#!/usr/bin/env python3
"""Generate the spec-connected codec laws of the typed object API.

    python3 codegen/spec_laws.py [--check]

proofs/obj/spec_codec_<N>.bend holds, for every Fulu name whose encoding is a
whole number of 32-bit words at word-aligned positions (the class of
codegen/laws.py, see `word_aligned` there) and whose leaves are integers and
byte vectors, the laws that tie the generated codec to the INDEPENDENT
specification in spec/*:

    <N>_spec_bytes    the bytes the encoder emits (`B.emit`, the output path of
                      every native program) are the little-endian limbs of the
                      object's words;
    <N>_spec_encode   those bytes are in the spec's canonical encoding relation
                      `Decoding.decodes(Spec.<N>(), bytes, value)` with the
                      spec value of the object - encoder soundness against
                      spec/codec.bend, whose `decodes` is defined as
                      `encoding_for_legal_type(schema, value) == Some{bytes}`;
    <N>_spec_decode   decoding ANY buffer of the type's size - every word free,
                      including the padding words of the array - accepts and
                      returns the object of those words (acceptance and
                      soundness over all buffers of that size);
    <N>_spec_view     the bytes of that buffer are the limbs of its words, so
                      with <N>_spec_encode the decoded object's spec value is
                      related by the spec to exactly the buffer's bytes;
    <N>_spec_reject   decoding with any size other than the type's size is
                      refused, for every buffer (a hypothesis `size != n`, no
                      other premise).

proofs/obj/spec_unique_<N>.bend adds

    <N>_spec_unique   every spec value related to those bytes IS the decoded
                      object's value (completeness of the decoder's answer:
                      injectivity of the canonical image: proofs/decode_unique
                      `valid_unique` = decode_complete `image_unique`, which
                      END_TO_END's frozen `deserialize_unique` is, from the
                      validator's acceptance of the schema; END_TO_END itself is
                      not imported: on Bend 2.0.28 a check that imports it together
                      with spec_fixed.bend fails to resolve spec_fixed's
                      primitive_invariants names).

One module per name and family (spec_{codec,repr,load,input,unique}_<N>.bend):
Bend re-checks every import, so a grouped module made each importer (the API
facades, the gate, e2e) pay for every name in it (the Cell / MatrixEntry group
cost every facade of its seven names 100 s).

Nothing closed is evaluated over a large buffer:
  - spec_repr_<N> carries the literal laws to every perfect tree through
    repr_seg.bend (per node `<N>_L<i>_<p>` / `<N>_E<i>_<p>`: the leaves are
    syntactically `R.w(t, k)`; the evaluated bridge was cubic in the words), and
    applies the literal law inside `<law>_h` over free words (a decode call over
    1024 leaves `R.w(t, k)` is past the identity check's budget);
  - a 2^p-word byte vector (Cell) is decoded / emitted / encoded / loaded by
    arr_copy / arr_emit's loop laws for every perfect tree (pow2_trees), a
    container whose buffer's left half is such a field (MatrixEntry) likewise
    over a spine tree (emit_lhalf), a container whose first field is a vector of
    2^p + E words (Deposit) likewise with the copy by arr_copy.acp and
    arr_enc.cpt_tail_q (emit_ltail), every other encoder-bytes law of VIEW_MIN
    words or more is the evaluated writes (`<N>_enc`) then its view law (`<N>_vw`),
    every view law of VIEW_MIN words or more is
    arr_emit.emit_take, every loader law of that size arr_enc.load_tail (or
    arr_emit.load_all): the literal arrays are first rewritten to the thaw of the
    tree of their words (a constructor-by-constructor conversion), so no copy,
    emit or fill loop runs over closed U32 indices.

The spec value of an object is built from its words the only way the spec
allows: an integer of words is `UInt{words, 0...}`, a byte vector of words is
`BytesValue{limbs(words)}`, a container is `Sequence{Items{...}}`. The schema
the laws speak about is `Spec.<N>()` from the frozen spec/fulu_schemas.bend;
the structural schema written into the proof terms is checked against it by
the kernel (it must reduce to the same term), so a transcription slip fails.

Bit vectors of whole words are covered through proofs/obj/spec_bits.bend: the
spec value is `BitsValue{bitsof(words)}`, the words' bits low bit first.

The generic SSZ forms whose encoding is whole words at aligned positions (the
same class, 38 of the supported forms) get the same laws against their schema in
proofs/obj/generic_specs.bend: spec_gcodec_<N>, spec_grepr_<N>, spec_ginput_<N>,
spec_gunique_<N> (legality from the checked validator, type_validator_soundness).

Array-backed storage (more than 512 words), codegen/spec_arr.py ->
proofs/obj/spec_arr_<N>.bend and spec_arr_unique_<N>.bend for Blob,
HistoricalBatch, SyncCommittee and BlobSidecar, spec_garr_<N>.bend for the generic
Vector[uint32/64/128/256, 512] (vectors of more than VEC_MAX_ELEMS elements go
there: the element-by-element proof is quadratic in the count): the same laws for EVERY perfect buffer tree (and
every storage tree), proved with the loop laws of proofs/obj/arr_*.bend
(codegen/arr_laws.py) for symbolic counts; no closed size is compared. The
loader law (*_spec_input) is generated for Blob, HistoricalBatch, SyncCommittee
and the generic Vector[uintN, 512/513] forms; Vector[uintN, 513] (spec_arr.uvec_tail)
is a whole tree then the last element's words (arr_enc.cpt_tail).

Validator (a boolean inside an unaligned record), validator_module ->
proofs/obj/spec_rec_Validator.bend: the same laws (encoder bytes, decoder
acceptance and rejections, spec parts, uniqueness), with word_mul.bend.

Uniqueness uses proofs/decode_unique.bend `valid_unique` (decode_complete's
`image_unique` from the validator's acceptance of the schema, without the
compatibility_* chain in the import closure), which END_TO_END's
frozen `deserialize_unique` is: on Bend 2.0.28 a check that imports END_TO_END
together with spec_fixed.bend fails (spec_fixed's primitive_invariants names do
not resolve), which broke the former spec_unique_* files.

Not covered here, and not claimed: sub-word leaves inside vectors and generic
containers, bit vectors of partial words, variable-size shapes, roots.

`--no-big` is accepted: this generator writes no big_* file in any case.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import laws as LW  # noqa: E402
import schema  # noqa: E402
import arr_laws as AL  # noqa: E402
import spec_arr as SA  # noqa: E402
import spec_any as SANY  # noqa: E402
import root_laws_generic as RG  # noqa: E402
import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

ROOT = Path(__file__).resolve().parents[1]
WIDTH = {4: 'P.U32Width{}', 8: 'P.U64{}', 16: 'P.U128{}', 32: 'P.U256{}'}
PART = {4: 'F.uint32_part', 8: 'F.uint64_part', 16: 'F.uint128_part', 32: 'F.uint256_part'}


class Skip(Exception):
    pass


class Node:
    """One schema node of a law: the object term, its words in encoding order,
    its spec value and schema, and the proof that the spec's parts of that
    value are one fixed part holding the limbs of those words."""

    def __init__(self, obj, words, val, sch, proof, dec=None, opads=()):
        self.obj, self.words, self.val, self.sch, self.proof = obj, words, val, sch, proof
        # `dec`: the object a decoder builds (its own storage padding is zero);
        # `opads`: an arbitrary object's storage padding words, free in the
        # encoder laws.
        self.dec = obj if dec is None else dec
        self.opads = list(opads)


VEC_MAX_WORDS = 512
# EXACT: emit container/vector proofs whose every step states exactly the
# Codec.parts term its parent unfolds to (F.items_fixed / F.container_fixed /
# F.vector_fixed / F.bytes_part_n), so the checker compares syntactically and
# never runs the spec encoders to compare two forms (spec_codec_3: 55 s -> 5 s).
# This generator's own files use it; generators that import walk() keep the
# older form until their owners regenerate with SL.EXACT = True.
EXACT = False
# TOTAL (opt-in, off by default): in the EXACT container / vector proofs, the fixed parts' layout
# `total` by vspec.agg_total (encoding_fparts, valid_fparts) instead of {==}, which evaluates the
# bytes' domain over the symbolic words (encx_l134217728_PendingPartialWithdrawal: 1.1 s). The module
# must import ./vspec.bend as VS.
TOTAL = False
VEC_MAX_ELEMS = 256
# HOIST (opt-in, off by default): every container / vector node's value and parts proof become calls
# of lemmas over its words, hv<k>(w..) / hp<k>(w..), emitted once per distinct shape (identical
# sub-records share one), so a parent's proof only sees its children as small calls: the untyped
# F.*_fixed steps are otherwise re-checked inline over terms past the identity budget
# (var_rlist's ProposerSlashing RPRF: 4.2 s). Callers take the lemmas with hoist_take().
HOIST = False
_HOISTED = {}
# VLCT (opt-in, off by default; main() turns it on for spec_rec_Validator): the container's parts one
# step down by a rewrite with a lemma over an opaque value (lct), and the fields by the typed
# F.items_fixed: the aggregate-vs-parts and concatenate-vs-parts conversions evaluated all of the
# record's parts (Validator_parts_true/false: 11.6 s each).
VLCT = False


def hoist_take():
    '''The hoisted lemmas since the last call, as module text; resets the registry.'''
    txt = ''.join(d for _, d in sorted(_HOISTED.values()))
    _HOISTED.clear()
    return txt


def _hoist(node):
    if not HOIST:
        return node
    ws = node.words
    loc = {w: f'w{j}' for j, w in enumerate(ws)}
    ren = lambda s: re.sub(r'\bx\d+\b', lambda m: loc[m.group(0)], s)
    key = (ren(node.val), node.sch, ren(node.proof), len(ws))
    if key not in _HOISTED:
        k = len(_HOISTED)
        ps = ', '.join(f'+w{j}: U32' for j in range(len(ws)))
        args = ', '.join(f'w{j}' for j in range(len(ws)))
        # hq<k> unfolds hv<k> outside Codec.parts: comparing parts(hv<k>(..), s) with parts(<body>, s)
        # would evaluate the parts (1 s per record)
        R = f'Some{{[S.Fixed{{F.limbs([{args}])}}]}} : Maybe<&2, +List<S.Part>>'
        d = (f'def hv{k}({ps}) -> S.Value: {key[0]}\n\n'
             f'def hq{k}({ps}) -> {{{key[0]} == hv{k}({args}) : S.Value}}:\n  {{==}}\n\n'
             f'def hp{k}({ps}) -> {{Codec.parts(hv{k}({args}), {node.sch}) == {R}}}:\n'
             f'  %hq{k}({args}) : {{Codec.parts(_, {node.sch}) == {R}}}\n'
             f'  {key[2]}\n\n')
        _HOISTED[key] = (k, d)
    k = _HOISTED[key][0]
    a = ', '.join(ws)
    node.val, node.proof = f'hv{k}({a})', f'hp{k}({a})'
    return node


def words_depth(w):
    return max(0, (w - 1).bit_length())


def storage(n):
    """Depth of the packed storage a decoder allocates for n bytes (src/obj.bend
    `zeros_for`)."""
    return words_depth(((n + 31) >> 5) * 8 + 8)


def wl(ws):
    return '[' + ', '.join(ws) + ']'


def walk(g, t, c):
    s = g.shape(t)
    if t.kind == 'uint':
        if t.size not in WIDTH:
            raise Skip('sub-word integer')
        n = t.size // 4
        ws = [f'x{next(c)}' for _ in range(n)]
        if s.kind == 'u32':
            obj = ws[0]
        elif s.kind == 'u64':
            obj = f'O.U64{{{ws[0]}, {ws[1]}}}'
        else:
            obj = f'T.{s.rep}{{' + ', '.join(ws) + '}'
        val = 'S.UnsignedValue{P.UInt{' + ', '.join(ws + ['0'] * (8 - n)) + '}}'
        return Node(obj, ws, val, f'S.Unsigned{{{WIDTH[t.size]}}}', f'{PART[t.size]}(' + ', '.join(ws) + ')')
    if t.kind == 'bytes' and s.kind == 'fixwords':
        if t.size % 4 or t.size // 4 > VEC_MAX_WORDS:
            raise Skip('array-backed byte vector (needs the array induction)')
        ws = [f'x{next(c)}' for _ in range(t.size // 4)]
        op = [f'q{next(c)}' for _ in range((1 << storage(t.size)) - len(ws))]
        return Node(f'O.Words{{{tree(ws + op)}, {t.size}}}', ws, f'S.BytesValue{{F.limbs({wl(ws)})}}',
                    f'S.ByteVector{{{t.size}n}}', (f'F.bytes_part_n({ws[0]}, {wl(ws[1:])}, {t.size}n, {{==}}, {{==}})' if EXACT else f'F.bytes_part({ws[0]}, {wl(ws[1:])}, {{==}})'),
                    dec=f'O.Words{{{tree(ws + ["0"] * len(op))}, {t.size}}}', opads=op)
    if t.kind == 'vector' and s.kind in ('packed', 'packed_elems'):
        e = t.elem
        es = e.fixed_size()
        if not ((e.kind == 'bytes' and es % 4 == 0) or (e.kind == 'uint' and es in WIDTH)):
            raise Skip('vector of sub-word elements')
        if t.size * es // 4 > VEC_MAX_WORDS:
            raise Skip('array-backed vector (needs the array induction)')
        if t.size > VEC_MAX_ELEMS:
            # the element-by-element proof is quadratic in the element count
            # (Vector[uint32, 512]: 11 MB, over 30 min); spec_arr.uvec proves it over the tree
            raise Skip('long vector (spec_arr.uvec)')
        kids = [walk(g, e, c) for _ in range(t.size)]
        ws = [x for k in kids for x in k.words]
        n = t.fixed_size()
        op = [f'q{next(c)}' for _ in range((1 << storage(n)) - len(ws))]
        esch = kids[0].sch

        def vitems(i):
            return 'S.EmptyItems{}' if i == len(kids) else f'S.Items{{{kids[i].val}, {vitems(i + 1)}}}'

        def vcat(i):
            if i == len(kids):
                return '{==}'
            rest = '[' + ', '.join(f'S.Fixed{{F.limbs({wl(k.words)})}}' for k in kids[i + 1:]) + ']'
            if not EXACT:
                return (f'F.cat_fixed(Codec.parts({kids[i].val}, {esch}), F.limbs({wl(kids[i].words)}), '
                        f'Codec.parts({vitems(i + 1)}, S.Repeat{{{esch}}}), {rest}, {kids[i].proof}, {vcat(i + 1)})')
            return (f'F.items_rep({kids[i].val}, {vitems(i + 1)}, {esch}, F.limbs({wl(kids[i].words)}), '
                    f'{rest}, {kids[i].proof}, {vcat(i + 1)})')
        wss = '[' + ', '.join(wl(k.words) for k in kids) + ']'
        # every step states exactly the Codec.parts term its parent unfolds to,
        # so the checker compares syntactically instead of running the encoders
        tot = f'VS.agg_total({wss}, {n}n, {{==}})' if TOTAL else '{==}'
        proof = (f'F.vector_fixed({esch}, {t.size}n, {vitems(0)}, {wss}, {n}n, {wl(ws)}, {vcat(0)}, {{==}}, {{==}}, {tot}, {{==}})'
                 if EXACT else f'F.aggregate_fixed(Codec.parts({vitems(0)}, S.Repeat{{{esch}}}), {wss}, {n}n, {vcat(0)}, {{==}})')
        return _hoist(Node(f'O.Words{{{tree(ws + op)}, {n}}}', ws, f'S.Sequence{{{vitems(0)}}}',
                    f'S.Vector{{{esch}, {t.size}n}}', proof,
                    dec=f'O.Words{{{tree(ws + ["0"] * len(op))}, {n}}}', opads=op))
    if t.kind == 'bytes':
        if s.kind != 'rec':
            raise Skip('array-backed byte vector (needs the array induction)')
        if t.size % 4 or t.size == 0:
            raise Skip('byte vector not a whole number of words')
        ws = [f'x{next(c)}' for _ in range(t.size // 4)]
        obj = f'T.{s.rep}{{' + ', '.join(ws) + '}'
        return Node(obj, ws, f'S.BytesValue{{F.limbs({wl(ws)})}}', f'S.ByteVector{{{t.size}n}}',
                    (f'F.bytes_part_n({ws[0]}, {wl(ws[1:])}, {t.size}n, {{==}}, {{==}})' if EXACT else f'F.bytes_part({ws[0]}, {wl(ws[1:])}, {{==}})'))
    if t.kind == 'bits':
        if s.kind != 'rec':
            raise Skip('array-backed bit vector (needs the array induction)')
        if t.size % 32 or t.size == 0:
            raise Skip('bit vector not a whole number of words')
        ws = [f'x{next(c)}' for _ in range(t.size // 32)]
        obj = f'T.{s.rep}{{' + ', '.join(ws) + '}'
        return Node(obj, ws, f'S.BitsValue{{FB.bitsof({wl(ws)})}}', f'S.BitVector{{{t.size}n}}',
                    f'FB.bits_part({wl(ws)}, {t.size}n, {{==}}, {{==}})')
    if t.kind == 'container':
        if s.kind != 'container' or len(t.fields) > G.GROUP:
            raise Skip('grouped container')
        kids = []
        for (_, ft), (_, fs) in zip(t.fields, s.fields):
            k = walk(g, ft, c)
            if fs.kind == 'box':
                # a boxed child is stored as a one-element box around the record
                k.obj = f'O.BSome{{{k.obj}, O.BNone{{}}}}'
                k.dec = f'O.BSome{{{k.dec}, O.BNone{{}}}}'
            kids.append(k)
        names = '[' + ', '.join(f'"{f}"' for f, _ in t.fields) + ']'

        def items(i):
            return 'S.EmptyItems{}' if i == len(kids) else f'S.Items{{{kids[i].val}, {items(i + 1)}}}'

        def chain(i):
            return 'S.End{}' if i == len(kids) else f'S.Chain{{{kids[i].sch}, {chain(i + 1)}}}'

        def cat(i):
            if i == len(kids):
                return '{==}'
            rest = '[' + ', '.join(f'S.Fixed{{F.limbs({wl(k.words)})}}' for k in kids[i + 1:]) + ']'
            if not EXACT:
                return (f'F.cat_fixed(Codec.parts({kids[i].val}, {kids[i].sch}), F.limbs({wl(kids[i].words)}), '
                        f'Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, {kids[i].proof}, {cat(i + 1)})')
            return (f'F.items_fixed({kids[i].val}, {items(i + 1)}, {kids[i].sch}, {chain(i + 1)}, F.limbs({wl(kids[i].words)}), '
                    f'{rest}, {kids[i].proof}, {cat(i + 1)})')
        words = [w for k in kids for w in k.words]
        wss = '[' + ', '.join(wl(k.words) for k in kids) + ']'
        tot = f'VS.agg_total({wss}, {t.fixed_size()}n, {{==}})' if TOTAL else '{==}'
        proof = (f'F.container_fixed({names}, {chain(0)}, {items(0)}, {wss}, {t.fixed_size()}n, {wl(words)}, '
                 f'{cat(0)}, {{==}}, {tot}, {{==}})' if EXACT else
                 f'F.aggregate_fixed(Codec.parts({items(0)}, {chain(0)}), {wss}, {t.fixed_size()}n, {cat(0)}, {{==}})')
        obj = f'T.{s.t.name}{{' + ', '.join(k.obj for k in kids) + '}'
        dec = f'T.{s.t.name}{{' + ', '.join(k.dec for k in kids) + '}'
        return _hoist(Node(obj, words, f'S.Sequence{{{items(0)}}}', f'S.Container{{{names}, {chain(0)}}}', proof,
                    dec=dec, opads=[q for k in kids for q in k.opads]))
    raise Skip(t.kind + ' (array-backed; needs the array induction)' if t.kind == 'vector' else t.kind)


def tree(leaves):
    """The array of a buffer: a complete binary tree, as `Array.new` of the
    buffer's capacity depth builds it."""
    if len(leaves) == 1:
        return f'ALeaf{{{leaves[0]}}}'
    h = len(leaves) // 2
    return f'ANode{{{tree(leaves[:h])}, {tree(leaves[h:])}}}'


def okname(obj_src, n):
    head = f'def {n}_decode(buf: B.Buf, +size: U32)'
    i = obj_src.index(head)
    body = obj_src[i:obj_src.index('\n\n', i)]
    want = f'{n}_built(size, '
    j = body.index(want) + len(want)
    k = body.index('_ok(buf, 0, size)', j)
    return body[j:k]



def word_pat(a):
    return 'U32{' + ''.join(f'WCon{{{x}, ' for x in a) + 'WNil{}' + '}' * len(a) + '}'


def bits_module():
    """proofs/obj/spec_bits.bend: what the spec's bit packing makes of words.

    `bitsof(ws)` lists the 32 bits of every word, low bit first, by taking the
    word apart - the reading of spec/bit_packing.bend ("bit i has weight 2^i")
    applied to the little-endian bytes the object stores. The laws: its length,
    the 256-case identity between the spec's `octet` and the byte of a word,
    `pack(bitsof ws) == limbs(ws)` by induction on the words, and the bit-vector
    leaf: the spec's parts of `BitsValue{bitsof(ws)}` at `BitVector{n}` are one
    fixed part holding `limbs(ws)` whenever n is the bit count.
    """
    a = [f'a{i}' for i in range(32)]
    W = word_pat(a)
    F24 = ['False{}'] * 24
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/primitives.bend as I',
         'import ../../spec/bit_packing.bend as SB', 'import ../../spec/bitfields.bend as SBF',
         'import ../../spec/codec.bend as Codec', 'import ../../types/schema.bend as S',
         'import ../../proofs/compact/bits.bend as BT', 'import ../../proofs/bit_packing.bend as BPK', 'import ./spec_fixed.bend as F', '',
         '# GENERATED by codegen/spec_laws.py (bits_module). Do not edit.', '']
    w = L.append
    w('def bitsof(ws: +List<U32>) -> +List<Bool>:')
    w('  match ws:')
    w('    case Nil{}: []')
    w('    case Con{h, t}:')
    w('      match h:')
    w(f'        case {W}: ' + ' <> '.join(a) + ' <> bitsof(t)')
    w('')
    w('def bitlen(ws: +List<U32>) -> Nat:')
    w('  match ws:')
    w('    case Nil{}: 0n')
    w('    case Con{h, t}: ' + '1n+' * 32 + 'bitlen(t)')
    w('')
    w('law len_bits:')
    w('  for +ws: +List<U32>')
    w('  {List.length(&2, Bool, bitsof(ws)) == bitlen(ws) : Nat}')
    w('def len_bits(ws):')
    w('  match ws:')
    w('    case Nil{}: {==}')
    w('    case Con{h, t}:')
    w('      match h:')
    w(f'        case {W}: Equal.cong(Nat, Nat, k => ' + '1n+' * 32 + 'k, List.length(&2, Bool, bitsof(t)), bitlen(t), len_bits(t))')
    w('')
    b = [f'b{i}' for i in range(8)]
    w('law octet_word:')
    for x in b:
        w(f'  for +{x}: Bool')
    w('  {SB.octet(' + ', '.join(b) + ') == ' + word_pat(b + F24) + ' : U32}')
    w('def octet_word(' + ', '.join(b) + '):')
    w('  BPK.model_octet(' + ', '.join(b) + ')')  # proofs/bit_packing.bend, symbolic (was 256 evaluated cases)
    w('')
    for k in range(4):
        seg = a[8 * k:8 * k + 8]
        w(f'law byte{k}_octet:')
        for x in a:
            w(f'  for +{x}: Bool')
        w(f'  {{SB.octet({", ".join(seg)}) == B.byte_sel({k}, {W}) : U32}}')
        w(f'def byte{k}_octet({", ".join(a)}):')
        w(f'  Equal.trans(U32, SB.octet({", ".join(seg)}), {word_pat(seg + F24)}, B.byte_sel({k}, {W}),')
        w(f'    octet_word({", ".join(seg)}),')
        w(f'    Equal.sym(U32, B.byte_sel({k}, {W}), {word_pat(seg + F24)}, BT.sel{k}({", ".join(a)})))')
        w('')
    octs = [f'SB.octet({", ".join(a[8 * k:8 * k + 8])})' for k in range(4)]
    sels = [f'B.byte_sel({k}, {W})' for k in range(4)]
    rhs = f'List.append(&2, U32, I.limb({W}), F.limbs(t))'
    w('law pack_limbs:')
    w('  for +ws: +List<U32>')
    w('  {SB.pack(bitsof(ws)) == F.limbs(ws) : +List<U32>}')
    w('def pack_limbs(ws):')
    w('  match ws:')
    w('    case Nil{}: {==}')
    w('    case Con{h, t}:')
    w('      match h:')
    w(f'        case {W}:')
    for k in range(4):
        cur = sels[:k] + ['_'] + octs[k + 1:]
        w(f'          %Equal.sym(U32, {octs[k]}, {sels[k]}, byte{k}_octet({", ".join(a)})) :')
        w('            {' + ' <> '.join(cur) + f' <> SB.pack(bitsof(t)) == {rhs} : +List<U32>}}')
    w(f'          Equal.cong(+List<U32>, +List<U32>, r => ' + ' <> '.join(sels) + ' <> r, SB.pack(bitsof(t)), F.limbs(t), pack_limbs(t))')
    w('')
    goal = 'Some{[S.Fixed{F.limbs(ws)}]} : Maybe<&2, +List<S.Part>>'
    w('law bits_part:')
    w('  for +ws: +List<U32>')
    w('  for +n: Nat')
    w('  for fit: {Nat.is_eq(bitlen(ws), n) == True{} : Bool}')
    w('  for pos: {Nat.is_lt(0n, n) == True{} : Bool}')
    w(f'  {{Codec.parts(S.BitsValue{{bitsof(ws)}}, S.BitVector{{n}}) == {goal}}}')
    w('def bits_part(ws, n, fit, pos):')
    width = 'Some{Nat.div(Nat.add(n, 7n), 8n)}'
    w('  %Equal.sym(Nat, List.length(&2, Bool, bitsof(ws)), bitlen(ws), len_bits(ws)) :')
    w(f'    {{Codec.one(SBF.encoding(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(_, n)), bitsof(ws)), {width}) == {goal}}}')
    w('  %Equal.sym(Bool, Nat.is_eq(bitlen(ws), n), True{}, fit) :')
    w(f'    {{Codec.one(SBF.encoding(Bool.and(Nat.is_lt(0n, n), _), bitsof(ws)), {width}) == {goal}}}')
    w('  %Equal.sym(Bool, Nat.is_lt(0n, n), True{}, pos) :')
    w(f'    {{Codec.one(SBF.encoding(Bool.and(_, True{{}}), bitsof(ws)), {width}) == {goal}}}')
    w('  %Equal.sym(+List<U32>, SB.pack(bitsof(ws)), F.limbs(ws), pack_limbs(ws)) :')
    w(f'    {{Codec.one(Some{{_}}, {width}) == {goal}}}')
    w('  {==}')
    return '\n'.join(L) + '\n'


VALUES = ['BooleanValue{b}', 'UnsignedValue{u}', 'BytesValue{xs}', 'BitsValue{bs}', 'Sequence{it}',
          'Items{hd, tl}', 'EmptyItems{}', 'Selected{sel, sv}', 'NullValue{}']


def small_module(src):
    """proofs/obj/spec_small.bend: the one-byte names.

    uint8, ParticipationFlags (uint8) and Bytes1 hold one byte, boolean one of
    two. A VALID object is one of 256 (2) byte values, so the encoder laws are
    stated over the eight bits of that byte and proved by exhaustive cases. The
    decoder laws are stated over an ARBITRARY buffer word w (all 32 bits free)
    and moved to the byte's bits with bits.bend `sel0` and found.bend
    `logic__subst`, so they cover every buffer of the size.
    """
    a = [f'a{i}' for i in range(32)]
    b = [f'b{i}' for i in range(8)]
    W = word_pat(a)
    X = word_pat(b + ['False{}'] * 24)
    LOWA = word_pat(a[:8] + ['False{}'] * 24)
    bsig = ', '.join(f'+{x}: Bool' for x in b)
    bargs = ', '.join(b)
    cases = [' '.join('True{}' if m >> i & 1 else 'False{}' for i in range(8)) for m in range(256)]
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
         'import ../../types/primitive.bend as P', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../../proofs/compact/bits.bend as BT', 'import ../../proofs/compact/found.bend as FD',
         'import ../../proofs/word_facts.bend as WF', 'import ../../spec/primitives.bend as SP',
         'import ../../proofs/integer_encoding.bend as IE', 'import ./spec_fixed.bend as SF', '',
         '# GENERATED by codegen/spec_laws.py (small_module). Do not edit.', '']
    w = L.append
    # the one-byte unsigned encoding, symbolically in the byte's eight bits: the
    # implementation's serializer (IE.uint_serialize_correct) reduces on them, and
    # its low byte U32.and(x, 255) is x bit by bit (no case split over 256 bytes)
    Xpos = lambda i: word_pat([(f'b{j}' if j < i else ('_' if j == i else f'Bool.and(b{j}, True{{}})')) for j in range(8)] + ['Bool.and(False{}, False{})'] * 24)
    w(f'def byte_and({bsig}) -> {{U32.and({X}, 255) == {X} : U32}}:')
    for i in range(8):
        w(f'  %Equal.sym(Bool, Bool.and(b{i}, True{{}}), b{i}, FD.u32__and_true(b{i})) :')
        w(f'    {{{Xpos(i)} == {X} : U32}}')
    w('  {==}')
    w('')
    UV = f'S.UnsignedValue{{P.UInt{{{X}, 0, 0, 0, 0, 0, 0, 0}}}}'
    w(f'def u8_parts({bsig}) -> {{Codec.parts({UV}, S.Unsigned{{P.U8{{}}}}) == Some{{[S.Fixed{{[{X}]}}]}} : Maybe<&2, +List<S.Part>>}}:')
    w(f'  %IE.uint_serialize_correct(P.U8{{}}, P.UInt{{{X}, 0, 0, 0, 0, 0, 0, 0}}) :')
    w(f'    {{Codec.one(_, Some{{SP.byte_width(P.U8{{}})}}) == Some{{[S.Fixed{{[{X}]}}]}} : Maybe<&2, +List<S.Part>>}}')
    w(f'  %Equal.sym(U32, U32.and({X}, 255), {X}, byte_and({bargs})) :')
    w(f'    {{Codec.one(Some{{[_]}}, Some{{1n}}) == Some{{[S.Fixed{{[{X}]}}]}} : Maybe<&2, +List<S.Part>>}}')
    w('  {==}')
    w('')

    def all_cases(indent='  '):
        w(f'{indent}match {" ".join(b)}:')
        for c in cases:
            w(f'{indent}  case {c}: {{==}}')

    def buf(x):
        return f'B.Buf{{ALeaf{{{x}}}, 1}}'

    for n, obj, val in [('uint8', X, f'S.UnsignedValue{{P.UInt{{{X}, 0, 0, 0, 0, 0, 0, 0}}}}'),
                        ('ParticipationFlags', X, f'S.UnsignedValue{{P.UInt{{{X}, 0, 0, 0, 0, 0, 0, 0}}}}'),
                        ('Bytes1', f'T.Bytes1{{{X}}}', f'S.BytesValue{{[{X}]}}')]:
        R = 'T.Bytes1' if n == 'Bytes1' else 'U32'
        w(f'# ---- {n} (1 byte) ----')
        w(f'def {n}_spec_bytes({bsig})')
        w(f'    -> {{B.emit(T.{n}_encode({obj}), 0, 1) == (T.{n}_encode({obj}), [{X}]) : B.Buf & +List<U32>}}:')
        all_cases()
        w(f'def {n}_spec_encode({bsig})')
        w(f'    -> Decoding.decodes(Spec.{n}(), [{X}], {val}):')
        if n == 'Bytes1':
            all_cases()
        else:
            w(f'  SF.encoding_of_parts(Spec.{n}(), {val}, [{X}], u8_parts({bargs}))')
        dobj = 'T.Bytes1{B.byte_sel(0, w)}' if n == 'Bytes1' else 'B.byte_sel(0, w)'
        w(f'def {n}_spec_decode(+w: U32)')
        w(f'    -> {{T.{n}_decode({buf("w")}, 1) == ({buf("w")}, Some{{{dobj}}}) : B.Buf & Maybe<&1, {R}>}}:')
        w('  {==}')
        w(f'def {n}_spec_view(+w: U32)')
        w(f'    -> {{B.emit({buf("w")}, 0, 1) == ({buf("w")}, [B.byte_sel(0, w)]) : B.Buf & +List<U32>}}:')
        w('  {==}')
        pv = val.replace(X, 'x')
        w(f'def {n}_spec_value(+w: U32)')
        w(f'    -> Decoding.decodes(Spec.{n}(), [B.byte_sel(0, w)], {pv.replace("x", "B.byte_sel(0, w)")}):')
        w('  match w:')
        w(f'    case {W}:')
        w(f'      FD.logic__subst(U32, x => Decoding.decodes(Spec.{n}(), [x], {pv}), {LOWA}, B.byte_sel(0, {W}),')
        w(f'        Equal.sym(U32, B.byte_sel(0, {W}), {LOWA}, BT.sel0({", ".join(a)})),')
        w(f'        {n}_spec_encode({", ".join(a[:8])}))')
        w('')

    # boolean
    w('# ---- boolean (1 byte) ----')
    for bv, byte in [('True', 1), ('False', 0)]:
        w(f'def boolean_{bv.lower()}_spec_bytes()')
        w(f'    -> {{B.emit(T.boolean_encode({bv}{{}}), 0, 1) == (T.boolean_encode({bv}{{}}), [{byte}]) : B.Buf & +List<U32>}}:')
        w('  {==}')
        w(f'def boolean_{bv.lower()}_spec_encode()')
        w(f'    -> Decoding.decodes(Spec.boolean(), [{byte}], S.BooleanValue{{{bv}{{}}}}):')
        w('  {==}')
    w('')
    BUF = buf('w')
    R = 'B.Buf & Maybe<&1, Bool>'
    w('def boolean_spec_view(+w: U32)')
    w(f'    -> {{B.emit({BUF}, 0, 1) == ({BUF}, [B.byte_sel(0, w)]) : B.Buf & +List<U32>}}:')
    w('  {==}')
    for c, got in [(0, 'False{}'), (1, 'True{}')]:
        w(f'def boolean_spec_decode_{c}(+w: U32, +h: {{B.byte_sel(0, w) == {c} : U32}})')
        w(f'    -> {{T.boolean_decode({BUF}, 1) == ({BUF}, Some{{{got}}}) : {R}}}:')
        w(f'  %Equal.sym(U32, B.byte_sel(0, w), {c}, h) : {{T.boolean_built(1, ({BUF}, U32.is_le(_, 1))) == ({BUF}, Some{{{got}}}) : {R}}}')
        w(f'  %Equal.sym(U32, B.byte_sel(0, w), {c}, h) : {{({BUF}, Some{{U32.is_eq(_, 1)}}) == ({BUF}, Some{{{got}}}) : {R}}}')
        w('  {==}')
    w(f'def boolean_spec_decode_reject(+w: U32, +h: {{U32.is_le(B.byte_sel(0, w), 1) == False{{}} : Bool}})')
    w(f'    -> {{T.boolean_decode({BUF}, 1) == ({BUF}, None{{}}) : {R}}}:')
    w(f'  %Equal.sym(Bool, U32.is_le(B.byte_sel(0, w), 1), False{{}}, h) : {{T.boolean_built(1, ({BUF}, _)) == ({BUF}, None{{}}) : {R}}}')
    w('  {==}')
    w('')
    w('# Rejection is exactly the complement of the spec image: a byte above 1 is')
    w('# the encoding of no value (spec/codec.bend encodes booleans as [0] or [1]).')
    w('def head_or(m: Maybe<&2, +List<U32>>, +d: U32) -> U32:')
    w('  match m:')
    w('    case Some{Con{x, t}}: x')
    w('    case _: d')
    w('def is_some2(m: Maybe<&2, +List<U32>>) -> Bool:')
    w('  match m:')
    w('    case None{}: False{}')
    w('    case Some{x}: True{}')
    w('def not_image(+c: U32, +h: {U32.is_le(c, 1) == False{} : Bool}, +k: U32, +hk: {U32.is_le(k, 1) == True{} : Bool},')
    w('    e: {Some{[k]} == Some{[c]} : Maybe<&2, +List<U32>>}) -> Empty:')
    w('  WF.false_true(Equal.trans(Bool, False{}, U32.is_le(c, 1), True{}, Equal.sym(Bool, U32.is_le(c, 1), False{}, h),')
    w('    %Equal.cong(Maybe<&2, +List<U32>>, U32, m => head_or(m, k), Some{[k]}, Some{[c]}, e) : {U32.is_le(_, 1) == True{} : Bool}')
    w('    hk))')
    w('def none_image(+c: U32, e: {None{} == Some{[c]} : Maybe<&2, +List<U32>>}) -> Empty:')
    w('  WF.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, m => is_some2(m), None{}, Some{[c]}, e))')
    w('def boolean_outside_v(+c: U32, +h: {U32.is_le(c, 1) == False{} : Bool}, +v: S.Value, e: Decoding.decodes(Spec.boolean(), [c], v)) -> Empty:')
    w('  match v:')
    w('    case S.BooleanValue{+bv}:')
    w('      match bv:')
    w('        case True{}: not_image(c, h, 1, {==}, e)')
    w('        case False{}: not_image(c, h, 0, {==}, e)')
    for vc in VALUES[1:]:
        w(f'    case S.{vc}: none_image(c, e)')
    w('def boolean_outside(+c: U32, +h: {U32.is_le(c, 1) == False{} : Bool}) -> Decoding.outside_image(Spec.boolean(), [c]):')
    w('  v => e => boolean_outside_v(c, h, v, e)')
    w('def boolean_spec_reject_outside(+w: U32, +h: {U32.is_le(B.byte_sel(0, w), 1) == False{} : Bool})')
    w('    -> Decoding.outside_image(Spec.boolean(), [B.byte_sel(0, w)]):')
    w('  boolean_outside(B.byte_sel(0, w), h)')
    w('')
    w('# ---- every other size is refused ----')
    for n, R in [('uint8', 'U32'), ('ParticipationFlags', 'U32'), ('Bytes1', 'T.Bytes1'), ('boolean', 'Bool')]:
        P = okname(src, n)
        w(f'def {n}_spec_reject(buf: B.Buf, +m: U32, e: {{U32.is_eq(m, 1) == False{{}} : Bool}})')
        w(f'    -> {{T.{n}_decode(buf, m) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}:')
        w(f'  %Equal.sym(Bool, U32.is_eq(m, 1), False{{}}, e) : '
          f'{{T.{n}_built(m, T.{P}_ok_len(_, buf, 0)) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}')
        w('  {==}')
    return '\n'.join(L) + '\n'


def unique_small():
    """Completeness of the one-byte decoders' answers (decode_unique.valid_unique: decode_complete.image_unique = END_TO_END.deserialize_unique)."""
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../types/schema.bend as S',
         'import ../../types/primitive.bend as P', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../decode_unique.bend as E',
         'import ../../proofs/compact/found.bend as FD',
         'import ./spec_small.bend as SM', '',
         '# GENERATED by codegen/spec_laws.py (unique_small). Do not edit.', '']
    w = L.append
    for n in ['uint8', 'ParticipationFlags', 'Bytes1']:
        val = ('S.BytesValue{[B.byte_sel(0, w)]}' if n == 'Bytes1'
               else 'S.UnsignedValue{P.UInt{B.byte_sel(0, w), 0, 0, 0, 0, 0, 0, 0}}')
        w(f'def {n}_spec_unique(+w: U32, +v: S.Value, spec: Decoding.decodes(Spec.{n}(), [B.byte_sel(0, w)], v))')
        w(f'    -> {{v == {val} : S.Value}}:')
        w(f'  E.valid_unique(Spec.{n}(), [B.byte_sel(0, w)], v, {val}, {{==}}, spec, SM.{n}_spec_value(w))')
    for c, got, law in [(0, 'False{}', 'false'), (1, 'True{}', 'true')]:
        w(f'def boolean_spec_unique_{c}(+w: U32, +h: {{B.byte_sel(0, w) == {c} : U32}}, +v: S.Value,')
        w(f'    spec: Decoding.decodes(Spec.boolean(), [B.byte_sel(0, w)], v)) -> {{v == S.BooleanValue{{{got}}} : S.Value}}:')
        w(f'  E.valid_unique(Spec.boolean(), [B.byte_sel(0, w)], v, S.BooleanValue{{{got}}}, {{==}}, spec,')
        w(f'    FD.logic__subst(U32, x => Decoding.decodes(Spec.boolean(), [x], S.BooleanValue{{{got}}}), {c}, B.byte_sel(0, w),')
        w(f'      Equal.sym(U32, B.byte_sel(0, w), {c}, h), SM.boolean_{law}_spec_encode()))')
    return '\n'.join(L) + '\n'


def validator_module(src):
    """proofs/obj/spec_rec_Validator.bend: Validator, a boolean inside an unaligned
    record (pubkey 48, withdrawal_credentials 32, effective_balance 8 bytes, then
    `slashed` at byte 88, then four uint64 at bytes 89, 97, 105, 113).

    Checked here: the spec side (the spec's parts of the value of any words and
    boolean are the bytes limbs(words 0..21) ++ [boolean] ++ limbs(epochs), the
    canonical encoding, and uniqueness), the decoder's rejections (every other
    size; byte 88 above 1), and its acceptance: a buffer of 121 bytes whose byte
    88 is at most 1 decodes to the object of words 0..21, that boolean and the
    epochs read across words 22..30 (`B.join_sel`), and the spec relates exactly
    the buffer's bytes to that object's value (Validator_spec_decoded: bit lemmas
    of proofs/compact/bits.bend for the joined words, U32.to_nat for the boolean).
    The encoder's bytes (Validator_spec_bytes): the encoder writes the epochs
    with `U32.mul(w, 256)` and `U32.or`; U32.mul recurses over its left operand's
    bits, so it does not reduce for a symbolic word, and proofs/obj/word_mul.bend
    (from codegen/word_mul.bend.in) proves `U32.mul(w, 256) == U32.shln(w, 8n)`
    for every w; the bytes of the shifted words then follow from bits.bend.
    """
    xs = [f'x{i}' for i in range(22)]
    es = [f'e{i}' for i in range(8)]
    ebits = [[f'e{i}_{k}' for k in range(32)] for i in range(8)]
    E = [word_pat(b) for b in ebits]
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
         'import ../../types/primitive.bend as P', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/primitives.bend as SP', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../../spec/schema.bend as SSC', 'import ./spec_fixed.bend as F',
         'import ./arr_spec.bend as AS', 'import ../../proofs/compact/found.bend as FD', 'import ../../proofs/compact/bits.bend as BT', 'import ../../src/primitives.bend as I', 'import ./word_mul.bend as WM', '', '# GENERATED by codegen/spec_laws.py (validator_module). Do not edit.', '']
    w = L.append

    def obj(ws, b, ep):
        return (f'T.Validator{{T.Bytes48{{{", ".join(ws[:12])}}}, T.Bytes32{{{", ".join(ws[12:20])}}}, O.U64{{{ws[20]}, {ws[21]}}}, {b}, '
                + ', '.join(f'O.U64{{{ep[2 * j]}, {ep[2 * j + 1]}}}' for j in range(4)) + '}')

    def byts(ws, b, ep):
        return f'List.append(&2, U32, F.limbs({wl(ws)}), List.append(&2, U32, SP.boolean_encoding({b}), F.limbs({wl(ep)})))'

    def val(ws, b, ep):
        items = [f'S.BytesValue{{F.limbs({wl(ws[:12])})}}', f'S.BytesValue{{F.limbs({wl(ws[12:20])})}}',
                 f'S.UnsignedValue{{P.UInt{{{ws[20]}, {ws[21]}, 0, 0, 0, 0, 0, 0}}}}', f'S.BooleanValue{{{b}}}'] + \
                [f'S.UnsignedValue{{P.UInt{{{ep[2 * j]}, {ep[2 * j + 1]}, 0, 0, 0, 0, 0, 0}}}}' for j in range(4)]
        out = 'S.EmptyItems{}'
        for it in reversed(items):
            out = f'S.Items{{{it}, {out}}}'
        return f'S.Sequence{{{out}}}'
    split = ['  match b:', '    case True{}: {==}', '    case False{}: {==}']
    names_ = '["pubkey", "withdrawal_credentials", "effective_balance", "slashed", "activation_eligibility_epoch", "activation_epoch", "exit_epoch", "withdrawable_epoch"]'
    chain_ = 'S.End{}'
    for sch_ in reversed(['S.ByteVector{48n}', 'S.ByteVector{32n}', 'S.Unsigned{P.U64{}}', 'S.Boolean{}'] + ['S.Unsigned{P.U64{}}'] * 4):
        chain_ = f'S.Chain{{{sch_}, {chain_}}}'
    if VLCT:
        w('# the schema as its container term (a rewrite on schemas: no parts are compared)')
        w(f'def vsq() -> {{S.Container{{{names_}, {chain_}}} == Spec.Validator() : S.Schema}}: {{==}}')
        w('# a container\'s parts, one step, over an opaque value (the rewrite below compares no parts)')
        w('def lct(+it: S.Value, +nm: +List<String>, +fs: S.Schema) -> {Codec.aggregate(Codec.parts(it, fs), SSC.fixed_size(fs)) == Codec.parts(S.Sequence{it}, S.Container{nm, fs}) : Maybe<&2, +List<S.Part>>}:')
        w('  {==}')
        w('')
    # spec parts, over free words
    xsig = ', '.join(f'+{x}: U32' for x in xs)
    esig = ', '.join(f'+{e}: U32' for e in es)
    V = val(xs, 'b', es)
    BY = byts(xs, 'b', es)
    wa = f'[{wl(xs[:12])}, {wl(xs[12:20])}, {wl(xs[20:22])}]'
    wb = '[' + ', '.join(wl(es[2 * j:2 * j + 2]) for j in range(4)) + ']'
    names = '["pubkey", "withdrawal_credentials", "effective_balance", "slashed", "activation_eligibility_epoch", "activation_epoch", "exit_epoch", "withdrawable_epoch"]'
    schs = ['S.ByteVector{48n}', 'S.ByteVector{32n}', 'S.Unsigned{P.U64{}}', 'S.Boolean{}'] + ['S.Unsigned{P.U64{}}'] * 4
    chain = 'S.End{}'
    for sch in reversed(schs):
        chain = f'S.Chain{{{sch}, {chain}}}'
    for bv in ['True', 'False']:
        vb = val(xs, f'{bv}{{}}', es)
        items_list = []
        # the value's items and their proofs, in order
        itv = [f'S.BytesValue{{F.limbs({wl(xs[:12])})}}', f'S.BytesValue{{F.limbs({wl(xs[12:20])})}}',
               f'S.UnsignedValue{{P.UInt{{x20, x21, 0, 0, 0, 0, 0, 0}}}}', f'S.BooleanValue{{{bv}{{}}}}'] + \
              [f'S.UnsignedValue{{P.UInt{{{es[2 * j]}, {es[2 * j + 1]}, 0, 0, 0, 0, 0, 0}}}}' for j in range(4)]
        parts = [f'F.limbs({wl(xs[:12])})', f'F.limbs({wl(xs[12:20])})', f'F.limbs({wl(xs[20:22])})', f'SP.boolean_encoding({bv}{{}})'] + \
                [f'F.limbs({wl(es[2 * j:2 * j + 2])})' for j in range(4)]
        prf = [f'F.bytes_part(x0, {wl(xs[1:12])}, {{==}})', f'F.bytes_part(x12, {wl(xs[13:20])}, {{==}})', 'F.uint64_part(x20, x21)', '{==}'] + \
              [f'F.uint64_part({es[2 * j]}, {es[2 * j + 1]})' for j in range(4)]

        def items(i):
            return 'S.EmptyItems{}' if i == 8 else f'S.Items{{{itv[i]}, {items(i + 1)}}}'

        def ch(i):
            return 'S.End{}' if i == 8 else f'S.Chain{{{schs[i]}, {ch(i + 1)}}}'

        def cat(i):
            if i == 8:
                return '{==}'
            rest = '[' + ', '.join(f'S.Fixed{{{q}}}' for q in parts[i + 1:]) + ']'
            if VLCT:
                return f'F.items_fixed({itv[i]}, {items(i + 1)}, {schs[i]}, {ch(i + 1)}, {parts[i]}, {rest}, {prf[i]}, {cat(i + 1)})'
            return (f'F.cat_fixed(Codec.parts({itv[i]}, {schs[i]}), {parts[i]}, Codec.parts({items(i + 1)}, {ch(i + 1)}), {rest}, {prf[i]}, {cat(i + 1)})')
        bsv = f'[{1 if bv == "True" else 0}]'
        w(f'def Validator_parts_{bv.lower()}({xsig}, {esig})')
        w(f'    -> {{Codec.parts({vb}, Spec.Validator()) == Some{{[S.Fixed{{{byts(xs, bv + "{}", es)}}}]}} : Maybe<&2, +List<S.Part>>}}:')
        allp = '[' + ', '.join(f'S.Fixed{{{q}}}' for q in parts) + ']'
        if VLCT:
            w(f'  %vsq() : {{Codec.parts({vb}, _) == Some{{[S.Fixed{{{byts(xs, bv + "{}", es)}}}]}} : Maybe<&2, +List<S.Part>>}}')
            w(f'  %lct({items(0)}, {names}, {ch(0)}) : {{_ == Some{{[S.Fixed{{{byts(xs, bv + "{}", es)}}}]}} : Maybe<&2, +List<S.Part>>}}')
        w(f'  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts({items(0)}, {ch(0)}), Some{{{allp}}}, {cat(0)}) :')
        w(f'    {{Codec.aggregate(_, SSC.fixed_size({ch(0)})) == Some{{[S.Fixed{{{byts(xs, bv + "{}", es)}}}]}} : Maybe<&2, +List<S.Part>>}}')
        w(f'  AS.agg_m({wa}, {bsv}, {wb}, 121n, 121n, {{==}}, {{==}}, {{==}})')
        w('')
    w('# the spec\'s parts of the value of the words and the boolean: one fixed part, those bytes')
    w(f'def Validator_spec_parts({xsig}, +b: Bool, {esig})')
    w(f'    -> {{Codec.parts({V}, Spec.Validator()) == Some{{[S.Fixed{{{BY}}}]}} : Maybe<&2, +List<S.Part>>}}:')
    w('  match b:')
    w(f'    case True{{}}: Validator_parts_true({", ".join(xs + es)})')
    w(f'    case False{{}}: Validator_parts_false({", ".join(xs + es)})')
    w('')
    w('# encoder soundness against spec/codec.bend')
    w(f'def Validator_spec_encode({xsig}, +b: Bool, {esig})')
    w(f'    -> Decoding.decodes(Spec.Validator(), {BY}, {V}):')
    w(f'  F.encoding_of_parts(Spec.Validator(), {V}, {BY}, Validator_spec_parts({", ".join(xs)}, b, {", ".join(es)}))')
    w('')
    # a buffer whose byte 88 is above 1 (any words): refused
    ws = [f'w{i}' for i in range(32)]
    bufc = f'B.Buf{{{tree(ws)}, 121}}'
    wsig = ', '.join(f'+{x}: U32' for x in ws)
    w('# a buffer whose byte 88 (the boolean) is above 1 is refused, whatever its other bytes')
    w(f'def Validator_spec_reject_bool({wsig}, +h: {{U32.is_le(B.byte_sel(0, w22), 1) == False{{}} : Bool}})')
    w(f'    -> {{T.Validator_decode({bufc}, 121) == ({bufc}, None{{}}) : B.Buf & Maybe<&1, T.Validator>}}:')
    w(f'  %Equal.sym(Bool, U32.is_le(B.byte_sel(0, w22), 1), False{{}}, h) : {{T.Validator_built(121, T.Validator_c0(_, {bufc}, 0)) == ({bufc}, None{{}}) : B.Buf & Maybe<&1, T.Validator>}}')
    w('  {==}')
    w('')
    # ---- the decoder's acceptance, and the spec value of what it returns ----
    A_ = [f'a{i}' for i in range(32)]
    B_ = [f'b{i}' for i in range(32)]
    WA, WB = word_pat(A_), word_pat(B_)
    Cb = A_[8:] + B_[:8]
    for k in range(4):
        rk = f'B.byte_sel({k + 1}, lo)' if k < 3 else 'B.byte_sel(0, hi)'
        rkp = rk.replace('lo', WA).replace('hi', WB)
        SEL = word_pat(Cb[8 * k:8 * k + 8] + ['False{}'] * 24)
        other = f'BT.sel{k + 1}({", ".join(A_)})' if k < 3 else f'BT.sel0({", ".join(B_)})'
        w(f'# byte {k} of the word an unaligned read at offset 1 joins')
        w(f'def Validator_jb{k}(+lo: U32, +hi: U32) -> {{B.byte_sel({k}, B.join_sel(1, lo, hi)) == {rk} : U32}}:')
        w('  match lo hi:')
        w(f'    case {WA} {WB}:')
        w(f'      %Equal.sym(U32, B.join_sel(1, {WA}, {WB}), {word_pat(Cb)}, BT.join1({", ".join(A_ + B_)})) :')
        w(f'        {{B.byte_sel({k}, _) == {rkp} : U32}}')
        w(f'      Equal.trans(U32, B.byte_sel({k}, {word_pat(Cb)}), {SEL}, {rkp}, BT.sel{k}({", ".join(Cb)}), Equal.sym(U32, {rkp}, {SEL}, {other}))')
        w('')
    J = lambda lo, hi: f'B.join_sel(1, {lo}, {hi})'
    w('# the limbs of a joined word: bytes 1..3 of lo, byte 0 of hi')
    w(f'def Validator_lj(+lo: U32, +hi: U32, +rest: +List<U32>)')
    RLJ = 'Con{B.byte_sel(1, lo), Con{B.byte_sel(2, lo), Con{B.byte_sel(3, lo), Con{B.byte_sel(0, hi), F.limbs(rest)}}}}'
    w(f'    -> {{F.limbs(Con{{{J("lo", "hi")}, rest}}) == {RLJ} : +List<U32>}}:')
    cur = [f'B.byte_sel({k}, {J("lo", "hi")})' for k in range(4)]
    tgt = ['B.byte_sel(1, lo)', 'B.byte_sel(2, lo)', 'B.byte_sel(3, lo)', 'B.byte_sel(0, hi)']
    for k in range(4):
        ctx = [tgt[i] if i < k else cur[i] for i in range(4)]
        ctx[k] = '_'
        w(f'  %Equal.sym(U32, {cur[k]}, {tgt[k]}, Validator_jb{k}(lo, hi)) :')
        w(f'    {{Con{{{ctx[0]}, Con{{{ctx[1]}, Con{{{ctx[2]}, Con{{{ctx[3]}, F.limbs(rest)}}}}}}}} == {RLJ} : +List<U32>}}')
    w('  {==}')
    w('')
    w('# a word the decoder accepts as a boolean (at most 1) is the byte of that boolean')
    w('def Validator_bb_go(+x: U32, +n: Nat, +en: {U32.to_nat(x) == n : Nat}, +h: {Cmp.is_le(Nat.cmp(n, 1n)) == True{} : Bool})')
    w('    -> {SP.boolean_encoding(U32.is_eq(x, 1)) == [x] : +List<U32>}:')
    w('  match n:')
    w('    case 0n: FD.logic__subst(U32, z => {SP.boolean_encoding(U32.is_eq(z, 1)) == [z] : +List<U32>}, 0, x, Equal.sym(U32, x, 0, FD.u32__injective(x, 0, en)), {==})')
    w('    case 1n: FD.logic__subst(U32, z => {SP.boolean_encoding(U32.is_eq(z, 1)) == [z] : +List<U32>}, 1, x, Equal.sym(U32, x, 1, FD.u32__injective(x, 1, en)), {==})')
    w('    case 2n+m: Empty.absurd({SP.boolean_encoding(U32.is_eq(x, 1)) == [x] : +List<U32>}, FD.logic__false_true(h))')
    w('')
    w('def Validator_bool_byte(+x: U32, +h: {U32.is_le(x, 1) == True{} : Bool}) -> {SP.boolean_encoding(U32.is_eq(x, 1)) == [x] : +List<U32>}:')
    w('  Validator_bb_go(x, U32.to_nat(x), {==}, FD.logic__subst(Cmp, c => {Cmp.is_le(c) == True{} : Bool}, U32.cmp(x, 1), Nat.cmp(U32.to_nat(x), 1n), FD.u32__u32_cmp(x, 1), h))')
    w('')
    ws = [f'w{i}' for i in range(32)]
    bufc = f'B.Buf{{{tree(ws)}, 121}}'
    wsig = ', '.join(f'+{x}: U32' for x in ws)
    hyp = '+h: {U32.is_le(B.byte_sel(0, w22), 1) == True{} : Bool}'
    bw = 'U32.is_eq(B.byte_sel(0, w22), 1)'
    JS = [J(f'w{i}', f'w{i + 1}') for i in range(22, 30)]
    OBJW = obj(ws[:22], bw, JS)
    RT = 'B.Buf & Maybe<&1, T.Validator>'
    w('# decoding a buffer of 121 bytes whose byte 88 is at most 1 accepts: the object of')
    w('# words 0..21, that boolean, and the four epochs read across words 22..30')
    w(f'def Validator_spec_decode({wsig}, {hyp})')
    w(f'    -> {{T.Validator_decode({bufc}, 121) == ({bufc}, Some{{{OBJW}}}) : {RT}}}:')
    w(f'  %Equal.sym(Bool, U32.is_le(B.byte_sel(0, w22), 1), True{{}}, h) : {{T.Validator_built(121, T.Validator_c0(_, {bufc}, 0)) == ({bufc}, Some{{{OBJW}}}) : {RT}}}')
    w('  {==}')
    w('')
    BYTESW = f'List.append(&2, U32, F.limbs([{", ".join(ws[:30])}]), [B.byte_sel(0, w30)])'
    w('# the bytes of that buffer')
    w(f'def Validator_spec_view({wsig})')
    w(f'    -> {{B.emit({bufc}, 0, 31) == ({bufc}, {BYTESW}) : B.Buf & +List<U32>}}:')
    w('  {==}')
    w('')
    VW = val(ws[:22], bw, JS)
    BYW = byts(ws[:22], bw, JS)
    XL = f'F.limbs([{", ".join(ws[:22])}])'
    # the equality of the spec bytes of the decoded value and the buffer's bytes
    eqs = []
    eqs.append((f'Equal.sym(+List<U32>, SP.boolean_encoding({bw}), [B.byte_sel(0, w22)], Validator_bool_byte(B.byte_sel(0, w22), h))',
                f'List.append(&2, U32, {XL}, List.append(&2, U32, _, F.limbs([{", ".join(JS)}])))'))
    done = []
    for i in range(22, 30):
        rest = '[' + ', '.join(JS[i - 21:]) + ']'
        new = f'Con{{B.byte_sel(1, w{i}), Con{{B.byte_sel(2, w{i}), Con{{B.byte_sel(3, w{i}), Con{{B.byte_sel(0, w{i + 1}), F.limbs({rest})}}}}}}}}'
        old = f'F.limbs([{", ".join(JS[i - 22:])}])'
        pre = 'Con{B.byte_sel(0, w22), ' + ''.join(f'Con{{{x}, ' for x in done) + '_' + '}' * (len(done) + 1)
        eqs.append((f'Equal.sym(+List<U32>, {old}, {new}, Validator_lj(w{i}, w{i + 1}, {rest}))', f'List.append(&2, U32, {XL}, {pre})'))
        done += [f'B.byte_sel(1, w{i})', f'B.byte_sel(2, w{i})', f'B.byte_sel(3, w{i})', f'B.byte_sel(0, w{i + 1})']
    w(f'def Validator_bytes_eq({wsig}, {hyp}) -> {{{BYW} == {BYTESW} : +List<U32>}}:')
    for e, ctx in eqs:
        w(f'  %{e} :')
        w(f'    {{{ctx} == {BYTESW} : +List<U32>}}')
    w('  {==}')
    w('')
    w('# the spec relates exactly those bytes to the value of the object the decoder returns')
    w(f'def Validator_spec_decoded({wsig}, {hyp})')
    w(f'    -> Decoding.decodes(Spec.Validator(), {BYTESW}, {VW}):')
    w(f'  +eq = Validator_bytes_eq({", ".join(ws)}, h)')
    w(f'  FD.logic__subst(+List<U32>, z => Decoding.decodes(Spec.Validator(), z, {VW}), {BYW}, {BYTESW}, eq,')
    w(f'    Validator_spec_encode({", ".join(ws[:22])}, {bw}, {", ".join(JS)}))')
    w('')
    # ---- the encoder's bytes ----
    C_ = [f'c{i}' for i in range(32)]
    FF = ['False{}']
    bs = lambda k, x: f'B.byte_sel({k}, {x})'
    selw = lambda k, bits: f'BT.sel{k}({", ".join(bits)})'
    w('# the limb of a word from its four bytes')
    w('def Validator_limb4(+x: U32, +y0: U32, +y1: U32, +y2: U32, +y3: U32, +e0: {B.byte_sel(0, x) == y0 : U32}, +e1: {B.byte_sel(1, x) == y1 : U32},')
    w('    +e2: {B.byte_sel(2, x) == y2 : U32}, +e3: {B.byte_sel(3, x) == y3 : U32}) -> {I.limb(x) == [y0, y1, y2, y3] : +List<U32>}:')
    cur = [bs(k, 'x') for k in range(4)]
    for k in range(4):
        ctx = [f'y{i}' if i < k else cur[i] for i in range(4)]
        ctx[k] = '_'
        w(f'  %Equal.sym(U32, {cur[k]}, y{k}, e{k}) : {{[{", ".join(ctx)}] == [y0, y1, y2, y3] : +List<U32>}}')
    w('  {==}')
    w('')
    EA = word_pat(A_)
    for c in (1, 0):
        wb = (['True{}'] if c else ['False{}']) + FF * 7 + A_[:24]
        W = f'U32.or({c}, U32.shln({EA}, 8n))'
        w(f'# the word of the boolean byte {c} and the low three bytes of an epoch word')
        w(f'def Validator_wa{c}(+e: U32) -> {{I.limb(U32.or({c}, U32.mul(e, 256))) == [{c}, {bs(0, "e")}, {bs(1, "e")}, {bs(2, "e")}] : +List<U32>}}:')
        w('  match e:')
        w(f'    case {EA}:')
        w(f'      %Equal.sym(U32, U32.mul({EA}, 256), U32.shln({EA}, 8n), WM.mul256({EA})) :')
        w(f'        {{I.limb(U32.or({c}, _)) == [{c}, {bs(0, EA)}, {bs(1, EA)}, {bs(2, EA)}] : +List<U32>}}')
        es_ = [f'Equal.trans(U32, {bs(k + 1, W)}, {word_pat(A_[8 * k:8 * k + 8] + FF * 24)}, {bs(k, EA)}, {selw(k + 1, wb)}, Equal.sym(U32, {bs(k, EA)}, {word_pat(A_[8 * k:8 * k + 8] + FF * 24)}, {selw(k, A_)}))' for k in range(3)]
        w(f'      Validator_limb4({W}, {c}, {bs(0, EA)}, {bs(1, EA)}, {bs(2, EA)}, {selw(0, wb)}, {", ".join(es_)})')
        w('')
    EC = word_pat(C_)
    orb = [f'Bool.or({x}, False{{}})' for x in C_[24:]]
    wb = orb + A_[:24]
    W = f'U32.or(U32.or(0, U32.shrn({EC}, 24n)), U32.shln({EA}, 8n))'
    top = word_pat(C_[24:] + FF * 24)
    w('# the word of the top byte of one epoch word and the low three bytes of the next')
    w(f'def Validator_wb(+d: U32, +e: U32) -> {{I.limb(U32.or(U32.or(0, U32.shrn(d, 24n)), U32.mul(e, 256))) == [{bs(3, "d")}, {bs(0, "e")}, {bs(1, "e")}, {bs(2, "e")}] : +List<U32>}}:')
    w('  match d e:')
    w(f'    case {EC} {EA}:')
    w(f'      %Equal.sym(U32, U32.mul({EA}, 256), U32.shln({EA}, 8n), WM.mul256({EA})) :')
    w(f'        {{I.limb(U32.or(U32.or(0, U32.shrn({EC}, 24n)), _)) == [{bs(3, EC)}, {bs(0, EA)}, {bs(1, EA)}, {bs(2, EA)}] : +List<U32>}}')
    wq = f'BT.word32_eq({", ".join(orb + FF * 24)}, {", ".join(C_[24:] + FF * 24)}, {", ".join([f"BT.or_false({x})" for x in C_[24:]] + ["{==}"] * 24)})'
    e0 = (f'Equal.trans(U32, {bs(0, W)}, {word_pat(orb + FF * 24)}, {bs(3, EC)}, {selw(0, wb)}, '
          f'Equal.trans(U32, {word_pat(orb + FF * 24)}, {top}, {bs(3, EC)}, {wq}, Equal.sym(U32, {bs(3, EC)}, {top}, {selw(3, C_)})))')
    es_ = [f'Equal.trans(U32, {bs(k + 1, W)}, {word_pat(A_[8 * k:8 * k + 8] + FF * 24)}, {bs(k, EA)}, {selw(k + 1, wb)}, Equal.sym(U32, {bs(k, EA)}, {word_pat(A_[8 * k:8 * k + 8] + FF * 24)}, {selw(k, A_)}))' for k in range(3)]
    w(f'      Validator_limb4({W}, {bs(3, EC)}, {bs(0, EA)}, {bs(1, EA)}, {bs(2, EA)}, {e0}, {", ".join(es_)})')
    w('')
    w('# the last byte: the top byte of the last epoch word')
    w(f'def Validator_wc(+d: U32) -> {{{bs(0, "U32.or(0, U32.shrn(d, 24n))")} == {bs(3, "d")} : U32}}:')
    w('  match d:')
    w(f'    case {EC}: Equal.trans(U32, {bs(0, f"U32.or(0, U32.shrn({EC}, 24n))")}, {top}, {bs(3, EC)}, {selw(0, C_[24:] + FF * 24)}, Equal.sym(U32, {bs(3, EC)}, {top}, {selw(3, C_)}))')
    w('')
    esig = ', '.join(f'+{e}: U32' for e in es)
    w('# the encoder emits the spec bytes of the value of the words and the boolean')
    w(f'def Validator_spec_bytes({", ".join(f"+{x}: U32" for x in xs)}, +b: Bool, {esig})')
    OB = obj(xs, 'b', es)
    w(f'    -> {{B.emit(T.Validator_encode({OB}), 0, 31) == (T.Validator_encode({OB}), {byts(xs, "b", es)}) : B.Buf & +List<U32>}}:')
    w('  match b:')
    for bv, c in (('True', 1), ('False', 0)):
        OBc = obj(xs, bv + '{}', es)
        ENC = f'T.Validator_encode({OBc})'
        RHS = f'({ENC}, {byts(xs, bv + "{}", es)})'
        words = [f'U32.or({c}, U32.mul(e0, 256))'] + [f'U32.or(U32.or(0, U32.shrn(e{j - 1}, 24n)), U32.mul(e{j}, 256))' for j in range(1, 8)]
        lasts = f'B.byte_sel(0, U32.or(0, U32.shrn(e7, 24n)))'
        news = [f'[{c}, {bs(0, "e0")}, {bs(1, "e0")}, {bs(2, "e0")}]'] + [f'[{bs(3, f"e{j - 1}")}, {bs(0, f"e{j}")}, {bs(1, f"e{j}")}, {bs(2, f"e{j}")}]' for j in range(1, 8)]
        prfs = [f'Validator_wa{c}(e0)'] + [f'Validator_wb(e{j - 1}, e{j})' for j in range(1, 8)]
        def lst(parts, last):
            out = f'[{last}]'
            for p_ in reversed(parts):
                out = f'List.append(&2, U32, {p_}, {out})'
            return f'List.append(&2, U32, F.limbs([{", ".join(xs)}]), {out})'
        w(f'    case {bv}{{}}:')
        for j in range(8):
            parts = news[:j] + ['_'] + [f'I.limb({x})' for x in words[j + 1:]]
            w(f'      %Equal.sym(+List<U32>, I.limb({words[j]}), {news[j]}, {prfs[j]}) :')
            w(f'        {{({ENC}, {lst(parts, lasts)}) == {RHS} : B.Buf & +List<U32>}}')
        w(f'      %Equal.sym(U32, {lasts}, {bs(3, "e7")}, Validator_wc(e7)) :')
        w(f'        {{({ENC}, {lst(news, "_")}) == {RHS} : B.Buf & +List<U32>}}')
        w('      {==}')
    w('')
    w('# every size other than 121 is refused')
    P = okname(src, 'Validator')
    w('def Validator_spec_reject(buf: B.Buf, +m: U32, e: {U32.is_eq(m, 121) == False{} : Bool})')
    w('    -> {T.Validator_decode(buf, m) == (buf, None{}) : B.Buf & Maybe<&1, T.Validator>}:')
    w(f'  %Equal.sym(Bool, U32.is_eq(m, 121), False{{}}, e) : {{T.Validator_built(m, T.{P}_ok_len(_, buf, 0)) == (buf, None{{}}) : B.Buf & Maybe<&1, T.Validator>}}')
    w('  {==}')
    U = ['import Base', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
         'import ../../spec/primitives.bend as SP', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../decode_unique.bend as E',
         'import ./spec_fixed.bend as F',
         'import ./spec_rec_Validator.bend as C', '', '# GENERATED by codegen/spec_laws.py (validator_module). Do not edit.', '']
    U.append(f'def Validator_spec_unique({xsig}, +b: Bool, {esig}, +v: S.Value, spec: Decoding.decodes(Spec.Validator(), {BY}, v))')
    U.append(f'    -> {{v == {V} : S.Value}}:')
    U.append(f'  E.valid_unique(Spec.Validator(), {BY}, v, {V}, {{==}}, spec, '
             f'C.Validator_spec_encode({", ".join(xs)}, b, {", ".join(es)}))')
    return '\n'.join(L) + '\n', '\n'.join(U) + '\n'


REPR_HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
             'import ../../types/fulu_obj.bend as T', 'import ../../proofs/compact/found.bend as FD',
             'import ./repr.bend as R', 'import ./spec_fixed.bend as F']
# the per-name repr files add repr_seg (the symbolic literal-tree bridge)
REPR_SEG = 'import ./repr_seg.bend as RS'


def repr_law(w, n, depth, size, nw, R, obj, law, rhs_of):
    """One law of the literal buffer tree, carried to EVERY perfect tree of the
    loader's depth by proofs/obj/repr.bend `tree_words` (a tree is the canonical
    tree of its words) and found.bend `logic__subst`."""
    tv = 'FD.array__Tree<U32>'
    words = [f'R.w(t, {i}n)' for i in range(1 << depth)]
    # rewrite the buffer's array to the literal tree of its words first, so the
    # law's instance matches syntactically (a motive over thaw(build(..)) made the
    # checker compare the two decodes by running them: MatrixEntry 52 s)
    LIT = tree(words)
    BUILD = f'R.build({depth}n, R.lits(FD.spec_common__pow2({depth}n), FD.array__slots(U32, t)))'
    pat = rhs_of('t', words).replace('FD.array__thaw(U32, t)', '_')
    w(f'def {law}_tree(+t: {tv}, +pf: {{FD.array__perfect(U32, {depth}n, t) == True{{}} : Bool}})')
    w(f'    -> {rhs_of("t", words)}:')
    w(f'  %Equal.sym(Array<U32>, FD.array__thaw(U32, t), {LIT},')
    w(f'      Equal.trans(Array<U32>, FD.array__thaw(U32, t), FD.array__thaw(U32, {BUILD}), {LIT},')
    w(f'        Equal.cong({tv}, Array<U32>, v => FD.array__thaw(U32, v), t, {BUILD}, Equal.sym({tv}, {BUILD}, t, R.tree_words({depth}n, t, pf))), {{==}})) :')
    w(f'    {pat}')
    w(f'  C.{law}({", ".join(words)})')


def tree_lit(w, n, depth):
    """`<n>_tl(t, pf)`: the array of every perfect tree t of the depth is the literal tree of
    its words `R.w(t, k)`, by repr_seg.bend: `<n>_L<i>_<p>` is the literal tree of the 2^p words
    from i, `<n>_E<i>_<p>` proves `thaw(seg(slots t, i, p))` is it (RS.leaf / RS.node with
    literal i, p, j), and tree_words / seg0 bridge t to `seg(slots t, 0, depth)`. No tree is
    evaluated: every leaf is syntactically `R.w(t, k)` (the evaluated bridge was cubic in the
    words: MatrixEntry 31 s per law)."""
    tv = 'FD.array__Tree<U32>'
    S = 'FD.array__slots(U32, t)'
    for p in range(depth + 1):
        for i in range(0, 1 << depth, 1 << p):
            if p == 0:
                w(f'def {n}_L{i}_0(+t: {tv}) -> Array<U32>: ALeaf{{R.w(t, {i}n)}}')
            else:
                j = i + (1 << (p - 1))
                w(f'def {n}_L{i}_{p}(+t: {tv}) -> Array<U32>: ANode{{{n}_L{i}_{p - 1}(t), {n}_L{j}_{p - 1}(t)}}')
    for p in range(depth + 1):
        for i in range(0, 1 << depth, 1 << p):
            w(f'def {n}_E{i}_{p}(+t: {tv}) -> {{FD.array__thaw(U32, RS.seg({S}, {i}n, {p}n)) == {n}_L{i}_{p}(t) : Array<U32>}}:')
            if p == 0:
                w(f'  RS.leaf(t, {i}n)')
            else:
                j = i + (1 << (p - 1))
                w(f'  RS.node({S}, {i}n, {p - 1}n, {p}n, {{==}}, {j}n, {{==}}, {n}_L{i}_{p - 1}(t), {n}_L{j}_{p - 1}(t), '
                  f'{n}_E{i}_{p - 1}(t), {n}_E{j}_{p - 1}(t))')
    words = [f'R.w(t, {i}n)' for i in range(1 << depth)]
    BUILD = f'R.build({depth}n, R.lits(FD.spec_common__pow2({depth}n), {S}))'
    SEG = f'RS.seg({S}, 0n, {depth}n)'
    w(f'def {n}_tl(+t: {tv}, +pf: {{FD.array__perfect(U32, {depth}n, t) == True{{}} : Bool}})')
    w(f'    -> {{FD.array__thaw(U32, t) == {tree(words)} : Array<U32>}}:')
    w(f'  Equal.trans(Array<U32>, FD.array__thaw(U32, t), FD.array__thaw(U32, {SEG}), {n}_L0_{depth}(t),')
    w(f'    Equal.cong({tv}, Array<U32>, v => FD.array__thaw(U32, v), t, {SEG},')
    w(f'      Equal.trans({tv}, t, {BUILD}, {SEG}, Equal.sym({tv}, {BUILD}, t, R.tree_words({depth}n, t, pf)), RS.seg0({S}, {depth}n))),')
    w(f'    {n}_E0_{depth}(t))')


def seg_law(w, n, depth, law, rhs_of):
    """One law over every perfect tree, from the literal-tree law by `<n>_tl`.

    The literal law is applied inside `<law>_h`, over free words y<k> and an array A with
    A == the tree of the y's: there the decode / emit call holds variables, so its instance
    and the goal are compared by the syntactic identity check (a call over the tree of
    1024 words `R.w(t, k)` is past its budget of 4096 visits, and the checker then ran the
    decoder to compare: MatrixEntry 6 s)."""
    tv = 'FD.array__Tree<U32>'
    K = 1 << depth
    ys = [f'y{i}' for i in range(K)]
    ysig = ', '.join(f'+{y}: U32' for y in ys)
    w(f'def {law}_h({ysig}, -A: Array<U32>, e: {{A == {tree(ys)} : Array<U32>}})')
    w(f'    -> {rhs_of("A", ys)}:')
    w(f'  %Equal.sym(Array<U32>, A, {tree(ys)}, e) :')
    w(f'    {rhs_of("_", ys)}')
    w(f'  C.{law}({", ".join(ys)})')
    words = [f'R.w(t, {i}n)' for i in range(K)]
    T = 'FD.array__thaw(U32, t)'
    w(f'def {law}_tree(+t: {tv}, +pf: {{FD.array__perfect(U32, {depth}n, t) == True{{}} : Bool}})')
    w(f'    -> {rhs_of(T, words)}:')
    w(f'  {law}_h({", ".join(words)}, {T}, {n}_tl(t, pf))')


def emit_repr(w, n, node, size, R):
    import re
    nw = size // 4
    depth = max(0, (nw - 1).bit_length())
    idx = {v: i for i, v in enumerate(node.words)}
    def sub(term, ws):
        return re.sub(r'\bx\d+\b', lambda m: ws[idx[m.group(0)]], term)
    def buf(a):
        return f'B.Buf{{{a}, {size}}}'
    tree_lit(w, n, depth)
    seg_law(w, n, depth, f'{n}_spec_decode',
            lambda a, ws: f'{{T.{n}_decode({buf(a)}, {size}) == ({buf(a)}, Some{{{sub(node.dec, ws)}}}) : B.Buf & Maybe<&1, {R}>}}')
    seg_law(w, n, depth, f'{n}_spec_view',
            lambda a, ws: f'{{B.emit({buf(a)}, 0, {nw}) == ({buf(a)}, F.limbs([{", ".join(ws[:nw])}])) : B.Buf & +List<U32>}}')


def repr_small():
    L = REPR_HEAD + ['import ./spec_small.bend as C', '',
                     '# GENERATED by codegen/spec_laws.py (repr_small). Do not edit.', '']
    w = L.append
    b = lambda u: f'B.Buf{{FD.array__thaw(U32, {u}), 1}}'
    for n, R, obj in [('uint8', 'U32', 'B.byte_sel(0, {x})'), ('ParticipationFlags', 'U32', 'B.byte_sel(0, {x})'),
                      ('Bytes1', 'T.Bytes1', 'T.Bytes1{{B.byte_sel(0, {x})}}')]:
        repr_law(w, n, 0, 1, 1, R, None, f'{n}_spec_decode',
                 lambda u, ws, n=n, R=R, obj=obj: f'{{T.{n}_decode({b(u)}, 1) == ({b(u)}, Some{{{obj.format(x=ws[0])}}}) : B.Buf & Maybe<&1, {R}>}}')
    for n in ['uint8', 'ParticipationFlags', 'Bytes1', 'boolean']:
        repr_law(w, n, 0, 1, 1, None, None, f'{n}_spec_view',
                 lambda u, ws: f'{{B.emit({b(u)}, 0, 1) == ({b(u)}, [B.byte_sel(0, {ws[0]})]) : B.Buf & +List<U32>}}')
    # boolean: the three decoder answers, each under its hypothesis on the byte
    tv = 'FD.array__Tree<U32>'
    for law, hyp, ans in [('boolean_spec_decode_0', '{B.byte_sel(0, R.w(t, 0n)) == 0 : U32}', 'Some{False{}}'),
                          ('boolean_spec_decode_1', '{B.byte_sel(0, R.w(t, 0n)) == 1 : U32}', 'Some{True{}}'),
                          ('boolean_spec_decode_reject', '{U32.is_le(B.byte_sel(0, R.w(t, 0n)), 1) == False{} : Bool}', 'None{}')]:
        ty = lambda u: f'{{T.boolean_decode({b(u)}, 1) == ({b(u)}, {ans}) : B.Buf & Maybe<&1, Bool>}}'
        w(f'def {law}_tree(+t: {tv}, +pf: {{FD.array__perfect(U32, 0n, t) == True{{}} : Bool}}, +h: {hyp})')
        w(f'    -> {ty("t")}:')
        w(f'  FD.logic__subst({tv}, u => {ty("u")},')
        w(f'    R.build(0n, R.lits(FD.spec_common__pow2(0n), FD.array__slots(U32, t))), t, R.tree_words(0n, t, pf),')
        w(f'    C.{law}(R.w(t, 0n), h))')
    return '\n'.join(L) + '\n'


def load_sizes(sizes):
    """The loader laws load_<n> of the given sizes over load_words.bend (a size of 2^p
    words, p >= POW2_MIN: arr_emit.load_all at the tree of the words, load_pow2)."""
    pw = {n: (n // 4).bit_length() - 1 for n in sizes if n % 4 == 0 and n // 4 == 1 << ((n // 4).bit_length() - 1)
          and (n // 4).bit_length() - 1 >= POW2_MIN}
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../proofs/compact/found.bend as FD',
         'import ./repr.bend as R', 'import ./spec_fixed.bend as F', 'import ./load_words.bend as LW'] + \
        (['import ./arr_emit.bend as AE'] if pw else []) + ['',
         '# GENERATED by codegen/spec_laws.py (load_sizes). Do not edit.',
         '# The loaded buffer of the bytes of any words is the literal buffer of the words.', '']
    tl = {n for n in sizes if n not in pw and n % 4 == 0 and n // 4 >= VIEW_MIN}
    if tl:
        L.insert(L.index(''), 'import ./arr_enc.bend as AN')
    rest = set(sizes) - set(pw) - tl
    body = ''
    if rest:
        body = load_module(rest)
        body = body[body.index('def load_'):]
    return ('\n'.join(L) + '\n' + body + ''.join(load_pow2(n, pw[n]) for n in sorted(pw))
            + ''.join(load_tail(n) for n in sorted(tl)))


def load_tail(n):
    """load_<n> for a word count past 2^p (p + 1 the buffer's depth): the words are the
    slots of the tree A of the first 2^p then the rest G (`lwt<n>`), and arr_enc.load_tail
    fills [A | G then zeros] for every such A (only G's |G| words are placed by the model
    copy; no fill loop is run)."""
    nw = n // 4
    p = (nw - 1).bit_length() - 1
    ws = [f'x{i}' for i in range(nw)]
    A, G = ws[:1 << p], ws[1 << p:]
    wsig = ', '.join(f'+{x}: U32' for x in ws)
    WS = '[' + ', '.join(ws) + ']'
    TA = ttree(A)
    GL = '[' + ', '.join(G) + ']'
    LIT = tree(ws + ['0'] * ((2 << p) - nw))
    out = [f'def lwt{n}({wsig}) -> {{FD.spec_common__append(U32, FD.array__slots(U32, {TA}), {GL}) == {WS} : List<&2, U32>}}:', '  {==}',
           f'def load_{n}({wsig})',
           f'    -> {{B.fill_at(B.alloc({n}), 0, F.limbs({WS})) == B.Buf{{{LIT}, {n}}} : B.Buf}}:',
           f'  %lwt{n}({", ".join(ws)}) : {{B.fill_at(B.alloc({n}), 0, F.limbs(_)) == B.Buf{{{LIT}, {n}}} : B.Buf}}',
           f'  AN.load_tail({p}n, {len(G)}n, {n}, {TA}, {GL}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})', '']
    return '\n'.join(out) + '\n'


def load_pow2(n, p):
    """load_<n> for 2^p words: the word list is the slots of the tree of the words (`lw<n>`,
    appends only), and AE.load_all fills every perfect tree (no fill loop is run)."""
    nw = n // 4
    ws = [f'x{i}' for i in range(nw)]
    wsig = ', '.join(f'+{x}: U32' for x in ws)
    WS = '[' + ', '.join(ws) + ']'
    TX = ttree(ws)
    out = [f'def lw{n}({wsig}) -> {{FD.array__slots(U32, {TX}) == {WS} : List<&2, U32>}}:', '  {==}',
           f'def load_{n}({wsig})',
           f'    -> {{B.fill_at(B.alloc({n}), 0, F.limbs({WS})) == B.Buf{{{tree(ws)}, {n}}} : B.Buf}}:',
           f'  %lw{n}({", ".join(ws)}) : {{B.fill_at(B.alloc({n}), 0, F.limbs(_)) == B.Buf{{{tree(ws)}, {n}}} : B.Buf}}',
           f'  AE.load_all({p}n, {TX}, {n}, {{==}}, {{==}}, {{==}})', '']
    return '\n'.join(out) + '\n'


def load_words():
    """proofs/obj/load_words.bend: word_of of a word's bytes is the word (shared by
    the per-name loader files spec_{tag}load_<N>.bend and arr_emit.bend).

    One load.bend with every size cost each importer all 40 loader laws (11 s);
    each spec_{tag}input_<N> imports only its own size."""
    return load_module(None)


def load_module(sizes):
    """proofs/obj/load.bend: the real input path.

    The native programs read a file into `B.alloc(n)` with `B.fill_at(buf, 0,
    bytes)` (benchmarks/compact/objio.bend; one piece for every fixed name
    here). A byte list of a whole number of words is `limbs(ws)` for its words
    ws, and `word_of` of the four bytes of a word is that word (`word_of_bytes`,
    by the word's 32 bits). So the loaded buffer is the literal buffer of ws
    (`load_<n>`), and every decode law over literal buffers holds for the bytes
    as loaded (proofs/obj/spec_input_*.bend).
    """
    a = [f'a{i}' for i in range(32)]
    F24 = ['False{}'] * 24
    W = word_pat(a)
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../proofs/compact/bits.bend as BT',
         'import ../../proofs/compact/found.bend as FD', '', '# GENERATED by codegen/spec_laws.py (load_words). Do not edit.', '']
    w = L.append
    shapes = {3: 'Bool.or(Bool.or(Bool.or(Bool.and(x, True{}), False{}), False{}), False{})',
              2: 'Bool.or(Bool.or(Bool.and(x, True{}), False{}), False{})',
              1: 'Bool.or(Bool.and(x, True{}), False{})', 0: 'Bool.and(x, True{})'}
    for k, e in shapes.items():
        w(f'def fix{k}(+x: Bool) -> {{{e} == x : Bool}}:')
        w('  match x:')
        w('    case True{}: {==}')
        w('    case False{}: {==}')
    byts = [word_pat(a[8 * k:8 * k + 8] + F24) for k in range(4)]
    xs = [shapes[3 - i // 8].replace('x', a[i]) for i in range(32)]
    sig = ', '.join(f'+{x}: Bool' for x in a)
    w(f'def word_of_bits({sig}) -> {{B.word_of({", ".join(byts)}) == {W} : U32}}:')
    w(f'  BT.word32_eq({", ".join(xs)}, {", ".join(a)}, ' + ', '.join(f'fix{3 - i // 8}({a[i]})' for i in range(32)) + ')')
    w('')
    w('# word_of of the four little-endian bytes of any word is the word.')
    w('law word_of_bytes:')
    w('  for +x: U32')
    w('  {B.word_of(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x)) == x : U32}')
    w('def word_of_bytes(x):')
    w('  match x:')
    w(f'    case {W}:')
    sels = [f'B.byte_sel({k}, {W})' for k in range(4)]
    for k in range(4):
        args = byts[:k] + ['_'] + sels[k + 1:]
        w(f'      %Equal.sym(U32, B.byte_sel({k}, {W}), {byts[k]}, BT.sel{k}({", ".join(a)})) :')
        w(f'        {{B.word_of({", ".join(args)}) == {W} : U32}}')
    w(f'      word_of_bits({", ".join(a)})')
    w('')
    w('# The words the loader stores for the bytes of a word list.')
    w('def wofs(ws: List<&2, U32>) -> List<&2, U32>:')
    w('  match ws:')
    w('    case Nil{}: Nil{}')
    w('    case Con{+h, t}: Con{B.word_of(B.byte_sel(0, h), B.byte_sel(1, h), B.byte_sel(2, h), B.byte_sel(3, h)), wofs(t)}')
    w('law wofs_id:')
    w('  for +ws: List<&2, U32>')
    w('  {wofs(ws) == ws : List<&2, U32>}')
    w('def wofs_id(ws):')
    w('  match ws:')
    w('    case Nil{}: {==}')
    w('    case Con{+h, +t}:')
    w('      %Equal.sym(U32, B.word_of(B.byte_sel(0, h), B.byte_sel(1, h), B.byte_sel(2, h), B.byte_sel(3, h)), h, word_of_bytes(h)) :')
    w('        {Con{_, wofs(t)} == Con{h, t} : List<&2, U32>}')
    w('      FD.list__cons_cong(U32, h, wofs(t), t, wofs_id(t))')
    w('')
    if sizes is None:
        return '\n'.join(L) + '\n'
    for n in sorted(sizes):
        nw = n // 4
        depth = max(0, (nw - 1).bit_length())
        ws = [f'x{i}' for i in range(nw)]
        leaves = ws + ['0'] * ((1 << depth) - nw)
        wsig = ', '.join(f'+{x}: U32' for x in ws)
        rhs = f'B.Buf{{{tree(leaves)}, {n}}}'
        zeros = '[' + ', '.join(['0'] * ((1 << depth) - nw)) + ']'
        WS = '[' + ', '.join(ws) + ']'
        w(f'def load_{n}({wsig})')
        w(f'    -> {{B.fill_at(B.alloc({n}), 0, F.limbs({WS})) == {rhs} : B.Buf}}:')
        w(f'  Equal.cong(List<&2, U32>, B.Buf, l => B.Buf{{FD.array__thaw(U32, R.build({depth}n, FD.spec_common__append(U32, l, {zeros}))), {n}}},')
        w(f'    LW.wofs({WS}), {WS}, LW.wofs_id({WS}))')
    return '\n'.join(L) + '\n'


def emit_input(w, n, node, size, R):
    """decode of the bytes as the loader stores them = the object of the words."""
    import re
    nw = size // 4
    depth = max(0, (nw - 1).bit_length())
    pads = ['0'] * ((1 << depth) - nw)
    loaded = f'B.fill_at(B.alloc({size}), 0, F.limbs([{", ".join(node.words)}]))'
    sig = ', '.join(f'+{v}: U32' for v in node.words)
    ty = lambda b: f'{{T.{n}_decode({b}, {size}) == ({b}, Some{{{node.dec}}}) : B.Buf & Maybe<&1, {R}>}}'
    lit = f'B.Buf{{{tree(node.words + pads)}, {size}}}'
    w(f'def {n}_spec_input({sig})')
    w(f'    -> {ty(loaded)}:')
    w(f'  FD.logic__subst(B.Buf, b => {ty("b")}, {lit}, {loaded},')
    w(f'    Equal.sym(B.Buf, {loaded}, {lit}, LD.load_{size}({", ".join(node.words)})),')
    w(f'    C.{n}_spec_decode({", ".join(node.words + pads)}))')


# A byte vector whose word count is 2^p (p >= POW2_MIN: Cell) is decoded, emitted,
# encoded and loaded by the array loop laws of proofs/obj/arr_copy.bend / arr_emit.bend
# (AC.zl1, AC.ov, AE.emit_all, AE.load_all) for EVERY perfect tree of depth p, once, and
# the literal laws instantiate them at the tree of the words: the literal array is first
# rewritten to the thaw of that tree (the arrays compare constructor by constructor), so no
# copy or emit loop is run over closed U32 indices (Cell: 5.3 + 2.7 + 2.1 s by evaluation).
POW2_MIN = 5


def pow2_words(t, g):
    """p when t is a byte vector stored as words (O.Words) of 2^p words, p >= POW2_MIN."""
    if t.kind != 'bytes' or g.shape(t).kind != 'fixwords' or t.size % 4:
        return None
    nw = t.size // 4
    p = nw.bit_length() - 1
    return p if nw == 1 << p and p >= POW2_MIN else None


POW2_IMPORTS = ['import ../../proofs/compact/found.bend as FD', 'import ./arr_copy.bend as AC', 'import ./arr_emit.bend as AE']


def ttree(leaves):
    """The found.bend Tree of the leaves (a perfect tree when there are 2^p)."""
    if len(leaves) == 1:
        return f'FD.TLeaf{{{leaves[0]}}}'
    h = len(leaves) // 2
    return f'FD.TNode{{{ttree(leaves[:h])}, {ttree(leaves[h:])}}}'


def HKP(p, words):
    """oct(words >> 3) == 2^p without unary 2^p (spec_arr.HK)."""
    return f'AC.oct_pow({words}, {p}n, {p - 3}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})'


def pow2_trees(w, n, p, size, R):
    """The tree forms of the laws of a 2^p-word byte vector (spec_arr.blob, in this
    module's aliases): <n>_td decode, <n>_tv view, <n>_tb encoder bytes."""
    nw = 1 << p
    TV = 'FD.array__Tree<U32>'
    th = lambda u: f'FD.array__thaw(U32, {u})'
    pf = lambda u: f'{{FD.array__perfect(U32, {p}n, {u}) == True{{}} : Bool}}'
    buf = lambda u: f'B.Buf{{{th(u)}, {size}}}'
    dec = f'O.Words{{ANode{{{th("t")}, Array.new(U32, {p}n, 0)}}, {size}}}'
    w(f'# ---- {n}: the laws for every perfect tree of depth {p} (arr_copy / arr_emit) ----')
    w(f'def {n}_td(+t: {TV}, +pt: {pf("t")})')
    w(f'    -> {{T.{n}_decode({buf("t")}, {size}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({nw}, 0, 0, Array.new(U32, {p + 1}n, 0), {th("t")}), (ANode{{{th("t")}, Array.new(U32, {p}n, 0)}}, {th("t")}),')
    w(f'      AC.zl1({p}n, {nw}, 0, 0, t, {{==}}, {{==}}, {HKP(p, nw)}, {{==}}, {{==}}, pt)) :')
    w(f'    {{T.{n}_some(O.ci_fin({size}, {size}, _)) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}')
    w('  {==}')
    w(f'def {n}_tv(+t: {TV}, +pt: {pf("t")})')
    w(f'    -> {{B.emit({buf("t")}, 0, {nw}) == ({buf("t")}, F.limbs(FD.array__slots(U32, t))) : B.Buf & +List<U32>}}:')
    w(f'  AE.emit_all({p}n, t, {size}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, pt)')
    obj = f'O.Words{{ANode{{{th("l")}, {th("r")}}}, {size}}}'
    SL_ = 'FD.array__slots(U32, l)'
    w(f'def {n}_tb(+l: {TV}, +r: {TV}, +pl: {pf("l")}, +pr: {pf("r")})')
    w(f'    -> {{F.emitted(O.Words, T.{n}_encode({obj}), {nw}) == ({obj}, F.limbs({SL_})) : O.Words & +List<U32>}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({nw}, 0, 0, Array.new(U32, {p}n, 0), {th("FD.TNode{l, r}")}), ({th("l")}, {th("FD.TNode{l, r}")}),')
    w(f'      AC.ov({p}n, {nw}, 0, 0, l, r, {{==}}, {{==}}, {HKP(p, nw)}, {{==}}, {{==}}, pl, pr)) :')
    w(f'    {{F.emitted(O.Words, T.{n}_enc_out(O.put_fin({size}, _)), {nw}) == ({obj}, F.limbs({SL_})) : O.Words & +List<U32>}}')
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit(B.Buf{{{th("l")}, {size}}}, 0, {nw}), (B.Buf{{{th("l")}, {size}}}, F.limbs({SL_})), {n}_tv(l, pl)) :')
    w(f'    {{({obj}, F.listed(_)) == ({obj}, F.limbs({SL_})) : O.Words & +List<U32>}}')
    w('  {==}')
    w('')


# The view law of a name of at least VIEW_MIN words is arr_emit.emit_take at the tree of its
# buffer's words (the literal buffer rewritten to that tree's thaw first): no emit loop is
# run over closed U32 indices (Deposit 1.4 s, MatrixEntry 2.3 s by evaluation).
VIEW_MIN = 32


def top_args(term):
    """The arguments of a constructor term `C{a, b, ..}`, split at depth 0."""
    body = term[term.index('{') + 1:-1]
    out, cur, d = [], '', 0
    for c in body:
        if c in '([{<':
            d += 1
        elif c in ')]}>':
            d -= 1
        if c == ',' and d == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += c
    out.append(cur.strip())
    return term[:term.index('{')], out


def lhalf(t, g, node):
    """p when t is a container whose first field is a 2^p-word byte vector filling the left
    half of its buffer (depth p + 1) and whose other fields have no storage padding
    (MatrixEntry: Cell then 16 words)."""
    if t.kind != 'container' or not t.fields:
        return None
    s = g.shape(t)
    if s.kind != 'container' or s.fields[0][1].kind == 'box':
        return None
    p = pow2_words(t.fields[0][1], g)
    if p is None:
        return None
    nw = t.fixed_size() // 4
    if max(0, (nw - 1).bit_length()) != p + 1 or len(node.opads) != 1 << p:
        return None
    return p


def ltail(t, g, node):
    """(p, E, rep) when t is a container whose first field is a packed vector stored as words
    (O.Words) of 2^p + E words (0 < E < 2^p, a multiple of 8 words in all) at offset 0, in
    a buffer of depth p + 1 whose storage depth is also that field's (Deposit: 264 = 256 + 8
    words, then DepositData)."""
    if t.kind != 'container' or not t.fields:
        return None
    s = g.shape(t)
    if s.kind != 'container' or s.fields[0][1].kind == 'box':
        return None
    ft = t.fields[0][1]
    fs = g.shape(ft)
    if fs.kind not in ('packed', 'packed_elems', 'fixwords') or ft.fixed_size() % 32:
        return None
    W = ft.fixed_size() // 4
    p = W.bit_length() - 1
    E = W - (1 << p)
    nw = t.fixed_size() // 4
    if E <= 0 or max(0, (nw - 1).bit_length()) != p + 1 or storage(ft.fixed_size()) != p + 1:
        return None
    if len(node.opads) != (2 << p) - W:
        return None
    m = re.search(rf'^def {fs.p}_valid\(o: O\.Words\) -> O\.Words & Bool: O\.words_ok\(o, (\d+), (\d+), False{{}}, (\d+)\)$',
                  RR.mono_text('fulu'), re.M)
    if not m or int(m.group(1)) != 4 * W or int(m.group(2)) != 4 * W:
        return None
    return p, E, fs.p, int(m.group(3))


def spine(y0, ms):
    """[..[y0 | m0] | m1] .. | m_k]: a perfect tree whose leftmost path is literal (so
    Array.size and the reads past the first word compute) and the rest free trees."""
    out = f'FD.TNode{{FD.TLeaf{{{y0}}}, {ms[0]}}}'
    for m in ms[1:]:
        out = f'FD.TNode{{{out}, {m}}}'
    return out


def spine_pf(y0, ms, pms):
    """perfect(k + 1, spine(y0, ms)) from the perfect facts pms of the free trees."""
    out = f'FD.logic__and_intro(FD.array__perfect(U32, 0n, FD.TLeaf{{{y0}}}), FD.array__perfect(U32, 0n, {ms[0]}), {{==}}, {pms[0]})'
    cur = f'FD.TNode{{FD.TLeaf{{{y0}}}, {ms[0]}}}'
    for j in range(1, len(ms)):
        out = f'FD.logic__and_intro(FD.array__perfect(U32, {j}n, {cur}), FD.array__perfect(U32, {j}n, {ms[j]}), {out}, {pms[j]})'
        cur = f'FD.TNode{{{cur}, {ms[j]}}}'
    return out


def spine_args(xs):
    """The spine's instance at the literal words xs (2^p of them): y0 = xs[0], m_j = the tree
    of xs[2^j .. 2^(j+1)); the spine is then syntactically ttree(xs)."""
    p = len(xs).bit_length() - 1
    return xs[0], [ttree(xs[1 << j:2 << j]) for j in range(p)]


def emit_name(w, n, t, node, size, R, P, data, p2=None, lh=None, lt=None):
    nw = size // 4
    if p2 is not None:
        return emit_pow2(w, n, t, node, size, R, P, p2)
    tview = nw >= VIEW_MIN or lt is not None
    sig = ', '.join(f'+{v}: U32' for v in node.words)
    args = ', '.join(node.words)
    L = f'F.limbs({wl(node.words)})'
    enc = f'T.{n}_encode({node.obj})'
    depth = max(0, (nw - 1).bit_length())
    pads = [f'p{i}' for i in range((1 << depth) - nw)]
    buf = f'B.Buf{{{tree(node.words + pads)}, {size}}}'
    psig = ', '.join([sig] + [f'+{p}: U32' for p in pads])
    osig = ', '.join([sig] + [f'+{q}: U32' for q in node.opads])
    if lh is not None:
        emit_lhalf(w, n, node, size, R, lh, pads)
    if lt is not None:
        emit_ltail(w, n, node, size, R, lt, pads)
    if tview:
        T_ = ttree(node.words + pads)
        w(f'def {n}_lb({psig}) -> {{FD.array__thaw(U32, {T_}) == {tree(node.words + pads)} : Array<U32>}}:')
        w('  {==}')
    # EVB: the encoder's bytes as the view of its output buffer: <n>_enc evaluates only the
    # writes, and the emitted bytes are <n>_vw (the view law, emit_take) at zero pads, so the
    # emit loop is not run over closed indices a second time
    evb = tview and not data and lh is None and lt is None
    if evb:
        zs = ['0'] * len(pads)
        LITW = f'B.Buf{{{tree(node.words + zs)}, {size}}}'
        w(f'def {n}_vw({psig})')
        w(f'    -> {{B.emit({buf}, 0, {nw}) == ({buf}, {L}) : B.Buf & +List<U32>}}:')
        w(f'  %{n}_lb({", ".join(node.words + pads)}) :')
        w(f'    {{B.emit(B.Buf{{_, {size}}}, 0, {nw}) == (B.Buf{{_, {size}}}, {L}) : B.Buf & +List<U32>}}')
        w(f'  AE.emit_take({depth}n, {ttree(node.words + pads)}, {size}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})')
        w(f'def {n}_enc({osig}) -> {{{enc} == ({node.obj}, {LITW}) : {R} & B.Buf}}:')
        w('  {==}')
    w(f'def {n}_spec_bytes({osig})')
    if data:
        w(f'    -> {{B.emit({enc}, 0, {nw}) == ({enc}, {L}) : B.Buf & +List<U32>}}:')
    else:
        w(f'    -> {{F.emitted({R}, {enc}, {nw}) == ({node.obj}, {L}) : {R} & +List<U32>}}:')
    if evb:
        zs = ['0'] * len(pads)
        LITW = f'B.Buf{{{tree(node.words + zs)}, {size}}}'
        EQ = f'{{({node.obj}, F.listed(_)) == ({node.obj}, {L}) : {R} & +List<U32>}}'
        w(f'  %Equal.sym({R} & B.Buf, {enc}, ({node.obj}, {LITW}), {n}_enc({", ".join(node.words + node.opads)})) :')
        w(f'    {{F.emitted({R}, _, {nw}) == ({node.obj}, {L}) : {R} & +List<U32>}}')
        w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit({LITW}, 0, {nw}), ({LITW}, {L}), {n}_vw({", ".join(node.words + zs)})) :')
        w(f'    {EQ}')
        w('  {==}')
    elif lh is not None:
        cname, rest = top_args(node.obj)
        objp = f'{cname}{{O.Words{{_, {4 << lh}}}, {", ".join(rest[1:])}}}'
        X, Q = node.words[:1 << lh], node.opads
        y0, ms = spine_args(X)
        w(f'  %{n}_lxq({", ".join(X + Q)}) :')
        w(f'    {{F.emitted({R}, T.{n}_encode({objp}), {nw}) == ({objp}, {L}) : {R} & +List<U32>}}')
        w(f'  {n}_ltb({y0}, {", ".join(ms)}, {", ".join(["{==}"] * lh)}, {ttree(Q)}, {{==}}, {", ".join(node.words[1 << lh:])})')
    elif lt is not None:
        H_ = 1 << lt[0]
        W_ = H_ + lt[1]
        cname, rest = top_args(node.obj)
        objp = f'{cname}{{O.Words{{_, {4 * W_}}}, {", ".join(rest[1:])}}}'
        X = node.words[:H_]
        Sr = node.words[H_:W_] + node.opads
        y0, ms = spine_args(X)
        w(f'  %{n}_lxs({", ".join(X + Sr)}) :')
        w(f'    {{F.emitted({R}, T.{n}_encode({objp}), {nw}) == ({objp}, {L}) : {R} & +List<U32>}}')
        w(f'  {n}_ltb({y0}, {", ".join(ms)}, {", ".join(["{==}"] * lt[0])}, {", ".join(Sr + node.words[W_:])})')
    else:
        w('  {==}')
    w(f'def {n}_spec_parts({sig})')
    w(f'    -> {{Codec.parts({node.val}, Spec.{n}()) == Some{{[S.Fixed{{{L}}}]}} : Maybe<&2, +List<S.Part>>}}:')
    if EXACT:
        w(f'  %Equal.sym(S.Schema, Spec.{n}(), {node.sch}, {{==}}) :')
        w(f'    {{Codec.parts({node.val}, _) == Some{{[S.Fixed{{{L}}}]}} : Maybe<&2, +List<S.Part>>}}')
    w(f'  {node.proof}')
    w(f'def {n}_spec_encode({sig})')
    w(f'    -> Decoding.decodes(Spec.{n}(), {L}, {node.val}):')
    w(f'  F.encoding_of_parts(Spec.{n}(), {node.val}, {L}, {n}_spec_parts({args}))')
    w(f'def {n}_spec_decode({psig})')
    w(f'    -> {{T.{n}_decode({buf}, {size}) == ({buf}, Some{{{node.dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    if lh is not None:
        H = 1 << lh
        X, Rw = node.words[:H], node.words[H:] + pads
        LX, LR = tree(X), tree(Rw)
        cname, rest = top_args(node.dec)
        LZ = tree(['0'] * H)
        y0, ms = spine_args(X)
        TX = ttree(X)
        pat = lambda a, b: (f'{{T.{n}_decode(B.Buf{{ANode{{{a}, {b}}}, {size}}}, {size}) == (B.Buf{{ANode{{{a}, {b}}}, {size}}}, '
                            f'Some{{{cname}{{O.Words{{ANode{{{a}, {LZ}}}, {4 << lh}}}, {", ".join(rest[1:])}}}}}) : B.Buf & Maybe<&1, {R}>}}')
        w(f'  %{n}_lx({", ".join(X)}) :')
        w(f'    {pat("_", LR)}')
        w(f'  %{n}_lr({", ".join(Rw)}) :')
        w(f'    {pat(f"FD.array__thaw(U32, {TX})", "_")}')
        w(f'  {n}_ltd({y0}, {", ".join(ms)}, {", ".join(["{==}"] * lh)}, {", ".join(Rw)})')
    elif lt is not None:
        H_ = 1 << lt[0]
        W_ = H_ + lt[1]
        X, Rw = node.words[:H_], node.words[H_:] + pads
        LX, LR = tree(X), tree(Rw)
        cname, rest = top_args(node.dec)
        DZ = tree(node.words[H_:W_] + ['0'] * (H_ - lt[1]))
        y0, ms = spine_args(X)
        TX = ttree(X)
        pat = lambda a, b: (f'{{T.{n}_decode(B.Buf{{ANode{{{a}, {b}}}, {size}}}, {size}) == (B.Buf{{ANode{{{a}, {b}}}, {size}}}, '
                            f'Some{{{cname}{{O.Words{{ANode{{{a}, {DZ}}}, {4 * W_}}}, {", ".join(rest[1:])}}}}}) : B.Buf & Maybe<&1, {R}>}}')
        w(f'  %{n}_lx({", ".join(X)}) :')
        w(f'    {pat("_", LR)}')
        w(f'  %{n}_lr({", ".join(Rw)}) :')
        w(f'    {pat(f"FD.array__thaw(U32, {TX})", "_")}')
        w(f'  {n}_ltd({y0}, {", ".join(ms)}, {", ".join(["{==}"] * lt[0])}, {", ".join(Rw)})')
    else:
        w('  {==}')
    w(f'def {n}_spec_view({psig})')
    w(f'    -> {{B.emit({buf}, 0, {nw}) == ({buf}, {L}) : B.Buf & +List<U32>}}:')
    if evb:
        w(f'  {n}_vw({", ".join(node.words + pads)})')
    elif tview:
        T_ = ttree(node.words + pads)
        w(f'  %{n}_lb({", ".join(node.words + pads)}) :')
        w(f'    {{B.emit(B.Buf{{_, {size}}}, 0, {nw}) == (B.Buf{{_, {size}}}, {L}) : B.Buf & +List<U32>}}')
        w(f'  AE.emit_take({depth}n, {T_}, {size}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})')
    else:
        w('  {==}')
    w(f'def {n}_spec_reject(buf: B.Buf, +m: U32, e: {{U32.is_eq(m, {size}) == False{{}} : Bool}})')
    w(f'    -> {{T.{n}_decode(buf, m) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(Bool, U32.is_eq(m, {size}), False{{}}, e) : '
      f'{{T.{n}_built(m, T.{P}_ok_len(_, buf, 0)) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}')
    w('  {==}')


def emit_lhalf(w, n, node, size, R, p, pads):
    """The decode and encoder-bytes laws of a container whose buffer's left half is its first
    field, a 2^p-word byte vector (MatrixEntry), for the left half a free spine
    [..[y0 | m0] .. | m_(p-1)] and the other words literal: the field's copy is
    arr_copy.zl2n (so the copy loop is never run: the spine's free trees stop it), the
    validity check arr_copy.vok, the emitted words arr_emit.emit_take; the small fields'
    reads and writes compute (the spine's literal leftmost path gives Array.size). The
    literal laws instantiate these at the spine of the words, which is syntactically
    their tree (spine_args)."""
    H = 1 << p
    nw = size // 4
    depth = p + 1
    TV = 'FD.array__Tree<U32>'
    th = lambda u: f'FD.array__thaw(U32, {u})'
    X, G = node.words[:H], node.words[H:]
    Q = node.opads
    ms = [f'm{j}' for j in range(p)]
    pms = [f'pm{j}' for j in range(p)]
    U = spine('y0', ms)
    pU = spine_pf('y0', ms, pms)
    sp = ('+y0: U32, ' + ', '.join(f'+{m}: {TV}' for m in ms) + ', '
          + ', '.join(f'+pm{j}: {{FD.array__perfect(U32, {j}n, m{j}) == True{{}} : Bool}}' for j in range(p)))
    gsig = ', '.join(f'+{x}: U32' for x in G)
    cname, rest = top_args(node.dec)
    _, rest_o = top_args(node.obj)
    assert rest[1:] == rest_o[1:], n
    RST = ', '.join(rest[1:])
    KB = 4 << p
    hk = HKP(p, H)
    # literal-array bridges
    LX, TX = tree(X), ttree(X)
    Rw = G + pads
    w(f'def {n}_lx({", ".join(f"+{x}: U32" for x in X)}) -> {{{th(TX)} == {LX} : Array<U32>}}:')
    w('  {==}')
    w(f'def {n}_lr({", ".join(f"+{x}: U32" for x in Rw)}) -> {{{th(ttree(Rw))} == {tree(Rw)} : Array<U32>}}:')
    w('  {==}')
    w(f'def {n}_lxq({", ".join(f"+{x}: U32" for x in X + Q)}) -> {{{th(f"FD.TNode{{{TX}, {ttree(Q)}}}")} == ANode{{{LX}, {tree(Q)}}} : Array<U32>}}:')
    w('  {==}')
    # decode over the spine and the literal right half
    TR = ttree(Rw)
    SRC = f'ANode{{{th(U)}, {th(TR)}}}'
    BUF = f'B.Buf{{{SRC}, {size}}}'
    OBJ = f'{cname}{{O.Words{{ANode{{{th(U)}, Array.new(U32, {p}n, 0)}}, {KB}}}, {RST}}}'
    RT = f'B.Buf & Maybe<&1, {R}>'
    w(f'# {n} decoded from a buffer whose left half is the spine: its first field copies that half (AC.zl2n)')
    w(f'def {n}_ltd({sp}, {", ".join(f"+{x}: U32" for x in Rw)})')
    w(f'    -> {{T.{n}_decode({BUF}, {size}) == ({BUF}, Some{{{OBJ}}}) : {RT}}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({H}, 0, 0, Array.new(U32, {depth}n, 0), {SRC}), (ANode{{{th(U)}, Array.new(U32, {p}n, 0)}}, {SRC}),')
    w(f'      AC.zl2n({p}n, {H}, 0, 0, {U}, {TR}, {{==}}, {{==}}, {hk}, {{==}}, {{==}}, {pU}, {{==}})) :')
    w(f'    {{T.{n}_some(T.{n}_rd0(0, {size}, O.ci_fin({size}, {KB}, _))) == ({BUF}, Some{{{OBJ}}}) : {RT}}}')
    w('  {==}')
    # encoder bytes over the spine and any storage padding tree
    WS = f'O.Words{{{th(f"FD.TNode{{{U}, q}}")}, {KB}}}'
    _, orest = top_args(node.obj)
    OBJE = f'{cname}{{{WS}, {RST}}}'
    TRo = ttree(G + ['0'] * (H - len(G)))
    UR = f'FD.TNode{{{U}, {TRo}}}'
    RHS = f'({OBJE}, F.limbs(FD.spec_common__take(U32, FD.array__slots(U32, {UR}), {nw}n)))'
    ET = f'{R} & +List<U32>'
    fargs = ', '.join(rest[1:])
    wrap = lambda inner: f'F.emitted({R}, T.{n}_enc_out(T.{n}_put_drop(T.{n}_pw0(0, 0, {fargs}, {inner}))), {nw})'
    pUQ = f'FD.logic__and_intro(FD.array__perfect(U32, {p}n, {U}), FD.array__perfect(U32, {p}n, q), {pU}, pq)'
    pUR = f'FD.logic__and_intro(FD.array__perfect(U32, {p}n, {U}), FD.array__perfect(U32, {p}n, {TRo}), {pU}, {{==}})'
    FB_ = f'B.Buf{{{th(UR)}, {size}}}'
    first = f'T.b{KB}'
    w(f'# {n}\'s encoder: the first field\'s storage [spine | q] (q free) copied (AC.vok, AC.zl2n), the rest written')
    w(f'def {n}_ltb({sp}, +q: {TV}, +pq: {{FD.array__perfect(U32, {p}n, q) == True{{}} : Bool}}, {gsig})')
    w(f'    -> {{F.emitted({R}, T.{n}_encode({OBJE}), {nw}) == {RHS} : {ET}}}:')
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({WS}, {KB}, {KB}, False{{}}, 1), ({WS}, True{{}}),')
    w(f'      AC.vok({depth}n, FD.TNode{{{U}, q}}, {KB}, {KB}, {KB}, False{{}}, 1, {{==}}, {{==}}, {{==}}, {{==}}, {pUQ})) :')
    w(f'    {{{wrap(f"{first}_pk(O.out_at({depth}n), (0 + 0 : U32), _)")} == {RHS} : {ET}}}')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({H}, 0, 0, Array.new(U32, {depth}n, 0), ANode{{{th(U)}, {th("q")}}}), (ANode{{{th(U)}, Array.new(U32, {p}n, 0)}}, ANode{{{th(U)}, {th("q")}}}),')
    w(f'      AC.zl2n({p}n, {H}, 0, 0, {U}, q, {{==}}, {{==}}, {hk}, {{==}}, {{==}}, {pU}, pq)) :')
    w(f'    {{{wrap(f"{first}_pk_ok(O.put_fin({KB}, O.pw_al_tail(True{{}}, {H}, 0, _)))")} == {RHS} : {ET}}}')
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit({FB_}, 0, {nw}), ({FB_}, F.limbs(FD.spec_common__take(U32, FD.array__slots(U32, {UR}), 1n+{nw - 1}n))),')
    w(f'      AE.emit_take({depth}n, {UR}, {size}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, {pUR})) :')
    w(f'    {{({OBJE}, F.listed(_)) == {RHS} : {ET}}}')
    w('  {==}')
    w('')


def emit_ltail(w, n, node, size, R, lt, pads):
    """Decode and encoder-bytes laws of a container whose first field is a vector of
    W = 2^p + E words (0 < E < 2^p) at offset 0 of a buffer of depth p + 1 (Deposit), as
    emit_lhalf: the buffer's left half a free spine, the right half literal. The field's copy
    is arr_copy.acp then arr_enc.cpt_tail_q (<n>_cps: the spine whole, then the E words of the
    right half into zero storage), the validity check arr_copy.vok, the emitted words
    arr_emit.emit_take; the other fields' reads and writes compute."""
    p, E, rep, unit = lt
    H = 1 << p
    W = H + E
    FB = 4 * W
    nw = size // 4
    depth = p + 1
    TV = 'FD.array__Tree<U32>'
    th = lambda u: f'FD.array__thaw(U32, {u})'
    X, G = node.words[:H], node.words[H:]
    Q = node.opads
    ms = [f'm{j}' for j in range(p)]
    pms = [f'pm{j}' for j in range(p)]
    U = spine('y0', ms)
    pU = spine_pf('y0', ms, pms)
    sp = ('+y0: U32, ' + ', '.join(f'+{m}: {TV}' for m in ms) + ', '
          + ', '.join(f'+pm{j}: {{FD.array__perfect(U32, {j}n, m{j}) == True{{}} : Bool}}' for j in range(p)))
    spa = 'y0, ' + ', '.join(ms) + ', ' + ', '.join(pms)
    cname, rest = top_args(node.dec)
    _, rest_o = top_args(node.obj)
    assert rest[1:] == rest_o[1:], n
    RST = ', '.join(rest[1:])
    M = f'Nat.add(FD.spec_common__pow2({p}n), {E}n)'
    Z = lambda d: f'FD.array__trep(U32, {d}n, 0)'
    vs = lambda xs: ', '.join(f'+{x}: U32' for x in xs)
    # the copy of the field's W words from [spine | r] into zero storage, any perfect r
    CPT = f'AC.cpt({p}n, {E}n, 0n, 0n, {Z(p)}, FD.array__slots(U32, r))'
    SRCr = f'ANode{{{th(U)}, {th("r")}}}'
    RHS = f'({th(f"FD.TNode{{{U}, {CPT}}}")}, {SRCr})'
    ty = lambda a, s_: f'{{O.acopy({W}, 0, 0, {a}, {s_}) == {RHS} : Array<U32> & Array<U32>}}'
    w(f'def {n}_tn(+a: {TV}, +b: {TV}) -> {{{th("FD.TNode{a, b}")} == ANode{{{th("a")}, {th("b")}}} : Array<U32>}}:')
    w('  {==}')
    w(f'# the first field\'s copy from [spine | r]: the spine, then the first {E} words of r (AC.acp, AN.cpt_tail_q)')
    w(f'def {n}_cps({sp}, +r: {TV}, +pr: {{FD.array__perfect(U32, {p}n, r) == True{{}} : Bool}})')
    w(f'    -> {ty(f"Array.new(U32, {depth}n, 0)", SRCr)}:')
    w(f'  %Equal.sym(Array<U32>, Array.new(U32, {depth}n, 0), {th(Z(depth))}, FD.array__new(U32, {depth}n, 0)) : {ty("_", SRCr)}')
    T_ = f'FD.TNode{{{U}, r}}'
    w(f'  %{n}_tn({U}, r) : {ty(th(Z(depth)), "_")}')
    pS = f'FD.logic__and_intro(FD.array__perfect(U32, {p}n, {U}), FD.array__perfect(U32, {p}n, r), {pU}, pr)'
    SL = f'FD.array__slots(U32, {T_})'
    CP = f'({th(f"AC.cpt({depth}n, {M}, 0n, 0n, {Z(depth)}, {SL})")}, {th(T_)})'
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({W}, 0, 0, {th(Z(depth))}, {th(T_)}), {CP},')
    w(f'      AC.acp({W}, {M}, 0, 0, 0n, 0n, {depth}n, {depth}n, {T_}, {Z(depth)}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pS}, FD.array__trep_perfect(U32, {depth}n, 0))) :')
    w(f'    {{_ == {RHS} : Array<U32> & Array<U32>}}')
    AP = f'FD.spec_common__append(U32, FD.array__slots(U32, {U}), FD.array__slots(U32, r))'
    w(f'  %Equal.sym(List<&2, U32>, {SL}, {AP}, AC.slots_node({U}, r)) :')
    w(f'    {{({th(f"AC.cpt({depth}n, {M}, 0n, 0n, {Z(depth)}, _)")}, {th(T_)}) == {RHS} : Array<U32> & Array<U32>}}')
    w(f'  %Equal.sym({TV}, AC.cpt({depth}n, {M}, 0n, 0n, {Z(depth)}, {AP}), FD.TNode{{{U}, {CPT}}},')
    w(f'      AN.cpt_tail_q({p}n, {depth}n, {{==}}, {E}n, {U}, FD.array__slots(U32, r), {pU})) :')
    w(f'    {{({th("_")}, {th(T_)}) == {RHS} : Array<U32> & Array<U32>}}')
    w('  {==}')
    # literal-array bridges
    LX, TX = tree(X), ttree(X)
    Rw = G + pads
    Sr = G[:E] + Q
    w(f'def {n}_lx({vs(X)}) -> {{{th(TX)} == {LX} : Array<U32>}}:')
    w('  {==}')
    w(f'def {n}_lr({vs(Rw)}) -> {{{th(ttree(Rw))} == {tree(Rw)} : Array<U32>}}:')
    w('  {==}')
    w(f'def {n}_lxs({vs(X + Sr)}) -> {{{th(f"FD.TNode{{{TX}, {ttree(Sr)}}}")} == ANode{{{LX}, {tree(Sr)}}} : Array<U32>}}:')
    w('  {==}')
    # decode over the spine and the literal right half
    TR = ttree(Rw)
    SRC = f'ANode{{{th(U)}, {th(TR)}}}'
    BUF = f'B.Buf{{{SRC}, {size}}}'
    CPTR = f'AC.cpt({p}n, {E}n, 0n, 0n, {Z(p)}, FD.array__slots(U32, {TR}))'
    OBJ = f'{cname}{{O.Words{{{th(f"FD.TNode{{{U}, {CPTR}}}")}, {FB}}}, {RST}}}'
    RT = f'B.Buf & Maybe<&1, {R}>'
    w(f'# {n} decoded from [spine | the literal right half]: its first field copied by {n}_cps')
    w(f'def {n}_ltd({sp}, {vs(Rw)})')
    w(f'    -> {{T.{n}_decode({BUF}, {size}) == ({BUF}, Some{{{OBJ}}}) : {RT}}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({W}, 0, 0, Array.new(U32, {depth}n, 0), {SRC}), ({th(f"FD.TNode{{{U}, {CPTR}}}")}, {SRC}),')
    w(f'      {n}_cps({spa}, {TR}, {{==}})) :')
    w(f'    {{T.{n}_some(T.{n}_rd0(0, {size}, O.ci_fin({size}, {FB}, _))) == ({BUF}, Some{{{OBJ}}}) : {RT}}}')
    w('  {==}')
    # encoder bytes: storage [spine | the literal tree of E words and the pads]
    TQR = ttree(Sr)
    WS = f'O.Words{{{th(f"FD.TNode{{{U}, {TQR}}}")}, {FB}}}'
    OBJE = f'{cname}{{{WS}, {RST}}}'
    TRo = ttree(G + ['0'] * (H - len(G)))
    UR = f'FD.TNode{{{U}, {TRo}}}'
    RHSE = f'({OBJE}, F.limbs(FD.spec_common__take(U32, FD.array__slots(U32, {UR}), {nw}n)))'
    ET = f'{R} & +List<U32>'
    wrap = lambda inner: f'F.emitted({R}, T.{n}_enc_out(T.{n}_put_drop(T.{n}_pw0(0, 0, {RST}, {inner}))), {nw})'
    pUQ = f'FD.logic__and_intro(FD.array__perfect(U32, {p}n, {U}), FD.array__perfect(U32, {p}n, {TQR}), {pU}, {{==}})'
    pUR = f'FD.logic__and_intro(FD.array__perfect(U32, {p}n, {U}), FD.array__perfect(U32, {p}n, {TRo}), {pU}, {{==}})'
    FB_ = f'B.Buf{{{th(UR)}, {size}}}'
    SRCQ = f'ANode{{{th(U)}, {th(TQR)}}}'
    CPTQ = f'AC.cpt({p}n, {E}n, 0n, 0n, {Z(p)}, FD.array__slots(U32, {TQR}))'
    w(f'# {n}\'s encoder: the first field\'s storage [spine | {E} words and pads] copied ({n}_cps), the rest written')
    w(f'def {n}_ltb({sp}, {vs(Sr + G[E:])})')
    w(f'    -> {{F.emitted({R}, T.{n}_encode({OBJE}), {nw}) == {RHSE} : {ET}}}:')
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({WS}, {FB}, {FB}, False{{}}, {unit}), ({WS}, True{{}}),')
    w(f'      AC.vok({depth}n, FD.TNode{{{U}, {TQR}}}, {FB}, {FB}, {FB}, False{{}}, {unit}, {{==}}, {{==}}, {{==}}, {{==}}, {pUQ})) :')
    w(f'    {{{wrap(f"T.{rep}_pk(O.out_at({depth}n), (0 + 0 : U32), _)")} == {RHSE} : {ET}}}')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({W}, 0, 0, Array.new(U32, {depth}n, 0), {SRCQ}), ({th(f"FD.TNode{{{U}, {CPTQ}}}")}, {SRCQ}),')
    w(f'      {n}_cps({spa}, {TQR}, {{==}})) :')
    w(f'    {{{wrap(f"T.{rep}_pk_ok(O.put_fin({FB}, O.pw_al_tail(True{{}}, {W}, 0, _)))")} == {RHSE} : {ET}}}')
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit({FB_}, 0, {nw}), ({FB_}, F.limbs(FD.spec_common__take(U32, FD.array__slots(U32, {UR}), 1n+{nw - 1}n))),')
    w(f'      AE.emit_take({depth}n, {UR}, {size}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, {pUR})) :')
    w(f'    {{({OBJE}, F.listed(_)) == {RHSE} : {ET}}}')
    w('  {==}')
    w('')


def emit_pow2(w, n, t, node, size, R, P, p):
    """The literal laws of a 2^p-word byte vector (statements as emit_name's), from the
    tree forms at the tree of the words: `<n>_lx` / `<n>_lxq` rewrite the literal arrays
    to thaws of trees (a constructor-by-constructor conversion) first."""
    nw = 1 << p
    xs, qs = node.words, node.opads
    assert len(xs) == nw and len(qs) == nw, n
    sig = ', '.join(f'+{v}: U32' for v in xs)
    qsig = ', '.join(f'+{v}: U32' for v in qs)
    args, qargs = ', '.join(xs), ', '.join(qs)
    L = f'F.limbs({wl(xs)})'
    LX, LQ = tree(xs), tree(qs)
    TX, TQ = ttree(xs), ttree(qs)
    thx, thq = f'FD.array__thaw(U32, {TX})', f'FD.array__thaw(U32, {TQ})'
    pow2_trees(w, n, p, size, R)
    w(f'def {n}_lx({sig}) -> {{{thx} == {LX} : Array<U32>}}:')
    w('  {==}')
    w(f'def {n}_lxq({sig}, {qsig}) -> {{ANode{{{thx}, {thq}}} == ANode{{{LX}, {LQ}}} : Array<U32>}}:')
    w('  {==}')
    obj = f'O.Words{{ANode{{{LX}, {LQ}}}, {size}}}'
    objp = f'O.Words{{_, {size}}}'
    w(f'def {n}_spec_bytes({sig}, {qsig})')
    w(f'    -> {{F.emitted(O.Words, T.{n}_encode({obj}), {nw}) == ({obj}, {L}) : O.Words & +List<U32>}}:')
    w(f'  %{n}_lxq({args}, {qargs}) :')
    w(f'    {{F.emitted(O.Words, T.{n}_encode({objp}), {nw}) == ({objp}, {L}) : O.Words & +List<U32>}}')
    w(f'  {n}_tb({TX}, {TQ}, {{==}}, {{==}})')
    w(f'def {n}_spec_parts({sig})')
    w(f'    -> {{Codec.parts({node.val}, Spec.{n}()) == Some{{[S.Fixed{{{L}}}]}} : Maybe<&2, +List<S.Part>>}}:')
    w(f'  %Equal.sym(S.Schema, Spec.{n}(), {node.sch}, {{==}}) :')
    w(f'    {{Codec.parts({node.val}, _) == Some{{[S.Fixed{{{L}}}]}} : Maybe<&2, +List<S.Part>>}}')
    w(f'  {node.proof}')
    w(f'def {n}_spec_encode({sig})')
    w(f'    -> Decoding.decodes(Spec.{n}(), {L}, {node.val}):')
    w(f'  F.encoding_of_parts(Spec.{n}(), {node.val}, {L}, {n}_spec_parts({args}))')
    buf = f'B.Buf{{{LX}, {size}}}'
    bufp = f'B.Buf{{_, {size}}}'
    w(f'def {n}_spec_decode({sig})')
    w(f'    -> {{T.{n}_decode({buf}, {size}) == ({buf}, Some{{{node.dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    assert node.dec == f'O.Words{{{tree(xs + ["0"] * nw)}, {size}}}', n
    w(f'  %{n}_lx({args}) :')
    w(f'    {{T.{n}_decode({bufp}, {size}) == ({bufp}, Some{{O.Words{{ANode{{_, {tree(["0"] * nw)}}}, {size}}}}}) : B.Buf & Maybe<&1, {R}>}}')
    w(f'  {n}_td({TX}, {{==}})')
    w(f'def {n}_spec_view({sig})')
    w(f'    -> {{B.emit({buf}, 0, {nw}) == ({buf}, {L}) : B.Buf & +List<U32>}}:')
    w(f'  %{n}_lx({args}) :')
    w(f'    {{B.emit({bufp}, 0, {nw}) == ({bufp}, {L}) : B.Buf & +List<U32>}}')
    w(f'  {n}_tv({TX}, {{==}})')
    w(f'def {n}_spec_reject(buf: B.Buf, +m: U32, e: {{U32.is_eq(m, {size}) == False{{}} : Bool}})')
    w(f'    -> {{T.{n}_decode(buf, m) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(Bool, U32.is_eq(m, {size}), False{{}}, e) : '
      f'{{T.{n}_built(m, T.{P}_ok_len(_, buf, 0)) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}')
    w('  {==}')


def emit_unique(w, n, node, k, legal=None):
    sig = ', '.join(f'+{v}: U32' for v in node.words)
    args = ', '.join(node.words)
    L = f'F.limbs({wl(node.words)})'
    # the validator's acceptance of the name's schema by evaluation, through
    # decode_unique.valid_unique (decode_complete.image_unique's type_legal form
    # imports the compatibility_* chain for public_complete, and the legality
    # witnesses a module of every name: ~4 s per importer)
    w(f'def {n}_spec_unique({sig}, +v: S.Value, spec: Decoding.decodes(Spec.{n}(), {L}, v))')
    w(f'    -> {{v == {node.val} : S.Value}}:')
    w(f'  E.valid_unique(Spec.{n}(), {L}, v, {node.val}, {{==}}, spec, '
      f'C{k}.{n}_spec_encode({args}))')


HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
        'import ../../types/primitive.bend as P', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ./spec_fixed.bend as F', 'import ./spec_bits.bend as FB', '']


def family(out, chosen, g, src, tag, head, rhead, uimports, legal=None):
    """The aligned laws of `chosen`, one module per name and law family:
    proofs/obj/spec_{tag}codec_<N>.bend (and spec_{tag}repr_<N>, spec_{tag}load_<N>,
    spec_{tag}input_<N>, spec_{tag}unique_<N>); `tag` is '' for the Fulu names, 'g' for
    the generic forms. Bend re-checks every import, so a module per name makes each
    importer (the API facades, the gate, e2e) pay for its own name only (spec_codec_6
    bundled Cell and MatrixEntry: 20 s for every facade of the seven names it held)."""
    for n, t, node in chosen:
        size = t.fixed_size()
        R = LW.qual(g.shape(t).rep)
        p2 = pow2_words(t, g)
        assert p2 is None or not g.shape(t).data, n
        lh = lhalf(t, g, node)
        lt = None if lh is not None or p2 is not None else ltail(t, g, node)
        tv = size // 4 >= VIEW_MIN
        lines = list(head[:-1]) + (POW2_IMPORTS if p2 is not None or lh is not None or tv or lt is not None else []) + \
            (['import ./arr_enc.bend as AN'] if lt is not None else []) + [''] + [
            '# GENERATED by codegen/spec_laws.py. Do not edit.',
            f'# Spec-connected codec laws of {n}: the emitted bytes, their relation to the',
            '# object value in the independent spec/codec.bend, acceptance of every buffer',
            '# of the size, and rejection of every other size.', '']
        w = lines.append
        w(f'# ---- {n} ({size} bytes) ----')
        emit_name(w, n, t, node, size, R, okname(src, n), g.shape(t).data, p2, lh, lt)
        w('')
        out[ROOT / f'proofs/obj/spec_{tag}codec_{n}.bend'] = '\n'.join(lines) + '\n'
        rl = rhead + [REPR_SEG, f'import ./spec_{tag}codec_{n}.bend as C', '',
                      '# GENERATED by codegen/spec_laws.py. Do not edit.',
                      f'# The decode and view laws of spec_{tag}codec_{n}.bend for EVERY perfect buffer',
                      '# tree of the depth the loader allocates, not only the literal tree.', '']
        emit_repr(rl.append, n, node, size, R)
        rl.append('')
        out[ROOT / f'proofs/obj/spec_{tag}repr_{n}.bend'] = '\n'.join(rl) + '\n'
        out[ROOT / f'proofs/obj/spec_{tag}load_{n}.bend'] = load_sizes({size})
        il = rhead + [f'import ./spec_{tag}load_{n}.bend as LD', f'import ./spec_{tag}codec_{n}.bend as C', '',
                      '# GENERATED by codegen/spec_laws.py. Do not edit.',
                      f'# The decode law of spec_{tag}codec_{n}.bend on the buffer the real loader builds',
                      '# (B.fill_at(B.alloc(n), 0, bytes), benchmarks/compact/objio.bend) from the',
                      '# bytes limbs(words) - every byte list of the size.', '']
        emit_input(il.append, n, node, size, R)
        il.append('')
        out[ROOT / f'proofs/obj/spec_{tag}input_{n}.bend'] = '\n'.join(il) + '\n'
        ul = list(uimports) + [f'import ./spec_{tag}codec_{n}.bend as C0', '',
                               '# GENERATED by codegen/spec_laws.py. Do not edit.',
                               '# Completeness of the decoder\'s answer: every value the independent spec relates',
                               '# to the bytes of a buffer is the value of the object the decoder returns for it',
                               '# (decode_unique.valid_unique: decode_complete.image_unique, which END_TO_END.deserialize_unique', '# is, from the validator\'s acceptance of the schema).', '']
        emit_unique(ul.append, n, node, 0, legal)
        out[ROOT / f'proofs/obj/spec_{tag}unique_{n}.bend'] = '\n'.join(ul) + '\n'
    return len(chosen), len(chosen)


def main():
    global EXACT
    EXACT = True
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    src = RR.mono_text('fulu')
    chosen, skipped = [], {}
    for n, t in names.items():
        if not (t.fixed() and LW.word_aligned(t)):
            continue
        try:
            node = walk(g, t, iter(range(10000)))
        except Skip as e:
            skipped[n] = str(e)
            continue
        chosen.append((n, t, node))
    out = {ROOT / 'proofs/obj/spec_bits.bend': bits_module(), ROOT / 'proofs/obj/spec_small.bend': small_module(src),
           ROOT / 'proofs/obj/spec_unique_small.bend': unique_small(),
           ROOT / 'proofs/obj/spec_repr_small.bend': repr_small()}
    UIMP = ['import Base', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
            'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/fulu_schemas.bend as Spec',
            'import ../decode_unique.bend as E', 'import ./spec_fixed.bend as F', 'import ./spec_bits.bend as FB']
    nchunks, nuchunks = family(out, chosen, g, src, '', HEAD, REPR_HEAD, UIMP)
    # the generic forms whose encoding is whole words at aligned positions
    gnames = RG.generic_names()
    gg = G.Gen()
    for n, t in gnames.items():
        gg.shape(t)
    gsrc = RR.mono_text('generic')
    gchosen = []
    for n, t in gnames.items():
        if not (t.fixed() and LW.word_aligned(t)):
            continue
        try:
            gchosen.append((n, t, walk(gg, t, iter(range(10000)))))
        except Skip:
            continue
    swap = lambda xs: [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T')
                        .replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
                        .replace('import ../../proofs/fulu_legality.bend as Legal', 'import ../type_validator_soundness.bend as VS') for x in xs]
    gn, gu = family(out, gchosen, gg, gsrc, 'g', swap(HEAD), swap(REPR_HEAD), swap(UIMP))
    out[ROOT / 'proofs/obj/load_words.bend'] = load_words()
    arr_out, arr_names = SA.outputs(ROOT)
    global VLCT
    VLCT = True   # spec_rec_Validator: the exact one-step parts (VLCT above)
    vt, vu = validator_module(src)
    VLCT = False
    arr_out[ROOT / 'proofs/obj/spec_rec_Validator.bend'] = vt
    arr_out[ROOT / 'proofs/obj/spec_rec_unique_Validator.bend'] = vu
    arr_out[ROOT / 'proofs/obj/word_mul.bend'] = (ROOT / 'codegen/word_mul.bend.in').read_text()
    arr_names = arr_names + ['Validator']
    out.update(arr_out)
    out.update(AL.outputs())
    out.update(SANY.outputs(ROOT, out)[0])
    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('spec_*_*.bend') if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, text in out.items() if not p.exists() or p.read_text() != text]
        if stale or orphans:
            print('stale generated spec laws: ' + ', '.join(stale + orphans))
            sys.exit(1)
        print('generated spec laws are current')
        return
    for q in orphans:
        (ROOT / q).unlink()
    for p, text in out.items():
        p.write_text(text)
    print(f'{nchunks} per-name spec-codec module sets over {len(chosen)} names; '
          f'{gn} per-name generic module sets; '
          f'array-backed (proofs/obj/spec_arr_*.bend): {", ".join(arr_names)}; '
          f'not covered: ' + ', '.join(f'{n} ({why})' for n, why in skipped.items() if n not in arr_names))


if __name__ == '__main__':
    main()
