import Base
import ../types/primitive.bend as Primitive


# Little-endian reads of the first bytes of a cursor.
def limb(+a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  U32.or(a, U32.or(U32.shln(b, 8n), U32.or(U32.shln(c, 16n), U32.shln(d, 24n))))
