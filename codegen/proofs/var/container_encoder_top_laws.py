#!/usr/bin/env python3
"""The encoder laws of containers written by codegen/proofs/var/container_encoder_windows.py, at X = 0.

    python3 codegen/proofs/var/container_encoder_top_laws.py [--check]

proofs/obj/var_codec_<C>_enc.bend (generated) for C in TOPS, on the container's encoder window
encx_<C> (K) and its interface section encx_<C>_iface (CI: the mirror MW, OK, TH, VAL, ENC):

  encode_eval   T.<C>_encode(TH(m)) == (TH(m), B.Buf{thaw(OUTE(m)), SZSM(m)}), the output tree the
                window's model at X = 0 of a zero tree of the size's depth;
  encode_spec   Decoding.decodes(Spec.<C>(), the buffer's bytes, VAL(m)).

The runtime's size pass (T.<C>_size) is rewritten through the children's sizex facts (its chain of
T.<C>_sz* / group _sz* helpers, as codegen/impl/typed_object_runtime.py emits them); its value is the byte count
ENDC (the interface's), with the exponent of the bound kept symbolic (k = 28).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.proofs.var.check_or_write_outputs import finish  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402

from codegen.proofs.var import container_encoder_windows as CE  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('container_encoder_top_laws', globals())

TOPS = ['ExecutionPayload', 'BeaconBlockBody', 'BeaconState']
SIZES = ['ExecutionPayload', 'ExecutionPayloadHeader', 'BeaconBlockBody', 'BeaconState']
# the generic wide containers' size modules (their interfaces state no sizex; gtop_text imports these)
GSIZES = ['ProgressiveBitsStruct']
TRUE = 'True{} : Bool'


def out_file(C):
    return ROOT / f'proofs/obj/var_codec_{C}_enc.bend'


REC = set()   # the containers whose interface is recordized: their size/top texts are too (CE.rm_iface)


def iface_params(C):
    txt = (ROOT / f'proofs/obj/encx_{C}_iface.bend').read_text()
    m = re.search(r'^def OKT\((.*?)\) -> Bool:', txt, re.M)
    P = m.group(1)
    if P == f'+{CE.RV}: K.KW':
        # a recordized interface (container_encoder_windows's RECORD): the fields are the writer's record K.KW's
        kw = re.search(r'^type KW is Data:\n  KW\{(.*)\}$', (ROOT / f'proofs/obj/encx_{C}.bend').read_text(), re.M).group(1)
        P = ', '.join('+' + x.strip() for x in CE_split(kw))
        REC.add(C)
    names = [x.split(':')[0].strip().lstrip('+') for x in CE_split(P)]
    imps = [ln for ln in txt.split('\n') if ln.startswith('import ') and not re.search(r'_d\.bend as \w+_D$', ln)]   # (the D twins: the companions' own)
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


def _top_container(C, generic, pfacts, plain_tot):
    """the container's object names (K, parameters, field objects, groups, the plain steps)"""
    from codegen.impl import typed_object_runtime as G
    from codegen.core import fulu_schema_loader as schema
    if generic:
        # a generic wide container (GSIZES): its size module only, from generic_obj
        from codegen.core import generic_form_schemas as GN
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
    # the objects of the fields (as container_encoder_windows's generate_cont builds them)
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
    return pfacts, plain_tot, K, P, OA, imps, OAS, FIX, p, fnames, OBJF, groups, gobj, OBJ, plain_steps, lin, var_of


def _top_steps(K, FIX, p, fnames, OBJF, groups, gobj, plain_steps, pfacts, plain_tot, lin, var_of):
    """the grouped sizes: the size step of each group of variable fields"""
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
    return steps, facts, tot


def _top_header_laws(C, P, OAS, FIX, p, OBJ, steps, facts, tot):
    """the module's header lemmas and the encode chain terms"""
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
    return L, w, ENDC, Ls, SZt, Q


def _top_size_chain_flat(P, OAS, FIX, facts, w, ENDC, Ls, SZt, Q):
    """the size laws of a container whose sizes chain without groups"""
    ls = []
    a = ls.append
    n = len(Ls)
    EP_ = [f'{FIX}n']
    CP_ = [str(FIX)]
    for i2 in range(n):
        EP_.append(f'Nat.add({EP_[-1]}, {Ls[i2]})')
        CP_.append(f'O.padd({CP_[-1]}, {SZt[i2]})')
    for line in TPL.render('_top_size_chain_flat_lines', OAS=OAS, n=n).split('\n'):
        a(line)
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
    w(TPL.render('_top_size_chain_flat', ENDC=ENDC, OAS=OAS, P=P, body=body, n=n))


def _top_size_chain_grouped(P, OAS, FIX, fnames, lin, var_of, facts, tot, w, ENDC, Ls, SZt, Q):
    """the size laws of a grouped container: the size tree, its Nat and U32 readings and the proof of the bound"""
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
    w(TPL.render('_top_size_chain_grouped', ENDC=ENDC, NT=NT, OAS=OAS, P=P, body=body, root=root))


def _top_putx_law(C, P, OA, OAS, OBJ, w, ENDC):
    """the top-level writer law: the runtime's put against the model and its size"""
    ptxt = (ROOT / f'proofs/obj/encx_{C}.bend').read_text()
    ph = re.search(r'^def putx\((.*?)\+dd: Nat, \+D: ', ptxt, re.M | re.S).group(1)
    pn = [x.split(':')[0].strip().lstrip('+') for x in CE_split(ph.rstrip().rstrip(','))]
    HA = pn[1:] if C in REC else pn[len(OA):]   # a recordized writer's putx takes the record (+wR: KW) first
    HAC = ', '.join(f'CI.ok_{x}({OAS}, h)' for x in HA)
    S = f'SZS({OAS})'
    Dd = f'VL.DO({S})'
    MA0 = f'{OAS}, {Dd}, VC.ZT({Dd}), 0, 0n, 0n'
    LLC = f'K.LLC({MA0})'
    ENCC = f'K.ENCC({OAS})'
    OUT = f'OUTC({OAS})'
    RTT = f'Array<U32> & (T.{C} & U32)'
    w(TPL.render('_top_putx_law', C=C, Dd=Dd, ENCC=ENCC, ENDC=ENDC, HAC=HAC, LLC=LLC, MA0=MA0, OA=OA, OAS=OAS, OBJ=OBJ, OUT=OUT, P=P, RTT=RTT, S=S))


def top_text(C, generic=False):
    pfacts = plain_tot = None  # bound only on some paths below; the helpers take them
    pfacts, plain_tot, K, P, OA, imps, OAS, FIX, p, fnames, OBJF, groups, gobj, OBJ, plain_steps, lin, var_of = _top_container(C, generic, pfacts, plain_tot)
    if not any(i.endswith(' as VBE') for i in imps):
        imps = imps + ['import ./vbenc.bend as VBE']
    steps, facts, tot = _top_steps(K, FIX, p, fnames, OBJF, groups, gobj, plain_steps, pfacts, plain_tot, lin, var_of)
    L, w, ENDC, Ls, SZt, Q = _top_header_laws(C, P, OAS, FIX, p, OBJ, steps, facts, tot)
    if plain_steps is not None:
        # E_0 = FIX, E_(s+1) = E_s + L_s (the interface's ENDC is E_n); C_0 = FIX, C_(s+1) = padd(C_s, size_s)
        _top_size_chain_flat(P, OAS, FIX, facts, w, ENDC, Ls, SZt, Q)
    else:
        # the size pass's value as a tree of padd over the fields' sizes: its Nat twin, bounded by the byte count
        _top_size_chain_grouped(P, OAS, FIX, fnames, lin, var_of, facts, tot, w, ENDC, Ls, SZt, Q)
    if K.wide:
        vt_ = valid_text(C, K, P, OAS, OBJF, groups, gobj, fnames, lin)
        if vt_:
            w(vt_)
    cut = len(L)
    if C not in TOPS:
        return L, [], K, P, OA, imps
    # ---- encode_eval / encode_spec ----
    # the writer's hypotheses, as the window's putx lists them (after the object's parameters, before dd)
    _top_putx_law(C, P, OA, OAS, OBJ, w, ENDC)
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


def acc_arg(term, call, k_):
    '''The offset of the k_-th top-level argument (True{}) of the first `call(` in term.'''
    i_ = term.index(call) + len(call)
    if k_ == 0:
        a0 = i_
    else:
        depth, argi, j_ = 0, 0, i_
        while True:
            ch_ = term[j_]
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
    assert term[a0:a0 + 6] == 'True{}', term[a0:a0 + 20]
    return a0


def valid_text(C, K, P, OAS, OBJF, groups, gobj, fnames, lin):
    """A wide container's validity pass (T.<C>_valid: its groups' _va chains) rewritten through its
    non-Data fields' validity facts; None when a field has none yet (a FixW field without its valid term)."""
    F, p = K.F, K.p
    steps, prfs = [], []
    gstart = {}   # step index -> (V, gk): the first step of a later group whose pass starts from V
    tacc = 'True{}'
    gok = None
    pre = ''
    pres = {}   # j > 0 -> (V, gk): a later group whose pass starts from its Data fields' check V
    for j, (gk, idx) in enumerate(lin):
        # a group whose Data fields have a check starts its pass with it (acc = V): V true (its hpz_g<k>, container_encoder_windows)
        body_ = CE.fn_body(f'{p}_g{gk}_valid')
        mm_ = re.search(r'case \w+\{([^}]*)\}: (\w+)\((.*)\)$', body_, re.M)
        pv_ = [v.strip().lstrip('+') for v in mm_.group(1).split(',')]
        args_ = __import__('codegen.proofs.var.block_body_offset_windows', fromlist=['_']).split_top(mm_.group(3))
        pn_ = CE.fn_params(mm_.group(2))
        acc0 = args_[pn_.index('acc')].strip()
        if acc0 != 'True{}':
            sub_ = dict(zip(pv_, [OBJF[fnames[i]] for i in idx]))
            V_ = re.sub(r'(?<![\w.])([A-Za-z_]\w*)\b(?![({])', lambda z_: sub_.get(z_.group(1), z_.group(1)), acc0)
            V_ = re.sub(r'(?<![\w.])([a-z_]\w*)\(', r'T.\1(', V_)
            if j == 0:
                pre = (V_, gk)
            else:
                pres[j] = (V_, gk)
    for j, (gk, idx) in enumerate(lin):
        gp = f'{p}_g{gk}'
        tparams = CE.fn_params(f'{p}_va{j}')
        if j > 0:
            tacc = f'Bool.and({tacc}, {gok})'
        gmap = {f'g{g2}': gobj[g2] for g2, _ in groups}
        gmap['acc'] = tacc
        nd = [i for i in idx if not F[i][1].data]
        acc = 'True{}'
        if j in pres:
            gstart[len(steps)] = pres[j]
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
            vn = '_valid_f' if (fs.kind == 'seq' and CE.has_valid_f(fs.p)) else '_valid'   # (a wrapped list field: its fields' validity, R4-05)
            steps.append((outer, f'T.{fs.p}{vn}({o})', f'({o}, True{{}})', f'{vt} & Bool'))
            prfs.append(prf.replace('{OAS}', OAS))
            acc = f'Bool.and({acc}, True{{}})'
        gok = acc
    RT = f'T.{C} & Bool'
    OBJ = f'K.OBJC({OAS})'
    start = f'T.{p}_valid_f({OBJ})' if CE.has_valid_f(p) else f'T.{p}_valid({OBJ})'
    end = f'({OBJ}, True{{}})'

    def chain(k, first):
        outer, lhs, rhs, ity = steps[k]
        e = f'Equal.cong({ity}, {RT}, z => {outer}, {lhs}, {rhs}, {prfs[k]})'
        if k == len(steps) - 1:
            return e
        after = outer.replace(', z)', f', {rhs})')
        nxt = steps[k + 1][0].replace(', z)', f', {steps[k + 1][1]})')
        if k + 1 in gstart:
            # the next group's pass starts from its Data fields' check V (after converts to nxt with acc = V):
            # V is True by CI.ok_hpz_g<k>, then the chain goes on from True
            V_, gk_ = gstart[k + 1]
            a0 = acc_arg(nxt, f'T.{p}_g{gk_}_va0(', CE.fn_params(f'{p}_g{gk_}_va0').index('acc'))
            nV = nxt[:a0] + V_ + nxt[a0 + 6:]
            br = f'Equal.cong(Bool, {RT}, zv => {nxt[:a0]}zv{nxt[a0 + 6:]}, {V_}, True{{}}, CI.ok_hpz_g{gk_}({OAS}, h))'
            return (f'Equal.trans({RT}, {first}, {after}, {end}, {e}, '
                    f'Equal.trans({RT}, {nV}, {nxt}, {end}, {br}, {chain(k + 1, nxt)}))')
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
    return TPL.render('valid_text', C=C, OAS=OAS, P=P, RT=RT, chain=chain, end=end, first=first, rw=rw, start=start)


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
    rs = re.search(r'O\.mulc\(\w+, (\d+)\)', ch.sz).group(1)
    W = int(rs) // 4
    if int(rs) % 4:
        # records of a size off a word (Validator: 121 bytes): the list module's own size lemma
        return (f'Equal.trans(Nat, U32.to_nat({ch.sz}), {LL}, LY.LN({a}.ENCL_{ch.p}({t}, {N})), '
                f'{a}.szx_{ch.p}({t}, {N}, 0n, 0n, k, CS.hk29(k, ek), VRX.nwn_le({LL}, VB.pw(k), {hm})), '
                f'Equal.sym(Nat, LY.LN({a}.ENCL_{ch.p}({t}, {N})), {LL}, {a}.len_encl_{ch.p}({t}, {N})))')
    return (f'Equal.trans(Nat, U32.to_nat({ch.sz}), {LL}, LY.LN({a}.ENCL_{ch.p}({t}, {N})), VRX.mulqc(k, {N}, U32.to_nat({N}), {rs}, {W}n, {{==}}, {{==}}, hk, {hm}, {{==}}, {{==}}, {{==}}), '
            f'Equal.sym(Nat, LY.LN({a}.ENCL_{ch.p}({t}, {N})), {LL}, {a}.len_encl_{ch.p}({t}, {N})))')


HEADX = ['import ../../src/buffer.bend as B', 'import ../../spec/decoding_relation.bend as Decoding', 'import ./vlist.bend as VL', 'import ./vdepth.bend as VD',
         'import ./vvlz.bend as VZG', 'import ./vuwb.bend as UWB', 'import ./vvle.bend as VE2']


def size_file(C):
    return ROOT / f'proofs/obj/encx_{C}_size.bend'



def u32_top(t, FIX):
    """U32 mode (BeaconState, CE.U32M): CI.ENDC spelled CI.ENDCs(.., U32.to_nat(F)) (as the interface states it);
    szS, summing from F, a core over F as a variable SZF (eSZF: SZF == U32.to_nat(F)), its bound carried once."""
    UF = f'U32.to_nat({FIX})'
    Fn = re.compile(rf'(?<![\w.]){FIX}n\b')
    out, i = [], 0
    while True:
        m = re.compile(r'(?<![\w.])CI\.ENDC\(').search(t, i)
        if m is None:
            out.append(t[i:])
            break
        c = CE.find_call(t, 'CI.ENDC', m.start())
        out.append(t[i:m.start()] + 'CI.ENDCs(' + ', '.join(c[2] + [UF]) + ')')
        i = c[1]
    t = ''.join(out)
    # the writer's byte count as the interface states it (VCN.LN: its List.length at the literal sizes evaluates)
    t = t.replace('List.length(&2, U32, K.ENCC(', 'VCN.LN(K.ENCC(')
    # bt_all states VRX.LN / VRX.AP: the goal's VCN.LN / VCN.AP rewritten to them by name (generic lnq / apq)
    j = 0
    while True:
        i = t.find('\n  VRX.bt_all(', j)
        if i < 0:
            break
        c = CE.find_call(t, 'VRX.bt_all', i)
        E_, B_ = c[2]
        rw = (f'\n  %lnq({E_}) : {{VS.bt(_, VCN.AP({E_}, {B_})) == {E_} : +List<U32>}}'
              f'\n  %apq({E_}, {B_}) : {{VS.bt(VRX.LN({E_}), _) == {E_} : +List<U32>}}')
        t = t[:i] + rw + t[i:]
        j = i + len(rw) + 5
    # the output tree by its writer's name (OUTC against K.PUTC would evaluate the output's bytes)
    mo = re.search(r'\ndef OUTC\((.*?)\) -> FD\.array__Tree<U32>: (.*)\n', t)
    if mo:
        body_ = mo.group(2)
        out, i = [], 0
        while True:
            c = CE.find_call(t, 'OUTC', i)
            if c is None:
                out.append(t[i:])
                break
            if t[max(0, c[0] - 4):c[0]] == 'def ' or (c[0] > 0 and (t[c[0] - 1].isalnum() or t[c[0] - 1] in '_.')):
                out.append(t[i:c[1]])
                i = c[1]
                continue
            out.append(t[i:c[0]] + body_)
            i = c[1]
        t = ''.join(out)
    # the output's bytes: the splice at 0 by the generic spl0 (unfolding SPL there would count the bytes)
    j = 0
    while True:
        i = t.find('\n  +e1 = Equal.trans(+List<U32>, UA.BYT(', j)
        if i < 0:
            break
        c = CE.find_call(t, 'Equal.trans', i)
        T_, a_, b_, c_, p_, q_ = c[2]
        if b_ == 'VCN.AP(Y, R)' and p_ == 'by':
            mR = re.search(r'\n  \+R = VS\.bdr\(VCN\.LN\(Y\), (.*)\)\n', t[:i + 1])
            BZ = mR.group(1)
            S0 = f'UW.SPL({BZ}, Nat.add(A.quad(0n), 0n), Y)'
            new = (f'Equal.trans(+List<U32>, {a_}, {S0}, {c_}, by, Equal.trans(+List<U32>, {S0}, VCN.AP(Y, R), {c_}, spl0({BZ}, Y), {q_}))')
            t = t[:c[0]] + new + t[c[1]:]
        j = i + 10
    if 'VS.app_assoc(' in t:
        # (VCN.AP's associativity by name: app_assoc states List.append, whose &2 defeats the identity check)
        t = t.replace('VS.app_assoc(', 'apa(')
        i = t.index('\ndef ')
        t = (t[:i] + '\ndef apa(+a: +List<U32>, +b: +List<U32>, +c: +List<U32>) -> {VCN.AP(VCN.AP(a, b), c) == VCN.AP(a, VCN.AP(b, c)) : +List<U32>}: VS.app_assoc(a, b, c)\n'
             + t[i:])
    if 'spl0(' in t and '\ndef spl0(' not in t:
        i = t.index('\ndef ')
        t = (t[:i] + '\n# a splice at 0 (generic: nothing evaluates)\n'
             + 'def spl0(+B: +List<U32>, +Y: +List<U32>) -> {UW.SPL(B, Nat.add(A.quad(0n), 0n), Y) == VCN.AP(Y, VS.bdr(VCN.LN(Y), B)) : +List<U32>}: {==}\n' + t[i:])
    if 'VRX.bt_all(' in t and '\ndef lnq(' not in t:
        i = t.index('\ndef ')
        t = (t[:i] + '\n# vrecx\'s length and append by name (generic: nothing evaluates)\n'
             + 'def lnq(+a: +List<U32>) -> {VRX.LN(a) == VCN.LN(a) : Nat}: {==}\n'
             + 'def apq(+a: +List<U32>, +b: +List<U32>) -> {VRX.AP(a, b) == VCN.AP(a, b) : +List<U32>}: {==}\n' + t[i:])
    if '\ndef szS(' not in t:
        return t
    a = t.index('\ndef szS(') + 1
    b = t.index('\ndef ', a)
    blk = t[a:b]
    hd = blk[:blk.index(':\n')]
    body = blk[len(hd) + 2:]
    params = hd[len('def szS('):hd.rindex(') -> ')]
    stmt = hd[hd.rindex(') -> ') + 5:]
    names = [x.split(':')[0].strip().lstrip('+') for x in CE.split_args(params)]
    OAS = ', '.join(names[:names.index('h')])
    body = body.replace(f'FD.nat__eq_from_is_eq({UF}, {FIX}n, {{==}})', f'Equal.sym(Nat, SZF, {UF}, eSZF)')
    body = Fn.sub('SZF', body)
    body = body.replace(f'{UF}, SZF, {{==}})', f'{UF}, SZF, Equal.sym(Nat, SZF, {UF}, eSZF))')
    body = body.replace(f'CI.ENDCs({OAS}, {UF})', f'CI.ENDCs({OAS}, SZF)')
    bnd = (f'FD.logic__subst(Nat, zf => {{Nat.is_le(CI.ENDCs({OAS}, zf), A.quad(VB.pw(k))) == True{{}} : Bool}}, {UF}, SZF, '
           f'Equal.sym(Nat, SZF, {UF}, eSZF), CI.okbk({OAS}, h, k, ek))')
    body = body.replace(f'CI.okbk({OAS}, h, k, ek)', bnd)
    st_c = stmt.replace(f'CI.ENDCs({OAS}, {UF})', f'CI.ENDCs({OAS}, SZF)')
    core = f'def szS_core({params}, +SZF: Nat, +eSZF: {{SZF == {UF} : Nat}}) -> {st_c}:\n{body.rstrip()}\n'
    wrap = f'def szS({params}) -> {stmt}:\n  szS_core({", ".join(names)}, {UF}, {{==}})\n\n'
    t = t[:a] + core + '\n' + wrap + t[b:]
    # szs through the interface's szx (its bytes' length as the law states it), the sizes' equation by match
    m = re.search(r'\ndef szs\(m, hok\):\n  match m:\n    case (CI\.MW\{[^\n]*\}): Equal\.trans[^\n]*\n[^\n]*\n', t)
    if m:
        pat = m.group(1)
        szsz = (TPL.render('szsz', OAS=OAS, UF=UF, pat=pat))
        new = ('\ndef szs(m, hok):\n  Equal.trans(Nat, U32.to_nat(SZSM(m)), U32.to_nat(CI.SZ(m)), List.length(&2, U32, CI.ENC(m)), szsz(m, hok), CI.szx(m, hok))\n')
        i = t.index('\nlaw szs:')
        t = t[:i] + szsz + t[i:m.start()] + new + t[m.end():]
    return t


def full_texts(C, generic=False):
    Ls, Lt, K, P, OA, imps = top_text(C, generic)
    OAS = ', '.join(OA)
    pat = ', '.join('+' + x for x in OA)
    sz = '\n'.join(Ls).replace('{OAS}', OAS) + TPL.render('full_texts', C=C, K=K, OAS=OAS, pat=pat)
    if 'def validC(' in sz:
        sz += TPL.render('full_texts_validx_f' if CE.has_valid_f(K.p) else 'full_texts_validx', C=C, K=K, OAS=OAS, pat=pat)
    if K.fixed >= CE.U32FIX:
        sz = u32_top(sz, K.fixed)
    hs = imps + HEADX + [f'import ./encx_{C}_iface.bend as CI', '', '# GENERATED by container_encoder_top_laws (codegen). Do not edit.',
                         f'# {C}: the runtime\'s size pass on its encoder window (T.{K.p}_size; see the generator).', '']
    out = {size_file(C): '\n'.join(hs) + '\n' + sz + '\n'}
    if Lt and not generic:
        top = '\n'.join(Lt).replace('{OAS}', OAS)
        top = re.sub(r'\bSZS\(', 'Z.SZS(', top)
        top = re.sub(r'\bsizeC\(', 'Z.sizeC(', top)
        top = re.sub(r'\bszS\(', 'Z.szS(', top)
        if K.fixed >= CE.U32FIX:
            top = u32_top(top, K.fixed)
        ht = imps + HEADX + [f'import ./encx_{C}_iface.bend as CI', f'import ./encx_{C}_size.bend as Z', '',
                             '# GENERATED by container_encoder_top_laws (codegen). Do not edit.',
                             f'# {C}: the encoder laws at X = 0 on its encoder window (see the generator).', '']
        out[out_file(C)] = '\n'.join(ht) + '\n' + top + '\n'
    if C in REC:
        OP = [x.strip() for x in CE_split(P)]
        out = {q: CE.rm_iface(t, OP, OA) for q, t in out.items()}
    return out


# ==== the generic containers (types/generic_obj.bend, proofs/obj/generic_specs.bend): encode laws on the mirror ====
# For a plain container whose interface module states all eight laws, the laws follow from the
# interface alone: the size pass is CI.sizex, its value CI.szx, the bound CI.bndx, the writer at X = 0 of
# a zero tree CI.putx / putx_bytes, the spec CI.encx_spec.

GTOPS = ['ProgressiveSingleListContainerTestStruct', 'ProgressiveVarTestStruct', 'ProgressiveComplexTestStruct', 'VarTestStruct', 'ProgressiveTestStruct', 'BitsStruct', 'ComplexTestStruct', 'BeaconBlock', 'SignedBeaconBlock',
         'CompatibleUnionA', 'CompatibleUnionBC', 'CompatibleUnionABCA', 'LightClientFinalityUpdate', 'ProgressiveBitsStruct', 'LightClientUpdate']


def gtop_text(C):
    txt = (ROOT / f'proofs/obj/encx_{C}_iface.bend').read_text()
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
    src = RR.mono_text('generic')
    if RR.runtime_of(txt) != 'generic':
        src = RR.mono_text('fulu')
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
    body = TPL.render('body', C=C, Dd=Dd, L=L, OUT=OUT, RTT=RTT, S=S, SZX=SZX, TH=TH)
    if fixd is None:
        body = body.replace('@ROOMF\n', '\n').replace('@EVALF\n', '')
    else:
        L_ = L
        roomf = TPL.render('roomf', Dd=Dd, L_=L_, MX=MX, fixd=fixd)
        OUTB = f'B.Buf{{FD.array__thaw(U32, {OUT}), {S}}}'
        evalf = TPL.render('evalf', C=C, Dd=Dd, L_=L_, MX=MX, OUT=OUT, OUTB=OUTB, RTT=RTT, S=S, TH=TH, kb=kb)
        body = body.replace('@ROOMF\n', roomf + '\n')
        # the size-depth room (bndx, 2^28) is not used at a fixed depth
        j0 = body.index("# the writer's hypotheses at X = 0")
        j1 = body.index('\n# the fixed depth')
        body = body[:j0] + body[j1 + 1:].replace('@EVALF\n', evalf)
        # the size-depth bound (bndx, 2^28) is not used at a fixed depth: no npz (the size is bounded by CI.maxx: a31)
        k0 = body.index('def npz(')
        k1 = body.index('\ndef ', k0)
        body = body[:k0] + body[k1 + 1:]
        # the fixed encoder has no size pass: its eval is eval_go above; the sized one is dropped
        i0 = body.index('def eval_go_sized(')
        i1 = body.index('# The output\'s first bytes')
        body = body[:i0] + body[i1:]
        body = body.replace('room(m, hok, 28n, {==})', 'roomf(m, hok)')
        imps = imps + ['import ./vbenc.bend as VBE']
    if not any(i.endswith(' as VBE') for i in imps):
        imps = imps + ['import ./vbenc.bend as VBE']
    tsrc = src if RR.runtime_of(txt) == 'generic' else RR.mono_text('fulu')
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
    hs = imps + HEADX + [f'import ./encx_{C}_iface.bend as CI'] + ([f'import ./encx_{C}_size.bend as Z'] if C in GSIZES else []) + ['', '# GENERATED by container_encoder_top_laws (codegen). Do not edit.',
                         f'# {C}: the encoder laws at X = 0, from its encoder window\'s interface (see the generator: gtop_text).', '']
    return '\n'.join(hs) + '\n' + body


def okw_sizes(out):
    """The size modules' companions <size>_o: their O laws on the interface's OKW (codegen/proofs/support/encode_size_limit_twins.py okw_size: the
    encoding below 2^31 bytes, the object API's own limit), in their own module so that only their callers check
    them; the interfaces' companions (<iface>_o, codegen/proofs/var/container_encoder_windows.py) through okw_relink."""
    from codegen.proofs.support import encode_size_limit_twins as okw
    comp = {}
    for q, t in out.items():
        t2 = okw_size(q, t)
        if t2 != t:
            comp[q.with_name(q.stem + '_o.bend')] = okw.okw_companion(t, t2, q.stem, 'the size and validity passes on OKW (encodings below 2^31 bytes) of ' + q.stem, 'container_encoder_top_laws')
    names = {q.stem[:-2]: okw._names(c) for q, c in comp.items()}
    for p in (ROOT / 'proofs/obj').glob('encx_*_iface_o.bend'):
        names[p.stem[:-2]] = okw._names(p.read_text())
    return {q: okw.okw_relink(c, names) for q, c in comp.items()}


def _has_okw(stem):
    """The interface stem has OKTW (in its base module, or in its companion <stem>_o: BeaconState's)."""
    return any('def OKTW(' in p.read_text() for p in (ROOT / f'proofs/obj/{stem}.bend', ROOT / f'proofs/obj/{stem}_o.bend') if p.exists())


def okw_tops(out):
    """The encoder laws' O twins (encode_evalO / encode_specO on OKW, the output tree below depth 31; codegen/proofs/support/encode_size_limit_twins.py
    top_o / gtop_o) of the tops with an OKW interface, in the companions var_codec_<C>_enc_o."""
    from codegen.proofs.support import encode_size_limit_twins as okw
    comp = {}
    for q, t in out.items():
        if not (q.stem.startswith('var_codec_') and q.stem.endswith('_enc')):
            continue
        ci = re.search(r'^import \./(\w+)\.bend as CI$', t, re.M)
        if not ci or not _has_okw(ci.group(1)) or 'law encode_eval:' not in t:
            continue
        if 'def putx0(' in t:
            k = re.search(r'^import \./(\w+)\.bend as K$', t, re.M)
            kt = (ROOT / f'proofs/obj/{k.group(1)}.bend').read_text()
            ko = ROOT / f'proofs/obj/{k.group(1)}_o.bend'   # (BeaconState's writer twins live in its companion)
            kt += ko.read_text() if ko.exists() else ''
            t2 = okw.top_o(t, 'putxO' if '\ndef putxO(' in kt else 'putxW')
        elif ('def room(' in t or 'def roomf(' in t) and 'Z.sizez(' not in t:   # (the wide generic containers' size module: later)
            t2 = okw.gtop_o(t)
        else:
            continue
        if t2 != t:
            comp[q.with_name(q.stem + '_o.bend')] = okw.okw_companion(t, t2, q.stem, 'the encoder laws on OKW (encodings below 2^31 bytes) of ' + q.stem, 'container_encoder_top_laws')
    names = {q.stem[:-2]: okw._names(c) for q, c in comp.items()}
    for p in (ROOT / 'proofs/obj').glob('encx_*_o.bend'):
        names.setdefault(p.stem[:-2], okw._names(p.read_text()))
    for q, t in out.items():
        if q.stem.endswith('_size_o') or q.stem.endswith('_iface_o'):
            names.setdefault(q.stem[:-2], okw._names(t))
    return {q: okw.okw_relink(c, names) for q, c in comp.items()}


def okw_size(q, t):
    """A size module with its O laws on its interface's OKW, when the interface has OKW."""
    from codegen.proofs.support import encode_size_limit_twins as okw
    if not q.stem.endswith('_size'):
        return t
    ci = re.search(r'^import \./(\w+)\.bend as CI$', t, re.M)
    if not ci or not _has_okw(ci.group(1)):
        return t
    child, es = set(), set()
    for mi in re.finditer(r'^import \./(\w+)\.bend as (\w+)$', t, re.M):
        p = ROOT / f'proofs/obj/{mi.group(1)}.bend'
        if mi.group(2) in ('CI', 'Z', 'K'):
            continue
        if mi.group(1).endswith('_size'):
            es.add(mi.group(2) + '.')
        elif p.exists() and 'def OKTW(' in p.read_text():
            child.add(mi.group(2) + '.')
    imp = (ROOT / f'proofs/obj/{ci.group(1)}.bend').read_text()
    me = re.search(r'^def ENDC\(.*?\) -> Nat: (.*)$', imp, re.M)
    t, bad = okw.okw_size(t, child, es, me.group(1) if me else None, dchild=ci.group(1) in okw.LIST_D_STEMS)
    if bad:
        raise SystemExit(f'container_encoder_top_laws: {q.name}: uses of k okw_size does not handle: {bad[:3]}')
    return t


def main():
    # accepts '--check' (check_or_write_outputs.finish reads it)
    out = {}
    for C in SIZES:
        out.update(full_texts(C))
    for C in GSIZES:
        out.update(full_texts(C, generic=True))
    for C in GTOPS:
        out[out_file(C)] = gtop_text(C)
    out = RR.rewire_out(out)
    out.update(okw_sizes(out))
    out.update(okw_tops(out))
    return finish(out, 'stale generated container encoder laws: ', 'generated container encoder laws are current', rewire=False, retire=True)


if __name__ == '__main__':
    main()
