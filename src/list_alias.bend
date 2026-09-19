import Base
import ../types/list_alias.bend as A
import ./byte_list.bend as I

def valid(alias: A.ByteListAlias, xs: +List<U32>) -> Bool: I.valid(A.capacity(alias), xs)
def serialize(alias: A.ByteListAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: I.serialize(A.capacity(alias), xs)
def deserialize(alias: A.ByteListAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: I.deserialize(A.capacity(alias), xs)
def hash_tree_root(alias: A.ByteListAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: I.hash_tree_root(A.capacity(alias), xs)
