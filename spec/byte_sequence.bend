import Base

# Extensional equality of byte-word sequences, including unequal lengths.
# The byte-range domain is checked separately by the public SSZ decoder.
def equal(a: +List<U32>, b: +List<U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(U32.is_eq(x, y), equal(xs, ys))
    case _ _: False{}
