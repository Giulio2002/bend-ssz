#!/usr/bin/env python3
"""e2e/e2e_dfl_<stem>.bend: a list of fixed-size records of Data (the elements stored unboxed: pl_SmallTestStruct, l10_ProgressiveSingleFieldContainerTestStruct)
read at a byte window (proofs/obj/var_winx_<stem>.bend: W) satisfies the root laws' representation invariant rep_<stem> and the encode premise
PRL_<stem> of the container that holds it (e2e_encld.bend). The reader writes record j (W.RX at the byte position j * size + x) into a tree of default
records (W.RT) and thaws it. Every slot of the tree satisfies the element predicate rp_<T> (a masked read, or the default record): AO, preserved by each
write (tao_t: a write sets some leaf), so the element laws (ereps) follow by induction over the slots; the tree is perfect, its depth the count's.

    sdl(d, t, x, off, len, [h31,] hchk)                  EL.PRL_<stem>(W.OBJw(d, t, x, off, len))
    rep(d, t, x, off, len, s, [es,] [h31,] hchk)         RT.rep_<stem>(W.OBJw(d, t, x, off, len), s)
    szl(d, t, x, off, len, hchk)                         [pl_* lists] EL.QR_<stem>(W.OBJw(d, t, x, off, len)) == len

h31 (pl_* lists): the window is shorter than 2^31 bytes (the container's total bound). es (l*_ lists): the schema's limit.

Usage: python3 codegen/proofs/decoded/unboxed_record_list_decoded_facts.py [--check]"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core.repository_paths import ROOT  # noqa: E402
E2E = ROOT / 'e2e'

MASK16 = ('FD.logic__subst(U32, w => {{U32.is_lt(w, 65536) == True{{}} : Bool}}, MK.cf16(UR.RWN(t, {y})), O.keep(2, UR.RWN(t, {y})), '
          'Equal.sym(U32, O.keep(2, UR.RWN(t, {y})), MK.cf16(UR.RWN(t, {y})), MK.mk16(UR.RWN(t, {y}))), {{==}})')

LISTS = {
    'pl_SmallTestStruct': dict(
        T='SmallTestStruct_d.SmallTestStruct', TF='SmallTestStruct_def_generated', SEQ='proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq', SEQF='proglist_SmallTestStruct_def_generated',
        SEQA='proglist_SmallTestStruct_d', TA='SmallTestStruct_d', ESZ=4, RP='RN.rp_SmallTestStruct', LIM=None, KIND='pl', HDEF='({==}, {==})',
        RPX='(' + MASK16.format(y='y') + ', ' + MASK16.format(y='2n+y') + ')'),
    'l10_ProgressiveSingleFieldContainerTestStruct': dict(
        T='ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct', TF='ProgressiveSingleFieldContainerTestStruct_def_generated',
        SEQ='list_ProgressiveSingleFieldContainerTestStruct_10_d.l10_ProgressiveSingleFieldContainerTestStruct_Seq', SEQF='list_ProgressiveSingleFieldContainerTestStruct_10_def_generated',
        SEQA='list_ProgressiveSingleFieldContainerTestStruct_10_d', TA='ProgressiveSingleFieldContainerTestStruct_d', ESZ=1,
        RP='RN.rp_ProgressiveSingleFieldContainerTestStruct', LIM=10, KIND='l', HDEF='{==}',
        RPX='DPA.nthb_lt(VUA.BYT(t), y, FXA.domain_limbs(VRA.SL(t)))'),
}


def text(stem):
    P = LISTS[stem]
    T, SEQ, ESZ, RP, LIM, KIND = P['T'], P['SEQ'], P['ESZ'], P['RP'], P['LIM'], P['KIND']
    XAT, EREPS, REP, XLEN = (f'RTL.{n}_{stem}' for n in ('xat', 'ereps', 'rep', 'xlen_o'))
    DEF = f'{P["TA"]}.{T.split(".")[1]}_default()'
    pos = lambda j: f'VRL.pos({j}, {ESZ}n, x)'  # noqa: E731
    RXj = f'W.RX(t, {pos("j")})'
    WD = 'B.words_depth(W.NN(len))'
    D0 = f'FD.array__trep({T}, {WD}, {DEF})'
    K0 = 'U32.to_nat(U32.sub(W.NN(len), 1))'
    TT = f'W.RT({K0}, 0n, {WD}, {D0}, t, x)'
    KB = 29 if KIND == 'pl' else 4
    H31 = '+h31: {Nat.is_lt(U32.to_nat(len), VB.pw(31n)) == True{} : Bool}, ' if KIND == 'pl' else ''   # (the progressive lists stay below 2^31: 2^29 records, depth < 30)
    ES = f'+es: {{SH.ListOf_limit(s) == U32.to_nat({LIM}) : Nat}}, ' if KIND == 'l' else ''
    HCHK = '+hchk: {W.CHKw(t, x, off, len) == True{} : Bool}'
    WIN = '+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'
    prl = f'EL.PRL_{stem}'
    out = []
    A_ = out.append
    imports = ['../src/obj.bend as O', '../src/buffer.bend as B', '../types/schema.bend as S', f'../types/{P["TF"]}.bend as {P["TA"]}',
               f'../types/{P["SEQF"]}.bend as {P["SEQA"]}', '../proofs/compact/found.bend as FD', '../proofs/compact/arith.bend as A', '../proofs/obj/vbuf.bend as VB',
               '../proofs/obj/vcopy.bend as VC', '../proofs/obj/vdepth.bend as VD', '../proofs/obj/vrl.bend as VRL', '../proofs/obj/vua_rd.bend as UR',
               '../proofs/obj/dk.bend as DK', '../proofs/obj/schema_shapes.bend as SH', '../proofs/obj/root_gnames_light.bend as RN',
               '../proofs/obj/root_gtypes2_light.bend as RTL', f'../proofs/obj/var_winx_{stem}.bend as W', './e2e_encld.bend as EL', './e2e_mask.bend as MK',
               './e2e_dpl.bend as DPA', '../proofs/obj/vua.bend as VUA', '../proofs/obj/vbrt.bend as VRA', '../proofs/obj/spec_fixed.bend as FXA',
               './e2e_encrd.bend as ER']
    A_('import Base')
    for i in imports:
        A_('import ' + i)
    A_('')
    A_('# GENERATED by unboxed_record_list_decoded_facts (codegen). Do not edit.')
    A_(f'# {stem}: the decoded list at a window: every slot satisfies the records\' predicate, the tree is perfect, its depth is the count\'s.')
    A_('')
    A_(f'def AO(+W: List<&2, {T}>) -> Data:\n  match W:\n    case Nil{{}}: {{True{{}} == True{{}} : Bool}}\n    case Con{{+x, +r}}: DK.P2({RP}(x), AO(r))')
    A_('')
    A_(f'def ao_xat(+W: List<&2, {T}>, +i: Nat, +h: AO(W), +hd: {RP}({DEF})) -> {RP}({XAT}(W, i)):\n'
       f'  match W i:\n    case Nil{{}} _: hd\n    case Con{{+x, +r}} 0n:\n      (+p, +q) = h\n      p\n'
       f'    case Con{{+x, +r}} 1n+ +j:\n      (+p, +q) = h\n      ao_xat(r, j, q, hd)')
    A_('')
    A_(f'def ao_app(+A: List<&2, {T}>, +B: List<&2, {T}>, +ha: AO(A), +hb: AO(B)) -> AO(FD.spec_common__append({T}, A, B)):\n'
       f'  match A:\n    case Nil{{}}: hb\n    case Con{{+x, +r}}:\n      (+p, +q) = ha\n      (p, ao_app(r, B, q, hb))')
    A_('')
    A_(f'def ao_splitL(+A: List<&2, {T}>, +B: List<&2, {T}>, +h: AO(FD.spec_common__append({T}, A, B))) -> AO(A):\n'
       f'  match A:\n    case Nil{{}}: {{==}}\n    case Con{{+x, +r}}:\n      (+p, +q) = h\n      (p, ao_splitL(r, B, q))')
    A_('')
    A_(f'def ao_splitR(+A: List<&2, {T}>, +B: List<&2, {T}>, +h: AO(FD.spec_common__append({T}, A, B))) -> AO(B):\n'
       f'  match A:\n    case Nil{{}}: h\n    case Con{{+x, +r}}:\n      (+p, +q) = h\n      ao_splitR(r, B, q)')
    A_('')
    A_(f'def ao_rep(+n: Nat, +v: {T}, +hv: {RP}(v)) -> AO(FD.spec_common__replicate({T}, n, v)):\n  match n:\n    case 0n: {{==}}\n    case 1n+ +p: (hv, ao_rep(p, v, hv))')
    A_('')
    A_(f'def ao_trep(+d: Nat, +v: {T}, +hv: {RP}(v)) -> AO(FD.array__slots({T}, FD.array__trep({T}, d, v))):\n'
       f'  %Equal.sym(List<&2, {T}>, FD.array__slots({T}, FD.array__trep({T}, d, v)), FD.spec_common__replicate({T}, FD.spec_common__pow2(d), v), FD.array__trep_slots({T}, d, v)) : AO(_)\n'
       f'  ao_rep(FD.spec_common__pow2(d), v, hv)')
    A_('')
    A_('# a write sets some leaf of the tree (the index is clamped to the last leaf past the end)')
    A_(f'def tao_t(+d: Nat, +t: FD.array__Tree<{T}>, +j: Nat, +e: {T}, +he: {RP}(e), +left: Bool, +h: AO(FD.array__slots({T}, t))) -> AO(FD.array__slots({T}, FD.array__tupd({T}, d, t, j, e, left))):\n'
       f'  match d t left:\n'
       f'    case 0n FD.TLeaf{{+x}} _: (he, {{==}})\n'
       f'    case 0n FD.TNode{{+l, +r}} _: h\n'
       f'    case 1n+ +p FD.TLeaf{{+x}} _: h\n'
       f'    case 1n+ +p FD.TNode{{+l, +r}} True{{}}:\n'
       f'      +hl = ao_splitL(FD.array__slots({T}, l), FD.array__slots({T}, r), h)\n      +hr = ao_splitR(FD.array__slots({T}, l), FD.array__slots({T}, r), h)\n'
       f'      ao_app(FD.array__slots({T}, FD.array__tupd({T}, p, l, j, e, FD.array__ndec(p, j))), FD.array__slots({T}, r), tao_t(p, l, j, e, he, FD.array__ndec(p, j), hl), hr)\n'
       f'    case 1n+ +p FD.TNode{{+l, +r}} False{{}}:\n'
       f'      +hl = ao_splitL(FD.array__slots({T}, l), FD.array__slots({T}, r), h)\n      +hr = ao_splitR(FD.array__slots({T}, l), FD.array__slots({T}, r), h)\n'
       f'      ao_app(FD.array__slots({T}, l), FD.array__slots({T}, FD.array__tupd({T}, p, r, Nat.sub(j, FD.spec_common__pow2(p)), e, FD.array__ndec(p, Nat.sub(j, FD.spec_common__pow2(p))))), hl, tao_t(p, r, Nat.sub(j, FD.spec_common__pow2(p)), e, he, FD.array__ndec(p, Nat.sub(j, FD.spec_common__pow2(p))), hr))')
    A_('')
    A_(f'def tao_upd(+d: Nat, +t: FD.array__Tree<{T}>, +j: Nat, +e: {T}, +he: {RP}(e), +h: AO(FD.array__slots({T}, t))) -> AO(FD.array__slots({T}, FD.array__upd({T}, d, t, j, e))):\n'
       f'  tao_t(d, t, j, e, he, FD.array__ndec(d, j), h)')
    A_('')
    A_('# a record the reader reads satisfies the predicate')
    A_(f'def rpx(+t: FD.array__Tree<U32>, +y: Nat) -> {RP}(W.RX(t, y)):\n  {P["RPX"]}')
    A_('')
    A_(f'def hdef() -> {RP}({DEF}): {P["HDEF"]}')
    A_('')
    A_('# the perfect tree stays perfect, and every slot satisfies the predicate, over the writes')
    A_(f'def rtp(k: Nat, +j: Nat, +dd: Nat, +D: FD.array__Tree<{T}>, +t: FD.array__Tree<U32>, +x: Nat, +pf: {{FD.array__perfect({T}, dd, D) == True{{}} : Bool}})\n'
       f'    -> {{FD.array__perfect({T}, dd, W.RT(k, j, dd, D, t, x)) == True{{}} : Bool}}:\n'
       f'  match k:\n    case 0n: FD.array__upd_perfect({T}, dd, D, j, {RXj}, pf)\n'
       f'    case 1n+ +q: rtp(q, 1n+j, dd, FD.array__upd({T}, dd, D, j, {RXj}), t, x, FD.array__upd_perfect({T}, dd, D, j, {RXj}, pf))')
    A_('')
    A_(f'def ao_rt(k: Nat, +j: Nat, +dd: Nat, +D: FD.array__Tree<{T}>, +t: FD.array__Tree<U32>, +x: Nat, +h: AO(FD.array__slots({T}, D)))\n'
       f'    -> AO(FD.array__slots({T}, W.RT(k, j, dd, D, t, x))):\n'
       f'  match k:\n'
       f'    case 0n: tao_upd(dd, D, j, {RXj}, rpx(t, {pos("j")}), h)\n'
       f'    case 1n+ +q: ao_rt(q, 1n+j, dd, FD.array__upd({T}, dd, D, j, {RXj}), t, x, tao_upd(dd, D, j, {RXj}, rpx(t, {pos("j")}), h))')
    A_('')
    A_(f'def er_ao(+k: Nat, +W: List<&2, {T}>, +i: Nat, +h: AO(W), +hd: {RP}({DEF})) -> {EREPS}(k, W, i):\n  match k:\n    case 0n: {{==}}\n    case 1n+ +q: (ao_xat(W, i, h, hd), er_ao(q, W, 1n+i, h, hd))')
    A_('')
    A_(f'def ao_win(+len: U32, +t: FD.array__Tree<U32>, +x: Nat) -> AO(FD.array__slots({T}, {TT})):\n'
       f'  ao_rt({K0}, 0n, {WD}, {D0}, t, x, ao_trep({WD}, {DEF}, hdef()))')
    A_('')
    # the count's bound
    if KIND == 'pl':
        A_('def BBQ() -> {VB.pw(31n) == A.quad(VB.pw(29n)) : Nat}:\n  %Equal.sym(Nat, 31n, 2n+29n, {==}) : {VB.pw(_) == A.quad(VB.pw(29n)) : Nat}\n  {==}')
        A_('')
        A_('# the record count of a window shorter than 2^31 bytes is at most 2^29\n'
           'def CC29(+len: U32, +e: {U32.to_nat(len) == Nat.mul(W.CC(len), 4n) : Nat}, +h31: {Nat.is_lt(U32.to_nat(len), VB.pw(31n)) == True{} : Bool})\n'
           '    -> {Nat.is_le(W.CC(len), O.pow2n(29n)) == True{} : Bool}:\n'
           '  +hq = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(31n)) == True{} : Bool}, U32.to_nat(len), A.quad(W.CC(len)), Equal.trans(Nat, U32.to_nat(len), Nat.mul(W.CC(len), 4n), A.quad(W.CC(len)), e, VC.quad_mul(W.CC(len))), h31)\n'
           '  +hp = FD.logic__subst(Nat, z => {Nat.is_lt(A.quad(W.CC(len)), z) == True{} : Bool}, VB.pw(31n), A.quad(VB.pw(29n)), BBQ(), hq)\n'
           '  FD.logic__subst(Nat, z => {Nat.is_le(W.CC(len), z) == True{} : Bool}, VB.pw(29n), O.pow2n(29n), VD.s_pow2_eq(29n), VC.quad_inv(W.CC(len), VB.pw(29n), FD.nat__lt_le(A.quad(W.CC(len)), A.quad(VB.pw(29n)), hp)))')
    else:
        A_(f'def CC4(+len: U32, +hc: {{Nat.is_le(W.CC(len), U32.to_nat({LIM})) == True{{}} : Bool}}) -> {{Nat.is_le(W.CC(len), O.pow2n(4n)) == True{{}} : Bool}}:\n'
           f'  FD.nat__le_trans(W.CC(len), U32.to_nat({LIM}), O.pow2n(4n), hc, {{==}})')
    A_('')
    HB = f'+hb: {{Nat.is_le(W.CC(len), O.pow2n({KB}n)) == True{{}} : Bool}}'
    A_('# the window\'s tree: perfect of the count\'s depth')
    A_(f'def hwd(+len: U32, {HB}) -> {{Nat.is_le(U32.to_nat(W.NN(len)), FD.spec_common__pow2({WD})) == True{{}} : Bool}}:\n'
       f'  FD.logic__subst(Nat, z => {{Nat.is_le(W.CC(len), z) == True{{}} : Bool}}, O.pow2n({WD}), FD.spec_common__pow2({WD}), Equal.sym(Nat, FD.spec_common__pow2({WD}), O.pow2n({WD}), VD.s_pow2_eq({WD})),\n'
       f'    VD.wd_cover(W.NN(len), {KB}n, {{==}}, hb))')
    A_('')
    A_(f'def hwlt(+len: U32, {HB}) -> {{Nat.is_lt({WD}, 32n) == True{{}} : Bool}}:\n'
       f'  FD.nat__le_lt_trans({WD}, {KB}n, 32n, VD.wd_min(W.NN(len), {KB}n, hb), {{==}})')
    A_('')
    A_('# ---- the representation invariant ----')
    rep_tuple_true = (f'(FD.array__trep({T}, 0n, {DEF}), (0n, (0, ({{==}}, (FD.array__trep_perfect({T}, 0n, {DEF}), ({{==}}, ({{==}}, {{==}})))))))')
    rep_tuple_false = (f'({TT}, ({WD}, (W.NN(len), ({{==}}, (rtp({K0}, 0n, {WD}, {D0}, t, x, FD.array__trep_perfect({T}, {WD}, {DEF})), '
                       f'(hwlt(len, hb), (hwd(len, hb), er_ao(U32.to_nat(W.NN(len)), FD.array__slots({T}, {TT}), 0n, ao_win(len, t, x), hdef()))))))))')
    if KIND == 'pl':
        A_(f'def lr(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +s: S.Schema, {HB}) -> {REP}(W.LOBJ(c, t, x, len), s):\n'
           f'  match c:\n    case True{{}}: {rep_tuple_true}\n    case False{{}}: {rep_tuple_false}')
    else:
        A_(f'def lr(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +s: S.Schema, +es: {{SH.ListOf_limit(s) == U32.to_nat({LIM}) : Nat}}, +hc: {{Nat.is_le(W.CC(len), U32.to_nat({LIM})) == True{{}} : Bool}}) -> {REP}(W.LOBJ(c, t, x, len), s):\n'
           f'  match c:\n    case True{{}}: ({rep_tuple_true}, FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat({XLEN}(W.LOBJ(True{{}}, t, x, len))), z) == True{{}} : Bool}}, U32.to_nat({LIM}), SH.ListOf_limit(s), Equal.sym(Nat, SH.ListOf_limit(s), U32.to_nat({LIM}), es), FD.nat__zero_le(U32.to_nat({LIM}))))\n'
           f'    case False{{}}:\n      +hb = CC4(len, hc)\n      ({rep_tuple_false}, FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat({XLEN}(W.LOBJ(False{{}}, t, x, len))), z) == True{{}} : Bool}}, U32.to_nat({LIM}), SH.ListOf_limit(s), Equal.sym(Nat, SH.ListOf_limit(s), U32.to_nat({LIM}), es), hc))')
    A_('')
    # PRL
    A_('# ---- the encode premise ----')
    if KIND == 'pl':
        prl_true = '({==}, FD.logic__subst(U32, z => {Nat.is_le(Nat.mul(W.CC(z), 4n), U32.to_nat(VB.NMAX())) == True{} : Bool}, len, 0, FD.u32alg__eq_of(len, 0, ec), hl))'
        prl_false = (f'(FD.logic__subst(Nat, z => {{Nat.is_lt(z, 30n) == True{{}} : Bool}}, {WD}, ER.LDEP({T}, FD.array__freeze({T}, FD.array__thaw({T}, {TT}))), '
                     f'Equal.sym(Nat, ER.LDEP({T}, FD.array__freeze({T}, FD.array__thaw({T}, {TT}))), {WD}, PDW(len, t, x)), FD.nat__le_lt_trans({WD}, {KB}n, 30n, VD.wd_min(W.NN(len), {KB}n, hb), {{==}})), hl)')
        A_(f'def PDW(+len: U32, +t: FD.array__Tree<U32>, +x: Nat) -> {{ER.LDEP({T}, FD.array__freeze({T}, FD.array__thaw({T}, {TT}))) == {WD} : Nat}}:\n'
           f'  %Equal.sym(FD.array__Tree<{T}>, FD.array__freeze({T}, FD.array__thaw({T}, {TT})), {TT}, FD.array__freeze_thaw({T}, {TT})) : {{ER.LDEP({T}, _) == {WD} : Nat}}\n'
           f'  ER.pdep({T}, {WD}, {TT}, rtp({K0}, 0n, {WD}, {D0}, t, x, FD.array__trep_perfect({T}, {WD}, {DEF})))')
        A_('')
        A_(f'def lg(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +ec: {{U32.is_eq(len, 0) == c : Bool}}, {HB}, +hl: {{Nat.is_le(Nat.mul(W.CC(len), 4n), U32.to_nat(VB.NMAX())) == True{{}} : Bool}}) -> {prl}(W.LOBJ(c, t, x, len)):\n'
           f'  match c:\n    case True{{}}: {prl_true}\n    case False{{}}: {prl_false}')
        A_('')
        A_(f'def sdl({WIN}, {H31}{HCHK}) -> {prl}(W.OBJw(d, t, x, off, len)):\n'
           f'  lg(U32.is_eq(len, 0), len, t, x, {{==}}, CC29(len, W.ecw(len, hchk), h31), VB.le_pw31_nmax(Nat.mul(W.CC(len), 4n), FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(31n)) == True{{}} : Bool}}, U32.to_nat(len), Nat.mul(W.CC(len), 4n), W.ecw(len, hchk), h31)))')
        A_('')
        A_(f'def rep({WIN}, +s: S.Schema, {H31}{HCHK}) -> {REP}(W.OBJw(d, t, x, off, len), s):\n  lr(U32.is_eq(len, 0), len, t, x, s, CC29(len, W.ecw(len, hchk), h31))')
        A_('')
        A_(f'def lq(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +ec: {{U32.is_eq(len, 0) == c : Bool}}, +e: {{U32.to_nat(len) == Nat.mul(W.CC(len), 4n) : Nat}})\n'
           f'    -> {{EL.QR_{stem}(W.LOBJ(c, t, x, len)) == U32.to_nat(len) : Nat}}:\n'
           f'  match c:\n    case True{{}}: Equal.sym(Nat, U32.to_nat(len), 0n, Equal.cong(U32, Nat, z => U32.to_nat(z), len, 0, FD.u32alg__eq_of(len, 0, ec)))\n'
           f'    case False{{}}: Equal.sym(Nat, U32.to_nat(len), Nat.mul(W.CC(len), 4n), e)')
        A_('')
        A_(f'def szl({WIN}, {HCHK}) -> {{EL.QR_{stem}(W.OBJw(d, t, x, off, len)) == U32.to_nat(len) : Nat}}:\n  lq(U32.is_eq(len, 0), len, t, x, {{==}}, W.ecw(len, hchk))')
    else:
        prl_true = '{==}'
        prl_false = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(z, 30n) == True{{}} : Bool}}, {WD}, ER.LDEP({T}, FD.array__freeze({T}, FD.array__thaw({T}, {TT}))), '
                     f'Equal.sym(Nat, ER.LDEP({T}, FD.array__freeze({T}, FD.array__thaw({T}, {TT}))), {WD}, PDW(len, t, x)), FD.nat__le_lt_trans({WD}, {KB}n, 30n, VD.wd_min(W.NN(len), {KB}n, hb), {{==}}))')
        A_(f'def PDW(+len: U32, +t: FD.array__Tree<U32>, +x: Nat) -> {{ER.LDEP({T}, FD.array__freeze({T}, FD.array__thaw({T}, {TT}))) == {WD} : Nat}}:\n'
           f'  %Equal.sym(FD.array__Tree<{T}>, FD.array__freeze({T}, FD.array__thaw({T}, {TT})), {TT}, FD.array__freeze_thaw({T}, {TT})) : {{ER.LDEP({T}, _) == {WD} : Nat}}\n'
           f'  ER.pdep({T}, {WD}, {TT}, rtp({K0}, 0n, {WD}, {D0}, t, x, FD.array__trep_perfect({T}, {WD}, {DEF})))')
        A_('')
        A_(f'def lg(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +hc: {{Nat.is_le(W.CC(len), U32.to_nat({LIM})) == True{{}} : Bool}}) -> {prl}(W.LOBJ(c, t, x, len)):\n'
           f'  match c:\n    case True{{}}: {prl_true}\n    case False{{}}:\n      +hb = CC4(len, hc)\n      {prl_false}')
        A_('')
        A_(f'def sdl({WIN}, {HCHK}) -> {prl}(W.OBJw(d, t, x, off, len)):\n  lg(U32.is_eq(len, 0), len, t, x, W.hcw(len, hchk))')
        A_('')
        A_(f'def rep({WIN}, +s: S.Schema, {ES}{HCHK}) -> {REP}(W.OBJw(d, t, x, off, len), s):\n  lr(U32.is_eq(len, 0), len, t, x, s, es, W.hcw(len, hchk))')
    return '\n'.join(out) + '\n'


def main():
    outs = {E2E / f'e2e_dfl_{s}.bend': text(s) for s in LISTS}
    if '--check' in sys.argv:
        stale = [p.name for p, t in outs.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('unboxed_record_list_decoded_facts: up to date')
        return
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print(f'unboxed_record_list_decoded_facts: {len(outs)} files')


if __name__ == '__main__':
    main()
