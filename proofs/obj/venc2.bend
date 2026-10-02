import Base
import ../compact/found_generated.bend as F
import ./vbuf.bend as VB
import ./vfix.bend as VF

# Windows of the slots of a tree after a run of word writes (VF.updv): a
# window before or after the run is that of the tree before (peel_lo,
# peel_hi); the run's own window is the written words (own).

def peel_lo(+V: List<&2, U32>, +dd: Nat, +D: F.array__Tree<U32>, +j: Nat, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(F.spec_common__length(U32, V), j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(VF.slen(V), j), p) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VF.updv(V, dd, D, j))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VF.updv(V, dd, D, j)), VF.lmv(V, j, F.array__slots(U32, D)), VF.slots_updv(V, dd, D, j, pf, hb)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lmv_lo(V, j, m, p, F.array__slots(U32, D), h)

def peel_hi(+V: List<&2, U32>, +dd: Nat, +D: F.array__Tree<U32>, +j: Nat, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(F.spec_common__length(U32, V), j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VF.updv(V, dd, D, j))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VF.updv(V, dd, D, j)), VF.lmv(V, j, F.array__slots(U32, D)), VF.slots_updv(V, dd, D, j, pf, hb)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lmv_hi(V, j, m, p, F.array__slots(U32, D), h)

def own(+V: List<&2, U32>, +dd: Nat, +D: F.array__Tree<U32>, +j: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(F.spec_common__length(U32, V), j), VB.pw(dd)) == True{} : Bool})
    -> {VF.WIN(VF.slen(V), j, F.array__slots(U32, VF.updv(V, dd, D, j))) == V : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VF.updv(V, dd, D, j)), VF.lmv(V, j, F.array__slots(U32, D)), VF.slots_updv(V, dd, D, j, pf, hb)) :
    {VF.WIN(VF.slen(V), j, _) == V : List<&2, U32>}
  VF.lmv_own(V, j, F.array__slots(U32, D),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VF.slen(V), j), z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, D)),
      Equal.sym(Nat, VB.len(F.array__slots(U32, D)), VB.pw(dd), F.array__slots_length(U32, dd, D, pf)), hb))
