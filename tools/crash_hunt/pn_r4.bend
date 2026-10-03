import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/proglist_uint8_def_generated.bend as P8
import ../../types/proglist_uint8_encode_ssz_generated.bend as P8E
import ../../types/proglist_uint8_hashtreeroot_generated.bend as P8H
import ../../types/proglist_uint8_decode_ssz_generated.bend as P8R
import ../../types/proglist_uint16_def_generated.bend as P16
import ../../types/proglist_uint64_encode_ssz_generated.bend as P64E
import ../../types/proglist_uint64_hashtreeroot_generated.bend as P64H
import ../../types/Fulu_list_uint8_1099511627776_encode_ssz_generated.bend as F8E
import ../../types/Fulu_list_uint8_1099511627776_hashtreeroot_generated.bend as F8H
import ../../types/ProgressiveComplexTestStruct_def_generated.bend as PC
import ../../types/ProgressiveComplexTestStruct_encode_ssz_generated.bend as PCE
import ../../types/ProgressiveComplexTestStruct_decode_ssz_generated.bend as PCR
import ../../types/proglist_SmallTestStruct_def_generated.bend as PS
import ../../types/SmallTestStruct_def_generated.bend as SS
import ../../types/FuluPendingPartialWithdrawal_def_generated.bend as PW
import ../../types/Fulu_list_PendingPartialWithdrawal_134217728_def_generated.bend as LPW
import ../../types/proglist_VarTestStruct_def_generated.bend as PV
import ../../types/proglist_proglist_VarTestStruct_def_generated.bend as PP
import ../../types/proglist_proglist_VarTestStruct_encode_ssz_generated.bend as PPE
import ../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 4, probe N: the new size arithmetic (objects of 2^31 .. NMAX = 4294967264 bytes) and the decode window.
# SSZ_CASE picks the case, SSZ_ARG the length or count; SSZ_D, SSZ_K, SSZ_DEPTH extra arguments. Storage of 4 GiB is a lazily
# shared Array.new(U32, 30n, 0): nothing touches the gigabytes it describes unless it writes them.
#  1/2  proglist_uint8 claim ARG in 4 GiB storage, dirty word 2^30-1 / clean: valid, root
#  3/4  proglist_uint64 the same           5/6  List[uint8, 2^40] the same
#  7    proglist_uint8 serialize / encode of a clean 4 GiB-storage claim ARG
#  8    proglist_uint8 append at ARG (4 GiB storage), then serialize the result
#  9    proglist_uint16 append at ARG elements (4 GiB storage)
#  10   ProgressiveComplexTestStruct decode_checked: f_E = ARG zero SmallTestStructs (an honest 4 GiB buffer)
#  11   ProgressiveComplexTestStruct with f_D = SSZ_D bytes (4 GiB storage), f_C = SSZ_K bits: size, valid, serialize, encode
#  12   List[PendingPartialWithdrawal, 2^27]: append to Seq{fill(SSZ_DEPTH), ARG}
#  13   proglist_SmallTestStruct: append to Seq{fill(SSZ_DEPTH), ARG}
#  14   proglist_proglist_VarTestStruct of 2^SSZ_DEPTH honest empty inner lists: size, valid, then PCTS serialize with it as f_F
#  15   proglist_uint8 decode_checked / decode of an honest 4 GiB buffer whose size field is ARG

def big() -> Array<U32>: Array.new(U32, 30n, 0)
def dirty() -> Array<U32>: Array.set(U32, big(), 1073741823, 2864434397)
def wbig(d: Bool, +n: U32) -> O.Words:
  match d:
    case True{}: O.Words{dirty(), n}
    case False{}: O.Words{big(), n}

def vline(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def rline(label: String, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print(label ++ " root=" ++ IOx.words(d))

def c1(d: Bool, +n: U32) -> IO(Unit):
  do IO<Unit>:
    vline("pl_u8", P8E.pl_u8_valid(wbig(d, n)))
    rline("pl_u8", P8H.proglist_uint8_hash_tree_root(O.hasher(), wbig(d, n)))
def c3(d: Bool, +n: U32) -> IO(Unit):
  do IO<Unit>:
    vline("pl_u64", P64E.pl_u64_valid(wbig(d, n)))
    rline("pl_u64", P64H.proglist_uint64_hash_tree_root(O.hasher(), wbig(d, n)))
def c5(d: Bool, +n: U32) -> IO(Unit):
  do IO<Unit>:
    vline("l2^40_u8", F8E.l1099511627776_u8_valid(wbig(d, n)))
    rline("l2^40_u8", F8H.l1099511627776_u8_root(64n, O.hasher(), wbig(d, n), 0))

def ser_tail(label: String, ok: Bool, pair: B.Buf & U32) -> IO(Unit):
  (b, +m) = pair
  IO.print(label ++ " ser_ok=" ++ O.pick_str(ok) ++ " ser_len=" ++ U32.show(m))
def ser_line(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: ser_tail(label, ok, B.size(b))
def enc_tail(label: String, pair: B.Buf & U32) -> IO(Unit):
  (b, +m) = pair
  IO.print(label ++ " enc_len=" ++ U32.show(m))
def enc_line(label: String, pair: O.Words & B.Buf) -> IO(Unit):
  (o, b) = pair
  enc_tail(label, B.size(b))
def c7(+n: U32) -> IO(Unit):
  do IO<Unit>:
    ser_line("pl_u8", P8E.proglist_uint8_serialize(wbig(False{}, n)))
    enc_line("pl_u8", P8E.proglist_uint8_encode(wbig(False{}, n)))

def app_ser(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case O.Words{ws, +n}:
      do IO<Unit>:
        IO.print(label ++ " append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
        ser_line(label, P8E.proglist_uint8_serialize(O.Words{ws, n}))
def c8(+n: U32) -> IO(Unit): app_ser("pl_u8", P8.pl_u8_append(wbig(False{}, n), 7))

def app_line(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case O.Words{ws, +n}: IO.print(label ++ " append_ok=" ++ O.pick_str(ok) ++ " bytes_after=" ++ U32.show(n))
def c9(+n: U32) -> IO(Unit): app_line("pl_u16", P16.pl_u16_append(wbig(False{}, (n * 2 : U32)), 65535))

# ---- ProgressiveComplexTestStruct ----
# fixed part: f_A (1 byte), 7 offsets; f_B empty, f_C the empty bit list (one delimiter byte), f_D empty, f_E m records, f_F f_G f_H empty
def pc_buf(+m: U32) -> Array<U32>:
  O.w8(O.w32(O.w32(O.w32(O.w32(O.w32(O.w32(O.w32(big(), 1, 29), 5, 29), 9, 30), 13, 30), 17, (30 + m * 4 : U32)), 21, (30 + m * 4 : U32)), 25, (30 + m * 4 : U32)), 29, 1)
def fe_len(f: PS.pl_SmallTestStruct_Seq) -> IO(Unit):
  match f:
    case PS.pl_SmallTestStruct_Seq{arr, +n}: IO.print("pcts decode=some f_E_len=" ++ U32.show(n))
def pc_some(v: PC.ProgressiveComplexTestStruct) -> IO(Unit):
  match v:
    case PC.ProgressiveComplexTestStruct{+a, b, c, d, e, f, g, h}: fe_len(e)
def pc_dec(pair: B.Buf & Maybe<&1, PC.ProgressiveComplexTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: pc_some(v)
    case None{}: IO.print("pcts decode=none")
def c10(+m: U32) -> IO(Unit): pc_dec(PCR.ProgressiveComplexTestStruct_decode_checked(B.Buf{pc_buf(m), (30 + m * 4 : U32)}, (30 + m * 4 : U32)))

def pc_mk(+dn: U32, +k: U32) -> PC.ProgressiveComplexTestStruct:
  PC.ProgressiveComplexTestStruct_set_f_D(PC.ProgressiveComplexTestStruct_set_f_C(PC.ProgressiveComplexTestStruct_default(), O.Bits{Array.new(U32, 27n, 0), k}), O.Words{big(), dn})
def pc_size(pair: PC.ProgressiveComplexTestStruct & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print("pcts size=" ++ U32.show(n))
def pc_valid(pair: PC.ProgressiveComplexTestStruct & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("pcts valid=" ++ O.pick_str(ok))
def pc_ser(pair: PC.ProgressiveComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: ser_tail("pcts", ok, B.size(b))
def pc_enc(pair: PC.ProgressiveComplexTestStruct & B.Buf) -> IO(Unit):
  (o, b) = pair
  enc_tail("pcts", B.size(b))
def c11(+dn: U32, +k: U32) -> IO(Unit):
  do IO<Unit>:
    pc_size(PCE.ProgressiveComplexTestStruct_size(pc_mk(dn, k)))
    pc_valid(PCE.ProgressiveComplexTestStruct_valid(pc_mk(dn, k)))
    pc_ser(PCE.ProgressiveComplexTestStruct_serialize(pc_mk(dn, k)))
    pc_enc(PCE.ProgressiveComplexTestStruct_encode(pc_mk(dn, k)))

def pw_line(pair: LPW.l134217728_PendingPartialWithdrawal_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case LPW.l134217728_PendingPartialWithdrawal_Seq{arr, +n}: IO.print("ppw append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
def c12(+n: U32, +d: U32) -> IO(Unit): pw_line(LPW.l134217728_PendingPartialWithdrawal_append(LPW.l134217728_PendingPartialWithdrawal_Seq{LPW.l134217728_PendingPartialWithdrawal_fill(U32.to_nat(d)), n}, PW.PendingPartialWithdrawal_default()))

def ps_line(pair: PS.pl_SmallTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case PS.pl_SmallTestStruct_Seq{arr, +n}: IO.print("pl_small append_ok=" ++ O.pick_str(ok) ++ " len_after=" ++ U32.show(n))
def c13(+n: U32, +d: U32) -> IO(Unit): ps_line(PS.pl_SmallTestStruct_append(PS.pl_SmallTestStruct_Seq{PS.pl_SmallTestStruct_fill(U32.to_nat(d)), n}, SS.SmallTestStruct_default()))

def pp_fill(k: Nat, +i: U32, arr: Array<O.Boxed<PV.pl_VarTestStruct_Seq>>) -> Array<O.Boxed<PV.pl_VarTestStruct_Seq>>:
  match k:
    case 0n: arr
    case 1n+q: pp_fill(q, (i + 1 : U32), Array.set(O.Boxed<PV.pl_VarTestStruct_Seq>, arr, i, PV.pl_VarTestStruct_bx_wrap(PV.pl_VarTestStruct_default())))
def pp_mk(+d: U32) -> PP.pl_pl_VarTestStruct_Seq:
  PP.pl_pl_VarTestStruct_Seq{pp_fill(O.pow2n(U32.to_nat(d)), 0, PP.pl_pl_VarTestStruct_fill(U32.to_nat(d))), O.pow2u(U32.to_nat(d))}
def pp_size(pair: PP.pl_pl_VarTestStruct_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print("pl_pl size=" ++ U32.show(n))
def pp_valid(pair: PP.pl_pl_VarTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("pl_pl valid=" ++ O.pick_str(ok))
def c14(+d: U32) -> IO(Unit):
  do IO<Unit>:
    pp_size(PPE.pl_pl_VarTestStruct_size(pp_mk(d)))
    pp_valid(PPE.pl_pl_VarTestStruct_valid(pp_mk(d)))
    pc_ser(PCE.ProgressiveComplexTestStruct_serialize(PC.ProgressiveComplexTestStruct_set_f_F(PC.ProgressiveComplexTestStruct_default(), pp_mk(d))))

def dec_line(label: String, pair: B.Buf & Maybe<&1, O.Words>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}:
      match v:
        case O.Words{ws, +n}: IO.print(label ++ "=some len=" ++ U32.show(n))
    case None{}: IO.print(label ++ "=none")
def c15(+n: U32) -> IO(Unit):
  do IO<Unit>:
    dec_line("pl_u8 decode_checked", P8R.proglist_uint8_decode_checked(B.Buf{big(), n}, n))
    dec_line("pl_u8 decode", P8R.proglist_uint8_decode(B.Buf{big(), n}, n))

def dispatch(+c: U32, +n: U32, +dn: U32, +k: U32, +dep: U32) -> IO(Unit):
  match c:
    case 1: c1(True{}, n)
    case 2: c1(False{}, n)
    case 3: c3(True{}, n)
    case 4: c3(False{}, n)
    case 5: c5(True{}, n)
    case 6: c5(False{}, n)
    case 7: c7(n)
    case 8: c8(n)
    case 9: c9(n)
    case 10: c10(n)
    case 11: c11(dn, k)
    case 12: c12(n, dep)
    case 13: c13(n, dep)
    case 14: c14(dep)
    case 15: c15(n)
    case _: IO.print("NOCASE")

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +n : U32 <- IOx.env_u32("SSZ_ARG")
    +dn : U32 <- IOx.env_u32("SSZ_D")
    +k : U32 <- IOx.env_u32("SSZ_K")
    +dep : U32 <- IOx.env_u32("SSZ_DEPTH")
    dispatch(c, n, dn, k, dep)
