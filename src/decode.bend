import Base
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./schema.bend as S
import ./layout.bend as L
import ./primitives.bend as P
import ./bitfields.bend as Bits
import ./bytes.bend as B
import ./walk.bend as W
import ./packed.bend as Pack
import ./cvalue.bend as C
import ./codec.bend as Codec

# One-pass SSZ decoding over the linked input.
#
# A cursor is a position in the input list; a region is a byte count at a
# cursor. Children are decoded in place: no region is copied, no header list is
# materialized and the result is never re-serialized. Canonicality is enforced
# locally: the first offset is the fixed-part size, every offset equals the
# current payload position (no gap or overlap), extents are monotone and within
# the region, and the region is consumed exactly. Leaf checks (boolean byte,
# bitfield padding and delimiter, limits) are those of the leaf codecs.
type Out is Data:
  Refused{}
  Parsed{value: C.CValue, rest: Pack.Slice}
  Begin{rest: Pack.Slice}

# Walk: a fixed/variable layout in progress. `prior` is the result of the
# previous child (Begin before the first): after a fixed child its rest is the
# header cursor and `other` the payload cursor, after a variable child the
# roles are swapped. `position` is the offset the next variable child must
# start at, `end` the region size.
type Cursor is Data:
  Region{size: Nat, input: Pack.Slice}
  Walk{fixed: Bool, prior: Out, other: Pack.Slice, position: Nat, end: Nat, acc: C.CValue}
  Pick{selector: U32, size: Nat, input: Pack.Slice}
  PickAmong{selectors: +List<U32>, selector: U32, size: Nat, input: Pack.Slice}
  Invalid{}

type Settled is Data:
  Settled{header: Pack.Slice, payload: Pack.Slice, acc: C.CValue}
  Broken{}

# How the end of a variable child is found: the next offset among the
# remaining fields, or among the remaining count of sequence elements.
type Ahead is Data:
  Later{fields: T.Schema}
  Remaining{count: Nat}

type Plan is Data:
  Plan{child: Cursor, fixed: Bool, other: Pack.Slice, position: Nat, acc: C.CValue}
  Stuck{}


# ---------------------------------------------------------------------------
# Arithmetic guards (Nat.is_lt is a primitive comparison).
def nat_eq(+a: Nat, +b: Nat) -> Bool:
  Bool.and(Bool.not(Nat.is_lt(a, b)), Bool.not(Nat.is_lt(b, a)))

def nat_le(+a: Nat, +b: Nat) -> Bool:
  Bool.not(Nat.is_lt(b, a))

# The strict uint32 serialized-size bound, in the same form the independent
# specification uses (four base-256 quotient steps leave no high digit).
def fits(+n: Nat) -> Bool:
  B.size_fits(n)

# ---------------------------------------------------------------------------
# Leaves. A leaf region is exactly `size` bytes at the cursor.
def boolean_byte(zero: Bool, one: Bool, rest: Pack.Slice) -> Out:
  match zero one:
    case True{} _: Parsed{C.CBool{False{}}, rest}
    case False{} True{}: Parsed{C.CBool{True{}}, rest}
    case False{} False{}: Refused{}

def boolean_leaf(ok: Bool, +xs: Pack.Slice) -> Out:
  match ok:
    case False{}: Refused{}
    case True{}: boolean_byte(U32.is_eq(Pack.byte_at(xs, 0n), 0), U32.is_eq(Pack.byte_at(xs, 0n), 1), Pack.adv(xs, 1n))

def uint_leaf(ok: Bool, +w: Primitive.Width, +xs: Pack.Slice) -> Out:
  match ok:
    case False{}: Refused{}
    case True{}: Parsed{C.CUint{Pack.uint_of(xs, P.width(w))}, Pack.adv(xs, P.width(w))}

# Zero copy: the decoded byte string is a slice of the input storage.
def bytes_leaf(ok: Bool, +n: Nat, +xs: Pack.Slice) -> Out:
  match ok:
    case False{}: Refused{}
    case True{}: Parsed{C.CBytes{Pack.sub(xs, n)}, Pack.adv(xs, n)}

def bits_result(r: Maybe<&2, +List<Bool>>, rest: Pack.Slice) -> Out:
  match r:
    case None{}: Refused{}
    case Some{bs}: Parsed{C.CBits{bs}, rest}

# Bitfields keep the neutral bit-list representation and the existing checked
# bitfield codecs; they are small in every supported schema.
def bits_leaf(+n: Nat, +xs: Pack.Slice, decode: +List<U32> -> Maybe<&2, +List<Bool>>) -> Out:
  bits_result(decode(Pack.to_list(Pack.sub(xs, n))), Pack.adv(xs, n))

def null_leaf(ok: Bool, xs: Pack.Slice) -> Out:
  match ok:
    case False{}: Refused{}
    case True{}: Parsed{C.CNull{}, xs}

# ---------------------------------------------------------------------------
# Layout bookkeeping.
#
# `reverse_items(remaining, acc)` is the chain a walk ends with when `acc`
# holds the children decoded so far (newest first) and `remaining` holds, in
# source order, the children still to come: each is prepended in turn. The
# decoder never evaluates it — closing a walk returns `acc` unchanged, because
# `C.to_value` already reads a chain newest-first — but the walk laws quantify
# over the remaining children, so they state the invariant through it.
def reverse_items(value: C.CValue, acc: C.CValue) -> C.CValue:
  match value:
    case C.CCons{h, t}: reverse_items(t, C.CCons{h, acc})
    case _: acc

# A completed layout is a sequence value.
def wrap_sequence(r: Out) -> Out:
  match r:
    case Parsed{v, rest}: Parsed{C.CSeq{v}, rest}
    case _: Refused{}

def wrap_selected(selector: U32, r: Out) -> Out:
  match r:
    case Parsed{v, rest}: Parsed{C.CSel{selector, v}, rest}
    case _: Refused{}

# Size of the fixed part of a field forest: fixed widths, four per offset.
def header_size(fields: T.Schema) -> Nat:
  match fields:
    case T.Chain{h, t}: Nat.add(L.slot(S.fixed_size(h)), header_size(t))
    case _: 0n

def next_field(width: Maybe<&2, Nat>, +header: Pack.Slice, later: Pack.Slice -> Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match width:
    case Some{w}: later(Pack.adv(header, w))
    case None{}: Some{Pack.offset_at(header)}

# The offset of the first variable field among `fields`, if any.
def next_offset(fields: T.Schema, +header: Pack.Slice) -> Maybe<&2, Nat>:
  match fields:
    case T.Chain{h, t}: next_field(S.fixed_size(h), header, rest => next_offset(t, rest))
    case _: None{}

def ahead(a: Ahead, +header: Pack.Slice) -> Maybe<&2, Nat>:
  match a:
    case Later{fields}: next_offset(fields, header)
    case Remaining{count}:
      match count:
        case 0n: None{}
        case 1n+p: Some{Pack.offset_at(header)}

def or_end(r: Maybe<&2, Nat>, end: Nat) -> Nat:
  match r:
    case None{}: end
    case Some{n}: n

def region_if(ok: Bool, n: Nat, xs: Pack.Slice) -> Cursor:
  match ok:
    case False{}: Invalid{}
    case True{}: Region{n, xs}

def settle(prior: Out, fixed: Bool, other: Pack.Slice, acc: C.CValue) -> Settled:
  match prior:
    case Refused{}: Broken{}
    case Begin{rest}:
      match fixed:
        case True{}: Settled{rest, other, acc}
        case False{}: Settled{other, rest, acc}
    case Parsed{v, rest}:
      match fixed:
        case True{}: Settled{rest, other, C.CCons{v, acc}}
        case False{}: Settled{other, rest, C.CCons{v, acc}}

def closed(ok: Bool, acc: C.CValue, rest: Pack.Slice) -> Out:
  match ok:
    case True{}: Parsed{acc, rest}
    case False{}: Refused{}

# The layout ends exactly at the region end: no trailing bytes.
def close(s: Settled, +pos: Nat, +end: Nat) -> Out:
  match s:
    case Broken{}: Refused{}
    case Settled{hdr, pay, acc}: closed(nat_eq(pos, end), acc, pay)

# The next child: a fixed child is read in place at the header cursor; a
# variable child spans [start, stop) at the payload cursor, where its offset
# `start` is exactly the current position and stop is the next offset or the
# region end.
def plan(s: Settled, width: Maybe<&2, Nat>, +pos: Nat, +end: Nat, a: Ahead) -> Plan:
  match s:
    case Broken{}: Stuck{}
    case Settled{+hdr, pay, acc}:
      match width:
        case Some{w}: Plan{Region{w, hdr}, True{}, pay, pos, acc}
        case None{}:
          +start = Pack.offset_at(hdr)
          +more = Pack.adv(hdr, 4n)
          +stop = or_end(ahead(a, more), end)
          Plan{region_if(Bool.and(nat_eq(start, pos), Bool.and(nat_le(start, stop), nat_le(stop, end))), Nat.sub(stop, start), pay), False{}, more, stop, acc}

def plan_child(p: Plan) -> Cursor:
  match p:
    case Stuck{}: Invalid{}
    case Plan{child, fixed, other, position, acc}: child

def plan_next(p: Plan, r: Out, +end: Nat) -> Cursor:
  match p:
    case Stuck{}: Invalid{}
    case Plan{child, fixed, other, position, acc}: Walk{fixed, r, other, position, end, acc}

# A layout region of `size` fixed-part bytes within `n` bytes at xs.
def layout(ok: Bool, +size: Nat, n: Nat, +xs: Pack.Slice) -> Cursor:
  match ok:
    case False{}: Invalid{}
    case True{}: Walk{True{}, Begin{xs}, Pack.adv(xs, size), size, n, C.CEnd{}}

# ---------------------------------------------------------------------------
# Element counts. Fixed-size elements divide the region; variable-size ones
# are counted by the first offset.
def count_if(ok: Bool, n: Nat) -> Maybe<&2, Nat>:
  match ok:
    case True{}: Some{n}
    case False{}: None{}

def list_count(+width: Maybe<&2, Nat>, +n: Nat, +xs: Pack.Slice) -> Maybe<&2, Nat>:
  match width:
    case Some{0n}: None{}
    case Some{1n+w}: count_if(nat_eq(Nat.mod(n, 1n+w), 0n), Nat.div(n, 1n+w))
    case None{}:
      match n:
        case 0n: Some{0n}
        case 1n+m:
          +first = Pack.offset_at(xs)
          count_if(Bool.and(Nat.is_lt(0n, first), Bool.and(nat_eq(Nat.mod(first, 4n), 0n), nat_le(first, 1n+m))), Nat.div(first, 4n))

def counted(r: Maybe<&2, Nat>) -> Nat:
  match r:
    case None{}: 0n
    case Some{k}: k

def count_ok(r: Maybe<&2, Nat>, +limit: Maybe<&2, Nat>) -> Bool:
  match r:
    case None{}: False{}
    case Some{k}:
      match limit:
        case None{}: True{}
        case Some{m}: nat_le(k, m)

# Sequence regions: fixed elements fill the region exactly; variable ones
# have a 4-byte offset each.
def sequence_ok(+width: Maybe<&2, Nat>, +count: Nat, +n: Nat) -> Bool:
  Bool.and(fits(n), nat_le(Nat.mul(L.slot(width), count), n))


# ---------------------------------------------------------------------------
# Unions: the selector byte, then the selected option over the rest.
def union_start(n: Nat, +xs: Pack.Slice) -> Cursor:
  match n:
    case 1n+m: Pick{Pack.byte_at(xs, 0n), m, Pack.adv(xs, 1n)}
    case _: Invalid{}

def among_start(selectors: +List<U32>, n: Nat, +xs: Pack.Slice) -> Cursor:
  match n:
    case 1n+m: PickAmong{selectors, Pack.byte_at(xs, 0n), m, Pack.adv(xs, 1n)}
    case _: Invalid{}

def selector_index(c: Cursor) -> Nat:
  match c:
    case Pick{selector, n, xs}: U32.to_nat(selector)
    case _: 0n

def among_here(hit: Bool, n: Nat, xs: Pack.Slice) -> Cursor:
  match hit:
    case True{}: Region{n, xs}
    case False{}: Invalid{}

def among_later(hit: Bool, rest: +List<U32>, selector: U32, n: Nat, xs: Pack.Slice) -> Cursor:
  match hit:
    case True{}: Invalid{}
    case False{}: PickAmong{rest, selector, n, xs}

def among(hit: Bool, selector: U32, here: Out, later: Out) -> Out:
  match hit:
    case True{}: wrap_selected(selector, here)
    case False{}: later

# ---------------------------------------------------------------------------
# The decoder. Recursion is on the schema; a composite first moves from its
# region (phase 1) to its layout walk (phase 0), whose remaining element count
# then decreases. Each loop step is one tail call carrying the previous
# child's result, so no closure is allocated per child.
def go(+schema: T.Schema, +phase: Nat, +k: Nat, c: Cursor) -> Out:
  match schema:
    case T.Boolean{}:
      match c:
        case Region{+n, xs}: boolean_leaf(nat_eq(n, 1n), xs)
        case _: Refused{}
    case T.Unsigned{+w}:
      match c:
        case Region{+n, xs}: uint_leaf(nat_eq(n, P.width(w)), w, xs)
        case _: Refused{}
    case T.ByteVector{+m}:
      match c:
        case Region{+n, +xs}: bytes_leaf(Bool.and(nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), fits(m))), m, xs)
        case _: Refused{}
    case T.ByteList{+m}:
      match c:
        case Region{+n, +xs}: bytes_leaf(Bool.and(nat_le(n, m), fits(n)), n, xs)
        case _: Refused{}
    case T.BitVector{+m}:
      match c:
        case Region{+n, +xs}: bits_leaf(n, xs, ys => Bits.bitvector_deserialize(m, ys))
        case _: Refused{}
    case T.BitList{+m}:
      match c:
        case Region{+n, +xs}: bits_leaf(n, xs, ys => Bits.bitlist_deserialize(m, ys))
        case _: Refused{}
    case T.ProgressiveBits{}:
      match c:
        case Region{+n, +xs}: bits_leaf(n, xs, ys => Bits.bitlist_deserialize(Nat.mul(n, 8n), ys))
        case _: Refused{}
    case T.Null{}:
      match c:
        case Region{+n, xs}: null_leaf(nat_eq(n, 0n), xs)
        case _: Refused{}
    case T.Vector{+e, +m}:
      match phase:
        case 1n+q:
          match c:
            case Region{+n, +xs}:
              +ok = Bool.and(Nat.is_lt(0n, m), sequence_ok(S.fixed_size(e), m, n))
              wrap_sequence(go(schema, q, m, layout(ok, Nat.mul(L.slot(S.fixed_size(e)), m), n, xs)))
            case _: Refused{}
        case 0n:
          match k:
            case 0n:
              match c:
                case Walk{fixed, prior, other, +pos, +end, acc}: close(settle(prior, fixed, other, acc), pos, end)
                case _: Refused{}
            case 1n+p:
              match c:
                case Walk{fixed, prior, other, +pos, +end, acc}:
                  +next = plan(settle(prior, fixed, other, acc), S.fixed_size(e), pos, end, Remaining{p})
                  r = go(e, 1n, 0n, plan_child(next))
                  go(schema, 0n, p, plan_next(next, r, end))
                case _: Refused{}
    case T.ListOf{+e, +limit}:
      match phase:
        case 1n+q:
          match c:
            case Region{+n, +xs}:
              +cnt = list_count(S.fixed_size(e), n, xs)
              +m = counted(cnt)
              +ok = Bool.and(count_ok(cnt, Some{limit}), sequence_ok(S.fixed_size(e), m, n))
              wrap_sequence(go(schema, q, m, layout(ok, Nat.mul(L.slot(S.fixed_size(e)), m), n, xs)))
            case _: Refused{}
        case 0n:
          match k:
            case 0n:
              match c:
                case Walk{fixed, prior, other, +pos, +end, acc}: close(settle(prior, fixed, other, acc), pos, end)
                case _: Refused{}
            case 1n+p:
              match c:
                case Walk{fixed, prior, other, +pos, +end, acc}:
                  +next = plan(settle(prior, fixed, other, acc), S.fixed_size(e), pos, end, Remaining{p})
                  r = go(e, 1n, 0n, plan_child(next))
                  go(schema, 0n, p, plan_next(next, r, end))
                case _: Refused{}
    case T.ProgressiveList{+e}:
      match phase:
        case 1n+q:
          match c:
            case Region{+n, +xs}:
              +cnt = list_count(S.fixed_size(e), n, xs)
              +m = counted(cnt)
              +ok = Bool.and(count_ok(cnt, None{}), sequence_ok(S.fixed_size(e), m, n))
              wrap_sequence(go(schema, q, m, layout(ok, Nat.mul(L.slot(S.fixed_size(e)), m), n, xs)))
            case _: Refused{}
        case 0n:
          match k:
            case 0n:
              match c:
                case Walk{fixed, prior, other, +pos, +end, acc}: close(settle(prior, fixed, other, acc), pos, end)
                case _: Refused{}
            case 1n+p:
              match c:
                case Walk{fixed, prior, other, +pos, +end, acc}:
                  +next = plan(settle(prior, fixed, other, acc), S.fixed_size(e), pos, end, Remaining{p})
                  r = go(e, 1n, 0n, plan_child(next))
                  go(schema, 0n, p, plan_next(next, r, end))
                case _: Refused{}
    case T.Container{names, +fields}:
      match c:
        case Region{+n, +xs}: wrap_sequence(go(fields, 0n, 0n, layout(Bool.and(fits(n), nat_le(header_size(fields), n)), header_size(fields), n, xs)))
        case _: Refused{}
    case T.ProgressiveContainer{names, +fields, active}:
      match c:
        case Region{+n, +xs}: wrap_sequence(go(fields, 0n, 0n, layout(Bool.and(fits(n), nat_le(header_size(fields), n)), header_size(fields), n, xs)))
        case _: Refused{}
    case T.Chain{+h, +t}:
      match k:
        case 0n:
          match c:
            case Walk{fixed, prior, other, +pos, +end, acc}:
              +next = plan(settle(prior, fixed, other, acc), S.fixed_size(h), pos, end, Later{t})
              r = go(h, 1n, 0n, plan_child(next))
              go(t, 0n, 0n, plan_next(next, r, end))
            case Pick{selector, n, xs}: wrap_selected(selector, go(h, 1n, 0n, Region{n, xs}))
            case PickAmong{selectors, +selector, +n, +xs}:
              match selectors:
                case Nil{}: Refused{}
                case Con{s, rest}:
                  +hit = U32.is_eq(s, selector)
                  r = go(h, 1n, 0n, among_here(hit, n, xs))
                  among(hit, selector, r, go(t, 0n, 0n, among_later(hit, rest, selector, n, xs)))
            case _: Refused{}
        case 1n+p:
          match c:
            case Pick{selector, n, xs}: go(t, 0n, p, Pick{selector, n, xs})
            case _: Refused{}
    case T.End{}:
      match c:
        case Walk{fixed, prior, other, +pos, +end, acc}: close(settle(prior, fixed, other, acc), pos, end)
        case _: Refused{}
    case T.Union{+options}:
      match c:
        case Region{n, xs}:
          +start = union_start(n, xs)
          go(options, 0n, selector_index(start), start)
        case _: Refused{}
    case T.CompatibleUnion{selectors, +options}:
      match c:
        case Region{n, xs}: go(options, 0n, 0n, among_start(selectors, n, xs))
        case _: Refused{}
    case _: Refused{}

# ---------------------------------------------------------------------------
# Public entry: type legality first, then one measuring pass (length and byte
# domain), then the decoder over the whole input as one region.
def result(r: Out) -> Maybe<&2, C.CValue>:
  match r:
    case Parsed{v, rest}: Some{v}
    case _: None{}

# One pass builds the packed storage, the byte count and the byte-domain
# check; a region is opened only if every input element is a byte.
def measured(p: Pack.Packing, +schema: T.Schema) -> Maybe<&2, C.CValue>:
  match p:
    case Pack.Packing{+n, ok, chunks}:
      result(go(schema, 1n, 0n, region_if(ok, n, Pack.Slice{chunks, 0n, n})))

def gate(ok: Bool, next: Unit -> Maybe<&2, C.CValue>) -> Maybe<&2, C.CValue>:
  match ok:
    case False{}: None{}
    case True{}: next(Unit{})

# The list entry point packs its input first, checking the byte domain.
def decode(+schema: T.Schema, +xs: +List<U32>) -> Maybe<&2, C.CValue>:
  gate(S.valid(schema), u => measured(Pack.pack_list(xs), schema))

# The neutral-representation entry point is the compact decoder composed with
# the compact-to-neutral view.
def deserialize(+schema: T.Schema, +xs: +List<U32>) -> Maybe<&2, T.Value>:
  C.result(decode(schema, xs))

# ---------------------------------------------------------------------------
# Byte equality and the canonical filter.
#
# These are the compatibility surface the canonicality laws are stated over.
# The decoder itself never re-serializes: `accepted_serializes` (proofs/
# decode_top.bend) derives the same guarantee from the structural checks, and
# `canonical` is retained as a proved filter for callers that want to state
# canonicality directly.
def equal_bytes_go(a: +List<U32>, b: +List<U32>, ok: Bool) -> Bool:
  match a b:
    case Nil{} Nil{}: ok
    case Nil{} Con{y, ys}: False{}
    case Con{x, xs} Nil{}: False{}
    case Con{x, xs} Con{y, ys}: equal_bytes_go(xs, ys, Bool.and(ok, U32.is_eq(x, y)))

def equal_bytes(a: +List<U32>, b: +List<U32>) -> Bool: equal_bytes_go(a, b, True{})

def value_result(ok: Bool, r: Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match ok:
    case False{}: None{}
    case True{}: r

def value_gate(ok: Bool, value: T.Value) -> Maybe<&2, T.Value>:
  match ok:
    case False{}: None{}
    case True{}: Some{value}

def canonical_bytes(encoded: Maybe<&2, +List<U32>>, input: +List<U32>, value: T.Value) -> Maybe<&2, T.Value>:
  match encoded:
    case None{}: None{}
    case Some{xs}: value_gate(equal_bytes(xs, input), value)

def canonical(result: Maybe<&2, T.Value>, schema: T.Schema, input: +List<U32>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{+value}: canonical_bytes(Codec.serialize(schema, value), input, value)
