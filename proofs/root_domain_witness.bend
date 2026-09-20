import Base
import ../types/schema.bend as T
import ../spec/value_domain.bend as VD
import ../spec/codec.bend as SC
import ../spec/layout.bend as E
import ../spec/schema.bend as SS
import ../spec/primitives.bend as SP
import ../spec/bytes.bend as SBytes
import ../spec/nat_bytes.bend as SLen
import ../spec/type_legality.bend as Legal
import ../src/primitives.bend as IP
import ./root_total_steps.bend as TS
import ./root_total.bend as Total
import ./root_domain_compat.bend as Compat
import ./codec_inverse.bend as ByteLength
import ./exact_division.bend as Division
import ./nat_algebra.bend as A
import ./layout.bend as LayoutLaws
import ./bit_vector_canonical.bend as Canon
import ./packing.bend as Packing
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./lists.bend as L

# Strict extension witness family (symbolic; nothing is allocated, and no
# 2^32-scale literal is evaluated). For every r, with fanout F = 256*(1+r):
#   nest_schema(3, r) = Vector[Vector[Vector[ByteVector[256], F], F], F]
# is a legal fixed-size composite type whose serialization would be
# 256*F^3 >= 2^32 bytes, violating the serializer's strict bound < 2^32. Its
# values (for ANY 256-byte leaf) are structurally valid, their mixed lengths
# are trivially uint256, and they have Merkle roots (computed over child
# roots); none of them is serializable. r = 0 is the smallest member
# (Vector[Vector[Vector[Bytes256, 256], 256], 256], exactly 2^32 bytes).

def fan(+r: Nat) -> Nat: Nat.mul(256n, 1n+r)

def copies(k: Nat, +v: T.Value) -> T.Value:
  match k:
    case 0n: T.EmptyItems{}
    case 1n+p: T.Items{v, copies(p, v)}

def nest_schema(d: Nat, +r: Nat) -> T.Schema:
  match d:
    case 0n: T.ByteVector{256n}
    case 1n+p: T.Vector{nest_schema(p, r), fan(r)}

def nest_value(d: Nat, +r: Nat, +xs: +List<U32>) -> T.Value:
  match d:
    case 0n: T.BytesValue{xs}
    case 1n+p: T.Sequence{copies(fan(r), nest_value(p, r, xs))}

# Serialized size of nest_schema(d, r): 256*F^d, as a symbolic product.
def size(d: Nat, +r: Nat) -> Nat:
  match d:
    case 0n: 256n
    case 1n+p: Nat.mul(fan(r), size(p, r))

# ---------------------------------------------------------------------------
# Legality, structural validity and mixer representability for every depth.

law legal_nest:
  for +d: Nat
  for +r: Nat
  Legal.type_legal(nest_schema(d, r))
def legal_nest(d, r):
  match d:
    case 0n: ({==}, {==})
    case 1n+p: ({==}, ({==}, legal_nest(p, r)))

law copies_length:
  for +k: Nat
  for +v: T.Value
  {VD.items_length(copies(k, v)) == k : Nat}
def copies_length(k, v):
  match k:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, x => 1n+x, VD.items_length(copies(p, v)), p, copies_length(p, v))

law copies_valid:
  for +k: Nat
  for +v: T.Value
  for +s: T.Schema
  for +ev: {VD.root_valid(v, s) == True{} : Bool}
  {VD.root_valid(copies(k, v), T.Repeat{s}) == True{} : Bool}
def copies_valid(k, v, s, ev):
  match k:
    case 0n: {==}
    case 1n+p: V.and_true(VD.root_valid(v, s), VD.root_valid(copies(p, v), T.Repeat{s}), ev, copies_valid(p, v, s, ev))

law copies_mixing:
  for +k: Nat
  for +v: T.Value
  for +s: T.Schema
  for +ev: {VD.mixing_lengths(v, s) == True{} : Bool}
  {VD.mixing_lengths(copies(k, v), T.Repeat{s}) == True{} : Bool}
def copies_mixing(k, v, s, ev):
  match k:
    case 0n: {==}
    case 1n+p: V.and_true(VD.mixing_lengths(v, s), VD.mixing_lengths(copies(p, v), T.Repeat{s}), ev, copies_mixing(p, v, s, ev))

law vector_count:
  for +v: T.Value
  for +r: Nat
  {Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(VD.items_length(copies(fan(r), v)), fan(r))) == True{} : Bool}
def vector_count(v, r):
  %Equal.sym(Nat, VD.items_length(copies(fan(r), v)), fan(r), copies_length(fan(r), v)) : {Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(_, fan(r))) == True{} : Bool}
  V.and_true(Nat.is_lt(0n, fan(r)), Nat.is_eq(fan(r), fan(r)), {==}, Canon.nat_equal_refl(fan(r)))

law nest_valid:
  for +d: Nat
  for +r: Nat
  for +xs: +List<U32>
  for +leaf: {SP.byte_scope(256n, xs) == True{} : Bool}
  {VD.root_valid(nest_value(d, r, xs), nest_schema(d, r)) == True{} : Bool}
def nest_valid(d, r, xs, leaf):
  match d:
    case 0n: leaf
    case 1n+p:
      V.and_true(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(VD.items_length(copies(fan(r), nest_value(p, r, xs))), fan(r))), VD.root_valid(copies(fan(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}),
        vector_count(nest_value(p, r, xs), r),
        copies_valid(fan(r), nest_value(p, r, xs), nest_schema(p, r), nest_valid(p, r, xs, leaf)))

law nest_mixing:
  for +d: Nat
  for +r: Nat
  for +xs: +List<U32>
  {VD.mixing_lengths(nest_value(d, r, xs), nest_schema(d, r)) == True{} : Bool}
def nest_mixing(d, r, xs):
  match d:
    case 0n: {==}
    case 1n+p: copies_mixing(fan(r), nest_value(p, r, xs), nest_schema(p, r), nest_mixing(p, r, xs))

law nest_domain:
  for +d: Nat
  for +r: Nat
  for +xs: +List<U32>
  for +leaf: {SP.byte_scope(256n, xs) == True{} : Bool}
  {VD.root_domain(nest_schema(d, r), nest_value(d, r, xs)) == True{} : Bool}
def nest_domain(d, r, xs, leaf):
  V.and_true(VD.root_valid(nest_value(d, r, xs), nest_schema(d, r)), VD.mixing_lengths(nest_value(d, r, xs), nest_schema(d, r)), nest_valid(d, r, xs, leaf), nest_mixing(d, r, xs))

# ---------------------------------------------------------------------------
# Serialization shape: every existing encoding part of nest_value(d) is one
# fixed part of exactly size(d) bytes.

def fixed_one(n: Nat, r: Maybe<&2, +List<T.Part>>) -> Type:
  match r:
    case None{}: Unit
    case Some{ps}:
      match ps:
        case Nil{}: Empty
        case Con{h, t}:
          match h:
            case T.Fixed{b}:
              match t:
                case Nil{}: {List.length(&2, U32, b) == n : Nat}
                case Con{a, rest}: Empty
            case T.Variable{b}: Empty

def rep_one(k: Nat, n: Nat, r: Maybe<&2, +List<T.Part>>) -> Type:
  match r:
    case None{}: Unit
    case Some{cps}: Compat.all_fixed(cps) & {E.fixed_size(cps) == Nat.mul(k, n) : Nat} & {E.payloads(cps) == [] : +List<U32>}

law rep_cons:
  for +b: +List<U32>
  for +cps: +List<T.Part>
  for +p: Nat
  for +n: Nat
  for +len: {List.length(&2, U32, b) == n : Nat}
  for rest: Compat.all_fixed(cps) & {E.fixed_size(cps) == Nat.mul(p, n) : Nat} & {E.payloads(cps) == [] : +List<U32>}
  rep_one(1n+p, n, Some{T.Fixed{b} <> cps})
def rep_cons(b, cps, p, n, len, rest):
  (af, (fs, pl)) = rest
  (af, (Equal.trans(Nat, Nat.add(List.length(&2, U32, b), E.fixed_size(cps)), Nat.add(n, E.fixed_size(cps)), Nat.add(n, Nat.mul(p, n)), Equal.cong(Nat, Nat, x => Nat.add(x, E.fixed_size(cps)), List.length(&2, U32, b), n, len), Equal.cong(Nat, Nat, x => Nat.add(n, x), E.fixed_size(cps), Nat.mul(p, n), fs)), pl))

law rep_step:
  for +b: +List<U32>
  for +r2: Maybe<&2, +List<T.Part>>
  for +p: Nat
  for +n: Nat
  for +len: {List.length(&2, U32, b) == n : Nat}
  for rest: rep_one(p, n, r2)
  rep_one(1n+p, n, SC.concatenate(Some{[T.Fixed{b}]}, r2))
def rep_step(b, r2, p, n, len, rest):
  match r2:
    case None{}: Unit{}
    case Some{cps}: rep_cons(b, cps, p, n, len, rest)

law rep_shape:
  for +k: Nat
  for +v: T.Value
  for +s: T.Schema
  for +n: Nat
  for +b: +List<U32>
  for +same: {SC.parts(v, s) == Some{[T.Fixed{b}]} : Maybe<&2, +List<T.Part>>}
  for +len: {List.length(&2, U32, b) == n : Nat}
  rep_one(k, n, SC.parts(copies(k, v), T.Repeat{s}))
def rep_shape(k, v, s, n, b, same, len):
  match k:
    case 0n: (Unit{}, ({==}, {==}))
    case 1n+p:
      %Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(v, s), Some{[T.Fixed{b}]}, same) : rep_one(1n+p, n, SC.concatenate(_, SC.parts(copies(p, v), T.Repeat{s})))
      rep_step(b, SC.parts(copies(p, v), T.Repeat{s}), p, n, len, rep_shape(p, v, s, n, b, same, len))

law leaf_shape:
  for +ok: Bool
  for +xs: +List<U32>
  for +n: Nat
  for len: {ok == True{} : Bool} -> {List.length(&2, U32, xs) == n : Nat}
  fixed_one(n, SC.one(SP.optional(ok, xs), Some{n}))
def leaf_shape(ok, xs, n, len):
  match ok:
    case False{}: Unit{}
    case True{}: len({==})

law flat_length:
  for +cps: +List<T.Part>
  for af: Compat.all_fixed(cps)
  {List.length(&2, U32, Compat.flat(cps)) == E.fixed_size(cps) : Nat}
def flat_length(cps, af):
  match cps:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, xs, Compat.flat(t))), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, Compat.flat(t))), Nat.add(List.length(&2, U32, xs), E.fixed_size(t)),
            L.append_length(U32, xs, Compat.flat(t)),
            Equal.cong(Nat, Nat, x => Nat.add(List.length(&2, U32, xs), x), List.length(&2, U32, Compat.flat(t)), E.fixed_size(t), flat_length(t, af)))
        case T.Variable{xs}:
          match af:

law fixed_twice:
  for +cps: +List<T.Part>
  for af: Compat.all_fixed(cps)
  Compat.all_fixed(cps) & Compat.all_fixed(cps)
def fixed_twice(cps, af):
  match cps:
    case Nil{}: (Unit{}, Unit{})
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: fixed_twice(t, af)
        case T.Variable{xs}:
          match af:

law encoded_length_pair:
  for +cps: +List<T.Part>
  for +b: +List<U32>
  for +k: Nat
  for +n: Nat
  for pair: Compat.all_fixed(cps) & Compat.all_fixed(cps)
  for +fs: {E.fixed_size(cps) == Nat.mul(k, n) : Nat}
  for +enc: {E.encoding(cps) == Some{b} : Maybe<&2, +List<U32>>}
  {List.length(&2, U32, b) == Nat.mul(k, n) : Nat}
def encoded_length_pair(cps, b, k, n, pair, fs, enc):
  (a1, a2) = pair
  Equal.trans(Nat, List.length(&2, U32, b), List.length(&2, U32, Compat.flat(cps)), Nat.mul(k, n),
    Equal.cong(+List<U32>, Nat, x => List.length(&2, U32, x), b, Compat.flat(cps), Compat.basic_encoding(cps, b, a1, enc)),
    Equal.trans(Nat, List.length(&2, U32, Compat.flat(cps)), E.fixed_size(cps), Nat.mul(k, n), flat_length(cps, a2), fs))

law encoded_length:
  for +cps: +List<T.Part>
  for +b: +List<U32>
  for +k: Nat
  for +n: Nat
  for af: Compat.all_fixed(cps)
  for +fs: {E.fixed_size(cps) == Nat.mul(k, n) : Nat}
  for +enc: {E.encoding(cps) == Some{b} : Maybe<&2, +List<U32>>}
  {List.length(&2, U32, b) == Nat.mul(k, n) : Nat}
def encoded_length(cps, b, k, n, af, fs, enc): encoded_length_pair(cps, b, k, n, fixed_twice(cps, af), fs, enc)

law enc_shape:
  for +cps: +List<T.Part>
  for +encm: Maybe<&2, +List<U32>>
  for +k: Nat
  for +n: Nat
  for +same: {E.encoding(cps) == encm : Maybe<&2, +List<U32>>}
  for af: Compat.all_fixed(cps)
  for +fs: {E.fixed_size(cps) == Nat.mul(k, n) : Nat}
  fixed_one(Nat.mul(k, n), SC.one(encm, Some{Nat.mul(k, n)}))
def enc_shape(cps, encm, k, n, same, af, fs):
  match encm:
    case None{}: Unit{}
    case Some{b}: encoded_length(cps, b, k, n, af, fs, same)

law level_shape:
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for +k: Nat
  for +n: Nat
  for rep: rep_one(k, n, r)
  fixed_one(Nat.mul(k, n), SC.require(ok, SC.aggregate(r, Some{Nat.mul(k, n)})))
def level_shape(ok, r, k, n, rep):
  match ok:
    case False{}: Unit{}
    case True{}:
      match r:
        case None{}: Unit{}
        case Some{cps}:
          (af, (fs, pl)) = rep
          enc_shape(cps, E.encoding(cps), k, n, {==}, af, fs)

law none_level:
  for +ok: Bool
  for +r2: Maybe<&2, +List<T.Part>>
  for +width: Maybe<&2, Nat>
  for +n: Nat
  fixed_one(n, SC.require(ok, SC.aggregate(SC.concatenate(None{}, r2), width)))
def none_level(ok, r2, width, n):
  match ok:
    case False{}: Unit{}
    case True{}:
      match r2:
        case None{}: Unit{}
        case Some{y}: Unit{}

law enc_fits:
  for +cps: +List<T.Part>
  for +k: Nat
  for +n: Nat
  for +fs: {E.fixed_size(cps) == Nat.mul(k, n) : Nat}
  for +pl: {E.payloads(cps) == [] : +List<U32>}
  for +present: {IP.is_some(E.encoding(cps)) == True{} : Bool}
  {SLen.fits(4n, Nat.mul(k, n)) == True{} : Bool}
def enc_fits(cps, k, n, fs, pl, present):
  Equal.trans(Bool, SLen.fits(4n, Nat.mul(k, n)), SLen.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps)))), True{},
    Equal.cong(Nat, Bool, x => SLen.fits(4n, x), Nat.mul(k, n), Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))),
      Equal.sym(Nat, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))), Nat.mul(k, n),
        Equal.trans(Nat, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))), Nat.add(Nat.mul(k, n), List.length(&2, U32, E.payloads(cps))), Nat.mul(k, n),
          Equal.cong(Nat, Nat, x => Nat.add(x, List.length(&2, U32, E.payloads(cps))), E.fixed_size(cps), Nat.mul(k, n), fs),
          Equal.trans(Nat, Nat.add(Nat.mul(k, n), List.length(&2, U32, E.payloads(cps))), Nat.add(Nat.mul(k, n), 0n), Nat.mul(k, n),
            Equal.cong(+List<U32>, Nat, ys => Nat.add(Nat.mul(k, n), List.length(&2, U32, ys)), E.payloads(cps), [], pl),
            Packing.add_zero(Nat.mul(k, n)))))),
    V.and_right(E.bytes_valid(cps), SLen.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps)))),
      Total.optional_true(Bool.and(E.bytes_valid(cps), SLen.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))))), List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps)), present)))

law level_fits_go:
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for +k: Nat
  for +n: Nat
  for rep: rep_one(k, n, r)
  {TS.parts_present(SC.require(ok, SC.aggregate(r, Some{Nat.mul(k, n)}))) == True{} : Bool} -> {SLen.fits(4n, Nat.mul(k, n)) == True{} : Bool}
def level_fits_go(ok, r, k, n, rep):
  match ok:
    case False{}: e => Empty.absurd({SLen.fits(4n, Nat.mul(k, n)) == True{} : Bool}, W.false_true(e))
    case True{}:
      match r:
        case None{}: e => Empty.absurd({SLen.fits(4n, Nat.mul(k, n)) == True{} : Bool}, W.false_true(e))
        case Some{cps}:
          (af, (fs, pl)) = rep
          e => enc_fits(cps, k, n, fs, pl, Total.one_present(E.encoding(cps), Some{Nat.mul(k, n)}, e))

law none_absent:
  for +ok: Bool
  for +r2: Maybe<&2, +List<T.Part>>
  for +width: Maybe<&2, Nat>
  for +goal: Bool
  {TS.parts_present(SC.require(ok, SC.aggregate(SC.concatenate(None{}, r2), width))) == True{} : Bool} -> {goal == True{} : Bool}
def none_absent(ok, r2, width, goal):
  match ok:
    case False{}: e => Empty.absurd({goal == True{} : Bool}, W.false_true(e))
    case True{}:
      match r2:
        case None{}: e => Empty.absurd({goal == True{} : Bool}, W.false_true(e))
        case Some{y}: e => Empty.absurd({goal == True{} : Bool}, W.false_true(e))

law mul_commute:
  for +a: Nat
  for +b: Nat
  {Nat.mul(a, b) == Nat.mul(b, a) : Nat}
def mul_commute(a, b):
  match a:
    case 0n: Equal.sym(Nat, Nat.mul(b, 0n), 0n, A.mul_zero(b))
    case 1n+p:
      Equal.trans(Nat, Nat.add(b, Nat.mul(p, b)), Nat.add(b, Nat.mul(b, p)), Nat.mul(b, 1n+p),
        Equal.cong(Nat, Nat, x => Nat.add(b, x), Nat.mul(p, b), Nat.mul(b, p), mul_commute(p, b)),
        Equal.sym(Nat, Nat.mul(b, 1n+p), Nat.add(b, Nat.mul(b, p)), A.mul_succ_right(b, p)))

law fits_step:
  for +w: Nat
  for +y: Nat
  {SLen.fits(1n+w, Nat.mul(y, 256n)) == SLen.fits(w, y) : Bool}
def fits_step(w, y):
  Equal.cong(Nat, Bool, x => SLen.fits(w, x), Nat.div(Nat.mul(y, 256n), 256n), y, Division.quotient(y, 255n))


law nest_fixed:
  for +d: Nat
  for +r: Nat
  {SS.fixed_size(nest_schema(d, r)) == Some{size(d, r)} : Maybe<&2, Nat>}
def nest_fixed(d, r):
  match d:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(nest_schema(p, r)), Some{size(p, r)}, nest_fixed(p, r)) : {SS.times(fan(r), _) == Some{Nat.mul(fan(r), size(p, r))} : Maybe<&2, Nat>}
      {==}

def fan_pred(+r: Nat) -> Nat: Nat.add(r, Nat.mul(255n, 1n+r))

law concat_none:
  for +r2: Maybe<&2, +List<T.Part>>
  {SC.concatenate(None{}, r2) == None{} : Maybe<&2, +List<T.Part>>}
def concat_none(r2):
  match r2:
    case None{}: {==}
    case Some{y}: {==}

law copies_none:
  for +m: Nat
  for +v: T.Value
  for +s: T.Schema
  for +same: {SC.parts(v, s) == None{} : Maybe<&2, +List<T.Part>>}
  {SC.parts(copies(1n+m, v), T.Repeat{s}) == None{} : Maybe<&2, +List<T.Part>>}
def copies_none(m, v, s, same):
  %Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(v, s), None{}, same) : {SC.concatenate(_, SC.parts(copies(m, v), T.Repeat{s})) == None{} : Maybe<&2, +List<T.Part>>}
  concat_none(SC.parts(copies(m, v), T.Repeat{s}))

law level_none:
  for +ok: Bool
  for +width: Maybe<&2, Nat>
  for +n: Nat
  fixed_one(n, SC.require(ok, SC.aggregate(None{}, width)))
def level_none(ok, width, n):
  match ok:
    case False{}: Unit{}
    case True{}: Unit{}

law level:
  for +p: Nat
  for +r: Nat
  for +xs: +List<U32>
  for +rr: Maybe<&2, +List<T.Part>>
  for +same: {SC.parts(nest_value(p, r, xs), nest_schema(p, r)) == rr : Maybe<&2, +List<T.Part>>}
  for known: fixed_one(size(p, r), rr)
  fixed_one(size(1n+p, r), SC.parts(nest_value(1n+p, r, xs), nest_schema(1n+p, r)))
def level(p, r, xs, rr, same, known):
  match rr:
    case None{}:
      %Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(copies(1n+fan_pred(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}), None{}, copies_none(fan_pred(r), nest_value(p, r, xs), nest_schema(p, r), same)) : fixed_one(size(1n+p, r), SC.require(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SC.aggregate(_, SS.times(fan(r), SS.fixed_size(nest_schema(p, r))))))
      level_none(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SS.times(fan(r), SS.fixed_size(nest_schema(p, r))), size(1n+p, r))
    case Some{ps}:
      match ps:
        case Nil{}:
          match known:
        case Con{h, t}:
          match h:
            case T.Fixed{b}:
              match t:
                case Nil{}:
                  %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(nest_schema(p, r)), Some{size(p, r)}, nest_fixed(p, r)) : fixed_one(size(1n+p, r), SC.require(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SC.aggregate(SC.parts(copies(fan(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}), SS.times(fan(r), _))))
                  level_shape(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SC.parts(copies(fan(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}), fan(r), size(p, r), rep_shape(fan(r), nest_value(p, r, xs), nest_schema(p, r), size(p, r), b, same, known))
                case Con{a, more}:
                  match known:
            case T.Variable{b}:
              match known:

law shape:
  for +d: Nat
  for +r: Nat
  for +xs: +List<U32>
  fixed_one(size(d, r), SC.parts(nest_value(d, r, xs), nest_schema(d, r)))
def shape(d, r, xs):
  match d:
    case 0n: leaf_shape(SBytes.vector_domain(256n, xs), xs, 256n, e => ByteLength.scope_length(256n, xs, V.and_left(SP.byte_scope(256n, xs), SBytes.size_fits(256n), e)))
    case 1n+p: level(p, r, xs, SC.parts(nest_value(p, r, xs), nest_schema(p, r)), {==}, shape(p, r, xs))

# ---------------------------------------------------------------------------
# An existing encoding of nest_value(d+1) forces size(d+1) < 2^32.

law absent_none:
  for +ok: Bool
  for +width: Maybe<&2, Nat>
  for +goal: Bool
  {TS.parts_present(SC.require(ok, SC.aggregate(None{}, width))) == True{} : Bool} -> {goal == True{} : Bool}
def absent_none(ok, width, goal):
  match ok:
    case False{}: e => Empty.absurd({goal == True{} : Bool}, W.false_true(e))
    case True{}: e => Empty.absurd({goal == True{} : Bool}, W.false_true(e))

law level_fits:
  for +p: Nat
  for +r: Nat
  for +xs: +List<U32>
  for +rr: Maybe<&2, +List<T.Part>>
  for +same: {SC.parts(nest_value(p, r, xs), nest_schema(p, r)) == rr : Maybe<&2, +List<T.Part>>}
  for known: fixed_one(size(p, r), rr)
  {TS.parts_present(SC.parts(nest_value(1n+p, r, xs), nest_schema(1n+p, r))) == True{} : Bool} -> {SLen.fits(4n, size(1n+p, r)) == True{} : Bool}
def level_fits(p, r, xs, rr, same, known):
  match rr:
    case None{}:
      %Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(copies(1n+fan_pred(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}), None{}, copies_none(fan_pred(r), nest_value(p, r, xs), nest_schema(p, r), same)) : {TS.parts_present(SC.require(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SC.aggregate(_, SS.times(fan(r), SS.fixed_size(nest_schema(p, r)))))) == True{} : Bool} -> {SLen.fits(4n, size(1n+p, r)) == True{} : Bool}
      absent_none(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SS.times(fan(r), SS.fixed_size(nest_schema(p, r))), SLen.fits(4n, size(1n+p, r)))
    case Some{ps}:
      match ps:
        case Nil{}:
          match known:
        case Con{h, t}:
          match h:
            case T.Fixed{b}:
              match t:
                case Nil{}:
                  %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(nest_schema(p, r)), Some{size(p, r)}, nest_fixed(p, r)) : {TS.parts_present(SC.require(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SC.aggregate(SC.parts(copies(fan(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}), SS.times(fan(r), _)))) == True{} : Bool} -> {SLen.fits(4n, size(1n+p, r)) == True{} : Bool}
                  level_fits_go(Bool.and(Nat.is_lt(0n, fan(r)), Nat.is_eq(SC.count(copies(fan(r), nest_value(p, r, xs))), fan(r))), SC.parts(copies(fan(r), nest_value(p, r, xs)), T.Repeat{nest_schema(p, r)}), fan(r), size(p, r), rep_shape(fan(r), nest_value(p, r, xs), nest_schema(p, r), size(p, r), b, same, known))
                case Con{a, more}:
                  match known:
            case T.Variable{b}:
              match known:

# ---------------------------------------------------------------------------
# size(3, r) = 256*F^3 >= 2^32 does not fit in four bytes (symbolic).

law mul_add_right:
  for +x: Nat
  for +y: Nat
  for +c: Nat
  {Nat.mul(Nat.add(x, y), c) == Nat.add(Nat.mul(x, c), Nat.mul(y, c)) : Nat}
def mul_add_right(x, y, c):
  match x:
    case 0n: {==}
    case 1n+p:
      Equal.trans(Nat, Nat.add(c, Nat.mul(Nat.add(p, y), c)), Nat.add(c, Nat.add(Nat.mul(p, c), Nat.mul(y, c))), Nat.add(Nat.add(c, Nat.mul(p, c)), Nat.mul(y, c)),
        Equal.cong(Nat, Nat, z => Nat.add(c, z), Nat.mul(Nat.add(p, y), c), Nat.add(Nat.mul(p, c), Nat.mul(y, c)), mul_add_right(p, y, c)),
        Equal.sym(Nat, Nat.add(Nat.add(c, Nat.mul(p, c)), Nat.mul(y, c)), Nat.add(c, Nat.add(Nat.mul(p, c), Nat.mul(y, c))), LayoutLaws.add_associative(c, Nat.mul(p, c), Nat.mul(y, c))))

law mul_assoc:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  {Nat.mul(Nat.mul(a, b), c) == Nat.mul(a, Nat.mul(b, c)) : Nat}
def mul_assoc(a, b, c):
  match a:
    case 0n: {==}
    case 1n+p:
      Equal.trans(Nat, Nat.mul(Nat.add(b, Nat.mul(p, b)), c), Nat.add(Nat.mul(b, c), Nat.mul(Nat.mul(p, b), c)), Nat.add(Nat.mul(b, c), Nat.mul(p, Nat.mul(b, c))),
        mul_add_right(b, Nat.mul(p, b), c),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.mul(b, c), z), Nat.mul(Nat.mul(p, b), c), Nat.mul(p, Nat.mul(b, c)), mul_assoc(p, b, c)))

law mul_swap:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  {Nat.mul(a, Nat.mul(b, c)) == Nat.mul(b, Nat.mul(a, c)) : Nat}
def mul_swap(a, b, c):
  Equal.trans(Nat, Nat.mul(a, Nat.mul(b, c)), Nat.mul(Nat.mul(a, b), c), Nat.mul(b, Nat.mul(a, c)),
    Equal.sym(Nat, Nat.mul(Nat.mul(a, b), c), Nat.mul(a, Nat.mul(b, c)), mul_assoc(a, b, c)),
    Equal.trans(Nat, Nat.mul(Nat.mul(a, b), c), Nat.mul(Nat.mul(b, a), c), Nat.mul(b, Nat.mul(a, c)),
      Equal.cong(Nat, Nat, z => Nat.mul(z, c), Nat.mul(a, b), Nat.mul(b, a), mul_commute(a, b)),
      mul_assoc(b, a, c)))

law fan_factor:
  for +r: Nat
  for +a: Nat
  {Nat.mul(fan(r), a) == Nat.mul(Nat.mul(1n+r, a), 256n) : Nat}
def fan_factor(r, a):
  Equal.trans(Nat, Nat.mul(Nat.mul(256n, 1n+r), a), Nat.mul(256n, Nat.mul(1n+r, a)), Nat.mul(Nat.mul(1n+r, a), 256n),
    mul_assoc(256n, 1n+r, a), mul_commute(256n, Nat.mul(1n+r, a)))

law fits_fan:
  for +w: Nat
  for +r: Nat
  for +a: Nat
  {SLen.fits(1n+w, Nat.mul(fan(r), a)) == SLen.fits(w, Nat.mul(1n+r, a)) : Bool}
def fits_fan(w, r, a):
  Equal.trans(Bool, SLen.fits(1n+w, Nat.mul(fan(r), a)), SLen.fits(1n+w, Nat.mul(Nat.mul(1n+r, a), 256n)), SLen.fits(w, Nat.mul(1n+r, a)),
    Equal.cong(Nat, Bool, z => SLen.fits(1n+w, z), Nat.mul(fan(r), a), Nat.mul(Nat.mul(1n+r, a), 256n), fan_factor(r, a)),
    fits_step(w, Nat.mul(1n+r, a)))

law fits_mul_eq:
  for +w: Nat
  for +x: Nat
  for +y: Nat
  for +e: {x == y : Nat}
  {SLen.fits(w, x) == SLen.fits(w, y) : Bool}
def fits_mul_eq(w, x, y, e): Equal.cong(Nat, Bool, z => SLen.fits(w, z), x, y, e)

# The depth stays symbolic from here on. Instantiating this family at a
# literal depth forces the checker to unfold the schema fanout-wide at every
# level (F = 256*(1+r) per level, so F^3 nodes at depth three), which is what
# made the root laws at the witness explode; with d open, every term below
# stays stuck and the same facts are proved once for all depths >= 3.
law size_step:
  for +p: Nat
  for +r: Nat
  for found: Exists(Nat, k => {size(p, r) == 1n+k : Nat})
  Exists(Nat, k => {size(1n+p, r) == 1n+k : Nat})
def size_step(p, r, found):
  (+k, e) = found
  (Nat.add(k, Nat.mul(fan_pred(r), 1n+k)),
   %Equal.sym(Nat, size(p, r), 1n+k, e) : {Nat.mul(fan(r), _) == 1n+Nat.add(k, Nat.mul(fan_pred(r), 1n+k)) : Nat}
   {==})

law size_positive:
  for +d: Nat
  for +r: Nat
  Exists(Nat, k => {size(d, r) == 1n+k : Nat})
def size_positive(d, r):
  match d:
    case 0n: (255n, {==})
    case 1n+p: size_step(p, r, size_positive(p, r))

law fits_zero_mul:
  for +m: Nat
  for +k: Nat
  {SLen.fits(0n, Nat.mul(1n+m, 1n+k)) == False{} : Bool}
def fits_zero_mul(m, k): {==}

# fits(w, (1+m)*size(d, r)) is false whenever the budget w is at most d+1:
# each nesting level contributes one factor 256 (one byte of width) and the
# 256-byte leaf contributes the last one, so w divisions by 256 leave a
# positive number behind.
law fits_zero_size:
  for +d: Nat
  for +r: Nat
  for +m: Nat
  for found: Exists(Nat, k => {size(d, r) == 1n+k : Nat})
  {SLen.fits(0n, Nat.mul(1n+m, size(d, r))) == False{} : Bool}
def fits_zero_size(d, r, m, found):
  (+k, e) = found
  %Equal.sym(Nat, size(d, r), 1n+k, e) : {SLen.fits(0n, Nat.mul(1n+m, _)) == False{} : Bool}
  fits_zero_mul(m, k)

law fits_leaf:
  for +w: Nat
  for +m: Nat
  for +room: {Nat.is_le(1n+w, 1n) == True{} : Bool}
  {SLen.fits(1n+w, Nat.mul(1n+m, 256n)) == False{} : Bool}
def fits_leaf(w, m, room):
  match w:
    case 0n: Equal.trans(Bool, SLen.fits(1n, Nat.mul(1n+m, 256n)), SLen.fits(0n, 1n+m), False{}, fits_step(0n, 1n+m), {==})
    case 1n+w3: Empty.absurd({SLen.fits(1n+(1n+w3), Nat.mul(1n+m, 256n)) == False{} : Bool}, W.false_true(room))

law fits_false_go:
  for +w: Nat
  for +d: Nat
  for +r: Nat
  for +m: Nat
  for +room: {Nat.is_le(w, 1n+d) == True{} : Bool}
  {SLen.fits(w, Nat.mul(1n+m, size(d, r))) == False{} : Bool}
def fits_false_go(w, d, r, m, room):
  match w:
    case 0n: fits_zero_size(d, r, m, size_positive(d, r))
    case 1n+w2:
      match d:
        case 0n: fits_leaf(w2, m, room)
        case 1n+d2:
          Equal.trans(Bool, SLen.fits(1n+w2, Nat.mul(1n+m, Nat.mul(fan(r), size(d2, r)))), SLen.fits(1n+w2, Nat.mul(fan(r), Nat.mul(1n+m, size(d2, r)))), False{},
            fits_mul_eq(1n+w2, Nat.mul(1n+m, Nat.mul(fan(r), size(d2, r))), Nat.mul(fan(r), Nat.mul(1n+m, size(d2, r))), mul_swap(1n+m, fan(r), size(d2, r))),
            Equal.trans(Bool, SLen.fits(1n+w2, Nat.mul(fan(r), Nat.mul(1n+m, size(d2, r)))), SLen.fits(w2, Nat.mul(1n+r, Nat.mul(1n+m, size(d2, r)))), False{},
              fits_fan(w2, r, Nat.mul(1n+m, size(d2, r))),
              Equal.trans(Bool, SLen.fits(w2, Nat.mul(1n+r, Nat.mul(1n+m, size(d2, r)))), SLen.fits(w2, Nat.mul(Nat.mul(1n+r, 1n+m), size(d2, r))), False{},
                fits_mul_eq(w2, Nat.mul(1n+r, Nat.mul(1n+m, size(d2, r))), Nat.mul(Nat.mul(1n+r, 1n+m), size(d2, r)),
                  Equal.sym(Nat, Nat.mul(Nat.mul(1n+r, 1n+m), size(d2, r)), Nat.mul(1n+r, Nat.mul(1n+m, size(d2, r))), mul_assoc(1n+r, 1n+m, size(d2, r)))),
                fits_false_go(w2, d2, r, Nat.add(m, Nat.mul(r, 1n+m)), room))))

law mul_one:
  for +x: Nat
  {Nat.mul(1n, x) == x : Nat}
def mul_one(x): Packing.add_zero(x)

law size_fits_false:
  for +d: Nat
  for +r: Nat
  for +deep: {Nat.is_le(3n, d) == True{} : Bool}
  {SLen.fits(4n, size(d, r)) == False{} : Bool}
def size_fits_false(d, r, deep):
  %mul_one(size(d, r)) : {SLen.fits(4n, _) == False{} : Bool}
  fits_false_go(4n, d, r, 0n, deep)

law bool_false:
  for +b: Bool
  for f: {b == True{} : Bool} -> Empty
  {b == False{} : Bool}
def bool_false(b, f):
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, f({==}))

# No value of nest_schema(d, r) with d >= 3 is serializable: an encoding would
# have to be exactly 256*F^d >= 2^32 bytes long. The depth stays a variable, so
# nothing here unfolds the schema.
law nest_not_serializable:
  for +d: Nat
  for +r: Nat
  for +xs: +List<U32>
  for +deep: {Nat.is_le(3n, d) == True{} : Bool}
  {VD.serializable(nest_schema(d, r), nest_value(d, r, xs)) == False{} : Bool}
def nest_not_serializable(d, r, xs, deep):
  match d:
    case 0n: Empty.absurd({VD.serializable(nest_schema(0n, r), nest_value(0n, r, xs)) == False{} : Bool}, W.false_true(deep))
    case 1n+p:
      bool_false(VD.serializable(nest_schema(1n+p, r), nest_value(1n+p, r, xs)), s =>
        W.false_true(Equal.trans(Bool, False{}, SLen.fits(4n, size(1n+p, r)), True{},
          Equal.sym(Bool, SLen.fits(4n, size(1n+p, r)), False{}, size_fits_false(1n+p, r, deep)),
          level_fits(p, r, xs, SC.parts(nest_value(p, r, xs), nest_schema(p, r)), {==}, shape(p, r, xs), Compat.parts_of(SC.parts(nest_value(1n+p, r, xs), nest_schema(1n+p, r)), s)))))
