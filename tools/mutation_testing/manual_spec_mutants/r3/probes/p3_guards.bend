import Base
import ../../../../../src/obj.bend as O
import ../../../../../types/proglist_uint32_def_generated.bend as P32
import ../../../../../types/proglist_bool_def_generated.bend as PB
import ../../../../../types/Fulu_list_uint8_1099511627776_def_generated.bend as L8
import ../../../../../types/FuluTransaction_def_generated.bend as TX
import ../../../../../types/Fulu_list_Validator_1099511627776_def_generated.bend as LV
import ../../../../../types/FuluValidator_def_generated.bend as VD
import ../../../../../types/proglist_SmallTestStruct_def_generated.bend as PS
import ../../../../../types/FuluProposerSlashing_def_generated.bend as PD
import ../../../../../types/SmallTestStruct_def_generated.bend as SM
import ../../../../../types/Fulu_list_ProposerSlashing_16_def_generated.bend as LP
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: the append guards of the list kinds, through the public X_append and X_len on (1) objects built with the public
# record constructors (a claimed length over tiny storage) and (2) honest objects (List[ProposerSlashing, 16]).
# SSZ_CASE: 1 ProgressiveList[uint32] claiming 1073741816 elements; 2 ProgressiveList[boolean] claiming 4294967264 elements; 3 List[uint8, 2^40]
# claiming 4294967264; 4 Transaction claiming 2^30 bytes; 5 Transaction of 10 bytes, append 256; 6 List[Validator, 2^40] claiming 2^32 - 1;
# 7 ProgressiveList[SmallTestStruct] claiming 2^32 - 1; 8 List[ProposerSlashing, 16] after 16 honest appends, the 17th; 9 the same, the 16th.

def flag_len(label: String, ok: Bool, +n: U32) -> IO(Unit): IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " len=" ++ U32.show(n))

def r32(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(O.Words, U32, P32.pl_u32_len(o)))

def rb(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(O.Words, U32, PB.pl_bool_len(o)))

def r8(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(O.Words, U32, L8.l1099511627776_u8_len(o)))

def rtx(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(O.Words, U32, TX.bl1073741824_len(o)))

def rv(label: String, pair: LV.l1099511627776_Validator_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(LV.l1099511627776_Validator_Seq, U32, LV.l1099511627776_Validator_len(o)))

def rs(label: String, pair: PS.pl_SmallTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(PS.pl_SmallTestStruct_Seq, U32, PS.pl_SmallTestStruct_len(o)))

def rp(label: String, pair: LP.l16_ProposerSlashing_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  flag_len(label, ok, Pair.snd(LP.l16_ProposerSlashing_Seq, U32, LP.l16_ProposerSlashing_len(o)))

def fill_p(+k: Nat, o: LP.l16_ProposerSlashing_Seq) -> LP.l16_ProposerSlashing_Seq:
  match k:
    case 0n: o
    case 1n+q: fill_p(q, Pair.fst(LP.l16_ProposerSlashing_Seq, Bool, LP.l16_ProposerSlashing_append(o, PD.ProposerSlashing_default())))

def c1() -> IO(Unit): r32("u32_claim_1073741816", P32.pl_u32_append(O.Words{Array.new(U32, 4n, 0), 4294967264}, 7))
def c2() -> IO(Unit): rb("bool_claim_4294967264", PB.pl_bool_append(O.Words{Array.new(U32, 4n, 0), 4294967264}, True{}))
def c3() -> IO(Unit): r8("u8_claim_4294967264", L8.l1099511627776_u8_append(O.Words{Array.new(U32, 4n, 0), 4294967264}, 5))
def c4() -> IO(Unit): rtx("tx_claim_2^30", TX.bl1073741824_append(O.Words{Array.new(U32, 4n, 0), 1073741824}, 7))
def c5() -> IO(Unit): rtx("tx_value_256", TX.bl1073741824_append(O.Words{Array.new(U32, 4n, 0), 10}, 256))
def c6() -> IO(Unit): rv("validator_claim_max", LV.l1099511627776_Validator_append(LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(0n), 4294967295}, VD.Validator_default()))
def c7() -> IO(Unit): rs("small_claim_max", PS.pl_SmallTestStruct_append(PS.pl_SmallTestStruct_Seq{PS.pl_SmallTestStruct_fill(0n), 4294967295}, SM.SmallTestStruct_default()))
def c8() -> IO(Unit): rp("slashing_17th", LP.l16_ProposerSlashing_append(fill_p(16n, LP.l16_ProposerSlashing_default()), PD.ProposerSlashing_default()))
def c9() -> IO(Unit): rp("slashing_16th", LP.l16_ProposerSlashing_append(fill_p(15n, LP.l16_ProposerSlashing_default()), PD.ProposerSlashing_default()))

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
    case _: c9()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
