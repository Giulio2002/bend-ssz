import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Prim
import ../src/schema.bend as IS
import ../spec/codec.bend as SC
import ../spec/layout.bend as SL
import ../spec/schema.bend as SS
import ../spec/nat_bytes.bend as N
import ../spec/primitives.bend as SP
import ../spec/bytes.bend as SBytes
import ../spec/byte_list.bend as SByteList
import ../spec/bitfields.bend as SBits
import ../spec/bit_packing.bend as SPack
import ./complete_leaves.bend as CLeaf
import ./complete_regions.bend as CReg
import ./layout.bend as LA
import ./primitive_invariants.bend as V
import ./word_facts.bend as F
import ./uint_prefix.bend as RT
import ./bit_packing.bend as BitPack
import ./complete_decode.bend as CDec
import ./complete_walk.bend as CWalk
import ./u32_order.bend as U32Order
import ./nat_order.bend as NO
import ../src/bit_packing.bend as IPack
import ../src/lists.bend as Lists

# The byte domain of the canonical encoding.
#
# The public list entry point packs its input first, and the packer only opens
# a region when every element is a byte. Completeness therefore needs the
# converse of that check: the independent encoding of a value of a legal type
# is a byte string. Each leaf gate already carries its own domain condition;
# a layout carries `bytes_valid`; a union prepends its selector byte.
law scope_domain:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(n, xs) == True{} : Bool}
  {SP.bytes_domain(xs) == True{} : Bool}
def scope_domain(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: Empty.absurd({SP.bytes_domain(h <> t) == True{} : Bool}, F.false_true(e))
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}:
          V.and_true(U32.is_lt(h, 256), SP.bytes_domain(t),
            V.and_left(U32.is_lt(h, 256), SP.byte_scope(p, t), e),
            scope_domain(p, t, V.and_right(U32.is_lt(h, 256), SP.byte_scope(p, t), e)))

# A one-fragment encoding built from an `optional` gate.
law one_optional_domain:
  for +ok: Bool
  for +xs: +List<U32>
  for +w: Maybe<&2, Nat>
  for dom: {ok == True{} : Bool} -> {SP.bytes_domain(xs) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.one(SP.optional(ok, xs), w))) == True{} : Bool}
def one_optional_domain(ok, xs, w, dom):
  match ok:
    case False{}: {==}
    case True{}:
      match w:
        case Some{q}: dom({==})
        case None{}: dom({==})

law one_some_domain:
  for +xs: +List<U32>
  for +w: Maybe<&2, Nat>
  for +dom: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.one(Some{xs}, w))) == True{} : Bool}
def one_some_domain(xs, w, dom):
  match w:
    case Some{q}: dom
    case None{}: dom

# A layout encoding is the fixed region followed by the payloads, and its
# gate is exactly `bytes_valid`.
law layout_encoding_domain:
  for +ps: +List<T.Part>
  for +zs: +List<U32>
  for +same: {SL.encoding(ps) == Some{zs} : Maybe<&2, +List<U32>>}
  {SP.bytes_domain(zs) == True{} : Bool}
def layout_encoding_domain(ps, zs, same):
  +gate = CLeaf.facts_dom(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
    List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), zs,
    CLeaf.optional_some(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), zs, same))
  +layout = CLeaf.facts_bytes(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
    List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), zs,
    CLeaf.optional_some(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), zs, same))
  %layout : {SP.bytes_domain(_) == True{} : Bool}
  Equal.trans(Bool, SP.bytes_domain(List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Bool.and(SP.bytes_domain(SL.fixed_parts(ps, SL.fixed_size(ps))), SP.bytes_domain(SL.payloads(ps))), True{},
    LA.bytes_append(SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.trans(Bool, Bool.and(SP.bytes_domain(SL.fixed_parts(ps, SL.fixed_size(ps))), SP.bytes_domain(SL.payloads(ps))), SL.bytes_valid(ps), True{},
      LA.layout_domain(ps, SL.fixed_size(ps)),
      V.and_left(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), gate)))

law one_result_domain:
  for +enc: Maybe<&2, +List<U32>>
  for +w: Maybe<&2, Nat>
  for dom: @+zs: +List<U32> -> @+same: {enc == Some{zs} : Maybe<&2, +List<U32>>} -> {SP.bytes_domain(zs) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.one(enc, w))) == True{} : Bool}
def one_result_domain(enc, w, dom):
  match enc:
    case None{}: {==}
    case Some{zs}: one_some_domain(zs, w, dom(zs, {==}))

law aggregate_domain:
  for +r: Maybe<&2, +List<T.Part>>
  for +w: Maybe<&2, Nat>
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.aggregate(r, w))) == True{} : Bool}
def aggregate_domain(r, w):
  match r:
    case None{}: {==}
    case Some{ps}: one_result_domain(SL.encoding(ps), w, zs => same => layout_encoding_domain(ps, zs, same))

law require_domain:
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for dom: {SP.bytes_domain(CLeaf.fragment_bytes(r)) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.require(ok, r))) == True{} : Bool}
def require_domain(ok, r, dom):
  match ok:
    case False{}: {==}
    case True{}: dom

# Leaf gates.
law boolean_domain:
  for +b: Bool
  {SP.bytes_domain(SP.boolean_encoding(b)) == True{} : Bool}
def boolean_domain(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law vector_domain_bytes:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {SBytes.vector_domain(n, xs) == True{} : Bool}
  {SP.bytes_domain(xs) == True{} : Bool}
def vector_domain_bytes(n, xs, e):
  match n:
    case 0n: Empty.absurd({SP.bytes_domain(xs) == True{} : Bool}, F.false_true(e))
    case 1n+p:
      scope_domain(1n+p, xs, V.and_left(SP.byte_scope(1n+p, xs), SBytes.size_fits(1n+p), e))

law pack_domain:
  for +bits: +List<Bool>
  {SP.bytes_domain(SPack.pack(bits)) == True{} : Bool}
def pack_domain(bits):
  %BitPack.pack_correct(bits) : {SP.bytes_domain(_) == True{} : Bool}
  BitPack.pack_bytes(bits)

law bits_encoding_domain:
  for +ok: Bool
  for +bits: +List<Bool>
  for +w: Maybe<&2, Nat>
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.one(SBits.encoding(ok, bits), w))) == True{} : Bool}
def bits_encoding_domain(ok, bits, w):
  match ok:
    case False{}: {==}
    case True{}: one_some_domain(SPack.pack(bits), w, pack_domain(bits))

law tagged_domain:
  for +sel: U32
  for +content: Maybe<&2, +List<T.Part>>
  for +selok: {U32.is_lt(sel, 256) == True{} : Bool}
  for +dom: {SP.bytes_domain(CLeaf.fragment_bytes(content)) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.tagged(sel, content))) == True{} : Bool}
def tagged_domain(sel, content, selok, dom):
  match content:
    case Some{Con{T.Fixed{ys}, Nil{}}}: V.and_true(U32.is_lt(sel, 256), SP.bytes_domain(ys), selok, dom)
    case Some{Con{T.Variable{ys}, Nil{}}}: V.and_true(U32.is_lt(sel, 256), SP.bytes_domain(ys), selok, dom)
    case Some{Nil{}}: {==}
    case Some{Con{T.Fixed{ys}, Con{a, b}}}: {==}
    case Some{Con{T.Variable{ys}, Con{a, b}}}: {==}
    case None{}: {==}

law with_option_domain:
  for +r: Maybe<&2, T.Schema>
  for f: T.Schema -> Maybe<&2, +List<T.Part>>
  for dom: @+s: T.Schema -> @+same: {r == Some{s} : Maybe<&2, T.Schema>} -> {SP.bytes_domain(CLeaf.fragment_bytes(f(s))) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.with_option(r, f))) == True{} : Bool}
def with_option_domain(r, f, dom):
  match r:
    case None{}: {==}
    case Some{s}: dom(s, {==})

law lt_le_trans:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +lt: {Nat.is_lt(a, b) == True{} : Bool}
  for +le: {Nat.is_le(b, c) == True{} : Bool}
  {Nat.is_lt(a, c) == True{} : Bool}
def lt_le_trans(a, b, c, lt, le):
  match a:
    case 0n:
      match b:
        case 0n: Empty.absurd({Nat.is_lt(0n, c) == True{} : Bool}, F.false_true(lt))
        case 1n+q:
          match c:
            case 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, F.false_true(le))
            case 1n+r: {==}
    case 1n+p:
      match b:
        case 0n: Empty.absurd({Nat.is_lt(1n+p, c) == True{} : Bool}, F.false_true(lt))
        case 1n+q:
          match c:
            case 0n: Empty.absurd({Nat.is_lt(1n+p, 0n) == True{} : Bool}, F.false_true(le))
            case 1n+r: lt_le_trans(p, q, r, lt, le)

law option_index_bound:
  for +opts: T.Schema
  for +i: Nat
  for +s: T.Schema
  for +found: {SS.option(opts, i) == Some{s} : Maybe<&2, T.Schema>}
  {Nat.is_lt(i, IS.count(opts)) == True{} : Bool}
def option_index_bound(opts, i, s, found):
  match opts:
    case T.Chain{hh, tt}:
      match i:
        case 0n: {==}
        case 1n+p: option_index_bound(tt, p, s, found)
    case T.Boolean{}: Empty.absurd({Nat.is_lt(i, IS.count(T.Boolean{})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Boolean{}, i), Some{s}, found)))
    case T.Unsigned{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.Unsigned{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Unsigned{z0}, i), Some{s}, found)))
    case T.ByteVector{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.ByteVector{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteVector{z0}, i), Some{s}, found)))
    case T.ByteList{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.ByteList{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteList{z0}, i), Some{s}, found)))
    case T.BitVector{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.BitVector{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitVector{z0}, i), Some{s}, found)))
    case T.BitList{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.BitList{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitList{z0}, i), Some{s}, found)))
    case T.Vector{z0, z1}: Empty.absurd({Nat.is_lt(i, IS.count(T.Vector{z0, z1})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, i), Some{s}, found)))
    case T.ListOf{z0, z1}: Empty.absurd({Nat.is_lt(i, IS.count(T.ListOf{z0, z1})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, i), Some{s}, found)))
    case T.Container{z0, z1}: Empty.absurd({Nat.is_lt(i, IS.count(T.Container{z0, z1})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Container{z0, z1}, i), Some{s}, found)))
    case T.Union{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.Union{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Union{z0}, i), Some{s}, found)))
    case T.Null{}: Empty.absurd({Nat.is_lt(i, IS.count(T.Null{})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Null{}, i), Some{s}, found)))
    case T.End{}: Empty.absurd({Nat.is_lt(i, IS.count(T.End{})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.End{}, i), Some{s}, found)))
    case T.Repeat{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.Repeat{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Repeat{z0}, i), Some{s}, found)))
    case T.Named{z0, z1}: Empty.absurd({Nat.is_lt(i, IS.count(T.Named{z0, z1})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Named{z0, z1}, i), Some{s}, found)))
    case T.ProgressiveList{z0}: Empty.absurd({Nat.is_lt(i, IS.count(T.ProgressiveList{z0})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, i), Some{s}, found)))
    case T.ProgressiveBits{}: Empty.absurd({Nat.is_lt(i, IS.count(T.ProgressiveBits{})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveBits{}, i), Some{s}, found)))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({Nat.is_lt(i, IS.count(T.ProgressiveContainer{z0, z1, z2})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveContainer{z0, z1, z2}, i), Some{s}, found)))
    case T.CompatibleUnion{z0, z1}: Empty.absurd({Nat.is_lt(i, IS.count(T.CompatibleUnion{z0, z1})) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.CompatibleUnion{z0, z1}, i), Some{s}, found)))

# The option count of a legal union is at most 128, so its selector byte is a
# byte. The head is read separately because `Null` is allowed there.
law union_count_bound:
  for +opts: T.Schema
  for +legal: {IS.valid_go(T.Union{opts}, False{}) == True{} : Bool}
  {Nat.is_le(IS.count(opts), 128n) == True{} : Bool}
def union_count_bound(opts, legal):
  match opts:
    case T.Chain{z0, z1}:
      match z0:
        case T.Boolean{}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Unsigned{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Unsigned{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.ByteVector{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ByteVector{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.ByteList{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ByteList{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.BitVector{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.BitVector{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.BitList{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.BitList{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Vector{w0, w1}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Vector{w0, w1}, False{}), IS.valid_go(z1, True{})), legal)
        case T.ListOf{w0, w1}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ListOf{w0, w1}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Container{w0, w1}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Container{w0, w1}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Union{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Union{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Null{}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), IS.valid_go(z1, True{}), V.and_right(Nat.is_lt(0n, IS.count(z1)), Bool.and(Nat.is_le(IS.count(z1), 127n), IS.valid_go(z1, True{})), legal))
        case T.Chain{w0, w1}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Chain{w0, w1}, False{}), IS.valid_go(z1, True{})), legal)
        case T.End{}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.End{}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Repeat{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Repeat{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.Named{w0, w1}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Named{w0, w1}, False{}), IS.valid_go(z1, True{})), legal)
        case T.ProgressiveList{w0}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveList{w0}, False{}), IS.valid_go(z1, True{})), legal)
        case T.ProgressiveBits{}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(z1, True{})), legal)
        case T.ProgressiveContainer{w0, w1, w2}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveContainer{w0, w1, w2}, False{}), IS.valid_go(z1, True{})), legal)
        case T.CompatibleUnion{w0, w1}:
          V.and_left(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.CompatibleUnion{w0, w1}, False{}), IS.valid_go(z1, True{})), legal)
    case T.Boolean{}: Empty.absurd({Nat.is_le(IS.count(T.Boolean{}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Unsigned{z0}: Empty.absurd({Nat.is_le(IS.count(T.Unsigned{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.ByteVector{z0}: Empty.absurd({Nat.is_le(IS.count(T.ByteVector{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.ByteList{z0}: Empty.absurd({Nat.is_le(IS.count(T.ByteList{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.BitVector{z0}: Empty.absurd({Nat.is_le(IS.count(T.BitVector{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.BitList{z0}: Empty.absurd({Nat.is_le(IS.count(T.BitList{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Vector{z0, z1}: Empty.absurd({Nat.is_le(IS.count(T.Vector{z0, z1}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.ListOf{z0, z1}: Empty.absurd({Nat.is_le(IS.count(T.ListOf{z0, z1}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Container{z0, z1}: Empty.absurd({Nat.is_le(IS.count(T.Container{z0, z1}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Union{z0}: Empty.absurd({Nat.is_le(IS.count(T.Union{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Null{}: Empty.absurd({Nat.is_le(IS.count(T.Null{}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.End{}: Empty.absurd({Nat.is_le(IS.count(T.End{}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Repeat{z0}: Empty.absurd({Nat.is_le(IS.count(T.Repeat{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.Named{z0, z1}: Empty.absurd({Nat.is_le(IS.count(T.Named{z0, z1}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveList{z0}: Empty.absurd({Nat.is_le(IS.count(T.ProgressiveList{z0}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveBits{}: Empty.absurd({Nat.is_le(IS.count(T.ProgressiveBits{}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({Nat.is_le(IS.count(T.ProgressiveContainer{z0, z1, z2}), 128n) == True{} : Bool}, F.false_true(legal))
    case T.CompatibleUnion{z0, z1}: Empty.absurd({Nat.is_le(IS.count(T.CompatibleUnion{z0, z1}), 128n) == True{} : Bool}, F.false_true(legal))

law u32_below:
  for +a: U32
  for +b: U32
  for +c: U32
  for +lt: {U32.is_lt(a, b) == True{} : Bool}
  for +le: {Nat.is_le(U32.to_nat(b), U32.to_nat(c)) == True{} : Bool}
  {U32.is_lt(a, c) == True{} : Bool}
def u32_below(a, b, c, lt, le):
  Equal.trans(Bool, U32.is_lt(a, c), Nat.is_lt(U32.to_nat(a), U32.to_nat(c)), True{},
    U32Order.u32_less(a, c),
    lt_le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(c),
      Equal.trans(Bool, Nat.is_lt(U32.to_nat(a), U32.to_nat(b)), U32.is_lt(a, b), True{},
        Equal.sym(Bool, U32.is_lt(a, b), Nat.is_lt(U32.to_nat(a), U32.to_nat(b)), U32Order.u32_less(a, b)),
        lt),
      le))

law union_selector_bound:
  for +opts: T.Schema
  for +sel: U32
  for +s: T.Schema
  for +legal: {IS.valid_go(T.Union{opts}, False{}) == True{} : Bool}
  for +found: {SS.option(opts, U32.to_nat(sel)) == Some{s} : Maybe<&2, T.Schema>}
  {U32.is_lt(sel, 256) == True{} : Bool}
def union_selector_bound(opts, sel, s, legal, found):
  Equal.trans(Bool, U32.is_lt(sel, 256), Nat.is_lt(U32.to_nat(sel), U32.to_nat(256)), True{},
    U32Order.u32_less(sel, 256),
    lt_le_trans(U32.to_nat(sel), IS.count(opts), U32.to_nat(256),
      option_index_bound(opts, U32.to_nat(sel), s, found),
      NO.transitive(IS.count(opts), 128n, U32.to_nat(256), union_count_bound(opts, legal), {==})))

law compatible_selector_at:
  for +hit: Bool
  for +h: U32
  for +sel: U32
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +s: T.Schema
  for +hvalid: {U32.is_lt(h, 128) == True{} : Bool}
  for +iseq: {U32.is_eq(h, sel) == hit : Bool}
  for +found: {SS.selected(hit, hh, SS.compatible_option(rest, tt, sel)) == Some{s} : Maybe<&2, T.Schema>}
  for rec: @+f2: {SS.compatible_option(rest, tt, sel) == Some{s} : Maybe<&2, T.Schema>} -> {U32.is_lt(sel, 256) == True{} : Bool}
  {U32.is_lt(sel, 256) == True{} : Bool}
def compatible_selector_at(hit, h, sel, hh, tt, rest, s, hvalid, iseq, found, rec):
  match hit:
    case True{}:
      %F.u32_equal_sound(h, sel, iseq) : {U32.is_lt(_, 256) == True{} : Bool}
      u32_below(h, 128, 256, hvalid, {==})
    case False{}: rec(found)

law compatible_selector_bound:
  for +sels: +List<U32>
  for +opts: T.Schema
  for +sel: U32
  for +s: T.Schema
  for +seen: +List<U32>
  for +svalid: {IS.selectors_valid(sels, seen) == True{} : Bool}
  for +found: {SS.compatible_option(sels, opts, sel) == Some{s} : Maybe<&2, T.Schema>}
  {U32.is_lt(sel, 256) == True{} : Bool}
def compatible_selector_bound(sels, opts, sel, s, seen, svalid, found):
  match sels:
    case Nil{}:
      Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool},
        F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], opts, sel), Some{s}, found)))
    case Con{h, t}:
      match opts:
        case T.Chain{z0, z1}:
          compatible_selector_at(U32.is_eq(h, sel), h, sel, z0, z1, t, s, V.and_right(U32.is_lt(0, h), U32.is_lt(h, 128), V.and_left(Bool.and(U32.is_lt(0, h), U32.is_lt(h, 128)), Bool.and(Bool.not(IS.has_selector(h, seen)), IS.selectors_valid(t, h <> seen)), svalid)), {==}, found,
            f2 => compatible_selector_bound(t, z1, sel, s, h <> seen, V.and_right(Bool.not(IS.has_selector(h, seen)), IS.selectors_valid(t, h <> seen), V.and_right(Bool.and(U32.is_lt(0, h), U32.is_lt(h, 128)), Bool.and(Bool.not(IS.has_selector(h, seen)), IS.selectors_valid(t, h <> seen)), svalid)), f2))
        case T.Boolean{}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Boolean{}, sel), Some{s}, found)))
        case T.Unsigned{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Unsigned{z0}, sel), Some{s}, found)))
        case T.ByteVector{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ByteVector{z0}, sel), Some{s}, found)))
        case T.ByteList{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ByteList{z0}, sel), Some{s}, found)))
        case T.BitVector{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.BitVector{z0}, sel), Some{s}, found)))
        case T.BitList{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.BitList{z0}, sel), Some{s}, found)))
        case T.Vector{z0, z1}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Vector{z0, z1}, sel), Some{s}, found)))
        case T.ListOf{z0, z1}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ListOf{z0, z1}, sel), Some{s}, found)))
        case T.Container{z0, z1}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Container{z0, z1}, sel), Some{s}, found)))
        case T.Union{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Union{z0}, sel), Some{s}, found)))
        case T.Null{}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Null{}, sel), Some{s}, found)))
        case T.End{}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.End{}, sel), Some{s}, found)))
        case T.Repeat{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Repeat{z0}, sel), Some{s}, found)))
        case T.Named{z0, z1}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Named{z0, z1}, sel), Some{s}, found)))
        case T.ProgressiveList{z0}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ProgressiveList{z0}, sel), Some{s}, found)))
        case T.ProgressiveBits{}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ProgressiveBits{}, sel), Some{s}, found)))
        case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ProgressiveContainer{z0, z1, z2}, sel), Some{s}, found)))
        case T.CompatibleUnion{z0, z1}: Empty.absurd({U32.is_lt(sel, 256) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.CompatibleUnion{z0, z1}, sel), Some{s}, found)))

law option_region_legal:
  for +opts: T.Schema
  for +i: Nat
  for +s: T.Schema
  for +legal: {CDec.opts_legal(opts) == True{} : Bool}
  for +found: {SS.option(opts, i) == Some{s} : Maybe<&2, T.Schema>}
  {CReg.region_legal(s) == True{} : Bool}
def option_region_legal(opts, i, s, legal, found):
  match opts:
    case T.Chain{hh, tt}:
      match i:
        case 0n:
          %Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, hh), Some{hh}, Some{s}, found) : {CReg.region_legal(_) == True{} : Bool}
          V.and_left(CReg.region_legal(hh), CDec.opts_legal(tt), legal)
        case 1n+p: option_region_legal(tt, p, s, V.and_right(CReg.region_legal(hh), CDec.opts_legal(tt), legal), found)
    case T.Boolean{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Boolean{}, i), Some{s}, found)))
    case T.Unsigned{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Unsigned{z0}, i), Some{s}, found)))
    case T.ByteVector{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteVector{z0}, i), Some{s}, found)))
    case T.ByteList{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteList{z0}, i), Some{s}, found)))
    case T.BitVector{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitVector{z0}, i), Some{s}, found)))
    case T.BitList{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitList{z0}, i), Some{s}, found)))
    case T.Vector{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, i), Some{s}, found)))
    case T.ListOf{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, i), Some{s}, found)))
    case T.Container{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Container{z0, z1}, i), Some{s}, found)))
    case T.Union{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Union{z0}, i), Some{s}, found)))
    case T.Null{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Null{}, i), Some{s}, found)))
    case T.End{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.End{}, i), Some{s}, found)))
    case T.Repeat{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Repeat{z0}, i), Some{s}, found)))
    case T.Named{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Named{z0, z1}, i), Some{s}, found)))
    case T.ProgressiveList{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, i), Some{s}, found)))
    case T.ProgressiveBits{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveBits{}, i), Some{s}, found)))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveContainer{z0, z1, z2}, i), Some{s}, found)))
    case T.CompatibleUnion{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.CompatibleUnion{z0, z1}, i), Some{s}, found)))

law compatible_region_legal_at:
  for +hit: Bool
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +sel: U32
  for +s: T.Schema
  for +hlegal: {CReg.region_legal(hh) == True{} : Bool}
  for +found: {SS.selected(hit, hh, SS.compatible_option(rest, tt, sel)) == Some{s} : Maybe<&2, T.Schema>}
  for rec: @+f2: {SS.compatible_option(rest, tt, sel) == Some{s} : Maybe<&2, T.Schema>} -> {CReg.region_legal(s) == True{} : Bool}
  {CReg.region_legal(s) == True{} : Bool}
def compatible_region_legal_at(hit, hh, tt, rest, sel, s, hlegal, found, rec):
  match hit:
    case True{}:
      %Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, hh), Some{hh}, Some{s}, found) : {CReg.region_legal(_) == True{} : Bool}
      hlegal
    case False{}: rec(found)

law compatible_region_legal:
  for +sels: +List<U32>
  for +opts: T.Schema
  for +sel: U32
  for +s: T.Schema
  for +legal: {CDec.opts_legal(opts) == True{} : Bool}
  for +found: {SS.compatible_option(sels, opts, sel) == Some{s} : Maybe<&2, T.Schema>}
  {CReg.region_legal(s) == True{} : Bool}
def compatible_region_legal(sels, opts, sel, s, legal, found):
  match sels:
    case Nil{}:
      Empty.absurd({CReg.region_legal(s) == True{} : Bool},
        F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], opts, sel), Some{s}, found)))
    case Con{h, t}:
      match opts:
        case T.Chain{z0, z1}:
          compatible_region_legal_at(U32.is_eq(h, sel), z0, z1, t, sel, s,
            V.and_left(CReg.region_legal(z0), CDec.opts_legal(z1), legal), found,
            f2 => compatible_region_legal(t, z1, sel, s, V.and_right(CReg.region_legal(z0), CDec.opts_legal(z1), legal), f2))
        case T.Boolean{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Boolean{}, sel), Some{s}, found)))
        case T.Unsigned{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Unsigned{z0}, sel), Some{s}, found)))
        case T.ByteVector{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ByteVector{z0}, sel), Some{s}, found)))
        case T.ByteList{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ByteList{z0}, sel), Some{s}, found)))
        case T.BitVector{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.BitVector{z0}, sel), Some{s}, found)))
        case T.BitList{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.BitList{z0}, sel), Some{s}, found)))
        case T.Vector{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Vector{z0, z1}, sel), Some{s}, found)))
        case T.ListOf{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ListOf{z0, z1}, sel), Some{s}, found)))
        case T.Container{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Container{z0, z1}, sel), Some{s}, found)))
        case T.Union{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Union{z0}, sel), Some{s}, found)))
        case T.Null{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Null{}, sel), Some{s}, found)))
        case T.End{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.End{}, sel), Some{s}, found)))
        case T.Repeat{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Repeat{z0}, sel), Some{s}, found)))
        case T.Named{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.Named{z0, z1}, sel), Some{s}, found)))
        case T.ProgressiveList{z0}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ProgressiveList{z0}, sel), Some{s}, found)))
        case T.ProgressiveBits{}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ProgressiveBits{}, sel), Some{s}, found)))
        case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.ProgressiveContainer{z0, z1, z2}, sel), Some{s}, found)))
        case T.CompatibleUnion{z0, z1}: Empty.absurd({CReg.region_legal(s) == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(h <> t, T.CompatibleUnion{z0, z1}, sel), Some{s}, found)))

# The canonical encoding of a value of a legal type is a byte string. The
# recursion is on the value, so a union descends into the selected option.
law parts_domain:
  for +value: T.Value
  for +schema: T.Schema
  for +legal: {CReg.region_legal(schema) == True{} : Bool}
  {SP.bytes_domain(CLeaf.fragment_bytes(SC.parts(value, schema))) == True{} : Bool}
def parts_domain(value, schema, legal):
  match value:
    case T.BooleanValue{b0}:
      match schema:
        case T.Boolean{}:
          boolean_domain(b0)
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.UnsignedValue{u0}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          one_optional_domain(SP.uint_domain(z0, u0), SP.prefix(SP.byte_width(z0), SP.full_digits(u0)), Some{SP.byte_width(z0)}, e => RT.uint_prefix_domain(z0, u0, e))
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.BytesValue{y0}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          one_optional_domain(SBytes.vector_domain(z0, y0), y0, Some{z0}, e => vector_domain_bytes(z0, y0, e))
        case T.ByteList{z0}:
          one_optional_domain(SByteList.domain(z0, y0), y0, None{}, e => V.and_left(SP.bytes_domain(y0), Nat.is_le(List.length(&2, U32, y0), z0), V.and_left(Bool.and(SP.bytes_domain(y0), Nat.is_le(List.length(&2, U32, y0), z0)), N.fits(4n, List.length(&2, U32, y0)), e)))
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.BitsValue{q0}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          bits_encoding_domain(SBits.vector_domain(z0, q0), q0, Some{Nat.div(Nat.add(z0, 7n), 8n)})
        case T.BitList{z0}:
          bits_encoding_domain(SBits.list_domain(z0, q0), List.append(&2, Bool, q0, [True{}]), None{})
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          bits_encoding_domain(SBits.list_domain(List.length(&2, Bool, q0), q0), List.append(&2, Bool, q0, [True{}]), None{})
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.Sequence{i0}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          require_domain(Bool.and(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1)), SC.aggregate(SC.parts(i0, T.Repeat{z0}), SS.times(z1, SS.fixed_size(z0))), aggregate_domain(SC.parts(i0, T.Repeat{z0}), SS.times(z1, SS.fixed_size(z0))))
        case T.ListOf{z0, z1}:
          require_domain(Nat.is_le(SC.count(i0), z1), SC.aggregate(SC.parts(i0, T.Repeat{z0}), None{}), aggregate_domain(SC.parts(i0, T.Repeat{z0}), None{}))
        case T.Container{z0, z1}:
          aggregate_domain(SC.parts(i0, z1), SS.fixed_size(z1))
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          aggregate_domain(SC.parts(i0, T.Repeat{z0}), None{})
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          aggregate_domain(SC.parts(i0, z1), SS.fixed_size(z1))
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.Items{i0, i1}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          Empty.absurd({SP.bytes_domain(CLeaf.fragment_bytes(SC.parts(T.Items{i0, i1}, T.Chain{z0, z1}))) == True{} : Bool}, F.false_true(legal))
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          Empty.absurd({SP.bytes_domain(CLeaf.fragment_bytes(SC.parts(T.Items{i0, i1}, T.Repeat{z0}))) == True{} : Bool}, F.false_true(legal))
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.EmptyItems{}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
    case T.Selected{v0, m0}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          with_option_domain(SS.option(z0, U32.to_nat(v0)), s => SC.tagged(v0, SC.parts(m0, s)),
          s2 => same2 => tagged_domain(v0, SC.parts(m0, s2),
            union_selector_bound(z0, v0, s2, legal, same2),
            parts_domain(m0, s2, option_region_legal(z0, U32.to_nat(v0), s2, CDec.union_opts_legal(z0, legal), same2))))
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          with_option_domain(SS.compatible_option(z0, z1, v0), s => SC.tagged(v0, SC.parts(m0, s)),
          s2 => same2 => tagged_domain(v0, SC.parts(m0, s2),
            compatible_selector_bound(z0, z1, v0, s2, [], V.and_left(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)), V.and_right(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1))), V.and_right(Nat.is_lt(0n, IS.count(z1)), Bool.and(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)))), legal))), same2),
            parts_domain(m0, s2, compatible_region_legal(z0, z1, v0, s2, CDec.forest_opts_legal(z1, V.and_left(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1), V.and_right(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)), V.and_right(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1))), V.and_right(Nat.is_lt(0n, IS.count(z1)), Bool.and(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)))), legal))))), same2))))
    case T.NullValue{}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{z0}:
          {==}
        case T.ByteVector{z0}:
          {==}
        case T.ByteList{z0}:
          {==}
        case T.BitVector{z0}:
          {==}
        case T.BitList{z0}:
          {==}
        case T.Vector{z0, z1}:
          {==}
        case T.ListOf{z0, z1}:
          {==}
        case T.Container{z0, z1}:
          {==}
        case T.Union{z0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{z0, z1}:
          {==}
        case T.End{}:
          {==}
        case T.Repeat{z0}:
          {==}
        case T.Named{z0, z1}:
          {==}
        case T.ProgressiveList{z0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{z0, z1, z2}:
          {==}
        case T.CompatibleUnion{z0, z1}:
          {==}
