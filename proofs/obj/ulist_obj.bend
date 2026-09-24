import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/codec.bend as Codec
import ../../spec/packing.bend as Pack
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../proofs/integer_encoding.bend as IE
import ../../proofs/nat_order.bend as Order
import ../../proofs/nat_algebra.bend as NA
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_obj.bend as WO
import ./list_root.bend as LR
import ./list_obj.bend as LO
import ./nat_facts.bend as NF
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# Lists of uint64 held as packed words (O.Words, 8 bytes per element): the runtime
# root is the byte storage's tree with the element count (the byte length
# shifted right by 3) mixed in; the specification's is the basic-sequence root
# of the elements (spec/root_relation.bend `sequence`). See
# proofs/obj/words_obj.bend for the object form.

# ---- the elements -------------------------------------------------------------

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

law ubytes:
  for +k: Nat
  for +W: List<&2, U32>
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {RR.basic_bytes(uitems(k, W), S.Unsigned{P.U64{}}) == Some{WS.btake(O.e8(k), FX.limbs(W))} : Maybe<&2, +List<U32>>}
def ubytes(k, W, hl):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: Empty.absurd({RR.basic_bytes(uitems(1n+c, Nil{}), S.Unsigned{P.U64{}}) == Some{WS.btake(O.e8(1n+c), FX.limbs(Nil{}))} : Maybe<&2, +List<U32>>}, MD.false_true(hl))
        case Con{+a, +t}:
          match t:
            case Nil{}: Empty.absurd({RR.basic_bytes(uitems(1n+c, [a]), S.Unsigned{P.U64{}}) == Some{WS.btake(O.e8(1n+c), FX.limbs([a]))} : Maybe<&2, +List<U32>>}, MD.false_true(hl))
            case Con{+b, +rest}:
              %Equal.sym(Maybe<&2, +List<U32>>, RR.basic_bytes(uitems(c, rest), S.Unsigned{P.U64{}}), Some{WS.btake(O.e8(c), FX.limbs(rest))}, ubytes(c, rest, hl)) :
                {RR.join(Some{List.append(&2, U32, SP.limb_digits(a), SP.limb_digits(b))}, _) == Some{WS.btake(O.e8(1n+c), FX.limbs(Con{a, Con{b, rest}}))} : Maybe<&2, +List<U32>>}
              %IE.limb_correct(a) :
                {RR.join(Some{List.append(&2, U32, _, SP.limb_digits(b))}, Some{WS.btake(O.e8(c), FX.limbs(rest))}) == Some{WS.btake(O.e8(1n+c), FX.limbs(Con{a, Con{b, rest}}))} : Maybe<&2, +List<U32>>}
              %IE.limb_correct(b) :
                {RR.join(Some{List.append(&2, U32, I.limb(a), _)}, Some{WS.btake(O.e8(c), FX.limbs(rest))}) == Some{WS.btake(O.e8(1n+c), FX.limbs(Con{a, Con{b, rest}}))} : Maybe<&2, +List<U32>>}
              {==}

law ucount:
  for +k: Nat
  for +W: List<&2, U32>
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {Codec.count(uitems(k, W)) == k : Nat}
def ucount(k, W, hl):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: Empty.absurd({Codec.count(uitems(1n+c, Nil{})) == 1n+c : Nat}, MD.false_true(hl))
        case Con{+a, +t}:
          match t:
            case Nil{}: Empty.absurd({Codec.count(uitems(1n+c, [a])) == 1n+c : Nat}, MD.false_true(hl))
            case Con{+b, +rest}:
              %Equal.sym(Nat, Codec.count(uitems(c, rest)), c, ucount(c, rest, hl)) : {1n+_ == 1n+c : Nat}
              {==}

# ---- arithmetic -----------------------------------------------------------------

law e8_mul:
  for +L: Nat
  {O.e8(L) == Nat.mul(L, 8n) : Nat}
def e8_mul(L):
  match L:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, O.e8(p), Nat.mul(p, 8n), e8_mul(p)) : {8n+_ == Nat.add(8n, Nat.mul(p, 8n)) : Nat}
      {==}

law dbl_cancel:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(Nat.double(a), Nat.double(b)) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def dbl_cancel(a, b, e):
  match a b:
    case 0n _: Order.zero_le(b)
    case 1n+p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, MD.false_true(e))
    case 1n+ +p 1n+ +q: dbl_cancel(p, q, e)

law e8_zero:
  for +c: Nat
  for +e: {0n == O.e8(c) : Nat}
  {c == 0n : Nat}
def e8_zero(c, e):
  match c:
    case 0n: {==}
    case 1n+p: Empty.absurd({1n+p == 0n : Nat}, MD.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Nat, Bool, x => Nat.is_eq(x, 0n), 0n, O.e8(1n+p), e))))


def is_U64(w: P.Width) -> Bool:
  match w:
    case P.U64{}: True{}
    case _: False{}

law is_U64_shape:
  for +w: P.Width
  for +e: {is_U64(w) == True{} : Bool}
  {w == P.U64{} : P.Width}
def is_U64_shape(w, e):
  match w:
    case P.U8{}: Empty.absurd({P.U8{} == P.U64{} : P.Width}, MD.false_true(e))
    case P.U16{}: Empty.absurd({P.U16{} == P.U64{} : P.Width}, MD.false_true(e))
    case P.U32Width{}: Empty.absurd({P.U32Width{} == P.U64{} : P.Width}, MD.false_true(e))
    case P.U64{}: {==}
    case P.U128{}: Empty.absurd({P.U128{} == P.U64{} : P.Width}, MD.false_true(e))
    case P.U256{}: Empty.absurd({P.U256{} == P.U64{} : P.Width}, MD.false_true(e))

# ---- the object -----------------------------------------------------------------

def ucnt(o: O.Words) -> Nat: U32.to_nat(U32.shrn(WO.len(o), 3n))

def uview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{uitems(U32.to_nat(U32.shrn(n, 3n)), F.array__slots(U32, F.array__freeze(U32, ws)))}

def udig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(n)), hl, MR.clist(O.chunks_of(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n), 0n), U32.shrn(n, 3n))

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

# The runtime root of empty byte storage (words_root, no length).
def wr0(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +depth: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == 0n : Nat},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool})
    -> {O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(Nat, U32.to_nat(dU), depth, edu) :
    {O.mt_words(N, O.mtree(_, 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(_), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(N), 0n, en) :
    {O.mt_words(N, O.mtree(depth, 0n, Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, O.LWords{}, O.pow2n(depth), 0n, Nat.div(Nat.add(_, 31n), 32n), (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(depth, 0n, False{}, hl, O.LWords{}, O.pow2n(depth), 0n, 0n, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))),
      MR.mt_words(depth, False{}, hl, dw, t, 0n, 0n, h, D.zero(), {==}, hd, pf, LR.zero_le(F.spec_common__pow2(dw)))) :
    {O.mt_words(N, _) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  {==}

def ul_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LO.wfl(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.mix_count(hl, 3n, O.words_root(hl, h, o, dU, seg)) == (h, (o, udig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, 3n, O.words_root(hl, h, _, dU, seg)) == (h, (_, udig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))),
          wr0(hl, h, dU, seg, N, depth, dw, t, en0, pf, edu, hd)) :
        {O.mix_count(hl, 3n, _) == (h, (O.Words{F.array__thaw(U32, t), N}, udig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n), U32.shrn(N, 3n)))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(Nat, U32.to_nat(N), 0n, en0) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, MR.clist(Nat.div(Nat.add(_, 31n), 32n), F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))) : B.Buf & (O.Words & D.Digest)}
      {==}
    case Inr{w}:
      (+t, w1) = w
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
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, 3n, O.words_root(hl, h, _, dU, seg)) == (h, (_, udig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
          WR.bv_state(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
        {O.mix_count(hl, 3n, _) == (h, (O.Words{F.array__thaw(U32, t), N}, udig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n), U32.shrn(N, 3n)))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))) : B.Buf & (O.Words & D.Digest)}
      {==}

# ---- the specification root -------------------------------------------------------

def eq_n(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +eN: {U32.to_nat(WO.len(o)) == O.e8(ucnt(o)) : Nat}) -> {U32.to_nat(N) == O.e8(U32.to_nat(U32.shrn(N, 3n))) : Nat}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {U32.to_nat(_) == O.e8(U32.to_nat(U32.shrn(_, 3n))) : Nat}
  eN

def le_n(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hv: {Nat.is_le(ucnt(o), L) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(U32.shrn(N, 3n)), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(U32.to_nat(U32.shrn(_, 3n)), L) == True{} : Bool}
  hv

def rw_le_l(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h

def rw_le_r(+a: Nat, +b: Nat, +c: Nat, +e: {b == c : Nat}, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(a, c) == True{} : Bool}:
  %e : {Nat.is_le(a, _) == True{} : Bool}
  h

def add32(+q: Nat) -> {Nat.add(WS.e32(q), 32n) == WS.e32(1n+q) : Nat}: NA.add_commute(WS.e32(q), 32n)

def cap_q(+q: Nat, +dw: Nat, +t: F.array__Tree<U32>, +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(O.e8(1n+q), F.spec_common__length(U32, F.array__slots(U32, t))) == True{} : Bool}:
  %MR.add_zero(1n+q) : {Nat.is_le(O.e8(_), F.spec_common__length(U32, F.array__slots(U32, t))) == True{} : Bool}
  WR.cap_at(q, dw, t, pf, room)

def e8_mono(+a: Nat, +b: Nat, +e: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(O.e8(a), O.e8(b)) == True{} : Bool}:
  Order.double_monotone(Nat.double(Nat.double(a)), Nat.double(Nat.double(b)), Order.double_monotone(Nat.double(a), Nat.double(b), Order.double_monotone(a, b, e)))

# 2c words fit the array: 8c = 32q + r <= 32(q + 1) words... bytes; so 2c <= 8(q + 1) words.
def words_fit(+c: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +ec: {Nat.add(WS.e32(q), r) == O.e8(c) : Nat},
    +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(Nat.double(c), F.spec_common__length(U32, F.array__slots(U32, t))) == True{} : Bool}:
  +a1 = Order.add_left(WS.e32(q), r, 32n, h32)
  +a2 = rw_le_l(Nat.add(WS.e32(q), r), O.e8(c), Nat.add(WS.e32(q), 32n), ec, a1)
  +a3 = rw_le_r(O.e8(c), Nat.add(WS.e32(q), 32n), WS.e32(1n+q), add32(q), a2)
  +a4 = dbl_cancel(Nat.double(c), O.e8(1n+q), dbl_cancel(Nat.double(Nat.double(c)), Nat.double(O.e8(1n+q)), a3))
  Order.transitive(Nat.double(c), O.e8(1n+q), F.spec_common__length(U32, F.array__slots(U32, t)), a4, cap_q(q, dw, t, pf, room))

def ul_enc(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +eNN: {U32.to_nat(N) == O.e8(U32.to_nat(U32.shrn(N, 3n))) : Nat},
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {RR.basic_bytes(uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t)), S.Unsigned{P.U64{}}) == Some{WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))} : Maybe<&2, +List<U32>>}:
  +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), O.e8(U32.to_nat(U32.shrn(N, 3n))), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)
  %Equal.sym(Nat, U32.to_nat(N), O.e8(U32.to_nat(U32.shrn(N, 3n))), eNN) :
    {RR.basic_bytes(uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t)), S.Unsigned{P.U64{}}) == Some{WS.btake(_, FX.limbs(F.array__slots(U32, t)))} : Maybe<&2, +List<U32>>}
  ubytes(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t), words_fit(U32.to_nat(U32.shrn(N, 3n)), q, r, dw, t, ec, h32, pf, room))

def ul_pack(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>})
    -> {Pack.pack(WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))) == Some{MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))} : Maybe<&2, +List<+List<U32>>>}:
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq) :
    {Pack.pack(WS.btake(_, FX.limbs(F.array__slots(U32, t)))) == Some{MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Bool, SP.bytes_domain(WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), True{},
      WS.scope_dom(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR.cap_at(q, dw, t, pf, room)))) :
    {Pack.checked(_, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))) == Some{MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(+List<+List<U32>>, Pack.scan(WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), 31n, [], []), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)),
      WS.chunk_scan(q, r, F.array__slots(U32, t), 0n, [], h1, h32, WR.cap_at(q, dw, t, pf, room), slack)) :
    {Some{_} == Some{MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))} : Maybe<&2, +List<+List<U32>>>}
  {==}

def ul_lim(+N: U32, +q: Nat, +r: Nat, +L: Nat, +t: F.array__Tree<U32>,
    +eNN: {U32.to_nat(N) == O.e8(U32.to_nat(U32.shrn(N, 3n))) : Nat},
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +hvN: {Nat.is_le(U32.to_nat(U32.shrn(N, 3n)), L) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), Nat.div(Nat.add(Nat.mul(L, 8n), 31n), 32n)) == True{} : Bool}:
  +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), O.e8(U32.to_nat(U32.shrn(N, 3n))), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)
  +hm = rw_le_r(O.e8(U32.to_nat(U32.shrn(N, 3n))), O.e8(L), Nat.mul(L, 8n), e8_mul(L), e8_mono(U32.to_nat(U32.shrn(N, 3n)), L, hvN))
  +hn8 = rw_le_l(O.e8(U32.to_nat(U32.shrn(N, 3n))), Nat.add(WS.e32(q), r), Nat.mul(L, 8n), Equal.sym(Nat, Nat.add(WS.e32(q), r), O.e8(U32.to_nat(U32.shrn(N, 3n))), ec), hm)
  LR.bl_hlen(q, t, Nat.mul(L, 8n), NF.chunk_le(q, r, Nat.mul(L, 8n), h1, h32, hn8))

def ul_len(+hl: Nat, +ehl: {hl == 64n : Nat}, +N: U32, +R: D.Digest, +W: List<&2, U32>,
    +fit: {Nat.is_le(Nat.double(U32.to_nat(U32.shrn(N, 3n))), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, Codec.count(uitems(U32.to_nat(U32.shrn(N, 3n)), W)))) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, 3n)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, Codec.count(uitems(U32.to_nat(U32.shrn(N, 3n)), W)), U32.to_nat(U32.shrn(N, 3n)), ucount(U32.to_nat(U32.shrn(N, 3n)), W, fit)) :
    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, 3n)))} : Maybe<&2, +List<U32>>}
  LR.mix_bytes(hl, ehl, R, U32.shrn(N, 3n))

def ul_len0(+hl: Nat, +ehl: {hl == 64n : Nat}, +N: U32, +R: D.Digest,
    +c0: {U32.to_nat(U32.shrn(N, 3n)) == 0n : Nat})
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, 0n)) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, 3n)))} : Maybe<&2, +List<U32>>}:
  %c0 : {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, 3n)))} : Maybe<&2, +List<U32>>}
  LR.mix_bytes(hl, ehl, R, U32.shrn(N, 3n))

def ul_body(+hl: Nat, +ehl: {hl == 64n : Nat}, -o: O.Words, +L: Nat, +depth: Nat,
    +wf: LO.wfl(o),
    +eN: {U32.to_nat(WO.len(o)) == O.e8(ucnt(o)) : Nat},
    +hv: {Nat.is_le(ucnt(o), L) == True{} : Bool},
    +hmin: {Lim.minimal(Nat.div(Nat.add(Nat.mul(L, 8n), 31n), 32n), depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(uview(o), S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(udig(hl, o, depth))]):
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      +eNN = eq_n(o, t, N, eo, eN)
      +c0 = e8_zero(U32.to_nat(U32.shrn(N, 3n)), Equal.trans(Nat, 0n, U32.to_nat(N), O.e8(U32.to_nat(U32.shrn(N, 3n))), Equal.sym(Nat, U32.to_nat(N), 0n, en0), eNN))
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        RR.roots(uview(_), S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(udig(hl, _, depth))])
      %Equal.sym(Nat, U32.to_nat(U32.shrn(N, 3n)), 0n, c0) :
        RR.roots(S.Sequence{uitems(_, F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))))}, S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(udig(hl, O.Words{F.array__thaw(U32, t), N}, depth))])
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        RR.roots(S.Sequence{S.EmptyItems{}}, S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n), U32.shrn(N, 3n)))])
      %Equal.sym(Nat, U32.to_nat(N), 0n, en0) :
        RR.roots(S.Sequence{S.EmptyItems{}}, S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, MR.clist(Nat.div(Nat.add(_, 31n), 32n), F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))])
      (MD.bytes_list(MR.clist(0n, F.array__slots(U32, t), 0n)), (([], ({==}, {==})), (D.bytes(MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n)),
        ((depth, (hmin, RS.at_depth_tree(Nat.div(Nat.add(Nat.mul(L, 8n), 31n), 32n), depth, hl, MR.clist(0n, F.array__slots(U32, t), 0n), hdep, LR.zero_le(Nat.div(Nat.add(Nat.mul(L, 8n), 31n), 32n)), ehl))),
         ul_len0(hl, ehl, N, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), c0)))))
    case Inr{w}:
      (+t, w1) = w
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
      +eNN = eq_n(o, t, N, eo, eN)
      +hvN = le_n(o, t, N, L, eo, hv)
      +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), O.e8(U32.to_nat(U32.shrn(N, 3n))), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)
      +fit = words_fit(U32.to_nat(U32.shrn(N, 3n)), q, r, dw, t, ec, h32, pf, room)
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        RR.roots(uview(_), S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(udig(hl, _, depth))])
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        RR.roots(S.Sequence{uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, _))}, S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n), U32.shrn(N, 3n)))])
      %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :
        RR.roots(S.Sequence{uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t))}, S.ListOf{S.Unsigned{P.U64{}}, L}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n), U32.shrn(N, 3n)))])
      (MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)),
        ((WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t))), (ul_enc(N, q, r, dw, t, eNN, enq, h32, pf, room), ul_pack(N, q, r, dw, t, enq, h1, h32, pf, room, slack))),
         (D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n)),
          ((depth, (hmin, RS.at_depth_tree(Nat.div(Nat.add(Nat.mul(L, 8n), 31n), 32n), depth, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), hdep, ul_lim(N, q, r, L, t, eNN, enq, h1, h32, hvN), ehl))),
           ul_len(hl, ehl, N, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), F.array__slots(U32, t), fit)))))

# A list of uint64: its digest is a specification root of its elements.
def ul_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: rep_ul(o, s),
    +ok: {ok_ul(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(uview(o), s, [D.bytes(udig(hl, o, depth))]):
  (+wf, +r1) = rep
  (+eN, +hv) = r1
  +c0 = DK.and_l(SH.is_ListOf(s), Bool.and(SH.is_Unsigned(SH.ListOf_element(s)), Bool.and(is_U64(SH.Unsigned_width(SH.ListOf_element(s))), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth))), ok)
  +k1 = DK.and_r(SH.is_ListOf(s), Bool.and(SH.is_Unsigned(SH.ListOf_element(s)), Bool.and(is_U64(SH.Unsigned_width(SH.ListOf_element(s))), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth))), ok)
  +c1 = DK.and_l(SH.is_Unsigned(SH.ListOf_element(s)), Bool.and(is_U64(SH.Unsigned_width(SH.ListOf_element(s))), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth)), k1)
  +k2 = DK.and_r(SH.is_Unsigned(SH.ListOf_element(s)), Bool.and(is_U64(SH.Unsigned_width(SH.ListOf_element(s))), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth)), k1)
  +c2 = DK.and_l(is_U64(SH.Unsigned_width(SH.ListOf_element(s))), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth), k2)
  +c3 = DK.and_r(is_U64(SH.Unsigned_width(SH.ListOf_element(s))), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth), k2)
  %Equal.sym(S.Schema, s, S.ListOf{SH.ListOf_element(s), SH.ListOf_limit(s)}, SH.ListOf_shape(s, c0)) :
    RR.roots(uview(o), _, [D.bytes(udig(hl, o, depth))])
  %Equal.sym(S.Schema, SH.ListOf_element(s), S.Unsigned{SH.Unsigned_width(SH.ListOf_element(s))}, SH.Unsigned_shape(SH.ListOf_element(s), c1)) :
    RR.roots(uview(o), S.ListOf{_, SH.ListOf_limit(s)}, [D.bytes(udig(hl, o, depth))])
  %Equal.sym(P.Width, SH.Unsigned_width(SH.ListOf_element(s)), P.U64{}, is_U64_shape(SH.Unsigned_width(SH.ListOf_element(s)), c2)) :
    RR.roots(uview(o), S.ListOf{S.Unsigned{_}, SH.ListOf_limit(s)}, [D.bytes(udig(hl, o, depth))])
  ul_body(hl, ehl, o, SH.ListOf_limit(s), depth, wf, eN, hv, c3, hdep)
