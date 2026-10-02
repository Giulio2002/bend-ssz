@@ ARR @@

# ---- a read leaves the buffer as it is ----------------------------------------------------------

def TH(+t: F.array__Tree<U32>) -> Array<U32>: F.array__thaw(U32, t)
def GV(+t: F.array__Tree<U32>, +n: U32, +i: U32, +z: Bool) -> U32: Pair.snd(Array<U32>, U32, Array.get.go(U32, TH(t), n, i, z))

def ggo(+t: F.array__Tree<U32>, +n: U32, +i: U32, +z: Bool) -> {Array.get.go(U32, TH(t), n, i, z) == (TH(t), GV(t, n, i, z)) : Array<U32> & U32}:
  match t z:
    case F.TLeaf{+x} _: {==}
    case F.TNode{+l, +r} True{}:
      +h = U32.shr(n)
      +zl = U32.is_lt(i, U32.shr(h))
      %Equal.sym(Array<U32> & U32, Array.get.go(U32, TH(l), h, i, zl), (TH(l), GV(l, h, i, zl)), ggo(l, h, i, zl)) :
        {Array.swap.lo(U32, TH(r), _) == (ANode{TH(l), TH(r)}, Pair.snd(Array<U32>, U32, Array.swap.lo(U32, TH(r), _))) : Array<U32> & U32}
      {==}
    case F.TNode{+l, +r} False{}:
      +h = U32.shr(n)
      +j = U32.sub(i, h)
      +zr = U32.is_lt(j, U32.shr(h))
      %Equal.sym(Array<U32> & U32, Array.get.go(U32, TH(r), h, j, zr), (TH(r), GV(r, h, j, zr)), ggo(r, h, j, zr)) :
        {Array.swap.hi(U32, TH(l), _) == (ANode{TH(l), TH(r)}, Pair.snd(Array<U32>, U32, Array.swap.hi(U32, TH(l), _))) : Array<U32> & U32}
      {==}

def SZ(+t: F.array__Tree<U32>) -> U32: Pair.snd(Array<U32>, U32, Array.size(U32, TH(t)))

def gsz(+t: F.array__Tree<U32>) -> {Array.size(U32, TH(t)) == (TH(t), SZ(t)) : Array<U32> & U32}:
  match t:
    case F.TLeaf{+x}: {==}
    case F.TNode{+l, +r}:
      %Equal.sym(Array<U32> & U32, Array.size(U32, TH(l)), (TH(l), SZ(l)), gsz(l)) :
        {Array.size.node(U32, TH(r), _) == (ANode{TH(l), TH(r)}, Pair.snd(Array<U32>, U32, Array.size.node(U32, TH(r), _))) : Array<U32> & U32}
      {==}

def GW(+t: F.array__Tree<U32>, +i: U32) -> U32: GV(t, SZ(t), U32.and(i, U32.sub(SZ(t), 1)), U32.is_lt(U32.and(i, U32.sub(SZ(t), 1)), U32.shr(SZ(t))))

def gget(+t: F.array__Tree<U32>, +i: U32) -> {Array.get(U32, TH(t), i) == (TH(t), GW(t, i)) : Array<U32> & U32}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, TH(t)), (TH(t), SZ(t)), gsz(t)) : {Array.get.at(U32, i, _) == (TH(t), GW(t, i)) : Array<U32> & U32}
  ggo(t, SZ(t), U32.and(i, U32.sub(SZ(t), 1)), U32.is_lt(U32.and(i, U32.sub(SZ(t), 1)), U32.shr(SZ(t))))

# The word at any index i (in the buffer or not): the buffer comes back as it was.
def wsame(+t: F.array__Tree<U32>, +n: U32, +i: U32) -> {B.word(UA.BF(t, n), i) == (UA.BF(t, n), GW(t, i)) : B.Buf & U32}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, TH(t), i), (TH(t), GW(t, i)), gget(t, i)) : {B.rewrap(n, _) == (UA.BF(t, n), GW(t, i)) : B.Buf & U32}
  {==}

def rc(+t: F.array__Tree<U32>, +n: U32, +X: U32, +j: U32, +a: Bool)
    -> {B.read32_choose(X, j, a, UA.BF(t, n)) == (UA.BF(t, n), Pair.snd(B.Buf, U32, B.read32_choose(X, j, a, UA.BF(t, n)))) : B.Buf & U32}:
  match a:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.shrn(X, 2n)), (UA.BF(t, n), GW(t, U32.shrn(X, 2n))), wsame(t, n, U32.shrn(X, 2n))) :
        {_ == (UA.BF(t, n), Pair.snd(B.Buf, U32, _)) : B.Buf & U32}
      {==}
    case False{}:
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.shrn(X, 2n)), (UA.BF(t, n), GW(t, U32.shrn(X, 2n))), wsame(t, n, U32.shrn(X, 2n))) :
        {B.read32_split(X, j, _) == (UA.BF(t, n), Pair.snd(B.Buf, U32, B.read32_split(X, j, _))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (UA.BF(t, n), GW(t, U32.add(U32.shrn(X, 2n), 1))), wsame(t, n, U32.add(U32.shrn(X, 2n), 1))) :
        {B.join_words(j, GW(t, U32.shrn(X, 2n)), _) == (UA.BF(t, n), Pair.snd(B.Buf, U32, B.join_words(j, GW(t, U32.shrn(X, 2n)), _))) : B.Buf & U32}
      {==}

# The four bytes the runtime reads at any X, and read32 leaves the buffer as it is.
def RV(+t: F.array__Tree<U32>, +n: U32, +X: U32) -> U32: Pair.snd(B.Buf, U32, B.read32(UA.BF(t, n), X))

def rd_same(+t: F.array__Tree<U32>, +n: U32, +X: U32) -> {B.read32(UA.BF(t, n), X) == (UA.BF(t, n), RV(t, n, X)) : B.Buf & U32}:
  rc(t, n, X, U32.and(X, 3), U32.is_eq(U32.and(X, 3), 0))

# 4 q + 3 + 2 <= 4 P gives q + 1 < P.
def q1x(+q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(A.quad(q), 3n), 2n), A.quad(P)) == True{} : Bool}) -> {Nat.is_lt(1n+q, P) == True{} : Bool}:
  +e5 = Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), 3n), 2n), Nat.add(A.quad(q), 5n), Nat.add(5n, A.quad(q)), F.nat__add_assoc(A.quad(q), 3n, 2n), F.nat__add_comm(A.quad(q), 5n))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(P)) == True{} : Bool}, Nat.add(Nat.add(A.quad(q), 3n), 2n), Nat.add(5n, A.quad(q)), e5, h)
  VR.lt_quad(1n+q, P, F.nat__lt_le_trans(A.quad(1n+q), Nat.add(5n, A.quad(q)), A.quad(P), F.nat__lt_succ(Nat.add(4n, A.quad(q))), h2))

