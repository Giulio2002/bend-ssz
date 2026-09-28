#!/usr/bin/env python3
"""Encoder laws of AggregateAndProof and SignedAggregateAndProof: containers of fixed
fields around one variable child, the child an Attestation (a bit list among fixed
fields) at a word-aligned position.

    python3 codegen/var_agg_enc.py [--check] [--no-big]

Every module below states the same WRITER INTERFACE of its name X at a symbolic
word-aligned position pos = 4 P of an existing output tree D of depth dd < 29:

  W(ws, dd, D, P, pos, T, K)      the output tree (X's words at P, the bit list's
                                  bytes at P + HX)
  putw(...)                       T.X_putn(thaw D, pos, OBJ) == (thaw W, (OBJ, SFS(K)))
  hdrw(...)                       WIN(HX, P, slots W) == HDR (the flat header words)
  payw(...)                       the bit list's bytes after the header are Y(ws, T, K)
                                  (proofs/obj/big_var_bitc_enc_Attestation.bend's bytes)
  ow_hi(..., m, p, hm)            a window below P is D's
  partsE(ws, dw, T, K, ...)       Codec.parts(VAL, Spec.X()) == Some{[Variable{limbs(HDR) ++ Y}]}

with the hypotheses: pos = 4 P; D perfect of depth dd < 29 with room for the
HX + q + 1 words at P (q = K / 32) and its two words under the bit list's delimiter
and last byte zero; the bit list O.Bits{thaw T, K} a value within BitList[2^17]
(BO.rep_bits) passing the runtime's checks (capacity, bits past K zero).

  proofs/obj/big_var_bitc_encw_Attestation.bend      Attestation (HX = 59), over the
      pos-0 encoder's library (codegen/var_bits_enc.py): vbitcont.enc_at writes the
      bit list at P + 59, the fixed fields are VF.updv runs;
  proofs/obj/big_var_codec_AggregateAndProof_enc.bend        (HX = 27 + 59)
  proofs/obj/big_var_codec_SignedAggregateAndProof_enc.bend  (HX = 25 + 86)
      the parent's offset word and fixed fields around the child's writer at
      P + H, then encode_eval / encode_spec: the interface at P = 0 of a zero tree.

BIG (checkq --big): they import the pos-0 Attestation encoder, a big file.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))

import var_laws as VL  # noqa: E402
import var_bits_enc as VBE_  # noqa: E402

OBJ = ROOT / 'proofs/obj'
LT = 'List<&2, U32>'
M = 'Maybe<&2, +List<U32>>'
MP = 'Maybe<&2, +List<S.Part>>'
TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'
q = 'VBT.QK(K)'
LIMN = 'U32.to_nat(131072)'
KB = 18
KY = VBE_.lg(32 + 131072)

HEAD = list(VL.DEC_HEAD) + [
    'import ./venc.bend as VE', 'import ./venc2.bend as V2', 'import ./vnenc.bend as VN', 'import ./vbspec.bend as VZ',
    'import ./vbytes.bend as VY', 'import ./vbitc.bend as VBC', 'import ./spec_bits.bend as FB',
    'import ../../spec/bitfields.bend as Bits', 'import ../../spec/bit_packing.bend as Bp', 'import ./bitlist_pack.bend as BK',
    'import ./bitlist_rep.bend as BO', 'import ./vbitenc.bend as VBT', 'import ./vbitdl.bend as DL', 'import ./vbitcore.bend as CO',
    'import ./vbitcont.bend as CT', 'import ./vbitrep.bend as VR', 'import ./var_bits_enc_bw.bend as BW', 'import ../compact/reads.bend as RD',
    'import ../../proofs/primitive_invariants.bend as V', 'import ./big_var_bitc_enc_Attestation.bend as E']


def wsig(ws):
    return ', '.join(f'+{w}: U32' for w in ws)


def shift(a, b):
    """is_le(a + P, b + P) for closed a <= b, as the checker reduces it."""
    assert a <= b, (a, b)
    return f'Order.left_below_sum({b - a}n, P)'


def chain(steps, last_term, last_proof):
    out = last_proof
    for a, b, pr in reversed(steps):
        out = f'Equal.trans({LT}, {a}, {b}, {last_term}, {pr},\n    {out})'
    return out


class Iface:
    """A module with the writer interface."""

    def __init__(self, n, alias, ws, HX, obj, val, hdr, sfs, sch):
        self.n, self.alias, self.ws, self.HX = n, alias, ws, HX
        self.obj, self.val, self.hdr, self.sfs, self.sch = obj, val, hdr, sfs, sch

    def args(self, pre=''):
        return ', '.join(self.ws)


# ---- the common hypotheses -----------------------------------------------------------------------

def hyps(ws, HX):
    CW = f'{wsig(ws)}, +dd: Nat, +D: {TR}, +P: Nat, +pos: U32, +T: {TR}, +K: U32'
    CWa = f'{", ".join(ws)}, dd, D, P, pos, T, K'
    HR = f'{{Nat.is_le(Nat.add(Nat.add({HX}n, P), Nat.add({q}, 1n)), VB.pw(dd)) == {TRUE}}}'
    HW = (f'+e: {{U32.to_nat(pos) == A.quad(P) : Nat}}, +pfD: {{FD.array__perfect(U32, dd, D) == {TRUE}}}, +hdd: {{Nat.is_lt(dd, 29n) == {TRUE}}},\n'
          f'    +hR: {HR},\n'
          f'    +hz0: {{VB.slot(D, Nat.add(Nat.add({HX}n, P), {q})) == 0 : U32}}, +hzq: {{VB.slot(D, Nat.add(VY.QL(O.bits_nbytes(K)), Nat.add({HX}n, P))) == 0 : U32}},\n'
          '    +dw: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},\n'
          f'    +rep: BO.rep_bits(E.OB(T, K), S.BitList{{{LIMN}}}),\n'
          '    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},\n'
          '    +hv: {O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))) == True{} : Bool}')
    HWa = 'e, pfD, hdd, hR, hz0, hzq, dw, pfT, hdw, rep, hcap, hv'
    SRC = (f'{wsig(ws)}, +dw: Nat, +T: {TR}, +K: U32,\n'
           '    +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},\n'
           f'    +rep: BO.rep_bits(E.OB(T, K), S.BitList{{{LIMN}}}),\n'
           '    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},\n'
           '    +hv: {O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))) == True{} : Bool}')
    SRCa = f'{", ".join(ws)}, dw, T, K, pfT, hdw, rep, hcap, hv'
    return CW, CWa, HW, HWa, SRC, SRCa


HN = f'VR.rep_N(T, K, {LIMN}, rep)'


def common_lemmas(HX):
    """hq, eoff, the zero slots under the bit list after one write below it."""
    HR = f'{{Nat.is_le(Nat.add(Nat.add({HX}n, P), Nat.add({q}, 1n)), VB.pw(dd)) == {TRUE}}}'
    return f'''
# a <= HX: a + P <= 2^dd.
def hq(+a: Nat, +dd: Nat, +P: Nat, +K: U32, +ha: {{Nat.is_le(a, {HX}n) == {TRUE}}}, +hR: {HR})
    -> {{Nat.is_le(Nat.add(a, P), VB.pw(dd)) == {TRUE}}}:
  FD.nat__le_trans(Nat.add(a, P), Nat.add({HX}n, P), VB.pw(dd), Order.add_right(a, {HX}n, P, ha),
    FD.nat__le_trans(Nat.add({HX}n, P), Nat.add(Nat.add({HX}n, P), Nat.add({q}, 1n)), VB.pw(dd), Order.below_sum(Nat.add({HX}n, P), Nat.add({q}, 1n)), hR))

def eoff(+pos: U32, +c: U32, +k: Nat, +dd: Nat, +P: Nat, +K: U32, +e: {{U32.to_nat(pos) == A.quad(P) : Nat}}, +ec: {{U32.to_nat(c) == A.quad(k) : Nat}},
    +hk: {{Nat.is_le(k, {HX}n) == {TRUE}}}, +hdd: {{Nat.is_lt(dd, 29n) == {TRUE}}}, +hR: {HR})
    -> {{U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}}:
  VF.off_add(pos, c, P, k, 2n+dd, e, ec, hdd, VF.in_q(k, P, dd, hq(k, dd, P, K, hk, hR)))

# A slot of D past a word i it wrote is D's.
def sl_up(+dd: Nat, +D: {TR}, +i: Nat, +v: U32, +k: Nat, +pfD: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hi: {{Nat.is_lt(i, VB.pw(dd)) == {TRUE}}}, +hk: {{Nat.is_lt(i, k) == {TRUE}}}, +hz: {{VB.slot(D, k) == 0 : U32}})
    -> {{VB.slot(FD.array__upd(U32, dd, D, i, v), k) == 0 : U32}}:
  %Equal.sym({LT}, FD.array__slots(U32, FD.array__upd(U32, dd, D, i, v)), FD.spec_common__update(U32, FD.array__slots(U32, D), i, v),
      FD.array__upd_slots(U32, dd, D, i, v, hi, pfD)) :
    {{FD.flat__nthc(_, k) == 0 : U32}}
  Equal.trans(U32, FD.flat__nthc(FD.spec_common__update(U32, FD.array__slots(U32, D), i, v), k), FD.flat__nthc(FD.array__slots(U32, D), k), 0,
    FD.flat__nthc_other(FD.array__slots(U32, D), i, k, v, FD.nat__is_eq_lt(i, k, hk)), hz)

def bd_app(+xs: +List<U32>, +ys: +List<U32>, +hx: {{SP.bytes_domain(xs) == {TRUE}}}, +hy: {{SP.bytes_domain(ys) == {TRUE}}})
    -> {{SP.bytes_domain(List.append(&2, U32, xs, ys)) == {TRUE}}}:
  match xs:
    case Nil{{}}: hy
    case Con{{+x, +t}}:
      V.and_true(U32.is_lt(x, 256), SP.bytes_domain(List.append(&2, U32, t, ys)), V.and_left(U32.is_lt(x, 256), SP.bytes_domain(t), hx),
        bd_app(t, ys, V.and_right(U32.is_lt(x, 256), SP.bytes_domain(t), hx), hy))
'''


# ---- the leaf: Attestation --------------------------------------------------------------------------

def leaf():
    g, xs = VBE_.cont_names()
    x = next(x for x in xs if x.n == 'Attestation')
    FS, H, po = x.FS, x.H, x.po
    assert po == 0 and FS == 236 and H == 59
    fixed = [f for f in x.fields if f['kind'] == 'fix']
    ks = [k for k in range(H) if k != po]
    ws = [f'w{k}' for k in ks]
    WA = ', '.join(ws)
    hdr = []
    for f in x.fields:
        hdr += [f'w{f["k"] + j}' for j in range(f['ft'].W)] if f['kind'] == 'fix' else [str(FS)]
    I = Iface('Attestation', 'A', ws, H, f'E.OBJE({WA}, T, K)', f'E.VAL({WA}, T, K)', hdr, 'E.SFS(K)', 'Spec.Attestation()')
    return g, x, fixed, I


def Y0(I):
    return 'VS.bt(U32.to_nat(CO.NK(K)), F.limbs(VB.wdr(59n, FD.array__slots(U32, E.OUTA(T, K)))))'


def leaf_text():
    g, x, fixed, I = leaf()
    ws, HX = I.ws, I.HX
    CW, CWa, HW, HWa, SRC, SRCa = hyps(ws, HX)
    WA = ', '.join(ws)
    Hs = f'Nat.add({HX}n, P)'
    pF = 'U32.add(pos, 236)'
    pO = 'U32.add(pos, 0)'
    L = HEAD + ['', '# GENERATED by codegen/var_agg_enc.py. Do not edit.',
                '# The writer of Attestation at a word-aligned position pos = 4 P of an existing output tree D:',
                '# the interface of codegen/var_agg_enc.py (putw, hdrw, payw, ow_hi, partsE).', '']
    w = L.append

    def V(f):
        return '[' + ', '.join(f'w{f["k"] + j}' for j in range(f['ft'].W)) + ']'

    def fobj(f):
        return f['ft'].obj([f'w{f["k"] + j}' for j in range(f['ft'].W)])

    def X(j):
        return f'X{j}({CWa})'
    w(f'def X0({CW}) -> {TR}: FD.array__upd(U32, dd, D, Nat.add(0n, P), 236)')
    w(f'def XA({CW}) -> {TR}: CT.OA(dd, {X(0)}, T, {pF}, {Hs}, K)')
    prev = f'XA({CWa})'
    for j, f in enumerate(fixed):
        w(f'def X{j + 1}({CW}) -> {TR}: VF.updv({V(f)}, dd, {prev}, Nat.add({f["k"]}n, P))')
        prev = X(j + 1)
    last = len(fixed)
    w(f'def W({CW}) -> {TR}: {X(last)}')
    w(common_lemmas(HX))
    MTK = f'VBT.MT(dd, {X(0)}, T, {Hs}, K)'
    VV = f'U32.or(VB.slot({MTK}, Nat.add({Hs}, {q})), VBT.DMK({pF}, K))'
    NB = 'VC.NW(O.bits_nbytes(K))'

    def hqq(a):
        return f'hq({a}, dd, P, K, {{==}}, hR)'
    w(f'''def hQ({CW}, {HW}) -> {{Nat.is_lt(Nat.add({Hs}, {q}), VB.pw(dd)) == {TRUE}}}:
  FD.nat__lt_le_trans(Nat.add({Hs}, {q}), Nat.add({Hs}, Nat.add({q}, 1n)), VB.pw(dd), FD.nat__lt_add_left({q}, Nat.add({q}, 1n), {Hs}, DL.lt_add1({q})), hR)

# The bit list's words end within the room: NW + H <= H + q + 1 <= 2^dd.
def hdstW({CW}, {HW}) -> {{Nat.is_le(Nat.add({NB}, {Hs}), VB.pw(dd)) == {TRUE}}}:
  +hN = {HN}
{VBE_CF()}
  +cA = DL.p1(DL.TA(j, b), DL.CB(j, b), cf)
  +cB = DL.p1(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))
  +eNW = Equal.trans(Nat, {NB}, Nat.add({q}, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add({q}, BW.CWr(DL.RK(K))),
    VBT.FNWnb(K, {KB}n, {{==}}, E.hKk(K, hN), j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {{==}}, {{==}}, {{==}}, cB, {{==}}),
    Equal.cong(Nat, Nat, z => Nat.add({q}, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(DL.RK(K)), cA))
  +h1 = FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add({q}, 1n)) == {TRUE}}}, Nat.add({q}, BW.CWr(DL.RK(K))), {NB},
    Equal.sym(Nat, {NB}, Nat.add({q}, BW.CWr(DL.RK(K))), eNW), Order.add_left({q}, BW.CWr(DL.RK(K)), 1n, CO.cwle(DL.RK(K))))
  FD.nat__le_trans(Nat.add({NB}, {Hs}), Nat.add({Hs}, Nat.add({q}, 1n)), VB.pw(dd),
    FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({NB}, {Hs}), z) == {TRUE}}}, Nat.add(Nat.add({q}, 1n), {Hs}), Nat.add({Hs}, Nat.add({q}, 1n)),
      FD.nat__add_comm(Nat.add({q}, 1n), {Hs}), Order.add_right({NB}, Nat.add({q}, 1n), {Hs}, h1)), hR)

def hP0({CW}, {HW}) -> {{Nat.is_lt(Nat.add(0n, P), VB.pw(dd)) == {TRUE}}}:
  FD.nat__lt_le_trans(Nat.add(0n, P), {Hs}, VB.pw(dd), VB.lt_kk(0n, {HX}n, P, {{==}}), {hqq(f"{HX}n")})

def pf0({CW}, {HW}) -> {{FD.array__perfect(U32, dd, {X(0)}) == {TRUE}}}: FD.array__upd_perfect(U32, dd, D, Nat.add(0n, P), 236, pfD)
def pfM({CW}, {HW}) -> {{FD.array__perfect(U32, dd, {MTK}) == {TRUE}}}: VB.mone_perfect({NB}, 0n, {Hs}, dd, {X(0)}, T, pf0({CWa}, {HWa}))
def pfA({CW}, {HW}) -> {{FD.array__perfect(U32, dd, XA({CWa})) == {TRUE}}}:
  FD.array__upd_perfect(U32, dd, {MTK}, Nat.add({Hs}, {q}), {VV}, pfM({CWa}, {HWa}))''')
    for j, f in enumerate(fixed):
        pv = 'pfA' if j == 0 else f'pf{j}'
        w(f'def pf{j + 1}({CW}, {HW}) -> {{FD.array__perfect(U32, dd, {X(j + 1)}) == {TRUE}}}:')
        w(f'  VF.updv_perfect({V(f)}, dd, {"XA(" + CWa + ")" if j == 0 else X(j)}, Nat.add({f["k"]}n, P), {pv}({CWa}, {HWa}))')
    w(f'def pfW({CW}, {HW}) -> {{FD.array__perfect(U32, dd, W({CWa})) == {TRUE}}}: pf{last}({CWa}, {HWa})')

    def pfd(j):  # the tree before fixed field j
        return f'pfA({CWa}, {HWa})' if j == 0 else f'pf{j}({CWa}, {HWa})'

    def tb(j):
        return f'XA({CWa})' if j == 0 else X(j)
    # the bit list writer
    w(f'''
# vbitcont.enc_at: the bit list's writer at P + 59.
def cra({CW}, {HW}) -> CT.CRA(dd, {X(0)}, T, {pF}, {Hs}, K):
  (+wf, +r1) = rep
  +hN = {HN}
  +hz = VR.rep_hz(dw, T, K, {KB}n, {LIMN}, pfT, {{==}}, hN, E.hNk0(), CO.qs_sized(dw, K, {KB}n, {LIMN}, {{==}}, hN, E.hNk0(), hcap), wf)
  +eF = eoff(pos, 236, {HX}n, dd, P, K, e, {{==}}, {{==}}, hdd, hR)
  +hP = hP0({CWa}, {HWa})
  +z0 = sl_up(dd, D, Nat.add(0n, P), 236, Nat.add({Hs}, {q}), pfD, hP,
    FD.nat__lt_le_trans(Nat.add(0n, P), {Hs}, Nat.add({Hs}, {q}), VB.lt_kk(0n, {HX}n, P, {{==}}), Order.below_sum({Hs}, {q})), hz0)
  +zq = sl_up(dd, D, Nat.add(0n, P), 236, Nat.add(VY.QL(O.bits_nbytes(K)), {Hs}), pfD, hP,
    FD.nat__lt_le_trans(Nat.add(0n, P), {Hs}, Nat.add(VY.QL(O.bits_nbytes(K)), {Hs}), VB.lt_kk(0n, {HX}n, P, {{==}}), Order.left_below_sum(VY.QL(O.bits_nbytes(K)), {Hs})), hzq)
  CT.enc_at(dd, dw, {X(0)}, T, {pF}, {Hs}, K, {KB}n, {KY}n, {LIMN}, pf0({CWa}, {HWa}), pfT, hdd, hdw, {{==}}, {{==}},
    eF, VF.al_3({pF}, {Hs}, eF), VF.al_q({pF}, {Hs}, eF), hN, E.hNk0(), {{==}}, hR, hcap, hz, z0, zq)
''')
    # putw
    Tn = 'T.Attestation'
    OBJ = I.obj
    FIXOBJS = ', '.join(fobj(f) for f in fixed)
    RP = f'(FD.array__thaw(U32, W({CWa})), ({OBJ}, E.SFS(K)))'
    TP = f'Array<U32> & ({Tn} & U32)'
    OBB = 'E.OB(T, K)'

    def puts(j, inner):
        t = inner
        for f in fixed[j:]:
            t = f'T.{f["ft"].p}_put({t}, U32.add(pos, {f["c"]}), {fobj(f)})'
        return t
    w(f'''# The writer at pos = 4 P returns the output tree W and the object's size.
def putw({CW}, {HW})
    -> {{{Tn}_putn(FD.array__thaw(U32, D), pos, {OBJ}) == {RP} : {TP}}}:
  +hN = {HN}
  +c = cra({CWa}, {HWa})
  +hd31 = FD.nat__lt_trans(dd, 29n, 31n, hdd, {{==}})
  +eO = eoff(pos, 0, 0n, dd, P, K, e, {{==}}, {{==}}, hdd, hR)
  %Equal.sym(U32, U32.and({pO}, 3), 0, VF.al_3({pO}, Nat.add(0n, P), eO)) :
    {{{Tn}_pw0(pos, {FIXOBJS}, T.bits131072_pvb(236, T.bits131072_pk(O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D), {pO}, 236), {pF}, T.bits131072_valid({OBB})))) == {RP} : {TP}}}
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D), U32.shrn({pO}, 2n), 236), FD.array__thaw(U32, {X(0)}),
      VB.set_n(dd, D, U32.shrn({pO}, 2n), Nat.add(0n, P), 236, VF.al_q({pO}, Nat.add(0n, P), eO), VB.lt32(dd, hd31), hP0({CWa}, {HWa}), pfD)) :
    {{{Tn}_pw0(pos, {FIXOBJS}, T.bits131072_pvb(236, T.bits131072_pk(_, {pF}, T.bits131072_valid({OBB})))) == {RP} : {TP}}}
  %Equal.sym(O.Bits & Bool, T.bits131072_valid({OBB}), ({OBB}, True{{}}),
      CT.valid_eval(dw, T, K, {KB}n, {LIMN}, 131072, pfT, hdw, {{==}}, {{==}}, hN, E.hNk0(), hcap, hv)) :
    {{{Tn}_pw0(pos, {FIXOBJS}, T.bits131072_pvb(236, T.bits131072_pk(FD.array__thaw(U32, {X(0)}), {pF}, _))) == {RP} : {TP}}}
  %Equal.sym(Array<U32> & (O.Bits & U32), O.put_bits_n(FD.array__thaw(U32, {X(0)}), {pF}, {OBB}), (FD.array__thaw(U32, XA({CWa})), ({OBB}, CO.NK(K))),
      CT.cra1(dd, {X(0)}, T, {pF}, {Hs}, K, c)) :
    {{{Tn}_pw0(pos, {FIXOBJS}, T.bits131072_pvb(236, _)) == {RP} : {TP}}}
  %Equal.sym(U32, O.padd(236, CO.NK(K)), E.SFS(K), E.padd(K, hN)) :
    {{({puts(0, f"FD.array__thaw(U32, XA({CWa}))")}, ({OBJ}, _)) == {RP} : {TP}}}''')
    for j, f in enumerate(fixed):
        ft = f['ft']
        cur = f'T.{ft.p}_put(FD.array__thaw(U32, {tb(j)}), U32.add(pos, {f["c"]}), {fobj(f)})'
        wsx = ', '.join(f'w{f["k"] + i}' for i in range(ft.W))
        w(f'  %Equal.sym(Array<U32>, {cur}, FD.array__thaw(U32, {X(j + 1)}),')
        w(f'      VT.put_{ft.p}(dd, {tb(j)}, U32.add(pos, {f["c"]}), Nat.add({f["k"]}n, P), eoff(pos, {f["c"]}, {f["k"]}n, dd, P, K, e, {{==}}, {{==}}, hdd, hR), hdd, {pfd(j)}, {hqq(f"Nat.add({ft.W}n, {f[chr(107)]}n)")}, {wsx})) :')
        w(f'    {{({puts(j + 1, "_")}, ({OBJ}, E.SFS(K))) == {RP} : {TP}}}')
    w('  {==}')
    w('')

    # ---- windows ----
    def win(mm, p, t):
        return f'VF.WIN({mm}, {p}, FD.array__slots(U32, {t}))'
    WL = f'W({CWa})'
    SA = f'FD.array__slots(U32, XA({CWa}))'
    w(f'''# A window below the bit list's words is the tree's before the bit list write.
def xa_lo({CW}, {HW}, +m: Nat, +p: Nat, +h: {{Nat.is_le(Nat.add(m, p), {Hs}) == {TRUE}}})
    -> {{{win("m", "p", f"XA({CWa})")} == {win("m", "p", X(0))} : {LT}}}:
  %Equal.sym({LT}, {SA}, FD.spec_common__update(U32, FD.array__slots(U32, {MTK}), Nat.add({Hs}, {q}), {VV}),
      FD.array__upd_slots(U32, dd, {MTK}, Nat.add({Hs}, {q}), {VV}, hQ({CWa}, {HWa}), pfM({CWa}, {HWa}))) :
    {{VF.WIN(m, p, _) == {win("m", "p", X(0))} : {LT}}}
  Equal.trans({LT}, VF.WIN(m, p, FD.spec_common__update(U32, FD.array__slots(U32, {MTK}), Nat.add({Hs}, {q}), {VV})), {win("m", "p", MTK)}, {win("m", "p", X(0))},
    VF.lmv_hi([{VV}], Nat.add({Hs}, {q}), m, p, FD.array__slots(U32, {MTK}), FD.nat__le_trans(Nat.add(m, p), {Hs}, Nat.add({Hs}, {q}), h, Order.below_sum({Hs}, {q}))),
    VN.pm_hi({NB}, {Hs}, dd, {X(0)}, T, m, p, pf0({CWa}, {HWa}), hdstW({CWa}, {HWa}), h))
''')

    def peel_fixed(mm, p, rel, stop):
        steps = []
        for g_ in range(len(fixed) - 1, stop - 1, -1):
            fg = fixed[g_]
            kind, hproof = rel(fg)
            hb = hqq(f'Nat.add({fg["ft"].W}n, {fg["k"]}n)')
            pr = f'V2.peel_{kind}({V(fg)}, dd, {tb(g_)}, Nat.add({fg["k"]}n, P), {mm}, {p}, {pfd(g_)}, {hb}, {hproof})'
            steps.append((win(mm, p, X(g_ + 1)), win(mm, p, tb(g_)), pr))
        return steps
    segs = []
    for i, f in enumerate(x.fields):
        if f['kind'] == 'fix':
            j = fixed.index(f)
            k0, W0 = f['k'], f['ft'].W

            def rel(fg, k0=k0, W0=W0):
                if fg['k'] + fg['ft'].W <= k0:
                    return 'lo', shift(fg['k'] + fg['ft'].W, k0)
                return 'hi', shift(k0 + W0, fg['k'])
            steps = peel_fixed(f'{W0}n', f'Nat.add({k0}n, P)', rel, j + 1)
            lastp = f'V2.own({V(f)}, dd, {tb(j)}, Nat.add({k0}n, P), {pfd(j)}, {hqq(f"Nat.add({W0}n, {k0}n)")})'
            w(f'def seg{i}({CW}, {HW}) -> {{{win(f"{W0}n", f"Nat.add({k0}n, P)", WL)} == {V(f)} : {LT}}}:')
            w('  ' + chain(steps, V(f), lastp))
            w('')
            segs.append((i, W0, k0, V(f)))
        else:
            steps = peel_fixed('1n', 'Nat.add(0n, P)', lambda fg: ('hi', shift(1, fg['k'])), 0)
            steps.append((win('1n', 'Nat.add(0n, P)', f'XA({CWa})'), win('1n', 'Nat.add(0n, P)', X(0)),
                          f'xa_lo({CWa}, {HWa}, 1n, Nat.add(0n, P), {shift(1, HX)})'))
            lastp = f'V2.own([236], dd, D, Nat.add(0n, P), pfD, {hqq("Nat.add(1n, 0n)")})'
            w(f'def seg{i}({CW}, {HW}) -> {{{win("1n", "Nat.add(0n, P)", WL)} == [236] : {LT}}}:')
            w('  ' + chain(steps, '[236]', lastp))
            w('')
            segs.append((i, 1, 0, '[236]'))
    w(hdr_text(segs, HX, CW, CWa, HW, HWa, WL, I.hdr))
    # payload
    steps = peel_fixed(f'Nat.add({q}, 1n)', Hs, lambda fg: ('lo', shift(fg['k'] + fg['ft'].W, HX)), 0)
    WQ = win(f'Nat.add({q}, 1n)', Hs, f'XA({CWa})')
    w(f'''# The bit list's bytes after the header.
def payw({CW}, {HW})
    -> {{VS.bt(U32.to_nat(CO.NK(K)), F.limbs({win(f"Nat.add({q}, 1n)", Hs, WL)})) == {Y0(I)} : +List<U32>}}:
  +hN = {HN}
  +c = cra({CWa}, {HWa})
  +c0 = E.cra({SRCa})
  %Equal.sym({LT}, {win(f"Nat.add({q}, 1n)", Hs, WL)}, {WQ},
      {chain(steps, WQ, "{==}")}) :
    {{VS.bt(U32.to_nat(CO.NK(K)), F.limbs(_)) == {Y0(I)} : +List<U32>}}
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat(CO.NK(K)), F.limbs({WQ})), VS.bt(U32.to_nat(CO.NK(K)), F.limbs(VB.wdr({Hs}, {SA}))), VY.bt_take(Nat.add({q}, 1n), U32.to_nat(CO.NK(K)), VB.wdr({Hs}, {SA}), E.nkq(K, hN))) :
    {{_ == {Y0(I)} : +List<U32>}}
  %CT.cra2(dd, {X(0)}, T, {pF}, {Hs}, K, c) :
    {{_ == {Y0(I)} : +List<U32>}}
  CT.cra2(E.DO(K), E.OUT1(K), T, U32.add(0, 236), 59n, K, c0)
''')
    # ow_hi
    steps = peel_fixed('m', 'p', lambda fg: ('hi', f'FD.nat__le_trans(Nat.add(m, p), P, Nat.add({fg["k"]}n, P), hm, Order.left_below_sum({fg["k"]}n, P))'), 0)
    steps.append((win('m', 'p', f'XA({CWa})'), win('m', 'p', X(0)),
                  f'xa_lo({CWa}, {HWa}, m, p, FD.nat__le_trans(Nat.add(m, p), P, {Hs}, hm, Order.left_below_sum({HX}n, P)))'))
    lastp = f'V2.peel_hi([236], dd, D, Nat.add(0n, P), m, p, pfD, {hqq("Nat.add(1n, 0n)")}, hm)'
    WD = 'VF.WIN(m, p, FD.array__slots(U32, D))'
    w('# A window before P is that of D.')
    w(f'def ow_hi({CW}, {HW}, +m: Nat, +p: Nat, +hm: {{Nat.is_le(Nat.add(m, p), P) == {TRUE}}})')
    w(f'    -> {{{win("m", "p", WL)} == {WD} : {LT}}}:')
    w('  ' + chain(steps, WD, lastp))
    w('')
    # partsE
    HDRL = '[' + ', '.join(I.hdr) + ']'
    nodes = VL.field_nodes(g, x, lambda k: f'w{k}')
    vi = [f['kind'] for f in x.fields].index('bits')
    VALB = f'S.BitsValue{{BO.bview({OBB})}}'
    vals, schs, parts = [], [], []
    Y = Y0(I)
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append(VALB)
            schs.append(f'S.BitList{{{LIMN}}}')
            parts.append(f'S.Variable{{{Y}}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chn(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chn(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if x.fields[i]['kind'] == 'fix':
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chn(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chn(i + 1)}, {Y}, {rest}, '
                f'E.bparts({SRCa}), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {Y})'
    RHSp = f'Some{{[S.Variable{{List.append(&2, U32, F.limbs({HDRL}), {Y})}}]}}'
    w(f'''# The spec parts of the value: one variable part, the header's limbs and the bit list's bytes.
def partsE({SRC})
    -> {{Codec.parts({I.val}, Spec.Attestation()) == {RHSp} : {MP}}}:
  %Equal.sym({MP}, Codec.parts({items(0)}, {chn(0)}), Some{{[{', '.join(parts)}]}},
      {cat(0)}) :
    {{Codec.aggregate(_, None{{}}) == {RHSp} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, {Y}, {POST})), Some{{{ENCR}}}, VBC.enc_fpvb({PRE}, {Y}, {POST}, VZ.bd_btl(U32.to_nat(CO.NK(K)), VB.wdr(59n, FD.array__slots(U32, E.OUTA(T, K)))), E.fitY({SRCa}))) :
    {{Codec.one(_, None{{}}) == {RHSp} : {MP}}}
  {{==}}

# The value's spec bytes are bytes.
def domX({SRC}) -> {{SP.bytes_domain(List.append(&2, U32, F.limbs({HDRL}), {Y})) == {TRUE}}}:
  bd_app(F.limbs({HDRL}), {Y}, F.domain_limbs({HDRL}), VZ.bd_btl(U32.to_nat(CO.NK(K)), VB.wdr(59n, FD.array__slots(U32, E.OUTA(T, K)))))
''')
    return '\n'.join(L) + '\n'


def VBE_CF():
    return '''  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +hj = FD.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = FD.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)'''


def hdr_text(segs, HX, CW, CWa, HW, HWa, WL, hdr, head=None, child=None):
    """hdrw: WIN(HX, P) == the flat header, by splitting off each own segment in turn
    (segs: (index, words, k, words list term)), then (child) the child's header."""
    HDRL = '[' + ', '.join(hdr) + ']'
    L = []
    w = L.append

    def win(mm, p):
        return f'VF.WIN({mm}, {p}, FD.array__slots(U32, {WL}))'
    w(f'def hdrw({CW}, {HW}) -> {{{win(f"{HX}n", "P")} == {HDRL} : {LT}}}:')
    R, s = HX, 0
    pre = lambda t: t  # noqa: E731
    items = list(segs) + ([child] if child else [])
    for idx, it in enumerate(items):
        i, Wd, k, Vs = it[:4]
        assert k == s, (k, s)
        ps = f'Nat.add({s}n, P)'
        proof = f'seg{i}({CWa}, {HWa})' if len(it) == 4 else it[4]
        if idx < len(items) - 1:
            w(f'  %Equal.sym({LT}, {win(f"Nat.add({Wd}n, {R - Wd}n)", ps)}, VF.app({win(f"{Wd}n", ps)}, {win(f"{R - Wd}n", f"Nat.add({Wd}n, {ps})")}),')
            w(f'      VN.win_split2({Wd}n, {R - Wd}n, {ps}, FD.array__slots(U32, {WL}))) :')
            w(f'    {{{pre("_")} == {HDRL} : {LT}}}')
            w(f'  %Equal.sym({LT}, {win(f"{Wd}n", ps)}, {Vs}, {proof}) :')
            rest = win(f'{R - Wd}n', f'Nat.add({s + Wd}n, P)')
            w(f'    {{{pre(f"VF.app(_, {rest})")} == {HDRL} : {LT}}}')
            pre = (lambda p0, Vs: (lambda t: p0(f'VF.app({Vs}, {t})')))(pre, Vs)
            R, s = R - Wd, s + Wd
        else:
            assert R == Wd, (R, Wd)
            w(f'  %Equal.sym({LT}, {win(f"{Wd}n", ps)}, {Vs}, {proof}) :')
            w(f'    {{{pre("_")} == {HDRL} : {LT}}}')
    w('  {==}')
    w('')
    return '\n'.join(L)


# ---- parents: fixed fields around one variable child ------------------------------------------------

class Child:
    """What a parent needs of its child's module (imported under alias)."""

    def __init__(self, I, mod, alias, FStot, eS, size_eval, boxed):
        self.I, self.mod, self.alias, self.FStot, self.eS, self.size_eval, self.boxed = I, mod, alias, FStot, eS, size_eval, boxed


def playout(n):
    import schema
    import generate as G
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for nm, t in names.items():
        g.shape(t)
    t = names[n]
    fields, pos, var = [], 0, None
    for fname, ft in t.fields:
        if ft.fixed():
            f = VL.FT(g, ft)
            fields.append({'kind': 'fix', 'name': fname, 'ft': f, 'c': pos, 'k': pos // 4, 't': ft})
            pos += f.size
        else:
            assert var is None
            var = {'kind': 'var', 'name': fname, 'c': pos, 'k': pos // 4, 't': ft}
            fields.append(var)
            pos += 4
    return g, fields, pos


def parent_text(n, pre, ch, doc):
    g, fields, FS = playout(n)
    H = FS // 4
    var = next(f for f in fields if f['kind'] == 'var')
    po, co = var['k'], var['c']
    fixed = [f for f in fields if f['kind'] == 'fix']
    C = ch.I
    HX = H + C.HX
    FSX = 4 * HX
    own = [f'{pre}{k}' for k in range(H) if k != po]
    ws = own + C.ws
    WA = ', '.join(ws)
    CW, CWa, HW, HWa, SRC, SRCa = hyps(ws, HX)
    CSRCa = f'{", ".join(C.ws)}, dw, T, K, pfT, hdw, rep, hcap, hv'
    Hs = f'Nat.add({HX}n, P)'
    Pc = f'Nat.add({H}n, P)'
    pC = f'U32.add(pos, {FS})'
    pO = f'U32.add(pos, {co})'
    ca = ch.alias

    def V(f):
        return '[' + ', '.join(f'{pre}{f["k"] + j}' for j in range(f['ft'].W)) + ']'

    def fobj(f):
        return f['ft'].obj([f'{pre}{f["k"] + j}' for j in range(f['ft'].W)])
    OBJc = C.obj
    OB_ = f'O.BSome{{{OBJc}, O.BNone{{}}}}' if ch.boxed else OBJc
    objs = [fobj(f) if f['kind'] == 'fix' else OB_ for f in fields]
    Tn = f'T.{n}'
    OBJ = f'{Tn}{{' + ', '.join(objs) + '}'
    FIXOBJS = ', '.join(fobj(f) for f in fixed)
    hdr = []
    for f in fields:
        hdr += [f'{pre}{f["k"] + j}' for j in range(f['ft'].W)] if f['kind'] == 'fix' else [str(FS)]
    hdr += C.hdr
    HDRL = '[' + ', '.join(hdr) + ']'
    Y = Y0(C)
    L = HEAD + [f'import ./{ch.mod} as {ca}', '', '# GENERATED by codegen/var_agg_enc.py. Do not edit.'] + ['# ' + l for l in doc] + ['']
    w = L.append

    def X(j):
        return f'X{j}({CWa})'
    YC = f'XC({CWa})'
    w(f'def SFSX(+K: U32) -> U32: U32.add({FS}, {C.sfs})')
    w(f'def X0({CW}) -> {TR}: FD.array__upd(U32, dd, D, Nat.add({po}n, P), {FS})')
    CWc = f'{", ".join(C.ws)}, dd, {X(0)}, {Pc}, {pC}, T, K'
    w(f'def XC({CW}) -> {TR}: {ca}.W({CWc})')
    prev = YC
    for j, f in enumerate(fixed):
        w(f'def X{j + 1}({CW}) -> {TR}: VF.updv({V(f)}, dd, {prev}, Nat.add({f["k"]}n, P))')
        prev = X(j + 1)
    last = len(fixed)
    w(f'def W({CW}) -> {TR}: {X(last)}')
    w(f'def OBJX({wsig(ws)}, +T: {TR}, +K: U32) -> {Tn}: {OBJ}')
    w(common_lemmas(HX))

    def hqq(a):
        return f'hq({a}, dd, P, K, {{==}}, hR)'
    QB = 'VY.QL(O.bits_nbytes(K))'
    Hc_s = f'Nat.add({C.HX}n, {Pc})'
    w(f'def hPo({CW}, {HW}) -> {{Nat.is_lt(Nat.add({po}n, P), VB.pw(dd)) == {TRUE}}}:')
    w(f'  FD.nat__lt_le_trans(Nat.add({po}n, P), {Pc}, VB.pw(dd), VB.lt_kk({po}n, {H}n, P, {{==}}), {hqq(f"{H}n")})')
    w(f'def pf0({CW}, {HW}) -> {{FD.array__perfect(U32, dd, {X(0)}) == {TRUE}}}: FD.array__upd_perfect(U32, dd, D, Nat.add({po}n, P), {FS}, pfD)')
    w(f'def eC({CW}, {HW}) -> {{U32.to_nat({pC}) == A.quad({Pc}) : Nat}}: eoff(pos, {FS}, {H}n, dd, P, K, e, {{==}}, {{==}}, hdd, hR)')
    for nm, idx, h2 in (('z0c', f'Nat.add({Hc_s}, {q})', f'Order.below_sum({Hc_s}, {q})'),
                        ('zqc', f'Nat.add({QB}, {Hc_s})', f'Order.left_below_sum({QB}, {Hc_s})')):
        hz = 'hz0' if nm == 'z0c' else 'hzq'
        w(f'def {nm}({CW}, {HW}) -> {{VB.slot({X(0)}, {idx}) == 0 : U32}}:')
        w(f'  sl_up(dd, D, Nat.add({po}n, P), {FS}, {idx}, pfD, hPo({CWa}, {HWa}),')
        w(f'    FD.nat__lt_le_trans(Nat.add({po}n, P), {Pc}, {idx}, VB.lt_kk({po}n, {H}n, P, {{==}}),')
        w(f'      FD.nat__le_trans({Pc}, {Hc_s}, {idx}, Order.left_below_sum({C.HX}n, {Pc}), {h2})), {hz})')
    CHa = f'{CWc}, eC({CWa}, {HWa}), pf0({CWa}, {HWa}), hdd, hR, z0c({CWa}, {HWa}), zqc({CWa}, {HWa}), dw, pfT, hdw, rep, hcap, hv'
    w(f'def pfC({CW}, {HW}) -> {{FD.array__perfect(U32, dd, {YC}) == {TRUE}}}: {ca}.pfW({CHa})')
    for j, f in enumerate(fixed):
        pv = 'pfC' if j == 0 else f'pf{j}'
        tb_ = YC if j == 0 else X(j)
        w(f'def pf{j + 1}({CW}, {HW}) -> {{FD.array__perfect(U32, dd, {X(j + 1)}) == {TRUE}}}:')
        w(f'  VF.updv_perfect({V(f)}, dd, {tb_}, Nat.add({f["k"]}n, P), {pv}({CWa}, {HWa}))')
    w(f'def pfW({CW}, {HW}) -> {{FD.array__perfect(U32, dd, W({CWa})) == {TRUE}}}: pf{last}({CWa}, {HWa})')

    def pfd(j):
        return f'pfC({CWa}, {HWa})' if j == 0 else f'pf{j}({CWa}, {HWa})'

    def tb(j):
        return YC if j == 0 else X(j)
    # sizes
    BOUND = FSX + 131073
    CB = ch.FStot
    NKn = 'U32.to_nat(CO.NK(K))'
    HNC = f'+K: U32, +hN: {{Nat.is_le(U32.to_nat(K), {LIMN}) == {TRUE}}}'
    CS = C.sfs
    w('')
    w(f'# The sizes: SFSX(K) = {FSX} + (K / 8 + 1).')
    w(f'def eSX({HNC}) -> {{U32.to_nat(SFSX(K)) == Nat.add({FSX}n, {NKn}) : Nat}}:')
    w(f'  +h = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({FS}n, z), U32.to_nat({BOUND})) == {TRUE}}}, Nat.add({CB}n, {NKn}), U32.to_nat({CS}),')
    w(f'    Equal.sym(Nat, U32.to_nat({CS}), Nat.add({CB}n, {NKn}), {ch.eS}(K, hN)),')
    w(f'    FD.nat__le_trans(Nat.add({FS}n, Nat.add({CB}n, {NKn})), Nat.add({FS}n, Nat.add({CB}n, Nat.add({LIMN}, 1n))), U32.to_nat({BOUND}),')
    w(f'      Order.add_left({FS}n, Nat.add({CB}n, {NKn}), Nat.add({CB}n, Nat.add({LIMN}, 1n)), Order.add_left({CB}n, {NKn}, Nat.add({LIMN}, 1n), E.eNK(K, hN))), {{==}}))')
    w(f'  Equal.trans(Nat, U32.to_nat(SFSX(K)), Nat.add({FS}n, U32.to_nat({CS})), Nat.add({FSX}n, {NKn}), A.add_le({FS}, {CS}, {BOUND}, h),')
    w(f'    Equal.cong(Nat, Nat, z => Nat.add({FS}n, z), U32.to_nat({CS}), Nat.add({CB}n, {NKn}), {ch.eS}(K, hN)))')
    w('')
    w(f'def paddX({HNC}) -> {{O.padd({FS}, {CS}) == SFSX(K) : U32}}:')
    w(f'  VE.padd_ok({FS}, {CS}, VE.winit(31n, VE.bits32({FS})), VE.winit(31n, VE.bits32({CS})), {{==}},')
    w(f'    VE.small_pad({CS}, 18n, {{==}}, FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(18n)) == {TRUE}}}, Nat.add({CB}n, {NKn}), U32.to_nat({CS}),')
    w(f'      Equal.sym(Nat, U32.to_nat({CS}), Nat.add({CB}n, {NKn}), {ch.eS}(K, hN)),')
    w(f'      FD.nat__le_lt_trans(Nat.add({CB}n, {NKn}), Nat.add({CB}n, Nat.add({LIMN}, 1n)), FD.spec_common__pow2(18n), Order.add_left({CB}n, {NKn}, Nat.add({LIMN}, 1n), E.eNK(K, hN)), {{==}}))))')
    w('')
    OBJa = f'OBJX({WA}, T, K)'
    szin = f'T.{C.n}_bx_size_back(_)' if ch.boxed else '_'
    w('# The runtime size of the object.')
    w(f'def size_eval({SRC})')
    w(f'    -> {{{Tn}_size({OBJa}) == ({OBJa}, SFSX(K)) : {Tn} & U32}}:')
    w(f'  +hN = {HN}')
    w(f'  %Equal.sym({C.T} & U32, {C.T}_size({OBJc}), ({OBJc}, {CS}), {ch.size_eval}({CSRCa})) :')
    w(f'    {{{Tn}_sz0({FIXOBJS}, {FS}, {szin}) == ({OBJa}, SFSX(K)) : {Tn} & U32}}')
    w(f'  %Equal.sym(U32, O.padd({FS}, {CS}), SFSX(K), paddX(K, hN)) : {{({OBJa}, _) == ({OBJa}, SFSX(K)) : {Tn} & U32}}')
    w('  {==}')
    w('')
    # putw
    RP = f'(FD.array__thaw(U32, W({CWa})), ({OBJa}, SFSX(K)))'
    TP = f'Array<U32> & ({Tn} & U32)'
    if ch.boxed:
        def inner(outt):
            return f'T.{C.n}_bx_pvb({FS}, T.{C.n}_bx_putk({outt}, {pC}, {OB_}))'
        after = f'T.{C.n}_bx_pvb({FS}, T.{C.n}_bx_pk_back(_))'
    else:
        def inner(outt):
            return f'T.{C.n}_pvb({FS}, T.{C.n}_putk({outt}, {pC}, {OB_}))'
        after = f'T.{C.n}_pvb({FS}, _)'

    def puts(j, inn):
        t = inn
        for f in fixed[j:]:
            t = f'T.{f["ft"].p}_put({t}, U32.add(pos, {f["c"]}), {fobj(f)})'
        return t
    w('# The writer at pos = 4 P returns the output tree W and the object\'s size.')
    w(f'def putw({CW}, {HW})')
    w(f'    -> {{{Tn}_putn(FD.array__thaw(U32, D), pos, {OBJa}) == {RP} : {TP}}}:')
    w(f'  +hN = {HN}')
    w('  +hd31 = FD.nat__lt_trans(dd, 29n, 31n, hdd, {==})')
    w(f'  +eO = eoff(pos, {co}, {po}n, dd, P, K, e, {{==}}, {{==}}, hdd, hR)')
    w(f'  %Equal.sym(U32, U32.and({pO}, 3), 0, VF.al_3({pO}, Nat.add({po}n, P), eO)) :')
    w(f'    {{{Tn}_pw0(pos, {FIXOBJS}, {inner(f"O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D), {pO}, {FS})")}) == {RP} : {TP}}}')
    w(f'  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D), U32.shrn({pO}, 2n), {FS}), FD.array__thaw(U32, {X(0)}),')
    w(f'      VB.set_n(dd, D, U32.shrn({pO}, 2n), Nat.add({po}n, P), {FS}, VF.al_q({pO}, Nat.add({po}n, P), eO), VB.lt32(dd, hd31), hPo({CWa}, {HWa}), pfD)) :')
    w(f'    {{{Tn}_pw0(pos, {FIXOBJS}, {inner("_")}) == {RP} : {TP}}}')
    w(f'  %Equal.sym(Array<U32> & ({C.T} & U32), {C.T}_putn(FD.array__thaw(U32, {X(0)}), {pC}, {OBJc}), (FD.array__thaw(U32, {YC}), ({OBJc}, {CS})), {ca}.putw({CHa})) :')
    w(f'    {{{Tn}_pw0(pos, {FIXOBJS}, {after}) == {RP} : {TP}}}')
    w(f'  %Equal.sym(U32, O.padd({FS}, {CS}), SFSX(K), paddX(K, hN)) :')
    w(f'    {{({puts(0, f"FD.array__thaw(U32, {YC})")}, ({OBJa}, _)) == {RP} : {TP}}}')
    for j, f in enumerate(fixed):
        ft = f['ft']
        cur = f'T.{ft.p}_put(FD.array__thaw(U32, {tb(j)}), U32.add(pos, {f["c"]}), {fobj(f)})'
        wsx = ', '.join(f'{pre}{f["k"] + i}' for i in range(ft.W))
        hb = hqq(f'Nat.add({ft.W}n, {f["k"]}n)')
        w(f'  %Equal.sym(Array<U32>, {cur}, FD.array__thaw(U32, {X(j + 1)}),')
        w(f'      VT.put_{ft.p}(dd, {tb(j)}, U32.add(pos, {f["c"]}), Nat.add({f["k"]}n, P), eoff(pos, {f["c"]}, {f["k"]}n, dd, P, K, e, {{==}}, {{==}}, hdd, hR), hdd, {pfd(j)}, {hb}, {wsx})) :')
        w(f'    {{({puts(j + 1, "_")}, ({OBJa}, SFSX(K))) == {RP} : {TP}}}')
    w('  {==}')
    w('')

    # ---- windows ----
    def win(mm, p, t):
        return f'VF.WIN({mm}, {p}, FD.array__slots(U32, {t}))'
    WL = f'W({CWa})'

    def peel_fixed(mm, p, rel, stop):
        steps = []
        for g_ in range(len(fixed) - 1, stop - 1, -1):
            fg = fixed[g_]
            kind, hproof = rel(fg)
            hb = hqq(f'Nat.add({fg["ft"].W}n, {fg["k"]}n)')
            pr = f'V2.peel_{kind}({V(fg)}, dd, {tb(g_)}, Nat.add({fg["k"]}n, P), {mm}, {p}, {pfd(g_)}, {hb}, {hproof})'
            steps.append((win(mm, p, X(g_ + 1)), win(mm, p, tb(g_)), pr))
        return steps
    segs = []
    for i, f in enumerate(fields):
        if f['kind'] == 'fix':
            j = fixed.index(f)
            k0, W0 = f['k'], f['ft'].W

            def rel(fg, k0=k0, W0=W0):
                if fg['k'] + fg['ft'].W <= k0:
                    return 'lo', shift(fg['k'] + fg['ft'].W, k0)
                return 'hi', shift(k0 + W0, fg['k'])
            steps = peel_fixed(f'{W0}n', f'Nat.add({k0}n, P)', rel, j + 1)
            lastp = f'V2.own({V(f)}, dd, {tb(j)}, Nat.add({k0}n, P), {pfd(j)}, {hqq(f"Nat.add({W0}n, {k0}n)")})'
            w(f'def seg{i}({CW}, {HW}) -> {{{win(f"{W0}n", f"Nat.add({k0}n, P)", WL)} == {V(f)} : {LT}}}:')
            w('  ' + chain(steps, V(f), lastp))
            w('')
            segs.append((i, W0, k0, V(f)))
        else:
            def rel(fg):
                if fg['k'] + fg['ft'].W <= po:
                    return 'lo', shift(fg['k'] + fg['ft'].W, po)
                return 'hi', shift(po + 1, fg['k'])
            steps = peel_fixed('1n', f'Nat.add({po}n, P)', rel, 0)
            steps.append((win('1n', f'Nat.add({po}n, P)', YC), win('1n', f'Nat.add({po}n, P)', X(0)),
                          f'{ca}.ow_hi({CHa}, 1n, Nat.add({po}n, P), {shift(po + 1, H)})'))
            lastp = f'V2.own([{FS}], dd, D, Nat.add({po}n, P), pfD, {hqq(f"Nat.add(1n, {po}n)")})'
            w(f'def seg{i}({CW}, {HW}) -> {{{win("1n", f"Nat.add({po}n, P)", WL)} == [{FS}] : {LT}}}:')
            w('  ' + chain(steps, f'[{FS}]', lastp))
            w('')
            segs.append((i, 1, po, f'[{FS}]'))
    segs.sort(key=lambda s_: s_[2])
    CHDRL = '[' + ', '.join(C.hdr) + ']'
    steps = peel_fixed(f'{C.HX}n', Pc, lambda fg: ('lo', shift(fg['k'] + fg['ft'].W, H)), 0)
    w(f'def segc({CW}, {HW}) -> {{{win(f"{C.HX}n", Pc, WL)} == {CHDRL} : {LT}}}:')
    w('  ' + chain(steps, CHDRL, f'{ca}.hdrw({CHa})'))
    w('')
    w(hdr_text(segs, HX, CW, CWa, HW, HWa, WL, hdr, child=('c', C.HX, H, CHDRL, f'segc({CWa}, {HWa})')))
    steps = peel_fixed(f'Nat.add({q}, 1n)', Hs, lambda fg: ('lo', shift(fg['k'] + fg['ft'].W, HX)), 0)
    WQ = win(f'Nat.add({q}, 1n)', Hs, YC)
    w('# The bit list\'s bytes after the header.')
    w(f'def payw({CW}, {HW})')
    w(f'    -> {{VS.bt(U32.to_nat(CO.NK(K)), F.limbs({win(f"Nat.add({q}, 1n)", Hs, WL)})) == {Y} : +List<U32>}}:')
    w(f'  %Equal.sym({LT}, {win(f"Nat.add({q}, 1n)", Hs, WL)}, {WQ},')
    w(f'      {chain(steps, WQ, "{==}")}) :')
    w(f'    {{VS.bt(U32.to_nat(CO.NK(K)), F.limbs(_)) == {Y} : +List<U32>}}')
    w(f'  {ca}.payw({CHa})')
    w('')
    steps = peel_fixed('m', 'p', lambda fg: ('hi', f'FD.nat__le_trans(Nat.add(m, p), P, Nat.add({fg["k"]}n, P), hm, Order.left_below_sum({fg["k"]}n, P))'), 0)
    steps.append((win('m', 'p', YC), win('m', 'p', X(0)),
                  f'{ca}.ow_hi({CHa}, m, p, FD.nat__le_trans(Nat.add(m, p), P, {Pc}, hm, Order.left_below_sum({H}n, P)))'))
    lastp = (f'V2.peel_hi([{FS}], dd, D, Nat.add({po}n, P), m, p, pfD, {hqq(f"Nat.add(1n, {po}n)")}, '
             f'FD.nat__le_trans(Nat.add(m, p), P, Nat.add({po}n, P), hm, Order.left_below_sum({po}n, P)))')
    WD = 'VF.WIN(m, p, FD.array__slots(U32, D))'
    w('# A window before P is that of D.')
    w(f'def ow_hi({CW}, {HW}, +m: Nat, +p: Nat, +hm: {{Nat.is_le(Nat.add(m, p), P) == {TRUE}}})')
    w(f'    -> {{{win("m", "p", WL)} == {WD} : {LT}}}:')
    w('  ' + chain(steps, WD, lastp))
    w('')
    # ---- spec ----
    import var_win as W_
    body = W_.spec_defs()[n]
    if body.endswith('()'):
        body = W_.spec_defs()[body[:-2]]
    schn = re.findall(r'Schema\d+\(\)', body)
    assert len(schn) == len(fields), (schn, body)
    fake = type('x', (), {})()
    fake.fields = fields
    nodes = VL.field_nodes(g, fake, lambda k: f'{pre}{k}')
    vi = [f['kind'] for f in fields].index('var')
    XC_ = f'List.append(&2, U32, F.limbs({CHDRL}), {Y})'
    vals, schs, parts = [], [], []
    for f, nd, sn in zip(fields, nodes, schn):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append(C.val)
            schs.append(f'Spec.{sn}')
            parts.append(f'S.Variable{{{XC_}}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chn(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chn(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if fields[i]['kind'] == 'fix':
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chn(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chn(i + 1)}, {XC_}, {rest}, '
                f'{ca}.partsE({CSRCa}), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {XC_})'
    RHS = f'List.append(&2, U32, F.limbs({HDRL}), {Y})'
    RHSp = f'Some{{[S.Variable{{{RHS}}}]}}'
    TOT = FS + 4 * C.HX
    YW = 'VB.wdr(59n, FD.array__slots(U32, E.OUTA(T, K)))'
    w(f'def VALX({wsig(ws)}, +T: {TR}, +K: U32) -> S.Value: S.Sequence{{{items(0)}}}')
    w('')
    w(f'def fitX({SRC})')
    w(f'    -> {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {XC_}))) == {TRUE}}}:')
    w(f'  +hN = {HN}')
    w(f'  VS.fits_mono(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {XC_})), Nat.add({TOT}n, Nat.add({LIMN}, 1n)),')
    w(f'    Order.add_left({TOT}n, List.length(&2, U32, {Y}), Nat.add({LIMN}, 1n),')
    w(f'      FD.nat__le_trans(List.length(&2, U32, {Y}), {NKn}, Nat.add({LIMN}, 1n), VZ.bt_len_le({NKn}, F.limbs({YW})), E.eNK(K, hN))),')
    w('    {==})')
    w('')
    w('# The spec parts of the value: one variable part, the header\'s limbs and the bit list\'s bytes.')
    w(f'def partsE({SRC})')
    w(f'    -> {{Codec.parts(VALX({WA}, T, K), Spec.{n}()) == {RHSp} : {MP}}}:')
    w(f'  %Equal.sym({MP}, Codec.parts({items(0)}, {chn(0)}), Some{{[{", ".join(parts)}]}},')
    w(f'      {cat(0)}) :')
    w(f'    {{Codec.aggregate(_, None{{}}) == {RHSp} : {MP}}}')
    w(f'  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, {XC_}, {POST})), Some{{{ENCR}}}, VBC.enc_fpvb({PRE}, {XC_}, {POST}, {ca}.domX({CSRCa}), fitX({SRCa}))) :')
    w(f'    {{Codec.one(_, None{{}}) == {RHSp} : {MP}}}')
    w('  {==}')
    w('')
    w('# The value\'s spec bytes are bytes.')
    w(f'def domX({SRC}) -> {{SP.bytes_domain({RHS}) == {TRUE}}}:')
    w(f'  bd_app(F.limbs({HDRL}), {Y}, F.domain_limbs({HDRL}), VZ.bd_btl({NKn}, {YW}))')
    w('')
    # ---- the whole-buffer encoder: the interface at P = 0 of a zero tree ----
    w(top_text(n, Tn, ws, WA, HX, FSX, SRC, SRCa, OBJa, HDRL, RHS, RHSp, Y, TP, HNC, NKn, QB))
    I = Iface(n, 'C', ws, HX, f'C.OBJX({WA}, T, K)', f'C.VALX({WA}, T, K)', hdr, 'C.SFSX(K)', f'Spec.{n}()')
    I.T = Tn
    return '\n'.join(L) + '\n', I


def top_text(n, Tn, ws, WA, HX, FSX, SRC, SRCa, OBJa, HDRL, RHS, RHSp, Y, TP, HNC, NKn, QB):
    L = []
    w = L.append
    w('def DO(+K: U32) -> Nat: B.words_depth(VC.nwu(SFSX(K)))')
    w(f'def OUT({wsig(ws)}, +T: {TR}, +K: U32) -> {TR}: W({WA}, DO(K), VC.ZT(DO(K)), 0n, 0, T, K)')
    w('')
    w(f'def hNk2() -> {{Nat.is_le(Nat.add(Nat.add({FSX}n, Nat.add({LIMN}, 1n)), 3n), O.pow2n(18n)) == {TRUE}}}:')
    w(f'  %VD.s_pow2_eq(18n) : {{Nat.is_le(Nat.add(Nat.add({FSX}n, Nat.add({LIMN}, 1n)), 3n), _) == {TRUE}}}')
    w('  {==}')
    w('')
    w(f'# The encoding\'s words: the header\'s {HX}, then the bit list\'s q + 1.')
    w(f'def nwS({HNC}) -> {{VC.NW(SFSX(K)) == Nat.add({HX}n, Nat.add({q}, 1n)) : Nat}}:')
    w(VBE_CF())
    w('  +cD = DL.p1(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))))')
    w(f'  +e1 = Equal.trans(Nat, U32.to_nat(SFSX(K)), Nat.add({FSX}n, {NKn}), Nat.add(A.quad(Nat.add({HX}n, {q})), Nat.add(j, 1n)), eSX(K, hN),')
    w(f'    Equal.trans(Nat, Nat.add({FSX}n, {NKn}), Nat.add(A.quad({HX}n), Nat.add(A.quad({q}), Nat.add(j, 1n))), Nat.add(A.quad(Nat.add({HX}n, {q})), Nat.add(j, 1n)),')
    w(f'      Equal.cong(Nat, Nat, z => Nat.add({FSX}n, z), {NKn}, Nat.add(A.quad({q}), Nat.add(j, 1n)), VBT.G4(K, {KB}n, {{==}}, E.hKk(K, hN), j, {{==}})),')
    w(f'      Equal.trans(Nat, Nat.add(A.quad({HX}n), Nat.add(A.quad({q}), Nat.add(j, 1n))), Nat.add(Nat.add(A.quad({HX}n), A.quad({q})), Nat.add(j, 1n)), Nat.add(A.quad(Nat.add({HX}n, {q})), Nat.add(j, 1n)),')
    w(f'        Equal.sym(Nat, Nat.add(Nat.add(A.quad({HX}n), A.quad({q})), Nat.add(j, 1n)), Nat.add(A.quad({HX}n), Nat.add(A.quad({q}), Nat.add(j, 1n))), FD.nat__add_assoc(A.quad({HX}n), A.quad({q}), Nat.add(j, 1n))),')
    w(f'        Equal.cong(Nat, Nat, z => Nat.add(z, Nat.add(j, 1n)), Nat.add(A.quad({HX}n), A.quad({q})), A.quad(Nat.add({HX}n, {q})), VF.quad_add({HX}n, {q})))))')
    w(f'  +h3 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, 3n), O.pow2n(18n)) == {TRUE}}}, Nat.add({FSX}n, {NKn}), U32.to_nat(SFSX(K)), Equal.sym(Nat, U32.to_nat(SFSX(K)), Nat.add({FSX}n, {NKn}), eSX(K, hN)),')
    w(f'    FD.nat__le_trans(Nat.add(Nat.add({FSX}n, {NKn}), 3n), Nat.add(Nat.add({FSX}n, Nat.add({LIMN}, 1n)), 3n), O.pow2n(18n),')
    w(f'      Order.add_right(Nat.add({FSX}n, {NKn}), Nat.add({FSX}n, Nat.add({LIMN}, 1n)), 3n, Order.add_left({FSX}n, {NKn}, Nat.add({LIMN}, 1n), E.eNK(K, hN))), hNk2()))')
    w(f'  +e2 = VBT.NWq(SFSX(K), Nat.add({HX}n, {q}), Nat.add(j, 1n), 18n, {{==}}, h3, e1)')
    w(f'  Equal.trans(Nat, VC.NW(SFSX(K)), Nat.add(Nat.add({HX}n, {q}), VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n))), Nat.add({HX}n, Nat.add({q}, 1n)), e2,')
    w(f'    Equal.trans(Nat, Nat.add(Nat.add({HX}n, {q}), VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n))), Nat.add(Nat.add({HX}n, {q}), 1n), Nat.add({HX}n, Nat.add({q}, 1n)),')
    w(f'      Equal.cong(Nat, Nat, z => Nat.add(Nat.add({HX}n, {q}), z), VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n)), 1n, cD),')
    w(f'      FD.nat__add_assoc({HX}n, {q}, 1n)))')
    w('')
    w(f'def e5le() -> {{Nat.is_le(Nat.add({HX}n, Nat.add(VD.s_rng(5n, {LIMN}), 1n)), O.pow2n(13n)) == {TRUE}}}:')
    w(f'  %VD.shrk(5n, 131072) : {{Nat.is_le(Nat.add({HX}n, Nat.add(_, 1n)), O.pow2n(13n)) == {TRUE}}}')
    w(f'  %VD.s_pow2_eq(13n) : {{Nat.is_le(Nat.add({HX}n, Nat.add(U32.to_nat(U32.shrn(131072, 5n)), 1n)), _) == {TRUE}}}')
    w('  {==}')
    w('')
    w(f'def hwO({HNC}) -> {{Nat.is_le(U32.to_nat(VC.nwu(SFSX(K))), O.pow2n(13n)) == {TRUE}}}:')
    w(f'  FD.logic__subst(Nat, z => {{Nat.is_le(z, O.pow2n(13n)) == {TRUE}}}, Nat.add({HX}n, Nat.add({q}, 1n)), U32.to_nat(VC.nwu(SFSX(K))),')
    w(f'    Equal.sym(Nat, U32.to_nat(VC.nwu(SFSX(K))), Nat.add({HX}n, Nat.add({q}, 1n)), nwS(K, hN)),')
    w(f'    FD.nat__le_trans(Nat.add({HX}n, Nat.add({q}, 1n)), Nat.add({HX}n, Nat.add(VD.s_rng(5n, {LIMN}), 1n)), O.pow2n(13n),')
    w(f'      Order.add_left({HX}n, Nat.add({q}, 1n), Nat.add(VD.s_rng(5n, {LIMN}), 1n), CO.qle(K, 18n, {LIMN}, {{==}}, hN, E.hNk0())), e5le()))')
    w('')
    w(f'def hDOK({HNC}) -> {{Nat.is_le(DO(K), 13n) == {TRUE}}}: VD.wd_min(VC.nwu(SFSX(K)), 13n, hwO(K, hN))')
    w(f'def hDO29({HNC}) -> {{Nat.is_lt(DO(K), 29n) == {TRUE}}}: FD.nat__le_lt_trans(DO(K), 13n, 29n, hDOK(K, hN), {{==}})')
    w('')
    w(f'def hDq({HNC}) -> {{Nat.is_le(Nat.add({HX}n, Nat.add({q}, 1n)), VB.pw(DO(K))) == {TRUE}}}:')
    w(f'  %Equal.sym(Nat, VB.pw(DO(K)), O.pow2n(DO(K)), VD.s_pow2_eq(DO(K))) : {{Nat.is_le(Nat.add({HX}n, Nat.add({q}, 1n)), _) == {TRUE}}}')
    w(f'  %nwS(K, hN) : {{Nat.is_le(_, O.pow2n(DO(K))) == {TRUE}}}')
    w('  VD.wd_cover(VC.nwu(SFSX(K)), 13n, {==}, hwO(K, hN))')
    w('')
    TA = f'{WA}, DO(K), VC.ZT(DO(K)), 0n, 0, T, K'
    HA0 = (f'{{==}}, FD.array__trep_perfect(U32, DO(K), 0), hDO29(K, hN), hDq(K, hN), VBT.zslot(DO(K), Nat.add(Nat.add({HX}n, 0n), {q})), '
           f'VBT.zslot(DO(K), Nat.add({QB}, Nat.add({HX}n, 0n))), dw, pfT, hdw, rep, hcap, hv')
    RE = f'({OBJa}, B.Buf{{FD.array__thaw(U32, OUT({WA}, T, K)), SFSX(K)}})'
    TE = f'{Tn} & B.Buf'
    ps = ['+' + p_.strip() for p_ in re.split(r',\s*\+', ' '.join(SRC.split()).lstrip('+'))]
    SO = f'FD.array__slots(U32, OUT({WA}, T, K))'
    BY = f'VS.bt(U32.to_nat(SFSX(K)), F.limbs({SO}))'
    w('# The encoder returns the object and the buffer of the output tree.')
    w('law encode_eval:')
    for p_ in ps:
        w(f'  for {p_}')
    w(f'  {{{Tn}_encode({OBJa}) == {RE} : {TE}}}')
    w(f'def encode_eval({SRCa}):')
    w(f'  +hN = {HN}')
    w(f'  %Equal.sym({Tn} & U32, {Tn}_size({OBJa}), ({OBJa}, SFSX(K)), size_eval({SRCa})) :')
    w(f'    {{{Tn}_enc_sized(_) == {RE} : {TE}}}')
    w('  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(SFSX(K)))), FD.array__thaw(U32, VC.ZT(DO(K))),')
    w('      Equal.trans(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(SFSX(K)))), Array.new(U32, DO(K), 0), FD.array__thaw(U32, VC.ZT(DO(K))),')
    w('        E.zeros_at(B.words_depth_u(VC.nwu(SFSX(K))), DO(K), VD.wdu(VC.nwu(SFSX(K))), hDOK(K, hN)), FD.array__new(U32, DO(K), 0))) :')
    w(f'    {{{Tn}_enc_put(SFSX(K), {Tn}_putn(_, 0, {OBJa})) == {RE} : {TE}}}')
    w(f'  %Equal.sym({TP}, {Tn}_putn(FD.array__thaw(U32, VC.ZT(DO(K))), 0, {OBJa}), (FD.array__thaw(U32, OUT({WA}, T, K)), ({OBJa}, SFSX(K))), putw({TA}, {HA0})) :')
    w(f'    {{{Tn}_enc_put(SFSX(K), _) == {RE} : {TE}}}')
    w('  {==}')
    w('')
    w('# The output\'s bytes: the header\'s words, then the bit list\'s bytes.')
    w(f'def out_eq({SRC})')
    w(f'    -> {{{BY} == {RHS} : +List<U32>}}:')
    w(f'  +hN = {HN}')
    w(f'  +hH = FD.logic__subst(Nat, z => {{Nat.is_le({HX}n, z) == {TRUE}}}, VB.pw(DO(K)), VB.len({SO}),')
    w(f'    Equal.sym(Nat, VB.len({SO}), VB.pw(DO(K)), FD.array__slots_length(U32, DO(K), OUT({WA}, T, K), pfW({TA}, {HA0}))),')
    w(f'    FD.nat__le_trans({HX}n, Nat.add({HX}n, Nat.add({q}, 1n)), VB.pw(DO(K)), Order.below_sum({HX}n, Nat.add({q}, 1n)), hDq(K, hN)))')
    w(f'  %Equal.sym(Nat, U32.to_nat(SFSX(K)), Nat.add({FSX}n, {NKn}), eSX(K, hN)) : {{VS.bt(_, F.limbs({SO})) == {RHS} : +List<U32>}}')
    w(f'  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad({HX}n), {NKn}), F.limbs({SO})),')
    w(f'      List.append(&2, U32, F.limbs(VS.wtake({HX}n, {SO})), VS.bt({NKn}, F.limbs(VB.wdr({HX}n, {SO})))), VY.bt_split({HX}n, {NKn}, {SO}, hH)) :')
    w(f'    {{_ == {RHS} : +List<U32>}}')
    w(f'  %Equal.sym({LT}, VF.WIN({HX}n, 0n, {SO}), {HDRL}, hdrw({TA}, {HA0})) :')
    w(f'    {{List.append(&2, U32, F.limbs(_), VS.bt({NKn}, F.limbs(VB.wdr({HX}n, {SO})))) == {RHS} : +List<U32>}}')
    w(f'  %VY.bt_take(Nat.add({q}, 1n), {NKn}, VB.wdr({HX}n, {SO}), E.nkq(K, hN)) :')
    w(f'    {{List.append(&2, U32, F.limbs({HDRL}), _) == {RHS} : +List<U32>}}')
    w(f'  %Equal.sym(+List<U32>, VS.bt({NKn}, F.limbs(VF.WIN(Nat.add({q}, 1n), Nat.add({HX}n, 0n), {SO}))), {Y}, payw({TA}, {HA0})) :')
    w(f'    {{List.append(&2, U32, F.limbs({HDRL}), _) == {RHS} : +List<U32>}}')
    w('  {==}')
    w('')
    w('# The bytes the encoder writes are the spec/codec.bend encoding of the object\'s value.')
    w('law encode_spec:')
    for p_ in ps:
        w(f'  for {p_}')
    w(f'  Decoding.decodes(Spec.{n}(), {BY}, VALX({WA}, T, K))')
    w(f'def encE({SRC})')
    w(f'    -> {{Codec.encoding_for_legal_type(Spec.{n}(), VALX({WA}, T, K)) == Some{{{RHS}}} : {M}}}:')
    w(f'  %Equal.sym({MP}, Codec.parts(VALX({WA}, T, K), Spec.{n}()), {RHSp}, partsE({SRCa})) : {{Codec.bytes(_) == Some{{{RHS}}} : {M}}}')
    w('  {==}')
    w(f'def encode_spec({SRCa}):')
    w(f'  Equal.trans({M}, Codec.encoding_for_legal_type(Spec.{n}(), VALX({WA}, T, K)), Some{{{RHS}}}, Some{{{BY}}},')
    w(f'    encE({SRCa}),')
    w(f'    Equal.cong(+List<U32>, {M}, z => Some{{z}}, {RHS}, {BY}, Equal.sym(+List<U32>, {BY}, {RHS}, out_eq({SRCa}))))')
    return '\n'.join(L) + '\n'


AAP_DOC = ['The encoder of AggregateAndProof (aggregator_index, the offset of the boxed Attestation, selection_proof,',
           'then the Attestation): its writer at P (the interface of codegen/var_agg_enc.py) over the',
           "Attestation's (big_var_bitc_encw_Attestation.bend) at P + 27, and encode_eval / encode_spec: for every",
           "object whose bit list represents a value within BitList[2^17] and passes the runtime's checks, the",
           'encoder returns the object and B.Buf{thaw(OUT), 344 + K / 8 + 1}, whose bytes are the spec encoding',
           "of the object's value."]
SAAP_DOC = ['The encoder of SignedAggregateAndProof (the offset of the message, signature, then the message, an',
            'AggregateAndProof written by big_var_codec_AggregateAndProof_enc.bend at P + 25): encode_eval and',
            'encode_spec, as for AggregateAndProof (B.Buf{thaw(OUT), 444 + K / 8 + 1}).']


def main():
    nb = '--no-big' in sys.argv
    out = {}
    if not nb:
        out[OBJ / 'big_var_bitc_encw_Attestation.bend'] = leaf_text()
        _g, _x, _f, IA = leaf()
        IA.T = 'T.Attestation'
        cA = Child(IA, 'big_var_bitc_encw_Attestation.bend', 'AW', 236, 'E.eS', 'E.size_eval', True)
        t1, IP = parent_text('AggregateAndProof', 'a', cA, AAP_DOC)
        out[OBJ / 'big_var_codec_AggregateAndProof_enc.bend'] = t1
        cP = Child(IP, 'big_var_codec_AggregateAndProof_enc.bend', 'C', 344, 'C.eSX', 'C.size_eval', False)
        t2, _ = parent_text('SignedAggregateAndProof', 's', cP, SAAP_DOC)
        out[OBJ / 'big_var_codec_SignedAggregateAndProof_enc.bend'] = t2
    import runtime_refs as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale generated encoder modules: ' + ', '.join(stale))
            sys.exit(1)
        print('generated encoder modules are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print(', '.join(str(p.relative_to(ROOT)) for p in out) or 'nothing (--no-big)')


if __name__ == '__main__':
    main()
