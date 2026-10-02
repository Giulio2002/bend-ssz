#!/usr/bin/env python3
"""Laws that pin three constants of the frozen spec that no other law reaches (mutation testing of the spec library,
docs/MUTATION_PROOFS.md section 8): the spec files are never edited; each law is a statement about a spec function that
lives in a small module importing the spec file, so a mutated copy of the file fails the module.

    python3 codegen/proofs/laws/spec_pins.py [--check]

proofs/obj/specpin_bytes.bend      imports spec/bytes.bend and spec/nat_bytes.bend
  size_fits_is_fits4   {size_fits(n) == Length.fits(4n, n)}    the 2^32 size limit is four base-256 quotient steps
                       (nat_bytes.fits is the independent definition: the width counted by recursion, not four spelled divisions)
  vector_domain_1      {vector_domain(1n, [7]) == True}         a one-byte vector accepts one byte (the exact scope 1n+p)
proofs/obj/specpin_byte_list.bend  imports spec/byte_list.bend and spec/bytes.bend
  domain_size_limit    {domain(c, xs) == and(and(bytes_domain(xs), length(xs) <= c), size_fits(length(xs)))}
                       the 4-byte length prefix of the byte-list domain is bytes.size_fits (independent of the literal 4n)

The modules are kept small on purpose: the library mutation harness checks a spec file with the two smallest proof files
that import it directly.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core import writer  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

H = writer.header("spec_pins")

BYTES = f"""import Base
import ../../spec/bytes.bend as B
import ../../spec/nat_bytes.bend as L
{H}
def size_fits_is_fits4(+n: Nat) -> {{B.size_fits(n) == L.fits(4n, n) : Bool}}:
  {{==}}
def vector_domain_1() -> {{B.vector_domain(1n, [7]) == True{{}} : Bool}}:
  {{==}}
"""

BYTE_LIST = f"""import Base
import ../../spec/byte_list.bend as K
import ../../spec/bytes.bend as B
import ../../spec/primitives.bend as P
{H}
def domain_size_limit(+c: Nat, +xs: +List<U32>) -> {{K.domain(c, xs) == Bool.and(Bool.and(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), c)), B.size_fits(List.length(&2, U32, xs))) : Bool}}:
  {{==}}
"""


def outputs():
    return {ROOT / "proofs/obj/specpin_bytes.bend": BYTES, ROOT / "proofs/obj/specpin_byte_list.bend": BYTE_LIST}


def main():
    out = outputs()
    if "--check" in sys.argv:
        return writer.check(out, "stale spec pins: ", "spec pins are current")
    writer.write(out)
    print(f"{len(out)} modules")


if __name__ == "__main__":
    main()
