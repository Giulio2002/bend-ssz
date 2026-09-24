import Base
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../src/digest.bend as D
import ./dk.bend as DK
import ../../spec/codec.bend as Codec

# A root relation at a schema moves along an equation of schemas.
def transport(-v: S.Value, -s: S.Schema, -E: S.Schema, -outs: +List<+List<U32>>, +e: {s == E : S.Schema}, p: RR.roots(v, E, outs)) -> RR.roots(v, s, outs):
  %Equal.sym(S.Schema, s, E, e) : RR.roots(v, _, outs)
  p

# A fact about a part f(s) of a schema variable, from the same fact about the
# schema's value S0 (a per-name law proves the latter by evaluation).
def eq_at(-f: S.Schema -> S.Schema, +s: S.Schema, -S0: S.Schema, -E: S.Schema, +es: {s == S0 : S.Schema}, +h: {f(S0) == E : S.Schema}) -> {f(s) == E : S.Schema}:
  %Equal.sym(S.Schema, s, S0, es) : {f(_) == E : S.Schema}
  h

# A digest known only in types, with a value equal to it.
def DW(d: D.Digest) -> Data:
  DK.Ex(D.Digest, dd => {d == dd : D.Digest})

# A root relation whose single output is a digest's bytes moves along an
# equation of digests (a container computes its chunks from the digest
# witnesses of its fields, which are values, in place of the digests of its
# erased fields).
def dtrans(-v: S.Value, -s: S.Schema, -a: D.Digest, -b: D.Digest, +e: {b == a : D.Digest}, p: RR.roots(v, s, [D.bytes(b)])) -> RR.roots(v, s, [D.bytes(a)]):
  %e : RR.roots(v, s, [D.bytes(_)])
  p

# The value of a digest witness, and its equation (projections, so a law can
# take both from one call).
def dwv(-x: D.Digest, +p: DW(x)) -> D.Digest:
  (+a, +b) = p
  a

def dwe(-x: D.Digest, +p: DW(x)) -> {x == dwv(x, p) : D.Digest}:
  (+a, +b) = p
  b

# Depths of 14 and more, as a record the laws hold as a VARIABLE (with the
# equation dv == DV0()). A law over a schema variable s must not mention a
# closed capacity 2^d for large d: the checker compares two copies of
# `Nat.is_le(<stuck>, capacity(15n))` by unrolling the bound in unary and
# overflows (WORK_LOG, iteration 22, "capacity comparison"). With the depth a
# variable, capacity(dv_15(dv)) stays stuck. Closed schema facts are proved
# once at DV0() (a closed definition evaluates them) and moved by ok_at.
type DV is Data:
  DV{d14: Nat, d15: Nat, d16: Nat, d17: Nat, d18: Nat, d19: Nat, d20: Nat, d21: Nat, d22: Nat, d23: Nat, d24: Nat, d25: Nat, d26: Nat, d27: Nat, d28: Nat, d29: Nat, d30: Nat, d31: Nat, d32: Nat, d33: Nat, d34: Nat, d35: Nat, d36: Nat, d37: Nat, d38: Nat, d39: Nat, d40: Nat}

def DV0() -> DV: DV{14n, 15n, 16n, 17n, 18n, 19n, 20n, 21n, 22n, 23n, 24n, 25n, 26n, 27n, 28n, 29n, 30n, 31n, 32n, 33n, 34n, 35n, 36n, 37n, 38n, 39n, 40n}

def dv_14(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a14
def dv_15(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a15
def dv_16(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a16
def dv_17(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a17
def dv_18(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a18
def dv_19(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a19
def dv_20(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a20
def dv_21(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a21
def dv_22(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a22
def dv_23(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a23
def dv_24(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a24
def dv_25(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a25
def dv_26(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a26
def dv_27(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a27
def dv_28(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a28
def dv_29(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a29
def dv_30(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a30
def dv_31(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a31
def dv_32(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a32
def dv_33(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a33
def dv_34(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a34
def dv_35(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a35
def dv_36(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a36
def dv_37(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a37
def dv_38(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a38
def dv_39(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a39
def dv_40(dv: DV) -> Nat:
  match dv:
    case DV{+a14, +a15, +a16, +a17, +a18, +a19, +a20, +a21, +a22, +a23, +a24, +a25, +a26, +a27, +a28, +a29, +a30, +a31, +a32, +a33, +a34, +a35, +a36, +a37, +a38, +a39, +a40}: a40

# A depth read from the record, at the record DV0().
def dveq(-f: DV -> Nat, +dv: DV, +edv: {dv == DV0() : DV}) -> {f(dv) == f(DV0()) : Nat}:
  %Equal.sym(DV, dv, DV0(), edv) : {f(_) == f(DV0()) : Nat}
  {==}

def dvu(-f: DV -> Nat, +dv: DV, +edv: {dv == DV0() : DV}, +dU: U32, +h: {U32.to_nat(dU) == f(DV0()) : Nat}) -> {U32.to_nat(dU) == f(dv) : Nat}:
  %Equal.sym(DV, dv, DV0(), edv) : {U32.to_nat(dU) == f(_) : Nat}
  h

def dvl(-f: DV -> Nat, +dv: DV, +edv: {dv == DV0() : DV}, +h: {Nat.is_lt(f(DV0()), 64n) == True{} : Bool}) -> {Nat.is_lt(f(dv), 64n) == True{} : Bool}:
  %Equal.sym(DV, dv, DV0(), edv) : {Nat.is_lt(f(_), 64n) == True{} : Bool}
  h

# A closed schema fact at (S0, DV0()) holds at every (s, dv) equal to it.
def ok_at(-f: S.Schema -> DV -> Bool, +s: S.Schema, -S0: S.Schema, +dv: DV, +es: {s == S0 : S.Schema}, +edv: {dv == DV0() : DV}, +h: {f(S0, DV0()) == True{} : Bool}) -> {f(s, dv) == True{} : Bool}:
  %Equal.sym(S.Schema, s, S0, es) : {f(_, dv) == True{} : Bool}
  %Equal.sym(DV, dv, DV0(), edv) : {f(S0, _) == True{} : Bool}
  h

# A list of composite elements (basic_size of the element schema is None): the
# specification's sequence relation is the element roots' relation.
def list_none(-items: S.Value, -E: S.Schema, -L: Nat, -outs: +List<+List<U32>>, +e: {RR.basic_size(E) == None{} : Maybe<&2, Nat>},
    p: RR.sequence(None{}, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), L, False{}, Some{Codec.count(items)}, outs))
    -> RR.roots(S.Sequence{items}, S.ListOf{E, L}, outs):
  %Equal.sym(Maybe<&2, Nat>, RR.basic_size(E), None{}, e) : RR.sequence(_, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), L, False{}, Some{Codec.count(items)}, outs)
  p
