#!/usr/bin/env python3
"""Codec laws of containers that nest a name of codegen/var_bytes.py.

Covered family: plain containers (at most 8 fields) of word-aligned fixed
fields (as var_bytes.py, plus boxed Data records) around ONE variable field
that is itself a covered name Y (ExecutionPayloadHeader, or a name of this
family), possibly boxed. Fulu names: LightClientHeader (Y =
ExecutionPayloadHeader), LightClientOptimisticUpdate (Y = LightClientHeader).

The laws are those of var_bytes.py (the _win, top, _unique and _rej modules),
built on Y's window laws at the window (off + FS, len - FS): Y's validator,
reader and spec parts at word H + i (proofs/obj/var_bytes_<Y>_win.bend), and
Y's windowed rejection facts (var_bytes_<Y>_rej.bend inv_p, rej_facts).
"""
import re

import generate as G
import spec_laws as SL
import var_laws as VL
import var_bytes as VBY
import var_bytes_boot as VBB

ROOT = VBY.ROOT
# parent -> child (the variable field's type)
NEST = {'LightClientHeader': 'ExecutionPayloadHeader', 'LightClientOptimisticUpdate': 'LightClientHeader',
        'LightClientBootstrap': 'LightClientHeader'}
ORDER = ['LightClientHeader', 'LightClientOptimisticUpdate', 'LightClientBootstrap']
NO_ENC = {'LightClientBootstrap'}  # its encoder laws: codegen/var_bytes_benc.py (big)


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
                    # parts come from codegen/var_bytes_boot.py
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
        LEHD = (f'def leH(+len: U32, +ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}) -> {{Nat.is_le(A.quad({H}n), U32.to_nat(len)) == True{{}} : Bool}}:\n'
                f'  VBZ.le_fs({FS}, A.quad({H}n), FD.nat__eq_from_is_eq(U32.to_nat({FS}), A.quad({H}n), {{==}}), len, ha)\n\n'
                f'def enH(+len: U32, +ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}) -> {{Nat.add(A.quad({H}n), U32.to_nat(LL(len))) == U32.to_nat(len) : Nat}}:\n'
                f'  VBZ.en_fs({FS}, A.quad({H}n), FD.nat__eq_from_is_eq(U32.to_nat({FS}), A.quad({H}n), {{==}}), len, LL(len), {{==}}, ha)\n\n')
    else:
        LEHC, LEHD = 'leFS(len, ha)', ''
        LEB = f'''  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le({FS}, len), Nat.is_le({FSN}, U32.to_nat(len)), VU.le_u32({FS}, len), ha)'''
        ENB = f'''  %Equal.sym(Nat, U32.to_nat(LL(len)), Nat.sub(U32.to_nat(len), {FSN}), FD.u32__sub_nat(len, {FS}, leFS(len, ha))) : {{Nat.add({FSN}, _) == U32.to_nat(len) : Nat}}
  FD.nat__sub_add(U32.to_nat(len), {FSN}, leFS(len, ha))'''
        HWB = f'''  +e1 = Equal.cong(Nat, Nat, z => Nat.add(A.quad(i), z), U32.to_nat(len), Nat.add({FSN}, U32.to_nat(LL(len))), Equal.sym(Nat, Nat.add({FSN}, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)))
  +e2 = Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), {FSN}), U32.to_nat(LL(len))), Nat.add(A.quad(i), Nat.add({FSN}, U32.to_nat(LL(len)))), FD.nat__add_assoc(A.quad(i), {FSN}, U32.to_nat(LL(len))))
  +e3 = Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(LL(len))), Nat.add(A.quad(i), {FSN}), Nat.add({FSN}, A.quad(i)), FD.nat__add_comm(A.quad(i), {FSN}))
  +e = Equal.trans(Nat, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(i), Nat.add({FSN}, U32.to_nat(LL(len)))), Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), e1,
    Equal.trans(Nat, Nat.add(A.quad(i), Nat.add({FSN}, U32.to_nat(LL(len)))), Nat.add(Nat.add(A.quad(i), {FSN}), U32.to_nat(LL(len))), Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), e2, e3))
  FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), e, hw)'''
    Tn = f'T.{n}'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    comp = any(f['kind'] == 'comp' for f in x.fields)
    L = list(HEAD) + (HEAD_COMP if comp else []) + (HEAD_BIG if x.big and not comp else []) + [f'import ./{wmod(Y)} as YW', '', '# GENERATED by codegen/var_bytes_nest.py. Do not edit.',
                      f'# {n} at a word-aligned window (off = 4 i, len) of a buffer: the validator,',
                      f'# the reader and the spec parts of the value, on {Y}\'s window laws at word {H} + i',
                      '# (see the module docstring of codegen/var_bytes_nest.py).', '']
    w = L.append
    yok = f'T.{Y}_bx_ok' if x.var['box'] else f'T.{Y}_ok'
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

def LL(+len: U32) -> U32: U32.sub(len, {FS})
def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add({po}n, i))

# The checks: the size, the offset, and {Y}'s checks on the window after the header.
def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> Bool:
  chk3(U32.is_le({FS}, len), U32.is_eq(SPOw(t, i), {FS}), YW.CHKw(t, Nat.add({H}n, i), LL(len)))

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {{{Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}}:
  match ok:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def leFS(+len: U32, {HA}) -> {{Nat.is_le({FSN}, U32.to_nat(len)) == True{{}} : Bool}}:
{LEB}

def enFS(+len: U32, {HA}) -> {{Nat.add({FSN}, U32.to_nat(LL(len))) == U32.to_nat(len) : Nat}}:
{ENB}

{LEHD}def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {{Nat.is_le(A.quad(k), U32.to_nat(len)) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{{}} : Bool}}) -> {{Nat.is_le(A.quad(Nat.add(k, i)), P) == True{{}} : Bool}}:
  %VF.quad_add(k, i) : {{Nat.is_le(_, P) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, P) == True{{}} : Bool}}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

# The byte offset off + c of header byte c = 4 k (k <= H) is word k + i.
def eoc(+d: Nat, +i: Nat, +off: U32, +len: U32, +k: Nat, +c: U32, +ec: {{U32.to_nat(c) == A.quad(k) : Nat}},
    +hkF: {{Nat.is_le(A.quad(k), {FSN}) == True{{}} : Bool}}, {WH}, {HA})
    -> {{U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}}:
  VF.off_add(off, c, i, k, 2n+d, eo, ec, hd,
    winb(k, i, len, A.quad(VB.pw(d)), FD.nat__le_trans(A.quad(k), {FSN}, U32.to_nat(len), hkF, leFS(len, ha)), hw))

# Header words k < H of the window are below 2^d.
def hiw(+d: Nat, +i: Nat, +len: U32, +k: Nat, +hk: {{Nat.is_lt(k, {H}n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{{}} : Bool}}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add({H}n, i), VB.pw(d), VB.lt_kk(k, {H}n, i, hk),
    VC.quad_inv(Nat.add({H}n, i), VB.pw(d), winb({H}n, i, len, A.quad(VB.pw(d)), {LEHC}, hw)))

# The child's window (4 (H + i), len - {FS}) lies in the buffer.
def hwY(+d: Nat, +i: Nat, +len: U32, +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{Nat.is_le(Nat.add(A.quad(Nat.add({H}n, i)), U32.to_nat(LL(len))), A.quad(VB.pw(d))) == True{{}} : Bool}}:
{HWB}

def ecY(+d: Nat, +i: Nat, +off: U32, +len: U32, {WH}, {HA}) -> {{U32.to_nat(U32.add(off, {FS})) == A.quad(Nat.add({H}n, i)) : Nat}}:
  eoc(d, i, off, len, {H}n, {FS}, {ecq(H, FS)}, {{==}}, eo, hd, hw, ha)

def okw_c1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}})
    -> {{{Tn}_c0(True{{}}, VF.BF(t, n), off, len, SPOw(t, i)) == (VF.BF(t, n), YW.CHKw(t, Nat.add({H}n, i), LL(len))) : B.Buf & Bool}}:
  %Equal.sym(U32, SPOw(t, i), {FS}, epo) :
    {{{Tn}_v1(off, len, _, {yok}(VF.BF(t, n), U32.add(off, _), U32.sub(len, _))) == (VF.BF(t, n), YW.CHKw(t, Nat.add({H}n, i), LL(len))) : B.Buf & Bool}}
  %Equal.sym(B.Buf & Bool, T.{Y}_ok(VF.BF(t, n), U32.add(off, {FS}), LL(len)), (VF.BF(t, n), YW.CHKw(t, Nat.add({H}n, i), LL(len))),
      YW.ok_evalw(d, t, n, Nat.add({H}n, i), U32.add(off, {FS}), LL(len), ecY(d, i, off, len, eo, hd, hw, ha), hd, hwY(d, i, len, hw, ha), pf)) :
    {{{Tn}_v1(off, len, {FS}, _) == (VF.BF(t, n), YW.CHKw(t, Nat.add({H}n, i), LL(len))) : B.Buf & Bool}}
  c1_id(YW.CHKw(t, Nat.add({H}n, i), LL(len)), VF.BF(t, n), off, len, {FS})

def okw_c0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF}, {HA},
    +b: Bool, +eb: {{U32.is_eq(SPOw(t, i), {FS}) == b : Bool}})
    -> {{{Tn}_c0(b, VF.BF(t, n), off, len, SPOw(t, i)) == (VF.BF(t, n), chk3(True{{}}, b, YW.CHKw(t, Nat.add({H}n, i), LL(len)))) : B.Buf & Bool}}:
  match b:
    case False{{}}: {{==}}
    case True{{}}: okw_c1(d, t, n, i, off, len, eo, hd, hw, pf, ha, FD.u32alg__eq_of(SPOw(t, i), {FS}, eb))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF},
    +a: Bool, +ea: {{U32.is_le({FS}, len) == a : Bool}})
    -> {{{Tn}_ok_len(a, VF.BF(t, n), off, len) == (VF.BF(t, n), chk3(a, U32.is_eq(SPOw(t, i), {FS}), YW.CHKw(t, Nat.add({H}n, i), LL(len)))) : B.Buf & Bool}}:
  match a:
    case False{{}}: {{==}}
    case True{{}}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, {cvar})), (VF.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, {cvar}), Nat.add({po}n, i), eoc(d, i, off, len, {po}n, {cvar}, {{==}}, {{==}}, eo, hd, hw, ea),
            VB.lt32(d, FD.nat__lt_trans(d, 29n, 31n, hd, {{==}})), hiw(d, i, len, {po}n, {{==}}, hw, ea), pf)) :
        {{{Tn}_v0(off, len, _) == (VF.BF(t, n), chk3(True{{}}, U32.is_eq(SPOw(t, i), {FS}), YW.CHKw(t, Nat.add({H}n, i), LL(len)))) : B.Buf & Bool}}
      okw_c0(d, t, n, i, off, len, eo, hd, hw, pf, ea, U32.is_eq(SPOw(t, i), {FS}), {{==}})

# The validator on the window returns the buffer and CHKw(t, i, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF})
    -> {{{Tn}_ok(VF.BF(t, n), off, len) == (VF.BF(t, n), CHKw(t, i, len)) : B.Buf & Bool}}:
  okw_len(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_le({FS}, len), {{==}})

def hHi(+d: Nat, +i: Nat, +len: U32, +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{Nat.is_le(Nat.add({H}n, i), VB.pw(d)) == True{{}} : Bool}}:
  VC.quad_inv(Nat.add({H}n, i), VB.pw(d), winb({H}n, i, len, A.quad(VB.pw(d)), {LEHC}, hw))

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
    w(f'def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> {Tn}: {OBJ}')
    w('')
    w('# The reader on the window, when the checks hold.')
    w(f'def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF},')
    w(f'    {HA}, +epo: {{SPOw(t, i) == {FS} : U32}}, +hY: {{YW.CHKw(t, Nat.add({H}n, i), LL(len)) == True{{}} : Bool}})')
    w(f'    -> {{{Tn}_read(VF.BF(t, n), off, len) == {RHS} : {TY}}}:')
    w('  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})')
    w('  +hH = hHi(d, i, len, hw, ha)')

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
            w(f'  %Equal.sym(B.Buf & O.Words, {call}, (VF.BF(t, n), {val}),')
            w(f'      VY.copy_into_any(d, t, n, U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {f["size"]}, {f["dz"]}n, {kw}n, pf, hd31, {{==}},')
            w(f'        VF.al_3(U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {e}), VF.al_q(U32.add(off, {f["c"]}), Nat.add({f["k"]}n, i), {e}),')
            w(f'        {hb(f["W"], f["k"])}, {{==}}, {{==}}, {{==}})) :')
        else:
            w(f'  %Equal.sym(B.Buf & T.{Y}, {call}, (VF.BF(t, n), {val}),')
            w(f'      YW.readw(d, t, n, Nat.add({H}n, i), U32.add(off, {FS}), LL(len), ecY(d, i, off, len, eo, hd, hw, ha), hd, hwY(d, i, len, hw, ha), pf, hY)) :')
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(f'''
# When the window's checks hold, the reader returns OBJw(t, i, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, {WH}, {PF},
    +hchk: {{CHKw(t, i, len) == True{{}} : Bool}})
    -> {{{Tn}_read(VF.BF(t, n), off, len) == (VF.BF(t, n), OBJw(t, i, len)) : {TY}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, i), {FS})
  +c = YW.CHKw(t, Nat.add({H}n, i), LL(len))
  +epo = FD.u32alg__eq_of(SPOw(t, i), {FS}, chk_b(a, b, c, hchk))
  rdw_go(d, t, n, i, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))
''')
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
        import var_bytes as VBY
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
    return [f'''
# ---- the spec side -------------------------------------------------------------------------

# The value of the window's fixed words and the child's value V.
def XVw(+t: FD.array__Tree<U32>, +i: Nat, +V: S.Value) -> S.Value: S.Sequence{{{ITEMS}}}

# Its spec parts: one variable part, the header's bytes (the offset is {FS}) and the child's bytes Yb.
def encpw(+t: FD.array__Tree<U32>, +i: Nat, +V: S.Value, +Yb: +List<U32>,
    +hv: {{Codec.parts(V, Spec.{Y}()) == Some{{[S.Variable{{Yb}}]}} : {MP}}}, +hdom: {{SP.bytes_domain(Yb) == True{{}} : Bool}},
    +fit: {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, Yb))) == True{{}} : Bool}})
    -> {{Codec.parts(XVw(t, i, V), Spec.{n}()) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}:
  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PL}}},
      {CAT}) :
    {{Codec.aggregate(_, None{{}}) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, Yb, {POST})), Some{{{ENCR}}}, VZ.enc_fpvb({PRE}, Yb, {POST}, hdom, fit)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  {{==}}

def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: XVw(t, i, {VY_})

# The header's bytes and the child's window's bytes are the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}})
    -> {{List.append(&2, U32, F.limbs({HDR}), {YT}) == {WIN} : +List<U32>}}:
  +hsl = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({H}n, i), z) == True{{}} : Bool}}, VB.pw(d), VB.len({s}), Equal.sym(Nat, VB.len({s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hHi(d, i, len, hw, ha))
  %enFS(len, ha) : {{List.append(&2, U32, F.limbs({HDR}), {YT}) == VS.bt(_, F.limbs(VB.wdr(i, {s}))) : +List<U32>}}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad({H}n), U32.to_nat(LL(len))), F.limbs(VB.wdr(i, {s}))),
      List.append(&2, U32, F.limbs(VS.wtake({H}n, VB.wdr(i, {s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr({H}n, VB.wdr(i, {s}))))),
      VY.bt_split({H}n, U32.to_nat(LL(len)), VB.wdr(i, {s}), VZ.wdr_len_le({H}n, i, {s}, hsl))) :
    {{List.append(&2, U32, F.limbs({HDR}), {YT}) == _ : +List<U32>}}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add({H}n, 0n), VB.wdr(i, {s})), VF.app(VF.wpre({H}n, i, {s}), VS.wtake(0n, VB.wdr(Nat.add({H}n, i), {s}))),
      VF.wt_pre({H}n, 0n, i, {s}, hsl)) :
    {{List.append(&2, U32, F.limbs({HDR}), {YT}) == List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr({H}n, VB.wdr(i, {s}))))) : +List<U32>}}
  %Equal.sym(List<&2, U32>, VB.wdr({H}n, VB.wdr(i, {s})), VB.wdr(Nat.add(i, {H}n), {s}), VF.wdr_add({H}n, i, {s})) :
    {{List.append(&2, U32, F.limbs({HDR}), {YT}) == List.append(&2, U32, F.limbs({hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(_))) : +List<U32>}}
  %Equal.sym(Nat, Nat.add(i, {H}n), Nat.add({H}n, i), FD.nat__add_comm(i, {H}n)) :
    {{List.append(&2, U32, F.limbs({HDR}), {YT}) == List.append(&2, U32, F.limbs({hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(_, {s})))) : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({hdrh}), {YT}) == List.append(&2, U32, F.limbs({hdrs}), {YT}) : +List<U32>}}
  {{==}}

def fitw(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +len: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {YT}))) == True{{}} : Bool}}:
  +hl = FD.nat__le_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw)
  +h1 = FD.nat__le_trans(Nat.add({FSN}, List.length(&2, U32, {YT})), Nat.add({FSN}, U32.to_nat(LL(len))), A.quad(VB.pw(d)),
    Order.add_left({FSN}, List.length(&2, U32, {YT}), U32.to_nat(LL(len)), VZ.bt_len_le(U32.to_nat(LL(len)), F.limbs(VB.wdr(Nat.add({H}n, i), {s})))),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({FSN}, U32.to_nat(LL(len))), Equal.sym(Nat, Nat.add({FSN}, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)), hl))
  VFT.fits4(2n+d, Nat.add({FSN}, List.length(&2, U32, {YT})), h1, FD.nat__lt_trans(d, 29n, 30n, hd, {{==}}))

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}},
    +hY: {{YW.CHKw(t, Nat.add({H}n, i), LL(len)) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{{WIN}}}]}} : {MP}}}:
  %bytesw(d, t, n, i, len, pf, hd, hw, ha, epo) :
    {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  encpw(t, i, {VY_}, {YT}, YW.specw(d, t, n, Nat.add({H}n, i), LL(len), pf, hd, hwY(d, i, len, hw, ha), hY),
    VZ.bd_btl(U32.to_nat(LL(len)), VB.wdr(Nat.add({H}n, i), {s})), fitw(d, t, i, len, hd, hw, ha))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hchk: {{CHKw(t, i, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{{WIN}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, i), {FS})
  +c = YW.CHKw(t, Nat.add({H}n, i), LL(len))
  +epo = FD.u32alg__eq_of(SPOw(t, i), {FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, i, len, pf, hd, hw, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))
''']


# ---- the rejection laws ----------------------------------------------------------------------

def rej_text(x, pure=False):
    """pure: only the lines up to inv_v (no window or whole-buffer facts), for codegen/var_bytes_x.py."""
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
         '# GENERATED by codegen/var_bytes_nest.py. Do not edit.',
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
        w('def mis(m: Maybe<&2, Nat>, +n: Nat) -> Bool:')
        w('  match m:')
        w('    case Some{v}: Nat.is_eq(v, n)')
        w('    case None{}: False{}')
        w('')
        w('def fs_of(+m: Maybe<&2, Nat>, +n: Nat, +h: {mis(m, n) == True{} : Bool}) -> {m == Some{n} : Maybe<&2, Nat>}:')
        w('  match m:')
        w('    case Some{+v}: Equal.cong(Nat, Maybe<&2, Nat>, z => Some{z}, v, n, F.nat__eq_from_is_eq(v, n, h))')
        w('    case None{}: Empty.absurd({None{} == Some{n} : Maybe<&2, Nat>}, F.logic__false_true(h))')
        w('')
        w('def sfix(+sch: S.Schema, +n: Nat, +h: S.Value, +hn: {mis(SS.fixed_size(sch), n) == True{} : Bool},')
        w('    hf: DF.single_result(SS.fixed_size(sch), Codec.parts(h, sch))) -> DF.single_result(Some{n}, Codec.parts(h, sch)):')
        w('  F.logic__subst(Maybe<&2, Nat>, z => DF.single_result(z, Codec.parts(h, sch)), SS.fixed_size(sch), Some{n}, fs_of(SS.fixed_size(sch), n, hn), hf)')
        w('')
    w('def FACTS(bs: +List<U32>) -> Type:')
    w(f'  {{VS.bt(4n, VS.bdr({P}n, bs)) == {FSL} : +List<U32>}} & DK.Ex(S.Value, hv0 => DK.Ex(+List<U32>, ys => '
      f'DK.P2({{List.length(&2, U32, bs) == Nat.add({FSN}, List.length(&2, U32, ys)) : Nat}}, '
      f'DK.P2({{VS.bdr({FSN}, bs) == ys : +List<U32>}}, {{Codec.parts(hv0, Spec.{Y}()) == Some{{[S.Variable{{ys}}]}} : {MP}}}))))')
    w('')

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
    w(f'  %eP({ALL}) : {{VS.bt(4n, VS.bdr(_, {OUT})) == N.digits(4n, Nat.add(_, 4n+{Qz}n)) : +List<U32>}}')
    w(f'  %eQ({ALL}) : {{VS.bt(4n, VS.bdr(VR.lens({PRE}), {OUT})) == N.digits(4n, Nat.add(VR.lens({PRE}), 4n+_)) : +List<U32>}}')
    w(f'  VR.out_off({PRE}, ys, {POST})')
    w('')
    if x.big:
        # the header size through one closed equality (no big sum compared against a stuck term)
        LP, LQ = f'VR.lens({PRE})', f'VR.lens({POST})'
        OFS = f'Nat.add({LP}, 4n+{LQ})'
        w('def eF(' + ', '.join(decl_m) + f') -> {{{OFS} == {FSN} : Nat}}:')
        w(f'  Equal.trans(Nat, {OFS}, Nat.add({Pz}n, 4n+{Qz}n), {FSN},')
        w(f'    Equal.trans(Nat, {OFS}, Nat.add({Pz}n, 4n+{LQ}), Nat.add({Pz}n, 4n+{Qz}n),')
        w(f'      Equal.cong(Nat, Nat, z => Nat.add(z, 4n+{LQ}), {LP}, {Pz}n, eP({ALL})), Equal.cong(Nat, Nat, z => Nat.add({Pz}n, 4n+z), {LQ}, {Qz}n, eQ({ALL}))),')
        w(f'    F.nat__eq_from_is_eq(Nat.add({Pz}n, 4n+{Qz}n), {FSN}, {{==}}))')
        w('')
        # stated for a symbolic size fs (proof terms holding Nat.add(<big literal>, <stuck>) overflow the post-check)
        FSD = ', '.join(decl_m + ['+fs: Nat', f'+ef: {{{OFS} == fs : Nat}}'])
        w(f'def f_len_g({FSD}) -> {{List.length(&2, U32, {OUT}) == Nat.add(fs, VBZ.LN(ys)) : Nat}}:')
        w(f'  Equal.trans(Nat, List.length(&2, U32, {OUT}), Nat.add({OFS}, List.length(&2, U32, ys)), Nat.add(fs, VBZ.LN(ys)), VR.out_len({PRE}, ys, {POST}),')
        w(f'    Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, ys)), {OFS}, fs, ef))')
        w('')
        w('def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FSN}, List.length(&2, U32, ys)) : Nat}}:')
        w(f'  f_len_g({ALL}, {FSN}, eF({ALL}))')
        w('')
        w(f'def f_dr_g({FSD}) -> {{VS.bdr(fs, {OUT}) == ys : +List<U32>}}:')
        w(f'  Equal.trans(+List<U32>, VS.bdr(fs, {OUT}), VS.bdr({OFS}, {OUT}), ys,')
        w(f'    Equal.cong(Nat, +List<U32>, z => VS.bdr(z, {OUT}), fs, {OFS}, Equal.sym(Nat, {OFS}, fs, ef)), VZ.out_dr({PRE}, ys, {POST}))')
        w('')
        w('def f_dr(' + ', '.join(decl_m) + f') -> {{VS.bdr({FSN}, {OUT}) == ys : +List<U32>}}:')
        w(f'  f_dr_g({ALL}, {FSN}, eF({ALL}))')
        w('')
    else:
        w('def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FSN}, List.length(&2, U32, ys)) : Nat}}:')
        w(f'  %eP({ALL}) : {{List.length(&2, U32, {OUT}) == Nat.add(Nat.add(_, 4n+{Qz}n), List.length(&2, U32, ys)) : Nat}}')
        w(f'  %eQ({ALL}) : {{List.length(&2, U32, {OUT}) == Nat.add(Nat.add(VR.lens({PRE}), 4n+_), List.length(&2, U32, ys)) : Nat}}')
        w(f'  VR.out_len({PRE}, ys, {POST})')
        w('')
        w('def f_dr(' + ', '.join(decl_m) + f') -> {{VS.bdr({FSN}, {OUT}) == ys : +List<U32>}}:')
        w(f'  %eP({ALL}) : {{VS.bdr(Nat.add(_, 4n+{Qz}n), {OUT}) == ys : +List<U32>}}')
        w(f'  %eQ({ALL}) : {{VS.bdr(Nat.add(VR.lens({PRE}), 4n+_), {OUT}) == ys : +List<U32>}}')
        w(f'  VZ.out_dr({PRE}, ys, {POST})')
        w('')
    PLIST = '[' + ', '.join(parts_m) + ']'
    w(sig('inv_fin', decl_m, ['+bs: +List<U32>', '+b5: Bool',
          f'+e: {{Codec.bytes(Codec.one(SP.optional(b5, {OUT}), None{{}})) == Some{{bs}} : {MB}}}']))
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w('    case True{}:')
    w(f'      %F.logic__some_inj(+List<U32>, {OUT}, bs, e) : FACTS(_)')
    w(f'      (f_off({ALL}), (hv0, (ys, (f_len({ALL}), (f_dr({ALL}), em)))))')
    w('')
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
            w('    case Nil{}: Empty.absurd(FACTS(bs), hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: st{i + 1}({A_}xs, Equal.sym(Nat, {z}n, List.length(&2, U32, xs), F.logic__some_inj(Nat, {z}n, List.length(&2, U32, xs), hf)), t, bs, e)')
            w(f'    case Con{{S.Variable{{+xs}}, Nil{{}}}}: Empty.absurd(FACTS(bs), F.logic__none_some(Nat, {z}n, Equal.sym(Maybe<&2, Nat>, Some{{{z}n}}, None{{}}, hf)))')
            w('    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)')
            w('    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)')
            w('')
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({A_}ps, hf, t, bs, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            fct = f'sfix({sch}, {z}n, h, {{==}}, DS.facts(h, {sch}, {{==}}))' if x.big else f'DS.facts(h, {sch}, {{==}})'
            w(f'  fm{i}({A_}Codec.parts(h, {sch}), {fct}, t, bs, e)')
            w('')
        else:
            w(sig(f'fp{i}', decl, ['+h: S.Value', '+ps: +List<S.Part>', 'hf: DF.single(None{}, ps)',
                                   f'+em0: {{Codec.parts(h, {sch}) == Some{{ps}} : {MP}}}', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            w('  match ps:')
            w('    case Nil{}: Empty.absurd(FACTS(bs), hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd(FACTS(bs), F.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
            w(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{i + 1}({A_}h, ys, em0, t, bs, e)')
            w('    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)')
            w('    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)')
            w('')
            w(sig(f'fm{i}', decl, ['+h: S.Value', '+mm: Maybe<&2, +List<S.Part>>', 'hf: DF.single_result(None{}, mm)',
                                   f'+em0: {{Codec.parts(h, {sch}) == mm : {MP}}}', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({A_}h, ps, hf, em0, t, bs, e)')
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
    w('  FACTS(bs)')
    w('def inv_v(v, bs, e):')
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


# The child's window after a big header (codegen/var_bytes_nest.py big names): stated for symbolic
# sizes h = 4 H and instantiated once (the literal would otherwise meet stuck lengths).
WVG = """def wv_g(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +h: Nat, +H: Nat, +eH: {A.quad(H) == h : Nat}, +l: U32, +en: {Nat.add(h, U32.to_nat(l)) == U32.to_nat(len) : Nat})
    -> {VS.bdr(h, WV(t, i, len)) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(h, U32.to_nat(l)), Equal.sym(Nat, Nat.add(h, U32.to_nat(l)), U32.to_nat(len), en)) :
    {VS.bdr(h, VS.bt(_, FX.limbs(VB.wdr(i, SL(t))))) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(h, VS.bt(Nat.add(h, U32.to_nat(l)), FX.limbs(VB.wdr(i, SL(t))))), VS.bt(U32.to_nat(l), VS.bdr(h, FX.limbs(VB.wdr(i, SL(t))))),
      VS.bdr_bt(h, U32.to_nat(l), FX.limbs(VB.wdr(i, SL(t))))) :
    {_ == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %eH : {VS.bt(U32.to_nat(l), VS.bdr(_, FX.limbs(VB.wdr(i, SL(t))))) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(H), FX.limbs(VB.wdr(i, SL(t)))), FX.limbs(VS.wdr0(H, VB.wdr(i, SL(t)))), VS.bdr_limbs(H, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(l), _) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(H, VB.wdr(i, SL(t))), VB.wdr(H, VB.wdr(i, SL(t))), wdr0_eq(H, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(l), FX.limbs(_)) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(H, VB.wdr(i, SL(t))), VB.wdr(Nat.add(i, H), SL(t)), VF.wdr_add(H, i, SL(t))) :
    {VS.bt(U32.to_nat(l), FX.limbs(_)) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, H), Nat.add(H, i), F.nat__add_comm(i, H)) :
    {VS.bt(U32.to_nat(l), FX.limbs(VB.wdr(_, SL(t)))) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  {==}

def wv_dr(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, X) : Nat})
    -> {VS.bdr(@FSn, WV(t, i, len)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}:
  wv_g(t, i, len, @FSn, @Hn, F.nat__eq_from_is_eq(A.quad(@Hn), @FSn, {==}), W.LL(len), W.enFS(len, haw(len, X, en)))

"""

NREJ = """
# The child's window: the bytes after the header.
def wv_dr(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, X) : Nat})
    -> {VS.bdr(@FSn, WV(t, i, len)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(@FSn, U32.to_nat(W.LL(len))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(W.LL(len))), U32.to_nat(len), W.enFS(len, haw(len, X, en)))) :
    {VS.bdr(@FSn, VS.bt(_, FX.limbs(VB.wdr(i, SL(t))))) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@FSn, VS.bt(Nat.add(@FSn, U32.to_nat(W.LL(len))), FX.limbs(VB.wdr(i, SL(t))))), VS.bt(U32.to_nat(W.LL(len)), VS.bdr(@FSn, FX.limbs(VB.wdr(i, SL(t))))),
      VS.bdr_bt(@FSn, U32.to_nat(W.LL(len)), FX.limbs(VB.wdr(i, SL(t))))) :
    {_ == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@FSn, FX.limbs(VB.wdr(i, SL(t)))), FX.limbs(VS.wdr0(@Hn, VB.wdr(i, SL(t)))), VS.bdr_limbs(@Hn, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(W.LL(len)), _) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(@Hn, VB.wdr(i, SL(t))), VB.wdr(@Hn, VB.wdr(i, SL(t))), wdr0_eq(@Hn, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(W.LL(len)), FX.limbs(_)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(@Hn, VB.wdr(i, SL(t))), VB.wdr(Nat.add(i, @Hn), SL(t)), VF.wdr_add(@Hn, i, SL(t))) :
    {VS.bt(U32.to_nat(W.LL(len)), FX.limbs(_)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, @Hn), Nat.add(@Hn, i), F.nat__add_comm(i, @Hn)) :
    {VS.bt(U32.to_nat(W.LL(len)), FX.limbs(VB.wdr(_, SL(t)))) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  {==}

# The window's checks hold when its offset is @FS and the child's window passes its checks.
def chk_truew(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, X) : Nat},
    +epo: {W.SPOw(t, i) == @FS : U32}, +hY: {YW.CHKw(t, Nat.add(@Hn, i), W.LL(len)) == True{} : Bool}) -> {W.CHKw(t, i, len) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(@FS, len), True{}, haw(len, X, en)) :
    {W.chk3(_, U32.is_eq(W.SPOw(t, i), @FS), YW.CHKw(t, Nat.add(@Hn, i), W.LL(len))) == True{} : Bool}
  %Equal.sym(U32, W.SPOw(t, i), @FS, epo) :
    {W.chk3(True{}, U32.is_eq(_, @FS), YW.CHKw(t, Nat.add(@Hn, i), W.LL(len))) == True{} : Bool}
  hY

def rej_tail(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))) == @FSL : +List<U32>}, +hv0: S.Value, +ys: +List<U32>,
    +hlen: {List.length(&2, U32, WV(t, i, len)) == Nat.add(@FSn, List.length(&2, U32, ys)) : Nat},
    +hdr: {VS.bdr(@FSn, WV(t, i, len)) == ys : +List<U32>},
    +hvp: {Codec.parts(hv0, Spec.@Y()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>})
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WV(t, i, len)), Nat.add(@FSn, List.length(&2, U32, ys)), Equal.sym(Nat, List.length(&2, U32, WV(t, i, len)), U32.to_nat(len), lenWV(d, t, i, len, pf, hw)), hlen)
  +epo = wordFS(W.SPOw(t, i), Equal.trans(+List<U32>, FX.limbs([W.SPOw(t, i)]), VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))), FX.limbs([W.SPOw(t, i)]), bytePw(d, t, i, len, List.length(&2, U32, ys), en, pf, hw)), hb))
  +eys = Equal.trans(+List<U32>, ys, VS.bdr(@FSn, WV(t, i, len)), YR.WV(t, Nat.add(@Hn, i), W.LL(len)), Equal.sym(+List<U32>, VS.bdr(@FSn, WV(t, i, len)), ys, hdr),
    wv_dr(t, i, len, List.length(&2, U32, ys), en))
  fy = F.logic__subst(+List<U32>, z => YR.FACTS(z), ys, YR.WV(t, Nat.add(@Hn, i), W.LL(len)), eys, YR.inv_p(hv0, ys, hvp))
  chk_truew(t, i, len, List.length(&2, U32, ys), en, epo,
    YR.rej_facts(d, t, Nat.add(@Hn, i), W.LL(len), pf, W.hwY(d, i, len, hw, haw(len, List.length(&2, U32, ys), en)), fy))

def rej_p2(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))) == @FSL : +List<U32>}, +hv0: S.Value, +ys: +List<U32>,
    +hlen: {List.length(&2, U32, WV(t, i, len)) == Nat.add(@FSn, List.length(&2, U32, ys)) : Nat},
    r3: DK.P2({VS.bdr(@FSn, WV(t, i, len)) == ys : +List<U32>}, {Codec.parts(hv0, Spec.@Y()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}))
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  (+hdr, hvp) = r3
  rej_tail(d, t, i, len, pf, hw, hb, hv0, ys, hlen, hdr, hvp)

# A window whose bytes have the checked shape passes the window's checks.
def rej_facts(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, facts: FACTS(WV(t, i, len)))
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  (+hb, ex) = facts
  (+hv0, r1) = ex
  (+ys, r2) = r1
  (+hlen, r3) = r2
  rej_p2(d, t, i, len, pf, hw, hb, hv0, ys, hlen, r3)

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
  v => e => F.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, rej_facts(d, t, 0n, n, pf, hn, inv_v(v, DC.VW(t, n), e))), hchk))

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


def outputs(g, names):
    out = {}
    for n in ORDER:
        x = NName(g, n, names[n])
        out[VBY.fname(x, '_win')] = win_text(x)
        out[VBY.fname(x)] = VBY.top_text(x).replace('codegen/var_bytes.py', 'codegen/var_bytes_nest.py')
        out[VBY.fname(x, '_unique')] = VBY.unique_text(x).replace('codegen/var_bytes.py', 'codegen/var_bytes_nest.py')
        # big names: rej_text states the header size's facts symbolically (x.big branches)
        out[VBY.fname(x, '_rej')] = rej_text(x)
    out.update(VBB.outputs())
    return out
