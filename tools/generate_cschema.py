"""Compile the frozen Fulu schema constants into the compact runtime schema.

`spec/fulu_schemas.bend` is frozen and states every size and limit as a unary
`Nat`: a `List[Validator, 2^40]` limit is a numeral with 2^40 successors, which
no runtime may convert, divide or compare. This generator reads those
definitions - it never invents a schema - and emits `types/fulu_cschema.bend`,
in which every quantity the hot path needs is machine sized and precomputed:
element strides, fixed sizes, each field's header offset inside the fixed part,
list limits as a 32-bit value plus a "bigger than any possible input" flag, and
the merkle depth of every sequence.

Limits are exact: an SSZ encoding is shorter than 2^32 bytes, so a limit at or
above 2^32 can never be exceeded by a machine-sized count, and the flag records
exactly that case rather than truncating the number.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'spec/fulu_schemas.bend'
TARGET = ROOT / 'types/fulu_cschema.bend'
INDEX = ROOT / 'types/fulu_cschema_index.bend'
WIDTHS = {'U8': 1, 'U16': 2, 'U32Width': 4, 'U64': 8, 'U128': 16, 'U256': 32}
U32_MAX = 1 << 32


def parse_nat(text):
    text = text.strip()
    literal = re.fullmatch(r'(\d+)n', text)
    if literal:
        return int(literal.group(1))
    converted = re.fullmatch(r'U32\.to_nat\((\d+)\)', text)
    if converted:
        return int(converted.group(1))
    product = re.fullmatch(r'Nat\.mul\((.+),\s*(.+)\)', text, re.S)
    if product:
        return parse_nat(product.group(1)) * parse_nat(product.group(2))
    total = re.fullmatch(r'Nat\.add\((.+),\s*(.+)\)', text, re.S)
    if total:
        return parse_nat(total.group(1)) + parse_nat(total.group(2))
    raise SystemExit('unrecognised size expression: ' + text)


def split_args(text):
    """Split a constructor argument list on top-level commas."""
    out, depth, current = [], 0, ''
    for ch in text:
        if ch in '{[(':
            depth += 1
        elif ch in '}])':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(current)
            current = ''
        else:
            current += ch
    out.append(current)
    return [x.strip() for x in out if x.strip()]


def parse(text, defs):
    """Parse one schema expression into a tuple tree."""
    text = text.strip()
    call = re.fullmatch(r'(\w+)\(\)', text)
    if call:
        return parse(defs[call.group(1)], defs)
    head = re.fullmatch(r'T\.(\w+)\{(.*)\}', text, re.S)
    if not head:
        raise SystemExit('unrecognised schema expression: ' + text)
    name, body = head.group(1), head.group(2)
    args = split_args(body)
    if name in ('Boolean', 'End', 'Null'):
        return (name,)
    if name == 'Unsigned':
        return ('Unsigned', WIDTHS[re.fullmatch(r'P\.(\w+)\{\}', args[0]).group(1)])
    if name in ('ByteVector', 'BitVector'):
        return (name, parse_nat(args[0]))
    if name in ('ByteList', 'BitList'):
        return (name, parse_nat(args[0]))
    if name in ('Vector', 'ListOf'):
        return (name, parse(args[0], defs), parse_nat(args[1]))
    if name == 'Chain':
        return ('Chain', parse(args[0], defs), parse(args[1], defs))
    if name == 'Container':
        return ('Container', parse(args[1], defs))
    raise SystemExit('unsupported schema constructor: ' + name)


def depth_of(chunks):
    d = 0
    while (1 << d) < chunks:
        d += 1
    return d


def fixed_size(node):
    kind = node[0]
    if kind == 'Boolean':
        return 1
    if kind == 'Unsigned':
        return node[1]
    if kind == 'ByteVector':
        return node[1]
    if kind == 'BitVector':
        return (node[1] + 7) // 8
    if kind == 'Null':
        return 0
    if kind == 'Vector':
        inner = fixed_size(node[1])
        return None if inner is None else inner * node[2]
    if kind == 'Container':
        total = 0
        for field in fields_of(node[1]):
            size = fixed_size(field)
            if size is None:
                return None
            total += size
        return total
    return None


def fields_of(chain):
    out = []
    while chain[0] == 'Chain':
        out.append(chain[1])
        chain = chain[2]
    return out


def plain(node):
    """Is every byte string of the value's fixed size a valid encoding?

    True for uints, byte vectors, bit vectors of whole bytes (no padding bits
    to check) and fixed vectors and containers built only from such values.
    Booleans (0 or 1 only), partial-byte bit vectors (zero padding) and
    anything variable-sized (offsets, limits, terminators) are not plain. For
    a list, plain describes its elements: its own length and limit checks
    still run."""
    kind = node[0]
    if kind in ('Unsigned', 'ByteVector', 'Null'):
        return True
    if kind == 'BitVector':
        return node[1] % 8 == 0
    if kind in ('Vector', 'ListOf'):
        return fixed_size(node[1]) is not None and plain(node[1])
    if kind == 'Container':
        return fixed_size(node) is not None and all(plain(f) for f in fields_of(node[1]))
    return False


def header_size(node):
    size = fixed_size(node)
    return 4 if size is None else size


def limit_fields(limit):
    return ('%d, True{}' % 0) if limit >= U32_MAX else ('%d, False{}' % limit)


# Named schemas already emitted, keyed by their parsed tree. A nested schema
# that has a name of its own is emitted as a call to that name rather than
# expanded again: spec/fulu_schemas.bend nests deeply (a SignedAggregateAndProof
# contains an Attestation contains an AttestationData contains two Checkpoints),
# and expanding every occurrence made the generated module cost four gigabytes
# to elaborate. Sharing the definitions keeps it under a tenth of that.
#
# Structurally identical types share one definition, so a field may be emitted
# under a sibling's name (Slot, Epoch and Gwei are all uint64; VoluntaryExit and
# SyncAggregatorSelectionData are the same pair of uint64s). The schema table is
# structural, so that is the same schema, not an approximation of it.
SHARED = {}


def emit(node, top=False):
    if not top:
        name = SHARED.get(node)
        if name is not None:
            return '%s()' % name
    kind = node[0]
    if kind == 'Boolean':
        return 'S.CBool{}'
    if kind == 'Unsigned':
        return 'S.CUint{%d}' % node[1]
    if kind == 'Null':
        return 'S.CNull{}'
    if kind == 'ByteVector':
        return 'S.CBytes{%d, %d}' % (node[1], depth_of((node[1] + 31) // 32))
    if kind == 'ByteList':
        return 'S.CByteList{%s, %d}' % (limit_fields(node[1]), depth_of((node[1] + 31) // 32))
    if kind == 'BitVector':
        return 'S.CBitVec{%d, %d, %d}' % (node[1], (node[1] + 7) // 8, depth_of((node[1] + 255) // 256))
    if kind == 'BitList':
        return 'S.CBitList{%s, %d}' % (limit_fields(node[1]), depth_of((node[1] + 255) // 256))
    if kind in ('Vector', 'ListOf'):
        element, count = node[1], node[2]
        stride = fixed_size(element)
        basic = element[0] in ('Boolean', 'Unsigned', 'ByteVector', 'BitVector')
        # Elements whose roots are their own bytes laid out as chunks: packed
        # basic types, and 32-byte vectors, whose root is the single chunk
        # they occupy. Such a sequence is merkleized as one byte range, which
        # gives the same tree as rooting each element and merkleizing the
        # roots, without walking 65,536 randao mixes one frame at a time.
        packs = element[0] in ('Boolean', 'Unsigned') or element == ('ByteVector', 32)
        if stride is None:
            depth = depth_of(count) if kind == 'Vector' else depth_of(min(count, U32_MAX))
            if kind == 'Vector':
                return 'S.CVecVar{%s, %d, %d}' % (emit(element), count, depth)
            return 'S.CListVar{%s, %s, %d}' % (emit(element), limit_fields(count), depth)
        chunks = (count * stride + 31) // 32 if packs else count
        depth = depth_of(max(chunks, 1))
        if kind == 'Vector':
            return 'S.CVec{%s, %d, %d, %d, %s, %s}' % (
                emit(element), count, stride, depth, 'True{}' if packs else 'False{}',
                'True{}' if plain(node) else 'False{}')
        return 'S.CList{%s, %s, %d, %d, %s, %s}' % (
            emit(element), limit_fields(count), stride, depth, 'True{}' if packs else 'False{}',
            'True{}' if plain(node) else 'False{}')
    if kind == 'Container':
        members = fields_of(node[1])
        total = fixed_size(node)
        part = sum(header_size(f) for f in members)
        return 'S.CCont{%s, %d, %d, %d, %s, %d, %s}' % (
            emit_fields(members), len(members), part, total if total is not None else 0,
            'True{}' if total is not None else 'False{}', depth_of(max(len(members), 1)),
            'True{}' if plain(node) else 'False{}')
    raise SystemExit('cannot emit ' + kind)


def emit_fields(members, base=0):
    """Balanced field tree; each leaf carries its header offset."""
    if not members:
        return 'S.CFNone{}'
    if len(members) == 1:
        node = members[0]
        size = fixed_size(node)
        return 'S.CFLeaf{%s, %d, %d, %s}' % (
            emit(node), base, header_size(node), 'True{}' if size is not None else 'False{}')
    half = len(members) // 2
    low, high = members[:half], members[half:]
    return 'S.CFNode{%s, %s, %d}' % (
        emit_fields(low, base), emit_fields(high, base + sum(header_size(f) for f in low)), half)


def main():
    text = SOURCE.read_text()
    defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.+)$', text, re.M))
    names = [name for name in defs if not re.fullmatch(r'Schema\d+', name)]
    lines = [
        'import Base',
        'import ../src/cschema.bend as S',
        '',
        '# Generated by tools/generate_cschema.py from the frozen',
        '# spec/fulu_schemas.bend. Every size, limit, stride, header offset and',
        '# merkle depth is precomputed here so that the runtime never walks a unary',
        '# Nat. Do not edit by hand.',
        '',
    ]
    for name in names:
        tree = parse(defs[name], defs)
        lines.append('def %s() -> S.CS: %s' % (name, emit(tree, top=True)))
        SHARED.setdefault(tree, name)
    # Index dispatch lives in its own module, imported only by programs that
    # work on any type by number. It is a balanced binary dispatch on the bits
    # of the index rather than one 109-way match: the flat match cost the pinned
    # compiler 1.30 GB to elaborate, the balanced one 0.44 GB, and a program
    # holding both codecs plus the flat table did not fit the compile budget.
    index = [
        'import Base',
        'import ../src/cschema.bend as S',
        'import ./fulu_cschema.bend as F',
        '',
        '# Generated by tools/generate_cschema.py. Named schemas by index, in the',
        '# order of spec/fulu_schemas.bend (build/cschema-index.json). Do not edit',
        '# by hand.',
        '',
        '# Is bit k of i clear?',
        'def low(+i: U32, +k: Nat) -> Bool: U32.is_eq((U32.shrn(i, k) .&. 1 : U32), 0)',
        '',
    ]
    top = max(len(names) - 1, 1).bit_length() - 1

    def split_bit(lo, hi, bit):
        while bit >= 0 and lo + (1 << bit) >= hi:
            bit -= 1
        return bit

    def dispatch(lo, hi, bit):
        """Expression selecting names[lo:hi] by the bits of `i` from `bit` down."""
        bit = split_bit(lo, hi, bit)
        if bit < 0:
            return 'F.%s()' % names[lo]
        mid = lo + (1 << bit)
        name = 'at_%d_%d' % (lo, hi)
        # Children first: a definition must precede its use.
        clear, set_ = dispatch(lo, mid, bit - 1), dispatch(mid, hi, bit - 1)
        index.append('def %s(c: Bool, +i: U32) -> S.CS:' % name)
        index.append('  match c:')
        index.append('    case True{}: %s' % clear)
        index.append('    case False{}: %s' % set_)
        index.append('')
        return '%s(low(i, %dn), i)' % (name, bit)

    root = dispatch(0, len(names), top)
    index.append('def by_index(+i: U32) -> S.CS: %s' % root)
    INDEX.write_text('\n'.join(index) + '\n')
    TARGET.write_text('\n'.join(lines) + '\n')
    (ROOT / 'build').mkdir(exist_ok=True)
    (ROOT / 'build/cschema-index.json').write_text(json.dumps(names, indent=1) + '\n')
    print('wrote %s with %d named schemas' % (TARGET.relative_to(ROOT), len(names)))


if __name__ == '__main__':
    main()
