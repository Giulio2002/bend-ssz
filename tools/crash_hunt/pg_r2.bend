import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/Fulu_list_uint64_1099511627776_def_generated.bend as L64
import ../../types/proglist_uint8_def_generated.bend as P8
import ../../types/proglist_uint16_def_generated.bend as P16
import ../../types/proglist_uint32_def_generated.bend as P32
import ../../types/proglist_uint64_def_generated.bend as P64
import ../../types/proglist_uint128_def_generated.bend as P128
import ../../types/proglist_uint256_def_generated.bend as P256
import ../../types/proglist_bool_def_generated.bend as PB
import ../../types/uint128_def_generated.bend as U128
import ../../types/uint256_def_generated.bend as U256
import ../../types/Fulu_list_bytevec_2048_4096_def_generated.bend as Cells
import ../../types/FuluAttestation_def_generated.bend as Att
import ../../types/Fulu_list_Attestation_8_def_generated.bend as L8
import ../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as L8H
import ../../types/Fulu_list_Attestation_8_encode_ssz_generated.bend as L8E
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as LPD
import ../../types/Fulu_list_PendingDeposit_134217728_hashtreeroot_generated.bend as LPDH
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/Fulu_bitlist_131072_def_generated.bend as B131
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt round 2, probe G: fix bypass variants and composite-list objects with a claimed count.
# SSZ_CASE selects the case, SSZ_ARG its parameter.

def tiny() -> Array<U32>: Array.new(U32, 4n, 0)

# ---- appends on packed lists near the 2^32 byte limit ---------------------------------
def app_after(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case O.Words{ws, +n}: IO.print(label ++ " append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))

def c1(+n: U32) -> IO(Unit): app_after("u64list", L64.l1099511627776_u64_append(O.Words{tiny(), n}, O.U64{1, 2}))
def c2(+n: U32) -> IO(Unit): app_after("pl_u16", P16.pl_u16_append(O.Words{tiny(), n}, 7))
def c3(+n: U32) -> IO(Unit): app_after("pl_u32", P32.pl_u32_append(O.Words{tiny(), n}, 7))
def c4(+n: U32) -> IO(Unit): app_after("pl_u64", P64.pl_u64_append(O.Words{tiny(), n}, O.U64{1, 2}))
def c5(+n: U32) -> IO(Unit): app_after("pl_u128", P128.pl_u128_append(O.Words{tiny(), n}, U128.u128_default()))
def c6(+n: U32) -> IO(Unit): app_after("pl_u256", P256.pl_u256_append(O.Words{tiny(), n}, U256.u256_default()))
def c7(+n: U32) -> IO(Unit): app_after("pl_u8", P8.pl_u8_append(O.Words{tiny(), n}, 7))
def c8(+n: U32) -> IO(Unit): app_after("pl_bool", PB.pl_bool_append(O.Words{tiny(), n}, True{}))

# ---- cell list: v claims 2048 bytes, storage smaller -----------------------------------
def cell_after(pair: O.Words & Bool) -> IO(Unit): app_after("cells", pair)
def c9() -> IO(Unit): cell_after(Cells.l4096_b2048_set(O.Words{Array.new(U32, 10n, 7), 4096}, 0, O.Words{Array.new(U32, 1n, 4294967295), 2048}))
def c10() -> IO(Unit): cell_after(Cells.l4096_b2048_append(O.Words{Array.new(U32, 10n, 7), 2048}, O.Words{Array.new(U32, 1n, 4294967295), 2048}))

# ---- composite list with claimed count and a tiny array ---------------------------------
def root_str(pair: B.Buf & (L8.l8_Attestation_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l8_root=" ++ IOx.words(d))
def c11(+n: U32) -> IO(Unit): root_str(L8H.l8_Attestation_root(64n, O.hasher(), L8.l8_Attestation_Seq{L8.l8_Attestation_fill(0n), n}, 0))

def root_pd(pair: B.Buf & (LPD.l134217728_PendingDeposit_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("pd_root=" ++ IOx.words(d))
def c12(+n: U32) -> IO(Unit): root_pd(LPDH.l134217728_PendingDeposit_root(64n, O.hasher(), LPD.l134217728_PendingDeposit_Seq{LPD.l134217728_PendingDeposit_fill(0n), n}, 0))

def cl_line(pair: L8.l8_Attestation_Cached & U32) -> IO(Unit):
  (c, +n) = pair
  IO.print("cached_len=" ++ U32.show(n))
def c13(+n: U32) -> IO(Unit): cl_line(L8.l8_Attestation_clen(L8.l8_Attestation_cache(L8.l8_Attestation_Seq{L8.l8_Attestation_fill(0n), n})))
def c14(+d: U32) -> IO(Unit): cl_line(L8.l8_Attestation_clen(L8.l8_Attestation_cache_at(L8.l8_Attestation_fill(0n), 8, U32.to_nat(d))))

def ok_line(pair: L8.l8_Attestation_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("valid=" ++ O.pick_str(ok))
def c15(+n: U32) -> IO(Unit): ok_line(L8E.l8_Attestation_valid(L8.l8_Attestation_Seq{L8.l8_Attestation_fill(0n), n}))

# ---- bit lists ----------------------------------------------------------------------------
def bits_after(label: String, pair: O.Bits & Bool) -> IO(Unit):
  (b, ok) = pair
  match b:
    case O.Bits{ws, +k}: IO.print(label ++ " append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(k))
def c16(+k: U32) -> IO(Unit): bits_after("bits131072", B131.bits131072_append(O.Bits{tiny(), k}, True{}))
def c17(+k: U32) -> IO(Unit): bits_after("pbits", PbD.pbits_append(O.Bits{tiny(), k}, True{}))

def dispatch(+c: U32, +a: U32) -> IO(Unit):
  match c:
    case 1: c1(a)
    case 2: c2(a)
    case 3: c3(a)
    case 4: c4(a)
    case 5: c5(a)
    case 6: c6(a)
    case 7: c7(a)
    case 8: c8(a)
    case 9: c9()
    case 10: c10()
    case 11: c11(a)
    case 12: c12(a)
    case 13: c13(a)
    case 14: c14(a)
    case 15: c15(a)
    case 16: c16(a)
    case _: c17(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    dispatch(c, a)
