"""Provers of e2e_decrep's PROVERS table that are kept apart from it (EXTRA_PROVERS): the (i)/(iv) premises of the decoded object of a name
(DC.OBJ), for every input the codec accepts. The helpers are e2e_decrep's.

ComplexTestStruct: A uint16, B List[uint16, 128], C uint8, D ByteList[256], E VarTestStruct, F Vector[FixedTestStruct, 4], G Vector[VarTestStruct, 2].
B, D and the list of E are windows read by the dec bridge's reader (their storage and representation: the u16 / byte list laws of e2e_dz, e2e_dpl),
E is the VarTestStruct window reader's object (a nested window: the inner list's window is the one of E's field), F is e2e_dfv4.bend's (the
four copied records) and G e2e_dvv2.bend's (the two-element vector the check of the window fixes)."""

import re


def complex_test_struct(lf):
    import e2e_decrep as DR
    name = 'ComplexTestStruct'
    DR.BUF_D.add(name)
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
    import e2e_decrep as DR
    name = 'ProgressiveTestStruct'
    h = '{Nat.is_lt(Nat.add(1n, U32.to_nat(n)), VB.pw(31n)) == True{} : Bool}'
    DR.BUF_D.add(name)
    DR.HEAVY[name] = h
    ps = DR.buf_ps(h)

    def lets(al):
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
        sz3 = f'{DVP}.szl(d, t, {X(3)}, {F(3)}, {L(3)}, {WF(3)}, hl3, {hc(3)})'
        sz2 = f'{DFL}.szl(d, t, {X(2)}, {F(2)}, {L(2)}, {hc(2)})'
        H1 = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add({a}{b}), z), VB.pw(31n)) == True{{}} : Bool}}, {c}, {QV3}, Equal.sym(Nat, {QV3}, {c}, {sz3}), {H0})')
        H2 = (f'FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add({a}z), {QV3}), VB.pw(31n)) == True{{}} : Bool}}, {b}, {QR2}, Equal.sym(Nat, {QR2}, {b}, {sz2}), {H1})')
        DR.TOT_HOOK[name] = lambda p: H2 if re.match(r'^\{Nat\.is_lt\(Nat\.add\(Nat\.add\(Nat\.add\(Nat\.add\(17n, ', p.strip()) else None

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
                                   facts=[f['facts'][0], (r'Nat\.is_lt\(U32\.to_nat\(\w+\.len\(\w+\)\), VB\.pw\(31n\)\)', f'hl{k}')])
            if fname == 'var_winx_pl_SmallTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRL_pl_SmallTestStruct'): lambda _: f'{DFL}.sdl({a}, hl{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_SmallTestStruct'): lambda s_: f'{DFL}.rep({a}, {s_}, hl{k}, {hc(k)})'})
            if fname == 'vvl_pl_pl_VarTestStruct.bend':
                return DR.FxWords(e, {('e2e_encld.bend', 'PRV_pl_pl_VarTestStruct'): lambda _: f'{DVP}.sdl({a}, {WF(k)}, hl{k}, {hc(k)})',
                                      ('root_gtypes2_light.bend', 'rep_pl_pl_VarTestStruct'): lambda s_: f'{DVP}.rep({a}, {WF(k)}, hl{k}, {s_}, {{==}}, {hc(k)})'})
            return None
        return out, None, None, None, xleaf
    return DR.container_file(name, lf, 'proofs/obj/var_codec_ProgressiveTestStruct.bend', 'OBJ', {'d': 'd', 't': 't', 'n': 'n'}, (['d', 't', 'n'], ps), lets, None,
                             'proofs/obj/var_codec_ProgressiveTestStruct.bend')


EXTRA_PROVERS = {
    'ComplexTestStruct': lambda lf: complex_test_struct(lf),
    'ProgressiveTestStruct': lambda lf: prog_test_struct(lf),
}
