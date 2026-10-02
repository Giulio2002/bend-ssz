"""BeaconState (i) (codec-top): the encode record (encx_BeaconState_iface's CI.MW) of every object the root law
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

from codegen.core.paths import ROOT  # noqa: E402
OBJ = ROOT / 'proofs' / 'obj'


def _rd(p):
    """a proving module's text as it read before the light split (light_split.unlight: the definitions its *_light companion holds)"""
    from codegen.proofs.support.light_split import unlight
    return unlight(Path(p).read_text())

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
    return _rd(OBJ / 'encx_BeaconState_iface.bend')


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
    E48.eview(O.Words{FD.array__thaw(U32, T), 24576}), S.Sequence{AV.ch12(VSP.wtake(VC.NW(24576), FD.array__slots(U32, T)))}, EW.pkt(T, dB, pf, hr))

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
    return ('\n'.join(BSX_IMPORTS) + '\n\n# GENERATED by e2e_bridge (codegen: e2e_state_enc). Do not edit.\n'
            '# BeaconState (i)\'s fixed-size parts (see codegen/proofs/bridges/e2e_state_enc.py): the vectors and sync committees as their\n'
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
    'import ../proofs/obj/encx_l16777216_b32.bend as EXh', 'import ../proofs/obj/var_winx_l16777216_b32.bend as WH',
    'import ../proofs/obj/encx_l1099511627776_u64.bend as EXu', 'import ../proofs/obj/var_winx_l1099511627776_u64.bend as W64',
    'import ../proofs/obj/encx_l1099511627776_u8.bend as EX8', 'import ../proofs/obj/var_winx_l1099511627776_u8.bend as W8',
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


def _and_chain(convs, proofs):
    """the right-nested Bool.and of convs and its FD.logic__and_intro proof from proofs."""
    def typ(i):
        return convs[i] if i == len(convs) - 1 else f'Bool.and({convs[i]}, {typ(i + 1)})'

    def prf(i):
        if i == len(convs) - 1:
            return proofs[i]
        return f'FD.logic__and_intro({convs[i]}, {typ(i + 1)}, {proofs[i]},\n    {prf(i + 1)})'
    return typ(0), prf(0)


def _ok_d(name, EX, sig_extra, convs, proofs):
    """the D validity (EX_D.OK: the base chain at depth below 31 and the object API's NMAX) of a byte list's record from its storage facts."""
    L = 'U.LDEP(U32, tt)'
    t0, p0 = _and_chain([c.replace('@L@', L) for c in convs], proofs)
    return (f"def {name}(+tt: FD.array__Tree<U32>, +n: U32, +sf: U.SFT(tt, n, 31n){sig_extra}, +hM: {{Nat.is_lt(U32.to_nat(n), VB.pw(31n)) == True{{}} : Bool}})\n"
            f"    -> {{{EX}D.OK({EX}.MW{{{L}, tt, n}}) == True{{}} : Bool}}:\n"
            f"  (+pf, +s1) = sf\n  (+hdw, +s2) = s1\n  (+hN, +htz) = s2\n"
            f"  FD.logic__and_intro({t0}, Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())), {p0},\n    nmaxD(n, hM))\n")


BSL_OK = {
    'okU': ('okU', 'EXu', ', +c: Nat, +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat}',
            ['FD.array__perfect(U32, @L@, tt)', 'Nat.is_lt(@L@, 31n)', 'Nat.is_le(U32.to_nat(n), A.quad(VB.pw(@L@)))', 'O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n)))',
             'U32.is_eq(U32.and(n, 7), 0)', 'W64.CHKw(tt, 0n, 0, n)'],
            ['pf', 'hdw', 'hN', 'htz', 'FD.u32alg__eq_true(U32.and(n, 7), 0, VEN.and7_x8(n, c, ex8))', 'VLS.whole_i1(n, 8, W64.v8(), {==}, {==}, {==}, c, emul)']),
    'ok8': ('ok8', 'EX8', '',
            ['FD.array__perfect(U32, @L@, tt)', 'Nat.is_lt(@L@, 31n)', 'Nat.is_le(U32.to_nat(n), A.quad(VB.pw(@L@)))', 'O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n)))',
             'W8.CHKw(tt, 0n, 0, n)'],
            ['pf', 'hdw', 'hN', 'htz', 'VLS.whole_i1(n, 1, W8.v1(), {==}, {==}, {==}, U32.to_nat(n), PBM.mul1(U32.to_nat(n)))']),
    'okH': ('okH', 'EXh', ', +c: Nat, +eN: {U32.to_nat(n) == WS.e32(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 32n) : Nat}, +hc: {Nat.is_le(c, U32.to_nat(16777216)) == True{} : Bool}',
            ['FD.array__perfect(U32, @L@, tt)', 'Nat.is_lt(@L@, 31n)', 'Nat.is_le(U32.to_nat(n), A.quad(VB.pw(@L@)))', 'O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n)))',
             'Nat.is_le(U32.to_nat(n), U32.to_nat(536870912))', 'U32.is_eq(U32.and(n, 31), 0)', 'WH.CHKw(tt, 0n, 0, n)'],
            ['pf', 'hdw', 'hN', 'htz', 'hB29(n, c, eN, hc)', 'FD.u32alg__eq_true(U32.and(n, 31), 0, and31_x32(n, c, emul))', 'VU.whole_i(n, 32, 16777216, WH.vR(), {==}, {==}, {==}, c, emul, hc)']),
}
HM = '{Nat.is_lt(U32.to_nat(WO_L.len(po)), VB.pw(31n)) == True{} : Bool}'
NMAXD = ('# n below 2^31 is within the object API\'s limit NMAX\n'
         'def nmaxD(+n: U32, +h31: {Nat.is_lt(U32.to_nat(n), VB.pw(31n)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())) == True{} : Bool}:\n'
         '  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, VB.NMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())), VB.le_u32n(n, VB.NMAX()), EMT.n31_N(n, h31))\n\n')


def _bsl_body_d():
    """BSL_BODY on the D twins of the lists (their validity at depth below 31 and the object API's NMAX): the storage premise U.sdk at
    depth below 31, each record's bytes below 2^31 (hM: a part of the encoding, which the top's bound gives)."""
    b = BSL_BODY
    for nm, (fn, EX, extra, convs, proofs) in BSL_OK.items():
        a = b.index(f'def {fn}(')
        e = b.index('\n\n', a)
        b = b[:a] + _ok_d(fn, EX, extra, convs, proofs).rstrip('\n') + b[e:]
    b = b.replace('28n', '31n')
    for EX in ('EXu', 'EX8', 'EXh'):
        b = b.replace(f'{{{EX}.OK(m) == True{{}} : Bool}}', f'{{{EX}D.OK(m) == True{{}} : Bool}}').replace(f'{EX}.szx(', f'{EX}D.szx(')
        b = b.replace(f'+ok: {{{EX}.OK(m) == True{{}} : Bool}}', f'+ok: {{{EX}D.OK(m) == True{{}} : Bool}}')
    # hM through the constructors
    def sub(old, new, cnt=1):
        nonlocal b
        assert b.count(old) >= 1, old[:80]
        b = b.replace(old, new, cnt)
    # u64 list
    sub("+emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat}) -> R_U(po):", "+emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat}, +hM: {Nat.is_lt(U32.to_nat(n), VB.pw(31n)) == True{} : Bool}) -> R_U(po):")
    sub("+hok = okU(tt, n, (pf, (hdw, (hN, htz))), c, ex8, emul)", "+hok = okU(tt, n, (pf, (hdw, (hN, htz))), c, ex8, emul, hM)")
    sub("def kU(-po: O.Words, +cw: CWS(po, 31n), +eN: {U32.to_nat(WO_L.len(po)) == O.e8(UL.ucnt(po)) : Nat}) -> R_U(po):",
        f"def kU(-po: O.Words, +cw: CWS(po, 31n), +eN: {{U32.to_nat(WO_L.len(po)) == O.e8(UL.ucnt(po)) : Nat}}, +hM: {HM}) -> R_U(po):")
    sub("  kU2(po, tt, n, ew, sf, c, ex8, emul)", "  +hM2 = FD.logic__subst(O.Words, z => {Nat.is_lt(U32.to_nat(WO_L.len(z)), VB.pw(31n)) == True{} : Bool}, po, O.Words{FD.array__thaw(U32, tt), n}, ew, hM)\n  kU2(po, tt, n, ew, sf, c, ex8, emul, hM2)")
    sub("+hs: U.sdk(po, 31n)) -> R_U(po):", f"+hs: U.sdk(po, 31n), +hM: {HM}) -> R_U(po):")
    sub("kU(po, cws(po, 31n, hs), eN)", "kU(po, cws(po, 31n, hs), eN, hM)")
    # u8 list
    sub("def kB8(-po: O.Words, +cw: CWS(po, 31n)) -> R_B8(po):", f"def kB8(-po: O.Words, +cw: CWS(po, 31n), +hM: {HM}) -> R_B8(po):")
    sub("  +hok = ok8(tt, n, sf)", "  +hM2 = FD.logic__subst(O.Words, z => {Nat.is_lt(U32.to_nat(WO_L.len(z)), VB.pw(31n)) == True{} : Bool}, po, O.Words{FD.array__thaw(U32, tt), n}, ew, hM)\n  +hok = ok8(tt, n, sf, hM2)")
    sub("def mk_B8(-po: O.Words, +hs: U.sdk(po, 31n)) -> R_B8(po):\n  kB8(po, cws(po, 31n, hs))", f"def mk_B8(-po: O.Words, +hs: U.sdk(po, 31n), +hM: {HM}) -> R_B8(po):\n  kB8(po, cws(po, 31n, hs), hM)")
    # b32 list
    sub("+hc: {Nat.is_le(U32.to_nat(U32.shrn(n, 5n)), U32.to_nat(16777216)) == True{} : Bool}) -> R_H(po):", "+hc: {Nat.is_le(U32.to_nat(U32.shrn(n, 5n)), U32.to_nat(16777216)) == True{} : Bool}, +hM: {Nat.is_lt(U32.to_nat(n), VB.pw(31n)) == True{} : Bool}) -> R_H(po):")
    sub("+hok = okH(tt, n, (pf, (hdw, (hN, htz))), c, eN, emul, hc)", "+hok = okH(tt, n, (pf, (hdw, (hN, htz))), c, eN, emul, hc, hM)")
    sub("+hl: {Nat.is_le(BLI.cnth(po), U32.to_nat(16777216)) == True{} : Bool}) -> R_H(po):", f"+hl: {{Nat.is_le(BLI.cnth(po), U32.to_nat(16777216)) == True{{}} : Bool}}, +hM: {HM}) -> R_H(po):")
    sub("  kH2(po, tt, n, ew, sf, eN2, hl2)", "  +hM2 = FD.logic__subst(O.Words, z => {Nat.is_lt(U32.to_nat(WO_L.len(z)), VB.pw(31n)) == True{} : Bool}, po, O.Words{FD.array__thaw(U32, tt), n}, ew, hM)\n  kH2(po, tt, n, ew, sf, eN2, hl2, hM2)")
    sub("+hs: U.sdk(po, 31n)) -> R_H(po):", f"+hs: U.sdk(po, 31n), +hM: {HM}) -> R_H(po):")
    sub("SH.ListOf_limit(s), U32.to_nat(16777216), el, hl))", "SH.ListOf_limit(s), U32.to_nat(16777216), el, hl), hM)")
    return NMAXD + b


def bsl_text():
    imps = BSL_IMPORTS + ['import ./e2e_tz.bend as TZ', 'import ./e2e_emit.bend as EMT',
                          'import ../proofs/obj/encx_l16777216_b32_d.bend as EXhD', 'import ../proofs/obj/encx_l1099511627776_u64_d.bend as EXuD',
                          'import ../proofs/obj/encx_l1099511627776_u8_d.bend as EX8D']
    return ('\n'.join(imps) + '\n\n# GENERATED by e2e_bridge (codegen: e2e_state_enc). Do not edit.\n'
            '# BeaconState (i)\'s byte-storage lists as their encode records (see codegen/proofs/bridges/e2e_state_enc.py): historical_roots,\n'
            '# balances, the participation lists, inactivity_scores, from the root law\'s representation and the premise U.sdk\n'
            '# (storage at depth below 31, a decoded-object gap); the records are on the D twins of the lists (their validity at depth\n'
            '# below 31 and the object API\'s limit NMAX, from each list\'s bytes below 2^31: hM); each record\'s bytes are the object\'s length.\n\n'
            + split32_text() + _bsl_body_d())


# ==== BeaconState's record lists (e2e_rls): each list's root view is its encode record's value (ITW / ITV), and
# the list as its encode record (R_W_L / mk_W_L) from rep and the premise sda_L (the tree at depth below the record's bound) ====
RLS = [('l2048_Eth1Data', 'Eth1Data', 2048), ('l1099511627776_Validator', 'Validator', 1099511627776),
       ('l16777216_HistoricalSummary', 'HistoricalSummary', 16777216), ('l134217728_PendingDeposit', 'PendingDeposit', 134217728),
       ('l134217728_PendingPartialWithdrawal', 'PendingPartialWithdrawal', 134217728), ('l262144_PendingConsolidation', 'PendingConsolidation', 262144)]


def _band(t):
    from codegen.proofs.bridges import e2e_var_b as EV
    return EV._band(t)


def _andc(c, p):
    from codegen.proofs.bridges import e2e_var_b as EV
    return EV._andc(c, p)


def rls_text():
    rs = _rd(OBJ / 'root_state.bend')
    imps = ['import Base', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P', 'import ../proofs/compact/found.bend as FD',
            'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/vrl.bend as VRL',
            'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vu32.bend as VU', 'import ../proofs/obj/vua_lay.bend as LY',
            'import ../proofs/obj/schema_shapes.bend as SH', 'import ../proofs/obj/root_names.bend as RN', 'import ../proofs/obj/root_names_light.bend as RN_L',
            'import ../proofs/obj/root_state.bend as ST', 'import ../src/obj.bend as O']
    body = []
    for i, (L, E, LIM) in enumerate(RLS):
        text = _rd(OBJ / f'encx_{L}.bend')
        al = f'EW{i}'
        imps.append(f'import ../proofs/obj/encx_{L}.bend as {al}')
        imps.append(f'import ../types/Fulu{E}_def_generated.bend as Fulu{E}_d')
        n = L.split('_')[0][1:]
        imps.append(f'import ../types/Fulu_list_{E}_{n}_def_generated.bend as Fulu_list_{E}_{n}_d')
        ET = f'Fulu{E}_d.{E}'
        SEQ = f'Fulu_list_{E}_{n}_d.{L}_Seq'
        rvn = f'RVW_{E}' if re.search(r'^def RVW_' + E + r'\(', text, re.M) else 'RVV'
        itn = 'ITW' if re.search(r'^def ITW_' + L + r'\(', text, re.M) else 'ITV'
        rvb = re.search(r'^def ' + rvn + r'\(\w+: .*?\n((?:  .*\n)+)', text, re.M).group(1).rstrip('\n').split('\n')
        rvb[-1] = re.match(r'\s*', rvb[-1]).group(0) + '{==}'
        rvvar = re.search(r'^def ' + rvn + r'\((\w+):', text, re.M).group(1)
        view = re.search(r'S\.Items\{(\w+\.\w+)\(xat_' + L, re.search(r'^def xi_' + L + r'\(.*\n(?:  .*\n)+', rs, re.M).group(0)).group(1)
        dflt = re.search(r'VRL\.mget\(' + re.escape(ET) + r', FD\.spec_common__nth\(.*?\), j\), (.*?)\)$', re.search(r'^def EL_' + L + r'\(.*$', text, re.M).group(0)).group(1)
        okw = _band(re.search(r'^def OKL_' + L + r'\(.*?\) -> Bool:\n((?:  .*\n)+)', text, re.M).group(1))
        KW = re.fullmatch(r'Nat\.is_lt\(TDM_' + L + r'\(A\), (\d+)n\)', okw[0]).group(1)
        LNW = re.fullmatch(r'U32\.is_le\(N, (\d+)\)', okw[3]).group(1) if len(okw) == 4 else None
        assert len(okw) in (3, 4), okw
        WLL = re.search(r'^def LL_' + L + r'\(.*?\) -> Nat: (.*)$', text, re.M).group(1)
        WLL = re.sub(r'(?<![\w.])N(?![\w])', 'n', WLL)
        sub = lambda s_: re.sub(r'(?<![\w.])(TDM_' + L + r')(?![\w])', f'{al}.TDM_{L}', s_).replace(f'{al}.TDM_{L}(A)', '@D@')
        ow = [re.sub(r'(?<![\w.])A(?![\w])', 'a', sub(c)) for c in okw]
        nest = lambda cs: cs[-1] if len(cs) == 1 else f'Bool.and({cs[0]}, {nest(cs[1:])})'
        pfs = ['hd', 'pf', 'hn'] + (['hlN'] if LNW else [])
        okd = _andc([c.replace('@D@', 'dw') for c in ow], pfs)
        hl_lets = ''
        kw_lim = ''
        mk_lim = ''
        mk_call = f'kW_{L}(po, a, dw, N, eo, pf, hd, hn)'
        if LNW:
            kw_lim = f', +s: S.Schema, +el: {{SH.ListOf_limit(s) == U32.to_nat({LNW}) : Nat}}, +hl: {{Nat.is_le(U32.to_nat(ST.xlen_o_{L}(po)), SH.ListOf_limit(s)) == True{{}} : Bool}}'
            hl_lets = (f"  +h1 = FD.logic__subst({SEQ}, z => {{Nat.is_le(U32.to_nat(ST.xlen_o_{L}(z)), SH.ListOf_limit(s)) == True{{}} : Bool}}, po, {SEQ}{{FD.array__thaw({ET}, a), N}}, eo, hl)\n"
                       f"  +h2 = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(N), z) == True{{}} : Bool}}, SH.ListOf_limit(s), U32.to_nat({LNW}), el, h1)\n"
                       f"  +hlN = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(N), U32.to_nat({LNW})), U32.is_le(N, {LNW}), Equal.sym(Bool, U32.is_le(N, {LNW}), Nat.is_le(U32.to_nat(N), U32.to_nat({LNW})), VU.le_u32(N, {LNW})), h2)\n")
            mk_lim = f', +el: {{SH.ListOf_limit(s) == U32.to_nat({LNW}) : Nat}}'
            mk_call = f'kW_{L}(po, s, el, hl, a, dw, N, eo, pf, hd, hn)'
        rvb_t = '\n'.join(rvb)
        body.append(f'''# ---- {L} ----
def xm_{L}(+W: List<&2, {ET}>, +i: Nat) -> {{ST.xat_{L}(W, i) == VRL.mget({ET}, FD.spec_common__nth({ET}, W, i), {dflt}) : {ET}}}:
  match W i:
    case Nil{{}} _: {{==}}
    case Con{{+x, +t}} 0n: {{==}}
    case Con{{+x, +t}} 1n+ +p: xm_{L}(t, p)

def rv_{L}(+{rvvar}: {ET}) -> {{{al}.{rvn}({rvvar}) == {view}({rvvar}) : S.Value}}:
{rvb_t}

def itw_{L}(c: Nat, +A: FD.array__Tree<{ET}>, +j: Nat) -> {{ST.xi_{L}(c, FD.array__slots({ET}, A), j) == {al}.{itn}_{L}(c, A, j) : S.Value}}:
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      %Equal.sym({ET}, ST.xat_{L}(FD.array__slots({ET}, A), j), {al}.EL_{L}(A, j), xm_{L}(FD.array__slots({ET}, A), j)) :
        {{S.Items{{{view}(_), ST.xi_{L}(q, FD.array__slots({ET}, A), 1n+j)}} == {al}.{itn}_{L}(1n+q, A, j) : S.Value}}
      %Equal.sym(S.Value, {view}({al}.EL_{L}(A, j)), {al}.{rvn}({al}.EL_{L}(A, j)), Equal.sym(S.Value, {al}.{rvn}({al}.EL_{L}(A, j)), {view}({al}.EL_{L}(A, j)), rv_{L}({al}.EL_{L}(A, j)))) :
        {{S.Items{{_, ST.xi_{L}(q, FD.array__slots({ET}, A), 1n+j)}} == {al}.{itn}_{L}(1n+q, A, j) : S.Value}}
      Equal.cong(S.Value, S.Value, z => S.Items{{{al}.{rvn}({al}.EL_{L}(A, j)), z}}, ST.xi_{L}(q, FD.array__slots({ET}, A), 1n+j), {al}.{itn}_{L}(q, A, 1n+j), itw_{L}(q, A, 1n+j))

def xvl_{L}(+A: FD.array__Tree<{ET}>, +n: U32) -> {{ST.xv_{L}({SEQ}{{FD.array__thaw({ET}, A), n}}) == {al}.VALL_{L}(A, n) : S.Value}}:
  %Equal.sym(FD.array__Tree<{ET}>, FD.array__freeze({ET}, FD.array__thaw({ET}, A)), A, FD.array__freeze_thaw({ET}, A)) :
    {{S.Sequence{{ST.xi_{L}(U32.to_nat(n), FD.array__slots({ET}, _), 0n)}} == {al}.VALL_{L}(A, n) : S.Value}}
  Equal.cong(S.Value, S.Value, z => S.Sequence{{z}}, ST.xi_{L}(U32.to_nat(n), FD.array__slots({ET}, A), 0n), {al}.{itn}_{L}(U32.to_nat(n), A, 0n), itw_{L}(U32.to_nat(n), A, 0n))

# the (i) premise: the list's array at depth below k
def sda_{L}(w: {SEQ}, +k: Nat) -> Data:
  DK.Ex(FD.array__Tree<{ET}>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({{w == {SEQ}{{FD.array__thaw({ET}, t), N}} : {SEQ}}},
    DK.P2({{FD.array__perfect({ET}, dw, t) == True{{}} : Bool}},
    DK.P2({{Nat.is_lt(dw, k) == True{{}} : Bool}},
          {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}))))))

def tdW_{L}(+d: Nat, +t: FD.array__Tree<{ET}>, +pf: {{FD.array__perfect({ET}, d, t) == True{{}} : Bool}}) -> {{{al}.TDM_{L}(t) == d : Nat}}:
  match d t:
    case 0n FD.TLeaf{{+x}}: {{==}}
    case 0n FD.TNode{{+l, +r}}: Empty.absurd({{{al}.TDM_{L}(FD.TNode{{l, r}}) == 0n : Nat}}, FD.logic__false_true(pf))
    case 1n+ +p FD.TLeaf{{+x}}: Empty.absurd({{{al}.TDM_{L}(FD.TLeaf{{x}}) == 1n+p : Nat}}, FD.logic__false_true(pf))
    case 1n+ +p FD.TNode{{+l, +r}}: Equal.cong(Nat, Nat, z => 1n+z, {al}.TDM_{L}(l), p, tdW_{L}(p, l, FD.array__pf_left({ET}, p, l, r, pf)))

# the list's encoded byte count, from the object alone
def WLL_{L}(w: {SEQ}) -> Nat:
  match w:
    case {SEQ}{{arr, +n}}: {WLL}

def R_W_{L}(po: {SEQ}) -> Data:
  DK.Ex(FD.array__Tree<{ET}>, a => DK.Ex(U32, N =>
    DK.P2({{po == {al}.THL_{L}(a, N) : {SEQ}}},
    DK.P2({{ST.xv_{L}({al}.THL_{L}(a, N)) == {al}.VALL_{L}(a, N) : S.Value}},
    DK.P2({{{al}.OKL_{L}(a, N) == True{{}} : Bool}},
          {{LY.LN({al}.ENCL_{L}(a, N)) == WLL_{L}(po) : Nat}})))))

def pk_{L}(-po: {SEQ}, +a: FD.array__Tree<{ET}>, +N: U32, +eo: {{po == {al}.THL_{L}(a, N) : {SEQ}}}, +ev: {{ST.xv_{L}({al}.THL_{L}(a, N)) == {al}.VALL_{L}(a, N) : S.Value}},
    +ok: {{{al}.OKL_{L}(a, N) == True{{}} : Bool}}, +eL: {{LY.LN({al}.ENCL_{L}(a, N)) == WLL_{L}(po) : Nat}}) -> R_W_{L}(po):
  (a, (N, (eo, (ev, (ok, eL)))))

def kW_{L}(-po: {SEQ}{kw_lim}, +a: FD.array__Tree<{ET}>, +dw: Nat, +N: U32, +eo: {{po == {SEQ}{{FD.array__thaw({ET}, a), N}} : {SEQ}}},
    +pf: {{FD.array__perfect({ET}, dw, a) == True{{}} : Bool}}, +hd: {{Nat.is_lt(dw, {KW}n) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}) -> R_W_{L}(po):
{hl_lets}  +okd = {okd}
  +ok = FD.logic__subst(Nat, z => {{{nest([c.replace('@D@', 'z') for c in ow])} == True{{}} : Bool}}, dw, {al}.TDM_{L}(a), Equal.sym(Nat, {al}.TDM_{L}(a), dw, tdW_{L}(dw, a, pf)), okd)
  +eL = Equal.trans(Nat, LY.LN({al}.ENCL_{L}(a, N)), {al}.LL_{L}(a, N), WLL_{L}(po), {al}.len_encl_{L}(a, N), Equal.sym(Nat, WLL_{L}(po), WLL_{L}({SEQ}{{FD.array__thaw({ET}, a), N}}), Equal.cong({SEQ}, Nat, z => WLL_{L}(z), po, {SEQ}{{FD.array__thaw({ET}, a), N}}, eo)))
  pk_{L}(po, a, N, eo, xvl_{L}(a, N), ok, eL)

def mk_W_{L}(-po: {SEQ}, +s: S.Schema{mk_lim}, +rep: ST.rep_{L}(po, s), +hs: sda_{L}(po, {KW}n)) -> R_W_{L}(po):
  (+w1, +hl) = rep
  (+a, b1) = hs
  (+dw, b2) = b1
  (+N, b3) = b2
  (+eo, b4) = b3
  (+pf, b5) = b4
  (+hd, +hn) = b5
  {mk_call}
''')
    bt = '\n'.join(body)
    for L, E, LIM in RLS:
        for l in _rd(OBJ / f'encx_{L}.bend').splitlines():
            m = re.match(r'import \.\./\.\./types/(\S+) as (\w+_d)$', l)
            if m and (m.group(2) + '.') in bt:
                imps.append(f'import ../types/{m.group(1)} as {m.group(2)}')
    return ('\n'.join(dict.fromkeys(imps)) + '\n\n# GENERATED by e2e_bridge (codegen: e2e_state_enc). Do not edit.\n'
            "# BeaconState's record lists in its encode record (encx_<L>): each list's root view is its value (xvl), and the list as its\n"
            "# encode record's (R_W_L / mk_W_L) from rep and the premise sda_L (the list's tree at depth below the record's bound,\n"
            "# a decoded-object gap), with its byte count WLL_L on the object.\n\n" + '\n'.join(body))


# ==== the top module: FuluBeaconState_e2e_generated.bend ====
def _split(s):
    from codegen.proofs.bridges import e2e_var_b as EV
    return EV.split_args(s)


def _peel(t, head):
    t = t.strip()
    assert t.startswith(head + '{') or t.startswith(head + '('), (head, t[:80])
    return _split(t[len(head) + 1:-1])


def _sum_terms(t):
    out = []
    while t.startswith('Nat.add('):
        a = _split(t[len('Nat.add('):-1])
        out.insert(0, a[1])
        t = a[0]
    return [t] + out


def _sumf(ts):
    s = ts[0]
    for x in ts[1:]:
        s = f'Nat.add({s}, {x})'
    return s


VEC = {5: ('pv', 8192, 262144, 13, 16, 18, 19), 6: ('pv', 8192, 262144, 13, 16, 18, 19), 13: ('pv', 65536, 2097152, 16, 19, 21, 22),
       14: ('v2', 8192, 65536, 13, 14, 16, 17), 37: ('v2', 64, 512, 6, 7, 9, 10)}   # kind, K, L, e, p, r, s
BYTEL = {7: 'H', 12: 'U', 21: 'U', 15: 'B8', 16: 'B8'}
RECL = {9: 'l2048_Eth1Data', 11: 'l1099511627776_Validator', 27: 'l16777216_HistoricalSummary', 34: 'l134217728_PendingDeposit',
        35: 'l134217728_PendingPartialWithdrawal', 36: 'l262144_PendingConsolidation'}
SCF = (22, 23)
EH = 24
BV4 = 17
EHO = 'FuluExecutionPayloadHeader_d.ExecutionPayloadHeader'
EHB = f'O.Boxed<{EHO}>'
EXA = {'H': 'EX_l16777216_b32', 'U': 'EX_l1099511627776_u64', 'B8': 'EX_l1099511627776_u8'}
BVIEW = {'H': 'BLI.hview', 'U': 'UL.uview', 'B8': 'PB.vview1'}

TOP_EXTRA = r'''
# ---- the latest execution payload header (boxed): e2e_mw's record, with its encoded length from the object ----
def lenB(+m: EB.MW, +ok: {EB.OK(m) == True{} : Bool}) -> {U32.to_nat(WO_L.len(EB.TH(m))) == LY.LN(EB.ENC(m)) : Nat}:
  match m:
    case EB.MW{+dw, +T, +N}: EB.szx(EB.MW{dw, T, N}, ok)

def lnE(+m: EC_ExecutionPayloadHeader.MW, +ok: {EC_ExecutionPayloadHeader.OK(m) == True{} : Bool})
    -> {LY.LN(EC_ExecutionPayloadHeader.ENC(m)) == Nat.add(584n, U32.to_nat(WO_L.len(RT.pj_ExecutionPayloadHeader_10(EC_ExecutionPayloadHeader.TH(m))))) : Nat}:
  match m:
    case EC_ExecutionPayloadHeader.MW{@EPHP@}:
      Equal.trans(Nat, LY.LN(IK.ENCC(@EPHA@)), EC_ExecutionPayloadHeader.ENDC(@EPHA@), Nat.add(584n, U32.to_nat(WO_L.len(EB.TH(a11)))),
        EC_ExecutionPayloadHeader.lenE(@EPHA@, ok),
        Equal.cong(Nat, Nat, z => Nat.add(584n, z), LY.LN(EB.ENC(a11)), U32.to_nat(WO_L.len(EB.TH(a11))),
          Equal.sym(Nat, U32.to_nat(WO_L.len(EB.TH(a11))), LY.LN(EB.ENC(a11)), lenB(a11, EC_ExecutionPayloadHeader.ok_hok_extra_data(@EPHA@, ok)))))

def LNEH(po: @EHB@) -> Nat: Nat.add(584n, U32.to_nat(WO_L.len(RT.pj_ExecutionPayloadHeader_10(RT.pjb_ExecutionPayloadHeader_bx(po)))))

def R_EB(po: @EHB@) -> Data:
  DK.Ex(EC_ExecutionPayloadHeader.MW, m => DK.P2({po == O.BSome{EC_ExecutionPayloadHeader.TH(m), O.BNone{}} : @EHB@},
    DK.P2({RT.v_ExecutionPayloadHeader_bx(O.BSome{EC_ExecutionPayloadHeader.TH(m), O.BNone{}}) == EC_ExecutionPayloadHeader.VAL(m) : S.Value},
    DK.P2({EC_ExecutionPayloadHeader.OKW(m) == True{} : Bool}, {LY.LN(EC_ExecutionPayloadHeader.ENC(m)) == LNEH(po) : Nat}))))

def pk_EB(-po: @EHB@, +m: EC_ExecutionPayloadHeader.MW, +e: {po == O.BSome{EC_ExecutionPayloadHeader.TH(m), O.BNone{}} : @EHB@},
    +v: {RT.v_ExecutionPayloadHeader_bx(O.BSome{EC_ExecutionPayloadHeader.TH(m), O.BNone{}}) == EC_ExecutionPayloadHeader.VAL(m) : S.Value},
    +ok: {EC_ExecutionPayloadHeader.OKW(m) == True{} : Bool}, +l: {LY.LN(EC_ExecutionPayloadHeader.ENC(m)) == LNEH(po) : Nat}) -> R_EB(po):
  (m, (e, (v, (ok, l))))

def kEB(-po: @EHB@, +eb: {po == O.BSome{RT.pjb_ExecutionPayloadHeader_bx(po), O.BNone{}} : @EHB@}, +w: MW.R_E(RT.pjb_ExecutionPayloadHeader_bx(po))) -> R_EB(po):
  (+m, w1) = w
  (+e, w2) = w1
  (+v, +ok) = w2
  +e2 = Equal.trans(@EHB@, po, O.BSome{RT.pjb_ExecutionPayloadHeader_bx(po), O.BNone{}}, O.BSome{EC_ExecutionPayloadHeader.TH(m), O.BNone{}}, eb,
    Equal.cong(@EHO@, @EHB@, z => O.BSome{z, O.BNone{}}, RT.pjb_ExecutionPayloadHeader_bx(po), EC_ExecutionPayloadHeader.TH(m), e))
  +l = Equal.trans(Nat, LY.LN(EC_ExecutionPayloadHeader.ENC(m)), Nat.add(584n, U32.to_nat(WO_L.len(RT.pj_ExecutionPayloadHeader_10(EC_ExecutionPayloadHeader.TH(m))))), LNEH(po), lnE(m, ok),
    Equal.cong(@EHO@, Nat, z => Nat.add(584n, U32.to_nat(WO_L.len(RT.pj_ExecutionPayloadHeader_10(z)))), EC_ExecutionPayloadHeader.TH(m), RT.pjb_ExecutionPayloadHeader_bx(po),
      Equal.sym(@EHO@, RT.pjb_ExecutionPayloadHeader_bx(po), EC_ExecutionPayloadHeader.TH(m), e)))
  pk_EB(po, m, e2, v, ECo.okwOfOkM(m, ok), l)

def mk_EB(-po: @EHB@, +s: S.Schema, +es: {s == Spec.ExecutionPayloadHeader() : S.Schema}, +r: RT.rep_ExecutionPayloadHeader_bx(po, s),
    +hs: MW.SHS_E(RT.pjb_ExecutionPayloadHeader_bx(po))) -> R_EB(po):
  (+eb, +ri) = r
  kEB(po, eb, MW.mk_E(RT.pjb_ExecutionPayloadHeader_bx(po), FD.logic__subst(S.Schema, z => RT.rep_ExecutionPayloadHeader(RT.pjb_ExecutionPayloadHeader_bx(po), z), s, Spec.ExecutionPayloadHeader(), es, ri), hs))
'''


def _vs_load(X):
    """the BeaconState's interfaces and root types, and the facts read off them (positions, views, values, fixed fields, types)"""
    from codegen.proofs.bridges import e2e_var_b as EV
    assert X == 'BeaconState'
    OT = 'FuluBeaconState_d.BeaconState'
    SC = 'Spec.BeaconState()'
    it = _rd(OBJ / 'encx_BeaconState_iface.bend')
    Kt = _rd(OBJ / 'encx_BeaconState.bend')
    en = _rd(OBJ / 'var_codec_BeaconState_enc.bend')
    eno = _rd(OBJ / 'var_codec_BeaconState_enc_o.bend')   # (i) on the OKW laws: the encoder's O twins
    ito = _rd(OBJ / 'encx_BeaconState_iface_o.bend')
    rs = _rd(OBJ / 'root_state.bend')
    eph = _rd(OBJ / 'encx_ExecutionPayloadHeader_iface.bend')
    sch = lambda j: 'SH.Chain_head(' + 'SH.Chain_tail(' * j + f'SH.Container_fields({SC})' + ')' * j + ')'
    pj = lambda j: f'ST.pj_BeaconState_{j}(o)'
    # the record's names, the object's positions (over them)
    KWN = [x.split(':')[0].strip() for x in _split(re.search(r'^type KW is Data:\n  KW\{(.*)\}$', Kt, re.M).group(1))]
    objc = re.search(r'^def OBJC\(.*?\) -> \S+: (.*)$', Kt, re.M).group(1)
    POS = [p for g in _peel(objc, OT) for p in _peel(g, g[:g.index('{')])]
    assert len(POS) == 38
    POSN = [re.sub(r'(?<![\w.])K?\.?F_(\w+)\(wR\)', r'\1', p) for p in POS]
    POSN = [re.sub(r'F_(\w+)\(wR\)', r'\1', p) for p in POSN]
    fnames = {j: [n for n in KWN if re.search(r'(?<![\w.])' + n + r'(?![\w])', POSN[j])] for j in range(38)}
    for n in KWN:
        if n.startswith('dB_'):
            j = [j for j in range(38) if ('TB_' + n[3:]) in fnames[j]][0]
            fnames[j].insert(fnames[j].index('TB_' + n[3:]), n)
    assert sum(len(v) for v in fnames.values()) == len(KWN)
    # the views (root_state's v_BeaconState), qualified
    vb = re.search(r'^def v_BeaconState\(o: .*\n(?:  .*\n)+', rs, re.M).group(0)
    vit = re.search(r'S\.Sequence\{(S\.Items\{.*)\}\s*$', vb.strip().split('\n')[-1].strip()).group(1)
    views = []
    while vit.startswith('S.Items{'):
        a = _peel(vit, 'S.Items'); views.append(a[0][:a[0].rindex('(')]); vit = a[1]
    views = [(w if '.' in w else 'ST.' + w) for w in views]
    assert len(views) == 38
    # the values
    valc = re.search(r'^def VALC\(.*?\) -> S\.Value: (.*)$', it, re.M).group(1)
    items, v = [], _peel(valc.strip(), 'S.Sequence')[0]
    while v.startswith('S.Items{'):
        a = _peel(v, 'S.Items'); items.append(a[0]); v = a[1]
    items = [re.sub(r'K\.F_(\w+)\(wR\)', r'\1', x) for x in items]
    FIX = {}
    for j in range(38):
        m = re.fullmatch(r'LV_(\w+)\((\w+)\)', items[j])
        if m:
            FIX[j] = m.group(1)
    TY = {'u64': 'O.U64', 'b32': 'FuluBytes32_d.Bytes32', 'Fork': 'FuluFork_d.Fork', 'BeaconBlockHeader': 'FuluBeaconBlockHeader_d.BeaconBlockHeader',
          'Eth1Data': 'FuluEth1Data_d.Eth1Data', 'Checkpoint': 'FuluCheckpoint_d.Checkpoint'}
    def fty(j):
        if j in FIX: return TY[FIX[j]]
        if j == BV4: return 'Fulu_bitvector_4_d.Bitvector4'
        if j in VEC or j in BYTEL: return 'O.Words'
        if j in RECL:
            L = RECL[j]; E = L.split('_', 1)[1]; n = L.split('_')[0][1:]
            return f'Fulu_list_{E}_{n}_d.{L}_Seq'
        if j in SCF: return 'FuluSyncCommittee_d.SyncCommittee'
        if j == EH: return EHB
        raise AssertionError(j)
    return EV, OT, SC, it, Kt, eno, ito, eph, sch, pj, KWN, fnames, views, FIX, fty


def _vs_view_lemmas(OT, views, FIX, fty):
    """the view of the record's object: OBJH, the equations of its parts and VALH, vz"""
    zs = [f'z{j}' for j in range(38)]
    grp = [(0, 8), (8, 16), (16, 24), (24, 32), (32, 38)]
    objt = lambda xs: f'{OT}{{' + ', '.join(f'FuluBeaconState_d.BeaconState_g{g}{{{", ".join(xs[a:b])}}}' for g, (a, b) in enumerate(grp)) + '}'
    # ---- OBJH / eqo / VALH / vz ----
    ws = [f'w{j}' for j in range(38)]
    PT = [j for j in range(38) if j not in FIX and j != BV4]
    out = []
    out.append(f'def OBJH({", ".join(f"{z}: {fty(j)}" for j, z in enumerate(zs))}) -> {OT}: {objt(zs)}\n')
    eqp = ', '.join([f'-{zs[j]}: {fty(j)}' for j in range(38)] + [f'-{ws[j]}: {fty(j)}, +q{j}: {{{zs[j]} == {ws[j]} : {fty(j)}}}' for j in PT])
    wcur = lambda k: [zs[j] if (j not in PT or PT.index(j) < k) else ('_' if PT.index(j) == k else ws[j]) for j in range(38)]
    out.append(f'def eqo({eqp}) -> {{OBJH({", ".join(zs)}) == OBJH({", ".join(zs[j] if j not in PT else ws[j] for j in range(38))}) : {OT}}}:')
    for k, j in enumerate(PT):
        out.append(f'  %q{j} : {{OBJH({", ".join(zs)}) == OBJH({", ".join(wcur(k))}) : {OT}}}')
    out.append('  {==}\n')
    ys = [f'Y{j}' for j in range(38)]
    valh = 'S.EmptyItems{}'
    for y in reversed(ys):
        valh = f'S.Items{{{y}, {valh}}}'
    out.append(f'def VALH({", ".join(f"+{y}: S.Value" for y in ys)}) -> S.Value: S.Sequence{{{valh}}}\n')
    LHS = f'ST.v_BeaconState(OBJH({", ".join(zs)}))'
    out.append(f'def vz({", ".join(f"{z}: {fty(j)}, +{y}: S.Value, +e{j}: {{{views[j]}({z}) == {y} : S.Value}}" for j, (z, y) in enumerate(zip(zs, ys)))}) -> {{{LHS} == VALH({", ".join(ys)}) : S.Value}}:')
    for k in range(38):
        cur = [f'{views[j]}(z{j})' if j < k else ('_' if j == k else f'Y{j}') for j in range(38)]
        out.append(f'  %e{k} : {{{LHS} == VALH({", ".join(cur)}) : S.Value}}')
    out.append('  {==}\n')
    return objt, PT, out


def _vs_sizes_okw(it, Kt, ito, KWN, fnames, PT, out):
    """the byte count (SZR) and the OKW facts of the record"""
    endcs = re.search(r'^def ENDCs\(\+wR: K\.KW, \+F: Nat\) -> Nat: (.*)$', it, re.M).group(1)
    terms = _sum_terms(endcs)
    assert terms[0] == 'F' and len(terms) == 13
    lnt = [re.sub(r'K\.F_(\w+)\(wR\)', r'\1', t) for t in terms[1:]]
    tj = []
    for t in lnt:
        js = [j for j in PT if any(re.search(r'(?<![\w.])' + n + r'(?![\w])', t) for n in fnames[j])]
        assert len(js) == 1, t
        tj.append(js[0])
    def objterm(j, o='o', pw=None):
        p = pw or f'ST.pj_BeaconState_{j}({o})'
        if j in BYTEL: return f'U32.to_nat(WO_L.len({p}))'
        if j in RECL: return f'RLS.WLL_{RECL[j]}({p})'
        if j == EH: return f'LNEH({p})'
        raise AssertionError(j)
    ts = ', '.join(f'+t{i}: Nat' for i in range(12))
    out.append(f'# the encoding\'s byte count: the fixed part F and the parts\' counts\ndef SZR(+F: Nat, {ts}) -> Nat: {_sumf(["F"] + [f"t{i}" for i in range(12)])}\n')
    # the encode law's size bound on the object (a decoded-object gap: its bytes within 4 * 2^28), stated as the record's
    # bound is (SZR over the parts' counts), so no closed count is evaluated
    SZO = f'Nat.is_lt(SZR(U32.to_nat(2737225), {", ".join(objterm(j) for j in tj)}), VB.pw(31n))'
    KWargs = ', '.join(KWN)
    KWparams = ', '.join(f'+{n}: {t.strip()}' for n, t in (x.split(':', 1) for x in _split(re.search(r'^type KW is Data:\n  KW\{(.*)\}$', Kt, re.M).group(1))))
    out.append(f'def endq({KWparams}, +F: Nat) -> {{CI.ENDCs(K.KW{{{KWargs}}}, F) == SZR(F, {", ".join(lnt)}) : Nat}}: {{==}}\n')
    # ---- OKT(KW{...}) from the facts ----
    okt = _band(re.search(r'^def OKTW\(\+wR: K\.KW\) -> Bool: (.*)$', ito, re.M).group(1))
    assert len(okt) == 36
    oktn = [re.sub(r'K\.F_(\w+)\(wR\)', r'\1', c).replace('OB.ENDCs(wR,', 'ENDCs(wR,').replace('ENDCs(wR,', f'CI.ENDCs(K.KW{{{KWargs}}},') for c in okt]
    fact = []
    for c in oktn:
        if c.startswith('Nat.is_lt(CI.ENDCs('):
            fact.append('hB'); continue
        if 'K.OK_bv4(' in c:
            fact.append('hv4a'); continue
        if 'bv4_valid(' in c:
            fact.append('hv4b'); continue
        js = [j for j in PT if any(re.search(r'(?<![\w.])' + n + r'(?![\w])', c) for n in fnames[j])]
        assert len(js) == 1, c
        j = js[0]
        if c.startswith('FD.array__perfect('): fact.append(f'pf{j}')
        elif c.startswith('Nat.is_lt('): fact.append(f'hd{j}')
        elif c.startswith('Nat.is_le('): fact.append(f'hr{j}')
        else: fact.append(f'k{j}')
    okp = ', '.join(f'+{f}: {{{c} == True{{}} : Bool}}' for f, c in zip(fact, oktn))
    out.append(f'def okw({KWparams}, {okp}) -> {{CIo.OKTW(K.KW{{{KWargs}}}) == True{{}} : Bool}}:\n  {_andc(oktn, fact)}\n')
    return lnt, tj, objterm, SZO, KWargs, KWparams, oktn, fact


def _vs_ks(OT, pj, fnames, views, FIX, fty, objt, PT, lnt, tj, objterm, SZO, KWargs, KWparams, oktn, fact):
    """kS: the record from its fields and the parts' records, with the byte bound"""
    xs = {j: fnames[j][0] for j in FIX}
    xs[BV4] = fnames[BV4][0]
    kp = [f'-o: {OT}'] + [f'+{xs[j]}: {fty(j)}' for j in sorted(xs)]
    c0 = objt([xs[j] if j in xs else pj(j) for j in range(38)])
    kp.append(f'+eo: {{o == {c0} : {OT}}}')
    kp.append(f'+hv4: {{Bool.and(K.OK_bv4({xs[BV4]}), Fulu_bitvector_4_e.bv4_valid({xs[BV4]})) == True{{}} : Bool}}')
    RT_ = {}
    for j in PT:
        if j in VEC: RT_[j] = f'PX.R_{"PV" if VEC[j][0] == "pv" else "V2"}({pj(j)}, {VEC[j][2]})'
        elif j in BYTEL: RT_[j] = f'PL.R_{BYTEL[j]}({pj(j)})'
        elif j in RECL: RT_[j] = f'RLS.R_W_{RECL[j]}({pj(j)})'
        elif j in SCF: RT_[j] = f'R_SC({pj(j)})'
        else: RT_[j] = f'R_EB({pj(j)})'
        kp.append(f'+r{j}: {RT_[j]}')
    kp.append(f'+hZ: {{{SZO} == True{{}} : Bool}}')
    body = []
    def destr(src, names):
        cur = src
        for i, n in enumerate(names[:-2]):
            body.append(f'  (+{n}, {src}_{i}) = {cur}'); cur = f'{src}_{i}'
        body.append(f'  (+{names[-2]}, +{names[-1]}) = {cur}')
    TH, Y = {}, {}
    for j in PT:
        f = fnames[j]
        if j in VEC:
            dB, TB = f
            destr(f'r{j}', [TB, dB, f'e{j}', f'v{j}', f'pf{j}', f'hd{j}', f'hr{j}'])
            TH[j] = f'O.Words{{FD.array__thaw(U32, {TB}), {VEC[j][2]}}}'
            Y[j] = f'FWS.{"VV8" if VEC[j][0] == "pv" else "VU2"}(VC.NW({VEC[j][2]}), {TB})'
        elif j in BYTEL:
            destr(f'r{j}', [f[0], f'e{j}', f'v{j}', f'k{j}', f'l{j}'])
            TH[j] = f'{EXA[BYTEL[j]]}.TH({f[0]})'; Y[j] = f'{EXA[BYTEL[j]]}.VAL({f[0]})'
        elif j in RECL:
            destr(f'r{j}', [f[0], f[1], f'e{j}', f'v{j}', f'k{j}', f'l{j}'])
            L = RECL[j]
            TH[j] = f'EW_{L}.THL_{L}({f[0]}, {f[1]})'; Y[j] = f'EW_{L}.VALL_{L}({f[0]}, {f[1]})'
        elif j in SCF:
            dB, TB = f[0], f[1]
            destr(f'r{j}', [TB, dB] + f[2:] + [f'e{j}', f'v{j}', f'pf{j}', f'hd{j}', f'hr{j}'])
            TH[j] = f'FuluSyncCommittee_d.SyncCommittee{{O.Words{{FD.array__thaw(U32, {TB}), 24576}}, FuluBytes48_d.Bytes48{{{", ".join(f[2:])}}}}}'
            Y[j] = f'FWS.SCV({TB}, {", ".join(f[2:])})'
        else:
            destr(f'r{j}', [f[0], f'e{j}', f'v{j}', f'k{j}', f'l{j}'])
            TH[j] = f'O.BSome{{EC_ExecutionPayloadHeader.TH({f[0]}), O.BNone{{}}}}'; Y[j] = f'EC_ExecutionPayloadHeader.VAL({f[0]})'
    body.append(f'  +hv4a = FD.logic__and_left(K.OK_bv4({xs[BV4]}), Fulu_bitvector_4_e.bv4_valid({xs[BV4]}), hv4)')
    body.append(f'  +hv4b = FD.logic__and_right(K.OK_bv4({xs[BV4]}), Fulu_bitvector_4_e.bv4_valid({xs[BV4]}), hv4)')
    # the bound through the parts' counts
    mix = lambda k, zz: [lnt[i] if i < k else (zz if i == k else objterm(tj[i])) for i in range(12)]
    prev = 'hZ'
    for i, j in enumerate(tj):
        a_ = objterm(j); b_ = lnt[i]
        body.append(f'  +b{i} = FD.logic__subst(Nat, z => {{Nat.is_lt(SZR(U32.to_nat(2737225), {", ".join(mix(i, "z"))}), VB.pw(31n)) == True{{}} : Bool}}, {a_}, {b_}, Equal.sym(Nat, {b_}, {a_}, l{j}), {prev})')
        prev = f'b{i}'
    SZL = f'SZR(U32.to_nat(2737225), {", ".join(lnt)})'
    body.append(f'  +hB = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(31n)) == True{{}} : Bool}}, {SZL}, CI.ENDCs(K.KW{{{KWargs}}}, U32.to_nat(2737225)), '
                f'Equal.sym(Nat, CI.ENDCs(K.KW{{{KWargs}}}, U32.to_nat(2737225)), {SZL}, endq({KWargs}, U32.to_nat(2737225))), {prev})')
    body.append(f'  +hok = okw({KWargs}, {", ".join(fact)})')
    eqargs = ', '.join([pj(j) if j in PT else xs[j] for j in range(38)] + [f'{TH[j]}, e{j}' for j in PT])
    body.append(f'  +eq = Equal.trans({OT}, o, OBJH({", ".join(pj(j) if j in PT else xs[j] for j in range(38))}), OBJH({", ".join(TH[j] if j in PT else xs[j] for j in range(38))}), eo, eqo({eqargs}))')
    vzargs = []
    for j in range(38):
        if j in FIX: vzargs.append(f'{xs[j]}, CI.LV_{FIX[j]}({xs[j]}), lv_{FIX[j]}({xs[j]})')
        elif j == BV4: vzargs.append(f'{xs[j]}, CI.VBo_bv4({xs[j]}), lv_bv4({xs[j]})')
        elif j in VEC or j in SCF:
            # the view of the pubkeys / vector words would unroll if compared against the record's field (K.F_TB(KW)):
            # carry the fact over to it (TB == K.F_TB(KW) by computation)
            TBn = fnames[j][1]
            FTB = f'K.F_{TBn}(K.KW{{{KWargs}}})'
            sub = lambda x_: re.sub(r'(?<![\w.])' + TBn + r'(?![\w])', 'z', x_)
            sub2 = lambda x_: re.sub(r'(?<![\w.])' + TBn + r'(?![\w])', FTB, x_)
            body.append(f'  +vt{j} = FD.logic__subst(FD.array__Tree<U32>, z => {{{views[j]}({sub(TH[j])}) == {sub(Y[j])} : S.Value}}, {TBn}, {FTB}, {{==}}, v{j})')
            vzargs.append(f'{sub2(TH[j])}, {sub2(Y[j])}, vt{j}')
        else: vzargs.append(f'{TH[j]}, {Y[j]}, v{j}')
    body.append(f'  via(o, CI.MW{{K.KW{{{KWargs}}}}}, eq, vz({", ".join(vzargs)}), hok)')
    # split: kS destructures the records; bndz / fin work on the facts alone (small contexts)
    dlines = [l for l in body if l.startswith('  (')]
    clines = [l for l in body if not l.startswith('  (')]
    conj = dict(zip(fact, oktn))
    FT = {}
    for j in PT:
        FT[f'e{j}'] = f'{{{pj(j)} == {TH[j]} : {fty(j)}}}'
        FT[f'v{j}'] = f'{{{views[j]}({TH[j]}) == {Y[j]} : S.Value}}'
        for f_ in (f'pf{j}', f'hd{j}', f'hr{j}', f'k{j}'):
            if f_ in conj:
                FT[f_] = f'{{{conj[f_]} == True{{}} : Bool}}'
    for i, j in enumerate(tj):
        FT[f'l{j}'] = f'{{{lnt[i]} == {objterm(j)} : Nat}}'
    fnm = [n for j in PT for n in (f'e{j}', f'v{j}', f'pf{j}', f'hd{j}', f'hr{j}', f'k{j}', f'l{j}') if n in FT]
    ln_ = [f'l{j}' for j in tj]
    hz_t = f'{{{SZO} == True{{}} : Bool}}'
    bl = [l for l in clines if l.startswith('  +b') or l.startswith('  +hB')]
    rest = [l for l in clines if l not in bl]
    bndz = (f"# the record's byte bound from the object's (hZ) through the parts' counts\n"
            f"def bndz(-o: {OT}, {KWparams}, {', '.join(f'+{n}: {FT[n]}' for n in ln_)}, +hZ: {hz_t})\n"
            f"    -> {{Nat.is_lt(CI.ENDCs(K.KW{{{KWargs}}}, U32.to_nat(2737225)), VB.pw(31n)) == True{{}} : Bool}}:\n" + '\n'.join(bl) + '\n  hB\n')
    finp = [f'-o: {OT}', KWparams, kp[len(xs) + 1], kp[len(xs) + 2]] + [f'+{n}: {FT[n]}' for n in fnm] + [f'+hZ: {hz_t}']
    fin = (f"def fin({', '.join(finp)}) -> @G@:\n"
           + '\n'.join([rest[0], rest[1], f'  +hB = bndz(o, {KWargs}, {", ".join(ln_)}, hZ)'] + rest[2:]) + '\n')
    kS = (bndz + '\n' + fin + f"\n# the record, from the fields and the parts' records\ndef kS({', '.join(kp)}) -> @G@:\n" + '\n'.join(dlines)
          + f"\n  fin(o, {KWargs}, eo, hv4, {', '.join(fnm)}, hZ)\n")
    return xs, kS


def _vs_mk(R, OT, SC, sch, pj, PT, SZO, xs):
    """mk: the record of every object the root law represents"""
    top_p, mkc = [], {}
    for j in PT:
        s_ = sch(j)
        if j in VEC:
            k_, K_, L_, e_, p_, r_, sx_ = VEC[j]
            top_p.append((f'hs{j}', f'BL.sdpv({pj(j)}, 31n)' if k_ == 'pv' else f'BL.sdk1({pj(j)}, 31n)'))
            mkc[j] = (f'PX.mk_{"PV" if k_ == "pv" else "V2"}({pj(j)}, {s_}, r{j}, hs{j}, {K_}, {L_}, {e_}n, {p_}n, {r_}n, {sx_}n, ' + ', '.join(['{==}'] * 10) + ')')
        elif j in BYTEL:
            top_p.append((f'hs{j}', f'U.sdk({pj(j)}, 31n)'))
            top_p.append((f'hm{j}', f'{{Nat.is_lt(U32.to_nat(WO_L.len({pj(j)})), VB.pw(31n)) == True{{}} : Bool}}'))
            if BYTEL[j] == 'H': mkc[j] = f'PL.mk_H({pj(j)}, {s_}, {{==}}, r{j}, hs{j}, hm{j})'
            elif BYTEL[j] == 'U': mkc[j] = f'PL.mk_U({pj(j)}, {s_}, r{j}, hs{j}, hm{j})'
            else: mkc[j] = f'PL.mk_B8({pj(j)}, hs{j}, hm{j})'
        elif j in RECL:
            L = RECL[j]
            KWb = re.fullmatch(r'Nat\.is_lt\(TDM_' + L + r'\(A\), (\d+)n\)', _band(re.search(r'^def OKL_' + L + r'\(.*?\) -> Bool:\n((?:  .*\n)+)', _rd(OBJ / f'encx_{L}.bend'), re.M).group(1))[0]).group(1)
            top_p.append((f'hs{j}', f'RLS.sda_{L}({pj(j)}, {KWb}n)'))
            lim = ', {==}' if L != 'l1099511627776_Validator' else ''
            mkc[j] = f'RLS.mk_W_{L}({pj(j)}, {s_}{lim}, r{j}, hs{j})'
        elif j in SCF:
            top_p.append((f'hs{j}', f'EW.sdsc(RT.pj_SyncCommittee_0({pj(j)}), 31n)'))
            mkc[j] = f'mk_SC({pj(j)}, {s_}, r{j}, hs{j})'
        else:
            top_p.append((f'hs{j}', f'MW.SHS_E(RT.pjb_ExecutionPayloadHeader_bx({pj(j)}))'))
            mkc[j] = f'mk_EB({pj(j)}, {s_}, {{==}}, r{j}, hs{j})'
    reps = [j for j in PT] + [BV4]
    reps.sort()
    tb = []
    names = [xs[j] for j in sorted(xs)] + ['eo'] + [f'r{j}' for j in reps]
    cur = 'rep'
    for i, n in enumerate(names[:-2]):
        tb.append(f'  (+{n}, q{i}) = {cur}'); cur = f'q{i}'
    tb.append(f'  (+{names[-2]}, +{names[-1]}) = {cur}')
    kargs = ', '.join(['o'] + [xs[j] for j in sorted(xs)] + ['eo', f'ok4({xs[BV4]}, r{BV4})'] + [mkc[j] for j in PT] + ['hZ'])
    tb.append(f'  kS({kargs})')
    law = (f"\n# (i): for every object the root law represents (rep) whose storage is as the encode record asks (decoded-object gaps:\n"
           f"# hs5/hs6/hs13 the Bytes32 vectors and hs14/hs37 the uint64 vectors at depth below 31, hs7/hs12/hs15/hs16/hs21 the byte-storage\n"
           f"# lists at depth below 31 (the D twins of the lists, the OKW laws), hs9..hs36 the record lists' trees below the records' bounds,\n"
           f"# hs22/hs23 the sync committees' pubkeys below 31, hs24 the latest execution payload header's storage (e2e_mw.SHS_E), hZ its\n"
           f"# bytes below 2^31, the object API's own limit; hm7/hm12/hm15/hm16/hm21 each byte-storage list's bytes below 2^31, a part of hZ's total)\n"
           f"def {R}_e2e_encode(-o: {OT}, +rep: ST.rep_BeaconState(o, {SC}), {', '.join(f'+{n}: {t}' for n, t in top_p)}, +hZ: {{{SZO} == True{{}} : Bool}}) -> @G@:\n"
           + '\n'.join(tb) + '\n')
    return law


def _vs_common(R, X, EV, OT, eno, eph, out, kS, law):
    """the common text of the encode records, the encoder's buffer facts and the top-level parts"""
    G, common = EV._encx_common(R, X, OT, 0, 10)
    i0 = eno.index('def putx0O(')
    j0 = re.search(r'\n  Ko?\.putx', eno[i0:]).start() + i0
    want = ('es', 'h31', 'e31', 'hS', 'eNW', 'nw', 'nwp', 'hd', 'hcov', 'hl0')
    lets, curn = [], None
    for l in eno[i0:j0].split('\n')[2:]:
        mm = re.match(r'  \+(\w+) = ', l)
        if mm:
            curn = mm.group(1)
        if curn in want:
            lets.append(l)
    SZ_ = 'Z.SZS(wR)'; DO = f'VL.DO({SZ_})'; OUT = 'EN.OUTC(wR)'
    obc = (f"# the encoder's buffer's bytes: the output tree is perfect at depth DO(size) < 31, the size (below 2^31) within it\n"
           f"def obC(+wR: K.KW, +h: {{CIo.OKTW(wR) == True{{}} : Bool}}, +k: Nat, +ek: {{k == 29n : Nat}})\n"
           f"    -> {{E.obytes(B.Buf{{FD.array__thaw(U32, {OUT}), {SZ_}}}) == VSP.bt(U32.to_nat({SZ_}), SF.limbs(FD.array__slots(U32, {OUT}))) : +List<U32>}}:\n"
           + '\n'.join(lets) + '\n' +
           f"  +ep = VCN.padb_id(0n, U32.to_nat({SZ_}))\n"
           f"  +hq = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat({SZ_}), z) == True{{}} : Bool}}, Nat.add(U32.to_nat({SZ_}), WD.PADB(0n, U32.to_nat({SZ_}))), A.quad(WD.NWN(U32.to_nat({SZ_}))), ep,\n"
           f"    FD.nat__le_add_right(U32.to_nat({SZ_}), WD.PADB(0n, U32.to_nat({SZ_}))))\n"
           f"  +hn = FD.nat__le_trans(U32.to_nat({SZ_}), A.quad(WD.NWN(U32.to_nat({SZ_}))), A.quad(FD.spec_common__pow2({DO})), hq, C.q4(WD.NWN(U32.to_nat({SZ_})), FD.spec_common__pow2({DO}), hl0))\n"
           # the tree's perfection from K.pfC at PUTC(wR, .., 0, 0n, 0n), restated at OUTC(wR) (which is that
           # term by definition) in a motive over the tree: a conversion between two spellings under
           # array__perfect would unfold array__perfect over the whole tree first
           f"  +pfo = FD.logic__subst(FD.array__Tree<U32>, z => {{FD.array__perfect(U32, {DO}, z) == True{{}} : Bool}}, K.PUTC(wR, {DO}, VC.ZT({DO}), 0, 0n, 0n), {OUT}, {{==}},\n"
           f"    K.pfC(wR, {DO}, VC.ZT({DO}), 0, 0n, 0n, FD.array__trep_perfect(U32, {DO}, 0)))\n"
           f"  EM.obD({DO}, {OUT}, {SZ_}, pfo, hd, h31, hn)\n\n"
           f"def obM(+m: CI.MW, +hok: {{CIo.OKW(m) == True{{}} : Bool}}) -> {{E.obytes(B.Buf{{FD.array__thaw(U32, EN.OUTE(m)), EN.SZSM(m)}}) == VSP.bt(U32.to_nat(EN.SZSM(m)), SF.limbs(FD.array__slots(U32, EN.OUTE(m)))) : +List<U32>}}:\n"
           f"  match m:\n    case CI.MW{{+wR}}: obC(wR, hok, 29n, {{==}})\n")
    a = common.index("# the encoder's buffer"); b = common.index('# (i) on a record')
    rest = common[b:].replace('{CI.OK(m) == True{} : Bool}', '{CIo.OKW(m) == True{} : Bool}').replace('EN.encode_eval(', 'ENo.encode_evalO(').replace('EN.encode_spec(', 'ENo.encode_specO(')
    common = common[:a] + obc + '\n' + rest
    # the header's record arguments
    ephn = [x.split(':')[0].strip() for x in _split(re.search(r'^type MW is Data:\n  MW\{(.*)\}$', eph, re.M).group(1))]
    assert ephn[11] == 'm_extra_data'
    tex = TOP_EXTRA.replace('@EPHP@', ', '.join(f'+a{i}' for i in range(len(ephn)))).replace('@EPHA@', ', '.join(f'a{i}' for i in range(len(ephn))))
    tex = tex.replace('@EHB@', EHB).replace('@EHO@', EHO)
    text = (common + '\n' + top_parts() + '\n' + tex + '\n' + "# ---- the record's object and view ----\n" + '\n'.join(out) + '\n' + kS + law).replace('@G@', G('o'))
    return text


def _vs_assemble(R, EV, it, text):
    """the module text: imports and the definitions in order"""
    iimps = []
    for mm in re.finditer(r'^import (\S+) as (\w+)$', it, re.M):
        p, al = mm.group(1), mm.group(2)
        p = p.replace('../../', '../') if p.startswith('../../') else ('../proofs/' + p[3:] if p.startswith('../') else '../proofs/obj/' + p[2:])
        iimps.append((p, al))
    base = [('../END_TO_END.bend', 'E2E'), ('../src/model.bend', 'API'), ('../src/buffer.bend', 'B'), ('../src/obj.bend', 'O'),
            (f'../types/{R}_encode_ssz_generated.bend', f'{R}_e'), ('../types/schema.bend', 'S'), ('../types/primitive.bend', 'P'), ('../spec/fulu_schemas.bend', 'Spec'),
            ('../proofs/type_validator_soundness.bend', 'VS'), ('../proofs/compact/found.bend', 'FD'), ('../proofs/compact/arith.bend', 'A'),
            ('../proofs/nat_order.bend', 'Order'), ('../proofs/word_split.bend', 'WSp'), ('../proofs/power_division.bend', 'PD'),
            ('../spec/codec.bend', 'Encoding'), ('../proofs/obj/spec_fixed.bend', 'SF'), ('../proofs/obj/spec_fixed.bend', 'FX'),
            ('../proofs/obj/vspec.bend', 'VSP'), ('../proofs/obj/vbuf.bend', 'VB'), ('../proofs/obj/vcopy.bend', 'VC'), ('../proofs/obj/vcont.bend', 'VCN'),
            ('../proofs/obj/vrecx.bend', 'VRX'), ('../proofs/obj/vdepth.bend', 'VD'), ('../proofs/obj/vlist.bend', 'VL'), ('../proofs/obj/vuwd.bend', 'WD'),
            ('../proofs/obj/vua_lay.bend', 'LY'), ('../proofs/obj/vconts.bend', 'CS'), ('../proofs/obj/arr_vec.bend', 'AV'), ('../proofs/obj/dk.bend', 'DK'),
            ('../proofs/obj/words_obj_light.bend', 'WO_L'), ('../proofs/obj/words_spec.bend', 'WS'), ('../proofs/obj/schema_shapes.bend', 'SH'),
            ('../proofs/obj/elems48.bend', 'E48'), ('../proofs/obj/bitlist_pack.bend', 'BLP'), ('../proofs/obj/vfx_bv4.bend', 'VFB4'),
            ('../proofs/obj/root_names.bend', 'RN'), ('../proofs/obj/root_names_light.bend', 'RN_L'), ('../proofs/obj/root_types.bend', 'RT'),
            ('../proofs/obj/root_state.bend', 'ST'), ('../proofs/obj/pv_obj.bend', 'PV'), ('../proofs/obj/packed_obj_light.bend', 'PK_L'),
            ('../proofs/obj/packed_bytes_light.bend', 'PB'), ('../proofs/obj/blist_obj.bend', 'BLI'), ('../proofs/obj/ulist_obj.bend', 'UL'),
            ('../proofs/obj/var_codec_BeaconState_enc.bend', 'EN'), ('../proofs/obj/encx_BeaconState_iface.bend', 'CI'),
            ('../proofs/obj/encx_BeaconState_size.bend', 'Z'), ('../proofs/obj/encx_ExecutionPayloadHeader.bend', 'IK'),
            ('../proofs/obj/encx_bl32.bend', 'EB'),
            ('../proofs/obj/encx_BeaconState_iface_o.bend', 'CIo'), ('../proofs/obj/var_codec_BeaconState_enc_o.bend', 'ENo'),
            ('../proofs/obj/encx_BeaconState_size_o.bend', 'Zo'), ('../proofs/obj/encx_ExecutionPayloadHeader_iface_o.bend', 'ECo'),
            ('../proofs/obj/encx_l16777216_b32_d.bend', 'EX_l16777216_b32_D'), ('../proofs/obj/encx_l1099511627776_u64_d.bend', 'EX_l1099511627776_u64_D'),
            ('../proofs/obj/encx_l1099511627776_u8_d.bend', 'EX_l1099511627776_u8_D')]
    base += iimps
    base += [('../types/FuluSyncCommittee_def_generated.bend', 'FuluSyncCommittee_d'), ('../types/FuluBytes48_def_generated.bend', 'FuluBytes48_d'),
             ('../types/FuluBytes4_def_generated.bend', 'FuluBytes4_d'), ('../types/FuluExecutionPayloadHeader_def_generated.bend', 'FuluExecutionPayloadHeader_d')]
    for j, L in RECL.items():
        E = L.split('_', 1)[1]; n = L.split('_')[0][1:]
        base.append((f'../types/Fulu_list_{E}_{n}_def_generated.bend', f'Fulu_list_{E}_{n}_d'))
    base += [('./e2e_support.bend', 'E'), ('./e2e_emit.bend', 'EM'), ('./e2e_cap.bend', 'C'), ('./e2e_blist.bend', 'BL'), ('./e2e_u64l.bend', 'U'),
             ('./e2e_mw.bend', 'MW'), ('./e2e_e48w.bend', 'EW'), ('./e2e_bsx.bend', 'PX'), ('./e2e_bsl.bend', 'PL'), ('./e2e_rls.bend', 'RLS')]
    seen, imps = set(), ['import Base']
    for p, al in base:
        if al in seen:
            continue
        seen.add(al); imps.append(f'import {p} as {al}')
    return EV.st_qualify('\n'.join(imps) + f"\n\n# GENERATED by e2e_bridge (codegen: e2e_state_enc). Do not edit.\n"
            f"# {R} (variable size): the object API's encoder's bytes are END_TO_END's serialize of the object's view, for every\n"
            f"# object the root law represents (rep) whose storage is as its encode record asks, through the encode record (CI.MW).\n\n" + text)


def venc_state(R, X):
    EV, OT, SC, it, Kt, eno, ito, eph, sch, pj, KWN, fnames, views, FIX, fty = _vs_load(X)
    objt, PT, out = _vs_view_lemmas(OT, views, FIX, fty)
    # ---- the bound: ENDCs' terms, each a part's byte count ----
    lnt, tj, objterm, SZO, KWargs, KWparams, oktn, fact = _vs_sizes_okw(it, Kt, ito, KWN, fnames, PT, out)
    # ---- kS: the record from the parts ----
    xs, kS = _vs_ks(OT, pj, fnames, views, FIX, fty, objt, PT, lnt, tj, objterm, SZO, KWargs, KWparams, oktn, fact)
    # ---- the law: from rep and the premises ----
    law = _vs_mk(R, OT, SC, sch, pj, PT, SZO, xs)
    # ---- the encoder's buffer (the output tree of depth DO(size) < 31: the OKW laws, var_codec_BeaconState_enc_o) and via ----
    text = _vs_common(R, X, EV, OT, eno, eph, out, kS, law)
    # imports: the iface's own (as seen from e2e/), and the modules above
    return _vs_assemble(R, EV, it, text)


STATE_PREMISE = ('rep: ST.rep_BeaconState(o, Spec.BeaconState()) and the encode record\'s storage bounds as premises, each a decoded-object gap '
                 '(the root law\'s invariant gives depth below 32 and no size bound); the record is on the OKW laws and the D twins of the lists (the container '
                 'encodes below 2^31 bytes, the object API\'s own limit; no depth-28 storage premise): the Bytes32 vectors (BL.sdpv) and uint64 vectors '
                 '(BL.sdk1) and the sync committees\' pubkeys (EW.sdsc) at depth below 31, the byte-storage lists at depth below 31 (U.sdk), the record '
                 'lists\' trees below their records\' bounds (RLS.sda_L), the latest execution payload header\'s storage (e2e_mw.SHS_E), '
                 'hM_j each byte-storage list\'s bytes below 2^31 (its share of the total), hZ the encoding below 2^31 bytes (SZR of the fixed part and the parts\' counts)')
