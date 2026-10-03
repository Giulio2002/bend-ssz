#!/usr/bin/env python3
"""What a checked writer reports for an invalid value, and what serialize then answers (manual spec-mutation audit, round 4: a02, a06, a07, a12, a01, a03).

    python3 codegen/proofs/slop/writer_poison_laws.py [--check]

Public counterexamples: `T.ComplexTestStruct_serialize` of a struct whose Vector[FixedTestStruct, 4] holds FixedTestStruct{256, ..} answers ok with a size
when the vector's checked writer reports the old marker 2^31 for its invalid branch (2^31 is a size since the marker moved to 2^32 - 1 and NMAX to 2^32 - 32);
the same for two absent boxes, a SmallTestStruct{65536, 0}, a transaction Words{[0xFFFFFFFF], 1}, 2049 aggregation bits (round 4: a07, 22 of 40 faults survived:
the laws described X_valid, not what the writer reports). `O.pz(False)` answering 2^31 or NMAX, `O.refused()` answering ok, a serializer whose final poison test is
dropped (ExecutionPayloadHeader with 33 bytes of extra_data: ok with size 2^32 - 1).

Laws, all by computation:

  for every checked writer `P_pk(out, pos, (o, ok))` of the generated code (157: every `match ok` whose False branch answers `(out, (o, poison))`),
  in proofs/slop/validity/<runtime>_<X>_writer_<P>_generated.bend (X the smallest name using P):
    <X>_serialize_vpoison_pk_<P>          the invalid branch reports a poisoned size: `O.is_poisoned(m of P_pk(out, 0, (v, False))) == True`
  for every name X with a checked serializer (`X_senc_out`), in proofs/slop/validity/<runtime>_<X>_senc_generated.bend:
    <X>_serialize_vrefuse_writer_marker   `X_senc_out(out, X_default(), 2^32 - 1)` is refused
    <X>_serialize_vrefuse_writer_above    the same at NMAX + 1 = 2^32 - 31 (the first poisoned size)
    <X>_serialize_vrefuse_writer_ok       at size 0 it answers ok with the empty buffer of `out`
  once per runtime, in proofs/slop/validity/<runtime>_<X>_poison_generated.bend (X the first name with a checked serializer):
    <X>_serialize_vpoison_pz_false / _pz_true    `O.pz(False) == 2^32 - 1`, `O.pz(True) == 0`
    <X>_serialize_vpoison_refused         `O.refused() == O.Encoded{False, B.empty()}`
    <X>_serialize_vpoison_marks           `O.is_poisoned` at 0, 2^31, NMAX, NMAX + 1, 2^32 - 2, 2^32 - 1 (closed literals)
    <X>_serialize_vpoison_padd            `O.padd` below, at and across the marker and across the wrap (closed literals)

The last two state padd and is_poisoned on closed literals near the marker, so that a mutant of either is killed by a small file (a mutant of them made the
pinned checker overflow its stack on every big file, round 4 unjudged a01/04, 06, 07, a03/01, 06). Filed by api_gate under serialize_valid.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402
from codegen.proofs.slop.collection_guards import owners_of  # noqa: E402

MARK, NMAX = 4294967295, 4294967264
PK = re.compile(r'^def (\w+)_pk\(out: Array<U32>, \+pos: U32, pair: ([\w.<>, ]+?) & Bool\) -> Array<U32> & \(([\w.<>, ]+?) & U32\):', re.M)
SENC = re.compile(r'^def (\w+)_senc_out\(([^)]*)\) -> ([^:\n]+):', re.M)
SENC_PAIR = re.compile(r'^def (\w+)_senc_out\(pair: Array<U32> & \(([\w.<>, ]+) & U32\)\) -> ([^:\n]+):\n  \(out, r\) = pair\n  \(o, fl\) = r\n'
                       r'  \(o, O\.ser_done\(O\.is_poisoned\(fl\), (\d+), out\)\)$', re.M)


def value_of(tx, ty):
    """a value of the type `ty` (any value: the invalid branch does not look at it), or None"""
    simple = {'U32': '0', 'Bool': 'False{}', 'O.U64': 'O.U64{0, 0}', 'O.Words': 'O.words_new(0)', 'O.Bits': 'O.Bits{Array.new(U32, 0n, 0), 0}'}
    if ty in simple:
        return simple[ty]
    if ty.endswith('_Seq') and f'{ty[:-4]}_default' in tx.blk:
        return f'T.{ty[:-4]}_default()'
    if f'{ty}_default' in tx.blk:
        return f'T.{ty}_default()'
    return None


def qual(ty):
    return ty if ty.startswith('O.') or ty in ('U32', 'Bool') else f'T.{ty}'


def holders(tx, p, depth=0):
    """the names using p through another collection (a list of lists): the owners of the collections whose definitions call p"""
    if depth > 3:
        return []
    pat = re.compile(rf'\b{re.escape(p)}_\w+\(')
    out = set()
    for n, b in tx.blk.items():
        if n.startswith(p + '_') or not pat.search(b):
            continue
        q = n
        while q and f'{q}_default' not in tx.blk:      # the collection prefix of the block's name
            q = q.rsplit('_', 1)[0] if '_' in q else ''
        if q and q != p:
            out |= set(owners_of(tx, q) or holders(tx, q, depth + 1))
    return sorted(out)


def smallest(tx, names):
    return sorted(names, key=lambda X: (sum(1 for n in tx.blk if n.startswith(X + '_')), X))


def nest(xs):
    return xs[0] if len(xs) == 1 else f'({xs[0]}, {nest(xs[1:])})'


def tnest(t, k):
    out = t
    for _ in range(k - 1):
        out = f'{t} & ({out})'
    return out


def module(tmod, X, comment, laws):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('writer_poison_laws'), f'# {X}: {comment} (manual spec-mutation audit, round 4; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def law(name, stmt):
    return f'def {name}()\n    -> {{{stmt}}}:\n  {{==}}'


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        writers = [(m.group(1), m.group(2)) for m in PK.finditer(tx.text) if f'case False{{}}: (out, (o, {MARK}))' in tx.blk.get(f'{m.group(1)}_pk', '')]
        poisoned = [n for n, b in tx.blk.items() if f'case False{{}}: (out, (o, {MARK}))' in b]
        if len(writers) != len(poisoned):
            missing = sorted(set(poisoned) - {f'{p}_pk' for p, _ in writers})
            raise SystemExit(f'writer_poison_laws: checked writers of an unexpected shape: {missing[:5]}')
        for p, ty in writers:
            v = value_of(tx, ty)
            if v is None:
                raise SystemExit(f'writer_poison_laws: no value of {ty} for the writer {p}_pk')
            owners = smallest(tx, owners_of(tx, p) or holders(tx, p))
            if not owners:
                raise SystemExit(f'writer_poison_laws: no name uses the writer {p}_pk')
            X = owners[0]
            T = qual(ty)
            m = f'Pair.snd({T}, U32, Pair.snd(Array<U32>, {T} & U32, T.{p}_pk(Array.new(U32, 0n, 0), 0, ({v}, False{{}}))))'
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_writer_{p}')] = module(
                tmod, X, f'the invalid branch of the checked writer {p}_pk reports a poisoned size',
                [law(f'{X}_serialize_vpoison_pk_{p}', f'O.is_poisoned({m}) == True{{}} : Bool')])
        sencs = []
        for m in SENC_PAIR.finditer(tx.text):
            # a fixed-size serializer: the writer's pair (out, (o, flag)), the size is the type's
            X, ty, ret, size = m.group(1), m.group(2), m.group(3).strip(), m.group(4)
            v = value_of(tx, ty)
            if v is None:
                raise SystemExit(f'writer_poison_laws: no value of {ty} for {X}_senc_out')
            sencs.append(X)
            T = qual(ty)
            call = lambda k, X=X, v=v: f'T.{X}_senc_out((Array.new(U32, 0n, 0), ({v}, {k})))'    # noqa: E731
            snd = (lambda c, T=T: f'Pair.snd({T}, O.Encoded, {c})') if ret.endswith('& O.Encoded') else (lambda c: c)    # noqa: E731
            laws = [law(f'{X}_serialize_vrefuse_writer_marker', f'{snd(call(MARK))} == O.refused() : O.Encoded'),
                    law(f'{X}_serialize_vrefuse_writer_above', f'{snd(call(NMAX + 1))} == O.refused() : O.Encoded'),
                    law(f'{X}_serialize_vrefuse_writer_ok', f'{snd(call(0))} == O.Encoded{{True{{}}, B.Buf{{Array.new(U32, 0n, 0), {size}}}}} : O.Encoded')]
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_senc')] = module(tmod, X, 'the final poison test of the checked serializer', laws)
        for m in SENC.finditer(tx.text):
            X, params, ret = m.group(1), m.group(2), m.group(3).strip()
            args, ty = [], None
            for prm in MC.split_top_args(params):
                name, pty = (s.strip() for s in prm.split(':', 1))
                name = name.lstrip('+-')
                if name == 'out':
                    args.append('Array.new(U32, 0n, 0)')
                elif name == 'o':
                    ty = pty
                    args.append('VALUE')
                elif name == 'm':
                    args.append('MARKVAL')
                else:
                    args.append('0')
            v = value_of(tx, ty) if ty else None
            if v is None or 'MARKVAL' not in args:
                raise SystemExit(f'writer_poison_laws: the checked serializer {X}_senc_out has an unexpected shape')
            sencs.append(X)
            pair = ret.endswith('& O.Encoded')
            T = qual(ty)
            template = f'T.{X}_senc_out({", ".join(args)})'.replace('VALUE', v)
            call = lambda k, template=template: template.replace('MARKVAL', str(k))    # noqa: E731
            snd = (lambda c, T=T: f'Pair.snd({T}, O.Encoded, {c})') if pair else (lambda c: c)    # noqa: E731
            laws = [law(f'{X}_serialize_vrefuse_writer_marker', f'{snd(call(MARK))} == O.refused() : O.Encoded'),
                    law(f'{X}_serialize_vrefuse_writer_above', f'{snd(call(NMAX + 1))} == O.refused() : O.Encoded'),
                    law(f'{X}_serialize_vrefuse_writer_ok', f'{snd(call(0))} == O.Encoded{{True{{}}, B.Buf{{Array.new(U32, 0n, 0), 0}}}} : O.Encoded')]
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_senc')] = module(tmod, X, 'the final poison test of the checked serializer', laws)
        every = re.findall(r'^def (\w+)_senc_out\(', tx.text, re.M)
        if sorted(every) != sorted(sencs):
            raise SystemExit(f'writer_poison_laws: checked serializers of an unexpected shape: {sorted(set(every) - set(sencs))[:5]}')
        if sencs:
            X = smallest(tx, sencs)[0]
            marks = [0, 1 << 31, NMAX, NMAX + 1, MARK - 1, MARK]
            pads = [((0, 0), 0), ((5, 7), 12), ((NMAX, 0), NMAX), ((NMAX, 1), NMAX + 1), ((MARK - 1, 0), MARK - 1), ((MARK - 1, 1), MARK),
                    ((MARK, 0), MARK), ((1, MARK), MARK), ((1 << 31, 1 << 31), MARK), ((MARK - 2, 1), MARK - 1)]
            laws = [law(f'{X}_serialize_vpoison_pz_false', f'O.pz(False{{}}) == {MARK} : U32'),
                    law(f'{X}_serialize_vpoison_pz_true', 'O.pz(True{}) == 0 : U32'),
                    law(f'{X}_serialize_vpoison_refused', 'O.refused() == O.Encoded{False{}, B.empty()} : O.Encoded'),
                    law(f'{X}_serialize_vpoison_marks', f'{nest([f"O.is_poisoned({k})" for k in marks])} == '
                        f'{nest(["True{}" if k > NMAX else "False{}" for k in marks])} : {tnest("Bool", len(marks))}'),
                    law(f'{X}_serialize_vpoison_padd', f'{nest([f"O.padd({a}, {b})" for (a, b), _ in pads])} == {nest([str(r) for _, r in pads])} : {tnest("U32", len(pads))}')]
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_poison')] = module(tmod, X, 'the poison marker, its sum and its test', laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'writer_poison_laws', ('validity',), 'stale writer poison laws: ', 'writer poison laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
