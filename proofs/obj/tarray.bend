import Base
import ../compact/found.bend as F

# Array laws for elements of any kind (Type-kind too: boxed containers, which cannot be copied, so
# the Data mirror of proofs/compact/found.bend's array laws does not apply). Array.swap is described
# by two structural functions over the array: put (the array after the write) and old (the element
# that was there). No premise on the array's shape or on the index is needed: both swaps of a
# write-then-read walk the same path, which depends only on the size and the index.
#
# This file is the only one that unfolds Base's Array.swap.go / Array.size (checker c55a7f03's
# Base: swap.go(a, n, i, v, z), z the caller's bit test).

# the size Array.size computes (2^depth along the left spine)
def sz(-T: Type, a: Array<T>) -> U32:
  match a:
    case ALeaf{x}: 1
    case ANode{xs, ys}: U32.shl(sz(T, xs))

# the array after swap.go writes v
def put(-T: Type, a: Array<T>, n: U32, +i: U32, v: T, z: Bool) -> Array<T>:
  match a z:
    case ALeaf{x} _: ALeaf{v}
    case ANode{xs, ys} True{}:
      +h = U32.shr(n)
      ANode{put(T, xs, h, i, v, U32.is_lt(i, U32.shr(h))), ys}
    case ANode{xs, ys} False{}:
      +h = U32.shr(n)
      +j = U32.sub(i, h)
      ANode{xs, put(T, ys, h, j, v, U32.is_lt(j, U32.shr(h)))}

# the element swap.go returns
def old(-T: Type, a: Array<T>, n: U32, +i: U32, z: Bool) -> T:
  match a z:
    case ALeaf{x} _: x
    case ANode{xs, ys} True{}:
      +h = U32.shr(n)
      old(T, xs, h, i, U32.is_lt(i, U32.shr(h)))
    case ANode{xs, ys} False{}:
      +h = U32.shr(n)
      +j = U32.sub(i, h)
      old(T, ys, h, j, U32.is_lt(j, U32.shr(h)))

def size_sz(-T: Type, a: Array<T>) -> {Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32}:
  match a:
    case ALeaf{x}: {==}
    case ANode{xs, ys}:
      %Equal.sym(Array<T> & U32, Array.size(T, xs), (xs, sz(T, xs)), size_sz(T, xs)) : {Array.size.node(T, ys, _) == (ANode{xs, ys}, U32.shl(sz(T, xs))) : Array<T> & U32}
      {==}

def go_l1(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.swap.go(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T})
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))), ih) : {Array.swap.lo(T, ys, _) == (put(T, ANode{xs, ys}, n, i, w, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T}
  {==}

def go_l2(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.swap.go(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T})
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, u, True{}) == (put(T, ANode{xs, ys}, n, i, u, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), (put(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))), ih) : {Array.swap.lo(T, ys, _) == (put(T, ANode{xs, ys}, n, i, u, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T}
  {==}

def go_l3(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.swap.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), w) : Array<T> & T})
    -> {Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, i, u, True{}) == (put(T, ANode{xs, ys}, n, i, u, True{}), w) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), (put(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), w), ih) : {Array.swap.lo(T, ys, _) == (put(T, ANode{xs, ys}, n, i, u, True{}), w) : Array<T> & T}
  {==}

def go_r1(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T})
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))), ih) : {Array.swap.hi(T, xs, _) == (put(T, ANode{xs, ys}, n, i, w, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T}
  {==}

def go_r2(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T})
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, u, False{}) == (put(T, ANode{xs, ys}, n, i, u, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))), ih) : {Array.swap.hi(T, xs, _) == (put(T, ANode{xs, ys}, n, i, u, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T}
  {==}

def go_r3(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.swap.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), w) : Array<T> & T})
    -> {Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, i, u, False{}) == (put(T, ANode{xs, ys}, n, i, u, False{}), w) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), w), ih) : {Array.swap.hi(T, xs, _) == (put(T, ANode{xs, ys}, n, i, u, False{}), w) : Array<T> & T}
  {==}

def size_node(-T: Type, -xs: Array<T>, -ys: Array<T>, +ih: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32})
    -> {Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32}:
  %Equal.sym(Array<T> & U32, Array.size(T, xs), (xs, sz(T, xs)), ih) : {Array.size.node(T, ys, _) == (ANode{xs, ys}, U32.shl(sz(T, xs))) : Array<T> & U32}
  {==}

def size_put_l(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.size(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32})
    -> {Array.size(T, put(T, ANode{xs, ys}, n, i, w, True{})) == (put(T, ANode{xs, ys}, n, i, w, True{}), sz(T, ANode{xs, ys})) : Array<T> & U32}:
  %Equal.sym(Array<T> & U32, Array.size(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))))), (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)), ih) : {Array.size.node(T, ys, _) == (put(T, ANode{xs, ys}, n, i, w, True{}), U32.shl(sz(T, xs))) : Array<T> & U32}
  {==}

def size_put_r(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, +ih: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32})
    -> {Array.size(T, put(T, ANode{xs, ys}, n, i, w, False{})) == (put(T, ANode{xs, ys}, n, i, w, False{}), sz(T, ANode{xs, ys})) : Array<T> & U32}:
  %Equal.sym(Array<T> & U32, Array.size(T, xs), (xs, sz(T, xs)), ih) : {Array.size.node(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), _) == (put(T, ANode{xs, ys}, n, i, w, False{}), U32.shl(sz(T, xs))) : Array<T> & U32}
  {==}

# Everything a write-then-swap at one position needs, by one induction (the array and the two values
# are used once each: Type-kind values cannot be copied, so the facts cannot be separate lemmas):
# swap.go writing w, and writing u, are put / old; after writing w, swap.go of u returns w and the
# array writing u directly gives; Array.size of the array, and of the written array, is sz.
def rw_l(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, ih: {Array.swap.go(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, u, U32.is_lt(i, U32.shr(U32.shr(n)))), w) : Array<T> & T} & ({Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({Array.size(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32})))))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, i, u, True{}) == (put(T, ANode{xs, ys}, n, i, u, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, i, u, True{}) == (put(T, ANode{xs, ys}, n, i, u, True{}), w) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, True{})) == (put(T, ANode{xs, ys}, n, i, w, True{}), sz(T, ANode{xs, ys})) : Array<T> & U32})))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (+h3, r3) = r2
  (+h4, h5) = r3
  (go_l1(T, xs, ys, n, i, w, u, h1), (go_l2(T, xs, ys, n, i, w, u, h2), (go_l3(T, xs, ys, n, i, w, u, h3), (size_node(T, xs, ys, h4), size_put_l(T, xs, ys, n, i, w, u, h5)))))

def rw_r(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, -u: T, ih: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), w) : Array<T> & T} & ({Array.size(T, ys) == (ys, sz(T, ys)) : Array<T> & U32} & ({Array.size(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, ys)) : Array<T> & U32})))), +sx: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32})
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, i, u, False{}) == (put(T, ANode{xs, ys}, n, i, u, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, i, u, False{}) == (put(T, ANode{xs, ys}, n, i, u, False{}), w) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, False{})) == (put(T, ANode{xs, ys}, n, i, w, False{}), sz(T, ANode{xs, ys})) : Array<T> & U32})))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (+h3, r3) = r2
  (go_r1(T, xs, ys, n, i, w, u, h1), (go_r2(T, xs, ys, n, i, w, u, h2), (go_r3(T, xs, ys, n, i, w, u, h3), (size_node(T, xs, ys, sx), size_put_r(T, xs, ys, n, i, w, u, sx)))))

def rw(-T: Type, a: Array<T>, +n: U32, +i: U32, w: T, u: T, +z: Bool)
    -> {Array.swap.go(T, a, n, i, w, z) == (put(T, a, n, i, w, z), old(T, a, n, i, z)) : Array<T> & T} & ({Array.swap.go(T, a, n, i, u, z) == (put(T, a, n, i, u, z), old(T, a, n, i, z)) : Array<T> & T} & ({Array.swap.go(T, put(T, a, n, i, w, z), n, i, u, z) == (put(T, a, n, i, u, z), w) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, n, i, w, z)) == (put(T, a, n, i, w, z), sz(T, a)) : Array<T> & U32})))):
  match a z:
    case ALeaf{x} _: ({==}, ({==}, ({==}, ({==}, {==}))))
    case ANode{xs, ys} True{}: rw_l(T, xs, ys, n, i, w, u, rw(T, xs, U32.shr(n), i, w, u, U32.is_lt(i, U32.shr(U32.shr(n)))))
    case ANode{xs, ys} False{}: rw_r(T, xs, ys, n, i, w, u, rw(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, u, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), size_sz(T, xs))

# ---- the public entry point ----
# the index and the bit test Array.swap.at computes from the size N
def J(+n: U32, +i: U32) -> U32: U32.and(i, U32.sub(n, 1))
def Z(+n: U32, +i: U32) -> Bool: U32.is_lt(J(n, i), U32.shr(n))

def set_step(-T: Type, -a: Array<T>, -N: U32, -i: U32, -v: T, +hz: {sz(T, a) == N : U32},
    +f: {Array.swap.go(T, a, N, J(N, i), v, Z(N, i)) == (put(T, a, N, J(N, i), v, Z(N, i)), old(T, a, N, J(N, i), Z(N, i))) : Array<T> & T}, +s: {Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32})
    -> {Array.set(T, a, i, v) == put(T, a, N, J(N, i), v, Z(N, i)) : Array<T>}:
  %Equal.sym(Array<T> & U32, Array.size(T, a), (a, sz(T, a)), s) : {Array.set.fin(T, Array.swap.at(T, i, v, _)) == put(T, a, N, J(N, i), v, Z(N, i)) : Array<T>}
  %Equal.sym(U32, sz(T, a), N, hz) : {Array.set.fin(T, Array.swap.at(T, i, v, (a, _))) == put(T, a, N, J(N, i), v, Z(N, i)) : Array<T>}
  %Equal.sym(Array<T> & T, Array.swap.go(T, a, N, J(N, i), v, Z(N, i)), (put(T, a, N, J(N, i), v, Z(N, i)), old(T, a, N, J(N, i), Z(N, i))), f) : {Array.set.fin(T, _) == put(T, a, N, J(N, i), v, Z(N, i)) : Array<T>}
  {==}

# Swapping u into the position just written returns the value written, and leaves the array that
# writing u directly gives: for every array (of size N) and every index.
def swap_set_go(-T: Type, -a: Array<T>, -N: U32, -i: U32, -w: T, -u: T, +hz: {sz(T, a) == N : U32}, b: {Array.swap.go(T, a, N, J(N, i), w, Z(N, i)) == (put(T, a, N, J(N, i), w, Z(N, i)), old(T, a, N, J(N, i), Z(N, i))) : Array<T> & T} & ({Array.swap.go(T, a, N, J(N, i), u, Z(N, i)) == (put(T, a, N, J(N, i), u, Z(N, i)), old(T, a, N, J(N, i), Z(N, i))) : Array<T> & T} & ({Array.swap.go(T, put(T, a, N, J(N, i), w, Z(N, i)), N, J(N, i), u, Z(N, i)) == (put(T, a, N, J(N, i), u, Z(N, i)), w) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, N, J(N, i), w, Z(N, i))) == (put(T, a, N, J(N, i), w, Z(N, i)), sz(T, a)) : Array<T> & U32})))))
    -> {Array.swap(T, Array.set(T, a, i, w), i, u) == (Array.set(T, a, i, u), w) : Array<T> & T}:
  (+f1, r1) = b
  (+f2, r2) = r1
  (+f3, r3) = r2
  (+f4, f5) = r3
  %Equal.sym(Array<T>, Array.set(T, a, i, w), put(T, a, N, J(N, i), w, Z(N, i)), set_step(T, a, N, i, w, hz, f1, f4)) : {Array.swap(T, _, i, u) == (Array.set(T, a, i, u), w) : Array<T> & T}
  %Equal.sym(Array<T>, Array.set(T, a, i, u), put(T, a, N, J(N, i), u, Z(N, i)), set_step(T, a, N, i, u, hz, f2, f4)) : {Array.swap(T, put(T, a, N, J(N, i), w, Z(N, i)), i, u) == (_, w) : Array<T> & T}
  %Equal.sym(Array<T> & U32, Array.size(T, put(T, a, N, J(N, i), w, Z(N, i))), (put(T, a, N, J(N, i), w, Z(N, i)), sz(T, a)), f5) : {Array.swap.at(T, i, u, _) == (put(T, a, N, J(N, i), u, Z(N, i)), w) : Array<T> & T}
  %Equal.sym(U32, sz(T, a), N, hz) : {Array.swap.at(T, i, u, (put(T, a, N, J(N, i), w, Z(N, i)), _)) == (put(T, a, N, J(N, i), u, Z(N, i)), w) : Array<T> & T}
  f3

def swap_set_same(-T: Type, a: Array<T>, +N: U32, +i: U32, w: T, u: T, +hz: {sz(T, a) == N : U32})
    -> {Array.swap(T, Array.set(T, a, i, w), i, u) == (Array.set(T, a, i, u), w) : Array<T> & T}:
  swap_set_go(T, a, N, i, w, u, hz, rw(T, a, N, J(N, i), w, u, Z(N, i)))

# ---- Data elements: reading (Array.get, which copies) the position just written ----
def get_l(-T: Data, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, +ih: {Array.get.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), w) : Array<T> & T})
    -> {Array.get.go(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, i, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), w) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.get.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))), (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), w), ih) : {Array.swap.lo(T, ys, _) == (put(T, ANode{xs, ys}, n, i, w, True{}), w) : Array<T> & T}
  {==}

def get_r(-T: Data, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, +ih: {Array.get.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), w) : Array<T> & T})
    -> {Array.get.go(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, i, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), w) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.get.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), w), ih) : {Array.swap.hi(T, xs, _) == (put(T, ANode{xs, ys}, n, i, w, False{}), w) : Array<T> & T}
  {==}

def rg_l(-T: Data, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, ih: {Array.swap.go(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.get.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), w) : Array<T> & T} & ({Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({Array.size(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32}))))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T} & ({Array.get.go(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, i, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), w) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, True{})) == (put(T, ANode{xs, ys}, n, i, w, True{}), sz(T, ANode{xs, ys})) : Array<T> & U32}))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (+h3, h4) = r2
  (go_l1(T, xs, ys, n, i, w, w, h1), (get_l(T, xs, ys, n, i, w, h2), (size_node(T, xs, ys, h3), size_put_l(T, xs, ys, n, i, w, w, h4))))

def rg_r(-T: Data, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -w: T, ih: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.get.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), w) : Array<T> & T} & ({Array.size(T, ys) == (ys, sz(T, ys)) : Array<T> & U32} & ({Array.size(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, ys)) : Array<T> & U32}))), +sx: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32})
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T} & ({Array.get.go(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, i, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), w) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, False{})) == (put(T, ANode{xs, ys}, n, i, w, False{}), sz(T, ANode{xs, ys})) : Array<T> & U32}))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (go_r1(T, xs, ys, n, i, w, w, h1), (get_r(T, xs, ys, n, i, w, h2), (size_node(T, xs, ys, sx), size_put_r(T, xs, ys, n, i, w, w, sx))))

# swap.go writing w is put / old; Array.get.go of the written array at the same position returns w and
# the array unchanged; the sizes: by one induction, as rw
def rg(-T: Data, a: Array<T>, +n: U32, +i: U32, +w: T, +z: Bool)
    -> {Array.swap.go(T, a, n, i, w, z) == (put(T, a, n, i, w, z), old(T, a, n, i, z)) : Array<T> & T} & ({Array.get.go(T, put(T, a, n, i, w, z), n, i, z) == (put(T, a, n, i, w, z), w) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, n, i, w, z)) == (put(T, a, n, i, w, z), sz(T, a)) : Array<T> & U32}))):
  match a z:
    case ALeaf{x} _: ({==}, ({==}, ({==}, {==})))
    case ANode{xs, ys} True{}: rg_l(T, xs, ys, n, i, w, rg(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))))
    case ANode{xs, ys} False{}: rg_r(T, xs, ys, n, i, w, rg(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), size_sz(T, xs))

def get_set_go(-T: Data, -a: Array<T>, -N: U32, -i: U32, -w: T, +hz: {sz(T, a) == N : U32}, b: {Array.swap.go(T, a, N, J(N, i), w, Z(N, i)) == (put(T, a, N, J(N, i), w, Z(N, i)), old(T, a, N, J(N, i), Z(N, i))) : Array<T> & T} & ({Array.get.go(T, put(T, a, N, J(N, i), w, Z(N, i)), N, J(N, i), Z(N, i)) == (put(T, a, N, J(N, i), w, Z(N, i)), w) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, N, J(N, i), w, Z(N, i))) == (put(T, a, N, J(N, i), w, Z(N, i)), sz(T, a)) : Array<T> & U32}))))
    -> {Array.get(T, Array.set(T, a, i, w), i) == (Array.set(T, a, i, w), w) : Array<T> & T}:
  (+f1, r1) = b
  (+f2, r2) = r1
  (+f3, f4) = r2
  %Equal.sym(Array<T>, Array.set(T, a, i, w), put(T, a, N, J(N, i), w, Z(N, i)), set_step(T, a, N, i, w, hz, f1, f3)) : {Array.get(T, _, i) == (_, w) : Array<T> & T}
  %Equal.sym(Array<T> & U32, Array.size(T, put(T, a, N, J(N, i), w, Z(N, i))), (put(T, a, N, J(N, i), w, Z(N, i)), sz(T, a)), f4) : {Array.get.at(T, i, _) == (put(T, a, N, J(N, i), w, Z(N, i)), w) : Array<T> & T}
  %Equal.sym(U32, sz(T, a), N, hz) : {Array.get.at(T, i, (put(T, a, N, J(N, i), w, Z(N, i)), _)) == (put(T, a, N, J(N, i), w, Z(N, i)), w) : Array<T> & T}
  f2

# Reading the position just written returns the value written and leaves the array as written:
# for every array (of size N) of Data elements and every index.
def get_set_same(-T: Data, a: Array<T>, +N: U32, +i: U32, +w: T, +hz: {sz(T, a) == N : U32})
    -> {Array.get(T, Array.set(T, a, i, w), i) == (Array.set(T, a, i, w), w) : Array<T> & T}:
  get_set_go(T, a, N, i, w, hz, rg(T, a, N, J(N, i), w, Z(N, i)))
# ---- two different positions ----
# a perfect array of depth d (what Array.new builds, and swap keeps)
def tperf(-T: Type, +d: Nat, a: Array<T>) -> Type:
  match d a:
    case 0n ALeaf{x}: {True{} == True{} : Bool}
    case 0n ANode{xs, ys}: Empty
    case 1n+p ALeaf{x}: Empty
    case 1n+p ANode{xs, ys}: tperf(T, p, xs) & tperf(T, p, ys)

# whether the walks of swap.go to (i, zi) and to (j, zj) in a tree of depth d end at the same leaf
def sameD(+d: Nat, n: U32, +i: U32, zi: Bool, +j: U32, zj: Bool) -> Bool:
  match d zi zj:
    case 0n _ _: True{}
    case 1n+p True{} True{}:
      +h = U32.shr(n)
      sameD(p, h, i, U32.is_lt(i, U32.shr(h)), j, U32.is_lt(j, U32.shr(h)))
    case 1n+p False{} False{}:
      +h = U32.shr(n)
      sameD(p, h, U32.sub(i, h), U32.is_lt(U32.sub(i, h), U32.shr(h)), U32.sub(j, h), U32.is_lt(U32.sub(j, h), U32.shr(h)))
    case 1n+p True{} False{}: False{}
    case 1n+p False{} True{}: False{}

# one level of swap.go, in the left and in the right subtree
def LO(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -v: T, -z: Bool, -P: Array<T>, -o: T, +ih: {Array.swap.go(T, xs, n, i, v, z) == (P, o) : Array<T> & T})
    -> {Array.swap.lo(T, ys, Array.swap.go(T, xs, n, i, v, z)) == (ANode{P, ys}, o) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, xs, n, i, v, z), (P, o), ih) : {Array.swap.lo(T, ys, _) == (ANode{P, ys}, o) : Array<T> & T}
  {==}

def HI(-T: Type, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -v: T, -z: Bool, -P: Array<T>, -o: T, +ih: {Array.swap.go(T, ys, n, i, v, z) == (P, o) : Array<T> & T})
    -> {Array.swap.hi(T, xs, Array.swap.go(T, ys, n, i, v, z)) == (ANode{xs, P}, o) : Array<T> & T}:
  %Equal.sym(Array<T> & T, Array.swap.go(T, ys, n, i, v, z), (P, o), ih) : {Array.swap.hi(T, xs, _) == (ANode{xs, P}, o) : Array<T> & T}
  {==}

def size_node2(-T: Type, -l: Array<T>, -ys: Array<T>, -s: U32, +ih: {Array.size(T, l) == (l, s) : Array<T> & U32})
    -> {Array.size(T, ANode{l, ys}) == (ANode{l, ys}, U32.shl(s)) : Array<T> & U32}:
  %Equal.sym(Array<T> & U32, Array.size(T, l), (l, s), ih) : {Array.size.node(T, ys, _) == (ANode{l, ys}, U32.shl(s)) : Array<T> & U32}
  {==}

def pf_l(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, pf: tperf(T, p, xs) & tperf(T, p, ys)) -> tperf(T, p, xs):
  (l, r) = pf
  l

def pf_r(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, pf: tperf(T, p, xs) & tperf(T, p, ys)) -> tperf(T, p, ys):
  (l, r) = pf
  r


# a perfect array's size: Array.size returns sz, and sz is 2^d
def sp_n(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, ih: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))
    -> {Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}):
  (+h1, h2) = ih
  (size_node2(T, xs, ys, sz(T, xs), h1), Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), h2))

def sp(-T: Type, +d: Nat, a: Array<T>, pf: tperf(T, d, a))
    -> {Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({sz(T, a) == F.u32__pow2u(d) : U32}):
  match d a:
    case 0n ALeaf{x}: ({==}, {==})
    case 0n ANode{xs, ys}: Empty.absurd({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(0n) : U32}), pf)
    case 1n+p ALeaf{x}: Empty.absurd({Array.size(T, ALeaf{x}) == (ALeaf{x}, sz(T, ALeaf{x})) : Array<T> & U32} & ({sz(T, ALeaf{x}) == F.u32__pow2u(1n+p) : U32}), pf)
    case 1n+p ANode{xs, ys}: sp_n(T, p, xs, ys, sp(T, p, xs, pf_l(T, p, xs, ys, pf)))


# swap.go writing v is put / old, the sizes of the array and of the written array, and sz: one induction
def rs_l(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -v: T, ih: {Array.swap.go(T, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({Array.size(T, put(T, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, v, True{}) == (put(T, ANode{xs, ys}, n, i, v, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, v, True{})) == (put(T, ANode{xs, ys}, n, i, v, True{}), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (+h3, h4) = r2
  (LO(T, xs, ys, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n))), put(T, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))), h1), (size_node2(T, xs, ys, sz(T, xs), h2), (size_node2(T, put(T, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))), ys, sz(T, xs), h3), (Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), h4)))))

def rs_r(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -v: T, ih: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, ys) == (ys, sz(T, ys)) : Array<T> & U32} & ({Array.size(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, ys)) : Array<T> & U32} & ({sz(T, ys) == F.u32__pow2u(p) : U32}))), sx: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, v, False{}) == (put(T, ANode{xs, ys}, n, i, v, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, v, False{})) == (put(T, ANode{xs, ys}, n, i, v, False{}), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}))):
  (+h1, r1) = ih
  (+s1, s2) = sx
  (HI(T, xs, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), h1), (size_node2(T, xs, ys, sz(T, xs), s1), (size_node2(T, xs, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, xs), s1), (Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), s2)))))

def rs(-T: Type, +d: Nat, a: Array<T>, +n: U32, +i: U32, v: T, +z: Bool, pf: tperf(T, d, a))
    -> {Array.swap.go(T, a, n, i, v, z) == (put(T, a, n, i, v, z), old(T, a, n, i, z)) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, n, i, v, z)) == (put(T, a, n, i, v, z), sz(T, a)) : Array<T> & U32} & ({sz(T, a) == F.u32__pow2u(d) : U32}))):
  match d a z:
    case 0n ALeaf{x} _: ({==}, ({==}, ({==}, {==})))
    case 0n ANode{xs, ys} _: Empty.absurd({Array.swap.go(T, ANode{xs, ys}, n, i, v, z) == (put(T, ANode{xs, ys}, n, i, v, z), old(T, ANode{xs, ys}, n, i, z)) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, v, z)) == (put(T, ANode{xs, ys}, n, i, v, z), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(0n) : U32}))), pf)
    case 1n+p ALeaf{x} _: Empty.absurd({Array.swap.go(T, ALeaf{x}, n, i, v, z) == (put(T, ALeaf{x}, n, i, v, z), old(T, ALeaf{x}, n, i, z)) : Array<T> & T} & ({Array.size(T, ALeaf{x}) == (ALeaf{x}, sz(T, ALeaf{x})) : Array<T> & U32} & ({Array.size(T, put(T, ALeaf{x}, n, i, v, z)) == (put(T, ALeaf{x}, n, i, v, z), sz(T, ALeaf{x})) : Array<T> & U32} & ({sz(T, ALeaf{x}) == F.u32__pow2u(1n+p) : U32}))), pf)
    case 1n+p ANode{xs, ys} True{}: rs_l(T, p, xs, ys, n, i, v, rs(T, p, xs, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n))), pf_l(T, p, xs, ys, pf)))
    case 1n+p ANode{xs, ys} False{}:
      (pl, pr) = pf
      rs_r(T, p, xs, ys, n, i, v, rs(T, p, ys, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), pr), sp(T, p, xs, pl))

# Everything a write at (i, zi) followed by a swap at a different leaf (j, zj) needs, by one induction
# over a perfect array: both swaps on the array are put / old, the swap at j of the written array
# returns the element the array had at j (the write did not touch it), the sizes, and sz = 2^d.
def ro_ll(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -j: U32, -w: T, -u: T, ih: {Array.swap.go(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))) == (put(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({Array.size(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))))))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, j, u, True{}) == (put(T, ANode{xs, ys}, n, j, u, True{}), old(T, ANode{xs, ys}, n, j, True{})) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, j, u, True{}) == (put(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, j, u, True{}), old(T, ANode{xs, ys}, n, j, True{})) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, True{})) == (put(T, ANode{xs, ys}, n, i, w, True{}), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}))))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (+h3, r3) = r2
  (+h4, r4) = r3
  (+h5, h6) = r4
  (LO(T, xs, ys, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))), put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))), h1), (LO(T, xs, ys, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n))), put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))), h2), (LO(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), ys, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n))), put(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))), h3), (size_node2(T, xs, ys, sz(T, xs), h4), (size_node2(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), ys, sz(T, xs), h5), (Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), h6)))))))

def ro_rr(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -j: U32, -w: T, -u: T, ih: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.swap.go(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, ys) == (ys, sz(T, ys)) : Array<T> & U32} & ({Array.size(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, ys)) : Array<T> & U32} & ({sz(T, ys) == F.u32__pow2u(p) : U32}))))), sx: {Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, j, u, False{}) == (put(T, ANode{xs, ys}, n, j, u, False{}), old(T, ANode{xs, ys}, n, j, False{})) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, j, u, False{}) == (put(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, j, u, False{}), old(T, ANode{xs, ys}, n, j, False{})) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, False{})) == (put(T, ANode{xs, ys}, n, i, w, False{}), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}))))):
  (+h1, r1) = ih
  (+h2, r2) = r1
  (+h3, r3) = r2
  (+s1, s2) = sx
  (HI(T, xs, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), h1), (HI(T, xs, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))), put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), h2), (HI(T, xs, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))), put(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), h3), (size_node2(T, xs, ys, sz(T, xs), s1), (size_node2(T, xs, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, xs), s1), (Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), s2)))))))

def ro_lr(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -j: U32, -w: T, -u: T, ia: {Array.swap.go(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({Array.size(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))), ib: {Array.swap.go(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, ys) == (ys, sz(T, ys)) : Array<T> & U32} & ({Array.size(T, put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))))) == (put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, ys)) : Array<T> & U32} & ({sz(T, ys) == F.u32__pow2u(p) : U32}))))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, True{}) == (put(T, ANode{xs, ys}, n, i, w, True{}), old(T, ANode{xs, ys}, n, i, True{})) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, j, u, False{}) == (put(T, ANode{xs, ys}, n, j, u, False{}), old(T, ANode{xs, ys}, n, j, False{})) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, j, u, False{}) == (put(T, put(T, ANode{xs, ys}, n, i, w, True{}), n, j, u, False{}), old(T, ANode{xs, ys}, n, j, False{})) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, True{})) == (put(T, ANode{xs, ys}, n, i, w, True{}), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}))))):
  (+a1, ra) = ia
  (+a2, rb) = ra
  (+a3, a4) = rb
  (+b1, rc) = ib
  (LO(T, xs, ys, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))), put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))), a1), (HI(T, xs, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))), put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), b1), (HI(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))), put(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))), b1), (size_node2(T, xs, ys, sz(T, xs), a2), (size_node2(T, put(T, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n)))), ys, sz(T, xs), a3), (Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), a4)))))))

def ro_rl(-T: Type, -p: Nat, -xs: Array<T>, -ys: Array<T>, -n: U32, -i: U32, -j: U32, -w: T, -u: T, ia: {Array.swap.go(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, ys) == (ys, sz(T, ys)) : Array<T> & U32} & ({Array.size(T, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))) == (put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, ys)) : Array<T> & U32} & ({sz(T, ys) == F.u32__pow2u(p) : U32}))), ib: {Array.swap.go(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))) == (put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n))))) : Array<T> & T} & ({Array.size(T, xs) == (xs, sz(T, xs)) : Array<T> & U32} & ({Array.size(T, put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n))))) == (put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), sz(T, xs)) : Array<T> & U32} & ({sz(T, xs) == F.u32__pow2u(p) : U32}))))
    -> {Array.swap.go(T, ANode{xs, ys}, n, i, w, False{}) == (put(T, ANode{xs, ys}, n, i, w, False{}), old(T, ANode{xs, ys}, n, i, False{})) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, j, u, True{}) == (put(T, ANode{xs, ys}, n, j, u, True{}), old(T, ANode{xs, ys}, n, j, True{})) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, j, u, True{}) == (put(T, put(T, ANode{xs, ys}, n, i, w, False{}), n, j, u, True{}), old(T, ANode{xs, ys}, n, j, True{})) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, False{})) == (put(T, ANode{xs, ys}, n, i, w, False{}), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(1n+p) : U32}))))):
  (+a1, ra) = ia
  (+b1, rb) = ib
  (+b2, rc) = rb
  (+b3, b4) = rc
  (HI(T, xs, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), old(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), a1), (LO(T, xs, ys, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n))), put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))), b1), (LO(T, xs, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n))), put(T, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n)))), old(T, xs, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))), b1), (size_node2(T, xs, ys, sz(T, xs), b2), (size_node2(T, xs, put(T, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))), sz(T, xs), b2), (Equal.cong(U32, U32, s => U32.shl(s), sz(T, xs), F.u32__pow2u(p), b4)))))))

def ro(-T: Type, +d: Nat, a: Array<T>, +n: U32, +i: U32, +zi: Bool, +j: U32, +zj: Bool, w: T, u: T, +hs: {sameD(d, n, i, zi, j, zj) == False{} : Bool}, pf: tperf(T, d, a))
    -> {Array.swap.go(T, a, n, i, w, zi) == (put(T, a, n, i, w, zi), old(T, a, n, i, zi)) : Array<T> & T} & ({Array.swap.go(T, a, n, j, u, zj) == (put(T, a, n, j, u, zj), old(T, a, n, j, zj)) : Array<T> & T} & ({Array.swap.go(T, put(T, a, n, i, w, zi), n, j, u, zj) == (put(T, put(T, a, n, i, w, zi), n, j, u, zj), old(T, a, n, j, zj)) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, n, i, w, zi)) == (put(T, a, n, i, w, zi), sz(T, a)) : Array<T> & U32} & ({sz(T, a) == F.u32__pow2u(d) : U32}))))):
  match d a zi zj:
    case 0n ALeaf{x} _ _: Empty.absurd({Array.swap.go(T, ALeaf{x}, n, i, w, zi) == (put(T, ALeaf{x}, n, i, w, zi), old(T, ALeaf{x}, n, i, zi)) : Array<T> & T} & ({Array.swap.go(T, ALeaf{x}, n, j, u, zj) == (put(T, ALeaf{x}, n, j, u, zj), old(T, ALeaf{x}, n, j, zj)) : Array<T> & T} & ({Array.swap.go(T, put(T, ALeaf{x}, n, i, w, zi), n, j, u, zj) == (put(T, put(T, ALeaf{x}, n, i, w, zi), n, j, u, zj), old(T, ALeaf{x}, n, j, zj)) : Array<T> & T} & ({Array.size(T, ALeaf{x}) == (ALeaf{x}, sz(T, ALeaf{x})) : Array<T> & U32} & ({Array.size(T, put(T, ALeaf{x}, n, i, w, zi)) == (put(T, ALeaf{x}, n, i, w, zi), sz(T, ALeaf{x})) : Array<T> & U32} & ({sz(T, ALeaf{x}) == F.u32__pow2u(0n) : U32}))))), F.logic__true_false(hs))
    case 0n ANode{xs, ys} _ _: Empty.absurd({Array.swap.go(T, ANode{xs, ys}, n, i, w, zi) == (put(T, ANode{xs, ys}, n, i, w, zi), old(T, ANode{xs, ys}, n, i, zi)) : Array<T> & T} & ({Array.swap.go(T, ANode{xs, ys}, n, j, u, zj) == (put(T, ANode{xs, ys}, n, j, u, zj), old(T, ANode{xs, ys}, n, j, zj)) : Array<T> & T} & ({Array.swap.go(T, put(T, ANode{xs, ys}, n, i, w, zi), n, j, u, zj) == (put(T, put(T, ANode{xs, ys}, n, i, w, zi), n, j, u, zj), old(T, ANode{xs, ys}, n, j, zj)) : Array<T> & T} & ({Array.size(T, ANode{xs, ys}) == (ANode{xs, ys}, sz(T, ANode{xs, ys})) : Array<T> & U32} & ({Array.size(T, put(T, ANode{xs, ys}, n, i, w, zi)) == (put(T, ANode{xs, ys}, n, i, w, zi), sz(T, ANode{xs, ys})) : Array<T> & U32} & ({sz(T, ANode{xs, ys}) == F.u32__pow2u(0n) : U32}))))), pf)
    case 1n+p ALeaf{x} _ _: Empty.absurd({Array.swap.go(T, ALeaf{x}, n, i, w, zi) == (put(T, ALeaf{x}, n, i, w, zi), old(T, ALeaf{x}, n, i, zi)) : Array<T> & T} & ({Array.swap.go(T, ALeaf{x}, n, j, u, zj) == (put(T, ALeaf{x}, n, j, u, zj), old(T, ALeaf{x}, n, j, zj)) : Array<T> & T} & ({Array.swap.go(T, put(T, ALeaf{x}, n, i, w, zi), n, j, u, zj) == (put(T, put(T, ALeaf{x}, n, i, w, zi), n, j, u, zj), old(T, ALeaf{x}, n, j, zj)) : Array<T> & T} & ({Array.size(T, ALeaf{x}) == (ALeaf{x}, sz(T, ALeaf{x})) : Array<T> & U32} & ({Array.size(T, put(T, ALeaf{x}, n, i, w, zi)) == (put(T, ALeaf{x}, n, i, w, zi), sz(T, ALeaf{x})) : Array<T> & U32} & ({sz(T, ALeaf{x}) == F.u32__pow2u(1n+p) : U32}))))), pf)
    case 1n+p ANode{xs, ys} True{} True{}: ro_ll(T, p, xs, ys, n, i, j, w, u, ro(T, p, xs, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))), j, U32.is_lt(j, U32.shr(U32.shr(n))), w, u, hs, pf_l(T, p, xs, ys, pf)))
    case 1n+p ANode{xs, ys} False{} False{}:
      (pl, pr) = pf
      ro_rr(T, p, xs, ys, n, i, j, w, u, ro(T, p, ys, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))), w, u, hs, pr), sp(T, p, xs, pl))
    case 1n+p ANode{xs, ys} True{} False{}:
      (pl, pr) = pf
      ro_lr(T, p, xs, ys, n, i, j, w, u, rs(T, p, xs, U32.shr(n), i, w, U32.is_lt(i, U32.shr(U32.shr(n))), pl), rs(T, p, ys, U32.shr(n), U32.sub(j, U32.shr(n)), u, U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))), pr))
    case 1n+p ANode{xs, ys} False{} True{}:
      (pl, pr) = pf
      ro_rl(T, p, xs, ys, n, i, j, w, u, rs(T, p, ys, U32.shr(n), U32.sub(i, U32.shr(n)), w, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), pr), rs(T, p, xs, U32.shr(n), j, u, U32.is_lt(j, U32.shr(U32.shr(n))), pl))

# ---- different indices of a perfect array are different leaves ----
def sub_neq(+c: Nat, +a: Nat, +b: Nat, +ne: {Nat.is_eq(a, b) == False{} : Bool}, +la: {Nat.is_le(c, a) == True{} : Bool}, +lb: {Nat.is_le(c, b) == True{} : Bool})
    -> {Nat.is_eq(Nat.sub(a, c), Nat.sub(b, c)) == False{} : Bool}:
  match c a b:
    case 0n _ _:
      %Equal.sym(Nat, Nat.sub(a, 0n), a, F.nat__sub_zero(a)) : {Nat.is_eq(_, Nat.sub(b, 0n)) == False{} : Bool}
      %Equal.sym(Nat, Nat.sub(b, 0n), b, F.nat__sub_zero(b)) : {Nat.is_eq(a, _) == False{} : Bool}
      ne
    case 1n+k 0n _: Empty.absurd({Nat.is_eq(Nat.sub(0n, 1n+k), Nat.sub(b, 1n+k)) == False{} : Bool}, F.logic__false_true(la))
    case 1n+k 1n+a2 0n: Empty.absurd({Nat.is_eq(Nat.sub(1n+a2, 1n+k), Nat.sub(0n, 1n+k)) == False{} : Bool}, F.logic__false_true(lb))
    case 1n+k 1n+a2 1n+b2: sub_neq(k, a2, b2, ne, la, lb)

# an index below 2^0 is 0, so two of them are equal
def dd0(+i: U32, +j: U32, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(0n)) == True{} : Bool}, +hj: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(0n)) == True{} : Bool},
    +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool}) -> {True{} == False{} : Bool}:
  %F.u32__lt_one_zero(U32.to_nat(i), hi) : {Nat.is_eq(_, 0n) == False{} : Bool}
  %F.u32__lt_one_zero(U32.to_nat(j), hj) : {Nat.is_eq(U32.to_nat(i), _) == False{} : Bool}
  ne

# the bit test of the top level, as U32.is_lt against 2^p
def ez_p(+p: Nat, +i: U32, +b: Bool, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +ez: {U32.is_lt(i, U32.shr(F.u32__pow2u(1n+p))) == b : Bool}) -> {U32.is_lt(i, F.u32__pow2u(p)) == b : Bool}:
  %F.u32__shr_pow2u(p, hd) : {U32.is_lt(i, _) == b : Bool}
  ez

def lt_lo(+p: Nat, +i: U32, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +ez: {U32.is_lt(i, U32.shr(F.u32__pow2u(1n+p))) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(p)) == True{} : Bool}:
  F.array__lt_bridge(i, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), True{}, ez_p(p, i, True{}, hd, ez))

def le_hi(+p: Nat, +i: U32, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +ez: {U32.is_lt(i, U32.shr(F.u32__pow2u(1n+p))) == False{} : Bool}) -> {Nat.is_le(F.spec_common__pow2(p), U32.to_nat(i)) == True{} : Bool}:
  F.nat__not_lt_le(U32.to_nat(i), F.spec_common__pow2(p), F.array__lt_bridge(i, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), False{}, ez_p(p, i, False{}, hd, ez)))

def lt_hi(+p: Nat, +i: U32, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(1n+p)) == True{} : Bool}, +ez: {U32.is_lt(i, U32.shr(F.u32__pow2u(1n+p))) == False{} : Bool})
    -> {Nat.is_lt(U32.to_nat(U32.sub(i, F.u32__pow2u(p))), F.spec_common__pow2(p)) == True{} : Bool}:
  F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, Nat.sub(U32.to_nat(i), F.spec_common__pow2(p)), U32.to_nat(U32.sub(i, F.u32__pow2u(p))),
    Equal.sym(Nat, U32.to_nat(U32.sub(i, F.u32__pow2u(p))), Nat.sub(U32.to_nat(i), F.spec_common__pow2(p)), F.array__sub_bridge(i, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), le_hi(p, i, hd, ez))),
    F.array__upper_lt(U32.to_nat(i), p, hi, le_hi(p, i, hd, ez)))

def ne_hi2(+p: Nat, +i: U32, +j: U32, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool},
    +ezi: {U32.is_lt(i, U32.shr(F.u32__pow2u(1n+p))) == False{} : Bool}, +ezj: {U32.is_lt(j, U32.shr(F.u32__pow2u(1n+p))) == False{} : Bool})
    -> {Nat.is_eq(U32.to_nat(U32.sub(i, F.u32__pow2u(p))), U32.to_nat(U32.sub(j, F.u32__pow2u(p)))) == False{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(i, F.u32__pow2u(p))), Nat.sub(U32.to_nat(i), F.spec_common__pow2(p)), F.array__sub_bridge(i, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), le_hi(p, i, hd, ezi))) :
    {Nat.is_eq(_, U32.to_nat(U32.sub(j, F.u32__pow2u(p)))) == False{} : Bool}
  %Equal.sym(Nat, U32.to_nat(U32.sub(j, F.u32__pow2u(p))), Nat.sub(U32.to_nat(j), F.spec_common__pow2(p)), F.array__sub_bridge(j, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), le_hi(p, j, hd, ezj))) :
    {Nat.is_eq(Nat.sub(U32.to_nat(i), F.spec_common__pow2(p)), _) == False{} : Bool}
  sub_neq(F.spec_common__pow2(p), U32.to_nat(i), U32.to_nat(j), ne, le_hi(p, i, hd, ezi), le_hi(p, j, hd, ezj))

# Two different indices below 2^d walk to different leaves of a tree of depth d < 32.
def dd(+d: Nat, +i: U32, +j: U32, +zi: Bool, +zj: Bool, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hj: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(d)) == True{} : Bool},
    +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool},
    +ezi: {U32.is_lt(i, U32.shr(F.u32__pow2u(d))) == zi : Bool}, +ezj: {U32.is_lt(j, U32.shr(F.u32__pow2u(d))) == zj : Bool})
    -> {sameD(d, F.u32__pow2u(d), i, zi, j, zj) == False{} : Bool}:
  match d zi zj:
    case 0n _ _: dd0(i, j, hi, hj, ne)
    case 1n+p True{} True{}:
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {sameD(p, _, i, U32.is_lt(i, U32.shr(_)), j, U32.is_lt(j, U32.shr(_))) == False{} : Bool}
      dd(p, i, j, U32.is_lt(i, U32.shr(F.u32__pow2u(p))), U32.is_lt(j, U32.shr(F.u32__pow2u(p))), F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), lt_lo(p, i, hd, ezi), lt_lo(p, j, hd, ezj), ne, {==}, {==})
    case 1n+p False{} False{}:
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) :
        {sameD(p, _, U32.sub(i, _), U32.is_lt(U32.sub(i, _), U32.shr(_)), U32.sub(j, _), U32.is_lt(U32.sub(j, _), U32.shr(_))) == False{} : Bool}
      dd(p, U32.sub(i, F.u32__pow2u(p)), U32.sub(j, F.u32__pow2u(p)), U32.is_lt(U32.sub(i, F.u32__pow2u(p)), U32.shr(F.u32__pow2u(p))), U32.is_lt(U32.sub(j, F.u32__pow2u(p)), U32.shr(F.u32__pow2u(p))), F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd),
        lt_hi(p, i, hd, hi, ezi), lt_hi(p, j, hd, hj, ezj), ne_hi2(p, i, j, hd, ne, ezi, ezj), {==}, {==})
    case 1n+p True{} False{}: {==}
    case 1n+p False{} True{}: {==}

# the same for the index and bit test Array.swap.at computes (the mask keeps an index below 2^d)
def slots_differ(+d: Nat, +i: U32, +j: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hj: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(d)) == True{} : Bool},
    +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool})
    -> {sameD(d, F.u32__pow2u(d), J(F.u32__pow2u(d), i), Z(F.u32__pow2u(d), i), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j)) == False{} : Bool}:
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {sameD(d, F.u32__pow2u(d), _, U32.is_lt(_, U32.shr(F.u32__pow2u(d))), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j)) == False{} : Bool}
  %Equal.sym(U32, U32.and(j, U32.sub(F.u32__pow2u(d), 1)), j, F.u32__mask_pow2u(j, d, hd, hj)) : {sameD(d, F.u32__pow2u(d), i, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), _, U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == False{} : Bool}
  dd(d, i, j, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), U32.is_lt(j, U32.shr(F.u32__pow2u(d))), hd, hi, hj, ne, {==}, {==})

def other_e2(-T: Type, -d: Nat, -a: Array<T>, -i: U32, -j: U32, -w: T, -u: T, +hz: {sz(T, a) == F.u32__pow2u(d) : U32}, +o2: {Array.swap.go(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}, +o4: {Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32})
    -> {Array.swap(T, a, j, u) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}:
  %Equal.sym(Array<T> & U32, Array.size(T, a), (a, sz(T, a)), o4) : {Array.swap.at(T, j, u, _) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}
  %Equal.sym(U32, sz(T, a), F.u32__pow2u(d), hz) : {Array.swap.at(T, j, u, (a, _)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}
  o2

def other_e1(-T: Type, -d: Nat, -a: Array<T>, -i: U32, -j: U32, -w: T, -u: T, +hz: {sz(T, a) == F.u32__pow2u(d) : U32}, +o1: {Array.swap.go(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), Z(F.u32__pow2u(d), i))) : Array<T> & T}, +o3: {Array.swap.go(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}, +o4: {Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32}, +o5: {Array.size(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i))) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), sz(T, a)) : Array<T> & U32})
    -> {Array.swap(T, Array.set(T, a, i, w), j, u) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}:
  %Equal.sym(Array<T>, Array.set(T, a, i, w), put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), set_step(T, a, F.u32__pow2u(d), i, w, hz, o1, o4)) : {Array.swap(T, _, j, u) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}
  %Equal.sym(Array<T> & U32, Array.size(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i))), (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), sz(T, a)), o5) : {Array.swap.at(T, j, u, _) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}
  %Equal.sym(U32, sz(T, a), F.u32__pow2u(d), hz) : {Array.swap.at(T, j, u, (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), _)) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}
  o3

def swap_other_fin(-T: Type, -d: Nat, -a: Array<T>, -i: U32, -j: U32, -w: T, -u: T, +o1: {Array.swap.go(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), Z(F.u32__pow2u(d), i))) : Array<T> & T}, +o2: {Array.swap.go(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}, +o3: {Array.swap.go(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}, +o4: {Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32}, +o5: {Array.size(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i))) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), sz(T, a)) : Array<T> & U32}, +o6: {sz(T, a) == F.u32__pow2u(d) : U32})
    -> {Array.swap(T, Array.set(T, a, i, w), j, u) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T} & {Array.swap(T, a, j, u) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}:
  (other_e1(T, d, a, i, j, w, u, o6, o1, o3, o4, o5), other_e2(T, d, a, i, j, w, u, o6, o2, o4))

def swap_other_go(-T: Type, -d: Nat, -a: Array<T>, -i: U32, -j: U32, -w: T, -u: T, b: {Array.swap.go(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), Z(F.u32__pow2u(d), i))) : Array<T> & T} & ({Array.swap.go(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T} & ({Array.swap.go(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T} & ({Array.size(T, a) == (a, sz(T, a)) : Array<T> & U32} & ({Array.size(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i))) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), sz(T, a)) : Array<T> & U32} & ({sz(T, a) == F.u32__pow2u(d) : U32}))))))
    -> {Array.swap(T, Array.set(T, a, i, w), j, u) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T} & {Array.swap(T, a, j, u) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}:
  (+o1, r1) = b
  (+o2, r2) = r1
  (+o3, r3) = r2
  (+o4, r4) = r3
  (+o5, o6) = r4
  swap_other_fin(T, d, a, i, j, w, u, o1, o2, o3, o4, o5, o6)

# After Array.set at i, Array.swap at a different index j returns the element the array had at j (E1);
# and Array.swap at j of the array itself returns that same element (E2). For a perfect array of depth
# d < 32 and indices below 2^d.
def swap_other(-T: Type, +d: Nat, a: Array<T>, +i: U32, +j: U32, w: T, u: T, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hj: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(d)) == True{} : Bool},
    +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool}, pf: tperf(T, d, a))
    -> {Array.swap(T, Array.set(T, a, i, w), j, u) == (put(T, put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), w, Z(F.u32__pow2u(d), i)), F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T} & {Array.swap(T, a, j, u) == (put(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), u, Z(F.u32__pow2u(d), j)), old(T, a, F.u32__pow2u(d), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j))) : Array<T> & T}:
  swap_other_go(T, d, a, i, j, w, u, ro(T, d, a, F.u32__pow2u(d), J(F.u32__pow2u(d), i), Z(F.u32__pow2u(d), i), J(F.u32__pow2u(d), j), Z(F.u32__pow2u(d), j), w, u, slots_differ(d, i, j, hd, hi, hj, ne), pf))

# ---- one level of put's walk against the index as a Nat (used by coll_boxed.bend's tfzput) ----
# half the size of a power of two is the next one down
def shr_n(+p: Nat, +n: U32, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +hn: {n == F.u32__pow2u(1n+p) : U32}) -> {U32.shr(n) == F.u32__pow2u(p) : U32}:
  %Equal.sym(U32, n, F.u32__pow2u(1n+p), hn) : {U32.shr(_) == F.u32__pow2u(p) : U32}
  F.u32__shr_pow2u(p, hd)

# the bit test of put at this level is the test of the index j against 2^p
def bit_nat(+p: Nat, +n: U32, +i: U32, +j: Nat, +z: Bool, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +hn: {n == F.u32__pow2u(1n+p) : U32}, +hj: {U32.to_nat(i) == j : Nat},
    +hz: {z == U32.is_lt(i, U32.shr(n)) : Bool}) -> {Nat.is_lt(j, F.spec_common__pow2(p)) == z : Bool}:
  F.logic__subst(Nat, m => {Nat.is_lt(m, F.spec_common__pow2(p)) == z : Bool}, U32.to_nat(i), j, hj,
    Equal.trans(Bool, Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(p)), U32.is_lt(i, F.u32__pow2u(p)), z,
      F.array__lt_bridge(i, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), U32.is_lt(i, F.u32__pow2u(p)), {==}),
      Equal.trans(Bool, U32.is_lt(i, F.u32__pow2u(p)), U32.is_lt(i, U32.shr(n)), z,
        Equal.cong(U32, Bool, m => U32.is_lt(i, m), F.u32__pow2u(p), U32.shr(n), Equal.sym(U32, U32.shr(n), F.u32__pow2u(p), shr_n(p, n, hd, hn))),
        Equal.sym(Bool, z, U32.is_lt(i, U32.shr(n)), hz))))

# in the right half the index is at least 2^p
def ge_ok(+p: Nat, +n: U32, +i: U32, +j: Nat, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +hn: {n == F.u32__pow2u(1n+p) : U32}, +hj: {U32.to_nat(i) == j : Nat},
    +hz: {False{} == U32.is_lt(i, U32.shr(n)) : Bool}) -> {Nat.is_le(F.spec_common__pow2(p), j) == True{} : Bool}:
  F.nat__not_lt_le(j, F.spec_common__pow2(p), bit_nat(p, n, i, j, False{}, hd, hn, hj, hz))

# ... and the index into the right half is below 2^p
def hi_ok(+p: Nat, +n: U32, +i: U32, +j: Nat, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +hn: {n == F.u32__pow2u(1n+p) : U32}, +hi: {Nat.is_lt(j, F.spec_common__pow2(1n+p)) == True{} : Bool},
    +hj: {U32.to_nat(i) == j : Nat}, +hz: {False{} == U32.is_lt(i, U32.shr(n)) : Bool}) -> {Nat.is_lt(Nat.sub(j, F.spec_common__pow2(p)), F.spec_common__pow2(p)) == True{} : Bool}:
  F.array__upper_lt(j, p, hi, ge_ok(p, n, i, j, hd, hn, hj, hz))

# the index put passes to the right half, as a Nat
def sub_of(+p: Nat, +n: U32, +i: U32, +j: Nat, +hd: {Nat.is_lt(1n+p, 32n) == True{} : Bool}, +hn: {n == F.u32__pow2u(1n+p) : U32}, +hj: {U32.to_nat(i) == j : Nat},
    +hz: {False{} == U32.is_lt(i, U32.shr(n)) : Bool}) -> {U32.to_nat(U32.sub(i, U32.shr(n))) == Nat.sub(j, F.spec_common__pow2(p)) : Nat}:
  Equal.trans(Nat, U32.to_nat(U32.sub(i, U32.shr(n))), U32.to_nat(U32.sub(i, F.u32__pow2u(p))), Nat.sub(j, F.spec_common__pow2(p)),
    Equal.cong(U32, Nat, m => U32.to_nat(U32.sub(i, m)), U32.shr(n), F.u32__pow2u(p), shr_n(p, n, hd, hn)),
    Equal.trans(Nat, U32.to_nat(U32.sub(i, F.u32__pow2u(p))), Nat.sub(U32.to_nat(i), F.spec_common__pow2(p)), Nat.sub(j, F.spec_common__pow2(p)),
      F.array__sub_bridge(i, p, F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd), F.logic__subst(Nat, m => {Nat.is_le(F.spec_common__pow2(p), m) == True{} : Bool}, j, U32.to_nat(i), Equal.sym(Nat, U32.to_nat(i), j, hj), ge_ok(p, n, i, j, hd, hn, hj, hz))),
      Equal.cong(Nat, Nat, m => Nat.sub(m, F.spec_common__pow2(p)), U32.to_nat(i), j, hj)))

# and_intro with the two booleans erased (they are the perfection of trees the caller does not hold)
def and_i(-a: Bool, -b: Bool, +ea: {a == True{} : Bool}, +eb: {b == True{} : Bool}) -> {Bool.and(a, b) == True{} : Bool}:
  %Equal.sym(Bool, a, True{}, ea) : {Bool.and(_, b) == True{} : Bool}
  eb
