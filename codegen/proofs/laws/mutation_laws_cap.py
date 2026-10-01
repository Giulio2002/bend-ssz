#!/usr/bin/env python3
"""Laws that pin the capacity of the checked serializer's output buffer, found by mutation testing (an
`O.out_at(d)` in `X_serialize` changed to `O.out_at(d - 1)`).

    python3 codegen/proofs/laws/mutation_laws_cap.py [--check]

`O.out_at(d)` is `Array.new(U32, d, 0)`: a zero array of 2^d words, and word indices are taken modulo that size, so an
encoder whose buffer is one power of two too small writes over its own head without any error. The encoders
(`X_encode`) are pinned by the statements about their output (a smaller buffer changes the emitted words or the
array), but `X_serialize` (the checked serializer, its own `out_at`) had no statement for most names: a name's
serialize_valid law exists only for scalars and byte vectors, and `X_serialize_in` (mutation_laws.py) only for byte
vectors of up to 4096 bytes.

proofs/obj/capacity_<X>.bend (one module per name) holds, for every name whose serializer allocates with `O.out_at`:

  <X>_serialize_cap    : {T.X_serialize(D) == (D, O.encoded(<the encoder's buffer for D>)) : ..}
      D is the name's default object (every field zero, storage of the right size: valid), by computation. The
      serializer's buffer and the encoder's are the same array (same size, same words): a serializer with a smaller
      or larger capacity than the encoder's changes the array and so the statement's value. The words written are
      zero, so this pins the capacity, not the contents (those are the encoder's statements).

Named so that api_gate files it under serialize_valid: it lands in the name's encode facade.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402

MAX_DEPTH = 10  # a default whose encoder buffer has more than 2^10 words costs 75 s (SyncCommittee, 2^13) to 160+ s (LightClientUpdate) to check, Blob (2^15) over 600 s


def name_laws(runtime):
    text = RR.mono_text(runtime)
    out = {}
    for m in re.finditer(r'^def (\w+)_serialize\(o: ([\w.]+)\) -> ([^\n:]*): (\w+)_senc_(?:out|put)\((\w+)_putk\(O\.out_at\((\d+)n\), 0, o\)\)$', text, re.M):
        X, P, d = m.group(1), m.group(5), int(m.group(6))
        if d > MAX_DEPTH or not re.search(rf'^def {P}_default\(\)', text, re.M):
            continue
        e = re.search(rf'^def {X}_encode\(o: [\w.]+\) -> ([^\n:]*):', text, re.M)
        if not e:
            continue
        D = f'T.{P}_default()'
        if '& B.Buf' in e.group(1):
            buf = f'Pair.snd({qual(e.group(1).replace(" & B.Buf", "").strip())}, B.Buf, T.{X}_encode({D}))'
        else:
            buf = f'T.{X}_encode({D})'
        ret = ' & '.join(qual(t.strip()) for t in m.group(3).split(' & '))
        out[X] = (f'def {X}_serialize_cap() -> {{T.{X}_serialize({D}) == ({D}, O.encoded({buf})) : {ret}}}:\n  {{==}}')
    return out


def module(tmod, X, law):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('mutation_laws_cap'),
         f'# {X}: the checked serializer\'s output buffer is the encoder\'s (same capacity)',
         '# (found by mutation testing; codegen/proofs/laws/mutation_laws_cap.py). By computation.', '', law, '']
    return '\n'.join(L)


def main():
    out, cnt, seen = {}, [], set()
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        laws = name_laws(runtime)
        n = 0
        for X, law in laws.items():
            if X in seen:
                continue
            seen.add(X)
            out[ROOT / f'proofs/obj/capacity_{X}.bend'] = module(tmod, X, law)
            n += 1
        cnt.append(n)
    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('capacity_*.bend') if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale capacity laws: ', 'capacity laws are current', orphans)
    writer.write(out, orphans)
    print(f'{cnt} laws')


if __name__ == '__main__':
    main()
