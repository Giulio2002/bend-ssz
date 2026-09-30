import Base
import ../proofs/word_split.bend as WSp
import ../proofs/word_facts.bend as W
import ../src/model.bend as API
import ../types/schema.bend as S
import ../spec/bytes.bend as Bytes
import ../spec/primitives.bend as SP
import ../spec/schema.bend as SS
import ../spec/codec.bend as Encoding
import ../spec/fulu_schemas.bend as Spec
import ../proofs/type_validator_soundness.bend as VS
import ./e2e_support.bend as E

# What the generated validity predicates (types/<X>_encode_ssz_generated.bend, X_valid) say, in the
# forms the e2e bridges take as premises (e2e/<Name>_e2e_generated.bend). Used by
# e2e/<Name>_e2e_ser_generated.bend (codegen/serialize_e2e.py).

# x <= 2^n - 1 gives x < 2^n (the uint8 / uint16 domains: u8_valid is is_le(o, 255), rp_u8 is is_lt(o, 256)), on the
# words: the checker never turns the constants into unary numbers
def le_tail(+c: Cmp, +b: Bool, +e: {Cmp.is_le(Word.cmp.fin(b, True{}, c)) == True{} : Bool}) -> {Cmp.is_le(c) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: e

def lt_fin(+c: Cmp, +b: Bool, +h: {Cmp.is_lt(c) == True{} : Bool}) -> {Cmp.is_lt(Word.cmp.fin(b, False{}, c)) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}:
      match b:
        case False{}: h
        case True{}: h
    case GT{}: h

def le_lt0(+c: Cmp, +b: Bool, +e: {Cmp.is_le(Word.cmp.fin(b, False{}, c)) == True{} : Bool}) -> {Cmp.is_lt(Word.cmp.fin(b, True{}, c)) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}:
      match b:
        case False{}: {==}
        case True{}: e
    case GT{}: e

def le_lt(+n: Nat, +m: Nat, +w: Word(Nat.add(n, 1n+m)),
    +e: {Cmp.is_le(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, WSp.ones(n), Word.zero(1n+m)))) == True{} : Bool})
    -> {Cmp.is_lt(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, Word.zero(n), WCon{True{}, Word.zero(m)}))) == True{} : Bool}:
  match n:
    case 0n:
      match w:
        case WCon{b, t}: le_lt0(Word.cmp(m, t, Word.zero(m)), b, e)
    case 1n+p:
      match w:
        case WCon{b, t}:
          lt_fin(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, Word.zero(p), WCon{True{}, Word.zero(m)})), b,
            le_lt(p, m, t, le_tail(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, WSp.ones(p), Word.zero(1n+m))), b, e)))

# a little-endian word below 2^n (as the word 0..0 1 0..0, n zeros first) has its high m + 1 bits zero, so it is the join
# of its n low bits with zeros: the shape the bit-vector bridges take as premise
def shz(+n: Nat, +m: Nat, +w: Word(Nat.add(n, 1n+m)),
    +e: {Cmp.is_lt(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, Word.zero(n), WCon{True{}, Word.zero(m)}))) == True{} : Bool})
    -> {w == WSp.join(n, 1n+m, WSp.take(n, Nat.add(n, 1n+m), w), Word.zero(1n+m)) : Word(Nat.add(n, 1n+m))}:
  match n:
    case 0n: WSp.below_one(m, w, e)
    case 1n+p:
      match w:
        case WCon{b, t}:
          Equal.cong(Word(Nat.add(p, 1n+m)), Word(Nat.add(1n+p, 1n+m)), z => WCon{b, z}, t,
            WSp.join(p, 1n+m, WSp.take(p, Nat.add(p, 1n+m), t), Word.zero(1n+m)),
            shz(p, m, t, WSp.lt_tail(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, Word.zero(p), WCon{True{}, Word.zero(m)})), b, e)))

# ---- the converses: the bridges' premise shapes give validity ----
def le_fin(+c: Cmp, +b: Bool, +h: {Cmp.is_le(c) == True{} : Bool}) -> {Cmp.is_le(Word.cmp.fin(b, True{}, c)) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}:
      match b:
        case False{}: {==}
        case True{}: {==}
    case GT{}: h

def lt_le0(+c: Cmp, +b: Bool, +e: {Cmp.is_lt(Word.cmp.fin(b, True{}, c)) == True{} : Bool}) -> {Cmp.is_le(Word.cmp.fin(b, False{}, c)) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}:
      match b:
        case False{}: {==}
        case True{}: e
    case GT{}: e

# below 2^n (the word 0..0 1 0..0) gives at most 2^n - 1 (ones, then zeros)
def lt_le(+n: Nat, +m: Nat, +w: Word(Nat.add(n, 1n+m)),
    +e: {Cmp.is_lt(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, Word.zero(n), WCon{True{}, Word.zero(m)}))) == True{} : Bool})
    -> {Cmp.is_le(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, WSp.ones(n), Word.zero(1n+m)))) == True{} : Bool}:
  match n:
    case 0n:
      match w:
        case WCon{b, t}: lt_le0(Word.cmp(m, t, Word.zero(m)), b, e)
    case 1n+p:
      match w:
        case WCon{b, t}:
          le_fin(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, WSp.ones(p), Word.zero(1n+m))), b,
            lt_le(p, m, t, WSp.lt_tail(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, Word.zero(p), WCon{True{}, Word.zero(m)})), b, e)))

def lt_sh0(+m: Nat) -> {Cmp.is_lt(Word.cmp(1n+m, Word.zero(1n+m), WCon{True{}, Word.zero(m)})) == True{} : Bool}:
  %Equal.sym(Cmp, Word.cmp(m, Word.zero(m), Word.zero(m)), EQ{}, W.word_compare_reflexive(m, Word.zero(m))) : {Cmp.is_lt(Word.cmp.fin(False{}, True{}, _)) == True{} : Bool}
  {==}

# a word of n low bits and zeros above is below 2^n
def lt_sh(+n: Nat, +m: Nat, +X: Word(n))
    -> {Cmp.is_lt(Word.cmp(Nat.add(n, 1n+m), WSp.join(n, 1n+m, X, Word.zero(1n+m)), WSp.join(n, 1n+m, Word.zero(n), WCon{True{}, Word.zero(m)}))) == True{} : Bool}:
  match n:
    case 0n: lt_sh0(m)
    case 1n+p:
      match X:
        case WCon{b, t}: lt_fin(Word.cmp(Nat.add(p, 1n+m), WSp.join(p, 1n+m, t, Word.zero(1n+m)), WSp.join(p, 1n+m, Word.zero(p), WCon{True{}, Word.zero(m)})), b, lt_sh(p, m, t))

# ---- refusal is outside the spec's domain (where the object's view keeps the value) ----
# Bytes1: a byte vector of one byte above 255 has no encoding
def b1_dom(+w: U32, +h: {U32.is_lt(w, 256) == False{} : Bool}) -> {Bytes.vector_domain(1n, [w]) == False{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(w, 256), False{}, h) : {Bool.and(Bool.and(_, True{}), Bytes.size_fits(1n)) == False{} : Bool}
  {==}

def b1_enc(+w: U32, +h: {U32.is_lt(w, 256) == False{} : Bool}) -> {Encoding.encoding_for_legal_type(Spec.Bytes1(), S.BytesValue{[w]}) == None{} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, Bytes.vector_domain(1n, [w]), False{}, b1_dom(w, h)) : {Encoding.bytes(Encoding.one(SP.optional(_, [w]), Some{1n})) == None{} : Maybe<&2, +List<U32>>}
  {==}

def b1_none(+w: U32, +h: {U32.is_lt(w, 256) == False{} : Bool})
    -> {API.serialize(Spec.Bytes1(), S.BytesValue{[w]}) == None{} : Maybe<&2, +List<U32>>}:
  Equal.trans(Maybe<&2, +List<U32>>, API.serialize(Spec.Bytes1(), S.BytesValue{[w]}), Encoding.encoding_for_legal_type(Spec.Bytes1(), S.BytesValue{[w]}), None{},
    E.serialize_legal(Spec.Bytes1(), S.BytesValue{[w]}, VS.public_sound(Spec.Bytes1(), {==})),
    b1_enc(w, h))

# ---- a container whose first (or second) field has no encoding has none ----
def cat_none(+a: Maybe<&2, +List<S.Part>>) -> {Encoding.concatenate(a, None{}) == None{} : Maybe<&2, +List<S.Part>>}:
  match a:
    case None{}: {==}
    case Some{x}: {==}

def cont_head_none(names: List<&2, String>, +s: S.Schema, +rest: S.Schema, +h: S.Value, +t: S.Value,
    +e: {Encoding.parts(h, s) == None{} : Maybe<&2, +List<S.Part>>})
    -> {Encoding.encoding_for_legal_type(S.Container{names, S.Chain{s, rest}}, S.Sequence{S.Items{h, t}}) == None{} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Encoding.parts(h, s), None{}, e) :
    {Encoding.bytes(Encoding.aggregate(Encoding.concatenate(_, Encoding.parts(t, rest)), SS.fixed_size(S.Chain{s, rest}))) == None{} : Maybe<&2, +List<U32>>}
  {==}

def pcont_head_none(names: List<&2, String>, +s: S.Schema, +rest: S.Schema, act: List<&2, Bool>, +h: S.Value, +t: S.Value,
    +e: {Encoding.parts(h, s) == None{} : Maybe<&2, +List<S.Part>>})
    -> {Encoding.encoding_for_legal_type(S.ProgressiveContainer{names, S.Chain{s, rest}, act}, S.Sequence{S.Items{h, t}}) == None{} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Encoding.parts(h, s), None{}, e) :
    {Encoding.bytes(Encoding.aggregate(Encoding.concatenate(_, Encoding.parts(t, rest)), SS.fixed_size(S.Chain{s, rest}))) == None{} : Maybe<&2, +List<U32>>}
  {==}

# the second of two leaf fields
def cont_second_none(names: List<&2, String>, +s: S.Schema, +s2: S.Schema, +end: S.Schema, +h: S.Value, +h2: S.Value,
    +e: {Encoding.parts(h2, s2) == None{} : Maybe<&2, +List<S.Part>>})
    -> {Encoding.encoding_for_legal_type(S.Container{names, S.Chain{s, S.Chain{s2, end}}}, S.Sequence{S.Items{h, S.Items{h2, S.EmptyItems{}}}}) == None{} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Encoding.parts(h2, s2), None{}, e) :
    {Encoding.bytes(Encoding.aggregate(Encoding.concatenate(Encoding.parts(h, s), Encoding.concatenate(_, Encoding.parts(S.EmptyItems{}, end))), SS.fixed_size(S.Chain{s, S.Chain{s2, end}}))) == None{} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Encoding.concatenate(Encoding.parts(h, s), None{}), None{}, cat_none(Encoding.parts(h, s))) :
    {Encoding.bytes(Encoding.aggregate(_, SS.fixed_size(S.Chain{s, S.Chain{s2, end}}))) == None{} : Maybe<&2, +List<U32>>}
  {==}
