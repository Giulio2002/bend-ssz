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


HEAD = list(VL.DEC_HEAD) + ['import ./spec_bits.bend as FB', 'import ./vlist.bend as VLS', 'import ./vbitl.bend as VBL',
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
    for k, v in [('@BMAXn', f'{x.BMAX}n'), ('@YMAXn', f'{x.YMAX}n'), ('@Cn', f'{x.C}n'), ('@Kn', f'{x.K}n'), ('@POn', f'{x.po}n'),
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
        out[fname(x)] = dec_text(g, x)
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_bitc_*.bend') if q.name.startswith(('var_bitc_', 'big_var_bitc_'))]
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
