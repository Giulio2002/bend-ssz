import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/primitives.bend as SP
import ../../spec/bytes.bend as Bytes
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ../encoding_domain.bend as ED
import ../complete_leaves.bend as CLeaf
import ../complete_regions.bend as CReg
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vmr.bend as VMR
import ./vuw.bend as UW
import ./vcont.bend as VCN
import ./vfits.bend as VFT
import ./vuwd.bend as WD
import ./vrecx.bend as VRX
import ../../spec/nat_bytes.bend as N

# The spec side of a container's encoder window (hand-written; for codegen/var_cont_enc.py's
# interface section): a fixed piece's bytes as the region cell PC, a byte vector held in a words
# tree, the running offsets (O.padd without overflow), and a part's bytes are bytes.

# A part list of one fixed part: its bytes as the region's cell PC(k, xs).
def pcfix(+v: S.Value, +s: S.Schema, +xs: +List<U32>, +k: Nat, +hk: {List.length(&2, U32, xs) == k : Nat},
    +h: {Codec.parts(v, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(v, s) == Some{[S.Fixed{VCN.PC(k, xs)}]} : Maybe<&2, +List<S.Part>>}:
  FD.logic__subst(+List<U32>, z => {Codec.parts(v, s) == Some{[S.Fixed{z}]} : Maybe<&2, +List<S.Part>>}, xs, VCN.PC(k, xs), Equal.sym(+List<U32>, VCN.PC(k, xs), xs, VCN.pc_id(k, xs, hk)), h)

# A byte vector of n > 0 bytes, the limbs of a word list.
def bpartl(+xs: +List<U32>, +n: Nat, +en: {n == FX.wlen(xs) : Nat}, +hn: {Nat.is_lt(0n, n) == True{} : Bool},
    +fit: {Bytes.size_fits(FX.wlen(xs)) == True{} : Bool})
    -> {Codec.parts(S.BytesValue{FX.limbs(xs)}, S.ByteVector{n}) == Some{[S.Fixed{FX.limbs(xs)}]} : Maybe<&2, +List<S.Part>>}:
  match xs:
    case Nil{}:
      Empty.absurd({Codec.parts(S.BytesValue{FX.limbs([])}, S.ByteVector{n}) == Some{[S.Fixed{FX.limbs([])}]} : Maybe<&2, +List<S.Part>>},
        FD.logic__false_true(FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, n, 0n, en, hn)))
    case Con{+h, +t}: FX.bytes_part_n(h, t, n, en, fit)

# The first k words of a words tree of depth dB (k <= 2^dB), as a byte vector of 4 k bytes.
def WT(+k: Nat, +TB: FD.array__Tree<U32>) -> +List<U32>: FX.limbs(VS.wtake(k, UW.SLW(TB)))
def bvw(+k: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool},
    +hrB: {Nat.is_le(k, VB.pw(dB)) == True{} : Bool}, +hk: {Nat.is_lt(0n, A.quad(k)) == True{} : Bool},
    +fit: {Bytes.size_fits(A.quad(k)) == True{} : Bool})
    -> {Codec.parts(S.BytesValue{WT(k, TB)}, S.ByteVector{A.quad(k)}) == Some{[S.Fixed{VCN.PC(A.quad(k), WT(k, TB))}]} : Maybe<&2, +List<S.Part>>}:
  +W = UW.SLW(TB)
  +hW = FD.logic__subst(Nat, zz => {Nat.is_le(k, zz) == True{} : Bool}, VB.pw(dB), List.length(&2, U32, W),
    Equal.sym(Nat, List.length(&2, U32, W), VB.pw(dB), Equal.trans(Nat, List.length(&2, U32, W), FD.spec_common__length(U32, W), VB.pw(dB), VMR.len_eq(W), FD.array__slots_length(U32, dB, TB, pfB))), hrB)
  +eL = VCN.len_wt(k, W, hW)
  +ew = Equal.trans(Nat, A.quad(k), List.length(&2, U32, WT(k, TB)), FX.wlen(VS.wtake(k, W)), Equal.sym(Nat, List.length(&2, U32, WT(k, TB)), A.quad(k), eL), VS.len_limbs(VS.wtake(k, W)))
  pcfix(S.BytesValue{WT(k, TB)}, S.ByteVector{A.quad(k)}, WT(k, TB), A.quad(k), eL,
    bpartl(VS.wtake(k, W), A.quad(k), ew, hk, FD.logic__subst(Nat, zz => {Bytes.size_fits(zz) == True{} : Bool}, A.quad(k), FX.wlen(VS.wtake(k, W)), ew, fit)))

# One step of the running offset: a + b without overflow.
def pstep(+a: U32, +b: U32, +o: Nat, +L: Nat, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool},
    +ea: {U32.to_nat(a) == o : Nat}, +eb: {U32.to_nat(b) == L : Nat}, +hb: {Nat.is_le(Nat.add(o, L), A.quad(VB.pw(k))) == True{} : Bool})
    -> {U32.to_nat(O.padd(a, b)) == Nat.add(o, L) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(o, U32.to_nat(b)), Nat.add(o, L),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(b)), U32.to_nat(a), o, ea), Equal.cong(Nat, Nat, z => Nat.add(o, z), U32.to_nat(b), L, eb))
  Equal.trans(Nat, U32.to_nat(O.padd(a, b)), Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(o, L),
    VCN.padd_dd(a, b, k, hk, FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(k))) == True{} : Bool}, Nat.add(o, L), Nat.add(U32.to_nat(a), U32.to_nat(b)), Equal.sym(Nat, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(o, L), e1), hb)),
    e1)

# A value whose parts are one part: its bytes are bytes (the schema legal).
def domv(+v: S.Value, +s: S.Schema, +ys: +List<U32>, +legal: {CReg.region_legal(s) == True{} : Bool},
    +h: {Codec.parts(v, s) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}) -> {SP.bytes_domain(ys) == True{} : Bool}:
  FD.logic__subst(Maybe<&2, +List<S.Part>>, z => {SP.bytes_domain(CLeaf.fragment_bytes(z)) == True{} : Bool}, Codec.parts(v, s), Some{[S.Variable{ys}]}, h, ED.parts_domain(v, s, legal))
def domf(+v: S.Value, +s: S.Schema, +ys: +List<U32>, +legal: {CReg.region_legal(s) == True{} : Bool},
    +h: {Codec.parts(v, s) == Some{[S.Fixed{ys}]} : Maybe<&2, +List<S.Part>>}) -> {SP.bytes_domain(ys) == True{} : Bool}:
  FD.logic__subst(Maybe<&2, +List<S.Part>>, z => {SP.bytes_domain(CLeaf.fragment_bytes(z)) == True{} : Bool}, Codec.parts(v, s), Some{[S.Fixed{ys}]}, h, ED.parts_domain(v, s, legal))

# a <= a + b <= c, and b <= a + b <= c
def lel(+a: Nat, +b: Nat, +c: Nat, +h: {Nat.is_le(Nat.add(a, b), c) == True{} : Bool}) -> {Nat.is_le(a, c) == True{} : Bool}:
  FD.nat__le_trans(a, Nat.add(a, b), c, Order.below_sum(a, b), h)
def ler(+a: Nat, +b: Nat, +c: Nat, +h: {Nat.is_le(Nat.add(a, b), c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  FD.nat__le_trans(b, Nat.add(a, b), c, Order.left_below_sum(a, b), h)

# ---- the bound 4 2^k, k = 28, kept symbolic ----
def hk29(+k: Nat, +ek: {k == 28n : Nat}) -> {Nat.is_lt(k, 29n) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(z, 29n) == True{} : Bool}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==})
def hk30(+k: Nat, +ek: {k == 28n : Nat}) -> {Nat.is_lt(k, 30n) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(z, 30n) == True{} : Bool}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==})
def ek2(+k: Nat, +ek: {k == 28n : Nat}) -> {2n+k == 30n : Nat}: Equal.cong(Nat, Nat, z => 2n+z, k, 28n, ek)

# The bytes fit a 4-byte length: FS + |PAY| = E <= 4 2^k.
def fitc(+FS: Nat, +PAY: +List<U32>, +E: Nat, +k: Nat, +ek: {k == 28n : Nat}, +eE: {Nat.add(FS, List.length(&2, U32, PAY)) == E : Nat},
    +hb: {Nat.is_le(E, A.quad(VB.pw(k))) == True{} : Bool}) -> {N.fits(4n, Nat.add(FS, List.length(&2, U32, PAY))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, E, Nat.add(FS, List.length(&2, U32, PAY)), Equal.sym(Nat, Nat.add(FS, List.length(&2, U32, PAY)), E, eE),
    VFT.fits4(2n+k, E, hb, hk30(k, ek)))

def q30(+dd: Nat, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}) -> {Nat.is_le(A.quad(VB.pw(dd)), VB.pw(30n)) == True{} : Bool}:
  FD.nat__pow2_mono(2n+dd, 30n, FD.nat__lt_succ_le(dd, 28n, hd))
def bsuc(+x: Nat, +k: Nat, +h: {Nat.is_le(x, VB.pw(k)) == True{} : Bool}) -> {Nat.is_lt(x, VB.pw(1n+k)) == True{} : Bool}:
  FD.nat__le_lt_trans(x, VB.pw(k), VB.pw(1n+k), h, FD.nat__pow2_lt_succ(k))
def b31n(+x: Nat, +h: {Nat.is_le(x, VB.pw(30n)) == True{} : Bool}) -> {Nat.is_lt(x, VB.pw(31n)) == True{} : Bool}: bsuc(x, 30n, h)

# The runtime's X is U32.from_nat(4 q + r) when the L bytes there fit the tree.
def exqW(+X: U32, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {X == U32.from_nat(Nat.add(A.quad(q), r)) : U32}:
  +X0 = Nat.add(A.quad(q), r)
  +hx = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(X), X0, e, VB.u32_lt(X))
  FD.u32__injective(X, U32.from_nat(X0), Equal.trans(Nat, U32.to_nat(X), X0, U32.to_nat(U32.from_nat(X0)), e, Equal.sym(Nat, U32.to_nat(U32.from_nat(X0)), X0, FD.u32__to_nat_from_nat(X0, 32n, {==}, hx))))

def exq(+X: U32, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {X == U32.from_nat(Nat.add(A.quad(q), r)) : U32}:
  exqW(X, q, r, L, dd, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl)

# ---- the bound B < 2^31 (the OKW twins: an encoding below 2^31 bytes, O.padd's poison bit) ----

# pstep under a bound B < 2^31 (any bound: no power of two is compared).
def pstepB(+a: U32, +b: U32, +o: Nat, +L: Nat, +B: Nat, +hB: {Nat.is_lt(B, VB.pw(31n)) == True{} : Bool},
    +ea: {U32.to_nat(a) == o : Nat}, +eb: {U32.to_nat(b) == L : Nat}, +hb: {Nat.is_le(Nat.add(o, L), B) == True{} : Bool})
    -> {U32.to_nat(O.padd(a, b)) == Nat.add(o, L) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(o, U32.to_nat(b)), Nat.add(o, L),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(b)), U32.to_nat(a), o, ea), Equal.cong(Nat, Nat, z => Nat.add(o, z), U32.to_nat(b), L, eb))
  Equal.trans(Nat, U32.to_nat(O.padd(a, b)), Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(o, L),
    VCN.padd_ddW(a, b, 0n, {==}, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(31n)) == True{} : Bool}, Nat.add(o, L), Nat.add(U32.to_nat(a), U32.to_nat(b)), Equal.sym(Nat, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(o, L), e1),
      FD.nat__le_lt_trans(Nat.add(o, L), B, VB.pw(31n), hb, hB))),
    e1)

# x <= B < 2^a, a < 32: x fits four bytes (the exponent symbolic).
def fitsBa(+x: Nat, +B: Nat, +a: Nat, +ha: {Nat.is_lt(a, 32n) == True{} : Bool}, +hx: {Nat.is_le(x, B) == True{} : Bool}, +hB: {Nat.is_lt(B, VB.pw(a)) == True{} : Bool})
    -> {N.fits(4n, x) == True{} : Bool}:
  VFT.fits4(a, x, FD.nat__le_trans(x, B, VB.pw(a), hx, FD.nat__lt_le(B, VB.pw(a), hB)), ha)
def fitsB(+x: Nat, +B: Nat, +hx: {Nat.is_le(x, B) == True{} : Bool}, +hB: {Nat.is_lt(B, VB.pw(31n)) == True{} : Bool}) -> {N.fits(4n, x) == True{} : Bool}:
  fitsBa(x, B, 31n, {==}, hx, hB)

# fitc under a bound B < 2^31.
def fitcB(+FS: Nat, +PAY: +List<U32>, +E: Nat, +B: Nat, +hB: {Nat.is_lt(B, VB.pw(31n)) == True{} : Bool}, +eE: {Nat.add(FS, List.length(&2, U32, PAY)) == E : Nat},
    +hb: {Nat.is_le(E, B) == True{} : Bool}) -> {N.fits(4n, Nat.add(FS, List.length(&2, U32, PAY))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, E, Nat.add(FS, List.length(&2, U32, PAY)), Equal.sym(Nat, Nat.add(FS, List.length(&2, U32, PAY)), E, eE),
    fitsB(E, B, hb, hB))

# x <= B < 2^a (a < 32): x < 2^32 (the exponent symbolic in lt32Ba).
def lt32Ba(+x: Nat, +B: Nat, +a: Nat, +ha: {Nat.is_le(a, 32n) == True{} : Bool}, +hx: {Nat.is_le(x, B) == True{} : Bool}, +hB: {Nat.is_lt(B, VB.pw(a)) == True{} : Bool})
    -> {Nat.is_lt(x, FD.spec_common__pow2(32n)) == True{} : Bool}:
  FD.nat__lt_le_trans(x, VB.pw(a), FD.spec_common__pow2(32n), FD.nat__le_lt_trans(x, B, VB.pw(a), hx, hB), FD.nat__pow2_mono(a, 32n, ha))
def lt32B(+x: Nat, +B: Nat, +hx: {Nat.is_le(x, B) == True{} : Bool}, +hB: {Nat.is_lt(B, VB.pw(31n)) == True{} : Bool}) -> {Nat.is_lt(x, FD.spec_common__pow2(32n)) == True{} : Bool}:
  lt32Ba(x, B, 31n, {==}, hx, hB)
