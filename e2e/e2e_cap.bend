import Base
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vdepth.bend as VD
import ./e2e_load.bend as L

# The capacity facts for the loader: a buffer of n bytes, n <= 4 * 2^k for some k < 29,
# is allocated at a depth d = B.capacity(n) with d < 29 (cap_lt), 2^d holds the words the
# loader packs its bytes into (cap_w) and 4 * 2^d holds its bytes (cap_q). The words of
# n bytes are nwn(n) = (n + 3) / 4, as VD's halvings.

def nwn(+x: Nat) -> Nat: VD.s_rng(2n, 3n+x)

law h2m:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VD.s_h2(a), VD.s_h2(b)) == True{} : Bool}
def h2m(a, b, e):
  match a b:
    case 0n _: Order.zero_le(VD.s_h2(b))
    case 1n 0n: Empty.absurd({Nat.is_le(0n, 0n) == True{} : Bool}, FD.logic__false_true(e))
    case 1n 1n+ +q: Order.zero_le(VD.s_h2(1n+q))
    case 2n+p 0n: Empty.absurd({Nat.is_le(VD.s_h2(2n+p), 0n) == True{} : Bool}, FD.logic__false_true(e))
    case 2n+p 1n: Empty.absurd({Nat.is_le(VD.s_h2(2n+p), 0n) == True{} : Bool}, FD.logic__false_true(e))
    case 2n+ +p 2n+ +q: h2m(p, q, e)

law rgm:
  for +l: Nat
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VD.s_rng(l, a), VD.s_rng(l, b)) == True{} : Bool}
def rgm(l, a, b, e):
  match l:
    case 0n: e
    case 1n+ +k: h2m(VD.s_rng(k, a), VD.s_rng(k, b), rgm(k, a, b, e))

law rq:
  for +m: Nat
  {nwn(A.quad(m)) == m : Nat}
def rq(m):
  match m:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, nwn(A.quad(p)), p, rq(p)) : {1n+_ == 1n+p : Nat}
      {==}

# y <= 4 * nwn(y)
law ng:
  for +y: Nat
  {Nat.is_le(y, A.quad(nwn(y))) == True{} : Bool}
def ng(y):
  match y:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +z: ng(z)

# y <= 4 * P: nwn(y) <= P
def nle(+y: Nat, +P: Nat, +h: {Nat.is_le(y, A.quad(P)) == True{} : Bool}) -> {Nat.is_le(nwn(y), P) == True{} : Bool}:
  %rq(P) : {Nat.is_le(nwn(y), _) == True{} : Bool}
  rgm(2n, 3n+y, 3n+A.quad(P), h)

def q4(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(A.quad(a), A.quad(b)) == True{} : Bool}:
  FD.nat__double_le(Nat.double(a), Nat.double(b), FD.nat__double_le(a, b, h))

# the runtime's word count (n + 3) >> 2 is nwn(n), for n <= 4 * 2^k, k < 29
def nwu(+n: U32) -> U32: U32.shrn((n + 3 : U32), 2n)
def nw(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {U32.to_nat(nwu(n)) == nwn(U32.to_nat(n)) : Nat}:
  +Q = A.quad(FD.spec_common__pow2(k))
  +h3 = FD.nat__le_trans(3n, 4n, Q, {==}, q4(1n, FD.spec_common__pow2(k), FD.nat__pow2_pos(k)))
  +hab = FD.nat__le_trans(Nat.add(U32.to_nat(n), 3n), Nat.add(Q, 3n), Nat.add(Q, Q), Order.add_right(U32.to_nat(n), Q, 3n, h), Order.add_left(Q, 3n, Q, h3))
  +hc = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(n), 3n), z) == True{} : Bool}, Nat.add(Q, Q), Nat.double(Q), Equal.sym(Nat, Nat.double(Q), Nat.add(Q, Q), FD.lru_nat_algebra__double_self(Q)), hab)
  +hd = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(n), 3n), z) == True{} : Bool}, FD.spec_common__pow2(Nat.add(3n, k)), O.pow2n(Nat.add(3n, k)), VD.s_pow2_eq(Nat.add(3n, k)), hc)
  +e1 = VD.shrk(2n, (n + 3 : U32))
  +e2 = VD.s_add_nat(n, 3, Nat.add(3n, k), hk, hd)
  Equal.trans(Nat, U32.to_nat(nwu(n)), VD.s_rng(2n, U32.to_nat((n + 3 : U32))), nwn(U32.to_nat(n)), e1,
    Equal.trans(Nat, VD.s_rng(2n, U32.to_nat((n + 3 : U32))), VD.s_rng(2n, Nat.add(U32.to_nat(n), 3n)), nwn(U32.to_nat(n)),
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat((n + 3 : U32)), Nat.add(U32.to_nat(n), 3n), e2),
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), Nat.add(U32.to_nat(n), 3n), 3n+U32.to_nat(n), FD.nat__add_comm(U32.to_nat(n), 3n))))

# the words fit 2^k
def nwk(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(nwu(n)), O.pow2n(k)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(nwu(n)), nwn(U32.to_nat(n)), nw(n, k, hk, h)) : {Nat.is_le(_, O.pow2n(k)) == True{} : Bool}
  %VD.s_pow2_eq(k) : {Nat.is_le(nwn(U32.to_nat(n)), _) == True{} : Bool}
  nle(U32.to_nat(n), FD.spec_common__pow2(k), h)

# d = B.capacity(n) <= k
def cap_le(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(B.capacity(n), k) == True{} : Bool}:
  VD.wd_min(nwu(n), k, nwk(n, k, hk, h))

# d = B.capacity(n) < 29
def cap_lt(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_lt(B.capacity(n), 29n) == True{} : Bool}:
  FD.nat__le_lt_trans(B.words_depth(nwu(n)), k, 29n, VD.wd_min(nwu(n), k, nwk(n, k, hk, h)), hk)

def cap_32(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_lt(B.capacity(n), 32n) == True{} : Bool}:
  FD.nat__lt_le_trans(B.capacity(n), 29n, 32n, cap_lt(n, k, hk, h), {==})

# nwn(n) <= 2^d
def cap_n(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(nwn(U32.to_nat(n)), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}:
  +hk32 = FD.nat__le_trans(k, 29n, 32n, FD.nat__lt_le(k, 29n, hk), {==})
  %nw(n, k, hk, h) : {Nat.is_le(_, FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  %Equal.sym(Nat, FD.spec_common__pow2(B.capacity(n)), O.pow2n(B.capacity(n)), VD.s_pow2_eq(B.capacity(n))) : {Nat.is_le(U32.to_nat(nwu(n)), _) == True{} : Bool}
  VD.wd_cover(nwu(n), k, hk32, nwk(n, k, hk, h))

# 4 * 2^d holds the n bytes
def cap_q(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(B.capacity(n)))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(n), A.quad(nwn(U32.to_nat(n))), A.quad(FD.spec_common__pow2(B.capacity(n))), ng(U32.to_nat(n)),
    q4(nwn(U32.to_nat(n)), FD.spec_common__pow2(B.capacity(n)), cap_n(n, k, hk, h)))

# the loader packs a byte list into nwn(its length) words
def RL(+g: Nat) -> Type:
  @+r: +List<U32> -> @+hf: {Nat.is_le(List.length(&2, U32, r), g) == True{} : Bool} -> {FD.spec_common__length(U32, L.wlp(r)) == nwn(List.length(&2, U32, r)) : Nat}

def ln4(+a: U32, +b: U32, +c: U32, +d: U32, +r: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, Con{b, Con{c, Con{d, r}}}})) == nwn(List.length(&2, U32, Con{a, Con{b, Con{c, Con{d, r}}}})) : Nat}:
  Equal.cong(Nat, Nat, z => 1n+z, FD.spec_common__length(U32, L.wlp(r)), nwn(List.length(&2, U32, r)),
    rec(r, FD.nat__le_trans(List.length(&2, U32, r), 3n+List.length(&2, U32, r), g, L.le3(List.length(&2, U32, r)), hf)))

def ln3(+a: U32, +b: U32, +c: U32, +t: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, Con{c, t}}}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, Con{b, Con{c, t}}})) == nwn(List.length(&2, U32, Con{a, Con{b, Con{c, t}}})) : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+d, +r}: ln4(a, b, c, d, r, g, hf, rec)

def ln2(+a: U32, +b: U32, +t: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, Con{b, t}}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, Con{b, t}})) == nwn(List.length(&2, U32, Con{a, Con{b, t}})) : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+c, +r}: ln3(a, b, c, r, g, hf, rec)

def ln1(+a: U32, +t: +List<U32>, +g: Nat, +hf: {Nat.is_le(List.length(&2, U32, Con{a, t}), 1n+g) == True{} : Bool}, rec: RL(g))
    -> {FD.spec_common__length(U32, L.wlp(Con{a, t})) == nwn(List.length(&2, U32, Con{a, t})) : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+b, +r}: ln2(a, b, r, g, hf, rec)

def lnf(+f: Nat, +bs: +List<U32>, +hf: {Nat.is_le(List.length(&2, U32, bs), f) == True{} : Bool}) -> {FD.spec_common__length(U32, L.wlp(bs)) == nwn(List.length(&2, U32, bs)) : Nat}:
  match f bs:
    case _ Nil{}: {==}
    case 0n Con{+a, +t}: Empty.absurd({FD.spec_common__length(U32, L.wlp(Con{a, t})) == nwn(List.length(&2, U32, Con{a, t})) : Nat}, FD.logic__false_true(hf))
    case 1n+ +g Con{+a, +t}: ln1(a, t, g, hf, r => hfr => lnf(g, r, hfr))

def ln(+bs: +List<U32>) -> {FD.spec_common__length(U32, L.wlp(bs)) == nwn(List.length(&2, U32, bs)) : Nat}:
  lnf(List.length(&2, U32, bs), bs, FD.nat__le_refl(List.length(&2, U32, bs)))

# 2^d holds the loader's words of n bytes
def cap_w(+bs: +List<U32>, +n: U32, +k: Nat, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hk: {Nat.is_lt(k, 29n) == True{} : Bool},
    +h: {Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(k))) == True{} : Bool})
    -> {Nat.is_le(FD.spec_common__length(U32, L.wlp(bs)), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, L.wlp(bs)), nwn(List.length(&2, U32, bs)), ln(bs)) : {Nat.is_le(_, FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, bs), U32.to_nat(n), hn) : {Nat.is_le(nwn(_), FD.spec_common__pow2(B.capacity(n))) == True{} : Bool}
  cap_n(n, k, hk, h)
