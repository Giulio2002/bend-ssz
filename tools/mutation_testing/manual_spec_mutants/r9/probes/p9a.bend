import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/uint128_def_generated.bend as U128
import ../../../../../types/uint256_def_generated.bend as U256
import ../../../../../types/vec_uint16_5_def_generated.bend as V5u16
import ../../../../../types/vec_uint16_5_encode_ssz_generated.bend as V5u16E
import ../../../../../types/vec_uint16_5_hashtreeroot_generated.bend as V5u16H
import ../../../../../types/vec_uint16_513_def_generated.bend as V513u16
import ../../../../../types/vec_uint16_513_encode_ssz_generated.bend as V513u16E
import ../../../../../types/vec_uint16_513_hashtreeroot_generated.bend as V513u16H
import ../../../../../types/vec_uint8_513_def_generated.bend as V513u8
import ../../../../../types/vec_uint8_513_encode_ssz_generated.bend as V513u8E
import ../../../../../types/vec_uint8_513_hashtreeroot_generated.bend as V513u8H
import ../../../../../types/vec_uint32_31_def_generated.bend as V31u32
import ../../../../../types/vec_uint32_31_encode_ssz_generated.bend as V31u32E
import ../../../../../types/vec_uint32_31_hashtreeroot_generated.bend as V31u32H
import ../../../../../types/vec_uint64_3_def_generated.bend as V3u64
import ../../../../../types/vec_uint64_3_encode_ssz_generated.bend as V3u64E
import ../../../../../types/vec_uint64_3_hashtreeroot_generated.bend as V3u64H
import ../../../../../types/vec_uint128_3_def_generated.bend as V3u128
import ../../../../../types/vec_uint128_3_encode_ssz_generated.bend as V3u128E
import ../../../../../types/vec_uint128_3_hashtreeroot_generated.bend as V3u128H
import ../../../../../types/vec_uint128_31_def_generated.bend as V31u128
import ../../../../../types/vec_uint128_31_encode_ssz_generated.bend as V31u128E
import ../../../../../types/vec_uint128_31_hashtreeroot_generated.bend as V31u128H
import ../../../../../types/vec_uint256_5_def_generated.bend as V5u256
import ../../../../../types/vec_uint256_5_encode_ssz_generated.bend as V5u256E
import ../../../../../types/vec_uint256_5_hashtreeroot_generated.bend as V5u256H
import ../../../../../types/vec_uint256_3_hashtreeroot_generated.bend as V3u256H
import ../../../../../types/vec_bool_5_def_generated.bend as V5b
import ../../../../../types/vec_bool_5_encode_ssz_generated.bend as V5bE
import ../../../../../types/vec_bool_513_def_generated.bend as V513b
import ../../../../../types/vec_bool_513_encode_ssz_generated.bend as V513bE
import ../../../../../types/vec_bool_513_hashtreeroot_generated.bend as V513bH
import ../../../../../types/proglist_uint32_def_generated.bend as PLu32
import ../../../../../types/proglist_uint32_encode_ssz_generated.bend as PLu32E
import ../../../../../types/proglist_uint64_def_generated.bend as PLu64
import ../../../../../types/proglist_uint64_encode_ssz_generated.bend as PLu64E
import ../../../../../types/proglist_uint128_def_generated.bend as PLu128
import ../../../../../types/proglist_uint128_encode_ssz_generated.bend as PLu128E
import ../../../../../types/proglist_uint256_def_generated.bend as PLu256
import ../../../../../types/proglist_uint256_encode_ssz_generated.bend as PLu256E
import ../../../../../types/proglist_bool_def_generated.bend as PLb
import ../../../../../types/proglist_bool_encode_ssz_generated.bend as PLbE
import ../../../../../types/bitvector_1281_def_generated.bend as BV1281
import ../../../../../types/ProgressiveBitsStruct_def_generated.bend as PBS
import ../../../../../types/ProgressiveBitsStruct_encode_ssz_generated.bend as PBSE
import ../../../../../types/ProgressiveBitsStruct_hashtreeroot_generated.bend as PBSH
import ../../../../../types/bitvector_1280_def_generated.bend as BV1280
import ../../../../../types/FixedTestStruct_def_generated.bend as FTS
import ../../../../../types/FixedTestStruct_encode_ssz_generated.bend as FTSE
import ../../../../../types/SmallTestStruct_def_generated.bend as STS
import ../../../../../types/SmallTestStruct_encode_ssz_generated.bend as STSE
import ../../../../../types/vec_FixedTestStruct_4_def_generated.bend as V4F
import ../../../../../types/ComplexTestStruct_def_generated.bend as CTS
import ../../../../../types/ComplexTestStruct_encode_ssz_generated.bend as CTSE
import ../../../../../types/proglist_SmallTestStruct_def_generated.bend as PLS
import ../../../../../types/ProgressiveTestStruct_def_generated.bend as PTS
import ../../../../../types/ProgressiveTestStruct_encode_ssz_generated.bend as PTSE
import ../../../../../types/CompatibleUnionBC_def_generated.bend as UBC
import ../../../../../types/CompatibleUnionABCA_def_generated.bend as UABCA
import ../../../../../types/CompatibleUnionA_def_generated.bend as UA
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-9 probe a: the typed accessors no law names (scalar vectors, progressive lists of scalars, bit vectors as bytes,
# composite vectors / lists, generic container getters / setters, union selectors) and the roots of odd vectors.
# Public calls only: X_default, X_get, X_set, X_append, X_len, field getters / setters, X_serialize, X_hash_tree_root,
# U_selector. Every case prints one line; apiprobe3.py (PROBE=this file) compares a mutant's lines with the unmutated build.

def ck_go(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> U32:
  match k pair:
    case 0n Tuple{ws, x}: acc
    case 1n+q Tuple{ws, +x}: ck_go(q, (i + 1 : U32), ((acc * 31 : U32) + x : U32), Array.get(U32, ws, (i + 1 : U32)))

def enc_str(e: O.Encoded) -> String:
  match e:
    case O.Encoded{x, b}:
      match b:
        case B.Buf{ws, +n}: "ok=" ++ O.pick_str(x) ++ ",n=" ++ U32.show(n) ++ ",ck=" ++ U32.show(ck_go(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, 7, Array.get(U32, ws, 0)))

def sw(pair: O.Words & O.Encoded) -> String:
  (w, e) = pair
  enc_str(e)

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(h)

def rw(pair: B.Buf & (O.Words & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def fstw(pair: O.Words & Bool) -> O.Words:
  (w, ok) = pair
  w
def okw(pair: O.Words & Bool) -> String:
  (w, ok) = pair
  O.pick_str(ok)
def lenw(pair: O.Words & U32) -> String:
  (w, +n) = pair
  U32.show(n)
def mu(pair: O.Words & Maybe<&1, U32>) -> String:
  (w, m) = pair
  match m:
    case Some{+v}: "S" ++ U32.show(v)
    case None{}: "N"
def mb(pair: O.Words & Maybe<&1, Bool>) -> String:
  (w, m) = pair
  match m:
    case Some{v}: "S" ++ O.pick_str(v)
    case None{}: "N"
def m64(pair: O.Words & Maybe<&1, O.U64>) -> String:
  (w, m) = pair
  match m:
    case Some{+v}:
      match v:
        case O.U64{+lo, +hi}: "S" ++ U32.show(lo) ++ ":" ++ U32.show(hi)
    case None{}: "N"
def m128(pair: O.Words & Maybe<&1, U128.Uint128>) -> String:
  (w, m) = pair
  match m:
    case Some{+v}:
      match v:
        case U128.Uint128{+a, +b1, +c, +d}: "S" ++ U32.show(a) ++ ":" ++ U32.show(b1) ++ ":" ++ U32.show(c) ++ ":" ++ U32.show(d)
    case None{}: "N"
def m256(pair: O.Words & Maybe<&1, U256.Uint256>) -> String:
  (w, m) = pair
  match m:
    case Some{+v}:
      match v:
        case U256.Uint256{+a, +b1, +c, +d, +e, +f, +g, +h}: "S" ++ U32.show(a) ++ ":" ++ U32.show(e) ++ ":" ++ U32.show(h)
    case None{}: "N"

def u64(+x: U32) -> O.U64: O.U64{x, (x + 1 : U32)}
def u128(+x: U32) -> U128.Uint128: U128.Uint128{x, (x + 1 : U32), (x + 2 : U32), (x + 3 : U32)}
def u256(+x: U32) -> U256.Uint256: U256.Uint256{x, (x + 1 : U32), (x + 2 : U32), (x + 3 : U32), (x + 4 : U32), (x + 5 : U32), (x + 6 : U32), (x + 7 : U32)}

def pbs_ser(pair: PBS.ProgressiveBitsStruct & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)
def pbs_root(pair: B.Buf & (PBS.ProgressiveBitsStruct & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)
def cts_ser(pair: CTS.ComplexTestStruct & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)
def pts_ser(pair: PTS.ProgressiveTestStruct & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)

# ---- scalar vectors of U32-held elements: get(len), set(len), set(0, 2^k), set(1, x) then get 0 / 1 / 2, serialize, root, len
def c_v5u16() -> String:
  "v5u16 g5=" ++ mu(V5u16.v5_u16_get(V5u16.v5_u16_default(), 5)) ++ " s5=" ++ okw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 5, 7)) ++ " sbig=" ++ okw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 0, 65536)) ++ " s1=" ++ okw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 1, 4660)) ++ " g0=" ++ mu(V5u16.v5_u16_get(fstw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 1, 4660)), 0)) ++ " g1=" ++ mu(V5u16.v5_u16_get(fstw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 1, 4660)), 1)) ++ " g2=" ++ mu(V5u16.v5_u16_get(fstw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 1, 4660)), 2)) ++ " ser=" ++ sw(V5u16E.vec_uint16_5_serialize(fstw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 1, 4660)))) ++ " sers5=" ++ sw(V5u16E.vec_uint16_5_serialize(fstw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 5, 7)))) ++ " root=" ++ rw(V5u16H.vec_uint16_5_hash_tree_root(O.hasher(), fstw(V5u16.v5_u16_set(V5u16.v5_u16_default(), 1, 4660)))) ++ " len=" ++ lenw(V5u16.v5_u16_len(V5u16.v5_u16_default()))

def c_v513u16() -> String:
  "v513u16 g513=" ++ mu(V513u16.v513_u16_get(V513u16.v513_u16_default(), 513)) ++ " s513=" ++ okw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 513, 7)) ++ " sbig=" ++ okw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 0, 65536)) ++ " s1=" ++ okw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 1, 4660)) ++ " g0=" ++ mu(V513u16.v513_u16_get(fstw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 1, 4660)), 0)) ++ " g1=" ++ mu(V513u16.v513_u16_get(fstw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 1, 4660)), 1)) ++ " ser=" ++ sw(V513u16E.vec_uint16_513_serialize(fstw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 1, 4660)))) ++ " root=" ++ rw(V513u16H.vec_uint16_513_hash_tree_root(O.hasher(), fstw(V513u16.v513_u16_set(V513u16.v513_u16_default(), 1, 4660)))) ++ " len=" ++ lenw(V513u16.v513_u16_len(V513u16.v513_u16_default()))

def c_v513u8() -> String:
  "v513u8 g513=" ++ mu(V513u8.v513_u8_get(V513u8.v513_u8_default(), 513)) ++ " s513=" ++ okw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 513, 7)) ++ " sbig=" ++ okw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 0, 256)) ++ " s1=" ++ okw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 1, 171)) ++ " g0=" ++ mu(V513u8.v513_u8_get(fstw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 1, 171)), 0)) ++ " g1=" ++ mu(V513u8.v513_u8_get(fstw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 1, 171)), 1)) ++ " g2=" ++ mu(V513u8.v513_u8_get(fstw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 1, 171)), 2)) ++ " ser=" ++ sw(V513u8E.vec_uint8_513_serialize(fstw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 1, 171)))) ++ " root=" ++ rw(V513u8H.vec_uint8_513_hash_tree_root(O.hasher(), fstw(V513u8.v513_u8_set(V513u8.v513_u8_default(), 1, 171)))) ++ " len=" ++ lenw(V513u8.v513_u8_len(V513u8.v513_u8_default()))

def c_v31u32() -> String:
  "v31u32 g31=" ++ mu(V31u32.v31_u32_get(V31u32.v31_u32_default(), 31)) ++ " s31=" ++ okw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 31, 7)) ++ " s1=" ++ okw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 1, 305419896)) ++ " g0=" ++ mu(V31u32.v31_u32_get(fstw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 1, 305419896)), 0)) ++ " g1=" ++ mu(V31u32.v31_u32_get(fstw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 1, 305419896)), 1)) ++ " g2=" ++ mu(V31u32.v31_u32_get(fstw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 1, 305419896)), 2)) ++ " ser=" ++ sw(V31u32E.vec_uint32_31_serialize(fstw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 1, 305419896)))) ++ " root=" ++ rw(V31u32H.vec_uint32_31_hash_tree_root(O.hasher(), fstw(V31u32.v31_u32_set(V31u32.v31_u32_default(), 1, 305419896)))) ++ " len=" ++ lenw(V31u32.v31_u32_len(V31u32.v31_u32_default()))

def c_v3u64() -> String:
  "v3u64 g3=" ++ m64(V3u64.v3_u64_get(V3u64.v3_u64_default(), 3)) ++ " s3=" ++ okw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 3, u64(7))) ++ " s1=" ++ okw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 1, u64(305419896))) ++ " g0=" ++ m64(V3u64.v3_u64_get(fstw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 1, u64(305419896))), 0)) ++ " g1=" ++ m64(V3u64.v3_u64_get(fstw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 1, u64(305419896))), 1)) ++ " g2=" ++ m64(V3u64.v3_u64_get(fstw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 1, u64(305419896))), 2)) ++ " ser=" ++ sw(V3u64E.vec_uint64_3_serialize(fstw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 1, u64(305419896))))) ++ " root=" ++ rw(V3u64H.vec_uint64_3_hash_tree_root(O.hasher(), fstw(V3u64.v3_u64_set(V3u64.v3_u64_default(), 1, u64(305419896))))) ++ " len=" ++ lenw(V3u64.v3_u64_len(V3u64.v3_u64_default()))

def c_v3u128() -> String:
  "v3u128 g3=" ++ m128(V3u128.v3_u128_get(V3u128.v3_u128_default(), 3)) ++ " s3=" ++ okw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 3, u128(7))) ++ " s1=" ++ okw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 1, u128(100))) ++ " g0=" ++ m128(V3u128.v3_u128_get(fstw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 1, u128(100))), 0)) ++ " g1=" ++ m128(V3u128.v3_u128_get(fstw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 1, u128(100))), 1)) ++ " g2=" ++ m128(V3u128.v3_u128_get(fstw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 1, u128(100))), 2)) ++ " ser=" ++ sw(V3u128E.vec_uint128_3_serialize(fstw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 1, u128(100))))) ++ " root=" ++ rw(V3u128H.vec_uint128_3_hash_tree_root(O.hasher(), fstw(V3u128.v3_u128_set(V3u128.v3_u128_default(), 1, u128(100))))) ++ " len=" ++ lenw(V3u128.v3_u128_len(V3u128.v3_u128_default()))

def c_v31u128() -> String:
  "v31u128 g31=" ++ m128(V31u128.v31_u128_get(V31u128.v31_u128_default(), 31)) ++ " s31=" ++ okw(V31u128.v31_u128_set(V31u128.v31_u128_default(), 31, u128(7))) ++ " g1=" ++ m128(V31u128.v31_u128_get(fstw(V31u128.v31_u128_set(V31u128.v31_u128_default(), 1, u128(100))), 1)) ++ " g0=" ++ m128(V31u128.v31_u128_get(fstw(V31u128.v31_u128_set(V31u128.v31_u128_default(), 1, u128(100))), 0)) ++ " ser=" ++ sw(V31u128E.vec_uint128_31_serialize(fstw(V31u128.v31_u128_set(V31u128.v31_u128_default(), 1, u128(100))))) ++ " root=" ++ rw(V31u128H.vec_uint128_31_hash_tree_root(O.hasher(), fstw(V31u128.v31_u128_set(V31u128.v31_u128_default(), 1, u128(100))))) ++ " len=" ++ lenw(V31u128.v31_u128_len(V31u128.v31_u128_default()))

def c_v5u256() -> String:
  "v5u256 g5=" ++ m256(V5u256.v5_u256_get(V5u256.v5_u256_default(), 5)) ++ " s5=" ++ okw(V5u256.v5_u256_set(V5u256.v5_u256_default(), 5, u256(7))) ++ " g1=" ++ m256(V5u256.v5_u256_get(fstw(V5u256.v5_u256_set(V5u256.v5_u256_default(), 1, u256(100))), 1)) ++ " g0=" ++ m256(V5u256.v5_u256_get(fstw(V5u256.v5_u256_set(V5u256.v5_u256_default(), 1, u256(100))), 0)) ++ " g2=" ++ m256(V5u256.v5_u256_get(fstw(V5u256.v5_u256_set(V5u256.v5_u256_default(), 1, u256(100))), 2)) ++ " ser=" ++ sw(V5u256E.vec_uint256_5_serialize(fstw(V5u256.v5_u256_set(V5u256.v5_u256_default(), 1, u256(100))))) ++ " root=" ++ rw(V5u256H.vec_uint256_5_hash_tree_root(O.hasher(), fstw(V5u256.v5_u256_set(V5u256.v5_u256_default(), 1, u256(100))))) ++ " root3=" ++ rw(V3u256H.vec_uint256_3_hash_tree_root(O.hasher(), O.words_new(96))) ++ " len=" ++ lenw(V5u256.v5_u256_len(V5u256.v5_u256_default()))

def c_v5b() -> String:
  "v5b g5=" ++ mb(V5b.v5_bool_get(V5b.v5_bool_default(), 5)) ++ " s5=" ++ okw(V5b.v5_bool_set(V5b.v5_bool_default(), 5, True{})) ++ " g0=" ++ mb(V5b.v5_bool_get(V5b.v5_bool_default(), 0)) ++ " g1t=" ++ mb(V5b.v5_bool_get(fstw(V5b.v5_bool_set(V5b.v5_bool_default(), 1, True{})), 1)) ++ " ser=" ++ sw(V5bE.vec_bool_5_serialize(fstw(V5b.v5_bool_set(V5b.v5_bool_default(), 1, True{})))) ++ " len=" ++ lenw(V5b.v5_bool_len(V5b.v5_bool_default()))

def c_v513b() -> String:
  "v513b g513=" ++ mb(V513b.v513_bool_get(V513b.v513_bool_default(), 513)) ++ " s513=" ++ okw(V513b.v513_bool_set(V513b.v513_bool_default(), 513, True{})) ++ " g0=" ++ mb(V513b.v513_bool_get(V513b.v513_bool_default(), 0)) ++ " g1t=" ++ mb(V513b.v513_bool_get(fstw(V513b.v513_bool_set(V513b.v513_bool_default(), 1, True{})), 1)) ++ " ser=" ++ sw(V513bE.vec_bool_513_serialize(fstw(V513b.v513_bool_set(V513b.v513_bool_default(), 1, True{})))) ++ " root=" ++ rw(V513bH.vec_bool_513_hash_tree_root(O.hasher(), fstw(V513b.v513_bool_set(V513b.v513_bool_default(), 1, True{})))) ++ " len=" ++ lenw(V513b.v513_bool_len(V513b.v513_bool_default()))

# ---- progressive lists: three appends, then the same questions
def pl32() -> O.Words: fstw(PLu32.pl_u32_append(fstw(PLu32.pl_u32_append(fstw(PLu32.pl_u32_append(PLu32.pl_u32_default(), 7)), 8)), 9))
def c_pl32() -> String:
  "pl32 g3=" ++ mu(PLu32.pl_u32_get(pl32(), 3)) ++ " s3=" ++ okw(PLu32.pl_u32_set(pl32(), 3, 5)) ++ " g1=" ++ mu(PLu32.pl_u32_get(pl32(), 1)) ++ " g1s=" ++ mu(PLu32.pl_u32_get(fstw(PLu32.pl_u32_set(pl32(), 1, 305419896)), 1)) ++ " g0s=" ++ mu(PLu32.pl_u32_get(fstw(PLu32.pl_u32_set(pl32(), 1, 305419896)), 0)) ++ " ser=" ++ sw(PLu32E.proglist_uint32_serialize(fstw(PLu32.pl_u32_set(pl32(), 1, 305419896)))) ++ " len=" ++ lenw(PLu32.pl_u32_len(pl32()))
def pl64() -> O.Words: fstw(PLu64.pl_u64_append(fstw(PLu64.pl_u64_append(fstw(PLu64.pl_u64_append(PLu64.pl_u64_default(), u64(7))), u64(8))), u64(9)))
def c_pl64() -> String:
  "pl64 g3=" ++ m64(PLu64.pl_u64_get(pl64(), 3)) ++ " s3=" ++ okw(PLu64.pl_u64_set(pl64(), 3, u64(5))) ++ " g1=" ++ m64(PLu64.pl_u64_get(pl64(), 1)) ++ " g1s=" ++ m64(PLu64.pl_u64_get(fstw(PLu64.pl_u64_set(pl64(), 1, u64(100))), 1)) ++ " g0s=" ++ m64(PLu64.pl_u64_get(fstw(PLu64.pl_u64_set(pl64(), 1, u64(100))), 0)) ++ " ser=" ++ sw(PLu64E.proglist_uint64_serialize(fstw(PLu64.pl_u64_set(pl64(), 1, u64(100))))) ++ " len=" ++ lenw(PLu64.pl_u64_len(pl64()))
def pl128() -> O.Words: fstw(PLu128.pl_u128_append(fstw(PLu128.pl_u128_append(fstw(PLu128.pl_u128_append(PLu128.pl_u128_default(), u128(7))), u128(8))), u128(9)))
def c_pl128() -> String:
  "pl128 g3=" ++ m128(PLu128.pl_u128_get(pl128(), 3)) ++ " s3=" ++ okw(PLu128.pl_u128_set(pl128(), 3, u128(5))) ++ " g1=" ++ m128(PLu128.pl_u128_get(pl128(), 1)) ++ " g2=" ++ m128(PLu128.pl_u128_get(pl128(), 2)) ++ " g1s=" ++ m128(PLu128.pl_u128_get(fstw(PLu128.pl_u128_set(pl128(), 1, u128(100))), 1)) ++ " g0s=" ++ m128(PLu128.pl_u128_get(fstw(PLu128.pl_u128_set(pl128(), 1, u128(100))), 0)) ++ " ser=" ++ sw(PLu128E.proglist_uint128_serialize(pl128())) ++ " len=" ++ lenw(PLu128.pl_u128_len(pl128()))
def pl256() -> O.Words: fstw(PLu256.pl_u256_append(fstw(PLu256.pl_u256_append(fstw(PLu256.pl_u256_append(PLu256.pl_u256_default(), u256(7))), u256(8))), u256(9)))
def c_pl256() -> String:
  "pl256 g3=" ++ m256(PLu256.pl_u256_get(pl256(), 3)) ++ " s3=" ++ okw(PLu256.pl_u256_set(pl256(), 3, u256(5))) ++ " g1=" ++ m256(PLu256.pl_u256_get(pl256(), 1)) ++ " g2=" ++ m256(PLu256.pl_u256_get(pl256(), 2)) ++ " g1s=" ++ m256(PLu256.pl_u256_get(fstw(PLu256.pl_u256_set(pl256(), 1, u256(100))), 1)) ++ " g0s=" ++ m256(PLu256.pl_u256_get(fstw(PLu256.pl_u256_set(pl256(), 1, u256(100))), 0)) ++ " ser=" ++ sw(PLu256E.proglist_uint256_serialize(pl256())) ++ " len=" ++ lenw(PLu256.pl_u256_len(pl256()))
def plb() -> O.Words: fstw(PLb.pl_bool_append(fstw(PLb.pl_bool_append(fstw(PLb.pl_bool_append(PLb.pl_bool_default(), True{})), False{})), True{}))
def c_plb() -> String:
  "plb g3=" ++ mb(PLb.pl_bool_get(plb(), 3)) ++ " s3=" ++ okw(PLb.pl_bool_set(plb(), 3, True{})) ++ " g1=" ++ mb(PLb.pl_bool_get(plb(), 1)) ++ " g2=" ++ mb(PLb.pl_bool_get(plb(), 2)) ++ " g1s=" ++ mb(PLb.pl_bool_get(fstw(PLb.pl_bool_set(plb(), 1, True{})), 1)) ++ " ser=" ++ sw(PLbE.proglist_bool_serialize(fstw(PLb.pl_bool_set(plb(), 1, True{})))) ++ " len=" ++ lenw(PLb.pl_bool_len(plb()))

# ---- bit vectors as byte arrays
def c_bv1281() -> String:
  "bv1281 g161=" ++ mu(BV1281.bv1281_get(BV1281.bv1281_default(), 161)) ++ " s161=" ++ okw(BV1281.bv1281_set(BV1281.bv1281_default(), 161, 1)) ++ " s1281=" ++ okw(BV1281.bv1281_set(BV1281.bv1281_default(), 1000, 1)) ++ " sbig=" ++ okw(BV1281.bv1281_set(BV1281.bv1281_default(), 0, 256)) ++ " g1=" ++ mu(BV1281.bv1281_get(fstw(BV1281.bv1281_set(BV1281.bv1281_default(), 1, 171)), 1)) ++ " g2=" ++ mu(BV1281.bv1281_get(fstw(BV1281.bv1281_set(BV1281.bv1281_default(), 1, 171)), 2)) ++ " g0=" ++ mu(BV1281.bv1281_get(fstw(BV1281.bv1281_set(BV1281.bv1281_default(), 0, 171)), 0)) ++ " ser=" ++ pbs_ser(PBSE.ProgressiveBitsStruct_serialize(PBS.ProgressiveBitsStruct_set_f_J(PBS.ProgressiveBitsStruct_default(), fstw(BV1281.bv1281_set(BV1281.bv1281_default(), 1, 171))))) ++ " root=" ++ pbs_root(PBSH.ProgressiveBitsStruct_hash_tree_root(O.hasher(), PBS.ProgressiveBitsStruct_set_f_J(PBS.ProgressiveBitsStruct_default(), fstw(BV1281.bv1281_set(BV1281.bv1281_default(), 1, 171)))))
def c_bv1280() -> String:
  "bv1280 g160=" ++ mu(BV1280.bv1280_get(BV1280.bv1280_default(), 160)) ++ " s160=" ++ okw(BV1280.bv1280_set(BV1280.bv1280_default(), 160, 1)) ++ " s1000=" ++ okw(BV1280.bv1280_set(BV1280.bv1280_default(), 1000, 1)) ++ " sbig=" ++ okw(BV1280.bv1280_set(BV1280.bv1280_default(), 0, 256)) ++ " g1=" ++ mu(BV1280.bv1280_get(fstw(BV1280.bv1280_set(BV1280.bv1280_default(), 1, 171)), 1)) ++ " g2=" ++ mu(BV1280.bv1280_get(fstw(BV1280.bv1280_set(BV1280.bv1280_default(), 1, 171)), 2)) ++ " g0=" ++ mu(BV1280.bv1280_get(fstw(BV1280.bv1280_set(BV1280.bv1280_default(), 0, 171)), 0)) ++ " ser=" ++ pbs_ser(PBSE.ProgressiveBitsStruct_serialize(PBS.ProgressiveBitsStruct_set_f_G(PBS.ProgressiveBitsStruct_default(), fstw(BV1280.bv1280_set(BV1280.bv1280_default(), 1, 171))))) ++ " root=" ++ pbs_root(PBSH.ProgressiveBitsStruct_hash_tree_root(O.hasher(), PBS.ProgressiveBitsStruct_set_f_G(PBS.ProgressiveBitsStruct_default(), fstw(BV1280.bv1280_set(BV1280.bv1280_default(), 1, 171)))))

# ---- generic containers: setters then getters of every field, serialize
def fts_show(o: FTS.FixedTestStruct) -> String:
  match o:
    case FTS.FixedTestStruct{+a, +b1, +c}:
      match b1:
        case O.U64{+lo, +hi}: U32.show(a) ++ "/" ++ U32.show(lo) ++ ":" ++ U32.show(hi) ++ "/" ++ U32.show(c)
def fts_g(pair: FTS.FixedTestStruct & U32) -> String:
  (o, +v) = pair
  U32.show(v)
def fts_fst(pair: FTS.FixedTestStruct & Bool) -> FTS.FixedTestStruct:
  (o, ok) = pair
  o
def fts1() -> FTS.FixedTestStruct: FTS.FixedTestStruct_set_f_C(FTS.FixedTestStruct_set_f_B(fts_fst(FTS.FixedTestStruct_set_f_A(FTS.FixedTestStruct_default(), 17)), O.U64{5, 6}), 3000)
def c_fts() -> String:
  "fts v=" ++ fts_show(fts1()) ++ " gA=" ++ fts_g(FTS.FixedTestStruct_get_f_A(fts1())) ++ " gC=" ++ fts_g(FTS.FixedTestStruct_get_f_C(fts1())) ++ " ser=" ++ enc_str(FTSE.FixedTestStruct_serialize(fts1()))
def sts_g(pair: STS.SmallTestStruct & U32) -> String:
  (o, +v) = pair
  U32.show(v)
def sts_fst(pair: STS.SmallTestStruct & Bool) -> STS.SmallTestStruct:
  (o, ok) = pair
  o
def sts1() -> STS.SmallTestStruct: sts_fst(STS.SmallTestStruct_set_f_B(sts_fst(STS.SmallTestStruct_set_f_A(STS.SmallTestStruct_default(), 17)), 3000))
def c_sts() -> String:
  "sts gA=" ++ sts_g(STS.SmallTestStruct_get_f_A(sts1())) ++ " gB=" ++ sts_g(STS.SmallTestStruct_get_f_B(sts1())) ++ " ser=" ++ enc_str(STSE.SmallTestStruct_serialize(sts1()))

# ---- composite vector / progressive list
def v4f_g(pair: V4F.v4_FixedTestStruct_Seq & Maybe<&1, FTS.FixedTestStruct>) -> String:
  (o, m) = pair
  match m:
    case Some{v}: "S" ++ fts_show(v)
    case None{}: "N"
def v4f_ok(pair: V4F.v4_FixedTestStruct_Seq & Bool) -> String:
  (o, ok) = pair
  O.pick_str(ok)
def v4f_fst(pair: V4F.v4_FixedTestStruct_Seq & Bool) -> V4F.v4_FixedTestStruct_Seq:
  (o, ok) = pair
  o
def v4f_ser(pair: V4F.v4_FixedTestStruct_Seq & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)
def v4f1() -> V4F.v4_FixedTestStruct_Seq: v4f_fst(V4F.v4_FixedTestStruct_set(V4F.v4_FixedTestStruct_default(), 2, fts1()))
def c_v4f() -> String:
  "v4f g4=" ++ v4f_g(V4F.v4_FixedTestStruct_get(V4F.v4_FixedTestStruct_default(), 4)) ++ " s4=" ++ v4f_ok(V4F.v4_FixedTestStruct_set(V4F.v4_FixedTestStruct_default(), 4, fts1())) ++ " g2=" ++ v4f_g(V4F.v4_FixedTestStruct_get(v4f1(), 2)) ++ " g0=" ++ v4f_g(V4F.v4_FixedTestStruct_get(v4f1(), 0)) ++ " ser=" ++ cts_ser(CTSE.ComplexTestStruct_serialize(CTS.ComplexTestStruct_set_f_F(CTS.ComplexTestStruct_default(), v4f1())))
def sts_show(o: STS.SmallTestStruct) -> String:
  match o:
    case STS.SmallTestStruct{+a, +b1}: U32.show(a) ++ "/" ++ U32.show(b1)
def pls_g(pair: PLS.pl_SmallTestStruct_Seq & Maybe<&1, STS.SmallTestStruct>) -> String:
  (o, m) = pair
  match m:
    case Some{v}: "S" ++ sts_show(v)
    case None{}: "N"
def pls_ok(pair: PLS.pl_SmallTestStruct_Seq & Bool) -> String:
  (o, ok) = pair
  O.pick_str(ok)
def pls_fst(pair: PLS.pl_SmallTestStruct_Seq & Bool) -> PLS.pl_SmallTestStruct_Seq:
  (o, ok) = pair
  o
def pls_ser(pair: PLS.pl_SmallTestStruct_Seq & O.Encoded) -> String:
  (o, e) = pair
  enc_str(e)
def pls1() -> PLS.pl_SmallTestStruct_Seq: pls_fst(PLS.pl_SmallTestStruct_append(pls_fst(PLS.pl_SmallTestStruct_append(PLS.pl_SmallTestStruct_default(), STS.SmallTestStruct{1, 2})), STS.SmallTestStruct{3, 4}))
def c_pls() -> String:
  "pls g2=" ++ pls_g(PLS.pl_SmallTestStruct_get(pls1(), 2)) ++ " s2=" ++ pls_ok(PLS.pl_SmallTestStruct_set(pls1(), 2, STS.SmallTestStruct{9, 9})) ++ " g1=" ++ pls_g(PLS.pl_SmallTestStruct_get(pls1(), 1)) ++ " g1s=" ++ pls_g(PLS.pl_SmallTestStruct_get(pls_fst(PLS.pl_SmallTestStruct_set(pls1(), 1, STS.SmallTestStruct{7, 8})), 1)) ++ " g0s=" ++ pls_g(PLS.pl_SmallTestStruct_get(pls_fst(PLS.pl_SmallTestStruct_set(pls1(), 1, STS.SmallTestStruct{7, 8})), 0)) ++ " ser=" ++ pts_ser(PTSE.ProgressiveTestStruct_serialize(PTS.ProgressiveTestStruct_set_f_C(PTS.ProgressiveTestStruct_default(), pls_fst(PLS.pl_SmallTestStruct_set(pls1(), 1, STS.SmallTestStruct{7, 8})))))

# ---- union selectors
def ubc(pair: UBC.CompatibleUnionBC & U32) -> String:
  (o, +s) = pair
  U32.show(s)
def uabca(pair: UABCA.CompatibleUnionABCA & U32) -> String:
  (o, +s) = pair
  U32.show(s)
def ua(pair: UA.CompatibleUnionA & U32) -> String:
  (o, +s) = pair
  U32.show(s)
def c_sel() -> String:
  "sel A=" ++ ua(UA.CompatibleUnionA_selector(UA.CompatibleUnionA_default())) ++ " BC=" ++ ubc(UBC.CompatibleUnionBC_selector(UBC.CompatibleUnionBC_default())) ++ " ABCA=" ++ uabca(UABCA.CompatibleUnionABCA_selector(UABCA.CompatibleUnionABCA_default()))

def dispatch(+c: U32) -> String:
  match c:
    case 1: c_v5u16()
    case 2: c_v513u16()
    case 3: c_v513u8()
    case 4: c_v31u32()
    case 5: c_v3u64()
    case 6: c_v3u128()
    case 7: c_v31u128()
    case 8: c_v5u256()
    case 9: c_v5b()
    case 10: c_v513b()
    case 11: c_pl32()
    case 12: c_pl64()
    case 13: c_pl128()
    case 14: c_pl256()
    case 15: c_plb()
    case 16: c_bv1281()
    case 17: c_bv1280()
    case 18: c_fts()
    case 19: c_sts()
    case 20: c_v4f()
    case 21: c_pls()
    case _: c_sel()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    IO.print(dispatch(c))
