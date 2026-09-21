import Base
import ../types/schema.bend as T
import ./cschema.bend as S
import ./schema.bend as V
import ./primitives.bend as P

# The compact runtime schema of a spec schema.
#
# `compile(T)` computes the compact schema (src/cschema.bend) that the scanner,
# the root walker and the accessors walk, directly from the spec's own schema
# value: element strides, fixed sizes, header offsets, check trees, list
# limits, merkle depths and the plain/simple/shallow flags. It is what
# tools/generate_cschema.py used to precompute as literals. Computing it from
# the schema instead makes the correspondence between the two a property of
# this one function, proved once for every schema, rather than a per-type fact
# about literals: the pinned checker cannot compare the spec's unary limits
# (2^40 validators) with anything, so per-type facts about them could never be
# checked. The runtime evaluates Nat natively (the C backend maps Nat and
# U32.from_nat to machine words), and a program compiles its schema once.
#
# Every quantity that reaches a U32 field is below 2^32 or the schema is
# compiled to a form that accepts exactly what the spec accepts on inputs
# shorter than 2^32 bytes: a fixed size of 2^32 or more has no such encoding,
# and a list whose element is that large holds no element.
#
# Shape: `comp` is structurally recursive on the schema. A field chain compiles
# to a spine (CFNode{CFLeaf{field}, rest, 0} ... CFNone); the container,
# union and progressive cases then lay the spine out - header offsets, balanced
# field and check trees, option trees - with functions that do not call
# `comp`, because Bend has no mutual recursion.

# ---- numbers ----------------------------------------------------------------

def two32() -> Nat: Nat.mul(U32.to_nat(65536), U32.to_nat(65536))

def small(+n: Nat) -> Bool: Nat.is_lt(n, two32())

def u32(+n: Nat) -> U32: U32.from_nat(n)

def pick(c: Bool, x: Nat, y: Nat) -> Nat:
  match c:
    case True{}: x
    case False{}: y

def bpick(c: Bool, x: Bool, y: Bool) -> Bool:
  match c:
    case True{}: x
    case False{}: y

def cpick(c: Bool, x: S.CS, y: S.CS) -> S.CS:
  match c:
    case True{}: x
    case False{}: y

# Smallest d with 2^d >= n (0 for n <= 1).
def depth_go(+fuel: Nat, lt: Bool, +n: Nat, +d: Nat, +p: Nat) -> Nat:
  match fuel:
    case 0n: d
    case 1n+f:
      match lt:
        case False{}: d
        case True{}: depth_go(f, Nat.is_lt(Nat.double(p), n), n, 1n+d, Nat.double(p))

def depth_of(+n: Nat) -> U32: u32(depth_go(64n, Nat.is_lt(1n, n), n, 0n, 1n))

def ceil_div(+n: Nat, +k: Nat) -> Nat: Nat.div(Nat.add(n, Nat.sub(k, 1n)), k)

def is_some(m: Maybe<&2, Nat>) -> Bool:
  match m:
    case None{}: False{}
    case Some{x}: True{}

def some_or(m: Maybe<&2, Nat>, +d: Nat) -> Nat:
  match m:
    case None{}: d
    case Some{x}: x

def header_size(+s: T.Schema) -> Nat: some_or(V.fixed_size(s), 4n)

# Limit fields: the limit if it is below 2^32, else the "bigger than any
# input" flag with a zero limit.
def lim_pick(c: Bool, +l: Nat) -> U32:
  match c:
    case True{}: u32(l)
    case False{}: 0

def lim_of(+l: Nat) -> U32: lim_pick(small(l), l)

def big_of(+l: Nat) -> Bool: Bool.not(small(l))

# Is every byte string of the schema's fixed size a valid encoding of it?
def plain(s: T.Schema) -> Bool:
  match s:
    case T.Unsigned{w}: True{}
    case T.ByteVector{n}: True{}
    case T.Null{}: True{}
    case T.BitVector{+n}: Nat.is_eq(Nat.mod(n, 8n), 0n)
    case T.Vector{+e, n}: Bool.and(is_some(V.fixed_size(e)), plain(e))
    case T.ListOf{+e, n}: Bool.and(is_some(V.fixed_size(e)), plain(e))
    case T.Container{names, +fields}: Bool.and(is_some(V.fixed_size(fields)), plain(fields))
    case T.ProgressiveContainer{names, +fields, active}: Bool.and(is_some(V.fixed_size(fields)), plain(fields))
    case T.Chain{h, t}: Bool.and(plain(h), plain(t))
    case T.End{}: True{}
    case _: False{}

# Packed elements: their roots are their own bytes laid out as chunks.
def packs(s: T.Schema) -> Bool:
  match s:
    case T.Boolean{}: True{}
    case T.Unsigned{w}: True{}
    case T.ByteVector{+n}: Nat.is_eq(n, 32n)
    case _: False{}

# ---- spines -----------------------------------------------------------------

# A spine is CFNode{CFLeaf{field, 0, header size, fixed}, rest, 0} ... CFNone.
def spine_count(sp: S.CS) -> Nat:
  match sp:
    case S.CFNode{lo, hi, split}: 1n+spine_count(hi)
    case _: 0n

def leaf_hsize(f: S.CS) -> Nat:
  match f:
    case S.CFLeaf{s, hoff, +hsize, fixed}: U32.to_nat(hsize)
    case _: 0n

def leaf_fixed(f: S.CS) -> Bool:
  match f:
    case S.CFLeaf{s, hoff, hsize, +fixed}: fixed
    case _: False{}

def leaf_schema(f: S.CS) -> S.CS:
  match f:
    case S.CFLeaf{+s, hoff, hsize, fixed}: s
    case _: S.CFNone{}

def with_hoff(f: S.CS, +h: Nat) -> S.CS:
  match f:
    case S.CFLeaf{s, hoff, hsize, fixed}: S.CFLeaf{s, u32(h), hsize, fixed}
    case other: other

# Sum of header sizes of a spine: the container's fixed part.
def spine_part(sp: S.CS) -> Nat:
  match sp:
    case S.CFNode{+lo, hi, split}: Nat.add(leaf_hsize(lo), spine_part(hi))
    case _: 0n

# The spine with header offsets filled in, starting at `h`.
def placed(sp: S.CS, +h: Nat) -> S.CS:
  match sp:
    case S.CFNode{+lo, hi, split}: S.CFNode{with_hoff(lo, h), placed(hi, Nat.add(h, leaf_hsize(lo))), 0}
    case other: other

# A leaf validation must visit: variable size, or fixed but not plain.
def checked(+f: S.CS) -> Bool:
  Bool.not(Bool.and(leaf_fixed(f), S.is_plain(leaf_schema(f))))

def keep_if(c: Bool, +lo: S.CS, rest: S.CS) -> S.CS:
  match c:
    case True{}: S.CFNode{lo, rest, 0}
    case False{}: rest

def checks(sp: S.CS) -> S.CS:
  match sp:
    case S.CFNode{+lo, hi, split}: keep_if(checked(lo), lo, checks(hi))
    case other: other

def spine_take(+k: Nat, sp: S.CS) -> S.CS:
  match k:
    case 0n: S.CFNone{}
    case 1n+j:
      match sp:
        case S.CFNode{lo, hi, split}: S.CFNode{lo, spine_take(j, hi), 0}
        case other: other

def spine_drop(+k: Nat, sp: S.CS) -> S.CS:
  match k:
    case 0n: sp
    case 1n+j:
      match sp:
        case S.CFNode{lo, hi, split}: spine_drop(j, hi)
        case other: other

def spine_head(sp: S.CS) -> S.CS:
  match sp:
    case S.CFNode{+lo, hi, split}: lo
    case _: S.CFNone{}

# Balanced tree over a spine of `n` leaves: the low half holds n / 2.
def balance_go(+fuel: Nat, +sp: S.CS, +n: Nat) -> S.CS:
  match fuel:
    case 0n: S.CFNone{}
    case 1n+f:
      match n:
        case 0n: S.CFNone{}
        case 1n+m:
          match m:
            case 0n: spine_head(sp)
            case 1n+r:
              S.CFNode{balance_go(f, spine_take(Nat.div(n, 2n), sp), Nat.div(n, 2n)),
                       balance_go(f, spine_drop(Nat.div(n, 2n), sp), Nat.sub(n, Nat.div(n, 2n))),
                       u32(Nat.div(n, 2n))}

def balance(+sp: S.CS) -> S.CS: balance_go(Nat.add(spine_count(sp), 1n), sp, spine_count(sp))

def shallow_cs(s: S.CS) -> Bool:
  match s:
    case S.CByteList{lim, big, depth}: True{}
    case S.CList{elem, lim, big, stride, depth, basic, +pl}: pl
    case _: False{}

# Are all leaves length-only variable lists (a simple variable container)?
def all_shallow(sp: S.CS) -> Bool:
  match sp:
    case S.CFNode{+lo, hi, split}: Bool.and(Bool.and(Bool.not(leaf_fixed(lo)), shallow_cs(leaf_schema(lo))), all_shallow(hi))
    case _: True{}

def byte_check(s: S.CS) -> Bool:
  match s:
    case S.CBool{}: True{}
    case S.CBitVec{+bits, bytes, depth}: Bool.not(U32.is_eq((bits .&. 7 : U32), 0))
    case _: False{}

# Are all leaves single-byte checks (a simple fixed container)?
def all_bytes(sp: S.CS) -> Bool:
  match sp:
    case S.CFNode{+lo, hi, split}: Bool.and(byte_check(leaf_schema(lo)), all_bytes(hi))
    case _: True{}

def simple_of(fixed: Bool, +ck: S.CS, +nck: Nat) -> Bool:
  match fixed:
    case False{}: all_shallow(ck)
    case True{}: Bool.and(Nat.is_lt(0n, nck), all_bytes(ck))

def max1(+n: Nat) -> Nat: pick(Nat.is_lt(n, 1n), 1n, n)

# ---- layouts ----------------------------------------------------------------

# A container: `sp` is the compiled field spine, `size` the spec's fixed size
# of the fields (None when variable), `pl` whether the container is plain.
def container_ok(+n: Nat, +part: Nat, +size: Maybe<&2, Nat>) -> Bool:
  Bool.and(Nat.is_lt(0n, n), Bool.and(small(part), small(some_or(size, 0n))))

def container(sp: S.CS, +size: Maybe<&2, Nat>, +pl: Bool) -> S.CS:
  +fields = placed(sp, 0n)
  +ck = checks(fields)
  +n = spine_count(fields)
  +nck = spine_count(ck)
  +part = spine_part(fields)
  cpick(container_ok(n, part, size),
    S.CCont{balance(fields), u32(n), u32(part), u32(some_or(size, 0n)), is_some(size),
            depth_of(max1(n)), pl, balance(ck), u32(nck), simple_of(is_some(size), ck, nck)},
    S.CFNone{})

# Progressive container: the slots are the fields at their active positions
# and a CNull leaf at every inactive one; the active bits are a mask, which
# holds at most 31 positions.
def slots(active: +List<Bool>, fields: S.CS) -> S.CS:
  match active:
    case Nil{}: S.CFNone{}
    case Con{True{}, rest}:
      match fields:
        case S.CFNode{lo, hi, split}: S.CFNode{lo, slots(rest, hi), 0}
        case other: S.CFNone{}
    case Con{False{}, rest}: S.CFNode{S.CFLeaf{S.CNull{}, 0, 0, True{}}, slots(rest, fields), 0}

def mask_go(active: +List<Bool>, +bit: U32) -> U32:
  match active:
    case Nil{}: 0
    case Con{True{}, rest}: (bit .|. mask_go(rest, U32.shl(bit)) : U32)
    case Con{False{}, rest}: mask_go(rest, U32.shl(bit))

def pcontainer_ok(+n: Nat, +part: Nat, +size: Maybe<&2, Nat>, +na: Nat) -> Bool:
  Bool.and(container_ok(n, part, size), Nat.is_le(na, 31n))

def pcontainer(sp: S.CS, +size: Maybe<&2, Nat>, +pl: Bool, +active: +List<Bool>) -> S.CS:
  +fields = placed(sp, 0n)
  +ck = checks(fields)
  +n = spine_count(fields)
  +nck = spine_count(ck)
  +part = spine_part(fields)
  +na = List.length(&2, Bool, active)
  cpick(pcontainer_ok(n, part, size, na),
    S.CPCont{balance(fields), u32(n), u32(part), u32(some_or(size, 0n)), is_some(size), pl,
             balance(ck), u32(nck), balance(slots(active, fields)), u32(na), mask_go(active, 1)},
    S.CFNone{})

# Union options as leaves at header offset 0 with header size 0.
def option_leaf(f: S.CS) -> S.CS:
  match f:
    case S.CFLeaf{s, hoff, hsize, fixed}: S.CFLeaf{s, 0, 0, fixed}
    case other: other

def options(sp: S.CS) -> S.CS:
  match sp:
    case S.CFNode{lo, hi, split}: S.CFNode{option_leaf(lo), options(hi), 0}
    case other: other

# A union: option i at selector i.
def union(sp: S.CS) -> S.CS:
  +opts = options(sp)
  S.CUnion{balance(opts), u32(spine_count(opts))}

# A compatible union: option j at its selector, holes elsewhere, up to the
# largest selector.
def option_at(+sel: U32, sels: +List<U32>, opts: S.CS) -> S.CS:
  match sels:
    case Nil{}: S.CFNone{}
    case Con{+s, rest}:
      match opts:
        case S.CFNode{+lo, hi, split}: cpick(U32.is_eq(s, sel), lo, option_at(sel, rest, hi))
        case other: S.CFNone{}

def dense_go(+fuel: Nat, +i: U32, +sels: +List<U32>, +opts: S.CS) -> S.CS:
  match fuel:
    case 0n: S.CFNone{}
    case 1n+f: S.CFNode{option_at(i, sels, opts), dense_go(f, (i + 1 : U32), sels, opts), 0}

def bpick_u32(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

def max_sel(sels: +List<U32>, +m: U32) -> U32:
  match sels:
    case Nil{}: m
    case Con{+s, rest}: max_sel(rest, bpick_u32(U32.is_lt(m, s), s, m))

def cunion(sp: S.CS, +sels: +List<U32>) -> S.CS:
  +opts = options(sp)
  +width = (max_sel(sels, 0) + 1 : U32)
  S.CUnion{balance(dense_go(U32.to_nat(width), 0, sels, opts)), width}

# Sequences. `ce` is the compiled element, `e` its spec schema.
def vec_fixed(+ce: S.CS, +e: T.Schema, +n: Nat, +st: Nat) -> S.CS:
  +chunks = pick(packs(e), ceil_div(Nat.mul(n, st), 32n), n)
  cpick(small(Nat.mul(n, st)),
    S.CVec{ce, u32(n), u32(st), depth_of(max1(chunks)), packs(e), plain(e)},
    S.CFNone{})

def vector_go(ce: S.CS, +e: T.Schema, +n: Nat, m: Maybe<&2, Nat>) -> S.CS:
  match m:
    case None{}: cpick(small(Nat.mul(4n, n)), S.CVecVar{ce, u32(n), depth_of(n)}, S.CFNone{})
    case Some{+st}: vec_fixed(ce, e, n, st)

def vector(ce: S.CS, +e: T.Schema, +n: Nat) -> S.CS: vector_go(ce, e, n, V.fixed_size(e))

# A list: the limit if below 2^32 or the "bigger than any input" flag, and
# the merkle depth of the limit's chunk count. An element of 2^32 bytes or
# more fits no input, so such a list holds no element: limit 0.
def list_fixed(+ce: S.CS, +e: T.Schema, +l: Nat, +st: Nat) -> S.CS:
  +chunks = pick(packs(e), ceil_div(Nat.mul(l, st), 32n), l)
  cpick(small(st),
    S.CList{ce, lim_of(l), big_of(l), u32(st), depth_of(max1(chunks)), packs(e), plain(e)},
    S.CList{ce, 0, False{}, 1, depth_of(max1(chunks)), packs(e), plain(e)})

def list_go(ce: S.CS, +e: T.Schema, +l: Nat, m: Maybe<&2, Nat>) -> S.CS:
  match m:
    case None{}: S.CListVar{ce, lim_of(l), big_of(l), depth_of(l)}
    case Some{+st}: list_fixed(ce, e, l, st)

def list(ce: S.CS, +e: T.Schema, +l: Nat) -> S.CS: list_go(ce, e, l, V.fixed_size(e))

# Progressive list: no limit, merkle depth 255 marks a progressive tree.
def plist_go(+ce: S.CS, +e: T.Schema, m: Maybe<&2, Nat>) -> S.CS:
  match m:
    case None{}: S.CListVar{ce, 0, True{}, 255}
    case Some{+st}:
      cpick(small(st),
        S.CList{ce, 0, True{}, u32(st), 255, packs(e), plain(e)},
        S.CList{ce, 0, False{}, 1, 255, packs(e), plain(e)})

def plist(ce: S.CS, +e: T.Schema) -> S.CS: plist_go(ce, e, V.fixed_size(e))

# ---- the compiler -------------------------------------------------------------

def comp(s: T.Schema) -> S.CS:
  match s:
    case T.Boolean{}: S.CBool{}
    case T.Unsigned{+w}: S.CUint{u32(P.width(w))}
    case T.Null{}: S.CNull{}
    case T.ByteVector{+n}: cpick(small(n), S.CBytes{u32(n), depth_of(ceil_div(n, 32n))}, S.CFNone{})
    case T.ByteList{+l}: S.CByteList{lim_of(l), big_of(l), depth_of(ceil_div(l, 32n))}
    case T.BitVector{+n}: cpick(small(n), S.CBitVec{u32(n), u32(ceil_div(n, 8n)), depth_of(ceil_div(n, 256n))}, S.CFNone{})
    case T.BitList{+l}: S.CBitList{lim_of(l), big_of(l), depth_of(ceil_div(l, 256n))}
    case T.ProgressiveBits{}: S.CBitList{0, True{}, 255}
    case T.Vector{+e, +n}: vector(comp(e), e, n)
    case T.ListOf{+e, +l}: list(comp(e), e, l)
    case T.ProgressiveList{+e}: plist(comp(e), e)
    case T.Container{names, +fields}:
      container(comp(fields), V.fixed_size(fields), Bool.and(is_some(V.fixed_size(fields)), plain(fields)))
    case T.ProgressiveContainer{names, +fields, +active}:
      pcontainer(comp(fields), V.fixed_size(fields), Bool.and(is_some(V.fixed_size(fields)), plain(fields)), active)
    case T.Union{+opts}: union(comp(opts))
    case T.CompatibleUnion{+sels, +opts}: cunion(comp(opts), sels)
    case T.Chain{+h, +t}: S.CFNode{S.CFLeaf{comp(h), 0, u32(header_size(h)), is_some(V.fixed_size(h))}, comp(t), 0}
    case T.End{}: S.CFNone{}
    case _: S.CFNone{}

# The compact schema of a type: an illegal type gets a schema no input
# validates against.
def compile(+s: T.Schema) -> S.CS: cpick(V.valid(s), comp(s), S.CFNone{})
