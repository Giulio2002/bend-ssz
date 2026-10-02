"""Provers of e2e_decrep's PROVERS table that are kept apart from it (EXTRA_PROVERS): the (i)/(iv) premises of the decoded object of a name
(DC.OBJ), for every input the codec accepts. The helpers are e2e_decrep's.

ComplexTestStruct: A uint16, B List[uint16, 128], C uint8, D ByteList[256], E VarTestStruct, F Vector[FixedTestStruct, 4], G Vector[VarTestStruct, 2].
B, D and the list of E are windows read by the dec bridge's reader (their storage and representation: the u16 / byte list laws of e2e_dz, e2e_dpl),
E is the VarTestStruct window reader's object (a nested window: the inner list's window is the one of E's field), F is e2e_dfv4.bend's (the
four copied records) and G e2e_dvv2.bend's (the two-element vector the check of the window fixes)."""
import sys as _sys
from codegen.core.shared_bridges import import_list  # noqa: E402
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script

import re


def complex_test_struct(lf):
    from codegen.proofs.composed import e2e_decrep as DR
    name = 'ComplexTestStruct'
    DR.BUF.depth_first.add(name)
    ps = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, '
          '+hn: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{} : Bool}, +hS: {U32.is_le(n, VB.NMAX()) == True{} : Bool}, +hchk: {DC.CHK(t, n) == True{} : Bool}')

    def lets(al):
        BW, CH0, CH1 = al('proofs/obj/var_winx_ComplexTestStruct.bend'), al('proofs/obj/var_winx_l128_u16.bend'), al('proofs/obj/vvlb_bl256.bend')
        BWE, CHE = al('proofs/obj/var_winx_VarTestStruct.bend'), al('proofs/obj/var_winx_l1024_u16.bend')
        DPA, DV4, DVV = al('e2e/e2e_dpl.bend'), al('e2e/e2e_dfv4.bend'), al('e2e/e2e_dvv2.bend')
        HVK = al('e2e/e2e_hvk.bend')
        X = lambda j: f'{BW}.XJ{j}(t, 0n)'  # noqa: E731
        F = lambda j: f'{BW}.FJ{j}(0, t, 0n)'  # noqa: E731
        L = lambda j: f'{BW}.LJ{j}(t, 0n)' if j < 3 else f'{BW}.LJ3(t, 0n, n)'  # noqa: E731
        hc = lambda j: f'{BW}.itD{j}(t, 0n, 0, n, hchk)'  # noqa: E731
        out = []

        def u16(sfx, CH, Xw, Fw, Lw, hcw, ky):
            out.extend([f'+hb{sfx} = {CH}.hB(t, {Xw}, {Fw}, {Lw}, {hcw})',
                        f'+hy{sfx} = VC.hyU({Lw}, {ky}n, {{==}}, {CH}.hyB({Lw}, hb{sfx}))',
                        f'+eL{sfx} = {CH}.eLc(t, {Xw}, {Fw}, {Lw}, {hcw})',
                        f'+hl{sfx} = {CH}.hcL(t, {Xw}, {Fw}, {Lw}, {hcw})',
                        f'+ec{sfx} = {DPA}.cnt(1n, {Lw}, {CH}.CQ({Lw}), eL{sfx})'])

        def u16words(e, sfx, CH, Fw, Lw, limit):
            cnt = f'U32.to_nat(U32.shrn({Lw}, 1n))'
            lenf = (f'Equal.trans(Nat, U32.to_nat({Lw}), Nat.double({CH}.CQ({Lw})), Nat.double({cnt}), eL{sfx}, '
                    f'Equal.cong(Nat, Nat, z => Nat.double(z), {CH}.CQ({Lw}), {cnt}, Equal.sym(Nat, {cnt}, {CH}.CQ({Lw}), ec{sfx})))')
            limf = (f'FD.logic__subst(Nat, z => {{Nat.is_le(z, {limit}n) == True{{}} : Bool}}, {CH}.CQ({Lw}), {cnt}, Equal.sym(Nat, {cnt}, {CH}.CQ({Lw}), ec{sfx}), hl{sfx})')
            return DR.WordsDec(e, any_=lambda k: f'DZ.ct_dec(d, t, {Fw}, {Lw}, {k}, {{==}}, hy{sfx})',
                               facts=[(r'U32\.to_nat\(\w+\.len\(o\)\) == Nat\.double\(\w+\.cnt2\(o\)\)', lenf), (r'Nat\.is_le\(\w+\.cnt2\(o\), ', limf)])
        # B: the List[uint16, 128] window
        out.append(f'+hc0 = {hc(0)}')
        u16('B', CH0, X(0), F(0), L(0), 'hc0', 9)
        # D: the ByteList[256] window
        out.append(f'+hc1 = {hc(1)}')
        out.extend([f'+hbD = {CH1}.hB(t, {X(1)}, {F(1)}, {L(1)}, hc1)', f'+hyD = VC.hyU({L(1)}, 9n, {{==}}, {CH1}.hyB({L(1)}, hbD))'])
        # E: the VarTestStruct window, its inner List[uint16, 1024] window
        out.append(f'+hc2 = {hc(2)}')
        XI, FI, LI = f'{BWE}.XJ0(t, {X(2)})', f'{BWE}.FJ0({F(2)}, t, {X(2)})', f'{BWE}.LJ0(t, {X(2)}, {L(2)})'
        out.append(f'+hcE = {BWE}.itD0(t, {X(2)}, {F(2)}, {L(2)}, hc2)')
        u16('E', CHE, XI, FI, LI, 'hcE', 12)
        out.append(f'+hc3 = {hc(3)}')
        com = 'd, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, hchk'
        WF3 = f'{BW}.eoJ3D({com}), hd, {BW}.hwJ3D({com}), {BW}.hwJ3_32({com}), pf'
        idx = [0]

        def words(j, e):
            k = idx[0]
            idx[0] += 1
            if k == 0:
                return u16words(e, 'B', CH0, F(0), L(0), 128)
            if k == 1:
                return DR.WordsDec(e, any_=lambda kk: f'DZ.ct_dec(d, t, {F(1)}, {L(1)}, {kk}, {{==}}, hyD)', limit='hbD')
            if k == 2:
                return u16words(e, 'E', CHE, FI, LI, 1024)
            raise SystemExit(f'e2e_decrep_x: ComplexTestStruct: unexpected word field {k}: {e[:120]}')

        def xleaf(fname, fn, args, e):
            a = ', '.join(args)
            if fname == 'vfx_v4_FixedTestStruct.bend' and fn == 'OBJ':
                return DR.FxWords(e, {('root_gtypes_light.bend', 'rep_v4_FixedTestStruct'): lambda s_: f'{DV4}.rep({a}, {s_}, {{==}})',
                                      ('e2e_encvd.bend', 'sv4'): lambda k_: f'{DV4}.sv({a}, {k_}, {{==}})'})
            if fname == 'vvl_v2_VarTestStruct.bend' and fn == 'OBJw':
                return DR.FxWords(e, {('root_gtypes_light.bend', 'rep_v2_VarTestStruct'): lambda s_: f'{DVV}.rep({a}, {WF3}, {s_}, {{==}}, {{==}}, hc3)',
                                      ('e2e_encvd.bend', 'sv2'): lambda k_: f'{DVV}.sdl({a}, {WF3}, hc3)'})
            return None
        return out, words, None, None, xleaf
    return DR.container_file(name, lf, 'proofs/obj/var_codec_ComplexTestStruct.bend', 'OBJ', {'d': 'd', 't': 't', 'n': 'n'}, (['d', 't', 'n'], ps), lets, None,
                             'proofs/obj/var_codec_ComplexTestStruct.bend')


def prog_test_struct(lf):
    """ProgressiveTestStruct: A progressive list of uint8, B of uint64, C pl_SmallTestStruct (fixed-size records, e2e_dfl), D pl_pl_VarTestStruct (e2e_dvp), each a
    window of the container's: the words' storage and representation (e2e_dz, the aligned-copy lemmas), the list libraries' laws. The theorem takes 1 + n < 2^31
    (the size bound TOT_ProgressiveTestStruct: 17 + the four windows' lengths = 1 + n)."""
    from codegen.proofs.composed import e2e_decrep as DR
    name = 'ProgressiveTestStruct'
    h = '{Nat.is_lt(Nat.add(1n, U32.to_nat(n)), VB.pw(31n)) == True{} : Bool}'
    DR.BUF.depth_first.add(name)
    DR.HEAVY[name] = h
    ps = DR.buf_ps(h)

    def setup(al):
        BW = al('proofs/obj/var_winx_ProgressiveTestStruct.bend')
        CH1 = al('proofs/obj/var_winp_pl_u64.bend')
        DPQ, DFL, DVP = al('e2e/e2e_dpq.bend'), al('e2e/e2e_dfl_pl_SmallTestStruct.bend'), al('e2e/e2e_dvp_pl_pl_VarTestStruct.bend')
        al('proofs/obj/words_spec.bend')
        X = lambda j: f'{BW}.XJ{j}(t, 0n)'  # noqa: E731
        F = lambda j: f'{BW}.FJ{j}(0, t, 0n)'  # noqa: E731
        L = lambda j: f'{BW}.LJ{j}(t, 0n)' if j < 3 else f'{BW}.LJ3(t, 0n, n)'  # noqa: E731
        hc = lambda j: f'{BW}.itD{j}(t, 0n, 0, n, hchk)'  # noqa: E731
        com = f'd, t, n, 0n, 0, n, {{==}}, hd, hn, {DR.HWN_TOP}, pf, hchk'
        out = ['+hn31 = FD.nat__lt_trans(U32.to_nat(n), Nat.add(1n, U32.to_nat(n)), VB.pw(31n), FD.nat__lt_succ(U32.to_nat(n)), h31)']
        for k in range(4):
            Ok, Ek = f'{BW}.O{k}(t, 0n)', (f'{BW}.O{k + 1}(t, 0n)' if k < 3 else 'n')
            out += [f'+lw{k} = {DPQ}.lwd({Ok}, {Ek}, n, {BW}.r1{k}(t, 0n, 0, n, hchk), {BW}.r2{k}(t, 0n, 0, n, hchk))',
                    f'+hy{k} = VC.hyW(0n, {L(k)}, FD.nat__le_trans(U32.to_nat({L(k)}), U32.to_nat(n), U32.to_nat(VB.NMAX()), lw{k}, {DR.HWN_TOP}))',
                    f'+hl{k} = FD.nat__le_lt_trans(U32.to_nat({L(k)}), U32.to_nat(n), VB.pw(31n), lw{k}, hn31)']
        WF = lambda j: f'{BW}.eoJ{j}D({com}), hd, {BW}.hwJ{j}D({com}), {BW}.hwJ{j}_32({com}), pf'  # noqa: E731
        DPT, EL_ = al('e2e/e2e_dpt.bend'), al('e2e/e2e_encld.bend')
        CH2, CH3 = al('proofs/obj/var_winx_pl_SmallTestStruct.bend'), al('proofs/obj/vvl_pl_pl_VarTestStruct.bend')
        sumL = 'Nat.add(Nat.add(Nat.add(Nat.add(17n, U32.to_nat(%s)), U32.to_nat(%s)), U32.to_nat(%s)), U32.to_nat(%s))' % (L(0), L(1), L(2), L(3))
        QR2 = f'{EL_}.QR_pl_SmallTestStruct({CH2}.OBJw(d, t, {X(2)}, {F(2)}, {L(2)}))'
        QV3 = f'{EL_}.QV_pl_pl_VarTestStruct({CH3}.OBJw(d, t, {X(3)}, {F(3)}, {L(3)}))'
        tot = f'{DPT}.tot(t, 0n, 0, n, hchk)'
        H0 = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(31n)) == True{{}} : Bool}}, Nat.add(1n, U32.to_nat(n)), {sumL}, '
              f'Equal.sym(Nat, {sumL}, Nat.add(1n, U32.to_nat(n)), {tot}), h31)')
        a, b, c = (f'Nat.add(Nat.add(Nat.add(17n, U32.to_nat({L(0)})), U32.to_nat({L(1)})), ', f'U32.to_nat({L(2)})', f'U32.to_nat({L(3)})')
        OBJ3 = f'{CH3}.OBJw(d, t, {X(3)}, {F(3)}, {L(3)})'
        DVP_LNQ = f'{DVP}.LNQ({OBJ3})'
        sz3 = f'{DVP}.szl(d, t, {X(3)}, {F(3)}, {L(3)}, {WF(3)}, hl3, {hc(3)})'
        sz2 = f'{DFL}.szl(d, t, {X(2)}, {F(2)}, {L(2)}, {hc(2)})'
        H1 = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add({a}{b}), z), VB.pw(31n)) == True{{}} : Bool}}, {c}, {QV3}, Equal.sym(Nat, {QV3}, {c}, Equal.trans(Nat, {QV3}, {DVP_LNQ}, {c}, {DPT}.qvl({OBJ3}), {sz3})), {H0})')
        H2 = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add({a}z), {QV3}), VB.pw(31n)) == True{{}} : Bool}}, {b}, {QR2}, Equal.sym(Nat, {QR2}, {b}, {sz2}), {H1})')
        return locals()

    def lets(al):
        V = setup(al)
        globals().update({})
        BW, CH1, DPQ, DFL, DVP, X, F, L, hc, com, out, WF = (V[k] for k in ('BW', 'CH1', 'DPQ', 'DFL', 'DVP', 'X', 'F', 'L', 'hc', 'com', 'out', 'WF'))
        PTOT = al('e2e/e2e_dpt_tot.bend')
        DR.TOT_HOOK[name] = lambda p: (f'{PTOT}.totp(d, t, n, pf, hd, hn, h31, hS, hchk)'
                                       if re.match(r'^\{Nat\.is_lt\(Nat\.add\(Nat\.add\(Nat\.add\(Nat\.add\(17n, ', p.strip()) else None)

        def xleaf(fname, fn, args, e):
            if fn != 'OBJw':
                return None
            a = ', '.join(args)
            mk = re.match(r'[\w.]+\.XJ(\d+)\(', args[2])
            if mk is None:
                return None
            k = int(mk.group(1))
            if fname == 'var_winp_u8.bend':
                return DR.WordsDec(e, any_=lambda kk: f'DZ.ct_dec({args[0]}, t, {args[3]}, {args[4]}, {kk}, {{==}}, hy{k})',
                                   facts=[(r'Nat\.is_lt\(U32\.to_nat\(\w+\.len\(\w+\)\), VB\.pw\(31n\)\)', f'hl{k}')])
            if fname == 'var_winp_pl_u64.bend':
                Lw = args[4]
                f = DR.u64_list_facts(Lw, f'{CH1}.CQ({Lw})', f'{CH1}.eLc(t, {args[2]}, {args[3]}, {Lw}, {hc(k)})', None, None, None, None, None)
                return DR.WordsDec(e, any_=lambda kk: f'DZ.ct_dec({args[0]}, t, {args[3]}, {Lw}, {kk}, {{==}}, hy{k})',
                                   facts=[(r'U32\.to_nat\(\w+\.len\(o\)\) == \w+\.e8\(\w+\.ucnt\(o\)\)', f['facts'][0][1]), (r'Nat\.is_lt\(U32\.to_nat\(\w+\.len\(\w+\)\), VB\.pw\(31n\)\)', f'hl{k}')])
            if fname == 'var_winx_pl_SmallTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRL_pl_SmallTestStruct'): lambda _: f'{DFL}.sdl({a}, hl{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_SmallTestStruct'): lambda s_: f'{DFL}.rep({a}, {s_}, hl{k}, {hc(k)})'})
            if fname == 'vvl_pl_pl_VarTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRV_pl_pl_VarTestStruct'): lambda _: f'{DVP}.sdl({a}, {WF(k)}, hl{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_pl_VarTestStruct'): lambda s_: f'{DVP}.rep({a}, {WF(k)}, hl{k}, {s_}, {{==}}, {hc(k)})'})
            return None
        return out, None, None, None, xleaf
    imap = {}

    def fal(path):
        imap.setdefault(path, f'M{len(imap)}')
        return imap[path]
    V = setup(fal)
    imps = [*import_list('Base FD VB VC A DC=var_codec_ProgressiveTestStruct EQ=e2e_encq2d')] + \
           [f"import {'./' + pth[4:] if pth.startswith('e2e/') else '../' + pth} as {a_}" for pth, a_ in imap.items()]
    txt = ('\n'.join(imps) + '\n\n# GENERATED by e2e_compose (codegen: e2e_decrep_x). Do not edit.\n# ProgressiveTestStruct: its total-size premise (17 + the four windows\' lengths < 2^31), from the windows\' size laws.\n\n'
           + 'def totp(' + ps + ')\n    -> EQ.TOT_ProgressiveTestStruct(DC.OBJ(d, t, n)):\n'
           + '\n'.join('  ' + l for l in V['out'][:1] + [x for x in V['out'][1:] if x.startswith('+lw') or x.startswith('+hl')]) + '\n  ' + V['H2'] + '\n')
    DR.EXTRA_FILES[DR.ROOT / 'e2e' / 'e2e_dpt_tot.bend'] = txt
    return DR.container_file(name, lf, 'proofs/obj/var_codec_ProgressiveTestStruct.bend', 'OBJ', {'d': 'd', 't': 't', 'n': 'n'}, (['d', 't', 'n'], ps), lets, None,
                             'proofs/obj/var_codec_ProgressiveTestStruct.bend')


def prog_complex_test_struct(lf):
    """ProgressiveComplexTestStruct: A uint8, B List[uint16, 123], C a progressive bit list, D pl_u64, E pl_SmallTestStruct, F pl_pl_VarTestStruct,
    G List[ProgressiveSingleFieldContainerTestStruct, 10], H pl_ProgressiveVarTestStruct: windows of the container's. The theorem takes 258 + n < 2^29: the size bound
    TOT (the bit list's 2^29 + 1 and the bounds 246 and 10 of the two bounded lists, with the other windows' lengths) is at most 257 + n + 2^29 + 1."""
    from codegen.proofs.composed import e2e_decrep as DR
    name = 'ProgressiveComplexTestStruct'
    h = '{Nat.is_lt(Nat.add(258n, U32.to_nat(n)), VB.pw(29n)) == True{} : Bool}'
    DR.BUF.depth_first.add(name)
    DR.HEAVY[name] = h
    ps = DR.buf_ps(h)

    def setup(al):
        BW = al('proofs/obj/var_winx_ProgressiveComplexTestStruct.bend')
        CH2 = al('proofs/obj/var_winp_pl_u64.bend')
        DPQ, DFL, DFL10 = al('e2e/e2e_dpq.bend'), al('e2e/e2e_dfl_pl_SmallTestStruct.bend'), al('e2e/e2e_dfl_l10_ProgressiveSingleFieldContainerTestStruct.bend')
        DVP, DVPP = al('e2e/e2e_dvp_pl_pl_VarTestStruct.bend'), al('e2e/e2e_dvp_pl_ProgressiveVarTestStruct.bend')
        al('proofs/obj/words_spec.bend')
        X = lambda j: f'{BW}.XJ{j}(t, 0n)'  # noqa: E731
        F = lambda j: f'{BW}.FJ{j}(0, t, 0n)'  # noqa: E731
        L = lambda j: f'{BW}.LJ{j}(t, 0n)' if j < 6 else f'{BW}.LJ6(t, 0n, n)'  # noqa: E731
        hc = lambda j: f'{BW}.itD{j}(t, 0n, 0, n, hchk)'  # noqa: E731
        com = f'd, t, n, 0n, 0, n, {{==}}, hd, hn, {DR.HWN_TOP}, pf, hchk'
        out = ['+hn29 = FD.nat__le_lt_trans(U32.to_nat(n), Nat.add(258n, U32.to_nat(n)), VB.pw(29n), A.le_skip(258n, U32.to_nat(n)), h31)',
               ]
        for k in range(7):
            Ok, Ek = f'{BW}.O{k}(t, 0n)', (f'{BW}.O{k + 1}(t, 0n)' if k < 6 else 'n')
            out += [f'+lw{k} = {DPQ}.lwd({Ok}, {Ek}, n, {BW}.r1{k}(t, 0n, 0, n, hchk), {BW}.r2{k}(t, 0n, 0, n, hchk))',
                    f'+hy{k} = VC.hyW(0n, {L(k)}, FD.nat__le_trans(U32.to_nat({L(k)}), U32.to_nat(n), U32.to_nat(VB.NMAX()), lw{k}, {DR.HWN_TOP}))',
                    f'+hl{k} = FD.nat__le_lt_trans(U32.to_nat({L(k)}), U32.to_nat(n), VB.pw(29n), lw{k}, hn29)',
                    f'+hh{k} = VB.le_pw_lt(U32.to_nat({L(k)}), 30n, FD.nat__lt_le(U32.to_nat({L(k)}), VB.pw(30n), VB.le_pw_lt(U32.to_nat({L(k)}), 29n, FD.nat__lt_le(U32.to_nat({L(k)}), VB.pw(29n), hl{k}))))']
        WF = lambda j, w32: f'{BW}.eoJ{j}D({com}), hd, {BW}.hwJ{j}D({com}), {BW}.hwJ{j}{w32}({com}), pf'  # noqa: E731
        return locals()

    def lets(al):
        V = setup(al)
        BW, CH2, DFL, DFL10, DVP, DVPP, X, F, L, hc, WF, out = (V[k] for k in ('BW', 'CH2', 'DFL', 'DFL10', 'DVP', 'DVPP', 'X', 'F', 'L', 'hc', 'WF', 'out'))
        PTOT = al('e2e/e2e_dpx_tot.bend')
        DR.TOT_HOOK[name] = lambda p: (f'{PTOT}.totc(d, t, n, pf, hd, hn, h31, hS, hchk)'
                                       if re.match(r'^\{Nat\.is_lt\(Nat\.add\(Nat\.add\(Nat\.add\(Nat\.add\(Nat\.add\(Nat\.add\(Nat\.add\(30n, 246n\)', p.strip()) else None)

        def xleaf(fname, fn, args, e):
            if fn != 'OBJw':
                return None
            a = ', '.join(args)
            mk = re.match(r'[\w.]+\.XJ(\d+)\(', args[2])
            if mk is None:
                return None
            k = int(mk.group(1))
            mu = re.fullmatch(r'var_winx_l(\d+)_u16\.bend', fname)
            if mu:
                return DR.u16_child(al, BW, args, e, int(mu.group(1)), fname, DR.PB_TOP)
            if fname == 'var_winp_pbits.bend':
                return DR.pb_child(al, BW, args, e, 'd', dict(DR.PB_TOP, h31='hn29'))
            if fname == 'var_winp_pl_u64.bend':
                Lw = args[4]
                f = DR.u64_list_facts(Lw, f'{CH2}.CQ({Lw})', f'{CH2}.eLc(t, {args[2]}, {args[3]}, {Lw}, {hc(k)})', None, None, None, None, None)
                return DR.WordsDec(e, any_=lambda kk: f'DZ.ct_dec({args[0]}, t, {args[3]}, {Lw}, {kk}, {{==}}, hy{k})',
                                   facts=[(r'U32\.to_nat\(\w+\.len\(o\)\) == \w+\.e8\(\w+\.ucnt\(o\)\)', f['facts'][0][1]),
                                          (r'Nat\.is_lt\(U32\.to_nat\(\w+\.len\(\w+\)\), VB\.pw\(31n\)\)', f'hh{k}')])
            if fname == 'var_winx_pl_SmallTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRL_pl_SmallTestStruct'): lambda _: f'{DFL}.sdl({a}, hh{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_SmallTestStruct'): lambda s_: f'{DFL}.rep({a}, {s_}, hh{k}, {hc(k)})'})
            if fname == 'vvl_pl_pl_VarTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRV_pl_pl_VarTestStruct'): lambda _: f'{DVP}.sdl({a}, {WF(k, "_32")}, hh{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_pl_VarTestStruct'): lambda s_: f'{DVP}.rep({a}, {WF(k, "_32")}, hh{k}, {s_}, {{==}}, {hc(k)})'})
            if fname == 'var_winx_l10_ProgressiveSingleFieldContainerTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRL_l10_ProgressiveSingleFieldContainerTestStruct'): lambda _: f'{DFL10}.sdl({a}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_l10_ProgressiveSingleFieldContainerTestStruct'): lambda s_: f'{DFL10}.rep({a}, {s_}, {{==}}, {hc(k)})'})
            if fname == 'vvl_pl_ProgressiveVarTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRV_pl_ProgressiveVarTestStruct'): lambda _: f'{DVPP}.sdl({a}, {WF(k, "N")}, hl{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_ProgressiveVarTestStruct'): lambda s_: f'{DVPP}.rep({a}, {WF(k, "N")}, hl{k}, {s_}, {{==}}, {hc(k)})'})
            return None
        return out, None, None, None, xleaf

    # the total-size premise, in its own file (inlined it overflows the checker's stack)
    imap = {}

    def fal(path):
        imap.setdefault(path, f'M{len(imap)}')
        return imap[path]
    V = setup(fal)
    BW = V['BW']
    X, F, L, hc, WF = V['X'], V['F'], V['L'], V['hc'], V['WF']
    DPX, DPT, DFL, DVP, DVPP, WT = fal('e2e/e2e_dpx.bend'), fal('e2e/e2e_dpt.bend'), V['DFL'], V['DVP'], V['DVPP'], fal('e2e/e2e_wit.bend')
    EL_, CH1 = fal('e2e/e2e_encld.bend'), fal('proofs/obj/var_winp_pbits.bend')
    CH3, CH4, CH6 = fal('proofs/obj/var_winx_pl_SmallTestStruct.bend'), fal('proofs/obj/vvl_pl_pl_VarTestStruct.bend'), fal('proofs/obj/vvl_pl_ProgressiveVarTestStruct.bend')
    Lt = lambda j: f'U32.to_nat({L(j)})'  # noqa: E731
    Q = 'Nat.add(VB.pw(29n), 1n)'
    QPt = f'EQ.QP({CH1}.OBJw(d, t, {X(1)}, {F(1)}, {L(1)}))'
    QR3 = f'{EL_}.QR_pl_SmallTestStruct({CH3}.OBJw(d, t, {X(3)}, {F(3)}, {L(3)}))'
    QV4 = f'{EL_}.QV_pl_pl_VarTestStruct({CH4}.OBJw(d, t, {X(4)}, {F(4)}, {L(4)}))'
    QV6 = f'{EL_}.QV_pl_ProgressiveVarTestStruct({CH6}.OBJw(d, t, {X(6)}, {F(6)}, {L(6)}))'
    S_ = lambda q, l2, l3, l4, l6: f'Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(30n, 246n), {q}), {l2}), {l3}), {l4}), 10n), {l6})'  # noqa: E731
    l2, l3, l4, l6 = Lt(2), Lt(3), Lt(4), Lt(6)
    Wr = f'Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(30n, 246n), {l2}), {l3}), {l4}), 10n), {l6})'
    # QP moved last: one swap per later term (l2, l3, l4, 10, l6)
    terms = [l2, l3, l4, '10n', l6]
    # build the chain explicitly
    U = [f'Nat.add({"Nat.add(30n, 246n)"}, {Q})']
    Wl = ['Nat.add(30n, 246n)']
    for tm in terms:
        U.append(f'Nat.add({U[-1]}, {tm})')
        Wl.append(f'Nat.add({Wl[-1]}, {tm})')
    pf = None
    for i, tm in enumerate(terms):
        step = f'{WT}.swapq({Wl[i]}, {Q}, {tm})'
        if pf is None:
            pf = step
        else:
            pf = (f'Equal.trans(Nat, {U[i + 1]}, Nat.add(Nat.add({Wl[i]}, {Q}), {tm}), Nat.add({Wl[i + 1]}, {Q}), '
                  f'Equal.cong(Nat, Nat, z => Nat.add(z, {tm}), {U[i]}, Nat.add({Wl[i]}, {Q}), {pf}), {step})')
    assert U[-1] == S_(Q, l2, l3, l4, l6) and Wl[-1] == Wr
    lens = ', '.join(Lt(j) for j in range(7))
    hle = f'{DPX}.leW({lens})'
    nn = f'{DPX}.tot(t, 0n, 0, n, hchk)'
    mot = lambda z: f'z => {{Nat.is_le({Wr}, Nat.add(257n, {z})) == True{{}} : Bool}}'  # noqa: E731
    Nsum = f'Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(Nat.add(29n, {Lt(0)}), {Lt(1)}), {Lt(2)}), {Lt(3)}), {Lt(4)}), {Lt(5)}), {Lt(6)})'
    le1 = f'FD.logic__subst(Nat, {mot("z")}, {Nsum}, U32.to_nat(n), {nn}, {hle})'
    le2 = f'Order.add_left(1n, {Wr}, Nat.add(257n, U32.to_nat(n)), {le1})'
    le3 = (f'FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add(258n, U32.to_nat(n))) == True{{}} : Bool}}, Nat.add(1n, {Wr}), Nat.add({Wr}, 1n), FD.nat__add_comm(1n, {Wr}), {le2})')
    hrw = f'FD.nat__le_lt_trans(Nat.add({Wr}, 1n), Nat.add(258n, U32.to_nat(n)), VB.pw(29n), {le3}, h31)'
    P0 = f'{WT}.tot29({Wr}, {Q}, {{==}}, {hrw})'
    P1 = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(31n)) == True{{}} : Bool}}, Nat.add({Wr}, {Q}), {S_(Q, l2, l3, l4, l6)}, '
          f'Equal.sym(Nat, {S_(Q, l2, l3, l4, l6)}, Nat.add({Wr}, {Q}), {pf}), {P0})')
    mt = lambda q, a, b, c, d_: f'{{Nat.is_lt({S_(q, a, b, c, d_)}, VB.pw(31n)) == True{{}} : Bool}}'  # noqa: E731
    qp_eq = 'qp_eq(' + f'{CH1}.OBJw(d, t, {X(1)}, {F(1)}, {L(1)}))'
    P2 = f'FD.logic__subst(Nat, z => {mt("z", l2, l3, l4, l6)}, {Q}, {QPt}, Equal.sym(Nat, {QPt}, {Q}, {qp_eq}), {P1})'
    sz3 = f'{DFL}.szl(d, t, {X(3)}, {F(3)}, {L(3)}, {hc(3)})'
    P3 = f'FD.logic__subst(Nat, z => {mt(QPt, l2, "z", l4, l6)}, {l3}, {QR3}, Equal.sym(Nat, {QR3}, {l3}, {sz3}), {P2})'
    OBJ4 = f'{CH4}.OBJw(d, t, {X(4)}, {F(4)}, {L(4)})'
    sz4 = f'{DVP}.szl(d, t, {X(4)}, {F(4)}, {L(4)}, {WF(4, "_32")}, hh4, {hc(4)})'
    P4 = (f'FD.logic__subst(Nat, z => {mt(QPt, l2, QR3, "z", l6)}, {l4}, {QV4}, Equal.sym(Nat, {QV4}, {l4}, Equal.trans(Nat, {QV4}, {DPT}.DVPLNQ, {l4}, {DPT}.qvl({OBJ4}), {sz4})), {P3})')
    P4 = P4.replace(f'{DPT}.DVPLNQ', f'{DVP}.LNQ({OBJ4})')
    OBJ6 = f'{CH6}.OBJw(d, t, {X(6)}, {F(6)}, {L(6)})'
    sz6 = f'{DVPP}.szl(d, t, {X(6)}, {F(6)}, {L(6)}, {WF(6, "N")}, hl6, {hc(6)})'
    P5 = (f'FD.logic__subst(Nat, z => {mt(QPt, l2, QR3, QV4, "z")}, {l6}, {QV6}, Equal.sym(Nat, {QV6}, {l6}, Equal.trans(Nat, {QV6}, {DVPP}.LNQ({OBJ6}), {l6}, {DPX}.qvl2({OBJ6}), {sz6})), {P4})')
    # the premise's terms are those of the decoded object's fields (RT.pj_k(DC.OBJ(d, t, n))): each leaf converted on its own
    RTa, WOa = fal('proofs/obj/root_gtypes2_light.bend'), fal('proofs/obj/words_obj_light.bend')
    pjk = lambda i: f'{RTa}.pj_ProgressiveComplexTestStruct_{i}(DC.OBJ(d, t, n))'  # noqa: E731
    T_QP, T_l2, T_QR, T_QV4, T_QV6 = f'EQ.QP({pjk(2)})', f'U32.to_nat({WOa}.len({pjk(3)}))', f'{EL_}.QR_pl_SmallTestStruct({pjk(4)})', f'{EL_}.QV_pl_pl_VarTestStruct({pjk(5)})', f'{EL_}.QV_pl_ProgressiveVarTestStruct({pjk(7)})'
    Pa = f'FD.logic__subst(Nat, z => {mt("z", l2, QR3, QV4, QV6)}, {QPt}, {T_QP}, {{==}}, {P5})'
    Pb = f'FD.logic__subst(Nat, z => {mt(T_QP, "z", QR3, QV4, QV6)}, {l2}, {T_l2}, {{==}}, {Pa})'
    Pc = f'FD.logic__subst(Nat, z => {mt(T_QP, T_l2, "z", QV4, QV6)}, {QR3}, {T_QR}, {{==}}, {Pb})'
    Pd = f'FD.logic__subst(Nat, z => {mt(T_QP, T_l2, T_QR, "z", QV6)}, {QV4}, {T_QV4}, {{==}}, {Pc})'
    Pe = f'FD.logic__subst(Nat, z => {mt(T_QP, T_l2, T_QR, T_QV4, "z")}, {QV6}, {T_QV6}, {{==}}, {Pd})'
    imps = [*import_list('Base O FD A Order VB VC DC=var_codec_ProgressiveComplexTestStruct EQ=e2e_encq2d')] + \
           [f"import {'./' + pth[4:] if pth.startswith('e2e/') else '../' + pth} as {a_}" for pth, a_ in imap.items()]
    keep = [x for x in V['out'] if x.startswith('+hn29') or x.startswith('+mono') or x.startswith('+lw') or x.startswith('+hl') or x.startswith('+hh')]
    txt = ('\n'.join(imps) + '\n\n# GENERATED by e2e_compose (codegen: e2e_decrep_x). Do not edit.\n# ProgressiveComplexTestStruct: its total-size premise (the bit list\'s 2^29 + 1, the bounds 246 and 10 and the other windows\' lengths < 2^31), from the windows\' size laws.\n\n'
           + 'def qp_eq(o: O.Bits) -> {EQ.QP(o) == ' + Q + ' : Nat}:\n  match o:\n    case O.Bits{arr, +K}: {==}\n\n'
           + 'def totc(' + ps + ')\n    -> EQ.TOT_ProgressiveComplexTestStruct(DC.OBJ(d, t, n)):\n'
           + '\n'.join('  ' + l for l in keep) + '\n  ' + Pe + '\n')
    DR.EXTRA_FILES[DR.ROOT / 'e2e' / 'e2e_dpx_tot.bend'] = txt
    return DR.container_file(name, lf, 'proofs/obj/var_codec_ProgressiveComplexTestStruct.bend', 'OBJ', {'d': 'd', 't': 't', 'n': 'n'}, (['d', 't', 'n'], ps), lets, None,
                             'proofs/obj/var_codec_ProgressiveComplexTestStruct.bend')


EXTRA_PROVERS = {
    'ComplexTestStruct': lambda lf: complex_test_struct(lf),
    'ProgressiveTestStruct': lambda lf: prog_test_struct(lf),
    'ProgressiveComplexTestStruct': lambda lf: prog_complex_test_struct(lf),
}
