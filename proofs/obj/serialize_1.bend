import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes4_def_generated.bend as FuluBytes4_d
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes8_def_generated.bend as FuluBytes8_d
import ../../types/uint256_def_generated.bend as uint256_d
import ../../types/uint8_encode_ssz_generated.bend as uint8_e
import ../../types/uint64_encode_ssz_generated.bend as uint64_e
import ../../types/uint256_encode_ssz_generated.bend as uint256_e
import ../../types/FuluBytes4_encode_ssz_generated.bend as FuluBytes4_e
import ../../types/FuluBytes32_encode_ssz_generated.bend as FuluBytes32_e
import ../../types/FuluBytes48_encode_ssz_generated.bend as FuluBytes48_e
import ../../types/FuluBytes8_encode_ssz_generated.bend as FuluBytes8_e
import ../../types/FuluBytes20_encode_ssz_generated.bend as FuluBytes20_e
import ../../types/FuluEth1Block_def_generated.bend as FuluEth1Block_d
import ../../types/FuluEth1Block_encode_ssz_generated.bend as FuluEth1Block_e
import ../../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../../types/FuluBeaconBlockHeader_encode_ssz_generated.bend as FuluBeaconBlockHeader_e
import ../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../types/FuluSignedBeaconBlockHeader_encode_ssz_generated.bend as FuluSignedBeaconBlockHeader_e
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluEth1Data_encode_ssz_generated.bend as FuluEth1Data_e
import ../../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../../types/FuluCheckpoint_encode_ssz_generated.bend as FuluCheckpoint_e
import ../../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../../types/FuluAttestationData_encode_ssz_generated.bend as FuluAttestationData_e
import ../../types/FuluSingleAttestation_def_generated.bend as FuluSingleAttestation_d
import ../../types/FuluSingleAttestation_encode_ssz_generated.bend as FuluSingleAttestation_e
import ../../types/FuluForkData_def_generated.bend as FuluForkData_d
import ../../types/FuluForkData_encode_ssz_generated.bend as FuluForkData_e
import ../../types/FuluSigningData_def_generated.bend as FuluSigningData_d
import ../../types/FuluSigningData_encode_ssz_generated.bend as FuluSigningData_e
import ../../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../../types/FuluDepositRequest_encode_ssz_generated.bend as FuluDepositRequest_e
import ../../types/FuluPendingDeposit_def_generated.bend as FuluPendingDeposit_d
import ../../types/FuluPendingDeposit_encode_ssz_generated.bend as FuluPendingDeposit_e
import ../../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../../types/FuluDepositData_encode_ssz_generated.bend as FuluDepositData_e
import ../../types/FuluDepositMessage_def_generated.bend as FuluDepositMessage_d
import ../../types/FuluDepositMessage_encode_ssz_generated.bend as FuluDepositMessage_e
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_encode_ssz_generated.bend as FuluValidator_e
import ../../types/FuluConsolidationRequest_def_generated.bend as FuluConsolidationRequest_d
import ../../types/FuluConsolidationRequest_encode_ssz_generated.bend as FuluConsolidationRequest_e
import ../../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../../types/FuluWithdrawalRequest_encode_ssz_generated.bend as FuluWithdrawalRequest_e
import ../../types/FuluBLSToExecutionChange_def_generated.bend as FuluBLSToExecutionChange_d
import ../../types/FuluBLSToExecutionChange_encode_ssz_generated.bend as FuluBLSToExecutionChange_e
import ../../types/FuluSignedBLSToExecutionChange_def_generated.bend as FuluSignedBLSToExecutionChange_d
import ../../types/FuluSignedBLSToExecutionChange_encode_ssz_generated.bend as FuluSignedBLSToExecutionChange_e
import ../../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
import ../../types/FuluWithdrawal_encode_ssz_generated.bend as FuluWithdrawal_e
import ../../types/FuluBlobIdentifier_def_generated.bend as FuluBlobIdentifier_d
import ../../types/FuluBlobIdentifier_encode_ssz_generated.bend as FuluBlobIdentifier_e
import ../../types/FuluForkDigest_encode_ssz_generated.bend as FuluForkDigest_e
import ../../types/FuluDomain_encode_ssz_generated.bend as FuluDomain_e
import ../../types/FuluBLSPubkey_encode_ssz_generated.bend as FuluBLSPubkey_e
import ../../types/FuluNodeID_encode_ssz_generated.bend as FuluNodeID_e
import ../../types/FuluSubnetID_encode_ssz_generated.bend as FuluSubnetID_e
import ../../types/FuluEther_encode_ssz_generated.bend as FuluEther_e
import ../../types/FuluParticipationFlags_encode_ssz_generated.bend as FuluParticipationFlags_e
import ../../types/FuluExecutionAddress_encode_ssz_generated.bend as FuluExecutionAddress_e
import ../../types/FuluPayloadId_encode_ssz_generated.bend as FuluPayloadId_e
import ../../types/FuluWithdrawalIndex_encode_ssz_generated.bend as FuluWithdrawalIndex_e
import ../../types/FuluBlobIndex_encode_ssz_generated.bend as FuluBlobIndex_e
import ../../types/FuluKZGCommitment_encode_ssz_generated.bend as FuluKZGCommitment_e
import ../../types/FuluKZGProof_encode_ssz_generated.bend as FuluKZGProof_e
import ../../types/FuluCellIndex_encode_ssz_generated.bend as FuluCellIndex_e
import ../../types/FuluCommitmentIndex_encode_ssz_generated.bend as FuluCommitmentIndex_e
import ../../types/FuluRowIndex_encode_ssz_generated.bend as FuluRowIndex_e

# GENERATED by codegen/laws.py. Do not edit.
# Checked encoder laws: a valid object serializes to its encoding, an
# invalid representable one (uint8 above 255, bits past a byte vector,
# nested invalid fields) is refused. Stated over a variable object.

def Eth1Block_serialize_valid(+o: FuluEth1Block_d.Eth1Block, e: {FuluEth1Block_e.Eth1Block_valid(o) == True{} : Bool})
    -> {FuluEth1Block_e.Eth1Block_serialize(o) == O.encoded(FuluEth1Block_e.Eth1Block_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluEth1Block_e.Eth1Block_valid(o), True{}, e) : {FuluEth1Block_e.Eth1Block_ser_pick(_, o) == O.encoded(FuluEth1Block_e.Eth1Block_encode(o)) : O.Encoded}
  {==}
def Eth1Block_serialize_refused(+o: FuluEth1Block_d.Eth1Block, e: {FuluEth1Block_e.Eth1Block_valid(o) == False{} : Bool})
    -> {FuluEth1Block_e.Eth1Block_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluEth1Block_e.Eth1Block_valid(o), False{}, e) : {FuluEth1Block_e.Eth1Block_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def BeaconBlockHeader_serialize_valid(+o: FuluBeaconBlockHeader_d.BeaconBlockHeader, e: {FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o) == True{} : Bool})
    -> {FuluBeaconBlockHeader_e.BeaconBlockHeader_serialize(o) == O.encoded(FuluBeaconBlockHeader_e.BeaconBlockHeader_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o), True{}, e) : {FuluBeaconBlockHeader_e.BeaconBlockHeader_ser_pick(_, o) == O.encoded(FuluBeaconBlockHeader_e.BeaconBlockHeader_encode(o)) : O.Encoded}
  {==}
def BeaconBlockHeader_serialize_refused(+o: FuluBeaconBlockHeader_d.BeaconBlockHeader, e: {FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o) == False{} : Bool})
    -> {FuluBeaconBlockHeader_e.BeaconBlockHeader_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o), False{}, e) : {FuluBeaconBlockHeader_e.BeaconBlockHeader_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def SignedBeaconBlockHeader_serialize_valid(+o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader, e: {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o) == True{} : Bool})
    -> {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_serialize(o) == O.encoded(FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o), True{}, e) : {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_ser_pick(_, o) == O.encoded(FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_encode(o)) : O.Encoded}
  {==}
def SignedBeaconBlockHeader_serialize_refused(+o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader, e: {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o) == False{} : Bool})
    -> {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o), False{}, e) : {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def Eth1Data_serialize_valid(+o: FuluEth1Data_d.Eth1Data, e: {FuluEth1Data_e.Eth1Data_valid(o) == True{} : Bool})
    -> {FuluEth1Data_e.Eth1Data_serialize(o) == O.encoded(FuluEth1Data_e.Eth1Data_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluEth1Data_e.Eth1Data_valid(o), True{}, e) : {FuluEth1Data_e.Eth1Data_ser_pick(_, o) == O.encoded(FuluEth1Data_e.Eth1Data_encode(o)) : O.Encoded}
  {==}
def Eth1Data_serialize_refused(+o: FuluEth1Data_d.Eth1Data, e: {FuluEth1Data_e.Eth1Data_valid(o) == False{} : Bool})
    -> {FuluEth1Data_e.Eth1Data_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluEth1Data_e.Eth1Data_valid(o), False{}, e) : {FuluEth1Data_e.Eth1Data_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def Checkpoint_serialize_valid(+o: FuluCheckpoint_d.Checkpoint, e: {FuluCheckpoint_e.Checkpoint_valid(o) == True{} : Bool})
    -> {FuluCheckpoint_e.Checkpoint_serialize(o) == O.encoded(FuluCheckpoint_e.Checkpoint_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluCheckpoint_e.Checkpoint_valid(o), True{}, e) : {FuluCheckpoint_e.Checkpoint_ser_pick(_, o) == O.encoded(FuluCheckpoint_e.Checkpoint_encode(o)) : O.Encoded}
  {==}
def Checkpoint_serialize_refused(+o: FuluCheckpoint_d.Checkpoint, e: {FuluCheckpoint_e.Checkpoint_valid(o) == False{} : Bool})
    -> {FuluCheckpoint_e.Checkpoint_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluCheckpoint_e.Checkpoint_valid(o), False{}, e) : {FuluCheckpoint_e.Checkpoint_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def AttestationData_serialize_valid(+o: FuluAttestationData_d.AttestationData, e: {FuluAttestationData_e.AttestationData_valid(o) == True{} : Bool})
    -> {FuluAttestationData_e.AttestationData_serialize(o) == O.encoded(FuluAttestationData_e.AttestationData_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluAttestationData_e.AttestationData_valid(o), True{}, e) : {FuluAttestationData_e.AttestationData_ser_pick(_, o) == O.encoded(FuluAttestationData_e.AttestationData_encode(o)) : O.Encoded}
  {==}
def AttestationData_serialize_refused(+o: FuluAttestationData_d.AttestationData, e: {FuluAttestationData_e.AttestationData_valid(o) == False{} : Bool})
    -> {FuluAttestationData_e.AttestationData_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluAttestationData_e.AttestationData_valid(o), False{}, e) : {FuluAttestationData_e.AttestationData_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def SingleAttestation_serialize_valid(+o: FuluSingleAttestation_d.SingleAttestation, e: {FuluSingleAttestation_e.SingleAttestation_valid(o) == True{} : Bool})
    -> {FuluSingleAttestation_e.SingleAttestation_serialize(o) == O.encoded(FuluSingleAttestation_e.SingleAttestation_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluSingleAttestation_e.SingleAttestation_valid(o), True{}, e) : {FuluSingleAttestation_e.SingleAttestation_ser_pick(_, o) == O.encoded(FuluSingleAttestation_e.SingleAttestation_encode(o)) : O.Encoded}
  {==}
def SingleAttestation_serialize_refused(+o: FuluSingleAttestation_d.SingleAttestation, e: {FuluSingleAttestation_e.SingleAttestation_valid(o) == False{} : Bool})
    -> {FuluSingleAttestation_e.SingleAttestation_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluSingleAttestation_e.SingleAttestation_valid(o), False{}, e) : {FuluSingleAttestation_e.SingleAttestation_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def ForkData_serialize_valid(+o: FuluForkData_d.ForkData, e: {FuluForkData_e.ForkData_valid(o) == True{} : Bool})
    -> {FuluForkData_e.ForkData_serialize(o) == O.encoded(FuluForkData_e.ForkData_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluForkData_e.ForkData_valid(o), True{}, e) : {FuluForkData_e.ForkData_ser_pick(_, o) == O.encoded(FuluForkData_e.ForkData_encode(o)) : O.Encoded}
  {==}
def ForkData_serialize_refused(+o: FuluForkData_d.ForkData, e: {FuluForkData_e.ForkData_valid(o) == False{} : Bool})
    -> {FuluForkData_e.ForkData_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluForkData_e.ForkData_valid(o), False{}, e) : {FuluForkData_e.ForkData_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def ForkDigest_serialize_valid(+o: FuluBytes4_d.Bytes4, e: {FuluBytes4_e.b4_valid(o) == True{} : Bool})
    -> {FuluForkDigest_e.ForkDigest_serialize(o) == O.encoded(FuluForkDigest_e.ForkDigest_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes4_e.b4_valid(o), True{}, e) : {FuluForkDigest_e.ForkDigest_ser_pick(_, o) == O.encoded(FuluForkDigest_e.ForkDigest_encode(o)) : O.Encoded}
  {==}
def ForkDigest_serialize_refused(+o: FuluBytes4_d.Bytes4, e: {FuluBytes4_e.b4_valid(o) == False{} : Bool})
    -> {FuluForkDigest_e.ForkDigest_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes4_e.b4_valid(o), False{}, e) : {FuluForkDigest_e.ForkDigest_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def Domain_serialize_valid(+o: FuluBytes32_d.Bytes32, e: {FuluBytes32_e.b32_valid(o) == True{} : Bool})
    -> {FuluDomain_e.Domain_serialize(o) == O.encoded(FuluDomain_e.Domain_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes32_e.b32_valid(o), True{}, e) : {FuluDomain_e.Domain_ser_pick(_, o) == O.encoded(FuluDomain_e.Domain_encode(o)) : O.Encoded}
  {==}
def Domain_serialize_refused(+o: FuluBytes32_d.Bytes32, e: {FuluBytes32_e.b32_valid(o) == False{} : Bool})
    -> {FuluDomain_e.Domain_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes32_e.b32_valid(o), False{}, e) : {FuluDomain_e.Domain_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def SigningData_serialize_valid(+o: FuluSigningData_d.SigningData, e: {FuluSigningData_e.SigningData_valid(o) == True{} : Bool})
    -> {FuluSigningData_e.SigningData_serialize(o) == O.encoded(FuluSigningData_e.SigningData_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluSigningData_e.SigningData_valid(o), True{}, e) : {FuluSigningData_e.SigningData_ser_pick(_, o) == O.encoded(FuluSigningData_e.SigningData_encode(o)) : O.Encoded}
  {==}
def SigningData_serialize_refused(+o: FuluSigningData_d.SigningData, e: {FuluSigningData_e.SigningData_valid(o) == False{} : Bool})
    -> {FuluSigningData_e.SigningData_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluSigningData_e.SigningData_valid(o), False{}, e) : {FuluSigningData_e.SigningData_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def BLSPubkey_serialize_valid(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == True{} : Bool})
    -> {FuluBLSPubkey_e.BLSPubkey_serialize(o) == O.encoded(FuluBLSPubkey_e.BLSPubkey_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes48_e.b48_valid(o), True{}, e) : {FuluBLSPubkey_e.BLSPubkey_ser_pick(_, o) == O.encoded(FuluBLSPubkey_e.BLSPubkey_encode(o)) : O.Encoded}
  {==}
def BLSPubkey_serialize_refused(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == False{} : Bool})
    -> {FuluBLSPubkey_e.BLSPubkey_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes48_e.b48_valid(o), False{}, e) : {FuluBLSPubkey_e.BLSPubkey_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def DepositRequest_serialize_valid(+o: FuluDepositRequest_d.DepositRequest, e: {FuluDepositRequest_e.DepositRequest_valid(o) == True{} : Bool})
    -> {FuluDepositRequest_e.DepositRequest_serialize(o) == O.encoded(FuluDepositRequest_e.DepositRequest_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluDepositRequest_e.DepositRequest_valid(o), True{}, e) : {FuluDepositRequest_e.DepositRequest_ser_pick(_, o) == O.encoded(FuluDepositRequest_e.DepositRequest_encode(o)) : O.Encoded}
  {==}
def DepositRequest_serialize_refused(+o: FuluDepositRequest_d.DepositRequest, e: {FuluDepositRequest_e.DepositRequest_valid(o) == False{} : Bool})
    -> {FuluDepositRequest_e.DepositRequest_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluDepositRequest_e.DepositRequest_valid(o), False{}, e) : {FuluDepositRequest_e.DepositRequest_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def PendingDeposit_serialize_valid(+o: FuluPendingDeposit_d.PendingDeposit, e: {FuluPendingDeposit_e.PendingDeposit_valid(o) == True{} : Bool})
    -> {FuluPendingDeposit_e.PendingDeposit_serialize(o) == O.encoded(FuluPendingDeposit_e.PendingDeposit_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluPendingDeposit_e.PendingDeposit_valid(o), True{}, e) : {FuluPendingDeposit_e.PendingDeposit_ser_pick(_, o) == O.encoded(FuluPendingDeposit_e.PendingDeposit_encode(o)) : O.Encoded}
  {==}
def PendingDeposit_serialize_refused(+o: FuluPendingDeposit_d.PendingDeposit, e: {FuluPendingDeposit_e.PendingDeposit_valid(o) == False{} : Bool})
    -> {FuluPendingDeposit_e.PendingDeposit_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluPendingDeposit_e.PendingDeposit_valid(o), False{}, e) : {FuluPendingDeposit_e.PendingDeposit_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def DepositData_serialize_valid(+o: FuluDepositData_d.DepositData, e: {FuluDepositData_e.DepositData_valid(o) == True{} : Bool})
    -> {FuluDepositData_e.DepositData_serialize(o) == O.encoded(FuluDepositData_e.DepositData_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluDepositData_e.DepositData_valid(o), True{}, e) : {FuluDepositData_e.DepositData_ser_pick(_, o) == O.encoded(FuluDepositData_e.DepositData_encode(o)) : O.Encoded}
  {==}
def DepositData_serialize_refused(+o: FuluDepositData_d.DepositData, e: {FuluDepositData_e.DepositData_valid(o) == False{} : Bool})
    -> {FuluDepositData_e.DepositData_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluDepositData_e.DepositData_valid(o), False{}, e) : {FuluDepositData_e.DepositData_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def DepositMessage_serialize_valid(+o: FuluDepositMessage_d.DepositMessage, e: {FuluDepositMessage_e.DepositMessage_valid(o) == True{} : Bool})
    -> {FuluDepositMessage_e.DepositMessage_serialize(o) == O.encoded(FuluDepositMessage_e.DepositMessage_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluDepositMessage_e.DepositMessage_valid(o), True{}, e) : {FuluDepositMessage_e.DepositMessage_ser_pick(_, o) == O.encoded(FuluDepositMessage_e.DepositMessage_encode(o)) : O.Encoded}
  {==}
def DepositMessage_serialize_refused(+o: FuluDepositMessage_d.DepositMessage, e: {FuluDepositMessage_e.DepositMessage_valid(o) == False{} : Bool})
    -> {FuluDepositMessage_e.DepositMessage_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluDepositMessage_e.DepositMessage_valid(o), False{}, e) : {FuluDepositMessage_e.DepositMessage_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def Validator_serialize_valid(+o: FuluValidator_d.Validator, e: {FuluValidator_e.Validator_valid(o) == True{} : Bool})
    -> {FuluValidator_e.Validator_serialize(o) == O.encoded(FuluValidator_e.Validator_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluValidator_e.Validator_valid(o), True{}, e) : {FuluValidator_e.Validator_ser_pick(_, o) == O.encoded(FuluValidator_e.Validator_encode(o)) : O.Encoded}
  {==}
def Validator_serialize_refused(+o: FuluValidator_d.Validator, e: {FuluValidator_e.Validator_valid(o) == False{} : Bool})
    -> {FuluValidator_e.Validator_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluValidator_e.Validator_valid(o), False{}, e) : {FuluValidator_e.Validator_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def NodeID_serialize_valid(+o: uint256_d.Uint256, e: {uint256_e.u256_valid(o) == True{} : Bool})
    -> {FuluNodeID_e.NodeID_serialize(o) == O.encoded(FuluNodeID_e.NodeID_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint256_e.u256_valid(o), True{}, e) : {FuluNodeID_e.NodeID_ser_pick(_, o) == O.encoded(FuluNodeID_e.NodeID_encode(o)) : O.Encoded}
  {==}
def NodeID_serialize_refused(+o: uint256_d.Uint256, e: {uint256_e.u256_valid(o) == False{} : Bool})
    -> {FuluNodeID_e.NodeID_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint256_e.u256_valid(o), False{}, e) : {FuluNodeID_e.NodeID_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def SubnetID_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluSubnetID_e.SubnetID_serialize(o) == O.encoded(FuluSubnetID_e.SubnetID_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluSubnetID_e.SubnetID_ser_pick(_, o) == O.encoded(FuluSubnetID_e.SubnetID_encode(o)) : O.Encoded}
  {==}
def SubnetID_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluSubnetID_e.SubnetID_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluSubnetID_e.SubnetID_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def Ether_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluEther_e.Ether_serialize(o) == O.encoded(FuluEther_e.Ether_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluEther_e.Ether_ser_pick(_, o) == O.encoded(FuluEther_e.Ether_encode(o)) : O.Encoded}
  {==}
def Ether_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluEther_e.Ether_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluEther_e.Ether_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def ParticipationFlags_serialize_valid(+o: U32, e: {uint8_e.u8_valid(o) == True{} : Bool})
    -> {FuluParticipationFlags_e.ParticipationFlags_serialize(o) == O.encoded(FuluParticipationFlags_e.ParticipationFlags_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint8_e.u8_valid(o), True{}, e) : {FuluParticipationFlags_e.ParticipationFlags_ser_pick(_, o) == O.encoded(FuluParticipationFlags_e.ParticipationFlags_encode(o)) : O.Encoded}
  {==}
def ParticipationFlags_serialize_refused(+o: U32, e: {uint8_e.u8_valid(o) == False{} : Bool})
    -> {FuluParticipationFlags_e.ParticipationFlags_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint8_e.u8_valid(o), False{}, e) : {FuluParticipationFlags_e.ParticipationFlags_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def ExecutionAddress_serialize_valid(+o: FuluBytes20_d.Bytes20, e: {FuluBytes20_e.b20_valid(o) == True{} : Bool})
    -> {FuluExecutionAddress_e.ExecutionAddress_serialize(o) == O.encoded(FuluExecutionAddress_e.ExecutionAddress_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes20_e.b20_valid(o), True{}, e) : {FuluExecutionAddress_e.ExecutionAddress_ser_pick(_, o) == O.encoded(FuluExecutionAddress_e.ExecutionAddress_encode(o)) : O.Encoded}
  {==}
def ExecutionAddress_serialize_refused(+o: FuluBytes20_d.Bytes20, e: {FuluBytes20_e.b20_valid(o) == False{} : Bool})
    -> {FuluExecutionAddress_e.ExecutionAddress_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes20_e.b20_valid(o), False{}, e) : {FuluExecutionAddress_e.ExecutionAddress_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def ConsolidationRequest_serialize_valid(+o: FuluConsolidationRequest_d.ConsolidationRequest, e: {FuluConsolidationRequest_e.ConsolidationRequest_valid(o) == True{} : Bool})
    -> {FuluConsolidationRequest_e.ConsolidationRequest_serialize(o) == O.encoded(FuluConsolidationRequest_e.ConsolidationRequest_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluConsolidationRequest_e.ConsolidationRequest_valid(o), True{}, e) : {FuluConsolidationRequest_e.ConsolidationRequest_ser_pick(_, o) == O.encoded(FuluConsolidationRequest_e.ConsolidationRequest_encode(o)) : O.Encoded}
  {==}
def ConsolidationRequest_serialize_refused(+o: FuluConsolidationRequest_d.ConsolidationRequest, e: {FuluConsolidationRequest_e.ConsolidationRequest_valid(o) == False{} : Bool})
    -> {FuluConsolidationRequest_e.ConsolidationRequest_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluConsolidationRequest_e.ConsolidationRequest_valid(o), False{}, e) : {FuluConsolidationRequest_e.ConsolidationRequest_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def WithdrawalRequest_serialize_valid(+o: FuluWithdrawalRequest_d.WithdrawalRequest, e: {FuluWithdrawalRequest_e.WithdrawalRequest_valid(o) == True{} : Bool})
    -> {FuluWithdrawalRequest_e.WithdrawalRequest_serialize(o) == O.encoded(FuluWithdrawalRequest_e.WithdrawalRequest_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluWithdrawalRequest_e.WithdrawalRequest_valid(o), True{}, e) : {FuluWithdrawalRequest_e.WithdrawalRequest_ser_pick(_, o) == O.encoded(FuluWithdrawalRequest_e.WithdrawalRequest_encode(o)) : O.Encoded}
  {==}
def WithdrawalRequest_serialize_refused(+o: FuluWithdrawalRequest_d.WithdrawalRequest, e: {FuluWithdrawalRequest_e.WithdrawalRequest_valid(o) == False{} : Bool})
    -> {FuluWithdrawalRequest_e.WithdrawalRequest_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluWithdrawalRequest_e.WithdrawalRequest_valid(o), False{}, e) : {FuluWithdrawalRequest_e.WithdrawalRequest_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def BLSToExecutionChange_serialize_valid(+o: FuluBLSToExecutionChange_d.BLSToExecutionChange, e: {FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o) == True{} : Bool})
    -> {FuluBLSToExecutionChange_e.BLSToExecutionChange_serialize(o) == O.encoded(FuluBLSToExecutionChange_e.BLSToExecutionChange_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o), True{}, e) : {FuluBLSToExecutionChange_e.BLSToExecutionChange_ser_pick(_, o) == O.encoded(FuluBLSToExecutionChange_e.BLSToExecutionChange_encode(o)) : O.Encoded}
  {==}
def BLSToExecutionChange_serialize_refused(+o: FuluBLSToExecutionChange_d.BLSToExecutionChange, e: {FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o) == False{} : Bool})
    -> {FuluBLSToExecutionChange_e.BLSToExecutionChange_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o), False{}, e) : {FuluBLSToExecutionChange_e.BLSToExecutionChange_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def SignedBLSToExecutionChange_serialize_valid(+o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, e: {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o) == True{} : Bool})
    -> {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_serialize(o) == O.encoded(FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o), True{}, e) : {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_ser_pick(_, o) == O.encoded(FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_encode(o)) : O.Encoded}
  {==}
def SignedBLSToExecutionChange_serialize_refused(+o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, e: {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o) == False{} : Bool})
    -> {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o), False{}, e) : {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def PayloadId_serialize_valid(+o: FuluBytes8_d.Bytes8, e: {FuluBytes8_e.b8_valid(o) == True{} : Bool})
    -> {FuluPayloadId_e.PayloadId_serialize(o) == O.encoded(FuluPayloadId_e.PayloadId_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes8_e.b8_valid(o), True{}, e) : {FuluPayloadId_e.PayloadId_ser_pick(_, o) == O.encoded(FuluPayloadId_e.PayloadId_encode(o)) : O.Encoded}
  {==}
def PayloadId_serialize_refused(+o: FuluBytes8_d.Bytes8, e: {FuluBytes8_e.b8_valid(o) == False{} : Bool})
    -> {FuluPayloadId_e.PayloadId_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes8_e.b8_valid(o), False{}, e) : {FuluPayloadId_e.PayloadId_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def WithdrawalIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluWithdrawalIndex_e.WithdrawalIndex_serialize(o) == O.encoded(FuluWithdrawalIndex_e.WithdrawalIndex_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluWithdrawalIndex_e.WithdrawalIndex_ser_pick(_, o) == O.encoded(FuluWithdrawalIndex_e.WithdrawalIndex_encode(o)) : O.Encoded}
  {==}
def WithdrawalIndex_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluWithdrawalIndex_e.WithdrawalIndex_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluWithdrawalIndex_e.WithdrawalIndex_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def Withdrawal_serialize_valid(+o: FuluWithdrawal_d.Withdrawal, e: {FuluWithdrawal_e.Withdrawal_valid(o) == True{} : Bool})
    -> {FuluWithdrawal_e.Withdrawal_serialize(o) == O.encoded(FuluWithdrawal_e.Withdrawal_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluWithdrawal_e.Withdrawal_valid(o), True{}, e) : {FuluWithdrawal_e.Withdrawal_ser_pick(_, o) == O.encoded(FuluWithdrawal_e.Withdrawal_encode(o)) : O.Encoded}
  {==}
def Withdrawal_serialize_refused(+o: FuluWithdrawal_d.Withdrawal, e: {FuluWithdrawal_e.Withdrawal_valid(o) == False{} : Bool})
    -> {FuluWithdrawal_e.Withdrawal_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluWithdrawal_e.Withdrawal_valid(o), False{}, e) : {FuluWithdrawal_e.Withdrawal_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def BlobIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluBlobIndex_e.BlobIndex_serialize(o) == O.encoded(FuluBlobIndex_e.BlobIndex_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluBlobIndex_e.BlobIndex_ser_pick(_, o) == O.encoded(FuluBlobIndex_e.BlobIndex_encode(o)) : O.Encoded}
  {==}
def BlobIndex_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluBlobIndex_e.BlobIndex_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluBlobIndex_e.BlobIndex_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def BlobIdentifier_serialize_valid(+o: FuluBlobIdentifier_d.BlobIdentifier, e: {FuluBlobIdentifier_e.BlobIdentifier_valid(o) == True{} : Bool})
    -> {FuluBlobIdentifier_e.BlobIdentifier_serialize(o) == O.encoded(FuluBlobIdentifier_e.BlobIdentifier_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBlobIdentifier_e.BlobIdentifier_valid(o), True{}, e) : {FuluBlobIdentifier_e.BlobIdentifier_ser_pick(_, o) == O.encoded(FuluBlobIdentifier_e.BlobIdentifier_encode(o)) : O.Encoded}
  {==}
def BlobIdentifier_serialize_refused(+o: FuluBlobIdentifier_d.BlobIdentifier, e: {FuluBlobIdentifier_e.BlobIdentifier_valid(o) == False{} : Bool})
    -> {FuluBlobIdentifier_e.BlobIdentifier_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBlobIdentifier_e.BlobIdentifier_valid(o), False{}, e) : {FuluBlobIdentifier_e.BlobIdentifier_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def KZGCommitment_serialize_valid(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == True{} : Bool})
    -> {FuluKZGCommitment_e.KZGCommitment_serialize(o) == O.encoded(FuluKZGCommitment_e.KZGCommitment_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes48_e.b48_valid(o), True{}, e) : {FuluKZGCommitment_e.KZGCommitment_ser_pick(_, o) == O.encoded(FuluKZGCommitment_e.KZGCommitment_encode(o)) : O.Encoded}
  {==}
def KZGCommitment_serialize_refused(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == False{} : Bool})
    -> {FuluKZGCommitment_e.KZGCommitment_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes48_e.b48_valid(o), False{}, e) : {FuluKZGCommitment_e.KZGCommitment_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def KZGProof_serialize_valid(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == True{} : Bool})
    -> {FuluKZGProof_e.KZGProof_serialize(o) == O.encoded(FuluKZGProof_e.KZGProof_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, FuluBytes48_e.b48_valid(o), True{}, e) : {FuluKZGProof_e.KZGProof_ser_pick(_, o) == O.encoded(FuluKZGProof_e.KZGProof_encode(o)) : O.Encoded}
  {==}
def KZGProof_serialize_refused(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == False{} : Bool})
    -> {FuluKZGProof_e.KZGProof_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, FuluBytes48_e.b48_valid(o), False{}, e) : {FuluKZGProof_e.KZGProof_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def CellIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluCellIndex_e.CellIndex_serialize(o) == O.encoded(FuluCellIndex_e.CellIndex_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluCellIndex_e.CellIndex_ser_pick(_, o) == O.encoded(FuluCellIndex_e.CellIndex_encode(o)) : O.Encoded}
  {==}
def CellIndex_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluCellIndex_e.CellIndex_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluCellIndex_e.CellIndex_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def CommitmentIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluCommitmentIndex_e.CommitmentIndex_serialize(o) == O.encoded(FuluCommitmentIndex_e.CommitmentIndex_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluCommitmentIndex_e.CommitmentIndex_ser_pick(_, o) == O.encoded(FuluCommitmentIndex_e.CommitmentIndex_encode(o)) : O.Encoded}
  {==}
def CommitmentIndex_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluCommitmentIndex_e.CommitmentIndex_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluCommitmentIndex_e.CommitmentIndex_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
def RowIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool})
    -> {FuluRowIndex_e.RowIndex_serialize(o) == O.encoded(FuluRowIndex_e.RowIndex_encode(o)) : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), True{}, e) : {FuluRowIndex_e.RowIndex_ser_pick(_, o) == O.encoded(FuluRowIndex_e.RowIndex_encode(o)) : O.Encoded}
  {==}
def RowIndex_serialize_refused(+o: O.U64, e: {uint64_e.u64_valid(o) == False{} : Bool})
    -> {FuluRowIndex_e.RowIndex_serialize(o) == O.refused() : O.Encoded}:
  %Equal.sym(Bool, uint64_e.u64_valid(o), False{}, e) : {FuluRowIndex_e.RowIndex_ser_pick(_, o) == O.refused() : O.Encoded}
  {==}
