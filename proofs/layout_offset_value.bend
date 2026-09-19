import Base
import ../spec/primitives.bend as S
import ../spec/nat_bytes.bend as N
import ./word_nat.bend as NatWord
import ./word_split.bend as W
import ./power_division.bend as D
import ./byte_arithmetic.bend as A
import ./integer_decoding.bend as Integer
import ./packing.bend as P
import ./nat_bytes.bend as Digits
import ./primitive_invariants.bend as V
import ./word_facts.bend as Facts
import ../spec/layout_decoding.bend as Layout
import ../types/schema.bend as T

law embedded_value:
  for +bits: Word(8n)
  {U32.to_nat(D.embed8(bits)) == Word.to_nat(8n, bits) : Nat}
def embedded_value(bits):
  Equal.trans(Nat, U32.to_nat(D.embed8(bits)), Nat.add(Word.to_nat(8n, bits), 0n), Word.to_nat(8n, bits), NatWord.join_value(8n, 24n, bits, Word.zero(24n)), P.add_zero(Word.to_nat(8n, bits)))

law four_values:
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  {N.value([a, b, c, d]) == Nat.add(U32.to_nat(a), Nat.mul(Nat.add(U32.to_nat(b), Nat.mul(Nat.add(U32.to_nat(c), Nat.mul(U32.to_nat(d), 256n)), 256n)), 256n)) : Nat}
def four_values(a, b, c, d):
  %P.add_zero(U32.to_nat(d)) : {N.value([a, b, c, d]) == Nat.add(U32.to_nat(a), Nat.mul(Nat.add(U32.to_nat(b), Nat.mul(Nat.add(U32.to_nat(c), Nat.mul(_, 256n)), 256n)), 256n)) : Nat}
  {==}

law word_four_value:
  for +a: Word(8n)
  for +b: Word(8n)
  for +c: Word(8n)
  for +d: Word(8n)
  {Word.to_nat(32n, W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))) == Nat.add(Word.to_nat(8n, a), Nat.mul(Nat.add(Word.to_nat(8n, b), Nat.mul(Nat.add(Word.to_nat(8n, c), Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)) : Nat}
def word_four_value(a, b, c, d):
  %NatWord.join_value(8n, 8n, c, d) : {Word.to_nat(32n, W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))) == Nat.add(Word.to_nat(8n, a), Nat.mul(Nat.add(Word.to_nat(8n, b), Nat.mul(_, 256n)), 256n)) : Nat}
  %NatWord.join_value(8n, 16n, b, W.join(8n, 8n, c, d)) : {Word.to_nat(32n, W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))) == Nat.add(Word.to_nat(8n, a), Nat.mul(_, 256n)) : Nat}
  NatWord.join_value(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))

law embedded_four_values:
  for +a: Word(8n)
  for +b: Word(8n)
  for +c: Word(8n)
  for +d: Word(8n)
  {N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) == Nat.add(Word.to_nat(8n, a), Nat.mul(Nat.add(Word.to_nat(8n, b), Nat.mul(Nat.add(Word.to_nat(8n, c), Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)) : Nat}
def embedded_four_values(a, b, c, d):
  %embedded_value(a) : {N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) == Nat.add(_, Nat.mul(Nat.add(Word.to_nat(8n, b), Nat.mul(Nat.add(Word.to_nat(8n, c), Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)) : Nat}
  %embedded_value(b) : {N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) == Nat.add(U32.to_nat(D.embed8(a)), Nat.mul(Nat.add(_, Nat.mul(Nat.add(Word.to_nat(8n, c), Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)) : Nat}
  %embedded_value(c) : {N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) == Nat.add(U32.to_nat(D.embed8(a)), Nat.mul(Nat.add(U32.to_nat(D.embed8(b)), Nat.mul(Nat.add(_, Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)) : Nat}
  %embedded_value(d) : {N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) == Nat.add(U32.to_nat(D.embed8(a)), Nat.mul(Nat.add(U32.to_nat(D.embed8(b)), Nat.mul(Nat.add(U32.to_nat(D.embed8(c)), Nat.mul(_, 256n)), 256n)), 256n)) : Nat}
  four_values(D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d))

law embedded_limb:
  for +a: Word(8n)
  for +b: Word(8n)
  for +c: Word(8n)
  for +d: Word(8n)
  {S.limb_value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)], 0n) == U32{W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))} : U32}
def embedded_limb(a, b, c, d):
  Equal.trans(U32, S.limb_value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)], 0n), U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))), U32{W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))}, Equal.sym(U32, U32.or(D.embed8(a), U32.or(U32.shln(D.embed8(b), 8n), U32.or(U32.shln(D.embed8(c), 16n), U32.shln(D.embed8(d), 24n)))), S.limb_value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)], 0n), Integer.assembly_bytes(a, b, c, d)), A.pack_or4(a, b, c, d))

law embedded_limb_value:
  for +a: Word(8n)
  for +b: Word(8n)
  for +c: Word(8n)
  for +d: Word(8n)
  {U32.to_nat(S.limb_value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)], 0n)) == N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) : Nat}
def embedded_limb_value(a, b, c, d):
  %Equal.sym(U32, S.limb_value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)], 0n), U32{W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))}, embedded_limb(a, b, c, d)) : {U32.to_nat(_) == N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]) : Nat}
  Equal.trans(Nat, Word.to_nat(32n, W.join(8n, 24n, a, W.join(8n, 16n, b, W.join(8n, 8n, c, d)))), Nat.add(Word.to_nat(8n, a), Nat.mul(Nat.add(Word.to_nat(8n, b), Nat.mul(Nat.add(Word.to_nat(8n, c), Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)), N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]), word_four_value(a, b, c, d), Equal.sym(Nat, N.value([D.embed8(a), D.embed8(b), D.embed8(c), D.embed8(d)]), Nat.add(Word.to_nat(8n, a), Nat.mul(Nat.add(Word.to_nat(8n, b), Nat.mul(Nat.add(Word.to_nat(8n, c), Nat.mul(Word.to_nat(8n, d), 256n)), 256n)), 256n)), embedded_four_values(a, b, c, d)))
# Generated all-byte bridge.
law four_bytes:
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  for ea: {U32.is_lt(a, 256) == True{} : Bool}
  for eb: {U32.is_lt(b, 256) == True{} : Bool}
  for ec: {U32.is_lt(c, 256) == True{} : Bool}
  for ed: {U32.is_lt(d, 256) == True{} : Bool}
  {U32.to_nat(S.limb_value([a, b, c, d], 0n)) == N.value([a, b, c, d]) : Nat}
def four_bytes(a, b, c, d, ea, eb, ec, ed):
  %Equal.sym(U32, a, D.embed8(W.take(8n, 32n, D.bits(a))), Integer.byte_shape(a, ea)) : {U32.to_nat(S.limb_value([_, b, c, d], 0n)) == N.value([_, b, c, d]) : Nat}
  %Equal.sym(U32, b, D.embed8(W.take(8n, 32n, D.bits(b))), Integer.byte_shape(b, eb)) : {U32.to_nat(S.limb_value([D.embed8(W.take(8n, 32n, D.bits(a))), _, c, d], 0n)) == N.value([D.embed8(W.take(8n, 32n, D.bits(a))), _, c, d]) : Nat}
  %Equal.sym(U32, c, D.embed8(W.take(8n, 32n, D.bits(c))), Integer.byte_shape(c, ec)) : {U32.to_nat(S.limb_value([D.embed8(W.take(8n, 32n, D.bits(a))), D.embed8(W.take(8n, 32n, D.bits(b))), _, d], 0n)) == N.value([D.embed8(W.take(8n, 32n, D.bits(a))), D.embed8(W.take(8n, 32n, D.bits(b))), _, d]) : Nat}
  %Equal.sym(U32, d, D.embed8(W.take(8n, 32n, D.bits(d))), Integer.byte_shape(d, ed)) : {U32.to_nat(S.limb_value([D.embed8(W.take(8n, 32n, D.bits(a))), D.embed8(W.take(8n, 32n, D.bits(b))), D.embed8(W.take(8n, 32n, D.bits(c))), _], 0n)) == N.value([D.embed8(W.take(8n, 32n, D.bits(a))), D.embed8(W.take(8n, 32n, D.bits(b))), D.embed8(W.take(8n, 32n, D.bits(c))), _]) : Nat}
  embedded_limb_value(W.take(8n, 32n, D.bits(a)), W.take(8n, 32n, D.bits(b)), W.take(8n, 32n, D.bits(c)), W.take(8n, 32n, D.bits(d)))

law scope_value:
  for +xs: +List<U32>
  for +scope: {S.byte_scope(4n, xs) == True{} : Bool}
  {U32.to_nat(S.limb_value(xs, 0n)) == N.value(xs) : Nat}
def scope_value(xs, scope):
  match xs:
    case Nil{}: Empty.absurd({U32.to_nat(S.limb_value([], 0n)) == N.value([]) : Nat}, Facts.false_true(scope))
    case Con{a, Nil{}}: Empty.absurd({U32.to_nat(S.limb_value(a <> [], 0n)) == N.value(a <> []) : Nat}, Facts.false_true(V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, []), scope)))
    case Con{a, Con{b, Nil{}}}: Empty.absurd({U32.to_nat(S.limb_value(a <> b <> [], 0n)) == N.value(a <> b <> []) : Nat}, Facts.false_true(V.and_right(U32.is_lt(b, 256), S.byte_scope(2n, []), V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, b <> []), scope))))
    case Con{a, Con{b, Con{c, Nil{}}}}: Empty.absurd({U32.to_nat(S.limb_value(a <> b <> c <> [], 0n)) == N.value(a <> b <> c <> []) : Nat}, Facts.false_true(V.and_right(U32.is_lt(c, 256), S.byte_scope(1n, []), V.and_right(U32.is_lt(b, 256), S.byte_scope(2n, c <> []), V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, b <> c <> []), scope)))))
    case Con{a, Con{b, Con{c, Con{d, Nil{}}}}}: four_bytes(a, b, c, d, V.and_left(U32.is_lt(a, 256), S.byte_scope(3n, b <> c <> d <> []), scope), V.and_left(U32.is_lt(b, 256), S.byte_scope(2n, c <> d <> []), V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, b <> c <> d <> []), scope)), V.and_left(U32.is_lt(c, 256), S.byte_scope(1n, d <> []), V.and_right(U32.is_lt(b, 256), S.byte_scope(2n, c <> d <> []), V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, b <> c <> d <> []), scope))), V.and_left(U32.is_lt(d, 256), S.byte_scope(0n, []), V.and_right(U32.is_lt(c, 256), S.byte_scope(1n, d <> []), V.and_right(U32.is_lt(b, 256), S.byte_scope(2n, c <> d <> []), V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, b <> c <> d <> []), scope)))))
    case Con{a, Con{b, Con{c, Con{d, Con{e, tail}}}}}: Empty.absurd({U32.to_nat(S.limb_value(a <> b <> c <> d <> e <> tail, 0n)) == N.value(a <> b <> c <> d <> e <> tail) : Nat}, Facts.false_true(V.and_right(U32.is_lt(d, 256), S.byte_scope(0n, e <> tail), V.and_right(U32.is_lt(c, 256), S.byte_scope(1n, d <> e <> tail), V.and_right(U32.is_lt(b, 256), S.byte_scope(2n, c <> d <> e <> tail), V.and_right(U32.is_lt(a, 256), S.byte_scope(3n, b <> c <> d <> e <> tail), scope))))))

# Every representable normative offset is read as exactly that natural number.
# Fits is the protocol's uint32 range, not a runtime or fixture-size cap.
law offset_digits:
  for +offset: Nat
  for fit: {N.fits(4n, offset) == True{} : Bool}
  {U32.to_nat(S.limb_value(N.digits(4n, offset), 0n)) == offset : Nat}
def offset_digits(offset, fit):
  Equal.trans(Nat, U32.to_nat(S.limb_value(N.digits(4n, offset), 0n)), N.value(N.digits(4n, offset)), offset, scope_value(N.digits(4n, offset), Digits.digits_scope(4n, offset)), Digits.digits_value(4n, offset, fit))

law field_offset:
  for +offset: Nat
  for fit: {N.fits(4n, offset) == True{} : Bool}
  {Layout.field(None{}, N.digits(4n, offset)) == T.Offset{offset} : T.Header}
def field_offset(offset, fit):
  Equal.cong(Nat, T.Header, x => T.Offset{x}, U32.to_nat(S.limb_value(N.digits(4n, offset), 0n)), offset, offset_digits(offset, fit))
