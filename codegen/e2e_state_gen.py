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
    'import ../proofs/obj/big_var_winx_l1099511627776_u8.bend as W8', 'import ../proofs/obj/big_var_winx_l1099511627776_u64.bend as W64',
    'import ../proofs/obj/big_var_winx_l16777216_b32.bend as WH',
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
    import e2e_var_c as EVC
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

# GENERATED by codegen/e2e_bridge.py (codegen/e2e_state_gen.py). Do not edit.
# BeaconState's field views: the root view of each field object BeaconState's window reader builds is the
# codec value of that field (for the (ii)/(iii) assembly: e2e_vbx_BeaconState).
''' + BASE + lists_text()
