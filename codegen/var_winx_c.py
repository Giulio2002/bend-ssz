#!/usr/bin/env python3
"""Byte-offset windows of CONTAINERS WITH SEVERAL VARIABLE FIELDS among fixed ones,
each variable field a type with a byte-offset window module: the interface of
proofs/obj/vua_win.bend (CHKw, ok_evalw, OBJw, readw, VALw, specw, invw).

    python3 codegen/var_winx_c.py [--check] [--no-big]

Covered: ExecutionPayload (extra_data: ByteList[32], transactions:
List[ByteList[2^30], 2^20], withdrawals: List[Withdrawal, 16]; children
big_vvlb_bl32, big_vvl_l1048576_bl1073741824 (codegen/var_vlist.py) and
var_winx_l16_Withdrawal (codegen/var_rlist.py)). Its window module keeps the
name proofs/obj/var_winx_ExecutionPayload.bend (BeaconBlockBody's generator
imports it) although it imports big modules: check it with checkq --big. With
--no-big nothing is written or checked.

The offsets O_j are the words UR.RWN(t, c_j + x) at the offset fields c_j; child j's
window is (off + O_j, E_j - O_j) at O_j + x, E_j the next offset (len for the last).
The validator mirror is the runtime's chain: FS <= len, O_0 = FS, O_(j-1) <= O_j <= len,
then the children's checks. The reader reads the fixed fields' words (vua_fix /
vbx_fix rdx_*, vbx.copy_into_at) and hands the children's windows to their readw.
The spec side lays the parts out one part at a time (proofs/obj/vwc.bend fp_fix,
fp_var) into the fixed section's words and the children's windows (UW.headWX,
vrc splitWX). The inversion walks the spec relation over the items (the fixed
fields' byte lengths, the children's variable parts), reads the offsets back from
the fixed section (vwc bdr_skip, UW.byteWX) and hands the children's windows to
their invw.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import schema  # noqa: E402
import spec_laws as SL  # noqa: E402
import var_laws as VL  # noqa: E402
import var_bytes as VBY  # noqa: E402
import var_bytes_x as VX  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]

# container -> variable field -> child window: runtime prefix, module, spec schema, object type,
# its one-part fact on a value h (DF.single_result(None{}, parts(h, schema))).
CONTAINERS = {
    'ExecutionPayload': {
        'extra_data': dict(p='bl32', mod='big_vvlb_bl32', sch='Spec.Schema70()', rep='O.Words',
                           sgl='VVL.bsingle(32n, h)'),
        'transactions': dict(p='l1048576_bl1073741824', mod='big_vvl_l1048576_bl1073741824', sch='Spec.Schema73()',
                             rep='T.l1048576_bl1073741824_Seq', sgl='VWC.lsingle(Spec.Schema60(), U32.to_nat(1048576), h)'),
        'withdrawals': dict(p='l16_Withdrawal', mod='var_winx_l16_Withdrawal', sch='Spec.Schema74()',
                            rep='T.l16_Withdrawal_Seq', sgl='VWC.lsingle(Spec.Schema72(), 16n, h)'),
    },
}

TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'
MP = 'Maybe<&2, +List<S.Part>>'
P = 'A.quad(VB.pw(d))'
CW = (f'+d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {{U32.to_nat(off) == x : Nat}},\n'
      f'    +hd: {{Nat.is_lt(d, 28n) == {TRUE}}}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P}) == {TRUE}}},\n'
      f'    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}')
CA = 'd, t, n, x, off, len, eo, hd, hw, pf'
TXO = f'+t: {TR}, +x: Nat, +off: U32, +len: U32'
WW = 'UW.WX(t, x, U32.to_nat(len))'
GOAL = f'{{CHKw(t, x, off, len) == {TRUE}}}'
RHSV = f'Some{{[S.Variable{{{WW}}}]}}'

HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
        'import ../../src/primitives.bend as I', 'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
        'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vfits.bend as VFT', 'import ./vnest.bend as VN',
        'import ./vdig.bend as VG', 'import ./vmul.bend as VM', 'import ./vmr.bend as VMR', 'import ./vrc.bend as VRC', 'import ./vmv.bend as VV',
        'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_win.bend as UW', 'import ./vua_ct.bend as UCT',
        'import ./vua_fix.bend as VTX', 'import ./vbx_fix.bend as XF', 'import ./vbx.bend as VBX', 'import ./vvl.bend as VVL',
        'import ./vwc.bend as VWC']


def fname(n):
    return ROOT / f'proofs/obj/var_winx_{n}.bend'


class CName:
    def __init__(self, g, n, t, kids):
        self.n, self.t, self.g = n, t, g
        s = g.shape(t)
        assert s.kind == 'container'
        self.s = s
        self.fields = []
        pos = 0
        c = iter(range(100000))
        src = VBY.src()
        nv = 0
        for (fn, ft), (_, fs) in zip(t.fields, s.fields):
            if ft.fixed():
                size = ft.fixed_size()
                assert size % 4 == 0, fn
                if fs.kind in ('fixwords', 'packed'):
                    m = re.search(rf'^def {fs.p}_read\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & O\.Words: '
                                  rf'O\.copy_into\(buf, off, {size}, Array\.new\(U32, (\d+)n, 0\)\)$', src, re.M)
                    assert m, fn
                    f = {'kind': 'words', 'dz': int(m.group(1)), 'p': fs.p, 'size': size, 'W': size // 4}
                else:
                    ftw = VBY.FTW(g, ft)
                    f = {'kind': 'fix', 'ft': ftw, 'p': ftw.p, 'size': size, 'W': size // 4}
                f['node'] = SL.walk(g, ft, c)
            else:
                k = kids[fn]
                f = {'kind': 'var', 'j': nv, 'size': 4, 'W': 1}
                f.update(k)
                nv += 1
            f.update({'name': fn, 't': ft, 'c': pos, 'k': pos // 4})
            self.fields.append(f)
            pos += f['size']
        self.FS, self.H = pos, pos // 4
        self.vars = [f for f in self.fields if f['kind'] == 'var']
        self.K = len(self.vars)
        assert self.K >= 2
        self.m = len(self.fields)
        self.check_runtime()

    # -- terms --
    def O(self, j):
        return f'O{j}(t, x)'

    def L(self, j):
        return f'L{j}(t, x, len)' if j == self.K - 1 else f'L{j}(t, x)'

    def X(self, j):
        return f'X{j}(t, x)'

    def F(self, j):
        return f'F{j}(off, t, x)'

    def E(self, j):
        return 'len' if j == self.K - 1 else self.O(j + 1)

    def Y(self, j):
        return f'UW.WX(t, {self.X(j)}, U32.to_nat({self.L(j)}))'

    def words(self, f):
        return [VX.rwn(f['c'] + 4 * i) for i in range(f['W'])]

    def node(self, f):
        nd = f['node']
        ws = self.words(f)
        mp = {int(w[1:]): ws[j] for j, w in enumerate(nd.words)}
        sub = lambda s: re.sub(r'\bx(\d+)\b', lambda mm: mp[int(mm.group(1))], s)  # noqa: E731
        return {'val': sub(nd.val), 'sch': nd.sch, 'proof': sub(nd.proof), 'words': ws}

    def obj(self, f):
        if f['kind'] == 'fix':
            return f['ft'].obj(self.words(f))
        if f['kind'] == 'words':
            return f'O.Words{{FD.array__thaw(U32, UCT.CT(d, t, U32.add(off, {f["c"]}), {f["size"]}, {f["dz"]}n)), {f["size"]}}}'
        j = f['j']
        return f'C{j}.OBJw(d, t, {self.X(j)}, {self.F(j)}, {self.L(j)})'

    def check_runtime(self):
        n, FS, K = self.n, self.FS, self.K
        cv = [f['c'] for f in self.vars]
        os_ = lambda i: ', '.join(f'o{q}' for q in range(i + 1))  # noqa: E731
        want = [f'def {n}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {n}_ok_len(U32.is_le({FS}, len), buf, off, len)',
                f'    case True{{}}: {n}_v0(off, len, B.read32(buf, (off + {cv[0]} : U32)))',
                f'  {n}_c0(U32.is_eq(o0, {FS}), buf, off, len, o0)']
        for i in range(1, K):
            want.append(f'    case True{{}}: {n}_v{i}(off, len, {os_(i - 1)}, B.read32(buf, (off + {cv[i]} : U32)))')
            want.append(f'  {n}_c{i}(Bool.and(U32.is_le(o{i - 1}, o{i}), U32.is_le(o{i}, len)), buf, off, len, {os_(i)})')
        for j, f in enumerate(self.vars):
            end = 'len' if j == K - 1 else f'o{j + 1}'
            want.append(f'    case True{{}}: {n}_v{K + j}(off, len, {os_(K - 1)}, {f["p"]}_ok(buf, (off + o{j} : U32), ({end} - o{j} : U32)))')
        want.append(f'def {n}_c{2 * K - 1}(ok: Bool, buf: B.Buf, +off: U32, +len: U32, {", ".join(f"+o{q}: U32" for q in range(K))}) -> B.Buf & Bool:')
        src = VBY.src()
        for w in want:
            assert w in src, w


# ---- the reader plan (codegen/var_bytes.py read_plan, with several offsets and child windows) ----

def read_plan(x):
    g, s = x.g, x.s
    Fs = [(f, g.shape(ft)) for f, ft in x.t.fields]
    hoff, fixed_part = G.container_layout(Fs)
    assert fixed_part == x.FS
    byname = {f['name']: f for f in x.fields}
    leaves = []

    def offval(f):
        return x.O(f['j'])

    def fieldset(p, R, names, vend, ctx, mode):
        idx = [x.fields.index(byname[nm]) for nm in names]
        var = [j for j, q in enumerate(idx) if x.fields[q]['kind'] == 'var']
        steps = [('off', j) for j in var] + [('field', j) for j in range(len(idx))]
        vals = []
        xarg = f', {vend}' if mode == 'group' else ''
        for k, st in enumerate(steps):
            args = ''.join(f'{v}, ' for v in vals)
            frame = f'T.{p}_rd{k}(off, len{xarg}, {args}@)'
            c = ctx.replace('@', frame)
            f = x.fields[idx[st[1]]]
            if st[0] == 'off':
                leaves.append((c, f'B.read32(BF(t, n), U32.add(off, {f["c"]}))', offval(f), 'off', f))
                vals.append(offval(f))
            else:
                if f['kind'] == 'var':
                    later = [x.fields[idx[q]] for q in var if q > st[1]]
                    end = offval(later[0]) if later else (vend if mode == 'group' else 'len')
                    call = f'T.{f["p"]}_read(BF(t, n), U32.add(off, {offval(f)}), U32.sub({end}, {offval(f)}))'
                else:
                    call = f'T.{f["p"]}_read(BF(t, n), U32.add(off, {f["c"]}), {f["size"]})'
                v = x.obj(f)
                leaves.append((c, call, v, f['kind'], f))
                vals.append(v)
        return f'T.{R}{{' + ', '.join(vals[len(var):]) + '}'

    names = [f for f, _ in Fs]
    if len(Fs) <= G.GROUP:
        return leaves, fieldset(s.p, s.t.name, names, None, '@', 'plain')
    groups = []
    for k in range(0, len(Fs), G.GROUP):
        groups.append((k // G.GROUP, names[k:k + G.GROUP], hoff[k:k + G.GROUP], [fs for _, fs in Fs[k:k + G.GROUP]]))
    firstvar = {}
    for gk, gn, gh, gfs in groups:
        for h, fs in zip(gh, gfs):
            if not fs.fixed:
                firstvar[gk] = h
                break
    vg = [gk for gk, *_ in groups if gk in firstvar]
    steps = [('v', k) for k in vg] + [('g', gk) for gk, *_ in groups]
    vals = []
    vv = {}
    for k, st in enumerate(steps):
        args = ''.join(f'{v}, ' for v in vals)
        frame = f'T.{s.p}_rd{k}(off, len, {args}@)'
        if st[0] == 'v':
            f = [q for q in x.fields if q['c'] == firstvar[st[1]]][0]
            leaves.append((frame, f'B.read32(BF(t, n), U32.add(off, {firstvar[st[1]]}))', offval(f), 'off', f))
            vals.append(offval(f))
            vv[st[1]] = offval(f)
        else:
            gk = st[1]
            later = [q for q in vg if q > gk]
            vend = vv[later[0]] if later else 'len'
            gp = f'{s.p}_g{gk}'
            vals.append(fieldset(gp, gp, groups[gk][1], vend, frame, 'group'))
    return leaves, f'T.{s.t.name}{{' + ', '.join(vals[len(vg):]) + '}'


# ---- the module -----------------------------------------------------------------------------------

def app(a, b):
    return f'List.append(&2, U32, {a}, {b})'


def ln(a):
    return f'List.length(&2, U32, {a})'


def nadd(a, b):
    return f'Nat.add({a}, {b})'


def trans(T, terms, proofs):
    """Equal.trans chain through terms[0] .. terms[-1] with proofs[i] : terms[i] == terms[i + 1]."""
    if len(proofs) == 1:
        return proofs[0]
    return f'Equal.trans({T}, {terms[0]}, {terms[1]}, {terms[-1]}, {proofs[0]}, {trans(T, terms[1:], proofs[1:])})'


def lassoc(base, ys):
    """(left-assoc sum, right-assoc sum, proof left == right) of base + ys[0] + .. + ys[-1]."""
    Ls = [base]
    for y in ys:
        Ls.append(nadd(Ls[-1], y))

    def rs(k):
        return ys[-1] if k == len(ys) - 1 else nadd(ys[k], rs(k + 1))
    right = nadd(base, rs(0))
    if len(ys) == 1:
        return Ls[-1], right, '{==}'
    # Nat.add(L(k), rs(k)) for k = n-1 .. 0; step: assoc(L(k-1), ys[k-1], rs(k))
    terms, proofs = [], []
    n = len(ys)
    terms.append(nadd(Ls[n - 1], rs(n - 1)))
    for k in range(n - 1, 0, -1):
        proofs.append(f'FD.nat__add_assoc({Ls[k - 1]}, {ys[k - 1]}, {rs(k)})')
        terms.append(nadd(Ls[k - 1], rs(k - 1)))
    return Ls[-1], right, trans('Nat', terms, proofs)


def win_text(x):
    n, FS, H, K, m = x.n, x.FS, x.H, x.K, x.m
    Tn = f'T.{n}'
    cv = [f['c'] for f in x.vars]
    N_ = 2 * K + 1
    O, L, X, Fk, E, Y = x.O, x.L, x.X, x.F, x.E, x.Y
    HA = f'+ha: {{U32.is_le({FS}, len) == {TRUE}}}'
    L_ = list(HEAD) + [f'import ./{f["mod"]}.bend as C{f["j"]}' for f in x.vars] + [
        '', '# GENERATED by codegen/var_winx_c.py. Do not edit.',
        f'# {n} at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend, over the',
        '# byte-offset window modules C_j of its variable fields (see codegen/var_winx_c.py). Checked with',
        '# checkq --big (its children are big modules).', '']
    w = L_.append
    # ---- offsets and windows ----
    w(f'def BF(t: {TR}, +n: U32) -> B.Buf: UA.BF(t, n)')
    w('')
    w('# the offsets, the children\'s lengths, byte positions and runtime offsets')
    for j in range(K):
        w(f'def O{j}(+t: {TR}, +x: Nat) -> U32: UR.RWN(t, Nat.add({cv[j]}n, x))')
    for j in range(K):
        if j == K - 1:
            w(f'def L{j}(+t: {TR}, +x: Nat, +len: U32) -> U32: U32.sub(len, O{j}(t, x))')
        else:
            w(f'def L{j}(+t: {TR}, +x: Nat) -> U32: U32.sub(O{j + 1}(t, x), O{j}(t, x))')
    for j in range(K):
        w(f'def X{j}(+t: {TR}, +x: Nat) -> Nat: Nat.add(U32.to_nat(O{j}(t, x)), x)')
    for j in range(K):
        w(f'def F{j}(+off: U32, +t: {TR}, +x: Nat) -> U32: U32.add(off, O{j}(t, x))')
    # ---- the validator ----
    w('')
    w('# ---- the validator ------------------------------------------------------------------------------')
    w('')
    Q = ['CA(len)', 'CB(t, x)'] + [f'CC{j}(t, x, len)' for j in range(1, K)] + [f'CE{j}(t, x, off, len)' for j in range(K)]
    w(f'def CA(+len: U32) -> Bool: U32.is_le({FS}, len)')
    w(f'def CB(+t: {TR}, +x: Nat) -> Bool: U32.is_eq(O0(t, x), {FS})')
    for j in range(1, K):
        w(f'def CC{j}(+t: {TR}, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le({O(j - 1)}, {O(j)}), U32.is_le({O(j)}, len))')
    for j in range(K):
        w(f'def CE{j}({TXO}) -> Bool: C{j}.CHKw(t, {X(j)}, {Fk(j)}, {L(j)})')
    KC = [f'KC{i}(t, x, off, len)' for i in range(N_)]
    for i in reversed(range(N_)):
        body = Q[i] if i == N_ - 1 else f'Bool.and({Q[i]}, {KC[i + 1]})'
        w(f'def KC{i}({TXO}) -> Bool: {body}')
    w(f'def CHKw({TXO}) -> Bool: KC0(t, x, off, len)')
    w('')
    # helpers
    w(f'''def natle(+a: U32, +b: U32, +h: {{U32.is_le(a, b) == {TRUE}}}) -> {{Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == {TRUE}}}:
  FD.logic__subst(Bool, z => {{z == {TRUE}}}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def leFS(+len: U32, {HA}) -> {{Nat.is_le({FS}n, U32.to_nat(len)) == {TRUE}}}: natle({FS}, len, ha)

def hFSof({CW}, {HA}) -> {{Nat.is_le(Nat.add(x, {FS}n), {P}) == {TRUE}}}:
  FD.nat__le_trans(Nat.add(x, {FS}n), Nat.add(x, U32.to_nat(len)), {P}, Order.add_left(x, {FS}n, U32.to_nat(len), leFS(len, ha)), hw)

# the offset words, read at off + k, k + 4 <= {FS}
def rdo({CW}, +k: Nat, +c: U32, +ec: {{U32.to_nat(c) == k : Nat}}, +hk: {{Nat.is_le(Nat.add(k, 4n), {FS}n) == {TRUE}}},
    +hFS: {{Nat.is_le(Nat.add(x, {FS}n), {P}) == {TRUE}}})
    -> {{B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}}:
  +hr = UR.roomw(x, {FS}n, k, {P}, hFS, hk)
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x),
    Equal.trans(Nat, U32.to_nat(U32.add(off, c)), Nat.add(U32.to_nat(c), x), Nat.add(k, x),
      UR.offx(d, off, c, x, eo, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}),
        FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, x), {P}) == {TRUE}}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec),
          FD.nat__lt_le_trans(Nat.add(k, x), Nat.add(Nat.add(k, x), 4n), {P}, VTX.ltp(Nat.add(k, x), 3n), hr))),
      Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(c), k, ec)),
    FD.nat__lt_trans(d, 28n, 31n, hd, {{==}}), pf, hr)

# the children's windows lie in the window
def xle({CW}, +c: U32, +hc: {{Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == {TRUE}}}) -> {{Nat.is_le(Nat.add(x, U32.to_nat(c)), {P}) == {TRUE}}}:
  FD.nat__le_trans(Nat.add(x, U32.to_nat(c)), Nat.add(x, U32.to_nat(len)), {P}, Order.add_left(x, U32.to_nat(c), U32.to_nat(len), hc), hw)
def eoc({CW}, +c: U32, +hc: {{Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == {TRUE}}})
    -> {{U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(2n+d, 30n, 31n, hd, {{==}}),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, {P}) == {TRUE}}}, Nat.add(x, U32.to_nat(c)), Nat.add(U32.to_nat(c), x), FD.nat__add_comm(x, U32.to_nat(c)), xle({CA}, c, hc)))
''')
    # child window facts from one offset check each
    for j in range(K):
        jj = j + 1 if j < K - 1 else K - 1
        cc = f'{{CC{jj}(t, x, len) == {TRUE}}}'
        if j < K - 1:
            hab = f'FD.logic__and_left(U32.is_le({O(j)}, {O(j + 1)}), U32.is_le({O(j + 1)}, len), hc)'
            hel = f'natle({O(j + 1)}, len, FD.logic__and_right(U32.is_le({O(j)}, {O(j + 1)}), U32.is_le({O(j + 1)}, len), hc))'
            hjl = f'FD.nat__le_trans(U32.to_nat({O(j)}), U32.to_nat({O(j + 1)}), U32.to_nat(len), natle({O(j)}, {O(j + 1)}, {hab}), {hel})'
        else:
            hab = f'FD.logic__and_right(U32.is_le({O(j - 1)}, {O(j)}), U32.is_le({O(j)}, len), hc)'
            hel = 'Order.reflexive(U32.to_nat(len))'
            hjl = f'natle({O(j)}, len, {hab})'
        w(f'def hwc{j}({CW}, +hc: {cc}) -> {{Nat.is_le(Nat.add({X(j)}, U32.to_nat({L(j)})), {P}) == {TRUE}}}:')
        w(f'  VRC.winb({O(j)}, {E(j)}, x, {P}, {hab}, xle({CA}, {E(j)}, {hel}))')
        w(f'def eoc{j}({CW}, +hc: {cc}) -> {{U32.to_nat({Fk(j)}) == {X(j)} : Nat}}: eoc({CA}, {O(j)}, {hjl})')
    w('')
    # ok lemmas
    OS = lambda i: ', '.join(O(q) for q in range(i + 1))  # noqa: E731
    OSK = OS(K - 1)
    CCP = lambda js: ''.join(f', +hc{q}: {{CC{q}(t, x, len) == {TRUE}}}' for q in js)  # noqa: E731
    CCA = lambda js: ''.join(f', hc{q}' for q in js)  # noqa: E731
    allcc = list(range(1, K))
    w(f'def okc{2 * K - 1}(+t: {TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +g: Bool)')
    w(f'    -> {{{Tn}_c{2 * K - 1}(g, BF(t, n), off, len, {OSK}) == (BF(t, n), g) : B.Buf & Bool}}:')
    w('  match g:\n    case True{}: {==}\n    case False{}: {==}')
    for j in reversed(range(K - 1)):
        i = K + j
        nx = j + 1
        rec = (f'okc{i + 1}(t, n, x, off, len, CE{nx}(t, x, off, len))' if i + 1 == 2 * K - 1
               else f'okc{i + 1}({CA}{CCA(allcc)}, CE{nx}(t, x, off, len))')
        jj = nx + 1 if nx < K - 1 else K - 1
        w(f'def okc{i}({CW}{CCP(allcc)}, +g: Bool)')
        w(f'    -> {{{Tn}_c{i}(g, BF(t, n), off, len, {OSK}) == (BF(t, n), Bool.and(g, {KC[i + 2]})) : B.Buf & Bool}}:')
        w('  match g:')
        w('    case True{}:')
        w(f'      %Equal.sym(B.Buf & Bool, T.{x.vars[nx]["p"]}_ok(BF(t, n), U32.add(off, {O(nx)}), U32.sub({E(nx)}, {O(nx)})), (BF(t, n), CE{nx}(t, x, off, len)),')
        w(f'          C{nx}.ok_evalw(d, t, n, {X(nx)}, {Fk(nx)}, {L(nx)}, eoc{nx}({CA}, hc{jj}), hd, hwc{nx}({CA}, hc{jj}), pf)) :')
        w(f'        {{{Tn}_v{i + 1}(off, len, {OSK}, _) == (BF(t, n), {KC[i + 2]}) : B.Buf & Bool}}')
        w(f'      {rec}')
        w('    case False{}: {==}')
    # okc{K-1}: the last offset check, then child 0
    i = K - 1
    pre = list(range(1, K - 1))
    rec0 = (f'okc{K}(t, n, x, off, len, CE0(t, x, off, len))' if K == 2 * K - 1
            else f'okc{K}({CA}{CCA(pre)}, eb, CE0(t, x, off, len))')
    w(f'def okc{i}({CW}{CCP(pre)}, +b: Bool, +eb: {{CC{K - 1}(t, x, len) == b : Bool}})')
    w(f'    -> {{{Tn}_c{i}(b, BF(t, n), off, len, {OSK}) == (BF(t, n), Bool.and(b, {KC[K + 1]})) : B.Buf & Bool}}:')
    w('  match b:')
    w('    case True{}:')
    w(f'      %Equal.sym(B.Buf & Bool, T.{x.vars[0]["p"]}_ok(BF(t, n), U32.add(off, {O(0)}), U32.sub({E(0)}, {O(0)})), (BF(t, n), CE0(t, x, off, len)),')
    hc0 = 'eb' if K == 2 else 'hc1'
    w(f'          C0.ok_evalw(d, t, n, {X(0)}, {Fk(0)}, {L(0)}, eoc0({CA}, {hc0}), hd, hwc0({CA}, {hc0}), pf)) :')
    w(f'        {{{Tn}_v{K}(off, len, {OSK}, _) == (BF(t, n), {KC[K + 1]}) : B.Buf & Bool}}')
    w(f'      {rec0}')
    w('    case False{}: {==}')
    # okc{i} for i = K-2 .. 1 (offset checks reading the next offset)
    for i in reversed(range(1, K - 1)):
        pre = list(range(1, i))
        nxt_pre = list(range(1, i + 1))
        call = (f'okc{i + 1}({CA}{CCA(nxt_pre)}, CC{i + 1}(t, x, len), {{==}})' if i + 1 == K - 1
                else f'okc{i + 1}({CA}, hFS{CCA(nxt_pre)}, CC{i + 1}(t, x, len), {{==}})')
        w(f'def okc{i}({CW}, +hFS: {{Nat.is_le(Nat.add(x, {FS}n), {P}) == {TRUE}}}{CCP(pre)}, +b: Bool, +eb: {{CC{i}(t, x, len) == b : Bool}})')
        w(f'    -> {{{Tn}_c{i}(b, BF(t, n), off, len, {OS(i)}) == (BF(t, n), Bool.and(b, {KC[i + 2]})) : B.Buf & Bool}}:')
        w('  match b:')
        w('    case True{}:')
        w(f'      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, {cv[i + 1]})), (BF(t, n), {O(i + 1)}), rdo({CA}, {cv[i + 1]}n, {cv[i + 1]}, {{==}}, {{==}}, hFS)) :')
        w(f'        {{{Tn}_v{i + 1}(off, len, {OS(i)}, _) == (BF(t, n), {KC[i + 2]}) : B.Buf & Bool}}')
        w(f'      {call.replace(", eb,", ", eb,")}'.replace(f'{CCA(nxt_pre)}', f'{CCA(pre)}, eb'))
        w('    case False{}: {==}')
    # okc0
    call1 = (f'okc1({CA}, CC1(t, x, len), {{==}})' if K - 1 == 1 else f'okc1({CA}, hFS, CC1(t, x, len), {{==}})')
    w(f'def okc0({CW}, +hFS: {{Nat.is_le(Nat.add(x, {FS}n), {P}) == {TRUE}}}, +b: Bool)')
    w(f'    -> {{{Tn}_c0(b, BF(t, n), off, len, {O(0)}) == (BF(t, n), Bool.and(b, {KC[2]})) : B.Buf & Bool}}:')
    w('  match b:')
    w('    case True{}:')
    w(f'      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, {cv[1]})), (BF(t, n), {O(1)}), rdo({CA}, {cv[1]}n, {cv[1]}, {{==}}, {{==}}, hFS)) :')
    w(f'        {{{Tn}_v1(off, len, {O(0)}, _) == (BF(t, n), {KC[2]}) : B.Buf & Bool}}')
    w(f'      {call1}')
    w('    case False{}: {==}')
    w(f'''def okA({CW}, +a: Bool, +ea: {{CA(len) == a : Bool}})
    -> {{{Tn}_ok_len(a, BF(t, n), off, len) == (BF(t, n), Bool.and(a, {KC[1]})) : B.Buf & Bool}}:
  match a:
    case True{{}}:
      +hFS = hFSof({CA}, ea)
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, {cv[0]})), (BF(t, n), {O(0)}), rdo({CA}, {cv[0]}n, {cv[0]}, {{==}}, {{==}}, hFS)) :
        {{{Tn}_v0(off, len, _) == (BF(t, n), {KC[1]}) : B.Buf & Bool}}
      okc0({CA}, hFS, CB(t, x))
    case False{{}}: {{==}}

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw({CW}) -> {{{Tn}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}}:
  okA({CA}, CA(len), {{==}})

# ---- what the checks give -----------------------------------------------------------------------
''')
    w(f'def kk0({TXO}, +h: {GOAL}) -> {{{KC[0]} == {TRUE}}}: h')
    for i in range(1, N_):
        w(f'def kk{i}({TXO}, +h: {GOAL}) -> {{{KC[i]} == {TRUE}}}: FD.logic__and_right({Q[i - 1]}, {KC[i]}, kk{i - 1}(t, x, off, len, h))')
    for i in range(N_):
        body = f'kk{i}(t, x, off, len, h)' if i == N_ - 1 else f'FD.logic__and_left({Q[i]}, {KC[i + 1]}, kk{i}(t, x, off, len, h))'
        w(f'def q{i}({TXO}, +h: {GOAL}) -> {{{Q[i]} == {TRUE}}}: {body}')
    hcc = lambda j: f'q{1 + j}(t, x, off, len, hchk)'  # noqa: E731
    cfor = lambda j: hcc(j + 1 if j < K - 1 else K - 1)  # noqa: E731
    # ---- the reader ----
    leaves, OBJ = read_plan(x)
    RHS = '(BF(t, n), OBJw(d, t, x, off, len))'
    TY = f'B.Buf & {Tn}'
    w(f'''
# ---- the reader ---------------------------------------------------------------------------------

# c + x <= 4 2^d for c <= {FS}.
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {{Nat.is_le(c, {FS}n) == {TRUE}}}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P}) == {TRUE}}}, {HA})
    -> {{Nat.is_le(Nat.add(c, x), {P}) == {TRUE}}}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), {P},
    Order.add_right(c, U32.to_nat(len), x, FD.nat__le_trans(c, {FS}n, U32.to_nat(len), hc, leFS(len, ha))),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, {P}) == {TRUE}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

# The byte offset off + c of header byte c <= {FS} is at c + x.
def eocf(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {{Nat.is_le(U32.to_nat(c), {FS}n) == {TRUE}}}, +eo: {{U32.to_nat(off) == x : Nat}},
    +hd: {{Nat.is_lt(d, 28n) == {TRUE}}}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P}) == {TRUE}}}, {HA})
    -> {{U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}), hcx(d, x, len, U32.to_nat(c), hc, hw, ha))

# Room for a field of s bytes at c + x, for c + s <= {FS}.
def roomc(+d: Nat, +x: Nat, +len: U32, +c: Nat, +s: Nat, +hc: {{Nat.is_le(Nat.add(c, s), {FS}n) == {TRUE}}}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P}) == {TRUE}}}, {HA})
    -> {{Nat.is_le(Nat.add(Nat.add(c, x), s), {P}) == {TRUE}}}:
  UR.roomf(x, U32.to_nat(len), c, s, {P}, hw, FD.nat__le_trans(Nat.add(c, s), {FS}n, U32.to_nat(len), hc, leFS(len, ha)))

def OBJw(+d: Nat, {TXO}) -> {Tn}: {OBJ}

# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw({CW}, +hchk: {GOAL})
    -> {{{Tn}_read(BF(t, n), off, len) == {RHS} : {TY}}}:
  +ha = q0(t, x, off, len, hchk)
  +hFS = hFSof({CA}, ha)
  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {{==}})''')

    def ecf(c):
        return f'eocf(d, x, off, len, {c}, {{==}}, eo, hd, hw, ha)'
    for ctx, call, val, kind, f in leaves:
        pat = ctx.replace('@', '_')
        if kind == 'off':
            w(f'  %Equal.sym(B.Buf & U32, {call}, (BF(t, n), {val}), rdo({CA}, {f["c"]}n, {f["c"]}, {{==}}, {{==}}, hFS)) :')
        elif kind == 'fix':
            ft, c = f['ft'], f['c']
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {call}, (BF(t, n), {val}),')
            w(f'      {VX.rdx_ref(ft)}(d, t, n, U32.add(off, {c}), {VX.posx(c)}, {ecf(c)}, hd30, pf, roomc(d, x, len, {c}n, {ft.size}n, {{==}}, hw, ha))) :')
        elif kind == 'words':
            c, z = f['c'], f['size']
            kw = VBY.kfit(31 + z)
            hs = (f'UW.hsx(d, U32.add(off, {c}), Nat.add(U32.to_nat({c}), x), {z}, {ecf(c)}, hd, '
                  f'roomc(d, x, len, U32.to_nat({c}), U32.to_nat({z}), {{==}}, hw, ha))')
            w(f'  %Equal.sym(B.Buf & O.Words, {call}, (BF(t, n), {val}),')
            w(f'      VBX.copy_into_at(d, t, n, U32.add(off, {c}), {z}, {f["dz"]}n, {kw}n, pf, hd31, {{==}}, {hs}, {{==}}, {{==}}, {{==}})) :')
        else:
            j = f['j']
            w(f'  %Equal.sym(B.Buf & {f["rep"]}, {call}, (BF(t, n), {val}),')
            w(f'      C{j}.readw(d, t, n, {X(j)}, {Fk(j)}, {L(j)}, eoc{j}({CA}, {cfor(j)}), hd, hwc{j}({CA}, {cfor(j)}), pf, q{K + 1 + j}(t, x, off, len, hchk))) :')
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    L_.extend(spec_part(x))
    L_.extend(inv_part(x))
    return '\n'.join(L_) + '\n'


def parts_of(x):
    """per field: (value, schema, part, bytes of its fixed field (FP piece))"""
    out = []
    for f in x.fields:
        if f['kind'] == 'var':
            j = f['j']
            out.append((f'C{j}.VALw(t, {x.X(j)}, {x.L(j)})', f['sch'], f'S.Variable{{{x.Y(j)}}}', f'I.limb({x.O(j)})', f))
        else:
            nd = x.node(f)
            ws = ', '.join(nd['words'])
            out.append((nd['val'], nd['sch'], f'S.Fixed{{F.limbs([{ws}])}}', f'F.limbs([{ws}])', f))
    return out


def spec_part(x):
    FS, H, K, m = x.FS, x.H, x.K, x.m
    O, L, X, Fk, E, Y = x.O, x.L, x.X, x.F, x.E, x.Y
    Q = ['CA(len)', 'CB(t, x)'] + [f'CC{j}(t, x, len)' for j in range(1, K)] + [f'CE{j}(t, x, off, len)' for j in range(K)]
    hcc = lambda j: f'q{1 + j}(t, x, off, len, hchk)'  # noqa: E731
    cfor = lambda j: hcc(j + 1 if j < K - 1 else K - 1)  # noqa: E731
    ps = parts_of(x)

    # the items and the parts from field i on, as definitions (the checker then compares them by name)
    def items(i):
        return f'ITS{i}(t, x, len)'

    def items0(i):
        return 'S.EmptyItems{}' if i == m else f'S.Items{{{ps[i][0]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{{ps[i][1]}, {chain(i + 1)}}}'

    def plist(i):
        return f'PST{i}(t, x, len)'

    def plist0(i):
        return '[]' if i == m else f'Con{{{ps[i][2]}, {plist(i + 1)}}}'

    # the parts from field i on, one lemma per field (cp<i>, below)
    def cat(i):
        return '{==}' if i == m else f'cp{i}({CA}, hchk)'

    def cat_step(i):
        f = ps[i][4]
        if f['kind'] == 'var':
            j = f['j']
            return (f'VS.cat_var(Codec.parts({ps[i][0]}, {ps[i][1]}), {Y(j)}, Codec.parts({items(i + 1)}, {chain(i + 1)}), {plist(i + 1)}, '
                    f'C{j}.specw(d, t, n, {X(j)}, {Fk(j)}, {L(j)}, eoc{j}({CA}, {cfor(j)}), hd, hwc{j}({CA}, {cfor(j)}), pf, q{K + 1 + j}(t, x, off, len, hchk)), {cat(i + 1)})')
        nd = x.node(f)
        return (f'F.cat_fixed(Codec.parts({ps[i][0]}, {ps[i][1]}), F.limbs([{", ".join(nd["words"])}]), '
                f'Codec.parts({items(i + 1)}, {chain(i + 1)}), {plist(i + 1)}, {nd["proof"]}, {cat(i + 1)})')
    # offsets along the parts (in |Y_j|), and the fixed section piecewise
    a = [f'U32.to_nat({L(j)})' for j in range(K)]
    ly = [ln(Y(j)) for j in range(K)]
    offe = [f'{FS}n']
    for j in range(K):
        offe.append(nadd(offe[-1], ly[j]))

    def cur(i):
        return offe[sum(1 for p in ps[:i] if p[4]['kind'] == 'var')]

    def FP(i):
        return '[]' if i == m else app(ps[i][3], FP(i + 1))

    def hf(i):
        if i == m:
            return '{==}'
        f = ps[i][4]
        if f['kind'] == 'var':
            j = f['j']
            return f'VWC.fp_var({Y(j)}, {plist(i + 1)}, {cur(i)}, {O(j)}, {FP(i + 1)}, ew{j}, {hf(i + 1)})'
        return f'VWC.fp_fix({ps[i][3]}, {plist(i + 1)}, {cur(i)}, {FP(i + 1)}, {hf(i + 1)})'

    def hv(i):
        if i == m:
            return '{==}'
        f = ps[i][4]
        if f['kind'] == 'var':
            j = f['j']
            return f'VWC.bv_var({Y(j)}, {plist(i + 1)}, UW.domWX(t, {X(j)}, {a[j]}), {hv(i + 1)})'
        nd = x.node(f)
        return f'VWC.bv_fix({ps[i][3]}, {plist(i + 1)}, F.domain_limbs([{", ".join(nd["words"])}]), {hv(i + 1)})'
    PS = plist(0)
    FP0 = FP(0)

    def pay(j):
        return Y(j) if j == K - 1 else app(Y(j), pay(j + 1))
    PAY = pay(0)

    def payn(j):
        return app(Y(j), '[]') if j == K - 1 else app(Y(j), payn(j + 1))

    def hp(j):
        # payloads(PS) (with its trailing []) == PAY
        if j == K - 1:
            return f'VS.app_nil({Y(j)})'
        return f'Equal.cong(+List<U32>, +List<U32>, z => {app(Y(j), "z")}, {payn(j + 1)}, {pay(j + 1)}, {hp(j + 1)})'

    def pla(j):
        return a[j] if j == K - 1 else nadd(a[j], pla(j + 1))

    def lp(j):
        if j == K - 1:
            return f'la{j}'
        return trans('Nat', [ln(pay(j)), nadd(ly[j], ln(pay(j + 1))), nadd(a[j], ln(pay(j + 1))), pla(j)],
                     [f'VS.len_app({Y(j)}, {pay(j + 1)})',
                      f'Equal.cong(Nat, Nat, z => Nat.add(z, {ln(pay(j + 1))}), {ly[j]}, {a[j]}, la{j})',
                      f'Equal.cong(Nat, Nat, z => Nat.add({a[j]}, z), {ln(pay(j + 1))}, {pla(j + 1)}, {lp(j + 1)})'])
    # to_nat(len) == FS + (a0 + (a1 + ..)) from the offsets in a_j
    offa = [f'{FS}n']
    for j in range(K - 1):
        offa.append(nadd(offa[-1], a[j]))
    left, right, eassoc = lassoc(f'{FS}n', a)
    ITEMS, CHAIN = items(0), chain(0)
    defs = []
    for i in range(m, -1, -1):
        defs.append(f'def ITS{i}(+t: {TR}, +x: Nat, +len: U32) -> S.Value: {items0(i)}')
        defs.append(f'def PST{i}(+t: {TR}, +x: Nat, +len: U32) -> +List<S.Part>: {plist0(i)}')
    out = [f'''
# ---- the spec side ------------------------------------------------------------------------------

''' + '\n'.join(defs) + f'''

def VALw(+t: {TR}, +x: Nat, +len: U32) -> S.Value: S.Sequence{{{ITEMS}}}
''']
    lines = []
    lw = lines.append
    for i in range(m - 1, -1, -1):
        lw(f'def cp{i}({CW}, +hchk: {GOAL}) -> {{Codec.parts({items(i)}, {chain(i)}) == Some{{{plist(i)}}} : {MP}}}:')
        lw(f'  {cat_step(i)}')
    lw('')
    lw(f'def specw({CW}, +hchk: {GOAL})')
    lw(f'    -> {{Codec.parts(VALw(t, x, len), Spec.{x.n}()) == {RHSV} : {MP}}}:')
    for j in range(K):
        lw(f'  +hw{j} = hwc{j}({CA}, {cfor(j)})')
        lw(f'  +la{j} = UW.lenWX(d, t, {X(j)}, {a[j]}, pf, hw{j})')
    lw(f'  +eO0 = Equal.cong(U32, Nat, z => U32.to_nat(z), {O(0)}, {FS}, FD.u32alg__eq_of({O(0)}, {FS}, q1(t, x, off, len, hchk)))')
    for j in range(1, K):
        le = f'FD.logic__and_left(U32.is_le({O(j - 1)}, {O(j)}), U32.is_le({O(j)}, len), {hcc(j)})'
        lw(f'  +eOn{j} = Equal.sym(Nat, Nat.add(U32.to_nat({O(j - 1)}), {a[j - 1]}), U32.to_nat({O(j)}), VM.sub_eq({O(j)}, {O(j - 1)}, {le}))')
    lw(f'  +eLn = Equal.sym(Nat, Nat.add(U32.to_nat({O(K - 1)}), {a[K - 1]}), U32.to_nat(len), VM.sub_eq(len, {O(K - 1)}, '
       f'FD.logic__and_right(U32.is_le({O(K - 2)}, {O(K - 1)}), U32.is_le({O(K - 1)}, len), {hcc(K - 1)})))')
    # ew_j: to_nat(O_j) == offe[j]; ea_j: to_nat(O_j) == offa[j]
    lw('  +ew0 = eO0')
    lw('  +ea0 = eO0')
    for j in range(1, K):
        lw(f'  +ew{j} = ' + trans('Nat', [f'U32.to_nat({O(j)})', nadd(f'U32.to_nat({O(j - 1)})', a[j - 1]), nadd(offe[j - 1], a[j - 1]), offe[j]],
                                  [f'eOn{j}', f'Equal.cong(Nat, Nat, z => Nat.add(z, {a[j - 1]}), U32.to_nat({O(j - 1)}), {offe[j - 1]}, ew{j - 1})',
                                   f'Equal.cong(Nat, Nat, z => Nat.add({offe[j - 1]}, z), {a[j - 1]}, {ly[j - 1]}, Equal.sym(Nat, {ly[j - 1]}, {a[j - 1]}, la{j - 1}))']))
        lw(f'  +ea{j} = ' + trans('Nat', [f'U32.to_nat({O(j)})', nadd(f'U32.to_nat({O(j - 1)})', a[j - 1]), offa[j]],
                                  [f'eOn{j}', f'Equal.cong(Nat, Nat, z => Nat.add(z, {a[j - 1]}), U32.to_nat({O(j - 1)}), {offa[j - 1]}, ea{j - 1})']))
    elen = trans('Nat', ['U32.to_nat(len)', nadd(f'U32.to_nat({O(K - 1)})', a[K - 1]), left, right],
                 ['eLn', f'Equal.cong(Nat, Nat, z => Nat.add(z, {a[K - 1]}), U32.to_nat({O(K - 1)}), {offa[K - 1]}, ea{K - 1})', eassoc])
    lw(f'  +elen = {elen}')
    PLA = pla(0)
    lw(f'  +hwR = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), {P}) == {TRUE}}}, U32.to_nat(len), {right}, elen, hw)')
    lw(f'  +lenpay = {lp(0)}')
    lw(f'  +fit = FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, U32.to_nat(len), Nat.add({FS}n, {ln(PAY)}),')
    lw(f'    Equal.sym(Nat, Nat.add({FS}n, {ln(PAY)}), U32.to_nat(len), Equal.trans(Nat, Nat.add({FS}n, {ln(PAY)}), {right}, U32.to_nat(len),')
    lw(f'      Equal.cong(Nat, Nat, z => Nat.add({FS}n, z), {ln(PAY)}, {PLA}, lenpay), Equal.sym(Nat, U32.to_nat(len), {right}, elen))),')
    lw(f'    VFT.fits4(2n+d, U32.to_nat(len), FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P}, Order.left_below_sum(x, U32.to_nat(len)), hw), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})))')
    # the window's bytes: the fixed section's words, then the children's windows
    RHSW = app(FP0, PAY)

    def tailY(j, last):
        # append(Y0, append(Y1, .. append(Y_(j-1), last)))
        s = last
        for q in reversed(range(j)):
            s = app(Y(q), s)
        return s
    RWS = f'F.limbs(UR.RWS({H}n, t, x))'
    lw(f'  +win = FD.logic__subst(Nat, z => {{UW.WX(t, x, z) == {RHSW} : +List<U32>}}, {right}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {right}, elen),')
    # proof of WX(t, x, FS + PLA) == RHSW
    wsteps = []
    wsteps.append(f'%Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad({H}n), {PLA})), {app(RWS, f"UW.WX(t, Nat.add(A.quad({H}n), x), {PLA})")}, UW.headWX(d, t, x, {H}n, {PLA}, pf, hwR)) :\n'
                  f'      {{_ == {RHSW} : +List<U32>}}')
    wsteps.append(f'%Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat({O(0)}), {FS}n, eO0) :\n'
                  f'      {{{app(RWS, f"UW.WX(t, _, {PLA})")} == {RHSW} : +List<U32>}}')
    for j in range(K - 1):
        restA = pla(j + 1)
        cur_ = f'UW.WX(t, {X(j)}, {nadd(a[j], restA)})'
        split = app(f'UW.WX(t, {X(j)}, {a[j]})', f'UW.WX(t, Nat.add({a[j]}, {X(j)}), {restA})')
        wsteps.append(f'%Equal.sym(+List<U32>, {cur_}, {split}, VRC.splitWX(t, {X(j)}, {a[j]}, {restA})) :\n'
                      f'      {{{app(RWS, tailY(j, "_"))} == {RHSW} : +List<U32>}}')
        wsteps.append(f'%VRC.pnext(U32.to_nat({O(j)}), U32.to_nat({O(j + 1)}), {a[j]}, x, eOn{j + 1}) :\n'
                      f'      {{{app(RWS, tailY(j + 1, f"UW.WX(t, _, {restA})"))} == {RHSW} : +List<U32>}}')
    out_lines = lines + ['    ' + s.replace('\n', '\n  ') for s in []]
    lines.append('    ' + 'wx_go(' + ')')  # placeholder removed below
    lines.pop()
    # wx is proved in its own def (the % rewrites need a goal)
    out.append('\n'.join([]))
    wx = [f'def wxw({CW}, +hchk: {GOAL}, +hwR: {{Nat.is_le(Nat.add(x, {right}), {P}) == {TRUE}}}, +eO0: {{U32.to_nat({O(0)}) == {FS}n : Nat}}'
          + ''.join(f', +eOn{j}: {{U32.to_nat({O(j)}) == {nadd(f"U32.to_nat({O(j - 1)})", a[j - 1])} : Nat}}' for j in range(1, K)) + ')',
          f'    -> {{UW.WX(t, x, {right}) == {RHSW} : +List<U32>}}:']
    for s in wsteps:
        wx.append('  ' + s.replace('\n      ', '\n    '))
    wx.append('  {==}')
    out.append('\n'.join(wx) + '\n')
    lines.append(f'    wxw({CA}, hchk, hwR, eO0{"".join(f", eOn{j}" for j in range(1, K))}))')
    lw(f'  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PS}}},')
    lw(f'      {cat(0)}) :')
    lw(f'    {{Codec.aggregate(_, None{{}}) == {RHSV} : {MP}}}')
    lw(f'  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding({PS}), Some{{{RHSW}}},')
    lw(f'      VV.enc_gen({PS}, {FS}n, {FP0}, {PAY}, {{==}}, {hf(0)}, {hp(0)}, {hv(0)}, fit)) :')
    lw(f'    {{Codec.one(_, None{{}}) == {RHSV} : {MP}}}')
    lw(f'  %win : {{Codec.one(Some{{_}}, None{{}}) == {RHSV} : {MP}}}')
    lw('  {==}')
    out.append('\n'.join(lines) + '\n')
    return out


def inv_part(x):
    FS, K, m = x.FS, x.K, x.m
    O, L, X, Fk, E, Y = x.O, x.L, x.X, x.F, x.E, x.Y
    Q = ['CA(len)', 'CB(t, x)'] + [f'CC{j}(t, x, len)' for j in range(1, K)] + [f'CE{j}(t, x, off, len)' for j in range(K)]
    N_ = 2 * K + 1
    KC = [f'KC{i}(t, x, off, len)' for i in range(N_)]
    ps = parts_of(x)
    fs = x.fields
    sch = [p[1] for p in ps]

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{{sch[i]}, {chain(i + 1)}}}'

    def pterm(i):
        f = fs[i]
        return f'S.Variable{{y{f["j"]}}}' if f['kind'] == 'var' else f'S.Fixed{{xs{i}}}'

    def acct(i):
        s = ''
        for q in range(i):
            f = fs[q]
            if f['kind'] == 'var':
                j = f['j']
                s += f', +hv{j}: S.Value, +y{j}: +List<U32>, +eh{j}: {{Codec.parts(hv{j}, {sch[q]}) == Some{{[S.Variable{{y{j}}}]}} : {MP}}}'
            else:
                s += f', +xs{q}: +List<U32>, +hl{q}: {{List.length(&2, U32, xs{q}) == {f["size"]}n : Nat}}'
        return s

    def acca(i):
        s = ''
        for q in range(i):
            f = fs[q]
            s += f', hv{f["j"]}, y{f["j"]}, eh{f["j"]}' if f['kind'] == 'var' else f', xs{q}, hl{q}'
        return s

    def cc(i, tail):
        out = tail
        for q in reversed(range(i)):
            out = f'Codec.concatenate(Some{{[{pterm(q)}]}}, {out})'
        return out

    def E_(i, tail):
        return f'{{Codec.aggregate({cc(i, tail)}, None{{}}) == {RHSV} : {MP}}}'

    def ABS(ev):
        return f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WW}}}], {ev}))'

    def width(i):
        return 'None{}' if fs[i]['kind'] == 'var' else f'Some{{{fs[i]["size"]}n}}'

    def sgl(i):
        return fs[i]['sgl'] if fs[i]['kind'] == 'var' else f'DS.facts(h, {sch[i]}, {{==}})'
    PSX = '[' + ', '.join(pterm(i) for i in range(m)) + ']'

    def psx(i):
        return '[' + ', '.join(pterm(q) for q in range(i, m)) + ']'
    BYTES = app(f'Layout.fixed_parts({PSX}, Layout.fixed_size({PSX}))', f'Layout.payloads({PSX})')
    yl = [ln(f'y{j}') for j in range(K)]
    offy = [f'{FS}n']
    for j in range(K - 1):
        offy.append(nadd(offy[-1], yl[j]))

    def rsum(k):
        return yl[K - 1] if k == K - 1 else nadd(yl[k], rsum(k + 1))
    SY = rsum(0)
    A_ = f'Layout.fixed_parts({PSX}, {FS}n)'

    def payx(j):
        return app(f'y{j}', '[]') if j == K - 1 else app(f'y{j}', payx(j + 1))
    PAYX = payx(0)
    L_ = []
    w = L_.append
    w(f'''
# ---- the inversion: every value of the window's bytes passes the checks --------------------------

def leU(+a: U32, +b: U32, +x0: Nat, +y: Nat, +ha: {{U32.to_nat(a) == x0 : Nat}}, +hb: {{U32.to_nat(b) == y : Nat}}, +h: {{Nat.is_le(x0, y) == {TRUE}}})
    -> {{U32.is_le(a, b) == {TRUE}}}:
  VMR.u32le(a, b, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(b)) == {TRUE}}}, x0, U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), x0, ha),
    FD.logic__subst(Nat, z => {{Nat.is_le(x0, z) == {TRUE}}}, y, U32.to_nat(b), Equal.sym(Nat, U32.to_nat(b), y, hb), h)))

# The offset word at k: its limbs are the digits the layout puts there.
def offw({CW}, +k: Nat, +L2: Nat, +v: Nat, +el: {{U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat}}, +hv: {{Nat.is_le(v, U32.to_nat(len)) == {TRUE}}},
    +eb: {{VS.bt(4n, VS.bdr(k, {WW})) == N.digits(4n, v) : +List<U32>}})
    -> {{U32.to_nat(UR.RWN(t, Nat.add(k, x))) == v : Nat}}:
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), {P}) == {TRUE}}}, U32.to_nat(len), Nat.add(k, 4n+L2), el, hw)
  +le0 = Order.add_left(k, Nat.add(x, 4n), Nat.add(x, 4n+L2), Order.add_left(x, 4n, 4n+L2, Order.below_sum(4n, L2)))
  +le1 = FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add(k, Nat.add(x, 4n+L2))) == {TRUE}}}, Nat.add(k, Nat.add(x, 4n)), Nat.add(Nat.add(k, x), 4n),
    Equal.sym(Nat, Nat.add(Nat.add(k, x), 4n), Nat.add(k, Nat.add(x, 4n)), FD.nat__add_assoc(k, x, 4n)), le0)
  +le2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(Nat.add(k, x), 4n), z) == {TRUE}}}, Nat.add(k, Nat.add(x, 4n+L2)), Nat.add(x, Nat.add(k, 4n+L2)),
    Equal.sym(Nat, Nat.add(x, Nat.add(k, 4n+L2)), Nat.add(k, Nat.add(x, 4n+L2)), FD.lru_nat_algebra__add_swap(x, k, 4n+L2)), le1)
  +hk = FD.nat__le_trans(Nat.add(Nat.add(k, x), 4n), Nat.add(x, Nat.add(k, 4n+L2)), {P}, le2, hl)
  +wb = FD.logic__subst(Nat, z => {{VS.bt(4n, VS.bdr(k, UW.WX(t, x, z))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}}, Nat.add(k, 4n+L2), U32.to_nat(len),
    Equal.sym(Nat, U32.to_nat(len), Nat.add(k, 4n+L2), el), VRC.wbytes(d, t, x, k, L2, pf, hk))
  VG.digits_word(UR.RWN(t, Nat.add(k, x)), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P}, Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, Nat.add(k, x))]), VS.bt(4n, VS.bdr(k, {WW})), N.digits(4n, v),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, {WW})), F.limbs([UR.RWN(t, Nat.add(k, x))]), wb), eb))
''')
    # contra: the facts of the spec relation give the checks
    C = []
    cw = C.append
    cw(f'def contra({CW}{acct(m)},\n    +eW: {{{BYTES} == {WW} : +List<U32>}}) -> {GOAL}:')

    # fixed size
    def fsz(i):
        if i == m:
            return '{==}'
        rest = sum(fs[q]['size'] for q in range(i + 1, m))
        f = fs[i]
        if f['kind'] == 'var':
            return f'VWC.fs_var(y{f["j"]}, {psx(i + 1)}, {rest}n, {fsz(i + 1)})'
        return f'VWC.fs_fix(xs{i}, {psx(i + 1)}, {f["size"]}n, {rest}n, hl{i}, {fsz(i + 1)})'
    cw(f'  +fsz = {fsz(0)}')
    cw(f'  +eWA = Equal.trans(+List<U32>, {WW}, {BYTES}, {app(A_, f"Layout.payloads({PSX})")}, Equal.sym(+List<U32>, {BYTES}, {WW}, eW),')
    cw(f'    Equal.cong(Nat, +List<U32>, z => {app(f"Layout.fixed_parts({PSX}, z)", f"Layout.payloads({PSX})")}, Layout.fixed_size({PSX}), {FS}n, fsz))')
    cw(f'  +lenA = Equal.trans(Nat, {ln(A_)}, Layout.fixed_size({PSX}), {FS}n, VWC.fp_len({PSX}, {FS}n), fsz)')
    # |PAYX| == SY
    def lpy(j):
        if j == K - 1:
            return f'Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), {app(f"y{j}", "[]")}, y{j}, VS.app_nil(y{j}))'
        return trans('Nat', [ln(payx(j)), nadd(yl[j], ln(payx(j + 1))), rsum(j)],
                     [f'VS.len_app(y{j}, {payx(j + 1)})', f'Equal.cong(Nat, Nat, z => Nat.add({yl[j]}, z), {ln(payx(j + 1))}, {rsum(j + 1)}, {lpy(j + 1)})'])
    cw(f'  +lpy = {lpy(0)}')
    cw(f'  +eLen = ' + trans('Nat', ['U32.to_nat(len)', ln(WW), ln(app(A_, PAYX)), nadd(ln(A_), ln(PAYX)), nadd(f'{FS}n', ln(PAYX)), nadd(f'{FS}n', SY)],
                             [f'Equal.sym(Nat, {ln(WW)}, U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw))',
                              f'Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), {WW}, {app(A_, PAYX)}, eWA)',
                              f'VS.len_app({A_}, {PAYX})',
                              f'Equal.cong(Nat, Nat, z => Nat.add(z, {ln(PAYX)}), {ln(A_)}, {FS}n, lenA)',
                              f'Equal.cong(Nat, Nat, z => Nat.add({FS}n, z), {ln(PAYX)}, {SY}, lpy)']))
    # offsets' bytes in the fixed section
    for j, f in enumerate(x.vars):
        cvj = f['c']
        terms, proofs = [f'VS.bdr({cvj}n, {A_})'], []
        rem = cvj
        off = f'{FS}n'
        i = 0
        while fs[i] is not f:
            g = fs[i]
            if g['kind'] == 'var':
                s, piece, hl = 4, f'N.digits(4n, {off})', '{==}'
                nxt_off = nadd(off, f'List.length(&2, U32, y{g["j"]})')
            else:
                s, piece, hl = g['size'], f'xs{i}', f'hl{i}'
                nxt_off = off
            rem -= s
            R = f'Layout.fixed_parts({psx(i + 1)}, {nxt_off})'
            proofs.append(f'VWC.bdr_skip({piece}, {s}n, {rem}n, {R}, {hl})')
            terms.append(f'VS.bdr({rem}n, {R})')
            off = nxt_off
            i += 1
        assert rem == 0 and off == offy[j], (rem, off, offy[j])
        chain_ = trans('+List<U32>', terms, proofs) if proofs else '{==}'
        cw(f'  +bof{j} = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), VS.bdr({cvj}n, {A_}), VS.bdr(0n, Layout.fixed_parts({psx(i)}, {offy[j]})), {chain_})')
        hroom = f'FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({cvj}n, 4n), z) == {TRUE}}}, {FS}n, {ln(A_)}, Equal.sym(Nat, {ln(A_)}, {FS}n, lenA), {{==}})'
        cw(f'  +bw{j} = ' + trans('+List<U32>', [f'VS.bt(4n, VS.bdr({cvj}n, {WW}))', f'VS.bt(4n, VS.bdr({cvj}n, {app(A_, PAYX)}))',
                                                  f'VS.bt(4n, VS.bdr({cvj}n, {A_}))', f'N.digits(4n, {offy[j]})'],
                                  [f'Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr({cvj}n, z)), {WW}, {app(A_, PAYX)}, eWA)',
                                   f'VN.btbdr_app({cvj}n, {A_}, {PAYX}, {hroom})', f'bof{j}']))
    # offy[j] <= FS + SY, and offy[K-1] + |y_(K-1)| == FS + SY
    for j in range(K):
        if j == 0:
            lej = f'Order.below_sum({FS}n, {SY})'
        else:
            lft, rgt, ea = lassoc(f'{FS}n', yl[:j])

            def pre_le(k, jj):
                # rsum over yl[k:jj] <= rsum(k), right-assoc
                if k == jj - 1:
                    return f'FD.nat__le_add_right({yl[k]}, {rsum(k + 1)})' if k < K - 1 else f'Order.reflexive({yl[k]})'
                pk = nadd(yl[k], pr(k + 1, jj))
                return f'Order.add_left({yl[k]}, {pr(k + 1, jj)}, {rsum(k + 1)}, {pre_le(k + 1, jj)})'

            def pr(k, jj):
                return yl[k] if k == jj - 1 else nadd(yl[k], pr(k + 1, jj))
            le_r = f'Order.add_left({FS}n, {pr(0, j)}, {SY}, {pre_le(0, j)})'
            lej = f'FD.logic__subst(Nat, z => {{Nat.is_le(z, {nadd(f"{FS}n", SY)}) == {TRUE}}}, {rgt}, {lft}, Equal.sym(Nat, {lft}, {rgt}, {ea}), {le_r})'
        cw(f'  +hvl{j} = FD.logic__subst(Nat, z => {{Nat.is_le({offy[j]}, z) == {TRUE}}}, {nadd(f"{FS}n", SY)}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {nadd(f"{FS}n", SY)}, eLen), {lej})')
    lft, rgt, ea = lassoc(f'{FS}n', yl)
    cw(f'  +eLenL = Equal.trans(Nat, U32.to_nat(len), {rgt}, {lft}, eLen, Equal.sym(Nat, {lft}, {rgt}, {ea}))')
    # the offsets' values
    for j, f in enumerate(x.vars):
        cvj = f['c']
        cw(f'  +eO{j} = offw({CA}, {cvj}n, Nat.add({FS - cvj - 4}n, {SY}), {offy[j]}, eLen, hvl{j}, bw{j})')
    # the checks
    cw(f'  +hQ0 = VMR.u32le({FS}, len, FD.logic__subst(Nat, z => {{Nat.is_le({FS}n, z) == {TRUE}}}, {nadd(f"{FS}n", SY)}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {nadd(f"{FS}n", SY)}, eLen), Order.below_sum({FS}n, {SY})))')
    cw(f'  +hQ1 = FD.u32alg__eq_true({O(0)}, {FS}, FD.u32__injective({O(0)}, {FS}, eO0))')
    for j in range(1, K):
        cw(f'  +hQ{1 + j} = FD.logic__and_intro(U32.is_le({O(j - 1)}, {O(j)}), U32.is_le({O(j)}, len),')
        cw(f'    leU({O(j - 1)}, {O(j)}, {offy[j - 1]}, {offy[j]}, eO{j - 1}, eO{j}, Order.below_sum({offy[j - 1]}, {yl[j - 1]})),')
        cw(f'    leU({O(j)}, len, {offy[j]}, U32.to_nat(len), eO{j}, {{==}}, hvl{j}))')
    # the children's windows
    cw(f'  +hR0 = Equal.trans(+List<U32>, VS.bdr({FS}n, {WW}), VS.bdr({FS}n, {app(A_, PAYX)}), {PAYX},')
    cw(f'    Equal.cong(+List<U32>, +List<U32>, z => VS.bdr({FS}n, z), {WW}, {app(A_, PAYX)}, eWA),')
    cw(f'    FD.logic__subst(Nat, z => {{VS.bdr(z, {app(A_, PAYX)}) == {PAYX} : +List<U32>}}, {ln(A_)}, {FS}n, lenA, VS.bdr_app({A_}, {PAYX})))')
    for j in range(1, K):
        cw(f'  +hR{j} = ' + trans('+List<U32>', [f'VS.bdr({offy[j]}, {WW})', f'VS.bdr({yl[j - 1]}, VS.bdr({offy[j - 1]}, {WW}))',
                                                  f'VS.bdr({yl[j - 1]}, {payx(j - 1)})', payx(j)],
                                  [f'VN.bdr_add({offy[j - 1]}, {yl[j - 1]}, {WW})',
                                   f'Equal.cong(+List<U32>, +List<U32>, z => VS.bdr({yl[j - 1]}, z), VS.bdr({offy[j - 1]}, {WW}), {payx(j - 1)}, hR{j - 1})',
                                   f'VS.bdr_app(y{j - 1}, {payx(j)})']))
    for j in range(K):
        eE = f'eO{j + 1}' if j < K - 1 else 'eLenL'
        Ej = x.E(j)
        cw(f'  +eL{j} = VMR.subL({Ej}, {O(j)}, {offy[j]}, {yl[j]}, eO{j}, {eE})')
        nxtle = f'hvl{j + 1}' if j < K - 1 else f'FD.logic__subst(Nat, z => {{Nat.is_le({nadd(offy[j], yl[j])}, z) == {TRUE}}}, {nadd(offy[j], yl[j])}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {nadd(offy[j], yl[j])}, eLenL), Order.reflexive({nadd(offy[j], yl[j])}))'
        rest = payx(j + 1) if j < K - 1 else '[]'
        cw(f'  +ey{j} = ' + trans('+List<U32>', [Y(j), f'UW.WX(t, Nat.add({offy[j]}, x), {yl[j]})', f'VS.bt({yl[j]}, VS.bdr({offy[j]}, {WW}))',
                                                  f'VS.bt({yl[j]}, {payx(j)})', f'VS.bt({yl[j]}, y{j})', f'y{j}'],
                                  [trans('+List<U32>', [Y(j), f'UW.WX(t, Nat.add({offy[j]}, x), U32.to_nat({L(j)}))', f'UW.WX(t, Nat.add({offy[j]}, x), {yl[j]})'],
                                         [f'Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(z, x), U32.to_nat({L(j)})), U32.to_nat({O(j)}), {offy[j]}, eO{j})',
                                          f'Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add({offy[j]}, x), z), U32.to_nat({L(j)}), {yl[j]}, eL{j})']),
                                   f'Equal.sym(+List<U32>, VS.bt({yl[j]}, VS.bdr({offy[j]}, {WW})), UW.WX(t, Nat.add({offy[j]}, x), {yl[j]}), UW.subWX(t, x, {offy[j]}, {yl[j]}, U32.to_nat(len), {nxtle}))',
                                   f'Equal.cong(+List<U32>, +List<U32>, z => VS.bt({yl[j]}, z), VS.bdr({offy[j]}, {WW}), {payx(j)}, hR{j})',
                                   f'VN.bt_app({yl[j]}, y{j}, {rest}, FD.nat__le_refl({yl[j]}))',
                                   f'UW.bt_self(y{j})']))
    for j in range(K):
        jj = j + 1 if j < K - 1 else K - 1
        sj = sch[[q for q in range(m) if fs[q] is x.vars[j]][0]]
        cw(f'  +hQ{K + 1 + j} = C{j}.invw(d, t, n, {X(j)}, {Fk(j)}, {L(j)}, eoc{j}({CA}, hQ{1 + jj}), hd, hwc{j}({CA}, hQ{1 + jj}), pf, hv{j},')
        cw(f'    FD.logic__subst(+List<U32>, z => {{Codec.parts(hv{j}, {sj}) == Some{{[S.Variable{{z}}]}} : {MP}}}, y{j}, {Y(j)}, Equal.sym(+List<U32>, {Y(j)}, y{j}, ey{j}), eh{j}))')

    def conj(i):
        if i == N_ - 1:
            return f'hQ{i}'
        return f'FD.logic__and_intro({Q[i]}, {KC[i + 1]}, hQ{i}, {conj(i + 1)})'
    cw(f'  {conj(0)}')
    w('\n'.join(C))
    w(f'''
def fin({CW}{acct(m)}, +b: Bool,
    +e: {{Codec.one(SP.optional(b, {BYTES}), None{{}}) == {RHSV} : {MP}}}) -> {GOAL}:
  match b:
    case False{{}}: {ABS("e")}
    case True{{}}: contra({CA}{acca(m)}, VVL.vinj({BYTES}, {WW}, e))
''')
    CONS = ['S.BooleanValue{+b0}', 'S.UnsignedValue{+u0}', 'S.BytesValue{+xs0}', 'S.BitsValue{+bs0}', 'S.Sequence{+it0}',
            'S.Items{+hd0, +tl0}', 'S.EmptyItems{}', 'S.Selected{+sel0, +sv0}', 'S.NullValue{}']
    for i in reversed(range(m + 1)):
        cases = []
        for c in CONS:
            if i < m and c.startswith('S.Items'):
                cases.append(f'    case S.Items{{+h, +r}}: fm{i}({CA}{acca(i)}, h, Codec.parts(h, {sch[i]}), {sgl(i)}, {{==}}, r, e)')
            elif i == m and c == 'S.EmptyItems{}':
                cases.append(f'    case S.EmptyItems{{}}: fin({CA}{acca(m)}, Bool.and(Layout.bytes_valid({PSX}), N.fits(4n, Nat.add(Layout.fixed_size({PSX}), List.length(&2, U32, Layout.payloads({PSX}))))), e)')
            else:
                cases.append(f'    case {c}: {ABS("e")}')
        ST = f'''
def st{i}({CW}{acct(i)}, +items: S.Value,
    +e: {E_(i, f'Codec.parts(items, {chain(i)})')}) -> {GOAL}:
  match items:
''' + '\n'.join(cases) + '\n'
        if i == m:
            w(ST)
            continue
        f = fs[i]
        tail = f'Codec.concatenate(Some{{ps}}, Codec.parts(r, {chain(i + 1)}))'
        if f['kind'] == 'var':
            j = f['j']
            cfix = f'Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))'
            cvar = f'st{i + 1}({CA}{acca(i)}, h, ys, em, r, e)'
        else:
            sz = f['size']
            cfix = f'st{i + 1}({CA}{acca(i)}, xs, Equal.sym(Nat, {sz}n, List.length(&2, U32, xs), FD.logic__some_inj(Nat, {sz}n, List.length(&2, U32, xs), hf)), r, e)'
            cvar = f'Empty.absurd({GOAL}, FD.logic__none_some(Nat, {sz}n, Equal.sym(Maybe<&2, Nat>, Some{{{sz}n}}, None{{}}, hf)))'
        w(f'''
def fp{i}({CW}{acct(i)}, +h: S.Value, +ps: +List<S.Part>, hf: DF.single({width(i)}, ps),
    +em: {{Codec.parts(h, {sch[i]}) == Some{{ps}} : {MP}}}, +r: S.Value,
    +e: {E_(i, tail)}) -> {GOAL}:
  match ps:
    case Nil{{}}: Empty.absurd({GOAL}, hf)
    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: {cfix}
    case Con{{S.Variable{{+ys}}, Nil{{}}}}: {cvar}
    case Con{{S.Fixed{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)
    case Con{{S.Variable{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)

def fm{i}({CW}{acct(i)}, +h: S.Value, +mm: {MP}, hf: DF.single_result({width(i)}, mm),
    +em: {{Codec.parts(h, {sch[i]}) == mm : {MP}}}, +r: S.Value,
    +e: {E_(i, f'Codec.concatenate(mm, Codec.parts(r, {chain(i + 1)}))')}) -> {GOAL}:
  match mm:
    case None{{}}: {ABS("e")}
    case Some{{+ps}}: fp{i}({CA}{acca(i)}, h, ps, hf, em, r, e)
''')
        w(ST)
    vc = '\n'.join(f'    case S.Sequence{{+items}}: st0({CA}, items, e)' if c.startswith('S.Sequence') else f'    case {c}: {ABS("e")}' for c in CONS)
    w(f'''
# Every value whose spec parts are the window's bytes passes the checks.
def invw({CW}, +v: S.Value,
    +e: {{Codec.parts(v, Spec.{x.n}()) == {RHSV} : {MP}}}) -> {GOAL}:
  match v:
{vc}
''')
    return L_


def main():
    SL.EXACT = True   # the exact spec-parts proofs (codegen/spec_laws.py), before any walk
    nb = '--no-big' in sys.argv
    out = {}
    if not nb:
        names = schema.load(ROOT / 'codegen/fulu.yaml')
        g = G.Gen()
        for nm, t in names.items():
            g.shape(t)
        for nm, kids in CONTAINERS.items():
            out[fname(nm)] = win_text(CName(g, nm, names[nm], kids))
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, text in out.items() if not p.exists() or p.read_text() != text]
        if stale:
            print('stale generated container windows: ' + ', '.join(stale))
            sys.exit(1)
        print('generated container windows are current')
        return
    for p, text in out.items():
        p.write_text(text)
    print(', '.join(str(p.relative_to(ROOT)) for p in out) or 'nothing (--no-big)')


if __name__ == '__main__':
    main()
