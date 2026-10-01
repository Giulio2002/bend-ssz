"""Lists of records held BOXED (Array<O.Boxed<R>>: ProposerSlashing, Deposit), for
codegen/proofs/var/var_rlist.py.

proofs/obj/vua_fixb.bend: T.<R>_read at any byte position x for records with boxed fields
(O.Boxed<K>, read by K_bx_read) and packed vector fields (O.Words, read by copy_into into a
fresh storage: the copy is VXB.CTN(d, t, y, L, dz), vua_ct's copy at the Nat position y),
and the boxed readers rdbx_<R>: T.<R>_bx_read returns T.<R>_bx_wrap of the record.

The list modules are var_rlist.list_text's, over boxed elements (post_box): the element
type is O.Boxed<T.R>, the reader T.R_bx_read (rdbx_R), the storage fill the tree of
O.BNone{} (fill_eq). A record whose object holds a copy (Deposit) depends on the source
depth d: its RX, RT and LOBJ take d (post_d).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
from codegen.proofs.var import var_laws as VLW  # noqa: E402
from codegen.proofs.var import var_ua as VUA  # noqa: E402

TRUE = 'True{} : Bool'
P = 'A.quad(VB.pw(d))'


def have(f):
    src = (ROOT / f'proofs/obj/{f}').read_text()
    return {ln.split('(')[0][len('def rdx_'):] for ln in src.splitlines() if ln.startswith('def rdx_')}


def posx(c, y='x'):
    return y if c == 0 else f'{c}n+{y}'


def log2c(n):
    k = 0
    while (1 << k) < n:
        k += 1
    return k


class Rec:
    """A fixed-size field type of a boxed record: 'ft' (var_laws.FT), 'box' (O.Boxed of a
    record), 'words' (a packed vector: O.Words), 'cont' (a container of such fields)."""

    def __init__(self, g, t):
        self.t = t
        s = g.shape(t)
        self.s = s
        self.p = s.p
        self.size = t.fixed_size()
        assert self.size % 4 == 0
        try:
            self.ft = VLW.FT(g, t)
            self.kind = 'ft'
            return
        except VLW.Skip:
            pass
        if t.kind == 'container':
            self.kind = 'cont'
            self.kids = []
            c = 0
            for (fname, ft), (_, fs) in zip(t.fields, s.fields):
                k = Rec(g, ft)
                if fs.kind == 'box':
                    k = BoxRec(k)
                self.kids.append((c, k))
                c += k.size
            return
        assert s.kind == 'packed', (t, s.kind)
        self.kind = 'words'
        self.dz = log2c(self.size // 4)

    @property
    def needs_d(self):
        if self.kind == 'words':
            return True
        if self.kind == 'cont':
            return any(k.needs_d for _, k in self.kids)
        return False

    def rep(self):
        if self.kind == 'ft':
            return self.ft.rep()
        if self.kind == 'words':
            return 'O.Words'
        return f'T.{self.s.rep}'

    def obj(self, y):
        """The object read at the Nat position y (a term)."""
        if self.kind == 'ft':
            return self.ft.obj([f'UR.RWN(t, {posx(4 * k, y)})' for k in range(self.ft.W)])
        if self.kind == 'words':
            return f'O.Words{{FD.array__thaw(U32, VXB.CTN(d, t, {y}, {self.size}, {self.dz}n)), {self.size}}}'
        return f'T.{self.s.rep}{{' + ', '.join(k.obj(posx(c, y)) for c, k in self.kids) + '}'


class BoxRec:
    kind = 'boxed'

    def __init__(self, r):
        self.r = r
        self.size = r.size
        self.needs_d = r.needs_d
        self.name = r.t.name

    def rep(self):
        return f'O.Boxed<T.{self.name}>'

    def obj(self, y):
        return f'T.{self.name}_bx_wrap({self.r.obj(y)})'


def sig(name, size, hd):
    return [f'def {name}(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +x: Nat, +e: {{U32.to_nat(off) == x : Nat}},',
            f'    +hd: {{Nat.is_lt(d, {hd}n) == {TRUE}}}, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}},',
            f'    +hb: {{Nat.is_le(Nat.add(x, {size}n), {P}) == {TRUE}}})']


def rdx_cont(r, refs, deep=False):
    """T.<R>_read at off (byte position x) of a container with boxed / packed fields.
    deep: rdxd_ at any tree depth d < 31 (UR.offx31: the offsets below 2^32)."""
    hd = 31 if deep else (28 if r.needs_d else 30)
    hd30 = 'FD.nat__lt_trans(d, 28n, 30n, hd, {==})' if hd == 28 else 'hd'
    sfx = 'd' if deep else ''
    ox = 'UR.offx31' if deep else 'UR.offx'
    RHS = f'(UA.BF(t, n), {r.obj("x")})'
    TY = f'B.Buf & {r.rep()}'
    L = sig(f'rdx{sfx}_{r.t.name}', r.size, hd) + [f'    -> {{T.{r.p}_read(UA.BF(t, n), off, {r.size}) == {RHS} : {TY}}}:']
    for j, (c, k) in enumerate(r.kids):
        prev = [kk.obj(posx(cc)) for cc, kk in r.kids[:j]]
        args = ', '.join(['off', f'{r.size}'] + prev)
        oj = f'U32.add(off, {c})'
        hbj = f'UR.roomf(x, {r.size}n, {c}n, {k.size}n, {P}, hb, {{==}})'
        ej = f'{ox}(d, off, {c}, x, e, {hd30}, FD.nat__lt_le_trans({posx(c)}, Nat.add({posx(c)}, {k.size}n), {P}, VTX.ltp({posx(c)}, {k.size - 1}n), {hbj}))'
        if k.kind == 'boxed':
            rd = f'T.{k.name}_bx_read(UA.BF(t, n), {oj}, {k.size})'
            lem = f'rdbx{sfx}_{k.name}'
            hdk = 'hd' if (deep or k.needs_d or not r.needs_d) else hd30
        elif k.kind == 'words':
            rd = f'T.{k.p}_read(UA.BF(t, n), {oj}, {k.size})'
            lem = f'rdw{sfx}_{k.p}'
            hdk = 'hd'
        else:
            rd = f'T.{k.p}_read(UA.BF(t, n), {oj}, {k.size})'
            lem = refs(k.p)
            hdk = hd30
        L.append(f'  %Equal.sym({"B.Buf & " + k.rep()}, {rd}, (UA.BF(t, n), {k.obj(posx(c))}),')
        L.append(f'      {lem}(d, t, n, {oj}, {posx(c)}, {ej}, {hdk}, pf, {hbj})) :')
        L.append(f'    {{T.{r.p}_rd{j}({args}, _) == {RHS} : {TY}}}')
    L.append('  {==}')
    return L


def rdbx(r, name, refs, deep=False):
    hd = 31 if deep else (28 if r.needs_d else 30)
    sfx = 'd' if deep else ''
    OBJ = r.obj('x')
    L = sig(f'rdbx{sfx}_{name}', r.size, hd) + [
        f'    -> {{T.{name}_bx_read(UA.BF(t, n), off, {r.size}) == (UA.BF(t, n), T.{name}_bx_wrap({OBJ})) : B.Buf & O.Boxed<T.{name}>}}:',
        f'  %Equal.sym(B.Buf & T.{name}, T.{name}_read(UA.BF(t, n), off, {r.size}), (UA.BF(t, n), {OBJ}), {refs(name)}(d, t, n, off, x, e, hd, pf, hb)) :',
        f'    {{T.{name}_bx_rd(_) == (UA.BF(t, n), T.{name}_bx_wrap({OBJ})) : B.Buf & O.Boxed<T.{name}>}}',
        '  {==}']
    return L


def rdw(r, deep=False):
    if deep:
        K = log2c(r.size + 31)
        return sig(f'rdwd_{r.p}', r.size, 31) + [
            f'    -> {{T.{r.p}_read(UA.BF(t, n), off, {r.size}) == (UA.BF(t, n), {r.obj("x")}) : B.Buf & O.Words}}:',
            f'  %ct_n(d, t, off, x, {r.size}, {r.dz}n, e) : {{T.{r.p}_read(UA.BF(t, n), off, {r.size}) == (UA.BF(t, n), O.Words{{FD.array__thaw(U32, _), {r.size}}}) : B.Buf & O.Words}}',
            f'  VBX.copy_into_at(d, t, n, off, {r.size}, {r.dz}n, {K}n, pf, hd, {{==}}, UW.hsxB(d, off, x, {r.size}, e, {K}n, {{==}}, {{==}}, hb), {{==}}, {{==}}, {{==}})']
    L = sig(f'rdw_{r.p}', r.size, 28) + [
        f'    -> {{T.{r.p}_read(UA.BF(t, n), off, {r.size}) == (UA.BF(t, n), {r.obj("x")}) : B.Buf & O.Words}}:',
        f'  %ct_n(d, t, off, x, {r.size}, {r.dz}n, e) : {{T.{r.p}_read(UA.BF(t, n), off, {r.size}) == (UA.BF(t, n), O.Words{{FD.array__thaw(U32, _), {r.size}}}) : B.Buf & O.Words}}',
        f'  VBX.copy_into_at(d, t, n, off, {r.size}, {r.dz}n, {log2c(r.size + 31)}n, pf, FD.nat__lt_trans(d, 28n, 31n, hd, {{==}}), {{==}}, UW.hsx(d, off, x, {r.size}, e, hd, hb), {{==}}, {{==}}, {{==}})']
    return L


CTN = r"""
# ---- a copy at a Nat byte position ---------------------------------------------------------------

# vua_ct's copy storage CT(d, t, off, L, dz), by the byte position y = off.
def ctsn(r: Nat, +d: Nat, +t: FD.array__Tree<U32>, +q: Nat, +L: U32, +dz: Nat) -> FD.array__Tree<U32>:
  match r:
    case 0n: VBY.MK(L, dz, VB.mone(VC.NW(L), q, 0n, dz, VC.ZT(dz), t))
    case 1n+s: VBY.MK(L, dz, UC.smone(1n+s, VC.NW(L), q, 0n, dz, d, VC.ZT(dz), t))

def CTN(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +L: U32, +dz: Nat) -> FD.array__Tree<U32>: ctsn(UR.m4(y), d, t, UR.d4(y), L, dz)

def cts_n(+r: Nat, +d: Nat, +t: FD.array__Tree<U32>, +off: U32, +L: U32, +dz: Nat) -> {UCT.cts(r, d, t, off, L, dz) == ctsn(r, d, t, VR.QX(off), L, dz) : FD.array__Tree<U32>}:
  match r:
    case 0n: {==}
    case 1n+ +s: {==}

def ct_n(+d: Nat, +t: FD.array__Tree<U32>, +off: U32, +y: Nat, +L: U32, +dz: Nat, +e: {U32.to_nat(off) == y : Nat})
    -> {UCT.CT(d, t, off, L, dz) == CTN(d, t, y, L, dz) : FD.array__Tree<U32>}:
  %e : {UCT.CT(d, t, off, L, dz) == ctsn(UR.m4(_), d, t, UR.d4(_), L, dz) : FD.array__Tree<U32>}
  %Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), VC.split4(off)) :
    {UCT.CT(d, t, off, L, dz) == ctsn(UR.m4(_), d, t, UR.d4(_), L, dz) : FD.array__Tree<U32>}
  %Equal.sym(Nat, UR.m4(Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.RX(off), UR.m4_eq(VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {UCT.CT(d, t, off, L, dz) == ctsn(_, d, t, UR.d4(Nat.add(A.quad(VR.QX(off)), VR.RX(off))), L, dz) : FD.array__Tree<U32>}
  %Equal.sym(Nat, UR.d4(Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.QX(off), UR.d4_eq(VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {UCT.CT(d, t, off, L, dz) == ctsn(VR.RX(off), d, t, _, L, dz) : FD.array__Tree<U32>}
  cts_n(VR.RX(off), d, t, off, L, dz)
"""


def fixb_module(g, recs):
    """proofs/obj/vua_fixb.bend: readers for the boxed list records recs (type objects)."""
    vtx, xf = have('vua_fix.bend'), have('vbx_fix.bend')
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ./vbuf.bend as VB', 'import ./vcopy.bend as VC', 'import ./vbrt.bend as VR', 'import ./vbytes.bend as VBY',
         'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_copy.bend as UC', 'import ./vua_ct.bend as UCT',
         'import ./vua_win.bend as UW', 'import ./vbx.bend as VBX', 'import ./vua_fix.bend as VTX', 'import ./vbx_fix.bend as XF', '',
         '# GENERATED by codegen/proofs/var/var_rlist.py (codegen/proofs/var/var_rlist_box.py). Do not edit.',
         '# T.<R>_read at an offset off at ANY byte position x for records with boxed and packed',
         '# fields, and their boxed readers: see codegen/proofs/var/var_rlist_box.py.']
    L.append(CTN)
    done = set(vtx) | set(xf)

    def refs(p):
        return f'VTX.rdx_{p}' if p in vtx else (f'XF.rdx_{p}' if p in xf else f'rdx_{p}')

    def refsd(p):
        return f'VTX.rdxd_{p}' if p in vtx else (f'XF.rdxd_{p}' if p in xf else f'rdxd_{p}')

    def emit_ft(ft, deep):
        for dep in ft.deps():
            if (dep.p, deep) in done or dep.p in done:
                continue
            rn = 'rdxd_' if deep else 'rdx_'
            for ln in VUA.rdx_lemma(dep, deep=deep):
                ln = ln.replace('ltp(', 'VTX.ltp(').replace('F.', 'FD.')
                for kp in vtx:
                    ln = ln.replace(f'{rn}{kp}(', f'VTX.{rn}{kp}(')
                for kp in xf:
                    ln = ln.replace(f'{rn}{kp}(', f'XF.{rn}{kp}(')
                L.append(ln)
            L.append('')
            done.add((dep.p, deep))

    def emit(r, deep):
        rf = refsd if deep else refs
        if r.kind == 'ft':
            emit_ft(r.ft, deep)
            return
        if r.kind == 'words':
            if (f'w:{r.p}', deep) not in done:
                L.extend(rdw(r, deep) + [''])
                done.add((f'w:{r.p}', deep))
            return
        for _, k in r.kids:
            if k.kind == 'boxed':
                emit(k.r, deep)
                if (f'bx:{k.name}', deep) not in done:
                    L.extend(rdbx(k.r, k.name, rf, deep) + [''])
                    done.add((f'bx:{k.name}', deep))
            else:
                emit(k, deep)
        L.extend(rdx_cont(r, rf, deep) + [''])
    for deep in (False, True):
        if deep:
            L.append('# ---- the same at any tree depth d < 31 (the offsets below 2^32) ----------------------------------\n')
        for t in recs:
            r = Rec(g, t)
            emit(r, deep)
            L.extend(rdbx(r, t.name, refsd if deep else refs, deep) + [''])
    return ('\n'.join(L) + '\n').replace('VXB.', '')


def list_rec(g, rt):
    """(obj, val, sch, proof, rp) of var_rlist.rec_node for a boxed record: the object is
    the boxed record at y (with d when it holds a copy)."""
    r = Rec(g, rt)
    obj = f'T.{rt.name}_bx_wrap({r.obj("y")})'
    word = lambda k: 'UR.RWN(t, y)' if k == 0 else f'UR.RWN(t, {4 * k}n+y)'
    nd = VLW.SL.walk(g, rt, iter(range(100000)))
    mp = {int(w_[1:]): word(j) for j, w_ in enumerate(nd.words)}
    return (obj, VLW.subst_words(nd.val, mp), nd.sch, VLW.subst_words(nd.proof, mp), None), r.needs_d


def reader_box(p, R, RS, hdr):
    """The boxed reader: the storage is the runtime array with the records set in turn."""
    ET = f'O.Boxed<T.{R}>'
    TR = 'FD.array__Tree<U32>'
    AE = f'Array<{ET}>'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    RT = f'''# the records j, j + 1, ..., j + k set into the runtime storage A from index i on
def RT(k: Nat, +i: U32, +j: Nat, A: {AE}, +t: {TR}, +x: Nat) -> {AE}:
  match k:
    case 0n: Array.set({ET}, A, i, RX(t, {POS("j")}))
    case 1n+q: RT(q, U32.add(i, 1), 1n+j, Array.set({ET}, A, i, RX(t, {POS("j")})), t, x)

'''
    RD = f'B.Buf & {AE}'
    HD = 'FD.nat__lt_trans(d, 28n, 30n, hd, {==})'
    LOBJ = f'''def LOBJ(e: Bool, +t: {TR}, +x: Nat, +len: U32) -> T.{p}_Seq:
  match e:
    case True{{}}: T.{p}_Seq{{T.{p}_fill(0n), 0}}
    case False{{}}: T.{p}_Seq{{RT(U32.to_nat(U32.sub(NN(len), 1)), 0, 0n, T.{p}_fill(T.{p}_cap(NN(len))), t, x), NN(len)}}
def OBJw(+d: Nat, +t: {TR}, +x: Nat, +off: U32, +len: U32) -> T.{p}_Seq: LOBJ(U32.is_eq(len, 0), t, x, len)

# The read loop from record j (index i) on.
def lp(k: Nat, +d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +i: U32, +j: Nat, A: {AE},
    +eo: {{U32.to_nat(off) == x : Nat}}, +ej: {{U32.to_nat(i) == j : Nat}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},
    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +hb: {{Nat.is_le({POS("Nat.add(1n+k, j)")}, A.quad(VB.pw(d))) == {TRUE}}})
    -> {{T.{p}_rd(k, i, off, A, (BF(t, n), RX(t, {POS("j")}))) == (BF(t, n), RT(k, i, j, A, t, x)) : {RD}}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      +hb2 = FD.logic__subst(Nat, z => {{Nat.is_le(VRL.pos(1n+z, {RS}n, x), A.quad(VB.pw(d))) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)
      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)
      %Equal.sym(B.Buf & {ET}, T.{R}_bx_read(BF(t, n), U32.add(off, U32.mul(U32.add(i, 1), {RS})), {RS}), (BF(t, n), RX(t, {POS("1n+j")})),
          VXB.rdbx_{R}(d, t, n, U32.add(off, U32.mul(U32.add(i, 1), {RS})), {POS("1n+j")}, ex, {hdr}, pf, hx)) :
        {{T.{p}_rd(q, U32.add(i, 1), off, Array.set({ET}, A, i, RX(t, {POS("j")})), _) == (BF(t, n), RT(1n+q, i, j, A, t, x)) : {RD}}}
      lp(q, d, t, n, x, off, U32.add(i, 1), 1n+j, Array.set({ET}, A, i, RX(t, {POS("j")})), eo, VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2)

'''
    return RT, LOBJ


def rd_go_box(orig, p, R, RS, hdr):
    """rd_go without the record tree's bounds."""
    a = orig.index('      +hcl = hcw(len, hchk)')
    b = orig.index('      +hb0 = ')
    orig = orig[:a] + orig[b:]
    a = orig.index('      +cap = B.words_depth(NN(len))')
    body = orig[:a]
    FILL = f'T.{p}_fill(T.{p}_cap(NN(len)))'
    body += (f'      %Equal.sym(B.Buf & O.Boxed<T.{R}>, T.{R}_bx_read(BF(t, n), off, {RS}), (BF(t, n), RX(t, x)), VXB.rdbx_{R}(d, t, n, off, x, eo, {hdr}, pf, hb0)) :\n'
             f'        {{T.{p}_rd_fin(NN(len), T.{p}_rd(k, 0, off, {FILL}, _)) == (BF(t, n), LOBJ(False{{}}, t, x, len)) : B.Buf & T.{p}_Seq}}\n'
             f'      %Equal.sym(B.Buf & Array<O.Boxed<T.{R}>>, T.{p}_rd(k, 0, off, {FILL}, (BF(t, n), RX(t, x))), (BF(t, n), RT(k, 0, 0n, {FILL}, t, x)),\n'
             f'          lp(k, d, t, n, x, off, 0, 0n, {FILL}, eo, {{==}}, hd, pf, hb)) :\n'
             f'        {{T.{p}_rd_fin(NN(len), _) == (BF(t, n), LOBJ(False{{}}, t, x, len)) : B.Buf & T.{p}_Seq}}\n'
             '      {==}\n\n')
    return body


def post_box(text, p, R, RS, needs_d):
    """var_rlist.list_text's module over boxed elements."""
    ET = f'O.Boxed<T.{R}>'
    hdr = 'hd' if needs_d else 'FD.nat__lt_trans(d, 28n, 30n, hd, {==})'
    RT, LOBJ = reader_box(p, R, RS, hdr)
    a = text.index('# the records j, j + 1')
    b = text.index('# ---- the validator')
    text = text[:a] + RT + text[b:]
    a = text.index('def LOBJ(')
    c0 = text.index('# A non-empty window holds')
    c1 = text.index('def rd_go(')
    b = text.index('def readw(')
    text = text[:a] + LOBJ + text[c0:c1] + rd_go_box(text[c1:b], p, R, RS, hdr) + text[b:]
    assert 'rdx_None' not in text and 'array__upd' not in text
    text = text.replace(f'def RX(+t: FD.array__Tree<U32>, +y: Nat) -> T.{R}:', f'def RX(+t: FD.array__Tree<U32>, +y: Nat) -> {ET}:')
    text = text.replace('import ./vrl.bend as VRL\n', 'import ./vrl.bend as VRL\nimport ./vua_fixb.bend as VXB\n', 1)
    text = text.replace('# GENERATED by codegen/proofs/var/var_rlist.py. Do not edit.', '# GENERATED by codegen/proofs/var/var_rlist.py (codegen/proofs/var/var_rlist_box.py). Do not edit.', 1)
    if needs_d:
        text = text.replace('def RX(+t: ', 'def RX(+d: Nat, +t: ').replace('RX(t, ', 'RX(d, t, ')
        text = text.replace('def RT(k: Nat, ', 'def RT(+d: Nat, k: Nat, ')
        text = re.sub(r'(?<![A-Za-z_.])RT\((?!\+d)', 'RT(d, ', text)
        text = text.replace('def LOBJ(e: Bool, ', 'def LOBJ(+d: Nat, e: Bool, ')
        text = re.sub(r'(?<![A-Za-z_.])LOBJ\((?!\+d)', 'LOBJ(d, ', text)
    return text
