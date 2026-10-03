import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluValidator_def_generated.bend as Va
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as LV
import ../../types/FuluPendingDeposit_def_generated.bend as Pd
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as LP
import ../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Tx
import ../../types/proglist_uint8_def_generated.bend as P8
import ../../types/progbitlist_def_generated.bend as Pb
import ../../types/Fulu_list_PendingDeposit_134217728_encode_ssz_generated.bend as LPE
import ../../types/FuluBeaconState_def_generated.bend as BsD
import ../../types/FuluBeaconState_encode_ssz_generated.bend as BsE
import ../../types/Fulu_list_PendingConsolidation_262144_def_generated.bend as Lc
import ../../types/FuluPendingConsolidation_def_generated.bend as Pc
import ../../types/Fulu_list_Attestation_8_def_generated.bend as L8
import ../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as L8H
import ../../types/FuluAttestation_def_generated.bend as At
import ../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 3, probe M: appends on objects that claim a count their storage does not hold (a hand-built Seq / Words / Bits).
# SSZ_CASE selects the case, SSZ_ARG the claimed count. Each prints the flag and the length after.
#  1: Validator list   2: PendingDeposit list   3: transactions list   4: proglist_uint8   5: progbitlist
#  6: Validator list: cached append (cache_at clamps the depth, the claimed count stays)

def flag_len(pair: LV.l1099511627776_Validator_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case LV.l1099511627776_Validator_Seq{arr, +n}: IO.print("validator append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))

def c1(+n: U32) -> IO(Unit): flag_len(LV.l1099511627776_Validator_append(LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(0n), n}, Va.Validator_default()))

def pd_len(pair: LP.l134217728_PendingDeposit_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case LP.l134217728_PendingDeposit_Seq{arr, +n}: IO.print("pending_deposit append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
def c2(+n: U32) -> IO(Unit): pd_len(LP.l134217728_PendingDeposit_append(LP.l134217728_PendingDeposit_Seq{LP.l134217728_PendingDeposit_fill(0n), n}, Pd.PendingDeposit_default()))

def tx_len(pair: Tx.l1048576_bl1073741824_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case Tx.l1048576_bl1073741824_Seq{arr, +n}: IO.print("transactions append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
def c3(+n: U32) -> IO(Unit): tx_len(Tx.l1048576_bl1073741824_append(Tx.l1048576_bl1073741824_Seq{Tx.l1048576_bl1073741824_fill(0n), n}, O.words_new(3)))

def w_len(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case O.Words{ws, +n}: IO.print(label ++ " append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
def c4(+n: U32) -> IO(Unit): w_len("proglist_uint8", P8.pl_u8_append(O.Words{Array.new(U32, 4n, 0), n}, 7))

def b_len(pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case O.Bits{ws, +k}: IO.print("progbitlist append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(k))
def c5(+n: U32) -> IO(Unit): b_len(Pb.pbits_append(O.Bits{Array.new(U32, 4n, 0), n}, True{}))

def cv_len(pair: LV.l1099511627776_Validator_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  match c:
    case LV.l1099511627776_Validator_Cached{arr, +n, +d, nodes, +lo, +hi}: IO.print("validator_cached capp_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
def c6(+n: U32) -> IO(Unit): cv_len(LV.l1099511627776_Validator_capp(LV.l1099511627776_Validator_cache(LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(0n), n}), Va.Validator_default()))

# 7: size pass of a valid PendingDeposit list of SSZ_ARG elements (192 bytes each) in storage of 2^25 slots; 8: its validity
def sz_line(pair: LP.l134217728_PendingDeposit_Seq & U32) -> IO(Unit):
  (o, +sz) = pair
  IO.print("pending_deposit size=" ++ U32.show(sz))
def c7(+n: U32) -> IO(Unit): sz_line(LPE.l134217728_PendingDeposit_size(LP.l134217728_PendingDeposit_Seq{LP.l134217728_PendingDeposit_fill(25n), n}))
def v_line(pair: LP.l134217728_PendingDeposit_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("pending_deposit valid=" ++ O.pick_str(ok))
def c8(+n: U32) -> IO(Unit): v_line(LPE.l134217728_PendingDeposit_valid(LP.l134217728_PendingDeposit_Seq{LP.l134217728_PendingDeposit_fill(25n), n}))

# 9: BeaconState_serialize of the default state whose pending_deposits holds SSZ_ARG elements (storage 2^25): flag and size
def ser9b(ok: Bool, pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  IO.print("BeaconState_serialize ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n))
def ser9a(pair: BsD.BeaconState & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: ser9b(ok, B.size(b))
def c9(+n: U32) -> IO(Unit): ser9a(BsE.BeaconState_serialize(BsD.BeaconState_set_pending_deposits(BsD.BeaconState_default(), LP.l134217728_PendingDeposit_Seq{LP.l134217728_PendingDeposit_fill(25n), n})))

# 10: cache_at with a depth SSZ_ARG too small for the claimed count 7 (storage 8 slots): root, set at 6, append, root again
def cr2(+n: U32, pair: B.Buf & (Lc.l262144_PendingConsolidation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print("after_append root=" ++ IOx.words(d))
def ca2(pair: Lc.l262144_PendingConsolidation_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  do IO<Unit>:
    IO.print("capp_ok=" ++ O.pick_str(ok))
    cr2(0, Lc.l262144_PendingConsolidation_cached_root(64n, O.hasher(), c, 0))
def cs2(pair: Lc.l262144_PendingConsolidation_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  do IO<Unit>:
    IO.print("cset_ok=" ++ O.pick_str(ok))
    ca2(Lc.l262144_PendingConsolidation_capp(c, Pc.PendingConsolidation_default()))
def cr1(pair: B.Buf & (Lc.l262144_PendingConsolidation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  do IO<Unit>:
    IO.print("root=" ++ IOx.words(d))
    cs2(Lc.l262144_PendingConsolidation_cset(c, 6, Pc.PendingConsolidation_default()))
def c10(+d: U32) -> IO(Unit): cr1(Lc.l262144_PendingConsolidation_cached_root(64n, O.hasher(), Lc.l262144_PendingConsolidation_cache_at(Lc.l262144_PendingConsolidation_fill(3n), 7, U32.to_nat(d)), 0))

# 11: X_dump of a byte list claiming SSZ_ARG bytes in 4 words; 12: X_force of an Attestation list claiming SSZ_ARG elements in one slot
def len_of(t: +List<U32>, +acc: U32) -> U32:
  match t:
    case Nil{}: acc
    case Con{+h, tl}: len_of(tl, (acc + 1 : U32))
def c11(+n: U32) -> IO(Unit): IO.print("dump_len=" ++ U32.show(len_of(P8.pl_u8_dump(O.Words{Array.new(U32, 2n, 0), n}, Nil{}), 0)))
def f12(pair: L8.l8_Attestation_Seq & U32) -> IO(Unit):
  (o, +x) = pair
  IO.print("force=" ++ U32.show(x))
def c12(+n: U32) -> IO(Unit): f12(L8.l8_Attestation_force(L8.l8_Attestation_Seq{L8.l8_Attestation_fill(0n), n}))

# 13: cached list of two attestations: cached root, cget(0), cached root again, then the plain root of the same list (uncache)
def x3(s1: String, s2: String, pair: B.Buf & (L8.l8_Attestation_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("cached_root_before=" ++ s1 ++ " cached_root_after_cget=" ++ s2 ++ " plain_root_after_cget=" ++ IOx.words(d))
def x2(s1: String, pair: B.Buf & (L8.l8_Attestation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  x3(s1, IOx.words(d), L8H.l8_Attestation_root(64n, O.hasher(), L8.l8_Attestation_uncache(c), 0))
def x1c(s1: String, pair: L8.l8_Attestation_Cached & Maybe<&1, At.Attestation>) -> IO(Unit):
  (c, m) = pair
  x2(s1, L8.l8_Attestation_cached_root(64n, O.hasher(), c, 0))
def x1b(pair: B.Buf & (L8.l8_Attestation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  x1c(IOx.words(d), L8.l8_Attestation_ctake(c, 0))
def x1a(pair: L8.l8_Attestation_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  x1b(L8.l8_Attestation_cached_root(64n, O.hasher(), L8.l8_Attestation_cache(o), 0))
def app_fst2(pair: L8.l8_Attestation_Seq & Bool) -> L8.l8_Attestation_Seq:
  (o, ok) = pair
  o
def app2() -> L8.l8_Attestation_Seq: app_fst2(L8.l8_Attestation_append(L8.l8_Attestation_default(), At.Attestation_default()))
def c13() -> IO(Unit): x1a(L8.l8_Attestation_append(app2(), At.Attestation_default()))

def dispatch(+c: U32, +a: U32) -> IO(Unit):
  match c:
    case 1: c1(a)
    case 2: c2(a)
    case 3: c3(a)
    case 4: c4(a)
    case 5: c5(a)
    case 7: c7(a)
    case 8: c8(a)
    case 9: c9(a)
    case 10: c10(a)
    case 11: c11(a)
    case 12: c12(a)
    case 13: c13()
    case _: c6(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    dispatch(c, a)
