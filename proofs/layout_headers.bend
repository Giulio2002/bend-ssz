import Base
import ../src/lists.bend as Lists
import ./lists.bend as L
import ../src/bytes.bend as Bytes
import ../src/packing.bend as Packing
import ../spec/nat_bytes.bend as N
import ../src/primitives.bend as IP
import ../src/layout.bend as I
import ../spec/layout_decoding.bend as S
import ../spec/primitives.bend as P
import ../types/schema.bend as T
import ./layout_slices.bend as Cut
import ./layout_extents.bend as Extents
import ./integer_decoding.bend as Integer
import ./primitive_invariants.bend as V
import ./layout.bend as Layout
import ./packing.bend as Pack

# Interpret an already collected reversed header prefix followed by a forward
# semantic header suffix. This is a proof relation, not a specification API.
def finish(region: Maybe<&2, S.HeaderRegion>, acc: +List<T.Header>, base: Nat, total: Nat) -> Maybe<&2, +List<+List<U32>>>:
  match region:
    case None{}: None{}
    case Some{S.HeaderRegion{fields, payload}}: I.resolve(List.reverse.go(&2, T.Header, acc, fields), base, total, payload, [])

law finish_prepend:
  for +region: Maybe<&2, S.HeaderRegion>
  for +item: T.Header
  for +acc: +List<T.Header>
  for +base: Nat
  for +total: Nat
  {finish(region, item <> acc, base, total) == finish(S.prepend_header(item, region), acc, base, total) : Maybe<&2, +List<+List<U32>>>}
def finish_prepend(region, item, acc, base, total):
  match region:
    case None{}: {==}
    case Some{S.HeaderRegion{fields, payload}}: {==}

def scan(result: Maybe<&2, S.Slice>, width: Maybe<&2, Nat>, next: T.Header -> +List<U32> -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{S.Slice{xs, rest}}: next(S.field(width, xs), rest)

law read_header_some:
  for +xs: +List<U32>
  for +rest: +List<U32>
  for +width: Maybe<&2, Nat>
  for -next: T.Header -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for valid: {P.bytes_domain(xs) == True{} : Bool}
  {I.read_header(Some{I.Split{xs, rest}}, width, next) == next(S.field(width, xs), rest) : Maybe<&2, +List<+List<U32>>>}
def read_header_some(xs, rest, width, next, valid):
  match width:
    case Some{n}: {==}
    case None{}:
      Equal.cong(U32, Maybe<&2, +List<+List<U32>>>, x => next(T.Offset{U32.to_nat(x)}, rest), IP.read_limb(xs, 0n), P.limb_value(xs, 0n), Integer.read_limb_correct(xs, 0n, valid))

law scan_source:
  for +result: Maybe<&2, I.Split>
  for +width: Maybe<&2, Nat>
  for -next: T.Header -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for valid: {Cut.domain(Cut.abstract(result)) == True{} : Bool}
  {I.read_header(result, width, next) == scan(Cut.abstract(result), width, next) : Maybe<&2, +List<+List<U32>>>}
def scan_source(result, width, next, valid):
  match result:
    case None{}: {==}
    case Some{I.Split{xs, rest}}: read_header_some(xs, rest, width, next, V.and_left(P.bytes_domain(xs), P.bytes_domain(rest), valid))

law scan_refinement:
  for +result: Maybe<&2, S.Slice>
  for +width: Maybe<&2, Nat>
  for +acc: +List<T.Header>
  for +base: Nat
  for +total: Nat
  for -next: T.Header -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for forward: +List<U32> -> Maybe<&2, S.HeaderRegion>
  for recur: @+item: T.Header -> @+rest: +List<U32> -> {P.bytes_domain(rest) == True{} : Bool} -> {next(item, rest) == finish(forward(rest), item <> acc, base, total) : Maybe<&2, +List<+List<U32>>>}
  for valid: {Cut.domain(result) == True{} : Bool}
  {scan(result, width, next) == finish(S.read_slice(result, width, forward), acc, base, total) : Maybe<&2, +List<+List<U32>>>}
def scan_refinement(result, width, acc, base, total, next, forward, recur, valid):
  match result:
    case None{}: {==}
    case Some{S.Slice{xs, rest}}:
      Equal.trans(Maybe<&2, +List<+List<U32>>>, next(S.field(width, xs), rest), finish(forward(rest), S.field(width, xs) <> acc, base, total), finish(S.prepend_header(S.field(width, xs), forward(rest)), acc, base, total), recur(S.field(width, xs), rest, V.and_right(P.bytes_domain(xs), P.bytes_domain(rest), valid)), finish_prepend(forward(rest), S.field(width, xs), acc, base, total))

law slot_correct:
  for +width: Maybe<&2, Nat>
  {I.slot(width) == S.slot(width) : Nat}
def slot_correct(width):
  match width:
    case None{}: {==}
    case Some{n}: {==}

law split_domain:
  for +n: Nat
  for +xs: +List<U32>
  for valid: {P.bytes_domain(xs) == True{} : Bool}
  {Cut.domain(Cut.abstract(I.split(n, xs))) == True{} : Bool}
def split_domain(n, xs, valid):
  %Equal.sym(Maybe<&2, S.Slice>, Cut.abstract(I.split(n, xs)), S.cut(n, xs), Cut.split_correct(n, xs)) : {Cut.domain(_) == True{} : Bool}
  Cut.cut_domain(n, xs, valid)

law scan_split:
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for +acc: +List<T.Header>
  for +base: Nat
  for +total: Nat
  for -next: T.Header -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for forward: +List<U32> -> Maybe<&2, S.HeaderRegion>
  for recur: @+item: T.Header -> @+rest: +List<U32> -> {P.bytes_domain(rest) == True{} : Bool} -> {next(item, rest) == finish(forward(rest), item <> acc, base, total) : Maybe<&2, +List<+List<U32>>>}
  for +valid: {P.bytes_domain(xs) == True{} : Bool}
  {I.read_header(I.split(I.slot(width), xs), width, next) == finish(S.read_slice(S.cut(S.slot(width), xs), width, forward), acc, base, total) : Maybe<&2, +List<+List<U32>>>}
def scan_split(width, xs, acc, base, total, next, forward, recur, valid):
  %slot_correct(width) : {I.read_header(I.split(I.slot(width), xs), width, next) == finish(S.read_slice(S.cut(_, xs), width, forward), acc, base, total) : Maybe<&2, +List<+List<U32>>>}
  %Cut.split_correct(I.slot(width), xs) : {I.read_header(I.split(I.slot(width), xs), width, next) == finish(S.read_slice(_, width, forward), acc, base, total) : Maybe<&2, +List<+List<U32>>>}
  Equal.trans(Maybe<&2, +List<+List<U32>>>, I.read_header(I.split(I.slot(width), xs), width, next), scan(Cut.abstract(I.split(I.slot(width), xs)), width, next), finish(S.read_slice(Cut.abstract(I.split(I.slot(width), xs)), width, forward), acc, base, total), scan_source(I.split(I.slot(width), xs), width, next, split_domain(I.slot(width), xs, valid)), scan_refinement(Cut.abstract(I.split(I.slot(width), xs)), width, acc, base, total, next, forward, recur, split_domain(I.slot(width), xs, valid)))

law headers_correct:
  for +widths: +List<Maybe<&2, Nat>>
  for +base: Nat
  for +total: Nat
  for +xs: +List<U32>
  for +acc: +List<T.Header>
  for valid: {P.bytes_domain(xs) == True{} : Bool}
  {I.headers(widths, base, total, xs, acc) == finish(S.read(widths, xs), acc, base, total) : Maybe<&2, +List<+List<U32>>>}
def headers_correct(widths, base, total, xs, acc, valid):
  match widths:
    case Nil{}: {==}
    case Con{h, t}:
      scan_split(h, xs, acc, base, total, item => rest => I.headers(t, base, total, rest, item <> acc), rest => S.read(t, rest), item => rest => domain => headers_correct(t, base, total, rest, item <> acc, domain), valid)

law header_length_correct:
  for +widths: +List<Maybe<&2, Nat>>
  for +acc: Nat
  {I.header_length(widths, acc) == Nat.add(acc, S.fixed_size(widths)) : Nat}
def header_length_correct(widths, acc):
  match widths:
    case Nil{}: Equal.sym(Nat, Nat.add(acc, 0n), acc, Pack.add_zero(acc))
    case Con{h, t}:
      match h:
        case None{}: Equal.trans(Nat, I.header_length(t, Nat.add(acc, 4n)), Nat.add(Nat.add(acc, 4n), S.fixed_size(t)), Nat.add(acc, Nat.add(4n, S.fixed_size(t))), header_length_correct(t, Nat.add(acc, 4n)), Layout.add_associative(acc, 4n, S.fixed_size(t)))
        case Some{n}: Equal.trans(Nat, I.header_length(t, Nat.add(acc, n)), Nat.add(Nat.add(acc, n), S.fixed_size(t)), Nat.add(acc, Nat.add(n, S.fixed_size(t))), header_length_correct(t, Nat.add(acc, n)), Layout.add_associative(acc, n, S.fixed_size(t)))

law finish_correct:
  for +region: Maybe<&2, S.HeaderRegion>
  for +base: Nat
  for +total: Nat
  {finish(region, [], base, total) == S.resolve(region, base, total) : Maybe<&2, +List<+List<U32>>>}
def finish_correct(region, base, total):
  match region:
    case None{}: {==}
    case Some{S.HeaderRegion{fields, payload}}: Extents.extents_correct(fields, base, total, payload)

law headers_public:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  for valid: {P.bytes_domain(xs) == True{} : Bool}
  {I.headers(widths, I.header_length(widths, 0n), Lists.length(U32, xs), xs, []) == S.resolve(S.read(widths, xs), S.fixed_size(widths), List.length(&2, U32, xs)) : Maybe<&2, +List<+List<U32>>>}
def headers_public(widths, xs, valid):
  %header_length_correct(widths, 0n) : {I.headers(widths, I.header_length(widths, 0n), Lists.length(U32, xs), xs, []) == S.resolve(S.read(widths, xs), _, List.length(&2, U32, xs)) : Maybe<&2, +List<+List<U32>>>}
  %L.length_correct(U32, xs) : {I.headers(widths, I.header_length(widths, 0n), Lists.length(U32, xs), xs, []) == S.resolve(S.read(widths, xs), I.header_length(widths, 0n), _) : Maybe<&2, +List<+List<U32>>>}
  Equal.trans(Maybe<&2, +List<+List<U32>>>, I.headers(widths, I.header_length(widths, 0n), Lists.length(U32, xs), xs, []), finish(S.read(widths, xs), [], I.header_length(widths, 0n), Lists.length(U32, xs)), S.resolve(S.read(widths, xs), I.header_length(widths, 0n), Lists.length(U32, xs)), headers_correct(widths, I.header_length(widths, 0n), Lists.length(U32, xs), xs, [], valid), finish_correct(S.read(widths, xs), I.header_length(widths, 0n), Lists.length(U32, xs)))

law decode_gate_correct:
  for +ok: Bool
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  for valid: {ok == True{} : Bool} -> {P.bytes_domain(xs) == True{} : Bool}
  {I.decode_gate(ok, widths, xs) == S.require(ok, u => S.resolve(S.read(widths, xs), S.fixed_size(widths), List.length(&2, U32, xs))) : Maybe<&2, +List<+List<U32>>>}
def decode_gate_correct(ok, widths, xs, valid):
  match ok:
    case False{}: {==}
    case True{}: headers_public(widths, xs, valid({==}))

law gate_condition:
  for +xs: +List<U32>
  {Bool.and(Bytes.size_fits(Lists.length(U32, xs)), Packing.valid_go(xs, True{})) == Bool.and(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs))) : Bool}
def gate_condition(xs):
  %Layout.and_commute(N.fits(4n, List.length(&2, U32, xs)), P.bytes_domain(xs)) : {Bool.and(Bytes.size_fits(Lists.length(U32, xs)), Packing.valid_go(xs, True{})) == _ : Bool}
  %L.length_correct(U32, xs) : {Bool.and(Bytes.size_fits(Lists.length(U32, xs)), Packing.valid_go(xs, True{})) == Bool.and(N.fits(4n, _), P.bytes_domain(xs)) : Bool}
  Equal.cong(Bool, Bool, ok => Bool.and(Bytes.size_fits(Lists.length(U32, xs)), ok), Packing.valid_go(xs, True{}), P.bytes_domain(xs), Pack.valid_go_correct(xs, True{}))

# No input invariants remain on this public layout-decoder refinement.
law decode_correct:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  {I.decode(widths, xs) == S.decoding(widths, xs) : Maybe<&2, +List<+List<U32>>>}
def decode_correct(widths, xs):
  %Equal.sym(Bool, Bool.and(Bytes.size_fits(Lists.length(U32, xs)), Packing.valid_go(xs, True{})), Bool.and(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs))), gate_condition(xs)) : {I.decode_gate(_, widths, xs) == S.decoding(widths, xs) : Maybe<&2, +List<+List<U32>>>}
  decode_gate_correct(Bool.and(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs))), widths, xs, valid => V.and_left(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs)), valid))
