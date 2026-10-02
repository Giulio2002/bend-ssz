import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluSignedBeaconBlock_def_generated.bend as SBd
import ../../types/FuluSignedBeaconBlock_encode_ssz_generated.bend as SBe
import ../../types/FuluSignedBeaconBlock_hashtreeroot_generated.bend as SBh
import ../../types/FuluSignedBeaconBlock_decode_ssz_generated.bend as SBr
import ../../types/FuluBeaconBlock_def_generated.bend as BKd
import ../../types/FuluBeaconBlockBody_def_generated.bend as BYd
import ../../types/FuluAttestation_def_generated.bend as ATd
import ../../types/FuluAttestationData_def_generated.bend as ADd
import ../../types/Fulu_list_Attestation_8_def_generated.bend as L8
import ../../types/FuluBeaconState_def_generated.bend as BSd
import ../../types/FuluBeaconState_encode_ssz_generated.bend as BSe
import ../../types/FuluBeaconState_hashtreeroot_generated.bend as BSh
import ../../types/FuluBeaconState_decode_ssz_generated.bend as BSr
import ../../types/FuluValidator_def_generated.bend as VAd
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as LV
import ../../types/Fulu_list_uint64_1099511627776_def_generated.bend as L64
import ../../types/Fulu_list_uint8_1099511627776_def_generated.bend as L8u
import ../../types/FuluPendingDeposit_def_generated.bend as PDd
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as LPD
import ../../types/proglist_uint8_decode_ssz_generated.bend as P8R
import ../../types/proglist_uint8_hashtreeroot_generated.bend as P8H
import ../../types/proglist_bool_decode_ssz_generated.bend as PBR
import ../../types/progbitlist_hashtreeroot_generated.bend as PbH
import ../../types/FuluAttestation_decode_ssz_generated.bend as ATr
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt round 2, probe I: objects built through setters (nested lists of containers) against decode(serialize(o)),
# decode_checked with a lying buffer, _ok with a wrapping offset, honest large progressive roots. SSZ_CASE / SSZ_ARG / SSZ_N.

# ---- 1: SignedBeaconBlock built through setters ----------------------------------------------
def att_bits(+k: Nat, +i: U32, a: ATd.Attestation) -> ATd.Attestation:
  match k:
    case 0n: a
    case 1n+q: att_bits(q, (i + 1 : U32), Pair.fst(ATd.Attestation, Bool, ATd.Attestation_fuzz(a, 1, i, (i * 7 + 1 : U32))))

def att_one(+bits: U32, +i: U32) -> ATd.Attestation:
  ATd.Attestation_set_data(att_bits(U32.to_nat(bits), 0, ATd.Attestation_default()), ADd.AttestationData_seed(i))

def atts(+k: Nat, +bits: U32, +i: U32, l: L8.l8_Attestation_Seq) -> L8.l8_Attestation_Seq:
  match k:
    case 0n: l
    case 1n+q: atts(q, bits, (i + 1 : U32), Pair.fst(L8.l8_Attestation_Seq, Bool, L8.l8_Attestation_append(l, att_one(bits, i))))

def build1(+k: U32, +bits: U32) -> SBd.SignedBeaconBlock:
  SBd.SignedBeaconBlock_set_message(SBd.SignedBeaconBlock_default(),
    BKd.BeaconBlock_set_body(BKd.BeaconBlock_default(),
      BYd.BeaconBlockBody_bx_wrap(BYd.BeaconBlockBody_set_attestations(BYd.BeaconBlockBody_default(), atts(U32.to_nat(k), bits, 0, L8.l8_Attestation_default())))))

def fin4(ok: Bool, a: String, +n: U32, rp: B.Buf & (SBd.SignedBeaconBlock & D.Digest)) -> IO(Unit):
  (h, r) = rp
  (o, d) = r
  IO.print("SBB ser_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " root_built=" ++ a ++ " root_decoded=" ++ IOx.words(d))

def fin3(ok: Bool, a: String, +n: U32, pair: B.Buf & Maybe<&1, SBd.SignedBeaconBlock>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: fin4(ok, a, n, SBh.SignedBeaconBlock_hash_tree_root(O.hasher(), v))
    case None{}: IO.print("SBB ser_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " decode=none")

def fin2(ok: Bool, rp: B.Buf & (SBd.SignedBeaconBlock & D.Digest), bp: B.Buf & U32) -> IO(Unit):
  (h, r) = rp
  (o, d) = r
  (b, +n) = bp
  fin3(ok, IOx.words(d), n, SBr.SignedBeaconBlock_decode_checked(b, n))

def fin1(pair: SBd.SignedBeaconBlock & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: fin2(ok, SBh.SignedBeaconBlock_hash_tree_root(O.hasher(), o), B.size(b))

def c1(+k: U32, +bits: U32) -> IO(Unit): fin1(SBe.SignedBeaconBlock_serialize(build1(k, bits)))

# ---- 2: BeaconState built through setters ---------------------------------------------------------
def vals(+k: Nat, +i: U32, l: LV.l1099511627776_Validator_Seq) -> LV.l1099511627776_Validator_Seq:
  match k:
    case 0n: l
    case 1n+q: vals(q, (i + 1 : U32), Pair.fst(LV.l1099511627776_Validator_Seq, Bool, LV.l1099511627776_Validator_append(l, VAd.Validator_seed(i))))

def bals(+k: Nat, +i: U32, w: O.Words) -> O.Words:
  match k:
    case 0n: w
    case 1n+q: bals(q, (i + 1 : U32), Pair.fst(O.Words, Bool, L64.l1099511627776_u64_append(w, O.U64{(i * 2654435761 : U32), i})))

def parts(+k: Nat, +i: U32, w: O.Words) -> O.Words:
  match k:
    case 0n: w
    case 1n+q: parts(q, (i + 1 : U32), Pair.fst(O.Words, Bool, L8u.l1099511627776_u8_append(w, (((i * 37 : U32) .&. 255) : U32))))

def pds(+k: Nat, +i: U32, l: LPD.l134217728_PendingDeposit_Seq) -> LPD.l134217728_PendingDeposit_Seq:
  match k:
    case 0n: l
    case 1n+q: pds(q, (i + 1 : U32), Pair.fst(LPD.l134217728_PendingDeposit_Seq, Bool, LPD.l134217728_PendingDeposit_append(l, PDd.PendingDeposit_seed(i))))

def build2(+k: U32) -> BSd.BeaconState:
  BSd.BeaconState_set_pending_deposits(
    BSd.BeaconState_set_previous_epoch_participation(
      BSd.BeaconState_set_balances(
        BSd.BeaconState_set_validators(BSd.BeaconState_default(), vals(U32.to_nat(k), 0, LV.l1099511627776_Validator_default())),
        bals(U32.to_nat(k), 1, L64.l1099511627776_u64_default())),
      parts(U32.to_nat(k), 2, L8u.l1099511627776_u8_default())),
    pds(U32.to_nat(k), 3, LPD.l134217728_PendingDeposit_default()))

def gin4(ok: Bool, a: String, +n: U32, rp: B.Buf & (BSd.BeaconState & D.Digest)) -> IO(Unit):
  (h, r) = rp
  (o, d) = r
  IO.print("BS ser_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " root_built=" ++ a ++ " root_decoded=" ++ IOx.words(d))

def gin3(ok: Bool, a: String, +n: U32, pair: B.Buf & Maybe<&1, BSd.BeaconState>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: gin4(ok, a, n, BSh.BeaconState_hash_tree_root(O.hasher(), v))
    case None{}: IO.print("BS ser_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " decode=none")

def gin2(ok: Bool, rp: B.Buf & (BSd.BeaconState & D.Digest), bp: B.Buf & U32) -> IO(Unit):
  (h, r) = rp
  (o, d) = r
  (b, +n) = bp
  gin3(ok, IOx.words(d), n, BSr.BeaconState_decode_checked(b, n))

def gin1(pair: BSd.BeaconState & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: gin2(ok, BSh.BeaconState_hash_tree_root(O.hasher(), o), B.size(b))

def c2(+k: U32) -> IO(Unit): gin1(BSe.BeaconState_serialize(build2(k)))

# ---- 3: decode_checked with a buffer that claims more than it holds ---------------------------------
def dec_u8(pair: B.Buf & Maybe<&1, O.Words>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{w}: IO.print("decode=some")
    case None{}: IO.print("decode=none")
def c3(+n: U32) -> IO(Unit): dec_u8(P8R.proglist_uint8_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
def c4(+n: U32) -> IO(Unit): dec_u8(PBR.proglist_bool_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))

# ---- 5: _ok with a window that wraps the 32-bit offset --------------------------------------------------
def ok_line(pair: B.Buf & Bool) -> IO(Unit):
  (b, ok) = pair
  IO.print("ok=" ++ O.pick_str(ok))
def c5(+off: U32, +len: U32) -> IO(Unit): ok_line(ATr.Attestation_ok(B.Buf{Array.new(U32, 10n, 0), 4096}, off, len))

# ---- 6/7: honest large progressive roots --------------------------------------------------------------------
def root_w(pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("root=" ++ IOx.words(d))
def c6(+n: U32) -> IO(Unit): root_w(P8H.proglist_uint8_hash_tree_root(O.hasher(), O.words_new(n)))
def root_b(pair: B.Buf & (O.Bits & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("root=" ++ IOx.words(d))
def c7(+n: U32) -> IO(Unit): root_b(PbH.progbitlist_hash_tree_root(O.hasher(), O.bits_zeros(n)))

def dispatch(+c: U32, +a: U32, +n: U32) -> IO(Unit):
  match c:
    case 1: c1(a, n)
    case 2: c2(a)
    case 3: c3(a)
    case 4: c4(a)
    case 5: c5(a, n)
    case 6: c6(a)
    case _: c7(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    +n : U32 <- IOx.env_u32("SSZ_N")
    dispatch(c, a, n)
