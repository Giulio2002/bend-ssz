#!/usr/bin/env python3
"""Spec-connected codec laws of variable-size names whose variable part is a
BYTE LIST (any length, not only whole words).

    python3 codegen/proofs/var/var_bytes.py [--check]

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
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.core import writer  # noqa: E402
from codegen.proofs.var.var_finish import finish  # noqa: E402

from codegen.impl import generate as G  # noqa: E402
from codegen.core import schema  # noqa: E402
from codegen.proofs.laws import spec_laws as SL  # noqa: E402
from codegen.proofs.var import var_laws as VL  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

from codegen.core.paths import ROOT  # noqa: E402
NAMES = ['ExecutionPayloadHeader']
SRC = None


def src():
    global SRC
    if SRC is None:
        SRC = RR.mono_text('fulu')
    return SRC


class Skip(Exception):
    pass


class FTW(VL.FT):
    """VL.FT, plus uint256 records (read and written like byte records)."""

    def __init__(self, g, t):
        s = g.shape(t)
        if (t.kind == 'uint' and s.kind == 'uwide') or (t.kind == 'bits' and s.kind == 'rec' and t.size % 32 == 0):
            self.t, self.s, self.p = t, s, s.p
            self.size = t.fixed_size()
            self.W = self.size // 4
            self.kind = 'bytes'
            return
        if t.kind == 'container' and s.kind == 'container' and s.data:
            self.t, self.s, self.p = t, s, s.p
            self.size = t.fixed_size()
            if self.size % 4:
                raise Skip('not whole words')
            self.W = self.size // 4
            self.kind = 'container'
            self.kids = []
            c = 0
            for (fname, ft), (_, fs) in zip(t.fields, s.fields):
                if fs.kind == 'box':
                    raise Skip('boxed field')
                k = FTW(g, ft)
                self.kids.append((c, k))
                c += k.size
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

    def node(self, f, wt=None):
        nd = f['node']
        wt = wt or (lambda f, j: self.slot(f['k'] + j))
        mp = {int(w[1:]): wt(f, j) for j, w in enumerate(nd.words)}
        sub = lambda s: re.sub(r'\bx(\d+)\b', lambda m: mp[int(m.group(1))], s)  # noqa: E731
        return {'val': sub(nd.val), 'sch': nd.sch, 'proof': sub(nd.proof), 'words': [mp[int(w[1:])] for w in nd.words]}


def fname(x, part=''):
    big = '' if getattr(x, 'big', False) else ''
    return ROOT / f'proofs/obj/{big}var_bytes_{x.n}{part}.bend'


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
         '# GENERATED by var_bytes (codegen). Do not edit.',
         '# Readers and writers of the fixed field types at a word-aligned offset 4 i',
         '# (symbolic), on the array model (as var_fix_types.bend, codegen/proofs/var/var_laws.py).', '']
    for ft in fts:
        L += VL.rd_lemma(ft) + [''] + VL.put_lemma(ft) + ['']
    return '\n'.join(L) + '\n'


# ---- the reader plan ------------------------------------------------------------------------

def read_plan(x):
    """The leaf reads of X_read(buf, off, len) in evaluation order: a list of
    (context with '@' for the call, call term, value, kind, field) and the
    object term. Mirrors codegen/impl/generate.py emit_fieldset / emit_wide."""
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
    L = list(HEAD) + ['', '# GENERATED by var_bytes (codegen). Do not edit.',
                      f'# {n} at a word-aligned window (off = 4 i, len) of a buffer: the validator,',
                      '# the reader and the spec parts of the value (see the module docstring of',
                      '# codegen/proofs/var/var_bytes.py).', '']
    w = L.append
    w(TPL.render('win_text', FS=FS, H=H, HA=HA, HX=HX, KY=KY, KZ=KZ, LIM=LIM, Tn=Tn, cvar=cvar, po=po, x=x))
    w(ZD.zeros_at_text(KZ, 'FD'))
    w(TPL.render('win_text_ez', FS=FS, H=H, HA=HA, HX=HX, KY=KY, KZ=KZ, cvar=cvar, po=po))
    # ---- the reader ----
    leaves, OBJ = read_plan(x)
    RHS = '(VF.BF(t, n), OBJw(t, i, len))'
    TY = f'B.Buf & {Tn}'
    for line in TPL.render('win_text_lines', FS=FS, HA=HA, HX=HX, OBJ=OBJ, RHS=RHS, TY=TY, Tn=Tn).split('\n'):
        w(line)

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
            for line in TPL.render('win_text_lines_2', call=call, e=e, f=f, hb=hb, kw=kw, val=val).split('\n'):
                w(line)
        else:
            e = ecf(H, FS)
            for line in TPL.render('win_text_lines_3', FS=FS, H=H, KY=KY, call=call, e=e, val=val).split('\n'):
                w(line)
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(TPL.render('win_text_readw', FS=FS, TY=TY, Tn=Tn))
    L.extend(spec_part(x))
    return '\n'.join(L) + '\n'


def chain_defs(pfx, decl, args, pdecl, pargs, vals, schs, parts, cdecl=None, cargs=None, proofs=None):
    """Named suffixes of a container's parts chain (callee first): <pfx>V<i>(args) the items
    from field i on, <pfx>S<i>() their schemas, <pfx>P<i>(pargs) their parts. With `proofs`
    (per field ('fixed' | 'var', bytes, proof)), also <pfx>T<i>(cargs): the parts of the fields
    from i on, one def per field. Each unfolds its suffixes by one-step {==} rewrites and closes
    with VS.chain_fixed / VS.chain_var, so no level re-evaluates the parts of the fields after
    it: in one nested F.cat_fixed chain the levels' types met only after whnf, which runs
    Codec.parts to the end (and past the identity budget the whole remaining terms were
    compared by evaluation)."""
    m = len(vals)
    L = []
    for i in range(m, -1, -1):
        if i == m:
            L += [f'def {pfx}V{i}({decl}) -> S.Value: S.EmptyItems{{}}', f'def {pfx}S{i}() -> S.Schema: S.End{{}}',
                  f'def {pfx}P{i}({pdecl}) -> +List<S.Part>: Nil{{}}']
        else:
            L += [f'def {pfx}V{i}({decl}) -> S.Value: S.Items{{{vals[i]}, {pfx}V{i + 1}({args})}}',
                  f'def {pfx}S{i}() -> S.Schema: S.Chain{{{schs[i]}, {pfx}S{i + 1}()}}',
                  f'def {pfx}P{i}({pdecl}) -> +List<S.Part>: Con{{{parts[i]}, {pfx}P{i + 1}({pargs})}}']
    if proofs is None:
        return L
    MP = 'Maybe<&2, +List<S.Part>>'
    ty = lambda i: f'{{Codec.parts({pfx}V{i}({args}), {pfx}S{i}()) == Some{{{pfx}P{i}({pargs})}} : {MP}}}'
    L.append(f'def {pfx}T{m}({cdecl}) -> {ty(m)}: {{==}}')
    for i in range(m - 1, -1, -1):
        kind, xs, prf = proofs[i]
        IT = f'S.Items{{{vals[i]}, {pfx}V{i + 1}({args})}}'
        CH = f'S.Chain{{{schs[i]}, {pfx}S{i + 1}()}}'
        PP = f'Con{{{parts[i]}, {pfx}P{i + 1}({pargs})}}'
        lem = 'VS.chain_fixed' if kind == 'fixed' else 'VS.chain_var'
        L += [f'def {pfx}T{i}({cdecl}) -> {ty(i)}:',
              f'  %Equal.sym(S.Value, {pfx}V{i}({args}), {IT}, {{==}}) : {{Codec.parts(_, {pfx}S{i}()) == Some{{{pfx}P{i}({pargs})}} : {MP}}}',
              f'  %Equal.sym(S.Schema, {pfx}S{i}(), {CH}, {{==}}) : {{Codec.parts({IT}, _) == Some{{{pfx}P{i}({pargs})}} : {MP}}}',
              f'  %Equal.sym(+List<S.Part>, {pfx}P{i}({pargs}), {PP}, {{==}}) : {{Codec.parts({IT}, {CH}) == Some{{_}} : {MP}}}',
              f'  {lem}({vals[i]}, {pfx}V{i + 1}({args}), {schs[i]}, {pfx}S{i + 1}(), {xs}, {pfx}P{i + 1}({pargs}), {prf}, {pfx}T{i + 1}({cargs}))']
    return L


def spec_items(x, Y, wt=None, named=None):
    """ITEMS, CHAIN, PL, CAT, PRE, POST, HDR of the window's value with byte list Y."""
    vals, schs, parts, nodes = [], [], [], []
    for f in x.fields:
        if f['kind'] == 'var':
            vals.append(f'S.BytesValue{{{Y}}}')
            schs.append(f'S.ByteList{{{x.LIM}n}}')
            parts.append(f'S.Variable{{{Y}}}')
            nodes.append(None)
        else:
            nd = x.node(f, wt)
            nodes.append(nd)
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
    m = len(vals)

    def items(i):
        if named:
            return f'{named[0]}V{i}({named[2]})'
        return 'S.EmptyItems{}' if i == m else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        if named:
            return f'{named[0]}S{i}()'
        return 'S.End{}' if i == m else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == m:
            return '{==}'
        rest = f'{named[0]}P{i + 1}({named[4]})' if named else '[' + ', '.join(parts[i + 1:]) + ']'
        # the exact parts forms (VS.chain_fixed / chain_var): each step states the Codec.parts term its
        # parent unfolds to, so no conversion runs the spec encoders (cat_fixed / cat_var's concatenate
        # forms did: ExecutionPayloadHeader encE 5.5 s)
        if nodes[i] is not None:
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, {Y}, {rest}, '
                f'VZ.bl_parts({x.LIM}n, {Y}, hdom, hlen, VS.fits_mono(4n, List.length(&2, U32, {Y}), {x.LIM}n, hlen, {{==}})), {cat(i + 1)})')
    vi = [f['kind'] for f in x.fields].index('var')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if nd is not None else [str(x.FS)]
    if named:
        proofs = [('fixed', f'F.limbs([{", ".join(nodes[i]["words"])}])', nodes[i]['proof']) if nodes[i] is not None else
                  ('var', Y, f'VZ.bl_parts({x.LIM}n, {Y}, hdom, hlen, VS.fits_mono(4n, List.length(&2, U32, {Y}), {x.LIM}n, hlen, {{==}}))')
                  for i in range(m)]
        return (items(0), chain(0), f'{named[0]}P0({named[4]})', f'{named[0]}T0({named[6]})', PRE, POST, hdr,
                chain_defs(*named[:5], vals, schs, parts, named[5], named[6], proofs))
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
    return [TPL.render('spec_part', CAT=CAT, CHAIN=CHAIN, ENC=ENC, ENCR=ENCR, FS=FS, H=H, HA=HA, HDR=HDR, HX=HX, ITEMS=ITEMS, KY=KY, LIM=LIM, M=M, MP=MP, PL=PL, POST=POST, PRE=PRE, WIN=WIN, YB=YB, YT=YT, hdrh=hdrh, hdrs=hdrs, n=n, s=s)]


# ---- the whole-buffer laws ------------------------------------------------------------------

def top_text(x):
    n = x.n
    Tn = f'T.{n}'
    W = fname(x, '_win').name
    D = f'B.Buf & Maybe<&1, {Tn}>'
    return '\n'.join(list(HEAD) + [f'import ./{W} as W', '', '# GENERATED by var_bytes (codegen). Do not edit.',
                                   f'# {n}: the validator, the decoder, and the spec relation of the decoded value',
                                   '# on a whole buffer (the window laws of the _win module at i = 0, len = n).', '']) + TPL.render('top_text', D=D, Tn=Tn, n=n)


def unique_text(x):
    return writer.rebrand(VL.unique_text(x, x.n, fname(x).name), 'var_laws', 'var_bytes')


# ---- the rejection laws ----------------------------------------------------------------------

def rej_text(x, pure=False):
    """pure: only the lines up to inv_v (no window or whole-buffer facts), for codegen/proofs/var/var_bytes_x.py."""
    n, FS, H, po, LIM = x.n, x.FS, x.H, x.po, x.LIM
    P = 4 * po
    kids, _ = VL.spec_schemas(n)
    m = len(x.fields)
    Tn = f'T.{n}'
    fsb = [FS & 255, (FS >> 8) & 255, (FS >> 16) & 255, (FS >> 24) & 255]
    FSL = '[' + ', '.join(map(str, fsb)) + ']'
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T',
         'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P', 'import ../compact/found.bend as F',
         'import ../compact/arith.bend as A', 'import ../compact/bits.bend as BT', 'import ../../proofs/nat_order.bend as Order',
         'import ../../proofs/primitive_invariants.bend as V',
         'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/byte_list.bend as ByteList',
         'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/nat_bytes.bend as N',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
         'import ./spec_fixed.bend as FX', 'import ./dk.bend as DK', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
         'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vrej.bend as VR', 'import ./vfix.bend as VF', 'import ./vbspec.bend as VZ',
         f'import ./{fname(x, "_win").name} as W', f'import ./{fname(x).name} as DC', '',
         '# GENERATED by var_bytes (codegen). Do not edit.',
         f'# Rejection of {n} is exactly the complement of the spec image: every byte',
         '# string the spec relates to some value has the shape the validator checks',
         '# (inv_v), so when CHK(t, n) is False no value is related to the buffer\'s',
         '# bytes (decode_reject), and the decoder returns None (decode_none).', '']
    w = L.append
    MB = 'Maybe<&2, +List<U32>>'
    for line in TPL.render('rej_text_lines', FS=FS, FSL=FSL, LIM=LIM, P=P).split('\n'):
        w(line)

    def absurd(e='e'):
        return f'Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, {e}))'

    def match_value(var, keep, body):
        out = [f'  match {var}:']
        for c, args in VL.VALUE_CTORS:
            pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
            if c == keep[0]:
                pat = f'S.{c}{{' + ', '.join('+' + a for a in keep[1]) + '}'
                out.append(f'    case {pat}: {body}')
            else:
                out.append(f'    case {pat}: {absurd()}')
        return out

    def prefix(i):
        decl, args, parts = [], [], []
        for j, f in enumerate(x.fields[:i]):
            if f['kind'] != 'var':
                decl += [f'+xs{j}: +List<U32>', f'+lx{j}: {{List.length(&2, U32, xs{j}) == {f["size"]}n : Nat}}']
                args += [f'xs{j}', f'lx{j}']
                parts.append(f'S.Fixed{{xs{j}}}')
            else:
                decl += ['+ys: +List<U32>', f'+hk: {{Nat.is_le(List.length(&2, U32, ys), {LIM}n) == True{{}} : Bool}}']
                args += ['ys', 'hk']
                parts.append('S.Variable{ys}')
        return decl, args, parts

    def CC(parts, X):
        for q in reversed(parts):
            X = f'Codec.concatenate(Some{{[{q}]}}, {X})'
        return X

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{Spec.{kids[i]}(), {chain(i + 1)}}}'

    def E(parts, X):
        return f'{{Codec.bytes(Codec.aggregate({CC(parts, X)}, None{{}})) == Some{{bs}} : {MB}}}'

    def sig(name, decl, extra):
        return f'def {name}(' + ', '.join(decl + extra) + ') -> FACTS(bs):'

    vi = [f['kind'] for f in x.fields].index('var')
    pre = list(range(vi))
    post = list(range(vi + 1, m))
    PRE = '[' + ', '.join(f'xs{j}' for j in pre) + ']'
    POST = '[' + ', '.join(f'xs{j}' for j in post) + ']'
    decl_m, args_m, parts_m = prefix(m)
    Pz = sum(x.fields[j]['size'] for j in pre)
    Qz = sum(x.fields[j]['size'] for j in post)
    assert Pz == P and Pz + 4 + Qz == FS

    def lens_eq(name, idx, total):
        w(f'def {name}(' + ', '.join(decl_m) + f') -> {{VR.lens([' + ', '.join(f'xs{j}' for j in idx) + f']) == {total}n : Nat}}:')
        cur = [f'List.length(&2, U32, xs{j})' for j in idx]

        def term(c):
            t = '0n'
            for q in reversed(c):
                t = f'Nat.add({q}, {t})'
            return t
        for a, j in enumerate(idx):
            mot = cur[:a] + ['_'] + cur[a + 1:]
            w(f'  %Equal.sym(Nat, List.length(&2, U32, xs{j}), {x.fields[j]["size"]}n, lx{j}) : {{{term(mot)} == {total}n : Nat}}')
            cur[a] = f'{x.fields[j]["size"]}n'
        w('  {==}')
        w('')
    lens_eq('eP', pre, Pz)
    lens_eq('eQ', post, Qz)
    ALL = ', '.join(args_m)
    OUT = f'VR.OUT({PRE}, ys, {POST})'
    w('def f_off(' + ', '.join(decl_m) + f') -> {{VS.bt(4n, VS.bdr({P}n, {OUT})) == {FSL} : +List<U32>}}:')
    for line in TPL.render('rej_text_lines_2', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE, Qz=Qz).split('\n'):
        w(line)
    w('def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FS}n, List.length(&2, U32, ys)) : Nat}}:')
    for line in TPL.render('rej_text_lines_3', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE, Qz=Qz).split('\n'):
        w(line)
    PLIST = '[' + ', '.join(parts_m) + ']'
    w(sig('inv_fin', decl_m, ['+bs: +List<U32>', '+b5: Bool',
          f'+e: {{Codec.bytes(Codec.one(SP.optional(b5, {OUT}), None{{}})) == Some{{bs}} : {MB}}}']))
    for line in TPL.render('rej_text_lines_4', ALL=ALL, OUT=OUT, absurd=absurd).split('\n'):
        w(line)
    b5 = f'Bool.and(Layout.bytes_valid({PLIST}), N.fits(4n, Nat.add(Layout.fixed_size({PLIST}), List.length(&2, U32, Layout.payloads({PLIST})))))'
    w(sig(f'st{m}', decl_m, ['+items: S.Value', '+bs: +List<U32>', '+e: ' + E(parts_m, 'Codec.parts(items, S.End{})')]))
    L.extend(match_value('items', ('EmptyItems', []), f'inv_fin({ALL}, bs, {b5}, e)'))
    w('')
    for i in reversed(range(m)):
        f = x.fields[i]
        decl, args, parts = prefix(i)
        A = ', '.join(args + [''])
        sch = f'Spec.{kids[i]}()'
        nxt = f'Codec.parts(t, {chain(i + 1)})'
        if f['kind'] != 'var':
            z = f['size']
            w(sig(f'fp{i}', decl, ['+ps: +List<S.Part>', f'hf: DF.single(Some{{{z}n}}, ps)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            for line in TPL.render('rej_text_lines_6', A=A, i=i, z=z).split('\n'):
                w(line)
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            for line in TPL.render('rej_text_lines_7', A=A, absurd=absurd, i=i).split('\n'):
                w(line)
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({A}Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), t, bs, e)')
            w('')
        else:
            w(sig('vbl', decl, ['+ys: +List<U32>', '+t: S.Value', '+bs: +List<U32>', '+b: Bool',
                                f'+eb: {{ByteList.domain({LIM}n, ys) == b : Bool}}',
                                '+e: ' + E(parts, f'Codec.concatenate(Codec.one(SP.optional(b, ys), None{{}}), {nxt})')]))
            for line in TPL.render('rej_text_lines_8', A=A, LIM=LIM, absurd=absurd, i=i).split('\n'):
                w(line)
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            L.extend(match_value('h', ('BytesValue', ['ys']), f'vbl({A}ys, t, bs, ByteList.domain({LIM}n, ys), {{==}}, e)'))
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+bs: +List<U32>', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 't']), f'fd{i}({A}h, t, bs, e)'))
        w('')
    for line in TPL.render('rej_text_lines_5', MB=MB, n=n).split('\n'):
        w(line)
    L.extend(match_value('v', ('Sequence', ['items']), 'st0(items, bs, e)'))
    w('')
    if pure:
        return L
    R = FS - P
    body = REJ + REJW + REJW_BL
    for a, b in [('@Tn', Tn), ('@n', n), ('@FSL', FSL), ('@FS', str(FS)), ('@PO', str(po)), ('@P', str(P)), ('@H', str(H)),
                 ('@R4', str(R - 4)), ('@R', str(R)), ('@LIM', str(LIM)),
                 ('@B0', str(fsb[0])), ('@B1', str(fsb[1])), ('@B2', str(fsb[2])), ('@B3', str(fsb[3]))]:
        body = body.replace(a, b)
    w(body)
    return '\n'.join(L) + '\n'


REJ = VL.REJ.split('# The offset word\'s index is below 2^d.')[0] + """# The offset word's index is below 2^d.
def hpoS(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hF: {Nat.is_le(@FSn, U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_lt(@POn, VB.len(SL(t))) == True{} : Bool}:
  %Equal.sym(Nat, VB.len(SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)) : {Nat.is_lt(@POn, _) == True{} : Bool}
  F.nat__lt_le_trans(@POn, @Hn, VB.pw(d), {==}, VC.quad_inv(@Hn, VB.pw(d), F.nat__le_trans(@FSn, U32.to_nat(n), A.quad(VB.pw(d)), hF, hn)))
""" + VL.REJ.split('# The four bytes at the offset field are the limbs of the offset word.')[1].split('def ec_sub(')[0].join(
    ['# The four bytes at the offset field are the limbs of the offset word.', '']) + """def ek_sub(+n: U32, +k: Nat, +en: {U32.to_nat(n) == Nat.add(@FSn, k) : Nat})
    -> {U32.to_nat(W.LL(n)) == k : Nat}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, Nat.add(@FSn, k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, k), en), Order.below_sum(@FSn, k))
  %Equal.sym(Nat, U32.to_nat(W.LL(n)), Nat.sub(U32.to_nat(n), @FSn), F.u32__sub_nat(n, @FS, le)) : {_ == k : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, k), en) : {Nat.sub(_, @FSn) == k : Nat}
  F.nat__add_sub_cancel(@FSn, k)

# The validator accepts every buffer whose bytes have the shape.
def chk_true(+t: F.array__Tree<U32>, +n: U32, +k: Nat, +en: {U32.to_nat(n) == Nat.add(@FSn, k) : Nat}, +hk: {Nat.is_le(k, @LIMn) == True{} : Bool},
    +epo: {W.SPOw(t, 0n) == @FS : U32}) -> {DC.CHK(t, n) == True{} : Bool}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, Nat.add(@FSn, k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, k), en), Order.below_sum(@FSn, k))
  +hL = F.logic__subst(Nat, z => {Nat.is_le(z, @LIMn) == True{} : Bool}, k, U32.to_nat(W.LL(n)), Equal.sym(Nat, U32.to_nat(W.LL(n)), k, ek_sub(n, k, en)), hk)
  %Equal.sym(Bool, U32.is_le(@FS, n), True{}, F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(@FSn, U32.to_nat(n)), U32.is_le(@FS, n), Equal.sym(Bool, U32.is_le(@FS, n), Nat.is_le(@FSn, U32.to_nat(n)), VU.le_u32(@FS, n)), le)) :
    {W.chk3(_, U32.is_eq(W.SPOw(t, 0n), @FS), W.BLW(U32.sub(n, W.SPOw(t, 0n)))) == True{} : Bool}
  %Equal.sym(U32, W.SPOw(t, 0n), @FS, epo) :
    {W.chk3(True{}, U32.is_eq(_, @FS), W.BLW(U32.sub(n, _))) == True{} : Bool}
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(W.LL(n)), U32.to_nat(@LIM)), U32.is_le(W.LL(n), @LIM), Equal.sym(Bool, U32.is_le(W.LL(n), @LIM), Nat.is_le(U32.to_nat(W.LL(n)), U32.to_nat(@LIM)), VU.le_u32(W.LL(n), @LIM)), hL)

def rej_k(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))) == @FSL : +List<U32>},
    ex: DK.Ex(Nat, k => DK.P2({List.length(&2, U32, DC.VW(t, n)) == Nat.add(@FSn, k) : Nat}, {Nat.is_le(k, @LIMn) == True{} : Bool}))) -> Empty:
  (+k, +pr) = ex
  (+hlen, +hk) = pr
  +en = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), Nat.add(@FSn, k), Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), lenVW(d, t, n, pf, hn)), hlen)
  +hF = F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, Nat.add(@FSn, k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, k), en), Order.below_sum(@FSn, k))
  +hp = hpoS(d, t, n, pf, hn, hF)
  +epo = wordFS(W.SPOw(t, 0n), Equal.trans(+List<U32>, FX.limbs([W.SPOw(t, 0n)]), VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), FX.limbs([W.SPOw(t, 0n)]), byteP(t, n, k, en, hp)), hb))
  F.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, chk_true(t, n, k, en, hk, epo)), hchk))

def rej_f(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    facts: FACTS(DC.VW(t, n))) -> Empty:
  (+hb, ex) = facts
  rej_k(d, t, n, pf, hn, hchk, hb, ex)

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.@n(), DC.VW(t, n))
def decode_reject(d, t, n, pf, hn, hchk):
  v => e => rej_f(d, t, n, pf, hn, hchk, inv_v(v, DC.VW(t, n), e))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  {@Tn_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @Tn_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), DC.CHK(t, n)), DC.ok_eval(d, t, n, pf, hd, hn)) :
    {@Tn_built(n, _) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(Bool, DC.CHK(t, n), False{}, hchk) :
    {@Tn_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  {==}
"""

REJW_BL = """
# The window's checks hold for every window whose bytes have the shape.
def chk_truew(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +k: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, k) : Nat}, +hk: {Nat.is_le(k, @LIMn) == True{} : Bool},
    +epo: {W.SPOw(t, i) == @FS : U32}) -> {W.CHKw(t, i, len) == True{} : Bool}:
  +hL = F.logic__subst(Nat, z => {Nat.is_le(z, @LIMn) == True{} : Bool}, k, U32.to_nat(W.LL(len)), Equal.sym(Nat, U32.to_nat(W.LL(len)), k, ek_sub(len, k, en)), hk)
  %Equal.sym(Bool, U32.is_le(@FS, len), True{}, haw(len, k, en)) :
    {W.chk3(_, U32.is_eq(W.SPOw(t, i), @FS), W.BLW(U32.sub(len, W.SPOw(t, i)))) == True{} : Bool}
  %Equal.sym(U32, W.SPOw(t, i), @FS, epo) :
    {W.chk3(True{}, U32.is_eq(_, @FS), W.BLW(U32.sub(len, _))) == True{} : Bool}
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(W.LL(len)), U32.to_nat(@LIM)), U32.is_le(W.LL(len), @LIM), Equal.sym(Bool, U32.is_le(W.LL(len), @LIM), Nat.is_le(U32.to_nat(W.LL(len)), U32.to_nat(@LIM)), VU.le_u32(W.LL(len), @LIM)), hL)

# A window whose bytes have the checked shape passes the window's checks.
def rej_facts(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, facts: FACTS(WV(t, i, len)))
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  (+hb, ex) = facts
  (+k, +pr) = ex
  (+hlen, +hk) = pr
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WV(t, i, len)), Nat.add(@FSn, k), Equal.sym(Nat, List.length(&2, U32, WV(t, i, len)), U32.to_nat(len), lenWV(d, t, i, len, pf, hw)), hlen)
  +epo = wordFS(W.SPOw(t, i), Equal.trans(+List<U32>, FX.limbs([W.SPOw(t, i)]), VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))), FX.limbs([W.SPOw(t, i)]), bytePw(d, t, i, len, k, en, pf, hw)), hb))
  chk_truew(t, i, len, k, en, hk, epo)
"""


# ---- the encoders' dd < 31 twins (deep.dify_out's post pass) -----------------------------------------------
# At dd = 30 a header offset 4 (k + P) can reach 2^32, so eocW takes it strictly below 2^32 (VF.off_add_lt), from
# hr32: 4 ROOM(N, P) < 2^32 (the object ends inside U32 positions), a premise of every twin that takes hdst.
EOC_OLD = (
    "def eoc(+k: Nat, +c: U32, +P: Nat, +pos: U32, +dd: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},\n"
    "    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},\n"
    "    +hq: {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == True{} : Bool})\n"
    "    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:\n"
    "  VF.off_add(pos, c, P, k, 2n+dd, eP, ec, hdd, hq)\n")
P32 = 'FD.spec_common__pow2(32n)'
HQ4S = """
# A run of W >= 1 words at word k + i lies strictly inside the tree: its first word k + i < 2^d.
def hq4S(+k: Nat, +i: Nat, +d: Nat, +W: Nat, +hW: {Nat.is_le(1n, W) == True{} : Bool}, +h: {Nat.is_le(Nat.add(W, Nat.add(k, i)), VB.pw(d)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{} : Bool}:
  +x = Nat.add(k, i)
  FD.nat__lt_le_trans(x, Nat.add(W, x), VB.pw(d), FD.nat__lt_le_trans(x, 1n+x, Nat.add(W, x), FD.nat__lt_succ(x), Order.add_right(1n, W, x, hW)), h)
"""


def enc_strict(q, t, res):
    from codegen.proofs.support import deep
    if 'def eocW(' not in t:
        return t, []
    m = re.search(r'^def hHP\(\+N: U32, \+dd: Nat, \+P: Nat, [^\n]*-> \{Nat\.is_le\(Nat\.add\((\d+)n, P\), VB\.pw\(dd\)\) == True\{\} : Bool\}:\n  FD\.nat__le_trans\(', t, re.M)
    H = m.group(1)
    args, _ = deep._args(t, m.end())
    A_, B_, prf = args[0], args[1], args[3]
    lem = TPL.render('lem', A_=A_, B_=B_, H=H, prf=prf)
    # eocW (and its wrapper eoc) give way to the strict eocW and the original eoc
    a = t.index('def eocW(')
    a = t.rfind('\n# ', 0, a) + 1 if t.rfind('\n\n', 0, a) < t.rfind('\n# ', 0, a) else a
    b = t.index('\ndef ', t.index('def eoc(', a) + 1) + 1
    t = t[:a] + lem + EOC_OLD + '\n' + t[b:]
    # the calls: the strict bound from hr32
    out, pos = [], 0
    for mm in re.finditer(r'(?<![\w.])eocW\(', t):
        if mm.start() < pos:
            continue
        ar, end = deep._args(t, mm.end())
        if t[mm.start() - 4:mm.start()] == 'def ':
            continue
        ar[8] = f'hq32({ar[0]}, N, P, {{==}}, hr32)'
        out.append(t[pos:mm.start()] + 'eocW(' + ', '.join(ar) + ')')
        pos = end
    out.append(t[pos:])
    t = ''.join(out)
    # a run's own words W >= 1 (the SyncCommittee writer's hq4): strict by q32lt
    k, out, pos = 0, [], 0
    for mm in re.finditer(r'VF\.off_add\(', t):
        ar, end = deep._args(t, mm.end())
        if len(ar) == 9 and ar[4] == '2n+dd' and ar[7] == 'hdd' and ar[8].startswith('hq4('):
            hq, _ = deep._args(ar[8], len('hq4('))
            if hq[0] == ar[3] and hq[1] == ar[2] and hq[2] == 'dd' and re.fullmatch(r'\d+n', hq[3]) and int(hq[3][:-1]) >= 1:
                out.append(t[pos:mm.start()] + f'VF.off_add_lt({ar[0]}, {ar[1]}, {ar[2]}, {ar[3]}, {ar[5]}, {ar[6]}, '
                           f'VF.q32lt({ar[3]}, {ar[2]}, dd, hdd, hq4S({ar[3]}, {ar[2]}, dd, {hq[3]}, {{==}}, {hq[4]})))')
                pos, k = end, k + 1
    out.append(t[pos:])
    t = ''.join(out)
    if k:
        t = t.replace('\ndef hq4(', HQ4S + '\ndef hq4(', 1)
    imp = {}
    for mi in re.finditer(r'^import \./(\w+)\.bend as (\w+)', t, re.M):
        src = res.get(q.parent / f'{mi.group(1)}.bend')
        if src:
            h = deep.premise_sigs(src, 'hdst')
            d = {n: h[n] for n in deep.premise_sigs(src, 'hr32')}
            if d:
                imp[mi.group(2) + '.'] = d
    t, bad = deep.add_premise(t, 'hdst', 'hr32',
                              lambda ty: ty.replace('Nat.is_le(ROOM(N, P), VB.pw(dd))', f'Nat.is_lt(A.quad(ROOM(N, P)), {P32})'), imp,
                              wrap='hr32w(N, P, dd, hdd, hdst)', wrap_needs=('N', 'P', 'dd', 'hdd', 'hdst'))
    return t, bad


def main():
    # accepts '--check' (var_finish.finish reads it)
    SL.EXACT = True   # spec_laws' exact spec-parts proofs (F.items_fixed, container_fixed, ...)
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for nm, t in names.items():
        g.shape(t)
    xs = [Name(g, nm, names[nm]) for nm in NAMES]
    fts = []
    for x in xs + [VBN.NName(g, nm, names[nm]) for nm in VBN.ORDER]:
        for f in x.fields:
            if f['kind'] in ('fix', 'comp'):
                for dft in (f['ft'] if f['kind'] == 'fix' else f['rft']).deps():
                    if dft.p not in [q.p for q in fts]:
                        fts.append(dft)
    out = {ROOT / 'proofs/obj/var_bytes_fix.bend': __import__('codegen.proofs.support.deep', fromlist=['_']).dify_fix(fix_module(fts)),
           ROOT / 'proofs/obj/var_bytes_wput.bend': __import__('codegen.proofs.support.deep', fromlist=['_']).dify_out({ROOT / 'proofs/obj/var_bytes_wput.bend': VBE.wput_module(xs + [VBN.NName(g, nm, names[nm]) for nm in VBN.ORDER])}).popitem()[1]}
    for x in xs:
        out[fname(x, '_win')] = win_text(x)
        out[fname(x)] = top_text(x)
        out[fname(x, '_unique')] = unique_text(x)
        out[fname(x, '_rej')] = rej_text(x)
        out[fname(x, '_enc')] = VBE.enc_module_text(x)
    out.update(VBN.outputs(g, names))
    out.update(VBNE.outputs(g, names))
    mine = sorted((ROOT / 'proofs/obj').glob('*var_bytes_*.bend'))
    orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out]
    return finish(out, 'stale generated byte-list laws: ', 'generated byte-list laws are current', orphans, dify=dict(post=enc_strict))




# The windowed rejection facts (used by containers that nest this name).
REJW = """
# ---- the window's bytes (for nesting) ------------------------------------------------------

def WV(t: F.array__Tree<U32>, +i: Nat, +len: U32) -> +List<U32>: VS.bt(U32.to_nat(len), FX.limbs(VB.wdr(i, SL(t))))

# Every value whose spec parts are one variable part has its bytes in the checked shape.
def inv_p(+v: S.Value, +bs: +List<U32>, +e: {Codec.parts(v, Spec.@n()) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}) -> FACTS(bs):
  inv_v(v, bs, Equal.cong(Maybe<&2, +List<S.Part>>, Maybe<&2, +List<U32>>, z => Codec.bytes(z), Codec.parts(v, Spec.@n()), Some{[S.Variable{bs}]}, e))

def lenWV(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, WV(t, i, len)) == U32.to_nat(len) : Nat}:
  VS.bt_len(U32.to_nat(len), FX.limbs(VB.wdr(i, SL(t))), VZ.win_room(d, t, i, len, pf, hw))

def haw(+len: U32, +X: Nat, +en: {U32.to_nat(len) == @FSn+X : Nat}) -> {U32.is_le(@FS, len) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(@FSn, U32.to_nat(len)), U32.is_le(@FS, len), Equal.sym(Bool, U32.is_le(@FS, len), Nat.is_le(@FSn, U32.to_nat(len)), VU.le_u32(@FS, len)),
    F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+X, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), @FSn+X, en), Order.below_sum(@FSn, X)))

# The four bytes at the window's offset field are the limbs of its offset word.
def bytePw(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == @FSn+X : Nat},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}:
  +hp = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(@POn, i), z) == True{} : Bool}, VB.pw(d), VB.len(SL(t)), Equal.sym(Nat, VB.len(SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)),
    W.hiw(d, i, len, @POn, {==}, hw, haw(len, X, en)))
  %Equal.sym(Nat, U32.to_nat(len), @FSn+X, en) : {VS.bt(4n, VS.bdr(@Pn, VS.bt(_, FX.limbs(VB.wdr(i, SL(t)))))) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@Pn, VS.bt(@FSn+X, FX.limbs(VB.wdr(i, SL(t))))), VS.bt(@Rn+X, VS.bdr(@Pn, FX.limbs(VB.wdr(i, SL(t))))), VS.bdr_bt(@Pn, @Rn+X, FX.limbs(VB.wdr(i, SL(t))))) :
    {VS.bt(4n, _) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(@Rn+X, VS.bdr(@Pn, FX.limbs(VB.wdr(i, SL(t)))))), VS.bt(4n, VS.bdr(@Pn, FX.limbs(VB.wdr(i, SL(t))))), VS.bt_bt(4n, @R4n+X, VS.bdr(@Pn, FX.limbs(VB.wdr(i, SL(t)))))) :
    {_ == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@Pn, FX.limbs(VB.wdr(i, SL(t)))), FX.limbs(VS.wdr0(@POn, VB.wdr(i, SL(t)))), VS.bdr_limbs(@POn, VB.wdr(i, SL(t)))) :
    {VS.bt(4n, _) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, FX.limbs(VS.wdr0(@POn, VB.wdr(i, SL(t))))), FX.limbs(VS.wtake(1n, VS.wdr0(@POn, VB.wdr(i, SL(t))))), VS.bt_limbs(1n, VS.wdr0(@POn, VB.wdr(i, SL(t))))) :
    {_ == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(@POn, VB.wdr(i, SL(t))), VB.wdr(@POn, VB.wdr(i, SL(t))), wdr0_eq(@POn, VB.wdr(i, SL(t)))) :
    {FX.limbs(VS.wtake(1n, _)) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(@POn, VB.wdr(i, SL(t))), VB.wdr(Nat.add(i, @POn), SL(t)), VF.wdr_add(@POn, i, SL(t))) :
    {FX.limbs(VS.wtake(1n, _)) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, @POn), Nat.add(@POn, i), F.nat__add_comm(i, @POn)) :
    {FX.limbs(VS.wtake(1n, VB.wdr(_, SL(t)))) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n, VB.wdr(Nat.add(@POn, i), SL(t))), Con{F.flat__nthc(SL(t), Nat.add(@POn, i)), VS.wtake(0n, VB.wdr(1n+Nat.add(@POn, i), SL(t)))}, VB.wt_eta(0n, Nat.add(@POn, i), SL(t), hp)) :
    {FX.limbs(_) == FX.limbs([W.SPOw(t, i)]) : +List<U32>}
  {==}
"""

from codegen.proofs.var import var_bytes_enc as VBE  # noqa: E402
from codegen.proofs.var import var_bytes_nest as VBN  # noqa: E402
from codegen.proofs.var import var_bytes_nenc as VBNE  # noqa: E402
from codegen.proofs.support import zeros_dispatch as ZD  # noqa: E402
from codegen.core.shared_var_b import Templates  # noqa: E402
TPL = Templates('var_bytes', globals())

if __name__ == '__main__':
    main()
