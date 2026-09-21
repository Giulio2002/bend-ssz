import Base
import ../compact/found.bend as F

# The cost model of the object operations, and what it comes to.
#
# The generated loops all have the same shape: a Nat that starts at the element
# count and drops by one per element, with a body whose cost does not depend on
# the element (a fixed-size container reads, writes or hashes the same number
# of words wherever it sits). cost__rep(c, k) is that loop: k+1 bodies of cost
# c. Decode, encode and the uncached root of a list of n elements are
# cost__rep(c, n-1) with their own c, so the closed form below is what makes
# them linear in n.
#
# cost__access is the cost of one indexed read or write in the reduction
# semantics the kernel uses: Array.get and Array.set walk down the array
# halving the size at each step, so they take as many steps as the array is
# deep - the same number for every index, which is what
# cost__access_index_free says. The native backend does not walk: it compiles
# an array to one contiguous block and the walk to a single indexed read or
# write of it (blk_read / blk_write in the emitted C, build/native/*.c), so
# indexed access of the compiled program is constant time. Both statements are
# about the same operation; only the first one is a theorem here.
#
# cost__copies is the storage cost of appending: the element array doubles when
# it fills, copying the elements it holds. Reaching 2^j elements copies
# 2^j - 1 elements in total - fewer than one per append - which is what
# amortised constant storage cost means.

def cost__rep(+c: Nat, k: Nat) -> Nat:
  match k:
    case 0n: c
    case 1n+q: Nat.add(c, cost__rep(c, q))

# k+1 bodies of cost c cost c*(k+1).
def cost__rep_closed(+c: Nat, +k: Nat) -> {cost__rep(c, k) == Nat.mul(c, 1n+k) : Nat}:
  match k:
    case 0n:
      %Equal.sym(Nat, Nat.mul(c, 1n+0n), Nat.add(c, Nat.mul(c, 0n)), F.lru_nat_algebra__mul_succ(c, 0n))
        : {cost__rep(c, 0n) == _ : Nat}
      %Equal.sym(Nat, Nat.mul(c, 0n), 0n, F.lru_nat_algebra__mul_zero(c)) : {cost__rep(c, 0n) == Nat.add(c, _) : Nat}
      Equal.sym(Nat, Nat.add(c, 0n), c, F.lru_nat_algebra__add_zero(c))
    case 1n+q:
      %Equal.sym(Nat, Nat.mul(c, 1n+1n+q), Nat.add(c, Nat.mul(c, 1n+q)), F.lru_nat_algebra__mul_succ(c, 1n+q))
        : {cost__rep(c, 1n+q) == _ : Nat}
      %Equal.sym(Nat, cost__rep(c, q), Nat.mul(c, 1n+q), cost__rep_closed(c, q))
        : {Nat.add(c, _) == Nat.add(c, Nat.mul(c, 1n+q)) : Nat}
      {==}

# One indexed read or write: the depth of the packed array, whatever the index.
def cost__access(+depth: Nat, +i: U32) -> Nat: depth

def cost__access_index_free(+depth: Nat, +i: U32, +j: U32) -> {cost__access(depth, i) == cost__access(depth, j) : Nat}:
  {==}

# Appending: growing to 2^j elements copies 2^j - 1 of them altogether.
def cost__copies(+j: Nat) -> Nat:
  match j:
    case 0n: 0n
    case 1n+q: Nat.add(F.spec_common__pow2(q), cost__copies(q))

def cost__add_sub(+v: Nat, +hp: {Nat.is_le(1n, v) == True{} : Bool})
    -> {Nat.add(v, Nat.sub(v, 1n)) == Nat.sub(Nat.add(v, v), 1n) : Nat}:
  match v:
    case 0n:
      Empty.absurd({Nat.add(0n, Nat.sub(0n, 1n)) == Nat.sub(Nat.add(0n, 0n), 1n) : Nat}, F.logic__false_true(hp))
    case 1n+p:
      %Equal.sym(Nat, Nat.sub(p, 0n), p, F.nat__sub_zero(p)) : {1n+Nat.add(p, _) == Nat.sub(Nat.add(p, 1n+p), 0n) : Nat}
      %Equal.sym(Nat, Nat.add(p, 1n+p), 1n+Nat.add(p, p), F.lru_nat_algebra__add_succ(p, p))
        : {1n+Nat.add(p, p) == Nat.sub(_, 0n) : Nat}
      Equal.sym(Nat, Nat.sub(1n+Nat.add(p, p), 0n), 1n+Nat.add(p, p), F.nat__sub_zero(1n+Nat.add(p, p)))

# 2^q + (2^q - 1) = 2^(q+1) - 1, given that 2^q is at least one.
def cost__pow_step(+q: Nat, +hp: {Nat.is_le(1n, F.spec_common__pow2(q)) == True{} : Bool})
    -> {Nat.add(F.spec_common__pow2(q), Nat.sub(F.spec_common__pow2(q), 1n)) == Nat.sub(F.spec_common__pow2(1n+q), 1n) : Nat}:
  %Equal.sym(Nat, Nat.double(F.spec_common__pow2(q)), Nat.add(F.spec_common__pow2(q), F.spec_common__pow2(q)),
      F.lru_nat_algebra__double_self(F.spec_common__pow2(q)))
    : {Nat.add(F.spec_common__pow2(q), Nat.sub(F.spec_common__pow2(q), 1n)) == Nat.sub(_, 1n) : Nat}
  cost__add_sub(F.spec_common__pow2(q), hp)

def cost__copies_closed(+j: Nat) -> {cost__copies(j) == Nat.sub(F.spec_common__pow2(j), 1n) : Nat}:
  match j:
    case 0n: {==}
    case 1n+q:
      %Equal.sym(Nat, cost__copies(q), Nat.sub(F.spec_common__pow2(q), 1n), cost__copies_closed(q))
        : {Nat.add(F.spec_common__pow2(q), _) == Nat.sub(F.spec_common__pow2(1n+q), 1n) : Nat}
      cost__pow_step(q, F.nat__pow2_pos(q))
