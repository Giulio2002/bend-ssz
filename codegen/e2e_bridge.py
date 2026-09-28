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
import runtime_refs as RR  # noqa: E402  the runtime split: the modules import the per-name files they use

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


LOAD = r'''import Base
import ../src/buffer.bend as B
import ../src/primitives.bend as I
import ../spec/primitives.bend as SP
import ../proofs/compact/found.bend as FD
import ../proofs/primitive_invariants.bend as V
import ../proofs/obj/spec_fixed.bend as F
import ./e2e_bytes.bend as E
import ../proofs/obj/arr_copy.bend as AC
import ../proofs/obj/arr_enc.bend as AN
import ../proofs/obj/arr_emit.bend as AE
import ../proofs/obj/vspec.bend as VSP

# The loader on a byte list (B.fill_at over a zero tree): the words it packs the bytes into, and the
# tree it builds (the segment tree of those words), for the variable-size decode bridges.

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# The loader on a byte list (B.fill_at over a zero tree): the words it packs the bytes into, the tree it
# builds (the segment tree of those words, bf) and that tree's byte view (vw), for the variable-size
# decode bridges. bf takes the capacity facts (d = B.capacity(n) < 32 and 2^d holds the words).

# The words the loader packs a byte list into (as B.fill_go: four bytes a word, the last word
# zero-padded).
def wlp(+bs: +List<U32>) -> List<&2, U32>:
  match bs:
    case Con{a, Con{b, Con{c, Con{d, r}}}}: Con{B.word_of(a, b, c, d), wlp(r)}
    case Con{a, Con{b, Con{c, Nil{}}}}: Con{B.word_of(a, b, c, 0), Nil{}}
    case Con{a, Con{b, Nil{}}}: Con{B.word_of(a, b, 0, 0), Nil{}}
    case Con{a, Nil{}}: Con{B.word_of(a, 0, 0, 0), Nil{}}
    case Nil{}: Nil{}

def IH(+r: +List<U32>) -> Type:
  @-ws: Array<U32> -> @+i: U32 -> {B.fill_go(r, ws, i) == B.fill_go(F.limbs(wlp(r)), ws, i) : Array<U32>}

def REC(+g: Nat) -> Type:
  @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hf: {Nat.is_le(List.length(&2, U32, r), g) == True{} : Bool} -> IH(r)

def le3(+x: Nat) -> {Nat.is_le(x, 3n+x) == True{} : Bool}:
  FD.nat__le_trans(x, 1n+x, 3n+x, FD.nat__le_succ(x), FD.nat__le_trans(1n+x, 2n+x, 3n+x, FD.nat__le_succ(1n+x), FD.nat__le_succ(2n+x)))

def lp4(+a: U32, +b: U32, +c: U32, +d: U32, +r: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, Con{c, Con{d, r}}}}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}), 1n+g) == True{} : Bool}, rec: REC(g), -ws: Array<U32>, +i: U32)
    -> {B.fill_go(Con{a, Con{b, Con{c, Con{d, r}}}}, ws, i) == B.fill_go(F.limbs(wlp(Con{a, Con{b, Con{c, Con{d, r}}}})), ws, i) : Array<U32>}:
  +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Con{d, r}}}), hd)
  +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Con{d, r}}}), hd)
  +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Con{d, r}}), h1)
  +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Con{d, r}}), h1)
  +ec = V.and_left(U32.is_lt(c, 256), SP.bytes_domain(Con{d, r}), h2)
  +h3 = V.and_right(U32.is_lt(c, 256), SP.bytes_domain(Con{d, r}), h2)
  +ed = V.and_left(U32.is_lt(d, 256), SP.bytes_domain(r), h3)
  +hr = V.and_right(U32.is_lt(d, 256), SP.bytes_domain(r), h3)
  %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, c, d)), [a, b, c, d], E.lwb(a, b, c, d, ea, eb, ec, ed)) :
    {B.fill_go(Con{a, Con{b, Con{c, Con{d, r}}}}, ws, i) == B.fill_go(List.append(&2, U32, _, F.limbs(wlp(r))), ws, i) : Array<U32>}
  rec(r, hr, FD.nat__le_trans(List.length(&2, U32, r), 3n+List.length(&2, U32, r), g, le3(List.length(&2, U32, r)), hf), Array.set(U32, ws, i, B.word_of(a, b, c, d)), (i + 1 : U32))

def lp3(+a: U32, +b: U32, +c: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, Con{c, t}}}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, t}}}), 1n+g) == True{} : Bool}, rec: REC(g), -ws: Array<U32>, +i: U32) -> {B.fill_go(Con{a, Con{b, Con{c, t}}}, ws, i) == B.fill_go(F.limbs(wlp(Con{a, Con{b, Con{c, t}}})), ws, i) : Array<U32>}:
  match t:
    case Nil{}:
      +h0 = hd
      +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Nil{}}}), h0)
      +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Nil{}}}), h0)
      +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Nil{}}), h1)
      +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Nil{}}), h1)
      +ec = V.and_left(U32.is_lt(c, 256), SP.bytes_domain(Nil{}), h2)
      +h3 = V.and_right(U32.is_lt(c, 256), SP.bytes_domain(Nil{}), h2)
      %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, c, 0)), [a, b, c, 0], E.lwb(a, b, c, 0, ea, eb, ec, {==})) :
        {B.fill_go(Con{a, Con{b, Con{c, Nil{}}}}, ws, i) == B.fill_go(List.append(&2, U32, _, []), ws, i) : Array<U32>}
      {==}
    case Con{+d, +r}: lp4(a, b, c, d, r, hd, g, hf, rec, ws, i)

def lp2(+a: U32, +b: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, t}}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, t}}), 1n+g) == True{} : Bool}, rec: REC(g), -ws: Array<U32>, +i: U32) -> {B.fill_go(Con{a, Con{b, t}}, ws, i) == B.fill_go(F.limbs(wlp(Con{a, Con{b, t}})), ws, i) : Array<U32>}:
  match t:
    case Nil{}:
      +h0 = hd
      +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Nil{}}), h0)
      +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Nil{}}), h0)
      +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Nil{}), h1)
      +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Nil{}), h1)
      %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, 0, 0)), [a, b, 0, 0], E.lwb(a, b, 0, 0, ea, eb, {==}, {==})) :
        {B.fill_go(Con{a, Con{b, Nil{}}}, ws, i) == B.fill_go(List.append(&2, U32, _, []), ws, i) : Array<U32>}
      {==}
    case Con{+c, +r}: lp3(a, b, c, r, hd, g, hf, rec, ws, i)

def lp1(+a: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, t}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, t}), 1n+g) == True{} : Bool}, rec: REC(g), -ws: Array<U32>, +i: U32) -> {B.fill_go(Con{a, t}, ws, i) == B.fill_go(F.limbs(wlp(Con{a, t})), ws, i) : Array<U32>}:
  match t:
    case Nil{}:
      +h0 = hd
      +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Nil{}), h0)
      +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Nil{}), h0)
      %Equal.sym(+List<U32>, I.limb(B.word_of(a, 0, 0, 0)), [a, 0, 0, 0], E.lwb(a, 0, 0, 0, ea, {==}, {==}, {==})) :
        {B.fill_go(Con{a, Nil{}}, ws, i) == B.fill_go(List.append(&2, U32, _, []), ws, i) : Array<U32>}
      {==}
    case Con{+b, +r}: lp2(a, b, r, hd, g, hf, rec, ws, i)

# the loader writes the same words for a byte list as for the limbs of its packed words
# (by fuel f >= |bs|, so that the recursion is structural)
def lpf(+f: Nat, +bs: +List<U32>, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hf: {Nat.is_le(List.length(&2, U32, bs), f) == True{} : Bool}, -ws: Array<U32>, +i: U32)
    -> {B.fill_go(bs, ws, i) == B.fill_go(F.limbs(wlp(bs)), ws, i) : Array<U32>}:
  match f bs:
    case _ Nil{}: {==}
    case 0n Con{+a, +t}: Empty.absurd({B.fill_go(Con{a, t}, ws, i) == B.fill_go(F.limbs(wlp(Con{a, t})), ws, i) : Array<U32>}, FD.logic__false_true(hf))
    case 1n+ +g Con{+a, +t}: lp1(a, t, hd, g, hf, r => hr => hfr => w => j => lpf(g, r, hr, hfr, w, j), ws, i)

def lp(+bs: +List<U32>, +hd: {SP.bytes_domain(bs) == True{} : Bool}, -ws: Array<U32>, +i: U32)
    -> {B.fill_go(bs, ws, i) == B.fill_go(F.limbs(wlp(bs)), ws, i) : Array<U32>}:
  lpf(List.length(&2, U32, bs), bs, hd, FD.nat__le_refl(List.length(&2, U32, bs)), ws, i)


# ---- the loader's tree: words written from 0 into a zero tree are the segment tree ----

def nz(sl: List<&2, U32>, +a: Nat, +h: {Nat.is_le(FD.spec_common__length(U32, sl), a) == True{} : Bool}) -> {FD.flat__nthc(sl, a) == 0 : U32}:
  match sl a:
    case Nil{} _: {==}
    case Con{+x, +t} 0n: Empty.absurd({FD.flat__nthc(Con{x, t}, 0n) == 0 : U32}, FD.logic__false_true(h))
    case Con{+x, +t} 1n+ +p: nz(t, p, h)

def sz(+p: Nat, +b: Nat, +sl: List<&2, U32>, +h: {Nat.is_le(FD.spec_common__length(U32, sl), b) == True{} : Bool}) -> {AC.segt(p, b, sl) == FD.array__trep(U32, p, 0) : FD.array__Tree<U32>}:
  match p:
    case 0n: Equal.cong(U32, FD.array__Tree<U32>, x => FD.TLeaf{x}, FD.flat__nthc(sl, b), 0, nz(sl, b, h))
    case 1n+ +q:
      +h2 = FD.nat__le_trans(FD.spec_common__length(U32, sl), b, Nat.add(FD.spec_common__pow2(q), b), h, AC.le_addl(FD.spec_common__pow2(q), b))
      %Equal.sym(FD.array__Tree<U32>, AC.segt(q, b, sl), FD.array__trep(U32, q, 0), sz(q, b, sl, h)) : {FD.TNode{_, AC.segt(q, Nat.add(FD.spec_common__pow2(q), b), sl)} == FD.array__trep(U32, 1n+q, 0) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.segt(q, Nat.add(FD.spec_common__pow2(q), b), sl), FD.array__trep(U32, q, 0), sz(q, Nat.add(FD.spec_common__pow2(q), b), sl, h2)) : {FD.TNode{FD.array__trep(U32, q, 0), _} == FD.array__trep(U32, 1n+q, 0) : FD.array__Tree<U32>}
      {==}

def lecl(+c: Nat, +x: Nat, +y: Nat, +h: {Nat.is_le(Nat.add(c, x), Nat.add(c, y)) == True{} : Bool}) -> {Nat.is_le(x, y) == True{} : Bool}:
  match c:
    case 0n: h
    case 1n+ +d: lecl(d, x, y, h)

def pf0(+k: Nat, +a: Nat, +sl: List<&2, U32>, +hk: {Nat.is_le(k, 1n) == True{} : Bool}, +hl: {Nat.is_le(FD.spec_common__length(U32, sl), Nat.add(a, k)) == True{} : Bool}) -> {AC.cpt(0n, k, a, 0n, FD.array__trep(U32, 0n, 0), sl) == AC.segt(0n, a, sl) : FD.array__Tree<U32>}:
  match k:
    case 0n:
      +h = FD.logic__subst(Nat, z => {Nat.is_le(FD.spec_common__length(U32, sl), z) == True{} : Bool}, Nat.add(a, 0n), a, FD.nat__add_zero(a), hl)
      Equal.sym(FD.array__Tree<U32>, AC.segt(0n, a, sl), FD.TLeaf{0}, Equal.cong(U32, FD.array__Tree<U32>, x => FD.TLeaf{x}, FD.flat__nthc(sl, a), 0, nz(sl, a, h)))
    case 1n: {==}
    case 2n+ +j: Empty.absurd({AC.cpt(0n, 2n+j, a, 0n, FD.array__trep(U32, 0n, 0), sl) == AC.segt(0n, a, sl) : FD.array__Tree<U32>}, FD.logic__false_true(hk))

def pfc(+q: Nat, +k: Nat, +a: Nat, +sl: List<&2, U32>, +hk: {Nat.is_le(k, FD.spec_common__pow2(1n+q)) == True{} : Bool}, +hl: {Nat.is_le(FD.spec_common__length(U32, sl), Nat.add(a, k)) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(k, FD.spec_common__pow2(q)) == c : Bool}, ih: @+k1: Nat -> @+a1: Nat -> @+hk1: {Nat.is_le(k1, FD.spec_common__pow2(q)) == True{} : Bool} -> @+hl1: {Nat.is_le(FD.spec_common__length(U32, sl), Nat.add(a1, k1)) == True{} : Bool} -> {AC.cpt(q, k1, a1, 0n, FD.array__trep(U32, q, 0), sl) == AC.segt(q, a1, sl) : FD.array__Tree<U32>}) -> {AC.cpt(1n+q, k, a, 0n, FD.array__trep(U32, 1n+q, 0), sl) == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}:
  match c:
    case True{}:
      +h0 = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(q)) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)), ec)
      +hl2 = FD.nat__le_trans(FD.spec_common__length(U32, sl), Nat.add(a, k), Nat.add(FD.spec_common__pow2(q), a), hl,
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, k), z) == True{} : Bool}, Nat.add(a, FD.spec_common__pow2(q)), Nat.add(FD.spec_common__pow2(q), a), FD.nat__add_comm(a, FD.spec_common__pow2(q)), FD.nat__le_add_left(k, FD.spec_common__pow2(q), a, ec)))
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(1n+q, k, a, 0n, FD.TNode{FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0)}, sl), FD.TNode{AC.cpt(q, k, a, 0n, FD.array__trep(U32, q, 0), sl), FD.array__trep(U32, q, 0)}, AC.left(q, k, a, 0n, FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0), sl, h0)) :
        {_ == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(q, k, a, 0n, FD.array__trep(U32, q, 0), sl), AC.segt(q, a, sl), ih(k, a, ec, hl)) :
        {FD.TNode{_, FD.array__trep(U32, q, 0)} == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.segt(q, Nat.add(FD.spec_common__pow2(q), a), sl), FD.array__trep(U32, q, 0), sz(q, Nat.add(FD.spec_common__pow2(q), a), sl, hl2)) :
        {FD.TNode{AC.segt(q, a, sl), FD.array__trep(U32, q, 0)} == FD.TNode{AC.segt(q, a, sl), _} : FD.array__Tree<U32>}
      {==}
    case False{}:
      +le = FD.nat__lt_le(FD.spec_common__pow2(q), k, FD.nat__not_le_lt(k, FD.spec_common__pow2(q), ec))
      +ek = FD.nat__sub_add(k, FD.spec_common__pow2(q), le)
      +k2 = Nat.sub(k, FD.spec_common__pow2(q))
      +hk1 = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(1n+q)) == True{} : Bool}, k, Nat.add(FD.spec_common__pow2(q), k2), Equal.sym(Nat, Nat.add(FD.spec_common__pow2(q), k2), k, ek), hk)
      +hk2 = lecl(FD.spec_common__pow2(q), k2, FD.spec_common__pow2(q), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(FD.spec_common__pow2(q), k2), z) == True{} : Bool}, FD.spec_common__pow2(1n+q), Nat.add(FD.spec_common__pow2(q), FD.spec_common__pow2(q)), FD.flat__pow2_split(q), hk1))
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_le(FD.spec_common__length(U32, sl), Nat.add(a, z)) == True{} : Bool}, k, Nat.add(FD.spec_common__pow2(q), k2), Equal.sym(Nat, Nat.add(FD.spec_common__pow2(q), k2), k, ek), hl)
      +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(FD.spec_common__length(U32, sl), z) == True{} : Bool}, Nat.add(a, Nat.add(FD.spec_common__pow2(q), k2)), Nat.add(Nat.add(FD.spec_common__pow2(q), a), k2),
        Equal.trans(Nat, Nat.add(a, Nat.add(FD.spec_common__pow2(q), k2)), Nat.add(Nat.add(a, FD.spec_common__pow2(q)), k2), Nat.add(Nat.add(FD.spec_common__pow2(q), a), k2),
          Equal.sym(Nat, Nat.add(Nat.add(a, FD.spec_common__pow2(q)), k2), Nat.add(a, Nat.add(FD.spec_common__pow2(q), k2)), FD.nat__add_assoc(a, FD.spec_common__pow2(q), k2)),
          Equal.cong(Nat, Nat, z => Nat.add(z, k2), Nat.add(a, FD.spec_common__pow2(q)), Nat.add(FD.spec_common__pow2(q), a), FD.nat__add_comm(a, FD.spec_common__pow2(q)))), hl1)
      +hP0 = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(q)) == True{} : Bool}, FD.spec_common__pow2(q), Nat.add(FD.spec_common__pow2(q), 0n), Equal.sym(Nat, Nat.add(FD.spec_common__pow2(q), 0n), FD.spec_common__pow2(q), FD.nat__add_zero(FD.spec_common__pow2(q))), FD.nat__le_refl(FD.spec_common__pow2(q)))
      +hPP = FD.logic__subst(Nat, z => {Nat.is_le(FD.spec_common__pow2(q), z) == True{} : Bool}, FD.spec_common__pow2(q), Nat.add(FD.spec_common__pow2(q), 0n), Equal.sym(Nat, Nat.add(FD.spec_common__pow2(q), 0n), FD.spec_common__pow2(q), FD.nat__add_zero(FD.spec_common__pow2(q))), FD.nat__le_refl(FD.spec_common__pow2(q)))
      +e0 = Equal.trans(Nat, Nat.sub(Nat.add(FD.spec_common__pow2(q), 0n), FD.spec_common__pow2(q)), Nat.sub(FD.spec_common__pow2(q), FD.spec_common__pow2(q)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(z, FD.spec_common__pow2(q)), Nat.add(FD.spec_common__pow2(q), 0n), FD.spec_common__pow2(q), FD.nat__add_zero(FD.spec_common__pow2(q))), FD.nat__sub_self(FD.spec_common__pow2(q)))
      %ek : {AC.cpt(1n+q, _, a, 0n, FD.TNode{FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0)}, sl) == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(1n+q, Nat.add(FD.spec_common__pow2(q), k2), a, 0n, FD.TNode{FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0)}, sl), AC.cpt(1n+q, k2, Nat.add(FD.spec_common__pow2(q), a), Nat.add(FD.spec_common__pow2(q), 0n), AC.cpt(1n+q, FD.spec_common__pow2(q), a, 0n, FD.TNode{FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0)}, sl), sl), AC.split(1n+q, FD.spec_common__pow2(q), k2, a, 0n, FD.TNode{FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0)}, sl)) :
        {_ == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(1n+q, FD.spec_common__pow2(q), a, 0n, FD.TNode{FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0)}, sl), FD.TNode{AC.cpt(q, FD.spec_common__pow2(q), a, 0n, FD.array__trep(U32, q, 0), sl), FD.array__trep(U32, q, 0)}, AC.left(q, FD.spec_common__pow2(q), a, 0n, FD.array__trep(U32, q, 0), FD.array__trep(U32, q, 0), sl, hP0)) :
        {AC.cpt(1n+q, k2, Nat.add(FD.spec_common__pow2(q), a), Nat.add(FD.spec_common__pow2(q), 0n), _, sl) == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(q, FD.spec_common__pow2(q), a, 0n, FD.array__trep(U32, q, 0), sl), AC.segt(q, a, sl), AC.full(q, a, FD.array__trep(U32, q, 0), sl, FD.array__trep_perfect(U32, q, 0))) :
        {AC.cpt(1n+q, k2, Nat.add(FD.spec_common__pow2(q), a), Nat.add(FD.spec_common__pow2(q), 0n), FD.TNode{_, FD.array__trep(U32, q, 0)}, sl) == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(1n+q, k2, Nat.add(FD.spec_common__pow2(q), a), Nat.add(FD.spec_common__pow2(q), 0n), FD.TNode{AC.segt(q, a, sl), FD.array__trep(U32, q, 0)}, sl), FD.TNode{AC.segt(q, a, sl), AC.cpt(q, k2, Nat.add(FD.spec_common__pow2(q), a), Nat.sub(Nat.add(FD.spec_common__pow2(q), 0n), FD.spec_common__pow2(q)), FD.array__trep(U32, q, 0), sl)},
          AC.right(q, k2, Nat.add(FD.spec_common__pow2(q), a), Nat.add(FD.spec_common__pow2(q), 0n), AC.segt(q, a, sl), FD.array__trep(U32, q, 0), sl, hPP)) :
        {_ == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(Nat, Nat.sub(Nat.add(FD.spec_common__pow2(q), 0n), FD.spec_common__pow2(q)), 0n, e0) :
        {FD.TNode{AC.segt(q, a, sl), AC.cpt(q, k2, Nat.add(FD.spec_common__pow2(q), a), _, FD.array__trep(U32, q, 0), sl)} == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      %Equal.sym(FD.array__Tree<U32>, AC.cpt(q, k2, Nat.add(FD.spec_common__pow2(q), a), 0n, FD.array__trep(U32, q, 0), sl), AC.segt(q, Nat.add(FD.spec_common__pow2(q), a), sl), ih(k2, Nat.add(FD.spec_common__pow2(q), a), hk2, hl2)) :
        {FD.TNode{AC.segt(q, a, sl), _} == AC.segt(1n+q, a, sl) : FD.array__Tree<U32>}
      {==}

# k words of sl from a, written into a zero tree of depth p (k <= 2^p, sl ends at a + k): the segment tree.
def pf(+p: Nat, +k: Nat, +a: Nat, +sl: List<&2, U32>, +hk: {Nat.is_le(k, FD.spec_common__pow2(p)) == True{} : Bool}, +hl: {Nat.is_le(FD.spec_common__length(U32, sl), Nat.add(a, k)) == True{} : Bool}) -> {AC.cpt(p, k, a, 0n, FD.array__trep(U32, p, 0), sl) == AC.segt(p, a, sl) : FD.array__Tree<U32>}:
  match p:
    case 0n: pf0(k, a, sl, hk, hl)
    case 1n+ +q: pfc(q, k, a, sl, hk, hl, Nat.is_le(k, FD.spec_common__pow2(q)), {==}, k1 => a1 => hk1 => hl1 => pf(q, k1, a1, sl, hk1, hl1))


# ---- the byte view of the loader's tree ----

def n0(+k: Nat, +a: Nat, +w: U32, +t: List<&2, U32>) -> {AN.ns(k, 1n+a, Con{w, t}) == AN.ns(k, a, t) : List<&2, U32>}:
  match k:
    case 0n: {==}
    case 1n+ +m: Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{FD.flat__nthc(t, a), z}, AN.ns(m, 2n+a, Con{w, t}), AN.ns(m, 1n+a, t), n0(m, 1n+a, w, t))

def n1(+W: List<&2, U32>, +m: Nat) -> {AN.ns(Nat.add(FD.spec_common__length(U32, W), m), 0n, W) == List.append(&2, U32, W, AN.ns(m, FD.spec_common__length(U32, W), W)) : List<&2, U32>}:
  match W:
    case Nil{}: {==}
    case Con{+w, +t}:
      %Equal.sym(List<&2, U32>, AN.ns(Nat.add(FD.spec_common__length(U32, t), m), 1n, Con{w, t}), AN.ns(Nat.add(FD.spec_common__length(U32, t), m), 0n, t), n0(Nat.add(FD.spec_common__length(U32, t), m), 0n, w, t)) :
        {Con{w, _} == List.append(&2, U32, Con{w, t}, AN.ns(m, 1n+FD.spec_common__length(U32, t), Con{w, t})) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, AN.ns(m, 1n+FD.spec_common__length(U32, t), Con{w, t}), AN.ns(m, FD.spec_common__length(U32, t), t), n0(m, FD.spec_common__length(U32, t), w, t)) :
        {Con{w, AN.ns(Nat.add(FD.spec_common__length(U32, t), m), 0n, t)} == Con{w, List.append(&2, U32, t, _)} : List<&2, U32>}
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{w, z}, AN.ns(Nat.add(FD.spec_common__length(U32, t), m), 0n, t), List.append(&2, U32, t, AN.ns(m, FD.spec_common__length(U32, t), t)), n1(t, m))

def n3(+xs: +List<U32>, +R: +List<U32>) -> {VSP.bt(List.length(&2, U32, xs), List.append(&2, U32, xs, R)) == xs : +List<U32>}:
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VSP.bt(List.length(&2, U32, t), List.append(&2, U32, t, R)), t, n3(t, R))

# the zero bytes the loader pads the last word with
def padz(+bs: +List<U32>) -> +List<U32>:
  match bs:
    case Con{a, Con{b, Con{c, Con{d, r}}}}: padz(r)
    case Con{a, Con{b, Con{c, Nil{}}}}: [0]
    case Con{a, Con{b, Nil{}}}: [0, 0]
    case Con{a, Nil{}}: [0, 0, 0]
    case Nil{}: []

def RECW(+g: Nat) -> Type:
  @+r: +List<U32> -> @+hr: {SP.bytes_domain(r) == True{} : Bool} -> @+hf: {Nat.is_le(List.length(&2, U32, r), g) == True{} : Bool} -> {F.limbs(wlp(r)) == List.append(&2, U32, r, padz(r)) : +List<U32>}

def lw4(+a: U32, +b: U32, +c: U32, +d: U32, +r: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, Con{c, Con{d, r}}}}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}), 1n+g) == True{} : Bool}, rec: RECW(g)) -> {F.limbs(wlp(Con{a, Con{b, Con{c, Con{d, r}}}})) == List.append(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}, padz(Con{a, Con{b, Con{c, Con{d, r}}}})) : +List<U32>}:
  +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Con{d, r}}}), hd)
  +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Con{d, r}}}), hd)
  +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Con{d, r}}), h1)
  +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Con{d, r}}), h1)
  +ec = V.and_left(U32.is_lt(c, 256), SP.bytes_domain(Con{d, r}), h2)
  +h3 = V.and_right(U32.is_lt(c, 256), SP.bytes_domain(Con{d, r}), h2)
  +ed = V.and_left(U32.is_lt(d, 256), SP.bytes_domain(r), h3)
  +hr = V.and_right(U32.is_lt(d, 256), SP.bytes_domain(r), h3)
  %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, c, d)), [a, b, c, d], E.lwb(a, b, c, d, ea, eb, ec, ed)) :
    {List.append(&2, U32, _, F.limbs(wlp(r))) == List.append(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}, padz(r)) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, [a, b, c, d], z), F.limbs(wlp(r)), List.append(&2, U32, r, padz(r)),
    rec(r, hr, FD.nat__le_trans(List.length(&2, U32, r), 3n+List.length(&2, U32, r), g, le3(List.length(&2, U32, r)), hf)))

def lw3(+a: U32, +b: U32, +c: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, Con{c, t}}}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, t}}}), 1n+g) == True{} : Bool}, rec: RECW(g)) -> {F.limbs(wlp(Con{a, Con{b, Con{c, t}}})) == List.append(&2, U32, Con{a, Con{b, Con{c, t}}}, padz(Con{a, Con{b, Con{c, t}}})) : +List<U32>}:
  match t:
    case Nil{}:
      +h0 = hd
      +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Nil{}}}), h0)
      +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Con{c, Nil{}}}), h0)
      +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Nil{}}), h1)
      +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Con{c, Nil{}}), h1)
      +ec = V.and_left(U32.is_lt(c, 256), SP.bytes_domain(Nil{}), h2)
      +h3 = V.and_right(U32.is_lt(c, 256), SP.bytes_domain(Nil{}), h2)
      %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, c, 0)), [a, b, c, 0], E.lwb(a, b, c, 0, ea, eb, ec, {==})) :
        {List.append(&2, U32, _, []) == List.append(&2, U32, Con{a, Con{b, Con{c, Nil{}}}}, padz(Con{a, Con{b, Con{c, Nil{}}}})) : +List<U32>}
      {==}
    case Con{+d, +r}: lw4(a, b, c, d, r, hd, g, hf, rec)

def lw2(+a: U32, +b: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, Con{b, t}}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, t}}), 1n+g) == True{} : Bool}, rec: RECW(g)) -> {F.limbs(wlp(Con{a, Con{b, t}})) == List.append(&2, U32, Con{a, Con{b, t}}, padz(Con{a, Con{b, t}})) : +List<U32>}:
  match t:
    case Nil{}:
      +h0 = hd
      +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Nil{}}), h0)
      +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Con{b, Nil{}}), h0)
      +eb = V.and_left(U32.is_lt(b, 256), SP.bytes_domain(Nil{}), h1)
      +h2 = V.and_right(U32.is_lt(b, 256), SP.bytes_domain(Nil{}), h1)
      %Equal.sym(+List<U32>, I.limb(B.word_of(a, b, 0, 0)), [a, b, 0, 0], E.lwb(a, b, 0, 0, ea, eb, {==}, {==})) :
        {List.append(&2, U32, _, []) == List.append(&2, U32, Con{a, Con{b, Nil{}}}, padz(Con{a, Con{b, Nil{}}})) : +List<U32>}
      {==}
    case Con{+c, +r}: lw3(a, b, c, r, hd, g, hf, rec)

def lw1(+a: U32, +t: +List<U32>, +hd: {SP.bytes_domain(Con{a, t}) == True{} : Bool}, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, t}), 1n+g) == True{} : Bool}, rec: RECW(g)) -> {F.limbs(wlp(Con{a, t})) == List.append(&2, U32, Con{a, t}, padz(Con{a, t})) : +List<U32>}:
  match t:
    case Nil{}:
      +h0 = hd
      +ea = V.and_left(U32.is_lt(a, 256), SP.bytes_domain(Nil{}), h0)
      +h1 = V.and_right(U32.is_lt(a, 256), SP.bytes_domain(Nil{}), h0)
      %Equal.sym(+List<U32>, I.limb(B.word_of(a, 0, 0, 0)), [a, 0, 0, 0], E.lwb(a, 0, 0, 0, ea, {==}, {==}, {==})) :
        {List.append(&2, U32, _, []) == List.append(&2, U32, Con{a, Nil{}}, padz(Con{a, Nil{}})) : +List<U32>}
      {==}
    case Con{+b, +r}: lw2(a, b, r, hd, g, hf, rec)

def lwf(+f: Nat, +bs: +List<U32>, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hf: {Nat.is_le(List.length(&2, U32, bs), f) == True{} : Bool}) -> {F.limbs(wlp(bs)) == List.append(&2, U32, bs, padz(bs)) : +List<U32>}:
  match f bs:
    case _ Nil{}: {==}
    case 0n Con{+a, +t}: Empty.absurd({F.limbs(wlp(Con{a, t})) == List.append(&2, U32, Con{a, t}, padz(Con{a, t})) : +List<U32>}, FD.logic__false_true(hf))
    case 1n+ +g Con{+a, +t}: lw1(a, t, hd, g, hf, r => hr => hfr => lwf(g, r, hr, hfr))

# the limbs of the packed words are the bytes and the last word's zero padding
def lw(+bs: +List<U32>, +hd: {SP.bytes_domain(bs) == True{} : Bool}) -> {F.limbs(wlp(bs)) == List.append(&2, U32, bs, padz(bs)) : +List<U32>}:
  lwf(List.length(&2, U32, bs), bs, hd, FD.nat__le_refl(List.length(&2, U32, bs)))

def app3(+xs: +List<U32>, +ys: +List<U32>, +zs: +List<U32>) -> {List.append(&2, U32, List.append(&2, U32, xs, ys), zs) == List.append(&2, U32, xs, List.append(&2, U32, ys, zs)) : +List<U32>}:
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, List.append(&2, U32, List.append(&2, U32, t, ys), zs), List.append(&2, U32, t, List.append(&2, U32, ys, zs)), app3(t, ys, zs))

# the first n bytes of the loader's tree are the byte list (n its length)
def vw(+bs: +List<U32>, +n: U32, +d: Nat, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat},
    +hW: {Nat.is_le(FD.spec_common__length(U32, wlp(bs)), FD.spec_common__pow2(d)) == True{} : Bool}) -> {VSP.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, AC.segt(d, 0n, wlp(bs))))) == bs : +List<U32>}:
  %hn : {VSP.bt(_, F.limbs(FD.array__slots(U32, AC.segt(d, 0n, wlp(bs))))) == bs : +List<U32>}
  %Equal.sym(List<&2, U32>, FD.array__slots(U32, AC.segt(d, 0n, wlp(bs))), AN.ns(FD.spec_common__pow2(d), 0n, wlp(bs)), AN.slots_segt(d, 0n, wlp(bs))) :
    {VSP.bt(List.length(&2, U32, bs), F.limbs(_)) == bs : +List<U32>}
  %FD.nat__sub_add(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs)), hW) : {VSP.bt(List.length(&2, U32, bs), F.limbs(AN.ns(_, 0n, wlp(bs)))) == bs : +List<U32>}
  %Equal.sym(List<&2, U32>, AN.ns(Nat.add(FD.spec_common__length(U32, wlp(bs)), Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs)))), 0n, wlp(bs)), List.append(&2, U32, wlp(bs), AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs))), n1(wlp(bs), Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))))) :
    {VSP.bt(List.length(&2, U32, bs), F.limbs(_)) == bs : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(List.append(&2, U32, wlp(bs), AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs)))), List.append(&2, U32, F.limbs(wlp(bs)), F.limbs(AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs)))), F.limbs_append(wlp(bs), AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs)))) :
    {VSP.bt(List.length(&2, U32, bs), _) == bs : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(wlp(bs)), List.append(&2, U32, bs, padz(bs)), lw(bs, hd)) :
    {VSP.bt(List.length(&2, U32, bs), List.append(&2, U32, _, F.limbs(AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs))))) == bs : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, bs, padz(bs)), F.limbs(AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs)))), List.append(&2, U32, bs, List.append(&2, U32, padz(bs), F.limbs(AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs))))), app3(bs, padz(bs), F.limbs(AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs))))) :
    {VSP.bt(List.length(&2, U32, bs), _) == bs : +List<U32>}
  n3(bs, List.append(&2, U32, padz(bs), F.limbs(AN.ns(Nat.sub(FD.spec_common__pow2(d), FD.spec_common__length(U32, wlp(bs))), FD.spec_common__length(U32, wlp(bs)), wlp(bs)))))

# the loader's buffer for a byte list is the buffer of the segment tree of its packed words
def bf(+bs: +List<U32>, +n: U32, +d: Nat, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hc: {B.capacity(n) == d : Nat},
    +hd32: {Nat.is_lt(d, 32n) == True{} : Bool}, +hW: {Nat.is_le(FD.spec_common__length(U32, wlp(bs)), FD.spec_common__pow2(d)) == True{} : Bool}) -> {B.fill_at(B.alloc(n), 0, bs) == B.Buf{FD.array__thaw(U32, AC.segt(d, 0n, wlp(bs))), n} : B.Buf}:
  +h0 = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(d)) == True{} : Bool}, FD.spec_common__length(U32, wlp(bs)), Nat.add(FD.spec_common__length(U32, wlp(bs)), 0n), Equal.sym(Nat, Nat.add(FD.spec_common__length(U32, wlp(bs)), 0n), FD.spec_common__length(U32, wlp(bs)), FD.nat__add_zero(FD.spec_common__length(U32, wlp(bs)))), hW)
  %Equal.sym(Nat, B.capacity(n), d, hc) : {B.Buf{B.fill_go(bs, Array.new(U32, _, 0), U32.shrn(0, 2n)), n} == B.Buf{FD.array__thaw(U32, AC.segt(d, 0n, wlp(bs))), n} : B.Buf}
  %Equal.sym(Array<U32>, Array.new(U32, d, 0), FD.array__thaw(U32, FD.array__trep(U32, d, 0)), FD.array__new(U32, d, 0)) : {B.Buf{B.fill_go(bs, _, 0), n} == B.Buf{FD.array__thaw(U32, AC.segt(d, 0n, wlp(bs))), n} : B.Buf}
  %Equal.sym(Array<U32>, B.fill_go(bs, FD.array__thaw(U32, FD.array__trep(U32, d, 0)), 0), B.fill_go(F.limbs(wlp(bs)), FD.array__thaw(U32, FD.array__trep(U32, d, 0)), 0), lp(bs, hd, FD.array__thaw(U32, FD.array__trep(U32, d, 0)), 0)) :
    {B.Buf{_, n} == B.Buf{FD.array__thaw(U32, AC.segt(d, 0n, wlp(bs))), n} : B.Buf}
  %Equal.sym(Array<U32>, B.fill_go(F.limbs(wlp(bs)), FD.array__thaw(U32, FD.array__trep(U32, d, 0)), 0), FD.array__thaw(U32, AC.cpt(d, FD.spec_common__length(U32, wlp(bs)), 0n, 0n, FD.array__trep(U32, d, 0), wlp(bs))),
      AE.fill(wlp(bs), d, FD.array__trep(U32, d, 0), 0, 0n, {==}, hd32, h0, FD.array__trep_perfect(U32, d, 0))) :
    {B.Buf{_, n} == B.Buf{FD.array__thaw(U32, AC.segt(d, 0n, wlp(bs))), n} : B.Buf}
  %Equal.sym(FD.array__Tree<U32>, AC.cpt(d, FD.spec_common__length(U32, wlp(bs)), 0n, 0n, FD.array__trep(U32, d, 0), wlp(bs)), AC.segt(d, 0n, wlp(bs)), pf(d, FD.spec_common__length(U32, wlp(bs)), 0n, wlp(bs), hW, FD.nat__le_refl(FD.spec_common__length(U32, wlp(bs))))) :
    {B.Buf{FD.array__thaw(U32, _), n} == B.Buf{FD.array__thaw(U32, AC.segt(d, 0n, wlp(bs))), n} : B.Buf}
  {==}

def seg_pf(+d: Nat, +sl: List<&2, U32>) -> {FD.array__perfect(U32, d, AC.segt(d, 0n, sl)) == True{} : Bool}:
  FD.logic__subst(FD.array__Tree<U32>, z => {FD.array__perfect(U32, d, z) == True{} : Bool}, AC.cpt(d, FD.spec_common__pow2(d), 0n, 0n, FD.array__trep(U32, d, 0), sl), AC.segt(d, 0n, sl),
    AC.full(d, 0n, FD.array__trep(U32, d, 0), sl, FD.array__trep_perfect(U32, d, 0)),
    AC.cpt_perfect(d, FD.spec_common__pow2(d), 0n, 0n, FD.array__trep(U32, d, 0), sl, FD.array__trep_perfect(U32, d, 0)))
'''


def blocks_of(f, cache):
    if f not in cache:
        # the runtime's symbols read as T.<sym> (a proving module imports the split files: RR.unwire)
        cache[f] = AG.blocks(RR.unwire((OBJ / f).read_text()))
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
        elif base.endswith('_generated.bend') and '/types/' in '/' + path:
            out['T'] = 'T'   # a runtime split file: its symbols read as T.<sym> (blocks_of)
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
            'ee': ee[0], 'es': es[0], 'rt': rt[0], 'generic': RR.runtime_of((OBJ / ee[0]['file']).read_text()) == 'generic'}


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
        src = RR.unwire(f.read_text())   # the runtime's symbols as T.<sym> (the module imports the split files)
        m = re.search(r'^def ' + X + r'_encode_any\((.*)\)\n    -> \{SF\.emitted\(O\.Words, T\.' + X + r'_encode\((.*?)\), (\d+)\) == ', src, re.M)
        if not m:
            continue
        md = re.search(r'^def ' + X + r'_decodes_any\((.*)\)\n    -> Decoding\.decodes\((\w+|Spec\.\w+\(\)), (.*)\):$', src, re.M)
        if not md:
            return None
        rt = RR.mono_text(RR.runtime_of(f.read_text()))
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


CAP = r'''import Base
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vbuf.bend as VB
import ./e2e_load.bend as L

# The capacity facts for the loader: a buffer of n bytes, n <= 4 * 2^k for some k < 29,
# is allocated at a depth d = B.capacity(n) with d < 29 (cap_lt), 2^d holds the words the
# loader packs its bytes into (cap_w) and 4 * 2^d holds its bytes (cap_q). The words of
# n bytes are nwn(n) = (n + 3) / 4, as VD's halvings. So the largest input covered is
# n <= 4 * 2^28 = 2^30 bytes (1 GiB), the bound of the variable-size decode bridges (k = 28 is
# the most here: the runtime's n + 3 must not wrap, n + 3 <= 2^(k + 3) < 2^32).

def nwn(+x: Nat) -> Nat: VD.s_rng(2n, 3n+x)

law h2m:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VD.s_h2(a), VD.s_h2(b)) == True{} : Bool}
def h2m(a, b, e):
  match a b:
    case 0n _: Order.zero_le(VD.s_h2(b))
    case 1n 0n: Empty.absurd({Nat.is_le(0n, 0n) == True{} : Bool}, FD.logic__false_true(e))
    case 1n 1n+ +q: Order.zero_le(VD.s_h2(1n+q))
    case 2n+p 0n: Empty.absurd({Nat.is_le(VD.s_h2(2n+p), 0n) == True{} : Bool}, FD.logic__false_true(e))
    case 2n+p 1n: Empty.absurd({Nat.is_le(VD.s_h2(2n+p), 0n) == True{} : Bool}, FD.logic__false_true(e))
    case 2n+ +p 2n+ +q: h2m(p, q, e)

law rgm:
  for +l: Nat
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VD.s_rng(l, a), VD.s_rng(l, b)) == True{} : Bool}
def rgm(l, a, b, e):
  match l:
    case 0n: e
    case 1n+ +k: h2m(VD.s_rng(k, a), VD.s_rng(k, b), rgm(k, a, b, e))

law rq:
  for +m: Nat
  {nwn(A.quad(m)) == m : Nat}
def rq(m):
  match m:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, nwn(A.quad(p)), p, rq(p)) : {1n+_ == 1n+p : Nat}
      {==}

# y <= 4 * nwn(y)
law ng:
  for +y: Nat
  {Nat.is_le(y, A.quad(nwn(y))) == True{} : Bool}
def ng(y):
  match y:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +z: ng(z)

# y <= 4 * P: nwn(y) <= P
def nle(+y: Nat, +P: Nat, +h: {Nat.is_le(y, A.quad(P)) == True{} : Bool}) -> {Nat.is_le(nwn(y), P) == True{} : Bool}:
  %rq(P) : {Nat.is_le(nwn(y), _) == True{} : Bool}
  rgm(2n, 3n+y, 3n+A.quad(P), h)

def q4(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(A.quad(a), A.quad(b)) == True{} : Bool}:
  FD.nat__double_le(Nat.double(a), Nat.double(b), FD.nat__double_le(a, b, h))

# the runtime's word count (n + 3) >> 2 is nwn(n), for n <= 4 * 2^k, k < 29
def nwu(+n: U32) -> U32: U32.shrn((n + 3 : U32), 2n)
def nw(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {U32.to_nat(nwu(n)) == nwn(U32.to_nat(n)) : Nat}:
  +Q = A.quad(FD.spec_common__pow2(k))
  +h3 = FD.nat__le_trans(3n, 4n, Q, {==}, q4(1n, FD.spec_common__pow2(k), FD.nat__pow2_pos(k)))
  +hab = FD.nat__le_trans(Nat.add(U32.to_nat(n), 3n), Nat.add(Q, 3n), Nat.add(Q, Q), Order.add_right(U32.to_nat(n), Q, 3n, h), Order.add_left(Q, 3n, Q, h3))
  +hc = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(n), 3n), z) == True{} : Bool}, Nat.add(Q, Q), Nat.double(Q), Equal.sym(Nat, Nat.double(Q), Nat.add(Q, Q), FD.lru_nat_algebra__double_self(Q)), hab)
  +hd = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(n), 3n), z) == True{} : Bool}, FD.spec_common__pow2(Nat.add(3n, k)), O.pow2n(Nat.add(3n, k)), VD.s_pow2_eq(Nat.add(3n, k)), hc)
  +e1 = VD.shrk(2n, (n + 3 : U32))
  +e2 = VD.s_add_nat(n, 3, Nat.add(3n, k), hk, hd)
  Equal.trans(Nat, U32.to_nat(nwu(n)), VD.s_rng(2n, U32.to_nat((n + 3 : U32))), nwn(U32.to_nat(n)), e1,
    Equal.trans(Nat, VD.s_rng(2n, U32.to_nat((n + 3 : U32))), VD.s_rng(2n, Nat.add(U32.to_nat(n), 3n)), nwn(U32.to_nat(n)),
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat((n + 3 : U32)), Nat.add(U32.to_nat(n), 3n), e2),
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), Nat.add(U32.to_nat(n), 3n), 3n+U32.to_nat(n), FD.nat__add_comm(U32.to_nat(n), 3n))))

# the words fit 2^k
def nwk(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(nwu(n)), O.pow2n(k)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(nwu(n)), nwn(U32.to_nat(n)), nw(n, k, hk, h)) : {Nat.is_le(_, O.pow2n(k)) == True{} : Bool}
  %VD.s_pow2_eq(k) : {Nat.is_le(nwn(U32.to_nat(n)), _) == True{} : Bool}
  nle(U32.to_nat(n), FD.spec_common__pow2(k), h)

# d = B.capacity(n) <= k
def cap_le(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(B.capacity(n), k) == True{} : Bool}:
  VD.wd_min(nwu(n), k, nwk(n, k, hk, h))

# d = B.capacity(n) < 29
def cap_lt(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_lt(B.capacity(n), 29n) == True{} : Bool}:
  FD.nat__le_lt_trans(B.words_depth(nwu(n)), k, 29n, VD.wd_min(nwu(n), k, nwk(n, k, hk, h)), hk)

def cap_32(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_lt(B.capacity(n), 32n) == True{} : Bool}:
  FD.nat__lt_le_trans(B.capacity(n), 29n, 32n, cap_lt(n, k, hk, h), {==})

# nwn(n) <= 2^d
def cap_n(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(nwn(U32.to_nat(n)), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}:
  +hk32 = FD.nat__le_trans(k, 29n, 32n, FD.nat__lt_le(k, 29n, hk), {==})
  %nw(n, k, hk, h) : {Nat.is_le(_, FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  %Equal.sym(Nat, FD.spec_common__pow2(B.capacity(n)), O.pow2n(B.capacity(n)), VD.s_pow2_eq(B.capacity(n))) : {Nat.is_le(U32.to_nat(nwu(n)), _) == True{} : Bool}
  VD.wd_cover(nwu(n), k, hk32, nwk(n, k, hk, h))

# 4 * 2^d holds the n bytes
def cap_q(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(B.capacity(n)))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(n), A.quad(nwn(U32.to_nat(n))), A.quad(FD.spec_common__pow2(B.capacity(n))), ng(U32.to_nat(n)),
    q4(nwn(U32.to_nat(n)), FD.spec_common__pow2(B.capacity(n)), cap_n(n, k, hk, h)))

# the loader packs a byte list into nwn(its length) words
def RL(+g: Nat) -> Type:
  @+r: +List<U32> -> @+hf: {Nat.is_le(List.length(&2, U32, r), g) == True{} : Bool} -> {FD.spec_common__length(U32, L.wlp(r)) == nwn(List.length(&2, U32, r)) : Nat}

def ln4(+a: U32, +b: U32, +c: U32, +d: U32, +r: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, Con{b, Con{c, Con{d, r}}}})) == nwn(List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}})) : Nat}:
  Equal.cong(Nat, Nat, z => 1n+z, FD.spec_common__length(U32, L.wlp(r)), nwn(List.length(&2, U32, r)),
    rec(r, FD.nat__le_trans(List.length(&2, U32, r), 3n+List.length(&2, U32, r), g, L.le3(List.length(&2, U32, r)), hf)))

def ln3(+a: U32, +b: U32, +c: U32, +t: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, t}}}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, Con{b, Con{c, t}}})) == nwn(List.length(&2, U32, Con{a, Con{b, Con{c, t}}})) : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+d, +r}: ln4(a, b, c, d, r, g, hf, rec)

def ln2(+a: U32, +b: U32, +t: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, t}}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, Con{b, t}})) == nwn(List.length(&2, U32, Con{a, Con{b, t}})) : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+c, +r}: ln3(a, b, c, r, g, hf, rec)

def ln1(+a: U32, +t: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, t}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, t})) == nwn(List.length(&2, U32, Con{a, t})) : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+b, +r}: ln2(a, b, r, g, hf, rec)

def lnf(+f: Nat, +bs: +List<U32>, +hf: {Nat.is_le(List.length(&2, U32, bs), f) == True{} : Bool}) -> {FD.spec_common__length(U32, L.wlp(bs)) == nwn(List.length(&2, U32, bs)) : Nat}:
  match f bs:
    case _ Nil{}: {==}
    case 0n Con{+a, +t}: Empty.absurd({FD.spec_common__length(U32, L.wlp(Con{a, t})) == nwn(List.length(&2, U32, Con{a, t})) : Nat}, FD.logic__false_true(hf))
    case 1n+ +g Con{+a, +t}: ln1(a, t, g, hf, r => hfr => lnf(g, r, hfr))

def ln(+bs: +List<U32>) -> {FD.spec_common__length(U32, L.wlp(bs)) == nwn(List.length(&2, U32, bs)) : Nat}:
  lnf(List.length(&2, U32, bs), bs, FD.nat__le_refl(List.length(&2, U32, bs)))

# 2^d holds the loader's words of n bytes
def cap_w(+bs: +List<U32>, +n: U32, +k: Nat, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hk: {Nat.is_lt(k, 29n) == True{} : Bool},
    +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(FD.spec_common__length(U32, L.wlp(bs)), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, L.wlp(bs)), nwn(List.length(&2, U32, bs)), ln(bs)) : {Nat.is_le(_, FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, bs), U32.to_nat(n), hn) : {Nat.is_le(nwn(_), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  cap_n(n, k, hk, h)


# ---- the object API's own input limit: n <= VB.NMAX() (2^32 - 32), depth at most 30 ----
# The same facts for every input the object API accepts: n + 3 does not wrap (VB.nmax_lt), the
# words of n bytes are at most 2^30 (n < 2^32), so d = B.capacity(n) <= 30.

def nwM(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {U32.to_nat(nwu(n)) == nwn(U32.to_nat(n)) : Nat}:
  +h3 = FD.nat__le_lt_trans(Nat.add(3n, U32.to_nat(n)), Nat.add(31n, U32.to_nat(n)), FD.spec_common__pow2(32n), Order.add_right(3n, 31n, U32.to_nat(n), {==}), VB.nmax_lt(n, hN))
  Equal.trans(Nat, U32.to_nat(nwu(n)), VD.s_rng(2n, U32.to_nat((n + 3 : U32))), nwn(U32.to_nat(n)), VD.shrk(2n, (n + 3 : U32)),
    Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat((n + 3 : U32)), Nat.add(3n, U32.to_nat(n)), VB.add_lt32(n, 3, U32.to_nat(n), {==}, h3)))

def nwkM(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(nwu(n)), O.pow2n(30n)) == True{} : Bool}:
  +hq = FD.nat__lt_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(30n)), VB.u32_lt(n))
  %Equal.sym(Nat, U32.to_nat(nwu(n)), nwn(U32.to_nat(n)), nwM(n, hN)) : {Nat.is_le(_, O.pow2n(30n)) == True{} : Bool}
  %VD.s_pow2_eq(30n) : {Nat.is_le(nwn(U32.to_nat(n)), _) == True{} : Bool}
  nle(U32.to_nat(n), FD.spec_common__pow2(30n), hq)

# d = B.capacity(n) <= 30
def capM_le(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_le(B.capacity(n), 30n) == True{} : Bool}:
  VD.wd_min(nwu(n), 30n, nwkM(n, hN))

def capM_lt(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_lt(B.capacity(n), 31n) == True{} : Bool}:
  FD.nat__le_lt_trans(B.capacity(n), 30n, 31n, capM_le(n, hN), {==})

def capM_32(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_lt(B.capacity(n), 32n) == True{} : Bool}:
  FD.nat__le_lt_trans(B.capacity(n), 30n, 32n, capM_le(n, hN), {==})

def capM_n(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_le(nwn(U32.to_nat(n)), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}:
  %nwM(n, hN) : {Nat.is_le(_, FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  %Equal.sym(Nat, FD.spec_common__pow2(B.capacity(n)), O.pow2n(B.capacity(n)), VD.s_pow2_eq(B.capacity(n))) : {Nat.is_le(U32.to_nat(nwu(n)), _) == True{} : Bool}
  VD.wd_cover(nwu(n), 30n, {==}, nwkM(n, hN))

def capM_q(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(B.capacity(n)))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(n), A.quad(nwn(U32.to_nat(n))), A.quad(FD.spec_common__pow2(B.capacity(n))), ng(U32.to_nat(n)),
    q4(nwn(U32.to_nat(n)), FD.spec_common__pow2(B.capacity(n)), capM_n(n, hN)))

def capM_w(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool})
    -> {Nat.is_le(FD.spec_common__length(U32, L.wlp(bs)), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, L.wlp(bs)), nwn(List.length(&2, U32, bs)), ln(bs)) : {Nat.is_le(_, FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, bs), U32.to_nat(n), hn) : {Nat.is_le(nwn(_), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  capM_n(n, hN)
'''

ULIST = r'''import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/primitive.bend as P
import ../proofs/compact/found.bend as FD
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/ulist_obj.bend as UL
import ../proofs/obj/words_spec.bend as WS
import ../proofs/obj/dk.bend as DK
import ../spec/primitives.bend as SP

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# The root view of a u64 list object (ulist_obj.uview) as the codec laws' value (vspec.uitems): c items
# of its tree's words when its byte length N has N >> 3 = c. Shared by the variable-size bridges.

def ue2(+c: Nat, +a: U32, +t: List<&2, U32>, rec: @+r: List<&2, U32> -> {UL.uitems(c, r) == VSP.uitems(c, r) : S.Value})
    -> {UL.uitems(1n+c, Con{a, t}) == VSP.uitems(1n+c, Con{a, t}) : S.Value}:
  match t:
    case Nil{}: {==}
    case Con{+b, +rest}: Equal.cong(S.Value, S.Value, z => S.Items{S.UnsignedValue{P.UInt{a, b, 0, 0, 0, 0, 0, 0}}, z}, UL.uitems(c, rest), VSP.uitems(c, rest), rec(rest))

law ue:
  for +k: Nat
  for +W: List<&2, U32>
  {UL.uitems(k, W) == VSP.uitems(k, W) : S.Value}
def ue(k, W):
  match k W:
    case 0n _: {==}
    case 1n+ +c Nil{}: {==}
    case 1n+ +c Con{+a, +t}: ue2(c, a, t, r => ue(c, r))

law r8:
  for +c: Nat
  {VD.s_rng(3n, VSP.x8(c)) == c : Nat}
def r8(c):
  match c:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_rng(3n, VSP.x8(p)), p, r8(p)) : {1n+_ == 1n+p : Nat}
      {==}

law x8e:
  for +c: Nat
  {VSP.x8(c) == O.e8(c) : Nat}
def x8e(c):
  match c:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 8n+z, VSP.x8(p), O.e8(p), x8e(p))

def uvw(+t: FD.array__Tree<U32>, +N: U32, +c: Nat, +ecq: {U32.to_nat(U32.shrn(N, 3n)) == c : Nat})
    -> {UL.uview(O.Words{FD.array__thaw(U32, t), N}) == S.Sequence{VSP.uitems(c, FD.array__slots(U32, t))} : S.Value}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(N, 3n)), c, ecq) :
    {S.Sequence{UL.uitems(_, FD.array__slots(U32, FD.array__freeze(U32, FD.array__thaw(U32, t))))} == S.Sequence{VSP.uitems(c, FD.array__slots(U32, t))} : S.Value}
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, t)), t, FD.array__freeze_thaw(U32, t)) :
    {S.Sequence{UL.uitems(c, FD.array__slots(U32, _))} == S.Sequence{VSP.uitems(c, FD.array__slots(U32, t))} : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, UL.uitems(c, FD.array__slots(U32, t)), VSP.uitems(c, FD.array__slots(U32, t)), ue(c, FD.array__slots(U32, t)))

# ---- the premise: the list field's storage as the root law's invariant (list_obj.wfl), at depth below 31 ----
# (the encode laws take storage depth dw < 31; the root law's invariant gives dw < 32)

def sd0(w: O.Words) -> Data:
  DK.Ex(FD.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({w == O.Words{FD.array__thaw(U32, t), N} : O.Words},
    DK.P2({FD.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 31n) == True{} : Bool},
          {U32.to_nat(N) == 0n : Nat}))))))

def sd1(w: O.Words) -> Data:
  DK.Ex(FD.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N => DK.Ex(Nat, q => DK.Ex(Nat, r =>
    DK.P2({w == O.Words{FD.array__thaw(U32, t), N} : O.Words},
    DK.P2({FD.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 31n) == True{} : Bool},
    DK.P2({U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    DK.P2({Nat.is_lt(0n, r) == True{} : Bool},
    DK.P2({Nat.is_le(r, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(O.e8(1n+q), FD.spec_common__pow2(dw)) == True{} : Bool},
          {WS.bdrop(r, WS.cb(FD.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>}))))))))))))

def sd(w: O.Words) -> Data: DK.Or2(sd0(w), sd1(w))
'''


# ---- the object API's output path (B.emit) on a perfect word tree ----
def _emit_text0():
    L = []
    w = L.append
    w('''import Base
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/compact/buf.bend as BF
import ../proofs/obj/spec_fixed.bend as SF
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/arr_emit.bend as AE
import ./e2e_cap.bend as C

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# The object API's output path on a buffer over a perfect word tree T of depth d: B.emit of the
# first (n + 3) / 4 words, cut at n, is the first n bytes of T's words (ob). For n = 4K + r,
# r in 1..4: the top word gives its first r bytes (bytes_in = r), the K words below it all four
# (arr_emit.eg). The variable-size encode bridges read their encoder's output through it.

def peta(-X: Type, -Y: Type, p: X & Y) -> {p == (Pair.fst(X, Y, p), Pair.snd(X, Y, p)) : X & Y}:
  (a, c) = p
  {==}

# w + (4 + x) = 4 + (w + x)
law sh4:
  for +w: Nat
  for +x: Nat
  {Nat.add(w, 4n+x) == 4n+Nat.add(w, x) : Nat}
def sh4(w, x):
  match w:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, Nat.add(p, 4n+x), 4n+Nat.add(p, x), sh4(p, x))

def pw4(+d: Nat) -> {FD.spec_common__pow2(2n+d) == A.quad(FD.spec_common__pow2(d)) : Nat}: {==}
''')
    T = 'FD.array__thaw(U32, T)'
    BUF = f'B.Buf{{{T}, n}}'
    WS = 'FD.array__slots(U32, T)'
    HD = '+hd: {Nat.is_lt(d, 29n) == True{} : Bool}'
    HN = '+hn: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{} : Bool}'
    PF = '+pf: {FD.array__perfect(U32, d, T) == True{} : Bool}'
    # the tail of the loop: the words below the top one, all four bytes
    w(f'''# The loop below the top word (to_nat(j) = K): the K words under it, all four bytes each.
def tail(+K: Nat, +d: Nat, +T: FD.array__Tree<U32>, +n: U32, +j: U32, acc: +List<U32>, +ej: {{U32.to_nat(j) == K : Nat}},
    +hd31: {{Nat.is_lt(d, 31n) == True{{}} : Bool}}, +hK: {{Nat.is_lt(K, FD.spec_common__pow2(d)) == True{{}} : Bool}},
    +hq: {{Nat.is_le(A.quad(K), U32.to_nat(n)) == True{{}} : Bool}}, {PF})
    -> {{Pair.snd(B.Buf, +List<U32>, B.emit_go(K, (j - 1 : U32), n, acc, B.word({BUF}, (j - 1 : U32)))) == AE.rl(FD.spec_common__take(U32, {WS}, K), acc) : +List<U32>}}:
  match K:
    case 0n:
      %Equal.sym(List<&2, U32>, FD.spec_common__take(U32, {WS}, 0n), Nil{{}}, FD.list__sc_take_zero(U32, {WS})) : {{Pair.snd(B.Buf, +List<U32>, B.emit_go(0n, (j - 1 : U32), n, acc, B.word({BUF}, (j - 1 : U32)))) == AE.rl(_, acc) : +List<U32>}}
      %Equal.sym(B.Buf & U32, B.word({BUF}, (j - 1 : U32)), (Pair.fst(B.Buf, U32, B.word({BUF}, (j - 1 : U32))), Pair.snd(B.Buf, U32, B.word({BUF}, (j - 1 : U32)))), peta(B.Buf, U32, B.word({BUF}, (j - 1 : U32)))) :
        {{Pair.snd(B.Buf, +List<U32>, B.emit_go(0n, (j - 1 : U32), n, acc, _)) == acc : +List<U32>}}
      {{==}}
    case 1n+ +q:
      +ej1 = AE.pred1(j, q, ej)
      +hq1 = FD.nat__lt_trans(q, 1n+q, FD.spec_common__pow2(d), FD.nat__lt_succ(q), hK)
      +hj1 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(d)) == True{{}} : Bool}}, q, U32.to_nat((j - 1 : U32)), Equal.sym(Nat, U32.to_nat((j - 1 : U32)), q, ej1), hq1)
      %Equal.sym(B.Buf & U32, B.word({BUF}, (j - 1 : U32)), ({BUF}, FD.flat__nthc({WS}, U32.to_nat((j - 1 : U32)))), BF.word_read(d, T, n, (j - 1 : U32), FD.nat__lt_trans(d, 31n, 32n, hd31, {{==}}), hj1, pf)) :
        {{Pair.snd(B.Buf, +List<U32>, B.emit_go(1n+q, (j - 1 : U32), n, acc, _)) == AE.rl(FD.spec_common__take(U32, {WS}, 1n+q), acc) : +List<U32>}}
      %Equal.sym(Nat, U32.to_nat((j - 1 : U32)), q, ej1) :
        {{Pair.snd(B.Buf, +List<U32>, B.emit_go(1n+q, (j - 1 : U32), n, acc, ({BUF}, FD.flat__nthc({WS}, _)))) == AE.rl(FD.spec_common__take(U32, {WS}, 1n+q), acc) : +List<U32>}}
      Equal.cong(B.Buf & +List<U32>, +List<U32>, p => Pair.snd(B.Buf, +List<U32>, p), B.emit_go(1n+q, (j - 1 : U32), n, acc, ({BUF}, FD.flat__nthc({WS}, q))), ({BUF}, AE.rl(FD.spec_common__take(U32, {WS}, 1n+q), acc)),
        AE.eg(q, (j - 1 : U32), n, acc, d, T, ej1, hd31, hq1, hq, pf))
''')
    for r in (1, 2, 3, 4):
        R = f'{r}n'
        RU = str(r)
        s = f'_{r}'
        # nwn(r + quad K) = 1 + K
        w(f'''# ---- the top word holds {r} byte{'s' if r > 1 else ''} ----

law nw{s}:
  for +K: Nat
  {{C.nwn(Nat.add({R}, A.quad(K))) == 1n+K : Nat}}
def nw{s}(K):
  match K:
    case 0n: {{==}}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, C.nwn(Nat.add({R}, A.quad(p))), 1n+p, nw{s}(p))

law gt{s}:
  for +x: Nat
  {{Nat.is_lt(x, Nat.add({R}, x)) == True{{}} : Bool}}
def gt{s}(x):
  match x:
    case 0n: {{==}}
    case 1n+ +p: gt{s}(p)

law bt{s}:
  for +K: Nat
  for +W: List<&2, U32>
  for +hl: {{Nat.is_lt(K, FD.spec_common__length(U32, W)) == True{{}} : Bool}}
  {{AE.rl(FD.spec_common__take(U32, W, K), B.prepend_word({RU}, FD.flat__nthc(W, K), [])) == VSP.bt(Nat.add({R}, A.quad(K)), SF.limbs(W)) : +List<U32>}}
def bt{s}(K, W, hl):
  match K W:
    case _ Nil{{}}: Empty.absurd({{AE.rl(FD.spec_common__take(U32, Nil{{}}, K), B.prepend_word({RU}, FD.flat__nthc(Nil{{}}, K), [])) == VSP.bt(Nat.add({R}, A.quad(K)), SF.limbs(Nil{{}})) : +List<U32>}}, FD.nat__lt_zero_absurd(K, hl))
    case 0n Con{{+x, +t}}: {{==}}
    case 1n+ +p Con{{+x, +t}}:
      Equal.cong(+List<U32>, +List<U32>, z => B.byte_sel(0, x) <> B.byte_sel(1, x) <> B.byte_sel(2, x) <> B.byte_sel(3, x) <> z,
        AE.rl(FD.spec_common__take(U32, t, p), B.prepend_word({RU}, FD.flat__nthc(t, p), [])), VSP.bt(Nat.add({R}, A.quad(p)), SF.limbs(t)), bt{s}(p, t, hl))
''')
        if r < 4:
            w(f'''law nle{s}:
  for +x: Nat
  {{Nat.is_le(Nat.add({R}, x), x) == False{{}} : Bool}}
def nle{s}(x):
  match x:
    case 0n: {{==}}
    case 1n+ +p: nle{s}(p)

law lt4{s}:
  for +x: Nat
  {{Nat.is_le(Nat.add(x, 4n), Nat.add({R}, x)) == False{{}} : Bool}}
def lt4{s}(x):
  match x:
    case 0n: {{==}}
    case 1n+ +p: lt4{s}(p)

law sub{s}:
  for +x: Nat
  {{Nat.sub(Nat.add({R}, x), x) == {R} : Nat}}
def sub{s}(x):
  match x:
    case 0n: {{==}}
    case 1n+ +p: sub{s}(p)

# the top word's bytes: n - 4j = {r}
def bi{s}(+j: U32, +n: U32, +K: Nat, +d: Nat, +ej: {{U32.to_nat(j) == K : Nat}}, {HD},
    +hK: {{Nat.is_lt(K, FD.spec_common__pow2(d)) == True{{}} : Bool}}, +eN: {{U32.to_nat(n) == Nat.add({R}, A.quad(K)) : Nat}}) -> {{B.bytes_in(j, n) == {RU} : U32}}:
  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {{==}})
  +q4 = AE.quadv(j, K, d, ej, hd31, hK)
  +c1 = Equal.trans(Bool, U32.is_le(n, (4 * j : U32)), Nat.is_le(U32.to_nat(n), U32.to_nat((4 * j : U32))), False{{}}, AE.le_nat(n, (4 * j : U32)),
    FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(n), z) == False{{}} : Bool}}, A.quad(K), U32.to_nat((4 * j : U32)), Equal.sym(Nat, U32.to_nat((4 * j : U32)), A.quad(K), q4),
      FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(K)) == False{{}} : Bool}}, Nat.add({R}, A.quad(K)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add({R}, A.quad(K)), eN), nle{s}(A.quad(K)))))
  +h4 = FD.nat__lt_succ_le_succ(K, FD.spec_common__pow2(d), hK)
  +hb = FD.logic__subst(Nat, z => {{Nat.is_le(z, O.pow2n(2n+d)) == True{{}} : Bool}}, A.quad(1n+K), Nat.add(U32.to_nat((4 * j : U32)), 4n),
    Equal.trans(Nat, A.quad(1n+K), Nat.add(A.quad(K), 4n), Nat.add(U32.to_nat((4 * j : U32)), 4n), FD.nat__add_comm(4n, A.quad(K)),
      Equal.cong(Nat, Nat, z => Nat.add(z, 4n), A.quad(K), U32.to_nat((4 * j : U32)), Equal.sym(Nat, U32.to_nat((4 * j : U32)), A.quad(K), q4))),
    FD.logic__subst(Nat, z => {{Nat.is_le(A.quad(1n+K), z) == True{{}} : Bool}}, FD.spec_common__pow2(2n+d), O.pow2n(2n+d), VD.s_pow2_eq(2n+d),
      AE.quad_le(1n+K, FD.spec_common__pow2(d), h4)))
  +e4 = VD.s_add_nat((4 * j : U32), 4, 2n+d, FD.nat__lt_trans(d, 29n, 30n, hd, {{==}}), hb)
  +c2 = Equal.trans(Bool, U32.is_le(((4 * j : U32) + 4 : U32), n), Nat.is_le(U32.to_nat(((4 * j : U32) + 4 : U32)), U32.to_nat(n)), False{{}}, AE.le_nat(((4 * j : U32) + 4 : U32), n),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(n)) == False{{}} : Bool}}, Nat.add(A.quad(K), 4n), U32.to_nat(((4 * j : U32) + 4 : U32)),
      Equal.sym(Nat, U32.to_nat(((4 * j : U32) + 4 : U32)), Nat.add(A.quad(K), 4n), Equal.trans(Nat, U32.to_nat(((4 * j : U32) + 4 : U32)), Nat.add(U32.to_nat((4 * j : U32)), 4n), Nat.add(A.quad(K), 4n), e4,
        Equal.cong(Nat, Nat, z => Nat.add(z, 4n), U32.to_nat((4 * j : U32)), A.quad(K), q4))),
      FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(A.quad(K), 4n), z) == False{{}} : Bool}}, Nat.add({R}, A.quad(K)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add({R}, A.quad(K)), eN), lt4{s}(A.quad(K)))))
  +hle = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(n)) == True{{}} : Bool}}, A.quad(K), U32.to_nat((4 * j : U32)), Equal.sym(Nat, U32.to_nat((4 * j : U32)), A.quad(K), q4),
    FD.logic__subst(Nat, z => {{Nat.is_le(A.quad(K), z) == True{{}} : Bool}}, Nat.add({R}, A.quad(K)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add({R}, A.quad(K)), eN),
      FD.nat__lt_le(A.quad(K), Nat.add({R}, A.quad(K)), gt{s}(A.quad(K)))))
  +es = Equal.trans(Nat, U32.to_nat((n - (4 * j : U32) : U32)), Nat.sub(U32.to_nat(n), U32.to_nat((4 * j : U32))), {R}, FD.u32__sub_nat(n, (4 * j : U32), hle),
    Equal.trans(Nat, Nat.sub(U32.to_nat(n), U32.to_nat((4 * j : U32))), Nat.sub(Nat.add({R}, A.quad(K)), A.quad(K)), {R},
      Equal.trans(Nat, Nat.sub(U32.to_nat(n), U32.to_nat((4 * j : U32))), Nat.sub(Nat.add({R}, A.quad(K)), U32.to_nat((4 * j : U32))), Nat.sub(Nat.add({R}, A.quad(K)), A.quad(K)),
        Equal.cong(Nat, Nat, z => Nat.sub(z, U32.to_nat((4 * j : U32))), U32.to_nat(n), Nat.add({R}, A.quad(K)), eN),
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.add({R}, A.quad(K)), z), U32.to_nat((4 * j : U32)), A.quad(K), q4)),
      sub{s}(A.quad(K))))
  +eu = FD.u32__injective((n - (4 * j : U32) : U32), {RU}, es)
  %Equal.sym(Bool, U32.is_le(n, (4 * j : U32)), False{{}}, c1) :
    {{B.pick(_, 0, B.pick(U32.is_le(((4 * j : U32) + 4 : U32), n), 4, (n - (4 * j : U32) : U32))) == {RU} : U32}}
  %Equal.sym(Bool, U32.is_le(((4 * j : U32) + 4 : U32), n), False{{}}, c2) :
    {{B.pick(False{{}}, 0, B.pick(_, 4, (n - (4 * j : U32) : U32))) == {RU} : U32}}
  eu
''')
        else:
            w(f'''def bi{s}(+j: U32, +n: U32, +K: Nat, +d: Nat, +ej: {{U32.to_nat(j) == K : Nat}}, {HD},
    +hK: {{Nat.is_lt(K, FD.spec_common__pow2(d)) == True{{}} : Bool}}, +eN: {{U32.to_nat(n) == Nat.add({R}, A.quad(K)) : Nat}}) -> {{B.bytes_in(j, n) == {RU} : U32}}:
  AE.bin4(j, n, K, d, ej, FD.nat__lt_trans(d, 29n, 31n, hd, {{==}}), hK,
    FD.logic__subst(Nat, z => {{Nat.is_le(A.quad(1n+K), z) == True{{}} : Bool}}, A.quad(1n+K), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), A.quad(1n+K), eN), FD.nat__le_refl(A.quad(1n+K))))
''')
        # the core for this r
        w(f'''def core{s}(+K: Nat, +d: Nat, +T: FD.array__Tree<U32>, +n: U32, {PF}, {HD}, {HN}, +eN: {{U32.to_nat(n) == Nat.add({R}, A.quad(K)) : Nat}})
    -> {{Pair.snd(B.Buf, +List<U32>, B.emit({BUF}, 0, C.nwu(n))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}:
  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {{==}})
  +hlt = FD.logic__subst(Nat, z => {{Nat.is_lt(A.quad(K), z) == True{{}} : Bool}}, Nat.add({R}, A.quad(K)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add({R}, A.quad(K)), eN), gt{s}(A.quad(K)))
  +hK = A.quad_lt(K, FD.spec_common__pow2(d), FD.nat__lt_le_trans(A.quad(K), U32.to_nat(n), A.quad(FD.spec_common__pow2(d)), hlt, hn))
  +ek = Equal.trans(Nat, U32.to_nat(C.nwu(n)), C.nwn(U32.to_nat(n)), 1n+K, C.nw(n, d, hd, hn),
    Equal.trans(Nat, C.nwn(U32.to_nat(n)), C.nwn(Nat.add({R}, A.quad(K))), 1n+K, Equal.cong(Nat, Nat, z => C.nwn(z), U32.to_nat(n), Nat.add({R}, A.quad(K)), eN), nw{s}(K)))
  +k = C.nwu(n)
  +j = U32.sub(U32.add(0, k), 1)
  +e0 = FD.logic__subst(U32, z => {{U32.to_nat(z) == 1n+K : Nat}}, k, U32.add(0, k), Equal.sym(U32, U32.add(0, k), k, FD.u32alg__zero_add(k)), ek)
  +ej = AE.pred1(U32.add(0, k), K, e0)
  +hj = FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(d)) == True{{}} : Bool}}, K, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), K, ej), hK)
  +hq = FD.nat__lt_le(A.quad(K), U32.to_nat(n), hlt)
  +hl = FD.logic__subst(Nat, z => {{Nat.is_lt(K, z) == True{{}} : Bool}}, FD.spec_common__pow2(d), FD.spec_common__length(U32, {WS}), Equal.sym(Nat, FD.spec_common__length(U32, {WS}), FD.spec_common__pow2(d), FD.array__slots_length(U32, d, T, pf)), hK)
  %Equal.sym(Nat, U32.to_nat(k), 1n+K, ek) :
    {{Pair.snd(B.Buf, +List<U32>, B.emit_go(_, j, n, [], B.word({BUF}, j))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}
  %Equal.sym(B.Buf & U32, B.word({BUF}, j), ({BUF}, FD.flat__nthc({WS}, U32.to_nat(j))), BF.word_read(d, T, n, j, FD.nat__lt_trans(d, 31n, 32n, hd31, {{==}}), hj, pf)) :
    {{Pair.snd(B.Buf, +List<U32>, B.emit_go(1n+K, j, n, [], _)) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}
  %Equal.sym(Nat, U32.to_nat(j), K, ej) :
    {{Pair.snd(B.Buf, +List<U32>, B.emit_go(1n+K, j, n, [], ({BUF}, FD.flat__nthc({WS}, _)))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}
  %Equal.sym(U32, B.bytes_in(j, n), {RU}, bi{s}(j, n, K, d, ej, hd, hK, eN)) :
    {{Pair.snd(B.Buf, +List<U32>, B.emit_go(K, (j - 1 : U32), n, B.prepend_word(_, FD.flat__nthc({WS}, K), []), B.word({BUF}, (j - 1 : U32)))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add({R}, A.quad(K)), eN) : {{Pair.snd(B.Buf, +List<U32>, B.emit_go(K, (j - 1 : U32), n, B.prepend_word({RU}, FD.flat__nthc({WS}, K), []), B.word({BUF}, (j - 1 : U32)))) == VSP.bt(_, SF.limbs({WS})) : +List<U32>}}
  Equal.trans(+List<U32>, Pair.snd(B.Buf, +List<U32>, B.emit_go(K, (j - 1 : U32), n, B.prepend_word({RU}, FD.flat__nthc({WS}, K), []), B.word({BUF}, (j - 1 : U32)))),
    AE.rl(FD.spec_common__take(U32, {WS}, K), B.prepend_word({RU}, FD.flat__nthc({WS}, K), [])), VSP.bt(Nat.add({R}, A.quad(K)), SF.limbs({WS})),
    tail(K, d, T, n, j, B.prepend_word({RU}, FD.flat__nthc({WS}, K), []), ej, hd31, hK, hq, pf), bt{s}(K, {WS}, hl))
''')
    # dispatch over n = M + quad K
    w(f'''# ---- n = 0, and the dispatch over n = M + 4K ----

def zero(+d: Nat, +T: FD.array__Tree<U32>, +n: U32, +eN: {{U32.to_nat(n) == 0n : Nat}})
    -> {{Pair.snd(B.Buf, +List<U32>, B.emit({BUF}, 0, C.nwu(n))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}:
  +e = FD.u32__injective(n, 0, eN)
  %Equal.sym(U32, n, 0, e) : {{Pair.snd(B.Buf, +List<U32>, B.emit(B.Buf{{{T}, _}}, 0, C.nwu(_))) == VSP.bt(U32.to_nat(_), SF.limbs({WS})) : +List<U32>}}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{{{T}, 0}}, U32.sub(U32.add(0, C.nwu(0)), 1)), (Pair.fst(B.Buf, U32, B.word(B.Buf{{{T}, 0}}, U32.sub(U32.add(0, C.nwu(0)), 1))), Pair.snd(B.Buf, U32, B.word(B.Buf{{{T}, 0}}, U32.sub(U32.add(0, C.nwu(0)), 1)))), peta(B.Buf, U32, B.word(B.Buf{{{T}, 0}}, U32.sub(U32.add(0, C.nwu(0)), 1)))) :
    {{Pair.snd(B.Buf, +List<U32>, B.emit_go(U32.to_nat(C.nwu(0)), U32.sub(U32.add(0, C.nwu(0)), 1), 0, [], _)) == [] : +List<U32>}}
  {{==}}

def z0(+K: Nat, +d: Nat, +T: FD.array__Tree<U32>, +n: U32, {PF}, {HD}, {HN}, +eN: {{U32.to_nat(n) == Nat.add(0n, A.quad(K)) : Nat}})
    -> {{Pair.snd(B.Buf, +List<U32>, B.emit({BUF}, 0, C.nwu(n))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}:
  match K:
    case 0n: zero(d, T, n, eN)
    case 1n+ +q: core_4(q, d, T, n, pf, hd, hn, eN)

law dsp:
  for +M: Nat
  for +K: Nat
  for +d: Nat
  for +T: FD.array__Tree<U32>
  for +n: U32
  for {PF[1:]}
  for {HD[1:]}
  for {HN[1:]}
  for +eN: {{U32.to_nat(n) == Nat.add(M, A.quad(K)) : Nat}}
  {{Pair.snd(B.Buf, +List<U32>, B.emit({BUF}, 0, C.nwu(n))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}
def dsp(M, K, d, T, n, pf, hd, hn, eN):
  match M:
    case 0n: z0(K, d, T, n, pf, hd, hn, eN)
    case 1n: core_1(K, d, T, n, pf, hd, hn, eN)
    case 2n: core_2(K, d, T, n, pf, hd, hn, eN)
    case 3n: core_3(K, d, T, n, pf, hd, hn, eN)
    case 4n: core_4(K, d, T, n, pf, hd, hn, eN)
    case 5n+ +z:
      dsp(1n+z, 1n+K, d, T, n, pf, hd, hn,
        Equal.trans(Nat, U32.to_nat(n), Nat.add(5n+z, A.quad(K)), Nat.add(1n+z, A.quad(1n+K)), eN,
          Equal.cong(Nat, Nat, y => 1n+y, 4n+Nat.add(z, A.quad(K)), Nat.add(z, 4n+A.quad(K)), Equal.sym(Nat, Nat.add(z, 4n+A.quad(K)), 4n+Nat.add(z, A.quad(K)), sh4(z, A.quad(K))))))

# The output path's bytes: the first n bytes of the words (n <= 4 * 2^d, d < 29).
def ob(+d: Nat, +T: FD.array__Tree<U32>, +n: U32, {PF}, {HD}, {HN})
    -> {{Pair.snd(B.Buf, +List<U32>, B.emit({BUF}, 0, C.nwu(n))) == VSP.bt(U32.to_nat(n), SF.limbs({WS})) : +List<U32>}}:
  dsp(U32.to_nat(n), 0n, d, T, n, pf, hd, hn, Equal.sym(Nat, Nat.add(U32.to_nat(n), 0n), U32.to_nat(n), FD.nat__add_zero(U32.to_nat(n))))
''')
    return ''.join(L)


def _emit_nmax(base):
    """The same output-path lemma for depth d < 31 and n <= VB.NMAX() (obN): n + 3 does not wrap by the
    object API's limit rather than by 4 * 2^d with d < 29."""
    import re as _re
    names = ['bi_1', 'bi_2', 'bi_3', 'bi_4', 'core_1', 'core_2', 'core_3', 'core_4', 'z0']
    blocks = []
    for nm in names:
        i = base.index(f'\ndef {nm}(')
        j = base.index('\ndef ', i + 1)
        k = base.find('\nlaw ', i + 1)
        if k != -1 and k < j:
            j = k
        j2 = base.rfind('\n# ', i, j)
        blocks.append(base[i:j2 if j2 > i else j])
    i = base.index('\nlaw dsp:')
    j = base.index('\n# The output path', i)
    blocks.append(base[i:j])
    i = base.index('\ndef ob(')
    blocks.append(base[i:])
    txt = '\n'.join(blocks)
    for nm in names:
        new = nm.replace('bi_', 'biM_').replace('core_', 'coreM_').replace('z0', 'z0M')
        txt = _re.sub(r'\b' + nm + r'\(', new + '(', txt)
    txt = txt.replace('law dsp:', 'law dspM:').replace('dsp(', 'dspM(').replace('def ob(', 'def obN(')
    txt = txt.replace('C.nw(n, d, hd, hn)', 'C.nwM(n, hM)')
    txt = txt.replace('+hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})', '+hd31 = hd')
    txt = txt.replace('FD.nat__lt_trans(d, 29n, 31n, hd, {==})', 'hd')
    txt = txt.replace('  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}', '  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}\n  for +hM: {U32.is_le(n, VB.NMAX()) == True{} : Bool}')
    txt = txt.replace('  for hd: {Nat.is_lt(d, 29n) == True{} : Bool}', '  for hd: {Nat.is_lt(d, 31n) == True{} : Bool}\n  for +hM: {U32.is_le(n, VB.NMAX()) == True{} : Bool}')
    txt = txt.replace('+hd: {Nat.is_lt(d, 29n) == True{} : Bool}', '+hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hM: {U32.is_le(n, VB.NMAX()) == True{} : Bool}')
    txt = txt.replace(', hd, hn', ', hd, hM, hn').replace(', ej, hd, hK, eN)', ', ej, hd, hM, hK, eN)')
    txt = txt.replace('def dspM(M, K, d, T, n, pf, hd, hn, eN):', 'def dspM(M, K, d, T, n, pf, hd, hM, hn, eN):')
    for r in (1, 2, 3):
        old = f'  +e4 = VD.s_add_nat((4 * j : U32), 4, 2n+d, FD.nat__lt_trans(d, 29n, 30n, hd, {{==}}), hb)'
        new = (f'  +hq4 = FD.nat__le_trans(Nat.add(4n, A.quad(K)), Nat.add(31n, A.quad(K)), Nat.add(31n, Nat.add({r}n, A.quad(K))), Order.add_right(4n, 31n, A.quad(K), {{==}}),\n'
               f'    Order.add_left(31n, A.quad(K), Nat.add({r}n, A.quad(K)), AC.le_addl({r}n, A.quad(K))))\n'
               f'  +hq5 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(4n, z), Nat.add(31n, U32.to_nat(n))) == True{{}} : Bool}}, A.quad(K), U32.to_nat((4 * j : U32)), Equal.sym(Nat, U32.to_nat((4 * j : U32)), A.quad(K), q4),\n'
               f'    FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(4n, A.quad(K)), Nat.add(31n, z)) == True{{}} : Bool}}, Nat.add({r}n, A.quad(K)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add({r}n, A.quad(K)), eN), hq4))\n'
               f'  +e4 = Equal.trans(Nat, U32.to_nat(((4 * j : U32) + 4 : U32)), Nat.add(4n, U32.to_nat((4 * j : U32))), Nat.add(U32.to_nat((4 * j : U32)), 4n),\n'
               f'    VB.add_lt32((4 * j : U32), 4, U32.to_nat((4 * j : U32)), {{==}}, FD.nat__le_lt_trans(Nat.add(4n, U32.to_nat((4 * j : U32))), Nat.add(31n, U32.to_nat(n)), FD.spec_common__pow2(32n), hq5, VB.nmax_lt(n, hM))),\n'
               f'    FD.nat__add_comm(4n, U32.to_nat((4 * j : U32))))')
        assert txt.count(old) >= 1, (r, txt.count(old))
        txt = txt.replace(old, new, 1)
    return ('\n\n# ---- the same at the object API\'s own limit: depth d < 31, n <= VB.NMAX() (obN) ----\n' + txt)


def emit_text():
    base = _emit_text0()
    base = base.replace('import ./e2e_cap.bend as C\n', 'import ./e2e_cap.bend as C\nimport ../proofs/obj/vbuf.bend as VB\nimport ../proofs/obj/arr_copy.bend as AC\nimport ../proofs/nat_order.bend as Order\n', 1)
    return base + _emit_nmax(base)


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

# ---- variable-size names: (ii) on views and (iii), through the loader ----
# The codec laws of a variable-size name X (proofs/obj/var_codec_X.bend and its _rej module) are
# stated over a buffer BF(t, n) = B.Buf{thaw(t), n} of a perfect word tree t of depth d with
# d below a bound and n <= 4 * 2^d: decode_accept / decode_spec when CHK(t, n) holds,
# decode_none / decode_reject when it does not. The loader (e2e_load) puts a byte list bs of
# length n in such a buffer at d = B.capacity(n), with VW(t, n) = bs; the capacity facts (e2e_cap)
# give the bounds for n <= 4 * 2^K, K one below the laws' depth bound (the premise hS). A name
# is bridged once its view lemma is written: vv, the root view of OBJ(t, n) is the codec law's
# value VAL(t, n) when CHK(t, n) holds (VDEC_VIEWS).
VDEC_HEAD = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
             'import ../src/obj.bend as O', 'import ../types/fulu_obj.bend as T', 'import ../types/schema.bend as S',
             'import ../types/primitive.bend as P', 'import ../spec/fulu_schemas.bend as Spec', 'import ../spec/primitives.bend as SP',
             'import ../spec/decoding_relation.bend as Decoding', 'import ../proofs/type_validator_soundness.bend as TVS',
             'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/spec_fixed.bend as F',
             'import ../proofs/obj/arr_copy.bend as AC', 'import ./e2e_bytes.bend as E', 'import ./e2e_load.bend as L', 'import ./e2e_cap.bend as C']
VDEC_VIEWS = {
    'DataColumnsByRootIdentifier': {
        'view': 'RT.v_DataColumnsByRootIdentifier',
        'imports': ['import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vspec.bend as VSP', 'import ../proofs/obj/vbuf.bend as VB',
                    'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/root_types.bend as RT', 'import ./e2e_ulist.bend as U'],
        'text': r'''# ---- the view of a decoded object is the codec law's value ----

def cnt(+n: U32, +hc: {DC.whole(DC.LL(n)) == True{} : Bool}) -> {U32.to_nat(U32.shrn(DC.LL(n), 3n)) == DC.CQ(n) : Nat}:
  Equal.trans(Nat, U32.to_nat(U32.shrn(DC.LL(n), 3n)), VD.s_rng(3n, U32.to_nat(DC.LL(n))), DC.CQ(n), VD.shrk(3n, DC.LL(n)),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(DC.LL(n))), VD.s_rng(3n, VSP.x8(DC.CQ(n))), DC.CQ(n),
      Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(DC.LL(n)), VSP.x8(DC.CQ(n)), DC.eLc(n, hc)), U.r8(DC.CQ(n))))

def wh(+t: FD.array__Tree<U32>, +n: U32, +hchk: {DC.CHK(t, n) == True{} : Bool}) -> {DC.whole(DC.LL(n)) == True{} : Bool}:
  +a = U32.is_le(36, n)
  +b = U32.is_eq(DC.SPO(t), 36)
  +c = DC.whole(U32.sub(n, DC.SPO(t)))
  +epo = FD.u32alg__eq_of(DC.SPO(t), 36, DC.chk_b(a, b, c, hchk))
  FD.logic__subst(U32, z => {DC.whole(U32.sub(n, z)) == True{} : Bool}, DC.SPO(t), 36, epo, DC.chk_c(a, b, c, hchk))

def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, @BD@) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == True{} : Bool}) -> {RT.v_DataColumnsByRootIdentifier(DC.OBJ(t, n)) == DC.VAL(t, n) : S.Value}:
  Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{S.BytesValue{F.limbs([VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)])}, S.Items{z, S.EmptyItems{}}}}, UL.uview(O.Words{FD.array__thaw(U32, DC.MM(t, n)), DC.LL(n)}),
    S.Sequence{VSP.uitems(DC.CQ(n), FD.array__slots(U32, DC.MM(t, n)))}, U.uvw(DC.MM(t, n), DC.LL(n), DC.CQ(n), cnt(n, wh(t, n, hchk))))

'''},
}
VDEC_REST = r'''# ---- the loaded buffer ----

# the words the loader fills, at the buffer's depth
def TT(+bs: +List<U32>, +n: U32) -> FD.array__Tree<U32>: AC.segt(B.capacity(n), 0n, L.wlp(bs))

def ld(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}) -> {B.fill_at(B.alloc(n), 0, bs) == DC.BF(TT(bs, n), n) : B.Buf}:
  L.bf(bs, n, B.capacity(n), hd, {==}, C.cap_32(n, @K@, {==}, hS), C.cap_w(bs, n, @K@, hn, {==}, hS))

def vwe(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}) -> {DC.VW(TT(bs, n), n) == bs : +List<U32>}:
  L.vw(bs, n, B.capacity(n), hd, hn, C.cap_w(bs, n, @K@, hn, {==}, hS))

def pfe(+bs: +List<U32>, +n: U32) -> {FD.array__perfect(U32, B.capacity(n), TT(bs, n)) == True{} : Bool}: L.seg_pf(B.capacity(n), L.wlp(bs))

# ---- the two sides on an accepted and a rejected buffer ----

def d_acc(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +hchk: {DC.CHK(TT(bs, n), n) == True{} : Bool}) -> {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{DC.OBJ(TT(bs, n), n)} : Maybe<&1, T.@X@>}:
  %Equal.sym(B.Buf, B.fill_at(B.alloc(n), 0, bs), DC.BF(TT(bs, n), n), ld(bs, n, hn, hd, hS)) : {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(_, n)) == Some{DC.OBJ(TT(bs, n), n)} : Maybe<&1, T.@X@>}
  Equal.cong(B.Buf & Maybe<&1, T.@X@>, Maybe<&1, T.@X@>, q => Pair.snd(B.Buf, Maybe<&1, T.@X@>, q), T.@X@_decode(DC.BF(TT(bs, n), n), n), (DC.BF(TT(bs, n), n), Some{DC.OBJ(TT(bs, n), n)}),
    DC.decode_accept(B.capacity(n), TT(bs, n), n, pfe(bs, n), FD.nat__le_lt_trans(B.capacity(n), @K@, @BD@, C.cap_le(n, @K@, {==}, hS), {==}), C.cap_q(n, @K@, {==}, hS), hchk))

def d_none(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +hchk: {DC.CHK(TT(bs, n), n) == False{} : Bool}) -> {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == None{} : Maybe<&1, T.@X@>}:
  %Equal.sym(B.Buf, B.fill_at(B.alloc(n), 0, bs), DC.BF(TT(bs, n), n), ld(bs, n, hn, hd, hS)) : {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(_, n)) == None{} : Maybe<&1, T.@X@>}
  Equal.cong(B.Buf & Maybe<&1, T.@X@>, Maybe<&1, T.@X@>, q => Pair.snd(B.Buf, Maybe<&1, T.@X@>, q), T.@X@_decode(DC.BF(TT(bs, n), n), n), (DC.BF(TT(bs, n), n), None{}),
    DR.decode_none(B.capacity(n), TT(bs, n), n, pfe(bs, n), FD.nat__le_lt_trans(B.capacity(n), @K@, @BD@, C.cap_le(n, @K@, {==}, hS), {==}), C.cap_q(n, @K@, {==}, hS), hchk))

def s_dec(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +hchk: {DC.CHK(TT(bs, n), n) == True{} : Bool}) -> Decoding.decodes(Spec.@X@(), bs, DC.VAL(TT(bs, n), n)):
  %vwe(bs, n, hn, hd, hS) : Decoding.decodes(Spec.@X@(), _, DC.VAL(TT(bs, n), n))
  DC.decode_spec(B.capacity(n), TT(bs, n), n, pfe(bs, n), FD.nat__le_lt_trans(B.capacity(n), @K@, @BD@, C.cap_le(n, @K@, {==}, hS), {==}), C.cap_q(n, @K@, {==}, hS), hchk)

def s_out(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +hchk: {DC.CHK(TT(bs, n), n) == False{} : Bool}) -> Decoding.outside_image(Spec.@X@(), bs):
  %vwe(bs, n, hn, hd, hS) : Decoding.outside_image(Spec.@X@(), _)
  DR.decode_reject(B.capacity(n), TT(bs, n), n, pfe(bs, n), C.cap_q(n, @K@, {==}, hS), hchk)

def a_acc(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +hchk: {DC.CHK(TT(bs, n), n) == True{} : Bool}) -> {API.deserialize(Spec.@X@(), bs) == Some{DC.VAL(TT(bs, n), n)} : Maybe<&2, S.Value>}:
  E2E.spec_accepted(Spec.@X@(), bs, DC.VAL(TT(bs, n), n), (TVS.public_sound(Spec.@X@(), {==}), s_dec(bs, n, hn, hd, hS, hchk)))

def a_none(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +hchk: {DC.CHK(TT(bs, n), n) == False{} : Bool}) -> {API.deserialize(Spec.@X@(), bs) == None{} : Maybe<&2, S.Value>}:
  E.outside_none(Spec.@X@(), bs, s_out(bs, n, hn, hd, hS, hchk))

# ---- (ii) on views, (iii) ----

def mv(m: Maybe<&1, T.@X@>) -> Maybe<&2, S.Value>:
  match m:
    case None{}: None{}
    case Some{o}: Some{@VIEW@(o)}

def d_v(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +c: Bool, +ec: {DC.CHK(TT(bs, n), n) == c : Bool}) -> {mv(Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n))) == API.deserialize(Spec.@X@(), bs) : Maybe<&2, S.Value>}:
  match c:
    case False{}:
      %Equal.sym(Maybe<&1, T.@X@>, Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), None{}, d_none(bs, n, hn, hd, hS, ec)) : {mv(_) == API.deserialize(Spec.@X@(), bs) : Maybe<&2, S.Value>}
      %Equal.sym(Maybe<&2, S.Value>, API.deserialize(Spec.@X@(), bs), None{}, a_none(bs, n, hn, hd, hS, ec)) : {mv(None{}) == _ : Maybe<&2, S.Value>}
      {==}
    case True{}:
      %Equal.sym(Maybe<&1, T.@X@>, Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{DC.OBJ(TT(bs, n), n)}, d_acc(bs, n, hn, hd, hS, ec)) : {mv(_) == API.deserialize(Spec.@X@(), bs) : Maybe<&2, S.Value>}
      %Equal.sym(Maybe<&2, S.Value>, API.deserialize(Spec.@X@(), bs), Some{DC.VAL(TT(bs, n), n)}, a_acc(bs, n, hn, hd, hS, ec)) : {mv(Some{DC.OBJ(TT(bs, n), n)}) == _ : Maybe<&2, S.Value>}
      Equal.cong(S.Value, Maybe<&2, S.Value>, z => Some{z}, @VIEW@(DC.OBJ(TT(bs, n), n)), DC.VAL(TT(bs, n), n), vv(B.capacity(n), TT(bs, n), n, pfe(bs, n), FD.nat__le_lt_trans(B.capacity(n), @K@, @BD@, C.cap_le(n, @K@, {==}, hS), {==}), C.cap_q(n, @K@, {==}, hS), ec))

def d_ra(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +c: Bool, +ec: {DC.CHK(TT(bs, n), n) == c : Bool}, +dn: {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == None{} : Maybe<&1, T.@X@>}) -> {API.deserialize(Spec.@X@(), bs) == None{} : Maybe<&2, S.Value>}:
  match c:
    case False{}: a_none(bs, n, hn, hd, hS, ec)
    case True{}: Empty.absurd({API.deserialize(Spec.@X@(), bs) == None{} : Maybe<&2, S.Value>}, E.none_someT(T.@X@, DC.OBJ(TT(bs, n), n), Equal.trans(Maybe<&1, T.@X@>, None{}, Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{DC.OBJ(TT(bs, n), n)}, Equal.sym(Maybe<&1, T.@X@>, Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), None{}, dn), d_acc(bs, n, hn, hd, hS, ec))))

def d_rb(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}, +c: Bool, +ec: {DC.CHK(TT(bs, n), n) == c : Bool}, +an: {API.deserialize(Spec.@X@(), bs) == None{} : Maybe<&2, S.Value>}) -> {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == None{} : Maybe<&1, T.@X@>}:
  match c:
    case False{}: d_none(bs, n, hn, hd, hS, ec)
    case True{}: Empty.absurd({Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == None{} : Maybe<&1, T.@X@>}, FD.logic__none_some(S.Value, DC.VAL(TT(bs, n), n), Equal.trans(Maybe<&2, S.Value>, None{}, API.deserialize(Spec.@X@(), bs), Some{DC.VAL(TT(bs, n), n)}, Equal.sym(Maybe<&2, S.Value>, API.deserialize(Spec.@X@(), bs), None{}, an), a_acc(bs, n, hn, hd, hS, ec))))

# (ii), on views: the view of the object the decoder returns is END_TO_END's deserialize.
def @R@_e2e_decode_view(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}) -> {mv(Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n))) == API.deserialize(Spec.@X@(), bs) : Maybe<&2, S.Value>}:
  d_v(bs, n, hn, hd, hS, DC.CHK(TT(bs, n), n), {==})

# (iii) the object decoder fails exactly when END_TO_END's deserialize does.
def @R@_e2e_decode_reject(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool})
    -> ({Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == None{} : Maybe<&1, T.@X@>} -> {API.deserialize(Spec.@X@(), bs) == None{} : Maybe<&2, S.Value>}) & ({API.deserialize(Spec.@X@(), bs) == None{} : Maybe<&2, S.Value>} -> {Pair.snd(B.Buf, Maybe<&1, T.@X@>, T.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == None{} : Maybe<&1, T.@X@>}):
  (dn => d_ra(bs, n, hn, hd, hS, DC.CHK(TT(bs, n), n), {==}, dn), an => d_rb(bs, n, hn, hd, hS, DC.CHK(TT(bs, n), n), {==}, an))
'''


def vdec_info(R):
    """The codec law modules of a variable-size name, from its decode facade, and the laws' depth bound."""
    f = ROOT / 'proofs/api' / f'{R}_decode_ssz_proof_generated.bend'
    if not f.exists():
        return None
    s = f.read_text()
    imp = dict((a, p) for p, a in re.findall(r'^import \.\./obj/(\S+) as (\w+)$', s, re.M))
    mods = {}
    for op in ('decode_accept', 'decode_spec', 'decode_none', 'decode_reject'):
        m = re.search(r'__' + op + '__' + op + r'\((?:\+d: Nat, )?\+t: \w+\.array__Tree<U32>, \+n: U32, (.*)\n  (\w+)\.' + op + r'\(', s)
        if not m:
            return None
        mods[op] = (imp[m.group(2)], m.group(1))
    sig = mods['decode_accept'][1]
    mb = re.search(r'\+hd: \{Nat\.is_lt\(d, (\d+)n\)', sig)
    mdc = re.search(r'\+hchk: \{(\w+)\.CHK\((?:t, )?n\)', sig)
    if not mb or not mdc or mdc.group(1) not in imp:
        return None
    acc = re.search(r'__decode_accept__decode_accept\(.*\) -> \{(\w+)\.(\w+)\(\w+\.BF\(t, n\), n\) == \(\w+\.BF\(t, n\), Some\{\w+\.OBJ\(((?:d, )?)t, n\)\}\) : \w+\.Buf & Maybe<&1, ([\w.]+)>\}', s)
    mbf = re.search(r'__decode_accept__decode_accept\(.*\) -> \{\w+\.\w+\((\w+)\.BF\(t, n\), n\)', s)
    mob = re.search(r'__decode_accept__decode_accept\(.*\) -> \{.*Some\{(\w+)\.OBJ\(', s)
    spec = re.search(r'__decode_spec__decode_spec\(.*\) -> \w+\.decodes\((\w+)\.\w+\(\), \w+\.VW\(t, n\), \w+\.VAL\(((?:d, )?)t, n\)\)', s)
    if not acc or not spec:
        return None
    ot = acc.group(4)
    mo = re.match(r'(?:\w+_)?O\.(\w+)$', ot)
    md = re.match(r'\w+_d\.(\w+)$', ot)
    otype = f'O.{mo.group(1)}' if mo else (f'T.{md.group(1)}' if md else None)
    if otype is None:
        return None
    return {'bound': int(mb.group(1)), 'dc': imp[mdc.group(1)], 'acc': mods['decode_accept'][0], 'spec': mods['decode_spec'][0],
            'none': mods['decode_none'][0], 'rej': mods['decode_reject'][0],
            'dfn': f'T.{acc.group(2)}', 'objd': bool(acc.group(3)), 'vald': bool(spec.group(2)), 'otype': otype, 'sch': 'GS' if imp.get(spec.group(1)) == 'generic_specs.bend' else 'Spec',
            'rejhd': '+hd:' in mods['decode_reject'][1],
            'bf': imp.get(mbf.group(1)) if mbf else None,
            'obj': imp.get(mob.group(1)) if mob else None,
            'chk1': bool(re.search(r'\+hchk: \{\w+\.CHK\(n\)', sig)),
            'noneshort': bool(re.search(r'__decode_none__decode_none\(\+t:', s))}


# The input-size bound of the variable-size bridges is a parameter: K = one below the codec
# laws' depth bound, read from the laws (so it rises when they are extended to deeper buffers),
# capped at CAP_KMAX, the largest K e2e_cap's lemmas cover (n + 3 must not overflow: K + 3 < 32).
# Names whose decode laws cover every tree depth below 31 (codec-deep) take the object API's own limit
# instead (vdec_nmax): hS is n <= VB.NMAX() (2^32 - 32), with e2e_cap's capM_* facts (depth at most 30).
# The K bound remains for the names whose laws still stop at a smaller depth.
CAP_KMAX = 28


def vdec_k(info):
    return max(1, min(info['bound'] - 1, CAP_KMAX))


def vdec_nmax(info):
    """The decode laws cover every tree depth below 31: the bridge takes the object API's own limit n <= NMAX."""
    return info['bound'] >= 31


def vdec_size(K):
    """The input bound n <= 4 * 2^K in plain bytes."""
    e = K + 2
    unit = {30: ' (1 GiB)', 29: ' (512 MiB)', 24: ' (16 MiB)', 20: ' (1 MiB)'}.get(e, '')
    return f'n <= 2^{e} bytes{unit}'


def text_vdec(R, X, info):
    vw = VDEC_VIEWS[X]
    K = vdec_k(info)
    alias = {info['dc']: 'DC'}
    for k, a in (('acc', 'DA'), ('spec', 'DS'), ('none', 'DN'), ('rej', 'DR')):
        alias.setdefault(info[k], a)
    body = VDEC_REST
    if info.get('obj') and info['obj'] != info['dc']:
        # the decoded object OBJ is defined in another law module than CHK (e.g. the accept module)
        alias[info['obj']] = alias.get(info['obj'], 'DA')
        body = body.replace('DC.OBJ(', alias[info['obj']] + '.OBJ(')
    if info.get('bf') and info['bf'] != info['dc']:
        # the buffer BF(t, n) is defined in another law module than CHK (a nested name: the child's)
        alias[info['bf']] = alias.get(info['bf'], 'DB')
        body = body.replace('DC.BF(', alias[info['bf']] + '.BF(')
    for op, k in (('decode_accept', 'acc'), ('decode_spec', 'spec'), ('decode_none', 'none'), ('decode_reject', 'rej')):
        body = body.replace(('DR.' if k in ('none', 'rej') else 'DC.') + op + '(', alias[info[k]] + '.' + op + '(')
    ot = vw.get('otype', info['otype'])
    body = (body.replace('T.@X@_decode(', info['dfn'] + '(').replace('Maybe<&1, T.@X@>', f'Maybe<&1, {ot}>')
            .replace('E.none_someT(T.@X@,', f'E.none_someT({ot},').replace('Spec.@X@()', f'{info["sch"]}.@X@()'))
    if info['objd']:
        body = body.replace('DC.OBJ(TT(bs, n), n)', 'DC.OBJ(B.capacity(n), TT(bs, n), n)')
    if info['chk1']:
        body = body.replace('DC.CHK(TT(bs, n), n)', 'DC.CHK(n)')
    if info['noneshort']:
        body = re.sub(r'\.decode_none\(B\.capacity\(n\), TT\(bs, n\), n, pfe\(bs, n\), .*, hchk\)\)$', '.decode_none(TT(bs, n), n, hchk))', body, flags=re.M)
    if info['rejhd']:
        body = body.replace('.decode_reject(B.capacity(n), TT(bs, n), n, pfe(bs, n), C.cap_q(',
                            '.decode_reject(B.capacity(n), TT(bs, n), n, pfe(bs, n), FD.nat__le_lt_trans(B.capacity(n), @K@, @BD@, C.cap_le(n, @K@, {==}, hS), {==}), C.cap_q(')
    if info['vald']:
        body = body.replace('DC.VAL(TT(bs, n), n)', 'DC.VAL(B.capacity(n), TT(bs, n), n)')
    if vdec_nmax(info):
        body = (body.replace('hS: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(@K@))) == True{} : Bool}', 'hS: {U32.is_le(n, VB.NMAX()) == True{} : Bool}')
                .replace('FD.nat__le_lt_trans(B.capacity(n), @K@, @BD@, C.cap_le(n, @K@, {==}, hS), {==})', 'FD.nat__le_lt_trans(B.capacity(n), 30n, @BD@, C.capM_le(n, hS), {==})')
                .replace('C.cap_q(n, @K@, {==}, hS)', 'C.capM_q(n, hS)').replace('C.cap_32(n, @K@, {==}, hS)', 'C.capM_32(n, hS)')
                .replace('C.cap_w(bs, n, @K@, hn, {==}, hS)', 'C.capM_w(bs, n, hn, hS)'))
        assert '@K@' not in body, 'NMAX mode: a K-bound left in the template'
    body = (body.replace('@X@', X).replace('@R@', R).replace('@VIEW@', vw['view'])
            .replace('@K@', f'{K}n').replace('@BD@', f'{info["bound"]}n'))
    imps = VDEC_HEAD + vw['imports'] + [f'import ../proofs/obj/{p} as {a}' for p, a in alias.items()]
    if info['sch'] == 'GS':
        imps = imps + ['import ../proofs/obj/generic_specs.bend as GS']
    if vdec_nmax(info):
        imps = imps + [x for x in ['import ../proofs/obj/vbuf.bend as VB'] if x not in imps]
        head = ['# GENERATED by codegen/e2e_bridge.py. Do not edit.',
                f'# {R} (variable size): the object API\'s decoder on a byte list against END_TO_END\'s deserialize,',
                '# (ii) through the view and (iii), for any input the object API accepts: hS, n <= VB.NMAX() (2^32 - 32).',
                '# The buffer is the loader\'s (e2e_load) at the capacity depth (e2e_cap: at most 30, the laws\' d < 31).']
        return '\n'.join(imps) + '\n\n' + '\n'.join(head) + '\n\n' + vw['text'].replace('@BD@', f'{info["bound"]}n') + body
    head = ['# GENERATED by codegen/e2e_bridge.py. Do not edit.',
            f'# {R} (variable size): the object API\'s decoder on a byte list against END_TO_END\'s deserialize,',
            f'# (ii) through the view and (iii), for inputs of {vdec_size(K)}: the premise hS, n <= 4 * 2^{K},',
            f'# K a parameter (the codec laws take buffers of depth below {info["bound"]}; 2^30 bytes is the most any of them',
            f'# covers). The buffer is the loader\'s (e2e_load) at the capacity depth (e2e_cap).']
    return '\n'.join(imps) + '\n\n' + '\n'.join(head) + '\n\n' + vw['text'].replace('@BD@', f'{info["bound"]}n') + body



def ssz_types():
    """{generated or Fulu name: Ty} over the whole API (codegen/fulu.yaml, the generic suite and the
    classes nested in it)."""
    sys.path.insert(0, str(ROOT / 'tools'))
    import schema as SC
    import generic as GN
    tys = dict(SC.load(ROOT / 'codegen/fulu.yaml'))
    for n, t, _ in GN.inventory_all():
        if t is not None:
            tys[n] = t

    def walk(t):
        if t is None:
            return
        if t.kind in ('container', 'pcontainer', 'cunion') and t.name:
            tys.setdefault(t.name, t)
        for _, f in t.fields:
            walk(f)
        walk(t.elem)
    for t in list(tys.values()):
        walk(t)
    return tys


def max_ssz_size(t):
    """The largest SSZ encoding of a type in bytes (None: unbounded, a progressive list inside)."""
    k = t.kind
    if t.fixed():
        return t.fixed_size()
    if k == 'bytelist':
        return t.size
    if k == 'bitlist':
        return t.size // 8 + 1
    if k in ('plist', 'pbits'):
        return None
    if k in ('list', 'vector'):
        e = t.elem
        m = e.fixed_size() if e.fixed() else (None if max_ssz_size(e) is None else 4 + max_ssz_size(e))
        return None if m is None else t.size * m
    if k in ('container', 'pcontainer'):
        ms = [0 if f.fixed() else max_ssz_size(f) for _, f in t.fields]
        return None if None in ms else sum(f.header() for _, f in t.fields) + sum(ms)
    if k == 'cunion':
        ms = [0 if f is None else max_ssz_size(f) for _, f in t.fields]
        return None if None in ms else 1 + max(ms)
    raise SystemExit(f'max_ssz_size: {k}')


def input_bounds(readable, bridged):
    """Per variable-size name with the codec decode laws' interface: the bridge's input bound
    (2^(K+2) bytes), the type's largest SSZ encoding and whether the bound covers it. The object
    API's byte length is a U32, so an encoding of 2^32 bytes or more is out of the API's range
    whatever the bound."""
    inv = {}
    for g, r in readable.items():
        inv.setdefault(r, g)
    tys = ssz_types()
    rows, short = {}, []
    for f in sorted((ROOT / 'proofs/api').glob('*_decode_ssz_proof_generated.bend')):
        R = f.name[:-len('_decode_ssz_proof_generated.bend')]
        mb = re.search(r'__decode_accept__decode_accept\(\+d: Nat, \+t: [^\n]*?\+hd: \{Nat\.is_lt\(d, (\d+)n\)', f.read_text())
        if not mb or inv.get(R) not in tys:
            continue
        info = {'bound': int(mb.group(1))}
        K = vdec_k(info)
        bound = 2 ** 32 - 32 if vdec_nmax(info) else 2 ** (K + 2)
        ibs = 'NMAX = 2^32 - 32 (the object API\'s limit)' if vdec_nmax(info) else f'2^{K + 2}'
        m = max_ssz_size(tys[inv[R]])
        cov = m is not None and m <= bound
        rows[R] = {'generated_name': inv[R], 'depth_bound': info['bound'], 'input_bound': ibs, 'input_bound_bytes': bound,
                   'max_ssz_size': 'unbounded' if m is None else m, 'covered': cov, 'bridged': bridged.get(R)}
        if not cov:
            why = ('unbounded (progressive list)' if m is None else
                   f'{m} bytes, beyond the U32 byte length the API takes' if m >= 2 ** 32 else f'{m} bytes')
            short.append({'name': R, 'input_bound': ibs, 'max_ssz_size': why,
                          'closed_at_depth_29': m is not None and m <= 2 ** 30})
    return rows, short


# ---- variable-size names: (iv) from the root law's representation invariant ----
# The root law (root_types.X_root_correct) and the validity lemma (gvalid_types.X_root_valid) take
# rep_X(o, s); (iv) takes the same premise. The object is rebuilt from rep's witnesses (its fixed
# fields, and each list field's words O.Words{thaw(t), N}) so every use of it is copyable. The rebuild
# is per shape; VROOT_SHAPES names the shape of each bridged name.
def vroot_bytes32_ulist(R, X):
    D = f'T.{X}'
    O1 = f'{D}{{x0, O.Words{{FD.array__thaw(U32, t), N}}}}'
    RX = lambda o: f'D.bytes(Pair.snd({D}, D.Digest, Pair.snd(B.Buf, {D} & D.Digest, T.{X}_hash_tree_root(h, {o}))))'
    G = lambda o: f'{{Some{{{RX(o)}}} == API.hash_tree_root(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'
    case = lambda fields: '\n'.join(f'      ({f}, w{i + 1}) = {"w" if i == 0 else "w" + str(i)}' for i, f in enumerate(fields))
    rb = (f'      rt2(h, o, rep, x0, t, N, Equal.trans({D}, o, {D}{{x0, RT.pj_{X}_1(o)}}, {O1}, eo,\n'
          f'        Equal.cong(O.Words, {D}, z => {D}{{x0, z}}, RT.pj_{X}_1(o), O.Words{{FD.array__thaw(U32, t), N}}, ew)))')
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/fulu_obj.bend as T', 'import ../types/schema.bend as S',
            'import ../spec/fulu_schemas.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            'import ../proofs/obj/root_types.bend as RT', 'import ../proofs/obj/gvalid_types.bend as GV', 'import ./e2e_support.bend as E']
    return '\n'.join(imps) + f"""

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# {R} (variable size): the object API's root is END_TO_END's hash_tree_root, for every object the
# root law represents (rep_{X}: its list field's words in a perfect tree of depth below 32).

def rt1(h: B.Buf, +x0: T.Bytes32, +t: FD.array__Tree<U32>, +N: U32, +rep: RT.rep_{X}({O1}, Spec.{X}())) -> {G(O1)}:
  E.root_legal(Spec.{X}(), RT.v_{X}({O1}), VS.public_sound(Spec.{X}(), {{==}}), {RX(O1)},
    GV.{X}_root_valid({O1}, Spec.{X}(), {{==}}, rep), RT.{X}_root_correct(h, {O1}, Spec.{X}(), {{==}}, rep))

# the object as rep's witnesses name it
def rt2(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), +x0: T.Bytes32, +t: FD.array__Tree<U32>, +N: U32,
    +eo: {{o == {O1} : {D}}}) -> {G('o')}:
  %Equal.sym({D}, o, {O1}, eo) : {G('_')}
  rt1(h, x0, t, N, FD.logic__subst({D}, z => RT.rep_{X}(z, Spec.{X}()), o, {O1}, eo, rep))

# (iv)
def {R}_e2e_root(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}())) -> {G('o')}:
  (+x0, +q0) = rep
  (+eo, +q1) = q0
  (+wf, +q2) = q1
  match wf:
    case Inl{{w}}:
{case(['+t', '+dw', '+N', '+ew'])}
{rb}
    case Inr{{w}}:
{case(['+t', '+dw', '+N', '+q', '+r', '+ew'])}
{rb}
"""


VROOT_SHAPES = {'DataColumnsByRootIdentifier': vroot_bytes32_ulist}


# ---- variable-size names: (i) through the encode laws and the output path (e2e_emit) ----
# The encode laws take the object's list storage at depth dw < 31 (hdw); the root law's invariant gives
# dw < 32, so (i) takes rep and U.sd (the invariant at depth below 31) until the encode laws take dw < 32.
VENC_DC = r'''import Base
import ../END_TO_END.bend as E2E
import ../src/model.bend as API
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/primitive.bend as P
import ../spec/fulu_schemas.bend as Spec
import ../proofs/type_validator_soundness.bend as VS
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../spec/codec.bend as Encoding
import ../proofs/obj/spec_fixed.bend as SF
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/ulist_obj.bend as UL
import ../proofs/obj/root_types.bend as RT
import ../proofs/obj/var_codec_DataColumnsByRootIdentifier_enc.bend as EN
import ../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../types/FuluDataColumnsByRootIdentifier_def_generated.bend as FuluDataColumnsByRootIdentifier_d
import ../types/FuluDataColumnsByRootIdentifier_encode_ssz_generated.bend as FuluDataColumnsByRootIdentifier_e
import ./e2e_support.bend as E
import ./e2e_cap.bend as C
import ./e2e_emit.bend as EM
import ./e2e_ulist.bend as U
import ../proofs/obj/words_obj.bend as WO
import ../proofs/obj/words_spec.bend as WS
import ../proofs/obj/schema_shapes.bend as SH
import ../proofs/obj/dk.bend as DK
import ../spec/primitives.bend as SP

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# @R@ (variable size): the object API's encoder's bytes are END_TO_END's serialize of the object's view,
# for every object the root law represents (rep) whose list storage is at depth below 31 (hs).

def vx(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +t: FD.array__Tree<U32>, +N: U32, +c: Nat, +ecq: {U32.to_nat(U32.shrn(N, 3n)) == c : Nat}) -> {RT.v_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}) == EN.XE(w0, w1, w2, w3, w4, w5, w6, w7, c, FD.array__slots(U32, t)) : S.Value}:
  Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{S.BytesValue{SF.limbs([w0, w1, w2, w3, w4, w5, w6, w7])}, S.Items{z, S.EmptyItems{}}}}, UL.uview(O.Words{FD.array__thaw(U32, t), N}),
    S.Sequence{VSP.uitems(c, FD.array__slots(U32, t))}, U.uvw(t, N, c, ecq))

# the encoder's buffer: its bytes, and within e2e_cap's bounds (36 + N <= 2^11)
def h9(+N: U32, +c: Nat, +ec: {U32.to_nat(N) == VSP.x8(c) : Nat}, +hc: {Nat.is_le(c, 128n) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(EN.SFS(N)), A.quad(FD.spec_common__pow2(9n))) == True{} : Bool}:
  +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, VSP.x8(128n)) == True{} : Bool}, VSP.x8(c), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), VSP.x8(c), ec), VSP.x8_mono(c, 128n, hc))
  +hs = FD.nat__le_trans(Nat.add(36n, U32.to_nat(N)), Nat.add(36n, VSP.x8(128n)), O.pow2n(11n), Order.add_left(36n, U32.to_nat(N), VSP.x8(128n), hN), {==})
  +es = VD.s_add_nat(36, N, 11n, {==}, hs)
  %Equal.sym(Nat, U32.to_nat(U32.add(36, N)), Nat.add(36n, U32.to_nat(N)), es) : {Nat.is_le(_, A.quad(FD.spec_common__pow2(9n))) == True{} : Bool}
  FD.nat__le_trans(Nat.add(36n, U32.to_nat(N)), O.pow2n(11n), A.quad(FD.spec_common__pow2(9n)), hs, {==})

def eby(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +t: FD.array__Tree<U32>, +N: U32, +h: {Nat.is_le(U32.to_nat(EN.SFS(N)), A.quad(FD.spec_common__pow2(9n))) == True{} : Bool})
    -> {E.obytes(B.Buf{FD.array__thaw(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t)), EN.SFS(N)}) == VSP.bt(U32.to_nat(EN.SFS(N)), SF.limbs(FD.array__slots(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t)))) : +List<U32>}:
  EM.ob(EN.DO(N), EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t), EN.SFS(N), EN.pfD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t),
    FD.nat__le_lt_trans(B.capacity(EN.SFS(N)), 9n, 29n, C.cap_le(EN.SFS(N), 9n, {==}, h), {==}), C.cap_q(EN.SFS(N), 9n, {==}, h))

# (i) on an object with its list stored in a perfect tree t of depth dw < 31 holding N = 8c bytes
def a1(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +dw: Nat, +t: FD.array__Tree<U32>, +N: U32, +c: Nat, +pf: {FD.array__perfect(U32, dw, t) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +ec: {U32.to_nat(N) == VSP.x8(c) : Nat}, +hc: {Nat.is_le(c, 128n) == True{} : Bool}, +hroom: {Nat.is_le(Nat.add(VC.NW(N), 0n), FD.spec_common__pow2(dw)) == True{} : Bool},
    +ecq: {U32.to_nat(U32.shrn(N, 3n)) == c : Nat}) -> {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}})))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}})) : Maybe<&2, +List<U32>>}:
  %Equal.sym(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier & B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}), (FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}, B.Buf{FD.array__thaw(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t)), EN.SFS(N)}), EN.encode_eval(w0, w1, w2, w3, w4, w5, w6, w7, dw, t, N, c, pf, hdw, ec, hc, hroom)) :
    {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, _))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}})) : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, E.obytes(B.Buf{FD.array__thaw(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t)), EN.SFS(N)}), VSP.bt(U32.to_nat(EN.SFS(N)), SF.limbs(FD.array__slots(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t)))), eby(w0, w1, w2, w3, w4, w5, w6, w7, t, N, h9(N, c, ec, hc))) :
    {Some{_} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}})) : Maybe<&2, +List<U32>>}
  %Equal.sym(S.Value, RT.v_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}), EN.XE(w0, w1, w2, w3, w4, w5, w6, w7, c, FD.array__slots(U32, t)), vx(w0, w1, w2, w3, w4, w5, w6, w7, t, N, c, ecq)) :
    {Some{VSP.bt(U32.to_nat(EN.SFS(N)), SF.limbs(FD.array__slots(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t))))} == API.serialize(Spec.DataColumnsByRootIdentifier(), _) : Maybe<&2, +List<U32>>}
  Equal.sym(Maybe<&2, +List<U32>>, API.serialize(Spec.DataColumnsByRootIdentifier(), EN.XE(w0, w1, w2, w3, w4, w5, w6, w7, c, FD.array__slots(U32, t))), Some{VSP.bt(U32.to_nat(EN.SFS(N)), SF.limbs(FD.array__slots(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t))))},
    Equal.trans(Maybe<&2, +List<U32>>, API.serialize(Spec.DataColumnsByRootIdentifier(), EN.XE(w0, w1, w2, w3, w4, w5, w6, w7, c, FD.array__slots(U32, t))), Encoding.encoding_for_legal_type(Spec.DataColumnsByRootIdentifier(), EN.XE(w0, w1, w2, w3, w4, w5, w6, w7, c, FD.array__slots(U32, t))), Some{VSP.bt(U32.to_nat(EN.SFS(N)), SF.limbs(FD.array__slots(U32, EN.TD1(w0, w1, w2, w3, w4, w5, w6, w7, N, t))))},
      E.serialize_legal(Spec.DataColumnsByRootIdentifier(), EN.XE(w0, w1, w2, w3, w4, w5, w6, w7, c, FD.array__slots(U32, t)), VS.public_sound(Spec.DataColumnsByRootIdentifier(), {==})),
      EN.encode_spec(w0, w1, w2, w3, w4, w5, w6, w7, dw, t, N, c, pf, hdw, ec, hc, hroom)))

# ---- (i) from the representation ----

def e2(-o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +eo: {o == FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, RT.pj_DataColumnsByRootIdentifier_1(o)} : FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier},
    +elen: {U32.to_nat(WO.len(RT.pj_DataColumnsByRootIdentifier_1(o))) == O.e8(UL.ucnt(RT.pj_DataColumnsByRootIdentifier_1(o))) : Nat}, +hlim: {Nat.is_le(UL.ucnt(RT.pj_DataColumnsByRootIdentifier_1(o)), SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.Container_fields(Spec.DataColumnsByRootIdentifier()))))) == True{} : Bool}, +hs: U.sd(RT.pj_DataColumnsByRootIdentifier_1(o))) -> {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(o)))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(o)) : Maybe<&2, +List<U32>>}:
  match hs:
    case Inl{s}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+ew, s4) = s3
      (+pf, s5) = s4
      (+hdw, +en0) = s5
      +c = U32.to_nat(U32.shrn(N, 3n))
      +el = FD.logic__subst(O.Words, z => {U32.to_nat(WO.len(z)) == O.e8(UL.ucnt(z)) : Nat}, RT.pj_DataColumnsByRootIdentifier_1(o), O.Words{FD.array__thaw(U32, t), N}, ew, elen)
      +ec = Equal.trans(Nat, U32.to_nat(N), O.e8(c), VSP.x8(c), el, Equal.sym(Nat, VSP.x8(c), O.e8(c), U.x8e(c)))
      +hc = FD.logic__subst(O.Words, z => {Nat.is_le(UL.ucnt(z), SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.Container_fields(Spec.DataColumnsByRootIdentifier()))))) == True{} : Bool}, RT.pj_DataColumnsByRootIdentifier_1(o), O.Words{FD.array__thaw(U32, t), N}, ew, hlim)
      +hN8 = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(FD.spec_common__pow2(8n))) == True{} : Bool}, VSP.x8(c), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), VSP.x8(c), ec), VSP.x8_mono(c, 128n, hc))
      +enw = Equal.trans(Nat, Nat.add(VC.NW(N), 0n), VC.NW(N), C.nwn(U32.to_nat(N)), FD.nat__add_zero(VC.NW(N)), C.nw(N, 8n, {==}, hN8))
      +hroom = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dw)) == True{} : Bool}, 0n, Nat.add(VC.NW(N), 0n),
        Equal.sym(Nat, Nat.add(VC.NW(N), 0n), 0n, Equal.trans(Nat, Nat.add(VC.NW(N), 0n), C.nwn(U32.to_nat(N)), 0n, enw, Equal.cong(Nat, Nat, z => C.nwn(z), U32.to_nat(N), 0n, en0))),
        Order.zero_le(FD.spec_common__pow2(dw)))
      %Equal.sym(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, o, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}, Equal.trans(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, o, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, RT.pj_DataColumnsByRootIdentifier_1(o)}, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}, eo, Equal.cong(O.Words, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, z => FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, z}, RT.pj_DataColumnsByRootIdentifier_1(o), O.Words{FD.array__thaw(U32, t), N}, ew))) : {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(_)))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(_)) : Maybe<&2, +List<U32>>}
      a1(w0, w1, w2, w3, w4, w5, w6, w7, dw, t, N, c, pf, hdw, ec, hc, hroom, {==})
    case Inr{s}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+q, s4) = s3
      (+r, s5) = s4
      (+ew, s6) = s5
      (+pf, s7) = s6
      (+hdw, s8) = s7
      (+eN, s9) = s8
      (+hr0, s10) = s9
      (+hr32, s11) = s10
      (+hcap, +bz) = s11
      +c = U32.to_nat(U32.shrn(N, 3n))
      +el = FD.logic__subst(O.Words, z => {U32.to_nat(WO.len(z)) == O.e8(UL.ucnt(z)) : Nat}, RT.pj_DataColumnsByRootIdentifier_1(o), O.Words{FD.array__thaw(U32, t), N}, ew, elen)
      +ec = Equal.trans(Nat, U32.to_nat(N), O.e8(c), VSP.x8(c), el, Equal.sym(Nat, VSP.x8(c), O.e8(c), U.x8e(c)))
      +hc = FD.logic__subst(O.Words, z => {Nat.is_le(UL.ucnt(z), SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.Container_fields(Spec.DataColumnsByRootIdentifier()))))) == True{} : Bool}, RT.pj_DataColumnsByRootIdentifier_1(o), O.Words{FD.array__thaw(U32, t), N}, ew, hlim)
      +hN8 = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(FD.spec_common__pow2(8n))) == True{} : Bool}, VSP.x8(c), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), VSP.x8(c), ec), VSP.x8_mono(c, 128n, hc))
      +enw = Equal.trans(Nat, Nat.add(VC.NW(N), 0n), VC.NW(N), C.nwn(U32.to_nat(N)), FD.nat__add_zero(VC.NW(N)), C.nw(N, 8n, {==}, hN8))
      +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(O.e8(1n+q))) == True{} : Bool}, Nat.add(r, WS.e32(q)), U32.to_nat(N),
        Equal.sym(Nat, U32.to_nat(N), Nat.add(r, WS.e32(q)), Equal.trans(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), Nat.add(r, WS.e32(q)), eN, FD.nat__add_comm(WS.e32(q), r))),
        Order.add_right(r, 32n, WS.e32(q), hr32))
      +hroom = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dw)) == True{} : Bool}, C.nwn(U32.to_nat(N)), Nat.add(VC.NW(N), 0n),
        Equal.sym(Nat, Nat.add(VC.NW(N), 0n), C.nwn(U32.to_nat(N)), enw),
        FD.nat__le_trans(C.nwn(U32.to_nat(N)), O.e8(1n+q), FD.spec_common__pow2(dw), C.nle(U32.to_nat(N), O.e8(1n+q), hq), hcap))
      %Equal.sym(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, o, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}, Equal.trans(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, o, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, RT.pj_DataColumnsByRootIdentifier_1(o)}, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, O.Words{FD.array__thaw(U32, t), N}}, eo, Equal.cong(O.Words, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, z => FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{FuluBytes32_d.Bytes32{w0, w1, w2, w3, w4, w5, w6, w7}, z}, RT.pj_DataColumnsByRootIdentifier_1(o), O.Words{FD.array__thaw(U32, t), N}, ew))) : {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(_)))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(_)) : Maybe<&2, +List<U32>>}
      a1(w0, w1, w2, w3, w4, w5, w6, w7, dw, t, N, c, pf, hdw, ec, hc, hroom, {==})

def e1(-o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, +x0: FuluBytes32_d.Bytes32, +eo: {o == FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{x0, RT.pj_DataColumnsByRootIdentifier_1(o)} : FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier},
    +elen: {U32.to_nat(WO.len(RT.pj_DataColumnsByRootIdentifier_1(o))) == O.e8(UL.ucnt(RT.pj_DataColumnsByRootIdentifier_1(o))) : Nat}, +hlim: {Nat.is_le(UL.ucnt(RT.pj_DataColumnsByRootIdentifier_1(o)), SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.Container_fields(Spec.DataColumnsByRootIdentifier()))))) == True{} : Bool}, +hs: U.sd(RT.pj_DataColumnsByRootIdentifier_1(o))) -> {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(o)))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(o)) : Maybe<&2, +List<U32>>}:
  match x0:
    case FuluBytes32_d.Bytes32{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: e2(o, w0, w1, w2, w3, w4, w5, w6, w7, eo, elen, hlim, hs)

# (i): for every object the root law represents, its list field stored at depth below 31 (hs)
def FuluDataColumnsByRootIdentifier_e2e_encode(-o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, +rep: RT.rep_DataColumnsByRootIdentifier(o, Spec.DataColumnsByRootIdentifier()), +hs: U.sd(RT.pj_DataColumnsByRootIdentifier_1(o))) -> {Some{E.obytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, B.Buf, FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_encode(o)))} == API.serialize(Spec.DataColumnsByRootIdentifier(), RT.v_DataColumnsByRootIdentifier(o)) : Maybe<&2, +List<U32>>}:
  (+x0, +q0) = rep
  (+eo, +q1) = q0
  (+wf, +q2) = q1
  (+elen, +hlim) = q2
  e1(o, x0, eo, elen, hlim, hs)
'''


def venc_dc(R, X):
    return VENC_DC.replace('FuluDataColumnsByRootIdentifier', R).replace('DataColumnsByRootIdentifier', X).replace('@R@', R)


VENC_SHAPES = {'DataColumnsByRootIdentifier': venc_dc}

import e2e_var_b as EVB  # noqa: E402  (the second variable-size worker's entries)
import e2e_var_c as EVC  # noqa: E402  (the third's: u-lists and unions)
import e2e_fix_d as EFD  # noqa: E402  (the fourth's: fixed-size leftovers)
import e2e_bview_gen as BVG  # noqa: E402  (the bit-list view module and the bit lists' view lemmas)
for _m in (EVB, EVC, EFD):
    for _k, _v in _m.VDEC_VIEWS.items():
        VDEC_VIEWS.setdefault(_k, _v)
    for _k, _v in _m.VROOT_SHAPES.items():
        VROOT_SHAPES.setdefault(_k, _v)
    for _k, _v in _m.VENC_SHAPES.items():
        VENC_SHAPES.setdefault(_k, _v)
VENC_PREMISE = dict(EVB.VENC_PREMISE, **EVC.VENC_PREMISE)



# ---- bit lists (O.Bits): (i) through the encode laws, (iv) from rep_bits ----
BITL = r'''import Base
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vbitenc.bend as VBT
import ../proofs/obj/vbitdl.bend as DL
import ../proofs/obj/vbitcore.bend as CO
import ../proofs/obj/dk.bend as DK
import ./e2e_cap.bend as C

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# Bit lists (O.Bits): the premise of (i) (sdb: the object's words in a perfect tree of depth below 31,
# as the encode laws take them), the encoder's output tree is perfect (pf_oz), and its byte count
# K / 8 + 1 is at most N / 8 + 1 for K <= N (nkb).

def sdb(o: O.Bits) -> Data:
  DK.Ex(FD.array__Tree<U32>, T => DK.Ex(Nat, dw => DK.Ex(U32, K =>
    DK.P2({o == O.Bits{FD.array__thaw(U32, T), K} : O.Bits},
    DK.P2({FD.array__perfect(U32, dw, T) == True{} : Bool},
          {Nat.is_lt(dw, 31n) == True{} : Bool})))))

# the same with the room the larger bit lists' encode laws take: (K >> 5) + 1 words
def sdbc(o: O.Bits) -> Data:
  DK.Ex(FD.array__Tree<U32>, T => DK.Ex(Nat, dw => DK.Ex(U32, K =>
    DK.P2({o == O.Bits{FD.array__thaw(U32, T), K} : O.Bits},
    DK.P2({FD.array__perfect(U32, dw, T) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 31n) == True{} : Bool},
          {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool}))))))

def pf_oz(+dd: Nat, +T: FD.array__Tree<U32>, +K: U32) -> {FD.array__perfect(U32, dd, DL.OZ(dd, T, K)) == True{} : Bool}:
  +M = VBT.MT(dd, VC.ZT(dd), T, 0n, K)
  FD.array__upd_perfect(U32, dd, M, VBT.QK(K), U32.or(VB.slot(M, VBT.QK(K)), VBT.DMK(0, K)),
    VB.mone_perfect(VC.NW(O.bits_nbytes(K)), 0n, 0n, dd, VC.ZT(dd), T, FD.array__trep_perfect(U32, dd, 0)))

def nkb(+K: U32, +N: Nat, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(CO.NK(K)), Nat.add(VD.s_rng(3n, N), 1n)) == True{} : Bool}:
  +hK = FD.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  %Equal.sym(Nat, U32.to_nat(CO.NK(K)), Nat.add(VBT.AK(K), 1n), VBT.E4(K, kb, hkb, hK)) : {Nat.is_le(_, Nat.add(VD.s_rng(3n, N), 1n)) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(U32.shrn(K, 3n)), VD.s_rng(3n, U32.to_nat(K)), VD.shrk(3n, K)) : {Nat.is_le(Nat.add(_, 1n), Nat.add(VD.s_rng(3n, N), 1n)) == True{} : Bool}
  Order.add_right(VD.s_rng(3n, U32.to_nat(K)), VD.s_rng(3n, N), 1n, C.rgm(3n, U32.to_nat(K), N, hN))
'''.replace('import ./e2e_cap.bend as C', 'import ./e2e_cap.bend as C\nimport ../proofs/nat_order.bend as Order')


def benc(R, X, N, big):
    """(i) for a bit list R (generated name X, limit N); big: the output tree at depth DOK(K), else 0."""
    kb = max(5, (N + 8).bit_length())          # N + 8 <= 2^kb
    nb = N // 8 + 1                            # the byte count bound s_rng(3, N) + 1
    if big:
        kc = 0
        while 4 * 2 ** kc < nb:
            kc += 1
        dd = 'CO.DOK(K)'
        HQ = f'FD.nat__le_trans(U32.to_nat(CO.NK(K)), Nat.add(VD.s_rng(3n, {N}n), 1n), A.quad(FD.spec_common__pow2({kc}n)), BL.nkb(K, {N}n, {kb}n, {{==}}, hN, {{==}}), {{==}})'
        HD = f'FD.nat__le_lt_trans(B.capacity(CO.NK(K)), {kc}n, 29n, C.cap_le(CO.NK(K), {kc}n, {{==}}, hq), {{==}})'
        HN = f'C.cap_q(CO.NK(K), {kc}n, {{==}}, hq)'
    else:
        assert nb <= 4
        dd = '0n'
        HQ = f'FD.nat__le_trans(U32.to_nat(CO.NK(K)), Nat.add(VD.s_rng(3n, {N}n), 1n), A.quad(FD.spec_common__pow2(0n)), BL.nkb(K, {N}n, {kb}n, {{==}}, hN, {{==}}), {{==}})'
        HD = '{==}'
        HN = 'hq'
    O1 = 'O.Bits{FD.array__thaw(U32, T), K}'
    CAPP = ', +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), FD.spec_common__pow2(dw)) == True{} : Bool}' if big else ''
    CAPA = ', hcap' if big else ''
    SD = 'sdbc' if big else 'sdb'
    UNP = ('  (+pf, s5) = s4\n  (+hdw, +hcap) = s5' if big else '  (+pf, +hdw) = s4')
    MB = 'Maybe<&2, +List<U32>>'
    G = lambda o: f'{{Some{{E.obytes(Pair.snd(O.Bits, B.Buf, {R}_e.{X}_encode({o})))}} == API.serialize(GS.{X}(), S.BitsValue{{BOr.bview({o})}}) : {MB}}}'
    BUF = f'B.Buf{{FD.array__thaw(U32, EN.OUT(T, K)), CO.NK(K)}}'
    return f'''import Base
import ../END_TO_END.bend as E2E
import ../src/model.bend as API
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../spec/codec.bend as Encoding
import ../proofs/type_validator_soundness.bend as VS
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/generic_specs.bend as GS
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vbitcore.bend as CO
import ../proofs/obj/vbitrep.bend as VR
import ../proofs/obj/bitlist_rep.bend as BOr
import ../proofs/obj/var_bits_enc_{X}.bend as EN
import ../types/{R}_encode_ssz_generated.bend as {R}_e
import ./e2e_support.bend as E
import ./e2e_cap.bend as C
import ./e2e_emit.bend as EM
import ./e2e_bitl.bend as BL

# GENERATED by codegen/e2e_bridge.py. Do not edit.
# {R} (bit list, limit {N}): the object API's encoder's bytes are END_TO_END's serialize of the object's
# view (bitlist_rep.bview, the root laws' bitlist_obj.bview verbatim), for every object the root law
# represents (rep) whose words are in a perfect tree of depth below 31 (hs, BL.sdb).

def ob(+T: FD.array__Tree<U32>, +K: U32, +hN: {{Nat.is_le(U32.to_nat(K), {N}n) == True{{}} : Bool}}) -> {{E.obytes({BUF}) == EN.BY(T, K) : +List<U32>}}:
  +hq = {HQ}
  EM.ob({dd}, EN.OUT(T, K), CO.NK(K), BL.pf_oz({dd}, T, K), {HD}, {HN})

def a1(+dw: Nat, +T: FD.array__Tree<U32>, +K: U32, +pf: {{FD.array__perfect(U32, dw, T) == True{{}} : Bool}}, +hdw: {{Nat.is_lt(dw, 31n) == True{{}} : Bool}},
    +rep: BOr.rep_bits({O1}, GS.{X}()){CAPP}) -> {G(O1)}:
  %Equal.sym(O.Bits & B.Buf, {R}_e.{X}_encode({O1}), ({O1}, {BUF}), EN.encode_eval(dw, T, K, pf, hdw, rep{CAPA})) :
    {{Some{{E.obytes(Pair.snd(O.Bits, B.Buf, _))}} == API.serialize(GS.{X}(), S.BitsValue{{BOr.bview({O1})}}) : {MB}}}
  %Equal.sym(+List<U32>, E.obytes({BUF}), EN.BY(T, K), ob(T, K, VR.rep_N(T, K, {N}n, rep))) :
    {{Some{{_}} == API.serialize(GS.{X}(), S.BitsValue{{BOr.bview({O1})}}) : {MB}}}
  Equal.sym({MB}, API.serialize(GS.{X}(), EN.VAL(T, K)), Some{{EN.BY(T, K)}},
    Equal.trans({MB}, API.serialize(GS.{X}(), EN.VAL(T, K)), Encoding.encoding_for_legal_type(GS.{X}(), EN.VAL(T, K)), Some{{EN.BY(T, K)}},
      E.serialize_legal(GS.{X}(), EN.VAL(T, K), VS.public_sound(GS.{X}(), {{==}})), EN.encode_spec(dw, T, K, pf, hdw, rep{CAPA})))

# (i)
def {R}_e2e_encode(-o: O.Bits, +rep: BOr.rep_bits(o, GS.{X}()), +hs: BL.{SD}(o)) -> {G('o')}:
  (+T, s1) = hs
  (+dw, s2) = s1
  (+K, s3) = s2
  (+eo, s4) = s3
{UNP}
  %Equal.sym(O.Bits, o, {O1}, eo) : {G('_')}
  a1(dw, T, K, pf, hdw, FD.logic__subst(O.Bits, z => BOr.rep_bits(z, GS.{X}()), o, {O1}, eo, rep){CAPA})
'''



def broot_batch(rows):
    """(iv) for bit lists: rows of (R, X)."""
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S',
            'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            'import ../proofs/obj/generic_specs.bend as GS', 'import ../proofs/obj/bitlist_obj.bend as BO',
            'import ../proofs/obj/root_gtypes.bend as RG', 'import ../proofs/obj/gvalid_gpacked.bend as GV', 'import ./e2e_support.bend as E']
    imps += [f'import ../types/{R}_hashtreeroot_generated.bend as {R}_h' for R, X in rows]
    out = ['\n'.join(imps), '',
           '# GENERATED by codegen/e2e_bridge.py. Do not edit.',
           f'# {rows[0][0]} and the next bit lists: the object API\'s root is END_TO_END\'s hash_tree_root, for every object',
           '# the root law represents (rep_bits: an empty list, or its words in a perfect tree of depth below 32).', '']
    O1 = 'O.Bits{FD.array__thaw(U32, t), K}'
    for R, X in rows:
        RX = lambda o: f'D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, {R}_h.{X}_hash_tree_root(h, {o}))))'
        G = lambda o: f'{{Some{{{RX(o)}}} == API.hash_tree_root(GS.{X}(), S.BitsValue{{BO.bview({o})}}) : Maybe<&2, +List<U32>>}}'
        cs = lambda n: '\n'.join(f'      ({v}, w{i + 1}) = {"w" if i == 0 else "w" + str(i)}' for i, v in enumerate(n))
        out.append(f"""# {R} ({X})
def {R}_rt1(h: B.Buf, +t: FD.array__Tree<U32>, +K: U32, +rep: BO.rep_bits({O1}, GS.{X}())) -> {G(O1)}:
  E.root_legal(GS.{X}(), S.BitsValue{{BO.bview({O1})}}, VS.public_sound(GS.{X}(), {{==}}), {RX(O1)},
    GV.{X}_root_valid({O1}, GS.{X}(), {{==}}, rep), RG.{X}_root_correct(h, {O1}, GS.{X}(), {{==}}, rep))

def {R}_rt2(h: B.Buf, -o: O.Bits, +rep: BO.rep_bits(o, GS.{X}()), +t: FD.array__Tree<U32>, +K: U32, +eo: {{o == {O1} : O.Bits}}) -> {G('o')}:
  %Equal.sym(O.Bits, o, {O1}, eo) : {G('_')}
  {R}_rt1(h, t, K, FD.logic__subst(O.Bits, z => BO.rep_bits(z, GS.{X}()), o, {O1}, eo, rep))

# (iv)
def {R}_e2e_root(h: B.Buf, -o: O.Bits, +rep: BO.rep_bits(o, GS.{X}())) -> {G('o')}:
  (+wf, +q0) = rep
  match wf:
    case Inl{{w}}:
{cs(['+t', '+dw', '+K', '+eo'])}
      {R}_rt2(h, o, rep, t, K, eo)
    case Inr{{w}}:
{cs(['+t', '+dw', '+K', '+q', '+r', '+eo'])}
      {R}_rt2(h, o, rep, t, K, eo)
""")
    return '\n'.join(out)


def bit_lists(amap_map):
    """The generic bit lists with the codec laws' interface: [(R, X, limit, big)] from the encode modules."""
    rows = []
    for f in sorted(OBJ.glob('var_bits_enc_Gt*.bend')):
        X = f.stem[len('var_bits_enc_'):]
        s = f.read_text()
        ml = re.search(r'rep_N\(T, K, (\d+)n', s)
        mo = re.search(r'def OUT\(.*DL\.OZ\(([^,]+),', s)
        if ml and mo:
            rows.append((X, int(ml.group(1)), mo.group(1) != '0n'))
    return rows

def outputs():
    # the generic bit lists' decode view lemmas (e2e_bview)
    for X0, N0, big0 in bit_lists(None):
        if (OBJ / f'var_bits_{X0}.bend').exists():
            VDEC_VIEWS.setdefault(X0, BVG.bl_view(X0, *BVG.bl_params(OBJ, X0)))
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
        r['generic'] = RR.runtime_of((OBJ / r['ee']['file']).read_text()) == 'generic'
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
           OUT / 'e2e_bits.bend': BITS, OUT / 'e2e_tree.bend': TREE, OUT / 'e2e_load.bend': LOAD,
           OUT / 'e2e_cap.bend': CAP, OUT / 'e2e_ulist.bend': ULIST, OUT / 'e2e_emit.bend': emit_text()}
    for _f, _txt in list(EVB.SUPPORT_OUT.items()) + list(EVC.SUPPORT_OUT.items()):
        out[OUT / _f] = _txt
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
        gen = RR.runtime_of((OBJ / a['file']).read_text()) == 'generic'
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
    for R0, u in sorted(uncovered.items()):
        X0 = u['generated_name']
        info = vdec_info(R0) if X0 in VDEC_VIEWS else None
        if not info:
            continue
        fn = f'{R0}_e2e_dec_generated.bend'
        out[OUT / fn] = text_vdec(R0, X0, info)
        man['files'][fn] = [{'name': R0, 'generated_name': X0, 'laws': [f'{R0}_e2e_decode_view', f'{R0}_e2e_decode_reject'], 'ii': 'view',
                             'premise': ('any input the object API accepts (hS: n <= VB.NMAX() = 2^32 - 32)' if vdec_nmax(info) else
                                         f'{vdec_size(vdec_k(info))} (hS: n <= 4 * 2^K with K = {vdec_k(info)}, a parameter; the codec laws take buffers of depth below {info["bound"]})')}]
        u['decode'] = fn
    for R0, u in sorted(uncovered.items()):
        X0 = u['generated_name']
        if X0 not in VROOT_SHAPES:
            continue
        fn = f'{R0}_e2e_root_generated.bend'
        out[OUT / fn] = VROOT_SHAPES[X0](R0, X0)
        man['files'][fn] = [{'name': R0, 'generated_name': X0, 'laws': [f'{R0}_e2e_root'],
                             'premise': f'rep: RT.rep_{X0}(o, Spec.{X0}()) (the root law\'s representation invariant)'}]
        u['root'] = fn
    for R0, u in sorted(uncovered.items()):
        X0 = u['generated_name']
        if X0 not in VENC_SHAPES:
            continue
        fn = f'{R0}_e2e_generated.bend'
        out[OUT / fn] = VENC_SHAPES[X0](R0, X0)
        man['files'][fn] = [{'name': R0, 'generated_name': X0, 'laws': [f'{R0}_e2e_encode'],
                             'premise': VENC_PREMISE.get(X0, f'rep: RT.rep_{X0}(o, Spec.{X0}()) and hs: U.sd(list field) (its storage at depth below 31: the encode laws take dw < 31, the root law dw < 32; dropped when the encode laws take dw < 32)')}]
        u['encode'] = fn
    out[OUT / 'e2e_bitl.bend'] = BITL
    out[OUT / 'e2e_bview.bend'] = BVG.text()
    inv = {u['generated_name']: R0 for R0, u in uncovered.items()}
    brows = [(inv[X], X, N, big) for X, N, big in bit_lists(amap['map']) if X in inv]
    for R0, X0, N, big in brows:
        fn = f'{R0}_e2e_generated.bend'
        out[OUT / fn] = benc(R0, X0, N, big)
        man['files'][fn] = [{'name': R0, 'generated_name': X0, 'laws': [f'{R0}_e2e_encode'],
                             'premise': ('rep: bitlist_rep.rep_bits(o, GS.X()) and hs: e2e_bitl.' + ('sdbc' if big else 'sdb') +
                                         '(o) (its words at depth below 31' + (', with room for (K >> 5) + 1 words' if big else '') +
                                         ': the encode laws take these, the root law dw < 32)')}]
        uncovered[R0]['encode'] = fn
    for i in range(0, len(brows), WRBATCH):
        rows = [(R0, X0) for R0, X0, N, big in brows[i:i + WRBATCH]]
        fn = f'{rows[0][0]}_e2e_root_generated.bend'
        out[OUT / fn] = broot_batch(rows)
        man['files'][fn] = [{'name': R0, 'generated_name': X0, 'laws': [f'{R0}_e2e_root'], 'premise': 'rep: bitlist_obj.rep_bits(o, GS.X())'} for R0, X0 in rows]
        for R0, X0 in rows:
            uncovered[R0]['root'] = fn
    fd = EFD.build(sys.modules[__name__], amap, cache, vidx)
    for _f, _txt in list(fd['support'].items()) + list(fd['files'].items()):
        out[OUT / _f] = _txt
    inv = {u['generated_name']: R0 for R0, u in uncovered.items()}
    man['fixed_size'] = {}
    for X0, cv in sorted(fd['cover'].items()):
        R0 = inv.get(X0)
        if R0 is None:
            continue
        laws = {'i': [f'{R0}_e2e_encode'], 'iv': [f'{R0}_e2e_root'],
                'ii_iii': [f'{R0}_e2e_decode_view' if cv.get('ii') == 'view' else f'{R0}_e2e_decode_accept', f'{R0}_e2e_decode_reject']}
        for k in ('i', 'ii_iii', 'iv'):
            if k in cv:
                e = {'name': R0, 'generated_name': X0, 'laws': laws[k]}
                if k == 'ii_iii':
                    e['ii'] = cv.get('ii', 'exact')
                if cv.get('premise'):
                    e['premise'] = cv['premise']
                man['files'].setdefault(cv[k], []).append(e)
        if all(k in cv for k in ('i', 'ii_iii', 'iv')):
            man['fixed_size'][R0] = {'generated_name': X0, 'i': cv['i'], 'ii_iii': cv['ii_iii'], 'iv': cv['iv']}
            del uncovered[R0]
        else:
            uncovered[R0].update({k: cv[k] for k in ('i', 'ii_iii', 'iv') if k in cv})
    man['variable_size'] = {}
    for R0 in sorted(uncovered):
        u = uncovered[R0]
        if all(k in u for k in ('encode', 'decode', 'root')):
            man['variable_size'][R0] = {'generated_name': u['generated_name'], 'i': u['encode'], 'ii_iii': u['decode'], 'iv': u['root']}
            del uncovered[R0]
    ib, ibs = input_bounds(readable, {R0: u['decode'] for R0, u in uncovered.items() if 'decode' in u})
    man['input_bounds'] = ib
    man['input_bound_short'] = ibs
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
    out = RR.rewire_out(out)
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
