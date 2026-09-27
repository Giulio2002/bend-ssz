#!/usr/bin/env python3
"""The object API against END_TO_END's model API, name by name.

    python3 codegen/e2e_bridge.py [--check]

END_TO_END.bend proves its frozen laws about the list-based model API (src/model.bend:
API.serialize, API.deserialize, API.hash_tree_root) for every schema. The object API
(types/fulu_obj.bend, types/generic_obj.bend) has per-name laws against the independent
specification (proofs/gate/api_map.json). This generator states, for every name X of the object
API whose laws have the needed form, one uniform law per operation that ties the two APIs, with
VAL(o) = the view of the object that its root law uses (v_X of its root module):

  (i)  <R>_e2e_encode(+o)   {Some{E.obytes(T.X_encode(o))} == API.serialize(Spec.X(), VAL(o))}
  (iv) <R>_e2e_root(h, +o)  {Some{D.bytes(Pair.snd(B.Buf, D.Digest, T.X_hash_tree_root(h, o)))}
                             == API.hash_tree_root(Spec.X(), VAL(o))}

and, over a byte list bs with its U32 size n (hn: |bs| = to_nat(n)) that is in the byte domain
(hd: SP.bytes_domain(bs); the decoder only sees bytes), with IN(bs) = B.fill_at(B.alloc(n), 0, bs):

  (ii)  <R>_e2e_decode_accept(bs, n, o, hn, hd)
        Pair.snd(T.X_decode(IN(bs), n)) == Some{o}  <->  API.deserialize(Spec.X(), bs) == Some{VAL(o)}
  (iii) <R>_e2e_decode_reject(bs, n, hn, hd)
        Pair.snd(T.X_decode(IN(bs), n)) == None     <->  API.deserialize(Spec.X(), bs) == None

(ii)/(iii) use e2e/e2e_bytes.bend: a byte list of 4 k bytes is the limbs of the k words the loader
packs it into (pk, from lwb: I.limb(B.word_of(a, b, c, d)) == [a, b, c, d] for bytes), sizes as
U32 byte counts, and END_TO_END's spec_accepted / accepted_spec / deserialize_rejection_correct;
per name its decode_input, decode_none, decode_reject and encode_spec laws (fixed-size forms).

E.obytes (e2e/e2e_support.bend) is the bytes the object API writes for a buffer (B.emit over its
words, cut at its size). Each law is discharged by END_TO_END's serialize_correct /
hash_tree_root_correct (at the legality of Spec.X() from the checked validator,
type_validator_soundness.public_sound) and the name's own laws: encode_eval (the encoder's
emitted bytes), encode_spec (their spec decoding), root (the root relation) and its view's
structural validity (rv_X).

Families (the forms of the name's laws), and what is written for each:
  A  encode_eval  {B.emit(T.X_encode(OBJ), 0, K) == (T.X_encode(OBJ), BYTES)} over free words
     or bits, encode_spec  decodes(Spec.X(), BYTES, VALUE) over the same variables, root
     RR.roots(v_X(o), Spec.X(), [..T.X_hash_tree_root(h, o)..]) over every o, and rv_X:
     (i) and (iv).
Every other name is listed in e2e/manifest.json with the reason it is not covered yet.

Files: e2e/<Name>_e2e_generated.bend ((i) and (iv)) and e2e/<Name>_e2e_dec_generated.bend ((ii)
and (iii)), each a batch named after its first name of names sharing proving modules (a module at the
top level, one directory down, so END_TO_END's imports and the proving modules' resolve
together), and e2e/manifest.json. Batches keep each file's check within 60 s / 8 GB.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
OBJ = ROOT / 'proofs/obj'
OUT = ROOT / 'e2e'
MB = 'Maybe<&2, +List<U32>>'
BATCH = 3  # names per file: the imports dominate (END_TO_END, the root module with zero_roots' 63
# SHA-256 evaluations, a spec module: ~50 s), each name adds about a second

# views (the root law's v_X) that do not convert to encode_spec's value by evaluation: a bit
# vector's view is its words' wbits, the spec value spec_bits.bitsof of the words (a lemma per
# shape is needed)
WRBATCH = 8  # word-storage root files (root_gtypes' import is the floor)
WBATCH = 3  # word-storage files (import floor as family A)
DBATCH = 3  # decode files: the same imports plus the decode laws' modules
DWORDS = 36  # and at most this many words in a file (a name's decode proof grows with its words)

VIEW_TODO = set()  # (the bit vectors are bridged by e2e_bits.bw)

import api_gate as AG  # noqa: E402

HEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API',
        'import ../src/buffer.bend as B', 'import ../src/digest.bend as D', 'import ../src/obj.bend as O',
        'import ../types/fulu_obj.bend as T', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
        'import ../spec/fulu_schemas.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS',
        'import ../spec/codec.bend as Encoding', 'import ../spec/primitives.bend as SP',
        'import ../proofs/obj/spec_fixed.bend as F', 'import ./e2e_support.bend as E']

SUPPORT = '''import Base
import ../END_TO_END.bend as E2E
import ../src/model.bend as API
import ../src/buffer.bend as B
import ../types/schema.bend as S
import ../spec/codec.bend as Encoding
import ../spec/type_legality.bend as Legal
import ../spec/root_relation.bend as Roots
import ../spec/value_domain.bend as Domain
import ../spec/primitives.bend as Bytes

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# The bytes the object API writes for a buffer, and END_TO_END's laws at a legal schema.

# B.emit over the buffer's words, cut at its size: what the object API's output path writes.
def obytes(b: B.Buf) -> +List<U32>:
  match b:
    case B.Buf{ws, +n}: Pair.snd(B.Buf, +List<U32>, B.emit(B.Buf{ws, n}, 0, U32.shrn((n + 3 : U32), 2n)))

# END_TO_END.serialize_correct at a legal schema.
def ser_legal(+schema: S.Schema, +value: S.Value,
    pr: (Legal.type_legal(schema) -> {API.serialize(schema, value) == Encoding.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}) & ((Legal.type_legal(schema) -> Empty) -> {API.serialize(schema, value) == None{} : Maybe<&2, +List<U32>>}),
    legal: Legal.type_legal(schema)) -> {API.serialize(schema, value) == Encoding.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}:
  (a, b) = pr
  a(legal)

def serialize_legal(+schema: S.Schema, +value: S.Value, legal: Legal.type_legal(schema))
    -> {API.serialize(schema, value) == Encoding.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}:
  ser_legal(schema, value, E2E.serialize_correct(schema, value), legal)

# END_TO_END.hash_tree_root_correct at a legal schema and a related root.
def htr_legal(+schema: S.Schema, +value: S.Value,
    pr: (@+root: +List<U32> -> @+accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} -> Legal.type_legal(schema) & Roots.root_for_legal_type(schema, value, root) & {Bytes.byte_scope(32n, root) == True{} : Bool}) & (Legal.type_legal(schema) -> @+root: +List<U32> -> Roots.root_for_legal_type(schema, value, root) -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}) & (Legal.type_legal(schema) -> {Domain.root_domain(schema, value) == True{} : Bool} -> Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})),
    legal: Legal.type_legal(schema), +root: +List<U32>, rel: Roots.root_for_legal_type(schema, value, root)) -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}:
  (a, bc) = pr
  (b, c) = bc
  b(legal, root, rel)

def root_legal(+schema: S.Schema, +value: S.Value, legal: Legal.type_legal(schema), +root: +List<U32>,
    +valid: {Domain.root_valid(value, schema) == True{} : Bool}, rel: Roots.roots(value, schema, [root]))
    -> {Some{root} == API.hash_tree_root(schema, value) : Maybe<&2, +List<U32>>}:
  Equal.sym(Maybe<&2, +List<U32>>, API.hash_tree_root(schema, value), Some{root},
    htr_legal(schema, value, E2E.hash_tree_root_correct(schema, value), legal, root, (valid, rel)))
'''



# ---- decoding support (e2e/e2e_bytes.bend) ----

BYTES_HEAD = '''import Base
import ../END_TO_END.bend as E2E
import ../src/model.bend as API
import ../src/buffer.bend as B
import ../src/primitives.bend as I
import ../types/schema.bend as S
import ../spec/decoding_relation.bend as Decoding
import ../spec/type_legality.bend as Legal
import ../spec/primitives.bend as SP
import ../proofs/power_division.bend as PD
import ../proofs/word_split.bend as WSp
import ../proofs/integer_decoding.bend as ID
import ../proofs/compact/bits.bend as BT
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/u32_order.bend as UO
import ../proofs/primitive_invariants.bend as V
import ../proofs/obj/spec_fixed.bend as F

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# Decoding support: a byte list as the words the object API's loader packs it into, sizes as
# U32 byte counts, and END_TO_END's deserialize laws at a schema.

'''

# the bits of I.limb(B.word_of(..)) of four symbolic bytes, as the checker evaluates them:
# limb j, bit i reads byte j + i / 8 through 3 - (j + i / 8) Bool.or(_, False)s
def core(k, x):
    t = f'Bool.and({x}, True{{}})'
    for _ in range(3 - k):
        t = f'Bool.or({t}, False{{}})'
    return t
def word(bits): return ''.join(f'WCon{{{b}, ' for b in bits) + 'WNil{}' + '}' * len(bits)
def lwb_text():
    L=[]
    for k in range(4):
        for tag, c, rhs in (('t', 'True{}', 'x'), ('f', 'False{}', 'False{}')):
            L.append(f'def fx{tag}{k}(+x: Bool) -> {{Bool.and({core(k, "x")}, {c}) == {rhs} : Bool}}:\n  match x:\n    case True{{}}: {{==}}\n    case False{{}}: {{==}}\n')
    L.append(f'def fx3(+x: Bool) -> {{{core(3, "x")} == x : Bool}}:\n  match x:\n    case True{{}}: {{==}}\n    case False{{}}: {{==}}\n')
    V=['a','b','c','d']
    lhs=[]; proofs=[]; tgt=[]
    for j in range(4):
        xs=[];ys=[];es=[]
        for i in range(32):
            k=j+i//8
            if k>3:
                xs.append('False{}'); ys.append('False{}'); es.append('{==}'); continue
            v=f'{V[k]}{i%8}'
            if j==3:
                xs.append(core(3,v)); ys.append(v if i<8 else 'False{}'); es.append(f'fx3({v})')
            elif i<8:
                xs.append(f'Bool.and({core(k,v)}, True{{}})'); ys.append(v); es.append(f'fxt{k}({v})')
            else:
                xs.append(f'Bool.and({core(k,v)}, False{{}})'); ys.append('False{}'); es.append(f'fxf{k}({v})')
        proofs.append(f'BT.word32_eq({", ".join(xs)}, {", ".join(ys)}, {", ".join(es)})')
        lhs.append(f'U32{{{word(xs)}}}'); tgt.append(f'U32{{{word(ys)}}}')
    L.append('''def l4eq(+p0: U32, +p1: U32, +p2: U32, +p3: U32, +q0: U32, +q1: U32, +q2: U32, +q3: U32,
    +e0: {p0 == q0 : U32}, +e1: {p1 == q1 : U32}, +e2: {p2 == q2 : U32}, +e3: {p3 == q3 : U32}) -> {[p0, p1, p2, p3] == [q0, q1, q2, q3] : +List<U32>}:
  %e0 : {[p0, p1, p2, p3] == [_, q1, q2, q3] : +List<U32>}
  %e1 : {[p0, p1, p2, p3] == [p0, _, q2, q3] : +List<U32>}
  %e2 : {[p0, p1, p2, p3] == [p0, p1, _, q3] : +List<U32>}
  %e3 : {[p0, p1, p2, p3] == [p0, p1, p2, _] : +List<U32>}
  {==}
''')
    def P(v): return ''.join(f'WCon{{+{v}{i}, ' for i in range(8))+'WNil{}'+'}'*8
    L.append('# The four bytes of the word of four bytes are those bytes (bits of each byte symbolic).')
    L.append('def lwb8(+wa: Word(8n), +wb: Word(8n), +wc: Word(8n), +wd: Word(8n)) -> {I.limb(B.word_of(PD.embed8(wa), PD.embed8(wb), PD.embed8(wc), PD.embed8(wd))) == [PD.embed8(wa), PD.embed8(wb), PD.embed8(wc), PD.embed8(wd)] : +List<U32>}:')
    L.append('  match wa wb wc wd:')
    L.append(f'    case {P("a")} {P("b")} {P("c")} {P("d")}:')
    L.append(f'      l4eq({", ".join(lhs)}, {", ".join(tgt)},')
    L.append('        ' + ',\n        '.join(proofs) + ')')
    return '\n'.join(L)+'\n'


BYTES_TAIL = r'''# The four bytes of the word of four bytes (U32s below 256) are those bytes.
def lwb(+a: U32, +b: U32, +c: U32, +d: U32, +ea: {U32.is_lt(a, 256) == True{} : Bool}, +eb: {U32.is_lt(b, 256) == True{} : Bool},
    +ec: {U32.is_lt(c, 256) == True{} : Bool}, +ed: {U32.is_lt(d, 256) == True{} : Bool}) -> {I.limb(B.word_of(a, b, c, d)) == [a, b, c, d] : +List<U32>}:
  %Equal.sym(U32, a, PD.embed8(WSp.take(8n, 32n, PD.bits(a))), ID.byte_shape(a, ea)) :
    {I.limb(B.word_of(_, b, c, d)) == [_, b, c, d] : +List<U32>}
  %Equal.sym(U32, b, PD.embed8(WSp.take(8n, 32n, PD.bits(b))), ID.byte_shape(b, eb)) :
    {I.limb(B.word_of(PD.embed8(WSp.take(8n, 32n, PD.bits(a))), _, c, d)) == [PD.embed8(WSp.take(8n, 32n, PD.bits(a))), _, c, d] : +List<U32>}
  %Equal.sym(U32, c, PD.embed8(WSp.take(8n, 32n, PD.bits(c))), ID.byte_shape(c, ec)) :
    {I.limb(B.word_of(PD.embed8(WSp.take(8n, 32n, PD.bits(a))), PD.embed8(WSp.take(8n, 32n, PD.bits(b))), _, d)) == [PD.embed8(WSp.take(8n, 32n, PD.bits(a))), PD.embed8(WSp.take(8n, 32n, PD.bits(b))), _, d] : +List<U32>}
  %Equal.sym(U32, d, PD.embed8(WSp.take(8n, 32n, PD.bits(d))), ID.byte_shape(d, ed)) :
    {I.limb(B.word_of(PD.embed8(WSp.take(8n, 32n, PD.bits(a))), PD.embed8(WSp.take(8n, 32n, PD.bits(b))), PD.embed8(WSp.take(8n, 32n, PD.bits(c))), _)) == [PD.embed8(WSp.take(8n, 32n, PD.bits(a))), PD.embed8(WSp.take(8n, 32n, PD.bits(b))), PD.embed8(WSp.take(8n, 32n, PD.bits(c))), _] : +List<U32>}
  lwb8(WSp.take(8n, 32n, PD.bits(a)), WSp.take(8n, 32n, PD.bits(b)), WSp.take(8n, 32n, PD.bits(c)), WSp.take(8n, 32n, PD.bits(d)))

# ---- a byte list as the words the loader packs it into ----

def hd(+bs: +List<U32>) -> U32:
  match bs:
    case Nil{}: 0
    case Con{h, t}: h

def tl(+bs: +List<U32>) -> +List<U32>:
  match bs:
    case Nil{}: []
    case Con{h, t}: t

# k words of a byte list, four bytes each (B.word_of, as B.fill_go packs them).
def wl(k: Nat, +bs: +List<U32>) -> +List<U32>:
  match k:
    case 0n: []
    case 1n+p: B.word_of(hd(bs), hd(tl(bs)), hd(tl(tl(bs))), hd(tl(tl(tl(bs))))) <> wl(p, tl(tl(tl(tl(bs)))))

# Word i of a byte list (wl(k, bs) is [wn(0n, bs), .., wn(k - 1, bs)] by evaluation).
def wn(i: Nat, +bs: +List<U32>) -> U32:
  match i:
    case 0n: B.word_of(hd(bs), hd(tl(bs)), hd(tl(tl(bs))), hd(tl(tl(tl(bs)))))
    case 1n+p: wn(p, tl(tl(tl(tl(bs)))))

def pk0(+bs: +List<U32>, +hl: {List.length(&2, U32, bs) == 0n : Nat}) -> {F.limbs(wl(0n, bs)) == bs : +List<U32>}:
  match bs:
    case Nil{}: {==}
    case Con{+x, +t}: Empty.absurd({F.limbs(wl(0n, Con{x, t})) == Con{x, t} : +List<U32>}, FD.nat__succ_zero(List.length(&2, U32, t), hl))

def pk5(+p: Nat, +a: U32, +b: U32, +c: U32, +d: U32, +r: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, Con{c, Con{d, r}}}}) == True{} : Bool},
    +hl: {List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}) == A.quad(1n+p) : Nat},
    ih: @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hlr: {List.length(&2, U32, r) == A.quad(p) : Nat} -> {F.limbs(wl(p, r)) == r : +List<U32>}) -> {F.limbs(wl(1n+p, Con{a, Con{b, Con{c, Con{d, r}}}})) == Con{a, Con{b, Con{c, Con{d, r}}}} : +List<U32>}:
  +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Con{d, r}}}), hd)
  +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Con{d, r}}}), hd)
  +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Con{d, r}}), h1)
  +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Con{d, r}}), h1)
  +ec = V.and_left(U32.is_lt(c, 256), SP.bytes_domain(Con{d, r}), h2)
  +h3 = V.and_right(U32.is_lt(c, 256), SP.bytes_domain(Con{d, r}), h2)
  +ed = V.and_left(U32.is_lt(d, 256), SP.bytes_domain(r), h3)
  +hr = V.and_right(U32.is_lt(d, 256), SP.bytes_domain(r), h3)
  +hlr = FD.nat__succ_inj(List.length(&2, U32, r), A.quad(p), FD.nat__succ_inj(1n+List.length(&2, U32, r), 1n+A.quad(p),
    FD.nat__succ_inj(2n+List.length(&2, U32, r), 2n+A.quad(p), FD.nat__succ_inj(3n+List.length(&2, U32, r), 3n+A.quad(p), hl))))
  %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, c, d)), [a, b, c, d], lwb(a, b, c, d, ea, eb, ec, ed)) :
    {List.append(&2, U32, _, F.limbs(wl(p, r))) == Con{a, Con{b, Con{c, Con{d, r}}}} : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, [a, b, c, d], z), F.limbs(wl(p, r)), r, ih(r, hr, hlr))

def pk4(+p: Nat, +a: U32, +b: U32, +c: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, Con{c, t}}}) == True{} : Bool},
    +hl: {List.length(&2, U32, Con{a, Con{b, Con{c, t}}}) == A.quad(1n+p) : Nat},
    ih: @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hlr: {List.length(&2, U32, r) == A.quad(p) : Nat} -> {F.limbs(wl(p, r)) == r : +List<U32>}) -> {F.limbs(wl(1n+p, Con{a, Con{b, Con{c, t}}})) == Con{a, Con{b, Con{c, t}}} : +List<U32>}:
  match t:
    case Nil{}: Empty.absurd({F.limbs(wl(1n+p, [a, b, c])) == [a, b, c] : +List<U32>}, FD.nat__zero_succ(A.quad(p), FD.nat__succ_inj(0n, 1n+A.quad(p), FD.nat__succ_inj(1n, 2n+A.quad(p), FD.nat__succ_inj(2n, 3n+A.quad(p), hl)))))
    case Con{+d, +r}: pk5(p, a, b, c, d, r, hd, hl, ih)

def pk3(+p: Nat, +a: U32, +b: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, t}}) == True{} : Bool},
    +hl: {List.length(&2, U32, Con{a, Con{b, t}}) == A.quad(1n+p) : Nat},
    ih: @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hlr: {List.length(&2, U32, r) == A.quad(p) : Nat} -> {F.limbs(wl(p, r)) == r : +List<U32>}) -> {F.limbs(wl(1n+p, Con{a, Con{b, t}})) == Con{a, Con{b, t}} : +List<U32>}:
  match t:
    case Nil{}: Empty.absurd({F.limbs(wl(1n+p, [a, b])) == [a, b] : +List<U32>}, FD.nat__zero_succ(1n+A.quad(p), FD.nat__succ_inj(0n, 2n+A.quad(p), FD.nat__succ_inj(1n, 3n+A.quad(p), hl))))
    case Con{+c, +r}: pk4(p, a, b, c, r, hd, hl, ih)

def pk2(+p: Nat, +a: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, t}) == True{} : Bool},
    +hl: {List.length(&2, U32, Con{a, t}) == A.quad(1n+p) : Nat},
    ih: @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hlr: {List.length(&2, U32, r) == A.quad(p) : Nat} -> {F.limbs(wl(p, r)) == r : +List<U32>}) -> {F.limbs(wl(1n+p, Con{a, t})) == Con{a, t} : +List<U32>}:
  match t:
    case Nil{}: Empty.absurd({F.limbs(wl(1n+p, [a])) == [a] : +List<U32>}, FD.nat__zero_succ(2n+A.quad(p), FD.nat__succ_inj(0n, 3n+A.quad(p), hl)))
    case Con{+b, +r}: pk3(p, a, b, r, hd, hl, ih)

def pk1(+p: Nat, +bs: +List<U32>, +hd: {SP.bytes_domain(bs) == True{} : Bool},
    +hl: {List.length(&2, U32, bs) == A.quad(1n+p) : Nat},
    ih: @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hlr: {List.length(&2, U32, r) == A.quad(p) : Nat} -> {F.limbs(wl(p, r)) == r : +List<U32>}) -> {F.limbs(wl(1n+p, bs)) == bs : +List<U32>}:
  match bs:
    case Nil{}: Empty.absurd({F.limbs(wl(1n+p, [])) == [] : +List<U32>}, FD.nat__zero_succ(3n+A.quad(p), hl))
    case Con{+a, +t}: pk2(p, a, t, hd, hl, ih)

# A byte list of 4 k bytes is the limbs of its k packed words.
def pk(+k: Nat, +bs: +List<U32>, +hd: {SP.bytes_domain(bs) == True{} : Bool},
    +hl: {List.length(&2, U32, bs) == A.quad(k) : Nat}) -> {F.limbs(wl(k, bs)) == bs : +List<U32>}:
  match k:
    case 0n: pk0(bs, hl)
    case 1n+ +p: pk1(p, bs, hd, hl, r => hr => hlr => pk(p, r, hr, hlr))

# ---- sizes: the U32 byte count of a list ----

def ueq_false(+n: U32, +L: Nat, +K: U32, +hn: {L == U32.to_nat(n) : Nat}, +e: {Nat.is_eq(L, U32.to_nat(K)) == False{} : Bool})
    -> {U32.is_eq(n, K) == False{} : Bool}:
  %Equal.sym(Cmp, U32.cmp(n, K), Nat.cmp(U32.to_nat(n), U32.to_nat(K)), UO.u32_compare(n, K)) : {Cmp.is_eq(_) == False{} : Bool}
  %hn : {Cmp.is_eq(Nat.cmp(_, U32.to_nat(K))) == False{} : Bool}
  e

def u32_len(+n: U32, +L: Nat, +K: U32, +hn: {L == U32.to_nat(n) : Nat}, +e: {Nat.is_eq(L, U32.to_nat(K)) == True{} : Bool}) -> {n == K : U32}:
  FD.u32__injective(n, K, Equal.trans(Nat, U32.to_nat(n), L, U32.to_nat(K), Equal.sym(Nat, L, U32.to_nat(n), hn), FD.nat__eq_from_is_eq(L, U32.to_nat(K), e)))

# ---- END_TO_END's deserialize laws ----

def rej_none(+schema: S.Schema, +bs: +List<U32>,
    pr: ({API.deserialize(schema, bs) == None{} : Maybe<&2, S.Value>} -> Legal.type_legal(schema) -> Decoding.outside_image(schema, bs)) & ((Legal.type_legal(schema) -> Decoding.outside_image(schema, bs)) -> {API.deserialize(schema, bs) == None{} : Maybe<&2, S.Value>}),
    out: Decoding.outside_image(schema, bs)) -> {API.deserialize(schema, bs) == None{} : Maybe<&2, S.Value>}:
  (a, b) = pr
  b(l => out)

def outside_none(+schema: S.Schema, +bs: +List<U32>, out: Decoding.outside_image(schema, bs)) -> {API.deserialize(schema, bs) == None{} : Maybe<&2, S.Value>}:
  rej_none(schema, bs, E2E.deserialize_rejection_correct(schema, bs), out)

def acc_dec(+schema: S.Schema, +bs: +List<U32>, +value: S.Value, pr: Legal.type_legal(schema) & Decoding.decodes(schema, bs, value)) -> Decoding.decodes(schema, bs, value):
  (a, b) = pr
  b

# Maybe<&1, _> (the object decoder's result) discrimination.
def none_some1(-A: Data, x: A, e: {None{} == Some{x} : Maybe<&1, A>}) -> Empty:
  %Equal.sym(Maybe<&1, A>, None{}, Some{x}, e) : FD.logic__truth(Maybe.is_some(&1, A, _))
  Unit{}

# the same for a storage-backed object (a Type)
def none_someT(-A: Type, x: A, e: {None{} == Some{x} : Maybe<&1, A>}) -> Empty:
  %Equal.sym(Maybe<&1, A>, None{}, Some{x}, e) : FD.logic__truth(Maybe.is_some(&1, A, _))
  Unit{}

def some_value1(-A: Data, m: Maybe<&1, A>, d: A) -> A:
  match m:
    case None{}: d
    case Some{x}: x

def some_inj1(-A: Data, x: A, y: A, e: {Some{x} == Some{y} : Maybe<&1, A>}) -> {x == y : A}:
  Equal.cong(Maybe<&1, A>, A, m => some_value1(A, m, x), Some{x}, Some{y}, e)
'''


# ---- (ii) / (iii) per name ----

def dec_text(R, en, ot, sn, VAL, obj, pat, xs, SI, SIlaw, SR, SRlaw, DR, DRlaw, SE, SElaw):
    """R readable; en encoder prefix (T.<en>_decode); ot object type (T.<ot>); sn spec name;
    VAL the view (qualified); obj / pat the object term / pattern over xs; SI/SR/DR/SE module aliases."""
    SEc = f'{SE}.{SElaw}' if SE else SElaw
    W = len(xs)
    KN, KU, WN = f'{4 * W}n', f'{4 * W}', f'{W}n'
    M1 = f'Maybe<&1, {ot}>'
    MV = 'Maybe<&2, S.Value>'
    LEN = 'List.length(&2, U32, bs)'
    IN = 'B.fill_at(B.alloc(n), 0, bs)'
    DEC = f'T.{en}_decode({IN}, n)'
    RES = f'Pair.snd(B.Buf, {M1}, {DEC})'
    API_ = f'API.deserialize(Spec.{sn}(), bs)'
    ws = [f'E.wn({i}n, bs)' for i in range(W)]
    def sub(t, vals):
        return re.sub(r'(?<![\w.])(' + '|'.join(xs) + r')(?![\w{(])', lambda m: vals[xs.index(m.group(1))], t)
    OW = sub(obj, ws)
    ys = [f'y{i}' for i in range(W)]
    OY = sub(obj, ys)
    PY = sub(pat, ys)
    lw = f'F.limbs([{", ".join(ws)}])'
    ly = f'F.limbs([{", ".join(ys)}])'
    HN = f'hn: {{{LEN} == U32.to_nat(n) : Nat}}'
    HD = 'hd: {SP.bytes_domain(bs) == True{} : Bool}'
    EC = lambda c: f'ec: {{Nat.is_eq({LEN}, {KN}) == {c} : Bool}}'  # noqa: E731
    p = f'{R}_d'
    L = []
    L.append(f'''# {R}: decoding a byte list against END_TO_END's deserialize.
def {p}_none(+bs: +List<U32>, +n: U32, +{HN}, +{EC("False{}")}) -> {{{RES} == None{{}} : {M1}}}:
  Equal.cong(B.Buf & {M1}, {M1}, q => Pair.snd(B.Buf, {M1}, q), {DEC}, ({IN}, None{{}}), {SR}.{SRlaw}({IN}, n, E.ueq_false(n, {LEN}, {KU}, hn, ec)))

def {p}_anone(+bs: +List<U32>, +{EC("False{}")}) -> {{{API_} == None{{}} : {MV}}}:
  E.outside_none(Spec.{sn}(), bs, {DR}.{DRlaw}(bs, ec))

def {p}_pk(+bs: +List<U32>, +{HD}, +{EC("True{}")}) -> {{F.limbs(E.wl({WN}, bs)) == bs : +List<U32>}}:
  E.pk({WN}, bs, hd, FD.nat__eq_from_is_eq({LEN}, {KN}, ec))

def {p}_some(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +{EC("True{}")}) -> {{{RES} == Some{{{OW}}} : {M1}}}:
  %Equal.sym(U32, n, {KU}, E.u32_len(n, {LEN}, {KU}, hn, ec)) :
    {{Pair.snd(B.Buf, {M1}, T.{en}_decode(B.fill_at(B.alloc(_), 0, bs), _)) == Some{{{OW}}} : {M1}}}
  %{p}_pk(bs, hd, ec) :
    {{Pair.snd(B.Buf, {M1}, T.{en}_decode(B.fill_at(B.alloc({KU}), 0, _), {KU})) == Some{{{OW}}} : {M1}}}
  Equal.cong(B.Buf & {M1}, {M1}, q => Pair.snd(B.Buf, {M1}, q), T.{en}_decode(B.fill_at(B.alloc({KU}), 0, {lw}), {KU}), (B.fill_at(B.alloc({KU}), 0, {lw}), Some{{{OW}}}),
    {SI}.{SIlaw}({", ".join(ws)}))

def {p}_asome(+bs: +List<U32>, +{HD}, +{EC("True{}")}) -> {{{API_} == Some{{{VAL}({OW})}} : {MV}}}:
  E2E.spec_accepted(Spec.{sn}(), bs, {VAL}({OW}), (VS.public_sound(Spec.{sn}(), {{==}}),
    %{p}_pk(bs, hd, ec) : {{Encoding.encoding_for_legal_type(Spec.{sn}(), {VAL}({OW})) == Some{{_}} : Maybe<&2, +List<U32>>}}
    {SEc}({", ".join(ws)})))

def {p}_ia(+bs: +List<U32>, +n: U32, +o: {ot}, +{HN}, +{HD}, +c: Bool, +{EC("c")}, +da: {{{RES} == Some{{o}} : {M1}}}) -> {{{API_} == Some{{{VAL}(o)}} : {MV}}}:
  match c:
    case False{{}}: Empty.absurd({{{API_} == Some{{{VAL}(o)}} : {MV}}}, E.none_some1({ot}, o, Equal.trans({M1}, None{{}}, {RES}, Some{{o}}, Equal.sym({M1}, {RES}, None{{}}, {p}_none(bs, n, hn, ec)), da)))
    case True{{}}:
      %E.some_inj1({ot}, {OW}, o, Equal.trans({M1}, Some{{{OW}}}, {RES}, Some{{o}}, Equal.sym({M1}, {RES}, Some{{{OW}}}, {p}_some(bs, n, hn, hd, ec)), da)) :
        {{{API_} == Some{{{VAL}(_)}} : {MV}}}
      {p}_asome(bs, hd, ec)

def {p}_ibt(+bs: +List<U32>, +n: U32, +o: {ot}, +{HN}, +{EC("True{}")}, +aa: {{{API_} == Some{{{VAL}(o)}} : {MV}}}) -> {{{RES} == Some{{o}} : {M1}}}:
  match o:
    case {PY}:
      +eb = FD.logic__some_inj(+List<U32>, {ly}, bs, Equal.trans(Maybe<&2, +List<U32>>, Some{{{ly}}}, Encoding.encoding_for_legal_type(Spec.{sn}(), {VAL}({OY})), Some{{bs}},
        Equal.sym(Maybe<&2, +List<U32>>, Encoding.encoding_for_legal_type(Spec.{sn}(), {VAL}({OY})), Some{{{ly}}}, {SEc}({", ".join(ys)})),
        E.acc_dec(Spec.{sn}(), bs, {VAL}({OY}), E2E.accepted_spec(Spec.{sn}(), bs, {VAL}({OY}), aa))))
      %Equal.sym(U32, n, {KU}, E.u32_len(n, {LEN}, {KU}, hn, ec)) :
        {{Pair.snd(B.Buf, {M1}, T.{en}_decode(B.fill_at(B.alloc(_), 0, bs), _)) == Some{{{OY}}} : {M1}}}
      %eb :
        {{Pair.snd(B.Buf, {M1}, T.{en}_decode(B.fill_at(B.alloc({KU}), 0, _), {KU})) == Some{{{OY}}} : {M1}}}
      Equal.cong(B.Buf & {M1}, {M1}, q => Pair.snd(B.Buf, {M1}, q), T.{en}_decode(B.fill_at(B.alloc({KU}), 0, {ly}), {KU}), (B.fill_at(B.alloc({KU}), 0, {ly}), Some{{{OY}}}),
        {SI}.{SIlaw}({", ".join(ys)}))

def {p}_ib(+bs: +List<U32>, +n: U32, +o: {ot}, +{HN}, +c: Bool, +{EC("c")}, +aa: {{{API_} == Some{{{VAL}(o)}} : {MV}}}) -> {{{RES} == Some{{o}} : {M1}}}:
  match c:
    case False{{}}: Empty.absurd({{{RES} == Some{{o}} : {M1}}}, FD.logic__none_some(S.Value, {VAL}(o), Equal.trans({MV}, None{{}}, {API_}, Some{{{VAL}(o)}}, Equal.sym({MV}, {API_}, None{{}}, {p}_anone(bs, ec)), aa)))
    case True{{}}: {p}_ibt(bs, n, o, hn, ec, aa)

def {p}_ra(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +c: Bool, +{EC("c")}, +dn: {{{RES} == None{{}} : {M1}}}) -> {{{API_} == None{{}} : {MV}}}:
  match c:
    case False{{}}: {p}_anone(bs, ec)
    case True{{}}: Empty.absurd({{{API_} == None{{}} : {MV}}}, E.none_someT({ot}, {OW}, Equal.trans({M1}, None{{}}, {RES}, Some{{{OW}}}, Equal.sym({M1}, {RES}, None{{}}, dn), {p}_some(bs, n, hn, hd, ec))))

def {p}_rb(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +c: Bool, +{EC("c")}, +an: {{{API_} == None{{}} : {MV}}}) -> {{{RES} == None{{}} : {M1}}}:
  match c:
    case False{{}}: {p}_none(bs, n, hn, ec)
    case True{{}}: Empty.absurd({{{RES} == None{{}} : {M1}}}, FD.logic__none_some(S.Value, {VAL}({OW}), Equal.trans({MV}, None{{}}, {API_}, Some{{{VAL}({OW})}}, Equal.sym({MV}, {API_}, None{{}}, an), {p}_asome(bs, hd, ec))))

# (ii) the object decoder returns o exactly when END_TO_END's deserialize returns VAL(o).
def {R}_e2e_decode_accept(+bs: +List<U32>, +n: U32, +o: {ot}, +{HN}, +{HD})
    -> ({{{RES} == Some{{o}} : {M1}}} -> {{{API_} == Some{{{VAL}(o)}} : {MV}}}) & ({{{API_} == Some{{{VAL}(o)}} : {MV}}} -> {{{RES} == Some{{o}} : {M1}}}):
  (da => {p}_ia(bs, n, o, hn, hd, Nat.is_eq({LEN}, {KN}), {{==}}, da), aa => {p}_ib(bs, n, o, hn, Nat.is_eq({LEN}, {KN}), {{==}}, aa))

# (iii) the object decoder fails exactly when END_TO_END's deserialize does.
def {R}_e2e_decode_reject(+bs: +List<U32>, +n: U32, +{HN}, +{HD})
    -> ({{{RES} == None{{}} : {M1}}} -> {{{API_} == None{{}} : {MV}}}) & ({{{API_} == None{{}} : {MV}}} -> {{{RES} == None{{}} : {M1}}}):
  (dn => {p}_ra(bs, n, hn, hd, Nat.is_eq({LEN}, {KN}), {{==}}, dn), an => {p}_rb(bs, n, hn, hd, Nat.is_eq({LEN}, {KN}), {{==}}, an))
''')
    return '\n'.join(L)


BITS = r'''import Base
import ../proofs/obj/spec_bits.bend as FB
import ../proofs/obj/bits_leaf.bend as BL

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# A bit vector's bits: the root view's words' wbits are the spec value's spec_bits.bitsof.

def wcat(ws: +List<U32>) -> +List<Bool>:
  match ws:
    case Nil{}: []
    case Con{h, t}: List.append(&2, Bool, BL.wbits(h), wcat(t))

def bw1(+h: U32, +t: +List<U32>, +ih: {FB.bitsof(t) == wcat(t) : +List<Bool>}) -> {FB.bitsof(Con{h, t}) == wcat(Con{h, t}) : +List<Bool>}:
  match h:
    case U32{WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WCon{+a8, WCon{+a9, WCon{+a10, WCon{+a11, WCon{+a12, WCon{+a13, WCon{+a14, WCon{+a15, WCon{+a16, WCon{+a17, WCon{+a18, WCon{+a19, WCon{+a20, WCon{+a21, WCon{+a22, WCon{+a23, WCon{+a24, WCon{+a25, WCon{+a26, WCon{+a27, WCon{+a28, WCon{+a29, WCon{+a30, WCon{+a31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      Equal.cong(+List<Bool>, +List<Bool>, z => a0 <> a1 <> a2 <> a3 <> a4 <> a5 <> a6 <> a7 <> a8 <> a9 <> a10 <> a11 <> a12 <> a13 <> a14 <> a15 <> a16 <> a17 <> a18 <> a19 <> a20 <> a21 <> a22 <> a23 <> a24 <> a25 <> a26 <> a27 <> a28 <> a29 <> a30 <> a31 <> z, FB.bitsof(t), wcat(t), ih)

def bw(+ws: +List<U32>) -> {FB.bitsof(ws) == wcat(ws) : +List<Bool>}:
  match ws:
    case Nil{}: {==}
    case Con{+h, +t}: bw1(h, t, bw(t))
'''


def blocks_of(f, cache):
    if f not in cache:
        cache[f] = AG.blocks((OBJ / f).read_text())
    return cache[f]


def law(cache, e):
    return next(b for b in blocks_of(e['file'], cache) if b[1] == e['law'])


def pvars(params):
    out = []
    for p in params:
        m = re.match(r'\s*\+?(\w+)\s*:\s*(.+)$', p)
        if not m:
            return None
        out.append((m.group(1), m.group(2).strip()))
    return out


def split_eq(st):
    """{A == B : T} -> (A, B, T), splitting at the top-level '=='."""
    assert st.startswith('{') and st.endswith('}')
    s = st[1:-1]
    d = 0
    eq = col = None
    for i, ch in enumerate(s):
        if ch in '({[<':
            d += 1
        elif ch in ')}]>':
            d -= 1
        elif d == 0 and s.startswith(' == ', i) and eq is None:
            eq = i
        elif d == 0 and s.startswith(' : ', i):
            col = i
    return s[:eq], s[eq + 4:col], s[col + 3:]


def call_args(s, head):
    """head(a, b, c) -> [a, b, c] (s starts with head + '(')."""
    assert s.startswith(head + '(')
    d, cur, out = 0, '', []
    for ch in s[len(head) + 1:]:
        if ch in '({[' or (ch == '<'):
            d += 1
        elif ch in ')}]' or ch == '>':
            if d == 0 and ch == ')':
                out.append(cur.strip())
                return out
            d -= 1
        if ch == ',' and d == 0:
            out.append(cur.strip())
            cur = ''
            continue
        cur += ch
    raise ValueError(s)


def family_a(X, m, cache, valid_idx):
    """Family A: the pieces (i) and (iv) need, or the reason X is not in it."""
    ee, es, rt = m.get('encode_eval', []), m.get('encode_spec', []), m.get('root', [])
    if not (ee and es and rt):
        return None, 'no encode_eval / encode_spec / root law'
    b_ee, b_es, b_rt = law(cache, ee[0]), law(cache, es[0]), law(cache, rt[0])
    P = pvars(b_ee[2])
    if P is None or any(t not in ('U32', 'Bool') for _, t in P) or pvars(b_es[2]) != P:
        return None, 'encode laws not over the same free words / bits'
    mt = re.match(r'\{B\.emit\(T\.(\w+)_encode\((.*)\), 0, (\w+)\) == \(T\.\1_encode\(\2\), (.*)\) : B\.Buf & \+List<U32>\}$', b_ee[3])
    if not mt:
        return None, 'encode_eval not an emit of the encoder'
    ename, obj, K, byts = mt.groups()
    ms = re.match(r'Decoding\.decodes\(Spec\.(\w+)\(\), (.*)\)$', b_es[3])
    if not ms:
        return None, 'encode_spec not a decodes of Spec.X()'
    sname = ms.group(1)
    rest = call_args('Decoding.decodes(' + ms.group(0)[len('Decoding.decodes('):], 'Decoding.decodes')
    if len(rest) != 3 or rest[1] != byts:
        return None, 'encode_spec bytes differ from encode_eval bytes'
    rp = pvars(b_rt[2]) if all(not p.startswith('-') or p.startswith('-h') for p in b_rt[2]) else None
    rparams = [p.strip() for p in b_rt[2]]
    if len(rparams) != 2 or not rparams[0].startswith('-h: B.Buf') or not re.match(r'\+o: (T|O)\.\w+$', rparams[1]):
        return None, 'root law not over every object (hypotheses or a representation)'
    otype = rparams[1][len('+o: '):]
    mr = re.match(r'RR\.roots\((\w+)\(o\), Spec\.' + sname + r'\(\), \[D\.bytes\(Pair\.snd\(B\.Buf, D\.Digest, T\.' + ename + r'_hash_tree_root\(h, o\)\)\)\]\)$', b_rt[3])
    if not mr:
        return None, 'root law not RR.roots of the view at Spec.X()'
    view = mr.group(1)
    # None: (iv) awaits root_valid(view)
    vx = valid_idx.get((rt[0]['file'], view)) or valid_idx.get((rt[0]['file'], view, sname))
    del rp
    names = [v for v, _ in P]
    pat = re.sub(r'(?<![\w.])(' + '|'.join(map(re.escape, names)) + r')(?![\w{(])', r'+\1', obj)
    return {'X': X, 'ename': ename, 'sname': sname, 'obj': obj, 'pat': pat, 'K': K, 'byts': byts, 'P': P, 'value': rest[2],
            'otype': otype, 'view': view, 'ee': ee[0], 'es': es[0], 'rt': rt[0], 'vx': vx}, None


def valid_index():
    """(root file, view) -> (valid file, lemma): the rv_ lemmas, whose statement names the view as
    <alias>.<view>(o) of the root file they import."""
    idx = {}
    for f in sorted(OBJ.glob('valid_*.bend')):
        src = f.read_text()
        al = {m.group(2): m.group(1) for m in re.finditer(r'import \./(\w+\.bend) as (\w+)', src)}
        for m in re.finditer(r'^def (rv_\w+)\(\+o: [\w.]+\) -> \{VD\.root_valid\((\w+)\.(\w+)\(o\), ', src, re.M):
            if m.group(2) in al:
                idx[(al[m.group(2)], m.group(3))] = (f.name, m.group(1))
    # the per-name lemmas at the Spec schema (codegen/valid_laws.py: gvalid_*.bend):
    # <X>_root_valid(+o: R) -> {VD.root_valid(<alias>.<view>(o), Spec.<X>()) == True{} : Bool}
    for f in sorted(OBJ.glob('gvalid_*.bend')):
        src = f.read_text()
        al = {m.group(2): m.group(1) for m in re.finditer(r'import \./(\w+\.bend) as (\w+)', src)}
        for m in re.finditer(r'^def ((\w+)_root_valid)\(\+o: [\w.]+\) -> \{VD\.root_valid\((\w+)\.(\w+)\(o\), Spec\.(\w+)\(\)\) == True', src, re.M):
            if m.group(3) in al and m.group(2) == m.group(5):
                idx[(al[m.group(3)], m.group(4), m.group(2))] = (f.name, m.group(1))
    return idx



GEN_IMPORTS = ['import ../types/generic_obj.bend as TG', 'import ../proofs/obj/generic_specs.bend as GS']


def gfix(line):
    """a generic form's lines: its objects are types/generic_obj.bend's (TG), its schemas
    proofs/obj/generic_specs.bend's (GS)"""
    line = re.sub(r'(?<![\w.])T\.', 'TG.', line)
    return re.sub(r'(?<![\w.])Spec\.', 'GS.', line)


def bits_of(r):
    return 'bitsof(' in r['value']


def view_text(r, VAL, ES):
    """<R>_e2e_view: the root view of the object is encode_spec's value (its bit vectors' bitsof
    are the view's wbits, e2e_bits.bw); <R>_e2e_enc: encode_spec at the view."""
    R, sn = r['R'], r['sname']
    xs = [v for v, _ in r['P']]
    ps = ', '.join(f'+{v}: U32' for v in xs)
    args = ', '.join(xs)
    obj = requal(r['obj'], r['ee_alias'])
    value = requal(r['value'], r['ee_alias'])
    byts = requal(r['byts'], r['ee_alias'])
    lists = re.findall(r'FB\.bitsof\((\[[^\]]*\])\)', value)
    L = [f'def {R}_e2e_view({ps}) -> {{{VAL}({obj}) == {value} : S.Value}}:']
    cur = value
    for lst in lists:
        L.append(f'  %Equal.sym(+List<Bool>, FB.bitsof({lst}), EB.wcat({lst}), EB.bw({lst})) :')
        L.append(f'    {{{VAL}({obj}) == {cur.replace(f"FB.bitsof({lst})", "_", 1)} : S.Value}}')
        cur = cur.replace(f'FB.bitsof({lst})', f'EB.wcat({lst})', 1)
    L.append('  {==}')
    L.append('')
    L.append(f'def {R}_e2e_enc({ps}) -> {{Encoding.encoding_for_legal_type(Spec.{sn}(), {VAL}({obj})) == Some{{{byts}}} : Maybe<&2, +List<U32>>}}:')
    L.append(f'  Equal.trans(Maybe<&2, +List<U32>>, Encoding.encoding_for_legal_type(Spec.{sn}(), {VAL}({obj})), Encoding.encoding_for_legal_type(Spec.{sn}(), {value}), Some{{{byts}}},')
    L.append(f'    Equal.cong(S.Value, Maybe<&2, +List<U32>>, v => Encoding.encoding_for_legal_type(Spec.{sn}(), v), {VAL}({obj}), {value}, {R}_e2e_view({args})),')
    L.append(f'    {ES}.{r["es"]["law"]}({args}))')
    L.append('')
    return '\n'.join(L)

def text_a(rows, k):
    L = list(HEAD)
    files = []
    for r in rows:
        for f in (r['ee']['file'], r['es']['file'], r['rt']['file']) + ((r['vx'][0],) if r['vx'] else ()):
            if f not in files:
                files.append(f)
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L += [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    if any(bits_of(r) for r in rows):
        L += ['import ../proofs/obj/spec_bits.bend as FB', 'import ./e2e_bits.bend as EB']
    L += GEN_IMPORTS if any(r['generic'] for r in rows) else []
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (family A): the object API\'s encoder bytes and roots are END_TO_END\'s model API\'s.', '']
    for r in rows:
        R, X, en, sn = r['R'], r['X'], r['ename'], r['sname']
        EE, ES, RT = al[r['ee']['file']], al[r['es']['file']], al[r['rt']['file']]
        n0 = len(L)
        obj, byts = r['obj'], r['byts']
        # the proving module's terms under this file's aliases
        obj_q = requal(obj, r['ee_alias'])
        byts_q = requal(byts, r['ee_alias'])
        args = ', '.join(v for v, _ in r['P'])
        VAL = f'{RT}.{r["view"]}'
        o = obj_q
        L.append(f'# {R} ({X})')
        encf = f'{ES}.{r["es"]["law"]}'
        if bits_of(r):
            L.append(view_text(r, VAL, ES))
            encf = f'{R}_e2e_enc'
        L.append(f'def {R}_e2e_encode(+o: {r["otype"]}) -> {{Some{{E.obytes(T.{en}_encode(o))}} == API.serialize(Spec.{sn}(), {VAL}(o)) : {MB}}}:')
        L.append('  match o:')
        L.append(f'    case {requal(r["pat"], r["ee_alias"])}:')
        enc = f'T.{en}_encode({o})'
        L.append(f'      Equal.trans({MB}, Some{{E.obytes({enc})}}, Some{{{byts_q}}}, API.serialize(Spec.{sn}(), {VAL}({o})),')
        L.append(f'        Equal.cong(B.Buf & +List<U32>, {MB}, p => Some{{Pair.snd(B.Buf, +List<U32>, p)}}, B.emit({enc}, 0, {r["K"]}), ({enc}, {byts_q}), {EE}.{r["ee"]["law"]}({args})),')
        L.append(f'        Equal.sym({MB}, API.serialize(Spec.{sn}(), {VAL}({o})), Some{{{byts_q}}},')
        L.append(f'          Equal.trans({MB}, API.serialize(Spec.{sn}(), {VAL}({o})), Encoding.encoding_for_legal_type(Spec.{sn}(), {VAL}({o})), Some{{{byts_q}}},')
        L.append(f'            E.serialize_legal(Spec.{sn}(), {VAL}({o}), VS.public_sound(Spec.{sn}(), {{==}})), {encf}({args}))))')
        L.append('')
        if r['vx']:
            vf, vl = r['vx']
            VV = al[vf]
            L.append(f'def {R}_e2e_root(h: B.Buf, +o: {r["otype"]}) -> {{Some{{D.bytes(Pair.snd(B.Buf, D.Digest, T.{en}_hash_tree_root(h, o)))}} == API.hash_tree_root(Spec.{sn}(), {VAL}(o)) : {MB}}}:')
            L.append(f'  E.root_legal(Spec.{sn}(), {VAL}(o), VS.public_sound(Spec.{sn}(), {{==}}), D.bytes(Pair.snd(B.Buf, D.Digest, T.{en}_hash_tree_root(h, o))),')
            L.append(f'    {VV}.{vl}(o), {RT}.{r["rt"]["law"]}(h, o))')
            L.append('')
        if r['generic']:
            L[n0:] = [gfix(x) for x in L[n0:]]
    return '\n'.join(L) + '\n'


# the aliases this file imports under the proving modules' own names
OWN = {'T': 'T', 'O': 'O', 'B': 'B', 'S': 'S', 'P': 'P', 'Spec': 'Spec', 'D': 'D'}


def requal(s, amap):
    """rename a proving module's aliases (amap: its alias -> ours) in a term"""
    return re.sub(r'(?<![\w.])([A-Za-z_]\w*)\.', lambda m: f'{amap[m.group(1)]}.' if m.group(1) in amap else m.group(0), s)


def file_aliases(f):
    """a proving file's import aliases, mapped to this file's (T/O/B/S/P/Spec/D/F/SP)."""
    out = {}
    for m in re.finditer(r'^import (\S+) as (\w+)$', (OBJ / f).read_text(), re.M):
        path, a = m.group(1), m.group(2)
        base = path.split('/')[-1]
        known = {'fulu_obj.bend': 'T', 'generic_obj.bend': 'T', 'obj.bend': 'O', 'buffer.bend': 'B',
                 'schema.bend': 'S' if 'types/' in path else None, 'primitive.bend': 'P', 'fulu_schemas.bend': 'Spec',
                 'digest.bend': 'D', 'spec_fixed.bend': 'F', 'spec_bits.bend': 'FB', 'found.bend': 'FD', 'vspec.bend': 'VSP', 'words_root.bend': 'WR', 'primitives.bend': 'SP' if 'spec/' in path else None}
        t = known.get(base)
        if t:
            out[a] = t
    return out



def decode_a(r, m, cache):
    """(ii)/(iii) for a family-A name: its decode_input / decode_none / decode_reject laws in the
    fixed-size form, or the reason it is not covered."""
    di, dn, dr = m.get('decode_input', []), m.get('decode_none', []), m.get('decode_reject', [])
    if not (di and dn and dr):
        return None, 'no decode_input / decode_none / decode_reject law'
    P = [v for v, t in r['P']]
    if any(t != 'U32' for _, t in r['P']):
        return None, 'encode laws over bits'
    W = len(P)
    K = 4 * W
    lim = f'F.limbs([{", ".join(P)}])'
    if r['byts'] != lim:
        return None, 'encode bytes not the limbs of the words'
    b_di, b_dn, b_dr = law(cache, di[0]), law(cache, dn[0]), law(cache, dr[0])
    en, ot = r['ename'], r['otype']
    want = (f'{{T.{en}_decode(B.fill_at(B.alloc({K}), 0, {lim}), {K}) == (B.fill_at(B.alloc({K}), 0, {lim}), '
            f'Some{{{r["obj"]}}}) : B.Buf & Maybe<&1, {ot}>}}')
    if pvars(b_di[2]) != r['P'] or b_di[3] != want:
        return None, 'decode_input not the fixed-size form'
    if [q.strip() for q in b_dn[2]] != ['buf: B.Buf', '+m: U32', f'e: {{U32.is_eq(m, {K}) == False{{}} : Bool}}'] or \
            b_dn[3] != f'{{T.{en}_decode(buf, m) == (buf, None{{}}) : B.Buf & Maybe<&1, {ot}>}}':
        return None, 'decode_none not the size form'
    if [q.strip() for q in b_dr[2]] != ['+bs: +List<U32>', f'+hn: {{Nat.is_eq(List.length(&2, U32, bs), {K}n) == False{{}} : Bool}}'] or \
            not re.match(r'Decoding\.outside_image\(\w+\.' + r['sname'] + r'\(\), bs\)$', b_dr[3]):
        return None, 'decode_reject not the length form'
    return {'di': di[0], 'dn': dn[0], 'dr': dr[0]}, None


DHEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API',
         'import ../src/buffer.bend as B', 'import ../src/obj.bend as O', 'import ../types/fulu_obj.bend as T',
         'import ../types/schema.bend as S', 'import ../types/primitive.bend as P', 'import ../spec/fulu_schemas.bend as Spec',
         'import ../spec/codec.bend as Encoding', 'import ../spec/primitives.bend as SP',
         'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
         'import ../proofs/obj/spec_fixed.bend as F', 'import ./e2e_bytes.bend as E']


def text_dec(rows, k):
    L = list(DHEAD)
    files = []
    for r in rows:
        for f in (r['d']['di']['file'], r['d']['dn']['file'], r['d']['dr']['file'], r['es']['file'], r['rt']['file']):
            if f not in files:
                files.append(f)
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L += [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    if any(bits_of(r) for r in rows):
        L += ['import ../proofs/obj/spec_bits.bend as FB', 'import ./e2e_bits.bend as EB']
    L += GEN_IMPORTS if any(r['generic'] for r in rows) else []
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (family A): the object API\'s decoder on a byte list against END_TO_END\'s deserialize.', '']
    for r in rows:
        d = r['d']
        xs = [v for v, _ in r['P']]
        obj = requal(r['obj'], r['ee_alias'])
        pat = requal(r['pat'], r['ee_alias'])
        VAL = f'{al[r["rt"]["file"]]}.{r["view"]}'
        SE, SEl = al[r['es']['file']], r['es']['law']
        n0 = len(L)
        if bits_of(r):
            L.append(view_text(r, VAL, SE))
            SE, SEl = '', f'{r["R"]}_e2e_enc'
        L.append(dec_text(r['R'], r['ename'], r['otype'], r['sname'], VAL, obj, pat, xs,
                          al[d['di']['file']], d['di']['law'], al[d['dn']['file']], d['dn']['law'],
                          al[d['dr']['file']], d['dr']['law'], SE, SEl))
        if r['generic']:
            L[n0:] = [gfix(x) for x in L[n0:]]
    return '\n'.join(L) + '\n'


# ---- family W: word-storage vectors (object O.Words under PK.rep_vK) ----

TREE = r"""import Base
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# Word storage at a given depth: a perfect tree is its explicit spine of leaves (tf), and the
# depth premise of the word-storage bridges.

def lo(+t: FD.array__Tree<U32>) -> FD.array__Tree<U32>:
  match t:
    case FD.TLeaf{x}: FD.TLeaf{x}
    case FD.TNode{l, r}: l

def hi(+t: FD.array__Tree<U32>) -> FD.array__Tree<U32>:
  match t:
    case FD.TLeaf{x}: FD.TLeaf{x}
    case FD.TNode{l, r}: r

def leaf(+t: FD.array__Tree<U32>) -> U32:
  match t:
    case FD.TLeaf{x}: x
    case FD.TNode{l, r}: 0

# the explicit perfect tree of depth d with t's leaves
def tf(+d: Nat, +t: FD.array__Tree<U32>) -> FD.array__Tree<U32>:
  match d:
    case 0n: FD.TLeaf{leaf(t)}
    case 1n+ +p: FD.TNode{tf(p, lo(t)), tf(p, hi(t))}

def eta(+d: Nat, +t: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}) -> {t == tf(d, t) : FD.array__Tree<U32>}:
  match d t:
    case 0n FD.TLeaf{+x}: {==}
    case 0n FD.TNode{+l, +r}: Empty.absurd({FD.TNode{l, r} == tf(0n, FD.TNode{l, r}) : FD.array__Tree<U32>}, FD.logic__false_true(pf))
    case 1n+ +p FD.TLeaf{+x}: Empty.absurd({FD.TLeaf{x} == tf(1n+p, FD.TLeaf{x}) : FD.array__Tree<U32>}, FD.logic__false_true(pf))
    case 1n+ +p FD.TNode{+l, +r}:
      +pl = FD.logic__and_left(FD.array__perfect(U32, p, l), FD.array__perfect(U32, p, r), pf)
      +pr = FD.logic__and_right(FD.array__perfect(U32, p, l), FD.array__perfect(U32, p, r), pf)
      %eta(p, l, pl) : {FD.TNode{l, r} == FD.TNode{_, tf(p, r)} : FD.array__Tree<U32>}
      %eta(p, r, pr) : {FD.TNode{l, r} == FD.TNode{l, _} : FD.array__Tree<U32>}
      {==}

# the premise: the object's words are a perfect tree of depth d (the depth the decoder allocates)
def at_depth(o: O.Words, +d: Nat) -> Bool:
  match o:
    case O.Words{ws, +n}: FD.array__perfect(U32, d, FD.array__freeze(U32, ws))
"""

WHEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API',
         'import ../src/buffer.bend as B', 'import ../src/digest.bend as D', 'import ../src/obj.bend as O',
         'import ../types/schema.bend as S', 'import ../spec/codec.bend as Encoding',
         'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
         'import ../proofs/obj/spec_fixed.bend as F', 'import ../proofs/obj/packed_obj.bend as PK',
         'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/schema_shapes.bend as SH',
         'import ./e2e_support.bend as E', 'import ./e2e_tree.bend as E3']


def family_w(X, m, cache):
    """the word-storage vectors: encode_eval an emitted encoder of O.Words{explicit tree, N},
    encode_spec over its data words, root over (o, s, es, rep: PK.rep_vK(o, s)) at PK.vviewK(o)"""
    ee, es, rt = m.get('encode_eval', []), m.get('encode_spec', []), m.get('root', [])
    if not (ee and es and rt):
        return None
    b_ee, b_es, b_rt = law(cache, ee[0]), law(cache, es[0]), law(cache, rt[0])
    mt = re.match(r'\{(\w+)\.emitted\(O\.Words, T\.(\w+)_encode\(O\.Words\{(.*), (\d+)\}\), (\d+)\) == \(O\.Words\{\3, \4\}, (\w+)\.limbs\(\[(.*)\]\)\) : O\.Words & \+List<U32>\}$', b_ee[3])
    if not mt:
        return None
    _, ename, tree, N, NW, _, xl = mt.groups()
    P = pvars(b_ee[2])
    leaves = re.findall(r'ALeaf\{(\w+)\}', tree)
    xs = [x.strip() for x in xl.split(',')]
    if P is None or [v for v, _ in P] != leaves or leaves[:len(xs)] != xs or any(t != 'U32' for _, t in P):
        return None
    d = len(leaves).bit_length() - 1
    if 1 << d != len(leaves):
        return None
    ms = re.match(r'Decoding\.decodes\((\w+)\.(\w+)\(\), (\w+)\.limbs\(\[' + re.escape(xl) + r'\]\), (.*)\)$', b_es[3])
    if not ms or [v for v, _ in (pvars(b_es[2]) or [])] != xs:
        return None
    sname = ms.group(2)
    rp = [q.strip() for q in b_rt[2]]
    mr = re.match(r'\+rep: PK\.rep_v(\d+)\(o, s\)$', rp[-1]) if len(rp) == 5 else None
    if not mr or rp[1] != '-o: O.Words' or not rp[3].startswith('+es: {s == '):
        return None
    K = mr.group(1)
    if not re.match(r'RR\.roots\(PK\.vview' + K + r'\(o\), s, ', b_rt[3]):
        return None
    return {'X': X, 'ename': ename, 'sname': sname, 'N': N, 'NW': NW, 'd': d, 'leaves': leaves, 'xs': xs, 'K': K, 'value': ms.group(4),
            'ee': ee[0], 'es': es[0], 'rt': rt[0], 'generic': 'types/generic_obj.bend as T' in (OBJ / ee[0]['file']).read_text()}


def leafterm(i, d):
    s_ = 't'
    for b in range(d - 1, -1, -1):
        s_ = f'E3.{"hi" if (i >> b) & 1 else "lo"}({s_})'
    return f'E3.leaf({s_})'


def text_w(rows):
    files = []
    for r in rows:
        for f in (r['ee']['file'], r['es']['file']):
            if f not in files:
                files.append(f)
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L = list(WHEAD) + (GEN_IMPORTS if any(r['generic'] for r in rows) else ['import ../types/fulu_obj.bend as T', 'import ../spec/fulu_schemas.bend as Spec'])
    L += [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (word storage): the object API\'s encoder bytes are END_TO_END\'s',
          '# serialize, for an object under its representation invariant (rep, the root law\'s) with its',
          '# storage at the canonical depth (hc: the depth the decoder allocates; a premise until the',
          '# any-depth encode laws land).', '']
    for r in rows:
        n0 = len(L)
        R, X, en, sn, d, N, K = r['R'], r['X'], r['ename'], r['sname'], r['d'], r['N'], r['K']
        MB = 'Maybe<&2, +List<U32>>'
        EE, ES = al[r['ee']['file']], al[r['es']['file']]
        LT = [leafterm(i, d) for i in range(len(r['leaves']))]
        xs = LT[:len(r['xs'])]
        OBJ = f'O.Words{{FD.array__thaw(U32, E3.tf({d}n, t)), {N}}}'
        OT = f'O.Words{{FD.array__thaw(U32, t), {N}}}'
        ON = 'O.Words{FD.array__thaw(U32, t), N}'
        G = lambda o: f'{{Some{{E.obytes(Pair.snd(O.Words, B.Buf, T.{en}_encode({o})))}} == API.serialize(Spec.{sn}(), PK.vview{K}({o})) : {MB}}}'  # noqa: E731
        LF = lambda o: f'{{U32.to_nat(WO.len({o})) == PK.e{K}(PK.cnt{K}({o})) : Nat}}'  # noqa: E731
        CF = lambda o: f'{{Nat.is_eq(PK.cnt{K}({o}), SH.Vector_length(Spec.{sn}())) == True{{}} : Bool}}'  # noqa: E731
        HC = lambda o: f'{{E3.at_depth({o}, {d}n) == True{{}} : Bool}}'  # noqa: E731
        lim = f'F.limbs([{", ".join(xs)}])'
        L.append(f'# {R} ({X})')
        L.append(f'def {R}_w3(+t: FD.array__Tree<U32>, +pf: {{FD.array__perfect(U32, {d}n, t) == True{{}} : Bool}}) -> {G(OT)}:')
        L.append(f'  %Equal.sym(FD.array__Tree<U32>, t, E3.tf({d}n, t), E3.eta({d}n, t, pf)) :')
        L.append(f'    {G("O.Words{FD.array__thaw(U32, _), " + N + "}")}')
        L.append(f'  Equal.trans({MB}, Some{{E.obytes(Pair.snd(O.Words, B.Buf, T.{en}_encode({OBJ})))}}, Some{{{lim}}}, API.serialize(Spec.{sn}(), PK.vview{K}({OBJ})),')
        L.append(f'    Equal.cong(O.Words & +List<U32>, {MB}, p => Some{{Pair.snd(O.Words, +List<U32>, p)}}, F.emitted(O.Words, T.{en}_encode({OBJ}), {r["NW"]}), ({OBJ}, {lim}), {EE}.{r["ee"]["law"]}({", ".join(LT)})),')
        L.append(f'    Equal.sym({MB}, API.serialize(Spec.{sn}(), PK.vview{K}({OBJ})), Some{{{lim}}},')
        L.append(f'      Equal.trans({MB}, API.serialize(Spec.{sn}(), PK.vview{K}({OBJ})), Encoding.encoding_for_legal_type(Spec.{sn}(), PK.vview{K}({OBJ})), Some{{{lim}}},')
        L.append(f'        E.serialize_legal(Spec.{sn}(), PK.vview{K}({OBJ}), VS.public_sound(Spec.{sn}(), {{==}})), {ES}.{r["es"]["law"]}({", ".join(xs)}))))')
        L.append('')
        L.append(f'def {R}_w2(+t: FD.array__Tree<U32>, +N: U32, +lf: {LF(ON)}, +cf: {CF(ON)}, +hc: {HC(ON)}) -> {G(ON)}:')
        L.append(f'  +ec = FD.nat__eq_from_is_eq(PK.cnt{K}({ON}), SH.Vector_length(Spec.{sn}()), cf)')
        L.append(f'  +ln = Equal.trans(Nat, U32.to_nat(N), PK.e{K}(PK.cnt{K}({ON})), U32.to_nat({N}), lf,')
        L.append(f'    Equal.trans(Nat, PK.e{K}(PK.cnt{K}({ON})), PK.e{K}(SH.Vector_length(Spec.{sn}())), U32.to_nat({N}),')
        L.append(f'      Equal.cong(Nat, Nat, z => PK.e{K}(z), PK.cnt{K}({ON}), SH.Vector_length(Spec.{sn}()), ec), {{==}}))')
        L.append(f'  +eN = FD.u32__injective(N, {N}, ln)')
        L.append(f'  +pf = FD.logic__subst(FD.array__Tree<U32>, z => {{FD.array__perfect(U32, {d}n, z) == True{{}} : Bool}}, FD.array__freeze(U32, FD.array__thaw(U32, t)), t, FD.array__freeze_thaw(U32, t), hc)')
        L.append(f'  %Equal.sym(U32, N, {N}, eN) : {G("O.Words{FD.array__thaw(U32, t), _}")}')
        L.append(f'  {R}_w3(t, pf)')
        L.append('')
        L.append(f'def {R}_w1(-o: O.Words, +w: WO.wf1(o), +lf: {LF("o")}, +cf: {CF("o")}, +hc: {HC("o")}) -> {G("o")}:')
        for a, b in (('t', 'w1'), ('dw', 'w2'), ('N', 'w3'), ('q', 'w4'), ('r', 'w5'), ('eo', 'w6')):
            src = {'w1': 'w', 'w2': 'w1', 'w3': 'w2', 'w4': 'w3', 'w5': 'w4', 'w6': 'w5'}[b]
            L.append(f'  (+{a}, {b}) = {src}')
        L.append(f'  %Equal.sym(O.Words, o, {ON}, eo) : {G("_")}')
        L.append(f'  {R}_w2(t, N, FD.logic__subst(O.Words, z => {LF("z")}, o, {ON}, eo, lf), FD.logic__subst(O.Words, z => {CF("z")}, o, {ON}, eo, cf),')
        L.append(f'    FD.logic__subst(O.Words, z => {HC("z")}, o, {ON}, eo, hc))')
        L.append('')
        L.append(f'# (i) under rep (the root law\'s invariant) with the storage at depth {d} (the decoder\'s).')
        L.append(f'def {R}_e2e_encode(-o: O.Words, +rep: PK.rep_v{K}(o, Spec.{sn}()), +hc: {HC("o")}) -> {G("o")}:')
        L.append('  (+w, +rest) = rep')
        L.append('  (+lf, +cf) = rest')
        L.append(f'  {R}_w1(o, w, lf, cf, hc)')
        L.append('')
        if r['generic']:
            L[n0:] = [gfix(x) for x in L[n0:]]
    return '\n'.join(L) + '\n'


# ---- (ii) on views, (iii): storage-backed names ----

def dec_view_text(R, en, ot, sn, VIEWF, dobj, value, xs, SI, SIlaw, SR, SRlaw, DR, DRlaw, SE, SElaw):
    """(ii) on views and (iii) for a storage-backed name: the decoder's result, seen through the
    view, is END_TO_END's deserialize."""
    W = len(xs)
    KN, KU, WN = f'{4 * W}n', f'{4 * W}', f'{W}n'
    M1 = f'Maybe<&1, {ot}>'
    MV = 'Maybe<&2, S.Value>'
    LEN = 'List.length(&2, U32, bs)'
    IN = 'B.fill_at(B.alloc(n), 0, bs)'
    DEC = f'T.{en}_decode({IN}, n)'
    RES = f'Pair.snd(B.Buf, {M1}, {DEC})'
    API_ = f'API.deserialize(Spec.{sn}(), bs)'
    ws = [f'E.wn({i}n, bs)' for i in range(W)]

    def sub(t, vals):
        return re.sub(r'(?<![\w.])(' + '|'.join(xs) + r')(?![\w{(])', lambda m: vals[xs.index(m.group(1))], t)
    OW = sub(dobj, ws)
    VW = sub(value, ws)
    lw = f'F.limbs([{", ".join(ws)}])'
    HN = f'hn: {{{LEN} == U32.to_nat(n) : Nat}}'
    HD = 'hd: {SP.bytes_domain(bs) == True{} : Bool}'
    EC = lambda c: f'ec: {{Nat.is_eq({LEN}, {KN}) == {c} : Bool}}'  # noqa: E731
    p = f'{R}_d'
    return f'''# {R}: decoding a byte list against END_TO_END's deserialize, through the view.
def {R}_mv(m: {M1}) -> {MV}:
  match m:
    case None{{}}: None{{}}
    case Some{{o}}: Some{{{VIEWF}(o)}}

def {p}_none(+bs: +List<U32>, +n: U32, +{HN}, +{EC("False{}")}) -> {{{RES} == None{{}} : {M1}}}:
  Equal.cong(B.Buf & {M1}, {M1}, q => Pair.snd(B.Buf, {M1}, q), {DEC}, ({IN}, None{{}}), {SR}.{SRlaw}({IN}, n, E.ueq_false(n, {LEN}, {KU}, hn, ec)))

def {p}_anone(+bs: +List<U32>, +{EC("False{}")}) -> {{{API_} == None{{}} : {MV}}}:
  E.outside_none(Spec.{sn}(), bs, {DR}.{DRlaw}(bs, ec))

def {p}_pk(+bs: +List<U32>, +{HD}, +{EC("True{}")}) -> {{F.limbs(E.wl({WN}, bs)) == bs : +List<U32>}}:
  E.pk({WN}, bs, hd, FD.nat__eq_from_is_eq({LEN}, {KN}, ec))

def {p}_some(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +{EC("True{}")}) -> {{{RES} == Some{{{OW}}} : {M1}}}:
  %Equal.sym(U32, n, {KU}, E.u32_len(n, {LEN}, {KU}, hn, ec)) :
    {{Pair.snd(B.Buf, {M1}, T.{en}_decode(B.fill_at(B.alloc(_), 0, bs), _)) == Some{{{OW}}} : {M1}}}
  %{p}_pk(bs, hd, ec) :
    {{Pair.snd(B.Buf, {M1}, T.{en}_decode(B.fill_at(B.alloc({KU}), 0, _), {KU})) == Some{{{OW}}} : {M1}}}
  Equal.cong(B.Buf & {M1}, {M1}, q => Pair.snd(B.Buf, {M1}, q), T.{en}_decode(B.fill_at(B.alloc({KU}), 0, {lw}), {KU}), (B.fill_at(B.alloc({KU}), 0, {lw}), Some{{{OW}}}),
    {SI}.{SIlaw}({", ".join(ws)}))

def {p}_asome(+bs: +List<U32>, +{HD}, +{EC("True{}")}) -> {{{API_} == Some{{{VW}}} : {MV}}}:
  E2E.spec_accepted(Spec.{sn}(), bs, {VW}, (VS.public_sound(Spec.{sn}(), {{==}}),
    %{p}_pk(bs, hd, ec) : {{Encoding.encoding_for_legal_type(Spec.{sn}(), {VW}) == Some{{_}} : Maybe<&2, +List<U32>>}}
    {SE}.{SElaw}({", ".join(ws)})))

def {p}_v(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +c: Bool, +{EC("c")}) -> {{{R}_mv({RES}) == {API_} : {MV}}}:
  match c:
    case False{{}}:
      %Equal.sym({M1}, {RES}, None{{}}, {p}_none(bs, n, hn, ec)) : {{{R}_mv(_) == {API_} : {MV}}}
      %Equal.sym({MV}, {API_}, None{{}}, {p}_anone(bs, ec)) : {{{R}_mv(None{{}}) == _ : {MV}}}
      {{==}}
    case True{{}}:
      %Equal.sym({M1}, {RES}, Some{{{OW}}}, {p}_some(bs, n, hn, hd, ec)) : {{{R}_mv(_) == {API_} : {MV}}}
      %Equal.sym({MV}, {API_}, Some{{{VW}}}, {p}_asome(bs, hd, ec)) : {{{R}_mv(Some{{{OW}}}) == _ : {MV}}}
      {{==}}

def {p}_ra(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +c: Bool, +{EC("c")}, +dn: {{{RES} == None{{}} : {M1}}}) -> {{{API_} == None{{}} : {MV}}}:
  match c:
    case False{{}}: {p}_anone(bs, ec)
    case True{{}}: Empty.absurd({{{API_} == None{{}} : {MV}}}, E.none_someT({ot}, {OW}, Equal.trans({M1}, None{{}}, {RES}, Some{{{OW}}}, Equal.sym({M1}, {RES}, None{{}}, dn), {p}_some(bs, n, hn, hd, ec))))

def {p}_rb(+bs: +List<U32>, +n: U32, +{HN}, +{HD}, +c: Bool, +{EC("c")}, +an: {{{API_} == None{{}} : {MV}}}) -> {{{RES} == None{{}} : {M1}}}:
  match c:
    case False{{}}: {p}_none(bs, n, hn, ec)
    case True{{}}: Empty.absurd({{{RES} == None{{}} : {M1}}}, FD.logic__none_some(S.Value, {VW}, Equal.trans({MV}, None{{}}, {API_}, Some{{{VW}}}, Equal.sym({MV}, {API_}, None{{}}, an), {p}_asome(bs, hd, ec))))

# (ii), on views: the view of the object the decoder returns is END_TO_END's deserialize.
def {R}_e2e_decode_view(+bs: +List<U32>, +n: U32, +{HN}, +{HD}) -> {{{R}_mv({RES}) == {API_} : {MV}}}:
  {p}_v(bs, n, hn, hd, Nat.is_eq({LEN}, {KN}), {{==}})

# (iii) the object decoder fails exactly when END_TO_END's deserialize does.
def {R}_e2e_decode_reject(+bs: +List<U32>, +n: U32, +{HN}, +{HD})
    -> ({{{RES} == None{{}} : {M1}}} -> {{{API_} == None{{}} : {MV}}}) & ({{{API_} == None{{}} : {MV}}} -> {{{RES} == None{{}} : {M1}}}):
  (dn => {p}_ra(bs, n, hn, hd, Nat.is_eq({LEN}, {KN}), {{==}}, dn), an => {p}_rb(bs, n, hn, hd, Nat.is_eq({LEN}, {KN}), {{==}}, an))
'''


def decode_w(r, m, cache):
    di, dn, dr = m.get('decode_input', []), m.get('decode_none', []), m.get('decode_reject', [])
    if not (di and dn and dr):
        return None
    xs = r['xs']
    K = 4 * len(xs)
    lim = f'F.limbs([{", ".join(xs)}])'
    b_di, b_dn, b_dr = law(cache, di[0]), law(cache, dn[0]), law(cache, dr[0])
    en = r['ename']
    mi = re.match(r'\{T\.' + en + r'_decode\(B\.fill_at\(B\.alloc\(' + str(K) + r'\), 0, ' + re.escape(lim) + r'\), ' + str(K) +
                  r'\) == \(B\.fill_at\(B\.alloc\(' + str(K) + r'\), 0, ' + re.escape(lim) + r'\), Some\{(O\.Words\{.*\})\}\) : B\.Buf & Maybe<&1, O\.Words>\}$', b_di[3])
    if not mi or [v for v, _ in (pvars(b_di[2]) or [])] != xs:
        return None
    if [q.strip() for q in b_dn[2]] != ['buf: B.Buf', '+m: U32', f'e: {{U32.is_eq(m, {K}) == False{{}} : Bool}}']:
        return None
    if [q.strip() for q in b_dr[2]] != ['+bs: +List<U32>', f'+hn: {{Nat.is_eq(List.length(&2, U32, bs), {K}n) == False{{}} : Bool}}']:
        return None
    return {'di': di[0], 'dn': dn[0], 'dr': dr[0], 'dobj': mi.group(1)}


VDHEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API',
          'import ../src/buffer.bend as B', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S',
          'import ../types/primitive.bend as P', 'import ../spec/codec.bend as Encoding', 'import ../spec/primitives.bend as SP',
          'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
          'import ../proofs/obj/spec_fixed.bend as F', 'import ../proofs/obj/packed_obj.bend as PK', 'import ./e2e_bytes.bend as E']


def text_wdec(rows):
    files = []
    for r in rows:
        for f in (r['dd']['di']['file'], r['dd']['dn']['file'], r['dd']['dr']['file'], r['es']['file']):
            if f not in files:
                files.append(f)
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L = list(VDHEAD) + (GEN_IMPORTS if any(r['generic'] for r in rows) else ['import ../types/fulu_obj.bend as T', 'import ../spec/fulu_schemas.bend as Spec'])
    L += ['import ../proofs/obj/words_root.bend as WR'] if any(r.get('kind') == 'words' for r in rows) else []
    L += [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (word storage): the object API\'s decoder on a byte list against',
          '# END_TO_END\'s deserialize, (ii) through the view (storage words past the data are not part of the value).', '']
    for r in rows:
        n0 = len(L)
        d = r['dd']
        ea = file_aliases(r['es']['file'])
        value = requal(r['value'], ea)
        VIEWF = f'PK.vview{r["K"]}' if r.get('kind', 'rep') == 'rep' else f'{r["R"]}_ov'
        if r.get('kind') == 'words':
            a = r['a']
            L.append(f'def {r["R"]}_ov(o: O.Words) -> S.Value:')
            L.append('  match o:')
            L.append(f'    case O.Words{{ws, +n}}: {requal(a["dec_value"], a["alias"]).replace("FD.array__slots(U32, t)", "FD.array__slots(U32, FD.array__freeze(U32, ws))")}')
            L.append('')
        L.append(dec_view_text(r['R'], r['ename'], 'O.Words', r['sname'], VIEWF, d['dobj'], value, r['xs'],
                               al[d['di']['file']], d['di']['law'], al[d['dn']['file']], d['dn']['law'],
                               al[d['dr']['file']], d['dr']['law'], al[r['es']['file']], r['es']['law']))
        if r['generic']:
            L[n0:] = [gfix(x) for x in L[n0:]]
    return '\n'.join(L) + '\n'


RHEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API',
         'import ../src/buffer.bend as B', 'import ../src/digest.bend as D', 'import ../src/obj.bend as O',
         'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
         'import ../proofs/obj/packed_obj.bend as PK', 'import ../proofs/obj/words_obj.bend as WO', 'import ./e2e_support.bend as E']


def wvalid(r):
    """the name's structural-validity lemma over the root law's binders (codegen/valid_laws.py)"""
    for f in sorted(OBJ.glob('gvalid_*.bend')):
        if re.search(r'^def ' + r['X'] + r'_root_valid\(-o: O\.Words, \+s: S\.Schema, \+es: \{s == Spec\.' + r['sname'] +
                     r'\(\) : S\.Schema\}, \+rep: PK\.rep_v' + r['K'] + r'\(o, s\)\)', f.read_text(), re.M):
            return f.name
    return None


def text_wroot(rows):
    files = []
    for r in rows:
        for f in (r['rt']['file'], r['vf']):
            if f not in files:
                files.append(f)
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L = list(RHEAD) + (GEN_IMPORTS if any(r['generic'] for r in rows) else ['import ../types/fulu_obj.bend as T', 'import ../spec/fulu_schemas.bend as Spec'])
    L += [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (word storage): the object API\'s root is END_TO_END\'s',
          '# hash_tree_root at the view, under the root law\'s representation invariant.', '']
    for r in rows:
        n0 = len(L)
        R, X, en, sn, K = r['R'], r['X'], r['ename'], r['sname'], r['K']
        RTf, VVf = al[r['rt']['file']], al[r['vf']]
        ON = 'O.Words{FD.array__thaw(U32, t), N}'
        RT = lambda o: f'D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, T.{en}_hash_tree_root(h, {o}))))'  # noqa: E731
        G = lambda o: f'{{Some{{{RT(o)}}} == API.hash_tree_root(Spec.{sn}(), PK.vview{K}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
        REP = lambda o: f'PK.rep_v{K}({o}, Spec.{sn}())'  # noqa: E731
        L.append(f'# {R} ({X})')
        L.append(f'def {R}_r2(h: B.Buf, +t: FD.array__Tree<U32>, +N: U32, +rep: {REP(ON)}) -> {G(ON)}:')
        L.append(f'  E.root_legal(Spec.{sn}(), PK.vview{K}({ON}), VS.public_sound(Spec.{sn}(), {{==}}), {RT(ON)},')
        L.append(f'    {VVf}.{X}_root_valid({ON}, Spec.{sn}(), {{==}}, rep), {RTf}.{r["rt"]["law"]}(h, {ON}, Spec.{sn}(), {{==}}, rep))')
        L.append('')
        L.append(f'def {R}_r1(h: B.Buf, -o: O.Words, +w: WO.wf1(o), +rep: {REP("o")}) -> {G("o")}:')
        for a, b, src in (('t', 'w1', 'w'), ('dw', 'w2', 'w1'), ('N', 'w3', 'w2'), ('q', 'w4', 'w3'), ('r', 'w5', 'w4'), ('eo', 'w6', 'w5')):
            L.append(f'  (+{a}, {b}) = {src}')
        L.append(f'  %Equal.sym(O.Words, o, {ON}, eo) : {G("_")}')
        L.append(f'  {R}_r2(h, t, N, FD.logic__subst(O.Words, z => {REP("z")}, o, {ON}, eo, rep))')
        L.append('')
        L.append(f'# (iv) under rep (the root law\'s invariant; no depth premise).')
        L.append(f'def {R}_e2e_root(h: B.Buf, -o: O.Words, +rep: {REP("o")}) -> {G("o")}:')
        L.append('  (+w, +rest) = rep')
        L.append(f'  {R}_r1(h, o, w, rep)')
        L.append('')
        if r['generic']:
            L[n0:] = [gfix(x) for x in L[n0:]]
    return '\n'.join(L) + '\n'


# ---- word storage, any depth (the root worker's <X>_encode_any / <X>_decodes_any) ----

ANYHEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API',
           'import ../src/buffer.bend as B', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S',
           'import ../spec/codec.bend as Encoding', 'import ../proofs/type_validator_soundness.bend as VS',
           'import ../proofs/compact/found.bend as FD', 'import ../proofs/obj/spec_fixed.bend as F',
           'import ../proofs/obj/packed_obj.bend as PK', 'import ../proofs/obj/words_obj.bend as WO',
           'import ../proofs/obj/vspec.bend as VSP', 'import ../proofs/obj/words_root.bend as WR', 'import ./e2e_support.bend as E']


def any_info(X):
    """the any-depth laws and the encoder's shape: (file, law binders, NW, value, put, out depth, N)"""
    for f in sorted(OBJ.glob('spec_[gw]any_*.bend')):
        src = f.read_text()
        m = re.search(r'^def ' + X + r'_encode_any\((.*)\)\n    -> \{SF\.emitted\(O\.Words, T\.' + X + r'_encode\((.*?)\), (\d+)\) == ', src, re.M)
        if not m:
            continue
        md = re.search(r'^def ' + X + r'_decodes_any\((.*)\)\n    -> Decoding\.decodes\((\w+|Spec\.\w+\(\)), (.*)\):$', src, re.M)
        if not md:
            return None
        rt = (ROOT / 'types' / ('generic_obj.bend' if 'types/generic_obj.bend as T' in src else 'fulu_obj.bend')).read_text()
        me = re.search(r'^def ' + X + r'_encode\(o: O\.Words\) -> O\.Words & B\.Buf: ' + X + r'_enc_out\((\w+)\(O\.out_at\((\d+)n\), 0, o\)\)$', rt, re.M)
        mo = re.search(r'^def ' + X + r'_enc_out\(pair: Array<U32> & O\.Words\) -> O\.Words & B\.Buf:\n  \(out, o\) = pair\n  \(o, O\.out_done\((\d+), out\)\)$', rt, re.M)
        if not (me and mo):
            return None
        return {'file': f.name, 'binders': m.group(1), 'obj': m.group(2), 'NW': m.group(3), 'dec': md.group(3),
                'put': me.group(1), 'outd': me.group(2), 'N': mo.group(1)}
    return None


def any_core(R, X, sn, OBJ, VIEW, enc_call, dec_call, a):
    """(i) at an explicit object term OBJ over copyable variables: the encoder's buffer by the
    pair eta of its writer, then the any-depth laws"""
    M = 'Maybe<&2, +List<U32>>'
    P = f'T.{a["put"]}(O.out_at({a["outd"]}n), 0, {OBJ})'
    FP = f'Pair.fst(Array<U32>, O.Words, {P})'
    SP_ = f'Pair.snd(Array<U32>, O.Words, {P})'
    EM = f'B.emit(B.Buf{{{FP}, {a["N"]}}}, 0, {a["NW"]})'
    L = []
    L.append(f'  +e = E4.peta(Array<U32>, O.Words, {P})')
    L.append(f'  +em = FD.logic__subst(Array<U32> & O.Words, q => {{F.emitted(O.Words, T.{X}_enc_out(q), {a["NW"]}) == ({OBJ}, WV) : O.Words & +List<U32>}}, {P}, ({FP}, {SP_}), e,')
    L.append(f'    {enc_call})')
    L.append(f'  +eb = Equal.trans(+List<U32>, Pair.snd(B.Buf, +List<U32>, {EM}), F.listed({EM}), WV, Equal.sym(+List<U32>, F.listed({EM}), Pair.snd(B.Buf, +List<U32>, {EM}), E4.lst({EM})),')
    L.append(f'    FD.logic__pair_snd(O.Words, +List<U32>, {SP_}, F.listed({EM}), {OBJ}, WV, em))')
    L.append(f'  %Equal.sym(Array<U32> & O.Words, {P}, ({FP}, {SP_}), e) : {{Some{{E.obytes(Pair.snd(O.Words, B.Buf, T.{X}_enc_out(_)))}} == API.serialize(Spec.{sn}(), {VIEW}) : {M}}}')
    L.append(f'  Equal.trans({M}, Some{{Pair.snd(B.Buf, +List<U32>, {EM})}}, Some{{WV}}, API.serialize(Spec.{sn}(), {VIEW}),')
    L.append(f'    Equal.cong(+List<U32>, {M}, z => Some{{z}}, Pair.snd(B.Buf, +List<U32>, {EM}), WV, eb),')
    L.append(f'    Equal.sym({M}, API.serialize(Spec.{sn}(), {VIEW}), Some{{WV}},')
    L.append(f'      Equal.trans({M}, API.serialize(Spec.{sn}(), {VIEW}), Encoding.encoding_for_legal_type(Spec.{sn}(), {VIEW}), Some{{WV}},')
    L.append(f'        E.serialize_legal(Spec.{sn}(), {VIEW}, VS.public_sound(Spec.{sn}(), {{==}})), {dec_call})))')
    return '\n'.join(L)


def text_any(rows):
    files = []
    for r in rows:
        if r['a']['file'] not in files:
            files.append(r['a']['file'])
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L = list(ANYHEAD) + (GEN_IMPORTS if any(r['generic'] for r in rows) else ['import ../types/fulu_obj.bend as T', 'import ../spec/fulu_schemas.bend as Spec'])
    L += ['import ./e2e_any.bend as E4'] + [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (word storage, any depth): the object API\'s encoder bytes are',
          '# END_TO_END\'s serialize, over the root law\'s own binders (no depth premise).', '']
    for r in rows:
        n0 = len(L)
        R, X, sn, a = r['R'], r['X'], r['sname'], r['a']
        MA = al[a['file']]
        L.append(f'# {R} ({X})')
        if r['kind'] == 'rep':
            K = r['K']
            ON = 'O.Words{FD.array__thaw(U32, t), N}'
            VIEW = f'PK.vview{K}({ON})'
            G = lambda o: f'{{Some{{E.obytes(Pair.snd(O.Words, B.Buf, T.{X}_encode({o})))}} == API.serialize(Spec.{sn}(), PK.vview{K}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
            L.append(f'def {R}_a1(+t: FD.array__Tree<U32>, +N: U32, +rep: PK.rep_v{K}({ON}, Spec.{sn}())) -> {G(ON)}:')
            core = any_core(R, X, sn, ON, VIEW, f'{MA}.{X}_encode_any({ON}, Spec.{sn}(), {{==}}, rep)', f'{MA}.{X}_decodes_any({ON}, Spec.{sn}(), {{==}}, rep)', a)
            L.append(core.replace('WV', f'WO.wview({ON})'))
            L.append('')
            L.append(f'# (i) under rep (the root law\'s representation invariant), at any storage depth.')
            L.append(f'def {R}_e2e_encode(-o: O.Words, +rep: PK.rep_v{K}(o, Spec.{sn}())) -> {G("o")}:')
            L.append('  (+w, +rest) = rep')
            for x, y, src in (('t', 'w1', 'w'), ('dw', 'w2', 'w1'), ('N', 'w3', 'w2'), ('q', 'w4', 'w3'), ('r', 'w5', 'w4'), ('eo', 'w6', 'w5')):
                L.append(f'  (+{x}, {y}) = {src}')
            L.append(f'  %Equal.sym(O.Words, o, {ON}, eo) : {G("_")}')
            L.append(f'  {R}_a1(t, N, FD.logic__subst(O.Words, z => PK.rep_v{K}(z, Spec.{sn}()), o, {ON}, eo, rep))')
        else:
            OBJ = requal(a['obj'], a['alias'])
            VIEW = requal(a['dec_value'], a['alias'])
            args = ', '.join(re.findall(r'\+(\w+):', a['binders']))
            WV = requal(a['wv'], a['alias'])
            L.append(f'# (i) over the root law\'s binders (t, dw, hd, pf, cap), o = {OBJ}.')
            L.append(f'def {R}_e2e_encode({requal(a["binders"], a["alias"])}) -> {{Some{{E.obytes(Pair.snd(O.Words, B.Buf, T.{X}_encode({OBJ})))}} == API.serialize(Spec.{sn}(), {VIEW}) : Maybe<&2, +List<U32>>}}:')
            core = any_core(R, X, sn, OBJ, VIEW, f'{MA}.{X}_encode_any({args})', f'{MA}.{X}_decodes_any({args})', a)
            L.append(core.replace('WV', WV))
        L.append('')
        if r['generic']:
            L[n0:] = [gfix(x) for x in L[n0:]]
    return '\n'.join(L) + '\n'


ANYSUP = """import Base
import ../src/buffer.bend as B
import ../proofs/obj/spec_fixed.bend as F

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# Pair eta, and the proof-side byte list of a buffer (spec_fixed.listed) as its second component.

def peta(-A: Type, -C: Type, p: A & C) -> {p == (Pair.fst(A, C, p), Pair.snd(A, C, p)) : A & C}:
  (a, c) = p
  {==}

def lst(p: B.Buf & +List<U32>) -> {F.listed(p) == Pair.snd(B.Buf, +List<U32>, p) : +List<U32>}:
  (b, xs) = p
  {==}
"""


def text_broot(rows):
    files = []
    for r in rows:
        for f in (r['rt']['file'], 'gvalid_words.bend'):
            if f not in files:
                files.append(f)
    al = {f: f'M{i}' for i, f in enumerate(files)}
    L = list(RHEAD) + ['import ../types/schema.bend as S', 'import ../proofs/obj/words_root.bend as WR', 'import ../types/fulu_obj.bend as T', 'import ../spec/fulu_schemas.bend as Spec']
    L += [f'import ../proofs/obj/{f} as {a}' for f, a in al.items()]
    L += ['', '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
          f'# {rows[0]["R"]} and the next names (word-storage branches): the object API\'s root is END_TO_END\'s',
          '# hash_tree_root, over the root law\'s binders.', '']
    for r in rows:
        X, R, a = r['X'], r['R'], r['a']
        OBJ = requal(a['obj'], a['alias'])
        VIEW = requal(a['dec_value'], a['alias'])
        B_ = requal(a['binders'], a['alias'])
        args = ', '.join(re.findall(r'\+(\w+):', a['binders']))
        RT = f'D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, T.{X}_hash_tree_root(h, {OBJ}))))'
        L.append(f'# {R} ({X})')
        L.append(f'def {R}_e2e_root(h: B.Buf, {B_}) -> {{Some{{{RT}}} == API.hash_tree_root(Spec.{X}(), {VIEW}) : Maybe<&2, +List<U32>>}}:')
        L.append(f'  E.root_legal(Spec.{X}(), {VIEW}, VS.public_sound(Spec.{X}(), {{==}}), {RT},')
        L.append(f'    {al["gvalid_words.bend"]}.{X}_root_valid({args}), {al[r["rt"]["file"]]}.{r["rt"]["law"]}(h, {args}))')
        L.append('')
    return '\n'.join(L) + '\n'

def outputs():
    import names as NM
    amap = json.loads((ROOT / 'proofs/gate/api_map.json').read_text())
    readable = NM.mapping()
    cache, vidx = {}, valid_index()
    fam, uncovered = [], {}
    for X in amap['fulu'] + amap['generic']:
        r, why = family_a(X, amap['map'][X], cache, vidx)
        R = readable[X]
        if r is not None and X in VIEW_TODO:
            r, why = None, 'root view (wbits of the words) differs from encode_spec value (bitsof): needs a view lemma'
        if r is None:
            uncovered[R] = {'generated_name': X, 'reason': why}
            continue
        r['R'] = R
        r['ee_alias'] = file_aliases(r['ee']['file'])
        r['generic'] = 'types/generic_obj.bend as T' in (OBJ / r['ee']['file']).read_text()
        fam.append(r)
    # a readable name shared by a Fulu name and a generic form (the basic types): the generic
    # form's laws carry its generated name
    seen = {}
    for r in fam:
        seen.setdefault(r['R'], []).append(r)
    for R, rs in seen.items():
        if len(rs) > 1:
            for r in rs:
                if r['generic']:
                    r['R'] = f'{R}_{r["X"]}'
    # batch by proving modules (root module first: it carries the heavy imports)
    fam.sort(key=lambda r: (r['rt']['file'], r['ee']['file'], r['R']))
    batches, cur, key = [], [], None
    for r in fam:
        k = (r['rt']['file'], r['ee']['file'])
        if cur and (k != key or len(cur) >= BATCH):
            batches.append(cur)
            cur = []
        cur.append(r)
        key = k
    if cur:
        batches.append(cur)
    out = {OUT / 'e2e_support.bend': SUPPORT, OUT / 'e2e_bytes.bend': BYTES_HEAD + lwb_text() + '\n' + BYTES_TAIL,
           OUT / 'e2e_bits.bend': BITS, OUT / 'e2e_tree.bend': TREE}
    wrows = []
    for R0, u in list(uncovered.items()):
        w = family_w(u['generated_name'], amap['map'][u['generated_name']], cache)
        if w:
            w['R'] = R0
            wrows.append(w)
            del uncovered[R0]
    man = {'files': {}, 'uncovered': uncovered, 'decode_uncovered': {},
           'root_awaiting': {r['R']: {'generated_name': r['X'], 'awaiting': 'root_valid(view)', 'view': f'{r["rt"]["file"]}:{r["view"]}'}
                             for r in fam if not r['vx']}}
    drows = []
    for r in fam:
        d, why = decode_a(r, amap['map'][r['X']], cache)
        if d is None:
            man['decode_uncovered'][r['R']] = {'generated_name': r['X'], 'reason': why}
            continue
        r['d'] = d
        drows.append(r)
    dbatches, cur = [], []
    for r in drows:
        if cur and ((r['rt']['file'], r['ee']['file']) != (cur[0]['rt']['file'], cur[0]['ee']['file']) or
                    len(cur) >= DBATCH or sum(len(q['P']) for q in cur) + len(r['P']) > DWORDS):
            dbatches.append(cur)
            cur = []
        cur.append(r)
    if cur:
        dbatches.append(cur)
    for i, rows in enumerate(dbatches):
        fn = f'{rows[0]["R"]}_e2e_dec_generated.bend'
        out[OUT / fn] = text_dec(rows, i)
        man['files'][fn] = [{'name': r['R'], 'generated_name': r['X'], 'laws': [f'{r["R"]}_e2e_decode_accept', f'{r["R"]}_e2e_decode_reject']} for r in rows]
    for i, rows in enumerate(batches):
        fn = f'{rows[0]["R"]}_e2e_generated.bend'
        out[OUT / fn] = text_a(rows, i)
        man['files'][fn] = [{'name': r['R'], 'generated_name': r['X'], 'laws': [f'{r["R"]}_e2e_encode'] + ([f'{r["R"]}_e2e_root'] if r['vx'] else [])} for r in rows]
    # (i) for word storage from the any-depth laws: the generic vectors (rep) and the arrays and
    # branches the older laws did not cover
    wrows.sort(key=lambda r: (r['ee']['file'], r['R']))
    arows = []
    for r in wrows:
        a = any_info(r['X'])
        if a:
            a['alias'] = file_aliases(a['file'])
            arows.append(dict(r, a=a, kind='rep'))
    for R0, u in list(uncovered.items()):
        X0 = u['generated_name']
        a = any_info(X0)
        m0 = amap['map'][X0]
        if not a or not m0.get('root'):
            continue
        a['alias'] = file_aliases(a['file'])
        b_rt = law(cache, m0['root'][0])
        rp = [q.strip() for q in b_rt[2]]
        gen = 'types/generic_obj.bend as T' in (OBJ / a['file']).read_text()
        ms_ = re.search(r'\{s == Spec\.(\w+)\(\) : S\.Schema\}', ' '.join(rp))
        mk = re.match(r'\+rep: PK\.rep_v(\d+)\(o, s\)$', rp[-1]) if len(rp) == 5 else None
        if mk and ms_ and rp[1] == '-o: O.Words' and re.match(r'RR\.roots\(PK\.vview' + mk.group(1) + r'\(o\), s, ', b_rt[3]):
            row = {'X': X0, 'R': R0, 'sname': ms_.group(1), 'K': mk.group(1), 'ename': X0, 'rt': m0['root'][0], 'generic': gen, 'a': a, 'kind': 'rep'}
        elif rp[:1] == ['-h: B.Buf'] and [q.split(':')[0] for q in rp[1:]] == ['+t', '+dw', '+hd', '+pf', '+cap']:
            mv = re.match(r'(Spec\.\w+\(\)|\w+), (.*)$', a['dec'])
            wv = re.search(r'== \(O\.Words\{.*?\}, (.*)\) : O\.Words & \+List<U32>\}', (OBJ / a['file']).read_text().split('def ' + X0 + '_encode_any(')[1].split('\n')[1])
            dv = call_args('D(' + a['dec'] + ')', 'D')
            row = {'X': X0, 'R': R0, 'sname': X0, 'rt': m0['root'][0], 'generic': gen, 'a': dict(a, dec_value=dv[1], wv=wv.group(1)), 'kind': 'words'}
        else:
            continue
        arows.append(row)
        del uncovered[R0]
    arows.sort(key=lambda r: (r['a']['file'], r['R']))
    ab, cur = [], []
    for r in arows:
        if cur and (r['a']['file'] != cur[0]['a']['file'] or len(cur) >= WBATCH):
            ab.append(cur)
            cur = []
        cur.append(r)
    if cur:
        ab.append(cur)
    out[OUT / 'e2e_any.bend'] = ANYSUP
    for rows in ab:
        fn = f'{rows[0]["R"]}_e2e_generated.bend'
        out[OUT / fn] = text_any(rows)
        man['files'][fn] = [{'name': r['R'], 'generated_name': r['X'], 'laws': [f'{r["R"]}_e2e_encode'],
                             'premise': (f'rep: PK.rep_v{r["K"]}(o, Spec.{r["sname"]}()) (the root law\'s representation invariant: the validity premise for generic forms)'
                                         if r['kind'] == 'rep' else 'the root law\'s binders (t, dw, hd, pf, cap)')} for r in rows]
    wrows_extra = [r for r in arows if 'ee' not in r]
    for r in wrows_extra:
        if r['kind'] != 'words':
            continue
        m0 = amap['map'][r['X']]
        es0 = m0.get('encode_spec', [])
        if not es0:
            continue
        b_es = law(cache, es0[0])
        P0 = pvars(b_es[2])
        ms0 = re.match(r'Decoding\.decodes\(Spec\.(\w+)\(\), F\.limbs\(\[(.*?)\]\), (.*)\)$', b_es[3])
        if not P0 or not ms0 or [v for v, _ in P0] != [x.strip() for x in ms0.group(2).split(',')]:
            continue
        r.update({'xs': [v for v, _ in P0], 'value': ms0.group(3), 'ename': r['X'], 'es': es0[0], 'ee': es0[0]})
    wd = []
    for r in wrows + [x for x in wrows_extra if x.get('xs')]:
        d = decode_w(r, amap['map'][r['X']], cache)
        if d:
            r['dd'] = d
            wd.append(r)
    wdb, cur = [], []
    for r in wd:
        if cur and (r['ee']['file'] != cur[0]['ee']['file'] or len(cur) >= DBATCH or sum(len(q['xs']) for q in cur) + len(r['xs']) > DWORDS):
            wdb.append(cur)
            cur = []
        cur.append(r)
    if cur:
        wdb.append(cur)
    for rows in wdb:
        fn = f'{rows[0]["R"]}_e2e_dec_generated.bend'
        out[OUT / fn] = text_wdec(rows)
        man['files'][fn] = [{'name': r['R'], 'generated_name': r['X'], 'laws': [f'{r["R"]}_e2e_decode_view', f'{r["R"]}_e2e_decode_reject'], 'ii': 'view'} for r in rows]
    wr = []
    for r in wrows + [x for x in wrows_extra if x['kind'] == 'rep']:
        vf = wvalid(r)
        if vf:
            r['vf'] = vf
            wr.append(r)
    wrb, cur = [], []
    for r in wr:
        if cur and (r['rt']['file'] != cur[0]['rt']['file'] or len(cur) >= WRBATCH):
            wrb.append(cur)
            cur = []
        cur.append(r)
    if cur:
        wrb.append(cur)
    for rows in wrb:
        fn = f'{rows[0]["R"]}_e2e_root_generated.bend'
        out[OUT / fn] = text_wroot(rows)
        man['files'][fn] = [{'name': r['R'], 'generated_name': r['X'], 'laws': [f'{r["R"]}_e2e_root'],
                             'premise': f'rep: PK.rep_v{r["K"]}(o, Spec.{r["sname"]}())'} for r in rows]
    brows = [x for x in wrows_extra if x['kind'] == 'words' and (OBJ / 'gvalid_words.bend').exists() and
             re.search(r'^def ' + x['X'] + r'_root_valid\(', (OBJ / 'gvalid_words.bend').read_text(), re.M)]
    if brows:
        fn = f'{brows[0]["R"]}_e2e_root_generated.bend'
        out[OUT / fn] = text_broot(brows)
        man['files'][fn] = [{'name': r['R'], 'generated_name': r['X'], 'laws': [f'{r["R"]}_e2e_root'], 'premise': 'the root law\'s binders (t, dw, hd, pf, cap)'} for r in brows]
    for r in brows:
        r['vf'] = 'gvalid_words.bend'
    man['word_storage'] = {r['R']: {'generated_name': r['X'], 'awaiting': ([] if 'vf' in r else ['(iv)']) + ([] if 'dd' in r else ['(ii)/(iii)'])} for r in wrows + wrows_extra}
    for f, rows_ in man['files'].items():
        for e in rows_:
            if any(l.endswith('_e2e_decode_accept') for l in e['laws']):
                e['ii'] = 'exact'
    out[OUT / 'manifest.json'] = json.dumps(man, indent=1) + '\n'
    return out


def main():
    out = outputs()
    mine = list(OUT.glob('*_generated.bend')) if OUT.exists() else []
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out]
        if stale or orphans:
            print('stale e2e bridge: ' + ', '.join((stale + orphans)[:20]))
            sys.exit(1)
        print('e2e bridge is current')
        return
    OUT.mkdir(exist_ok=True)
    for q in mine:
        if q not in out:
            q.unlink()
    for p, t in out.items():
        p.write_text(t)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
