"""BeaconState (i) (codec-top): the encode record (big_encx_BeaconState_iface's CI.MW) of every object the root law
represents, with the storage premises the root law does not give (decoded-object gaps, named).

  e2e/e2e_bsx.bend        the fixed fields' values, justification_bits, the vectors (block_roots, state_roots,
                          randao_mixes: Bytes32; slashings, proposer_lookahead: uint64) and the sync committees
                          as their records' parts (R_PV, R_V2, R_SC): sizes are powers of two, carried
                          symbolically (vbig: u32pow, quadpw; no closed power is evaluated)
  e2e/e2e_bsl.bend        the byte-storage lists (historical_roots: Bytes32; balances, inactivity_scores: uint64;
                          the participation lists: uint8) and the latest execution payload header as records
                          (R_H, R_U, R_B8, R_EH), each with its encoded length from the object alone
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OBJ = ROOT / 'proofs' / 'obj'

BSX_IMPORTS = [
    'import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
    'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
    'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vcopy.bend as VC',
    'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vspec.bend as VS', 'import ../proofs/obj/vmul.bend as VM',
    'import ../proofs/obj/arr_vec.bend as AV', 'import ../proofs/obj/vbig.bend as VG', 'import ../proofs/obj/words_spec.bend as WS',
    'import ../proofs/obj/words_obj_light.bend as WO_L', 'import ../proofs/obj/pv_obj.bend as PV', 'import ../proofs/obj/packed_obj_light.bend as PK_L',
    'import ../proofs/obj/vfixw_spec.bend as FWS', 'import ../proofs/obj/schema_shapes.bend as SH',
    'import ./e2e_blist.bend as BL', 'import ./e2e_pv8.bend as EP8']

LV_KINDS = ['u64', 'b32', 'Fork', 'BeaconBlockHeader', 'Eth1Data', 'Checkpoint']
LV_TY = {'u64': 'O.U64', 'b32': 'FuluBytes32_d.Bytes32', 'Fork': 'FuluFork_d.Fork', 'BeaconBlockHeader': 'FuluBeaconBlockHeader_d.BeaconBlockHeader',
         'Eth1Data': 'FuluEth1Data_d.Eth1Data', 'Checkpoint': 'FuluCheckpoint_d.Checkpoint'}


def _iface():
    return (OBJ / 'big_encx_BeaconState_iface.bend').read_text()


def lv_lemmas():
    """lv_X: the root view of a fixed field is the record's value (the iface's own LV_X matches, leaf {==})."""
    it = _iface()
    out = []
    for k in LV_KINDS:
        m = re.search(r'^def LV_' + k + r'\(o: (\S+)\) -> S\.Value:\n((?:  .*\n)+)', it, re.M)
        ty, body = m.group(1), m.group(2).rstrip('\n').split('\n')
        last = body[-1]
        mc = re.match(r'(\s*case .*?\}): ', last)
        body[-1] = (mc.group(1) + ': {==}') if mc else re.match(r'\s*', last).group(0) + '{==}'
        out.append(f'def lv_{k}(+o: {ty}) -> {{RN_L.v_{k}(o) == CI.LV_{k}(o) : S.Value}}:\n' + '\n'.join(body) + '\n')
    return '\n'.join(out)


BSX_BODY = r'''
# ---- sizes: powers of two, symbolically ----
def e32s(+q: Nat) -> {Nat.add(WS.e32(q), 32n) == WS.e32(1n+q) : Nat}:
  Equal.trans(Nat, Nat.add(WS.e32(q), 32n), Nat.add(32n, WS.e32(q)), WS.e32(1n+q), FD.nat__add_comm(WS.e32(q), 32n), {==})

# e32(2^e) = 2^r, r = 5 + e
def e32pw(+e: Nat, +r: Nat, +er: {r == 5n+e : Nat}) -> {WS.e32(VB.pw(e)) == VB.pw(r) : Nat}:
  %Equal.sym(Nat, r, 5n+e, er) : {WS.e32(VB.pw(e)) == VB.pw(_) : Nat}
  {==}

# e8(2^e) = 2^p, p = 3 + e
def e8pw(+e: Nat, +p: Nat, +ep: {p == 3n+e : Nat}) -> {O.e8(VB.pw(e)) == VB.pw(p) : Nat}:
  %Equal.sym(Nat, p, 3n+e, ep) : {O.e8(VB.pw(e)) == VB.pw(_) : Nat}
  {==}

# 2 * 2^e = 2^p, p = 1 + e
def d1pw(+e: Nat, +p: Nat, +ep: {p == 1n+e : Nat}) -> {Nat.double(VB.pw(e)) == VB.pw(p) : Nat}:
  %Equal.sym(Nat, p, 1n+e, ep) : {Nat.double(VB.pw(e)) == VB.pw(_) : Nat}
  {==}

# 8 k = m8(k)
law me8:
  for +k: Nat
  {VM.mulE(8n, k) == AV.m8(k) : Nat}
def me8(k):
  match k:
    case 0n: {==}
    case 1n+ +q: Equal.cong(Nat, Nat, z => Nat.add(8n, z), VM.mulE(8n, q), AV.m8(q), me8(q))

# the U32 N of 32 (1 + q) bytes, 1 + q = 2^e, is L = 2^r (r = 5 + e)
def vlen(+N: U32, +q: Nat, +e: Nat, +r: Nat, +L: U32, +eN: {U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat}, +ec: {1n+q == VB.pw(e) : Nat},
    +er: {r == 5n+e : Nat}, +eL: {L == FD.u32__pow2u(r) : U32}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> {N == L : U32}:
  +a = Equal.trans(Nat, U32.to_nat(N), Nat.add(WS.e32(q), 32n), WS.e32(1n+q), eN, e32s(q))
  +b = Equal.trans(Nat, U32.to_nat(N), WS.e32(1n+q), WS.e32(VB.pw(e)), a, Equal.cong(Nat, Nat, z => WS.e32(z), 1n+q, VB.pw(e), ec))
  +c = Equal.trans(Nat, U32.to_nat(N), WS.e32(VB.pw(e)), VB.pw(r), b, e32pw(e, r, er))
  FD.u32__injective(N, L, Equal.trans(Nat, U32.to_nat(N), VB.pw(r), U32.to_nat(L), c, Equal.sym(Nat, U32.to_nat(L), VB.pw(r), VG.u32pow(L, r, eL, hr))))

# the words of L = 2^r bytes (r = 2 + p): NW(L) = 2^p (s = 3 + p < 32: L + 3 does not overflow)
def nwq(+L: U32, +p: Nat, +r: Nat, +s: Nat, +erp: {r == 2n+p : Nat}, +es: {s == 3n+p : Nat}, +eL: {L == FD.u32__pow2u(r) : U32},
    +hs: {Nat.is_lt(s, 32n) == True{} : Bool}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> {VC.NW(L) == VB.pw(p) : Nat}:
  +PP = VB.pw(p)
  +eN = Equal.trans(Nat, U32.to_nat(L), VB.pw(r), A.quad(PP), VG.u32pow(L, r, eL, hr), Equal.sym(Nat, A.quad(PP), VB.pw(r), VG.quadpw(p, r, erp)))
  +eS = VG.u32pow(FD.u32__pow2u(s), s, {==}, hs)
  +h8 = VG.e83(PP, VG.pw_pos(p))
  +hA0 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(PP), 3n), z) == True{} : Bool}, O.e8(PP), VB.pw(s), e8pw(p, s, es), h8)
  +hA1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(PP), 3n), z) == True{} : Bool}, VB.pw(s), U32.to_nat(FD.u32__pow2u(s)), Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(s)), VB.pw(s), eS), hA0)
  +hA = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 3n), U32.to_nat(FD.u32__pow2u(s))) == True{} : Bool}, A.quad(PP), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(PP), eN), hA1)
  +eadd = A.add_le(L, 3, FD.u32__pow2u(s), hA)
  Equal.trans(Nat, VC.NW(L), VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), PP,
    VD.shrk(2n, U32.add(L, 3)),
    Equal.trans(Nat, VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), VD.s_rng(2n, Nat.add(A.quad(PP), 3n)), PP,
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat(U32.add(L, 3)), Nat.add(A.quad(PP), 3n),
        Equal.trans(Nat, U32.to_nat(U32.add(L, 3)), Nat.add(U32.to_nat(L), 3n), Nat.add(A.quad(PP), 3n), eadd,
          Equal.cong(Nat, Nat, z => Nat.add(z, 3n), U32.to_nat(L), A.quad(PP), eN))),
      VG.h2q(PP)))

# ---- a vector of 2^e Bytes32 (block_roots, state_roots, randao_mixes): its record's part ----
# K = 2^e chunks, L = 2^r bytes (r = 5 + e), 2^p words (p = 3 + e = r - 2), s = 3 + p < 32
def R_PV(po: O.Words, +L: U32) -> Data:
  DK.Ex(FD.array__Tree<U32>, T => DK.Ex(Nat, dB =>
    DK.P2({po == O.Words{FD.array__thaw(U32, T), L} : O.Words},
    DK.P2({PV.pview(O.Words{FD.array__thaw(U32, T), L}) == FWS.VV8(VC.NW(L), T) : S.Value},
    DK.P2({FD.array__perfect(U32, dB, T) == True{} : Bool},
    DK.P2({Nat.is_lt(dB, 31n) == True{} : Bool},
          {Nat.is_le(VC.NW(L), VB.pw(dB)) == True{} : Bool}))))))

def pk_PV(-po: O.Words, +L: U32, +T: FD.array__Tree<U32>, +dB: Nat, +ew: {po == O.Words{FD.array__thaw(U32, T), L} : O.Words},
    +ev: {PV.pview(O.Words{FD.array__thaw(U32, T), L}) == FWS.VV8(VC.NW(L), T) : S.Value}, +pf: {FD.array__perfect(U32, dB, T) == True{} : Bool},
    +hd: {Nat.is_lt(dB, 31n) == True{} : Bool}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dB)) == True{} : Bool}) -> R_PV(po, L):
  (T, (dB, (ew, (ev, (pf, (hd, hr))))))

# its value: 8 * 2^e = NW(L) words of T
def ev_PV(+T: FD.array__Tree<U32>, +dw: Nat, +pf: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +L: U32, +e: Nat, +p: Nat,
    +ecL: {O.chunks_of(L) == VB.pw(e) : Nat}, +eM: {VM.mulE(8n, VB.pw(e)) == VC.NW(L) : Nat}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dw)) == True{} : Bool})
    -> {PV.pview(O.Words{FD.array__thaw(U32, T), L}) == FWS.VV8(VC.NW(L), T) : S.Value}:
  +hr8 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(L), VM.mulE(8n, VB.pw(e)), Equal.sym(Nat, VM.mulE(8n, VB.pw(e)), VC.NW(L), eM), hr)
  Equal.trans(S.Value, PV.pview(O.Words{FD.array__thaw(U32, T), L}), S.Sequence{AV.ch8(VS.wtake(VM.mulE(8n, VB.pw(e)), FD.array__slots(U32, T)))}, FWS.VV8(VC.NW(L), T),
    EP8.pv8(T, dw, pf, L, VB.pw(e), ecL, hr8),
    Equal.cong(Nat, S.Value, z => S.Sequence{AV.ch8(VS.wtake(z, FD.array__slots(U32, T)))}, VM.mulE(8n, VB.pw(e)), VC.NW(L), eM))

def kPV(-po: O.Words, +L: U32, +e: Nat, +p: Nat, +r: Nat, +sx: Nat, +T: FD.array__Tree<U32>, +dw: Nat, +N: U32, +q: Nat,
    +eo: {po == O.Words{FD.array__thaw(U32, T), N} : O.Words}, +pf: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hd: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eN: {U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat}, +hc: {Nat.is_le(O.e8(1n+q), FD.spec_common__pow2(dw)) == True{} : Bool},
    +cc: {O.chunks_of(N) == 1n+q : Nat}, +ec: {1n+q == VB.pw(e) : Nat},
    +eL: {L == FD.u32__pow2u(r) : U32}, +er: {r == 5n+e : Nat}, +ep: {p == 3n+e : Nat}, +erp: {r == 2n+p : Nat}, +es: {sx == 3n+p : Nat},
    +hsx: {Nat.is_lt(sx, 32n) == True{} : Bool}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> R_PV(po, L):
  +eNL = vlen(N, q, e, r, L, eN, ec, er, eL, hr)
  +ew = Equal.trans(O.Words, po, O.Words{FD.array__thaw(U32, T), N}, O.Words{FD.array__thaw(U32, T), L}, eo, Equal.cong(U32, O.Words, z => O.Words{FD.array__thaw(U32, T), z}, N, L, eNL))
  +eW = nwq(L, p, r, sx, erp, es, eL, hsx, hr)
  +e8 = e8pw(e, p, ep)
  +hc2 = FD.logic__subst(Nat, z => {Nat.is_le(O.e8(z), FD.spec_common__pow2(dw)) == True{} : Bool}, 1n+q, VB.pw(e), ec, hc)
  +hc3 = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dw)) == True{} : Bool}, O.e8(VB.pw(e)), VB.pw(p), e8, hc2)
  +hrw = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VB.pw(p), VC.NW(L), Equal.sym(Nat, VC.NW(L), VB.pw(p), eW), hc3)
  +ecN = Equal.trans(Nat, O.chunks_of(N), 1n+q, VB.pw(e), cc, ec)
  +ecL = FD.logic__subst(U32, z => {O.chunks_of(z) == VB.pw(e) : Nat}, N, L, eNL, ecN)
  +eM = Equal.trans(Nat, VM.mulE(8n, VB.pw(e)), AV.m8(VB.pw(e)), VC.NW(L), me8(VB.pw(e)),
    Equal.trans(Nat, AV.m8(VB.pw(e)), VB.pw(p), VC.NW(L), Equal.trans(Nat, AV.m8(VB.pw(e)), O.e8(VB.pw(e)), VB.pw(p), VG.m8_d3(VB.pw(e)), e8),
      Equal.sym(Nat, VC.NW(L), VB.pw(p), eW)))
  pk_PV(po, L, T, dw, ew, ev_PV(T, dw, pf, L, e, p, ecL, eM, hrw), pf, hd, hrw)

# from rep (its chunk count, the schema's length K) and the premise sdpv (its storage at depth below 31)
def mk_PV(-po: O.Words, +s: S.Schema, +rep: PV.rep_pv(po, s), +hs: BL.sdpv(po, 31n), +K: U32, +L: U32, +e: Nat, +p: Nat, +r: Nat, +sx: Nat,
    +ev: {SH.Vector_length(s) == U32.to_nat(K) : Nat}, +eK: {K == FD.u32__pow2u(e) : U32}, +eL: {L == FD.u32__pow2u(r) : U32},
    +er: {r == 5n+e : Nat}, +ep: {p == 3n+e : Nat}, +erp: {r == 2n+p : Nat}, +es: {sx == 3n+p : Nat},
    +hsx: {Nat.is_lt(sx, 32n) == True{} : Bool}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}, +he: {Nat.is_lt(e, 32n) == True{} : Bool}) -> R_PV(po, L):
  (+wf, +nb) = rep
  (+T, s0) = hs
  (+dw, s1) = s0
  (+N, s2) = s1
  (+q, s3) = s2
  (+eo, s4) = s3
  (+pf, s5) = s4
  (+hd, s6) = s5
  (+eN, +hc) = s6
  +nn = FD.logic__subst(O.Words, z => {Nat.is_eq(O.chunks_of(WO_L.len(z)), SH.Vector_length(s)) == True{} : Bool}, po, O.Words{FD.array__thaw(U32, T), N}, eo, nb)
  +cc = FD.logic__subst(Nat, z => {Nat.div(Nat.add(z, 31n), 32n) == 1n+q : Nat}, Nat.add(WS.e32(q), 32n), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), 32n), eN), WS.chunks_count(q, 32n, {==}, {==}))
  +ec1 = Equal.trans(Nat, 1n+q, O.chunks_of(N), SH.Vector_length(s), Equal.sym(Nat, O.chunks_of(N), 1n+q, cc), FD.nat__eq_from_is_eq(O.chunks_of(N), SH.Vector_length(s), nn))
  +ec = Equal.trans(Nat, 1n+q, U32.to_nat(K), VB.pw(e), Equal.trans(Nat, 1n+q, SH.Vector_length(s), U32.to_nat(K), ec1, ev), VG.u32pow(K, e, eK, he))
  kPV(po, L, e, p, r, sx, T, dw, N, q, eo, pf, hd, eN, hc, cc, ec, eL, er, ep, erp, es, hsx, hr)

# ---- a vector of 2^e uint64 (slashings, proposer_lookahead): its record's part ----
# K = 2^e elements, L = 2^r bytes (r = 3 + e), 2^p words (p = 1 + e = r - 2), s = 3 + p < 32
def R_V2(po: O.Words, +L: U32) -> Data:
  DK.Ex(FD.array__Tree<U32>, T => DK.Ex(Nat, dB =>
    DK.P2({po == O.Words{FD.array__thaw(U32, T), L} : O.Words},
    DK.P2({PK_L.vview8(O.Words{FD.array__thaw(U32, T), L}) == FWS.VU2(VC.NW(L), T) : S.Value},
    DK.P2({FD.array__perfect(U32, dB, T) == True{} : Bool},
    DK.P2({Nat.is_lt(dB, 31n) == True{} : Bool},
          {Nat.is_le(VC.NW(L), VB.pw(dB)) == True{} : Bool}))))))

def pk_V2(-po: O.Words, +L: U32, +T: FD.array__Tree<U32>, +dB: Nat, +ew: {po == O.Words{FD.array__thaw(U32, T), L} : O.Words},
    +ev: {PK_L.vview8(O.Words{FD.array__thaw(U32, T), L}) == FWS.VU2(VC.NW(L), T) : S.Value}, +pf: {FD.array__perfect(U32, dB, T) == True{} : Bool},
    +hd: {Nat.is_lt(dB, 31n) == True{} : Bool}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dB)) == True{} : Bool}) -> R_V2(po, L):
  (T, (dB, (ew, (ev, (pf, (hd, hr))))))

# it8 over k pairs is chu2 of the first 2 k words
law ic2:
  for +k: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(AV.m2(k), VB.len(W)) == True{} : Bool}
  {PK_L.it8(k, W) == AV.chu2(VS.wtake(AV.m2(k), W)) : S.Value}
def ic2(k, W, h):
  match k W:
    case 0n _: {==}
    case 1n+ +q Nil{}: Empty.absurd({PK_L.it8(1n+q, Nil{}) == AV.chu2(VS.wtake(AV.m2(1n+q), Nil{})) : S.Value}, FD.logic__false_true(h))
    case 1n+ +q Con{+a0, Nil{}}: Empty.absurd({PK_L.it8(1n+q, [a0]) == AV.chu2(VS.wtake(AV.m2(1n+q), [a0])) : S.Value}, FD.logic__false_true(h))
    case 1n+ +q Con{+a0, Con{+a1, +r}}:
      Equal.cong(S.Value, S.Value, z => S.Items{S.UnsignedValue{P.UInt{a0, a1, 0, 0, 0, 0, 0, 0}}, z}, PK_L.it8(q, r), AV.chu2(VS.wtake(AV.m2(q), r)), ic2(q, r, h))

# its value: the first 2 * 2^e = NW(L) words of T
def ev_V2(+T: FD.array__Tree<U32>, +dw: Nat, +pf: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +L: U32, +e: Nat,
    +eC: {U32.to_nat(U32.shrn(L, 3n)) == VB.pw(e) : Nat}, +eM: {AV.m2(VB.pw(e)) == VC.NW(L) : Nat}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dw)) == True{} : Bool})
    -> {PK_L.vview8(O.Words{FD.array__thaw(U32, T), L}) == FWS.VU2(VC.NW(L), T) : S.Value}:
  +Sl = FD.array__slots(U32, T)
  +hK = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(L), AV.m2(VB.pw(e)), Equal.sym(Nat, AV.m2(VB.pw(e)), VC.NW(L), eM), hr)
  +hKl = FD.logic__subst(Nat, z => {Nat.is_le(AV.m2(VB.pw(e)), z) == True{} : Bool}, VB.pw(dw), VB.len(Sl), Equal.sym(Nat, VB.len(Sl), VB.pw(dw), FD.array__slots_length(U32, dw, T, pf)), hK)
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, T)), T, FD.array__freeze_thaw(U32, T)) :
    {S.Sequence{PK_L.it8(U32.to_nat(U32.shrn(L, 3n)), FD.array__slots(U32, _))} == FWS.VU2(VC.NW(L), T) : S.Value}
  %Equal.sym(Nat, U32.to_nat(U32.shrn(L, 3n)), VB.pw(e), eC) : {S.Sequence{PK_L.it8(_, Sl)} == FWS.VU2(VC.NW(L), T) : S.Value}
  %Equal.sym(Nat, VC.NW(L), AV.m2(VB.pw(e)), Equal.sym(Nat, AV.m2(VB.pw(e)), VC.NW(L), eM)) : {S.Sequence{PK_L.it8(VB.pw(e), Sl)} == S.Sequence{AV.chu2(VS.wtake(_, Sl))} : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, PK_L.it8(VB.pw(e), Sl), AV.chu2(VS.wtake(AV.m2(VB.pw(e)), Sl)), ic2(VB.pw(e), Sl, hKl))

# 2^p <= e8(1 + q) when 4 * 2^p = e32(q) + r0, r0 <= 32
def rmq(+p: Nat, +q: Nat, +r0: Nat, +e4: {A.quad(VB.pw(p)) == Nat.add(WS.e32(q), r0) : Nat}, +h32: {Nat.is_le(r0, 32n) == True{} : Bool})
    -> {Nat.is_le(VB.pw(p), O.e8(1n+q)) == True{} : Bool}:
  +h1 = Order.add_left(WS.e32(q), r0, 32n, h32)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(WS.e32(q), 32n)) == True{} : Bool}, Nat.add(WS.e32(q), r0), A.quad(VB.pw(p)), Equal.sym(Nat, A.quad(VB.pw(p)), Nat.add(WS.e32(q), r0), e4), h1)
  +h3 = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(VB.pw(p)), z) == True{} : Bool}, Nat.add(WS.e32(q), 32n), WS.e32(1n+q), e32s(q), h2)
  VC.quad_inv(VB.pw(p), O.e8(1n+q), h3)

def kV2(-po: O.Words, +L: U32, +e: Nat, +p: Nat, +r: Nat, +sx: Nat, +T: FD.array__Tree<U32>, +dw: Nat, +N: U32, +q: Nat, +r0: Nat,
    +eo: {po == O.Words{FD.array__thaw(U32, T), N} : O.Words}, +pf: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hd: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eN: {U32.to_nat(N) == Nat.add(WS.e32(q), r0) : Nat}, +h32: {Nat.is_le(r0, 32n) == True{} : Bool}, +hc: {Nat.is_le(O.e8(1n+q), FD.spec_common__pow2(dw)) == True{} : Bool},
    +eC: {U32.to_nat(U32.shrn(N, 3n)) == VB.pw(e) : Nat}, +eNr: {U32.to_nat(N) == VB.pw(r) : Nat},
    +eL: {L == FD.u32__pow2u(r) : U32}, +ep: {p == 1n+e : Nat}, +erp: {r == 2n+p : Nat}, +es: {sx == 3n+p : Nat},
    +hsx: {Nat.is_lt(sx, 32n) == True{} : Bool}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> R_V2(po, L):
  +eNL = FD.u32__injective(N, L, Equal.trans(Nat, U32.to_nat(N), VB.pw(r), U32.to_nat(L), eNr, Equal.sym(Nat, U32.to_nat(L), VB.pw(r), VG.u32pow(L, r, eL, hr))))
  +ew = Equal.trans(O.Words, po, O.Words{FD.array__thaw(U32, T), N}, O.Words{FD.array__thaw(U32, T), L}, eo, Equal.cong(U32, O.Words, z => O.Words{FD.array__thaw(U32, T), z}, N, L, eNL))
  +eW = nwq(L, p, r, sx, erp, es, eL, hsx, hr)
  +e4 = Equal.trans(Nat, A.quad(VB.pw(p)), VB.pw(r), Nat.add(WS.e32(q), r0), VG.quadpw(p, r, erp), Equal.trans(Nat, VB.pw(r), U32.to_nat(N), Nat.add(WS.e32(q), r0), Equal.sym(Nat, U32.to_nat(N), VB.pw(r), eNr), eN))
  +hp = FD.nat__le_trans(VB.pw(p), O.e8(1n+q), FD.spec_common__pow2(dw), rmq(p, q, r0, e4, h32), hc)
  +hrw = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VB.pw(p), VC.NW(L), Equal.sym(Nat, VC.NW(L), VB.pw(p), eW), hp)
  +eCL = FD.logic__subst(U32, z => {U32.to_nat(U32.shrn(z, 3n)) == VB.pw(e) : Nat}, N, L, eNL, eC)
  +eM = Equal.trans(Nat, AV.m2(VB.pw(e)), VB.pw(p), VC.NW(L), Equal.trans(Nat, AV.m2(VB.pw(e)), Nat.double(VB.pw(e)), VB.pw(p), VG.m2_d1(VB.pw(e)), d1pw(e, p, ep)),
    Equal.sym(Nat, VC.NW(L), VB.pw(p), eW))
  pk_V2(po, L, T, dw, ew, ev_V2(T, dw, pf, L, e, eCL, eM, hrw), pf, hd, hrw)

# from rep (its element count, the schema's length K) and the premise sdk1 (its storage at depth below 31)
def mk_V2(-po: O.Words, +s: S.Schema, +rep: PK_L.rep_v8(po, s), +hs: BL.sdk1(po, 31n), +K: U32, +L: U32, +e: Nat, +p: Nat, +r: Nat, +sx: Nat,
    +ev: {SH.Vector_length(s) == U32.to_nat(K) : Nat}, +eK: {K == FD.u32__pow2u(e) : U32}, +eL: {L == FD.u32__pow2u(r) : U32},
    +er: {r == 3n+e : Nat}, +ep: {p == 1n+e : Nat}, +erp: {r == 2n+p : Nat}, +es: {sx == 3n+p : Nat},
    +hsx: {Nat.is_lt(sx, 32n) == True{} : Bool}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}, +he: {Nat.is_lt(e, 32n) == True{} : Bool}) -> R_V2(po, L):
  (+wf, r1) = rep
  (+eLn, +nb) = r1
  (+T, s0) = hs
  (+dw, s1) = s0
  (+N, s2) = s1
  (+q, s3) = s2
  (+r0, s4) = s3
  (+eo, s5) = s4
  (+pf, s6) = s5
  (+hd, s7) = s6
  (+eN, s8) = s7
  (+h1, s9) = s8
  (+h32, s10) = s9
  (+hc, +bz) = s10
  +nn = FD.logic__subst(O.Words, z => {Nat.is_eq(PK_L.cnt8(z), SH.Vector_length(s)) == True{} : Bool}, po, O.Words{FD.array__thaw(U32, T), N}, eo, nb)
  +eL2 = FD.logic__subst(O.Words, z => {U32.to_nat(WO_L.len(z)) == PK_L.e8(PK_L.cnt8(z)) : Nat}, po, O.Words{FD.array__thaw(U32, T), N}, eo, eLn)
  +eC = Equal.trans(Nat, U32.to_nat(U32.shrn(N, 3n)), U32.to_nat(K), VB.pw(e),
    Equal.trans(Nat, U32.to_nat(U32.shrn(N, 3n)), SH.Vector_length(s), U32.to_nat(K), FD.nat__eq_from_is_eq(U32.to_nat(U32.shrn(N, 3n)), SH.Vector_length(s), nn), ev),
    VG.u32pow(K, e, eK, he))
  +eNr = Equal.trans(Nat, U32.to_nat(N), O.e8(U32.to_nat(U32.shrn(N, 3n))), VB.pw(r), eL2,
    Equal.trans(Nat, O.e8(U32.to_nat(U32.shrn(N, 3n))), O.e8(VB.pw(e)), VB.pw(r), Equal.cong(Nat, Nat, z => O.e8(z), U32.to_nat(U32.shrn(N, 3n)), VB.pw(e), eC), e8pw(e, r, er)))
  kV2(po, L, e, p, r, sx, T, dw, N, q, r0, eo, pf, hd, eN, h32, hc, eC, eNr, eL, ep, erp, es, hsx, hr)

'''

# ---- the top module's own parts: the sync committees, justification_bits, the fixed fields ----
TOP_PARTS = r'''
# ---- a sync committee: its pubkeys' words in a tree of depth below 31 (the premise EW.sdsc), its aggregate key's words ----
def R_SC(po: FuluSyncCommittee_d.SyncCommittee) -> Data:
  DK.Ex(FD.array__Tree<U32>, T => DK.Ex(Nat, dB => DK.Ex(U32, a0 => DK.Ex(U32, a1 => DK.Ex(U32, a2 => DK.Ex(U32, a3 => DK.Ex(U32, a4 => DK.Ex(U32, a5 =>
  DK.Ex(U32, a6 => DK.Ex(U32, a7 => DK.Ex(U32, a8 => DK.Ex(U32, a9 => DK.Ex(U32, a10 => DK.Ex(U32, a11 =>
    DK.P2({po == FuluSyncCommittee_d.SyncCommittee{O.Words{FD.array__thaw(U32, T), 24576}, FuluBytes48_d.Bytes48{a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11}} : FuluSyncCommittee_d.SyncCommittee},
    DK.P2({RT.v_SyncCommittee(FuluSyncCommittee_d.SyncCommittee{O.Words{FD.array__thaw(U32, T), 24576}, FuluBytes48_d.Bytes48{a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11}}) == FWS.SCV(T, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11) : S.Value},
    DK.P2({FD.array__perfect(U32, dB, T) == True{} : Bool},
    DK.P2({Nat.is_lt(dB, 31n) == True{} : Bool},
          {Nat.is_le(6144n, VB.pw(dB)) == True{} : Bool}))))))))))))))))))

def evSC(+T: FD.array__Tree<U32>, +dB: Nat, +pf: {FD.array__perfect(U32, dB, T) == True{} : Bool}, +hr: {Nat.is_le(6144n, VB.pw(dB)) == True{} : Bool},
    +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32, +a8: U32, +a9: U32, +a10: U32, +a11: U32)
    -> {RT.v_SyncCommittee(FuluSyncCommittee_d.SyncCommittee{O.Words{FD.array__thaw(U32, T), 24576}, FuluBytes48_d.Bytes48{a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11}}) == FWS.SCV(T, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11) : S.Value}:
  Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{z, S.Items{S.BytesValue{FX.limbs([a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])}, S.EmptyItems{}}}},
    E48.eview(O.Words{FD.array__thaw(U32, T), 24576}), S.Sequence{AV.ch12(VS.wtake(VC.NW(24576), FD.array__slots(U32, T)))}, EW.pkt(T, dB, pf, hr))

def kSC(-po: FuluSyncCommittee_d.SyncCommittee, +x1: FuluBytes48_d.Bytes48, +T: FD.array__Tree<U32>, +dB: Nat,
    +eo: {po == FuluSyncCommittee_d.SyncCommittee{O.Words{FD.array__thaw(U32, T), 24576}, x1} : FuluSyncCommittee_d.SyncCommittee},
    +pf: {FD.array__perfect(U32, dB, T) == True{} : Bool}, +hd: {Nat.is_lt(dB, 31n) == True{} : Bool}, +hr: {Nat.is_le(6144n, VB.pw(dB)) == True{} : Bool}) -> R_SC(po):
  match x1:
    case FuluBytes48_d.Bytes48{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7, +a8, +a9, +a10, +a11}:
      (T, (dB, (a0, (a1, (a2, (a3, (a4, (a5, (a6, (a7, (a8, (a9, (a10, (a11, (eo, (evSC(T, dB, pf, hr, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11), (pf, (hd, hr))))))))))))))))))

def mk_SC(-po: FuluSyncCommittee_d.SyncCommittee, +s: S.Schema, +rep: RT.rep_SyncCommittee(po, s), +hs: EW.sdsc(RT.pj_SyncCommittee_0(po), 31n)) -> R_SC(po):
  (+x1, r1) = rep
  (+eo, +rk) = r1
  (+T, s0) = hs
  (+dB, s1) = s0
  (+ew, s2) = s1
  (+pf, s3) = s2
  (+hd, +hr) = s3
  +e1 = Equal.trans(FuluSyncCommittee_d.SyncCommittee, po, FuluSyncCommittee_d.SyncCommittee{RT.pj_SyncCommittee_0(po), x1}, FuluSyncCommittee_d.SyncCommittee{O.Words{FD.array__thaw(U32, T), 24576}, x1}, eo,
    Equal.cong(O.Words, FuluSyncCommittee_d.SyncCommittee, z => FuluSyncCommittee_d.SyncCommittee{z, x1}, RT.pj_SyncCommittee_0(po), O.Words{FD.array__thaw(U32, T), 24576}, ew))
  kSC(po, x1, T, dB, e1, pf, hd, hr)

# ---- justification_bits: the root law's bits past 4 are zero (rp_bv4): its record facts and its view ----
def W4(+a: Bool, +b: Bool, +c: Bool, +d: Bool) -> U32: U32{WSp.join(4n, 28n, WCon{a, WCon{b, WCon{c, WCon{d, WNil{}}}}}, Word.zero(28n))}

def ok4b(+a: Bool, +b: Bool, +c: Bool, +d: Bool)
    -> {Bool.and(K.OK_bv4(Fulu_bitvector_4_d.Bitvector4{W4(a, b, c, d)}), Fulu_bitvector_4_e.bv4_valid(Fulu_bitvector_4_d.Bitvector4{W4(a, b, c, d)})) == True{} : Bool}:
@OK4ROWS@

def ok4w(+X: Word(4n))
    -> {Bool.and(K.OK_bv4(Fulu_bitvector_4_d.Bitvector4{U32{WSp.join(4n, 28n, X, Word.zero(28n))}}), Fulu_bitvector_4_e.bv4_valid(Fulu_bitvector_4_d.Bitvector4{U32{WSp.join(4n, 28n, X, Word.zero(28n))}})) == True{} : Bool}:
  match X:
    case WCon{+a, WCon{+b, WCon{+c, WCon{+d, WNil{}}}}}: ok4b(a, b, c, d)

def ok4(+x: Fulu_bitvector_4_d.Bitvector4, +rp: ST.rp_bv4(x)) -> {Bool.and(K.OK_bv4(x), Fulu_bitvector_4_e.bv4_valid(x)) == True{} : Bool}:
  match x:
    case Fulu_bitvector_4_d.Bitvector4{+w0}:
      %Equal.sym(U32, w0, U32{WSp.join(4n, 28n, WSp.take(4n, 32n, PD.bits(w0)), Word.zero(28n))}, rp) :
        {Bool.and(K.OK_bv4(Fulu_bitvector_4_d.Bitvector4{_}), Fulu_bitvector_4_e.bv4_valid(Fulu_bitvector_4_d.Bitvector4{_})) == True{} : Bool}
      ok4w(WSp.take(4n, 32n, PD.bits(w0)))

def w4(+v: U32) -> {S.BitsValue{BLP.btk(4n, BLP.bitsof([v]))} == VFB4.VB4(v) : S.Value}:
  match v:
    case U32{WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, +r}}}}}: {==}

def lv_bv4(+x: Fulu_bitvector_4_d.Bitvector4) -> {ST.v_bv4(x) == CI.VBo_bv4(x) : S.Value}:
  match x:
    case Fulu_bitvector_4_d.Bitvector4{+w0}: w4(w0)

# ---- the fixed fields: their root views are the record's values ----
'''


def ok4_rows():
    rows = []
    for i in range(16):
        bs = ['True{}' if (i >> (3 - j)) & 1 else 'False{}' for j in range(4)]
        rows.append(f'    case {" ".join(bs)}: {{==}}')
    return '  match a b c d:\n' + '\n'.join(rows)


def bsx_text():
    body = BSX_BODY
    return ('\n'.join(BSX_IMPORTS) + '\n\n# GENERATED by codegen/e2e_bridge.py (codegen/e2e_state_enc.py). Do not edit.\n'
            '# BeaconState (i)\'s fixed-size parts (see codegen/e2e_state_enc.py): the vectors and sync committees as their\n'
            '# encode record\'s pieces from the root law\'s representation and the storage premises (sdpv / sdk1 / sdsc: depth\n'
            '# below 31).\n'
            + body)


def top_parts():
    return TOP_PARTS.replace('@OK4ROWS@', ok4_rows()) + lv_lemmas()


# ==== the byte-storage lists (e2e_bsl) ====
BSL_IMPORTS = [
    'import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
    'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/compact/reads.bend as RD',
    'import ../proofs/compact/buf.bend as BF', 'import ../proofs/nat_order.bend as Order',
    'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vcopy.bend as VC',
    'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vspec.bend as VS', 'import ../proofs/obj/vmul.bend as VM',
    'import ../proofs/obj/arr_vec.bend as AV', 'import ../proofs/obj/vbig.bend as VG', 'import ../proofs/obj/vu32.bend as VU',
    'import ../proofs/obj/venc.bend as VEN', 'import ../proofs/obj/vlist.bend as VLS', 'import ../proofs/obj/vbytes.bend as VY',
    'import ../proofs/obj/vua_rd.bend as UR', 'import ../proofs/obj/vua_lay.bend as LY', 'import ../proofs/obj/words_spec.bend as WS',
    'import ../proofs/obj/words_obj_light.bend as WO_L', 'import ../proofs/obj/words_root_light.bend as WR_L',
    'import ../proofs/obj/packed_bytes_light.bend as PBF', 'import ../proofs/obj/pb_min.bend as PBM',
    'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/blist_obj.bend as BLI', 'import ../proofs/obj/schema_shapes.bend as SH',
    'import ../proofs/obj/big_encx_l16777216_b32.bend as EXh', 'import ../proofs/obj/big_var_winx_l16777216_b32.bend as WH',
    'import ../proofs/obj/big_encx_l1099511627776_u64.bend as EXu', 'import ../proofs/obj/big_var_winx_l1099511627776_u64.bend as W64',
    'import ../proofs/obj/big_encx_l1099511627776_u8.bend as EX8', 'import ../proofs/obj/big_var_winx_l1099511627776_u8.bend as W8',
    'import ./e2e_u64l.bend as U', 'import ./e2e_ulist.bend as ULW', 'import ./e2e_blist.bend as BL', 'import ./e2e_pv8.bend as EP8']


def _w5(bs, tail):
    s = tail
    for b in reversed(bs):
        s = f'WCon{{{b}, {s}}}'
    return s


def split32_text():
    pads = 'r'
    for k in (27, 28, 29, 30):
        pads = f'Word.shr.pad({k}n, {pads})'
    # Word.to_nat(32n, pad31(pad30(pad29(pad28(pad27 r))))) -> Word.to_nat(27n, r), one pad_value per level
    lv = []
    inner = ['r']
    for k in (27, 28, 29, 30):
        inner.append(f'Word.shr.pad({k}n, {inner[-1]})')
    # inner[i] : Word(27+i); the top term is Word.shr.pad(31n, inner[4]) : Word(32)
    terms = [f'Word.to_nat(32n, Word.shr.pad(31n, {inner[4]}))'] + [f'Word.to_nat({27 + i}n, {inner[i]})' for i in (4, 3, 2, 1, 0)]
    pvs = [f'BF.pad_value(31n, {inner[4]})'] + [f'BF.pad_value({26 + i}n, {inner[i - 1]})' for i in (4, 3, 2, 1)]
    chain = pvs[-1]
    for i in range(len(pvs) - 2, -1, -1):
        chain = f'Equal.trans(Nat, {terms[i]}, {terms[i + 1]}, {terms[-1]}, {pvs[i]},\n    {chain})'
    out = [f'''# ---- a word is 32 times its value shifted right by five, plus its low five bits ----
def fifth(+b0: Bool, +b1: Bool, +b2: Bool, +b3: Bool, +b4: Bool, +r: Word(27n))
    -> {{U32.to_nat(U32.shrn(U32{{{_w5(["b0", "b1", "b2", "b3", "b4"], "r")}}}, 5n)) == Word.to_nat(27n, r) : Nat}}:
  {chain}

law split32:
  for +x: U32
  {{U32.to_nat(x) == Nat.add(Nat.mul(U32.to_nat(U32.shrn(x, 5n)), 32n), U32.to_nat(U32.and(x, 31))) : Nat}}
def split32(x):
  match x:''']
    for v in range(32):
        bs = ['True{}' if (v >> i) & 1 else 'False{}' for i in range(5)]
        X = f'U32{{{_w5(bs, "r")}}}'
        XP = f'U32{{{_w5(bs, "+r")}}}'
        R = 'Word.to_nat(27n, r)'
        D5 = f'Nat.double(Nat.double(Nat.double(Nat.double(Nat.double({R})))))'
        out.append(f'''    case {XP}:
      %Equal.sym(Word(27n), Word.and(27n, r, Word.zero(27n)), Word.zero(27n), BF.and_zero(27n, r)) :
        {{U32.to_nat({X}) == Nat.add(Nat.mul(U32.to_nat(U32.shrn({X}, 5n)), 32n), U32.to_nat(U32{{{_w5(bs, "_")}}})) : Nat}}
      %Equal.sym(Nat, U32.to_nat(U32.shrn({X}, 5n)), {R}, fifth({", ".join(bs)}, r)) :
        {{U32.to_nat({X}) == Nat.add(Nat.mul(_, 32n), {v}n) : Nat}}
      %Equal.sym(Nat, Nat.mul({R}, 32n), {D5}, VG.mul32({R})) : {{U32.to_nat({X}) == Nat.add(_, {v}n) : Nat}}
      %Equal.sym(Nat, Nat.add({D5}, {v}n), Nat.add({v}n, {D5}), FD.nat__add_comm({D5}, {v}n)) : {{U32.to_nat({X}) == _ : Nat}}
      {{==}}''')
    return '\n'.join(out) + '\n'


BSL_BODY = r'''
# a length of 32 c bytes has no bytes past a whole chunk
def and31_x32(+L: U32, +c: Nat, +e: {U32.to_nat(L) == Nat.mul(c, 32n) : Nat}) -> {U32.and(L, 31) == 0 : U32}:
  +q = U32.to_nat(U32.shrn(L, 5n))
  +r = U32.to_nat(U32.and(L, 31))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(q, 32n), r), U32.to_nat(L), Nat.add(Nat.mul(c, 32n), 0n), Equal.sym(Nat, U32.to_nat(L), Nat.add(Nat.mul(q, 32n), r), split32(L)),
    Equal.trans(Nat, U32.to_nat(L), Nat.mul(c, 32n), Nat.add(Nat.mul(c, 32n), 0n), e, Equal.sym(Nat, Nat.add(Nat.mul(c, 32n), 0n), Nat.mul(c, 32n), FD.nat__add_zero(Nat.mul(c, 32n)))))
  +hr = FD.nat__le_lt_trans(r, 31n, 32n, RD.and_le(L, 31), {==})
  FD.u32__injective(U32.and(L, 31), 0, Pair.snd({q == c : Nat}, {r == 0n : Nat}, VU.dm_unique(q, r, c, 0n, 32n, e1, hr, {==})))

def e32m(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(WS.e32(a), WS.e32(b)) == True{} : Bool}:
  FD.nat__double_le(Nat.double(Nat.double(Nat.double(Nat.double(a)))), Nat.double(Nat.double(Nat.double(Nat.double(b)))),
    FD.nat__double_le(Nat.double(Nat.double(Nat.double(a))), Nat.double(Nat.double(Nat.double(b))),
      FD.nat__double_le(Nat.double(Nat.double(a)), Nat.double(Nat.double(b)),
        FD.nat__double_le(Nat.double(a), Nat.double(b), FD.nat__double_le(a, b, h)))))

# e32(2^e) = 2^r, r = 5 + e
def e32pw(+e: Nat, +r: Nat, +er: {r == 5n+e : Nat}) -> {WS.e32(VB.pw(e)) == VB.pw(r) : Nat}:
  %Equal.sym(Nat, r, 5n+e, er) : {WS.e32(VB.pw(e)) == VB.pw(_) : Nat}
  {==}

# 8 k = m8(k)
law me8:
  for +k: Nat
  {VM.mulE(8n, k) == AV.m8(k) : Nat}
def me8(k):
  match k:
    case 0n: {==}
    case 1n+ +q: Equal.cong(Nat, Nat, z => Nat.add(8n, z), VM.mulE(8n, q), AV.m8(q), me8(q))

# ---- a byte-storage list's premise (U.sdk: its storage at depth below K) as its constructor and the storage facts ----
def CWS(w: O.Words, +K: Nat) -> Data:
  DK.Ex(FD.array__Tree<U32>, t => DK.Ex(U32, n => DK.P2({w == O.Words{FD.array__thaw(U32, t), n} : O.Words}, U.SFT(t, n, K))))

def cws(-w: O.Words, +K: Nat, +hs: U.sdk(w, K)) -> CWS(w, K):
  match hs:
    case Inl{s}:
      (+T, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+ew, s4) = s3
      (+pf, s5) = s4
      (+hdw, +en0) = s5
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dw))) == True{} : Bool}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, en0), Order.zero_le(A.quad(VB.pw(dw))))
      +htz = FD.logic__subst(U32, z => {O.tail_zero(U32.and(z, 3), VB.slot(T, VY.QL(z))) == True{} : Bool}, 0, N, Equal.sym(U32, N, 0, FD.u32__injective(N, 0, en0)), {==})
      (T, (N, (ew, U.sfx(T, N, K, T, dw, N, {==}, pf, hdw, hN, htz))))
    case Inr{s}:
      (+T, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+q, s4) = s3
      (+r, s5) = s4
      (+ew, s6) = s5
      (+pf, s7) = s6
      (+hdw, s8) = s7
      (+eN, s9) = s8
      (+hr0, s10) = s9
      (+hr32, s11) = s10
      (+hcap, +bz) = s11
      +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(O.e8(1n+q))) == True{} : Bool}, Nat.add(r, WS.e32(q)), U32.to_nat(N),
        Equal.sym(Nat, U32.to_nat(N), Nat.add(r, WS.e32(q)), Equal.trans(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), Nat.add(r, WS.e32(q)), eN, FD.nat__add_comm(WS.e32(q), r))),
        Order.add_right(r, 32n, WS.e32(q), hr32))
      +hN = FD.nat__le_trans(U32.to_nat(N), A.quad(O.e8(1n+q)), A.quad(VB.pw(dw)), hq, U.q4(O.e8(1n+q), FD.spec_common__pow2(dw), hcap))
      (T, (N, (ew, U.sfx(T, N, K, T, dw, N, {==}, pf, hdw, hN, TZ.tz(T, N, q, r, eN, hr0, hr32, bz)))))

# ---- balances, inactivity_scores: a list of uint64 as its encode record (EXu) ----
def R_U(po: O.Words) -> Data:
  DK.Ex(EXu.MW, m => DK.P2({po == EXu.TH(m) : O.Words}, DK.P2({UL.uview(EXu.TH(m)) == EXu.VAL(m) : S.Value},
    DK.P2({EXu.OK(m) == True{} : Bool}, {LY.LN(EXu.ENC(m)) == U32.to_nat(WO_L.len(po)) : Nat}))))

def okU(+tt: FD.array__Tree<U32>, +n: U32, +sf: U.SFT(tt, n, 28n), +c: Nat, +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat})
    -> {EXu.OK(EXu.MW{U.LDEP(U32, tt), tt, n}) == True{} : Bool}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  FD.logic__and_intro(FD.array__perfect(U32, U.LDEP(U32, tt), tt), Bool.and(Nat.is_lt(U.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), W64.CHKw(tt, 0n, 0, n))))), pf,
    FD.logic__and_intro(Nat.is_lt(U.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), W64.CHKw(tt, 0n, 0, n)))), hdw,
    FD.logic__and_intro(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), W64.CHKw(tt, 0n, 0, n))), hN,
    FD.logic__and_intro(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), W64.CHKw(tt, 0n, 0, n)), htz,
    FD.logic__and_intro(U32.is_eq(U32.and(n, 7), 0), W64.CHKw(tt, 0n, 0, n), FD.u32alg__eq_true(U32.and(n, 7), 0, VEN.and7_x8(n, c, ex8)),
    VLS.whole_i1(n, 8, W64.v8(), {==}, {==}, {==}, c, emul))))))

def lvU(+dw: Nat, +tt: FD.array__Tree<U32>, +n: U32, +c: Nat, +pf: {FD.array__perfect(U32, dw, tt) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(dw))) == True{} : Bool},
    +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat})
    -> {UL.uview(O.Words{FD.array__thaw(U32, tt), n}) == W64.VALw(tt, 0n, n) : S.Value}:
  +Sl = FD.array__slots(U32, tt)
  +cq = U.cq8(n, c, emul, VU.whole_q(n, 8, c, emul, {==}, VU.div_u32(n, 8, W64.v8(), {==}, {==}, {==})))
  +ecq = Equal.trans(Nat, U32.to_nat(U32.shrn(n, 3n)), VD.s_rng(3n, U32.to_nat(n)), c, VD.shrk(3n, n),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(n)), VD.s_rng(3n, VS.x8(c)), c, Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(n), VS.x8(c), ex8), ULW.r8(c)))
  +eq8 = Equal.trans(Nat, U32.to_nat(n), Nat.mul(c, 8n), A.quad(Nat.double(c)), emul, VG.mul8(c))
  +h2c = VC.quad_inv(Nat.double(c), VB.pw(dw), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dw))) == True{} : Bool}, U32.to_nat(n), A.quad(Nat.double(c)), eq8, hN))
  +er = U.rws0(Nat.double(c), 0n, dw, tt, pf, h2c)
  %Equal.sym(Nat, U32.to_nat(U32.div(n, 8)), c, cq) : {UL.uview(O.Words{FD.array__thaw(U32, tt), n}) == S.Sequence{VS.uitems(_, UR.RWS(Nat.double(_), tt, 0n))} : S.Value}
  %Equal.sym(List<&2, U32>, UR.RWS(Nat.double(c), tt, 0n), VS.wtake(Nat.double(c), Sl), er) : {UL.uview(O.Words{FD.array__thaw(U32, tt), n}) == S.Sequence{VS.uitems(c, _)} : S.Value}
  Equal.trans(S.Value, UL.uview(O.Words{FD.array__thaw(U32, tt), n}), S.Sequence{VS.uitems(c, Sl)}, S.Sequence{VS.uitems(c, VS.wtake(Nat.double(c), Sl))},
    ULW.uvw(tt, n, c, ecq), Equal.cong(S.Value, S.Value, z => S.Sequence{z}, VS.uitems(c, Sl), VS.uitems(c, VS.wtake(Nat.double(c), Sl)), U.ut(c, Sl)))

def pk_U(-po: O.Words, +m: EXu.MW, +ew: {po == EXu.TH(m) : O.Words}, +ev: {UL.uview(EXu.TH(m)) == EXu.VAL(m) : S.Value}, +ok: {EXu.OK(m) == True{} : Bool},
    +el: {LY.LN(EXu.ENC(m)) == U32.to_nat(WO_L.len(po)) : Nat}) -> R_U(po):
  (m, (ew, (ev, (ok, el))))

def kU2(-po: O.Words, +tt: FD.array__Tree<U32>, +n: U32, +ew: {po == O.Words{FD.array__thaw(U32, tt), n} : O.Words}, +sf: U.SFT(tt, n, 28n), +c: Nat,
    +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat}) -> R_U(po):
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  +hok = okU(tt, n, (pf, (hdw, (hN, htz))), c, ex8, emul)
  +el = Equal.trans(Nat, LY.LN(EXu.ENC(EXu.MW{U.LDEP(U32, tt), tt, n})), U32.to_nat(n), U32.to_nat(WO_L.len(po)), Equal.sym(Nat, U32.to_nat(n), LY.LN(EXu.ENC(EXu.MW{U.LDEP(U32, tt), tt, n})), EXu.szx(EXu.MW{U.LDEP(U32, tt), tt, n}, hok)),
    Equal.sym(Nat, U32.to_nat(WO_L.len(po)), U32.to_nat(n), Equal.cong(O.Words, Nat, z => U32.to_nat(WO_L.len(z)), po, O.Words{FD.array__thaw(U32, tt), n}, ew)))
  pk_U(po, EXu.MW{U.LDEP(U32, tt), tt, n}, ew, lvU(U.LDEP(U32, tt), tt, n, c, pf, hN, ex8, emul), hok, el)

def kU(-po: O.Words, +cw: CWS(po, 28n), +eN: {U32.to_nat(WO_L.len(po)) == O.e8(UL.ucnt(po)) : Nat}) -> R_U(po):
  (+tt, c1) = cw
  (+n, c2) = c1
  (+ew, +sf) = c2
  +eN2 = FD.logic__subst(O.Words, z => {U32.to_nat(WO_L.len(z)) == O.e8(UL.ucnt(z)) : Nat}, po, O.Words{FD.array__thaw(U32, tt), n}, ew, eN)
  +c = UL.ucnt(O.Words{FD.array__thaw(U32, tt), n})
  +ex8 = Equal.trans(Nat, U32.to_nat(n), O.e8(c), VS.x8(c), eN2, Equal.sym(Nat, VS.x8(c), O.e8(c), ULW.x8e(c)))
  +emul = Equal.trans(Nat, U32.to_nat(n), VS.x8(c), Nat.mul(c, 8n), ex8, Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c)))
  kU2(po, tt, n, ew, sf, c, ex8, emul)

# from rep (whole elements) and the premise U.sdk (its storage at depth below 28)
def mk_U(-po: O.Words, +s: S.Schema, +rep: UL.rep_ul(po, s), +hs: U.sdk(po, 28n)) -> R_U(po):
  (+wf, r1) = rep
  (+eN, +hl) = r1
  kU(po, cws(po, 28n, hs), eN)

# ---- previous / current_epoch_participation: a list of uint8 as its encode record (EX8) ----
def R_B8(po: O.Words) -> Data:
  DK.Ex(EX8.MW, m => DK.P2({po == EX8.TH(m) : O.Words}, DK.P2({PBF.vview1(EX8.TH(m)) == EX8.VAL(m) : S.Value},
    DK.P2({EX8.OK(m) == True{} : Bool}, {LY.LN(EX8.ENC(m)) == U32.to_nat(WO_L.len(po)) : Nat}))))

def it1eq(+k: Nat, +xs: +List<U32>) -> {PBF.it1(k, xs) == PBM.it1(k, xs) : S.Value}:
  match k xs:
    case 0n _: {==}
    case 1n+ +c Nil{}: {==}
    case 1n+ +c Con{+x, +t}:
      Equal.cong(S.Value, S.Value, z => S.Items{S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}, z}, PBF.it1(c, t), PBM.it1(c, t), it1eq(c, t))

def lv8(+tt: FD.array__Tree<U32>, +n: U32) -> {PBF.vview1(O.Words{FD.array__thaw(U32, tt), n}) == W8.VALw(tt, 0n, n) : S.Value}:
  +e1 = Equal.cong(+List<U32>, S.Value, z => S.Sequence{PBF.it1(U32.to_nat(n), z)}, WO_L.wview(O.Words{FD.array__thaw(U32, tt), n}), BL.WX0(tt, n), BL.wv0(tt, n))
  +e2 = Equal.cong(S.Value, S.Value, z => S.Sequence{z}, PBF.it1(U32.to_nat(n), BL.WX0(tt, n)), PBM.it1(U32.to_nat(n), BL.WX0(tt, n)), it1eq(U32.to_nat(n), BL.WX0(tt, n)))
  Equal.trans(S.Value, PBF.vview1(O.Words{FD.array__thaw(U32, tt), n}), S.Sequence{PBF.it1(U32.to_nat(n), BL.WX0(tt, n))}, W8.VALw(tt, 0n, n), e1, e2)

def ok8(+tt: FD.array__Tree<U32>, +n: U32, +sf: U.SFT(tt, n, 28n)) -> {EX8.OK(EX8.MW{U.LDEP(U32, tt), tt, n}) == True{} : Bool}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  FD.logic__and_intro(FD.array__perfect(U32, U.LDEP(U32, tt), tt), Bool.and(Nat.is_lt(U.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), W8.CHKw(tt, 0n, 0, n)))), pf,
    FD.logic__and_intro(Nat.is_lt(U.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), W8.CHKw(tt, 0n, 0, n))), hdw,
    FD.logic__and_intro(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), W8.CHKw(tt, 0n, 0, n)), hN,
    FD.logic__and_intro(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), W8.CHKw(tt, 0n, 0, n), htz,
    VLS.whole_i1(n, 1, W8.v1(), {==}, {==}, {==}, U32.to_nat(n), PBM.mul1(U32.to_nat(n)))))))

def pk_B8(-po: O.Words, +m: EX8.MW, +ew: {po == EX8.TH(m) : O.Words}, +ev: {PBF.vview1(EX8.TH(m)) == EX8.VAL(m) : S.Value}, +ok: {EX8.OK(m) == True{} : Bool},
    +el: {LY.LN(EX8.ENC(m)) == U32.to_nat(WO_L.len(po)) : Nat}) -> R_B8(po):
  (m, (ew, (ev, (ok, el))))

def kB8(-po: O.Words, +cw: CWS(po, 28n)) -> R_B8(po):
  (+tt, c1) = cw
  (+n, c2) = c1
  (+ew, +sf) = c2
  +hok = ok8(tt, n, sf)
  +el = Equal.trans(Nat, LY.LN(EX8.ENC(EX8.MW{U.LDEP(U32, tt), tt, n})), U32.to_nat(n), U32.to_nat(WO_L.len(po)), Equal.sym(Nat, U32.to_nat(n), LY.LN(EX8.ENC(EX8.MW{U.LDEP(U32, tt), tt, n})), EX8.szx(EX8.MW{U.LDEP(U32, tt), tt, n}, hok)),
    Equal.sym(Nat, U32.to_nat(WO_L.len(po)), U32.to_nat(n), Equal.cong(O.Words, Nat, z => U32.to_nat(WO_L.len(z)), po, O.Words{FD.array__thaw(U32, tt), n}, ew)))
  pk_B8(po, EX8.MW{U.LDEP(U32, tt), tt, n}, ew, lv8(tt, n), hok, el)

# from the premise U.sdk (its storage at depth below 28); every U32 length is within the limit
def mk_B8(-po: O.Words, +hs: U.sdk(po, 28n)) -> R_B8(po):
  kB8(po, cws(po, 28n, hs))

# ---- historical_roots: a list of Bytes32 as its encode record (EXh) ----
def R_H(po: O.Words) -> Data:
  DK.Ex(EXh.MW, m => DK.P2({po == EXh.TH(m) : O.Words}, DK.P2({BLI.hview(EXh.TH(m)) == EXh.VAL(m) : S.Value},
    DK.P2({EXh.OK(m) == True{} : Bool}, {LY.LN(EXh.ENC(m)) == U32.to_nat(WO_L.len(po)) : Nat}))))

# c <= 2^24 chunks: 32 c <= 2^29 bytes
def hB29(+n: U32, +c: Nat, +eN: {U32.to_nat(n) == WS.e32(c) : Nat}, +hc: {Nat.is_le(c, U32.to_nat(16777216)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(n), U32.to_nat(536870912)) == True{} : Bool}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(c, z) == True{} : Bool}, U32.to_nat(16777216), VB.pw(24n), VG.u32pow(16777216, 24n, {==}, {==}), hc)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(WS.e32(c), z) == True{} : Bool}, WS.e32(VB.pw(24n)), VB.pw(29n), e32pw(24n, 29n, {==}), e32m(c, VB.pw(24n), h1))
  +h3 = FD.logic__subst(Nat, z => {Nat.is_le(WS.e32(c), z) == True{} : Bool}, VB.pw(29n), U32.to_nat(536870912), Equal.sym(Nat, U32.to_nat(536870912), VB.pw(29n), VG.u32pow(536870912, 29n, {==}, {==})), h2)
  FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(536870912)) == True{} : Bool}, WS.e32(c), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), WS.e32(c), eN), h3)

def okH(+tt: FD.array__Tree<U32>, +n: U32, +sf: U.SFT(tt, n, 28n), +c: Nat, +eN: {U32.to_nat(n) == WS.e32(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 32n) : Nat},
    +hc: {Nat.is_le(c, U32.to_nat(16777216)) == True{} : Bool}) -> {EXh.OK(EXh.MW{U.LDEP(U32, tt), tt, n}) == True{} : Bool}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  FD.logic__and_intro(FD.array__perfect(U32, U.LDEP(U32, tt), tt), Bool.and(Nat.is_lt(U.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(Nat.is_le(U32.to_nat(n), U32.to_nat(536870912)), Bool.and(U32.is_eq(U32.and(n, 31), 0), WH.CHKw(tt, 0n, 0, n)))))), pf,
    FD.logic__and_intro(Nat.is_lt(U.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(Nat.is_le(U32.to_nat(n), U32.to_nat(536870912)), Bool.and(U32.is_eq(U32.and(n, 31), 0), WH.CHKw(tt, 0n, 0, n))))), hdw,
    FD.logic__and_intro(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(U.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(Nat.is_le(U32.to_nat(n), U32.to_nat(536870912)), Bool.and(U32.is_eq(U32.and(n, 31), 0), WH.CHKw(tt, 0n, 0, n)))), hN,
    FD.logic__and_intro(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(Nat.is_le(U32.to_nat(n), U32.to_nat(536870912)), Bool.and(U32.is_eq(U32.and(n, 31), 0), WH.CHKw(tt, 0n, 0, n))), htz,
    FD.logic__and_intro(Nat.is_le(U32.to_nat(n), U32.to_nat(536870912)), Bool.and(U32.is_eq(U32.and(n, 31), 0), WH.CHKw(tt, 0n, 0, n)), hB29(n, c, eN, hc),
    FD.logic__and_intro(U32.is_eq(U32.and(n, 31), 0), WH.CHKw(tt, 0n, 0, n), FD.u32alg__eq_true(U32.and(n, 31), 0, and31_x32(n, c, emul)),
    VU.whole_i(n, 32, 16777216, WH.vR(), {==}, {==}, {==}, c, emul, hc)))))))

def lvH(+dw: Nat, +tt: FD.array__Tree<U32>, +n: U32, +c: Nat, +pf: {FD.array__perfect(U32, dw, tt) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(dw))) == True{} : Bool},
    +emul: {U32.to_nat(n) == Nat.mul(c, 32n) : Nat}, +cq: {WH.CC(n) == c : Nat}, +e5: {U32.to_nat(U32.shrn(n, 5n)) == c : Nat}) -> {BLI.hview(O.Words{FD.array__thaw(U32, tt), n}) == WH.VALw(tt, 0n, n) : S.Value}:
  +Sl = FD.array__slots(U32, tt)
  +Mq = VM.mulE(8n, c)
  +R = UR.RWS(Mq, tt, 0n)
  +eMq = Equal.trans(Nat, Mq, AV.m8(c), O.e8(c), me8(c), VG.m8_d3(c))
  +e4 = Equal.trans(Nat, A.quad(O.e8(c)), Nat.mul(c, 32n), U32.to_nat(n), Equal.sym(Nat, Nat.mul(c, 32n), A.quad(O.e8(c)), VG.mul32(c)), Equal.sym(Nat, U32.to_nat(n), Nat.mul(c, 32n), emul))
  +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dw))) == True{} : Bool}, U32.to_nat(n), A.quad(O.e8(c)), Equal.sym(Nat, A.quad(O.e8(c)), U32.to_nat(n), e4), hN)
  +h8 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, O.e8(c), Mq, Equal.sym(Nat, Mq, O.e8(c), eMq), VC.quad_inv(O.e8(c), VB.pw(dw), hq))
  +hS = FD.logic__subst(Nat, z => {Nat.is_le(Mq, z) == True{} : Bool}, VB.pw(dw), VB.len(Sl), Equal.sym(Nat, VB.len(Sl), VB.pw(dw), FD.array__slots_length(U32, dw, tt, pf)), h8)
  +h0 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(Sl)) == True{} : Bool}, Mq, Nat.add(Mq, 0n), Equal.sym(Nat, Nat.add(Mq, 0n), Mq, FD.nat__add_zero(Mq)), hS)
  +hR = FD.logic__subst(Nat, z => {Nat.is_le(Mq, z) == True{} : Bool}, Mq, VB.len(R), Equal.sym(Nat, VB.len(R), Mq, UR.rws_len(Mq, tt, 0n)), FD.nat__le_refl(Mq))
  +er = U.rws0(Mq, 0n, dw, tt, pf, h8)
  +L1 = Equal.trans(S.Value, WR_L.items(c, Sl, 0n), VM.bvit(c, 8n, Sl), AV.ch8(VS.wtake(Mq, Sl)), EP8.pit(c, 0n, Sl, h0), EP8.bch8(c, Sl, hS))
  +R1 = Equal.trans(S.Value, VM.bvit(c, 8n, R), AV.ch8(VS.wtake(Mq, R)), AV.ch8(VS.wtake(Mq, Sl)), EP8.bch8(c, R, hR),
    Equal.trans(S.Value, AV.ch8(VS.wtake(Mq, R)), AV.ch8(R), AV.ch8(VS.wtake(Mq, Sl)), Equal.cong(List<&2, U32>, S.Value, z => AV.ch8(z), VS.wtake(Mq, R), R, UR.wtake_rws(Mq, tt, 0n)),
      Equal.cong(List<&2, U32>, S.Value, z => AV.ch8(z), R, VS.wtake(Mq, Sl), er)))
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, tt)), tt, FD.array__freeze_thaw(U32, tt)) :
    {S.Sequence{WR_L.items(U32.to_nat(U32.shrn(n, 5n)), FD.array__slots(U32, _), 0n)} == WH.VALw(tt, 0n, n) : S.Value}
  %Equal.sym(Nat, U32.to_nat(U32.shrn(n, 5n)), c, e5) : {S.Sequence{WR_L.items(_, Sl, 0n)} == WH.VALw(tt, 0n, n) : S.Value}
  %Equal.sym(Nat, WH.CC(n), c, cq) : {S.Sequence{WR_L.items(c, Sl, 0n)} == S.Sequence{VM.bvit(_, 8n, UR.RWS(VM.mulE(8n, _), tt, 0n))} : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, WR_L.items(c, Sl, 0n), VM.bvit(c, 8n, R),
    Equal.trans(S.Value, WR_L.items(c, Sl, 0n), AV.ch8(VS.wtake(Mq, Sl)), VM.bvit(c, 8n, R), L1, Equal.sym(S.Value, VM.bvit(c, 8n, R), AV.ch8(VS.wtake(Mq, Sl)), R1)))

def pk_H(-po: O.Words, +m: EXh.MW, +ew: {po == EXh.TH(m) : O.Words}, +ev: {BLI.hview(EXh.TH(m)) == EXh.VAL(m) : S.Value}, +ok: {EXh.OK(m) == True{} : Bool},
    +el: {LY.LN(EXh.ENC(m)) == U32.to_nat(WO_L.len(po)) : Nat}) -> R_H(po):
  (m, (ew, (ev, (ok, el))))

def kH2(-po: O.Words, +tt: FD.array__Tree<U32>, +n: U32, +ew: {po == O.Words{FD.array__thaw(U32, tt), n} : O.Words}, +sf: U.SFT(tt, n, 28n),
    +eN: {U32.to_nat(n) == WS.e32(U32.to_nat(U32.shrn(n, 5n))) : Nat}, +hc: {Nat.is_le(U32.to_nat(U32.shrn(n, 5n)), U32.to_nat(16777216)) == True{} : Bool}) -> R_H(po):
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  +c = U32.to_nat(U32.shrn(n, 5n))
  +emul = Equal.trans(Nat, U32.to_nat(n), WS.e32(c), Nat.mul(c, 32n), eN, Equal.sym(Nat, Nat.mul(c, 32n), WS.e32(c), VG.mul32(c)))
  +cq = Pair.fst({U32.to_nat(U32.div(n, 32)) == c : Nat}, {U32.to_nat(U32.mod(n, 32)) == 0n : Nat}, VU.whole_q(n, 32, c, emul, {==}, VU.div_u32(n, 32, WH.vR(), {==}, {==}, {==})))
  +hok = okH(tt, n, (pf, (hdw, (hN, htz))), c, eN, emul, hc)
  +el = Equal.trans(Nat, LY.LN(EXh.ENC(EXh.MW{U.LDEP(U32, tt), tt, n})), U32.to_nat(n), U32.to_nat(WO_L.len(po)), Equal.sym(Nat, U32.to_nat(n), LY.LN(EXh.ENC(EXh.MW{U.LDEP(U32, tt), tt, n})), EXh.szx(EXh.MW{U.LDEP(U32, tt), tt, n}, hok)),
    Equal.sym(Nat, U32.to_nat(WO_L.len(po)), U32.to_nat(n), Equal.cong(O.Words, Nat, z => U32.to_nat(WO_L.len(z)), po, O.Words{FD.array__thaw(U32, tt), n}, ew)))
  pk_H(po, EXh.MW{U.LDEP(U32, tt), tt, n}, ew, lvH(U.LDEP(U32, tt), tt, n, c, pf, hN, emul, cq, {==}), hok, el)

def kH(-po: O.Words, +cw: CWS(po, 28n), +eN: {U32.to_nat(WO_L.len(po)) == WS.e32(BLI.cnth(po)) : Nat}, +hl: {Nat.is_le(BLI.cnth(po), U32.to_nat(16777216)) == True{} : Bool}) -> R_H(po):
  (+tt, c1) = cw
  (+n, c2) = c1
  (+ew, +sf) = c2
  +eN2 = FD.logic__subst(O.Words, z => {U32.to_nat(WO_L.len(z)) == WS.e32(BLI.cnth(z)) : Nat}, po, O.Words{FD.array__thaw(U32, tt), n}, ew, eN)
  +hl2 = FD.logic__subst(O.Words, z => {Nat.is_le(BLI.cnth(z), U32.to_nat(16777216)) == True{} : Bool}, po, O.Words{FD.array__thaw(U32, tt), n}, ew, hl)
  kH2(po, tt, n, ew, sf, eN2, hl2)

# from rep (whole chunks within the limit) and the premise U.sdk (its storage at depth below 28)
def mk_H(-po: O.Words, +s: S.Schema, +el: {SH.ListOf_limit(s) == U32.to_nat(16777216) : Nat}, +rep: BLI.rep_lh(po, s), +hs: U.sdk(po, 28n)) -> R_H(po):
  (+wf, r1) = rep
  (+eN, +hl) = r1
  kH(po, cws(po, 28n, hs), eN, FD.logic__subst(Nat, z => {Nat.is_le(BLI.cnth(po), z) == True{} : Bool}, SH.ListOf_limit(s), U32.to_nat(16777216), el, hl))
'''


def bsl_text():
    return ('\n'.join(BSL_IMPORTS + ['import ./e2e_tz.bend as TZ']) + '\n\n# GENERATED by codegen/e2e_bridge.py (codegen/e2e_state_enc.py). Do not edit.\n'
            '# BeaconState (i)\'s byte-storage lists as their encode records (see codegen/e2e_state_enc.py): historical_roots,\n'
            '# balances, the participation lists, inactivity_scores, from the root law\'s representation and the premise U.sdk\n'
            '# (storage at depth below 28, a decoded-object gap); each record\'s bytes are the object\'s length.\n\n'
            + split32_text() + BSL_BODY)
