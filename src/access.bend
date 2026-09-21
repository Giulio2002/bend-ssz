import Base
import ./buffer.bend as B
import ./cschema.bend as S

# Field access, element iteration and encode for the compact primary API.
#
# A decoded value is a window of the caller's buffer that `API.validate` accepted
# against its schema: a `View` is that window, an offset and a length, and the
# schema says how to read it. Nothing is copied to take a view apart. A field
# or element of a validated view is again a validated view of its own schema,
# so access composes all the way down to the scalars, which are read straight
# out of the buffer.
#
# Every accessor takes the buffer and gives it back, like every other reader:
# the caller owns the input, and views stay meaningful for as long as the
# caller keeps it. The accessors assume a view that validated; on an arbitrary
# window they still read in bounds (`Array.get` masks its index) but the answer
# means nothing.
#
# This module is separate from `api.bend` on purpose: the pinned compiler
# elaborates every definition of every imported module, so a driver that only
# decodes and roots does not pay for these.
type View is Data:
  View{off: U32, len: U32}

def view_off(v: View) -> U32:
  match v:
    case View{+off, len}: off

def view_len(v: View) -> U32:
  match v:
    case View{off, +len}: len

def pick(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

def some_or(m: Maybe<&2, U32>, +d: U32) -> U32:
  match m:
    case None{}: d
    case Some{+x}: x

def is_some(m: Maybe<&2, U32>) -> Bool:
  match m:
    case None{}: False{}
    case Some{x}: True{}

# ---------------------------------------------------------------------------
# Containers

def leaf_schema(f: S.CS) -> S.CS:
  match f:
    case S.CFLeaf{+s, hoff, hsize, fixed}: s
    case _: S.CNull{}

def leaf_hsize(f: S.CS) -> U32:
  match f:
    case S.CFLeaf{s, hoff, +hsize, fixed}: hsize
    case _: 0

def cont_fields(s: S.CS) -> S.CS:
  match s:
    case S.CCont{+fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}: fields
    case S.CPCont{+fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}: fields
    case _: S.CFNone{}

def cont_count(s: S.CS) -> U32:
  match s:
    case S.CCont{fields, +cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}: cnt
    case S.CPCont{fields, +cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}: cnt
    case _: 0

def rebase(+off: U32, pair: B.Buf & U32) -> B.Buf & U32:
  (b, +x) = pair
  (b, (off + x : U32))

# End of a variable field: the next variable field's offset, or the end of the
# container when it is the last one.
def var_end(has_next: Bool, +off: U32, +len: U32, +next_hoff: U32, b: B.Buf) -> B.Buf & U32:
  match has_next:
    case True{}: rebase(off, B.read32(b, (off + next_hoff : U32)))
    case False{}: (b, (off + len : U32))

def var_view(+start: U32, pair: B.Buf & U32) -> B.Buf & View:
  (b, +stop) = pair
  (b, View{start, (stop - start : U32)})

def var_field(+off: U32, +len: U32, +next: Maybe<&2, U32>, pair: B.Buf & U32) -> B.Buf & View:
  (b, +rel) = pair
  var_view((off + rel : U32), var_end(is_some(next), off, len, some_or(next, 0), b))

def field_pick(fixed: Bool, +fields: S.CS, +cnt: U32, +i: U32, +hoff: U32, +hsize: U32,
               +off: U32, +len: U32, b: B.Buf) -> B.Buf & View:
  match fixed:
    case True{}: (b, View{(off + hoff : U32), hsize})
    case False{}:
      var_field(off, len, S.next_var(fields, (i + 1 : U32), cnt), B.read32(b, (off + hoff : U32)))

# Schema of field `i` of a container schema.
def field_schema(+s: S.CS, +i: U32) -> S.CS: leaf_schema(S.field(cont_fields(s), i))

# View of field `i` of a validated container view.
def field(+s: S.CS, +i: U32, +v: View, b: B.Buf) -> B.Buf & View:
  field_pick(S.fixed_of(S.field(cont_fields(s), i)), cont_fields(s), cont_count(s), i,
    S.hoff_of(S.field(cont_fields(s), i)), leaf_hsize(S.field(cont_fields(s), i)),
    view_off(v), view_len(v), b)

# ---------------------------------------------------------------------------
# Vectors and lists

def elem_schema(s: S.CS) -> S.CS:
  match s:
    case S.CVec{+elem, count, stride, depth, basic, plain}: elem
    case S.CVecVar{+elem, count, depth}: elem
    case S.CList{+elem, lim, big, stride, depth, basic, plain}: elem
    case S.CListVar{+elem, lim, big, depth}: elem
    case _: S.CNull{}

def first_count(+len: U32, pair: B.Buf & U32) -> B.Buf & U32:
  (b, +first) = pair
  (b, pick(U32.is_eq(len, 0), 0, U32.shrn(first, 2n)))

# Number of elements of a validated sequence view; fields for a container.
def count(+s: S.CS, +v: View, b: B.Buf) -> B.Buf & U32:
  match s:
    case S.CVec{elem, +n, stride, depth, basic, plain}: (b, n)
    case S.CVecVar{elem, +n, depth}: (b, n)
    case S.CList{elem, lim, big, +stride, depth, basic, plain}: (b, U32.div(view_len(v), stride))
    case S.CListVar{elem, lim, big, depth}: first_count(view_len(v), B.read32(b, view_off(v)))
    case S.CCont{fields, +cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}: (b, cnt)
    case S.CPCont{fields, +cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}: (b, cnt)
    case _: (b, 0)

def var_elem_end(last: Bool, +off: U32, +len: U32, +i: U32, b: B.Buf) -> B.Buf & U32:
  match last:
    case True{}: (b, (off + len : U32))
    case False{}: rebase(off, B.read32(b, (off + 4 * (i + 1 : U32) : U32)))

def var_elem(+off: U32, +len: U32, +i: U32, +n: U32, pair: B.Buf & U32) -> B.Buf & View:
  (b, +rel) = pair
  var_view((off + rel : U32), var_elem_end(U32.is_eq((i + 1 : U32), n), off, len, i, b))

def var_elem_at(+off: U32, +len: U32, +i: U32, pair: B.Buf & U32) -> B.Buf & View:
  (b, +n) = pair
  var_elem(off, len, i, n, B.read32(b, (off + 4 * i : U32)))

# View of element `i` of a validated vector or list view.
def elem(+s: S.CS, +i: U32, +v: View, b: B.Buf) -> B.Buf & View:
  match s:
    case S.CVec{e, n, +stride, depth, basic, plain}: (b, View{(view_off(v) + i * stride : U32), stride})
    case S.CList{e, lim, big, +stride, depth, basic, plain}: (b, View{(view_off(v) + i * stride : U32), stride})
    case S.CVecVar{e, +n, depth}:
      var_elem(view_off(v), view_len(v), i, n, B.read32(b, (view_off(v) + 4 * i : U32)))
    case S.CListVar{e, lim, big, depth}:
      var_elem_at(view_off(v), view_len(v), i, count(s, v, b))
    case _: (b, View{view_off(v), 0})

# ---------------------------------------------------------------------------
# Scalars, read in place

# A uint of up to eight bytes as (low word, high word).
def uint64(+v: View, b: B.Buf) -> B.Buf & (U32 & U32): B.read64(b, view_off(v))

def boolean(+v: View, b: B.Buf) -> B.Buf & U32: B.byte_at(b, view_off(v))

def byte(+v: View, +j: U32, b: B.Buf) -> B.Buf & U32: B.byte_at(b, (view_off(v) + j : U32))

# ---------------------------------------------------------------------------
# Encode
#
# The encoding of a validated view is its window - SSZ encodings are unique,
# so the bytes that validated are the value's encoding - and encode returns it
# as compact bytes: a fresh `Buf` of exactly those bytes, copied a word at a
# time with no intermediate list.

def put(+j: U32, out: Array<U32>, pair: B.Buf & U32) -> B.Buf & Array<U32>:
  (b, +w) = pair
  (b, Array.set(U32, out, j, w))

def copy_go(+k: Nat, +j: U32, +off: U32, pair: B.Buf & Array<U32>) -> B.Buf & Array<U32>:
  match k pair:
    case 0n Tuple{b, out}: (b, out)
    case 1n+p Tuple{b, out}:
      copy_go(p, (j + 1 : U32), off, put(j, out, B.read32(b, (off + 4 * j : U32))))

def keep_mask(+r: U32) -> U32:
  match r:
    case 0: 0
    case 1: 255
    case 2: 65535
    case _: 16777215

def close(+len: U32, pair: B.Buf & Array<U32>) -> B.Buf & B.Buf:
  (b, out) = pair
  (b, B.Buf{out, len})

# Bytes past the logical end of the last word are cleared, so the output holds
# exactly the window and nothing of what followed it in the input.
def masked(+len: U32, b: B.Buf, pair: B.Buf & U32) -> B.Buf & B.Buf:
  (o, +w) = pair
  match o:
    case B.Buf{out, +n}:
      (b, B.Buf{Array.set(U32, out, U32.shrn(len, 2n),
        (w .&. keep_mask((len .&. 3 : U32)) : U32)), n})

def tail_word(+len: U32, pair: B.Buf & Array<U32>) -> B.Buf & B.Buf:
  (b, out) = pair
  masked(len, b, B.word(B.Buf{out, len}, U32.shrn(len, 2n)))

def finish(aligned: Bool, +len: U32, pair: B.Buf & Array<U32>) -> B.Buf & B.Buf:
  match aligned:
    case True{}: close(len, pair)
    case False{}: tail_word(len, pair)

def encode_window(+v: View, b: B.Buf) -> B.Buf & B.Buf:
  finish(U32.is_eq((view_len(v) .&. 3 : U32), 0), view_len(v),
    copy_go(U32.to_nat(U32.shrn((view_len(v) + 3 : U32), 2n)), 0, view_off(v),
      (b, Array.new(U32, B.capacity(view_len(v)), 0))))

def cloned(+n: U32, pair: Array<U32> & Array<U32>) -> B.Buf & B.Buf:
  (a, c) = pair
  (B.Buf{a, n}, B.Buf{c, n})

# A view of the whole buffer is encoded by cloning its word array, which the
# native runtime does as one block copy (`blk_copy` in the emitted C). The
# bytes past the logical end are the input's zero padding and its Merkle
# scratch; they are not part of the value, and a later root rewrites the
# scratch before reading it.
def encode_whole(b: B.Buf) -> B.Buf & B.Buf:
  match b:
    case B.Buf{ws, +n}: cloned(n, Array.clone(U32, ws))

def encode_pick(whole: Bool, +v: View, b: B.Buf) -> B.Buf & B.Buf:
  match whole:
    case True{}: encode_whole(b)
    case False{}: encode_window(v, b)

def encode_sized(+v: View, pair: B.Buf & U32) -> B.Buf & B.Buf:
  (b, +n) = pair
  encode_pick(Bool.and(U32.is_eq(view_off(v), 0), U32.is_eq(view_len(v), n)), v, b)

# Encode a validated view: the input buffer back, and the encoding.
def encode(+v: View, b: B.Buf) -> B.Buf & B.Buf: encode_sized(v, B.size(b))
