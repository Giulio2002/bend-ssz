import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/bit_packing.bend as Bp
import ../../spec/bitfields.bend as SBF
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ./spec_fixed.bend as FX
import ./spec_bits.bend as FB
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vbrt.bend as VR
import ./vuw.bend as UW
import ./venc.bend as VE
import ./vbitl.bend as VBL
import ./vfx_bv1281.bend as G

# The spec side of the word-held bit vectors of the generic containers (hand-written): Bitvector[1280]
# (40 words) and Bitvector[1281] (40 words, then one byte of the 41st), their values and parts.

def X32(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: 32n+X32(p)
law bitlen_x32:
  for +ws: +List<U32>
  {FB.bitlen(ws) == X32(List.length(&2, U32, ws)) : Nat}
def bitlen_x32(ws):
  match ws:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(Nat, Nat, z => 32n+z, FB.bitlen(t), X32(List.length(&2, U32, t)), bitlen_x32(t))

def len40(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(40n, VB.pw(dB)) == True{} : Bool})
    -> {List.length(&2, U32, VS.wtake(40n, UW.SLW(TB))) == 40n : Nat}:
  UW.len_take(40n, UW.SLW(TB), FD.logic__subst(Nat, z => {Nat.is_le(40n, z) == True{} : Bool}, VB.pw(dB), VB.len(UW.SLW(TB)), Equal.sym(Nat, VB.len(UW.SLW(TB)), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)), hrB))
def bl1280(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(40n, VB.pw(dB)) == True{} : Bool})
    -> {FB.bitlen(VS.wtake(40n, UW.SLW(TB))) == 1280n : Nat}:
  Equal.trans(Nat, FB.bitlen(VS.wtake(40n, UW.SLW(TB))), X32(List.length(&2, U32, VS.wtake(40n, UW.SLW(TB)))), 1280n, bitlen_x32(VS.wtake(40n, UW.SLW(TB))),
    Equal.cong(Nat, Nat, z => X32(z), List.length(&2, U32, VS.wtake(40n, UW.SLW(TB))), 40n, len40(dB, TB, pfB, hrB)))

# ---- Bitvector[1280]: the bits of the first 40 words ----
def V1280(+TB: FD.array__Tree<U32>) -> S.Value: S.BitsValue{FB.bitsof(VS.wtake(40n, UW.SLW(TB)))}
def prt1280(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(40n, VB.pw(dB)) == True{} : Bool})
    -> {Codec.parts(V1280(TB), S.BitVector{1280n}) == Some{[S.Fixed{FX.limbs(VS.wtake(40n, UW.SLW(TB)))}]} : Maybe<&2, +List<S.Part>>}:
  FB.bits_part(VS.wtake(40n, UW.SLW(TB)), 1280n, FD.logic__subst(Nat, z => {Nat.is_eq(z, 1280n) == True{} : Bool}, 1280n, FB.bitlen(VS.wtake(40n, UW.SLW(TB))), Equal.sym(Nat, FB.bitlen(VS.wtake(40n, UW.SLW(TB))), 1280n, bl1280(dB, TB, pfB, hrB)), {==}), {==})

# ---- Bitvector[1281]: the bits of the first 40 words, then the low bit of the 41st ----
law bt_limbs1:
  for +m: Nat
  for +W: +List<U32>
  for +h: {Nat.is_lt(m, FD.spec_common__length(U32, W)) == True{} : Bool}
  {VS.bt(Nat.add(A.quad(m), 1n), FX.limbs(W)) == List.append(&2, U32, FX.limbs(VS.wtake(m, W)), [U32.and(FD.flat__nthc(W, m), 255)]) : +List<U32>}
def bt_limbs1(m, W, h):
  match m W:
    case _ Nil{}: Empty.absurd({VS.bt(Nat.add(A.quad(m), 1n), FX.limbs([])) == List.append(&2, U32, FX.limbs(VS.wtake(m, [])), [U32.and(FD.flat__nthc([], m), 255)]) : +List<U32>}, FD.nat__lt_zero_absurd(m, h))
    case 0n Con{+w, +t}: {==}
    case 1n+ +p Con{+w, +t}:
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, I.limb(w), z), VS.bt(Nat.add(A.quad(p), 1n), FX.limbs(t)), List.append(&2, U32, FX.limbs(VS.wtake(p, t)), [U32.and(FD.flat__nthc(t, p), 255)]), bt_limbs1(p, t, h))

def W40(+TB: FD.array__Tree<U32>) -> U32: U32.and(VB.slot(TB, 40n), 255)
def V1281(+TB: FD.array__Tree<U32>) -> S.Value: S.BitsValue{List.append(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))])}

def band_as(+a: Bool, +b: Bool, +c: Bool) -> {Bool.and(Bool.and(a, b), c) == Bool.and(a, Bool.and(b, c)) : Bool}:
  match a b c:
    case False{} False{} False{}: {==}
    case False{} False{} True{}: {==}
    case False{} True{} False{}: {==}
    case False{} True{} True{}: {==}
    case True{} False{} False{}: {==}
    case True{} False{} True{}: {==}
    case True{} True{} False{}: {==}
    case True{} True{} True{}: {==}
law wand_as:
  for +n: Nat
  for +x: Word(n)
  for +y: Word(n)
  for +z: Word(n)
  {Word.and(n, Word.and(n, x, y), z) == Word.and(n, x, Word.and(n, y, z)) : Word(n)}
def wand_as(n, x, y, z):
  match n:
    case 0n: {==}
    case 1n+ +p:
      match x y z:
        case WCon{+a, +xt} WCon{+b, +yt} WCon{+c, +zt}:
          Equal.trans(Word(1n+p), WCon{Bool.and(Bool.and(a, b), c), Word.and(p, Word.and(p, xt, yt), zt)}, WCon{Bool.and(a, Bool.and(b, c)), Word.and(p, Word.and(p, xt, yt), zt)},
            WCon{Bool.and(a, Bool.and(b, c)), Word.and(p, xt, Word.and(p, yt, zt))},
            Equal.cong(Bool, Word(1n+p), h => WCon{h, Word.and(p, Word.and(p, xt, yt), zt)}, Bool.and(Bool.and(a, b), c), Bool.and(a, Bool.and(b, c)), band_as(a, b, c)),
            Equal.cong(Word(p), Word(1n+p), t => WCon{Bool.and(a, Bool.and(b, c)), t}, Word.and(p, Word.and(p, xt, yt), zt), Word.and(p, xt, Word.and(p, yt, zt)), wand_as(p, xt, yt, zt)))
def and_as(+a: U32, +b: U32, +c: U32) -> {U32.and(U32.and(a, b), c) == U32.and(a, U32.and(b, c)) : U32}:
  match a b c:
    case U32{+x} U32{+y} U32{+z}: Equal.cong(Word(32n), U32, w => U32{w}, Word.and(32n, Word.and(32n, x, y), z), Word.and(32n, x, Word.and(32n, y, z)), wand_as(32n, x, y, z))

# the runtime's word read is the tree's slot
def wd_slot(+d: Nat, +t: FD.array__Tree<U32>, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}) -> {RD.wd(t, d, q) == VB.slot(t, i) : U32}:
  +e = Equal.trans(Array<U32> & U32, (FD.array__thaw(U32, t), RD.wd(t, d, q)), Array.get(U32, FD.array__thaw(U32, t), q), (FD.array__thaw(U32, t), VB.slot(t, i)),
    Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, t), q), (FD.array__thaw(U32, t), RD.wd(t, d, q)), VE.get_any(d, t, q, VB.lt32(d, hd), pf)),
    VB.get_n(d, t, q, i, eq, VB.lt32(d, hd), hi, pf))
  Equal.cong(Array<U32> & U32, U32, p => Pair.snd(Array<U32>, U32, p), (FD.array__thaw(U32, t), RD.wd(t, d, q)), (FD.array__thaw(U32, t), VB.slot(t, i)), e)

def h40(+dB: Nat, +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}) -> {Nat.is_lt(40n, VB.pw(dB)) == True{} : Bool}:
  A.quad_lt(40n, VB.pw(dB), FD.nat__lt_le_trans(160n, 161n, A.quad(VB.pw(dB)), {==}, hrB))

# the last byte has bits 1..31 clear (the runtime's check of the tail bits)
def chk(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == True{} : Bool})
    -> {G.CHKv(W40(TB)) == True{} : Bool}:
  +w = VB.slot(TB, 40n)
  +ew = wd_slot(dB, TB, U32.shrn(1281, 5n), 40n, {==}, FD.nat__lt_trans(dB, 28n, 31n, hdB, {==}), h40(dB, hrB), pfB)
  +h0 = FD.u32alg__eq_of(U32.and(w, 4294967294), 0, FD.logic__subst(U32, z => {U32.is_eq(U32.and(z, 4294967294), 0) == True{} : Bool}, RD.wd(TB, dB, U32.shrn(1281, 5n)), w, ew, hbz))
  +e1 = Equal.trans(U32, U32.and(U32.and(w, 255), 4294967294), U32.and(w, 254), 0, and_as(w, 255, 4294967294),
    Equal.trans(U32, U32.and(w, 254), U32.and(U32.and(w, 4294967294), 254), 0, Equal.sym(U32, U32.and(U32.and(w, 4294967294), 254), U32.and(w, 254), and_as(w, 4294967294, 254)),
      Equal.cong(U32, U32, z => U32.and(z, 254), U32.and(w, 4294967294), 0, h0)))
  Equal.cong(U32, Bool, z => U32.is_eq(z, 0), U32.and(U32.and(w, 255), 4294967294), 0, e1)

def elen(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(40n, VB.pw(dB)) == True{} : Bool})
    -> {List.length(&2, Bool, List.append(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))])) == 1281n : Nat}:
  %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))])), Nat.add(List.length(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB)))), 1n), VBL.lenB_app(FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))])) : {_ == 1281n : Nat}
  %Equal.sym(Nat, List.length(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB)))), FB.bitlen(VS.wtake(40n, UW.SLW(TB))), FB.len_bits(VS.wtake(40n, UW.SLW(TB)))) : {Nat.add(_, 1n) == 1281n : Nat}
  %Equal.sym(Nat, FB.bitlen(VS.wtake(40n, UW.SLW(TB))), 1280n, bl1280(dB, TB, pfB, hrB)) : {Nat.add(_, 1n) == 1281n : Nat}
  {==}

def prt1281(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == True{} : Bool})
    -> {Codec.parts(V1281(TB), S.BitVector{1281n}) == Some{[S.Fixed{VS.bt(161n, FX.limbs(UW.SLW(TB)))}]} : Maybe<&2, +List<S.Part>>}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(40n, z) == True{} : Bool}, VB.pw(dB), FD.spec_common__length(U32, UW.SLW(TB)),
    Equal.sym(Nat, FD.spec_common__length(U32, UW.SLW(TB)), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)), h40(dB, hrB))
  +h40l = FD.nat__lt_le(40n, VB.pw(dB), h40(dB, hrB))
  %Equal.sym(+List<U32>, VS.bt(161n, FX.limbs(UW.SLW(TB))), List.append(&2, U32, FX.limbs(VS.wtake(40n, UW.SLW(TB))), [W40(TB)]), bt_limbs1(40n, UW.SLW(TB), hl)) :
    {Codec.parts(V1281(TB), S.BitVector{1281n}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  %G.ob1(W40(TB), chk(dB, TB, pfB, hdB, hrB, hbz)) :
    {Codec.parts(V1281(TB), S.BitVector{1281n}) == Some{[S.Fixed{List.append(&2, U32, FX.limbs(VS.wtake(40n, UW.SLW(TB))), [_])}]} : Maybe<&2, +List<S.Part>>}
  %G.pack_app(VS.wtake(40n, UW.SLW(TB)), [G.LB(W40(TB))]) :
    {Codec.parts(V1281(TB), S.BitVector{1281n}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))])), 1281n, elen(dB, TB, pfB, h40l)) :
    {Codec.one(SBF.encoding(Bool.and(Nat.is_lt(0n, 1281n), Nat.is_eq(_, 1281n)), List.append(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))])), Some{Nat.div(Nat.add(1281n, 7n), 8n)}) == Some{[S.Fixed{Bp.pack(List.append(&2, Bool, FB.bitsof(VS.wtake(40n, UW.SLW(TB))), [G.LB(W40(TB))]))}]} : Maybe<&2, +List<S.Part>>}
  {==}
