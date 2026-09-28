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
(MT, over RT_L.fz_<E>_bx(W.RX ..)) with root_types' amset / tfzam, then follows e2e_var_b's vl
template (_VL_TEXT) on that tree.

    python3 codegen/e2e_vlm_gen.py            # write the modules
    python3 codegen/e2e_vlm_gen.py --check    # fail if a module is stale

Imported by codegen/e2e_var_b.py (SUPPORT_OUT) through `modules()`.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OBJ = ROOT / 'proofs/obj'

LISTS = [('l16_ProposerSlashing', 'ProposerSlashing', 'var_winx_l16_ProposerSlashing', 16)]


def vl_template():
    s = (ROOT / 'codegen/e2e_var_b.py').read_text()
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
    assert not dp, f'{win}: RX over the depth (not handled yet)'
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
    new = (f'      +hd = FD.nat__le_lt_trans({DW}, {k5}n, 32n, VD.wd_min(W.NN(len), {k5}n, FD.nat__le_trans(U32.to_nat(W.NN(len)), U32.to_nat({limit}), O.pow2n({k5}n), W.hcw(len, hchk), {{==}})), {{==}})\n'
           f'      %fillam({DW}) :\n'
           f'        {{RT_L.xv_{L}({SEQ(f"W.RT({Q}, 0, 0n, _, t, x)")}) == {GV} : S.Value}}\n'
           f'      %amrt({Q}, 0, 0n, {DW}, {T0}, t, x, {{==}}, hb, hd, FD.array__trep_perfect({E}, {DW}, RT_L.MNone{{}})) :\n'
           f'        {{RT_L.xv_{L}({SEQ("_")}) == {GV} : S.Value}}\n'
           f'      %Equal.sym(FD.array__Tree<{E}>, RT_L.tfz_{L}(RT_L.am_{L}({MTQ})), {MTQ}, RT.tfzam_{L}({MTQ})) :\n'
           f'        {{S.Sequence{{RT_L.xi_{L}(U32.to_nat(W.NN(len)), FD.array__slots({E}, _), 0n)}} == {GV} : S.Value}}\n')
    t = t[:i0] + new + t[i1:]
    # hb in vlf is stated at Nat.add(k, 0n); amrt takes Nat.add(Q, 0n) with Q = to_nat(sub(NN, 1)): hb is moved there
    t = t.replace(f'      %amrt({Q}, 0, 0n, {DW}, {T0}, t, x, {{==}}, hb, hd,',
                  f'      %amrt({Q}, 0, 0n, {DW}, {T0}, t, x, {{==}}, hbQ, hd,')
    hbq = (f'      +hbQ = FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, 0n), FD.spec_common__pow2({DW})) == True{{}} : Bool}}, k, {Q}, '
           f'Equal.trans(Nat, k, Nat.sub(1n+k, U32.to_nat(1)), {Q}, Equal.sym(Nat, Nat.sub(1n+k, U32.to_nat(1)), k, subz(k)), '
           f'Equal.trans(Nat, Nat.sub(1n+k, U32.to_nat(1)), Nat.sub(U32.to_nat(W.NN(len)), U32.to_nat(1)), {Q}, '
           f'Equal.cong(Nat, Nat, z => Nat.sub(z, U32.to_nat(1)), 1n+k, U32.to_nat(W.NN(len)), Equal.sym(Nat, W.CC(len), 1n+k, ecc)), '
           f'Equal.sym(Nat, {Q}, Nat.sub(U32.to_nat(W.NN(len)), U32.to_nat(1)), eQ))), hb)\n')
    t = t.replace('      +hd = FD.nat__le_lt_trans(', hbq + '      +hd = FD.nat__le_lt_trans(', 1)
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
    imps = ['import Base', 'import ../src/buffer.bend as B', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vrl.bend as VRL', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/root_types.bend as RT', 'import ../proofs/obj/root_types_light.bend as RT_L', 'import ../proofs/obj/root_names_light.bend as RN',
            f'import ../proofs/obj/{win}.bend as W',
            f'import ../types/Fulu{X}_def_generated.bend as {XD}', f'import ../types/{LD.replace("_d", "")}_def_generated.bend as {LD}']
    hdr = ['', '# GENERATED by codegen/e2e_vlm_gen.py. Do not edit.',
           f'# The {L} window ({win}): the list object it reads (the runtime array of boxed records) views as the',
           '# window\'s value (vl), for any window whose check holds, through the mirror tree of its records.', '']
    # the helpers before vlf, which uses them; the template's lemmas (hbj, hbs, ..) before the helpers
    iv = t.index('def vlf(')
    mx = head[:head.index('def fillam(')]
    rest = head[head.index('# the empty runtime array'):]
    return '\n'.join(imps + hdr) + '\n' + mx + t[:iv] + rest + t[iv:]


def modules():
    return {f'e2e_vlm_{L}.bend': module(L, X, win, lim) for L, X, win, lim in LISTS}


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
        raise SystemExit('stale e2e list views: ' + ', '.join(stale) + '; run codegen/e2e_vlm_gen.py')
    print(f'{len(out)} list view modules' + (' up to date' if '--check' in sys.argv else ''))


if __name__ == '__main__':
    main()
