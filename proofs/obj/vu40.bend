import Base
import ../../spec/codec.bend as Codec
import ../../spec/layout.bend as Layout
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../compact/found_generated.bend as F
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vu32.bend as VU
import ../../spec/tree.bend as TR
import ../../proofs/nat_order.bend as Order
import ./lim_sym.bend as LSY

# Lists whose limit exceeds what a 32-bit length can hold (2^40): the length's
# bound replaces the count check. The limits are compared symbolically (as
# capacities, never evaluated); the big flag compares the identical terms.

# ---- the 2^40 limit, symbolically (never evaluated) -------------------------------------------

def d10(x: Nat) -> Nat: Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(x))))))))))

law m10:
  for +x: Nat
  {d10(x) == Nat.mul(x, 1024n) : Nat}
def m10(x):
  match x:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, d10(p), Nat.mul(p, 1024n), m10(p)) : {1024n+_ == Nat.add(1024n, Nat.mul(p, 1024n)) : Nat}
      {==}

# The 2^40 limit of the Fulu schemas as a capacity.
def pow40() -> {Nat.mul(U32.to_nat(1073741824), 1024n) == TR.capacity(40n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(1073741824), TR.capacity(30n), LSY.pow30()) : {Nat.mul(_, 1024n) == TR.capacity(40n) : Nat}
  Equal.sym(Nat, d10(TR.capacity(30n)), Nat.mul(TR.capacity(30n), 1024n), m10(TR.capacity(30n)))

law sb_cap:
  for +n: Nat
  {F.spec_numeric__scale_binary(n, 1n) == TR.capacity(n) : Nat}
def sb_cap(n):
  match n:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => Nat.double(z), F.spec_numeric__scale_binary(p, 1n), TR.capacity(p), sb_cap(p))

law cap_mono:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(TR.capacity(a), TR.capacity(b)) == True{} : Bool}
def cap_mono(a, b, h):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+ +q: F.nat__le_trans(1n, TR.capacity(q), Nat.double(TR.capacity(q)), cap_mono(0n, q, F.nat__zero_le(q)), F.nat__double_self_le(TR.capacity(q)))
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(Nat.double(TR.capacity(p)), 1n) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: Order.double_monotone(TR.capacity(p), TR.capacity(q), cap_mono(p, q, h))

# Every U32 is below 2^32.
def u32cap(+u: U32) -> {Nat.is_lt(U32.to_nat(u), TR.capacity(32n)) == True{} : Bool}:
  match u:
    case U32{+w}:
      %Equal.sym(Nat, Word.to_nat(32n, w), F.spec_numeric__unsigned(32n, w), F.lru_numeric__primitive_word_interpretation(32n, w)) : {Nat.is_lt(_, TR.capacity(32n)) == True{} : Bool}
      F.logic__subst(Nat, z => {Nat.is_lt(F.spec_numeric__unsigned(32n, w), z) == True{} : Bool}, F.spec_numeric__scale_binary(32n, 1n), TR.capacity(32n), sb_cap(32n), F.u32__WB_unsigned(32n, w))

# Every U32 is at most 2^40.
def u32le40(+u: U32) -> {Nat.is_le(U32.to_nat(u), Nat.mul(U32.to_nat(1073741824), 1024n)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(u), z) == True{} : Bool}, TR.capacity(40n), Nat.mul(U32.to_nat(1073741824), 1024n),
    Equal.sym(Nat, Nat.mul(U32.to_nat(1073741824), 1024n), TR.capacity(40n), pow40()),
    F.nat__le_trans(U32.to_nat(u), TR.capacity(32n), TR.capacity(40n), F.nat__lt_le(U32.to_nat(u), TR.capacity(32n), u32cap(u)), cap_mono(32n, 40n, {==})))

law x8ge:
  for +c: Nat
  {Nat.is_le(c, VS.x8(c)) == True{} : Bool}
def x8ge(c):
  match c:
    case 0n: {==}
    case 1n+ +p: F.nat__le_trans(1n+p, 1n+VS.x8(p), 8n+VS.x8(p), x8ge(p), Order.add_right(1n, 8n, VS.x8(p), {==}))

# A whole number of e-byte elements (the first half of VU.whole_t, without a count limit).
def whole_e(+L: U32, +e: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool}, +h1: {U32.is_eq(L, U32.mul(U32.div(L, e), e)) == True{} : Bool})
    -> {U32.to_nat(L) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat}:
  Equal.trans(Nat, U32.to_nat(L), U32.to_nat(U32.mul(U32.div(L, e), e)), Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)),
    Equal.cong(U32, Nat, x => U32.to_nat(x), L, U32.mul(U32.div(L, e), e), F.u32alg__eq_of(L, U32.mul(U32.div(L, e), e), h1)),
    VU.mul_le(U32.div(L, e), e, L, VU.whole_parts(L, e, v, eb, hb, hz, VU.div_u32(L, e, v, eb, hb, hz))))

# VS.list_u64_parts with the fit of the list's own bytes (not of the limit's).
law list_u64_partsk:
  for +k: Nat
  for +W: List<&2, U32>
  for +lim: Nat
  for +hk: {Nat.is_le(k, lim) == True{} : Bool}
  for +hfit: {N.fits(4n, VS.x8(k)) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {Codec.parts(S.Sequence{VS.uitems(k, W)}, S.ListOf{S.Unsigned{P.U64{}}, lim}) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
def list_u64_partsk(k, W, lim, hk, hfit, hl):
  +fit = VS.fits_mono(4n, List.length(&2, U32, FX.flat(VS.upairs(k, W))), VS.x8(k),
    F.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(k)) == True{} : Bool}, VS.x8(VS.upairs_n(k, W)), List.length(&2, U32, FX.flat(VS.upairs(k, W))),
      Equal.sym(Nat, List.length(&2, U32, FX.flat(VS.upairs(k, W))), VS.x8(VS.upairs_n(k, W)), VS.len_flat_upairs(k, W)),
      VS.x8_mono(VS.upairs_n(k, W), k, VS.upairs_n_le(k, W))),
    hfit)
  %Equal.sym(Nat, Codec.count(VS.uitems(k, W)), k, VS.count_uitems(k, W, hl)) :
    {Codec.require(Nat.is_le(_, lim), Codec.aggregate(Codec.parts(VS.uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}), None{})) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Nat.is_le(k, lim), True{}, hk) :
    {Codec.require(_, Codec.aggregate(Codec.parts(VS.uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}), None{})) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VS.uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}), Some{FX.fparts(VS.upairs(k, W))}, VS.u64_parts(k, W)) :
    {Codec.require(True{}, Codec.aggregate(_, None{})) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(FX.fparts(VS.upairs(k, W))), Some{FX.flat(VS.upairs(k, W))}, VS.encoding_fparts(VS.upairs(k, W), fit)) :
    {Codec.one(_, None{}) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, FX.flat(VS.upairs(k, W)), FX.limbs(VS.wtake(Nat.double(VS.upairs_n(k, W)), W)), VS.flat_upairs(k, W)) :
    {Codec.one(Some{_}, None{}) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Nat, VS.upairs_n(k, W), k, VS.upairs_n_eq(k, W, hl)) :
    {Codec.one(Some{FX.limbs(VS.wtake(Nat.double(_), W))}, None{}) == Some{[S.Variable{FX.limbs(VS.wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  {==}
