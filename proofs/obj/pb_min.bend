import Base
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../proofs/integer_encoding.bend as IE
import ../../proofs/integer_decoding.bend as ID
import ../../proofs/power_division.bend as PD
import ../../proofs/word_split.bend as WSp

# The uint8 / uint16 list items (it1, it2) and the byte-encoding facts of packed_bytes.bend, without its
# root imports (zero_roots evaluates 63 SHA-256 compressions at load): for the uint8 list
# windows (vu8.bend and the lists' window modules).
law andt:
  for +a: Bool
  {Bool.and(a, True{}) == a : Bool}
def andt(a):
  match a:
    case True{}: {==}
    case False{}: {==}

law andf:
  for +a: Bool
  {Bool.and(a, False{}) == False{} : Bool}
def andf(a):
  match a:
    case True{}: {==}
    case False{}: {==}

law mul1:
  for +L: Nat
  {L == Nat.mul(L, 1n) : Nat}
def mul1(L):
  match L:
    case 0n: {==}
    case 1n+ +p:
      %mul1(p) : {1n+p == 1n+_ : Nat}
      {==}

law bone8:
  for +w8: Word(8n)
  {RR.basic_one(S.UnsignedValue{P.UInt{PD.embed8(w8), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}) == Some{[PD.embed8(w8)]} : Maybe<&2, +List<U32>>}
def bone8(w8):
  match w8:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WNil{}}}}}}}}}:
      %IE.limb_correct(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})) :
        {SP.optional(SP.fits(1n, List.append(&2, U32, _, List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), SP.limb_digits(0))))))))), SP.prefix(1n, List.append(&2, U32, _, List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), SP.limb_digits(0)))))))))) == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a0, True{}), a0, andt(a0)) :
        {Some{[U32{WCon{_, WCon{Bool.and(a1, True{}), WCon{Bool.and(a2, True{}), WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a1, True{}), a1, andt(a1)) :
        {Some{[U32{WCon{a0, WCon{_, WCon{Bool.and(a2, True{}), WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a2, True{}), a2, andt(a2)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{_, WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a3, True{}), a3, andt(a3)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{_, WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a4, True{}), a4, andt(a4)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{_, WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a5, True{}), a5, andt(a5)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{_, WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a6, True{}), a6, andt(a6)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{_, WCon{Bool.and(a7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a7, True{}), a7, andt(a7)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{_, Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      {==}

law bone:
  for +x: U32
  for +e: {U32.is_lt(x, 256) == True{} : Bool}
  {RR.basic_one(S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}) == Some{[x]} : Maybe<&2, +List<U32>>}
def bone(x, e):
  %Equal.sym(U32, x, PD.embed8(WSp.take(8n, 32n, PD.bits(x))), ID.byte_shape(x, e)) :
    {RR.basic_one(S.UnsignedValue{P.UInt{_, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}) == Some{[_]} : Maybe<&2, +List<U32>>}
  bone8(WSp.take(8n, 32n, PD.bits(x)))

def it1(k: Nat, xs: +List<U32>) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+c:
      match xs:
        case Nil{}: S.EmptyItems{}
        case Con{+x, t}: S.Items{S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}, it1(c, t)}


# ---- uint16: two bytes per element (packed_bytes.bend) ----

def v16of(+x0: U32, +x1: U32) -> U32: U32{WSp.join(8n, 24n, WSp.take(8n, 32n, PD.bits(x0)), WSp.join(8n, 16n, WSp.take(8n, 32n, PD.bits(x1)), Word.zero(16n)))}

law two8:
  for +t0: Word(8n)
  for +t1: Word(8n)
  {RR.basic_one(S.UnsignedValue{P.UInt{v16of(PD.embed8(t0), PD.embed8(t1)), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}) == Some{[PD.embed8(t0), PD.embed8(t1)]} : Maybe<&2, +List<U32>>}
def two8(t0, t1):
  match t0 t1:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WNil{}}}}}}}}} WCon{+b0, WCon{+b1, WCon{+b2, WCon{+b3, WCon{+b4, WCon{+b5, WCon{+b6, WCon{+b7, WNil{}}}}}}}}}:
      %IE.limb_correct(U32{WSp.join(8n, 24n, WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}, WSp.join(8n, 16n, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}, Word.zero(16n)))}) :
        {SP.optional(SP.fits(2n, List.append(&2, U32, _, List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), SP.limb_digits(0))))))))), SP.prefix(2n, List.append(&2, U32, _, List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), List.append(&2, U32, SP.limb_digits(0), SP.limb_digits(0)))))))))) == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a0, True{}), a0, andt(a0)) :
        {Some{[U32{WCon{_, WCon{Bool.and(a1, True{}), WCon{Bool.and(a2, True{}), WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a1, True{}), a1, andt(a1)) :
        {Some{[U32{WCon{a0, WCon{_, WCon{Bool.and(a2, True{}), WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a2, True{}), a2, andt(a2)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{_, WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a3, True{}), a3, andt(a3)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{_, WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a4, True{}), a4, andt(a4)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{_, WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a5, True{}), a5, andt(a5)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{_, WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a6, True{}), a6, andt(a6)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{_, WCon{Bool.and(a7, True{}), WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(a7, True{}), a7, andt(a7)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{_, WCon{Bool.and(b0, False{}), WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b0, False{}), False{}, andf(b0)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{_, WCon{Bool.and(b1, False{}), WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b1, False{}), False{}, andf(b1)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{_, WCon{Bool.and(b2, False{}), WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b2, False{}), False{}, andf(b2)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{_, WCon{Bool.and(b3, False{}), WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b3, False{}), False{}, andf(b3)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{_, WCon{Bool.and(b4, False{}), WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b4, False{}), False{}, andf(b4)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{_, WCon{Bool.and(b5, False{}), WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b5, False{}), False{}, andf(b5)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{_, WCon{Bool.and(b6, False{}), WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b6, False{}), False{}, andf(b6)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{_, WCon{Bool.and(b7, False{}), Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b7, False{}), False{}, andf(b7)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{_, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b0, True{}), b0, andt(b0)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{_, WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b1, True{}), b1, andt(b1)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{_, WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b2, True{}), b2, andt(b2)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{b1, WCon{_, WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b3, True{}), b3, andt(b3)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{b1, WCon{b2, WCon{_, WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b4, True{}), b4, andt(b4)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{_, WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b5, True{}), b5, andt(b5)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{_, WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b6, True{}), b6, andt(b6)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{_, WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Bool.and(b7, True{}), b7, andt(b7)) :
        {Some{[U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(16n)}}}}}}}}}}}}}}}}}, U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{_, Word.zero(24n)}}}}}}}}}]} == Some{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), PD.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}})]} : Maybe<&2, +List<U32>>}
      {==}

law two:
  for +x0: U32
  for +x1: U32
  for +e0: {U32.is_lt(x0, 256) == True{} : Bool}
  for +e1: {U32.is_lt(x1, 256) == True{} : Bool}
  {RR.basic_one(S.UnsignedValue{P.UInt{v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}) == Some{[x0, x1]} : Maybe<&2, +List<U32>>}
def two(x0, x1, e0, e1):
  %Equal.sym(U32, x0, PD.embed8(WSp.take(8n, 32n, PD.bits(x0))), ID.byte_shape(x0, e0)) :
    {RR.basic_one(S.UnsignedValue{P.UInt{v16of(_, x1), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}) == Some{[_, x1]} : Maybe<&2, +List<U32>>}
  %Equal.sym(U32, x1, PD.embed8(WSp.take(8n, 32n, PD.bits(x1))), ID.byte_shape(x1, e1)) :
    {RR.basic_one(S.UnsignedValue{P.UInt{v16of(PD.embed8(WSp.take(8n, 32n, PD.bits(x0))), _), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}) == Some{[PD.embed8(WSp.take(8n, 32n, PD.bits(x0))), _]} : Maybe<&2, +List<U32>>}
  two8(WSp.take(8n, 32n, PD.bits(x0)), WSp.take(8n, 32n, PD.bits(x1)))

def it2(k: Nat, xs: +List<U32>) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+c:
      match xs:
        case Nil{}: S.EmptyItems{}
        case Con{+x0, t}:
          match t:
            case Nil{}: S.EmptyItems{}
            case Con{+x1, rest}: S.Items{S.UnsignedValue{P.UInt{v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, it2(c, rest)}

law dbl_mul:
  for +L: Nat
  {Nat.double(L) == Nat.mul(L, 2n) : Nat}
def dbl_mul(L):
  match L:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.double(p), Nat.mul(p, 2n), dbl_mul(p)) : {2n+_ == Nat.add(2n, Nat.mul(p, 2n)) : Nat}
      {==}

