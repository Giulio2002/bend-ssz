import Base
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../proofs/power_division.bend as PD
import ../../proofs/word_split.bend as WSp
import ./pb_min.bend as PBM

# The uint domains of the one-word leaves (spec/primitives.bend uint_domain),
# from their representation facts: a lemma library of the structural-validity
# lemmas (proofs/obj/valid_*.bend, codegen/valid_laws.py).

def nothing_is(m: Maybe<&2, +List<U32>>) -> Type:
  match m:
    case None{}: Unit
    case Some{v}: Empty

def none_some(+ys: +List<U32>, +e: {None{} == Some{ys} : Maybe<&2, +List<U32>>}) -> Empty:
  %e : nothing_is(_)
  Unit{}

# An encoding that exists was allowed by its domain.
def od_true(+b: Bool, +xs: +List<U32>, +ys: +List<U32>, +e: {SP.optional(b, xs) == Some{ys} : Maybe<&2, +List<U32>>}) -> {b == True{} : Bool}:
  match b:
    case True{}: {==}
    case False{}: Empty.absurd({False{} == True{} : Bool}, none_some(ys, e))

# uint8: a value below 256.
def u8dom(+x: U32, +e: {U32.is_lt(x, 256) == True{} : Bool}) -> {SP.uint_domain(P.U8{}, P.UInt{x, 0, 0, 0, 0, 0, 0, 0}) == True{} : Bool}:
  od_true(SP.uint_domain(P.U8{}, P.UInt{x, 0, 0, 0, 0, 0, 0, 0}), SP.prefix(1n, SP.full_digits(P.UInt{x, 0, 0, 0, 0, 0, 0, 0})), [x], PBM.bone(x, e))

# uint32: every word (the zero high limbs through pb_min's zt0, never evaluated).
def u32dom(+x: U32) -> {SP.uint_domain(P.U32Width{}, P.UInt{x, 0, 0, 0, 0, 0, 0, 0}) == True{} : Bool}:
  %Equal.sym(Bool, SP.zero_suffix(PBM.ap(SP.limb_digits(0), PBM.ap(SP.limb_digits(0), PBM.ap(SP.limb_digits(0), PBM.ap(SP.limb_digits(0), PBM.ap(SP.limb_digits(0), PBM.ap(SP.limb_digits(0), SP.limb_digits(0)))))))), True{}, PBM.zt0()) :
    {_ == True{} : Bool}
  {==}

# uint16: a value below 65536 is its low sixteen bits followed by zeros.
law half_shape:
  for +x: U32
  for e: {U32.is_lt(x, 65536) == True{} : Bool}
  {x == U32{WSp.join(16n, 16n, WSp.take(16n, 32n, PD.bits(x)), Word.zero(16n))} : U32}
def half_shape(x, e):
  match x:
    case U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, hi}}}}}}}}}}}}}}}}}:
      Equal.cong(Word(16n), U32, hi => U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, hi}}}}}}}}}}}}}}}}}, hi, Word.zero(16n),
        WSp.below_one(15n, hi, WSp.lt_prefix(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, hi, WCon{True{}, Word.zero(15n)}, e)))

def u16s(+a0: Bool, +a1: Bool, +a2: Bool, +a3: Bool, +a4: Bool, +a5: Bool, +a6: Bool, +a7: Bool, +a8: Bool, +a9: Bool, +a10: Bool, +a11: Bool, +a12: Bool, +a13: Bool, +a14: Bool, +a15: Bool) -> {SP.optional(SP.uint_domain(P.U16{}, P.UInt{U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0}), SP.prefix(2n, SP.full_digits(P.UInt{U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0}))) == Some{[U32.and(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 255), U32.and(U32.shrn(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 8n), 255)]} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Maybe<&2, +List<U32>>, RR.basic_one(S.UnsignedValue{P.UInt{U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}), SP.optional(SP.zero_suffix([U32.and(U32.shrn(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 16n), 255), U32.shrn(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 24n)]), [U32.and(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 255), U32.and(U32.shrn(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 8n), 255)]), PBM.u16h(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0, PBM.zt0())) :
    {_ == Some{[U32.and(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 255), U32.and(U32.shrn(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 8n), 255)]} : Maybe<&2, +List<U32>>}
  {==}

def u16w(+w16: Word(16n)) -> {SP.uint_domain(P.U16{}, P.UInt{U32{WSp.join(16n, 16n, w16, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0}) == True{} : Bool}:
  match w16:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WCon{+a8, WCon{+a9, WCon{+a10, WCon{+a11, WCon{+a12, WCon{+a13, WCon{+a14, WCon{+a15, WNil{}}}}}}}}}}}}}}}}}:
      od_true(SP.uint_domain(P.U16{}, P.UInt{U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0}), SP.prefix(2n, SP.full_digits(P.UInt{U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 0, 0, 0, 0, 0, 0, 0})), [U32.and(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 255), U32.and(U32.shrn(U32{WSp.join(16n, 16n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{a8, WCon{a9, WCon{a10, WCon{a11, WCon{a12, WCon{a13, WCon{a14, WCon{a15, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n))}, 8n), 255)], u16s(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15))

def u16dom(+x: U32, +e: {U32.is_lt(x, 65536) == True{} : Bool}) -> {SP.uint_domain(P.U16{}, P.UInt{x, 0, 0, 0, 0, 0, 0, 0}) == True{} : Bool}:
  %Equal.sym(U32, x, U32{WSp.join(16n, 16n, WSp.take(16n, 32n, PD.bits(x)), Word.zero(16n))}, half_shape(x, e)) :
    {SP.uint_domain(P.U16{}, P.UInt{_, 0, 0, 0, 0, 0, 0, 0}) == True{} : Bool}
  u16w(WSp.take(16n, 32n, PD.bits(x)))
