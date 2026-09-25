import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/bit_root.bend as Bm
import ../../spec/bit_packing.bend as Bp
import ../../spec/packing.bend as Pack
import ../../spec/progressive.bend as PS
import ../../spec/nat_bytes.bend as Len
import ../../spec/primitives.bend as SP
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_obj.bend as WO
import ./list_root.bend as LR
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./obj_support.bend as OS
import ./spec_fixed.bend as FX
import ./bitlist_pack.bend as BK
import ./bitlist_obj.bend as BO
import ./prog_root.bend as PR

# Progressive bit lists (ProgressiveBitlist) as objects: O.Bits{ws, k}, the
# same storage and representation invariant as a bit list (bitlist_obj.bend
# `wfb`), but the runtime root is the PROGRESSIVE chunk tree of the first
# ceil(k/8) bytes (src/obj.bend bits_root_prog; prog_root.bend: the runtime
# tree is `pr`, whose bytes are spec/progressive.bend `tree`) with k mixed in.
# The specification root (spec/root_relation.bend, ProgressiveBits) is
# `aggregate` with a progressive tree over the chunks of the first k bits and
# the bit count as the length. As for bit lists, the two chunk lists meet at
# bitlist_pack.bend `bpack`. A progressive bit list has no limit.

def pbdig(+hl: Nat, o: O.Bits) -> D.Digest:
  match o:
    case O.Bits{ws, +k}: O.mix_len(hl, PR.pr(1n+O.chunks_of(O.bits_nbytes(k)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(k))), hl, 0n, 0n, O.chunks_of(O.bits_nbytes(k)), MR.clist(O.chunks_of(O.bits_nbytes(k)), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)), k)

# The object represents a value of the progressive bit list schema s.
def rep_pbits(o: O.Bits, +s: S.Schema) -> Data:
  BO.wfb(o)

def ok_pbits(+s: S.Schema) -> Bool: SH.is_ProgressiveBits(s)

law pow2_eq:
  for +d: Nat
  {F.spec_common__pow2(d) == O.pow2n(d) : Nat}
def pow2_eq(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, F.spec_common__pow2(p), O.pow2n(p), pow2_eq(p)) : {Nat.double(_) == Nat.double(O.pow2n(p)) : Nat}
      {==}

# ---- the runtime root -----------------------------------------------------------

def pst(+hl: Nat, -h: B.Buf, +t: F.array__Tree<U32>, +K: U32, +seg: U32, +dw: Nat,
    +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +hn: {Nat.is_le(O.e8(O.chunks_of(O.bits_nbytes(K))), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {O.bits_root_prog(hl, h, O.Bits{F.array__thaw(U32, t), K}, seg) == (h, (O.Bits{F.array__thaw(U32, t), K}, pbdig(hl, O.Bits{F.array__thaw(U32, t), K}))) : B.Buf & (O.Bits & D.Digest)}:
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ptree(1n+O.chunks_of(O.bits_nbytes(K)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, O.LWords{}, 0n, 0n, O.chunks_of(O.bits_nbytes(K)), (h, (F.array__thaw(U32, t), D.zero()))),
      (h, (F.array__thaw(U32, t), PR.pr(1n+O.chunks_of(O.bits_nbytes(K)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, 0n, 0n, O.chunks_of(O.bits_nbytes(K)), MR.clist(O.chunks_of(O.bits_nbytes(K)), F.array__slots(U32, t), 0n)))),
      PR.pt_run(1n+O.chunks_of(O.bits_nbytes(K)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, 0n, 0n, O.chunks_of(O.bits_nbytes(K)), dw, t, h, D.zero(), {==}, hd, pf, hn)) :
    {O.bits_rooted(hl, K, O.mt_words(O.bits_nbytes(K), _)) == (h, (O.Bits{F.array__thaw(U32, t), K}, pbdig(hl, O.Bits{F.array__thaw(U32, t), K}))) : B.Buf & (O.Bits & D.Digest)}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {(h, (O.Bits{F.array__thaw(U32, t), K}, O.mix_len(hl, PR.pr(1n+O.chunks_of(O.bits_nbytes(K)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, 0n, 0n, O.chunks_of(O.bits_nbytes(K)), MR.clist(O.chunks_of(O.bits_nbytes(K)), F.array__slots(U32, t), 0n)), K))) == (h, (O.Bits{F.array__thaw(U32, t), K}, O.mix_len(hl, PR.pr(1n+O.chunks_of(O.bits_nbytes(K)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, 0n, 0n, O.chunks_of(O.bits_nbytes(K)), MR.clist(O.chunks_of(O.bits_nbytes(K)), F.array__slots(U32, _), 0n)), K))) : B.Buf & (O.Bits & D.Digest)}
  {==}

def pb_hn1(+K: U32, +q: Nat, +r: Nat, +dw: Nat,
    +enq: {U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(O.e8(O.chunks_of(O.bits_nbytes(K))), F.spec_common__pow2(dw)) == True{} : Bool}:
  %Equal.sym(Nat, O.chunks_of(O.bits_nbytes(K)), 1n+q, WO.chunks_q(O.bits_nbytes(K), q, r, enq, h1, h32)) : {Nat.is_le(O.e8(_), F.spec_common__pow2(dw)) == True{} : Bool}
  room

# The runtime root of a represented progressive bit list: the object and pbdig.
def pbst(+hl: Nat, -h: B.Buf, -o: O.Bits, +seg: U32, +wf: BO.wfb(o))
    -> {O.bits_root_prog(hl, h, o, seg) == (h, (o, pbdig(hl, o))) : B.Buf & (O.Bits & D.Digest)}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +ek) = w5
      +kz = F.u32__injective(K, 0, ek)
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {O.bits_root_prog(hl, h, _, seg) == (h, (_, pbdig(hl, _))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(U32, K, 0, kz) :
        {O.bits_root_prog(hl, h, O.Bits{F.array__thaw(U32, t), _}, seg) == (h, (O.Bits{F.array__thaw(U32, t), _}, pbdig(hl, O.Bits{F.array__thaw(U32, t), _}))) : B.Buf & (O.Bits & D.Digest)}
      pst(hl, h, t, 0, seg, dw, hd, pf, LR.zero_le(F.spec_common__pow2(dw)))
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, w12) = w11
      (+slack, w13) = w12
      (+hz, w14) = w13
      (+hbc, +hln) = w14
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {O.bits_root_prog(hl, h, _, seg) == (h, (_, pbdig(hl, _))) : B.Buf & (O.Bits & D.Digest)}
      pst(hl, h, t, K, seg, dw, hd, pf, pb_hn1(K, q, r, dw, enq, h1, h32, room))

# ---- the specification root ---------------------------------------------------------

# The chunks of nonempty storage merkleize progressively to the bytes of pr.
def pb_merk(+hl: Nat, +ehl: {hl == 64n : Nat}, +q: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {PS.merkleize(MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))) == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}:
  +hm = Order.transitive(PR.q4(1n+q), O.e8(1n+q), O.pow2n(dw), F.nat__double_self_le(PR.q4(1n+q)),
    PR.rw_le_r(O.e8(1n+q), F.spec_common__pow2(dw), O.pow2n(dw), pow2_eq(dw), room))
  %Equal.sym(Bool, Pack.chunks_domain(MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), True{}, RS.chunks_domain_bytes(MR.clist(1n+q, F.array__slots(U32, t), 0n))) :
    {PS.gate(_, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))) == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, List.length(&2, +List<U32>, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), RS.length_bytes(MR.clist(1n+q, F.array__slots(U32, t), 0n))) :
    {Some{PS.tree(_, 0n, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)))} == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)) :
    {Some{PS.tree(_, 0n, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)))} == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n))), PS.tree(1n+q, 0n, MD.bytes_list(MD.ddrop(0n, MR.clist(1n+q, F.array__slots(U32, t), 0n)))),
      PR.pr_spec(2n+q, 1n+q, True{}, hl, ehl, 0n, 0n, 1n+q, dw, MR.clist(1n+q, F.array__slots(U32, t), 0n), MR.clist_len(1n+q, F.array__slots(U32, t), 0n), {==},
        Order.step_right(1n+q, 1n+q, Order.reflexive(1n+q)), Order.reflexive(1n+q), {==}, hm, F.nat__lt_trans(dw, 32n, 64n, hd, {==}))) :
    {Some{PS.tree(1n+q, 0n, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)))} == Some{_} : Maybe<&2, +List<U32>>}
  {==}

# The chunks of the first K bits are the chunks of the storage.
def pb_chunks(+t: F.array__Tree<U32>, +dw: Nat, +K: U32, +q: Nat, +r: Nat,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +enq: {U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +hz: {BK.zt(F.array__slots(U32, t), U32.to_nat(K)) == True{} : Bool},
    +hbc: {Bp.byte_count(U32.to_nat(K)) == U32.to_nat(O.bits_nbytes(K)) : Nat})
    -> {Bm.chunks(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>}:
  %Equal.sym(+List<U32>, Bp.pack(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), WS.btake(Bp.byte_count(U32.to_nat(K)), FX.limbs(F.array__slots(U32, t))), BK.bpack(F.array__slots(U32, t), U32.to_nat(K), hz)) :
    {Pack.scan(_, 31n, [], []) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>}
  %Equal.sym(Nat, Bp.byte_count(U32.to_nat(K)), U32.to_nat(O.bits_nbytes(K)), hbc) :
    {Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], []) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>}
  %Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(WS.e32(q), r), enq) :
    {Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], []) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>}
  WS.chunk_scan(q, r, F.array__slots(U32, t), 0n, [], h1, h32, WR.cap_at(q, dw, t, pf, room), slack)

def pb_merk1(+hl: Nat, +ehl: {hl == 64n : Nat}, +t: F.array__Tree<U32>, +dw: Nat, +K: U32, +q: Nat,
    +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +ec: {Bm.chunks(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>})
    -> {PS.merkleize(Bm.chunks(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t))))) == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(+List<+List<U32>>, Bm.chunks(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)), ec) :
    {PS.merkleize(_) == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  pb_merk(hl, ehl, q, dw, t, hd, room)

def pb_mix1(+hl: Nat, +ehl: {hl == 64n : Nat}, +t: F.array__Tree<U32>, +K: U32, +R: D.Digest,
    +hln: {List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == U32.to_nat(K) : Nat})
    -> {Bm.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))))) == Some{D.bytes(O.mix_len(hl, R, K))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), U32.to_nat(K), hln) :
    {Bm.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, K))} : Maybe<&2, +List<U32>>}
  LR.mix_bytes(hl, ehl, R, K)

# The digest of a represented progressive bit list aggregates, progressively
# and with its bit count, from the chunks of its bits.
def pbagg(+hl: Nat, +ehl: {hl == 64n : Nat}, -o: O.Bits, +wf: BO.wfb(o))
    -> RR.aggregate(True{}, 0n, Bm.chunks(BO.bview(o)), Some{List.length(&2, Bool, BO.bview(o))}, [D.bytes(pbdig(hl, o))]):
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +ek) = w5
      +kz = F.u32__injective(K, 0, ek)
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        RR.aggregate(True{}, 0n, Bm.chunks(BO.bview(_)), Some{List.length(&2, Bool, BO.bview(_))}, [D.bytes(pbdig(hl, _))])
      %Equal.sym(U32, K, 0, kz) :
        RR.aggregate(True{}, 0n, Bm.chunks(BO.bview(O.Bits{F.array__thaw(U32, t), _})), Some{List.length(&2, Bool, BO.bview(O.Bits{F.array__thaw(U32, t), _}))}, [D.bytes(pbdig(hl, O.Bits{F.array__thaw(U32, t), _}))])
      (D.bytes(PR.pr(1n, False{}, hl, 0n, 0n, 0n, MR.clist(0n, F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))), 0n))), ({==},
        LR.mix_bytes(hl, ehl, PR.pr(1n, False{}, hl, 0n, 0n, 0n, MR.clist(0n, F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))), 0n)), 0)))
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, w12) = w11
      (+slack, w13) = w12
      (+hz, w14) = w13
      (+hbc, +hln) = w14
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        RR.aggregate(True{}, 0n, Bm.chunks(BO.bview(_)), Some{List.length(&2, Bool, BO.bview(_))}, [D.bytes(pbdig(hl, _))])
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        RR.aggregate(True{}, 0n, Bm.chunks(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, _)))), Some{List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, _))))},
          [D.bytes(O.mix_len(hl, PR.pr(1n+O.chunks_of(O.bits_nbytes(K)), Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, 0n, 0n, O.chunks_of(O.bits_nbytes(K)), MR.clist(O.chunks_of(O.bits_nbytes(K)), F.array__slots(U32, _), 0n)), K))])
      %Equal.sym(Nat, O.chunks_of(O.bits_nbytes(K)), 1n+q, WO.chunks_q(O.bits_nbytes(K), q, r, enq, h1, h32)) :
        RR.aggregate(True{}, 0n, Bm.chunks(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), Some{List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t))))},
          [D.bytes(O.mix_len(hl, PR.pr(1n+_, Nat.is_lt(0n, _), hl, 0n, 0n, _, MR.clist(_, F.array__slots(U32, t), 0n)), K))])
      (D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n))),
        (pb_merk1(hl, ehl, t, dw, K, q, hd, room, pb_chunks(t, dw, K, q, r, pf, enq, h1, h32, room, slack, hz, hbc)),
         pb_mix1(hl, ehl, t, K, PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)), hln)))

# A progressive bit list's digest is a specification root of its bits.
def pbrs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Bits, +s: S.Schema,
    +rep: rep_pbits(o, s), +ok: {ok_pbits(s) == True{} : Bool})
    -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(pbdig(hl, o))]):
  %Equal.sym(S.Schema, s, S.ProgressiveBits{}, SH.ProgressiveBits_shape(s, ok)) :
    RR.roots(S.BitsValue{BO.bview(o)}, _, [D.bytes(pbdig(hl, o))])
  pbagg(hl, ehl, o, rep)

# ---- the digest as a value, from the invariant ----------------------------------------

def pbwdc(+hl: Nat, -o: O.Bits, +c: BO.CFB(o)) -> OS.DW(pbdig(hl, o)):
  (+t, +c1) = c
  (+K, +eo) = c1
  %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) : OS.DW(pbdig(hl, _))
  (pbdig(hl, O.Bits{F.array__thaw(U32, t), K}), {==})

def pbwd(+hl: Nat, -o: O.Bits, +s: S.Schema, +r: rep_pbits(o, s)) -> OS.DW(pbdig(hl, o)):
  pbwdc(hl, o, BO.bcf(o, r))
