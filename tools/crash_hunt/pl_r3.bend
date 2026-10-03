import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluAttestation_def_generated.bend as Att
import ../../types/Fulu_list_Attestation_8_def_generated.bend as L8
import ../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as L8H
import ../../types/Fulu_list_Attestation_8_encode_ssz_generated.bend as L8E
import ../../types/VarTestStruct_def_generated.bend as Vt
import ../../types/vec_VarTestStruct_2_def_generated.bend as V2
import ../../types/vec_VarTestStruct_2_encode_ssz_generated.bend as V2E
import ../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Tx
import ../../types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend as TxE
import ../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 3, probe L: a composite list of boxed elements. SSZ_CASE selects the case, SSZ_ARG its parameter.
#  1: append two default attestations, then: root, valid, get(0), valid, root, get(0) again
#  2: Seq{fill, n} with n absent elements (SSZ_ARG = n): valid, root
#  3: set(i, v) then get(i), valid, root for i = SSZ_ARG over a 2-element list

def rstr(pair: B.Buf & (L8.l8_Attestation_Seq & D.Digest)) -> String & L8.l8_Attestation_Seq:
  (h, r) = pair
  (o, d) = r
  (IOx.words(d), o)

def vstr(pair: L8.l8_Attestation_Seq & Bool) -> String & L8.l8_Attestation_Seq:
  (o, ok) = pair
  (O.pick_str(ok), o)

def gstr(pair: L8.l8_Attestation_Seq & Maybe<&1, Att.Attestation>) -> String & L8.l8_Attestation_Seq:
  (o, m) = pair
  match m:
    case Some{x}: ("some", o)
    case None{}: ("none", o)

def app_fst(pair: L8.l8_Attestation_Seq & Bool) -> L8.l8_Attestation_Seq:
  (o, ok) = pair
  o

def mk2() -> L8.l8_Attestation_Seq: app_fst(L8.l8_Attestation_append(app_fst(L8.l8_Attestation_append(L8.l8_Attestation_default(), Att.Attestation_default())), Att.Attestation_default()))

def root_of(o: L8.l8_Attestation_Seq) -> String & L8.l8_Attestation_Seq: rstr(L8H.l8_Attestation_root(64n, O.hasher(), o, 0))
def valid_of(o: L8.l8_Attestation_Seq) -> String & L8.l8_Attestation_Seq: vstr(L8E.l8_Attestation_valid(o))
def get_of(o: L8.l8_Attestation_Seq, +i: U32) -> String & L8.l8_Attestation_Seq: gstr(L8.l8_Attestation_get(o, i))

def c1e(r0: String, v0: String, g0: String, v1: String, r1: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (g1, o) = pair
  IO.print("root0=" ++ r0 ++ " valid0=" ++ v0 ++ " get0=" ++ g0 ++ " valid_after_get=" ++ v1 ++ " root_after_get=" ++ r1 ++ " get0_again=" ++ g1)
def c1d(r0: String, v0: String, g0: String, v1: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (r1, o) = pair
  c1e(r0, v0, g0, v1, r1, get_of(o, 0))
def c1c(r0: String, v0: String, g0: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (v1, o) = pair
  c1d(r0, v0, g0, v1, root_of(o))
def c1b(r0: String, v0: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (g0, o) = pair
  c1c(r0, v0, g0, valid_of(o))
def c1a(r0: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (v0, o) = pair
  c1b(r0, v0, get_of(o, 0))
def c1_start(pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (r0, o) = pair
  c1a(r0, valid_of(o))
def c1() -> IO(Unit): c1_start(root_of(mk2()))

def c2b(n: U32, v0: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (r0, o) = pair
  IO.print("absent_elems n=" ++ U32.show(n) ++ " valid=" ++ v0 ++ " root=" ++ r0)
def c2a(+n: U32, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (v0, o) = pair
  c2b(n, v0, root_of(o))
def c2(+n: U32) -> IO(Unit): c2a(n, valid_of(L8.l8_Attestation_Seq{L8.l8_Attestation_fill(3n), n}))

def c3d(ok: Bool, g0: String, v0: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (r0, o) = pair
  IO.print("set_ok=" ++ O.pick_str(ok) ++ " get=" ++ g0 ++ " valid=" ++ v0 ++ " root=" ++ r0)
def c3c(ok: Bool, g0: String, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (v0, o) = pair
  c3d(ok, g0, v0, root_of(o))
def c3b(ok: Bool, pair: String & L8.l8_Attestation_Seq) -> IO(Unit):
  (g0, o) = pair
  c3c(ok, g0, valid_of(o))
def c3a(+i: U32, pair: L8.l8_Attestation_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  c3b(ok, get_of(o, i))
def c3(+i: U32) -> IO(Unit): c3a(i, L8.l8_Attestation_set(mk2(), i, Att.Attestation_default()))

# 4: vector of two VarTestStruct (the default holds present elements): valid, get(0), valid
def c4b(g: String, pair: V2.v2_VarTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("vec_get0=" ++ g ++ " valid_after_get=" ++ O.pick_str(ok))
def c4a(pair: V2.v2_VarTestStruct_Seq & Maybe<&1, Vt.VarTestStruct>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{x}: c4b("some", V2E.v2_VarTestStruct_valid(o))
    case None{}: c4b("none", V2E.v2_VarTestStruct_valid(o))
def c4() -> IO(Unit): c4a(V2.v2_VarTestStruct_get(V2.v2_VarTestStruct_default(), 0))

# 5: transactions list: append one empty byte list, valid, get(0), valid
def c5b(g: String, pair: Tx.l1048576_bl1073741824_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("tx_get0=" ++ g ++ " valid_after_get=" ++ O.pick_str(ok))
def c5a(pair: Tx.l1048576_bl1073741824_Seq & Maybe<&1, O.Words>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{x}: c5b("some", TxE.l1048576_bl1073741824_valid(o))
    case None{}: c5b("none", TxE.l1048576_bl1073741824_valid(o))
def c5f(pair: Tx.l1048576_bl1073741824_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  c5a(Tx.l1048576_bl1073741824_get(o, 0))
def c5() -> IO(Unit): c5f(Tx.l1048576_bl1073741824_append(Tx.l1048576_bl1073741824_default(), O.words_new(5)))

def dispatch(+c: U32, +a: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2(a)
    case 3: c3(a)
    case 4: c4()
    case _: c5()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    dispatch(c, a)
