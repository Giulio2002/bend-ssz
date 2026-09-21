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
  # fixed-stride elements; `basic` means each element's root is its own bytes
  # laid out as chunks - packed basic types, and 32-byte vectors, which are
  # exactly one chunk - so the sequence merkleizes as one byte range.
  # `plain` (here and on containers) means every byte string of the right
  # length is a valid encoding: the value is built only from uints, byte
  # vectors and whole-byte bit vectors, so validation is the length check
  # alone and the scanner does not visit elements or fields.
  CVec{elem: CS, count: U32, stride: U32, depth: U32, basic: Bool, plain: Bool}
  CVecVar{elem: CS, count: U32, depth: U32}
  CList{elem: CS, lim: U32, big: Bool, stride: U32, depth: U32, basic: Bool, plain: Bool}
  CListVar{elem: CS, lim: U32, big: Bool, depth: U32}
  # `checks`/`nchecks`: the same field tree filtered to the fields validation
  # must visit - variable-size fields and fixed fields that are not plain - in
  # order and with their header offsets. The scanner walks only these.
  # `simple`: a variable-size container whose checks are all variable fields
  # whose validity depends on their length alone (byte lists, lists of plain
  # elements); the scanner then validates one offset per step (tag 15).
  CCont{fields: CS, count: U32, fixed_part: U32, size: U32, fixed: Bool, depth: U32, plain: Bool,
        checks: CS, nchecks: U32, simple: Bool}
  # Progressive container: encoded, validated and accessed exactly like a
  # container over `fields`; rooted over `slots` - the fields at their active
  # positions with CNull at inactive ones - as a progressive tree, then mixed
  # with the active bit vector, packed little-endian into `active` (the
  # generator refuses more than 31 positions).
  CPCont{fields: CS, count: U32, fixed_part: U32, size: U32, fixed: Bool, plain: Bool,
         checks: CS, nchecks: U32, slots: CS, nslots: U32, active: U32}
  # Compatible union: a selector byte, then the value of the selected option.
  # `options` is a field tree indexed by selector value, with a CFNone leaf
  # where the selector is not allowed; `nsel` is its size.
  CUnion{options: CS, nsel: U32}
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
    case CVec{elem, +count, +stride, depth, basic, plain}: Some{(count * stride : U32)}
    case CVecVar{elem, count, depth}: None{}
    case CList{elem, lim, big, stride, depth, basic, plain}: None{}
    case CListVar{elem, lim, big, depth}: None{}
    case CCont{fields, count, fixed_part, +size, fixed, depth, plain, checks, nchecks, simple}: cont_size(fixed, size)
    case CPCont{fields, count, fixed_part, +size, fixed, plain, checks, nchecks, slots, nslots, active}: cont_size(fixed, size)
    case CUnion{options, nsel}: None{}
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
    case CVec{elem, count, stride, depth, basic, plain}: True{}
    case CVecVar{elem, count, depth}: False{}
    case CList{elem, lim, big, stride, depth, basic, plain}: False{}
    case CListVar{elem, lim, big, depth}: False{}
    case CCont{fields, count, fixed_part, size, +fixed, depth, plain, checks, nchecks, simple}: fixed
    case CPCont{fields, count, fixed_part, size, +fixed, plain, checks, nchecks, slots, nslots, active}: fixed
    case CUnion{options, nsel}: False{}
    case CNull{}: True{}
    case CFLeaf{f, hoff, hsize, fixed}: False{}
    case CFNode{lo, hi, split}: False{}
    case CFNone{}: False{}

# Is every byte string of the schema's fixed size a valid encoding of it?
# (Uints, byte vectors, whole-byte bit vectors, and the fixed vectors and
# containers the generator marked `plain`.)
def is_plain(s: CS) -> Bool:
  match s:
    case CUint{size}: True{}
    case CBytes{len, depth}: True{}
    case CBitVec{+bits, bytes, depth}: U32.is_eq((bits .&. 7 : U32), 0)
    case CVec{elem, count, stride, depth, basic, +plain}: plain
    case CCont{fields, count, fixed_part, size, +fixed, depth, +plain, checks, nchecks, simple}: Bool.and(fixed, plain)
    case CPCont{fields, count, fixed_part, size, +fixed, +plain, checks, nchecks, slots, nslots, active}: Bool.and(fixed, plain)
    case CNull{}: True{}
    case _: False{}

# Validity of a variable-size value that depends on its length alone: a byte
# list (within the limit), or a list of plain elements (a whole number of
# elements, within the limit). 1 = valid, 2 = invalid, 0 = not such a schema,
# walk into it.
def shallow_pick(ok: Bool) -> U32:
  match ok:
    case True{}: 1
    case False{}: 2

def shallow_list(plain: Bool, +len: U32, +lim: U32, big: Bool, +stride: U32) -> U32:
  match plain:
    case True{}:
      shallow_pick(Bool.and(U32.is_eq(len, (U32.div(len, stride) * stride : U32)),
        within(U32.div(len, stride), lim, big)))
    case False{}: 0

def shallow(+s: CS, +len: U32) -> U32:
  match s:
    case CByteList{+lim, big, depth}: shallow_pick(within(len, lim, big))
    case CList{elem, +lim, big, +stride, depth, basic, plain}: shallow_list(plain, len, lim, big, stride)
    case _: 0

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
