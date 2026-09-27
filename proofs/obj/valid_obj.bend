import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/value_domain.bend as VD
import ../../spec/primitives.bend as SP
import ../../spec/bit_root.bend as Bm
import ../../spec/limits.bend as Lim
import ../../spec/byte_list.bend as BL
import ../compact/found.bend as F
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./schema_shapes.bend as SH
import ./spec_fixed.bend as FX
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_obj.bend as WO
import ./list_obj.bend as LO
import ./pv_obj.bend as PV
import ./ulist_obj.bend as UL
import ./bitlist_obj.bend as BO
import ./bitlist_pack.bend as BK
import ./valid_lib.bend as VL
import ./cform.bend as CF

# Structural validity (spec/value_domain.bend root_valid) of the views of the
# Type-kind fields of the root laws (root_laws_b.py field kinds), from the same
# representation invariant (rep_*) and schema facts (ok_*) as their root laws.
# A lemma library of the structural-validity lemmas (codegen/valid_laws.py).

# ---- bytes -------------------------------------------------------------------

# The first N = 32q + r bytes of the words are N bytes below 256.
def bv_valid(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {VD.root_valid(S.BytesValue{WR.view(t, N)}, S.ByteVector{U32.to_nat(N)}) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :
    {VD.bytevector_domain(_, WS.btake(_, FX.limbs(F.array__slots(U32, t)))) == True{} : Bool}
  %Equal.sym(Bool, VD.bytevector_domain(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), SP.byte_scope(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))),
      WR.dom_pos(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), WR.pos_add(WS.e32(q), r, h1))) :
    {_ == True{} : Bool}
  WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR.cap_at(q, dw, t, pf, cap))

def eq_at(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ns: {Nat.is_eq(U32.to_nat(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(U32.to_nat(_), L) == True{} : Bool}
  ns

# A byte vector held as byte storage (words_obj rep_bv / ok_bv).
def vbv(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: WO.rep_bv(o, s), +ok: {WO.ok_bv(s, depth) == True{} : Bool})
    -> {VD.root_valid(S.BytesValue{WO.wview(o)}, s) == True{} : Bool}:
  (+wf, +ns) = rep
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
  +ks = DK.and_l(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth), ok)
  +eN = WS.nat_eq(U32.to_nat(N), SH.ByteVector_length(s), eq_at(o, t, N, SH.ByteVector_length(s), eo, ns))
  %Equal.sym(S.Schema, s, S.ByteVector{SH.ByteVector_length(s)}, SH.ByteVector_shape(s, ks)) :
    {VD.root_valid(S.BytesValue{WO.wview(o)}, _) == True{} : Bool}
  %eN : {VD.root_valid(S.BytesValue{WO.wview(o)}, S.ByteVector{_}) == True{} : Bool}
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {VD.root_valid(S.BytesValue{WO.wview(_)}, S.ByteVector{U32.to_nat(N)}) == True{} : Bool}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {VD.root_valid(S.BytesValue{WR.view(_, N)}, S.ByteVector{U32.to_nat(N)}) == True{} : Bool}
  bv_valid(N, q, r, dw, t, enq, h1, h32, pf, room)

# n bytes below 256 are a byte list of length n.
law sc_len:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(n, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == n : Nat}
def sc_len(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{+x, +t}: Empty.absurd({List.length(&2, U32, Con{x, t}) == 0n : Nat}, MD.false_true(e))
    case 1n+ +p:
      match xs:
        case Nil{}: Empty.absurd({List.length(&2, U32, Nil{}) == 1n+p : Nat}, MD.false_true(e))
        case Con{+x, +t}:
          %Equal.sym(Nat, List.length(&2, U32, t), p, sc_len(p, t, WS.and_right(U32.is_lt(x, 256), SP.byte_scope(p, t), e))) :
            {1n+_ == 1n+p : Nat}
          {==}

law sc_dom:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(n, xs) == True{} : Bool}
  {SP.bytes_domain(xs) == True{} : Bool}
def sc_dom(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{+x, +t}: Empty.absurd({SP.bytes_domain(Con{x, t}) == True{} : Bool}, MD.false_true(e))
    case 1n+ +p:
      match xs:
        case Nil{}: {==}
        case Con{+x, +t}:
          %Equal.sym(Bool, U32.is_lt(x, 256), True{}, WS.and_left(U32.is_lt(x, 256), SP.byte_scope(p, t), e)) :
            {Bool.and(_, SP.bytes_domain(t)) == True{} : Bool}
          sc_dom(p, t, WS.and_right(U32.is_lt(x, 256), SP.byte_scope(p, t), e))

# The first N = 32q + r bytes of the words are N bytes below 256.
def scN(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {SP.byte_scope(U32.to_nat(N), WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq) :
    {SP.byte_scope(_, WS.btake(_, FX.limbs(F.array__slots(U32, t)))) == True{} : Bool}
  WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR.cap_at(q, dw, t, pf, room))

# Empty byte storage views no bytes.
def wempty_v(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words}, +en0: {U32.to_nat(N) == 0n : Nat})
    -> {WO.wview(o) == [] : +List<U32>}:
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) : {WO.wview(_) == [] : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(N), 0n, en0) : {WS.btake(_, FX.limbs(F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))))) == [] : +List<U32>}
  {==}

def wempty_n(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words}, +en0: {U32.to_nat(N) == 0n : Nat})
    -> {U32.to_nat(WO.len(o)) == 0n : Nat}:
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) : {U32.to_nat(WO.len(_)) == 0n : Nat}
  en0

law zero_le:
  for +x: Nat
  {Nat.is_le(0n, x) == True{} : Bool}
def zero_le(x):
  match x:
    case 0n: {==}
    case 1n+p: {==}

def vbl_go(-o: O.Words, +L: Nat, +wf: LO.wfl(o), +hn: {Nat.is_le(U32.to_nat(WO.len(o)), L) == True{} : Bool})
    -> {Bool.and(SP.bytes_domain(WO.wview(o)), Nat.is_le(List.length(&2, U32, WO.wview(o)), L)) == True{} : Bool}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      %Equal.sym(+List<U32>, WO.wview(o), [], wempty_v(o, t, N, eo, en0)) :
        {Bool.and(SP.bytes_domain(_), Nat.is_le(List.length(&2, U32, _), L)) == True{} : Bool}
      zero_le(L)
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
      +hnN = LO.le_len(o, t, N, L, eo, hn)
      +sc = scN(N, q, r, dw, t, enq, h32, pf, room)
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {Bool.and(SP.bytes_domain(WO.wview(_)), Nat.is_le(List.length(&2, U32, WO.wview(_)), L)) == True{} : Bool}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {Bool.and(SP.bytes_domain(WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, _)))), Nat.is_le(List.length(&2, U32, WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, _)))), L)) == True{} : Bool}
      %Equal.sym(Bool, SP.bytes_domain(WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))), True{}, sc_dom(U32.to_nat(N), WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t))), sc)) :
        {Bool.and(_, Nat.is_le(List.length(&2, U32, WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))), L)) == True{} : Bool}
      %Equal.sym(Nat, List.length(&2, U32, WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))), U32.to_nat(N), sc_len(U32.to_nat(N), WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t))), sc)) :
        {Bool.and(True{}, Nat.is_le(_, L)) == True{} : Bool}
      hnN

# A byte list held as byte storage (list_obj rep_bl / ok_bl).
def vbl(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: LO.rep_bl(o, s), +ok: {LO.ok_bl(s, depth) == True{} : Bool})
    -> {VD.root_valid(S.BytesValue{WO.wview(o)}, s) == True{} : Bool}:
  (+wf, +hn) = rep
  +ks = DK.and_l(SH.is_ByteList(s), Lim.minimal(BL.chunk_limit(SH.ByteList_limit(s)), depth), ok)
  %Equal.sym(S.Schema, s, S.ByteList{SH.ByteList_limit(s)}, SH.ByteList_shape(s, ks)) :
    {VD.root_valid(S.BytesValue{WO.wview(o)}, _) == True{} : Bool}
  vbl_go(o, SH.ByteList_limit(s), wf, hn)

# ---- bit lists -----------------------------------------------------------------

def bits_len(-o: O.Bits, +w: BO.wfb(o)) -> {List.length(&2, Bool, BO.bview(o)) == U32.to_nat(BO.blen(o)) : Nat}:
  match w:
    case Inl{w0}:
      (+t, w1) = w0
      (+dw, w2) = w1
      (+K, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +ek) = w5
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {List.length(&2, Bool, BO.bview(_)) == U32.to_nat(BO.blen(_)) : Nat}
      %Equal.sym(Nat, U32.to_nat(K), 0n, ek) :
        {List.length(&2, Bool, BK.btk(_, BK.bitsof(F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t)))))) == _ : Nat}
      {==}
    case Inr{w0}:
      (+t, w1) = w0
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
        {List.length(&2, Bool, BO.bview(_)) == U32.to_nat(BO.blen(_)) : Nat}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, _)))) == U32.to_nat(K) : Nat}
      hln

# A bit list (bitlist_obj rep_bits / ok_bits).
def vbits(-o: O.Bits, +s: S.Schema, +depth: Nat, +rep: BO.rep_bits(o, s), +ok: {BO.ok_bits(s, depth) == True{} : Bool})
    -> {VD.root_valid(S.BitsValue{BO.bview(o)}, s) == True{} : Bool}:
  (+wf, +hs) = rep
  (+hn, +hc) = hs
  +ks = DK.and_l(SH.is_BitList(s), Bm.canonical_depth(SH.BitList_limit(s), depth), ok)
  %Equal.sym(S.Schema, s, S.BitList{SH.BitList_limit(s)}, SH.BitList_shape(s, ks)) :
    {VD.root_valid(S.BitsValue{BO.bview(o)}, _) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, Bool, BO.bview(o)), U32.to_nat(BO.blen(o)), bits_len(o, wf)) :
    {Nat.is_le(_, SH.BitList_limit(s)) == True{} : Bool}
  hn

# ---- vectors of Bytes32 held as byte storage (pv_obj) ------------------------------

law items_len:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {VD.items_length(WR.items(k, W, i)) == k : Nat}
def items_len(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, VD.items_length(WR.items(q, W, 1n+i)), q, items_len(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}

law items_valid:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {VD.root_valid(WR.items(k, W, i), S.Repeat{S.ByteVector{32n}}) == True{} : Bool}
def items_valid(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Bool, SP.byte_scope(32n, WS.cb(W, i)), True{}, WS.scope_cb(W, i)) :
        {Bool.and(_, VD.root_valid(WR.items(q, W, 1n+i), S.Repeat{S.ByteVector{32n}})) == True{} : Bool}
      items_valid(q, W, 1n+i)

def pv_at(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ns: {Nat.is_eq(O.chunks_of(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_eq(O.chunks_of(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(O.chunks_of(_), L) == True{} : Bool}
  ns

def pv_items(+q: Nat, +W: List<&2, U32>)
    -> {VD.root_valid(S.Sequence{WR.items(1n+q, W, 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}) == True{} : Bool}:
  %Equal.sym(Bool, VD.root_valid(WR.items(1n+q, W, 0n), S.Repeat{S.ByteVector{32n}}), True{}, items_valid(1n+q, W, 0n)) :
    {Bool.and(Bool.and(Nat.is_lt(0n, 1n+q), Nat.is_eq(VD.items_length(WR.items(1n+q, W, 0n)), 1n+q)), _) == True{} : Bool}
  %Equal.sym(Nat, VD.items_length(WR.items(1n+q, W, 0n)), 1n+q, items_len(1n+q, W, 0n)) :
    {Bool.and(Bool.and(True{}, Nat.is_eq(_, 1n+q)), True{}) == True{} : Bool}
  %Equal.sym(Bool, Nat.is_eq(1n+q, 1n+q), True{}, F.nat__is_eq_refl(1n+q)) :
    {Bool.and(Bool.and(True{}, _), True{}) == True{} : Bool}
  {==}

# A vector of Bytes32 (pv_obj rep_pv / ok_pv).
def vpv(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: PV.rep_pv(o, s), +ok: {PV.ok_pv(s, depth) == True{} : Bool})
    -> {VD.root_valid(PV.pview(o), s) == True{} : Bool}:
  (+wf, +ns) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+q, w4) = w3
  (+eo, w5) = w4
  (+pf, w6) = w5
  (+hd, w7) = w6
  (+en, +room) = w7
  +k0 = DK.and_l(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +r1 = DK.and_r(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +k1 = DK.and_l(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +k2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth), r2)
  +eC = WS.nat_eq(O.chunks_of(N), SH.Vector_length(s), pv_at(o, t, N, SH.Vector_length(s), eo, ns))
  +e32 = WS.nat_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n, k2)
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, k0)) :
    {VD.root_valid(PV.pview(o), _) == True{} : Bool}
  %Equal.sym(S.Schema, SH.Vector_element(s), S.ByteVector{SH.ByteVector_length(SH.Vector_element(s))}, SH.ByteVector_shape(SH.Vector_element(s), k1)) :
    {VD.root_valid(PV.pview(o), S.Vector{_, SH.Vector_length(s)}) == True{} : Bool}
  %Equal.sym(Nat, SH.ByteVector_length(SH.Vector_element(s)), 32n, e32) :
    {VD.root_valid(PV.pview(o), S.Vector{S.ByteVector{_}, SH.Vector_length(s)}) == True{} : Bool}
  %eC : {VD.root_valid(PV.pview(o), S.Vector{S.ByteVector{32n}, _}) == True{} : Bool}
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {VD.root_valid(PV.pview(_), S.Vector{S.ByteVector{32n}, O.chunks_of(N)}) == True{} : Bool}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {VD.root_valid(S.Sequence{WR.items(O.chunks_of(N), F.array__slots(U32, _), 0n)}, S.Vector{S.ByteVector{32n}, O.chunks_of(N)}) == True{} : Bool}
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, 32n, en, {==}, {==})) :
    {VD.root_valid(S.Sequence{WR.items(_, F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{32n}, _}) == True{} : Bool}
  pv_items(q, F.array__slots(U32, t))

# ---- lists of uint64 held as byte storage (ulist_obj) ----------------------------

law ulen_le:
  for +k: Nat
  for +W: List<&2, U32>
  {Nat.is_le(VD.items_length(UL.uitems(k, W)), k) == True{} : Bool}
def ulen_le(k, W):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: zero_le(1n+c)
        case Con{+a, +t}:
          match t:
            case Nil{}: zero_le(1n+c)
            case Con{+b, +rest}: ulen_le(c, rest)

law uvalid:
  for +k: Nat
  for +W: List<&2, U32>
  {VD.root_valid(UL.uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}) == True{} : Bool}
def uvalid(k, W):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a, +t}:
          match t:
            case Nil{}: {==}
            case Con{+b, +rest}:
              %Equal.sym(Bool, SP.uint_domain(P.U64{}, P.UInt{a, b, 0, 0, 0, 0, 0, 0}), True{}, VL.u64dom(a, b)) :
                {Bool.and(_, VD.root_valid(UL.uitems(c, rest), S.Repeat{S.Unsigned{P.U64{}}})) == True{} : Bool}
              uvalid(c, rest)

def ucnt_at(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hv: {Nat.is_le(UL.ucnt(o), L) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(U32.shrn(N, 3n)), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(U32.to_nat(U32.shrn(_, 3n)), L) == True{} : Bool}
  hv

def vul_go(-o: O.Words, +L: Nat, +c: CF.CF(o), +hv: {Nat.is_le(UL.ucnt(o), L) == True{} : Bool})
    -> {VD.root_valid(UL.uview(o), S.ListOf{S.Unsigned{P.U64{}}, L}) == True{} : Bool}:
  (+t, +c1) = c
  (+N, +eo) = c1
  +hvN = ucnt_at(o, t, N, L, eo, hv)
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {VD.root_valid(UL.uview(_), S.ListOf{S.Unsigned{P.U64{}}, L}) == True{} : Bool}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {VD.root_valid(S.Sequence{UL.uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, _))}, S.ListOf{S.Unsigned{P.U64{}}, L}) == True{} : Bool}
  %Equal.sym(Bool, VD.root_valid(UL.uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t)), S.Repeat{S.Unsigned{P.U64{}}}), True{}, uvalid(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t))) :
    {Bool.and(Nat.is_le(VD.items_length(UL.uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t))), L), _) == True{} : Bool}
  %Equal.sym(Bool, Nat.is_le(VD.items_length(UL.uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t))), L), True{},
      F.nat__le_trans(VD.items_length(UL.uitems(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t))), U32.to_nat(U32.shrn(N, 3n)), L, ulen_le(U32.to_nat(U32.shrn(N, 3n)), F.array__slots(U32, t)), hvN)) :
    {Bool.and(_, True{}) == True{} : Bool}
  {==}

# A list of uint64 (ulist_obj rep_ul / ok_ul).
def vul(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: UL.rep_ul(o, s), +ok: {UL.ok_ul(s, depth) == True{} : Bool})
    -> {VD.root_valid(UL.uview(o), s) == True{} : Bool}:
  (+wf, +r1) = rep
  (+eN, +hv) = r1
  +E = SH.ListOf_element(s)
  +k0 = DK.and_l(SH.is_ListOf(s), Bool.and(SH.is_Unsigned(E), Bool.and(UL.is_U64(SH.Unsigned_width(E)), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth))), ok)
  +r2 = DK.and_r(SH.is_ListOf(s), Bool.and(SH.is_Unsigned(E), Bool.and(UL.is_U64(SH.Unsigned_width(E)), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth))), ok)
  +k1 = DK.and_l(SH.is_Unsigned(E), Bool.and(UL.is_U64(SH.Unsigned_width(E)), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth)), r2)
  +r3 = DK.and_r(SH.is_Unsigned(E), Bool.and(UL.is_U64(SH.Unsigned_width(E)), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth)), r2)
  +k2 = DK.and_l(UL.is_U64(SH.Unsigned_width(E)), Lim.minimal(Nat.div(Nat.add(Nat.mul(SH.ListOf_limit(s), 8n), 31n), 32n), depth), r3)
  %Equal.sym(S.Schema, s, S.ListOf{E, SH.ListOf_limit(s)}, SH.ListOf_shape(s, k0)) :
    {VD.root_valid(UL.uview(o), _) == True{} : Bool}
  %Equal.sym(S.Schema, E, S.Unsigned{SH.Unsigned_width(E)}, SH.Unsigned_shape(E, k1)) :
    {VD.root_valid(UL.uview(o), S.ListOf{_, SH.ListOf_limit(s)}) == True{} : Bool}
  %Equal.sym(P.Width, SH.Unsigned_width(E), P.U64{}, UL.is_U64_shape(SH.Unsigned_width(E), k2)) :
    {VD.root_valid(UL.uview(o), S.ListOf{S.Unsigned{_}, SH.ListOf_limit(s)}) == True{} : Bool}
  vul_go(o, SH.ListOf_limit(s), CF.cfl(o, wf), hv)

# A validity fact moves along an equation of schemas.
def vtrans(-v: S.Value, -s: S.Schema, -E: S.Schema, +e: {s == E : S.Schema}, +h: {VD.root_valid(v, E) == True{} : Bool})
    -> {VD.root_valid(v, s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, E, e) : {VD.root_valid(v, _) == True{} : Bool}
  h

def le_rw(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h
