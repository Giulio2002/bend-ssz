import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/byte_list.bend as BL
import ../../spec/limits.bend as Lim
import ../compact/found.bend as F
import ./words_obj_light.bend as WO
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# The definitions of list_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

# The representation invariant of empty byte storage.
def wf0(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {U32.to_nat(N) == 0n : Nat}))))))

# Byte storage of any length.
def wfl(o: O.Words) -> Data:
  DK.Or2(wf0(o), WO.wf1(o))

# The object represents a value of the byte list schema s: its length is within
# the schema's limit.
def rep_bl(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfl(o), {Nat.is_le(U32.to_nat(WO.len(o)), SH.ByteList_limit(s)) == True{} : Bool})

# The schema is a byte list whose chunk limit has minimal depth `depth`.
def ok_bl(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ByteList(s), Lim.minimal(BL.chunk_limit(SH.ByteList_limit(s)), depth))

def rep_wf(-o: O.Words, +s: S.Schema, +rep: rep_bl(o, s)) -> wfl(o):
  (+w, +n) = rep
  w
