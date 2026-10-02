import Base
import ../compact/found_generated.bend as F

# Element reads of a perfect array tree of Data-kind elements (for the generated
# per-list tree laws in proofs/obj/root_types_generated.bend).

def lt_len(-A: Data, +dw: Nat, +t: F.array__Tree<A>, +s: Nat, +pf: {F.array__perfect(A, dw, t) == True{} : Bool},
    +hs: {Nat.is_lt(s, F.spec_common__pow2(dw)) == True{} : Bool}) -> {Nat.is_lt(s, F.spec_common__length(A, F.array__slots(A, t))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(A, F.array__slots(A, t)), F.spec_common__pow2(dw), F.array__slots_length(A, dw, t, pf)) : {Nat.is_lt(s, _) == True{} : Bool}
  hs

def at_nth(-A: Data, +W: List<&2, A>, +s: Nat, +j: Nat, +x: A, +e: {j == s : Nat}, +h: {F.spec_common__nth(A, W, s) == Some{x} : Maybe<&2, A>})
    -> {F.spec_common__nth(A, W, j) == Some{x} : Maybe<&2, A>}:
  %Equal.sym(Nat, j, s, e) : {F.spec_common__nth(A, W, _) == Some{x} : Maybe<&2, A>}
  h
