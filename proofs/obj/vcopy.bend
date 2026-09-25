import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/buf.bend as BF
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vdepth.bend as VD

# The input copy O.copy_in (the decoder of every packed field) on the array
# model: an aligned range of whole words.

def split4_c(+b0: Bool, +b1: Bool, +r: Word(30n)) -> {U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n)) == Word.to_nat(30n, r) : Nat}:
  BF.quarter_value(b0, b1, r)

# A word is four times its value shifted right by two, plus its low two bits.
law split4:
  for +x: U32
  {U32.to_nat(x) == Nat.add(A.quad(U32.to_nat(U32.shrn(x, 2n))), U32.to_nat(U32.and(x, 3))) : Nat}
def split4(x):
  match x:
    case U32{WCon{False{}, WCon{False{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, r}}}, 2n))), U32.to_nat(U32{WCon{False{}, WCon{False{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(False{}, False{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, r}}}) == Nat.add(A.quad(_), 0n) : Nat}
      %F.nat__add_comm(0n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{False{}, WCon{False{}, r}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{False{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n))), U32.to_nat(U32{WCon{True{}, WCon{False{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(True{}, False{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, r}}}) == Nat.add(A.quad(_), 1n) : Nat}
      %F.nat__add_comm(1n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{True{}, WCon{False{}, r}}}) == _ : Nat}
      {==}
    case U32{WCon{False{}, WCon{True{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n))), U32.to_nat(U32{WCon{False{}, WCon{True{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(False{}, True{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, r}}}) == Nat.add(A.quad(_), 2n) : Nat}
      %F.nat__add_comm(2n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{False{}, WCon{True{}, r}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{True{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n))), U32.to_nat(U32{WCon{True{}, WCon{True{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(True{}, True{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, r}}}) == Nat.add(A.quad(_), 3n) : Nat}
      %F.nat__add_comm(3n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{True{}, WCon{True{}, r}}}) == _ : Nat}
      {==}

# The storage word count of n bytes, and the size copy_in allocates for.
def nwu(+L: U32) -> U32: U32.shrn(U32.add(L, 3), 2n)
def NW(+L: U32) -> Nat: U32.to_nat(nwu(L))
def WZ(+L: U32) -> U32: U32.add(U32.mul(U32.shrn(U32.add(L, 31), 5n), 8), 8)
def ZT(+dz: Nat) -> F.array__Tree<U32>: F.array__trep(U32, dz, 0)

def mask_keep(+L: U32, X: Array<U32>, +h3: {U32.and(L, 3) == 0 : U32}) -> {O.mask_last(L, X) == X : Array<U32>}:
  %Equal.sym(U32, U32.and(L, 3), 0, h3) : {O.ml_go(U32.is_eq(_, 0), _, U32.sub(nwu(L), 1), X) == X : Array<U32>}
  {==}

def ci_case(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +L: U32, +dz: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +h3: {U32.and(off, 3) == 0 : U32}, +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}, +hL3: {U32.and(L, 3) == 0 : U32},
    +hs: {Nat.is_le(Nat.add(NW(L), i), VB.pw(d)) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(L, 0) == z : Bool})
    -> {O.ci_fin(n, L, O.ci_go(z, U32.and(off, 3), U32.shrn(off, 2n), nwu(L), F.array__thaw(U32, ZT(dz)), F.array__thaw(U32, t)))
        == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}:
  match z:
    case True{}:
      +eL = F.u32alg__eq_of(L, 0, ez)
      %Equal.sym(Array<U32>, O.mask_last(L, F.array__thaw(U32, ZT(dz))), F.array__thaw(U32, ZT(dz)), mask_keep(L, F.array__thaw(U32, ZT(dz)), hL3)) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{_, L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      %Equal.sym(U32, L, 0, eL) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, ZT(dz)), L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(_), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      {==}
    case False{}:
      %Equal.sym(U32, U32.and(off, 3), 0, h3) :
        {O.ci_fin(n, L, O.ci_pick(_, U32.shrn(off, 2n), nwu(L), F.array__thaw(U32, ZT(dz)), F.array__thaw(U32, t)))
          == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.acopy(nwu(L), U32.shrn(off, 2n), 0, F.array__thaw(U32, ZT(dz)), F.array__thaw(U32, t)),
          (F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), F.array__thaw(U32, t)),
          VB.acopy_ok(nwu(L), U32.shrn(off, 2n), 0, i, 0n, dz, d, ZT(dz), t, ei, {==}, hdz, hd, hs, hr, F.array__trep_perfect(U32, dz, 0), pf)) :
        {O.ci_fin(n, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32>, O.mask_last(L, F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t))), F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), mask_keep(L, F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), hL3)) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{_, L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      {==}

# copy_in of a whole number of words at a word-aligned offset copies them.
law copy_in_ok:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +i: Nat
  for +L: U32
  for +dz: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +ez: {B.zeros(B.words_depth_u(WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hL3: {U32.and(L, 3) == 0 : U32}
  for +hs: {Nat.is_le(Nat.add(NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  {O.copy_in(B.Buf{F.array__thaw(U32, t), n}, off, L) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
def copy_in_ok(d, t, n, off, i, L, dz, pf, hd, hdz, ez, h3, ei, hL3, hs, hr):
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(WZ(L))), Array.new(U32, dz, 0), ez) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
  %Equal.sym(Array<U32>, Array.new(U32, dz, 0), F.array__thaw(U32, ZT(dz)), F.array__new(U32, dz, 0)) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
  ci_case(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hL3, hs, hr, U32.is_eq(L, 0), {==})
