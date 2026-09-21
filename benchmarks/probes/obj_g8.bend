import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/io.bend as IOx

# Compile-cost probe: eight types, decode + encode + root.
type Any is Type:
  A_BeaconState{v: T.BeaconState}
  A_BeaconBlockBody{v: T.BeaconBlockBody}
  A_ExecutionPayload{v: T.ExecutionPayload}
  A_LightClientUpdate{v: T.LightClientUpdate}
  A_DataColumnSidecar{v: T.DataColumnSidecar}
  A_SignedBeaconBlock{v: T.SignedBeaconBlock}
  A_Attestation{v: T.Attestation}
  A_ExecutionPayloadHeader{v: T.ExecutionPayloadHeader}
def some_BeaconState(pair: B.Buf & Maybe<&1, T.BeaconState>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_BeaconState{v}})
    case None{}: (buf, None{})
def some_BeaconBlockBody(pair: B.Buf & Maybe<&1, T.BeaconBlockBody>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_BeaconBlockBody{v}})
    case None{}: (buf, None{})
def some_ExecutionPayload(pair: B.Buf & Maybe<&1, T.ExecutionPayload>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_ExecutionPayload{v}})
    case None{}: (buf, None{})
def some_LightClientUpdate(pair: B.Buf & Maybe<&1, T.LightClientUpdate>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_LightClientUpdate{v}})
    case None{}: (buf, None{})
def some_DataColumnSidecar(pair: B.Buf & Maybe<&1, T.DataColumnSidecar>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_DataColumnSidecar{v}})
    case None{}: (buf, None{})
def some_SignedBeaconBlock(pair: B.Buf & Maybe<&1, T.SignedBeaconBlock>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_SignedBeaconBlock{v}})
    case None{}: (buf, None{})
def some_Attestation(pair: B.Buf & Maybe<&1, T.Attestation>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_Attestation{v}})
    case None{}: (buf, None{})
def some_ExecutionPayloadHeader(pair: B.Buf & Maybe<&1, T.ExecutionPayloadHeader>) -> B.Buf & Maybe<&1, Any>:
  (buf, m) = pair
  match m:
    case Some{v}: (buf, Some{A_ExecutionPayloadHeader{v}})
    case None{}: (buf, None{})
def decode(+i: U32, buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, Any>:
  match i:
    case 84: some_BeaconState(T.BeaconState_decode(buf, size))
    case 94: some_BeaconBlockBody(T.BeaconBlockBody_decode(buf, size))
    case 83: some_ExecutionPayload(T.ExecutionPayload_decode(buf, size))
    case 89: some_LightClientUpdate(T.LightClientUpdate_decode(buf, size))
    case 107: some_DataColumnSidecar(T.DataColumnSidecar_decode(buf, size))
    case 65: some_SignedBeaconBlock(T.SignedBeaconBlock_decode(buf, size))
    case 48: some_Attestation(T.Attestation_decode(buf, size))
    case 45: some_ExecutionPayloadHeader(T.ExecutionPayloadHeader_decode(buf, size))
    case _: (buf, None{})
def enc_BeaconState(pair: T.BeaconState & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_BeaconState{v}, out)
def root_BeaconState(pair: B.Buf & (T.BeaconState & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_BeaconState{v}, d))
def enc_BeaconBlockBody(pair: T.BeaconBlockBody & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_BeaconBlockBody{v}, out)
def root_BeaconBlockBody(pair: B.Buf & (T.BeaconBlockBody & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_BeaconBlockBody{v}, d))
def enc_ExecutionPayload(pair: T.ExecutionPayload & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_ExecutionPayload{v}, out)
def root_ExecutionPayload(pair: B.Buf & (T.ExecutionPayload & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_ExecutionPayload{v}, d))
def enc_LightClientUpdate(pair: T.LightClientUpdate & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_LightClientUpdate{v}, out)
def root_LightClientUpdate(pair: B.Buf & (T.LightClientUpdate & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_LightClientUpdate{v}, d))
def enc_DataColumnSidecar(pair: T.DataColumnSidecar & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_DataColumnSidecar{v}, out)
def root_DataColumnSidecar(pair: B.Buf & (T.DataColumnSidecar & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_DataColumnSidecar{v}, d))
def enc_SignedBeaconBlock(pair: T.SignedBeaconBlock & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_SignedBeaconBlock{v}, out)
def root_SignedBeaconBlock(pair: B.Buf & (T.SignedBeaconBlock & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_SignedBeaconBlock{v}, d))
def enc_Attestation(pair: T.Attestation & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_Attestation{v}, out)
def root_Attestation(pair: B.Buf & (T.Attestation & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_Attestation{v}, d))
def enc_ExecutionPayloadHeader(pair: T.ExecutionPayloadHeader & B.Buf) -> Any & B.Buf:
  (v, out) = pair
  (A_ExecutionPayloadHeader{v}, out)
def root_ExecutionPayloadHeader(pair: B.Buf & (T.ExecutionPayloadHeader & D.Digest)) -> B.Buf & (Any & D.Digest):
  (h, r) = pair
  (v, d) = r
  (h, (A_ExecutionPayloadHeader{v}, d))
def encode(a: Any) -> Any & B.Buf:
  match a:
    case A_BeaconState{v}: enc_BeaconState(T.BeaconState_encode(v))
    case A_BeaconBlockBody{v}: enc_BeaconBlockBody(T.BeaconBlockBody_encode(v))
    case A_ExecutionPayload{v}: enc_ExecutionPayload(T.ExecutionPayload_encode(v))
    case A_LightClientUpdate{v}: enc_LightClientUpdate(T.LightClientUpdate_encode(v))
    case A_DataColumnSidecar{v}: enc_DataColumnSidecar(T.DataColumnSidecar_encode(v))
    case A_SignedBeaconBlock{v}: enc_SignedBeaconBlock(T.SignedBeaconBlock_encode(v))
    case A_Attestation{v}: enc_Attestation(T.Attestation_encode(v))
    case A_ExecutionPayloadHeader{v}: enc_ExecutionPayloadHeader(T.ExecutionPayloadHeader_encode(v))
def root(h: B.Buf, a: Any) -> B.Buf & (Any & D.Digest):
  match a:
    case A_BeaconState{v}: root_BeaconState(T.BeaconState_hash_tree_root(h, v))
    case A_BeaconBlockBody{v}: root_BeaconBlockBody(T.BeaconBlockBody_hash_tree_root(h, v))
    case A_ExecutionPayload{v}: root_ExecutionPayload(T.ExecutionPayload_hash_tree_root(h, v))
    case A_LightClientUpdate{v}: root_LightClientUpdate(T.LightClientUpdate_hash_tree_root(h, v))
    case A_DataColumnSidecar{v}: root_DataColumnSidecar(T.DataColumnSidecar_hash_tree_root(h, v))
    case A_SignedBeaconBlock{v}: root_SignedBeaconBlock(T.SignedBeaconBlock_hash_tree_root(h, v))
    case A_Attestation{v}: root_Attestation(T.Attestation_hash_tree_root(h, v))
    case A_ExecutionPayloadHeader{v}: root_ExecutionPayloadHeader(T.ExecutionPayloadHeader_hash_tree_root(h, v))
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
