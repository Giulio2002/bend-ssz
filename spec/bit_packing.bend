import Base

# Bits are in increasing index order; bit i has weight 2^i.
def octet(+b0: Bool, +b1: Bool, +b2: Bool, +b3: Bool, +b4: Bool, +b5: Bool, +b6: Bool, +b7: Bool) -> U32:
  U32.add(Bool.pick(U32, b0, 1, 0), U32.add(Bool.pick(U32, b1, 2, 0), U32.add(Bool.pick(U32, b2, 4, 0), U32.add(Bool.pick(U32, b3, 8, 0), U32.add(Bool.pick(U32, b4, 16, 0), U32.add(Bool.pick(U32, b5, 32, 0), U32.add(Bool.pick(U32, b6, 64, 0), U32.add(Bool.pick(U32, b7, 128, 0), 0))))))))

def pack(bits: +List<Bool>) -> +List<U32>:
  match bits:
    case Nil{}: []
    case Con{b0, Nil{}}: octet(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}) <> []
    case Con{b0, Con{b1, Nil{}}}: octet(b0, b1, False{}, False{}, False{}, False{}, False{}, False{}) <> []
    case Con{b0, Con{b1, Con{b2, Nil{}}}}: octet(b0, b1, b2, False{}, False{}, False{}, False{}, False{}) <> []
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}: octet(b0, b1, b2, b3, False{}, False{}, False{}, False{}) <> []
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}: octet(b0, b1, b2, b3, b4, False{}, False{}, False{}) <> []
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}: octet(b0, b1, b2, b3, b4, b5, False{}, False{}) <> []
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}: octet(b0, b1, b2, b3, b4, b5, b6, False{}) <> []
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}: octet(b0, b1, b2, b3, b4, b5, b6, b7) <> pack(tail)

# Exactly ceil(n / 8): zero bytes for zero bits, then one per block of eight.
def byte_count(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n: 1n
    case 2n: 1n
    case 3n: 1n
    case 4n: 1n
    case 5n: 1n
    case 6n: 1n
    case 7n: 1n
    case 8n+p: 1n+byte_count(p)
