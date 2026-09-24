import Base
import ../../proofs/nat_order.bend as Order
import ./words_spec.bend as WS
import ./mtree_defs.bend as MD

# Quotients are monotone (copied from proofs/bit_chunk_count.bend
# `quotient_lower` / `quotient_monotone`, whose module imports the bit packer),
# and the chunk count of 32q + r bytes (1 <= r) is at most the chunk limit of
# any capacity that holds them.

law quotient_lower:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  {Nat.is_le(d, Nat.div.fin(Nat.divmod.go(n, m, d, r))) == True{} : Bool}
def quotient_lower(n, m, d, r):
  match n:
    case 0n: Order.reflexive(d)
    case 1n+p:
      match m:
        case 0n:
          Order.transitive(d, 1n+d, Nat.div.fin(Nat.divmod.go(p, r, 1n+d, 0n)), Order.step_right(d, d, Order.reflexive(d)), quotient_lower(p, r, 1n+d, 0n))
        case 1n+q: quotient_lower(p, q, d, 1n+r)

law quotient_monotone:
  for +a: Nat
  for +b: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for le: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.div.fin(Nat.divmod.go(a, m, d, r)), Nat.div.fin(Nat.divmod.go(b, m, d, r))) == True{} : Bool}
def quotient_monotone(a, b, m, d, r, le):
  match a b:
    case 0n 0n: Order.reflexive(d)
    case 0n 1n+q: quotient_lower(1n+q, m, d, r)
    case 1n+p 0n:
      Empty.absurd({Nat.is_le(Nat.div.fin(Nat.divmod.go(1n+p, m, d, r)), d) == True{} : Bool}, MD.false_true(le))
    case 1n+p 1n+q:
      match m:
        case 0n: quotient_monotone(p, q, r, 1n+d, 0n, le)
        case 1n+s: quotient_monotone(p, q, s, d, 1n+r, le)

law chunk_le:
  for +q: Nat
  for +r: Nat
  for +cap: Nat
  for +h1: {Nat.is_lt(0n, r) == True{} : Bool}
  for +h32: {Nat.is_le(r, 32n) == True{} : Bool}
  for +hn: {Nat.is_le(Nat.add(WS.e32(q), r), cap) == True{} : Bool}
  {Nat.is_le(1n+q, Nat.div(Nat.add(cap, 31n), 32n)) == True{} : Bool}
def chunk_le(q, r, cap, h1, h32, hn):
  %WS.chunks_count(q, r, h1, h32) : {Nat.is_le(_, Nat.div(Nat.add(cap, 31n), 32n)) == True{} : Bool}
  quotient_monotone(Nat.add(Nat.add(WS.e32(q), r), 31n), Nat.add(cap, 31n), 31n, 0n, 0n, Order.add_right(Nat.add(WS.e32(q), r), cap, 31n, hn))
