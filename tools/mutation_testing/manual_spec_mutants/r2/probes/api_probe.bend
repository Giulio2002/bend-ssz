import Base
import ../../../../../src/obj.bend as O
import ../../../../../types/bytelist_256_def_generated.bend as BL
import ../../../../../types/bitlist_9_def_generated.bend as BB
import ../../../../../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as WL
import ../../../../../types/FuluWithdrawalRequest_def_generated.bend as WD
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-2 API probe: the public collection operations (X_append, X_set, X_get, X_len) of three collection shapes, driven only through
# those entry points. SSZ_CASE selects one observation; each prints one line. The expected line of every case is in api_probe_expected.txt
# (the unmutated tree). The reference corpus cannot reach these operations: it only decodes, re-encodes and hashes.

def flag_s(label: String, +ok: Bool) -> IO(Unit): IO.print(label ++ "=" ++ O.pick_str(ok))
def flag_p(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_s(label, ok)
def len_p(label: String, pair: O.Words & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def get_p(label: String, pair: O.Words & Maybe<&1, U32>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{+v}: IO.print(label ++ "=some " ++ U32.show(v))
    case None{}: IO.print(label ++ "=none")

def bl_fill(+k: Nat, +i: U32, o: O.Words) -> O.Words:
  match k:
    case 0n: o
    case 1n+q: bl_fill(q, (i + 1 : U32), Pair.fst(O.Words, Bool, BL.bl256_append(o, (i .&. 127 : U32))))
def bl_n(+k: Nat) -> O.Words: bl_fill(k, 0, BL.bl256_default())

def c1() -> IO(Unit): flag_p("bl_append_257th", BL.bl256_append(bl_n(256n), 7))
def c2() -> IO(Unit): len_p("bl_len_after_257th", BL.bl256_len(Pair.fst(O.Words, Bool, BL.bl256_append(bl_n(256n), 7))))
def c3() -> IO(Unit): get_p("bl_get_at_len", BL.bl256_get(bl_n(256n), 256))
def c4() -> IO(Unit): flag_p("bl_set_at_len", BL.bl256_set(bl_n(256n), 256, 9))
def c5() -> IO(Unit): flag_p("bl_set_value_300", BL.bl256_set(bl_n(10n), 5, 300))
def c6() -> IO(Unit): flag_p("bl_append_value_256", BL.bl256_append(bl_n(10n), 256))
def c7() -> IO(Unit): flag_p("bl_append_256th", BL.bl256_append(bl_n(255n), 7))
def c8() -> IO(Unit): len_p("bl_len_after_3", BL.bl256_len(bl_n(3n)))
def c9() -> IO(Unit): get_p("bl_get_2_after_3", BL.bl256_get(bl_n(3n), 2))
def c10() -> IO(Unit): get_p("bl_get_39_after_40", BL.bl256_get(bl_n(40n), 39))
def c11() -> IO(Unit): get_p("bl_get_130_after_200", BL.bl256_get(bl_n(200n), 130))
def c12() -> IO(Unit): get_p("bl_get_at_len_3", BL.bl256_get(bl_n(3n), 3))
def c13() -> IO(Unit): flag_p("bl_set_value_255", BL.bl256_set(bl_n(10n), 5, 255))
def c14() -> IO(Unit): flag_p("bl_append_value_255", BL.bl256_append(bl_n(10n), 255))

def bb_fill(+k: Nat, o: O.Bits) -> O.Bits:
  match k:
    case 0n: o
    case 1n+q: bb_fill(q, Pair.fst(O.Bits, Bool, BB.bits9_append(o, True{})))
def bb_n(+k: Nat) -> O.Bits: bb_fill(k, BB.bits9_default())
def bflag(label: String, pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_s(label, ok)
def blen(label: String, pair: O.Bits & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def bget(label: String, pair: O.Bits & Maybe<&1, Bool>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{b}: IO.print(label ++ "=some " ++ O.pick_str(b))
    case None{}: IO.print(label ++ "=none")
def c20() -> IO(Unit): bflag("bits_append_10th", BB.bits9_append(bb_n(9n), True{}))
def c21() -> IO(Unit): bflag("bits_append_9th", BB.bits9_append(bb_n(8n), True{}))
def c22() -> IO(Unit): blen("bits_len_after_10th", BB.bits9_len(Pair.fst(O.Bits, Bool, BB.bits9_append(bb_n(9n), True{}))))
def c23() -> IO(Unit): bflag("bits_set_at_len", BB.bits9_set(bb_n(5n), 5, True{}))
def c24() -> IO(Unit): bget("bits_get_at_len", BB.bits9_get(bb_n(5n), 5))
def c25() -> IO(Unit): bget("bits_get_4_after_5_true", BB.bits9_get(bb_n(5n), 4))
def c26() -> IO(Unit): bget("bits_get_0_after_false_push", BB.bits9_get(Pair.fst(O.Bits, Bool, BB.bits9_append(BB.bits9_default(), False{})), 0))
def c27() -> IO(Unit): blen("bits_len_after_5", BB.bits9_len(bb_n(5n)))

def wl_fill(+k: Nat, o: WL.l16_WithdrawalRequest_Seq) -> WL.l16_WithdrawalRequest_Seq:
  match k:
    case 0n: o
    case 1n+q: wl_fill(q, Pair.fst(WL.l16_WithdrawalRequest_Seq, Bool, WL.l16_WithdrawalRequest_append(o, WD.WithdrawalRequest_default())))
def wl_n(+k: Nat) -> WL.l16_WithdrawalRequest_Seq: wl_fill(k, WL.l16_WithdrawalRequest_default())
def wflag(label: String, pair: WL.l16_WithdrawalRequest_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_s(label, ok)
def wlen(label: String, pair: WL.l16_WithdrawalRequest_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))
def wget(label: String, pair: WL.l16_WithdrawalRequest_Seq & Maybe<&1, WD.WithdrawalRequest>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")
def c30() -> IO(Unit): wflag("wl_append_17th", WL.l16_WithdrawalRequest_append(wl_n(16n), WD.WithdrawalRequest_default()))
def c31() -> IO(Unit): wflag("wl_append_16th", WL.l16_WithdrawalRequest_append(wl_n(15n), WD.WithdrawalRequest_default()))
def c32() -> IO(Unit): wlen("wl_len_after_17th", WL.l16_WithdrawalRequest_len(Pair.fst(WL.l16_WithdrawalRequest_Seq, Bool, WL.l16_WithdrawalRequest_append(wl_n(16n), WD.WithdrawalRequest_default()))))
def c33() -> IO(Unit): wlen("wl_len_after_5", WL.l16_WithdrawalRequest_len(wl_n(5n)))
def c34() -> IO(Unit): wflag("wl_set_at_len", WL.l16_WithdrawalRequest_set(wl_n(5n), 5, WD.WithdrawalRequest_default()))
def c35() -> IO(Unit): wget("wl_get_at_len", WL.l16_WithdrawalRequest_get(wl_n(5n), 5))
def c36() -> IO(Unit): wget("wl_get_last_after_9", WL.l16_WithdrawalRequest_get(wl_n(9n), 8))
def c37() -> IO(Unit): wlen("wl_len_after_16", WL.l16_WithdrawalRequest_len(wl_n(16n)))

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
    case 20: c20()
    case 21: c21()
    case 22: c22()
    case 23: c23()
    case 24: c24()
    case 25: c25()
    case 26: c26()
    case 27: c27()
    case 30: c30()
    case 31: c31()
    case 32: c32()
    case 33: c33()
    case 34: c34()
    case 35: c35()
    case 36: c36()
    case _: c37()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
