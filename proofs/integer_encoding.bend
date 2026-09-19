import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T
import ./word_split.bend as B
import ./power_division.bend as D
import ./prefix.bend as P
import ./primitives.bend as Basic
import ./basic_root.bend as Root

law mask_modulo:
  for +x: U32
  {U32.and(x, 255) == U32.mod(x, 256) : U32}
def mask_modulo(x):
  match x:
    case U32{w}:
      %Equal.sym(U32, U32.mod(U32{w}, 256), D.embed8(B.take(8n, 32n, w)), D.remainder8(U32{w})) : {U32.and(U32{w}, 255) == _ : U32}
      Equal.cong(Word(32n), U32, w => U32{w},
        Word.and(32n, w, B.join(8n, 24n, B.ones(8n), Word.zero(24n))),
        B.join(8n, 24n, B.take(8n, 32n, w), Word.zero(24n)), B.mask_take(8n, 24n, w))

law second_digit:
  for +x: U32
  {U32.and(U32.shrn(x, 8n), 255) == U32.mod(U32.div(x, 256), 256) : U32}
def second_digit(x):
  %Equal.sym(U32, U32.div(x, 256), U32.shrn(x, 8n), D.div_shift8(x)) :
    {U32.and(U32.shrn(x, 8n), 255) == U32.mod(_, 256) : U32}
  mask_modulo(U32.shrn(x, 8n))

law third_digit:
  for +x: U32
  {U32.and(U32.shrn(x, 16n), 255) == U32.mod(U32.div(x, 65536), 256) : U32}
def third_digit(x):
  %Equal.sym(U32, U32.div(x, 65536), U32.shrn(x, 16n), D.div_shift16(x)) :
    {U32.and(U32.shrn(x, 16n), 255) == U32.mod(_, 256) : U32}
  mask_modulo(U32.shrn(x, 16n))

law limb_correct:
  for +x: U32
  {I.limb(x) == S.limb_digits(x) : +List<U32>}
def limb_correct(x):
  %mask_modulo(x) :
    {I.limb(x) == [_, U32.mod(U32.div(x, 256), 256), U32.mod(U32.div(x, 65536), 256), U32.div(x, 16777216)] : +List<U32>}
  %second_digit(x) :
    {I.limb(x) == [U32.and(x, 255), _, U32.mod(U32.div(x, 65536), 256), U32.div(x, 16777216)] : +List<U32>}
  %third_digit(x) :
    {I.limb(x) == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), _, U32.div(x, 16777216)] : +List<U32>}
  %Equal.sym(U32, U32.div(x, 16777216), U32.shrn(x, 24n), D.div_shift24(x)) :
    {I.limb(x) == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), U32.and(U32.shrn(x, 16n), 255), _] : +List<U32>}
  {==}

law all_digits_correct:
  for +v: T.UInt
  {I.uint_bytes(v) == S.full_digits(v) : +List<U32>}
def all_digits_correct(v):
  match v:
    case T.UInt{a, b, c, d, e, f, g, h}:
      %limb_correct(a) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, _, List.append(&2, U32, S.limb_digits(b), List.append(&2, U32, S.limb_digits(c), List.append(&2, U32, S.limb_digits(d), List.append(&2, U32, S.limb_digits(e), List.append(&2, U32, S.limb_digits(f), List.append(&2, U32, S.limb_digits(g), S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(b) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, _, List.append(&2, U32, S.limb_digits(c), List.append(&2, U32, S.limb_digits(d), List.append(&2, U32, S.limb_digits(e), List.append(&2, U32, S.limb_digits(f), List.append(&2, U32, S.limb_digits(g), S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(c) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, _, List.append(&2, U32, S.limb_digits(d), List.append(&2, U32, S.limb_digits(e), List.append(&2, U32, S.limb_digits(f), List.append(&2, U32, S.limb_digits(g), S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(d) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, _, List.append(&2, U32, S.limb_digits(e), List.append(&2, U32, S.limb_digits(f), List.append(&2, U32, S.limb_digits(g), S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(e) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, _, List.append(&2, U32, S.limb_digits(f), List.append(&2, U32, S.limb_digits(g), S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(f) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, _, List.append(&2, U32, S.limb_digits(g), S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(g) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, _, S.limb_digits(h)))))))) : +List<U32>}
      %limb_correct(h) : {I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h}) == List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, I.limb(g), _))))))) : +List<U32>}
      {==}

law uint_serialize_correct:
  for +w: T.Width
  for +v: T.UInt
  {I.uint_serialize(w, v) == S.uint_encoding(w, v) : Maybe<&2, +List<U32>>}
def uint_serialize_correct(w, v):
  %Basic.width_correct(w) :
    {I.uint_serialize(w, v) == S.optional(S.fits(_, S.full_digits(v)), S.prefix(_, S.full_digits(v))) : Maybe<&2, +List<U32>>}
  %all_digits_correct(v) :
    {I.uint_serialize(w, v) == S.optional(S.fits(I.width(w), _), S.prefix(I.width(w), _)) : Maybe<&2, +List<U32>>}
  P.narrow_correct(I.width(w), I.uint_bytes(v))

law uint_domain_correct:
  for +w: T.Width
  for +v: T.UInt
  {I.uint_valid(w, v) == S.uint_domain(w, v) : Bool}
def uint_domain_correct(w, v):
  %Basic.width_correct(w) : {I.uint_valid(w, v) == S.fits(_, S.full_digits(v)) : Bool}
  %all_digits_correct(v) : {I.uint_valid(w, v) == S.fits(I.width(w), _) : Bool}
  P.narrow_domain_correct(I.width(w), I.uint_bytes(v))

law padding_optional:
  for ok: Bool
  for n: Nat
  for xs: +List<U32>
  {S.pad_encoding(n, S.optional(ok, xs)) == S.optional(ok, List.append(&2, U32, xs, S.zero_bytes(n))) : Maybe<&2, +List<U32>>}
def padding_optional(ok, n, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law uint_hash_tree_root_correct:
  for +w: T.Width
  for +v: T.UInt
  {I.uint_root(w, v) == S.uint_hash_tree_root(w, v) : Maybe<&2, +List<U32>>}
def uint_hash_tree_root_correct(w, v):
  %Equal.sym(Maybe<&2, +List<U32>>, I.uint_root(w, v), S.pad_encoding(Nat.sub(32n, I.width(w)), I.uint_serialize(w, v)), Root.uint_root_from_encoding(w, v)) :
    {_ == S.uint_hash_tree_root(w, v) : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, I.width(w), S.byte_width(w), Basic.width_correct(w)) :
    {S.pad_encoding(Nat.sub(32n, _), I.uint_serialize(w, v)) == S.uint_hash_tree_root(w, v) : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<U32>>, I.uint_serialize(w, v), S.uint_encoding(w, v), uint_serialize_correct(w, v)) :
    {S.pad_encoding(Nat.sub(32n, S.byte_width(w)), _) == S.uint_hash_tree_root(w, v) : Maybe<&2, +List<U32>>}
  padding_optional(S.uint_domain(w, v), Nat.sub(32n, S.byte_width(w)), S.prefix(S.byte_width(w), S.full_digits(v)))
