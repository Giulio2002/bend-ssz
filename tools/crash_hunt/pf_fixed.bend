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
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as LV
import ../../types/FuluValidator_def_generated.bend as Va
import ../../types/FuluPendingDeposit_def_generated.bend as Pd
import ../../types/Fulu_list_Attestation_8_def_generated.bend as L8
import ../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as L8H
import ../../types/FuluAttestation_def_generated.bend as At
import ../../types/Fulu_list_Withdrawal_16_def_generated.bend as LW
import ../../types/FuluWithdrawal_def_generated.bend as Wd
import ../../types/Fulu_list_Withdrawal_16_encode_ssz_generated.bend as LWE
import ../../types/proglist_uint8_encode_ssz_generated.bend as PlE
import ../../types/Fulu_list_PendingDeposit_134217728_encode_ssz_generated.bend as LPDE
import ../../types/Fulu_list_Validator_1099511627776_encode_ssz_generated.bend as LVE
import ../../types/ProgressiveTestStruct_def_generated.bend as PtD
import ../../types/ProgressiveTestStruct_encode_ssz_generated.bend as PtE
import ../../types/CompatibleUnionBC_def_generated.bend as UbD
import ../../types/CompatibleUnionBC_encode_ssz_generated.bend as UbE
import ../../types/ProgressiveSingleListContainerTestStruct_def_generated.bend as PslD
import ../../types/proglist_proglist_VarTestStruct_def_generated.bend as PpD
import ../../types/proglist_proglist_VarTestStruct_encode_ssz_generated.bend as PpE
import ../../types/proglist_VarTestStruct_def_generated.bend as PvD
import ../../types/Fulu_list_Deposit_16_def_generated.bend as LdD
import ../../types/Fulu_list_Deposit_16_hashtreeroot_generated.bend as LdH
import ../../types/FuluDeposit_def_generated.bend as DpD
import ../../types/FuluDepositData_def_generated.bend as DdD

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

# R3-02: an append to an object that claims more elements than its storage holds is refused, and does not allocate or copy for the claim
def va_line(label: String, pair: LV.l1099511627776_Validator_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case LV.l1099511627776_Validator_Seq{arr, +n}: IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " len=" ++ U32.show(n))
def case31() -> IO(Unit): va_line("validator_claim_67108864", LV.l1099511627776_Validator_append(LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(0n), 67108864}, Va.Validator_default()))
def pd_line(label: String, pair: LPD.l134217728_PendingDeposit_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case LPD.l134217728_PendingDeposit_Seq{arr, +n}: IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " len=" ++ U32.show(n))
def case32() -> IO(Unit): pd_line("pending_deposit_claim_33554432", LPD.l134217728_PendingDeposit_append(LPD.l134217728_PendingDeposit_Seq{LPD.l134217728_PendingDeposit_fill(0n), 33554432}, Pd.PendingDeposit_default()))
def case33() -> IO(Unit): flag_line("pl_u8_claim_2gib", PlD.pl_u8_append(O.Words{Array.new(U32, 8n, 0), 2147483647}, 7))
def case34() -> IO(Unit): bits_flag_line("pbits_claim_2g", PbD.pbits_append(O.Bits{Array.new(U32, 4n, 0), 2147483647}, True{}))
def cv_line(label: String, pair: LV.l1099511627776_Validator_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  match c:
    case LV.l1099511627776_Validator_Cached{arr, +n, +d, nodes, +lo, +hi}: IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " len=" ++ U32.show(n))
def case35() -> IO(Unit): cv_line("validator_capp_claim_67108864", LV.l1099511627776_Validator_capp(LV.l1099511627776_Validator_cache(LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(0n), 67108864}), Va.Validator_default()))
def len_of(t: +List<U32>, +acc: U32) -> U32:
  match t:
    case Nil{}: acc
    case Con{+h, tl}: len_of(tl, (acc + 1 : U32))
def case36() -> IO(Unit): IO.print("dump_len=" ++ U32.show(len_of(PlD.pl_u8_dump(O.Words{Array.new(U32, 2n, 0), 100000000}, Nil{}), 0)))
def force_line(pair: L8.l8_Attestation_Seq & U32) -> IO(Unit):
  (o, +x) = pair
  IO.print("force_claim_100000000=" ++ U32.show(x))
def case37() -> IO(Unit): force_line(L8.l8_Attestation_force(L8.l8_Attestation_Seq{L8.l8_Attestation_fill(0n), 100000000}))

# R3-01: `_get` of an unboxed list leaves it valid; the cached `_ctake` of a boxed list marks the slot dirty, so the cached root is the plain root
def w_valid_line(pair: LW.l16_Withdrawal_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("valid_after_get=" ++ O.pick_str(ok))
def w_get_valid(pair: LW.l16_Withdrawal_Seq & Maybe<&1, Wd.Withdrawal>) -> IO(Unit):
  (o, m) = pair
  w_valid_line(LWE.l16_Withdrawal_valid(o))
def w_one(pair: LW.l16_Withdrawal_Seq & Bool) -> LW.l16_Withdrawal_Seq:
  (o, ok) = pair
  o
def case38() -> IO(Unit): w_get_valid(LW.l16_Withdrawal_get(w_one(LW.l16_Withdrawal_append(LW.l16_Withdrawal_default(), Wd.Withdrawal_default())), 0))
def tk3(label: String, d_c: D.Digest, pair: B.Buf & (L8.l8_Attestation_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d_p) = r
  IO.print(label ++ "=" ++ O.pick_str(dig_eq(d_c, d_p)))
def tk2(label: String, d_c: D.Digest, pair: L8.l8_Attestation_Seq & Maybe<&1, At.Attestation>) -> IO(Unit):
  (o, m) = pair
  tk3(label, d_c, L8H.l8_Attestation_root(64n, O.hasher(), o, 0))
def tk1(label: String, o2: L8.l8_Attestation_Seq, pair: B.Buf & (L8.l8_Attestation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d_c) = r
  tk2(label, d_c, L8.l8_Attestation_take(o2, 0))
def tk0(label: String, o2: L8.l8_Attestation_Seq, pair: L8.l8_Attestation_Cached & Maybe<&1, At.Attestation>) -> IO(Unit):
  (c, m) = pair
  tk1(label, o2, L8.l8_Attestation_cached_root(64n, O.hasher(), c, 0))
def ctk0(label: String, o2: L8.l8_Attestation_Seq, pair: B.Buf & (L8.l8_Attestation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  tk0(label, o2, L8.l8_Attestation_ctake(c, 0))
def one_att(pair: L8.l8_Attestation_Seq & Bool) -> L8.l8_Attestation_Seq:
  (o, ok) = pair
  o
def mk_att() -> L8.l8_Attestation_Seq: one_att(L8.l8_Attestation_append(L8.l8_Attestation_default(), At.Attestation_default()))
def case39() -> IO(Unit): ctk0("cached_root_after_ctake_equals_plain_root_after_take", mk_att(), L8.l8_Attestation_cached_root(64n, O.hasher(), L8.l8_Attestation_cache(mk_att()), 0))

# CH-06 (agent/decode-window): `X_decode` itself refuses a window that is not inside the buffer (size > B.size(buf), also at 2^32 - 1
# where an off + size would wrap); the window inside the buffer, and the empty window of an empty buffer, are decoded
def maybe_w(label: String, pair: B.Buf & Maybe<&1, O.Words>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")
def case40() -> IO(Unit): maybe_line("decode_empty_buf_40", CpR.Checkpoint_decode(B.empty(), 40))
def case41() -> IO(Unit): maybe_line("decode_40_control", CpR.Checkpoint_decode(B.alloc(40), 40))
def case42() -> IO(Unit): maybe_line("decode_window_41_of_40", CpR.Checkpoint_decode(B.alloc(40), 41))
def case43() -> IO(Unit): maybe_line("decode_window_2_pow_32_minus_1", CpR.Checkpoint_decode(B.alloc(40), 4294967295))
def case44() -> IO(Unit): maybe_w("decode_empty_list_empty_buf", PlR.proglist_uint8_decode(B.empty(), 0))
def case45() -> IO(Unit): maybe_w("decode_list_window_5_of_empty_buf", PlR.proglist_uint8_decode(B.empty(), 5))

# size-limit (agent/size-limit, docs/SIZE_LIMIT_DESIGN.md): a valid object is up to NMAX = 2^32 - 32 bytes; the size pass neither wraps n * es
# nor takes a size past NMAX for valid; an unchecked encode of such a size refuses (empty buffer) before it allocates. The storage is a
# lazily shared zero tree of depth 30 (2^30 words), so no case touches gigabytes.
def big() -> Array<U32>: Array.new(U32, 30n, 0)
def size_line(label: String, pair: O.Words & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def enc_len_line(label: String, pair: O.Words & B.Buf) -> IO(Unit):
  (o, b) = pair
  IO.print(label ++ "_len=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
def ser_words_line(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ " ok=" ++ O.pick_str(ok))
def case46() -> IO(Unit): size_line("size_2_pow_31_plus_1", PlE.pl_u8_size(O.Words{big(), 2147483649}))
def case47() -> IO(Unit): size_line("size_nmax", PlE.pl_u8_size(O.Words{big(), 4294967264}))
def case48() -> IO(Unit): size_line("size_2_pow_32_minus_2", PlE.pl_u8_size(O.Words{big(), 4294967294}))
def case49() -> IO(Unit): enc_len_line("encode_2_pow_32_minus_2", PlE.proglist_uint8_encode(O.Words{big(), 4294967294}))
def case50() -> IO(Unit): ser_words_line("serialize_2_pow_32_minus_2", PlE.proglist_uint8_serialize(O.Words{big(), 4294967294}))
def pd_size_line(label: String, pair: LPD.l134217728_PendingDeposit_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def pds(+n: U32) -> LPD.l134217728_PendingDeposit_Seq: LPD.l134217728_PendingDeposit_Seq{LPD.l134217728_PendingDeposit_fill(25n), n}
def case51() -> IO(Unit): pd_size_line("pd_size_22369621", LPDE.l134217728_PendingDeposit_size(pds(22369621)))
def case52() -> IO(Unit): pd_size_line("pd_size_22369622", LPDE.l134217728_PendingDeposit_size(pds(22369622)))
def va_size_line(label: String, pair: LV.l1099511627776_Validator_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def vas(+n: U32) -> LV.l1099511627776_Validator_Seq: LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(26n), n}
def case53() -> IO(Unit): va_size_line("validator_size_17747799", LVE.l1099511627776_Validator_size(vas(17747799)))
def case54() -> IO(Unit): va_size_line("validator_size_35495597", LVE.l1099511627776_Validator_size(vas(35495597)))
def case55() -> IO(Unit): va_size_line("validator_size_35495598", LVE.l1099511627776_Validator_size(vas(35495598)))
def case56() -> IO(Unit): va_line("validator_append_at_17747798", LV.l1099511627776_Validator_append(vas(17747798), Va.Validator_default()))
def case57() -> IO(Unit): va_line("validator_append_at_35495597", LV.l1099511627776_Validator_append(vas(35495597), Va.Validator_default()))


# crash-fix5 (docs/CRASH_HUNT.md round 4): R4-01 the clean copy of the root path is sized without the wrap of n + 31 (8 words before);
# R4-05 `_valid` agrees with `_serialize` above NMAX (packed lists, fixed-size element counts, containers); R4-04 a union's size keeps the
# marker of an invalid payload (0 before); R4-03 the offset table of a list of variable-size elements is checked (4 n wrapped to 0 before);
# the cached root after `_ctake` is the plain root of the returned list (an absent box stays absent through the root).
def case58() -> IO(Unit): IO.print("copy_words_4294967292=" ++ U32.show(Pair.snd(Array<U32>, U32, Array.size(U32, O.zeros_copy(4294967292)))))
def valid_w_line(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ "=" ++ O.pick_str(ok))
def case59() -> IO(Unit): valid_w_line("pl_u8_valid_nmax_plus_1", PlE.pl_u8_valid(O.Words{big(), 4294967265}))
def case60() -> IO(Unit): valid_w_line("pl_u8_valid_nmax", PlE.pl_u8_valid(O.Words{big(), 4294967264}))
def va_valid_line(label: String, pair: LV.l1099511627776_Validator_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ "=" ++ O.pick_str(ok))
def case61() -> IO(Unit): va_valid_line("validator_valid_35495598", LVE.l1099511627776_Validator_valid(vas(35495598)))
def pt_valid_fin(label: String, +m: U32, pair: PtD.ProgressiveTestStruct & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " size=" ++ U32.show(m) ++ " valid=" ++ O.pick_str(ok))
def pt_valid_line(label: String, pair: PtD.ProgressiveTestStruct & U32) -> IO(Unit):
  (o, +m) = pair
  pt_valid_fin(label, m, PtE.ProgressiveTestStruct_valid(o))
def pts(+a: U32) -> PtD.ProgressiveTestStruct: PtD.ProgressiveTestStruct_set_f_A(PtD.ProgressiveTestStruct_default(), O.Words{big(), a})
def case62() -> IO(Unit): pt_valid_line("pts_f_A_4294967249", PtE.ProgressiveTestStruct_size(pts(4294967249)))
def case63() -> IO(Unit): pt_valid_line("pts_f_A_4294967248", PtE.ProgressiveTestStruct_size(pts(4294967248)))
def ub_size_line(label: String, pair: UbD.CompatibleUnionBC & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def case64() -> IO(Unit): ub_size_line("union_size_invalid_payload", UbE.CompatibleUnionBC_size(UbD.CompatibleUnionBC_c0{PslD.ProgressiveSingleListContainerTestStruct{O.Bits{Array.new(U32, 0n, 0), 4294967295}}}))
def pp_size_line(label: String, pair: PpD.pl_pl_VarTestStruct_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def case65() -> IO(Unit): pp_size_line("plpl_offset_table_2_pow_30", PpE.pl_pl_VarTestStruct_sz_fin(1073741824, (PpD.pl_pl_VarTestStruct_fill(0n), (0, O.BNone{}))))
def dep(+x: U32) -> DpD.Deposit: DpD.Deposit_set_data(DpD.Deposit_default(), DdD.DepositData_bx_wrap(DdD.DepositData_seed(x)))
def dbuild(+k: Nat, +i: U32, o: LdD.l16_Deposit_Seq) -> LdD.l16_Deposit_Seq:
  match k:
    case 0n: o
    case 1n+q: dbuild(q, (i + 1 : U32), Pair.fst(LdD.l16_Deposit_Seq, Bool, LdD.l16_Deposit_append(o, dep((i + 1 : U32)))))
def dcroot(c: LdD.l16_Deposit_Cached) -> LdD.l16_Deposit_Cached & D.Digest: Pair.snd(B.Buf, LdD.l16_Deposit_Cached & D.Digest, LdD.l16_Deposit_cached_root(64n, O.hasher(), c, 0))
def dproot(o: LdD.l16_Deposit_Seq) -> D.Digest: Pair.snd(LdD.l16_Deposit_Seq, D.Digest, Pair.snd(B.Buf, LdD.l16_Deposit_Seq & D.Digest, LdH.l16_Deposit_root(64n, O.hasher(), o, 0)))
def dcmp(pair: LdD.l16_Deposit_Cached & D.Digest) -> IO(Unit):
  (c, +r) = pair
  IO.print("deposit_ctake_cached_root_eq_plain=" ++ O.pick_str(D.equal(r, dproot(LdD.l16_Deposit_uncache(c)))))
def dtake(pair: LdD.l16_Deposit_Cached & Maybe<&1, DpD.Deposit>) -> IO(Unit):
  (c, m) = pair
  dcmp(dcroot(c))
def dafter(pair: LdD.l16_Deposit_Cached & D.Digest) -> IO(Unit):
  (c, +r) = pair
  dtake(LdD.l16_Deposit_ctake(c, 1))
def case66() -> IO(Unit): dafter(dcroot(LdD.l16_Deposit_cache(dbuild(3n, 0, LdD.l16_Deposit_default()))))

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
    case 31: case31()
    case 32: case32()
    case 33: case33()
    case 34: case34()
    case 35: case35()
    case 36: case36()
    case 37: case37()
    case 38: case38()
    case 39: case39()
    case 40: case40()
    case 41: case41()
    case 42: case42()
    case 43: case43()
    case 44: case44()
    case 45: case45()
    case 46: case46()
    case 47: case47()
    case 48: case48()
    case 49: case49()
    case 50: case50()
    case 51: case51()
    case 52: case52()
    case 53: case53()
    case 54: case54()
    case 55: case55()
    case 56: case56()
    case 57: case57()
    case 58: case58()
    case 59: case59()
    case 60: case60()
    case 61: case61()
    case 62: case62()
    case 63: case63()
    case 64: case64()
    case 65: case65()
    case 66: case66()
    case _: case12()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
