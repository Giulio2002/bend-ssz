import Base
import ../types/primitive.bend as T

# Independent transcription: SSZ Serialization / boolean.
def boolean_encoding(b: Bool) -> +List<U32>:
  match b:
    case False{}: [0]
    case True{}: [1]

def choose_boolean(is_zero: Bool, is_one: Bool) -> Maybe<&2, Bool>:
  match is_zero:
    case True{}: Some{False{}}
    case False{}:
      match is_one:
        case False{}: None{}
        case True{}: Some{True{}}

# The only legal encodings are a SINGLE byte 0 or 1.
def boolean_decoding(data: +List<U32>) -> Maybe<&2, Bool>:
  match data:
    case Nil{}: None{}
    case Con{+byte, rest}:
      match rest:
        case Nil{}: choose_boolean(U32.is_eq(byte, 0), U32.is_eq(byte, 1))
        case Con{extra, tail}: None{}

def zero_bytes(n: Nat) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p: 0 <> zero_bytes(p)

# pack right pads a basic value to a single chunk; merkleize([chunk]) = chunk.
def boolean_hash_tree_root(b: Bool) -> +List<U32>:
  List.append(&2, U32, boolean_encoding(b), zero_bytes(31n))

def byte_width(w: T.Width) -> Nat:
  match w:
    case T.U8{}: 1n
    case T.U16{}: 2n
    case T.U32Width{}: 4n
    case T.U64{}: 8n
    case T.U128{}: 16n
    case T.U256{}: 32n

# Arithmetic little-endian digits, independent of the runtime's masks/shifts.
def limb_digits(+x: U32) -> +List<U32>:
  [U32.mod(x, 256), U32.mod(U32.div(x, 256), 256),
   U32.mod(U32.div(x, 65536), 256), U32.div(x, 16777216)]

def full_digits(v: T.UInt) -> +List<U32>:
  T.UInt{a, b, c, d, e, f, g, h} = v
  List.append(&2, U32, limb_digits(a),
    List.append(&2, U32, limb_digits(b),
      List.append(&2, U32, limb_digits(c),
        List.append(&2, U32, limb_digits(d),
          List.append(&2, U32, limb_digits(e),
            List.append(&2, U32, limb_digits(f),
              List.append(&2, U32, limb_digits(g), limb_digits(h))))))))

def zero_suffix(xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, t}: Bool.and(U32.is_eq(h, 0), zero_suffix(t))

def fits(n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n: zero_suffix(xs)
    case 1n+p:
      match xs:
        case Nil{}: False{}
        case Con{h, t}: fits(p, t)

# Numeric domain: 0 <= value < 256^byte_width, via zero high digits.
def uint_domain(w: T.Width, v: T.UInt) -> Bool:
  fits(byte_width(w), full_digits(v))

def prefix(n: Nat, xs: +List<U32>) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{h, t}: h <> prefix(p, t)

def optional(ok: Bool, value: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{value}

def uint_encoding(+w: T.Width, +v: T.UInt) -> Maybe<&2, +List<U32>>:
  optional(uint_domain(w, v), prefix(byte_width(w), full_digits(v)))

# Exact scope AND byte domain, required even though the host calls them bytes.
def byte_scope(n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n:
      match xs:
        case Nil{}: True{}
        case Con{h, t}: False{}
    case 1n+p:
      match xs:
        case Nil{}: False{}
        case Con{h, t}: Bool.and(U32.is_lt(h, 256), byte_scope(p, t))

def default_byte(x: Maybe<&2, U32>) -> U32:
  match x:
    case None{}: 0
    case Some{v}: v

def byte_at(xs: +List<U32>, n: Nat) -> U32:
  default_byte(List.get(&2, U32, xs, n))

def limb_value(+xs: +List<U32>, +n: Nat) -> U32:
  U32.add(byte_at(xs, n), U32.add(U32.mul(256, byte_at(xs, 1n+n)),
    U32.add(U32.mul(65536, byte_at(xs, 2n+n)), U32.mul(16777216, byte_at(xs, 3n+n)))))

def integer_value(+xs: +List<U32>) -> T.UInt:
  T.UInt{limb_value(xs, 0n), limb_value(xs, 4n), limb_value(xs, 8n), limb_value(xs, 12n),
    limb_value(xs, 16n), limb_value(xs, 20n), limb_value(xs, 24n), limb_value(xs, 28n)}

def optional_integer(ok: Bool, xs: +List<U32>) -> Maybe<&2, T.UInt>:
  match ok:
    case False{}: None{}
    case True{}: Some{integer_value(xs)}

def uint_decoding(w: T.Width, +xs: +List<U32>) -> Maybe<&2, T.UInt>:
  optional_integer(byte_scope(byte_width(w), xs), xs)

def uint_hash_tree_root(+w: T.Width, +v: T.UInt) -> Maybe<&2, +List<U32>>:
  optional(uint_domain(w, v), List.append(&2, U32,
    prefix(byte_width(w), full_digits(v)), zero_bytes(Nat.sub(32n, byte_width(w)))))

# Byte-domain predicate independent of sequence length.
def bytes_domain(xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, t}: Bool.and(U32.is_lt(h, 256), bytes_domain(t))

# Compositional right-padding rule (independent of any implementation encoder).
def pad_encoding(zero_count: Nat, r: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match r:
    case None{}: None{}
    case Some{xs}: Some{List.append(&2, U32, xs, zero_bytes(zero_count))}
