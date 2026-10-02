#!/usr/bin/env python3
"""Laws that pin the write start, the length constants and the reported sizes of the generated encoders, and the
read offset of the record decoders (docs/mutation_testing/MUTATION_PROOFS.md, section 6: mutation round 2).

    python3 codegen/proofs/mutation_coverage/write_start_and_sizes.py [--check]

proofs/mutation_coverage/size/<X>.bend, one module per name; object_api_coverage_gate files `<X>_ms_<tag>` in the name's encode facade.

  <X>_ms_serdepth   {T.X_serialize(o) == T.X_senc_out(T.P_putk(O.out_at(Kn), 0, o))}      (symbolic in o)
      the checked serializer of a fixed-size name writes at byte 0 of an output of exactly the depth K that holds
      the encoding (2^K words >= the size in bytes / 4). A start 1 or a depth K-1 (the writer would run past the
      array) changes the statement; K is the least such depth for the size N of the schema / of the validity pass
      (the generator stops if the generated file disagrees).
  <X>_ms_senc       {T.X_senc_out((out, (o, 0))) == (o, O.encoded(B.Buf{out, N}))}        (symbolic in out, o)
      the length the serializer reports for a valid value is N.
  <X>_ms_encout     {T.X_enc_out((out, o)) == (o, B.Buf{out, N})}                         (symbolic)
      the length the unchecked encoder reports is N.
  <X>_ms_size       {snd(T.X_size(T.X_default())) == MIN}                                   (by computation)
      the size pass of a Fulu name reports, for the default object, the schema's least encoded size
      (the fixed part plus 4 per variable field plus what the variable fields' defaults encode to).
  <X>_ms_bxsize     {snd(T.X_bx_size(O.BNone{})) == 0}                                       (symbolic)
  <X>_ms_build      {T.X_build(E, N) == (E, w)}     E = B.Buf{T.P_put(O.out_at(4n),0,w),N}, w the record's seed   (by computation)
  <X>_ms_dec        {T.X_decode(E, N) == (E, Some{w})}                                       (by computation)
      the record readers read at offset 0 (a word read at `off + 4` of the second word, ...).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import mutation_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.collections.object_field_access_laws import qual  # noqa: E402
from codegen.proofs.mutation_coverage import encoder_constants as MC  # noqa: E402

SIZE_MAX = 4096   # bytes: the default object of a `_ms_size` law is computed


def depth_for_bytes(n):
    k = 0
    while (1 << k) < (n + 3) // 4:
        k += 1
    return k


def max_size(t):
    """the greatest encoded size of a value of the schema type t (None for the progressive and union forms)"""
    if t.fixed():
        return t.fixed_size()
    k = t.kind
    if k == 'bytelist':
        return t.size
    if k == 'bitlist':
        return (t.size + 8) // 8
    if k in ('list', 'vector'):
        e = max_size(t.elem)
        return None if e is None else t.size * (e + (0 if t.elem.fixed() else 4))
    if k == 'container':
        parts = [(c.fixed_size() if c.fixed() else None, c) for _, c in t.fields]
        tot = 0
        for fx, c in parts:
            if fx is not None:
                tot += fx
            else:
                m = max_size(c)
                if m is None:
                    return None
                tot += 4 + m
        return tot
    return None


def type_decl(tx, R):
    """[(constructor, [(field, type)])] of the type R in the runtime text"""
    m = re.search(rf'^type {re.escape(R)} is Type:\n((?:  [^\n]+\n)+)', tx.text, re.M)
    if not m:
        return None
    out = []
    for line in m.group(1).strip('\n').split('\n'):
        mm = re.fullmatch(r'\s*(\w+)\{(.*)\}', line)
        if not mm:
            return None
        out.append((mm.group(1), [(a.split(':', 1)[0].strip(), a.split(':', 1)[1].strip()) for a in MC.split_top_args(mm.group(2))] if mm.group(2) else []))
    return out


def decl_ok(tx, R):
    return type_decl(tx, R) is not None


def object_witness(tx, X, R):
    """a value of the container X with every seeded field set (its seed, else the default with setters)"""
    sd = f'{X}_seed'
    if tx.get(sd) and tx.get(sd)[1] == R:
        return f'T.{sd}(2271560481)'
    d = tx.get(f'{X}_default')
    if not (d and d[1] == R):
        return None
    w, n = f'T.{X}_default()', 0
    for nm in sorted(tx.blk):
        if re.fullmatch(rf'{re.escape(X)}_set_\w+', nm):
            sg = tx.get(nm)
            if sg and len(sg[0]) == 2 and sg[1] == R and MC.ptype(sg[0][0]) == R and MC.ptype(sg[0][1]) in MC.seeds_of(tx):
                w = f'T.{nm}({w}, T.{MC.seeds_of(tx)[MC.ptype(sg[0][1])]}({2271560481 + 17 * n}))'
                n += 1
    return w if n else None


def laws_of(tx, X, syms):
    laws = []
    enc = tx.get(f'{X}_encode')
    if enc is None:
        return laws
    R = MC.ptype(enc[0][0])
    QR = qual(R)
    fidx = syms.get(f'{X}_encode')
    here = lambda sym: syms.get(sym) == fidx   # noqa: E731
    # ---- serializer depth, write start, reported lengths ------------------------------------------
    ser = tx.get(f'{X}_serialize')
    so = tx.blk.get(f'{X}_senc_out', '')
    sp = tx.blk.get(f'{X}_senc_put', '')
    mn = re.search(r'O\.ser_done\(O\.is_poisoned\(fl\), (\d+), out\)', so + '\n' + sp)
    mx = None
    if ser and not mn:
        import codegen.proofs.mutation_coverage.encoder_constants as _mc
        _mc.default_size(X)
        t = _mc.SCHEMA.get(X)
        mx = None if t is None else max_size(t)
    if ser and (mn or mx) and ser[1].endswith(' & O.Encoded'):
        N = int(mn.group(1)) if mn else mx
        m = re.fullmatch(rf'({re.escape(X)}_senc_(?:out|put))\((\w+)_putk\(O\.out_at\((\d+)n\), 0, o\)\)', ser[2])
        if m:
            wrap, P, K = m.group(1), m.group(2), int(m.group(3))
            if K != depth_for_bytes(N):
                raise SystemExit(f'{X}: out_at({K}n) is not the least depth for {N} bytes ({depth_for_bytes(N)}n)')
            Kn = depth_for_bytes(N)
            laws.append(('serdepth',
                         f'def {X}_ms_serdepth(o: {QR})\n    -> {{T.{X}_serialize(o) == T.{wrap}(T.{P}_putk(O.out_at({Kn}n), 0, o)) : {QR} & O.Encoded}}:\n  {{==}}'))
        for nm in (('senc_out', 'senc_put') if mn else ()):
            g = tx.get(f'{X}_{nm}')
            if g and g[0] == [f'pair: Array<U32> & ({R} & U32)'] and 'O.ser_done(O.is_poisoned(fl)' in tx.blk[f'{X}_{nm}']:
                laws.append(('senc',
                             f'def {X}_ms_{nm}(out: Array<U32>, o: {QR})\n    -> {{T.{X}_{nm}((out, (o, 0))) == (o, O.encoded(B.Buf{{out, {N}}})) : {QR} & O.Encoded}}:\n  {{==}}'))
    eo = tx.get(f'{X}_enc_out')
    if eo and re.fullmatch(r'pair: Array<U32> & ' + re.escape(R), ', '.join(eo[0])):
        mo = re.search(r'\(o, O\.out_done\((\d+), out\)\)$', tx.blk[f'{X}_enc_out'])
        if mo:
            laws.append(('encout',
                         f'def {X}_ms_encout(out: Array<U32>, o: {QR})\n    -> {{T.{X}_enc_out((out, o)) == (o, B.Buf{{out, {mo.group(1)}}}) : {QR} & B.Buf}}:\n  {{==}}'))
    # ---- reported size -------------------------------------------------------------------------------
    sz = tx.get(f'{X}_size')
    dflt = tx.get(f'{X}_default')
    ms = MC.default_size(X)
    if sz and sz[1] == f'{R} & U32' and dflt and dflt[1] == R and ms is not None and ms <= SIZE_MAX:
        laws.append(('size',
                     f'def {X}_ms_size()\n    -> {{Pair.snd({QR}, U32, T.{X}_size(T.{X}_default())) == {ms} : U32}}:\n  {{==}}'))
    for nm in sorted(tx.blk):
        m = re.fullmatch(r'(\w+)_bx_size', nm)
        if m and here(nm) and re.search(r'case O\.BNone\{\}: \([\w.()]+, 0\)$', tx.blk[nm]):
            sg = tx.get(nm)
            Bx = MC.ptype(sg[0][0])
            QB = 'O.Boxed<' + qual(Bx[len('O.Boxed<'):-1]) + '>'
            laws.append((f'bxsize_{m.group(1)}',
                         f'def {X}_ms_bxsize_{m.group(1)}()\n    -> {{Pair.snd({QB}, U32, T.{nm}(O.BNone{{}})) == 0 : U32}}:\n  {{==}}'))
    # ---- the size pass of a container, symbolic in its fixed fields ----------------------------------
    t = MC.SCHEMA.get(X) if MC.SCHEMA else None
    if sz and sz[1] == f'{R} & U32' and dflt and dflt[1] == R and t is not None and t.kind == 'container' and not (ms is not None and ms <= SIZE_MAX):
        decl = type_decl(tx, R)
        body = re.fullmatch(rf'{re.escape(R)}\{{(.*)\}}', dflt[2])
        if decl and len(decl) == 1 and body:
            dexpr = MC.split_top_args(body.group(1))
            flds = decl[0][1]
            if len(dexpr) == len(flds) == len(t.fields):
                params, args = [], []
                for (fn, ft), de, (_, st) in zip(flds, dexpr, t.fields):
                    if st.fixed():
                        params.append(f'{fn}: {qual(ft)}')
                        args.append(fn)
                    else:
                        args.append('T.' + de if re.match(r'[A-Za-z_]\w*\(', de) and '.' not in de.split('(')[0] else de)
                laws.append(('sizesym',
                             f'def {X}_ms_sizesym({", ".join(params)})\n    -> {{Pair.snd({QR}, U32, T.{X}_size(T.{R}{{{", ".join(args)}}})) == {MC.min_size(t)} : U32}}:\n  {{==}}'))
    # ---- the checked writer against the unchecked one (fixed-size containers) ---------------------------
    pk, pu = tx.get(f'{X}_putk'), tx.get(f'{X}_put')
    if (t is not None and t.kind == 'container' and t.fixed() and t.fixed_size() <= SIZE_MAX and pk and pu and decl_ok(tx, R)
            and pk[1] == f'Array<U32> & ({R} & U32)' and pu[1] == f'Array<U32> & {R}'):
        w = object_witness(tx, X, R)
        if w:
            # the words at every field's first and last byte do not depend on the capacity of the output array
            # (a write at `pos - k` instead of `pos + k` lands on the same word when the capacity is 2k bytes)
            js, off = [], 0
            for _, ft in t.fields:
                sz_ = ft.fixed_size()
                js += [off // 4, (off + sz_ - 1) // 4]
                off += sz_
            js = sorted(set(js))
            K0 = depth_for_bytes(t.fixed_size())
            get = lambda k, j: f'Pair.snd(Array<U32>, U32, Array.get(U32, Pair.fst(Array<U32>, ({QR} & U32), T.{X}_putk(O.out_at({k}n), 0, {w})), {j}))'   # noqa: E731
            nest_ = lambda items: items[0] if len(items) == 1 else f'({items[0]}, {nest_(items[1:])})'   # noqa: E731
            nt = lambda n: 'U32' if n == 1 else f'U32 & ({nt(n - 1)})'   # noqa: E731
            laws.append(('putk', f'def {X}_ms_putk()\n    -> {{{nest_([get(K0, j) for j in js])} == {nest_([get(K0 + 2, j) for j in js])} : {nt(len(js))}}}:\n  {{==}}'))
    # ---- union arms ---------------------------------------------------------------------------------
    decl = type_decl(tx, R)
    if decl and all(re.fullmatch(r'\w+_c\d+', c_) for c_, _ in decl) and tx.get(f'{X}_decode') and tx.get(f'{X}_encode'):
        RD = tx.get(f'{X}_decode')[1].replace(R, QR)
        for ci, (ctor, fl) in enumerate(decl):
            if len(fl) != 1:
                continue
            PT = fl[0][1]
            sd = MC.seeds_of(tx).get(PT)
            if not sd:        # a payload without a seed (a list's default) decodes to another capacity: not structurally equal
                continue
            pw = f'T.{sd}(2271560481)'
            w = f'T.{ctor}{{{pw}}}'
            E = f'Pair.snd({QR}, B.Buf, T.{X}_encode({w}))'
            if ci == 0 and tx.get(f'{X}_put') and tx.get(f'{X}_read'):
                # a selector that names no arm (bit 7 set): the reader falls through every arm to the first (decode never
                # gets here, `ok` refuses it; `X_read` / `X_build` do not check)
                A = f'Pair.fst(Array<U32>, {QR}, T.{X}_put(O.out_at(3n), 0, {w}))'
                Nn = f'Pair.snd(B.Buf, U32, B.size({E}))'
                Eb = f'B.Buf{{O.or_word({A}, 0, 128), {Nn}}}'
                laws.append(('armbad', f'def {X}_ms_armbad()\n    -> {{T.{X}_read({Eb}, 0, {Nn}) == ({Eb}, {w}) : B.Buf & {QR}}}:\n  {{==}}'))
            laws.append((f'arm{ci}', f'def {X}_ms_arm{ci}()\n    -> {{T.{X}_decode({E}, Pair.snd(B.Buf, U32, B.size({E}))) == ({E}, Some{{{w}}}) : {RD}}}:\n  {{==}}'))
    # ---- record readers --------------------------------------------------------------------------------
    mr = re.search(r'\b(\w+)_put\(O\.out_at\((\d+)n\), 0, o\)', enc[2])
    nb = re.search(r'O\.out_done\((\d+), ', enc[2])
    if mr and nb:
        P, N = mr.group(1), int(nb.group(1))
        seed = tx.get(f'{P}_seed')
        if seed and seed[1] == R:
            w = f'T.{P}_seed(2271560481)'
            E = f'B.Buf{{T.{P}_put(O.out_at({depth_for_bytes(N) + 2}n), 0, {w}), {N}}}'   # slack: a wrapped read index must not land on a written word
            dec = tx.get(f'{X}_decode')
            bd = tx.get(f'{X}_build')
            if bd and bd[2] == f'{P}_read(buf, 0, size)' and bd[1] == f'B.Buf & {R}':
                laws.append(('build', f'def {X}_ms_build()\n    -> {{T.{X}_build({E}, {N}) == ({E}, {w}) : B.Buf & {QR}}}:\n  {{==}}'))
            if dec and dec[1].startswith('B.Buf & Maybe<'):
                # two seeds: a bit vector's masked words are all nonzero for at least one of them
                ws = [f'T.{P}_seed({x})' for x in (2271560481, 2271560482)]
                Es = [f'B.Buf{{T.{P}_put(O.out_at({depth_for_bytes(N) + 2}n), 0, {v}), {N}}}' for v in ws]
                RD = dec[1].replace(R, QR)
                laws.append(('dec', f'def {X}_ms_dec()\n    -> {{(T.{X}_decode({Es[0]}, {N}), T.{X}_decode({Es[1]}, {N})) == '
                                    f'(({Es[0]}, Some{{{ws[0]}}}), ({Es[1]}, Some{{{ws[1]}}})) : ({RD}) & ({RD})}}:\n  {{==}}'))
    return laws


def module(tmod, by):
    out = {}
    for X, laws in by.items():
        L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
             f'import ../../types/{tmod}.bend as T', '', writer.header('write_start_and_sizes'),
             f'# {X}: write start, length constants, reported sizes and read offsets (mutation round 2; docs/mutation_testing/MUTATION_PROOFS.md, section 6)', '']
        for tag, text in laws:
            L += [text, '']
        out[LAYOUT.module_path('size', X)] = '\n'.join(L)
    return out


def outputs():
    files, syms, monos = RR.index()
    out, seen = {}, set()
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        names = sorted(set(re.findall(r'^def (\w+)_encode\(', tx.text, re.M)) - seen)
        by = {}
        for X in names:
            laws = laws_of(tx, X, syms)
            if laws:
                by[X] = laws
        seen |= set(names)
        out.update(module(tmod, by))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'write_start_and_sizes', ('size',), 'stale write start laws: ', 'write start laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules, {sum(t.count(chr(10) + "def ") for t in out.values())} laws')


if __name__ == '__main__':
    main()
