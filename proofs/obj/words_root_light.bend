import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/primitives.bend as SP
import ../../spec/value_domain.bend as VD
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./words_spec.bend as WS

# The definitions of words_root.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

def view(+t: F.array__Tree<U32>, +n: U32) -> +List<U32>: WS.btake(U32.to_nat(n), FX.limbs(F.array__slots(U32, t)))

def cap_at(+q: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(O.e8(Nat.add(1n+q, 0n)), F.spec_common__length(U32, F.array__slots(U32, t))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, t)), F.spec_common__pow2(dw), F.array__slots_length(U32, dw, t, pf)) :
    {Nat.is_le(O.e8(Nat.add(1n+q, 0n)), _) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(q, 0n), q, MR.add_zero(q)) :
    {Nat.is_le(O.e8(1n+_), F.spec_common__pow2(dw)) == True{} : Bool}
  cap

law pos_add:
  for +x: Nat
  for +r: Nat
  for +h1: {Nat.is_lt(0n, r) == True{} : Bool}
  {Nat.is_lt(0n, Nat.add(x, r)) == True{} : Bool}
def pos_add(x, r, h1):
  match x:
    case 0n: h1
    case 1n+y: {==}

def dom_pos(+n: Nat, +xs: +List<U32>, +pos: {Nat.is_lt(0n, n) == True{} : Bool}) -> {VD.bytevector_domain(n, xs) == SP.byte_scope(n, xs) : Bool}:
  match n:
    case 0n: Empty.absurd({VD.bytevector_domain(0n, xs) == SP.byte_scope(0n, xs) : Bool}, MD.false_true(pos))
    case 1n+p: {==}

# The view of k Bytes32 elements from element i: element j is chunk j's bytes.
def items(k: Nat, +W: List<&2, U32>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{S.BytesValue{WS.cb(W, i)}, items(q, W, 1n+i)}
