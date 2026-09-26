#!/usr/bin/env python3
"""Generate the spec-connected codec laws of variable-size names.

    python3 codegen/var_laws.py [--check] [--no-big]

Covered family (this generator): containers whose fixed fields are word
aligned Data-kind leaves and records (uint64, byte vectors of whole words,
containers of those) and which have exactly ONE variable field, a list of
uint64 held as packed words (O.Words). Mainnet Fulu names in the family:
DataColumnsByRootIdentifier, IndexedAttestation.

For each name X the generator writes

    proofs/obj/var_codec_<X>.bend
        ok_eval        the validator returns the buffer and CHK(t, n), the Bool
                       of its checks;
        decode_accept  CHK(t, n) = True: the decoder returns Some{OBJ(t, n)},
                       the object of the buffer's words;
        decode_spec    and the buffer's bytes are the spec/codec.bend encoding
                       of VAL(t, n), the spec value of that object;
    proofs/obj/var_codec_<X>_rej.bend
        decode_none    CHK(t, n) = False: the decoder returns None;
        decode_reject  and no spec value is related to the buffer's bytes;
    proofs/obj/var_codec_<X>_enc.bend
        encode_eval    the encoder returns the object and the buffer of an
                       explicit output tree;
        encode_spec    whose bytes are the spec encoding of the object's value;
    proofs/obj/var_codec_<X>_unique.bend
        decode_unique  every spec value of an accepted buffer's bytes is VAL.

and proofs/obj/var_fix_types.bend: the reader and writer lemmas of the fixed
field types at a symbolic word-aligned offset.

The laws quantify over every buffer B.Buf{thaw(t), n} on a perfect word tree
t of depth d < 29 with n <= 4 2^d, and over every object whose list storage is
a perfect tree with room for its words. The generic development is
proofs/obj/v{spec,buf,u32,depth,copy,enc,fix}.bend.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import schema  # noqa: E402
import spec_laws as SL  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
FAMILY = ['DataColumnsByRootIdentifier', 'IndexedAttestation']


class Skip(Exception):
    pass


# ---- fixed field types ---------------------------------------------------------------------

class FT:
    """A fixed field type: runtime prefix p, word count W, byte size, children."""

    def __init__(self, g, t):
        self.t = t
        self.s = g.shape(t)
        self.p = self.s.p
        self.size = t.fixed_size()
        if self.size % 4:
            raise Skip('not whole words')
        self.W = self.size // 4
        if t.kind == 'uint' and t.size == 8:
            self.kind = 'u64'
        elif t.kind == 'bytes' and self.s.kind == 'rec':
            self.kind = 'bytes'
        elif t.kind == 'container' and self.s.kind == 'container' and self.s.data:
            self.kind = 'container'
            self.kids = []
            c = 0
            for (fname, ft), (_, fs) in zip(t.fields, self.s.fields):
                if fs.kind == 'box':
                    raise Skip('boxed field')
                k = FT(g, ft)
                self.kids.append((c, k))
                c += k.size
        else:
            raise Skip(f'fixed field kind {t.kind}/{self.s.kind}')

    def rep(self):
        return {'u64': 'O.U64', 'bytes': f'T.{self.s.rep}', 'container': f'T.{self.s.rep}'}[self.kind]

    def obj(self, ws):
        """The object whose words are ws (terms)."""
        if self.kind == 'u64':
            return f'O.U64{{{ws[0]}, {ws[1]}}}'
        if self.kind == 'bytes':
            return f'T.{self.s.rep}{{' + ', '.join(ws) + '}'
        parts = []
        for c, k in self.kids:
            parts.append(k.obj(ws[c // 4:c // 4 + k.W]))
        return f'T.{self.s.rep}{{' + ', '.join(parts) + '}'

    def deps(self):
        out = []
        if self.kind == 'container':
            for _, k in self.kids:
                for d in k.deps():
                    if d.p not in [x.p for x in out]:
                        out.append(d)
        out.append(self)
        return out


def sl(k, i='i'):
    return f'VB.slot(t, {i})' if k == 0 else f'VB.slot(t, {k}n+{i})'


def rd_lemma(ft):
    """T.<p>_read at off = 4 i reads words i .. i + W - 1."""
    W = ft.W
    words = [sl(k) for k in range(W)]
    OBJ = ft.obj(words)
    RHS = f'(VF.BF(t, n), {OBJ})'
    TY = f'B.Buf & {ft.rep()}'
    L = [f'def rd_{ft.p}(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +e: {{U32.to_nat(off) == A.quad(i) : Nat}},',
         '    +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},',
         f'    +hb: {{Nat.is_le(Nat.add({W}n, i), VB.pw(d)) == True{{}} : Bool}})',
         f'    -> {{T.{ft.p}_read(VF.BF(t, n), off, {ft.size}) == {RHS} : {TY}}}:']
    w = L.append
    hd32 = 'VB.lt32(d, F.nat__lt_trans(d, 29n, 31n, hd, {==}))'

    def at(k):
        # (offset term, index term, equation proof) of word k
        if k == 0:
            return 'off', 'i', 'e'
        return (f'U32.add(off, {4 * k})', f'{k}n+i',
                f'VF.off_add(off, {4 * k}, i, {k}n, 2n+d, e, {{==}}, hd, VF.in_q({k}n, i, d, VF.lt_le1({k}n, i, VB.pw(d), VF.in_lt({k}n, {W}n, i, VB.pw(d), {{==}}, hb))))')

    def rd(k):
        o, ix, ee = at(k)
        return (f'Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), {o}), (VF.BF(t, n), {sl(k)}), '
                f'VF.rd32a(d, t, n, {o}, {ix}, {ee}, {hd32}, VF.in_lt({k}n, {W}n, i, VB.pw(d), {{==}}, hb), pf))')
    if ft.kind == 'u64':
        w(f'  %{rd(0)} :')
        w(f'    {{O.u64_of(B.read64_lo(off, _)) == {RHS} : {TY}}}')
        w(f'  %{rd(1)} :')
        w(f'    {{O.u64_of(B.read64_hi({sl(0)}, _)) == {RHS} : {TY}}}')
        w('  {==}')
    elif ft.kind == 'bytes':
        for k in range(W):
            args = ', '.join(['off'] + words[:k])
            w(f'  %{rd(k)} :')
            w(f'    {{T.{ft.p}_r{k}({args}, _) == {RHS} : {TY}}}')
        w('  {==}')
    else:
        for j, (c, kt) in enumerate(ft.kids):
            k0 = c // 4
            wk = words[k0:k0 + kt.W]
            prev = [kk.obj(words[cc // 4:cc // 4 + kk.W]) for cc, kk in ft.kids[:j]]
            args = ', '.join(['off', f'{ft.size}'] + prev)
            oj = f'U32.add(off, {c})'
            ij = f'Nat.add({k0}n, i)'
            ej = f'VF.off_add(off, {c}, i, {k0}n, 2n+d, e, {{==}}, hd, VF.in_q({k0}n, i, d, VF.in_le(0n, {k0}n, {W}n, i, VB.pw(d), {{==}}, hb)))'
            hbj = f'VF.in_le({kt.W}n, {k0}n, {W}n, i, VB.pw(d), {{==}}, hb)'
            OBJj = kt.obj(wk)
            w(f'  %Equal.sym(B.Buf & {kt.rep()}, T.{kt.p}_read(VF.BF(t, n), {oj}, {kt.size}), (VF.BF(t, n), {OBJj}),')
            w(f'      rd_{kt.p}(d, t, n, {oj}, {ij}, {ej}, hd, pf, {hbj})) :')
            w(f'    {{T.{ft.p}_rd{j}({args}, _) == {RHS} : {TY}}}')
        w('  {==}')
    return L


def put_lemma(ft):
    """T.<p>_put at pos = 4 P writes the object's words at P .. P + W - 1."""
    W = ft.W
    xs = [f'x{k}' for k in range(W)]
    OBJ = ft.obj(xs)
    RHS = f'F.array__thaw(U32, VF.updv([{", ".join(xs)}], dd, D, P))'
    sig = ', '.join(f'+x{k}: U32' for k in range(W))
    L = [f'def put_{ft.p}(+dd: Nat, +D: F.array__Tree<U32>, +pos: U32, +P: Nat, +e: {{U32.to_nat(pos) == A.quad(P) : Nat}},',
         '    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},',
         f'    +hb: {{Nat.is_le(Nat.add({W}n, P), VB.pw(dd)) == True{{}} : Bool}}, {sig})',
         f'    -> {{T.{ft.p}_put(F.array__thaw(U32, D), pos, {OBJ}) == {RHS} : Array<U32>}}:']
    w = L.append
    hd32 = 'VB.lt32(dd, F.nat__lt_trans(dd, 29n, 31n, hdd, {==}))'
    q = 'U32.shrn(pos, 2n)'
    trees = ['D']
    pfs = ['pf']
    for k in range(W):
        trees.append(f'F.array__upd(U32, dd, {trees[-1]}, {k}n+P, x{k})' if k else f'F.array__upd(U32, dd, D, P, x0)')
        pfs.append(f'F.array__upd_perfect(U32, dd, {trees[-2]}, {k}n+P, x{k}, {pfs[-1]})' if k else 'F.array__upd_perfect(U32, dd, D, P, x0, pf)')
    lt = lambda k: f'VF.in_lt({k}n, {W}n, P, VB.pw(dd), {{==}}, hb)'

    def setk(k):
        if k == 0:
            return (f'Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), {q}, x0), F.array__thaw(U32, {trees[1]}), '
                    f'VB.set_n(dd, D, {q}, P, x0, VF.al_q(pos, P, e), {hd32}, {lt(0)}, pf))')
        return (f'Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, {trees[k]}), U32.add({q}, {k}), x{k}), F.array__thaw(U32, {trees[k + 1]}), '
                f'VB.set_at(dd, {trees[k]}, {q}, {k}, P, x{k}, VF.al_q(pos, P, e), {hd32}, {lt(k)}, {pfs[k]}))')
    if ft.kind == 'u64':
        w(f'  %Equal.sym(U32, U32.and(pos, 3), 0, VF.al_3(pos, P, e)) :')
        w(f'    {{O.w64_at(U32.is_eq(_, 0), F.array__thaw(U32, D), pos, x0, x1) == {RHS} : Array<U32>}}')
        w(f'  %{setk(0)} :')
        w(f'    {{Array.set(U32, _, U32.add({q}, 1), x1) == {RHS} : Array<U32>}}')
        w(f'  %{setk(1)} :')
        w(f'    {{_ == {RHS} : Array<U32>}}')
        w('  {==}')
    elif ft.kind == 'bytes':
        w(f'  %Equal.sym(U32, U32.and(pos, 3), 0, VF.al_3(pos, P, e)) :')
        w(f'    {{T.{ft.p}_pwd(U32.is_eq(_, 0), _, F.array__thaw(U32, D), {q}, {", ".join(xs)}) == {RHS} : Array<U32>}}')
        # b<N>_pw0: Array.set(... Array.set(out, (q + 0), x0) ..., (q + W-1), x_{W-1})
        for k in range(W):
            pat = '_'
            for j in range(k + 1, W):
                pat = f'Array.set(U32, {pat}, U32.add({q}, {j}), x{j})'
            if k == 0:
                s0 = (f'Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add({q}, 0), x0), F.array__thaw(U32, {trees[1]}), '
                      f'VB.set_at(dd, D, {q}, 0, P, x0, VF.al_q(pos, P, e), {hd32}, {lt(0)}, pf))')
                w(f'  %{s0} :')
            else:
                w(f'  %{setk(k)} :')
            w(f'    {{{pat} == {RHS} : Array<U32>}}')
        w('  {==}')
    else:
        # C_put(out, pos, C{v..}) = K_{m-1}_put(... K_0_put(out, (pos + c0), v0) ..., (pos + c_{m-1}), v_{m-1})
        m = len(ft.kids)
        cur = 'D'
        curpf = 'pf'
        for j, (c, kt) in enumerate(ft.kids):
            k0 = c // 4
            wk = xs[k0:k0 + kt.W]
            pat = '_'
            for jj in range(j + 1, m):
                cc, kk = ft.kids[jj]
                pat = f'T.{kk.p}_put({pat}, U32.add(pos, {cc}), {kk.obj(xs[cc // 4:cc // 4 + kk.W])})'
            oj = f'U32.add(pos, {c})'
            ej = f'VF.off_add(pos, {c}, P, {k0}n, 2n+dd, e, {{==}}, hdd, VF.in_q({k0}n, P, dd, VF.in_le(0n, {k0}n, {W}n, P, VB.pw(dd), {{==}}, hb)))'
            hbj = f'VF.in_le({kt.W}n, {k0}n, {W}n, P, VB.pw(dd), {{==}}, hb)'
            nxt = f'VF.updv([{", ".join(wk)}], dd, {cur}, Nat.add({k0}n, P))'
            w(f'  %Equal.sym(Array<U32>, T.{kt.p}_put(F.array__thaw(U32, {cur}), {oj}, {kt.obj(wk)}), F.array__thaw(U32, {nxt}),')
            w(f'      put_{kt.p}(dd, {cur}, {oj}, Nat.add({k0}n, P), {ej}, hdd, {curpf}, {hbj}, {", ".join(wk)})) :')
            w(f'    {{{pat} == {RHS} : Array<U32>}}')
            curpf = f'VF.updv_perfect([{", ".join(wk)}], dd, {cur}, Nat.add({k0}n, P), {curpf})'
            cur = nxt
        w('  {==}')
    return L


FIX_HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
            'import ../../types/fulu_obj.bend as T', 'import ../compact/found.bend as F', 'import ../compact/arith.bend as A',
            'import ./vbuf.bend as VB', 'import ./vfix.bend as VF']


def fix_module(fts):
    L = list(FIX_HEAD) + ['', '# GENERATED by codegen/var_laws.py. Do not edit.',
                          '# Readers and writers of the fixed field types at a word-aligned offset 4 i',
                          '# (symbolic), on the array model: reads return the object of words i ..,',
                          '# writes are the run of word writes VF.updv of the object\'s words.', '']
    for ft in fts:
        L += rd_lemma(ft) + [''] + put_lemma(ft) + ['']
    return '\n'.join(L) + '\n'



# ---- one name ------------------------------------------------------------------------------

def ceil_log2(x):
    return max(0, (x - 1).bit_length())


class Name:
    def __init__(self, g, n, t, src):
        self.n, self.t = n, t
        self.fields = []
        pos = 0
        var = None
        for fname, ft in t.fields:
            if ft.fixed():
                f = FT(g, ft)
                self.fields.append({'kind': 'fix', 'name': fname, 'ft': f, 'c': pos, 'k': pos // 4, 't': ft})
                pos += f.size
            else:
                s = g.shape(ft)
                if not (ft.kind == 'list' and ft.elem.kind == 'uint' and ft.elem.size == 8 and s.kind == 'packed'):
                    raise Skip(f'variable field {fname} is not a list of uint64')
                if var is not None:
                    raise Skip('more than one variable field')
                var = {'kind': 'var', 'name': fname, 'c': pos, 'k': pos // 4, 'lp': s.p, 'LIM': ft.size, 't': ft}
                self.fields.append(var)
                pos += 4
        if var is None:
            raise Skip('no variable field')
        if pos % 4:
            raise Skip('header not whole words')
        self.FS, self.H = pos, pos // 4
        self.var = var
        self.po = var['k']
        self.lp, self.LIM = var['lp'], var['LIM']
        # storage depths: decoded list storage and the encoder's output
        self.K = ceil_log2(((31 + 8 * self.LIM) >> 2) + 8)
        self.KO = ceil_log2(self.H + 2 * self.LIM)
        self.check_runtime(src)

    def check_runtime(self, src):
        n, FS, lp = self.n, self.FS, self.lp
        want = [f'def {n}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {n}_ok_len(U32.is_le({FS}, len), buf, off, len)',
                f'    case True{{}}: {n}_v0(off, len, B.read32(buf, (off + {self.var["c"]} : U32)))',
                f'  {n}_c0(U32.is_eq(o0, {FS}), buf, off, len, o0)',
                f'    case True{{}}: {n}_v1(off, len, o0, {lp}_ok(buf, (off + o0 : U32), (len - o0 : U32)))',
                f'def {lp}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), {self.LIM})))',
                f'def {lp}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)']
        for x in want:
            if x not in src:
                raise Skip('runtime shape differs: ' + x)
def is_big(x):
    """Laws whose statements carry the list limit as a closed number too large
    for stock Bend's unary evaluation go to big_* files (checkq --big)."""
    return x.LIM >= 1 << 16


def fname(x, part=''):
    return ROOT / f'proofs/obj/{"big_" if is_big(x) else ""}var_codec_{x.n}{part}.bend'


def unique_text(x):
    n = x.n
    D = fname(x).name
    return f'''import Base
import ../../types/schema.bend as S
import ../../spec/decoding_relation.bend as Decoding
import ../../spec/fulu_schemas.bend as Spec
import ../../proofs/fulu_legality.bend as Legal
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./{D} as DC
import ../../proofs/decode_complete.bend as DCO

# GENERATED by codegen/var_laws.py. Do not edit.
# Every spec value of an accepted buffer's bytes is the decoded object's value.
law decode_unique:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {{F.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.{n}(), DC.VW(t, n), v)
  {{v == DC.VAL(t, n) : S.Value}}
def decode_unique(d, t, n, pf, hd, hn, hchk, v, spec):
  DCO.image_unique(Spec.{n}(), DC.VW(t, n), v, DC.VAL(t, n), Legal.{n}_normative_legal(), spec,
    DC.decode_spec(d, t, n, pf, hd, hn, hchk))
'''


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    src = (ROOT / 'types/fulu_obj.bend').read_text()
    no_big = '--no-big' in sys.argv
    fts = []
    xs = []
    for n in FAMILY:
        t = names[n]
        for fname_, ft in t.fields:
            if ft.fixed():
                for d in FT(g, ft).deps():
                    if d.p not in [x.p for x in fts]:
                        fts.append(d)
        xs.append(Name(g, n, t, src))
    out = {ROOT / 'proofs/obj/var_fix_types.bend': fix_module(fts)}
    for x in xs:
        if no_big and is_big(x):
            continue
        out[fname(x)] = dec_module_text(g, x)
        out[fname(x, '_unique')] = unique_text(x)
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_codec_*.bend') if q.name.startswith(('var_codec_', 'big_var_codec_'))]
    orphans = sorted(str(q.relative_to(ROOT)) for q in mine if q not in out and 'dcbri' not in q.name
                     and not (no_big and q.name.startswith('big_')))
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, text in out.items() if not p.exists() or p.read_text() != text]
        if stale or orphans:
            print('stale generated variable-size laws: ' + ', '.join(stale + orphans))
            sys.exit(1)
        print('generated variable-size laws are current')
        return
    for q in orphans:
        (ROOT / q).unlink()
    for p, text in out.items():
        p.write_text(text)
    print(f'{len(fts)} fixed field types, {len(xs)} names: ' + ', '.join(str(p.relative_to(ROOT)) for p in out))




# ---- the decoder laws of one name ---------------------------------------------------------------

DEC_HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
            'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
            'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
            'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
            'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/nat_bytes.bend as N',
            'import ../../spec/fulu_schemas.bend as Spec', 'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS',
            'import ./vbuf.bend as VB', 'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD',
            'import ./vfix.bend as VF', 'import ./var_fix_types.bend as VT']


def subst_words(term, mapping):
    return re.sub(r'\bx(\d+)\b', lambda m: mapping[int(m.group(1))], term)


def field_nodes(g, x, wordterm):
    """walk() nodes of the fixed fields with their words renamed: wordterm(k)
    is the term of header word k."""
    out = []
    for f in x.fields:
        if f['kind'] != 'fix':
            out.append(None)
            continue
        c = iter(range(100000))
        node = SL.walk(g, f['t'], c)
        mp = {int(w[1:]): wordterm(f['k'] + j) for j, w in enumerate(node.words)}
        out.append({'obj': subst_words(node.obj, mp), 'val': subst_words(node.val, mp), 'sch': node.sch,
                    'proof': subst_words(node.proof, mp), 'words': [mp[int(w[1:])] for w in node.words]})
    return out


def dec_module(g, x):
    n, FS, H, po, LIM, K, lp = x.n, x.FS, x.H, x.po, x.LIM, x.K, x.lp
    L = list(DEC_HEAD) + ['', f'# GENERATED by codegen/var_laws.py. Do not edit.',
                          f'# {n}: the validator, the decoder, and the spec relation of the decoded value',
                          f'# (see the module docstring of codegen/var_laws.py).', '']
    w = L.append
    Tn = f'T.{n}'
    w(f'''def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{{FD.array__thaw(U32, t), n}}

def rd32(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {{U32.to_nat(q) == i : Nat}},
    +hd: {{Nat.is_lt(d, 32n) == True{{}} : Bool}}, +hi: {{Nat.is_lt(i, VB.pw(d)) == True{{}} : Bool}},
    +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}})
    -> {{B.word(BF(t, n), q) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, t), q), (FD.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, q, i, eq, hd, hi, pf)) :
    {{B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}}
  {{==}}

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{{}}: False{{}}
    case True{{}}:
      match b:
        case False{{}}: False{{}}
        case True{{}}: c

def whole(+L: U32) -> Bool: Bool.and(U32.is_eq(L, (U32.div(L, 8) * 8 : U32)), U32.is_le(U32.div(L, 8), {LIM}))

def SPO(t: FD.array__Tree<U32>) -> U32: VB.slot(t, {po}n)

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {{{Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}}:
  match ok:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def ok_c0(+t: FD.array__Tree<U32>, +n: U32, +b: Bool)
    -> {{{Tn}_c0(b, BF(t, n), 0, n, SPO(t)) == (BF(t, n), chk3(True{{}}, b, whole(U32.sub(n, SPO(t))))) : B.Buf & Bool}}:
  match b:
    case False{{}}: {{==}}
    case True{{}}: c1_id(whole(U32.sub(n, SPO(t))), BF(t, n), 0, n, SPO(t))

def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chk3(U32.is_le({FS}, n), U32.is_eq(SPO(t), {FS}), whole(U32.sub(n, SPO(t))))

def ok_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +a: Bool,
    +hd: {{Nat.is_lt(d, 32n) == True{{}} : Bool}}, +hpo: {{Nat.is_lt({po}n, VB.pw(d)) == True{{}} : Bool}},
    +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}})
    -> {{{Tn}_ok_len(a, BF(t, n), 0, n) == (BF(t, n), chk3(a, U32.is_eq(SPO(t), {FS}), whole(U32.sub(n, SPO(t))))) : B.Buf & Bool}}:
  match a:
    case False{{}}: {{==}}
    case True{{}}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), {po}), (BF(t, n), SPO(t)), rd32(d, t, n, {po}, {po}n, {{==}}, hd, hpo, pf)) :
        {{{Tn}_v0(0, n, _) == (BF(t, n), chk3(True{{}}, U32.is_eq(SPO(t), {FS}), whole(U32.sub(n, SPO(t))))) : B.Buf & Bool}}
      ok_c0(t, n, U32.is_eq(SPO(t), {FS}))

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32,
    +hd: {{Nat.is_lt(d, 32n) == True{{}} : Bool}}, +hpo: {{Nat.is_lt({po}n, VB.pw(d)) == True{{}} : Bool}},
    +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}})
    -> {{{Tn}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}}:
  ok_len(d, t, n, U32.is_le({FS}, n), hd, hpo, pf)
''')
    # zeros
    w(f'def zeros_at(+du: U32, +k: Nat, +e: {{U32.to_nat(du) == k : Nat}}, +hk: {{Nat.is_le(k, {max(K, x.KO)}n) == True{{}} : Bool}})')
    w('    -> {B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}:')
    w('  match k:')
    for j in range(max(K, x.KO) + 1):
        w(f'    case {j}n:')
        w(f'      %Equal.sym(U32, du, {j}, FD.u32__injective(du, {j}, e)) : {{B.zeros(_) == Array.new(U32, {j}n, 0) : Array<U32>}}')
        w('      {==}')
    KK = max(K, x.KO) + 1
    w(f'    case {KK}n+p: Empty.absurd({{B.zeros(du) == Array.new(U32, {KK}n+p, 0) : Array<U32>}}, FD.logic__false_true(hk))')
    X8L = 8 * LIM
    Y = 31 + X8L
    RB = (Y >> 2) + 8
    w(f'''
def v8() -> Word(31n): FD.spec_numeric__from_nat(31n, 8n)
def LL(+n: U32) -> U32: U32.sub(n, {FS})
def CQ(+n: U32) -> Nat: U32.to_nat(U32.div(LL(n), 8))
def DZ(+n: U32) -> Nat: B.words_depth(VC.WZ(LL(n)))
def MM(+t: FD.array__Tree<U32>, +n: U32) -> FD.array__Tree<U32>: VB.mone(VC.NW(LL(n)), {H}n, 0n, DZ(n), VC.ZT(DZ(n)), t)

def leFS(+n: U32, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}) -> {{Nat.is_le({FS}n, U32.to_nat(n)) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le({FS}, n), Nat.is_le({FS}n, U32.to_nat(n)), VU.le_u32({FS}, n), ha)

def enFS(+n: U32, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}) -> {{Nat.add({FS}n, U32.to_nat(LL(n))) == U32.to_nat(n) : Nat}}:
  %Equal.sym(Nat, U32.to_nat(LL(n)), Nat.sub(U32.to_nat(n), {FS}n), FD.u32__sub_nat(n, {FS}, leFS(n, ha))) : {{Nat.add({FS}n, _) == U32.to_nat(n) : Nat}}
  FD.nat__sub_add(U32.to_nat(n), {FS}n, leFS(n, ha))

def eLc(+n: U32, +hc: {{whole(LL(n)) == True{{}} : Bool}}) -> {{U32.to_nat(LL(n)) == VS.x8(CQ(n)) : Nat}}:
  %VC.x8_mul(CQ(n)) : {{U32.to_nat(LL(n)) == _ : Nat}}
  Pair.fst({{U32.to_nat(LL(n)) == Nat.mul(CQ(n), U32.to_nat(8)) : Nat}}, {{Nat.is_le(CQ(n), U32.to_nat({LIM})) == True{{}} : Bool}},
    VU.whole_t(LL(n), 8, {LIM}, v8(), {{==}}, {{==}}, {{==}}, hc))

def hcL(+n: U32, +hc: {{whole(LL(n)) == True{{}} : Bool}}) -> {{Nat.is_le(CQ(n), U32.to_nat({LIM})) == True{{}} : Bool}}:
  Pair.snd({{U32.to_nat(LL(n)) == Nat.mul(CQ(n), U32.to_nat(8)) : Nat}}, {{Nat.is_le(CQ(n), U32.to_nat({LIM})) == True{{}} : Bool}},
    VU.whole_t(LL(n), 8, {LIM}, v8(), {{==}}, {{==}}, {{==}}, hc))

def hy(+d: Nat, +n: U32, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}, +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}})
    -> {{Nat.is_le(VC.YL(LL(n)), VB.pw(2n+d)) == True{{}} : Bool}}:
  FD.nat__le_trans(VC.YL(LL(n)), U32.to_nat(n), VB.pw(2n+d),
    FD.logic__subst(Nat, z => {{Nat.is_le(VC.YL(LL(n)), z) == True{{}} : Bool}}, Nat.add({FS}n, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha),
      Order.add_right(31n, {FS}n, U32.to_nat(LL(n)), {{==}})),
    hn)

def eNWc(+d: Nat, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{VC.NW(LL(n)) == Nat.double(CQ(n)) : Nat}}:
  %Equal.sym(Nat, VC.NW(LL(n)), VD.s_rng(2n, 3n+U32.to_nat(LL(n))), VC.eNW(LL(n), 2n+d, hd, hy(d, n, ha, hn))) : {{_ == Nat.double(CQ(n)) : Nat}}
  %Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)) : {{VD.s_rng(2n, 3n+_) == Nat.double(CQ(n)) : Nat}}
  VC.rng2_x8(CQ(n))

# H + 2c <= 2^d: the header and the list's words lie in the buffer.
def hs(+d: Nat, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(VC.NW(LL(n)), {H}n), VB.pw(d)) == True{{}} : Bool}}:
  %Equal.sym(Nat, VC.NW(LL(n)), Nat.double(CQ(n)), eNWc(d, n, hd, ha, hn, hc)) : {{Nat.is_le(Nat.add(_, {H}n), VB.pw(d)) == True{{}} : Bool}}
  %FD.nat__add_comm({H}n, Nat.double(CQ(n))) : {{Nat.is_le(_, VB.pw(d)) == True{{}} : Bool}}
  VC.quad_inv({H}n+Nat.double(CQ(n)), VB.pw(d),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(n), {FS}n+VB.d3(CQ(n)),
      Equal.trans(Nat, U32.to_nat(n), Nat.add({FS}n, U32.to_nat(LL(n))), {FS}n+VB.d3(CQ(n)), Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha)),
        Equal.cong(Nat, Nat, z => Nat.add({FS}n, z), U32.to_nat(LL(n)), VB.d3(CQ(n)), Equal.trans(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), VB.d3(CQ(n)), eLc(n, hc), VB.x8_d3(CQ(n))))),
      hn))

def hWZ(+d: Nat, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{Nat.is_le(U32.to_nat(VC.WZ(LL(n))), O.pow2n({K}n)) == True{{}} : Bool}}:
  +hx = FD.logic__subst(Nat, z => {{Nat.is_le(z, VS.x8(U32.to_nat({LIM}))) == True{{}} : Bool}}, VS.x8(CQ(n)), U32.to_nat(LL(n)), Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)),
    VS.x8_mono(CQ(n), U32.to_nat({LIM}), hcL(n, hc)))
  FD.nat__le_trans(U32.to_nat(VC.WZ(LL(n))), Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), O.pow2n({K}n),
    VC.wz_le(LL(n), 2n+d, hd, hy(d, n, ha, hn)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat({LIM})))), 8n), O.pow2n({K}n),
      Order.add_right(VD.s_rng(2n, VC.YL(LL(n))), VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat({LIM})))), 8n, VC.rng_mono(2n, VC.YL(LL(n)), Nat.add(31n, VS.x8(U32.to_nat({LIM}))), Order.add_left(31n, U32.to_nat(LL(n)), VS.x8(U32.to_nat({LIM})), hx))),
      {{==}}))

def hdzK(+d: Nat, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{Nat.is_le(DZ(n), {K}n) == True{{}} : Bool}}:
  VD.wd_min(VC.WZ(LL(n)), {K}n, hWZ(d, n, hd, ha, hn, hc))

def hr(+d: Nat, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(VC.NW(LL(n)), 0n), VB.pw(DZ(n))) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add(VC.NW(LL(n)), 0n), VC.NW(LL(n)), FD.nat__add_zero(VC.NW(LL(n)))) : {{Nat.is_le(_, VB.pw(DZ(n))) == True{{}} : Bool}}
  %Equal.sym(Nat, VB.pw(DZ(n)), O.pow2n(DZ(n)), VD.s_pow2_eq(DZ(n))) : {{Nat.is_le(VC.NW(LL(n)), _) == True{{}} : Bool}}
  FD.nat__le_trans(VC.NW(LL(n)), U32.to_nat(VC.WZ(LL(n))), O.pow2n(DZ(n)),
    VC.nw_le_wz(LL(n), 2n+d, hd, hy(d, n, ha, hn)),
    VD.wd_cover(VC.WZ(LL(n)), {K}n, {{==}}, hWZ(d, n, hd, ha, hn, hc)))

# k < 2^d for every header word k < H.
def hk(+k: Nat, +d: Nat, +n: U32, +hkH: {{Nat.is_lt(k, {H}n) == True{{}} : Bool}}, +h: {{Nat.is_le(Nat.add(VC.NW(LL(n)), {H}n), VB.pw(d)) == True{{}} : Bool}})
    -> {{Nat.is_lt(k, VB.pw(d)) == True{{}} : Bool}}:
  FD.nat__lt_le_trans(k, {H}n, VB.pw(d), hkH, FD.nat__le_trans({H}n, Nat.add(VC.NW(LL(n)), {H}n), VB.pw(d), Order.left_below_sum(VC.NW(LL(n)), {H}n), h))
''')
    dec_read(x, w, Tn)
    dec_spec(g, x, w, Tn)
    return L


def spec_lim(n, j):
    """The limit term of the spec schema of name n's field j (a ListOf)."""
    src = (ROOT / 'spec/fulu_schemas.bend').read_text()
    defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.*)$', src, re.M))
    body = defs[n]
    while re.fullmatch(r'Schema\d+\(\)', body):
        body = defs[body[:-2]]
    kids = re.findall(r'T\.Chain\{(Schema\d+)\(\)', body)
    m = re.fullmatch(r'T\.ListOf\{Schema\d+\(\), (.*)\}', defs[kids[j]])
    return m.group(1)


def spec_parts(g, x, word, k='k', W='W'):
    """(ITEMS, CHAIN, PL, CAT, PRE, POST, HDR) of name x over header words word(k):
    the spec value items and schema chain, the parts list, the proof that the
    parts of the items are that list, the fixed word lists before and after
    the variable field, and the header words (the offset is FS)."""
    nodes = field_nodes(g, x, word)
    LIMN = spec_lim(x.n, [f['kind'] for f in x.fields].index('var'))
    YS = f'VS.wtake(Nat.double({k}), {W})'
    vals, schs, parts = [], [], []
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append(f'S.Sequence{{VS.uitems({k}, {W})}}')
            schs.append(f'S.ListOf{{S.Unsigned{{P.U64{{}}}}, {LIMN}}}')
            parts.append(f'S.Variable{{F.limbs({YS})}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        f = x.fields[i]
        if f['kind'] == 'fix':
            return (f'F.cat_fixed(Codec.parts({vals[i]}, {schs[i]}), F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.cat_var(Codec.parts({vals[i]}, {schs[i]}), F.limbs({YS}), Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, '
                f'VS.list_u64_parts({k}, {W}, {LIMN}, hk, {{==}}, hl), {cat(i + 1)})')
    vi = [f['kind'] for f in x.fields].index('var')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(x.FS)]
    return items(0), chain(0), '[' + ', '.join(parts) + ']', cat(0), PRE, POST, hdr, LIMN, YS


def dec_spec(g, x, w, Tn):
    FS, H, po = x.FS, x.H, x.po
    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, LIMN, YS = spec_parts(g, x, lambda k: f'VB.slot(t, {k}n)')
    HDR = ' <> '.join(hdr)
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), F.limbs({YS}))'
    RHS = f'Some{{F.limbs({HDR} <> {YS})}}'
    M = 'Maybe<&2, +List<U32>>'
    MP = 'Maybe<&2, +List<S.Part>>'
    s = 'FD.array__slots(U32, t)'
    NW = 'VC.NW(LL(n))'
    LM = f'VB.lm({NW}, {H}n, 0n, FD.array__slots(U32, VC.ZT(DZ(n))), {s})'
    hdrs = ' <> '.join(h if i != po else 'SPO(t)' for i, h in enumerate(hdr))
    hdrh = ' <> '.join(h if i != po else '_' for i, h in enumerate(hdr))
    RW = f'F.limbs(VF.app(VF.wpre({H}n, 0n, {s}), VS.wtake({NW}, VB.wdr({H}n, {s}))))'
    w(f'''
# ---- the spec side -------------------------------------------------------------------------

def XV(+t: FD.array__Tree<U32>, +k: Nat, +W: List<&2, U32>) -> S.Value: S.Sequence{{{ITEMS}}}

# The spec encoding of the value of header words t and list words W (k elements).
def enc_spec(+t: FD.array__Tree<U32>, +k: Nat, +W: List<&2, U32>,
    +hk: {{Nat.is_le(k, {LIMN}) == True{{}} : Bool}},
    +hl: {{Nat.is_le(Nat.double(k), FD.spec_common__length(U32, W)) == True{{}} : Bool}})
    -> {{Codec.encoding_for_legal_type(Spec.{x.n}(), XV(t, k, W)) == {RHS} : {M}}}:
  +le2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, VS.x8({LIMN})) == True{{}} : Bool}}, VS.x8(k), List.length(&2, U32, F.limbs({YS})),
    Equal.sym(Nat, List.length(&2, U32, F.limbs({YS})), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)), VS.x8_mono(k, {LIMN}, hk))
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, F.limbs({YS}))), Nat.add({FS}n, VS.x8({LIMN})),
    Order.add_left({FS}n, List.length(&2, U32, F.limbs({YS})), VS.x8({LIMN}), le2), {{==}})
  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PL}}},
      {CAT}) :
    {{Codec.bytes(Codec.aggregate(_, None{{}})) == {RHS} : {M}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, F.limbs({YS}), {POST})), Some{{{ENCR}}}, VS.enc_fpv({PRE}, {YS}, {POST}, fit)) :
    {{Codec.bytes(Codec.one(_, None{{}})) == {RHS} : {M}}}
  {{==}}

def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs({s}))
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: XV(t, CQ(n), FD.array__slots(U32, MM(t, n)))

def en_q(+d: Nat, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}},
    +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{A.quad({H}n+{NW}) == U32.to_nat(n) : Nat}}:
  %Equal.sym(Nat, {NW}, Nat.double(CQ(n)), eNWc(d, n, hd, ha, hn, hc)) : {{A.quad({H}n+_) == U32.to_nat(n) : Nat}}
  %enFS(n, ha) : {{A.quad({H}n+Nat.double(CQ(n))) == _ : Nat}}
  %Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)) : {{A.quad({H}n+Nat.double(CQ(n))) == Nat.add({FS}n, _) : Nat}}
  %Equal.sym(Nat, VS.x8(CQ(n)), VB.d3(CQ(n)), VB.x8_d3(CQ(n))) : {{A.quad({H}n+Nat.double(CQ(n))) == Nat.add({FS}n, _) : Nat}}
  {{==}}

def len_z(+n: U32) -> {{VB.len(FD.array__slots(U32, VC.ZT(DZ(n)))) == VB.pw(DZ(n)) : Nat}}:
  FD.array__slots_length(U32, DZ(n), VC.ZT(DZ(n)), FD.array__trep_perfect(U32, DZ(n), 0))

# The buffer's bytes are the limbs of the header words and the list's words.
def lim_eq(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}, +epo: {{SPO(t) == {FS} : U32}},
    +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{F.limbs({HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == VW(t, n) : +List<U32>}}:
  +hs0 = hs(d, n, hd, ha, hn, hc)
  +hr0 = hr(d, n, hd, ha, hn, hc)
  +hsl = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({NW}, {H}n), z) == True{{}} : Bool}}, VB.pw(d), VB.len({s}), Equal.sym(Nat, VB.len({s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hs0)
  +hpre = FD.nat__le_trans({H}n, Nat.add({NW}, {H}n), VB.len({s}), Order.left_below_sum({NW}, {H}n), hsl)
  %en_q(d, n, hd, hn, ha, hc) : {{F.limbs({HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == VS.bt(_, F.limbs({s})) : +List<U32>}}
  %Equal.sym(+List<U32>, VS.bt(A.quad({H}n+{NW}), F.limbs({s})), F.limbs(VS.wtake({H}n+{NW}, {s})), VS.bt_limbs({H}n+{NW}, {s})) :
    {{F.limbs({HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == _ : +List<U32>}}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add({H}n, {NW}), VB.wdr(0n, {s})), VF.app(VF.wpre({H}n, 0n, {s}), VS.wtake({NW}, VB.wdr(Nat.add({H}n, 0n), {s}))), VF.wt_pre({H}n, {NW}, 0n, {s}, hpre)) :
    {{F.limbs({HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == F.limbs(_) : +List<U32>}}
  %epo : {{F.limbs({hdrh} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == {RW} : +List<U32>}}
  %Equal.sym(List<&2, U32>, FD.array__slots(U32, MM(t, n)), {LM},
      VB.slots_mone({NW}, {H}n, 0n, DZ(n), VC.ZT(DZ(n)), t, FD.array__trep_perfect(U32, DZ(n), 0), hr0)) :
    {{F.limbs({hdrs} <> VS.wtake(Nat.double(CQ(n)), _)) == {RW} : +List<U32>}}
  %eNWc(d, n, hd, ha, hn, hc) : {{F.limbs({hdrs} <> VS.wtake(_, {LM})) == {RW} : +List<U32>}}
  %Equal.sym(List<&2, U32>, VS.wtake({NW}, VB.wdr(0n, {LM})), VS.wtake({NW}, VB.wdr({H}n, {s})),
      VB.lm_win({NW}, {H}n, 0n, FD.array__slots(U32, VC.ZT(DZ(n))), {s},
        FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({NW}, 0n), z) == True{{}} : Bool}}, VB.pw(DZ(n)), VB.len(FD.array__slots(U32, VC.ZT(DZ(n)))), Equal.sym(Nat, VB.len(FD.array__slots(U32, VC.ZT(DZ(n)))), VB.pw(DZ(n)), len_z(n)), hr0),
        hsl)) :
    {{F.limbs({hdrs} <> _) == {RW} : +List<U32>}}
  {{==}}

def hl_mm(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}}, +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}},
    +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}, +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.double(CQ(n)), FD.spec_common__length(U32, FD.array__slots(U32, MM(t, n)))) == True{{}} : Bool}}:
  %Equal.sym(Nat, FD.spec_common__length(U32, FD.array__slots(U32, MM(t, n))), VB.pw(DZ(n)),
      FD.array__slots_length(U32, DZ(n), MM(t, n), VB.mone_perfect({NW}, {H}n, 0n, DZ(n), VC.ZT(DZ(n)), t, FD.array__trep_perfect(U32, DZ(n), 0)))) :
    {{Nat.is_le(Nat.double(CQ(n)), _) == True{{}} : Bool}}
  %eNWc(d, n, hd, ha, hn, hc) : {{Nat.is_le(_, VB.pw(DZ(n))) == True{{}} : Bool}}
  FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(DZ(n))) == True{{}} : Bool}}, Nat.add({NW}, 0n), {NW}, FD.nat__add_zero({NW}), hr(d, n, hd, ha, hn, hc))

def spec_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 29n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}, +ha: {{U32.is_le({FS}, n) == True{{}} : Bool}}, +epo: {{SPO(t) == {FS} : U32}},
    +hc: {{whole(LL(n)) == True{{}} : Bool}})
    -> Decoding.decodes(Spec.{x.n}(), VW(t, n), VAL(t, n)):
  Equal.trans({M}, Codec.encoding_for_legal_type(Spec.{x.n}(), VAL(t, n)), Some{{F.limbs({HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n))))}}, Some{{VW(t, n)}},
    enc_spec(t, CQ(n), FD.array__slots(U32, MM(t, n)), hcL(n, hc), hl_mm(d, t, n, hd, hn, ha, hc)),
    Equal.cong(+List<U32>, {M}, z => Some{{z}}, F.limbs({HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))), VW(t, n), lim_eq(d, t, n, pf, hd, hn, ha, epo, hc)))

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
  Decoding.decodes(Spec.{x.n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le({FS}, n)
  +b = U32.is_eq(SPO(t), {FS})
  +c = whole(U32.sub(n, SPO(t)))
  +epo = FD.u32alg__eq_of(SPO(t), {FS}, chk_b(a, b, c, hchk))
  spec_go(d, t, n, pf, hd, hn, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {{whole(U32.sub(n, z)) == True{{}} : Bool}}, SPO(t), {FS}, epo, chk_c(a, b, c, hchk)))
''')


def fix_obj(f):
    return f['ft'].obj([f'VB.slot(t, {f["k"] + j}n)' for j in range(f['ft'].W)])


def objs_of(x, dz):
    Mz = f'VB.mone(VC.NW(LL(n)), {x.H}n, 0n, {dz}, VC.ZT({dz}), t)'
    return [fix_obj(f) if f['kind'] == 'fix' else f'O.Words{{FD.array__thaw(U32, {Mz}), LL(n)}}' for f in x.fields]


def dec_read(x, w, Tn):
    FS, H, po, K, lp = x.FS, x.H, x.po, x.K, x.lp
    KK = max(K, x.KO)
    objs = objs_of(x, 'dz')
    OBJz = f'{Tn}{{' + ', '.join(objs) + '}'
    RHS = f'(BF(t, n), {OBJz})'
    TY = f'B.Buf & {Tn}'
    w('# The reader returns the object of the buffer words (list storage: depth dz).')
    w('def rd_ok(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +dz: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},')
    w('    +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},')
    w(f'    +hs0: {{Nat.is_le(Nat.add(VC.NW(LL(n)), {H}n), VB.pw(d)) == True{{}} : Bool}}, +epo: {{SPO(t) == {FS} : U32}},')
    w('    +ez: {B.zeros(B.words_depth_u(VC.WZ(LL(n)))) == Array.new(U32, dz, 0) : Array<U32>},')
    w('    +hL3: {U32.and(LL(n), 3) == 0 : U32}, +hr0: {Nat.is_le(Nat.add(VC.NW(LL(n)), 0n), VB.pw(dz)) == True{} : Bool})')
    w(f'    -> {{{Tn}_read(BF(t, n), 0, n) == {RHS} : {TY}}}:')
    w('  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})')
    w('  +hd32 = VB.lt32(d, hd31)')
    w(f'  %Equal.sym(B.Buf & U32, B.word(BF(t, n), {po}), (BF(t, n), SPO(t)), rd32(d, t, n, {po}, {po}n, {{==}}, hd32, hk({po}n, d, n, {{==}}, hs0), pf)) :')
    w(f'    {{{Tn}_rd0(0, n, _) == {RHS} : {TY}}}')

    def read_term(f, o):
        if f['kind'] == 'fix':
            ft = f['ft']
            return f'T.{ft.p}_read(BF(t, n), U32.add(0, {f["c"]}), {ft.size})'
        return f'T.{lp}_read(BF(t, n), U32.add(0, {o}), U32.sub(n, {o}))'
    w(f'  %Equal.sym(U32, SPO(t), {FS}, epo) :')
    w(f'    {{{Tn}_rd1(0, n, _, {read_term(x.fields[0], "_")}) == {RHS} : {TY}}}')
    for j, f in enumerate(x.fields):
        args = ', '.join(['0', 'n', f'{FS}'] + objs[:j])
        if f['kind'] == 'fix':
            ft = f['ft']
            hb = (f'FD.nat__le_trans(Nat.add({ft.W}n, {f["k"]}n), {H}n, VB.pw(d), {{==}}, FD.nat__le_trans({H}n, Nat.add(VC.NW(LL(n)), {H}n), VB.pw(d), '
                  f'Order.left_below_sum(VC.NW(LL(n)), {H}n), hs0))')
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {read_term(f, FS)}, (BF(t, n), {objs[j]}),')
            w(f'      VT.rd_{ft.p}(d, t, n, U32.add(0, {f["c"]}), {f["k"]}n, {{==}}, hd, pf, {hb})) :')
        else:
            w(f'  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), U32.add(0, {FS}), LL(n)), (BF(t, n), {objs[j]}),')
            w(f'      VC.copy_in_ok(d, t, n, U32.add(0, {FS}), {H}n, LL(n), dz, pf, hd31, hdz, ez, {{==}}, {{==}}, hL3, hs0, hr0)) :')
        w(f'    {{{Tn}_rd{j + 1}({args}, _) == {RHS} : {TY}}}')
    w('  {==}')
    w('')
    OBJ = f'{Tn}{{' + ', '.join(objs_of(x, 'DZ(n)')) + '}'
    w(f'def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> {Tn}: {OBJ}')
    D = f'B.Buf & Maybe<&1, {Tn}>'
    w(ACCEPT.replace('@Tn', Tn).replace('@FS', str(FS)).replace('@D', D).replace('@KK', str(KK)).replace('@K', str(K)).replace('@po', str(po)))


ACCEPT = '''
def chk_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def chk_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def chk_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{}: h

def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32,
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +hchk: {CHK(t, n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +epo: {SPO(t) == @FS : U32}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {@Tn_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : @D}:
  +hs0 = hs(d, n, hd, ha, hn, hc)
  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})
  +hz = hdzK(d, n, hd, ha, hn, hc)
  +ez = zeros_at(B.words_depth_u(VC.WZ(LL(n))), DZ(n), VD.wdu(VC.WZ(LL(n))), FD.nat__le_trans(DZ(n), @Kn, @KKn, hz, {==}))
  %Equal.sym(B.Buf & Bool, @Tn_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, VB.lt32(d, hd31), hk(@pon, d, n, {==}, hs0), pf)) :
    {@Tn_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : @D}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {@Tn_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : @D}
  %Equal.sym(B.Buf & @Tn, @Tn_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)),
      rd_ok(d, t, n, DZ(n), pf, hd, FD.nat__le_lt_trans(DZ(n), @Kn, 31n, hz, {==}), hs0, epo, ez, VC.and3_x8(LL(n), CQ(n), eLc(n, hc)), hr(d, n, hd, ha, hn, hc))) :
    {@Tn_some(_) == (BF(t, n), Some{OBJ(t, n)}) : @D}
  {==}

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {@Tn_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : @D}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(@FS, n)
  +b = U32.is_eq(SPO(t), @FS)
  +c = whole(U32.sub(n, SPO(t)))
  +epo = FD.u32alg__eq_of(SPO(t), @FS, chk_b(a, b, c, hchk))
  acc_go(d, t, n, pf, hd, hn, hchk, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {whole(U32.sub(n, z)) == True{} : Bool}, SPO(t), @FS, epo, chk_c(a, b, c, hchk)))
'''


def dec_module_text(g, x):
    return '\n'.join(dec_module(g, x)) + '\n'


if __name__ == '__main__':
    main()
