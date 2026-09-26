import Base
import ../../src/obj.bend as O
import ../../types/generic_obj.bend as T
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/bit_packing.bend as Bp
import ../../spec/bitfields.bend as SBF
import ../compact/found.bend as FD
import ./spec_fixed.bend as F
import ./spec_bits.bend as FB
import ./vbitl.bend as VBL
import ./vfx_bv257.bend as G
import ./vbitb.bend as VBB
import ./vbv257.bend as V

# The spec's value of a Bitvector[257] object (its eight words' bits, then the last word's low bit) and its
# parts: one fixed part, the object's 33 bytes (vbv257.BYW), when the runtime's check passes (last word < 2).
# Hand-written, from vfx_bv257's pack_app / ob1.

def V257(o: T.Bitvector257) -> S.Value:
  match o:
    case T.Bitvector257{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8}: S.BitsValue{List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])}

def c1(+b: Bool) -> {G.CHKv(U32{WCon{b, Word.zero(31n)}}) == True{} : Bool}:
  match b:
    case False{}: {==}
    case True{}: {==}
def chk1(+v: U32, +h: {U32.is_lt(v, 2) == True{} : Bool}) -> {G.CHKv(v) == True{} : Bool}:
  %Equal.sym(U32, v, U32{WCon{VBB.B0(v), Word.zero(31n)}}, VBB.shape1(v, h)) : {G.CHKv(_) == True{} : Bool}
  c1(VBB.B0(v))

def elen(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32) -> {List.length(&2, Bool, List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])) == 257n : Nat}:
  %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])), Nat.add(List.length(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7])), 1n), VBL.lenB_app(FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])) : {_ == 257n : Nat}
  %Equal.sym(Nat, List.length(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7])), FB.bitlen([w0, w1, w2, w3, w4, w5, w6, w7]), FB.len_bits([w0, w1, w2, w3, w4, w5, w6, w7])) : {Nat.add(_, 1n) == 257n : Nat}
  {==}

def prtw(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32, +h: {U32.is_lt(w8, 2) == True{} : Bool})
    -> {Codec.parts(S.BitsValue{List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])}, S.BitVector{257n}) == Some{[S.Fixed{List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), [U32.and(w8, 255)])}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(U32, U32.and(w8, 255), w8, VBB.ea(w8, VBB.e1(w8, h))) :
    {Codec.parts(S.BitsValue{List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])}, S.BitVector{257n}) == Some{[S.Fixed{List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), [_])}]} : Maybe<&2, +List<S.Part>>}
  %G.ob1(w8, chk1(w8, h)) :
    {Codec.parts(S.BitsValue{List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])}, S.BitVector{257n}) == Some{[S.Fixed{List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), [_])}]} : Maybe<&2, +List<S.Part>>}
  %G.pack_app([w0, w1, w2, w3, w4, w5, w6, w7], [G.LB(w8)]) :
    {Codec.parts(S.BitsValue{List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])}, S.BitVector{257n}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])), 257n, elen(w0, w1, w2, w3, w4, w5, w6, w7, w8)) :
    {Codec.one(SBF.encoding(Bool.and(Nat.is_lt(0n, 257n), Nat.is_eq(_, 257n)), List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)])), Some{Nat.div(Nat.add(257n, 7n), 8n)}) == Some{[S.Fixed{Bp.pack(List.append(&2, Bool, FB.bitsof([w0, w1, w2, w3, w4, w5, w6, w7]), [G.LB(w8)]))}]} : Maybe<&2, +List<S.Part>>}
  {==}

def prt257(+o: T.Bitvector257, +h: {T.bv257_valid(o) == True{} : Bool}) -> {Codec.parts(V257(o), S.BitVector{257n}) == Some{[S.Fixed{V.BYW(o)}]} : Maybe<&2, +List<S.Part>>}:
  match o:
    case T.Bitvector257{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8}: prtw(w0, w1, w2, w3, w4, w5, w6, w7, w8, h)
