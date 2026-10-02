import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluAttesterSlashing_def_generated.bend as AsD
import ../../types/FuluAttesterSlashing_encode_ssz_generated.bend as AsE
import ../../types/FuluIndexedAttestation_def_generated.bend as IaD
import ../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 3 (docs/CRASH_HUNT.md CH-12): a container with an absent box (the empty box, O.BNone) is not valid and `_serialize`
# refuses it. SSZ_CASE selects the case; each prints one line. 1: attestation_1 absent, 2: attestation_2 absent, 3: both absent,
# 4: the default (control), 5: `_valid` of attestation_1 absent, 6: IndexedAttestation inside present and absent boxes.

def ser_line(label: String, pair: AsD.AttesterSlashing & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))

def valid_line(label: String, pair: AsD.AttesterSlashing & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def none() -> O.Boxed<IaD.IndexedAttestation>: O.BNone{}
def dflt() -> O.Boxed<IaD.IndexedAttestation>: IaD.IndexedAttestation_bx_default()

def c1() -> IO(Unit): ser_line("attestation_1_absent", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing{none(), dflt()}))
def c2() -> IO(Unit): ser_line("attestation_2_absent", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing{dflt(), none()}))
def c3() -> IO(Unit): ser_line("both_absent", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing{none(), none()}))
def c4() -> IO(Unit): ser_line("default", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing_default()))
def c5() -> IO(Unit): valid_line("attestation_1_absent", AsE.AttesterSlashing_valid(AsD.AttesterSlashing{none(), dflt()}))

def m_fin(label: String, pair: AsD.AttesterSlashing & U32) -> IO(Unit):
  (o, +m) = pair
  IO.print(label ++ " m=" ++ U32.show(m))
def m_line(label: String, pair: Array<U32> & (AsD.AttesterSlashing & U32)) -> IO(Unit):
  (out, r) = pair
  m_fin(label, r)
def c6() -> IO(Unit): m_line("putk_attestation_1_absent", AsE.AttesterSlashing_putk(O.out_new(236), 0, AsD.AttesterSlashing{none(), dflt()}))
def c7() -> IO(Unit): IO.print("is_poisoned=" ++ O.pick_str(O.is_poisoned(2147483884)))
def sp_line(label: String, pair: AsD.AttesterSlashing & O.Encoded) -> IO(Unit): ser_line(label, pair)
def c8() -> IO(Unit): sp_line("senc_put", AsE.AttesterSlashing_senc_put(236, AsE.AttesterSlashing_putk(O.out_new(236), 0, AsD.AttesterSlashing{none(), dflt()})))
def c9() -> IO(Unit): sp_line("senc_go", AsE.AttesterSlashing_senc_go(False{}, 236, AsD.AttesterSlashing{none(), dflt()}))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 6: c6()
    case 7: c7()
    case 8: c8()
    case 9: c9()
    case _: c5()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
