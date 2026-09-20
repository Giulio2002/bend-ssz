import Base
import ../types/schema.bend as T
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/schema.bend as IS
import ../src/ssz.bend as API
import ../src/codec.bend as Codec
import ../spec/codec.bend as SC
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./packed_pack_acc.bend as PP
import ./cursor_leaves.bend as CL
import ./cursor_walk.bend as CW
import ./cursor_legal.bend as CLG
import ./cursor_sound.bend as CS
import ./primitive_invariants.bend as V
import ./nat_order.bend as NO
import ./word_facts.bend as F
import ./codec_composition.bend as Composition

# The public list entry point, tied to the frozen specification.
#
# `Decode.decode` packs its input in one pass (`Packed.pack_list`), opens a
# region over the packed bytes and runs the cursor decoder. `pack_list_view`
# says the packed region denotes exactly the input, `go_sound` says the
# decoded value re-encodes to exactly the region, so an accepted input is the
# specification's encoding of the decoded value.

def some_value(d: T.Value, m: Maybe<&2, T.Value>) -> T.Value:
  match m:
    case None{}: d
    case Some{v}: v

law some_injective:
  for +a: T.Value
  for +b: T.Value
  for +e: {Some{a} == Some{b} : Maybe<&2, T.Value>}
  {a == b : T.Value}
def some_injective(a, b, e):
  Equal.cong(Maybe<&2, T.Value>, T.Value, m => some_value(a, m), Some{a}, Some{b}, e)

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

law fragment_bytes:
  for +width: Maybe<&2, Nat>
  for +ys: +List<U32>
  {SC.bytes(Some{[SC.fragment(width, ys)]}) == Some{ys} : Maybe<&2, +List<U32>>}
def fragment_bytes(width, ys):
  match width:
    case None{}: {==}
    case Some{w}: {==}

law parsed_encodes:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +v: C.CValue
  for +rest: P.Slice
  for +len: {n == List.length(&2, U32, xs) : Nat}
  for +bytes: {List.take(&2, U32, P.chunks_bytes(chunks), List.length(&2, U32, xs)) == xs : +List<U32>}
  for sound: CL.region_sound(schema, n, P.Slice{chunks, 0n, n}, D.Parsed{v, rest})
  {SC.encoding_for_legal_type(schema, C.to_value(v)) == Some{xs} : Maybe<&2, +List<U32>>}
def parsed_encodes(schema, xs, n, chunks, v, rest, len, bytes, sound):
  (parts, restinfo) = sound
  +view = region_is_input(xs, n, chunks, len, bytes)
  +whole = take_all(xs, n, len)
  %Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n), List.take(&2, U32, xs, n), xs,
     Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, n), P.slice_bytes(P.Slice{chunks, 0n, n}), xs, view),
     whole) : {SC.bytes(SC.parts(C.to_value(v), schema)) == Some{_} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(C.to_value(v), schema), Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n))]}, parts) : {SC.bytes(_) == Some{List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n)} : Maybe<&2, +List<U32>>}
  fragment_bytes(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n))


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

law out_encodes:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +out: D.Out
  for +osame: {D.go(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}) == out : D.Out}
  for +len: {n == List.length(&2, U32, xs) : Nat}
  for +bytes: {List.take(&2, U32, P.chunks_bytes(chunks), List.length(&2, U32, xs)) == xs : +List<U32>}
  for +legal: {CW.legal_go(schema) == True{} : Bool}
  for +accepted: {C.result(D.result(out)) == Some{value} : Maybe<&2, T.Value>}
  {SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def out_encodes(schema, xs, value, n, chunks, out, osame, len, bytes, legal, accepted):
  match out:
    case D.Refused{}: Empty.absurd({SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}, F.none_some(value, accepted))
    case D.Begin{r}: Empty.absurd({SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}, F.none_some(value, accepted))
    case D.Parsed{v, rest}:
      %some_injective(C.to_value(v), value, accepted) : {SC.encoding_for_legal_type(schema, _) == Some{xs} : Maybe<&2, +List<U32>>}
      parsed_encodes(schema, xs, n, chunks, v, rest, len, bytes,
        (%osame : CL.region_sound(schema, n, P.Slice{chunks, 0n, n}, _)
         CS.go_sound(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}, schema, P.Slice{chunks, 0n, n}, 0n, 0n, [], P.Slice{chunks, 0n, n}, P.Slice{chunks, 0n, n}, C.CEnd{}, 0n, 0n, legal)(
           region_wf(xs, n, chunks, len, bytes), NO.reflexive(n))))


law domain_of:
  for +xs: +List<U32>
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +psame: {P.pack_list(xs) == P.Packing{n, True{}, chunks} : P.Packing}
  {P.packing_domain(P.pack_list(xs)) == True{} : Bool}
def domain_of(xs, n, chunks, psame):
  Equal.cong(P.Packing, Bool, P.packing_domain, P.pack_list(xs), P.Packing{n, True{}, chunks}, psame)

law with_view:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +psame: {P.pack_list(xs) == P.Packing{n, True{}, chunks} : P.Packing}
  for +legal: {CW.legal_go(schema) == True{} : Bool}
  for +accepted: {C.result(D.measured(P.Packing{n, True{}, chunks}, schema)) == Some{value} : Maybe<&2, T.Value>}
  for view: {P.packing_length(P.pack_list(xs)) == List.length(&2, U32, xs) : Nat} & {List.take(&2, U32, P.chunks_bytes(P.packing_chunks(P.pack_list(xs))), List.length(&2, U32, xs)) == xs : +List<U32>}
  {SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def with_view(schema, xs, value, n, chunks, psame, legal, accepted, view):
  (+lenv, +bytesv) = view
  out_encodes(schema, xs, value, n, chunks, D.go(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}), {==},
    (%psame : {P.packing_length(_) == List.length(&2, U32, xs) : Nat}
     lenv),
    (%psame : {List.take(&2, U32, P.chunks_bytes(P.packing_chunks(_)), List.length(&2, U32, xs)) == xs : +List<U32>}
     bytesv),
    legal, accepted)

# The packed region the list entry point built, case by case.
law packing_encodes:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +p: P.Packing
  for +psame: {P.pack_list(xs) == p : P.Packing}
  for +legal: {CW.legal_go(schema) == True{} : Bool}
  for +accepted: {C.result(D.measured(p, schema)) == Some{value} : Maybe<&2, T.Value>}
  {SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def packing_encodes(schema, xs, value, p, psame, legal, accepted):
  match p:
    case P.Packing{+n, +ok, +chunks}:
      match ok:
        case False{}:
          Empty.absurd({SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>},
            F.none_some(value,
              (%CW.invalid_refuses(schema, 1n, 0n) : {C.result(D.result(_)) == Some{value} : Maybe<&2, T.Value>}
               accepted)))
        case True{}:
          with_view(schema, xs, value, n, chunks, psame, legal, accepted, PP.pack_list_view(xs, domain_of(xs, n, chunks, psame)))

# The public list entry point.
law decode_encodes:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +valid: Bool
  for +vsame: {IS.valid(schema) == valid : Bool}
  for +legal: {CW.legal_go(schema) == True{} : Bool}
  for +accepted: {D.deserialize(schema, xs) == Some{value} : Maybe<&2, T.Value>}
  {SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def decode_encodes(schema, xs, value, valid, vsame, legal, accepted):
  match valid:
    case False{}:
      Empty.absurd({SC.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>},
        F.none_some(value,
          (%vsame : {C.result(D.gate(_, u => D.measured(P.pack_list(xs), schema))) == Some{value} : Maybe<&2, T.Value>}
           accepted)))
    case True{}:
      packing_encodes(schema, xs, value, P.pack_list(xs), {==}, legal,
        (%vsame : {C.result(D.gate(_, u => D.measured(P.pack_list(xs), schema))) == Some{value} : Maybe<&2, T.Value>}
         accepted))

# An accepted input is the encoding of the decoded value: the public list
# entry point, the packed cursor decoder and the frozen specification agree.
law accepted_valid:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +valid: Bool
  for +vsame: {IS.valid(schema) == valid : Bool}
  for +accepted: {D.deserialize(schema, xs) == Some{value} : Maybe<&2, T.Value>}
  {IS.valid(schema) == True{} : Bool}
def accepted_valid(schema, xs, value, valid, vsame, accepted):
  match valid:
    case True{}: vsame
    case False{}:
      Empty.absurd({IS.valid(schema) == True{} : Bool},
        F.none_some(value,
          (%vsame : {C.result(D.gate(_, u => D.measured(P.pack_list(xs), schema))) == Some{value} : Maybe<&2, T.Value>}
           accepted)))

law accepted_serializes:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +accepted: {D.deserialize(schema, xs) == Some{value} : Maybe<&2, T.Value>}
  {Codec.serialize(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def accepted_serializes(schema, xs, value, accepted):
  +valid = accepted_valid(schema, xs, value, IS.valid(schema), {==}, accepted)
  Equal.trans(Maybe<&2, +List<U32>>, Codec.serialize(schema, value), SC.encoding_for_legal_type(schema, value), Some{xs},
    Composition.serialize_for_valid_type(schema, value, valid),
    decode_encodes(schema, xs, value, IS.valid(schema), {==}, CLG.from_valid(schema, False{}, valid), accepted))
