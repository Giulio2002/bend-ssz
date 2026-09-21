import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./reads.bend as Rd
import ./cvm.bend as V

# M is monotone in its level: what holds at h holds at 1 + h.

def if_map(c: Bool, -A: Type, -B: Type, -A2: Type, -B2: Type, f: A -> A2, g: B -> B2, x: V.If(c, A, B)) -> V.If(c, A2, B2):
  match c:
    case True{}: f(x)
    case False{}: g(x)

def both(-A: Type, -B: Type, -A2: Type, -B2: Type, f: A -> A2, g: B -> B2, x: A & B) -> A2 & B2:
  (p, q) = x
  (f(p), g(q))

def snd_map(-A: Type, -B: Type, -B2: Type, g: B -> B2, x: A & B) -> A & B2:
  (p, q) = x
  (p, g(q))

def shallow_map(+r: U32, -A: Type, -A2: Type, f: A -> A2, x: V.Shallow(r, A)) -> V.Shallow(r, A2):
  if_map(U32.is_eq(r, 0), A, V.If(U32.is_eq(r, 1), Unit, Empty), A2, V.If(U32.is_eq(r, 1), Unit, Empty), f, y => y, x)

def varstep_map(last: Bool, +child: U32, +cend: U32, +endp: U32, -A: Type, -B: Type, -R: Type, -A2: Type, -B2: Type, -R2: Type,
    fa: A -> A2, fb: B -> B2, fr: R -> R2, x: V.VarStep(last, child, cend, endp, A, B, R)) -> V.VarStep(last, child, cend, endp, A2, B2, R2):
  match last:
    case True{}: both(A, R, A2, R2, fa, fr, x)
    case False{}: snd_map(V.Is(C.bsel(U32.is_ge(cend, child), U32.is_le(cend, endp), False{})), B & R, B2 & R2, y => both(B, R, B2, R2, fb, fr, y), x)

# At level 0 only the finished loops hold; they hold at every level.
def zero_rep(+t: F.array__Tree<U32>, +d: Nat, +elem: S.CS, c: Bool, +off: U32, +stride: U32, +left: U32,
    e: {U32.is_eq(left, 0) == c : Bool}, x: V.If(c, Unit, Empty)) -> V.M(t, d, 1n, V.Rep{elem, left, off, stride}):
  match c:
    case True{}:
      %Equal.sym(Bool, U32.is_eq(left, 0), True{}, e) : {V.If(_, Unit, V.M(t, d, 0n, V.Node{elem, off, (off + stride : U32)}) & V.M(t, d, 0n, V.Rep{elem, (left - 1 : U32), (off + stride : U32), stride})) : Type}
      x
    case False{}:
      match x:

def zero_vel(+t: F.array__Tree<U32>, +d: Nat, +elem: S.CS, c: Bool, +i: U32, +n: U32, +base: U32, +endp: U32,
    e: {U32.is_eq(i, n) == c : Bool}, x: V.If(c, Unit, Empty)) -> V.M(t, d, 1n, V.VEl{elem, i, n, base, endp}):
  match c:
    case True{}:
      %Equal.sym(Bool, U32.is_eq(i, n), True{}, e) : {V.If(_, Unit,
        V.Is(C.bsel(U32.is_le(V.el_at(t, d, base, i), endp), U32.is_ge(V.el_at(t, d, base, i), base), False{})) &
        V.VarStep(U32.is_eq((i + 1 : U32), n), V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32)), endp,
          V.M(t, d, 0n, V.Node{elem, V.el_at(t, d, base, i), endp}),
          V.M(t, d, 0n, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32))}),
          V.M(t, d, 0n, V.VEl{elem, (i + 1 : U32), n, base, endp}))) : Type}
      x
    case False{}:
      match x:
