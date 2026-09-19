import Base
import ../types/list_alias.bend as A
import ./byte_list.bend as S

def domain(alias: A.ByteListAlias, xs: +List<U32>) -> Bool: S.domain(A.capacity(alias), xs)
def encoding(alias: A.ByteListAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: S.encoding(A.capacity(alias), xs)
def decoding(alias: A.ByteListAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: S.decoding(A.capacity(alias), xs)
def root_at_depth(alias: A.ByteListAlias, depth: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>: S.at_depth(A.capacity(alias), depth, xs)
