import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/bit_root.bend as Bm
import ../../spec/bit_packing.bend as Bp
import ../../spec/packing.bend as Pack
import ../../spec/limits.bend as Lim
import ../../spec/primitives.bend as SP
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./words_root_light.bend as WR
import ./words_obj.bend as WO
import ./words_obj_light.bend as WO_L
import ./cform.bend as CF
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./obj_support.bend as OS
import ./spec_fixed.bend as FX
import ./bitlist_pack.bend as BK

# Bit vectors held as byte storage (O.Words{ws, N}, N = ceil(n/8) bytes: the
# generated form of a Bitvector[n] too long for a record of words). The
# runtime root is the byte vector's (words_obj.bend `wdig`, O.words_root at the
# depth of the chunk count); the view is the first n bits of the words. As for
# bit lists (bitlist_obj.bend) the two meet at bitlist_pack.bend `bpack`: the
# first n bits pack to the first ceil(n/8) bytes when the bits of the last byte
# past n are zero (`zt`).

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

def fct_at(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +n: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words}, +fc: fct(o, n))
    -> fct(O.Words{F.array__thaw(U32, t), N}, n):
  %eo : fct(_, n)
  fc

# The same facts over the word tree itself.
def fct2(+t: F.array__Tree<U32>, +N: U32, +n: Nat) -> Data:
  DK.P2({Nat.is_eq(U32.to_nat(N), Bp.byte_count(n)) == True{} : Bool},
  DK.P2({BK.zt(F.array__slots(U32, t), n) == True{} : Bool},
  DK.P2({List.length(&2, Bool, BK.btk(n, BK.bitsof(F.array__slots(U32, t)))) == n : Nat},
        {Nat.is_le(O.chunks_of(N), Bm.chunk_limit(n)) == True{} : Bool})))

def fct_ft(+t: F.array__Tree<U32>, +N: U32, +n: Nat, +fc: fct(O.Words{F.array__thaw(U32, t), N}, n)) -> fct2(t, N, n):
  %F.array__freeze_thaw(U32, t) :
    DK.P2({Nat.is_eq(U32.to_nat(N), Bp.byte_count(n)) == True{} : Bool},
    DK.P2({BK.zt(F.array__slots(U32, _), n) == True{} : Bool},
    DK.P2({List.length(&2, Bool, BK.btk(n, BK.bitsof(F.array__slots(U32, _)))) == n : Nat},
          {Nat.is_le(O.chunks_of(N), Bm.chunk_limit(n)) == True{} : Bool})))
  fc

def le_rw(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h

def bvb_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +n: Nat, +rep: rep_bvb(o, n), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.words_root(hl, h, o, dU, seg) == (h, (o, WO_L.wdig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  (+wf, +fc) = rep
  WO.bv_st(hl, h, o, dU, seg, depth, wf, edu)

# The gate over the storage's concrete form.
def bvb_gate(+hl: Nat, +ehl: {hl == 64n : Nat}, +t: F.array__Tree<U32>, +dw: Nat, +N: U32, +q: Nat, +r: Nat, +n: Nat, +depth: Nat,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +fc: fct2(t, N, n),
    +kpos: {Nat.is_lt(0n, n) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> {Bm.bitvector_at_depth(n, depth, BK.btk(n, BK.bitsof(F.array__slots(U32, t)))) == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}:
  (+hbc, +f1) = fc
  (+hz, +f2) = f1
  (+hln, +hcl) = f2
  +BITS = BK.btk(n, BK.bitsof(F.array__slots(U32, t)))
  +DIG = D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))
  +ebc = WS.nat_eq(U32.to_nat(N), Bp.byte_count(n), hbc)
  +ecq = WO_L.chunks_q(N, q, r, enq, h1, h32)
  %Equal.sym(Nat, List.length(&2, Bool, BITS), n, hln) :
    {Bm.vector_gate(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(_, n)), n, depth, BITS) == Some{DIG} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_eq(n, n), True{}, F.nat__is_eq_refl(n)) :
    {Bm.vector_gate(Bool.and(Nat.is_lt(0n, n), _), n, depth, BITS) == Some{DIG} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_lt(0n, n), True{}, kpos) :
    {Bm.vector_gate(Bool.and(_, True{}), n, depth, BITS) == Some{DIG} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Bp.pack(BITS), WS.btake(Bp.byte_count(n), FX.limbs(F.array__slots(U32, t))), BK.bpack(F.array__slots(U32, t), n, hz)) :
    {Lim.at_depth(Bm.chunk_limit(n), depth, Pack.scan(_, 31n, [], [])) == Some{DIG} : Maybe<&2, +List<U32>>}
  %ebc :
    {Lim.at_depth(Bm.chunk_limit(n), depth, Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], [])) == Some{DIG} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq) :
    {Lim.at_depth(Bm.chunk_limit(n), depth, Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], [])) == Some{DIG} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Pack.scan(WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), 31n, [], []), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)),
      WS.chunk_scan(q, r, F.array__slots(U32, t), 0n, [], h1, h32, WR.cap_at(q, dw, t, pf, room), slack)) :
    {Lim.at_depth(Bm.chunk_limit(n), depth, _) == Some{DIG} : Maybe<&2, +List<U32>>}
  +hcq0 = le_rw(O.chunks_of(N), 1n+q, Bm.chunk_limit(n), ecq, hcl)
  +hcq = le_rw(1n+q, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), Bm.chunk_limit(n), Equal.sym(Nat, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)), hcq0)
  %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(Bm.chunk_limit(n), depth, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n))), hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))},
      RS.at_depth_tree(Bm.chunk_limit(n), depth, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), hdep, hcq, ehl)) :
    {_ == Some{DIG} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_lt(0n, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n))), True{}, {==}) :
    {Some{D.bytes(MD.rtree(depth, _, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} == Some{DIG} : Maybe<&2, +List<U32>>}
  {==}

def bvb_body(+hl: Nat, +ehl: {hl == 64n : Nat}, -o: O.Words, +n: Nat, +depth: Nat, +wf: WO_L.wf1(o), +fc: fct(o, n),
    +kpos: {Nat.is_lt(0n, n) == True{} : Bool},
    +kcan: {Bm.canonical_depth(n, depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(S.BitsValue{wbits(o, n)}, S.BitVector{n}, [D.bytes(WO_L.wdig(hl, o, depth))]):
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+q, w4) = w3
  (+r, w5) = w4
  (+eo, w6) = w5
  (+pf, w7) = w6
  (+hd, w8) = w7
  (+enq, w9) = w8
  (+h1, w10) = w9
  (+h32, w11) = w10
  (+room, +slack) = w11
  +fc2 = fct_ft(t, N, n, fct_at(o, t, N, n, eo, fc))
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(S.BitsValue{wbits(_, n)}, S.BitVector{n}, [D.bytes(WO_L.wdig(hl, _, depth))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.BitsValue{BK.btk(n, BK.bitsof(F.array__slots(U32, _)))}, S.BitVector{n}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n))])
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO_L.chunks_q(N, q, r, enq, h1, h32)) :
    RR.roots(S.BitsValue{BK.btk(n, BK.bitsof(F.array__slots(U32, t)))}, S.BitVector{n}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n))])
  (depth, (kcan, bvb_gate(hl, ehl, t, dw, N, q, r, n, depth, pf, enq, h1, h32, room, slack, fc2, kpos, hdep)))

# A bit vector in byte storage: its digest is a specification root of its bits.
def bvb_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +n: Nat, +depth: Nat,
    +rep: rep_bvb(o, n),
    +ok: {ok_bvb(s, n, depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(S.BitsValue{wbits(o, n)}, s, [D.bytes(WO_L.wdig(hl, o, depth))]):
  (+wf, +fc) = rep
  +ks = DK.and_l(SH.is_BitVector(s), Bool.and(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth))), ok)
  +k1 = DK.and_r(SH.is_BitVector(s), Bool.and(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth))), ok)
  +keq = DK.and_l(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth)), k1)
  +k2 = DK.and_r(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth)), k1)
  +kpos = DK.and_l(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth), k2)
  +kcan = DK.and_r(Nat.is_lt(0n, n), Bm.canonical_depth(n, depth), k2)
  %Equal.sym(S.Schema, s, S.BitVector{SH.BitVector_length(s)}, SH.BitVector_shape(s, ks)) :
    RR.roots(S.BitsValue{wbits(o, n)}, _, [D.bytes(WO_L.wdig(hl, o, depth))])
  %Equal.sym(Nat, SH.BitVector_length(s), n, WS.nat_eq(SH.BitVector_length(s), n, keq)) :
    RR.roots(S.BitsValue{wbits(o, n)}, S.BitVector{_}, [D.bytes(WO_L.wdig(hl, o, depth))])
  bvb_body(hl, ehl, o, n, depth, wf, fc, kpos, kcan, hdep)

# ---- the digest as a value, from the invariant ----------------------------------------

def bvb_wdc(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(WO_L.wdig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(WO_L.wdig(hl, _, d))
  (WO_L.wdig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})

def bvb_wd(+hl: Nat, -o: O.Words, +n: Nat, +d: Nat, +r: rep_bvb(o, n)) -> OS.DW(WO_L.wdig(hl, o, d)):
  (+w, +z) = r
  bvb_wdc(hl, o, d, CF.cf1(o, w))
