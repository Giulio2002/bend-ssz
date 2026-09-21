import Base

# The schema the runtime walks.
#
# `types/schema.bend` is the neutral representation the frozen specifications
# quantify over, and its sizes and limits are unary `Nat`s: a
# `List[Validator, 2^40]` limit is a numeral with 2^40 successors. Nothing may
# convert, divide or compare that at runtime, so the runtime walks this compact
# form instead, in which every quantity is machine sized and every quantity the
# hot path needs is precomputed by the generator:
#
#   * element strides and fixed sizes in bytes,
#   * the header size of each field and its offset inside the fixed part,
#   * list limits as a 32-bit value plus a "larger than any possible input"
#     flag, which is exact because an SSZ input is shorter than 2^32 bytes,
#   * the merkle depth of every sequence, so no chunk limit is ever divided.
#
# Container fields are a balanced tree, not a spine: field i is found by
# halving, and each leaf already knows its header offset.
type CS is Data:
  CBool{}
  CUint{size: U32}
  CBytes{len: U32, depth: U32}
  CByteList{lim: U32, big: Bool, depth: U32}
  CBitVec{bits: U32, bytes: U32, depth: U32}
  CBitList{lim: U32, big: Bool, depth: U32}
  # fixed-stride elements; `basic` means the elements pack into chunks
  CVec{elem: CS, count: U32, stride: U32, depth: U32, basic: Bool}
  CVecVar{elem: CS, count: U32, depth: U32}
  CList{elem: CS, lim: U32, big: Bool, stride: U32, depth: U32, basic: Bool}
  CListVar{elem: CS, lim: U32, big: Bool, depth: U32}
  CCont{fields: CS, count: U32, fixed_part: U32, size: U32, fixed: Bool, depth: U32}
  CNull{}
  # Field-tree nodes. They share this type because Bend has no mutually
  # recursive type declarations; a field tree never appears where a schema is
  # expected and vice versa.
  CFLeaf{f: CS, hoff: U32, hsize: U32, fixed: Bool}
  CFNode{lo: CS, hi: CS, split: U32}
  CFNone{}

# Field `i` of a container, found by halving. `split` is the number of fields
# in the low subtree, and each leaf already knows its header offset. The
# decision for the *next* node is computed by the caller, because Bend cannot
# match a computed value and has no mutual recursion.
def split_of(fs: CS) -> U32:
  match fs:
    case CFNode{lo, hi, +sp}: sp
    case _: 0

def field_at(+fuel: Nat, low: Bool, +fs: CS, +i: U32) -> CS:
  match fuel:
    case 0n: CFNone{}
    case 1n+p:
      match low:
        case True{}:
          match fs:
            case CFNode{+lo, +hi, +sp}: field_at(p, U32.is_lt(i, split_of(lo)), lo, i)
            case _: fs
        case False{}:
          match fs:
            case CFNode{+lo, +hi, +sp}:
              field_at(p, U32.is_lt((i - sp : U32), split_of(hi)), hi, (i - sp : U32))
            case _: fs

def field(+fs: CS, +i: U32) -> CS: field_at(32n, U32.is_lt(i, split_of(fs)), fs, i)

# Is `n` within a list limit? The flag means the limit exceeds any possible
# input length, so every machine count is within it.
def within(+n: U32, +lim: U32, big: Bool) -> Bool:
  match big:
    case True{}: True{}
    case False{}: U32.is_le(n, lim)

def cont_size(fixed: Bool, +size: U32) -> Maybe<&2, U32>:
  match fixed:
    case True{}: Some{size}
    case False{}: None{}

# Fixed size of a schema in bytes, or None when it is variable sized.
def fixed_size(s: CS) -> Maybe<&2, U32>:
  match s:
    case CBool{}: Some{1}
    case CUint{+size}: Some{size}
    case CBytes{+len, depth}: Some{len}
    case CByteList{lim, big, depth}: None{}
    case CBitVec{bits, +bytes, depth}: Some{bytes}
    case CBitList{lim, big, depth}: None{}
    case CVec{elem, +count, +stride, depth, basic}: Some{(count * stride : U32)}
    case CVecVar{elem, count, depth}: None{}
    case CList{elem, lim, big, stride, depth, basic}: None{}
    case CListVar{elem, lim, big, depth}: None{}
    case CCont{fields, count, fixed_part, +size, fixed, depth}: cont_size(fixed, size)
    case CNull{}: Some{0}
    case CFLeaf{f, hoff, hsize, fixed}: None{}
    case CFNode{lo, hi, split}: None{}
    case CFNone{}: None{}

def is_fixed(s: CS) -> Bool:
  match s:
    case CBool{}: True{}
    case CUint{size}: True{}
    case CBytes{len, depth}: True{}
    case CByteList{lim, big, depth}: False{}
    case CBitVec{bits, bytes, depth}: True{}
    case CBitList{lim, big, depth}: False{}
    case CVec{elem, count, stride, depth, basic}: True{}
    case CVecVar{elem, count, depth}: False{}
    case CList{elem, lim, big, stride, depth, basic}: False{}
    case CListVar{elem, lim, big, depth}: False{}
    case CCont{fields, count, fixed_part, size, +fixed, depth}: fixed
    case CNull{}: True{}
    case CFLeaf{f, hoff, hsize, fixed}: False{}
    case CFNode{lo, hi, split}: False{}
    case CFNone{}: False{}

def size_or(m: Maybe<&2, U32>, +d: U32) -> U32:
  match m:
    case None{}: d
    case Some{x}: x

def fixed_or_zero(s: CS) -> U32: size_or(fixed_size(s), 0)

# Field-leaf accessors and the search for the next variable-size field.
def hoff_of(f: CS) -> U32:
  match f:
    case CFLeaf{s, +hoff, hsize, fixed}: hoff
    case _: 0

def fixed_of(f: CS) -> Bool:
  match f:
    case CFLeaf{s, hoff, hsize, +fixed}: fixed
    case _: True{}

def not_fixed(b: Bool) -> Bool:
  match b:
    case True{}: False{}
    case False{}: True{}

def var_pick(inside: Bool, +fields: CS, +i: U32) -> Bool:
  match inside:
    case False{}: False{}
    case True{}: not_fixed(fixed_of(field(fields, i)))

def var_at(+fields: CS, +i: U32, +cnt: U32) -> Bool:
  var_pick(U32.is_lt(i, cnt), fields, i)

# Header offset of the first variable-size field at or after index `i`, or
# None when every remaining field is fixed size.
def next_var_go(+fuel: Nat, found: Bool, +fields: CS, +i: U32, +cnt: U32) -> Maybe<&2, U32>:
  match fuel:
    case 0n: None{}
    case 1n+p:
      match found:
        case True{}: Some{hoff_of(field(fields, i))}
        case False{}:
          next_var_go(p, var_at(fields, (i + 1 : U32), cnt), fields, (i + 1 : U32), cnt)

def next_var(+fields: CS, +i: U32, +cnt: U32) -> Maybe<&2, U32>:
  next_var_go(64n, var_at(fields, i, cnt), fields, i, cnt)
