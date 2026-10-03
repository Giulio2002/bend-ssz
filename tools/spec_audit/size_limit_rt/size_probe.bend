import Base
import ../../../src/buffer.bend as B
import ../../../src/obj.bend as O
import ../../../src/digest.bend as D
import ../../../benchmarks/compact/objio.bend as IOx
import ../../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as LPD
import ../../../types/Fulu_list_PendingDeposit_134217728_encode_ssz_generated.bend as LPDE
import ../../../types/Fulu_list_Validator_1099511627776_def_generated.bend as LV
import ../../../types/Fulu_list_Validator_1099511627776_encode_ssz_generated.bend as LVE
import ../../../types/FuluBeaconState_def_generated.bend as BSD
import ../../../types/FuluBeaconState_encode_ssz_generated.bend as BSE
import ../../../types/proglist_uint8_encode_ssz_generated.bend as PlE
import ../../../types/proglist_uint8_hashtreeroot_generated.bend as PlH

# Size-limit runtime probe (tools/spec_audit/size_limit_rt): objects of a given size, with a lazily shared storage tree
# (Array.new at depth 30 / 25 / 26: no case touches the gigabytes it describes unless it writes them). SSZ_CASE picks the case,
# SSZ_N the length (bytes of a byte list, elements of a composite list). Every case prints one line.

def big() -> Array<U32>: Array.new(U32, 30n, 0)
def pds(+n: U32) -> LPD.l134217728_PendingDeposit_Seq: LPD.l134217728_PendingDeposit_Seq{LPD.l134217728_PendingDeposit_fill(25n), n}
def vas(+n: U32) -> LV.l1099511627776_Validator_Seq: LV.l1099511627776_Validator_Seq{LV.l1099511627776_Validator_fill(26n), n}

def size_line(label: String, pair: O.Words & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))

def pd_size_line(label: String, pair: LPD.l134217728_PendingDeposit_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))

def va_size_line(label: String, pair: LV.l1099511627776_Validator_Seq & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))

def enc_len_line(label: String, pair: O.Words & B.Buf) -> IO(Unit):
  (o, b) = pair
  IO.print(label ++ "_len=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))

def last_word(pair: B.Buf & U32) -> U32:
  (b, +w) = pair
  w

def ser_tail(label: String, ok: Bool, b: B.Buf) -> IO(Unit):
  match ok:
    case True{}:
      IO.print(label ++ " ok=1 len=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
    case False{}: IO.print(label ++ " ok=0")

def ser_words(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: ser_tail(label, ok, b)

def bs_pd(+n: U32) -> BSD.BeaconState: Pair.fst(BSD.BeaconState, LPD.l134217728_PendingDeposit_Seq, BSD.BeaconState_swap_pending_deposits(BSD.BeaconState_default(), pds(n)))
def bs_va(+n: U32) -> BSD.BeaconState: Pair.fst(BSD.BeaconState, LV.l1099511627776_Validator_Seq, BSD.BeaconState_swap_validators(BSD.BeaconState_default(), vas(n)))

def ser_bs(label: String, pair: BSD.BeaconState & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: ser_tail(label, ok, b)

def bs_size_line(label: String, pair: BSD.BeaconState & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print(label ++ "=" ++ U32.show(n))

def root_line(label: String, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print(label ++ " root=" ++ IOx.words(d))

def case0(+n: U32) -> IO(Unit): size_line("pl_u8_size", PlE.pl_u8_size(O.Words{big(), n}))
def case1(+n: U32) -> IO(Unit): ser_words("pl_u8_serialize", PlE.proglist_uint8_serialize(O.Words{big(), n}))
def case2(+n: U32) -> IO(Unit): enc_len_line("pl_u8_encode", PlE.proglist_uint8_encode(O.Words{big(), n}))
def case3(+n: U32) -> IO(Unit): root_line("pl_u8_root", PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{big(), n}))
def case4(+n: U32) -> IO(Unit): pd_size_line("pd_size", LPDE.l134217728_PendingDeposit_size(pds(n)))
def case5(+n: U32) -> IO(Unit): ser_bs("bs_pending_deposits_serialize", BSE.BeaconState_serialize(bs_pd(n)))
def case6(+n: U32) -> IO(Unit): va_size_line("va_size", LVE.l1099511627776_Validator_size(vas(n)))
def case7(+n: U32) -> IO(Unit): ser_bs("bs_validators_serialize", BSE.BeaconState_serialize(bs_va(n)))
def case8(+n: U32) -> IO(Unit): bs_size_line("bs_validators_size", BSE.BeaconState_size(bs_va(n)))
def case9(+n: U32) -> IO(Unit): bs_size_line("bs_pending_deposits_size", BSE.BeaconState_size(bs_pd(n)))

def dispatch(+c: U32, +n: U32) -> IO(Unit):
  match c:
    case 0: case0(n)
    case 1: case1(n)
    case 2: case2(n)
    case 3: case3(n)
    case 4: case4(n)
    case 5: case5(n)
    case 6: case6(n)
    case 7: case7(n)
    case 8: case8(n)
    case 9: case9(n)
    case _: IO.print("NOCASE")

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +n : U32 <- IOx.env_u32("SSZ_N")
    dispatch(c, n)
