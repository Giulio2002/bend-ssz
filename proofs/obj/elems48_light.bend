import Base
import ../../src/obj.bend as O
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/schema.bend as S
import ../../spec/limits.bend as Lim
import ../compact/found.bend as F
import ./words_obj_light.bend as WO
import ./elems_obj.bend as EL
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./root_names_light.bend as RN_L

# The definitions of elems48.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

# The element at word b as a record: its words as the element's chunk reads see them.
def rec48(+W: List<&2, U32>, +b: Nat) -> FuluBytes48_d.Bytes48:
  FuluBytes48_d.Bytes48{EL.rdv(W, b, Nat.add(O.e8(0n), 0n), 12n), EL.rdv(W, b, Nat.add(O.e8(0n), 1n), 12n), EL.rdv(W, b, Nat.add(O.e8(0n), 2n), 12n), EL.rdv(W, b, Nat.add(O.e8(0n), 3n), 12n),
            EL.rdv(W, b, Nat.add(O.e8(0n), 4n), 12n), EL.rdv(W, b, Nat.add(O.e8(0n), 5n), 12n), EL.rdv(W, b, Nat.add(O.e8(0n), 6n), 12n), EL.rdv(W, b, Nat.add(O.e8(0n), 7n), 12n),
            EL.rdv(W, b, Nat.add(O.e8(1n), 0n), 12n), EL.rdv(W, b, Nat.add(O.e8(1n), 1n), 12n), EL.rdv(W, b, Nat.add(O.e8(1n), 2n), 12n), EL.rdv(W, b, Nat.add(O.e8(1n), 3n), 12n)}

def eitems(k: Nat, +W: List<&2, U32>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN_L.v_b48(rec48(W, Nat.mul(i, 12n))), eitems(q, W, 1n+i)}

def k48(+n: U32) -> Nat: U32.to_nat(U32.div(n, 48))

def eview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{eitems(k48(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)}

# The representation invariant: a perfect word tree holding the elements.
def wfe(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(Nat.mul(k48(N), 12n), F.spec_common__pow2(dw)) == True{} : Bool}))))))

def rep_ev(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfe(o), {Nat.is_eq(k48(WO.len(o)), SH.Vector_length(s)) == True{} : Bool})

def rep_el(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfe(o), {Nat.is_le(k48(WO.len(o)), SH.ListOf_limit(s)) == True{} : Bool})

def rep_wfv(-o: O.Words, +s: S.Schema, +rep: rep_ev(o, s)) -> wfe(o):
  (+w, +n) = rep
  w

def rep_wfl(-o: O.Words, +s: S.Schema, +rep: rep_el(o, s)) -> wfe(o):
  (+w, +n) = rep
  w

def ok_ev(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth))))

def ok_el(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth))))
