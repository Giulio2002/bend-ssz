import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/FuluTransaction_def_generated.bend as FuluTransaction_d
import ../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Fulu_list_bytelist_1073741824_1048576_d
import ../proofs/compact/found_generated.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/dk.bend as DK
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vu32.bend as VU
import ../proofs/obj/schema_shapes_generated.bend as SH
import ../proofs/obj/words_obj_light.bend as WO
import ../proofs/obj/list_obj_light.bend as LO
import ../proofs/obj/root_types_light_generated.bend as RT
import ../proofs/obj/vvl_l1048576_bl1073741824_generated.bend as V
import ../proofs/obj/vvlb_bl1073741824_generated.bend as YW
import ../proofs/obj/vua_ct.bend as UCT
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/view_seq_generated.bend as VQ
import ../proofs/obj/words_rw.bend as WR
import ../proofs/obj/vvlu.bend as VVU
import ./e2e_blist_generated.bend as BL
import ./e2e_eptx_generated.bend as TX
import ../src/buffer.bend as B
import ../proofs/obj/vdepth.bend as VD
import ./e2e_dz_generated.bend as DZ

# The list of transactions a decoder returns (proofs/obj/vvl_l1048576_bl1073741824_generated.bend's mirror OBJw of the reader) satisfies
# the representation invariant rep_l1048576_bl1073741824 and the encode premise e2e_eptx.bend's sdt. The reader builds the array by one
# Array.set per element into fill(cap(N)); this file shows the array is am(T) for the tree T the same writes build (RVT), element by element.

# ---- one element ----

# the box the reader makes of an element is what freezing and thawing leave
def obje_canon(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32)
    -> {RT.th_bl1073741824_bx(RT.fz_bl1073741824_bx(V.OBJE(d, t, x, off, s, e))) == V.OBJE(d, t, x, off, s, e) : O.Boxed<O.Words>}:
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, U32.add(off, s), U32.sub(e, s), VLS.DZ(U32.sub(e, s))))), UCT.CT(d, t, U32.add(off, s), U32.sub(e, s), VLS.DZ(U32.sub(e, s))),
      FD.array__freeze_thaw(U32, UCT.CT(d, t, U32.add(off, s), U32.sub(e, s), VLS.DZ(U32.sub(e, s))))) :
    {O.BSome{O.Words{FD.array__thaw(U32, _), U32.sub(e, s)}, O.BNone{}} == V.OBJE(d, t, x, off, s, e) : O.Boxed<O.Words>}
  {==}

# the element's own representation invariant (rep_bl at the schema's limit) and its storage at depth below 31
def el_hy(+x: Nat, +len: U32, +a: U32, +b: U32, +hab: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(b), U32.to_nat(len)) == True{} : Bool}, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {Nat.is_le(VC.YL(U32.sub(b, a)), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  VC.hyW(Nat.add(U32.to_nat(a), x), U32.sub(b, a), V.hwab32(x, len, a, b, hab, hb, hwN))

def el_lim(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +a: U32, +b: U32, +sE: S.Schema, +es: {SH.ByteList_limit(sE) == U32.to_nat(1073741824) : Nat},
    +h: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(U32.sub(b, a)), SH.ByteList_limit(sE)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(U32.sub(b, a)), z) == True{} : Bool}, U32.to_nat(1073741824), SH.ByteList_limit(sE), Equal.sym(Nat, SH.ByteList_limit(sE), U32.to_nat(1073741824), es),
    FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(U32.sub(b, a), 1073741824), Nat.is_le(U32.to_nat(U32.sub(b, a)), U32.to_nat(1073741824)), VU.le_u32(U32.sub(b, a), 1073741824), V.el_c(t, x, off, len, a, b, h)))

def el_rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},
    +a: U32, +b: U32, +h: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool}, +sE: S.Schema, +es: {SH.ByteList_limit(sE) == U32.to_nat(1073741824) : Nat})
    -> RT.rep_bl1073741824_bx(V.OBJE(d, t, x, off, a, b), sE):
  +hab = V.el_ab(t, x, off, len, a, b, h)
  +hb = V.el_b(t, x, off, len, a, b, h)
  ({==}, (DZ.ct_dec(d, t, U32.add(off, a), U32.sub(b, a), 32n, {==}, el_hy(x, len, a, b, hab, hb, hwN)), el_lim(t, x, off, len, a, b, sE, es, h)))

# ---- the tree the reader's writes build ----

def XE(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32) -> RT.MB<RT.WMr>: RT.fz_bl1073741824_bx(V.OBJE(d, t, x, off, s, e))

def RVT(k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.WMr>>, +v: RT.MB<RT.WMr>) -> FD.array__Tree<RT.MB<RT.WMr>>:
  match k:
    case 0n: FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v)
    case 1n+q: RVT(q, U32.add(i, 1), m, dw, d, t, x, off, len, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v),
      XE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))))

def lt_add_succ(+a: Nat, +p: Nat) -> {Nat.is_lt(a, Nat.add(a, 1n+p)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(a, z) == True{} : Bool}, 1n+Nat.add(a, p), Nat.add(a, 1n+p), Equal.sym(Nat, Nat.add(a, 1n+p), 1n+Nat.add(a, p), FD.nat__add_succ(a, p)),
    FD.nat__le_lt_succ(a, Nat.add(a, p), FD.nat__le_add_right(a, p)))

# the index being written is inside the storage
def lt_i(+i: U32, +k: Nat, +m: U32, +dw: Nat, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool},
    +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat}) -> {Nat.is_lt(U32.to_nat(i), FD.spec_common__pow2(dw)) == True{} : Bool}:
  FD.nat__lt_le_trans(U32.to_nat(i), Nat.add(U32.to_nat(i), 1n+k), FD.spec_common__pow2(dw), lt_add_succ(U32.to_nat(i), k),
    FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dw)) == True{} : Bool}, U32.to_nat(m), Nat.add(U32.to_nat(i), 1n+k), Equal.sym(Nat, Nat.add(U32.to_nat(i), 1n+k), U32.to_nat(m), inv), hm))

def lt_len(+i: U32, +k: Nat, +m: U32, +dw: Nat, +T: FD.array__Tree<RT.MB<RT.WMr>>, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat})
    -> {Nat.is_lt(U32.to_nat(i), FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, FD.spec_common__pow2(dw), FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)),
    Equal.sym(Nat, FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)), FD.spec_common__pow2(dw), FD.array__slots_length(RT.MB<RT.WMr>, dw, T, pf)), lt_i(i, k, m, dw, hm, inv))

# ---- the array is the array of that tree ----
def rv_am(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.WMr>>, +v: RT.MB<RT.WMr>,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat})
    -> {V.RV(k, i, m, d, t, x, off, len, RT.am_l1048576_bl1073741824(T), RT.th_bl1073741824_bx(v)) == RT.am_l1048576_bl1073741824(RVT(k, i, m, dw, d, t, x, off, len, T, v)) : Array<O.Boxed<O.Words>>}:
  match k:
    case 0n:
      RT.amset_l1048576_bl1073741824(dw, T, i, v, RT.xat_l1048576_bl1073741824(FD.array__slots(RT.MB<RT.WMr>, T), U32.to_nat(i)), hdw, lt_i(i, 0n, m, dw, hm, inv),
        RT.nth_l1048576_bl1073741824(FD.array__slots(RT.MB<RT.WMr>, T), U32.to_nat(i), lt_len(i, 0n, m, dw, T, pf, hm, inv)), pf)
    case 1n+q:
      %Equal.sym(Array<O.Boxed<O.Words>>, Array.set(O.Boxed<O.Words>, RT.am_l1048576_bl1073741824(T), i, RT.th_bl1073741824_bx(v)), RT.am_l1048576_bl1073741824(FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v)),
          RT.amset_l1048576_bl1073741824(dw, T, i, v, RT.xat_l1048576_bl1073741824(FD.array__slots(RT.MB<RT.WMr>, T), U32.to_nat(i)), hdw, lt_i(i, 1n+q, m, dw, hm, inv),
            RT.nth_l1048576_bl1073741824(FD.array__slots(RT.MB<RT.WMr>, T), U32.to_nat(i), lt_len(i, 1n+q, m, dw, T, pf, hm, inv)), pf)) :
        {V.RV(q, U32.add(i, 1), m, d, t, x, off, len, _, V.OBJE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))) ==
          RT.am_l1048576_bl1073741824(RVT(1n+q, i, m, dw, d, t, x, off, len, T, v)) : Array<O.Boxed<O.Words>>}
      %Equal.sym(O.Boxed<O.Words>, V.OBJE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))),
          RT.th_bl1073741824_bx(XE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))),
          Equal.sym(O.Boxed<O.Words>, RT.th_bl1073741824_bx(XE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))),
            V.OBJE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))),
            obje_canon(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))))) :
        {V.RV(q, U32.add(i, 1), m, d, t, x, off, len, RT.am_l1048576_bl1073741824(FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v)), _) ==
          RT.am_l1048576_bl1073741824(RVT(1n+q, i, m, dw, d, t, x, off, len, T, v)) : Array<O.Boxed<O.Words>>}
      rv_am(q, U32.add(i, 1), m, dw, d, t, x, off, len, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v),
        XE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))), hdw,
        FD.array__upd_perfect(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v, pf), hm, V.inv_nx(q, i, m, inv))

# ---- the elements' representation, over the writes ----

def ereps_after(+k: Nat, +W: List<&2, RT.MB<RT.WMr>>, +i0: Nat, +J: Nat, +e: RT.MB<RT.WMr>, +sE: S.Schema, +hJ: {Nat.is_le(Nat.add(i0, k), J) == True{} : Bool},
    +r: RT.ereps_l1048576_bl1073741824(k, W, i0, sE)) -> RT.ereps_l1048576_bl1073741824(k, FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0, sE):
  match k:
    case 0n: {==}
    case 1n+q:
      (r1, r2) = r
      +hlt = FD.nat__lt_le_trans(i0, Nat.add(i0, 1n+q), J, lt_add_succ(i0, q), hJ)
      (FD.logic__subst(RT.MB<RT.WMr>, z => RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(z), sE), RT.xat_l1048576_bl1073741824(W, i0), RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0),
          Equal.sym(RT.MB<RT.WMr>, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0), RT.xat_l1048576_bl1073741824(W, i0),
            VQ.l1048576_bl1073741824_xat_other(W, J, i0, e, WR.neq_sym(i0, J, FD.nat__is_eq_lt(i0, J, hlt)))), r1),
        ereps_after(q, W, 1n+i0, J, e, sE, FD.logic__subst(Nat, z => {Nat.is_le(z, J) == True{} : Bool}, Nat.add(i0, 1n+q), Nat.add(1n+i0, q), FD.nat__add_succ(i0, q), hJ), r2))

def ereps_snoc(+k: Nat, +W: List<&2, RT.MB<RT.WMr>>, +i0: Nat, +sE: S.Schema, +r: RT.ereps_l1048576_bl1073741824(k, W, i0, sE),
    +z: RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(RT.xat_l1048576_bl1073741824(W, Nat.add(i0, k))), sE)) -> RT.ereps_l1048576_bl1073741824(1n+k, W, i0, sE):
  match k:
    case 0n:
      (FD.logic__subst(Nat, n => RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(RT.xat_l1048576_bl1073741824(W, n)), sE), Nat.add(i0, 0n), i0, FD.nat__add_zero(i0), z), {==})
    case 1n+q:
      (r1, r2) = r
      (r1, ereps_snoc(q, W, 1n+i0, sE, r2, FD.logic__subst(Nat, n => RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(RT.xat_l1048576_bl1073741824(W, n)), sE), Nat.add(i0, 1n+q), Nat.add(1n+i0, q), FD.nat__add_succ(i0, q), z)))

def ereps_step(+i: Nat, +dw: Nat, +T: FD.array__Tree<RT.MB<RT.WMr>>, +vm: RT.MB<RT.WMr>, +sE: S.Schema, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hI: {Nat.is_lt(i, FD.spec_common__pow2(dw)) == True{} : Bool},
    +r: RT.ereps_l1048576_bl1073741824(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n, sE), +z: RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(vm), sE))
    -> RT.ereps_l1048576_bl1073741824(1n+i, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)), 0n, sE):
  +hl = FD.logic__subst(Nat, n => {Nat.is_lt(i, n) == True{} : Bool}, FD.spec_common__pow2(dw), FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)),
    Equal.sym(Nat, FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)), FD.spec_common__pow2(dw), FD.array__slots_length(RT.MB<RT.WMr>, dw, T, pf)), hI)
  FD.logic__subst(List<&2, RT.MB<RT.WMr>>, W2 => RT.ereps_l1048576_bl1073741824(1n+i, W2, 0n, sE), FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)),
    Equal.sym(List<&2, RT.MB<RT.WMr>>, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)), FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), FD.array__upd_slots(RT.MB<RT.WMr>, dw, T, i, vm, hI, pf)),
    ereps_snoc(i, FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), 0n, sE,
      ereps_after(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n, i, vm, sE, FD.nat__le_refl(i), r),
      FD.logic__subst(RT.MB<RT.WMr>, y => RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(y), sE), vm, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), i),
        Equal.sym(RT.MB<RT.WMr>, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), i), vm, VQ.l1048576_bl1073741824_xat_same(FD.array__slots(RT.MB<RT.WMr>, T), i, vm, hl)), z)))

# the thawed frozen element is the element, so its invariant is the element's
def el_rep_th(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},
    +a: U32, +b: U32, +h: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool}, +sE: S.Schema, +es: {SH.ByteList_limit(sE) == U32.to_nat(1073741824) : Nat})
    -> RT.rep_bl1073741824_bx(RT.th_bl1073741824_bx(XE(d, t, x, off, a, b)), sE):
  FD.logic__subst(O.Boxed<O.Words>, o => RT.rep_bl1073741824_bx(o, sE), V.OBJE(d, t, x, off, a, b), RT.th_bl1073741824_bx(XE(d, t, x, off, a, b)),
    Equal.sym(O.Boxed<O.Words>, RT.th_bl1073741824_bx(XE(d, t, x, off, a, b)), V.OBJE(d, t, x, off, a, b), obje_canon(d, t, x, off, a, b)), el_rep(d, t, x, off, len, hwN, a, b, h, sE, es))

# the index after i, and the count of one more
def i1_val(+p: Nat, +i: U32, +m: U32, +inv: {Nat.add(U32.to_nat(i), 2n+p) == U32.to_nat(m) : Nat}) -> {U32.to_nat(U32.add(i, 1)) == 1n+U32.to_nat(i) : Nat}:
  VVU.addk(i, 1, m, FD.logic__subst(Nat, z => {Nat.is_le(1n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n+p), U32.to_nat(m), inv,
    FD.logic__subst(Nat, z => {Nat.is_le(1n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n+p, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n+p), FD.nat__add_comm(2n+p, U32.to_nat(i)),
      A.le_skip(1n+p, U32.to_nat(i)))))

def cnt0(+a: Nat, +c: Nat, +inv: {Nat.add(a, 1n+0n) == c : Nat}) -> {1n+a == c : Nat}:
  Equal.trans(Nat, 1n+a, Nat.add(a, 1n+0n), c,
    Equal.trans(Nat, 1n+a, 1n+Nat.add(a, 0n), Nat.add(a, 1n+0n), Equal.cong(Nat, Nat, z => 1n+z, a, Nat.add(a, 0n), Equal.sym(Nat, Nat.add(a, 0n), a, FD.nat__add_zero(a))),
      Equal.sym(Nat, Nat.add(a, 1n+0n), 1n+Nat.add(a, 0n), FD.nat__add_succ(a, 0n))), inv)

# ---- the loop: every element's invariant, the count and the perfect tree ----
def rv_ereps(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.WMr>>, +s: U32, +a: U32,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},
    +hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool}, +hEV: {V.EV(k, i, m, t, x, off, len, True{}, V.WJ(t, x, i)) == True{} : Bool},
    +sE: S.Schema, +es: {SH.ByteList_limit(sE) == U32.to_nat(1073741824) : Nat},
    +pre: RT.ereps_l1048576_bl1073741824(U32.to_nat(i), FD.array__slots(RT.MB<RT.WMr>, T), 0n, sE))
    -> RT.ereps_l1048576_bl1073741824(U32.to_nat(m), FD.array__slots(RT.MB<RT.WMr>, RVT(k, i, m, dw, d, t, x, off, len, T, XE(d, t, x, off, s, a))), 0n, sE):
  match k:
    case 0n:
      FD.logic__subst(Nat, c => RT.ereps_l1048576_bl1073741824(c, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a))), 0n, sE), 1n+U32.to_nat(i), U32.to_nat(m), cnt0(U32.to_nat(i), U32.to_nat(m), inv),
        ereps_step(U32.to_nat(i), dw, T, XE(d, t, x, off, s, a), sE, pf, lt_i(i, 0n, m, dw, hm, inv), pre, el_rep_th(d, t, x, off, len, hwN, s, a, hEE, sE, es)))
    case 1n+q:
      +nb = V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      rv_ereps(q, U32.add(i, 1), m, dw, d, t, x, off, len, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a)), V.WJ(t, x, i), nb, hdw,
        FD.array__upd_perfect(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a), pf), hm, V.inv_nx(q, i, m, inv), hwN,
        V.ev_ok(q, U32.add(i, 1), m, t, x, off, len, V.EE(True{}, t, x, off, len, V.WJ(t, x, i), nb), nb, hEV), V.he_nx(q, i, m, t, x, off, len, inv, hEV), sE, es,
        FD.logic__subst(Nat, c => RT.ereps_l1048576_bl1073741824(c, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a))), 0n, sE), 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)),
          Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), i1_val(q, i, m, inv)),
          ereps_step(U32.to_nat(i), dw, T, XE(d, t, x, off, s, a), sE, pf, lt_i(i, 1n+q, m, dw, hm, inv), pre, el_rep_th(d, t, x, off, len, hwN, s, a, hEE, sE, es))))


# ---- the elements' storage at depth below 31 (the encode premise's SDKS), over the writes ----
def el_sdk_th(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},
    +a: U32, +b: U32, +h: {V.EE(True{}, t, x, off, len, a, b) == True{} : Bool})
    -> BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(XE(d, t, x, off, a, b))), 31n):
  FD.logic__subst(O.Boxed<O.Words>, o => BL.sdk(RT.pjb_bl1073741824_bx(o), 31n), V.OBJE(d, t, x, off, a, b), RT.th_bl1073741824_bx(XE(d, t, x, off, a, b)),
    Equal.sym(O.Boxed<O.Words>, RT.th_bl1073741824_bx(XE(d, t, x, off, a, b)), V.OBJE(d, t, x, off, a, b), obje_canon(d, t, x, off, a, b)),
    DZ.ct_dec(d, t, U32.add(off, a), U32.sub(b, a), 31n, {==}, el_hy(x, len, a, b, V.el_ab(t, x, off, len, a, b, h), V.el_b(t, x, off, len, a, b, h), hwN)))


def sdks_after(+k: Nat, +W: List<&2, RT.MB<RT.WMr>>, +i0: Nat, +J: Nat, +e: RT.MB<RT.WMr>, +hJ: {Nat.is_le(Nat.add(i0, k), J) == True{} : Bool},
    +r: TX.SDKS(k, W, i0)) -> TX.SDKS(k, FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0):
  match k:
    case 0n: {==}
    case 1n+q:
      (r1, r2) = r
      +hlt = FD.nat__lt_le_trans(i0, Nat.add(i0, 1n+q), J, lt_add_succ(i0, q), hJ)
      (FD.logic__subst(RT.MB<RT.WMr>, z => BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(z)), 31n), RT.xat_l1048576_bl1073741824(W, i0), RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0),
          Equal.sym(RT.MB<RT.WMr>, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0), RT.xat_l1048576_bl1073741824(W, i0),
            VQ.l1048576_bl1073741824_xat_other(W, J, i0, e, WR.neq_sym(i0, J, FD.nat__is_eq_lt(i0, J, hlt)))), r1),
        sdks_after(q, W, 1n+i0, J, e, FD.logic__subst(Nat, z => {Nat.is_le(z, J) == True{} : Bool}, Nat.add(i0, 1n+q), Nat.add(1n+i0, q), FD.nat__add_succ(i0, q), hJ), r2))

def sdks_snoc(+k: Nat, +W: List<&2, RT.MB<RT.WMr>>, +i0: Nat, +r: TX.SDKS(k, W, i0),
    +z: BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(RT.xat_l1048576_bl1073741824(W, Nat.add(i0, k)))), 31n)) -> TX.SDKS(1n+k, W, i0):
  match k:
    case 0n:
      (FD.logic__subst(Nat, n => BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(RT.xat_l1048576_bl1073741824(W, n))), 31n), Nat.add(i0, 0n), i0, FD.nat__add_zero(i0), z), {==})
    case 1n+q:
      (r1, r2) = r
      (r1, sdks_snoc(q, W, 1n+i0, r2, FD.logic__subst(Nat, n => BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(RT.xat_l1048576_bl1073741824(W, n))), 31n), Nat.add(i0, 1n+q), Nat.add(1n+i0, q), FD.nat__add_succ(i0, q), z)))

def sdks_step(+i: Nat, +dw: Nat, +T: FD.array__Tree<RT.MB<RT.WMr>>, +vm: RT.MB<RT.WMr>, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hI: {Nat.is_lt(i, FD.spec_common__pow2(dw)) == True{} : Bool},
    +r: TX.SDKS(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), +z: BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(vm)), 31n))
    -> TX.SDKS(1n+i, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)), 0n):
  +hl = FD.logic__subst(Nat, n => {Nat.is_lt(i, n) == True{} : Bool}, FD.spec_common__pow2(dw), FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)),
    Equal.sym(Nat, FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)), FD.spec_common__pow2(dw), FD.array__slots_length(RT.MB<RT.WMr>, dw, T, pf)), hI)
  FD.logic__subst(List<&2, RT.MB<RT.WMr>>, W2 => TX.SDKS(1n+i, W2, 0n), FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)),
    Equal.sym(List<&2, RT.MB<RT.WMr>>, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)), FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), FD.array__upd_slots(RT.MB<RT.WMr>, dw, T, i, vm, hI, pf)),
    sdks_snoc(i, FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), 0n,
      sdks_after(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n, i, vm, FD.nat__le_refl(i), r),
      FD.logic__subst(RT.MB<RT.WMr>, y => BL.sdk(RT.pjb_bl1073741824_bx(RT.th_bl1073741824_bx(y)), 31n), vm, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), i),
        Equal.sym(RT.MB<RT.WMr>, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm), i), vm, VQ.l1048576_bl1073741824_xat_same(FD.array__slots(RT.MB<RT.WMr>, T), i, vm, hl)), z)))


# ---- the loop: every element's invariant, the count and the perfect tree ----
def rv_sdks(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.WMr>>, +s: U32, +a: U32,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},
    +hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool}, +hEV: {V.EV(k, i, m, t, x, off, len, True{}, V.WJ(t, x, i)) == True{} : Bool},
    
    +pre: TX.SDKS(U32.to_nat(i), FD.array__slots(RT.MB<RT.WMr>, T), 0n))
    -> TX.SDKS(U32.to_nat(m), FD.array__slots(RT.MB<RT.WMr>, RVT(k, i, m, dw, d, t, x, off, len, T, XE(d, t, x, off, s, a))), 0n):
  match k:
    case 0n:
      FD.logic__subst(Nat, c => TX.SDKS(c, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a))), 0n), 1n+U32.to_nat(i), U32.to_nat(m), cnt0(U32.to_nat(i), U32.to_nat(m), inv),
        sdks_step(U32.to_nat(i), dw, T, XE(d, t, x, off, s, a), pf, lt_i(i, 0n, m, dw, hm, inv), pre, el_sdk_th(d, t, x, off, len, hwN, s, a, hEE)))
    case 1n+q:
      +nb = V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      rv_sdks(q, U32.add(i, 1), m, dw, d, t, x, off, len, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a)), V.WJ(t, x, i), nb, hdw,
        FD.array__upd_perfect(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a), pf), hm, V.inv_nx(q, i, m, inv), hwN,
        V.ev_ok(q, U32.add(i, 1), m, t, x, off, len, V.EE(True{}, t, x, off, len, V.WJ(t, x, i), nb), nb, hEV), V.he_nx(q, i, m, t, x, off, len, inv, hEV),
        FD.logic__subst(Nat, c => TX.SDKS(c, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a))), 0n), 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)),
          Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), i1_val(q, i, m, inv)),
          sdks_step(U32.to_nat(i), dw, T, XE(d, t, x, off, s, a), pf, lt_i(i, 1n+q, m, dw, hm, inv), pre, el_sdk_th(d, t, x, off, len, hwN, s, a, hEE))))


# ---- the elements' byte counts add up to the window (the offsets telescope) ----
def sumn_after(+k: Nat, +W: List<&2, RT.MB<RT.WMr>>, +i0: Nat, +J: Nat, +e: RT.MB<RT.WMr>, +hJ: {Nat.is_le(Nat.add(i0, k), J) == True{} : Bool})
    -> {TX.SUMN(k, FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0) == TX.SUMN(k, W, i0) : Nat}:
  match k:
    case 0n: {==}
    case 1n+q:
      +hlt = FD.nat__lt_le_trans(i0, Nat.add(i0, 1n+q), J, lt_add_succ(i0, q), hJ)
      %Equal.sym(RT.MB<RT.WMr>, RT.xat_l1048576_bl1073741824(FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), i0), RT.xat_l1048576_bl1073741824(W, i0),
          VQ.l1048576_bl1073741824_xat_other(W, J, i0, e, WR.neq_sym(i0, J, FD.nat__is_eq_lt(i0, J, hlt)))) :
        {Nat.add(U32.to_nat(TX.NR(_)), TX.SUMN(q, FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), 1n+i0)) == TX.SUMN(1n+q, W, i0) : Nat}
      %Equal.sym(Nat, TX.SUMN(q, FD.spec_common__update(RT.MB<RT.WMr>, W, J, e), 1n+i0), TX.SUMN(q, W, 1n+i0),
          sumn_after(q, W, 1n+i0, J, e, FD.logic__subst(Nat, z => {Nat.is_le(z, J) == True{} : Bool}, Nat.add(i0, 1n+q), Nat.add(1n+i0, q), FD.nat__add_succ(i0, q), hJ))) :
        {Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), _) == TX.SUMN(1n+q, W, i0) : Nat}
      {==}

def sumn_snoc(+k: Nat, +W: List<&2, RT.MB<RT.WMr>>, +i0: Nat)
    -> {TX.SUMN(1n+k, W, i0) == Nat.add(TX.SUMN(k, W, i0), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(i0, k))))) : Nat}:
  match k:
    case 0n:
      %Equal.sym(RT.MB<RT.WMr>, RT.xat_l1048576_bl1073741824(W, Nat.add(i0, 0n)), RT.xat_l1048576_bl1073741824(W, i0),
          Equal.cong(Nat, RT.MB<RT.WMr>, n => RT.xat_l1048576_bl1073741824(W, n), Nat.add(i0, 0n), i0, FD.nat__add_zero(i0))) :
        {TX.SUMN(1n, W, i0) == Nat.add(0n, U32.to_nat(TX.NR(_))) : Nat}
      Equal.trans(Nat, Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), 0n), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), Nat.add(0n, U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0)))), FD.nat__add_zero(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0)))), {==})
    case 1n+q:
      Equal.trans(Nat, TX.SUMN(2n+q, W, i0), Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), Nat.add(TX.SUMN(q, W, 1n+i0), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q)))))),
        Nat.add(Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), TX.SUMN(q, W, 1n+i0)), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(i0, 1n+q))))),
        Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), z), TX.SUMN(1n+q, W, 1n+i0), Nat.add(TX.SUMN(q, W, 1n+i0), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q))))), sumn_snoc(q, W, 1n+i0)),
        Equal.trans(Nat, Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), Nat.add(TX.SUMN(q, W, 1n+i0), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q)))))), Nat.add(Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), TX.SUMN(q, W, 1n+i0)), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q))))),
          Nat.add(Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), TX.SUMN(q, W, 1n+i0)), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(i0, 1n+q))))),
          Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), TX.SUMN(q, W, 1n+i0)), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q))))), Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), Nat.add(TX.SUMN(q, W, 1n+i0), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q)))))),
            FD.nat__add_assoc(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), TX.SUMN(q, W, 1n+i0), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, Nat.add(1n+i0, q)))))),
          Equal.cong(Nat, Nat, n => Nat.add(Nat.add(U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, i0))), TX.SUMN(q, W, 1n+i0)), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W, n)))), Nat.add(1n+i0, q), Nat.add(i0, 1n+q),
            Equal.sym(Nat, Nat.add(i0, 1n+q), Nat.add(1n+i0, q), FD.nat__add_succ(i0, q)))))

def NXk(+k: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +i: U32) -> U32:
  match k:
    case 0n: len
    case 1n+q: V.WJ(t, x, i)

def him2(+q: Nat, +i: U32, +m: U32, +inv: {Nat.add(U32.to_nat(i), 2n+q) == U32.to_nat(m) : Nat}) -> {Nat.is_le(Nat.add(2n, U32.to_nat(i)), U32.to_nat(m)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, U32.to_nat(i)), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n+q), U32.to_nat(m), inv,
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, U32.to_nat(i)), z) == True{} : Bool}, Nat.add(2n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n+q), FD.nat__add_comm(2n+q, U32.to_nat(i)),
      A.le_skip(q, U32.to_nat(i))))

def i2_val(+q: Nat, +i: U32, +m: U32, +inv: {Nat.add(U32.to_nat(i), 2n+q) == U32.to_nat(m) : Nat}) -> {U32.to_nat(U32.add(i, 2)) == Nat.add(2n, U32.to_nat(i)) : Nat}:
  VVU.addk(i, 2, m, him2(q, i, m, inv))

# the end of the element after i is the next offset, or the window's end for the last one
def nxk(+q: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +inv: {Nat.add(U32.to_nat(i), 2n+q) == U32.to_nat(m) : Nat})
    -> {V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)) == NXk(q, t, x, len, U32.add(i, 1)) : U32}:
  match q:
    case 0n:
      %Equal.sym(Bool, U32.is_eq(U32.add(i, 2), m), True{}, V.eqtr(U32.add(i, 2), m, Equal.trans(Nat, U32.to_nat(U32.add(i, 2)), Nat.add(2n, U32.to_nat(i)), U32.to_nat(m), i2_val(0n, i, m, inv),
          Equal.trans(Nat, Nat.add(2n, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n), U32.to_nat(m), FD.nat__add_comm(2n, U32.to_nat(i)), inv)))) :
        {V.NX(_, t, x, len, U32.add(i, 1)) == len : U32}
      {==}
    case 1n+p:
      +hi3 = FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n+(1n+p)), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n+(1n+p), U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n+(1n+p)), FD.nat__add_comm(2n+(1n+p), U32.to_nat(i)),
          A.le_skip(p, U32.to_nat(i))))
      +hne = V.eqfr(U32.add(i, 2), m, FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(m)) == False{} : Bool}, Nat.add(2n, U32.to_nat(i)), U32.to_nat(U32.add(i, 2)),
        Equal.sym(Nat, U32.to_nat(U32.add(i, 2)), Nat.add(2n, U32.to_nat(i)), i2_val(1n+p, i, m, inv)),
        FD.nat__is_eq_lt(Nat.add(2n, U32.to_nat(i)), U32.to_nat(m), FD.nat__succ_le_lt(Nat.add(2n, U32.to_nat(i)), U32.to_nat(m), hi3))))
      %Equal.sym(Bool, U32.is_eq(U32.add(i, 2), m), False{}, hne) : {V.NX(_, t, x, len, U32.add(i, 1)) == V.WJ(t, x, U32.add(i, 1)) : U32}
      {==}

def tele(+s: U32, +a: U32, +h: {Nat.is_le(U32.to_nat(s), U32.to_nat(a)) == True{} : Bool}) -> {Nat.add(U32.to_nat(s), U32.to_nat(U32.sub(a, s))) == U32.to_nat(a) : Nat}:
  Equal.trans(Nat, Nat.add(U32.to_nat(s), U32.to_nat(U32.sub(a, s))), Nat.add(U32.to_nat(s), Nat.sub(U32.to_nat(a), U32.to_nat(s))), U32.to_nat(a),
    Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(s), z), U32.to_nat(U32.sub(a, s)), Nat.sub(U32.to_nat(a), U32.to_nat(s)), FD.u32__sub_nat(a, s, h)),
    FD.nat__sub_add(U32.to_nat(a), U32.to_nat(s), h))

def sum_step(+i: Nat, +dw: Nat, +T: FD.array__Tree<RT.MB<RT.WMr>>, +vm: RT.MB<RT.WMr>, +F: Nat, +sN: Nat, +aN: Nat, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hI: {Nat.is_lt(i, FD.spec_common__pow2(dw)) == True{} : Bool},
    +pre: {Nat.add(F, TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n)) == sN : Nat}, +ht: {Nat.add(sN, U32.to_nat(TX.NR(vm))) == aN : Nat})
    -> {Nat.add(F, TX.SUMN(1n+i, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)), 0n)) == aN : Nat}:
  +hl = FD.logic__subst(Nat, n => {Nat.is_lt(i, n) == True{} : Bool}, FD.spec_common__pow2(dw), FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)),
    Equal.sym(Nat, FD.spec_common__length(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T)), FD.spec_common__pow2(dw), FD.array__slots_length(RT.MB<RT.WMr>, dw, T, pf)), hI)
  +W2 = FD.spec_common__update(RT.MB<RT.WMr>, FD.array__slots(RT.MB<RT.WMr>, T), i, vm)
  +e1 = sumn_snoc(i, W2, 0n)
  +e2 = sumn_after(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n, i, vm, FD.nat__le_refl(i))
  +e3 = VQ.l1048576_bl1073741824_xat_same(FD.array__slots(RT.MB<RT.WMr>, T), i, vm, hl)
  FD.logic__subst(List<&2, RT.MB<RT.WMr>>, w => {Nat.add(F, TX.SUMN(1n+i, w, 0n)) == aN : Nat}, W2, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)),
    Equal.sym(List<&2, RT.MB<RT.WMr>>, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, i, vm)), W2, FD.array__upd_slots(RT.MB<RT.WMr>, dw, T, i, vm, hI, pf)),
    Equal.trans(Nat, Nat.add(F, TX.SUMN(1n+i, W2, 0n)), Nat.add(F, Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm)))), aN,
      Equal.cong(Nat, Nat, z => Nat.add(F, z), TX.SUMN(1n+i, W2, 0n), Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm))),
        Equal.trans(Nat, TX.SUMN(1n+i, W2, 0n), Nat.add(TX.SUMN(i, W2, 0n), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W2, i)))), Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm))), e1,
          Equal.trans(Nat, Nat.add(TX.SUMN(i, W2, 0n), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W2, i)))), Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W2, i)))), Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm))),
            Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(TX.NR(RT.xat_l1048576_bl1073741824(W2, i)))), TX.SUMN(i, W2, 0n), TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), e2),
            Equal.cong(RT.MB<RT.WMr>, Nat, z => Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(z))), RT.xat_l1048576_bl1073741824(W2, i), vm, e3)))),
      Equal.trans(Nat, Nat.add(F, Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm)))), Nat.add(Nat.add(F, TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n)), U32.to_nat(TX.NR(vm))), aN,
        Equal.sym(Nat, Nat.add(Nat.add(F, TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n)), U32.to_nat(TX.NR(vm))), Nat.add(F, Nat.add(TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm)))), FD.nat__add_assoc(F, TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n), U32.to_nat(TX.NR(vm)))),
        Equal.trans(Nat, Nat.add(Nat.add(F, TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n)), U32.to_nat(TX.NR(vm))), Nat.add(sN, U32.to_nat(TX.NR(vm))), aN,
          Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(TX.NR(vm))), Nat.add(F, TX.SUMN(i, FD.array__slots(RT.MB<RT.WMr>, T), 0n)), sN, pre), ht))))

# ---- the loop: the elements' windows tile the list's window ----
def rv_sum(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +F: Nat, +T: FD.array__Tree<RT.MB<RT.WMr>>, +s: U32, +a: U32,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}, +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool},
    +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dw)) == True{} : Bool}, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +hEE: {V.EE(True{}, t, x, off, len, s, a) == True{} : Bool}, +hEV: {V.EV(k, i, m, t, x, off, len, True{}, V.WJ(t, x, i)) == True{} : Bool},
    +hak: {NXk(k, t, x, len, i) == a : U32},
    +pre: {Nat.add(F, TX.SUMN(U32.to_nat(i), FD.array__slots(RT.MB<RT.WMr>, T), 0n)) == U32.to_nat(s) : Nat})
    -> {Nat.add(F, TX.SUMN(U32.to_nat(m), FD.array__slots(RT.MB<RT.WMr>, RVT(k, i, m, dw, d, t, x, off, len, T, XE(d, t, x, off, s, a))), 0n)) == U32.to_nat(len) : Nat}:
  match k:
    case 0n:
      +hab = V.el_ab(t, x, off, len, s, a, hEE)
      FD.logic__subst(Nat, c => {Nat.add(F, TX.SUMN(c, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a))), 0n)) == U32.to_nat(len) : Nat}, 1n+U32.to_nat(i), U32.to_nat(m), cnt0(U32.to_nat(i), U32.to_nat(m), inv),
        sum_step(U32.to_nat(i), dw, T, XE(d, t, x, off, s, a), F, U32.to_nat(s), U32.to_nat(len), pf, lt_i(i, 0n, m, dw, hm, inv), pre,
          Equal.trans(Nat, Nat.add(U32.to_nat(s), U32.to_nat(U32.sub(a, s))), U32.to_nat(a), U32.to_nat(len), tele(s, a, hab),
            Equal.cong(U32, Nat, z => U32.to_nat(z), a, len, Equal.sym(U32, len, a, hak)))))
    case 1n+q:
      +hab = V.el_ab(t, x, off, len, s, a, hEE)
      +nb = V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      rv_sum(q, U32.add(i, 1), m, dw, d, t, x, off, len, F, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a)), V.WJ(t, x, i), nb, hdw,
        FD.array__upd_perfect(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a), pf), hm, V.inv_nx(q, i, m, inv),
        V.ev_ok(q, U32.add(i, 1), m, t, x, off, len, V.EE(True{}, t, x, off, len, V.WJ(t, x, i), nb), nb, hEV), V.he_nx(q, i, m, t, x, off, len, inv, hEV),
        Equal.sym(U32, nb, NXk(q, t, x, len, U32.add(i, 1)), nxk(q, i, m, t, x, len, inv)),
        FD.logic__subst(Nat, c => {Nat.add(F, TX.SUMN(c, FD.array__slots(RT.MB<RT.WMr>, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), XE(d, t, x, off, s, a))), 0n)) == U32.to_nat(V.WJ(t, x, i)) : Nat}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)),
          Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), i1_val(q, i, m, inv)),
          sum_step(U32.to_nat(i), dw, T, XE(d, t, x, off, s, a), F, U32.to_nat(s), U32.to_nat(V.WJ(t, x, i)), pf, lt_i(i, 1n+q, m, dw, hm, inv), pre,
            Equal.trans(Nat, Nat.add(U32.to_nat(s), U32.to_nat(U32.sub(a, s))), U32.to_nat(a), U32.to_nat(V.WJ(t, x, i)), tele(s, a, hab),
              Equal.cong(U32, Nat, z => U32.to_nat(z), a, V.WJ(t, x, i), Equal.sym(U32, V.WJ(t, x, i), a, hak))))))


# ---- the list the reader starts from, and the tree it ends with ----
def fill_am(+dw: Nat) -> {Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(dw) == RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, dw, RT.MNone{})) : Array<O.Boxed<O.Words>>}:
  match dw:
    case 0n: {==}
    case 1n+q:
      %Equal.sym(Array<O.Boxed<O.Words>>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(q), RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, q, RT.MNone{})), fill_am(q)) :
        {ANode{_, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(q)} == RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, 1n+q, RT.MNone{})) : Array<O.Boxed<O.Words>>}
      %Equal.sym(Array<O.Boxed<O.Words>>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(q), RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, q, RT.MNone{})), fill_am(q)) :
        {ANode{RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, q, RT.MNone{})), _} == RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, 1n+q, RT.MNone{})) : Array<O.Boxed<O.Words>>}
      {==}

# every tree the reader's writes build is perfect
def rvt_pf(+k: Nat, +i: U32, +m: U32, +dw: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +T: FD.array__Tree<RT.MB<RT.WMr>>, +v: RT.MB<RT.WMr>,
    +pf: {FD.array__perfect(RT.MB<RT.WMr>, dw, T) == True{} : Bool}) -> {FD.array__perfect(RT.MB<RT.WMr>, dw, RVT(k, i, m, dw, d, t, x, off, len, T, v)) == True{} : Bool}:
  match k:
    case 0n: FD.array__upd_perfect(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v, pf)
    case 1n+q:
      rvt_pf(q, U32.add(i, 1), m, dw, d, t, x, off, len, FD.array__upd(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v),
        XE(d, t, x, off, V.WJ(t, x, i), V.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))), FD.array__upd_perfect(RT.MB<RT.WMr>, dw, T, U32.to_nat(i), v, pf))

# the list's element count is at most 2^20, as a Nat fact about the literal
def hL20() -> {Nat.is_le(U32.to_nat(1048576), O.pow2n(20n)) == True{} : Bool}:
  +e1 = Equal.trans(Nat, U32.to_nat(1048576), FD.spec_common__pow2(20n),  O.pow2n(20n),
    FD.logic__subst(U32, z => {U32.to_nat(z) == FD.spec_common__pow2(20n) : Nat}, FD.u32__pow2u(20n), 1048576, {==}, FD.u32__pow2u_value(20n, {==})), VD.s_pow2_eq(20n))
  FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(20n)) == True{} : Bool}, O.pow2n(20n), U32.to_nat(1048576), Equal.sym(Nat, U32.to_nat(1048576), O.pow2n(20n), e1), FD.nat__le_refl(O.pow2n(20n)))

# ---- what the window's check says (it is nonempty) ----
def hc_of(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == False{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {V.HC(V.W0(t, x), len) == True{} : Bool}:
  V.cf_ok(V.HC(V.W0(t, x), len), t, x, off, len, FD.logic__subst(Bool, z => {V.CZ(z, t, x, off, len) == True{} : Bool}, U32.is_eq(len, 0), False{}, ec, hchk))

def evb_of(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == False{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {V.EV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), t, x, off, len, V.EE(True{}, t, x, off, len, V.W0(t, x), V.B1(t, x, len)), V.B1(t, x, len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {V.CF(z, t, x, off, len) == True{} : Bool}, V.HC(V.W0(t, x), len), True{}, hc_of(t, x, off, len, ec, hchk),
    FD.logic__subst(Bool, z => {V.CZ(z, t, x, off, len) == True{} : Bool}, U32.is_eq(len, 0), False{}, ec, hchk))

def hcA(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {U32.is_eq(U32.and(V.W0(t, x), 3), 0) == True{} : Bool}:
  FD.logic__and_left(U32.is_eq(U32.and(V.W0(t, x), 3), 0), U32.is_le(V.W0(t, x), len), FD.logic__and_left(Bool.and(U32.is_eq(U32.and(V.W0(t, x), 3), 0), U32.is_le(V.W0(t, x), len)), Bool.and(U32.is_le(4, V.W0(t, x)), U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576)), hc))

def hcC(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {U32.is_le(4, V.W0(t, x)) == True{} : Bool}:
  FD.logic__and_left(U32.is_le(4, V.W0(t, x)), U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576), FD.logic__and_right(Bool.and(U32.is_eq(U32.and(V.W0(t, x), 3), 0), U32.is_le(V.W0(t, x), len)), Bool.and(U32.is_le(4, V.W0(t, x)), U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576)), hc))

def hcD(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576) == True{} : Bool}:
  FD.logic__and_right(U32.is_le(4, V.W0(t, x)), U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576), FD.logic__and_right(Bool.and(U32.is_eq(U32.and(V.W0(t, x), 3), 0), U32.is_le(V.W0(t, x), len)), Bool.and(U32.is_le(4, V.W0(t, x)), U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576)), hc))

# the first offset is four times the element count
def quadN(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {A.quad(U32.to_nat(V.NN(t, x))) == U32.to_nat(V.W0(t, x)) : Nat}:
  Equal.trans(Nat, A.quad(U32.to_nat(V.NN(t, x))), Nat.add(A.quad(U32.to_nat(V.NN(t, x))), 0n), U32.to_nat(V.W0(t, x)), Equal.sym(Nat, Nat.add(A.quad(U32.to_nat(V.NN(t, x))), 0n), A.quad(U32.to_nat(V.NN(t, x))), FD.nat__add_zero(A.quad(U32.to_nat(V.NN(t, x))))),
    Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(V.NN(t, x))), 0n), Nat.add(A.quad(U32.to_nat(V.NN(t, x))), U32.to_nat(U32.and(V.W0(t, x), 3))), U32.to_nat(V.W0(t, x)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(V.NN(t, x))), z), 0n, U32.to_nat(U32.and(V.W0(t, x), 3)), Equal.cong(U32, Nat, z => U32.to_nat(z), 0, U32.and(V.W0(t, x), 3), Equal.sym(U32, U32.and(V.W0(t, x), 3), 0, FD.u32alg__eq_of(U32.and(V.W0(t, x), 3), 0, hcA(t, x, len, hc))))),
      Equal.sym(Nat, U32.to_nat(V.W0(t, x)), Nat.add(A.quad(U32.to_nat(V.NN(t, x))), U32.to_nat(U32.and(V.W0(t, x), 3))), VC.split4(V.W0(t, x)))))

def nn1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {Nat.is_le(1n, U32.to_nat(V.NN(t, x))) == True{} : Bool}:
  V.quad_pos(U32.to_nat(V.NN(t, x)), FD.logic__subst(Nat, z => {Nat.is_le(4n, z) == True{} : Bool}, U32.to_nat(V.W0(t, x)), A.quad(U32.to_nat(V.NN(t, x))), Equal.sym(Nat, A.quad(U32.to_nat(V.NN(t, x))), U32.to_nat(V.W0(t, x)), quadN(t, x, len, hc)),
    FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(4, V.W0(t, x)), Nat.is_le(U32.to_nat(4), U32.to_nat(V.W0(t, x))), VU.le_u32(4, V.W0(t, x)), hcC(t, x, len, hc))))

def nn20(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(V.NN(t, x)), O.pow2n(20n)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(V.NN(t, x)), U32.to_nat(1048576), O.pow2n(20n),
    FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(U32.shrn(V.W0(t, x), 2n), 1048576), Nat.is_le(U32.to_nat(U32.shrn(V.W0(t, x), 2n)), U32.to_nat(1048576)), VU.le_u32(U32.shrn(V.W0(t, x), 2n), 1048576), hcD(t, x, len, hc)), hL20())

def dw_lt(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {Nat.is_lt(B.words_depth(V.NN(t, x)), 31n) == True{} : Bool}:
  FD.nat__le_lt_trans(B.words_depth(V.NN(t, x)), 20n, 31n, VD.wd_min(V.NN(t, x), 20n, nn20(t, x, len, hc)), {==})

def dw_cov(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(V.NN(t, x)), FD.spec_common__pow2(B.words_depth(V.NN(t, x)))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(V.NN(t, x)), z) == True{} : Bool}, O.pow2n(B.words_depth(V.NN(t, x))), FD.spec_common__pow2(B.words_depth(V.NN(t, x))),
    Equal.sym(Nat, FD.spec_common__pow2(B.words_depth(V.NN(t, x))), O.pow2n(B.words_depth(V.NN(t, x))), VD.s_pow2_eq(B.words_depth(V.NN(t, x)))), VD.wd_cover(V.NN(t, x), 20n, {==}, nn20(t, x, len, hc)))

def succ_pred(+y: Nat, +h: {Nat.is_le(1n, y) == True{} : Bool}) -> {1n+Nat.sub(y, 1n) == y : Nat}:
  match y:
    case 0n: Empty.absurd({1n+Nat.sub(0n, 1n) == 0n : Nat}, FD.logic__false_true(h))
    case 1n+p: Equal.cong(Nat, Nat, z => 1n+z, Nat.sub(p, 0n), p, FD.nat__sub_zero(p))

def inv0(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool})
    -> {Nat.add(U32.to_nat(0), 1n+U32.to_nat(U32.sub(V.NN(t, x), 1))) == U32.to_nat(V.NN(t, x)) : Nat}:
  Equal.trans(Nat, 1n+U32.to_nat(U32.sub(V.NN(t, x), 1)), 1n+Nat.sub(U32.to_nat(V.NN(t, x)), 1n), U32.to_nat(V.NN(t, x)),
    Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(U32.sub(V.NN(t, x), 1)), Nat.sub(U32.to_nat(V.NN(t, x)), 1n), FD.u32__sub_nat(V.NN(t, x), 1, nn1(t, x, len, hc))),
    succ_pred(U32.to_nat(V.NN(t, x)), nn1(t, x, len, hc)))

# the first element's end is the second offset (or the window's end, for a single element)
def nxk0(+k: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +inv: {Nat.add(U32.to_nat(0), 1n+k) == U32.to_nat(V.NN(t, x)) : Nat})
    -> {V.B1(t, x, len) == NXk(k, t, x, len, 0) : U32}:
  match k:
    case 0n:
      %Equal.sym(Bool, U32.is_eq(1, V.NN(t, x)), True{}, V.eqtr(1, V.NN(t, x), inv)) : {V.NX(_, t, x, len, 0) == len : U32}
      {==}
    case 1n+p:
      %Equal.sym(Bool, U32.is_eq(1, V.NN(t, x)), False{}, V.eqfr(1, V.NN(t, x), FD.nat__is_eq_lt(U32.to_nat(1), U32.to_nat(V.NN(t, x)),
          FD.logic__subst(Nat, z => {Nat.is_lt(1n, z) == True{} : Bool}, Nat.add(U32.to_nat(0), 1n+(1n+p)), U32.to_nat(V.NN(t, x)), inv, {==})))) : {V.NX(_, t, x, len, 0) == V.WJ(t, x, 0) : U32}
      {==}

def ev_start(+k: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +inv: {Nat.add(U32.to_nat(0), 1n+k) == U32.to_nat(V.NN(t, x)) : Nat},
    +evb: {V.EV(k, 0, V.NN(t, x), t, x, off, len, True{}, V.B1(t, x, len)) == True{} : Bool})
    -> {V.EV(k, 0, V.NN(t, x), t, x, off, len, True{}, V.WJ(t, x, 0)) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+p: FD.logic__subst(U32, z => {V.EV(1n+p, 0, V.NN(t, x), t, x, off, len, True{}, z) == True{} : Bool}, V.B1(t, x, len), V.WJ(t, x, 0), nxk0(1n+p, t, x, len, inv), evb)

# ---- the decoded list of a nonempty window ----
def arr_eq(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == False{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {V.RV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), d, t, x, off, len, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cap(V.NN(t, x))), V.OBJE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))) == RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))) : Array<O.Boxed<O.Words>>}:
  +hc = hc_of(t, x, off, len, ec, hchk)
  FD.logic__subst(Array<O.Boxed<O.Words>>, z => {V.RV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), d, t, x, off, len, z, V.OBJE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))) == RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))) : Array<O.Boxed<O.Words>>},
    RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{})), Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cap(V.NN(t, x))), Equal.sym(Array<O.Boxed<O.Words>>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cap(V.NN(t, x))), RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{})), fill_am(B.words_depth(V.NN(t, x)))),
    FD.logic__subst(O.Boxed<O.Words>, v => {V.RV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), d, t, x, off, len, RT.am_l1048576_bl1073741824(FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{})), v) == RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))) : Array<O.Boxed<O.Words>>},
      RT.th_bl1073741824_bx(XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))), V.OBJE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)), obje_canon(d, t, x, off, V.W0(t, x), V.B1(t, x, len)),
      rv_am(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)), FD.nat__lt_trans(B.words_depth(V.NN(t, x)), 31n, 32n, dw_lt(t, x, len, hc), {==}), FD.array__trep_perfect(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), dw_cov(t, x, len, hc), inv0(t, x, len, hc))))

def obj_eq(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == False{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {V.RZ(False{}, d, t, x, off, len) == Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))), V.NN(t, x)} : Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq}:
  Equal.cong(Array<O.Boxed<O.Words>>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, a => Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{a, V.NN(t, x)},
    V.RV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), d, t, x, off, len, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_fill(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cap(V.NN(t, x))), V.OBJE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))), RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))), arr_eq(d, t, x, off, len, ec, hchk))

def ee0_of(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == False{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {V.EE(True{}, t, x, off, len, V.W0(t, x), V.B1(t, x, len)) == True{} : Bool}:
  V.ev_ok(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), t, x, off, len, V.EE(True{}, t, x, off, len, V.W0(t, x), V.B1(t, x, len)), V.B1(t, x, len), evb_of(t, x, off, len, ec, hchk))

def ev0_of(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == False{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {V.EV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), t, x, off, len, True{}, V.WJ(t, x, 0)) == True{} : Bool}:
  ev_start(U32.to_nat(U32.sub(V.NN(t, x), 1)), t, x, off, len, inv0(t, x, len, hc_of(t, x, off, len, ec, hchk)),
    FD.logic__subst(Bool, z => {V.EV(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), t, x, off, len, z, V.B1(t, x, len)) == True{} : Bool}, V.EE(True{}, t, x, off, len, V.W0(t, x), V.B1(t, x, len)), True{}, ee0_of(t, x, off, len, ec, hchk), evb_of(t, x, off, len, ec, hchk)))

def nn_lim(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {V.HC(V.W0(t, x), len) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(V.NN(t, x)), U32.to_nat(1048576)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(V.NN(t, x), 1048576), Nat.is_le(U32.to_nat(V.NN(t, x)), U32.to_nat(1048576)), VU.le_u32(V.NN(t, x), 1048576), hcD(t, x, len, hc))

# ---- the list's representation invariant ----
def rep_c(+c: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == c : Bool}, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool}, +s: S.Schema, +es: {SH.ListOf_limit(s) == U32.to_nat(1048576) : Nat},
    +ee: {SH.ByteList_limit(SH.ListOf_element(s)) == U32.to_nat(1073741824) : Nat})
    -> RT.rep_l1048576_bl1073741824(V.RZ(c, d, t, x, off, len), s):
  match c:
    case True{}: ((FD.array__trep(RT.MB<RT.WMr>, 0n, RT.MNone{}), (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), FD.nat__zero_le(SH.ListOf_limit(s)))
    case False{}:
      +hc = hc_of(t, x, off, len, ec, hchk)
      (((RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))), (B.words_depth(V.NN(t, x)), (V.NN(t, x), (obj_eq(d, t, x, off, len, ec, hchk), (rvt_pf(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)), FD.array__trep_perfect(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{})),
        (FD.nat__lt_trans(B.words_depth(V.NN(t, x)), 31n, 32n, dw_lt(t, x, len, hc), {==}), (dw_cov(t, x, len, hc),
          rv_ereps(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), V.W0(t, x), V.B1(t, x, len), FD.nat__lt_trans(B.words_depth(V.NN(t, x)), 31n, 32n, dw_lt(t, x, len, hc), {==}), FD.array__trep_perfect(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}),
            dw_cov(t, x, len, hc), inv0(t, x, len, hc), hwN, ee0_of(t, x, off, len, ec, hchk), ev0_of(t, x, off, len, ec, hchk), SH.ListOf_element(s), ee, {==})))))))),
        FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(V.NN(t, x)), z) == True{} : Bool}, U32.to_nat(1048576), SH.ListOf_limit(s), Equal.sym(Nat, SH.ListOf_limit(s), U32.to_nat(1048576), es), nn_lim(t, x, len, hc)))

def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}, +s: S.Schema, +es: {SH.ListOf_limit(s) == U32.to_nat(1048576) : Nat},
    +ee: {SH.ByteList_limit(SH.ListOf_element(s)) == U32.to_nat(1073741824) : Nat}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> RT.rep_l1048576_bl1073741824(V.OBJw(d, t, x, off, len), s):
  rep_c(U32.is_eq(len, 0), d, t, x, off, len, {==}, hwN, hchk, s, es, ee)

# ---- the encode premise: the list's tree and each element's storage below depth 31 ----
def sdl_c(+c: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == c : Bool}, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> TX.sdt(V.RZ(c, d, t, x, off, len)):
  match c:
    case True{}: (FD.array__trep(RT.MB<RT.WMr>, 0n, RT.MNone{}), (0n, (0, ({==}, ({==}, ({==}, ({==}, {==})))))))
    case False{}:
      +hc = hc_of(t, x, off, len, ec, hchk)
      (RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))), (B.words_depth(V.NN(t, x)), (V.NN(t, x), (obj_eq(d, t, x, off, len, ec, hchk), (rvt_pf(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)), FD.array__trep_perfect(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{})),
        (dw_lt(t, x, len, hc), (dw_cov(t, x, len, hc),
          rv_sdks(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), V.W0(t, x), V.B1(t, x, len), FD.nat__lt_trans(B.words_depth(V.NN(t, x)), 31n, 32n, dw_lt(t, x, len, hc), {==}), FD.array__trep_perfect(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}),
            dw_cov(t, x, len, hc), inv0(t, x, len, hc), hwN, ee0_of(t, x, off, len, ec, hchk), ev0_of(t, x, off, len, ec, hchk), {==}))))))))

def sdl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool}) -> TX.sdt(V.OBJw(d, t, x, off, len)):
  sdl_c(U32.is_eq(len, 0), d, t, x, off, len, {==}, hwN, hchk)

# ---- the list's encoded byte count: four per element and the element bytes, which tile the window ----
def txl_c(+c: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ec: {U32.is_eq(len, 0) == c : Bool}, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {TX.TXL(V.RZ(c, d, t, x, off, len)) == U32.to_nat(len) : Nat}:
  match c:
    case True{}: Equal.sym(Nat, U32.to_nat(len), 0n, Equal.cong(U32, Nat, z => U32.to_nat(z), len, 0, FD.u32alg__eq_of(len, 0, ec)))
    case False{}:
      +hc = hc_of(t, x, off, len, ec, hchk)
      %Equal.sym(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, V.RZ(False{}, d, t, x, off, len), Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len)))), V.NN(t, x)}, obj_eq(d, t, x, off, len, ec, hchk)) :
        {TX.TXL(_) == U32.to_nat(len) : Nat}
      FD.logic__subst(FD.array__Tree<RT.MB<RT.WMr>>, z => {Nat.add(A.quad(U32.to_nat(V.NN(t, x))), TX.SUMN(U32.to_nat(V.NN(t, x)), FD.array__slots(RT.MB<RT.WMr>, z), 0n)) == U32.to_nat(len) : Nat},
        RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))), RT.tfz_l1048576_bl1073741824(RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))))), Equal.sym(FD.array__Tree<RT.MB<RT.WMr>>, RT.tfz_l1048576_bl1073741824(RT.am_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))))), RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))), RT.tfzam_l1048576_bl1073741824(RVT(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), XE(d, t, x, off, V.W0(t, x), V.B1(t, x, len))))),
        rv_sum(U32.to_nat(U32.sub(V.NN(t, x), 1)), 0, V.NN(t, x), B.words_depth(V.NN(t, x)), d, t, x, off, len, A.quad(U32.to_nat(V.NN(t, x))), FD.array__trep(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}), V.W0(t, x), V.B1(t, x, len), FD.nat__lt_trans(B.words_depth(V.NN(t, x)), 31n, 32n, dw_lt(t, x, len, hc), {==}), FD.array__trep_perfect(RT.MB<RT.WMr>, B.words_depth(V.NN(t, x)), RT.MNone{}),
          dw_cov(t, x, len, hc), inv0(t, x, len, hc), ee0_of(t, x, off, len, ec, hchk), ev0_of(t, x, off, len, ec, hchk), Equal.sym(U32, V.B1(t, x, len), NXk(U32.to_nat(U32.sub(V.NN(t, x), 1)), t, x, len, 0), nxk0(U32.to_nat(U32.sub(V.NN(t, x), 1)), t, x, len, inv0(t, x, len, hc))),
          Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(V.NN(t, x))), 0n), A.quad(U32.to_nat(V.NN(t, x))), U32.to_nat(V.W0(t, x)), FD.nat__add_zero(A.quad(U32.to_nat(V.NN(t, x)))), quadN(t, x, len, hc))))

def txl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}, +hchk: {V.CHKw(t, x, off, len) == True{} : Bool}) -> {TX.TXL(V.OBJw(d, t, x, off, len)) == U32.to_nat(len) : Nat}:
  txl_c(U32.is_eq(len, 0), d, t, x, off, len, {==}, hwN, hchk)
