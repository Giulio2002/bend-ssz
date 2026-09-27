import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../types/FuluAttestation_decode_ssz_generated.bend as FuluAttestation_r
import ../../types/FuluAttestation_encode_ssz_generated.bend as FuluAttestation_e
import ../../types/FuluAttestation_hashtreeroot_generated.bend as FuluAttestation_h
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/FuluExecutionPayloadHeader_decode_ssz_generated.bend as FuluExecutionPayloadHeader_r
import ../../types/FuluExecutionPayloadHeader_encode_ssz_generated.bend as FuluExecutionPayloadHeader_e
import ../../types/FuluExecutionPayloadHeader_hashtreeroot_generated.bend as FuluExecutionPayloadHeader_h
import ../../types/FuluExecutionPayload_def_generated.bend as FuluExecutionPayload_d
import ../../types/FuluExecutionPayload_decode_ssz_generated.bend as FuluExecutionPayload_r
import ../../types/FuluExecutionPayload_encode_ssz_generated.bend as FuluExecutionPayload_e
import ../../types/FuluExecutionPayload_hashtreeroot_generated.bend as FuluExecutionPayload_h
import ../../types/FuluBeaconState_def_generated.bend as FuluBeaconState_d
import ../../types/FuluBeaconState_decode_ssz_generated.bend as FuluBeaconState_r
import ../../types/FuluBeaconState_encode_ssz_generated.bend as FuluBeaconState_e
import ../../types/FuluBeaconState_hashtreeroot_generated.bend as FuluBeaconState_h
import ../../types/FuluLightClientUpdate_def_generated.bend as FuluLightClientUpdate_d
import ../../types/FuluLightClientUpdate_decode_ssz_generated.bend as FuluLightClientUpdate_r
import ../../types/FuluLightClientUpdate_encode_ssz_generated.bend as FuluLightClientUpdate_e
import ../../types/FuluLightClientUpdate_hashtreeroot_generated.bend as FuluLightClientUpdate_h
import ../../types/FuluBeaconBlockBody_def_generated.bend as FuluBeaconBlockBody_d
import ../../types/FuluBeaconBlockBody_decode_ssz_generated.bend as FuluBeaconBlockBody_r
import ../../types/FuluBeaconBlockBody_encode_ssz_generated.bend as FuluBeaconBlockBody_e
import ../../types/FuluBeaconBlockBody_hashtreeroot_generated.bend as FuluBeaconBlockBody_h
import ../../types/FuluSignedBeaconBlock_def_generated.bend as FuluSignedBeaconBlock_d
import ../../types/FuluSignedBeaconBlock_decode_ssz_generated.bend as FuluSignedBeaconBlock_r
import ../../types/FuluSignedBeaconBlock_encode_ssz_generated.bend as FuluSignedBeaconBlock_e
import ../../types/FuluSignedBeaconBlock_hashtreeroot_generated.bend as FuluSignedBeaconBlock_h
import ../../types/FuluDataColumnSidecar_def_generated.bend as FuluDataColumnSidecar_d
import ../../types/FuluDataColumnSidecar_decode_ssz_generated.bend as FuluDataColumnSidecar_r
import ../../types/FuluDataColumnSidecar_encode_ssz_generated.bend as FuluDataColumnSidecar_e
import ../../types/FuluDataColumnSidecar_hashtreeroot_generated.bend as FuluDataColumnSidecar_h
import ../compact/io.bend as IOx

# Compile-cost probe: eight types, decode + encode + root.
type Any is Type:
  A_BeaconState{v: FuluBeaconState_d.BeaconState}
  A_BeaconBlockBody{v: FuluBeaconBlockBody_d.BeaconBlockBody}
  A_ExecutionPayload{v: FuluExecutionPayload_d.ExecutionPayload}
  A_LightClientUpdate{v: FuluLightClientUpdate_d.LightClientUpdate}
  A_DataColumnSidecar{v: FuluDataColumnSidecar_d.DataColumnSidecar}
  A_SignedBeaconBlock{v: FuluSignedBeaconBlock_d.SignedBeaconBlock}
  A_Attestation{v: FuluAttestation_d.Attestation}
  A_ExecutionPayloadHeader{v: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader}
def some_BeaconState(pair: B.Buf & Maybe<&1, FuluBeaconState_d.BeaconState>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_BeaconState{v}})
    case None{}: (buf, None{})
def some_BeaconBlockBody(pair: B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_BeaconBlockBody{v}})
    case None{}: (buf, None{})
def some_ExecutionPayload(pair: B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_ExecutionPayload{v}})
    case None{}: (buf, None{})
def some_LightClientUpdate(pair: B.Buf & Maybe<&1, FuluLightClientUpdate_d.LightClientUpdate>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_LightClientUpdate{v}})
    case None{}: (buf, None{})
def some_DataColumnSidecar(pair: B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_DataColumnSidecar{v}})
    case None{}: (buf, None{})
def some_SignedBeaconBlock(pair: B.Buf & Maybe<&1, FuluSignedBeaconBlock_d.SignedBeaconBlock>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_SignedBeaconBlock{v}})
    case None{}: (buf, None{})
def some_Attestation(pair: B.Buf & Maybe<&1, FuluAttestation_d.Attestation>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_Attestation{v}})
    case None{}: (buf, None{})
def some_ExecutionPayloadHeader(pair: B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_ExecutionPayloadHeader{v}})
    case None{}: (buf, None{})
def decode(+i: U32, buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, Any>:
  match i:
    case 84: some_BeaconState(FuluBeaconState_r.BeaconState_decode(buf, size))
    case 94: some_BeaconBlockBody(FuluBeaconBlockBody_r.BeaconBlockBody_decode(buf, size))
    case 83: some_ExecutionPayload(FuluExecutionPayload_r.ExecutionPayload_decode(buf, size))
    case 89: some_LightClientUpdate(FuluLightClientUpdate_r.LightClientUpdate_decode(buf, size))
    case 107: some_DataColumnSidecar(FuluDataColumnSidecar_r.DataColumnSidecar_decode(buf, size))
    case 65: some_SignedBeaconBlock(FuluSignedBeaconBlock_r.SignedBeaconBlock_decode(buf, size))
    case 48: some_Attestation(FuluAttestation_r.Attestation_decode(buf, size))
    case 45: some_ExecutionPayloadHeader(FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(buf, size))
    case _: (buf, None{})
def enc_BeaconState(pair: FuluBeaconState_d.BeaconState & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_BeaconState{v}, out)
def root_BeaconState(pair: B.Buf & (FuluBeaconState_d.BeaconState & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_BeaconState{v}, d))
def enc_BeaconBlockBody(pair: FuluBeaconBlockBody_d.BeaconBlockBody & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_BeaconBlockBody{v}, out)
def root_BeaconBlockBody(pair: B.Buf & (FuluBeaconBlockBody_d.BeaconBlockBody & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_BeaconBlockBody{v}, d))
def enc_ExecutionPayload(pair: FuluExecutionPayload_d.ExecutionPayload & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_ExecutionPayload{v}, out)
def root_ExecutionPayload(pair: B.Buf & (FuluExecutionPayload_d.ExecutionPayload & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_ExecutionPayload{v}, d))
def enc_LightClientUpdate(pair: FuluLightClientUpdate_d.LightClientUpdate & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_LightClientUpdate{v}, out)
def root_LightClientUpdate(pair: B.Buf & (FuluLightClientUpdate_d.LightClientUpdate & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_LightClientUpdate{v}, d))
def enc_DataColumnSidecar(pair: FuluDataColumnSidecar_d.DataColumnSidecar & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_DataColumnSidecar{v}, out)
def root_DataColumnSidecar(pair: B.Buf & (FuluDataColumnSidecar_d.DataColumnSidecar & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_DataColumnSidecar{v}, d))
def enc_SignedBeaconBlock(pair: FuluSignedBeaconBlock_d.SignedBeaconBlock & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_SignedBeaconBlock{v}, out)
def root_SignedBeaconBlock(pair: B.Buf & (FuluSignedBeaconBlock_d.SignedBeaconBlock & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_SignedBeaconBlock{v}, d))
def enc_Attestation(pair: FuluAttestation_d.Attestation & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_Attestation{v}, out)
def root_Attestation(pair: B.Buf & (FuluAttestation_d.Attestation & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_Attestation{v}, d))
def enc_ExecutionPayloadHeader(pair: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_ExecutionPayloadHeader{v}, out)
def root_ExecutionPayloadHeader(pair: B.Buf & (FuluExecutionPayloadHeader_d.ExecutionPayloadHeader & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_ExecutionPayloadHeader{v}, d))
def encode(a: Any) -> Any & B.Buf:
  match a:
    case A_BeaconState{v}: enc_BeaconState(FuluBeaconState_e.BeaconState_encode(v))
    case A_BeaconBlockBody{v}: enc_BeaconBlockBody(FuluBeaconBlockBody_e.BeaconBlockBody_encode(v))
    case A_ExecutionPayload{v}: enc_ExecutionPayload(FuluExecutionPayload_e.ExecutionPayload_encode(v))
    case A_LightClientUpdate{v}: enc_LightClientUpdate(FuluLightClientUpdate_e.LightClientUpdate_encode(v))
    case A_DataColumnSidecar{v}: enc_DataColumnSidecar(FuluDataColumnSidecar_e.DataColumnSidecar_encode(v))
    case A_SignedBeaconBlock{v}: enc_SignedBeaconBlock(FuluSignedBeaconBlock_e.SignedBeaconBlock_encode(v))
    case A_Attestation{v}: enc_Attestation(FuluAttestation_e.Attestation_encode(v))
    case A_ExecutionPayloadHeader{v}: enc_ExecutionPayloadHeader(FuluExecutionPayloadHeader_e.ExecutionPayloadHeader_encode(v))
def root(h: B.Buf, a: Any) -> B.Buf & (Any & D.Digest):
  match a:
    case A_BeaconState{v}: root_BeaconState(FuluBeaconState_h.BeaconState_hash_tree_root(h, v))
    case A_BeaconBlockBody{v}: root_BeaconBlockBody(FuluBeaconBlockBody_h.BeaconBlockBody_hash_tree_root(h, v))
    case A_ExecutionPayload{v}: root_ExecutionPayload(FuluExecutionPayload_h.ExecutionPayload_hash_tree_root(h, v))
    case A_LightClientUpdate{v}: root_LightClientUpdate(FuluLightClientUpdate_h.LightClientUpdate_hash_tree_root(h, v))
    case A_DataColumnSidecar{v}: root_DataColumnSidecar(FuluDataColumnSidecar_h.DataColumnSidecar_hash_tree_root(h, v))
    case A_SignedBeaconBlock{v}: root_SignedBeaconBlock(FuluSignedBeaconBlock_h.SignedBeaconBlock_hash_tree_root(h, v))
    case A_Attestation{v}: root_Attestation(FuluAttestation_h.Attestation_hash_tree_root(h, v))
    case A_ExecutionPayloadHeader{v}: root_ExecutionPayloadHeader(FuluExecutionPayloadHeader_h.ExecutionPayloadHeader_hash_tree_root(h, v))
def shown(pair: B.Buf & (Any & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (a, d) = r
  IO.print("OK")
def encoded(pair: Any & B.Buf) -> IO(Unit):
  (a, out) = pair
  shown(root(O.hasher(), a))
def done(pair: B.Buf & Maybe<&1, Any>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("REJECT")
    case Some{a}: encoded(encode(a))
def with_input(+i: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(decode(i, buf, size))
def main() -> IO(Unit):
  do IO<Unit>:
    +i : U32 <- IOx.env_u32("SSZ_INDEX")
    input : B.Buf & U32 <- IOx.load()
    with_input(i, input)
