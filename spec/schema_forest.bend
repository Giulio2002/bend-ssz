import Base
import ../types/schema.bend as T

# Representation invariants only, weaker than normative SSZ type legality.
def finite(schema: T.Schema) -> Bool:
  match schema:
    case T.End{}: True{}
    case T.Chain{head, tail}: finite(tail)
    case _: False{}

def well_formed(schema: T.Schema) -> Bool:
  match schema:
    case T.Vector{e, n}: well_formed(e)
    case T.ListOf{e, n}: well_formed(e)
    case T.ProgressiveList{e}: well_formed(e)
    case T.Repeat{e}: well_formed(e)
    case T.Named{name, e}: well_formed(e)
    case T.Container{names, +fields}: Bool.and(finite(fields), well_formed(fields))
    case T.ProgressiveContainer{names, +fields, active}: Bool.and(finite(fields), well_formed(fields))
    case T.Union{+options}: Bool.and(finite(options), well_formed(options))
    case T.CompatibleUnion{selectors, +options}: Bool.and(finite(options), well_formed(options))
    case T.Chain{h, +t}: Bool.and(well_formed(h), Bool.and(finite(t), well_formed(t)))
    case _: True{}
