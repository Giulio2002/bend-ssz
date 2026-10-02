"""Byte-offset windows of containers whose first TWO fields are variable, both a
name with a byte-offset window module of codegen/proofs/var/var_bytes_x.py, followed by
fixed fields (LightClientFinalityUpdate: two LightClientHeaders, the finality
branch, a boxed SyncAggregate, the signature slot). Called from
codegen/proofs/var/var_bytes_x.py.

The window module proofs/obj/var_bytesx_X.bend has the interface of
proofs/obj/vua_win.bend (CHKw, ok_evalw, OBJw, readw, VALw, specw, invw). The
first child's window is (off + FS, o1 - FS) at FS + x, the second's
(off + o1, len - o1) at o1 + x, o1 being the second offset word
SPO1(t, x) = UR.RWN(t, 4 + x). The spec side is the layout of two variable parts
(proofs/obj/vbx2.bend enc2, OUT2); the inversion (var_bytesx_X_inv.bend) runs
the spec relation back to that layout (FACTS2) and invw reads the two offsets
back from the window's bytes (UW.byteWX, vdig digits_word), then hands the two
halves of the tail (vbx2 wx_fst, wx_snd) to the children's invw.
var_bytesx_X_dec.bend holds the whole-buffer decoder laws (the window laws at
x = 0).
"""
import re

from codegen.proofs.laws import spec_laws as SL
from codegen.proofs.var import var_laws as VL
from codegen.proofs.var import var_bytes as VBY
from codegen.proofs.var import var_bytes_x as VX
from codegen.core.shared_var_a import Templates  # noqa: E402
TEMPLATES = Templates('var_bytes_x2', globals())

X2 = {'LightClientFinalityUpdate': 'LightClientHeader'}


class X2Name:
    def __init__(self, g, n, t):
        self.n, self.t, self.g = n, t, g
        s = g.shape(t)
        if s.kind != 'container':
            raise VBY.Skip('not a container')
        self.s = s
        self.fields = []
        pos = 0
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
                    f = {'kind': 'words', 'dz': int(m.group(1)), 'p': fs.p, 'size': size, 'W': size // 4, 'box': False}
                else:
                    ft_ = VBY.FTW(g, ft)
                    f = {'kind': 'fix', 'ft': ft_, 'p': ft_.p, 'size': size, 'W': size // 4, 'box': box}
                f['node'] = SL.walk(g, ft, c)
            else:
                if box or inner.p != X2[n]:
                    raise VBY.Skip(f'variable field {fname} is not the covered child')
                f = {'kind': 'var', 'p': fs.p, 'size': 4, 'W': 1, 'box': False}
            f.update({'name': fname, 't': ft, 'c': pos, 'k': pos // 4})
            self.fields.append(f)
            pos += f['size']
        kinds = [f['kind'] for f in self.fields]
        if kinds[:2] != ['var', 'var'] or 'var' in kinds[2:]:
            raise VBY.Skip('not two leading variable fields')
        self.FS, self.H = pos, pos // 4
        self.Y = X2[n]

    def slot(self, k):
        return VX.rwn(4 * k)

    def words(self, f):
        return [self.slot(f['k'] + j) for j in range(f['W'])]

    def node(self, f):
        nd = f['node']
        mp = {int(w[1:]): self.slot(f['k'] + j) for j, w in enumerate(nd.words)}
        sub = lambda s: re.sub(r'\bx(\d+)\b', lambda m: mp[int(m.group(1))], s)  # noqa: E731
        return {'val': sub(nd.val), 'sch': nd.sch, 'proof': sub(nd.proof), 'words': [mp[int(w[1:])] for w in nd.words]}

    def obj(self, f):
        if f['kind'] == 'fix':
            o = f['ft'].obj(self.words(f))
            return f'O.BSome{{{o}, O.BNone{{}}}}' if f['box'] else o
        if f['kind'] == 'words':
            return f'O.Words{{FD.array__thaw(U32, UCT.CT(d, t, U32.add(off, {f["c"]}), {f["size"]}, {f["dz"]}n)), {f["size"]}}}'
        raise VBY.Skip('obj of a variable field')


def fname(x, part=''):
    return VX.fname(x, part)


# ---- the spec inversion -------------------------------------------------------------------------

def inv_text(x):
    n, FS, Y = x.n, x.FS, x.Y
    kids, _ = VL.spec_schemas(n)
    m = len(x.fields)
    fsb = [FS & 255, (FS >> 8) & 255, (FS >> 16) & 255, (FS >> 24) & 255]
    FSL = '[' + ', '.join(map(str, fsb)) + ']'
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../types/schema.bend as S', 'import ../compact/found.bend as F',
         'import ../compact/arith.bend as A', 'import ../compact/bits.bend as BT', 'import ../../proofs/nat_order.bend as Order',
         'import ../../proofs/primitive_invariants.bend as V', 'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout',
         'import ../../spec/codec.bend as Codec', 'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF', 'import ./spec_fixed.bend as FX',
         'import ./dk.bend as DK', 'import ./vspec.bend as VS', 'import ./vrej.bend as VR', 'import ./vbx2.bend as VX2', '',
         '# GENERATED by var_bytes_x (codegen: var_bytes_x2). Do not edit.',
         f'# Every byte string the spec relates to a {n} value has the shape its validator checks',
         '# (FACTS2: the first offset is FS, the second FS + |y0|, the tail is y0 ++ y1, y0 and y1',
         f'# the spec bytes of two {Y} values).', '']
    w = L.append
    MB = 'Maybe<&2, +List<U32>>'
    MP = 'Maybe<&2, +List<S.Part>>'
    w('def FACTS2(bs: +List<U32>) -> Type:')
    w(f'  {{VS.bt(4n, VS.bdr(0n, bs)) == {FSL} : +List<U32>}} & DK.Ex(S.Value, hv0 => DK.Ex(+List<U32>, ys0 => DK.Ex(S.Value, hv1 => DK.Ex(+List<U32>, ys1 => '
      f'DK.P2({{VS.bt(4n, VS.bdr(4n, bs)) == N.digits(4n, Nat.add({FS}n, List.length(&2, U32, ys0))) : +List<U32>}}, '
      f'DK.P2({{List.length(&2, U32, bs) == Nat.add({FS}n, Nat.add(List.length(&2, U32, ys0), List.length(&2, U32, ys1))) : Nat}}, '
      f'DK.P2({{VS.bdr({FS}n, bs) == List.append(&2, U32, ys0, ys1) : +List<U32>}}, '
      f'DK.P2({{Codec.parts(hv0, Spec.{Y}()) == Some{{[S.Variable{{ys0}}]}} : {MP}}}, {{Codec.parts(hv1, Spec.{Y}()) == Some{{[S.Variable{{ys1}}]}} : {MP}}}))))))))')
    w('')

    def absurd(e='e'):
        return f'Empty.absurd(FACTS2(bs), F.logic__none_some(+List<U32>, bs, {e}))'

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
                decl += [f'+hv{j}: S.Value', f'+ys{j}: +List<U32>', f'+em{j}: {{Codec.parts(hv{j}, Spec.{Y}()) == Some{{[S.Variable{{ys{j}}}]}} : {MP}}}']
                args += [f'hv{j}', f'ys{j}', f'em{j}']
                parts.append(f'S.Variable{{ys{j}}}')
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
        return f'def {name}(' + ', '.join(decl + extra) + ') -> FACTS2(bs):'

    decl_m, args_m, parts_m = prefix(m)
    post = list(range(2, m))
    POST = '[' + ', '.join(f'xs{j}' for j in post) + ']'
    Qz = sum(x.fields[j]['size'] for j in post)
    ALL = ', '.join(args_m)
    w('def eQ(' + ', '.join(decl_m) + f') -> {{VX2.F2({POST}) == {FS}n : Nat}}:')
    cur = [f'List.length(&2, U32, xs{j})' for j in post]

    def term(c):
        t = '0n'
        for q in reversed(c):
            t = f'Nat.add({q}, {t})'
        return f'4n+4n+{t}'
    for a, j in enumerate(post):
        mot = cur[:a] + ['_'] + cur[a + 1:]
        w(f'  %Equal.sym(Nat, List.length(&2, U32, xs{j}), {x.fields[j]["size"]}n, lx{j}) : {{{term(mot)} == {FS}n : Nat}}')
        cur[a] = f'{x.fields[j]["size"]}n'
    w('  {==}')
    w('')
    OUT = f'VX2.OUT2(ys0, ys1, {POST})'
    OUTL = f'VX2.OUTL(ys0, ys1, {POST})'
    w(sig('inv_fin', decl_m, ['+bs: +List<U32>', '+b5: Bool',
          f'+e: {{Codec.bytes(Codec.one(SP.optional(b5, {OUTL}), None{{}})) == Some{{bs}} : {MB}}}']))
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w('    case True{}:')
    w(f'      %F.logic__some_inj(+List<U32>, {OUTL}, bs, e) : FACTS2(_)')
    w(f'      %Equal.sym(+List<U32>, {OUTL}, {OUT}, VX2.out2(ys0, ys1, {POST})) : FACTS2(_)')
    w(f'      +eq = eQ({ALL})')
    w(f'      +f0 = F.logic__subst(Nat, z => {{VS.bt(4n, VS.bdr(0n, {OUT})) == N.digits(4n, z) : +List<U32>}}, VX2.F2({POST}), {FS}n, eq, VX2.o2_b0(ys0, ys1, {POST}))')
    w(f'      +f1 = F.logic__subst(Nat, z => {{VS.bt(4n, VS.bdr(4n, {OUT})) == N.digits(4n, Nat.add(z, List.length(&2, U32, ys0))) : +List<U32>}}, VX2.F2({POST}), {FS}n, eq, VX2.o2_b1(ys0, ys1, {POST}))')
    w(f'      +f2 = F.logic__subst(Nat, z => {{List.length(&2, U32, {OUT}) == Nat.add(z, Nat.add(List.length(&2, U32, ys0), List.length(&2, U32, ys1))) : Nat}}, VX2.F2({POST}), {FS}n, eq, VX2.o2_len(ys0, ys1, {POST}))')
    w(f'      +f3 = F.logic__subst(Nat, z => {{VS.bdr(z, {OUT}) == List.append(&2, U32, ys0, ys1) : +List<U32>}}, VX2.F2({POST}), {FS}n, eq, VX2.o2_dr(ys0, ys1, {POST}))')
    w('      (f0, (hv0, (ys0, (hv1, (ys1, (f1, (f2, (f3, (em0, em1)))))))))')
    w('')
    PLIST = '[' + ', '.join(parts_m) + ']'
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
            w('  match ps:')
            w('    case Nil{}: Empty.absurd(FACTS2(bs), hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: st{i + 1}({A_}xs, Equal.sym(Nat, {z}n, List.length(&2, U32, xs), F.logic__some_inj(Nat, {z}n, List.length(&2, U32, xs), hf)), t, bs, e)')
            w(f'    case Con{{S.Variable{{+xs}}, Nil{{}}}}: Empty.absurd(FACTS2(bs), F.logic__none_some(Nat, {z}n, Equal.sym(Maybe<&2, Nat>, Some{{{z}n}}, None{{}}, hf)))')
            w('    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS2(bs), hf)')
            w('    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS2(bs), hf)')
            w('')
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({A_}ps, hf, t, bs, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({A_}Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), t, bs, e)')
            w('')
        else:
            w(sig(f'fp{i}', decl, ['+h: S.Value', '+ps: +List<S.Part>', 'hf: DF.single(None{}, ps)',
                                   f'+emh: {{Codec.parts(h, {sch}) == Some{{ps}} : {MP}}}', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            w('  match ps:')
            w('    case Nil{}: Empty.absurd(FACTS2(bs), hf)')
            w('    case Con{S.Fixed{+xs}, Nil{}}: Empty.absurd(FACTS2(bs), F.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
            w(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{i + 1}({A_}h, ys, emh, t, bs, e)')
            w('    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS2(bs), hf)')
            w('    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS2(bs), hf)')
            w('')
            w(sig(f'fm{i}', decl, ['+h: S.Value', '+mm: Maybe<&2, +List<S.Part>>', 'hf: DF.single_result(None{}, mm)',
                                   f'+emh: {{Codec.parts(h, {sch}) == mm : {MP}}}', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({A_}h, ps, hf, emh, t, bs, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({A_}h, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), {{==}}, t, bs, e)')
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+bs: +List<U32>', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 't']), f'fd{i}({A_}h, t, bs, e)'))
        w('')
    w('# Every byte string the spec relates to a value has the checked shape.')
    w('law inv_v:')
    w('  for +v: S.Value')
    w('  for +bs: +List<U32>')
    w(f'  for +e: {{Codec.encoding_for_legal_type(Spec.{n}(), v) == Some{{bs}} : {MB}}}')
    w('  FACTS2(bs)')
    w('def inv_v(v, bs, e):')
    L.extend(match_value('v', ('Sequence', ['items']), 'st0(items, bs, e)'))
    w('')
    q = VL.REJ
    q = q[q.index('def q0('):q.index('def ec_sub(')]
    for a, b in [('@FSL', FSL), ('@FS', str(FS)), ('@B0', str(fsb[0])), ('@B1', str(fsb[1])), ('@B2', str(fsb[2])), ('@B3', str(fsb[3]))]:
        q = q.replace(a, b)
    w(q.rstrip() + '\n')
    w('# Every value whose spec parts are one variable part has its bytes in the checked shape.')
    w(f'def inv_p(+v: S.Value, +bs: +List<U32>, +e: {{Codec.parts(v, Spec.{n}()) == Some{{[S.Variable{{bs}}]}} : {MP}}}) -> FACTS2(bs):')
    w(f'  inv_v(v, bs, Equal.cong({MP}, {MB}, z => Codec.bytes(z), Codec.parts(v, Spec.{n}()), Some{{[S.Variable{{bs}}]}}, e))')
    return '\n'.join(L) + '\n'


# ---- the window module ----------------------------------------------------------------------------

def T_(s, mp):
    for a in sorted(mp, key=len, reverse=True):
        s = s.replace(a, mp[a])
    return s


WIN_HEAD = TEMPLATES.text('WIN_HEAD')


def win_text(x):
    n, FS, H, Y = x.n, x.FS, x.H, x.Y
    Tn = f'T.{n}'
    BF = 'UA.BF(t, n)'
    X1 = VX.posx(FS)
    P4 = 'A.quad(VB.pw(d))'
    mp = {'@Tn': Tn, '@FSn': f'{FS}n', '@FS': str(FS), '@X1': X1, '@Y': Y, '@BF': BF, '@P4': P4,
          '@HA': f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}',
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@WHX': VX.WHX, '@PF': VX.PF}
    HEAD = list(VX.HEAD) + ['import ../../src/primitives.bend as I', 'import ../../proofs/primitive_invariants.bend as V',
                            'import ./vbsize.bend as VBZ', 'import ./dk.bend as DK', 'import ./vrej.bend as VR', 'import ./vbx2.bend as VX2',
                            'import ./vdig.bend as VG', 'import ../../spec/nat_bytes.bend as NBx', 'import ./vfits.bend as VFT', 'import ./spec_bits.bend as FB',
                            f'import ./{fname(type("X", (), {"n": Y})).name} as YW', f'import ./{fname(x, "_inv").name} as XI']
    L = HEAD + ['', '# GENERATED by var_bytes_x (codegen: var_bytes_x2). Do not edit.',
                f'# {n} at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend, on',
                f'# {Y}\'s at the windows (off + {FS}, o1 - {FS}) and (off + o1, len - o1) (see codegen/proofs/var/var_bytes_x2.py).']
    L.append(T_(WIN_HEAD, mp))
    w = L.append
    # ---- the reader ----
    Y1o = f'YW.OBJw(d, t, {X1}, U32.add(off, {FS}), L1(t, x))'
    Y2o = f'YW.OBJw(d, t, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len))'
    vals = []
    leaves = []
    for k, f in enumerate([None, None] + x.fields):
        args = ''.join(f'{v}, ' for v in vals)
        frame = f'{Tn}_rd{k}(off, len, {args}@)'
        if k == 0:
            leaves.append((frame, f'B.read32({BF}, U32.add(off, 0))', 'U32', f'rdo0(d, t, n, x, off, len, eo, hd, hw, pf, ha, epo)', None))
            vals.append(str(FS))
            continue
        if k == 1:
            leaves.append((frame, f'B.read32({BF}, U32.add(off, 4))', 'U32', f'rdoff1(d, t, n, x, off, len, eo, hd, hw, pf, ha)', None))
            vals.append('SPO1(t, x)')
            continue
        if f['kind'] == 'var':
            j = k - 2
            if j == 0:
                call = f'T.{Y}_read({BF}, U32.add(off, {FS}), U32.sub(SPO1(t, x), {FS}))'
                pf_ = (f'YW.readw(d, t, n, {X1}, U32.add(off, {FS}), L1(t, x), eo1(d, x, off, len, eo, hd, hw, ha), hd, '
                       f'hw1(d, t, x, len, hw, hc), pf, h1)')
                val = Y1o
            else:
                call = f'T.{Y}_read({BF}, U32.add(off, SPO1(t, x)), U32.sub(len, SPO1(t, x)))'
                pf_ = (f'YW.readw(d, t, n, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len), eo2(d, t, x, off, len, eo, hd, hw, hc), hd, '
                       f'hw2(d, t, x, len, hw, hc), pf, h2)')
                val = Y2o
            leaves.append((frame, call, f'T.{Y}', pf_, val))
            vals.append(val)
            continue
        c = f['c']
        ec = f'eoc(d, x, off, len, {c}, hcF(len, {c}n, {{==}}, ha), eo, hd, hw)'
        if f['kind'] == 'fix':
            ft = f['ft']
            ctx = frame.replace('@', f'T.{ft.p}_bx_rd(@)') if f['box'] else frame
            call = f'T.{ft.p}_read({BF}, U32.add(off, {c}), {f["size"]})'
            inner = ft.obj(x.words(f))
            pf_ = f'{VX.rdx_ref(ft)}(d, t, n, U32.add(off, {c}), {VX.posx(c)}, {ec}, hd30, pf, roomc(d, x, len, {c}n, {ft.size}n, {{==}}, hw, ha))'
            leaves.append((ctx, call, ft.rep(), pf_, inner))
        else:
            z = f['size']
            kw = VBY.kfit(31 + z)
            hs = (f'UW.hsx(d, U32.add(off, {c}), Nat.add(U32.to_nat({c}), x), {z}, {ec}, hd, '
                  f'roomc(d, x, len, U32.to_nat({c}), U32.to_nat({z}), {{==}}, hw, ha))')
            call = f'T.{f["p"]}_read({BF}, U32.add(off, {c}), {z})'
            pf_ = f'VBX.copy_into_at(d, t, n, U32.add(off, {c}), {z}, {f["dz"]}n, {kw}n, pf, hd31, {{==}}, {hs}, {{==}}, {{==}}, {{==}})'
            leaves.append((frame, call, 'O.Words', pf_, x.obj(f)))
        vals.append(x.obj(f))
    OBJ = f'T.{x.s.t.name}{{' + ', '.join(vals[2:]) + '}'
    RHS = f'({BF}, OBJw(d, t, x, off, len))'
    TY = f'B.Buf & {Tn}'
    w(f'def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {Tn}: {OBJ}')
    w('')
    w('# The reader on the window, when the checks hold.')
    w(f'def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {VX.WHX}, {VX.PF},')
    w(f'    {mp["@HA"]}, +epo: {{SPO0(t, x) == {FS} : U32}}, +hc: {{CK(t, x, len) == True{{}} : Bool}},')
    w('    +h1: {D1(t, x, off) == True{} : Bool}, +h2: {D2(t, x, off, len) == True{} : Bool})')
    w(f'    -> {{{Tn}_read({BF}, off, len) == {RHS} : {TY}}}:')
    w('  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {==})')
    w('  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})')
    for ctx, call, rep, pf_, val in leaves:
        pat = ctx.replace('@', '_')
        if val is None:
            w(f'  %Equal.sym(B.Buf & U32, {call}, ({BF}, {"SPO1(t, x)" if "U32.add(off, 4)" in call else FS}), {pf_}) :')
        else:
            w(f'  %Equal.sym(B.Buf & {rep}, {call}, ({BF}, {val}),')
            w(f'      {pf_}) :')
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(TEMPLATES.render('win_text', Tn=Tn, BF=BF, RHS=RHS, TY=TY, FS=FS))
    L.extend(spec_part(x, mp))
    L.extend(inv_part(x, mp))
    return '\n'.join(L) + '\n'


def spec_items(x):
    vals, schs, parts, nodes = [], [], [], []
    for f in x.fields:
        if f['kind'] == 'var':
            j = len(vals)
            vals.append(f'V{j}')
            schs.append(f'Spec.{x.Y}()')
            parts.append(f'S.Variable{{Y{j}}}')
            nodes.append(None)
        else:
            nd = x.node(f)
            nodes.append(nd)
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
    m = len(vals)

    # named field suffixes (var_bytes.chain_defs): the chain's levels carry small calls
    NV = ('XC', '+t: FD.array__Tree<U32>, +x: Nat, +V0: S.Value, +V1: S.Value', 't, x, V0, V1',
          '+t: FD.array__Tree<U32>, +x: Nat, +Y0: +List<U32>, +Y1: +List<U32>', 't, x, Y0, Y1')

    def items(i):
        return f'XCV{i}({NV[2]})'

    def chain(i):
        return f'XCS{i}()'

    def cat(i):
        if i == m:
            return '{==}'
        rest = f'XCP{i + 1}({NV[4]})'
        if nodes[i] is not None:
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, Y{i}, {rest}, '
                f'hv{i}, {cat(i + 1)})')
    POSTb = '[' + ', '.join(f'F.limbs([{", ".join(nd["words"])}])' for nd in nodes[2:]) + ']'
    from codegen.proofs.var import var_bytes as VBY
    proofs = [('fixed', f'F.limbs([{", ".join(nodes[i]["words"])}])', nodes[i]['proof']) if nodes[i] is not None else ('var', f'Y{i}', f'hv{i}')
              for i in range(m)]
    CD = ('+t: FD.array__Tree<U32>, +x: Nat, +V0: S.Value, +V1: S.Value, +Y0: +List<U32>, +Y1: +List<U32>, '
          f'+hv0: {{Codec.parts(V0, Spec.{x.Y}()) == Some{{[S.Variable{{Y0}}]}} : Maybe<&2, +List<S.Part>>}}, '
          f'+hv1: {{Codec.parts(V1, Spec.{x.Y}()) == Some{{[S.Variable{{Y1}}]}} : Maybe<&2, +List<S.Part>>}}')
    return (items(0), chain(0), f'XCP0({NV[4]})', 'XCT0(t, x, V0, V1, Y0, Y1, hv0, hv1)', POSTb, nodes[2:],
            VBY.chain_defs(*NV, vals, schs, parts, CD, 't, x, V0, V1, Y0, Y1, hv0, hv1', proofs))


def spec_part(x, mp):
    n, FS, H, Y = x.n, x.FS, x.H, x.Y
    ITEMS, CHAIN, PL, CAT, POSTb, pnodes, CDEFS = spec_items(x)
    CDEF = '\n'.join(CDEFS)
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'

    def valid(k):
        if k == len(pnodes):
            return '{==}'
        rest = '[' + ', '.join(f'F.limbs([{", ".join(nd["words"])}])' for nd in pnodes[k + 1:]) + ']'
        wk = f'[{", ".join(pnodes[k]["words"])}]'
        return (f'V.and_true(SP.bytes_domain(F.limbs({wk})), Layout.bytes_valid(VR.bfix({rest})), F.domain_limbs({wk}), {valid(k + 1)})')
    HPV = valid(0)
    X1 = VX.posx(FS)
    L1n = 'U32.to_nat(L1(t, x))'
    L2n = 'U32.to_nat(L2(t, x, len))'
    Y0x = f'UW.WX(t, {X1}, {L1n})'
    Y1x = f'UW.WX(t, X2(t, x), {L2n})'
    WX = 'UW.WX(t, x, U32.to_nat(len))'
    OUTx = f'VX2.OUT2({Y0x}, {Y1x}, {POSTb})'
    hdr = []
    for f in x.fields:
        hdr += (x.words(f) if f['kind'] != 'var' else [])
    RWSL = '[' + ', '.join([VX.rwn(0), VX.rwn(4)] + hdr) + ']'
    RWSh = '[' + ', '.join(['_', VX.rwn(4)] + hdr) + ']'
    R2u = (lambda Z: f'List.append(&2, U32, List.append(&2, U32, N.digits(4n, VX2.F2({POSTb})), List.append(&2, U32, N.digits(4n, {Z}), VR.bcat({POSTb}))), List.append(&2, U32, {Y0x}, {Y1x}))')
    QH = f'A.quad({H}n)'
    RHS3 = (lambda P2: f'List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), List.append(&2, U32, UW.WX(t, Nat.add({QH}, x), {L1n}), UW.WX(t, {P2}, {L2n})))')
    POS = f'Nat.add({L1n}, Nat.add({QH}, x))'
    s = f'''
# ---- the spec side ------------------------------------------------------------------------------

# The value of the window's fixed words and the children's values V0, V1, through its named field suffixes.
{CDEF}
def XVw(+t: FD.array__Tree<U32>, +x: Nat, +V0: S.Value, +V1: S.Value) -> S.Value: S.Sequence{{{ITEMS}}}

# Its spec parts: one variable part, the layout of the children's bytes Y0, Y1 and the fixed words.
def encpw(+t: FD.array__Tree<U32>, +x: Nat, +V0: S.Value, +V1: S.Value, +Y0: +List<U32>, +Y1: +List<U32>,
    +hv0: {{Codec.parts(V0, Spec.{Y}()) == Some{{[S.Variable{{Y0}}]}} : {MP}}}, +hv1: {{Codec.parts(V1, Spec.{Y}()) == Some{{[S.Variable{{Y1}}]}} : {MP}}},
    +hd0: {{SP.bytes_domain(Y0) == True{{}} : Bool}}, +hd1: {{SP.bytes_domain(Y1) == True{{}} : Bool}},
    +fit: {{N.fits(4n, Nat.add(VX2.F2({POSTb}), List.length(&2, U32, List.append(&2, U32, Y0, List.append(&2, U32, Y1, []))))) == True{{}} : Bool}})
    -> {{Codec.parts(XVw(t, x, V0, V1), Spec.{n}()) == Some{{[S.Variable{{VX2.OUT2(Y0, Y1, {POSTb})}}]}} : {MP}}}:
{VX.seq_step(n, 'XVw(t, x, V0, V1)', ITEMS, CHAIN, f'Some{{[S.Variable{{VX2.OUT2(Y0, Y1, {POSTb})}}]}}', MP)}  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PL}}},
      {CAT}) :
    {{Codec.aggregate(_, SC.fixed_size({CHAIN})) == Some{{[S.Variable{{VX2.OUT2(Y0, Y1, {POSTb})}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VX2.PR2(Y0, Y1, {POSTb})), Some{{VX2.OUT2(Y0, Y1, {POSTb})}},
      VX2.enc2(Y0, Y1, {POSTb}, VX2.valid2(Y0, Y1, {POSTb}, hd0, hd1, {HPV}), fit)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{VX2.OUT2(Y0, Y1, {POSTb})}}]}} : {MP}}}
  {{==}}

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: XVw(t, x, YW.VALw(t, {X1}, L1(t, x)), YW.VALw(t, X2(t, x), L2(t, x, len)))
# VALw's body, as a rewrite (a spec-parts goal over VALw compared with one over its body ran the spec encoder)
def VALq(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {{XVw(t, x, YW.VALw(t, {X1}, L1(t, x)), YW.VALw(t, X2(t, x), L2(t, x, len))) == VALw(t, x, len) : S.Value}}: {{==}}

# |y0| + |y1| of the two windows, and the whole window's length.
def lenY(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {VX.PF}, @HW, @HA, +hc: {{CK(t, x, len) == True{{}} : Bool}})
    -> {{List.length(&2, U32, List.append(&2, U32, {Y0x}, List.append(&2, U32, {Y1x}, []))) == Nat.add({L1n}, {L2n}) : Nat}}:
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, {Y0x}, List.append(&2, U32, {Y1x}, []))), Nat.add(List.length(&2, U32, {Y0x}), List.length(&2, U32, List.append(&2, U32, {Y1x}, []))),
      VS.len_app({Y0x}, List.append(&2, U32, {Y1x}, []))) : {{_ == Nat.add({L1n}, {L2n}) : Nat}}
  %Equal.sym(+List<U32>, List.append(&2, U32, {Y1x}, []), {Y1x}, VS.app_nil({Y1x})) :
    {{Nat.add(List.length(&2, U32, {Y0x}), List.length(&2, U32, _)) == Nat.add({L1n}, {L2n}) : Nat}}
  %Equal.sym(Nat, List.length(&2, U32, {Y0x}), {L1n}, UW.lenWX(d, t, {X1}, {L1n}, pf, hw1(d, t, x, len, hw, hc))) :
    {{Nat.add(_, List.length(&2, U32, {Y1x})) == Nat.add({L1n}, {L2n}) : Nat}}
  %Equal.sym(Nat, List.length(&2, U32, {Y1x}), {L2n}, UW.lenWX(d, t, X2(t, x), {L2n}, pf, hw2(d, t, x, len, hw, hc))) :
    {{Nat.add({L1n}, _) == Nat.add({L1n}, {L2n}) : Nat}}
  {{==}}

def eLen(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {{CK(t, x, len) == True{{}} : Bool}})
    -> {{Nat.add({FS}n, Nat.add({L1n}, {L2n})) == U32.to_nat(len) : Nat}}:
  %Equal.sym(Nat, Nat.add(Nat.add({FS}n, {L1n}), {L2n}), Nat.add({FS}n, Nat.add({L1n}, {L2n})), FD.nat__add_assoc({FS}n, {L1n}, {L2n})) :
    {{_ == U32.to_nat(len) : Nat}}
  %Equal.sym(Nat, Nat.add(U32.to_nat({FS}), {L1n}), U32.to_nat(SPO1(t, x)), eL1(t, x, len, hc)) : {{Nat.add(_, {L2n}) == U32.to_nat(len) : Nat}}
  eL2(t, x, len, hc)

def fitw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {VX.PF}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}, @HW, @HA,
    +hc: {{CK(t, x, len) == True{{}} : Bool}})
    -> {{N.fits(4n, Nat.add(VX2.F2({POSTb}), List.length(&2, U32, List.append(&2, U32, {Y0x}, List.append(&2, U32, {Y1x}, []))))) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, {Y0x}, List.append(&2, U32, {Y1x}, []))), Nat.add({L1n}, {L2n}), lenY(d, t, x, len, pf, hw, ha, hc)) : {{N.fits(4n, Nat.add(VX2.F2({POSTb}), _)) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add({FS}n, Nat.add({L1n}, {L2n})), U32.to_nat(len), eLen(t, x, len, hc)) : {{N.fits(4n, _) == True{{}} : Bool}}
  VBZ.fitq(d, U32.to_nat(len), FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), @P4, Order.left_below_sum(x, U32.to_nat(len)), hw),
    FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))

def hwH(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @HW, +hc: {{CK(t, x, len) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(x, Nat.add({QH}, Nat.add({L1n}, {L2n}))), @P4) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add({FS}n, Nat.add({L1n}, {L2n})), U32.to_nat(len), eLen(t, x, len, hc)) : {{Nat.is_le(Nat.add(x, _), @P4) == True{{}} : Bool}}
  hw

# The second child's position: |y0| + (FS + x) = o1 + x.
def ePos(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {{CK(t, x, len) == True{{}} : Bool}})
    -> {{{POS} == X2(t, x) : Nat}}:
  %FD.nat__add_assoc({L1n}, {QH}, x) : {{_ == X2(t, x) : Nat}}
  %FD.nat__add_comm({QH}, {L1n}) : {{Nat.add(_, x) == X2(t, x) : Nat}}
  %Equal.sym(Nat, Nat.add(U32.to_nat({FS}), {L1n}), U32.to_nat(SPO1(t, x)), eL1(t, x, len, hc)) : {{Nat.add(_, x) == X2(t, x) : Nat}}
  {{==}}

# The layout of the children's windows and the header words is the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {VX.PF}, @HW, @HA, +epo: {{SPO0(t, x) == {FS} : U32}},
    +hc: {{CK(t, x, len) == True{{}} : Bool}})
    -> {{{OUTx} == {WX} : +List<U32>}}:
  %eLen(t, x, len, hc) : {{{OUTx} == UW.WX(t, x, _) : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add({QH}, Nat.add({L1n}, {L2n}))), List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), UW.WX(t, Nat.add({QH}, x), Nat.add({L1n}, {L2n}))),
      UW.headWX(d, t, x, {H}n, Nat.add({L1n}, {L2n}), pf, hwH(d, t, x, len, hw, hc))) :
    {{{OUTx} == _ : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, Nat.add({QH}, x), Nat.add({L1n}, {L2n})), List.append(&2, U32, UW.WX(t, Nat.add({QH}, x), {L1n}), UW.WX(t, {POS}, {L2n})),
      VX2.splitWX(t, Nat.add({QH}, x), {L1n}, {L2n})) :
    {{{OUTx} == List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), _) : +List<U32>}}
  %Equal.sym(Nat, {POS}, X2(t, x), ePos(t, x, len, hc)) : {{{OUTx} == {RHS3('_')} : +List<U32>}}
  %Equal.sym(Nat, List.length(&2, U32, {Y0x}), {L1n}, UW.lenWX(d, t, {X1}, {L1n}, pf, hw1(d, t, x, len, hw, hc))) :
    {{{R2u('Nat.add(VX2.F2(' + POSTb + '), _)')} == {RHS3('X2(t, x)')} : +List<U32>}}
  %Equal.sym(Nat, Nat.add(U32.to_nat({FS}), {L1n}), U32.to_nat(SPO1(t, x)), eL1(t, x, len, hc)) :
    {{{R2u('_')} == {RHS3('X2(t, x)')} : +List<U32>}}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(SPO1(t, x))), I.limb(SPO1(t, x)), VG.digits_limb(SPO1(t, x))) :
    {{List.append(&2, U32, List.append(&2, U32, N.digits(4n, VX2.F2({POSTb})), List.append(&2, U32, _, VR.bcat({POSTb}))), List.append(&2, U32, {Y0x}, {Y1x})) == {RHS3('X2(t, x)')} : +List<U32>}}
  %Equal.sym(U32, SPO0(t, x), {FS}, epo) :
    {{List.append(&2, U32, List.append(&2, U32, N.digits(4n, VX2.F2({POSTb})), List.append(&2, U32, I.limb(SPO1(t, x)), VR.bcat({POSTb}))), List.append(&2, U32, {Y0x}, {Y1x})) == List.append(&2, U32, F.limbs({RWSh}), List.append(&2, U32, UW.WX(t, Nat.add({QH}, x), {L1n}), UW.WX(t, X2(t, x), {L2n}))) : +List<U32>}}
  {{==}}

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {VX.WHX}, {VX.PF}, @HA, +epo: {{SPO0(t, x) == {FS} : U32}},
    +hc: {{CK(t, x, len) == True{{}} : Bool}}, +h1: {{D1(t, x, off) == True{{}} : Bool}}, +h2: {{D2(t, x, off, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  %VALq(t, x, len) :
    {{Codec.parts(_, Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}
  %bytesw(d, t, x, len, pf, hw, ha, epo, hc) :
    {{Codec.parts(XVw(t, x, YW.VALw(t, {X1}, L1(t, x)), YW.VALw(t, X2(t, x), L2(t, x, len))), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  encpw(t, x, YW.VALw(t, {X1}, L1(t, x)), YW.VALw(t, X2(t, x), L2(t, x, len)), {Y0x}, {Y1x},
    YW.specw(d, t, n, {X1}, U32.add(off, {FS}), L1(t, x), eo1(d, x, off, len, eo, hd, hw, ha), hd, hw1(d, t, x, len, hw, hc), pf, h1),
    YW.specw(d, t, n, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len), eo2(d, t, x, off, len, eo, hd, hw, hc), hd, hw2(d, t, x, len, hw, hc), pf, h2),
    UW.domWX(t, {X1}, {L1n}), UW.domWX(t, X2(t, x), {L2n}), fitw(d, t, x, len, pf, hd, hw, ha, hc))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {VX.WHX}, {VX.PF},
    +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPO0(t, x), {FS})
  +c = CK(t, x, len)
  +dd = D1(t, x, off)
  +e = D2(t, x, off, len)
  +ha = c5a(a, b, c, dd, e, hchk)
  +h1 = FD.logic__subst(Bool, z => {{chk5(z, b, c, dd, e) == True{{}} : Bool}}, a, True{{}}, ha, hchk)
  +hb = c5b(b, c, dd, e, h1)
  +h2 = FD.logic__subst(Bool, z => {{chk5(True{{}}, z, c, dd, e) == True{{}} : Bool}}, b, True{{}}, hb, h1)
  +hc = c5c(c, dd, e, h2)
  +h3 = FD.logic__subst(Bool, z => {{chk5(True{{}}, True{{}}, z, dd, e) == True{{}} : Bool}}, c, True{{}}, hc, h2)
  +hd1 = c5d(dd, e, h3)
  +h4 = FD.logic__subst(Bool, z => {{chk5(True{{}}, True{{}}, True{{}}, z, e) == True{{}} : Bool}}, dd, True{{}}, hd1, h3)
  specw_go(d, t, n, x, off, len, eo, hd, hw, pf, ha, FD.u32alg__eq_of(SPO0(t, x), {FS}, hb), hc, hd1, c5e(e, h4))
'''
    return [T_(s, mp)]


def inv_part(x, mp):
    n, FS, H, Y = x.n, x.FS, x.H, x.Y
    X1 = VX.posx(FS)
    fsb = [FS & 255, (FS >> 8) & 255, (FS >> 16) & 255, (FS >> 24) & 255]
    FSL = '[' + ', '.join(map(str, fsb)) + ']'
    MP = 'Maybe<&2, +List<S.Part>>'
    L1n = 'U32.to_nat(L1(t, x))'
    L2n = 'U32.to_nat(L2(t, x, len))'
    K0 = 'List.length(&2, U32, ys0)'
    K1 = 'List.length(&2, U32, ys1)'
    WXn = 'UW.WX(t, x, U32.to_nat(len))'
    ARGS = '+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF'
    A_ = 'd, t, n, x, off, len, eo, hd, hw, pf'
    F1 = f'{{VS.bt(4n, VS.bdr(4n, {WXn})) == N.digits(4n, Nat.add({FS}n, {K0})) : +List<U32>}}'
    F2_ = f'{{List.length(&2, U32, {WXn}) == Nat.add({FS}n, Nat.add({K0}, {K1})) : Nat}}'
    F3 = f'{{VS.bdr({FS}n, {WXn}) == List.append(&2, U32, ys0, ys1) : +List<U32>}}'
    E0 = f'{{Codec.parts(hv0, Spec.{Y}()) == Some{{[S.Variable{{ys0}}]}} : {MP}}}'
    E1 = f'{{Codec.parts(hv1, Spec.{Y}()) == Some{{[S.Variable{{ys1}}]}} : {MP}}}'
    s = TEMPLATES.render('inv_part', WXn=WXn, ARGS=ARGS, FSL=FSL, F1=F1, F2_=F2_, F3=F3, E0=E0, E1=E1, K0=K0, K1=K1, FS=FS, X1=X1, L1n=L1n, L2n=L2n, Y=Y, MP=MP, A_=A_, n=n)
    return [T_(s, mp)]


# ---- the whole-buffer decoder laws ---------------------------------------------------------------

def dec_text(x):
    n, Y = x.n, x.Y
    Tn = f'T.{n}'
    D = f'B.Buf & Maybe<&1, {Tn}>'
    H = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../../proofs/decode_unique.bend as DCO',
         'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA',
         'import ./vua_win.bend as UW', f'import ./{fname(x).name} as W', f'import ./{fname(x, "_inv").name} as XI', '',
         '# GENERATED by var_bytes_x (codegen: var_bytes_x2). Do not edit.',
         f'# {n} on a whole buffer: the decoder laws, the window laws of {fname(x).name}',
         '# at x = 0, off = 0, len = n (buffers on perfect trees of depth d < 28).', '']
    Q = ['  for +d: Nat', '  for +t: FD.array__Tree<U32>', '  for +n: U32',
         '  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}',
         '  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}',
         '  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}']
    q = '\n'.join(Q)
    return '\n'.join(H) + TEMPLATES.render('dec_text', Tn=Tn, q=q, D=D, n=n)
