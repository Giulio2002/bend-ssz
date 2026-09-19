import Base
import ./word_facts.bend as W
import ./bytes.bend as B
import ../src/primitives.bend as IP
import ../src/bytes.bend as IB
import ../src/packing.bend as PK
import ../src/nat_bytes.bend as NB
import ../spec/primitives.bend as SP
import ../spec/nat_bytes.bend as N
import ./nat_bytes.bend as Digits
import ./nat_order.bend as Order
import ./primitive_invariants.bend as V
import ../src/layout.bend as I
import ../src/lists.bend as Lists
import ../spec/layout.bend as S
import ../types/schema.bend as T
import ./lists.bend as L
import ./packing.bend as P

law add_associative:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  {Nat.add(Nat.add(a, b), c) == Nat.add(a, Nat.add(b, c)) : Nat}
def add_associative(a, b, c):
  match a:
    case 0n: {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Nat.add(Nat.add(p, b), c), Nat.add(p, Nat.add(b, c)), add_associative(p, b, c))

law fixed_length_correct:
  for +parts: +List<T.Part>
  for +acc: Nat
  {I.fixed_length(parts, acc) == Nat.add(acc, S.fixed_size(parts)) : Nat}
def fixed_length_correct(parts, acc):
  match parts:
    case Nil{}: Equal.sym(Nat, Nat.add(acc, 0n), acc, P.add_zero(acc))
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          %L.length_correct(U32, xs) : {I.fixed_length(t, Nat.add(acc, Lists.length(U32, xs))) == Nat.add(acc, Nat.add(_, S.fixed_size(t))) : Nat}
          Equal.trans(Nat, I.fixed_length(t, Nat.add(acc, Lists.length(U32, xs))), Nat.add(Nat.add(acc, Lists.length(U32, xs)), S.fixed_size(t)), Nat.add(acc, Nat.add(Lists.length(U32, xs), S.fixed_size(t))), fixed_length_correct(t, Nat.add(acc, Lists.length(U32, xs))), add_associative(acc, Lists.length(U32, xs), S.fixed_size(t)))
        case T.Variable{xs}:
          Equal.trans(Nat, I.fixed_length(t, Nat.add(acc, 4n)), Nat.add(Nat.add(acc, 4n), S.fixed_size(t)), Nat.add(acc, Nat.add(4n, S.fixed_size(t))), fixed_length_correct(t, Nat.add(acc, 4n)), add_associative(acc, 4n, S.fixed_size(t)))

law fixed_parts_length:
  for +parts: +List<T.Part>
  for +cursor: Nat
  {List.length(&2, U32, S.fixed_parts(parts, cursor)) == S.fixed_size(parts) : Nat}
def fixed_parts_length(parts, cursor):
  match parts:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          %fixed_parts_length(t, cursor) : {List.length(&2, U32, List.append(&2, U32, xs, S.fixed_parts(t, cursor))) == Nat.add(List.length(&2, U32, xs), _) : Nat}
          L.append_length(U32, xs, S.fixed_parts(t, cursor))
        case T.Variable{xs}:
          %Digits.digits_length(4n, cursor) : {List.length(&2, U32, S.fixed_parts(T.Variable{xs} <> t, cursor)) == Nat.add(_, S.fixed_size(t)) : Nat}
          %fixed_parts_length(t, Nat.add(cursor, List.length(&2, U32, xs))) : {List.length(&2, U32, S.fixed_parts(T.Variable{xs} <> t, cursor)) == Nat.add(List.length(&2, U32, N.digits(4n, cursor)), _) : Nat}
          L.append_length(U32, N.digits(4n, cursor), S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))))

law advance_total:
  for +cursor: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  {Nat.add(Nat.add(cursor, List.length(&2, U32, xs)), List.length(&2, U32, ys)) == Nat.add(cursor, List.length(&2, U32, List.append(&2, U32, xs, ys))) : Nat}
def advance_total(cursor, xs, ys):
  Equal.trans(Nat, Nat.add(Nat.add(cursor, List.length(&2, U32, xs)), List.length(&2, U32, ys)), Nat.add(cursor, Nat.add(List.length(&2, U32, xs), List.length(&2, U32, ys))), Nat.add(cursor, List.length(&2, U32, List.append(&2, U32, xs, ys))), add_associative(cursor, List.length(&2, U32, xs), List.length(&2, U32, ys)), Equal.cong(Nat, Nat, n => Nat.add(cursor, n), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, ys)), List.length(&2, U32, List.append(&2, U32, xs, ys)), Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, xs, ys)), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, ys)), L.append_length(U32, xs, ys))))

law offsets_representable:
  for +parts: +List<T.Part>
  for +cursor: Nat
  for +bound: {N.fits(4n, Nat.add(cursor, List.length(&2, U32, S.payloads(parts)))) == True{} : Bool}
  {S.offsets_fit(parts, cursor) == True{} : Bool}
def offsets_representable(parts, cursor, bound):
  match parts:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: offsets_representable(t, cursor, bound)
        case T.Variable{xs}:
          V.and_true(N.fits(4n, cursor), S.offsets_fit(t, Nat.add(cursor, List.length(&2, U32, xs))), Digits.fits_monotone(4n, cursor, Nat.add(cursor, List.length(&2, U32, S.payloads(T.Variable{xs} <> t))), Order.below_sum(cursor, List.length(&2, U32, S.payloads(T.Variable{xs} <> t))), bound), offsets_representable(t, Nat.add(cursor, List.length(&2, U32, xs)), Equal.trans(Bool, N.fits(4n, Nat.add(Nat.add(cursor, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t)))), N.fits(4n, Nat.add(cursor, List.length(&2, U32, S.payloads(T.Variable{xs} <> t)))), True{}, Equal.cong(Nat, Bool, n => N.fits(4n, n), Nat.add(Nat.add(cursor, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t))), Nat.add(cursor, List.length(&2, U32, S.payloads(T.Variable{xs} <> t))), advance_total(cursor, xs, S.payloads(t))), bound)))

# Accumulator ordering is independent of fragment contents and lengths.
# Offset representability is a mathematical premise, discharged from the
# strict total size bound by offsets_representable above.
law encode_accumulators:
  for +parts: +List<T.Part>
  for +cursor: Nat
  for +fixed: +List<U32>
  for +variable: +List<U32>
  for +fit: {S.offsets_fit(parts, cursor) == True{} : Bool}
  {I.encode_go(parts, cursor, fixed, variable) == I.finish(List.reverse.go(&2, U32, S.fixed_parts(parts, cursor), fixed), List.reverse.go(&2, U32, S.payloads(parts), variable)) : Maybe<&2, +List<U32>>}
def encode_accumulators(parts, cursor, fixed, variable, fit):
  match parts:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          %Equal.sym(+List<U32>, List.reverse.go(&2, U32, List.append(&2, U32, xs, S.fixed_parts(t, cursor)), fixed), List.reverse.go(&2, U32, S.fixed_parts(t, cursor), List.reverse.go(&2, U32, xs, fixed)), L.reverse_append(U32, xs, S.fixed_parts(t, cursor), fixed)) : {I.encode_go(T.Fixed{xs} <> t, cursor, fixed, variable) == I.finish(_, List.reverse.go(&2, U32, S.payloads(t), variable)) : Maybe<&2, +List<U32>>}
          encode_accumulators(t, cursor, List.reverse.go(&2, U32, xs, fixed), variable, fit)
        case T.Variable{xs}:
          %Equal.sym(Maybe<&2, +List<U32>>, NB.encode(4n, cursor), N.encoding(4n, cursor), Digits.encode_correct(4n, cursor)) : {I.offset_append(_, fixed, f => I.encode_go(t, Nat.add(cursor, Lists.length(U32, xs)), f, List.reverse.go(&2, U32, xs, variable))) == I.finish(List.reverse.go(&2, U32, S.fixed_parts(T.Variable{xs} <> t, cursor), fixed), List.reverse.go(&2, U32, S.payloads(T.Variable{xs} <> t), variable)) : Maybe<&2, +List<U32>>}
          %Equal.sym(Bool, N.fits(4n, cursor), True{}, V.and_left(N.fits(4n, cursor), S.offsets_fit(t, Nat.add(cursor, List.length(&2, U32, xs))), fit)) : {I.offset_append(SP.optional(_, N.digits(4n, cursor)), fixed, f => I.encode_go(t, Nat.add(cursor, Lists.length(U32, xs)), f, List.reverse.go(&2, U32, xs, variable))) == I.finish(List.reverse.go(&2, U32, S.fixed_parts(T.Variable{xs} <> t, cursor), fixed), List.reverse.go(&2, U32, S.payloads(T.Variable{xs} <> t), variable)) : Maybe<&2, +List<U32>>}
          %Equal.sym(Nat, Lists.length(U32, xs), List.length(&2, U32, xs), L.length_correct(U32, xs)) : {I.encode_go(t, Nat.add(cursor, _), List.reverse.go(&2, U32, N.digits(4n, cursor), fixed), List.reverse.go(&2, U32, xs, variable)) == I.finish(List.reverse.go(&2, U32, S.fixed_parts(T.Variable{xs} <> t, cursor), fixed), List.reverse.go(&2, U32, S.payloads(T.Variable{xs} <> t), variable)) : Maybe<&2, +List<U32>>}
          %Equal.sym(+List<U32>, List.reverse.go(&2, U32, List.append(&2, U32, N.digits(4n, cursor), S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs)))), fixed), List.reverse.go(&2, U32, S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))), List.reverse.go(&2, U32, N.digits(4n, cursor), fixed)), L.reverse_append(U32, N.digits(4n, cursor), S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))), fixed)) : {I.encode_go(t, Nat.add(cursor, List.length(&2, U32, xs)), List.reverse.go(&2, U32, N.digits(4n, cursor), fixed), List.reverse.go(&2, U32, xs, variable)) == I.finish(_, List.reverse.go(&2, U32, S.payloads(T.Variable{xs} <> t), variable)) : Maybe<&2, +List<U32>>}
          %Equal.sym(+List<U32>, List.reverse.go(&2, U32, List.append(&2, U32, xs, S.payloads(t)), variable), List.reverse.go(&2, U32, S.payloads(t), List.reverse.go(&2, U32, xs, variable)), L.reverse_append(U32, xs, S.payloads(t), variable)) : {I.encode_go(t, Nat.add(cursor, List.length(&2, U32, xs)), List.reverse.go(&2, U32, N.digits(4n, cursor), fixed), List.reverse.go(&2, U32, xs, variable)) == I.finish(List.reverse.go(&2, U32, S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))), List.reverse.go(&2, U32, N.digits(4n, cursor), fixed)), _) : Maybe<&2, +List<U32>>}
          encode_accumulators(t, Nat.add(cursor, List.length(&2, U32, xs)), List.reverse.go(&2, U32, N.digits(4n, cursor), fixed), List.reverse.go(&2, U32, xs, variable), V.and_right(N.fits(4n, cursor), S.offsets_fit(t, Nat.add(cursor, List.length(&2, U32, xs))), fit))

law checked_bytes:
  for +ok: Bool
  for +xs: +List<U32>
  {IP.accept_bytes(ok, xs) == SP.optional(ok, xs) : Maybe<&2, +List<U32>>}
def checked_bytes(ok, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law finish_bytes:
  for +xs: +List<U32>
  {IP.accept_bytes(Bool.and(IB.size_fits(Lists.length(U32, xs)), PK.valid_go(xs, True{})), xs) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, xs)), SP.bytes_domain(xs)), xs) : Maybe<&2, +List<U32>>}
def finish_bytes(xs):
  %L.length_correct(U32, xs) : {IP.accept_bytes(Bool.and(IB.size_fits(Lists.length(U32, xs)), PK.valid_go(xs, True{})), xs) == SP.optional(Bool.and(N.fits(4n, _), SP.bytes_domain(xs)), xs) : Maybe<&2, +List<U32>>}
  %P.valid_go_correct(xs, True{}) : {IP.accept_bytes(Bool.and(IB.size_fits(Lists.length(U32, xs)), PK.valid_go(xs, True{})), xs) == SP.optional(Bool.and(N.fits(4n, Lists.length(U32, xs)), _), xs) : Maybe<&2, +List<U32>>}
  checked_bytes(Bool.and(IB.size_fits(Lists.length(U32, xs)), PK.valid_go(xs, True{})), xs)

law finish_output:
  for +a: +List<U32>
  for +b: +List<U32>
  {IP.accept_bytes(Bool.and(IB.size_fits(Lists.length(U32, Lists.append(U32, a, b))), PK.valid_go(Lists.append(U32, a, b), True{})), Lists.append(U32, a, b)) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, List.append(&2, U32, a, b))), SP.bytes_domain(List.append(&2, U32, a, b))), List.append(&2, U32, a, b)) : Maybe<&2, +List<U32>>}
def finish_output(a, b):
  %L.append_correct(U32, a, b) : {IP.accept_bytes(Bool.and(IB.size_fits(Lists.length(U32, Lists.append(U32, a, b))), PK.valid_go(Lists.append(U32, a, b), True{})), Lists.append(U32, a, b)) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, _)), SP.bytes_domain(_)), _) : Maybe<&2, +List<U32>>}
  finish_bytes(Lists.append(U32, a, b))

law finish_forward:
  for +fixed: +List<U32>
  for +variable: +List<U32>
  {I.finish(List.reverse(&2, U32, fixed), List.reverse(&2, U32, variable)) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, List.append(&2, U32, fixed, variable))), SP.bytes_domain(List.append(&2, U32, fixed, variable))), List.append(&2, U32, fixed, variable)) : Maybe<&2, +List<U32>>}
def finish_forward(fixed, variable):
  %L.reverse_twice(U32, fixed) : {I.finish(List.reverse(&2, U32, fixed), List.reverse(&2, U32, variable)) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, List.append(&2, U32, _, variable))), SP.bytes_domain(List.append(&2, U32, _, variable))), List.append(&2, U32, _, variable)) : Maybe<&2, +List<U32>>}
  %L.reverse_twice(U32, variable) : {I.finish(List.reverse(&2, U32, fixed), List.reverse(&2, U32, variable)) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, List.append(&2, U32, List.reverse(&2, U32, List.reverse(&2, U32, fixed)), _))), SP.bytes_domain(List.append(&2, U32, List.reverse(&2, U32, List.reverse(&2, U32, fixed)), _))), List.append(&2, U32, List.reverse(&2, U32, List.reverse(&2, U32, fixed)), _)) : Maybe<&2, +List<U32>>}
  finish_output(List.reverse(&2, U32, List.reverse(&2, U32, fixed)), List.reverse(&2, U32, List.reverse(&2, U32, variable)))

law bytes_append:
  for +xs: +List<U32>
  for +ys: +List<U32>
  {SP.bytes_domain(List.append(&2, U32, xs, ys)) == Bool.and(SP.bytes_domain(xs), SP.bytes_domain(ys)) : Bool}
def bytes_append(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(Bool, Bool.and(Bool.and(U32.is_lt(h, 256), SP.bytes_domain(t)), SP.bytes_domain(ys)), Bool.and(U32.is_lt(h, 256), Bool.and(SP.bytes_domain(t), SP.bytes_domain(ys))), B.and_associative(U32.is_lt(h, 256), SP.bytes_domain(t), SP.bytes_domain(ys))) : {SP.bytes_domain(List.append(&2, U32, h <> t, ys)) == _ : Bool}
      Equal.cong(Bool, Bool, ok => Bool.and(U32.is_lt(h, 256), ok), SP.bytes_domain(List.append(&2, U32, t, ys)), Bool.and(SP.bytes_domain(t), SP.bytes_domain(ys)), bytes_append(t, ys))

law and_shuffle:
  for +a: Bool
  for +b: Bool
  for +c: Bool
  {Bool.and(a, Bool.and(b, c)) == Bool.and(b, Bool.and(a, c)) : Bool}
def and_shuffle(a, b, c):
  match a b:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}: {==}

law layout_domain:
  for +parts: +List<T.Part>
  for +cursor: Nat
  {Bool.and(SP.bytes_domain(S.fixed_parts(parts, cursor)), SP.bytes_domain(S.payloads(parts))) == S.bytes_valid(parts) : Bool}
def layout_domain(parts, cursor):
  match parts:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          %Equal.sym(Bool, SP.bytes_domain(List.append(&2, U32, xs, S.fixed_parts(t, cursor))), Bool.and(SP.bytes_domain(xs), SP.bytes_domain(S.fixed_parts(t, cursor))), bytes_append(xs, S.fixed_parts(t, cursor))) : {Bool.and(_, SP.bytes_domain(S.payloads(t))) == S.bytes_valid(T.Fixed{xs} <> t) : Bool}
          %layout_domain(t, cursor) : {Bool.and(Bool.and(SP.bytes_domain(xs), SP.bytes_domain(S.fixed_parts(t, cursor))), SP.bytes_domain(S.payloads(t))) == Bool.and(SP.bytes_domain(xs), _) : Bool}
          B.and_associative(SP.bytes_domain(xs), SP.bytes_domain(S.fixed_parts(t, cursor)), SP.bytes_domain(S.payloads(t)))
        case T.Variable{xs}:
          %Equal.sym(Bool, SP.bytes_domain(List.append(&2, U32, N.digits(4n, cursor), S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))))), Bool.and(SP.bytes_domain(N.digits(4n, cursor)), SP.bytes_domain(S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))))), bytes_append(N.digits(4n, cursor), S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))))) : {Bool.and(_, SP.bytes_domain(S.payloads(T.Variable{xs} <> t))) == S.bytes_valid(T.Variable{xs} <> t) : Bool}
          %Equal.sym(Bool, SP.bytes_domain(N.digits(4n, cursor)), True{}, Digits.digits_domain(4n, cursor)) : {Bool.and(Bool.and(_, SP.bytes_domain(S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs))))), SP.bytes_domain(S.payloads(T.Variable{xs} <> t))) == S.bytes_valid(T.Variable{xs} <> t) : Bool}
          %Equal.sym(Bool, SP.bytes_domain(List.append(&2, U32, xs, S.payloads(t))), Bool.and(SP.bytes_domain(xs), SP.bytes_domain(S.payloads(t))), bytes_append(xs, S.payloads(t))) : {Bool.and(SP.bytes_domain(S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs)))), _) == S.bytes_valid(T.Variable{xs} <> t) : Bool}
          %layout_domain(t, Nat.add(cursor, List.length(&2, U32, xs))) : {Bool.and(SP.bytes_domain(S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs)))), Bool.and(SP.bytes_domain(xs), SP.bytes_domain(S.payloads(t)))) == Bool.and(SP.bytes_domain(xs), _) : Bool}
          and_shuffle(SP.bytes_domain(S.fixed_parts(t, Nat.add(cursor, List.length(&2, U32, xs)))), SP.bytes_domain(xs), SP.bytes_domain(S.payloads(t)))

law output_length:
  for +parts: +List<T.Part>
  for +cursor: Nat
  {List.length(&2, U32, List.append(&2, U32, S.fixed_parts(parts, cursor), S.payloads(parts))) == Nat.add(S.fixed_size(parts), List.length(&2, U32, S.payloads(parts))) : Nat}
def output_length(parts, cursor):
  %fixed_parts_length(parts, cursor) : {List.length(&2, U32, List.append(&2, U32, S.fixed_parts(parts, cursor), S.payloads(parts))) == Nat.add(_, List.length(&2, U32, S.payloads(parts))) : Nat}
  L.append_length(U32, S.fixed_parts(parts, cursor), S.payloads(parts))

law output_domain:
  for +parts: +List<T.Part>
  for +cursor: Nat
  {SP.bytes_domain(List.append(&2, U32, S.fixed_parts(parts, cursor), S.payloads(parts))) == S.bytes_valid(parts) : Bool}
def output_domain(parts, cursor):
  Equal.trans(Bool, SP.bytes_domain(List.append(&2, U32, S.fixed_parts(parts, cursor), S.payloads(parts))), Bool.and(SP.bytes_domain(S.fixed_parts(parts, cursor)), SP.bytes_domain(S.payloads(parts))), S.bytes_valid(parts), bytes_append(S.fixed_parts(parts, cursor), S.payloads(parts)), layout_domain(parts, cursor))

law and_commute:
  for +a: Bool
  for +b: Bool
  {Bool.and(a, b) == Bool.and(b, a) : Bool}
def and_commute(a, b):
  match a b:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}: {==}

law finish_layout:
  for +parts: +List<T.Part>
  {I.finish(List.reverse(&2, U32, S.fixed_parts(parts, S.fixed_size(parts))), List.reverse(&2, U32, S.payloads(parts))) == S.encoding(parts) : Maybe<&2, +List<U32>>}
def finish_layout(parts):
  %and_commute(N.fits(4n, Nat.add(S.fixed_size(parts), List.length(&2, U32, S.payloads(parts)))), S.bytes_valid(parts)) : {I.finish(List.reverse(&2, U32, S.fixed_parts(parts, S.fixed_size(parts))), List.reverse(&2, U32, S.payloads(parts))) == SP.optional(_, List.append(&2, U32, S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts))) : Maybe<&2, +List<U32>>}
  %output_length(parts, S.fixed_size(parts)) : {I.finish(List.reverse(&2, U32, S.fixed_parts(parts, S.fixed_size(parts))), List.reverse(&2, U32, S.payloads(parts))) == SP.optional(Bool.and(N.fits(4n, _), S.bytes_valid(parts)), List.append(&2, U32, S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts))) : Maybe<&2, +List<U32>>}
  %output_domain(parts, S.fixed_size(parts)) : {I.finish(List.reverse(&2, U32, S.fixed_parts(parts, S.fixed_size(parts))), List.reverse(&2, U32, S.payloads(parts))) == SP.optional(Bool.and(N.fits(4n, List.length(&2, U32, List.append(&2, U32, S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts)))), _), List.append(&2, U32, S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts))) : Maybe<&2, +List<U32>>}
  finish_forward(S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts))

law encode_with_representable_offsets:
  for +parts: +List<T.Part>
  for fit: {S.offsets_fit(parts, S.fixed_size(parts)) == True{} : Bool}
  {I.encode(parts) == S.encoding(parts) : Maybe<&2, +List<U32>>}
def encode_with_representable_offsets(parts, fit):
  %Equal.sym(Nat, I.fixed_length(parts, 0n), S.fixed_size(parts), fixed_length_correct(parts, 0n)) : {I.encode_go(parts, _, [], []) == S.encoding(parts) : Maybe<&2, +List<U32>>}
  Equal.trans(Maybe<&2, +List<U32>>, I.encode_go(parts, S.fixed_size(parts), [], []), I.finish(List.reverse(&2, U32, S.fixed_parts(parts, S.fixed_size(parts))), List.reverse(&2, U32, S.payloads(parts))), S.encoding(parts), encode_accumulators(parts, S.fixed_size(parts), [], [], fit), finish_layout(parts))

law encode_with_size_bound:
  for +parts: +List<T.Part>
  for bound: {N.fits(4n, Nat.add(S.fixed_size(parts), List.length(&2, U32, S.payloads(parts)))) == True{} : Bool}
  {I.encode(parts) == S.encoding(parts) : Maybe<&2, +List<U32>>}
def encode_with_size_bound(parts, bound):
  encode_with_representable_offsets(parts, offsets_representable(parts, S.fixed_size(parts), bound))

law offset_rejection:
  for +ok: Bool
  for +rest_ok: Bool
  for +digits: +List<U32>
  for +fixed: +List<U32>
  for next: +List<U32> -> Maybe<&2, +List<U32>>
  for reject: @bad: {rest_ok == False{} : Bool} -> @+f: +List<U32> -> {next(f) == None{} : Maybe<&2, +List<U32>>}
  for fail: {Bool.and(ok, rest_ok) == False{} : Bool}
  {I.offset_append(SP.optional(ok, digits), fixed, next) == None{} : Maybe<&2, +List<U32>>}
def offset_rejection(ok, rest_ok, digits, fixed, next, reject, fail):
  match ok:
    case False{}: {==}
    case True{}: reject(fail, List.reverse.go(&2, U32, digits, fixed))

law encode_offsets_rejected:
  for +parts: +List<T.Part>
  for +cursor: Nat
  for +fixed: +List<U32>
  for +variable: +List<U32>
  for fail: {S.offsets_fit(parts, cursor) == False{} : Bool}
  {I.encode_go(parts, cursor, fixed, variable) == None{} : Maybe<&2, +List<U32>>}
def encode_offsets_rejected(parts, cursor, fixed, variable, fail):
  match parts:
    case Nil{}: Empty.absurd({I.finish(fixed, variable) == None{} : Maybe<&2, +List<U32>>}, W.false_true(Equal.sym(Bool, True{}, False{}, fail)))
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: encode_offsets_rejected(t, cursor, List.reverse.go(&2, U32, xs, fixed), variable, fail)
        case T.Variable{xs}:
          %Equal.sym(Maybe<&2, +List<U32>>, NB.encode(4n, cursor), N.encoding(4n, cursor), Digits.encode_correct(4n, cursor)) : {I.offset_append(_, fixed, f => I.encode_go(t, Nat.add(cursor, Lists.length(U32, xs)), f, List.reverse.go(&2, U32, xs, variable))) == None{} : Maybe<&2, +List<U32>>}
          %Equal.sym(Nat, Lists.length(U32, xs), List.length(&2, U32, xs), L.length_correct(U32, xs)) : {I.offset_append(N.encoding(4n, cursor), fixed, f => I.encode_go(t, Nat.add(cursor, _), f, List.reverse.go(&2, U32, xs, variable))) == None{} : Maybe<&2, +List<U32>>}
          offset_rejection(N.fits(4n, cursor), S.offsets_fit(t, Nat.add(cursor, List.length(&2, U32, xs))), N.digits(4n, cursor), fixed, f => I.encode_go(t, Nat.add(cursor, List.length(&2, U32, xs)), f, List.reverse.go(&2, U32, xs, variable)), bad => f => encode_offsets_rejected(t, Nat.add(cursor, List.length(&2, U32, xs)), f, List.reverse.go(&2, U32, xs, variable), bad), fail)

law false_from_implication:
  for +a: Bool
  for +b: Bool
  for implies: @e: {a == True{} : Bool} -> {b == True{} : Bool}
  for bad: {b == False{} : Bool}
  {a == False{} : Bool}
def false_from_implication(a, b, implies, bad):
  match a:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, W.false_true(Equal.trans(Bool, False{}, b, True{}, Equal.sym(Bool, b, False{}, bad), implies({==}))))

law spec_offset_rejection:
  for +parts: +List<T.Part>
  for fail: {S.offsets_fit(parts, S.fixed_size(parts)) == False{} : Bool}
  {S.encoding(parts) == None{} : Maybe<&2, +List<U32>>}
def spec_offset_rejection(parts, fail):
  %Equal.sym(Bool, N.fits(4n, Nat.add(S.fixed_size(parts), List.length(&2, U32, S.payloads(parts)))), False{}, false_from_implication(N.fits(4n, Nat.add(S.fixed_size(parts), List.length(&2, U32, S.payloads(parts)))), S.offsets_fit(parts, S.fixed_size(parts)), bound => offsets_representable(parts, S.fixed_size(parts), bound), fail)) : {SP.optional(Bool.and(S.bytes_valid(parts), _), List.append(&2, U32, S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts))) == None{} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Bool.and(S.bytes_valid(parts), False{}), False{}, B.and_zero(S.bytes_valid(parts))) : {SP.optional(_, List.append(&2, U32, S.fixed_parts(parts, S.fixed_size(parts)), S.payloads(parts))) == None{} : Maybe<&2, +List<U32>>}
  {==}

law encode_cases:
  for +parts: +List<T.Part>
  for +ok: Bool
  for +eq: {S.offsets_fit(parts, S.fixed_size(parts)) == ok : Bool}
  {I.encode(parts) == S.encoding(parts) : Maybe<&2, +List<U32>>}
def encode_cases(parts, ok, eq):
  match ok:
    case True{}: encode_with_representable_offsets(parts, eq)
    case False{}:
      %Equal.sym(Nat, I.fixed_length(parts, 0n), S.fixed_size(parts), fixed_length_correct(parts, 0n)) : {I.encode_go(parts, _, [], []) == S.encoding(parts) : Maybe<&2, +List<U32>>}
      Equal.trans(Maybe<&2, +List<U32>>, I.encode_go(parts, S.fixed_size(parts), [], []), None{}, S.encoding(parts), encode_offsets_rejected(parts, S.fixed_size(parts), [], [], eq), Equal.sym(Maybe<&2, +List<U32>>, S.encoding(parts), None{}, spec_offset_rejection(parts, eq)))

# Unconditional, including non-byte fragments and every overflowing layout.
law encode_correct:
  for +parts: +List<T.Part>
  {I.encode(parts) == S.encoding(parts) : Maybe<&2, +List<U32>>}
def encode_correct(parts):
  encode_cases(parts, S.offsets_fit(parts, S.fixed_size(parts)), {==})
