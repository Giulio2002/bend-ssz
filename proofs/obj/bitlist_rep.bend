import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/bit_root.bend as Bm
import ../../spec/primitives.bend as SP
import ../../spec/bit_packing.bend as Bp
import ./spec_fixed.bend as FX
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./bitlist_pack.bend as BK

# The bit-list representation invariant of bitlist_obj.bend (blen, bview, wfb, rep_bits), without
# the root machinery: for the encoders (importing bitlist_obj re-checks zero_roots, 149 s).
# Hand-written; the definitions are bitlist_obj's, verbatim.

def blen(o: O.Bits) -> U32:
  match o:
    case O.Bits{ws, +k}: k

def bview(o: O.Bits) -> +List<Bool>:
  match o:
    case O.Bits{ws, +k}: BK.btk(U32.to_nat(k), BK.bitsof(F.array__slots(U32, F.array__freeze(U32, ws))))

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

def rep_bits(o: O.Bits, +s: S.Schema) -> Data:
  DK.P2(wfb(o), DK.P2({Nat.is_le(U32.to_nat(blen(o)), SH.BitList_limit(s)) == True{} : Bool},
    {Nat.is_le(O.chunks_of(O.bits_nbytes(blen(o))), Bm.chunk_limit(SH.BitList_limit(s))) == True{} : Bool}))

def rep_wf(-o: O.Bits, +s: S.Schema, +rep: rep_bits(o, s)) -> wfb(o):
  (+w, +z) = rep
  w

def blen_at(-o: O.Bits, +t: F.array__Tree<U32>, +K: U32, +eo: {o == O.Bits{F.array__thaw(U32, t), K} : O.Bits}) -> {blen(o) == K : U32}:
  Equal.cong(O.Bits, U32, blen, o, O.Bits{F.array__thaw(U32, t), K}, eo)

def CFB(o: O.Bits) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(U32, K => {o == O.Bits{F.array__thaw(U32, t), K} : O.Bits}))

def bcf(-o: O.Bits, +w: wfb(o)) -> CFB(o):
  match w:
    case Inl{+a}:
      (+t, +a1) = a
      (+dw, +a2) = a1
      (+K, +a3) = a2
      (+eo, +a4) = a3
      (t, (K, eo))
    case Inr{+b}:
      (+t, +b1) = b
      (+dw, +b2) = b1
      (+K, +b3) = b2
      (+q, +b4) = b3
      (+r, +b5) = b4
      (+eo, +b6) = b5
      (t, (K, eo))
