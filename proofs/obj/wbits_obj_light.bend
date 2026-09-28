import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/bit_root.bend as Bm
import ../../spec/bit_packing.bend as Bp
import ../compact/found.bend as F
import ./words_obj_light.bend as WO_L
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./bitlist_pack.bend as BK

# The definitions of wbits_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

def wbits(o: O.Words, +n: Nat) -> +List<Bool>:
  match o:
    case O.Words{ws, +N}: BK.btk(n, BK.bitsof(F.array__slots(U32, F.array__freeze(U32, ws))))

# The bit facts of the storage for n bits: ceil(n/8) bytes, zero bits past n,
# all n bits held, and the chunk count within the bit vector's chunk limit.
def fct(o: O.Words, +n: Nat) -> Data:
  match o:
    case O.Words{ws, +N}:
      DK.P2({Nat.is_eq(U32.to_nat(N), Bp.byte_count(n)) == True{} : Bool},
      DK.P2({BK.zt(F.array__slots(U32, F.array__freeze(U32, ws)), n) == True{} : Bool},
      DK.P2({List.length(&2, Bool, BK.btk(n, BK.bitsof(F.array__slots(U32, F.array__freeze(U32, ws))))) == n : Nat},
            {Nat.is_le(O.chunks_of(N), Bm.chunk_limit(n)) == True{} : Bool})))

# The object represents a Bitvector[n] value.
def rep_bvb(o: O.Words, +n: Nat) -> Data:
  DK.P2(WO_L.wf1(o), fct(o, n))

# The schema is Bitvector[n] with n > 0 and canonical depth `depth`.
def ok_bvb(+s: S.Schema, +n: Nat, +depth: Nat) -> Bool:
  Bool.and(SH.is_BitVector(s), Bool.and(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth))))
