#!/usr/bin/env python3
"""Laws that pin the offsets the decoders read at and the reported size of a boxed container, the two proof-side
mutation groups `offset` and `reported-size` that no earlier statement noticed (docs/MUTATION_PROOFS.md).

    python3 codegen/proofs/laws/mutation_laws_offset.py [--check]

Per name X, proofs/obj/offset_laws_<X>.bend holds (kind `decode_offsets` of api_gate, filed in the
name's decode facade):

  <X>_decode_build(buf, size, b2, e: {P_ok(buf, 0, size) == (b2, True{})})
      : {T.<X>_decode(buf, size) == T.<X>_some(T.<X>_build(b2, size))}
      the decoder of the whole buffer is the builder `<X>_build` (the runtime's decode entry, listed in
      types/runtime_index.json) at start offset 0 over the buffer the validator returned. Every name.
  <X>_decode_fields(buf, b1, v0, .., h0: {F0_read(buf, K0, L0) == (b1, v0)}, ..)
      : {T.<X>_decode(buf, N) == (bn, Some{T.<X>{v0, .., vn}})}
      a fixed-size container (at most 8 fields, every field of a fixed size): when each field's reader returns
      (b_i+1, v_i) at the field's offset K_i of the schema layout (the sum of the fixed sizes before it) with the
      field's size L_i, the decoder returns the record of those values. The offsets, sizes and readers come from the
      schema, not from the generated reader's text. A decoder that reads a field at another offset (`off + K` to
      `off - K`: on a power-of-two buffer the word index 2^30 - K/4 is the same tree path as K/4, so no statement over
      the tight buffer of the object can see it) does not match the hypothesis.

proofs/obj/offset_size_<X>.bend, for a name whose size pass is a literal and whose boxed size pass is the
match form (Deposit, ProposerSlashing, ...; the literal boxed form is mutation_laws.py's):

  <X>_encoded_size(v, rest)
      : {(snd(T.<X>_bx_size(O.BSome{v, rest})), snd(T.<X>_bx_size(O.BNone{}))) == (N, 0)}
      the size the boxed size pass reports for a present element is the schema's fixed size N of the type, and an
      absent element counts 0 (the encoder's size of such a container is not a literal, so it cannot be the
      right-hand side; the literal-boxed form of mutation_laws.py compares with the encoder).

By computation / one rewrite per field; named so that api_gate files them under `decode_offsets` and `encoded_size`.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core import schema  # noqa: E402
from codegen.impl import generate as G  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402
from codegen.proofs.laws import root_laws_generic as RG  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

DEC = re.compile(r'^def (\w+)_decode\(buf: B\.Buf, \+size: U32\) -> [^\n]*\n  \1_built\(size, (\w+)_ok\(buf, 0, size\)\)$', re.M)
BUILD = re.compile(r'^def (\w+)_build\(buf: B\.Buf, \+size: U32\) -> B\.Buf & ([^\n]+?): (\w+)_read\(buf, 0, size\)$', re.M)
SIZE = re.compile(r'^def (\w+)_size\(o: [^\n]+?\) -> [^\n]*?: \(o, (\d+)\)$', re.M)
BXM = re.compile(r'^def (\w+)_bx_size\(o: O\.Boxed<([^\n]+?)>\) -> [^\n]*:\n  match o:\n'
                 r'    case O\.BSome\{v, rest\}: \w+_bx_size_back\(\w+_size\(v\)\)\n'
                 r'    case O\.BNone\{\}: \(\w+_bx_default\(\), 0\)$', re.M)


def header(tmod, what):
    return ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
            f'import ../../types/{tmod}.bend as T', '', writer.header('mutation_laws_offset'), f'# {what}', '']


def build_law(X, P, R):
    ty = f'B.Buf & Maybe<&1, {R}>'
    rhs = f'T.{X}_some(T.{X}_build(b2, size))'
    return [f'def {X}_decode_build(buf: B.Buf, +size: U32, b2: B.Buf, e: {{T.{P}_ok(buf, 0, size) == (b2, True{{}}) : B.Buf & Bool}})',
            f'    -> {{T.{X}_decode(buf, size) == {rhs} : {ty}}}:',
            f'  %Equal.sym(B.Buf & Bool, T.{P}_ok(buf, 0, size), (b2, True{{}}), e) : {{T.{X}_built(size, _) == {rhs} : {ty}}}',
            '  {==}']


def fields_law(X, s, P, text):
    """The decode_fields law of the fixed container shape s (None when its shape is not the plain fixed record)."""
    if s.t.kind != 'container' or not s.fixed or len(s.fields) > G.GROUP or not s.fields or any(not fs.fixed for _, fs in s.fields):
        return None
    F = s.fields
    if f'def {s.p}_rd0(+off: U32, +len: U32, pair:' not in text:
        return None
    hoff, fixed_part = G.container_layout(F)
    N = s.fsize
    R, n = qual(s.rep), len(F)
    mt = f'B.Buf & Maybe<&1, {R}>'
    ok_lit = (f'def {P}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: (buf, True{{}})' in text
              and f'def {P}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {P}_ok_len(U32.is_eq(len, {N}), buf, off)' in text)
    bs = ['buf'] + [f'b{i}' for i in range(1, n + 1)]
    if not ok_lit:
        bs = ['buf', 'b0'] + [f'b{i}' for i in range(1, n + 1)]     # b0: the buffer the validator returns
    first = bs[0] if ok_lit else bs[1]
    vs = [f'v{i}' for i in range(n)]
    rec = f'T.{s.t.name}{{' + ', '.join(vs) + '}'
    params = ['buf: B.Buf'] + ([] if ok_lit else ['b0: B.Buf']) + [f'{b}: B.Buf' for b in bs[(1 if ok_lit else 2):]]
    params += [f'{"+" if fs.data else ""}{v}: {qual(fs.rep)}' for v, (_, fs) in zip(vs, F)]
    if not ok_lit:
        params.append(f'e: {{T.{P}_ok(buf, 0, {N}) == (b0, True{{}}) : B.Buf & Bool}}')
    chain = [first] + bs[(1 if ok_lit else 2):]
    for i, (_, fs) in enumerate(F):
        params.append(f'h{i}: {{T.{fs.p}_read({chain[i]}, {hoff[i]}, {fs.fsize}) == ({chain[i + 1]}, {vs[i]}) : B.Buf & {qual(fs.rep)}}}')
    rhs = f'({chain[-1]}, Some{{{rec}}})'
    L = [f'def {X}_decode_fields({", ".join(params)})', f'    -> {{T.{X}_decode(buf, {N}) == {rhs} : {mt}}}:']
    if not ok_lit:
        L.append(f'  %Equal.sym(B.Buf & Bool, T.{P}_ok(buf, 0, {N}), (b0, True{{}}), e) : {{T.{X}_built({N}, _) == {rhs} : {mt}}}')
    for i, (_, fs) in enumerate(F):
        so = ', '.join(vs[:i])
        L.append(f'  %Equal.sym(B.Buf & {qual(fs.rep)}, T.{fs.p}_read({chain[i]}, {hoff[i]}, {fs.fsize}), ({chain[i + 1]}, {vs[i]}), h{i}) : '
                 f'{{T.{X}_some(T.{s.p}_rd{i}(0, {N}, {so + ", " if so else ""}_)) == {rhs} : {mt}}}')
    L.append('  {==}')
    return L


def size_law(X, rep, N):
    R = qual(rep)
    bx = f'O.Boxed<{R}>'
    some = f'Pair.snd({bx}, U32, T.{X}_bx_size(O.BSome{{v, rest}}))'
    none = f'Pair.snd({bx}, U32, T.{X}_bx_size(O.BNone{{}}))'
    return [f'# ---- {X}: a present element reports {N} bytes, an absent one 0 ----',
            f'def {X}_encoded_size(v: {R}, rest: {bx})',
            f'    -> {{({some}, {none}) == ({N}, 0) : U32 & U32}}:',
            '  {==}']


def runtime_files(runtime, tmod, shapes):
    text = RR.mono_text(runtime)
    out, nb, nf, ns = {}, 0, 0, 0
    sizes = {X: int(N) for X, N in SIZE.findall(text)}   # the names whose size pass is a literal
    bxm = {m.group(1): m.group(2) for m in BXM.finditer(text)}
    enc = set(re.findall(r'^def (\w+)_encode\(', text, re.M))
    builds = {X: (R, Q) for X, R, Q in BUILD.findall(text)}
    for X, P in DEC.findall(text):
        if X not in builds or builds[X][1] != P:
            continue
        L = header(tmod, 'The decoder of the whole buffer is the builder at start offset 0, and a fixed container\'s decoder reads each field at its\n'
                         '# schema offset (found by mutation testing; docs/MUTATION_PROOFS.md). By one rewrite of the validator / field reads, then computation.')
        L += [f'# ---- {X}: decode is some(build) of the validated buffer ----'] + build_law(X, P, qual(builds[X][0]))
        nb += 1
        s = shapes.get(X)
        fl = fields_law(X, s, P, text) if s is not None else None
        if fl:
            L += [f'# ---- {X}: decode reads each field at its schema offset ----'] + fl
            nf += 1
        out[ROOT / f'proofs/obj/offset_laws_{X}.bend'] = '\n'.join(L) + '\n'
    for X, lit in sorted(sizes.items()):
        s = shapes.get(X)
        if X in bxm and X in enc and s is not None and s.fixed:
            N = s.fsize        # the schema's fixed size, not the pass's literal
            L = header(tmod, 'The boxed size pass of a container whose size pass is a literal reports the encoding\'s length for a present element and 0 for an\n'
                             '# absent one (found by mutation testing; docs/MUTATION_PROOFS.md). By computation.')
            L += size_law(X, bxm[X], N)
            out[ROOT / f'proofs/obj/offset_size_{X}.bend'] = '\n'.join(L) + '\n'
            ns += 1
    return out, (nb, nf, ns)


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    fs_ = {n: g.shape(t) for n, t in names.items()}
    gnames = RG.generic_names()
    gg = G.Gen()
    for n, t in gnames.items():
        gg.shape(t)
    gs_ = {n: gg.shape(t) for n, t in gnames.items()}
    out, cnt = {}, []
    for runtime, tmod, shapes in (('fulu', 'fulu_obj', fs_), ('generic', 'generic_obj', gs_)):
        o, c = runtime_files(runtime, tmod, shapes)
        dup = set(o) & set(out)
        assert not dup, f'a name in both runtimes: {sorted(dup)[:3]}'
        out.update(o)
        cnt.append(c)
    orphans = sorted(str(q.relative_to(ROOT)) for q in list((ROOT / 'proofs/obj').glob('offset_laws_*.bend')) +
                     list((ROOT / 'proofs/obj').glob('offset_size_*.bend')) if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale offset mutation laws: ', 'offset mutation laws are current', orphans)
    writer.write(out, orphans)
    print(f'{len(out)} files; (decode_build, decode_fields, size) per runtime: {cnt}')


if __name__ == '__main__':
    main()
