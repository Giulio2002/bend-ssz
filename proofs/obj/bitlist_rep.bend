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

import ./bitlist_obj_light.bend as BL

# The bit-list representation invariant (blen, bview, wfb, rep_bits) for the encoders, without the
# root machinery (importing bitlist_obj re-checks zero_roots, 149 s). Hand-written. Each definition
# shared with bitlist_obj is that module's own, through its light companion bitlist_obj_light (one
# definition, so the encode view and the root view of a bit list cannot diverge).

def blen(o: O.Bits) -> U32: BL.blen(o)

def bview(o: O.Bits) -> +List<Bool>: BL.bview(o)

def wfb0(o: O.Bits) -> Data: BL.wfb0(o)

def wfb1(o: O.Bits) -> Data: BL.wfb1(o)

def wfb(o: O.Bits) -> Data: BL.wfb(o)

def rep_bits(o: O.Bits, +s: S.Schema) -> Data: BL.rep_bits(o, s)

def rep_wf(-o: O.Bits, +s: S.Schema, +rep: rep_bits(o, s)) -> wfb(o): BL.rep_wf(o, s, rep)

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
