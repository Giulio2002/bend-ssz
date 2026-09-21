import Base
import ../types/schema.bend as T
import ./buffer.bend as B
import ./digest.bend as D
import ./merkle_fast.bend as MF
import ./sizes.bend as Z

# hash_tree_root over indexed storage.
#
# Leaves are hashed straight from the packed buffer by `src/merkle_fast.bend`.
# Composite roots - container fields, and sequences whose elements are
# themselves composite - are merkleized with the same level-stack algorithm,
# each nesting level using its own sixty-four-slot segment of one shared
# `Array<D.Digest>`, so no stack is allocated per element and nothing is a
# linked structure.
#
# As in `src/scan.bend`, this is one self-recursive definition: Bend has no
# mutual recursion, cannot match a computed value, and requires a self-call to
# leave every argument unchanged until one shrinks.
#
# Tags:
#   0  compute the root of `schema` over the window [a, b) and deliver it
#   1  deliver the digest just computed to the frame
type RFrame is Data:
  RDone{}
  # merkleizing `n` fixed-stride composite elements of `elem` from `base`;
  # `i` elements have been pushed, `seg` is this level's stack segment,
  # `limit` the chunk limit and `mix` the length to mix in (0 = none)
  RRep{elem: T.Schema, i: U32, n: U32, base: U32, stride: U32, seg: U32, limit: U32, mix: U32, up: RFrame}
  # merkleizing container fields: `rest` is the remaining chain
  RField{rest: T.Schema, hp: U32, base: U32, endp: U32, i: U32, cnt: U32, seg: U32,
         pend: T.Schema, start: U32, has: U32, up: RFrame}

def mix_chunk(+n: U32) -> D.Digest:
  D.D{0, 0, 0, 0, 0, 0, 0, MF.shl_by(0, 0)}

# The length chunk is the little-endian uint256 of `n`, which in big-endian
# words is the byte-swapped value in the first word.
def length_chunk(+n: U32) -> D.Digest:
  D.D{B.swap32(n), 0, 0, 0, 0, 0, 0, 0}

def mix_in_length(d: D.Digest, +n: U32) -> D.Digest: D.hash_pair(d, length_chunk(n))

# Chunk limits for the leaf forms.
def bytes_limit(+n: U32) -> U32: U32.shrn((n + 31 : U32), 5n)

def bits_limit(+n: U32) -> U32: U32.shrn((n + 255 : U32), 8n)
