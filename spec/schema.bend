import Base
import ../types/schema.bend as T
import ./primitives.bend as P

# Normative fixed/variable-size classification. None means variable size.
# Chain/End denote declaration-order fields, not public SSZ types.
def sum(a: Maybe<&2, Nat>, b: Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match a b:
    case Some{x} Some{y}: Some{Nat.add(x, y)}
    case _ _: None{}

def times(n: Nat, width: Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match width:
    case None{}: None{}
    case Some{w}: Some{Nat.mul(n, w)}

def fixed_size(schema: T.Schema) -> Maybe<&2, Nat>:
  match schema:
    case T.Boolean{}: Some{1n}
    case T.Unsigned{w}: Some{P.byte_width(w)}
    case T.ByteVector{n}: Some{n}
    case T.BitVector{n}: Some{Nat.div(Nat.add(n, 7n), 8n)}
    case T.Vector{e, n}: times(n, fixed_size(e))
    case T.Container{names, fields}: fixed_size(fields)
    case T.ProgressiveContainer{names, fields, active}: fixed_size(fields)
    case T.Chain{h, t}: sum(fixed_size(h), fixed_size(t))
    case T.End{}: Some{0n}
    case T.Null{}: Some{0n}
    case _: None{}

def option(types: T.Schema, selector: Nat) -> Maybe<&2, T.Schema>:
  match types:
    case T.Chain{h, t}:
      match selector:
        case 0n: Some{h}
        case 1n+p: option(t, p)
    case _: None{}

def selected(found: Bool, value: T.Schema, rest: Maybe<&2, T.Schema>) -> Maybe<&2, T.Schema>:
  match found:
    case True{}: Some{value}
    case False{}: rest

def compatible_option(selectors: +List<U32>, types: T.Schema, +selector: U32) -> Maybe<&2, T.Schema>:
  match selectors types:
    case Con{s, ss} T.Chain{t, ts}: selected(U32.is_eq(s, selector), t, compatible_option(ss, ts, selector))
    case _ _: None{}
