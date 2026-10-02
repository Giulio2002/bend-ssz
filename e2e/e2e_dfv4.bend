import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/FixedTestStruct_def_generated.bend as FixedTestStruct_d
import ../types/vec_FixedTestStruct_4_def_generated.bend as vec_FixedTestStruct_4_d
import ../proofs/compact/found_generated.bend as FD
import ../proofs/obj/schema_shapes_generated.bend as SH
import ../proofs/obj/root_gnames_light_generated.bend as RN
import ../proofs/obj/root_gtypes_light_generated.bend as RT
import ../proofs/obj/vfx_v4_FixedTestStruct_generated.bend as VX
import ../proofs/obj/vfx_u8_generated.bend as L2
import ../proofs/obj/vua.bend as VUA
import ../proofs/obj/vbrt.bend as VRA
import ../proofs/obj/spec_fixed.bend as FXA
import ./e2e_dpl_generated.bend as DPA
import ./e2e_encvd_generated.bend as EV

# A decoded Vector[FixedTestStruct, 4] (vfx_v4_FixedTestStruct.OBJ at the byte position x): its four records are copies of the input's
# bytes (the first field a byte, below 256), the array the four writes build is the thaw of the tree of the four records, perfect at depth 2.
# These are the root laws' representation invariant (rep_v4_FixedTestStruct) and the encode premise sv4, for every tree, depth and position.

def u8lt(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat) -> {U32.is_lt(L2.OBJ(d, t, x), 256) == True{} : Bool}:
  DPA.nthb_lt(VUA.BYT(t), x, FXA.domain_limbs(VRA.SL(t)))

def el_rp(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat) -> RN.rp_FixedTestStruct(VX.EO(d, t, x)):
  u8lt(d, t, x)

def FTt(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat) -> FD.array__Tree<FixedTestStruct_d.FixedTestStruct>:
  FD.TNode{FD.TNode{FD.TLeaf{VX.EO(d, t, Nat.add(0n, x))}, FD.TLeaf{VX.EO(d, t, Nat.add(13n, x))}}, FD.TNode{FD.TLeaf{VX.EO(d, t, Nat.add(26n, x))}, FD.TLeaf{VX.EO(d, t, Nat.add(39n, x))}}}

def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +s: S.Schema, +hl: {Nat.is_eq(4n, SH.Vector_length(s)) == True{} : Bool})
    -> RT.rep_v4_FixedTestStruct(VX.OBJ(d, t, x), s):
  ((FTt(d, t, x), (2n, (4, ({==}, ({==}, ({==}, ({==}, (el_rp(d, t, Nat.add(0n, x)), (el_rp(d, t, Nat.add(13n, x)), (el_rp(d, t, Nat.add(26n, x)), (el_rp(d, t, Nat.add(39n, x)), {==}))))))))))), hl)

def sv(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +K: Nat, +hK: {Nat.is_lt(2n, K) == True{} : Bool}) -> EV.sv4(VX.OBJ(d, t, x), K):
  FD.logic__subst(Nat, z => {Nat.is_lt(2n, z) == True{} : Bool}, K, K, {==}, hK)
