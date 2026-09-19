import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T
import ./word_split.bend as B
import ./power_division.bend as D
import ./byte_arithmetic.bend as A
import ./primitive_invariants.bend as V
import ./primitives.bend as Basic
import ./word_facts.bend as W

law byte_shape:
  for +x: U32
  for e: {U32.is_lt(x, 256) == True{} : Bool}
  {x == D.embed8(B.take(8n, 32n, D.bits(x))) : U32}
def byte_shape(x, e):
  match x:
    case U32{WCon{a, WCon{b, WCon{c, WCon{d, WCon{f, WCon{g, WCon{h, WCon{i, hi}}}}}}}}}:
      Equal.cong(Word(24n), U32,
        hi => U32{WCon{a, WCon{b, WCon{c, WCon{d, WCon{f, WCon{g, WCon{h, WCon{i, hi}}}}}}}}},
        hi, Word.zero(24n),
        B.below_one(23n, hi, B.lt_prefix(8n, 24n,
          WCon{a, WCon{b, WCon{c, WCon{d, WCon{f, WCon{g, WCon{h, WCon{i, WNil{}}}}}}}}}, hi,
          WCon{True{}, Word.zero(23n)}, e)))

law assembly_bytes:
  for +a: Word(8n)
  for +b: Word(8n)
  for +c: Word(8n)
  for +d: Word(8n)
  {U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))) ==
    U32.add(D.embed8(a), U32.add(U32.mul(256, D.embed8(b)), U32.add(U32.mul(65536, D.embed8(c)), U32.mul(16777216, D.embed8(d))))) : U32}
def assembly_bytes(a, b, c, d):
  %Equal.sym(U32, U32.mul(256, D.embed8(b)), U32.shln(D.embed8(b), 8n), A.multiply_shift8(D.embed8(b))) :
    {U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))) ==
      U32.add(D.embed8(a), U32.add(_, U32.add(U32.mul(65536, D.embed8(c)), U32.mul(16777216, D.embed8(d))))) : U32}
  %Equal.sym(U32, U32.mul(65536, D.embed8(c)), U32.shln(D.embed8(c), 16n), A.multiply_shift16(D.embed8(c))) :
    {U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))) ==
      U32.add(D.embed8(a), U32.add(U32.shln(D.embed8(b), 8n), U32.add(_, U32.mul(16777216, D.embed8(d))))) : U32}
  %Equal.sym(U32, U32.mul(16777216, D.embed8(d)), U32.shln(D.embed8(d), 24n), A.multiply_shift24(D.embed8(d))) :
    {U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))) ==
      U32.add(D.embed8(a), U32.add(U32.shln(D.embed8(b), 8n), U32.add(U32.shln(D.embed8(c), 16n), _))) : U32}
  Equal.trans(U32,
    U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))),
    U32{B.join(8n, 24n, a, B.join(8n, 16n, b, B.join(8n, 8n, c, d)))},
    U32.add(D.embed8(a), U32.add(U32.shln(D.embed8(b), 8n), U32.add(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))),
    A.pack_or4(a, b, c, d),
    Equal.sym(U32, U32.add(D.embed8(a), U32.add(U32.shln(D.embed8(b), 8n), U32.add(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))),
      U32{B.join(8n, 24n, a, B.join(8n, 16n, b, B.join(8n, 8n, c, d)))}, A.pack_add4(a, b, c, d)))

law assembly_correct:
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  for ea: {U32.is_lt(a, 256) == True{} : Bool}
  for eb: {U32.is_lt(b, 256) == True{} : Bool}
  for ec: {U32.is_lt(c, 256) == True{} : Bool}
  for ed: {U32.is_lt(d, 256) == True{} : Bool}
  {U32.or(a, U32.or(U32.shln(b, 8n), U32.or(U32.shln(c, 16n), U32.shln(d, 24n)))) == U32.add(a, U32.add(U32.mul(256, b), U32.add(U32.mul(65536, c), U32.mul(16777216, d)))) : U32}
def assembly_correct(a, b, c, d, ea, eb, ec, ed):
  %Equal.sym(U32, a, D.embed8(B.take(8n, 32n, D.bits(a))), byte_shape(a, ea)) : {U32.or(_, U32.or(U32.shln(b, 8n), U32.or(U32.shln(c, 16n), U32.shln(d, 24n)))) == U32.add(_, U32.add(U32.mul(256, b), U32.add(U32.mul(65536, c), U32.mul(16777216, d)))) : U32}
  %Equal.sym(U32, b, D.embed8(B.take(8n, 32n, D.bits(b))), byte_shape(b, eb)) : {U32.or(D.embed8(B.take(8n, 32n, D.bits(a))), U32.or(U32.shln(_, 8n), U32.or(U32.shln(c, 16n), U32.shln(d, 24n)))) == U32.add(D.embed8(B.take(8n, 32n, D.bits(a))), U32.add(U32.mul(256, _), U32.add(U32.mul(65536, c), U32.mul(16777216, d)))) : U32}
  %Equal.sym(U32, c, D.embed8(B.take(8n, 32n, D.bits(c))), byte_shape(c, ec)) : {U32.or(D.embed8(B.take(8n, 32n, D.bits(a))), U32.or(U32.shln(D.embed8(B.take(8n, 32n, D.bits(b))), 8n), U32.or(U32.shln(_, 16n), U32.shln(d, 24n)))) == U32.add(D.embed8(B.take(8n, 32n, D.bits(a))), U32.add(U32.mul(256, D.embed8(B.take(8n, 32n, D.bits(b)))), U32.add(U32.mul(65536, _), U32.mul(16777216, d)))) : U32}
  %Equal.sym(U32, d, D.embed8(B.take(8n, 32n, D.bits(d))), byte_shape(d, ed)) : {U32.or(D.embed8(B.take(8n, 32n, D.bits(a))), U32.or(U32.shln(D.embed8(B.take(8n, 32n, D.bits(b))), 8n), U32.or(U32.shln(D.embed8(B.take(8n, 32n, D.bits(c))), 16n), U32.shln(_, 24n)))) == U32.add(D.embed8(B.take(8n, 32n, D.bits(a))), U32.add(U32.mul(256, D.embed8(B.take(8n, 32n, D.bits(b)))), U32.add(U32.mul(65536, D.embed8(B.take(8n, 32n, D.bits(c)))), U32.mul(16777216, _)))) : U32}
  assembly_bytes(B.take(8n, 32n, D.bits(a)), B.take(8n, 32n, D.bits(b)), B.take(8n, 32n, D.bits(c)), B.take(8n, 32n, D.bits(d)))

law at_domain:
  for +xs: +List<U32>
  for +n: Nat
  for e: {S.bytes_domain(xs) == True{} : Bool}
  {U32.is_lt(I.at(xs, n), 256) == True{} : Bool}
def at_domain(xs, n, e):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      match n:
        case 0n: V.and_left(U32.is_lt(h, 256), S.bytes_domain(t), e)
        case 1n+p: at_domain(t, p, V.and_right(U32.is_lt(h, 256), S.bytes_domain(t), e))

law default_correct:
  for r: Maybe<&2, U32>
  {I.or_zero(r) == S.default_byte(r) : U32}
def default_correct(r):
  match r:
    case None{}: {==}
    case Some{v}: {==}

law at_correct:
  for xs: +List<U32>
  for n: Nat
  {I.at(xs, n) == S.byte_at(xs, n) : U32}
def at_correct(xs, n):
  default_correct(List.get(&2, U32, xs, n))

law read_limb_correct:
  for +xs: +List<U32>
  for +n: Nat
  for +e: {S.bytes_domain(xs) == True{} : Bool}
  {I.read_limb(xs, n) == S.limb_value(xs, n) : U32}
def read_limb_correct(xs, n, e):
  %at_correct(xs, n) :
    {I.read_limb(xs, n) == U32.add(_, U32.add(U32.mul(256, S.byte_at(xs, 1n+n)), U32.add(U32.mul(65536, S.byte_at(xs, 2n+n)), U32.mul(16777216, S.byte_at(xs, 3n+n))))) : U32}
  %at_correct(xs, 1n+n) :
    {I.read_limb(xs, n) == U32.add(I.at(xs, n), U32.add(U32.mul(256, _), U32.add(U32.mul(65536, S.byte_at(xs, 2n+n)), U32.mul(16777216, S.byte_at(xs, 3n+n))))) : U32}
  %at_correct(xs, 2n+n) :
    {I.read_limb(xs, n) == U32.add(I.at(xs, n), U32.add(U32.mul(256, I.at(xs, 1n+n)), U32.add(U32.mul(65536, _), U32.mul(16777216, S.byte_at(xs, 3n+n))))) : U32}
  %at_correct(xs, 3n+n) :
    {I.read_limb(xs, n) == U32.add(I.at(xs, n), U32.add(U32.mul(256, I.at(xs, 1n+n)), U32.add(U32.mul(65536, I.at(xs, 2n+n)), U32.mul(16777216, _)))) : U32}
  assembly_correct(I.at(xs, n), I.at(xs, 1n+n), I.at(xs, 2n+n), I.at(xs, 3n+n),
    at_domain(xs, n, e), at_domain(xs, 1n+n, e), at_domain(xs, 2n+n, e), at_domain(xs, 3n+n, e))

law decoded_correct:
  for +xs: +List<U32>
  for +e: {S.bytes_domain(xs) == True{} : Bool}
  {I.decoded(xs) == S.integer_value(xs) : T.UInt}
def decoded_correct(xs, e):
  %read_limb_correct(xs, 0n, e) : {I.decoded(xs) == T.UInt{_, S.limb_value(xs, 4n), S.limb_value(xs, 8n), S.limb_value(xs, 12n), S.limb_value(xs, 16n), S.limb_value(xs, 20n), S.limb_value(xs, 24n), S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 4n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), _, S.limb_value(xs, 8n), S.limb_value(xs, 12n), S.limb_value(xs, 16n), S.limb_value(xs, 20n), S.limb_value(xs, 24n), S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 8n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), I.read_limb(xs, 4n), _, S.limb_value(xs, 12n), S.limb_value(xs, 16n), S.limb_value(xs, 20n), S.limb_value(xs, 24n), S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 12n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), I.read_limb(xs, 4n), I.read_limb(xs, 8n), _, S.limb_value(xs, 16n), S.limb_value(xs, 20n), S.limb_value(xs, 24n), S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 16n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), I.read_limb(xs, 4n), I.read_limb(xs, 8n), I.read_limb(xs, 12n), _, S.limb_value(xs, 20n), S.limb_value(xs, 24n), S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 20n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), I.read_limb(xs, 4n), I.read_limb(xs, 8n), I.read_limb(xs, 12n), I.read_limb(xs, 16n), _, S.limb_value(xs, 24n), S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 24n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), I.read_limb(xs, 4n), I.read_limb(xs, 8n), I.read_limb(xs, 12n), I.read_limb(xs, 16n), I.read_limb(xs, 20n), _, S.limb_value(xs, 28n)} : T.UInt}
  %read_limb_correct(xs, 28n, e) : {I.decoded(xs) == T.UInt{I.read_limb(xs, 0n), I.read_limb(xs, 4n), I.read_limb(xs, 8n), I.read_limb(xs, 12n), I.read_limb(xs, 16n), I.read_limb(xs, 20n), I.read_limb(xs, 24n), _} : T.UInt}
  {==}

law scope_domain:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {S.byte_scope(n, xs) == True{} : Bool}
  {S.bytes_domain(xs) == True{} : Bool}
def scope_domain(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: Empty.absurd({S.bytes_domain(h <> t) == True{} : Bool}, W.false_true(e))
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}:
          V.and_true(U32.is_lt(h, 256), S.bytes_domain(t),
            V.and_left(U32.is_lt(h, 256), S.byte_scope(p, t), e),
            scope_domain(p, t, V.and_right(U32.is_lt(h, 256), S.byte_scope(p, t), e)))

law decode_branch:
  for ok: Bool
  for +n: Nat
  for +xs: +List<U32>
  for e: {S.byte_scope(n, xs) == ok : Bool}
  {I.decode_checked(ok, xs) == S.optional_integer(ok, xs) : Maybe<&2, T.UInt>}
def decode_branch(ok, n, xs, e):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(T.UInt, Maybe<&2, T.UInt>, v => Some{v}, I.decoded(xs), S.integer_value(xs),
        decoded_correct(xs, scope_domain(n, xs, e)))

law uint_deserialize_correct:
  for +w: T.Width
  for +xs: +List<U32>
  {I.uint_deserialize(w, xs) == S.uint_decoding(w, xs) : Maybe<&2, T.UInt>}
def uint_deserialize_correct(w, xs):
  %Basic.width_correct(w) :
    {I.uint_deserialize(w, xs) == S.optional_integer(S.byte_scope(_, xs), xs) : Maybe<&2, T.UInt>}
  %Basic.byte_scope_correct(I.width(w), xs) :
    {I.uint_deserialize(w, xs) == S.optional_integer(_, xs) : Maybe<&2, T.UInt>}
  decode_branch(I.valid_bytes(I.width(w), xs), I.width(w), xs,
    Equal.sym(Bool, I.valid_bytes(I.width(w), xs), S.byte_scope(I.width(w), xs), Basic.byte_scope_correct(I.width(w), xs)))
