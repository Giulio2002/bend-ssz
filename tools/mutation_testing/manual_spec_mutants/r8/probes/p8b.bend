import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/list_ProgressiveSingleFieldContainerTestStruct_10_def_generated.bend as L10
import ../../../../../types/list_ProgressiveSingleFieldContainerTestStruct_10_hashtreeroot_generated.bend as L10H
import ../../../../../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as PS
import ../../../../../types/Fulu_list_ConsolidationRequest_2_def_generated.bend as L2
import ../../../../../types/Fulu_list_ConsolidationRequest_2_hashtreeroot_generated.bend as L2H
import ../../../../../types/FuluConsolidationRequest_def_generated.bend as CR
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as TX
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_hashtreeroot_generated.bend as TXH
import ../../../../../types/Fulu_list_Attestation_8_def_generated.bend as LA
import ../../../../../types/Fulu_list_Attestation_8_encode_ssz_generated.bend as LAE
import ../../../../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as LAH
import ../../../../../types/FuluAttestation_def_generated.bend as AT
import ../../../../../types/vec_VarTestStruct_2_def_generated.bend as V2
import ../../../../../types/vec_VarTestStruct_2_hashtreeroot_generated.bend as V2H
import ../../../../../types/vec_VarTestStruct_2_encode_ssz_generated.bend as V2E
import ../../../../../types/VarTestStruct_def_generated.bend as VT
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-8 probe b: cached Merkle trees, take / set / append through public calls only (X_default, X_append, X_cache, X_capp, X_ctake,
# X_cached_root, X_uncache, X_set, X_take, X_valid, the hash_tree_root of the list kind, element X_default / record constructors).
# SSZ_CASE:
#  1 List[ProgressiveSingleFieldContainerTestStruct, 10] of 1 default element: plain root vs cached root          (r8-d01/14, /15)
#  2 the same list kind: cache of the empty list, capp 10 defaults, then an 11th capp: its ok flag and the length (r8-d01/16)
#  3 List[ConsolidationRequest, 2] of 1 default element: plain root vs cached root                                  (r8-d02/01)
#  4 transactions [0x01, 0x02]: cache, cached_root, ctake(0), then cached root vs the plain root of the returned list (r8-d01/18)
#  5 List[Attestation, 8], empty: set(0, default): the ok flag and the length                                      (r8-e01/02)
#  6 List[Attestation, 8]: append 2 defaults (the storage grows on the 2nd): X_valid and the root                  (r8-e01/04)
#  7 Vector[VarTestStruct, 2] default: take(2): Some/None, then X_valid and the root of the returned vector        (r8-e02/01)
#  8 Vector[VarTestStruct, 2] default: set(2, {A = 5, B = [], C = 7}): the ok flag, X_valid and the root           (r8-e02/02)

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(h)

def okc(b: Bool) -> String: O.pick_str(b)

def l10_fst(pair: L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq & Bool) -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq:
  (o, ok) = pair
  o
def l10_one() -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq: l10_fst(L10.l10_ProgressiveSingleFieldContainerTestStruct_append(L10.l10_ProgressiveSingleFieldContainerTestStruct_default(), PS.ProgressiveSingleFieldContainerTestStruct_default()))
def l10_rp(pair: B.Buf & (L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def l10_rc(pair: B.Buf & (L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def l10_cfst(pair: L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached & Bool) -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached:
  (c, ok) = pair
  c
def l10_capp_n(+k: Nat, c: L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached) -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached:
  match k:
    case 0n: c
    case 1n+q: l10_capp_n(q, l10_cfst(L10.l10_ProgressiveSingleFieldContainerTestStruct_capp(c, PS.ProgressiveSingleFieldContainerTestStruct_default())))
def l10_c2b(ok: Bool, pair: L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached & U32) -> IO(Unit):
  (c, +n) = pair
  IO.print("c2 capp11 ok=" ++ okc(ok) ++ " clen=" ++ U32.show(n))
def l10_c2(pair: L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  l10_c2b(ok, L10.l10_ProgressiveSingleFieldContainerTestStruct_clen(c))

def l2_fst(pair: L2.l2_ConsolidationRequest_Seq & Bool) -> L2.l2_ConsolidationRequest_Seq:
  (o, ok) = pair
  o
def l2_one() -> L2.l2_ConsolidationRequest_Seq: l2_fst(L2.l2_ConsolidationRequest_append(L2.l2_ConsolidationRequest_default(), CR.ConsolidationRequest_default()))
def l2_rp(pair: B.Buf & (L2.l2_ConsolidationRequest_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def l2_rc(pair: B.Buf & (L2.l2_ConsolidationRequest_Cached & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)

def tx_fst(pair: TX.l1048576_bl1073741824_Seq & Bool) -> TX.l1048576_bl1073741824_Seq:
  (o, ok) = pair
  o
def tx_w(+v: U32) -> O.Words: O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, v), 1}
def tx_two() -> TX.l1048576_bl1073741824_Seq: tx_fst(TX.l1048576_bl1073741824_append(tx_fst(TX.l1048576_bl1073741824_append(TX.l1048576_bl1073741824_default(), tx_w(1))), tx_w(2)))
def tx_rp(pair: B.Buf & (TX.l1048576_bl1073741824_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def tx_c4c(pair: B.Buf & (TX.l1048576_bl1073741824_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print("c4 after ctake cached=" ++ rs(d) ++ " plain=" ++ tx_rp(TXH.l1048576_bl1073741824_root(64n, O.hasher(), TX.l1048576_bl1073741824_uncache(c), 0)))
def tx_c4b(pair: TX.l1048576_bl1073741824_Cached & Maybe<&1, O.Words>) -> IO(Unit):
  (c, m) = pair
  tx_c4c(TX.l1048576_bl1073741824_cached_root(64n, O.hasher(), c, 0))
def tx_c4a(pair: B.Buf & (TX.l1048576_bl1073741824_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d0) = r
  tx_c4b(TX.l1048576_bl1073741824_ctake(c, 0))

def la_len(ok: Bool, pair: LA.l8_Attestation_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print("c5 set(0) on empty ok=" ++ okc(ok) ++ " len=" ++ U32.show(n))
def la_c5(pair: LA.l8_Attestation_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  la_len(ok, LA.l8_Attestation_len(o))
def la_fst(pair: LA.l8_Attestation_Seq & Bool) -> LA.l8_Attestation_Seq:
  (o, ok) = pair
  o
def la_rp(pair: B.Buf & (LA.l8_Attestation_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def LAE_root(o: LA.l8_Attestation_Seq) -> B.Buf & (LA.l8_Attestation_Seq & D.Digest): LAH.l8_Attestation_root(64n, O.hasher(), o, 0)
def la_c6(pair: LA.l8_Attestation_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("c6 two appends valid=" ++ okc(ok) ++ " root=" ++ la_rp(LAE_root(o)))

def v2_rp(pair: B.Buf & (V2.v2_VarTestStruct_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def v2_c7b(s: String, pair: V2.v2_VarTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(s ++ " valid=" ++ okc(ok) ++ " root=" ++ v2_rp(V2H.v2_VarTestStruct_root(64n, O.hasher(), o, 0)))
def some_str(m: Maybe<&1, VT.VarTestStruct>) -> String:
  match m:
    case Some{v}: "Some"
    case None{}: "None"
def v2_c7(pair: V2.v2_VarTestStruct_Seq & Maybe<&1, VT.VarTestStruct>) -> IO(Unit):
  (o, m) = pair
  v2_c7b("c7 take(2)=" ++ some_str(m), V2E.v2_VarTestStruct_valid(o))
def v2_c8(pair: V2.v2_VarTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  v2_c7b("c8 set(2) ok=" ++ okc(ok), V2E.v2_VarTestStruct_valid(o))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: IO.print("c1 plain=" ++ l10_rp(L10H.l10_ProgressiveSingleFieldContainerTestStruct_root(64n, O.hasher(), l10_one(), 0)) ++ " cached=" ++ l10_rc(L10.l10_ProgressiveSingleFieldContainerTestStruct_cached_root(64n, O.hasher(), L10.l10_ProgressiveSingleFieldContainerTestStruct_cache(l10_one()), 0)))
    case 2: l10_c2(L10.l10_ProgressiveSingleFieldContainerTestStruct_capp(l10_capp_n(10n, L10.l10_ProgressiveSingleFieldContainerTestStruct_cache(L10.l10_ProgressiveSingleFieldContainerTestStruct_default())), PS.ProgressiveSingleFieldContainerTestStruct_default()))
    case 3: IO.print("c3 plain=" ++ l2_rp(L2H.l2_ConsolidationRequest_root(64n, O.hasher(), l2_one(), 0)) ++ " cached=" ++ l2_rc(L2.l2_ConsolidationRequest_cached_root(64n, O.hasher(), L2.l2_ConsolidationRequest_cache(l2_one()), 0)))
    case 4: tx_c4a(TX.l1048576_bl1073741824_cached_root(64n, O.hasher(), TX.l1048576_bl1073741824_cache(tx_two()), 0))
    case 5: la_c5(LA.l8_Attestation_set(LA.l8_Attestation_default(), 0, AT.Attestation_default()))
    case 6: la_c6(LAE.l8_Attestation_valid(la_fst(LA.l8_Attestation_append(la_fst(LA.l8_Attestation_append(LA.l8_Attestation_default(), AT.Attestation_default())), AT.Attestation_default()))))
    case 7: v2_c7(V2.v2_VarTestStruct_take(V2.v2_VarTestStruct_default(), 2))
    case _: v2_c8(V2.v2_VarTestStruct_set(V2.v2_VarTestStruct_default(), 2, VT.VarTestStruct{5, O.Words{Array.new(U32, 0n, 0), 0}, 7}))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
