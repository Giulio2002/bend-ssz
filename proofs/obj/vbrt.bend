import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../spec/primitives.bend as SP
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vbitl.bend as VBL
import ./vbyte_generated.bend as VY
import ./vdepth.bend as VD
import ./vlist.bend as VL

# Bit lists, runtime side: the byte the validator reads is the last byte of
# the spec's byte string, and copy_in of an arbitrary length at a word-aligned
# offset.

def BF(t: F.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{F.array__thaw(U32, t), n}

def rdw(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(BF(t, n), q) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), q), (F.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, q, i, eq, hd, hi, pf)) :
    {B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  {==}

def QX(+X: U32) -> Nat: U32.to_nat(U32.shrn(X, 2n))
def RX(+X: U32) -> Nat: U32.to_nat(U32.and(X, 3))
def VX(+t: F.array__Tree<U32>, +X: U32) -> U32: B.byte_sel(U32.and(X, 3), VB.slot(t, QX(X)))

# The byte the runtime reads at X.
def byte_at_ok(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +X: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(QX(X), VB.pw(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.byte_at(BF(t, n), X) == (BF(t, n), VX(t, X)) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.shrn(X, 2n)), (BF(t, n), VB.slot(t, QX(X))), rdw(d, t, n, U32.shrn(X, 2n), QX(X), {==}, hd, hi, pf)) :
    {B.byte_pick(U32.and(X, 3), _) == (BF(t, n), VX(t, X)) : B.Buf & U32}
  {==}

def bsN(r: Nat, +x: U32) -> U32:
  match r:
    case 0n: B.byte_sel(0, x)
    case 1n: B.byte_sel(1, x)
    case 2n: B.byte_sel(2, x)
    case 3n+s: B.byte_sel(3, x)

def bs_eq(+j: U32, +x: U32, +k: Nat, +e: {U32.to_nat(j) == k : Nat}, +hk: {Nat.is_lt(k, 4n) == True{} : Bool})
    -> {B.byte_sel(j, x) == bsN(k, x) : U32}:
  match k:
    case 0n:
      %Equal.sym(U32, j, 0, F.u32__injective(j, 0, e)) : {B.byte_sel(_, x) == bsN(0n, x) : U32}
      {==}
    case 1n:
      %Equal.sym(U32, j, 1, F.u32__injective(j, 1, e)) : {B.byte_sel(_, x) == bsN(1n, x) : U32}
      {==}
    case 2n:
      %Equal.sym(U32, j, 2, F.u32__injective(j, 2, e)) : {B.byte_sel(_, x) == bsN(2n, x) : U32}
      {==}
    case 3n:
      %Equal.sym(U32, j, 3, F.u32__injective(j, 3, e)) : {B.byte_sel(_, x) == bsN(3n, x) : U32}
      {==}
    case 4n+s: Empty.absurd({B.byte_sel(j, x) == bsN(4n+s, x) : U32}, F.nat__lt_zero_absurd(s, hk))

def bs0(+r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}) -> {0 == bsN(r, 0) : U32}:
  match r:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+s: Empty.absurd({0 == bsN(4n+s, 0) : U32}, F.nat__lt_zero_absurd(s, hr))

def nl0(+x: U32, +T: List<&2, U32>, +r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool})
    -> {VBL.nthb(FX.limbs(Con{x, T}), r) == bsN(r, x) : U32}:
  match r:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+s: Empty.absurd({VBL.nthb(FX.limbs(Con{x, T}), 4n+s) == bsN(4n+s, x) : U32}, F.nat__lt_zero_absurd(s, hr))

# Byte 4 q + r of the limbs of a word list is byte r of word q.
law nth_limbs:
  for +S: List<&2, U32>
  for +q: Nat
  for +r: Nat
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  {VBL.nthb(FX.limbs(S), Nat.add(A.quad(q), r)) == bsN(r, F.flat__nthc(S, q)) : U32}
def nth_limbs(S, q, r, hr):
  match S q:
    case Nil{} _: bs0(r, hr)
    case Con{+x, +T} 0n: nl0(x, T, r, hr)
    case Con{+x, +T} 1n+ +p: nth_limbs(T, p, r, hr)

law nth_bt:
  for +L: Nat
  for +xs: +List<U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, L) == True{} : Bool}
  {VBL.nthb(VS.bt(L, xs), k) == VBL.nthb(xs, k) : U32}
def nth_bt(L, xs, k, hk):
  match L xs k:
    case 0n _ _: Empty.absurd({VBL.nthb(VS.bt(0n, xs), k) == VBL.nthb(xs, k) : U32}, F.nat__lt_zero_absurd(k, hk))
    case 1n+ +p Nil{} _: {==}
    case 1n+ +p Con{+h, +t} 0n: {==}
    case 1n+ +p Con{+h, +t} 1n+ +j: nth_bt(p, t, j, hk)

law nth_bdr:
  for +P: Nat
  for +xs: +List<U32>
  for +k: Nat
  {VBL.nthb(VS.bdr(P, xs), k) == VBL.nthb(xs, Nat.add(P, k)) : U32}
def nth_bdr(P, xs, k):
  match P xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: nth_bdr(p, t, k)

law bdr_len:
  for +P: Nat
  for +xs: +List<U32>
  for +k: Nat
  for +h: {Nat.is_le(Nat.add(P, k), List.length(&2, U32, xs)) == True{} : Bool}
  {Nat.is_le(k, List.length(&2, U32, VS.bdr(P, xs))) == True{} : Bool}
def bdr_len(P, xs, k, h):
  match P xs:
    case 0n _: h
    case 1n+ +p Nil{}: Empty.absurd({Nat.is_le(k, List.length(&2, U32, VS.bdr(1n+p, Nil{}))) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: bdr_len(p, t, k, h)

def last_len(+bs: +List<U32>, +m: Nat, +e: {List.length(&2, U32, bs) == 1n+m : Nat}) -> {VBL.lastb(bs) == VBL.nthb(bs, m) : U32}:
  match bs:
    case Nil{}: Empty.absurd({VBL.lastb(Nil{}) == VBL.nthb(Nil{}, m) : U32}, F.nat__zero_succ(m, e))
    case Con{+v, +t}:
      %F.nat__succ_inj(List.length(&2, U32, t), m, e) : {VBL.lastb(v <> t) == VBL.nthb(v <> t, _) : U32}
      VBL.lastb_nth(t, v)

law len_eq:
  for +W: List<&2, U32>
  {List.length(&2, U32, W) == F.spec_common__length(U32, W) : Nat}
def len_eq(W):
  match W:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), F.spec_common__length(U32, t), len_eq(t)) : {1n+_ == 1n+F.spec_common__length(U32, t) : Nat}
      {==}

def SL(t: F.array__Tree<U32>) -> List<&2, U32>: F.array__slots(U32, t)

def lenS(+d: Nat, +t: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, FX.limbs(SL(t))) == A.quad(VB.pw(d)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), FX.wlen(SL(t)), VS.len_limbs(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, FX.wlen(SL(t)), A.quad(List.length(&2, U32, SL(t))), VS.wlen_quad(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, SL(t)), VB.pw(d), Equal.trans(Nat, List.length(&2, U32, SL(t)), F.spec_common__length(U32, SL(t)), VB.pw(d), len_eq(SL(t)), F.array__slots_length(U32, d, t, pf))) : {A.quad(_) == A.quad(VB.pw(d)) : Nat}
  {==}

# The spec's bytes of the window [4 i, 4 i + L) of the buffer.
def WB(+t: F.array__Tree<U32>, +i: Nat, +L: Nat) -> +List<U32>: VS.bt(L, VS.bdr(A.quad(i), FX.limbs(SL(t))))

def lenWB(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +L: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), L), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, WB(t, i, L)) == L : Nat}:
  VS.bt_len(L, VS.bdr(A.quad(i), FX.limbs(SL(t))), bdr_len(A.quad(i), FX.limbs(SL(t)), L,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), L), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, FX.limbs(SL(t))),
      Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), A.quad(VB.pw(d)), lenS(d, t, pf)), hw)))

# The window's last spec byte is the byte the runtime reads at X = 4 i + m.
def lastWB(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +m: Nat, +X: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), 1n+m), A.quad(VB.pw(d))) == True{} : Bool},
    +eX: {U32.to_nat(X) == Nat.add(A.quad(i), m) : Nat})
    -> {VBL.lastb(WB(t, i, 1n+m)) == VX(t, X) : U32}:
  +hr = F.nat__le_lt_trans(RX(X), 3n, 4n, RD.and_le(X, 3), {==})
  %Equal.sym(U32, VBL.lastb(WB(t, i, 1n+m)), VBL.nthb(WB(t, i, 1n+m), m), last_len(WB(t, i, 1n+m), m, lenWB(d, t, i, 1n+m, pf, hw))) : {_ == VX(t, X) : U32}
  %Equal.sym(U32, VBL.nthb(WB(t, i, 1n+m), m), VBL.nthb(VS.bdr(A.quad(i), FX.limbs(SL(t))), m), nth_bt(1n+m, VS.bdr(A.quad(i), FX.limbs(SL(t))), m, F.nat__lt_succ(m))) :
    {_ == VX(t, X) : U32}
  %Equal.sym(U32, VBL.nthb(VS.bdr(A.quad(i), FX.limbs(SL(t))), m), VBL.nthb(FX.limbs(SL(t)), Nat.add(A.quad(i), m)), nth_bdr(A.quad(i), FX.limbs(SL(t)), m)) :
    {_ == VX(t, X) : U32}
  %eX : {VBL.nthb(FX.limbs(SL(t)), _) == VX(t, X) : U32}
  %Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(QX(X)), RX(X)), VC.split4(X)) : {VBL.nthb(FX.limbs(SL(t)), _) == VX(t, X) : U32}
  %Equal.sym(U32, VBL.nthb(FX.limbs(SL(t)), Nat.add(A.quad(QX(X)), RX(X))), bsN(RX(X), VB.slot(t, QX(X))), nth_limbs(SL(t), QX(X), RX(X), hr)) :
    {_ == VX(t, X) : U32}
  Equal.sym(U32, B.byte_sel(U32.and(X, 3), VB.slot(t, QX(X))), bsN(RX(X), VB.slot(t, QX(X))), bs_eq(U32.and(X, 3), VB.slot(t, QX(X)), RX(X), {==}, hr))

law dom_bt:
  for +L: Nat
  for +xs: +List<U32>
  for +h: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.bytes_domain(VS.bt(L, xs)) == True{} : Bool}
def dom_bt(L, xs, h):
  match L xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}:
      F.logic__and_intro(U32.is_lt(x, 256), SP.bytes_domain(VS.bt(p, t)), F.logic__and_left(U32.is_lt(x, 256), SP.bytes_domain(t), h),
        dom_bt(p, t, F.logic__and_right(U32.is_lt(x, 256), SP.bytes_domain(t), h)))

law dom_bdr:
  for +P: Nat
  for +xs: +List<U32>
  for +h: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.bytes_domain(VS.bdr(P, xs)) == True{} : Bool}
def dom_bdr(P, xs, h):
  match P xs:
    case 0n _: h
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}: dom_bdr(p, t, F.logic__and_right(U32.is_lt(x, 256), SP.bytes_domain(t), h))

def domWB(+t: F.array__Tree<U32>, +i: Nat, +L: Nat) -> {SP.bytes_domain(WB(t, i, L)) == True{} : Bool}:
  dom_bt(L, VS.bdr(A.quad(i), FX.limbs(SL(t))), dom_bdr(A.quad(i), FX.limbs(SL(t)), FX.domain_limbs(SL(t))))

# blen of a byte string of length 1 + m.
def blen_m(+bs: +List<U32>, +m: Nat, +e: {List.length(&2, U32, bs) == 1n+m : Nat})
    -> {VBL.blen(bs) == Nat.add(VS.x8(m), VY.hb(VBL.lastb(bs))) : Nat}:
  match bs:
    case Nil{}: Empty.absurd({VBL.blen(Nil{}) == Nat.add(VS.x8(m), VY.hb(VBL.lastb(Nil{}))) : Nat}, F.nat__zero_succ(m, e))
    case Con{+v, +t}:
      %F.nat__succ_inj(List.length(&2, U32, t), m, e) : {VBL.blen(v <> t) == Nat.add(VS.x8(_), VY.hb(VBL.lastb(v <> t))) : Nat}
      VBL.blen_eq(t, v)

# ---- copy_in of any length at a word-aligned offset --------------------------------------------

def ci_case2(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +L: U32, +dz: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +h3: {U32.and(off, 3) == 0 : U32}, +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(L, 0) == z : Bool})
    -> {O.ci_fin(n, L, O.ci_go(z, U32.and(off, 3), U32.shrn(off, 2n), VC.nwu(L), F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)))
        == (BF(t, n), O.Words{O.mask_last(L, F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}:
  match z:
    case True{}:
      +eL = F.u32alg__eq_of(L, 0, ez)
      %Equal.sym(U32, L, 0, eL) :
        {(BF(t, n), O.Words{O.mask_last(_, F.array__thaw(U32, VC.ZT(dz))), _}) == (BF(t, n), O.Words{O.mask_last(_, F.array__thaw(U32, VB.mone(VC.NW(_), i, 0n, dz, VC.ZT(dz), t))), _}) : B.Buf & O.Words}
      {==}
    case False{}:
      %Equal.sym(U32, U32.and(off, 3), 0, h3) :
        {O.ci_fin(n, L, O.ci_pick(_, U32.shrn(off, 2n), VC.nwu(L), F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)))
          == (BF(t, n), O.Words{O.mask_last(L, F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.acopy(VC.nwu(L), U32.shrn(off, 2n), 0, F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)),
          (F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t)), F.array__thaw(U32, t)),
          VB.acopy_ok(VC.nwu(L), U32.shrn(off, 2n), 0, i, 0n, dz, d, VC.ZT(dz), t, ei, {==}, hdz, hd, hs, hr, F.array__trep_perfect(U32, dz, 0), pf)) :
        {O.ci_fin(n, L, _) == (BF(t, n), O.Words{O.mask_last(L, F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
      {==}

# copy_in of L bytes at a word-aligned offset copies ceil(L / 4) words and masks the last one.
law copy_in_ok2:
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
  for +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  {O.copy_in(BF(t, n), off, L) == (BF(t, n), O.Words{O.mask_last(L, F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
def copy_in_ok2(d, t, n, off, i, L, dz, pf, hd, hdz, ez, h3, ei, hs, hr):
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.WZ(L))), Array.new(U32, dz, 0), ez) :
    {O.copy_into(BF(t, n), off, L, _) == (BF(t, n), O.Words{O.mask_last(L, F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
  %Equal.sym(Array<U32>, Array.new(U32, dz, 0), F.array__thaw(U32, VC.ZT(dz)), F.array__new(U32, dz, 0)) :
    {O.copy_into(BF(t, n), off, L, _) == (BF(t, n), O.Words{O.mask_last(L, F.array__thaw(U32, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
  ci_case2(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hs, hr, U32.is_eq(L, 0), {==})

# ---- lengths ---------------------------------------------------------------------------------

def lt_u32(+a: U32, +b: U32) -> {U32.is_lt(a, b) == Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), F.u32__u32_cmp(a, b)) : {Cmp.is_lt(_) == Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) : Bool}
  {==}

def pos1(+n: U32, +h: {U32.is_lt(0, n) == True{} : Bool}) -> {Nat.is_le(1n, U32.to_nat(n)) == True{} : Bool}:
  F.nat__lt_succ_le_succ(0n, U32.to_nat(n), F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(0, n), Nat.is_lt(0n, U32.to_nat(n)), lt_u32(0, n), h))

# n = 1 + (n - 1).
def e1n(+n: U32, +h: {Nat.is_le(1n, U32.to_nat(n)) == True{} : Bool}) -> {U32.to_nat(n) == 1n+U32.to_nat(U32.sub(n, 1)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, 1)), Nat.sub(U32.to_nat(n), 1n), F.u32__sub_nat(n, 1, h)) : {U32.to_nat(n) == 1n+_ : Nat}
  Equal.sym(Nat, Nat.add(1n, Nat.sub(U32.to_nat(n), 1n)), U32.to_nat(n), F.nat__sub_add(U32.to_nat(n), 1n, h))

def XN(+off: U32, +n: U32) -> U32: U32.sub(U32.add(off, n), 1)

# The last byte's position: 4 i + m, for a window 4 i + (1 + m) <= 4 2^d.
def eXN(+d: Nat, +off: U32, +i: Nat, +n: U32, +m: Nat, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(n)), A.quad(VB.pw(d))) == True{} : Bool},
    +e1: {U32.to_nat(n) == 1n+m : Nat})
    -> {U32.to_nat(XN(off, n)) == Nat.add(A.quad(i), m) : Nat}:
  +h0 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(2n+d)) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(n)), Nat.add(U32.to_nat(n), A.quad(i)), F.nat__add_comm(A.quad(i), U32.to_nat(n)), hw)
  +ea = VB.add_le_at(off, n, A.quad(i), 2n+d, eo, hd, h0)
  +ea2 = Equal.trans(Nat, U32.to_nat(U32.add(off, n)), Nat.add(U32.to_nat(n), A.quad(i)), 1n+Nat.add(m, A.quad(i)), ea,
    Equal.cong(Nat, Nat, z => Nat.add(z, A.quad(i)), U32.to_nat(n), 1n+m, e1))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+Nat.add(m, A.quad(i)), U32.to_nat(U32.add(off, n)), Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, A.quad(i)), ea2), F.nat__zero_le(Nat.add(m, A.quad(i))))
  %Equal.sym(Nat, U32.to_nat(XN(off, n)), Nat.sub(U32.to_nat(U32.add(off, n)), 1n), F.u32__sub_nat(U32.add(off, n), 1, h1)) : {_ == Nat.add(A.quad(i), m) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, A.quad(i)), ea2) : {Nat.sub(_, 1n) == Nat.add(A.quad(i), m) : Nat}
  %Equal.sym(Nat, Nat.sub(Nat.add(1n, Nat.add(m, A.quad(i))), 1n), Nat.add(m, A.quad(i)), F.nat__add_sub_cancel(1n, Nat.add(m, A.quad(i)))) : {_ == Nat.add(A.quad(i), m) : Nat}
  F.nat__add_comm(m, A.quad(i))

law lt_quad:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_lt(A.quad(a), A.quad(b)) == True{} : Bool}
  {Nat.is_lt(a, b) == True{} : Bool}
def lt_quad(a, b, h):
  match a b:
    case _ 0n: Empty.absurd({Nat.is_lt(a, 0n) == True{} : Bool}, F.nat__lt_zero_absurd(A.quad(a), h))
    case 0n 1n+ +q: {==}
    case 1n+ +p 1n+ +q: lt_quad(p, q, h)

# The last byte's word lies in the buffer.
def hiX(+d: Nat, +X: U32, +k: Nat, +eX: {U32.to_nat(X) == k : Nat}, +hk: {Nat.is_lt(k, A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_lt(QX(X), VB.pw(d)) == True{} : Bool}:
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(A.quad(QX(X)), z) == True{} : Bool}, Nat.add(A.quad(QX(X)), RX(X)), k,
    Equal.trans(Nat, Nat.add(A.quad(QX(X)), RX(X)), U32.to_nat(X), k, Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(QX(X)), RX(X)), VC.split4(X)), eX),
    F.nat__le_add_right(A.quad(QX(X)), RX(X)))
  lt_quad(QX(X), VB.pw(d), F.nat__le_lt_trans(A.quad(QX(X)), k, A.quad(VB.pw(d)), h1, hk))

law x8_inv:
  for +m: Nat
  for +c: Nat
  for +h: {Nat.is_le(VS.x8(m), Nat.add(VS.x8(c), 7n)) == True{} : Bool}
  {Nat.is_le(m, c) == True{} : Bool}
def x8_inv(m, c, h):
  match m c:
    case 0n _: F.nat__zero_le(c)
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: x8_inv(p, q, h)

def mul8(+m: Nat) -> {Nat.mul(8n, m) == VS.x8(m) : Nat}:
  Equal.trans(Nat, Nat.mul(8n, m), Nat.mul(m, 8n), VS.x8(m), F.lru_nat_algebra__mul_comm(8n, m), VC.x8_mul(m))

# ceil(n / 4) words for n <= 4 2^d bytes.
def nwle(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %Equal.sym(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), VC.eNW(n, VL.KK(d), VL.kk_lt(d, hd), VL.hyn(d, n, hn))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %VL.rng2_q(VB.pw(d)) : {Nat.is_le(VD.s_rng(2n, 3n+U32.to_nat(n)), _) == True{} : Bool}
  VC.rng_mono(2n, 3n+U32.to_nat(n), 3n+A.quad(VB.pw(d)), hn)

# ---- any tree depth d < 31: the same, below 2^32 ----------------------------------------------

# The last byte's position 4 i + m, for a window that ends below 2^32.
def eXNw(+off: U32, +i: Nat, +n: U32, +m: Nat, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(n)), F.spec_common__pow2(32n)) == True{} : Bool},
    +e1: {U32.to_nat(n) == 1n+m : Nat})
    -> {U32.to_nat(XN(off, n)) == Nat.add(A.quad(i), m) : Nat}:
  +h0 = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(n)), Nat.add(U32.to_nat(n), A.quad(i)), F.nat__add_comm(A.quad(i), U32.to_nat(n)), hw32)
  +ea = VB.add_lt32(off, n, A.quad(i), eo, h0)
  +ea2 = Equal.trans(Nat, U32.to_nat(U32.add(off, n)), Nat.add(U32.to_nat(n), A.quad(i)), 1n+Nat.add(m, A.quad(i)), ea,
    Equal.cong(Nat, Nat, z => Nat.add(z, A.quad(i)), U32.to_nat(n), 1n+m, e1))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+Nat.add(m, A.quad(i)), U32.to_nat(U32.add(off, n)), Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, A.quad(i)), ea2), F.nat__zero_le(Nat.add(m, A.quad(i))))
  %Equal.sym(Nat, U32.to_nat(XN(off, n)), Nat.sub(U32.to_nat(U32.add(off, n)), 1n), F.u32__sub_nat(U32.add(off, n), 1, h1)) : {_ == Nat.add(A.quad(i), m) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, A.quad(i)), ea2) : {Nat.sub(_, 1n) == Nat.add(A.quad(i), m) : Nat}
  %Equal.sym(Nat, Nat.sub(Nat.add(1n, Nat.add(m, A.quad(i))), 1n), Nat.add(m, A.quad(i)), F.nat__add_sub_cancel(1n, Nat.add(m, A.quad(i)))) : {_ == Nat.add(A.quad(i), m) : Nat}
  F.nat__add_comm(m, A.quad(i))

# ... of the whole buffer (off = 0): n is a U32, below 2^32.
def eXN0(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}) -> {U32.to_nat(XN(0, n)) == Nat.add(A.quad(0n), m) : Nat}:
  eXNw(0, 0n, n, m, {==}, VB.u32_lt(n), e1)

# ceil(n / 4) words for n <= 4 2^d bytes, the list storage bounded by 31 + n <= 2^k (k < 31) ...
def nwleB(+d: Nat, +n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %Equal.sym(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), VC.eNW(n, k, hk, hy)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %VL.rng2_q(VB.pw(d)) : {Nat.is_le(VD.s_rng(2n, 3n+U32.to_nat(n)), _) == True{} : Bool}
  VC.rng_mono(2n, 3n+U32.to_nat(n), 3n+A.quad(VB.pw(d)), hn)

# ... or by 31 + n <= UMAX (every n <= VB.NMAX).
def nwleU(+d: Nat, +n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %Equal.sym(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), VC.eNWu(n, hy)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %VL.rng2_q(VB.pw(d)) : {Nat.is_le(VD.s_rng(2n, 3n+U32.to_nat(n)), _) == True{} : Bool}
  VC.rng_mono(2n, 3n+U32.to_nat(n), 3n+A.quad(VB.pw(d)), hn)
