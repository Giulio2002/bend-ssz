import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/value_domain.bend as VD
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../../spec/tree.bend as Tr
import ../compact/found.bend as F
import ../compact/arith.bend as AR
import ./dk.bend as DK
import ./mtree_run.bend as MR
import ./schema_shapes.bend as SH
import ./words_spec.bend as WS
import ./words_obj.bend as WO
import ./elems_obj.bend as EL
import ./elems48.bend as E48
import ./cells.bend as CE
import ./root_names_light.bend as RN
import ./valid_names.bend as VN
import ./valid_obj.bend as VO

# Structural validity of the packed-element views (vectors/lists of Bytes48,
# elems48.bend; lists of cells, cells.bend), from their rep_* and ok_* facts.
# A lemma library of the structural-validity lemmas (codegen/valid_laws.py).

# A minimal depth above 0 covers at least one chunk.
def min_pos(+n: Nat, +p: Nat, +h: {Lim.minimal(n, 1n+p) == True{} : Bool}) -> {Nat.is_lt(0n, n) == True{} : Bool}:
  F.nat__le_lt_trans(0n, Tr.capacity(p), n, VO.zero_le(Tr.capacity(p)), DK.and_r(Nat.is_le(n, Tr.capacity(1n+p)), Nat.is_lt(Tr.capacity(p), n), h))

def lt0_rw(+a: Nat, +b: Nat, +e: {a == b : Nat}, +h: {Nat.is_lt(0n, b) == True{} : Bool}) -> {Nat.is_lt(0n, a) == True{} : Bool}:
  %Equal.sym(Nat, a, b, e) : {Nat.is_lt(0n, _) == True{} : Bool}
  h

# ---- Bytes48 elements -------------------------------------------------------------

law elen:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {VD.items_length(E48.eitems(k, W, i)) == k : Nat}
def elen(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, VD.items_length(E48.eitems(q, W, 1n+i)), q, elen(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}

law evalid:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {VD.root_valid(E48.eitems(k, W, i), S.Repeat{S.ByteVector{48n}}) == True{} : Bool}
def evalid(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(E48.rec48(W, Nat.mul(i, 12n))), S.ByteVector{48n}), True{}, VN.rv_b48(E48.rec48(W, Nat.mul(i, 12n)))) :
        {Bool.and(_, VD.root_valid(E48.eitems(q, W, 1n+i), S.Repeat{S.ByteVector{48n}})) == True{} : Bool}
      evalid(q, W, 1n+i)

def k48_eq(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ns: {Nat.is_eq(E48.k48(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_eq(E48.k48(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(E48.k48(_), L) == True{} : Bool}
  ns

def k48_le(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hv: {Nat.is_le(E48.k48(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_le(E48.k48(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(E48.k48(_), L) == True{} : Bool}
  hv

def ev_items(+k: Nat, +W: List<&2, U32>, +kp: {Nat.is_lt(0n, k) == True{} : Bool})
    -> {VD.root_valid(S.Sequence{E48.eitems(k, W, 0n)}, S.Vector{S.ByteVector{48n}, k}) == True{} : Bool}:
  %Equal.sym(Bool, VD.root_valid(E48.eitems(k, W, 0n), S.Repeat{S.ByteVector{48n}}), True{}, evalid(k, W, 0n)) :
    {Bool.and(Bool.and(Nat.is_lt(0n, k), Nat.is_eq(VD.items_length(E48.eitems(k, W, 0n)), k)), _) == True{} : Bool}
  %Equal.sym(Nat, VD.items_length(E48.eitems(k, W, 0n)), k, elen(k, W, 0n)) :
    {Bool.and(Bool.and(Nat.is_lt(0n, k), Nat.is_eq(_, k)), True{}) == True{} : Bool}
  %Equal.sym(Bool, Nat.is_eq(k, k), True{}, F.nat__is_eq_refl(k)) :
    {Bool.and(Bool.and(Nat.is_lt(0n, k), _), True{}) == True{} : Bool}
  %Equal.sym(Bool, Nat.is_lt(0n, k), True{}, kp) :
    {Bool.and(Bool.and(_, True{}), True{}) == True{} : Bool}
  {==}

# A vector of Bytes48 (elems48 rep_ev / ok_ev at a depth above 0).
def vev(-o: O.Words, +s: S.Schema, +dp: Nat, +rep: E48.rep_ev(o, s), +ok: {E48.ok_ev(s, 1n+dp) == True{} : Bool})
    -> {VD.root_valid(E48.eview(o), s) == True{} : Bool}:
  (+wf, +ns) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  +E = SH.Vector_element(s)
  +n = SH.Vector_length(s)
  +k0 = DK.and_l(SH.is_Vector(s), Bool.and(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(n, 1n+dp))), ok)
  +r1 = DK.and_r(SH.is_Vector(s), Bool.and(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(n, 1n+dp))), ok)
  +k1 = DK.and_l(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(n, 1n+dp)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(n, 1n+dp)), r1)
  +k2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(n, 1n+dp), r2)
  +k3 = DK.and_r(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(n, 1n+dp), r2)
  +eK = WS.nat_eq(E48.k48(N), n, k48_eq(o, t, N, n, eo, ns))
  +kpN = lt0_rw(E48.k48(N), n, eK, min_pos(n, dp, k3))
  %Equal.sym(S.Schema, s, S.Vector{E, n}, SH.Vector_shape(s, k0)) :
    {VD.root_valid(E48.eview(o), _) == True{} : Bool}
  %Equal.sym(S.Schema, E, S.ByteVector{SH.ByteVector_length(E)}, SH.ByteVector_shape(E, k1)) :
    {VD.root_valid(E48.eview(o), S.Vector{_, n}) == True{} : Bool}
  %Equal.sym(Nat, SH.ByteVector_length(E), 48n, WS.nat_eq(SH.ByteVector_length(E), 48n, k2)) :
    {VD.root_valid(E48.eview(o), S.Vector{S.ByteVector{_}, n}) == True{} : Bool}
  %eK : {VD.root_valid(E48.eview(o), S.Vector{S.ByteVector{48n}, _}) == True{} : Bool}
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {VD.root_valid(E48.eview(_), S.Vector{S.ByteVector{48n}, E48.k48(N)}) == True{} : Bool}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {VD.root_valid(S.Sequence{E48.eitems(E48.k48(N), F.array__slots(U32, _), 0n)}, S.Vector{S.ByteVector{48n}, E48.k48(N)}) == True{} : Bool}
  ev_items(E48.k48(N), F.array__slots(U32, t), kpN)

# A list of Bytes48 (elems48 rep_el / ok_el).
def vel(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: E48.rep_el(o, s), +ok: {E48.ok_el(s, depth) == True{} : Bool})
    -> {VD.root_valid(E48.eview(o), s) == True{} : Bool}:
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  +E = SH.ListOf_element(s)
  +L = SH.ListOf_limit(s)
  +k0 = DK.and_l(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(L, depth))), ok)
  +r1 = DK.and_r(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(L, depth))), ok)
  +k1 = DK.and_l(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(L, depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(L, depth)), r1)
  +k2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(E), 48n), Lim.minimal(L, depth), r2)
  +hvN = k48_le(o, t, N, L, eo, hv)
  %Equal.sym(S.Schema, s, S.ListOf{E, L}, SH.ListOf_shape(s, k0)) :
    {VD.root_valid(E48.eview(o), _) == True{} : Bool}
  %Equal.sym(S.Schema, E, S.ByteVector{SH.ByteVector_length(E)}, SH.ByteVector_shape(E, k1)) :
    {VD.root_valid(E48.eview(o), S.ListOf{_, L}) == True{} : Bool}
  %Equal.sym(Nat, SH.ByteVector_length(E), 48n, WS.nat_eq(SH.ByteVector_length(E), 48n, k2)) :
    {VD.root_valid(E48.eview(o), S.ListOf{S.ByteVector{_}, L}) == True{} : Bool}
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {VD.root_valid(E48.eview(_), S.ListOf{S.ByteVector{48n}, L}) == True{} : Bool}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {VD.root_valid(S.Sequence{E48.eitems(E48.k48(N), F.array__slots(U32, _), 0n)}, S.ListOf{S.ByteVector{48n}, L}) == True{} : Bool}
  %Equal.sym(Bool, VD.root_valid(E48.eitems(E48.k48(N), F.array__slots(U32, t), 0n), S.Repeat{S.ByteVector{48n}}), True{}, evalid(E48.k48(N), F.array__slots(U32, t), 0n)) :
    {Bool.and(Nat.is_le(VD.items_length(E48.eitems(E48.k48(N), F.array__slots(U32, t), 0n)), L), _) == True{} : Bool}
  %Equal.sym(Nat, VD.items_length(E48.eitems(E48.k48(N), F.array__slots(U32, t), 0n)), E48.k48(N), elen(E48.k48(N), F.array__slots(U32, t), 0n)) :
    {Bool.and(Nat.is_le(_, L), True{}) == True{} : Bool}
  %Equal.sym(Bool, Nat.is_le(E48.k48(N), L), True{}, hvN) : {Bool.and(_, True{}) == True{} : Bool}
  {==}

# ---- cells (2048 bytes) -------------------------------------------------------------

law clen:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {VD.items_length(CE.citems(k, W, i)) == k : Nat}
def clen(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, VD.items_length(CE.citems(q, W, 1n+i)), q, clen(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}

def cone(+W: List<&2, U32>, +j: Nat,
    +cap: {Nat.is_le(O.e8(Nat.add(64n, Nat.mul(j, 64n))), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {VD.root_valid(S.BytesValue{CE.cbytes(W, j)}, S.ByteVector{2048n}) == True{} : Bool}:
  %Equal.sym(Bool, SP.byte_scope(Nat.add(WS.e32(63n), 32n), CE.cbytes(W, j)), True{}, WS.chunk_scope(63n, 32n, W, Nat.mul(j, 64n), {==}, cap)) :
    {_ == True{} : Bool}
  {==}

law cvalid:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +cap: {Nat.is_le(Nat.mul(Nat.add(k, i), 512n), F.spec_common__length(U32, W)) == True{} : Bool}
  {VD.root_valid(CE.citems(k, W, i), S.Repeat{S.ByteVector{2048n}}) == True{} : Bool}
def cvalid(k, W, i, cap):
  match k:
    case 0n: {==}
    case 1n+ +q:
      +len = F.spec_common__length(U32, W)
      +le1 = AR.le_skip(q, i)
      +capm = F.nat__le_trans(Nat.mul(1n+i, 512n), Nat.mul(Nat.add(1n+q, i), 512n), len, EL.mul_le_left(1n+i, Nat.add(1n+q, i), 512n, le1), cap)
      +capi = CE.rw_le(Nat.mul(1n+i, 512n), O.e8(Nat.add(64n, Nat.mul(i, 64n))), len, CE.mul_e8(1n+i), capm)
      +capq = CE.rw_le(Nat.mul(Nat.add(1n+q, i), 512n), Nat.mul(Nat.add(q, 1n+i), 512n), len,
        Equal.cong(Nat, Nat, x => Nat.mul(x, 512n), Nat.add(1n+q, i), Nat.add(q, 1n+i), Equal.sym(Nat, Nat.add(q, 1n+i), 1n+Nat.add(q, i), MR.add_succ(q, i))), cap)
      %Equal.sym(Bool, VD.root_valid(S.BytesValue{CE.cbytes(W, i)}, S.ByteVector{2048n}), True{}, cone(W, i, capi)) :
        {Bool.and(_, VD.root_valid(CE.citems(q, W, 1n+i), S.Repeat{S.ByteVector{2048n}})) == True{} : Bool}
      cvalid(q, W, 1n+i, capq)

def kc_eq(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ns: {Nat.is_eq(CE.kc(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_eq(CE.kc(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(CE.kc(_), L) == True{} : Bool}
  ns

def kc_le(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hv: {Nat.is_le(CE.kc(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_le(CE.kc(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(CE.kc(_), L) == True{} : Bool}
  hv

# A list of cells (cells rep_el / ok_el).
def vcl(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: CE.rep_el(o, s), +ok: {CE.ok_el(s, depth) == True{} : Bool})
    -> {VD.root_valid(CE.eview(o), s) == True{} : Bool}:
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  +E = SH.ListOf_element(s)
  +L = SH.ListOf_limit(s)
  +k0 = DK.and_l(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 2048n), Lim.minimal(L, depth))), ok)
  +r1 = DK.and_r(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 2048n), Lim.minimal(L, depth))), ok)
  +k1 = DK.and_l(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 2048n), Lim.minimal(L, depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(E), Bool.and(Nat.is_eq(SH.ByteVector_length(E), 2048n), Lim.minimal(L, depth)), r1)
  +k2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(E), 2048n), Lim.minimal(L, depth), r2)
  +hvN = kc_le(o, t, N, L, eo, hv)
  +cap = CE.ccap(CE.kc(N), dw, t, pf, room)
  %Equal.sym(S.Schema, s, S.ListOf{E, L}, SH.ListOf_shape(s, k0)) :
    {VD.root_valid(CE.eview(o), _) == True{} : Bool}
  %Equal.sym(S.Schema, E, S.ByteVector{SH.ByteVector_length(E)}, SH.ByteVector_shape(E, k1)) :
    {VD.root_valid(CE.eview(o), S.ListOf{_, L}) == True{} : Bool}
  %Equal.sym(Nat, SH.ByteVector_length(E), 2048n, WS.nat_eq(SH.ByteVector_length(E), 2048n, k2)) :
    {VD.root_valid(CE.eview(o), S.ListOf{S.ByteVector{_}, L}) == True{} : Bool}
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {VD.root_valid(CE.eview(_), S.ListOf{S.ByteVector{2048n}, L}) == True{} : Bool}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {VD.root_valid(S.Sequence{CE.citems(CE.kc(N), F.array__slots(U32, _), 0n)}, S.ListOf{S.ByteVector{2048n}, L}) == True{} : Bool}
  %Equal.sym(Bool, VD.root_valid(CE.citems(CE.kc(N), F.array__slots(U32, t), 0n), S.Repeat{S.ByteVector{2048n}}), True{}, cvalid(CE.kc(N), F.array__slots(U32, t), 0n, cap)) :
    {Bool.and(Nat.is_le(VD.items_length(CE.citems(CE.kc(N), F.array__slots(U32, t), 0n)), L), _) == True{} : Bool}
  %Equal.sym(Nat, VD.items_length(CE.citems(CE.kc(N), F.array__slots(U32, t), 0n)), CE.kc(N), clen(CE.kc(N), F.array__slots(U32, t), 0n)) :
    {Bool.and(Nat.is_le(_, L), True{}) == True{} : Bool}
  %Equal.sym(Bool, Nat.is_le(CE.kc(N), L), True{}, hvN) : {Bool.and(_, True{}) == True{} : Bool}
  {==}
