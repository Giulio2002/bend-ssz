import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/limits.bend as Lim
import ../compact/found_generated.bend as F
import ./words_obj_light.bend as WO
import ./list_obj_light.bend as LO
import ./schema_shapes_generated.bend as SH
import ./dk.bend as DK

# The definitions of ulist_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

# k uint64 elements from a word list: element j is words 2j, 2j + 1 (low, high).
def uitems(k: Nat, W: List<&2, U32>) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+c:
      match W:
        case Nil{}: S.EmptyItems{}
        case Con{+a, t}:
          match t:
            case Nil{}: S.EmptyItems{}
            case Con{+b, rest}: S.Items{S.UnsignedValue{P.UInt{a, b, 0, 0, 0, 0, 0, 0}}, uitems(c, rest)}

def is_U64(w: P.Width) -> Bool:
  match w:
    case P.U64{}: True{}
    case _: False{}

def ucnt(o: O.Words) -> Nat: U32.to_nat(U32.shrn(WO.len(o), 3n))

def uview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{uitems(U32.to_nat(U32.shrn(n, 3n)), F.array__slots(U32, F.array__freeze(U32, ws)))}

# The object represents a value of the list schema s: its bytes are whole
# elements (the length is 8 times the element count) within the limit.
def rep_ul(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(LO.wfl(o), DK.P2({U32.to_nat(WO.len(o)) == O.e8(ucnt(o)) : Nat}, {Nat.is_le(ucnt(o), SH.ListOf_limit(s)) == True{} : Bool}))

# The schema is a list of uint64 whose chunk limit has minimal depth `depth`.
def ok_ul(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ListOf(s), Bool.and(SH.is_Unsigned(SH.ListOf_element(s)), Bool.and(is_U64(SH.Unsigned_width(SH.ListOf_element(s))),
    Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth))))

def rep_wf(-o: O.Words, +s: S.Schema, +rep: rep_ul(o, s)) -> LO.wfl(o):
  (+w, +n) = rep
  w
