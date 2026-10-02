@@ ACCEPT @@

def chk_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def chk_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def chk_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{}: h

def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32,
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +hchk: {CHK(t, n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +epo: {SPO(t) == @FS : U32}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {@Tn_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : @D}:
  +hs0 = hs(d, n, hd, ha, hn, hc)
  +hd31 = hd
  +hz = hdzK(d, n, hd, ha, hn, hc)
  +ez = zeros_at(B.words_depth_u(VC.WZ(LL(n))), DZ(n), VD.wdu(VC.WZ(LL(n))), FD.nat__le_trans(DZ(n), @Kn, @KKn, hz, {==}))
  %Equal.sym(B.Buf & Bool, @Tn_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, VB.lt32(d, hd31), hk(@pon, d, n, {==}, hs0), pf)) :
    {@Tn_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : @D}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {@Tn_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : @D}
  %Equal.sym(B.Buf & @Tn, @Tn_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)),
      rd_ok(d, t, n, DZ(n), pf, hd, FD.nat__le_lt_trans(DZ(n), @Kn, 31n, hz, {==}), hs0, epo, ez, VC.and3_x8(LL(n), CQ(n), eLc(n, hc)), hr(d, n, hd, ha, hn, hc))) :
    {@Tn_some(_) == (BF(t, n), Some{OBJ(t, n)}) : @D}
  {==}

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {@Tn_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : @D}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(@FS, n)
  +b = U32.is_eq(SPO(t), @FS)
  +c = whole(U32.sub(n, SPO(t)))
  +epo = FD.u32alg__eq_of(SPO(t), @FS, chk_b(a, b, c, hchk))
  acc_go(d, t, n, pf, hd, hn, hchk, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {whole(U32.sub(n, z)) == True{} : Bool}, SPO(t), @FS, epo, chk_c(a, b, c, hchk)))

@@ REJ @@
# ---- the buffer's bytes ------------------------------------------------------------------

law wdr0_eq:
  for +n: Nat
  for +W: List<&2, U32>
  {VS.wdr0(n, W) == VB.wdr(n, W) : List<&2, U32>}
def wdr0_eq(n, W):
  match n W:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: wdr0_eq(p, t)

law len_eq:
  for +W: List<&2, U32>
  {List.length(&2, U32, W) == F.spec_common__length(U32, W) : Nat}
def len_eq(W):
  match W:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), F.spec_common__length(U32, t), len_eq(t)) : {1n+_ == 1n+F.spec_common__length(U32, t) : Nat}
      {==}

def SL(t: F.array__Tree<U32>) -> List<&2, U32>: F.array__slots(U32, t)

def lenS(+d: Nat, +t: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, FX.limbs(SL(t))) == A.quad(VB.pw(d)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), FX.wlen(SL(t)), VS.len_limbs(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, FX.wlen(SL(t)), A.quad(List.length(&2, U32, SL(t))), VS.wlen_quad(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, SL(t)), VB.pw(d), Equal.trans(Nat, List.length(&2, U32, SL(t)), F.spec_common__length(U32, SL(t)), VB.pw(d), len_eq(SL(t)), F.array__slots_length(U32, d, t, pf))) : {A.quad(_) == A.quad(VB.pw(d)) : Nat}
  {==}

def lenVW(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, DC.VW(t, n)) == U32.to_nat(n) : Nat}:
  VS.bt_len(U32.to_nat(n), FX.limbs(SL(t)),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(n), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, FX.limbs(SL(t))), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), A.quad(VB.pw(d)), lenS(d, t, pf)), hn))

# The offset word's index is below 2^d.
def hpoD(+d: Nat, +n: U32, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hF: {Nat.is_le(@FSn, U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_lt(@POn, VB.pw(d)) == True{} : Bool}:
  F.nat__lt_le_trans(@POn, @Hn, VB.pw(d), {==}, VC.quad_inv(@Hn, VB.pw(d), F.nat__le_trans(@FSn, U32.to_nat(n), A.quad(VB.pw(d)), hF, hn)))

def hpoS(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hF: {Nat.is_le(@FSn, U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_lt(@POn, VB.len(SL(t))) == True{} : Bool}:
  %Equal.sym(Nat, VB.len(SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)) : {Nat.is_lt(@POn, _) == True{} : Bool}
  hpoD(d, n, hn, hF)

# The four bytes at the offset field are the limbs of the offset word.
def byteP(+t: F.array__Tree<U32>, +n: U32, +X: Nat, +en: {U32.to_nat(n) == @FSn+X : Nat}, +hp: {Nat.is_lt(@POn, VB.len(SL(t))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))) == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(n), @FSn+X, en) : {VS.bt(4n, VS.bdr(@Pn, VS.bt(_, FX.limbs(SL(t))))) == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@Pn, VS.bt(@FSn+X, FX.limbs(SL(t)))), VS.bt(@Rn+X, VS.bdr(@Pn, FX.limbs(SL(t)))), VS.bdr_bt(@Pn, @Rn+X, FX.limbs(SL(t)))) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(@Rn+X, VS.bdr(@Pn, FX.limbs(SL(t))))), VS.bt(4n, VS.bdr(@Pn, FX.limbs(SL(t)))), VS.bt_bt(4n, @R4n+X, VS.bdr(@Pn, FX.limbs(SL(t))))) :
    {_ == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@Pn, FX.limbs(SL(t))), FX.limbs(VS.wdr0(@POn, SL(t))), VS.bdr_limbs(@POn, SL(t))) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, FX.limbs(VS.wdr0(@POn, SL(t)))), FX.limbs(VS.wtake(1n, VS.wdr0(@POn, SL(t)))), VS.bt_limbs(1n, VS.wdr0(@POn, SL(t)))) :
    {_ == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(@POn, SL(t)), VB.wdr(@POn, SL(t)), wdr0_eq(@POn, SL(t))) :
    {FX.limbs(VS.wtake(1n, _)) == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n, VB.wdr(@POn, SL(t))), Con{F.flat__nthc(SL(t), @POn), VS.wtake(0n, VB.wdr(1n+@POn, SL(t)))}, VB.wt_eta(0n, @POn, SL(t), hp)) :
    {FX.limbs(_) == FX.limbs([VB.slot(t, @POn)]) : +List<U32>}
  {==}

def q0(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: h
    case Nil{}: 0
def q1(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q0(t)
    case Nil{}: 0
def q2(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q1(t)
    case Nil{}: 0
def q3(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q2(t)
    case Nil{}: 0

# A word whose limbs are those of @FS is @FS.
def wordFS(+x: U32, +h: {FX.limbs([x]) == @FSL : +List<U32>}) -> {x == @FS : U32}:
  Equal.trans(U32, x, BT.asm(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x)), @FS, BT.reassemble(x),
    BT.asm_cong(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x), @B0, @B1, @B2, @B3,
      Equal.cong(+List<U32>, U32, l => q0(l), FX.limbs([x]), @FSL, h),
      Equal.cong(+List<U32>, U32, l => q1(l), FX.limbs([x]), @FSL, h),
      Equal.cong(+List<U32>, U32, l => q2(l), FX.limbs([x]), @FSL, h),
      Equal.cong(+List<U32>, U32, l => q3(l), FX.limbs([x]), @FSL, h)))

def ec_sub(+n: U32, +k: Nat, +en: {U32.to_nat(n) == @FSn+VS.x8(k) : Nat})
    -> {U32.to_nat(DC.LL(n)) == Nat.mul(k, U32.to_nat(8)) : Nat}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+VS.x8(k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), @FSn+VS.x8(k), en), Order.below_sum(@FSn, VS.x8(k)))
  %Equal.sym(Nat, U32.to_nat(DC.LL(n)), Nat.sub(U32.to_nat(n), @FSn), F.u32__sub_nat(n, @FS, le)) : {_ == Nat.mul(k, U32.to_nat(8)) : Nat}
  %Equal.sym(Nat, U32.to_nat(n), @FSn+VS.x8(k), en) : {Nat.sub(_, @FSn) == Nat.mul(k, U32.to_nat(8)) : Nat}
  %VC.x8_mul(k) : {Nat.sub(@FSn+_, @FSn) == Nat.mul(k, U32.to_nat(8)) : Nat}
  F.nat__add_sub_cancel(@FSn, Nat.mul(k, 8n))

# The validator accepts every buffer whose bytes have the shape.
def chk_true(+t: F.array__Tree<U32>, +n: U32, +k: Nat, +en: {U32.to_nat(n) == @FSn+VS.x8(k) : Nat}, +hk: {Nat.is_le(k, @LIMN) == True{} : Bool},
    +epo: {DC.SPO(t) == @FS : U32}) -> {DC.CHK(t, n) == True{} : Bool}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+VS.x8(k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), @FSn+VS.x8(k), en), Order.below_sum(@FSn, VS.x8(k)))
  %Equal.sym(Bool, U32.is_le(@FS, n), True{}, F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(@FSn, U32.to_nat(n)), U32.is_le(@FS, n), Equal.sym(Bool, U32.is_le(@FS, n), Nat.is_le(@FSn, U32.to_nat(n)), VU.le_u32(@FS, n)), le)) :
    {DC.chk3(_, U32.is_eq(DC.SPO(t), @FS), DC.whole(U32.sub(n, DC.SPO(t)))) == True{} : Bool}
  %Equal.sym(U32, DC.SPO(t), @FS, epo) :
    {DC.chk3(True{}, U32.is_eq(_, @FS), DC.whole(U32.sub(n, _))) == True{} : Bool}
  VU.whole_i(DC.LL(n), 8, @LIM, DC.v8(), {==}, {==}, {==}, k, ec_sub(n, k, en), hk)

def rej_k(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))) == @FSL : +List<U32>},
    ex: DK.Ex(Nat, k => DK.P2({List.length(&2, U32, DC.VW(t, n)) == Nat.add(@FSn, VS.x8(k)) : Nat}, {Nat.is_le(k, @LIMN) == True{} : Bool}))) -> Empty:
  (+k, +pr) = ex
  (+hlen, +hk) = pr
  +en = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), @FSn+VS.x8(k), Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), lenVW(d, t, n, pf, hn)), hlen)
  +hF = F.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+VS.x8(k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), @FSn+VS.x8(k), en), Order.below_sum(@FSn, VS.x8(k)))
  +hp = hpoS(d, t, n, pf, hn, hF)
  +epo = wordFS(DC.SPO(t), Equal.trans(+List<U32>, FX.limbs([DC.SPO(t)]), VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), FX.limbs([DC.SPO(t)]), byteP(t, n, VS.x8(k), en, hp)), hb))
  F.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, chk_true(t, n, k, en, hk, epo)), hchk))

def rej_f(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    facts: FACTS(DC.VW(t, n))) -> Empty:
  (+hb, ex) = facts
  rej_k(d, t, n, pf, hn, hchk, hb, ex)

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.@n(), DC.VW(t, n))
def decode_reject(d, t, n, pf, hn, hchk):
  v => e => rej_f(d, t, n, pf, hn, hchk, inv_v(v, DC.VW(t, n), e))

def none_go(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +a: Bool, +ea: {U32.is_le(@FS, n) == a : Bool})
    -> {@Tn_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_le(@FS, n), False{}, ea) :
        {@Tn_built(n, @Tn_ok_len(_, DC.BF(t, n), 0, n)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
      {==}
    case True{}:
      +hF = F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, n), Nat.is_le(@FSn, U32.to_nat(n)), VU.le_u32(@FS, n), ea)
      %Equal.sym(B.Buf & Bool, @Tn_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), DC.CHK(t, n)), DC.ok_eval(d, t, n, VB.lt32(d, hd), hpoD(d, n, hn, hF), pf)) :
        {@Tn_built(n, _) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
      %Equal.sym(Bool, DC.CHK(t, n), False{}, hchk) :
        {@Tn_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
      {==}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  {@Tn_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  none_go(d, t, n, pf, hd, hn, hchk, U32.is_le(@FS, n), {==})

@@ unique_text @@
import Base
import ../../types/schema.bend as S
import ../../spec/decoding_relation.bend as Decoding
import ../../spec/fulu_schemas.bend as Spec
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./${D} as DC
import ../../proofs/decode_unique.bend as DCO

# GENERATED by var_laws (codegen). Do not edit.
# Every spec value of an accepted buffer's bytes is the decoded object's value.
law decode_unique:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, ${db}n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == True{} : Bool}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.${n}(), DC.VW(t, n), v)
  {v == DC.VAL(t, n) : S.Value}
def decode_unique(d, t, n, pf, hd, hn, hchk, v, spec):
  DCO.valid_unique(Spec.${n}(), DC.VW(t, n), v, DC.VAL(t, n), {==}, spec,
    DC.decode_spec(d, t, n, pf, hd, hn, hchk))

@@ dec_module @@
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{FD.array__thaw(U32, t), n}

def rd32(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(BF(t, n), q) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, t), q), (FD.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, q, i, eq, hd, hi, pf)) :
    {B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  {==}

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def whole(+L: U32) -> Bool: Bool.and(U32.is_eq(L, (U32.div(L, 8) * 8 : U32)), U32.is_le(U32.div(L, 8), ${LIM}))

def SPO(t: FD.array__Tree<U32>) -> U32: VB.slot(t, ${po}n)

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {${Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def ok_c0(+t: FD.array__Tree<U32>, +n: U32, +b: Bool)
    -> {${Tn}_c0(b, BF(t, n), 0, n, SPO(t)) == (BF(t, n), chk3(True{}, b, whole(U32.sub(n, SPO(t))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: c1_id(whole(U32.sub(n, SPO(t))), BF(t, n), 0, n, SPO(t))

def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chk3(U32.is_le(${FS}, n), U32.is_eq(SPO(t), ${FS}), whole(U32.sub(n, SPO(t))))

def ok_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +a: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(${po}n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {${Tn}_ok_len(a, BF(t, n), 0, n) == (BF(t, n), chk3(a, U32.is_eq(SPO(t), ${FS}), whole(U32.sub(n, SPO(t))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), ${po}), (BF(t, n), SPO(t)), rd32(d, t, n, ${po}, ${po}n, {==}, hd, hpo, pf)) :
        {${Tn}_v0(0, n, _) == (BF(t, n), chk3(True{}, U32.is_eq(SPO(t), ${FS}), whole(U32.sub(n, SPO(t))))) : B.Buf & Bool}
      ok_c0(t, n, U32.is_eq(SPO(t), ${FS}))

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(${po}n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {${Tn}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  ok_len(d, t, n, U32.is_le(${FS}, n), hd, hpo, pf)

@@ dec_module_2 @@

def v8() -> Word(31n): FD.spec_numeric__from_nat(31n, 8n)
def LL(+n: U32) -> U32: U32.sub(n, ${FS})
def CQ(+n: U32) -> Nat: U32.to_nat(U32.div(LL(n), 8))
def DZ(+n: U32) -> Nat: B.words_depth(VC.WZ(LL(n)))
def MM(+t: FD.array__Tree<U32>, +n: U32) -> FD.array__Tree<U32>: VB.mone(VC.NW(LL(n)), ${H}n, 0n, DZ(n), VC.ZT(DZ(n)), t)

def leFS(+n: U32, +ha: {U32.is_le(${FS}, n) == True{} : Bool}) -> {Nat.is_le(${FS}n, U32.to_nat(n)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(${FS}, n), Nat.is_le(${FS}n, U32.to_nat(n)), VU.le_u32(${FS}, n), ha)

def enFS(+n: U32, +ha: {U32.is_le(${FS}, n) == True{} : Bool}) -> {Nat.add(${FS}n, U32.to_nat(LL(n))) == U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(LL(n)), Nat.sub(U32.to_nat(n), ${FS}n), FD.u32__sub_nat(n, ${FS}, leFS(n, ha))) : {Nat.add(${FS}n, _) == U32.to_nat(n) : Nat}
  FD.nat__sub_add(U32.to_nat(n), ${FS}n, leFS(n, ha))

def eLc(+n: U32, +hc: {whole(LL(n)) == True{} : Bool}) -> {U32.to_nat(LL(n)) == VS.x8(CQ(n)) : Nat}:
  %VC.x8_mul(CQ(n)) : {U32.to_nat(LL(n)) == _ : Nat}
  Pair.fst({U32.to_nat(LL(n)) == Nat.mul(CQ(n), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(n), U32.to_nat(${LIM})) == True{} : Bool},
    VU.whole_t(LL(n), 8, ${LIM}, v8(), {==}, {==}, {==}, hc))

def hcL(+n: U32, +hc: {whole(LL(n)) == True{} : Bool}) -> {Nat.is_le(CQ(n), U32.to_nat(${LIM})) == True{} : Bool}:
  Pair.snd({U32.to_nat(LL(n)) == Nat.mul(CQ(n), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(n), U32.to_nat(${LIM})) == True{} : Bool},
    VU.whole_t(LL(n), 8, ${LIM}, v8(), {==}, {==}, {==}, hc))

# 31 + L <= 2^KL: the list's bytes are bounded by its limit (whatever the buffer's depth).
def hy(+n: U32, +hc: {whole(LL(n)) == True{} : Bool})
    -> {Nat.is_le(VC.YL(LL(n)), VB.pw(${KL}n)) == True{} : Bool}:
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(U32.to_nat(${LIM}))) == True{} : Bool}, VS.x8(CQ(n)), U32.to_nat(LL(n)), Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)),
    VS.x8_mono(CQ(n), U32.to_nat(${LIM}), hcL(n, hc)))
  FD.nat__le_trans(VC.YL(LL(n)), Nat.add(31n, VS.x8(U32.to_nat(${LIM}))), VB.pw(${KL}n),
    Order.add_left(31n, U32.to_nat(LL(n)), VS.x8(U32.to_nat(${LIM})), hx), ${K_HY})

def eNWc(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {VC.NW(LL(n)) == Nat.double(CQ(n)) : Nat}:
  %Equal.sym(Nat, VC.NW(LL(n)), VD.s_rng(2n, 3n+U32.to_nat(LL(n))), VC.eNW(LL(n), ${KL}n, {==}, hy(n, hc))) : {_ == Nat.double(CQ(n)) : Nat}
  %Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)) : {VD.s_rng(2n, 3n+_) == Nat.double(CQ(n)) : Nat}
  VC.rng2_x8(CQ(n))

# H + 2c <= 2^d: the header and the list's words lie in the buffer.
def hs(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(LL(n)), ${H}n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(LL(n)), Nat.double(CQ(n)), eNWc(d, n, hd, ha, hn, hc)) : {Nat.is_le(Nat.add(_, ${H}n), VB.pw(d)) == True{} : Bool}
  %FD.nat__add_comm(${H}n, Nat.double(CQ(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  VC.quad_inv(${H}n+Nat.double(CQ(n)), VB.pw(d),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), ${FS}n+VB.d3(CQ(n)),
      Equal.trans(Nat, U32.to_nat(n), Nat.add(${FS}n, U32.to_nat(LL(n))), ${FS}n+VB.d3(CQ(n)), Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha)),
        Equal.cong(Nat, Nat, z => Nat.add(${FS}n, z), U32.to_nat(LL(n)), VB.d3(CQ(n)), Equal.trans(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), VB.d3(CQ(n)), eLc(n, hc), VB.x8_d3(CQ(n))))),
      hn))

def hWZ(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(LL(n))), O.pow2n(${K}n)) == True{} : Bool}:
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(U32.to_nat(${LIM}))) == True{} : Bool}, VS.x8(CQ(n)), U32.to_nat(LL(n)), Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)),
    VS.x8_mono(CQ(n), U32.to_nat(${LIM}), hcL(n, hc)))
  FD.nat__le_trans(U32.to_nat(VC.WZ(LL(n))), Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), O.pow2n(${K}n),
    VC.wz_le(LL(n), ${KL}n, {==}, hy(n, hc)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(${LIM})))), 8n), O.pow2n(${K}n),
      Order.add_right(VD.s_rng(2n, VC.YL(LL(n))), VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(${LIM})))), 8n, VC.rng_mono(2n, VC.YL(LL(n)), Nat.add(31n, VS.x8(U32.to_nat(${LIM}))), Order.add_left(31n, U32.to_nat(LL(n)), VS.x8(U32.to_nat(${LIM})), hx))),
      ${K_WZ}))

def hdzK(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {Nat.is_le(DZ(n), ${K}n) == True{} : Bool}:
  VD.wd_min(VC.WZ(LL(n)), ${K}n, hWZ(d, n, hd, ha, hn, hc))

def hr(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(LL(n)), 0n), VB.pw(DZ(n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(LL(n)), 0n), VC.NW(LL(n)), FD.nat__add_zero(VC.NW(LL(n)))) : {Nat.is_le(_, VB.pw(DZ(n))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(DZ(n)), O.pow2n(DZ(n)), VD.s_pow2_eq(DZ(n))) : {Nat.is_le(VC.NW(LL(n)), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(LL(n)), U32.to_nat(VC.WZ(LL(n))), O.pow2n(DZ(n)),
    VC.nw_le_wz(LL(n), ${KL}n, {==}, hy(n, hc)),
    VD.wd_cover(VC.WZ(LL(n)), ${K}n, {==}, hWZ(d, n, hd, ha, hn, hc)))

# k < 2^d for every header word k < H.
def hk(+k: Nat, +d: Nat, +n: U32, +hkH: {Nat.is_lt(k, ${H}n) == True{} : Bool}, +h: {Nat.is_le(Nat.add(VC.NW(LL(n)), ${H}n), VB.pw(d)) == True{} : Bool})
    -> {Nat.is_lt(k, VB.pw(d)) == True{} : Bool}:
  FD.nat__lt_le_trans(k, ${H}n, VB.pw(d), hkH, FD.nat__le_trans(${H}n, Nat.add(VC.NW(LL(n)), ${H}n), VB.pw(d), Order.left_below_sum(VC.NW(LL(n)), ${H}n), h))

@@ dec_spec @@

# ---- the spec side -------------------------------------------------------------------------

def XV(+t: FD.array__Tree<U32>, +k: Nat, +W: List<&2, U32>) -> S.Value: S.Sequence{${ITEMS}}

# The spec encoding of the value of header words t and list words W (k elements).
def enc_spec(+t: FD.array__Tree<U32>, +k: Nat, +W: List<&2, U32>,
    +hk: {Nat.is_le(k, ${LIMN}) == True{} : Bool},
    +hl: {Nat.is_le(Nat.double(k), FD.spec_common__length(U32, W)) == True{} : Bool})
    -> {Codec.encoding_for_legal_type(Spec.${x.n}(), XV(t, k, W)) == ${RHS} : ${M}}:
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(${LIMN})) == True{} : Bool}, VS.x8(k), List.length(&2, U32, F.limbs(${YS})),
    Equal.sym(Nat, List.length(&2, U32, F.limbs(${YS})), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)), VS.x8_mono(k, ${LIMN}, hk))
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, F.limbs(${YS}))), Nat.add(${FS}n, VS.x8(${LIMN})),
    Order.add_left(${FS}n, List.length(&2, U32, F.limbs(${YS})), VS.x8(${LIMN}), le2), ${K_FIT})
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.bytes(Codec.aggregate(_, None{})) == ${RHS} : ${M}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, F.limbs(${YS}), ${POST})), Some{${ENCR}}, VS.enc_fpv(${PRE}, ${YS}, ${POST}, fit)) :
    {Codec.bytes(Codec.one(_, None{})) == ${RHS} : ${M}}
  {==}

def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(${s}))
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: XV(t, CQ(n), FD.array__slots(U32, MM(t, n)))

def en_q(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +ha: {U32.is_le(${FS}, n) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {A.quad(${H}n+${NW}) == U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, ${NW}, Nat.double(CQ(n)), eNWc(d, n, hd, ha, hn, hc)) : {A.quad(${H}n+_) == U32.to_nat(n) : Nat}
  %enFS(n, ha) : {A.quad(${H}n+Nat.double(CQ(n))) == _ : Nat}
  %Equal.sym(Nat, U32.to_nat(LL(n)), VS.x8(CQ(n)), eLc(n, hc)) : {A.quad(${H}n+Nat.double(CQ(n))) == Nat.add(${FS}n, _) : Nat}
  %Equal.sym(Nat, VS.x8(CQ(n)), VB.d3(CQ(n)), VB.x8_d3(CQ(n))) : {A.quad(${H}n+Nat.double(CQ(n))) == Nat.add(${FS}n, _) : Nat}
  {==}

def len_z(+n: U32) -> {VB.len(FD.array__slots(U32, VC.ZT(DZ(n)))) == VB.pw(DZ(n)) : Nat}:
  FD.array__slots_length(U32, DZ(n), VC.ZT(DZ(n)), FD.array__trep_perfect(U32, DZ(n), 0))

# The buffer's bytes are the limbs of the header words and the list's words.
def lim_eq(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool}, +epo: {SPO(t) == ${FS} : U32},
    +hc: {whole(LL(n)) == True{} : Bool})
    -> {F.limbs(${HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == VW(t, n) : +List<U32>}:
  +hs0 = hs(d, n, hd, ha, hn, hc)
  +hr0 = hr(d, n, hd, ha, hn, hc)
  +hsl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${NW}, ${H}n), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hs0)
  +hpre = FD.nat__le_trans(${H}n, Nat.add(${NW}, ${H}n), VB.len(${s}), Order.left_below_sum(${NW}, ${H}n), hsl)
  %en_q(d, n, hd, hn, ha, hc) : {F.limbs(${HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == VS.bt(_, F.limbs(${s})) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(${H}n+${NW}), F.limbs(${s})), F.limbs(VS.wtake(${H}n+${NW}, ${s})), VS.bt_limbs(${H}n+${NW}, ${s})) :
    {F.limbs(${HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(${H}n, ${NW}), VB.wdr(0n, ${s})), VF.app(VF.wpre(${H}n, 0n, ${s}), VS.wtake(${NW}, VB.wdr(Nat.add(${H}n, 0n), ${s}))), VF.wt_pre(${H}n, ${NW}, 0n, ${s}, hpre)) :
    {F.limbs(${HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == F.limbs(_) : +List<U32>}
  %epo : {F.limbs(${hdrh} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))) == ${RW} : +List<U32>}
  %Equal.sym(List<&2, U32>, FD.array__slots(U32, MM(t, n)), ${LM},
      VB.slots_mone(${NW}, ${H}n, 0n, DZ(n), VC.ZT(DZ(n)), t, FD.array__trep_perfect(U32, DZ(n), 0), hr0)) :
    {F.limbs(${hdrs} <> VS.wtake(Nat.double(CQ(n)), _)) == ${RW} : +List<U32>}
  %eNWc(d, n, hd, ha, hn, hc) : {F.limbs(${hdrs} <> VS.wtake(_, ${LM})) == ${RW} : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(${NW}, VB.wdr(0n, ${LM})), VS.wtake(${NW}, VB.wdr(${H}n, ${s})),
      VB.lm_win(${NW}, ${H}n, 0n, FD.array__slots(U32, VC.ZT(DZ(n))), ${s},
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${NW}, 0n), z) == True{} : Bool}, VB.pw(DZ(n)), VB.len(FD.array__slots(U32, VC.ZT(DZ(n)))), Equal.sym(Nat, VB.len(FD.array__slots(U32, VC.ZT(DZ(n)))), VB.pw(DZ(n)), len_z(n)), hr0),
        hsl)) :
    {F.limbs(${hdrs} <> _) == ${RW} : +List<U32>}
  {==}

def hl_mm(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +ha: {U32.is_le(${FS}, n) == True{} : Bool}, +hc: {whole(LL(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.double(CQ(n)), FD.spec_common__length(U32, FD.array__slots(U32, MM(t, n)))) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, FD.array__slots(U32, MM(t, n))), VB.pw(DZ(n)),
      FD.array__slots_length(U32, DZ(n), MM(t, n), VB.mone_perfect(${NW}, ${H}n, 0n, DZ(n), VC.ZT(DZ(n)), t, FD.array__trep_perfect(U32, DZ(n), 0)))) :
    {Nat.is_le(Nat.double(CQ(n)), _) == True{} : Bool}
  %eNWc(d, n, hd, ha, hn, hc) : {Nat.is_le(_, VB.pw(DZ(n))) == True{} : Bool}
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(DZ(n))) == True{} : Bool}, Nat.add(${NW}, 0n), ${NW}, FD.nat__add_zero(${NW}), hr(d, n, hd, ha, hn, hc))

def spec_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +ha: {U32.is_le(${FS}, n) == True{} : Bool}, +epo: {SPO(t) == ${FS} : U32},
    +hc: {whole(LL(n)) == True{} : Bool})
    -> Decoding.decodes(Spec.${x.n}(), VW(t, n), VAL(t, n)):
  Equal.trans(${M}, Codec.encoding_for_legal_type(Spec.${x.n}(), VAL(t, n)), Some{F.limbs(${HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n))))}, Some{VW(t, n)},
    enc_spec(t, CQ(n), FD.array__slots(U32, MM(t, n)), hcL(n, hc), hl_mm(d, t, n, hd, hn, ha, hc)),
    Equal.cong(+List<U32>, ${M}, z => Some{z}, F.limbs(${HDR} <> VS.wtake(Nat.double(CQ(n)), FD.array__slots(U32, MM(t, n)))), VW(t, n), lim_eq(d, t, n, pf, hd, hn, ha, epo, hc)))

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.${x.n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(${FS}, n)
  +b = U32.is_eq(SPO(t), ${FS})
  +c = whole(U32.sub(n, SPO(t)))
  +epo = FD.u32alg__eq_of(SPO(t), ${FS}, chk_b(a, b, c, hchk))
  spec_go(d, t, n, pf, hd, hn, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {whole(U32.sub(n, z)) == True{} : Bool}, SPO(t), ${FS}, epo, chk_c(a, b, c, hchk)))
