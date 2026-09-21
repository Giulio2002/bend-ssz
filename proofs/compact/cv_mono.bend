import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./cv.bend as V
import ./buf.bend as Bf

# CV is monotone in its fuel: a window valid with fuel h is valid with 1 + h.
# The composite cases are mapped through the generic shapes of cv.bend.

def if_map(c: Bool, -A: Type, -B: Type, -A2: Type, -B2: Type, f: A -> A2, g: B -> B2, x: V.If(c, A, B)) -> V.If(c, A2, B2):
  match c:
    case True{}: f(x)
    case False{}: g(x)

def vecels_map(+n: Nat, +a: Nat, +stride: Nat, -P: Nat -> Nat -> Type, -Q: Nat -> Nat -> Type,
    f: @x: Nat -> @y: Nat -> P(x, y) -> Q(x, y), v: V.VecEls(n, a, stride, P)) -> V.VecEls(n, a, stride, Q):
  +i => hi => f(Nat.add(a, Nat.mul(i, stride)), Nat.add(a, Nat.mul(1n+i, stride)), v(i, hi))

def varel_map(-A: Type, -B: Type, +x: Nat, +y: Nat, -P: Nat -> Nat -> Type, -Q: Nat -> Nat -> Type,
    f: @x: Nat -> @y: Nat -> P(x, y) -> Q(x, y), v: A & B & P(x, y)) -> A & B & Q(x, y):
  (h1, rest) = v
  (h2, p) = rest
  (h1, (h2, f(x, y, p)))

def snd_map(-A: Type, -B: Type, -B2: Type, g: B -> B2, v: A & B) -> A & B2:
  (x, y) = v
  (x, g(y))

def varels_map(+t: F.array__Tree<U32>, +a: Nat, +b: Nat, +n: Nat, -P: Nat -> Nat -> Type, -Q: Nat -> Nat -> Type,
    f: @x: Nat -> @y: Nat -> P(x, y) -> Q(x, y), v: V.VarEls(t, a, b, n, P)) -> V.VarEls(t, a, b, n, Q):
  +k => hk => varel_map(V.Is(Nat.is_le(V.el_start(t, a, k), V.el_end(t, a, b, n, k))), V.Is(Nat.is_le(V.el_end(t, a, b, n, k), b)),
    V.el_start(t, a, k), V.el_end(t, a, b, n, k), P, Q, f, v(k, hk))

# The fixed/variable branches of a leaf, with the map used once per branch.
def leaf_body(c: Bool, pl: Bool, +s: S.CS, +x1: Nat, +y1: Nat, +x2: Nat, +y2: Nat, -A: Type, -B: Type,
    -P: S.CS -> Nat -> Nat -> Type, -Q: S.CS -> Nat -> Nat -> Type,
    m: @s: S.CS -> @x: Nat -> @y: Nat -> P(s, x, y) -> Q(s, x, y),
    v: V.If(c, V.If(pl, Unit, P(s, x1, y1)), A & B & P(s, x2, y2))) -> V.If(c, V.If(pl, Unit, Q(s, x1, y1)), A & B & Q(s, x2, y2)):
  match c:
    case True{}:
      match pl:
        case True{}: v
        case False{}: m(s, x1, y1, v)
    case False{}: varel_map(A, B, x2, y2, x => y => P(s, x, y), x => y => Q(s, x, y), x => y => p => m(s, x, y, p), v)

def leafok_map(+f: S.CS, +t: F.array__Tree<U32>, +a: Nat, +b: Nat, +checks: S.CS, +nchecks: U32, +i: U32,
    -P: S.CS -> Nat -> Nat -> Type, -Q: S.CS -> Nat -> Nat -> Type,
    m: @s: S.CS -> @x: Nat -> @y: Nat -> P(s, x, y) -> Q(s, x, y),
    v: V.LeafOk(f, t, a, b, checks, nchecks, i, P)) -> V.LeafOk(f, t, a, b, checks, nchecks, i, Q):
  snd_map(V.Is(C.is_leaf(f)),
    V.If(C.f_fixed(f), V.If(S.is_plain(C.f_schema(f)), Unit, P(C.f_schema(f), Nat.add(a, V.f_hoff(f)), Nat.add(Nat.add(a, V.f_hoff(f)), V.f_hsize(f)))),
      V.Is(Nat.is_le(V.var_start(t, a, f), V.var_end(t, a, b, checks, nchecks, i))) & V.Is(Nat.is_le(V.var_end(t, a, b, checks, nchecks, i), b)) & P(C.f_schema(f), V.var_start(t, a, f), V.var_end(t, a, b, checks, nchecks, i))),
    V.If(C.f_fixed(f), V.If(S.is_plain(C.f_schema(f)), Unit, Q(C.f_schema(f), Nat.add(a, V.f_hoff(f)), Nat.add(Nat.add(a, V.f_hoff(f)), V.f_hsize(f)))),
      V.Is(Nat.is_le(V.var_start(t, a, f), V.var_end(t, a, b, checks, nchecks, i))) & V.Is(Nat.is_le(V.var_end(t, a, b, checks, nchecks, i), b)) & Q(C.f_schema(f), V.var_start(t, a, f), V.var_end(t, a, b, checks, nchecks, i))),
    w => leaf_body(C.f_fixed(f), S.is_plain(C.f_schema(f)), C.f_schema(f),
      Nat.add(a, V.f_hoff(f)), Nat.add(Nat.add(a, V.f_hoff(f)), V.f_hsize(f)),
      V.var_start(t, a, f), V.var_end(t, a, b, checks, nchecks, i),
      V.Is(Nat.is_le(V.var_start(t, a, f), V.var_end(t, a, b, checks, nchecks, i))), V.Is(Nat.is_le(V.var_end(t, a, b, checks, nchecks, i), b)),
      P, Q, m, w),
    v)

def leaves_map(+t: F.array__Tree<U32>, +a: Nat, +b: Nat, +checks: S.CS, +nchecks: U32,
    -P: S.CS -> Nat -> Nat -> Type, -Q: S.CS -> Nat -> Nat -> Type,
    m: @s: S.CS -> @x: Nat -> @y: Nat -> P(s, x, y) -> Q(s, x, y),
    v: V.Leaves(t, a, b, checks, nchecks, P)) -> V.Leaves(t, a, b, checks, nchecks, Q):
  +i => hi => leafok_map(S.field(checks, i), t, a, b, checks, nchecks, i, P, Q, m, v(i, hi))

def contok_map(+fixed: Bool, +plain: Bool, +fp: U32, +checks: S.CS, +nchecks: U32, +t: F.array__Tree<U32>, +a: Nat, +b: Nat,
    -P: S.CS -> Nat -> Nat -> Type, -Q: S.CS -> Nat -> Nat -> Type,
    m: @s: S.CS -> @x: Nat -> @y: Nat -> P(s, x, y) -> Q(s, x, y),
    v: V.ContOk(fixed, plain, fp, checks, nchecks, t, a, b, P)) -> V.ContOk(fixed, plain, fp, checks, nchecks, t, a, b, Q):
  (len, rest) = v
  (len, if_map(Bool.and(fixed, plain), Unit,
    V.first_off(S.next_var(checks, 0, nchecks), t, a, fp) & V.Leaves(t, a, b, checks, nchecks, P),
    Unit, V.first_off(S.next_var(checks, 0, nchecks), t, a, fp) & V.Leaves(t, a, b, checks, nchecks, Q),
    u => u,
    w => snd_map(V.first_off(S.next_var(checks, 0, nchecks), t, a, fp), V.Leaves(t, a, b, checks, nchecks, P), V.Leaves(t, a, b, checks, nchecks, Q),
      lv => leaves_map(t, a, b, checks, nchecks, P, Q, m, lv), w),
    rest))

def lvar_map(+t: F.array__Tree<U32>, +a: Nat, +b: Nat, +lim: U32, +big: Bool, -P: Nat -> Nat -> Type, -Q: Nat -> Nat -> Type,
    f: @x: Nat -> @y: Nat -> P(x, y) -> Q(x, y),
    w: V.Is(Nat.is_le(4n, V.off(t, a))) & {Nat.mod(V.off(t, a), 4n) == 0n : Nat} & V.Is(Nat.is_le(V.off(t, a), Nat.sub(b, a))) & V.Is(V.within(Nat.div(V.off(t, a), 4n), lim, big)) & V.VarEls(t, a, b, Nat.div(V.off(t, a), 4n), P))
    -> V.Is(Nat.is_le(4n, V.off(t, a))) & {Nat.mod(V.off(t, a), 4n) == 0n : Nat} & V.Is(Nat.is_le(V.off(t, a), Nat.sub(b, a))) & V.Is(V.within(Nat.div(V.off(t, a), 4n), lim, big)) & V.VarEls(t, a, b, Nat.div(V.off(t, a), 4n), Q):
  (h1, r1) = w
  (h2, r2) = r1
  (h3, r3) = r2
  (h4, els) = r3
  (h1, (h2, (h3, (h4, varels_map(t, a, b, Nat.div(V.off(t, a), 4n), P, Q, f, els)))))

def cv_mono(+h: Nat, cs: S.CS, +t: F.array__Tree<U32>, +a: Nat, +b: Nat, x: V.CV(h, cs, t, a, b)) -> V.CV(1n+h, cs, t, a, b):
  match h:
    case 0n:
      match x:
    case 1n+g:
      match cs:
        case S.CBool{}: x
        case S.CUint{size}: x
        case S.CBytes{len, depth}: x
        case S.CByteList{lim, big, depth}: x
        case S.CBitVec{bits, bytes, depth}: x
        case S.CBitList{lim, big, depth}: x
        case S.CNull{}: x
        case S.CVec{+elem, +count, +stride, depth, basic, +plain}:
          (len, rest) = x
          (len, if_map(Bool.or(U32.is_eq(count, 0), plain),
            Unit, V.VecEls(U32.to_nat(count), a, U32.to_nat(stride), p => q => V.CV(g, elem, t, p, q)),
            Unit, V.VecEls(U32.to_nat(count), a, U32.to_nat(stride), p => q => V.CV(1n+g, elem, t, p, q)),
            u => u,
            v => vecels_map(U32.to_nat(count), a, U32.to_nat(stride), p => q => V.CV(g, elem, t, p, q), p => q => V.CV(1n+g, elem, t, p, q),
              p => q => c => cv_mono(g, elem, t, p, q, c), v),
            rest))
        case S.CVecVar{+elem, +count, depth}:
          (h1, r1) = x
          (h2, els) = r1
          (h1, (h2, varels_map(t, a, b, U32.to_nat(count), p => q => V.CV(g, elem, t, p, q), p => q => V.CV(1n+g, elem, t, p, q),
            p => q => c => cv_mono(g, elem, t, p, q, c), els)))
        case S.CList{+elem, +lim, +big, +stride, depth, basic, +plain}:
          (h1, r1) = x
          (h2, rest) = r1
          (h1, (h2, if_map(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain),
            Unit, V.VecEls(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), a, U32.to_nat(stride), p => q => V.CV(g, elem, t, p, q)),
            Unit, V.VecEls(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), a, U32.to_nat(stride), p => q => V.CV(1n+g, elem, t, p, q)),
            u => u,
            v => vecels_map(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), a, U32.to_nat(stride), p => q => V.CV(g, elem, t, p, q), p => q => V.CV(1n+g, elem, t, p, q),
              p => q => c => cv_mono(g, elem, t, p, q, c), v),
            rest)))
        case S.CListVar{+elem, +lim, +big, depth}:
          if_map(Nat.is_eq(Nat.sub(b, a), 0n),
            Unit,
            V.Is(Nat.is_le(4n, V.off(t, a))) & {Nat.mod(V.off(t, a), 4n) == 0n : Nat} & V.Is(Nat.is_le(V.off(t, a), Nat.sub(b, a))) & V.Is(V.within(Nat.div(V.off(t, a), 4n), lim, big)) & V.VarEls(t, a, b, Nat.div(V.off(t, a), 4n), p => q => V.CV(g, elem, t, p, q)),
            Unit,
            V.Is(Nat.is_le(4n, V.off(t, a))) & {Nat.mod(V.off(t, a), 4n) == 0n : Nat} & V.Is(Nat.is_le(V.off(t, a), Nat.sub(b, a))) & V.Is(V.within(Nat.div(V.off(t, a), 4n), lim, big)) & V.VarEls(t, a, b, Nat.div(V.off(t, a), 4n), p => q => V.CV(1n+g, elem, t, p, q)),
            u => u,
            w => lvar_map(t, a, b, lim, big, p => q => V.CV(g, elem, t, p, q), p => q => V.CV(1n+g, elem, t, p, q),
              p => q => c => cv_mono(g, elem, t, p, q, c), w),
            x)
        case S.CCont{fields, cnt, +fp, size, +fixed, depth, +plain, +checks, +nchecks, simple}:
          contok_map(fixed, plain, fp, checks, nchecks, t, a, b, s => p => q => V.CV(g, s, t, p, q), s => p => q => V.CV(1n+g, s, t, p, q),
            s => p => q => c => cv_mono(g, s, t, p, q, c), x)
        case S.CPCont{fields, cnt, +fp, size, +fixed, +plain, +checks, +nchecks, slots, nslots, active}:
          contok_map(fixed, plain, fp, checks, nchecks, t, a, b, s => p => q => V.CV(g, s, t, p, q), s => p => q => V.CV(1n+g, s, t, p, q),
            s => p => q => c => cv_mono(g, s, t, p, q, c), x)
        case S.CUnion{+options, +nsel}:
          (h1, r1) = x
          (h2, r2) = r1
          (h3, c) = r2
          (h1, (h2, (h3, cv_mono(g, C.f_schema(S.field(options, Bf.at(t, a))), t, 1n+a, b, c))))
        case S.CFLeaf{f, hoff, hsize, fixed}:
          match x:
        case S.CFNode{lo, hi, split}:
          match x:
        case S.CFNone{}:
          match x:
