import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FixedTestStruct_def_generated.bend as FxD
import ../../../../../types/VarTestStruct_def_generated.bend as VtD
import ../../../../../types/SmallTestStruct_def_generated.bend as SmD
import ../../../../../types/vec_FixedTestStruct_4_def_generated.bend as V4D
import ../../../../../types/vec_VarTestStruct_2_def_generated.bend as V2D
import ../../../../../types/ComplexTestStruct_def_generated.bend as CtD
import ../../../../../types/ComplexTestStruct_encode_ssz_generated.bend as CtE
import ../../../../../types/ComplexTestStruct_decode_ssz_generated.bend as CtR
import ../../../../../types/proglist_SmallTestStruct_def_generated.bend as PsD
import ../../../../../types/ProgressiveTestStruct_def_generated.bend as PtD
import ../../../../../types/ProgressiveTestStruct_encode_ssz_generated.bend as PtE
import ../../../../../types/FuluAttestation_def_generated.bend as AtD
import ../../../../../types/FuluAttestation_encode_ssz_generated.bend as AtE
import ../../../../../types/FuluWithdrawalRequest_def_generated.bend as WrD
import ../../../../../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as LwD
import ../../../../../types/Fulu_list_ConsolidationRequest_2_def_generated.bend as LcD
import ../../../../../types/FuluExecutionRequests_def_generated.bend as ErD
import ../../../../../types/FuluExecutionRequests_encode_ssz_generated.bend as ErE
import ../../../../../types/progbitlist_encode_ssz_generated.bend as PbE
import ../../../../../types/FuluCheckpoint_def_generated.bend as CpD
import ../../../../../types/FuluCheckpoint_encode_ssz_generated.bend as CpE
import ../../../../../types/FuluCheckpoint_decode_ssz_generated.bend as CpR
import ../../../../../types/FuluDeposit_def_generated.bend as DpD
import ../../../../../types/FuluDepositData_def_generated.bend as DdD
import ../../../../../types/Fulu_list_Deposit_16_def_generated.bend as LdD
import ../../../../../types/Fulu_list_Deposit_16_hashtreeroot_generated.bend as LdH
import ../../../../../types/FuluEth1Data_def_generated.bend as EdD
import ../../../../../types/Fulu_list_Eth1Data_2048_def_generated.bend as LeD
import ../../../../../types/Fulu_list_Eth1Data_2048_hashtreeroot_generated.bend as LeH
import ../../../../../types/bitvector_2_def_generated.bend as Bv2D
import ../../../../../types/BitsStruct_def_generated.bend as BsD
import ../../../../../types/BitsStruct_encode_ssz_generated.bend as BsE
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as LtD
import ../../../../../types/FuluExecutionPayload_def_generated.bend as EpD
import ../../../../../types/FuluExecutionPayload_encode_ssz_generated.bend as EpE
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-4 probe: the public object API on values whose size pass, checked writers, decode window and caches carry the round-4 faults.
# Every input is built with public constructors (records, O.Words, O.Bits, B.Buf, O.BNone, Seq records) and public setters.
# SSZ_CASE:
#  1 ComplexTestStruct default (control)            2 ComplexTestStruct with f_F[0].A = 256 (uint8 out of range)
#  3 ComplexTestStruct with f_G = [BNone, BNone]   4 ComplexTestStruct with f_B claiming 258 bytes (> 2 * 128)
#  5 ProgressiveTestStruct default (control)       6 ProgressiveTestStruct with f_C = [SmallTestStruct{A = 65536}]
#  7 Attestation default (control)                 8 Attestation with 131073 aggregation bits (> 131072)
#  9 ExecutionRequests default (control)           10 ExecutionRequests with 17 withdrawal requests (> 16)
# 11 ExecutionRequests with 3 consolidations (> 2) 12 progbitlist of 64 bits in 1 word of storage
# 13 ComplexTestStruct decode of its own serialized bytes (window = buffer)
# 14 the same bytes, size field claiming 50 (window past the buffer's size)
# 15 the same bytes with the first offset corrupted to 72 (invalid inside the window)
# 16 Checkpoint decode of 40 bytes in a buffer claiming 39
# 17 Deposit list: append 3, cache, root, ctake(1), cached root vs plain root of the uncached list
# 18 Deposit list: append 2, cache, ctake(2) (index = length)
# 19 Eth1Data list: append 3 seeds, cache, root, capp 1, cached root vs plain root
# 20 Eth1Data list: cache of 0, capp x 5 (growth), cached root vs plain root
# 23 ExecutionPayload with one transaction Words{[0xFFFFFFFF], 1} (junk past its 1-byte length: invalid)  24 ExecutionPayload default (control)
# 21 BitsStruct with f_B = Bitvector2{4} (a bit past the 2 bits)   22 ComplexTestStruct with f_A = 65536 (uint16 out of range, built with the record constructor)

def ck(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  match k:
    case 0n:
      (ws, +w) = pair
      (ws, (acc + (w * (i + 1 : U32) : U32) : U32))
    case 1n+q:
      (ws, +w) = pair
      ck(q, (i + 1 : U32), (acc + (w * (i + 1 : U32) : U32) : U32), Array.get(U32, ws, (i + 1 : U32)))

def ckz(empty: Bool, ws: Array<U32>, +n: U32) -> Array<U32> & U32:
  match empty:
    case True{}: (ws, 0)
    case False{}: ck(U32.to_nat((U32.shrn((n + 3 : U32), 2n) - 1 : U32)), 0, 0, Array.get(U32, ws, 0))

def ckfin(+n: U32, pair: Array<U32> & U32) -> U32 & U32:
  (ws, +c) = pair
  (n, c)

def ckinfo(b: B.Buf) -> U32 & U32:
  match b:
    case B.Buf{ws, +n}: ckfin(n, ckz(U32.is_eq(n, 0), ws, n))

def show_ck(label: String, ok: Bool, pair: U32 & U32) -> IO(Unit):
  (+n, +c) = pair
  IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(c))

def show(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: show_ck(label, ok, ckinfo(b))

def ser_ct(label: String, pair: CtD.ComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def ser_pt(label: String, pair: PtD.ProgressiveTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def ser_at(label: String, pair: AtD.Attestation & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def ser_er(label: String, pair: ErD.ExecutionRequests & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def ser_pb(label: String, pair: O.Bits & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def pr(label: String, d: D.Digest) -> IO(Unit):
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}:
      IO.print(label ++ " root=" ++ U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h))

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h)

# ---- values ----
def bad_fixed() -> FxD.FixedTestStruct: FxD.FixedTestStruct{256, O.U64{0, 0}, 0}
def bad_f() -> V4D.v4_FixedTestStruct_Seq: Pair.fst(V4D.v4_FixedTestStruct_Seq, Bool, V4D.v4_FixedTestStruct_set(V4D.v4_FixedTestStruct_default(), 0, bad_fixed()))
def bad_g() -> V2D.v2_VarTestStruct_Seq: V2D.v2_VarTestStruct_Seq{V2D.v2_VarTestStruct_fill(1n), 2}
def bad_b() -> O.Words: O.Words{Array.new(U32, 7n, 0), 258}
def bad_c() -> PsD.pl_SmallTestStruct_Seq: PsD.pl_SmallTestStruct_Seq{Array.new(SmD.SmallTestStruct, 0n, SmD.SmallTestStruct{65536, 0}), 1}
def bad_bits() -> O.Bits: O.Bits{Array.new(U32, 13n, 0), 131073}
def bad_w() -> LwD.l16_WithdrawalRequest_Seq: LwD.l16_WithdrawalRequest_Seq{LwD.l16_WithdrawalRequest_fill(5n), 17}
def bad_cons() -> LcD.l2_ConsolidationRequest_Seq: LcD.l2_ConsolidationRequest_Seq{LcD.l2_ConsolidationRequest_fill(2n), 3}

def ct_bytes() -> B.Buf: O.ser_out(Pair.snd(CtD.ComplexTestStruct, O.Encoded, CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default())))
def reclaim(b: B.Buf, +k: U32) -> B.Buf:
  match b:
    case B.Buf{ws, +n}: B.Buf{ws, k}
def corrupt(b: B.Buf) -> B.Buf:
  match b:
    case B.Buf{ws, +n}: B.Buf{O.w32(ws, 2, 72), n}

def show_ct(label: String, pair: B.Buf & Maybe<&1, CtD.ComplexTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: ser_ct(label ++ " decoded=some", CtE.ComplexTestStruct_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

def show_cp(label: String, pair: B.Buf & Maybe<&1, CpD.Checkpoint>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{+v}: IO.print(label ++ " decoded=some")
    case None{}: IO.print(label ++ " decoded=none")

def cp_bytes() -> B.Buf: O.ser_out(CpE.Checkpoint_serialize(CpD.Checkpoint_default()))

# ---- caches ----
def dep(+x: U32) -> DpD.Deposit: DpD.Deposit_set_data(DpD.Deposit_default(), DdD.DepositData_bx_wrap(DdD.DepositData_seed(x)))
def dbuild(+k: Nat, +i: U32, o: LdD.l16_Deposit_Seq) -> LdD.l16_Deposit_Seq:
  match k:
    case 0n: o
    case 1n+q: dbuild(q, (i + 1 : U32), Pair.fst(LdD.l16_Deposit_Seq, Bool, LdD.l16_Deposit_append(o, dep((i + 1 : U32)))))

def dcroot(c: LdD.l16_Deposit_Cached) -> LdD.l16_Deposit_Cached & D.Digest: Pair.snd(B.Buf, LdD.l16_Deposit_Cached & D.Digest, LdD.l16_Deposit_cached_root(64n, O.hasher(), c, 0))
def dproot(o: LdD.l16_Deposit_Seq) -> D.Digest: Pair.snd(LdD.l16_Deposit_Seq, D.Digest, Pair.snd(B.Buf, LdD.l16_Deposit_Seq & D.Digest, LdH.l16_Deposit_root(64n, O.hasher(), o, 0)))

def dcmp(label: String, pair: LdD.l16_Deposit_Cached & D.Digest) -> IO(Unit):
  (c, +r) = pair
  IO.print(label ++ " cached=" ++ rs(r) ++ " plain=" ++ rs(dproot(LdD.l16_Deposit_uncache(c))))
def dtake_fin(label: String, pair: LdD.l16_Deposit_Cached & Maybe<&1, DpD.Deposit>) -> IO(Unit):
  (c, m) = pair
  dcmp(label, dcroot(c))
def dtake_after_root(label: String, +i: U32, pair: LdD.l16_Deposit_Cached & D.Digest) -> IO(Unit):
  (c, +r) = pair
  dtake_fin(label, LdD.l16_Deposit_ctake(c, i))

def eth(+x: U32) -> EdD.Eth1Data: EdD.Eth1Data_seed(x)
def ebuild(+k: Nat, +i: U32, o: LeD.l2048_Eth1Data_Seq) -> LeD.l2048_Eth1Data_Seq:
  match k:
    case 0n: o
    case 1n+q: ebuild(q, (i + 1 : U32), Pair.fst(LeD.l2048_Eth1Data_Seq, Bool, LeD.l2048_Eth1Data_append(o, eth((i + 1 : U32)))))
def ecroot(c: LeD.l2048_Eth1Data_Cached) -> LeD.l2048_Eth1Data_Cached & D.Digest: Pair.snd(B.Buf, LeD.l2048_Eth1Data_Cached & D.Digest, LeD.l2048_Eth1Data_cached_root(64n, O.hasher(), c, 0))
def eproot(o: LeD.l2048_Eth1Data_Seq) -> D.Digest: Pair.snd(LeD.l2048_Eth1Data_Seq, D.Digest, Pair.snd(B.Buf, LeD.l2048_Eth1Data_Seq & D.Digest, LeH.l2048_Eth1Data_root(64n, O.hasher(), o, 0)))
def ecmp(label: String, pair: LeD.l2048_Eth1Data_Cached & D.Digest) -> IO(Unit):
  (c, +r) = pair
  IO.print(label ++ " cached=" ++ rs(r) ++ " plain=" ++ rs(eproot(LeD.l2048_Eth1Data_uncache(c))))
def ecapp(c: LeD.l2048_Eth1Data_Cached, +x: U32) -> LeD.l2048_Eth1Data_Cached: Pair.fst(LeD.l2048_Eth1Data_Cached, Bool, LeD.l2048_Eth1Data_capp(c, eth(x)))
def eapp_after_root(label: String, pair: LeD.l2048_Eth1Data_Cached & D.Digest) -> IO(Unit):
  (c, +r) = pair
  ecmp(label, ecroot(ecapp(c, 77)))
def ecapps(+k: Nat, +i: U32, c: LeD.l2048_Eth1Data_Cached) -> LeD.l2048_Eth1Data_Cached:
  match k:
    case 0n: c
    case 1n+q: ecapps(q, (i + 1 : U32), ecapp(c, (i + 100 : U32)))

def c1() -> IO(Unit): ser_ct("cts_default", CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default()))
def c2() -> IO(Unit): ser_ct("cts_bad_F", CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_set_f_F(CtD.ComplexTestStruct_default(), bad_f())))
def c3() -> IO(Unit): ser_ct("cts_bad_G", CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_set_f_G(CtD.ComplexTestStruct_default(), bad_g())))
def c4() -> IO(Unit): ser_ct("cts_bad_B", CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_set_f_B(CtD.ComplexTestStruct_default(), bad_b())))
def c5() -> IO(Unit): ser_pt("pts_default", PtE.ProgressiveTestStruct_serialize(PtD.ProgressiveTestStruct_default()))
def c6() -> IO(Unit): ser_pt("pts_bad_C", PtE.ProgressiveTestStruct_serialize(PtD.ProgressiveTestStruct_set_f_C(PtD.ProgressiveTestStruct_default(), bad_c())))
def c7() -> IO(Unit): ser_at("att_default", AtE.Attestation_serialize(AtD.Attestation_default()))
def c8() -> IO(Unit): ser_at("att_bad_bits", AtE.Attestation_serialize(AtD.Attestation_set_aggregation_bits(AtD.Attestation_default(), bad_bits())))
def c9() -> IO(Unit): ser_er("er_default", ErE.ExecutionRequests_serialize(ErD.ExecutionRequests_default()))
def c10() -> IO(Unit): ser_er("er_bad_w", ErE.ExecutionRequests_serialize(ErD.ExecutionRequests_set_withdrawals(ErD.ExecutionRequests_default(), bad_w())))
def c11() -> IO(Unit): ser_er("er_bad_cons", ErE.ExecutionRequests_serialize(ErD.ExecutionRequests_set_consolidations(ErD.ExecutionRequests_default(), bad_cons())))
def c12() -> IO(Unit): ser_pb("pbits_short", PbE.progbitlist_serialize(O.Bits{Array.new(U32, 0n, 0), 64}))
def c13() -> IO(Unit): show_ct("cts_decode_own", CtR.ComplexTestStruct_decode(ct_bytes(), 100))
def c14() -> IO(Unit): show_ct("cts_decode_claim50", CtR.ComplexTestStruct_decode(reclaim(ct_bytes(), 50), 100))
def c15() -> IO(Unit): show_ct("cts_decode_badoff", CtR.ComplexTestStruct_decode(corrupt(ct_bytes()), 100))
def c16() -> IO(Unit): show_cp("cp_decode_claim39", CpR.Checkpoint_decode(reclaim(cp_bytes(), 39), 40))
def c17() -> IO(Unit): dtake_after_root("dep_take1", 1, dcroot(LdD.l16_Deposit_cache(dbuild(3n, 0, LdD.l16_Deposit_default()))))
def c18() -> IO(Unit): dtake_after_root("dep_take_n", 2, dcroot(LdD.l16_Deposit_cache(dbuild(2n, 0, LdD.l16_Deposit_default()))))
def c19() -> IO(Unit): eapp_after_root("eth_capp", ecroot(LeD.l2048_Eth1Data_cache(ebuild(3n, 0, LeD.l2048_Eth1Data_default()))))
def c20() -> IO(Unit): ecmp("eth_grow", ecroot(ecapps(5n, 0, LeD.l2048_Eth1Data_cache(LeD.l2048_Eth1Data_default()))))

def bs_badf(o: BsD.BitsStruct) -> BsD.BitsStruct:
  match o:
    case BsD.BitsStruct{a, +b, +c, d, +e}: BsD.BitsStruct{a, Bv2D.Bitvector2{4}, c, d, e}
def bs_bad() -> BsD.BitsStruct: bs_badf(BsD.BitsStruct_default())
def ser_bs(label: String, pair: BsD.BitsStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)
def ct_badAf(o: CtD.ComplexTestStruct) -> CtD.ComplexTestStruct:
  match o:
    case CtD.ComplexTestStruct{+a, b, +c, d, e, f, g}: CtD.ComplexTestStruct{65536, b, c, d, e, f, g}
def ct_badA() -> CtD.ComplexTestStruct: ct_badAf(CtD.ComplexTestStruct_default())
def c21() -> IO(Unit): ser_bs("bs_bad_B", BsE.BitsStruct_serialize(bs_bad()))
def c22() -> IO(Unit): ser_ct("cts_bad_A", CtE.ComplexTestStruct_serialize(ct_badA()))

def bad_txs() -> LtD.l1048576_bl1073741824_Seq: LtD.l1048576_bl1073741824_Seq{ALeaf{O.BSome{O.Words{Array.new(U32, 0n, 4294967295), 1}, O.BNone{}}}, 1}
def ser_ep(label: String, pair: EpD.ExecutionPayload & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)
def c23() -> IO(Unit): ser_ep("ep_bad_tx", EpE.ExecutionPayload_serialize(EpD.ExecutionPayload_set_transactions(EpD.ExecutionPayload_default(), bad_txs())))
def c24() -> IO(Unit): ser_ep("ep_default", EpE.ExecutionPayload_serialize(EpD.ExecutionPayload_default()))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 5: c5()
    case 6: c6()
    case 7: c7()
    case 8: c8()
    case 9: c9()
    case 10: c10()
    case 11: c11()
    case 12: c12()
    case 13: c13()
    case 14: c14()
    case 15: c15()
    case 16: c16()
    case 17: c17()
    case 18: c18()
    case 19: c19()
    case 20: c20()
    case 21: c21()
    case 22: c22()
    case 23: c23()
    case _: c24()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
