import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./ctree.bend as CT
import ./cidx.bend as CX

# The runtime's U32 loops of the cached Merkle tree (BeaconState.validators,
# types/fulu_obj.bend) on the heap model of ctree.bend: a node array that is
# the thawed tree t of depth 1 + d, a node index j whose value is the heap
# position hp(d, 1 + L, i) of node i of level 1 + L. With level L complete, the
# runtime's node step writes that node's value mv, i.e. it is ctree's model
# write, and the runtime's level loop is ctree's mlevel_t. The depth bound
# d < 31 keeps every heap index below 2^(1 + d) <= 2^31, so no U32 operation
# wraps.

def le_of_succ(+L: Nat, +d: Nat, +hL: {Nat.is_le(1n+L, d) == True{} : Bool}) -> {Nat.is_le(L, d) == True{} : Bool}:
  F.nat__le_trans(L, 1n+L, d, F.nat__le_succ(L), hL)

def lt63(+L: Nat, +d: Nat, +hL: {Nat.is_le(1n+L, d) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool})
    -> {Nat.is_lt(L, 63n) == True{} : Bool}:
  F.nat__lt_le_trans(L, 31n, 63n, F.nat__le_lt_trans(L, d, 31n, le_of_succ(L, d, hL), hd), {==})

# ---- heap positions of the children ------------------------------------------------------

# 2 (2^(d - (1 + L)) + i) = 2^(d - L) + 2i.
def dbl_hp(+d: Nat, +L: Nat, +i: Nat, +hL: {Nat.is_le(1n+L, d) == True{} : Bool})
    -> {Nat.double(CT.hp(d, 1n+L, i)) == CT.hp(d, L, Nat.double(i)) : Nat}:
  %Equal.sym(Nat, Nat.sub(d, L), 1n+Nat.sub(d, 1n+L), CT.sub_succ(d, L, hL)) :
    {Nat.double(CT.hp(d, 1n+L, i)) == Nat.add(O.pow2n(_), Nat.double(i)) : Nat}
  CT.dbl_add(O.pow2n(Nat.sub(d, 1n+L)), i)

def dlt(+d: Nat, +L: Nat, +i: Nat, +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool})
    -> {Nat.is_lt(Nat.double(i), O.pow2n(Nat.sub(d, L))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.sub(d, L), 1n+Nat.sub(d, 1n+L), CT.sub_succ(d, L, hL)) : {Nat.is_lt(Nat.double(i), O.pow2n(_)) == True{} : Bool}
  F.nat__double_lt(i, O.pow2n(Nat.sub(d, 1n+L)), hi)

def dlt1(+d: Nat, +L: Nat, +i: Nat, +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool})
    -> {Nat.is_lt(1n+Nat.double(i), O.pow2n(Nat.sub(d, L))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.sub(d, L), 1n+Nat.sub(d, 1n+L), CT.sub_succ(d, L, hL)) : {Nat.is_lt(1n+Nat.double(i), O.pow2n(_)) == True{} : Bool}
  F.nat__double_lt_bit(True{}, i, O.pow2n(Nat.sub(d, 1n+L)), hi)

# hp(d, L, x) + 1 = hp(d, L, 1 + x).
def hp_succ(+d: Nat, +L: Nat, +x: Nat) -> {Nat.add(CT.hp(d, L, x), 1n) == CT.hp(d, L, 1n+x) : Nat}:
  %Equal.sym(Nat, Nat.add(O.pow2n(Nat.sub(d, L)), 1n+x), 1n+Nat.add(O.pow2n(Nat.sub(d, L)), x), MR.add_succ(O.pow2n(Nat.sub(d, L)), x)) :
    {Nat.add(CT.hp(d, L, x), 1n) == _ : Nat}
  CX.NA_add1(CT.hp(d, L, x))

def b2j(+j: U32, +d: Nat, +L: Nat, +i: Nat,
    +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat},
    +e1: {Nat.double(CT.hp(d, 1n+L, i)) == CT.hp(d, L, Nat.double(i)) : Nat},
    +bnd: {Nat.is_lt(CT.hp(d, L, Nat.double(i)), O.pow2n(1n+d)) == True{} : Bool})
    -> {Nat.is_lt(Nat.double(U32.to_nat(j)), O.pow2n(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(j), CT.hp(d, 1n+L, i), ej) : {Nat.is_lt(Nat.double(_), O.pow2n(1n+d)) == True{} : Bool}
  %Equal.sym(Nat, Nat.double(CT.hp(d, 1n+L, i)), CT.hp(d, L, Nat.double(i)), e1) : {Nat.is_lt(_, O.pow2n(1n+d)) == True{} : Bool}
  bnd

# The left child 2j is at hp(d, L, 2i).
def c2j(+j: U32, +d: Nat, +L: Nat, +i: Nat,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool},
    +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat})
    -> {U32.to_nat((2 * j : U32)) == CT.hp(d, L, Nat.double(i)) : Nat}:
  +e1 = dbl_hp(d, L, i, hL)
  +b = b2j(j, d, L, i, ej, e1, CT.hp_lt(d, L, Nat.double(i), le_of_succ(L, d, hL), dlt(d, L, i, hL, hi)))
  %Equal.sym(Nat, U32.to_nat((2 * j : U32)), Nat.double(U32.to_nat(j)), CX.dbl_val(j, 1n+d, hd, b)) : {_ == CT.hp(d, L, Nat.double(i)) : Nat}
  %Equal.sym(Nat, U32.to_nat(j), CT.hp(d, 1n+L, i), ej) : {Nat.double(_) == CT.hp(d, L, Nat.double(i)) : Nat}
  e1

def b2j1(+j: U32, +d: Nat, +L: Nat, +i: Nat,
    +e2: {U32.to_nat((2 * j : U32)) == CT.hp(d, L, Nat.double(i)) : Nat},
    +bnd: {Nat.is_lt(CT.hp(d, L, 1n+Nat.double(i)), O.pow2n(1n+d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat((2 * j : U32)), U32.to_nat(1)), O.pow2n(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((2 * j : U32)), CT.hp(d, L, Nat.double(i)), e2) : {Nat.is_le(Nat.add(_, 1n), O.pow2n(1n+d)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(CT.hp(d, L, Nat.double(i)), 1n), CT.hp(d, L, 1n+Nat.double(i)), hp_succ(d, L, Nat.double(i))) :
    {Nat.is_le(_, O.pow2n(1n+d)) == True{} : Bool}
  F.nat__lt_le(CT.hp(d, L, 1n+Nat.double(i)), O.pow2n(1n+d), bnd)

# The right child 2j + 1 is at hp(d, L, 2i + 1).
def c2j1(+j: U32, +d: Nat, +L: Nat, +i: Nat,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool},
    +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat})
    -> {U32.to_nat((2 * j + 1 : U32)) == CT.hp(d, L, 1n+Nat.double(i)) : Nat}:
  +e2 = c2j(j, d, L, i, hd, hL, hi, ej)
  +h = b2j1(j, d, L, i, e2, CT.hp_lt(d, L, 1n+Nat.double(i), le_of_succ(L, d, hL), dlt1(d, L, i, hL, hi)))
  %Equal.sym(Nat, U32.to_nat(U32.add((2 * j : U32), 1)), Nat.add(U32.to_nat((2 * j : U32)), U32.to_nat(1)), CX.add_nat((2 * j : U32), 1, 1n+d, hd, h)) :
    {_ == CT.hp(d, L, 1n+Nat.double(i)) : Nat}
  %Equal.sym(Nat, U32.to_nat((2 * j : U32)), CT.hp(d, L, Nat.double(i)), e2) : {Nat.add(_, 1n) == CT.hp(d, L, 1n+Nat.double(i)) : Nat}
  hp_succ(d, L, Nat.double(i))

# The next node j + 1 is at hp(d, 1 + L, 1 + i).
def bnext(+j: U32, +d: Nat, +L: Nat, +i: Nat,
    +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat},
    +bnd: {Nat.is_lt(CT.hp(d, 1n+L, i), O.pow2n(1n+d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(j), U32.to_nat(1)), O.pow2n(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(j), CT.hp(d, 1n+L, i), ej) : {Nat.is_le(Nat.add(_, 1n), O.pow2n(1n+d)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(CT.hp(d, 1n+L, i), 1n), 1n+CT.hp(d, 1n+L, i), CX.NA_add1(CT.hp(d, 1n+L, i))) : {Nat.is_le(_, O.pow2n(1n+d)) == True{} : Bool}
  F.nat__lt_succ_le_succ(CT.hp(d, 1n+L, i), O.pow2n(1n+d), bnd)

def cnext(+j: U32, +d: Nat, +L: Nat, +i: Nat,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool},
    +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat})
    -> {U32.to_nat((j + 1 : U32)) == CT.hp(d, 1n+L, 1n+i) : Nat}:
  +h = bnext(j, d, L, i, ej, CT.hp_lt(d, 1n+L, i, hL, hi))
  %Equal.sym(Nat, U32.to_nat(U32.add(j, 1)), Nat.add(U32.to_nat(j), U32.to_nat(1)), CX.add_nat(j, 1, 1n+d, hd, h)) :
    {_ == CT.hp(d, 1n+L, 1n+i) : Nat}
  %Equal.sym(Nat, U32.to_nat(j), CT.hp(d, 1n+L, i), ej) : {Nat.add(_, 1n) == CT.hp(d, 1n+L, 1n+i) : Nat}
  hp_succ(d, 1n+L, i)

# ---- reads and writes of the node array --------------------------------------------------------

def lt_at(+x: Nat, +y: Nat, +k: Nat, +e: {x == y : Nat}, +h: {Nat.is_lt(y, O.pow2n(k)) == True{} : Bool})
    -> {Nat.is_lt(x, F.spec_common__pow2(k)) == True{} : Bool}:
  %Equal.sym(Nat, x, y, e) : {Nat.is_lt(_, F.spec_common__pow2(k)) == True{} : Bool}
  CX.rw_pow_lt(y, k, h)

def nth_at(+NS: List<&2, D.Digest>, +x: Nat, +y: Nat, +v: D.Digest, +e: {x == y : Nat},
    +h: {F.spec_common__nth(D.Digest, NS, y) == Some{v} : Maybe<&2, D.Digest>})
    -> {F.spec_common__nth(D.Digest, NS, x) == Some{v} : Maybe<&2, D.Digest>}:
  %Equal.sym(Nat, x, y, e) : {F.spec_common__nth(D.Digest, NS, _) == Some{v} : Maybe<&2, D.Digest>}
  h

# A store at an index inside the tree: whatever the slot held.
def set_any(+d: Nat, +t: F.array__Tree<D.Digest>, +i: U32, +v: D.Digest,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, d, t) == True{} : Bool},
    +m: Maybe<&2, D.Digest>,
    +em: {F.spec_common__nth(D.Digest, F.array__slots(D.Digest, t), U32.to_nat(i)) == m : Maybe<&2, D.Digest>})
    -> {Array.set(D.Digest, F.array__thaw(D.Digest, t), i, v) == F.array__thaw(D.Digest, F.array__upd(D.Digest, d, t, U32.to_nat(i), v)) : Array<D.Digest>}:
  match m:
    case Some{+x}: F.array__set(D.Digest, d, t, i, v, x, hd, hi, em, pf)
    case None{}:
      Empty.absurd({Array.set(D.Digest, F.array__thaw(D.Digest, t), i, v) == F.array__thaw(D.Digest, F.array__upd(D.Digest, d, t, U32.to_nat(i), v)) : Array<D.Digest>},
        F.list__sc_nth_some(D.Digest, F.array__slots(D.Digest, t), U32.to_nat(i), F.array__len_lt(D.Digest, d, t, U32.to_nat(i), pf, hi), em))

def set_rw(+d: Nat, +t: F.array__Tree<D.Digest>, +j: U32, +k: Nat, +v: D.Digest,
    +ej: {U32.to_nat(j) == k : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, d, t) == True{} : Bool})
    -> {Array.set(D.Digest, F.array__thaw(D.Digest, t), j, v) == F.array__thaw(D.Digest, F.array__upd(D.Digest, d, t, k, v)) : Array<D.Digest>}:
  %ej : {Array.set(D.Digest, F.array__thaw(D.Digest, t), j, v) == F.array__thaw(D.Digest, F.array__upd(D.Digest, d, t, _, v)) : Array<D.Digest>}
  set_any(d, t, j, v, hd, hi, pf, F.spec_common__nth(D.Digest, F.array__slots(D.Digest, t), U32.to_nat(j)), {==})

# ---- one node ------------------------------------------------------------------------

# The runtime's node step at j = hp(d, 1 + L, i), level L complete: the model write.
def cnode(+d: Nat, +L: Nat, +i: Nat, +j: U32, +n: Nat, +XL: List<&2, D.Digest>, +t: F.array__Tree<D.Digest>,
    -arr: Array<FuluValidator_d.Validator>, -h: B.Buf,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool},
    +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat},
    +en: {MD.dlen(XL) == n : Nat},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +lv: CT.lvl_ok(F.array__slots(D.Digest, t), d, L, n, XL))
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_node_step(64n, j, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)})
        == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), CT.mv(64n, 1n+L, i, n, XL)))}
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}:
  +hL0 = le_of_succ(L, d, hL)
  +e2 = c2j(j, d, L, i, hd, hL, hi, ej)
  +e3 = c2j1(j, d, L, i, hd, hL, hi, ej)
  +dl = CT.mv(64n, L, Nat.double(i), n, XL)
  +dr = CT.mv(64n, L, 1n+Nat.double(i), n, XL)
  +v = CT.mv(64n, 1n+L, i, n, XL)
  +hle = lt_at(U32.to_nat((2 * j : U32)), CT.hp(d, L, Nat.double(i)), 1n+d, e2, CT.hp_lt(d, L, Nat.double(i), hL0, dlt(d, L, i, hL, hi)))
  +hr = lt_at(U32.to_nat((2 * j + 1 : U32)), CT.hp(d, L, 1n+Nat.double(i)), 1n+d, e3, CT.hp_lt(d, L, 1n+Nat.double(i), hL0, dlt1(d, L, i, hL, hi)))
  +hx = nth_at(F.array__slots(D.Digest, t), U32.to_nat((2 * j : U32)), CT.hp(d, L, Nat.double(i)), dl, e2, CT.lvl_get(F.array__slots(D.Digest, t), d, L, n, XL, lv, Nat.double(i), dlt(d, L, i, hL, hi)))
  +hy = nth_at(F.array__slots(D.Digest, t), U32.to_nat((2 * j + 1 : U32)), CT.hp(d, L, 1n+Nat.double(i)), dr, e3, CT.lvl_get(F.array__slots(D.Digest, t), d, L, n, XL, lv, 1n+Nat.double(i), dlt1(d, L, i, hL, hi)))
  +hj = lt_at(U32.to_nat(j), CT.hp(d, 1n+L, i), 1n+d, ej, CT.hp_lt(d, 1n+L, i, hL, hi))
  # the two reads (as in cache.bend's validators_node_hashes)
  %Equal.sym(Array<D.Digest> & D.Digest, Array.get(D.Digest, F.array__thaw(D.Digest, t), (2 * j : U32)),
      (F.array__thaw(D.Digest, t), dl), F.array__get(D.Digest, 1n+d, t, (2 * j : U32), dl, hd, hle, hx, pf)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_node_go(64n, j, h, arr, _) == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
  %Equal.sym(Array<D.Digest> & D.Digest, Array.get(D.Digest, F.array__thaw(D.Digest, t), (2 * j + 1 : U32)),
      (F.array__thaw(D.Digest, t), dr), F.array__get(D.Digest, 1n+d, t, (2 * j + 1 : U32), dr, hd, hr, hy, pf)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_node_fin(64n, j, h, arr, dl, _) == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
  %Equal.sym(D.Digest, D.node(64n, dl, dr), v, CT.node_rule(L, i, n, XL, en, lt63(L, d, hL, hd))) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, Array.set(D.Digest, F.array__thaw(D.Digest, t), j, _)} == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
  %Equal.sym(Array<D.Digest>, Array.set(D.Digest, F.array__thaw(D.Digest, t), j, v), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v)),
      set_rw(1n+d, t, j, CT.hp(d, 1n+L, i), v, ej, hd, hj, pf)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, _} == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
  {==}

# ---- one level ------------------------------------------------------------------------

# The written tree's slots: level L stays complete under a write at level 1 + L.
def lv_keep(+d: Nat, +L: Nat, +i: Nat, +n: Nat, +XL: List<&2, D.Digest>, +t: F.array__Tree<D.Digest>,
    +hL: {Nat.is_le(1n+L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +lv: CT.lvl_ok(F.array__slots(D.Digest, t), d, L, n, XL))
    -> CT.lvl_ok(F.array__slots(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), CT.mv(64n, 1n+L, i, n, XL))), d, L, n, XL):
  +v = CT.mv(64n, 1n+L, i, n, XL)
  %Equal.sym(List<&2, D.Digest>, F.array__slots(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v)),
      F.spec_common__update(D.Digest, F.array__slots(D.Digest, t), CT.hp(d, 1n+L, i), v),
      F.array__upd_slots(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v, CT.hp_lt2(d, 1n+L, i, hL, hi), pf)) :
    CT.lvl_ok(_, d, L, n, XL)
  CT.lv_wo(O.pow2n(Nat.sub(d, L)), F.array__slots(D.Digest, t), d, n, XL, 1n+L, i, L, 0n, CT.ne_below(L, L, F.nat__le_refl(L)), hL, hi, le_of_succ(L, d, hL),
    F.nat__le_refl(O.pow2n(Nat.sub(d, L))), lv)

# The runtime's loop over q nodes of level 1 + L from j = hp(d, 1 + L, i) is mlevel_t.
law clevel:
  for +q: Nat
  for +d: Nat
  for +L: Nat
  for +i: Nat
  for +j: U32
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +t: F.array__Tree<D.Digest>
  for -arr: Array<FuluValidator_d.Validator>
  for -h: B.Buf
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hL: {Nat.is_le(1n+L, d) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(i, q), O.pow2n(Nat.sub(d, 1n+L))) == True{} : Bool}
  for +ej: {U32.to_nat(j) == CT.hp(d, 1n+L, i) : Nat}
  for +en: {MD.dlen(XL) == n : Nat}
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  for +lv: CT.lvl_ok(F.array__slots(D.Digest, t), d, L, n, XL)
  {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_level(64n, q, j, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)})
   == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, CT.mlevel_t(q, i, d, n, XL, 1n+L, t))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
def clevel(q, d, L, i, j, n, XL, t, arr, h, hd, hL, hq, ej, en, pf, lv):
  match q:
    case 0n: {==}
    case 1n+ +r:
      +hi = CT.step_lt(i, r, O.pow2n(Nat.sub(d, 1n+L)), hq)
      +v = CT.mv(64n, 1n+L, i, n, XL)
      +t1 = F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v)
      %Equal.sym(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_node_step(64n, j, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)}),
          Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t1)},
          cnode(d, L, i, j, n, XL, t, arr, h, hd, hL, hi, ej, en, pf, lv)) :
        {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_level(64n, r, (j + 1 : U32), _)
         == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, CT.mlevel_t(r, 1n+i, d, n, XL, 1n+L, t1))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
      clevel(r, d, L, 1n+i, (j + 1 : U32), n, XL, t1, arr, h, hd, hL,
        CT.step_le(i, r, O.pow2n(Nat.sub(d, 1n+L)), hq),
        cnext(j, d, L, i, hd, hL, hi, ej), en,
        F.array__upd_perfect(D.Digest, 1n+d, t, CT.hp(d, 1n+L, i), v, pf),
        lv_keep(d, L, i, n, XL, t, hL, hi, pf, lv))
