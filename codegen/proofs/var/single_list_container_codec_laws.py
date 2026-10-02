#!/usr/bin/env python3
"""Generate the spec-connected codec laws of variable-size names.

    python3 codegen/proofs/var/single_list_container_codec_laws.py [--check]

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

(the _enc file is written by codegen/proofs/var/single_list_container_encoder_laws.py) and proofs/obj/var_fix_types.bend:
the reader and writer lemmas of the fixed field types at a symbolic word-aligned
offset. A name whose list limit is 2^16 or more writes var_codec_<X>*.bend
instead (its limit appears in the laws' types; checked with `checkq --big`).

The laws quantify over every buffer B.Buf{thaw(t), n} on a perfect word tree
t of depth d < 29 with n <= 4 2^d, and over every object whose list storage is
a perfect tree with room for its words. The generic development is
proofs/obj/v{spec,buf,u32,depth,copy,enc,enc2,fix,rej}.bend.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys
from codegen.core import generated_file_writer as writer  # noqa: E402

from codegen.impl import typed_object_runtime as G  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.proofs.laws import spec_connected_codec_laws as SL  # noqa: E402
from codegen.proofs.support import zeros_without_case_split as ZD  # noqa: E402
from codegen.proofs.support import large_limit_size_facts as LPW  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('single_list_container_codec_laws', globals())
FAMILY = ['DataColumnsByRootIdentifier', 'IndexedAttestation']
# Containers of two variable-size family fields (codegen/proofs/var/single_list_container_nested_windows.py): parent -> child.
NESTED = {'AttesterSlashing': 'IndexedAttestation'}
# Containers of fixed fields around one bit list (codegen/proofs/var/bit_list_container_codec_laws.py); their
# fixed field types are in var_fix_types.bend too.
BITC = ['Attestation', 'PendingAttestation']


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
        elif t.kind in ('bytes', 'bits') and self.s.kind == 'rec':
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


def rd_lemma(ft, db=29):
    """T.<p>_read at off = 4 i reads words i .. i + W - 1."""
    W = ft.W
    words = [sl(k) for k in range(W)]
    OBJ = ft.obj(words)
    RHS = f'(VF.BF(t, n), {OBJ})'
    TY = f'B.Buf & {ft.rep()}'
    rdn = 'rd_' if db == 29 else 'rdd_'   # rdd_: any tree depth d < 31
    L = [f'def {rdn}{ft.p}(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +e: {{U32.to_nat(off) == A.quad(i) : Nat}},',
         f'    +hd: {{Nat.is_lt(d, {db}n) == True{{}} : Bool}}, +pf: {{F.array__perfect(U32, d, t) == True{{}} : Bool}},',
         f'    +hb: {{Nat.is_le(Nat.add({W}n, i), VB.pw(d)) == True{{}} : Bool}})',
         f'    -> {{T.{ft.p}_read(VF.BF(t, n), off, {ft.size}) == {RHS} : {TY}}}:']
    w = L.append
    hd32 = 'VB.lt32(d, hd)' if db == 31 else 'VB.lt32(d, F.nat__lt_trans(d, 29n, 31n, hd, {==}))'

    def at(k):
        # (offset term, index term, equation proof) of word k
        if k == 0:
            return 'off', 'i', 'e'
        return (f'U32.add(off, {4 * k})', f'{k}n+i',
                f'VF.off_add32(off, {4 * k}, i, {k}n, d, e, {{==}}, hd, VF.in_lt({k}n, {W}n, i, VB.pw(d), {{==}}, hb))' if db == 31 else
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
            ej = (f'VF.off_add32(off, {c}, i, {k0}n, d, e, {{==}}, hd, VF.in_lt({k0}n, {W}n, i, VB.pw(d), {{==}}, hb))' if db == 31 else
                  f'VF.off_add(off, {c}, i, {k0}n, 2n+d, e, {{==}}, hd, VF.in_q({k0}n, i, d, VF.in_le(0n, {k0}n, {W}n, i, VB.pw(d), {{==}}, hb)))')
            hbj = f'VF.in_le({kt.W}n, {k0}n, {W}n, i, VB.pw(d), {{==}}, hb)'
            OBJj = kt.obj(wk)
            w(f'  %Equal.sym(B.Buf & {kt.rep()}, T.{kt.p}_read(VF.BF(t, n), {oj}, {kt.size}), (VF.BF(t, n), {OBJj}),')
            w(f'      {rdn}{kt.p}(d, t, n, {oj}, {ij}, {ej}, hd, pf, {hbj})) :')
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


def fix_module(fts, db=29):
    L = list(FIX_HEAD) + ['', '# GENERATED by single_list_container_codec_laws (codegen). Do not edit.',
                          '# Readers and writers of the fixed field types at a word-aligned offset 4 i',
                          '# (symbolic), on the array model: reads return the object of words i ..,',
                          '# writes are the run of word writes VF.updv of the object\'s words.', '']
    for ft in fts:
        L += rd_lemma(ft) + [''] + put_lemma(ft) + ['']
        if db == 31:
            L += rd_lemma(ft, 31) + ['']
    return '\n'.join(L) + '\n'



# ---- one name ------------------------------------------------------------------------------

# The decoder laws' tree depth bound: d < DB (31: every buffer the runtime allocates for n <= VB.NMAX)
DB = 31


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
    return ROOT / f'proofs/obj/{"" if is_big(x) else ""}var_codec_{x.n}{part}.bend'


def unique_text(x, n=None, D=None, db=29):
    n = n or x.n
    D = D or fname(x).name
    return TEMPLATES.render('unique_text', D=D, db=db, n=n)


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    src = RR.mono_text('fulu')
    fts = []
    xs = []
    for n in FAMILY + BITC:
        t = names[n]
        for _, ft in t.fields:
            if ft.fixed():
                for d in FT(g, ft).deps():
                    if d.p not in [x.p for x in fts]:
                        fts.append(d)
        if n in FAMILY:
            xs.append(Name(g, n, t, src))
    from codegen.proofs.support import deep_window_decode_passes as deep
    out = {ROOT / 'proofs/obj/var_fix_types.bend': deep.dify_fix(fix_module(fts, DB))}
    for x in xs:
        out[fname(x)] = dec_module_text(g, x)
        out[fname(x, '_unique')] = unique_text(x, db=DB)
        out[fname(x, '_rej')] = rej_module_text(g, x)
        out[fname(x, '_enc')] = single_list_container_encoder_laws.enc_module_text(g, x)
    for parent, child in NESTED.items():
        xc = [x for x in xs if x.n == child][0]
        pre = '' if is_big(xc) else ''
        out[fname(xc, '_win')] = single_list_container_nested_windows.win_module_text(g, xc)
        pf = ROOT / f'proofs/obj/{pre}var_codec_{parent}.bend'
        out[pf] = single_list_container_nested_windows.as_module_text(g, xc, parent)
        out[ROOT / f'proofs/obj/{pre}var_codec_{parent}_unique.bend'] = unique_text(xc, parent, pf.name, DB)
        out[ROOT / f'proofs/obj/{pre}var_codec_{parent}_rej.bend'] = single_list_container_nested_windows.as_rej_text(g, xc, parent)
        out[fname(xc, '_encw')] = nested_container_encoder_laws.encw_text(g, xc)
        out[ROOT / f'proofs/obj/{pre}var_codec_{parent}_enc.bend'] = nested_container_encoder_laws.as_enc_text(g, xc, parent)
    # the names codegen/proofs/var/multi_variable_field_codec_laws.py owns
    multi = tuple(f'{p}var_codec_{n}' for p in ('', '') for n in ('DataColumnSidecar', 'ExecutionRequests'))
    # and files another generator marks as its own (block_body_offset_windows.py, record_list_offset_windows.py, ...)
    def foreign(q):
        return writer.is_foreign(q, 'single_list_container_codec_laws')
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_codec_*.bend') if q.name.startswith(('var_codec_', 'var_codec_'))
            and not q.name.startswith(multi) and not foreign(q)]
    orphans = sorted(str(q.relative_to(ROOT)) for q in mine if q not in out)
    out = RR.rewire_out(out)
    from codegen.proofs.support import deep_window_decode_passes as deep  # the dd < 31 twins (name+W; the old names wrap them at dd < 29)
    out = deep.dify_out(out, post=deep.strict_eoff())
    if '--check' in sys.argv:
        return writer.check(out, 'stale generated variable-size laws: ', 'generated variable-size laws are current', orphans=orphans)
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


def _split_args(t):
    out, dep, cur = [], 0, ''
    for ch in t:
        if ch in '([{':
            dep += 1
        elif ch in ')]}':
            dep -= 1
        if ch == ',' and dep == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    out.append(cur.strip())
    return out


def chainify(proof):
    """spec_connected_codec_laws' walk() proof with every F.cat_fixed(Codec.parts(h, s), xs, Codec.parts(t, r), ps, ea, eb)
    as VS.chain_fixed(h, t, s, r, xs, ps, ea, eb): the same fact, stated as parts(Items{h, t}, Chain{s, r}),
    so no conversion evaluates the parts of the remaining fields (checker_findings item 2)."""
    head = 'F.cat_fixed('
    j = proof.find(head)
    if j < 0:
        return proof
    k, dep = j + len(head), 1
    while dep:
        dep += {'(': 1, ')': -1}.get(proof[k], 0)
        k += 1
    args = _split_args(proof[j + len(head):k - 1])
    assert len(args) == 6, args
    a, xs, b, ps, ea, eb = args

    def parts(t):
        assert t.startswith('Codec.parts(') and t.endswith(')'), t
        hs = _split_args(t[len('Codec.parts('):-1])
        assert len(hs) == 2, hs
        return hs
    h, sch = parts(a)
    tl, rest = parts(b)
    return (proof[:j] + f'VS.chain_fixed({h}, {tl}, {sch}, {rest}, {xs}, {ps}, {chainify(ea)}, {chainify(eb)})'
            + chainify(proof[k:]))


# spec_parts' proofs open a fixed container's parts by VSQ.seq_parts (proofs/obj/vseq.bend)
SPEC_IMPORTS = ['import ../../spec/schema.bend as SC', 'import ./vseq.bend as VSQ']


def seqwrap(text):
    """Every VS.chain_fixed(S.Sequence{I}, t, S.Container{NM, CH}, rest, xs, ps, F.aggregate_fixed(..), eb) with its
    container's parts proved as Codec.parts(S.Sequence{I}, S.Container{NM, CH}) == Codec.aggregate(Codec.parts(I, CH), ..)
    by VSQ.seq_parts first: the conversion to aggregate_fixed's statement would evaluate the container's parts
    (Codec.aggregate is strict; scratchpad checker_findings item 2b)."""
    head = 'VS.chain_fixed('
    out, i = [], 0
    while True:
        j = text.find(head, i)
        if j < 0:
            out.append(text[i:])
            return ''.join(out)
        k, dep = j + len(head), 1
        while dep:
            dep += {'(': 1, ')': -1}.get(text[k], 0)
            k += 1
        args = _split_args(text[j + len(head):k - 1])
        assert len(args) == 8, args
        h, t, s, rest, xs, ps, ea, eb = args
        ea, eb = seqwrap(ea), seqwrap(eb)
        if ea.startswith('F.aggregate_fixed(') and s.startswith('S.Container{') and h.startswith('S.Sequence{'):
            I = h[len('S.Sequence{'):-1]
            NM, CH = _split_args(s[len('S.Container{'):-1])
            ag = _split_args(ea[len('F.aggregate_fixed('):-1])
            assert len(ag) == 5 and ag[0] == f'Codec.parts({I}, {CH})', (ag[0][:80], I[:80])
            WSS, n = ag[1], ag[2]
            MP = 'Maybe<&2, +List<S.Part>>'
            RHS = f'Some{{[S.Fixed{{F.flat({WSS})}}]}}'
            ea = (f'Equal.trans({MP}, Codec.parts({h}, {s}), Codec.aggregate(Codec.parts({I}, {CH}), SC.fixed_size({CH})), {RHS}, '
                  f'VSQ.seq_parts({h}, {s}, {I}, {NM}, {CH}, {{==}}, {{==}}), '
                  f'FD.logic__subst(Maybe<&2, Nat>, z => {{Codec.aggregate(Codec.parts({I}, {CH}), z) == {RHS} : {MP}}}, Some{{{n}}}, SC.fixed_size({CH}), {{==}}, {ea}))')
        out.append(text[i:j] + f'VS.chain_fixed({h}, {t}, {s}, {rest}, {xs}, {ps}, {ea}, {eb})')
        i = k


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
                    'proof': chainify(subst_words(node.proof, mp)), 'words': [mp[int(w[1:])] for w in node.words]})
    return out


def dec_module(g, x):
    n, FS, H, po, LIM, K, lp = x.n, x.FS, x.H, x.po, x.LIM, x.K, x.lp
    LP = LPW.LimPow(spec_lim(x.n, [f['kind'] for f in x.fields].index('var')))
    L = list(DEC_HEAD) + LP.imports() + SPEC_IMPORTS + ['', f'# GENERATED by single_list_container_codec_laws (codegen). Do not edit.',
                          f'# {n}: the validator, the decoder, and the spec relation of the decoded value',
                          f'# (see the module docstring of codegen/proofs/var/single_list_container_codec_laws.py).', '']
    w = L.append
    Tn = f'T.{n}'
    w(TEMPLATES.render('dec_module', LIM=LIM, po=po, Tn=Tn, FS=FS))
    # zeros
    w(ZD.zeros_at_text(max(K, x.KO), 'FD'))
    X8L = 8 * LIM
    Y = 31 + X8L
    KL = ceil_log2(Y)
    assert KL < 31
    RB = (Y >> 2) + 8
    # The closed limit facts: `{==}` for a small limit, symbolic (codegen/proofs/support/large_limit_size_facts.py) for 2^p.
    if LP.big:
        assert LP.M == LIM
        Y31 = LP.add(31, LP.x8())
        K_HY = LP.le(Y31, KL)
        K_WZ = LP.le_pow2n(LP.addr(LP.rng2(Y31), 8), K)
    else:
        K_HY = K_WZ = '{==}'
    w(TEMPLATES.render('dec_module_2', FS=FS, H=H, LIM=LIM, KL=KL, K_HY=K_HY, K=K, K_WZ=K_WZ))
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


def lim_imports(x):
    """The import spec_parts' proofs need for x's list limit (codegen/proofs/support/large_limit_size_facts.py)."""
    return LPW.LimPow(spec_lim(x.n, [f['kind'] for f in x.fields].index('var'))).imports()


def spec_parts(g, x, word, k='k', W='W'):
    """(ITEMS, CHAIN, PL, CAT, PRE, POST, HDR) of name x over header words word(k):
    the spec value items and schema chain, the parts list, the proof that the
    parts of the items are that list, the fixed word lists before and after
    the variable field, and the header words (the offset is FS)."""
    nodes = field_nodes(g, x, word)
    LIMN = spec_lim(x.n, [f['kind'] for f in x.fields].index('var'))
    YS = f'VS.wtake(Nat.double({k}), {W})'
    LP = LPW.LimPow(LIMN)
    HFIT = LP.fits(LP.x8(), LP.x8().s) if LP.big else '{==}'
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
        # VS.chain_fixed / chain_var state exactly parts(Items{h, t}, Chain{s, rest}): no conversion
        # unfolds Codec.parts of the remaining fields (checker_findings item 2).
        if f['kind'] == 'fix':
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs({YS}), {rest}, '
                f'VS.list_u64_parts({k}, {W}, {LIMN}, hk, {HFIT}, hl), {cat(i + 1)})')
    vi = [f['kind'] for f in x.fields].index('var')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(x.FS)]
    return items(0), chain(0), '[' + ', '.join(parts) + ']', seqwrap(cat(0)), PRE, POST, hdr, LIMN, YS


def dec_spec(g, x, w, Tn):
    FS, H, po = x.FS, x.H, x.po
    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, LIMN, YS = spec_parts(g, x, lambda k: f'VB.slot(t, {k}n)')
    LP = LPW.LimPow(LIMN)
    K_FIT = LP.fits(LP.add(FS, LP.x8()), LP.bound(LP.add(FS, LP.x8()))) if LP.big else '{==}'
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
    w(TEMPLATES.render('dec_spec', ITEMS=ITEMS, LIMN=LIMN, x=x, RHS=RHS, M=M, YS=YS, PRE=PRE, POST=POST, FS=FS, K_FIT=K_FIT, MP=MP, CHAIN=CHAIN, PL=PL, CAT=CAT, ENCR=ENCR, s=s, H=H, NW=NW, HDR=HDR, hdrh=hdrh, RW=RW, LM=LM, hdrs=hdrs))


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
    w('    +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},')
    w(f'    +hs0: {{Nat.is_le(Nat.add(VC.NW(LL(n)), {H}n), VB.pw(d)) == True{{}} : Bool}}, +epo: {{SPO(t) == {FS} : U32}},')
    w('    +ez: {B.zeros(B.words_depth_u(VC.WZ(LL(n)))) == Array.new(U32, dz, 0) : Array<U32>},')
    w('    +hL3: {U32.and(LL(n), 3) == 0 : U32}, +hr0: {Nat.is_le(Nat.add(VC.NW(LL(n)), 0n), VB.pw(dz)) == True{} : Bool})')
    w(f'    -> {{{Tn}_read(BF(t, n), 0, n) == {RHS} : {TY}}}:')
    w('  +hd31 = hd')
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
            w(f'      VT.rdd_{ft.p}(d, t, n, U32.add(0, {f["c"]}), {f["k"]}n, {{==}}, hd, pf, {hb})) :')
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


ACCEPT = TEMPLATES.text('ACCEPT')


def dec_module_text(g, x):
    return '\n'.join(dec_module(g, x)) + '\n'


# ---- the rejection laws of one name ------------------------------------------------------------

VALUE_CTORS = [('BooleanValue', ['b0']), ('UnsignedValue', ['u0']), ('BytesValue', ['xs0']), ('BitsValue', ['bs0']),
               ('Sequence', ['it0']), ('Items', ['hd0', 'tl0']), ('EmptyItems', []), ('Selected', ['sel0', 'sv0']), ('NullValue', [])]


def spec_schemas(n):
    """Spec schema def names of name n's fields, and the element schema of its list field."""
    src = (ROOT / 'spec/fulu_schemas.bend').read_text()
    defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.*)$', src, re.M))
    body = defs[n]
    while re.fullmatch(r'Schema\d+\(\)', body):
        body = defs[body[:-2]]
    kids = re.findall(r'T\.Chain\{(Schema\d+)\(\)', body)
    elem = None
    for k in kids:
        m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), .*\}', defs[k])
        if m:
            elem = m.group(1)
    return kids, elem


def rej_module_text(g, x):
    n, FS, H, po, LIM = x.n, x.FS, x.H, x.po, x.LIM
    P = 4 * po
    LIMN = spec_lim(n, [f['kind'] for f in x.fields].index('var'))
    kids, elem = spec_schemas(n)
    m = len(x.fields)
    Tn = f'T.{n}'
    fsb = [FS & 255, (FS >> 8) & 255, (FS >> 16) & 255, (FS >> 24) & 255]
    FSL = '[' + ', '.join(map(str, fsb)) + ']'
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T',
         'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P', 'import ../compact/found.bend as F',
         'import ../compact/arith.bend as A', 'import ../compact/bits.bend as BT', 'import ../../proofs/nat_order.bend as Order',
         'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/nat_bytes.bend as N',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
         'import ./spec_fixed.bend as FX', 'import ./dk.bend as DK', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
         'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vrej.bend as VR', f'import ./{fname(x).name} as DC', '',
         '# GENERATED by single_list_container_codec_laws (codegen). Do not edit.',
         f'# Rejection of {n} is exactly the complement of the spec image: every byte',
         '# string the spec relates to some value has the shape the validator checks',
         '# (inv_v), so when CHK(t, n) is False no value is related to the buffer\'s',
         '# bytes (decode_reject), and the decoder returns None (decode_none).', '']
    w = L.append
    MB = 'Maybe<&2, +List<U32>>'
    w(f'def FACTS(bs: +List<U32>) -> Type:')
    w(f'  {{VS.bt(4n, VS.bdr({P}n, bs)) == {FSL} : +List<U32>}} & DK.Ex(Nat, k => DK.P2({{List.length(&2, U32, bs) == Nat.add({FS}n, VS.x8(k)) : Nat}}, {{Nat.is_le(k, {LIMN}) == True{{}} : Bool}}))')
    w('')

    def absurd(e='e'):
        return f'Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, {e}))'

    def match_value(var, keep, body):
        """match var: case keep -> body; other constructors absurd."""
        out = [f'  match {var}:']
        for c, args in VALUE_CTORS:
            pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
            if c == keep[0]:
                pat = f'S.{c}{{' + ', '.join('+' + a for a in keep[1]) + '}'
                out.append(f'    case {pat}: {body}')
            else:
                out.append(f'    case {pat}: {absurd()}')
        return out

    # the parts before stage i, as parameter declarations, argument names and part terms
    def prefix(i):
        decl, args, parts = [], [], []
        for j, f in enumerate(x.fields[:i]):
            if f['kind'] == 'fix':
                decl += [f'+xs{j}: +List<U32>', f'+lx{j}: {{List.length(&2, U32, xs{j}) == {f["ft"].size}n : Nat}}']
                args += [f'xs{j}', f'lx{j}']
                parts.append(f'S.Fixed{{xs{j}}}')
            else:
                decl += ['+ys: +List<U32>', '+k: Nat', '+lys: {List.length(&2, U32, ys) == VS.x8(k) : Nat}',
                         f'+hk: {{Nat.is_le(k, {LIMN}) == True{{}} : Bool}}']
                args += ['ys', 'k', 'lys', 'hk']
                parts.append('S.Variable{ys}')
        return decl, args, parts

    def CC(parts, X):
        for p in reversed(parts):
            X = f'Codec.concatenate(Some{{[{p}]}}, {X})'
        return X

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{Spec.{kids[i]}(), {chain(i + 1)}}}'

    def E(parts, X):
        return f'{{Codec.bytes(Codec.aggregate({CC(parts, X)}, None{{}})) == Some{{bs}} : {MB}}}'

    def sig(name, decl, extra):
        return f'def {name}(' + ', '.join(decl + extra) + ') -> FACTS(bs):'

    vi = [f['kind'] for f in x.fields].index('var')
    pre = [j for j in range(vi)]
    post = [j for j in range(vi + 1, m)]
    PRE = '[' + ', '.join(f'xs{j}' for j in pre) + ']'
    POST = '[' + ', '.join(f'xs{j}' for j in post) + ']'
    decl_m, args_m, parts_m = prefix(m)
    Pz = sum(x.fields[j]['ft'].size for j in pre)
    Qz = sum(x.fields[j]['ft'].size for j in post)
    assert Pz == P and Pz + 4 + Qz == FS

    # lens of the fixed byte lists
    def lens_eq(name, idx, total):
        w(f'def {name}(' + ', '.join(decl_m) + f') -> {{VR.lens([' + ', '.join(f'xs{j}' for j in idx) + f']) == {total}n : Nat}}:')
        cur = [f'List.length(&2, U32, xs{j})' for j in idx]
        for a, j in enumerate(idx):
            def term(c):
                t = '0n'
                for q in reversed(c):
                    t = f'Nat.add({q}, {t})'
                return t
            mot = cur[:a] + ['_'] + cur[a + 1:]
            w(f'  %Equal.sym(Nat, List.length(&2, U32, xs{j}), {x.fields[j]["ft"].size}n, lx{j}) : {{{term(mot)} == {total}n : Nat}}')
            cur[a] = f'{x.fields[j]["ft"].size}n'
        w('  {==}')
        w('')
    lens_eq('eP', pre, Pz)
    lens_eq('eQ', post, Qz)
    ALL = ', '.join(args_m)
    OUT = f'VR.OUT({PRE}, ys, {POST})'
    w(f'def f_off(' + ', '.join(decl_m) + f') -> {{VS.bt(4n, VS.bdr({P}n, {OUT})) == {FSL} : +List<U32>}}:')
    w(f'  %eP({ALL}) : {{VS.bt(4n, VS.bdr(_, {OUT})) == N.digits(4n, Nat.add(_, 4n+{Qz}n)) : +List<U32>}}')
    w(f'  %eQ({ALL}) : {{VS.bt(4n, VS.bdr(VR.lens({PRE}), {OUT})) == N.digits(4n, Nat.add(VR.lens({PRE}), 4n+_)) : +List<U32>}}')
    w(f'  VR.out_off({PRE}, ys, {POST})')
    w('')
    w(f'def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FS}n, VS.x8(k)) : Nat}}:')
    w(f'  %eP({ALL}) : {{List.length(&2, U32, {OUT}) == Nat.add(Nat.add(_, 4n+{Qz}n), VS.x8(k)) : Nat}}')
    w(f'  %eQ({ALL}) : {{List.length(&2, U32, {OUT}) == Nat.add(Nat.add(VR.lens({PRE}), 4n+_), VS.x8(k)) : Nat}}')
    w(f'  %lys : {{List.length(&2, U32, {OUT}) == Nat.add(VR.FZ({PRE}, {POST}), _) : Nat}}')
    w(f'  VR.out_len({PRE}, ys, {POST})')
    w('')
    PLIST = '[' + ', '.join(parts_m) + ']'
    w(sig('inv_fin', decl_m, ['+bs: +List<U32>', '+b5: Bool',
          f'+e: {{Codec.bytes(Codec.one(SP.optional(b5, {OUT}), None{{}})) == Some{{bs}} : {MB}}}']))
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w('    case True{}:')
    w(f'      %F.logic__some_inj(+List<U32>, {OUT}, bs, e) : FACTS(_)')
    w(f'      (f_off({ALL}), (k, (f_len({ALL}), hk)))')
    w('')
    # stages, last first (no forward references)
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
        if f['kind'] == 'fix':
            z = f['ft'].size
            w(sig(f'fp{i}', decl, ['+ps: +List<S.Part>', f'hf: DF.single(Some{{{z}n}}, ps)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            w('  match ps:')
            w('    case Nil{}: Empty.absurd(FACTS(bs), hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: st{i + 1}({A}xs, Equal.sym(Nat, {z}n, List.length(&2, U32, xs), F.logic__some_inj(Nat, {z}n, List.length(&2, U32, xs), hf)), t, bs, e)')
            w(f'    case Con{{S.Variable{{+xs}}, Nil{{}}}}: Empty.absurd(FACTS(bs), F.logic__none_some(Nat, {z}n, Equal.sym(Maybe<&2, Nat>, Some{{{z}n}}, None{{}}, hf)))')
            w('    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)')
            w('    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)')
            w('')
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({A}ps, hf, t, bs, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({A}Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), t, bs, e)')
            w('')
        else:
            RE = f'S.Repeat{{Spec.{elem}()}}'
            HK = f'+hk: {{Nat.is_le(Codec.count(its), {LIMN}) == True{{}} : Bool}}'
            w(sig(f'vm4', decl, ['+its: S.Value', '+t: S.Value', '+bs: +List<U32>', HK, '+ps: +List<S.Part>',
                                 f'+em3: {{Codec.parts(its, {RE}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}}', f'+m4: {MB}',
                                 f'+em4: {{Layout.encoding(ps) == m4 : {MB}}}',
                                 '+e: ' + E(parts, f'Codec.concatenate(Codec.one(m4, None{{}}), {nxt})')]))
            w('  match m4:')
            w(f'    case None{{}}: {absurd()}')
            w('    case Some{+ys}:')
            w('      +lys = Equal.trans(Nat, List.length(&2, U32, ys), Layout.fixed_size(ps), VS.x8(Codec.count(its)),')
            w('        VS.enc_len(ps, ys, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)), em4),')
            w('        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)))')
            w(f'      st{i + 1}({A}ys, Codec.count(its), lys, hk, t, bs, e)')
            w('')
            w(sig('vm3', decl, ['+its: S.Value', '+t: S.Value', '+bs: +List<U32>', HK, '+m3: Maybe<&2, +List<S.Part>>',
                                f'+em3: {{Codec.parts(its, {RE}) == m3 : Maybe<&2, +List<S.Part>>}}',
                                '+e: ' + E(parts, f'Codec.concatenate(Codec.aggregate(m3, None{{}}), {nxt})')]))
            w('  match m3:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: vm4({A}its, t, bs, hk, ps, em3, Layout.encoding(ps), {{==}}, e)')
            w('')
            w(sig('vb', decl, ['+its: S.Value', '+t: S.Value', '+bs: +List<U32>', '+b2: Bool',
                               f'+eb2: {{Nat.is_le(Codec.count(its), {LIMN}) == b2 : Bool}}',
                               '+e: ' + E(parts, f'Codec.concatenate(Codec.require(b2, Codec.aggregate(Codec.parts(its, {RE}), None{{}})), {nxt})')]))
            w('  match b2:')
            w(f'    case False{{}}: {absurd()}')
            w(f'    case True{{}}: vm3({A}its, t, bs, eb2, Codec.parts(its, {RE}), {{==}}, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+t: S.Value', '+bs: +List<U32>',
                                   '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            L.extend(match_value('h', ('Sequence', ['its']), f'vb({A}its, t, bs, Nat.is_le(Codec.count(its), {LIMN}), {{==}}, e)'))
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+bs: +List<U32>', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 't']), f'fd{i}({A}h, t, bs, e)'))
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
    R = FS - P  # bytes from the offset word to the end of the fixed part
    w(REJ.replace('@Tn', Tn).replace('@n', n).replace('@FSL', FSL).replace('@FS', str(FS)).replace('@PO', str(po)).replace('@P', str(P))
        .replace('@H', str(H)).replace('@R4', str(R - 4)).replace('@R', str(R)).replace('@LIMN', LIMN).replace('@LIM', str(LIM))
        .replace('@B0', str(fsb[0])).replace('@B1', str(fsb[1])).replace('@B2', str(fsb[2])).replace('@B3', str(fsb[3])))
    return '\n'.join(L) + '\n'


REJ = TEMPLATES.text('REJ')


from codegen.proofs.var import single_list_container_encoder_laws as single_list_container_encoder_laws  # noqa: E402  (uses the definitions above)
from codegen.proofs.var import single_list_container_nested_windows as single_list_container_nested_windows  # noqa: E402
from codegen.proofs.var import nested_container_encoder_laws as nested_container_encoder_laws  # noqa: E402


if __name__ == '__main__':
    main()
