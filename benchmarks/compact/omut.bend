import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/Fulu_list_uint64_131072_def_generated.bend as Fulu_list_uint64_131072_d
import ../../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../../types/FuluIndexedAttestation_decode_ssz_generated.bend as FuluIndexedAttestation_r
import ../../types/FuluIndexedAttestation_encode_ssz_generated.bend as FuluIndexedAttestation_e
import ../../types/Fulu_vec_bytevec_32_33_def_generated.bend as Fulu_vec_bytevec_32_33_d
import ../../types/FuluDeposit_def_generated.bend as FuluDeposit_d
import ../../types/FuluDeposit_decode_ssz_generated.bend as FuluDeposit_r
import ../../types/FuluDeposit_encode_ssz_generated.bend as FuluDeposit_e
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_decode_ssz_generated.bend as FuluValidator_r
import ../../types/FuluValidator_encode_ssz_generated.bend as FuluValidator_e
import ../../types/Fulu_bytelist_32_def_generated.bend as Fulu_bytelist_32_d
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/FuluExecutionPayloadHeader_decode_ssz_generated.bend as FuluExecutionPayloadHeader_r
import ../../types/FuluExecutionPayloadHeader_encode_ssz_generated.bend as FuluExecutionPayloadHeader_e
import ./objio.bend as IOx

# Mutation regressions on the typed object API (finite checks, not laws).
# SSZ_MODE selects the case; each decodes SSZ_INPUT, applies updates through
# the generated API and writes the re-encoded object to SSZ_OUTPUT, which
# tests_generated/mutations.py compares with the independently computed
# expectation. Rejection cases print STATUS=0 and must leave the value
# unchanged, which the same comparison checks.
#
#  0 Validator: effective_balance := SSZ_ARG, slashed := true
#  1 Validator: read back effective_balance after writing it (read-after-write)
#  2 Deposit: proof[0] := the 32 bytes 0x00..0x1f (vector element replacement)
#  3 Deposit: proof[33] := ... rejected (index equals the vector length)
#  4 ExecutionPayloadHeader: extra_data append of byte SSZ_ARG
#  5 IndexedAttestation: attesting_indices append of SSZ_ARG
#  6 IndexedAttestation: attesting_indices[0] := SSZ_ARG
#  7 IndexedAttestation: attesting_indices[len] := SSZ_ARG, rejected

def status(ok: Bool) -> IO(Unit):
  match ok:
    case True{}: IO.print("STATUS=1")
    case False{}: IO.print("STATUS=0")

def out_of(pair: B.Buf & U32) -> IO(Unit):
  (out, +n) = pair
  do IO<Unit>:
    IO.print("ENCODED=" ++ U32.show(n))
    IOx.write_out(out, n)

# ---- Validator -------------------------------------------------------------

def val_enc(ok: Bool, +v: FuluValidator_d.Validator) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(FuluValidator_e.Validator_encode(v)))

def val_set(+arg: U32, v: FuluValidator_d.Validator) -> IO(Unit):
  val_enc(True{}, FuluValidator_d.Validator_set_slashed(FuluValidator_d.Validator_set_effective_balance(v, O.U64{arg, 0}), True{}))

def val_read(+arg: U32, pair: FuluValidator_d.Validator & O.U64) -> IO(Unit):
  (v, +got) = pair
  do IO<Unit>:
    IO.print("READBACK=" ++ U32.show(O.u64_lo_of(got)))
    val_enc(O.u64_eq(got, O.U64{arg, 0}), v)

def val_rw(+arg: U32, v: FuluValidator_d.Validator) -> IO(Unit):
  val_read(arg, FuluValidator_d.Validator_get_effective_balance(FuluValidator_d.Validator_set_effective_balance(v, O.U64{arg, 0})))

def val_pick(+mode: U32, +arg: U32, +v: FuluValidator_d.Validator) -> IO(Unit):
  match mode:
    case 0: val_set(arg, v)
    case _: val_rw(arg, v)

def on_validator(+mode: U32, +arg: U32, m: Maybe<&1, FuluValidator_d.Validator>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{+v}: val_pick(mode, arg, v)

def validator(+mode: U32, +arg: U32, pair: B.Buf & Maybe<&1, FuluValidator_d.Validator>) -> IO(Unit):
  (buf, m) = pair
  on_validator(mode, arg, m)

# ---- Deposit: a vector element is replaced, out-of-range is rejected --------

def dep_enc(ok: Bool, d: FuluDeposit_d.Deposit) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(Pair.snd(FuluDeposit_d.Deposit, B.Buf, FuluDeposit_e.Deposit_encode(d))))

def dep_only(pr: FuluDeposit_d.Deposit & O.Words) -> FuluDeposit_d.Deposit:
  (d, old) = pr
  d

def dep_put(pr: FuluDeposit_d.Deposit & O.Words, proof: O.Words) -> FuluDeposit_d.Deposit:
  (d, old) = pr
  dep_only(FuluDeposit_d.Deposit_swap_proof(d, proof))

def dep_back(pr: FuluDeposit_d.Deposit & O.Words, res: O.Words & Bool) -> IO(Unit):
  (proof, ok) = res
  dep_enc(ok, dep_put(pr, proof))

def dep_take(+i: U32, pr: FuluDeposit_d.Deposit & O.Words) -> IO(Unit):
  (d, proof) = pr
  dep_back((d, O.words_new(0)), Fulu_vec_bytevec_32_33_d.v33_b32_set(proof, i, FuluBytes32_d.Bytes32{50462976, 117835012, 185207048, 252579084, 319951120, 387323156, 454695192, 522067228}))

def dep_set(+i: U32, d: FuluDeposit_d.Deposit) -> IO(Unit):
  dep_take(i, FuluDeposit_d.Deposit_swap_proof(d, O.words_new(0)))

def dep_pick(+mode: U32, d: FuluDeposit_d.Deposit) -> IO(Unit):
  match mode:
    case 2: dep_set(0, d)
    case _: dep_set(33, d)

def on_deposit(+mode: U32, m: Maybe<&1, FuluDeposit_d.Deposit>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{d}: dep_pick(mode, d)

def deposit(+mode: U32, pair: B.Buf & Maybe<&1, FuluDeposit_d.Deposit>) -> IO(Unit):
  (buf, m) = pair
  on_deposit(mode, m)

# ---- ExecutionPayloadHeader: a byte list append within its 32-byte limit ----

def eph_only(pr: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader & O.Words) -> FuluExecutionPayloadHeader_d.ExecutionPayloadHeader:
  (h, old) = pr
  h

def eph_enc(ok: Bool, h: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(Pair.snd(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, B.Buf, FuluExecutionPayloadHeader_e.ExecutionPayloadHeader_encode(h))))

def eph_back(h: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, res: O.Words & Bool) -> IO(Unit):
  (extra, ok) = res
  eph_enc(ok, eph_only(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_swap_extra_data(h, extra)))

def eph_take(+arg: U32, pr: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader & O.Words) -> IO(Unit):
  (h, extra) = pr
  eph_back(h, Fulu_bytelist_32_d.bl32_append(extra, arg))

def on_eph(+arg: U32, m: Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{h}: eph_take(arg, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_swap_extra_data(h, O.words_new(0)))

def eph(+arg: U32, pair: B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>) -> IO(Unit):
  (buf, m) = pair
  on_eph(arg, m)

# ---- IndexedAttestation: list append and element replacement ----------------

def ia_only(pr: FuluIndexedAttestation_d.IndexedAttestation & O.Words) -> FuluIndexedAttestation_d.IndexedAttestation:
  (a, old) = pr
  a

def ia_enc(ok: Bool, a: FuluIndexedAttestation_d.IndexedAttestation) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(Pair.snd(FuluIndexedAttestation_d.IndexedAttestation, B.Buf, FuluIndexedAttestation_e.IndexedAttestation_encode(a))))

def ia_back(a: FuluIndexedAttestation_d.IndexedAttestation, res: O.Words & Bool) -> IO(Unit):
  (idx, ok) = res
  ia_enc(ok, ia_only(FuluIndexedAttestation_d.IndexedAttestation_swap_attesting_indices(a, idx)))

def ia_op(+mode: U32, +arg: U32, +n: U32, a: FuluIndexedAttestation_d.IndexedAttestation, idx: O.Words) -> IO(Unit):
  match mode:
    case 5: ia_back(a, Fulu_list_uint64_131072_d.l131072_u64_append(idx, O.U64{arg, 0}))
    case 6: ia_back(a, Fulu_list_uint64_131072_d.l131072_u64_set(idx, 0, O.U64{arg, 0}))
    case _: ia_back(a, Fulu_list_uint64_131072_d.l131072_u64_set(idx, n, O.U64{arg, 0}))

def ia_len(+mode: U32, +arg: U32, a: FuluIndexedAttestation_d.IndexedAttestation, pair: O.Words & U32) -> IO(Unit):
  (idx, +n) = pair
  ia_op(mode, arg, n, a, idx)

def ia_take(+mode: U32, +arg: U32, pr: FuluIndexedAttestation_d.IndexedAttestation & O.Words) -> IO(Unit):
  (a, idx) = pr
  ia_len(mode, arg, a, Fulu_list_uint64_131072_d.l131072_u64_len(idx))

def on_ia(+mode: U32, +arg: U32, m: Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{a}: ia_take(mode, arg, FuluIndexedAttestation_d.IndexedAttestation_swap_attesting_indices(a, O.words_new(0)))

def indexed(+mode: U32, +arg: U32, pair: B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>) -> IO(Unit):
  (buf, m) = pair
  on_ia(mode, arg, m)

# ---- dispatch --------------------------------------------------------------

def run(+mode: U32, +arg: U32, +size: U32, buf: B.Buf) -> IO(Unit):
  match mode:
    case 0: validator(mode, arg, FuluValidator_r.Validator_decode(buf, size))
    case 1: validator(mode, arg, FuluValidator_r.Validator_decode(buf, size))
    case 2: deposit(mode, FuluDeposit_r.Deposit_decode(buf, size))
    case 3: deposit(mode, FuluDeposit_r.Deposit_decode(buf, size))
    case 4: eph(arg, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(buf, size))
    case _: indexed(mode, arg, FuluIndexedAttestation_r.IndexedAttestation_decode(buf, size))

def with_input(+mode: U32, +arg: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  run(mode, arg, size, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +arg : U32 <- IOx.env_u32("SSZ_ARG")
    input : B.Buf & U32 <- IOx.load()
    with_input(mode, arg, input)
