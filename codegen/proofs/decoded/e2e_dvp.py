#!/usr/bin/env python3
"""e2e/e2e_dvp_<list>.bend: a progressive list of variable-size boxed records (pl_VarTestStruct, pl_pl_VarTestStruct, ...) read at a byte window
(proofs/obj/vvl_<list>.bend: V) satisfies the root laws' representation invariant rep_<list> and the encode premise PRV_<list> of the container that
holds it (e2e_encld.bend: EL), and its encoder's byte count is the window's:

    sdl(d, t, x, off, len, WF, h31, hchk)                EL.PRV_<list>(V.OBJw(d, t, x, off, len))
    rep(d, t, x, off, len, WF, s, ee, hchk)              RT.rep_<list>(V.OBJw(d, t, x, off, len), s)        [RT = root_gtypes2_light]
    szl(d, t, x, off, len, WF, hchk)                     LN(V.OBJw(d, t, x, off, len)) == to_nat(len)   (LN: the encoder's byte count of the list)

WF is the window facts eo, hd, hw, hw32, pfw (the argument order of e2e_dvl_*); h31: the window is shorter than 2^31 bytes (the container's total bound).
The proofs are e2e_dvl.py's (e2e_dtx.bend's loops over the same reader interface), with the progressive lists' check (no count limit: the tree's depth
is bounded by the window's: hd, hw) and the element facts from a hook module E (e2e_hkv.bend, or another list library e2e_dvp_*.bend) in the
convention (d, t, x, off, len, hchk, WF, ...): repT, sde, sz, canon.

Usage: python3 codegen/proofs/decoded/e2e_dvp.py [--check]"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.proofs.decoded import e2e_dvl as DVL
from codegen.proofs.decoded.e2e_dvl import WF_ARG, WF_SIG, close_paren, dtx_defs

from codegen.core.paths import ROOT  # noqa: E402
E2E = ROOT / 'e2e'

LISTS = {
    'pl_VarTestStruct': dict(
        X='VarTestStruct', ELTI='../types/VarTestStruct_def_generated.bend as VarTestStruct_d', ELT='VarTestStruct_d.VarTestStruct',
        LSTI='../types/proglist_VarTestStruct_def_generated.bend as proglist_VarTestStruct_d', LST='proglist_VarTestStruct_d',
        HK='e2e_hkv.bend', ENC='proofs/obj/encx_pl_VarTestStruct.bend', EMI='proofs/obj/encx_VarTestStruct_iface.bend',
        ESCH='Spec.VarTestStruct()', SPECI='../proofs/obj/generic_specs.bend as Spec', LN=None),
}

VLM_SRC = (E2E / 'e2e_vlm_l8_Attestation.bend').read_text()
VQ_SRC = (ROOT / 'proofs/obj/view_seq.bend').read_text()


def vlm_defs():
    out = {}
    lines = VLM_SRC.split('\n')
    i = 0
    while i < len(lines):
        m = re.match(r'(?:def|law) (\w+)', lines[i])
        if not m or not lines[i].startswith('def '):
            i += 1
            continue
        j = i + 1
        while j < len(lines) and not re.match(r'(def |law |#)', lines[j]):
            j += 1
        out[m.group(1)] = '\n'.join(lines[i:j]).rstrip()
        i = j
    return out


def vq_defs():
    i = VQ_SRC.index('# ---- l8_Attestation ----')
    j = VQ_SRC.index('def l8_Attestation_xi_same(')
    blk = VQ_SRC[i:j]
    k = blk.index('def l8_Attestation_xat_same(')
    return blk[k:].rstrip()


def text(c):
    P = LISTS[c]
    X, ELT, LST = P['X'], P['ELT'], P['LST']
    SEQ = f'{LST}.{c}_Seq'
    D = dtx_defs()
    VD_ = vlm_defs()
    EL_ = {'cvE': f'EL.fbx_{c}', 'CV': f'EL.TM_{c}', 'LM': f'EL.MAPB_{c}', 'xatlm': f'EL.xatM_{c}', 'slcv': f'EL.slTM_{c}', 'SDE': f'EL.EPB_{c}', 'SDKS': f'EL.EPS_{c}'}
    LNF = P['LN'] or 'LNQ'
    PRV = f'EL.PRV_{c}'
    PM = f'EL.PM_{c}'

    def bb(t):
        for k, v in EL_.items():
            t = t.replace('BBA.' + k, v)
        return t

    def tr(t):
        """dtx's text for this list"""
        t = t.replace('Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_', LST + '.' + c + '_')
        t = t.replace('Fulu_list_bytelist_1073741824_1048576_d', LST)
        t = t.replace('l1048576_bl1073741824', c).replace('bl1073741824_bx', X + '_bx')
        t = t.replace('VQ.', '').replace('U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576)', 'True{}')
        t = t.replace('RT.MB<RT.WMr>', 'RT.MB<RT.M_%s>' % X).replace('O.Boxed<O.Words>', 'O.Boxed<%s>' % ELT)
        t = t.replace('+es: {SH.ByteList_limit(sE) == U32.to_nat(1073741824) : Nat}', '+es: {sE == %s : S.Schema}' % P['ESCH'])
        t = t.replace('+ee: {SH.ByteList_limit(SH.ListOf_element(s)) == U32.to_nat(1073741824) : Nat}', '+ee: {SH.ProgressiveList_element(s) == %s : S.Schema}' % P['ESCH'])
        t = t.replace('SH.ListOf_element(s)', 'SH.ProgressiveList_element(s)')
        t = t.replace(DVL.HWN_SIG, WF_SIG)
        t = re.sub(r'\bhwN\b', WF_ARG, t)
        t = t.replace('TX.SUMN', 'SUMN').replace('TX.SDKS', EL_['SDKS']).replace('TX.TXL', 'LNM')
        t = DVL.unwrap_nr(t)
        key = 'BL.sdk(RT.pjb_%s_bx(RT.th_%s_bx(' % (X, X)
        while key in t:
            i = t.index(key)
            p0 = i + len('BL.sdk')
            pth = i + len(key) - 1
            cth = close_paren(t, pth)
            c0 = close_paren(t, p0)
            t = t[:i] + EL_['SDE'] + '(' + t[pth + 1:cth] + ')' + t[c0 + 1:]
        assert 'TX.' not in t and 'WMr' not in t and 'bl1073741824' not in t and 'ByteList_' not in t
        return t

    def vl(t):
        """the l8_Attestation vlm text for this list"""
        t = t.replace('l8_Attestation', c).replace('Fulu_list_Attestation_8_d', LST).replace('FuluAttestation_d.Attestation', ELT)
        t = t.replace('M_Attestation', 'M_' + X).replace('Attestation_bx', X + '_bx')
        t = re.sub(r'(?<![\w.])W\.', 'V.', t)
        assert 'Attestation' not in t, [l for l in t.split('\n') if 'Attestation' in l][:2]
        return t

    out = []
    A_ = out.append
    imps = ['Base', '../src/obj.bend as O', '../src/buffer.bend as B', '../types/schema.bend as S', P['SPECI'], P['ELTI'], P['LSTI'],
            '../proofs/compact/found.bend as FD', '../proofs/compact/arith.bend as A', '../proofs/nat_order.bend as Order',
            '../proofs/obj/vbuf.bend as VB', '../proofs/obj/vcopy.bend as VC', '../proofs/obj/vu32.bend as VU', '../proofs/obj/schema_shapes.bend as SH',
            '../proofs/obj/root_gtypes2_light.bend as RT', '../proofs/obj/vvl_%s.bend as V' % c, '../proofs/obj/words_rw.bend as WR',
            '../proofs/obj/vvlu.bend as VVU', '../proofs/obj/vdepth.bend as VD', './%s as E' % P['HK'], './e2e_encld.bend as EL', './e2e_encrd.bend as ER',
            '../%s as W8' % P['ENC'], '../%s as EM' % P['EMI'], '../proofs/obj/dk.bend as DK']
    for i in imps:
        A_('import ' + i if i != 'Base' else 'import Base')
    A_('')
    A_('# GENERATED by e2e_dvp (codegen) from e2e_dtx.bend and e2e_vlm_l8_Attestation.bend. Do not edit.')
    A_(f'# The progressive list a window reads ({c}, vvl_{c}) satisfies the root laws\' invariant rep_{c} and the encode premise PRV_{c}; its encoder\'s bytes are the window\'s.')
    A_('')
    A_('# ---- the reader\'s array is the array of the tree of its writes (e2e_vlm_l8_Attestation.bend\'s, for this list) ----')
    for n in ['e1', 'inv1', 'hiq', 'isne']:
        A_(vl(VD_[n]))
        A_('')
    SUB = ('Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a)')
    EEP = '+hEE: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool}'

    def HK(f, extra='', s='a', e='b', hh='hEE'):
        ab = f'V.el_ab(t, x, off, len, {s}, {e}, {hh})'
        bb_ = f'V.el_b(t, x, off, len, {s}, {e}, {hh})'
        sub = f'Nat.add(U32.to_nat({s}), x), U32.add(off, {s}), U32.sub({e}, {s})'
        return (f'E.{f}(d, t, {sub}, V.el_c(t, x, off, len, {s}, {e}, {hh}), '
                f'V.eocD(d, x, off, len, {s}, FD.nat__le_trans(U32.to_nat({s}), U32.to_nat({e}), U32.to_nat(len), {ab}, {bb_}), eo, hd, hw, hw32), hd, '
                f'V.hwab(d, x, len, {s}, {e}, {ab}, {bb_}, hw), V.hwab32(x, len, {s}, {e}, {ab}, {bb_}, hw32), pfw{extra})')
    for n in ['ND_l8_Attestation', 'NV_l8_Attestation', 'FT_l8_Attestation', 'pfFT_l8_Attestation', 'fillam_l8_Attestation', 'hx_at_l8_Attestation']:
        A_(vl(VD_[n]))
        A_('')
    A_(f'def eqE_{c}(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {WF_SIG}, +a: U32, +b: U32, +hEE: {{V.EE(True{{}}, t, x, off, len, a, b) == True{{}} : Bool}})\n'
       f'    -> {{V.OBJE(d, t, x, off, a, b) == RT.th_{X}_bx(ND_{c}(d, t, x, off, a, b)) : O.Boxed<{ELT}>}}:\n'
       f'  Equal.sym(O.Boxed<{ELT}>, RT.th_{X}_bx(ND_{c}(d, t, x, off, a, b)), V.OBJE(d, t, x, off, a, b), {HK("canon")})')
    A_('')
    # rvF with the element canon: the vlm text, its eqE replaced
    A_(vl(VD_['rvF_l8_Attestation']))
    A_('')
    A_('# ---- the elements\' facts at a window ----')
    HEAD = '(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, %s, +a: U32, +b: U32, %s' % (WF_SIG, EEP)
    A_('def XE(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32) -> RT.MB<RT.M_%s>: RT.fz_%s_bx(V.OBJE(d, t, x, off, s, e))' % (X, X))
    A_('')
    A_('def obje_canon%s)\n    -> {RT.th_%s_bx(XE(d, t, x, off, a, b)) == V.OBJE(d, t, x, off, a, b) : O.Boxed<%s>}:\n'
       '  Equal.sym(O.Boxed<%s>, V.OBJE(d, t, x, off, a, b), RT.th_%s_bx(XE(d, t, x, off, a, b)), eqE_%s(d, t, x, off, len, %s, a, b, hEE))'
       % (HEAD, X, ELT, ELT, X, c, WF_ARG))
    A_('')
    A_('def el_rep_th%s, +sE: S.Schema, +es: {sE == %s : S.Schema})\n    -> RT.rep_%s_bx(RT.th_%s_bx(XE(d, t, x, off, a, b)), sE):\n  %s'
       % (HEAD, P['ESCH'], X, X, HK('repT', ', sE, es')))
    A_('')
    A_('def NRa(+m: RT.MB<RT.M_%s>) -> Nat: List.length(&2, U32, W8.YE(%s(m)))' % (X, EL_['cvE']))
    A_('')
    A_('def SUMN(k: Nat, +W: List<&2, RT.MB<RT.M_%s>>, +i: Nat) -> Nat:\n  match k:\n    case 0n: 0n\n    case 1n+q: Nat.add(NRa(RT.xat_%s(W, i)), SUMN(q, W, 1n+i))' % (X, c))
    A_('')
    A_('def tele(+s: U32, +a: U32, +h: {Nat.is_le(U32.to_nat(s), U32.to_nat(a)) == True{} : Bool}) -> {Nat.add(U32.to_nat(s), U32.to_nat(U32.sub(a, s))) == U32.to_nat(a) : Nat}:\n'
       + D['tele'].split('\n', 1)[1])
    A_('')
    A_('def szel%s)\n    -> {Nat.add(U32.to_nat(a), %s) == U32.to_nat(b) : Nat}:\n  ' % (HEAD, 'NRa(XE(d, t, x, off, a, b))') + 'Equal.trans(Nat, Nat.add(U32.to_nat(a), NRa(XE(d, t, x, off, a, b))), Nat.add(U32.to_nat(a), U32.to_nat(U32.sub(b, a))), U32.to_nat(b),\n'
       '    Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(a), z), NRa(XE(d, t, x, off, a, b)), U32.to_nat(U32.sub(b, a)), %s), tele(a, b, V.el_ab(t, x, off, len, a, b, hEE)))' % HK('sz'))
    A_('')
    A_('def RVT(k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.M_%s>>, +v: RT.MB<RT.M_%s>) -> FD.array__Tree<RT.MB<RT.M_%s>>:\n'
       '  FT_%s(k, i, m, d, t, x, off, len, dw, T, v)' % (X, X, X, c))
    A_('')
    for n in ['lt_add_succ', 'lt_i', 'lt_len']:
        A_(tr(D[n]))
        A_('')
    A_('def rv_am(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.M_%s>>, +v: RT.MB<RT.M_%s>,\n'
       '    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}, +pf: {FD.array__perfect(RT.MB<RT.M_%s>, dw, T) == True{} : Bool},\n'
       '    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},\n'
       '    %s, +hE: {V.EV(k, i, m, t, x, off, len, True{}, V.WJ(t, x, i)) == True{} : Bool})\n'
       '    -> {V.RV(k, i, m, d, t, x, off, len, RT.am_%s(T), RT.th_%s_bx(v)) == RT.am_%s(RVT(k, i, m, dw, d, t, x, off, len, T, v)) : Array<O.Boxed<%s>>}:\n'
       '  rvF_%s(k, i, m, d, t, x, off, len, %s, dw, T, v, pf, hdw, hm, inv, hE)'
       % (X, X, X, WF_SIG, c, X, c, ELT, c, WF_ARG))
    A_('')
    A_(vq_defs().replace('l8_Attestation', c).replace('M_Attestation', 'M_' + X).replace('RTL.', 'RT.').replace('F.', 'FD.'))
    A_('')
    for n in ['ereps_after', 'ereps_snoc', 'ereps_step']:
        A_(tr(D[n]))
        A_('')
    for n in ['i1_val', 'cnt0', 'rv_ereps']:
        A_(tr(D[n]))
        A_('')
    A_('def el_sdk_th%s)\n    -> %s(XE(d, t, x, off, a, b)):\n  %s' % (HEAD, EL_['SDE'], HK('sde')))
    A_('')
    for n in ['sdks_after', 'sdks_snoc', 'sdks_step', 'rv_sdks']:
        A_(tr(D[n]))
        A_('')
    for n in ['sumn_after', 'sumn_snoc', 'NXk', 'him2', 'i2_val', 'nxk']:
        A_(tr(D[n]))
        A_('')
    A_(tr(D['sum_step']))
    A_('')
    s = tr(D['rv_sum'])
    s = s.replace('+hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool},', WF_SIG + ',\n    +hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool},', 1)
    s, k = re.subn(r'Equal\.trans\(Nat, Nat\.add\(U32\.to_nat\(s\), U32\.to_nat\(U32\.sub\(a, s\)\)\), U32\.to_nat\(a\), (.*?), tele\(s, a, hab\),',
                   lambda m: 'Equal.trans(Nat, Nat.add(U32.to_nat(s), NRa(XE(d, t, x, off, s, a))), U32.to_nat(a), %s, szel(d, t, x, off, len, %s, s, a, hEE),' % (m.group(1), WF_ARG), s)
    assert k == 2, k
    a1 = 'V.inv_nx(q, i, m, inv),\n        V.ev_ok('
    assert s.count(a1) == 1
    s = s.replace(a1, 'V.inv_nx(q, i, m, inv), %s,\n        V.ev_ok(' % WF_ARG)
    A_(s)
    A_('')
    for n in ['fill_am', 'rvt_pf', 'hc_of', 'evb_of', 'hcA', 'hcC', 'quadN', 'nn1', 'succ_pred', 'inv0', 'nxk0', 'ev_start', 'ee0_of', 'ev0_of']:
        A_(tr(D[n]))
        A_('')
    # the progressive check has no count limit: the tree's depth is the window's (hd, hw)
    WN = 'V.NN(t, x)'
    A_('# the count of records is at most 2^d: four times it is the first offset, which is within the window')
    A_(f'def nnD(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {{V.HC(V.W0(t, x), len) == True{{}} : Bool}},\n'
       f'    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hw32: {{Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{{}} : Bool}})\n'
       f'    -> {{Nat.is_le(U32.to_nat({WN}), O.pow2n(d)) == True{{}} : Bool}}:\n'
       f'  +hA = hcA(t, x, len, hc)\n'
       f'  +hfl = V.ule(V.W0(t, x), len, FD.logic__and_right(U32.is_eq(U32.and(V.W0(t, x), 3), 0), U32.is_le(V.W0(t, x), len), FD.logic__and_left(Bool.and(U32.is_eq(U32.and(V.W0(t, x), 3), 0), U32.is_le(V.W0(t, x), len)), Bool.and(U32.is_le(4, V.W0(t, x)), True{{}}), hc)))\n'
       f'  +hNq = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(V.W0(t, x)), A.quad(U32.to_nat({WN})), Equal.sym(Nat, A.quad(U32.to_nat({WN})), U32.to_nat(V.W0(t, x)), quadN(t, x, len, hc)),\n'
       f'    FD.nat__le_trans(U32.to_nat(V.W0(t, x)), U32.to_nat(len), A.quad(VB.pw(d)), hfl, V.hlen(d, x, len, hw)))\n'
       f'  FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat({WN}), z) == True{{}} : Bool}}, VB.pw(d), O.pow2n(d), VD.s_pow2_eq(d), VC.quad_inv(U32.to_nat({WN}), VB.pw(d), hNq))')
    A_('')
    A_(f'def dw_lt(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {{V.HC(V.W0(t, x), len) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 31n) == True{{}} : Bool}},\n'
       f'    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hw32: {{Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{{}} : Bool}})\n'
       f'    -> {{Nat.is_lt(B.words_depth({WN}), 31n) == True{{}} : Bool}}:\n'
       f'  FD.nat__le_lt_trans(B.words_depth({WN}), d, 31n, VD.wd_min({WN}, d, nnD(d, t, x, len, hc, hw, hw32)), hd)')
    A_('')
    A_(f'def dw_cov(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {{V.HC(V.W0(t, x), len) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 31n) == True{{}} : Bool}},\n'
       f'    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hw32: {{Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{{}} : Bool}})\n'
       f'    -> {{Nat.is_le(U32.to_nat({WN}), FD.spec_common__pow2(B.words_depth({WN}))) == True{{}} : Bool}}:\n'
       f'  FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat({WN}), z) == True{{}} : Bool}}, O.pow2n(B.words_depth({WN})), FD.spec_common__pow2(B.words_depth({WN})), Equal.sym(Nat, FD.spec_common__pow2(B.words_depth({WN})), O.pow2n(B.words_depth({WN})), VD.s_pow2_eq(B.words_depth({WN}))),\n'
       f'    VD.wd_cover({WN}, d, FD.nat__lt_le(d, 32n, FD.nat__lt_trans(d, 31n, 32n, hd, {{==}})), nnD(d, t, x, len, hc, hw, hw32)))')
    A_('')
    DWL = 'dw_lt(d, t, x, len, hc, hd, hw, hw32)'
    DWC = 'dw_cov(d, t, x, len, hc, hd, hw, hw32)'
    # arr_eq / obj_eq as in e2e_dvl
    s = tr(D['arr_eq'])
    s = s.replace('+hchk: {V.CHKw(t, x, off, len) == True{} : Bool})', '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)' % WF_SIG, 1)
    s = s.replace('dw_lt(t, x, len, hc)', DWL).replace('dw_cov(t, x, len, hc)', DWC)
    s = s.replace('obje_canon(d, t, x, off, V.W0(t, x), V.B1(t, x, len))', 'obje_canon(d, t, x, off, len, %s, V.W0(t, x), V.B1(t, x, len), ee0_of(t, x, off, len, ec, hchk))' % WF_ARG)
    s = s.replace('inv0(t, x, len, hc))))', 'inv0(t, x, len, hc), %s, ev0_of(t, x, off, len, ec, hchk))))' % WF_ARG)
    A_(s)
    A_('')
    s = tr(D['obj_eq'])
    s = s.replace('+hchk: {V.CHKw(t, x, off, len) == True{} : Bool})', '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)' % WF_SIG, 1)
    s = s.replace('arr_eq(d, t, x, off, len, ec, hchk', 'arr_eq(d, t, x, off, len, ec, hchk, %s' % WF_ARG)
    A_(s)
    A_('')
    # the representation invariant: no limit
    s = tr(D['rep_c'])
    s = re.sub(r'\+es: \{SH\.ListOf_limit\(s\) == U32\.to_nat\(1048576\) : Nat\},\s*', '', s)
    s = s.replace('obj_eq(d, t, x, off, len, ec, hchk)', 'obj_eq(d, t, x, off, len, ec, hchk, %s)' % WF_ARG)
    s = s.replace('dw_lt(t, x, len, hc)', DWL).replace('dw_cov(t, x, len, hc)', DWC)
    s = s.replace('inv0(t, x, len, hc), eo,', 'inv0(t, x, len, hc), eo,')
    i0 = s.index('case True{}: ((')
    s = s.replace('case True{}: ((FD.array__trep(', 'case True{}: (FD.array__trep(', 1)
    j0 = s.index(', FD.nat__zero_le(SH.ListOf_limit(s)))')
    s = s[:j0] + s[j0 + len(', FD.nat__zero_le(SH.ListOf_limit(s)))'):]
    assert '      (((RVT(' in s
    s = s.replace('      (((RVT(', '      ((RVT(', 1)
    jt = s.index(',\n        FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(V.NN(t, x)), z) == True{} : Bool}')
    s = s[:jt]
    assert 'ListOf_limit' not in s, s[-400:]
    A_(s.replace('+ee: {SH.ListOf_element(s) ==', '+ee: {SH.ProgressiveList_element(s) =='))
    A_('')
    A_(f'def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {WF_SIG}, +s: S.Schema, +ee: {{SH.ProgressiveList_element(s) == {P["ESCH"]} : S.Schema}}, +hchk: {{V.CHKw(t, x, off, len) == True{{}} : Bool}})\n'
       f'    -> RT.rep_{c}(V.OBJw(d, t, x, off, len), s):\n  rep_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WF_ARG}, hchk, s, ee)')
    A_('')
    # the byte count
    A_(f'def blsum(k: Nat, +W: List<&2, RT.MB<RT.M_{X}>>, +i: Nat) -> {{W8.BL(k, {EL_["LM"]}(W), i) == SUMN(k, W, i) : Nat}}:\n'
       f'  match k:\n    case 0n: {{==}}\n    case 1n+ +q:\n'
       f'      Equal.trans(Nat, W8.BL(1n+q, {EL_["LM"]}(W), i), Nat.add(List.length(&2, U32, W8.YE(W8.xat_{c}({EL_["LM"]}(W), i))), W8.BL(q, {EL_["LM"]}(W), 1n+i)), SUMN(1n+q, W, i), W8.bl_cons(q, {EL_["LM"]}(W), i),\n'
       f'        Equal.trans(Nat, Nat.add(List.length(&2, U32, W8.YE(W8.xat_{c}({EL_["LM"]}(W), i))), W8.BL(q, {EL_["LM"]}(W), 1n+i)), Nat.add(NRa(RT.xat_{c}(W, i)), W8.BL(q, {EL_["LM"]}(W), 1n+i)), SUMN(1n+q, W, i),\n'
       f'          Equal.cong(W8.MB<EM.MW>, Nat, z => Nat.add(List.length(&2, U32, W8.YE(z)), W8.BL(q, {EL_["LM"]}(W), 1n+i)), W8.xat_{c}({EL_["LM"]}(W), i), {EL_["cvE"]}(RT.xat_{c}(W, i)), {EL_["xatlm"]}(W, i)),\n'
       f'          Equal.cong(Nat, Nat, z => Nat.add(NRa(RT.xat_{c}(W, i)), z), W8.BL(q, {EL_["LM"]}(W), 1n+i), SUMN(q, W, 1n+i), blsum(q, W, 1n+i))))')
    A_('')
    TM = EL_['TM'] if 'TM' in EL_ else f'EL.TM_{c}'
    TM = f'EL.TM_{c}'
    A_(f'def lnT(+T: FD.array__Tree<RT.MB<RT.M_{X}>>, +n: U32) -> {{W8.LL({TM}(T), n) == Nat.add(A.quad(U32.to_nat(n)), SUMN(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_{X}>, T), 0n)) : Nat}}:\n'
       f'  %Equal.sym(List<&2, W8.MB<EM.MW>>, FD.array__slots(W8.MB<EM.MW>, {TM}(T)), {EL_["LM"]}(FD.array__slots(RT.MB<RT.M_{X}>, T)), {EL_["slcv"]}(T)) :\n'
       f'    {{Nat.add(A.quad(U32.to_nat(n)), W8.BL(U32.to_nat(n), _, 0n)) == Nat.add(A.quad(U32.to_nat(n)), SUMN(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_{X}>, T), 0n)) : Nat}}\n'
       f'  Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(n)), z), W8.BL(U32.to_nat(n), {EL_["LM"]}(FD.array__slots(RT.MB<RT.M_{X}>, T)), 0n), SUMN(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_{X}>, T), 0n),\n'
       f'    blsum(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_{X}>, T), 0n))')
    A_('')
    if P['LN'] is None:
        A_(f'def LNQ(w: {SEQ}) -> Nat:\n  match w:\n    case {SEQ}{{arr, +n}}: W8.LL({TM}(RT.tfz_{c}(arr)), n)')
        A_('')
    # the byte count: szl_c as in e2e_dvl (the list's encoder bytes, from the tree)
    s = tr(D['txl_c'])
    s = s.replace('def txl_c', 'def szl_c').replace('{TX.TXL(', '{%s(' % LNF).replace('{LNM(', '{%s(' % LNF)
    s = s.replace('obj_eq(d, t, x, off, len, ec, hchk)', 'obj_eq(d, t, x, off, len, ec, hchk, %s)' % WF_ARG)
    s = s.replace('dw_lt(t, x, len, hc)', DWL).replace('dw_cov(t, x, len, hc)', DWC)
    a2 = 'inv0(t, x, len, hc), ee0_of('
    assert s.count(a2) == 1, s.count(a2)
    s = s.replace(a2, 'inv0(t, x, len, hc), %s, ee0_of(' % WF_ARG)
    a3 = 'FD.logic__subst(FD.array__Tree<RT.MB<RT.M_%s>>, z => {Nat.add(A.quad(U32.to_nat(V.NN(t, x))), SUMN(U32.to_nat(V.NN(t, x)), FD.array__slots(RT.MB<RT.M_%s>, z), 0n)) == U32.to_nat(len) : Nat},\n        ' % (X, X)
    assert a3 in s
    k = s.index(a3) + len(a3)
    R = s[k:close_paren(s, s.index('(', k)) + 1]
    assert R.startswith('RVT(')
    s = s.replace(a3, 'FD.logic__subst(FD.array__Tree<RT.MB<RT.M_%s>>, z => {W8.LL(%s(z), V.NN(t, x)) == U32.to_nat(len) : Nat},\n        ' % (X, TM))
    r = s.index('rv_sum(')
    rc = close_paren(s, r + len('rv_sum'))
    rs = s[r:rc + 1]
    inner = ('Equal.trans(Nat, W8.LL(%s(%s), V.NN(t, x)), Nat.add(A.quad(U32.to_nat(V.NN(t, x))), SUMN(U32.to_nat(V.NN(t, x)), FD.array__slots(RT.MB<RT.M_%s>, %s), 0n)), U32.to_nat(len), lnT(%s, V.NN(t, x)),\n          %s)' % (TM, R, X, R, R, rs))
    s = s[:r] + inner + s[rc + 1:]
    A_(s)
    A_('')
    # the encode premise: PM of the tree of the writes
    TREP = f'FD.array__trep(RT.MB<RT.M_{X}>, B.words_depth(V.NN(t, x)), RT.MNone{{}})'
    K0 = 'U32.to_nat(U32.sub(V.NN(t, x), 1))'
    WD = 'B.words_depth(V.NN(t, x))'
    XE0 = 'XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))'
    RR = f'RVT({K0}, 0, V.NN(t, x), {WD}, d, t, x, off, len, {TREP}, {XE0})'
    PFR = f'rvt_pf({K0}, 0, V.NN(t, x), {WD}, d, t, x, off, len, {TREP}, {XE0}, FD.array__trep_perfect(RT.MB<RT.M_{X}>, {WD}, RT.MNone{{}}))'
    WINS = '+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'
    HCK = '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}'
    hdw = f'FD.nat__lt_trans({WD}, 31n, 32n, {DWL}, {{==}})'
    A_(f'def llw({WINS}, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {WF_SIG}, {HCK}) -> {{W8.LL({TM}({RR}), V.NN(t, x)) == U32.to_nat(len) : Nat}}:\n'
       f'  +hc = hc_of(t, x, off, len, ec, hchk)\n  {inner}')
    A_('')
    A_(f'def pm_f({WINS}, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {WF_SIG}, {HCK}, +h31: {{Nat.is_lt(U32.to_nat(len), VB.pw(31n)) == True{{}} : Bool}})\n'
       f'    -> {PM}({RR}, V.NN(t, x)):\n'
       f'  +hc = hc_of(t, x, off, len, ec, hchk)\n'
       f'  (FD.logic__subst(Nat, z => {{Nat.is_lt(z, 31n) == True{{}} : Bool}}, {WD}, ER.LDEP(RT.MB<RT.M_{X}>, {RR}), Equal.sym(Nat, ER.LDEP(RT.MB<RT.M_{X}>, {RR}), {WD}, ER.pdep(RT.MB<RT.M_{X}>, {WD}, {RR}, {PFR})), {DWL}),\n'
       f'    (FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(31n)) == True{{}} : Bool}}, U32.to_nat(len), W8.LL({TM}({RR}), V.NN(t, x)), Equal.sym(Nat, W8.LL({TM}({RR}), V.NN(t, x)), U32.to_nat(len), llw(d, t, x, off, len, ec, {WF_ARG}, hchk)), h31),\n'
       f'      rv_sdks({K0}, 0, V.NN(t, x), {WD}, d, t, x, off, len, {TREP}, V.W0(t, x), V.B1(t, x, len), {hdw}, FD.array__trep_perfect(RT.MB<RT.M_{X}>, {WD}, RT.MNone{{}}),\n'
       f'        {DWC}, inv0(t, x, len, hc), {WF_ARG}, ee0_of(t, x, off, len, ec, hchk), ev0_of(t, x, off, len, ec, hchk), {{==}})))')
    A_('')
    A_(f'def sd_c(+c: Bool, {WINS}, +ec: {{U32.is_eq(len, 0) == c : Bool}}, {WF_SIG}, {HCK}, +h31: {{Nat.is_lt(U32.to_nat(len), VB.pw(31n)) == True{{}} : Bool}})\n'
       f'    -> {PRV}(V.RZ(c, d, t, x, off, len)):\n'
       f'  match c:\n'
       f'    case True{{}}: ({{==}}, (FD.logic__subst(U32, z => {{Nat.is_lt(U32.to_nat(z), VB.pw(31n)) == True{{}} : Bool}}, len, 0, FD.u32alg__eq_of(len, 0, ec), h31), {{==}}))\n'
       f'    case False{{}}:\n'
       f'      %Equal.sym({SEQ}, V.RZ(False{{}}, d, t, x, off, len), {SEQ}{{RT.am_{c}({RR}), V.NN(t, x)}}, obj_eq(d, t, x, off, len, ec, hchk, {WF_ARG})) : {PRV}(_)\n'
       f'      FD.logic__subst(FD.array__Tree<RT.MB<RT.M_{X}>>, z => {PM}(z, V.NN(t, x)), {RR}, RT.tfz_{c}(RT.am_{c}({RR})), Equal.sym(FD.array__Tree<RT.MB<RT.M_{X}>>, RT.tfz_{c}(RT.am_{c}({RR})), {RR}, RT.tfzam_{c}({RR})), pm_f(d, t, x, off, len, ec, {WF_ARG}, hchk, h31))')
    A_('')
    A_(f'def sdl({WINS}, {WF_SIG}, +h31: {{Nat.is_lt(U32.to_nat(len), VB.pw(31n)) == True{{}} : Bool}}, {HCK}) -> {PRV}(V.OBJw(d, t, x, off, len)):\n'
       f'  sd_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WF_ARG}, hchk, h31)')
    A_('')
    A_(f'def szl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {WF_SIG}, +hchk: {{V.CHKw(t, x, off, len) == True{{}} : Bool}})\n'
       f'    -> {{{LNF}(V.OBJw(d, t, x, off, len)) == U32.to_nat(len) : Nat}}:\n'
       f'  szl_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WF_ARG}, hchk)')
    A_('')
    return '\n'.join(out) + '\n'


def main():
    outs = {E2E / ('e2e_dvp_%s.bend' % c): text(c) for c in LISTS}
    check = '--check' in sys.argv
    stale = [p.name for p, t in outs.items() if not p.exists() or p.read_text() != t]
    if check:
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('e2e_dvp: up to date')
        return
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print('e2e_dvp: %d files' % len(outs))


if __name__ == '__main__':
    main()
