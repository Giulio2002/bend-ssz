import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/bit_root.bend as Bm
import ../../spec/bit_packing.bend as Bp
import ../../spec/primitives.bend as SP
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./bitlist_pack.bend as BK

# The definitions of bitlist_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

def blen(o: O.Bits) -> U32:
  match o:
    case O.Bits{ws, +k}: k

def bview(o: O.Bits) -> +List<Bool>:
  match o:
    case O.Bits{ws, +k}: BK.btk(U32.to_nat(k), BK.bitsof(F.array__slots(U32, F.array__freeze(U32, ws))))

# The representation invariant: an empty bit list, or a perfect word tree whose
# byte view (ceil(k/8) bytes) has the byte-list facts of words_obj.bend, whose
# bits of the last byte past k are zero, and which holds all k bits.
def wfb0(o: O.Bits) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, K =>
    DK.P2({o == O.Bits{F.array__thaw(U32, t), K} : O.Bits},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {U32.to_nat(K) == 0n : Nat}))))))

def wfb1(o: O.Bits) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, K => DK.Ex(Nat, q => DK.Ex(Nat, r =>
    DK.P2({o == O.Bits{F.array__thaw(U32, t), K} : O.Bits},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(q), r) : Nat},
    DK.P2({Nat.is_lt(0n, r) == True{} : Bool},
    DK.P2({Nat.is_le(r, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    DK.P2({WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    DK.P2({BK.zt(F.array__slots(U32, t), U32.to_nat(K)) == True{} : Bool},
    DK.P2({Bp.byte_count(U32.to_nat(K)) == U32.to_nat(O.bits_nbytes(K)) : Nat},
          {List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == U32.to_nat(K) : Nat})))))))))))))))

def wfb(o: O.Bits) -> Data:
  DK.Or2(wfb0(o), wfb1(o))

# The object represents a value of the bit list schema s: its bit count, and so
# its chunk count, are within the schema's limit.
def rep_bits(o: O.Bits, +s: S.Schema) -> Data:
  DK.P2(wfb(o), DK.P2({Nat.is_le(U32.to_nat(blen(o)), SH.BitList_limit(s)) == True{} : Bool},
    {Nat.is_le(O.chunks_of(O.bits_nbytes(blen(o))), Bm.chunk_limit(SH.BitList_limit(s))) == True{} : Bool}))

# The schema is a bit list whose chunk limit has minimal depth `depth`.
def ok_bits(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_BitList(s), Bm.canonical_depth(SH.BitList_limit(s), depth))

def rep_wf(-o: O.Bits, +s: S.Schema, +rep: rep_bits(o, s)) -> wfb(o):
  (+w, +z) = rep
  w
