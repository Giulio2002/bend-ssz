@@ text @@
# The object's Data mirror.
type MB is Data:
  MB{dw: Nat, T: FD.array__Tree<U32>, K: U32, B: Nat, kb: Nat, KY: Nat}

def TH(m: MB) -> O.Bits:
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: O.Bits{FD.array__thaw(U32, T), K}

# A valid object: a perfect storage tree of depth < 28 with room for its bits, the widths of
# vuwb.pbx_any, zero past the bits (in their bytes' last word, above bit K in word K / 32)${', at most ' + str(NB) + ' bits' if NB else ''}.
def OKT(${ARGS}) -> Bool:
  ${R(0)}
def OK(m: MB) -> Bool:
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: OKT(${A_})

def ENC(m: MB) -> +List<U32>:
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}]))
def VAL(m: MB) -> S.Value:
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: S.BitsValue{CO.BITS(T, K)}
def SZ(m: MB) -> U32:
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: CO.NK(K)
def PUTX(m: MB, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat) -> FD.array__Tree<U32>:
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: VWB.PBX(r, dd, D, q, T, K)
def PADB(+r: Nat, m: MB) -> Nat: UWD.PADB(r, List.length(&2, U32, ENC(m)))

@@ text_pack_len @@
# ---- the bits' byte count ------------------------------------------------------------------

law pack_len:
  for +xs: +List<Bool>
  {List.length(&2, U32, Bp.pack(xs)) == Bp.byte_count(List.length(&2, Bool, xs)) : Nat}
def pack_len(xs):
  match xs:
    case Nil{}: {==}
@@ text_bcx @@
law bcx:
  for +a: Nat
  for +b: Nat
  for +hb: {Nat.is_le(b, 7n) == ${TRUE}}
  {Bp.byte_count(Nat.add(Nat.add(VS.x8(a), b), 1n)) == 1n+a : Nat}
def bcx(a, b, hb):
  match a:
    case 0n:
      match b:
${bc_cases}
        case 8n+ +p: Empty.absurd({Bp.byte_count(Nat.add(8n+p, 1n)) == 1n : Nat}, FD.logic__false_true(hb))
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, Bp.byte_count(Nat.add(Nat.add(VS.x8(p), b), 1n)), 1n+p, bcx(p, b, hb))

law len_app_b:
  for +xs: +List<Bool>
  for +ys: +List<Bool>
  {List.length(&2, Bool, List.append(&2, Bool, xs, ys)) == Nat.add(List.length(&2, Bool, xs), List.length(&2, Bool, ys)) : Nat}
def len_app_b(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+b, +t}: FD.nat__succ_cong(List.length(&2, Bool, List.append(&2, Bool, t, ys)), Nat.add(List.length(&2, Bool, t), List.length(&2, Bool, ys)), len_app_b(t, ys))

def hK(${ARGS}, +h: {OKT(${A_}) == ${TRUE}}) -> VBT.HK(K, kb):
  FD.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(B, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), B, 8n, ok_hN(${A_}, h)), ok_hNk(${A_}, h))

def hWq(${ARGS}, +h: {OKT(${A_}) == ${TRUE}}) -> {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(dw)) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), VB.pw(dw)) == ${TRUE}}, U32.to_nat(U32.shrn(K, 5n)), VBT.QK(K), CO.eq5(K, kb, B, ok_hkb(${A_}, h), ok_hN(${A_}, h), ok_hNk(${A_}, h)), ok_hcap(${A_}, h))

def hdw31(${ARGS}, +h: {OKT(${A_}) == ${TRUE}}) -> {Nat.is_lt(dw, 31n) == ${TRUE}}: ok_hdw(${A_}, h)

# The bits' count is K (vbitcore.enc_core's CR3, at the storage's own depth).
def lbits(${ARGS}, +h: {OKT(${A_}) == ${TRUE}}) -> {List.length(&2, Bool, CO.BITS(T, K)) == U32.to_nat(K) : Nat}:
  CO.cr3(dw, T, K, CO.enc_core2(dw, dw, T, K, kb, B, ok_pf(${A_}, h), hdw31(${A_}, h), hdw31(${A_}, h), ok_hkb(${A_}, h),
    ok_hN(${A_}, h), ok_hNk(${A_}, h), hWq(${A_}, h), hWq(${A_}, h), ok_hbz(${A_}, h)))

# |ENC| = K / 8 + 1.
def eL(${ARGS}, +h: {OKT(${A_}) == ${TRUE}}) -> {List.length(&2, U32, ENC(MB{${A_}})) == U32.to_nat(CO.NK(K)) : Nat}:
  +bs = List.append(&2, Bool, CO.BITS(T, K), [True{}])
  +e1 = Equal.trans(Nat, List.length(&2, Bool, bs), Nat.add(List.length(&2, Bool, CO.BITS(T, K)), 1n), Nat.add(U32.to_nat(K), 1n), len_app_b(CO.BITS(T, K), [True{}]),
    Equal.cong(Nat, Nat, z => Nat.add(z, 1n), List.length(&2, Bool, CO.BITS(T, K)), U32.to_nat(K), lbits(${A_}, h)))
  +M = Nat.add(Nat.add(VS.x8(VBT.AK(K)), VBT.BKk(K)), 1n)
  +e2 = Equal.trans(Nat, List.length(&2, Bool, bs), Nat.add(U32.to_nat(K), 1n), M, e1, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), U32.to_nat(K), Nat.add(VS.x8(VBT.AK(K)), VBT.BKk(K)), VBT.E1(K)))
  +e3 = Equal.trans(Nat, Bp.byte_count(List.length(&2, Bool, bs)), Bp.byte_count(M), 1n+VBT.AK(K), Equal.cong(Nat, Nat, z => Bp.byte_count(z), List.length(&2, Bool, bs), M, e2),
    bcx(VBT.AK(K), VBT.BKk(K), RD.and_le(K, 7)))
  Equal.trans(Nat, List.length(&2, U32, Bp.pack(bs)), Bp.byte_count(List.length(&2, Bool, bs)), U32.to_nat(CO.NK(K)), pack_len(bs),
    Equal.trans(Nat, Bp.byte_count(List.length(&2, Bool, bs)), 1n+VBT.AK(K), U32.to_nat(CO.NK(K)), e3,
      Equal.trans(Nat, 1n+VBT.AK(K), Nat.add(VBT.AK(K), 1n), U32.to_nat(CO.NK(K)), Equal.sym(Nat, Nat.add(VBT.AK(K), 1n), 1n+VBT.AK(K), FD.nat__add_comm(VBT.AK(K), 1n)),
        Equal.sym(Nat, U32.to_nat(CO.NK(K)), Nat.add(VBT.AK(K), 1n), VBT.E4(K, kb, ok_hkb(${A_}, h), hK(${A_}, h))))))

@@ text_valid @@
# ---- the runtime's check and size ---------------------------------------------------------------

def valid(${ARGS}, +h: {OKT(${A_}) == ${TRUE}})
    -> {T.${p}_valid(O.Bits{FD.array__thaw(U32, T), K}) == (O.Bits{FD.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}:
  +hd31 = hdw31(${A_}, h)
${lim_rw}  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T)), (FD.array__thaw(U32, T), FD.u32__pow2u(dw)), FD.array__size_thaw(U32, dw, T, ok_pf(${A_}, h))) :
    {O.bk_cap(${after_or}, K, _) == (O.Bits{FD.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Bool, U32.is_le(U32.add(U32.shrn(K, 5n), 1), FD.u32__pow2u(dw)), True{}, CO.capT(K, dw, hd31, ok_hcap(${A_}, h))) :
    {O.bk_last(Bool.and(${after_or}, _), K, Array.get(U32, FD.array__thaw(U32, T), U32.shrn(K, 5n))) == (O.Bits{FD.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, T), U32.shrn(K, 5n)), (FD.array__thaw(U32, T), RD.wd(T, dw, U32.shrn(K, 5n))),
      VE.get_any(dw, T, U32.shrn(K, 5n), FD.nat__lt_trans(dw, 31n, 32n, ok_hdw(${A_}, h), {==}), ok_pf(${A_}, h))) :
    {O.bk_last(Bool.and(${after_or}, True{}), K, _) == (O.Bits{FD.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Bool, O.bits_above_zero(U32.and(K, 31), RD.wd(T, dw, U32.shrn(K, 5n))), True{}, ok_hbz2(${A_}, h)) :
    {(O.Bits{FD.array__thaw(U32, T), K}, Bool.and(Bool.and(${after_or}, True{}), _)) == (O.Bits{FD.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  {==}

def size_go(${ARGS}, +h: {OKT(${A_}) == ${TRUE}})
    -> {T.${p}_size(O.Bits{FD.array__thaw(U32, T), K}) == (O.Bits{FD.array__thaw(U32, T), K}, CO.NK(K)) : O.Bits & U32}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T)), (FD.array__thaw(U32, T), FD.u32__pow2u(dw)), FD.array__size_thaw(U32, dw, T, ok_pf(${A_}, h))) :
    {O.bsz_pick(K, _) == (O.Bits{FD.array__thaw(U32, T), K}, CO.NK(K)) : O.Bits & U32}
  %Equal.sym(Bool, U32.is_le(U32.add(U32.shrn(K, 5n), 1), FD.u32__pow2u(dw)), True{}, CO.capT(K, dw, hdw31(${A_}, h), ok_hcap(${A_}, h))) :
    {(O.Bits{FD.array__thaw(U32, T), K}, O.pick(_, U32.add(U32.shrn(K, 3n), 1), 2147483648)) == (O.Bits{FD.array__thaw(U32, T), K}, CO.NK(K)) : O.Bits & U32}
  {==}

@@ HYP @@
+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, U32.to_nat(CO.NK(K))))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(CO.NK(K)), UWD.PADB(r, U32.to_nat(CO.NK(K)))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(CO.NK(K)), UWD.PADB(r, U32.to_nat(CO.NK(K))))) : +List<U32>}
@@ text_putx_go @@
def putx_go(${ARGS}, ${HYP},
    +h: {OKT(${A_}) == ${TRUE}})
    -> {T.${p}_putk(FD.array__thaw(U32, D), X, O.Bits{FD.array__thaw(U32, T), K}) == (FD.array__thaw(U32, VWB.PBX(r, dd, D, q, T, K)), (O.Bits{FD.array__thaw(U32, T), K}, CO.NK(K))) : Array<U32> & (O.Bits & U32)}:
  %Equal.sym(O.Bits & Bool, T.${p}_valid(O.Bits{FD.array__thaw(U32, T), K}), (O.Bits{FD.array__thaw(U32, T), K}, True{}), valid(${A_}, h)) :
    {T.${p}_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, VWB.PBX(r, dd, D, q, T, K)), (O.Bits{FD.array__thaw(U32, T), K}, CO.NK(K))) : Array<U32> & (O.Bits & U32)}
  %Equal.sym(Array<U32> & O.Bits, O.put_bits(FD.array__thaw(U32, D), X, O.Bits{FD.array__thaw(U32, T), K}), (FD.array__thaw(U32, VWB.PBX(r, dd, D, q, T, K)), O.Bits{FD.array__thaw(U32, T), K}),
      VWB.pbx_any2(${PB})) :
    {O.pbn(_) == (FD.array__thaw(U32, VWB.PBX(r, dd, D, q, T, K)), (O.Bits{FD.array__thaw(U32, T), K}, CO.NK(K))) : Array<U32> & (O.Bits & U32)}
  {==}

def bytes_go(${ARGS}, ${HYP},
    +h: {OKT(${A_}) == ${TRUE}})
    -> {UA.BYT(VWB.PBX(r, dd, D, q, T, K)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}])), UW.ZB(UWD.PADB(r, U32.to_nat(CO.NK(K)))))) : +List<U32>}:
  VWB.pbx_any_bytes2(${PB})

@@ CONV @@
    case MB{+dw, +T, +K, +B, +kb, +KY}:
      +E = List.length(&2, U32, ENC(MB{${A_}}))
      +eE = eL(${A_}, hok)
      +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, E, U32.to_nat(CO.NK(K)), eE, hl)
      +hz2 = FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, UWD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, UWD.PADB(r, z))) : +List<U32>}, E, U32.to_nat(CO.NK(K)), eE, hz)
@@ text_putx_bytes @@
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
${CONV}
      %Equal.sym(Nat, E, U32.to_nat(CO.NK(K)), eE) : {UA.BYT(VWB.PBX(r, dd, D, q, T, K)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}])), UW.ZB(UWD.PADB(r, _)))) : +List<U32>}
      bytes_go(${A_}, dd, D, X, q, r, e, hr, hd, pf, hl2, hz2, hok)

law pfx:
  for +m: MB
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +q: Nat
  for +r: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}
  {FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == ${TRUE}}
def pfx(m, dd, D, q, r, pf):
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: VWB.pbx_perfect(r, dd, D, q, T, K, pf)

law szx:
  for +m: MB
  for +hok: {OK(m) == ${TRUE}}
  {U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}
def szx(m, hok):
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: Equal.sym(Nat, List.length(&2, U32, ENC(MB{${A_}})), U32.to_nat(CO.NK(K)), eL(${A_}, hok))

law sizex:
  for +m: MB
  for +hok: {OK(m) == ${TRUE}}
  {T.${p}_size(TH(m)) == (TH(m), SZ(m)) : O.Bits & U32}
def sizex(m, hok):
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: size_go(${A_}, hok)

law validx:
  for +m: MB
  for +hok: {OK(m) == ${TRUE}}
  {T.${p}_valid(TH(m)) == (TH(m), True{}) : O.Bits & Bool}
def validx(m, hok):
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: valid(${A_}, hok)

@@ text_encx_spec @@
law encx_spec:
  for +m: MB
  for +hok: {OK(m) == ${TRUE}}
  {Codec.parts(VAL(m), ${sch}) == Some{[S.Variable{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def encx_spec(m, hok):
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}:
      %Equal.sym(Bool, ${dom}, True{}, ${dproof}) :
        {Codec.one(Bits.encoding(_, List.append(&2, Bool, CO.BITS(T, K), [True{}])), None{}) == Some{[S.Variable{Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}]))}]} : Maybe<&2, +List<S.Part>>}
      {==}

@@ text_x8le @@
# ---- the bound: at most ${M8 + 1} bytes (K <= ${NB}) ----
def x8le(+a: Nat, +M: Nat, +h: {Nat.is_le(VS.x8(a), Nat.add(VS.x8(M), 7n)) == ${TRUE}}) -> {Nat.is_le(a, M) == ${TRUE}}:
  match a M:
    case 0n _: FD.nat__zero_le(M)
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == ${TRUE}}, FD.logic__false_true(h))
    case 1n+ +p 1n+ +c: x8le(p, c, h)
def maxg(${ARGS}, +h: {OKT(${A_}) == ${TRUE}}) -> {Nat.is_le(List.length(&2, U32, ENC(MB{${A_}})), ${M8 + 1}n) == ${TRUE}}:
  +hk = FD.logic__subst(Bool, z => {z == ${TRUE}}, U32.is_le(K, ${NB}), Nat.is_le(U32.to_nat(K), U32.to_nat(${NB})), VU.le_u32(K, ${NB}), ok_hlim(${A_}, h))
  +h8 = FD.nat__le_trans(VS.x8(VBT.AK(K)), Nat.add(VS.x8(VBT.AK(K)), VBT.BKk(K)), Nat.add(VS.x8(${M8}n), 7n), FD.nat__le_add_right(VS.x8(VBT.AK(K)), VBT.BKk(K)),
    FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(VS.x8(${M8}n), 7n)) == ${TRUE}}, U32.to_nat(K), Nat.add(VS.x8(VBT.AK(K)), VBT.BKk(K)), VBT.E1(K),
      FD.nat__le_trans(U32.to_nat(K), U32.to_nat(${NB}), Nat.add(VS.x8(${M8}n), 7n), hk, {==})))
  +hA = Order.add_right(VBT.AK(K), ${M8}n, 1n, x8le(VBT.AK(K), ${M8}n, h8))
  +eN = Equal.trans(Nat, List.length(&2, U32, ENC(MB{${A_}})), U32.to_nat(CO.NK(K)), Nat.add(VBT.AK(K), 1n), eL(${A_}, h), VBT.E4(K, kb, ok_hkb(${A_}, h), hK(${A_}, h)))
  FD.logic__subst(Nat, z => {Nat.is_le(z, ${M8 + 1}n) == ${TRUE}}, Nat.add(VBT.AK(K), 1n), List.length(&2, U32, ENC(MB{${A_}})), Equal.sym(Nat, List.length(&2, U32, ENC(MB{${A_}})), Nat.add(VBT.AK(K), 1n), eN), hA)

law maxx:
  for +m: MB
  for +hok: {OK(m) == ${TRUE}}
  {Nat.is_le(List.length(&2, U32, ENC(m)), ${M8 + 1}n) == ${TRUE}}
def maxx(m, hok):
  match m:
    case MB{+dw, +T, +K, +B, +kb, +KY}: maxg(${A_}, hok)
