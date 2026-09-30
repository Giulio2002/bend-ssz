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

# The spec value of a list that grows by one element at the end: items_snoc / seq_append (a value that is not a Sequence is
# returned unchanged), the reference the append laws are stated against.
def items_snoc(xs: S.Value, e: S.Value) -> S.Value:
  match xs:
    case S.Items{h, t}: S.Items{h, items_snoc(t, e)}
    case _: S.Items{e, S.EmptyItems{}}

def seq_append(x: S.Value, e: S.Value) -> S.Value:
  match x:
    case S.Sequence{items}: S.Sequence{items_snoc(items, e)}
    case _: x

# The bytes of a byte sequence with byte k replaced (no change past its end): list_set / bytes_set, the reference of the
# byte collections' setters.
def list_set(xs: +List<U32>, +k: Nat, v: U32) -> +List<U32>:
  match xs:
    case Nil{}: []
    case Con{h, t}:
      match k:
        case 0n: Con{v, t}
        case 1n+p: Con{h, list_set(t, p, v)}

def bytes_set(x: S.Value, +k: Nat, v: U32) -> S.Value:
  match x:
    case S.BytesValue{bs}: S.BytesValue{list_set(bs, k, v)}
    case _: x
