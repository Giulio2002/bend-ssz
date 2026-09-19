import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/codec.bend as S
import ../spec/schema.bend as SS
import ../spec/layout.bend as E
import ../spec/primitives.bend as SP
import ../spec/bytes.bend as SBytes
import ../spec/bitfields.bend as SBits
import ./layout_image_headers.bend as H
import ./layout.bend as L
import ./leaf_sizes.bend as Leaf
import ./primitive_invariants.bend as V
import ./bit_vector_inverse.bend as Eq
import ./lists.bend as Lists
import ./packing.bend as Pack
import ./word_facts.bend as W
import ../spec/nat_bytes.bend as SNat

# Layout facts of the independent recursive encoding: every non-forest schema
# yields exactly one fragment whose kind/size is its normative fixed size;
# forests yield the width lists consumed by the layout decoder.
def single(width: Maybe<&2, Nat>, ps: +List<T.Part>) -> Type:
  match ps:
    case Nil{}: Empty
    case Con{T.Fixed{xs}, Nil{}}: {width == Some{List.length(&2, U32, xs)} : Maybe<&2, Nat>}
    case Con{T.Variable{xs}, Nil{}}: {width == None{} : Maybe<&2, Nat>}
    case Con{T.Fixed{xs}, Con{h, t}}: Empty
    case Con{T.Variable{xs}, Con{h, t}}: Empty

def single_result(width: Maybe<&2, Nat>, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{ps}: single(width, ps)

def widths(schema: T.Schema) -> +List<Maybe<&2, Nat>>:
  match schema:
    case T.Chain{h, t}: SS.fixed_size(h) <> widths(t)
    case _: []

def total(ws: +List<Maybe<&2, Nat>>) -> Maybe<&2, Nat>:
  match ws:
    case Nil{}: Some{0n}
    case Con{w, t}: SS.sum(w, total(t))

def ok(schema: T.Schema) -> Bool:
  match schema:
    case T.Repeat{e}: I.valid_go(e, False{})
    case T.Chain{h, t}: I.valid_go(T.Chain{h, t}, True{})
    case T.End{}: True{}
    case T.Null{}: True{}
    case _: I.valid_go(schema, False{})

def chain_fact(expected: +List<Maybe<&2, Nat>>, size: Maybe<&2, Nat>, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{ps}: {H.widths(ps) == expected : +List<Maybe<&2, Nat>>} & {total(H.widths(ps)) == size : Maybe<&2, Nat>}

def repeat_fact(expected: +List<Maybe<&2, Nat>>, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{ps}: {H.widths(ps) == expected : +List<Maybe<&2, Nat>>}

def fact(schema: T.Schema, value: T.Value, result: Maybe<&2, +List<T.Part>>) -> Type:
  match schema:
    case T.Chain{+h, +t}: chain_fact(widths(T.Chain{h, t}), SS.fixed_size(T.Chain{h, t}), result)
    case T.End{}: chain_fact([], Some{0n}, result)
    case T.Repeat{+e}: repeat_fact(List.replicate(Maybe<&2, Nat>, S.count(value), SS.fixed_size(e)), result)
    case _: single_result(SS.fixed_size(schema), result)

def sized_opt(width: Maybe<&2, Nat>, xs: +List<U32>) -> Type:
  match width:
    case None{}: Unit
    case Some{n}: {List.length(&2, U32, xs) == n : Nat}

law fragment_single:
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for size: sized_opt(width, xs)
  single(width, [S.fragment(width, xs)])
def fragment_single(width, xs, size):
  match width:
    case None{}: {==}
    case Some{n}: Equal.cong(Nat, Maybe<&2, Nat>, k => Some{k}, n, List.length(&2, U32, xs), Equal.sym(Nat, List.length(&2, U32, xs), n, size))

law one_fixed:
  for +encoded: Maybe<&2, +List<U32>>
  for +n: Nat
  for size: V.sized(n, encoded)
  single_result(Some{n}, S.one(encoded, Some{n}))
def one_fixed(encoded, n, size):
  match encoded:
    case None{}: Unit{}
    case Some{xs}: fragment_single(Some{n}, xs, size)

law one_variable:
  for +encoded: Maybe<&2, +List<U32>>
  single_result(None{}, S.one(encoded, None{}))
def one_variable(encoded):
  match encoded:
    case None{}: Unit{}
    case Some{xs}: {==}

def fixed_view(ps: +List<T.Part>, t: Maybe<&2, Nat>) -> Type:
  match t:
    case None{}: Unit
    case Some{n}: {E.fixed_size(ps) == n : Nat} & {E.payloads(ps) == [] : +List<U32>}

law fixed_step:
  for +xs: +List<U32>
  for +t: +List<T.Part>
  for +r: Maybe<&2, Nat>
  for ih: fixed_view(t, r)
  fixed_view(T.Fixed{xs} <> t, SS.sum(Some{List.length(&2, U32, xs)}, r))
def fixed_step(xs, t, r, ih):
  match r:
    case None{}: Unit{}
    case Some{n}:
      (size, empty) = ih
      (Equal.cong(Nat, Nat, k => Nat.add(List.length(&2, U32, xs), k), E.fixed_size(t), n, size), empty)

law fixed_total:
  for +ps: +List<T.Part>
  fixed_view(ps, total(H.widths(ps)))
def fixed_total(ps):
  match ps:
    case Nil{}: ({==}, {==})
    case Con{T.Fixed{xs}, t}: fixed_step(xs, t, total(H.widths(t)), fixed_total(t))
    case Con{T.Variable{xs}, t}: Unit{}

law layout_length:
  for +ps: +List<T.Part>
  for +n: Nat
  for view: fixed_view(ps, Some{n})
  {List.length(&2, U32, List.append(&2, U32, E.fixed_parts(ps, E.fixed_size(ps)), E.payloads(ps))) == n : Nat}
def layout_length(ps, n, view):
  (size, empty) = view
  Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, E.fixed_parts(ps, E.fixed_size(ps)), E.payloads(ps))), Nat.add(E.fixed_size(ps), List.length(&2, U32, E.payloads(ps))), n, L.output_length(ps, E.fixed_size(ps)),
    %Equal.sym(+List<U32>, E.payloads(ps), [], empty) : {Nat.add(E.fixed_size(ps), List.length(&2, U32, _)) == n : Nat}
    Equal.trans(Nat, Nat.add(E.fixed_size(ps), 0n), E.fixed_size(ps), n, Pack.add_zero(E.fixed_size(ps)), size))

law encoded_sized:
  for +ps: +List<T.Part>
  for +n: Nat
  for tot: {total(H.widths(ps)) == Some{n} : Maybe<&2, Nat>}
  V.sized(n, E.encoding(ps))
def encoded_sized(ps, n, tot):
  Leaf.optional_sized(Bool.and(E.bytes_valid(ps), SNat.fits(4n, Nat.add(E.fixed_size(ps), List.length(&2, U32, E.payloads(ps))))), List.append(&2, U32, E.fixed_parts(ps, E.fixed_size(ps)), E.payloads(ps)), n, e => layout_length(ps, n,
    %tot : fixed_view(ps, _)
    fixed_total(ps)))

def total_result(size: Maybe<&2, Nat>, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{ps}: {total(H.widths(ps)) == size : Maybe<&2, Nat>}

law aggregate_variable:
  for +parts: Maybe<&2, +List<T.Part>>
  single_result(None{}, S.aggregate(parts, None{}))
def aggregate_variable(parts):
  match parts:
    case None{}: Unit{}
    case Some{ps}: one_variable(E.encoding(ps))

law aggregate_any:
  for +width: Maybe<&2, Nat>
  for +parts: Maybe<&2, +List<T.Part>>
  for tot: total_result(width, parts)
  single_result(width, S.aggregate(parts, width))
def aggregate_any(width, parts, tot):
  match width:
    case None{}: aggregate_variable(parts)
    case Some{n}:
      match parts:
        case None{}: Unit{}
        case Some{ps}: one_fixed(E.encoding(ps), n, encoded_sized(ps, n, tot))

law chain_total:
  for +ws: +List<Maybe<&2, Nat>>
  for +size: Maybe<&2, Nat>
  for +parts: Maybe<&2, +List<T.Part>>
  for known: chain_fact(ws, size, parts)
  total_result(size, parts)
def chain_total(ws, size, parts, known):
  match parts:
    case None{}: Unit{}
    case Some{ps}:
      (same, tot) = known
      tot

law require_fact:
  for +ok: Bool
  for +width: Maybe<&2, Nat>
  for +result: Maybe<&2, +List<T.Part>>
  for known: {ok == True{} : Bool} -> single_result(width, result)
  single_result(width, S.require(ok, result))
def require_fact(ok, width, result, known):
  match ok:
    case False{}: Unit{}
    case True{}: known({==})

law copies_total:
  for +k: Nat
  for +w: Nat
  {total(List.replicate(Maybe<&2, Nat>, k, Some{w})) == Some{Nat.mul(k, w)} : Maybe<&2, Nat>}
def copies_total(k, w):
  match k:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Maybe<&2, Nat>, total(List.replicate(Maybe<&2, Nat>, p, Some{w})), Some{Nat.mul(p, w)}, copies_total(p, w)) : {SS.sum(Some{w}, _) == Some{Nat.add(w, Nat.mul(p, w))} : Maybe<&2, Nat>}
      {==}

law repeat_total:
  for +k: Nat
  for +n: Nat
  for +w: Nat
  for +parts: Maybe<&2, +List<T.Part>>
  for same: {k == n : Nat}
  for known: repeat_fact(List.replicate(Maybe<&2, Nat>, k, Some{w}), parts)
  total_result(Some{Nat.mul(n, w)}, parts)
def repeat_total(k, n, w, parts, same, known):
  match parts:
    case None{}: Unit{}
    case Some{ps}:
      %same : {total(H.widths(ps)) == Some{Nat.mul(_, w)} : Maybe<&2, Nat>}
      %Equal.sym(+List<Maybe<&2, Nat>>, H.widths(ps), List.replicate(Maybe<&2, Nat>, k, Some{w}), known) : {total(_) == Some{Nat.mul(k, w)} : Maybe<&2, Nat>}
      copies_total(k, w)

law vector_fact:
  for +width: Maybe<&2, Nat>
  for +n: Nat
  for +k: Nat
  for +parts: Maybe<&2, +List<T.Part>>
  for known: repeat_fact(List.replicate(Maybe<&2, Nat>, k, width), parts)
  single_result(SS.times(n, width), S.require(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(k, n)), S.aggregate(parts, SS.times(n, width))))
def vector_fact(width, n, k, parts, known):
  match width:
    case None{}: require_fact(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(k, n)), None{}, S.aggregate(parts, None{}), e => aggregate_variable(parts))
    case Some{w}: require_fact(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(k, n)), Some{Nat.mul(n, w)}, S.aggregate(parts, Some{Nat.mul(n, w)}), e => aggregate_any(Some{Nat.mul(n, w)}, parts, repeat_total(k, n, w, parts, Eq.nat_equal_sound(k, n, V.and_right(Nat.is_lt(0n, n), Nat.is_eq(k, n), e)), known)))

law tagged_fact:
  for +selector: U32
  for +result: Maybe<&2, +List<T.Part>>
  single_result(None{}, S.tagged(selector, result))
def tagged_fact(selector, result):
  match result:
    case None{}: Unit{}
    case Some{Nil{}}: Unit{}
    case Some{Con{T.Fixed{xs}, Nil{}}}: {==}
    case Some{Con{T.Variable{xs}, Nil{}}}: {==}
    case Some{Con{T.Fixed{xs}, Con{h, t}}}: Unit{}
    case Some{Con{T.Variable{xs}, Con{h, t}}}: Unit{}

law option_fact:
  for +option: Maybe<&2, T.Schema>
  for +value: T.Value
  for +selector: U32
  single_result(None{}, S.with_option(option, s => S.tagged(selector, S.parts(value, s))))
def option_fact(option, value, selector):
  match option:
    case None{}: Unit{}
    case Some{s}: tagged_fact(selector, S.parts(value, s))

law boolean_fact:
  for +b: Bool
  single(Some{1n}, [T.Fixed{SP.boolean_encoding(b)}])
def boolean_fact(b):
  match b:
    case False{}: {==}
    case True{}: {==}
