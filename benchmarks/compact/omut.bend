import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
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

def val_enc(ok: Bool, +v: T.Validator) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(T.Validator_encode(v)))

def val_set(+arg: U32, v: T.Validator) -> IO(Unit):
  val_enc(True{}, T.Validator_set_slashed(T.Validator_set_effective_balance(v, O.U64{arg, 0}), True{}))

def val_read(+arg: U32, pair: T.Validator & O.U64) -> IO(Unit):
  (v, +got) = pair
  do IO<Unit>:
    IO.print("READBACK=" ++ U32.show(O.u64_lo_of(got)))
    val_enc(O.u64_eq(got, O.U64{arg, 0}), v)

def val_rw(+arg: U32, v: T.Validator) -> IO(Unit):
  val_read(arg, T.Validator_get_effective_balance(T.Validator_set_effective_balance(v, O.U64{arg, 0})))

def val_pick(+mode: U32, +arg: U32, +v: T.Validator) -> IO(Unit):
  match mode:
    case 0: val_set(arg, v)
    case _: val_rw(arg, v)

def on_validator(+mode: U32, +arg: U32, m: Maybe<&1, T.Validator>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{+v}: val_pick(mode, arg, v)

def validator(+mode: U32, +arg: U32, pair: B.Buf & Maybe<&1, T.Validator>) -> IO(Unit):
  (buf, m) = pair
  on_validator(mode, arg, m)

# ---- Deposit: a vector element is replaced, out-of-range is rejected --------

def dep_enc(ok: Bool, d: T.Deposit) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(Pair.snd(T.Deposit, B.Buf, T.Deposit_encode(d))))

def dep_only(pr: T.Deposit & O.Words) -> T.Deposit:
  (d, old) = pr
  d

def dep_put(pr: T.Deposit & O.Words, proof: O.Words) -> T.Deposit:
  (d, old) = pr
  dep_only(T.Deposit_swap_proof(d, proof))

def dep_back(pr: T.Deposit & O.Words, res: O.Words & Bool) -> IO(Unit):
  (proof, ok) = res
  dep_enc(ok, dep_put(pr, proof))

def dep_take(+i: U32, pr: T.Deposit & O.Words) -> IO(Unit):
  (d, proof) = pr
  dep_back((d, O.words_new(0)), T.v33_b32_set(proof, i, T.Bytes32{50462976, 117835012, 185207048, 252579084, 319951120, 387323156, 454695192, 522067228}))

def dep_set(+i: U32, d: T.Deposit) -> IO(Unit):
  dep_take(i, T.Deposit_swap_proof(d, O.words_new(0)))

def dep_pick(+mode: U32, d: T.Deposit) -> IO(Unit):
  match mode:
    case 2: dep_set(0, d)
    case _: dep_set(33, d)

def on_deposit(+mode: U32, m: Maybe<&1, T.Deposit>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{d}: dep_pick(mode, d)

def deposit(+mode: U32, pair: B.Buf & Maybe<&1, T.Deposit>) -> IO(Unit):
  (buf, m) = pair
  on_deposit(mode, m)

# ---- ExecutionPayloadHeader: a byte list append within its 32-byte limit ----

def eph_only(pr: T.ExecutionPayloadHeader & O.Words) -> T.ExecutionPayloadHeader:
  (h, old) = pr
  h

def eph_enc(ok: Bool, h: T.ExecutionPayloadHeader) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(Pair.snd(T.ExecutionPayloadHeader, B.Buf, T.ExecutionPayloadHeader_encode(h))))

def eph_back(h: T.ExecutionPayloadHeader, res: O.Words & Bool) -> IO(Unit):
  (extra, ok) = res
  eph_enc(ok, eph_only(T.ExecutionPayloadHeader_swap_extra_data(h, extra)))

def eph_take(+arg: U32, pr: T.ExecutionPayloadHeader & O.Words) -> IO(Unit):
  (h, extra) = pr
  eph_back(h, T.bl32_append(extra, arg))

def on_eph(+arg: U32, m: Maybe<&1, T.ExecutionPayloadHeader>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{h}: eph_take(arg, T.ExecutionPayloadHeader_swap_extra_data(h, O.words_new(0)))

def eph(+arg: U32, pair: B.Buf & Maybe<&1, T.ExecutionPayloadHeader>) -> IO(Unit):
  (buf, m) = pair
  on_eph(arg, m)

# ---- IndexedAttestation: list append and element replacement ----------------

def ia_only(pr: T.IndexedAttestation & O.Words) -> T.IndexedAttestation:
  (a, old) = pr
  a

def ia_enc(ok: Bool, a: T.IndexedAttestation) -> IO(Unit):
  do IO<Unit>:
    status(ok)
    out_of(B.size(Pair.snd(T.IndexedAttestation, B.Buf, T.IndexedAttestation_encode(a))))

def ia_back(a: T.IndexedAttestation, res: O.Words & Bool) -> IO(Unit):
  (idx, ok) = res
  ia_enc(ok, ia_only(T.IndexedAttestation_swap_attesting_indices(a, idx)))

def ia_op(+mode: U32, +arg: U32, +n: U32, a: T.IndexedAttestation, idx: O.Words) -> IO(Unit):
  match mode:
    case 5: ia_back(a, T.l131072_u64_append(idx, O.U64{arg, 0}))
    case 6: ia_back(a, T.l131072_u64_set(idx, 0, O.U64{arg, 0}))
    case _: ia_back(a, T.l131072_u64_set(idx, n, O.U64{arg, 0}))

def ia_len(+mode: U32, +arg: U32, a: T.IndexedAttestation, pair: O.Words & U32) -> IO(Unit):
  (idx, +n) = pair
  ia_op(mode, arg, n, a, idx)

def ia_take(+mode: U32, +arg: U32, pr: T.IndexedAttestation & O.Words) -> IO(Unit):
  (a, idx) = pr
  ia_len(mode, arg, a, T.l131072_u64_len(idx))

def on_ia(+mode: U32, +arg: U32, m: Maybe<&1, T.IndexedAttestation>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{a}: ia_take(mode, arg, T.IndexedAttestation_swap_attesting_indices(a, O.words_new(0)))

def indexed(+mode: U32, +arg: U32, pair: B.Buf & Maybe<&1, T.IndexedAttestation>) -> IO(Unit):
  (buf, m) = pair
  on_ia(mode, arg, m)

# ---- dispatch --------------------------------------------------------------

def run(+mode: U32, +arg: U32, +size: U32, buf: B.Buf) -> IO(Unit):
  match mode:
    case 0: validator(mode, arg, T.Validator_decode(buf, size))
    case 1: validator(mode, arg, T.Validator_decode(buf, size))
    case 2: deposit(mode, T.Deposit_decode(buf, size))
    case 3: deposit(mode, T.Deposit_decode(buf, size))
    case 4: eph(arg, T.ExecutionPayloadHeader_decode(buf, size))
    case _: indexed(mode, arg, T.IndexedAttestation_decode(buf, size))

def with_input(+mode: U32, +arg: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  run(mode, arg, size, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +arg : U32 <- IOx.env_u32("SSZ_ARG")
    input : B.Buf & U32 <- IOx.load()
    with_input(mode, arg, input)
