#!/usr/bin/env python3
"""e2e/e2e_dvv2.bend: a Vector[VarTestStruct, 2] read at a byte window (proofs/obj/vvl_v2_VarTestStruct.bend: V) satisfies the root laws'
representation invariant and the encode premise of the container that holds it (ComplexTestStruct):

    sdl(d, t, x, off, len, WF, hchk)                     EV.sv2(V.OBJw(d, t, x, off, len), 31n, 31n)
    rep(d, t, x, off, len, WF, s, es, ee, hchk)          RT.rep_v2_VarTestStruct(V.OBJw(d, t, x, off, len), s)

with WF the window facts eo, hd, hw, hw32, pfw (the argument order of e2e_dvl_*). The check of the window fixes the first offset at 8 (HC), so the
vector has two elements, (8, WJ0) and (WJ0, len): the array the reader builds is the one of two writes (V.RV(1n, ..): e2e_gvt.bend's v2e), the tree
of the elements' mirrors. An element's premises are the VarTestStruct decoder's own (VarTestStruct_e2e_decrep_generated.bend's p_rep / p_hs, at the
element's window: x, off, len in place of 0n, 0, n), moved to the freeze-then-thaw of the element by e2e_gvt.thfz.

Usage: python3 codegen/proofs/decoded/variable_vector_decoded_facts.py [--check]"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core.repository_paths import ROOT  # noqa: E402
E2E = ROOT / 'e2e'

WF_SIG = ('+eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},\n'
          '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},\n'
          '    +pfw: {FD.array__perfect(U32, d, t) == True{} : Bool}')
WF_ARG = 'eo, hd, hw, hw32, pfw'
WIN = '+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'


def at_window(t):
    """the decoder's lemma text at the window (x, off, len) in place of (0n, 0, n)"""
    t = t.replace('W.itD0(t, 0n, 0, n, hchk)', 'W.itD0(t, x, off, len, hchk)')
    t = t.replace('W.XJ0(t, 0n)', 'W.XJ0(t, x)').replace('W.FJ0(0, t, 0n)', 'W.FJ0(off, t, x)').replace('W.LJ0(t, 0n, n)', 'W.LJ0(t, x, len)')
    t = t.replace('Nat.add(0n, U32.to_nat(', 'Nat.add(x, U32.to_nat(')
    return t


def element_defs():
    dec = (E2E / 'VarTestStruct_e2e_decrep_generated.bend').read_text()
    imports = [l for l in dec.split('\n') if l.startswith('import ') and not l.endswith('as DC') and 'e2e_gvt' not in l]
    out = {}
    for nm in ('p_rep', 'p_hs'):
        i = dec.index(f'def {nm}(')
        j = dec.find('\n\n', i)
        j = len(dec) if j < 0 else j
        blk = dec[i:j]
        head, body = blk.split(':\n', 1)
        ret = head.split('-> ', 1)[1]
        ret = ret.replace('DC.OBJ(d, t, n)', 'W.OBJw(d, t, x, off, len)')
        out[nm] = (ret, at_window(body))
    return imports, out


def text():
    imports, el = element_defs()
    imports += ['import ../proofs/obj/vvl_v2_VarTestStruct.bend as V', 'import ../proofs/obj/root_gtypes_light.bend as RT' if 'root_gtypes_light' not in ' '.join(imports) else '',
                'import ./e2e_gvt.bend as GVT', 'import ./e2e_encvd.bend as EV', 'import ../proofs/obj/schema_shapes.bend as SH',
                'import ../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d', 'import ../types/schema.bend as S',
                'import ../proofs/obj/vuaw_dummy.bend as DUMMY']
    imports = [i for i in imports if i and 'DUMMY' not in i]
    # the module aliases of the copied lemmas: W is var_winx_VarTestStruct
    imports = list(dict.fromkeys(imports))
    WJ0 = 'V.WJ(t, x, 0)'
    VT = 'VarTestStruct_d.VarTestStruct'
    SEQ = 'vec_VarTestStruct_2_d.v2_VarTestStruct_Seq'
    FILL = 'vec_VarTestStruct_2_d.v2_VarTestStruct_fill'
    CAP = 'vec_VarTestStruct_2_d.v2_VarTestStruct_cap'
    E0 = f'W.OBJw(d, t, Nat.add(U32.to_nat(8), x), U32.add(off, 8), U32.sub({WJ0}, 8))'
    E1 = f'W.OBJw(d, t, Nat.add(U32.to_nat({WJ0}), x), U32.add(off, {WJ0}), U32.sub(len, {WJ0}))'
    A0 = ('Nat.add(U32.to_nat(8), x)', 'U32.add(off, 8)', f'U32.sub({WJ0}, 8)')
    A1 = (f'Nat.add(U32.to_nat({WJ0}), x)', f'U32.add(off, {WJ0})', f'U32.sub(len, {WJ0})')
    ARR = f'V.RV(1n, 0, 2, d, t, x, off, len, {FILL}({CAP}(2)), V.OBJE(d, t, x, off, 8, {WJ0}))'
    SEQ8 = f'{SEQ}{{{ARR}, 2}}'
    TT = f'FD.TNode{{FD.TLeaf{{RT.MSome{{RT.fz_VarTestStruct({E0})}}}}, FD.TLeaf{{RT.MSome{{RT.fz_VarTestStruct({E1})}}}}}}'
    TH = lambda e: f'RT.th_VarTestStruct(RT.fz_VarTestStruct({e}))'  # noqa: E731
    EE1 = f'V.EE(True{{}}, t, x, off, len, 8, {WJ0})'
    EW2 = lambda z: f'V.EW(V.GD({z}, {WJ0}, len, len), t, x, off, {WJ0}, len)'  # noqa: E731
    H8 = f'{{V.EE({EE1}, t, x, off, len, {WJ0}, len) == True{{}} : Bool}}'
    W0 = 'V.W0(t, x)'
    HCK_V = '+hchk: {V.CHKw(t, x, off, len) == True{} : Bool}'
    HCK_W = '+hchk: {W.CHKw(t, x, off, len) == True{} : Bool}'
    SCH = 'Spec.VarTestStruct()'

    def hel(a, b, h):
        """the element (a, b)'s window check, from the vector's EE"""
        ab = f'V.el_ab(t, x, off, len, {a}, {b}, {h})'
        bb = f'V.el_b(t, x, off, len, {a}, {b}, {h})'
        return ab, bb

    o = []
    A_ = o.append
    A_('\n'.join(imports))
    A_('')
    A_('# GENERATED by variable_vector_decoded_facts (codegen). Do not edit.')
    A_('# A Vector[VarTestStruct, 2] at a byte window: the root laws\' representation invariant and the encode premise (see the generator).')
    A_('')
    A_('# ---- an element at its window (the decoder\'s own lemmas, at the window) ----')
    A_(f'def el_rep({WIN}, {HCK_W})\n    -> {el["p_rep"][0].replace("Spec.VarTestStruct()", SCH) if False else el["p_rep"][0]}:\n{el["p_rep"][1]}')
    A_('')
    A_(f'def el_hs({WIN}, {HCK_W})\n    -> {el["p_hs"][0]}:\n{el["p_hs"][1]}')
    A_('')
    A_('# ... of the freeze-then-thaw of the element (the box the vector\'s tree holds)')
    A_(f'def el_rep_th({WIN}, {HCK_W})\n    -> RT.rep_VarTestStruct({TH("W.OBJw(d, t, x, off, len)")}, Spec.VarTestStruct()):\n'
       f'  FD.logic__subst({VT}, z => RT.rep_VarTestStruct(z, Spec.VarTestStruct()), W.OBJw(d, t, x, off, len), {TH("W.OBJw(d, t, x, off, len)")}, Equal.sym({VT}, {TH("W.OBJw(d, t, x, off, len)")}, W.OBJw(d, t, x, off, len), GVT.thfz(d, t, x, off, len)), el_rep(d, t, x, off, len, hchk))')
    A_('')
    A_(f'def el_hs_th({WIN}, {HCK_W})\n    -> BL.sdk(RT.pj_VarTestStruct_1({TH("W.OBJw(d, t, x, off, len)")}), 31n):\n'
       f'  FD.logic__subst({VT}, z => BL.sdk(RT.pj_VarTestStruct_1(z), 31n), W.OBJw(d, t, x, off, len), {TH("W.OBJw(d, t, x, off, len)")}, Equal.sym({VT}, {TH("W.OBJw(d, t, x, off, len)")}, W.OBJw(d, t, x, off, len), GVT.thfz(d, t, x, off, len)), el_hs(d, t, x, off, len, hchk))')
    A_('')
    A_('# the element\'s box: its representation (the schema the vector\'s element schema)')
    A_(f'def el_bx({WIN}, {HCK_W}, +sE: S.Schema, +ee: {{sE == {SCH} : S.Schema}})\n    -> RT.rep_VarTestStruct_bx(RT.th_VarTestStruct_bx(RT.MSome{{RT.fz_VarTestStruct(W.OBJw(d, t, x, off, len))}}), sE):\n'
       f'  ({{==}}, FD.logic__subst(S.Schema, z => RT.rep_VarTestStruct({TH("W.OBJw(d, t, x, off, len)")}, z), {SCH}, sE, Equal.sym(S.Schema, sE, {SCH}, ee), el_rep_th(d, t, x, off, len, hchk)))')
    A_('')
    A_('# ---- the vector\'s array: the two writes ----')
    A_(f'def TT({WIN}) -> FD.array__Tree<RT.MB<RT.M_VarTestStruct>>: {TT}')
    A_('')
    # the array of the tree of the thawed-frozen elements is the array the reader writes
    A_(f'def eqv({WIN}) -> {{{SEQ8} == {SEQ}{{RT.am_v2_VarTestStruct(TT(d, t, x, off, len)), 2}} : {SEQ}}}:\n'
       f'  %Equal.sym({VT}, {TH(E0)}, {E0}, GVT.thfz(d, t, {A0[0]}, {A0[1]}, {A0[2]})) :\n'
       f'    {{{SEQ8} == {SEQ}{{ANode{{ALeaf{{O.BSome{{_, O.BNone{{}}}}}}, ALeaf{{O.BSome{{{TH(E1)}, O.BNone{{}}}}}}}}, 2}} : {SEQ}}}\n'
       f'  %Equal.sym({VT}, {TH(E1)}, {E1}, GVT.thfz(d, t, {A1[0]}, {A1[1]}, {A1[2]})) :\n'
       f'    {{{SEQ8} == {SEQ}{{ANode{{ALeaf{{O.BSome{{{E0}, O.BNone{{}}}}}}, ALeaf{{O.BSome{{_, O.BNone{{}}}}}}}}, 2}} : {SEQ}}}\n'
       f'  {{==}}')
    A_('')
    A_('# the two elements\' window checks, from the check of the vector')
    A_(f'def ha8({WIN}, +h8: {H8}) -> {{V.EE(True{{}}, t, x, off, len, 8, {WJ0}) == True{{}} : Bool}}:\n'
       f'  FD.logic__and_left({EE1}, {EW2(EE1)}, h8)')
    A_('')
    A_(f'def hb8({WIN}, +h8: {H8}) -> {{V.EE(True{{}}, t, x, off, len, {WJ0}, len) == True{{}} : Bool}}:\n'
       f'  FD.logic__subst(Bool, z => {{{EW2("z")} == True{{}} : Bool}}, {EE1}, True{{}}, ha8(d, t, x, off, len, h8), FD.logic__and_right({EE1}, {EW2(EE1)}, h8))')
    A_('')
    # the facts both elements' windows hold as the vector reader's lemmas give them
    A_('# ---- the representation invariant of the two-write vector ----')
    ELA = lambda i: f'el_bx(d, t, {(A0, A1)[i][0]}, {(A0, A1)[i][1]}, {(A0, A1)[i][2]}, V.el_c(t, x, off, len, {("8", WJ0)[i]}, {(WJ0, "len")[i]}, {("ha8", "hb8")[i]}(d, t, x, off, len, h8)), sE, ee)'  # noqa: E731
    A_(f'def rep8({WIN}, +h8: {H8}, +s: S.Schema, +es: {{Nat.is_eq(2n, SH.Vector_length(s)) == True{{}} : Bool}}, +ee: {{SH.Vector_element(s) == {SCH} : S.Schema}})\n'
       f'    -> RT.rep_v2_VarTestStruct({SEQ8}, s):\n'
       f'  +sE = SH.Vector_element(s)\n'
       f'  FD.logic__subst({SEQ}, z => RT.rep_v2_VarTestStruct(z, s), {SEQ}{{RT.am_v2_VarTestStruct(TT(d, t, x, off, len)), 2}}, {SEQ8}, Equal.sym({SEQ}, {SEQ8}, {SEQ}{{RT.am_v2_VarTestStruct(TT(d, t, x, off, len)), 2}}, eqv(d, t, x, off, len)),\n'
       f'    ((TT(d, t, x, off, len), (1n, (2, ({{==}}, ({{==}}, ({{==}}, ({{==}}, ({ELA(0)}, ({ELA(1)}, {{==}}))))))))), es))')
    A_('')
    A_('# ---- the encode premise of the two-write vector ----')
    ELS = lambda i: f'el_hs_th(d, t, {(A0, A1)[i][0]}, {(A0, A1)[i][1]}, {(A0, A1)[i][2]}, V.el_c(t, x, off, len, {("8", WJ0)[i]}, {(WJ0, "len")[i]}, {("ha8", "hb8")[i]}(d, t, x, off, len, h8)))'  # noqa: E731
    A_(f'def sd8({WIN}, +h8: {H8}) -> EV.sv2({SEQ8}, 31n, 31n):\n'
       f'  ({{==}}, ({ELS(0)}, ({ELS(1)}, {{==}})))')
    A_('')
    # the window's check: the first offset is 8
    A_('# ---- the window\'s check: nonempty, the first offset 8 ----')
    A_(f'def e8_of({WIN}, +h: {{V.CF(V.HC({W0}, len), t, x, off, len) == True{{}} : Bool}}) -> {{{W0} == 8 : U32}}:\n'
       f'  FD.u32alg__eq_of({W0}, 8, FD.logic__and_right(Bool.and(U32.is_eq(U32.and({W0}, 3), 0), U32.is_le({W0}, len)), U32.is_eq({W0}, 8), V.cf_ok(V.HC({W0}, len), t, x, off, len, h)))')
    A_('')
    A_(f'def h8_of({WIN}, +h: {{V.CF(V.HC({W0}, len), t, x, off, len) == True{{}} : Bool}}) -> {H8}:\n'
       f'  +hc = V.cf_ok(V.HC({W0}, len), t, x, off, len, h)\n'
       f'  +h1 = FD.logic__subst(Bool, z => {{V.CF(z, t, x, off, len) == True{{}} : Bool}}, V.HC({W0}, len), True{{}}, hc, h)\n'
       f'  FD.logic__subst(U32, w => {{V.EV(U32.to_nat(U32.sub(U32.shrn(w, 2n), 1)), 0, U32.shrn(w, 2n), t, x, off, len, V.EE(True{{}}, t, x, off, len, w, V.NX(U32.is_eq(1, U32.shrn(w, 2n)), t, x, len, 0)), V.NX(U32.is_eq(1, U32.shrn(w, 2n)), t, x, len, 0)) == True{{}} : Bool}}, {W0}, 8, e8_of(d, t, x, off, len, h), h1)')
    A_('')
    OBJR = (f'{SEQ}{{V.RV(U32.to_nat(U32.sub(U32.shrn(_, 2n), 1)), 0, U32.shrn(_, 2n), d, t, x, off, len, {FILL}({CAP}(U32.shrn(_, 2n))), '
            f'V.OBJE(d, t, x, off, _, V.NX(U32.is_eq(1, U32.shrn(_, 2n)), t, x, len, 0))), U32.shrn(_, 2n)}}')
    OBJF = f'V.RZ(False{{}}, d, t, x, off, len)'

    def case_false(ty, call):
        return (f'  +e8 = e8_of(d, t, x, off, len, h)\n'
                f'  +h8 = h8_of(d, t, x, off, len, h)\n'
                f'  %Equal.sym(U32, {W0}, 8, e8) : {ty.replace("@O@", OBJR)}\n'
                f'  {call}')
    A_(f'def repF({WIN}, +h: {{V.CF(V.HC({W0}, len), t, x, off, len) == True{{}} : Bool}}, +s: S.Schema, +es: {{Nat.is_eq(2n, SH.Vector_length(s)) == True{{}} : Bool}}, +ee: {{SH.Vector_element(s) == {SCH} : S.Schema}})\n'
       f'    -> RT.rep_v2_VarTestStruct({OBJF}, s):\n'
       + case_false('RT.rep_v2_VarTestStruct(@O@, s)', 'rep8(d, t, x, off, len, h8, s, es, ee)'))
    A_('')
    A_(f'def sdF({WIN}, +h: {{V.CF(V.HC({W0}, len), t, x, off, len) == True{{}} : Bool}})\n'
       f'    -> EV.sv2({OBJF}, 31n, 31n):\n'
       + case_false('EV.sv2(@O@, 31n, 31n)', 'sd8(d, t, x, off, len, h8)'))
    A_('')
    A_('# ---- the window at its check: the empty window is rejected ----')
    A_(f'def rep_c(+c: Bool, {WIN[len("+d: Nat, "):] if False else "+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32"}, +ec: {{U32.is_eq(len, 0) == c : Bool}}, {HCK_V}, +s: S.Schema, +es: {{Nat.is_eq(2n, SH.Vector_length(s)) == True{{}} : Bool}}, +ee: {{SH.Vector_element(s) == {SCH} : S.Schema}})\n'
       f'    -> RT.rep_v2_VarTestStruct(V.RZ(c, d, t, x, off, len), s):\n'
       f'  match c:\n'
       f'    case True{{}}: Empty.absurd(RT.rep_v2_VarTestStruct(V.RZ(True{{}}, d, t, x, off, len), s), FD.logic__false_true(FD.logic__subst(Bool, z => {{V.CZ(z, t, x, off, len) == True{{}} : Bool}}, U32.is_eq(len, 0), True{{}}, ec, hchk)))\n'
       f'    case False{{}}: repF(d, t, x, off, len, FD.logic__subst(Bool, z => {{V.CZ(z, t, x, off, len) == True{{}} : Bool}}, U32.is_eq(len, 0), False{{}}, ec, hchk), s, es, ee)')
    A_('')
    A_(f'def sd_c(+c: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {{U32.is_eq(len, 0) == c : Bool}}, {HCK_V})\n'
       f'    -> EV.sv2(V.RZ(c, d, t, x, off, len), 31n, 31n):\n'
       f'  match c:\n'
       f'    case True{{}}: Empty.absurd(EV.sv2(V.RZ(True{{}}, d, t, x, off, len), 31n, 31n), FD.logic__false_true(FD.logic__subst(Bool, z => {{V.CZ(z, t, x, off, len) == True{{}} : Bool}}, U32.is_eq(len, 0), True{{}}, ec, hchk)))\n'
       f'    case False{{}}: sdF(d, t, x, off, len, FD.logic__subst(Bool, z => {{V.CZ(z, t, x, off, len) == True{{}} : Bool}}, U32.is_eq(len, 0), False{{}}, ec, hchk))')
    A_('')
    A_('# ---- the two laws ----')
    A_(f'def sdl({WIN}, {WF_SIG}, {HCK_V})\n    -> EV.sv2(V.OBJw(d, t, x, off, len), 31n, 31n):\n  sd_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, hchk)')
    A_('')
    A_(f'def rep({WIN}, {WF_SIG}, +s: S.Schema, +es: {{Nat.is_eq(2n, SH.Vector_length(s)) == True{{}} : Bool}}, +ee: {{SH.Vector_element(s) == {SCH} : S.Schema}}, {HCK_V})\n'
       f'    -> RT.rep_v2_VarTestStruct(V.OBJw(d, t, x, off, len), s):\n  rep_c(U32.is_eq(len, 0), d, t, x, off, len, {{==}}, hchk, s, es, ee)')
    return '\n'.join(o) + '\n'


def main():
    p = E2E / 'e2e_dvv2.bend'
    t = text()
    if '--check' in sys.argv:
        if not p.exists() or p.read_text() != t:
            print('stale: ' + p.name)
            sys.exit(1)
        print('variable_vector_decoded_facts: up to date')
        return
    if not p.exists() or p.read_text() != t:
        p.write_text(t)
    print('variable_vector_decoded_facts: 1 file')


if __name__ == '__main__':
    main()
