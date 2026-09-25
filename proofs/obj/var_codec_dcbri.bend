import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/found.bend as F
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vcopy.bend as VC
import ./vspec.bend as VS
import ./vdepth.bend as VD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/decoding_relation.bend as Decoding
import ../../spec/nat_bytes.bend as N
import ../../spec/fulu_schemas.bend as Spec
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ./spec_fixed.bend as FX

# Spec-connected codec laws of DataColumnsByRootIdentifier, a variable-size
# container {block_root: Bytes32, columns: List[uint64, 128]}, against the
# generated decoder (types/fulu_obj.bend) and spec/codec.bend. For every
# buffer B.Buf{thaw(t), n} on a perfect word tree t of depth d < 29 holding
# n <= 4 2^d bytes:
#   ok_eval        the validator returns the buffer and CHK(t, n), the Bool
#                  of its three checks (fixed part present, offset 36, a whole
#                  number of at most 128 elements);
#   decode_accept  when CHK(t, n) holds, the decoder returns Some{OBJ(t, n)},
#                  the object whose root is the buffer's words 0..7 and whose
#                  list storage is the copy of words 9.. (explicit tree);
#   decode_spec    and then the buffer's bytes VW(t, n) are exactly the
#                  spec/codec.bend encoding of VAL(t, n), the spec value of
#                  that object (Decoding.decodes).
# var_codec_dcbri_unique.bend: every spec value of those bytes is VAL(t, n).

def BF(t: F.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{F.array__thaw(U32, t), n}

# An aligned read of word k (4k a literal offset).
def rd32(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(BF(t, n), q) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), q), (F.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, q, i, eq, hd, hi, pf)) :
    {B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  {==}

# The decoder's acceptance test, as a Bool of its three checks.
def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def whole(+L: U32) -> Bool: Bool.and(U32.is_eq(L, (U32.div(L, 8) * 8 : U32)), U32.is_le(U32.div(L, 8), 128))

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {T.DataColumnsByRootIdentifier_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def ok_c0(+t: F.array__Tree<U32>, +n: U32, +b: Bool)
    -> {T.DataColumnsByRootIdentifier_c0(b, BF(t, n), 0, n, VB.slot(t, 8n)) == (BF(t, n), chk3(True{}, b, whole(U32.sub(n, VB.slot(t, 8n))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: c1_id(whole(U32.sub(n, VB.slot(t, 8n))), BF(t, n), 0, n, VB.slot(t, 8n))

def ok_len(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +a: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +h8: {Nat.is_lt(8n, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnsByRootIdentifier_ok_len(a, BF(t, n), 0, n)
        == (BF(t, n), chk3(a, U32.is_eq(VB.slot(t, 8n), 36), whole(U32.sub(n, VB.slot(t, 8n))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 8), (BF(t, n), VB.slot(t, 8n)), rd32(d, t, n, 8, 8n, {==}, hd, h8, pf)) :
        {T.DataColumnsByRootIdentifier_v0(0, n, _) == (BF(t, n), chk3(True{}, U32.is_eq(VB.slot(t, 8n), 36), whole(U32.sub(n, VB.slot(t, 8n))))) : B.Buf & Bool}
      ok_c0(t, n, U32.is_eq(VB.slot(t, 8n), 36))

# The validator returns the buffer and the Bool of its checks.
def ok_eval(+d: Nat, +t: F.array__Tree<U32>, +n: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +h8: {Nat.is_lt(8n, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnsByRootIdentifier_ok(BF(t, n), 0, n)
        == (BF(t, n), chk3(U32.is_le(36, n), U32.is_eq(VB.slot(t, 8n), 36), whole(U32.sub(n, VB.slot(t, 8n))))) : B.Buf & Bool}:
  ok_len(d, t, n, U32.is_le(36, n), hd, h8, pf)

# B.zeros at a depth known up to 9.
def zeros_at(+du: U32, +k: Nat, +e: {U32.to_nat(du) == k : Nat}, +hk: {Nat.is_le(k, 9n) == True{} : Bool})
    -> {B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}:
  match k:
    case 0n:
      %Equal.sym(U32, du, 0, F.u32__injective(du, 0, e)) : {B.zeros(_) == Array.new(U32, 0n, 0) : Array<U32>}
      {==}
    case 1n:
      %Equal.sym(U32, du, 1, F.u32__injective(du, 1, e)) : {B.zeros(_) == Array.new(U32, 1n, 0) : Array<U32>}
      {==}
    case 2n:
      %Equal.sym(U32, du, 2, F.u32__injective(du, 2, e)) : {B.zeros(_) == Array.new(U32, 2n, 0) : Array<U32>}
      {==}
    case 3n:
      %Equal.sym(U32, du, 3, F.u32__injective(du, 3, e)) : {B.zeros(_) == Array.new(U32, 3n, 0) : Array<U32>}
      {==}
    case 4n:
      %Equal.sym(U32, du, 4, F.u32__injective(du, 4, e)) : {B.zeros(_) == Array.new(U32, 4n, 0) : Array<U32>}
      {==}
    case 5n:
      %Equal.sym(U32, du, 5, F.u32__injective(du, 5, e)) : {B.zeros(_) == Array.new(U32, 5n, 0) : Array<U32>}
      {==}
    case 6n:
      %Equal.sym(U32, du, 6, F.u32__injective(du, 6, e)) : {B.zeros(_) == Array.new(U32, 6n, 0) : Array<U32>}
      {==}
    case 7n:
      %Equal.sym(U32, du, 7, F.u32__injective(du, 7, e)) : {B.zeros(_) == Array.new(U32, 7n, 0) : Array<U32>}
      {==}
    case 8n:
      %Equal.sym(U32, du, 8, F.u32__injective(du, 8, e)) : {B.zeros(_) == Array.new(U32, 8n, 0) : Array<U32>}
      {==}
    case 9n:
      %Equal.sym(U32, du, 9, F.u32__injective(du, 9, e)) : {B.zeros(_) == Array.new(U32, 9n, 0) : Array<U32>}
      {==}
    case 10n+p: Empty.absurd({B.zeros(du) == Array.new(U32, 10n+p, 0) : Array<U32>}, F.logic__false_true(hk))

def lt_k(+k: Nat, +d: Nat, +hk: {Nat.is_lt(k, 8n) == True{} : Bool}, +h8: {Nat.is_lt(8n, VB.pw(d)) == True{} : Bool}) -> {Nat.is_lt(k, VB.pw(d)) == True{} : Bool}:
  F.nat__lt_trans(k, 8n, VB.pw(d), hk, h8)

def b32_rd(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +h8: {Nat.is_lt(8n, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.b32_read(BF(t, n), U32.add(0, 0), 32) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}:
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 0), (BF(t, n), VB.slot(t, 0n)), rd32(d, t, n, 0, 0n, {==}, hd, lt_k(0n, d, {==}, h8), pf)) :
    {T.b32_r0(U32.add(0, 0), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 1), (BF(t, n), VB.slot(t, 1n)), rd32(d, t, n, 1, 1n, {==}, hd, lt_k(1n, d, {==}, h8), pf)) :
    {T.b32_r1(U32.add(0, 0), VB.slot(t, 0n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 2), (BF(t, n), VB.slot(t, 2n)), rd32(d, t, n, 2, 2n, {==}, hd, lt_k(2n, d, {==}, h8), pf)) :
    {T.b32_r2(U32.add(0, 0), VB.slot(t, 0n), VB.slot(t, 1n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 3), (BF(t, n), VB.slot(t, 3n)), rd32(d, t, n, 3, 3n, {==}, hd, lt_k(3n, d, {==}, h8), pf)) :
    {T.b32_r3(U32.add(0, 0), VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 4), (BF(t, n), VB.slot(t, 4n)), rd32(d, t, n, 4, 4n, {==}, hd, lt_k(4n, d, {==}, h8), pf)) :
    {T.b32_r4(U32.add(0, 0), VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 5), (BF(t, n), VB.slot(t, 5n)), rd32(d, t, n, 5, 5n, {==}, hd, lt_k(5n, d, {==}, h8), pf)) :
    {T.b32_r5(U32.add(0, 0), VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 6), (BF(t, n), VB.slot(t, 6n)), rd32(d, t, n, 6, 6n, {==}, hd, lt_k(6n, d, {==}, h8), pf)) :
    {T.b32_r6(U32.add(0, 0), VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 7), (BF(t, n), VB.slot(t, 7n)), rd32(d, t, n, 7, 7n, {==}, hd, lt_k(7n, d, {==}, h8), pf)) :
    {T.b32_r7(U32.add(0, 0), VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), _) == (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}) : B.Buf & T.Bytes32}
  {==}

def rd_ok(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +dz: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +h8: {Nat.is_lt(8n, VB.pw(d)) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +e8: {VB.slot(t, 8n) == 36 : U32},
    +ez: {B.zeros(B.words_depth_u(VC.WZ(U32.sub(n, 36)))) == Array.new(U32, dz, 0) : Array<U32>},
    +hL3: {U32.and(U32.sub(n, 36), 3) == 0 : U32},
    +hs: {Nat.is_le(Nat.add(VC.NW(U32.sub(n, 36)), 9n), VB.pw(d)) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(VC.NW(U32.sub(n, 36)), 0n), VB.pw(dz)) == True{} : Bool})
    -> {T.DataColumnsByRootIdentifier_read(BF(t, n), 0, n) == (BF(t, n), T.DataColumnsByRootIdentifier{T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, O.Words{F.array__thaw(U32, VB.mone(VC.NW(U32.sub(n, 36)), 9n, 0n, dz, VC.ZT(dz), t)), U32.sub(n, 36)}}) : B.Buf & T.DataColumnsByRootIdentifier}:
  +hd32 = VB.lt32(d, hd)
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 8), (BF(t, n), VB.slot(t, 8n)), rd32(d, t, n, 8, 8n, {==}, hd32, h8, pf)) :
    {T.DataColumnsByRootIdentifier_rd0(0, n, _) == (BF(t, n), T.DataColumnsByRootIdentifier{T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, O.Words{F.array__thaw(U32, VB.mone(VC.NW(U32.sub(n, 36)), 9n, 0n, dz, VC.ZT(dz), t)), U32.sub(n, 36)}}) : B.Buf & T.DataColumnsByRootIdentifier}
  %Equal.sym(B.Buf & T.Bytes32, T.b32_read(BF(t, n), U32.add(0, 0), 32), (BF(t, n), T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}), b32_rd(d, t, n, hd32, h8, pf)) :
    {T.DataColumnsByRootIdentifier_rd1(0, n, VB.slot(t, 8n), _) == (BF(t, n), T.DataColumnsByRootIdentifier{T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, O.Words{F.array__thaw(U32, VB.mone(VC.NW(U32.sub(n, 36)), 9n, 0n, dz, VC.ZT(dz), t)), U32.sub(n, 36)}}) : B.Buf & T.DataColumnsByRootIdentifier}
  %Equal.sym(U32, VB.slot(t, 8n), 36, e8) :
    {T.DataColumnsByRootIdentifier_rd2(0, n, _, T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, T.l128_u64_read(BF(t, n), U32.add(0, _), U32.sub(n, _))) == (BF(t, n), T.DataColumnsByRootIdentifier{T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, O.Words{F.array__thaw(U32, VB.mone(VC.NW(U32.sub(n, 36)), 9n, 0n, dz, VC.ZT(dz), t)), U32.sub(n, 36)}}) : B.Buf & T.DataColumnsByRootIdentifier}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), U32.add(0, 36), U32.sub(n, 36)), (BF(t, n), O.Words{F.array__thaw(U32, VB.mone(VC.NW(U32.sub(n, 36)), 9n, 0n, dz, VC.ZT(dz), t)), U32.sub(n, 36)}),
      VC.copy_in_ok(d, t, n, U32.add(0, 36), 9n, U32.sub(n, 36), dz, pf, hd, hdz, ez, {==}, {==}, hL3, hs, hr)) :
    {T.DataColumnsByRootIdentifier_rd2(0, n, 36, T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, _) == (BF(t, n), T.DataColumnsByRootIdentifier{T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, O.Words{F.array__thaw(U32, VB.mone(VC.NW(U32.sub(n, 36)), 9n, 0n, dz, VC.ZT(dz), t)), U32.sub(n, 36)}}) : B.Buf & T.DataColumnsByRootIdentifier}
  {==}

def chk_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def chk_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, F.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def chk_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, F.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, F.logic__false_true(h))
    case True{} True{}: h

def v8() -> Word(31n): F.spec_numeric__from_nat(31n, 8n)

# The facts the accepting checks give, over the list's length L = n - 36.
def L36(+n: U32) -> U32: U32.sub(n, 36)
def CQ(+n: U32) -> Nat: U32.to_nat(U32.div(L36(n), 8))

def le36(+n: U32, +ha: {U32.is_le(36, n) == True{} : Bool}) -> {Nat.is_le(36n, U32.to_nat(n)) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(36, n), Nat.is_le(36n, U32.to_nat(n)), VU.le_u32(36, n), ha)

def en36(+n: U32, +ha: {U32.is_le(36, n) == True{} : Bool}) -> {Nat.add(36n, U32.to_nat(L36(n))) == U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L36(n)), Nat.sub(U32.to_nat(n), 36n), F.u32__sub_nat(n, 36, le36(n, ha))) : {Nat.add(36n, _) == U32.to_nat(n) : Nat}
  F.nat__sub_add(U32.to_nat(n), 36n, le36(n, ha))

def eLc(+n: U32, +hc: {whole(L36(n)) == True{} : Bool}) -> {U32.to_nat(L36(n)) == VS.x8(CQ(n)) : Nat}:
  %VC.x8_mul(CQ(n)) : {U32.to_nat(L36(n)) == _ : Nat}
  Pair.fst({U32.to_nat(L36(n)) == Nat.mul(CQ(n), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(n), U32.to_nat(128)) == True{} : Bool},
    VU.whole_t(L36(n), 8, 128, v8(), {==}, {==}, {==}, hc))

def hc128(+n: U32, +hc: {whole(L36(n)) == True{} : Bool}) -> {Nat.is_le(CQ(n), 128n) == True{} : Bool}:
  Pair.snd({U32.to_nat(L36(n)) == Nat.mul(CQ(n), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(n), U32.to_nat(128)) == True{} : Bool},
    VU.whole_t(L36(n), 8, 128, v8(), {==}, {==}, {==}, hc))

def DZ(+n: U32) -> Nat: B.words_depth(VC.WZ(L36(n)))
def MM(+t: F.array__Tree<U32>, +n: U32) -> F.array__Tree<U32>: VB.mone(VC.NW(L36(n)), 9n, 0n, DZ(n), VC.ZT(DZ(n)), t)

# 31 + L <= n <= 2^(2 + d)
def hy(+d: Nat, +n: U32, +ha: {U32.is_le(36, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(VC.YL(L36(n)), VB.pw(2n+d)) == True{} : Bool}:
  F.nat__le_trans(VC.YL(L36(n)), U32.to_nat(n), VB.pw(2n+d),
    F.logic__subst(Nat, z => {Nat.is_le(VC.YL(L36(n)), z) == True{} : Bool}, Nat.add(36n, U32.to_nat(L36(n))), U32.to_nat(n), en36(n, ha),
      Order.add_right(31n, 36n, U32.to_nat(L36(n)), {==})),
    hn)

def eNWc(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {VC.NW(L36(n)) == Nat.double(CQ(n)) : Nat}:
  %Equal.sym(Nat, VC.NW(L36(n)), VD.s_rng(2n, 3n+U32.to_nat(L36(n))), VC.eNW(L36(n), 2n+d, hd, hy(d, n, ha, hn))) : {_ == Nat.double(CQ(n)) : Nat}
  %Equal.sym(Nat, U32.to_nat(L36(n)), VS.x8(CQ(n)), eLc(n, hc)) : {VD.s_rng(2n, 3n+_) == Nat.double(CQ(n)) : Nat}
  VC.rng2_x8(CQ(n))

# 9 + 2c <= 2^d: the list's words lie in the buffer.
def hs(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L36(n)), 9n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(L36(n)), Nat.double(CQ(n)), eNWc(d, n, hd, ha, hn, hc)) : {Nat.is_le(Nat.add(_, 9n), VB.pw(d)) == True{} : Bool}
  %F.nat__add_comm(9n, Nat.double(CQ(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  VC.quad_inv(9n+Nat.double(CQ(n)), VB.pw(d),
    F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), 36n+VB.d3(CQ(n)),
      Equal.trans(Nat, U32.to_nat(n), Nat.add(36n, U32.to_nat(L36(n))), 36n+VB.d3(CQ(n)), Equal.sym(Nat, Nat.add(36n, U32.to_nat(L36(n))), U32.to_nat(n), en36(n, ha)),
        Equal.cong(Nat, Nat, z => Nat.add(36n, z), U32.to_nat(L36(n)), VB.d3(CQ(n)), Equal.trans(Nat, U32.to_nat(L36(n)), VS.x8(CQ(n)), VB.d3(CQ(n)), eLc(n, hc), VB.x8_d3(CQ(n))))),
      hn))

# The allocation is at most 2^9 words.
def hWZ(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(L36(n))), O.pow2n(9n)) == True{} : Bool}:
  +hx = F.logic__subst(Nat, z => {Nat.is_le(z, 1024n) == True{} : Bool}, VS.x8(CQ(n)), U32.to_nat(L36(n)), Equal.sym(Nat, U32.to_nat(L36(n)), VS.x8(CQ(n)), eLc(n, hc)),
    VS.x8_mono(CQ(n), 128n, hc128(n, hc)))
  F.nat__le_trans(U32.to_nat(VC.WZ(L36(n))), Nat.add(VD.s_rng(2n, VC.YL(L36(n))), 8n), O.pow2n(9n),
    VC.wz_le(L36(n), 2n+d, hd, hy(d, n, ha, hn)),
    F.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(L36(n))), 8n), Nat.add(VD.s_rng(2n, 1055n), 8n), O.pow2n(9n),
      Order.add_right(VD.s_rng(2n, VC.YL(L36(n))), VD.s_rng(2n, 1055n), 8n, VC.rng_mono(2n, VC.YL(L36(n)), 1055n, Order.add_left(31n, U32.to_nat(L36(n)), 1024n, hx))),
      {==}))

def hdz9(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {Nat.is_le(DZ(n), 9n) == True{} : Bool}:
  VD.wd_min(VC.WZ(L36(n)), 9n, hWZ(d, n, hd, ha, hn, hc))

def hr(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L36(n)), 0n), VB.pw(DZ(n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(L36(n)), 0n), VC.NW(L36(n)), F.nat__add_zero(VC.NW(L36(n)))) : {Nat.is_le(_, VB.pw(DZ(n))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(DZ(n)), O.pow2n(DZ(n)), VD.s_pow2_eq(DZ(n))) : {Nat.is_le(VC.NW(L36(n)), _) == True{} : Bool}
  F.nat__le_trans(VC.NW(L36(n)), U32.to_nat(VC.WZ(L36(n))), O.pow2n(DZ(n)),
    VC.nw_le_wz(L36(n), 2n+d, hd, hy(d, n, ha, hn)),
    VD.wd_cover(VC.WZ(L36(n)), 9n, {==}, hWZ(d, n, hd, ha, hn, hc)))

def OBJ(+t: F.array__Tree<U32>, +n: U32) -> T.DataColumnsByRootIdentifier: T.DataColumnsByRootIdentifier{T.Bytes32{VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n)}, O.Words{F.array__thaw(U32, MM(t, n)), L36(n)}}
def CHK(+t: F.array__Tree<U32>, +n: U32) -> Bool: chk3(U32.is_le(36, n), U32.is_eq(VB.slot(t, 8n), 36), whole(U32.sub(n, VB.slot(t, 8n))))

def h8of(+d: Nat, +n: U32, +h: {Nat.is_le(Nat.add(VC.NW(L36(n)), 9n), VB.pw(d)) == True{} : Bool}) -> {Nat.is_lt(8n, VB.pw(d)) == True{} : Bool}:
  F.nat__lt_le_trans(8n, 9n, VB.pw(d), {==}, F.nat__le_trans(9n, Nat.add(VC.NW(L36(n)), 9n), VB.pw(d), Order.left_below_sum(VC.NW(L36(n)), 9n), h))

def acc_go(+d: Nat, +t: F.array__Tree<U32>, +n: U32,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +hchk: {CHK(t, n) == True{} : Bool},
    +ha: {U32.is_le(36, n) == True{} : Bool}, +e8: {VB.slot(t, 8n) == 36 : U32}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {T.DataColumnsByRootIdentifier_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}:
  +hs0 = hs(d, n, hd, ha, hn, hc)
  +h8 = h8of(d, n, hs0)
  +hd31 = F.nat__lt_trans(d, 29n, 31n, hd, {==})
  +hz = hdz9(d, n, hd, ha, hn, hc)
  +ez = zeros_at(B.words_depth_u(VC.WZ(L36(n))), DZ(n), VD.wdu(VC.WZ(L36(n))), hz)
  %Equal.sym(B.Buf & Bool, T.DataColumnsByRootIdentifier_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, VB.lt32(d, hd31), h8, pf)) :
    {T.DataColumnsByRootIdentifier_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {T.DataColumnsByRootIdentifier_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
  %Equal.sym(B.Buf & T.DataColumnsByRootIdentifier, T.DataColumnsByRootIdentifier_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)),
      rd_ok(d, t, n, DZ(n), pf, hd31, h8, F.nat__le_lt_trans(DZ(n), 9n, 31n, hz, {==}), e8, ez, VC.and3_x8(L36(n), CQ(n), eLc(n, hc)), hs0, hr(d, n, hd, ha, hn, hc))) :
    {T.DataColumnsByRootIdentifier_some(_) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
  {==}

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {T.DataColumnsByRootIdentifier_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(36, n)
  +b = U32.is_eq(VB.slot(t, 8n), 36)
  +c = whole(U32.sub(n, VB.slot(t, 8n)))
  +e8 = F.u32alg__eq_of(VB.slot(t, 8n), 36, chk_b(a, b, c, hchk))
  acc_go(d, t, n, pf, hd, hn, hchk, chk_a(a, b, c, hchk), e8,
    F.logic__subst(U32, z => {whole(U32.sub(n, z)) == True{} : Bool}, VB.slot(t, 8n), 36, e8, chk_c(a, b, c, hchk)))
def dc_val(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +k: Nat, +W: List<&2, U32>) -> S.Value:
  S.Sequence{S.Items{S.BytesValue{FX.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.Sequence{VS.uitems(k, W)}, S.EmptyItems{}}}}

def dc_enc(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +k: Nat, +W: List<&2, U32>,
    +hk: {Nat.is_le(k, 128n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {Codec.encoding_for_legal_type(Spec.DataColumnsByRootIdentifier(), dc_val(x0, x1, x2, x3, x4, x5, x6, x7, k, W))
        == Some{FX.limbs(x0 <> x1 <> x2 <> x3 <> x4 <> x5 <> x6 <> x7 <> 36 <> VS.wtake(Nat.double(k), W))} : Maybe<&2, +List<U32>>}:
  +X = FX.limbs([x0, x1, x2, x3, x4, x5, x6, x7])
  +Y = FX.limbs(VS.wtake(Nat.double(k), W))
  +R = FX.limbs(x0 <> x1 <> x2 <> x3 <> x4 <> x5 <> x6 <> x7 <> 36 <> VS.wtake(Nat.double(k), W))
  +fit = VS.fits_mono(4n, Nat.add(36n, List.length(&2, U32, Y)), 1060n,
    Order.add_left(36n, List.length(&2, U32, Y), 1024n,
      F.logic__subst(Nat, z => {Nat.is_le(z, 1024n) == True{} : Bool}, VS.x8(k), List.length(&2, U32, Y),
        Equal.sym(Nat, List.length(&2, U32, Y), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)), VS.x8_mono(k, 128n, hk))),
    {==})
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Sequence{VS.uitems(k, W)}, S.ListOf{S.Unsigned{P.U64{}}, 128n}), Some{[S.Variable{Y}]},
      VS.list_u64_parts(k, W, 128n, hk, {==}, hl)) :
    {Codec.bytes(Codec.aggregate(Codec.concatenate(Codec.parts(S.BytesValue{X}, S.ByteVector{32n}), Codec.concatenate(_, Some{[]})), None{})) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.BytesValue{X}, S.ByteVector{32n}), Some{[S.Fixed{X}]}, FX.bytes_part(x0, [x1, x2, x3, x4, x5, x6, x7], {==})) :
    {Codec.bytes(Codec.aggregate(Codec.concatenate(_, Codec.concatenate(Some{[S.Variable{Y}]}, Some{[]})), None{})) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(Bool.and(SP.bytes_domain(X), Bool.and(SP.bytes_domain(Y), True{})), N.fits(4n, Nat.add(36n, List.length(&2, U32, _)))),
       List.append(&2, U32, List.append(&2, U32, X, List.append(&2, U32, N.digits(4n, 36n), [])), _)), None{})) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, SP.bytes_domain(X), True{}, FX.domain_limbs([x0, x1, x2, x3, x4, x5, x6, x7])) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(Bool.and(_, Bool.and(SP.bytes_domain(Y), True{})), N.fits(4n, Nat.add(36n, List.length(&2, U32, Y)))),
       List.append(&2, U32, List.append(&2, U32, X, List.append(&2, U32, N.digits(4n, 36n), [])), Y)), None{})) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, SP.bytes_domain(Y), True{}, FX.domain_limbs(VS.wtake(Nat.double(k), W))) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(Bool.and(True{}, Bool.and(_, True{})), N.fits(4n, Nat.add(36n, List.length(&2, U32, Y)))),
       List.append(&2, U32, List.append(&2, U32, X, List.append(&2, U32, N.digits(4n, 36n), [])), Y)), None{})) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(36n, List.length(&2, U32, Y))), True{}, fit) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(Bool.and(True{}, Bool.and(True{}, True{})), _),
       List.append(&2, U32, List.append(&2, U32, X, List.append(&2, U32, N.digits(4n, 36n), [])), Y)), None{})) == Some{R} : Maybe<&2, +List<U32>>}
  {==}


def VW(+t: F.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), FX.limbs(F.array__slots(U32, t)))
def VAL(+t: F.array__Tree<U32>, +n: U32) -> S.Value:
  dc_val(VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n), CQ(n), F.array__slots(U32, MM(t, n)))

def pre9(+t: F.array__Tree<U32>, +K: Nat, +h: {Nat.is_lt(8n, VB.len(F.array__slots(U32, t))) == True{} : Bool})
    -> {VS.wtake(9n+K, VB.wdr(0n, F.array__slots(U32, t))) == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, VS.wtake(9n+K, VB.wdr(0n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 0n), VS.wtake(8n+K, VB.wdr(1n, F.array__slots(U32, t)))}, VB.wt_eta(8n+K, 0n, F.array__slots(U32, t), F.nat__lt_trans(0n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {_ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(8n+K, VB.wdr(1n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 1n), VS.wtake(7n+K, VB.wdr(2n, F.array__slots(U32, t)))}, VB.wt_eta(7n+K, 1n, F.array__slots(U32, t), F.nat__lt_trans(1n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(7n+K, VB.wdr(2n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 2n), VS.wtake(6n+K, VB.wdr(3n, F.array__slots(U32, t)))}, VB.wt_eta(6n+K, 2n, F.array__slots(U32, t), F.nat__lt_trans(2n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(6n+K, VB.wdr(3n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 3n), VS.wtake(5n+K, VB.wdr(4n, F.array__slots(U32, t)))}, VB.wt_eta(5n+K, 3n, F.array__slots(U32, t), F.nat__lt_trans(3n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(5n+K, VB.wdr(4n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 4n), VS.wtake(4n+K, VB.wdr(5n, F.array__slots(U32, t)))}, VB.wt_eta(4n+K, 4n, F.array__slots(U32, t), F.nat__lt_trans(4n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(4n+K, VB.wdr(5n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 5n), VS.wtake(3n+K, VB.wdr(6n, F.array__slots(U32, t)))}, VB.wt_eta(3n+K, 5n, F.array__slots(U32, t), F.nat__lt_trans(5n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(3n+K, VB.wdr(6n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 6n), VS.wtake(2n+K, VB.wdr(7n, F.array__slots(U32, t)))}, VB.wt_eta(2n+K, 6n, F.array__slots(U32, t), F.nat__lt_trans(6n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(2n+K, VB.wdr(7n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 7n), VS.wtake(1n+K, VB.wdr(8n, F.array__slots(U32, t)))}, VB.wt_eta(1n+K, 7n, F.array__slots(U32, t), F.nat__lt_trans(7n, 8n, VB.len(F.array__slots(U32, t)), {==}, h))) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n+K, VB.wdr(8n, F.array__slots(U32, t))), Con{F.flat__nthc(F.array__slots(U32, t), 8n), VS.wtake(0n+K, VB.wdr(9n, F.array__slots(U32, t)))}, VB.wt_eta(0n+K, 8n, F.array__slots(U32, t), h)) :
    {F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> _ == F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(K, VB.wdr(9n, F.array__slots(U32, t))) : List<&2, U32>}
  {==}

def en_q(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +ha: {U32.is_le(36, n) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {A.quad(9n+VC.NW(L36(n))) == U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, VC.NW(L36(n)), Nat.double(CQ(n)), eNWc(d, n, hd, ha, hn, hc)) : {A.quad(9n+_) == U32.to_nat(n) : Nat}
  %en36(n, ha) : {A.quad(9n+Nat.double(CQ(n))) == _ : Nat}
  %Equal.sym(Nat, U32.to_nat(L36(n)), VS.x8(CQ(n)), eLc(n, hc)) : {A.quad(9n+Nat.double(CQ(n))) == Nat.add(36n, _) : Nat}
  %Equal.sym(Nat, VS.x8(CQ(n)), VB.d3(CQ(n)), VB.x8_d3(CQ(n))) : {A.quad(9n+Nat.double(CQ(n))) == Nat.add(36n, _) : Nat}
  {==}

def len_z(+n: U32) -> {VB.len(F.array__slots(U32, VC.ZT(DZ(n)))) == VB.pw(DZ(n)) : Nat}:
  F.array__slots_length(U32, DZ(n), VC.ZT(DZ(n)), F.array__trep_perfect(U32, DZ(n), 0))

def len_t(+d: Nat, +t: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d, t) == True{} : Bool}) -> {VB.len(F.array__slots(U32, t)) == VB.pw(d) : Nat}:
  F.array__slots_length(U32, d, t, pf)

def lim_eq(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool}, +e8: {VB.slot(t, 8n) == 36 : U32}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n)))) == VW(t, n) : +List<U32>}:
  +hs0 = hs(d, n, hd, ha, hn, hc)
  +hr0 = hr(d, n, hd, ha, hn, hc)
  +h8 = F.logic__subst(Nat, z => {Nat.is_lt(8n, z) == True{} : Bool}, VB.pw(d), VB.len(F.array__slots(U32, t)), Equal.sym(Nat, VB.len(F.array__slots(U32, t)), VB.pw(d), len_t(d, t, pf)), h8of(d, n, hs0))
  %en_q(d, n, hd, hn, ha, hc) : {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n)))) == VS.bt(_, FX.limbs(F.array__slots(U32, t))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(9n+VC.NW(L36(n))), FX.limbs(F.array__slots(U32, t))), FX.limbs(VS.wtake(9n+VC.NW(L36(n)), F.array__slots(U32, t))), VS.bt_limbs(9n+VC.NW(L36(n)), F.array__slots(U32, t))) :
    {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n)))) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(9n+VC.NW(L36(n)), VB.wdr(0n, F.array__slots(U32, t))), F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> F.flat__nthc(F.array__slots(U32, t), 8n) <> VS.wtake(VC.NW(L36(n)), VB.wdr(9n, F.array__slots(U32, t))), pre9(t, VC.NW(L36(n)), h8)) :
    {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n)))) == FX.limbs(_) : +List<U32>}
  %Equal.sym(U32, VB.slot(t, 8n), 36, e8) :
    {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n)))) == FX.limbs(F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> _ <> VS.wtake(VC.NW(L36(n)), VB.wdr(9n, F.array__slots(U32, t)))) : +List<U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, MM(t, n)), VB.lm(VC.NW(L36(n)), 9n, 0n, F.array__slots(U32, VC.ZT(DZ(n))), F.array__slots(U32, t)),
      VB.slots_mone(VC.NW(L36(n)), 9n, 0n, DZ(n), VC.ZT(DZ(n)), t, F.array__trep_perfect(U32, DZ(n), 0), hr0)) :
    {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), _)) == FX.limbs(F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> 36 <> VS.wtake(VC.NW(L36(n)), VB.wdr(9n, F.array__slots(U32, t)))) : +List<U32>}
  %eNWc(d, n, hd, ha, hn, hc) :
    {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(_, VB.lm(VC.NW(L36(n)), 9n, 0n, F.array__slots(U32, VC.ZT(DZ(n))), F.array__slots(U32, t)))) == FX.limbs(F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> 36 <> VS.wtake(VC.NW(L36(n)), VB.wdr(9n, F.array__slots(U32, t)))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(VC.NW(L36(n)), VB.wdr(0n, VB.lm(VC.NW(L36(n)), 9n, 0n, F.array__slots(U32, VC.ZT(DZ(n))), F.array__slots(U32, t)))), VS.wtake(VC.NW(L36(n)), VB.wdr(9n, F.array__slots(U32, t))),
      VB.lm_win(VC.NW(L36(n)), 9n, 0n, F.array__slots(U32, VC.ZT(DZ(n))), F.array__slots(U32, t),
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L36(n)), 0n), z) == True{} : Bool}, VB.pw(DZ(n)), VB.len(F.array__slots(U32, VC.ZT(DZ(n)))), Equal.sym(Nat, VB.len(F.array__slots(U32, VC.ZT(DZ(n)))), VB.pw(DZ(n)), len_z(n)), hr0),
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L36(n)), 9n), z) == True{} : Bool}, VB.pw(d), VB.len(F.array__slots(U32, t)), Equal.sym(Nat, VB.len(F.array__slots(U32, t)), VB.pw(d), len_t(d, t, pf)), hs0))) :
    {FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> _) == FX.limbs(F.flat__nthc(F.array__slots(U32, t), 0n) <> F.flat__nthc(F.array__slots(U32, t), 1n) <> F.flat__nthc(F.array__slots(U32, t), 2n) <> F.flat__nthc(F.array__slots(U32, t), 3n) <> F.flat__nthc(F.array__slots(U32, t), 4n) <> F.flat__nthc(F.array__slots(U32, t), 5n) <> F.flat__nthc(F.array__slots(U32, t), 6n) <> F.flat__nthc(F.array__slots(U32, t), 7n) <> 36 <> VS.wtake(VC.NW(L36(n)), VB.wdr(9n, F.array__slots(U32, t)))) : +List<U32>}
  {==}

def hl_mm(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +ha: {U32.is_le(36, n) == True{} : Bool}, +hc: {whole(L36(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.double(CQ(n)), F.spec_common__length(U32, F.array__slots(U32, MM(t, n)))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, MM(t, n))), VB.pw(DZ(n)),
      F.array__slots_length(U32, DZ(n), MM(t, n), VB.mone_perfect(VC.NW(L36(n)), 9n, 0n, DZ(n), VC.ZT(DZ(n)), t, F.array__trep_perfect(U32, DZ(n), 0)))) :
    {Nat.is_le(Nat.double(CQ(n)), _) == True{} : Bool}
  %eNWc(d, n, hd, ha, hn, hc) : {Nat.is_le(_, VB.pw(DZ(n))) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(DZ(n))) == True{} : Bool}, Nat.add(VC.NW(L36(n)), 0n), VC.NW(L36(n)), F.nat__add_zero(VC.NW(L36(n))), hr(d, n, hd, ha, hn, hc))

def spec_go(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +ha: {U32.is_le(36, n) == True{} : Bool}, +e8: {VB.slot(t, 8n) == 36 : U32},
    +hc: {whole(L36(n)) == True{} : Bool})
    -> Decoding.decodes(Spec.DataColumnsByRootIdentifier(), VW(t, n), VAL(t, n)):
  Equal.trans(Maybe<&2, +List<U32>>, Codec.encoding_for_legal_type(Spec.DataColumnsByRootIdentifier(), VAL(t, n)), Some{FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n))))}, Some{VW(t, n)},
    dc_enc(VB.slot(t, 0n), VB.slot(t, 1n), VB.slot(t, 2n), VB.slot(t, 3n), VB.slot(t, 4n), VB.slot(t, 5n), VB.slot(t, 6n), VB.slot(t, 7n), CQ(n), F.array__slots(U32, MM(t, n)), hc128(n, hc), hl_mm(d, t, n, hd, hn, ha, hc)),
    Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, x => Some{x}, FX.limbs(VB.slot(t, 0n) <> VB.slot(t, 1n) <> VB.slot(t, 2n) <> VB.slot(t, 3n) <> VB.slot(t, 4n) <> VB.slot(t, 5n) <> VB.slot(t, 6n) <> VB.slot(t, 7n) <> 36 <> VS.wtake(Nat.double(CQ(n)), F.array__slots(U32, MM(t, n)))), VW(t, n), lim_eq(d, t, n, pf, hd, hn, ha, e8, hc)))

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
law decode_spec:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.DataColumnsByRootIdentifier(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(36, n)
  +b = U32.is_eq(VB.slot(t, 8n), 36)
  +c = whole(U32.sub(n, VB.slot(t, 8n)))
  +e8 = F.u32alg__eq_of(VB.slot(t, 8n), 36, chk_b(a, b, c, hchk))
  spec_go(d, t, n, pf, hd, hn, chk_a(a, b, c, hchk), e8,
    F.logic__subst(U32, z => {whole(U32.sub(n, z)) == True{} : Bool}, VB.slot(t, 8n), 36, e8, chk_c(a, b, c, hchk)))
