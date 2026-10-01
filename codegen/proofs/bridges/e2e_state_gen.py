"""BeaconState's field views for (ii)/(iii) (codec-top): e2e/e2e_stv.bend.

Each lemma states that the root view of a field object read at byte x of a perfect tree t of depth d
(< 28) is the codec value the decode law gives for that field:
  sbv4                 justification_bits (Bitvector[4], one byte: BVS.lowb)
  pvv                  a vector of 2^e Bytes32 copied into its own tree (block_roots, state_roots, randao_mixes)
  vv8                  a vector of 2^e uint64 copied into its own tree (slashings, proposer_lookahead)
  su8, su64            the uint8 / uint64 list windows (participation, balances, inactivity_scores)
  shr                  the Bytes32 list window (historical_roots)
Sizes are powers of two carried symbolically (vbig: u32pow, nw_pow, pw_mono); no closed size is evaluated.
"""
import re

HEAD = [
    'import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
    'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
    'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vbrt.bend as VR', 'import ../proofs/obj/vdepth.bend as VD',
    'import ../proofs/obj/vcopy.bend as VC', 'import ../proofs/obj/vspec.bend as VS', 'import ../proofs/obj/vlist.bend as VLS',
    'import ../proofs/obj/vua_ct.bend as UCT', 'import ../proofs/obj/vua_rd.bend as UR', 'import ../proofs/obj/vua_win.bend as UW',
    'import ../proofs/obj/vua_fixb.bend as VXB', 'import ../proofs/obj/vfxg.bend as VXG', 'import ../proofs/obj/arr_vec.bend as AV',
    'import ../proofs/obj/vmul.bend as VM', 'import ../proofs/obj/vbig.bend as VG', 'import ../proofs/obj/vbig.bend as VBG',
    'import ../proofs/obj/pv_obj.bend as PV', 'import ../proofs/obj/packed_obj.bend as PK', 'import ../proofs/obj/packed_bytes.bend as PBF',
    'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/blist_obj.bend as BLI',
    'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/words_spec.bend as WS', 'import ../proofs/obj/words_root.bend as WR',
    'import ../proofs/obj/var_elems.bend as EL', 'import ../proofs/obj/bitlist_pack.bend as BLP',
    'import ../proofs/obj/root_state.bend as ST',
    'import ../proofs/obj/vfx_bv4.bend as F4', 'import ../types/Fulu_bitvector_4_def_generated.bend as Fulu_bitvector_4_d',
    'import ../proofs/obj/var_winx_l1099511627776_u8.bend as W8', 'import ../proofs/obj/var_winx_l1099511627776_u64.bend as W64',
    'import ../proofs/obj/var_winx_l16777216_b32.bend as WH',
    'import ./e2e_bvsub.bend as BVS', 'import ./e2e_bvw.bend as BVW', 'import ./e2e_pv8.bend as EP8', 'import ./e2e_bx.bend as BXW',
    'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_plw.bend as PW']

BASE = r'''
# ---- justification_bits: the four low bits of the byte at x ----
def w4(+v: U32) -> {S.BitsValue{BLP.btk(4n, BLP.bitsof([v]))} == F4.VB4(v) : S.Value}:
  match v:
    case U32{WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, +r}}}}}: {==}

def sbv4(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat) -> {ST.v_bv4(F4.OBJ(d, t, x)) == F4.VAL(t, x) : S.Value}:
  Equal.trans(S.Value, ST.v_bv4(F4.OBJ(d, t, x)), S.BitsValue{BLP.btk(4n, BLP.bitsof([F4.BX(t, x)]))}, F4.VAL(t, x),
    Equal.cong(U32, S.Value, z => S.BitsValue{BLP.btk(4n, BLP.bitsof([z]))}, U32.and(UR.RWN(t, x), 255), F4.BX(t, x), BVS.lowb(t, x)),
    w4(F4.BX(t, x)))

# ---- counts ----
law me8:
  for +k: Nat
  {VM.mulE(8n, k) == AV.m8(k) : Nat}
def me8(k):
  match k:
    case 0n: {==}
    case 1n+ +q: Equal.cong(Nat, Nat, z => Nat.add(8n, z), VM.mulE(8n, q), AV.m8(q), me8(q))

# it8 over k pairs is chu2 of the first 2 k words
law ic2:
  for +k: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(AV.m2(k), VB.len(W)) == True{} : Bool}
  {PK.it8(k, W) == AV.chu2(VS.wtake(AV.m2(k), W)) : S.Value}
def ic2(k, W, h):
  match k W:
    case 0n _: {==}
    case 1n+ +q Nil{}: Empty.absurd({PK.it8(1n+q, Nil{}) == AV.chu2(VS.wtake(AV.m2(1n+q), Nil{})) : S.Value}, FD.logic__false_true(h))
    case 1n+ +q Con{+a0, Nil{}}: Empty.absurd({PK.it8(1n+q, [a0]) == AV.chu2(VS.wtake(AV.m2(1n+q), [a0])) : S.Value}, FD.logic__false_true(h))
    case 1n+ +q Con{+a0, Con{+a1, +r}}:
      Equal.cong(S.Value, S.Value, z => S.Items{S.UnsignedValue{P.UInt{a0, a1, 0, 0, 0, 0, 0, 0}}, z}, PK.it8(q, r), AV.chu2(VS.wtake(AV.m2(q), r)), ic2(q, r, h))

# ---- block_roots, state_roots, randao_mixes: 2^e Bytes32 copied into a tree of depth dz ----
def pvv(+d: Nat, +t: FD.array__Tree<U32>, +off: U32, +x: Nat, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +L: U32, +Ku: U32, +e: Nat, +dz: Nat, +M: Nat,
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +eL: {L == FD.u32__pow2u(5n+e) : U32}, +eK: {U32.shrn(L, 5n) == Ku : U32}, +eKu: {Ku == FD.u32__pow2u(e) : U32},
    +h6: {Nat.is_lt(6n+e, 32n) == True{} : Bool}, +hdz: {Nat.is_le(3n+e, dz) == True{} : Bool}, +eM: {M == AV.m8(U32.to_nat(Ku)) : Nat})
    -> {PV.pview(O.Words{FD.array__thaw(U32, VXB.CTN(d, t, x, L, dz)), L}) == S.Sequence{AV.ch8(UR.RWS(VXG.CNT(x, M), t, x))} : S.Value}:
  +C = VB.pw(e)
  +K = VM.mulE(8n, C)
  +CT = UCT.CT(d, t, off, L, dz)
  +h5 = FD.nat__lt_trans(5n+e, 6n+e, 32n, FD.nat__lt_succ(5n+e), h6)
  +he = FD.nat__le_lt_trans(e, 5n+e, 32n, Order.left_below_sum(5n, e), h5)
  +eKn = VG.u32pow(Ku, e, eKu, he)
  +eLn = VG.u32pow(L, 5n+e, eL, h5)
  +eS = Equal.trans(Nat, U32.to_nat(U32.shrn(L, 5n)), U32.to_nat(Ku), C, Equal.cong(U32, Nat, z => U32.to_nat(z), U32.shrn(L, 5n), Ku, eK), eKn)
  +eNN = Equal.trans(Nat, U32.to_nat(L), VB.pw(5n+e), WS.e32(U32.to_nat(U32.shrn(L, 5n))), eLn,
    Equal.sym(Nat, WS.e32(U32.to_nat(U32.shrn(L, 5n))), WS.e32(C), Equal.cong(Nat, Nat, z => WS.e32(z), U32.to_nat(U32.shrn(L, 5n)), C, eS)))
  +ec = Equal.trans(Nat, O.chunks_of(L), U32.to_nat(U32.shrn(L, 5n)), C, BLI.chq(L, eNN), eS)
  +eK8 = Equal.trans(Nat, K, AV.m8(C), VB.pw(3n+e), me8(C), VG.m8_d3(C))
  +hr = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, VB.pw(3n+e), K, Equal.sym(Nat, K, VB.pw(3n+e), eK8), VG.pw_mono(3n+e, dz, hdz))
  +A1 = EP8.pv8(CT, dz, BVW.ctps(VR.RX(off), d, t, off, L, dz), L, C, ec, hr)
  +hrw = VG.nw_pow(L, 3n+e, dz, eL, h6, hdz)
  +eLq = Equal.trans(Nat, U32.to_nat(L), A.quad(VB.pw(3n+e)), A.quad(K), eLn, Equal.cong(Nat, Nat, z => A.quad(z), VB.pw(3n+e), K, Equal.sym(Nat, K, VB.pw(3n+e), eK8)))
  +B1 = BXW.ctw(d, t, off, L, dz, x, K, eo, hd, hw, pf, hrw, eLq)
  +eMC = Equal.trans(Nat, M, AV.m8(U32.to_nat(Ku)), AV.m8(C), eM, Equal.cong(Nat, Nat, z => AV.m8(z), U32.to_nat(Ku), C, eKn))
  +eKM = Equal.trans(Nat, K, AV.m8(C), M, me8(C), Equal.sym(Nat, M, AV.m8(C), eMC))
  %VXB.ct_n(d, t, off, x, L, dz, eo) : {PV.pview(O.Words{FD.array__thaw(U32, _), L}) == S.Sequence{AV.ch8(UR.RWS(VXG.CNT(x, M), t, x))} : S.Value}
  %Equal.sym(Nat, VXG.CNT(x, M), M, VXG.cnt_eq(x, M)) : {PV.pview(O.Words{FD.array__thaw(U32, CT), L}) == S.Sequence{AV.ch8(UR.RWS(_, t, x))} : S.Value}
  %eKM : {PV.pview(O.Words{FD.array__thaw(U32, CT), L}) == S.Sequence{AV.ch8(UR.RWS(_, t, x))} : S.Value}
  Equal.trans(S.Value, PV.pview(O.Words{FD.array__thaw(U32, CT), L}), S.Sequence{AV.ch8(VS.wtake(K, FD.array__slots(U32, CT)))}, S.Sequence{AV.ch8(UR.RWS(K, t, x))}, A1,
    Equal.cong(List<&2, U32>, S.Value, z => S.Sequence{AV.ch8(z)}, VS.wtake(K, FD.array__slots(U32, CT)), UR.RWS(K, t, x), B1))

# ---- slashings, proposer_lookahead: 2^e uint64 copied into a tree of depth dz ----
def vv8(+d: Nat, +t: FD.array__Tree<U32>, +off: U32, +x: Nat, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +L: U32, +Ku: U32, +e: Nat, +dz: Nat, +M: Nat,
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +eL: {L == FD.u32__pow2u(3n+e) : U32}, +eK: {U32.shrn(L, 3n) == Ku : U32}, +eKu: {Ku == FD.u32__pow2u(e) : U32},
    +h4: {Nat.is_lt(4n+e, 32n) == True{} : Bool}, +hdz: {Nat.is_le(1n+e, dz) == True{} : Bool}, +eM: {M == AV.m2(U32.to_nat(Ku)) : Nat})
    -> {PK.vview8(O.Words{FD.array__thaw(U32, VXB.CTN(d, t, x, L, dz)), L}) == S.Sequence{AV.chu2(UR.RWS(VXG.CNT(x, M), t, x))} : S.Value}:
  +C = VB.pw(e)
  +K = AV.m2(C)
  +CT = UCT.CT(d, t, off, L, dz)
  +h3 = FD.nat__lt_trans(3n+e, 4n+e, 32n, FD.nat__lt_succ(3n+e), h4)
  +he = FD.nat__le_lt_trans(e, 3n+e, 32n, Order.left_below_sum(3n, e), h3)
  +eKn = VG.u32pow(Ku, e, eKu, he)
  +eLn = VG.u32pow(L, 3n+e, eL, h3)
  +eS = Equal.trans(Nat, U32.to_nat(U32.shrn(L, 3n)), U32.to_nat(Ku), C, Equal.cong(U32, Nat, z => U32.to_nat(z), U32.shrn(L, 3n), Ku, eK), eKn)
  +eK2 = VG.m2_d1(C)
  +hK = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, VB.pw(1n+e), K, Equal.sym(Nat, K, VB.pw(1n+e), eK2), VG.pw_mono(1n+e, dz, hdz))
  +hKl = FD.logic__subst(Nat, z => {Nat.is_le(K, z) == True{} : Bool}, VB.pw(dz), VB.len(FD.array__slots(U32, CT)),
    Equal.sym(Nat, VB.len(FD.array__slots(U32, CT)), VB.pw(dz), FD.array__slots_length(U32, dz, CT, BVW.ctps(VR.RX(off), d, t, off, L, dz))), hK)
  +hrw = VG.nw_pow(L, 1n+e, dz, eL, h4, hdz)
  +eLq = Equal.trans(Nat, U32.to_nat(L), A.quad(VB.pw(1n+e)), A.quad(K), eLn, Equal.cong(Nat, Nat, z => A.quad(z), VB.pw(1n+e), K, Equal.sym(Nat, K, VB.pw(1n+e), eK2)))
  +B1 = BXW.ctw(d, t, off, L, dz, x, K, eo, hd, hw, pf, hrw, eLq)
  +eMC = Equal.trans(Nat, M, AV.m2(U32.to_nat(Ku)), K, eM, Equal.cong(Nat, Nat, z => AV.m2(z), U32.to_nat(Ku), C, eKn))
  %VXB.ct_n(d, t, off, x, L, dz, eo) : {PK.vview8(O.Words{FD.array__thaw(U32, _), L}) == S.Sequence{AV.chu2(UR.RWS(VXG.CNT(x, M), t, x))} : S.Value}
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, CT)), CT, FD.array__freeze_thaw(U32, CT)) :
    {S.Sequence{PK.it8(U32.to_nat(U32.shrn(L, 3n)), FD.array__slots(U32, _))} == S.Sequence{AV.chu2(UR.RWS(VXG.CNT(x, M), t, x))} : S.Value}
  %Equal.sym(Nat, U32.to_nat(U32.shrn(L, 3n)), C, eS) : {S.Sequence{PK.it8(_, FD.array__slots(U32, CT))} == S.Sequence{AV.chu2(UR.RWS(VXG.CNT(x, M), t, x))} : S.Value}
  %Equal.sym(Nat, VXG.CNT(x, M), M, VXG.cnt_eq(x, M)) : {S.Sequence{PK.it8(C, FD.array__slots(U32, CT))} == S.Sequence{AV.chu2(UR.RWS(_, t, x))} : S.Value}
  %Equal.sym(Nat, M, K, eMC) : {S.Sequence{PK.it8(C, FD.array__slots(U32, CT))} == S.Sequence{AV.chu2(UR.RWS(_, t, x))} : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, PK.it8(C, FD.array__slots(U32, CT)), AV.chu2(UR.RWS(K, t, x)),
    Equal.trans(S.Value, PK.it8(C, FD.array__slots(U32, CT)), AV.chu2(VS.wtake(K, FD.array__slots(U32, CT))), AV.chu2(UR.RWS(K, t, x)),
      ic2(C, FD.array__slots(U32, CT), hKl),
      Equal.cong(List<&2, U32>, S.Value, z => AV.chu2(z), VS.wtake(K, FD.array__slots(U32, CT)), UR.RWS(K, t, x), B1)))
# ---- historical_roots: the Bytes32 list window ----
law r32:
  for +c: Nat
  {VD.s_rng(5n, Nat.mul(c, 32n)) == c : Nat}
def r32(c):
  match c:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, VD.s_rng(5n, Nat.mul(p, 32n)), p, r32(p))

law lwt:
  for +n: Nat
  for +W: List<&2, U32>
  {Nat.is_le(VB.len(VS.wtake(n, W)), VB.len(W)) == True{} : Bool}
def lwt(n, W):
  match n W:
    case 0n _: FD.nat__zero_le(VB.len(W))
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+a, +r}: lwt(p, r)

def shr(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hc: {WH.CHKw(t, x, off, len) == True{} : Bool}) -> {BLI.hview(WH.OBJw(d, t, x, off, len)) == WH.VALw(t, x, len) : S.Value}:
  +c = WH.CC(len)
  +Mq = WH.MQ(len)
  +M = UCT.CT(d, t, off, len, VLS.DZ(len))
  +Sl = FD.array__slots(U32, M)
  +R = UR.RWS(Mq, t, x)
  +hL = FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw)
  +B1 = BXW.ctw(d, t, off, len, VLS.DZ(len), x, Mq, eo, hd, hw, pf, VLS.hrg(d, len, hd, hL), WH.eqw(len, hc))
  +eLW = Equal.trans(Nat, VB.len(VS.wtake(Mq, Sl)), VB.len(R), Mq, Equal.cong(List<&2, U32>, Nat, z => VB.len(z), VS.wtake(Mq, Sl), R, B1), UR.rws_len(Mq, t, x))
  +hS = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(Sl)) == True{} : Bool}, VB.len(VS.wtake(Mq, Sl)), Mq, eLW, lwt(Mq, Sl))
  +h0 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(Sl)) == True{} : Bool}, Mq, Nat.add(Mq, 0n), Equal.sym(Nat, Nat.add(Mq, 0n), Mq, FD.nat__add_zero(Mq)), hS)
  +hR = FD.logic__subst(Nat, z => {Nat.is_le(Mq, z) == True{} : Bool}, Mq, VB.len(R), Equal.sym(Nat, VB.len(R), Mq, UR.rws_len(Mq, t, x)), FD.nat__le_refl(Mq))
  +eS5 = Equal.trans(Nat, U32.to_nat(U32.shrn(len, 5n)), VD.s_rng(5n, U32.to_nat(len)), c, VD.shrk(5n, len),
    Equal.trans(Nat, VD.s_rng(5n, U32.to_nat(len)), VD.s_rng(5n, Nat.mul(c, 32n)), c, Equal.cong(Nat, Nat, z => VD.s_rng(5n, z), U32.to_nat(len), Nat.mul(c, 32n), WH.ecw(len, hc)), r32(c)))
  +L1 = Equal.trans(S.Value, WR.items(c, Sl, 0n), VM.bvit(c, 8n, Sl), AV.ch8(VS.wtake(Mq, Sl)), EP8.pit(c, 0n, Sl, h0), EP8.bch8(c, Sl, hS))
  +R1 = Equal.trans(S.Value, VM.bvit(c, 8n, R), AV.ch8(VS.wtake(Mq, R)), AV.ch8(VS.wtake(Mq, Sl)), EP8.bch8(c, R, hR),
    Equal.trans(S.Value, AV.ch8(VS.wtake(Mq, R)), AV.ch8(R), AV.ch8(VS.wtake(Mq, Sl)), Equal.cong(List<&2, U32>, S.Value, z => AV.ch8(z), VS.wtake(Mq, R), R, UR.wtake_rws(Mq, t, x)),
      Equal.cong(List<&2, U32>, S.Value, z => AV.ch8(z), R, VS.wtake(Mq, Sl), Equal.sym(List<&2, U32>, VS.wtake(Mq, Sl), R, B1))))
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, M)), M, FD.array__freeze_thaw(U32, M)) :
    {S.Sequence{WR.items(U32.to_nat(U32.shrn(len, 5n)), FD.array__slots(U32, _), 0n)} == WH.VALw(t, x, len) : S.Value}
  %Equal.sym(Nat, U32.to_nat(U32.shrn(len, 5n)), c, eS5) : {S.Sequence{WR.items(_, Sl, 0n)} == WH.VALw(t, x, len) : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, WR.items(c, Sl, 0n), VM.bvit(c, 8n, R),
    Equal.trans(S.Value, WR.items(c, Sl, 0n), AV.ch8(VS.wtake(Mq, Sl)), VM.bvit(c, 8n, R), L1, Equal.sym(S.Value, VM.bvit(c, 8n, R), AV.ch8(VS.wtake(Mq, Sl)), R1)))
'''


def lists_text():
    """su8 / su64: e2e-c's pu8 / pu64 (e2e_gprog: the progressive windows' views) for BeaconState's list windows,
    whose readers and values have the same shape."""
    from codegen.proofs.bridges import e2e_var_c as EVC
    g = EVC.gprog_text()
    out = []
    for name in ('pu8', 'uu', 'ut', 'xb2', 'pu64'):
        m = re.search(r'^def ' + name + r'\(.*?(?=\n\n|\n# |\ndef |\Z)', g, re.M | re.S)
        out.append(m.group(0))
    s = '\n\n'.join(out)
    s = re.sub(r'(?<![\w.])PU8\.', 'W8.', s)
    s = re.sub(r'(?<![\w.])PU64\.', 'W64.', s)
    s = re.sub(r'(?<![\w.])pu8\(', 'su8(', s)
    s = re.sub(r'(?<![\w.])pu64\(', 'su64(', s)
    return '\n# ---- the participation lists (uint8) and balances / inactivity_scores (uint64): e2e-c\'s progressive-window views ----\n' + s + '\n'


def text():
    return '\n'.join(HEAD) + '''

# GENERATED by e2e_bridge (codegen: e2e_state_gen). Do not edit.
# BeaconState's field views: the root view of each field object BeaconState's window reader builds is the
# codec value of that field (for the (ii)/(iii) assembly: e2e_vbx_BeaconState).
''' + BASE + lists_text()


# ---- BeaconState (ii)/(iii): its window (var_winx_BeaconState) through e2e-b's vbx_module, with the fields as holes ----
FSZ = 2737225   # the fixed part's bytes (hF)


def _fx(K):
    x1 = f'Nat.add(x, U32.to_nat({K}))'
    eo = f'W.eocX(d, t, 0, x, off, len, eo, hd, hw, pf, hF, {K}, U32.to_nat({K}), {{==}}, VA.le_nat({K}, {FSZ}, {{==}}))'
    return x1, eo


def _hw(K, S):
    return f'W.roomFX(d, t, 0, x, off, len, eo, hd, hw, pf, hF, U32.to_nat({K}), U32.to_nat({S}), VA.lea({K}, {S}, {FSZ}, U32.to_nat({S}), {{==}}, {{==}}, {{==}}))'


def _ch(j, lj=None):
    L = lj or f'LJ{j}(t, x)'
    args = f'XJ{j}(t, x), FJ{j}(off, t, x), {L}'
    q = lambda s: re.sub(r'(?<![\w.])(XJ\d+|FJ\d+|LJ\d+)\(', r'W.\1(', s)
    A6 = 'd, t, 0, x, off, len, eo, hd, hw, pf, hchk'
    return args, [q(f'XJ{j}(t, x)'), q(f'FJ{j}(off, t, x)'), q(L)], f'W.eoJ{j}({A6})', f'W.hwJ{j}({A6})', f'W.itD{j}(t, x, off, len, hchk)'


def state_holes():
    H = []
    for K, (M, L, Ku, e, dz, Mv) in ((176, ('pvv', 262144, 8192, 13, 17, 'AV.m8(U32.to_nat(8192))')), (262320, ('pvv', 262144, 8192, 13, 17, 'AV.m8(U32.to_nat(8192))')),
                                    (524560, ('pvv', 2097152, 65536, 16, 20, 'AV.m8(U32.to_nat(65536))')), (2621712, ('vv8', 65536, 8192, 13, 15, 'AV.m2(U32.to_nat(8192))')),
                                    (2736713, ('vv8', 512, 64, 6, 8, '128n'))):
        mod = {(262144, 'pvv'): 'FX_v8192_b32', (2097152, 'pvv'): 'FX_v65536_b32', (65536, 'vv8'): 'FX_v8192_u64', (512, 'vv8'): 'FX_v64_u64'}[(L, M)]
        x1, eo = _fx(K)
        H.append({'obj': f'{mod}.OBJ(d, t, {x1})', 'ty': 'O.Words', 'view': 'PV.pview' if M == 'pvv' else 'PK.vview8', 'vty': 'S.Value',
                  'xvt': f'{mod}.VAL(t, {x1})',
                  'pf': f'SV.{M}(d, t, U32.add(off, {K}), {x1}, {eo}, hd, {L}, {Ku}, {e}n, {dz}n, {Mv}, {_hw(K, L)}, pf, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})'})
    x1, _ = _fx(2687256)
    H.append({'obj': f'FX_bv4.OBJ(d, t, {x1})', 'ty': 'Fulu_bitvector_4_d.Bitvector4', 'view': 'RT.v_bv4', 'vty': 'S.Value', 'xvt': f'FX_bv4.VAL(t, {x1})',
              'pf': f'SV.sbv4(d, t, {x1})'})
    for K in (2687381, 2712005):
        x1, eo = _fx(K)
        H.append({'obj': f'FX_SyncCommittee.OBJ(d, t, {x1})', 'ty': 'FuluSyncCommittee_d.SyncCommittee', 'view': 'RT.v_SyncCommittee', 'vty': 'S.Value',
                  'xvt': f'FX_SyncCommittee.VAL(t, {x1})', 'pf': f'FXE.fxsc(d, t, U32.add(off, {K}), {x1}, {eo}, hd, {_hw(K, 24576)}, pf)'})
    # the list windows
    for j, lem, view, ty in ((0, 'SV.shr', 'BLI.hview', 'O.Words'), (3, 'SV.su64', 'UL.uview', 'O.Words'), (6, 'SV.su64', 'UL.uview', 'O.Words'),
                             (4, 'SV.su8', 'PB.vview1', 'O.Words'), (5, 'SV.su8', 'PB.vview1', 'O.Words')):
        a, qa3, eo, hw_, it = _ch(j)
        H.append({'obj': f'CH{j}.OBJw(d, t, {a})', 'ty': ty, 'view': view, 'vty': 'S.Value', 'xvt': f'CH{j}.VALw(t, XJ{j}(t, x), LJ{j}(t, x))',
                  'pf': f'{lem}(d, t, {qa3[0]}, {qa3[1]}, {qa3[2]}, {eo}, hd, {hw_}, pf, {it})'})
    for j, V, ty, lj in ((1, 'l2048_Eth1Data', 'Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq', None),
                         (2, 'l1099511627776_Validator', 'Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq', None),
                         (8, 'l16777216_HistoricalSummary', 'Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq', None),
                         (9, 'l134217728_PendingDeposit', 'Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq', None),
                         (10, 'l134217728_PendingPartialWithdrawal', 'Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq', None),
                         (11, 'l262144_PendingConsolidation', 'Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq', 'LJ11(t, x, len)')):
        a, qa, eo, hw_, it = _ch(j, lj)
        H.append({'obj': f'CH{j}.OBJw(d, t, {a})', 'ty': ty, 'view': f'RT.xv_{V}', 'vty': 'S.Value', 'xvt': f'CH{j}.VALw(t, XJ{j}(t, x), {lj or f"LJ{j}(t, x)"})',
                  'pf': f'VL{j}.vl(d, t, {", ".join(qa)}, {it})'})
    a, qa3, eo, hw_, it = _ch(7)
    H.append({'obj': f'O.BSome{{CH7.OBJw(d, t, {a}), O.BNone{{}}}}', 'ty': 'O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>',
              'view': 'RT.v_ExecutionPayloadHeader_bx', 'vty': 'S.Value', 'xvt': 'CH7.VALw(t, XJ7(t, x), LJ7(t, x))',
              'pf': f'VEH.vb(d, t, {qa3[0]}, {qa3[1]}, {qa3[2]}, {eo}, hd, {hw_}, pf, {it})'})
    return H


# ==== the same at any tree depth (d < 31, the window within NMAX): BeaconState (ii)/(iii) at n <= NMAX ====
# Each field lemma's copy is bounded by its length (hy: 31 + L <= UMAX, e2e_bx's ctwY / bvgY / fbvY, e2e_blist's
# bviewY) in place of d < 28; the window's facts are its D / N ones (d < 31, hwN).
HY = '+hy: {Nat.is_le(VC.YL(@L@), U32.to_nat(VB.UMAX())) == True{} : Bool}'
HD28 = '+hd: {Nat.is_lt(d, 28n) == True{} : Bool}'
DEEP_HEAD = ['import ../proofs/obj/spec_fixed.bend as F', 'import ../proofs/obj/elems48.bend as E48', 'import ../proofs/obj/root_names_light.bend as RN',
             'import ../proofs/obj/root_types.bend as RT', 'import ../proofs/obj/vfx_SyncCommittee.bend as FSC',
             'import ../proofs/obj/var_bytesx_ExecutionPayloadHeader.bend as XW', 'import ../types/FuluBytes48_def_generated.bend as FuluBytes48_d',
             'import ./e2e_fx.bend as FXE', 'import ./e2e_e48w.bend as EW', 'import ./e2e_vbx_ExecutionPayloadHeader.bend as VEH']


def _block(text, name):
    a = text.index(f'\ndef {name}(') + 1
    m = re.search(r'\n(?=\n|# |def |law )', text[a:])
    return text[a:a + m.start()] if m else text[a:]


def _nohd(s):
    assert not re.search(r'(?<![\w.])hd(?![\w])', s), s[:200]
    return s


def deep_text():
    from codegen.proofs.bridges import e2e_var_b as EVB
    full = BASE + lists_text()
    out = ['''
# ---- the same at any tree depth: each copy bounded by its length (hy), the window within NMAX ----
def w32(+S: Nat, +h: {Nat.is_le(S, U32.to_nat(VB.NMAX())) == True{} : Bool}) -> {Nat.is_lt(S, FD.spec_common__pow2(32n)) == True{} : Bool}:
  +h1 = Order.add_left(31n, S, U32.to_nat(VB.NMAX()), h)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, S), z) == True{} : Bool}, Nat.add(31n, U32.to_nat(VB.NMAX())), U32.to_nat(VB.UMAX()), VB.e_umax(), h1)
  VB.umax_lt(S, FD.nat__le_trans(S, Nat.add(31n, S), U32.to_nat(VB.UMAX()), Order.left_below_sum(31n, S), h2))
''']
    for nm in ('pvv', 'vv8'):
        b = _block(full, nm).replace(f'def {nm}(', f'def {nm}Y(', 1)
        assert b.count(', ' + HD28 + ',\n    +L: U32') == 1
        b = b.replace(', ' + HD28 + ',\n    +L: U32', ',\n    +L: U32', 1)
        b = b.replace('+M: Nat,', '+M: Nat, ' + HY.replace('@L@', 'L') + ',', 1)
        b = b.replace('BXW.ctw(d, t, off, L, dz, x, K, eo, hd, hw,', 'BXW.ctwY(d, t, off, L, dz, x, K, eo, hy, hw,')
        out.append(_nohd(b))
    for nm in ('shr', 'su64'):
        b = _block(full, nm).replace(f'def {nm}(', f'def {nm}Y(', 1).replace(HD28, HY.replace('@L@', 'len'), 1)
        b = re.sub(r'BXW\.ctw\((d, t, off, len, VLS\.DZ\(len\), x, [^,]+(?:\([^)]*\))?, eo), hd, hw, pf, VLS\.hrg\(d, len, hd, hL\)',
                   r'BXW.ctwY(\1, hy, hw, pf, VC.hrgU(len, hy)', b)
        out.append(_nohd(b))
    b = _block(full, 'su8').replace('def su8(', 'def su8Y(', 1).replace(HD28, HY.replace('@L@', 'len'), 1)
    b = b.replace('BL.bview(d, t, off, len, x, eo, hd, hw, pf)', 'BL.bviewY(d, t, off, len, x, eo, hw, pf, hy)')
    out.append(_nohd(b))
    # the sync committees (e2e_fx's pkc / fxsc)
    fx = EVB.fx_text()
    HY24 = 'VC.hyU(24576, 15n, {==}, {==})'
    for nm in ('pkc', 'fxsc'):
        b = _block(fx, nm).replace(f'def {nm}(', f'def {nm}Y(', 1).replace(', ' + HD28 + ',\n', ',\n', 1)
        b = b.replace('BX.ctw(d, t, off, 24576, 13n, y, 6144n, eo, hd, hw,', f'BXW.ctwY(d, t, off, 24576, 13n, y, 6144n, eo, {HY24}, hw,')
        b = b.replace('pkc(d, t, off, y, eo, hd, hw, pf)', 'pkcY(d, t, off, y, eo, hw, pf)')
        b = re.sub(r'(?<![\w.])ltk\(', 'FXE.ltk(', b)
        out.append(_nohd(b))
    # the latest execution payload header (e2e-b's e2e_vbx_ExecutionPayloadHeader.vb): its window's D facts, its copies' hy
    veh = EVB.SUPPORT_OUT['e2e_vbx_ExecutionPayloadHeader.bend']
    b = _block(veh, 'vb').replace('def vb(', 'def ephY(', 1)
    b = b.replace('+hd: {Nat.is_lt(d, 28n) == True{} : Bool},', '+hd: {Nat.is_lt(d, 31n) == True{} : Bool},', 1)
    b = b.replace('+hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},',
                  '+hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},', 1)
    b = re.sub(r'(?<![\w.])W\.', 'XW.', b)
    b = re.sub(r'(?<![\w.])BX\.', 'BXW.', b)
    b = re.sub(r'\n  vz\(', '\n  VEH.vz(', b)
    b = re.sub(r'XW\.eoc\(d, x, off, len, (\d+), \{==\}, eo, hd, hw, ha\)', r'XW.eocD(d, x, off, len, \1, {==}, eo, hd, hw, hw32, ha)', b)
    assert b.count('), hd, XW.roomc(') == 1 and b.count('), hd, XW.hwv(') == 1, b[-800:]
    b = b.replace('BXW.fbv(', 'BXW.fbvY(').replace('), hd, XW.roomc(', '), VC.hyU(256, 9n, {==}, {==}), XW.roomc(')
    b = b.replace('BXW.bvg(', 'BXW.bvgY(').replace('), hd, XW.hwv(', '), VC.hyU(XW.LL(len), 6n, {==}, XW.hyL(len, hx)), XW.hwv(')
    b = b.replace('\n  +ha = ', '\n  +hw32 = w32(Nat.add(x, U32.to_nat(len)), hwN)\n  +ha = ', 1)
    out.append(b)
    return '\n'.join(out) + '\n'


def text_deep():
    t = text()
    h = '\n'.join(HEAD)
    assert t.startswith(h)
    return '\n'.join(HEAD + [i for i in DEEP_HEAD if i not in HEAD]) + t[len(h):] + deep_text()


def _fxD(K):
    x1 = f'Nat.add(x, U32.to_nat({K}))'
    eo = f'W.eocXD(d, t, 0, x, off, len, eo, hd, hw, hwN, pf, hF, {K}, U32.to_nat({K}), {{==}}, VA.le_nat({K}, {FSZ}, {{==}}))'
    return x1, eo


def _hwD(K, S):
    return f'W.roomFXD(d, t, 0, x, off, len, eo, hd, hw, hwN, pf, hF, U32.to_nat({K}), U32.to_nat({S}), VA.lea({K}, {S}, {FSZ}, U32.to_nat({S}), {{==}}, {{==}}, {{==}}))'


def _hyC(L):
    p = L.bit_length() - 1
    assert L == 1 << p and p >= 5
    return f'VC.hyU({L}, {p + 1}n, {{==}}, VG.yl_pow({L}, {p}n, {p + 1}n, {{==}}, {{==}}, {{==}}, {{==}}))'


def state_holes_deep():
    H = state_holes()
    A6D = 'd, t, 0, x, off, len, eo, hd, hw, hwN, pf, hchk'
    out = []
    for h in H:
        pf = h['pf']
        m = re.match(r'SV\.(pvv|vv8)\(d, t, U32\.add\(off, (\d+)\), (Nat\.add\(x, U32\.to_nat\(\d+\)\)), W\.eocX\(.*?\), hd, (\d+), (\d+), (\d+)n, (\d+)n, (.*?), W\.roomFX\(', pf)
        if m:
            M, K, x1, L, Ku, e, dz, Mv = m.groups()
            _, eo = _fxD(int(K))
            pf = (f'SV.{M}Y(d, t, U32.add(off, {K}), {x1}, {eo}, {L}, {Ku}, {e}n, {dz}n, {Mv}, {_hyC(int(L))}, {_hwD(int(K), int(L))}, pf, '
                  + ', '.join(['{==}'] * 6) + ')')
        elif pf.startswith('FXE.fxsc('):
            K = int(re.search(r'U32\.add\(off, (\d+)\)', pf).group(1))
            x1, eo = _fxD(K)
            pf = f'SV.fxscY(d, t, U32.add(off, {K}), {x1}, {eo}, {_hwD(K, 24576)}, pf)'
        elif re.match(r'SV\.(shr|su64|su8)\(', pf):
            m = re.match(r'SV\.(\w+)\(d, t, (W\.XJ(\d+)\(t, x\)), (W\.FJ\d+\(off, t, x\)), (W\.LJ\d+\(t, x(?:, len)?\)), ', pf)
            lem, X, j, F_, L = m.groups()
            pf = (f'SV.{lem}Y(d, t, {X}, {F_}, {L}, W.eoJ{j}D({A6D}), VC.hyW({X}, {L}, W.hwJ{j}N({A6D})), W.hwJ{j}D({A6D}), pf, W.itD{j}(t, x, off, len, hchk))')
        elif pf.startswith('VEH.vb('):
            m = re.match(r'VEH\.vb\(d, t, (W\.XJ(\d+)\(t, x\)), (W\.FJ\d+\(off, t, x\)), (W\.LJ\d+\(t, x(?:, len)?\)), ', pf)
            X, j, F_, L = m.groups()
            pf = f'SV.ephY(d, t, {X}, {F_}, {L}, W.eoJ{j}D({A6D}), hd, W.hwJ{j}D({A6D}), W.hwJ{j}N({A6D}), pf, W.itD{j}(t, x, off, len, hchk))'
        else:
            assert pf.startswith('SV.sbv4(') or pf.startswith('VL'), pf
        assert not re.search(r'W\.(eocX|roomFX|eoJ\d+|hwJ\d+)\(', pf) or 'D(' in pf or 'N(' in pf, pf
        out.append(dict(h, pf=pf))
    return out


def vbx_state_deep():
    from codegen.proofs.bridges import e2e_var_b as EVB
    imps = ['import ./e2e_stv.bend as SV', 'import ../proofs/obj/vbig.bend as VG',
            'import ../proofs/obj/packed_bytes.bend as PB', 'import ../proofs/obj/packed_obj.bend as PK', 'import ../proofs/obj/ulist_obj.bend as UL',
            'import ../proofs/obj/blist_obj.bend as BLI', 'import ../proofs/obj/arr_vec.bend as AV']
    for j, V in ((1, 'l2048_Eth1Data'), (2, 'l1099511627776_Validator'), (8, 'l16777216_HistoricalSummary'), (9, 'l134217728_PendingDeposit'),
                 (10, 'l134217728_PendingPartialWithdrawal'), (11, 'l262144_PendingConsolidation')):
        imps.append(f'import ./e2e_vl_{V}.bend as VL{j}')
    txt = EVB.vbx_module('BeaconState', 'var_winx_BeaconState', state_holes_deep(), ['+hF = W.hFc(t, x, off, len, hchk)'], imps)
    a = '+hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},'
    assert txt.count(a) == 1
    txt = txt.replace(a, '+hd: {Nat.is_lt(d, 31n) == True{} : Bool},\n    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, '
                         '+hwN: {Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool},')
    return EVB.st_qualify(txt)


def vdec_state_deep():
    return {'view': 'ST.v_BeaconState', 'imports': ['import ../proofs/obj/root_state.bend as ST', 'import ./e2e_vbx_BeaconState.bend as VWX',
                                                    'import ../proofs/obj/vbuf.bend as VB'],
            'text': '''# ---- the view of a decoded BeaconState is the codec law's value (the window's view at offset 0, within NMAX) ----

def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, @BD@) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{} : Bool}, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool},
    +hchk: {DC.CHK(t, n) == True{} : Bool}) -> {ST.v_BeaconState(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}:
  VWX.vb(d, t, 0n, 0, n, {==}, hd, hn,
    FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, VB.NMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())), VB.le_u32n(n, VB.NMAX()), hN), pf, hchk)

'''}
