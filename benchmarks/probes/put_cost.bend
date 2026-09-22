import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/objio.bend as IOx

# Is what is left of an encode memory traffic or per-call overhead?
#
# `AttestationData` is a fixed 128-byte container of two uint64s, a 32-byte
# root and two Checkpoints - eight scalar field writes, 32 words, no
# allocation and no variable-size machinery at all. Writing it at an aligned
# position and at an unaligned one, against the 0.19 ns/word a bare copy loop
# costs (benchmarks/probes/out_alloc.bend), separates the two.
#
#   SSZ_MODE 0  SSZ_OPS x AttestationData_put at byte 0   (aligned)
#   SSZ_MODE 1  SSZ_OPS x AttestationData_put at byte 1   (unaligned)
#   SSZ_MODE 2  SSZ_OPS x a bare 32-word copy for scale

def first(out: Array<U32>) -> Array<U32> & U32: Array.get(U32, out, 0)

def took(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def one(+pos: U32, +acc: U32) -> U32:
  (acc .^. took(first(T.AttestationData_put(O.out_at(6n), pos, T.AttestationData_default()))) : U32)

def ploop(+k: Nat, +pos: U32, +acc: U32) -> U32:
  match k:
    case 0n: one(pos, acc)
    case 1n+p: ploop(p, pos, one(pos, acc))

def cp(+k: Nat, +j: U32, out: Array<U32>) -> Array<U32>:
  match k:
    case 0n: Array.set(U32, out, j, j)
    case 1n+p: cp(p, (j + 1 : U32), Array.set(U32, out, j, j))

def one_cp(+acc: U32) -> U32:
  (acc .^. took(first(cp(31n, 0, O.out_at(6n)))) : U32)

def cloop(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: one_cp(acc)
    case 1n+p: cloop(p, one_cp(acc))

# Mode 3: the whole public encode of one Attestation, called directly, with
# no dispatch sum between the loop and the codec. Mode 4: the same for
# ExecutionPayloadHeader. Compared with the benchmark harness's per-workload
# number, this separates the codec from the harness's Any wrapper.
def enc_a(pair: T.Attestation & B.Buf) -> T.Attestation & U32:
  (o, out) = pair
  (o, IOx.word_out_of(B.size(out)))

def aloop(+k: Nat, +acc: U32, pair: T.Attestation & U32) -> U32:
  match k:
    case 0n:
      (o, +x) = pair
      (acc .^. x : U32)
    case 1n+p:
      (o, +x) = pair
      aloop(p, (acc .^. x : U32), enc_a(T.Attestation_encode(o)))

def enc_h(pair: T.ExecutionPayloadHeader & B.Buf) -> T.ExecutionPayloadHeader & U32:
  (o, out) = pair
  (o, IOx.word_out_of(B.size(out)))

def hloop(+k: Nat, +acc: U32, pair: T.ExecutionPayloadHeader & U32) -> U32:
  match k:
    case 0n:
      (o, +x) = pair
      (acc .^. x : U32)
    case 1n+p:
      (o, +x) = pair
      hloop(p, (acc .^. x : U32), enc_h(T.ExecutionPayloadHeader_encode(o)))

# Mode 5: Attestation_size alone. Mode 6: just the output allocation an
# Attestation encode makes. Mode 7: the Bytes96 field write alone. Together
# with modes 0 and 3 these account for the parts of one public encode.
def sz_a(pair: T.Attestation & U32) -> T.Attestation & U32:
  (o, +n) = pair
  (o, n)

def sloop(+k: Nat, +acc: U32, pair: T.Attestation & U32) -> U32:
  match k:
    case 0n:
      (o, +x) = pair
      (acc .^. x : U32)
    case 1n+p:
      (o, +x) = pair
      sloop(p, (acc .^. x : U32), T.Attestation_size(o))

def one_new(+acc: U32) -> U32:
  (acc .^. took(first(O.out_new(229))) : U32)

def nloop(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: one_new(acc)
    case 1n+p: nloop(p, one_new(acc))

def one_b96(+acc: U32) -> U32:
  (acc .^. took(first(T.b96_put(O.out_at(6n), 1, T.b96_default()))) : U32)

def bloop(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: one_b96(acc)
    case 1n+p: bloop(p, one_b96(acc))

# Mode 8: B.capacity alone - the depth an encode's output allocation needs.
# Mode 9: Array.new at a literal depth, for scale.
def one_cap(+acc: U32) -> U32:
  (acc .^. O.nat_u32(B.capacity(229)) : U32)

def kloop(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: one_cap(acc)
    case 1n+p: kloop(p, one_cap(acc))

def one_lit(+acc: U32) -> U32:
  (acc .^. took(first(O.out_at(6n))) : U32)

def lloop(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: one_lit(acc)
    case 1n+p: lloop(p, one_lit(acc))

# Mode 10: ExecutionPayloadHeader_size alone - the traversal an encode makes
# before it can allocate, duplicating the structural walk the write then does.
def hsloop(+k: Nat, +acc: U32, pair: T.ExecutionPayloadHeader & U32) -> U32:
  match k:
    case 0n:
      (o, +x) = pair
      (acc .^. x : U32)
    case 1n+p:
      (o, +x) = pair
      hsloop(p, (acc .^. x : U32), T.ExecutionPayloadHeader_size(o))

def pick_acc(+mode: U32, +ops: U32) -> U32:
  match mode:
    case 0: ploop(U32.to_nat(ops), 0, 0)
    case 1: ploop(U32.to_nat(ops), 1, 0)
    case 2: cloop(U32.to_nat(ops), 0)
    case 3: aloop(U32.to_nat(ops), 0, enc_a(T.Attestation_encode(T.Attestation_default())))
    case 4: hloop(U32.to_nat(ops), 0, enc_h(T.ExecutionPayloadHeader_encode(T.ExecutionPayloadHeader_default())))
    case 5: sloop(U32.to_nat(ops), 0, T.Attestation_size(T.Attestation_default()))
    case 6: nloop(U32.to_nat(ops), 0)
    case 7: bloop(U32.to_nat(ops), 0)
    case 8: kloop(U32.to_nat(ops), 0)
    case 9: lloop(U32.to_nat(ops), 0)
    case _: hsloop(U32.to_nat(ops), 0, T.ExecutionPayloadHeader_size(T.ExecutionPayloadHeader_default()))

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def run(+mode: U32, +ops: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, pick_acc(mode, ops))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    run(mode, ops)
