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


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    fts = []
    for n in FAMILY:
        t = names[n]
        for fname, ft in t.fields:
            if ft.fixed():
                for d in FT(g, ft).deps():
                    if d.p not in [x.p for x in fts]:
                        fts.append(d)
    out = {ROOT / 'proofs/obj/var_fix_types.bend': fix_module(fts)}
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, text in out.items() if not p.exists() or p.read_text() != text]
        if stale:
            print('stale generated variable-size laws: ' + ', '.join(stale))
            sys.exit(1)
        print('generated variable-size laws are current')
        return
    for p, text in out.items():
        p.write_text(text)
    print(f'{len(fts)} fixed field types')


if __name__ == '__main__':
    main()
