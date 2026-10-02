#!/usr/bin/env python3
"""A packed list's byte length must be a whole number of elements (manual spec-mutation audit, round 2: s04/03, s04/04).

    python3 codegen/proofs/slop/word_unit_validity.py [--check]

Public counterexample: `T.Fulu_list_uint64_128_serialize(O.Words{ws, 2})`, a list of 2 bytes of 8-byte elements: the divisibility test
`O.unit_ok(8, n)` of the validity pass decides, and a test that is weaker (`n & 1 == 0`) accepts it. The existing symbolic validity law
states the pass through `O.unit_ok` itself, so a change of `unit_ok` moved both sides of the statement.

For every name X whose checked serializer's validity is `O.words_ok(o, lo, hi, big, U)` with an element size U > 1 (packed uint lists, lists
of byte vectors), proofs/slop/validity/<runtime>_<X>_unit_generated.bend holds, on a zero storage of n bytes,

  <X>_serialize_vunit()      n = 1, U / 2 and U + 1 are refused (when they lie in the length range), n = U and 2 U are accepted
                             (when they do): {Pair.snd(O.Words, Bool, T.p_valid(O.words_new(n))) == <verdict> : Bool}, one law each.

By computation; filed by api_gate under serialize_valid.
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

VALID = re.compile(r'^def (\w+)_valid\(o: O\.Words\) -> O\.Words & Bool: (?:O\.bools_ok\()?O\.words_ok\(o, (\d+), (\d+), (True|False)\{\}, (\d+)\)\)?$', re.M)
N_MAX = 8192


def laws_of(X, p, lo, hi, big, U):
    def inside(n):
        return lo <= n and (big or n <= hi) and n <= N_MAX
    laws = []
    for tag, n, want in [(f'refuse_{n}', n, 'False') for n in sorted({1, U // 2, U + 1}) if n >= 1 and inside(n) and n % U] + \
                        [(f'accept_{n}', n, 'True') for n in (U, 2 * U) if inside(n)]:
        laws.append(f'def {X}_serialize_vunit_{tag}()\n    -> {{Pair.snd(O.Words, Bool, T.{p}_valid(O.words_new({n}))) == {want}{{}} : Bool}}:\n  {{==}}')
    return laws


def module(tmod, X, laws):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('word_unit_validity'),
         f'# {X}: a packed list holds whole elements (manual spec-mutation audit, round 2; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        for m in VALID.finditer(tx.text):
            p, lo, hi, big, U = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4) == 'True', int(m.group(5))
            if U <= 1:
                continue
            for X in owners_of(tx, p):
                laws = laws_of(X, p, lo, hi, big, U)
                if laws:
                    laws = [l.replace(f'{X}_serialize_vunit_', f'{X}_serialize_vunit_{p}_') for l in laws]
                    out[LAYOUT.module_path('validity', f'{runtime}_{X}_unit_{p}')] = module(tmod, X, laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'word_unit_validity', ('validity',), 'stale word unit laws: ', 'word unit laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
