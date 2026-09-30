import Base
import ../../types/schema.bend as S

# The spec value of a container with one field replaced, the reference the setter
# laws are stated against (e2e/<Name>_e2e_set_generated.bend: view(set_f(o, w)) ==
# field_set(view(o), k, view_f(w)), f the k-th field). A container's value is
# S.Sequence{S.Items{v0, S.Items{v1, .. S.EmptyItems{}}}} (spec/codec.bend); field_set
# replaces the k-th item and keeps every other one. Nothing else is changed; a value
# that is not a container, or an index past its fields, is returned unchanged.

def items_set(xs: S.Value, +k: Nat, v: S.Value) -> S.Value:
  match xs:
    case S.Items{h, t}:
      match k:
        case 0n: S.Items{v, t}
        case 1n+p: S.Items{h, items_set(t, p, v)}
    case _: xs

def field_set(x: S.Value, +k: Nat, v: S.Value) -> S.Value:
  match x:
    case S.Sequence{items}: S.Sequence{items_set(items, k, v)}
    case _: x
