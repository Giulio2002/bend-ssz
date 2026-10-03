@@ dec_text @@
def cL(+t: FD.array__Tree<U32>, +n: U32, +h: {chk1(True{}, t, n) == True{} : Bool}, +nz: {U32.is_eq(V(t, n), 0) == False{} : Bool})
    -> {@LT29 == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(True{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(V(t, n), 0), False{}, nz, h)

def c1(
@@ enc_text_lines @@
def OUT(+T: F.array__Tree<U32>, +K: U32) -> F.array__Tree<U32>: DL.OZ(${DO}, T, K)
def VAL(+T: F.array__Tree<U32>, +K: U32) -> S.Value: S.BitsValue{BO.bview(${OBJ})}
def BY(+T: F.array__Tree<U32>, +K: U32) -> +List<U32>: VS.bt(U32.to_nat(CO.NK(K)), FX.limbs(F.array__slots(U32, OUT(T, K))))

@@ enc_text_lines_2 @@
def cr(${PS}) -> CO.CR(${DO}, T, K):
  +hz = VR.rep_hz(dw, T, K, kb, N, pfT, hkb, hN, hNk, CO.qs_sized(dw, K, kb, N, hkb, hN, hNk, hcap), wf)
  CO.enc_sized2(dw, T, K, kb, KO, N, pfT, hdw, hkb, hKO, hN, hNk, hNO, hcap, hz)

@@ enc_text_lines_3 @@
  {T.${X}_encode(${OBJ}) == ${RE} : O.Bits & B.Buf}
def encode_eval(${AS}):
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, T)), (F.array__thaw(U32, T), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, T, pfT)) :
    {T.${X}_enc_sized(O.bsz_pick(K, _)) == ${RE} : O.Bits & B.Buf}
  %Equal.sym(Bool, ${CAP}, True{}, CO.capT(K, dw, hdw, hcap)) :
    {T.${X}_enc_sized((${OBJ}, O.pick(_, U32.add(U32.shrn(K, 3n), 1), 4294967295))) == ${RE} : O.Bits & B.Buf}
  %Equal.sym(Bool, O.is_poisoned(CO.NK(K)), False{}, CO.np_nk(K)) :
    {T.${X}_enc_go(_, CO.NK(K), ${OBJ}) == ${RE} : O.Bits & B.Buf}
  %Equal.sym(Array<U32>, ${ZB}, ${ZT},
      Equal.trans(Array<U32>, ${ZB}, Array.new(U32, ${DO}, 0), ${ZT},
        F.logic__subst(Nat, z => {${ZB} == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.nwu(CO.NK(K)))), ${DO},
          VD.wdu(VC.nwu(CO.NK(K))), VZG.zg(B.words_depth_u(VC.nwu(CO.NK(K))))),
        F.array__new(U32, ${DO}, 0))) :
    {T.${X}_enc_put(CO.NK(K), T.${p}_putn(_, 0, ${OBJ})) == ${RE} : O.Bits & B.Buf}
  %Equal.sym(${PN}, O.put_bits_n(${ZT}, 0, ${OBJ}), (F.array__thaw(U32, OUT(T, K)), (${OBJ}, CO.NK(K))), ${EV}) :
    {T.${X}_enc_put(CO.NK(K), _) == ${RE} : O.Bits & B.Buf}
  {==}

# Those bytes are the spec/codec.bend encoding of the object's value.
law encode_spec:
@@ enc_text_lines_4 @@
  Decoding.decodes(GS.${X}(), BY(T, K), VAL(T, K))
def encode_spec(${AS}):
  +c = cr(${AS})
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, T)), T, F.array__freeze_thaw(U32, T)) :
    Decoding.decodes(GS.${X}(), BY(T, K), S.BitsValue{BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, _)))})
@@ enc_text_lines_5 @@
  %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}])), BY(T, K), CO.cr2(${DO}, T, K, c)) :
    {Codec.bytes(Codec.one(Some{_}, None{})) == Some{BY(T, K)} : Maybe<&2, +List<U32>>}
  {==}