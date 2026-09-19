import Base
import ../types/byte_alias.bend as A
import ./bytes.bend as B
import ./byte_root.bend as Root

# Every named byte wrapper delegates to this closed inventory API.
def valid(alias: A.ByteAlias, xs: +List<U32>) -> Bool: B.vector_valid(A.size(alias), xs)
def serialize(alias: A.ByteAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: B.vector_serialize(A.size(alias), xs)
def deserialize(alias: A.ByteAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: B.vector_deserialize(A.size(alias), xs)
def hash_tree_root(alias: A.ByteAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: Root.hash_tree_root(A.size(alias), xs)
