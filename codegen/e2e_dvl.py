#!/usr/bin/env python3
"""e2e/e2e_dvl_<list>.bend: the decoded list of a variable-size boxed record list (l8_Attestation: a list of at most 8 attestations, each a
record with a bit list) satisfies the root laws' invariant of a block body that holds it, from the list window reader's own facts.

The reader (proofs/obj/vvl_<list>.bend: W) writes element c (the window (s, e) of the offset table, read by the element reader
var_winx_<X>.bend) into the array at index c. e2e_vlm_<list>.bend shows the array is am(FT) for the tree FT the same writes build; this file
is e2e_dtx.bend's proof (the transactions list, the same loops over the same reader interface) with the element facts supplied by a hook module
E (e2e_hk_<X>.bend: rep / repT / sde / sz of the element at a window, hand-written):

    rep(d, t, x, off, len, s, es, ee, hchk, eo, hd, hw, hw32, pfw)   the root laws' rep_<list>(OBJw, s)
    szl(d, t, x, off, len, hchk, eo, hd, hw, hw32, pfw)               the list's encoded byte count (the list encoder's LN) is the window's

(the encode premise of the attestation list is e2e_vhl8.vh's). The lemmas are e2e_dtx.bend's text, renamed, with the element facts and the
window facts (eo, hd, hw, hw32, pfw: the window's offset, depth, end and the perfect tree) threaded in place of dtx's hwN.

Usage: python3 codegen/e2e_dvl.py [--check]"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
E2E = ROOT / 'e2e'

LISTS = {
    'l8_Attestation': dict(X='Attestation', LIM=8, DEPTH=3, LST='Fulu_list_Attestation_8_d', HK='e2e_hk_Attestation.bend', BB='e2e_bbatt.bend',
                           ENC='proofs/obj/encx_l8_Attestation.bend', LN='LN8', VM='e2e_vlm_l8_Attestation.bend', VH='e2e_vhl8.bend'),
}

DTX = (E2E / 'e2e_dtx.bend').read_text()


def dtx_defs():
    """name -> text of every def of e2e_dtx.bend, in order"""
    out = {}
    lines = DTX.split('\n')
    i = 0
    while i < len(lines):
        m = re.match(r'def (\w+)\(', lines[i])
        if not m:
            i += 1
            continue
        j = i + 1
        while j < len(lines) and not re.match(r'(def |#)', lines[j]):
            j += 1
        out[m.group(1)] = '\n'.join(lines[i:j]).rstrip()
        i = j
    return out


def close_paren(t, i):
    depth = 0
    for k in range(i, len(t)):
        if t[k] == '(':
            depth += 1
        elif t[k] == ')':
            depth -= 1
            if depth == 0:
                return k
    raise ValueError


def unwrap_nr(t):
    """U32.to_nat(TX.NR(A)) -> NRa(A)"""
    key = 'U32.to_nat(TX.NR('
    while key in t:
        i = t.index(key)
        p1 = i + len('U32.to_nat')
        p2 = i + len('U32.to_nat(TX.NR')
        c2 = close_paren(t, p2)
        c1 = close_paren(t, p1)
        assert c1 == c2 + 1
        t = t[:i] + 'NRa(' + t[p2 + 1:c2] + ')' + t[c1 + 1:]
    return t


WF_SIG = ('+eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},\n'
          '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},\n'
          '    +pfw: {FD.array__perfect(U32, d, t) == True{} : Bool}')
WF_ARG = 'eo, hd, hw, hw32, pfw'
HWN_SIG = '+hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}'


def text(c):
    P = LISTS[c]
    X, LIM, DEP = P['X'], P['LIM'], P['DEPTH']
    D = dtx_defs()

    def tr(t):
        """dtx's text for this list"""
        t = t.replace('Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_', P['LST'] + '.' + c + '_')
        t = t.replace('Fulu_list_bytelist_1073741824_1048576_d', P['LST'])
        t = t.replace('l1048576_bl1073741824', c).replace('bl1073741824_bx', X + '_bx')
        t = t.replace('RT.MB<RT.WMr>', 'RT.MB<RT.M_%s>' % X).replace('O.Boxed<O.Words>', 'O.Boxed<Fulu%s_d.%s>' % (X, X))
        t = t.replace('1048576', str(LIM)).replace('20n', '%dn' % DEP).replace('hL20', 'hLn').replace('nn20', 'nnL')
        t = t.replace('+es: {SH.ByteList_limit(sE) == U32.to_nat(1073741824) : Nat}', '+es: {sE == Spec.%s() : S.Schema}' % X)
        t = t.replace('+ee: {SH.ByteList_limit(SH.ListOf_element(s)) == U32.to_nat(1073741824) : Nat}', '+ee: {SH.ListOf_element(s) == Spec.%s() : S.Schema}' % X)
        t = t.replace(HWN_SIG, WF_SIG)
        t = re.sub(r'\bhwN\b', WF_ARG, t)
        t = t.replace('TX.SUMN', 'SUMN').replace('TX.TXL', 'LNM')
        t = unwrap_nr(t)
        assert 'TX.' not in t and 'WMr' not in t and 'bl1073741824' not in t, t[:200]
        return t

    out = []
    A_ = out.append
    imps = ['Base', '../src/obj.bend as O', '../src/buffer.bend as B', '../types/schema.bend as S', '../spec/fulu_schemas.bend as Spec',
            '../types/Fulu%s_def_generated.bend as Fulu%s_d' % (X, X), '../types/Fulu_list_%s_%d_def_generated.bend as %s' % (X, LIM, P['LST']),
            '../proofs/compact/found.bend as FD', '../proofs/compact/arith.bend as A', '../proofs/nat_order.bend as Order',
            '../proofs/obj/vbuf.bend as VB', '../proofs/obj/vcopy.bend as VC', '../proofs/obj/vu32.bend as VU', '../proofs/obj/schema_shapes.bend as SH',
            '../proofs/obj/root_types_light.bend as RT', '../proofs/obj/vvl_%s.bend as V' % c, '../proofs/obj/var_winx_%s.bend as YW' % X,
            '../proofs/obj/view_seq.bend as VQ', '../proofs/obj/words_rw.bend as WR', '../proofs/obj/vvlu.bend as VVU', '../proofs/obj/vdepth.bend as VD',
            './e2e_hk_%s.bend as E' % X, './%s as BBA' % P['BB'], './%s as VM' % P['VM'], './%s as VH' % P['VH'], '../%s as W8' % P['ENC'],
            '../proofs/obj/encx_%s_iface.bend as EM' % X, '../proofs/obj/vsum_dummy.bend as VSD']
    imps = [i for i in imps if 'vsum_dummy' not in i]
    for i in imps:
        A_('import ' + i)
    A_('')
    A_('# GENERATED by codegen/e2e_dvl.py from e2e_dtx.bend. Do not edit.')
    A_('# The list a window reads (%s, vvl_%s) satisfies the root laws\' invariant rep_%s and its encoded byte count is the window\'s.' % (c, c, c))
    A_('# The array is am(FT) (e2e_vlm_%s.rvF) for the tree FT the reader\'s writes build; the elements\' facts are the hook module E\'s (e2e_hk_%s).' % (c, X))
    A_('')
    A_('# ---- the elements\' facts at a window ----')
    EEP = '+hEE: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool}'
    SUB = ('Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a)')
    HK = lambda f, extra='': ('E.%s(d, t, %s, V.el_c(t, x, off, len, a, b, hEE), V.eocD(d, x, off, len, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), V.el_ab(t, x, off, len, a, b, hEE), V.el_b(t, x, off, len, a, b, hEE)), eo, hd, hw, hw32), hd, '
                              'V.hwab(d, x, len, a, b, V.el_ab(t, x, off, len, a, b, hEE), V.el_b(t, x, off, len, a, b, hEE), hw), V.hwab32(x, len, a, b, V.el_ab(t, x, off, len, a, b, hEE), V.el_b(t, x, off, len, a, b, hEE), hw32), pfw%s)' % (f, SUB, extra))
    HEAD = '(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, %s, +a: U32, +b: U32, %s' % (WF_SIG, EEP)
    A_('def XE(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32) -> RT.MB<RT.M_%s>: RT.fz_%s_bx(V.OBJE(d, t, x, off, s, e))' % (X, X))
    A_('')
    A_('# the box the reader makes of an element is what freezing and thawing leave')
    A_('def obje_canon%s)\n    -> {RT.th_%s_bx(XE(d, t, x, off, a, b)) == V.OBJE(d, t, x, off, a, b) : O.Boxed<Fulu%s_d.%s>}:\n'
       '  Equal.sym(O.Boxed<Fulu%s_d.%s>, V.OBJE(d, t, x, off, a, b), RT.th_%s_bx(XE(d, t, x, off, a, b)), VM.eqE_%s(d, t, x, off, len, %s, a, b, hEE))'
       % (HEAD, X, X, X, X, X, X, c, WF_ARG))
    A_('')
    A_('# the element\'s own representation invariant')
    A_('def el_rep_th%s, +sE: S.Schema, +es: {sE == Spec.%s() : S.Schema})\n    -> RT.rep_%s_bx(RT.th_%s_bx(XE(d, t, x, off, a, b)), sE):\n  %s'
       % (HEAD, X, X, X, HK('repT', ', sE, es')))
    A_('')
    A_('# the element\'s encoded byte count (as the list\'s encoder sums it): the window of the element')
    A_('def NRa(+m: RT.MB<RT.M_%s>) -> Nat: List.length(&2, U32, W8.YE(BBA.cvE(m)))' % X)
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
       '  VM.FT_%s(k, i, m, d, t, x, off, len, dw, T, v)' % (X, X, X, c))
    A_('')
    for n in ['lt_add_succ', 'lt_i', 'lt_len']:
        A_(tr(D[n]))
        A_('')
    A_('# ---- the array is the array of that tree ----')
    A_('def rv_am(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.M_%s>>, +v: RT.MB<RT.M_%s>,\n'
       '    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}, +pf: {FD.array__perfect(RT.MB<RT.M_%s>, dw, T) == True{} : Bool},\n'
       '    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},\n'
       '    %s, +hE: {V.EV(k, i, m, t, x, off, len, True{}, V.WJ(t, x, i)) == True{} : Bool})\n'
       '    -> {V.RV(k, i, m, d, t, x, off, len, RT.am_%s(T), RT.th_%s_bx(v)) == RT.am_%s(RVT(k, i, m, dw, d, t, x, off, len, T, v)) : Array<O.Boxed<Fulu%s_d.%s>>}:\n'
       '  VM.rvF_%s(k, i, m, d, t, x, off, len, %s, dw, T, v, pf, hdw, hm, inv, hE)'
       % (X, X, X, WF_SIG, c, X, c, X, X, c, WF_ARG))
    A_('')
    A_('# ---- the elements\' representation, over the writes ----')
    for n in ['ereps_after', 'ereps_snoc', 'ereps_step']:
        A_(tr(D[n]))
        A_('')
    for n in ['i1_val', 'cnt0', 'rv_ereps']:
        A_(tr(D[n]).replace('el_rep_th(d, t, x, off, len, %s, s, a, hEE, sE, es)' % WF_ARG, 'el_rep_th(d, t, x, off, len, %s, s, a, hEE, sE, es)' % WF_ARG))
        A_('')
    A_('# ---- the elements\' byte counts add up to the window (the offsets telescope) ----')
    for n in ['sumn_after', 'sumn_snoc', 'NXk', 'him2', 'i2_val', 'nxk']:
        A_(tr(D[n]))
        A_('')
    s = tr(D['sum_step'])
    A_(s)
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
    A_('# ---- the list the reader starts from, and the tree it ends with ----')
    for n in ['fill_am', 'rvt_pf', 'hL20', 'hc_of', 'evb_of', 'hcA', 'hcC', 'hcD', 'quadN', 'nn1', 'nn20', 'dw_lt', 'dw_cov', 'succ_pred', 'inv0', 'nxk0', 'ev_start', 'ee0_of', 'ev0_of']:
        A_(tr(D[n]))
        A_('')
    A_('# ---- the decoded list of a nonempty window ----')
    s = tr(D['arr_eq'])
    s = s.replace('+hchk: {V.CHKw(t, x, off, len) == True{} : Bool})', '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)' % WF_SIG, 1)
    s = s.replace('obje_canon(d, t, x, off, V.W0(t, x), V.B1(t, x, len))', 'obje_canon(d, t, x, off, len, %s, V.W0(t, x), V.B1(t, x, len), ee0_of(t, x, off, len, ec, hchk))' % WF_ARG)
    s = s.replace('inv0(t, x, len, hc))))', 'inv0(t, x, len, hc), %s, ev0_of(t, x, off, len, ec, hchk))))' % WF_ARG)
    A_(s)
    A_('')
    s = tr(D['obj_eq'])
    s = s.replace('+hchk: {V.CHKw(t, x, off, len) == True{} : Bool})', '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)' % WF_SIG, 1)
    s = s.replace('arr_eq(d, t, x, off, len, ec, hchk', 'arr_eq(d, t, x, off, len, ec, hchk, %s' % WF_ARG)
    A_(s)
    A_('')
    A_(tr(D['nn_lim']))
    A_('')
    A_('# ---- the list\'s representation invariant ----')
    s = tr(D['rep_c'])
    s = s.replace('obj_eq(d, t, x, off, len, ec, hchk)', 'obj_eq(d, t, x, off, len, ec, hchk, %s)' % WF_ARG)
    s = s.replace('inv0(t, x, len, hc), eo,', 'inv0(t, x, len, hc), eo,')
    A_(s)
    A_('')
    A_(tr(D['rep']))
    A_('')
    A_('# ---- the encode premise: e2e_vhl8.vh ----')
    A_('def sdl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)\n    -> BBA.sd8(V.OBJw(d, t, x, off, len)):\n  VH.vh(d, t, x, off, len, eo, hd, hw, hw32, pfw, hchk)' % WF_SIG)
    A_('')
    A_('# ---- the list\'s encoded byte count: four per element and the element bytes, which tile the window ----')
    A_('def blsum(k: Nat, +W: List<&2, RT.MB<RT.M_%s>>, +i: Nat) -> {W8.BL(k, BBA.LM(W), i) == SUMN(k, W, i) : Nat}:\n'
       '  match k:\n    case 0n: {==}\n    case 1n+ +q:\n'
       '      Equal.trans(Nat, W8.BL(1n+q, BBA.LM(W), i), Nat.add(List.length(&2, U32, W8.YE(W8.xat_%s(BBA.LM(W), i))), W8.BL(q, BBA.LM(W), 1n+i)), SUMN(1n+q, W, i), W8.bl_cons(q, BBA.LM(W), i),\n'
       '        Equal.trans(Nat, Nat.add(List.length(&2, U32, W8.YE(W8.xat_%s(BBA.LM(W), i))), W8.BL(q, BBA.LM(W), 1n+i)), Nat.add(NRa(RT.xat_%s(W, i)), W8.BL(q, BBA.LM(W), 1n+i)), SUMN(1n+q, W, i),\n'
       '          Equal.cong(W8.MB<EM.MW>, Nat, z => Nat.add(List.length(&2, U32, W8.YE(z)), W8.BL(q, BBA.LM(W), 1n+i)), W8.xat_%s(BBA.LM(W), i), BBA.cvE(RT.xat_%s(W, i)), BBA.xatlm(W, i)),\n'
       '          Equal.cong(Nat, Nat, z => Nat.add(NRa(RT.xat_%s(W, i)), z), W8.BL(q, BBA.LM(W), 1n+i), SUMN(q, W, 1n+i), blsum(q, W, 1n+i))))'
       % (X, c, c, c, c, c, c))
    A_('')
    A_('def lnT(+T: FD.array__Tree<RT.MB<RT.M_%s>>, +n: U32) -> {W8.LL(BBA.CV(T), n) == Nat.add(A.quad(U32.to_nat(n)), SUMN(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_%s>, T), 0n)) : Nat}:\n'
       '  %%Equal.sym(List<&2, W8.MB<EM.MW>>, FD.array__slots(W8.MB<EM.MW>, BBA.CV(T)), BBA.LM(FD.array__slots(RT.MB<RT.M_%s>, T)), BBA.slcv(T)) :\n'
       '    {Nat.add(A.quad(U32.to_nat(n)), W8.BL(U32.to_nat(n), _, 0n)) == Nat.add(A.quad(U32.to_nat(n)), SUMN(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_%s>, T), 0n)) : Nat}\n'
       '  Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(n)), z), W8.BL(U32.to_nat(n), BBA.LM(FD.array__slots(RT.MB<RT.M_%s>, T)), 0n), SUMN(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_%s>, T), 0n),\n'
       '    blsum(U32.to_nat(n), FD.array__slots(RT.MB<RT.M_%s>, T), 0n))' % ((X,) * 7))
    A_('')
    s = tr(D['txl_c'])
    s = s.replace('def txl_c', 'def szl_c').replace('{LNM(', '{BBA.%s(' % P['LN'])
    s = s.replace('obj_eq(d, t, x, off, len, ec, hchk)', 'obj_eq(d, t, x, off, len, ec, hchk, %s)' % WF_ARG)
    a2 = 'inv0(t, x, len, hc), ee0_of('
    assert s.count(a2) == 1, s.count(a2)
    s = s.replace(a2, 'inv0(t, x, len, hc), %s, ee0_of(' % WF_ARG)
    # the goal on the tree: the list's encoder length
    a3 = 'FD.logic__subst(FD.array__Tree<RT.MB<RT.M_%s>>, z => {Nat.add(A.quad(U32.to_nat(V.NN(t, x))), SUMN(U32.to_nat(V.NN(t, x)), FD.array__slots(RT.MB<RT.M_%s>, z), 0n)) == U32.to_nat(len) : Nat},\n        ' % (X, X)
    assert a3 in s
    k = s.index(a3) + len(a3)
    R = s[k:close_paren(s, s.index('(', k)) + 1]
    assert R.startswith('RVT(')
    s = s.replace(a3, 'FD.logic__subst(FD.array__Tree<RT.MB<RT.M_%s>>, z => {W8.LL(BBA.CV(z), V.NN(t, x)) == U32.to_nat(len) : Nat},\n        ' % X)
    r = s.index('rv_sum(')
    rc = close_paren(s, r + len('rv_sum'))
    rs = s[r:rc + 1]
    s = s[:r] + ('Equal.trans(Nat, W8.LL(BBA.CV(%s), V.NN(t, x)), Nat.add(A.quad(U32.to_nat(V.NN(t, x))), SUMN(U32.to_nat(V.NN(t, x)), FD.array__slots(RT.MB<RT.M_%s>, %s), 0n)), U32.to_nat(len), lnT(%s, V.NN(t, x)),\n          %s)' % (R, X, R, R, rs)) + s[rc + 1:]
    A_(s)
    A_('')
    A_('def szl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, %s)\n'
       '    -> {BBA.%s(V.OBJw(d, t, x, off, len)) == U32.to_nat(len) : Nat}:\n'
       '  szl_c(U32.is_eq(len, 0), d, t, x, off, len, {==}, %s, hchk)' % (WF_SIG, P['LN'], WF_ARG))
    return '\n'.join(out) + '\n'


def main():
    outs = {E2E / ('e2e_dvl_%s.bend' % c): text(c) for c in LISTS}
    check = '--check' in sys.argv
    stale = [p.name for p, t in outs.items() if not p.exists() or p.read_text() != t]
    if check:
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('e2e_dvl: up to date')
        return
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print('e2e_dvl: %d files' % len(outs))


if __name__ == '__main__':
    main()
