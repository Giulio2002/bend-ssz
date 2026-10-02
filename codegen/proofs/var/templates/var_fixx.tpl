@@ gen_text @@
# M, as a term that stays neutral while x is (so a value over M words is not unfolded)
def CNT(+x: Nat, +M: Nat) -> Nat: Nat.add(Nat.sub(x, x), M)
def cnt_eq(+x: Nat, +M: Nat) -> {CNT(x, M) == M : Nat}:
  %Equal.sym(Nat, Nat.sub(x, x), 0n, FD.nat__sub_self(x)) : {Nat.add(_, M) == M : Nat}
  {==}


@@ gen_text_2 @@
# ---- positions and splits ----------------------------------------------------------------------

def lenC(+t: ${TR}, +x: Nat, +M: Nat) -> {FD.spec_common__length(U32, UR.RWS(CNT(x, M), t, x)) == M : Nat}:
  %Equal.sym(Nat, CNT(x, M), M, cnt_eq(x, M)) : {FD.spec_common__length(U32, UR.RWS(_, t, x)) == M : Nat}
  UR.rws_len(M, t, x)

# x < P from x + S <= P, S > 0
def ltx(+x: Nat, +S: Nat, +P: Nat, +h0: {Nat.is_lt(0n, S) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, S), P) == ${TRUE}}) -> {Nat.is_lt(x, P) == ${TRUE}}:
  FD.nat__lt_le_trans(x, Nat.add(x, S), P, FD.logic__subst(Nat, z => {Nat.is_lt(z, Nat.add(x, S)) == ${TRUE}}, Nat.add(x, 0n), x, FD.nat__add_zero(x),
    FD.nat__lt_add_left(0n, S, x, h0)), hb)

# off + c is at byte C + x, for C < S the field size
def offc(+d: Nat, +off: U32, +c: U32, +C: Nat, +x: Nat, +S: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == ${TRUE}},
    +eC: {Nat.is_eq(U32.to_nat(c), C) == ${TRUE}}, +hC: {Nat.is_lt(C, S) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(x, C) : Nat}:
  %FD.nat__add_comm(C, x) : {U32.to_nat(U32.add(off, c)) == _ : Nat}
  offc0(d, off, c, C, x, S, e, hd, eC, hC, hb)
def offc0(+d: Nat, +off: U32, +c: U32, +C: Nat, +x: Nat, +S: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == ${TRUE}},
    +eC: {Nat.is_eq(U32.to_nat(c), C) == ${TRUE}}, +hC: {Nat.is_lt(C, S) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(C, x) : Nat}:
  +ec = FD.nat__eq_from_is_eq(U32.to_nat(c), C, eC)
  +h = FD.logic__subst(Nat, z => {Nat.is_lt(z, ${P}) == ${TRUE}}, Nat.add(x, C), Nat.add(C, x), FD.nat__add_comm(x, C),
    FD.nat__lt_le_trans(Nat.add(x, C), Nat.add(x, S), ${P}, FD.nat__lt_add_left(C, S, x, hC), hb))
  %Equal.sym(Nat, C, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), C, ec)) : {U32.to_nat(U32.add(off, c)) == Nat.add(_, x) : Nat}
  UR.offx(d, off, c, x, e, FD.nat__lt_trans(d, 28n, 30n, hd, {==}), FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, x), ${P}) == ${TRUE}}, C, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), C, ec), h))

# room for S2 bytes at x + C inside a field of S bytes at x
def roomc(+x: Nat, +S: Nat, +C: Nat, +S2: Nat, +P: Nat, +hb: {Nat.is_le(Nat.add(x, S), P) == ${TRUE}}, +hc: {Nat.is_le(Nat.add(C, S2), S) == ${TRUE}})
    -> {Nat.is_le(Nat.add(Nat.add(x, C), S2), P) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, P) == ${TRUE}}, Nat.add(x, Nat.add(C, S2)), Nat.add(Nat.add(x, C), S2), Equal.sym(Nat, Nat.add(Nat.add(x, C), S2), Nat.add(x, Nat.add(C, S2)), FD.nat__add_assoc(x, C, S2)),
    FD.nat__le_trans(Nat.add(x, Nat.add(C, S2)), Nat.add(x, S), P, Order.add_left(x, Nat.add(C, S2), S, hc), hb))

# the window's S = S1 + S2 bytes: the limbs of the M words at x (4 M = S1), then S2 bytes at S1 + x
def splitC(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +M: Nat, +S1: Nat, +S2: Nat, +S: Nat,
    +eS: {Nat.is_eq(A.quad(M), S1) == ${TRUE}}, +hS: {Nat.is_eq(Nat.add(S1, S2), S) == ${TRUE}}, +hw: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {UW.WX(t, x, S) == List.append(&2, U32, F.limbs(UR.RWS(CNT(x, M), t, x)), UW.WX(t, Nat.add(x, S1), S2)) : +List<U32>}:
  %FD.nat__add_comm(S1, x) : {UW.WX(t, x, S) == List.append(&2, U32, F.limbs(UR.RWS(CNT(x, M), t, x)), UW.WX(t, _, S2)) : +List<U32>}
  splitC0(d, t, x, pf, M, S1, S2, S, eS, hS, hw)
def splitC0(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +M: Nat, +S1: Nat, +S2: Nat, +S: Nat,
    +eS: {Nat.is_eq(A.quad(M), S1) == ${TRUE}}, +hS: {Nat.is_eq(Nat.add(S1, S2), S) == ${TRUE}}, +hw: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {UW.WX(t, x, S) == List.append(&2, U32, F.limbs(UR.RWS(CNT(x, M), t, x)), UW.WX(t, Nat.add(S1, x), S2)) : +List<U32>}:
  +eq = FD.nat__eq_from_is_eq(A.quad(M), S1, eS)
  +es = FD.nat__eq_from_is_eq(Nat.add(S1, S2), S, hS)
  %Equal.sym(Nat, CNT(x, M), M, cnt_eq(x, M)) : {UW.WX(t, x, S) == List.append(&2, U32, F.limbs(UR.RWS(_, t, x)), UW.WX(t, Nat.add(S1, x), S2)) : +List<U32>}
  %es : {UW.WX(t, x, _) == List.append(&2, U32, F.limbs(UR.RWS(M, t, x)), UW.WX(t, Nat.add(S1, x), S2)) : +List<U32>}
  %eq : {UW.WX(t, x, Nat.add(_, S2)) == List.append(&2, U32, F.limbs(UR.RWS(M, t, x)), UW.WX(t, Nat.add(_, x), S2)) : +List<U32>}
  UW.headWX(d, t, x, M, S2, pf, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P}) == ${TRUE}}, S, Nat.add(A.quad(M), S2),
    Equal.trans(Nat, S, Nat.add(S1, S2), Nat.add(A.quad(M), S2), Equal.sym(Nat, Nat.add(S1, S2), S, es), Equal.cong(Nat, Nat, z => Nat.add(z, S2), S1, A.quad(M), Equal.sym(Nat, A.quad(M), S1, eq))), hw))


@@ gen_text_3 @@
# copy_into of L bytes (S = L) at off (byte position x) into a zero storage of depth dz
def rdg(+d: Nat, +t: ${TR}, +n: U32, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == ${TRUE}}, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}},
    +L: U32, +S: Nat, +dz: Nat, +k: Nat, +eS: {Nat.is_eq(U32.to_nat(L), S) == ${TRUE}}, +hdz: {Nat.is_lt(dz, 31n) == ${TRUE}},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == ${TRUE}}, +hk: {Nat.is_lt(k, 31n) == ${TRUE}}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == ${TRUE}},
    +hb: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {O.copy_into(UA.BF(t, n), off, L, Array.new(U32, dz, 0)) == (UA.BF(t, n), O.Words{FD.array__thaw(U32, VXB.CTN(d, t, x, L, dz)), L}) : B.Buf & O.Words}:
  +hw = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P}) == ${TRUE}}, S, U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), S, FD.nat__eq_from_is_eq(U32.to_nat(L), S, eS)), hb)
  %VXB.ct_n(d, t, off, x, L, dz, e) : {O.copy_into(UA.BF(t, n), off, L, Array.new(U32, dz, 0)) == (UA.BF(t, n), O.Words{FD.array__thaw(U32, _), L}) : B.Buf & O.Words}
  VBX.copy_into_at(d, t, n, off, L, dz, k, pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), hdz, UW.hsx(d, off, x, L, e, hd, hw), hr, hk, hy)

@@ gen_text_4 @@
# the value of a vector of k elements over the M words at x: its parts are the S window bytes
def prt_${ch}(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +s: S.Schema, +k: Nat, +M: Nat, +S: Nat,
    +hs: {SH.is_Vector(s) == ${TRUE}}, +he: {SH.Vector_element(s) == ${el} : S.Schema}, +hk: {Nat.is_eq(SH.Vector_length(s), k) == ${TRUE}},
    +hk0: {Nat.is_lt(0n, k) == ${TRUE}}, +hL: {Nat.is_eq(AV.${mm}(k), M) == ${TRUE}}, +eS: {Nat.is_eq(A.quad(M), S) == ${TRUE}},
    +hf: {N.fits(4n, Nat.add(S, 0n)) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {Codec.parts(S.Sequence{AV.${ch}(UR.RWS(CNT(x, M), t, x))}, s) == Some{[S.Fixed{UW.WX(t, x, S)}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Nat, CNT(x, M), M, cnt_eq(x, M)) : {Codec.parts(S.Sequence{AV.${ch}(UR.RWS(_, t, x))}, s) == Some{[S.Fixed{UW.WX(t, x, S)}]} : Maybe<&2, +List<S.Part>>}
  prt0_${ch}(d, t, x, pf, s, k, M, S, hs, he, hk, hk0, hL, eS, hf, hb)
def prt0_${ch}(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +s: S.Schema, +k: Nat, +M: Nat, +S: Nat,
    +hs: {SH.is_Vector(s) == ${TRUE}}, +he: {SH.Vector_element(s) == ${el} : S.Schema}, +hk: {Nat.is_eq(SH.Vector_length(s), k) == ${TRUE}},
    +hk0: {Nat.is_lt(0n, k) == ${TRUE}}, +hL: {Nat.is_eq(AV.${mm}(k), M) == ${TRUE}}, +eS: {Nat.is_eq(A.quad(M), S) == ${TRUE}},
    +hf: {N.fits(4n, Nat.add(S, 0n)) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, S), ${P}) == ${TRUE}})
    -> {Codec.parts(S.Sequence{AV.${ch}(${W})}, s) == Some{[S.Fixed{UW.WX(t, x, S)}]} : Maybe<&2, +List<S.Part>>}:
  +eq = FD.nat__eq_from_is_eq(A.quad(M), S, eS)
  +hq = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P}) == ${TRUE}}, S, A.quad(M), Equal.sym(Nat, A.quad(M), S, eq), hb)
  +hN = Equal.trans(Nat, F.wlen(${W}), A.quad(M), S,
    Equal.trans(Nat, F.wlen(${W}), A.quad(List.length(&2, U32, ${W})), A.quad(M), VS.wlen_quad(${W}),
      Equal.cong(Nat, Nat, z => A.quad(z), List.length(&2, U32, ${W}), M, Equal.trans(Nat, List.length(&2, U32, ${W}), FD.spec_common__length(U32, ${W}), M, VMR.len_eq(${W}), UR.rws_len(M, t, x)))), eq)
  %eq : {Codec.parts(S.Sequence{AV.${ch}(${W})}, s) == Some{[S.Fixed{UW.WX(t, x, _)}]} : Maybe<&2, +List<S.Part>>}
  %UR.rws_bytes(M, d, t, x, pf, hq) : {Codec.parts(S.Sequence{AV.${ch}(${W})}, s) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  AV.${vp}(s, ${W}, k, M, S, hs, he, hk, hk0, UR.rws_len(M, t, x), hL, hN, hf)

@@ vec_text @@
def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> O.Words: O.Words{FD.array__thaw(U32, VXB.CTN(d, t, x, ${S}, ${dz}n)), ${S}}

${sig('rdx', S, sn=SN)}
    -> {T.${p}_read(UA.BF(t, n), off, ${S}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & O.Words}:
  VXG.rdg(d, t, n, off, x, e, hd, pf, ${S}, ${SN}, ${dz}n, ${ky}n, FD.nat__is_eq_refl(${SN}), {==}, VG.nw_pow(${S}, ${q}n, ${dz}n, {==}, {==}, {==}), {==},
    VG.yl_pow(${S}, ${r}n, ${ky}n, {==}, {==}, {==}, {==}), hb)

def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.Sequence{AV.${ch}(UR.RWS(VXG.CNT(x, AV.${mm}(${KN})), t, x))}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${SN}), A.quad(VB.pw(d))) == ${TRUE}},
    +s: S.Schema, +es: {s == ${sch} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, ${SN})}]} : Maybe<&2, +List<S.Part>>}:
  VXG.prt_${ch}(d, t, x, pf, s, ${KN}, AV.${mm}(${KN}), ${SN},
    FD.logic__subst(S.Schema, z => {SH.is_Vector(z) == ${TRUE}}, ${sch}, s, Equal.sym(S.Schema, s, ${sch}, es), {==}),
    FD.logic__subst(S.Schema, z => {SH.Vector_element(z) == ${EL} : S.Schema}, ${sch}, s, Equal.sym(S.Schema, s, ${sch}, es), {==}),
    FD.logic__subst(S.Schema, z => {Nat.is_eq(SH.Vector_length(z), ${KN}) == ${TRUE}}, ${sch}, s, Equal.sym(S.Schema, s, ${sch}, es), {==}),
    VG.pos_pow(${KN}, ${e}n, ${EK}), FD.nat__is_eq_refl(AV.${mm}(${KN})), VG.${es}(${S}, ${KN}, ${e}n, ${r}n, ${EK}, {==}, {==}, {==}),
    VG.fits_pow(${S}, ${r}n, {==}, {==}), hb)

@@ vec_text_2 @@
def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> O.Words: O.Words{FD.array__thaw(U32, VXB.CTN(d, t, x, ${S}, ${dz}n)), ${S}}

${sig('rdx', S)}
    -> {T.${p}_read(UA.BF(t, n), off, ${S}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & O.Words}:
  VXG.rdg(d, t, n, off, x, e, hd, pf, ${S}, ${S}n, ${dz}n, ${ky}n, {==}, {==}, {==}, {==}, {==}, hb)

def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.Sequence{AV.${ch}(UR.RWS(VXG.CNT(x, ${M}n), t, x))}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), A.quad(VB.pw(d))) == ${TRUE}},
    +s: S.Schema, +es: {s == ${sch} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : Maybe<&2, +List<S.Part>>}:
  VXG.prt_${ch}(d, t, x, pf, s, ${k}n, ${M}n, ${S}n,
    FD.logic__subst(S.Schema, z => {SH.is_Vector(z) == ${TRUE}}, ${sch}, s, Equal.sym(S.Schema, s, ${sch}, es), {==}),
    FD.logic__subst(S.Schema, z => {SH.Vector_element(z) == ${EL} : S.Schema}, ${sch}, s, Equal.sym(S.Schema, s, ${sch}, es), {==}),
    FD.logic__subst(S.Schema, z => {Nat.is_eq(SH.Vector_length(z), ${k}n) == ${TRUE}}, ${sch}, s, Equal.sym(S.Schema, s, ${sch}, es), {==}),
    {==}, {==}, {==}, {==}, hb)

@@ sc_mod @@
def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> T.SyncCommittee: ${OBJ}

${sig('rdx', S)}
    -> {T.SyncCommittee_read(UA.BF(t, n), off, ${S}) == ${RHS} : B.Buf & T.SyncCommittee}:
  %Equal.sym(B.Buf & O.Words, T.v512_b48_read(UA.BF(t, n), U32.add(off, 0), ${S1}), (UA.BF(t, n), ${PK}),
      VXG.rdg(d, t, n, U32.add(off, 0), x, Equal.trans(Nat, U32.to_nat(U32.add(off, 0)), Nat.add(x, 0n), x, VXG.offc(d, off, 0, 0n, x, ${S}n, e, hd, {==}, {==}, hb), FD.nat__add_zero(x)),
        hd, pf, ${S1}, ${S1}n, ${dz}n, ${ky}n, {==}, {==}, {==}, {==}, {==},
        FD.nat__le_trans(Nat.add(x, ${S1}n), Nat.add(x, ${S}n), ${P}, Order.add_left(x, ${S1}n, ${S}n, {==}), hb))) :
    {T.SyncCommittee_rd0(off, ${S}, _) == ${RHS} : B.Buf & T.SyncCommittee}
  %Equal.sym(B.Buf & T.Bytes48, T.b48_read(UA.BF(t, n), U32.add(off, ${S1}), 48), (UA.BF(t, n), ${B48}),
      VTX.rdx_b48(d, t, n, U32.add(off, ${S1}), ${y}, VXG.offc(d, off, ${S1}, ${S1}n, x, ${S}n, e, hd, {==}, {==}, hb), FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf,
        VXG.roomc(x, ${S}n, ${S1}n, 48n, ${P}, hb, {==}))) :
    {T.SyncCommittee_rd1(off, ${S}, ${PK}, _) == ${RHS} : B.Buf & T.SyncCommittee}
  {==}

def VAL(+t: ${TR}, +x: Nat) -> S.Value: ${VAL}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == Spec.SyncCommittee() : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(+List<U32>, UW.WX(t, x, ${S}n), List.append(&2, U32, F.limbs(UR.RWS(VXG.CNT(x, ${M}n), t, x)), UW.WX(t, ${y}, 48n)), VXG.splitC(d, t, x, pf, ${M}n, ${S1}n, 48n, ${S}n, {==}, {==}, hb)) : {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  %UR.rws_bytes(12n, d, t, ${y}, pf, VXG.roomc(x, ${S}n, ${S1}n, 48n, ${P}, hb, {==})) :
    {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{List.append(&2, U32, F.limbs(UR.RWS(VXG.CNT(x, ${M}n), t, x)), _)}]} : Maybe<&2, +List<S.Part>>}
  VXG.sc_parts(s, es, UR.RWS(VXG.CNT(x, ${M}n), t, x), ${M}n, ${S1}n, ${S}n, ${', '.join(G)}, VXG.lenC(t, x, ${M}n), {==}, {==}, {==}, {==}, {==})

@@ seq_head @@
%Equal.sym(${MP}, Codec.parts(VAL(t, x), ${sch}), Codec.aggregate(${a}, SC.fixed_size(${chain})),
      VSQ.seq_parts(VAL(t, x), ${sch}, ${items}, ${names}, ${chain}, {==}, {==})) :
    {_ == ${RHS} : ${MP}}
  %Equal.sym(Maybe<&2, Nat>, SC.fixed_size(${chain}), Some{${n}}, {==}) :
    {Codec.aggregate(${a}, _) == ${RHS} : ${MP}}
  ${VLW.chainify(proof)}
@@ small_mod @@
def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> ${ft.rep()}: ${OBJ}

${sig('rdx', S)}
    -> {T.${p}_read(UA.BF(t, n), off, ${S}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${ft.rep()}}:
  ${ref}(d, t, n, off, x, e, FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf, hb)

def VAL(+t: ${TR}, +x: Nat) -> S.Value: ${val}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == ${sch} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(S.Schema, s, ${sch}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : Maybe<&2, +List<S.Part>>}
  %UR.rws_bytes(${W}n, d, t, x, pf, hb) : {Codec.parts(VAL(t, x), ${sch}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
${xrw}  ${proof}
