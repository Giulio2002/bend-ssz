#!/usr/bin/env python3
"""Byte-offset windows of containers with several variable fields (the
interface of proofs/obj/vua_win.bend): BeaconBlockBody, whose four fixed and
nine variable fields are read by their own window modules.

    python3 codegen/var_winb.py [--check] [--no-big]
    python3 codegen/var_winb.py --test NAME OUT    (a test module, not tracked)

The container at a window at byte offset x (x = to_nat off), length len:

  validator  the runtime's flat chain: the fixed part is there (IT0), the first
             offset is the fixed size (IT1), each offset lies between the one
             before and len (IT2 ..), then each variable field's window passes
             its child's check (the D items). CHKw is their conjunction.
  reader     the offsets, then every field in order: the fixed ones by the
             fixed readers of vua_fix.bend, the variable ones by their child's
             readw. A container of more than eight fields is read by groups
             of eight (as types/fulu_obj.bend emits it).
  spec       the parts of VALw are the fixed parts' words and the children's
             windows; Layout.encoding of those parts is the window's bytes
             (vua_lay.hdr_fp: the fixed region is the header words).
  inversion  a value whose parts are the window's bytes: the value's parts are
             read back part by part (vua_lay: lay_off, lay_pay, lay_end), so
             the offsets are the layout's, each child's window holds that
             child's payload, and each child's invw gives its check.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import var_laws as VL  # noqa: E402
import var_win as W  # noqa: E402
import schema  # noqa: E402
import generate as G  # noqa: E402

ROOT = VL.ROOT
GROUP = 8
# the child window module of each variable field's runtime prefix (boxes stripped)
CHECKED = {'bv4'}
CHILD_MOD = {
    'l16_ProposerSlashing': 'var_winx_l16_ProposerSlashing.bend',
    'l1_AttesterSlashing': 'big_var_winx_l1_AttesterSlashing.bend',
    'l8_Attestation': 'big_var_winx_l8_Attestation.bend',
    'l16_Deposit': 'var_winx_l16_Deposit.bend',
    'l16_SignedVoluntaryExit': 'var_winx_l16_SignedVoluntaryExit.bend',
    'ExecutionPayload': 'var_winx_ExecutionPayload.bend',
    'l16_SignedBLSToExecutionChange': 'var_winx_l16_SignedBLSToExecutionChange.bend',
    'l4096_b48': 'var_winx_l4096_b48.bend',
    'ExecutionRequests': 'var_winx_ExecutionRequests.bend',
    'l8192_DepositRequest': 'var_winx_l8192_DepositRequest.bend',
    'l16_WithdrawalRequest': 'var_winx_l16_WithdrawalRequest.bend',
    'l2_ConsolidationRequest': 'var_winx_l2_ConsolidationRequest.bend',
    'l128_u64': 'var_winx_l128_u64.bend',
    'BeaconBlockBody': 'big_var_winx_BeaconBlockBody.bend',
    'BeaconBlock': 'big_var_winx_BeaconBlock.bend',
    # BeaconState's lists
    'l16777216_b32': 'big_var_winx_l16777216_b32.bend',
    'l2048_Eth1Data': 'var_winx_l2048_Eth1Data.bend',
    'l1099511627776_Validator': 'big_var_winx_l1099511627776_Validator.bend',
    'l1099511627776_u64': 'big_var_winx_l1099511627776_u64.bend',
    'l1099511627776_u8': 'big_var_winx_l1099511627776_u8.bend',
    'ExecutionPayloadHeader': 'var_bytesx_ExecutionPayloadHeader.bend',
    'l16777216_HistoricalSummary': 'big_var_winx_l16777216_HistoricalSummary.bend',
    'l134217728_PendingDeposit': 'big_var_winx_l134217728_PendingDeposit.bend',
    'l134217728_PendingPartialWithdrawal': 'big_var_winx_l134217728_PendingPartialWithdrawal.bend',
    'l262144_PendingConsolidation': 'big_var_winx_l262144_PendingConsolidation.bend',
}
# containers written only with --pending (not yet checked)
PENDING = set()
# the fixed-field modules (at any byte position) of the containers generated with window slices
FIXMOD = {p: f'vfx_{p}.bend' for p in ['u64', 'b32', 'Fork', 'BeaconBlockHeader', 'v8192_b32', 'Eth1Data', 'v65536_b32', 'v8192_u64', 'bv4',
                                         'Checkpoint', 'SyncCommittee', 'v64_u64']}
# (container, output file) of the tracked modules
MODULES = [('BeaconBlockBody', 'big_var_winx_BeaconBlockBody.bend', False), ('BeaconBlock', 'big_var_winx_BeaconBlock.bend', False),
           ('SignedBeaconBlock', 'big_var_winx_SignedBeaconBlock.bend', False), ('BeaconState', 'big_var_winx_BeaconState.bend', True)]

CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
      '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
      '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
TXO = '+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'
TXOA = 't, x, off, len'
PW = 'A.quad(VB.pw(d))'
BUF = 'BF(t, n)'
MP = 'Maybe<&2, +List<S.Part>>'
M = 'Maybe<&2, +List<U32>>'
TRUE = 'True{} : Bool'
WBL = 'UW.WX(t, x, U32.to_nat(len))'
TGT = f'Some{{[S.Variable{{{WBL}}}]}}'
GOAL = f'{{CHKw(t, x, off, len) == {TRUE}}}'
HCHK = f'+hchk: {{CHKw(t, x, off, len) == {TRUE}}}'


def pos(c):
    return 'x' if c == 0 else f'{c}n+x'


def qual(rep):
    """A runtime representation type, qualified from outside types/fulu_obj.bend."""
    m = re.fullmatch(r'O\.Boxed<(\w+)>', rep)
    if m:
        return f'O.Boxed<T.{m.group(1)}>'
    return rep if rep.startswith('O.') else f'T.{rep}'


def split_top(txt):
    """Split txt at its top-level commas."""
    out, depth, cur = [], 0, ''
    for ch in txt:
        if ch in '{[(<':
            depth += 1
        elif ch in '}])>':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    out.append(cur.strip())
    return out


def generic_schema(name):
    """(names text, [field schema texts], kind) of generic container `name` (proofs/obj/generic_specs.bend);
    kind is 'Container' or 'ProgressiveContainer' (encoded alike: spec/codec.bend)."""
    src = (ROOT / 'proofs/obj/generic_specs.bend').read_text()
    m = re.search(rf'^def {name}\(\) -> S\.Schema: S\.(Container|ProgressiveContainer)\{{(.*)\}}$', src, re.M)
    kind = m.group(1)
    top = split_top(m.group(2))
    names_txt, ch = top[0], top[1]
    kids = []
    while ch != 'S.End{}':
        assert ch.startswith('S.Chain{') and ch.endswith('}'), ch
        a, b = split_top(ch[len('S.Chain{'):-1])
        kids.append(a)
        ch = b
    return names_txt, kids, kind


class Layout:
    """The fields of container `name`: kind, byte position c, spec schema sk;
    fixed fields their FT, variable ones their index j, child prefix and module."""

    def __init__(self, name, g, names, sym=False, fixmod=None, generic=False):
        self.name = name
        self.sym = sym
        self.generic = generic
        self.g = g
        t = names[name]
        s = g.shape(t)
        if generic:
            _, ktxt, self.CK = generic_schema(name)
            kids = [f'F{i}' for i in range(len(ktxt))]
            self.top = f'GS.{name}()'
        else:
            kids, _ = VL.spec_schemas(name)
            ktxt = [f'Spec.{k}()' for k in kids]
            self.CK = 'Container'
            self.top = f'Spec.{name}()'
        self.defs = W.spec_defs()
        self.fields = []
        p = 0
        for i, ((fn, ft), (_, fs), k) in enumerate(zip(t.fields, s.fields, kids)):
            f = {'i': i, 'name': fn, 'c': p, 'k': p // 4, 't': ft, 'sk': k, 'sch': ktxt[i], 'box': fs.kind == 'box', 'rep': qual(fs.rep)}
            if ft.fixed():
                f['kind'] = 'fix'
                f['size'] = ft.fixed_size()
                if sym:
                    # read by a fixed-field module at any byte position (FIXMOD)
                    f['rt'] = fs.p
                    f['fmod'] = fixmod[fs.p]
                    f['fa'] = f'FX_{fs.p}'
                    f['chk'] = fs.p in CHECKED
                else:
                    f['ft'] = VL.FT(g, ft)
                p += f['size']
            else:
                f['kind'] = 'var'
                base = fs.p[:-3] if f['box'] else fs.p
                f['p'] = base
                f['mod'] = CHILD_MOD[base]
                f['j'] = sum(1 for q in self.fields if q['kind'] == 'var')
                f['brep'] = qual(g.shape(ft).rep) if f['box'] else f['rep']
                p += 4
            self.fields.append(f)
        self.FS = p
        self.vars = [f for f in self.fields if f['kind'] == 'var']
        self.k = len(self.vars)
        self.nf = len(self.fields)
        self.grouped = self.nf > GROUP
        self.fchk = [f for f in self.fields if f.get('chk')]
        if not sym:
            assert p % 4 == 0
            self.H = p // 4
            self.nodes = VL.field_nodes(g, self, lambda k: f'UR.RWN(t, {pos(4 * k)})')

    def pos(self, c):
        return f'Nat.add(x, U32.to_nat({c}))' if self.sym else pos(c)

    # ---- constants (sym: U32 terms, never evaluated in unary; see proofs/obj/vadd.bend) ----
    @property
    def FSN(self):
        return f'U32.to_nat({self.FS})' if self.sym else f'{self.FS}n'

    def PN(self, c):
        """A byte position c of the fixed region, as a Nat term."""
        return f'U32.to_nat({c})' if self.sym else f'{c}n'

    def ES(self, s):
        """U32.to_nat(s) == sn."""
        return '{==}' if s <= 4096 else f'eSz{s}()'

    def LEA(self, c, s):
        """Nat.is_le(Nat.add(PN(c), sn), FSN)."""
        return f'VA.lea({c}, {s}, {self.FS}, {s}n, {self.ES(s)}, {{==}}, {{==}})' if self.sym else '{==}'

    def LEC(self, c):
        """Nat.is_le(PN(c), FSN)."""
        return f'VA.le_nat({c}, {self.FS}, {{==}})' if self.sym else '{==}'

    def RD(self, c):
        """The header word at off + c."""
        return f'{RDF(self)}({CWA}, hF, {c}, {self.PN(c)}, {EU(self, c)}, {self.LEA(c, 4)})'

    def EOC(self, c):
        return f'eocX({CWA}, hF, {c}, {self.PN(c)}, {{==}}, {self.LEC(c)})'

    def ROOM(self, c, s, hF='hF'):
        return f'roomFX({CWA}, {hF}, {self.PN(c)}, {s}n, {self.LEA(c, s)})'

    def wpos_targets(self):
        return sorted({f['i'] for f in self.vars} | {f['i'] for f in self.fchk})

    def fmods(self):
        out = {}
        for f in self.fields:
            if f.get('fmod'):
                out[f['fa']] = f['fmod']
        return out

    # ---- terms ----
    def O(self, j):
        return f'O{j}(t, x)'

    def E(self, j):
        return self.O(j + 1) if j + 1 < self.k else 'len'

    def XJ(self, j):
        return f'XJ{j}(t, x)'

    def FJ(self, j):
        return f'FJ{j}(off, t, x)'

    def LJ(self, j):
        return f'LJ{j}(t, x, len)' if j + 1 == self.k else f'LJ{j}(t, x)'

    def Y(self, j):
        return f'UW.WX(t, {self.XJ(j)}, U32.to_nat({self.LJ(j)}))'

    def spec(self, f):
        return f['sch']


# ---------------------------------------------------------------------------------------------------
# definitions and the facts the checks give

def EU(L, c):
    return '{==}'


def LEF(L, h):
    """FS <= len from U32.is_le(FS, len) == True (h)."""
    if not L.sym:
        return f'le_nat({L.FS}, len, {h})'
    return f'le_nat({L.FS}, len, {h})'


def EUDEFS(L):
    """The sym layout's arithmetic: the large sizes as Nat literals (once each), and the widths'
    sums WFS / WPOS of the fixed region at U32 positions (vadd.bend's lemmas, instantiated)."""
    w = []
    sizes = sorted({f['size'] for f in L.fields if f['kind'] == 'fix' and f['size'] > 4096})
    for s in sizes:
        w.append(f'def eSz{s}() -> {{U32.to_nat({s}) == {s}n : Nat}}: FD.nat__eq_from_is_eq(U32.to_nat({s}), {s}n, {{==}})')
    FS = L.FS
    nf = L.nf
    sz = [f['size'] if f['kind'] == 'fix' else 4 for f in L.fields]
    wv = [f'Some{{{f["size"]}n}}' if f['kind'] == 'fix' else 'None{}' for f in L.fields]
    w.append('# the widths from part k on')
    w.append(f'def WSS{nf}() -> +List<Maybe<&2, Nat>>: Nil{{}}')
    for q in range(nf - 1, -1, -1):
        w.append(f'def WSS{q}() -> +List<Maybe<&2, Nat>>: Con{{{wv[q]}, WSS{q + 1}()}}')
    w.append('# their sums: the fixed region from part k on')
    w.append(f'def wf{nf}() -> {{LY.WFS(WSS{nf}()) == U32.to_nat(0) : Nat}}: {{==}}')
    for q in range(nf - 1, -1, -1):
        c = L.fields[q]['c']
        R, R1 = FS - c, FS - c - sz[q]
        w.append(f'def wf{q}() -> {{LY.WFS(WSS{q}()) == U32.to_nat({R}) : Nat}}:')
        w.append(f'  Equal.trans(Nat, LY.WFS(WSS{q}()), Nat.add({sz[q]}n, U32.to_nat({R1})), U32.to_nat({R}), VA.wfs_c({wv[q]}, WSS{q + 1}(), {sz[q]}n, U32.to_nat({R1}), {{==}}, wf{q + 1}()),')
        w.append(f'    VA.stpL({sz[q]}, {R1}, {R}, {sz[q]}n, {L.ES(sz[q])}, {{==}}, {{==}}))')
    w.append('# the positions: part i at c_i (the widths before it summed)')
    for i in L.wpos_targets():
        ci = L.fields[i]['c']
        w.append(f'def wp{i}_{i}() -> {{LY.WPOS(WSS{i}(), 0n) == U32.to_nat(0) : Nat}}: VA.wpos_0(WSS{i}())')
        for q in range(i - 1, -1, -1):
            c = L.fields[q]['c']
            D, D1 = ci - c, ci - c - sz[q]
            w.append(f'def wp{i}_{q}() -> {{LY.WPOS(WSS{q}(), {i - q}n) == U32.to_nat({D}) : Nat}}:')
            w.append(f'  Equal.trans(Nat, LY.WPOS(WSS{q}(), {i - q}n), Nat.add({sz[q]}n, U32.to_nat({D1})), U32.to_nat({D}), VA.wpos_c({wv[q]}, WSS{q + 1}(), {i - q - 1}n, {sz[q]}n, U32.to_nat({D1}), {{==}}, wp{i}_{q + 1}()),')
            w.append(f'    VA.stpL({sz[q]}, {D1}, {D}, {sz[q]}n, {L.ES(sz[q])}, {{==}}, {{==}}))')
    return '\n'.join(w) + '\n'


def RDF(L):
    return 'rdFX' if L.sym else 'rdF'


SYMX = r'''
# ---- positions as x + c (a literal second argument never unfolds) --------------------------------

def eocX(@CW, +hF: {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(k, @FSn) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(x, k) : Nat}:
  Equal.trans(Nat, U32.to_nat(U32.add(off, c)), Nat.add(k, x), Nat.add(x, k), eoc(@CWA, hF, c, k, ec, hk), FD.nat__add_comm(k, x))

def roomFX(@CW, +hF: {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), @FSn) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(x, c), s), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, s), A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(c, x), Nat.add(x, c), FD.nat__add_comm(c, x), roomF(@CWA, hF, c, s, hc))

def rdFX(@CW, +hF: {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(Nat.add(k, 4n), @FSn) == True{} : Bool})
    -> {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(x, k))) : B.Buf & U32}:
  FD.logic__subst(Nat, z => {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, z)) : B.Buf & U32}, Nat.add(k, x), Nat.add(x, k), FD.nat__add_comm(k, x), rdF(@CWA, hF, c, k, ec, hk))

def splitX(+t: FD.array__Tree<U32>, +x: Nat, +c: Nat, +s: Nat, +r: Nat)
    -> {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, Nat.add(c, s)), r)) : +List<U32>}:
  +e = Equal.trans(Nat, Nat.add(s, Nat.add(x, c)), Nat.add(x, Nat.add(s, c)), Nat.add(x, Nat.add(c, s)), FD.lru_nat_algebra__add_swap(s, x, c),
    Equal.cong(Nat, Nat, z => Nat.add(x, z), Nat.add(s, c), Nat.add(c, s), FD.nat__add_comm(s, c)))
  FD.logic__subst(Nat, z => {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, z, r)) : +List<U32>}, Nat.add(s, Nat.add(x, c)), Nat.add(x, Nat.add(c, s)), e,
    UW.splitWX(t, Nat.add(x, c), s, r))

def splitXe(+t: FD.array__Tree<U32>, +x: Nat, +c: Nat, +s: Nat, +r: Nat, +T: Nat, +c2: Nat, +eT: {Nat.add(s, r) == T : Nat}, +e2: {Nat.add(c, s) == c2 : Nat})
    -> {UW.WX(t, Nat.add(x, c), T) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, c2), r)) : +List<U32>}:
  %eT : {UW.WX(t, Nat.add(x, c), _) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, c2), r)) : +List<U32>}
  %e2 : {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, _), r)) : +List<U32>}
  splitX(t, x, c, s, r)

def splitR(+t: FD.array__Tree<U32>, +x: Nat, +s: Nat, +r: Nat)
    -> {UW.WX(t, x, Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, x, s), UW.WX(t, Nat.add(x, s), r)) : +List<U32>}:
  FD.logic__subst(Nat, z => {UW.WX(t, x, Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, x, s), UW.WX(t, z, r)) : +List<U32>}, Nat.add(s, x), Nat.add(x, s), FD.nat__add_comm(s, x), UW.splitWX(t, x, s, r))

def subX(+t: FD.array__Tree<U32>, +x: Nat, +k: Nat, +m: Nat, +L: Nat, +hl: {Nat.is_le(Nat.add(k, m), L) == True{} : Bool})
    -> {VS.bt(m, VS.bdr(k, UW.WX(t, x, L))) == UW.WX(t, Nat.add(x, k), m) : +List<U32>}:
  FD.logic__subst(Nat, z => {VS.bt(m, VS.bdr(k, UW.WX(t, x, L))) == UW.WX(t, z, m) : +List<U32>}, Nat.add(k, x), Nat.add(x, k), FD.nat__add_comm(k, x), UW.subWX(t, x, k, m, L, hl))

# The window's k .. k + s (k + s <= len) at x + k.
def room4(@CW, +k: Nat, +s: Nat, +hk: {Nat.is_le(Nat.add(k, s), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(x, k), s), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, Nat.add(k, s)), Nat.add(Nat.add(x, k), s),
    Equal.sym(Nat, Nat.add(Nat.add(x, k), s), Nat.add(x, Nat.add(k, s)), FD.nat__add_assoc(x, k, s)),
    FD.nat__le_trans(Nat.add(x, Nat.add(k, s)), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, Nat.add(k, s), U32.to_nat(len), hk), hw))

# The offset word at k: its limbs are the digits the layout puts there.
def offwX(@CW, +k: Nat, +v: Nat, +hk: {Nat.is_le(Nat.add(k, 4n), U32.to_nat(len)) == True{} : Bool}, +hv: {Nat.is_le(v, U32.to_nat(len)) == True{} : Bool},
    +eb: {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == N.digits(4n, v) : +List<U32>})
    -> {U32.to_nat(UR.RWN(t, Nat.add(x, k))) == v : Nat}:
  +P = Nat.add(x, k)
  VG.digits_word(UR.RWN(t, P), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, P)]), UW.WX(t, P, 4n), N.digits(4n, v), UR.rwn_bytes(d, t, P, pf, room4(@CWA, k, 4n, hk)),
      Equal.trans(+List<U32>, UW.WX(t, P, 4n), VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), N.digits(4n, v),
        Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), UW.WX(t, P, 4n), subX(t, x, k, 4n, U32.to_nat(len), hk)), eb)))
'''


def items(L):
    its = [f'U32.is_le({L.FS}, len)', f'U32.is_eq({L.O(0)}, {L.FS})']
    for j in range(1, L.k):
        its.append(f'Bool.and(U32.is_le({L.O(j - 1)}, {L.O(j)}), U32.is_le({L.O(j)}, len))')
    for f in L.fchk:
        its.append(f'{f["fa"]}.CHK(t, {L.pos(f["c"])})')
    for f in L.vars:
        j = f['j']
        its.append(f'CH{j}.CHKw(t, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)})')
    return its


def defs_text(L):
    w = []
    for f in L.vars:
        j = f['j']
        w.append(f'def O{j}(+t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, {L.pos(f["c"])})')
    for f in L.vars:
        j = f['j']
        w.append(f'def XJ{j}(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat({L.O(j)}), x)')
        w.append(f'def FJ{j}(+off: U32, +t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.add(off, {L.O(j)})')
        if j + 1 == L.k:
            w.append(f'def LJ{j}(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> U32: U32.sub(len, {L.O(j)})')
        else:
            w.append(f'def LJ{j}(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub({L.E(j)}, {L.O(j)})')
    w.append('')
    its = items(L)
    for m, it in enumerate(its):
        w.append(f'def IT{m}({TXO}) -> Bool: {it}')
    n = len(its)
    for m in range(n - 1, -1, -1):
        body = f'IT{m}({TXOA})' if m == n - 1 else f'Bool.and(IT{m}({TXOA}), K{m + 1}({TXOA}))'
        w.append(f'def K{m}({TXO}) -> Bool: {body}')
    w.append('')
    w.append(f'# The fixed part is there, the first offset is {L.FS}, the offsets are in order inside')
    w.append('# the window, and each variable field\'s window passes its child\'s check.')
    w.append(f'def CHKw({TXO}) -> Bool: K0({TXOA})')
    w.append('')
    return '\n'.join(w)


def common_text(L):
    FS = L.FS
    FSN = L.FSN
    return f'''
def le_nat(+a: U32, +b: U32, +h: {{U32.is_le(a, b) == {TRUE}}}) -> {{Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == {TRUE}}}:
  FD.logic__subst(Bool, z => {{z == {TRUE}}}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def and_l(+a: Bool, +b: Bool, +h: {{Bool.and(a, b) == {TRUE}}}) -> {{a == {TRUE}}}: FD.logic__and_left(a, b, h)
def and_r(+a: Bool, +b: Bool, +h: {{Bool.and(a, b) == {TRUE}}}) -> {{b == {TRUE}}}: FD.logic__and_right(a, b, h)

# A byte position o <= len of the window, as an offset: off + o at o + x.
def eoj({CW}, +o: U32, +h: {{Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == {TRUE}}})
    -> {{U32.to_nat(U32.add(off, o)) == Nat.add(U32.to_nat(o), x) : Nat}}:
  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), {PW}, Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {{==}}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))

def alg(+o: Nat, +x: Nat, +e: Nat, +h: {{Nat.is_le(o, e) == {TRUE}}}) -> {{Nat.add(Nat.add(o, x), Nat.sub(e, o)) == Nat.add(x, e) : Nat}}:
  %Equal.sym(Nat, Nat.add(Nat.add(o, x), Nat.sub(e, o)), Nat.add(o, Nat.add(x, Nat.sub(e, o))), FD.nat__add_assoc(o, x, Nat.sub(e, o))) : {{_ == Nat.add(x, e) : Nat}}
  %Equal.sym(Nat, Nat.add(o, Nat.add(x, Nat.sub(e, o))), Nat.add(x, Nat.add(o, Nat.sub(e, o))), FD.lru_nat_algebra__add_swap(o, x, Nat.sub(e, o))) : {{_ == Nat.add(x, e) : Nat}}
  %Equal.sym(Nat, Nat.add(o, Nat.sub(e, o)), e, FD.nat__sub_add(e, o, h)) : {{Nat.add(x, _) == Nat.add(x, e) : Nat}}
  {{==}}

# The window [a, b) of the window (a <= b <= len): its offset, and its room.
def eoW({CW}, +a: U32, +b: U32, +h1: {{Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == {TRUE}}}, +h2: {{Nat.is_le(U32.to_nat(b), U32.to_nat(len)) == {TRUE}}})
    -> {{U32.to_nat(U32.add(off, a)) == Nat.add(U32.to_nat(a), x) : Nat}}:
  eoj({CWA}, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), h1, h2))

def hwj({CW}, +o: U32, +e: U32, +h1: {{Nat.is_le(U32.to_nat(o), U32.to_nat(e)) == {TRUE}}}, +h2: {{Nat.is_le(U32.to_nat(e), U32.to_nat(len)) == {TRUE}}})
    -> {{Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), {PW}) == {TRUE}}}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(e, o)), Nat.sub(U32.to_nat(e), U32.to_nat(o)), FD.u32__sub_nat(e, o, h1)) : {{Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), {PW}) == {TRUE}}}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(o), x), Nat.sub(U32.to_nat(e), U32.to_nat(o))), Nat.add(x, U32.to_nat(e)), alg(U32.to_nat(o), x, U32.to_nat(e), h1)) :
    {{Nat.is_le(_, {PW}) == {TRUE}}}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), {PW}, Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)

# Room for s bytes at c + x, for c + s <= {FS} <= len.
def roomF({CW}, +hF: {{Nat.is_le({FSN}, U32.to_nat(len)) == {TRUE}}}, +c: Nat, +s: Nat, +hc: {{Nat.is_le(Nat.add(c, s), {FSN}) == {TRUE}}})
    -> {{Nat.is_le(Nat.add(Nat.add(c, x), s), {PW}) == {TRUE}}}:
  UR.roomf(x, U32.to_nat(len), c, s, {PW}, hw, FD.nat__le_trans(Nat.add(c, s), {FSN}, U32.to_nat(len), hc, hF))

# off + c at c + x, for c <= {FS} <= len.
def eoc({CW}, +hF: {{Nat.is_le({FSN}, U32.to_nat(len)) == {TRUE}}}, +c: U32, +k: Nat, +ec: {{U32.to_nat(c) == k : Nat}}, +hk: {{Nat.is_le(k, {FSN}) == {TRUE}}})
    -> {{U32.to_nat(U32.add(off, c)) == Nat.add(k, x) : Nat}}:
  %ec : {{U32.to_nat(U32.add(off, c)) == Nat.add(_, x) : Nat}}
  eoj({CWA}, c, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == {TRUE}}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), FD.nat__le_trans(k, {FSN}, U32.to_nat(len), hk, hF)))

# The header word at off + c (c + 4 <= {FS} <= len).
def rdF({CW}, +hF: {{Nat.is_le({FSN}, U32.to_nat(len)) == {TRUE}}}, +c: U32, +k: Nat, +ec: {{U32.to_nat(c) == k : Nat}}, +hk: {{Nat.is_le(Nat.add(k, 4n), {FSN}) == {TRUE}}})
    -> {{B.read32({BUF}, U32.add(off, c)) == ({BUF}, UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}}:
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x), eoc({CWA}, hF, c, k, ec, FD.nat__le_trans(k, Nat.add(k, 4n), {FSN}, Order.below_sum(k, 4n), hk)),
    FD.nat__lt_trans(d, 28n, 31n, hd, {{==}}), pf, roomF({CWA}, hF, k, 4n, hk))
'''


OFFW = r"""
# The four window bytes at k are the limbs of the word at x + k.
def wbk(@CW, +k: Nat, +L2: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat},
    +hk: {Nat.is_le(Nat.add(Nat.add(k, x), 4n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(k, 4n+L2), el) : {VS.bt(4n, VS.bdr(k, UW.WX(t, x, _))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}
  VRC.wbytes(d, t, x, k, L2, pf, hk)

# The offset word at k: its limbs are the digits the layout puts there.
def offw(@CW, +k: Nat, +L2: Nat, +v: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat}, +hv: {Nat.is_le(v, U32.to_nat(len)) == True{} : Bool},
    +eb: {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == N.digits(4n, v) : +List<U32>})
    -> {U32.to_nat(UR.RWN(t, Nat.add(k, x))) == v : Nat}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(k, 4n+L2), el, hw)
  +le0 = Order.add_left(k, Nat.add(x, 4n), Nat.add(x, 4n+L2), Order.add_left(x, 4n, 4n+L2, Order.below_sum(4n, L2)))
  +le1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(k, Nat.add(x, 4n+L2))) == True{} : Bool}, Nat.add(k, Nat.add(x, 4n)), Nat.add(Nat.add(k, x), 4n),
    Equal.sym(Nat, Nat.add(Nat.add(k, x), 4n), Nat.add(k, Nat.add(x, 4n)), FD.nat__add_assoc(k, x, 4n)), le0)
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(k, x), 4n), z) == True{} : Bool}, Nat.add(k, Nat.add(x, 4n+L2)), Nat.add(x, Nat.add(k, 4n+L2)),
    Equal.sym(Nat, Nat.add(x, Nat.add(k, 4n+L2)), Nat.add(k, Nat.add(x, 4n+L2)), FD.lru_nat_algebra__add_swap(x, k, 4n+L2)), le1)
  +hk = FD.nat__le_trans(Nat.add(Nat.add(k, x), 4n), Nat.add(x, Nat.add(k, 4n+L2)), A.quad(VB.pw(d)), le2, hl)
  VG.digits_word(UR.RWN(t, Nat.add(k, x)), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, Nat.add(k, x))]), VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), N.digits(4n, v),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), F.limbs([UR.RWN(t, Nat.add(k, x))]), wbk(@CWA, k, L2, el, hk)),
      eb))
"""


def facts_text(L):
    """What CHKw == True gives: every item, the windows' ranges, the offsets' values."""
    its = items(L)
    n = len(its)
    k = L.k
    w = []
    H = f'+h: {{CHKw(t, x, off, len) == {TRUE}}}'
    w.append(f'def kk0({TXO}, {H}) -> {{K0({TXOA}) == {TRUE}}}: h')
    for m in range(n - 1):
        w.append(f'def kk{m + 1}({TXO}, {H}) -> {{K{m + 1}({TXOA}) == {TRUE}}}: and_r(IT{m}({TXOA}), K{m + 1}({TXOA}), kk{m}({TXOA}, h))')
    for m in range(n):
        if m == n - 1:
            w.append(f'def it{m}({TXO}, {H}) -> {{IT{m}({TXOA}) == {TRUE}}}: kk{m}({TXOA}, h)')
        else:
            w.append(f'def it{m}({TXO}, {H}) -> {{IT{m}({TXOA}) == {TRUE}}}: and_l(IT{m}({TXOA}), K{m + 1}({TXOA}), kk{m}({TXOA}, h))')
    w.append(f'def hFc({TXO}, {H}) -> {{Nat.is_le({L.FSN}, U32.to_nat(len)) == {TRUE}}}: {LEF(L, "it0(" + TXOA + ", h)")}')
    w.append(f'def eO0({TXO}, {H}) -> {{U32.to_nat({L.O(0)}) == {L.FSN} : Nat}}:')
    w.append(f'  Equal.cong(U32, Nat, z => U32.to_nat(z), {L.O(0)}, {L.FS}, FD.u32alg__eq_of({L.O(0)}, {L.FS}, it1({TXOA}, h)))')
    for j in range(k):
        E = L.E(j)
        if j + 1 < k:
            R = f'U32.is_le({L.O(j)}, {L.O(j + 1)}), U32.is_le({L.O(j + 1)}, len)'
            w.append(f'def r1{j}({TXO}, {H}) -> {{Nat.is_le(U32.to_nat({L.O(j)}), U32.to_nat({E})) == {TRUE}}}: le_nat({L.O(j)}, {E}, and_l({R}, it{j + 2}({TXOA}, h)))')
            w.append(f'def r2{j}({TXO}, {H}) -> {{Nat.is_le(U32.to_nat({E}), U32.to_nat(len)) == {TRUE}}}: le_nat({E}, len, and_r({R}, it{j + 2}({TXOA}, h)))')
        else:
            if k >= 2:
                R = f'U32.is_le({L.O(j - 1)}, {L.O(j)}), U32.is_le({L.O(j)}, len)'
                body = f'le_nat({L.O(j)}, len, and_r({R}, it{j + 1}({TXOA}, h)))'
            else:
                body = (f'FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == {TRUE}}}, {L.FSN}, U32.to_nat({L.O(0)}), '
                        f'Equal.sym(Nat, U32.to_nat({L.O(0)}), {L.FSN}, eO0({TXOA}, h)), hFc({TXOA}, h))')
            w.append(f'def r1{j}({TXO}, {H}) -> {{Nat.is_le(U32.to_nat({L.O(j)}), U32.to_nat(len)) == {TRUE}}}: {body}')
            w.append(f'def r2{j}({TXO}, {H}) -> {{Nat.is_le(U32.to_nat(len), U32.to_nat(len)) == {TRUE}}}: Order.reflexive(U32.to_nat(len))')
    for j in range(k):
        E = L.E(j)
        w.append(f'def eoJ{j}({CW}, {H}) -> {{U32.to_nat({L.FJ(j)}) == {L.XJ(j)} : Nat}}: eoW({CWA}, {L.O(j)}, {E}, r1{j}({TXOA}, h), r2{j}({TXOA}, h))')
        w.append(f'def hwJ{j}({CW}, {H}) -> {{Nat.is_le(Nat.add({L.XJ(j)}, U32.to_nat({L.LJ(j)})), {PW}) == {TRUE}}}: hwj({CWA}, {L.O(j)}, {E}, r1{j}({TXOA}, h), r2{j}({TXOA}, h))')
        w.append(f'def itD{j}({TXO}, {H}) -> {{CH{j}.CHKw(t, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)}) == {TRUE}}}: it{k + 1 + len(L.fchk) + j}({TXOA}, h)')
        w.append(f'def eE{j}({TXO}, {H}) -> {{U32.to_nat({E}) == Nat.add(U32.to_nat({L.O(j)}), U32.to_nat({L.LJ(j)})) : Nat}}:')
        w.append(f'  Equal.sym(Nat, Nat.add(U32.to_nat({L.O(j)}), U32.to_nat(U32.sub({E}, {L.O(j)}))), U32.to_nat({E}), VM.sub_eq({E}, {L.O(j)}, VMR.u32le({L.O(j)}, {E}, r1{j}({TXOA}, h))))')
    w.append('')
    return '\n'.join(w)


# ---------------------------------------------------------------------------------------------------
# the validator

def validator_text(L):
    k = L.k
    Tn = f'T.{L.name}'
    w = []
    HF = f'+hF: {{Nat.is_le({L.FSN}, U32.to_nat(len)) == {TRUE}}}'

    def hI(m):
        return f'+hI{m}: {{IT{m}({TXOA}) == {TRUE}}}'

    def rng(j):
        """(O_j <= E_j, E_j <= len) from the stage facts hI1 .. hIk."""
        if j + 1 < k:
            R = f'U32.is_le({L.O(j)}, {L.O(j + 1)}), U32.is_le({L.O(j + 1)}, len)'
            return (f'le_nat({L.O(j)}, {L.O(j + 1)}, and_l({R}, hI{j + 2}))', f'le_nat({L.O(j + 1)}, len, and_r({R}, hI{j + 2}))')
        if k >= 2:
            R = f'U32.is_le({L.O(j - 1)}, {L.O(j)}), U32.is_le({L.O(j)}, len)'
            h1 = f'le_nat({L.O(j)}, len, and_r({R}, hI{k}))'
        else:
            h1 = (f'FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == {TRUE}}}, {L.FSN}, U32.to_nat({L.O(0)}), '
                  f'Equal.sym(Nat, U32.to_nat({L.O(0)}), {L.FSN}, Equal.cong(U32, Nat, z => U32.to_nat(z), {L.O(0)}, {L.FS}, FD.u32alg__eq_of({L.O(0)}, {L.FS}, hI1))), hF)')
        return (h1, 'Order.reflexive(U32.to_nat(len))')

    def OS(i):
        return ', '.join(L.O(j) for j in range(min(i, k - 1) + 1))

    m = len(L.fchk)
    last = 2 * k + m - 1
    for i in range(last, -1, -1):
        nfacts = min(i, k)
        decl = ', '.join([HF] + [hI(m) for m in range(1, nfacts + 1)])
        args = ', '.join(['hF'] + [f'hI{m}' for m in range(1, nfacts + 1)])
        cur = f'{Tn}_c{i}(b, {BUF}, off, len, {OS(i)})'
        if i == last:
            w.append(f'def okc{i}({CW}, {decl}, +b: Bool, +eb: {{IT{i + 1}({TXOA}) == b : Bool}}) -> {{{cur} == ({BUF}, b) : B.Buf & Bool}}:')
            w.append('  match b:')
            w.append('    case True{}: {==}')
            w.append('    case False{}: {==}')
            w.append('')
            continue
        RES = f'Bool.and(b, K{i + 2}({TXOA}))'
        w.append(f'def okc{i}({CW}, {decl}, +b: Bool, +eb: {{IT{i + 1}({TXOA}) == b : Bool}}) -> {{{cur} == ({BUF}, {RES}) : B.Buf & Bool}}:')
        w.append('  match b:')
        w.append('    case False{}: {==}')
        w.append('    case True{}:')
        if i + 1 <= k:
            w.append(f'      +hI{i + 1} = eb')
        nargs = args + (f', hI{i + 1}' if i + 1 <= k else '')
        GOALT = f'({BUF}, K{i + 2}({TXOA})) : B.Buf & Bool'
        if i < k - 1:
            f = L.vars[i + 1]
            c = f['c']
            w.append(f'      %Equal.sym(B.Buf & U32, B.read32({BUF}, U32.add(off, {c})), ({BUF}, {L.O(i + 1)}), {L.RD(c)}) :')
            w.append(f'        {{{Tn}_v{i + 1}(off, len, {OS(i)}, _) == {GOALT}}}')
        elif i < k - 1 + m:
            f = L.fchk[i - (k - 1)]
            c = f['c']
            w.append(f'      %Equal.sym(B.Buf & Bool, T.{f["rt"]}_ok_at({BUF}, U32.add(off, {c})), ({BUF}, {f["fa"]}.CHK(t, {L.pos(c)})),')
            w.append(f'          {f["fa"]}.ok(d, t, n, U32.add(off, {c}), {L.pos(c)}, {L.EOC(c)}, hd, pf, {L.ROOM(c, 4)})) :')
            w.append(f'        {{{Tn}_v{i + 1}(off, len, {OS(k - 1)}, _) == {GOALT}}}')
        else:
            j = i - (k - 1) - m
            f = L.vars[j]
            h1, h2 = rng(j)
            okf = f'T.{f["p"]}_bx_ok' if f['box'] else f'T.{f["p"]}_ok'
            w.append(f'      %Equal.sym(B.Buf & Bool, {okf}({BUF}, {L.FJ(j)}, {L.LJ(j)}), ({BUF}, CH{j}.CHKw(t, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)})),')
            w.append(f'          CH{j}.ok_evalw(d, t, n, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)}, eoW({CWA}, {L.O(j)}, {L.E(j)}, {h1}, {h2}), hd,')
            w.append(f'            hwj({CWA}, {L.O(j)}, {L.E(j)}, {h1}, {h2}), pf)) :')
            w.append(f'        {{{Tn}_v{i + 1}(off, len, {OS(k - 1)}, _) == {GOALT}}}')
        w.append(f'      okc{i + 1}({CWA}, {nargs}, IT{i + 2}({TXOA}), {{==}})')
        w.append('')
    w.append(f'def okl({CW}, +a: Bool, +ea: {{IT0({TXOA}) == a : Bool}})')
    w.append(f'    -> {{{Tn}_ok_len(a, {BUF}, off, len) == ({BUF}, Bool.and(a, K1({TXOA}))) : B.Buf & Bool}}:')
    w.append('  match a:')
    w.append('    case False{}: {==}')
    w.append('    case True{}:')
    w.append(f'      +hF = {LEF(L, "ea")}')
    c0 = L.vars[0]['c']
    w.append(f'      %Equal.sym(B.Buf & U32, B.read32({BUF}, U32.add(off, {c0})), ({BUF}, {L.O(0)}), {L.RD(c0)}) :')
    w.append(f'        {{{Tn}_v0(off, len, _) == ({BUF}, K1({TXOA})) : B.Buf & Bool}}')
    w.append(f'      okc0({CWA}, hF, IT1({TXOA}), {{==}})')
    w.append('')
    w.append('# The validator on the window returns the buffer and CHKw.')
    w.append(f'def ok_evalw({CW}) -> {{{Tn}_ok({BUF}, off, len) == ({BUF}, CHKw(t, x, off, len)) : B.Buf & Bool}}:')
    w.append(f'  okl({CWA}, IT0({TXOA}), {{==}})')
    w.append('')
    return '\n'.join(w)


# ---------------------------------------------------------------------------------------------------
# the reader

def field_obj(L, f):
    """The object field f reads, and the one the record holds (boxed if the field is)."""
    if f['kind'] == 'fix' and L.sym:
        o = f'{f["fa"]}.OBJ(d, t, {L.pos(f["c"])})'
    elif f['kind'] == 'fix':
        o = L.nodes[f['i']]['obj']
    else:
        j = f['j']
        o = f'CH{j}.OBJw(d, t, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)})'
    return o, (f'O.BSome{{{o}, O.BNone{{}}}}' if f['box'] else o)


def read_step(L, f):
    """(runtime call, value, equation type, proof, hole) of reading field f."""
    o, _ = field_obj(L, f)
    if f['kind'] == 'fix' and L.sym:
        c = f['c']
        sz = f['size']
        call = f'T.{f["rt"]}_read({BUF}, U32.add(off, {c}), {sz})'
        prf = (f'{f["fa"]}.rdx(d, t, n, U32.add(off, {c}), {L.pos(c)}, {L.EOC(c)}, hd, pf,\n'
               f'        {L.ROOM(c, max(sz, 4) if f.get("chk") else sz)})')
        ty = f'B.Buf & {f["rep"]}'
        base = f['rt']
    elif f['kind'] == 'fix':
        ft = f['ft']
        c = f['c']
        call = f'T.{ft.p}_read({BUF}, U32.add(off, {c}), {ft.size})'
        prf = (f'VTX.rdx_{ft.p}(d, t, n, U32.add(off, {c}), {pos(c)}, eoc({CWA}, hF, {c}, {c}n, {{==}}, {{==}}), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), pf,\n'
               f'        roomF({CWA}, hF, {c}n, {ft.size}n, {{==}}))')
        ty = f'B.Buf & {ft.rep()}'
        base = ft.p
    else:
        j = f['j']
        call = f'T.{f["p"]}_read({BUF}, {L.FJ(j)}, {L.LJ(j)})'
        prf = f'CH{j}.readw(d, t, n, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)}, eoJ{j}({CWA}, hchk), hd, hwJ{j}({CWA}, hchk), pf, itD{j}({TXOA}, hchk))'
        ty = f'B.Buf & {f["brep"]}'
        base = f['p']
    hole = f'T.{base}_bx_rd(_)' if f['box'] else '_'
    return call, o, ty, prf, hole


def fieldset_reader(L, name, prefix, R, fs, vend):
    """The lemma `name`: the runtime reader `prefix`_read of fields fs (record R)
    returns its record; vend is the group's end argument (None: a plain container)."""
    RT = f'T.{R}'
    objs = [field_obj(L, f)[1] for f in fs]
    OBJ = f'{RT}{{' + ', '.join(objs) + '}'
    xa = f', {vend}' if vend else ''
    RHS = f'({BUF}, {OBJ}) : B.Buf & {RT}'
    w = [f'def {name}({CW}, {HCHK})', f'    -> {{T.{prefix}_read({BUF}, off, len{xa}) == {RHS}}}:', f'  +hF = hFc({TXOA}, hchk)']
    done = []
    vs = [f for f in fs if f['kind'] == 'var']
    for s, f in enumerate(vs):
        c = f['c']
        pre = ', '.join(['off', 'len'] + ([vend] if vend else []) + done)
        w.append(f'  %Equal.sym(B.Buf & U32, B.read32({BUF}, U32.add(off, {c})), ({BUF}, {L.O(f["j"])}), {L.RD(c)}) :')
        w.append(f'    {{T.{prefix}_rd{s}({pre}, _) == {RHS}}}')
        done.append(L.O(f['j']))
    for q, f in enumerate(fs):
        call, o, ty, prf, hole = read_step(L, f)
        pre = ', '.join(['off', 'len'] + ([vend] if vend else []) + done)
        w.append(f'  %Equal.sym({ty}, {call}, ({BUF}, {o}),')
        w.append(f'      {prf}) :')
        w.append(f'    {{T.{prefix}_rd{len(vs) + q}({pre}, {hole}) == {RHS}}}')
        done.append(objs[q])
    w.append('  {==}')
    w.append('')
    return '\n'.join(w), OBJ


def reader_text(L):
    Tn = f'T.{L.name}'
    out = []
    if not L.grouped:
        txt, OBJ = fieldset_reader(L, 'rd_all', L.name, L.name, L.fields, None)
        out.append(txt)
        out.append(f'def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {Tn}: {OBJ}')
        out.append('')
        out.append('# The reader on the window, when the checks hold.')
        out.append(f'def readw({CW}, {HCHK}) -> {{{Tn}_read({BUF}, off, len) == ({BUF}, OBJw(d, t, x, off, len)) : B.Buf & {Tn}}}:')
        out.append(f'  rd_all({CWA}, hchk)')
        out.append('')
        return '\n'.join(out)
    groups = [L.fields[a:a + GROUP] for a in range(0, L.nf, GROUP)]
    firstvar = {}
    for gk, fs in enumerate(groups):
        for f in fs:
            if f['kind'] == 'var':
                firstvar[gk] = f
                break
    vg = [gk for gk in range(len(groups)) if gk in firstvar]

    def vend(gk):
        later = [q for q in vg if q > gk]
        return L.O(firstvar[later[0]]['j']) if later else 'len'
    gobjs = []
    for gk, fs in enumerate(groups):
        txt, OBJ = fieldset_reader(L, f'rdg{gk}', f'{L.name}_g{gk}', f'{L.name}_g{gk}', fs, vend(gk))
        out.append(txt)
        gobjs.append(OBJ)
    OBJ = f'{Tn}{{' + ', '.join(gobjs) + '}'
    out.append(f'def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {Tn}: {OBJ}')
    out.append('')
    out.append('# The reader on the window, when the checks hold.')
    RHS = f'({BUF}, OBJw(d, t, x, off, len)) : B.Buf & {Tn}'
    out.append(f'def readw({CW}, {HCHK}) -> {{{Tn}_read({BUF}, off, len) == {RHS}}}:')
    out.append(f'  +hF = hFc({TXOA}, hchk)')
    done = []
    s = 0
    for gk in vg:
        c = firstvar[gk]['c']
        pre = ', '.join(['off', 'len'] + done)
        out.append(f'  %Equal.sym(B.Buf & U32, B.read32({BUF}, U32.add(off, {c})), ({BUF}, {L.O(firstvar[gk]["j"])}), {L.RD(c)}) :')
        out.append(f'    {{{Tn}_rd{s}({pre}, _) == {RHS}}}')
        done.append(L.O(firstvar[gk]['j']))
        s += 1
    for gk in range(len(groups)):
        pre = ', '.join(['off', 'len'] + done)
        out.append(f'  %Equal.sym(B.Buf & T.{L.name}_g{gk}, T.{L.name}_g{gk}_read({BUF}, off, len, {vend(gk)}), ({BUF}, {gobjs[gk]}), rdg{gk}({CWA}, hchk)) :')
        out.append(f'    {{{Tn}_rd{s}({pre}, _) == {RHS}}}')
        done.append(gobjs[gk])
        s += 1
    out.append('  {==}')
    out.append('')
    return '\n'.join(out)


# ---------------------------------------------------------------------------------------------------
# the spec side

def sym_header_text(L, PSV, OSL, H):
    """The fixed region of a container whose fixed fields are window slices: its widths
    and size, and its bytes (the slices and the offset words) as the window's first FS bytes.
    Positions and remaining lengths are U32 terms (U32.to_nat(c)), stepped by vadd.bend."""
    FS = L.FS
    FSN = L.FSN
    w = []
    WS = 'WSS0()'
    fixed = [f for f in L.fields if f['kind'] == 'fix']
    w.append(f'def ewidw({CW}, {H}) -> {{LY.WID({PSV}) == {WS} : +List<Maybe<&2, Nat>>}}:')
    w.append(f'  +hF = hFc({TXOA}, h)')
    full = '[' + ', '.join(f'Some{{{f["size"]}n}}' if f['kind'] == 'fix' else 'None{}' for f in L.fields) + ']'
    for f in fixed:
        els = []
        for g2 in L.fields:
            if g2['kind'] == 'var':
                els.append('None{}')
            elif g2['i'] < f['i']:
                els.append(f'Some{{{g2["size"]}n}}')
            elif g2['i'] == f['i']:
                els.append('Some{_}')
            else:
                els.append(f'Some{{List.length(&2, U32, UW.WX(t, {L.pos(g2["c"])}, {g2["size"]}n))}}')
        P, sz = L.pos(f['c']), f['size']
        w.append(f'  %Equal.sym(Nat, List.length(&2, U32, UW.WX(t, {P}, {sz}n)), {sz}n, UW.lenWX(d, t, {P}, {sz}n, pf, {L.ROOM(f["c"], sz)})) :')
        w.append(f'    {{[{", ".join(els)}] == {WS} : +List<Maybe<&2, Nat>>}}')
    w.append(f'  %Equal.sym(+List<Maybe<&2, Nat>>, {full}, {WS}, {{==}}) : {{_ == {WS} : +List<Maybe<&2, Nat>>}}')
    w.append('  {==}')
    w.append('')
    w.append(f'def efsw({CW}, {H}) -> {{Layout.fixed_size({PSV}) == {FSN} : Nat}}:')
    w.append(f'  Equal.trans(Nat, Layout.fixed_size({PSV}), LY.WFS({WS}), {FSN}, Equal.trans(Nat, Layout.fixed_size({PSV}), LY.WFS(LY.WID({PSV})), LY.WFS({WS}), LY.fs_w({PSV}),')
    w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WFS(z), LY.WID({PSV}), {WS}, ewidw({CWA}, h))), wf0())')
    w.append('')
    # the fixed region's bytes
    pieces = []
    for f in L.fields:
        P = L.pos(f['c'])
        pieces.append(f'UW.WX(t, {P}, {f["size"]}n)' if f['kind'] == 'fix' else f'F.limbs([UR.RWN(t, {P})])')

    def pre(i, hole):
        return ''.join(f'List.append(&2, U32, {pc}, ' for pc in pieces[:i]) + hole + ')' * i
    w.append(f'# The fixed region: the fixed fields\' slices and the offset words, the window\'s first {FS} bytes.')
    w.append(f'def hdrE({CW}, {H}) -> {{LY.HDRW({PSV}, {OSL}) == UW.WX(t, x, {FSN}) : +List<U32>}}:')
    w.append(f'  +hF = hFc({TXOA}, h)')
    w.append(f'  %Equal.trans(Nat, Nat.add(x, U32.to_nat(0)), Nat.add(x, 0n), x, {{==}}, FD.nat__add_zero(x)) : {{LY.HDRW({PSV}, {OSL}) == UW.WX(t, _, {FSN}) : +List<U32>}}')
    for i, f in enumerate(L.fields):
        c = f['c']
        sz = f['size'] if f['kind'] == 'fix' else 4
        P = L.pos(c)
        R, R1 = FS - c, FS - c - sz
        cur = f'UW.WX(t, {P}, U32.to_nat({R}))'
        ea = f'VA.stpL({sz}, {R1}, {R}, {sz}n, {L.ES(sz)}, {{==}}, {{==}})'
        eb = f'VA.stp({c}, {sz}, {c + sz}, {sz}n, {L.ES(sz)}, {{==}}, {{==}})'
        w.append(f'  %Equal.sym(+List<U32>, {cur}, List.append(&2, U32, UW.WX(t, {P}, {sz}n), UW.WX(t, {L.pos(c + sz)}, U32.to_nat({R1}))), '
                 f'splitXe(t, x, U32.to_nat({c}), {sz}n, U32.to_nat({R1}), U32.to_nat({R}), U32.to_nat({c + sz}), {ea}, {eb})) :')
        w.append(f'    {{LY.HDRW({PSV}, {OSL}) == {pre(i, "_")} : +List<U32>}}')
        if f['kind'] == 'var':
            w.append(f'  %UR.rwn_bytes(d, t, {P}, pf, {L.ROOM(c, 4)}) :')
            w.append(f'    {{LY.HDRW({PSV}, {OSL}) == {pre(i, f"List.append(&2, U32, _, UW.WX(t, {L.pos(c + 4)}, U32.to_nat({R1})))")} : +List<U32>}}')
    w.append('  {==}')
    w.append('')
    return '\n'.join(w)


def sym_schema_text(L):
    """The spec schema as a variable sv = Spec.<name>(): its fields' chain, taken apart
    one head at a time (each fact closed at the literal, then transported to sv)."""
    nf = L.nf
    X = L.top
    w = ['', '# ---- the schema, taken apart without unfolding it ----------------------------------------------', '']
    CK = L.CK
    w.append(f'def TL0(+sv: S.Schema) -> S.Schema: SH.{CK}_fields(sv)')
    for i in range(nf):
        w.append(f'def TL{i + 1}(+sv: S.Schema) -> S.Schema: SH.Chain_tail(TL{i}(sv))')
    for i in range(nf):
        w.append(f'def HD{i}(+sv: S.Schema) -> S.Schema: SH.Chain_head(TL{i}(sv))')
    SVE = f'+sv: S.Schema, +esv: {{sv == {X} : S.Schema}}'
    TR = lambda body: f'FD.logic__subst(S.Schema, z => {{{body} : {"Bool" if "== True" in body else "S.Schema" if "Spec." in body or "S.End" in body else "Maybe<&2, Nat>"}}}, {X}, sv, Equal.sym(S.Schema, sv, {X}, esv), {{==}})'
    w.append(f'def isc({SVE}) -> {{SH.is_{CK}(sv) == True{{}} : Bool}}:')
    w.append(f'  FD.logic__subst(S.Schema, z => {{SH.is_{CK}(z) == True{{}} : Bool}}, {X}, sv, Equal.sym(S.Schema, sv, {X}, esv), {{==}})')
    w.append(f'def fsn({SVE}) -> {{SS.fixed_size(SH.{CK}_fields(sv)) == None{{}} : Maybe<&2, Nat>}}:')
    w.append(f'  FD.logic__subst(S.Schema, z => {{SS.fixed_size(SH.{CK}_fields(z)) == None{{}} : Maybe<&2, Nat>}}, {X}, sv, Equal.sym(S.Schema, sv, {X}, esv), {{==}})')
    for i, f in enumerate(L.fields):
        w.append(f'def es{i}({SVE}) -> {{HD{i}(sv) == {L.spec(f)} : S.Schema}}:')
        w.append(f'  FD.logic__subst(S.Schema, z => {{HD{i}(z) == {L.spec(f)} : S.Schema}}, {X}, sv, Equal.sym(S.Schema, sv, {X}, esv), {{==}})')
        w.append(f'def isch{i}({SVE}) -> {{SH.is_Chain(TL{i}(sv)) == True{{}} : Bool}}:')
        w.append(f'  FD.logic__subst(S.Schema, z => {{SH.is_Chain(TL{i}(z)) == True{{}} : Bool}}, {X}, sv, Equal.sym(S.Schema, sv, {X}, esv), {{==}})')
    w.append(f'def isend({SVE}) -> {{SH.is_End(TL{nf}(sv)) == True{{}} : Bool}}:')
    w.append(f'  FD.logic__subst(S.Schema, z => {{SH.is_End(TL{nf}(z)) == True{{}} : Bool}}, {X}, sv, Equal.sym(S.Schema, sv, {X}, esv), {{==}})')

    w.append(f'def CHS{nf}(+sv: S.Schema) -> S.Schema: S.End{{}}')
    for i in range(nf - 1, -1, -1):
        w.append(f'def CHS{i}(+sv: S.Schema) -> S.Schema: S.Chain{{HD{i}(sv), CHS{i + 1}(sv)}}')

    def ch(i):
        return f'CHS{i}(sv)'
    w.append(f'def fe{nf}({SVE}) -> {{TL{nf}(sv) == S.End{{}} : S.Schema}}: SH.End_shape(TL{nf}(sv), isend(sv, esv))')
    for i in range(nf - 1, -1, -1):
        w.append(f'def fe{i}({SVE}) -> {{TL{i}(sv) == {ch(i)} : S.Schema}}:')
        w.append(f'  Equal.trans(S.Schema, TL{i}(sv), S.Chain{{HD{i}(sv), TL{i + 1}(sv)}}, {ch(i)}, SH.Chain_shape(TL{i}(sv), isch{i}(sv, esv)),')
        w.append(f'    Equal.cong(S.Schema, S.Schema, z => S.Chain{{HD{i}(sv), z}}, TL{i + 1}(sv), {ch(i + 1)}, fe{i + 1}(sv, esv)))')
    w.append('')
    return '\n'.join(w)


def spec_text(L):
    k = L.k
    FS = L.FS
    FSN = L.FSN
    w = []
    vals, parts = [], []
    for f in L.fields:
        if f['kind'] == 'fix' and L.sym:
            vals.append(f'{f["fa"]}.VAL(t, {L.pos(f["c"])})')
            parts.append(f'S.Fixed{{UW.WX(t, {L.pos(f["c"])}, {f["size"]}n)}}')
        elif f['kind'] == 'fix':
            nd = L.nodes[f['i']]
            vals.append(nd['val'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            j = f['j']
            vals.append(f'CH{j}.VALw(t, {L.XJ(j)}, {L.LJ(j)})')
            parts.append(f'S.Variable{{{L.Y(j)}}}')
    nf = L.nf

    def itm(i):
        if L.sym:
            return f'ITS{i}(t, x, len)'
        return 'S.EmptyItems{}' if i == nf else f'S.Items{{{vals[i]}, {itm(i + 1)}}}'

    def chain(i):
        if L.sym:
            return f'CHS{i}(sv)'
        return 'S.End{}' if i == nf else f'S.Chain{{{L.spec(L.fields[i])}, {chain(i + 1)}}}'

    def sch(i):
        return f'HD{i}(sv)' if L.sym else L.spec(L.fields[i])

    def cat(i):
        if i == nf:
            return '{==}'
        rest = f'RST{i}(t, x, len)' if L.sym else '[' + ', '.join(parts[i + 1:]) + ']'
        f = L.fields[i]
        if f['kind'] == 'fix' and L.sym:
            P, sz = L.pos(f['c']), f['size']
            ex = ''
            hb = sz
            if f.get('chk'):
                ex = f', it{1 + L.k + L.fchk.index(f)}({TXOA}, hchk)'
                hb = max(sz, 4)
            return (f'F.cat_fixed(Codec.parts({vals[i]}, {sch(i)}), UW.WX(t, {P}, {sz}n), Codec.parts({itm(i + 1)}, {chain(i + 1)}), {rest}, '
                    f'{f["fa"]}.prt(d, t, {P}, pf, {L.ROOM(f["c"], hb, hF=f"hFc({TXOA}, hchk)")}, HD{i}(sv), es{i}(sv, esv){ex}),\n      {cat(i + 1)})')
        if f['kind'] == 'fix':
            nd = L.nodes[i]
            return (f'F.cat_fixed(Codec.parts({vals[i]}, {nd["sch"]}), F.limbs([{", ".join(nd["words"])}]), '
                    f'Codec.parts({itm(i + 1)}, {chain(i + 1)}), {rest}, {nd["proof"]},\n      {cat(i + 1)})')
        j = f['j']
        cs = f'CH{j}.specw(d, t, n, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)}, eoJ{j}({CWA}, hchk), hd, hwJ{j}({CWA}, hchk), pf, itD{j}({TXOA}, hchk))'
        if L.sym:
            cs = (f'FD.logic__subst(S.Schema, z => {{Codec.parts({vals[i]}, z) == Some{{[S.Variable{{{L.Y(j)}}}]}} : {MP}}}, {L.spec(f)}, HD{i}(sv), '
                  f'Equal.sym(S.Schema, HD{i}(sv), {L.spec(f)}, es{i}(sv, esv)), {cs})')
        return (f'VS.cat_var(Codec.parts({vals[i]}, {sch(i)}), {L.Y(j)}, Codec.parts({itm(i + 1)}, {chain(i + 1)}), {rest}, '
                f'{cs},\n      {cat(i + 1)})')
    PSV = '[' + ', '.join(parts) + ']'
    if L.sym:
        TXL = '+t: FD.array__Tree<U32>, +x: Nat, +len: U32'
        w.append(f'def PSW({TXL}) -> +List<S.Part>: {PSV}')
        w.append(f'def RST{nf - 1}({TXL}) -> +List<S.Part>: []')
        for i in range(nf - 2, -1, -1):
            w.append(f'def RST{i}({TXL}) -> +List<S.Part>: Con{{{parts[i + 1]}, RST{i + 1}(t, x, len)}}')
        w.append(f'def ITS{nf}({TXL}) -> S.Value: S.EmptyItems{{}}')
        for i in range(nf - 1, -1, -1):
            w.append(f'def ITS{i}({TXL}) -> S.Value: S.Items{{{vals[i]}, ITS{i + 1}(t, x, len)}}')
        w.append('')
        PSV = 'PSW(t, x, len)'
    OSL = '[' + ', '.join(L.O(j) for j in range(k)) + ']'
    Ln = [f'U32.to_nat({L.LJ(j)})' for j in range(k)]
    lenY = [(f'LY.LN({L.Y(j)})' if L.sym else f'List.length(&2, U32, {L.Y(j)})') for j in range(k)]
    H = f'+h: {{CHKw(t, x, off, len) == {TRUE}}}'
    if L.sym:
        w.append(sym_schema_text(L))
    w.append(f'def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{{{itm(0)}}}')
    w.append('')
    for j in range(k):
        w.append(f'def lY{j}({CW}, {H}) -> {{{lenY[j]} == {Ln[j]} : Nat}}: UW.lenWX(d, t, {L.XJ(j)}, {Ln[j]}, pf, hwJ{j}({CWA}, h))')
    # eq_j: to_nat O_j == Q_j, the layout's offsets from the children's lengths (eq_k: len)
    Q = [f'{FSN}']
    for j in range(1, k + 1):
        Q.append(f'Nat.add({Q[j - 1]}, {lenY[j - 1]})')
    w.append(f'def eq0({CW}, {H}) -> {{U32.to_nat({L.O(0)}) == {Q[0]} : Nat}}: eO0({TXOA}, h)')
    for j in range(1, k + 1):
        Ej = L.O(j) if j < k else 'len'
        w.append(f'def eq{j}({CW}, {H}) -> {{U32.to_nat({Ej}) == {Q[j]} : Nat}}:')
        w.append(f'  Equal.trans(Nat, U32.to_nat({Ej}), Nat.add(U32.to_nat({L.O(j - 1)}), {Ln[j - 1]}), {Q[j]}, eE{j - 1}({TXOA}, h),')
        w.append(f'    Equal.trans(Nat, Nat.add(U32.to_nat({L.O(j - 1)}), {Ln[j - 1]}), Nat.add({Q[j - 1]}, {Ln[j - 1]}), {Q[j]},')
        w.append(f'      Equal.cong(Nat, Nat, z => Nat.add(z, {Ln[j - 1]}), U32.to_nat({L.O(j - 1)}), {Q[j - 1]}, eq{j - 1}({CWA}, h)),')
        w.append(f'      Equal.cong(Nat, Nat, z => Nat.add({Q[j - 1]}, z), {Ln[j - 1]}, {lenY[j - 1]}, Equal.sym(Nat, {lenY[j - 1]}, {Ln[j - 1]}, lY{j - 1}({CWA}, h)))))')
    w.append('')
    # the window's length, right-nested: len == O_j + (L_j + (.. + L_(k-1)))
    RS = [None] * k
    RS[k - 1] = Ln[k - 1]
    for j in range(k - 2, -1, -1):
        RS[j] = f'Nat.add({Ln[j]}, {RS[j + 1]})'
    w.append(f'def eln{k - 1}({TXO}, {H}) -> {{U32.to_nat(len) == Nat.add(U32.to_nat({L.O(k - 1)}), {RS[k - 1]}) : Nat}}: eE{k - 1}({TXOA}, h)')
    for j in range(k - 2, -1, -1):
        w.append(f'def eln{j}({TXO}, {H}) -> {{U32.to_nat(len) == Nat.add(U32.to_nat({L.O(j)}), {RS[j]}) : Nat}}:')
        w.append(f'  Equal.trans(Nat, U32.to_nat(len), Nat.add(U32.to_nat({L.O(j + 1)}), {RS[j + 1]}), Nat.add(U32.to_nat({L.O(j)}), {RS[j]}), eln{j + 1}({TXOA}, h),')
        w.append(f'    Equal.trans(Nat, Nat.add(U32.to_nat({L.O(j + 1)}), {RS[j + 1]}), Nat.add(Nat.add(U32.to_nat({L.O(j)}), {Ln[j]}), {RS[j + 1]}), Nat.add(U32.to_nat({L.O(j)}), {RS[j]}),')
        w.append(f'      Equal.cong(Nat, Nat, z => Nat.add(z, {RS[j + 1]}), U32.to_nat({L.O(j + 1)}), Nat.add(U32.to_nat({L.O(j)}), {Ln[j]}), eE{j}({TXOA}, h)),')
        w.append(f'      FD.nat__add_assoc(U32.to_nat({L.O(j)}), {Ln[j]}, {RS[j + 1]})))')
    w.append(f'def elen({TXO}, {H}) -> {{U32.to_nat(len) == Nat.add({FSN}, {RS[0]}) : Nat}}:')
    w.append(f'  Equal.trans(Nat, U32.to_nat(len), Nat.add(U32.to_nat({L.O(0)}), {RS[0]}), Nat.add({FSN}, {RS[0]}), eln0({TXOA}, h),')
    w.append(f'    Equal.cong(Nat, Nat, z => Nat.add(z, {RS[0]}), U32.to_nat({L.O(0)}), {FSN}, eO0({TXOA}, h)))')
    w.append('')
    if L.sym:
        w.append(sym_header_text(L, PSV, OSL, H))
    # the window's bytes: the header words, then the children's windows
    PAYt = ''.join(f'List.append(&2, U32, {L.Y(j)}, ' for j in range(k - 1)) + L.Y(k - 1) + ')' * (k - 1)
    LHS = f'List.append(&2, U32, LY.HDRW({PSV}, {OSL}), Layout.payloads({PSV}))'
    w.append(f'def winE({CW}, {H})')
    w.append(f'    -> {{{LHS} == {WBL} : +List<U32>}}:')
    w.append(f'  +hwR = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), {PW}) == {TRUE}}}, U32.to_nat(len), Nat.add({FSN}, {RS[0]}), elen({TXOA}, h), hw)')
    inner = ''.join(f'List.append(&2, U32, {L.Y(j)}, ' for j in range(k - 1)) + '_' + ')' * (k - 1)
    w.append(f'  %Equal.sym(+List<U32>, List.append(&2, U32, {L.Y(k - 1)}, []), {L.Y(k - 1)}, VS.app_nil({L.Y(k - 1)})) :')
    w.append(f'    {{List.append(&2, U32, LY.HDRW({PSV}, {OSL}), {inner}) == {WBL} : +List<U32>}}')
    CUR = f'List.append(&2, U32, LY.HDRW({PSV}, {OSL}), {PAYt})'
    w.append(f'  %Equal.sym(Nat, U32.to_nat(len), Nat.add({FSN}, {RS[0]}), elen({TXOA}, h)) : {{{CUR} == UW.WX(t, x, _) : +List<U32>}}')
    if L.sym:
        w.append(f'  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add({FSN}, {RS[0]})), List.append(&2, U32, UW.WX(t, x, {FSN}), UW.WX(t, Nat.add(x, {FSN}), {RS[0]})),')
        w.append(f'      splitR(t, x, {FSN}, {RS[0]})) :')
        w.append(f'    {{{CUR} == _ : +List<U32>}}')
        w.append(f'  %hdrE({CWA}, h) : {{{CUR} == List.append(&2, U32, _, UW.WX(t, Nat.add(x, {FSN}), {RS[0]})) : +List<U32>}}')
        HD = f'LY.HDRW({PSV}, {OSL})'
    else:
        w.append(f'  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad({L.H}n), {RS[0]})), List.append(&2, U32, F.limbs(UR.RWS({L.H}n, t, x)), UW.WX(t, Nat.add(A.quad({L.H}n), x), {RS[0]})),')
        w.append(f'      UW.headWX(d, t, x, {L.H}n, {RS[0]}, pf, hwR)) :')
        w.append(f'    {{{CUR} == _ : +List<U32>}}')
        HD = f'F.limbs(UR.RWS({L.H}n, t, x))'

    def rhs(j, hole):
        """The right side after j splits, with `hole` in the last window."""
        pre = ''.join(f'List.append(&2, U32, {L.Y(q)}, ' for q in range(j))
        return f'List.append(&2, U32, {HD}, {pre}{hole}{")" * j})'
    if L.sym:
        w.append(f'  %Equal.cong(Nat, Nat, z => Nat.add(x, z), U32.to_nat({L.O(0)}), {FSN}, eO0({TXOA}, h)) :')
        w.append(f'    {{{CUR} == {rhs(0, f"UW.WX(t, _, {RS[0]})")} : +List<U32>}}')
        w.append(f'  %FD.nat__add_comm(U32.to_nat({L.O(0)}), x) :')
        w.append(f'    {{{CUR} == {rhs(0, f"UW.WX(t, _, {RS[0]})")} : +List<U32>}}')
    else:
        w.append(f'  %Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat({L.O(0)}), {FSN}, eO0({TXOA}, h)) :')
        w.append(f'    {{{CUR} == {rhs(0, f"UW.WX(t, _, {RS[0]})")} : +List<U32>}}')
    for j in range(k - 1):
        w.append(f'  %Equal.sym(+List<U32>, UW.WX(t, {L.XJ(j)}, {RS[j]}), List.append(&2, U32, UW.WX(t, {L.XJ(j)}, {Ln[j]}), UW.WX(t, Nat.add({Ln[j]}, {L.XJ(j)}), {RS[j + 1]})),')
        w.append(f'      UW.splitWX(t, {L.XJ(j)}, {Ln[j]}, {RS[j + 1]})) :')
        w.append(f'    {{{CUR} == {rhs(j, "_")} : +List<U32>}}')
        w.append(f'  %VRC.pnext(U32.to_nat({L.O(j)}), U32.to_nat({L.O(j + 1)}), {Ln[j]}, x, eE{j}({TXOA}, h)) :')
        w.append(f'    {{{CUR} == {rhs(j + 1, f"UW.WX(t, _, {RS[j + 1]})")} : +List<U32>}}')
    w.append('  {==}')
    w.append('')
    # the encoding of the parts
    oko = 'Unit{}'
    for j in range(k - 1, -1, -1):
        oko = f'(eq{j}({CWA}, h), {oko})'
    doms = []
    for f in L.fields:
        if f['kind'] == 'fix' and L.sym:
            doms.append((f'SP.bytes_domain(UW.WX(t, {L.pos(f["c"])}, {f["size"]}n))', f'UW.domWX(t, {L.pos(f["c"])}, {f["size"]}n)'))
        elif f['kind'] == 'fix':
            ws = ', '.join(L.nodes[f['i']]['words'])
            doms.append((f'SP.bytes_domain(F.limbs([{ws}]))', f'F.domain_limbs([{ws}])'))
        else:
            j = f['j']
            doms.append((f'SP.bytes_domain({L.Y(j)})', f'UW.domWX(t, {L.XJ(j)}, {Ln[j]})'))
    hv = '{==}'
    for i in range(nf - 1, -1, -1):
        rest = f'RST{i}(t, x, len)' if L.sym else '[' + ', '.join(parts[i + 1:]) + ']'
        hv = f'FD.logic__and_intro({doms[i][0]}, Layout.bytes_valid({rest}), {doms[i][1]},\n      {hv})'
    PL = f'Layout.payloads({PSV})'
    LPL = f'LY.LN({PL})' if L.sym else f'List.length(&2, U32, {PL})'
    w.append(f'def fitw({CW}, {H}) -> {{N.fits(4n, Nat.add({FSN}, {LPL})) == {TRUE}}}:')
    w.append(f'  FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, U32.to_nat(len), Nat.add({FSN}, {LPL}),')
    w.append(f'    Equal.trans(Nat, U32.to_nat(len), {Q[k]}, Nat.add({FSN}, {LPL}), eq{k}({CWA}, h),')
    w.append(f'      Equal.sym(Nat, Nat.add({FSN}, {LPL}), LY.END({PSV}, {FSN}), LY.lay_end({PSV}, {FSN}))),')
    w.append(f'    VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})))')
    w.append('')
    w.append(f'def encw({CW}, {H}) -> {{Layout.encoding({PSV}) == Some{{{LHS}}} : {M}}}:')
    w.append(f'  {"LY.enc_genL" if L.sym else "VMV.enc_gen"}({PSV}, {FSN}, LY.HDRW({PSV}, {OSL}), {PL}, {"efsw(" + CWA + ", h)" if L.sym else "{==}"},')
    w.append(f'    LY.hdr_fp({PSV}, {FSN}, {OSL}, {oko}), {{==}},')
    w.append(f'    {hv},')
    w.append(f'    fitw({CWA}, h))')
    w.append('')
    SV = ', +sv: S.Schema, +esv: {sv == Spec.' + L.name + '() : S.Schema}' if L.sym else ''
    w.append(f'def partsw({CW}, {HCHK}{SV}) -> {{Codec.parts({itm(0)}, {chain(0)}) == Some{{{PSV}}} : {MP}}}:')
    w.append(f'  {cat(0)}')
    w.append('')
    if L.sym:
        w.append('# The spec parts of the value at the schema sv = the spec\'s (never unfolded here).')
        w.append(f'def specg({CW}, {HCHK}{SV}) -> {{Codec.parts(VALw(t, x, len), sv) == {TGT} : {MP}}}:')
        CK = L.CK
        SHP = (f'S.Container{{SH.Container_names(sv), SH.Container_fields(sv)}}' if CK == 'Container' else
               f'S.ProgressiveContainer{{SH.ProgressiveContainer_names(sv), SH.ProgressiveContainer_fields(sv), SH.ProgressiveContainer_active(sv)}}')
        w.append(f'  %Equal.sym(S.Schema, sv, {SHP}, SH.{CK}_shape(sv, isc(sv, esv))) : {{Codec.parts(VALw(t, x, len), _) == {TGT} : {MP}}}')
        w.append(f'  %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(SH.{CK}_fields(sv)), None{{}}, fsn(sv, esv)) : {{Codec.aggregate(Codec.parts({itm(0)}, SH.{CK}_fields(sv)), _) == {TGT} : {MP}}}')
        w.append(f'  %Equal.sym(S.Schema, TL0(sv), {chain(0)}, fe0(sv, esv)) : {{Codec.aggregate(Codec.parts({itm(0)}, _), None{{}}) == {TGT} : {MP}}}')
        w.append(f'  %Equal.sym({MP}, Codec.parts({itm(0)}, {chain(0)}), Some{{{PSV}}}, partsw({CWA}, hchk, sv, esv)) : {{Codec.aggregate(_, None{{}}) == {TGT} : {MP}}}')
        w.append(f'  %Equal.sym({M}, Layout.encoding({PSV}), Some{{{LHS}}}, encw({CWA}, hchk)) : {{Codec.one(_, None{{}}) == {TGT} : {MP}}}')
        w.append(f'  %Equal.sym(+List<U32>, {LHS}, {WBL}, winE({CWA}, hchk)) : {{Codec.one(Some{{_}}, None{{}}) == {TGT} : {MP}}}')
        w.append('  {==}')
        w.append('')
        w.append('# The spec parts of the value: one variable part, the window\'s bytes.')
        w.append(f'def specw({CW}, {HCHK}) -> {{Codec.parts(VALw(t, x, len), {L.top}) == {TGT} : {MP}}}:')
        w.append(f'  specg({CWA}, hchk, {L.top}, {{==}})')
        w.append('')
        return '\n'.join(w)
    w.append('# The spec parts of the value: one variable part, the window\'s bytes.')
    w.append(f'def specw({CW}, {HCHK}) -> {{Codec.parts(VALw(t, x, len), {L.top}) == {TGT} : {MP}}}:')
    w.append(f'  %Equal.sym({MP}, Codec.parts({itm(0)}, {chain(0)}), Some{{{PSV}}}, partsw({CWA}, hchk)) : {{Codec.aggregate(_, None{{}}) == {TGT} : {MP}}}')
    w.append(f'  %Equal.sym({M}, Layout.encoding({PSV}), Some{{{LHS}}}, encw({CWA}, hchk)) : {{Codec.one(_, None{{}}) == {TGT} : {MP}}}')
    w.append(f'  %Equal.sym(+List<U32>, {LHS}, {WBL}, winE({CWA}, hchk)) : {{Codec.one(Some{{_}}, None{{}}) == {TGT} : {MP}}}')
    w.append('  {==}')
    w.append('')
    return '\n'.join(w)


# ---------------------------------------------------------------------------------------------------
# the inversion

VALUES = ['BooleanValue{+b0}', 'UnsignedValue{+u0}', 'BytesValue{+xs0}', 'BitsValue{+bs0}', 'Sequence{+it0}', 'Items{+hd0, +tl0}', 'EmptyItems{}',
          'Selected{+sel0, +sv0}', 'NullValue{}']


def inv_text(L):
    k = L.k
    FS = L.FS
    FSN = L.FSN
    nf = L.nf
    w = []

    def part(f):
        return f'S.Fixed{{xs{f["i"]}}}' if f['kind'] == 'fix' else f'S.Variable{{y{f["j"]}}}'

    def sdecl(i):
        out = []
        for f in L.fields[:i]:
            if f['kind'] == 'fix':
                s = f['size']
                if L.sym:
                    out.append(f'+xs{f["i"]}: +List<U32>, +lx{f["i"]}: LXF({s}n, xs{f["i"]})')
                else:
                    out.append(f'+xs{f["i"]}: +List<U32>, +lx{f["i"]}: {{Some{{{s}n}} == Some{{List.length(&2, U32, xs{f["i"]})}} : Maybe<&2, Nat>}}')
                if f.get('chk'):
                    out.append(f'+hx{f["i"]}: S.Value, +ex{f["i"]}: EXF(hx{f["i"]}, {L.spec(f)}, xs{f["i"]})')
            else:
                j = f['j']
                if L.sym:
                    out.append(f'+y{j}: +List<U32>, +h{j}: S.Value, +ev{j}: EVF(h{j}, {L.spec(f)}, y{j})')
                else:
                    out.append(f'+y{j}: +List<U32>, +h{j}: S.Value, +ev{j}: {{Codec.parts(h{j}, {L.spec(f)}) == Some{{[S.Variable{{y{j}}}]}} : {MP}}}')
        return ''.join(x + ', ' for x in out)

    def sargs(i):
        out = []
        for f in L.fields[:i]:
            if f['kind'] == 'fix':
                out.append(f'xs{f["i"]}, lx{f["i"]}' + (f', hx{f["i"]}, ex{f["i"]}' if f.get('chk') else ''))
            else:
                j = f['j']
                out.append(f'y{j}, h{j}, ev{j}')
        return ''.join(x + ', ' for x in out)

    def prefix0(i, inner):
        s = inner
        for f in reversed(L.fields[:i]):
            s = f'Codec.concatenate(Some{{[{part(f)}]}}, {s})'
        return s

    def pargs(i):
        return ''.join(f'xs{f["i"]}, ' if f['kind'] == 'fix' else f'y{f["j"]}, ' for f in L.fields[:i])

    def prefix(i, inner):
        return f'PFX{i}({pargs(i)}{inner})' if L.sym else prefix0(i, inner)

    def chain0(i):
        return 'S.End{}' if i == nf else f'S.Chain{{{L.spec(L.fields[i])}, {chain0(i + 1)}}}'

    def chain(i):
        return f'LCH{i}()' if L.sym else chain0(i)

    def absurd():
        return f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))'
    CP = L.sym
    PS = '[' + ', '.join(part(f) for f in L.fields) + ']'
    WS = '[' + ', '.join(f'Some{{{f["size"]}n}}' if f['kind'] == 'fix' else 'None{}' for f in L.fields) + ']'
    PLD = ''.join(f'+xs{f["i"]}: +List<U32>, ' if f['kind'] == 'fix' else f'+y{f["j"]}: +List<U32>, ' for f in L.fields)
    PLA = ''.join(f'xs{f["i"]}, ' if f['kind'] == 'fix' else f'y{f["j"]}, ' for f in L.fields)
    if CP:
        # the parts, their bytes and widths as definitions (the lemmas below take the payloads only)
        w.append(f'def PSX({PLD[:-2]}) -> +List<S.Part>: {PS}')
        PS = f'PSX({PLA[:-2]})'
        w.append(f'def BYX({PLD[:-2]}) -> +List<U32>: List.append(&2, U32, Layout.fixed_parts({PS}, Layout.fixed_size({PS})), Layout.payloads({PS}))')
        w.append(f'def EVF(+h: S.Value, +s: S.Schema, +y: +List<U32>) -> Data: {{Codec.parts(h, s) == Some{{[S.Variable{{y}}]}} : {MP}}}')
        w.append(f'def EXF(+h: S.Value, +s: S.Schema, +y: +List<U32>) -> Data: {{Codec.parts(h, s) == Some{{[S.Fixed{{y}}]}} : {MP}}}')
        w.append(f'def LXF(+s: Nat, +xs: +List<U32>) -> Data: {{Some{{s}} == Some{{List.length(&2, U32, xs)}} : Maybe<&2, Nat>}}')
        w.append('def mis(a: Maybe<&2, Nat>, +n: Nat) -> Bool:')
        w.append('  match a:')
        w.append('    case None{}: False{}')
        w.append('    case Some{v}: Nat.is_eq(v, n)')
        w.append('def eqM(+a: Maybe<&2, Nat>, +n: Nat, +e: {mis(a, n) == True{} : Bool}) -> {a == Some{n} : Maybe<&2, Nat>}:')
        w.append('  match a:')
        w.append('    case None{}: Empty.absurd({None{} == Some{n} : Maybe<&2, Nat>}, FD.logic__false_true(e))')
        w.append('    case Some{+v}: Equal.cong(Nat, Maybe<&2, Nat>, z => Some{z}, v, n, FD.nat__eq_from_is_eq(v, n, e))')
        seen = set()
        for f in L.fields:
            if f['kind'] == 'fix' and f['sk'] not in seen:
                seen.add(f['sk'])
                w.append(f'def fz{f["sk"]}() -> {{SS.fixed_size({L.spec(f)}) == Some{{{f["size"]}n}} : Maybe<&2, Nat>}}: eqM(SS.fixed_size({L.spec(f)}), {f["size"]}n, {{==}})')
        w.append(f'def LCH{nf}() -> S.Schema: S.End{{}}')
        for i in range(nf - 1, -1, -1):
            w.append(f'def LCH{i}() -> S.Schema: S.Chain{{{L.spec(L.fields[i])}, LCH{i + 1}()}}')
        for i in range(nf + 1):
            pd = ''.join(f'+xs{f["i"]}: +List<U32>, ' if f['kind'] == 'fix' else f'+y{f["j"]}: +List<U32>, ' for f in L.fields[:i])
            w.append(f'def PFX{i}({pd}+m: {MP}) -> {MP}: {prefix0(i, "m")}')
        w.append('')
        WS = 'WSS0()'
    FP = f'Layout.fixed_parts({PS}, Layout.fixed_size({PS}))'
    PL = f'Layout.payloads({PS})'
    BYTES = f'BYX({PLA[:-2]})' if CP else f'List.append(&2, U32, {FP}, {PL})'
    if CP:
        SD = f'{CW}, {PLD}+ew: {{LY.WID({PS}) == {WS} : +List<Maybe<&2, Nat>>}}, +eq: {{{BYTES} == {WBL} : +List<U32>}}'
        SA = f'{CWA}, {PLA}ew, eq'
    else:
        SD = f'{CW}, {sdecl(nf)}+eq: {{{BYTES} == {WBL} : +List<U32>}}'
        SA = f'{CWA}, {sargs(nf)}eq'
    fixed = [f for f in L.fields if f['kind'] == 'fix']
    # the widths of the parts
    LXD = ''.join(f'+lx{f["i"]}: {{Some{{{f["size"]}n}} == Some{{List.length(&2, U32, xs{f["i"]})}} : Maybe<&2, Nat>}}, ' for f in L.fields if f['kind'] == 'fix')
    LXA = ''.join(f'lx{f["i"]}, ' for f in L.fields if f['kind'] == 'fix')
    w.append(f'def ewid({PLD + LXD if CP else sdecl(nf)}+u: Unit) -> {{LY.WID({PS}) == {WS} : +List<Maybe<&2, Nat>>}}:')
    for f in fixed:
        els = []
        for g2 in L.fields:
            if g2['kind'] == 'var':
                els.append('None{}')
            elif g2['i'] < f['i']:
                els.append(f'Some{{{g2["size"]}n}}')
            elif g2['i'] == f['i']:
                els.append('_')
            else:
                els.append(f'Some{{List.length(&2, U32, xs{g2["i"]})}}')
        w.append(f'  %lx{f["i"]} : {{[{", ".join(els)}] == {WS} : +List<Maybe<&2, Nat>>}}')
    w.append('  {==}')
    w.append('')
    EW = 'ew' if CP else f'ewid({sargs(nf)}Unit{{}})'
    w.append(f'def efs({SD}) -> {{Layout.fixed_size({PS}) == {FSN} : Nat}}:')
    if CP:
        w.append(f'  Equal.trans(Nat, Layout.fixed_size({PS}), LY.WFS({WS}), {FSN}, Equal.trans(Nat, Layout.fixed_size({PS}), LY.WFS(LY.WID({PS})), LY.WFS({WS}), LY.fs_w({PS}),')
        w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WFS(z), LY.WID({PS}), {WS}, {EW})), wf0())')
    else:
        w.append(f'  Equal.trans(Nat, Layout.fixed_size({PS}), LY.WFS(LY.WID({PS})), {FSN}, LY.fs_w({PS}),')
        w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WFS(z), LY.WID({PS}), {WS}, {EW}))')
    w.append('')
    END = f'LY.END({PS}, {FSN})'
    LPL = f'LY.LN({PL})' if CP else f'List.length(&2, U32, {PL})'
    w.append(f'def eL({SD}) -> {{U32.to_nat(len) == {END} : Nat}}:')
    w.append(f'  +FPt = {FP}')
    w.append(f'  +lenB = Equal.trans(Nat, List.length(&2, U32, {BYTES}), Nat.add(List.length(&2, U32, FPt), {LPL}), {END}, VS.len_app(FPt, {PL}),')
    w.append(f'    Equal.trans(Nat, Nat.add(List.length(&2, U32, FPt), {LPL}), Nat.add({FSN}, {LPL}), {END},')
    w.append(f'      Equal.cong(Nat, Nat, z => Nat.add(z, {LPL}), List.length(&2, U32, FPt), {FSN},')
    w.append(f'        Equal.trans(Nat, List.length(&2, U32, FPt), Layout.fixed_size({PS}), {FSN}, LY.lay_len({PS}, Layout.fixed_size({PS})), efs({SA}))),')
    w.append(f'      LY.lay_end({PS}, {FSN})))')
    w.append(f'  Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, {WBL}), {END}, Equal.sym(Nat, List.length(&2, U32, {WBL}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),')
    w.append(f'    Equal.trans(Nat, List.length(&2, U32, {WBL}), List.length(&2, U32, {BYTES}), {END},')
    w.append(f'      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), {WBL}, {BYTES}, Equal.sym(+List<U32>, {BYTES}, {WBL}, eq)), lenB))')
    w.append('')
    if CP:
        w.append(f'def offz({PLD}+o: Nat) -> {{LY.OFF({PS}, {L.vars[0]["i"]}n, o) == o : Nat}}: {{==}}')
    OFFS = []
    for f in L.vars:
        j = f['j']
        i = f['i']
        c = f['c']
        OFF = f'LY.OFF({PS}, {i}n, {FSN})'
        OFFS.append(OFF)
        w.append(f'def epos{j}({PLD + "+ew: {LY.WID(" + PS + ") == " + WS + " : +List<Maybe<&2, Nat>>}" if CP else sdecl(nf) + "+u: Unit"}) -> {{LY.FPOS({PS}, {i}n) == {L.PN(c)} : Nat}}:')
        if CP:
            w.append(f'  Equal.trans(Nat, LY.FPOS({PS}, {i}n), LY.WPOS({WS}, {i}n), {L.PN(c)}, Equal.trans(Nat, LY.FPOS({PS}, {i}n), LY.WPOS(LY.WID({PS}), {i}n), LY.WPOS({WS}, {i}n), LY.fpos_w({PS}, {i}n),')
            w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WPOS(z, {i}n), LY.WID({PS}), {WS}, {EW})), wp{i}_0())')
        else:
            w.append(f'  Equal.trans(Nat, LY.FPOS({PS}, {i}n), LY.WPOS(LY.WID({PS}), {i}n), {c}n, LY.fpos_w({PS}, {i}n),')
            w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WPOS(z, {i}n), LY.WID({PS}), {WS}, {EW}))')
        w.append(f'def eb{j}({SD}) -> {{VS.bt(4n, VS.bdr({L.PN(c)}, {WBL})) == N.digits(4n, {OFF}) : +List<U32>}}:')
        w.append(f'  %eq : {{VS.bt(4n, VS.bdr({L.PN(c)}, _)) == N.digits(4n, {OFF}) : +List<U32>}}')
        w.append(f'  %efs({SA}) : {{VS.bt(4n, VS.bdr({L.PN(c)}, {BYTES})) == N.digits(4n, LY.OFF({PS}, {i}n, _)) : +List<U32>}}')
        w.append(f'  %epos{j}({PLA + "ew" if CP else sargs(nf) + "Unit{}"}) : {{VS.bt(4n, VS.bdr(_, {BYTES})) == N.digits(4n, LY.OFF({PS}, {i}n, Layout.fixed_size({PS}))) : +List<U32>}}')
        w.append(f'  LY.lay_off({PS}, Layout.fixed_size({PS}), {i}n, y{j}, {PL}, {{==}})')
        RF = FS - c - 4
        w.append(f'def ov{j}({SD}) -> {{U32.to_nat({L.O(j)}) == {OFF} : Nat}}:')
        if L.sym:
            HFS = f'FD.logic__subst(Nat, z => {{Nat.is_le({FSN}, z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), LY.end_ge({PS}, {FSN}))'
            w.append(f'  offwX({CWA}, {L.PN(c)}, {OFF}, FD.nat__le_trans(Nat.add({L.PN(c)}, 4n), {FSN}, U32.to_nat(len), {L.LEA(c, 4)}, {HFS}),')
            w.append(f'    FD.logic__subst(Nat, z => {{Nat.is_le({OFF}, z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), LY.off_le({PS}, {i}n, {FSN})),')
            w.append(f'    eb{j}({SA}))')
            continue
        w.append(f'  +eL2 = Equal.trans(Nat, U32.to_nat(len), {END}, Nat.add({FSN}, List.length(&2, U32, {PL})), eL({SA}), Equal.sym(Nat, Nat.add({FSN}, List.length(&2, U32, {PL})), {END}, LY.lay_end({PS}, {FSN})))')
        w.append(f'  offw({CWA}, {c}n, Nat.add({RF}n, List.length(&2, U32, {PL})), {OFF}, eL2,')
        w.append(f'    FD.logic__subst(Nat, z => {{Nat.is_le({OFF}, z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), LY.off_le({PS}, {i}n, {FSN})),')
        w.append(f'    eb{j}({SA}))')
    w.append('')
    for f in L.vars:
        j = f['j']
        i = f['i']
        OFF = OFFS[j]
        ly = f'LY.LN(y{j})' if CP else f'List.length(&2, U32, y{j})'
        E = L.E(j)
        ovE = f'ov{j + 1}({SA})' if j + 1 < k else f'eL({SA})'
        OFFE = OFFS[j + 1] if j + 1 < k else END
        w.append(f'def el{j}({SD}) -> {{U32.to_nat({L.LJ(j)}) == {ly} : Nat}}: VMR.subL({E}, {L.O(j)}, {OFF}, {ly}, ov{j}({SA}), {ovE})')
        w.append(f'def nle{j}({SD}) -> {{Nat.is_le(U32.to_nat({L.O(j)}), U32.to_nat({E})) == {TRUE}}}:')
        w.append(f'  FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat({E})) == {TRUE}}}, {OFF}, U32.to_nat({L.O(j)}), Equal.sym(Nat, U32.to_nat({L.O(j)}), {OFF}, ov{j}({SA})),')
        w.append(f'    FD.logic__subst(Nat, z => {{Nat.is_le({OFF}, z) == {TRUE}}}, Nat.add({OFF}, {ly}), U32.to_nat({E}), Equal.sym(Nat, U32.to_nat({E}), Nat.add({OFF}, {ly}), {ovE}),')
        w.append(f'      FD.nat__le_add_right({OFF}, {ly})))')
        if j + 1 < k:
            i2 = L.vars[j + 1]['i']
            w.append(f'def nle2{j}({SD}) -> {{Nat.is_le(U32.to_nat({E}), U32.to_nat(len)) == {TRUE}}}:')
            w.append(f'  FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == {TRUE}}}, {OFFE}, U32.to_nat({E}), Equal.sym(Nat, U32.to_nat({E}), {OFFE}, {ovE}),')
            w.append(f'    FD.logic__subst(Nat, z => {{Nat.is_le({OFFE}, z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), LY.off_le({PS}, {i2}n, {FSN})))')
            bnd = f'LY.off_le({PS}, {i2}n, o)'
        else:
            w.append(f'def nle2{j}({SD}) -> {{Nat.is_le(U32.to_nat(len), U32.to_nat(len)) == {TRUE}}}: Order.reflexive(U32.to_nat(len))')
            bnd = f'FD.nat__le_refl(LY.END({PS}, o))'
        if CP:
            # the payload's bound, for a symbolic fixed size o (at the literal the two sides are equal only by evaluation)
            OFFo = f'LY.OFF({PS}, {i}n, o)'
            w.append(f'def bnd{j}({PLD}+o: Nat) -> {{Nat.is_le(Nat.add({OFFo}, {ly}), LY.END({PS}, o)) == {TRUE}}}: {bnd}')
            bnd = f'bnd{j}({PLA}{FSN})'
        else:
            bnd = bnd.replace(', o)', f', {FSN})')
        hl = (f'FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({OFF}, {ly}), z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), '
              f'{bnd})')
        w.append(f'def ypay{j}({SD}) -> {{{L.Y(j)} == y{j} : +List<U32>}}:')
        w.append(f'  %Equal.sym(Nat, U32.to_nat({L.LJ(j)}), {ly}, el{j}({SA})) : {{UW.WX(t, {L.XJ(j)}, _) == y{j} : +List<U32>}}')
        w.append(f'  %Equal.sym(Nat, U32.to_nat({L.O(j)}), {OFF}, ov{j}({SA})) : {{UW.WX(t, Nat.add(_, x), {ly}) == y{j} : +List<U32>}}')
        w.append(f'  %UW.subWX(t, x, {OFF}, {ly}, U32.to_nat(len), {hl}) : {{_ == y{j} : +List<U32>}}')
        w.append(f'  %eq : {{VS.bt({ly}, VS.bdr({OFF}, _)) == y{j} : +List<U32>}}')
        w.append(f'  %efs({SA}) : {{VS.bt({ly}, VS.bdr(LY.OFF({PS}, {i}n, _), {BYTES})) == y{j} : +List<U32>}}')
        w.append(f'  LY.lay_pay({PS}, {i}n, y{j}, Layout.fixed_size({PS}), {FP}, LY.lay_len({PS}, Layout.fixed_size({PS})), {{==}})')
        w.append(f'def dch{j}({SD}{", +h" + str(j) + ": S.Value, +ev" + str(j) + ": EVF(h" + str(j) + ", " + L.spec(f) + ", y" + str(j) + ")" if CP else ""}) -> {{CH{j}.CHKw(t, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)}) == {TRUE}}}:')
        w.append(f'  CH{j}.invw(d, t, n, {L.XJ(j)}, {L.FJ(j)}, {L.LJ(j)}, eoW({CWA}, {L.O(j)}, {E}, nle{j}({SA}), nle2{j}({SA})), hd,')
        w.append(f'    hwj({CWA}, {L.O(j)}, {E}, nle{j}({SA}), nle2{j}({SA})), pf, h{j},')
        w.append(f'    FD.logic__subst(+List<U32>, z => {{Codec.parts(h{j}, {L.spec(f)}) == Some{{[S.Variable{{z}}]}} : {MP}}}, y{j}, {L.Y(j)}, Equal.sym(+List<U32>, {L.Y(j)}, y{j}, ypay{j}({SA})), ev{j}))')
    w.append('')
    for f in L.fchk:
        i, c, sz, P = f['i'], f['c'], f['size'], L.pos(f['c'])
        w.append(f'def eposF{i}({PLD + "+ew: {LY.WID(" + PS + ") == " + WS + " : +List<Maybe<&2, Nat>>}" if CP else sdecl(nf) + "+u: Unit"}) -> {{LY.FPOS({PS}, {i}n) == {L.PN(c)} : Nat}}:')
        if CP:
            w.append(f'  Equal.trans(Nat, LY.FPOS({PS}, {i}n), LY.WPOS({WS}, {i}n), {L.PN(c)}, Equal.trans(Nat, LY.FPOS({PS}, {i}n), LY.WPOS(LY.WID({PS}), {i}n), LY.WPOS({WS}, {i}n), LY.fpos_w({PS}, {i}n),')
            w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WPOS(z, {i}n), LY.WID({PS}), {WS}, {EW})), wp{i}_0())')
        else:
            w.append(f'  Equal.trans(Nat, LY.FPOS({PS}, {i}n), LY.WPOS(LY.WID({PS}), {i}n), {c}n, LY.fpos_w({PS}, {i}n),')
            w.append(f'    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WPOS(z, {i}n), LY.WID({PS}), {WS}, {EW}))')
        w.append(f'def fx{i}({SD}{", +lx" + str(i) + ": {Some{" + str(sz) + "n} == Some{List.length(&2, U32, xs" + str(i) + ")} : Maybe<&2, Nat>}" if CP else ""}) -> {{UW.WX(t, {P}, {sz}n) == xs{i} : +List<U32>}}:')
        w.append(f'  +hl = FD.nat__le_trans(Nat.add({L.PN(c)}, {sz}n), {FSN}, U32.to_nat(len), {L.LEA(c, sz)},')
        w.append(f'    FD.logic__subst(Nat, z => {{Nat.is_le({FSN}, z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), LY.end_ge({PS}, {FSN})))')
        w.append(f'  %{"subX" if L.sym else "UW.subWX"}(t, x, {L.PN(c)}, {sz}n, U32.to_nat(len), hl) : {{_ == xs{i} : +List<U32>}}')
        w.append(f'  %eq : {{VS.bt({sz}n, VS.bdr({L.PN(c)}, _)) == xs{i} : +List<U32>}}')
        w.append(f'  %eposF{i}({PLA + "ew" if CP else sargs(nf) + "Unit{}"}) : {{VS.bt({sz}n, VS.bdr(_, {BYTES})) == xs{i} : +List<U32>}}')
        w.append(f'  %Equal.sym(Nat, {sz}n, List.length(&2, U32, xs{i}), LY.mnat({sz}n, List.length(&2, U32, xs{i}), lx{i})) : {{VS.bt(_, VS.bdr(LY.FPOS({PS}, {i}n), {BYTES})) == xs{i} : +List<U32>}}')
        w.append(f'  LY.lay_fix({PS}, Layout.fixed_size({PS}), {i}n, xs{i}, {PL}, {{==}})')
        w.append(f'def fch{i}({SD}{", +lx" + str(i) + ": {Some{" + str(sz) + "n} == Some{List.length(&2, U32, xs" + str(i) + ")} : Maybe<&2, Nat>}, +hx" + str(i) + ": S.Value, +ex" + str(i) + ": {Codec.parts(hx" + str(i) + ", " + L.spec(f) + ") == Some{[S.Fixed{xs" + str(i) + "}]} : " + MP + "}" if CP else ""}) -> {{{f["fa"]}.CHK(t, {P}) == {TRUE}}}:')
        w.append(f'  {f["fa"]}.inv(t, {P}, hx{i}, FD.logic__subst(+List<U32>, z => {{Codec.parts(hx{i}, {L.spec(f)}) == Some{{[S.Fixed{{z}}]}} : {MP}}}, xs{i}, UW.WX(t, {P}, {sz}n),')
        w.append(f'    Equal.sym(+List<U32>, UW.WX(t, {P}, {sz}n), xs{i}, fx{i}({SA}{", lx" + str(i) if CP else ""})), ex{i}))')
    if L.fchk:
        w.append('')
    its = items(L)
    h0 = f'FD.logic__subst(Nat, z => {{Nat.is_le({FSN}, z) == {TRUE}}}, {END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), {END}, eL({SA})), LY.end_ge({PS}, {FSN}))'
    o0 = f'ov0({SA})'
    if CP:
        o0 = f'Equal.trans(Nat, U32.to_nat({L.O(0)}), {OFFS[0]}, {FSN}, {o0}, offz({PLA}{FSN}))'
    prfs = [f'VMR.u32le({FS}, len, {h0})',
            f'FD.u32alg__eq_true({L.O(0)}, {FS}, FD.u32__injective({L.O(0)}, {FS}, {o0}))']
    for j in range(1, k):
        prfs.append(f'FD.logic__and_intro(U32.is_le({L.O(j - 1)}, {L.O(j)}), U32.is_le({L.O(j)}, len), VMR.u32le({L.O(j - 1)}, {L.O(j)}, nle{j - 1}({SA})), VMR.u32le({L.O(j)}, len, nle2{j - 1}({SA})))')
    for f in L.fchk:
        prfs.append(f'fch{f["i"]}({SA}' + (f', lx{f["i"]}, hx{f["i"]}, ex{f["i"]})' if CP else ')'))
    for j in range(k):
        prfs.append(f'dch{j}({SA}' + (f', h{j}, ev{j})' if CP else ')'))
    n = len(its)
    body = prfs[n - 1]
    for m in range(n - 2, -1, -1):
        body = f'FD.logic__and_intro(IT{m}({TXOA}), K{m + 1}({TXOA}), {prfs[m]},\n    {body})'
    if CP:
        w.append(f'def contra({CW}, {sdecl(nf)}+eq: {{{BYTES} == {WBL} : +List<U32>}}) -> {GOAL}:')
        w.append(f'  +ew = ewid({PLA}{LXA}Unit{{}})')
    else:
        w.append(f'def contra({SD}) -> {GOAL}:')
    w.append(f'  {body}')
    w.append('')
    bexpr = f'Bool.and(Layout.bytes_valid({PS}), N.fits(4n, Nat.add(Layout.fixed_size({PS}), List.length(&2, U32, {PL}))))'
    w.append(f'def fin({CW}, {sdecl(nf)}+b: Bool, +e: {{Codec.one(SP.optional(b, {BYTES}), None{{}}) == {TGT} : {MP}}}) -> {GOAL}:')
    w.append('  match b:')
    w.append(f'    case False{{}}: {absurd()}')
    w.append(f'    case True{{}}: contra({CWA}, {sargs(nf)}var_inj({BYTES}, {WBL}, e))')
    w.append('')

    def match_items(var, keep, body):
        out = [f'  match {var}:']
        for v in VALUES:
            nm = v.split('{')[0]
            if nm == keep:
                out.append(f'    case {body[0]}: {body[1]}')
            else:
                out.append(f'    case S.{v}: {absurd()}')
        return out
    for i in range(nf, -1, -1):
        if i == nf:
            e_ty = f'{{Codec.aggregate({prefix(i, "Codec.parts(items, S.End{})")}, None{{}}) == {TGT} : {MP}}}'
            w.append(f'def st{i}({CW}, {sdecl(i)}+items: S.Value, +e: {e_ty}) -> {GOAL}:')
            w.extend(match_items('items', 'EmptyItems', ('S.EmptyItems{}', f'fin({CWA}, {sargs(i)}{bexpr}, e)')))
            w.append('')
            continue
        f = L.fields[i]
        sp = L.spec(f)
        if f['kind'] == 'fix':
            wd = f'Some{{{f["size"]}n}}'
            fact = f'DS.facts(h, {sp}, {{==}})'
            if CP:
                fact = f'FD.logic__subst(Maybe<&2, Nat>, z => DF.single_result(z, Codec.parts(h, {sp})), SS.fixed_size({sp}), {wd}, fz{f["sk"]}(), {fact})'
        else:
            wd = 'None{}'
            if L.generic:
                mc = re.fullmatch(r'S\.Container\{(\[.*?\]), (.*)\}', sp)
                ml = re.fullmatch(r'S\.ListOf\{(.*)\}', sp)
                if mc:
                    fact = f'UW.vsingle(h, {mc.group(1)}, {mc.group(2)}, {{==}})'
                elif ml:
                    e_, n_ = split_top(ml.group(1))
                    fact = f'LY.lsingle(h, {e_}, {n_})'
                else:
                    fact = f'DS.facts(h, {sp}, {{==}})'
            else:
                body = L.defs[f['sk']]
                mc = re.fullmatch(r'T\.Container\{(\[.*?\]), (.*)\}', body)
                ml = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', body)
            if L.generic:
                pass
            elif mc:
                flds = re.sub(r'\bSchema(\d+)\(\)', r'Spec.Schema\1()', mc.group(2)).replace('T.', 'S.')
                fact = f'UW.vsingle(h, {mc.group(1)}, {flds}, {{==}})'
            else:
                assert ml, body
                fact = f'LY.lsingle(h, Spec.{ml.group(1)}(), {ml.group(2)})'
        e_fp = f'{{Codec.aggregate({prefix(i, f"Codec.concatenate(Some{{ps}}, Codec.parts(r, {chain(i + 1)}))")}, None{{}}) == {TGT} : {MP}}}'
        w.append(f'def fp{i}({CW}, {sdecl(i)}+h: S.Value, +ps: +List<S.Part>, hf: DF.single({wd}, ps), +em: {{Codec.parts(h, {sp}) == Some{{ps}} : {MP}}}, +r: S.Value,')
        w.append(f'    +e: {e_fp}) -> {GOAL}:')
        w.append('  match ps:')
        w.append(f'    case Nil{{}}: Empty.absurd({GOAL}, hf)')
        if f['kind'] == 'fix':
            w.append(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: st{i + 1}({CWA}, {sargs(i)}xs, hf, {"h, em, " if f.get("chk") else ""}r, e)')
            w.append(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, {f["size"]}n, Equal.sym(Maybe<&2, Nat>, {wd}, None{{}}, hf)))')
        else:
            w.append(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
            w.append(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{i + 1}({CWA}, {sargs(i)}ys, h, em, r, e)')
        w.append(f'    case Con{{S.Fixed{{+xs}}, Con{{+a, +b}}}}: Empty.absurd({GOAL}, hf)')
        w.append(f'    case Con{{S.Variable{{+xs}}, Con{{+a, +b}}}}: Empty.absurd({GOAL}, hf)')
        w.append('')
        e_fm = f'{{Codec.aggregate({prefix(i, f"Codec.concatenate(mm, Codec.parts(r, {chain(i + 1)}))")}, None{{}}) == {TGT} : {MP}}}'
        w.append(f'def fm{i}({CW}, {sdecl(i)}+h: S.Value, +mm: {MP}, hf: DF.single_result({wd}, mm), +em: {{Codec.parts(h, {sp}) == mm : {MP}}}, +r: S.Value,')
        w.append(f'    +e: {e_fm}) -> {GOAL}:')
        w.append('  match mm:')
        w.append(f'    case None{{}}: {absurd()}')
        w.append(f'    case Some{{+ps}}: fp{i}({CWA}, {sargs(i)}h, ps, hf, em, r, e)')
        w.append('')
        e_st = f'{{Codec.aggregate({prefix(i, f"Codec.parts(items, {chain(i)})")}, None{{}}) == {TGT} : {MP}}}'
        w.append(f'def st{i}({CW}, {sdecl(i)}+items: S.Value, +e: {e_st}) -> {GOAL}:')
        w.extend(match_items('items', 'Items', ('S.Items{+h, +r}', f'fm{i}({CWA}, {sargs(i)}h, Codec.parts(h, {sp}), {fact}, {{==}}, r, e)')))
        w.append('')
    w.append('# Every value whose parts are the window\'s bytes passes the checks.')
    w.append(f'def invw({CW}, +v: S.Value, +e: {{Codec.parts(v, {L.top}) == {TGT} : {MP}}}) -> {GOAL}:')
    w.extend(match_items('v', 'Sequence', ('S.Sequence{+items}', f'st0({CWA}, items, e)')))
    w.append('')
    return '\n'.join(w)


def module_text(L):
    head0 = W.HEADX
    if L.generic:
        head0 = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T') for x in head0] + ['import ./generic_specs.bend as GS']
    imps = head0 + ['import ../../src/primitives.bend as I', 'import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', 'import ./vua_lay.bend as LY',
                      'import ./vmv.bend as VMV', 'import ./vdig.bend as VG', 'import ./vmr.bend as VMR', 'import ./vmul.bend as VM', 'import ./vrc.bend as VRC',
                      'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF']
    for f in L.vars:
        imps.append(f'import ./{f["mod"]} as CH{f["j"]}')
    if L.sym:
        imps += ['import ../../spec/schema.bend as SS', 'import ./vadd.bend as VA', './schema_shapes.bend']
        imps[-1] = 'import ./schema_shapes.bend as SH'
        for a, m in sorted(L.fmods().items()):
            imps.append(f'import ./{m} as {a}')
    head = imps + ['', '# GENERATED by codegen/var_winb.py. Do not edit.',
                   f'# {L.name} at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    body = (defs_text(L) + common_text(L) + OFFW.replace('@CWA', CWA).replace('@CW', CW)
            + (SYMX.replace('@CWA', CWA).replace('@CW', CW).replace('@FSn', L.FSN) + EUDEFS(L) if L.sym else '') + facts_text(L) + validator_text(L) + reader_text(L)
            + spec_text(L) + inv_text(L))
    return '\n'.join(head) + W.COMMONX + '\n' + body


def top_text(L, wmod):
    """The whole-buffer decoder laws of the container: its window at x = 0, off = 0, len = n
    (after codegen/var_rlist_er.py's top_text)."""
    import var_rlist_er as ER
    import var_rlist as RL
    X = L.name
    txt = ER.top_text(RL.HEAD)
    txt = txt.replace('import ./var_winx_ExecutionRequests.bend as EW', f'import ./{wmod} as EW')
    txt = txt.replace('# GENERATED by codegen/var_rlist.py (codegen/var_rlist_er.py). Do not edit.', '# GENERATED by codegen/var_winb.py. Do not edit.')
    txt = txt.replace('ExecutionRequests', X)
    # the value's one variable part, without evaluating the schema's legality
    body = W.spec_defs()[X] if not W.spec_defs()[X].endswith('()') else W.spec_defs()[W.spec_defs()[X][:-2]]
    mc = re.fullmatch(r'T\.Container\{(\[.*?\]), (.*)\}', body)
    flds = re.sub(r'\bSchema(\d+)\(\)', r'Spec.Schema\1()', mc.group(2)).replace('T.', 'S.')
    old = f'DS.facts(v, Spec.{X}(), {{==}})'
    assert old in txt
    txt = txt.replace(old, f'UW.vsingle(v, {mc.group(1)}, {flds}, {{==}})')
    return txt


def layout(name, sym=False, fixmod=None, generic=False):
    if generic:
        import generic as GN
        names = {n: t for n, t, err in GN.inventory_all() if err is None}
    else:
        names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    return Layout(name, g, names, sym, fixmod, generic)


def main():
    if '--test-sym' in sys.argv:
        # a container whose fixed fields are read by the modules given as prefix=module pairs
        a = sys.argv.index('--test-sym')
        name, out = sys.argv[a + 1], sys.argv[a + 2]
        fm = dict(kv.split('=') for kv in sys.argv[a + 3].split(','))
        Path(out).write_text(module_text(layout(name, True, fm)))
        print('wrote ' + out)
        return
    if '--test' in sys.argv:
        a = sys.argv.index('--test')
        name, out = sys.argv[a + 1], sys.argv[a + 2]
        Path(out).write_text(module_text(layout(name)))
        print('wrote ' + out)
        return
    no_big = '--no-big' in sys.argv
    out = {}
    for name, fn, sym in MODULES:
        if no_big and fn.startswith('big_'):
            continue
        if name in PENDING and '--pending' not in sys.argv:
            continue
        L = layout(name, sym, FIXMOD)
        # a container is generated once all its children's (and fixed fields') modules exist
        mods = [f['mod'] for f in L.vars] + sorted(set(L.fmods().values()))
        missing = [m for m in mods if not (ROOT / 'proofs/obj' / m).exists() and ROOT / 'proofs/obj' / m not in out]
        if missing:
            print(f'{fn}: waits for ' + ', '.join(missing))
            continue
        out[ROOT / 'proofs/obj' / fn] = module_text(L)
        out[ROOT / 'proofs/obj' / f'big_var_codec_{name}.bend'] = top_text(L, fn)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale generated container windows: ' + ', '.join(stale))
            sys.exit(1)
        print('generated container windows are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
