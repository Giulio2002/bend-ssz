import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/limits.bend as Lim
import ../compact/found_generated.bend as F
import ./words_spec.bend as WS
import ./words_root_light.bend as WR_L
import ./words_obj_light.bend as WO_L
import ./schema_shapes_generated.bend as SH
import ./dk.bend as DK

# The definitions of pv_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

def pview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{WR_L.items(O.chunks_of(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)}

# The representation invariant: a perfect word tree with room for 1 + q whole chunks.
def wfv(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N => DK.Ex(Nat, q =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat},
          {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool}))))))))

# The object represents a value of the vector schema s: it holds one chunk per element.
def rep_pv(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfv(o), {Nat.is_eq(O.chunks_of(WO_L.len(o)), SH.Vector_length(s)) == True{} : Bool})

# The schema is a vector of Bytes32 whose length has minimal depth `depth`.
def ok_pv(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))))

def k_len1(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ks: {Nat.is_eq(O.chunks_of(WO_L.len(o)), K) == True{} : Bool}) -> {Nat.is_eq(O.chunks_of(N), K) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO_L.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(O.chunks_of(_), K) == True{} : Bool}
  ks

def k_len(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +q: Nat, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat},
    +ks: {Nat.is_eq(O.chunks_of(WO_L.len(o)), K) == True{} : Bool}) -> {K == 1n+q : Nat}:
  +ks1 = k_len1(o, t, N, K, eo, ks)
  Equal.trans(Nat, K, O.chunks_of(N), 1n+q, Equal.sym(Nat, O.chunks_of(N), K, WS.nat_eq(O.chunks_of(N), K, ks1)), WO_L.chunks_q(N, q, 32n, en, {==}, {==}))

def rep_wf(-o: O.Words, +s: S.Schema, +rep: rep_pv(o, s)) -> wfv(o):
  (+w, +n) = rep
  w
