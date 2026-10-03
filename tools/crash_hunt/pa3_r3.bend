import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../benchmarks/compact/objio.bend as IOx
import ../../types/Fulu_list_Deposit_16_def_generated.bend as D0
import ../../types/Fulu_list_Deposit_16_encode_ssz_generated.bend as E0
import ../../types/Fulu_list_Deposit_16_hashtreeroot_generated.bend as H0
import ../../types/Fulu_list_AttesterSlashing_1_def_generated.bend as D1
import ../../types/Fulu_list_AttesterSlashing_1_encode_ssz_generated.bend as E1
import ../../types/Fulu_list_AttesterSlashing_1_hashtreeroot_generated.bend as H1
import ../../types/Fulu_list_ProposerSlashing_16_def_generated.bend as D2
import ../../types/Fulu_list_ProposerSlashing_16_encode_ssz_generated.bend as E2
import ../../types/Fulu_list_ProposerSlashing_16_hashtreeroot_generated.bend as H2
import ../../types/proglist_proglist_VarTestStruct_def_generated.bend as D3
import ../../types/proglist_proglist_VarTestStruct_encode_ssz_generated.bend as E3
import ../../types/proglist_proglist_VarTestStruct_hashtreeroot_generated.bend as H3
import ../../types/proglist_ProgressiveVarTestStruct_def_generated.bend as D4
import ../../types/proglist_ProgressiveVarTestStruct_encode_ssz_generated.bend as E4
import ../../types/proglist_ProgressiveVarTestStruct_hashtreeroot_generated.bend as H4
import ../../types/proglist_VarTestStruct_def_generated.bend as D5
import ../../types/proglist_VarTestStruct_encode_ssz_generated.bend as E5
import ../../types/proglist_VarTestStruct_hashtreeroot_generated.bend as H5
import ../../types/vec_VarTestStruct_2_def_generated.bend as D6
import ../../types/vec_VarTestStruct_2_encode_ssz_generated.bend as E6
import ../../types/vec_VarTestStruct_2_hashtreeroot_generated.bend as H6
import ../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as D7
import ../../types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend as E7
import ../../types/Fulu_list_bytelist_1073741824_1048576_hashtreeroot_generated.bend as H7
import ../../types/Fulu_list_Attestation_8_def_generated.bend as D8
import ../../types/Fulu_list_Attestation_8_encode_ssz_generated.bend as E8
import ../../types/Fulu_list_Attestation_8_hashtreeroot_generated.bend as H8
import ../../types/list_ProgressiveSingleFieldContainerTestStruct_10_def_generated.bend as D9
import ../../types/list_ProgressiveSingleFieldContainerTestStruct_10_encode_ssz_generated.bend as E9
import ../../types/list_ProgressiveSingleFieldContainerTestStruct_10_hashtreeroot_generated.bend as H9
import ../../types/Fulu_list_SignedVoluntaryExit_16_def_generated.bend as D10
import ../../types/Fulu_list_SignedVoluntaryExit_16_encode_ssz_generated.bend as E10
import ../../types/Fulu_list_SignedVoluntaryExit_16_hashtreeroot_generated.bend as H10

# Crash hunt round 3, probe A: a list / vector of composites whose elements are the empty box (O.BNone): SSZ_CASE selects the module (see the order of
# the imports), SSZ_ARG the count n of the Seq{fill, n}. Prints valid (must be 0 for a list of boxed elements; the unboxed lists have no empty box) and
# whether the root finishes.

def v0(pair: D0.l16_Deposit_Seq & Bool) -> String & D0.l16_Deposit_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r0(+n: U32, vs: String, pair: B.Buf & (D0.l16_Deposit_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l16_Deposit n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w0(+n: U32, pair: String & D0.l16_Deposit_Seq) -> IO(Unit):
  (vs, o) = pair
  r0(n, vs, H0.l16_Deposit_root(64n, O.hasher(), o, 0))
def c0(+n: U32) -> IO(Unit): w0(n, v0(E0.l16_Deposit_valid(D0.l16_Deposit_Seq{D0.l16_Deposit_fill(3n), n})))

def v1(pair: D1.l1_AttesterSlashing_Seq & Bool) -> String & D1.l1_AttesterSlashing_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r1(+n: U32, vs: String, pair: B.Buf & (D1.l1_AttesterSlashing_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l1_AttesterSlashing n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w1(+n: U32, pair: String & D1.l1_AttesterSlashing_Seq) -> IO(Unit):
  (vs, o) = pair
  r1(n, vs, H1.l1_AttesterSlashing_root(64n, O.hasher(), o, 0))
def c1(+n: U32) -> IO(Unit): w1(n, v1(E1.l1_AttesterSlashing_valid(D1.l1_AttesterSlashing_Seq{D1.l1_AttesterSlashing_fill(3n), n})))

def v2(pair: D2.l16_ProposerSlashing_Seq & Bool) -> String & D2.l16_ProposerSlashing_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r2(+n: U32, vs: String, pair: B.Buf & (D2.l16_ProposerSlashing_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l16_ProposerSlashing n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w2(+n: U32, pair: String & D2.l16_ProposerSlashing_Seq) -> IO(Unit):
  (vs, o) = pair
  r2(n, vs, H2.l16_ProposerSlashing_root(64n, O.hasher(), o, 0))
def c2(+n: U32) -> IO(Unit): w2(n, v2(E2.l16_ProposerSlashing_valid(D2.l16_ProposerSlashing_Seq{D2.l16_ProposerSlashing_fill(3n), n})))

def v3(pair: D3.pl_pl_VarTestStruct_Seq & Bool) -> String & D3.pl_pl_VarTestStruct_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r3(+n: U32, vs: String, pair: B.Buf & (D3.pl_pl_VarTestStruct_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("pl_pl_VarTestStruct n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w3(+n: U32, pair: String & D3.pl_pl_VarTestStruct_Seq) -> IO(Unit):
  (vs, o) = pair
  r3(n, vs, H3.pl_pl_VarTestStruct_root(64n, O.hasher(), o, 0))
def c3(+n: U32) -> IO(Unit): w3(n, v3(E3.pl_pl_VarTestStruct_valid(D3.pl_pl_VarTestStruct_Seq{D3.pl_pl_VarTestStruct_fill(3n), n})))

def v4(pair: D4.pl_ProgressiveVarTestStruct_Seq & Bool) -> String & D4.pl_ProgressiveVarTestStruct_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r4(+n: U32, vs: String, pair: B.Buf & (D4.pl_ProgressiveVarTestStruct_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("pl_ProgressiveVarTestStruct n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w4(+n: U32, pair: String & D4.pl_ProgressiveVarTestStruct_Seq) -> IO(Unit):
  (vs, o) = pair
  r4(n, vs, H4.pl_ProgressiveVarTestStruct_root(64n, O.hasher(), o, 0))
def c4(+n: U32) -> IO(Unit): w4(n, v4(E4.pl_ProgressiveVarTestStruct_valid(D4.pl_ProgressiveVarTestStruct_Seq{D4.pl_ProgressiveVarTestStruct_fill(3n), n})))

def v5(pair: D5.pl_VarTestStruct_Seq & Bool) -> String & D5.pl_VarTestStruct_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r5(+n: U32, vs: String, pair: B.Buf & (D5.pl_VarTestStruct_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("pl_VarTestStruct n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w5(+n: U32, pair: String & D5.pl_VarTestStruct_Seq) -> IO(Unit):
  (vs, o) = pair
  r5(n, vs, H5.pl_VarTestStruct_root(64n, O.hasher(), o, 0))
def c5(+n: U32) -> IO(Unit): w5(n, v5(E5.pl_VarTestStruct_valid(D5.pl_VarTestStruct_Seq{D5.pl_VarTestStruct_fill(3n), n})))

def v6(pair: D6.v2_VarTestStruct_Seq & Bool) -> String & D6.v2_VarTestStruct_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r6(+n: U32, vs: String, pair: B.Buf & (D6.v2_VarTestStruct_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("v2_VarTestStruct n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w6(+n: U32, pair: String & D6.v2_VarTestStruct_Seq) -> IO(Unit):
  (vs, o) = pair
  r6(n, vs, H6.v2_VarTestStruct_root(64n, O.hasher(), o, 0))
def c6(+n: U32) -> IO(Unit): w6(n, v6(E6.v2_VarTestStruct_valid(D6.v2_VarTestStruct_Seq{D6.v2_VarTestStruct_fill(3n), n})))

def v7(pair: D7.l1048576_bl1073741824_Seq & Bool) -> String & D7.l1048576_bl1073741824_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r7(+n: U32, vs: String, pair: B.Buf & (D7.l1048576_bl1073741824_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l1048576_bl1073741824 n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w7(+n: U32, pair: String & D7.l1048576_bl1073741824_Seq) -> IO(Unit):
  (vs, o) = pair
  r7(n, vs, H7.l1048576_bl1073741824_root(64n, O.hasher(), o, 0))
def c7(+n: U32) -> IO(Unit): w7(n, v7(E7.l1048576_bl1073741824_valid(D7.l1048576_bl1073741824_Seq{D7.l1048576_bl1073741824_fill(3n), n})))

def v8(pair: D8.l8_Attestation_Seq & Bool) -> String & D8.l8_Attestation_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r8(+n: U32, vs: String, pair: B.Buf & (D8.l8_Attestation_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l8_Attestation n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w8(+n: U32, pair: String & D8.l8_Attestation_Seq) -> IO(Unit):
  (vs, o) = pair
  r8(n, vs, H8.l8_Attestation_root(64n, O.hasher(), o, 0))
def c8(+n: U32) -> IO(Unit): w8(n, v8(E8.l8_Attestation_valid(D8.l8_Attestation_Seq{D8.l8_Attestation_fill(3n), n})))

def v9(pair: D9.l10_ProgressiveSingleFieldContainerTestStruct_Seq & Bool) -> String & D9.l10_ProgressiveSingleFieldContainerTestStruct_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r9(+n: U32, vs: String, pair: B.Buf & (D9.l10_ProgressiveSingleFieldContainerTestStruct_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l10_ProgressiveSingleFieldContainerTestStruct n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w9(+n: U32, pair: String & D9.l10_ProgressiveSingleFieldContainerTestStruct_Seq) -> IO(Unit):
  (vs, o) = pair
  r9(n, vs, H9.l10_ProgressiveSingleFieldContainerTestStruct_root(64n, O.hasher(), o, 0))
def c9(+n: U32) -> IO(Unit): w9(n, v9(E9.l10_ProgressiveSingleFieldContainerTestStruct_valid(D9.l10_ProgressiveSingleFieldContainerTestStruct_Seq{D9.l10_ProgressiveSingleFieldContainerTestStruct_fill(3n), n})))

def v10(pair: D10.l16_SignedVoluntaryExit_Seq & Bool) -> String & D10.l16_SignedVoluntaryExit_Seq:
  (o, ok) = pair
  ("valid=" ++ O.pick_str(ok), o)
def r10(+n: U32, vs: String, pair: B.Buf & (D10.l16_SignedVoluntaryExit_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("l16_SignedVoluntaryExit n=" ++ U32.show(n) ++ " " ++ vs ++ " root=" ++ IOx.words(d))
def w10(+n: U32, pair: String & D10.l16_SignedVoluntaryExit_Seq) -> IO(Unit):
  (vs, o) = pair
  r10(n, vs, H10.l16_SignedVoluntaryExit_root(64n, O.hasher(), o, 0))
def c10(+n: U32) -> IO(Unit): w10(n, v10(E10.l16_SignedVoluntaryExit_valid(D10.l16_SignedVoluntaryExit_Seq{D10.l16_SignedVoluntaryExit_fill(3n), n})))

def dispatch(+c: U32, +a: U32) -> IO(Unit):
  match c:
    case 0: c0(a)
    case 1: c1(a)
    case 2: c2(a)
    case 3: c3(a)
    case 4: c4(a)
    case 5: c5(a)
    case 6: c6(a)
    case 7: c7(a)
    case 8: c8(a)
    case 9: c9(a)
    case _: c10(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    dispatch(c, a)
