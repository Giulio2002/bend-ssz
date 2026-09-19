import Base
import ../src/lists.bend as ILLists
import ../types/schema.bend as T
import ../src/codec.bend as I
import ../src/layout.bend as IL
import ../spec/codec.bend as S
import ../spec/layout.bend as SL
import ../spec/schema.bend as Schema
import ./layout.bend as Layout
import ./lists.bend as Lists

law fragment_correct:
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  {I.part(width, xs) == S.fragment(width, xs) : T.Part}
def fragment_correct(width, xs):
  match width:
    case None{}: {==}
    case Some{n}: {==}

law wrap_correct:
  for +result: Maybe<&2, +List<U32>>
  for +width: Maybe<&2, Nat>
  {I.wrap(result, width) == S.one(result, width) : Maybe<&2, +List<T.Part>>}
def wrap_correct(result, width):
  match result:
    case None{}: {==}
    case Some{xs}: Equal.cong(T.Part, Maybe<&2, +List<T.Part>>, part => Some{[part]}, I.part(width, xs), S.fragment(width, xs), fragment_correct(width, xs))

law layout_correct:
  for +parts: Maybe<&2, +List<T.Part>>
  for +width: Maybe<&2, Nat>
  {I.layout(parts, width) == S.aggregate(parts, width) : Maybe<&2, +List<T.Part>>}
def layout_correct(parts, width):
  match parts:
    case None{}: {==}
    case Some{xs}:
      %Layout.encode_correct(xs) : {I.wrap(IL.encode(xs), width) == S.one(_, width) : Maybe<&2, +List<T.Part>>}
      wrap_correct(IL.encode(xs), width)

law unwrap_correct:
  for +result: Maybe<&2, +List<T.Part>>
  {I.unwrap(result) == S.bytes(result) : Maybe<&2, +List<U32>>}
def unwrap_correct(result):
  match result:
    case None{}: {==}
    case Some{parts}:
      match parts:
        case Nil{}: {==}
        case Con{h, t}:
          match h:
            case T.Fixed{xs}:
              match t:
                case Nil{}: {==}
                case Con{a, b}: {==}
            case T.Variable{xs}:
              match t:
                case Nil{}: {==}
                case Con{a, b}: {==}

law join_correct:
  for +a: Maybe<&2, +List<T.Part>>
  for +b: Maybe<&2, +List<T.Part>>
  {I.join(a, b) == S.concatenate(a, b) : Maybe<&2, +List<T.Part>>}
def join_correct(a, b):
  match a b:
    case None{} None{}: {==}
    case None{} Some{ys}: {==}
    case Some{xs} None{}: {==}
    case Some{xs} Some{ys}: Equal.cong(+List<T.Part>, Maybe<&2, +List<T.Part>>, parts => Some{parts}, ILLists.append(T.Part, xs, ys), List.append(&2, T.Part, xs, ys), Lists.append_correct(T.Part, xs, ys))

law gate_correct:
  for +ok: Bool
  for -next: Unit -> Maybe<&2, +List<T.Part>>
  {I.gate(ok, next) == S.require(ok, next(Unit{})) : Maybe<&2, +List<T.Part>>}
def gate_correct(ok, next):
  match ok:
    case False{}: {==}
    case True{}: {==}

law tagged_correct:
  for +selector: U32
  for +parts: Maybe<&2, +List<T.Part>>
  {I.wrap(IL.append(Some{[selector]}, I.unwrap(parts)), None{}) == S.tagged(selector, parts) : Maybe<&2, +List<T.Part>>}
def tagged_correct(selector, parts):
  match parts:
    case None{}: {==}
    case Some{items}:
      match items:
        case Nil{}: {==}
        case Con{h, t}:
          match h:
            case T.Fixed{xs}:
              match t:
                case Nil{}: {==}
                case Con{a, b}: {==}
            case T.Variable{xs}:
              match t:
                case Nil{}: {==}
                case Con{a, b}: {==}

law select_correct:
  for +ok: Bool
  for +schema: T.Schema
  for -next: Unit -> Maybe<&2, T.Schema>
  {I.select_option(ok, schema, next) == Schema.selected(ok, schema, next(Unit{})) : Maybe<&2, T.Schema>}
def select_correct(ok, schema, next):
  match ok:
    case False{}: {==}
    case True{}: {==}

law with_schema_correct:
  for +option: Maybe<&2, T.Schema>
  for -next: T.Schema -> Maybe<&2, +List<T.Part>>
  {I.with_schema(option, next) == S.with_option(option, next) : Maybe<&2, +List<T.Part>>}
def with_schema_correct(option, next):
  match option:
    case None{}: {==}
    case Some{s}: {==}

law selected_schema_correct:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +selector: U32
  {I.selected_schema(selectors, options, selector) == Schema.compatible_option(selectors, options, selector) : Maybe<&2, T.Schema>}
def selected_schema_correct(selectors, options, selector):
  match selectors:
    case Nil{}: {==}
    case Con{h, t}:
      match options:
        case T.Chain{s, rest}:
          %selected_schema_correct(t, rest, selector) : {I.selected_schema(h <> t, T.Chain{s, rest}, selector) == Schema.selected(U32.is_eq(h, selector), s, _) : Maybe<&2, T.Schema>}
          select_correct(U32.is_eq(h, selector), s, u => I.selected_schema(t, rest, selector))
        case T.Boolean{}: {==}
        case T.Unsigned{x0}: {==}
        case T.ByteVector{x0}: {==}
        case T.ByteList{x0}: {==}
        case T.BitVector{x0}: {==}
        case T.BitList{x0}: {==}
        case T.Vector{x0, x1}: {==}
        case T.ListOf{x0, x1}: {==}
        case T.Container{x0, x1}: {==}
        case T.Union{x0}: {==}
        case T.Null{}: {==}
        case T.End{}: {==}
        case T.Repeat{x0}: {==}
        case T.Named{x0, x1}: {==}
        case T.ProgressiveList{x0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{x0, x1, x2}: {==}
        case T.CompatibleUnion{x0, x1}: {==}
