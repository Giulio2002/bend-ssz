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
  <X>_decode_vlit_bad_order_sym_o<i>     (every offset i >= 1 of a variable-size container X) symbolic: o_i below o_{i-1} makes the validator refuse
  <X>_decode_vlit_win_<step> / _win_elem_<p>   symbolic: each step of X's reader that reads an offset slot or a variable field reads the slot and the
                               window the schema asks for (checked here against the generated reader); element i of a list of variable elements
                               X reaches is read at off + s_i up to e_i
  (round 10)
  <X>_decode_vlit_win_<step>   also every step that reads a fixed field: the field at its own position and size in the fixed part (BeaconState
                               r10-r01/11: proposer_lookahead read at the previous field's position; no literal of the 2.7 MB default fits a law)
  <X>_decode_vlit_bad_order_<f>  the out-of-order literal of the container rule above for every variable-size container up to ORDER_MAX bytes,
                               above the byte and law caps of the other literals (r10-l02/09: LightClientUpdate, LightClientFinalityUpdate)
  (round 11, manual audit a01/09..12, b03/01, /10..12, f01/02)
  <X>_decode_vlit_fwin_<step>            symbolic: for every container X that a parent reads (a field, a list element: X is read at a non-zero
                               offset), each step of X's reader that reads a fixed field reads it at off + its position (the gate: every fixed field)
  <X>_decode_vlit_bad_box_<field>        X's default with one variable field holding an invalid boxed value (its own check fails) or a list / vector
                               field of variable elements holding one invalid element; X a list / vector of variable elements: one invalid
                               element (`_bad_box_elem`). The gate: every type in a boxed position anywhere is refused inside some parent
                               (the transaction byte list is exempt: an invalid one is over 2^30 bytes)
  <X>_decode_vlit_ok_sel_<s>             (every compatible union) the selector s with its option's default payload decodes to the option of s
                               (`X_selector` answers s); `_bad_sel_<s>`: 0, 255 and every selector next to a declared one are refused
  (round 12, manual audit e02/01..03, e03/01..04)
  <X>_decode_vlit_vwin_<step>            symbolic: each step of the container X's validator that checks a fixed field in place (`F_ok_at`: a bit vector's
                               padding, a boolean) restates the step, the position checked against the schema
  <X>_decode_vlit_ck_<p>_step / _end / _first   symbolic: the element loop of every list / vector kind p of fixed checked elements (List[Validator]):
                               the verdict kept, element i + 1 at off + (i + 1) * size, the first at off (the gate: every such loop, under the
                               first decoder that reaches it)
  (round 13: r2-random-api/16, /17) <X>_decode_vlit_count_at_<p> / _count_over_<p>   (every list p that X validates, symbolic; count_at_laws)
                               the count check accepts exactly the limit N and refuses N + 1, stated on the length (and for a bit list the last
                               byte) only, so a BeaconState list of 262144 pending consolidations is pinned without a 4 MiB literal
  (round 13: s01-copy/09, /10) <X>_decode_vlit_rt_ua<s>_<f>   (every variable-size container X, every variable field f decoded by a byte copy:
                               a byte list or a list of fixed elements any bytes of which are valid) a literal whose field f holds marked bytes
                               starting at a byte offset s = 1, 2, 3 mod 4 (an earlier variable field padded to shift it), every other variable
                               part empty: decodes, and serializes back to the same size and words (copy_in's dispatch on off & 3)

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
ORDER_MAX = 65536  # bytes: the out-of-order offset literals (round 10), every container but BeaconState (2.7 MB; its order law is symbolic)
U32_MAX = 1 << 32
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


def free(t):
    """every byte string of t's fixed size is a valid t (uints and byte vectors, and vectors / containers of them)"""
    if t.kind in ('uint', 'bytes'):
        return True
    if t.kind in ('vector', 'container') and t.fixed():
        return all(free(c) for _, c in kids_of(t))
    return False


def mbytes(n, seed=0):
    """n marked bytes, none zero, no two neighbours equal: a copy shifted by one, two or three bytes reads other values"""
    return bytes(((seed + 37 * j) % 251) + 1 for j in range(n))


UA_LEN = 9      # bytes a copied field holds: three words at every shift, a partial last word


def payload(c, depth=0):
    """(round 13) a valid encoding of the variable type c holding about UA_LEN marked bytes that its decoder copies (a byte list, a list of
    free fixed elements, a bit list, or one level down a list of such variable elements / a container with such a field), or None"""
    k = c.kind
    if k == 'bytelist':
        return mbytes(min(c.size, UA_LEN)) if c.size >= 1 else None
    if k in ('list', 'plist'):
        lim = c.size if k == 'list' else 1 << 30
        e = c.elem
        if lim < 1:
            return None
        if e.fixed() and free(e):
            es = e.fixed_size()
            return mbytes(min(lim, -(-UA_LEN // es)) * es)
        if not e.fixed() and depth < 2:
            p = payload(e, depth + 1)
            return None if p is None else elems(e, [p])
        return None
    if k in ('bitlist', 'pbits'):
        m = min(UA_LEN, (c.size if k == 'bitlist' else 1 << 30) // 8 + 1)
        return mbytes(m - 1) + b'\x01' if m >= 2 else None
    if k in ('container', 'pcontainer', 'vector') and not c.fixed() and depth < 2:
        kids = kids_of(c)
        base = [enc0(x) for _, x in kids]
        if any(b is None for b in base):
            return None
        for i, (_, x) in enumerate(kids):
            if not x.fixed():
                p = payload(x, depth + 1)
                if p is not None:
                    encs = list(base)
                    encs[i] = p
                    return compose(kids, encs)
    return None


def pads(c):
    """(round 13) valid encodings of the variable type c of 0 to 3 more bytes than the least (to shift the fields after it)"""
    k = c.kind
    if k == 'bytelist':
        return [mbytes(n, 5) for n in range(1, min(3, c.size) + 1)]
    if k in ('list', 'plist') and c.elem.fixed() and free(c.elem):
        lim = c.size if k == 'list' else 3
        return [mbytes(n * c.elem.fixed_size(), 5) for n in range(1, min(3, lim) + 1)]
    if k in ('bitlist', 'pbits'):
        N = c.size if k == 'bitlist' else 1 << 30
        return [mbytes(m - 1, 5) + b'\x01' for m in range(2, 5) if 8 * (m - 1) <= N]
    return []


def ua_literals(t):
    """(round 13: s01-copy/09, /10) [(tag, bytes)]: for every variable field f of the container t whose decoder copies bytes (payload) and every
    s = 1, 2, 3 that some padding of an earlier variable field reaches, an encoding whose field f starts at a byte offset s mod 4 and holds
    marked bytes, every other variable part empty (the default's) or the padding"""
    if t.kind not in ('container', 'pcontainer') or t.fixed():
        return []
    kids = kids_of(t)
    base = [enc0(c) for _, c in kids]
    if any(b is None for b in base):
        return []
    head = sum(c.fixed_size() if c.fixed() else 4 for _, c in kids)
    var = [i for i, (_, c) in enumerate(kids) if not c.fixed()]
    out = []
    for i in var:
        p = payload(kids[i][1])
        if p is None:
            continue
        cands = [None] + [(j, pb) for j in var if j < i for pb in pads(kids[j][1])]
        for s in (1, 2, 3):
            for cand in cands:
                encs = list(base)
                encs[i] = p
                if cand:
                    encs[cand[0]] = cand[1]
                if (head + sum(len(encs[j]) for j in var if j < i)) % 4 == s:
                    out.append((f'ua{s}_{kids[i][0]}', compose(kids, encs)))
                    break
    return out


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

    def law(kind, tag, data, wide=False, r7=False, cap=MAX_BYTES):
        # the round-7 laws (r7) come after the cap of the earlier ones, which they do not displace
        if (kind, data) in seen:
            return True
        if len(data) > cap or (len(out) >= MAX_LAWS and not r7):
            return False
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
        return True
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
        # (round 10: r10-l02/09) two consecutive offsets out of order, for every variable-size container: above the byte cap of the other literals
        # (the light-client updates hold a sync committee) and the law cap (AttesterSlashing); the literal is the default encoding with one
        # offset one byte below the one before it, so a validator that drops the order test reads a negative window
        for tag, b in bads(t):
            if tag.startswith('order_'):
                law('bad', tag, b, r7=True, cap=ORDER_MAX)
        # (round 13: s01-copy/09, /10) a copied field at each unaligned start: decodes and serializes back word for word
        for tag, d in ua_literals(t):
            if ser_pair is not None:
                law('rt', tag, d, wide=True, r7=True)
            else:
                law('ok', tag, d, r7=True)
    # (round 11: b03/01, /10, /11, /12) one invalid boxed value in a variable field or one invalid element in a list of variable elements: refused
    for tag, b, e in box_laws(t):
        if law('bad', f'box_{tag}', b, r7=True):
            COVER.add(e)
    sel = []
    if t.kind == 'cunion' and t.selectors and t.fields:
        # (round 11: f01/02) every declared selector decodes to its own option (two options of the same payload type: a reader that builds the
        # first for both decodes, but answers the other selector); the selectors next to the declared ones, 0 and 255 are refused
        for s, (_, c) in zip(t.selectors, t.fields):
            a = enc0(c)
            if a is not None and 1 + len(a) <= MAX_BYTES:
                seen.add(('sel', bytes([s]) + a))
                out.append(f'def {X}_decode_vlit_ok_sel_{s}()\n    -> {{selof({dec(bytes([s]) + a)}) == {s} : U32}}:\n  {{==}}')
                sel.append(s)
        arm = enc0(t.fields[0][1])
        declared = set(t.selectors)
        if arm is not None:
            for s in sorted(({0, 255} | {x + d for x in declared for d in (-1, 1)}) - declared):
                if 0 <= s <= 255:
                    law('bad', f'sel_{s}', bytes([s]) + arm, r7=True)
        if set(sel) != declared:
            raise SystemExit(f'{X}: no selector law for {sorted(declared - set(sel))}')
    ser = f'Pair.snd({val}, O.Encoded, T.{X}_serialize(v))' if ser_pair else f'T.{X}_serialize(v)'
    helper = [f'def some1(m: {M}) -> Bool:\n  match m:\n    case Some{{v}}: True{{}}\n    case None{{}}: False{{}}\n',
              f'def rt(m: {M}) -> B.Buf:\n  match m:\n    case Some{{v}}: O.ser_out({ser})\n    case None{{}}: B.empty()\n']
    if sel:
        helper.append(f'def selof(m: {M}) -> U32:\n  match m:\n    case Some{{v}}: Pair.snd({val}, U32, T.{X}_selector(v))\n    case None{{}}: 0\n')
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


FIXED_OK = re.compile(r'\(buf, Bool\.and\(U32\.is_eq\(len, \(U32\.div\(len, (\d+)\) \* \1 : U32\)\), U32\.is_le\(U32\.div\(len, \1\), (\d+)\)\)\)')
BYTES_OK = re.compile(r'\(buf, U32\.is_le\(len, (\d+)\)\)')
BITS_OK = re.compile(r'O\.ok_bitlist\(buf, off, len, (\d+), False\{\}\)')
BITS_EVAL = 1 << 20  # bits: the bit-list check compares 8 (len - 1) + high bit with the limit as Nats; at the largest limit (Attestation's 131072)
                     # the law checks in 2 s, also at a quarter of the pinned stack budget (4 MB / 2.5 MB JSC): the literals are not unfolded


def count_at_laws(tx, X):
    """(round 13: r2-random-api/16, /17) [(p, law)]: for every list p that X's own definitions validate (`p_ok`), the count check accepts a
    list of exactly the limit N and refuses N + 1, symbolic in the buffer and the position (no literal of the list's bytes: the check reads
    only the length, or, for a bit list, the last byte, given as a premise):

      list of fixed elements of S bytes  `p_ok(buf, off, N * S)` is (buf, True), `p_ok(buf, off, (N + 1) * S)` is (buf, False)   (when (N + 1) * S < 2^32)
      byte list                          `p_ok(buf, off, N)` accepted, `N + 1` refused
      bit list (N <= BITS_EVAL)          the last byte the delimiter of exactly N bits: accepted; of N + 1 bits: refused
      list of variable elements          the head with the first offset 4 N (a table of N elements) inside the window is the head's
                                         accepting branch `p_first(True, ..)` (count N + 1 is `_decode_vlit_bad_count_<p>`)

    A list whose limit times its element size passes 2^32 (BeaconState's validators, balances, ...) has no count test (NMAX bounds it) and no law.
    A check that refuses a full list (`<` for `<=`) fails `_count_at_`; one that admits N + 1 fails `_count_over_`."""
    out = []
    for name, b in sorted(tx.blk.items()):
        if not name.endswith('_ok'):
            continue
        p = name[:-3]
        if not any(n.startswith(X + '_') and re.search(rf'\b{re.escape(p)}_ok\(', bb) for n, bb in tx.blk.items()):
            continue
        body = b.split(' -> B.Buf & Bool: ', 1)[1] if b.startswith(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: ') else ''
        laws = []
        m = FIXED_OK.fullmatch(body)
        if m:
            S, N = int(m.group(1)), int(m.group(2))
            for tag, n, want in (('at', N, 'True'), ('over', N + 1, 'False')):
                if n * S < U32_MAX:
                    laws.append(f'def {X}_decode_vlit_count_{tag}_{p}(buf: B.Buf, +off: U32)\n    -> {{T.{p}_ok(buf, off, {n * S}) == (buf, {want}{{}}) : B.Buf & Bool}}:\n  {{==}}')
        m = BYTES_OK.fullmatch(body)
        if m:
            N = int(m.group(1))
            for tag, n, want in (('at', N, 'True'), ('over', N + 1, 'False')):
                if n < U32_MAX:
                    laws.append(f'def {X}_decode_vlit_count_{tag}_{p}(buf: B.Buf, +off: U32)\n    -> {{T.{p}_ok(buf, off, {n}) == (buf, {want}{{}}) : B.Buf & Bool}}:\n  {{==}}')
        m = BITS_OK.fullmatch(body)
        if m and int(m.group(1)) <= BITS_EVAL:
            N = int(m.group(1))
            for tag, n, want in (('at', N, 'True'), ('over', N + 1, 'False')):
                L, D = n // 8 + 1, 1 << (n % 8)       # n bits and the delimiter: bit n % 8 of byte n // 8, the last
                rd = f'B.byte_at(buf, (off + {L} - 1 : U32))'
                laws.append(f'''def {X}_decode_vlit_count_{tag}_{p}(buf: B.Buf, +off: U32,
    hb: {{{rd} == (buf, {D}) : B.Buf & U32}})
    -> {{T.{p}_ok(buf, off, {L}) == (buf, {want}{{}}) : B.Buf & Bool}}:
  %Equal.sym(B.Buf & U32, {rd}, (buf, {D}), hb) : {{O.bitlist_pick({L}, {N}, False{{}}, _) == (buf, {want}{{}}) : B.Buf & Bool}}
  {{==}}''')
        out += [(p, t) for t in laws]
    for name, b in sorted(tx.blk.items()):
        m = HEAD.match(b)
        if not m:
            continue
        p, g = m.group(1), m.group(2)
        lim = re.fullmatch(r'Bool\.and\(Bool\.and\(U32\.is_eq\(\(first \.&\. 3 : U32\), 0\), U32\.is_le\(first, len\)\), Bool\.and\(U32\.is_le\(4, first\), U32\.is_le\(U32\.shrn\(first, 2n\), (\d+)\)\)\)', g)
        if not lim or not any(n.startswith(X + '_') and re.search(rf'\b{re.escape(p)}_ok\(', bb) for n, bb in tx.blk.items()):
            continue
        F = 4 * int(lim.group(1))
        if F >= U32_MAX:
            continue
        Lb = f'U32.is_le({F}, len)'
        out.append((p, f'''def {X}_decode_vlit_count_at_{p}(buf: B.Buf, +off: U32, +len: U32,
    hl: {{{Lb} == True{{}} : Bool}})
    -> {{T.{p}_head(len, off, (buf, {F})) == T.{p}_first(True{{}}, buf, off, len, {F}) : B.Buf & Bool}}:
  %Equal.sym(Bool, {Lb}, True{{}}, hl) : {{T.{p}_first(Bool.and(Bool.and(True{{}}, _), Bool.and(True{{}}, True{{}})), buf, off, len, {F}) == T.{p}_first(True{{}}, buf, off, len, {F}) : B.Buf & Bool}}
  {{==}}'''))
    return out


def order_laws(tx, X):
    """(round 7 / r5-d02/01) [law]: for every offset o_i (i >= 1) of the variable-size container X, an offset below the one before it makes the
    validator refuse, symbolic in the buffer, the position, the length and the offsets: the offset test `o_{i-1} <= o_i` is rewritten to False
    (a validator that drops it leaves the rewrite without its subterm). The literal laws cannot reach this when a crossing window is still
    accepted by the field types around it (ProgressiveTestStruct with offsets 16, 16, 24, 16 decoded)."""
    out = []
    i = 1
    while f'{X}_v{i}' in tx.blk:
        m = re.fullmatch(rf'def {re.escape(X)}_v{i}\(\+off: U32, \+len: U32, (.*), pair: B\.Buf & U32\) -> B\.Buf & Bool:\n  \(buf, \+o{i}\) = pair\n'
                         rf'  {re.escape(X)}_c{i}\(Bool\.and\(U32\.is_le\(o{i - 1}, o{i}\), U32\.is_le\(o{i}, len\)\), buf, off, len, (.*)\)', tx.blk[f'{X}_v{i}'])
        if not m:
            break
        prm, args = m.group(1), m.group(2)
        pre = ', '.join(a.split(':')[0].strip() for a in prm.split(', '))
        if args != f'{pre.replace("+", "")}, o{i}':
            raise SystemExit(f'{X}_v{i}: unexpected arguments {args}')
        T = f'T.{X}_c{i}'
        out.append(f'''def {X}_decode_vlit_bad_order_sym_o{i}(buf: B.Buf, +off: U32, +len: U32, {prm}, +o{i}: U32,
    hlt: {{U32.is_le(o{i - 1}, o{i}) == False{{}} : Bool}})
    -> {{T.{X}_v{i}(off, len, {args.rsplit(', ', 1)[0]}, (buf, o{i})) == (buf, False{{}}) : B.Buf & Bool}}:
  %Equal.sym(Bool, U32.is_le(o{i - 1}, o{i}), False{{}}, hlt) : {{{T}(Bool.and(_, U32.is_le(o{i}, len)), buf, off, len, {args}) == (buf, False{{}}) : B.Buf & Bool}}
  {{==}}''')
        i += 1
    return out


RD = re.compile(r'def (\w+)\((.*), pair: B\.Buf & ([^)]*)\) -> (.*):\n  \(buf, (\+?)(\w+)\) = pair\n  (.*)')
WIN = re.compile(r'(\w+)\(buf, \(off \+ (o_\w+) : U32\), \((\w+) - (o_\w+) : U32\)\)')
SLOT = re.compile(r'B\.read32\(buf, \(off \+ (\d+) : U32\)\)')
FIX = re.compile(r'(\w+)_read\(buf, \(off \+ (\d+) : U32\), (\d+)\)')


def qualify(text, names):
    """the runtime's own names (definitions and types) as T.<name>"""
    return re.sub(r'(?<![.\w])(\w+)(?![\w])', lambda m: f'T.{m.group(1)}' if m.group(1) in names else m.group(1), text)


def window_laws(tx, X, t, names):
    """(round 7: r5-d01/10, r5-d02/07, r5-d02/08, c04/10..12) [law]: the reader's windows, symbolic in the buffer and every offset. For each step of X's
    reader that reads an offset slot or a variable field, the step is the read the schema asks for: the slot of the next variable field at its
    position (4 bytes per variable field, the fixed sizes before it), the field f at off + o_f up to the next field's offset (the last up to the
    end); for each list of variable elements X's reader reaches, element i at off + s_i up to e_i. The generator checks the generated reader
    against the schema (and stops on a difference); the statement unfolds one step, so a reader that reads another slot or window fails it."""
    if t.kind not in ('container', 'pcontainer') or t.fixed():
        return []
    var = [fn for fn, c in t.fields if not c.fixed()]
    fix = {}     # (round 10) the position and size of every fixed field in the fixed part
    slot, pos = {}, 0
    for fn, c in t.fields:
        if not c.fixed():
            slot[fn] = pos
        else:
            fix[fn] = (pos, c.fixed_size())
        pos += c.fixed_size() if c.fixed() else 4
    out = []
    for name, b in sorted(tx.blk.items()):
        if not re.fullmatch(rf'{re.escape(X)}(_g\d+)?_rd\d+', name):
            continue
        m = RD.fullmatch(b)
        if not m:
            continue
        _, prm, pty, ret, plus, v, body = m.groups()
        sl, wn, fx = SLOT.findall(body), WIN.findall(body), FIX.findall(body)
        ok = False
        if len(sl) == 1 and not wn and v.startswith('o_') and v[2:] in var and var.index(v[2:]) + 1 < len(var):
            nxt = var[var.index(v[2:]) + 1]
            if int(sl[0]) != slot[nxt]:
                raise SystemExit(f'{name}: reads the slot of {nxt} at {sl[0]}, the schema says {slot[nxt]}')
            ok = True
        elif len(wn) == 1 and not sl:
            _, a, end, a2 = wn[0]
            f = a[2:]
            if a != a2 or f not in var:
                raise SystemExit(f'{name}: reads a window {wn[0]}')
            i = var.index(f)
            want = ('len', 'vend') if i + 1 == len(var) else (f'o_{var[i + 1]}', 'vend')    # vend: the end of a group's variable parts (the parent's next offset)
            if end not in want:
                raise SystemExit(f'{name}: the window of {f} ends at {end}, the schema says {want[0]}')
            ok = True
        elif len(fx) == 1 and not sl and not wn:
            # (round 10: r10-r01/11, BeaconState) a step that reads a fixed field reads it at its own position and size; the field is the one
            # the next step binds
            nm = re.match(r'(\w+)\(', body)
            nb = RD.fullmatch(tx.blk.get(nm.group(1), '')) if nm else None
            f = nb.group(6) if nb else None
            if f not in fix:
                raise SystemExit(f'{name}: reads a fixed window {fx[0]} for {f}, which is no fixed field of {X}')
            if (int(fx[0][1]), int(fx[0][2])) != fix[f]:
                raise SystemExit(f'{name}: reads {f} at ({fx[0][1]}, {fx[0][2]}), the schema says {fix[f]}')
            ok = True
        if not ok:
            continue
        args = ', '.join(p.split(':')[0].strip().lstrip('+') for p in MC.split_top_args(prm))
        tag = name[len(X) + 1:]
        out.append(qualify(f'def {X}_decode_vlit_win_{tag}(buf: B.Buf, {prm}, {plus}{v}: {pty})\n'
                           f'    -> {{{name}({args}, (buf, {v})) == {body} : {ret}}}:\n  {{==}}', names))
    for p in sorted({p for n, bb in tx.blk.items() if n.startswith(X + '_') for p in re.findall(r'\b(\w+)_read\(buf', bb)}):
        b = tx.blk.get(f'{p}_elem_win')
        if not b:
            continue
        m = re.fullmatch(rf'def {re.escape(p)}_elem_win\(\+off: U32, \+s: U32, \+e: U32, buf: B\.Buf\) -> (.*): (\w+)\(buf, (.*)\)', b)
        if not m:
            continue
        if m.group(3) != '(off + s : U32), (e - s : U32)':
            raise SystemExit(f'{p}_elem_win reads ({m.group(3)}): the element window is (off + s, e - s)')
        out.append(qualify(f'def {X}_decode_vlit_win_elem_{p}(+off: U32, +s: U32, +e: U32, buf: B.Buf)\n'
                           f'    -> {{{p}_elem_win(off, s, e, buf) == {m.group(2)}(buf, (off + s : U32), (e - s : U32)) : {m.group(1)}}}:\n  {{==}}', names))
    return out


FREAD = re.compile(r'\(buf, \(off \+ (\d+) : U32\)')     # a read at the container's offset plus a literal position
FREAD_ABS = re.compile(r'\(buf, \((\d+) : U32\)')         # a read at an absolute literal position (the container's offset dropped)


def nested(tx, X):
    """True when a definition of another name reads X (`X_read` / `X_bx_read`): X is read at a non-zero offset (a field of a parent, an element)"""
    pat = re.compile(rf'(?<![\w.]){re.escape(X)}_(?:bx_)?read\(buf')
    return any(not n.startswith(X + '_') and pat.search(b) for n, b in tx.blk.items())


def field_window_laws(tx, X, t, names):
    """(round 11: a01/09..12) [law]: for every container X that a parent reads (a field of another container, an element of a list), each step of
    X's reader that reads a fixed field reads it at off + the field's position in X (symbolic in the buffer, the offset and every argument). A
    reader written for a top-level container (a position without `off`) is right at off = 0 only: the decode literal laws, which decode X at
    offset 0, cannot see it. The generator checks every such read against the schema and stops on a difference; the gate asks a law for every
    fixed field of a nested container."""
    if t.kind not in ('container', 'pcontainer') or f'{X}_read' not in tx.blk or not nested(tx, X):
        return []
    pos, at = {}, 0
    for fn, c in t.fields:
        if c.fixed():
            pos[fn] = at
        at += c.fixed_size() if c.fixed() else 4
    steps = {}
    for name, b in tx.blk.items():
        if re.fullmatch(rf'{re.escape(X)}(_g\d+)?_rd\d+', name):
            m = RD.fullmatch(b)
            if m:
                steps[name] = m.groups()
    out, seen = [], set()
    for name, b in sorted(tx.blk.items()):
        entry = re.fullmatch(rf'{re.escape(X)}(_g\d+)?_read', name)
        if not (entry or name in steps):
            continue
        if entry:
            m = re.fullmatch(r'def \w+\((.*)\) -> (.*?): (.*)', b)
            if not m:
                continue
            prm, ret, body = m.groups()
        else:
            _, prm, pty, ret, plus, v, body = steps[name]
        if FREAD_ABS.search(body):
            raise SystemExit(f'{name}: reads at an absolute position ({body}): a nested reader reads at off + the position')
        nm = re.match(r'(\w+)\(', body)
        rd = FREAD.findall(body)
        if not (nm and nm.group(1) in steps and len(rd) == 1):
            continue
        f = steps[nm.group(1)][5]       # the field the next step receives
        if f not in pos:
            continue
        if int(rd[0]) != pos[f]:
            raise SystemExit(f'{name}: reads {f} at off + {rd[0]}, the schema says off + {pos[f]}')
        seen.add(f)
        args = ', '.join(p.split(':')[0].strip().lstrip('+') for p in MC.split_top_args(prm))
        tag = name[len(X) + 1:]
        if entry:
            stmt = f'{name}({args}) == {body} : {ret}'
            params = prm
        else:
            stmt = f'{name}({args}, (buf, {v})) == {body} : {ret}'
            params = f'buf: B.Buf, {prm}, {plus}{v}: {pty}'
        out.append(qualify(f'def {X}_decode_vlit_fwin_{tag}({params})\n    -> {{{stmt}}}:\n  {{==}}', names))
    if set(pos) - seen:
        raise SystemExit(f'{X}: no reader step found for the fixed fields {sorted(set(pos) - seen)} (field window laws)')
    return out


VSTEP = re.compile(r'def (\w+)\(ok: Bool, (.*)\) -> (.*):\n  match ok:\n    case True\{\}: (.*)\n    case False\{\}: .*')
OKAT = re.compile(r'_ok_at\(buf, \(off \+ (\d+) : U32\)\)')


def validator_window_laws(tx, X, t, names):
    """(round 12: e03/01..04) [law]: each step of the container X's validator that checks a fixed field in place (`F_ok_at(buf, (off + N))`: a
    bit vector's padding, a boolean, a nested container's own checks) checks it at off + the field's position (N one of the schema's
    positions; the statement restates the step, so a check at a neighbour's byte fails it). Symbolic in the buffer and every argument."""
    if t.kind not in ('container', 'pcontainer'):
        return []
    pos, at = set(), 0
    for _, c in t.fields:
        if c.fixed():
            pos.add(at)
        at += c.fixed_size() if c.fixed() else 4
    out = []
    for name, b in sorted(tx.blk.items()):
        if not re.fullmatch(rf'{re.escape(X)}(_g\d+)?_(c\d+|ok_len)', name):
            continue
        m = VSTEP.fullmatch(b)
        if not m:
            continue
        _, prm, ret, body = m.groups()
        ns = OKAT.findall(body)
        if len(ns) != 1:
            continue
        if int(ns[0]) not in pos:
            raise SystemExit(f'{name}: checks a fixed field at off + {ns[0]}, which starts no fixed field of {X}')
        args = ', '.join(p.split(':')[0].strip().lstrip('+') for p in MC.split_top_args(prm))
        out.append(qualify(f'def {X}_decode_vlit_vwin_{name[len(X) + 1:]}({prm})\n    -> {{{name}(True{{}}, {args}) == {body} : {ret}}}:\n  {{==}}', names))
    return out


CK = re.compile(r'def (\w+)_ck\(\+k: Nat, \+i: U32, \+off: U32, \+acc: Bool, pair: B\.Buf & Bool\) -> B\.Buf & Bool:\n  match k:\n'
                r'    case 0n: O\.and_pair\(acc, pair\)\n    case 1n\+q:\n      \(buf, ok\) = pair\n      (.*)')
NZ = re.compile(r'def (\w+)_ok_nz\(empty: Bool, buf: B\.Buf, \+off: U32, \+n: U32\) -> B\.Buf & Bool:\n  match empty:\n'
                r'    case True\{\}: \(buf, True\{\}\)\n    case False\{\}: (.*)')


def elem_check_laws(tx, p, X, names):
    """(round 12: e02/01..03) [law]: the element loop of the list / vector kind p of fixed checked elements (List[Validator] in BeaconState):
    one step keeps the running verdict (`Bool.and(acc, ok)`) and checks element i + 1 at off + (i + 1) * size; the first element is checked
    at off. Symbolic in the buffer, the offset, the index and the verdicts: each statement unfolds one step (the stride is checked here
    against the length test `U32.div(len, size)`)."""
    m = CK.fullmatch(tx.blk.get(f'{p}_ck', ''))
    if not m:
        return []
    step = m.group(2)
    es = re.search(r'U32\.div\(len, (\d+)\)', tx.blk.get(f'{p}_ok_len', '') + tx.blk.get(f'{p}_ok', ''))
    st = re.search(r'(?:_ok_at|O\.ok_bool)\(buf, \(off \+ \(i \+ 1 : U32\) \* (\d+) : U32\)\)', step)
    if not st or 'Bool.and(acc, ok)' not in step or (es and es.group(1) != st.group(1)):
        raise SystemExit(f'{p}_ck: the step `{step}` is not: verdict kept, element i + 1 at off + (i + 1) * {es.group(1) if es else "size"}')
    out = [qualify(f'def {X}_decode_vlit_ck_{p}_step(+q: Nat, +i: U32, +off: U32, +acc: Bool, buf: B.Buf, ok: Bool)\n'
                   f'    -> {{{p}_ck(1n+q, i, off, acc, (buf, ok)) == {step} : B.Buf & Bool}}:\n  {{==}}', names),
           qualify(f'def {X}_decode_vlit_ck_{p}_end(+i: U32, +off: U32, +acc: Bool, buf: B.Buf, ok: Bool)\n'
                   f'    -> {{{p}_ck(0n, i, off, acc, (buf, ok)) == O.and_pair(acc, (buf, ok)) : B.Buf & Bool}}:\n  {{==}}', names)]
    nz = NZ.fullmatch(tx.blk.get(f'{p}_ok_nz', ''))
    if nz:
        first = nz.group(2)
        if not re.search(r'(?:_ok_at|O\.ok_bool)\(buf, off\)\)$', first):
            raise SystemExit(f'{p}_ok_nz: the first element is not checked at off ({first})')
        out.append(qualify(f'def {X}_decode_vlit_ck_{p}_first(buf: B.Buf, +off: U32, +n: U32)\n'
                           f'    -> {{{p}_ok_nz(False{{}}, buf, off, n) == {first} : B.Buf & Bool}}:\n  {{==}}', names))
    return out


def box_bad(c):
    """(round 11: b03) an invalid encoding of the variable-size value c whose fault is c's own (or, for a list / vector of variable elements,
    one element's own): the check a boxed element's validator `E_bx_ok` makes. (bytes, the type whose own check refuses it) or None"""
    if c.fixed() or c.kind in ('bytelist', 'bitlist', 'pbits') or (c.kind in ('list', 'plist', 'vector') and c.elem.fixed()):
        return None     # validated in place (no boxed value): a list of fixed elements checks its elements at known positions
    if c.kind in ('list', 'plist', 'vector') and not c.elem.fixed():
        e = c.elem
        bad = child_bads(e, 0)[:1]
        if not bad:
            return None
        if c.kind == 'vector':
            d = enc0(e)
            if d is None:
                return None
            return elems(e, [bad[0][1]] + [d] * (c.size - 1)), e
        return elems(e, [bad[0][1]]), e
    bad = child_bads(c, 0)[:1]
    return (bad[0][1], c) if bad else None


def box_laws(t):
    """(round 11: b03/01, /10, /11, /12) [(tag, bytes, the type of the invalid boxed value)]: X's default with one variable field holding an
    invalid boxed value (a container, a list whose own check fails) or a list / vector of variable elements holding one invalid element (the
    element's own validator refuses it); X itself a list / vector of variable elements: one invalid element. Each must not decode."""
    out = []
    if t.kind in ('list', 'plist', 'vector') and not t.elem.fixed():
        r = box_bad(t)
        if r:
            out.append(('elem', r[0], r[1]))
    elif t.kind in ('container', 'pcontainer') and not t.fixed():
        kids = kids_of(t)
        base = [enc0(c) for _, c in kids]
        if any(b is None for b in base):
            return out
        for i, (fn, c) in enumerate(kids):
            r = box_bad(c)
            if r:
                encs = list(base)
                encs[i] = r[0]
                out.append((fn, compose(kids, encs), r[1]))
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
        rtnames = set(tx.blk) | set(re.findall(r'^type (\w+)', tx.text, re.M))
        ck_done = set()
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
            wlaws = window_laws(tx, X, t, rtnames)
            if wlaws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_win')] = module(tmod, X, '', wlaws)
            flaws = field_window_laws(tx, X, t, rtnames)
            if flaws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_fwin')] = module(tmod, X, '', flaws)
            vlaws = validator_window_laws(tx, X, t, rtnames)
            if vlaws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_vwin')] = module(tmod, X, '', vlaws)
            # (round 12) the element loops X's validator reaches (directly, or X itself), each stated once (under the first name that reaches it)
            own = '\n'.join(b for n, b in tx.blk.items() if n.startswith(X + '_'))
            for p in sorted({q for q in re.findall(r'\b(\w+)_ok(?:_at|_n)?\(buf', own) if f'{q}_ck' in tx.blk} - ck_done):
                claws = elem_check_laws(tx, p, X, rtnames)
                if claws:
                    ck_done.add(p)
                    out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_ck_{p}')] = module(tmod, X, '', claws)
            olaws = order_laws(tx, X)
            if olaws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_order_sym')] = module(tmod, X, '', olaws)
            for p, text in count_laws(tx, X):
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_count_{p}')] = module(tmod, X, '', [text])
            alaws = [text for _, text in count_at_laws(tx, X)]
            if alaws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_literal_count_at')] = module(tmod, X, '', alaws)
            boxed_positions(t, NEED, set())
        # (round 12) the gate of the element-loop laws: every element loop of fixed checked elements is reached from a decoder
        left_ck = sorted(m.group(1) for b in tx.blk.values() for m in [CK.fullmatch(b)] if m and m.group(1) not in ck_done)
        if left_ck:
            raise SystemExit(f'decode_literal_laws: element loops with no step law ({runtime}): ' + ', '.join(left_ck))
    # (round 11: b03) the coverage gate of the boxed-value laws: every variable-size value that sits in a boxed position (a container field of a
    # container, an element of a list / vector of variable elements) and has an invalid encoding of its own is refused, by some law, inside a parent
    left = sorted({e.name or repr(e) for e in NEED - COVER})
    if left:
        raise SystemExit('decode_literal_laws: boxed values with no reject law: ' + '; '.join(left))
    return out


COVER = set()      # the types an invalid boxed value of which some `_bad_box_` law refuses
NEED = set()       # the types that sit in a boxed position somewhere (and have an invalid encoding of their own)


def boxed_positions(t, need, seen):
    """the types in a boxed position anywhere below t (see box_laws): a variable container / union field, an element of a list / vector of
    variable elements; only those whose own invalid encoding box_bad can build"""
    if t in seen or t.fixed():
        return
    seen.add(t)
    if t.kind in ('list', 'plist', 'vector'):
        r = box_bad(t)
        if r:
            need.add(r[1])
        boxed_positions(t.elem, need, seen)
    elif t.kind in ('container', 'pcontainer', 'cunion'):
        for _, c in t.fields:
            if t.kind != 'cunion' and not c.fixed() and c.kind in ('container', 'pcontainer', 'cunion'):
                r = box_bad(c)
                if r:
                    need.add(r[1])
            boxed_positions(c, need, seen)


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'decode_literal_laws', ('validity',), 'stale decode literal laws: ', 'decode literal laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
