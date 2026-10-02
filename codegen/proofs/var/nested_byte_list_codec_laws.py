#!/usr/bin/env python3
"""Codec laws of containers that nest a name of codegen/proofs/var/byte_list_codec_laws.py.

Covered family: plain containers (at most 8 fields) of word-aligned fixed
fields (as byte_list_codec_laws.py, plus boxed Data records) around ONE variable field
that is itself a covered name Y (ExecutionPayloadHeader, or a name of this
family), possibly boxed. Fulu names: LightClientHeader (Y =
ExecutionPayloadHeader), LightClientOptimisticUpdate (Y = LightClientHeader).

The laws are those of byte_list_codec_laws.py (the _win, top, _unique and _rej modules),
built on Y's window laws at the window (off + FS, len - FS): Y's validator,
reader and spec parts at word H + i (proofs/obj/var_bytes_<Y>_win.bend), and
Y's windowed rejection facts (var_bytes_<Y>_rej.bend inv_p, rej_facts).
"""
import re

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.impl import typed_object_runtime as G
from codegen.proofs.laws import spec_connected_codec_laws as SL
from codegen.proofs.var import single_list_container_codec_laws as VL
from codegen.proofs.var import byte_list_codec_laws as VBY
from codegen.proofs.var import light_client_bootstrap_helpers as VBB
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('nested_byte_list_codec_laws', globals())

ROOT = VBY.ROOT
# parent -> child (the variable field's type)
NEST = {'LightClientHeader': 'ExecutionPayloadHeader', 'LightClientOptimisticUpdate': 'LightClientHeader',
        'LightClientBootstrap': 'LightClientHeader'}
ORDER = ['LightClientHeader', 'LightClientOptimisticUpdate', 'LightClientBootstrap']
NO_ENC = {'LightClientBootstrap'}  # its encoder laws: codegen/proofs/var/light_client_bootstrap_encoder_laws.py (big)


class NName(VBY.Name):
    def __init__(self, g, n, t):
        self.n, self.t, self.g = n, t, g
        s = g.shape(t)
        if s.kind != 'container' or len(s.fields) > G.GROUP:
            raise VBY.Skip('not a plain container')
        self.s = s
        self.fields = []
        pos = 0
        var = None
        c = iter(range(100000))
        src = VBY.src()
        for (fname, ft), (_, fs) in zip(t.fields, s.fields):
            box = fs.kind == 'box'
            inner = fs.inner if box else fs
            if ft.fixed():
                size = ft.fixed_size()
                if size % 4:
                    raise VBY.Skip('fixed field not whole words')
                if inner.kind in ('fixwords', 'packed') and not box:
                    m = re.search(rf'^def {fs.p}_read\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & O\.Words: '
                                  rf'O\.copy_into\(buf, off, {size}, Array\.new\(U32, (\d+)n, 0\)\)$', src, re.M)
                    if not m:
                        raise VBY.Skip(f'words field {fname}: reader shape')
                    f = {'kind': 'words', 'dz': int(m.group(1)), 'p': fs.p, 'size': size, 'W': size // 4}
                elif inner.kind == 'container' and not inner.data and not box:
                    # a Type record of packed words and Data records (SyncCommittee): its value's
                    # parts come from codegen/proofs/var/light_client_bootstrap_helpers.py
                    f = VBB.comp_field(g, ft, inner, size)
                else:
                    ft_ = VBY.FTW(g, ft)
                    f = {'kind': 'fix', 'ft': ft_, 'p': ft_.p, 'size': size, 'W': size // 4, 'box': box}
                if f['kind'] != 'comp':
                    f['node'] = SL.walk(g, ft, c)
                f.update({'name': fname, 't': ft, 'c': pos, 'k': pos // 4})
                self.fields.append(f)
                pos += size
            else:
                if var is not None:
                    raise VBY.Skip('more than one variable field')
                if inner.p != NEST.get(n):
                    raise VBY.Skip(f'variable field {fname} is not a covered name')
                var = {'kind': 'var', 'name': fname, 't': ft, 'c': pos, 'k': pos // 4, 'p': fs.p, 'Y': inner.p, 'box': box}
                self.fields.append(var)
                pos += 4
        if var is None:
            raise VBY.Skip('no variable field')
        self.FS, self.H = pos, pos // 4
        # past BIGFS header bytes the name's files are big_* files (checkq --big): their closed Nat
        # facts go through Nat.is_eq and the size lemmas of proofs/obj/vbsize.bend (see BIGFS)
        self.big = pos > BIGFS
        self.FSN = f'{pos}n'
        self.var = var
        self.po, self.cvar = var['k'], var['c']
        self.Y = var['Y']
        self.check_runtime()

    def check_runtime(self):
        n, FS, Y = self.n, self.FS, self.Y
        yok = f'{Y}_bx_ok' if self.var['box'] else f'{Y}_ok'
        want = [f'def {n}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {n}_ok_len(U32.is_le({FS}, len), buf, off, len)',
                f'    case True{{}}: {n}_v0(off, len, B.read32(buf, (off + {self.cvar} : U32)))',
                f'  {n}_c0(U32.is_eq(o0, {FS}), buf, off, len, o0)',
                f'    case True{{}}: {n}_v1(off, len, o0, {yok}(buf, (off + o0 : U32), (len - o0 : U32)))']
        if self.var['box']:
            want.append(f'def {Y}_bx_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {Y}_ok(buf, off, len)')
        for x in want:
            if x not in VBY.src():
                raise VBY.Skip('runtime shape differs: ' + x)

    def obj(self, f):
        if f['kind'] == 'comp':
            return VBB.comp_obj(self, f)
        if f['kind'] == 'fix':
            o = f['ft'].obj(self.words(f))
            return f'O.BSome{{{o}, O.BNone{{}}}}' if f['box'] else o
        if f['kind'] == 'words':
            return VBY.Name.obj(self, f)
        o = f'YW.OBJw(t, Nat.add({self.H}n, i), LL(len))'
        return f'O.BSome{{{o}, O.BNone{{}}}}' if f['box'] else o


def wmod(Y):
    return VBY.fname(type('X', (), {'n': Y}), '_win').name


def rmod(Y):
    return VBY.fname(type('X', (), {'n': Y}), '_rej').name


HEAD = VBY.HEAD + ['import ../../spec/nat_bytes.bend as NBx', 'import ./vfits.bend as VFT', 'import ./spec_bits.bend as FB']
# A header of more bytes than this makes the stock checker compare unary Nats deeper than its
# stack (it evaluates both sides of every conversion first); such names get big_* files.
BIGFS = 4096
def ecq(k, c):
    """A proof of U32.to_nat(c) == A.quad(k) for closed k, c: past BIGFS through Nat.is_eq."""
    return '{==}' if c <= BIGFS else f'FD.nat__eq_from_is_eq(U32.to_nat({c}), A.quad({k}n), {{==}})'


HEAD_BIG = ['import ./vbsize.bend as VBZ']
HEAD_COMP = ['import ./arr_vec.bend as AV', 'import ./vsc.bend as VSC', 'import ./vbsize.bend as VBZ', 'import ./vbenc.bend as VBE']


def read_plan(x):
    leaves = []
    vals = []
    var = [j for j, f in enumerate(x.fields) if f['kind'] == 'var']
    steps = [('off', j) for j in var] + [('field', j) for j in range(len(x.fields))]
    p = x.s.p
    for k, st in enumerate(steps):
        args = ''.join(f'{v}, ' for v in vals)
        frame = f'T.{p}_rd{k}(off, len, {args}@)'
        f = x.fields[st[1]]
        if st[0] == 'off':
            leaves.append((frame, f'B.read32(VF.BF(t, n), U32.add(off, {f["c"]}))', str(x.FS), 'off', f))
            vals.append(str(x.FS))
            continue
        if f['kind'] == 'var':
            call = f'T.{x.Y}_read(VF.BF(t, n), U32.add(off, {x.FS}), U32.sub(len, {x.FS}))'
            inner = f'YW.OBJw(t, Nat.add({x.H}n, i), LL(len))'
            ctx = frame.replace('@', f'T.{x.Y}_bx_rd(@)') if f['box'] else frame
        elif f['kind'] == 'comp':
            call = f'T.{f["p"]}_read(VF.BF(t, n), U32.add(off, {f["c"]}), {f["size"]})'
            inner = x.obj(f)
            ctx = frame
        elif f['kind'] == 'fix':
            ft = f['ft']
            call = f'T.{ft.p}_read(VF.BF(t, n), U32.add(off, {f["c"]}), {f["size"]})'
            inner = ft.obj(x.words(f))
            ctx = frame.replace('@', f'T.{ft.p}_bx_rd(@)') if f['box'] else frame
        else:
            call = f'T.{f["p"]}_read(VF.BF(t, n), U32.add(off, {f["c"]}), {f["size"]})'
            inner = x.obj(f)
            ctx = frame
        leaves.append((ctx, call, inner, f['kind'], f))
        vals.append(x.obj(f))
    return leaves, f'T.{x.s.t.name}{{' + ', '.join(vals[len(var):]) + '}'


WH = VBY.WH
PF = VBY.PF


def win_text(x):
    n, FS, H, po, cvar, Y = x.n, x.FS, x.H, x.po, x.cvar, x.Y
    FSN = x.FSN
    if x.big:
        EF = f'FD.nat__eq_from_is_eq(U32.to_nat({FS}), {FSN}, {{==}})'
        LEB = f'  VBZ.le_fs({FS}, {FSN}, {EF}, len, ha)'
        ENB = f'  VBZ.en_fs({FS}, {FSN}, {EF}, len, LL(len), {{==}}, ha)'
        HWB = f'  VBZ.hw_y(d, i, len, {H}n, {FSN}, LL(len), FD.nat__eq_from_is_eq(A.quad({H}n), {FSN}, {{==}}), enFS(len, ha), hw)'
        LEHC = 'leH(len, ha)'
        LEHD = (TPL.render('LEHD', FS=FS, H=H))
    else:
        LEHC, LEHD = 'leFS(len, ha)', ''
        LEB = f'''  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le({FS}, len), Nat.is_le({FSN}, U32.to_nat(len)), VU.le_u32({FS}, len), ha)'''
        ENB = f'''  %Equal.sym(Nat, U32.to_nat(LL(len)), Nat.sub(U32.to_nat(len), {FSN}), FD.u32__sub_nat(len, {FS}, leFS(len, ha))) : {{Nat.add({FSN}, _) == U32.to_nat(len) : Nat}}
  FD.nat__sub_add(U32.to_nat(len), {FSN}, leFS(len, ha))'''
        HWB = TPL.render('HWB', FSN=FSN, H=H)
    Tn = f'T.{n}'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    comp = any(f['kind'] == 'comp' for f in x.fields)
    L = list(HEAD) + (HEAD_COMP if comp else []) + (HEAD_BIG if x.big and not comp else []) + [f'import ./{wmod(Y)} as YW', '', '# GENERATED by nested_byte_list_codec_laws (codegen). Do not edit.',
                      f'# {n} at a word-aligned window (off = 4 i, len) of a buffer: the validator,',
                      f'# the reader and the spec parts of the value, on {Y}\'s window laws at word {H} + i',
                      '# (see the module docstring of codegen/proofs/var/nested_byte_list_codec_laws.py).', '']
    w = L.append
    yok = f'T.{Y}_bx_ok' if x.var['box'] else f'T.{Y}_ok'
    w(TPL.render('win_text', ENB=ENB, FS=FS, FSN=FSN, H=H, HA=HA, HWB=HWB, LEB=LEB, LEHC=LEHC, LEHD=LEHD, Tn=Tn, Y=Y, cvar=cvar, po=po, yok=yok))
    shk_done = False
    for f in x.fields:
        if f['kind'] == 'comp':
            L.extend(VBB.rd_comp_lemma(f))
            if f['k'] != 0:
                shk, lem = VBB.rd_comp_shift(f, f['k'])
                L.extend(([] if shk_done else [shk + '\n']) + [lem + '\n'])
                shk_done = True
    leaves, OBJ = read_plan(x)
    RHS = '(VF.BF(t, n), OBJw(t, i, len))'
    TY = f'B.Buf & {Tn}'
    for line in TPL.render('win_text_lines', FS=FS, H=H, HA=HA, OBJ=OBJ, RHS=RHS, TY=TY, Tn=Tn).split('\n'):
        w(line)

    def ecf(k, c):
        return f'eoc(d, i, off, len, {k}n, {c}, {ecq(k, c)}, {{==}}, eo, hd, hw, ha)'

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
        elif kind == 'comp':
            w(f'  %Equal.sym(B.Buf & T.{f["p"]}, {call}, (VF.BF(t, n), {val}),')
            rc = f'rd_comp_{f["p"]}(d, t, n, U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {ecf(f["k"], f["c"])}, hd, pf, {hb(f["W"], f["k"])})'
            if f['k'] != 0:
                rc = f'rdc_shift_{f["p"]}_{f["k"]}(d, t, n, U32.add(off, {f["c"]}), i, {rc})'
            w(f'      {rc}) :')
        elif kind == 'words':
            e = ecf(f['k'], f['c'])
            kw = VBY.kfit(31 + f['size'])
            for line in TPL.render('win_text_lines_2', call=call, e=e, f=f, hb=hb, kw=kw, val=val).split('\n'):
                w(line)
        else:
            w(f'  %Equal.sym(B.Buf & T.{Y}, {call}, (VF.BF(t, n), {val}),')
            w(f'      YW.readw(d, t, n, Nat.add({H}n, i), U32.add(off, {FS}), LL(len), ecY(d, i, off, len, eo, hd, hw, ha), hd, hwY(d, i, len, hw, ha), pf, hY)) :')
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(TPL.render('win_text_readw', FS=FS, H=H, TY=TY, Tn=Tn))
    if any(f['kind'] == 'comp' for f in x.fields):
        L.extend(VBB.spec_part_seg(x))
    else:
        L.extend(spec_part(x))
    return '\n'.join(L) + '\n'


def spec_items(x, V, Yb, hv, wt=None, named=None):
    """ITEMS, CHAIN, PL, CAT, PRE, POST, HDR with the child's value V, bytes Yb and parts proof hv."""
    vals, schs, parts, nodes = [], [], [], []
    for f in x.fields:
        if f['kind'] == 'var':
            vals.append(V)
            schs.append(f'Spec.{x.Y}()')
            parts.append(f'S.Variable{{{Yb}}}')
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
        if nodes[i] is not None:
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, {Yb}, {rest}, '
                f'{hv}, {cat(i + 1)})')
    vi = [f['kind'] for f in x.fields].index('var')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if nd is not None else [str(x.FS)]
    if named:
        from codegen.proofs.var import byte_list_codec_laws as VBY
        proofs = [('fixed', f'F.limbs([{", ".join(nodes[i]["words"])}])', nodes[i]['proof']) if nodes[i] is not None else ('var', Yb, hv)
                  for i in range(m)]
        return (items(0), chain(0), f'{named[0]}P0({named[4]})', f'{named[0]}T0({named[6]})', PRE, POST, hdr,
                VBY.chain_defs(*named[:5], vals, schs, parts, named[5], named[6], proofs))
    return items(0), chain(0), '[' + ', '.join(parts) + ']', cat(0), PRE, POST, hdr


def spec_part(x):
    n, FS, H, po, Y = x.n, x.FS, x.H, x.po, x.Y
    FSN = x.FSN
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr = spec_items(x, 'V', 'Yb', 'hv')
    HDR = '[' + ', '.join(hdr) + ']'
    hdrh = '[' + ', '.join(h if j != po else '_' for j, h in enumerate(hdr)) + ']'
    hdrs = '[' + ', '.join(h if j != po else 'SPOw(t, i)' for j, h in enumerate(hdr)) + ']'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    ENC = f'List.append(&2, U32, F.limbs({HDR}), Yb)'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), Yb)'
    s = 'FD.array__slots(U32, t)'
    WIN = f'VS.bt(U32.to_nat(len), F.limbs(VB.wdr(i, {s})))'
    YT = f'VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(Nat.add({H}n, i), {s})))'
    VY_ = f'YW.VALw(t, Nat.add({H}n, i), LL(len))'
    return [TPL.render('spec_part', CAT=CAT, CHAIN=CHAIN, ENC=ENC, ENCR=ENCR, FS=FS, FSN=FSN, H=H, HA=HA, HDR=HDR, ITEMS=ITEMS, M=M, MP=MP, PL=PL, POST=POST, PRE=PRE, VY_=VY_, WIN=WIN, Y=Y, YT=YT, hdrh=hdrh, hdrs=hdrs, n=n, s=s)]


# ---- the rejection laws ----------------------------------------------------------------------

def rej_text(x, pure=False):
    """pure: only the lines up to inv_v (no window or whole-buffer facts), for codegen/proofs/var/byte_list_offset_windows.py."""
    n, FS, H, po, Y = x.n, x.FS, x.H, x.po, x.Y
    FSN = x.FSN
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
         'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/nat_bytes.bend as N',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
         'import ./spec_fixed.bend as FX', 'import ./dk.bend as DK', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
         'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vrej.bend as VR', 'import ./vfix.bend as VF', 'import ./vbspec.bend as VZ',
         f'import ./{VBY.fname(x, "_win").name} as W', f'import ./{VBY.fname(x).name} as DC',
         f'import ./{wmod(Y)} as YW', f'import ./{rmod(Y)} as YR', '',
         '# GENERATED by nested_byte_list_codec_laws (codegen). Do not edit.',
         f'# Rejection of {n} is exactly the complement of the spec image: every byte',
         '# string the spec relates to some value has the shape the validator checks',
         f'# (inv_v; the child\'s bytes through {Y}\'s own inversion), so when CHK(t, n) is',
         '# False no value is related to the buffer\'s bytes (decode_reject), and the',
         '# decoder returns None (decode_none).', '']
    w = L.append
    MB = 'Maybe<&2, +List<U32>>'
    MP = 'Maybe<&2, +List<S.Part>>'
    if x.big:
        # a fixed field's one fixed part, its size compared through Nat.is_eq (a closed product of
        # the schema's widths, e.g. 512 * 48, is otherwise compared unary)
        for line in TPL.text('rej_text_lines_5').split('\n'):
            w(line)
    for line in TPL.render('rej_text_lines', FSL=FSL, FSN=FSN, MP=MP, P=P, Y=Y).split('\n'):
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
                decl += ['+hv0: S.Value', '+ys: +List<U32>', f'+em: {{Codec.parts(hv0, Spec.{Y}()) == Some{{[S.Variable{{ys}}]}} : {MP}}}']
                args += ['hv0', 'ys', 'em']
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
        if x.big and idx:
            # symbolic lengths first (a closed big sum compared against a stuck term unrolls it)
            k = len(idx)

            def tm(v):
                t = '0n'
                for q in reversed(v):
                    t = f'Nat.add({q}, {t})'
                return t
            av, Av = [f'a{q}' for q in range(k)], [f'A{q}' for q in range(k)]
            w(f'def {name}_s(' + ', '.join([f'+a{q}: Nat' for q in range(k)] + [f'+A{q}: Nat' for q in range(k)] + [f'+h{q}: {{a{q} == A{q} : Nat}}' for q in range(k)])
              + f') -> {{{tm(av)} == {tm(Av)} : Nat}}:')
            steps = []
            for q in range(k):
                lo = tm(Av[:q] + av[q:])
                hi = tm(Av[:q + 1] + av[q + 1:])
                mot = tm(Av[:q] + ['z'] + av[q + 1:])
                steps.append((lo, hi, f'Equal.cong(Nat, Nat, z => {mot}, a{q}, A{q}, h{q})'))

            def chain(st):
                if len(st) == 1:
                    return st[0][2]
                return f'Equal.trans(Nat, {st[0][0]}, {st[0][1]}, {st[-1][1]}, {st[0][2]}, {chain(st[1:])})'
            w('  ' + chain(steps))
            w('')
            lits = [f'{x.fields[j]["size"]}n' for j in idx]
            w(f'def {name}(' + ', '.join(decl_m) + f') -> {{VR.lens([' + ', '.join(f'xs{j}' for j in idx) + f']) == {total}n : Nat}}:')
            w(f'  Equal.trans(Nat, VR.lens([' + ', '.join(f'xs{j}' for j in idx) + f']), {tm(lits)}, {total}n, {name}_s('
              + ', '.join([f'List.length(&2, U32, xs{j})' for j in idx] + lits + [f'lx{j}' for j in idx])
              + f'), F.nat__eq_from_is_eq({tm(lits)}, {total}n, {{==}}))')
            w('')
            return
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
    if x.big:
        # the header size through one closed equality (no big sum compared against a stuck term)
        LP, LQ = f'VR.lens({PRE})', f'VR.lens({POST})'
        OFS = f'Nat.add({LP}, 4n+{LQ})'
        w('def eF(' + ', '.join(decl_m) + f') -> {{{OFS} == {FSN} : Nat}}:')
        for line in TPL.render('rej_text_lines_6', ALL=ALL, FSN=FSN, LP=LP, LQ=LQ, OFS=OFS, Pz=Pz, Qz=Qz).split('\n'):
            w(line)
        # stated for a symbolic size fs (proof terms holding Nat.add(<big literal>, <stuck>) overflow the post-check)
        FSD = ', '.join(decl_m + ['+fs: Nat', f'+ef: {{{OFS} == fs : Nat}}'])
        for line in TPL.render('rej_text_lines_7', FSD=FSD, OFS=OFS, OUT=OUT, POST=POST, PRE=PRE).split('\n'):
            w(line)
        w('def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FSN}, List.length(&2, U32, ys)) : Nat}}:')
        for line in TPL.render('rej_text_lines_8', ALL=ALL, FSD=FSD, FSN=FSN, OFS=OFS, OUT=OUT, POST=POST, PRE=PRE).split('\n'):
            w(line)
        w('def f_dr(' + ', '.join(decl_m) + f') -> {{VS.bdr({FSN}, {OUT}) == ys : +List<U32>}}:')
        w(f'  f_dr_g({ALL}, {FSN}, eF({ALL}))')
        w('')
    else:
        w('def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FSN}, List.length(&2, U32, ys)) : Nat}}:')
        for line in TPL.render('rej_text_lines_9', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE, Qz=Qz).split('\n'):
            w(line)
        w('def f_dr(' + ', '.join(decl_m) + f') -> {{VS.bdr({FSN}, {OUT}) == ys : +List<U32>}}:')
        for line in TPL.render('rej_text_lines_10', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE, Qz=Qz).split('\n'):
            w(line)
    PLIST = '[' + ', '.join(parts_m) + ']'
    w(sig('inv_fin', decl_m, ['+bs: +List<U32>', '+b5: Bool',
          f'+e: {{Codec.bytes(Codec.one(SP.optional(b5, {OUT}), None{{}})) == Some{{bs}} : {MB}}}']))
    for line in TPL.render('rej_text_lines_3', ALL=ALL, OUT=OUT, absurd=absurd).split('\n'):
        w(line)
    b5 = f'Bool.and(Layout.bytes_valid({PLIST}), N.fits(4n, Nat.add(Layout.fixed_size({PLIST}), List.length(&2, U32, Layout.payloads({PLIST})))))'
    w(sig(f'st{m}', decl_m, ['+items: S.Value', '+bs: +List<U32>', '+e: ' + E(parts_m, 'Codec.parts(items, S.End{})')]))
    L.extend(match_value('items', ('EmptyItems', []), f'inv_fin({ALL}, bs, {b5}, e)'))
    w('')
    for i in reversed(range(m)):
        f = x.fields[i]
        decl, args, parts = prefix(i)
        A_ = ', '.join(args + [''])
        sch = f'Spec.{kids[i]}()'
        nxt = f'Codec.parts(t, {chain(i + 1)})'
        if f['kind'] != 'var':
            z = f['size']
            w(sig(f'fp{i}', decl, ['+ps: +List<S.Part>', f'hf: DF.single(Some{{{z}n}}, ps)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            for line in TPL.render('rej_text_lines_11', A_=A_, i=i, z=z).split('\n'):
                w(line)
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            for line in TPL.render('rej_text_lines_12', A_=A_, absurd=absurd, i=i).split('\n'):
                w(line)
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            fct = f'sfix({sch}, {z}n, h, {{==}}, DS.facts(h, {sch}, {{==}}))' if x.big else f'DS.facts(h, {sch}, {{==}})'
            w(f'  fm{i}({A_}Codec.parts(h, {sch}), {fct}, t, bs, e)')
            w('')
        else:
            w(sig(f'fp{i}', decl, ['+h: S.Value', '+ps: +List<S.Part>', 'hf: DF.single(None{}, ps)',
                                   f'+em0: {{Codec.parts(h, {sch}) == Some{{ps}} : {MP}}}', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            for line in TPL.render('rej_text_lines_13', A_=A_, i=i).split('\n'):
                w(line)
            w(sig(f'fm{i}', decl, ['+h: S.Value', '+mm: Maybe<&2, +List<S.Part>>', 'hf: DF.single_result(None{}, mm)',
                                   f'+em0: {{Codec.parts(h, {sch}) == mm : {MP}}}', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            for line in TPL.render('rej_text_lines_14', A_=A_, absurd=absurd, i=i).split('\n'):
                w(line)
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({A_}h, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), {{==}}, t, bs, e)')
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+bs: +List<U32>', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 't']), f'fd{i}({A_}h, t, bs, e)'))
        w('')
    for line in TPL.render('rej_text_lines_4', MB=MB, n=n).split('\n'):
        w(line)
    L.extend(match_value('v', ('Sequence', ['items']), 'st0(items, bs, e)'))
    w('')
    if pure:
        return L
    R = FS - P
    body = VBY.REJ.split('def ek_sub(')[0] + VBY.REJW + NREJ
    for a, b in [('@Tn', Tn), ('@n', n), ('@FSL', FSL), ('@FSn', x.FSN), ('@FS', str(FS)), ('@PO', str(po)), ('@P', str(P)), ('@H', str(H)),
                 ('@R4', str(R - 4)), ('@R', str(R)), ('@Y', Y),
                 ('@B0', str(fsb[0])), ('@B1', str(fsb[1])), ('@B2', str(fsb[2])), ('@B3', str(fsb[3]))]:
        body = body.replace(a, b)
    w(body)
    out = '\n'.join(L) + '\n'
    if x.big:
        out = out.replace("import ./vbspec.bend as VZ", "import ./vbspec.bend as VZ\nimport ./vbsize.bend as VBZ\nimport ../../spec/schema.bend as SS", 1)
        out = re.sub(rf'Nat\.add\({FS}n, List\.length\(&2, U32, (\w+)\)\)', rf'Nat.add({FS}n, VBZ.LN(\1))', out)
        out = re.sub(rf'\b({FS}|{FS - 4})n\+X\b', r'Nat.add(\1n, X)', out)
        out = out.replace('List.length(&2, U32, ys), en', 'VBZ.LN(ys), en')
        # the whole-buffer offset facts (unused: decode_reject goes through the window at i = 0)
        # compare the literal header size with stuck lengths; dropped for big names
        blocks = re.split(r'(?m)^(?=def |law |# )', out)
        drop = ('def lenS(', 'def lenVW(', 'def hpoS(', 'def byteP(', '# The offset word\'s index', '# The four bytes at the offset field')
        out = ''.join(b for b in blocks if not b.startswith(drop))
        wvg = WVG.replace('@FSn', f'{FS}n').replace('@Hn', f'{H}n')
        blocks = re.split(r'(?m)^(?=def |law |# )', out)
        out = ''.join(wvg if b.startswith('def wv_dr(') else b for b in blocks)
        out = re.sub(r'(def haw\(\+len: U32, \+X: Nat, \+en: \{U32\.to_nat\(len\) == Nat\.add\(\d+n, X\) : Nat\}\) -> \{U32\.is_le\(\d+, len\) == True\{\} : Bool\}:\n)(?:  .*\n)+',
                     lambda m_: m_.group(1) + f'  VBZ.haw_g({FS}, {FS}n, F.nat__eq_from_is_eq(U32.to_nat({FS}), {FS}n, {{==}}), len, X, en)\n', out)
    return out


# The child's window after a big header (codegen/proofs/var/nested_byte_list_codec_laws.py big names): stated for symbolic
# sizes h = 4 H and instantiated once (the literal would otherwise meet stuck lengths).
WVG = TPL.text('WVG')

NREJ = TPL.text('NREJ')


def outputs(g, names):
    out = {}
    for n in ORDER:
        x = NName(g, n, names[n])
        out[VBY.fname(x, '_win')] = win_text(x)
        out[VBY.fname(x)] = writer.rebrand(VBY.top_text(x), 'byte_list_codec_laws', 'nested_byte_list_codec_laws')
        out[VBY.fname(x, '_unique')] = writer.rebrand(VBY.unique_text(x), 'byte_list_codec_laws', 'nested_byte_list_codec_laws')
        # big names: rej_text states the header size's facts symbolically (x.big branches)
        out[VBY.fname(x, '_rej')] = rej_text(x)
    out.update(VBB.outputs())
    return out
