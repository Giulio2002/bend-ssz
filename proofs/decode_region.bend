import Base
import ../src/packed.bend as P
import ./packed.bend as PK

# The list entry point's region facts (from decode_top.bend), with only the packed
# representation in their import closure: decode_image needs these three, and
# decode_top imports codec_composition (and through byte_list the SHA-256
# conformance proofs) for its later laws.

# The region the list entry point opens is exactly the input.
law region_is_input:
  for +xs: +List<U32>
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +len: {n == List.length(&2, U32, xs) : Nat}
  for +bytes: {List.take(&2, U32, P.chunks_bytes(chunks), List.length(&2, U32, xs)) == xs : +List<U32>}
  {P.slice_bytes(P.Slice{chunks, 0n, n}) == xs : +List<U32>}
def region_is_input(xs, n, chunks, len, bytes):
  %Equal.sym(+List<U32>, List.drop(&2, U32, P.chunks_bytes(chunks), 0n), P.chunks_bytes(chunks), PK.drop_zero(P.chunks_bytes(chunks))) : {List.take(&2, U32, _, n) == xs : +List<U32>}
  %Equal.sym(Nat, n, List.length(&2, U32, xs), len) : {List.take(&2, U32, P.chunks_bytes(chunks), _) == xs : +List<U32>}
  bytes

# From a parsed region to the specification's encoding of the decoded value.
law take_all:
  for +xs: +List<U32>
  for +n: Nat
  for +len: {n == List.length(&2, U32, xs) : Nat}
  {List.take(&2, U32, xs, n) == xs : +List<U32>}
def take_all(xs, n, len):
  %Equal.sym(Nat, n, List.length(&2, U32, xs), len) : {List.take(&2, U32, xs, _) == xs : +List<U32>}
  PK.take_length_all(xs)

# The decoder's result, case by case on what the implementation computed.
law region_wf:
  for +xs: +List<U32>
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +len: {n == List.length(&2, U32, xs) : Nat}
  for +bytes: {List.take(&2, U32, P.chunks_bytes(chunks), List.length(&2, U32, xs)) == xs : +List<U32>}
  {List.length(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n})) == P.slice_size(P.Slice{chunks, 0n, n}) : Nat}
def region_wf(xs, n, chunks, len, bytes):
  %Equal.sym(+List<U32>, P.slice_bytes(P.Slice{chunks, 0n, n}), xs, region_is_input(xs, n, chunks, len, bytes)) : {List.length(&2, U32, _) == n : Nat}
  Equal.sym(Nat, n, List.length(&2, U32, xs), len)
