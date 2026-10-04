#!/usr/bin/env python3
"""Small closed-literal decode laws for every type: valid encodings decode, one invalid encoding per rule does not (manual spec-mutation audit, round 5: d01..d06, c05).

    python3 codegen/proofs/slop/decode_literal_laws.py [--check]

Public counterexamples (round 5, probe B'): a list of VarTestStruct whose first offset is 5 decoded; a ProgressiveComplexTestStruct whose bit list has no delimiter
decoded; a 2-byte list of 3-byte SmallTestStruct decoded; CompatibleUnionBC with selector 1 decoded; a Bitlist[257] of 258 bits decoded; the default value of
ProgressiveTestStruct and ProgressiveComplexTestStruct refused. The mutants of these validators were unjudged: any edit to a validator made the pinned checker
overflow its stack on every big file that unfolds it, before a statement could fail. These laws decode literal byte strings of at most 2048 bytes, so a mutant
fails one of them in a file of a few seconds, by name.

For every name X with a decoder (`X_decode(buf, size)`), proofs/slop/validity/<runtime>_<X>_decode_literal_<kind>[_<tag>]_generated.bend (one module per law
for a variable-size container or union, one per kind otherwise: a mutated validator may loop on another literal) holds laws on literal buffers
(the bytes are computed here from the schema, little-endian words):

  <X>_decode_vlit_ok_<tag>     decodes (Some): the default encoding (fixed parts zero, variable parts empty, offsets at the end of the fixed part), and
                               for each field / element a non-empty valid variant (a list with one and with two elements, recursively one level down)
  <X>_decode_vlit_bad_<tag>    does not decode (None), one literal per rule:
      fixed type               one byte short, one byte long; a boolean byte 2; the padding bits of a bit vector set
      list of fixed elements   a ragged length (one element plus one byte, for elements of 2 bytes or more); one element past the limit; an invalid element
      byte list                one byte past the limit
      list of variable elems   the first offset 5 (not a multiple of 4 / not the table size), the first offset 0; an invalid element
      bit list                 no delimiter (a zero last byte); one bit past the limit
      container                the first offset plus one, minus one; the second offset below the first; each field holding the first invalid
                               literal of its type (the offsets recomputed)
      union                    a selector that is no option; an option holding an invalid payload

By computation; filed by api_gate under decode_offsets (the `_decode_vlit_` form).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import generic_form_schemas as generic  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402
from codegen.proofs.slop.decode_checked_laws import enc0, buffer  # noqa: E402

MAX_BYTES = 2048
MAX_LAWS = 64
RT_MAX = 128     # bytes: the literal a round-trip law re-encodes word by word
DECODE = re.compile(r'^def (\w+)_decode\(buf: B\.Buf, \+size: U32\) -> B\.Buf & Maybe<&1, ([\w.]+)>:', re.M)


def kids_of(t):
    return [(fn, c) for fn, c in t.fields] if t.kind != 'vector' else [(f'e{i}', t.elem) for i in range(t.size)]


def compose(kids, encs):
    """the encoding of a container / vector of variable elements from the encodings of its children"""
    head = sum(c.fixed_size() if c.fixed() else 4 for _, c in kids)
    fixed, var = b'', b''
    for (_, c), e in zip(kids, encs):
        if c.fixed():
            fixed += e
        else:
            fixed += (head + len(var)).to_bytes(4, 'little')
            var += e
    return fixed + var


def elems(e_t, items):
    """the encoding of a list of the given element encodings"""
    if e_t.fixed():
        return b''.join(items)
    head = 4 * len(items)
    offs, body = b'', b''
    for it in items:
        offs += (head + len(body)).to_bytes(4, 'little')
        body += it
    return offs + body


def goods(t, depth=0):
    """[(tag, bytes)]: valid encodings, the default first"""
    d = enc0(t)
    if d is None:
        return []
    out = [('default', d)]
    if depth > 1:
        return out
    k = t.kind
    if k in ('list', 'plist'):
        e = enc0(t.elem)
        if e is not None:
            for n in (1, 2):
                if k == 'plist' or n <= t.size:
                    out.append((f'n{n}', elems(t.elem, [e] * n)))
    elif k == 'bytelist':
        if t.size >= 1:
            out.append(('n1', b'\x07'))
    elif k in ('bitlist', 'pbits'):
        if k == 'pbits' or t.size >= 1:
            out.append(('n1', b'\x03'))
    elif k in ('container', 'pcontainer') and not t.fixed():
        kids = kids_of(t)
        base = [enc0(c) for _, c in kids]
        for i, (fn, c) in enumerate(kids):
            if c.fixed():
                continue
            for tag, g in goods(c, depth + 1)[1:3]:
                encs = list(base)
                encs[i] = g
                out.append((f'{fn}_{tag}', compose(kids, encs)))
        # every variable field non-empty at once: each field's window differs from its neighbours' (a reader that reads a field at another one's offset)
        full = [(goods(c, depth + 1)[1:2] or [(None, base[i])])[0][1] if not c.fixed() else base[i] for i, (_, c) in enumerate(kids)]
        if full != base:
            out.append(('all', compose(kids, full)))
        # the same with two elements per list and the element bytes of fixed-size lists starting with 4: read at a neighbour's offset, those bytes
        # parse as a short offset table (a small wrong value, not a loop over a garbage count), so a reader at the wrong window fails the round trip
        marked = []
        for i, (_, c) in enumerate(kids):
            if c.fixed():
                marked.append(base[i])
            elif c.kind in ('list', 'plist') and c.elem.fixed() and c.elem.fixed_size() >= 4 and (c.kind == 'plist' or c.size >= 2):
                marked.append((b'\x04' + bytes(c.elem.fixed_size() - 1)) * 2)
            else:
                g = goods(c, depth + 1)
                marked.append((g[2:3] or g[1:2] or [(None, base[i])])[0][1])
        if marked != base and marked != full:
            out.append(('marked', compose(kids, marked)))
    return out


def child_bads(c, depth):
    """the invalid literals of a child type that keep their own length (a short or long fixed value would only shift the offsets)"""
    return [x for x in bads(c, depth + 1) if x[0] not in ('short', 'long')][:10]


def bads(t, depth=0):
    """[(tag, bytes)]: invalid encodings, one per rule"""
    d = enc0(t)
    if d is None or depth > 3:
        return []
    k = t.kind
    out = []
    if t.fixed():
        if depth == 0:
            if len(d) > 0:
                out.append(('short', d[:-1]))
            out.append(('long', d + b'\x00'))
        if k == 'bool':
            out.append(('bool2', b'\x02'))
        elif k == 'bits' and t.size % 8:
            out.append(('pad', d[:-1] + bytes([1 << (t.size % 8)])))
        elif k in ('container', 'vector'):
            kids = kids_of(t)
            base = [enc0(c) for _, c in kids]
            for i, (fn, c) in enumerate(kids):
                for tag, b in child_bads(c, depth):
                    encs = list(base)
                    encs[i] = b
                    out.append((f'{fn}_{tag}', compose(kids, encs) if k == 'container' else b''.join(encs)))
                    break
        return out
    if k in ('list', 'plist'):
        e_t = t.elem
        e = enc0(e_t)
        if e is None:
            return out
        if e_t.fixed():
            if len(e) >= 2:
                out.append(('ragged', e + b'\x00'))
            for L in sorted({1, 2, len(e) // 2, len(e) - 1, len(e) + 1, len(e) + 2} - {0}):
                if L % len(e) and len(e) >= 2:
                    out.append((f'ragged_{L}', bytes(L)))      # a length that is no multiple of the element size (every unit test, every divisor)
            if k == 'list' and (t.size + 1) * len(e) <= MAX_BYTES:
                out.append(('over', e * (t.size + 1)))
        else:
            two = elems(e_t, [e, e])
            out.append(('off5', (5).to_bytes(4, 'little') + b'\x00' + e))         # a first offset that is no multiple of 4, inside the window
            out.append(('off0', (0).to_bytes(4, 'little') + e))
            out.append(('first_past', (len(e) + 8).to_bytes(4, 'little') + e))                       # the table runs past the window
            out.append(('off_desc', two[:4] + (int.from_bytes(two[:4], 'little') - 1).to_bytes(4, 'little') + two[8:]))   # the second offset before the first
            out.append(('off_past', two[:4] + (len(two) + 1).to_bytes(4, 'little') + two[8:]))         # the second offset past the window
            if k == 'list' and t.size < 16:
                out.append(('over', elems(e_t, [e] * (t.size + 1))))
        for tag, b in child_bads(e_t, depth):
            out.append((f'elem_{tag}', elems(e_t, [b])))
    elif k == 'bytelist':
        if t.size + 1 <= MAX_BYTES:
            out.append(('over', bytes(t.size + 1)))
    elif k in ('bitlist', 'pbits'):
        out.append(('nodelim', b'\x00'))
        if k == 'bitlist' and t.size + 1 <= 8 * MAX_BYTES - 8:
            n = t.size + 1                       # bits; the delimiter is bit n
            b = bytearray((n + 8) // 8)
            b[n // 8] |= 1 << (n % 8)
            out.append(('over', bytes(b)))
    elif k in ('container', 'pcontainer', 'vector'):
        kids = kids_of(t)
        base = [enc0(c) for _, c in kids]
        var = [i for i, (_, c) in enumerate(kids) if not c.fixed()]
        offs = {i: sum(c.fixed_size() if c.fixed() else 4 for _, c in kids[:i]) for i in var}
        if var and k != 'vector':
            pos = offs[var[0]]
            first = int.from_bytes(d[pos:pos + 4], 'little')
            for tag, v in (('off_plus', first + 1), ('off_minus', first - 1)):
                out.append((tag, d[:pos] + v.to_bytes(4, 'little') + d[pos + 4:] + (b'\x00' if tag == 'off_plus' else b'')))
            for a, b2 in zip(var, var[1:]):
                # consecutive offsets out of order: the later one one byte before the earlier (every variable part empty)
                p2 = offs[b2]
                prev = int.from_bytes(d[offs[a]:offs[a] + 4], 'little')
                out.append((f'order_{kids[b2][0]}', d[:p2] + (prev - 1).to_bytes(4, 'little') + d[p2 + 4:]))
        for i, (fn, c) in enumerate(kids):
            for tag, b in child_bads(c, depth):
                encs = list(base)
                encs[i] = b
                out.append((f'{fn}_{tag}', compose(kids, encs)))
    elif k == 'cunion' and t.selectors and t.fields:
        sels = set(t.selectors)
        bad_sel = next(s for s in range(256) if s not in sels)
        arm = enc0(t.fields[0][1])
        if arm is not None:
            out.append(('selector', bytes([bad_sel]) + arm))
        for tag, b in child_bads(t.fields[0][1], depth):
            out.append((f'arm_{tag}', bytes([t.selectors[0]]) + b))
    return out


def words_of(data):
    return [int.from_bytes(data[i:i + 4].ljust(4, b'\0'), 'little') for i in range(0, len(data), 4)]


def tnest(t, k):
    out = t
    for _ in range(k - 1):
        out = f'{t} & ({out})'
    return out


def nest(xs):
    return xs[0] if len(xs) == 1 else f'({xs[0]}, {nest(xs[1:])})'


def laws_of(X, V, t, ser_pair):
    val = V if V.startswith('O.') or V in ('U32', 'Bool') else f'T.{V}'
    M = f'Maybe<&1, {val}>'
    out, seen, widths = [], set(), set()

    def dec(data):
        return f'Pair.snd(B.Buf, {M}, T.{X}_decode({buffer(data)}, {len(data)}))'

    def law(kind, tag, data):
        if len(data) > MAX_BYTES or (kind, data) in seen or len(out) >= MAX_LAWS:
            return
        seen.add((kind, data))
        tag = re.sub(r'\W', '_', tag)
        if kind == 'rt':
            # the decoded value serializes back to the same bytes: the size, then every word (a reader that reads a field at another
            # field's window decodes something, but not this)
            ws = words_of(data)
            widths.add(len(ws))
            stmt = f'(Pair.snd(B.Buf, U32, B.size(rt({dec(data)}))), rw{len(ws)}(rt({dec(data)}), 0)) == ({len(data)}, {nest([str(w) for w in ws])}) : U32 & ({tnest("U32", len(ws))})'
            out.append(f'def {X}_decode_vlit_rt_{tag}()\n    -> {{{stmt}}}:\n  {{==}}')
            return
        want = 'True' if kind == 'ok' else 'False'
        out.append(f'def {X}_decode_vlit_{kind}_{tag}()\n    -> {{some1({dec(data)}) == {want}{{}} : Bool}}:\n  {{==}}')
    good = goods(t)
    for tag, g in good:
        law('ok', tag, g)
    for tag, b in bads(t):
        law('bad', tag, b)
    for tag, g in good:
        if 0 < len(g) <= RT_MAX and ser_pair is not None:
            law('rt', tag, g)
    ser = f'Pair.snd({val}, O.Encoded, T.{X}_serialize(v))' if ser_pair else f'T.{X}_serialize(v)'
    helper = [f'def some1(m: {M}) -> Bool:\n  match m:\n    case Some{{v}}: True{{}}\n    case None{{}}: False{{}}\n',
              f'def rt(m: {M}) -> B.Buf:\n  match m:\n    case Some{{v}}: O.ser_out({ser})\n    case None{{}}: B.empty()\n']
    if widths:
        helper.append('def rw1(b: B.Buf, +i: U32) -> U32: Pair.snd(B.Buf, U32, B.read32(b, i))\n')
        for k in range(2, max(widths) + 1):
            helper.append(f'def rwc{k}(+i: U32, pair: B.Buf & U32) -> {tnest("U32", k)}:\n  (b, +x) = pair\n  (x, rw{k - 1}(b, (i + 4 : U32)))\n\n'
                          f'def rw{k}(b: B.Buf, +i: U32) -> {tnest("U32", k)}: rwc{k}(i, B.read32(b, i))\n')
    return '\n'.join(helper), out


def module(tmod, X, helper, laws):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('decode_literal_laws'),
         f'# {X}: literal encodings that decode and literal encodings that do not (manual spec-mutation audit, round 5; docs/mutation_testing/MUTATION_PROOFS.md).', '', helper]
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        for m in DECODE.finditer(tx.text):
            X, V = m.group(1), m.group(2)
            t = names.get(X)
            if t is None:
                continue
            ser = tx.get(f'{X}_serialize')
            helper, laws = laws_of(X, V, t, None if not ser else ' & O.Encoded' in ser[1] or ser[1].strip().endswith('& O.Encoded'))
            # A mutated validator can loop for minutes on one literal (a garbage offset read as a count of 2^15 elements) before the checker
            # reaches the law that names its fault: a variable-size container or union gets one module per law, every other type one module
            # per kind (ok, bad, rt), so the law that kills a mutant is in a file of its own.
            split = t.kind in ('container', 'pcontainer', 'cunion') and not t.fixed()
            groups = {}
            for text in laws:
                kind, tag = re.match(rf'def {re.escape(X)}_decode_vlit_(ok|bad|rt)_(\w+)\(', text).groups()
                groups.setdefault(f'{kind}_{tag}' if split else kind, []).append(text)
            for key, texts in groups.items():
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_{key}')] = module(tmod, X, helper, texts)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'decode_literal_laws', ('validity',), 'stale decode literal laws: ', 'decode literal laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
