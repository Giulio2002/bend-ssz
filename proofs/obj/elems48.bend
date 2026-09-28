import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/codec.bend as Codec
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_obj_light.bend as WO
import ./list_root.bend as LR
import ./elems_obj.bend as EL
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./root_names.bend as RN
import ./root_names_light.bend as RN_L
import ./elems48_light.bend as LV

# Vectors and lists of Bytes48 packed in words (12 words per element): each
# element's root is the Bytes48 record law of phase A (proofs/obj/root_names.bend
# rs_b48) on the record of its twelve words; the runtime trees are
# proofs/obj/elems_obj.bend's.

def er48(+W: List<&2, U32>, +i: Nat, +hl: Nat) -> {EL.er(W, i, 12n, 1n, 2n, hl) == RN.d_b48(hl, LV.rec48(W, Nat.mul(i, 12n))) : D.Digest}: {==}

def elem48(+W: List<&2, U32>, +i: Nat, +hl: Nat, +ehl: {hl == 64n : Nat})
    -> RR.roots(RN_L.v_b48(LV.rec48(W, Nat.mul(i, 12n))), S.ByteVector{48n}, [D.bytes(EL.er(W, i, 12n, 1n, 2n, hl))]):
  %Equal.sym(D.Digest, EL.er(W, i, 12n, 1n, 2n, hl), RN.d_b48(hl, LV.rec48(W, Nat.mul(i, 12n))), er48(W, i, hl)) :
    RR.roots(RN_L.v_b48(LV.rec48(W, Nat.mul(i, 12n))), S.ByteVector{48n}, [D.bytes(_)])
  RN.rs_b48(hl, ehl, LV.rec48(W, Nat.mul(i, 12n)))

law eroots:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  RR.roots(LV.eitems(k, W, i), S.Repeat{S.ByteVector{48n}}, MD.bytes_list(EL.elist(k, W, i, 12n, 1n, 2n, hl)))
def eroots(k, W, i, hl, ehl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      ([D.bytes(EL.er(W, i, 12n, 1n, 2n, hl))], (MD.bytes_list(EL.elist(q, W, 1n+i, 12n, 1n, 2n, hl)), (elem48(W, i, hl, ehl), (eroots(q, W, 1n+i, hl, ehl), {==}))))

law ecount:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {Codec.count(LV.eitems(k, W, i)) == k : Nat}
def ecount(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Codec.count(LV.eitems(q, W, 1n+i)), q, ecount(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}

# ---- the object -------------------------------------------------------------------

def edig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: MD.rtree(depth, Nat.is_lt(0n, LV.k48(n)), hl, EL.elist(LV.k48(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n, 12n, 1n, 2n, hl), 0n)

def ldig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, LV.k48(n)), hl, EL.elist(LV.k48(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n, 12n, 1n, 2n, hl), 0n), U32.div(n, 48))

# The runtime root of the packed elements (O.elems_root, no length).
def ev_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wfe(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.elems_root(hl, h, o, 12, 1, dU, seg) == (h, (o, edig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {O.elems_root(hl, h, _, 12, 1, dU, seg) == (h, (_, edig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(dU), depth, edu) :
    {O.mt_words(N, O.mtree(_, 0n, Nat.is_lt(0n, LV.k48(N)), hl, O.LElems{12n, 1n, 2n}, O.pow2n(_), 0n, LV.k48(N), (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, edig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(depth, 0n, Nat.is_lt(0n, LV.k48(N)), hl, O.LElems{12n, 1n, 2n}, O.pow2n(depth), 0n, LV.k48(N), (h, (F.array__thaw(U32, t), D.zero()))),
      (h, (F.array__thaw(U32, t), MD.rtree(depth, Nat.is_lt(0n, LV.k48(N)), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n))),
      EL.mt_elems(depth, Nat.is_lt(0n, LV.k48(N)), hl, dw, t, 12n, 1n, 2n, 0n, LV.k48(N), h, D.zero(), {==}, hd, pf, room)) :
    {O.mt_words(N, _) == (h, (O.Words{F.array__thaw(U32, t), N}, edig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, LV.k48(N)), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, LV.k48(N)), hl, EL.elist(LV.k48(N), F.array__slots(U32, _), 0n, 12n, 1n, 2n, hl), 0n))) : B.Buf & (O.Words & D.Digest)}
  {==}

def klen(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ks: {Nat.is_eq(LV.k48(WO.len(o)), K) == True{} : Bool}) -> {Nat.is_eq(LV.k48(N), K) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(LV.k48(_), K) == True{} : Bool}
  ks

def keq(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ks: {Nat.is_eq(LV.k48(WO.len(o)), K) == True{} : Bool}) -> {LV.k48(N) == K : Nat}:
  WS.nat_eq(LV.k48(N), K, klen(o, t, N, K, eo, ks))

def kle(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hv: {Nat.is_le(LV.k48(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_le(LV.k48(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(LV.k48(_), L) == True{} : Bool}
  hv

def hlen_k(+K: Nat, +L: Nat, +W: List<&2, U32>, +hl: Nat, +hv: {Nat.is_le(K, L) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(EL.elist(K, W, 0n, 12n, 1n, 2n, hl)), L) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(EL.elist(K, W, 0n, 12n, 1n, 2n, hl)), K, EL.elist_len(K, W, 0n, 12n, 1n, 2n, hl)) : {Nat.is_le(_, L) == True{} : Bool}
  hv

def minK(+K: Nat, +K2: Nat, +depth: Nat, +e: {K == K2 : Nat}, +hm: {Lim.minimal(K2, depth) == True{} : Bool}) -> {Lim.minimal(K, depth) == True{} : Bool}:
  %Equal.sym(Nat, K, K2, e) : {Lim.minimal(_, depth) == True{} : Bool}
  hm

# A vector of Bytes48: its digest is a specification root of its elements.
def ev_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: LV.rep_ev(o, s),
    +ok: {LV.ok_ev(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(LV.eview(o), s, [D.bytes(edig(hl, o, depth))]):
  (+wf, +ks) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  +c0 = DK.and_l(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +r1 = DK.and_r(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +c1 = DK.and_l(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +c2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth), r2)
  +c3 = DK.and_r(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n), Lim.minimal(SH.Vector_length(s), depth), r2)
  +kK = keq(o, t, N, SH.Vector_length(s), eo, ks)
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, c0)) :
    RR.roots(LV.eview(o), _, [D.bytes(edig(hl, o, depth))])
  %Equal.sym(S.Schema, SH.Vector_element(s), S.ByteVector{SH.ByteVector_length(SH.Vector_element(s))}, SH.ByteVector_shape(SH.Vector_element(s), c1)) :
    RR.roots(LV.eview(o), S.Vector{_, SH.Vector_length(s)}, [D.bytes(edig(hl, o, depth))])
  %Equal.sym(Nat, SH.ByteVector_length(SH.Vector_element(s)), 48n, WS.nat_eq(SH.ByteVector_length(SH.Vector_element(s)), 48n, c2)) :
    RR.roots(LV.eview(o), S.Vector{S.ByteVector{_}, SH.Vector_length(s)}, [D.bytes(edig(hl, o, depth))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(LV.eview(_), S.Vector{S.ByteVector{48n}, SH.Vector_length(s)}, [D.bytes(edig(hl, _, depth))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.Sequence{LV.eitems(LV.k48(N), F.array__slots(U32, _), 0n)}, S.Vector{S.ByteVector{48n}, SH.Vector_length(s)}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, LV.k48(N)), hl, EL.elist(LV.k48(N), F.array__slots(U32, _), 0n, 12n, 1n, 2n, hl), 0n))])
  %kK :
    RR.roots(S.Sequence{LV.eitems(LV.k48(N), F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{48n}, _}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, LV.k48(N)), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n))])
  %EL.elist_len(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl) :
    RR.roots(S.Sequence{LV.eitems(LV.k48(N), F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{48n}, LV.k48(N)}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, _), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n))])
  (MD.bytes_list(EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl)), (eroots(LV.k48(N), F.array__slots(U32, t), 0n, hl, ehl),
    RS.aggregate_digests(LV.k48(N), depth, hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), hdep, minK(LV.k48(N), SH.Vector_length(s), depth, kK, c3),
      hlen_k(LV.k48(N), LV.k48(N), F.array__slots(U32, t), hl, WS.le_refl(LV.k48(N))), ehl)))

def elen48(+hl: Nat, +ehl: {hl == 64n : Nat}, +N: U32, +R: D.Digest, +W: List<&2, U32>)
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, Codec.count(LV.eitems(LV.k48(N), W, 0n)))) == Some{D.bytes(O.mix_len(hl, R, U32.div(N, 48)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, Codec.count(LV.eitems(LV.k48(N), W, 0n)), LV.k48(N), ecount(LV.k48(N), W, 0n)) :
    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, U32.div(N, 48)))} : Maybe<&2, +List<U32>>}
  LR.mix_bytes(hl, ehl, R, U32.div(N, 48))

# A list of Bytes48: its digest (the element tree with the count mixed in) is a
# specification root of its elements.
def el_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat,
    +rep: LV.rep_el(o, s),
    +ok: {LV.ok_el(s, depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(LV.eview(o), s, [D.bytes(ldig(hl, o, depth))]):
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  +c0 = DK.and_l(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth))), ok)
  +r1 = DK.and_r(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth))), ok)
  +c1 = DK.and_l(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth)), r1)
  +c2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth), r2)
  +c3 = DK.and_r(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n), Lim.minimal(SH.ListOf_limit(s), depth), r2)
  +hvN = kle(o, t, N, SH.ListOf_limit(s), eo, hv)
  %Equal.sym(S.Schema, s, S.ListOf{SH.ListOf_element(s), SH.ListOf_limit(s)}, SH.ListOf_shape(s, c0)) :
    RR.roots(LV.eview(o), _, [D.bytes(ldig(hl, o, depth))])
  %Equal.sym(S.Schema, SH.ListOf_element(s), S.ByteVector{SH.ByteVector_length(SH.ListOf_element(s))}, SH.ByteVector_shape(SH.ListOf_element(s), c1)) :
    RR.roots(LV.eview(o), S.ListOf{_, SH.ListOf_limit(s)}, [D.bytes(ldig(hl, o, depth))])
  %Equal.sym(Nat, SH.ByteVector_length(SH.ListOf_element(s)), 48n, WS.nat_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n, c2)) :
    RR.roots(LV.eview(o), S.ListOf{S.ByteVector{_}, SH.ListOf_limit(s)}, [D.bytes(ldig(hl, o, depth))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(LV.eview(_), S.ListOf{S.ByteVector{48n}, SH.ListOf_limit(s)}, [D.bytes(ldig(hl, _, depth))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.Sequence{LV.eitems(LV.k48(N), F.array__slots(U32, _), 0n)}, S.ListOf{S.ByteVector{48n}, SH.ListOf_limit(s)}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, LV.k48(N)), hl, EL.elist(LV.k48(N), F.array__slots(U32, _), 0n, 12n, 1n, 2n, hl), 0n), U32.div(N, 48)))])
  %EL.elist_len(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl) :
    RR.roots(S.Sequence{LV.eitems(LV.k48(N), F.array__slots(U32, t), 0n)}, S.ListOf{S.ByteVector{48n}, SH.ListOf_limit(s)}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n), U32.div(N, 48)))])
  (MD.bytes_list(EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl)), (eroots(LV.k48(N), F.array__slots(U32, t), 0n, hl, ehl),
    (D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl))), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n)),
     ((depth, (c3, RS.at_depth_tree(SH.ListOf_limit(s), depth, hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), hdep, hlen_k(LV.k48(N), SH.ListOf_limit(s), F.array__slots(U32, t), hl, hvN), ehl))),
      elen48(hl, ehl, N, MD.rtree(depth, Nat.is_lt(0n, MD.dlen(EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl))), hl, EL.elist(LV.k48(N), F.array__slots(U32, t), 0n, 12n, 1n, 2n, hl), 0n), F.array__slots(U32, t))))))
