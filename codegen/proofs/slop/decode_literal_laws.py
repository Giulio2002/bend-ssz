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
  <X>_decode_vlit_rt_<tag>     (a literal of at most 128 bytes) decodes, and its value serializes back to the same size and words
  (round 7, every variable-size container X; the decoder's readers, which no other literal reached)
  <X>_decode_vlit_ok_fixed / _rt_fixed   the default value with every fixed leaf distinct (each word of a uint / byte vector a fresh mark from
                               4 to 243, so no word reads as a large count): decodes, and serializes back to the same size and first 192 words
                               (a field read at a neighbour's position: gas_used at timestamp's, a signature over the offset)
  <X>_decode_vlit_ok_wide / _rt_wide     the same with every variable part three levels deep non-empty (byte lists of min(L, 20) bytes, lists of
                               fixed elements a whole number of words, two elements in a list of variable elements, bit lists of 5 bits; byte
                               lists and lists of fixed elements open with the word 4, so a window read at a neighbour's offset parses as a
                               table of one element): a reader at a wrong window, an element at its relative offset, a last element cut short
  <X>_decode_vlit_bad_size_<path>        one size rule broken deep inside a variable field, every offset right: a validator that skips a child's
                               window accepts it (SignedBeaconBlock's message: a ragged proposer slashing)
  <X>_decode_vlit_bad_count_<p>          (every list p of variable elements with a limit N that X validates) symbolic: an aligned first offset inside
                               the window, at least 4, that counts more than N elements makes the head refuse (by rewriting its four tests)

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
RT_WIDE = 192    # words: a round-trip law of the round-7 literals (`fixed`, `wide`) compares the size and at most this many words from byte 0
DEEP = 3         # nesting levels the `wide` literal fills (deeper variable parts stay empty)
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


class Marks:
    """distinct small word values for the round-7 literals: every word a reader may take for an offset or a count is between 4 and 243, so a
    mutated reader that reads a window at another field's offset parses a short table (a few elements) instead of looping over 2^30"""
    def __init__(self):
        self.k = 0

    def next(self):
        self.k += 1
        return 4 + (self.k - 1) % 240


def mfix(t, m, pos=0):
    """a valid encoding of the fixed type t whose leaves hold distinct values: each 4-byte word of a uint / byte vector a fresh mark; a uint8 /
    uint16 / short byte vector, a boolean (1) or a bit vector (bit 0) only where it starts a word (pos, the byte position mod 4), zero elsewhere,
    so that no word of the literal reads as a large count"""
    k = t.kind
    if k in ('uint', 'bytes') and t.size >= 4 and pos % 4 == 0:
        return b''.join(m.next().to_bytes(4, 'little') for _ in range(t.size // 4)) + bytes(t.size % 4)
    if k in ('bool', 'uint', 'bytes', 'bits'):
        n = t.fixed_size()
        if pos % 4:
            return bytes(n)
        lead = 1 if k in ('bool', 'bits') else m.next()
        return bytes([lead]) + bytes(n - 1)
    if k == 'vector':
        out = b''
        for _ in range(t.size):
            out += mfix(t.elem, m, pos + len(out))
        return out
    if k in ('container', 'pcontainer'):
        out = b''
        for _, c in t.fields:
            out += mfix(c, m, pos + len(out))
        return out
    raise ValueError(k)


def lead4(b):
    """the part with its first word 4: read at a neighbour's offset, it is a table of one element"""
    return b'\x04\x00\x00\x00' + b[4:] if len(b) >= 4 else b


def packed(e_t, n, m):
    """n elements of the fixed type e_t (each at its own byte position, for mfix)"""
    out = b''
    for _ in range(n):
        out += mfix(e_t, m, len(out))
    return out


def marked(t, m, wide, depth=0, pos=0):
    """(round 7) a valid encoding of t whose fixed leaves hold distinct marks (mfix); with `wide`, every variable part down to DEEP levels is
    non-empty: a byte list of min(L, 20) bytes (whole marked words), a list of fixed elements a whole number of words of them (at least 2), a
    list of variable elements two of them, a bit list min(L, 5) bits, each byte list and list of fixed elements opening with the word 4 (lead4);
    without it the variable parts are empty (the default's). None when not built."""
    k = t.kind
    if t.fixed():
        return mfix(t, m, pos)
    fill = wide and depth < DEEP
    if k == 'bytelist':
        if not fill or t.size < 1:
            return b''
        n = min(t.size, 20)
        if n >= 4:
            return lead4(b''.join(m.next().to_bytes(4, 'little') for _ in range(n // 4)))
        return bytes([m.next()]) + bytes(n - 1)
    if k in ('bitlist', 'pbits'):
        n = min(t.size, 5) if k == 'bitlist' else 5
        if not fill or n < 1:
            return b'\x01'
        bits = sum(1 << i for i in range(0, n, 2)) | (1 << n)
        return bits.to_bytes((n + 8) // 8, 'little')
    if k in ('list', 'plist'):
        lim = t.size if k == 'list' else 1 << 30
        if not fill or lim < 1:
            return b''
        e_t = t.elem
        if e_t.fixed():
            sz = e_t.fixed_size()
            n = 2
            while (n * sz) % 4:
                n += 1
            return lead4(packed(e_t, min(n, lim) if lim >= 2 else 1, m))
        items = [marked(e_t, m, wide, depth + 1) for _ in range(min(2, lim))]
        return None if any(i is None for i in items) else elems(e_t, items)
    if k in ('container', 'pcontainer', 'vector'):
        kids = kids_of(t)
        encs, at = [], pos
        for _, c in kids:
            encs.append(marked(c, m, wide, depth + 1, at))
            at += c.fixed_size() if c.fixed() else 4
        return None if any(e is None for e in encs) else compose(kids, encs)
    if k == 'cunion' and t.selectors and t.fields:
        arm = marked(t.fields[0][1], m, wide, depth + 1, 1)
        return None if arm is None else bytes([t.selectors[0]]) + arm
    return None


def size_bad(t, depth=0):
    """(round 7: c06/02) [(tag, bytes)]: an invalid encoding of t whose offsets are all right and whose fault is one size rule deep inside (a byte
    list one past its limit, a list of fixed elements one byte ragged, a bit list without its delimiter), the rest the default: a validator that
    skips a window refuses nothing, and a reader that reads it anyway stops after a few elements. One literal per variable field of t."""
    if depth > 4 or t.fixed():
        return []
    k = t.kind
    if k == 'bytelist':
        return [('over', bytes(t.size + 1))] if t.size + 1 <= MAX_BYTES else []
    if k in ('bitlist', 'pbits'):
        return [('nodelim', b'\x00')]
    if k in ('list', 'plist'):
        e = enc0(t.elem)
        if e is None:
            return []
        if t.elem.fixed():
            return [('ragged', e + b'\x00')] if len(e) >= 2 else []
        return [(f'elem_{tag}', elems(t.elem, [b])) for tag, b in size_bad(t.elem, depth + 1)[:1]]
    if k in ('container', 'pcontainer'):
        kids = kids_of(t)
        base = [enc0(c) for _, c in kids]
        if any(b is None for b in base):
            return []
        out = []
        for i, (fn, c) in enumerate(kids):
            for tag, b in size_bad(c, depth + 1)[:1]:
                encs = list(base)
                encs[i] = b
                out.append((f'{fn}_{tag}', compose(kids, encs)))
        return out if depth == 0 else out[:1]
    return []


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
    out, seen = [], set()

    def dec(data):
        return f'Pair.snd(B.Buf, {M}, T.{X}_decode({buffer(data)}, {len(data)}))'

    def law(kind, tag, data, wide=False, r7=False):
        # the round-7 laws (r7) come after the cap of the earlier ones, which they do not displace
        if len(data) > MAX_BYTES or (kind, data) in seen or (len(out) >= MAX_LAWS and not r7):
            return
        seen.add((kind, data))
        tag = re.sub(r'\W', '_', tag)
        if kind == 'rt' and wide:
            # (round 7) the same for the larger literals: one decode, then the size and the first RT_WIDE words (the whole literal when it is shorter)
            ws = words_of(data)[:RT_WIDE]
            stmt = f'rtc{len(ws)}(rt({dec(data)})) == ({len(data)}, {nest([str(w) for w in ws])}) : U32 & ({tnest("U32", len(ws))})'
            out.append(f'def {X}_decode_vlit_rt_{tag}()\n    -> {{{stmt}}}:\n  {{==}}')
            return
        if kind == 'rt':
            # the decoded value serializes back to the same bytes: the size, then every word (a reader that reads a field at another
            # field's window decodes something, but not this)
            ws = words_of(data)
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
    if t.kind in ('container', 'pcontainer') and not t.fixed():
        # (round 7: c04, c05, c06/03, r5-d01/d02/d04) every fixed leaf distinct (`fixed`), and every variable part non-empty too (`wide`): a reader
        # that reads a field at a neighbour's position or window decodes these into a different value
        for tag, wide in (('fixed', False), ('wide', True)):
            d = marked(t, Marks(), wide)
            if d is not None and all(d != g for _, g in good):
                law('ok', tag, d, r7=True)
                if ser_pair is not None:
                    law('rt', tag, d, wide=True, r7=True)
        # (round 7: c06/02) one size fault deep inside each variable field, every offset right
        for tag, b in size_bad(t):
            law('bad', f'size_{tag}', b, r7=True)
    ser = f'Pair.snd({val}, O.Encoded, T.{X}_serialize(v))' if ser_pair else f'T.{X}_serialize(v)'
    helper = [f'def some1(m: {M}) -> Bool:\n  match m:\n    case Some{{v}}: True{{}}\n    case None{{}}: False{{}}\n',
              f'def rt(m: {M}) -> B.Buf:\n  match m:\n    case Some{{v}}: O.ser_out({ser})\n    case None{{}}: B.empty()\n']
    return '\n'.join(helper), out


def readers(laws):
    """the word readers the laws of one module use: rw1 .. rwK (and rtcK, the size and K words of one buffer)"""
    k = max([int(x) for x in re.findall(r'\b(?:rw|rtc)(\d+)\(', '\n'.join(laws))] or [0])
    if not k:
        return ''
    out = ['def rw1(b: B.Buf, +i: U32) -> U32: Pair.snd(B.Buf, U32, B.read32(b, i))\n']
    for j in range(2, k + 1):
        out.append(f'def rwc{j}(+i: U32, pair: B.Buf & U32) -> {tnest("U32", j)}:\n  (b, +x) = pair\n  (x, rw{j - 1}(b, (i + 4 : U32)))\n\n'
                   f'def rw{j}(b: B.Buf, +i: U32) -> {tnest("U32", j)}: rwc{j}(i, B.read32(b, i))\n')
    for j in sorted({int(x) for x in re.findall(r'\brtc(\d+)\(', '\n'.join(laws))}):
        out.append(f'def rtg{j}(pair: B.Buf & U32) -> U32 & ({tnest("U32", j)}):\n  (b, +n) = pair\n  (n, rw{j}(b, 0))\n\n'
                   f'def rtc{j}(b: B.Buf) -> U32 & ({tnest("U32", j)}): rtg{j}(B.size(b))\n')
    return '\n'.join(out)


HEAD = re.compile(r'^def (\w+)_head\(\+len: U32, \+off: U32, pair: B\.Buf & U32\) -> B\.Buf & Bool:\n  \(buf, \+first\) = pair\n  \1_first\((.*), buf, off, len, first\)$')


def count_laws(tx, X):
    """(round 7: c05/01) [(p, law)]: for every list of variable elements with a limit N that X's own definitions validate (`p_ok`), a table whose
    first offset is aligned, inside the window and at least 4 but counts more than N elements is refused, symbolic in the buffer, the position,
    the length and the offset. The proof rewrites the four tests of the head in turn (the count test last), so a head that does not test the
    count against N leaves the last rewrite without its subterm. No closed term over the large offset: the count is a variable."""
    out = []
    for name, b in sorted(tx.blk.items()):
        m = HEAD.match(b)
        if not m:
            continue
        p, g = m.group(1), m.group(2)
        lim = re.fullmatch(r'Bool\.and\(Bool\.and\(U32\.is_eq\(\(first \.&\. 3 : U32\), 0\), U32\.is_le\(first, len\)\), Bool\.and\(U32\.is_le\(4, first\), U32\.is_le\(U32\.shrn\(first, 2n\), (\d+)\)\)\)', g)
        if not lim:
            continue
        N = int(lim.group(1))
        if not p.startswith(f'l{N}_'):
            raise SystemExit(f'{p}_head tests the count against {N}: its name says otherwise')
        if not any(n.startswith(X + '_') and re.search(rf'\b{re.escape(p)}_ok\(', bb) for n, bb in tx.blk.items()):
            continue
        lhs = lambda a, b2, c, d: f'T.{p}_first(Bool.and(Bool.and({a}, {b2}), Bool.and({c}, {d})), buf, off, len, first) == (buf, False{{}}) : B.Buf & Bool'  # noqa: E731
        A, Lb, F4, C = 'U32.is_eq((first .&. 3 : U32), 0)', 'U32.is_le(first, len)', 'U32.is_le(4, first)', f'U32.is_le(U32.shrn(first, 2n), {N})'
        out.append((p, f'''def {X}_decode_vlit_bad_count_{p}(buf: B.Buf, +off: U32, +len: U32, +first: U32,
    ha: {{{A} == True{{}} : Bool}},
    hl: {{{Lb} == True{{}} : Bool}},
    h4: {{{F4} == True{{}} : Bool}},
    hn: {{{C} == False{{}} : Bool}})
    -> {{T.{p}_head(len, off, (buf, first)) == (buf, False{{}}) : B.Buf & Bool}}:
  %Equal.sym(Bool, {A}, True{{}}, ha) : {{{lhs('_', Lb, F4, C)}}}
  %Equal.sym(Bool, {Lb}, True{{}}, hl) : {{{lhs('True{}', '_', F4, C)}}}
  %Equal.sym(Bool, {F4}, True{{}}, h4) : {{{lhs('True{}', 'True{}', '_', C)}}}
  %Equal.sym(Bool, {C}, False{{}}, hn) : {{{lhs('True{}', 'True{}', 'True{}', '_')}}}
  {{==}}'''))
    return out


def module(tmod, X, helper, laws):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('decode_literal_laws'),
         f'# {X}: literal encodings that decode and literal encodings that do not (manual spec-mutation audit, round 5; docs/mutation_testing/MUTATION_PROOFS.md).', '', helper]
    rd = readers(laws)
    if rd:
        L.append(rd)
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
            for p, text in count_laws(tx, X):
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_count_{p}')] = module(tmod, X, '', [text])
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'decode_literal_laws', ('validity',), 'stale decode literal laws: ', 'decode literal laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
