import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/Fulu_list_bytevec_32_16777216_encode_ssz_generated.bend as L32
import ../../../../../types/list_uint16_128_encode_ssz_generated.bend as L16
import ../../../../../types/Fulu_vec_uint64_8192_encode_ssz_generated.bend as V8
import ../../../../../types/uint16_decode_ssz_generated.bend as U16R
import ../../../../../types/bitlist_9_decode_ssz_generated.bend as B9R
import ../../../../../types/bitlist_9_encode_ssz_generated.bend as B9E
import ../../../../../types/bitlist_9_hashtreeroot_generated.bend as B9H
import ../../../../../types/bitlist_33_decode_ssz_generated.bend as B33R
import ../../../../../types/bitlist_33_encode_ssz_generated.bend as B33E
import ../../../../../types/bitlist_33_hashtreeroot_generated.bend as B33H
import ../../../../../types/CompatibleUnionABCA_def_generated.bend as CD
import ../../../../../types/CompatibleUnionABCA_decode_ssz_generated.bend as CR
import ../../../../../types/CompatibleUnionABCA_encode_ssz_generated.bend as CE
import ../../../../../types/ProgressiveSingleListContainerTestStruct_def_generated.bend as SL
import ../../../../../types/FuluExecutionPayload_def_generated.bend as XD
import ../../../../../types/FuluExecutionPayload_encode_ssz_generated.bend as XE
import ../../../../../types/Fulu_list_Withdrawal_16_def_generated.bend as WL
import ../../../../../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as PF
import ../../../../../types/ProgressiveSingleListContainerTestStruct_def_generated.bend as PL
import ../../../../../types/ProgressiveVarTestStruct_def_generated.bend as PV
import ../../../../../types/CompatibleUnionABCA_hashtreeroot_generated.bend as CH
import ../../../../../types/FuluWithdrawal_def_generated.bend as WD
import ../../../../../types/boolean_decode_ssz_generated.bend as BoR
import ../../../../../types/uint64_decode_ssz_generated.bend as U64R
import ../../../../../types/uint64_hashtreeroot_generated.bend as U64H
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_decode_ssz_generated.bend as TL
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: public X_valid / X_decode / X_serialize / X_hash_tree_root of small types (survivors of areas x02, x09, x11, u01, l01, p01).
# SSZ_CASE: 1 List[Bytes32] valid of Words{3 words, 16 bytes}; 2 List[uint16, 128] valid of Words{1 word, 3 bytes}; 3 uint16 decode of bytes 01 02;
# 4 Bitlist[9] decode of ff 03 then serialize; 5 same then valid; 6 same then root; 7 Bitlist[33] decode of ff ff 1f then serialize; 8 same, root;
# 9 Bitlist[33] decode of ff ff 1f, valid; 10 Bitlist[9] decode ab 01, root; 11 union decode of 00 05; 12 union decode of 01 07;
# 13 union decode of Buf{[1], 0} size 0; 14 union with an invalid arm-1 payload, serialize; 15 ExecutionPayload with withdrawals claiming 17 elements, serialize;
# 16 Vector[uint64, 8192] valid of Words{2 words, 8 bytes}; 17 union decode of 01 02; 18 union decode of 04 09.

def pr_digest(label: String, d: D.Digest) -> IO(Unit):
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}:
      IO.print(label ++ " root=" ++ U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h))

def vflag(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def bflag(label: String, pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def ck(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  match k:
    case 0n:
      (ws, +w) = pair
      (ws, (acc + (w * (i + 1 : U32) : U32) : U32))
    case 1n+q:
      (ws, +w) = pair
      ck(q, (i + 1 : U32), (acc + (w * (i + 1 : U32) : U32) : U32), Array.get(U32, ws, (i + 1 : U32)))

def ckz(empty: Bool, ws: Array<U32>, +n: U32) -> Array<U32> & U32:
  match empty:
    case True{}: (ws, 0)
    case False{}: ck(U32.to_nat((U32.shrn((n + 3 : U32), 2n) - 1 : U32)), 0, 0, Array.get(U32, ws, 0))

def ckfin(+n: U32, pair: Array<U32> & U32) -> U32 & U32:
  (ws, +c) = pair
  (n, c)

def ckinfo(b: B.Buf) -> U32 & U32:
  match b:
    case B.Buf{ws, +n}: ckfin(n, ckz(U32.is_eq(n, 0), ws, n))

def show_ck(label: String, ok: Bool, pair: U32 & U32) -> IO(Unit):
  (+n, +c) = pair
  IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(c))

def show_enc(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: show_ck(label, ok, ckinfo(b))

def ser9(label: String, pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: show_enc(label, Pair.snd(O.Bits, O.Encoded, B9E.bitlist_9_serialize(o)))
    case None{}: IO.print(label ++ " none")

def val9(label: String, pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: bflag(label, B9E.bits9_valid(o))
    case None{}: IO.print(label ++ " none")

def root9_fin(label: String, pair: B.Buf & (O.Bits & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  pr_digest(label, d)

def root9(label: String, pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: root9_fin(label, B9H.bitlist_9_hash_tree_root(O.hasher(), o))
    case None{}: IO.print(label ++ " none")

def ser33(label: String, pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: show_enc(label, Pair.snd(O.Bits, O.Encoded, B33E.bitlist_33_serialize(o)))
    case None{}: IO.print(label ++ " none")

def val33(label: String, pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: bflag(label, B33E.bits33_valid(o))
    case None{}: IO.print(label ++ " none")

def root33_fin(label: String, pair: B.Buf & (O.Bits & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  pr_digest(label, d)

def root33(label: String, pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: root33_fin(label, B33H.bitlist_33_hash_tree_root(O.hasher(), o))
    case None{}: IO.print(label ++ " none")

def u16show(label: String, pair: B.Buf & Maybe<&1, U32>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{+v}: IO.print(label ++ "=" ++ U32.show(v))
    case None{}: IO.print(label ++ "=none")

def ushow(label: String, pair: B.Buf & Maybe<&1, CD.CompatibleUnionABCA>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")

def ser_u(label: String, pair: CD.CompatibleUnionABCA & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show_enc(label, e)

def ser_x(label: String, pair: XD.ExecutionPayload & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show_enc(label, e)

def buf1(+w: U32, +n: U32) -> B.Buf: B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, w), n}

def c1() -> IO(Unit): vflag("b32_16", L32.l16777216_b32_valid(O.Words{Array.new(U32, 3n, 0), 16}))
def c2() -> IO(Unit): vflag("u16_3", L16.l128_u16_valid(O.Words{Array.new(U32, 1n, 0), 3}))
def c3() -> IO(Unit): u16show("u16_dec", U16R.uint16_decode(buf1(513, 2), 2))
def c4() -> IO(Unit): ser9("bl9_ff03_ser", B9R.bitlist_9_decode(buf1(1023, 2), 2))
def c5() -> IO(Unit): val9("bl9_ff03", B9R.bitlist_9_decode(buf1(1023, 2), 2))
def c6() -> IO(Unit): root9("bl9_ff03", B9R.bitlist_9_decode(buf1(1023, 2), 2))
def c7() -> IO(Unit): ser33("bl33_ser", B33R.bitlist_33_decode(buf1(2097151, 3), 3))
def c8() -> IO(Unit): root33("bl33", B33R.bitlist_33_decode(buf1(2097151, 3), 3))
def c9() -> IO(Unit): val33("bl33", B33R.bitlist_33_decode(buf1(2097151, 3), 3))
def c10() -> IO(Unit): root9("bl9_ab01", B9R.bitlist_9_decode(buf1(427, 2), 2))
def c11() -> IO(Unit): ushow("union_00_05", CR.CompatibleUnionABCA_decode(buf1(1280, 2), 2))
def c12() -> IO(Unit): ushow("union_01_07", CR.CompatibleUnionABCA_decode(buf1(1793, 2), 2))
def c13() -> IO(Unit): ushow("union_empty_win", CR.CompatibleUnionABCA_decode(buf1(1, 0), 0))
def c14() -> IO(Unit): ser_u("union_bad_arm1", CE.CompatibleUnionABCA_serialize(CD.CompatibleUnionABCA_c1{SL.ProgressiveSingleListContainerTestStruct{O.Bits{Array.new(U32, 0n, 0), 100000}}}))
def c15() -> IO(Unit): ser_x("payload_17_withdrawals", XE.ExecutionPayload_serialize(XD.ExecutionPayload_set_withdrawals(XD.ExecutionPayload_default(), WL.l16_Withdrawal_Seq{WL.l16_Withdrawal_fill(5n), 17})))
def c16() -> IO(Unit): vflag("v8192_8bytes", V8.v8192_u64_valid(O.Words{Array.new(U32, 1n, 0), 8}))
def c17() -> IO(Unit): ushow("union_01_02", CR.CompatibleUnionABCA_decode(buf1(513, 2), 2))
def c18() -> IO(Unit): ushow("union_04_09", CR.CompatibleUnionABCA_decode(buf1(2308, 2), 2))

def wd_fill(+k: Nat, o: WL.l16_Withdrawal_Seq) -> WL.l16_Withdrawal_Seq:
  match k:
    case 0n: o
    case 1n+q: wd_fill(q, Pair.fst(WL.l16_Withdrawal_Seq, Bool, WL.l16_Withdrawal_append(o, WD.Withdrawal_default())))

def two_buf() -> B.Buf: B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 3), 5}

def uroot(label: String, pair: B.Buf & (CD.CompatibleUnionABCA & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  pr_digest(label, d)

def u0() -> CD.CompatibleUnionABCA: CD.CompatibleUnionABCA_c0{PF.ProgressiveSingleFieldContainerTestStruct{7}}
def u1() -> CD.CompatibleUnionABCA: CD.CompatibleUnionABCA_c1{PL.ProgressiveSingleListContainerTestStruct_default()}
def u2() -> CD.CompatibleUnionABCA: CD.CompatibleUnionABCA_c2{PV.ProgressiveVarTestStruct_default()}
def u3() -> CD.CompatibleUnionABCA: CD.CompatibleUnionABCA_c3{PF.ProgressiveSingleFieldContainerTestStruct{9}}

def c19() -> IO(Unit): ser33("bl33_33bits_ser", B33R.bitlist_33_decode(two_buf(), 5))
def c20() -> IO(Unit): root33("bl33_33bits", B33R.bitlist_33_decode(two_buf(), 5))
def c21() -> IO(Unit): ser_x("payload_3_withdrawals", XE.ExecutionPayload_serialize(XD.ExecutionPayload_set_withdrawals(XD.ExecutionPayload_default(), wd_fill(3n, WL.l16_Withdrawal_default()))))
def c22() -> IO(Unit): ser_x("payload_16_withdrawals", XE.ExecutionPayload_serialize(XD.ExecutionPayload_set_withdrawals(XD.ExecutionPayload_default(), wd_fill(16n, WL.l16_Withdrawal_default()))))
def c24() -> IO(Unit): ser_u("union_arm0", CE.CompatibleUnionABCA_serialize(u0()))
def c25() -> IO(Unit): ser_u("union_arm1", CE.CompatibleUnionABCA_serialize(u1()))
def c26() -> IO(Unit): ser_u("union_arm2", CE.CompatibleUnionABCA_serialize(u2()))
def c27() -> IO(Unit): ser_u("union_arm3", CE.CompatibleUnionABCA_serialize(u3()))
def c28() -> IO(Unit): uroot("union_root0", CH.CompatibleUnionABCA_hash_tree_root(O.hasher(), u0()))
def c29() -> IO(Unit): uroot("union_root1", CH.CompatibleUnionABCA_hash_tree_root(O.hasher(), u1()))
def c30() -> IO(Unit): uroot("union_root2", CH.CompatibleUnionABCA_hash_tree_root(O.hasher(), u2()))
def c31() -> IO(Unit): uroot("union_root3", CH.CompatibleUnionABCA_hash_tree_root(O.hasher(), u3()))


def ckb2fin(+n: U32, pair: Array<U32> & U32) -> B.Buf & (U32 & U32):
  (ws, +c) = pair
  (B.Buf{ws, n}, (n, c))

def ckb2(b: B.Buf) -> B.Buf & (U32 & U32):
  match b:
    case B.Buf{ws, +n}: ckb2fin(n, ckz(U32.is_eq(n, 0), ws, n))

def rt_dec(label: String, pair: B.Buf & Maybe<&1, CD.CompatibleUnionABCA>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: ser_u(label ++ " reser", CE.CompatibleUnionABCA_serialize(v))
    case None{}: IO.print(label ++ " none")

def rt_b(label: String, +n: U32, +c: U32, b: B.Buf) -> IO(Unit): rt_dec(label ++ " enc_size=" ++ U32.show(n) ++ " enc_ck=" ++ U32.show(c), CR.CompatibleUnionABCA_decode(b, n))

def rt_a0(label: String, r: U32 & U32, b: B.Buf) -> IO(Unit):
  (+n, +c) = r
  rt_b(label, n, c, b)

def rt_a(label: String, pair: B.Buf & (U32 & U32)) -> IO(Unit):
  (b, r) = pair
  rt_a0(label, r, b)

def rt(label: String, pair: CD.CompatibleUnionABCA & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: rt_a(label, ckb2(b))

def bo_show(label: String, pair: B.Buf & Maybe<&1, Bool>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some " ++ O.pick_str(v))
    case None{}: IO.print(label ++ "=none")

def u64_fin(label: String, pair: B.Buf & D.Digest) -> IO(Unit):
  (b, d) = pair
  pr_digest(label, d)

def u64_show(label: String, pair: B.Buf & Maybe<&1, O.U64>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: u64_fin(label, U64H.uint64_hash_tree_root(O.hasher(), v))
    case None{}: IO.print(label ++ "=none")

def ok_show(label: String, pair: B.Buf & Bool) -> IO(Unit):
  (b, ok) = pair
  IO.print(label ++ " ok=" ++ O.pick_str(ok))

def tx_fill(b: B.Buf) -> B.Buf:
  match b:
    case B.Buf{ws, +n}: B.Buf{Array.set(U32, Array.set(U32, ws, 0, 8), 1, 9), n}

def tx_buf() -> B.Buf: tx_fill(B.alloc(1048586))

def seeds(+k: Nat, +x: U32, o: WL.l16_Withdrawal_Seq) -> WL.l16_Withdrawal_Seq:
  match k:
    case 0n: o
    case 1n+q: seeds(q, (x + 1 : U32), Pair.fst(WL.l16_Withdrawal_Seq, Bool, WL.l16_Withdrawal_append(o, WD.Withdrawal_seed(x))))

def c46() -> IO(Unit): ser_u("union_arm1_junk_bits", CE.CompatibleUnionABCA_serialize(CD.CompatibleUnionABCA_c1{SL.ProgressiveSingleListContainerTestStruct{O.Bits{Array.set(U32, Array.new(U32, 0n, 0), 0, 255), 3}}}))

def c32() -> IO(Unit): rt_dec("union_dec_04_09", CR.CompatibleUnionABCA_decode(buf1(2308, 2), 2))
def c33() -> IO(Unit): rt("rt_arm2", CE.CompatibleUnionABCA_serialize(u2()))
def c34() -> IO(Unit): rt("rt_arm1", CE.CompatibleUnionABCA_serialize(u1()))
def c35() -> IO(Unit): rt("rt_arm0", CE.CompatibleUnionABCA_serialize(u0()))
def c36() -> IO(Unit): rt("rt_arm3", CE.CompatibleUnionABCA_serialize(u3()))
def c37() -> IO(Unit): ser9("bl9_ab00", B9R.bitlist_9_decode(buf1(171, 2), 2))
def c38() -> IO(Unit): ser9("bl9_ff07", B9R.bitlist_9_decode(buf1(2047, 2), 2))
def c40() -> IO(Unit): bo_show("bool_02", BoR.boolean_decode(buf1(2, 1), 1))
def c41() -> IO(Unit): bo_show("bool_01", BoR.boolean_decode(buf1(1, 1), 1))
def c42() -> IO(Unit): bo_show("bool_00", BoR.boolean_decode(buf1(0, 1), 1))
def c43() -> IO(Unit): u64_show("u64_dec", U64R.uint64_decode(B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 67305985), 1, 134678021), 8}, 8))
def c44() -> IO(Unit): ok_show("txlist_2nd_oversize", TL.l1048576_bl1073741824_ok(tx_buf(), 0, 1048586))
def c45() -> IO(Unit): ser_x("payload_3_seeded_withdrawals", XE.ExecutionPayload_serialize(XD.ExecutionPayload_set_withdrawals(XD.ExecutionPayload_default(), seeds(3n, 5, WL.l16_Withdrawal_default()))))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 5: c5()
    case 6: c6()
    case 7: c7()
    case 8: c8()
    case 9: c9()
    case 10: c10()
    case 11: c11()
    case 12: c12()
    case 13: c13()
    case 14: c14()
    case 15: c15()
    case 16: c16()
    case 17: c17()
    case 18: c18()
    case 19: c19()
    case 20: c20()
    case 21: c21()
    case 22: c22()
    case 24: c24()
    case 25: c25()
    case 26: c26()
    case 27: c27()
    case 28: c28()
    case 29: c29()
    case 30: c30()
    case 31: c31()
    case 32: c32()
    case 33: c33()
    case 34: c34()
    case 35: c35()
    case 36: c36()
    case 37: c37()
    case 38: c38()
    case 40: c40()
    case 41: c41()
    case 42: c42()
    case 43: c43()
    case 44: c44()
    case 45: c45()
    case _: c46()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
