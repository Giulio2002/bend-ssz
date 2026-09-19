import Base
import ../types/primitive.bend as T

def width(w: T.Width) -> Nat:
  match w:
    case T.U8{}: 1n
    case T.U16{}: 2n
    case T.U32Width{}: 4n
    case T.U64{}: 8n
    case T.U128{}: 16n
    case T.U256{}: 32n

def zeros(n: Nat) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p: 0 <> zeros(p)

def boolean_serialize(b: Bool) -> +List<U32>:
  [Bool.to_u32(b)]

def boolean_decode_byte(z: Bool, o: Bool) -> Maybe<&2, Bool>:
  match z:
    case True{}: Some{False{}}
    case False{}:
      match o:
        case True{}: Some{True{}}
        case False{}: None{}

def boolean_deserialize(xs: +List<U32>) -> Maybe<&2, Bool>:
  match xs:
    case Nil{}: None{}
    case Con{+h, t}:
      match t:
        case Nil{}: boolean_decode_byte(U32.is_eq(h, 0), U32.is_eq(h, 1))
        case Con{x, rest}: None{}

def boolean_root(b: Bool) -> +List<U32>:
  Bool.to_u32(b) <> zeros(31n)

# Exactly four little-endian bytes for each 32-bit limb.
def limb(+x: U32) -> +List<U32>:
  [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255),
   U32.and(U32.shrn(x, 16n), 255), U32.shrn(x, 24n)]

def uint_bytes(v: T.UInt) -> +List<U32>:
  T.UInt{a, b, c, d, e, f, g, h} = v
  List.append(&2, U32, limb(a),
    List.append(&2, U32, limb(b),
      List.append(&2, U32, limb(c),
        List.append(&2, U32, limb(d),
          List.append(&2, U32, limb(e),
            List.append(&2, U32, limb(f),
              List.append(&2, U32, limb(g), limb(h))))))))

def all_zero(xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, t}: Bool.and(U32.is_eq(h, 0), all_zero(t))

def accept_bytes(ok: Bool, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case True{}: Some{xs}
    case False{}: None{}

def prepend(h: U32, rest: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match rest:
    case None{}: None{}
    case Some{t}: Some{h <> t}

# Reject overflow rather than truncating the mathematical integer.
def narrow(n: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match n:
    case 0n: accept_bytes(all_zero(xs), [])
    case 1n+p:
      match xs:
        case Nil{}: None{}
        case Con{h, t}: prepend(h, narrow(p, t))

def uint_serialize(w: T.Width, v: T.UInt) -> Maybe<&2, +List<U32>>:
  narrow(width(w), uint_bytes(v))

def is_some(xs: Maybe<&2, +List<U32>>) -> Bool:
  match xs:
    case None{}: False{}
    case Some{v}: True{}

def uint_valid(w: T.Width, v: T.UInt) -> Bool:
  is_some(uint_serialize(w, v))

def valid_bytes(n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n:
      match xs:
        case Nil{}: True{}
        case Con{h, t}: False{}
    case 1n+p:
      match xs:
        case Nil{}: False{}
        case Con{h, t}: Bool.and(U32.is_lt(h, 256), valid_bytes(p, t))

def or_zero(x: Maybe<&2, U32>) -> U32:
  match x:
    case None{}: 0
    case Some{v}: v

def at(xs: +List<U32>, n: Nat) -> U32:
  or_zero(List.get(&2, U32, xs, n))

def read_limb(+xs: +List<U32>, +n: Nat) -> U32:
  U32.or(at(xs, n), U32.or(U32.shln(at(xs, 1n+n), 8n),
    U32.or(U32.shln(at(xs, 2n+n), 16n), U32.shln(at(xs, 3n+n), 24n))))

def decoded(+xs: +List<U32>) -> T.UInt:
  T.UInt{read_limb(xs, 0n), read_limb(xs, 4n), read_limb(xs, 8n), read_limb(xs, 12n),
    read_limb(xs, 16n), read_limb(xs, 20n), read_limb(xs, 24n), read_limb(xs, 28n)}

def decode_checked(ok: Bool, xs: +List<U32>) -> Maybe<&2, T.UInt>:
  match ok:
    case False{}: None{}
    case True{}: Some{decoded(xs)}

def uint_deserialize(w: T.Width, +xs: +List<U32>) -> Maybe<&2, T.UInt>:
  decode_checked(valid_bytes(width(w), xs), xs)

def pad(n: Nat, xs: +List<U32>) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p:
      match xs:
        case Nil{}: 0 <> pad(p, [])
        case Con{h, t}: h <> pad(p, t)

def root_checked(xs: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match xs:
    case None{}: None{}
    case Some{bs}: Some{pad(32n, bs)}

def uint_root(w: T.Width, v: T.UInt) -> Maybe<&2, +List<U32>>:
  root_checked(uint_serialize(w, v))

# Constructor bridge for hosts: do not guess compiled enum constructor tags.
def width8() -> T.Width: T.U8{}
def width16() -> T.Width: T.U16{}
def width32() -> T.Width: T.U32Width{}
def width64() -> T.Width: T.U64{}
def width128() -> T.Width: T.U128{}
def width256() -> T.Width: T.U256{}
def make_uint(a: U32, b: U32, c: U32, d: U32, e: U32, f: U32, g: U32, h: U32) -> T.UInt:
  T.UInt{a, b, c, d, e, f, g, h}
