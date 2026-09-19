import Base

# Closed identities and exact frozen mainnet lengths, shared representation metadata.
type ByteAlias is Data:
  Bytes1{}
  Bytes4{}
  Bytes32{}
  Bytes48{}
  Bytes96{}
  Bytes8{}
  Bytes20{}
  Hash32{}
  Version{}
  DomainType{}
  BLSSignature{}
  VersionedHash{}
  G1Point{}
  G2Point{}
  Root{}
  ForkDigest{}
  Domain{}
  BLSPubkey{}
  ExecutionAddress{}
  PayloadId{}
  KZGCommitment{}
  KZGProof{}
  Blob{}
  Cell{}

def size(alias: ByteAlias) -> Nat:
  match alias:
    case Bytes1{}: 1n
    case Bytes4{}: 4n
    case Bytes32{}: 32n
    case Bytes48{}: 48n
    case Bytes96{}: 96n
    case Bytes8{}: 8n
    case Bytes20{}: 20n
    case Hash32{}: 32n
    case Version{}: 4n
    case DomainType{}: 4n
    case BLSSignature{}: 96n
    case VersionedHash{}: 32n
    case G1Point{}: 48n
    case G2Point{}: 96n
    case Root{}: 32n
    case ForkDigest{}: 4n
    case Domain{}: 32n
    case BLSPubkey{}: 48n
    case ExecutionAddress{}: 20n
    case PayloadId{}: 8n
    case KZGCommitment{}: 48n
    case KZGProof{}: 48n
    case Blob{}: Nat.mul(128n, 1024n)
    case Cell{}: Nat.mul(2n, 1024n)
