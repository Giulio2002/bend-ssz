#!/usr/bin/env python3
"""Byte-offset windows of lists of variable-size elements (List[C, N], C a
container with a byte-offset window module): the interface of
proofs/obj/vua_win.bend.

    python3 codegen/proofs/var/container_list_offset_windows.py [--check]

The runtime reads the first offset O0; with O0 = 4 m it walks the m element
windows [O_i, O_(i+1)) (the last one ends at len). The laws are proved per
element count m = 1 .. N (the count is a literal in each case, so the
runtime's walk unrolls): the validator's Bool is CK_m, the reader's object
OBJ_m, the spec value VAL_m, and the inversion recovers m from the value.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys
from codegen.core import generated_file_writer as writer  # noqa: E402

from codegen.proofs.var import single_list_container_codec_laws as VL  # noqa: E402
from codegen.proofs.var import nested_type_window_laws as W  # noqa: E402
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('container_list_offset_windows', globals())

ROOT = VL.ROOT

# (list runtime prefix, count limit N, child runtime prefix, child window module)
LISTS = [('l1_AttesterSlashing', 1, 'AttesterSlashing', 'var_winx_AttesterSlashing.bend'),
         ('l8_Attestation', 8, 'Attestation', 'var_winx_Attestation.bend')]

CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
      '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
      '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
PW = 'A.quad(VB.pw(d))'
BUF = 'BF(t, n)'
MP = 'Maybe<&2, +List<S.Part>>'


def pos(c):
    return 'x' if c == 0 else f'{c}n+x'


def O(j):
    return f'O{j}(t, x)'


def B_(m, i):
    """End of element i of m."""
    return O(i + 1) if i + 1 < m else 'len'


def D_(i, m):
    return f'D{m}_{i}(t, x, off, len)'


def okv(m, i):
    return f'Bool.and(AC{m}_{i}(t, x, off, len), Bool.and(U32.is_le({O(i)}, {B_(m, i)}), U32.is_le({B_(m, i)}, len)))'


def header_defs(LP, N, C):
    L = []
    w = L.append
    for j in range(N):
        w(f'def O{j}(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, {pos(4 * j)})')
    w('')
    w(TEMPLATES.render('header_defs', N=N))
    for m in range(1, N + 1):
        for i in range(m):
            w(f'def D{m}_{i}(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: '
              f'CH.CHKw(t, Nat.add(U32.to_nat({O(i)}), x), U32.add(off, {O(i)}), U32.sub({B_(m, i)}, {O(i)}))')
        w(f'def AC{m}_0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: True{{}}')
        for i in range(m):
            w(f'def AC{m}_{i + 1}(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: '
              f'Bool.and(AC{m}_{i}(t, x, off, len), EW({okv(m, i)}, {D_(i, m)}))')
        w('')
    w('def LOOP(q: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:')
    w('  match q:')
    w('    case 0n: False{}')
    for m in range(1, N + 1):
        w(f'    case {m}n: AC{m}_{m}(t, x, off, len)')
    w(f'    case {N + 1}n+r: False{{}}')
    w('''
def HK(h: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  match h:
    case True{}: LOOP(NQ(t, x), t, x, off, len)
    case False{}: False{}

def L4(s: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  match s:
    case True{}: False{}
    case False{}: HK(HC(t, x, len), t, x, off, len)

def LZ(z: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  match z:
    case True{}: True{}
    case False{}: L4(U32.is_lt(len, 4), t, x, off, len)

# Empty, or at least 4 bytes, a first offset 4 m with 1 <= m <= N inside the
# window, and the m element windows pass (CK_m = AC_m_m).
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: LZ(U32.is_eq(len, 0), t, x, off, len)
''')
    return '\n'.join(L)


def common_lemmas(LP, N, C):
    return TEMPLATES.render('common_lemmas', LP=LP, C=C, N=N)


def validator(LP, N, C):
    L = []
    w = L.append
    # per count m: the runtime walk after the first offset, when shrn(O0, 2) = m
    for m in range(1, N + 1):
        CK = f'AC{m}_{m}(t, x, off, len)'
        hyp = (f'+hf: {{Nat.is_le(Nat.add({4 * m}n, 0n), U32.to_nat(len)) == True{{}} : Bool}}')
        w(f'def walk{m}({CW}, {hyp})')
        n1 = f'T.{LP}_next(U32.is_eq(1, {m}), {BUF}, off, len, 0)'
        w(f'    -> {{T.{LP}_ev({m - 1}n, 0, {m}, off, len, T.{LP}_ee(True{{}}, off, len, {O(0)}, {n1})) == ({BUF}, {CK}) : B.Buf & Bool}}:')
        acc = 'True{}'
        for i in range(m):
            b = B_(m, i)
            ev = f'T.{LP}_ev({m - 1 - i}n, {i}, {m}, off, len, {{}})'
            if i + 1 < m:
                c = 4 * (i + 1)
                # the read of offset i + 1 at off + 4 (i + 1)
                hole = f'T.{LP}_ee({acc}, off, len, {O(i)}, _)'
                w(f'  %Equal.sym(B.Buf & U32, B.read32({BUF}, U32.add(off, {c})), ({BUF}, {O(i + 1)}), rdo({CWA}, {c}, {c}n, {{==}}, '
                  f'FD.nat__le_trans(Nat.add({c}n, 4n), {4 * m}n, U32.to_nat(len), {{==}}, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == True{{}} : Bool}}, Nat.add({4 * m}n, 0n), {4 * m}n, FD.nat__add_zero({4 * m}n), hf)))) :')
                w(f'    {{{ev.format(hole)} == ({BUF}, {CK}) : B.Buf & Bool}}')
            ok = okv(m, i).replace(f'AC{m}_{i}(t, x, off, len)', acc) if i == 0 else okv(m, i)
            hole = f'T.{LP}_eb({b}, O.and_pair({acc}, _))'
            w(f'  %Equal.sym(B.Buf & Bool, T.{LP}_ew({ok}, {BUF}, off, {O(i)}, {b}), ({BUF}, EW({ok}, {D_(i, m)})), ewl({CWA}, {acc}, {O(i)}, {b}, {ok}, {{==}})) :')
            w(f'    {{{ev.format(hole)} == ({BUF}, {CK}) : B.Buf & Bool}}')
            acc = f'AC{m}_{i + 1}(t, x, off, len)'
        w('  {==}')
        w('')
    # the dispatch on the count
    w(f'def walkq({CW}, +q: Nat, +eq: {{NQ(t, x) == q : Nat}}, +h4: {{Nat.is_le(4n, U32.to_nat({O(0)})) == True{{}} : Bool}},')
    w(f'    +hq: {{Nat.is_le(q, {N}n) == True{{}} : Bool}}, +e3: {{U32.and({O(0)}, 3) == 0 : U32}}, +hfl: {{Nat.is_le(U32.to_nat({O(0)}), U32.to_nat(len)) == True{{}} : Bool}})')
    w(f'    -> {{T.{LP}_first(True{{}}, {BUF}, off, len, {O(0)}) == ({BUF}, LOOP(q, t, x, off, len)) : B.Buf & Bool}}:')
    w('  match q:')
    w(f'    case 0n: Empty.absurd({{T.{LP}_first(True{{}}, {BUF}, off, len, {O(0)}) == ({BUF}, LOOP(0n, t, x, off, len)) : B.Buf & Bool}}, FD.logic__false_true(FD.logic__subst(Nat, z => {{Nat.is_le(4n, z) == True{{}} : Bool}}, U32.to_nat({O(0)}), 0n, Equal.trans(Nat, U32.to_nat({O(0)}), Nat.add(A.quad(NQ(t, x)), 0n), 0n, e4q(t, x, e3), Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), 0n), NQ(t, x), 0n, eq)), h4)))')
    for m in range(1, N + 1):
        w(f'    case {m}n:')
        w(f'      +em = FD.u32__injective(U32.shrn({O(0)}, 2n), {m}, eq)')
        w(f'      %Equal.sym(U32, U32.shrn({O(0)}, 2n), {m}, em) :')
        w(f'        {{T.{LP}_ev(U32.to_nat(U32.sub(_, 1)), 0, _, off, len, T.{LP}_ee(True{{}}, off, len, {O(0)}, T.{LP}_next(U32.is_eq(1, _), {BUF}, off, len, 0))) == ({BUF}, AC{m}_{m}(t, x, off, len)) : B.Buf & Bool}}')
        w(f'      walk{m}({CWA}, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == True{{}} : Bool}}, U32.to_nat({O(0)}), Nat.add({4 * m}n, 0n), '
          f'Equal.trans(Nat, U32.to_nat({O(0)}), Nat.add(A.quad(NQ(t, x)), 0n), Nat.add({4 * m}n, 0n), e4q(t, x, e3), Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), 0n), NQ(t, x), {m}n, eq)), hfl))')
    w(f'    case {N + 1}n+r: Empty.absurd({{T.{LP}_first(True{{}}, {BUF}, off, len, {O(0)}) == ({BUF}, LOOP({N + 1}n+r, t, x, off, len)) : B.Buf & Bool}}, FD.logic__false_true(hq))')
    w('')
    return '\n'.join(L)


def facts_lets(m, indent='  '):
    """Lets deriving, from ha{m}: AC{m}_{m} == True, the per-element facts
    hk_i (child check), hab_i (O_i <= B_i), hbl_i (B_i <= len)."""
    L = []
    for i in range(m - 1, -1, -1):
        AC = f'AC{m}_{i}(t, x, off, len)'
        EWt = f'EW({okv(m, i)}, {D_(i, m)})'
        L.append(f'{indent}+ew{i} = and_r({AC}, {EWt}, ha{i + 1})')
        L.append(f'{indent}+ha{i} = and_l({AC}, {EWt}, ha{i + 1})')
        L.append(f'{indent}+ok{i} = ew_l({okv(m, i)}, {D_(i, m)}, ew{i})')
        L.append(f'{indent}+hk{i} = ew_r({okv(m, i)}, {D_(i, m)}, ew{i})')
        L.append(f'{indent}+rg{i} = and_r({AC}, Bool.and(U32.is_le({O(i)}, {B_(m, i)}), U32.is_le({B_(m, i)}, len)), ok{i})')
        L.append(f'{indent}+hab{i} = le_nat({O(i)}, {B_(m, i)}, and_l(U32.is_le({O(i)}, {B_(m, i)}), U32.is_le({B_(m, i)}, len), rg{i}))')
        L.append(f'{indent}+hbl{i} = le_nat({B_(m, i)}, len, and_r(U32.is_le({O(i)}, {B_(m, i)}), U32.is_le({B_(m, i)}, len), rg{i}))')
    return '\n'.join(L)


def CHOBJ(m, i):
    return f'CH.OBJw(d, t, Nat.add(U32.to_nat({O(i)}), x), U32.add(off, {O(i)}), U32.sub({B_(m, i)}, {O(i)}))'


def ARR(LP, C, m, i):
    a = f'T.{LP}_fill(T.{LP}_cap({m}))'
    for j in range(i):
        a = f'Array.set(O.Boxed<T.{C}>, {a}, {j}, O.BSome{{{CHOBJ(m, j)}, O.BNone{{}}}})'
    return a


READER_TAIL = TEMPLATES.text('READER_TAIL')

READER_TOP = TEMPLATES.text('READER_TOP')


def subst(txt, LP, N):
    return txt.replace('@CWA', CWA).replace('@CW', CW).replace('@LP', LP).replace('@N', str(N))


def reader(LP, N, C):
    L = []
    w = L.append
    for m in range(1, N + 1):
        w(f'def OBJ{m}(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.{LP}_Seq: T.{LP}_Seq{{{ARR(LP, C, m, m)}, {m}}}')
    w('')
    w(f'def RQ(q: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.{LP}_Seq:')
    w('  match q:')
    for m in range(1, N + 1):
        w(f'    case {m}n: OBJ{m}(d, t, x, off, len)')
    w(f'    case _: T.{LP}_Seq{{T.{LP}_fill(0n), 0}}')
    w(subst(READER_TAIL, LP, N))
    for m in range(1, N + 1):
        RHS = f'({BUF}, OBJ{m}(d, t, x, off, len))'
        TY = f'B.Buf & T.{LP}_Seq'
        hf = f'+hf: {{Nat.is_le(Nat.add({4 * m}n, 0n), U32.to_nat(len)) == True{{}} : Bool}}'
        w(f'def rdm{m}({CW}, {hf}, +ha{m}: {{AC{m}_{m}(t, x, off, len) == True{{}} : Bool}})')
        w(f'    -> {{T.{LP}_rv_fin({m}, T.{LP}_rv({m - 1}n, 0, off, len, {m}, T.{LP}_fill(T.{LP}_cap({m})), T.{LP}_elem(off, T.{LP}_win_start(off, len, 0, {m}, B.read32({BUF}, off))))) == {RHS} : {TY}}}:')
        w(facts_lets(m))
        w(f'  +hf2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == True{{}} : Bool}}, Nat.add({4 * m}n, 0n), {4 * m}n, FD.nat__add_zero({4 * m}n), hf)')
        for i in range(m):
            outer = f'T.{LP}_rv_fin({m}, T.{LP}_rv({m - 1 - i}n, {i}, off, len, {m}, {ARR(LP, C, m, i)}, @H))'
            if i == 0:
                rd = (f'UR.rwx(d, t, n, off, x, eo, FD.nat__lt_trans(d, 28n, 31n, hd, {{==}}), pf, '
                      f'UR.roomw(x, U32.to_nat(len), 0n, {PW}, hw, FD.nat__le_trans(4n, {4 * m}n, U32.to_nat(len), {{==}}, hf2)))')
                cur = f'B.read32({BUF}, off)'
            else:
                rd = f'rdo({CWA}, {4 * i}, {4 * i}n, {{==}}, FD.nat__le_trans(Nat.add({4 * i}n, 4n), {4 * m}n, U32.to_nat(len), {{==}}, hf2))'
                cur = f'B.read32({BUF}, U32.add(off, {4 * i}))'
            w(f'  %Equal.sym(B.Buf & U32, {cur}, ({BUF}, {O(i)}), {rd}) :')
            w(f'    {{{outer.replace("@H", f"T.{LP}_elem(off, T.{LP}_win_start(off, len, {i}, {m}, _))")} == {RHS} : {TY}}}')
            if i + 1 < m:
                c = 4 * (i + 1)
                rd = f'rdo({CWA}, {c}, {c}n, {{==}}, FD.nat__le_trans(Nat.add({c}n, 4n), {4 * m}n, U32.to_nat(len), {{==}}, hf2))'
                w(f'  %Equal.sym(B.Buf & U32, B.read32({BUF}, U32.add(off, {c})), ({BUF}, {O(i + 1)}), {rd}) :')
                w(f'    {{{outer.replace("@H", f"T.{LP}_elem(off, T.{LP}_win_end({O(i)}, _))")} == {RHS} : {TY}}}')
            b = B_(m, i)
            w(f'  %Equal.sym(B.Buf & T.{C}, T.{C}_read({BUF}, U32.add(off, {O(i)}), U32.sub({b}, {O(i)})), ({BUF}, {CHOBJ(m, i)}),')
            w(f'      CH.readw(d, t, n, Nat.add(U32.to_nat({O(i)}), x), U32.add(off, {O(i)}), U32.sub({b}, {O(i)}), eoj({CWA}, {O(i)}, FD.nat__le_trans(U32.to_nat({O(i)}), U32.to_nat({b}), U32.to_nat(len), hab{i}, hbl{i})), hd,')
            w(f'        hwj({CWA}, {O(i)}, {b}, hab{i}, hbl{i}), pf, hk{i})) :')
            w(f'    {{{outer.replace("@H", f"T.{C}_bx_rd(_)")} == {RHS} : {TY}}}')
        w('  {==}')
        w('')
    w(f'def rdq({CW}, +q: Nat, +eq: {{NQ(t, x) == q : Nat}}, +e3: {{U32.and({O(0)}, 3) == 0 : U32}}, +hl: {{LOOP(q, t, x, off, len) == True{{}} : Bool}},')
    w(f'    +hfl: {{Nat.is_le(U32.to_nat({O(0)}), U32.to_nat(len)) == True{{}} : Bool}})')
    w(f'    -> {{T.{LP}_rv_count(off, len, ({BUF}, {O(0)})) == ({BUF}, RQ(q, d, t, x, off, len)) : B.Buf & T.{LP}_Seq}}:')
    w('  match q:')
    w(f'    case 0n: Empty.absurd({{T.{LP}_rv_count(off, len, ({BUF}, {O(0)})) == ({BUF}, RQ(0n, d, t, x, off, len)) : B.Buf & T.{LP}_Seq}}, FD.logic__false_true(hl))')
    for m in range(1, N + 1):
        w(f'    case {m}n:')
        w(f'      +em = FD.u32__injective(U32.shrn({O(0)}, 2n), {m}, eq)')
        w(f'      %Equal.sym(U32, U32.shrn({O(0)}, 2n), {m}, em) :')
        w(f'        {{T.{LP}_rv_fin(_, T.{LP}_rv(U32.to_nat(U32.sub(_, 1)), 0, off, len, _, T.{LP}_fill(T.{LP}_cap(_)), T.{LP}_elem(off, T.{LP}_win_start(off, len, 0, _, B.read32({BUF}, off))))) == ({BUF}, OBJ{m}(d, t, x, off, len)) : B.Buf & T.{LP}_Seq}}')
        w(f'      rdm{m}({CWA}, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == True{{}} : Bool}}, U32.to_nat({O(0)}), Nat.add({4 * m}n, 0n), '
          f'Equal.trans(Nat, U32.to_nat({O(0)}), Nat.add(A.quad(NQ(t, x)), 0n), Nat.add({4 * m}n, 0n), e4q(t, x, e3), Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), 0n), NQ(t, x), {m}n, eq)), hfl), hl)')
    w(f'    case {N + 1}n+r: Empty.absurd({{T.{LP}_rv_count(off, len, ({BUF}, {O(0)})) == ({BUF}, RQ({N + 1}n+r, d, t, x, off, len)) : B.Buf & T.{LP}_Seq}}, FD.logic__false_true(hl))')
    w(subst(READER_TOP, LP, N))
    return '\n'.join(L)


def nat_o(i):
    return f'U32.to_nat({O(i)})'


def l_(m, i):
    """Length (Nat) of element i of m, element 0 with O0 = 4 m."""
    if i == 0:
        return f'U32.to_nat(U32.sub({B_(m, 0)}, {4 * m}))'
    return f'U32.to_nat(U32.sub({B_(m, i)}, {O(i)}))'


def J_(m, i):
    return f'{4 * m}n+x' if i == 0 else f'Nat.add({nat_o(i)}, x)'


def Y_(m, i):
    return f'UW.WX(t, {J_(m, i)}, {l_(m, i)})'


def S_(m, i):
    s = l_(m, m - 1)
    for k in range(m - 2, i - 1, -1):
        s = f'Nat.add({l_(m, k)}, {s})'
    return s


def off_(m, j):
    """The spec's offset of element j (j >= 1): 4 m + l_0 + .. + l_(j-1), left nested."""
    s = f'{4 * m}n'
    for k in range(j):
        s = f'Nat.add({s}, {l_(m, k)})'
    return s


def OFF_(m, j):
    """The same with the payloads' lengths (the spec layout's own terms)."""
    s = f'{4 * m}n'
    for k in range(j):
        s = f'Nat.add({s}, List.length(&2, U32, {Y_(m, k)}))'
    return s


def PL_(m):
    return '[' + ', '.join(f'S.Variable{{{Y_(m, i)}}}' for i in range(m)) + ']'


def PAY(m):
    """The payloads, right nested (as after the splits)."""
    s = Y_(m, m - 1)
    for i in range(m - 2, -1, -1):
        s = f'List.append(&2, U32, {Y_(m, i)}, {s})'
    return s


def eo_lines(w, m, F):
    # eO_i (i >= 1): o_i == Nat.add(o_(i-1), l_(i-1)) (o_0 as Fn)
    for i in range(1, m):
        prev = f'{F}n' if i == 1 else nat_o(i - 1)
        h = 'h0b' if i == 1 else f'hab{i - 1}'
        sub = f'U32.sub({O(i)}, {F if i == 1 else O(i - 1)})'
        w(f'  +eO{i} = Equal.trans(Nat, {nat_o(i)}, Nat.add({prev}, Nat.sub({nat_o(i)}, {prev})), Nat.add({prev}, {l_(m, i - 1)}),')
        w(f'    Equal.sym(Nat, Nat.add({prev}, Nat.sub({nat_o(i)}, {prev})), {nat_o(i)}, FD.nat__sub_add({nat_o(i)}, {prev}, {h})),')
        w(f'    Equal.cong(Nat, Nat, z => Nat.add({prev}, z), Nat.sub({nat_o(i)}, {prev}), {l_(m, i - 1)}, Equal.sym(Nat, U32.to_nat({sub}), Nat.sub({nat_o(i)}, {prev}), FD.u32__sub_nat({O(i)}, {F if i == 1 else O(i - 1)}, {h}))))')


def e_lines(w, m, F):
    lastp = f'{F}n' if m == 1 else nat_o(m - 1)
    if m == 1:
        hl = f'FD.logic__subst(U32, z => {{Nat.is_le(U32.to_nat(z), U32.to_nat(len)) == True{{}} : Bool}}, {O(0)}, {F}, e0, hab0)'
        subl = f'U32.sub(len, {F})'
    else:
        hl = f'hab{m - 1}'
        subl = f'U32.sub(len, {O(m - 1)})'
    w(f'  +E{m - 1} = Equal.trans(Nat, U32.to_nat(len), Nat.add({lastp}, Nat.sub(U32.to_nat(len), {lastp})), Nat.add({lastp}, {l_(m, m - 1)}),')
    w(f'    Equal.sym(Nat, Nat.add({lastp}, Nat.sub(U32.to_nat(len), {lastp})), U32.to_nat(len), FD.nat__sub_add(U32.to_nat(len), {lastp}, {hl})),')
    w(f'    Equal.cong(Nat, Nat, z => Nat.add({lastp}, z), Nat.sub(U32.to_nat(len), {lastp}), {l_(m, m - 1)}, Equal.sym(Nat, U32.to_nat({subl}), Nat.sub(U32.to_nat(len), {lastp}), FD.u32__sub_nat(len, {F if m == 1 else O(m - 1)}, {hl}))))')
    for k in range(m - 2, -1, -1):
        ok_ = f'{F}n' if k == 0 else nat_o(k)
        w(f'  +E{k} = Equal.trans(Nat, U32.to_nat(len), Nat.add({nat_o(k + 1)}, {S_(m, k + 1)}), Nat.add({ok_}, {S_(m, k)}), E{k + 1},')
        w(f'    Equal.trans(Nat, Nat.add({nat_o(k + 1)}, {S_(m, k + 1)}), Nat.add(Nat.add({ok_}, {l_(m, k)}), {S_(m, k + 1)}), Nat.add({ok_}, {S_(m, k)}),')
        w(f'      Equal.cong(Nat, Nat, z => Nat.add(z, {S_(m, k + 1)}), {nat_o(k + 1)}, Nat.add({ok_}, {l_(m, k)}), eO{k + 1}), FD.nat__add_assoc({ok_}, {l_(m, k)}, {S_(m, k + 1)})))')


def spec_m(LP, N, C, m, ESCH, LSCH, LIMN):
    F = 4 * m
    L = []
    w = L.append
    FH = f'+hf: {{Nat.is_le(Nat.add({F}n, 0n), U32.to_nat(len)) == True{{}} : Bool}}'
    EH = f'+e0: {{{O(0)} == {F} : U32}}'
    HA = f'+ha{m}: {{AC{m}_{m}(t, x, off, len) == True{{}} : Bool}}'
    # the range facts in literal form (O0 = F)
    lets = facts_lets(m)
    w(f'def elen{m}({CW}, {FH}, {EH}, {HA})')
    w(f'    -> {{U32.to_nat(len) == Nat.add({F}n, {S_(m, 0)}) : Nat}}:')
    w(lets)
    w(f'  +h0b = FD.logic__subst(U32, z => {{Nat.is_le(U32.to_nat(z), U32.to_nat({B_(m, 0)})) == True{{}} : Bool}}, {O(0)}, {F}, e0, hab0)')
    eo_lines(w, m, F)
    e_lines(w, m, F)
    w('  E0')
    w('')
    w(f'def enc{m}({CW}, {FH}, {EH}, {HA})')
    w(f'    -> {{List.append(&2, U32, Layout.fixed_parts({PL_(m)}, {F}n), Layout.payloads({PL_(m)})) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}}:')
    w(lets)
    w(f'  +h0b = FD.logic__subst(U32, z => {{Nat.is_le(U32.to_nat(z), U32.to_nat({B_(m, 0)})) == True{{}} : Bool}}, {O(0)}, {F}, e0, hab0)')
    eo_lines(w, m, F)
    w(f'  +E0 = elen{m}({CWA}, hf, e0, ha{m})')
    # eJ_i: Nat.add(l_(i-1), P_(i-1)) == J_i
    for i in range(1, m):
        if i == 1:
            w(f'  +eJ1 = Equal.trans(Nat, Nat.add({l_(m, 0)}, {F}n+x), Nat.add({F}n, Nat.add({l_(m, 0)}, x)), Nat.add({nat_o(1)}, x),')
            w(f'    FD.lru_nat_algebra__add_swap({l_(m, 0)}, {F}n, x), Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add({F}n, {l_(m, 0)}), {nat_o(1)}, Equal.sym(Nat, {nat_o(1)}, Nat.add({F}n, {l_(m, 0)}), eO1)))')
        else:
            a, lo = nat_o(i - 1), l_(m, i - 1)
            w(f'  +eJ{i} = Equal.trans(Nat, Nat.add({lo}, Nat.add({a}, x)), Nat.add({a}, Nat.add({lo}, x)), Nat.add({nat_o(i)}, x),')
            w(f'    FD.lru_nat_algebra__add_swap({lo}, {a}, x), Equal.trans(Nat, Nat.add({a}, Nat.add({lo}, x)), Nat.add(Nat.add({a}, {lo}), x), Nat.add({nat_o(i)}, x),')
            w(f'      Equal.sym(Nat, Nat.add(Nat.add({a}, {lo}), x), Nat.add({a}, Nat.add({lo}, x)), FD.nat__add_assoc({a}, {lo}, x)),')
            w(f'      Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add({a}, {lo}), {nat_o(i)}, Equal.sym(Nat, {nat_o(i)}, Nat.add({a}, {lo}), eO{i}))))')
    # hwY_i: J_i + l_i <= 4 2^d
    for i in range(m):
        if i == 0:
            w(f'  +hwY0 = hwj({CWA}, {F}, {B_(m, 0)}, h0b, hbl0)')
        else:
            w(f'  +hwY{i} = hwj({CWA}, {O(i)}, {B_(m, i)}, hab{i}, hbl{i})')
    # eoffq_j: OFF_j == o_j (j >= 1)
    for j in range(1, m):
        # OFF_j (lens) == off_j (l's)
        if j == 1:
            w(f'  +eF1 = Equal.cong(Nat, Nat, z => Nat.add({F}n, z), List.length(&2, U32, {Y_(m, 0)}), {l_(m, 0)}, UW.lenWX(d, t, {J_(m, 0)}, {l_(m, 0)}, pf, hwY0))')
        else:
            w(f'  +eF{j} = Equal.trans(Nat, {OFF_(m, j)}, Nat.add({off_(m, j - 1)}, List.length(&2, U32, {Y_(m, j - 1)})), {off_(m, j)},')
            w(f'    Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, {Y_(m, j - 1)})), {OFF_(m, j - 1)}, {off_(m, j - 1)}, eF{j - 1}),')
            w(f'    Equal.cong(Nat, Nat, z => Nat.add({off_(m, j - 1)}, z), List.length(&2, U32, {Y_(m, j - 1)}), {l_(m, j - 1)}, UW.lenWX(d, t, {J_(m, j - 1)}, {l_(m, j - 1)}, pf, hwY{j - 1})))')
        # off_j == o_j
        if j == 1:
            w(f'  +eo1 = Equal.sym(Nat, {nat_o(1)}, {off_(m, 1)}, eO1)')
        else:
            w(f'  +eo{j} = Equal.trans(Nat, {off_(m, j)}, Nat.add({nat_o(j - 1)}, {l_(m, j - 1)}), {nat_o(j)},')
            w(f'    Equal.cong(Nat, Nat, z => Nat.add(z, {l_(m, j - 1)}), {off_(m, j - 1)}, {nat_o(j - 1)}, eo{j - 1}), Equal.sym(Nat, {nat_o(j)}, Nat.add({nat_o(j - 1)}, {l_(m, j - 1)}), eO{j}))')
        w(f'  +eq{j} = Equal.trans(Nat, {OFF_(m, j)}, {off_(m, j)}, {nat_o(j)}, eF{j}, eo{j})')
    LSX = f'List.append(&2, U32, Layout.fixed_parts({PL_(m)}, {F}n), Layout.payloads({PL_(m)}))'
    # 1. len -> Nat.add(Fn, S_0)
    w(f'  +hw2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), {PW}) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({F}n, {S_(m, 0)}), E0, hw)')
    w(f'  %Equal.sym(Nat, U32.to_nat(len), Nat.add({F}n, {S_(m, 0)}), E0) : {{{LSX} == UW.WX(t, x, _) : +List<U32>}}')
    # 2. headWX
    RWS = f'F.limbs(UR.RWS({m}n, t, x))'
    w(f'  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad({m}n), {S_(m, 0)})), List.append(&2, U32, {RWS}, UW.WX(t, Nat.add(A.quad({m}n), x), {S_(m, 0)})),')
    w(f'      UW.headWX(d, t, x, {m}n, {S_(m, 0)}, pf, hw2)) :')
    w(f'    {{{LSX} == _ : +List<U32>}}')
    # 3/4. splits and positions

    def rhs_pay(k, hole):
        # Y_0 .. Y_(k-1) then the hole
        sx = hole
        for i in range(k - 1, -1, -1):
            sx = f'List.append(&2, U32, {Y_(m, i)}, {sx})'
        return sx
    for i in range(m - 1):
        P = J_(m, i)
        w(f'  %Equal.sym(+List<U32>, UW.WX(t, {P}, {S_(m, i)}), List.append(&2, U32, UW.WX(t, {P}, {l_(m, i)}), UW.WX(t, Nat.add({l_(m, i)}, {P}), {S_(m, i + 1)})), UW.splitWX(t, {P}, {l_(m, i)}, {S_(m, i + 1)})) :')
        w(f'    {{{LSX} == List.append(&2, U32, {RWS}, {rhs_pay(i, "_")}) : +List<U32>}}')
        w(f'  %Equal.sym(Nat, Nat.add({l_(m, i)}, {P}), {J_(m, i + 1)}, eJ{i + 1}) :')
        w(f'    {{{LSX} == List.append(&2, U32, {RWS}, {rhs_pay(i + 1, f"UW.WX(t, _, {S_(m, i + 1)})")}) : +List<U32>}}')
    # 5. header O0 -> F
    words = [O(j) for j in range(m)]
    PAYF = PAY(m)
    w(f'  %Equal.sym(U32, {O(0)}, {F}, e0) :')
    w(f'    {{{LSX} == List.append(&2, U32, F.limbs([{", ".join(["_"] + words[1:])}]), {PAYF}) : +List<U32>}}')

    def limbs_expl(items):
        sx = '[]'
        for it in reversed(items):
            sx = f'List.append(&2, U32, {it}, {sx})'
        return sx
    cur = [f'I.limb({F})'] + [f'I.limb({O(j)})' for j in range(1, m)]
    for j in range(1, m):
        h = list(cur)
        h[j] = '_'
        w(f'  %VG.digits_limb({O(j)}) :')
        w(f'    {{{LSX} == List.append(&2, U32, {limbs_expl(h)}, {PAYF}) : +List<U32>}}')
        cur[j] = f'N.digits(4n, {nat_o(j)})'
        h = list(cur)
        h[j] = 'N.digits(4n, _)'
        w(f'  %eq{j} :')
        w(f'    {{{LSX} == List.append(&2, U32, {limbs_expl(h)}, {PAYF}) : +List<U32>}}')
        cur[j] = f'N.digits(4n, {OFF_(m, j)})'
    # 9. the trailing [] of the payloads
    left = f'List.append(&2, U32, Layout.fixed_parts({PL_(m)}, {F}n), {rhs_pay(m - 1, "_")})'
    w(f'  %Equal.sym(+List<U32>, List.append(&2, U32, {Y_(m, m - 1)}, []), {Y_(m, m - 1)}, VS.app_nil({Y_(m, m - 1)})) :')
    w(f'    {{{left} == List.append(&2, U32, {limbs_expl(cur)}, {PAYF}) : +List<U32>}}')
    w('  {==}')
    w('')
    # the payloads' length
    w(f'def lpay{m}({CW}, {FH}, {EH}, {HA})')
    w(f'    -> {{U32.to_nat(len) == Nat.add({F}n, List.length(&2, U32, Layout.payloads({PL_(m)}))) : Nat}}:')
    w(lets)
    w(f'  +h0b = FD.logic__subst(U32, z => {{Nat.is_le(U32.to_nat(z), U32.to_nat({B_(m, 0)})) == True{{}} : Bool}}, {O(0)}, {F}, e0, hab0)')
    for i in range(m):
        if i == 0:
            w(f'  +hwY0 = hwj({CWA}, {F}, {B_(m, 0)}, h0b, hbl0)')
        else:
            w(f'  +hwY{i} = hwj({CWA}, {O(i)}, {B_(m, i)}, hab{i}, hbl{i})')

    def lens(k, hole, tail):
        # Nat.add(len Y_0, Nat.add(.., hole))
        sx = hole
        for i in range(k - 1, -1, -1):
            sx = f'Nat.add({tail(i)}, {sx})'
        return sx
    R = [None] * (m + 1)
    R[m - 1] = f'List.append(&2, U32, {Y_(m, m - 1)}, [])'
    for i in range(m - 2, -1, -1):
        R[i] = f'List.append(&2, U32, {Y_(m, i)}, {R[i + 1]})'
    LY = lambda i: f'List.length(&2, U32, {Y_(m, i)})'
    for i in range(m - 1):
        w(f'  %Equal.sym(Nat, List.length(&2, U32, {R[i]}), Nat.add({LY(i)}, List.length(&2, U32, {R[i + 1]})), VS.len_app({Y_(m, i)}, {R[i + 1]})) :')
        w(f'    {{U32.to_nat(len) == Nat.add({F}n, {lens(i, "_", LY)}) : Nat}}')
    w(f'  %Equal.sym(+List<U32>, {R[m - 1]}, {Y_(m, m - 1)}, VS.app_nil({Y_(m, m - 1)})) :')
    w(f'    {{U32.to_nat(len) == Nat.add({F}n, {lens(m - 1, "List.length(&2, U32, _)", LY)}) : Nat}}')
    for i in range(m):
        tl = lambda k: l_(m, k) if k < i else LY(k)
        # build the Nat nest with a hole at position i
        parts = [l_(m, k) if k < i else ('_' if k == i else LY(k)) for k in range(m)]
        sx = parts[-1]
        for k in range(m - 2, -1, -1):
            sx = f'Nat.add({parts[k]}, {sx})'
        w(f'  %Equal.sym(Nat, {LY(i)}, {l_(m, i)}, UW.lenWX(d, t, {J_(m, i)}, {l_(m, i)}, pf, hwY{i})) :')
        w(f'    {{U32.to_nat(len) == Nat.add({F}n, {sx}) : Nat}}')
    w(f'  elen{m}({CWA}, hf, e0, ha{m})')
    w('')
    return '\n'.join(L)


def items_(m, lit0):
    s = 'S.EmptyItems{}'
    for i in range(m - 1, -1, -1):
        if i == 0 and lit0:
            v = f'CH.VALw(t, {4 * m}n+x, U32.sub({B_(m, 0)}, {4 * m}))'
        else:
            v = f'CH.VALw(t, Nat.add({nat_o(i)}, x), U32.sub({B_(m, i)}, {O(i)}))'
        s = f'S.Items{{{v}, {s}}}'
    return s


def spec_top(LP, N, C, ESCH, LSCH, LIMN):
    L = []
    w = L.append
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    # an element's parts at the list schema's own name for the element schema
    # (the list unfolds to S.Repeat{ESCH}; CH.specw states Spec.<C>()): cast
    # once here, so the element steps compare syntactically
    MPX = 'Maybe<&2, +List<S.Part>>'
    w(f'def ecast(+v: S.Value, +ys: +List<U32>, +e: {{Codec.parts(v, Spec.{C}()) == Some{{[S.Variable{{ys}}]}} : {MPX}}})')
    w(f'    -> {{Codec.parts(v, {ESCH}) == Some{{[S.Variable{{ys}}]}} : {MPX}}}:')
    w(f'  %Equal.sym(S.Schema, {ESCH}, Spec.{C}(), {{==}}) : {{Codec.parts(v, _) == Some{{[S.Variable{{ys}}]}} : {MPX}}}')
    w('  e')
    w('')
    for m in range(1, N + 1):
        F = 4 * m
        FH = f'+hf: {{Nat.is_le(Nat.add({F}n, 0n), U32.to_nat(len)) == True{{}} : Bool}}'
        EH = f'+e0: {{{O(0)} == {F} : U32}}'
        HA = f'+ha{m}: {{AC{m}_{m}(t, x, off, len) == True{{}} : Bool}}'
        w(spec_m(LP, N, C, m, ESCH, LSCH, LIMN))
        w(f'def VAL{m}(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{{{items_(m, False)}}}')
        w('')
        LSX = f'List.append(&2, U32, Layout.fixed_parts({PL_(m)}, {F}n), Layout.payloads({PL_(m)}))'
        w(f'def specm{m}({CW}, {FH}, {EH}, {HA})')
        w(f'    -> {{Codec.parts(S.Sequence{{{items_(m, True)}}}, {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}:')
        w(facts_lets(m))
        w(f'  +h0b = FD.logic__subst(U32, z => {{Nat.is_le(U32.to_nat(z), U32.to_nat({B_(m, 0)})) == True{{}} : Bool}}, {O(0)}, {F}, e0, hab0)')
        w(f'  +hk08 = FD.logic__subst(U32, z => {{CH.CHKw(t, Nat.add(U32.to_nat(z), x), U32.add(off, z), U32.sub({B_(m, 0)}, z)) == True{{}} : Bool}}, {O(0)}, {F}, e0, hk0)')
        w(f'  +hfl = FD.nat__le_trans({F}n, U32.to_nat({B_(m, 0)}), U32.to_nat(len), h0b, hbl0)')
        for i in range(m):
            if i == 0:
                w(f'  +c0 = CH.specw(d, t, n, {F}n+x, U32.add(off, {F}), U32.sub({B_(m, 0)}, {F}), eoj({CWA}, {F}, hfl), hd, hwj({CWA}, {F}, {B_(m, 0)}, h0b, hbl0), pf, hk08)')
            else:
                w(f'  +c{i} = CH.specw(d, t, n, Nat.add({nat_o(i)}, x), U32.add(off, {O(i)}), U32.sub({B_(m, i)}, {O(i)}), '
                  f'eoj({CWA}, {O(i)}, FD.nat__le_trans({nat_o(i)}, U32.to_nat({B_(m, i)}), U32.to_nat(len), hab{i}, hbl{i})), hd, hwj({CWA}, {O(i)}, {B_(m, i)}, hab{i}, hbl{i}), pf, hk{i})')
        w(f'  +hfit = FD.logic__subst(Nat, z => {{N.fits(4n, z) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({F}n, List.length(&2, U32, Layout.payloads({PL_(m)}))), lpay{m}({CWA}, hf, e0, ha{m}),')
        w(f'    VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})))')
        w(f'  %enc{m}({CWA}, hf, e0, ha{m}) : {{Codec.parts(S.Sequence{{{items_(m, True)}}}, {LSCH}) == Some{{[S.Variable{{_}}]}} : {MP}}}')
        # the parts of the items: one variable part per element
        cat = '{==}'
        for i in range(m - 1, -1, -1):
            rest = '[' + ', '.join(f'S.Variable{{{Y_(m, k)}}}' for k in range(i + 1, m)) + ']'
            v = (f'CH.VALw(t, {F}n+x, U32.sub({B_(m, 0)}, {F}))' if i == 0 else f'CH.VALw(t, Nat.add({nat_o(i)}, x), U32.sub({B_(m, i)}, {O(i)}))')
            # the items after i
            sub = 'S.EmptyItems{}'
            for k in range(m - 1, i, -1):
                vk = f'CH.VALw(t, Nat.add({nat_o(k)}, x), U32.sub({B_(m, k)}, {O(k)}))'
                sub = f'S.Items{{{vk}, {sub}}}'
            # items_var: each step in the exact Codec.parts form of its parent (vspec)
            cat = f'VS.items_var({v}, {sub}, {ESCH}, {Y_(m, i)}, {rest}, ecast({v}, {Y_(m, i)}, c{i}), {cat})'
        w(f'  %Equal.sym({MP}, Codec.parts({items_(m, True)}, S.Repeat{{{ESCH}}}), Some{{{PL_(m)}}},')
        w(f'      {cat}) :')
        w(f'    {{Codec.aggregate(_, None{{}}) == Some{{[S.Variable{{{LSX}}}]}} : {MP}}}')
        doms = [f'SP.bytes_domain({Y_(m, i)})' for i in range(m)]
        FITS = f'N.fits(4n, Nat.add({F}n, List.length(&2, U32, Layout.payloads({PL_(m)}))))'

        def bv(ds):
            sx = 'True{}'
            for dd in reversed(ds):
                sx = f'Bool.and({dd}, {sx})'
            return sx
        for i in range(m):
            h = ['True{}'] * i + ['_'] + doms[i + 1:]
            w(f'  %Equal.sym(Bool, {doms[i]}, True{{}}, UW.domWX(t, {J_(m, i)}, {l_(m, i)})) :')
            w(f'    {{Codec.one(SP.optional(Bool.and({bv(h)}, {FITS}), {LSX}), None{{}}) == Some{{[S.Variable{{{LSX}}}]}} : {MP}}}')
        w(f'  %Equal.sym(Bool, {FITS}, True{{}}, hfit) :')
        w(f'    {{Codec.one(SP.optional(Bool.and({bv(["True{}"] * m)}, _), {LSX}), None{{}}) == Some{{[S.Variable{{{LSX}}}]}} : {MP}}}')
        w('  {==}')
        w('')
    # dispatch
    w('def VQ(q: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:')
    w('  match q:')
    for m in range(1, N + 1):
        w(f'    case {m}n: VAL{m}(t, x, len)')
    w('    case _: S.Sequence{S.EmptyItems{}}')
    w('''
def V4(s: Bool, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:
  match s:
    case True{}: S.Sequence{S.EmptyItems{}}
    case False{}: VQ(NQ(t, x), t, x, len)

def VZ(z: Bool, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:
  match z:
    case True{}: S.Sequence{S.EmptyItems{}}
    case False{}: V4(U32.is_lt(len, 4), t, x, len)

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: VZ(U32.is_eq(len, 0), t, x, len)
''')
    w(f'def specq({CW}, +q: Nat, +eq: {{NQ(t, x) == q : Nat}}, +e3: {{U32.and({O(0)}, 3) == 0 : U32}}, +hl: {{LOOP(q, t, x, off, len) == True{{}} : Bool}},')
    w(f'    +hfl: {{Nat.is_le(U32.to_nat({O(0)}), U32.to_nat(len)) == True{{}} : Bool}})')
    w(f'    -> {{Codec.parts(VQ(q, t, x, len), {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}:')
    w('  match q:')
    w(f'    case 0n: Empty.absurd({{Codec.parts(VQ(0n, t, x, len), {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}, FD.logic__false_true(hl))')
    for m in range(1, N + 1):
        F = 4 * m
        w(f'    case {m}n:')
        w(f'      +ev = Equal.trans(Nat, U32.to_nat({O(0)}), Nat.add(A.quad(NQ(t, x)), 0n), Nat.add({F}n, 0n), e4q(t, x, e3), Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), 0n), NQ(t, x), {m}n, eq))')
        w(f'      +e0 = FD.u32__injective({O(0)}, {F}, ev)')
        w(f'      %Equal.sym(U32, {O(0)}, {F}, e0) :')
        w(f'        {{Codec.parts(S.Sequence{{{items_(m, False).replace(f"CH.VALw(t, Nat.add({nat_o(0)}, x), U32.sub({B_(m, 0)}, {O(0)}))", f"CH.VALw(t, Nat.add(U32.to_nat(_), x), U32.sub({B_(m, 0)}, _))")}}}, {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}')
        # the first element's position as specm states it ({F}n+x), so the instance matches
        pat0 = items_(m, False).replace(f"CH.VALw(t, Nat.add({nat_o(0)}, x), U32.sub({B_(m, 0)}, {O(0)}))", f"CH.VALw(t, _, U32.sub({B_(m, 0)}, {F}))")
        w(f'      %Equal.sym(Nat, Nat.add(U32.to_nat({F}), x), {F}n+x, {{==}}) :')
        w(f'        {{Codec.parts(S.Sequence{{{pat0}}}, {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}')
        w(f'      specm{m}({CWA}, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == True{{}} : Bool}}, U32.to_nat({O(0)}), Nat.add({F}n, 0n), ev, hfl), e0, hl)')
    w(f'    case {N + 1}n+r: Empty.absurd({{Codec.parts(VQ({N + 1}n+r, t, x, len), {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}, FD.logic__false_true(hl))')
    SPEC_TOP = TEMPLATES.render('spec_top', LSCH=LSCH, WBL=WBL, N=N)
    w(SPEC_TOP)
    return '\n'.join(L)


def inv_all(LP, N, C, ESCH, LSCH, LIMN):
    L = []
    w = L.append
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    GOAL = '{CHKw(t, x, off, len) == True{} : Bool}'
    ys = lambda k: [f'y{i}' for i in range(k)]
    YS = lambda k: '[' + ', '.join(f'S.Variable{{y{i}}}' for i in range(k)) + ']'
    LY = lambda i: f'List.length(&2, U32, y{i})'

    def OUTk(k):
        return f'List.append(&2, U32, Layout.fixed_parts({YS(k)}, {4 * k}n), Layout.payloads({YS(k)}))'

    def OFFy(k, j):
        s = f'{4 * k}n'
        for i in range(j):
            s = f'Nat.add({s}, {LY(i)})'
        return s

    def PAYk(k, i):
        # y_i ++ (y_(i+1) ++ .. (y_(k-1) ++ []))
        s = '[]'
        for q in range(k - 1, i - 1, -1):
            s = f'List.append(&2, U32, y{q}, {s})'
        return s

    def SUMy(k, i):
        s = LY(k - 1)
        for q in range(k - 2, i - 1, -1):
            s = f'Nat.add({LY(q)}, {s})'
        return s
    for k in range(1, N + 1):
        F = 4 * k
        EQ = f'+eq: {{{OUTk(k)} == {WBL} : +List<U32>}}'
        HY = ', '.join(f'+h{i}: S.Value, +y{i}: +List<U32>, +eh{i}: {{Codec.parts(h{i}, {ESCH}) == Some{{[S.Variable{{y{i}}}]}} : {MP}}}' for i in range(k))
        YA = ', '.join(f'h{i}, y{i}, eh{i}' for i in range(k))
        # lengths
        w(f'def lout{k}({", ".join(f"+y{i}: +List<U32>" for i in range(k))}) -> {{List.length(&2, U32, {OUTk(k)}) == Nat.add({F}n, {SUMy(k, 0)}) : Nat}}:')
        for i in range(k - 1):
            pre = [LY(q) for q in range(i)]
            sx = '_'
            for q in reversed(pre):
                sx = f'Nat.add({q}, {sx})'
            w(f'  %Equal.sym(Nat, List.length(&2, U32, {PAYk(k, i)}), Nat.add({LY(i)}, List.length(&2, U32, {PAYk(k, i + 1)})), VS.len_app(y{i}, {PAYk(k, i + 1)})) :')
            w(f'    {{Nat.add({F}n, {sx}) == Nat.add({F}n, {SUMy(k, 0)}) : Nat}}')
        pre = [LY(q) for q in range(k - 1)]
        sx = 'List.length(&2, U32, _)'
        for q in reversed(pre):
            sx = f'Nat.add({q}, {sx})'
        w(f'  %Equal.sym(+List<U32>, List.append(&2, U32, y{k - 1}, []), y{k - 1}, VS.app_nil(y{k - 1})) :')
        w(f'    {{Nat.add({F}n, {sx}) == Nat.add({F}n, {SUMy(k, 0)}) : Nat}}')
        w('  {==}')
        w('')
        # the facts of a window of k parts
        w(f'def cfacts{k}({CW}, {HY}, {EQ}) -> {GOAL}:')
        w(f'  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, {WBL}), Nat.add({F}n, {SUMy(k, 0)}),')
        w(f'    Equal.sym(Nat, List.length(&2, U32, {WBL}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),')
        w(f'    Equal.trans(Nat, List.length(&2, U32, {WBL}), List.length(&2, U32, {OUTk(k)}), Nat.add({F}n, {SUMy(k, 0)}),')
        w(f'      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), {WBL}, {OUTk(k)}, Equal.sym(+List<U32>, {OUTk(k)}, {WBL}, eq)), lout{k}({", ".join(ys(k))})))')
        # OFF_j + |y_j| <= len, j = 0..k-1 (with OFF_0 = F)
        # cumulative: OFF_(j+1) + rest = len where rest = sum of later
        w(f'  +hF = FD.logic__subst(Nat, z => {{Nat.is_le({F}n, z) == True{{}} : Bool}}, Nat.add({F}n, {SUMy(k, 0)}), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add({F}n, {SUMy(k, 0)}), en), Order.below_sum({F}n, {SUMy(k, 0)}))')
        # en_j: len == Nat.add(OFF_j, SUM_j): from en by assoc steps
        w(f'  +en0 = en')
        for j in range(1, k):
            w(f'  +en{j} = Equal.trans(Nat, U32.to_nat(len), Nat.add({OFFy(k, j - 1)}, {SUMy(k, j - 1)}), Nat.add({OFFy(k, j)}, {SUMy(k, j)}), en{j - 1},')
            w(f'    Equal.sym(Nat, Nat.add({OFFy(k, j)}, {SUMy(k, j)}), Nat.add({OFFy(k, j - 1)}, {SUMy(k, j - 1)}), FD.nat__add_assoc({OFFy(k, j - 1)}, {LY(j - 1)}, {SUMy(k, j)})))')
        for j in range(k):
            # OFF_j + |y_j| <= len
            if j + 1 < k:
                w(f'  +hy{j} = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({OFFy(k, j)}, {LY(j)}), z) == True{{}} : Bool}}, Nat.add({OFFy(k, j + 1)}, {SUMy(k, j + 1)}), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add({OFFy(k, j + 1)}, {SUMy(k, j + 1)}), en{j + 1}), Order.below_sum(Nat.add({OFFy(k, j)}, {LY(j)}), {SUMy(k, j + 1)}))')
            else:
                w(f'  +hy{j} = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({OFFy(k, j)}, {LY(j)}), z) == True{{}} : Bool}}, Nat.add({OFFy(k, j)}, {LY(j)}), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add({OFFy(k, j)}, {LY(j)}), en{j}), FD.nat__le_refl(Nat.add({OFFy(k, j)}, {LY(j)})))')
            w(f'  +hj{j} = FD.nat__le_trans({OFFy(k, j)}, Nat.add({OFFy(k, j)}, {LY(j)}), U32.to_nat(len), Order.below_sum({OFFy(k, j)}, {LY(j)}), hy{j})')
        # the offset words
        w(f'  +b0 = Equal.trans(+List<U32>, F.limbs([{O(0)}]), UW.WX(t, x, 4n), [{F}, 0, 0, 0],')
        w(f'    UR.rwn_bytes(d, t, x, pf, UR.roomw(x, U32.to_nat(len), 0n, {PW}, hw, FD.nat__le_trans(4n, {F}n, U32.to_nat(len), {{==}}, hF))),')
        w(f'    Equal.trans(+List<U32>, UW.WX(t, x, 4n), VS.bt(4n, {WBL}), [{F}, 0, 0, 0],')
        w(f'      Equal.sym(+List<U32>, VS.bt(4n, {WBL}), UW.WX(t, x, 4n), UW.btWX(t, x, 4n, U32.to_nat(len), FD.nat__le_trans(4n, {F}n, U32.to_nat(len), {{==}}, hF))),')
        w(f'      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), {WBL}, {OUTk(k)}, Equal.sym(+List<U32>, {OUTk(k)}, {WBL}, eq))))')
        w(f'  +e0 = VN.wordc({O(0)}, {F}, b0)')
        for j in range(1, k):
            c = 4 * j
            D = f'N.digits(4n, {OFFy(k, j)})'
            w(f'  +b{j} = Equal.trans(+List<U32>, I.limb({O(j)}), F.limbs([{O(j)}]), {D}, Equal.sym(+List<U32>, F.limbs([{O(j)}]), I.limb({O(j)}), VS.app_nil(I.limb({O(j)}))),')
            w(f'    Equal.trans(+List<U32>, F.limbs([{O(j)}]), UW.WX(t, {c}n+x, 4n), {D},')
            w(f'      UR.rwn_bytes(d, t, {c}n+x, pf, UR.roomw(x, U32.to_nat(len), {c}n, {PW}, hw, FD.nat__le_trans(Nat.add({c}n, 4n), {F}n, U32.to_nat(len), {{==}}, hF))),')
            w(f'      Equal.trans(+List<U32>, UW.WX(t, {c}n+x, 4n), VS.bt(4n, VS.bdr({c}n, {WBL})), {D},')
            w(f'        Equal.sym(+List<U32>, VS.bt(4n, VS.bdr({c}n, {WBL})), UW.WX(t, {c}n+x, 4n), UW.subWX(t, x, {c}n, 4n, U32.to_nat(len), FD.nat__le_trans(Nat.add({c}n, 4n), {F}n, U32.to_nat(len), {{==}}, hF))),')
            w(f'        Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr({c}n, z)), {WBL}, {OUTk(k)}, Equal.sym(+List<U32>, {OUTk(k)}, {WBL}, eq)))))')
            w(f'  +e{j} = VG.digits_word({O(j)}, {OFFy(k, j)}, VFT.fits4(2n+d, {OFFy(k, j)}, FD.nat__le_trans({OFFy(k, j)}, U32.to_nat(len), {PW}, hj{j}, hlen(d, x, len, hw)), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})), b{j})')
        # the element windows
        for i in range(k):
            # y_i == WX(t, OFF_i + x, |y_i|)
            PI = PAYk(k, i)
            # bdr(OFF_i, OUT) == PAY_i
            chain = f'{{==}}'
            # build: bdr(OFF_i, OUT) -> bdr(|y_(i-1)|, bdr(OFF_(i-1), OUT)) ... -> PAY_i
            w('')
            steps = []
            cur = f'VS.bdr({OFFy(k, 0)}, {OUTk(k)})'
            # bdr(F, OUT) computes to PAY_0
            eqs = []
            w(f'  +dq{i}_0 = Equal.cong(+List<U32>, +List<U32>, z => z, VS.bdr({F}n, {OUTk(k)}), {PAYk(k, 0)}, {{==}})')
            for q in range(1, i + 1):
                # bdr(OFF_q, OUT) == bdr(|y_(q-1)|, bdr(OFF_(q-1), OUT)) == bdr(|y_(q-1)|, PAY_(q-1)) == PAY_q
                w(f'  +dq{i}_{q} = Equal.trans(+List<U32>, VS.bdr({OFFy(k, q)}, {OUTk(k)}), VS.bdr({LY(q - 1)}, VS.bdr({OFFy(k, q - 1)}, {OUTk(k)})), {PAYk(k, q)},')
                w(f'    VN.bdr_add({OFFy(k, q - 1)}, {LY(q - 1)}, {OUTk(k)}),')
                w(f'    Equal.trans(+List<U32>, VS.bdr({LY(q - 1)}, VS.bdr({OFFy(k, q - 1)}, {OUTk(k)})), VS.bdr({LY(q - 1)}, {PAYk(k, q - 1)}), {PAYk(k, q)},')
                w(f'      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr({LY(q - 1)}, z), VS.bdr({OFFy(k, q - 1)}, {OUTk(k)}), {PAYk(k, q - 1)}, dq{i}_{q - 1}), VS.bdr_app(y{q - 1}, {PAYk(k, q)})))')
            w(f'  +ey{i} = Equal.trans(+List<U32>, y{i}, VS.bt({LY(i)}, VS.bdr({OFFy(k, i)}, {OUTk(k)})), UW.WX(t, Nat.add({OFFy(k, i)}, x), {LY(i)}),')
            w(f'    Equal.sym(+List<U32>, VS.bt({LY(i)}, VS.bdr({OFFy(k, i)}, {OUTk(k)})), y{i},')
            w(f'      Equal.trans(+List<U32>, VS.bt({LY(i)}, VS.bdr({OFFy(k, i)}, {OUTk(k)})), VS.bt({LY(i)}, {PI}), y{i},')
            w(f'        Equal.cong(+List<U32>, +List<U32>, z => VS.bt({LY(i)}, z), VS.bdr({OFFy(k, i)}, {OUTk(k)}), {PI}, dq{i}_{i}),')
            w(f'        Equal.trans(+List<U32>, VS.bt({LY(i)}, {PI}), VS.bt({LY(i)}, y{i}), y{i}, VN.bt_app({LY(i)}, y{i}, {PAYk(k, i + 1)}, FD.nat__le_refl({LY(i)})), UW.bt_self(y{i})))),')
            w(f'    Equal.trans(+List<U32>, VS.bt({LY(i)}, VS.bdr({OFFy(k, i)}, {OUTk(k)})), VS.bt({LY(i)}, VS.bdr({OFFy(k, i)}, {WBL})), UW.WX(t, Nat.add({OFFy(k, i)}, x), {LY(i)}),')
            w(f'      Equal.cong(+List<U32>, +List<U32>, z => VS.bt({LY(i)}, VS.bdr({OFFy(k, i)}, z)), {OUTk(k)}, {WBL}, eq), UW.subWX(t, x, {OFFy(k, i)}, {LY(i)}, U32.to_nat(len), hy{i})))')
        w(f'  cfin{k}({CWA}, {YA}, eq, en, e0' + ''.join(f', e{j}' for j in range(1, k)) + ''.join(f', ey{i}, hy{i}' for i in range(k)) + ')')
        w('')
    return L


def inv_helpers(LP, N, C, ESCH, LSCH, LIMN, L):
    w = L.append
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    GOAL = '{CHKw(t, x, off, len) == True{} : Bool}'
    w(TEMPLATES.render('inv_helpers', WBL=WBL, GOAL=GOAL))


def inv_fin(LP, N, C, ESCH, LSCH, LIMN, L):
    w = L.append
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    GOAL = '{CHKw(t, x, off, len) == True{} : Bool}'
    LY = lambda i: f'List.length(&2, U32, y{i})'
    YS = lambda k: '[' + ', '.join(f'S.Variable{{y{i}}}' for i in range(k)) + ']'

    def OFFy(k, j):
        s = f'{4 * k}n'
        for i in range(j):
            s = f'Nat.add({s}, {LY(i)})'
        return s

    def SUMy(k, i):
        s = LY(k - 1)
        for q in range(k - 2, i - 1, -1):
            s = f'Nat.add({LY(q)}, {s})'
        return s
    for k in range(1, N + 1):
        F = 4 * k
        HY = ', '.join(f'+h{i}: S.Value, +y{i}: +List<U32>, +eh{i}: {{Codec.parts(h{i}, {ESCH}) == Some{{[S.Variable{{y{i}}}]}} : {MP}}}' for i in range(k))
        args = [f'+eq: {{List.append(&2, U32, Layout.fixed_parts({YS(k)}, {F}n), Layout.payloads({YS(k)})) == {WBL} : +List<U32>}}',
                f'+en: {{U32.to_nat(len) == Nat.add({F}n, {SUMy(k, 0)}) : Nat}}', f'+e0: {{{O(0)} == {F} : U32}}']
        args += [f'+e{j}: {{U32.to_nat({O(j)}) == {OFFy(k, j)} : Nat}}' for j in range(1, k)]
        for i in range(k):
            args.append(f'+ey{i}: {{y{i} == UW.WX(t, Nat.add({OFFy(k, i)}, x), {LY(i)}) : +List<U32>}}')
            args.append(f'+hy{i}: {{Nat.is_le(Nat.add({OFFy(k, i)}, {LY(i)}), U32.to_nat(len)) == True{{}} : Bool}}')
        # enl: Nat.add(F, SUM_0) == Nat.add(OFF_(k-1), |y_(k-1)|)
        w(f'def enl{k}({", ".join(f"+y{i}: +List<U32>" for i in range(k))}) -> {{Nat.add({F}n, {SUMy(k, 0)}) == Nat.add({OFFy(k, k - 1)}, {LY(k - 1)}) : Nat}}:')
        steps = []
        # Nat.add(OFF_j, SUM_j) == Nat.add(OFF_(j+1), SUM_(j+1)) by assoc
        s_ = []
        for j in range(k - 1):
            s_.append(f'Equal.sym(Nat, Nat.add({OFFy(k, j + 1)}, {SUMy(k, j + 1)}), Nat.add({OFFy(k, j)}, {SUMy(k, j)}), FD.nat__add_assoc({OFFy(k, j)}, {LY(j)}, {SUMy(k, j + 1)}))')
        if not s_:
            w('  {==}')
        else:
            e = s_[0]
            for j in range(1, k - 1):
                e = f'Equal.trans(Nat, Nat.add({F}n, {SUMy(k, 0)}), Nat.add({OFFy(k, j)}, {SUMy(k, j)}), Nat.add({OFFy(k, j + 1)}, {SUMy(k, j + 1)}), {e}, {s_[j]})'
            w(f'  {e}')
        w('')
        w(f'def cfin{k}({CW}, {HY}, {", ".join(args)}) -> {GOAL}:')
        # o_i as Nat (i >= 1: e_i; i = 0: F)
        w(f'  +eo0 = Equal.cong(U32, Nat, z => U32.to_nat(z), {O(0)}, {F}, e0)')
        for j in range(1, k):
            w(f'  +eo{j} = e{j}')
        # ranges: o_i <= B_i, B_i <= len
        for i in range(k):
            oi = f'U32.to_nat({O(i)})'
            if i + 1 < k:
                bi = f'U32.to_nat({O(i + 1)})'
            else:
                bi = 'U32.to_nat(len)'
            # o_i == OFF_i
            w(f'  +hlo{i} = FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add({OFFy(k, i)}, {LY(i)})) == True{{}} : Bool}}, {OFFy(k, i)}, {oi}, Equal.sym(Nat, {oi}, {OFFy(k, i)}, eo{i}), Order.below_sum({OFFy(k, i)}, {LY(i)}))')
            if i + 1 < k:
                w(f'  +hab{i} = FD.logic__subst(Nat, z => {{Nat.is_le({oi}, z) == True{{}} : Bool}}, {OFFy(k, i + 1)}, {bi}, Equal.sym(Nat, {bi}, {OFFy(k, i + 1)}, eo{i + 1}), hlo{i})')
                w(f'  +hbl{i} = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == True{{}} : Bool}}, {OFFy(k, i + 1)}, {bi}, Equal.sym(Nat, {bi}, {OFFy(k, i + 1)}, eo{i + 1}), hy{i})')
            else:
                w(f'  +hab{i} = FD.nat__le_trans({oi}, Nat.add({OFFy(k, i)}, {LY(i)}), U32.to_nat(len), hlo{i}, hy{i})')
                w(f'  +hbl{i} = FD.nat__le_refl(U32.to_nat(len))')
            # l_i == |y_i|
            B = O(i + 1) if i + 1 < k else 'len'
            bnat = OFFy(k, i + 1) if i + 1 < k else f'Nat.add({OFFy(k, i)}, {LY(i)})'
            ebn = f'eo{i + 1}' if i + 1 < k else f'Equal.trans(Nat, U32.to_nat(len), Nat.add({F}n, {SUMy(k, 0)}), Nat.add({OFFy(k, i)}, {LY(i)}), en, enl{k}(' + ', '.join(f'y{q}' for q in range(k)) + '))'
            w(f'  +el{i} = Equal.trans(Nat, U32.to_nat(U32.sub({B}, {O(i)})), Nat.sub(U32.to_nat({B}), {oi}), {LY(i)}, FD.u32__sub_nat({B}, {O(i)}, hab{i}),')
            w(f'    Equal.trans(Nat, Nat.sub(U32.to_nat({B}), {oi}), Nat.sub({bnat}, {OFFy(k, i)}), {LY(i)},')
            w(f'      Equal.trans(Nat, Nat.sub(U32.to_nat({B}), {oi}), Nat.sub({bnat}, {oi}), Nat.sub({bnat}, {OFFy(k, i)}),')
            w(f'        Equal.cong(Nat, Nat, z => Nat.sub(z, {oi}), U32.to_nat({B}), {bnat}, {ebn}), Equal.cong(Nat, Nat, z => Nat.sub({bnat}, z), {oi}, {OFFy(k, i)}, eo{i})),')
            w(f'      FD.nat__add_sub_cancel({OFFy(k, i)}, {LY(i)})))')
            # the child's check
            J = f'Nat.add({oi}, x)'
            w(f'  +ew{i} = Equal.trans(+List<U32>, y{i}, UW.WX(t, Nat.add({OFFy(k, i)}, x), {LY(i)}), UW.WX(t, {J}, U32.to_nat(U32.sub({B}, {O(i)}))), ey{i},')
            w(f'    Equal.sym(+List<U32>, UW.WX(t, {J}, U32.to_nat(U32.sub({B}, {O(i)}))), UW.WX(t, Nat.add({OFFy(k, i)}, x), {LY(i)}),')
            w(f'      Equal.trans(+List<U32>, UW.WX(t, {J}, U32.to_nat(U32.sub({B}, {O(i)}))), UW.WX(t, Nat.add({OFFy(k, i)}, x), U32.to_nat(U32.sub({B}, {O(i)}))), UW.WX(t, Nat.add({OFFy(k, i)}, x), {LY(i)}),')
            w(f'        Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(z, x), U32.to_nat(U32.sub({B}, {O(i)}))), {oi}, {OFFy(k, i)}, eo{i}),')
            w(f'        Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add({OFFy(k, i)}, x), z), U32.to_nat(U32.sub({B}, {O(i)})), {LY(i)}, el{i}))))')
            w(f'  +hk{i} = CH.invw(d, t, n, {J}, U32.add(off, {O(i)}), U32.sub({B}, {O(i)}), eoj({CWA}, {O(i)}, FD.nat__le_trans({oi}, U32.to_nat({B}), U32.to_nat(len), hab{i}, hbl{i})), hd,')
            w(f'    hwj({CWA}, {O(i)}, {B}, hab{i}, hbl{i}), pf, h{i},')
            w(f'    FD.logic__subst(+List<U32>, z => {{Codec.parts(h{i}, {ESCH}) == Some{{[S.Variable{{z}}]}} : {MP}}}, y{i}, UW.WX(t, {J}, U32.to_nat(U32.sub({B}, {O(i)}))), ew{i}, eh{i}))')
        # the accumulated checks
        w('')
        for i in range(k):
            AC = f'AC{k}_{i}(t, x, off, len)'
            B = O(i + 1) if i + 1 < k else 'len'
            prev = '{==}' if i == 0 else f'ac{i}'
            w(f'  +r{i}a = u32le({O(i)}, {B}, hab{i})')
            w(f'  +r{i}b = u32le({B}, len, hbl{i})')
            w(f'  +ac{i + 1} = FD.logic__subst(Bool, z => {{Bool.and(z, EW(Bool.and(z, Bool.and(U32.is_le({O(i)}, {B}), U32.is_le({B}, len))), {D_(i, k)})) == True{{}} : Bool}}, True{{}}, {AC}, Equal.sym(Bool, {AC}, True{{}}, {prev}),')
            w(f'    FD.logic__subst(Bool, z => {{Bool.and(True{{}}, EW(Bool.and(True{{}}, Bool.and(z, U32.is_le({B}, len))), {D_(i, k)})) == True{{}} : Bool}}, True{{}}, U32.is_le({O(i)}, {B}), Equal.sym(Bool, U32.is_le({O(i)}, {B}), True{{}}, r{i}a),')
            w(f'      FD.logic__subst(Bool, z => {{Bool.and(True{{}}, EW(Bool.and(True{{}}, Bool.and(True{{}}, z)), {D_(i, k)})) == True{{}} : Bool}}, True{{}}, U32.is_le({B}, len), Equal.sym(Bool, U32.is_le({B}, len), True{{}}, r{i}b),')
            w(f'        FD.logic__subst(Bool, z => {{Bool.and(True{{}}, EW(Bool.and(True{{}}, Bool.and(True{{}}, True{{}})), z)) == True{{}} : Bool}}, True{{}}, {D_(i, k)}, Equal.sym(Bool, {D_(i, k)}, True{{}}, hk{i}), {{==}}))))')
        # the header and the dispatch
        w(f'  +hlen = FD.logic__subst(Nat, z => {{Nat.is_le({F}n, z) == True{{}} : Bool}}, Nat.add({F}n, {SUMy(k, 0)}), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add({F}n, {SUMy(k, 0)}), en), Order.below_sum({F}n, {SUMy(k, 0)}))')
        w(f'  +hc = FD.logic__subst(U32, z => {{Bool.and(Bool.and(U32.is_eq(U32.and(z, 3), 0), U32.is_le(z, len)), Bool.and(U32.is_le(4, z), U32.is_le(U32.shrn(z, 2n), {N}))) == True{{}} : Bool}}, {F}, {O(0)}, Equal.sym(U32, {O(0)}, {F}, e0),')
        w(f'    FD.logic__subst(Bool, z => {{Bool.and(Bool.and(True{{}}, z), Bool.and(True{{}}, True{{}})) == True{{}} : Bool}}, True{{}}, U32.is_le({F}, len), Equal.sym(Bool, U32.is_le({F}, len), True{{}}, u32le({F}, len, hlen)), {{==}}))')
        w(f'  +nq = Equal.cong(U32, Nat, z => U32.to_nat(U32.shrn(z, 2n)), {O(0)}, {F}, e0)')
        w(f'  %Equal.sym(Bool, U32.is_eq(len, 0), False{{}}, neq0(len, FD.nat__le_trans(1n, {F}n, U32.to_nat(len), {{==}}, hlen), U32.is_eq(len, 0), {{==}})) : {{LZ(_, t, x, off, len) == True{{}} : Bool}}')
        w(f'  %Equal.sym(Bool, U32.is_lt(len, 4), False{{}}, nlt4(len, FD.nat__le_trans(4n, {F}n, U32.to_nat(len), {{==}}, hlen), U32.is_lt(len, 4), {{==}})) : {{L4(_, t, x, off, len) == True{{}} : Bool}}')
        w(f'  %Equal.sym(Bool, HC(t, x, len), True{{}}, hc) : {{HK(_, t, x, off, len) == True{{}} : Bool}}')
        w(f'  %Equal.sym(Nat, NQ(t, x), {k}n, nq) : {{LOOP(_, t, x, off, len) == True{{}} : Bool}}')
        w(f'  ac{k}')
        w('')


def inv_stages(LP, N, C, ESCH, LSCH, LIMN, L):
    import re
    w = L.append
    body = W.spec_defs()[ESCH[len('Spec.'):-2]]
    mm = re.fullmatch(r'T\.Container\{(\[.*?\]), (.*)\}', body)
    ENAMES = mm.group(1)
    EFIELDS = re.sub(r'\bSchema(\d+)\(\)', r'Spec.Schema\1()', mm.group(2)).replace('T.', 'S.')
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    GOAL = '{CHKw(t, x, off, len) == True{} : Bool}'

    def absurd():
        return f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))'

    def match_value(var, keep, body):
        out = [f'  match {var}:']
        for c, args in W.VALUE_CTORS:
            if c in keep:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in keep[c][0]) + f'}}: {keep[c][1]}')
            else:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in args) + f'}}: {absurd()}')
        return out

    def FULL(k, items):
        s = items
        for i in range(k - 1, -1, -1):
            s = f'S.Items{{h{i}, {s}}}'
        return s

    def CC(k, X):
        for i in range(k - 1, -1, -1):
            X = f'Codec.concatenate(Some{{[S.Variable{{y{i}}}]}}, {X})'
        return X

    def E(k, items, X):
        return (f'{{Codec.require(Nat.is_le(Codec.count({FULL(k, items)}), {LIMN}), Codec.aggregate({CC(k, X)}, None{{}})) == '
                f'Some{{[S.Variable{{{WBL}}}]}} : {MP}}}')

    def pre(k):
        return ''.join(f'+h{i}: S.Value, +y{i}: +List<U32>, +eh{i}: {{Codec.parts(h{i}, {ESCH}) == Some{{[S.Variable{{y{i}}}]}} : {MP}}}, ' for i in range(k))

    def pargs(k):
        return ''.join(f'h{i}, y{i}, eh{i}, ' for i in range(k))
    YS = lambda k: '[' + ', '.join(f'S.Variable{{y{i}}}' for i in range(k)) + ']'
    for k in range(N, -1, -1):
        # the end of the items: k elements
        if k == 0:
            w(f'def fin0({CW}, +e: {E(0, "S.EmptyItems{}", "Codec.parts(S.EmptyItems{}, S.Repeat{" + ESCH + "})")}) -> {GOAL}:')
            w(f'  zero_len({CWA}, var_inj([], {WBL}, e))')
            w('')
        else:
            b5 = f'Bool.and(Layout.bytes_valid({YS(k)}), N.fits(4n, Nat.add(Layout.fixed_size({YS(k)}), List.length(&2, U32, Layout.payloads({YS(k)})))))'
            OUT = f'List.append(&2, U32, Layout.fixed_parts({YS(k)}, {4 * k}n), Layout.payloads({YS(k)}))'
            w(f'def fb{k}({CW}, {pre(k)}+b5: Bool, +e: {{Codec.one(SP.optional(b5, {OUT}), None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
            w('  match b5:')
            w(f'    case False{{}}: {absurd()}')
            w(f'    case True{{}}: cfacts{k}({CWA}, {pargs(k)}var_inj({OUT}, {WBL}, e))')
            w('')
            w(f'def fin{k}({CW}, {pre(k)}+e: {E(k, "S.EmptyItems{}", "Codec.parts(S.EmptyItems{}, S.Repeat{" + ESCH + "})")}) -> {GOAL}:')
            w(f'  fb{k}({CWA}, {pargs(k)}{b5}, e)')
            w('')
        if k < N:
            nxt = f'Codec.parts(r, S.Repeat{{{ESCH}}})'
            w(f'def vp{k}({CW}, {pre(k)}+h: S.Value, +ps: +List<S.Part>, hf: DF.single(None{{}}, ps), +em: {{Codec.parts(h, {ESCH}) == Some{{ps}} : {MP}}}, +r: S.Value,')
            w(f'    +e: {E(k, "S.Items{h, r}", f"Codec.concatenate(Some{{ps}}, {nxt})")}) -> {GOAL}:')
            w('  match ps:')
            w(f'    case Nil{{}}: Empty.absurd({GOAL}, hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
            w(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{k + 1}({CWA}, {pargs(k)}h, ys, em, r, e)')
            w(f'    case Con{{S.Fixed{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)')
            w(f'    case Con{{S.Variable{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)')
            w('')
            w(f'def vm{k}({CW}, {pre(k)}+h: S.Value, +mm: {MP}, hf: DF.single_result(None{{}}, mm), +em: {{Codec.parts(h, {ESCH}) == mm : {MP}}}, +r: S.Value,')
            w(f'    +e: {E(k, "S.Items{h, r}", f"Codec.concatenate(mm, {nxt})")}) -> {GOAL}:')
            w('  match mm:')
            w(f'    case None{{}}: Empty.absurd({GOAL}, req_none(t, x, len, Nat.is_le(Codec.count({FULL(k, "S.Items{h, r}")}), {LIMN}), e))')
            w(f'    case Some{{+ps}}: vp{k}({CWA}, {pargs(k)}h, ps, hf, em, r, e)')
            w('')
        items = 'items'
        if k == N:
            keep = {'EmptyItems': ([], f'fin{k}({CWA}, {pargs(k)}e)'),
                    'Items': (['hh', 'rr'], f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))')}
        else:
            keep = {'EmptyItems': ([], f'fin{k}({CWA}, {pargs(k)}e)'),
                    'Items': (['h', 'r'], f'vm{k}({CWA}, {pargs(k)}h, Codec.parts(h, {ESCH}), UW.vsingle(h, {ENAMES}, {EFIELDS}, {{==}}), {{==}}, r, e)')}
        w(f'def st{k}({CW}, {pre(k)}+items: S.Value, +e: {E(k, "items", f"Codec.parts(items, S.Repeat{{{ESCH}}})")}) -> {GOAL}:')
        L.extend(match_value('items', keep, None))
        w('')
    w("# Every value whose spec parts are the window's bytes passes the checks.")
    w(f'def invw({CW}, +v: S.Value, +e: {{Codec.parts(v, {LSCH}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    L.extend(match_value('v', {'Sequence': (['items'], f'st0({CWA}, items, e)')}, None))


def inv_text(LP, N, C, ESCH, LSCH, LIMN):
    L = []
    inv_helpers(LP, N, C, ESCH, LSCH, LIMN, L)
    inv_fin(LP, N, C, ESCH, LSCH, LIMN, L)
    L += inv_all(LP, N, C, ESCH, LSCH, LIMN)
    inv_stages(LP, N, C, ESCH, LSCH, LIMN, L)
    return '\n'.join(L)


def ok_top(LP, N, C):
    return TEMPLATES.render('ok_top', LP=LP, N=N)


def module_text(LP, N, C, chmod, ESCH, LSCH, LIMN):
    L = W.HEADX + ['import ../../src/primitives.bend as I', 'import ./vua_rd.bend as UR', f'import ./{chmod} as CH', 'import ./vdig.bend as VG',
                   'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF', '',
                   '# GENERATED by container_list_offset_windows (codegen). Do not edit.',
                   f'# List[{C}, {N}] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    body = header_defs(LP, N, C) + common_lemmas(LP, N, C) + validator(LP, N, C) + ok_top(LP, N, C) + reader(LP, N, C) + spec_top(LP, N, C, ESCH, LSCH, LIMN) + inv_text(LP, N, C, ESCH, LSCH, LIMN)
    return '\n'.join(L) + W.COMMONX + body


def main():
    import re
    defs = W.spec_defs()
    kids, _ = VL.spec_schemas('BeaconBlockBody')
    lsch = {}
    for k in kids:
        mm = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[k])
        if mm:
            lsch[mm.group(1)] = (f'Spec.{mm.group(1)}()', f'Spec.{k}()', mm.group(2))
    out = {}
    for LP, N, C, chmod in LISTS:
        ESCH, LSCH, LIMN = lsch[ELEM[C]]
        out[ROOT / f'proofs/obj/var_winx_{LP}.bend'] = module_text(LP, N, C, chmod, ESCH, LSCH, LIMN)
    from codegen.impl import runtime_file_split as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    from codegen.core import retired_module_list as retired  # modules nothing imports: not written (codegen/core/retired_module_list.py)
    out = retired.drop(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale generated list windows: ', 'generated list windows are current')
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


# the element schema of each child
ELEM = {'AttesterSlashing': 'Schema47', 'Attestation': 'Schema40'}


if __name__ == '__main__':
    main()
