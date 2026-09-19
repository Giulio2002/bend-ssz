import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T
import ./word_split.bend as B
import ./power_division.bend as D
import ./byte_arithmetic.bend as A
import ./integer_decoding.bend as Decode
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./basic_root.bend as Root
import ./primitives.bend as Basic

law masked_shape:
  for +x: U32
  {U32.and(x, 255) == D.embed8(B.take(8n, 32n, D.bits(x))) : U32}
def masked_shape(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n), U32, w => U32{w},
        Word.and(32n, w, B.join(8n, 24n, B.ones(8n), Word.zero(24n))),
        B.join(8n, 24n, B.take(8n, 32n, w), Word.zero(24n)), B.mask_take(8n, 24n, w))

law limb_packed:
  for +a: Word(8n)
  for +b: Word(8n)
  for +c: Word(8n)
  for +d: Word(8n)
  {I.limb(U32{B.join(8n, 24n, a, B.join(8n, 16n, b, B.join(8n, 8n, c, d)))}) == [D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)] : +List<U32>}
def limb_packed(a, b, c, d):
  match a b c d:
    case WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}} WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}} WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}} WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}:
      %Equal.sym(U32, U32.and(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 255), D.embed8(B.take(8n, 32n, D.bits(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))), masked_shape(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) :
        {[_, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n), 255), U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n), 255), U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 24n)] == [D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}), D.embed8(WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}}), D.embed8(WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}})] : +List<U32>}
      %Equal.sym(U32, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n), 255), D.embed8(B.take(8n, 32n, D.bits(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n)))), masked_shape(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n))) :
        {[D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), _, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n), 255), U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 24n)] == [D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}), D.embed8(WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}}), D.embed8(WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}})] : +List<U32>}
      %Equal.sym(U32, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n), 255), D.embed8(B.take(8n, 32n, D.bits(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n)))), masked_shape(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n))) :
        {[D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}), _, U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 24n)] == [D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}), D.embed8(WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}}), D.embed8(WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}})] : +List<U32>}
      {==}

law limb_inverse:
  for +x: U32
  {I.read_limb(I.limb(x), 0n) == x : U32}
def limb_inverse(x):
  match x:
    case U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      %Equal.sym(U32, U32.and(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 255), D.embed8(B.take(8n, 32n, D.bits(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))), masked_shape(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) :
        {I.read_limb([_, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n), 255), U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n), 255), U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 24n)], 0n) == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
      %Equal.sym(U32, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n), 255), D.embed8(B.take(8n, 32n, D.bits(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n)))), masked_shape(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8n))) :
        {I.read_limb([D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), _, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n), 255), U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 24n)], 0n) == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
      %Equal.sym(U32, U32.and(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n), 255), D.embed8(B.take(8n, 32n, D.bits(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n)))), masked_shape(U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16n))) :
        {I.read_limb([D.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}), D.embed8(WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}), _, U32.shrn(U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 24n)], 0n) == U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}
      A.pack_or4(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}, WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WNil{}}}}}}}}}, WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}}, WCon{d0, WCon{d1, WCon{d2, WCon{d3, WCon{d4, WCon{d5, WCon{d6, WCon{d7, WNil{}}}}}}}}})

law bytes_reencode:
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  for ea: {U32.is_lt(a, 256) == True{} : Bool}
  for eb: {U32.is_lt(b, 256) == True{} : Bool}
  for ec: {U32.is_lt(c, 256) == True{} : Bool}
  for ed: {U32.is_lt(d, 256) == True{} : Bool}
  {I.limb(I.read_limb([a, b, c, d], 0n)) == [a, b, c, d] : +List<U32>}
def bytes_reencode(a, b, c, d, ea, eb, ec, ed):
  %Equal.sym(U32, a, D.embed8(B.take(8n, 32n, D.bits(a))), Decode.byte_shape(a, ea)) : {I.limb(I.read_limb([_, b, c, d], 0n)) == [_, b, c, d] : +List<U32>}
  %Equal.sym(U32, b, D.embed8(B.take(8n, 32n, D.bits(b))), Decode.byte_shape(b, eb)) : {I.limb(I.read_limb([D.embed8(B.take(8n, 32n, D.bits(a))), _, c, d], 0n)) == [D.embed8(B.take(8n, 32n, D.bits(a))), _, c, d] : +List<U32>}
  %Equal.sym(U32, c, D.embed8(B.take(8n, 32n, D.bits(c))), Decode.byte_shape(c, ec)) : {I.limb(I.read_limb([D.embed8(B.take(8n, 32n, D.bits(a))), D.embed8(B.take(8n, 32n, D.bits(b))), _, d], 0n)) == [D.embed8(B.take(8n, 32n, D.bits(a))), D.embed8(B.take(8n, 32n, D.bits(b))), _, d] : +List<U32>}
  %Equal.sym(U32, d, D.embed8(B.take(8n, 32n, D.bits(d))), Decode.byte_shape(d, ed)) : {I.limb(I.read_limb([D.embed8(B.take(8n, 32n, D.bits(a))), D.embed8(B.take(8n, 32n, D.bits(b))), D.embed8(B.take(8n, 32n, D.bits(c))), _], 0n)) == [D.embed8(B.take(8n, 32n, D.bits(a))), D.embed8(B.take(8n, 32n, D.bits(b))), D.embed8(B.take(8n, 32n, D.bits(c))), _] : +List<U32>}
  %Equal.sym(U32, I.read_limb([D.embed8(B.take(8n, 32n, D.bits(a))), D.embed8(B.take(8n, 32n, D.bits(b))), D.embed8(B.take(8n, 32n, D.bits(c))), D.embed8(B.take(8n, 32n, D.bits(d)))], 0n), U32{B.join(8n, 24n, B.take(8n, 32n, D.bits(a)), B.join(8n, 16n, B.take(8n, 32n, D.bits(b)), B.join(8n, 8n, B.take(8n, 32n, D.bits(c)), B.take(8n, 32n, D.bits(d)))))}, A.pack_or4(B.take(8n, 32n, D.bits(a)), B.take(8n, 32n, D.bits(b)), B.take(8n, 32n, D.bits(c)), B.take(8n, 32n, D.bits(d)))) : {I.limb(_) == [D.embed8(B.take(8n, 32n, D.bits(a))), D.embed8(B.take(8n, 32n, D.bits(b))), D.embed8(B.take(8n, 32n, D.bits(c))), D.embed8(B.take(8n, 32n, D.bits(d)))] : +List<U32>}
  limb_packed(B.take(8n, 32n, D.bits(a)), B.take(8n, 32n, D.bits(b)), B.take(8n, 32n, D.bits(c)), B.take(8n, 32n, D.bits(d)))

law read_limb_reencode:
  for +xs: +List<U32>
  for +n: Nat
  for +e: {S.bytes_domain(xs) == True{} : Bool}
  {I.limb(I.read_limb(xs, n)) == [I.at(xs, n), I.at(xs, 1n+n), I.at(xs, 2n+n), I.at(xs, 3n+n)] : +List<U32>}
def read_limb_reencode(xs, n, e):
  bytes_reencode(I.at(xs, n), I.at(xs, 1n+n), I.at(xs, 2n+n), I.at(xs, 3n+n),
    Decode.at_domain(xs, n, e), Decode.at_domain(xs, 1n+n, e), Decode.at_domain(xs, 2n+n, e), Decode.at_domain(xs, 3n+n, e))

def sample(n: Nat, +xs: +List<U32>, +index: Nat) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p: I.at(xs, index) <> sample(p, xs, 1n+index)

law sample_empty:
  for n: Nat
  for index: Nat
  {sample(n, [], index) == S.zero_bytes(n) : +List<U32>}
def sample_empty(n, index):
  match n:
    case 0n: {==}
    case 1n+p:
      %sample_empty(p, 1n+index) : {0 <> sample(p, [], 1n+index) == 0 <> _ : +List<U32>}
      {==}

law sample_tail:
  for +n: Nat
  for +h: U32
  for +t: +List<U32>
  for +index: Nat
  {sample(n, h <> t, 1n+index) == sample(n, t, index) : +List<U32>}
def sample_tail(n, h, t, index):
  match n:
    case 0n: {==}
    case 1n+p:
      %sample_tail(p, h, t, 1n+index) :
        {I.at(t, index) <> sample(p, h <> t, 2n+index) == I.at(t, index) <> _ : +List<U32>}
      {==}

law sample_padding:
  for +n: Nat
  for +xs: +List<U32>
  {sample(n, xs, 0n) == I.pad(n, xs) : +List<U32>}
def sample_padding(n, xs):
  match n:
    case 0n: {==}
    case 1n+p:
      match xs:
        case Nil{}:
          Equal.trans(+List<U32>, sample(1n+p, [], 0n), S.zero_bytes(1n+p), I.pad(1n+p, []),
            sample_empty(1n+p, 0n), Equal.sym(+List<U32>, I.pad(1n+p, []), S.zero_bytes(1n+p), Root.empty_padding(1n+p)))
        case Con{h, t}:
          %sample_padding(p, t) : {h <> sample(p, h <> t, 1n) == h <> _ : +List<U32>}
          Equal.cong(+List<U32>, +List<U32>, xs => h <> xs,
            sample(p, h <> t, 1n), sample(p, t, 0n), sample_tail(p, h, t, 0n))

law decoded_sample:
  for +xs: +List<U32>
  for +e: {S.bytes_domain(xs) == True{} : Bool}
  {I.uint_bytes(I.decoded(xs)) == sample(32n, xs, 0n) : +List<U32>}
def decoded_sample(xs, e):
  %read_limb_reencode(xs, 0n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, _, List.append(&2, U32, [I.at(xs, 4n), I.at(xs, 5n), I.at(xs, 6n), I.at(xs, 7n)], List.append(&2, U32, [I.at(xs, 8n), I.at(xs, 9n), I.at(xs, 10n), I.at(xs, 11n)], List.append(&2, U32, [I.at(xs, 12n), I.at(xs, 13n), I.at(xs, 14n), I.at(xs, 15n)], List.append(&2, U32, [I.at(xs, 16n), I.at(xs, 17n), I.at(xs, 18n), I.at(xs, 19n)], List.append(&2, U32, [I.at(xs, 20n), I.at(xs, 21n), I.at(xs, 22n), I.at(xs, 23n)], List.append(&2, U32, [I.at(xs, 24n), I.at(xs, 25n), I.at(xs, 26n), I.at(xs, 27n)], [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 4n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, _, List.append(&2, U32, [I.at(xs, 8n), I.at(xs, 9n), I.at(xs, 10n), I.at(xs, 11n)], List.append(&2, U32, [I.at(xs, 12n), I.at(xs, 13n), I.at(xs, 14n), I.at(xs, 15n)], List.append(&2, U32, [I.at(xs, 16n), I.at(xs, 17n), I.at(xs, 18n), I.at(xs, 19n)], List.append(&2, U32, [I.at(xs, 20n), I.at(xs, 21n), I.at(xs, 22n), I.at(xs, 23n)], List.append(&2, U32, [I.at(xs, 24n), I.at(xs, 25n), I.at(xs, 26n), I.at(xs, 27n)], [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 8n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, I.limb(I.read_limb(xs, 4n)), List.append(&2, U32, _, List.append(&2, U32, [I.at(xs, 12n), I.at(xs, 13n), I.at(xs, 14n), I.at(xs, 15n)], List.append(&2, U32, [I.at(xs, 16n), I.at(xs, 17n), I.at(xs, 18n), I.at(xs, 19n)], List.append(&2, U32, [I.at(xs, 20n), I.at(xs, 21n), I.at(xs, 22n), I.at(xs, 23n)], List.append(&2, U32, [I.at(xs, 24n), I.at(xs, 25n), I.at(xs, 26n), I.at(xs, 27n)], [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 12n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, I.limb(I.read_limb(xs, 4n)), List.append(&2, U32, I.limb(I.read_limb(xs, 8n)), List.append(&2, U32, _, List.append(&2, U32, [I.at(xs, 16n), I.at(xs, 17n), I.at(xs, 18n), I.at(xs, 19n)], List.append(&2, U32, [I.at(xs, 20n), I.at(xs, 21n), I.at(xs, 22n), I.at(xs, 23n)], List.append(&2, U32, [I.at(xs, 24n), I.at(xs, 25n), I.at(xs, 26n), I.at(xs, 27n)], [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 16n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, I.limb(I.read_limb(xs, 4n)), List.append(&2, U32, I.limb(I.read_limb(xs, 8n)), List.append(&2, U32, I.limb(I.read_limb(xs, 12n)), List.append(&2, U32, _, List.append(&2, U32, [I.at(xs, 20n), I.at(xs, 21n), I.at(xs, 22n), I.at(xs, 23n)], List.append(&2, U32, [I.at(xs, 24n), I.at(xs, 25n), I.at(xs, 26n), I.at(xs, 27n)], [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 20n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, I.limb(I.read_limb(xs, 4n)), List.append(&2, U32, I.limb(I.read_limb(xs, 8n)), List.append(&2, U32, I.limb(I.read_limb(xs, 12n)), List.append(&2, U32, I.limb(I.read_limb(xs, 16n)), List.append(&2, U32, _, List.append(&2, U32, [I.at(xs, 24n), I.at(xs, 25n), I.at(xs, 26n), I.at(xs, 27n)], [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 24n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, I.limb(I.read_limb(xs, 4n)), List.append(&2, U32, I.limb(I.read_limb(xs, 8n)), List.append(&2, U32, I.limb(I.read_limb(xs, 12n)), List.append(&2, U32, I.limb(I.read_limb(xs, 16n)), List.append(&2, U32, I.limb(I.read_limb(xs, 20n)), List.append(&2, U32, _, [I.at(xs, 28n), I.at(xs, 29n), I.at(xs, 30n), I.at(xs, 31n)]))))))) : +List<U32>}
  %read_limb_reencode(xs, 28n, e) : {I.uint_bytes(I.decoded(xs)) == List.append(&2, U32, I.limb(I.read_limb(xs, 0n)), List.append(&2, U32, I.limb(I.read_limb(xs, 4n)), List.append(&2, U32, I.limb(I.read_limb(xs, 8n)), List.append(&2, U32, I.limb(I.read_limb(xs, 12n)), List.append(&2, U32, I.limb(I.read_limb(xs, 16n)), List.append(&2, U32, I.limb(I.read_limb(xs, 20n)), List.append(&2, U32, I.limb(I.read_limb(xs, 24n)), _))))))) : +List<U32>}
  {==}

law all_zero_padding:
  for n: Nat
  {I.all_zero(I.pad(n, [])) == True{} : Bool}
def all_zero_padding(n):
  match n:
    case 0n: {==}
    case 1n+p: all_zero_padding(p)

law narrow_padding:
  for +xs: +List<U32>
  for +p: Nat
  {I.narrow(List.length(&2, U32, xs), I.pad(Nat.add(List.length(&2, U32, xs), p), xs)) == Some{xs} : Maybe<&2, +List<U32>>}
def narrow_padding(xs, p):
  match xs:
    case Nil{}:
      %Equal.sym(Bool, I.all_zero(I.pad(p, [])), True{}, all_zero_padding(p)) :
        {I.accept_bytes(_, []) == Some{[]} : Maybe<&2, +List<U32>>}
      {==}
    case Con{h, t}:
      Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, +List<U32>>, r => I.prepend(h, r),
        I.narrow(List.length(&2, U32, t), I.pad(Nat.add(List.length(&2, U32, t), p), t)), Some{t}, narrow_padding(t, p))

law scope_length:
  for +n: Nat
  for +xs: +List<U32>
  for e: {S.byte_scope(n, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == n : Nat}
def scope_length(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: Empty.absurd({1n+List.length(&2, U32, t) == 0n : Nat}, W.false_true(e))
    case 1n+p:
      match xs:
        case Nil{}: Empty.absurd({0n == 1n+p : Nat}, W.false_true(e))
        case Con{h, t}:
          %scope_length(p, t, V.and_right(U32.is_lt(h, 256), S.byte_scope(p, t), e)) :
            {1n+List.length(&2, U32, t) == 1n+_ : Nat}
          {==}

law uint_scope_reencode:
  for +w: T.Width
  for +xs: +List<U32>
  for +e: {S.byte_scope(I.width(w), xs) == True{} : Bool}
  {I.uint_serialize(w, I.decoded(xs)) == Some{xs} : Maybe<&2, +List<U32>>}
def uint_scope_reencode(w, xs, e):
  %Equal.sym(+List<U32>, I.uint_bytes(I.decoded(xs)), sample(32n, xs, 0n), decoded_sample(xs, Decode.scope_domain(I.width(w), xs, e))) :
    {I.narrow(I.width(w), _) == Some{xs} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, sample(32n, xs, 0n), I.pad(32n, xs), sample_padding(32n, xs)) :
    {I.narrow(I.width(w), _) == Some{xs} : Maybe<&2, +List<U32>>}
  %Root.width_padding(w) :
    {I.narrow(I.width(w), I.pad(_, xs)) == Some{xs} : Maybe<&2, +List<U32>>}
  %scope_length(I.width(w), xs, e) :
    {I.narrow(_, I.pad(Nat.add(_, Nat.sub(32n, I.width(w))), xs)) == Some{xs} : Maybe<&2, +List<U32>>}
  narrow_padding(xs, Nat.sub(32n, I.width(w)))

def canonical(w: T.Width, xs: +List<U32>, r: Maybe<&2, T.UInt>) -> Type:
  match r:
    case None{}: Unit
    case Some{v}: {I.uint_serialize(w, v) == Some{xs} : Maybe<&2, +List<U32>>}

law canonical_branch:
  for ok: Bool
  for +w: T.Width
  for +xs: +List<U32>
  for e: {S.byte_scope(I.width(w), xs) == ok : Bool}
  canonical(w, xs, I.decode_checked(ok, xs))
def canonical_branch(ok, w, xs, e):
  match ok:
    case False{}: Unit{}
    case True{}: uint_scope_reencode(w, xs, e)

law uint_decoding_canonical:
  for +w: T.Width
  for +xs: +List<U32>
  canonical(w, xs, I.uint_deserialize(w, xs))
def uint_decoding_canonical(w, xs):
  canonical_branch(I.valid_bytes(I.width(w), xs), w, xs,
    Equal.sym(Bool, I.valid_bytes(I.width(w), xs), S.byte_scope(I.width(w), xs), Basic.byte_scope_correct(I.width(w), xs)))

law uint_accepted_reencode:
  for +w: T.Width
  for +xs: +List<U32>
  for v: T.UInt
  for e: {I.uint_deserialize(w, xs) == Some{v} : Maybe<&2, T.UInt>}
  {I.uint_serialize(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
def uint_accepted_reencode(w, xs, v, e):
  %e : canonical(w, xs, _)
  uint_decoding_canonical(w, xs)
