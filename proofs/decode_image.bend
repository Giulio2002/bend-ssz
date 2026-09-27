import Base
import ../types/schema.bend as T
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/schema.bend as IS
import ../spec/codec.bend as SC
import ../spec/schema.bend as SS
import ../spec/primitives.bend as SP
import ./packed.bend as PK
import ./packed_pack_acc.bend as PA
import ./packed_domain.bend as PD
import ./word_facts.bend as F
import ./primitive_invariants.bend as V
import ./nat_order.bend as NO
import ./complete_leaves.bend as CLeaf
import ./complete_walk.bend as CWalk
import ./complete_regions.bend as CReg
import ./complete_decode.bend as CDec
import ./encoding_domain.bend as ED
import ./decode_region.bend as DT

# Completeness of the public list entry point: every byte string in the
# canonical image of a legal type is accepted, and decodes to exactly the
# value it encodes. This is the converse of `decode_top.accepted_serializes`,
# and it is `go_complete` applied to the region the packer builds.
law bytes_elim:
  for -G: Type
  for +r: Maybe<&2, +List<T.Part>>
  for +bytes: +List<U32>
  for +same: {SC.bytes(r) == Some{bytes} : Maybe<&2, +List<U32>>}
  for k: @+fb: {CLeaf.fragment_bytes(r) == bytes : +List<U32>} -> @+isng: {CReg.single_parts(r) == True{} : Bool} -> G
  G
def bytes_elim(G, r, bytes, same, k):
  match r:
    case Some{Con{T.Fixed{ys}, Nil{}}}: k(Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, CReg.bytes_of, Some{ys}, Some{bytes}, same), {==})
    case Some{Con{T.Variable{ys}, Nil{}}}: k(Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, CReg.bytes_of, Some{ys}, Some{bytes}, same), {==})
    case Some{Nil{}}: Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, CReg.is_some_bytes, SC.bytes(Some{[]}), Some{bytes}, same)))
    case Some{Con{T.Fixed{ys}, Con{a, b}}}: Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, CReg.is_some_bytes, SC.bytes(Some{T.Fixed{ys} <> (a <> b)}), Some{bytes}, same)))
    case Some{Con{T.Variable{ys}, Con{a, b}}}: Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, CReg.is_some_bytes, SC.bytes(Some{T.Variable{ys} <> (a <> b)}), Some{bytes}, same)))
    case None{}: Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, CReg.is_some_bytes, SC.bytes(None{}), Some{bytes}, same)))

# The decoder's result, read back through the public wrapper.
law parsed_result:
  for +out: D.Out
  for +value: T.Value
  for +sl: P.Slice
  for +size: Nat
  for ok: CLeaf.parsed_as(value, sl, size, out)
  {C.result(D.result(out)) == Some{value} : Maybe<&2, T.Value>}
def parsed_result(out, value, sl, size, ok):
  CWalk.parsed_elim({C.result(D.result(out)) == Some{value} : Maybe<&2, T.Value>}, out, value, sl, size, ok,
    v => rest => shape => cval => crest => cwf =>
      %Equal.sym(D.Out, out, D.Parsed{v, rest}, shape) : {C.result(D.result(_)) == Some{value} : Maybe<&2, T.Value>}
      Equal.cong(T.Value, Maybe<&2, T.Value>, x => Some{x}, C.to_value(v), value, cval))

law region_accepts:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +len: {n == List.length(&2, U32, bytes) : Nat}
  for +view: {List.take(&2, U32, P.chunks_bytes(chunks), List.length(&2, U32, bytes)) == bytes : +List<U32>}
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +encoded: {SC.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {C.result(D.result(D.go(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}))) == Some{value} : Maybe<&2, T.Value>}
def region_accepts(schema, value, bytes, n, chunks, len, view, legal, encoded):
  +rlegal = CDec.or_right(CReg.is_null(schema), IS.valid_go(schema, False{}), legal)
  +slbytes = DT.region_is_input(bytes, n, chunks, len, view)
  bytes_elim({C.result(D.result(D.go(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}))) == Some{value} : Maybe<&2, T.Value>}, SC.parts(value, schema), bytes, encoded,
    fbytes => single =>
  +regioneq = Equal.trans(+List<U32>, CLeaf.fragment_bytes(SC.parts(value, schema)), bytes, List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n),
    fbytes,
    Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n), bytes,
      Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n), List.take(&2, U32, bytes, n), bytes,
        Equal.cong(+List<U32>, +List<U32>, us => List.take(&2, U32, us, n), P.slice_bytes(P.Slice{chunks, 0n, n}), bytes, slbytes),
        DT.take_all(bytes, n, len))))
  parsed_result(D.go(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}), value, P.Slice{chunks, 0n, n}, n,
    CDec.go_complete(schema, 1n, 0n, D.Region{n, P.Slice{chunks, 0n, n}}, value, schema, P.Slice{chunks, 0n, n}, 0n, 0n, [], [], P.Slice{chunks, 0n, n}, P.Slice{chunks, 0n, n}, C.CEnd{})(
      DT.region_wf(bytes, n, chunks, len, view),
      NO.reflexive(n),
      rlegal,
      {==},
      Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(value, schema), Some{[SC.fragment(SS.fixed_size(schema), CLeaf.fragment_bytes(SC.parts(value, schema)))]}, Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n))]},
        CReg.single_holds(schema, SC.parts(value, schema), CDec.region_single(schema, value, rlegal), single),
        Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, us => Some{[SC.fragment(SS.fixed_size(schema), us)]}, CLeaf.fragment_bytes(SC.parts(value, schema)), List.take(&2, U32, P.slice_bytes(P.Slice{chunks, 0n, n}), n), regioneq)))))

law accepted_with_view:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +n: Nat
  for +chunks: +List<P.Chunk>
  for +psame: {P.pack_list(bytes) == P.Packing{n, True{}, chunks} : P.Packing}
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +encoded: {SC.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  for view: {P.packing_length(P.pack_list(bytes)) == List.length(&2, U32, bytes) : Nat} & {List.take(&2, U32, P.chunks_bytes(P.packing_chunks(P.pack_list(bytes))), List.length(&2, U32, bytes)) == bytes : +List<U32>}
  {C.result(D.measured(P.Packing{n, True{}, chunks}, schema)) == Some{value} : Maybe<&2, T.Value>}
def accepted_with_view(schema, value, bytes, n, chunks, psame, legal, encoded, view):
  (lenv, bytesv) = view
  region_accepts(schema, value, bytes, n, chunks,
    (%psame : {P.packing_length(_) == List.length(&2, U32, bytes) : Nat}
     lenv),
    (%psame : {List.take(&2, U32, P.chunks_bytes(P.packing_chunks(_)), List.length(&2, U32, bytes)) == bytes : +List<U32>}
     bytesv),
    legal, encoded)

law packed_accepted:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +p: P.Packing
  for +psame: {P.pack_list(bytes) == p : P.Packing}
  for +pdom: {P.packing_domain(P.pack_list(bytes)) == True{} : Bool}
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +encoded: {SC.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {C.result(D.measured(p, schema)) == Some{value} : Maybe<&2, T.Value>}
def packed_accepted(schema, value, bytes, p, psame, pdom, legal, encoded):
  match p:
    case P.Packing{n, ok, chunks}:
      match ok:
        case False{}:
          Empty.absurd({C.result(D.measured(P.Packing{n, False{}, chunks}, schema)) == Some{value} : Maybe<&2, T.Value>},
            F.false_true(Equal.trans(Bool, False{}, P.packing_domain(P.pack_list(bytes)), True{},
              Equal.sym(Bool, P.packing_domain(P.pack_list(bytes)), False{},
                Equal.cong(P.Packing, Bool, P.packing_domain, P.pack_list(bytes), P.Packing{n, False{}, chunks}, psame)),
              pdom)))
        case True{}:
          accepted_with_view(schema, value, bytes, n, chunks, psame, legal, encoded, PA.pack_list_view(bytes, pdom))

law image_accepted:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +encoded: {SC.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
def image_accepted(schema, value, bytes, legal, encoded):
  +rlegal = CDec.or_right(CReg.is_null(schema), IS.valid_go(schema, False{}), legal)
  bytes_elim({D.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}, SC.parts(value, schema), bytes, encoded,
    fb => isng =>
      %Equal.sym(Bool, IS.valid(schema), True{}, legal) : {C.result(D.gate(_, u => D.measured(P.pack_list(bytes), schema))) == Some{value} : Maybe<&2, T.Value>}
      packed_accepted(schema, value, bytes, P.pack_list(bytes), {==},
        PD.pack_list_domain(bytes,
          Equal.trans(Bool, SP.bytes_domain(bytes), SP.bytes_domain(CLeaf.fragment_bytes(SC.parts(value, schema))), True{},
            Equal.cong(+List<U32>, Bool, SP.bytes_domain, bytes, CLeaf.fragment_bytes(SC.parts(value, schema)),
              Equal.sym(+List<U32>, CLeaf.fragment_bytes(SC.parts(value, schema)), bytes, fb)),
            ED.parts_domain(value, schema, rlegal))),
        legal, encoded))
