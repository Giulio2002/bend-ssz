import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/Fulu_list_bytevec_2048_4096_def_generated.bend as Cells
import ../../types/proglist_uint8_def_generated.bend as PlD
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/Fulu_bitlist_2048_def_generated.bend as B2048
import ../../types/Fulu_bitlist_2048_hashtreeroot_generated.bend as B2048H
import ../../types/proglist_uint8_hashtreeroot_generated.bend as PlH
import ../../src/digest.bend as D
import ../../types/FuluCheckpoint_def_generated.bend as CpD
import ../../types/FuluCheckpoint_decode_ssz_generated.bend as CpR
import ../../types/ComplexTestStruct_def_generated.bend as CtD
import ../../types/Fulu_list_uint64_1099511627776_def_generated.bend as L64
import ../../types/proglist_uint16_def_generated.bend as P16
import ../../types/proglist_uint32_def_generated.bend as P32
import ../../types/proglist_uint64_def_generated.bend as P64
import ../../types/proglist_uint8_decode_ssz_generated.bend as PlR
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as LPD
import ../../types/Fulu_list_PendingDeposit_134217728_hashtreeroot_generated.bend as LPDH
import ../../types/FuluAttesterSlashing_def_generated.bend as AsD
import ../../types/FuluAttesterSlashing_encode_ssz_generated.bend as AsE
import ../../types/FuluIndexedAttestation_def_generated.bend as IaD
import ../../types/ComplexTestStruct_encode_ssz_generated.bend as CtE
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt regression probe: the cases of docs/CRASH_HUNT.md CH-01, CH-04, CH-05, CH-06 and CH-10 after their fixes.
# SSZ_CASE selects a case; each prints one line. tools/crash_hunt/regress.sh runs them all against regress_expected.txt.

def flag_line(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ "=" ++ O.pick_str(ok))

def bits_flag_line(label: String, pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ "=" ++ O.pick_str(ok))

def cells2() -> O.Words: O.Words{Array.new(U32, 10n, 0), 4096}

# CH-01: a cell is exactly 2048 bytes; any other length is refused (it used to copy by the argument's length)
def case1() -> IO(Unit): flag_line("cell_set_empty", Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 3n, 0), 0}))
def case2() -> IO(Unit): flag_line("cell_set_4096_at_1", Cells.l4096_b2048_set(cells2(), 1, O.Words{Array.new(U32, 10n, 4294967295), 4096}))
def case3() -> IO(Unit): flag_line("cell_set_64", Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 5n, 4294967295), 64}))
def case4() -> IO(Unit): flag_line("cell_append_empty", Cells.l4096_b2048_append(cells2(), O.Words{Array.new(U32, 3n, 0), 0}))
def case5() -> IO(Unit): flag_line("cell_set_2048_control", Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 9n, 7), 2048}))

# CH-04: a count of 2^32 - 1 elements is full: the append is refused (n + 1 used to wrap to 0)
def case6() -> IO(Unit): bits_flag_line("pbits_append_max", PbD.pbits_append(O.Bits{Array.new(U32, 1n, 0), 4294967295}, True{}))
def case7() -> IO(Unit): bits_flag_line("bits2048_append_max", B2048.bits2048_append(O.Bits{Array.new(U32, 1n, 0), 4294967295}, True{}))
def case8() -> IO(Unit): flag_line("pl_u8_append_max", PlD.pl_u8_append(O.Words{Array.new(U32, 4n, 0), 4294967295}, 7))

# CH-05, CH-06: the checked decoder refuses a window outside the buffer or at 2^31 bytes or more
def maybe_line(label: String, pair: B.Buf & Maybe<&1, CpD.Checkpoint>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")
def case9() -> IO(Unit): maybe_line("decode_checked_empty_buf_40", CpR.Checkpoint_decode_checked(B.empty(), 40))
def case10() -> IO(Unit): maybe_line("decode_checked_40_control", CpR.Checkpoint_decode_checked(B.alloc(40), 40))
def case11() -> IO(Unit): maybe_line("decode_checked_2gib", CpR.Checkpoint_decode_checked(B.alloc(40), 2147483648))

# CH-10: the default of a container with a vector of variable-size elements serializes to the spec's 100 bytes
def ct_line(pair: CtD.ComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: IO.print("complex_default_serialize_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
def case12() -> IO(Unit): ct_line(CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default()))

# CH-03: the root of a 16-byte object that claims 2^32 - 1 bytes (or bits) is bounded by its storage (it used to hash 2^27 chunks, 75 s)
def root_done(label: String, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  match d:
    case D.D{a, b1, c, d1, e, f, g, h}: IO.print(label ++ "=done")
def bits_root_done(label: String, pair: B.Buf & (O.Bits & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  match d:
    case D.D{a, b1, c, d1, e, f, g, h}: IO.print(label ++ "=done")
def case13() -> IO(Unit): root_done("pl_u8_root_huge_claim", PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{Array.new(U32, 2n, 0), 4294967295}))
def case14() -> IO(Unit): bits_root_done("bits2048_root_huge_claim", B2048H.bits2048_root(64n, O.hasher(), O.Bits{Array.new(U32, 2n, 0), 4294967295}, 0))

# ---- round 2 (docs/CRASH_HUNT.md R2-01 .. R2-06, CH-11, CH-12) --------------------------------------------------------------------
def tiny() -> Array<U32>: Array.new(U32, 4n, 0)

# R2-01, R2-06: every list kind guards its append against the wrap of (n + 1) * size and of its chunk rounding
def case15() -> IO(Unit): flag_line("u64list_append_max", L64.l1099511627776_u64_append(O.Words{tiny(), 4294967288}, O.U64{1, 2}))
def case16() -> IO(Unit): flag_line("pl_u16_append_max", P16.pl_u16_append(O.Words{tiny(), 4294967294}, 7))
def case17() -> IO(Unit): flag_line("pl_u32_append_max", P32.pl_u32_append(O.Words{tiny(), 4294967292}, 7))
def case18() -> IO(Unit): flag_line("pl_u64_append_max", P64.pl_u64_append(O.Words{tiny(), 4294967288}, O.U64{1, 2}))
def case19() -> IO(Unit): flag_line("pl_u8_append_chunk_wrap", PlD.pl_u8_append(O.Words{tiny(), 4294967264}, 7))

# R2-05: a cell whose storage is smaller than the cell is refused
def case20() -> IO(Unit): flag_line("cell_set_one_word", Cells.l4096_b2048_set(O.Words{Array.new(U32, 10n, 7), 4096}, 0, O.Words{Array.new(U32, 1n, 4294967295), 2048}))
def case21() -> IO(Unit): flag_line("cell_append_one_word", Cells.l4096_b2048_append(O.Words{Array.new(U32, 10n, 7), 2048}, O.Words{Array.new(U32, 1n, 4294967295), 2048}))

# R2-04: the checked decoder looks at the words of the buffer's array, not at its size field
def maybe_words_line(label: String, pair: B.Buf & Maybe<&1, O.Words>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")
def case22() -> IO(Unit): maybe_words_line("decode_checked_lying_buf", PlR.proglist_uint8_decode_checked(B.Buf{Array.new(U32, 1n, 0), 2147483647}, 2147483647))

# R2-03: the root of a list of composites and the cache are bounded by the storage, not by the claimed count
def pd_done(label: String, pair: B.Buf & (LPD.l134217728_PendingDeposit_Seq & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  match d:
    case D.D{a, b1, c, d1, e, f, g, h}: IO.print(label ++ "=done")
def case23() -> IO(Unit): pd_done("pd_root_huge_claim", LPDH.l134217728_PendingDeposit_root(64n, O.hasher(), LPD.l134217728_PendingDeposit_Seq{LPD.l134217728_PendingDeposit_fill(0n), 10000000}, 0))
def cache_done(label: String, pair: LPD.l134217728_PendingDeposit_Cached & U32) -> IO(Unit):
  (c, +n) = pair
  IO.print(label ++ "=done")
def case24() -> IO(Unit): cache_done("pd_cache_huge_claim", LPD.l134217728_PendingDeposit_clen(LPD.l134217728_PendingDeposit_cache(LPD.l134217728_PendingDeposit_Seq{LPD.l134217728_PendingDeposit_fill(0n), 100000000})))
def case25() -> IO(Unit): cache_done("pd_cache_at_huge_depth", LPD.l134217728_PendingDeposit_clen(LPD.l134217728_PendingDeposit_cache_at(LPD.l134217728_PendingDeposit_fill(0n), 8, 40n)))

# CH-11 (R2-02 c): a valid object of tight storage (ceil(n / 4) words, less than the 8 words per chunk the root reads) has the root of
# the same bytes in roomy storage
def dig_eq(d1: D.Digest, d2: D.Digest) -> Bool:
  match d1 d2:
    case D.D{a0, a1, a2, a3, a4, a5, a6, a7} D.D{b0, b1, b2, b3, b4, b5, b6, b7}:
      Bool.and(Bool.and(Bool.and(U32.is_eq(a0, b0), U32.is_eq(a1, b1)), Bool.and(U32.is_eq(a2, b2), U32.is_eq(a3, b3))), Bool.and(Bool.and(U32.is_eq(a4, b4), U32.is_eq(a5, b5)), Bool.and(U32.is_eq(a6, b6), U32.is_eq(a7, b7))))
def same_fin(label: String, d1: D.Digest, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h2, r2) = pair
  (o2, d2) = r2
  IO.print(label ++ "=" ++ O.pick_str(dig_eq(d1, d2)))
def same_digest(label: String, p1: B.Buf & (O.Words & D.Digest), p2: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h1, r1) = p1
  (o1, d1) = r1
  same_fin(label, d1, p2)
def case26() -> IO(Unit): same_digest("tight_root_equals_roomy", PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{Array.new(U32, 0n, 7), 1}), PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{Array.set(U32, Array.new(U32, 4n, 0), 0, 7), 1}))

# R2-02 (b): garbage in the words past the length inside the last chunk does not change the root of a valid object
def dirty8() -> Array<U32>: Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1, 2), 6, 3735928559)
def clean8() -> Array<U32>: Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1, 2)
def case30() -> IO(Unit): same_digest("dirty_root_equals_clean", PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{dirty8(), 8}), PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{clean8(), 8}))

# CH-12: an absent box makes the container invalid, and `_serialize` refuses it
def ser_ok_line(label: String, pair: AsD.AttesterSlashing & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ " ok=" ++ O.pick_str(ok))
def none() -> O.Boxed<IaD.IndexedAttestation>: O.BNone{}
def dflt() -> O.Boxed<IaD.IndexedAttestation>: IaD.IndexedAttestation_bx_default()
def case27() -> IO(Unit): ser_ok_line("attestation_1_absent", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing{none(), dflt()}))
def case28() -> IO(Unit): ser_ok_line("attestation_2_absent", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing{dflt(), none()}))
def case29() -> IO(Unit): ser_ok_line("both_present_control", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing_default()))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: case1()
    case 2: case2()
    case 3: case3()
    case 4: case4()
    case 5: case5()
    case 6: case6()
    case 7: case7()
    case 8: case8()
    case 9: case9()
    case 10: case10()
    case 11: case11()
    case 13: case13()
    case 14: case14()
    case 15: case15()
    case 16: case16()
    case 17: case17()
    case 18: case18()
    case 19: case19()
    case 20: case20()
    case 21: case21()
    case 22: case22()
    case 23: case23()
    case 24: case24()
    case 25: case25()
    case 26: case26()
    case 27: case27()
    case 28: case28()
    case 29: case29()
    case 30: case30()
    case _: case12()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
