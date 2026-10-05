#!/usr/bin/env python3
"""The default constructors are the spec's default values (manual spec-mutation audit, round 10: r10-d01).

    python3 codegen/proofs/slop/default_value_laws.py [--check]

Public counterexamples (round 10, docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md R10.2): `b20_default` with byte 0 = 1, `b32_default`,
`b48_default`, `b8_default`, `b96_default`, the bit vectors 128 / 512 / 64 / 513 / 5 / 4 with bit 0 set, `bool_default` = True and
`u64_default` = 1 all checked: no law tied `X_default()` to the spec's *Default values* rule (every basic value zero / False, byte and bit
vectors all zero, lists empty, a vector of N element defaults, a container of field defaults, a union's first option); the facades
quantify over every value and the `_serialize_cap` / `vec_*_e2e_valid_default` laws pin only the default's length.

proofs/slop/constants/<runtime>_<X>_default_<tag>_generated.bend holds, by computation (`{==}`):

  <X>_default_serialize   (every name X whose spec default encodes to at most IMG_MAX bytes) the checked serializer of X's default is
                          accepted and writes exactly the spec's default encoding: the bytes computed here by the independent oracle
                          (codegen/core/independent_ssz_oracle.py) from the schema's default value (zero fixed parts, empty lists, every
                          offset at the end of the fixed part)
                            {dflt_bytes(X_serialize(X_default())) == (True{}, [b0, b1, ...]) : Bool & +List<U32>}
  <X>_default_root        (every name X whose spec default root takes at most HASH_MAX hashes in the oracle) the root of X's default is
                          the oracle's root of the spec default value (D.D{w0..w7}, big-endian words of the 32 bytes)
  <X>_default_fields      (every container and every field group of one, Fulu and generic) per field: the default is the record of its
                          fields' kind defaults (the kind named from the schema type of each field, codegen/impl/typed_object_runtime.ident,
                          never read from the default's own body); a union's default is its first option holding that option's default;
                          a boxed default is the box of the default
                            {X_default() == X{<kind of f0>_default(), <kind of f1>_default(), ...} : X}
  <kp>_default_zero       (every other kind with a `_default`: basic values, byte and bit vectors, packed vectors and lists, bit lists,
                          lists and vectors of composite elements) the default is the spec's zero value: False{}, 0, O.U64{0, 0}, the
                          record of ceil(n / 4) zero words of an n-byte value, the zero storage O.words_new(n) of the spec's n bytes (a
                          vector, a byte vector) or of 0 bytes (a list); a bit list or a list of composite elements has length 0, a vector
                          of composite elements length N

So every field kind's default is pinned once (`_default_zero`, or `_default_fields` for a container kind), every container default is
pinned through its fields, and the names small enough to encode / hash in a law also have their whole image and root stated. The names
above the caps (BeaconState, HistoricalBatch, SyncCommittee, the light-client bootstrap / updates, BlobSidecar, Blob, the 512 / 513-element
uint64 / uint128 / uint256 vectors, ...) are covered field by field: their facades give serialize and hash_tree_root of every object, and
the object is the spec default.

Coverage gate: the generator stops when any `def <k>_default()` of a runtime monolith has no law of this family (a kind whose schema type it
cannot find, a representation it has no zero literal for, a record whose word count is not ceil(n / 4), a container field whose kind has
no default). Filed under the `constants` slop group.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import generic_form_schemas as generic  # noqa: E402
from codegen.core import independent_ssz_oracle as oracle  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.impl.typed_object_runtime import ident  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402

GEN = 'default_value_laws'
IMG_MAX = 2048      # bytes: a default image law expands the encoding as a byte list (the checker spends about 4 ms a byte)
HASH_MAX = 16       # SHA-256 nodes: the checker evaluates a node in about a second
EBYTES = '''def dflt_bytes(e: O.Encoded) -> Bool & +List<U32>:
  match e:
    case O.Encoded{ok, b}:
      match b:
        case B.Buf{ws, +n}: (ok, Pair.snd(B.Buf, +List<U32>, B.emit(B.Buf{ws, n}, 0, U32.shrn((n + 3 : U32), 2n))))
'''


def spec_default(t):
    """the spec's default value of schema type t, in the oracle's value form (SSZ 'Default values')"""
    k = t.kind
    if k == 'bool':
        return False
    if k == 'uint':
        return 0
    if k == 'bytes':
        return bytes(t.size)
    if k == 'bits':
        return [False] * t.size
    if k == 'bytelist':
        return b''
    if k in ('bitlist', 'pbits', 'list', 'plist'):
        return []
    if k == 'vector':
        return [spec_default(t.elem)] * t.size
    if k in ('container', 'pcontainer'):
        return {f: spec_default(ft) for f, ft in t.fields}
    if k == 'cunion':
        return {'selector': t.selectors[0], 'value': spec_default(t.fields[0][1])}
    raise ValueError(f'no default for kind {k}')


class Count:
    """the number of SHA-256 nodes of one oracle root"""

    def __init__(self):
        self.n = 0

    def __enter__(self):
        self.h = oracle.h

        def h(a, b):
            self.n += 1
            return self.h(a, b)
        oracle.h = h
        return self

    def __exit__(self, *a):
        oracle.h = self.h


def kinds_of(names):
    """{kind prefix: schema type} over every type reachable from the names"""
    out = {}

    def walk(t):
        p = ident(t)
        if p in out:
            return
        out[p] = t
        if t.elem is not None:
            walk(t.elem)
        for _, ft in t.fields:
            walk(ft)
    for t in names.values():
        walk(t)
    return out


def record(tx, R):
    """[(field, type)] of the record type R of the monolith, or None"""
    pat = re.compile(rf'^type {re.escape(R)} is (?:Type|Data):\n  {re.escape(R)}\{{([^}}]*)\}}', re.M)
    m = pat.search(tx.text)
    if m is None:       # a record the runtime shares with the fork's split type files (the generic runtime's uint256)
        for f in sorted((ROOT / 'types').glob('*_def_generated.bend')):
            m = pat.search(f.read_text())
            if m:
                break
    if not m:
        return None
    return [tuple(x.strip() for x in f.split(':', 1)) for f in MC.split_top_args(m.group(1))]


def q(ty):
    """a monolith type as the law module spells it"""
    m = re.fullmatch(r'O\.Boxed<(\w+)>', ty)
    if m:
        return f'O.Boxed<T.{m.group(1)}>'
    if ty in ('U32', 'Bool') or ty.startswith(('O.', 'B.', 'D.')):
        return ty
    return f'T.{ty}'


def law(name, stmt):
    return f'def {name}()\n    -> {{{stmt}}}:\n  {{==}}'


def container_laws(tx, X, t, kinds, missing):
    """[(record, law)]: X's default (and each field group's) is the record of its fields' kind defaults"""
    out = []
    by = dict(t.fields)
    top = record(tx, X)
    if top is None:
        missing.append(f'{X}: no record declaration')
        return out
    recs = [(X, top)]
    if all(re.fullmatch(rf'{re.escape(X)}_g\d+', ty) for _, ty in top):
        recs += [(ty, record(tx, ty)) for _, ty in top]
    for R, fs in recs:
        if fs is None:
            missing.append(f'{R}: no record declaration')
            continue
        args = []
        for f, ty in fs:
            if re.fullmatch(rf'{re.escape(X)}_g\d+', ty):
                d = f'{ty}_default'
            elif f in by:
                d = ident(by[f]) + ('_bx_default' if ty.startswith('O.Boxed<') else '_default')
            else:
                missing.append(f'{R}.{f}: not a field of the schema')
                d = None
            if d is not None and d not in tx.blk:
                missing.append(f'{R}.{f}: no {d}')
            args.append(f'T.{d}()')
        out.append((R, law(f'{R}_default_fields', f'T.{R}_default() == T.{R}{{{", ".join(args)}}} : T.{R}')))
    return out


def zero_law(tx, kp, t, missing):
    """the law that kp's default is the spec's zero value, or None (recorded in missing)"""
    sig = tx.get(f'{kp}_default')
    R = sig[1] if sig else None
    k = t.kind
    if R == 'Bool' and k == 'bool':
        return law(f'{kp}_default_zero', f'T.{kp}_default() == False{{}} : Bool')
    if R == 'U32' and k == 'uint' and t.size <= 4:
        return law(f'{kp}_default_zero', f'T.{kp}_default() == 0 : U32')
    if R == 'O.U64' and k == 'uint' and t.size == 8:
        return law(f'{kp}_default_zero', f'T.{kp}_default() == O.U64{{0, 0}} : O.U64')
    if R == 'O.Words':
        if k in ('bytes', 'bits', 'vector'):
            n = t.fixed_size()
        elif k in ('bytelist', 'list', 'plist'):
            n = 0
        else:
            missing.append(f'{kp}: O.Words of kind {k}')
            return None
        return law(f'{kp}_default_zero', f'T.{kp}_default() == O.words_new({n}) : O.Words')
    if R and record(tx, R) and k in ('uint', 'bytes', 'bits'):
        fs = record(tx, R)
        nb = t.fixed_size()
        if any(ty != 'U32' for _, ty in fs) or len(fs) != (nb + 3) // 4:
            missing.append(f'{kp}: record {R} is not {(nb + 3) // 4} U32 words')
            return None
        return law(f'{kp}_default_zero', f'T.{kp}_default() == T.{R}{{{", ".join("0" for _ in fs)}}} : T.{R}')
    if R and f'{kp}_len' in tx.blk and k in ('bitlist', 'pbits', 'list', 'plist', 'vector'):
        n = t.size if k == 'vector' else 0
        return law(f'{kp}_default_zero', f'Pair.snd({q(R)}, U32, T.{kp}_len(T.{kp}_default())) == {n} : U32')
    missing.append(f'{kp}: no zero literal for {R} ({k})')
    return None


def name_laws(tx, X, t):
    """[(tag, law)]: the image and the root of the name X's default, within the caps"""
    ser, hr = tx.get(f'{X}_serialize'), tx.get(f'{X}_hash_tree_root')
    if not ser or not hr:
        return []
    P = ser[0][0].split(':', 1)[1].strip()
    d = f'{ident(t)}_default'
    if d not in tx.blk or tx.get(d)[1] != P:
        return []
    v = spec_default(t)
    out = []
    enc = oracle.serialize(t, v)
    if len(enc) <= IMG_MAX:
        e = f'T.{X}_serialize(T.{d}())'
        if ser[1] != 'O.Encoded':
            e = f'Pair.snd({q(P)}, O.Encoded, {e})'
        out.append(('image', law(f'{X}_default_serialize', f'dflt_bytes({e}) == (True{{}}, [{", ".join(str(b) for b in enc)}]) : Bool & +List<U32>')))
    with Count() as c:
        r = oracle.root(t, v)
    if c.n <= HASH_MAX:
        h = f'T.{X}_hash_tree_root(O.hasher(), T.{d}())'
        if hr[1] == 'B.Buf & D.Digest':
            dg = f'Pair.snd(B.Buf, D.Digest, {h})'
        else:
            dg = f'Pair.snd({q(P)}, D.Digest, Pair.snd(B.Buf, {q(P)} & D.Digest, {h}))'
        ws = [int.from_bytes(r[i:i + 4], 'big') for i in range(0, 32, 4)]
        out.append(('image', law(f'{X}_default_root', f'{dg} == D.D{{{", ".join(str(w) for w in ws)}}} : D.Digest')))
    return out


def module(tmod, what, laws, ebytes=False):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/digest.bend as D', 'import ../../src/obj.bend as O',
         f'import ../../types/{tmod}.bend as T', '', writer.header(GEN),
         f'# {what}: the default is the spec default value (manual spec-mutation audit, round 10; docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md).', '']
    if ebytes:
        L.append(EBYTES)
    return '\n'.join(L + ['\n\n'.join(laws), ''])


def outputs():
    out, missing = {}, []
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', dict(fu.items())), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        kinds = kinds_of(names)
        defaults = sorted(n[:-len('_default')] for n in tx.blk if n.endswith('_default') and tx.get(n) and not tx.get(n)[0])
        covered = set()
        # whole images and roots of the names
        for X in sorted(names):
            laws = name_laws(tx, X, names[X])
            if laws:
                out[LAYOUT.module_path('constants', f'{runtime}_{X}_default_image')] = module(tmod, X, [x for _, x in laws], ebytes=True)
        # containers and their groups, unions, boxes
        for p, t in sorted(kinds.items()):
            if t.kind in ('container', 'pcontainer'):
                for R, x in container_laws(tx, p, t, kinds, missing):
                    covered.add(R)
                    out[LAYOUT.module_path('constants', f'{runtime}_{R}_default_fields')] = module(tmod, R, [x])
            elif t.kind == 'cunion':
                c0 = re.search(rf'^  ({re.escape(p)}_c0)\{{', tx.text, re.M)
                d = ident(t.fields[0][1]) + '_default'
                if not c0 or d not in tx.blk:
                    missing.append(f'{p}: union option 0')
                    continue
                covered.add(p)
                out[LAYOUT.module_path('constants', f'{runtime}_{p}_default_fields')] = module(
                    tmod, p, [law(f'{p}_default_fields', f'T.{p}_default() == T.{p}_c0{{T.{d}()}} : T.{p}')])
        for b in defaults:
            if b.endswith('_bx'):
                base = b[:-len('_bx')]
                if f'{base}_default' not in tx.blk or f'{b}_wrap' not in tx.blk:
                    missing.append(f'{b}: a box without its base default or wrap')
                    continue
                covered.add(b)
                out[LAYOUT.module_path('constants', f'{runtime}_{b}_default_fields')] = module(
                    tmod, b, [law(f'{b}_default_fields', f'T.{b}_default() == T.{b}_wrap(T.{base}_default()) : {q(tx.get(b + "_default")[1])}')])
        # every other kind: the zero value
        for kp in defaults:
            if kp in covered:
                continue
            t = kinds.get(kp)
            if t is None:
                missing.append(f'{kp}: no schema type')
                continue
            x = zero_law(tx, kp, t, missing)
            if x:
                covered.add(kp)
                out[LAYOUT.module_path('constants', f'{runtime}_{kp}_default_zero')] = module(tmod, kp, [x])
        missing += [f'{runtime} {kp}: no default law' for kp in defaults if kp not in covered]
    if missing:
        raise SystemExit('default_value_laws: defaults without a law: ' + '; '.join(sorted(set(missing))))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), GEN, ('constants',), 'stale default value laws: ', 'default value laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
