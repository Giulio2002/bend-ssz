import Base
import ../types/byte_alias.bend as A
import ./bytes.bend as B
import ./byte_root.bend as Root

# A supplies only closed identities and frozen preset constants, no codec rules.
def domain(alias: A.ByteAlias, xs: +List<U32>) -> Bool: B.vector_domain(A.size(alias), xs)
def encoding(alias: A.ByteAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: B.vector_encoding(A.size(alias), xs)
def decoding(alias: A.ByteAlias, xs: +List<U32>) -> Maybe<&2, +List<U32>>: B.vector_decoding(A.size(alias), xs)
def root_at_depth(alias: A.ByteAlias, depth: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>: Root.at_depth(A.size(alias), depth, xs)
