import Base
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../spec/root_relation.bend as RR
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vmv.bend as VMV
import ./pb_min.bend as PB

# Lists of uint8 (List[uint8, N]): the items of a byte string (PB.it1) have
# the string's bytes as their spec parts, one fixed byte each, and the list's
# encoding is the string itself.

def sparts(xs: +List<U32>) -> +List<S.Part>:
  match xs:
    case Nil{}: []
    case Con{x, t}: S.Fixed{[x]} <> sparts(t)

law u8p:
  for +x: U32
  for +e: {U32.is_lt(x, 256) == True{} : Bool}
  {Codec.parts(S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}) == Some{[S.Fixed{[x]}]} : Maybe<&2, +List<S.Part>>}
def u8p(x, e):
  %Equal.sym(Maybe<&2, +List<U32>>, RR.basic_one(S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}), Some{[x]}, PB.bone(x, e)) :
    {Codec.one(_, Some{1n}) == Some{[S.Fixed{[x]}]} : Maybe<&2, +List<S.Part>>}
  {==}

law u8parts:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(k, xs) == True{} : Bool}
  {Codec.parts(PB.it1(k, xs), S.Repeat{S.Unsigned{P.U8{}}}) == Some{sparts(xs)} : Maybe<&2, +List<S.Part>>}
def u8parts(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({Codec.parts(S.EmptyItems{}, S.Repeat{S.Unsigned{P.U8{}}}) == Some{sparts(x <> t)} : Maybe<&2, +List<S.Part>>}, F.logic__false_true(hs))
    case 1n+ +c Nil{}: Empty.absurd({Codec.parts(S.EmptyItems{}, S.Repeat{S.Unsigned{P.U8{}}}) == Some{[]} : Maybe<&2, +List<S.Part>>}, F.logic__false_true(hs))
    case 1n+ +c Con{+x, +t}:
      FX.cat_fixed(Codec.parts(S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U8{}}), [x], Codec.parts(PB.it1(c, t), S.Repeat{S.Unsigned{P.U8{}}}), sparts(t),
        u8p(x, F.logic__and_left(U32.is_lt(x, 256), SP.byte_scope(c, t), hs)), u8parts(c, t, F.logic__and_right(U32.is_lt(x, 256), SP.byte_scope(c, t), hs)))

law scope_len:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(k, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == k : Nat}
def scope_len(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({List.length(&2, U32, x <> t) == 0n : Nat}, F.logic__false_true(hs))
    case 1n+ +c Nil{}: Empty.absurd({0n == 1n+c : Nat}, F.logic__false_true(hs))
    case 1n+ +c Con{+x, +t}: Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, t), c, scope_len(c, t, F.logic__and_right(U32.is_lt(x, 256), SP.byte_scope(c, t), hs)))

law count_it1:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(k, xs) == True{} : Bool}
  {Codec.count(PB.it1(k, xs)) == k : Nat}
def count_it1(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: {==}
    case 1n+ +c Nil{}: Empty.absurd({0n == 1n+c : Nat}, F.logic__false_true(hs))
    case 1n+ +c Con{+x, +t}: Equal.cong(Nat, Nat, z => 1n+z, Codec.count(PB.it1(c, t)), c, count_it1(c, t, F.logic__and_right(U32.is_lt(x, 256), SP.byte_scope(c, t), hs)))

law scope_valid:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(k, xs) == True{} : Bool}
  {Layout.bytes_valid(sparts(xs)) == True{} : Bool}
def scope_valid(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({Layout.bytes_valid(sparts(x <> t)) == True{} : Bool}, F.logic__false_true(hs))
    case 1n+ +c Nil{}: {==}
    case 1n+ +c Con{+x, +t}:
      F.logic__and_intro(SP.bytes_domain([x]), Layout.bytes_valid(sparts(t)),
        F.logic__and_intro(U32.is_lt(x, 256), True{}, F.logic__and_left(U32.is_lt(x, 256), SP.byte_scope(c, t), hs), {==}),
        scope_valid(c, t, F.logic__and_right(U32.is_lt(x, 256), SP.byte_scope(c, t), hs)))

law sp_size:
  for +xs: +List<U32>
  {Layout.fixed_size(sparts(xs)) == List.length(&2, U32, xs) : Nat}
def sp_size(xs):
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(Nat, Nat, z => 1n+z, Layout.fixed_size(sparts(t)), List.length(&2, U32, t), sp_size(t))

law sp_fp:
  for +xs: +List<U32>
  for +o: Nat
  {Layout.fixed_parts(sparts(xs), o) == xs : +List<U32>}
def sp_fp(xs, o):
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => x <> z, Layout.fixed_parts(sparts(t), o), t, sp_fp(t, o))

law sp_pay:
  for +xs: +List<U32>
  {Layout.payloads(sparts(xs)) == [] : +List<U32>}
def sp_pay(xs):
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}: sp_pay(t)

# The spec parts of the list of a byte string's bytes: one variable part, the string.
law listu8_parts:
  for +k: Nat
  for +xs: +List<U32>
  for +lim: Nat
  for +hk: {Nat.is_le(k, lim) == True{} : Bool}
  for +hs: {SP.byte_scope(k, xs) == True{} : Bool}
  for +hfit: {N.fits(4n, k) == True{} : Bool}
  {Codec.parts(S.Sequence{PB.it1(k, xs)}, S.ListOf{S.Unsigned{P.U8{}}, lim}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
def listu8_parts(k, xs, lim, hk, hs, hfit):
  %Equal.sym(Nat, Codec.count(PB.it1(k, xs)), k, count_it1(k, xs, hs)) :
    {Codec.require(Nat.is_le(_, lim), Codec.aggregate(Codec.parts(PB.it1(k, xs), S.Repeat{S.Unsigned{P.U8{}}}), None{})) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Nat.is_le(k, lim), True{}, hk) :
    {Codec.require(_, Codec.aggregate(Codec.parts(PB.it1(k, xs), S.Repeat{S.Unsigned{P.U8{}}}), None{})) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(PB.it1(k, xs), S.Repeat{S.Unsigned{P.U8{}}}), Some{sparts(xs)}, u8parts(k, xs, hs)) :
    {Codec.require(True{}, Codec.aggregate(_, None{})) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(sparts(xs)), Some{List.append(&2, U32, xs, [])},
      VMV.enc_gen(sparts(xs), k, xs, [], Equal.trans(Nat, Layout.fixed_size(sparts(xs)), List.length(&2, U32, xs), k, sp_size(xs), scope_len(k, xs, hs)),
        sp_fp(xs, k), sp_pay(xs), scope_valid(k, xs, hs),
        F.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, F.nat__add_zero(k)), hfit))) :
    {Codec.one(_, None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, xs, []), xs, VS.app_nil(xs)) : {Codec.one(Some{_}, None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  {==}

# A string of bytes is in byte scope at its length.
law dom_scope:
  for +xs: +List<U32>
  for +hd: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.byte_scope(List.length(&2, U32, xs), xs) == True{} : Bool}
def dom_scope(xs, hd):
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}:
      F.logic__and_intro(U32.is_lt(x, 256), SP.byte_scope(List.length(&2, U32, t), t), F.logic__and_left(U32.is_lt(x, 256), SP.bytes_domain(t), hd),
        dom_scope(t, F.logic__and_right(U32.is_lt(x, 256), SP.bytes_domain(t), hd)))
