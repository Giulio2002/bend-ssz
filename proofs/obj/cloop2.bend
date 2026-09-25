import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./cloop.bend as CL
import ./root_names.bend as RN

# The whole root sweep of the cached Merkle tree of BeaconState.validators on
# the heap model of ctree.bend. The leaf loop writes each dirty leaf's model
# value: the element's own root (root_names' d_Validator) inside the length and
# the zero chunk past it. The level loops then write each level's dirty range
# [rng(l, lo), rng(l, hi)], and the runtime's shifted heap indices
# (2^d + lo) >> l are the model's heap positions of that range. Together, the
# runtime sweep is ctree's msweep. `XL` is the element-root list:
# xl(n, W, 0, 64) is the roots of the first n elements of the item slots W.

# ---- the element-root list ------------------------------------------------------------------

def xat(W: List<&2, T.Validator>, +i: Nat) -> T.Validator:
  match W:
    case Nil{}: T.Validator_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat(t, j)

law xnth:
  for +W: List<&2, T.Validator>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(T.Validator, W)) == True{} : Bool}
  {F.spec_common__nth(T.Validator, W, i) == Some{xat(W, i)} : Maybe<&2, T.Validator>}
def xnth(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(T.Validator, Nil{}, i) == Some{xat(Nil{}, i)} : Maybe<&2, T.Validator>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: xnth(t, j, hi)

def xl(k: Nat, +W: List<&2, T.Validator>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: RN.d_Validator(hl, xat(W, i)) <> xl(q, W, 1n+i, hl)

law xlen:
  for +k: Nat
  for +W: List<&2, T.Validator>
  for +i: Nat
  for +hl: Nat
  {MD.dlen(xl(k, W, i, hl)) == k : Nat}
def xlen(k, W, i, hl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %xlen(q, W, 1n+i, hl) : {1n+MD.dlen(xl(q, W, 1n+i, hl)) == 1n+_ : Nat}
      {==}

law xat_at:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, T.Validator>
  for +i: Nat
  for +hl: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MD.dhead(MD.ddrop(s, xl(k, W, i, hl))) == RN.d_Validator(hl, xat(W, Nat.add(s, i))) : D.Digest}
def xat_at(s, k, W, i, hl, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, xl(0n, W, i, hl))) == RN.d_Validator(hl, xat(W, Nat.add(0n, i))) : D.Digest}, MD.false_true(e))
        case 1n+q: {==}
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(1n+p1, xl(0n, W, i, hl))) == RN.d_Validator(hl, xat(W, Nat.add(1n+p1, i))) : D.Digest}, MD.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p1, i) : {MD.dhead(MD.ddrop(p1, xl(q, W, 1n+i, hl))) == RN.d_Validator(hl, xat(W, _)) : D.Digest}
          xat_at(p1, q, W, 1n+i, hl, e)

# ---- the leaf loop ---------------------------------------------------------------------

def bpos(+i: U32, +d: Nat, +x: Nat,
    +ex: {U32.to_nat(i) == x : Nat},
    +ep: {U32.to_nat(O.pow2u(d)) == O.pow2n(d) : Nat},
    +hlt: {Nat.is_lt(CT.hp(d, 0n, x), O.pow2n(1n+d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(O.pow2u(d)), U32.to_nat(i)), O.pow2n(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(O.pow2u(d)), O.pow2n(d), ep) : {Nat.is_le(Nat.add(_, U32.to_nat(i)), O.pow2n(1n+d)) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(i), x, ex) : {Nat.is_le(Nat.add(O.pow2n(d), _), O.pow2n(1n+d)) == True{} : Bool}
  %F.nat__sub_zero(d) : {Nat.is_le(Nat.add(O.pow2n(_), x), O.pow2n(1n+d)) == True{} : Bool}
  F.nat__lt_le(CT.hp(d, 0n, x), O.pow2n(1n+d), hlt)

def hd32(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_lt(d, 32n) == True{} : Bool}:
  F.nat__lt_le_trans(d, 31n, 32n, hd, {==})

def hp0_lt(+d: Nat, +x: Nat, +hx: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool}) -> {Nat.is_lt(CT.hp(d, 0n, x), O.pow2n(1n+d)) == True{} : Bool}:
  CT.hp_lt(d, 0n, x, Order.zero_le(d), CT.lt_d0(d, x, hx))

# The leaf position 2^d + i.
def cpos(+i: U32, +d: Nat, +x: Nat,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +ex: {U32.to_nat(i) == x : Nat},
    +hx: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool})
    -> {U32.to_nat((O.pow2u(d) + i : U32)) == CT.hp(d, 0n, x) : Nat}:
  +ep = CX.pow2u_val(d, hd32(d, hd))
  +h = bpos(i, d, x, ex, ep, hp0_lt(d, x, hx))
  %Equal.sym(Nat, U32.to_nat(U32.add(O.pow2u(d), i)), Nat.add(U32.to_nat(O.pow2u(d)), U32.to_nat(i)), CX.add_nat(O.pow2u(d), i, 1n+d, hd, h)) :
    {_ == CT.hp(d, 0n, x) : Nat}
  %Equal.sym(Nat, U32.to_nat(O.pow2u(d)), O.pow2n(d), ep) : {Nat.add(_, U32.to_nat(i)) == CT.hp(d, 0n, x) : Nat}
  %Equal.sym(Nat, U32.to_nat(i), x, ex) : {Nat.add(O.pow2n(d), _) == CT.hp(d, 0n, x) : Nat}
  %Equal.sym(Nat, Nat.sub(d, 0n), d, F.nat__sub_zero(d)) : {Nat.add(O.pow2n(d), x) == Nat.add(O.pow2n(_), x) : Nat}
  {==}

# The next leaf index i + 1.
def bsucc(+i: U32, +d: Nat, +x: Nat, +ex: {U32.to_nat(i) == x : Nat}, +hx: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(i), U32.to_nat(1)), O.pow2n(d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(i), x, ex) : {Nat.is_le(Nat.add(_, 1n), O.pow2n(d)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(x, 1n), 1n+x, CX.NA_add1(x)) : {Nat.is_le(_, O.pow2n(d)) == True{} : Bool}
  F.nat__lt_succ_le_succ(x, O.pow2n(d), hx)

def csucc(+i: U32, +d: Nat, +x: Nat,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +ex: {U32.to_nat(i) == x : Nat},
    +hx: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool})
    -> {U32.to_nat((i + 1 : U32)) == 1n+x : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), Nat.add(U32.to_nat(i), U32.to_nat(1)), CX.add_nat(i, 1, d, hd32(d, hd), bsucc(i, d, x, ex, hx))) :
    {_ == 1n+x : Nat}
  %Equal.sym(Nat, U32.to_nat(i), x, ex) : {Nat.add(_, 1n) == 1n+x : Nat}
  CX.NA_add1(x)

def lt_items(+x: Nat, +N: Nat, +dw: Nat, +ta: F.array__Tree<T.Validator>,
    +pfa: {F.array__perfect(T.Validator, dw, ta) == True{} : Bool},
    +hin: {Nat.is_lt(x, N) == True{} : Bool},
    +hn: {Nat.is_le(N, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_lt(x, F.spec_common__length(T.Validator, F.array__slots(T.Validator, ta))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(T.Validator, F.array__slots(T.Validator, ta)), F.spec_common__pow2(dw), F.array__slots_length(T.Validator, dw, ta, pfa)) : {Nat.is_lt(x, _) == True{} : Bool}
  F.nat__lt_le_trans(x, N, F.spec_common__pow2(dw), hin, hn)

def ix_at(+i: U32, +x: Nat, +ex: {U32.to_nat(i) == x : Nat}, +W: List<&2, T.Validator>,
    +h: {F.spec_common__nth(T.Validator, W, x) == Some{xat(W, x)} : Maybe<&2, T.Validator>})
    -> {F.spec_common__nth(T.Validator, W, U32.to_nat(i)) == Some{xat(W, x)} : Maybe<&2, T.Validator>}:
  %Equal.sym(Nat, U32.to_nat(i), x, ex) : {F.spec_common__nth(T.Validator, W, _) == Some{xat(W, x)} : Maybe<&2, T.Validator>}
  h

def ix_lt(+i: U32, +x: Nat, +B: Nat, +ex: {U32.to_nat(i) == x : Nat}, +h: {Nat.is_lt(x, B) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(i), B) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(i), x, ex) : {Nat.is_lt(_, B) == True{} : Bool}
  h

# One leaf, inside (b = True) or past (b = False) the length.
def cleaf_b(+d: Nat, +dw: Nat, +ta: F.array__Tree<T.Validator>, +t: F.array__Tree<D.Digest>, +i: U32, +x: Nat, +N: Nat, +k: U32, +seg: U32, -h: B.Buf,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(T.Validator, dw, ta) == True{} : Bool},
    +hn: {Nat.is_le(N, F.spec_common__pow2(dw)) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +ex: {U32.to_nat(i) == x : Nat},
    +hx: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool},
    +ek: {U32.to_nat(k) == CT.hp(d, 0n, x) : Nat},
    +b: Bool, +eb: {Nat.is_lt(x, N) == b : Bool})
    -> {T.l1099511627776_Validator_leaf_step(64n, b, k, i, seg, T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t)})
        == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta),
             F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), MD.rtree(0n, b, 64n, xl(N, F.array__slots(T.Validator, ta), 0n, 64n), x)))}
        : T.l1099511627776_Validator_TS}:
  match b:
    case False{}:
      +hk = CL.lt_at(U32.to_nat(k), CT.hp(d, 0n, x), 1n+d, ek, hp0_lt(d, x, hx))
      %Equal.sym(Array<D.Digest>, Array.set(D.Digest, F.array__thaw(D.Digest, t), k, D.zero()), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), D.zero())),
          CL.set_rw(1n+d, t, k, CT.hp(d, 0n, x), D.zero(), ek, hd, hk, pf)) :
        {T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), _}
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), D.zconst(0n)))}
         : T.l1099511627776_Validator_TS}
      {==}
    case True{}:
      +hk = CL.lt_at(U32.to_nat(k), CT.hp(d, 0n, x), 1n+d, ek, hp0_lt(d, x, hx))
      +W = F.array__slots(T.Validator, ta)
      +v = xat(W, x)
      +dv = RN.d_Validator(64n, v)
      +hia = ix_lt(i, x, F.spec_common__pow2(dw), ex, F.nat__lt_le_trans(x, N, F.spec_common__pow2(dw), eb, hn))
      +hxa = ix_at(i, x, ex, W, xnth(W, x, lt_items(x, N, dw, ta, pfa, eb, hn)))
      %Equal.sym(Array<T.Validator> & T.Validator, Array.get(T.Validator, F.array__thaw(T.Validator, ta), i), (F.array__thaw(T.Validator, ta), v),
          F.array__get(T.Validator, dw, ta, i, v, hdw, hia, hxa, pfa)) :
        {T.l1099511627776_Validator_leaf_go(64n, k, seg, F.array__thaw(D.Digest, t), h, _)
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), MD.dhead(MD.ddrop(x, xl(N, W, 0n, 64n)))))}
         : T.l1099511627776_Validator_TS}
      %Equal.sym(B.Buf & D.Digest, T.Validator_root(64n, h, v, (seg + 64 : U32)), (h, dv), RN.st_Validator(64n, h, v, (seg + 64 : U32))) :
        {T.l1099511627776_Validator_leaf_fin(k, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t), _)
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), MD.dhead(MD.ddrop(x, xl(N, W, 0n, 64n)))))}
         : T.l1099511627776_Validator_TS}
      %Equal.sym(Array<D.Digest>, Array.set(D.Digest, F.array__thaw(D.Digest, t), k, dv), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), dv)),
          CL.set_rw(1n+d, t, k, CT.hp(d, 0n, x), dv, ek, hd, hk, pf)) :
        {T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), _}
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), MD.dhead(MD.ddrop(x, xl(N, W, 0n, 64n)))))}
         : T.l1099511627776_Validator_TS}
      %Equal.sym(D.Digest, MD.dhead(MD.ddrop(x, xl(N, W, 0n, 64n))), RN.d_Validator(64n, xat(W, Nat.add(x, 0n))), xat_at(x, N, W, 0n, 64n, eb)) :
        {T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), dv))}
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), _))}
         : T.l1099511627776_Validator_TS}
      %Equal.sym(Nat, Nat.add(x, 0n), x, F.nat__add_zero(x)) :
        {T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), dv))}
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), RN.d_Validator(64n, xat(W, _))))}
         : T.l1099511627776_Validator_TS}
      {==}

# One leaf step of the runtime: the model's write of leaf x (mv at level 0).
def cleaf(+d: Nat, +dw: Nat, +ta: F.array__Tree<T.Validator>, +t: F.array__Tree<D.Digest>, +i: U32, +x: Nat, +n: U32, +k: U32, +seg: U32, -h: B.Buf,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(T.Validator, dw, ta) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +ex: {U32.to_nat(i) == x : Nat},
    +hx: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool},
    +ek: {U32.to_nat(k) == CT.hp(d, 0n, x) : Nat})
    -> {T.l1099511627776_Validator_leaf_step(64n, U32.is_lt(i, n), k, i, seg, T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t)})
        == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta),
             F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), CT.mv(64n, 0n, x, U32.to_nat(n), xl(U32.to_nat(n), F.array__slots(T.Validator, ta), 0n, 64n))))}
        : T.l1099511627776_Validator_TS}:
  %Equal.sym(Bool, U32.is_lt(i, n), Nat.is_lt(U32.to_nat(i), U32.to_nat(n)), CX.lt_nat(i, n)) :
    {T.l1099511627776_Validator_leaf_step(64n, _, k, i, seg, T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t)})
     == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta),
          F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), CT.mv(64n, 0n, x, U32.to_nat(n), xl(U32.to_nat(n), F.array__slots(T.Validator, ta), 0n, 64n))))}
     : T.l1099511627776_Validator_TS}
  %Equal.sym(Nat, U32.to_nat(i), x, ex) :
    {T.l1099511627776_Validator_leaf_step(64n, Nat.is_lt(_, U32.to_nat(n)), k, i, seg, T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t)})
     == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta),
          F.array__thaw(D.Digest, F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), CT.mv(64n, 0n, x, U32.to_nat(n), xl(U32.to_nat(n), F.array__slots(T.Validator, ta), 0n, 64n))))}
     : T.l1099511627776_Validator_TS}
  cleaf_b(d, dw, ta, t, i, x, U32.to_nat(n), k, seg, h, hd, hdw, pfa, hn, pf, ex, hx, ek, Nat.is_lt(x, U32.to_nat(n)), {==})

# The runtime's leaf loop over q leaves from index i = x is mlevel_t at level 0.
law cleaves:
  for +q: Nat
  for +d: Nat
  for +dw: Nat
  for +ta: F.array__Tree<T.Validator>
  for +t: F.array__Tree<D.Digest>
  for +i: U32
  for +x: Nat
  for +n: U32
  for +seg: U32
  for -h: B.Buf
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pfa: {F.array__perfect(T.Validator, dw, ta) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool}
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  for +ex: {U32.to_nat(i) == x : Nat}
  for +hq: {Nat.is_le(Nat.add(x, q), O.pow2n(d)) == True{} : Bool}
  {T.l1099511627776_Validator_leaves(64n, q, i, n, seg, O.pow2u(d), T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t)})
   == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta),
        F.array__thaw(D.Digest, CT.mlevel_t(q, x, d, U32.to_nat(n), xl(U32.to_nat(n), F.array__slots(T.Validator, ta), 0n, 64n), 0n, t))}
   : T.l1099511627776_Validator_TS}
def cleaves(q, d, dw, ta, t, i, x, n, seg, h, hd, hdw, pfa, hn, pf, ex, hq):
  match q:
    case 0n: {==}
    case 1n+ +r:
      +XL = xl(U32.to_nat(n), F.array__slots(T.Validator, ta), 0n, 64n)
      +hx = CT.step_lt(x, r, O.pow2n(d), hq)
      +k = (O.pow2u(d) + i : U32)
      +v = CT.mv(64n, 0n, x, U32.to_nat(n), XL)
      +t1 = F.array__upd(D.Digest, 1n+d, t, CT.hp(d, 0n, x), v)
      %Equal.sym(T.l1099511627776_Validator_TS,
          T.l1099511627776_Validator_leaf_step(64n, U32.is_lt(i, n), k, i, seg, T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t)}),
          T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, t1)},
          cleaf(d, dw, ta, t, i, x, n, k, seg, h, hd, hdw, pfa, hn, pf, ex, hx, cpos(i, d, x, hd, ex, hx))) :
        {T.l1099511627776_Validator_leaves(64n, r, (i + 1 : U32), n, seg, O.pow2u(d), _)
         == T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, ta), F.array__thaw(D.Digest, CT.mlevel_t(r, 1n+x, d, U32.to_nat(n), XL, 0n, t1))}
         : T.l1099511627776_Validator_TS}
      cleaves(r, d, dw, ta, t1, (i + 1 : U32), 1n+x, n, seg, h, hd, hdw, pfa, hn,
        F.array__upd_perfect(D.Digest, 1n+d, t, CT.hp(d, 0n, x), v, pf),
        csucc(i, d, x, hd, ex, hx), CT.step_le(x, r, O.pow2n(d), hq))

# ---- the level loops ----------------------------------------------------------------------

law h2_dbl:
  for +P: Nat
  for +x: Nat
  {CT.h2(Nat.add(Nat.double(P), x)) == Nat.add(P, CT.h2(x)) : Nat}
def h2_dbl(P, x):
  match P:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, CT.h2(Nat.add(Nat.double(p), x)), Nat.add(p, CT.h2(x)), h2_dbl(p, x)) : {1n+_ == 1n+Nat.add(p, CT.h2(x)) : Nat}
      {==}

# The parent of heap position hp(d, l, x) is hp(d, 1 + l, x / 2).
def h2_hp(+d: Nat, +l: Nat, +x: Nat, +hL: {Nat.is_le(1n+l, d) == True{} : Bool})
    -> {CT.h2(CT.hp(d, l, x)) == CT.hp(d, 1n+l, CT.h2(x)) : Nat}:
  %Equal.sym(Nat, Nat.sub(d, l), 1n+Nat.sub(d, 1n+l), CT.sub_succ(d, l, hL)) : {CT.h2(Nat.add(O.pow2n(_), x)) == CT.hp(d, 1n+l, CT.h2(x)) : Nat}
  h2_dbl(O.pow2n(Nat.sub(d, 1n+l)), x)

def cshr(+k: U32, +d: Nat, +l: Nat, +x: Nat, +hL: {Nat.is_le(1n+l, d) == True{} : Bool}, +ek: {U32.to_nat(k) == CT.hp(d, l, x) : Nat})
    -> {U32.to_nat(U32.shrn(k, 1n)) == CT.hp(d, 1n+l, CT.h2(x)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(k, 1n)), CT.h2(U32.to_nat(k)), CX.shr1(k)) : {_ == CT.hp(d, 1n+l, CT.h2(x)) : Nat}
  %Equal.sym(Nat, U32.to_nat(k), CT.hp(d, l, x), ek) : {CT.h2(_) == CT.hp(d, 1n+l, CT.h2(x)) : Nat}
  h2_hp(d, l, x, hL)

law sub_cancel:
  for +P: Nat
  for +b: Nat
  for +a: Nat
  {Nat.sub(Nat.add(P, b), Nat.add(P, a)) == Nat.sub(b, a) : Nat}
def sub_cancel(P, b, a):
  match P:
    case 0n: {==}
    case 1n+ +p: sub_cancel(p, b, a)

law add_mono:
  for +P: Nat
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.add(P, a), Nat.add(P, b)) == True{} : Bool}
def add_mono(P, a, b, h):
  match P:
    case 0n: h
    case 1n+ +p: add_mono(p, a, b, h)

def le_rw2(+A: U32, +Bk: U32, +x: Nat, +y: Nat, +ea: {U32.to_nat(A) == x : Nat}, +eb: {U32.to_nat(Bk) == y : Nat},
    +h: {Nat.is_le(x, y) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(A), U32.to_nat(Bk)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(A), x, ea) : {Nat.is_le(_, U32.to_nat(Bk)) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(Bk), y, eb) : {Nat.is_le(x, _) == True{} : Bool}
  h

def lt_rw(+K: U32, +y: Nat, +Bn: Nat, +e: {U32.to_nat(K) == y : Nat}, +h: {Nat.is_lt(y, Bn) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(K), Bn) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(K), y, e) : {Nat.is_lt(_, Bn) == True{} : Bool}
  h

# The node count of a level loop: (B - A + 1) for A = hp(a), B = hp(b), a <= b.
def ccount(+A: U32, +Bk: U32, +d: Nat, +l: Nat, +a: Nat, +b: Nat,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hl: {Nat.is_le(1n+l, d) == True{} : Bool},
    +ea: {U32.to_nat(A) == CT.hp(d, 1n+l, a) : Nat},
    +eb: {U32.to_nat(Bk) == CT.hp(d, 1n+l, b) : Nat},
    +hab: {Nat.is_le(a, b) == True{} : Bool},
    +hbq: {Nat.is_lt(b, O.pow2n(Nat.sub(d, 1n+l))) == True{} : Bool})
    -> {U32.to_nat((Bk - A + 1 : U32)) == 1n+Nat.sub(b, a) : Nat}:
  +P = O.pow2n(Nat.sub(d, 1n+l))
  +hab2 = le_rw2(A, Bk, CT.hp(d, 1n+l, a), CT.hp(d, 1n+l, b), ea, eb, add_mono(P, a, b, hab))
  +hb2 = lt_rw(Bk, CT.hp(d, 1n+l, b), O.pow2n(1n+d), eb, CT.hp_lt(d, 1n+l, b, hl, hbq))
  %Equal.sym(Nat, U32.to_nat((Bk - A + 1 : U32)), 1n+Nat.sub(U32.to_nat(Bk), U32.to_nat(A)), CX.span_val(A, Bk, 1n+d, hd, hab2, hb2)) :
    {_ == 1n+Nat.sub(b, a) : Nat}
  %Equal.sym(Nat, U32.to_nat(Bk), CT.hp(d, 1n+l, b), eb) : {1n+Nat.sub(_, U32.to_nat(A)) == 1n+Nat.sub(b, a) : Nat}
  %Equal.sym(Nat, U32.to_nat(A), CT.hp(d, 1n+l, a), ea) : {1n+Nat.sub(CT.hp(d, 1n+l, b), _) == 1n+Nat.sub(b, a) : Nat}
  %Equal.sym(Nat, Nat.sub(CT.hp(d, 1n+l, b), CT.hp(d, 1n+l, a)), Nat.sub(b, a), sub_cancel(P, b, a)) : {1n+_ == 1n+Nat.sub(b, a) : Nat}
  {==}

# The level loops l + 1 .. l + k on the tree.
def mlevels_t(k: Nat, +l: Nat, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>) -> F.array__Tree<D.Digest>:
  match k:
    case 0n: t
    case 1n+r: mlevels_t(r, 1n+l, d, n, XL, lo, hi, CT.mlevel_t(CT.qn(1n+l, lo, hi), CT.rng(1n+l, lo), d, n, XL, 1n+l, t))

def hq_at(+d: Nat, +l: Nat, +lo: Nat, +hi: Nat,
    +hl: {Nat.is_le(1n+l, d) == True{} : Bool},
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool},
    +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(CT.rng(1n+l, lo), CT.qn(1n+l, lo, hi)), O.pow2n(Nat.sub(d, 1n+l))) == True{} : Bool}:
  CT.end_le(CT.rng(1n+l, lo), CT.rng(1n+l, hi), O.pow2n(Nat.sub(d, 1n+l)), CT.rng_mono(1n+l, lo, hi, hlh), CT.rng_lt(1n+l, hi, d, hl, hhi))

law mlevels_t_perfect:
  for +k: Nat
  for +l: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +t: F.array__Tree<D.Digest>
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  {F.array__perfect(D.Digest, 1n+d, mlevels_t(k, l, d, n, XL, lo, hi, t)) == True{} : Bool}
def mlevels_t_perfect(k, l, d, n, XL, lo, hi, t, pf):
  match k:
    case 0n: pf
    case 1n+ +r:
      mlevels_t_perfect(r, 1n+l, d, n, XL, lo, hi, CT.mlevel_t(CT.qn(1n+l, lo, hi), CT.rng(1n+l, lo), d, n, XL, 1n+l, t),
        CT.mlevel_t_perfect(CT.qn(1n+l, lo, hi), CT.rng(1n+l, lo), d, n, XL, 1n+l, t, pf))

law mlevels_t_slots:
  for +k: Nat
  for +l: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +t: F.array__Tree<D.Digest>
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  for +hk: {Nat.is_le(Nat.add(l, k), d) == True{} : Bool}
  for +hlh: {Nat.is_le(lo, hi) == True{} : Bool}
  for +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool}
  {F.array__slots(D.Digest, mlevels_t(k, l, d, n, XL, lo, hi, t)) == CT.mlevels(k, l, d, n, XL, lo, hi, F.array__slots(D.Digest, t)) : List<&2, D.Digest>}
def mlevels_t_slots(k, l, d, n, XL, lo, hi, t, pf, hk, hlh, hhi):
  match k:
    case 0n: {==}
    case 1n+ +r:
      +hl = F.nat__le_trans(1n+l, Nat.add(l, 1n+r), d, CT.step_le1(l, r), hk)
      +q = CT.qn(1n+l, lo, hi)
      +a = CT.rng(1n+l, lo)
      +t1 = CT.mlevel_t(q, a, d, n, XL, 1n+l, t)
      %CT.mlevel_t_slots(q, a, d, n, XL, 1n+l, t, pf, hl, hq_at(d, l, lo, hi, hl, hlh, hhi)) :
        {F.array__slots(D.Digest, mlevels_t(r, 1n+l, d, n, XL, lo, hi, t1)) == CT.mlevels(r, 1n+l, d, n, XL, lo, hi, _) : List<&2, D.Digest>}
      mlevels_t_slots(r, 1n+l, d, n, XL, lo, hi, t1, CT.mlevel_t_perfect(q, a, d, n, XL, 1n+l, t, pf), CT.step_le(l, r, d, hk), hlh, hhi)

# Transport of the invariants along an equality of slot lists.
def len_tr(+X: List<&2, D.Digest>, +Y: List<&2, D.Digest>, +e: {X == Y : List<&2, D.Digest>}, +d: Nat,
    +c: {F.spec_common__length(D.Digest, Y) == O.pow2n(1n+d) : Nat}) -> {F.spec_common__length(D.Digest, X) == O.pow2n(1n+d) : Nat}:
  %Equal.sym(List<&2, D.Digest>, X, Y, e) : {F.spec_common__length(D.Digest, _) == O.pow2n(1n+d) : Nat}
  c

def ci_tr(+X: List<&2, D.Digest>, +Y: List<&2, D.Digest>, +e: {X == Y : List<&2, D.Digest>}, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat,
    +c: CT.cinv(Y, d, n, XL, lo, hi)) -> CT.cinv(X, d, n, XL, lo, hi):
  %Equal.sym(List<&2, D.Digest>, X, Y, e) : CT.cinv(_, d, n, XL, lo, hi)
  c

def up_tr(+X: List<&2, D.Digest>, +Y: List<&2, D.Digest>, +e: {X == Y : List<&2, D.Digest>}, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat,
    +c: CT.all_upto(Y, d, n, XL, L)) -> CT.all_upto(X, d, n, XL, L):
  %Equal.sym(List<&2, D.Digest>, X, Y, e) : CT.all_upto(_, d, n, XL, L)
  c

# The runtime's level loops, from heap indices klo, khi of level l's range, are mlevels_t.
law clevels:
  for +k: Nat
  for +l: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +klo: U32
  for +khi: U32
  for +t: F.array__Tree<D.Digest>
  for -arr: Array<T.Validator>
  for -h: B.Buf
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hk: {Nat.is_le(Nat.add(l, k), d) == True{} : Bool}
  for +hlh: {Nat.is_le(lo, hi) == True{} : Bool}
  for +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool}
  for +ekl: {U32.to_nat(klo) == CT.hp(d, l, CT.rng(l, lo)) : Nat}
  for +ekh: {U32.to_nat(khi) == CT.hp(d, l, CT.rng(l, hi)) : Nat}
  for +en: {MD.dlen(XL) == n : Nat}
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat}
  for +ci: CT.cinv(F.array__slots(D.Digest, t), d, n, XL, lo, hi)
  for +up: CT.all_upto(F.array__slots(D.Digest, t), d, n, XL, l)
  {T.l1099511627776_Validator_levels(64n, k, klo, khi, T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)})
   == T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, mlevels_t(k, l, d, n, XL, lo, hi, t))} : T.l1099511627776_Validator_TS}
def clevels(k, l, d, n, XL, lo, hi, klo, khi, t, arr, h, hd, hk, hlh, hhi, ekl, ekh, en, pf, len, ci, up):
  match k:
    case 0n: {==}
    case 1n+ +r:
      +hl = F.nat__le_trans(1n+l, Nat.add(l, 1n+r), d, CT.step_le1(l, r), hk)
      +A = U32.shrn(klo, 1n)
      +Bk = U32.shrn(khi, 1n)
      +a = CT.rng(1n+l, lo)
      +b = CT.rng(1n+l, hi)
      +q = CT.qn(1n+l, lo, hi)
      +ea = cshr(klo, d, l, CT.rng(l, lo), hl, ekl)
      +eb = cshr(khi, d, l, CT.rng(l, hi), hl, ekh)
      +ecount = ccount(A, Bk, d, l, a, b, hd, hl, ea, eb, CT.rng_mono(1n+l, lo, hi, hlh), CT.rng_lt(1n+l, hi, d, hl, hhi))
      +hq = hq_at(d, l, lo, hi, hl, hlh, hhi)
      +NS = F.array__slots(D.Digest, t)
      +t1 = CT.mlevel_t(q, a, d, n, XL, 1n+l, t)
      +es = CT.mlevel_t_slots(q, a, d, n, XL, 1n+l, t, pf, hl, hq)
      +NS1 = CT.mlevel(q, a, d, n, XL, 1n+l, NS)
      %Equal.sym(Nat, U32.to_nat((Bk - A + 1 : U32)), q, ecount) :
        {T.l1099511627776_Validator_levels(64n, r, A, Bk, T.l1099511627776_Validator_level(64n, _, A, T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)}))
         == T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, mlevels_t(r, 1n+l, d, n, XL, lo, hi, t1))} : T.l1099511627776_Validator_TS}
      %Equal.sym(T.l1099511627776_Validator_TS,
          T.l1099511627776_Validator_level(64n, q, A, T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)}),
          T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t1)},
          CL.clevel(q, d, l, a, A, n, XL, t, arr, h, hd, hl, hq, ea, en, pf, CT.au_get(1n+l, NS, d, n, XL, up, l, F.nat__le_lt_succ(l, l, F.nat__le_refl(l))))) :
        {T.l1099511627776_Validator_levels(64n, r, A, Bk, _)
         == T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, mlevels_t(r, 1n+l, d, n, XL, lo, hi, t1))} : T.l1099511627776_Validator_TS}
      clevels(r, 1n+l, d, n, XL, lo, hi, A, Bk, t1, arr, h, hd, CT.step_le(l, r, d, hk), hlh, hhi, ea, eb, en,
        CT.mlevel_t_perfect(q, a, d, n, XL, 1n+l, t, pf),
        len_tr(F.array__slots(D.Digest, t1), NS1, es, d, CT.lvl_step_len(NS, d, n, XL, lo, hi, l, len)),
        ci_tr(F.array__slots(D.Digest, t1), NS1, es, d, n, XL, lo, hi, CT.lvl_step_ci(NS, d, n, XL, lo, hi, l, hl, hlh, hhi, len, ci)),
        up_tr(F.array__slots(D.Digest, t1), NS1, es, d, n, XL, 1n+l, CT.lvl_step(NS, d, n, XL, lo, hi, l, hl, hlh, hhi, len, ci, up)))
