#!/usr/bin/env python3
"""Laws that pin the poison flag of the words writers (docs/mutation_testing/EXCLUSION_AUDIT.md: the hidden ExecutionBranch mutant).

    python3 codegen/proofs/mutation_coverage/poison_flag.py [--check]

The checked serializer of a words name writes with `P_putk`, whose `P_pk_ok` branch returns the object and the flag 0 (valid:
no poison bit). A writer's flag is OR-ed into the running length of every container that embeds the name
(`cur .|. fl`), so `0 -> 1` in `P_pk_ok` changes the reported length of LightClientHeader, the light-client updates and any
other variable-size container by one, but not the serialized length of the name itself, which `O.is_poisoned` reads
(bit 31): the facade of the name saw no difference. For every words name this file writes, into
proofs/mutation_coverage/validity/<runtime>_<X>_poison_flag.bend (one file per name),

  <X>_serialize_vflag(out, o) : {T.P_pk_ok((out, o)) == (out, (o, 0))}

for every storage `out` and object `o`: a valid object reports the flag 0. By computation. Named so that object_api_coverage_gate files it
under serialize_valid, in the name's own encode facade, which is where a mutant of that file is re-checked.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core.law_module_helpers import RUNTIMES  # noqa: E402
from codegen.core import mutation_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402

SER = re.compile(r'^def (\w+)_serialize\(o: O\.Words\) -> [^\n]*: ([^\n]*)$', re.M)


def module(text, tmod):
    out = {}
    for X, body in SER.findall(text):
        m = re.search(r'\b(\w+?)_putk\(', body)
        if not m:
            continue
        P = m.group(1)
        pk = re.search(rf'^def {P}_pk_ok\(pair: Array<U32> & O\.Words\) -> Array<U32> & \(O\.Words & U32\):\n  \(out, o\) = pair\n  \(out, \(o, 0\)\)$', text, re.M)
        if not pk:
            raise SystemExit(f'poison_flag: {X}: `{P}_pk_ok` is not the (out, (o, 0)) writer')
        head = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
                writer.header('poison_flag'),
                '# Laws that pin the poison flag of the words writers (found by the exclusion audit; docs/mutation_testing/EXCLUSION_AUDIT.md).',
                '# By computation. One file per name: a facade imports (and re-checks) only its own.', '',
                f'# ---- {X}: a valid object reports the flag 0 (the flag is OR-ed into the length of every container that embeds it) ----']
        law = [f'def {X}_serialize_vflag(out: Array<U32>, o: O.Words) -> {{T.{P}_pk_ok((out, o)) == (out, (o, 0)) : Array<U32> & (O.Words & U32)}}:',
               '  {==}']
        out[X] = '\n'.join(head + law) + '\n'
    return out


def main():
    out = {}
    for runtime, tmod in RUNTIMES:
        for X, t in module(RR.mono_text(runtime), tmod).items():
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_poison_flag')] = t
    if LAYOUT.finish(RR.rewire_out(out), 'poison_flag', ('validity',), 'stale poison flag laws: ', 'flag laws are current', '--check' in sys.argv):
        print(f'{len(out)} files')


if __name__ == '__main__':
    main()
