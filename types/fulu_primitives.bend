import Base
import ../types/primitive.bend as T
import ../src/primitives.bend as P

# Named value aliases with checked-at-runtime range validation on serialization.

def boolean() -> Data:
  Bool
def boolean.serialize(v: Bool) -> +List<U32>:
  P.boolean_serialize(v)
def boolean.deserialize(xs: +List<U32>) -> Maybe<&2, Bool>:
  P.boolean_deserialize(xs)
def boolean.hash_tree_root(v: Bool) -> +List<U32>:
  P.boolean_root(v)

def uint8() -> Data:
  T.UInt
def uint8.valid(v: uint8()) -> Bool:
  P.uint_valid(T.U8{}, v)
def uint8.serialize(v: uint8()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U8{}, v)
def uint8.deserialize(xs: +List<U32>) -> Maybe<&2, uint8()>:
  P.uint_deserialize(T.U8{}, xs)
def uint8.hash_tree_root(v: uint8()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U8{}, v)

def uint32() -> Data:
  T.UInt
def uint32.valid(v: uint32()) -> Bool:
  P.uint_valid(T.U32Width{}, v)
def uint32.serialize(v: uint32()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U32Width{}, v)
def uint32.deserialize(xs: +List<U32>) -> Maybe<&2, uint32()>:
  P.uint_deserialize(T.U32Width{}, xs)
def uint32.hash_tree_root(v: uint32()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U32Width{}, v)

def uint64() -> Data:
  T.UInt
def uint64.valid(v: uint64()) -> Bool:
  P.uint_valid(T.U64{}, v)
def uint64.serialize(v: uint64()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def uint64.deserialize(xs: +List<U32>) -> Maybe<&2, uint64()>:
  P.uint_deserialize(T.U64{}, xs)
def uint64.hash_tree_root(v: uint64()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def uint256() -> Data:
  T.UInt
def uint256.valid(v: uint256()) -> Bool:
  P.uint_valid(T.U256{}, v)
def uint256.serialize(v: uint256()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U256{}, v)
def uint256.deserialize(xs: +List<U32>) -> Maybe<&2, uint256()>:
  P.uint_deserialize(T.U256{}, xs)
def uint256.hash_tree_root(v: uint256()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U256{}, v)

def Slot() -> Data:
  T.UInt
def Slot.valid(v: Slot()) -> Bool:
  P.uint_valid(T.U64{}, v)
def Slot.serialize(v: Slot()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def Slot.deserialize(xs: +List<U32>) -> Maybe<&2, Slot()>:
  P.uint_deserialize(T.U64{}, xs)
def Slot.hash_tree_root(v: Slot()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def Epoch() -> Data:
  T.UInt
def Epoch.valid(v: Epoch()) -> Bool:
  P.uint_valid(T.U64{}, v)
def Epoch.serialize(v: Epoch()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def Epoch.deserialize(xs: +List<U32>) -> Maybe<&2, Epoch()>:
  P.uint_deserialize(T.U64{}, xs)
def Epoch.hash_tree_root(v: Epoch()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def Gwei() -> Data:
  T.UInt
def Gwei.valid(v: Gwei()) -> Bool:
  P.uint_valid(T.U64{}, v)
def Gwei.serialize(v: Gwei()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def Gwei.deserialize(xs: +List<U32>) -> Maybe<&2, Gwei()>:
  P.uint_deserialize(T.U64{}, xs)
def Gwei.hash_tree_root(v: Gwei()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def CommitteeIndex() -> Data:
  T.UInt
def CommitteeIndex.valid(v: CommitteeIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def CommitteeIndex.serialize(v: CommitteeIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def CommitteeIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CommitteeIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def CommitteeIndex.hash_tree_root(v: CommitteeIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def ValidatorIndex() -> Data:
  T.UInt
def ValidatorIndex.valid(v: ValidatorIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def ValidatorIndex.serialize(v: ValidatorIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def ValidatorIndex.deserialize(xs: +List<U32>) -> Maybe<&2, ValidatorIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def ValidatorIndex.hash_tree_root(v: ValidatorIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def NodeID() -> Data:
  T.UInt
def NodeID.valid(v: NodeID()) -> Bool:
  P.uint_valid(T.U256{}, v)
def NodeID.serialize(v: NodeID()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U256{}, v)
def NodeID.deserialize(xs: +List<U32>) -> Maybe<&2, NodeID()>:
  P.uint_deserialize(T.U256{}, xs)
def NodeID.hash_tree_root(v: NodeID()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U256{}, v)

def SubnetID() -> Data:
  T.UInt
def SubnetID.valid(v: SubnetID()) -> Bool:
  P.uint_valid(T.U64{}, v)
def SubnetID.serialize(v: SubnetID()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def SubnetID.deserialize(xs: +List<U32>) -> Maybe<&2, SubnetID()>:
  P.uint_deserialize(T.U64{}, xs)
def SubnetID.hash_tree_root(v: SubnetID()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def Ether() -> Data:
  T.UInt
def Ether.valid(v: Ether()) -> Bool:
  P.uint_valid(T.U64{}, v)
def Ether.serialize(v: Ether()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def Ether.deserialize(xs: +List<U32>) -> Maybe<&2, Ether()>:
  P.uint_deserialize(T.U64{}, xs)
def Ether.hash_tree_root(v: Ether()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def ParticipationFlags() -> Data:
  T.UInt
def ParticipationFlags.valid(v: ParticipationFlags()) -> Bool:
  P.uint_valid(T.U8{}, v)
def ParticipationFlags.serialize(v: ParticipationFlags()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U8{}, v)
def ParticipationFlags.deserialize(xs: +List<U32>) -> Maybe<&2, ParticipationFlags()>:
  P.uint_deserialize(T.U8{}, xs)
def ParticipationFlags.hash_tree_root(v: ParticipationFlags()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U8{}, v)

def WithdrawalIndex() -> Data:
  T.UInt
def WithdrawalIndex.valid(v: WithdrawalIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def WithdrawalIndex.serialize(v: WithdrawalIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def WithdrawalIndex.deserialize(xs: +List<U32>) -> Maybe<&2, WithdrawalIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def WithdrawalIndex.hash_tree_root(v: WithdrawalIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def BlobIndex() -> Data:
  T.UInt
def BlobIndex.valid(v: BlobIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def BlobIndex.serialize(v: BlobIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def BlobIndex.deserialize(xs: +List<U32>) -> Maybe<&2, BlobIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def BlobIndex.hash_tree_root(v: BlobIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def CellIndex() -> Data:
  T.UInt
def CellIndex.valid(v: CellIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def CellIndex.serialize(v: CellIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def CellIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CellIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def CellIndex.hash_tree_root(v: CellIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def CommitmentIndex() -> Data:
  T.UInt
def CommitmentIndex.valid(v: CommitmentIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def CommitmentIndex.serialize(v: CommitmentIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def CommitmentIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CommitmentIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def CommitmentIndex.hash_tree_root(v: CommitmentIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def RowIndex() -> Data:
  T.UInt
def RowIndex.valid(v: RowIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def RowIndex.serialize(v: RowIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def RowIndex.deserialize(xs: +List<U32>) -> Maybe<&2, RowIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def RowIndex.hash_tree_root(v: RowIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def ColumnIndex() -> Data:
  T.UInt
def ColumnIndex.valid(v: ColumnIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def ColumnIndex.serialize(v: ColumnIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def ColumnIndex.deserialize(xs: +List<U32>) -> Maybe<&2, ColumnIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def ColumnIndex.hash_tree_root(v: ColumnIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def CustodyIndex() -> Data:
  T.UInt
def CustodyIndex.valid(v: CustodyIndex()) -> Bool:
  P.uint_valid(T.U64{}, v)
def CustodyIndex.serialize(v: CustodyIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U64{}, v)
def CustodyIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CustodyIndex()>:
  P.uint_deserialize(T.U64{}, xs)
def CustodyIndex.hash_tree_root(v: CustodyIndex()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U64{}, v)

def uint16() -> Data:
  T.UInt
def uint16.valid(v: uint16()) -> Bool:
  P.uint_valid(T.U16{}, v)
def uint16.serialize(v: uint16()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U16{}, v)
def uint16.deserialize(xs: +List<U32>) -> Maybe<&2, uint16()>:
  P.uint_deserialize(T.U16{}, xs)
def uint16.hash_tree_root(v: uint16()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U16{}, v)

def uint128() -> Data:
  T.UInt
def uint128.valid(v: uint128()) -> Bool:
  P.uint_valid(T.U128{}, v)
def uint128.serialize(v: uint128()) -> Maybe<&2, +List<U32>>:
  P.uint_serialize(T.U128{}, v)
def uint128.deserialize(xs: +List<U32>) -> Maybe<&2, uint128()>:
  P.uint_deserialize(T.U128{}, xs)
def uint128.hash_tree_root(v: uint128()) -> Maybe<&2, +List<U32>>:
  P.uint_root(T.U128{}, v)
