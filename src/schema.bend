import Base
import ./lists.bend as Lists
import ../types/schema.bend as T
import ./primitives.bend as P

# Internal Chain/End nodes represent a schema forest. Public type validation
# excludes these internal nodes as a value's type.
def add_size(a: Maybe<&2, Nat>, b: Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match a b:
    case Some{x} Some{y}: Some{Nat.add(x, y)}
    case _ _: None{}

def scale_size(n: Nat, size: Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match size:
    case None{}: None{}
    case Some{s}: Some{Nat.mul(n, s)}

def fixed_size(schema: T.Schema) -> Maybe<&2, Nat>:
  match schema:
    case T.Boolean{}: Some{1n}
    case T.Unsigned{w}: Some{P.width(w)}
    case T.ByteVector{n}: Some{n}
    case T.BitVector{n}: Some{Nat.div(Nat.add(n, 7n), 8n)}
    case T.Vector{e, n}: scale_size(n, fixed_size(e))
    case T.Container{names, fields}: fixed_size(fields)
    case T.ProgressiveContainer{names, fields, active}: fixed_size(fields)
    case T.Chain{h, t}: add_size(fixed_size(h), fixed_size(t))
    case T.End{}: Some{0n}
    case T.Null{}: Some{0n}
    case _: None{}

def weight(schema: T.Schema) -> Nat:
  match schema:
    case T.Vector{e, n}: 1n+weight(e)
    case T.ListOf{e, n}: 1n+weight(e)
    case T.ProgressiveList{e}: 1n+weight(e)
    case T.Repeat{e}: 1n+weight(e)
    case T.Named{name, e}: 1n+weight(e)
    case T.Container{names, fields}: 1n+weight(fields)
    case T.ProgressiveContainer{names, fields, active}: 1n+weight(fields)
    case T.Union{options}: 1n+weight(options)
    case T.CompatibleUnion{selectors, options}: 1n+weight(options)
    case T.Chain{h, t}: 1n+Nat.add(weight(h), weight(t))
    case _: 1n

def basic_size(schema: T.Schema) -> Maybe<&2, Nat>:
  match schema:
    case T.Boolean{}: Some{1n}
    case T.Unsigned{w}: Some{P.width(w)}
    case _: None{}

def count(schema: T.Schema) -> Nat:
  match schema:
    case T.Chain{h, t}: 1n+count(t)
    case _: 0n

def get(schema: T.Schema, n: Nat) -> Maybe<&2, T.Schema>:
  match schema:
    case T.Chain{h, t}:
      match n:
        case 0n: Some{h}
        case 1n+p: get(t, p)
    case _: None{}

def widths(schema: T.Schema) -> +List<Maybe<&2, Nat>>:
  match schema:
    case T.Chain{h, t}: fixed_size(h) <> widths(t)
    case _: []

def names_equal(a: +List<String>, b: +List<String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(String.eq(x, y), names_equal(xs, ys))
    case _ _: False{}

def contains_name(+name: String, names: +List<String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(String.eq(name, h), contains_name(name, t))

def unique_names(names: +List<String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{h, +t}: Bool.and(Bool.not(contains_name(h, t)), unique_names(t))

def active_count(active: +List<Bool>, +acc: Nat) -> Nat:
  match active:
    case Nil{}: acc
    case Con{h, t}: active_count(t, Bool.pick(Nat, h, 1n+acc, acc))

def ends_active(active: +List<Bool>, last: Bool) -> Bool:
  match active:
    case Nil{}: last
    case Con{h, t}: ends_active(t, h)

def has_selector(+selector: U32, xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(U32.is_eq(selector, h), has_selector(selector, t))

def selectors_valid(selectors: +List<U32>, +seen: +List<U32>) -> Bool:
  match selectors:
    case Nil{}: True{}
    case Con{+h, t}: Bool.and(Bool.and(U32.is_lt(0, h), U32.is_lt(h, 128)), Bool.and(Bool.not(has_selector(h, seen)), selectors_valid(t, h <> seen)))

def active_fields(active: +List<Bool>, names: +List<String>, fields: T.Schema) -> T.Schema:
  match active:
    case Nil{}: T.End{}
    case Con{a, t}:
      match a:
        case False{}: T.Chain{T.Null{}, active_fields(t, names, fields)}
        case True{}:
          match names fields:
            case Con{n, ns} T.Chain{s, ss}: T.Chain{T.Named{n, s}, active_fields(t, ns, ss)}
            case _ _: T.End{}

# A shared field name must retain its active position, including when the
# other schema omits different slots. Comparing only overlapping slots is
# insufficient: it would accept a field moved across an inactive slot.
def position_choice(equal: Bool, position: Nat, next: Unit -> Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match equal:
    case True{}: Some{position}
    case False{}: next(Unit{})

def field_position(fields: T.Schema, +name: String, +position: Nat) -> Maybe<&2, Nat>:
  match fields:
    case T.Chain{T.Named{n, f}, t}: position_choice(String.eq(name, n), position, u => field_position(t, name, 1n+position))
    case T.Chain{h, t}: field_position(t, name, 1n+position)
    case _: None{}

def same_position(result: Maybe<&2, Nat>, position: Nat) -> Bool:
  match result:
    case None{}: True{}
    case Some{n}: Nat.is_eq(n, position)

def shared_positions(a: T.Schema, +b: T.Schema, +position: Nat) -> Bool:
  match a:
    case T.Chain{T.Named{n, f}, t}: Bool.and(same_position(field_position(b, n, 0n), position), shared_positions(t, b, 1n+position))
    case T.Chain{h, t}: shared_positions(t, b, 1n+position)
    case _: True{}

# Ordinary unions are compatible only with the same option types. In
# particular, compatibility of progressive fields alone does not identify two
# distinct ordinary union types.
def bools_equal(a: +List<Bool>, b: +List<Bool>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(Bool.not(Bool.xor(x, y)), bools_equal(xs, ys))
    case _ _: False{}

def selectors_equal(a: +List<U32>, b: +List<U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(U32.is_eq(x, y), selectors_equal(xs, ys))
    case _ _: False{}

def identical(a: T.Schema, b: T.Schema) -> Bool:
  match a b:
    case T.Boolean{} T.Boolean{}: True{}
    case T.Unsigned{wa} T.Unsigned{wb}: Nat.is_eq(P.width(wa), P.width(wb))
    case T.ByteVector{n} T.ByteVector{m}: Nat.is_eq(n, m)
    case T.ByteList{n} T.ByteList{m}: Nat.is_eq(n, m)
    case T.ByteVector{n} T.Vector{T.Unsigned{w}, m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
    case T.Vector{T.Unsigned{w}, n} T.ByteVector{m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
    case T.ByteList{n} T.ListOf{T.Unsigned{w}, m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
    case T.ListOf{T.Unsigned{w}, n} T.ByteList{m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
    case T.BitVector{n} T.BitVector{m}: Nat.is_eq(n, m)
    case T.BitList{n} T.BitList{m}: Nat.is_eq(n, m)
    case T.Vector{x, n} T.Vector{y, m}: Bool.and(Nat.is_eq(n, m), identical(x, y))
    case T.ListOf{x, n} T.ListOf{y, m}: Bool.and(Nat.is_eq(n, m), identical(x, y))
    case T.ProgressiveList{x} T.ProgressiveList{y}: identical(x, y)
    case T.ProgressiveBits{} T.ProgressiveBits{}: True{}
    case T.Container{na, fa} T.Container{nb, fb}: Bool.and(names_equal(na, nb), identical(fa, fb))
    case T.ProgressiveContainer{na, fa, aa} T.ProgressiveContainer{nb, fb, ab}: Bool.and(names_equal(na, nb), Bool.and(bools_equal(aa, ab), identical(fa, fb)))
    case T.Named{na, fa} T.Named{nb, fb}: Bool.and(String.eq(na, nb), identical(fa, fb))
    case T.Union{as} T.Union{bs}: identical(as, bs)
    case T.CompatibleUnion{sa, as} T.CompatibleUnion{sb, bs}: Bool.and(selectors_equal(sa, sb), identical(as, bs))
    case T.Chain{ah, at} T.Chain{bh, bt}: Bool.and(identical(ah, bh), identical(at, bt))
    case T.Null{} T.Null{}: True{}
    case T.End{} T.End{}: True{}
    case _ _: False{}

# Compatibility is checked recursively, with input-derived traversal fuel.
# mode 0: normal pair; 1: all pairs in two forests; 2: one vs forest;
# mode 3: aligned progressive slots, allowing absent fields.
def compatible_go(+fuel: Nat, mode: U32, +a: T.Schema, +b: T.Schema) -> Bool:
  match fuel:
    case 0n: False{}
    case 1n+p:
      match mode:
        case 1:
          match a:
            case T.End{}: True{}
            case T.Chain{h, t}: Bool.and(compatible_go(p, 2, h, b), compatible_go(p, 1, t, b))
            case _: False{}
        case 2:
          match b:
            case T.End{}: True{}
            case T.Chain{h, t}: Bool.and(compatible_go(p, 0, a, h), compatible_go(p, 2, a, t))
            case _: False{}
        case 3:
          match a b:
            case T.End{} _: True{}
            case _ T.End{}: True{}
            case T.Chain{T.Null{}, at} T.Chain{bh, bt}: compatible_go(p, 3, at, bt)
            case T.Chain{ah, at} T.Chain{T.Null{}, bt}: compatible_go(p, 3, at, bt)
            case T.Chain{ah, at} T.Chain{bh, bt}: Bool.and(compatible_go(p, 0, ah, bh), compatible_go(p, 3, at, bt))
            case _ _: False{}
        case _:
          match a b:
            case T.Boolean{} T.Boolean{}: True{}
            case T.Unsigned{wa} T.Unsigned{wb}: Nat.is_eq(P.width(wa), P.width(wb))
            case T.ByteVector{n} T.ByteVector{m}: Nat.is_eq(n, m)
            case T.ByteList{n} T.ByteList{m}: Nat.is_eq(n, m)
            case T.ByteVector{n} T.Vector{T.Unsigned{w}, m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
            case T.Vector{T.Unsigned{w}, n} T.ByteVector{m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
            case T.ByteList{n} T.ListOf{T.Unsigned{w}, m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
            case T.ListOf{T.Unsigned{w}, n} T.ByteList{m}: Bool.and(Nat.is_eq(n, m), Nat.is_eq(P.width(w), 1n))
            case T.BitVector{n} T.BitVector{m}: Nat.is_eq(n, m)
            case T.BitList{n} T.BitList{m}: Nat.is_eq(n, m)
            case T.Vector{x, n} T.Vector{y, m}: Bool.and(Nat.is_eq(n, m), compatible_go(p, 0, x, y))
            case T.ListOf{x, n} T.ListOf{y, m}: Bool.and(Nat.is_eq(n, m), compatible_go(p, 0, x, y))
            case T.ProgressiveList{x} T.ProgressiveList{y}: compatible_go(p, 0, x, y)
            case T.ProgressiveBits{} T.ProgressiveBits{}: True{}
            case T.Container{na, fa} T.Container{nb, fb}: Bool.and(names_equal(na, nb), compatible_go(p, 0, fa, fb))
            case T.ProgressiveContainer{+na, +fa, +aa} T.ProgressiveContainer{+nb, +fb, +ab}: Bool.or(identical(T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab}), Bool.and(shared_positions(active_fields(aa, na, fa), active_fields(ab, nb, fb), 0n), compatible_go(p, 3, active_fields(aa, na, fa), active_fields(ab, nb, fb))))
            case T.Named{na, fa} T.Named{nb, fb}: Bool.and(String.eq(na, nb), compatible_go(p, 0, fa, fb))
            case T.Union{as} T.Union{bs}: identical(as, bs)
            case T.Null{} T.Null{}: True{}
            case T.Chain{ah, at} T.Chain{bh, bt}: Bool.and(compatible_go(p, 0, ah, bh), compatible_go(p, 0, at, bt))
            case T.End{} T.End{}: True{}
            case T.CompatibleUnion{sa, as} T.CompatibleUnion{sb, bs}: Bool.or(identical(T.CompatibleUnion{sa, as}, T.CompatibleUnion{sb, bs}), compatible_go(p, 1, as, bs))
            case _ _: False{}

def compatible(+a: T.Schema, +b: T.Schema) -> Bool:
  compatible_go(Nat.mul(1024n, 1n+Nat.add(weight(a), weight(b))), 0, a, b)

def named_fields_valid(+names: +List<String>, +fields: T.Schema) -> Bool:
  Bool.and(Nat.is_lt(0n, count(fields)), Bool.and(Nat.is_eq(Lists.length(String, names), count(fields)), unique_names(names)))

def valid_go(schema: T.Schema, forest: Bool) -> Bool:
  match schema:
    case T.Boolean{}: Bool.not(forest)
    case T.Unsigned{w}: Bool.not(forest)
    case T.ByteVector{n}: Bool.and(Bool.not(forest), Nat.is_lt(0n, n))
    case T.ByteList{n}: Bool.not(forest)
    case T.BitVector{n}: Bool.and(Bool.not(forest), Nat.is_lt(0n, n))
    case T.BitList{n}: Bool.not(forest)
    case T.Vector{e, n}: Bool.and(Bool.not(forest), Bool.and(Nat.is_lt(0n, n), valid_go(e, False{})))
    case T.ListOf{e, n}: Bool.and(Bool.not(forest), valid_go(e, False{}))
    case T.Container{names, +fields}: Bool.and(Bool.not(forest), Bool.and(named_fields_valid(names, fields), valid_go(fields, True{})))
    case T.Union{T.Chain{T.Null{}, +t}}: Bool.and(Bool.not(forest), Bool.and(Nat.is_lt(0n, count(t)), Bool.and(Nat.is_le(count(t), 127n), valid_go(t, True{}))))
    case T.Union{T.Chain{h, +t}}: Bool.and(Bool.not(forest), Bool.and(Nat.is_le(count(t), 127n), Bool.and(valid_go(h, False{}), valid_go(t, True{}))))
    case T.Union{_}: False{}
    case T.ProgressiveList{e}: Bool.and(Bool.not(forest), valid_go(e, False{}))
    case T.ProgressiveBits{}: Bool.not(forest)
    case T.ProgressiveContainer{names, +fields, +active}:
      Bool.and(Bool.not(forest), Bool.and(named_fields_valid(names, fields), Bool.and(valid_go(fields, True{}), Bool.and(Nat.is_le(Lists.length(Bool, active), 256n), Bool.and(ends_active(active, False{}), Nat.is_eq(active_count(active, 0n), count(fields)))))))
    case T.CompatibleUnion{+selectors, +options}:
      Bool.and(Bool.not(forest), Bool.and(Nat.is_lt(0n, count(options)), Bool.and(Nat.is_eq(Lists.length(U32, selectors), count(options)), Bool.and(selectors_valid(selectors, []), Bool.and(valid_go(options, True{}), compatible_go(Nat.mul(1024n, 1n+weight(options)), 1, options, options))))))
    case T.Chain{h, t}: Bool.and(forest, Bool.and(valid_go(h, False{}), valid_go(t, True{})))
    case T.End{}: forest
    case _: False{}

def valid(schema: T.Schema) -> Bool: valid_go(schema, False{})
