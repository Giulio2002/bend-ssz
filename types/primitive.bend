import Base

# Neutral mathematical value representation, NOT serialized bytes.
# Significance is a + 2^32*b + ... + 2^224*h.
type UInt is Data:
  UInt{a: U32, b: U32, c: U32, d: U32, e: U32, f: U32, g: U32, h: U32}

type Width is Data:
  U8{}
  U16{}
  U32Width{}
  U64{}
  U128{}
  U256{}
