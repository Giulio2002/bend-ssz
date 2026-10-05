import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../benchmarks/compact/objio.bend as IOx
import ../../../../../types/FuluBytes20_def_generated.bend as B20
import ../../../../../types/FuluBytes20_encode_ssz_generated.bend as B20E
import ../../../../../types/FuluBytes20_hashtreeroot_generated.bend as B20H
import ../../../../../types/FuluBytes48_def_generated.bend as B48
import ../../../../../types/FuluBytes48_encode_ssz_generated.bend as B48E
import ../../../../../types/FuluBytes48_hashtreeroot_generated.bend as B48H
import ../../../../../types/FuluBytes8_def_generated.bend as B8
import ../../../../../types/FuluBytes8_encode_ssz_generated.bend as B8E
import ../../../../../types/FuluBytes8_hashtreeroot_generated.bend as B8H
import ../../../../../types/FuluBytes96_def_generated.bend as B96
import ../../../../../types/FuluBytes96_encode_ssz_generated.bend as B96E
import ../../../../../types/FuluBytes96_hashtreeroot_generated.bend as B96H
import ../../../../../types/FuluCheckpoint_def_generated.bend as CP
import ../../../../../types/FuluCheckpoint_encode_ssz_generated.bend as CPE
import ../../../../../types/FuluCheckpoint_hashtreeroot_generated.bend as CPH
import ../../../../../types/FuluSyncCommitteeContribution_def_generated.bend as SCC
import ../../../../../types/FuluSyncCommitteeContribution_encode_ssz_generated.bend as SCCE
import ../../../../../types/FuluSyncCommitteeContribution_hashtreeroot_generated.bend as SCCH
import ../../../../../types/FuluSyncAggregate_def_generated.bend as SA
import ../../../../../types/FuluSyncAggregate_encode_ssz_generated.bend as SAE
import ../../../../../types/FuluSyncAggregate_hashtreeroot_generated.bend as SAH
import ../../../../../types/FuluAttestation_def_generated.bend as AT
import ../../../../../types/FuluAttestation_encode_ssz_generated.bend as ATE
import ../../../../../types/FuluAttestation_hashtreeroot_generated.bend as ATH
import ../../../../../types/bitvector_5_def_generated.bend as BV5
import ../../../../../types/bitvector_5_encode_ssz_generated.bend as BV5E
import ../../../../../types/bitvector_5_hashtreeroot_generated.bend as BV5H
import ../../../../../types/bitvector_513_def_generated.bend as BV513
import ../../../../../types/bitvector_513_encode_ssz_generated.bend as BV513E
import ../../../../../types/bitvector_513_hashtreeroot_generated.bend as BV513H
import ../../../../../types/boolean_def_generated.bend as BO
import ../../../../../types/boolean_encode_ssz_generated.bend as BOE
import ../../../../../types/boolean_hashtreeroot_generated.bend as BOH
import ../../../../../types/uint64_def_generated.bend as U64
import ../../../../../types/uint64_encode_ssz_generated.bend as U64E
import ../../../../../types/uint64_hashtreeroot_generated.bend as U64H
import ../../../../../types/vec_uint64_513_def_generated.bend as V513u64
import ../../../../../types/vec_uint64_513_encode_ssz_generated.bend as V513u64E
import ../../../../../types/vec_uint64_513_hashtreeroot_generated.bend as V513u64H
import ../../../../../types/vec_uint128_513_def_generated.bend as V513u128
import ../../../../../types/vec_uint128_513_encode_ssz_generated.bend as V513u128E
import ../../../../../types/vec_uint128_513_hashtreeroot_generated.bend as V513u128H
import ../../../../../types/vec_uint256_513_def_generated.bend as V513u256
import ../../../../../types/vec_uint256_513_encode_ssz_generated.bend as V513u256E
import ../../../../../types/vec_uint256_513_hashtreeroot_generated.bend as V513u256H
import ../../../../../types/FuluBlobSidecar_def_generated.bend as BS
import ../../../../../types/FuluBlobSidecar_encode_ssz_generated.bend as BSE
import ../../../../../types/FuluBlobSidecar_hashtreeroot_generated.bend as BSH
import ../../../../../types/FuluDeposit_def_generated.bend as DP
import ../../../../../types/FuluDeposit_encode_ssz_generated.bend as DPE
import ../../../../../types/FuluDeposit_hashtreeroot_generated.bend as DPH
import ../../../../../types/FuluSyncCommittee_def_generated.bend as SC
import ../../../../../types/FuluSyncCommittee_encode_ssz_generated.bend as SCE
import ../../../../../types/FuluSyncCommittee_hashtreeroot_generated.bend as SCH
import ../../../../../types/FuluHistoricalBatch_def_generated.bend as HB
import ../../../../../types/FuluHistoricalBatch_encode_ssz_generated.bend as HBE
import ../../../../../types/FuluHistoricalBatch_hashtreeroot_generated.bend as HBH

# Round-10 probe a: the default constructors (X_default) through public calls only: X_serialize(X_default()) and
# X_hash_tree_root(X_default()). The spec default is all zero bytes of the type's fixed length, so the unmutated line is
# 'ok=1,n=<size>,ck=<checksum of zeroes>' and the root of the zero value. apiprobe3.py (PROBE=this file) compares a
# mutant's lines with the unmutated build.

def ck_go(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> U32:
  match k pair:
    case 0n Tuple{ws, x}: acc
    case 1n+q Tuple{ws, +x}: ck_go(q, (i + 1 : U32), ((acc * 31 : U32) + x : U32), Array.get(U32, ws, (i + 1 : U32)))

def enc_str(e: O.Encoded) -> String:
  match e:
    case O.Encoded{x, b}:
      match b:
        case B.Buf{ws, +n}: "ok=" ++ O.pick_str(x) ++ ",n=" ++ U32.show(n) ++ ",ck=" ++ U32.show(ck_go(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, 7, Array.get(U32, ws, 0)))

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(h)

def rv(pair: B.Buf & D.Digest) -> String:
  (h, d) = pair
  rs(d)


def ro_at(pair: B.Buf & (AT.Attestation & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def so_at(pair: AT.Attestation & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

def ro_w(pair: B.Buf & (O.Words & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def so_w(pair: O.Words & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

def ro_bs(pair: B.Buf & (BS.BlobSidecar & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def so_bs(pair: BS.BlobSidecar & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

def ro_dp(pair: B.Buf & (DP.Deposit & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def so_dp(pair: DP.Deposit & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

def ro_sc(pair: B.Buf & (SC.SyncCommittee & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def so_sc(pair: SC.SyncCommittee & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

def ro_hb(pair: B.Buf & (HB.HistoricalBatch & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def so_hb(pair: HB.HistoricalBatch & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

def c1() -> String: "b20 ser=" ++ enc_str(B20E.Bytes20_serialize(B20.b20_default())) ++ " root=" ++ rv(B20H.Bytes20_hash_tree_root(O.hasher(), B20.b20_default()))
def c2() -> String: "checkpoint ser=" ++ enc_str(CPE.Checkpoint_serialize(CP.Checkpoint_default())) ++ " root=" ++ rv(CPH.Checkpoint_hash_tree_root(O.hasher(), CP.Checkpoint_default()))
def c3() -> String: "b48 ser=" ++ enc_str(B48E.Bytes48_serialize(B48.b48_default())) ++ " root=" ++ rv(B48H.Bytes48_hash_tree_root(O.hasher(), B48.b48_default()))
def c4() -> String: "b8 ser=" ++ enc_str(B8E.Bytes8_serialize(B8.b8_default())) ++ " root=" ++ rv(B8H.Bytes8_hash_tree_root(O.hasher(), B8.b8_default()))
def c5() -> String: "b96 ser=" ++ enc_str(B96E.Bytes96_serialize(B96.b96_default())) ++ " root=" ++ rv(B96H.Bytes96_hash_tree_root(O.hasher(), B96.b96_default()))
def c6() -> String: "scc ser=" ++ enc_str(SCCE.SyncCommitteeContribution_serialize(SCC.SyncCommitteeContribution_default())) ++ " root=" ++ rv(SCCH.SyncCommitteeContribution_hash_tree_root(O.hasher(), SCC.SyncCommitteeContribution_default()))
def c7() -> String: "syncagg ser=" ++ enc_str(SAE.SyncAggregate_serialize(SA.SyncAggregate_default())) ++ " root=" ++ rv(SAH.SyncAggregate_hash_tree_root(O.hasher(), SA.SyncAggregate_default()))
def c8() -> String: "att ser=" ++ so_at(ATE.Attestation_serialize(AT.Attestation_default())) ++ " root=" ++ ro_at(ATH.Attestation_hash_tree_root(O.hasher(), AT.Attestation_default()))
def c9() -> String: "bv5 ser=" ++ enc_str(BV5E.bitvector_5_serialize(BV5.bv5_default())) ++ " root=" ++ rv(BV5H.bitvector_5_hash_tree_root(O.hasher(), BV5.bv5_default()))
def c10() -> String: "bv513 ser=" ++ enc_str(BV513E.bitvector_513_serialize(BV513.bv513_default())) ++ " root=" ++ rv(BV513H.bitvector_513_hash_tree_root(O.hasher(), BV513.bv513_default()))
def c11() -> String: "bool ser=" ++ enc_str(BOE.boolean_serialize(BO.bool_default())) ++ " root=" ++ rv(BOH.boolean_hash_tree_root(O.hasher(), BO.bool_default()))
def c12() -> String: "u64 ser=" ++ enc_str(U64E.uint64_serialize(U64.u64_default())) ++ " root=" ++ rv(U64H.uint64_hash_tree_root(O.hasher(), U64.u64_default()))
def c13() -> String: "v513u64 ser=" ++ so_w(V513u64E.vec_uint64_513_serialize(V513u64.v513_u64_default())) ++ " root=" ++ ro_w(V513u64H.vec_uint64_513_hash_tree_root(O.hasher(), V513u64.v513_u64_default()))
def c14() -> String: "v513u128 ser=" ++ so_w(V513u128E.vec_uint128_513_serialize(V513u128.v513_u128_default())) ++ " root=" ++ ro_w(V513u128H.vec_uint128_513_hash_tree_root(O.hasher(), V513u128.v513_u128_default()))
def c15() -> String: "v513u256 ser=" ++ so_w(V513u256E.vec_uint256_513_serialize(V513u256.v513_u256_default())) ++ " root=" ++ ro_w(V513u256H.vec_uint256_513_hash_tree_root(O.hasher(), V513u256.v513_u256_default()))
def c16() -> String: "blobsidecar ser=" ++ so_bs(BSE.BlobSidecar_serialize(BS.BlobSidecar_default())) ++ " root=" ++ ro_bs(BSH.BlobSidecar_hash_tree_root(O.hasher(), BS.BlobSidecar_default()))
def c17() -> String: "deposit ser=" ++ so_dp(DPE.Deposit_serialize(DP.Deposit_default())) ++ " root=" ++ ro_dp(DPH.Deposit_hash_tree_root(O.hasher(), DP.Deposit_default()))
def c18() -> String: "synccommittee ser=" ++ so_sc(SCE.SyncCommittee_serialize(SC.SyncCommittee_default())) ++ " root=" ++ ro_sc(SCH.SyncCommittee_hash_tree_root(O.hasher(), SC.SyncCommittee_default()))
def c19() -> String: "histbatch ser=" ++ so_hb(HBE.HistoricalBatch_serialize(HB.HistoricalBatch_default())) ++ " root=" ++ ro_hb(HBH.HistoricalBatch_hash_tree_root(O.hasher(), HB.HistoricalBatch_default()))

def dispatch(+c: U32) -> String:
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
    case _: c19()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    IO.print(dispatch(c))
