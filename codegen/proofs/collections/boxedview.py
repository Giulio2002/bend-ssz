"""The spec view of a boxed list (Array<O.Boxed<X>>, Type-kind elements, through the Data mirrors of root_types_light.bend)
after an accepted set: proofs/obj/tfz_boxed.bend.

The view xv_<list> reads the frozen tree tfz_<list>(arr) of the mirrors M of the stored boxes. Writing a box w at index i of a perfect
array (TA.put, the array Array.set gives, proofs/obj/tarray.bend) freezes to the tree updated at i with the mirror of w (tfzput_<list>:
one induction over the depth, the index walk of put against F.array__upd's), so the view of the written array is the view before with item i
replaced (view_seq.bend's induction over the items, the same `<list>_view_set` the Data lists use) by the view of the stored box,
`v_X_bx(th_X_bx(fz_X_bx(wrap v)))` (what the root bridge reads of a stored element).

    python3 codegen/proofs/collections/boxedview.py            # write
    python3 codegen/proofs/collections/boxedview.py --check    # nonzero exit if the output is stale
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core.paths import ROOT  # noqa: E402
from codegen.core.shared_laws import run_single  # noqa: E402


P_ = 'F.spec_common__pow2'
U_ = 'F.u32__pow2u'


def lemmas(c, T, MB, TFZ, FZ, AM, VQ):
    """freezing the array Array.set writes is updating the frozen tree: tfzrs_<c> (with the facts about put and the sizes tarray.bend's rs
    gives, and the perfection of the frozen tree), the induction over the depth; amperf_<c>; view_set_t_<c>"""
    TR = 'F.array__Tree<%s>' % MB
    SZA = lambda a: '{Array.size(%s, %s) == (%s, TA.sz(%s, %s)) : Array<%s> & U32}' % (T, a, a, T, a, T)
    SZB = lambda a, d: '{TA.sz(%s, %s) == %s(%s) : U32}' % (T, a, U_, d)
    PERF = lambda a, d: '{F.array__perfect(%s, %s, %s(%s)) == True{} : Bool}' % (MB, d, TFZ, a)
    PUT = lambda a, n, i, w, z: 'TA.put(%s, %s, %s, %s, %s, %s)' % (T, a, n, i, w, z)
    RS4 = lambda a, n, i, w, z, d: ('{Array.swap.go(%s, %s, %s, %s, %s, %s) == (%s, TA.old(%s, %s, %s, %s, %s)) : Array<%s> & %s} & ({Array.size(%s, %s) == (%s, TA.sz(%s, %s)) : Array<%s> & U32} & '
                                    '({Array.size(%s, %s) == (%s, TA.sz(%s, %s)) : Array<%s> & U32} & (%s)))'
                                    % (T, a, n, i, w, z, PUT(a, n, i, w, z), T, a, n, i, z, T, T, T, a, a, T, a, T, T, PUT(a, n, i, w, z), PUT(a, n, i, w, z), T, a, T, SZB(a, d)))
    EQ = lambda a, n, i, j, w, z, d: '{%s(%s) == F.array__tupd(%s, %s, %s(%s), %s, %s(%s), F.array__ndec(%s, %s)) : %s}' % (TFZ, PUT(a, n, i, w, z), MB, d, TFZ, a, j, FZ, w, d, j, TR)
    out = []
    # the size, the power of two and the perfection of the frozen tree of a perfect array
    SPT = lambda a, d: '%s & ((%s) & (%s))' % (SZA(a), SZB(a, d), PERF(a, d))
    out.append(f"""def tfzsp_n_{c}(-p: Nat, -xs: Array<{T}>, -ys: Array<{T}>, ih1: {SPT('xs', 'p')}, ih2: {SPT('ys', 'p')}) -> {SPT('ANode{xs, ys}', '1n+p')}:
  (+s1, r1) = ih1
  (+s2, p1) = r1
  (+t1, r2) = ih2
  (+t2, p2) = r2
  (TA.size_node2({T}, xs, ys, TA.sz({T}, xs), s1), (Equal.cong(U32, U32, s => U32.shl(s), TA.sz({T}, xs), {U_}(p), s2), TA.and_i(F.array__perfect({MB}, p, {TFZ}(xs)), F.array__perfect({MB}, p, {TFZ}(ys)), p1, p2)))

def tfzsp_{c}(+d: Nat, a: Array<{T}>, pf: TA.tperf({T}, d, a)) -> {SPT('a', 'd')}:
  match d a:
    case 0n ALeaf{{x}}: ({{==}}, ({{==}}, {{==}}))
    case 0n ANode{{xs, ys}}: Empty.absurd({SPT('ANode{xs, ys}', '0n')}, pf)
    case 1n+p ALeaf{{x}}: Empty.absurd({SPT('ALeaf{x}', '1n+p')}, pf)
    case 1n+p ANode{{xs, ys}}:
      (pl, pr) = pf
      tfzsp_n_{c}(p, xs, ys, tfzsp_{c}(p, xs, pl), tfzsp_{c}(p, ys, pr))
""")
    # one level of the update walk, left and right
    for side, z in (('l', 'True{}'), ('r', 'False{}')):
        if side == 'l':
            ih = EQ('xs', 'U32.shr(n)', 'i', 'j', 'w', 'U32.is_lt(i, U32.shr(U32.shr(n)))', 'p')
            rew = ('%%Equal.sym(%s, %s(%s), F.array__tupd(%s, p, %s(xs), j, %s(w), F.array__ndec(p, j)), ih) :\n'
                   '        {F.TNode{_, %s(ys)} == F.TNode{F.array__tupd(%s, p, %s(xs), j, %s(w), F.array__ndec(p, j)), %s(ys)} : %s}'
                   % (TR, TFZ, PUT('xs', 'U32.shr(n)', 'i', 'w', 'U32.is_lt(i, U32.shr(U32.shr(n)))'), MB, TFZ, FZ, TFZ, MB, TFZ, FZ, TFZ, TR))
        else:
            JS = '%s(p)' % P_
            PI = 'U32.sub(i, U32.shr(n))'
            PJ = 'Nat.sub(j, %s)' % JS
            PZ = 'U32.is_lt(%s, U32.shr(U32.shr(n)))' % PI
            ih = EQ('ys', 'U32.shr(n)', PI, PJ, 'w', PZ, 'p')
            rew = ('%%Equal.sym(%s, %s(%s), F.array__tupd(%s, p, %s(ys), %s, %s(w), F.array__ndec(p, %s)), ih) :\n'
                   '        {F.TNode{%s(xs), _} == F.TNode{%s(xs), F.array__tupd(%s, p, %s(ys), %s, %s(w), F.array__ndec(p, %s))} : %s}'
                   % (TR, TFZ, PUT('ys', 'U32.shr(n)', PI, 'w', PZ), MB, TFZ, PJ, FZ, PJ, TFZ, TFZ, MB, TFZ, PJ, FZ, PJ, TR))
        out.append(f"""def tfzeq_{side}_{c}(+p: Nat, -xs: Array<{T}>, -ys: Array<{T}>, +n: U32, +i: U32, +j: Nat, -w: {T}, +hd: {{Nat.is_lt(1n+p, 32n) == True{{}} : Bool}},
    +hn: {{n == {U_}(1n+p) : U32}}, +hi: {{Nat.is_lt(j, {P_}(1n+p)) == True{{}} : Bool}}, +hj: {{U32.to_nat(i) == j : Nat}}, +hz: {{{z} == U32.is_lt(i, U32.shr(n)) : Bool}},
    +ih: {ih})
    -> {EQ('ANode{xs, ys}', 'n', 'i', 'j', 'w', z, '1n+p')}:
  %Equal.sym(Bool, F.array__ndec(1n+p, j), {z}, TA.bit_nat(p, n, i, j, {z}, hd, hn, hj, hz)) :
    {{{TFZ}({PUT('ANode{xs, ys}', 'n', 'i', 'w', z)}) == F.array__tupd({MB}, 1n+p, {TFZ}(ANode{{xs, ys}}), j, {FZ}(w), _) : {TR}}}
  {rew}
  {{==}}
""")
    # the lemma itself
    def rec(a, n, i, j, z, hn, hi_, hj_, hz_, pfv):
        return 'tfzrs_%s(p, %s, %s, %s, %s, w, %s, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), %s, %s, %s, %s, %s)' % (c, a, n, i, j, z, hn, hi_, hj_, hz_, pfv)
    ST = 'TA.shr_n(p, n, hd, hn)'
    left = rec('xs', 'U32.shr(n)', 'i', 'j', 'U32.is_lt(i, U32.shr(U32.shr(n)))', ST, 'TA.bit_nat(p, n, i, j, True{}, hd, hn, hj, hz)', 'hj', '{==}', 'pl')
    PI = 'U32.sub(i, U32.shr(n))'
    PJ = 'Nat.sub(j, %s(p))' % P_
    right = rec('ys', 'U32.shr(n)', PI, PJ, 'U32.is_lt(%s, U32.shr(U32.shr(n)))' % PI, ST, 'TA.hi_ok(p, n, i, j, hd, hn, hi, hj, hz)', 'TA.sub_of(p, n, i, j, hd, hn, hj, hz)', '{==}', 'pr')
    ZA = lambda a, n, i, j, z, d: ('%s & (%s & (%s))' % (EQ(a, n, i, j, 'w', z, d), PERF(a, d), RS4(a, n, i, 'w', z, d)))
    common = f"""+n: U32, +i: U32, +j: Nat, -w: {T}, +hd: {{Nat.is_lt(1n+p, 32n) == True{{}} : Bool}},
    +hn: {{n == {U_}(1n+p) : U32}}, +hi: {{Nat.is_lt(j, {P_}(1n+p)) == True{{}} : Bool}}, +hj: {{U32.to_nat(i) == j : Nat}}"""
    LI = ('U32.shr(n)', 'i', 'j', 'U32.is_lt(i, U32.shr(U32.shr(n)))')
    RI = ('U32.shr(n)', PI, PJ, 'U32.is_lt(%s, U32.shr(U32.shr(n)))' % PI)
    out.append(f"""def tfzrs_nl_{c}(+p: Nat, -xs: Array<{T}>, -ys: Array<{T}>, {common}, +hz: {{True{{}} == U32.is_lt(i, U32.shr(n)) : Bool}},
    ih: {ZA('xs', *LI, 'p')}, sy: {SPT('ys', 'p')})
    -> {ZA('ANode{xs, ys}', 'n', 'i', 'j', 'True{}', '1n+p')}:
  (+e1, r1) = ih
  (+pf1, rs1) = r1
  (+t1, rt) = sy
  (+t2, pf2) = rt
  (tfzeq_l_{c}(p, xs, ys, n, i, j, w, hd, hn, hi, hj, hz, e1), (TA.and_i(F.array__perfect({MB}, p, {TFZ}(xs)), F.array__perfect({MB}, p, {TFZ}(ys)), pf1, pf2), TA.rs_l({T}, p, xs, ys, n, i, w, rs1)))
""")
    out.append(f"""def tfzrs_nr_{c}(+p: Nat, -xs: Array<{T}>, -ys: Array<{T}>, {common}, +hz: {{False{{}} == U32.is_lt(i, U32.shr(n)) : Bool}},
    ih: {ZA('ys', *RI, 'p')}, sx: {SPT('xs', 'p')})
    -> {ZA('ANode{xs, ys}', 'n', 'i', 'j', 'False{}', '1n+p')}:
  (+e1, r1) = ih
  (+pf2, rs1) = r1
  (+s1, rt) = sx
  (+s2, pf1) = rt
  (tfzeq_r_{c}(p, xs, ys, n, i, j, w, hd, hn, hi, hj, hz, e1), (TA.and_i(F.array__perfect({MB}, p, {TFZ}(xs)), F.array__perfect({MB}, p, {TFZ}(ys)), pf1, pf2), TA.rs_r({T}, p, xs, ys, n, i, w, rs1, (s1, s2))))
""")
    out.append(f"""def tfzrs_{c}(+d: Nat, a: Array<{T}>, +n: U32, +i: U32, +j: Nat, -w: {T}, +z: Bool, +hd: {{Nat.is_lt(d, 32n) == True{{}} : Bool}},
    +hn: {{n == {U_}(d) : U32}}, +hi: {{Nat.is_lt(j, {P_}(d)) == True{{}} : Bool}}, +hj: {{U32.to_nat(i) == j : Nat}}, +hz: {{z == U32.is_lt(i, U32.shr(n)) : Bool}},
    pf: TA.tperf({T}, d, a))
    -> {ZA('a', 'n', 'i', 'j', 'z', 'd')}:
  match d a z:
    case 0n ALeaf{{x}} _: ({{==}}, ({{==}}, ({{==}}, ({{==}}, ({{==}}, {{==}})))))
    case 0n ANode{{xs, ys}} _: Empty.absurd({ZA('ANode{xs, ys}', 'n', 'i', 'j', 'z', '0n')}, pf)
    case 1n+p ALeaf{{x}} _: Empty.absurd({ZA('ALeaf{x}', 'n', 'i', 'j', 'z', '1n+p')}, pf)
    case 1n+p ANode{{xs, ys}} True{{}}:
      (pl, pr) = pf
      tfzrs_nl_{c}(p, xs, ys, n, i, j, w, hd, hn, hi, hj, hz, {left}, tfzsp_{c}(p, ys, pr))
    case 1n+p ANode{{xs, ys}} False{{}}:
      (pl, pr) = pf
      tfzrs_nr_{c}(p, xs, ys, n, i, j, w, hd, hn, hi, hj, hz, {right}, tfzsp_{c}(p, xs, pl))
""")
    # the tree of a perfect tree's array is perfect
    out.append(f"""def amperf_{c}(+d: Nat, +t: {TR}, +pf: {{F.array__perfect({MB}, d, t) == True{{}} : Bool}}) -> TA.tperf({T}, d, {AM}(t)):
  match d t:
    case 0n F.TLeaf{{x}}: {{==}}
    case 0n F.TNode{{l, r}}: Empty.absurd(TA.tperf({T}, 0n, {AM}(F.TNode{{l, r}})), F.logic__false_true(pf))
    case 1n+p F.TLeaf{{x}}: Empty.absurd(TA.tperf({T}, 1n+p, {AM}(F.TLeaf{{x}})), F.logic__false_true(pf))
    case 1n+p F.TNode{{l, r}}: (amperf_{c}(p, l, F.array__pf_left({MB}, p, l, r, pf)), amperf_{c}(p, r, F.array__pf_right({MB}, p, l, r, pf)))
""")
    # the view of the frozen tree after the update
    SLU = 'F.array__slots(%s, F.array__upd(%s, d, t, J, e))' % (MB, MB)
    FT = lambda x: 'F.array__freeze(%s, F.array__thaw(%s, %s))' % (MB, MB, x)
    UPD = 'F.array__upd(%s, d, t, J, e)' % MB
    UPDC = 'F.array__upd(%s, d, t, c, e)' % MB
    out.append(f"""def view_set_t_{c}(+c: Nat, +d: Nat, +t: {TR}, +J: Nat, +e: {MB}, +hJ: {{Nat.is_lt(J, {P_}(d)) == True{{}} : Bool}}, +pf: {{F.array__perfect({MB}, d, t) == True{{}} : Bool}})
    -> {{S.Sequence{{RT.xi_{c}(c, {SLU}, 0n)}} == VS.field_set(S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, t), 0n)}}, J, {VQ}.vm_{c}(e)) : S.Value}}:
  %Equal.sym({TR}, {UPD}, {FT(UPD)}, Equal.sym({TR}, {FT(UPD)}, {UPD}, F.array__freeze_thaw({MB}, {UPD}))) :
    {{S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, _), 0n)}} == VS.field_set(S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, t), 0n)}}, J, {VQ}.vm_{c}(e)) : S.Value}}
  %Equal.sym({TR}, t, {FT('t')}, Equal.sym({TR}, {FT('t')}, t, F.array__freeze_thaw({MB}, t))) :
    {{S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, {FT(UPD)}), 0n)}} == VS.field_set(S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, _), 0n)}}, J, {VQ}.vm_{c}(e)) : S.Value}}
  {VQ}.{c}_view_set(c, d, t, J, e, hJ, pf)

def view_app_t_{c}(+c: Nat, +c2: Nat, +d: Nat, +t: {TR}, +e: {MB}, +hJ: {{Nat.is_lt(c, {P_}(d)) == True{{}} : Bool}}, +hc2: {{c2 == 1n+c : Nat}}, +pf: {{F.array__perfect({MB}, d, t) == True{{}} : Bool}})
    -> {{S.Sequence{{RT.xi_{c}(c2, F.array__slots({MB}, {UPDC}), 0n)}} == VS.seq_append(S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, t), 0n)}}, {VQ}.vm_{c}(e)) : S.Value}}:
  %Equal.sym({TR}, {UPDC}, {FT(UPDC)}, Equal.sym({TR}, {FT(UPDC)}, {UPDC}, F.array__freeze_thaw({MB}, {UPDC}))) :
    {{S.Sequence{{RT.xi_{c}(c2, F.array__slots({MB}, _), 0n)}} == VS.seq_append(S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, t), 0n)}}, {VQ}.vm_{c}(e)) : S.Value}}
  %Equal.sym({TR}, t, {FT('t')}, Equal.sym({TR}, {FT('t')}, t, F.array__freeze_thaw({MB}, t))) :
    {{S.Sequence{{RT.xi_{c}(c2, F.array__slots({MB}, {FT(UPDC)}), 0n)}} == VS.seq_append(S.Sequence{{RT.xi_{c}(c, F.array__slots({MB}, _), 0n)}}, {VQ}.vm_{c}(e)) : S.Value}}
  {VQ}.{c}_view_app(c, c2, d, t, e, hJ, hc2, pf)
""")
    return '\n'.join(out)


def prefix(s):
    import re
    return re.sub(r'\b(MB|M_\w+|WMr)\b', lambda m: 'RT.' + m.group(1), s)


def zatype(c, a, n, i, j, w, z, d):
    """the type tfzrs_<c> returns for the array a written at (n, i, j, z): the frozen tree updated, perfect, and rs's facts"""
    for c_, T, MB, tfz, fz in lists():
        if c_ == c:
            break
    else:
        raise KeyError(c)
    MB, TFZ, FZ = prefix(MB), 'RT.' + tfz, 'RT.' + fz
    TR = 'F.array__Tree<%s>' % MB
    PUT = lambda a, n, i, w, z: 'TA.put(%s, %s, %s, %s, %s, %s)' % (T, a, n, i, w, z)
    SZB = lambda a, d: '{TA.sz(%s, %s) == %s(%s) : U32}' % (T, a, U_, d)
    RS4 = ('{Array.swap.go(%s, %s, %s, %s, %s, %s) == (%s, TA.old(%s, %s, %s, %s, %s)) : Array<%s> & %s} & ({Array.size(%s, %s) == (%s, TA.sz(%s, %s)) : Array<%s> & U32} & '
           '({Array.size(%s, %s) == (%s, TA.sz(%s, %s)) : Array<%s> & U32} & (%s)))'
           % (T, a, n, i, w, z, PUT(a, n, i, w, z), T, a, n, i, z, T, T, T, a, a, T, a, T, T, PUT(a, n, i, w, z), PUT(a, n, i, w, z), T, a, T, SZB(a, d)))
    EQ = '{%s(%s) == F.array__tupd(%s, %s, %s(%s), %s, %s(%s), F.array__ndec(%s, %s)) : %s}' % (TFZ, PUT(a, n, i, w, z), MB, d, TFZ, a, j, FZ, w, d, j, TR)
    PERF = '{F.array__perfect(%s, %s, %s(%s)) == True{} : Bool}' % (MB, d, TFZ, a)
    return '%s & (%s & (%s))' % (EQ, PERF, RS4)


OUT = ROOT / 'proofs/obj/tfz_boxed.bend'
RT = ROOT / 'proofs/obj/root_types_light.bend'
HEADER = '# GENERATED by boxedview (codegen). Do not edit.'


def lists():
    """(c, T, MB, tfz, fz) of every boxed list of root_types_light.bend"""
    import re
    t = RT.read_text()
    out = []
    for m in re.finditer(r'^def (tfz_(\w+))\(a: Array<(O\.Boxed<.*?>)>\) -> F\.array__Tree<(MB<\w+>)>:\n  match a:\n    case ALeaf\{x\}: F\.TLeaf\{(\w+)\(x\)\}', t, re.M):
        tfz, c, T, MB, fz = m.groups()
        out.append((c, T, MB, tfz, fz))
    return out


def text():
    import re
    ls = lists()
    aliases = sorted({a for _c, T, *_ in ls for a in re.findall(r'(\w+_d)\.', T)})
    out = ['import Base', 'import ./tarray.bend as TA', 'import ../../src/obj.bend as O', 'import ../compact/found.bend as F',
           'import ./root_types_light.bend as RT', 'import ./view_seq.bend as VQ', 'import ./value_set.bend as VS', 'import ../../types/schema.bend as S']
    for a in aliases:
        out.append('import ../../types/%s_def_generated.bend as %s' % (a[:-2], a))
    out += ['', HEADER, '# See codegen/proofs/collections/boxedview.py.', '']
    pre = lambda s: re.sub(r'\b(MB|M_\w+|WMr)\b', lambda m: 'RT.' + m.group(1), s)
    for c, T, MB, tfz, fz in ls:
        out.append('# ---- %s ----' % c)
        out.append(lemmas(c, T, pre(MB), 'RT.' + tfz, 'RT.' + fz, 'RT.am_' + c, 'VQ'))
    return '\n'.join(out)


def main():
    run_single('boxedview', OUT, text(), '--check' in sys.argv)


if __name__ == '__main__':
    main()
