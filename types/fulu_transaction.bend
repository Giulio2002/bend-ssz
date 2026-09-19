import Base
import ../src/list_alias.bend as I
import ../types/list_alias.bend as A

# schemas/fulu_mainnet.json: Transaction = ByteList[1073741824].
# Values use raw byte lists; all public operations enforce the domain.
def Transaction() -> Data: +List<U32>
def Transaction.capacity() -> Nat: A.capacity(A.Transaction{})
def Transaction.valid(xs: Transaction()) -> Bool: I.valid(A.Transaction{}, xs)
def Transaction.serialize(xs: Transaction()) -> Maybe<&2, +List<U32>>: I.serialize(A.Transaction{}, xs)
def Transaction.deserialize(xs: +List<U32>) -> Maybe<&2, Transaction()>: I.deserialize(A.Transaction{}, xs)
def Transaction.hash_tree_root(xs: Transaction()) -> Maybe<&2, +List<U32>>: I.hash_tree_root(A.Transaction{}, xs)
