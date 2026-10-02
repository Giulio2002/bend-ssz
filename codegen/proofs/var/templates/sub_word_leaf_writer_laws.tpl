@@ U8 @@

# ---- O.w8 at X = 4 q + r ----------------------------------------------------------------------------

def W8X(+r: Nat, +dd: Nat, +D: ${TR}, +q: Nat, +x: U32) -> ${TR}: UW.ORW(dd, D, q, VWB.SHB(U32.and(x, 255), r))

def w8x_perfect(+r: Nat, +dd: Nat, +D: ${TR}, +q: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, W8X(r, dd, D, q, x)) == ${TRUE}}:
  UW.orw_perfect(dd, D, q, VWB.SHB(U32.and(x, 255), r), pf)

# A byte position 4 q + j, j < 4, below 4 P when q < P.
def bnd(+q: Nat, +j: Nat, +P: Nat, +hq: {Nat.is_lt(q, P) == ${TRUE}}, +hj: {Nat.is_lt(j, 4n) == ${TRUE}})
    -> {Nat.is_lt(Nat.add(A.quad(q), j), A.quad(P)) == ${TRUE}}:
  +h0 = FD.nat__succ_le_lt(Nat.add(j, A.quad(q)), Nat.add(4n, A.quad(q)), Order.add_right(1n+j, 4n, A.quad(q), FD.nat__lt_succ_le_succ(j, 4n, hj)))
  +h1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, Nat.add(4n, A.quad(q))) == ${TRUE}}, Nat.add(j, A.quad(q)), Nat.add(A.quad(q), j), FD.nat__add_comm(j, A.quad(q)), h0)
  FD.nat__lt_le_trans(Nat.add(A.quad(q), j), Nat.add(4n, A.quad(q)), A.quad(P), h1, UW.quad_le(1n+q, P, FD.nat__lt_succ_le_succ(q, P, hq)))

def hq1(+q: Nat, +r: Nat, +dd: Nat, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == ${TRUE}})
    -> {Nat.is_lt(q, VB.pw(dd)) == ${TRUE}}:
  match r:
    case 0n: UWD.le_q(q, 0n, VB.pw(dd), hl)
    case 1n: UWD.le_q(q, 0n, VB.pw(dd), hl)
    case 2n: UWD.le_q(q, 0n, VB.pw(dd), hl)
    case 3n: UWD.le_q(q, 0n, VB.pw(dd), hl)
    case 4n+ +t: Empty.absurd({Nat.is_lt(q, VB.pw(dd)) == ${TRUE}}, FD.nat__lt_zero_absurd(t, hr))

# T.u8_put (O.w8) at any byte position.
def w8_any(+dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {T.u8_put(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W8X(r, dd, D, q, x)) : Array<U32>}:
  %Equal.sym(U32, O.shl_bytes(U32.and(x, 255), U32.and(X, 3)), VWB.SHB(U32.and(x, 255), U32.to_nat(U32.and(X, 3))), VWB.shb_u(U32.and(x, 255), X)) :
    {O.or_word(FD.array__thaw(U32, D), U32.shrn(X, 2n), _) == FD.array__thaw(U32, W8X(r, dd, D, q, x)) : Array<U32>}
  %Equal.sym(Nat, U32.to_nat(U32.and(X, 3)), r, Pair.snd({U32.to_nat(U32.shrn(X, 2n)) == q : Nat}, {U32.to_nat(U32.and(X, 3)) == r : Nat}, UW.ua_pair(X, q, r, e, hr))) :
    {O.or_word(FD.array__thaw(U32, D), U32.shrn(X, 2n), VWB.SHB(U32.and(x, 255), _)) == FD.array__thaw(U32, W8X(r, dd, D, q, x)) : Array<U32>}
  UW.orw_rt(dd, D, U32.shrn(X, 2n), q, VWB.SHB(U32.and(x, 255), r), UW.ua_q(X, q, r, e, hr), FD.nat__lt_trans(dd, 29n, 32n, hd, {==}), hq1(q, r, dd, hr, hl), pf)

# 4 q + r is a byte of the tree.
def hxP(+q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hq: {Nat.is_lt(q, VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {Nat.is_le(Nat.add(A.quad(q), r), List.length(&2, U32, UA.BYT(D))) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), r), z) == ${TRUE}}, ${Q}, List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), ${Q}, VR.lenS(dd, D, pf)),
    FD.nat__lt_le(Nat.add(A.quad(q), r), ${Q}, bnd(q, r, VB.pw(dd), hq, hr)))

# Its bytes: the byte x & 255 at X, when the byte there was zero.
def w8_any_bytes(+dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(1n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(1n) : +List<U32>})
    -> {UA.BYT(W8X(r, dd, D, q, x)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), [U32.and(x, 255)]) : +List<U32>}:
  +B = UA.BYT(D)
  +P = Nat.add(A.quad(q), r)
  +v = U32.and(x, 255)
  +hq = hq1(q, r, dd, hr, hl)
  +e0 = UW.inv_init(B, P, 1n, [0], hz, {==})
  +e1 = VWB.tor(dd, D, q, r, x, pf, hq, hr)
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => VWB.ORB(z, P, v), B, UW.SPL(B, P, [0]), e0)
  +e3 = FD.logic__subst(Nat, z => {VWB.ORB(UW.SPL(B, P, [0]), z, v) == UW.SPL(B, P, [U32.or(0, v)]) : +List<U32>}, Nat.add(P, 0n), P, FD.nat__add_zero(P),
    VWB.orb_spl(B, P, [0], 0n, v, hxP(q, r, dd, D, hr, hq, pf), {==}))
  Equal.trans(+List<U32>, UA.BYT(W8X(r, dd, D, q, x)), VWB.ORB(B, P, v), UW.SPL(B, P, [v]), e1,
    Equal.trans(+List<U32>, VWB.ORB(B, P, v), VWB.ORB(UW.SPL(B, P, [0]), P, v), UW.SPL(B, P, [v]), e2,
      Equal.trans(+List<U32>, VWB.ORB(UW.SPL(B, P, [0]), P, v), UW.SPL(B, P, [U32.or(0, v)]), UW.SPL(B, P, [v]), e3,
        Equal.cong(U32, +List<U32>, z => UW.SPL(B, P, [z]), U32.or(0, v), v, VBE.zero_or(v)))))

@@ u16_text @@

# ---- O.w16 at X = 4 q + r: two w8 ------------------------------------------------------------------

def W16X(+r: Nat, +dd: Nat, +D: ${TR}, +q: Nat, +x: U32) -> ${TR}:
  match r:
@@ u16_text_w16_any @@
# T.u16_put (O.w16) at any byte position.
def w16_any(+dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 2n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {T.u16_put(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W16X(r, dd, D, q, x)) : Array<U32>}:
  match r:
@@ u16_text_2 @@
    case ${c['k']}n:
      %Equal.sym(Array<U32>, O.w8(FD.array__thaw(U32, D), X, x), FD.array__thaw(U32, ${D1}), w8_any(dd, D, X, q, ${c['k']}n, x, e, {==}, hd, ${c['hl_a']}, pf)) :
        {O.w8(_, U32.add(X, 1), U32.shrn(x, 8n)) == FD.array__thaw(U32, W16X(${c['k']}n, dd, D, q, x)) : Array<U32>}
      w8_any(dd, ${D1}, U32.add(X, 1), ${c['q1']}, ${c['r1']}, U32.shrn(x, 8n), ${e1(c)}, {==}, hd, ${c['hl_b']}, w8x_perfect(${c['k']}n, dd, D, q, x, pf))
@@ u16_text_w16_any_bytes @@
# Its bytes: x's two low bytes at X, when the two bytes there were zero.
def w16_any_bytes(+dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 2n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(2n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(2n) : +List<U32>})
    -> {UA.BYT(W16X(r, dd, D, q, x)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) : +List<U32>}:
  match r:
@@ u16_text_3 @@
    case ${k}n:
      +B = UA.BYT(D)
      +P = ${P}
      +v0 = U32.and(x, 255)
      +v1 = U32.and(U32.shrn(x, 8n), 255)
      +hq = ${c['hq_a']}
      +hX = hxP(q, ${k}n, dd, D, {==}, hq, pf)
      +e0 = UW.inv_init(B, P, 2n, [0, 0], hz, {==})
      +f1 = Equal.trans(+List<U32>, UA.BYT(${D1}), VWB.ORB(B, P, v0), UW.SPL(B, P, [U32.or(0, v0), 0]), VWB.tor(dd, D, q, ${k}n, x, pf, hq, {==}),
        Equal.trans(+List<U32>, VWB.ORB(B, P, v0), VWB.ORB(UW.SPL(B, P, [0, 0]), P, v0), UW.SPL(B, P, [U32.or(0, v0), 0]),
          Equal.cong(+List<U32>, +List<U32>, z => VWB.ORB(z, P, v0), B, UW.SPL(B, P, [0, 0]), e0),
          FD.logic__subst(Nat, z => {VWB.ORB(UW.SPL(B, P, [0, 0]), z, v0) == UW.SPL(B, P, [U32.or(0, v0), 0]) : +List<U32>}, Nat.add(P, 0n), P, FD.nat__add_zero(P),
            VWB.orb_spl(B, P, [0, 0], 0n, v0, hX, {==}))))
      +p2 = Equal.trans(Nat, Nat.add(A.quad(${c['q1']}), ${c['r1']}), 1n+P, Nat.add(P, 1n), ${c['eqP']}, Equal.sym(Nat, Nat.add(P, 1n), 1n+P, FD.nat__add_comm(P, 1n)))
      +g1 = VWB.tor(dd, ${D1}, ${c['q1']}, ${c['r1']}, U32.shrn(x, 8n), w8x_perfect(${k}n, dd, D, q, x, pf), ${c['hq_b']}, {==})
      +g2 = FD.logic__subst(Nat, z => {UA.BYT(W16X(${k}n, dd, D, q, x)) == VWB.ORB(UA.BYT(${D1}), z, v1) : +List<U32>}, Nat.add(A.quad(${c['q1']}), ${c['r1']}), Nat.add(P, 1n), p2, g1)
      +g3 = Equal.cong(+List<U32>, +List<U32>, z => VWB.ORB(z, Nat.add(P, 1n), v1), UA.BYT(${D1}), UW.SPL(B, P, [U32.or(0, v0), 0]), f1)
      +g4 = VWB.orb_spl(B, P, [U32.or(0, v0), 0], 1n, v1, hX, {==})
      Equal.trans(+List<U32>, UA.BYT(W16X(${k}n, dd, D, q, x)), UW.SPL(B, P, [U32.or(0, v0), U32.or(0, v1)]), UW.SPL(B, P, [v0, v1]),
        Equal.trans(+List<U32>, UA.BYT(W16X(${k}n, dd, D, q, x)), VWB.ORB(UA.BYT(${D1}), Nat.add(P, 1n), v1), UW.SPL(B, P, [U32.or(0, v0), U32.or(0, v1)]), g2,
          Equal.trans(+List<U32>, VWB.ORB(UA.BYT(${D1}), Nat.add(P, 1n), v1), VWB.ORB(UW.SPL(B, P, [U32.or(0, v0), 0]), Nat.add(P, 1n), v1), UW.SPL(B, P, [U32.or(0, v0), U32.or(0, v1)]), g3, g4)),
        Equal.trans(+List<U32>, UW.SPL(B, P, [U32.or(0, v0), U32.or(0, v1)]), UW.SPL(B, P, [v0, U32.or(0, v1)]), UW.SPL(B, P, [v0, v1]),
          Equal.cong(U32, +List<U32>, z => UW.SPL(B, P, [z, U32.or(0, v1)]), U32.or(0, v0), v0, VBE.zero_or(v0)),
          Equal.cong(U32, +List<U32>, z => UW.SPL(B, P, [v0, z]), U32.or(0, v1), v1, VBE.zero_or(v1))))
@@ BV1281 @@

# ---- T.bv1281_putk (Bitvector[1281], 161 bytes held as O.Words) at X = 4 q + r ------------------------
# The validity check (161 bytes, storage room, zero tails), then O.put_words of the 161 bytes (vuwd.putw_any).

def PX_bv1281(+r: Nat, +dd: Nat, +D: ${TR}, +q: Nat, +TB: ${TR}) -> ${TR}: UWD.PWM(r, dd, D, q, TB, 161)

def bv1281x_perfect(+r: Nat, +dd: Nat, +D: ${TR}, +q: Nat, +TB: ${TR}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PX_bv1281(r, dd, D, q, TB)) == ${TRUE}}:
  UWD.pwm_perfect(r, dd, D, q, TB, 161, pf)

def hrm(+dB: Nat, +hdB: {Nat.is_lt(dB, 28n) == ${TRUE}}, +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == ${TRUE}})
    -> {Nat.is_le(Nat.add(VC.NW(161), 0n), VB.pw(dB)) == ${TRUE}}:
  UW2.hsx(dB, 0, 0n, 161, {==}, hdB, hrB)

def valid(+dB: Nat, +TB: ${TR}, +pfB: {FD.array__perfect(U32, dB, TB) == ${TRUE}}, +hdB: {Nat.is_lt(dB, 28n) == ${TRUE}},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == ${TRUE}}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == ${TRUE}},
    +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == ${TRUE}})
    -> {T.bv1281_valid(O.Words{FD.array__thaw(U32, TB), 161}) == (O.Words{FD.array__thaw(U32, TB), 161}, True{}) : O.Words & Bool}:
  %Equal.sym(O.Words & Bool, O.words_ok(O.Words{FD.array__thaw(U32, TB), 161}, 161, 161, False{}, 1), (O.Words{FD.array__thaw(U32, TB), 161}, True{}),
      VBE.words_ok_b(dB, TB, 161, 161, 161, VLS.KK(dB), pfB, FD.nat__lt_trans(dB, 28n, 31n, hdB, {==}), VLS.kk_lt(dB, hdB), VLS.hyn(dB, 161, hrB), {==}, {==},
        hrm(dB, hdB, hrB), htz, 1, {==})) :
    {O.bitvec_tail(1281, _) == (O.Words{FD.array__thaw(U32, TB), 161}, True{}) : O.Words & Bool}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TB), U32.shrn(1281, 5n)), (FD.array__thaw(U32, TB), RD.wd(TB, dB, U32.shrn(1281, 5n))),
      VE.get_any(dB, TB, U32.shrn(1281, 5n), FD.nat__lt_trans(dB, 28n, 32n, hdB, {==}), pfB)) :
    {O.bv_fin(161, True{}, 1281, _) == (O.Words{FD.array__thaw(U32, TB), 161}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))), True{}, hbz) :
    {(O.Words{FD.array__thaw(U32, TB), 161}, Bool.and(True{}, _)) == (O.Words{FD.array__thaw(U32, TB), 161}, True{}) : O.Words & Bool}
  {==}

def bv1281_any(+dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: ${TR}, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 161n))), VB.pw(dd)) == ${TRUE}},
    +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +pfB: {FD.array__perfect(U32, dB, TB) == ${TRUE}}, +hdB: {Nat.is_lt(dB, 28n) == ${TRUE}},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == ${TRUE}}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == ${TRUE}},
    +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == ${TRUE}},
    +hz: {VS.bt(Nat.add(161n, UWD.PADB(r, 161n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(161n, UWD.PADB(r, 161n))) : +List<U32>})
    -> {T.bv1281_putk(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, TB), 161}) == (FD.array__thaw(U32, PX_bv1281(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}:
  %Equal.sym(O.Words & Bool, T.bv1281_valid(O.Words{FD.array__thaw(U32, TB), 161}), (O.Words{FD.array__thaw(U32, TB), 161}, True{}), valid(dB, TB, pfB, hdB, hrB, htz, hbz)) :
    {T.bv1281_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PX_bv1281(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, TB), 161}), (FD.array__thaw(U32, PX_bv1281(r, dd, D, q, TB)), O.Words{FD.array__thaw(U32, TB), 161}),
      UWD.putw_any(dd, D, X, q, r, dB, TB, 161, VLS.KK(dB), e, hr, hd, FD.nat__lt_trans(dB, 28n, 31n, hdB, {==}), VLS.kk_lt(dB, hdB), VLS.hyn(dB, 161, hrB),
        FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dB)) == ${TRUE}}, Nat.add(VC.NW(161), 0n), VC.NW(161), FD.nat__add_zero(VC.NW(161)), hrm(dB, hdB, hrB)), hl, pf, pfB, htz, hz)) :
    {T.bv1281_pk_ok(_) == (FD.array__thaw(U32, PX_bv1281(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}
  {==}

# Its bytes: the 161 bytes, then zeros to the end of the last word written (vuwd.putw_any_bytes).
def bv1281_any_bytes(+dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: ${TR}, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 161n))), VB.pw(dd)) == ${TRUE}},
    +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +pfB: {FD.array__perfect(U32, dB, TB) == ${TRUE}}, +hdB: {Nat.is_lt(dB, 28n) == ${TRUE}},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == ${TRUE}}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == ${TRUE}},
    +hz: {VS.bt(Nat.add(161n, UWD.PADB(r, 161n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(161n, UWD.PADB(r, 161n))) : +List<U32>})
    -> {UA.BYT(PX_bv1281(r, dd, D, q, TB)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(161n, FX.limbs(UW.SLW(TB))), UW.ZB(UWD.PADB(r, 161n)))) : +List<U32>}:
  UWD.putw_any_bytes(dd, D, X, q, r, dB, TB, 161, VLS.KK(dB), e, hr, hd, FD.nat__lt_trans(dB, 28n, 31n, hdB, {==}), VLS.kk_lt(dB, hdB), VLS.hyn(dB, 161, hrB),
    FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dB)) == ${TRUE}}, Nat.add(VC.NW(161), 0n), VC.NW(161), FD.nat__add_zero(VC.NW(161)), hrm(dB, hdB, hrB)), hl, pf, pfB, htz, hz)
