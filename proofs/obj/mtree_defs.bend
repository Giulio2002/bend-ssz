import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O

# The reference tree and its list helpers (the definitions only; the laws
# about them are proofs/obj/mtree_spec.bend and proofs/obj/mtree_run.bend).
# `rtree(d, inside, hl, L, s)` is the root of the digests L[s .. s + 2^d)
# (digests past the end of L count as absent): Z(d) when s is past the end,
# L[s] at depth 0, and node(hl, left, right) otherwise - the same recursion as
# the runtime trees O.mtree / O.ctree and the generated `{p}_mt`.

def bytes_list(L: List<&2, D.Digest>) -> +List<+List<U32>>:
  match L:
    case Nil{}: []
    case Con{x, t}: D.bytes(x) <> bytes_list(t)

def ddrop(n: Nat, L: List<&2, D.Digest>) -> List<&2, D.Digest>:
  match n:
    case 0n: L
    case 1n+p:
      match L:
        case Nil{}: []
        case Con{x, t}: ddrop(p, t)

def dlen(L: List<&2, D.Digest>) -> Nat:
  match L:
    case Nil{}: 0n
    case Con{x, t}: 1n+dlen(t)

def dhead(L: List<&2, D.Digest>) -> D.Digest:
  match L:
    case Nil{}: D.zero()
    case Con{x, t}: x

def dtail(L: List<&2, D.Digest>) -> List<&2, D.Digest>:
  match L:
    case Nil{}: []
    case Con{x, t}: t

def rtree(+d: Nat, inside: Bool, +hl: Nat, +L: List<&2, D.Digest>, +s: Nat) -> D.Digest:
  match d:
    case 0n:
      match inside:
        case False{}: D.zconst(0n)
        case True{}: dhead(ddrop(s, L))
    case 1n+ +p:
      match inside:
        case False{}: D.zconst(1n+p)
        case True{}:
          D.node(hl, rtree(p, True{}, hl, L, s),
            rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), dlen(L)), hl, L, Nat.add(s, O.pow2n(p))))

def bool_disc(b: Bool) -> Type:
  match b:
    case True{}: Unit
    case False{}: Empty

def true_false(e: {True{} == False{} : Bool}) -> Empty:
  %e : bool_disc(_)
  Unit{}

def false_true(e: {False{} == True{} : Bool}) -> Empty:
  %Equal.sym(Bool, False{}, True{}, e) : bool_disc(_)
  Unit{}
