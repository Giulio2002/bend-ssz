#!/usr/bin/env python3
"""Encoder windows of variable-size CONTAINERS at any byte position X = 4 q + r.

    python3 codegen/var_cont_enc.py [--check] [--no-big]

For each container C of CONTS, proofs/obj/big_encx_<C>.bend (generated):

  the object OBJ, built from its fields' objects (Data leaves) and its children's mirrors
  (the encoder windows' own: big_encx_bl32's MW, the transactions list's (t, N), a record
  list's (A, N), a fixed byte vector's tree);
  M<k>                    the output tree after the k-th write of the runtime's put chain
                          (codegen/generate.py's emit_fieldset / emit_wide order: per group,
                          its checked writers `putk` and variable fields `putv` (offset word,
                          then the child), then its Data fields, innermost first);
  rt_<g>, rt_C            the runtime's chain, from each write's fact (cong steps);
  putx                    DK.P2( T.C_putn(thaw D, X, OBJ) == (thaw PUTC, (OBJ, SZC)),
                                 DK.P2( BYT(PUTC) == SPL(BYT D, 4 q + r, AP(ENCC, ZB(PADB(r, L)))),
                                        PUTC perfect ) )
                          when the L + PADB(r, L) bytes at X are zero, the L bytes fit the tree,
                          and the children's objects are valid.

The bytes follow the container's region as a list of pieces (proofs/obj/vcont.bend): its fixed
fields and offsets in byte order, its variable fields, the trailing zeros; each write turns one
zero piece into its bytes (reg_put / reg_putc), and each writer's zero window comes from the
pieces not yet written (reg_zero). Positions: vrecx.fpos/froom for the fixed part, vcont.vpos /
croom / padfit / cnext for the variable part (the running cursor).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))

import generate as G  # noqa: E402
import schema  # noqa: E402

CONTS = ['ExecutionPayload', 'ExecutionPayloadHeader']
TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'
GROUP = G.GROUP


def out_file(C):
    return ROOT / f'proofs/obj/big_encx_{C}.bend'


# ---- leaves -----------------------------------------------------------------------------------------

class Leaf:
    """A Data leaf written at any X by its dispatch lemma (vuwd, vuwv_<p>)."""

    def __init__(self, p, ctor, W, mod, model, rt, by, pf, rt_hz, rec=None):
        self.p, self.ctor, self.W, self.mod = p, ctor, W, mod
        self.model, self.rt, self.by, self.pf, self.rt_hz = model, rt, by, pf, rt_hz
        self.rec = rec    # a fixed record of codegen/var_rec_enc.py's RECS: its field tree (var_laws.FT)


# the fixed records written by codegen/var_rec_enc.py (proofs/obj/encx_recs.bend), by name: their field trees
_RECFT = None


def rec_ft(n):
    global _RECFT
    if _RECFT is None:
        import var_rec_enc as VRE
        g, names = VRE.layout()
        _RECFT = {m: ft for m, ft in VRE.order(g, names, VRE.RECS)}
    return _RECFT.get(n)


# the packed byte vectors of fixed size written like the fixwords (codegen/var_uwv.py's FWORDS: vuwv_<p>)
FIXW_PACKED = ('v4_b32', 'v6_b32', 'v7_b32')


def is_fixw(fs):
    return fs.fixed and (fs.kind == 'fixwords' or (fs.kind == 'packed' and fs.p in FIXW_PACKED))


def leaf_of(fs):
    if fs.kind == 'u64':
        return Leaf('u64', 'O.U64', 2, None, 'WD.W64X', 'WD.w64_any', 'WD.w64_any_bytes', 'WD.w64x_perfect', False)
    if fs.p == 'b20':
        return Leaf('b20', 'T.Bytes20', 5, None, 'WD.B20X', 'WD.b20_any', 'WD.b20_any_bytes', 'WD.b20x_perfect', True)
    if fs.p in ('b32', 'u256', 'b48', 'b96', 'bv512', 'bv64'):
        a = f'V_{fs.p}'
        return Leaf(fs.p, f'T.{fs.rep}', fs.fsize // 4, f'import ./vuwv_{fs.p}.bend as {a}', f'{a}.PX_{fs.p}', f'{a}.{fs.p}_any',
                    f'{a}.{fs.p}_any_bytes', f'{a}.{fs.p}x_perfect', True)
    if fs.kind == 'container' and rec_ft(fs.p) is not None:
        return Leaf(fs.p, f'T.{fs.p}', fs.fsize // 4, 'import ./encx_recs.bend as ER', f'ER.PX_{fs.p}', f'ER.putx_{fs.p}', None,
                    f'ER.pf_{fs.p}', True, rec=rec_ft(fs.p))
    raise SystemExit(f'no leaf writer for {fs.kind}/{fs.p}')


def rec_leaf_text(lf):
    """A fixed record's writer on the object: nested matches exposing its words, then encx_recs' lemmas."""
    import var_rlist_enc as EN
    p = lf.p
    words = []
    ls, ind = EN.nest(lf.rec, 'o', words, 2)
    body = '\n'.join(ls)
    pad = ' ' * ind
    WA = ', '.join(words)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * lf.W
    return f'''
# ---- {p}: its writer on the object (the record's words; proofs/obj/encx_recs.bend) ----
def RW_{p}(o: {lf.ctor}) -> List<&2, U32>:
{body}
{pad}[{WA}]
def PXo_{p}(o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
{body}
{pad}ER.PX_{p}({WA}, dd, D, q, r)
def pfo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PXo_{p}(o, dd, D, q, r)) == {TRUE}}}:
{body}
{pad}ER.pf_{p}({WA}, dd, D, q, r, pf)
def RTo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_{p}(o, dd, D, q, r)) : Array<U32>}}
def BYo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PXo_{p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, FX.limbs(RW_{p}(o))) : +List<U32>}}
def putxo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {B}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({B}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({B}n) : +List<U32>}})
    -> DK.P2(RTo_{p}(o, dd, D, X, q, r), BYo_{p}(o, dd, D, q, r)):
{body}
{pad}ER.putx_{p}({WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
def lenb_{p}(+o: {lf.ctor}) -> {{VCN.LN(FX.limbs(RW_{p}(o))) == {B}n : Nat}}:
{body}
{pad}{{==}}
'''


def leaf_text(lf):
    if lf.rec is not None:
        return rec_leaf_text(lf)
    p, W = lf.p, lf.W
    ws = [f'w{i}' for i in range(W)]
    pat = f'{lf.ctor}{{' + ', '.join('+' + w for w in ws) + '}'
    WA = ', '.join(ws)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * W
    hz = ', hz' if lf.rt_hz else ''
    return f'''
# ---- {p}: its writer on the object ----
def RW_{p}(o: {lf.ctor}) -> List<&2, U32>:
  match o:
    case {pat}: [{WA}]
def PXo_{p}(o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
  match o:
    case {pat}: {lf.model}(r, dd, D, q, {WA})
def pfo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PXo_{p}(o, dd, D, q, r)) == {TRUE}}}:
  match o:
    case {pat}: {lf.pf}(r, dd, D, q, {WA}, pf)
def RTo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_{p}(o, dd, D, q, r)) : Array<U32>}}
def BYo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PXo_{p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, FX.limbs(RW_{p}(o))) : +List<U32>}}
def putxo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {B}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({B}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({B}n) : +List<U32>}})
    -> DK.P2(RTo_{p}(o, dd, D, X, q, r), BYo_{p}(o, dd, D, q, r)):
  match o:
    case {pat}: ({lf.rt}(dd, D, X, q, r, {WA}, e, hr, hd, hl, pf{hz}), {lf.by}(dd, D, X, q, r, {WA}, e, hr, hd, hl, pf, hz))
def lenb_{p}(+o: {lf.ctor}) -> {{VCN.LN(FX.limbs(RW_{p}(o))) == {B}n : Nat}}:
  match o:
    case {pat}: {{==}}
'''


# ---- children (variable fields) -----------------------------------------------------------------------

class Child:
    """A variable field's encoder window, adapted: its mirror parameters and facts, object, bytes,
    byte count, writer model and laws, returned size."""

    def __init__(self, f, fs):
        self.f, self.fs, self.p = f, fs, fs.p
        if fs.kind == 'bytelist' and fs.p == 'bl32':
            m = f'm_{f}'
            self.mod = 'import ./big_encx_bl32.bend as EB'
            self.params = [f'+{m}: EB.MW']
            self.hyps = [f'+hok_{f}: {{EB.OK({m}) == {TRUE}}}']
            self.oargs = [m]
            self.hargs = [f'hok_{f}']
            self.obj = f'EB.TH({m})'
            self.vt = 'O.Words'
            self.enc = f'EB.ENC({m})'
            self.len = f'List.length(&2, U32, EB.ENC({m}))'
            self.sz = f'EB.SZ({m})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'EB.PUTX({m}, {dd}, {D}, {q}, {r})'
            self.hY = '{==}'
        elif fs.kind == 'seq' and fs.p == 'l1048576_bl1073741824':
            t, N = f't_{f}', f'N_{f}'
            self.mod = 'import ./big_encx_l1048576_bl1073741824.bend as ET'
            self.params = [f'+{t}: FD.array__Tree<ET.MB<ET.WMr>>', f'+{N}: U32']
            self.hyps = [f'+h_{f}: {{ET.OKL({t}, {N}) == {TRUE}}}']
            self.oargs = [t, N]
            self.hargs = [f'h_{f}']
            self.obj = f'ET.THL({t}, {N})'
            self.vt = f'T.{fs.p}_Seq'
            self.enc = f'ET.ENCL({t}, {N})'
            self.len = f'ET.LL({t}, {N})'
            self.sz = f'ET.SZW({t}, {N})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'ET.PUTL({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            self.hY = f'ET.len_encl({t}, {N})'
        elif fs.kind == 'seq' and fs.p.startswith('l') and '_' in fs.p:
            A_, N = f'A_{f}', f'N_{f}'
            p = fs.p
            R = p.split('_', 1)[1]
            self.mod = f'import ./encx_{p}.bend as EW_{p}'
            a = f'EW_{p}'
            self.params = [f'+{A_}: FD.array__Tree<T.{R}>', f'+{N}: U32']
            self.hyps = [f'+h_{f}: {{{a}.OKL_{p}({A_}, {N}) == {TRUE}}}']
            self.oargs = [A_, N]
            self.hargs = [f'h_{f}']
            self.obj = f'{a}.THL_{p}({A_}, {N})'
            self.vt = f'T.{p}_Seq'
            self.enc = f'{a}.ENCL_{p}({A_}, {N})'
            self.len = f'{a}.LL_{p}({A_}, {N})'
            rs = re.search(r'\(n \* (\d+) : U32\)', fn_body(f'{p}_ptn_fin')).group(1)
            self.sz = f'U32.mul({N}, {rs})'
            self.pad = False
            self.model = lambda dd, D, X, q, r: f'{a}.PUTL_{p}({A_}, {N}, {dd}, {D}, {q}, {r})'
            self.hY = f'{a}.len_encl_{p}({A_}, {N})'
            self.alias = a
        elif fs.p in STD_CHILDREN():
            # a child in var_plist_sub's encoder-window interface (codegen/encx_children.py)
            c = STD_CHILDREN()[fs.p]
            a = f'EX_{fs.p}'
            m = f'm_{f}'
            self.mod = f'import ./{c["file"]} as {a}'
            self.params = [f'+{m}: {a}.{c["mirror"]}']
            self.hyps = [f'+hok_{f}: {{{a}.OK({m}) == {TRUE}}}']
            self.oargs = [m]
            self.hargs = [f'hok_{f}']
            self.obj = f'{a}.TH({m})'
            self.vt = c['obj']
            self.enc = f'{a}.ENC({m})'
            self.len = f'List.length(&2, U32, {a}.ENC({m}))'
            self.sz = f'{a}.SZ({m})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'{a}.PUTX({m}, {dd}, {D}, {q}, {r})'
            self.hY = '{==}'
            self.alias = a
            self.std = True
        else:
            raise SystemExit(f'no child window for {fs.kind}/{fs.p}')

    def putx(self, dd, D, X, q, r, e, hr, hd, hl, pf, hz):
        """(runtime fact, bytes fact, perfect fact) terms."""
        f, p = self.f, self.p
        if p == 'bl32':
            m = f'm_{f}'
            a = f'{m}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {pf}, {hl}, {hz}, hok_{f}'
            return f'EB.putx({a})', f'EB.putx_bytes({a})', f'EB.pfx({m}, {dd}, {D}, {q}, {r}, {pf})', None
        if getattr(self, 'std', False):
            m, al = f'm_{f}', self.alias
            a = f'{m}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {pf}, {hl}, {hz}, hok_{f}'
            return f'{al}.putx({a})', f'{al}.putx_bytes({a})', f'{al}.pfx({m}, {dd}, {D}, {q}, {r}, {pf})', None
        t, N = self.oargs
        if p == 'l1048576_bl1073741824':
            g = f'ET.putx({t}, {N}, h_{f}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {hl}, {pf}, {hz})'
            b = f'U32.is_eq({N}, 0)'
            RT = f'ET.RTL({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            BY = f'ET.BYLb({b}, {t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            PF = f'ET.PFLb({b}, {t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            return g, (RT, BY, PF), None, 'P3'
        a = self.alias
        g = f'{a}.putx_{p}({t}, {N}, h_{f}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {hl}, {pf}, {hz})'
        RT = f'{a}.RTL_{p}({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
        BY = f'{a}.BYL_{p}({t}, {N}, {dd}, {D}, {q}, {r})'
        PF = f'{a}.PFL_{p}({t}, {N}, {dd}, {D}, {q}, {r})'
        return g, (RT, BY, PF), None, 'P3'

    def szx(self, qc, rc, dd, hd, hlc):
        f, p = self.f, self.p
        if p == 'bl32':
            return f'EB.szx(m_{f}, hok_{f})'
        if getattr(self, 'std', False):
            return f'{self.alias}.szx(m_{f}, hok_{f})'
        t, N = self.oargs
        if p == 'l1048576_bl1073741824':
            hb = (f'FD.nat__le_trans(ET.LL({t}, {N}), A.quad(VB.pw({dd})), VB.pw(30n), VCN.pc_end({qc}, {rc}, ET.LL({t}, {N}), {dd}, ET.LL({t}, {N}), '
                  f'FD.nat__le_refl(ET.LL({t}, {N})), {hlc}), FD.nat__pow2_mono(2n+{dd}, 30n, FD.nat__lt_succ_le({dd}, 28n, {hd})))')
            return f'ET.szx({t}, {N}, h_{f}, 30n, {{==}}, {hb})'
        a = self.alias
        return f'{a}.szx_{p}({t}, {N}, {qc}, {rc}, {dd}, {hd}, {hlc})'


# ---- the runtime's source ---------------------------------------------------------------------------

SRC = None
SRC_FILE = 'types/fulu_obj.bend'
_STD = None


def STD_CHILDREN():
    """The children in the encoder-window interface (codegen/encx_children.py), by runtime prefix;
    bl32 keeps its own branch."""
    global _STD
    if _STD is None:
        import encx_children as EC
        _STD = {p: c for p, c in EC.CHILDREN.items() if p != 'bl32'}
    return _STD


def src():
    global SRC
    if SRC is None:
        SRC = (ROOT / SRC_FILE).read_text()
    return SRC


def fn_body(name):
    m = re.search(rf'^def {re.escape(name)}\(.*?(?=^def |\Z)', src(), re.M | re.S)
    if not m:
        raise SystemExit(f'no runtime def {name}')
    return m.group(0)


def fn_params(name):
    """The parameter names of a runtime def, in order."""
    m = re.search(rf'^def {re.escape(name)}\((.*?)\) ->', src(), re.M)
    if not m:
        raise SystemExit(f'no runtime def {name}')
    ps = []
    d = 0
    cur = ''
    for ch in m.group(1):
        if ch in '<({':
            d += 1
        elif ch in '>)}':
            d -= 1
        if ch == ',' and d == 0:
            ps.append(cur)
            cur = ''
        else:
            cur += ch
    ps.append(cur)
    return [x.split(':')[0].strip().lstrip('+~-') for x in ps]


# ---- the container --------------------------------------------------------------------------------------

class Cont:
    def __init__(self, g, names, C):
        self.C = C
        self.t = names[C]
        self.s = g.shape(self.t)
        self.p = self.s.p
        F = self.s.fields
        self.F = F
        self.hoff, self.fixed = G.container_layout(F)
        self.wide = len(F) > GROUP
        self.leaves = {}
        self.children = {}
        self.fixw = {}
        for i, (f, fs) in enumerate(F):
            if fs.fixed and fs.data:
                lf = leaf_of(fs)
                self.leaves.setdefault(lf.p, lf)
            elif is_fixw(fs):
                self.fixw[f] = fs
            elif not fs.fixed:
                self.children[f] = Child(f, fs)
            else:
                raise SystemExit(f'field {f}: {fs.kind} not supported')


def generate_cont(g, names, C):
    K = Cont(g, names, C)
    F, hoff, FIX, p = K.F, K.hoff, K.fixed, K.p
    names_ = [f for f, _ in F]
    fsd = dict(F)
    # ---- parameters and the object ----
    OP, OA, HP, HA = [], [], [], []
    OBJF = {}
    for i, (f, fs) in enumerate(F):
        if fs.fixed and fs.data:
            OP.append(f'+{f}: {leaf_of(fs).ctor}')
            OA.append(f)
            OBJF[f] = f
        elif is_fixw(fs):
            nW = fs.fsize // 4
            OP += [f'+dB_{f}: Nat', f'+TB_{f}: {TR}']
            OA += [f'dB_{f}', f'TB_{f}']
            HP += [f'+pfB_{f}: {{FD.array__perfect(U32, dB_{f}, TB_{f}) == {TRUE}}}', f'+hdB_{f}: {{Nat.is_lt(dB_{f}, 31n) == {TRUE}}}',
                   f'+hrB_{f}: {{Nat.is_le({nW}n, VB.pw(dB_{f})) == {TRUE}}}']
            HA += [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}']
            OBJF[f] = f'O.Words{{FD.array__thaw(U32, TB_{f}), {fs.fsize}}}'
        else:
            ch = K.children[f]
            OP += ch.params
            OA += ch.oargs
            HP += ch.hyps
            HA += ch.hargs
            OBJF[f] = ch.obj
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS, HAS = ', '.join(HP), ', '.join(HA)
    if K.wide:
        groups = [(k // GROUP, list(range(k, min(k + GROUP, len(F))))) for k in range(0, len(F), GROUP)]
    else:
        groups = [(None, list(range(len(F))))]

    def gname(gk):
        return p if gk is None else f'{p}_g{gk}'

    def grec(gk, idx):
        return f'T.{gname(gk)}{{' + ', '.join(OBJF[names_[i]] for i in idx) + '}'
    if K.wide:
        OBJ = f'T.{C}{{' + ', '.join(grec(gk, idx) for gk, idx in groups) + '}'
    else:
        OBJ = grec(None, groups[0][1])
    X0 = 'Nat.add(A.quad(q), r)'
    MA = f'{OAS}, dd, D, X, q, r'
    MP = f'{OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat'
    # ---- the pieces ----
    pieces = []   # (kind, field, size term)
    fidx = {}
    for i, (f, fs) in enumerate(F):
        fidx[f] = len(pieces)
        pieces.append(('fix' if fs.fixed else 'off', f, f'{fs.fsize}n' if fs.fixed else '4n'))
    var = [f for f, fs in F if not fs.fixed]
    vidx = {}
    for f in var:
        vidx[f] = len(pieces)
        pieces.append(('var', f, K.children[f].len))
    PT = f'WD.PADB(r, LLC({MA}))'
    pieces.append(('pad', None, PT))
    ks_all = [K.children[f].len for f in var]
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    FS = '[' + ', '.join(sz for k, f, sz in pieces if k in ('fix', 'off')) + ']'
    state = [f'UW.ZB({sz})' for _, _, sz in pieces]
    # ---- the runtime's writes, in order ----
    events = []    # dict(kind, field, ...)
    cur_terms = {}

    def group_events(gk, idx, cur0):
        Fg = [(names_[i], F[i][1]) for i in idx]
        varg = [i for i in idx if not F[i][1].fixed]
        ling = [i for i in idx if not F[i][1].data]
        psteps = [('putv', i) for i in varg] + [('put', i) for i in ling if i not in varg]
        cur = cur0
        for kind_, i in psteps:
            f = names_[i]
            if kind_ == 'putv':
                events.append(dict(kind='off', field=f, cur=cur, hoff=hoff[i]))
                events.append(dict(kind='var', field=f, cur=cur))
                cur_terms[f] = cur
                cur = f'O.padd({cur}, {K.children[f].sz})'
            else:
                events.append(dict(kind='fixw', field=f, hoff=hoff[i]))
        for i in idx:
            if F[i][1].fixed and F[i][1].data:
                events.append(dict(kind='leaf', field=names_[i], hoff=hoff[i]))
        return psteps, cur
    GI = []
    cur = f'{FIX}'
    for gk, idx in groups:
        st, cur2 = group_events(gk, idx, cur)
        GI.append((gk, idx, st, cur))
        cur = cur2
    SZC = cur
    # the models
    L = []
    w = L.append
    for lf in K.leaves.values():
        w(leaf_text(lf))
    w(f'''
# ---- {C}: the object, its bytes and byte count ----
def OBJC({OPS}) -> T.{C}: {OBJ}
def LLC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Nat: Nat.add({FIX}n, VCN.SUM({KS(ks_all)}))
def SZC({OPS}) -> U32: {SZC}
''')
    # models M0..Mn
    w(f'def M0({MP}) -> {TR}: D')
    trees = ['D']
    ev_q = {}
    for k, ev in enumerate(events):
        prev = f'M{k}({MA})'
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf':
            lf = leaf_of(fs)
            kw = ev['hoff'] // 4
            mdl = f'PXo_{lf.p}({f}, dd, {prev}, Nat.add({kw}n, q), r)'
        elif ev['kind'] == 'fixw':
            kw = ev['hoff'] // 4
            mdl = f'V_{fs.p}.PX_{fs.p}(r, dd, {prev}, Nat.add({kw}n, q), TB_{f})'
        elif ev['kind'] == 'off':
            kw = ev['hoff'] // 4
            mdl = f'WD.W32X(r, dd, {prev}, Nat.add({kw}n, q), {ev["cur"]})'
        else:
            Xc = f'U32.add(X, {ev["cur"]})'
            mdl = K.children[f].model('dd', prev, Xc, f'VCN.QX({Xc})', f'VCN.RX({Xc})')
        w(f'def M{k + 1}({MP}) -> {TR}: {mdl}')
    NE = len(events)
    w(f'def PUTC({MP}) -> {TR}: M{NE}({MA})')
    return K, L, events, GI, OBJ, OBJF, OP, OA, HP, HA, pieces, fidx, vidx, var, ks_all, PT, FS, groups, SZC


def module_text(g, names, C):
    K, L, events, GI, OBJ, OBJF, OP, OA, HP, HA, pieces, fidx, vidx, var, ks_all, PT, FS, groups, SZC = generate_cont(g, names, C)
    F, hoff, FIX, p = K.F, K.hoff, K.fixed, K.p
    names_ = [f for f, _ in F]
    fsd = dict(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS, HAS = ', '.join(HP), ', '.join(HA)
    MA = f'{OAS}, dd, D, X, q, r'
    MP = f'{OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat'
    X0 = 'Nat.add(A.quad(q), r)'
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    w = L.append
    Mk = lambda k: f'M{k}({MA})'
    TH = lambda k: f'FD.array__thaw(U32, {Mk(k)})'
    # ---- the putv facts, per variable field ----
    for f in var:
        ch = K.children[f]
        V = ch.obj
        RT = f'Array<U32> & ({ch.vt} & U32)'
        w(f'''
# {f}: its offset word, then its bytes (T.{ch.p}_putv).
def putv_{f}({', '.join(ch.params)}, +D: {TR}, +D1: {TR}, +D2: {TR}, +X: U32, +hoff: U32, +cur: U32,
    +e1: {{O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur) == FD.array__thaw(U32, D1) : Array<U32>}},
    +e2: {{T.{ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), {V}) == (FD.array__thaw(U32, D2), ({V}, {ch.sz})) : {RT}}})
    -> {{T.{ch.p}_putv(FD.array__thaw(U32, D), X, hoff, cur, {V}) == (FD.array__thaw(U32, D2), ({V}, O.padd(cur, {ch.sz}))) : {RT}}}:
  Equal.trans({RT}, T.{ch.p}_pvb(cur, T.{ch.p}_putk(O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur), U32.add(X, cur), {V})),
    T.{ch.p}_pvb(cur, T.{ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), {V})), (FD.array__thaw(U32, D2), ({V}, O.padd(cur, {ch.sz}))),
    Equal.cong(Array<U32>, {RT}, z => T.{ch.p}_pvb(cur, T.{ch.p}_putk(z, U32.add(X, cur), {V})), O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur), FD.array__thaw(U32, D1), e1),
    Equal.cong({RT}, {RT}, z => T.{ch.p}_pvb(cur, z), T.{ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), {V}), (FD.array__thaw(U32, D2), ({V}, {ch.sz})), e2))
''')
    # ---- the runtime chain: facts per write ----
    def fact(k, ev):
        """(inner lhs, rhs) of write k (runtime term on tree M_k)."""
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf':
            return f'T.{leaf_of(fs).p}_put({TH(k)}, U32.add(X, {ev["hoff"]}), {f})', TH(k + 1), 'Array<U32>'
        if ev['kind'] == 'fixw':
            o = OBJF[f]
            return f'T.{fs.p}_putk({TH(k)}, U32.add(X, {ev["hoff"]}), {o})', f'({TH(k + 1)}, ({o}, 0))', 'Array<U32> & (O.Words & U32)'
        if ev['kind'] == 'off':
            return f'O.w32({TH(k)}, U32.add(X, {ev["hoff"]}), {ev["cur"]})', TH(k + 1), 'Array<U32>'
        ch = K.children[f]
        return f'T.{ch.p}_putk({TH(k)}, U32.add(X, {ev["cur"]}), {ch.obj})', f'({TH(k + 1)}, ({ch.obj}, {ch.sz}))', f'Array<U32> & ({ch.vt} & U32)'
    FACTP = []
    for k, ev in enumerate(events):
        lhs, rhs, ty = fact(k, ev)
        FACTP.append(f'+f{k}: {{{lhs} == {rhs} : {ty}}}')
    FPS = ',\n    '.join(FACTP)
    FAS = ', '.join(f'f{k}' for k in range(len(events)))
    # chain builder
    def chain(ty, steps, start, end):
        """steps: [(ctx lambda body with z, inner lhs, inner rhs, inner type, proof, term after)]"""
        if not steps:
            return '{==}'
        terms = [start] + [s[5] for s in steps]
        def go(j):
            ctx, lhs, rhs, ity, prf, after = steps[j]
            e = f'Equal.cong({ity}, {ty}, z => {ctx}, {lhs}, {rhs}, {prf})'
            if j == len(steps) - 1:
                return e
            return f'Equal.trans({ty}, {terms[j]}, {terms[j + 1]}, {end}, {e}, {go(j + 1)})'
        return go(0)
    # per group: runtime lemma
    evk = {}  # event index by (kind, field)
    for k, ev in enumerate(events):
        evk[(ev['kind'], ev['field'])] = k
    GRT = []
    k0 = 0
    for gi, (gk, idx, psteps, cur0) in enumerate(GI):
        gp = p if gk is None else f'{p}_g{gk}'
        gobj = f'T.{gp}{{' + ', '.join(OBJF[names_[i]] for i in idx) + '}'
        data_only = not psteps
        nev = sum(1 for ev in events if ev['field'] in [names_[i] for i in idx])
        kA, kB = k0, k0 + nev
        k0 = kB
        steps = []
        if data_only:
            RTg = 'Array<U32>'
            start = f'T.{gp}_put({TH(kA)}, X, {cur0}, {gobj})' if K.wide else None
            curterm = None
        else:
            RTg = f'Array<U32> & (T.{gp} & U32)'
            start = f'T.{gp}_put({TH(kA)}, X, {cur0}, {gobj})' if K.wide else f'T.{gp}_putn({TH(kA)}, X, {gobj})'
        # the chain steps
        held = lambda i_ex, reps: [reps.get(names_[i], OBJF[names_[i]]) for i in idx if i != i_ex]
        cur = cur0
        reps = {}
        kk = kA
        for s, (kind_, i) in enumerate(psteps):
            f = names_[i]
            pw = f'T.{gp}_pw{s}'
            pnames = fn_params(f'{gp}_pw{s}')
            if kind_ == 'putv':
                ch = K.children[f]
                args = ['X'] + held(i, reps)
                ctx = f'{pw}({", ".join(args)}, z)'
                lhs = f'T.{ch.p}_putv({TH(kk)}, X, {hoff[i]}, {cur}, {ch.obj})'
                ncur = f'O.padd({cur}, {ch.sz})'
                rhs = f'({TH(kk + 2)}, ({ch.obj}, {ncur}))'
                ity = f'Array<U32> & ({ch.vt} & U32)'
                prf = f'putv_{f}({", ".join(ch.oargs)}, {Mk(kk)}, {Mk(kk + 1)}, {Mk(kk + 2)}, X, {hoff[i]}, {cur}, f{kk}, f{kk + 1})'
                steps.append((ctx, lhs, rhs, ity, prf, f'{pw}({", ".join(args)}, {rhs})'))
                cur = ncur
                kk += 2
            else:
                fs = fsd[f]
                args = ['X', cur] + held(i, reps)
                ctx = f'{pw}({", ".join(args)}, z)'
                o = OBJF[f]
                lhs = f'T.{fs.p}_putk({TH(kk)}, U32.add(X, {hoff[i]}), {o})'
                rhs = f'({TH(kk + 1)}, ({o}, 0))'
                steps.append((ctx, lhs, rhs, 'Array<U32> & (O.Words & U32)', f'f{kk}', f'{pw}({", ".join(args)}, {rhs})'))
                cur = f'({cur} .|. 0 : U32)'
                kk += 1
        # the Data fields, innermost first
        dat = [i for i in idx if F[i][1].fixed and F[i][1].data]

        def fw(expr, j0):
            for i in dat[j0:]:
                expr = f'T.{leaf_of(fsd[names_[i]]).p}_put({expr}, U32.add(X, {hoff[i]}), {names_[i]})'
            return expr
        for j, i in enumerate(dat):
            f = names_[i]
            lhs, rhs, ity = fact(kk, events[kk])
            inner = fw('z', j + 1)
            if data_only:
                ctx = inner
                after = fw(rhs, j + 1)
            else:
                ctx = f'({inner}, ({gobj}, {cur}))'
                after = f'({fw(rhs, j + 1)}, ({gobj}, {cur}))'
            steps.append((ctx, lhs, rhs, ity, f'f{kk}', after))
            kk += 1
        assert kk == kB, (gk, kk, kB)
        end = TH(kB) if data_only else f'({TH(kB)}, ({gobj}, {cur}))'
        if start is None:
            start = f'T.{gp}_put({TH(kA)}, X, {gobj})'
        GRT.append((gk, gp, kA, kB, RTg, start, end, cur, gobj, data_only))
        w(f'''
# the runtime's {gp} writes, from its writes' facts
def rt_{gp.replace(p, "G") if gk is not None else "C"}({MP},
    {FPS})
    -> {{{start} == {end} : {RTg}}}:
  {chain(RTg, steps, start, end)}
''')
    # the whole container (wide): putn through the groups
    RTC = f'Array<U32> & (T.{C} & U32)'
    START = f'T.{p}_putn({TH(0)}, X, {OBJ})'
    ENDC = f'({TH(len(events))}, ({OBJ}, {SZC}))'
    if K.wide:
        lin = [x for x in GRT if not x[9]]
        steps = []
        gmap = {x[0]: x for x in GRT}
        allg = [x[0] for x in GRT]
        # putn: the Data groups before the first linear group, then pw0(...)
        first = lin[0]
        assert all(not gmap[gk][9] or gk > first[0] for gk in allg), 'Data groups before the first linear group'
        for j, x in enumerate(lin):
            gk, gp, kA, kB, RTg, start, end, cur, gobj, _ = x
            heldg = [gmap[g2][8] for g2 in allg if g2 != gk]
            if j == 0:
                ctx = f'T.{p}_pw0(X, {", ".join(heldg)}, z)'
            else:
                ctx = f'T.{p}_pw{j}(X, {", ".join(heldg)}, z)'
            nm = 'G' + gp[len(p):]
            prf = f'rt_{nm}({MA}, {FAS})'
            after = f'{ctx.replace("z)", end + ")")}'
            steps.append((ctx, start, end, RTg, prf, after))
            # Data groups after this one (before the next linear one)
            nxt = lin[j + 1][0] if j + 1 < len(lin) else None
            for g2 in allg:
                y = gmap[g2]
                if y[9] and g2 > gk and (nxt is None or g2 < nxt):
                    ctx2 = f'(z, ({OBJ}, {cur}))'
                    nm2 = 'G' + y[1][len(p):]
                    steps.append((ctx2, y[5], y[6], 'Array<U32>', f'rt_{nm2}({MA}, {FAS})', f'({y[6]}, ({OBJ}, {cur}))'))
        chain_rt = chain(RTC, steps, START, ENDC)
    else:
        chain_rt = f'rt_C({MA}, {FAS})'
    w(f'''
# the runtime's put of {C} at X
def rt_all({MP},
    {FPS})
    -> {{{START} == {ENDC} : {RTC}}}:
  {chain_rt}
''')
    return L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC


def K_fixed_count(pieces):
    return sum(1 for k, _, _ in pieces if k in ('fix', 'off'))


def putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC):
    F, FIX = K.F, K.fixed
    fsd = dict(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS = ', '.join(HP)
    MA = f'{OAS}, dd, D, X, q, r'
    X0 = 'Nat.add(A.quad(q), r)'
    LLv = f'LLC({MA})'
    Mk = lambda k: f'M{k}({MA})'
    BY = lambda k: f'UA.BYT({Mk(k)})'
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    st = [f'UW.ZB({sz})' for _, _, sz in pieces]
    L = []
    w = L.append
    ls = []
    a = ls.append
    PTr = f'WD.PADB(r, {LLv})'
    MS = f'VCN.APPN({FS}, VCN.APPN({KS(ks_all)}, [{PTr}]))'
    a(f'+hX = VRX.xstart(q, r, {LLv}, dd, D, pf, hl)')
    a(f'+hz0 = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({X0}, UA.BYT(D))) == UW.ZB(zz) : +List<U32>}}, Nat.add({LLv}, {PTr}), VCN.SUM({MS}), '
      f'Equal.sym(Nat, VCN.SUM({MS}), Nat.add({LLv}, {PTr}), VCN.sum_region({FS}, {KS(ks_all)}, {PTr})), hz)')
    a(f'+I0 = VCN.reg_init(UA.BYT(D), {X0}, {MS}, hz0)')
    a('+pf0 = pf')
    facts = []
    curs = {}
    enc_of = {}
    szx_of = {}
    ec_of = {}
    vj = {f: j for j, f in enumerate(var)}
    nfix = K_fixed_count(pieces)
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        kind = ev['kind']
        UBk, UBn = BY(k), BY(k + 1)
        if kind in ('leaf', 'fixw', 'off'):
            i = fidx[f]
            c = ev['hoff']
            kw = c // 4
            size = 4 if kind == 'off' else fs.fsize
            pre = '[' + ', '.join(st[:i]) + ']'
            post = '[' + ', '.join(st[i + 1:]) + ']'
            pos = f'Nat.add(A.quad(Nat.add({kw}n, q)), r)'
            rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({size}n, VS.bdr(zz, {UBk})) == UW.ZB({size}n) : +List<U32>}}, {rel}, {pos}, VRX.fpx(q, r, {kw}n), z{k})')
            a(f'+ep{k} = VRX.fpos(X, q, r, {kw}n, {c}, {LLv}, dd, e, {{==}}, hd, {{==}}, hl)')
            a(f'+hl{k} = VRX.froom(q, r, dd, {kw}n, {size}n, {LLv}, FD.nat__le_trans(Nat.add(A.quad({kw}n), {size}n), {FIX}n, {LLv}, {{==}}, Order.below_sum({FIX}n, VCN.SUM({KS(ks_all)}))), hl)')
            Xc = f'U32.add(X, {c})'
            qk = f'Nat.add({kw}n, q)'
            if kind == 'leaf':
                lf = leaf_of(fs)
                a(f'+g{k} = putxo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, r, ep{k}, hr, hd, hl{k}, pf{k}, hz{k})')
                a(f'+rt{k} = PA(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, r), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, r), g{k})')
                a(f'+by{k} = PB(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, r), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, r), g{k})')
                Y = f'FX.limbs(RW_{lf.p}({f}))'
                hY = f'lenb_{lf.p}({f})'
                a(f'+pf{k + 1} = pfo_{lf.p}({f}, dd, {Mk(k)}, {qk}, r, pf{k})')
                piece = f'VCN.PC({size}n, {Y})'
                reg = 'reg_putc0'
            elif kind == 'fixw':
                M = f'V_{fs.p}'
                args = f'dd, {Mk(k)}, {Xc}, {qk}, r, dB_{f}, TB_{f}, ep{k}, hr, hd, hl{k}, pf{k}, pfB_{f}, hdB_{f}, hrB_{f}, hz{k}'
                a(f'+rt{k} = {M}.{fs.p}_any({args})')
                a(f'+by{k} = {M}.{fs.p}_any_bytes({args})')
                nW = fs.fsize // 4
                Y = f'FX.limbs(VS.wtake({nW}n, UW.SLW(TB_{f})))'
                h64 = (f'FD.logic__subst(Nat, zz => {{Nat.is_le({nW}n, zz) == {TRUE}}}, VB.pw(dB_{f}), List.length(&2, U32, UW.SLW(TB_{f})), '
                       f'Equal.sym(Nat, List.length(&2, U32, UW.SLW(TB_{f})), VB.pw(dB_{f}), Equal.trans(Nat, List.length(&2, U32, UW.SLW(TB_{f})), '
                       f'FD.spec_common__length(U32, UW.SLW(TB_{f})), VB.pw(dB_{f}), VMR.len_eq(UW.SLW(TB_{f})), FD.array__slots_length(U32, dB_{f}, TB_{f}, pfB_{f}))), hrB_{f})')
                hY = f'VCN.len_wt({nW}n, UW.SLW(TB_{f}), {h64})'
                a(f'+pf{k + 1} = {M}.{fs.p}x_perfect(r, dd, {Mk(k)}, {qk}, TB_{f}, pf{k})')
                piece = f'VCN.PC({size}n, {Y})'
                reg = 'reg_putc0'
            else:
                cur = ev['cur']
                a(f'+rt{k} = WD.w32_any(dd, {Mk(k)}, {Xc}, {qk}, r, {cur}, ep{k}, hr, hd, hl{k}, pf{k})')
                a(f'+by{k} = WD.w32_any_bytes(dd, {Mk(k)}, {Xc}, {qk}, r, {cur}, ep{k}, hr, hd, hl{k}, pf{k}, hz{k})')
                Y = f'I.limb({cur})'
                hY = '{==}'
                a(f'+pf{k + 1} = WD.w32x_perfect(r, dd, {Mk(k)}, {qk}, {cur}, pf{k})')
                piece = Y
                reg = 'reg_put0'
            a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, VRX.fpx(q, r, {kw}n)), by{k})')
            a(f'+I{k + 1} = VCN.{reg}(UA.BYT(D), {X0}, {pre}, {size}n, {post}, {Y}, {UBk}, {UBn}, hX, I{k}, {hY}, hop{k})')
            st[i] = piece
            facts.append(f'rt{k}')
            continue
        # a variable field
        ch = K.children[f]
        j = vj[f]
        i = vidx[f]
        cur = ev['cur']
        ks_j = ks_all[:j]
        rest = ks_all[j + 1:]
        Lj = ch.len
        aj = f'Nat.add({FIX}n, VCN.SUM({KS(ks_j)}))'
        Xc = f'U32.add(X, {cur})'
        QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
        if j == 0:
            a(f'+ec{k} = VCN.EQN(U32.to_nat({cur}), {aj}, {{==}})')
        else:
            fp = var[j - 1]
            pa = f'Nat.add(Nat.add({FIX}n, VCN.SUM({KS(ks_all[:j - 1])})), {ks_all[j - 1]})'
            a(f'+ec{k} = VCN.cnext({curs[fp]}, {K.children[fp].sz}, {FIX}n, {KS(ks_all[:j - 1])}, {ks_all[j - 1]}, dd, hd, {ec_of[fp]}, {szx_of[fp]}, '
              f'VCN.pc_end(q, r, {LLv}, dd, {pa}, VCN.pc_room({FIX}n, {KS(ks_all[:j - 1])}, {ks_all[j - 1]}, {KS(ks_all[j:])}), hl))')
        ec_of[f] = f'ec{k}'
        curs[f] = cur
        a(f'+hk{k} = VCN.pc_room({FIX}n, {KS(ks_j)}, {Lj}, {KS(rest)})')
        a(f'+ha{k} = FD.nat__le_trans({aj}, Nat.add({aj}, {Lj}), {LLv}, Order.below_sum({aj}, {Lj}), hk{k})')
        a(f'+ep{k} = VCN.vpos(X, {cur}, {aj}, q, r, {LLv}, dd, e, ec{k}, hd, ha{k}, hl)')
        a(f'+hlc{k} = VCN.croom({Xc}, q, r, {aj}, {Lj}, {LLv}, dd, ep{k}, hk{k}, hl)')
        fw = st[:nfix]
        ps = '[' + ', '.join(enc_of[x] for x in var[:j]) + ']'
        pre = f'VCN.LAP([{", ".join(fw)}], VCN.PCL({KS(ks_j)}, {ps}))'
        post = '[' + ', '.join(st[i + 1:]) + ']'
        rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
        pos = f'Nat.add(A.quad({QX}), {RX})'
        a(f'+epc{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, {aj}), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), {aj}, '
          f'VCN.eposv([{", ".join(fw)}], {ps}, {KS(ks_j)})), '
          f'Equal.trans(Nat, Nat.add({X0}, {aj}), U32.to_nat({Xc}), {pos}, Equal.sym(Nat, U32.to_nat({Xc}), Nat.add({X0}, {aj}), ep{k}), VC.split4({Xc})))')
        if ch.pad:
            pc = f'WD.PADB({RX}, {Lj})'
            MSr = f'VCN.APPN({KS(rest)}, [{PTr}])'
            a(f'+hp{k} = VCN.zbs_pre({MSr}, {pc}, VCN.padfit({Xc}, q, r, {aj}, {Lj}, {LLv}, VCN.SUM({MSr}), ep{k}, hk{k}, '
              f'VCN.pc_after({FIX}n, {KS(ks_j)}, {Lj}, {KS(rest)}, {PTr})))')
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {pc}, {UBk}, hX, I{k}, hp{k})')
            win = f'Nat.add({Lj}, {pc})'
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({win}, VS.bdr(zz, {UBk})) == UW.ZB({win}) : +List<U32>}}, {rel}, {pos}, epc{k}, z{k})')
        else:
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
            a(f'+z{k}b = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({rel}, {UBk})) == UW.ZB(zz) : +List<U32>}}, Nat.add({Lj}, 0n), {Lj}, FD.nat__add_zero({Lj}), z{k})')
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({Lj}, VS.bdr(zz, {UBk})) == UW.ZB({Lj}) : +List<U32>}}, {rel}, {pos}, epc{k}, z{k}b)')
        g, parts, pfx, kind_ = ch.putx('dd', Mk(k), Xc, QX, RX, f'VC.split4({Xc})', f'VCN.rx_lt({Xc})', 'hd', f'hlc{k}', f'pf{k}', f'hz{k}')
        if kind_ is None:
            a(f'+rt{k} = {g}')
            a(f'+by{k} = {parts}')
            a(f'+pf{k + 1} = {pfx}')
        else:
            RT, BYt, PF = parts
            a(f'+g{k} = {g}')
            a(f'+rt{k} = PA({RT}, DK.P2({BYt}, {PF}), g{k})')
            a(f'+g{k}b = PB({RT}, DK.P2({BYt}, {PF}), g{k})')
            a(f'+by{k} = PA({BYt}, {PF}, g{k}b)')
            a(f'+pf{k + 1} = PB({BYt}, {PF}, g{k}b)')
        Y = f'VCN.AP({ch.enc}, UW.ZB(WD.PADB({RX}, {Lj})))' if ch.pad else ch.enc
        a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, epc{k}), by{k})')
        if ch.pad:
            a(f'+I{k + 1} = VCN.reg_putc(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {ch.enc}, WD.PADB({RX}, {Lj}), {UBk}, {UBn}, hX, I{k}, {ch.hY}, hp{k}, hop{k})')
        else:
            a(f'+I{k + 1} = VCN.reg_putc0(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {ch.enc}, {UBk}, {UBn}, hX, I{k}, {ch.hY}, hop{k})')
        a(f'+sz{k} = {ch.szx(QX, RX, "dd", "hd", f"hlc{k}")}')
        szx_of[f] = f'sz{k}'
        enc_of[f] = ch.enc
        st[i] = f'VCN.PC({Lj}, {ch.enc})'
        facts.append(f'rt{k}')
    n = len(events)
    EP = '[' + ', '.join(st[:-1]) + ']'
    ENCC = f'VCN.CAT({EP})'
    a(f'+ef = Equal.trans(+List<U32>, VCN.CAT(VCN.LAP({EP}, [UW.ZB({PTr})])), VCN.AP({ENCC}, VCN.CAT([UW.ZB({PTr})])), VCN.AP({ENCC}, UW.ZB({PTr})), '
      f'VCN.cat_lap({EP}, [UW.ZB({PTr})]), Equal.cong(+List<U32>, +List<U32>, zz => VCN.AP({ENCC}, zz), VCN.AP(UW.ZB({PTr}), []), UW.ZB({PTr}), VS.app_nil(UW.ZB({PTr}))))')
    a(f'+byf = FD.logic__subst(+List<U32>, zz => {{{BY(n)} == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VCN.CAT(VCN.LAP({EP}, [UW.ZB({PTr})])), VCN.AP({ENCC}, UW.ZB({PTr})), ef, I{n})')
    fl = var[-1]
    ksl = ks_all[:-1]
    pa = f'Nat.add(Nat.add({FIX}n, VCN.SUM({KS(ksl)})), {ks_all[-1]})'
    a(f'+szf = VCN.cnext({curs[fl]}, {K.children[fl].sz}, {FIX}n, {KS(ksl)}, {ks_all[-1]}, dd, hd, {ec_of[fl]}, {szx_of[fl]}, '
      f'VCN.pc_end(q, r, {LLv}, dd, {pa}, VCN.pc_room({FIX}n, {KS(ksl)}, {ks_all[-1]}, []), hl))')
    body = '\n  '.join(ls)
    w(f'''
def ENCC({OPS}) -> +List<U32>: {ENCC}
def RTC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{K.p}_putn(FD.array__thaw(U32, D), X, OBJC({OAS})) == (FD.array__thaw(U32, PUTC({MA})), (OBJC({OAS}), SZC({OAS}))) : Array<U32> & (T.{K.C} & U32)}}
def BYC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTC({MA})) == UW.SPL(UA.BYT(D), {X0}, VCN.AP(ENCC({OAS}), UW.ZB(WD.PADB(r, LLC({MA}))))) : +List<U32>}}
def PFC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {{FD.array__perfect(U32, dd, PUTC({MA})) == {TRUE}}}
def SZXC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {{U32.to_nat(SZC({OAS})) == LLC({MA}) : Nat}}

# The four facts as one (built from variables, so no fact's proof term enters another's type).
def mk4({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +a: RTC({MA}), +b: BYC({MA}), +c: PFC({MA}), +d: SZXC({MA}))
    -> DK.P2(RTC({MA}), DK.P2(BYC({MA}), DK.P2(PFC({MA}), SZXC({MA})))):
  (a, (b, (c, d)))

# putx: the runtime's writer of {K.C} at X = 4 q + r is the model PUTC, whose bytes splice the
# container's bytes (and the zeros to the end of the last word) into D's, whose tree is perfect,
# and whose returned size is the byte count.
def putx({OPS}, {HPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LLC({MA})))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt(Nat.add(LLC({MA}), WD.PADB(r, LLC({MA}))), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(Nat.add(LLC({MA}), WD.PADB(r, LLC({MA})))) : +List<U32>}})
    -> DK.P2(RTC({MA}), DK.P2(BYC({MA}), DK.P2(PFC({MA}), SZXC({MA})))):
  {body}
  mk4({MA}, rt_all({MA}, {", ".join(facts)}), byf, pf{n}, szf)
''')
    return L


HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
        'import ./vuwd.bend as WD', 'import ./vcopy.bend as VC', 'import ./vrecx.bend as VRX', 'import ./vcont.bend as VCN', 'import ./vmr.bend as VMR', 'import ./dk.bend as DK']


# The generic containers (types/generic_obj.bend, proofs/obj/generic_specs.bend) written by this generator:
# every child in the encoder-window interface, every fixed piece word-aligned (so far).
GCONTS = ['Gp4B0CA2906A']


def gfile_c(C):
    return ROOT / f'proofs/obj/big_encx_{C}.bend'


def full_text(C, generic=False):
    global SRC, SRC_FILE
    if generic:
        import generic as GN
        names = {n: t for n, t, err in GN.inventory_all() if err is None}
        g = G.Gen()
        if SRC_FILE != 'types/generic_obj.bend':
            SRC, SRC_FILE = None, 'types/generic_obj.bend'
    else:
        g, names = G.Gen(), schema.load(ROOT / 'codegen/fulu.yaml')
        if SRC_FILE != 'types/fulu_obj.bend':
            SRC, SRC_FILE = None, 'types/fulu_obj.bend'
    for n, t in names.items():
        g.shape(t)
    L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC = module_text(g, names, C)
    L += putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC)
    mods = []
    for lf in K.leaves.values():
        if lf.mod and lf.mod not in mods:
            mods.append(lf.mod)
    for f, fs in K.fixw.items():
        m = f'import ./vuwv_{fs.p}.bend as V_{fs.p}'
        if m not in mods:
            mods.append(m)
    for ch in K.children.values():
        if ch.mod not in mods:
            mods.append(ch.mod)
    hd = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T') for x in HEAD] if generic else HEAD
    head = hd + mods + ['', '# GENERATED by codegen/var_cont_enc.py. Do not edit.',
                          f'# {C} in the encoder-window interface: written at any byte position X = 4 q + r (see the generator).', '',
                          'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                          'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b']
    return '\n'.join(head) + '\n' + '\n'.join(L) + '\n'


def main():
    out = {}
    if '--no-big' not in sys.argv:
        for C in CONTS:
            out[out_file(C)] = full_text(C)
        for C in GCONTS:
            out[gfile_c(C)] = full_text(C, generic=True)
    if '--check' in sys.argv:
        stale = [str(q.relative_to(ROOT)) for q, t in out.items() if not q.exists() or q.read_text() != t]
        if stale:
            print('stale generated container encoder windows: ' + ', '.join(stale))
            sys.exit(1)
        print('generated container encoder windows are current')
        return
    for q, t in out.items():
        q.write_text(t)
    print(', '.join(str(q.relative_to(ROOT)) for q in out))


if __name__ == '__main__':
    main()
