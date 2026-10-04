import Base
import ../../../src/buffer.bend as B
import ../../../src/obj.bend as O
import ../../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as TX
import ../../../types/FuluExecutionPayload_def_generated.bend as EP
import ../../../types/FuluExecutionPayload_encode_ssz_generated.bend as EPE
import ../../../types/FuluBeaconBlockBody_def_generated.bend as BB
import ../../../types/FuluBeaconBlockBody_encode_ssz_generated.bend as BBE
import ../../../types/FuluBeaconBlock_def_generated.bend as BK
import ../../../types/FuluBeaconBlock_encode_ssz_generated.bend as BKE
import ../../../types/FuluSignedBeaconBlock_def_generated.bend as SB
import ../../../types/FuluSignedBeaconBlock_encode_ssz_generated.bend as SBE
import ../../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 5, probe S: _valid / _size / _serialize of the NESTED containers around NMAX. Four transactions in lazily shared
# 1 GiB storage hold SSZ_ARG bytes in all (each at most 2^30); the payload goes into a body, the body into a block, the block into a
# signed block, through the public setters. Prints size and valid at every level; SSZ_SER = 1 also runs SignedBeaconBlock_serialize.

def big() -> Array<U32>: Array.new(U32, 28n, 0)
def part(+t: U32, +i: U32) -> U32:
  O.pick(U32.is_le(t, (1073741824 * i : U32)), 0, O.pick(U32.is_le((t - 1073741824 * i : U32), 1073741824), (t - 1073741824 * i : U32), 1073741824))
def a1(pair: TX.l1048576_bl1073741824_Seq & Bool) -> TX.l1048576_bl1073741824_Seq:
  (l, ok) = pair
  l
def txs(+t: U32) -> TX.l1048576_bl1073741824_Seq:
  a1(TX.l1048576_bl1073741824_append(a1(TX.l1048576_bl1073741824_append(a1(TX.l1048576_bl1073741824_append(a1(TX.l1048576_bl1073741824_append(
    TX.l1048576_bl1073741824_default(), O.Words{big(), part(t, 0)})), O.Words{big(), part(t, 1)})), O.Words{big(), part(t, 2)})), O.Words{big(), part(t, 3)}))

def sline(l: String, +m: U32, ok: Bool) -> String: l ++ "_size=" ++ U32.show(m) ++ " valid=" ++ O.pick_str(ok) ++ " "

def ser_sz(ok: Bool, pair: B.Buf & U32) -> String:
  (b, +m) = pair
  "ser_ok=" ++ O.pick_str(ok) ++ " ser_size=" ++ U32.show(m)
def ser_line(e: O.Encoded) -> String:
  match e:
    case O.Encoded{ok, b}: ser_sz(ok, B.size(b))
def sb_ser(pair: SB.SignedBeaconBlock & O.Encoded) -> String:
  (o, e) = pair
  ser_line(e)
def sb_fin(+ser: U32, o: SB.SignedBeaconBlock) -> String:
  match ser:
    case 1: sb_ser(SBE.SignedBeaconBlock_serialize(o))
    case _: "ser=skipped"

def sb4(+ser: U32, acc: String, +m: U32, pair: SB.SignedBeaconBlock & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(acc ++ sline("sbb", m, ok) ++ sb_fin(ser, o))
def sb3(+ser: U32, acc: String, pair: SB.SignedBeaconBlock & U32) -> IO(Unit):
  (o, +m) = pair
  sb4(ser, acc, m, SBE.SignedBeaconBlock_valid(o))
def bk4(+ser: U32, acc: String, +m: U32, pair: BK.BeaconBlock & Bool) -> IO(Unit):
  (o, ok) = pair
  sb3(ser, acc ++ sline("blk", m, ok), SBE.SignedBeaconBlock_size(SB.SignedBeaconBlock_set_message(SB.SignedBeaconBlock_default(), o)))
def bk3(+ser: U32, acc: String, pair: BK.BeaconBlock & U32) -> IO(Unit):
  (o, +m) = pair
  bk4(ser, acc, m, BKE.BeaconBlock_valid(o))
def bb4(+ser: U32, acc: String, +m: U32, pair: BB.BeaconBlockBody & Bool) -> IO(Unit):
  (o, ok) = pair
  bk3(ser, acc ++ sline("body", m, ok), BKE.BeaconBlock_size(BK.BeaconBlock_set_body(BK.BeaconBlock_default(), BB.BeaconBlockBody_bx_wrap(o))))
def bb3(+ser: U32, acc: String, pair: BB.BeaconBlockBody & U32) -> IO(Unit):
  (o, +m) = pair
  bb4(ser, acc, m, BBE.BeaconBlockBody_valid(o))
def ep4(+ser: U32, +m: U32, pair: EP.ExecutionPayload & Bool) -> IO(Unit):
  (o, ok) = pair
  bb3(ser, sline("ep", m, ok), BBE.BeaconBlockBody_size(BB.BeaconBlockBody_set_execution_payload(BB.BeaconBlockBody_default(), EP.ExecutionPayload_bx_wrap(o))))
def ep3(+ser: U32, pair: EP.ExecutionPayload & U32) -> IO(Unit):
  (o, +m) = pair
  ep4(ser, m, EPE.ExecutionPayload_valid(o))

def main() -> IO(Unit):
  do IO<Unit>:
    +t : U32 <- IOx.env_u32("SSZ_ARG")
    +ser : U32 <- IOx.env_u32("SSZ_SER")
    ep3(ser, EPE.ExecutionPayload_size(EP.ExecutionPayload_set_transactions(EP.ExecutionPayload_default(), txs(t))))
