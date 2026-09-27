import Base
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ./vbuf.bend as VB

# The progressive bit list's representation bound. Its validator (O.bitlist_pick with no
# declared limit) accepts a window of len bytes only when len - 1 < 2^29 (536870912):
# the decoded bit count 8 (len - 1) + the delimiter's high bit is a U32 exactly then.
# Every window of a buffer on a word tree of depth d < 28 (len <= 4 2^d <= 2^29) passes,
# proved symbolically in d (the one closed power, 2^29, is only ever compared syntactically).

def lt29(+d: Nat, +len: U32, +m: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hl: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+m : Nat})
    -> {U32.is_lt(U32.sub(len, 1), 536870912) == True{} : Bool}:
  # len <= 4 2^d = 2^(2+d) <= 2^29
  +hq = FD.nat__le_trans(U32.to_nat(len), FD.spec_common__pow2(2n+d), FD.spec_common__pow2(29n), hl,
    FD.nat__pow2_mono(2n+d, 29n, FD.nat__lt_succ_le(d, 27n, hd)))
  +h1m = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(29n)) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hq)
  +hm = FD.nat__succ_le_lt(m, FD.spec_common__pow2(29n), h1m)
  # U32.to_nat(len - 1) == m
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1),
    FD.nat__zero_le(m))
  +es = Equal.trans(Nat, U32.to_nat(U32.sub(len, 1)), Nat.sub(U32.to_nat(len), 1n), m,
    FD.u32__sub_nat(len, 1, h1),
    FD.logic__subst(Nat, z => {Nat.sub(z, 1n) == m : Nat}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), FD.nat__add_sub_cancel(1n, m)))
  +hs = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(29n)) == True{} : Bool}, m, U32.to_nat(U32.sub(len, 1)), Equal.sym(Nat, U32.to_nat(U32.sub(len, 1)), m, es), hm)
  # the U32 comparison, through 2^29 == pow2u(29)
  Equal.trans(Bool, U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)), Nat.is_lt(U32.to_nat(U32.sub(len, 1)), FD.spec_common__pow2(29n)), True{},
    Equal.sym(Bool, Nat.is_lt(U32.to_nat(U32.sub(len, 1)), FD.spec_common__pow2(29n)), U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)),
      FD.array__lt_bridge(U32.sub(len, 1), 29n, {==}, U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)), {==})),
    hs)
