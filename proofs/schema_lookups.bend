import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/bitfields.bend as IBits
import ../spec/schema.bend as SS
import ../spec/primitives.bend as SP
import ../spec/bitfields.bend as SBits
import ../spec/nat_bytes.bend as N
import ./layout_image.bend as Image
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ../spec/layout.bend as E
import ./decode_facts.bend as F
import ./layout.bend as Layout
import ./u32_order.bend as U32Order

# Schema-side facts shared by the root proofs and the decoder proofs.
#
# Nothing here mentions a decoder: these are statements about the frozen
# schema module - which option a union selector names, how option indices
# shift and widen, that a validated vector's contents satisfy the independent
# vector predicate, and the byte length a layout occupies. They were first
# proved inside the layout-decoder development; the root development needs
# exactly these, so they live in their own module and neither development
# depends on the other.

law vector_valid_of:
  for +n: Nat
  for +bits: +List<Bool>
  for e: {SBits.vector_domain(n, bits) == True{} : Bool}
  {IBits.vector_valid(n, bits) == True{} : Bool}
def vector_valid_of(n, bits, e):
  match n:
    case 0n: Empty.absurd({IBits.vector_valid(0n, bits) == True{} : Bool}, W.false_true(e))
    case 1n+p: e


law layout_bytes:
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {SP.bytes_domain(bytes) == True{} : Bool}
def layout_bytes(cps, bytes, encoded):
  %Image.optional_output(Bool.and(E.bytes_valid(cps), N.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))))), List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps)), bytes, encoded) : {SP.bytes_domain(_) == True{} : Bool}
  %Equal.sym(Bool, SP.bytes_domain(List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps))), E.bytes_valid(cps), Layout.output_domain(cps, E.fixed_size(cps))) : {_ == True{} : Bool}
  V.and_left(E.bytes_valid(cps), N.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps)))), Image.optional_valid(Bool.and(E.bytes_valid(cps), N.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))))), List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps)), bytes, encoded))


def option_ok(s: T.Schema) -> Bool:
  match s:
    case T.Null{}: True{}
    case _: I.valid_go(s, False{})


def selection(sel: U32, found: Maybe<&2, T.Schema>) -> Type:
  match found:
    case None{}: Unit
    case Some{s}: {option_ok(s) == True{} : Bool} & {U32.is_lt(sel, 256) == True{} : Bool}


law lt_le:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for ab: {Nat.is_lt(a, b) == True{} : Bool}
  for bc: {Nat.is_le(b, c) == True{} : Bool}
  {Nat.is_lt(a, c) == True{} : Bool}
def lt_le(a, b, c, ab, bc):
  match a:
    case 0n:
      match b:
        case 0n: Empty.absurd({Nat.is_lt(0n, c) == True{} : Bool}, W.false_true(ab))
        case 1n+q:
          match c:
            case 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, W.false_true(bc))
            case 1n+r: {==}
    case 1n+p:
      match b:
        case 0n: Empty.absurd({Nat.is_lt(1n+p, c) == True{} : Bool}, W.false_true(ab))
        case 1n+q:
          match c:
            case 0n: Empty.absurd({Nat.is_lt(1n+p, 0n) == True{} : Bool}, W.false_true(bc))
            case 1n+r: lt_le(p, q, r, ab, bc)


law u32_below:
  for +x: U32
  for +limit: U32
  for +bound: Nat
  for small: {Nat.is_lt(U32.to_nat(x), bound) == True{} : Bool}
  for fits: {Nat.is_le(bound, U32.to_nat(limit)) == True{} : Bool}
  {U32.is_lt(x, limit) == True{} : Bool}
def u32_below(x, limit, bound, small, fits):
  %Equal.sym(Bool, U32.is_lt(x, limit), Nat.is_lt(U32.to_nat(x), U32.to_nat(limit)), U32Order.u32_less(x, limit)) : {_ == True{} : Bool}
  lt_le(U32.to_nat(x), bound, U32.to_nat(limit), small, fits)


law u32_widen:
  for +h: U32
  for small: {U32.is_lt(h, 128) == True{} : Bool}
  {U32.is_lt(h, 256) == True{} : Bool}
def u32_widen(h, small):
  u32_below(h, 256, 128n,
    %U32Order.u32_less(h, 128) : {_ == True{} : Bool}
    small, {==})

# Accumulated forest decoding (Chain and Repeat share the actual step shape).

def index_fact(j: Nat, c: Nat, found: Maybe<&2, T.Schema>) -> Type:
  match found:
    case None{}: Unit
    case Some{s}: {option_ok(s) == True{} : Bool} & {Nat.is_lt(j, c) == True{} : Bool}


law index_shift:
  for +j: Nat
  for +c: Nat
  for +found: Maybe<&2, T.Schema>
  for known: index_fact(j, c, found)
  index_fact(1n+j, 1n+c, found)
def index_shift(j, c, found, known):
  match found:
    case None{}: Unit{}
    case Some{s}: known


law index_widen:
  for +j: Nat
  for +c: Nat
  for +found: Maybe<&2, T.Schema>
  for known: index_fact(j, c, found)
  for +bound: {Nat.is_le(c, 127n) == True{} : Bool}
  index_fact(1n+j, 128n, found)
def index_widen(j, c, found, known, bound):
  match found:
    case None{}: Unit{}
    case Some{s}:
      (valid, less) = known
      (valid, lt_le(j, c, 127n, less, bound))


law index_selection:
  for +sel: U32
  for +found: Maybe<&2, T.Schema>
  for known: index_fact(U32.to_nat(sel), 128n, found)
  selection(sel, found)
def index_selection(sel, found, known):
  match found:
    case None{}: Unit{}
    case Some{s}:
      (valid, less) = known
      (valid, u32_below(sel, 256, 128n, less, {==}))


law compat_select:
  for +found: Bool
  for +h: U32
  for +sel: U32
  for +o: T.Schema
  for +rest: Maybe<&2, T.Schema>
  for +same: {U32.is_eq(h, sel) == found : Bool}
  for +small: {U32.is_lt(h, 256) == True{} : Bool}
  for +valid: {option_ok(o) == True{} : Bool}
  for known: selection(sel, rest)
  selection(sel, SS.selected(found, o, rest))
def compat_select(found, h, sel, o, rest, same, small, valid, known):
  match found:
    case False{}: known
    case True{}:
      (valid, %W.u32_equal_sound(h, sel, same) : {U32.is_lt(_, 256) == True{} : Bool}
       small)

law ok_of_option:
  for +schema: T.Schema
  for legal: {option_ok(schema) == True{} : Bool}
  {F.ok(schema) == True{} : Bool}
def ok_of_option(schema, legal):
  match schema:
    case T.Boolean{}: legal
    case T.Unsigned{s0}: legal
    case T.ByteVector{s0}: legal
    case T.ByteList{s0}: legal
    case T.BitVector{s0}: legal
    case T.BitList{s0}: legal
    case T.Vector{s0, s1}: legal
    case T.ListOf{s0, s1}: legal
    case T.Container{s0, s1}: legal
    case T.Union{s0}: legal
    case T.Null{}: {==}
    case T.Chain{s0, s1}: Empty.absurd({F.ok(T.Chain{s0, s1}) == True{} : Bool}, W.false_true(legal))
    case T.End{}: Empty.absurd({F.ok(T.End{}) == True{} : Bool}, W.false_true(legal))
    case T.Repeat{s0}: Empty.absurd({F.ok(T.Repeat{s0}) == True{} : Bool}, W.false_true(legal))
    case T.Named{s0, s1}: legal
    case T.ProgressiveList{s0}: legal
    case T.ProgressiveBits{}: legal
    case T.ProgressiveContainer{s0, s1, s2}: legal
    case T.CompatibleUnion{s0, s1}: legal


law single_option_ok:
  for +schema: T.Schema
  for legal: {I.valid_go(schema, False{}) == True{} : Bool}
  {option_ok(schema) == True{} : Bool}
def single_option_ok(schema, legal):
  match schema:
    case T.Boolean{}: legal
    case T.Unsigned{s0}: legal
    case T.ByteVector{s0}: legal
    case T.ByteList{s0}: legal
    case T.BitVector{s0}: legal
    case T.BitList{s0}: legal
    case T.Vector{s0, s1}: legal
    case T.ListOf{s0, s1}: legal
    case T.Container{s0, s1}: legal
    case T.Union{s0}: legal
    case T.Null{}: {==}
    case T.Chain{s0, s1}: legal
    case T.End{}: legal
    case T.Repeat{s0}: legal
    case T.Named{s0, s1}: legal
    case T.ProgressiveList{s0}: legal
    case T.ProgressiveBits{}: legal
    case T.ProgressiveContainer{s0, s1, s2}: legal
    case T.CompatibleUnion{s0, s1}: legal


law forest_lookup:
  for +schema: T.Schema
  for +j: Nat
  for +legal: {I.valid_go(schema, True{}) == True{} : Bool}
  index_fact(j, I.count(schema), SS.option(schema, j))
def forest_lookup(schema, j, legal):
  match schema:
    case T.Boolean{}: Unit{}
    case T.Unsigned{s0}: Unit{}
    case T.ByteVector{s0}: Unit{}
    case T.ByteList{s0}: Unit{}
    case T.BitVector{s0}: Unit{}
    case T.BitList{s0}: Unit{}
    case T.Vector{s0, s1}: Unit{}
    case T.ListOf{s0, s1}: Unit{}
    case T.Container{s0, s1}: Unit{}
    case T.Union{s0}: Unit{}
    case T.Null{}: Unit{}
    case T.Chain{s0, s1}:
      match j:
        case 0n: (single_option_ok(s0, V.and_left(I.valid_go(s0, False{}), I.valid_go(s1, True{}), legal)), {==})
        case 1n+q: index_shift(q, I.count(s1), SS.option(s1, q), forest_lookup(s1, q, V.and_right(I.valid_go(s0, False{}), I.valid_go(s1, True{}), legal)))
    case T.End{}: Unit{}
    case T.Repeat{s0}: Unit{}
    case T.Named{s0, s1}: Unit{}
    case T.ProgressiveList{s0}: Unit{}
    case T.ProgressiveBits{}: Unit{}
    case T.ProgressiveContainer{s0, s1, s2}: Unit{}
    case T.CompatibleUnion{s0, s1}: Unit{}


law union_lookup:
  for +options: T.Schema
  for +i: Nat
  for +legal: {I.valid_go(T.Union{options}, False{}) == True{} : Bool}
  index_fact(i, 128n, SS.option(options, i))
def union_lookup(options, i, legal):
  match options:
    case T.Boolean{}: Unit{}
    case T.Unsigned{o0}: Unit{}
    case T.ByteVector{o0}: Unit{}
    case T.ByteList{o0}: Unit{}
    case T.BitVector{o0}: Unit{}
    case T.BitList{o0}: Unit{}
    case T.Vector{o0, o1}: Unit{}
    case T.ListOf{o0, o1}: Unit{}
    case T.Container{o0, o1}: Unit{}
    case T.Union{o0}: Unit{}
    case T.Null{}: Unit{}
    case T.Chain{o0, o1}:
      match o0:
        case T.Boolean{}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Boolean{}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Boolean{}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Boolean{}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Boolean{}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Boolean{}, False{}), I.valid_go(o1, True{})), legal))
        case T.Unsigned{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Unsigned{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Unsigned{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Unsigned{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Unsigned{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Unsigned{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.ByteVector{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.ByteVector{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ByteVector{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.ByteVector{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ByteVector{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ByteVector{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.ByteList{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.ByteList{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ByteList{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.ByteList{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ByteList{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ByteList{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.BitVector{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.BitVector{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.BitVector{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.BitVector{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.BitVector{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.BitVector{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.BitList{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.BitList{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.BitList{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.BitList{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.BitList{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.BitList{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.Vector{h0, h1}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Vector{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Vector{h0, h1}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Vector{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Vector{h0, h1}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Vector{h0, h1}, False{}), I.valid_go(o1, True{})), legal))
        case T.ListOf{h0, h1}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.ListOf{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ListOf{h0, h1}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.ListOf{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ListOf{h0, h1}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ListOf{h0, h1}, False{}), I.valid_go(o1, True{})), legal))
        case T.Container{h0, h1}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Container{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Container{h0, h1}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Container{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Container{h0, h1}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Container{h0, h1}, False{}), I.valid_go(o1, True{})), legal))
        case T.Union{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Union{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Union{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Union{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Union{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Union{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.Null{}:
          match i:
            case 0n: ({==}, {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(Nat.is_le(I.count(o1), 127n), I.valid_go(o1, True{}), V.and_right(Nat.is_lt(0n, I.count(o1)), Bool.and(Nat.is_le(I.count(o1), 127n), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), I.valid_go(o1, True{}), V.and_right(Nat.is_lt(0n, I.count(o1)), Bool.and(Nat.is_le(I.count(o1), 127n), I.valid_go(o1, True{})), legal)))
        case T.Chain{h0, h1}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Chain{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Chain{h0, h1}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Chain{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Chain{h0, h1}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Chain{h0, h1}, False{}), I.valid_go(o1, True{})), legal))
        case T.End{}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.End{}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.End{}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.End{}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.End{}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.End{}, False{}), I.valid_go(o1, True{})), legal))
        case T.Repeat{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Repeat{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Repeat{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Repeat{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Repeat{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Repeat{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.Named{h0, h1}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.Named{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Named{h0, h1}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.Named{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Named{h0, h1}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.Named{h0, h1}, False{}), I.valid_go(o1, True{})), legal))
        case T.ProgressiveList{h0}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.ProgressiveList{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveList{h0}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.ProgressiveList{h0}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveList{h0}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveList{h0}, False{}), I.valid_go(o1, True{})), legal))
        case T.ProgressiveBits{}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.ProgressiveBits{}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveBits{}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.ProgressiveBits{}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveBits{}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveBits{}, False{}), I.valid_go(o1, True{})), legal))
        case T.ProgressiveContainer{h0, h1, h2}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.ProgressiveContainer{h0, h1, h2}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveContainer{h0, h1, h2}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.ProgressiveContainer{h0, h1, h2}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveContainer{h0, h1, h2}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.ProgressiveContainer{h0, h1, h2}, False{}), I.valid_go(o1, True{})), legal))
        case T.CompatibleUnion{h0, h1}:
          match i:
            case 0n: (V.and_left(I.valid_go(T.CompatibleUnion{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.CompatibleUnion{h0, h1}, False{}), I.valid_go(o1, True{})), legal)), {==})
            case 1n+q: index_widen(q, I.count(o1), SS.option(o1, q), forest_lookup(o1, q, V.and_right(I.valid_go(T.CompatibleUnion{h0, h1}, False{}), I.valid_go(o1, True{}), V.and_right(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.CompatibleUnion{h0, h1}, False{}), I.valid_go(o1, True{})), legal))), V.and_left(Nat.is_le(I.count(o1), 127n), Bool.and(I.valid_go(T.CompatibleUnion{h0, h1}, False{}), I.valid_go(o1, True{})), legal))
    case T.End{}: Unit{}
    case T.Repeat{o0}: Unit{}
    case T.Named{o0, o1}: Unit{}
    case T.ProgressiveList{o0}: Unit{}
    case T.ProgressiveBits{}: Unit{}
    case T.ProgressiveContainer{o0, o1, o2}: Unit{}
    case T.CompatibleUnion{o0, o1}: Unit{}


law compatible_lookup:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +sel: U32
  for +seen: +List<U32>
  for +valid_selectors: {I.selectors_valid(selectors, seen) == True{} : Bool}
  for +valid_options: {I.valid_go(options, True{}) == True{} : Bool}
  selection(sel, SS.compatible_option(selectors, options, sel))
def compatible_lookup(selectors, options, sel, seen, valid_selectors, valid_options):
  match selectors:
    case Nil{}: Unit{}
    case Con{h, hs}:
      match options:
        case T.Boolean{}: Unit{}
        case T.Unsigned{o0}: Unit{}
        case T.ByteVector{o0}: Unit{}
        case T.ByteList{o0}: Unit{}
        case T.BitVector{o0}: Unit{}
        case T.BitList{o0}: Unit{}
        case T.Vector{o0, o1}: Unit{}
        case T.ListOf{o0, o1}: Unit{}
        case T.Container{o0, o1}: Unit{}
        case T.Union{o0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{o0, o1}: compat_select(U32.is_eq(h, sel), h, sel, o0, SS.compatible_option(hs, o1, sel), {==}, u32_widen(h, V.and_right(U32.is_lt(0, h), U32.is_lt(h, 128), V.and_left(Bool.and(U32.is_lt(0, h), U32.is_lt(h, 128)), Bool.and(Bool.not(I.has_selector(h, seen)), I.selectors_valid(hs, h <> seen)), valid_selectors))), single_option_ok(o0, V.and_left(I.valid_go(o0, False{}), I.valid_go(o1, True{}), valid_options)), compatible_lookup(hs, o1, sel, h <> seen, V.and_right(Bool.not(I.has_selector(h, seen)), I.selectors_valid(hs, h <> seen), V.and_right(Bool.and(U32.is_lt(0, h), U32.is_lt(h, 128)), Bool.and(Bool.not(I.has_selector(h, seen)), I.selectors_valid(hs, h <> seen)), valid_selectors)), V.and_right(I.valid_go(o0, False{}), I.valid_go(o1, True{}), valid_options)))
        case T.End{}: Unit{}
        case T.Repeat{o0}: Unit{}
        case T.Named{o0, o1}: Unit{}
        case T.ProgressiveList{o0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{o0, o1, o2}: Unit{}
        case T.CompatibleUnion{o0, o1}: Unit{}

