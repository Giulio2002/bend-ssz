#!/usr/bin/env python3
"""e2e/e2e_dvp_<list>.bend: a progressive list of variable-size boxed records (pl_VarTestStruct, pl_pl_VarTestStruct, ...) read at a byte window
(proofs/obj/vvl_<list>.bend: V) satisfies the root laws' representation invariant rep_<list> and the encode premise PRV_<list> of the container that
holds it (e2e_encld.bend: EL), and its encoder's byte count is the window's:

    sdl(d, t, x, off, len, WF, h31, hchk)                EL.PRV_<list>(V.OBJw(d, t, x, off, len))
    rep(d, t, x, off, len, WF, s, ee, hchk)              RT.rep_<list>(V.OBJw(d, t, x, off, len), s)        [RT = root_gtypes2_light]
    szl(d, t, x, off, len, WF, hchk)                     LN(V.OBJw(d, t, x, off, len)) == to_nat(len)   (LN: the encoder's byte count of the list)

WF is the window facts eo, hd, hw, hw32, pfw (the argument order of e2e_dvl_*); h31: the window is shorter than 2^31 bytes (the container's total bound).
The proofs are variable_record_list_decoded_facts.py's (e2e_dtx.bend's loops over the same reader interface), with the progressive lists' check (no count limit: the tree's depth
is bounded by the window's: hd, hw) and the element facts from a hook module E (e2e_hkv.bend, or another list library e2e_dvp_*.bend) in the
convention (d, t, x, off, len, hchk, WF, ...): repT, sde, sz, canon.

Usage: python3 codegen/proofs/decoded/progressive_variable_list_decoded_facts.py [--check]"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.proofs.decoded import variable_record_list_decoded_facts as DVL
from codegen.proofs.decoded.variable_record_list_decoded_facts import WF_ARG, WF_SIG, close_paren, dtx_defs

from codegen.core.repository_paths import ROOT  # noqa: E402
E2E = ROOT / 'e2e'

LISTS = {
    'pl_VarTestStruct': dict(
        X='VarTestStruct', ELTI='../types/VarTestStruct_def_generated.bend as VarTestStruct_d', ELT='VarTestStruct_d.VarTestStruct',
        LSTI='../types/proglist_VarTestStruct_def_generated.bend as proglist_VarTestStruct_d', LST='proglist_VarTestStruct_d',
        HK='e2e_hkv.bend', ENC='proofs/obj/encx_pl_VarTestStruct.bend', EMI='proofs/obj/encx_VarTestStruct_iface.bend',
        ESCH='Spec.VarTestStruct()', SPECI='../proofs/obj/generic_specs.bend as Spec', LN=None),
    # elements are pl_VarTestStruct windows: the element hooks (e2e_hpl.bend) need the element's 2^31 bound, so h31 is one of the window facts here
    'pl_pl_VarTestStruct': dict(
        X='pl_VarTestStruct', ELTI='../types/proglist_VarTestStruct_def_generated.bend as proglist_VarTestStruct_d', ELT='proglist_VarTestStruct_d.pl_VarTestStruct_Seq',
        LSTI='../types/proglist_proglist_VarTestStruct_def_generated.bend as proglist_proglist_VarTestStruct_d', LST='proglist_proglist_VarTestStruct_d',
        HK='e2e_hpl_pl_VarTestStruct.bend', ENC='proofs/obj/encx_pl_pl_VarTestStruct.bend', EMI='proofs/obj/encx_pl_VarTestStruct.bend',
        ESCH='S.ProgressiveList{Spec.VarTestStruct()}', SPECI='../proofs/obj/generic_specs.bend as Spec', LN=None, H31=True, THFZ=False),
    # elements are ProgressiveVarTestStruct windows: the decoder's own bounds (x + len <= NMAX, len < 2^29) are window facts here too
    'pl_ProgressiveVarTestStruct': dict(
        X='ProgressiveVarTestStruct', ELTI='../types/ProgressiveVarTestStruct_def_generated.bend as ProgressiveVarTestStruct_d', ELT='ProgressiveVarTestStruct_d.ProgressiveVarTestStruct',
        LSTI='../types/proglist_ProgressiveVarTestStruct_def_generated.bend as proglist_ProgressiveVarTestStruct_d', LST='proglist_ProgressiveVarTestStruct_d',
        HK='e2e_hkp.bend', ENC='proofs/obj/encx_pl_ProgressiveVarTestStruct.bend', EMI='proofs/obj/encx_ProgressiveVarTestStruct_iface.bend',
        ESCH='Spec.ProgressiveVarTestStruct()', SPECI='../proofs/obj/generic_specs.bend as Spec', LN=None, H31=True, H31E=29, HWN=True, THFZ=False),
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


def _dvp_config(c):
    """the list's configuration (its names, window facts, element maps) and the text builders"""
    P = LISTS[c]
    H31 = P.get('H31', False)
    H31E = P.get('H31E', 31)   # the window facts' bound: len < 2^H31E (the encode premise needs < 2^31)
    HWN = P.get('HWN', False)   # the window fact hw32 (x + len < 2^32) is x + len <= NMAX (the window libraries of the progressive bit lists take it)
    H31T = '+h31: {Nat.is_lt(U32.to_nat(len), VB.pw(%dn)) == True{} : Bool}' % H31E
    WSIG = WF_SIG + (', ' + H31T if H31 else '')
    WARG = WF_ARG + (', h31' if H31 else '')
    H31U = 'VB.le_pw31_nmax(U32.to_nat(len), h31)' if H31E == 31 else 'lt31(len, h31)'   # the encode premise's bound from the window facts'
    H31S = '' if H31 else ', ' + H31T   # a separate h31 argument after the window facts
    H31A = '' if H31 else ', h31'
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
        t = t.replace(DVL.HWN_SIG, '\x00SIG\x00')
        t = re.sub(r'\bhwN\b', WARG, t)
        t = t.replace('\x00SIG\x00', WSIG)
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
    return P, H31, H31E, HWN, H31T, WSIG, WARG, H31U, H31S, H31A, X, ELT, SEQ, D, VD_, EL_, LNF, PRV, PM, tr, vl


def _dvp_header_and_eqe(c, P, H31, H31E, H31T, WSIG, X, ELT, VD_, vl):
    """the module header, the reader's array facts and eqE"""
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
    A_('# GENERATED by progressive_variable_list_decoded_facts (codegen) from e2e_dtx.bend and e2e_vlm_l8_Attestation.bend. Do not edit.')
    A_(f'# The progressive list a window reads ({c}, vvl_{c}) satisfies the root laws\' invariant rep_{c} and the encode premise PRV_{c}; its encoder\'s bytes are the window\'s.')
    A_('')
    A_('# ---- the reader\'s array is the array of the tree of its writes (e2e_vlm_l8_Attestation.bend\'s, for this list) ----')
    for n in ['e1', 'inv1', 'hiq', 'isne']:
        A_(vl(VD_[n]))
        A_('')
    if H31:
        A_('# an element window is at most the list window: its facts from the list window\'s')
        A_('def h31ab(+len: U32, +a: U32, +b: U32, +hab: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}, +hb: {Nat.is_le(U32.to_nat(b), U32.to_nat(len)) == True{} : Bool},\n'
           '    +h31: {Nat.is_lt(U32.to_nat(len), VB.pw(%dn)) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat(U32.sub(b, a)), VB.pw(%dn)) == True{} : Bool}:\n' % (H31E, H31E) +
           '  +e = FD.u32__sub_nat(b, a, hab)\n'
           '  +s1 = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(U32.sub(b, a)), Nat.add(U32.to_nat(a), z)) == True{} : Bool}, U32.to_nat(U32.sub(b, a)), Nat.sub(U32.to_nat(b), U32.to_nat(a)), e,\n'
           '    Order.left_below_sum(U32.to_nat(a), U32.to_nat(U32.sub(b, a))))\n'
           '  +s2 = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(U32.sub(b, a)), z) == True{} : Bool}, Nat.add(U32.to_nat(a), Nat.sub(U32.to_nat(b), U32.to_nat(a))), U32.to_nat(b), FD.nat__sub_add(U32.to_nat(b), U32.to_nat(a), hab), s1)\n'
           '  FD.nat__le_lt_trans(U32.to_nat(U32.sub(b, a)), U32.to_nat(len), VB.pw(%dn), FD.nat__le_trans(U32.to_nat(U32.sub(b, a)), U32.to_nat(b), U32.to_nat(len), s2, hb), h31)' % H31E)
        A_('')
        if H31E != 31:
            A_('# the list window below 2^%d is below 2^31, the encode premise\'s bound' % H31E)
            assert H31E == 29
            A_('def bbq() -> {VB.pw(31n) == A.quad(VB.pw(29n)) : Nat}:\n'
               '  %Equal.sym(Nat, 31n, 2n+29n, {==}) : {VB.pw(_) == A.quad(VB.pw(29n)) : Nat}\n'
               '  {==}\n\n'
               'def lt31(+len: U32, +h: {Nat.is_lt(U32.to_nat(len), VB.pw(29n)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(len), U32.to_nat(VB.NMAX())) == True{} : Bool}:\n'
               '  VB.le_pw31_nmax(U32.to_nat(len), FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(len), z) == True{} : Bool}, A.quad(VB.pw(29n)), VB.pw(31n), Equal.sym(Nat, VB.pw(31n), A.quad(VB.pw(29n)), bbq()),\n'
               '    FD.nat__lt_le_trans(U32.to_nat(len), VB.pw(29n), A.quad(VB.pw(29n)), h, A.quad_ge(VB.pw(29n)))))')
            A_('')
    SUB = ('Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a)')
    EEP = '+hEE: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool}'

    def HK(f, extra='', s='a', e='b', hh='hEE'):
        ab = f'V.el_ab(t, x, off, len, {s}, {e}, {hh})'
        bb_ = f'V.el_b(t, x, off, len, {s}, {e}, {hh})'
        sub = f'Nat.add(U32.to_nat({s}), x), U32.add(off, {s}), U32.sub({e}, {s})'
        return (f'E.{f}(d, t, {sub}, V.el_c(t, x, off, len, {s}, {e}, {hh}), '
                f'V.eocD(d, x, off, len, {s}, FD.nat__le_trans(U32.to_nat({s}), U32.to_nat({e}), U32.to_nat(len), {ab}, {bb_}), eo, hd, hw, hw32), hd, '
                f'V.hwab(d, x, len, {s}, {e}, {ab}, {bb_}, hw), V.hwab32(x, len, {s}, {e}, {ab}, {bb_}, hw32), pfw' + (f', h31ab(len, {s}, {e}, {ab}, {bb_}, h31)' if H31 else '') + f'{extra})')
    for n in ['ND_l8_Attestation', 'NV_l8_Attestation', 'FT_l8_Attestation', 'pfFT_l8_Attestation', 'fillam_l8_Attestation', 'hx_at_l8_Attestation']:
        A_(vl(VD_[n]))
        A_('')
    A_(f'def eqE_{c}(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {WSIG}, +a: U32, +b: U32, +hEE: {{V.EE(True{{}}, t, x, off, len, a, b) == True{{}} : Bool}})\n'
       f'    -> {{V.OBJE(d, t, x, off, a, b) == RT.th_{X}_bx(ND_{c}(d, t, x, off, a, b)) : O.Boxed<{ELT}>}}:\n'
       f'  Equal.sym(O.Boxed<{ELT}>, RT.th_{X}_bx(ND_{c}(d, t, x, off, a, b)), V.OBJE(d, t, x, off, a, b), {HK("canon")})')
    A_('')
    # rvF with the element canon: the vlm text, its eqE replaced
    s = vl(VD_['rvF_l8_Attestation'])
    if H31:   # the element facts of eqE take the extra window facts too: the vlm text's window facts (eo, hd, hw, hw32, pf) get them after pf
        ex_sig = ', ' + H31T
        ex_arg = ', h31'
        for a, b in [('+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +dd', '+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}' + ex_sig + ', +dd'),
                     ('hw32, pf, V.WJ(t, x, i)', 'hw32, pf' + ex_arg + ', V.WJ(t, x, i)'), ('hw32, pf, dd, FD', 'hw32, pf' + ex_arg + ', dd, FD')]:
            assert s.count(a) == 1, (a, s.count(a))
            s = s.replace(a, b)
    A_(s)
    A_('')
    return out, A_, EEP, HK


def _dvp_element_facts(c, P, WSIG, WARG, X, ELT, D, EL_, tr, A_, EEP, HK):
    """the elements' facts at a window: XE, the canonical object, the sums and the induction lemmas"""
    A_('# ---- the elements\' facts at a window ----')
    HEAD = '(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, %s, +a: U32, +b: U32, %s' % (WSIG, EEP)
    A_('def XE(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32) -> RT.MB<RT.M_%s>: RT.fz_%s_bx(V.OBJE(d, t, x, off, s, e))' % (X, X))
    A_('')
    A_('def obje_canon%s)\n    -> {RT.th_%s_bx(XE(d, t, x, off, a, b)) == V.OBJE(d, t, x, off, a, b) : O.Boxed<%s>}:\n'
       '  Equal.sym(O.Boxed<%s>, V.OBJE(d, t, x, off, a, b), RT.th_%s_bx(XE(d, t, x, off, a, b)), eqE_%s(d, t, x, off, len, %s, a, b, hEE))'
       % (HEAD, X, ELT, ELT, X, c, WARG))
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
       % (X, X, X, WSIG, c, X, c, ELT, c, WARG))
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
    s = s.replace('+hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool},', WSIG + ',\n    +hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool},', 1)
    s, k = re.subn(r'Equal\.trans\(Nat, Nat\.add\(U32\.to_nat\(s\), U32\.to_nat\(U32\.sub\(a, s\)\)\), U32\.to_nat\(a\), (.*?), tele\(s, a, hab\),',
                   lambda m: 'Equal.trans(Nat, Nat.add(U32.to_nat(s), NRa(XE(d, t, x, off, s, a))), U32.to_nat(a), %s, szel(d, t, x, off, len, %s, s, a, hEE),' % (m.group(1), WARG), s)
    assert k == 2, k
    a1 = 'V.inv_nx(q, i, m, inv),\n        V.ev_ok('
    assert s.count(a1) == 1
    s = s.replace(a1, 'V.inv_nx(q, i, m, inv), %s,\n        V.ev_ok(' % WARG)
    A_(s)
    A_('')
    for n in ['fill_am', 'rvt_pf', 'hc_of', 'evb_of', 'hcA', 'hcC', 'quadN', 'nn1', 'succ_pred', 'inv0', 'nxk0', 'ev_start', 'ee0_of', 'ev0_of']:
        A_(tr(D[n]))
        A_('')


def _dvp_count_bounds(A_):
    """the count of records is at most 2^d: nnD, dw_lt and dw_cov"""
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
    return DWL, DWC


def _dvp_object_laws(c, P, WSIG, WARG, D, tr, A_, DWL, DWC):
    """the array, object and representation laws of the list window"""
    s = tr(D['arr_eq'])
    s = s.replace('+hchk: {V.CHKw(t, x, off, len) == True{} : Bool})', '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)' % WSIG, 1)
    s = s.replace('dw_lt(t, x, len, hc)', DWL).replace('dw_cov(t, x, len, hc)', DWC)
    s = s.replace('obje_canon(d, t, x, off, V.W0(t, x), V.B1(t, x, len))', 'obje_canon(d, t, x, off, len, %s, V.W0(t, x), V.B1(t, x, len), ee0_of(t, x, off, len, ec, hchk))' % WARG)
    s = s.replace('inv0(t, x, len, hc))))', 'inv0(t, x, len, hc), %s, ev0_of(t, x, off, len, ec, hchk))))' % WARG)
    A_(s)
    A_('')
    s = tr(D['obj_eq'])
    s = s.replace('+hchk: {V.CHKw(t, x, off, len) == True{} : Bool})', '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)' % WSIG, 1)
    s = s.replace('arr_eq(d, t, x, off, len, ec, hchk', 'arr_eq(d, t, x, off, len, ec, hchk, %s' % WARG)
    A_(s)
    A_('')
    # the representation invariant: no limit
    s = tr(D['rep_c'])
    s = re.sub(r'\+es: \{SH\.ListOf_limit\(s\) == U32\.to_nat\(1048576\) : Nat\},\s*', '', s)
    s = s.replace('obj_eq(d, t, x, off, len, ec, hchk)', 'obj_eq(d, t, x, off, len, ec, hchk, %s)' % WARG)
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
    A_(f'def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {WSIG}, +s: S.Schema, +ee: {{SH.ProgressiveList_element(s) == {P["ESCH"]} : S.Schema}}, +hchk: {{V.CHKw(t, x, off, len) == True{{}} : Bool}})\n'
       f'    -> RT.rep_{c}(V.OBJw(d, t, x, off, len), s):\n  rep_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WARG}, hchk, s, ee)')
    A_('')


def _dvp_byte_sums(c, P, WARG, X, SEQ, D, EL_, LNF, tr, A_, DWL, DWC):
    """the bytes of the elements: blsum, lnT and the list's length law"""
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
    # the byte count: szl_c as in variable_record_list_decoded_facts (the list's encoder bytes, from the tree)
    s = tr(D['txl_c'])
    s = s.replace('def txl_c', 'def szl_c').replace('{TX.TXL(', '{%s(' % LNF).replace('{LNM(', '{%s(' % LNF)
    s = s.replace('obj_eq(d, t, x, off, len, ec, hchk)', 'obj_eq(d, t, x, off, len, ec, hchk, %s)' % WARG)
    s = s.replace('dw_lt(t, x, len, hc)', DWL).replace('dw_cov(t, x, len, hc)', DWC)
    a2 = 'inv0(t, x, len, hc), ee0_of('
    assert s.count(a2) == 1, s.count(a2)
    s = s.replace(a2, 'inv0(t, x, len, hc), %s, ee0_of(' % WARG)
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
    return TM, inner


def _dvp_root_laws(c, P, WSIG, WARG, H31U, H31S, H31A, X, SEQ, LNF, PRV, PM, A_, DWL, DWC, TM, inner):
    """the root-side laws: lengths, premises, the reader's facts and the thaw of the first element"""
    TREP = f'FD.array__trep(RT.MB<RT.M_{X}>, B.words_depth(V.NN(t, x)), RT.MNone{{}})'
    K0 = 'U32.to_nat(U32.sub(V.NN(t, x), 1))'
    WD = 'B.words_depth(V.NN(t, x))'
    XE0 = 'XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))'
    RR = f'RVT({K0}, 0, V.NN(t, x), {WD}, d, t, x, off, len, {TREP}, {XE0})'
    PFR = f'rvt_pf({K0}, 0, V.NN(t, x), {WD}, d, t, x, off, len, {TREP}, {XE0}, FD.array__trep_perfect(RT.MB<RT.M_{X}>, {WD}, RT.MNone{{}}))'
    WINS = '+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'
    HCK = '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}'
    hdw = f'FD.nat__lt_trans({WD}, 31n, 32n, {DWL}, {{==}})'
    A_(f'def llw({WINS}, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {WSIG}, {HCK}) -> {{W8.LL({TM}({RR}), V.NN(t, x)) == U32.to_nat(len) : Nat}}:\n'
       f'  +hc = hc_of(t, x, off, len, ec, hchk)\n  {inner}')
    A_('')
    A_(f'def pm_f({WINS}, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {WSIG}, {HCK}{H31S})\n'
       f'    -> {PM}({RR}, V.NN(t, x)):\n'
       f'  +hc = hc_of(t, x, off, len, ec, hchk)\n'
       f'  (FD.logic__subst(Nat, z => {{Nat.is_lt(z, 31n) == True{{}} : Bool}}, {WD}, ER.LDEP(RT.MB<RT.M_{X}>, {RR}), Equal.sym(Nat, ER.LDEP(RT.MB<RT.M_{X}>, {RR}), {WD}, ER.pdep(RT.MB<RT.M_{X}>, {WD}, {RR}, {PFR})), {DWL}),\n'
       f'    (FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(VB.NMAX())) == True{{}} : Bool}}, U32.to_nat(len), W8.LL({TM}({RR}), V.NN(t, x)), Equal.sym(Nat, W8.LL({TM}({RR}), V.NN(t, x)), U32.to_nat(len), llw(d, t, x, off, len, ec, {WARG}, hchk)), {H31U}),\n'
       f'      rv_sdks({K0}, 0, V.NN(t, x), {WD}, d, t, x, off, len, {TREP}, V.W0(t, x), V.B1(t, x, len), {hdw}, FD.array__trep_perfect(RT.MB<RT.M_{X}>, {WD}, RT.MNone{{}}),\n'
       f'        {DWC}, inv0(t, x, len, hc), {WARG}, ee0_of(t, x, off, len, ec, hchk), ev0_of(t, x, off, len, ec, hchk), {{==}})))')
    A_('')
    A_(f'def sd_c(+c: Bool, {WINS}, +ec: {{U32.is_eq(len, 0) == c : Bool}}, {WSIG}, {HCK}{H31S})\n'
       f'    -> {PRV}(V.RZ(c, d, t, x, off, len)):\n'
       f'  match c:\n'
       f'    case True{{}}: ({{==}}, (FD.logic__subst(U32, z => {{Nat.is_le(U32.to_nat(z), U32.to_nat(VB.NMAX())) == True{{}} : Bool}}, len, 0, FD.u32alg__eq_of(len, 0, ec), {H31U}), {{==}}))\n'
       f'    case False{{}}:\n'
       f'      %Equal.sym({SEQ}, V.RZ(False{{}}, d, t, x, off, len), {SEQ}{{RT.am_{c}({RR}), V.NN(t, x)}}, obj_eq(d, t, x, off, len, ec, hchk, {WARG})) : {PRV}(_)\n'
       f'      FD.logic__subst(FD.array__Tree<RT.MB<RT.M_{X}>>, z => {PM}(z, V.NN(t, x)), {RR}, RT.tfz_{c}(RT.am_{c}({RR})), Equal.sym(FD.array__Tree<RT.MB<RT.M_{X}>>, RT.tfz_{c}(RT.am_{c}({RR})), {RR}, RT.tfzam_{c}({RR})), pm_f(d, t, x, off, len, ec, {WARG}, hchk{H31A}))')
    A_('')
    A_(f'def sdl({WINS}, {WSIG}{H31S}, {HCK}) -> {PRV}(V.OBJw(d, t, x, off, len)):\n'
       f'  sd_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WARG}, hchk{H31A})')
    A_('')
    A_(f'def szl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {WSIG}, +hchk: {{V.CHKw(t, x, off, len) == True{{}} : Bool}})\n'
       f'    -> {{{LNF}(V.OBJw(d, t, x, off, len)) == U32.to_nat(len) : Nat}}:\n'
       f'  szl_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WARG}, hchk)')
    if P.get('THFZ', True):
        A_('')
        # the object is canonical: freezing then thawing the mirror gives it back (the element hooks of a list of these lists)
        A_(f'def thfz_am(+T: FD.array__Tree<RT.MB<RT.M_{X}>>, +N: U32) -> {{RT.th_{c}(RT.fz_{c}({SEQ}{{RT.am_{c}(T), N}})) == {SEQ}{{RT.am_{c}(T), N}} : {SEQ}}}:\n'
           f'  Equal.cong(FD.array__Tree<RT.MB<RT.M_{X}>>, {SEQ}, z => {SEQ}{{RT.am_{c}(z), N}}, RT.tfz_{c}(RT.am_{c}(T)), T, RT.tfzam_{c}(T))')
        A_('')
        A_(f'def thfz_c(+c: Bool, {WINS}, +ec: {{U32.is_eq(len, 0) == c : Bool}}, {WSIG}, {HCK})\n'
           f'    -> {{RT.th_{c}(RT.fz_{c}(V.RZ(c, d, t, x, off, len))) == V.RZ(c, d, t, x, off, len) : {SEQ}}}:\n'
           f'  match c:\n'
           f'    case True{{}}: thfz_am(FD.array__trep(RT.MB<RT.M_{X}>, 0n, RT.MNone{{}}), 0)\n'
           f'    case False{{}}:\n'
           f'      FD.logic__subst({SEQ}, z => {{RT.th_{c}(RT.fz_{c}(z)) == z : {SEQ}}}, {SEQ}{{RT.am_{c}({RR}), V.NN(t, x)}}, V.RZ(False{{}}, d, t, x, off, len),\n'
           f'        Equal.sym({SEQ}, V.RZ(False{{}}, d, t, x, off, len), {SEQ}{{RT.am_{c}({RR}), V.NN(t, x)}}, obj_eq(d, t, x, off, len, ec, hchk, {WARG})), thfz_am({RR}, V.NN(t, x)))')
        A_('')
        A_(f'def thfz({WINS}, {WSIG}, {HCK}) -> {{RT.th_{c}(RT.fz_{c}(V.OBJw(d, t, x, off, len))) == V.OBJw(d, t, x, off, len) : {SEQ}}}:\n'
           f'  thfz_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, {WARG}, hchk)')
        A_('')


def text(c):
    P, H31, H31E, HWN, H31T, WSIG, WARG, H31U, H31S, H31A, X, ELT, SEQ, D, VD_, EL_, LNF, PRV, PM, tr, vl = _dvp_config(c)

    out, A_, EEP, HK = _dvp_header_and_eqe(c, P, H31, H31E, H31T, WSIG, X, ELT, VD_, vl)
    _dvp_element_facts(c, P, WSIG, WARG, X, ELT, D, EL_, tr, A_, EEP, HK)
    # the progressive check has no count limit: the tree's depth is the window's (hd, hw)
    DWL, DWC = _dvp_count_bounds(A_)
    # arr_eq / obj_eq as in variable_record_list_decoded_facts
    _dvp_object_laws(c, P, WSIG, WARG, D, tr, A_, DWL, DWC)
    # the byte count
    TM, inner = _dvp_byte_sums(c, P, WARG, X, SEQ, D, EL_, LNF, tr, A_, DWL, DWC)
    # the encode premise: PM of the tree of the writes
    _dvp_root_laws(c, P, WSIG, WARG, H31U, H31S, H31A, X, SEQ, LNF, PRV, PM, A_, DWL, DWC, TM, inner)
    res = '\n'.join(out) + '\n'
    if HWN:
        res = res.replace('Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n))', 'Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX()))')
    return res


def main():
    outs = {E2E / ('e2e_dvp_%s.bend' % c): text(c) for c in LISTS}
    check = '--check' in sys.argv
    stale = [p.name for p, t in outs.items() if not p.exists() or p.read_text() != t]
    if check:
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('progressive_variable_list_decoded_facts: up to date')
        return
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print('progressive_variable_list_decoded_facts: %d files' % len(outs))


if __name__ == '__main__':
    main()
