#!/usr/bin/env python3
"""e2e/e2e_dbl_<list>.bend: the decoded list of a boxed fixed-size record list (a list of at most LIM records of SZ bytes, stored as an
array of boxes: l16_ProposerSlashing, l16_Deposit) satisfies the encode premise and the root laws' invariant of a block body that holds it.

The reader (proofs/obj/var_winx_<list>.bend: RT) writes record j (RX(t, pos(j, SZ, x)), its words read at a byte position) into the array at index i,
for j = 0 .. N - 1. The array is am(T) for the tree T the same writes build (RTT: rt_am, with root_types_light.bend's amset: the Array.set of the box
th(v) is the tree updated with v), every element is a record whose words are the window's (rx_rep: the proof term of the fixed-size composed theorem's
pe_rep, with the words of the record in place of those of the input; a record's vector of chunks is a copy of the window, perfect by e2e_dfx.bend),
and the window holds N = len / SZ records:

    sdl(d, t, x, off, len, hchk)                  the encode premise (the tree below depth 31; each element's storage premise)
    rep(d, t, x, off, len, s, es, ee, hchk)       the root laws' rep_<list>(OBJw, s)
    szl(d, t, x, off, len, hchk)                  the list's encoded byte count is the window's

The lemmas over the elements (ereps_after / ereps_snoc / ereps_step) are e2e_dtx.bend's, renamed (the storage premise's are the same with
the element predicate ML.SDE).

Usage: python3 codegen/proofs/decoded/boxed_record_list_decoded_facts.py [--check]"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core.repository_paths import ROOT, E2E  # noqa: E402
from codegen.core.text_scanning_helpers import close_paren  # noqa: E402

LISTS = {
    'l16_ProposerSlashing': dict(X='ProposerSlashing', Wf='proofs/obj/var_winx_l16_ProposerSlashing.bend', ML='e2e_ml_l16_ProposerSlashing.bend',
                                 comp='FuluProposerSlashing_e2e_comp_generated.bend', SZ=416, WORDS=104, LIM=16, KB=4, ELEM='Spec.ProposerSlashing()',
                                 LST='Fulu_list_ProposerSlashing_16_d', D=False, SDEX=False),
    'l16_Deposit': dict(X='Deposit', Wf='proofs/obj/var_winx_l16_Deposit.bend', ML='e2e_ml_l16_Deposit.bend',
                        comp='FuluDeposit_e2e_comp_generated.bend', SZ=1240, WORDS=310, LIM=16, KB=4, ELEM='Spec.Deposit()',
                        LST='Fulu_list_Deposit_16_d', D=True, SDEX=True),
}

DTX = (E2E / 'e2e_dtx.bend').read_text()


def dtx_def(name):
    """the text of a def of e2e_dtx.bend (up to the next blank line)"""
    m = re.search(r'^def %s\(.*?(?=\n\n)' % re.escape(name), DTX, re.M | re.S)
    return m.group(0)


def rename(t, c, X):
    return t.replace('l1048576_bl1073741824', c).replace('bl1073741824_bx', X + '_bx').replace('RT.MB<RT.WMr>', 'RT.MB<RT.M_%s>' % X)


def to_sde(t, c, X):
    """the element-storage version of ereps_after / ereps_snoc / ereps_step: the element predicate is ML.SDE of the mirror, the list's SDKS"""
    pat = 'RT.rep_%s_bx(RT.th_%s_bx(' % (X, X)
    while True:
        i = t.find(pat)
        if i < 0:
            break
        j = i + len(pat) - 1
        k = close_paren(t, j)
        assert t[k + 1:k + 6] == ', sE)', t[k:k + 20]
        t = t[:i] + 'ML.SDE(' + t[j + 1:k] + ')' + t[k + 6:]
    t = re.sub(r'RT\.ereps_%s\(([^;]*?), (0n|i0|1n\+i0), sE\)' % re.escape(c), lambda m: 'ML.SDKS(%s, %s)' % (m.group(1), m.group(2)), t)
    t = t.replace(' +sE: S.Schema,', '').replace(', sE)', ')').replace(', sE,', ',').replace(' sE,', '')
    return t.replace('ereps_', 'sdks_')


INV_NX = '''def inv_nx(+p: Nat, +i: U32, +m: U32, +inv: {Nat.add(U32.to_nat(i), 2n+p) == U32.to_nat(m) : Nat})
    -> {Nat.add(U32.to_nat(U32.add(i, 1)), 1n+p) == U32.to_nat(m) : Nat}:
  +him = FD.logic__subst(Nat, z => {Nat.is_le(1n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n+p), U32.to_nat(m), inv,
    FD.logic__subst(Nat, z => {Nat.is_le(1n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n+p, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n+p), FD.nat__add_comm(2n+p, U32.to_nat(i)),
      A.le_skip(1n+p, U32.to_nat(i))))
  +e1 = VVU.addk(i, 1, m, him)
  Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 1n+p), Nat.add(1n+U32.to_nat(i), 1n+p), U32.to_nat(m),
    Equal.cong(Nat, Nat, z => Nat.add(z, 1n+p), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
    Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 1n+p), Nat.add(U32.to_nat(i), 2n+p), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 2n+p), 1n+Nat.add(U32.to_nat(i), 1n+p), FD.nat__add_succ(U32.to_nat(i), 1n+p)), inv))
'''

CTN = 'VXB.CTN(d, t, y, 1056, 9n)'
FTCTN = 'FD.array__freeze(U32, FD.array__thaw(U32, %s))' % CTN
# the proof vector of a deposit: a copy of the window, perfect (e2e_dfx.bend's ctn_pf); its storage and its chunk count
WFV = ('(%s, (9n, (1056, (32n, ({==}, (FD.logic__subst(FD.array__Tree<U32>, z => {FD.array__perfect(U32, 9n, z) == True{} : Bool}, %s, %s, '
       'Equal.sym(FD.array__Tree<U32>, %s, %s, FD.array__freeze_thaw(U32, %s)), DFX.ctn_pf(d, t, y, 1056, 9n)), '
       '({==}, (FD.nat__eq_from_is_eq(U32.to_nat(1056), Nat.add(WS.e32(32n), 32n), {==}), {==}))))))))' % (FTCTN, CTN, FTCTN, FTCTN, CTN, CTN))


def text(c):
    S = LISTS[c]
    X, SZ, LIM, KB, LST, ELEM, D, SDEX = S['X'], S['SZ'], S['LIM'], S['KB'], S['LST'], S['ELEM'], S['D'], S['SDEX']
    MB = 'RT.MB<RT.M_%s>' % X
    BX = 'O.Boxed<Fulu%s_d.%s>' % (X, X)
    ARR = 'Array<%s>' % BX
    comp = (E2E / S['comp']).read_text()
    wtext = (ROOT / S['Wf']).read_text()
    rx = re.search(r'^def RX\(.*?: (.*)$', wtext, re.M).group(1)
    words = re.findall(r'UR\.RWN\(t, [^()]*\)', rx)
    term = re.search(r'^def pe_rep\(\+bs: \+List<U32>\) -> .*?:\n  (.*)$', comp, re.M).group(1)
    if D:
        # the record: the proof words (a copy of the window) and the data's words (the last ones)
        i = term.index(', (FuluDepositData_d.DepositData{')
        tail = term[i + 2:]
        nth = re.findall(r'FD\.flat__nthc\(L\.wlp\(bs\), (\d+)n\)', tail)
        assert len(words) == len(nth) == 46, (len(words), len(nth))
        tail = re.sub(r'FD\.flat__nthc\(L\.wlp\(bs\), (\d+)n\)', lambda m: words[int(m.group(1)) - 264], tail)
        term = '({==}, ({==}, ((%s, {==}), %s)' % (WFV, tail)
    else:
        assert len(words) == S['WORDS'], (len(words), S['WORDS'])
        term = '({==}, %s)' % re.sub(r'FD\.flat__nthc\(L\.wlp\(bs\), (\d+)n\)', lambda m: words[int(m.group(1))], term)
    RXC = (lambda y: 'W.RX(d, t, %s)' % y) if D else (lambda y: 'W.RX(t, %s)' % y)
    RTC = (lambda k, i, j, a: 'W.RT(d, %s, %s, %s, %s, t, x)' % (k, i, j, a)) if D else (lambda k, i, j, a: 'W.RT(%s, %s, %s, %s, t, x)' % (k, i, j, a))
    LOB = (lambda e: 'W.LOBJ(d, %s, t, x, len)' % e) if D else (lambda e: 'W.LOBJ(%s, t, x, len)' % e)
    imps = ['import Base', 'import ../src/obj.bend as O', 'import ../src/buffer.bend as B', 'import ../types/schema.bend as S', 'import ../spec/fulu_schemas.bend as Spec',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vdepth.bend as VD',
            'import ../proofs/obj/vrl.bend as VRL', 'import ../proofs/obj/vvlu.bend as VVU', 'import ../proofs/obj/schema_shapes.bend as SH',
            'import ../proofs/obj/root_types_light.bend as RT', 'import ../%s as W' % S['Wf'], 'import ./%s as ML' % S['ML'],
            'import ../proofs/obj/view_seq.bend as VQ', 'import ../proofs/obj/words_rw.bend as WR', 'import ../proofs/obj/vua_rd.bend as UR',
            'import ../proofs/obj/vu32.bend as VU', 'import ../types/%s_def_generated.bend as %s' % (LST[:-2], LST)]
    if D:
        imps += ['import ../proofs/obj/vua_fixb.bend as VXB', 'import ./e2e_dfx.bend as DFX', 'import ../proofs/obj/words_spec.bend as WS', 'import ./e2e_blist.bend as BL']
    for m in re.finditer(r'^import (\S+) as (Fulu\w*_d)$', comp, re.M):
        imps.append('import %s as %s' % (m.group(1), m.group(2)))
    out = ['\n'.join(dict.fromkeys(imps)), '', '# GENERATED by boxed_record_list_decoded_facts (codegen). Do not edit.',
           "# The decoded %s (proofs/obj/var_winx_%s.bend): its encode premise, the root laws' invariant and its byte count. See codegen/proofs/decoded/boxed_record_list_decoded_facts.py." % (c, c), '']
    ren = lambda t: rename(t, c, X)
    out.append('def XE(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat) -> %s: RT.fz_%s_bx(%s)\n' % (MB, X, RXC('y')))
    out.append("# the record at y: the proof term of the fixed-size composed theorem (pe_rep), with the record's words\n"
               "def rx_rep(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat) -> RT.rep_%s_bx(RT.th_%s_bx(XE(d, t, y)), %s):\n  %s\n" % (X, X, ELEM, term))
    if D:
        canon = (f'FD.logic__subst(FD.array__Tree<U32>, z => {{O.BSome{{Fulu{X}_d.{X}{{O.Words{{FD.array__thaw(U32, z), 1056}}, RT.pj_Deposit_1(RT.pjb_Deposit_bx(W.RX(d, t, y)))}}, O.BNone{{}}}} == W.RX(d, t, y) : {BX}}}, '
                 f'{CTN}, {FTCTN}, Equal.sym(FD.array__Tree<U32>, {FTCTN}, {CTN}, FD.array__freeze_thaw(U32, {CTN})), {{==}})')
    else:
        canon = '{==}'
    out.append(f'# freezing and thawing the record is the record\ndef rx_canon(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat) -> {{RT.th_{X}_bx(XE(d, t, y)) == {RXC("y")} : {BX}}}:\n  {canon}\n')
    out.append(dtx_def('lt_add_succ') + '\n')
    trio = [ren(dtx_def(n)) for n in ('lt_i', 'lt_len', 'ereps_after', 'ereps_snoc', 'ereps_step', 'cnt0')]
    out += [t + '\n' for t in trio]
    out.append(INV_NX)
    out.append(dtx_def('i1_val') + '\n')
    UPDX = lambda T, i, j: 'FD.array__upd(%s, dw, %s, %s, XE(d, t, VRL.pos(%s, %dn, x)))' % (MB, T, i, j, SZ)
    XEJ = 'XE(d, t, VRL.pos(j, %dn, x))' % SZ
    out.append(f'''def RTT(+k: Nat, +i: U32, +j: Nat, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +T: FD.array__Tree<{MB}>) -> FD.array__Tree<{MB}>:
  match k:
    case 0n: {UPDX('T', 'U32.to_nat(i)', 'j')}
    case 1n+q: RTT(q, U32.add(i, 1), 1n+j, dw, d, t, x, {UPDX('T', 'U32.to_nat(i)', 'j')})

# the array the reader writes is the array of the tree its writes build
def rt_am(+k: Nat, +i: U32, +m: U32, +j: Nat, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +T: FD.array__Tree<{MB}>,
    +hdw: {{Nat.is_lt(dw, 32n) == True{{}} : Bool}}, +pf: {{FD.array__perfect({MB}, dw, T) == True{{}} : Bool}},
    +hm: {{Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +inv: {{Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat}})
    -> {{{RTC('k', 'i', 'j', f'RT.am_{c}(T)')} == RT.am_{c}(RTT(k, i, j, dw, d, t, x, T)) : {ARR}}}:
  match k:
    case 0n:
      %Equal.sym({BX}, {RXC('VRL.pos(j, %dn, x)' % SZ)}, RT.th_{X}_bx({XEJ}), Equal.sym({BX}, RT.th_{X}_bx({XEJ}), {RXC('VRL.pos(j, %dn, x)' % SZ)}, rx_canon(d, t, VRL.pos(j, {SZ}n, x)))) :
        {{Array.set({BX}, RT.am_{c}(T), i, _) == RT.am_{c}(RTT(0n, i, j, dw, d, t, x, T)) : {ARR}}}
      RT.amset_{c}(dw, T, i, {XEJ}, RT.xat_{c}(FD.array__slots({MB}, T), U32.to_nat(i)), hdw, lt_i(i, 0n, m, dw, hm, inv),
        RT.nth_{c}(FD.array__slots({MB}, T), U32.to_nat(i), lt_len(i, 0n, m, dw, T, pf, hm, inv)), pf)
    case 1n+q:
      %Equal.sym({BX}, {RXC('VRL.pos(j, %dn, x)' % SZ)}, RT.th_{X}_bx({XEJ}), Equal.sym({BX}, RT.th_{X}_bx({XEJ}), {RXC('VRL.pos(j, %dn, x)' % SZ)}, rx_canon(d, t, VRL.pos(j, {SZ}n, x)))) :
        {{{RTC('q', 'U32.add(i, 1)', '1n+j', 'Array.set(%s, RT.am_%s(T), i, _)' % (BX, c))} == RT.am_{c}(RTT(1n+q, i, j, dw, d, t, x, T)) : {ARR}}}
      %Equal.sym({ARR}, Array.set({BX}, RT.am_{c}(T), i, RT.th_{X}_bx({XEJ})), RT.am_{c}({UPDX('T', 'U32.to_nat(i)', 'j')}),
          RT.amset_{c}(dw, T, i, {XEJ}, RT.xat_{c}(FD.array__slots({MB}, T), U32.to_nat(i)), hdw, lt_i(i, 1n+q, m, dw, hm, inv),
            RT.nth_{c}(FD.array__slots({MB}, T), U32.to_nat(i), lt_len(i, 1n+q, m, dw, T, pf, hm, inv)), pf)) :
        {{{RTC('q', 'U32.add(i, 1)', '1n+j', '_')} == RT.am_{c}(RTT(1n+q, i, j, dw, d, t, x, T)) : {ARR}}}
      rt_am(q, U32.add(i, 1), m, 1n+j, dw, d, t, x, {UPDX('T', 'U32.to_nat(i)', 'j')}, hdw,
        FD.array__upd_perfect({MB}, dw, T, U32.to_nat(i), {XEJ}, pf), hm, inv_nx(q, i, m, inv))
''')
    out.append(f"""def rxs(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +sE: S.Schema, +hs: {{sE == {ELEM} : S.Schema}}) -> RT.rep_{X}_bx(RT.th_{X}_bx(XE(d, t, y)), sE):
  FD.logic__subst(S.Schema, z => RT.rep_{X}_bx(RT.th_{X}_bx(XE(d, t, y)), z), {ELEM}, sE, Equal.sym(S.Schema, sE, {ELEM}, hs), rx_rep(d, t, y))

def rt_ereps(+k: Nat, +i: U32, +m: U32, +j: Nat, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +T: FD.array__Tree<{MB}>,
    +hdw: {{Nat.is_lt(dw, 32n) == True{{}} : Bool}}, +pf: {{FD.array__perfect({MB}, dw, T) == True{{}} : Bool}},
    +hm: {{Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +inv: {{Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat}}, +sE: S.Schema, +hs: {{sE == {ELEM} : S.Schema}},
    +pre: RT.ereps_{c}(U32.to_nat(i), FD.array__slots({MB}, T), 0n, sE))
    -> RT.ereps_{c}(U32.to_nat(m), FD.array__slots({MB}, RTT(k, i, j, dw, d, t, x, T)), 0n, sE):
  match k:
    case 0n:
      FD.logic__subst(Nat, z => RT.ereps_{c}(z, FD.array__slots({MB}, {UPDX('T', 'U32.to_nat(i)', 'j')}), 0n, sE), 1n+U32.to_nat(i), U32.to_nat(m), cnt0(U32.to_nat(i), U32.to_nat(m), inv),
        ereps_step(U32.to_nat(i), dw, T, {XEJ}, sE, pf, lt_i(i, 0n, m, dw, hm, inv), pre, rxs(d, t, VRL.pos(j, {SZ}n, x), sE, hs)))
    case 1n+q:
      rt_ereps(q, U32.add(i, 1), m, 1n+j, dw, d, t, x, {UPDX('T', 'U32.to_nat(i)', 'j')}, hdw, FD.array__upd_perfect({MB}, dw, T, U32.to_nat(i), {XEJ}, pf), hm, inv_nx(q, i, m, inv), sE, hs,
        FD.logic__subst(Nat, z => RT.ereps_{c}(z, FD.array__slots({MB}, {UPDX('T', 'U32.to_nat(i)', 'j')}), 0n, sE), 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)),
          Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), i1_val(q, i, m, inv)),
          ereps_step(U32.to_nat(i), dw, T, {XEJ}, sE, pf, lt_i(i, 1n+q, m, dw, hm, inv), pre, rxs(d, t, VRL.pos(j, {SZ}n, x), sE, hs))))

def rtt_pf(+k: Nat, +i: U32, +j: Nat, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +T: FD.array__Tree<{MB}>, +pf: {{FD.array__perfect({MB}, dw, T) == True{{}} : Bool}})
    -> {{FD.array__perfect({MB}, dw, RTT(k, i, j, dw, d, t, x, T)) == True{{}} : Bool}}:
  match k:
    case 0n: FD.array__upd_perfect({MB}, dw, T, U32.to_nat(i), {XEJ}, pf)
    case 1n+q: rtt_pf(q, U32.add(i, 1), 1n+j, dw, d, t, x, {UPDX('T', 'U32.to_nat(i)', 'j')}, FD.array__upd_perfect({MB}, dw, T, U32.to_nat(i), {XEJ}, pf))

""")
    if SDEX:
        out += [to_sde(t, c, X) + '\n' for t in trio[2:5]]     # ereps_after, ereps_snoc, ereps_step
        out.append(f"""# the element's storage premise: the proof vector is a copy of the window
def sdE(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat) -> ML.SDE(XE(d, t, y)):
  {WFV}

def rt_sdks(+k: Nat, +i: U32, +m: U32, +j: Nat, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +T: FD.array__Tree<{MB}>,
    +hdw: {{Nat.is_lt(dw, 32n) == True{{}} : Bool}}, +pf: {{FD.array__perfect({MB}, dw, T) == True{{}} : Bool}},
    +hm: {{Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +inv: {{Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat}},
    +pre: ML.SDKS(U32.to_nat(i), FD.array__slots({MB}, T), 0n))
    -> ML.SDKS(U32.to_nat(m), FD.array__slots({MB}, RTT(k, i, j, dw, d, t, x, T)), 0n):
  match k:
    case 0n:
      FD.logic__subst(Nat, z => ML.SDKS(z, FD.array__slots({MB}, {UPDX('T', 'U32.to_nat(i)', 'j')}), 0n), 1n+U32.to_nat(i), U32.to_nat(m), cnt0(U32.to_nat(i), U32.to_nat(m), inv),
        sdks_step(U32.to_nat(i), dw, T, {XEJ}, pf, lt_i(i, 0n, m, dw, hm, inv), pre, sdE(d, t, VRL.pos(j, {SZ}n, x))))
    case 1n+q:
      rt_sdks(q, U32.add(i, 1), m, 1n+j, dw, d, t, x, {UPDX('T', 'U32.to_nat(i)', 'j')}, hdw, FD.array__upd_perfect({MB}, dw, T, U32.to_nat(i), {XEJ}, pf), hm, inv_nx(q, i, m, inv),
        FD.logic__subst(Nat, z => ML.SDKS(z, FD.array__slots({MB}, {UPDX('T', 'U32.to_nat(i)', 'j')}), 0n), 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)),
          Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), i1_val(q, i, m, inv)),
          sdks_step(U32.to_nat(i), dw, T, {XEJ}, pf, lt_i(i, 1n+q, m, dw, hm, inv), pre, sdE(d, t, VRL.pos(j, {SZ}n, x)))))
""")
    else:
        out.append(f"""# the elements' storage premise is trivial
def sdks_triv(+k: Nat, +W: List<&2, {MB}>, +i: Nat) -> ML.SDKS(k, W, i):
  match k:
    case 0n: {{==}}
    case 1n+q: ({{==}}, sdks_triv(q, W, 1n+i))
""")
    fa = dtx_def('fill_am').replace('Fulu_list_bytelist_1073741824_1048576_d', LST).replace('O.Boxed<O.Words>', BX)
    out.append(ren(fa) + '\n')
    out.append(dtx_def('succ_pred') + '\n')
    HCK = '+hchk: {W.CHKw(t, x, off, len) == True{} : Bool}'
    TXN = '+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'
    NNe, CCe = 'W.NN(len)', 'W.CC(len)'
    DW = f'B.words_depth({NNe})'
    K0 = f'U32.to_nat(U32.sub({NNe}, 1))'
    T0 = f'FD.array__trep({MB}, {DW}, RT.MNone{{}})'
    TF = f'RTT({K0}, 0, 0n, {DW}, d, t, x, {T0})'
    PF0 = f'FD.array__trep_perfect({MB}, {DW}, RT.MNone{{}})'
    HCW = 'W.hcw(len, hchk)'
    EMPT = f'FD.array__trep({MB}, 0n, RT.MNone{{}})'
    EC = '+ec: {U32.is_eq(len, 0) == c : Bool}'
    D32 = f'FD.nat__lt_trans({DW}, 31n, 32n, dw_lt(t, x, off, len, hchk), {{==}})'
    SDKSLAST = ('rt_sdks(%s, 0, %s, 0n, %s, d, t, x, %s, %s, %s, dw_cov(t, x, off, len, hchk), inv0(t, x, off, len, ec, hchk), {==})' % (K0, NNe, DW, T0, D32, PF0)
                if SDEX else 'sdks_triv(%s, FD.array__slots(%s, %s), 0n)' % (CCe, MB, TF))
    out.append(f"""# ---- what the window's check says ----
def hL() -> {{Nat.is_le(U32.to_nat({LIM}), O.pow2n({KB}n)) == True{{}} : Bool}}:
  {{==}}

def h2k(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {HCK}) -> {{Nat.is_le({CCe}, O.pow2n({KB}n)) == True{{}} : Bool}}:
  FD.nat__le_trans({CCe}, U32.to_nat({LIM}), O.pow2n({KB}n), {HCW}, hL())

def dw_lt(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {HCK}) -> {{Nat.is_lt({DW}, 31n) == True{{}} : Bool}}:
  FD.nat__le_lt_trans({DW}, {KB}n, 31n, VD.wd_min({NNe}, {KB}n, h2k(t, x, off, len, hchk)), {{==}})

def dw_cov(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {HCK}) -> {{Nat.is_le({CCe}, FD.spec_common__pow2({DW})) == True{{}} : Bool}}:
  FD.logic__subst(Nat, z => {{Nat.is_le({CCe}, z) == True{{}} : Bool}}, O.pow2n({DW}), FD.spec_common__pow2({DW}),
    Equal.sym(Nat, FD.spec_common__pow2({DW}), O.pow2n({DW}), VD.s_pow2_eq({DW})), VD.wd_cover({NNe}, {KB}n, {{==}}, h2k(t, x, off, len, hchk)))

def inv0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {HCK})
    -> {{Nat.add(U32.to_nat(0), 1n+{K0}) == {CCe} : Nat}}:
  +h1 = W.cpos(len, {CCe}, W.ecw(len, hchk), ec)
  Equal.trans(Nat, 1n+{K0}, 1n+Nat.sub({CCe}, 1n), {CCe},
    Equal.cong(Nat, Nat, z => 1n+z, {K0}, Nat.sub({CCe}, 1n), FD.u32__sub_nat({NNe}, 1, h1)), succ_pred({CCe}, h1))

# ---- the decoded list of a nonempty window ----
def arr_eq(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {HCK})
    -> {{{RTC(K0, '0', '0n', f'{LST}.{c}_fill({LST}.{c}_cap({NNe}))')} == RT.am_{c}({TF}) : {ARR}}}:
  FD.logic__subst({ARR}, z => {{{RTC(K0, '0', '0n', 'z')} == RT.am_{c}({TF}) : {ARR}}}, RT.am_{c}({T0}), {LST}.{c}_fill({LST}.{c}_cap({NNe})),
    Equal.sym({ARR}, {LST}.{c}_fill({LST}.{c}_cap({NNe})), RT.am_{c}({T0}), fill_am({DW})),
    rt_am({K0}, 0, {NNe}, 0n, {DW}, d, t, x, {T0}, FD.nat__lt_trans({DW}, 31n, 32n, dw_lt(t, x, off, len, hchk), {{==}}), {PF0}, dw_cov(t, x, off, len, hchk), inv0(t, x, off, len, ec, hchk)))

def obj_eq(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {HCK})
    -> {{{LOB('False{}')} == {LST}.{c}_Seq{{RT.am_{c}({TF}), {NNe}}} : {LST}.{c}_Seq}}:
  Equal.cong({ARR}, {LST}.{c}_Seq, a => {LST}.{c}_Seq{{a, {NNe}}}, {RTC(K0, '0', '0n', f'{LST}.{c}_fill({LST}.{c}_cap({NNe}))')}, RT.am_{c}({TF}), arr_eq(d, t, x, off, len, ec, hchk))

# ---- the list's representation invariant ----
def rep_c(+c: Bool, +d: Nat, {TXN}, {EC}, {HCK}, +s: S.Schema, +es: {{SH.ListOf_limit(s) == U32.to_nat({LIM}) : Nat}},
    +ee: {{SH.ListOf_element(s) == {ELEM} : S.Schema}})
    -> RT.rep_{c}({LOB('c')}, s):
  match c:
    case True{{}}: (({EMPT}, (0n, (0, ({{==}}, ({{==}}, ({{==}}, ({{==}}, {{==}}))))))), FD.nat__zero_le(SH.ListOf_limit(s)))
    case False{{}}:
      ((({TF}), ({DW}, ({NNe}, (obj_eq(d, t, x, off, len, ec, hchk), (rtt_pf({K0}, 0, 0n, {DW}, d, t, x, {T0}, {PF0}),
          ({D32}, (dw_cov(t, x, off, len, hchk),
            rt_ereps({K0}, 0, {NNe}, 0n, {DW}, d, t, x, {T0}, {D32}, {PF0}, dw_cov(t, x, off, len, hchk), inv0(t, x, off, len, ec, hchk), SH.ListOf_element(s), ee, {{==}})))))))),
          FD.logic__subst(Nat, z => {{Nat.is_le({CCe}, z) == True{{}} : Bool}}, U32.to_nat({LIM}), SH.ListOf_limit(s), Equal.sym(Nat, SH.ListOf_limit(s), U32.to_nat({LIM}), es), {HCW}))

def rep(+d: Nat, {TXN}, +s: S.Schema, +es: {{SH.ListOf_limit(s) == U32.to_nat({LIM}) : Nat}}, +ee: {{SH.ListOf_element(s) == {ELEM} : S.Schema}}, {HCK})
    -> RT.rep_{c}(W.OBJw(d, t, x, off, len), s):
  rep_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, hchk, s, es, ee)

# ---- the encode premise ----
def sdl_c(+c: Bool, +d: Nat, {TXN}, {EC}, {HCK}) -> ML.sdt({LOB('c')}):
  match c:
    case True{{}}: ({EMPT}, (0n, (0, ({{==}}, ({{==}}, ({{==}}, ({{==}}, {{==}})))))))
    case False{{}}:
      ({TF}, ({DW}, ({NNe}, (obj_eq(d, t, x, off, len, ec, hchk), (rtt_pf({K0}, 0, 0n, {DW}, d, t, x, {T0}, {PF0}),
        (dw_lt(t, x, off, len, hchk), (dw_cov(t, x, off, len, hchk), {SDKSLAST})))))))

def sdl(+d: Nat, {TXN}, {HCK}) -> ML.sdt(W.OBJw(d, t, x, off, len)):
  sdl_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, hchk)

# ---- the encoded byte count: the records are {SZ} bytes, {S['WORDS']} words, each ----
def qadd(+a: Nat, +b: Nat) -> {{A.quad(Nat.add(a, b)) == Nat.add(A.quad(a), A.quad(b)) : Nat}}:
  Equal.trans(Nat, A.quad(Nat.add(a, b)), Nat.double(Nat.add(Nat.double(a), Nat.double(b))), Nat.add(A.quad(a), A.quad(b)),
    Equal.cong(Nat, Nat, z => Nat.double(z), Nat.double(Nat.add(a, b)), Nat.add(Nat.double(a), Nat.double(b)), Equal.sym(Nat, Nat.add(Nat.double(a), Nat.double(b)), Nat.double(Nat.add(a, b)), FD.nat__add_double(a, b))),
    Equal.sym(Nat, Nat.add(A.quad(a), A.quad(b)), Nat.double(Nat.add(Nat.double(a), Nat.double(b))), FD.nat__add_double(Nat.double(a), Nat.double(b))))

def qm(+c: Nat) -> {{A.quad(Nat.mul(c, {S['WORDS']}n)) == Nat.mul(c, {SZ}n) : Nat}}:
  match c:
    case 0n: {{==}}
    case 1n+q:
      Equal.trans(Nat, A.quad(Nat.mul(1n+q, {S['WORDS']}n)), Nat.add(A.quad({S['WORDS']}n), A.quad(Nat.mul(q, {S['WORDS']}n))), Nat.mul(1n+q, {SZ}n), qadd({S['WORDS']}n, Nat.mul(q, {S['WORDS']}n)),
        Equal.cong(Nat, Nat, z => Nat.add(A.quad({S['WORDS']}n), z), A.quad(Nat.mul(q, {S['WORDS']}n)), Nat.mul(q, {SZ}n), qm(q)))

def szl_c(+c: Bool, +d: Nat, {TXN}, {EC}, {HCK}) -> {{ML.LLX({LOB('c')}) == U32.to_nat(len) : Nat}}:
  match c:
    case True{{}}: Equal.sym(Nat, U32.to_nat(len), 0n, Equal.cong(U32, Nat, z => U32.to_nat(z), len, 0, FD.u32alg__eq_of(len, 0, ec)))
    case False{{}}: Equal.trans(Nat, ML.LLX({LOB('False{}')}), Nat.mul({CCe}, {SZ}n), U32.to_nat(len), qm({CCe}), Equal.sym(Nat, U32.to_nat(len), Nat.mul({CCe}, {SZ}n), W.ecw(len, hchk)))

def szl(+d: Nat, {TXN}, {HCK}) -> {{ML.LLX(W.OBJw(d, t, x, off, len)) == U32.to_nat(len) : Nat}}:
  szl_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, hchk)
""")
    return '\n'.join(out)


def main():
    outs = {E2E / ('e2e_dbl_%s.bend' % c): text(c) for c in LISTS}
    check = '--check' in sys.argv
    stale = [p.name for p, t in outs.items() if not p.exists() or p.read_text() != t]
    if check:
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('boxed_record_list_decoded_facts: up to date')
        return
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print('boxed_record_list_decoded_facts: %d files' % len(outs))


if __name__ == '__main__':
    main()
