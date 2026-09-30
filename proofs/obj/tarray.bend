import Base

# Array laws for elements of any kind (Type-kind too: boxed containers, which cannot be copied, so
# the Data mirror of proofs/compact/found.bend's array laws does not apply). Array.swap is described
# by two structural functions over the array: put (the array after the write) and old (the element
# that was there). No premise on the array's shape or on the index is needed: both swaps of a
# write-then-read walk the same path, which depends only on the size and the index.
#
# This file is the only one that unfolds Base's Array.swap.go / Array.size (checker aa99b746's
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
