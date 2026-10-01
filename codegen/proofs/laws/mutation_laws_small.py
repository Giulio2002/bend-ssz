#!/usr/bin/env python3
"""Laws that pin the write start, the length constants and the reported sizes of the generated encoders, and the
read offset of the record decoders (docs/MUTATION_PROOFS.md, section 6: mutation round 2).

    python3 codegen/proofs/laws/mutation_laws_small.py [--check]

proofs/obj/mutsmall_<X>.bend, one module per name; api_gate files `<X>_ms_<tag>` in the name's encode facade.

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

from codegen.core import writer  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402
from codegen.proofs.laws import mutation_laws_const as MC  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

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
        import codegen.proofs.laws.mutation_laws_const as _mc
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
             f'import ../../types/{tmod}.bend as T', '', writer.header('mutation_laws_small'),
             f'# {X}: write start, length constants, reported sizes and read offsets (mutation round 2; docs/MUTATION_PROOFS.md, section 6)', '']
        for tag, text in laws:
            L += [text, '']
        out[ROOT / f'proofs/obj/mutsmall_{X}.bend'] = '\n'.join(L)
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
    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('mutsmall_*.bend') if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale mutation small laws: ', 'mutation small laws are current', orphans)
    writer.write(out, orphans)
    print(f'{len(out)} modules, {sum(t.count(chr(10) + "def ") for t in out.values())} laws')


if __name__ == '__main__':
    main()
