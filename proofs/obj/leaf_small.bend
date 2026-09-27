import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/FuluBytes1_def_generated.bend as FuluBytes1_d
import ../../types/uint8_hashtreeroot_generated.bend as uint8_h
import ../../types/uint32_hashtreeroot_generated.bend as uint32_h
import ../../types/FuluBytes1_hashtreeroot_generated.bend as FuluBytes1_h
import ../../types/FuluParticipationFlags_hashtreeroot_generated.bend as FuluParticipationFlags_h
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/fulu_schemas.bend as Spec
import ../../proofs/integer_encoding.bend as IE
import ../../proofs/integer_decoding.bend as ID
import ../../proofs/power_division.bend as PD
import ../../proofs/word_split.bend as WSp
import ./root_leaf.bend as RL
import ../../proofs/compact/found.bend as FD

# Root laws of the one-word leaves: uint32 (every value), uint8 and
# ParticipationFlags (values below 256, their representation invariant) and
# Bytes1 (its one byte below 256). A byte below 256 is embed8 of its low eight
# bits (proofs/integer_decoding.bend byte_shape); the laws over those bits are
# symbolic (a chunk is its own root: nothing is hashed).

# uint32: the chunk of its word.
law u32_root:
  for +o: U32
  RR.roots(S.UnsignedValue{P.UInt{o, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U32Width{}}, [D.bytes(O.u32_chunk(o))])
def u32_root(o):
  %IE.uint_hash_tree_root_correct(P.U32Width{}, P.UInt{o, 0, 0, 0, 0, 0, 0, 0}) :
    {_ == Some{D.be_bytes(B.swap32(o), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, []))))))))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, D.be_bytes(B.swap32(o), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, [])))))))), List.append(&2, U32, I.limb(o), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, [])))))))), RL.bytes_swap(o, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, []))))))))) :
    {I.uint_root(P.U32Width{}, P.UInt{o, 0, 0, 0, 0, 0, 0, 0}) == Some{_} : Maybe<&2, +List<U32>>}
  {==}

# A byte embedded from its eight bits: its uint8 root and its Bytes1 root.
def u8_bits(+a0: Bool, +a1: Bool, +a2: Bool, +a3: Bool, +a4: Bool, +a5: Bool, +a6: Bool, +a7: Bool) -> RR.roots(S.UnsignedValue{P.UInt{PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}, [D.bytes(O.u32_chunk(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})))]):
  # the byte is embed8 of eight free bits: the uint encoding and the chunk reduce on
  # them symbolically (no case split over the 256 bytes)
  %IE.uint_hash_tree_root_correct(P.U8{}, P.UInt{PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 0, 0, 0, 0, 0, 0, 0}) :
    {_ == Some{D.be_bytes(B.swap32(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, []))))))))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, D.be_bytes(B.swap32(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, [])))))))), List.append(&2, U32, I.limb(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, [])))))))), RL.bytes_swap(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, []))))))))) :
    {I.uint_root(P.U8{}, P.UInt{PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 0, 0, 0, 0, 0, 0, 0}) == Some{_} : Maybe<&2, +List<U32>>}
  {==}


# the low byte of the embedded byte is itself (per bit: Bool.and(b, True) is b)
def b1and(+a0: Bool, +a1: Bool, +a2: Bool, +a3: Bool, +a4: Bool, +a5: Bool, +a6: Bool, +a7: Bool) -> {U32.and(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 255) == PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}) : U32}:
  %Equal.sym(Bool, Bool.and(a0, True{}), a0, FD.u32__and_true(a0)) :
    {U32{WCon{_, WCon{Bool.and(a1, True{}), WCon{Bool.and(a2, True{}), WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a1, True{}), a1, FD.u32__and_true(a1)) :
    {U32{WCon{a0, WCon{_, WCon{Bool.and(a2, True{}), WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a2, True{}), a2, FD.u32__and_true(a2)) :
    {U32{WCon{a0, WCon{a1, WCon{_, WCon{Bool.and(a3, True{}), WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a3, True{}), a3, FD.u32__and_true(a3)) :
    {U32{WCon{a0, WCon{a1, WCon{a2, WCon{_, WCon{Bool.and(a4, True{}), WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a4, True{}), a4, FD.u32__and_true(a4)) :
    {U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{_, WCon{Bool.and(a5, True{}), WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a5, True{}), a5, FD.u32__and_true(a5)) :
    {U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{_, WCon{Bool.and(a6, True{}), WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a6, True{}), a6, FD.u32__and_true(a6)) :
    {U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{_, WCon{Bool.and(a7, True{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  %Equal.sym(Bool, Bool.and(a7, True{}), a7, FD.u32__and_true(a7)) :
    {U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{_, WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WCon{Bool.and(False{}, False{}), WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
  {==}

# Bytes1: its one byte embedded from eight free bits; the chunk's bytes by RL.bytes_swap,
# as u8_bits (was a 256-way case split evaluating each root: 9.5 s)
def b1e(+a0: Bool, +a1: Bool, +a2: Bool, +a3: Bool, +a4: Bool, +a5: Bool, +a6: Bool, +a7: Bool) -> {RR.bytevector_at_depth(1n, 0n, [PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]) == Some{D.bytes(D.D{B.swap32(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), 0, 0, 0, 0, 0, 0, 0})} : Maybe<&2, +List<U32>>}:
  %Equal.sym(+List<U32>, D.be_bytes(B.swap32(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, [])))))))), List.append(&2, U32, I.limb(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, [])))))))), RL.bytes_swap(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, []))))))))) :
    {RR.bytevector_at_depth(1n, 0n, [PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]) == Some{_} : Maybe<&2, +List<U32>>}
  %Equal.sym(U32, U32.and(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 255), PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), b1and(a0, a1, a2, a3, a4, a5, a6, a7)) :
    {RR.bytevector_at_depth(1n, 0n, [PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]) == Some{List.append(&2, U32, [_, U32.and(U32.shrn(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 8n), 255), U32.and(U32.shrn(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 16n), 255), U32.shrn(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), 24n)], D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, D.be_bytes(0, []))))))))} : Maybe<&2, +List<U32>>}
  {==}

def b1_bits(+a0: Bool, +a1: Bool, +a2: Bool, +a3: Bool, +a4: Bool, +a5: Bool, +a6: Bool, +a7: Bool) -> RR.roots(S.BytesValue{[PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})]}, S.ByteVector{1n}, [D.bytes(D.D{B.swap32(PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}})), 0, 0, 0, 0, 0, 0, 0})]):
  (0n, ({==}, b1e(a0, a1, a2, a3, a4, a5, a6, a7)))

law u8_w:
  for +w8: Word(8n)
  RR.roots(S.UnsignedValue{P.UInt{PD.embed8(w8), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}, [D.bytes(O.u32_chunk(PD.embed8(w8)))])
def u8_w(w8):
  match w8:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WNil{}}}}}}}}}: u8_bits(a0, a1, a2, a3, a4, a5, a6, a7)

law b1_w:
  for +w8: Word(8n)
  RR.roots(S.BytesValue{[PD.embed8(w8)]}, S.ByteVector{1n}, [D.bytes(D.D{B.swap32(PD.embed8(w8)), 0, 0, 0, 0, 0, 0, 0})])
def b1_w(w8):
  match w8:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WNil{}}}}}}}}}: b1_bits(a0, a1, a2, a3, a4, a5, a6, a7)

# uint8: every value below 256.
law uint8_root_correct:
  for -h: B.Buf
  for +o: U32
  for +e: {U32.is_lt(o, 256) == True{} : Bool}
  RR.roots(S.UnsignedValue{P.UInt{o, 0, 0, 0, 0, 0, 0, 0}}, Spec.uint8(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint8_h.uint8_hash_tree_root(h, o)))])
def uint8_root_correct(h, o, e):
  %Equal.sym(U32, o, PD.embed8(WSp.take(8n, 32n, PD.bits(o))), ID.byte_shape(o, e)) :
    RR.roots(S.UnsignedValue{P.UInt{_, 0, 0, 0, 0, 0, 0, 0}}, Spec.uint8(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint8_h.uint8_hash_tree_root(h, _)))])
  u8_w(WSp.take(8n, 32n, PD.bits(o)))

# ParticipationFlags: every value below 256.
law ParticipationFlags_root_correct:
  for -h: B.Buf
  for +o: U32
  for +e: {U32.is_lt(o, 256) == True{} : Bool}
  RR.roots(S.UnsignedValue{P.UInt{o, 0, 0, 0, 0, 0, 0, 0}}, Spec.ParticipationFlags(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluParticipationFlags_h.ParticipationFlags_hash_tree_root(h, o)))])
def ParticipationFlags_root_correct(h, o, e):
  %Equal.sym(U32, o, PD.embed8(WSp.take(8n, 32n, PD.bits(o))), ID.byte_shape(o, e)) :
    RR.roots(S.UnsignedValue{P.UInt{_, 0, 0, 0, 0, 0, 0, 0}}, Spec.ParticipationFlags(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluParticipationFlags_h.ParticipationFlags_hash_tree_root(h, _)))])
  u8_w(WSp.take(8n, 32n, PD.bits(o)))

# uint32: every value.
law uint32_root_correct:
  for -h: B.Buf
  for +o: U32
  RR.roots(S.UnsignedValue{P.UInt{o, 0, 0, 0, 0, 0, 0, 0}}, Spec.uint32(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint32_h.uint32_hash_tree_root(h, o)))])
def uint32_root_correct(h, o): u32_root(o)

def b1_byte(o: FuluBytes1_d.Bytes1) -> U32:
  match o:
    case FuluBytes1_d.Bytes1{+w0}: w0

# Bytes1: every object whose one byte is below 256 (the word holds the byte).
law Bytes1_root_correct:
  for -h: B.Buf
  for +o: FuluBytes1_d.Bytes1
  for +e: {U32.is_lt(b1_byte(o), 256) == True{} : Bool}
  RR.roots(S.BytesValue{[b1_byte(o)]}, Spec.Bytes1(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes1_h.Bytes1_hash_tree_root(h, o)))])
def Bytes1_root_correct(h, o, e):
  match o:
    case FuluBytes1_d.Bytes1{+w0}:
      %Equal.sym(U32, w0, PD.embed8(WSp.take(8n, 32n, PD.bits(w0))), ID.byte_shape(w0, e)) :
        RR.roots(S.BytesValue{[_]}, Spec.Bytes1(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes1_h.Bytes1_hash_tree_root(h, FuluBytes1_d.Bytes1{_})))])
      b1_w(WSp.take(8n, 32n, PD.bits(w0)))
