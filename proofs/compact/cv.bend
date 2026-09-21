import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./buf.bend as Bf
import ./bits.bend as W

# CV(fuel, cs, t, a, b): the window [a, b) of the buffer whose words are the
# slots of t is a valid encoding of the compact schema cs. It is the scanner's
# specification: stated per constructor, over the bytes in the window, with
# natural-number positions and no machine state, fuel or frames. The scanner
# (src/cscan.bend) is proved to accept exactly when CV holds; CV of a compiled
# spec schema is proved to hold exactly when the window is in the spec image.
#
# The leading fuel bounds the nesting depth, as the scanner's own fuel does:
# Bend requires a structurally shrinking argument, and container fields and
# union options are reached through `S.field`, the runtime's own index
# descent into the balanced field tree, exactly as the scanner reaches them.
# With too little fuel CV is Empty, which makes soundness statements
# (CV -> spec) hold for every fuel and completeness ones need enough of it.

# ---- bytes and offsets ------------------------------------------------------

def byte(t: F.array__Tree<U32>, +k: Nat) -> U32: Bf.at(t, k)

# The little-endian uint32 at byte k: an SSZ offset.
def off(+t: F.array__Tree<U32>, +k: Nat) -> Nat:
  U32.to_nat(W.asm(Bf.at(t, k), Bf.at(t, 1n+k), Bf.at(t, 2n+k), Bf.at(t, 3n+k)))

def within(+n: Nat, +lim: U32, big: Bool) -> Bool:
  match big:
    case True{}: True{}
    case False{}: Nat.is_le(n, U32.to_nat(lim))

def If(c: Bool, A: Type, B: Type) -> Type:
  match c:
    case True{}: A
    case False{}: B

def Is(b: Bool) -> Type: {b == True{} : Bool}

# The end of the variable field whose leaf index is `idx`: the offset of the
# next variable field of the check tree, or the container's end.
def var_end_of(m: Maybe<&2, U32>, +t: F.array__Tree<U32>, +base: Nat, +endp: Nat) -> Nat:
  match m:
    case None{}: endp
    case Some{+h}: Nat.add(base, off(t, Nat.add(base, U32.to_nat(h))))

def var_end(+t: F.array__Tree<U32>, +base: Nat, +endp: Nat, +tree: S.CS, +cnt: U32, +idx: U32) -> Nat:
  var_end_of(S.next_var(tree, (idx + 1 : U32), cnt), t, base, endp)

# The first variable field's offset is the fixed part's size.
def first_off(m: Maybe<&2, U32>, +t: F.array__Tree<U32>, +base: Nat, +fp: U32) -> Type:
  match m:
    case None{}: Unit
    case Some{+h}: {off(t, Nat.add(base, U32.to_nat(h))) == U32.to_nat(fp) : Nat}

# A bit vector's last byte has its padding bits clear.
def pad_ok(+bits: U32, +v: U32) -> Bool:
  Bool.or(U32.is_eq((bits .&. 7 : U32), 0), U32.is_eq(v, (v .&. C.low_mask((bits .&. 7 : U32)) : U32)))

# A bit list's delimiter byte and length: the last byte is non-zero and the
# bit count 8 * (len - 1) + its highest set bit is within the limit.
def bits_ok(+len: Nat, +v: U32, +lim: U32, big: Bool) -> Bool:
  Bool.and(Bool.not(U32.is_eq(v, 0)),
    within(Nat.add(Nat.mul(Nat.sub(len, 1n), 8n), U32.to_nat(C.high_bit(v))), lim, big))

def f_hoff(+f: S.CS) -> Nat: U32.to_nat(C.f_hoff(f))

def f_hsize(+f: S.CS) -> Nat: U32.to_nat(C.f_hsize(f))

def npick(c: Bool, +x: Nat, +y: Nat) -> Nat:
  match c:
    case True{}: x
    case False{}: y

# The end of element k of a variable-size sequence at [a, b) with `count`
# elements: where element k + 1 starts, or the end of the window.
def el_end(+t: F.array__Tree<U32>, +a: Nat, +b: Nat, +count: Nat, +k: Nat) -> Nat:
  npick(Nat.is_lt(1n+k, count), Nat.add(a, off(t, Nat.add(a, Nat.mul(4n, 1n+k)))), b)

# Start of element k of a variable-size sequence at a.
def el_start(+t: F.array__Tree<U32>, +a: Nat, +k: Nat) -> Nat:
  Nat.add(a, off(t, Nat.add(a, Nat.mul(4n, k))))

# Start of the variable field whose leaf is f, in a container at base.
def var_start(+t: F.array__Tree<U32>, +base: Nat, +f: S.CS) -> Nat:
  Nat.add(base, off(t, Nat.add(base, f_hoff(f))))

# ---- shapes of the composite cases -------------------------------------------
#
# Each takes the child predicate P (CV at one less fuel) as an argument, so the
# composite cases share one definition with every lemma that maps over them.

# Elements i < n of a fixed-stride sequence at a.
def VecEls(+n: Nat, +a: Nat, +stride: Nat, P: Nat -> Nat -> Type) -> Type:
  @i: Nat -> Is(Nat.is_lt(i, n)) -> P(Nat.add(a, Nat.mul(i, stride)), Nat.add(a, Nat.mul(1n+i, stride)))

# Elements k < n of a variable-size sequence at [a, b), found by offsets.
def VarEls(+t: F.array__Tree<U32>, +a: Nat, +b: Nat, +n: Nat, P: Nat -> Nat -> Type) -> Type:
  @k: Nat -> Is(Nat.is_lt(k, n)) ->
    Is(Nat.is_le(el_start(t, a, k), el_end(t, a, b, n, k))) & Is(Nat.is_le(el_end(t, a, b, n, k), b)) &
    P(el_start(t, a, k), el_end(t, a, b, n, k))

# One leaf of a container's check tree: a fixed field at its header
# position (nothing to check if its schema is plain), or a variable field
# between its offset and the next variable field's.
def LeafOk(+f: S.CS, +t: F.array__Tree<U32>, +a: Nat, +b: Nat, +checks: S.CS, +nchecks: U32, +i: U32,
    P: S.CS -> Nat -> Nat -> Type) -> Type:
  Is(C.is_leaf(f)) &
  If(C.f_fixed(f),
    If(S.is_plain(C.f_schema(f)), Unit, P(C.f_schema(f), Nat.add(a, f_hoff(f)), Nat.add(Nat.add(a, f_hoff(f)), f_hsize(f)))),
    Is(Nat.is_le(var_start(t, a, f), var_end(t, a, b, checks, nchecks, i))) &
    Is(Nat.is_le(var_end(t, a, b, checks, nchecks, i), b)) &
    P(C.f_schema(f), var_start(t, a, f), var_end(t, a, b, checks, nchecks, i)))

def Leaves(+t: F.array__Tree<U32>, +a: Nat, +b: Nat, +checks: S.CS, +nchecks: U32, P: S.CS -> Nat -> Nat -> Type) -> Type:
  @i: U32 -> Is(U32.is_lt(i, nchecks)) -> LeafOk(S.field(checks, i), t, a, b, checks, nchecks, i, P)

# A container's window: its length against the fixed part, then (unless it is
# fixed and plain) the first variable offset and every checked field.
def ContOk(+fixed: Bool, +plain: Bool, +fp: U32, +checks: S.CS, +nchecks: U32, +t: F.array__Tree<U32>, +a: Nat, +b: Nat,
    P: S.CS -> Nat -> Nat -> Type) -> Type:
  If(fixed, {Nat.sub(b, a) == U32.to_nat(fp) : Nat}, Is(Nat.is_le(U32.to_nat(fp), Nat.sub(b, a)))) &
  If(Bool.and(fixed, plain), Unit,
    first_off(S.next_var(checks, 0, nchecks), t, a, fp) & Leaves(t, a, b, checks, nchecks, P))

# ---- the specification --------------------------------------------------------

def CV(fuel: Nat, cs: S.CS, +t: F.array__Tree<U32>, +a: Nat, +b: Nat) -> Type:
  match fuel:
    case 0n: Empty
    case 1n+g:
      match cs:
        case S.CBool{}:
          {Nat.sub(b, a) == 1n : Nat} & Is(U32.is_le(Bf.at(t, a), 1))
        case S.CUint{+size}:
          {Nat.sub(b, a) == U32.to_nat(size) : Nat}
        case S.CBytes{+len, depth}:
          {Nat.sub(b, a) == U32.to_nat(len) : Nat}
        case S.CByteList{+lim, +big, depth}:
          Is(within(Nat.sub(b, a), lim, big))
        case S.CBitVec{+bits, +bytes, depth}:
          {Nat.sub(b, a) == U32.to_nat(bytes) : Nat} & Is(pad_ok(bits, Bf.at(t, Nat.sub(b, 1n))))
        case S.CBitList{+lim, +big, depth}:
          Is(Nat.is_lt(a, b)) & Is(bits_ok(Nat.sub(b, a), Bf.at(t, Nat.sub(b, 1n)), lim, big))
        case S.CVec{+elem, +count, +stride, depth, basic, +plain}:
          {Nat.sub(b, a) == Nat.mul(U32.to_nat(count), U32.to_nat(stride)) : Nat} &
          If(Bool.or(U32.is_eq(count, 0), plain), Unit,
            VecEls(U32.to_nat(count), a, U32.to_nat(stride), x => y => CV(g, elem, t, x, y)))
        case S.CVecVar{+elem, +count, depth}:
          Is(Nat.is_le(Nat.mul(4n, U32.to_nat(count)), Nat.sub(b, a))) &
          {off(t, a) == Nat.mul(4n, U32.to_nat(count)) : Nat} &
          VarEls(t, a, b, U32.to_nat(count), x => y => CV(g, elem, t, x, y))
        case S.CList{+elem, +lim, +big, +stride, depth, basic, +plain}:
          {Nat.sub(b, a) == Nat.mul(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), U32.to_nat(stride)) : Nat} &
          Is(within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big)) &
          If(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), Unit,
            VecEls(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), a, U32.to_nat(stride), x => y => CV(g, elem, t, x, y)))
        case S.CListVar{+elem, +lim, +big, depth}:
          If(Nat.is_eq(Nat.sub(b, a), 0n), Unit,
            Is(Nat.is_le(4n, off(t, a))) &
            {Nat.mod(off(t, a), 4n) == 0n : Nat} &
            Is(Nat.is_le(off(t, a), Nat.sub(b, a))) &
            Is(within(Nat.div(off(t, a), 4n), lim, big)) &
            VarEls(t, a, b, Nat.div(off(t, a), 4n), x => y => CV(g, elem, t, x, y)))
        case S.CCont{fields, cnt, +fp, size, +fixed, depth, +plain, +checks, +nchecks, simple}:
          ContOk(fixed, plain, fp, checks, nchecks, t, a, b, s => x => y => CV(g, s, t, x, y))
        case S.CPCont{fields, cnt, +fp, size, +fixed, +plain, +checks, +nchecks, slots, nslots, active}:
          ContOk(fixed, plain, fp, checks, nchecks, t, a, b, s => x => y => CV(g, s, t, x, y))
        case S.CUnion{+options, +nsel}:
          Is(Nat.is_lt(a, b)) & Is(U32.is_lt(Bf.at(t, a), nsel)) &
          Is(C.is_leaf(S.field(options, Bf.at(t, a)))) &
          CV(g, C.f_schema(S.field(options, Bf.at(t, a))), t, 1n+a, b)
        case S.CNull{}:
          {Nat.sub(b, a) == 0n : Nat}
        case _: Empty
