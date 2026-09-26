#!/usr/bin/env python3
"""The codec laws of containers of word-aligned fixed fields around ONE bit
list (Attestation, PendingAttestation).

    python3 codegen/var_bitc.py [--check] [--no-big]

For each name X it writes proofs/obj/<big_>var_bitc_X{,_unique}.bend:

    ok_eval        the validator returns the buffer and CHK(t, n): the fixed
                   part is there, the offset is the fixed size FS, and the
                   window [FS, n) passes the bit-list checks (non-empty, a
                   non-zero last byte, at most N bits);
    decode_accept  then the decoder returns Some{OBJ(t, n)}: the fixed fields'
                   words and the bit list O.Bits{clear_bit(mask_last(copy)), k}
                   with k the delimiter's position;
    decode_none    otherwise None;
    decode_spec    and the buffer's bytes are the spec encoding of VAL(t, n),
                   whose bit list is the window's bits cut before its last
                   byte's highest set bit (vbitl.bl);
    decode_unique  every spec value of those bytes is VAL(t, n).

for every buffer on a perfect word tree of depth d < 28 with n <= 4 2^d. A name
whose bit limit is 2^16 or more goes to big_* (the limit is a closed number in
the laws' types). Libraries: proofs/obj/v{bitl,brt,bitc}.bend, vbyte.bend.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import schema  # noqa: E402
import spec_laws as SL  # noqa: E402
import var_laws as VL  # noqa: E402

ROOT = VL.ROOT
NAMES = VL.BITC


def ceil_log2(x):
    return max(0, (x - 1).bit_length())


class BName:
    def __init__(self, g, n, t):
        self.n, self.t = n, t
        self.fields = []
        pos = 0
        var = None
        for fname, ft in t.fields:
            if ft.fixed():
                f = VL.FT(g, ft)
                self.fields.append({'kind': 'fix', 'name': fname, 'ft': f, 'c': pos, 'k': pos // 4, 't': ft})
                pos += f.size
            else:
                s = g.shape(ft)
                if ft.kind != 'bitlist':
                    raise VL.Skip('variable field is not a bit list')
                if var is not None:
                    raise VL.Skip('more than one variable field')
                var = {'kind': 'bits', 'name': fname, 'c': pos, 'k': pos // 4, 'N': ft.size, 'p': s.p, 't': ft}
                self.fields.append(var)
                pos += 4
        assert var is not None and pos % 4 == 0
        self.FS, self.H, self.po, self.N, self.p = pos, pos // 4, var['k'], var['N'], var['p']
        self.C = self.N // 8
        self.BMAX = self.C + 1
        self.YMAX = 31 + self.BMAX
        self.K = ceil_log2((self.YMAX >> 2) + 8)


def is_big(x):
    return x.N >= 1 << 16


def fname(x, part=''):
    return ROOT / f'proofs/obj/{"big_" if is_big(x) else ""}var_bitc_{x.n}{part}.bend'


HEAD = list(VL.DEC_HEAD) + ['import ./spec_bits.bend as FB', 'import ./vfits.bend as VFT', 'import ./vlist.bend as VLS', 'import ./vbitl.bend as VBL',
                            'import ./vbyte.bend as VY', 'import ./vbrt.bend as VR', 'import ./vbitc.bend as VBC',
                            'import ../../spec/bitfields.bend as Bits', 'import ../../spec/bit_packing.bend as Bp']

CORE = r"""
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)
def SPO(t: FD.array__Tree<U32>) -> U32: VB.slot(t, @POn)
def LL(+n: U32) -> U32: U32.sub(n, @FS)
def OW() -> U32: U32.add(0, @FS)
def XW(+n: U32) -> U32: VR.XN(OW(), LL(n))
def VWB(+t: FD.array__Tree<U32>, +n: U32) -> U32: VR.VX(t, XW(n))
def M1(+n: U32) -> Nat: U32.to_nat(U32.sub(LL(n), 1))
def BD(+t: FD.array__Tree<U32>, +n: U32) -> Nat: Nat.add(Nat.mul(8n, M1(n)), U32.to_nat(O.high_bit(VWB(t, n))))

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def chkw(a: Bool, +t: FD.array__Tree<U32>, +n: U32) -> Bool:
  match a:
    case False{}: False{}
    case True{}: O.bsel(U32.is_eq(VWB(t, n), 0), False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))))

# The window [@FS, n) passes the bit-list checks.
def CHKW(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chkw(U32.is_lt(0, LL(n)), t, n)
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chk3(U32.is_le(@FS, n), U32.is_eq(SPO(t), @FS), CHKW(t, n))

def leFS(+n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}) -> {Nat.is_le(@FSn, U32.to_nat(n)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, n), Nat.is_le(@FSn, U32.to_nat(n)), VU.le_u32(@FS, n), ha)

def enFS(+n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}) -> {Nat.add(@FSn, U32.to_nat(LL(n))) == U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(LL(n)), Nat.sub(U32.to_nat(n), @FSn), FD.u32__sub_nat(n, @FS, leFS(n, ha))) : {Nat.add(@FSn, _) == U32.to_nat(n) : Nat}
  FD.nat__sub_add(U32.to_nat(n), @FSn, leFS(n, ha))

# The window lies in the buffer: 4 H + L <= 4 2^d.
def hwL(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), Nat.add(@FSn, U32.to_nat(LL(n))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha)), hn)

def hLd(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(LL(n)), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(LL(n)), Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(@Hn), U32.to_nat(LL(n))), hwL(d, n, ha, hn))

# The header words k < H lie in the buffer.
def hk(+d: Nat, +n: U32, +k: Nat, +hkH: {Nat.is_lt(k, @Hn) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_lt(k, VB.pw(d)) == True{} : Bool}:
  FD.nat__lt_le_trans(k, @Hn, VB.pw(d), hkH, FD.nat__le_trans(@Hn, Nat.add(VC.NW(LL(n)), @Hn), VB.pw(d), Order.left_below_sum(VC.NW(LL(n)), @Hn), VBC.nwH(d, LL(n), @Hn, hd, hwL(d, n, ha, hn))))

def hlt(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat})
    -> {Nat.is_lt(Nat.add(A.quad(@Hn), M1(n)), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__lt_le_trans(Nat.add(A.quad(@Hn), M1(n)), Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d)),
    FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(@Hn), M1(n)), Nat.add(A.quad(@Hn), z)) == True{} : Bool}, 1n+M1(n), U32.to_nat(LL(n)), Equal.sym(Nat, U32.to_nat(LL(n)), 1n+M1(n), e1),
      FD.nat__lt_add_left(M1(n), 1n+M1(n), A.quad(@Hn), FD.nat__lt_succ(M1(n)))),
    hwL(d, n, ha, hn))

def eXW(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +ha: {U32.is_le(@FS, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat})
    -> {U32.to_nat(XW(n)) == Nat.add(A.quad(@Hn), M1(n)) : Nat}:
  VR.eXN(d, OW(), @Hn, LL(n), M1(n), {==}, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hwL(d, n, ha, hn), e1)

def hiW(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +ha: {U32.is_le(@FS, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat})
    -> {Nat.is_lt(VR.QX(XW(n)), VB.pw(d)) == True{} : Bool}:
  VR.hiX(d, XW(n), Nat.add(A.quad(@Hn), M1(n)), eXW(d, n, hd, ha, hn, e1), hlt(d, n, ha, hn, e1))

# ---- the validator ----------------------------------------------------------------------------

def okw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +a: Bool, +ea: {U32.is_lt(0, LL(n)) == a : Bool})
    -> {T.@p_ok(BF(t, n), OW(), LL(n)) == (BF(t, n), chkw(a, t, n)) : B.Buf & Bool}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_lt(0, LL(n)), False{}, ea) : {O.bitlist_nz(_, BF(t, n), OW(), LL(n), @N, False{}) == (BF(t, n), False{}) : B.Buf & Bool}
      {==}
    case True{}:
      +e1 = VR.e1n(LL(n), VR.pos1(LL(n), ea))
      %Equal.sym(Bool, U32.is_lt(0, LL(n)), True{}, ea) : {O.bitlist_nz(_, BF(t, n), OW(), LL(n), @N, False{}) == (BF(t, n), chkw(True{}, t, n)) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), XW(n)), (BF(t, n), VWB(t, n)),
          VR.byte_at_ok(d, t, n, XW(n), VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hiW(d, n, hd, ha, hn, e1), pf)) :
        {O.bitlist_pick(LL(n), @N, False{}, _) == (BF(t, n), chkw(True{}, t, n)) : B.Buf & Bool}
      {==}

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {T.@X_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def ok_c0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(SPO(t), @FS) == b : Bool})
    -> {T.@X_c0(b, BF(t, n), 0, n, SPO(t)) == (BF(t, n), chk3(True{}, b, CHKW(t, n))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +epo = FD.u32alg__eq_of(SPO(t), @FS, eb)
      %Equal.sym(U32, SPO(t), @FS, epo) :
        {T.@X_v1(0, n, _, T.@p_ok(BF(t, n), U32.add(0, _), U32.sub(n, _))) == (BF(t, n), CHKW(t, n)) : B.Buf & Bool}
      %Equal.sym(B.Buf & Bool, T.@p_ok(BF(t, n), OW(), LL(n)), (BF(t, n), CHKW(t, n)), okw(d, t, n, pf, hd, ha, hn, U32.is_lt(0, LL(n)), {==})) :
        {T.@X_v1(0, n, @FS, _) == (BF(t, n), CHKW(t, n)) : B.Buf & Bool}
      c1_id(CHKW(t, n), BF(t, n), 0, n, @FS)

def ok_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +a: Bool, +ea: {U32.is_le(@FS, n) == a : Bool})
    -> {T.@X_ok_len(a, BF(t, n), 0, n) == (BF(t, n), chk3(a, U32.is_eq(SPO(t), @FS), CHKW(t, n))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(0, @CV)), (VF.BF(t, n), SPO(t)),
          VF.rd32a(d, t, n, U32.add(0, @CV), @POn, {==}, VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hk(d, n, @POn, {==}, hd, ea, hn), pf)) :
        {T.@X_v0(0, n, _) == (BF(t, n), chk3(True{}, U32.is_eq(SPO(t), @FS), CHKW(t, n))) : B.Buf & Bool}
      ok_c0(d, t, n, pf, hd, ea, hn, U32.is_eq(SPO(t), @FS), {==})

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {T.@X_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  ok_len(d, t, n, pf, hd, hn, U32.is_le(@FS, n), {==})

# ---- facts of accepted buffers -----------------------------------------------------------------

def ch_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def ch_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def ch_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{}: h

def cwA(+a: Bool, +t: FD.array__Tree<U32>, +n: U32, +h: {chkw(a, t, n) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def bselF(+c: Bool, +y: Bool, +h: {O.bsel(c, False{}, y) == True{} : Bool}) -> {c == False{} : Bool}:
  match c:
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(h))
    case False{}: {==}

def cw1(+t: FD.array__Tree<U32>, +n: U32, +h: {CHKW(t, n) == True{} : Bool}) -> {chkw(True{}, t, n) == True{} : Bool}:
  FD.logic__subst(Bool, z => {chkw(z, t, n) == True{} : Bool}, U32.is_lt(0, LL(n)), True{}, cwA(U32.is_lt(0, LL(n)), t, n, h), h)

def cwB(+t: FD.array__Tree<U32>, +n: U32, +h: {chkw(True{}, t, n) == True{} : Bool}) -> {U32.is_eq(VWB(t, n), 0) == False{} : Bool}:
  bselF(U32.is_eq(VWB(t, n), 0), O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))), h)

def cwC(+t: FD.array__Tree<U32>, +n: U32, +h: {chkw(True{}, t, n) == True{} : Bool}, +nz: {U32.is_eq(VWB(t, n), 0) == False{} : Bool})
    -> {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(VWB(t, n), 0), False{}, nz, h)

def cwE(+t: FD.array__Tree<U32>, +n: U32, +h: {CHKW(t, n) == True{} : Bool}) -> {U32.to_nat(LL(n)) == 1n+M1(n) : Nat}:
  VR.e1n(LL(n), VR.pos1(LL(n), cwA(U32.is_lt(0, LL(n)), t, n, h)))

# L <= @BMAX: the checks bound the window.
def hB(+t: FD.array__Tree<U32>, +n: U32, +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat}, +bd: {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}:
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(VWB(t, n)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, M1(n)), VS.x8(M1(n)), VR.mul8(M1(n)), bd)
  +h8 = FD.nat__le_trans(VS.x8(M1(n)), Nat.add(VS.x8(M1(n)), U32.to_nat(O.high_bit(VWB(t, n)))), Nat.add(VS.x8(@Cn), 7n), FD.nat__le_add_right(VS.x8(M1(n)), U32.to_nat(O.high_bit(VWB(t, n)))),
    FD.nat__le_trans(Nat.add(VS.x8(M1(n)), U32.to_nat(O.high_bit(VWB(t, n)))), U32.to_nat(@N), Nat.add(VS.x8(@Cn), 7n), bd1, {==}))
  %Equal.sym(Nat, U32.to_nat(LL(n)), 1n+M1(n), e1) : {Nat.is_le(_, @BMAXn) == True{} : Bool}
  VR.x8_inv(M1(n), @Cn, h8)

def hdzK(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hL: {Nat.is_le(U32.to_nat(LL(n)), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(LL(n)), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(LL(n)), @Kn,
    FD.nat__le_trans(U32.to_nat(VC.WZ(LL(n))), Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), O.pow2n(@Kn),
      VC.wz_le(LL(n), VLS.KK(d), VLS.kk_lt(d, hd), VLS.hyn(d, LL(n), hL)),
      FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
        Order.add_right(VD.s_rng(2n, VC.YL(LL(n))), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(LL(n)), @YMAXn, Order.add_left(31n, U32.to_nat(LL(n)), @BMAXn, hb))),
        {==})))
"""


def zeros_at_text(KK):
    L = [f'def zeros_at(+du: U32, +k: Nat, +e: {{U32.to_nat(du) == k : Nat}}, +hk: {{Nat.is_le(k, {KK}n) == True{{}} : Bool}})',
         '    -> {B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}:', '  match k:']
    for j in range(KK + 1):
        L.append(f'    case {j}n:')
        L.append(f'      %Equal.sym(U32, du, {j}, FD.u32__injective(du, {j}, e)) : {{B.zeros(_) == Array.new(U32, {j}n, 0) : Array<U32>}}')
        L.append('      {==}')
    L.append(f'    case {KK + 1}n+p: Empty.absurd({{B.zeros(du) == Array.new(U32, {KK + 1}n+p, 0) : Array<U32>}}, FD.logic__false_true(hk))')
    return '\n'.join(L) + '\n'


def subst(txt, x):
    for k, v in [('@BMAXn', f'{x.BMAX}n'), ('@YMAXn', f'{x.YMAX}n'), ('@Cn', f'{x.C}n'), ('@Kn', f'{x.K}n'), ('@POn', f'{x.po}n'), ('@Pn', f'{4 * x.po}n'),
                 ('@FSn', f'{x.FS}n'), ('@FS', str(x.FS)), ('@Hn', f'{x.H}n'), ('@CV', str(4 * x.po)), ('@N', str(x.N)),
                 ('@X_', f'{x.n}_'), ('@p_', f'{x.p}_')]:
        txt = txt.replace(k, v)
    return txt


def dec_text(g, x):
    n, FS, H, po = x.n, x.FS, x.H, x.po
    Tn = f'T.{n}'
    L = list(HEAD) + ['', '# GENERATED by codegen/var_bitc.py. Do not edit.',
                      f'# {n}: fixed fields around one bit list; the validator, the decoder and the',
                      '# spec relation (see the module docstring of codegen/var_bitc.py).', '']
    w = L.append
    w(subst(CORE, x))
    w(zeros_at_text(x.K))
    # ---- the reader ----
    NWt = 'VC.NW(LL(n))'
    objs = []
    for f in x.fields:
        if f['kind'] == 'fix':
            objs.append(f['ft'].obj([f'VB.slot(t, {f["k"] + j}n)' for j in range(f['ft'].W)]))
        else:
            objs.append(f'O.Bits{{O.clear_bit(O.mask_last(LL(n), FD.array__thaw(U32, VB.mone({NWt}, {H}n, 0n, dz, VC.ZT(dz), t))), NBW(t, n)), NBW(t, n)}}')
    OBJz = f'{Tn}{{' + ', '.join(objs) + '}'
    RHS = f'(BF(t, n), {OBJz})'
    TY = f'B.Buf & {Tn}'
    w('def NBW(+t: FD.array__Tree<U32>, +n: U32) -> U32: U32.add(U32.mul(8, U32.sub(LL(n), 1)), O.high_bit(VWB(t, n)))')
    w('')
    w('# The reader returns the object of the buffer words (bit list storage: depth dz).')
    w('def rd_ok(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +dz: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},')
    w('    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},')
    w(f'    +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}, +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +epo: {{SPO(t) == {FS} : U32}},')
    w('    +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat},')
    w('    +ez: {B.zeros(B.words_depth_u(VC.WZ(LL(n)))) == Array.new(U32, dz, 0) : Array<U32>},')
    w('    +hr0: {Nat.is_le(Nat.add(VC.NW(LL(n)), 0n), VB.pw(dz)) == True{} : Bool})')
    w(f'    -> {{{Tn}_read(BF(t, n), 0, n) == {RHS} : {TY}}}:')
    w('  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})')
    w('  +hd32 = VB.lt32(d, hd31)')
    w(f'  +hs = VBC.nwH(d, LL(n), {H}n, hd, hwL(d, n, ha, hn))')
    w(f'  +hHi = FD.nat__le_trans({H}n, Nat.add({NWt}, {H}n), VB.pw(d), Order.left_below_sum({NWt}, {H}n), hs)')
    w(f'  %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(0, {4 * po})), (VF.BF(t, n), SPO(t)),')
    w(f'      VF.rd32a(d, t, n, U32.add(0, {4 * po}), {po}n, {{==}}, hd32, hk(d, n, {po}n, {{==}}, hd, ha, hn), pf)) :')
    w(f'    {{{Tn}_rd0(0, n, _) == {RHS} : {TY}}}')

    def read_term(f, o):
        if f['kind'] == 'fix':
            ft = f['ft']
            return f'T.{ft.p}_read(BF(t, n), U32.add(0, {f["c"]}), {ft.size})'
        return f'T.{x.p}_read(BF(t, n), U32.add(0, {o}), U32.sub(n, {o}))'
    w(f'  %Equal.sym(U32, SPO(t), {FS}, epo) :')
    w(f'    {{{Tn}_rd1(0, n, _, {read_term(x.fields[0], "_")}) == {RHS} : {TY}}}')
    for j, f in enumerate(x.fields):
        args = ', '.join(['0', 'n', f'{FS}'] + objs[:j])
        if f['kind'] == 'fix':
            ft = f['ft']
            hb = (f'FD.nat__le_trans(Nat.add({ft.W}n, {f["k"]}n), {H}n, VB.pw(d), {{==}}, hHi)')
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {read_term(f, FS)}, (BF(t, n), {objs[j]}),')
            w(f'      VT.rd_{ft.p}(d, t, n, U32.add(0, {f["c"]}), {f["k"]}n, {{==}}, FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}), pf, {hb})) :')
            w(f'    {{{Tn}_rd{j + 1}({args}, _) == {RHS} : {TY}}}')
        else:
            w(f'  %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), XW(n)), (BF(t, n), VWB(t, n)), VR.byte_at_ok(d, t, n, XW(n), hd32, hiW(d, n, hd, ha, hn, e1), pf)) :')
            w(f'    {{{Tn}_rd{j + 1}({args}, O.bits_from(LL(n), OW(), _)) == {RHS} : {TY}}}')
            w(f'  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), OW(), LL(n)), (BF(t, n), O.Words{{O.mask_last(LL(n), FD.array__thaw(U32, VB.mone({NWt}, {H}n, 0n, dz, VC.ZT(dz), t))), LL(n)}}),')
            w(f'      VR.copy_in_ok2(d, t, n, OW(), {H}n, LL(n), dz, pf, hd31, hdz, ez, {{==}}, {{==}}, FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(d)) == True{{}} : Bool}}, Nat.add({NWt}, {H}n), Nat.add({NWt}, {H}n), {{==}}, hs), hr0)) :')
            w(f'    {{{Tn}_rd{j + 1}({args}, O.bits_clear(NBW(t, n), _)) == {RHS} : {TY}}}')
    w('  {==}')
    w('')
    OBJ = OBJz.replace('dz', 'VLS.DZ(LL(n))')
    D = f'B.Buf & Maybe<&1, {Tn}>'
    w(f'def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> {Tn}: {OBJ}')
    w(subst(f'''
def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hchk: {{CHK(t, n) == True{{}} : Bool}},
    +ha: {{U32.is_le(@FS, n) == True{{}} : Bool}}, +epo: {{SPO(t) == @FS : U32}}, +hw: {{CHKW(t, n) == True{{}} : Bool}})
    -> {{{Tn}_decode(BF(t, n), n) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}:
  +e1 = cwE(t, n, hw)
  +h1 = cw1(t, n, hw)
  +hL = hLd(d, n, ha, hn)
  +hz = hdzK(d, n, hd, hL, hB(t, n, e1, cwC(t, n, h1, cwB(t, n, h1))))
  +ez = zeros_at(B.words_depth_u(VC.WZ(LL(n))), VLS.DZ(LL(n)), VD.wdu(VC.WZ(LL(n))), hz)
  %Equal.sym(B.Buf & Bool, {Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {{{Tn}_built(n, _) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
  %Equal.sym(Bool, CHK(t, n), True{{}}, hchk) :
    {{{Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
  %Equal.sym(B.Buf & {Tn}, {Tn}_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)),
      rd_ok(d, t, n, VLS.DZ(LL(n)), pf, hd, FD.nat__le_lt_trans(VLS.DZ(LL(n)), @Kn, 31n, hz, {{==}}), ha, hn, epo, e1, ez, VLS.hrg(d, LL(n), hd, hL))) :
    {{{Tn}_some(_) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
  {{==}}

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  {{{Tn}_decode(BF(t, n), n) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(@FS, n)
  +b = U32.is_eq(SPO(t), @FS)
  +c = CHKW(t, n)
  acc_go(d, t, n, pf, hd, hn, hchk, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPO(t), @FS, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{CHK(t, n) == False{{}} : Bool}}
  {{{Tn}_decode(BF(t, n), n) == (BF(t, n), None{{}}) : {D}}}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, {Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {{{Tn}_built(n, _) == (BF(t, n), None{{}}) : {D}}}
  %Equal.sym(Bool, CHK(t, n), False{{}}, hchk) :
    {{{Tn}_built(n, (BF(t, n), _)) == (BF(t, n), None{{}}) : {D}}}
  {{==}}
''', x))
    return '\n'.join(L) + '\n'


def spec_bits_lim(n, j):
    src = (ROOT / 'spec/fulu_schemas.bend').read_text()
    defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.*)$', src, re.M))
    kids, _ = VL.spec_schemas(n)
    m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[kids[j]])
    return m.group(1)


def spec_text(g, x):
    n, FS, H, po = x.n, x.FS, x.H, x.po
    vi = [f['kind'] for f in x.fields].index('bits')
    LIMN = spec_bits_lim(n, vi)
    nodes = VL.field_nodes(g, x, lambda k: f'VB.slot(t, {k}n)')
    W1 = f'VR.WB(t, {H}n, 1n+M1(n))'
    vals, schs, parts = [], [], []
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append(f'S.BitsValue{{VBL.bl({W1})}}')
            schs.append(f'S.BitList{{{LIMN}}}')
            parts.append(f'S.Variable{{{W1}}}')

    def items(i, W=W1):
        if i == len(vals):
            return 'S.EmptyItems{}'
        v = vals[i].replace(W1, W)
        return f'S.Items{{{v}, {items(i + 1, W)}}}'

    def chain(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if x.fields[i]['kind'] == 'fix':
            return (f'F.cat_fixed(Codec.parts({vals[i]}, {schs[i]}), F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.cat_var(Codec.parts({vals[i]}, {schs[i]}), {W1}, Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, '
                f'VBC.bl_parts({W1}, {LIMN}, dom, nzl, hl), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(FS)]
    HDR = '[' + ', '.join(hdr) + ']'
    HDRh = '[' + ', '.join(h if i != po else '_' for i, h in enumerate(hdr)) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {W1})'
    RHS = f'Some{{List.append(&2, U32, F.limbs({HDR}), {W1})}}'
    M = 'Maybe<&2, +List<U32>>'
    MP = 'Maybe<&2, +List<S.Part>>'
    s = 'FD.array__slots(U32, t)'
    Wn = f'VR.WB(t, {H}n, U32.to_nat(LL(n)))'
    return subst(f"""
# ---- the spec side -------------------------------------------------------------------------

def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs({s}))
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: S.Sequence{{{items(0, Wn)}}}

def fitN(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}, +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}},
    +ha: {{U32.is_le(@FS, n) == True{{}} : Bool}}, +el: {{List.length(&2, U32, {W1}) == U32.to_nat(LL(n)) : Nat}})
    -> {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {W1}))) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {W1}), U32.to_nat(LL(n)), el) : {{N.fits(4n, Nat.add(@FSn, _)) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha)) : {{N.fits(4n, _) == True{{}} : Bool}}
  VFT.fits4(2n+d, U32.to_nat(n), hn, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))

# The spec encoding of the value: the header words' limbs (offset @FS), then the window's bytes.
def enc_spec(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}, +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}},
    +ha: {{U32.is_le(@FS, n) == True{{}} : Bool}}, +el: {{List.length(&2, U32, {W1}) == U32.to_nat(LL(n)) : Nat}},
    +dom: {{SP.bytes_domain({W1}) == True{{}} : Bool}}, +nzl: {{U32.is_eq(VBL.lastb({W1}), 0) == False{{}} : Bool}},
    +hl: {{Nat.is_le(List.length(&2, Bool, VBL.bl({W1})), {LIMN}) == True{{}} : Bool}})
    -> {{Codec.encoding_for_legal_type(Spec.{n}(), S.Sequence{{{items(0)}}}) == {RHS} : {M}}}:
  %Equal.sym({MP}, Codec.parts({items(0)}, {chain(0)}), Some{{[{', '.join(parts)}]}},
      {cat(0)}) :
    {{Codec.bytes(Codec.aggregate(_, None{{}})) == {RHS} : {M}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, {W1}, {POST})), Some{{{ENCR}}}, VBC.enc_fpvb({PRE}, {W1}, {POST}, dom, fitN(d, t, n, hd, hn, ha, el))) :
    {{Codec.bytes(Codec.one(_, None{{}})) == {RHS} : {M}}}
  {{==}}

# The header's limbs and the window's bytes are the buffer's bytes.
def lim_eq(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +ha: {{U32.is_le(@FS, n) == True{{}} : Bool}}, +epo: {{SPO(t) == @FS : U32}})
    -> {{List.append(&2, U32, F.limbs({HDR}), {Wn}) == VW(t, n) : +List<U32>}}:
  +hs = VBC.nwH(d, LL(n), @Hn, hd, hwL(d, n, ha, hn))
  +hpre = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(@Hn, 0n), z) == True{{}} : Bool}}, VB.pw(d), VB.len({s}), Equal.sym(Nat, VB.len({s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)),
    FD.nat__le_trans(@Hn, Nat.add(VC.NW(LL(n)), @Hn), VB.pw(d), Order.left_below_sum(VC.NW(LL(n)), @Hn), hs))
  %enFS(n, ha) : {{List.append(&2, U32, F.limbs({HDR}), {Wn}) == VS.bt(_, F.limbs({s})) : +List<U32>}}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(@FSn, U32.to_nat(LL(n))), F.limbs({s})), List.append(&2, U32, VS.bt(@FSn, F.limbs({s})), VS.bt(U32.to_nat(LL(n)), VS.bdr(@FSn, F.limbs({s})))),
      VBC.bt_split(@FSn, U32.to_nat(LL(n)), F.limbs({s}))) :
    {{List.append(&2, U32, F.limbs({HDR}), {Wn}) == _ : +List<U32>}}
  %Equal.sym(+List<U32>, VS.bt(A.quad(@Hn), F.limbs({s})), F.limbs(VS.wtake(@Hn, {s})), VS.bt_limbs(@Hn, {s})) :
    {{List.append(&2, U32, F.limbs({HDR}), {Wn}) == List.append(&2, U32, _, {Wn}) : +List<U32>}}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(@Hn, 0n), VB.wdr(0n, {s})), VF.app(VF.wpre(@Hn, 0n, {s}), VS.wtake(0n, VB.wdr(Nat.add(@Hn, 0n), {s}))), VF.wt_pre(@Hn, 0n, 0n, {s}, hpre)) :
    {{List.append(&2, U32, F.limbs({HDR}), {Wn}) == List.append(&2, U32, F.limbs(_), {Wn}) : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({HDRh}), {Wn}) == List.append(&2, U32, F.limbs(VF.app(VF.wpre(@Hn, 0n, {s}), [])), {Wn}) : +List<U32>}}
  {{==}}

def spec_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +ha: {{U32.is_le(@FS, n) == True{{}} : Bool}}, +epo: {{SPO(t) == @FS : U32}},
    +hw: {{CHKW(t, n) == True{{}} : Bool}})
    -> Decoding.decodes(Spec.{n}(), VW(t, n), VAL(t, n)):
  +e1 = cwE(t, n, hw)
  +h1 = cw1(t, n, hw)
  +nz = cwB(t, n, h1)
  +bd = cwC(t, n, h1, nz)
  +m = M1(n)
  +hw1 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(A.quad(@Hn), z), A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(LL(n)), 1n+m, e1, hwL(d, n, ha, hn))
  +el = Equal.trans(Nat, List.length(&2, U32, {W1}), 1n+m, U32.to_nat(LL(n)), VR.lenWB(d, t, @Hn, 1n+m, pf, hw1), Equal.sym(Nat, U32.to_nat(LL(n)), 1n+m, e1))
  +lw = VR.lastWB(d, t, @Hn, m, XW(n), pf, hw1, eXW(d, n, hd, ha, hn, e1))
  +nzl = FD.logic__subst(U32, z => {{U32.is_eq(z, 0) == False{{}} : Bool}}, VWB(t, n), VBL.lastb({W1}), Equal.sym(U32, VBL.lastb({W1}), VWB(t, n), lw), nz)
  +dom = VR.domWB(t, @Hn, 1n+m)
  +len = Equal.trans(Nat, List.length(&2, Bool, VBL.bl({W1})), VBL.blen({W1}), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(VWB(t, n)))), VBL.bl_len({W1}, dom, nzl),
    Equal.trans(Nat, VBL.blen({W1}), Nat.add(VS.x8(m), VY.hb(VBL.lastb({W1}))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(VWB(t, n)))),
      VR.blen_m({W1}, m, VR.lenWB(d, t, @Hn, 1n+m, pf, hw1)),
      Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.lastb({W1}), VWB(t, n), lw)))
  +bd1 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(VWB(t, n)))), U32.to_nat(@N)) == True{{}} : Bool}}, Nat.mul(8n, m), VS.x8(m), VR.mul8(m), bd)
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(z, {LIMN}) == True{{}} : Bool}}, Nat.add(VS.x8(m), U32.to_nat(O.high_bit(VWB(t, n)))), List.length(&2, Bool, VBL.bl({W1})),
    Equal.sym(Nat, List.length(&2, Bool, VBL.bl({W1})), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(VWB(t, n)))), len), bd1)
  %Equal.sym(Nat, U32.to_nat(LL(n)), 1n+m, e1) :
    {{Codec.encoding_for_legal_type(Spec.{n}(), S.Sequence{{{items(0, f'VR.WB(t, {H}n, _)')}}}) == Some{{VW(t, n)}} : {M}}}
  %lim_eq(d, t, n, pf, hd, hn, ha, epo) :
    {{Codec.encoding_for_legal_type(Spec.{n}(), S.Sequence{{{items(0)}}}) == Some{{_}} : {M}}}
  %Equal.sym(Nat, U32.to_nat(LL(n)), 1n+m, e1) :
    {{Codec.encoding_for_legal_type(Spec.{n}(), S.Sequence{{{items(0)}}}) == Some{{List.append(&2, U32, F.limbs({HDR}), VR.WB(t, {H}n, _))}} : {M}}}
  enc_spec(d, t, n, hd, hn, ha, el, dom, nzl, hl)

# The bytes of every buffer the validator accepts are the spec encoding of VAL(t, n).
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  Decoding.decodes(Spec.{n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(@FS, n)
  +b = U32.is_eq(SPO(t), @FS)
  +c = CHKW(t, n)
  spec_go(d, t, n, pf, hd, hn, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPO(t), @FS, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))
""", x)


def unique_text(x):
    return VL.unique_text(None, x.n, fname(x).name).replace('GENERATED by codegen/var_laws.py', 'GENERATED by codegen/var_bitc.py').replace(
        'for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}', 'for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}')


VALUE_CTORS = [('BooleanValue', ['b0']), ('UnsignedValue', ['u0']), ('BytesValue', ['xs0']), ('BitsValue', ['bs0']),
               ('Sequence', ['it0']), ('Items', ['hd0', 'tl0']), ('EmptyItems', []), ('Selected', ['sel0', 'sv0']), ('NullValue', [])]


def rej_text(g, x):
    n, FS, H, po = x.n, x.FS, x.H, x.po
    P = 4 * po
    vi = [f['kind'] for f in x.fields].index('bits')
    LIMN = spec_bits_lim(n, vi)
    kids, _ = VL.spec_schemas(n)
    m = len(x.fields)
    L = list(HEAD) + ['import ./vrej.bend as VRJ', 'import ./vnest.bend as VN', 'import ./dk.bend as DK',
                      'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
                      f'import ./{fname(x).name} as DC', '',
                      '# GENERATED by codegen/var_bitc.py. Do not edit.',
                      f'# Rejection of {n}: every byte string the spec relates to a value has the',
                      '# fixed fields, the offset and a bit-list encoding behind it, and then every',
                      '# check of the validator passes.', '']
    w = L.append
    MB = 'Maybe<&2, +List<U32>>'
    VWt = 'DC.VW(t, n)'
    CTX = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
           '    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool}')
    CA = 'd, t, n, pf, hd, hn, hchk'

    def absurd():
        return f'FD.logic__none_some(+List<U32>, {VWt}, e)'

    def match_value(var, keep, body):
        out = [f'  match {var}:']
        for c, args in VALUE_CTORS:
            if c == keep[0]:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in keep[1]) + f'}}: {body}')
            else:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in args) + f'}}: {absurd()}')
        return out

    def prefix(i):
        decl, args, parts = [], [], []
        for j, f in enumerate(x.fields[:i]):
            if f['kind'] == 'fix':
                decl += [f'+xs{j}: +List<U32>', f'+lx{j}: {{List.length(&2, U32, xs{j}) == {f["ft"].size}n : Nat}}']
                args += [f'xs{j}', f'lx{j}']
                parts.append(f'S.Fixed{{xs{j}}}')
            else:
                decl += ['+bits: +List<Bool>', f'+hb: {{Nat.is_le(List.length(&2, Bool, bits), {LIMN}) == True{{}} : Bool}}', '+fs: VBL.IF(bits)']
                args += ['bits', 'hb', 'fs']
                parts.append('S.Variable{VBL.P(bits)}')
        return decl, args, parts

    def CC(parts, X):
        for pp in reversed(parts):
            X = f'Codec.concatenate(Some{{[{pp}]}}, {X})'
        return X

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{Spec.{kids[i]}(), {chain(i + 1)}}}'

    def E(parts, X):
        return f'{{Codec.bytes(Codec.aggregate({CC(parts, X)}, None{{}})) == Some{{{VWt}}} : {MB}}}'

    def sig(name, decl, extra):
        return f'def {name}({CTX}, ' + ', '.join(decl + extra) + ') -> Empty:'

    pre = list(range(vi))
    post = list(range(vi + 1, m))
    PRE = '[' + ', '.join(f'xs{j}' for j in pre) + ']'
    POST = '[' + ', '.join(f'xs{j}' for j in post) + ']'
    decl_m, args_m, parts_m = prefix(m)
    Pz = sum(x.fields[j]['ft'].size for j in pre)
    Qz = sum(x.fields[j]['ft'].size for j in post)
    assert Pz == P and Pz + 4 + Qz == FS
    ALL = ', '.join(args_m)
    OUT = f'VRJ.OUT({PRE}, VBL.P(bits), {POST})'

    def lens_eq(name, idx, total):
        w(f'def {name}(' + ', '.join(decl_m) + f') -> {{VRJ.lens([' + ', '.join(f'xs{j}' for j in idx) + f']) == {total}n : Nat}}:')
        cur = [f'List.length(&2, U32, xs{j})' for j in idx]
        for a, j in enumerate(idx):
            def term(c):
                tt = '0n'
                for q in reversed(c):
                    tt = f'Nat.add({q}, {tt})'
                return tt
            mot = cur[:a] + ['_'] + cur[a + 1:]
            w(f'  %Equal.sym(Nat, List.length(&2, U32, xs{j}), {x.fields[j]["ft"].size}n, lx{j}) : {{{term(mot)} == {total}n : Nat}}')
            cur[a] = f'{x.fields[j]["ft"].size}n'
        w('  {==}')
        w('')
    lens_eq('eP', pre, Pz)
    lens_eq('eQ', post, Qz)
    w(f'def fz_eq(' + ', '.join(decl_m) + f') -> {{VRJ.FZ({PRE}, {POST}) == {FS}n : Nat}}:')
    w(f'  %Equal.sym(Nat, VRJ.lens({PRE}), {Pz}n, eP({ALL})) : {{Nat.add(_, 4n+VRJ.lens({POST})) == {FS}n : Nat}}')
    w(f'  %Equal.sym(Nat, VRJ.lens({POST}), {Qz}n, eQ({ALL})) : {{Nat.add({Pz}n, 4n+_) == {FS}n : Nat}}')
    w('  {==}')
    w('')
    w(f'def f_off(' + ', '.join(decl_m) + f') -> {{VS.bt(4n, VS.bdr({P}n, {OUT})) == N.digits(4n, {FS}n) : +List<U32>}}:')
    w(f'  %eP({ALL}) : {{VS.bt(4n, VS.bdr(_, {OUT})) == N.digits(4n, Nat.add(_, 4n+{Qz}n)) : +List<U32>}}')
    w(f'  %eQ({ALL}) : {{VS.bt(4n, VS.bdr(VRJ.lens({PRE}), {OUT})) == N.digits(4n, Nat.add(VRJ.lens({PRE}), 4n+_)) : +List<U32>}}')
    w(f'  VRJ.out_off({PRE}, VBL.P(bits), {POST})')
    w('')
    w(f'def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FS}n, List.length(&2, U32, VBL.P(bits))) : Nat}}:')
    w(f'  %fz_eq({ALL}) : {{List.length(&2, U32, {OUT}) == Nat.add(_, List.length(&2, U32, VBL.P(bits))) : Nat}}')
    w(f'  VRJ.out_len({PRE}, VBL.P(bits), {POST})')
    w('')
    w(f'def f_tail(' + ', '.join(decl_m) + f') -> {{VS.bdr({FS}n, {OUT}) == VBL.P(bits) : +List<U32>}}:')
    w(f'  %fz_eq({ALL}) : {{VS.bdr(_, {OUT}) == VBL.P(bits) : +List<U32>}}')
    w(f'  VBC.out_tail({PRE}, VBL.P(bits), {POST})')
    w('')
    w(subst(CHKT, x))
    w(subst(CONTRA, x).replace('@DECL', ', '.join(decl_m)).replace('@ALL', ALL).replace('@OUT', OUT).replace('@LIMN', LIMN).replace('@CTX', CTX).replace('@CA', CA))
    PLIST = '[' + ', '.join(parts_m) + ']'
    b5 = f'Bool.and(Layout.bytes_valid({PLIST}), N.fits(4n, Nat.add(Layout.fixed_size({PLIST}), List.length(&2, U32, Layout.payloads({PLIST})))))'
    w(sig('fin', decl_m, ['+b5: Bool', f'+e: {{Codec.bytes(Codec.one(SP.optional(b5, {OUT}), None{{}})) == Some{{{VWt}}} : {MB}}}']))
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w(f'    case True{{}}: contra({CA}, {ALL}, FD.logic__some_inj(+List<U32>, {OUT}, {VWt}, e))')
    w('')
    w(sig(f'st{m}', decl_m, ['+items: S.Value', '+e: ' + E(parts_m, 'Codec.parts(items, S.End{})')]))
    L.extend(match_value('items', ('EmptyItems', []), f'fin({CA}, {ALL}, {b5}, e)'))
    w('')
    for i in reversed(range(m)):
        f = x.fields[i]
        decl, args, parts = prefix(i)
        A = ', '.join(args + [''])
        sch = f'Spec.{kids[i]}()'
        nxt = f'Codec.parts(r, {chain(i + 1)})'
        if f['kind'] == 'fix':
            z = f['ft'].size
            w(sig(f'fp{i}', decl, ['+ps: +List<S.Part>', f'hf: DF.single(Some{{{z}n}}, ps)', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            w('  match ps:')
            w('    case Nil{}: hf')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: st{i + 1}({CA}, {A}xs, Equal.sym(Nat, {z}n, List.length(&2, U32, xs), FD.logic__some_inj(Nat, {z}n, List.length(&2, U32, xs), hf)), r, e)')
            w(f'    case Con{{S.Variable{{+xs}}, Nil{{}}}}: FD.logic__none_some(Nat, {z}n, Equal.sym(Maybe<&2, Nat>, Some{{{z}n}}, None{{}}, hf))')
            w('    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: hf')
            w('    case Con{S.Variable{+xs}, Con{+h2, +t2}}: hf')
            w('')
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({CA}, {A}ps, hf, r, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+r: S.Value', '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({CA}, {A}Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), r, e)')
            w('')
        else:
            w(sig('vb', decl, ['+bits: +List<Bool>', '+r: S.Value', '+b: Bool', f'+eb: {{Nat.is_le(List.length(&2, Bool, bits), {LIMN}) == b : Bool}}',
                               '+e: ' + E(parts, f'Codec.concatenate(Codec.one(Bits.encoding(b, List.append(&2, Bool, bits, [True{{}}])), None{{}}), {nxt})')]))
            w('  match b:')
            w(f'    case False{{}}: {absurd()}')
            w(f'    case True{{}}: st{i + 1}({CA}, {A}bits, eb, VBL.inv(bits), r, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+r: S.Value', '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            L.extend(match_value('h', ('BitsValue', ['bits']), f'vb({CA}, {A}bits, r, Nat.is_le(List.length(&2, Bool, bits), {LIMN}), {{==}}, e)'))
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 'r']), f'fd{i}({CA}, {A}h, r, e)'))
        w('')
    w(f'def inv_v({CTX}, +v: S.Value, +e: {{Codec.encoding_for_legal_type(Spec.{n}(), v) == Some{{{VWt}}} : {MB}}}) -> Empty:')
    L.extend(match_value('v', ('Sequence', ['items']), f'st0({CA}, items, e)'))
    w(f"""
# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{DC.CHK(t, n) == False{{}} : Bool}}
  Decoding.outside_image(Spec.{n}(), {VWt})
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => inv_v({CA}, v, e)
""")
    return '\n'.join(L) + '\n'


CONTRA = r"""
def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def subc(+n: U32, +k: U32, +y: Nat, +e: {U32.to_nat(n) == Nat.add(U32.to_nat(k), y) : Nat}) -> {U32.to_nat(U32.sub(n, k)) == y : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(k), z) == True{} : Bool}, Nat.add(U32.to_nat(k), y), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e), FD.nat__le_add_right(U32.to_nat(k), y))
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, k)), Nat.sub(U32.to_nat(n), U32.to_nat(k)), FD.u32__sub_nat(n, k, le)) : {_ == y : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e) : {Nat.sub(_, U32.to_nat(k)) == y : Nat}
  FD.nat__add_sub_cancel(U32.to_nat(k), y)

# The window's bytes, from the layout.
def winY(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +Y: +List<U32>, +ha: {U32.is_le(@FS, n) == True{} : Bool},
    +ty: {VS.bdr(@FSn, DC.VW(t, n)) == Y : +List<U32>}) -> {Y == VR.WB(t, @Hn, U32.to_nat(DC.LL(n))) : +List<U32>}:
  %ty : {_ == VR.WB(t, @Hn, U32.to_nat(DC.LL(n))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, U32.to_nat(DC.LL(n))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(DC.LL(n))), U32.to_nat(n), DC.enFS(n, ha))) :
    {VS.bdr(@FSn, VS.bt(_, F.limbs(FD.array__slots(U32, t)))) == VR.WB(t, @Hn, U32.to_nat(DC.LL(n))) : +List<U32>}
  VS.bdr_bt(@FSn, U32.to_nat(DC.LL(n)), F.limbs(FD.array__slots(U32, t)))

def contra(@CTX, @DECL, +eo: {@OUT == DC.VW(t, n) : +List<U32>}) -> Empty:
  (+l, +r) = fs
  (+nz0, +ln) = r
  +m = VBL.mcnt(bits)
  +Y = VBL.P(bits)
  +lY = List.length(&2, U32, Y)
  +elen = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), Nat.add(@FSn, lY), Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), VR.lenWB(d, t, 0n, U32.to_nat(n), pf, hn)),
    Equal.trans(Nat, List.length(&2, U32, DC.VW(t, n)), List.length(&2, U32, @OUT), Nat.add(@FSn, lY),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), DC.VW(t, n), @OUT, Equal.sym(+List<U32>, @OUT, DC.VW(t, n), eo)), f_len(@ALL)))
  +hF = FD.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, Nat.add(@FSn, lY), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, lY), elen), FD.nat__le_add_right(@FSn, lY))
  +ha = u32le(@FS, n, hF)
  +eLL = subc(n, @FS, lY, elen)
  +e1 = Equal.trans(Nat, U32.to_nat(DC.LL(n)), lY, 1n+m, eLL, l)
  # the offset word
  +b0 = VN.byteK2(d, t, n, @POn, pf, hn, FD.nat__le_trans(Nat.add(A.quad(@POn), 4n), @FSn, U32.to_nat(n), {==}, hF))
  +epo = VN.wordc(DC.SPO(t), @FS, Equal.trans(+List<U32>, F.limbs([DC.SPO(t)]), VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), N.digits(4n, @FSn),
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), F.limbs([DC.SPO(t)]), b0),
    Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), VS.bt(4n, VS.bdr(@Pn, @OUT)), N.digits(4n, @FSn),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(@Pn, z)), DC.VW(t, n), @OUT, Equal.sym(+List<U32>, @OUT, DC.VW(t, n), eo)), f_off(@ALL))))
  # the window
  +ty = Equal.trans(+List<U32>, VS.bdr(@FSn, DC.VW(t, n)), VS.bdr(@FSn, @OUT), Y,
    Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@FSn, z), DC.VW(t, n), @OUT, Equal.sym(+List<U32>, @OUT, DC.VW(t, n), eo)), f_tail(@ALL))
  +eW = winY(d, t, n, Y, ha, ty)
  +W1 = VR.WB(t, @Hn, 1n+m)
  +eW1 = Equal.trans(+List<U32>, Y, VR.WB(t, @Hn, U32.to_nat(DC.LL(n))), W1, eW, Equal.cong(Nat, +List<U32>, z => VR.WB(t, @Hn, z), U32.to_nat(DC.LL(n)), 1n+m, e1))
  +m1 = Equal.trans(Nat, DC.M1(n), m, m, subc(DC.LL(n), 1, m, e1), {==})
  +e1m = Equal.trans(Nat, U32.to_nat(DC.LL(n)), 1n+m, 1n+DC.M1(n), e1, Equal.cong(Nat, Nat, z => 1n+z, m, DC.M1(n), Equal.sym(Nat, DC.M1(n), m, m1)))
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(@Hn), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(DC.LL(n)), 1n+m, e1, DC.hwL(d, n, ha, hn))
  +lw = VR.lastWB(d, t, @Hn, m, DC.XW(n), pf, hw1,
    FD.logic__subst(Nat, z => {U32.to_nat(DC.XW(n)) == Nat.add(A.quad(@Hn), z) : Nat}, DC.M1(n), m, m1, DC.eXW(d, n, hd, ha, hn, e1m)))
  +eV = Equal.trans(U32, VBL.nthb(Y, m), VBL.nthb(W1, m), DC.VWB(t, n), Equal.cong(+List<U32>, U32, z => VBL.nthb(z, m), Y, W1, eW1),
    Equal.trans(U32, VBL.nthb(W1, m), VBL.lastb(W1), DC.VWB(t, n), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(W1, m), VR.last_len(W1, m, VR.lenWB(d, t, @Hn, 1n+m, pf, hw1))), lw))
  +nz = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, VBL.nthb(Y, m), DC.VWB(t, n), eV, nz0)
  +lnV = Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), VY.hb(VBL.nthb(Y, m))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))), ln,
    Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.nthb(Y, m), DC.VWB(t, n), eV))
  +eBD = Equal.trans(Nat, DC.BD(t, n), Nat.add(VS.x8(DC.M1(n)), U32.to_nat(O.high_bit(DC.VWB(t, n)))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(O.high_bit(DC.VWB(t, n)))), Nat.mul(8n, DC.M1(n)), VS.x8(DC.M1(n)), VR.mul8(DC.M1(n))),
    Equal.cong(Nat, Nat, z => Nat.add(VS.x8(z), U32.to_nat(O.high_bit(DC.VWB(t, n)))), DC.M1(n), m, m1))
  +bd = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, List.length(&2, Bool, bits), DC.BD(t, n),
    Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))), DC.BD(t, n), lnV, Equal.sym(Nat, DC.BD(t, n), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))), eBD)), hb)
  +lt0 = FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+m, U32.to_nat(DC.LL(n)), Equal.sym(Nat, U32.to_nat(DC.LL(n)), 1n+m, e1), {==})
  +ea = FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(0n, U32.to_nat(DC.LL(n))), U32.is_lt(0, DC.LL(n)), Equal.sym(Bool, U32.is_lt(0, DC.LL(n)), Nat.is_lt(0n, U32.to_nat(DC.LL(n))), VR.lt_u32(0, DC.LL(n))), lt0)
  +hw = chkw_t(t, n, ea, nz, bd)
  FD.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, chk_t(t, n, ha, epo, hw)), hchk))
"""

CHKT = r"""
def chkw_t(+t: FD.array__Tree<U32>, +n: U32, +ea: {U32.is_lt(0, DC.LL(n)) == True{} : Bool}, +nz: {U32.is_eq(DC.VWB(t, n), 0) == False{} : Bool},
    +bd: {Nat.is_le(DC.BD(t, n), U32.to_nat(@N)) == True{} : Bool}) -> {DC.CHKW(t, n) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(0, DC.LL(n)), True{}, ea) : {DC.chkw(_, t, n) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(DC.VWB(t, n), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(DC.BD(t, n), U32.to_nat(@N)))) == True{} : Bool}
  bd

def chk_t(+t: FD.array__Tree<U32>, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +epo: {DC.SPO(t) == @FS : U32}, +hw: {DC.CHKW(t, n) == True{} : Bool})
    -> {DC.CHK(t, n) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(@FS, n), True{}, ha) : {DC.chk3(_, U32.is_eq(DC.SPO(t), @FS), DC.CHKW(t, n)) == True{} : Bool}
  %Equal.sym(U32, DC.SPO(t), @FS, epo) : {DC.chk3(True{}, U32.is_eq(_, @FS), DC.CHKW(t, n)) == True{} : Bool}
  hw
"""



def _foreign(q, me):
    # a file whose header names another generator is not ours, whatever its name
    m = re.search(r'# GENERATED by (codegen/[\w/]+\.py)', q.read_text()[:8000])
    return m is not None and m.group(1) != me

def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    no_big = '--no-big' in sys.argv
    out = {}
    for n in NAMES:
        x = BName(g, n, names[n])
        if no_big and is_big(x):
            continue
        out[fname(x)] = dec_text(g, x) + spec_text(g, x)
        out[fname(x, '_unique')] = unique_text(x)
        out[fname(x, '_rej')] = rej_text(g, x)
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_bitc_*.bend') if q.name.startswith(('var_bitc_', 'big_var_bitc_')) and not q.name.startswith(('var_bitc_enc_', 'big_var_bitc_enc_')) and not _foreign(q, 'codegen/var_bitc.py')]
    orphans = sorted(str(q.relative_to(ROOT)) for q in mine if q not in out and not (no_big and q.name.startswith('big_')))
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t] + orphans
        if stale:
            print('stale generated bit-list container laws: ' + ', '.join(stale))
            sys.exit(1)
        print('generated bit-list container laws are current')
        return
    for q in orphans:
        (ROOT / q).unlink()
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
