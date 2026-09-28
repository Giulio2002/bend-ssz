import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/limits.bend as Lim
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./spec_fixed.bend as FX
import ./words_obj_light.bend as WO
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# The definitions of cells.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

# The bytes of cell j.
def cbytes(+W: List<&2, U32>, +j: Nat) -> +List<U32>:
  WS.btake(Nat.add(WS.e32(63n), 32n), FX.limbs(WS.wdrop(O.e8(Nat.mul(j, 64n)), W)))

def citems(k: Nat, +W: List<&2, U32>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{S.BytesValue{cbytes(W, i)}, citems(q, W, 1n+i)}

def kc(+n: U32) -> Nat: U32.to_nat(U32.div(n, 2048))

def eview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{citems(kc(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)}

# The representation invariant: a perfect word tree holding the elements.
def wfe(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(Nat.mul(kc(N), 512n), F.spec_common__pow2(dw)) == True{} : Bool}))))))

def rep_el(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfe(o), {Nat.is_le(kc(WO.len(o)), SH.ListOf_limit(s)) == True{} : Bool})

def rep_wfl(-o: O.Words, +s: S.Schema, +rep: rep_el(o, s)) -> wfe(o):
  (+w, +n) = rep
  w

def ok_el(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth))))
