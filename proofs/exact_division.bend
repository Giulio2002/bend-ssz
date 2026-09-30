import Base
import ./packing.bend as P

# Exact Base division of a multiple: no bound on either operand.
law block:
  for +m: Nat
  for +n: Nat
  for +d: Nat
  for +r: Nat
  {Nat.divmod.go(Nat.add(1n+m, n), m, d, r) == Nat.divmod.go(n, Nat.add(r, m), 1n+d, 0n) : Nat & Nat}
def block(m, n, d, r):
  match m:
    case 0n:
      %Equal.sym(Nat, Nat.add(r, 0n), r, P.add_zero(r)) : {Nat.divmod.go(n, r, 1n+d, 0n) == Nat.divmod.go(n, _, 1n+d, 0n) : Nat & Nat}
      {==}
    case 1n+mp:
      %Equal.sym(Nat, Nat.add(r, 1n+mp), 1n+Nat.add(r, mp), P.add_succ(r, mp)) : {Nat.divmod.go(Nat.add(1n+mp, n), mp, d, 1n+r) == Nat.divmod.go(n, _, 1n+d, 0n) : Nat & Nat}
      block(mp, n, d, 1n+r)

law multiple:
  for +k: Nat
  for +w: Nat
  for +d: Nat
  {Nat.divmod.go(Nat.mul(k, 1n+w), w, d, 0n) == (Nat.add(k, d), 0n) : Nat & Nat}
def multiple(k, w, d):
  match k:
    case 0n: {==}
    case 1n+kp:
      Equal.trans(Nat & Nat, Nat.divmod.go(Nat.add(1n+w, Nat.mul(kp, 1n+w)), w, d, 0n), Nat.divmod.go(Nat.mul(kp, 1n+w), w, 1n+d, 0n), (1n+Nat.add(kp, d), 0n),
        block(w, Nat.mul(kp, 1n+w), d, 0n),
        %P.add_succ(kp, d) : {Nat.divmod.go(Nat.mul(kp, 1n+w), w, 1n+d, 0n) == (_, 0n) : Nat & Nat}
        multiple(kp, w, 1n+d))

law quotient:
  for +k: Nat
  for +w: Nat
  {Nat.div(Nat.mul(k, 1n+w), 1n+w) == k : Nat}
def quotient(k, w):
  Equal.trans(Nat, Nat.div(Nat.mul(k, 1n+w), 1n+w), Nat.add(k, 0n), k,
    Equal.cong(Nat & Nat, Nat, x => Pair.fst(Nat, Nat, x), Nat.divmod.go(Nat.mul(k, 1n+w), w, 0n, 0n), (Nat.add(k, 0n), 0n), multiple(k, w, 0n)),
    P.add_zero(k))

law remainder:
  for +k: Nat
  for +w: Nat
  {Nat.mod(Nat.mul(k, 1n+w), 1n+w) == 0n : Nat}
def remainder(k, w):
  Equal.cong(Nat & Nat, Nat, x => Pair.snd(Nat, Nat, x), Nat.divmod.go(Nat.mul(k, 1n+w), w, 0n, 0n), (Nat.add(k, 0n), 0n), multiple(k, w, 0n))
