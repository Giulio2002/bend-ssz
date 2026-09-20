import Base
import ../types/schema.bend as T
import ../src/schema.bend as IS
import ../src/lists.bend as ILists
import ../spec/codec.bend as SC
import ./word_facts.bend as F
import ./primitive_invariants.bend as V
import ./cursor_walk.bend as CW



# Structural legality, as the decoder's recursion needs it.
#
# `src/schema.valid_go` is the public type validator; it rejects `Null`
# everywhere except as a union's first option, and it carries conditions the
# decoder never consults. This module extracts exactly the structural facts
# the soundness recursion uses: that a container's fields (and a union's
# options) really are a declaration-order forest, and that every element
# schema a walk descends into is itself structurally usable. Nothing here is
# assumed; `from_valid` derives all of it from the public validator.

law forest_of_valid:
  for +fs: T.Schema
  for +legal: {IS.valid_go(fs, True{}) == True{} : Bool}
  {CW.forest_ok(fs) == True{} : Bool}
def forest_of_valid(fs, legal):
  match fs:
    case T.Chain{hh, tt}: forest_of_valid(tt, V.and_right(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), V.and_right(True{}, Bool.and(IS.valid_go(hh, False{}), IS.valid_go(tt, True{})), legal)))
    case T.End{}: {==}
    case T.Boolean{}: Empty.absurd({CW.forest_ok(T.Boolean{}) == True{} : Bool}, F.false_true(legal))
    case T.Unsigned{w}: Empty.absurd({CW.forest_ok(T.Unsigned{w}) == True{} : Bool}, F.false_true(legal))
    case T.ByteVector{m}: Empty.absurd({CW.forest_ok(T.ByteVector{m}) == True{} : Bool}, F.false_true(legal))
    case T.ByteList{m}: Empty.absurd({CW.forest_ok(T.ByteList{m}) == True{} : Bool}, F.false_true(legal))
    case T.BitVector{m}: Empty.absurd({CW.forest_ok(T.BitVector{m}) == True{} : Bool}, F.false_true(legal))
    case T.BitList{m}: Empty.absurd({CW.forest_ok(T.BitList{m}) == True{} : Bool}, F.false_true(legal))
    case T.Vector{e, m}: Empty.absurd({CW.forest_ok(T.Vector{e, m}) == True{} : Bool}, F.false_true(legal))
    case T.ListOf{e, m}: Empty.absurd({CW.forest_ok(T.ListOf{e, m}) == True{} : Bool}, F.false_true(legal))
    case T.Container{names, fields}: Empty.absurd({CW.forest_ok(T.Container{names, fields}) == True{} : Bool}, F.false_true(legal))
    case T.Union{options}:
      match options:
        case T.Chain{oh, ot}:
          match oh:
            case T.Boolean{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Unsigned{zw}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.ByteVector{zm}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.ByteList{zm}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.BitVector{zm}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.BitList{zm}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Vector{ze, zm}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.ListOf{ze, zm}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Container{zn, zf}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Union{zo}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Null{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Chain{zh, zt}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.End{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Repeat{ze}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.Named{zn, ze}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.ProgressiveList{ze}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.ProgressiveBits{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.ProgressiveContainer{zn, zf, za}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
            case T.CompatibleUnion{zs, zo}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Boolean{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Unsigned{yw}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.ByteVector{ym}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.ByteList{ym}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.BitVector{ym}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.BitList{ym}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Vector{ye, ym}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.ListOf{ye, ym}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Container{yn, yf}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Union{yo}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Null{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.End{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Repeat{ye}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.Named{yn, ye}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.ProgressiveList{ye}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.ProgressiveBits{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.ProgressiveContainer{yn, yf, ya}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
        case T.CompatibleUnion{ys, yo}: Empty.absurd({False{} == True{} : Bool}, F.false_true(legal))
    case T.Null{}: Empty.absurd({CW.forest_ok(T.Null{}) == True{} : Bool}, F.false_true(legal))
    case T.Repeat{e}: Empty.absurd({CW.forest_ok(T.Repeat{e}) == True{} : Bool}, F.false_true(legal))
    case T.Named{name, inner}: Empty.absurd({CW.forest_ok(T.Named{name, inner}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveList{e}: Empty.absurd({CW.forest_ok(T.ProgressiveList{e}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveBits{}: Empty.absurd({CW.forest_ok(T.ProgressiveBits{}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveContainer{names, fields, active}: Empty.absurd({CW.forest_ok(T.ProgressiveContainer{names, fields, active}) == True{} : Bool}, F.false_true(legal))
    case T.CompatibleUnion{selectors, options}: Empty.absurd({CW.forest_ok(T.CompatibleUnion{selectors, options}) == True{} : Bool}, F.false_true(legal))

# The nested validator conditions that carry the structural facts.
law progressive_fields_valid:
  for +names: +List<String>
  for +fields: T.Schema
  for +active: +List<Bool>
  for +forest: Bool
  for +legal: {IS.valid_go(T.ProgressiveContainer{names, fields, active}, forest) == True{} : Bool}
  {IS.valid_go(fields, True{}) == True{} : Bool}
def progressive_fields_valid(names, fields, active, forest, legal):
  +rest = Bool.and(Nat.is_le(ILists.length(Bool, active), 256n), Bool.and(IS.ends_active(active, False{}), Nat.is_eq(IS.active_count(active, 0n), IS.count(fields))))
  V.and_left(IS.valid_go(fields, True{}), rest,
    V.and_right(IS.named_fields_valid(names, fields), Bool.and(IS.valid_go(fields, True{}), rest),
      V.and_right(Bool.not(forest), Bool.and(IS.named_fields_valid(names, fields), Bool.and(IS.valid_go(fields, True{}), rest)), legal)))

law compatible_options_valid:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +forest: Bool
  for +legal: {IS.valid_go(T.CompatibleUnion{selectors, options}, forest) == True{} : Bool}
  {IS.valid_go(options, True{}) == True{} : Bool}
def compatible_options_valid(selectors, options, forest, legal):
  +tail = Bool.and(IS.valid_go(options, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(options)), 1, options, options))
  V.and_left(IS.valid_go(options, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(options)), 1, options, options),
    V.and_right(IS.selectors_valid(selectors, []), tail,
      V.and_right(Nat.is_eq(ILists.length(U32, selectors), IS.count(options)), Bool.and(IS.selectors_valid(selectors, []), tail),
        V.and_right(Nat.is_lt(0n, IS.count(options)), Bool.and(Nat.is_eq(ILists.length(U32, selectors), IS.count(options)), Bool.and(IS.selectors_valid(selectors, []), tail)),
          V.and_right(Bool.not(forest), Bool.and(Nat.is_lt(0n, IS.count(options)), Bool.and(Nat.is_eq(ILists.length(U32, selectors), IS.count(options)), Bool.and(IS.selectors_valid(selectors, []), tail))), legal)))))

law from_valid:
  for +schema: T.Schema
  for +forest: Bool
  for +legal: {IS.valid_go(schema, forest) == True{} : Bool}
  {CW.legal_go(schema) == True{} : Bool}
def from_valid(schema, forest, legal):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{w}: {==}
    case T.ByteVector{m}: {==}
    case T.ByteList{m}: {==}
    case T.BitVector{m}: {==}
    case T.BitList{m}: {==}
    case T.ProgressiveBits{}: {==}
    case T.Null{}: {==}
    case T.End{}: {==}
    case T.Repeat{e}: {==}
    case T.Named{name, inner}: {==}
    case T.Vector{e, m}:
      from_valid(e, False{}, V.and_right(Nat.is_lt(0n, m), IS.valid_go(e, False{}), V.and_right(Bool.not(forest), Bool.and(Nat.is_lt(0n, m), IS.valid_go(e, False{})), legal)))
    case T.ListOf{e, m}:
      from_valid(e, False{}, V.and_right(Bool.not(forest), IS.valid_go(e, False{}), legal))
    case T.ProgressiveList{e}:
      from_valid(e, False{}, V.and_right(Bool.not(forest), IS.valid_go(e, False{}), legal))
    case T.Container{names, fields}:
      V.and_true(CW.forest_ok(fields), CW.legal_go(fields), forest_of_valid(fields, V.and_right(IS.named_fields_valid(names, fields), IS.valid_go(fields, True{}), V.and_right(Bool.not(forest), Bool.and(IS.named_fields_valid(names, fields), IS.valid_go(fields, True{})), legal))), from_valid(fields, True{}, V.and_right(IS.named_fields_valid(names, fields), IS.valid_go(fields, True{}), V.and_right(Bool.not(forest), Bool.and(IS.named_fields_valid(names, fields), IS.valid_go(fields, True{})), legal))))
    case T.ProgressiveContainer{names, fields, active}:
      V.and_true(CW.forest_ok(fields), CW.legal_go(fields), forest_of_valid(fields, progressive_fields_valid(names, fields, active, forest, legal)), from_valid(fields, True{}, progressive_fields_valid(names, fields, active, forest, legal)))
    case T.CompatibleUnion{selectors, options}:
      V.and_true(CW.forest_ok(options), CW.legal_go(options), forest_of_valid(options, compatible_options_valid(selectors, options, forest, legal)), from_valid(options, True{}, compatible_options_valid(selectors, options, forest, legal)))
    case T.Chain{hh, tt}:
      +vt = V.and_right(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), V.and_right(forest, Bool.and(IS.valid_go(hh, False{}), IS.valid_go(tt, True{})), legal))
      V.and_true(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), from_valid(hh, False{}, V.and_left(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), V.and_right(forest, Bool.and(IS.valid_go(hh, False{}), IS.valid_go(tt, True{})), legal))), V.and_true(CW.forest_ok(tt), CW.legal_go(tt), forest_of_valid(tt, vt), from_valid(tt, True{}, vt)))
    case T.Union{options}:
      match options:
        case T.Chain{oh, ot}:
          match oh:
            case T.Null{}:
              +vt = V.and_right(Nat.is_le(IS.count(ot), 127n), IS.valid_go(ot, True{}), V.and_right(Nat.is_lt(0n, IS.count(ot)), Bool.and(Nat.is_le(IS.count(ot), 127n), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_lt(0n, IS.count(ot)), Bool.and(Nat.is_le(IS.count(ot), 127n), IS.valid_go(ot, True{}))), legal)))
              V.and_true(CW.forest_ok(ot), Bool.and(True{}, Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(True{}, Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), {==}, V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Boolean{}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Boolean{}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Boolean{}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Boolean{}, False{}, V.and_left(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Unsigned{zw}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Unsigned{zw}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Unsigned{zw}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Unsigned{zw}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Unsigned{zw}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Unsigned{zw}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Unsigned{zw}, False{}, V.and_left(IS.valid_go(T.Unsigned{zw}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.ByteVector{zm}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ByteVector{zm}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ByteVector{zm}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.ByteVector{zm}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.ByteVector{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.ByteVector{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.ByteVector{zm}, False{}, V.and_left(IS.valid_go(T.ByteVector{zm}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.ByteList{zm}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ByteList{zm}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ByteList{zm}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.ByteList{zm}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.ByteList{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.ByteList{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.ByteList{zm}, False{}, V.and_left(IS.valid_go(T.ByteList{zm}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.BitVector{zm}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.BitVector{zm}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.BitVector{zm}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.BitVector{zm}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.BitVector{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.BitVector{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.BitVector{zm}, False{}, V.and_left(IS.valid_go(T.BitVector{zm}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.BitList{zm}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.BitList{zm}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.BitList{zm}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.BitList{zm}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.BitList{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.BitList{zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.BitList{zm}, False{}, V.and_left(IS.valid_go(T.BitList{zm}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Vector{ze, zm}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Vector{ze, zm}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Vector{ze, zm}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Vector{ze, zm}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Vector{ze, zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Vector{ze, zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Vector{ze, zm}, False{}, V.and_left(IS.valid_go(T.Vector{ze, zm}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.ListOf{ze, zm}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ListOf{ze, zm}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ListOf{ze, zm}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.ListOf{ze, zm}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.ListOf{ze, zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.ListOf{ze, zm}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.ListOf{ze, zm}, False{}, V.and_left(IS.valid_go(T.ListOf{ze, zm}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Container{zn, zf}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Container{zn, zf}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Container{zn, zf}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Container{zn, zf}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Container{zn, zf}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Container{zn, zf}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Container{zn, zf}, False{}, V.and_left(IS.valid_go(T.Container{zn, zf}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Union{zo}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Union{zo}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Union{zo}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Union{zo}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Union{zo}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Union{zo}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Union{zo}, False{}, V.and_left(IS.valid_go(T.Union{zo}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Chain{zh, zt}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Chain{zh, zt}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Chain{zh, zt}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Chain{zh, zt}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Chain{zh, zt}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Chain{zh, zt}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Chain{zh, zt}, False{}, V.and_left(IS.valid_go(T.Chain{zh, zt}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.End{}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.End{}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.End{}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.End{}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.End{}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.End{}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.End{}, False{}, V.and_left(IS.valid_go(T.End{}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Repeat{ze}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Repeat{ze}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Repeat{ze}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Repeat{ze}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Repeat{ze}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Repeat{ze}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Repeat{ze}, False{}, V.and_left(IS.valid_go(T.Repeat{ze}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.Named{zn, ze}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Named{zn, ze}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.Named{zn, ze}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.Named{zn, ze}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.Named{zn, ze}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.Named{zn, ze}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.Named{zn, ze}, False{}, V.and_left(IS.valid_go(T.Named{zn, ze}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.ProgressiveList{ze}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ProgressiveList{ze}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ProgressiveList{ze}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.ProgressiveList{ze}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.ProgressiveList{ze}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.ProgressiveList{ze}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.ProgressiveList{ze}, False{}, V.and_left(IS.valid_go(T.ProgressiveList{ze}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.ProgressiveBits{}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.ProgressiveBits{}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.ProgressiveBits{}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.ProgressiveBits{}, False{}, V.and_left(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.ProgressiveContainer{zn, zf, za}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ProgressiveContainer{zn, zf, za}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.ProgressiveContainer{zn, zf, za}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.ProgressiveContainer{zn, zf, za}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.ProgressiveContainer{zn, zf, za}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.ProgressiveContainer{zn, zf, za}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.ProgressiveContainer{zn, zf, za}, False{}, V.and_left(IS.valid_go(T.ProgressiveContainer{zn, zf, za}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
            case T.CompatibleUnion{zs, zo}:
              +inner = V.and_right(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.CompatibleUnion{zs, zo}, False{}), IS.valid_go(ot, True{})), V.and_right(Bool.not(forest), Bool.and(Nat.is_le(IS.count(ot), 127n), Bool.and(IS.valid_go(T.CompatibleUnion{zs, zo}, False{}), IS.valid_go(ot, True{}))), legal))
              +vt = V.and_right(IS.valid_go(T.CompatibleUnion{zs, zo}, False{}), IS.valid_go(ot, True{}), inner)
              V.and_true(CW.forest_ok(ot), Bool.and(CW.legal_go(T.CompatibleUnion{zs, zo}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot))), forest_of_valid(ot, vt), V.and_true(CW.legal_go(T.CompatibleUnion{zs, zo}), Bool.and(CW.forest_ok(ot), CW.legal_go(ot)), from_valid(T.CompatibleUnion{zs, zo}, False{}, V.and_left(IS.valid_go(T.CompatibleUnion{zs, zo}, False{}), IS.valid_go(ot, True{}), inner)), V.and_true(CW.forest_ok(ot), CW.legal_go(ot), forest_of_valid(ot, vt), from_valid(ot, True{}, vt))))
        case T.Boolean{}: Empty.absurd({CW.forest_ok(T.Boolean{}) == True{} : Bool}, F.false_true(legal))
        case T.Unsigned{yw}: Empty.absurd({CW.forest_ok(T.Unsigned{yw}) == True{} : Bool}, F.false_true(legal))
        case T.ByteVector{ym}: Empty.absurd({CW.forest_ok(T.ByteVector{ym}) == True{} : Bool}, F.false_true(legal))
        case T.ByteList{ym}: Empty.absurd({CW.forest_ok(T.ByteList{ym}) == True{} : Bool}, F.false_true(legal))
        case T.BitVector{ym}: Empty.absurd({CW.forest_ok(T.BitVector{ym}) == True{} : Bool}, F.false_true(legal))
        case T.BitList{ym}: Empty.absurd({CW.forest_ok(T.BitList{ym}) == True{} : Bool}, F.false_true(legal))
        case T.Vector{ye, ym}: Empty.absurd({CW.forest_ok(T.Vector{ye, ym}) == True{} : Bool}, F.false_true(legal))
        case T.ListOf{ye, ym}: Empty.absurd({CW.forest_ok(T.ListOf{ye, ym}) == True{} : Bool}, F.false_true(legal))
        case T.Container{yn, yf}: Empty.absurd({CW.forest_ok(T.Container{yn, yf}) == True{} : Bool}, F.false_true(legal))
        case T.Union{yo}: Empty.absurd({CW.forest_ok(T.Union{yo}) == True{} : Bool}, F.false_true(legal))
        case T.Null{}: Empty.absurd({CW.forest_ok(T.Null{}) == True{} : Bool}, F.false_true(legal))
        case T.End{}: Empty.absurd({CW.forest_ok(T.End{}) == True{} : Bool}, F.false_true(legal))
        case T.Repeat{ye}: Empty.absurd({CW.forest_ok(T.Repeat{ye}) == True{} : Bool}, F.false_true(legal))
        case T.Named{yn, ye}: Empty.absurd({CW.forest_ok(T.Named{yn, ye}) == True{} : Bool}, F.false_true(legal))
        case T.ProgressiveList{ye}: Empty.absurd({CW.forest_ok(T.ProgressiveList{ye}) == True{} : Bool}, F.false_true(legal))
        case T.ProgressiveBits{}: Empty.absurd({CW.forest_ok(T.ProgressiveBits{}) == True{} : Bool}, F.false_true(legal))
        case T.ProgressiveContainer{yn, yf, ya}: Empty.absurd({CW.forest_ok(T.ProgressiveContainer{yn, yf, ya}) == True{} : Bool}, F.false_true(legal))
        case T.CompatibleUnion{ys, yo}: Empty.absurd({CW.forest_ok(T.CompatibleUnion{ys, yo}) == True{} : Bool}, F.false_true(legal))
