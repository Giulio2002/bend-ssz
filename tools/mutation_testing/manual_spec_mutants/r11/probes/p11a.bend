import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../benchmarks/compact/objio.bend as IOx
import ../../../../../types/FuluAttestationData_def_generated.bend as AD
import ../../../../../types/FuluAttestation_def_generated.bend as AT
import ../../../../../types/FuluIndexedAttestation_def_generated.bend as IA
import ../../../../../types/FuluAttesterSlashing_def_generated.bend as AS
import ../../../../../types/FuluProposerSlashing_def_generated.bend as PSL
import ../../../../../types/Fulu_list_Attestation_8_def_generated.bend as LA
import ../../../../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as LAH
import ../../../../../types/Fulu_list_AttesterSlashing_1_def_generated.bend as L1
import ../../../../../types/Fulu_list_AttesterSlashing_1_hashtreeroot_generated.bend as L1H
import ../../../../../types/Fulu_list_ProposerSlashing_16_def_generated.bend as L16
import ../../../../../types/Fulu_list_ProposerSlashing_16_hashtreeroot_generated.bend as L16H
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as TX
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_hashtreeroot_generated.bend as TXH
import ../../../../../types/list_ProgressiveSingleFieldContainerTestStruct_10_def_generated.bend as L10
import ../../../../../types/list_ProgressiveSingleFieldContainerTestStruct_10_hashtreeroot_generated.bend as L10H
import ../../../../../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as PS
import ../../../../../types/CompatibleUnionABCA_def_generated.bend as UA
import ../../../../../types/CompatibleUnionABCA_encode_ssz_generated.bend as UAE
import ../../../../../types/CompatibleUnionABCA_decode_ssz_generated.bend as UAD

# Round-11 probe a: the cached-tree API (X_cache, X_capp, X_cset, X_cached_root, X_uncache) and a same-type union option, through
# public calls only (X_default, X_append, the record setters, bx_wrap, the union constructor, X_serialize, X_decode). Each case
# prints the cached root next to the plain root (hash_tree_root of the uncached list): the spec says they are equal.
# SSZ_CASE:
#  1 List[Attestation, 8]: cache(empty), capp x5 (tree depth 0 -> 1 -> 2 -> 3)                    (r11-d02/03)
#  2 transactions: cache(empty), capp x5                                                             (r11-d02/05)
#  3 List[ProgressiveSingleFieldContainerTestStruct, 10]: cache(empty), capp x5                      (r11-d02/06)
#  4 List[AttesterSlashing, 1] = [default]: cache, cached_root, cset(0, slashing with slot 7), root   (r11-d03/04)
#  5 transactions [01, 02]: cache, cached_root, cset(0, [03]), root                                   (r11-d03/05)
#  6 transactions [01, 02]: cache, cached_root, cset(1, [03]), root                                   (r11-d04/03)
#  7 List[AttesterSlashing, 1] = [default]: cache, cached_root                                        (r11-d05/04)
#  8 List[ProposerSlashing, 16] = [d, d]: cache, root, capp(d), root, cset(0, d), root, capp(d), root (r11-d06, r11-d07)
#  9 CompatibleUnionABCA option 4 (ProgressiveSingleFieldContainerTestStruct default): serialize, decode, selector (r11-f01/02)
# 10 List[Attestation, 8] = [d, d]: cache, root, cset(0, attestation with slot 7), root (control: killed design on this list)

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(h)

def okc(b: Bool) -> String: O.pick_str(b)

def slot7() -> AD.AttestationData: AD.AttestationData_set_slot(AD.AttestationData_default(), O.U64{7, 0})

# ---- List[Attestation, 8] ----
def la_fst(pair: LA.l8_Attestation_Seq & Bool) -> LA.l8_Attestation_Seq:
  (o, ok) = pair
  o
def la_cfst(pair: LA.l8_Attestation_Cached & Bool) -> LA.l8_Attestation_Cached:
  (c, ok) = pair
  c
def la_capp_n(+k: Nat, c: LA.l8_Attestation_Cached) -> LA.l8_Attestation_Cached:
  match k:
    case 0n: c
    case 1n+q: la_capp_n(q, la_cfst(LA.l8_Attestation_capp(c, AT.Attestation_default())))
def la_plain(pair: B.Buf & (LA.l8_Attestation_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def la_cmp(s: String, pair: B.Buf & (LA.l8_Attestation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print(s ++ " cached=" ++ rs(d) ++ " plain=" ++ la_plain(LAH.l8_Attestation_root(64n, O.hasher(), LA.l8_Attestation_uncache(c), 0)))
def la_croot_go(pair: B.Buf & (LA.l8_Attestation_Cached & D.Digest)) -> LA.l8_Attestation_Cached:
  (h, r) = pair
  (c, d) = r
  c
def la_croot(c: LA.l8_Attestation_Cached) -> LA.l8_Attestation_Cached:
  la_croot_go(LA.l8_Attestation_cached_root(64n, O.hasher(), c, 0))
def la_two() -> LA.l8_Attestation_Seq: la_fst(LA.l8_Attestation_append(la_fst(LA.l8_Attestation_append(LA.l8_Attestation_default(), AT.Attestation_default())), AT.Attestation_default()))

# ---- transactions ----
def tx_fst(pair: TX.l1048576_bl1073741824_Seq & Bool) -> TX.l1048576_bl1073741824_Seq:
  (o, ok) = pair
  o
def tx_cfst(pair: TX.l1048576_bl1073741824_Cached & Bool) -> TX.l1048576_bl1073741824_Cached:
  (c, ok) = pair
  c
def tx_w(+v: U32) -> O.Words: O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, v), 1}
def tx_two() -> TX.l1048576_bl1073741824_Seq: tx_fst(TX.l1048576_bl1073741824_append(tx_fst(TX.l1048576_bl1073741824_append(TX.l1048576_bl1073741824_default(), tx_w(1))), tx_w(2)))
def tx_capp_n(+k: Nat, +i: U32, c: TX.l1048576_bl1073741824_Cached) -> TX.l1048576_bl1073741824_Cached:
  match k:
    case 0n: c
    case 1n+q: tx_capp_n(q, (i + 1 : U32), tx_cfst(TX.l1048576_bl1073741824_capp(c, tx_w(i))))
def tx_plain(pair: B.Buf & (TX.l1048576_bl1073741824_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def tx_cmp(s: String, pair: B.Buf & (TX.l1048576_bl1073741824_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print(s ++ " cached=" ++ rs(d) ++ " plain=" ++ tx_plain(TXH.l1048576_bl1073741824_root(64n, O.hasher(), TX.l1048576_bl1073741824_uncache(c), 0)))
def tx_croot_go(pair: B.Buf & (TX.l1048576_bl1073741824_Cached & D.Digest)) -> TX.l1048576_bl1073741824_Cached:
  (h, r) = pair
  (c, d) = r
  c
def tx_croot(c: TX.l1048576_bl1073741824_Cached) -> TX.l1048576_bl1073741824_Cached: tx_croot_go(TX.l1048576_bl1073741824_cached_root(64n, O.hasher(), c, 0))

# ---- List[ProgressiveSingleFieldContainerTestStruct, 10] ----
def l10_cfst(pair: L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached & Bool) -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached:
  (c, ok) = pair
  c
def l10_capp_n(+k: Nat, c: L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached) -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached:
  match k:
    case 0n: c
    case 1n+q: l10_capp_n(q, l10_cfst(L10.l10_ProgressiveSingleFieldContainerTestStruct_capp(c, PS.ProgressiveSingleFieldContainerTestStruct_default())))
def l10_plain(pair: B.Buf & (L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def l10_cmp(s: String, pair: B.Buf & (L10.l10_ProgressiveSingleFieldContainerTestStruct_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print(s ++ " cached=" ++ rs(d) ++ " plain=" ++ l10_plain(L10H.l10_ProgressiveSingleFieldContainerTestStruct_root(64n, O.hasher(), L10.l10_ProgressiveSingleFieldContainerTestStruct_uncache(c), 0)))

# ---- List[AttesterSlashing, 1] ----
def as7() -> AS.AttesterSlashing: AS.AttesterSlashing_set_attestation_1(AS.AttesterSlashing_default(), IA.IndexedAttestation_bx_wrap(IA.IndexedAttestation_set_data(IA.IndexedAttestation_default(), slot7())))
def l1_fst(pair: L1.l1_AttesterSlashing_Seq & Bool) -> L1.l1_AttesterSlashing_Seq:
  (o, ok) = pair
  o
def l1_cfst(pair: L1.l1_AttesterSlashing_Cached & Bool) -> L1.l1_AttesterSlashing_Cached:
  (c, ok) = pair
  c
def l1_one() -> L1.l1_AttesterSlashing_Seq: l1_fst(L1.l1_AttesterSlashing_append(L1.l1_AttesterSlashing_default(), AS.AttesterSlashing_default()))
def l1_plain(pair: B.Buf & (L1.l1_AttesterSlashing_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def l1_cmp(s: String, pair: B.Buf & (L1.l1_AttesterSlashing_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print(s ++ " cached=" ++ rs(d) ++ " plain=" ++ l1_plain(L1H.l1_AttesterSlashing_root(64n, O.hasher(), L1.l1_AttesterSlashing_uncache(c), 0)))
def l1_croot_go(pair: B.Buf & (L1.l1_AttesterSlashing_Cached & D.Digest)) -> L1.l1_AttesterSlashing_Cached:
  (h, r) = pair
  (c, d) = r
  c
def l1_croot(c: L1.l1_AttesterSlashing_Cached) -> L1.l1_AttesterSlashing_Cached: l1_croot_go(L1.l1_AttesterSlashing_cached_root(64n, O.hasher(), c, 0))

# ---- List[ProposerSlashing, 16] ----
def p16_fst(pair: L16.l16_ProposerSlashing_Seq & Bool) -> L16.l16_ProposerSlashing_Seq:
  (o, ok) = pair
  o
def p16_cfst(pair: L16.l16_ProposerSlashing_Cached & Bool) -> L16.l16_ProposerSlashing_Cached:
  (c, ok) = pair
  c
def p16_two() -> L16.l16_ProposerSlashing_Seq: p16_fst(L16.l16_ProposerSlashing_append(p16_fst(L16.l16_ProposerSlashing_append(L16.l16_ProposerSlashing_default(), PSL.ProposerSlashing_default())), PSL.ProposerSlashing_default()))
def p16_plain(pair: B.Buf & (L16.l16_ProposerSlashing_Seq & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  rs(d)
def p16_rt(pair: B.Buf & (L16.l16_ProposerSlashing_Cached & D.Digest)) -> L16.l16_ProposerSlashing_Cached & String:
  (h, r) = pair
  (c, d) = r
  (c, rs(d))
def p16_root(c: L16.l16_ProposerSlashing_Cached) -> L16.l16_ProposerSlashing_Cached & String: p16_rt(L16.l16_ProposerSlashing_cached_root(64n, O.hasher(), c, 0))
def p16_s4(s: String, pair: L16.l16_ProposerSlashing_Cached & String) -> IO(Unit):
  (c, x) = pair
  IO.print(s ++ " r4=" ++ x ++ " plain=" ++ p16_plain(L16H.l16_ProposerSlashing_root(64n, O.hasher(), L16.l16_ProposerSlashing_uncache(c), 0)))
def p16_s3(s: String, pair: L16.l16_ProposerSlashing_Cached & String) -> IO(Unit):
  (c, x) = pair
  p16_s4(s ++ " r3=" ++ x, p16_root(p16_cfst(L16.l16_ProposerSlashing_capp(c, PSL.ProposerSlashing_default()))))
def p16_s2(s: String, pair: L16.l16_ProposerSlashing_Cached & String) -> IO(Unit):
  (c, x) = pair
  p16_s3(s ++ " r2=" ++ x, p16_root(p16_cfst(L16.l16_ProposerSlashing_cset(c, 0, PSL.ProposerSlashing_default()))))
def p16_s1(pair: L16.l16_ProposerSlashing_Cached & String) -> IO(Unit):
  (c, x) = pair
  p16_s2("c8 r1=" ++ x, p16_root(p16_cfst(L16.l16_ProposerSlashing_capp(c, PSL.ProposerSlashing_default()))))

# ---- CompatibleUnionABCA option 4 ----
def ua_sel(pair: UA.CompatibleUnionABCA & U32) -> String:
  (u, +s) = pair
  U32.show(s)
def ua_dec(pair: B.Buf & Maybe<&1, UA.CompatibleUnionABCA>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{u}: IO.print("c9 decoded selector=" ++ ua_sel(UA.CompatibleUnionABCA_selector(u)))
    case None{}: IO.print("c9 decode refused")
def ua_sz(pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  ua_dec(UAD.CompatibleUnionABCA_decode(b, n))
def ua_enc(pair: UA.CompatibleUnionABCA & O.Encoded) -> IO(Unit):
  (u, e) = pair
  match e:
    case O.Encoded{x, b}: ua_sz(B.size(b))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: la_cmp("c1", LA.l8_Attestation_cached_root(64n, O.hasher(), la_capp_n(5n, LA.l8_Attestation_cache(LA.l8_Attestation_default())), 0))
    case 2: tx_cmp("c2", TX.l1048576_bl1073741824_cached_root(64n, O.hasher(), tx_capp_n(5n, 1, TX.l1048576_bl1073741824_cache(TX.l1048576_bl1073741824_default())), 0))
    case 3: l10_cmp("c3", L10.l10_ProgressiveSingleFieldContainerTestStruct_cached_root(64n, O.hasher(), l10_capp_n(5n, L10.l10_ProgressiveSingleFieldContainerTestStruct_cache(L10.l10_ProgressiveSingleFieldContainerTestStruct_default())), 0))
    case 4: l1_cmp("c4", L1.l1_AttesterSlashing_cached_root(64n, O.hasher(), l1_cfst(L1.l1_AttesterSlashing_cset(l1_croot(L1.l1_AttesterSlashing_cache(l1_one())), 0, as7())), 0))
    case 5: tx_cmp("c5", TX.l1048576_bl1073741824_cached_root(64n, O.hasher(), tx_cfst(TX.l1048576_bl1073741824_cset(tx_croot(TX.l1048576_bl1073741824_cache(tx_two())), 0, tx_w(3))), 0))
    case 6: tx_cmp("c6", TX.l1048576_bl1073741824_cached_root(64n, O.hasher(), tx_cfst(TX.l1048576_bl1073741824_cset(tx_croot(TX.l1048576_bl1073741824_cache(tx_two())), 1, tx_w(3))), 0))
    case 7: l1_cmp("c7", L1.l1_AttesterSlashing_cached_root(64n, O.hasher(), L1.l1_AttesterSlashing_cache(l1_one()), 0))
    case 8: p16_s1(p16_root(L16.l16_ProposerSlashing_cache(p16_two())))
    case 9: ua_enc(UAE.CompatibleUnionABCA_serialize(UA.CompatibleUnionABCA_c3{PS.ProgressiveSingleFieldContainerTestStruct_default()}))
    case _: la_cmp("c10", LA.l8_Attestation_cached_root(64n, O.hasher(), la_cfst(LA.l8_Attestation_cset(la_croot(LA.l8_Attestation_cache(la_two())), 0, AT.Attestation_set_data(AT.Attestation_default(), slot7()))), 0))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
