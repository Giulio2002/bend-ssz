#!/usr/bin/env python3
"""The list views of BeaconBlockBody's lists of Type-kind elements over a window (e2e (ii)/(iii)):

    e2e/e2e_vlm_l16_ProposerSlashing.bend    (var_winx_l16_ProposerSlashing)
    e2e/e2e_vlm_l16_Deposit.bend             (var_winx_l16_Deposit)

each stating, for W the window module,

    vl(+d, +t, +x, +off, +len, +hchk: {W.CHKw(t, x, off, len) == True{}})
      -> {RT_L.xv_<L>(W.OBJw(d, t, x, off, len)) == W.VALw(t, x, len) : S.Value}

(the list object the window reads views as the window's value). The window builds its runtime
array by Array.set of boxed records (W.RT over W.RX); the root view reads that array through the
mirror tree (RT_L.tfz_<L>). The proof moves the array to the mirror tree the record writes build
(MT, over RT_L.fz_<E>_bx(W.RX ..)) with root_types' amset / tfzam, then follows block_and_light_client_bridges's vl
template (_VL_TEXT) on that tree.

    python3 codegen/proofs/bridges/block_body_record_list_views.py            # write the modules
    python3 codegen/proofs/bridges/block_body_record_list_views.py --check    # fail if a module is stale

Imported by codegen/proofs/bridges/block_and_light_client_bridges.py (SUPPORT_OUT) through `modules()`.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core.repository_paths import ROOT, OBJ  # noqa: E402
from codegen.core.bridge_text_helpers import import_list  # noqa: E402

LISTS = [('l16_ProposerSlashing', 'ProposerSlashing', 'var_winx_l16_ProposerSlashing', 16),
         ('l16_Deposit', 'Deposit', 'var_winx_l16_Deposit', 16)]


def vl_template():
    s = (ROOT / 'codegen/proofs/bridges/block_and_light_client_bridges.py').read_text()
    i = s.index('_VL_TEXT = """') + len('_VL_TEXT = """')
    return s[i:s.index('"""', i)]


def wrap_calls(text, name, pre, post):
    """name(ARGS) -> pre(ARGS)post, for every call of name (balanced parentheses)"""
    out, k = [], 0
    while True:
        j = text.find(name + '(', k)
        if j < 0:
            out.append(text[k:])
            return ''.join(out)
        out.append(text[k:j])
        a = j + len(name) + 1
        dep, e = 1, a
        while dep:
            c = text[e]
            dep += (c == '(') - (c == ')')
            e += 1
        out.append(pre + text[a:e - 1] + ')' + post)
        k = e


def module(L, X, win, limit):
    wtext = (OBJ / f'{win}.bend').read_text()
    R = int(re.search(r'VRL\.pos\(j, (\d+)n, x\)', wtext).group(1))
    dp = bool(re.search(r'^def RX\(\+d: Nat, ', wtext, re.M))
    LD = re.search(r'import \.\./\.\./types/(Fulu_list_\w+_def_generated)\.bend as (\w+)', wtext).group(2)
    XD = re.search(r'import \.\./\.\./types/Fulu' + X + r'_def_generated\.bend as (\w+)', wtext).group(1)
    MB = f'RT_L.MB<RT_L.M_{X}>'
    E = MB
    AR = f'Array<O.Boxed<{XD}.{X}>>'
    k5 = max(1, (limit).bit_length())
    t = vl_template()
    # the template over the mirror tree MT of the records' mirrors MX
    t = t.replace('W.RT(', 'MT(').replace('W.RX(t, ', 'MX(t, ')
    t = t.replace('@E@', E).replace('@R@', str(R)).replace('@L@', L).replace('@DEF@', 'RT_L.MNone{}')
    t = wrap_calls(t, '@VIEWE@', f'RT_L.v_{X}_bx(RT_L.th_{X}_bx(', ')')
    t = t.replace('RT.xi_', 'RT_L.xi_').replace('RT.xv_', 'RT_L.xv_').replace('RT.xat_', 'RT_L.xat_')
    # vlf: the window's array is am of the mirror tree (amrt), which tfz reads back (tfzam)
    Q = 'U32.to_nat(U32.sub(W.NN(len), 1))'
    DW = 'B.words_depth(W.NN(len))'
    T0 = f'FD.array__trep({E}, {DW}, RT_L.MNone{{}})'
    MTQ = f'MT({Q}, 0n, {DW}, {T0}, t, x)'
    SEQ = lambda arr: f'{LD}.{L}_Seq{{{arr}, W.NN(len)}}'  # noqa: E731
    GV = 'W.VALw(t, x, len)'
    i0 = t.index('      %Equal.sym(FD.array__Tree<' + E + '>, FD.array__freeze(')
    i1 = t.index('        {S.Sequence{RT_L.xi_' + L + '(U32.to_nat(W.NN(len)), FD.array__slots(' + E + ', _), 0n)} == W.VALw(t, x, len) : S.Value}\n', i0)
    i1 = t.index('\n', i1) + 1
    new = (f'      +hdw = FD.nat__le_lt_trans({DW}, {k5}n, 32n, VD.wd_min(W.NN(len), {k5}n, FD.nat__le_trans(U32.to_nat(W.NN(len)), U32.to_nat({limit}), O.pow2n({k5}n), W.hcw(len, hchk), {{==}})), {{==}})\n'
           f'      %fillam({DW}) :\n'
           f'        {{RT_L.xv_{L}({SEQ(f"W.RT({Q}, 0, 0n, _, t, x)")}) == {GV} : S.Value}}\n'
           f'      %amrt({Q}, 0, 0n, {DW}, {T0}, t, x, {{==}}, hb, hdw, FD.array__trep_perfect({E}, {DW}, RT_L.MNone{{}})) :\n'
           f'        {{RT_L.xv_{L}({SEQ("_")}) == {GV} : S.Value}}\n'
           f'      %Equal.sym(FD.array__Tree<{E}>, RT_L.tfz_{L}(RT_L.am_{L}({MTQ})), {MTQ}, RT.tfzam_{L}({MTQ})) :\n'
           f'        {{S.Sequence{{RT_L.xi_{L}(U32.to_nat(W.NN(len)), FD.array__slots({E}, _), 0n)}} == {GV} : S.Value}}\n')
    t = t[:i0] + new + t[i1:]
    # hb in vlf is stated at Nat.add(k, 0n); amrt takes Nat.add(Q, 0n) with Q = to_nat(sub(NN, 1)): hb is moved there
    t = t.replace(f'      %amrt({Q}, 0, 0n, {DW}, {T0}, t, x, {{==}}, hb, hdw,',
                  f'      %amrt({Q}, 0, 0n, {DW}, {T0}, t, x, {{==}}, hbQ, hdw,')
    hbq = (f'      +hbQ = FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, 0n), FD.spec_common__pow2({DW})) == True{{}} : Bool}}, k, {Q}, '
           f'Equal.trans(Nat, k, Nat.sub(1n+k, U32.to_nat(1)), {Q}, Equal.sym(Nat, Nat.sub(1n+k, U32.to_nat(1)), k, subz(k)), '
           f'Equal.trans(Nat, Nat.sub(1n+k, U32.to_nat(1)), Nat.sub(U32.to_nat(W.NN(len)), U32.to_nat(1)), {Q}, '
           f'Equal.cong(Nat, Nat, z => Nat.sub(z, U32.to_nat(1)), 1n+k, U32.to_nat(W.NN(len)), Equal.sym(Nat, W.CC(len), 1n+k, ecc)), '
           f'Equal.sym(Nat, {Q}, Nat.sub(U32.to_nat(W.NN(len)), U32.to_nat(1)), eQ))), hb)\n')
    t = t.replace('      +hdw = FD.nat__le_lt_trans(', hbq + '      +hdw = FD.nat__le_lt_trans(', 1)
    TV = 'FD.array__Tree<U32>'
    pos = lambda j: f'VRL.pos({j}, {R}n, x)'  # noqa: E731
    head = f'''# the mirror of record j, and the mirror tree the writes of records j .. j + k build from D
def MX(+t: {TV}, +y: Nat) -> {E}: RT_L.fz_{X}_bx(W.RX(t, y))
def thfz(+t: {TV}, +y: Nat) -> {{RT_L.th_{X}_bx(MX(t, y)) == W.RX(t, y) : O.Boxed<{XD}.{X}>}}: {{==}}
def MT(k: Nat, +j: Nat, +dd: Nat, D: FD.array__Tree<{E}>, +t: {TV}, +x: Nat) -> FD.array__Tree<{E}>:
  match k:
    case 0n: FD.array__upd({E}, dd, D, j, MX(t, {pos("j")}))
    case 1n+q: MT(q, 1n+j, dd, FD.array__upd({E}, dd, D, j, MX(t, {pos("j")})), t, x)

# the empty runtime array is am of the tree of MNone
def fillam(+dd: Nat) -> {{RT_L.am_{L}(FD.array__trep({E}, dd, RT_L.MNone{{}})) == {LD}.{L}_fill(dd) : {AR}}}:
  match dd:
    case 0n: {{==}}
    case 1n+ +p:
      %Equal.sym({AR}, RT_L.am_{L}(FD.array__trep({E}, p, RT_L.MNone{{}})), {LD}.{L}_fill(p), fillam(p)) :
        {{ANode{{_, _}} == ANode{{{LD}.{L}_fill(p), {LD}.{L}_fill(p)}} : {AR}}}
      {{==}}

# i + 1 does not wrap below 2^dd, dd < 32
def inc(+i: U32, +dd: Nat, +hd: {{Nat.is_lt(dd, 32n) == True{{}} : Bool}}, +h: {{Nat.is_le(1n+U32.to_nat(i), FD.spec_common__pow2(dd)) == True{{}} : Bool}})
    -> {{U32.to_nat(U32.add(i, 1)) == 1n+U32.to_nat(i) : Nat}}:
  +hc = FD.logic__subst(Nat, z => {{Nat.is_le(1n+U32.to_nat(i), z) == True{{}} : Bool}}, FD.spec_common__pow2(dd), U32.to_nat(FD.u32__pow2u(dd)),
    Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(dd)), FD.spec_common__pow2(dd), FD.u32__pow2u_value(dd, hd)), h)
  +hc2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(FD.u32__pow2u(dd))) == True{{}} : Bool}}, 1n+U32.to_nat(i), Nat.add(U32.to_nat(i), U32.to_nat(1)),
    Equal.trans(Nat, 1n+U32.to_nat(i), 1n+Nat.add(U32.to_nat(i), 0n), Nat.add(U32.to_nat(i), U32.to_nat(1)),
      Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(i), Nat.add(U32.to_nat(i), 0n), Equal.sym(Nat, Nat.add(U32.to_nat(i), 0n), U32.to_nat(i), FD.nat__add_zero(U32.to_nat(i)))),
      Equal.sym(Nat, Nat.add(U32.to_nat(i), 1n), 1n+Nat.add(U32.to_nat(i), 0n), FD.nat__add_succ(U32.to_nat(i), 0n))), hc)
  Equal.trans(Nat, U32.to_nat(U32.add(i, 1)), Nat.add(U32.to_nat(i), U32.to_nat(1)), 1n+U32.to_nat(i), A.add_le(i, 1, FD.u32__pow2u(dd), hc2),
    Equal.trans(Nat, Nat.add(U32.to_nat(i), 1n), 1n+Nat.add(U32.to_nat(i), 0n), 1n+U32.to_nat(i), FD.nat__add_succ(U32.to_nat(i), 0n),
      Equal.cong(Nat, Nat, z => 1n+z, Nat.add(U32.to_nat(i), 0n), U32.to_nat(i), FD.nat__add_zero(U32.to_nat(i)))))

# one record write: the runtime Array.set is am of the tree write
def amst(+i: U32, +j: Nat, +dd: Nat, +D: FD.array__Tree<{E}>, +t: {TV}, +x: Nat, +ej: {{U32.to_nat(i) == j : Nat}},
    +hj: {{Nat.is_lt(j, FD.spec_common__pow2(dd)) == True{{}} : Bool}}, +hd: {{Nat.is_lt(dd, 32n) == True{{}} : Bool}}, +pf: {{FD.array__perfect({E}, dd, D) == True{{}} : Bool}})
    -> {{Array.set(O.Boxed<{XD}.{X}>, RT_L.am_{L}(D), i, W.RX(t, {pos("j")})) == RT_L.am_{L}(FD.array__upd({E}, dd, D, j, MX(t, {pos("j")}))) : {AR}}}:
  +hi = FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(dd)) == True{{}} : Bool}}, j, U32.to_nat(i), Equal.sym(Nat, U32.to_nat(i), j, ej), hj)
  +hl = FD.logic__subst(Nat, z => {{Nat.is_lt(U32.to_nat(i), z) == True{{}} : Bool}}, FD.spec_common__pow2(dd), FD.spec_common__length({E}, FD.array__slots({E}, D)),
    Equal.sym(Nat, FD.spec_common__length({E}, FD.array__slots({E}, D)), FD.spec_common__pow2(dd), FD.array__slots_length({E}, dd, D, pf)), hi)
  %thfz(t, {pos("j")}) :
    {{Array.set(O.Boxed<{XD}.{X}>, RT_L.am_{L}(D), i, _) == RT_L.am_{L}(FD.array__upd({E}, dd, D, j, MX(t, {pos("j")}))) : {AR}}}
  %ej : {{Array.set(O.Boxed<{XD}.{X}>, RT_L.am_{L}(D), i, RT_L.th_{X}_bx(MX(t, {pos("j")}))) == RT_L.am_{L}(FD.array__upd({E}, dd, D, _, MX(t, {pos("j")}))) : {AR}}}
  RT.amset_{L}(dd, D, i, MX(t, {pos("j")}), RT_L.xat_{L}(FD.array__slots({E}, D), U32.to_nat(i)), hd, hi,
    RT.nth_{L}(FD.array__slots({E}, D), U32.to_nat(i), hl), pf)

# the window's record writes into am(D) are am of the mirror tree they build
def amrt(k: Nat, +i: U32, +j: Nat, +dd: Nat, +D: FD.array__Tree<{E}>, +t: {TV}, +x: Nat, +ej: {{U32.to_nat(i) == j : Nat}},
    +hb: {{Nat.is_lt(Nat.add(k, j), FD.spec_common__pow2(dd)) == True{{}} : Bool}}, +hd: {{Nat.is_lt(dd, 32n) == True{{}} : Bool}}, +pf: {{FD.array__perfect({E}, dd, D) == True{{}} : Bool}})
    -> {{RT_L.am_{L}(MT(k, j, dd, D, t, x)) == W.RT(k, i, j, RT_L.am_{L}(D), t, x) : {AR}}}:
  match k:
    case 0n: Equal.sym({AR}, W.RT(0n, i, j, RT_L.am_{L}(D), t, x), RT_L.am_{L}(MT(0n, j, dd, D, t, x)), amst(i, j, dd, D, t, x, ej, hb, hd, pf))
    case 1n+ +p:
      +hj = hbj(p, j, dd, hb)
      +h1 = FD.logic__subst(Nat, z => {{Nat.is_le(1n+z, FD.spec_common__pow2(dd)) == True{{}} : Bool}}, j, U32.to_nat(i), Equal.sym(Nat, U32.to_nat(i), j, ej), FD.nat__lt_succ_le_succ(j, FD.spec_common__pow2(dd), hj))
      +ej2 = Equal.trans(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), 1n+j, inc(i, dd, hd, h1), Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(i), j, ej))
      +ih = amrt(p, U32.add(i, 1), 1n+j, dd, FD.array__upd({E}, dd, D, j, MX(t, {pos("j")})), t, x, ej2, hbs(p, j, dd, hb), hd,
        FD.array__upd_perfect({E}, dd, D, j, MX(t, {pos("j")}), pf))
      %Equal.sym({AR}, Array.set(O.Boxed<{XD}.{X}>, RT_L.am_{L}(D), i, W.RX(t, {pos("j")})), RT_L.am_{L}(FD.array__upd({E}, dd, D, j, MX(t, {pos("j")}))), amst(i, j, dd, D, t, x, ej, hj, hd, pf)) :
        {{RT_L.am_{L}(MT(1n+p, j, dd, D, t, x)) == W.RT(p, U32.add(i, 1), 1n+j, _, t, x) : {AR}}}
      ih

'''
    imps = [*import_list('Base B O S FD A Order VD VRL VB RT=root_types RT_L RN=root_names_light'),
            f'import ../proofs/obj/{win}.bend as W',
            f'import ../types/Fulu{X}_def_generated.bend as {XD}', f'import ../types/{LD.replace("_d", "")}_def_generated.bend as {LD}']
    hdr = ['', '# GENERATED by block_body_record_list_views (codegen). Do not edit.',
           f'# The {L} window ({win}): the list object it reads (the runtime array of boxed records) views as the',
           '# window\'s value (vl), for any window whose check holds, through the mirror tree of its records.', '']
    # the helpers before vlf, which uses them; the template's lemmas (hbj, hbs, ..) before the helpers
    iv = t.index('def vlf(')
    mx = head[:head.index('def fillam(')]
    rest = head[head.index('# the empty runtime array'):]
    body = mx + t[:iv] + rest + t[iv:]
    if dp:
        body = depth_form(body, L, X, R, wtext)
        imps += DP_IMPORTS
        imps += [f'import ../types/{m.group(1)} as {m.group(2)}' for m in re.finditer(r'^import \.\./\.\./types/(\w+_def_generated\.bend) as (\w+)$', wtext, re.M)]
        imps = list(dict.fromkeys(imps))
    return '\n'.join(imps + hdr) + '\n' + body


DP_IMPORTS = [*import_list('F VS=vspec VC VF UR UCT VXB PV=pv_obj_light WR=words_root_light BX')]
DP_DEFS = ('MX', 'thfz', 'MT', 'amst', 'amrt', 'pfRT', 'lemB', 'stepA', 'lemA', 'xiR', 'vlf', 'vlc')


def depth_form(body, L, X, R, wtext):
    """A window whose records read a copied field (Deposit: its proof, VXB.CTN at the decoder's depth d):
    every def over the records takes d; the element step of xiR is the record view lemma ev (the copy's
    view reads the window's words: e2e_bx.ctwY), at the element's position, from the window facts
    (vt's order: eo, hd, hw, pf) that vl now takes."""
    for nm in DP_DEFS:
        body = re.sub(r'(?<=def )' + nm + r'\(', nm + '(+d: Nat, ', body)
        body = re.sub(r'(?<![\w.])(?<!def )' + nm + r'\(', nm + '(d, ', body)
    body = body.replace('W.RX(t, ', 'W.RX(d, t, ').replace('W.RT(', 'W.RT(d, ').replace('W.LOBJ(', 'W.LOBJ(d, ')
    E = f'RT_L.MB<RT_L.M_{X}>'
    VIEW = lambda y: f'RT_L.v_{X}_bx(RT_L.th_{X}_bx(MX(d, t, {y})))'  # noqa: E731
    pos = lambda j: f'VRL.pos({j}, {R}n, x)'  # noqa: E731
    HD = '+hd: {Nat.is_lt(d, 31n) == True{} : Bool}'
    HW = '+hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}'
    PF = '+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}'
    # xiR: the element view hypothesis ev_, and the element step through it
    evt = ('+len: U32, +ecc: {W.CC(len) == 1n+Q : Nat}, +hchk: {W.CHKw(t, x, 0, len) == True{} : Bool}, '
           + HD + ', ' + HW + ', ' + PF.replace('+pf:', '+pft:'))
    body = body.replace('+hm: {Nat.is_le(Nat.add(m, i), 1n+Q) == True{} : Bool})\n    -> {RT_L.xi_',
                        '+hm: {Nat.is_le(Nat.add(m, i), 1n+Q) == True{} : Bool}, ' + evt + ')\n    -> {RT_L.xi_', 1)
    i = body.index('def xiR(')
    j = body.index('      Equal.cong(S.Value, S.Value, z => S.Items{', i)
    k = body.index('\n\n', j)
    cong = body[j + 6:k].replace(', hb, hm2))', ', hb, hm2, len, ecc, hchk, hd, hw, pft))')
    XI = f'RT_L.xi_{L}(k, FD.array__slots({E}, MT(d, Q, 0n, dd, D, t, x)), 1n+i)'
    RK = f'W.RITEMS(k, t, {pos("1n+i")})'
    step = (f'      Equal.trans(S.Value, S.Items{{{VIEW(pos("i"))}, {XI}}}, S.Items{{{VIEW(pos("i"))}, {RK}}}, W.RITEMS(1n+k, t, {pos("i")}),\n'
            f'        {cong},\n'
            f'        Equal.cong(S.Value, S.Value, z => S.Items{{z, {RK}}}, {VIEW(pos("i"))}, W.RVAL(t, {pos("i")}), EVP(d, t, x, len, i, Q, ecc, hchk, hd, hw, pft, hq)))')
    body = body[:j] + step + body[k:]
    # vlf / vlc / vl: the window facts
    body = body.replace('+eb: {U32.is_eq(len, 0) == False{} : Bool})\n    -> {RT_L.xv_',
                        f'+eb: {{U32.is_eq(len, 0) == False{{}} : Bool}}, {HD}, {HW}, {PF})\n    -> {{RT_L.xv_', 1)
    body = body.replace('+b: Bool, +eb: {U32.is_eq(len, 0) == b : Bool})\n    -> {RT_L.xv_',
                        f'+b: Bool, +eb: {{U32.is_eq(len, 0) == b : Bool}}, {HD}, {HW}, {PF})\n    -> {{RT_L.xv_', 1)
    body = body.replace('vlf(d, t, x, len, hchk, W.CC(len), {==}, eb)', 'vlf(d, t, x, len, hchk, W.CC(len), {==}, eb, hd, hw, pf)')
    body = body.replace('+len: U32, +hchk: {W.CHKw(t, x, off, len) == True{} : Bool})\n    -> {RT_L.xv_',
                        f'+len: U32, +eo: {{U32.to_nat(off) == x : Nat}}, {HD}, {HW}, {PF},\n    +hchk: {{W.CHKw(t, x, off, len) == True{{}} : Bool}})\n    -> {{RT_L.xv_', 1)
    body = body.replace('vlc(d, t, x, len, hchk, U32.is_eq(len, 0), {==})', 'vlc(d, t, x, len, hchk, U32.is_eq(len, 0), {==}, hd, hw, pf)')
    i = body.index('def vlf(')
    j = body.index('xiR(d, 1n+k, 0n, k, ', i)
    k = body.index('hb, hm))', j)
    body = body[:k] + 'hb, hm, len, ecc, hchk, hd, hw, pf))' + body[k + len('hb, hm))'):]
    # the record view lemma, before vlf
    m = re.search(r'VXB\.CTN\(d, t, y, (\d+), (\d+)n\)', wtext)
    FB, DZ = int(m.group(1)), int(m.group(2))
    K = FB // 4
    rx = re.search(r'^def RX\(\+d: Nat, \+t: FD\.array__Tree<U32>, \+y: Nat\) -> O\.Boxed<\w+\.' + X + r'>: (.*)$', wtext, re.M).group(1)
    mm = re.match(r'(\w+)\.' + X + r'_bx_wrap\(\1\.' + X + r'\{O\.Words\{FD\.array__thaw\(U32, VXB\.CTN\(d, t, y, ' + str(FB) + r', ' + str(DZ) + r'n\)\), ' + str(FB) + r'\}, (.*)\}\)$', rx)
    assert mm, 'the copied field is not the first'
    REST = mm.group(2)
    XDm = mm.group(1)
    # the mirror holds the copy's storage frozen: th(fz(RX)) is RX up to freeze(thaw(CTN)) (freeze_thaw)
    CTNd = f'VXB.CTN(d, t, y, {FB}, {DZ}n)'
    thl = re.search(r'^def thfz\(.*$', body, re.M).group(0)
    thn = (thl[:thl.rindex(': {==}')] + ':\n'
           f'  Equal.cong(FD.array__Tree<U32>, O.Boxed<{XDm}.{X}>, z => {XDm}.{X}_bx_wrap({XDm}.{X}{{O.Words{{FD.array__thaw(U32, z), {FB}}}, {REST}}}), '
           f'FD.array__freeze(U32, FD.array__thaw(U32, {CTNd})), {CTNd}, FD.array__freeze_thaw(U32, {CTNd}))')
    body = body.replace(thl, thn)
    rv = re.search(r'^def v_' + X + r'\(o: \w+\.' + X + r'\) -> S\.Value:\n  match o:\n    case \w+\.' + X + r'\{x0, x1\}: S\.Sequence\{S\.Items\{PV\.pview\(x0\), S\.Items\{(\w+)\(x1\), S\.EmptyItems\{\}\}\}\}$',
                   (ROOT / 'proofs/obj/root_types_light.bend').read_text(), re.M)
    assert rv, 'record view shape'
    V1 = rv.group(1)
    ky = max(1, (31 + FB).bit_length())
    TV = 'FD.array__Tree<U32>'
    CT = f'UCT.CT(d, t, U32.from_nat(y), {FB}, {DZ}n)'
    PVR = f'S.Sequence{{WR.items(O.chunks_of({FB}), VF.app(UR.RWS({K}n, t, y), VB.wdr({K}n, FD.array__slots(U32, {CT}))), 0n)}}'
    PVW = f'PV.pview(O.Words{{FD.array__thaw(U32, VXB.CTN(d, t, y, {FB}, {DZ}n)), {FB}}})'
    PVC = f'PV.pview(O.Words{{FD.array__thaw(U32, {CT}), {FB}}})'
    lem = f"""# a copied vector of Bytes32 at any depth: its view reads the window's words (e2e_bx.pvx, through ctwY)
def pvxY(+d: Nat, +t: {TV}, +off: U32, +L: U32, +dz: Nat, +x: Nat, +K: Nat, +eo: {{U32.to_nat(off) == x : Nat}}, +hy: {{Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}},
    +hr: {{Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{{}} : Bool}}, +eL: {{U32.to_nat(L) == A.quad(K) : Nat}})
    -> {{PV.pview(O.Words{{FD.array__thaw(U32, UCT.CT(d, t, off, L, dz)), L}}) == S.Sequence{{WR.items(O.chunks_of(L), VF.app(UR.RWS(K, t, x), VB.wdr(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)))), 0n)}} : S.Value}}:
  %Equal.sym({TV}, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, off, L, dz))), UCT.CT(d, t, off, L, dz), FD.array__freeze_thaw(U32, UCT.CT(d, t, off, L, dz))) :
    {{S.Sequence{{WR.items(O.chunks_of(L), FD.array__slots(U32, _), 0n)}} == S.Sequence{{WR.items(O.chunks_of(L), VF.app(UR.RWS(K, t, x), VB.wdr(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)))), 0n)}} : S.Value}}
  %Equal.sym(List<&2, U32>, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)), VF.app(VS.wtake(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz))), VB.wdr(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)))), BX.tdl(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)))) :
    {{S.Sequence{{WR.items(O.chunks_of(L), _, 0n)}} == S.Sequence{{WR.items(O.chunks_of(L), VF.app(UR.RWS(K, t, x), VB.wdr(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)))), 0n)}} : S.Value}}
  Equal.cong(List<&2, U32>, S.Value, z => S.Sequence{{WR.items(O.chunks_of(L), VF.app(z, VB.wdr(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz)))), 0n)}}, VS.wtake(K, FD.array__slots(U32, UCT.CT(d, t, off, L, dz))), UR.RWS(K, t, x),
    BX.ctwY(d, t, off, L, dz, x, K, eo, hy, hw, pf, hr, eL))

# the record read at byte y: its view is the window's value of that record
def ev(+d: Nat, +t: {TV}, +y: Nat, +h32: {{Nat.is_lt(y, FD.spec_common__pow2(32n)) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add({R}n, y), A.quad(VB.pw(d))) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}})
    -> {{RT_L.v_{X}_bx(W.RX(d, t, y)) == W.RVAL(t, y) : S.Value}}:
  +eo = FD.u32__to_nat_from_nat(y, 32n, {{==}}, h32)
  +hw1 = FD.nat__le_trans(Nat.add({FB}n, y), Nat.add({R}n, y), A.quad(VB.pw(d)), Order.add_right({FB}n, {R}n, y, {{==}}), hw)
  +hw0 = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, Nat.add({FB}n, y), Nat.add(y, {FB}n), FD.nat__add_comm({FB}n, y), hw1)
  +ec = Equal.cong({TV}, S.Value, z => PV.pview(O.Words{{FD.array__thaw(U32, z), {FB}}}), VXB.CTN(d, t, y, {FB}, {DZ}n), {CT},
    Equal.sym({TV}, {CT}, VXB.CTN(d, t, y, {FB}, {DZ}n), VXB.ct_n(d, t, U32.from_nat(y), y, {FB}, {DZ}n, eo)))
  +epv = Equal.trans(S.Value, {PVW}, {PVC}, {PVR}, ec,
    pvxY(d, t, U32.from_nat(y), {FB}, {DZ}n, y, {K}n, eo, VC.hyU({FB}, {ky}n, {{==}}, {{==}}), hw0, pf, {{==}}, {{==}}))
  FD.logic__subst(S.Value, z => {{S.Sequence{{S.Items{{z, S.Items{{RT_L.{V1}({REST}), S.EmptyItems{{}}}}}}}} == W.RVAL(t, y) : S.Value}}, {PVR}, {PVW},
    Equal.sym(S.Value, {PVW}, {PVR}, epv), {{==}})

# element i < CC(len) of the window: its position is within the tree and below 2^32
def EVP(+d: Nat, +t: {TV}, +x: Nat, +len: U32, +i: Nat, +k: Nat, +ecc: {{W.CC(len) == 1n+k : Nat}}, +hchk: {{W.CHKw(t, x, 0, len) == True{{}} : Bool}},
    {HD}, {HW}, {PF}, +hq: {{Nat.is_le(i, k) == True{{}} : Bool}})
    -> {{{VIEW(pos("i"))} == W.RVAL(t, {pos("i")}) : S.Value}}:
  +hcc = FD.logic__subst(Nat, z => {{Nat.is_le(1n+i, z) == True{{}} : Bool}}, 1n+k, W.CC(len), Equal.sym(Nat, W.CC(len), 1n+k, ecc), hq)
  +hm = VRL.mul_mono(1n+i, W.CC(len), {R}n, hcc)
  +hp = Order.add_right(Nat.mul(1n+i, {R}n), Nat.mul(W.CC(len), {R}n), x, hm)
  +el = W.ecw(len, hchk)
  +e2 = Equal.trans(Nat, Nat.add(Nat.mul(W.CC(len), {R}n), x), Nat.add(x, Nat.mul(W.CC(len), {R}n)), Nat.add(x, U32.to_nat(len)), FD.nat__add_comm(Nat.mul(W.CC(len), {R}n), x),
    Equal.cong(Nat, Nat, z => Nat.add(x, z), Nat.mul(W.CC(len), {R}n), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.mul(W.CC(len), {R}n), el)))
  +h1 = FD.logic__subst(Nat, z => {{Nat.is_le({pos("1n+i")}, z) == True{{}} : Bool}}, Nat.add(Nat.mul(W.CC(len), {R}n), x), Nat.add(x, U32.to_nat(len)), e2, hp)
  +h2 = FD.nat__le_trans({pos("1n+i")}, Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), h1, hw)
  +h3 = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, {pos("1n+i")}, Nat.add({R}n, {pos("i")}), Equal.sym(Nat, Nat.add({R}n, {pos("i")}), {pos("1n+i")}, VRL.pnx0(i, {R}n, x)), h2)
  +h32 = FD.nat__lt_le_trans({pos("i")}, Nat.add({R}n, {pos("i")}), FD.spec_common__pow2(32n), FD.nat__le_lt_succ({pos("i")}, Nat.add({R - 1}n, {pos("i")}), Order.left_below_sum({R - 1}n, {pos("i")})),
    FD.nat__le_trans(Nat.add({R}n, {pos("i")}), A.quad(VB.pw(d)), FD.spec_common__pow2(32n), h3, FD.nat__pow2_mono(2n+d, 32n, FD.nat__lt_succ_le(d, 30n, hd))))
  %Equal.sym(O.Boxed<{XDm}.{X}>, RT_L.th_{X}_bx(MX(d, t, {pos("i")})), W.RX(d, t, {pos("i")}), thfz(d, t, {pos("i")})) :
    {{RT_L.v_{X}_bx(_) == W.RVAL(t, {pos("i")}) : S.Value}}
  ev(d, t, {pos("i")}, h32, h3, pf)

"""
    i = body.index('def xiR(')
    i = body.rindex('\n#', 0, i) + 1 if body.rindex('\n\n', 0, i) < body.rindex('\n#', 0, i) else i
    return body[:i] + lem + body[i:]


def modules():
    from codegen.impl import runtime_file_split as RR   # the bridge writes every module rewired (its light companions): a fixpoint of rewire
    return {f'e2e_vlm_{L}.bend': RR.rewire(module(L, X, win, lim)) for L, X, win, lim in LISTS}


def main():
    out = modules()
    stale = []
    for name, text in out.items():
        p = ROOT / 'e2e' / name
        if '--check' in sys.argv:
            if not p.exists() or p.read_text() != text:
                stale.append(name)
        else:
            p.write_text(text)
    if stale:
        raise SystemExit('stale e2e list views: ' + ', '.join(stale) + '; run codegen/proofs/bridges/block_body_record_list_views.py')
    print(f'{len(out)} list view modules' + (' up to date' if '--check' in sys.argv else ''))


if __name__ == '__main__':
    main()
