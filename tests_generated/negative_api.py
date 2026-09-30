"""Compiler-negative checks: what the object API must refuse to compile.

    /opt/homebrew/bin/python3 tests_generated/negative_api.py

Each case is a small Bend program written to build/negative/. The negative ones
must fail to compile, for the stated reason; the positive control must compile,
so the suite cannot pass by everything failing. The checks are about the API's
shape and Bend's affine rules, not about run-time behaviour - they are evidence
of what the type system enforces, next to the universal laws in proofs/obj/.

  vector_append      a vector has no _append: only lists do, so a program that
                     tries to grow a Vector[Bytes32, 33] does not compile.
  bytevector_append  the same for a fixed byte vector.
  bitvector_append   and for a fixed bit vector.
  use_after_move     an owning object may not be used twice: writing a field
                     and then also encoding the original value is refused.
  duplicate_object   an owning object may not be duplicated into a pair.
  stale_collection   a collection swapped out of its object may not be used
                     again after being put back.
  positive_control   the same program, written the way the API intends, does
                     compile.
"""
import os
import pathlib
import subprocess
import sys
import json

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
import runtime_refs as RR  # noqa: E402
os.chdir(ROOT)
BEND = os.environ.get('BEND_RUNTIME') or json.loads((ROOT / 'benchmarks/toolchain.json').read_text())['bend']['path']
sys.path.insert(0, str(ROOT / 'benchmarks/checks'))
from provenance import stamp  # noqa: E402

OUT = ROOT / 'build/negative'
OUT.mkdir(parents=True, exist_ok=True)

HEAD = '''import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T

'''

CASES = [
    ('vector_append', False, '''
# Deposit.proof is Vector[Bytes32, 33]: there is no append for it.
def grow(v: O.Words) -> O.Words & Bool:
  T.v33_b32_append(v, T.Bytes32{0, 0, 0, 0, 0, 0, 0, 0})
'''),
    ('bytevector_append', False, '''
# Bytes32 is a fixed byte vector: no append.
def grow(v: O.Words) -> O.Words & Bool:
  T.b32_append(v, 1)
'''),
    ('bitvector_append', False, '''
# Bitvector[4] is fixed length: no append.
def grow(v: O.Words) -> O.Words & Bool:
  T.bits4_append(v, True{})
'''),
    ('use_after_move', False, '''
# An object that owns storage is consumed by the write; encoding the old value
# as well is a second use of it. (A Validator is all scalars, so the compiler
# does let it be copied; IndexedAttestation owns a list and does not.)
def twice(a: T.IndexedAttestation) -> B.Buf & B.Buf:
  (Pair.snd(T.IndexedAttestation, B.Buf,
     T.IndexedAttestation_encode(Pair.fst(T.IndexedAttestation, O.Words,
       T.IndexedAttestation_swap_attesting_indices(a, O.words_new(0))))),
   Pair.snd(T.IndexedAttestation, B.Buf, T.IndexedAttestation_encode(a)))
'''),
    ('duplicate_object', False, '''
def clone(s: T.BeaconState) -> T.BeaconState & T.BeaconState:
  (s, s)
'''),
    ('stale_collection', False, '''
# The list is swapped out of the object and put back; the handle the caller
# held may not be used again afterwards.
def stale_go(pr: T.IndexedAttestation & O.Words) -> T.IndexedAttestation & O.Words:
  (obj, idx) = pr
  (Pair.fst(T.IndexedAttestation, O.Words, T.IndexedAttestation_swap_attesting_indices(obj, idx)), idx)

def stale(a: T.IndexedAttestation) -> T.IndexedAttestation & O.Words:
  stale_go(T.IndexedAttestation_swap_attesting_indices(a, O.words_new(0)))
'''),
    ('positive_control', True, '''
# What the API intends: consume the object once, write a field, encode the
# result. The same program as use_after_move without the second use.
def once(a: T.IndexedAttestation) -> B.Buf:
  Pair.snd(T.IndexedAttestation, B.Buf,
    T.IndexedAttestation_encode(Pair.fst(T.IndexedAttestation, O.Words,
      T.IndexedAttestation_swap_attesting_indices(a, O.words_new(0)))))

def once_scalar(+v: T.Validator) -> B.Buf:
  T.Validator_encode(T.Validator_set_slashed(v, True{}))
'''),
]


def main():
    results, allok = [], True
    for name, must_compile, body in CASES:
        src = OUT / f'{name}.bend'
        # the runtime split: the program imports the per-name files it names (a missing symbol: its owner's file)
        src.write_text(RR.rewire(HEAD + body.lstrip(), missing='owner'))
        r = subprocess.run([BEND, str(src.relative_to(ROOT))], cwd=ROOT, capture_output=True, text=True,
                           env={**os.environ, 'BEND_NO_TELEMETRY': '1', 'BUN_JSC_forceRAMSize': '3000000000'})
        compiled = r.returncode == 0
        ok = compiled == must_compile
        allok &= ok
        results.append({'case': name, 'must_compile': must_compile, 'compiled': compiled, 'pass': ok,
                        'message': (r.stdout + r.stderr).strip().splitlines()[:4]})
        print(('pass ' if ok else 'FAIL ') + f'{name}: compiled={compiled}, required={must_compile}')
    out = ROOT / 'benchmarks/evidence/negative_api.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({'cases': results, 'pass': allok, 'provenance': stamp(__file__)}, indent=1) + '\n')
    print(('all negative API checks behave as required' if allok else 'FAILURES') + f' ({len(results)} cases)')
    sys.exit(0 if allok else 1)


if __name__ == '__main__':
    main()
