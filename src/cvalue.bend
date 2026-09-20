import Base
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./packed.bend as Packed

# Compact decoded values.
#
# This is the representation the decoder actually builds. It differs from the
# neutral `T.Value` only in how byte strings are stored: packed 32-byte chunks
# instead of one list cell per byte. Booleans, integers and bitfields keep
# their neutral representation, because they are small in every supported
# schema and reuse the existing checked leaf codecs.
#
# `to_value` materialises the neutral representation with `Packed.to_list`,
# which walks only the slice's own bytes (`Packed.slice_bytes` is the same
# byte list stated declaratively, and is what the laws quantify over).
#
# `to_value` is the view into the neutral representation: every law about the
# compact runtime is stated by composing this view with the frozen independent
# specifications, so the compact form never defines its own semantics.
type CValue is Data:
  CBool{value: Bool}
  CUint{value: Primitive.UInt}
  CBytes{value: Packed.Slice}
  CBits{value: +List<Bool>}
  CSeq{items: CValue}
  CCons{head: CValue, tail: CValue}
  CEnd{}
  CSel{selector: U32, value: CValue}
  CNull{}

# Item chains are stored in decode order reversed: the decoder prepends each
# finished child, so the head of a `CCons` chain is the *last* child decoded.
# `to_value` therefore folds a chain from its head onto an accumulator, which
# both restores the source order and keeps the conversion iterative: a
# container or list with a million children costs a million steps but constant
# conversion depth. `chain` selects the folding mode; the fold is a single
# self-recursive function because it always descends into the value.
def to_value_go(c: CValue, +chain: Bool, +acc: T.Value) -> T.Value:
  match c:
    case CBool{b}: T.BooleanValue{b}
    case CUint{v}: T.UnsignedValue{v}
    case CBytes{p}: T.BytesValue{Packed.to_list(p)}
    case CBits{bs}: T.BitsValue{bs}
    case CSeq{items}: T.Sequence{to_value_go(items, False{}, T.EmptyItems{})}
    case CCons{h, t}:
      match chain:
        case True{}: to_value_go(t, True{}, T.Items{to_value_go(h, False{}, T.EmptyItems{}), acc})
        case False{}: to_value_go(t, True{}, T.Items{to_value_go(h, False{}, T.EmptyItems{}), T.EmptyItems{}})
    case CEnd{}: acc
    case CSel{s, v}: T.Selected{s, to_value_go(v, False{}, T.EmptyItems{})}
    case CNull{}: T.NullValue{}

def to_value(c: CValue) -> T.Value:
  to_value_go(c, False{}, T.EmptyItems{})

# The same chain read in source order, used only by the laws: it is the view
# a walk's remaining children present before they have been decoded.
def items_fwd(c: CValue) -> T.Value:
  match c:
    case CCons{h, t}: T.Items{to_value(h), items_fwd(t)}
    case _: T.EmptyItems{}

def result(r: Maybe<&2, CValue>) -> Maybe<&2, T.Value>:
  match r:
    case None{}: None{}
    case Some{c}: Some{to_value(c)}
