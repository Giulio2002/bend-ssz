#!/usr/bin/env python3
"""Zero-run lemmas of the symbolic decoder-acceptance witness of FuluBeaconState: e2e/e2e_zero_run_generated.bend.

The decode-acceptance witnesses (codegen/proofs/witnesses/decoder_acceptance_witnesses.py) evaluate the decoder's window check over the real input
bytes. The default BeaconState is 2.7 MB and almost all zero (its fixed-size vectors); no route that forms the byte list, or the
tree built from it, fits the checker (docs/BS_WITNESS_DESIGN.md). The symbolic route states the input as a zero run in front of a
tail and proves what the composed theorems' premises need by induction on the run, so no 2.7 MB list is ever evaluated. This is its
first slice: the three list facts, by induction on the number of zero bytes (`UW.ZB(m)`) or zero words (`ZW(m)`), and the window
check of a u64 list (the largest zero-run field kind: balances, inactivity scores), which reads no byte at all.

  zr_dom(m, r)    bytes_domain(ZB(m) ++ r) == bytes_domain(r)            hd of the composed theorems
  zr_len(m, r)    length(ZB(m) ++ r) == m + length(r)                    hn
  zr_wlp(m, r)    wlp(ZB(4 m) ++ r) == ZW(m) ++ wlp(r)                  the words the loader packs (the tree's slots)
  zr_dom0(m)      bytes_domain(ZB(m)) == True                            a run on its own
  u64l_window(buf, off, len)   the u64 list's window check is `len` a multiple of 8, whatever the buffer, offset and bytes
  u64l_zero_window(buf, off)   ... so a window of 2^20 words (8388608 bytes) of zeros is accepted: no list, no tree evaluated

    python3 codegen/proofs/witnesses/zero_run_lemmas.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402

OUT = ROOT / 'e2e' / 'e2e_zero_run_generated.bend'
IMPORTS = """import Base
import ../src/buffer.bend as B
import ../proofs/compact/arith.bend as A
import ../proofs/obj/vuw.bend as UW
import ../spec/primitives.bend as SP
import ../types/Fulu_list_uint64_1099511627776_decode_ssz_generated.bend as U64L
import ./e2e_load.bend as L
"""
BODY = r"""
# zero words: the packed form of zero bytes
def ZW(+m: Nat) -> List<&2, U32>:
  match m:
    case 0n: Nil{}
    case 1n+ +p: Con{0, ZW(p)}

def zr_dom(+m: Nat, +r: +List<U32>) -> {SP.bytes_domain(List.append(&2, U32, UW.ZB(m), r)) == SP.bytes_domain(r) : Bool}:
  match m:
    case 0n: {==}
    case 1n+ +p:
      Equal.trans(Bool, SP.bytes_domain(List.append(&2, U32, UW.ZB(1n+p), r)), SP.bytes_domain(List.append(&2, U32, UW.ZB(p), r)), SP.bytes_domain(r), {==}, zr_dom(p, r))

def zr_dom0(+m: Nat) -> {SP.bytes_domain(UW.ZB(m)) == True{} : Bool}:
  match m:
    case 0n: {==}
    case 1n+ +p:
      Equal.trans(Bool, SP.bytes_domain(UW.ZB(1n+p)), SP.bytes_domain(UW.ZB(p)), True{}, {==}, zr_dom0(p))

def zr_len(+m: Nat, +r: +List<U32>) -> {List.length(&2, U32, List.append(&2, U32, UW.ZB(m), r)) == Nat.add(m, List.length(&2, U32, r)) : Nat}:
  match m:
    case 0n: {==}
    case 1n+ +p:
      Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, List.append(&2, U32, UW.ZB(p), r)), Nat.add(p, List.length(&2, U32, r)), zr_len(p, r))

def zr_wlp(+m: Nat, +r: +List<U32>) -> {L.wlp(List.append(&2, U32, UW.ZB(A.quad(m)), r)) == List.append(&2, U32, ZW(m), L.wlp(r)) : List<&2, U32>}:
  match m:
    case 0n: {==}
    case 1n+ +p:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{0, z}, L.wlp(List.append(&2, U32, UW.ZB(A.quad(p)), r)), List.append(&2, U32, ZW(p), L.wlp(r)), zr_wlp(p, r))

# the u64 list's window check reads no byte: it is `len` a multiple of 8
def u64l_window(buf: B.Buf, +off: U32, +len: U32)
    -> {U64L.l1099511627776_u64_ok(buf, off, len) == (buf, Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{})) : B.Buf & Bool}:
  {==}

# a window of 2^20 words of zeros (8388608 bytes), whatever the buffer holds: accepted, evaluating no byte
def u64l_zero_window(buf: B.Buf, +off: U32)
    -> {U64L.l1099511627776_u64_ok(buf, off, 8388608) == (buf, True{}) : B.Buf & Bool}:
  {==}
"""


def outputs():
    return {OUT: IMPORTS + '\n' + writer.header('zero_run_lemmas') + '\n# the zero-run lemmas of the symbolic BeaconState decode witness (docs/BS_WITNESS_DESIGN.md)\n' + BODY}


def main():
    out = outputs()
    if '--check' in sys.argv:
        return writer.check(out, 'stale zero_run_lemmas: ', 'zero_run_lemmas is current')
    writer.write(out)
    print(f'{len(out)} file')


if __name__ == '__main__':
    main()
