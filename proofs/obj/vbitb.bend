import Base
import ../../src/obj.bend as O
import ../../types/generic_obj.bend as T
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/bit_packing.bend as Bp
import ../compact/found.bend as FD
import ../../proofs/word_split.bend as WSp
import ../../proofs/power_division.bend as PD
import ../../proofs/integer_decoding.bend as ID
import ./vuwd.bend as UWD
import ./vuw_bits.bend as UWB
import ./bits_leaf.bend as BLf

# One-byte bit vectors (Bitvector[1], [2], [8]) of the generic containers, as byte leaves: a valid
# vector's word is below 256, so the runtime's OR-based bvN_put writes exactly the byte T.u8_put
# writes (vpiece.u8piece places it at any byte, data-only), and the spec's parts of its bits are
# that byte.

# ---- a word below 256 ----
def sh8(+w: Word(8n)) -> {U32.shrn(PD.embed8(w), 8n) == 0 : U32}:
  match w:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WNil{}}}}}}}}}: {==}
def z8(+v: U32, +e: {U32.is_lt(v, 256) == True{} : Bool}) -> {U32.shrn(v, 8n) == 0 : U32}:
  Equal.trans(U32, U32.shrn(v, 8n), U32.shrn(PD.embed8(WSp.take(8n, 32n, PD.bits(v))), 8n), 0,
    Equal.cong(U32, U32, z => U32.shrn(z, 8n), v, PD.embed8(WSp.take(8n, 32n, PD.bits(v))), ID.byte_shape(v, e)),
    sh8(WSp.take(8n, 32n, PD.bits(v))))
def mshape(+x: U32) -> {U32.and(x, 255) == PD.embed8(WSp.take(8n, 32n, PD.bits(x))) : U32}:
  match x:
    case U32{+w}:
      Equal.cong(Word(32n), U32, w => U32{w},
        Word.and(32n, w, WSp.join(8n, 24n, WSp.ones(8n), Word.zero(24n))),
        WSp.join(8n, 24n, WSp.take(8n, 32n, w), Word.zero(24n)), WSp.mask_take(8n, 24n, w))
def ea(+v: U32, +e: {U32.is_lt(v, 256) == True{} : Bool}) -> {U32.and(v, 255) == v : U32}:
  Equal.trans(U32, U32.and(v, 255), PD.embed8(WSp.take(8n, 32n, PD.bits(v))), v, mshape(v),
    Equal.sym(U32, v, PD.embed8(WSp.take(8n, 32n, PD.bits(v))), ID.byte_shape(v, e)))

# ---- a word below 2 / 4: its low bits ----
def B0(+v: U32) -> Bool:
  match v:
    case U32{WCon{+b0, +t}}: b0
def shape1(+v: U32, +h: {U32.is_lt(v, 2) == True{} : Bool}) -> {v == U32{WCon{B0(v), Word.zero(31n)}} : U32}:
  match v:
    case U32{WCon{+b0, +hi}}:
      Equal.cong(Word(31n), U32, z => U32{WCon{b0, z}}, hi, Word.zero(31n),
        WSp.below_one(30n, hi, WSp.lt_prefix(1n, 31n, WCon{b0, WNil{}}, hi, WCon{True{}, Word.zero(30n)}, h)))
def shape2(+v: U32, +h: {U32.is_lt(v, 4) == True{} : Bool}) -> {v == U32{WCon{UWD.LB0(v), WCon{UWD.LB1(v), Word.zero(30n)}}} : U32}:
  match v:
    case U32{WCon{+b0, WCon{+b1, +hi}}}:
      Equal.cong(Word(30n), U32, z => U32{WCon{b0, WCon{b1, z}}}, hi, Word.zero(30n),
        WSp.below_one(29n, hi, WSp.lt_prefix(2n, 30n, WCon{b0, WCon{b1, WNil{}}}, hi, WCon{True{}, Word.zero(29n)}, h)))
def l1(+b0: Bool) -> {U32.is_lt(U32{WCon{b0, Word.zero(31n)}}, 256) == True{} : Bool}:
  match b0:
    case False{}: {==}
    case True{}: {==}
def l2(+b0: Bool, +b1: Bool) -> {U32.is_lt(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}, 256) == True{} : Bool}:
  match b0 b1:
    case False{} False{}: {==}
    case True{} False{}: {==}
    case False{} True{}: {==}
    case True{} True{}: {==}
def e1(+v: U32, +h: {U32.is_lt(v, 2) == True{} : Bool}) -> {U32.is_lt(v, 256) == True{} : Bool}:
  FD.logic__subst(U32, z => {U32.is_lt(z, 256) == True{} : Bool}, U32{WCon{B0(v), Word.zero(31n)}}, v,
    Equal.sym(U32, v, U32{WCon{B0(v), Word.zero(31n)}}, shape1(v, h)), l1(B0(v)))
def e2(+v: U32, +h: {U32.is_lt(v, 4) == True{} : Bool}) -> {U32.is_lt(v, 256) == True{} : Bool}:
  FD.logic__subst(U32, z => {U32.is_lt(z, 256) == True{} : Bool}, U32{WCon{UWD.LB0(v), WCon{UWD.LB1(v), Word.zero(30n)}}}, v,
    Equal.sym(U32, v, U32{WCon{UWD.LB0(v), WCon{UWD.LB1(v), Word.zero(30n)}}}, shape2(v, h)), l2(UWD.LB0(v), UWD.LB1(v)))

# ---- Bitvector[1]: its put is the byte write ----
def pwd1(+c0: Bool, +c1: Bool, out: Array<U32>, +Q: U32, +w0: U32, +z24: {U32.shrn(w0, 24n) == 0 : U32}, +z16: {U32.shrn(w0, 16n) == 0 : U32}, +z8: {U32.shrn(w0, 8n) == 0 : U32})
    -> {T.bv1_pwd(U32.is_eq(U32{WCon{c0, WCon{c1, Word.zero(30n)}}}, 0), U32{WCon{c0, WCon{c1, Word.zero(30n)}}}, out, Q, w0) == O.or_word(out, Q, O.shl_bytes(w0, U32{WCon{c0, WCon{c1, Word.zero(30n)}}})) : Array<U32>}:
  match c0 c1:
    case False{} False{}: Equal.cong(U32, Array<U32>, z => O.or_word(out, z, w0), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case True{} False{}:
      %Equal.sym(U32, U32.shrn(w0, 24n), 0, z24) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 256)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 256)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 256)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case False{} True{}:
      %Equal.sym(U32, U32.shrn(w0, 16n), 0, z16) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 65536)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 65536)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 65536)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case True{} True{}:
      %Equal.sym(U32, U32.shrn(w0, 8n), 0, z8) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 16777216)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 16777216)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 16777216)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
def put1(out: Array<U32>, +pos: U32, +w0: U32, +h: {U32.is_lt(w0, 2) == True{} : Bool})
    -> {T.bv1_put(out, pos, T.Bitvector1{w0}) == T.u8_put(out, pos, w0) : Array<U32>}:
  +e = e1(w0, h)
  +v8 = z8(w0, e)
  %Equal.sym(U32, U32.and(w0, 255), w0, ea(w0, e)) :
    {T.bv1_pwd(U32.is_eq(U32.and(pos, 3), 0), U32.and(pos, 3), out, U32.shrn(pos, 2n), w0) == O.or_word(out, U32.shrn(pos, 2n), O.shl_bytes(_, U32.and(pos, 3))) : Array<U32>}
  %Equal.sym(U32, U32.and(pos, 3), U32{WCon{UWD.LB0(pos), WCon{UWD.LB1(pos), Word.zero(30n)}}}, UWD.rmv(pos)) :
    {T.bv1_pwd(U32.is_eq(_, 0), _, out, U32.shrn(pos, 2n), w0) == O.or_word(out, U32.shrn(pos, 2n), O.shl_bytes(w0, _)) : Array<U32>}
  pwd1(UWD.LB0(pos), UWD.LB1(pos), out, U32.shrn(pos, 2n), w0, UWB.tzc11(w0, v8), UWB.tzc21(w0, v8), v8)

# ---- Bitvector[2]: its put is the byte write ----
def pwd2(+c0: Bool, +c1: Bool, out: Array<U32>, +Q: U32, +w0: U32, +z24: {U32.shrn(w0, 24n) == 0 : U32}, +z16: {U32.shrn(w0, 16n) == 0 : U32}, +z8: {U32.shrn(w0, 8n) == 0 : U32})
    -> {T.bv2_pwd(U32.is_eq(U32{WCon{c0, WCon{c1, Word.zero(30n)}}}, 0), U32{WCon{c0, WCon{c1, Word.zero(30n)}}}, out, Q, w0) == O.or_word(out, Q, O.shl_bytes(w0, U32{WCon{c0, WCon{c1, Word.zero(30n)}}})) : Array<U32>}:
  match c0 c1:
    case False{} False{}: Equal.cong(U32, Array<U32>, z => O.or_word(out, z, w0), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case True{} False{}:
      %Equal.sym(U32, U32.shrn(w0, 24n), 0, z24) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 256)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 256)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 256)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case False{} True{}:
      %Equal.sym(U32, U32.shrn(w0, 16n), 0, z16) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 65536)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 65536)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 65536)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case True{} True{}:
      %Equal.sym(U32, U32.shrn(w0, 8n), 0, z8) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 16777216)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 16777216)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 16777216)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
def put2(out: Array<U32>, +pos: U32, +w0: U32, +h: {U32.is_lt(w0, 4) == True{} : Bool})
    -> {T.bv2_put(out, pos, T.Bitvector2{w0}) == T.u8_put(out, pos, w0) : Array<U32>}:
  +e = e2(w0, h)
  +v8 = z8(w0, e)
  %Equal.sym(U32, U32.and(w0, 255), w0, ea(w0, e)) :
    {T.bv2_pwd(U32.is_eq(U32.and(pos, 3), 0), U32.and(pos, 3), out, U32.shrn(pos, 2n), w0) == O.or_word(out, U32.shrn(pos, 2n), O.shl_bytes(_, U32.and(pos, 3))) : Array<U32>}
  %Equal.sym(U32, U32.and(pos, 3), U32{WCon{UWD.LB0(pos), WCon{UWD.LB1(pos), Word.zero(30n)}}}, UWD.rmv(pos)) :
    {T.bv2_pwd(U32.is_eq(_, 0), _, out, U32.shrn(pos, 2n), w0) == O.or_word(out, U32.shrn(pos, 2n), O.shl_bytes(w0, _)) : Array<U32>}
  pwd2(UWD.LB0(pos), UWD.LB1(pos), out, U32.shrn(pos, 2n), w0, UWB.tzc11(w0, v8), UWB.tzc21(w0, v8), v8)

# ---- Bitvector[8]: its put is the byte write ----
def pwd8(+c0: Bool, +c1: Bool, out: Array<U32>, +Q: U32, +w0: U32, +z24: {U32.shrn(w0, 24n) == 0 : U32}, +z16: {U32.shrn(w0, 16n) == 0 : U32}, +z8: {U32.shrn(w0, 8n) == 0 : U32})
    -> {T.bv8_pwd(U32.is_eq(U32{WCon{c0, WCon{c1, Word.zero(30n)}}}, 0), U32{WCon{c0, WCon{c1, Word.zero(30n)}}}, out, Q, w0) == O.or_word(out, Q, O.shl_bytes(w0, U32{WCon{c0, WCon{c1, Word.zero(30n)}}})) : Array<U32>}:
  match c0 c1:
    case False{} False{}: Equal.cong(U32, Array<U32>, z => O.or_word(out, z, w0), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case True{} False{}:
      %Equal.sym(U32, U32.shrn(w0, 24n), 0, z24) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 256)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 256)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 256)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case False{} True{}:
      %Equal.sym(U32, U32.shrn(w0, 16n), 0, z16) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 65536)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 65536)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 65536)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
    case True{} True{}:
      %Equal.sym(U32, U32.shrn(w0, 8n), 0, z8) : {O.or_skip(O.or_word(out, U32.add(Q, 0), U32.mul(w0, 16777216)), U32.add(Q, 1), _) == O.or_word(out, Q, U32.mul(w0, 16777216)) : Array<U32>}
      Equal.cong(U32, Array<U32>, z => O.or_word(out, z, U32.mul(w0, 16777216)), U32.add(Q, 0), Q, FD.u32alg__add_zero(Q))
def put8(out: Array<U32>, +pos: U32, +w0: U32, +h: {U32.is_lt(w0, 256) == True{} : Bool})
    -> {T.bv8_put(out, pos, T.Bitvector8{w0}) == T.u8_put(out, pos, w0) : Array<U32>}:
  +e = h
  +v8 = z8(w0, e)
  %Equal.sym(U32, U32.and(w0, 255), w0, ea(w0, e)) :
    {T.bv8_pwd(U32.is_eq(U32.and(pos, 3), 0), U32.and(pos, 3), out, U32.shrn(pos, 2n), w0) == O.or_word(out, U32.shrn(pos, 2n), O.shl_bytes(_, U32.and(pos, 3))) : Array<U32>}
  %Equal.sym(U32, U32.and(pos, 3), U32{WCon{UWD.LB0(pos), WCon{UWD.LB1(pos), Word.zero(30n)}}}, UWD.rmv(pos)) :
    {T.bv8_pwd(U32.is_eq(_, 0), _, out, U32.shrn(pos, 2n), w0) == O.or_word(out, U32.shrn(pos, 2n), O.shl_bytes(w0, _)) : Array<U32>}
  pwd8(UWD.LB0(pos), UWD.LB1(pos), out, U32.shrn(pos, 2n), w0, UWB.tzc11(w0, v8), UWB.tzc21(w0, v8), v8)

# ---- the spec's value of the bits, and its parts: the byte ----
def V1(+v: U32) -> S.Value:
  match v:
    case U32{WCon{a0, r}}: S.BitsValue{[a0]}
def V2(+v: U32) -> S.Value:
  match v:
    case U32{WCon{a0, WCon{a1, r}}}: S.BitsValue{[a0, a1]}
def V8(+v: U32) -> S.Value:
  match v:
    case U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, r}}}}}}}}}: S.BitsValue{[a0, a1, a2, a3, a4, a5, a6, a7]}
def p1(+b0: Bool) -> {Codec.parts(V1(U32{WCon{b0, Word.zero(31n)}}), S.BitVector{1n}) == Some{[S.Fixed{[U32.and(U32{WCon{b0, Word.zero(31n)}}, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  match b0:
    case False{}: {==}
    case True{}: {==}
def prt1(+v: U32, +h: {U32.is_lt(v, 2) == True{} : Bool}) -> {Codec.parts(V1(v), S.BitVector{1n}) == Some{[S.Fixed{[U32.and(v, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(U32, v, U32{WCon{B0(v), Word.zero(31n)}}, shape1(v, h)) : {Codec.parts(V1(_), S.BitVector{1n}) == Some{[S.Fixed{[U32.and(_, 255)]}]} : Maybe<&2, +List<S.Part>>}
  p1(B0(v))
def p2(+b0: Bool, +b1: Bool) -> {Codec.parts(V2(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}), S.BitVector{2n}) == Some{[S.Fixed{[U32.and(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  match b0 b1:
    case False{} False{}: {==}
    case True{} False{}: {==}
    case False{} True{}: {==}
    case True{} True{}: {==}
def prt2(+v: U32, +h: {U32.is_lt(v, 4) == True{} : Bool}) -> {Codec.parts(V2(v), S.BitVector{2n}) == Some{[S.Fixed{[U32.and(v, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(U32, v, U32{WCon{UWD.LB0(v), WCon{UWD.LB1(v), Word.zero(30n)}}}, shape2(v, h)) : {Codec.parts(V2(_), S.BitVector{2n}) == Some{[S.Fixed{[U32.and(_, 255)]}]} : Maybe<&2, +List<S.Part>>}
  p2(UWD.LB0(v), UWD.LB1(v))
def p8(+w: Word(8n)) -> {Codec.parts(V8(PD.embed8(w)), S.BitVector{8n}) == Some{[S.Fixed{[PD.embed8(w)]}]} : Maybe<&2, +List<S.Part>>}:
  match w:
    case WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WNil{}}}}}}}}}:
      Equal.cong(U32, Maybe<&2, +List<S.Part>>, z => Some{[S.Fixed{[z]}]}, Bp.octet(a0, a1, a2, a3, a4, a5, a6, a7), PD.embed8(WCon{a0, WCon{a1, WCon{a2, WCon{a3, WCon{a4, WCon{a5, WCon{a6, WCon{a7, WNil{}}}}}}}}}),
        BLf.oct8(a0, a1, a2, a3, a4, a5, a6, a7))
def prt8(+v: U32, +h: {U32.is_lt(v, 256) == True{} : Bool}) -> {Codec.parts(V8(v), S.BitVector{8n}) == Some{[S.Fixed{[U32.and(v, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(U32, U32.and(v, 255), v, ea(v, h)) : {Codec.parts(V8(v), S.BitVector{8n}) == Some{[S.Fixed{[_]}]} : Maybe<&2, +List<S.Part>>}
  FD.logic__subst(U32, z => {Codec.parts(V8(z), S.BitVector{8n}) == Some{[S.Fixed{[z]}]} : Maybe<&2, +List<S.Part>>},
    PD.embed8(WSp.take(8n, 32n, PD.bits(v))), v, Equal.sym(U32, v, PD.embed8(WSp.take(8n, 32n, PD.bits(v))), ID.byte_shape(v, h)),
    p8(WSp.take(8n, 32n, PD.bits(v))))
