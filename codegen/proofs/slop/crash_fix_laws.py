#!/usr/bin/env python3
"""Laws that pin the crash-hunt fixes (docs/CRASH_HUNT.md CH-01, CH-04, CH-05, CH-06, CH-10), each by computation on a small object.

    python3 codegen/proofs/slop/crash_fix_laws.py [--check]

proofs/slop/crash/crash_fix_laws_generated.bend (one module; the objects are tiny, a claimed length of 2^32 - 1 needs no storage):

  CH-01  the cell list refuses a cell whose length is not 2048 bytes: set of an empty cell, of a 4096-byte cell at index 1, of a
         64-byte cell, and append of an empty cell, each return the list unchanged and False; a 2048-byte cell is accepted.
  CH-04  a list that claims 2^32 - 1 elements is full: append to a progressive bit list, to Bitlist[2048] and to a progressive
         byte list returns the list unchanged and False (the guard `n + 1 <= limit` wrapped to 0 there and accepted).
  CH-05, CH-06  the checked decoder refuses a window larger than its buffer and a window of 2^31 bytes or more, and accepts a
         window inside the buffer.
  CH-10  serialize(default) of ComplexTestStruct, whose default holds a vector of variable-size elements, is accepted and has the
         spec's 100 bytes (the absent boxes of the default used to leave 14 bytes unwritten).

The symbolic statements of the same fixes are the regenerated collection laws (`<X>_api_set_flag`, `<X>_api_append_flag`: the flag is
exactly the guard, now with the length test and `n < limit`); these laws fail on the unfixed tree where a statement about the guard alone
would not name the object.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402

H = writer.header("crash_fix_laws")

MODULE = f"""import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/Fulu_list_bytevec_2048_4096_def_generated.bend as Cells
import ../../types/proglist_uint8_def_generated.bend as PlD
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/Fulu_bitlist_2048_def_generated.bend as B2048
import ../../types/FuluCheckpoint_def_generated.bend as CpD
import ../../types/FuluCheckpoint_decode_ssz_generated.bend as CpR
import ../../types/ComplexTestStruct_def_generated.bend as CtD
import ../../types/ComplexTestStruct_encode_ssz_generated.bend as CtE
import ../../types/Fulu_list_uint64_1099511627776_def_generated.bend as L64
import ../../types/proglist_uint16_def_generated.bend as P16
import ../../types/proglist_uint32_def_generated.bend as P32
import ../../types/proglist_uint64_def_generated.bend as P64
import ../../types/proglist_uint8_decode_ssz_generated.bend as PlR
{H}
# ---- CH-01: a cell is exactly 2048 bytes ----
def cells2() -> O.Words: O.Words{{Array.new(U32, 10n, 0), 4096}}

def cells_set_empty_refused() -> {{Cells.l4096_b2048_set(O.Words{{Array.new(U32, 10n, 0), 4096}}, 0, O.Words{{Array.new(U32, 3n, 0), 0}}) == (O.Words{{Array.new(U32, 10n, 0), 4096}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def cells_set_4096_refused() -> {{Cells.l4096_b2048_set(O.Words{{Array.new(U32, 10n, 0), 4096}}, 1, O.Words{{Array.new(U32, 10n, 4294967295), 4096}}) == (O.Words{{Array.new(U32, 10n, 0), 4096}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def cells_set_64_refused() -> {{Cells.l4096_b2048_set(O.Words{{Array.new(U32, 10n, 0), 4096}}, 0, O.Words{{Array.new(U32, 5n, 4294967295), 64}}) == (O.Words{{Array.new(U32, 10n, 0), 4096}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def cells_append_empty_refused() -> {{Cells.l4096_b2048_append(O.Words{{Array.new(U32, 10n, 0), 4096}}, O.Words{{Array.new(U32, 3n, 0), 0}}) == (O.Words{{Array.new(U32, 10n, 0), 4096}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def cells_set_2048_accepted() -> {{Pair.snd(O.Words, Bool, Cells.l4096_b2048_set(O.Words{{Array.new(U32, 10n, 0), 4096}}, 0, O.Words{{Array.new(U32, 9n, 7), 2048}})) == True{{}} : Bool}}:
  {{==}}

# ---- CH-04: 2^32 - 1 elements is full ----
def pbits_append_max_refused() -> {{PbD.pbits_append(O.Bits{{Array.new(U32, 1n, 0), 4294967295}}, True{{}}) == (O.Bits{{Array.new(U32, 1n, 0), 4294967295}}, False{{}}) : O.Bits & Bool}}:
  {{==}}

def bits2048_append_max_refused() -> {{B2048.bits2048_append(O.Bits{{Array.new(U32, 1n, 0), 4294967295}}, True{{}}) == (O.Bits{{Array.new(U32, 1n, 0), 4294967295}}, False{{}}) : O.Bits & Bool}}:
  {{==}}

def pl_u8_append_max_refused() -> {{PlD.pl_u8_append(O.Words{{Array.new(U32, 4n, 0), 4294967295}}, 7) == (O.Words{{Array.new(U32, 4n, 0), 4294967295}}, False{{}}) : O.Words & Bool}}:
  {{==}}

# ---- CH-05, CH-06: the checked decoder ----
def decode_checked_empty_buffer_refused() -> {{CpR.Checkpoint_decode_checked(B.empty(), 40) == (B.empty(), None{{}}) : B.Buf & Maybe<&1, CpD.Checkpoint>}}:
  {{==}}

def decode_checked_2gib_refused() -> {{CpR.Checkpoint_decode_checked(B.Buf{{Array.new(U32, 1n, 0), 2147483648}}, 2147483648) == (B.Buf{{Array.new(U32, 1n, 0), 2147483648}}, None{{}}) : B.Buf & Maybe<&1, CpD.Checkpoint>}}:
  {{==}}

def decode_checked_inside_accepted() -> {{CpR.Checkpoint_decode_checked(B.alloc(40), 40) == CpR.Checkpoint_decode(B.alloc(40), 40) : B.Buf & Maybe<&1, CpD.Checkpoint>}}:
  {{==}}

# ---- CH-10: the default of a container with a vector of variable-size elements serializes whole ----
def enc_ok(e: O.Encoded) -> Bool:
  match e:
    case O.Encoded{{ok, b}}: ok

def enc_size_of(e: O.Encoded) -> U32:
  match e:
    case O.Encoded{{ok, b}}: Pair.snd(B.Buf, U32, B.size(b))

def complex_default_serialize_ok() -> {{enc_ok(Pair.snd(CtD.ComplexTestStruct, O.Encoded, CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default()))) == True{{}} : Bool}}:
  {{==}}

def complex_default_serialize_100() -> {{enc_size_of(Pair.snd(CtD.ComplexTestStruct, O.Encoded, CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default()))) == 100 : U32}}:
  {{==}}

# ---- R2-01, R2-06: every list kind guards its append (a limit above U32 used to leave the guard True{{}} and (n + 1) * size wrapped) ----
def u64list_append_max_refused() -> {{L64.l1099511627776_u64_append(O.Words{{Array.new(U32, 4n, 0), 4294967288}}, O.U64{{1, 2}}) == (O.Words{{Array.new(U32, 4n, 0), 4294967288}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def pl_u16_append_max_refused() -> {{P16.pl_u16_append(O.Words{{Array.new(U32, 4n, 0), 4294967294}}, 7) == (O.Words{{Array.new(U32, 4n, 0), 4294967294}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def pl_u32_append_max_refused() -> {{P32.pl_u32_append(O.Words{{Array.new(U32, 4n, 0), 4294967292}}, 7) == (O.Words{{Array.new(U32, 4n, 0), 4294967292}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def pl_u64_append_max_refused() -> {{P64.pl_u64_append(O.Words{{Array.new(U32, 4n, 0), 4294967288}}, O.U64{{1, 2}}) == (O.Words{{Array.new(U32, 4n, 0), 4294967288}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def pl_u8_append_wrap_refused() -> {{PlD.pl_u8_append(O.Words{{Array.new(U32, 4n, 0), 4294967264}}, 7) == (O.Words{{Array.new(U32, 4n, 0), 4294967264}}, False{{}}) : O.Words & Bool}}:
  {{==}}

# ---- R2-05: the cell's storage must hold its 2048 bytes ----
def cells_set_one_word_refused() -> {{Cells.l4096_b2048_set(O.Words{{Array.new(U32, 10n, 0), 4096}}, 0, O.Words{{Array.new(U32, 1n, 4294967295), 2048}}) == (O.Words{{Array.new(U32, 10n, 0), 4096}}, False{{}}) : O.Words & Bool}}:
  {{==}}

def cells_append_one_word_refused() -> {{Cells.l4096_b2048_append(O.Words{{Array.new(U32, 10n, 0), 2048}}, O.Words{{Array.new(U32, 1n, 4294967295), 2048}}) == (O.Words{{Array.new(U32, 10n, 0), 2048}}, False{{}}) : O.Words & Bool}}:
  {{==}}

# ---- R2-04: the checked decoder looks at the words the buffer holds, not at its size field ----
def decode_checked_lying_buf_refused() -> {{PlR.proglist_uint8_decode_checked(B.Buf{{Array.new(U32, 1n, 0), 2147483647}}, 2147483647) == (B.Buf{{Array.new(U32, 1n, 0), 2147483647}}, None{{}}) : B.Buf & Maybe<&1, O.Words>}}:
  {{==}}
"""


def outputs():
    return {LAYOUT.module_path("crash", "crash_fix_laws"): MODULE}


def main():
    out = outputs()
    LAYOUT.check_or_write(out, "stale crash-fix laws: ", "crash-fix laws are current", "--check" in sys.argv)
    if "--check" not in sys.argv:
        print(f"{len(out)} module")


if __name__ == "__main__":
    main()
