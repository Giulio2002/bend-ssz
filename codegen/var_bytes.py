#!/usr/bin/env python3
"""Spec-connected codec laws of variable-size names whose variable part is a
BYTE LIST (any length, not only whole words).

    python3 codegen/var_bytes.py [--check] [--no-big]

Covered family: containers (plain or grouped: more than 8 fields) whose fixed
fields are word-aligned Data leaves and records (uint64, uint256, byte vectors
of whole words, containers of those) or packed word storage (O.Words byte
vectors / vectors of Bytes32), with exactly ONE variable field, a ByteList
held as packed bytes. Fulu names: ExecutionPayloadHeader.

The input copy of a byte list keeps only the low L & 3 bytes of its last word
(O.mask_last); that is proved once, symbolically in the length, in
proofs/obj/vbytes.bend (copy_in_any, mk_bytes) and vbspec.bend (ybytes).

For each name X this writes

    proofs/obj/var_bytes_<X>_win.bend  X at a word-aligned window (off = 4 i, len)
        ok_evalw   the validator returns the buffer and CHKw(t, i, len);
        readw      CHKw holds: the reader returns OBJw(t, i, len), an explicit
                   object (the byte list's storage is the masked copy MKw);
        specw      CHKw holds: the spec parts of VALw(t, i, len), the value of
                   that object, are one variable part holding the window's bytes;
    proofs/obj/var_bytes_<X>.bend      the whole buffer (i = 0, len = n):
        ok_eval, decode_accept, decode_spec;
    proofs/obj/var_bytes_<X>_unique.bend  decode_unique;
    proofs/obj/var_bytes_<X>_rej.bend     decode_reject, decode_none;

and proofs/obj/var_bytes_fix.bend, the reader/writer lemmas of the fixed field
types. The laws quantify over every buffer B.Buf{thaw(t), n} on a perfect word
tree t of depth d < 29 with n <= 4 2^d (windows: 4 i + len <= 4 2^d).
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import schema  # noqa: E402
import spec_laws as SL  # noqa: E402
import var_laws as VL  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
NAMES = ['ExecutionPayloadHeader']
SRC = None


def src():
    global SRC
    if SRC is None:
        SRC = (ROOT / 'types/fulu_obj.bend').read_text()
    return SRC


class Skip(Exception):
    pass


class FTW(VL.FT):
    """VL.FT, plus uint256 records (read and written like byte records)."""

    def __init__(self, g, t):
        s = g.shape(t)
        if t.kind == 'uint' and s.kind == 'uwide':
            self.t, self.s, self.p = t, s, s.p
            self.size = t.fixed_size()
            self.W = self.size // 4
            self.kind = 'bytes'
            return
        super().__init__(g, t)


def ceil_log2(x):
    return max(0, (x - 1).bit_length())


def kfit(y):
    """The least k with y <= 2^k."""
    return ceil_log2(y)


# ---- one name -------------------------------------------------------------------------------

class Name:
    def __init__(self, g, n, t):
        self.n, self.t, self.g = n, t, g
        s = g.shape(t)
        if s.kind != 'container':
            raise Skip('not a container')
        self.s = s
        self.fields = []
        pos = 0
        var = None
        c = iter(range(100000))
        for fname, ft in t.fields:
            fs = g.shape(ft)
            if ft.fixed():
                size = ft.fixed_size()
                if size % 4:
                    raise Skip('fixed field not whole words')
                if fs.kind in ('fixwords', 'packed'):
                    m = re.search(rf'^def {fs.p}_read\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & O\.Words: '
                                  rf'O\.copy_into\(buf, off, {size}, Array\.new\(U32, (\d+)n, 0\)\)$', src(), re.M)
                    if not m:
                        raise Skip(f'words field {fname}: reader shape')
                    f = {'kind': 'words', 'dz': int(m.group(1)), 'p': fs.p, 'size': size, 'W': size // 4}
                else:
                    ft_ = FTW(g, ft)
                    f = {'kind': 'fix', 'ft': ft_, 'p': ft_.p, 'size': size, 'W': size // 4}
                node = SL.walk(g, ft, c)
                f['node'] = node
                f.update({'name': fname, 't': ft, 'c': pos, 'k': pos // 4})
                self.fields.append(f)
                pos += size
            else:
                if not (ft.kind == 'bytelist' and fs.kind == 'bytelist'):
                    raise Skip(f'variable field {fname} is not a byte list')
                if var is not None:
                    raise Skip('more than one variable field')
                var = {'kind': 'var', 'name': fname, 't': ft, 'c': pos, 'k': pos // 4, 'p': fs.p, 'LIM': ft.size}
                self.fields.append(var)
                pos += 4
        if var is None:
            raise Skip('no variable field')
        self.FS, self.H = pos, pos // 4
        self.var = var
        self.po, self.cvar = var['k'], var['c']
        self.lp, self.LIM = var['p'], var['LIM']
        self.KY = kfit(31 + self.LIM)            # YL(L) <= 2^KY
        self.R5 = (31 + self.LIM) >> 5
        self.KZ = ceil_log2(self.R5 * 8 + 8)     # the storage depth of the byte list is at most KZ
        self.check_runtime()

    def check_runtime(self):
        n, FS, lp, LIM = self.n, self.FS, self.lp, self.LIM
        want = [f'def {n}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {n}_ok_len(U32.is_le({FS}, len), buf, off, len)',
                f'    case True{{}}: {n}_v0(off, len, B.read32(buf, (off + {self.cvar} : U32)))',
                f'  {n}_c0(U32.is_eq(o0, {FS}), buf, off, len, o0)',
                f'    case True{{}}: {n}_v1(off, len, o0, {lp}_ok(buf, (off + o0 : U32), (len - o0 : U32)))',
                f'def {lp}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, U32.is_le(len, {LIM}))',
                f'def {lp}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)']
        for x in want:
            if x not in src():
                raise Skip('runtime shape differs: ' + x)

    # -- terms --
    def slot(self, k):
        return f'VB.slot(t, Nat.add({k}n, i))'

    def words(self, f):
        return [self.slot(f['k'] + j) for j in range(f['W'])]

    def obj(self, f):
        """The object the reader builds for field f of the window."""
        if f['kind'] == 'fix':
            return f['ft'].obj(self.words(f))
        if f['kind'] == 'words':
            return f'O.Words{{FD.array__thaw(U32, VB.mone({f["W"]}n, Nat.add({f["k"]}n, i), 0n, {f["dz"]}n, VC.ZT({f["dz"]}n), t)), {f["size"]}}}'
        return 'O.Words{FD.array__thaw(U32, MKw(t, i, len)), LL(len)}'

    def node(self, f):
        nd = f['node']
        mp = {int(w[1:]): self.slot(f['k'] + j) for j, w in enumerate(nd.words)}
        sub = lambda s: re.sub(r'\bx(\d+)\b', lambda m: mp[int(m.group(1))], s)  # noqa: E731
        return {'val': sub(nd.val), 'sch': nd.sch, 'proof': sub(nd.proof), 'words': [mp[int(w[1:])] for w in nd.words]}


def fname(x, part=''):
    return ROOT / f'proofs/obj/var_bytes_{x.n}{part}.bend'


HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/nat_bytes.bend as N',
        'import ../../spec/fulu_schemas.bend as Spec', 'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS',
        'import ./vbuf.bend as VB', 'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD',
        'import ./vfix.bend as VF', 'import ./vbytes.bend as VY', 'import ./vbspec.bend as VZ', 'import ./var_bytes_fix.bend as VT']


def fix_module(fts):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/fulu_obj.bend as T', 'import ../compact/found.bend as F', 'import ../compact/arith.bend as A',
         'import ./vbuf.bend as VB', 'import ./vfix.bend as VF', '',
         '# GENERATED by codegen/var_bytes.py. Do not edit.',
         '# Readers and writers of the fixed field types at a word-aligned offset 4 i',
         '# (symbolic), on the array model (as var_fix_types.bend, codegen/var_laws.py).', '']
    for ft in fts:
        L += VL.rd_lemma(ft) + [''] + VL.put_lemma(ft) + ['']
    return '\n'.join(L) + '\n'


# ---- the reader plan ------------------------------------------------------------------------

def read_plan(x):
    """The leaf reads of X_read(buf, off, len) in evaluation order: a list of
    (context with '@' for the call, call term, value, kind, field) and the
    object term. Mirrors codegen/generate.py emit_fieldset / emit_wide."""
    g, s = x.g, x.s
    F = [(f, g.shape(ft)) for f, ft in x.t.fields]
    hoff, fixed_part = G.container_layout(F)
    assert fixed_part == x.FS
    byname = {f['name']: f for f in x.fields}
    leaves = []

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
                leaves.append((c, f'B.read32(VF.BF(t, n), U32.add(off, {f["c"]}))', str(x.FS), 'off', f))
                vals.append(str(x.FS))
            else:
                if f['kind'] == 'var':
                    end = vend if mode == 'group' else 'len'
                    call = f'T.{f["p"]}_read(VF.BF(t, n), U32.add(off, {x.FS}), U32.sub({end}, {x.FS}))'
                else:
                    call = f'T.{f["p"]}_read(VF.BF(t, n), U32.add(off, {f["c"]}), {f["size"]})'
                v = x.obj(f)
                leaves.append((c, call, v, f['kind'], f))
                vals.append(v)
        return f'T.{R}{{' + ', '.join(vals[len(var):]) + '}'

    names = [f for f, _ in F]
    if len(F) <= G.GROUP:
        OBJ = fieldset(s.p, s.t.name, names, None, '@', 'plain')
        return leaves, OBJ
    groups = []
    for k in range(0, len(F), G.GROUP):
        groups.append((k // G.GROUP, names[k:k + G.GROUP], hoff[k:k + G.GROUP], [fs for _, fs in F[k:k + G.GROUP]]))
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
            leaves.append((frame, f'B.read32(VF.BF(t, n), U32.add(off, {firstvar[st[1]]}))', str(x.FS), 'off', f))
            vals.append(str(x.FS))
            vv[st[1]] = str(x.FS)
        else:
            gk = st[1]
            later = [q for q in vg if q > gk]
            vend = vv[later[0]] if later else 'len'
            gp = f'{s.p}_g{gk}'
            v = fieldset(gp, gp, groups[gk][1], vend, frame, 'group')
            vals.append(v)
    return leaves, f'T.{s.t.name}{{' + ', '.join(vals[len(vg):]) + '}'


# ---- the window module ----------------------------------------------------------------------

WH = ('+eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},\n'
      '    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}')
WHa = 'eo, hd, hw'
PF = '+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}'


def win_text(x):
    n, FS, H, po, cvar, LIM, KY, KZ = x.n, x.FS, x.H, x.po, x.cvar, x.LIM, x.KY, x.KZ
    Tn = f'T.{n}'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    HX = '+hx: {BLW(LL(len)) == True{} : Bool}'
    L = list(HEAD) + ['', '# GENERATED by codegen/var_bytes.py. Do not edit.',
                      f'# {n} at a word-aligned window (off = 4 i, len) of a buffer: the validator,',
                      '# the reader and the spec parts of the value (see the module docstring of',
                      '# codegen/var_bytes.py).', '']
    w = L.append
    w(f'''def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{{}}: False{{}}
    case True{{}}:
      match b:
        case False{{}}: False{{}}
        case True{{}}: c

def chk_a(+a: Bool, +b: Bool, +c: Bool, +h: {{chk3(a, b, c) == True{{}} : Bool}}) -> {{a == True{{}} : Bool}}:
  match a:
    case False{{}}: h
    case True{{}}: {{==}}

def chk_b(+a: Bool, +b: Bool, +c: Bool, +h: {{chk3(a, b, c) == True{{}} : Bool}}) -> {{b == True{{}} : Bool}}:
  match a b:
    case False{{}} _: Empty.absurd({{b == True{{}} : Bool}}, FD.logic__false_true(h))
    case True{{}} False{{}}: h
    case True{{}} True{{}}: {{==}}

def chk_c(+a: Bool, +b: Bool, +c: Bool, +h: {{chk3(a, b, c) == True{{}} : Bool}}) -> {{c == True{{}} : Bool}}:
  match a b:
    case False{{}} _: Empty.absurd({{c == True{{}} : Bool}}, FD.logic__false_true(h))
    case True{{}} False{{}}: Empty.absurd({{c == True{{}} : Bool}}, FD.logic__false_true(h))
    case True{{}} True{{}}: h

# The byte list's check: its length is at most the limit.
def BLW(+L: U32) -> Bool: U32.is_le(L, {LIM})
def LL(+len: U32) -> U32: U32.sub(len, {FS})
def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add({po}n, i))

def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> Bool:
  chk3(U32.is_le({FS}, len), U32.is_eq(SPOw(t, i), {FS}), BLW(U32.sub(len, SPOw(t, i))))

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {{{Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}}:
  match ok:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def leFS(+len: U32, {HA}) -> {{Nat.is_le({FS}n, U32.to_nat(len)) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le({FS}, len), Nat.is_le({FS}n, U32.to_nat(len)), VU.le_u32({FS}, len), ha)

def enFS(+len: U32, {HA}) -> {{Nat.add({FS}n, U32.to_nat(LL(len))) == U32.to_nat(len) : Nat}}:
  %Equal.sym(Nat, U32.to_nat(LL(len)), Nat.sub(U32.to_nat(len), {FS}n), FD.u32__sub_nat(len, {FS}, leFS(len, ha))) : {{Nat.add({FS}n, _) == U32.to_nat(len) : Nat}}
  FD.nat__sub_add(U32.to_nat(len), {FS}n, leFS(len, ha))

def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {{Nat.is_le(A.quad(k), U32.to_nat(len)) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{{}} : Bool}}) -> {{Nat.is_le(A.quad(Nat.add(k, i)), P) == True{{}} : Bool}}:
  %VF.quad_add(k, i) : {{Nat.is_le(_, P) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, P) == True{{}} : Bool}}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

# The byte offset off + c of header byte c = 4 k (k <= H) is word k + i.
def eoc(+d: Nat, +i: Nat, +off: U32, +len: U32, +k: Nat, +c: U32, +ec: {{U32.to_nat(c) == A.quad(k) : Nat}},
    +hkF: {{Nat.is_le(A.quad(k), {FS}n) == True{{}} : Bool}}, {WH}, {HA})
    -> {{U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}}:
  VF.off_add(off, c, i, k, 2n+d, eo, ec, hd,
    winb(k, i, len, A.quad(VB.pw(d)), FD.nat__le_trans(A.quad(k), {FS}n, U32.to_nat(len), hkF, leFS(len, ha)), hw))

# Header words k < H of the window are below 2^d.
def hiw(+d: Nat, +i: Nat, +len: U32, +k: Nat, +hk: {{Nat.is_lt(k, {H}n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{{}} : Bool}}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add({H}n, i), VB.pw(d), VB.lt_kk(k, {H}n, i, hk),
    VC.quad_inv(Nat.add({H}n, i), VB.pw(d), winb({H}n, i, len, A.quad(VB.pw(d)), leFS(len, ha), hw)))

def okw_c0(+t: FD.array__Tree<U32>, +n: U32, +off: U32, +len: U32, +i: Nat, +b: Bool)
    -> {{{Tn}_c0(b, VF.BF(t, n), off, len, SPOw(t, i)) == (VF.BF(t, n), chk3(True{{}}, b, BLW(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}}:
  match b:
    case False{{}}: {{==}}
    case True{{}}: c1_id(BLW(U32.sub(len, SPOw(t, i))), VF.BF(t, n), off, len, SPOw(t, i))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF},
    +a: Bool, +ea: {{U32.is_le({FS}, len) == a : Bool}})
    -> {{{Tn}_ok_len(a, VF.BF(t, n), off, len) == (VF.BF(t, n), chk3(a, U32.is_eq(SPOw(t, i), {FS}), BLW(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}}:
  match a:
    case False{{}}: {{==}}
    case True{{}}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, {cvar})), (VF.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, {cvar}), Nat.add({po}n, i), eoc(d, i, off, len, {po}n, {cvar}, {{==}}, {{==}}, eo, hd, hw, ea),
            VB.lt32(d, FD.nat__lt_trans(d, 29n, 31n, hd, {{==}})), hiw(d, i, len, {po}n, {{==}}, hw, ea), pf)) :
        {{{Tn}_v0(off, len, _) == (VF.BF(t, n), chk3(True{{}}, U32.is_eq(SPOw(t, i), {FS}), BLW(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}}
      okw_c0(t, n, off, len, i, U32.is_eq(SPOw(t, i), {FS}))

# The validator on the window returns the buffer and CHKw(t, i, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF})
    -> {{{Tn}_ok(VF.BF(t, n), off, len) == (VF.BF(t, n), CHKw(t, i, len)) : B.Buf & Bool}}:
  okw_len(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_le({FS}, len), {{==}})

# ---- the byte list's bounds --------------------------------------------------------------------

def hLx(+len: U32, {HX}) -> {{Nat.is_le(U32.to_nat(LL(len)), {LIM}n) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le(LL(len), {LIM}), Nat.is_le(U32.to_nat(LL(len)), U32.to_nat({LIM})), VU.le_u32(LL(len), {LIM}), hx)

def hyL(+len: U32, {HX}) -> {{Nat.is_le(VC.YL(LL(len)), VB.pw({KY}n)) == True{{}} : Bool}}:
  FD.nat__le_trans(VC.YL(LL(len)), {31 + LIM}n, VB.pw({KY}n), hLx(len, hx), {{==}})

# The byte list's words lie in the buffer: NW + H + i <= 2^d.
def hsw(+d: Nat, +i: Nat, +len: U32, +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, {HX})
    -> {{Nat.is_le(Nat.add(VC.NW(LL(len)), Nat.add({H}n, i)), VB.pw(d)) == True{{}} : Bool}}:
  +e1 = Equal.cong(Nat, Nat, z => Nat.add(A.quad(i), z), U32.to_nat(len), Nat.add({FS}n, U32.to_nat(LL(len))), Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)))
  +e2 = Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), {FS}n), U32.to_nat(LL(len))), Nat.add(A.quad(i), Nat.add({FS}n, U32.to_nat(LL(len)))), FD.nat__add_assoc(A.quad(i), {FS}n, U32.to_nat(LL(len))))
  +e3 = Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(LL(len))), Nat.add(A.quad(i), {FS}n), Nat.add({FS}n, A.quad(i)), FD.nat__add_comm(A.quad(i), {FS}n))
  +e = Equal.trans(Nat, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(i), Nat.add({FS}n, U32.to_nat(LL(len)))), Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), e1,
    Equal.trans(Nat, Nat.add(A.quad(i), Nat.add({FS}n, U32.to_nat(LL(len)))), Nat.add(Nat.add(A.quad(i), {FS}n), U32.to_nat(LL(len))), Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), e2, e3))
  VY.nw_room(Nat.add({H}n, i), LL(len), VB.pw(d), {KY}n, {{==}}, hyL(len, hx),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), e, hw))

def hHi(+d: Nat, +i: Nat, +len: U32, +hs: {{Nat.is_le(Nat.add(VC.NW(LL(len)), Nat.add({H}n, i)), VB.pw(d)) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add({H}n, i), VB.pw(d)) == True{{}} : Bool}}:
  FD.nat__le_trans(Nat.add({H}n, i), Nat.add(VC.NW(LL(len)), Nat.add({H}n, i)), VB.pw(d), Order.left_below_sum(VC.NW(LL(len)), Nat.add({H}n, i)), hs)

# The storage of the byte list: depth DZ <= {KZ}.
def DZ(+len: U32) -> Nat: B.words_depth(VC.WZ(LL(len)))

def d3m(+a: Nat, +b: Nat, +h: {{Nat.is_le(a, b) == True{{}} : Bool}}) -> {{Nat.is_le(VB.d3(a), VB.d3(b)) == True{{}} : Bool}}:
  Order.double_monotone(Nat.double(Nat.double(a)), Nat.double(Nat.double(b)), Order.double_monotone(Nat.double(a), Nat.double(b), Order.double_monotone(a, b, h)))

def hWZ(+len: U32, {HX}) -> {{Nat.is_le(U32.to_nat(VC.WZ(LL(len))), O.pow2n({KZ}n)) == True{{}} : Bool}}:
  %Equal.sym(Nat, U32.to_nat(VC.WZ(LL(len))), Nat.add(VB.d3(VD.s_rng(5n, VC.YL(LL(len)))), 8n), VC.eWZ(LL(len), {KY}n, {{==}}, hyL(len, hx))) :
    {{Nat.is_le(_, O.pow2n({KZ}n)) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add(VB.d3(VD.s_rng(5n, VC.YL(LL(len)))), 8n), Nat.add(VB.d3({x.R5}n), 8n), O.pow2n({KZ}n),
    Order.add_right(VB.d3(VD.s_rng(5n, VC.YL(LL(len)))), VB.d3({x.R5}n), 8n, d3m(VD.s_rng(5n, VC.YL(LL(len))), {x.R5}n, VC.rng_mono(5n, VC.YL(LL(len)), {31 + LIM}n, hLx(len, hx)))),
    {{==}})

def hdz(+len: U32, {HX}) -> {{Nat.is_le(DZ(len), {KZ}n) == True{{}} : Bool}}:
  VD.wd_min(VC.WZ(LL(len)), {KZ}n, hWZ(len, hx))

def hdz31(+len: U32, {HX}) -> {{Nat.is_lt(DZ(len), 31n) == True{{}} : Bool}}:
  FD.nat__le_lt_trans(DZ(len), {KZ}n, 31n, hdz(len, hx), {{==}})
''')
    w(f'def zeros_at(+du: U32, +k: Nat, +e: {{U32.to_nat(du) == k : Nat}}, +hk: {{Nat.is_le(k, {KZ}n) == True{{}} : Bool}})')
    w('    -> {B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}:')
    w('  match k:')
    for j in range(KZ + 1):
        w(f'    case {j}n:')
        w(f'      %Equal.sym(U32, du, {j}, FD.u32__injective(du, {j}, e)) : {{B.zeros(_) == Array.new(U32, {j}n, 0) : Array<U32>}}')
        w('      {==}')
    w(f'    case {KZ + 1}n+p: Empty.absurd({{B.zeros(du) == Array.new(U32, {KZ + 1}n+p, 0) : Array<U32>}}, FD.logic__false_true(hk))')
    w(f'''
def ez(+len: U32, {HX}) -> {{B.zeros(B.words_depth_u(VC.WZ(LL(len)))) == Array.new(U32, DZ(len), 0) : Array<U32>}}:
  zeros_at(B.words_depth_u(VC.WZ(LL(len))), DZ(len), VD.wdu(VC.WZ(LL(len))), hdz(len, hx))

def hr(+len: U32, {HX}) -> {{Nat.is_le(Nat.add(VC.NW(LL(len)), 0n), VB.pw(DZ(len))) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add(VC.NW(LL(len)), 0n), VC.NW(LL(len)), FD.nat__add_zero(VC.NW(LL(len)))) : {{Nat.is_le(_, VB.pw(DZ(len))) == True{{}} : Bool}}
  %Equal.sym(Nat, VB.pw(DZ(len)), O.pow2n(DZ(len)), VD.s_pow2_eq(DZ(len))) : {{Nat.is_le(VC.NW(LL(len)), _) == True{{}} : Bool}}
  FD.nat__le_trans(VC.NW(LL(len)), U32.to_nat(VC.WZ(LL(len))), O.pow2n(DZ(len)),
    VC.nw_le_wz(LL(len), {KY}n, {{==}}, hyL(len, hx)),
    VD.wd_cover(VC.WZ(LL(len)), {KZ}n, {{==}}, hWZ(len, hx)))

# The byte list's storage: the masked copy of its words.
def MKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> FD.array__Tree<U32>:
  VY.MK(LL(len), DZ(len), VB.mone(VC.NW(LL(len)), Nat.add({H}n, i), 0n, DZ(len), VC.ZT(DZ(len)), t))

# The offset word, once checked, reads as {FS}.
def rdo(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}})
    -> {{B.read32(VF.BF(t, n), U32.add(off, {cvar})) == (VF.BF(t, n), {FS}) : B.Buf & U32}}:
  %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, {cvar})), (VF.BF(t, n), SPOw(t, i)),
      VF.rd32a(d, t, n, U32.add(off, {cvar}), Nat.add({po}n, i), eoc(d, i, off, len, {po}n, {cvar}, {{==}}, {{==}}, eo, hd, hw, ha),
        VB.lt32(d, FD.nat__lt_trans(d, 29n, 31n, hd, {{==}})), hiw(d, i, len, {po}n, {{==}}, hw, ha), pf)) :
    {{_ == (VF.BF(t, n), {FS}) : B.Buf & U32}}
  %Equal.sym(U32, SPOw(t, i), {FS}, epo) : {{(VF.BF(t, n), _) == (VF.BF(t, n), {FS}) : B.Buf & U32}}
  {{==}}
''')
    # ---- the reader ----
    leaves, OBJ = read_plan(x)
    RHS = '(VF.BF(t, n), OBJw(t, i, len))'
    TY = f'B.Buf & {Tn}'
    w(f'def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> {Tn}: {OBJ}')
    w('')
    w('# The reader on the window, when the checks hold.')
    w(f'def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF},')
    w(f'    {HA}, +epo: {{SPOw(t, i) == {FS} : U32}}, {HX})')
    w(f'    -> {{{Tn}_read(VF.BF(t, n), off, len) == {RHS} : {TY}}}:')
    w('  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})')
    w('  +hs = hsw(d, i, len, hw, ha, hx)')
    w('  +hH = hHi(d, i, len, hs)')

    def ecf(k, c):
        return f'eoc(d, i, off, len, {k}n, {c}, {{==}}, {{==}}, eo, hd, hw, ha)'

    def hb(W, k):
        return (f'FD.nat__le_trans(Nat.add({W}n, Nat.add({k}n, i)), Nat.add({H}n, i), VB.pw(d), '
                f'Order.left_below_sum({H - W - k}n, Nat.add({W}n, Nat.add({k}n, i))), hH)')
    for ctx, call, val, kind, f in leaves:
        pat = ctx.replace('@', '_')
        if kind == 'off':
            w(f'  %Equal.sym(B.Buf & U32, {call}, (VF.BF(t, n), {val}), rdo(d, t, n, i, off, len, eo, hd, hw, pf, ha, epo)) :')
        elif kind == 'fix':
            ft = f['ft']
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {call}, (VF.BF(t, n), {val}),')
            w(f'      VT.rd_{ft.p}(d, t, n, U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {ecf(f["k"], f["c"])}, hd, pf, {hb(f["W"], f["k"])})) :')
        elif kind == 'words':
            e = ecf(f['k'], f['c'])
            kw = kfit(31 + f['size'])
            w(f'  %Equal.sym(B.Buf & O.Words, {call}, (VF.BF(t, n), {val}),')
            w(f'      VY.copy_into_any(d, t, n, U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {f["size"]}, {f["dz"]}n, {kw}n, pf, hd31, {{==}},')
            w(f'        VF.al_3(U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {e}), VF.al_q(U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {e}),')
            w(f'        {hb(f["W"], f["k"])}, {{==}}, {{==}}, {{==}})) :')
        else:
            e = ecf(H, FS)
            w(f'  %Equal.sym(B.Buf & O.Words, {call}, (VF.BF(t, n), {val}),')
            w(f'      VY.copy_in_any(d, t, n, U32.add(off, {FS}), Nat.add({H}n, i), LL(len), DZ(len), {KY}n, pf, hd31, hdz31(len, hx), ez(len, hx),')
            w(f'        VF.al_3(U32.add(off, {FS}), Nat.add({H}n, i), {e}), VF.al_q(U32.add(off, {FS}), Nat.add({H}n, i), {e}),')
            w(f'        hs, hr(len, hx), {{==}}, hyL(len, hx))) :')
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(f'''
# When the window's checks hold, the reader returns OBJw(t, i, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF},
    +hchk: {{CHKw(t, i, len) == True{{}} : Bool}})
    -> {{{Tn}_read(VF.BF(t, n), off, len) == (VF.BF(t, n), OBJw(t, i, len)) : {TY}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, i), {FS})
  +c = BLW(U32.sub(len, SPOw(t, i)))
  +epo = FD.u32alg__eq_of(SPOw(t, i), {FS}, chk_b(a, b, c, hchk))
  rdw_go(d, t, n, i, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {{BLW(U32.sub(len, z)) == True{{}} : Bool}}, SPOw(t, i), {FS}, epo, chk_c(a, b, c, hchk)))
''')
    L.extend(spec_part(x))
    return '\n'.join(L) + '\n'


def spec_items(x, Y):
    """ITEMS, CHAIN, PL, CAT, PRE, POST, HDR of the window's value with byte list Y."""
    vals, schs, parts, nodes = [], [], [], []
    for f in x.fields:
        if f['kind'] == 'var':
            vals.append(f'S.BytesValue{{{Y}}}')
            schs.append(f'S.ByteList{{{x.LIM}n}}')
            parts.append(f'S.Variable{{{Y}}}')
            nodes.append(None)
        else:
            nd = x.node(f)
            nodes.append(nd)
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
    m = len(vals)

    def items(i):
        return 'S.EmptyItems{}' if i == m else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == m:
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if nodes[i] is not None:
            return (f'F.cat_fixed(Codec.parts({vals[i]}, {schs[i]}), F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.cat_var(Codec.parts({vals[i]}, {schs[i]}), {Y}, Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, '
                f'VZ.bl_parts({x.LIM}n, {Y}, hdom, hlen, VS.fits_mono(4n, List.length(&2, U32, {Y}), {x.LIM}n, hlen, {{==}})), {cat(i + 1)})')
    vi = [f['kind'] for f in x.fields].index('var')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if nd is not None else [str(x.FS)]
    return items(0), chain(0), '[' + ', '.join(parts) + ']', cat(0), PRE, POST, hdr


def spec_part(x):
    n, FS, H, po, LIM, KY = x.n, x.FS, x.H, x.po, x.LIM, x.KY
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    HX = '+hx: {BLW(LL(len)) == True{} : Bool}'
    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr = spec_items(x, 'Y')
    HDR = '[' + ', '.join(hdr) + ']'
    hdrh = '[' + ', '.join(h if j != po else '_' for j, h in enumerate(hdr)) + ']'
    hdrs = '[' + ', '.join(h if j != po else 'SPOw(t, i)' for j, h in enumerate(hdr)) + ']'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    ENC = f'List.append(&2, U32, F.limbs({HDR}), Y)'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), Y)'
    s = 'FD.array__slots(U32, t)'
    YB = 'YB(t, i, len)'
    WIN = f'VS.bt(U32.to_nat(len), F.limbs(VB.wdr(i, {s})))'
    YT = f'VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(Nat.add({H}n, i), {s})))'
    return [f'''
# ---- the spec side -------------------------------------------------------------------------

# The value of the window's fixed words and byte list Y.
def XVw(+t: FD.array__Tree<U32>, +i: Nat, +Y: +List<U32>) -> S.Value: S.Sequence{{{ITEMS}}}

# Its spec parts: one variable part, the header's bytes (the offset is {FS}) and Y.
def encpw(+t: FD.array__Tree<U32>, +i: Nat, +Y: +List<U32>, +hdom: {{SP.bytes_domain(Y) == True{{}} : Bool}},
    +hlen: {{Nat.is_le(List.length(&2, U32, Y), {LIM}n) == True{{}} : Bool}})
    -> {{Codec.parts(XVw(t, i, Y), Spec.{n}()) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}:
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, Y)), Nat.add({FS}n, {LIM}n),
    Order.add_left({FS}n, List.length(&2, U32, Y), {LIM}n, hlen), {{==}})
  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PL}}},
      {CAT}) :
    {{Codec.aggregate(_, None{{}}) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, Y, {POST})), Some{{{ENCR}}}, VZ.enc_fpvb({PRE}, Y, {POST}, hdom, fit)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  {{==}}

# The byte list's value: the first LL(len) bytes of its storage.
def YB(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> +List<U32>: VS.bt(U32.to_nat(LL(len)), F.limbs(FD.array__slots(U32, MKw(t, i, len))))
def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: XVw(t, i, YB(t, i, len))

def len_yb(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, {HX}) -> {{Nat.is_le(List.length(&2, U32, {YB}), {LIM}n) == True{{}} : Bool}}:
  FD.nat__le_trans(List.length(&2, U32, {YB}), U32.to_nat(LL(len)), {LIM}n, VZ.bt_len_le(U32.to_nat(LL(len)), F.limbs(FD.array__slots(U32, MKw(t, i, len)))), hLx(len, hx))

# Those bytes are the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}}, {HX})
    -> {{List.append(&2, U32, F.limbs({HDR}), {YB}) == {WIN} : +List<U32>}}:
  +hs = hsw(d, i, len, hw, ha, hx)
  +hsl = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(VC.NW(LL(len)), Nat.add({H}n, i)), z) == True{{}} : Bool}}, VB.pw(d), VB.len({s}), Equal.sym(Nat, VB.len({s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hs)
  +hpre = FD.nat__le_trans(Nat.add({H}n, i), Nat.add(VC.NW(LL(len)), Nat.add({H}n, i)), VB.len({s}), Order.left_below_sum(VC.NW(LL(len)), Nat.add({H}n, i)), hsl)
  %enFS(len, ha) : {{List.append(&2, U32, F.limbs({HDR}), {YB}) == VS.bt(_, F.limbs(VB.wdr(i, {s}))) : +List<U32>}}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad({H}n), U32.to_nat(LL(len))), F.limbs(VB.wdr(i, {s}))),
      List.append(&2, U32, F.limbs(VS.wtake({H}n, VB.wdr(i, {s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr({H}n, VB.wdr(i, {s}))))),
      VY.bt_split({H}n, U32.to_nat(LL(len)), VB.wdr(i, {s}), VZ.wdr_len_le({H}n, i, {s}, hpre))) :
    {{List.append(&2, U32, F.limbs({HDR}), {YB}) == _ : +List<U32>}}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add({H}n, 0n), VB.wdr(i, {s})), VF.app(VF.wpre({H}n, i, {s}), VS.wtake(0n, VB.wdr(Nat.add({H}n, i), {s}))),
      VF.wt_pre({H}n, 0n, i, {s}, hpre)) :
    {{List.append(&2, U32, F.limbs({HDR}), {YB}) == List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr({H}n, VB.wdr(i, {s}))))) : +List<U32>}}
  %Equal.sym(List<&2, U32>, VB.wdr({H}n, VB.wdr(i, {s})), VB.wdr(Nat.add(i, {H}n), {s}), VF.wdr_add({H}n, i, {s})) :
    {{List.append(&2, U32, F.limbs({HDR}), {YB}) == List.append(&2, U32, F.limbs({hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(_))) : +List<U32>}}
  %Equal.sym(Nat, Nat.add(i, {H}n), Nat.add({H}n, i), FD.nat__add_comm(i, {H}n)) :
    {{List.append(&2, U32, F.limbs({HDR}), {YB}) == List.append(&2, U32, F.limbs({hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(_, {s})))) : +List<U32>}}
  %Equal.sym(+List<U32>, {YB}, {YT},
      VZ.ybytes(LL(len), DZ(len), Nat.add({H}n, i), t, {KY}n, {{==}}, hyL(len, hx), hr(len, hx), hsl)) :
    {{List.append(&2, U32, F.limbs({HDR}), _) == List.append(&2, U32, F.limbs({hdrs}), {YT}) : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({hdrh}), {YT}) == List.append(&2, U32, F.limbs({hdrs}), {YT}) : +List<U32>}}
  {{==}}

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}}, {HX})
    -> {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{{WIN}}}]}} : {MP}}}:
  %bytesw(d, t, n, i, len, pf, hd, hw, ha, epo, hx) :
    {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  encpw(t, i, {YB}, VZ.bd_btl(U32.to_nat(LL(len)), FD.array__slots(U32, MKw(t, i, len))), len_yb(t, i, len, hx))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hchk: {{CHKw(t, i, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{{WIN}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, i), {FS})
  +c = BLW(U32.sub(len, SPOw(t, i)))
  +epo = FD.u32alg__eq_of(SPOw(t, i), {FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, i, len, pf, hd, hw, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {{BLW(U32.sub(len, z)) == True{{}} : Bool}}, SPOw(t, i), {FS}, epo, chk_c(a, b, c, hchk)))
''']


# ---- the whole-buffer laws ------------------------------------------------------------------

def top_text(x):
    n = x.n
    Tn = f'T.{n}'
    W = fname(x, '_win').name
    D = f'B.Buf & Maybe<&1, {Tn}>'
    return '\n'.join(list(HEAD) + [f'import ./{W} as W', '', '# GENERATED by codegen/var_bytes.py. Do not edit.',
                                   f'# {n}: the validator, the decoder, and the spec relation of the decoded value',
                                   '# on a whole buffer (the window laws of the _win module at i = 0, len = n).', '']) + f'''
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VF.BF(t, n)
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: W.CHKw(t, 0n, n)
def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> {Tn}: W.OBJw(t, 0n, n)
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: W.VALw(t, 0n, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))

# The validator returns the buffer and CHK(t, n).
law ok_eval:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  {{{Tn}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}}
def ok_eval(d, t, n, pf, hd, hn):
  W.ok_evalw(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf)

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  {{{Tn}_decode(BF(t, n), n) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, {Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {{{Tn}_built(n, _) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
  %Equal.sym(Bool, CHK(t, n), True{{}}, hchk) :
    {{{Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
  %Equal.sym(B.Buf & {Tn}, {Tn}_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)), W.readw(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf, hchk)) :
    {{{Tn}_some(_) == (BF(t, n), Some{{OBJ(t, n)}}) : {D}}}
  {{==}}

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  Decoding.decodes(Spec.{n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VAL(t, n), Spec.{n}()), Some{{[S.Variable{{VW(t, n)}}]}}, W.specw(d, t, n, 0n, n, pf, hd, hn, hchk)) :
    {{Codec.bytes(_) == Some{{VW(t, n)}} : Maybe<&2, +List<U32>>}}
  {{==}}
'''


def unique_text(x):
    return VL.unique_text(x, x.n, fname(x).name).replace('codegen/var_laws.py', 'codegen/var_bytes.py')


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for nm, t in names.items():
        g.shape(t)
    xs = [Name(g, nm, names[nm]) for nm in NAMES]
    fts = []
    for x in xs:
        for f in x.fields:
            if f['kind'] == 'fix':
                for dft in f['ft'].deps():
                    if dft.p not in [q.p for q in fts]:
                        fts.append(dft)
    out = {ROOT / 'proofs/obj/var_bytes_fix.bend': fix_module(fts)}
    for x in xs:
        out[fname(x, '_win')] = win_text(x)
        out[fname(x)] = top_text(x)
        out[fname(x, '_unique')] = unique_text(x)
    mine = sorted((ROOT / 'proofs/obj').glob('*var_bytes_*.bend'))
    orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out]
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, text in out.items() if not p.exists() or p.read_text() != text]
        if stale or orphans:
            print('stale generated byte-list laws: ' + ', '.join(stale + orphans))
            sys.exit(1)
        print('generated byte-list laws are current')
        return
    for q in orphans:
        (ROOT / q).unlink()
    for p, text in out.items():
        if not p.exists() or p.read_text() != text:
            p.write_text(text)
    print(f'{len(fts)} fixed field types, {len(xs)} names: ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
