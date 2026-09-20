import Base
import ../types/schema.bend as T
import ../src/cvalue.bend as C
import ../src/decode.bend as D

# Reading an item chain newest-first is reading its reversal oldest-first.
#
# The decoder prepends each finished child, so a completed walk holds its
# children in reverse source order and `C.to_value` folds them back. The walk
# laws instead speak of `C.items_fwd`, the source-order reading of the
# children a walk still has to produce. These two laws connect the views: once
# every child has been prepended, the fold yields exactly the source-order
# reading.

# With at least one child already accumulated, folding the whole chain is
# folding the accumulator onto the source-order reading of the rest.
law fold_prepended:
  for +remaining: C.CValue
  for +head: C.CValue
  for +acc: C.CValue
  {C.to_value(D.reverse_items(remaining, C.CCons{head, acc})) == C.to_value_go(C.CCons{head, acc}, True{}, C.items_fwd(remaining)) : T.Value}
def fold_prepended(remaining, head, acc):
  match remaining:
    case C.CCons{h, t}: fold_prepended(t, h, C.CCons{head, acc})
    case C.CEnd{}: {==}
    case C.CBool{b}: {==}
    case C.CUint{v}: {==}
    case C.CBytes{p}: {==}
    case C.CBits{bs}: {==}
    case C.CSeq{items}: {==}
    case C.CSel{s, v}: {==}
    case C.CNull{}: {==}

# Nothing accumulated yet: the walk's view of its remaining children is the
# value the decoder will return once it has prepended all of them.
law fold_reversal:
  for +remaining: C.CValue
  {C.to_value(D.reverse_items(remaining, C.CEnd{})) == C.items_fwd(remaining) : T.Value}
def fold_reversal(remaining):
  match remaining:
    case C.CCons{h, t}: fold_prepended(t, h, C.CEnd{})
    case C.CEnd{}: {==}
    case C.CBool{b}: {==}
    case C.CUint{v}: {==}
    case C.CBytes{p}: {==}
    case C.CBits{bs}: {==}
    case C.CSeq{items}: {==}
    case C.CSel{s, v}: {==}
    case C.CNull{}: {==}
