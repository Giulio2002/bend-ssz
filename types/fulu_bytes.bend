import Base
import ../types/byte_alias.bend as A
import ../src/byte_alias.bend as I


# Frozen SSZ Vector[byte, 1]. Root uses canonical packed-byte Merkleization.
def Bytes1() -> Data: +List<U32>
def Bytes1.tag() -> A.ByteAlias: A.Bytes1{}
def Bytes1.length() -> Nat: A.size(Bytes1.tag())
def Bytes1.valid(+xs: Bytes1()) -> Bool: I.valid(Bytes1.tag(), xs)
def Bytes1.serialize(+xs: Bytes1()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes1.tag(), xs)
def Bytes1.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes1()>: I.deserialize(Bytes1.tag(), xs)
def Bytes1.hash_tree_root(+xs: Bytes1()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes1.tag(), xs)


# Frozen SSZ Vector[byte, 4]. Root uses canonical packed-byte Merkleization.
def Bytes4() -> Data: +List<U32>
def Bytes4.tag() -> A.ByteAlias: A.Bytes4{}
def Bytes4.length() -> Nat: A.size(Bytes4.tag())
def Bytes4.valid(+xs: Bytes4()) -> Bool: I.valid(Bytes4.tag(), xs)
def Bytes4.serialize(+xs: Bytes4()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes4.tag(), xs)
def Bytes4.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes4()>: I.deserialize(Bytes4.tag(), xs)
def Bytes4.hash_tree_root(+xs: Bytes4()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes4.tag(), xs)


# Frozen SSZ Vector[byte, 32]. Root uses canonical packed-byte Merkleization.
def Bytes32() -> Data: +List<U32>
def Bytes32.tag() -> A.ByteAlias: A.Bytes32{}
def Bytes32.length() -> Nat: A.size(Bytes32.tag())
def Bytes32.valid(+xs: Bytes32()) -> Bool: I.valid(Bytes32.tag(), xs)
def Bytes32.serialize(+xs: Bytes32()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes32.tag(), xs)
def Bytes32.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes32()>: I.deserialize(Bytes32.tag(), xs)
def Bytes32.hash_tree_root(+xs: Bytes32()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes32.tag(), xs)


# Frozen SSZ Vector[byte, 48]. Root uses canonical packed-byte Merkleization.
def Bytes48() -> Data: +List<U32>
def Bytes48.tag() -> A.ByteAlias: A.Bytes48{}
def Bytes48.length() -> Nat: A.size(Bytes48.tag())
def Bytes48.valid(+xs: Bytes48()) -> Bool: I.valid(Bytes48.tag(), xs)
def Bytes48.serialize(+xs: Bytes48()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes48.tag(), xs)
def Bytes48.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes48()>: I.deserialize(Bytes48.tag(), xs)
def Bytes48.hash_tree_root(+xs: Bytes48()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes48.tag(), xs)


# Frozen SSZ Vector[byte, 96]. Root uses canonical packed-byte Merkleization.
def Bytes96() -> Data: +List<U32>
def Bytes96.tag() -> A.ByteAlias: A.Bytes96{}
def Bytes96.length() -> Nat: A.size(Bytes96.tag())
def Bytes96.valid(+xs: Bytes96()) -> Bool: I.valid(Bytes96.tag(), xs)
def Bytes96.serialize(+xs: Bytes96()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes96.tag(), xs)
def Bytes96.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes96()>: I.deserialize(Bytes96.tag(), xs)
def Bytes96.hash_tree_root(+xs: Bytes96()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes96.tag(), xs)


# Frozen SSZ Vector[byte, 8]. Root uses canonical packed-byte Merkleization.
def Bytes8() -> Data: +List<U32>
def Bytes8.tag() -> A.ByteAlias: A.Bytes8{}
def Bytes8.length() -> Nat: A.size(Bytes8.tag())
def Bytes8.valid(+xs: Bytes8()) -> Bool: I.valid(Bytes8.tag(), xs)
def Bytes8.serialize(+xs: Bytes8()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes8.tag(), xs)
def Bytes8.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes8()>: I.deserialize(Bytes8.tag(), xs)
def Bytes8.hash_tree_root(+xs: Bytes8()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes8.tag(), xs)


# Frozen SSZ Vector[byte, 20]. Root uses canonical packed-byte Merkleization.
def Bytes20() -> Data: +List<U32>
def Bytes20.tag() -> A.ByteAlias: A.Bytes20{}
def Bytes20.length() -> Nat: A.size(Bytes20.tag())
def Bytes20.valid(+xs: Bytes20()) -> Bool: I.valid(Bytes20.tag(), xs)
def Bytes20.serialize(+xs: Bytes20()) -> Maybe<&2, +List<U32>>: I.serialize(Bytes20.tag(), xs)
def Bytes20.deserialize(+xs: +List<U32>) -> Maybe<&2, Bytes20()>: I.deserialize(Bytes20.tag(), xs)
def Bytes20.hash_tree_root(+xs: Bytes20()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Bytes20.tag(), xs)


# Frozen SSZ Vector[byte, 32]. Root uses canonical packed-byte Merkleization.
def Hash32() -> Data: +List<U32>
def Hash32.tag() -> A.ByteAlias: A.Hash32{}
def Hash32.length() -> Nat: A.size(Hash32.tag())
def Hash32.valid(+xs: Hash32()) -> Bool: I.valid(Hash32.tag(), xs)
def Hash32.serialize(+xs: Hash32()) -> Maybe<&2, +List<U32>>: I.serialize(Hash32.tag(), xs)
def Hash32.deserialize(+xs: +List<U32>) -> Maybe<&2, Hash32()>: I.deserialize(Hash32.tag(), xs)
def Hash32.hash_tree_root(+xs: Hash32()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Hash32.tag(), xs)


# Frozen SSZ Vector[byte, 4]. Root uses canonical packed-byte Merkleization.
def Version() -> Data: +List<U32>
def Version.tag() -> A.ByteAlias: A.Version{}
def Version.length() -> Nat: A.size(Version.tag())
def Version.valid(+xs: Version()) -> Bool: I.valid(Version.tag(), xs)
def Version.serialize(+xs: Version()) -> Maybe<&2, +List<U32>>: I.serialize(Version.tag(), xs)
def Version.deserialize(+xs: +List<U32>) -> Maybe<&2, Version()>: I.deserialize(Version.tag(), xs)
def Version.hash_tree_root(+xs: Version()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Version.tag(), xs)


# Frozen SSZ Vector[byte, 4]. Root uses canonical packed-byte Merkleization.
def DomainType() -> Data: +List<U32>
def DomainType.tag() -> A.ByteAlias: A.DomainType{}
def DomainType.length() -> Nat: A.size(DomainType.tag())
def DomainType.valid(+xs: DomainType()) -> Bool: I.valid(DomainType.tag(), xs)
def DomainType.serialize(+xs: DomainType()) -> Maybe<&2, +List<U32>>: I.serialize(DomainType.tag(), xs)
def DomainType.deserialize(+xs: +List<U32>) -> Maybe<&2, DomainType()>: I.deserialize(DomainType.tag(), xs)
def DomainType.hash_tree_root(+xs: DomainType()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(DomainType.tag(), xs)


# Frozen SSZ Vector[byte, 96]. Root uses canonical packed-byte Merkleization.
def BLSSignature() -> Data: +List<U32>
def BLSSignature.tag() -> A.ByteAlias: A.BLSSignature{}
def BLSSignature.length() -> Nat: A.size(BLSSignature.tag())
def BLSSignature.valid(+xs: BLSSignature()) -> Bool: I.valid(BLSSignature.tag(), xs)
def BLSSignature.serialize(+xs: BLSSignature()) -> Maybe<&2, +List<U32>>: I.serialize(BLSSignature.tag(), xs)
def BLSSignature.deserialize(+xs: +List<U32>) -> Maybe<&2, BLSSignature()>: I.deserialize(BLSSignature.tag(), xs)
def BLSSignature.hash_tree_root(+xs: BLSSignature()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(BLSSignature.tag(), xs)


# Frozen SSZ Vector[byte, 32]. Root uses canonical packed-byte Merkleization.
def VersionedHash() -> Data: +List<U32>
def VersionedHash.tag() -> A.ByteAlias: A.VersionedHash{}
def VersionedHash.length() -> Nat: A.size(VersionedHash.tag())
def VersionedHash.valid(+xs: VersionedHash()) -> Bool: I.valid(VersionedHash.tag(), xs)
def VersionedHash.serialize(+xs: VersionedHash()) -> Maybe<&2, +List<U32>>: I.serialize(VersionedHash.tag(), xs)
def VersionedHash.deserialize(+xs: +List<U32>) -> Maybe<&2, VersionedHash()>: I.deserialize(VersionedHash.tag(), xs)
def VersionedHash.hash_tree_root(+xs: VersionedHash()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(VersionedHash.tag(), xs)


# Frozen SSZ Vector[byte, 48]. Root uses canonical packed-byte Merkleization.
def G1Point() -> Data: +List<U32>
def G1Point.tag() -> A.ByteAlias: A.G1Point{}
def G1Point.length() -> Nat: A.size(G1Point.tag())
def G1Point.valid(+xs: G1Point()) -> Bool: I.valid(G1Point.tag(), xs)
def G1Point.serialize(+xs: G1Point()) -> Maybe<&2, +List<U32>>: I.serialize(G1Point.tag(), xs)
def G1Point.deserialize(+xs: +List<U32>) -> Maybe<&2, G1Point()>: I.deserialize(G1Point.tag(), xs)
def G1Point.hash_tree_root(+xs: G1Point()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(G1Point.tag(), xs)


# Frozen SSZ Vector[byte, 96]. Root uses canonical packed-byte Merkleization.
def G2Point() -> Data: +List<U32>
def G2Point.tag() -> A.ByteAlias: A.G2Point{}
def G2Point.length() -> Nat: A.size(G2Point.tag())
def G2Point.valid(+xs: G2Point()) -> Bool: I.valid(G2Point.tag(), xs)
def G2Point.serialize(+xs: G2Point()) -> Maybe<&2, +List<U32>>: I.serialize(G2Point.tag(), xs)
def G2Point.deserialize(+xs: +List<U32>) -> Maybe<&2, G2Point()>: I.deserialize(G2Point.tag(), xs)
def G2Point.hash_tree_root(+xs: G2Point()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(G2Point.tag(), xs)


# Frozen SSZ Vector[byte, 32]. Root uses canonical packed-byte Merkleization.
def Root() -> Data: +List<U32>
def Root.tag() -> A.ByteAlias: A.Root{}
def Root.length() -> Nat: A.size(Root.tag())
def Root.valid(+xs: Root()) -> Bool: I.valid(Root.tag(), xs)
def Root.serialize(+xs: Root()) -> Maybe<&2, +List<U32>>: I.serialize(Root.tag(), xs)
def Root.deserialize(+xs: +List<U32>) -> Maybe<&2, Root()>: I.deserialize(Root.tag(), xs)
def Root.hash_tree_root(+xs: Root()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Root.tag(), xs)


# Frozen SSZ Vector[byte, 4]. Root uses canonical packed-byte Merkleization.
def ForkDigest() -> Data: +List<U32>
def ForkDigest.tag() -> A.ByteAlias: A.ForkDigest{}
def ForkDigest.length() -> Nat: A.size(ForkDigest.tag())
def ForkDigest.valid(+xs: ForkDigest()) -> Bool: I.valid(ForkDigest.tag(), xs)
def ForkDigest.serialize(+xs: ForkDigest()) -> Maybe<&2, +List<U32>>: I.serialize(ForkDigest.tag(), xs)
def ForkDigest.deserialize(+xs: +List<U32>) -> Maybe<&2, ForkDigest()>: I.deserialize(ForkDigest.tag(), xs)
def ForkDigest.hash_tree_root(+xs: ForkDigest()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(ForkDigest.tag(), xs)


# Frozen SSZ Vector[byte, 32]. Root uses canonical packed-byte Merkleization.
def Domain() -> Data: +List<U32>
def Domain.tag() -> A.ByteAlias: A.Domain{}
def Domain.length() -> Nat: A.size(Domain.tag())
def Domain.valid(+xs: Domain()) -> Bool: I.valid(Domain.tag(), xs)
def Domain.serialize(+xs: Domain()) -> Maybe<&2, +List<U32>>: I.serialize(Domain.tag(), xs)
def Domain.deserialize(+xs: +List<U32>) -> Maybe<&2, Domain()>: I.deserialize(Domain.tag(), xs)
def Domain.hash_tree_root(+xs: Domain()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Domain.tag(), xs)


# Frozen SSZ Vector[byte, 48]. Root uses canonical packed-byte Merkleization.
def BLSPubkey() -> Data: +List<U32>
def BLSPubkey.tag() -> A.ByteAlias: A.BLSPubkey{}
def BLSPubkey.length() -> Nat: A.size(BLSPubkey.tag())
def BLSPubkey.valid(+xs: BLSPubkey()) -> Bool: I.valid(BLSPubkey.tag(), xs)
def BLSPubkey.serialize(+xs: BLSPubkey()) -> Maybe<&2, +List<U32>>: I.serialize(BLSPubkey.tag(), xs)
def BLSPubkey.deserialize(+xs: +List<U32>) -> Maybe<&2, BLSPubkey()>: I.deserialize(BLSPubkey.tag(), xs)
def BLSPubkey.hash_tree_root(+xs: BLSPubkey()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(BLSPubkey.tag(), xs)


# Frozen SSZ Vector[byte, 20]. Root uses canonical packed-byte Merkleization.
def ExecutionAddress() -> Data: +List<U32>
def ExecutionAddress.tag() -> A.ByteAlias: A.ExecutionAddress{}
def ExecutionAddress.length() -> Nat: A.size(ExecutionAddress.tag())
def ExecutionAddress.valid(+xs: ExecutionAddress()) -> Bool: I.valid(ExecutionAddress.tag(), xs)
def ExecutionAddress.serialize(+xs: ExecutionAddress()) -> Maybe<&2, +List<U32>>: I.serialize(ExecutionAddress.tag(), xs)
def ExecutionAddress.deserialize(+xs: +List<U32>) -> Maybe<&2, ExecutionAddress()>: I.deserialize(ExecutionAddress.tag(), xs)
def ExecutionAddress.hash_tree_root(+xs: ExecutionAddress()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(ExecutionAddress.tag(), xs)


# Frozen SSZ Vector[byte, 8]. Root uses canonical packed-byte Merkleization.
def PayloadId() -> Data: +List<U32>
def PayloadId.tag() -> A.ByteAlias: A.PayloadId{}
def PayloadId.length() -> Nat: A.size(PayloadId.tag())
def PayloadId.valid(+xs: PayloadId()) -> Bool: I.valid(PayloadId.tag(), xs)
def PayloadId.serialize(+xs: PayloadId()) -> Maybe<&2, +List<U32>>: I.serialize(PayloadId.tag(), xs)
def PayloadId.deserialize(+xs: +List<U32>) -> Maybe<&2, PayloadId()>: I.deserialize(PayloadId.tag(), xs)
def PayloadId.hash_tree_root(+xs: PayloadId()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(PayloadId.tag(), xs)


# Frozen SSZ Vector[byte, 48]. Root uses canonical packed-byte Merkleization.
def KZGCommitment() -> Data: +List<U32>
def KZGCommitment.tag() -> A.ByteAlias: A.KZGCommitment{}
def KZGCommitment.length() -> Nat: A.size(KZGCommitment.tag())
def KZGCommitment.valid(+xs: KZGCommitment()) -> Bool: I.valid(KZGCommitment.tag(), xs)
def KZGCommitment.serialize(+xs: KZGCommitment()) -> Maybe<&2, +List<U32>>: I.serialize(KZGCommitment.tag(), xs)
def KZGCommitment.deserialize(+xs: +List<U32>) -> Maybe<&2, KZGCommitment()>: I.deserialize(KZGCommitment.tag(), xs)
def KZGCommitment.hash_tree_root(+xs: KZGCommitment()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(KZGCommitment.tag(), xs)


# Frozen SSZ Vector[byte, 48]. Root uses canonical packed-byte Merkleization.
def KZGProof() -> Data: +List<U32>
def KZGProof.tag() -> A.ByteAlias: A.KZGProof{}
def KZGProof.length() -> Nat: A.size(KZGProof.tag())
def KZGProof.valid(+xs: KZGProof()) -> Bool: I.valid(KZGProof.tag(), xs)
def KZGProof.serialize(+xs: KZGProof()) -> Maybe<&2, +List<U32>>: I.serialize(KZGProof.tag(), xs)
def KZGProof.deserialize(+xs: +List<U32>) -> Maybe<&2, KZGProof()>: I.deserialize(KZGProof.tag(), xs)
def KZGProof.hash_tree_root(+xs: KZGProof()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(KZGProof.tag(), xs)


# Frozen SSZ Vector[byte, 131072]. Root uses canonical packed-byte Merkleization.
def Blob() -> Data: +List<U32>
def Blob.tag() -> A.ByteAlias: A.Blob{}
def Blob.length() -> Nat: A.size(Blob.tag())
def Blob.valid(+xs: Blob()) -> Bool: I.valid(Blob.tag(), xs)
def Blob.serialize(+xs: Blob()) -> Maybe<&2, +List<U32>>: I.serialize(Blob.tag(), xs)
def Blob.deserialize(+xs: +List<U32>) -> Maybe<&2, Blob()>: I.deserialize(Blob.tag(), xs)
def Blob.hash_tree_root(+xs: Blob()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Blob.tag(), xs)


# Frozen SSZ Vector[byte, 2048]. Root uses canonical packed-byte Merkleization.
def Cell() -> Data: +List<U32>
def Cell.tag() -> A.ByteAlias: A.Cell{}
def Cell.length() -> Nat: A.size(Cell.tag())
def Cell.valid(+xs: Cell()) -> Bool: I.valid(Cell.tag(), xs)
def Cell.serialize(+xs: Cell()) -> Maybe<&2, +List<U32>>: I.serialize(Cell.tag(), xs)
def Cell.deserialize(+xs: +List<U32>) -> Maybe<&2, Cell()>: I.deserialize(Cell.tag(), xs)
def Cell.hash_tree_root(+xs: Cell()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(Cell.tag(), xs)
