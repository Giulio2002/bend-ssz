import Base
import ../types/primitive.bend as Primitive

# Allocation-free walks over the linked byte input.
#
# Under the JavaScript backend every tail call allocates a trampoline record
# and every Nat step allocates a BigInt. Byte-granular loops therefore use
# direct (non-tail) recursion with a U32 step counter, which compiles to plain
# calls and integer operations. Runs are at most 4096 steps, so JS stack depth
# stays bounded; longer walks are sequences of runs.
def run_skip(xs: +List<U32>, stop: Bool, +i: U32, +n: U32) -> +List<U32>:
  match xs:
    case Nil{}: []
    case Con{h, t}:
      match stop:
        case True{}: xs
        case False{}:
          r = run_skip(t, U32.is_eq(U32.inc(i), n), U32.inc(i), n)
          r

def run_copy(xs: +List<U32>, stop: Bool, +i: U32, +n: U32, tail: +List<U32>) -> +List<U32>:
  match xs:
    case Nil{}: tail
    case Con{h, t}:
      match stop:
        case True{}: tail
        case False{}: h <> run_copy(t, U32.is_eq(U32.inc(i), n), U32.inc(i), n, tail)

# Short walks (n <= 4096): start a run of exactly n steps.
def skip_short(+n: Nat, xs: +List<U32>) -> +List<U32>:
  run_skip(xs, Nat.is_lt(n, 1n), 0, U32.from_nat(n))

def copy_short(+n: Nat, xs: +List<U32>, tail: +List<U32>) -> +List<U32>:
  run_copy(xs, Nat.is_lt(n, 1n), 0, U32.from_nat(n), tail)

def skip_blocks(k: Nat, xs: +List<U32>) -> +List<U32>:
  match k:
    case 0n: xs
    case 1n+p: skip_blocks(p, run_skip(xs, False{}, 0, 4096))

# drop(n, xs), in runs of 4096.
def skip(+n: Nat, xs: +List<U32>) -> +List<U32>:
  skip_short(Nat.mod(n, 4096n), skip_blocks(Nat.div(n, 4096n), xs))

# take(k * 4096 + r, xs) ++ tail. The later blocks are built first, so the
# nesting depth is the block count plus one run.
def copy_blocks(k: Nat, +r: Nat, +xs: +List<U32>, tail: +List<U32>) -> +List<U32>:
  match k:
    case 0n: copy_short(r, xs, tail)
    case 1n+p: run_copy(xs, False{}, 0, 4096, copy_blocks(p, r, run_skip(xs, False{}, 0, 4096), tail))

def copy_super(k: Nat, +r: Nat, +xs: +List<U32>) -> +List<U32>:
  match k:
    case 0n: copy_blocks(Nat.div(r, 4096n), Nat.mod(r, 4096n), xs, [])
    case 1n+p: copy_blocks(4096n, 0n, xs, copy_super(p, r, skip_blocks(4096n, xs)))

# take(n, xs). `short` selects the single-run form (n <= 4096).
def copy(short: Bool, +n: Nat, +xs: +List<U32>) -> +List<U32>:
  match short:
    case True{}: copy_short(n, xs, [])
    case False{}: copy_super(Nat.div(n, 16777216n), Nat.mod(n, 16777216n), xs)

# Whole-input measurement: length and byte domain in one pass. The input is
# its own structural counter (one element per 4096-byte run), so the walk is
# structurally terminating without first computing a length.
type Scan is Data:
  Scan{rest: +List<U32>, count: U32, domain: Bool}

type Measure is Data:
  Measure{length: Nat, domain: Bool}

def run_scan(xs: +List<U32>, stop: Bool, +i: U32, ok: Bool) -> Scan:
  match xs:
    case Nil{}: Scan{[], i, ok}
    case Con{h, t}:
      match stop:
        case True{}: Scan{xs, i, ok}
        case False{}:
          r = run_scan(t, U32.is_eq(U32.inc(i), 4096), U32.inc(i), Bool.and(ok, U32.is_lt(h, 256)))
          r

def scan_all(counter: +List<U32>, s: Scan, +length: Nat) -> Measure:
  match counter:
    case Nil{}: Measure{length, False{}}
    case Con{c, more}:
      match s:
        case Scan{rest, count, ok}:
          match rest:
            case Nil{}: Measure{Nat.add(length, U32.to_nat(count)), ok}
            case Con{x, t}: scan_all(more, run_scan(rest, False{}, 0, ok), Nat.add(length, U32.to_nat(count)))

def measure(+xs: +List<U32>) -> Measure:
  match xs:
    case Nil{}: Measure{0n, True{}}
    case Con{h, t}: scan_all(xs, run_scan(xs, False{}, 0, True{}), 0n)

# Little-endian reads of the first bytes of a cursor.
def limb(+a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  U32.or(a, U32.or(U32.shln(b, 8n), U32.or(U32.shln(c, 16n), U32.shln(d, 24n))))

def offset(xs: +List<U32>) -> Nat:
  match xs:
    case Con{a, Con{b, Con{c, Con{d, t}}}}: U32.to_nat(limb(a, b, c, d))
    case _: 0n

def width32(w: Primitive.Width) -> U32:
  match w:
    case Primitive.U8{}: 1
    case Primitive.U16{}: 2
    case Primitive.U32Width{}: 4
    case Primitive.U64{}: 8
    case Primitive.U128{}: 16
    case Primitive.U256{}: 32

def word(w: Primitive.Width, xs: +List<U32>) -> Primitive.UInt:
  match w:
    case Primitive.U8{}:
      match xs:
        case Con{a, t}: Primitive.UInt{limb(a, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0)}
        case _: Primitive.UInt{0, 0, 0, 0, 0, 0, 0, 0}
    case Primitive.U16{}:
      match xs:
        case Con{a, Con{b, t}}: Primitive.UInt{limb(a, b, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0)}
        case _: Primitive.UInt{0, 0, 0, 0, 0, 0, 0, 0}
    case Primitive.U32Width{}:
      match xs:
        case Con{a, Con{b, Con{c, Con{d, t}}}}: Primitive.UInt{limb(a, b, c, d), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0)}
        case _: Primitive.UInt{0, 0, 0, 0, 0, 0, 0, 0}
    case Primitive.U64{}:
      match xs:
        case Con{a, Con{b, Con{c, Con{d, Con{e, Con{f, Con{g, Con{h, t}}}}}}}}: Primitive.UInt{limb(a, b, c, d), limb(e, f, g, h), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0)}
        case _: Primitive.UInt{0, 0, 0, 0, 0, 0, 0, 0}
    case Primitive.U128{}:
      match xs:
        case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, t}}}}}}}}}}}}}}}}: Primitive.UInt{limb(b0, b1, b2, b3), limb(b4, b5, b6, b7), limb(b8, b9, b10, b11), limb(b12, b13, b14, b15), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0), limb(0, 0, 0, 0)}
        case _: Primitive.UInt{0, 0, 0, 0, 0, 0, 0, 0}
    case Primitive.U256{}:
      match xs:
        case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Primitive.UInt{limb(b0, b1, b2, b3), limb(b4, b5, b6, b7), limb(b8, b9, b10, b11), limb(b12, b13, b14, b15), limb(b16, b17, b18, b19), limb(b20, b21, b22, b23), limb(b24, b25, b26, b27), limb(b28, b29, b30, b31)}
        case _: Primitive.UInt{0, 0, 0, 0, 0, 0, 0, 0}
