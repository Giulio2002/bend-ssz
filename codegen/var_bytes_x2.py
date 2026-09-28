"""Byte-offset windows of containers whose first TWO fields are variable, both a
name with a byte-offset window module of codegen/var_bytes_x.py, followed by
fixed fields (LightClientFinalityUpdate: two LightClientHeaders, the finality
branch, a boxed SyncAggregate, the signature slot). Called from
codegen/var_bytes_x.py.

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

import spec_laws as SL
import var_laws as VL
import var_bytes as VBY
import var_bytes_x as VX

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
         '# GENERATED by codegen/var_bytes_x.py (codegen/var_bytes_x2.py). Do not edit.',
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


WIN_HEAD = """
def chk5(a: Bool, b: Bool, c: Bool, d: Bool, e: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}:
          match c:
            case False{}: False{}
            case True{}:
              match d:
                case False{}: False{}
                case True{}: e

def c5a(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def c5b(+b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(True{}, b, c, d, e) == True{} : Bool}) -> {b == True{} : Bool}:
  match b:
    case False{}: h
    case True{}: {==}

def c5c(+c: Bool, +d: Bool, +e: Bool, +h: {chk5(True{}, True{}, c, d, e) == True{} : Bool}) -> {c == True{} : Bool}:
  match c:
    case False{}: h
    case True{}: {==}

def c5d(+d: Bool, +e: Bool, +h: {chk5(True{}, True{}, True{}, d, e) == True{} : Bool}) -> {d == True{} : Bool}:
  match d:
    case False{}: h
    case True{}: {==}

def c5e(+e: Bool, +h: {chk5(True{}, True{}, True{}, True{}, e) == True{} : Bool}) -> {e == True{} : Bool}:
  h

def c3_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32, +o1: U32) -> {@Tn_c3(ok, buf, off, len, o0, o1) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def SPO0(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, x)
def SPO1(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, 4n+x)
def L1(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub(SPO1(t, x), @FS)
def L2(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> U32: U32.sub(len, SPO1(t, x))
def X2(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat(SPO1(t, x)), x)
def CK(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le(@FS, SPO1(t, x)), U32.is_le(SPO1(t, x), len))
def D1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> Bool: YW.CHKw(t, @X1, U32.add(off, @FS), L1(t, x))
def D2(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: YW.CHKw(t, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len))

# The checks: the size, the first offset, the second offset between it and the end, and
# @Y's checks on the two windows.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  chk5(U32.is_le(@FS, len), U32.is_eq(SPO0(t, x), @FS), CK(t, x, len), D1(t, x, off), D2(t, x, off, len))

def leFS(+len: U32, @HA) -> {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, len), Nat.is_le(@FSn, U32.to_nat(len)), VU.le_u32(@FS, len), ha)

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def subc(+n: U32, +k: U32, +y: Nat, +e: {U32.to_nat(n) == Nat.add(U32.to_nat(k), y) : Nat}) -> {U32.to_nat(U32.sub(n, k)) == y : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(k), z) == True{} : Bool}, Nat.add(U32.to_nat(k), y), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e), FD.nat__le_add_right(U32.to_nat(k), y))
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, k)), Nat.sub(U32.to_nat(n), U32.to_nat(k)), FD.u32__sub_nat(n, k, le)) : {_ == y : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e) : {Nat.sub(_, U32.to_nat(k)) == y : Nat}
  FD.nat__add_sub_cancel(U32.to_nat(k), y)

# c + x <= 4 2^d for c <= len.
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, U32.to_nat(len)) == True{} : Bool}, @HW)
    -> {Nat.is_le(Nat.add(c, x), @P4) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), @P4, Order.add_right(c, U32.to_nat(len), x, hc),
    FD.logic__subst(Nat, z => {Nat.is_le(z, @P4) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

# The byte offset off + c, for c <= len, is at c + x.
def eoc(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == True{} : Bool}, @WHX)
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw))

def hcF(+len: U32, +c: Nat, +hc: {Nat.is_le(c, @FSn) == True{} : Bool}, @HA) -> {Nat.is_le(c, U32.to_nat(len)) == True{} : Bool}:
  FD.nat__le_trans(c, @FSn, U32.to_nat(len), hc, leFS(len, ha))

# Room for a field of s bytes at c + x, for c + s <= @FS.
def roomc(+d: Nat, +x: Nat, +len: U32, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), @FSn) == True{} : Bool}, @HW, @HA)
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), @P4) == True{} : Bool}:
  UR.roomf(x, U32.to_nat(len), c, s, @P4, hw, hcF(len, Nat.add(c, s), hc, ha))

# ---- the two windows ---------------------------------------------------------------------------

def ck1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(@FS), U32.to_nat(SPO1(t, x))) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, SPO1(t, x)), Nat.is_le(U32.to_nat(@FS), U32.to_nat(SPO1(t, x))), VU.le_u32(@FS, SPO1(t, x)),
    FD.logic__and_left(U32.is_le(@FS, SPO1(t, x)), U32.is_le(SPO1(t, x), len), hc))

def ck2(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(SPO1(t, x)), U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(SPO1(t, x), len), Nat.is_le(U32.to_nat(SPO1(t, x)), U32.to_nat(len)), VU.le_u32(SPO1(t, x), len),
    FD.logic__and_right(U32.is_le(@FS, SPO1(t, x)), U32.is_le(SPO1(t, x), len), hc))

def eL1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.add(U32.to_nat(@FS), U32.to_nat(L1(t, x))) == U32.to_nat(SPO1(t, x)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L1(t, x)), Nat.sub(U32.to_nat(SPO1(t, x)), U32.to_nat(@FS)), FD.u32__sub_nat(SPO1(t, x), @FS, ck1(t, x, len, hc))) :
    {Nat.add(U32.to_nat(@FS), _) == U32.to_nat(SPO1(t, x)) : Nat}
  FD.nat__sub_add(U32.to_nat(SPO1(t, x)), U32.to_nat(@FS), ck1(t, x, len, hc))

def eL2(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.add(U32.to_nat(SPO1(t, x)), U32.to_nat(L2(t, x, len))) == U32.to_nat(len) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L2(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(SPO1(t, x))), FD.u32__sub_nat(len, SPO1(t, x), ck2(t, x, len, hc))) :
    {Nat.add(U32.to_nat(SPO1(t, x)), _) == U32.to_nat(len) : Nat}
  FD.nat__sub_add(U32.to_nat(len), U32.to_nat(SPO1(t, x)), ck2(t, x, len, hc))

def eo1(+d: Nat, +x: Nat, +off: U32, +len: U32, @WHX, @HA) -> {U32.to_nat(U32.add(off, @FS)) == @X1 : Nat}:
  eoc(d, x, off, len, @FS, leFS(len, ha), eo, hd, hw)

def eo2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, @WHX, +hc: {CK(t, x, len) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, SPO1(t, x))) == X2(t, x) : Nat}:
  eoc(d, x, off, len, SPO1(t, x), ck2(t, x, len, hc), eo, hd, hw)

# (a + x) + b = x + (a + b)
def swp(+a: Nat, +x: Nat, +b: Nat) -> {Nat.add(Nat.add(a, x), b) == Nat.add(x, Nat.add(a, b)) : Nat}:
  Equal.trans(Nat, Nat.add(Nat.add(a, x), b), Nat.add(a, Nat.add(x, b)), Nat.add(x, Nat.add(a, b)), FD.nat__add_assoc(a, x, b), FD.lru_nat_algebra__add_swap(a, x, b))

def hw1(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @HW, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(@FS), x), U32.to_nat(L1(t, x))), @P4) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(@FS), x), U32.to_nat(L1(t, x))), Nat.add(x, Nat.add(U32.to_nat(@FS), U32.to_nat(L1(t, x)))), swp(U32.to_nat(@FS), x, U32.to_nat(L1(t, x)))) :
    {Nat.is_le(_, @P4) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(@FS), U32.to_nat(L1(t, x))), U32.to_nat(SPO1(t, x)), eL1(t, x, len, hc)) : {Nat.is_le(Nat.add(x, _), @P4) == True{} : Bool}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(SPO1(t, x))), Nat.add(x, U32.to_nat(len)), @P4, Order.add_left(x, U32.to_nat(SPO1(t, x)), U32.to_nat(len), ck2(t, x, len, hc)), hw)

def hw2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @HW, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(Nat.add(X2(t, x), U32.to_nat(L2(t, x, len))), @P4) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(SPO1(t, x)), x), U32.to_nat(L2(t, x, len))), Nat.add(x, Nat.add(U32.to_nat(SPO1(t, x)), U32.to_nat(L2(t, x, len)))), swp(U32.to_nat(SPO1(t, x)), x, U32.to_nat(L2(t, x, len)))) :
    {Nat.is_le(_, @P4) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(SPO1(t, x)), U32.to_nat(L2(t, x, len))), U32.to_nat(len), eL2(t, x, len, hc)) : {Nat.is_le(Nat.add(x, _), @P4) == True{} : Bool}
  hw

# ---- the validator ------------------------------------------------------------------------------

def rdoff0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA)
    -> {B.read32(@BF, U32.add(off, 0)) == (@BF, SPO0(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, 0), x, eoc(d, x, off, len, 0, FD.nat__zero_le(U32.to_nat(len)), eo, hd, hw), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomc(d, x, len, 0n, 4n, {==}, hw, ha))

def rdoff1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA)
    -> {B.read32(@BF, U32.add(off, 4)) == (@BF, SPO1(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, 4), 4n+x, eoc(d, x, off, len, 4, hcF(len, 4n, {==}, ha), eo, hd, hw), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomc(d, x, len, 4n, 4n, {==}, hw, ha))

def okc2(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +hc: {CK(t, x, len) == True{} : Bool},
    +b: Bool, +eb: {D1(t, x, off) == b : Bool})
    -> {@Tn_c2(b, @BF, off, len, @FS, SPO1(t, x)) == (@BF, chk5(True{}, True{}, True{}, b, D2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & Bool, T.@Y_ok(@BF, U32.add(off, SPO1(t, x)), U32.sub(len, SPO1(t, x))), (@BF, D2(t, x, off, len)),
          YW.ok_evalw(d, t, n, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len), eo2(d, t, x, off, len, eo, hd, hw, hc), hd, hw2(d, t, x, len, hw, hc), pf)) :
        {@Tn_v3(off, len, @FS, SPO1(t, x), _) == (@BF, D2(t, x, off, len)) : B.Buf & Bool}
      c3_id(D2(t, x, off, len), @BF, off, len, @FS, SPO1(t, x))

def okc1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA,
    +b: Bool, +eb: {CK(t, x, len) == b : Bool})
    -> {@Tn_c1(b, @BF, off, len, @FS, SPO1(t, x)) == (@BF, chk5(True{}, True{}, b, D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & Bool, T.@Y_ok(@BF, U32.add(off, @FS), U32.sub(SPO1(t, x), @FS)), (@BF, D1(t, x, off)),
          YW.ok_evalw(d, t, n, @X1, U32.add(off, @FS), L1(t, x), eo1(d, x, off, len, eo, hd, hw, ha), hd, hw1(d, t, x, len, hw, eb), pf)) :
        {@Tn_v2(off, len, @FS, SPO1(t, x), _) == (@BF, chk5(True{}, True{}, True{}, D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      okc2(d, t, n, x, off, len, eo, hd, hw, pf, eb, D1(t, x, off), {==})

def okc0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA,
    +b: Bool, +eb: {U32.is_eq(SPO0(t, x), @FS) == b : Bool})
    -> {@Tn_c0(b, @BF, off, len, SPO0(t, x)) == (@BF, chk5(True{}, b, CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +epo = FD.u32alg__eq_of(SPO0(t, x), @FS, eb)
      %Equal.sym(U32, SPO0(t, x), @FS, epo) :
        {@Tn_v1(off, len, _, B.read32(@BF, U32.add(off, 4))) == (@BF, chk5(True{}, True{}, CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, 4)), (@BF, SPO1(t, x)), rdoff1(d, t, n, x, off, len, eo, hd, hw, pf, ha)) :
        {@Tn_v1(off, len, @FS, _) == (@BF, chk5(True{}, True{}, CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      okc1(d, t, n, x, off, len, eo, hd, hw, pf, ha, CK(t, x, len), {==})

def okl(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +a: Bool, +ea: {U32.is_le(@FS, len) == a : Bool})
    -> {@Tn_ok_len(a, @BF, off, len) == (@BF, chk5(a, U32.is_eq(SPO0(t, x), @FS), CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, 0)), (@BF, SPO0(t, x)), rdoff0(d, t, n, x, off, len, eo, hd, hw, pf, ea)) :
        {@Tn_v0(off, len, _) == (@BF, chk5(True{}, U32.is_eq(SPO0(t, x), @FS), CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      okc0(d, t, n, x, off, len, eo, hd, hw, pf, ea, U32.is_eq(SPO0(t, x), @FS), {==})

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF)
    -> {@Tn_ok(@BF, off, len) == (@BF, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okl(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_le(@FS, len), {==})

# The first offset word, once checked, reads as @FS.
def rdo0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA, +epo: {SPO0(t, x) == @FS : U32})
    -> {B.read32(@BF, U32.add(off, 0)) == (@BF, @FS) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, 0)), (@BF, SPO0(t, x)), rdoff0(d, t, n, x, off, len, eo, hd, hw, pf, ha)) :
    {_ == (@BF, @FS) : B.Buf & U32}
  %Equal.sym(U32, SPO0(t, x), @FS, epo) : {(@BF, _) == (@BF, @FS) : B.Buf & U32}
  {==}
"""


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
    L = HEAD + ['', '# GENERATED by codegen/var_bytes_x.py (codegen/var_bytes_x2.py). Do not edit.',
                f'# {n} at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend, on',
                f'# {Y}\'s at the windows (off + {FS}, o1 - {FS}) and (off + o1, len - o1) (see codegen/var_bytes_x2.py).']
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
    w(f'''
# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {VX.WHX}, {VX.PF},
    +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}})
    -> {{{Tn}_read({BF}, off, len) == {RHS} : {TY}}}:
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
  rdw_go(d, t, n, x, off, len, eo, hd, hw, pf, ha, FD.u32alg__eq_of(SPO0(t, x), {FS}, hb), hc, hd1, c5e(e, h4))
''')
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
    import var_bytes as VBY
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
    s = f'''
# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

# The four bytes at offset P of the window are the word at P + x.
def byteAt(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +P: Nat, +R: Nat, +en: {{U32.to_nat(len) == Nat.add(P, 4n+R) : Nat}}, @PF, @HW)
    -> {{VS.bt(4n, VS.bdr(P, {WXn})) == F.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}}:
  +hw2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), @P4) == True{{}} : Bool}}, U32.to_nat(len), Nat.add(P, 4n+R), en, hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(P, 4n+R), en) : {{VS.bt(4n, VS.bdr(P, UW.WX(t, x, _))) == F.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}}
  UW.byteWX(d, t, x, P, R, pf, hw2)

def inv_tail({ARGS}, +hb0: {{VS.bt(4n, VS.bdr(0n, {WXn})) == {FSL} : +List<U32>}},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: {F1}, +f2: {F2_}, +f3: {F3}, +em0: {E0}, +em1: {E1})
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  +K = Nat.add({K0}, {K1})
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, {WXn}), Nat.add({FS}n, K), Equal.sym(Nat, List.length(&2, U32, {WXn}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)), f2)
  +hl = FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), @P4, Order.left_below_sum(x, U32.to_nat(len)), hw)
  +ha = u32le({FS}, len, FD.logic__subst(Nat, z => {{Nat.is_le({FS}n, z) == True{{}} : Bool}}, Nat.add({FS}n, K), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add({FS}n, K), en), Order.below_sum({FS}n, K)))
  +epo = XI.wordFS(SPO0(t, x), Equal.trans(+List<U32>, F.limbs([SPO0(t, x)]), VS.bt(4n, VS.bdr(0n, {WXn})), {FSL},
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(0n, {WXn})), F.limbs([SPO0(t, x)]), byteAt(d, t, x, len, 0n, Nat.add({FS - 4}n, K), en, pf, hw)), hb0))
  +le1 = FD.nat__le_trans(Nat.add({FS}n, {K0}), Nat.add({FS}n, K), @P4, Order.add_left({FS}n, {K0}, K, Order.below_sum({K0}, {K1})),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, @P4) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({FS}n, K), en, hl))
  +e1 = VG.digits_word(SPO1(t, x), Nat.add({FS}n, {K0}), VBZ.fitq(d, Nat.add({FS}n, {K0}), le1, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})),
    Equal.trans(+List<U32>, I.limb(SPO1(t, x)), VS.bt(4n, VS.bdr(4n, {WXn})), N.digits(4n, Nat.add({FS}n, {K0})),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(4n, {WXn})), I.limb(SPO1(t, x)), byteAt(d, t, x, len, 4n, Nat.add({FS - 8}n, K), en, pf, hw)), f1))
  +hc1 = u32le({FS}, SPO1(t, x), FD.logic__subst(Nat, z => {{Nat.is_le({FS}n, z) == True{{}} : Bool}}, Nat.add({FS}n, {K0}), U32.to_nat(SPO1(t, x)), Equal.sym(Nat, U32.to_nat(SPO1(t, x)), Nat.add({FS}n, {K0}), e1), Order.below_sum({FS}n, {K0})))
  +e2 = Equal.trans(Nat, U32.to_nat(len), Nat.add({FS}n, K), Nat.add(U32.to_nat(SPO1(t, x)), {K1}), en,
    Equal.trans(Nat, Nat.add({FS}n, K), Nat.add(Nat.add({FS}n, {K0}), {K1}), Nat.add(U32.to_nat(SPO1(t, x)), {K1}),
      Equal.sym(Nat, Nat.add(Nat.add({FS}n, {K0}), {K1}), Nat.add({FS}n, K), FD.nat__add_assoc({FS}n, {K0}, {K1})),
      Equal.cong(Nat, Nat, z => Nat.add(z, {K1}), Nat.add({FS}n, {K0}), U32.to_nat(SPO1(t, x)), Equal.sym(Nat, U32.to_nat(SPO1(t, x)), Nat.add({FS}n, {K0}), e1))))
  +hc2 = u32le(SPO1(t, x), len, FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(SPO1(t, x)), z) == True{{}} : Bool}}, Nat.add(U32.to_nat(SPO1(t, x)), {K1}), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(U32.to_nat(SPO1(t, x)), {K1}), e2), Order.below_sum(U32.to_nat(SPO1(t, x)), {K1})))
  +hc = V.and_true(U32.is_le({FS}, SPO1(t, x)), U32.is_le(SPO1(t, x), len), hc1, hc2)
  +el1 = subc(SPO1(t, x), {FS}, {K0}, e1)
  +el2 = subc(len, SPO1(t, x), {K1}, e2)
  +ew = Equal.trans(+List<U32>, UW.WX(t, Nat.add({FS}n, x), K), VS.bdr({FS}n, UW.WX(t, x, Nat.add({FS}n, K))), List.append(&2, U32, ys0, ys1),
    Equal.sym(+List<U32>, VS.bdr({FS}n, UW.WX(t, x, Nat.add({FS}n, K))), UW.WX(t, Nat.add({FS}n, x), K), UW.tailWX(t, x, {FS}n, K)),
    FD.logic__subst(Nat, z => {{VS.bdr({FS}n, UW.WX(t, x, z)) == List.append(&2, U32, ys0, ys1) : +List<U32>}}, U32.to_nat(len), Nat.add({FS}n, K), en, f3))
  +ey0 = Equal.trans(+List<U32>, ys0, UW.WX(t, Nat.add({FS}n, x), {K0}), UW.WX(t, {X1}, {L1n}), VX2.wx_fst(t, Nat.add({FS}n, x), ys0, ys1, ew),
    Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add({FS}n, x), z), {K0}, {L1n}, Equal.sym(Nat, {L1n}, {K0}, el1)))
  +pos = Equal.trans(Nat, Nat.add({K0}, Nat.add({FS}n, x)), Nat.add(Nat.add({FS}n, {K0}), x), X2(t, x),
    Equal.trans(Nat, Nat.add({K0}, Nat.add({FS}n, x)), Nat.add(Nat.add({K0}, {FS}n), x), Nat.add(Nat.add({FS}n, {K0}), x),
      Equal.sym(Nat, Nat.add(Nat.add({K0}, {FS}n), x), Nat.add({K0}, Nat.add({FS}n, x)), FD.nat__add_assoc({K0}, {FS}n, x)),
      Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add({K0}, {FS}n), Nat.add({FS}n, {K0}), FD.nat__add_comm({K0}, {FS}n))),
    Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add({FS}n, {K0}), U32.to_nat(SPO1(t, x)), Equal.sym(Nat, U32.to_nat(SPO1(t, x)), Nat.add({FS}n, {K0}), e1)))
  +ey1 = Equal.trans(+List<U32>, ys1, UW.WX(t, Nat.add({K0}, Nat.add({FS}n, x)), {K1}), UW.WX(t, X2(t, x), {L2n}), VX2.wx_snd(t, Nat.add({FS}n, x), ys0, ys1, ew),
    Equal.trans(+List<U32>, UW.WX(t, Nat.add({K0}, Nat.add({FS}n, x)), {K1}), UW.WX(t, X2(t, x), {K1}), UW.WX(t, X2(t, x), {L2n}),
      Equal.cong(Nat, +List<U32>, z => UW.WX(t, z, {K1}), Nat.add({K0}, Nat.add({FS}n, x)), X2(t, x), pos),
      Equal.cong(Nat, +List<U32>, z => UW.WX(t, X2(t, x), z), {K1}, {L2n}, Equal.sym(Nat, {L2n}, {K1}, el2))))
  +d1 = YW.invw(d, t, n, {X1}, U32.add(off, {FS}), L1(t, x), eo1(d, x, off, len, eo, hd, hw, ha), hd, hw1(d, t, x, len, hw, hc), pf, hv0,
    FD.logic__subst(+List<U32>, z => {{Codec.parts(hv0, Spec.{Y}()) == Some{{[S.Variable{{z}}]}} : {MP}}}, ys0, UW.WX(t, {X1}, {L1n}), ey0, em0))
  +d2 = YW.invw(d, t, n, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len), eo2(d, t, x, off, len, eo, hd, hw, hc), hd, hw2(d, t, x, len, hw, hc), pf, hv1,
    FD.logic__subst(+List<U32>, z => {{Codec.parts(hv1, Spec.{Y}()) == Some{{[S.Variable{{z}}]}} : {MP}}}, ys1, UW.WX(t, X2(t, x), {L2n}), ey1, em1))
  %Equal.sym(Bool, U32.is_le({FS}, len), True{{}}, ha) : {{chk5(_, U32.is_eq(SPO0(t, x), {FS}), CK(t, x, len), D1(t, x, off), D2(t, x, off, len)) == True{{}} : Bool}}
  %Equal.sym(U32, SPO0(t, x), {FS}, epo) : {{chk5(True{{}}, U32.is_eq(_, {FS}), CK(t, x, len), D1(t, x, off), D2(t, x, off, len)) == True{{}} : Bool}}
  %Equal.sym(Bool, CK(t, x, len), True{{}}, hc) : {{chk5(True{{}}, U32.is_eq({FS}, {FS}), _, D1(t, x, off), D2(t, x, off, len)) == True{{}} : Bool}}
  %Equal.sym(Bool, D1(t, x, off), True{{}}, d1) : {{chk5(True{{}}, U32.is_eq({FS}, {FS}), True{{}}, _, D2(t, x, off, len)) == True{{}} : Bool}}
  d2

def inv_e({ARGS}, +hb0: {{VS.bt(4n, VS.bdr(0n, {WXn})) == {FSL} : +List<U32>}},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: {F1}, +f2: {F2_}, +f3: {F3}, r: DK.P2({E0}, {E1}))
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  (+em0, em1) = r
  inv_tail({A_}, hb0, hv0, ys0, hv1, ys1, f1, f2, f3, em0, em1)

def inv_d({ARGS}, +hb0: {{VS.bt(4n, VS.bdr(0n, {WXn})) == {FSL} : +List<U32>}},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: {F1}, +f2: {F2_}, r: DK.P2({F3}, DK.P2({E0}, {E1})))
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  (+f3, r2) = r
  inv_e({A_}, hb0, hv0, ys0, hv1, ys1, f1, f2, f3, r2)

def inv_c({ARGS}, +hb0: {{VS.bt(4n, VS.bdr(0n, {WXn})) == {FSL} : +List<U32>}},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: {F1}, r: DK.P2({F2_}, DK.P2({F3}, DK.P2({E0}, {E1}))))
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  (+f2, r2) = r
  inv_d({A_}, hb0, hv0, ys0, hv1, ys1, f1, f2, r2)

def inv_b({ARGS}, +hb0: {{VS.bt(4n, VS.bdr(0n, {WXn})) == {FSL} : +List<U32>}},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, r: DK.P2({F1}, DK.P2({F2_}, DK.P2({F3}, DK.P2({E0}, {E1})))))
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  (+f1, r2) = r
  inv_c({A_}, hb0, hv0, ys0, hv1, ys1, f1, r2)

def inv_facts({ARGS}, facts: XI.FACTS2({WXn})) -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  (+hb0, ex) = facts
  (+hv0, r1) = ex
  (+ys0, r2) = r1
  (+hv1, r3) = r2
  (+ys1, r4) = r3
  inv_b({A_}, hb0, hv0, ys0, hv1, ys1, r4)

# Every value whose spec parts are the window's bytes passes the checks.
def invw({ARGS}, +v: S.Value, +e: {{Codec.parts(v, Spec.{n}()) == Some{{[S.Variable{{{WXn}}}]}} : {MP}}})
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  inv_facts({A_}, XI.inv_p(v, {WXn}, e))
'''
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
         '# GENERATED by codegen/var_bytes_x.py (codegen/var_bytes_x2.py). Do not edit.',
         f'# {n} on a whole buffer: the decoder laws, the window laws of {fname(x).name}',
         '# at x = 0, off = 0, len = n (buffers on perfect trees of depth d < 28).', '']
    Q = ['  for +d: Nat', '  for +t: FD.array__Tree<U32>', '  for +n: U32',
         '  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}',
         '  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}',
         '  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}']
    q = '\n'.join(Q)
    return '\n'.join(H) + f'''
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: UA.BF(t, n)
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: W.CHKw(t, 0n, 0, n)
def OBJ(+d: Nat, +t: FD.array__Tree<U32>, +n: U32) -> {Tn}: W.OBJw(d, t, 0n, 0, n)
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: W.VALw(t, 0n, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))

# The validator returns the buffer and CHK(t, n).
law ok_eval:
{q}
  {{{Tn}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}}
def ok_eval(d, t, n, pf, hd, hn):
  W.ok_evalw(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf)

# Every buffer the validator accepts decodes to OBJ(d, t, n).
law decode_accept:
{q}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  {{{Tn}_decode(BF(t, n), n) == (BF(t, n), Some{{OBJ(d, t, n)}}) : {D}}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, {Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {{{Tn}_built(n, _) == (BF(t, n), Some{{OBJ(d, t, n)}}) : {D}}}
  %Equal.sym(Bool, CHK(t, n), True{{}}, hchk) :
    {{{Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{{OBJ(d, t, n)}}) : {D}}}
  %Equal.sym(B.Buf & {Tn}, {Tn}_read(BF(t, n), 0, n), (BF(t, n), OBJ(d, t, n)), W.readw(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf, hchk)) :
    {{{Tn}_some(_) == (BF(t, n), Some{{OBJ(d, t, n)}}) : {D}}}
  {{==}}

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
def VALe(+t: FD.array__Tree<U32>, +n: U32) -> {{W.VALw(t, 0n, n) == VAL(t, n) : S.Value}}: {{==}}
def VWe(+t: FD.array__Tree<U32>, +n: U32) -> {{UW.WX(t, 0n, U32.to_nat(n)) == VW(t, n) : +List<U32>}}: {{==}}

law decode_spec:
{q}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  Decoding.decodes(Spec.{n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  # the value and bytes in specw's own terms first (VALe, VWe), then F.encoding_of_var over
  # them: comparing the spec encoding of VAL with that of W.VALw ran the spec encoder (3 s)
  %VALe(t, n) : Decoding.decodes(Spec.{n}(), VW(t, n), _)
  %VWe(t, n) : Decoding.decodes(Spec.{n}(), _, W.VALw(t, 0n, n))
  F.encoding_of_var(Spec.{n}(), W.VALw(t, 0n, n), UW.WX(t, 0n, U32.to_nat(n)), W.specw(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf, hchk))

# Every spec value of an accepted buffer's bytes is the decoded object's value.
law decode_unique:
{q}
  for +hchk: {{CHK(t, n) == True{{}} : Bool}}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.{n}(), VW(t, n), v)
  {{v == VAL(t, n) : S.Value}}
def decode_unique(d, t, n, pf, hd, hn, hchk, v, spec):
  # the validator's acceptance of the schema by evaluation (decode_unique.valid_unique): image_unique's
  # legality form imports the compatibility_* chain and every name's legality witness
  DCO.valid_unique(Spec.{n}(), VW(t, n), v, VAL(t, n), {{==}}, spec, decode_spec(d, t, n, pf, hd, hn, hchk))

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
{q}
  for +hchk: {{CHK(t, n) == False{{}} : Bool}}
  Decoding.outside_image(Spec.{n}(), VW(t, n))
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => FD.logic__true_false(Equal.trans(Bool, True{{}}, CHK(t, n), False{{}},
    Equal.sym(Bool, CHK(t, n), True{{}}, W.inv_facts(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf, XI.inv_v(v, VW(t, n), e))), hchk))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
{q}
  for +hchk: {{CHK(t, n) == False{{}} : Bool}}
  {{{Tn}_decode(BF(t, n), n) == (BF(t, n), None{{}}) : {D}}}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, {Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {{{Tn}_built(n, _) == (BF(t, n), None{{}}) : {D}}}
  %Equal.sym(Bool, CHK(t, n), False{{}}, hchk) :
    {{{Tn}_built(n, (BF(t, n), _)) == (BF(t, n), None{{}}) : {D}}}
  {{==}}
'''
