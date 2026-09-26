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

TOPS = ['ExecutionPayload']
SIZES = ['ExecutionPayload']
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


def top_text(C):
    import generate as G
    import schema
    g, names = G.Gen(), schema.load(ROOT / 'codegen/fulu.yaml')
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
    for j, (gk, idx) in enumerate(lin):
        gp = f'{p}_g{gk}'
        # the top step's context: sz<j>(others..., acc, z)
        tparams = CE.fn_params(f'{p}_sz{j}')
        tacc = str(FIX) if j == 0 else f'O.padd({FIX}, 0)'
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
        tot = f'O.padd(O.padd({FIX}, 0), {sizes[lin[-1][0]]})' if len(lin) == 2 and not var_of[lin[0][0]] else None
    assert tot is not None, 'size chains of this shape: TODO'
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
        ls = []
        a = ls.append
        a(f'+bnd = CI.okbk({OAS}, h, k, ek)')
        a(f'+hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, 29n) == {TRUE}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {{==}})')
        # E4 == ENDC
        n = len(Ls)
        assert n == 3
        a(f'+e4 = Equal.trans(Nat, {E4}, Nat.add(Nat.add({FIX}n, {E[1]}), {Ls[2]}), {ENDC}, Equal.sym(Nat, Nat.add(Nat.add({FIX}n, {E[1]}), {Ls[2]}), {E4}, FD.nat__add_assoc({FIX}n, {E[1]}, {Ls[2]})), '
          f'Equal.cong(Nat, Nat, z => Nat.add(z, {Ls[2]}), Nat.add({FIX}n, {E[1]}), Nat.add(Nat.add({FIX}n, {Ls[0]}), {Ls[1]}), Equal.sym(Nat, Nat.add(Nat.add({FIX}n, {Ls[0]}), {Ls[1]}), Nat.add({FIX}n, {E[1]}), FD.nat__add_assoc({FIX}n, {Ls[0]}, {Ls[1]}))))')
        a(f'+b4 = FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE}}}, {ENDC}, {E4}, Equal.sym(Nat, {E4}, {ENDC}, e4), bnd)')
        a(f'+b3 = FD.nat__le_trans({E[2]}, {E4}, {Q}, Order.left_below_sum({FIX}n, {E[2]}), b4)')
        a(f'+b2 = FD.nat__le_trans({E[1]}, {E[2]}, {Q}, Order.below_sum({E[1]}, {Ls[2]}), b3)')
        a(f'+b1 = FD.nat__le_trans({E[0]}, {E[1]}, {Q}, Order.below_sum({E[0]}, {Ls[1]}), b2)')
        a(f'+bl1 = FD.nat__le_trans({Ls[1]}, {E[1]}, {Q}, Order.left_below_sum({E[0]}, {Ls[1]}), b2)')
        a(f'+bl2 = FD.nat__le_trans({Ls[2]}, {E[2]}, {Q}, Order.left_below_sum({E[1]}, {Ls[2]}), b3)')
        bls = ['b1', 'bl1', 'bl2']
        for i2, (f, ch, sz) in enumerate(facts):
            a(f'+z{i2} = {szx_term(f, ch, bls[i2])}')
        # the partial sums
        for i2 in range(n):
            cur, sz = PT[i2], SZt[i2]
            prev = '0n' if i2 == 0 else E[i2 - 1]
            tgt = E[i2]
            # to_nat(padd(cur, sz)) == Nat.add(to_nat cur, to_nat sz) == Nat.add(prev, L)  (== L when i2 == 0)
            ec = '{==}' if i2 == 0 else f'c{i2 - 1}'
            a(f'+ea{i2} = Equal.trans(Nat, Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), Nat.add({prev}, U32.to_nat({sz})), Nat.add({prev}, {Ls[i2]}), '
              f'Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat({sz})), U32.to_nat({cur}), {prev}, {ec}), Equal.cong(Nat, Nat, z => Nat.add({prev}, z), U32.to_nat({sz}), {Ls[i2]}, z{i2}))')
            bnd_i = 'b1' if i2 == 0 else ('b2' if i2 == 1 else 'b3')
            a(f'+c{i2} = Equal.trans(Nat, U32.to_nat(O.padd({cur}, {sz})), Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), {tgt}, '
              f'VCN.padd_dd({cur}, {sz}, k, hk, FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE}}}, Nat.add({prev}, {Ls[i2]}), Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), '
              f'Equal.sym(Nat, Nat.add(U32.to_nat({cur}), U32.to_nat({sz})), Nat.add({prev}, {Ls[i2]}), ea{i2}), {bnd_i})), ea{i2})')
        a(f'+cf = Equal.trans(Nat, U32.to_nat(O.padd(O.padd({FIX}, 0), {PT[n]})), Nat.add({FIX}n, U32.to_nat({PT[n]})), {E4}, '
          f'VCN.padd_dd(O.padd({FIX}, 0), {PT[n]}, k, hk, FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({FIX}n, z), {Q}) == {TRUE}}}, {E[2]}, U32.to_nat({PT[n]}), Equal.sym(Nat, U32.to_nat({PT[n]}), {E[2]}, c{n - 1}), b4)), '
          f'Equal.cong(Nat, Nat, z => Nat.add({FIX}n, z), U32.to_nat({PT[n]}), {E[2]}, c{n - 1}))')
        body = '\n  '.join(ls)
        w(f'''
    # The size pass's value is the byte count.
    def szS({P}, +h: {{CI.OKT({OAS}) == {TRUE}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{U32.to_nat(SZS({OAS})) == {ENDC} : Nat}}:
      {body}
      Equal.trans(Nat, U32.to_nat(SZS({OAS})), {E4}, {ENDC}, cf, e4)
    ''')
    cut = len(L)
    if C not in TOPS:
        return L, [], K, P, OA, imps
    # ---- encode_eval / encode_spec ----
    HA = []
    for f, fs in F:
        if fs.fixed and fs.kind == 'fixwords':
            HA += [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}']
        elif not fs.fixed:
            HA += K.children[f].hargs
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
    return f'{ch.alias}.sizex_{ch.p}({ch.oargs[0]}, {ch.oargs[1]}, {h})'


def len_term(ch):
    if ch.p == 'bl32':
        return f'LY.LN(EB.ENC({ch.oargs[0]}))'
    if ch.p == 'l1048576_bl1073741824':
        return f'LY.LN(ET.ENCL({ch.oargs[0]}, {ch.oargs[1]}))'
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


def full_texts(C):
    Ls, Lt, K, P, OA, imps = top_text(C)
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
'''
    hs = imps + HEADX + [f'import ./big_encx_{C}_iface.bend as CI', '', '# GENERATED by codegen/var_cont_top.py. Do not edit.',
                         f'# {C}: the runtime\'s size pass on its encoder window (T.{K.p}_size; see the generator).', '']
    out = {size_file(C): '\n'.join(hs) + '\n' + sz + '\n'}
    if Lt:
        top = '\n'.join(Lt).replace('{OAS}', OAS)
        top = re.sub(r'\bSZS\(', 'Z.SZS(', top)
        top = re.sub(r'\bsizeC\(', 'Z.sizeC(', top)
        top = re.sub(r'\bszS\(', 'Z.szS(', top)
        ht = imps + HEADX + [f'import ./big_encx_{C}_iface.bend as CI', f'import ./big_encx_{C}_size.bend as Z', '',
                             '# GENERATED by codegen/var_cont_top.py. Do not edit.',
                             f'# {C}: the encoder laws at X = 0 on its encoder window (see the generator).', '']
        out[out_file(C)] = '\n'.join(ht) + '\n' + top + '\n'
    return out


def main():
    out = {}
    if '--no-big' not in sys.argv:
        for C in SIZES:
            out.update(full_texts(C))
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
