#!/usr/bin/env python3
"""The encoder laws of containers written by codegen/var_cont_enc.py, at X = 0.

    python3 codegen/var_cont_top.py [--check] [--no-big]

proofs/obj/big_var_codec_<C>_enc.bend (generated) for C in TOPS, on the container's encoder window
big_encx_<C> (K) and its interface section big_encx_<C>_iface (CI: the mirror MW, OK, TH, VAL, ENC):

  encode_eval   T.<C>_encode(TH(m)) == (TH(m), B.Buf{thaw(OUTE(m)), SZSM(m)}), the output tree the
                window's model at X = 0 of a zero tree of the size's depth;
  encode_spec   Decoding.decodes(Spec.<C>(), the buffer's bytes, VAL(m)).

The runtime's size pass (T.<C>_size) is rewritten through the children's sizex facts (its chain of
T.<C>_sz* / group _sz* helpers, as codegen/generate.py emits them); its value is the byte count
ENDC (the interface's), with the exponent of the bound kept symbolic (k = 28).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))

import var_cont_enc as CE  # noqa: E402

TOPS = ['ExecutionPayload', 'BeaconBlockBody']
SIZES = ['ExecutionPayload', 'ExecutionPayloadHeader', 'BeaconBlockBody']
# the generic wide containers' size modules (their interfaces state no sizex; gtop_text imports these)
GSIZES = ['Gc60805EC295']
TRUE = 'True{} : Bool'


def out_file(C):
    return ROOT / f'proofs/obj/big_var_codec_{C}_enc.bend'


def iface_params(C):
    txt = (ROOT / f'proofs/obj/big_encx_{C}_iface.bend').read_text()
    m = re.search(r'^def OKT\((.*?)\) -> Bool:', txt, re.M)
    P = m.group(1)
    names = [x.split(':')[0].strip().lstrip('+') for x in CE_split(P)]
    imps = [ln for ln in txt.split('\n') if ln.startswith('import ')]
    return P, names, imps


def CE_split(s):
    out, cur, d = [], '', 0
    for ch in s:
        if ch in '<({':
            d += 1
        elif ch in '>)}':
            d -= 1
        if ch == ',' and d == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    out.append(cur)
    return out


def top_text(C, generic=False):
    import generate as G
    import schema
    if generic:
        # a generic wide container (GSIZES): its size module only, from generic_obj
        import generic as GN
        g, names = G.Gen(), {n: t for n, t, err in GN.inventory_all() if err is None}
        if CE.SRC_FILE != 'types/generic_obj.bend':
            CE.SRC, CE.SRC_FILE = None, 'types/generic_obj.bend'
    else:
        g, names = G.Gen(), schema.load(ROOT / 'codegen/fulu.yaml')
        if CE.SRC_FILE != 'types/fulu_obj.bend':
            CE.SRC, CE.SRC_FILE = None, 'types/fulu_obj.bend'
    for n, t in names.items():
        g.shape(t)
    K = CE.Cont(g, names, C)
    P, OA, imps = iface_params(C)
    OAS = ', '.join(OA)
    F, FIX, p = K.F, K.fixed, K.p
    fnames = [f for f, _ in F]
    # the objects of the fields (as var_cont_enc's generate_cont builds them)
    OBJF = {}
    for f, fs in F:
        if fs.fixed and fs.data:
            OBJF[f] = f
        elif fs.fixed and fs.kind == 'fixwords':
            OBJF[f] = f'O.Words{{FD.array__thaw(U32, TB_{f}), {fs.fsize}}}'
        elif f in K.fixw:
            OBJF[f] = K.fixw[f].obj
        else:
            OBJF[f] = K.children[f].obj
    groups = [(k // CE.GROUP, list(range(k, min(k + CE.GROUP, len(F))))) for k in range(0, len(F), CE.GROUP)] if K.wide else []
    gobj = {gk: f'T.{p}_g{gk}{{' + ', '.join(OBJF[fnames[i]] for i in idx) + '}' for gk, idx in groups}
    OBJ = f'K.OBJC({OAS})'
    plain_steps = None
    if not K.wide:
        # a plain container: sz<s>(others..., acc, z) over its variable fields, acc from the fixed part's size
        plain_steps, pfacts, acc = [], [], str(FIX)
        for s_, i in enumerate([i for i in range(len(F)) if not F[i][1].fixed]):
            f = fnames[i]
            ch = K.children[f]
            ps = CE.fn_params(f'{p}_sz{s_}')
            mp = {x: OBJF[x] for x in fnames}
            mp['acc'] = acc
            outer = f'T.{p}_sz{s_}(' + ', '.join(mp[x] if x != 'pair' else 'z' for x in ps) + ')'
            sz = size_term(ch)
            plain_steps.append((outer, f'T.{ch.p}_size({ch.obj})', f'({ch.obj}, {sz})', f'{ch.vt} & U32'))
            pfacts.append((f, ch, sz))
            acc = f'O.padd({acc}, {sz})'
        plain_tot = acc
    # the size pass: the linear groups' sizes in order (emit_wide), each group's variable fields in order (emit_fieldset)
    lin = [(gk, idx) for gk, idx in groups if any(not F[i][1].data for i in idx)]
    var_of = {gk: [i for i in idx if not F[i][1].fixed] for gk, idx in groups}
    steps, facts, sizes = [], [], {}
    tacc = str(FIX)
    for j, (gk, idx) in enumerate(lin):
        gp = f'{p}_g{gk}'
        # the top step's context: sz<j>(others..., acc, z)
        tparams = CE.fn_params(f'{p}_sz{j}')
        if j > 0:
            tacc = f'O.padd({tacc}, {sizes[lin[j - 1][0]]})'
        gmap = {f'g{g2}': gobj[g2] for g2, _ in groups}
        gmap['acc'] = tacc
        vs = var_of[gk]
        acc = '0'
        for s, i in enumerate(vs):
            f = fnames[i]
            ch = K.children[f]
            ps = CE.fn_params(f'{gp}_sz{s}')
            mp = {fnames[i2]: OBJF[fnames[i2]] for i2 in idx}
            mp['acc'] = acc
            inner = f'T.{gp}_sz{s}(' + ', '.join(mp[x] if x != 'pair' else 'z' for x in ps) + ')'
            outer = f'T.{p}_sz{j}(' + ', '.join(gmap[x] if x != 'pair' else inner for x in tparams) + ')'
            lhs = f'T.{ch.p}_size({ch.obj})'
            sz = size_term(ch)
            rhs = f'({ch.obj}, {sz})'
            steps.append((outer, lhs, rhs, f'{ch.vt} & U32'))
            facts.append((f, ch, sz))
            acc = f'O.padd({acc}, {sz})'
        sizes[gk] = acc
    if plain_steps is not None:
        steps, facts, tot = plain_steps, pfacts, plain_tot
    else:
        tot = f'O.padd({tacc}, {sizes[lin[-1][0]]})'
    L = []
    w = L.append
    RT = f'T.{C} & U32'
    FPS = []
    for f, ch, sz in facts:
        FPS.append(f'+s_{f}: {{T.{ch.p}_size({ch.obj}) == ({ch.obj}, {sz}) : {ch.vt} & U32}}')
    start = f'T.{p}_size({OBJ})'
    end = f'({OBJ}, SZS({OAS}))'

    def chain(k, first):
        outer, lhs, rhs, ity = steps[k]
        e = f'Equal.cong({ity}, {RT}, z => {outer}, {lhs}, {rhs}, s_{facts[k][0]})'
        if k == len(steps) - 1:
            return e
        after = outer.replace('z)', rhs + ')', 1) if False else outer.replace(', z)', f', {rhs})')
        nxt = steps[k + 1][0].replace(', z)', f', {steps[k + 1][1]})')
        return f'Equal.trans({RT}, {first}, {after}, {end}, {e}, {chain(k + 1, nxt)})'
    # the byte counts
    LN = {f: len_term(ch) for f, ch, sz in facts}
    ENDC = f'CI.ENDC({OAS})'
    w(f'''
# ---- {C}: the runtime's size pass ----
def SZS({P}) -> U32: {tot}

def rt_size({P},
    {(", " + chr(10) + "    ").join(FPS)})
    -> {{{start} == {end} : {RT}}}:
  {chain(0, steps[0][0].replace(', z)', f', {steps[0][1]})'))}

def sizeC({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}) -> {{{start} == {end} : {RT}}}:
  rt_size({OAS}, {", ".join(sizex_term(f, ch) for f, ch, sz in facts)})
''')
    # the size's value: the byte count
    Ls = [LN[f] for f, _, _ in facts]
    SZt = [sz for _, _, sz in facts]
    Q = 'A.quad(VB.pw(k))'
    E = [Ls[0]]
    for x in Ls[1:]:
        E.append(f'Nat.add({E[-1]}, {x})')
    E4 = f'Nat.add({FIX}n, {E[-1]})'
    PT = ['0']
    for sz in SZt:
        PT.append(f'O.padd({PT[-1]}, {sz})')
    if plain_steps is not None:
        # E_0 = FIX, E_(s+1) = E_s + L_s (the interface's ENDC is E_n); C_0 = FIX, C_(s+1) = padd(C_s, size_s)
        ls = []
        a = ls.append
        n = len(Ls)
        EP_ = [f'{FIX}n']
        CP_ = [str(FIX)]
        for i2 in range(n):
            EP_.append(f'Nat.add({EP_[-1]}, {Ls[i2]})')
            CP_.append(f'O.padd({CP_[-1]}, {SZt[i2]})')
        a(f'+bnd = CI.okbk({OAS}, h, k, ek)')
        a(f'+hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}})')
        a(f'+b{n} = bnd')
        for i2 in range(n - 1, 0, -1):
            a(f'+b{i2} = FD.nat__le_trans({EP_[i2]}, {EP_[i2 + 1]}, {Q}, Order.below_sum({EP_[i2]}, {Ls[i2]}), b{i2 + 1})')
        for i2, (f, ch, sz) in enumerate(facts):
            a(f'+bl{i2} = FD.nat__le_trans({Ls[i2]}, {EP_[i2 + 1]}, {Q}, Order.left_below_sum({EP_[i2]}, {Ls[i2]}), b{i2 + 1})')
            a(f'+z{i2} = {szx_term(f, ch, f"bl{i2}")}')
        for i2 in range(n):
            cur, sz = CP_[i2], SZt[i2]
            ec = '{==}' if i2 == 0 else f'c{i2 - 1}'
            a(f'+ea{i2} = Equal.trans(Nat, Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), Nat.add({EP_[i2]}, U32.to_nat({sz})), {EP_[i2 + 1]}, '
              f'Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat({sz})), U32.to_nat({cur}), {EP_[i2]}, {ec}), Equal.cong(Nat, Nat, z => Nat.add({EP_[i2]}, z), U32.to_nat({sz}), {Ls[i2]}, z{i2}))')
            a(f'+c{i2} = Equal.trans(Nat, U32.to_nat(O.padd({cur}, {sz})), Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), {EP_[i2 + 1]}, '
              f'VCN.padd_dd({cur}, {sz}, k, hk, FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE}}}, {EP_[i2 + 1]}, Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), '
              f'Equal.sym(Nat, Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), {EP_[i2 + 1]}, ea{i2}), b{i2 + 1})), ea{i2})')
        body = '\n  '.join(ls)
        w(f'''
# The size pass's value is the byte count.
def szS({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{U32.to_nat(SZS({OAS})) == {ENDC} : Nat}}:
  {body}
  c{n - 1}
''')
    else:
        # the size pass's value as a tree of padd over the fields' sizes: its Nat twin, bounded by the byte count
        ls = []
        a = ls.append
        a(f'+bnd = CI.okbk({OAS}, h, k, ek)')
        a(f'+hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}})')
        it = iter(range(len(facts)))
        atoms = {}
        for i2, (f, ch, sz) in enumerate(facts):
            atoms[f] = i2

        def gtree(gk):
            t = ('lit', '0', '0n')
            for i in var_of[gk]:
                t = ('padd', t, ('atom', atoms[fnames[i]]))
            return t
        T = ('lit', str(FIX), f'{FIX}n')
        for gk, _ in lin:
            T = ('padd', T, gtree(gk))

        def u32(t):
            if t[0] == 'lit':
                return t[1]
            if t[0] == 'atom':
                return SZt[t[1]]
            return f'O.padd({u32(t[1])}, {u32(t[2])})'

        def nat(t):
            if t[0] == 'lit':
                return t[2]
            if t[0] == 'atom':
                return Ls[t[1]]
            return f'Nat.add({nat(t[1])}, {nat(t[2])})'
        assert u32(T) == tot, (u32(T), tot)
        # N == ENDC: fold each group's sum into the running left-associated sum
        cnt = [0]

        def fresh(pre):
            cnt[0] += 1
            return f'{pre}{cnt[0]}'

        def flat(X, Ls_):
            """(Nat.add(X, G(Ls_)) == X + L1 + ... + Ln left-associated, as a let name; the right side)"""
            if not Ls_:
                return None, X
            G = Ls_[0]
            for x in Ls_[1:]:
                G = f'Nat.add({G}, {x})'
            if len(Ls_) == 1:
                return '{==}', f'Nat.add({X}, {Ls_[0]})'
            pr, rhs0 = flat(X, Ls_[:-1])
            Gp = Ls_[0]
            for x in Ls_[1:-1]:
                Gp = f'Nat.add({Gp}, {x})'
            last = Ls_[-1]
            nm = fresh('fa')
            a(f'+{nm} = Equal.trans(Nat, Nat.add({X}, Nat.add({Gp}, {last})), Nat.add(Nat.add({X}, {Gp}), {last}), Nat.add({rhs0}, {last}), '
              f'Equal.sym(Nat, Nat.add(Nat.add({X}, {Gp}), {last}), Nat.add({X}, Nat.add({Gp}, {last})), FD.nat__add_assoc({X}, {Gp}, {last})), '
              f'Equal.cong(Nat, Nat, z => Nat.add(z, {last}), Nat.add({X}, {Gp}), {rhs0}, {pr}))')
            return nm, f'Nat.add({rhs0}, {last})'
        # the tree's Nat twin: ((FIX + G0) + G1) + ...; G_j = ((0n + L) + L') ... == L + L' + ...
        Xn = f'{FIX}n'
        cur_nat = Xn
        eqs = []
        NT = Xn
        for gk, _ in lin:
            Lg = [Ls[atoms[fnames[i]]] for i in var_of[gk]]
            Gt = nat(gtree(gk))
            NT2 = f'Nat.add({NT}, {Gt})'
            if not Lg:
                # G = 0n: Nat.add(X, 0n) == X
                nm = fresh('fz')
                a(f'+{nm} = Equal.trans(Nat, {NT2}, Nat.add({cur_nat}, 0n), {cur_nat}, Equal.cong(Nat, Nat, z => Nat.add(z, 0n), {NT}, {cur_nat}, {eqs[-1] if eqs else "{==}"}), FD.nat__add_zero({cur_nat}))')
                eqs.append(nm)
                NT = NT2
                continue
            pr, rhs = flat(cur_nat, Lg)
            nm = fresh('fg')
            # Nat.add(NT, Gt) == Nat.add(cur_nat, G(Lg)) (Gt's leading 0n + L reduces) == rhs
            a(f'+{nm} = Equal.trans(Nat, {NT2}, Nat.add({cur_nat}, {Gt}), {rhs}, Equal.cong(Nat, Nat, z => Nat.add(z, {Gt}), {NT}, {cur_nat}, {eqs[-1] if eqs else "{==}"}), {pr})')
            eqs.append(nm)
            NT = NT2
            cur_nat = rhs
        assert NT == nat(T), (NT, nat(T))
        assert cur_nat == ENDC or True
        a(f'+eN = {eqs[-1]}')
        a(f'+bN = FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE}}}, {ENDC}, {NT}, Equal.sym(Nat, {NT}, {ENDC}, eN), bnd)')
        for i2, (f, ch, sz) in enumerate(facts):
            pass

        def prove(t, bname):
            """a let name proving to_nat(u32 t) == nat t; bname proves nat t <= Q"""
            if t[0] == 'lit':
                return '{==}'
            if t[0] == 'atom':
                i2 = t[1]
                f, ch, sz = facts[i2]
                nm = fresh('z')
                a(f'+{nm} = {szx_term(f, ch, bname)}')
                return nm
            l, r = t[1], t[2]
            bl = fresh('b')
            a(f'+{bl} = FD.nat__le_trans({nat(l)}, {nat(t)}, {Q}, Order.below_sum({nat(l)}, {nat(r)}), {bname})')
            br = fresh('b')
            a(f'+{br} = FD.nat__le_trans({nat(r)}, {nat(t)}, {Q}, Order.left_below_sum({nat(l)}, {nat(r)}), {bname})')
            pl = prove(l, bl)
            pr_ = prove(r, br)
            lu, ru = u32(l), u32(r)
            ea = fresh('ea')
            a(f'+{ea} = Equal.trans(Nat, Nat.add(U32.to_nat({lu}), U32.to_nat({ru})), Nat.add({nat(l)}, U32.to_nat({ru})), {nat(t)}, '
              f'Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat({ru})), U32.to_nat({lu}), {nat(l)}, {pl}), Equal.cong(Nat, Nat, z => Nat.add({nat(l)}, z), U32.to_nat({ru}), {nat(r)}, {pr_}))')
            c = fresh('c')
            a(f'+{c} = Equal.trans(Nat, U32.to_nat(O.padd({lu}, {ru})), Nat.add(U32.to_nat({lu}), U32.to_nat({ru})), {nat(t)}, '
              f'VCN.padd_dd({lu}, {ru}, k, hk, FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE}}}, {nat(t)}, Nat.add(U32.to_nat({lu}), U32.to_nat({ru})), '
              f'Equal.sym(Nat, Nat.add(U32.to_nat({lu}), U32.to_nat({ru})), {nat(t)}, {ea}), {bname})), {ea})')
            return c
        root = prove(T, 'bN')
        body = '\n  '.join(ls)
        w(f'''
# The size pass's value is the byte count.
def szS({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{U32.to_nat(SZS({OAS})) == {ENDC} : Nat}}:
  {body}
  Equal.trans(Nat, U32.to_nat(SZS({OAS})), {NT}, {ENDC}, {root}, eN)
''')
    if K.wide:
        vt_ = valid_text(C, K, P, OAS, OBJF, groups, gobj, fnames, lin)
        if vt_:
            w(vt_)
    cut = len(L)
    if C not in TOPS:
        return L, [], K, P, OA, imps
    # ---- encode_eval / encode_spec ----
    # the writer's hypotheses, as the window's putx lists them (after the object's parameters, before dd)
    ptxt = (ROOT / f'proofs/obj/big_encx_{C}.bend').read_text()
    ph = re.search(r'^def putx\((.*?)\+dd: Nat, \+D: ', ptxt, re.M | re.S).group(1)
    pn = [x.split(':')[0].strip().lstrip('+') for x in CE_split(ph.rstrip().rstrip(','))]
    HA = pn[len(OA):]
    HAC = ', '.join(f'CI.ok_{x}({OAS}, h)' for x in HA)
    S = f'SZS({OAS})'
    Dd = f'VL.DO({S})'
    MA0 = f'{OAS}, {Dd}, VC.ZT({Dd}), 0, 0n, 0n'
    LLC = f'K.LLC({MA0})'
    ENCC = f'K.ENCC({OAS})'
    OUT = f'OUTC({OAS})'
    RTT = f'Array<U32> & (T.{C} & U32)'
    w(f"""
# ---- {C} at X = 0 ----
def OUTC({P}) -> FD.array__Tree<U32>: K.PUTC({MA0})

def putx0({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}, +k: Nat, +ek: {{k == 28n : Nat}})
    -> DK.P2(K.RTC({MA0}), DK.P2(K.BYC({MA0}), DK.P2(K.PFC({MA0}), K.SZXC({MA0})))):
  +es = szS({OAS}, h, k, ek)
  +el = CI.lenE({OAS}, h)
  +elc = CI.lenC({MA0})
  +eLS = Equal.trans(Nat, {LLC}, {ENDC}, U32.to_nat({S}), Equal.trans(Nat, {LLC}, List.length(&2, U32, {ENCC}), {ENDC}, Equal.sym(Nat, List.length(&2, U32, {ENCC}), {LLC}, elc), el),
    Equal.sym(Nat, U32.to_nat({S}), {ENDC}, es))
  +hS = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(k))) == {TRUE}}}, {ENDC}, U32.to_nat({S}), Equal.sym(Nat, U32.to_nat({S}), {ENDC}, es), CI.okbk({OAS}, h, k, ek))
  +eNW = VCN.nw_nat({S}, k, FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}}), hS)
  +nw = VRX.nwn_le(U32.to_nat({S}), VB.pw(k), hS)
  +nwp = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(VC.nwu({S})), z) == {TRUE}}}, VB.pw(k), O.pow2n(k), VD.s_pow2_eq(k),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(k)) == {TRUE}}}, WD.NWN(U32.to_nat({S})), VC.NW({S}), Equal.sym(Nat, VC.NW({S}), WD.NWN(U32.to_nat({S})), eNW), nw))
  +hd = FD.nat__le_lt_trans({Dd}, k, 29n, VD.wd_min(VC.nwu({S}), k, nwp), FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}}))
  +hcov = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(VC.nwu({S})), z) == {TRUE}}}, O.pow2n({Dd}), VB.pw({Dd}), Equal.sym(Nat, VB.pw({Dd}), O.pow2n({Dd}), VD.s_pow2_eq({Dd})),
    VD.wd_cover(VC.nwu({S}), k, FD.logic__subst(Nat, z => {{Nat.is_le(z, 32n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}}), nwp))
  +hl0 = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw({Dd})) == {TRUE}}}, VC.NW({S}), WD.NWN(U32.to_nat({S})), eNW, hcov)
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(WD.NWN(z), VB.pw({Dd})) == {TRUE}}}, U32.to_nat({S}), {LLC}, Equal.sym(Nat, {LLC}, U32.to_nat({S}), eLS), hl0)
  +pf0 = FD.array__trep_perfect(U32, {Dd}, 0)
  +m = Nat.add({LLC}, WD.PADB(0n, {LLC}))
  +hm = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw({Dd}))) == {TRUE}}}, A.quad(WD.NWN({LLC})), m, Equal.sym(Nat, m, A.quad(WD.NWN({LLC})), VCN.padb_id(0n, {LLC})),
    VCN.VME4(WD.NWN({LLC}), VB.pw({Dd}), hl))
  +hz = FD.logic__subst(+List<U32>, z => {{VS.bt(m, VS.bdr(Nat.add(A.quad(0n), 0n), z)) == UW.ZB(m) : +List<U32>}}, UW.ZB(A.quad(VB.pw({Dd}))), UA.BYT(VC.ZT({Dd})),
    Equal.sym(+List<U32>, UA.BYT(VC.ZT({Dd})), UW.ZB(A.quad(VB.pw({Dd}))), UWB.zt_bytes({Dd})), VE2.bt_zb_le(m, A.quad(VB.pw({Dd})), hm))
  K.putx({OAS}, {HAC}, {Dd}, VC.ZT({Dd}), 0, 0n, 0n, {{==}}, {{==}}, hd, hl, pf0, hz)

def eval_go({P}, +h: {{CI.OKT({OAS}) == {TRUE}}})
    -> {{T.{C}_encode({OBJ}) == ({OBJ}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}:
  +g = putx0({OAS}, h, 28n, {{==}})
  +rt = CI.PA(K.RTC({MA0}), DK.P2(K.BYC({MA0}), DK.P2(K.PFC({MA0}), K.SZXC({MA0}))), g)
  %Equal.sym(T.{C} & U32, T.{C}_size({OBJ}), ({OBJ}, {S}), sizeC({OAS}, h)) :
    {{T.{C}_enc_sized(_) == ({OBJ}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu({S}))), Array.new(U32, {Dd}, 0),
      FD.logic__subst(Nat, z => {{B.zeros(B.words_depth_u(VC.nwu({S}))) == Array.new(U32, z, 0) : Array<U32>}}, U32.to_nat(B.words_depth_u(VC.nwu({S}))), {Dd}, VD.wdu(VC.nwu({S})), VZG.zg(B.words_depth_u(VC.nwu({S}))))) :
    {{T.{C}_enc_put({S}, T.{C}_putn(_, 0, {OBJ})) == ({OBJ}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  %Equal.sym(Array<U32>, Array.new(U32, {Dd}, 0), FD.array__thaw(U32, VC.ZT({Dd})), FD.array__new(U32, {Dd}, 0)) :
    {{T.{C}_enc_put({S}, T.{C}_putn(_, 0, {OBJ})) == ({OBJ}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  %Equal.sym({RTT}, T.{C}_putn(FD.array__thaw(U32, VC.ZT({Dd})), 0, {OBJ}), (FD.array__thaw(U32, K.PUTC({MA0})), ({OBJ}, K.SZC({OAS}))), rt) :
    {{T.{C}_enc_put({S}, _) == ({OBJ}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  {{==}}

# The output's first bytes, as many as the size, are the container's bytes.
def obytes({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT}))) == {ENCC} : +List<U32>}}:
  +es = szS({OAS}, h, k, ek)
  +el = CI.lenE({OAS}, h)
  +g = putx0({OAS}, h, k, ek)
  +by = CI.PA(K.BYC({MA0}), DK.P2(K.PFC({MA0}), K.SZXC({MA0})), CI.PB(K.RTC({MA0}), DK.P2(K.BYC({MA0}), DK.P2(K.PFC({MA0}), K.SZXC({MA0}))), g))
  +Y = VCN.AP({ENCC}, UW.ZB(WD.PADB(0n, {LLC})))
  +R = VS.bdr(VCN.LN(Y), UA.BYT(VC.ZT({Dd})))
  +e1 = Equal.trans(+List<U32>, UA.BYT({OUT}), VCN.AP(Y, R), VCN.AP({ENCC}, VCN.AP(UW.ZB(WD.PADB(0n, {LLC})), R)), by, VS.app_assoc({ENCC}, UW.ZB(WD.PADB(0n, {LLC})), R))
  +eN = Equal.trans(Nat, U32.to_nat({S}), {ENDC}, VCN.LN({ENCC}), es, Equal.sym(Nat, VCN.LN({ENCC}), {ENDC}, el))
  %Equal.sym(Nat, U32.to_nat({S}), VCN.LN({ENCC}), eN) : {{VS.bt(_, FX.limbs(FD.array__slots(U32, {OUT}))) == {ENCC} : +List<U32>}}
  %Equal.sym(+List<U32>, UA.BYT({OUT}), VCN.AP({ENCC}, VCN.AP(UW.ZB(WD.PADB(0n, {LLC})), R)), e1) : {{VS.bt(VCN.LN({ENCC}), _) == {ENCC} : +List<U32>}}
  VRX.bt_all({ENCC}, VCN.AP(UW.ZB(WD.PADB(0n, {LLC})), R))

def spec_go({P}, +h: {{CI.OKT({OAS}) == {TRUE}}})
    -> Decoding.decodes(Spec.{C}(), VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT}))), CI.VALC({OAS})):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(CI.VALC({OAS}), Spec.{C}()), Some{{[S.Variable{{{ENCC}}}]}}, CI.encx_spec(CI.MW{{{OAS}}}, h)) :
    {{Codec.bytes(_) == Some{{VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT})))}} : Maybe<&2, +List<U32>>}}
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT}))), {ENCC}, obytes({OAS}, h, 28n, {{==}})) :
    {{Some{{{ENCC}}} == Some{{_}} : Maybe<&2, +List<U32>>}}
  {{==}}

# ---- the laws, on the container's mirror ----
def SZSM(m: CI.MW) -> U32:
  match m:
    case CI.MW{{{", ".join("+" + x for x in OA)}}}: SZS({OAS})
def OUTE(m: CI.MW) -> FD.array__Tree<U32>:
  match m:
    case CI.MW{{{", ".join("+" + x for x in OA)}}}: OUTC({OAS})

# The encoder returns the object and the buffer of OUTE(m), its bytes.
law encode_eval:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  {{T.{C}_encode(CI.TH(m)) == (CI.TH(m), B.Buf{{FD.array__thaw(U32, OUTE(m)), SZSM(m)}}) : T.{C} & B.Buf}}
def encode_eval(m, hok):
  match m:
    case CI.MW{{{", ".join("+" + x for x in OA)}}}: eval_go({OAS}, hok)

# The buffer's bytes are the spec encoding of the object's value.
law encode_spec:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  Decoding.decodes(Spec.{C}(), VS.bt(U32.to_nat(SZSM(m)), FX.limbs(FD.array__slots(U32, OUTE(m)))), CI.VAL(m))
def encode_spec(m, hok):
  match m:
    case CI.MW{{{", ".join("+" + x for x in OA)}}}: spec_go({OAS}, hok)
""")
    return L[:cut], L[cut:], K, P, OA, imps


def valid_fact(f, fs, K):
    """(the field's valid call's type, its proof) in a size module (hypotheses through CI.ok_*), or None"""
    h = lambda x: f'CI.ok_{x}({{OAS}}, h)'
    if f in K.fixw:
        fw = K.fixw[f]
        if not callable(getattr(fw, 'valid', None)):
            return None
        return (fw.vt, fw.valid([h(x) for x in fw.hargs]))
    ch = K.children[f]
    if ch.p == 'bl32':
        return (ch.vt, f'EB.validx({ch.oargs[0]}, {h(ch.hargs[0])})')
    if ch.p == 'l1048576_bl1073741824':
        return (ch.vt, f'ET.valid_l({ch.oargs[0]}, {ch.oargs[1]}, {h(ch.hargs[0])})')
    if getattr(ch, 'std', False):
        m = ch.oargs[0]
        sa = getattr(ch, 'szalias', None)
        e = f'{sa or ch.alias}.validx({m}, {h(ch.hargs[0])})'
        B = getattr(ch, 'box', None)
        if B:
            th = f'{ch.alias}.TH({m})'
            e = f'Equal.cong(T.{B} & Bool, O.Boxed<T.{B}> & Bool, z => T.{B}_bx_va_back(z), T.{B}_valid({th}), ({th}, True{{}}), {e})'
        return (ch.vt, e)
    return (ch.vt, f'{ch.alias}.valid_{ch.p}({ch.oargs[0]}, {ch.oargs[1]}, {h(ch.hargs[0])})')


def valid_text(C, K, P, OAS, OBJF, groups, gobj, fnames, lin):
    """A wide container's validity pass (T.<C>_valid: its groups' _va chains) rewritten through its
    non-Data fields' validity facts; None when a field has none yet (a FixW field without its valid term)."""
    F, p = K.F, K.p
    steps, prfs = [], []
    tacc = 'True{}'
    gok = None
    pre = ''
    for j, (gk, idx) in enumerate(lin):
        # a group whose Data fields have a check starts its pass with it (acc = V): V true (its hpz_g<k>, var_cont_enc)
        body_ = CE.fn_body(f'{p}_g{gk}_valid')
        mm_ = re.search(r'case \w+\{([^}]*)\}: (\w+)\((.*)\)$', body_, re.M)
        pv_ = [v.strip().lstrip('+') for v in mm_.group(1).split(',')]
        args_ = __import__('var_winb').split_top(mm_.group(3))
        pn_ = CE.fn_params(mm_.group(2))
        acc0 = args_[pn_.index('acc')].strip()
        if acc0 != 'True{}':
            assert j == 0, (C, gk, acc0)
            sub_ = dict(zip(pv_, [OBJF[fnames[i]] for i in idx]))
            V_ = re.sub(r'(?<![\w.])([A-Za-z_]\w*)\b(?![({])', lambda z_: sub_.get(z_.group(1), z_.group(1)), acc0)
            V_ = re.sub(r'(?<![\w.])([a-z_]\w*)\(', r'T.\1(', V_)
            pre = (V_, gk)
    for j, (gk, idx) in enumerate(lin):
        gp = f'{p}_g{gk}'
        tparams = CE.fn_params(f'{p}_va{j}')
        if j > 0:
            tacc = f'Bool.and({tacc}, {gok})'
        gmap = {f'g{g2}': gobj[g2] for g2, _ in groups}
        gmap['acc'] = tacc
        nd = [i for i in idx if not F[i][1].data]
        acc = 'True{}'
        for s, i in enumerate(nd):
            f = fnames[i]
            fs = F[i][1]
            vf = valid_fact(f, fs, K)
            if vf is None:
                return None
            vt, prf = vf
            ps = CE.fn_params(f'{gp}_va{s}')
            mp = {fnames[i2]: OBJF[fnames[i2]] for i2 in idx}
            mp['acc'] = acc
            inner = f'T.{gp}_va{s}(' + ', '.join(mp[x] if x != 'pair' else 'z' for x in ps) + ')'
            outer = f'T.{p}_va{j}(' + ', '.join(gmap[x] if x != 'pair' else inner for x in tparams) + ')'
            o = OBJF[f]
            steps.append((outer, f'T.{fs.p}_valid({o})', f'({o}, True{{}})', f'{vt} & Bool'))
            prfs.append(prf.replace('{OAS}', OAS))
            acc = f'Bool.and({acc}, True{{}})'
        gok = acc
    RT = f'T.{C} & Bool'
    OBJ = f'K.OBJC({OAS})'
    start = f'T.{p}_valid({OBJ})'
    end = f'({OBJ}, True{{}})'

    def chain(k, first):
        outer, lhs, rhs, ity = steps[k]
        e = f'Equal.cong({ity}, {RT}, z => {outer}, {lhs}, {rhs}, {prfs[k]})'
        if k == len(steps) - 1:
            return e
        after = outer.replace(', z)', f', {rhs})')
        nxt = steps[k + 1][0].replace(', z)', f', {steps[k + 1][1]})')
        return f'Equal.trans({RT}, {first}, {after}, {end}, {e}, {chain(k + 1, nxt)})'
    first = steps[0][0].replace(', z)', f', {steps[0][1]})')
    rw = ''
    if pre:
        V_, gk_ = pre
        # the first group's pass starts from its Data fields' check: rewrite it to True (the chain starts from True)
        hole = first.replace(f'T.{p}_g{gk_}_va0(', f'@@', 1)
        i_ = hole.index('@@')
        ps_ = CE.fn_params(f'{p}_g{gk_}_va0')
        k_ = ps_.index('acc')
        # the k_-th top-level argument of the inner call
        inner_start = i_ + 2
        depth, argi, j_ = 0, 0, inner_start
        while True:
            ch_ = hole[j_]
            if ch_ in '({[':
                depth += 1
            elif ch_ in ')}]':
                depth -= 1
            elif ch_ == ',' and depth == 0:
                argi += 1
                if argi == k_:
                    a0 = j_ + 2
                    break
            j_ += 1
        assert hole[a0:a0 + 6] == 'True{}', hole[a0:a0 + 20]
        motive = hole[:a0] + '_' + hole[a0 + 6:]
        motive = motive.replace('@@', f'T.{p}_g{gk_}_va0(', 1)
        rw = f'  %Equal.sym(Bool, {V_}, True{{}}, CI.ok_hpz_g{gk_}({OAS}, h)) :\n    {{{motive} == {end} : {RT}}}\n'
    return f'''
# ---- {C}: the runtime's validity pass ----
def validC({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}) -> {{{start} == {end} : {RT}}}:
{rw}  {chain(0, first)}
'''


def size_term(ch):
    if ch.p == 'bl32':
        return f'EB.SZ({ch.oargs[0]})'
    if ch.p == 'l1048576_bl1073741824':
        return f'ET.SZS({ch.oargs[0]}, {ch.oargs[1]})'
    return ch.sz


def sizex_term(f, ch):
    h = f'CI.ok_{ch.hargs[0]}({{OAS}}, h)'
    if ch.p == 'bl32':
        return f'EB.sizex({ch.oargs[0]}, {h})'
    if ch.p == 'l1048576_bl1073741824':
        return f'ET.sizex({ch.oargs[0]}, {ch.oargs[1]}, {h})'
    if getattr(ch, 'std', False):
        # a child in the encoder-window interface: its sizex (a wide container's size module: sizez), a box rewrapped
        m = ch.oargs[0]
        sa = getattr(ch, 'szalias', None)
        e = f'{sa}.sizez({m}, {h})' if sa else f'{ch.alias}.sizex({m}, {h})'
        B = getattr(ch, 'box', None)
        if B:
            th = f'{ch.alias}.TH({m})'
            e = f'Equal.cong(T.{B} & U32, O.Boxed<T.{B}> & U32, z => T.{B}_bx_size_back(z), T.{B}_size({th}), ({th}, {ch.sz}), {e})'
        return e
    return f'{ch.alias}.sizex_{ch.p}({ch.oargs[0]}, {ch.oargs[1]}, {h})'


def len_term(ch):
    if ch.p == 'bl32':
        return f'LY.LN(EB.ENC({ch.oargs[0]}))'
    if ch.p == 'l1048576_bl1073741824':
        return f'LY.LN(ET.ENCL({ch.oargs[0]}, {ch.oargs[1]}))'
    if getattr(ch, 'std', False):
        return f'LY.LN({ch.enc})'
    return f'LY.LN({ch.alias}.ENCL_{ch.p}({ch.oargs[0]}, {ch.oargs[1]}))'


def szx_term(f, ch, bnd):
    """to_nat(size) == its byte count, bnd: the byte count <= 4 2^k."""
    h = f'CI.ok_{ch.hargs[0]}({{OAS}}, h)'
    t, N = (ch.oargs + [None])[:2]
    if ch.p == 'bl32':
        return f'EB.szx({t}, {h})'
    if ch.p == 'l1048576_bl1073741824':
        LL = f'ET.LL({t}, {N})'
        hb = (f'FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(k))) == {TRUE}}}, LY.LN(ET.ENCL({t}, {N})), {LL}, ET.len_encl({t}, {N}), {bnd})')
        return (f'Equal.trans(Nat, U32.to_nat(ET.SZS({t}, {N})), {LL}, LY.LN(ET.ENCL({t}, {N})), ET.szs({t}, {N}, {h}, Nat.add(2n, k), '
                f'Equal.cong(Nat, Nat, z => Nat.add(2n, z), k, 28n, ek), {hb}), Equal.sym(Nat, LY.LN(ET.ENCL({t}, {N})), {LL}, ET.len_encl({t}, {N})))')
    if getattr(ch, 'std', False):
        return f'{ch.alias}.szx({t}, {h})'
    a = ch.alias
    LL = f'{a}.LL_{ch.p}({t}, {N})'
    hm = f'FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(k))) == {TRUE}}}, LY.LN({a}.ENCL_{ch.p}({t}, {N})), {LL}, {a}.len_encl_{ch.p}({t}, {N}), {bnd})'
    rs = re.search(r'U32\.mul\(\w+, (\d+)\)', ch.sz).group(1)
    W = int(rs) // 4
    return (f'Equal.trans(Nat, U32.to_nat({ch.sz}), {LL}, LY.LN({a}.ENCL_{ch.p}({t}, {N})), VRX.mulq(k, {N}, U32.to_nat({N}), {rs}, {W}n, {{==}}, {{==}}, hk, {hm}), '
            f'Equal.sym(Nat, LY.LN({a}.ENCL_{ch.p}({t}, {N})), {LL}, {a}.len_encl_{ch.p}({t}, {N})))')


HEADX = ['import ../../src/buffer.bend as B', 'import ../../spec/decoding_relation.bend as Decoding', 'import ./vlist.bend as VL', 'import ./vdepth.bend as VD',
         'import ./big_vvlz.bend as VZG', 'import ./vuwb.bend as UWB', 'import ./vvle.bend as VE2']


def size_file(C):
    return ROOT / f'proofs/obj/big_encx_{C}_size.bend'


def full_texts(C, generic=False):
    Ls, Lt, K, P, OA, imps = top_text(C, generic)
    OAS = ', '.join(OA)
    pat = ', '.join('+' + x for x in OA)
    sz = '\n'.join(Ls).replace('{OAS}', OAS) + f'''
# ---- the size pass on the container's mirror ----
def SZSM(m: CI.MW) -> U32:
  match m:
    case CI.MW{{{pat}}}: SZS({OAS})

law sizex:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  {{T.{K.p}_size(CI.TH(m)) == (CI.TH(m), SZSM(m)) : T.{C} & U32}}
def sizex(m, hok):
  match m:
    case CI.MW{{{pat}}}: sizeC({OAS}, hok)

law szs:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  {{U32.to_nat(SZSM(m)) == List.length(&2, U32, CI.ENC(m)) : Nat}}
def szs(m, hok):
  match m:
    case CI.MW{{{pat}}}: Equal.trans(Nat, U32.to_nat(SZS({OAS})), CI.ENDC({OAS}), List.length(&2, U32, K.ENCC({OAS})), szS({OAS}, hok, 28n, {{==}}),
      Equal.sym(Nat, List.length(&2, U32, K.ENCC({OAS})), CI.ENDC({OAS}), CI.lenE({OAS}, hok)))

# The size pass returns the writer's size CI.SZ (both are the byte count).
law sizez:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  {{T.{K.p}_size(CI.TH(m)) == (CI.TH(m), CI.SZ(m)) : T.{C} & U32}}
def sizez(m, hok):
  +e = FD.u32__injective(SZSM(m), CI.SZ(m), Equal.trans(Nat, U32.to_nat(SZSM(m)), List.length(&2, U32, CI.ENC(m)), U32.to_nat(CI.SZ(m)), szs(m, hok),
    Equal.sym(Nat, U32.to_nat(CI.SZ(m)), List.length(&2, U32, CI.ENC(m)), CI.szx(m, hok))))
  FD.logic__subst(U32, z => {{T.{K.p}_size(CI.TH(m)) == (CI.TH(m), z) : T.{C} & U32}}, SZSM(m), CI.SZ(m), e, sizex(m, hok))
'''
    if 'def validC(' in sz:
        sz += f'''
# The runtime's validity pass accepts the object.
law validx:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  {{T.{K.p}_valid(CI.TH(m)) == (CI.TH(m), True{{}}) : T.{C} & Bool}}
def validx(m, hok):
  match m:
    case CI.MW{{{pat}}}: validC({OAS}, hok)
'''
    hs = imps + HEADX + [f'import ./big_encx_{C}_iface.bend as CI', '', '# GENERATED by codegen/var_cont_top.py. Do not edit.',
                         f'# {C}: the runtime\'s size pass on its encoder window (T.{K.p}_size; see the generator).', '']
    out = {size_file(C): '\n'.join(hs) + '\n' + sz + '\n'}
    if Lt and not generic:
        top = '\n'.join(Lt).replace('{OAS}', OAS)
        top = re.sub(r'\bSZS\(', 'Z.SZS(', top)
        top = re.sub(r'\bsizeC\(', 'Z.sizeC(', top)
        top = re.sub(r'\bszS\(', 'Z.szS(', top)
        ht = imps + HEADX + [f'import ./big_encx_{C}_iface.bend as CI', f'import ./big_encx_{C}_size.bend as Z', '',
                             '# GENERATED by codegen/var_cont_top.py. Do not edit.',
                             f'# {C}: the encoder laws at X = 0 on its encoder window (see the generator).', '']
        out[out_file(C)] = '\n'.join(ht) + '\n' + top + '\n'
    return out


# ==== the generic containers (types/generic_obj.bend, proofs/obj/generic_specs.bend): encode laws on the mirror ====
# For a plain container whose interface module states all eight laws, the laws follow from the
# interface alone: the size pass is CI.sizex, its value CI.szx, the bound CI.bndx, the writer at X = 0 of
# a zero tree CI.putx / putx_bytes, the spec CI.encx_spec.

GTOPS = ['Gp4B0CA2906A', 'Gp66304057C3', 'Gp8A7851175B', 'Gc465214E502', 'Gc221EC01D83', 'Gc85FA758A04', 'Gc56D855869F', 'BeaconBlock', 'SignedBeaconBlock',
         'GuA2212AE21F', 'GuAD91DEB870', 'Gu6DDF182530', 'LightClientFinalityUpdate', 'Gc60805EC295']


def gtop_text(C):
    txt = (ROOT / f'proofs/obj/big_encx_{C}_iface.bend').read_text()
    imps = [ln for ln in txt.split('\n') if ln.startswith('import ') and ' as K' not in ln]
    SZX = 'Z.sizez' if C in GSIZES else 'CI.sizex'
    imps = [x for x in imps if not x.endswith(' as B')]
    # the interface's own imports whose alias HEADX takes (vuw_bits as UWB) are not needed here
    hx = {x.rsplit(' as ', 1)[1] for x in HEADX}
    imps = [x for x in imps if ' as ' not in x or x.rsplit(' as ', 1)[1] not in hx]
    TH = 'CI.TH(m)'
    S = 'CI.SZ(m)'
    Dd = f'VL.DO({S})'
    # a fixed-depth encoder (the runtime's buffer is O.out_at(d), its size masked): the bytes' bound CI.maxx
    src = (ROOT / 'types/generic_obj.bend').read_text()
    if 'types/generic_obj.bend as T' not in txt:
        src = (ROOT / 'types/fulu_obj.bend').read_text()
    em = re.search(rf'^def {C}_encode\(o: {C}\) -> {C} & B\.Buf: {C}_enc_put\({C}_putn\(O\.out_at\((\d+)n\), 0, o\)\)$', src, re.M)
    fixd = None
    if em:
        fixd = int(em.group(1))
        mx = re.search(r'^law maxx:\n.*\n.*\n  \{Nat\.is_le\(List\.length\(&2, U32, ENC\(m\)\), (\d+)n\)', txt, re.M)
        assert mx, f'{C}: a fixed-depth encoder needs its interface\'s maxx'
        MX = int(mx.group(1))
        assert MX <= 4 * 2 ** fixd, (C, MX, fixd)
        kb = MX.bit_length()
        Dd = f'{fixd}n'
    L = 'List.length(&2, U32, CI.ENC(m))'
    OUT = f'OUTE(m)'
    RTT = f'Array<U32> & (T.{C} & U32)'
    body = f"""
# ---- {C} at X = 0 of a zero tree ----
def OUTE(+m: CI.MW) -> FD.array__Tree<U32>: CI.PUTX(m, {Dd}, VC.ZT({Dd}), 0n, 0n)
def SZSM(+m: CI.MW) -> U32: {S}

def HL(+m: CI.MW) -> Data: {{Nat.is_le(Nat.add(0n, WD.NWN(Nat.add(0n, {L}))), VB.pw({Dd})) == {TRUE}}}
def HZ(+m: CI.MW) -> Data:
  {{VS.bt(Nat.add({L}, CI.PADB(0n, m)), VS.bdr(Nat.add(A.quad(0n), 0n), UA.BYT(VC.ZT({Dd})))) == UW.ZB(Nat.add({L}, CI.PADB(0n, m))) : +List<U32>}}
def HD(+m: CI.MW) -> Data: {{Nat.is_lt({Dd}, 29n) == {TRUE}}}

def mk3(+m: CI.MW, +a: HD(m), +b: HL(m), +c: HZ(m)) -> DK.P2(HD(m), DK.P2(HL(m), HZ(m))): (a, (b, c))

# the writer's hypotheses at X = 0 of the zero tree of the size's depth
def room(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> DK.P2(HD(m), DK.P2(HL(m), HZ(m))):
  +es = CI.szx(m, hok)
  +hS = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(k))) == {TRUE}}}, {L}, U32.to_nat({S}), Equal.sym(Nat, U32.to_nat({S}), {L}, es), CI.bndx(m, hok, k, ek))
  +eNW = VCN.nw_nat({S}, k, FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}}), hS)
  +nw = VRX.nwn_le(U32.to_nat({S}), VB.pw(k), hS)
  +nwp = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(VC.nwu({S})), z) == {TRUE}}}, VB.pw(k), O.pow2n(k), VD.s_pow2_eq(k),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(k)) == {TRUE}}}, WD.NWN(U32.to_nat({S})), VC.NW({S}), Equal.sym(Nat, VC.NW({S}), WD.NWN(U32.to_nat({S})), eNW), nw))
  +hd = FD.nat__le_lt_trans({Dd}, k, 29n, VD.wd_min(VC.nwu({S}), k, nwp), FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}}))
  +hcov = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(VC.nwu({S})), z) == {TRUE}}}, O.pow2n({Dd}), VB.pw({Dd}), Equal.sym(Nat, VB.pw({Dd}), O.pow2n({Dd}), VD.s_pow2_eq({Dd})),
    VD.wd_cover(VC.nwu({S}), k, FD.logic__subst(Nat, z => {{Nat.is_le(z, 32n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}}), nwp))
  +hl0 = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw({Dd})) == {TRUE}}}, VC.NW({S}), WD.NWN(U32.to_nat({S})), eNW, hcov)
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(WD.NWN(z), VB.pw({Dd})) == {TRUE}}}, U32.to_nat({S}), {L}, es, hl0)
  +M = Nat.add({L}, WD.PADB(0n, {L}))
  +hm = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw({Dd}))) == {TRUE}}}, A.quad(WD.NWN({L})), M, Equal.sym(Nat, M, A.quad(WD.NWN({L})), VCN.padb_id(0n, {L})),
    VCN.VME4(WD.NWN({L}), VB.pw({Dd}), hl))
  +hz = FD.logic__subst(+List<U32>, z => {{VS.bt(M, VS.bdr(Nat.add(A.quad(0n), 0n), z)) == UW.ZB(M) : +List<U32>}}, UW.ZB(A.quad(VB.pw({Dd}))), UA.BYT(VC.ZT({Dd})),
    Equal.sym(+List<U32>, UA.BYT(VC.ZT({Dd})), UW.ZB(A.quad(VB.pw({Dd}))), UWB.zt_bytes({Dd})), VE2.bt_zb_le(M, A.quad(VB.pw({Dd})), hm))
  mk3(m, hd, hl, hz)
@ROOMF
def RT0(+m: CI.MW) -> Data: {{T.{C}_putk(FD.array__thaw(U32, VC.ZT({Dd})), 0, {TH}) == (FD.array__thaw(U32, {OUT}), ({TH}, {S})) : {RTT}}}

def rt0(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}}, +g: DK.P2(HD(m), DK.P2(HL(m), HZ(m)))) -> RT0(m):
  +hd = CI.PA(HD(m), DK.P2(HL(m), HZ(m)), g)
  +hl = CI.PA(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  +hz = CI.PB(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  CI.putx(m, {Dd}, VC.ZT({Dd}), 0, 0n, 0n, {{==}}, {{==}}, hd, FD.array__trep_perfect(U32, {Dd}, 0), hl, hz, hok)

def BY0(+m: CI.MW) -> Data: {{UA.BYT({OUT}) == UW.SPL(UA.BYT(VC.ZT({Dd})), Nat.add(A.quad(0n), 0n), List.append(&2, U32, CI.ENC(m), UW.ZB(CI.PADB(0n, m)))) : +List<U32>}}

def by0(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}}, +g: DK.P2(HD(m), DK.P2(HL(m), HZ(m)))) -> BY0(m):
  +hd = CI.PA(HD(m), DK.P2(HL(m), HZ(m)), g)
  +hl = CI.PA(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  +hz = CI.PB(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  CI.putx_bytes(m, {Dd}, VC.ZT({Dd}), 0, 0n, 0n, {{==}}, {{==}}, hd, FD.array__trep_perfect(U32, {Dd}, 0), hl, hz, hok)

@EVALF
def eval_go(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}})
    -> {{T.{C}_encode({TH}) == ({TH}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}:
  +rt = rt0(m, hok, room(m, hok, 28n, {{==}}))
  %Equal.sym(T.{C} & U32, T.{C}_size({TH}), ({TH}, {S}), {SZX}(m, hok)) :
    {{T.{C}_enc_sized(_) == ({TH}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu({S}))), Array.new(U32, {Dd}, 0),
      FD.logic__subst(Nat, z => {{B.zeros(B.words_depth_u(VC.nwu({S}))) == Array.new(U32, z, 0) : Array<U32>}}, U32.to_nat(B.words_depth_u(VC.nwu({S}))), {Dd}, VD.wdu(VC.nwu({S})), VZG.zg(B.words_depth_u(VC.nwu({S}))))) :
    {{T.{C}_enc_put({S}, T.{C}_putn(_, 0, {TH})) == ({TH}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  %Equal.sym(Array<U32>, Array.new(U32, {Dd}, 0), FD.array__thaw(U32, VC.ZT({Dd})), FD.array__new(U32, {Dd}, 0)) :
    {{T.{C}_enc_put({S}, T.{C}_putn(_, 0, {TH})) == ({TH}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  %Equal.sym({RTT}, T.{C}_putk(FD.array__thaw(U32, VC.ZT({Dd})), 0, {TH}), (FD.array__thaw(U32, {OUT}), ({TH}, {S})), rt) :
    {{T.{C}_enc_put({S}, _) == ({TH}, B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}) : T.{C} & B.Buf}}
  {{==}}

# The output's first bytes, as many as the size, are the container's bytes.
def obytes(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}}) -> {{VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT}))) == CI.ENC(m) : +List<U32>}}:
  +by = by0(m, hok, room(m, hok, 28n, {{==}}))
  +P = UW.ZB(CI.PADB(0n, m))
  +R = VS.bdr(VCN.LN(VCN.AP(CI.ENC(m), P)), UA.BYT(VC.ZT({Dd})))
  +e1 = Equal.trans(+List<U32>, UA.BYT({OUT}), VCN.AP(VCN.AP(CI.ENC(m), P), R), VCN.AP(CI.ENC(m), VCN.AP(P, R)), by, VS.app_assoc(CI.ENC(m), P, R))
  %Equal.sym(Nat, U32.to_nat({S}), VCN.LN(CI.ENC(m)), CI.szx(m, hok)) : {{VS.bt(_, FX.limbs(FD.array__slots(U32, {OUT}))) == CI.ENC(m) : +List<U32>}}
  %Equal.sym(+List<U32>, UA.BYT({OUT}), VCN.AP(CI.ENC(m), VCN.AP(P, R)), e1) : {{VS.bt(VCN.LN(CI.ENC(m)), _) == CI.ENC(m) : +List<U32>}}
  VRX.bt_all(CI.ENC(m), VCN.AP(P, R))

# The encoder returns the object and the buffer of OUTE(m), its bytes.
law encode_eval:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  {{T.{C}_encode(CI.TH(m)) == (CI.TH(m), B.Buf{{FD.array__thaw(U32, OUTE(m)), SZSM(m)}}) : T.{C} & B.Buf}}
def encode_eval(m, hok): eval_go(m, hok)

# The buffer's bytes are the spec encoding of the object's value.
law encode_spec:
  for +m: CI.MW
  for +hok: {{CI.OK(m) == {TRUE}}}
  Decoding.decodes(Spec.{C}(), VS.bt(U32.to_nat(SZSM(m)), FX.limbs(FD.array__slots(U32, OUTE(m)))), CI.VAL(m))
def encode_spec(m, hok):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(CI.VAL(m), Spec.{C}()), Some{{[S.Variable{{CI.ENC(m)}}]}}, CI.encx_spec(m, hok)) :
    {{Codec.bytes(_) == Some{{VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT})))}} : Maybe<&2, +List<U32>>}}
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat({S}), FX.limbs(FD.array__slots(U32, {OUT}))), CI.ENC(m), obytes(m, hok)) :
    {{Some{{CI.ENC(m)}} == Some{{_}} : Maybe<&2, +List<U32>>}}
  {{==}}
"""
    if fixd is None:
        body = body.replace('@ROOMF\n', '\n').replace('@EVALF\n', '')
    else:
        L_ = L
        roomf = f'''
# the fixed depth {fixd}: the bytes within its {4 * 2 ** fixd} (CI.maxx: at most {MX})
def roomf(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}}) -> DK.P2(HD(m), DK.P2(HL(m), HZ(m))):
  +hq = FD.nat__le_trans({L_}, {MX}n, A.quad(VB.pw({Dd})), CI.maxx(m, hok), {{==}})
  +hl = VRX.nwn_le({L_}, VB.pw({Dd}), hq)
  +M = Nat.add({L_}, WD.PADB(0n, {L_}))
  +hm = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw({Dd}))) == {TRUE}}}, A.quad(WD.NWN({L_})), M, Equal.sym(Nat, M, A.quad(WD.NWN({L_})), VCN.padb_id(0n, {L_})),
    VCN.VME4(WD.NWN({L_}), VB.pw({Dd}), hl))
  +hz = FD.logic__subst(+List<U32>, z => {{VS.bt(M, VS.bdr(Nat.add(A.quad(0n), 0n), z)) == UW.ZB(M) : +List<U32>}}, UW.ZB(A.quad(VB.pw({Dd}))), UA.BYT(VC.ZT({Dd})),
    Equal.sym(+List<U32>, UA.BYT(VC.ZT({Dd})), UW.ZB(A.quad(VB.pw({Dd}))), UWB.zt_bytes({Dd})), VE2.bt_zb_le(M, A.quad(VB.pw({Dd})), hm))
  mk3(m, {{==}}, hl, hz)
'''
        OUTB = f'B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}'
        evalf = f'''
# the size under the mask 0x7fffffff: below 2^{kb} (CI.szx, CI.maxx)
def a31(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}}) -> {{U32.and({S}, 2147483647) == {S} : U32}}:
  +hs = FD.logic__subst(Nat, z => {{Nat.is_le(z, {MX}n) == {TRUE}}}, {L_}, U32.to_nat({S}), Equal.sym(Nat, U32.to_nat({S}), {L_}, CI.szx(m, hok)), CI.maxx(m, hok))
  VBE.and31({S}, {kb}n, {{==}}, FD.nat__le_lt_trans(U32.to_nat({S}), {MX}n, FD.spec_common__pow2({kb}n), hs, {{==}}))

def eval_go(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}})
    -> {{T.{C}_encode({TH}) == ({TH}, {OUTB}) : T.{C} & B.Buf}}:
  +rt = rt0(m, hok, roomf(m, hok))
  %Equal.sym(Array<U32>, Array.new(U32, {Dd}, 0), FD.array__thaw(U32, VC.ZT({Dd})), FD.array__new(U32, {Dd}, 0)) :
    {{T.{C}_enc_put(T.{C}_putn(_, 0, {TH})) == ({TH}, {OUTB}) : T.{C} & B.Buf}}
  %Equal.sym({RTT}, T.{C}_putk(FD.array__thaw(U32, VC.ZT({Dd})), 0, {TH}), (FD.array__thaw(U32, {OUT}), ({TH}, {S})), rt) :
    {{T.{C}_enc_put(_) == ({TH}, {OUTB}) : T.{C} & B.Buf}}
  %Equal.sym(U32, U32.and({S}, 2147483647), {S}, a31(m, hok)) :
    {{({TH}, B.Buf{{FD.array__thaw(U32, {OUT}), _}}) == ({TH}, {OUTB}) : T.{C} & B.Buf}}
  {{==}}

def eval_go_sized(+m: CI.MW, +hok: {{CI.OK(m) == {TRUE}}})
'''
        body = body.replace('@ROOMF\n', roomf + '\n')
        # the size-depth room (bndx, 2^28) is not used at a fixed depth
        j0 = body.index("# the writer's hypotheses at X = 0")
        j1 = body.index('\n# the fixed depth')
        body = body[:j0] + body[j1 + 1:].replace('@EVALF\n', evalf)
        # the fixed encoder has no size pass: its eval is eval_go above; the sized one is dropped
        i0 = body.index('def eval_go_sized(')
        i1 = body.index('# The output\'s first bytes')
        body = body[:i0] + body[i1:]
        body = body.replace('room(m, hok, 28n, {==})', 'roomf(m, hok)')
        imps = imps + ['import ./vbenc.bend as VBE']
    tsrc = src if 'types/generic_obj.bend as T' in txt else (ROOT / 'types/fulu_obj.bend').read_text()
    pk = re.search(rf'^def {C}_putk\(out: Array<U32>, \+pos: U32, o: {C}\) -> .*: (.*)$', tsrc, re.M).group(1)
    if pk != f'{C}_putn(out, pos, o)':
        # a checked writer (a union: putk = pk(valid(o))): the encoder's putn is putk once the check passes (CI.validx)
        assert pk == f'{C}_pk(out, pos, {C}_valid(o))', (C, pk)
        ZT = f'FD.array__thaw(U32, VC.ZT({Dd}))'
        R = f'(FD.array__thaw(U32, {OUT}), ({TH}, {S}))'
        body = body.replace(f'def RT0(+m: CI.MW) -> Data: {{T.{C}_putk(', f'def RT0(+m: CI.MW) -> Data: {{T.{C}_putn(', 1)
        old_ = f'  CI.putx(m, {Dd}, VC.ZT({Dd}), 0, 0n, 0n, {{==}}, {{==}}, hd, FD.array__trep_perfect(U32, {Dd}, 0), hl, hz, hok)\n'
        assert body.count(old_) == 1
        body = body.replace(old_, f'  FD.logic__subst(T.{C} & Bool, z => {{T.{C}_pk({ZT}, 0, z) == {R} : {RTT}}}, T.{C}_valid({TH}), ({TH}, True{{}}), CI.validx(m, hok),\n  ' + old_[2:-1] + ')\n', 1)
        body = body.replace(f'%Equal.sym({RTT}, T.{C}_putk(', f'%Equal.sym({RTT}, T.{C}_putn(')
    hs = imps + HEADX + [f'import ./big_encx_{C}_iface.bend as CI'] + ([f'import ./big_encx_{C}_size.bend as Z'] if C in GSIZES else []) + ['', '# GENERATED by codegen/var_cont_top.py. Do not edit.',
                         f'# {C}: the encoder laws at X = 0, from its encoder window\'s interface (see the generator: gtop_text).', '']
    return '\n'.join(hs) + '\n' + body


def main():
    out = {}
    if '--no-big' not in sys.argv:
        for C in SIZES:
            out.update(full_texts(C))
        for C in GSIZES:
            out.update(full_texts(C, generic=True))
        for C in GTOPS:
            out[out_file(C)] = gtop_text(C)
    if '--check' in sys.argv:
        stale = [str(q.relative_to(ROOT)) for q, t in out.items() if not q.exists() or q.read_text() != t]
        if stale:
            print('stale generated container encoder laws: ' + ', '.join(stale))
            sys.exit(1)
        print('generated container encoder laws are current')
        return
    for q, t in out.items():
        q.write_text(t)
    print(', '.join(str(q.relative_to(ROOT)) for q in out))


if __name__ == '__main__':
    main()
