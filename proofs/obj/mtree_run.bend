import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ./mtree_defs.bend as MS

# The Merkle layer, runtime side: the recursive tree the object API runs over
# packed words (src/obj.bend `mtree` with LWords leaves, used by every byte
# vector, byte list, bit list and packed list root) computes, on ANY perfect
# Array tree of words, the reference tree (proofs/obj/mtree_spec.bend) over the
# chunk digests of the words - and hands back the hasher and the word array
# unchanged. Array reads go through proofs/compact/found.bend's model
# (`array__get`: a read of a perfect tree at an in-range index returns the
# slot and the same tree).

def wd(W: List<&2, U32>, +k: Nat) -> U32: F.flat__nthc(W, k)

# The chunk digest of the words b .. b + 7 (big-endian for SHA).
def cwb(+W: List<&2, U32>, +b: Nat) -> D.Digest:
  D.D{B.swap32(wd(W, Nat.add(b, 0n))), B.swap32(wd(W, Nat.add(b, 1n))), B.swap32(wd(W, Nat.add(b, 2n))), B.swap32(wd(W, Nat.add(b, 3n))),
      B.swap32(wd(W, Nat.add(b, 4n))), B.swap32(wd(W, Nat.add(b, 5n))), B.swap32(wd(W, Nat.add(b, 6n))), B.swap32(wd(W, Nat.add(b, 7n)))}

def cw(+W: List<&2, U32>, +i: Nat) -> D.Digest: cwb(W, O.e8(i))

# The chunk digests i, i + 1, ... (k of them).
def clist(k: Nat, +W: List<&2, U32>, +i: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: cw(W, i) <> clist(q, W, 1n+i)

# ---- arithmetic ------------------------------------------------------------------

law add_succ:
  for +a: Nat
  for +b: Nat
  {Nat.add(a, 1n+b) == 1n+Nat.add(a, b) : Nat}
def add_succ(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p:
      %add_succ(p, b) : {1n+Nat.add(p, 1n+b) == 1n+_ : Nat}
      {==}

law add_zero:
  for +a: Nat
  {Nat.add(a, 0n) == a : Nat}
def add_zero(a):
  match a:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.add(p, 0n), p, add_zero(p)) : {1n+_ == 1n+p : Nat}
      {==}

law div_double:
  for +x: Nat
  {Nat.div(Nat.double(x), 2n) == x : Nat}
def div_double(x): F.lru_modular_addition__binary_quotient(x, False{})

# s < n gives 8s + 7 < 8n.
law e8_bound:
  for +s: Nat
  for +n: Nat
  for +e: {Nat.is_lt(s, n) == True{} : Bool}
  {Nat.is_lt(Nat.add(O.e8(s), 7n), O.e8(n)) == True{} : Bool}
def e8_bound(s, n, e):
  match s:
    case 0n:
      match n:
        case 0n: Empty.absurd({Nat.is_lt(Nat.add(O.e8(0n), 7n), O.e8(0n)) == True{} : Bool}, MS.false_true(e))
        case 1n+ +q: {==}
    case 1n+ +p:
      match n:
        case 0n: Empty.absurd({Nat.is_lt(Nat.add(O.e8(1n+p), 7n), O.e8(0n)) == True{} : Bool}, MS.false_true(e))
        case 1n+ +q: e8_bound(p, q, e)

# ---- one chunk read --------------------------------------------------------------

def lt_step(+b: Nat, +j: Nat, +P: Nat, +lt: {Nat.is_lt(j, 7n) == True{} : Bool}, +hb: {Nat.is_lt(Nat.add(b, 7n), P) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(b, j), P) == True{} : Bool}:
  F.nat__le_lt_trans(Nat.add(b, j), Nat.add(b, 7n), P, F.nat__lt_le(Nat.add(b, j), Nat.add(b, 7n), F.nat__lt_add_left(j, 7n, b, lt)), hb)

def hi_at(+dw: Nat, +k: Nat, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}, +hk: {Nat.is_lt(k, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(U32.from_nat(k)), F.spec_common__pow2(dw)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.from_nat(k)), k, F.u32__to_nat_from_nat(k, dw, F.nat__lt_le(dw, 32n, hd), hk)) : {Nat.is_lt(_, F.spec_common__pow2(dw)) == True{} : Bool}
  hk

def hx_at(+dw: Nat, +t: F.array__Tree<U32>, +k: Nat, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hk: {Nat.is_lt(k, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {F.spec_common__nth(U32, F.array__slots(U32, t), U32.to_nat(U32.from_nat(k))) == Some{wd(F.array__slots(U32, t), k)} : Maybe<&2, U32>}:
  %Equal.sym(Nat, U32.to_nat(U32.from_nat(k)), k, F.u32__to_nat_from_nat(k, dw, F.nat__lt_le(dw, 32n, hd), hk)) :
    {F.spec_common__nth(U32, F.array__slots(U32, t), _) == Some{wd(F.array__slots(U32, t), k)} : Maybe<&2, U32>}
  F.flat__nthc_nth(F.array__slots(U32, t), k,
    Equal.trans(Bool, Nat.is_lt(k, F.spec_common__length(U32, F.array__slots(U32, t))), Nat.is_lt(k, F.spec_common__pow2(dw)), True{},
      Equal.cong(Nat, Bool, x => Nat.is_lt(k, x), F.spec_common__length(U32, F.array__slots(U32, t)), F.spec_common__pow2(dw), F.array__slots_length(U32, dw, t, pf)),
      hk))

def get_at(+dw: Nat, +t: F.array__Tree<U32>, +k: Nat, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hk: {Nat.is_lt(k, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), U32.from_nat(k)) == (F.array__thaw(U32, t), wd(F.array__slots(U32, t), k)) : Array<U32> & U32}:
  F.array__get(U32, dw, t, U32.from_nat(k), wd(F.array__slots(U32, t), k), hd, hi_at(dw, k, hd, hk), hx_at(dw, t, k, hd, pf, hk), pf)

# The eight reads of one chunk (src/obj.bend `chunkn`) at words b .. b + 7.
law chunk_read:
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for +b: Nat
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hb: {Nat.is_lt(Nat.add(b, 7n), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.chunkn(F.array__thaw(U32, t), b) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
def chunk_read(dw, t, b, hd, pf, hb):
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 0n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 0n))), get_at(dw, t, Nat.add(b, 0n), hd, pf, lt_step(b, 0n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn0(b, _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 1n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 1n))), get_at(dw, t, Nat.add(b, 1n), hd, pf, lt_step(b, 1n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn1(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 2n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 2n))), get_at(dw, t, Nat.add(b, 2n), hd, pf, lt_step(b, 2n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn2(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), wd(F.array__slots(U32, t), Nat.add(b, 1n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 3n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 3n))), get_at(dw, t, Nat.add(b, 3n), hd, pf, lt_step(b, 3n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn3(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), wd(F.array__slots(U32, t), Nat.add(b, 1n)), wd(F.array__slots(U32, t), Nat.add(b, 2n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 4n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 4n))), get_at(dw, t, Nat.add(b, 4n), hd, pf, lt_step(b, 4n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn4(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), wd(F.array__slots(U32, t), Nat.add(b, 1n)), wd(F.array__slots(U32, t), Nat.add(b, 2n)), wd(F.array__slots(U32, t), Nat.add(b, 3n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 5n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 5n))), get_at(dw, t, Nat.add(b, 5n), hd, pf, lt_step(b, 5n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn5(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), wd(F.array__slots(U32, t), Nat.add(b, 1n)), wd(F.array__slots(U32, t), Nat.add(b, 2n)), wd(F.array__slots(U32, t), Nat.add(b, 3n)), wd(F.array__slots(U32, t), Nat.add(b, 4n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 6n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 6n))), get_at(dw, t, Nat.add(b, 6n), hd, pf, lt_step(b, 6n, F.spec_common__pow2(dw), {==}, hb))) :
    {O.cn6(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), wd(F.array__slots(U32, t), Nat.add(b, 1n)), wd(F.array__slots(U32, t), Nat.add(b, 2n)), wd(F.array__slots(U32, t), Nat.add(b, 3n)), wd(F.array__slots(U32, t), Nat.add(b, 4n)), wd(F.array__slots(U32, t), Nat.add(b, 5n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(b, 7n))), (F.array__thaw(U32, t), wd(F.array__slots(U32, t), Nat.add(b, 7n))), get_at(dw, t, Nat.add(b, 7n), hd, pf, hb)) :
    {O.cn7(b, wd(F.array__slots(U32, t), Nat.add(b, 0n)), wd(F.array__slots(U32, t), Nat.add(b, 1n)), wd(F.array__slots(U32, t), Nat.add(b, 2n)), wd(F.array__slots(U32, t), Nat.add(b, 3n)), wd(F.array__slots(U32, t), Nat.add(b, 4n)), wd(F.array__slots(U32, t), Nat.add(b, 5n)), wd(F.array__slots(U32, t), Nat.add(b, 6n)), _) == (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), b)) : Array<U32> & D.Digest}
  {==}

# ---- the chunk list ---------------------------------------------------------------

law clist_len:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {MS.dlen(clist(k, W, i)) == k : Nat}
def clist_len(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %clist_len(q, W, 1n+i) : {1n+MS.dlen(clist(q, W, 1n+i)) == 1n+_ : Nat}
      {==}

# Entry s of the chunk list from i is chunk s + i.
law clist_at:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MS.dhead(MS.ddrop(s, clist(k, W, i))) == cw(W, Nat.add(s, i)) : D.Digest}
def clist_at(s, k, W, i, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MS.dhead(MS.ddrop(0n, clist(0n, W, i))) == cw(W, Nat.add(0n, i)) : D.Digest}, MS.false_true(e))
        case 1n+q: {==}
    case 1n+ +p:
      match k:
        case 0n: Empty.absurd({MS.dhead(MS.ddrop(1n+p, clist(0n, W, i))) == cw(W, Nat.add(1n+p, i)) : D.Digest}, MS.false_true(e))
        case 1n+ +q:
          %add_succ(p, i) :
            {MS.dhead(MS.ddrop(p, clist(q, W, 1n+i))) == cw(W, _) : D.Digest}
          clist_at(p, q, W, 1n+i, e)

# A phase-1 call (the right half of a node, with the left root held) unfolds.
law mt_phase1:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +lf: O.Leaf
  for +v: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for -ws: Array<U32>
  for +dl: D.Digest
  {O.mtree(d, 1n, b, hl, lf, v, s, n, (h, (ws, dl))) == O.mt_join(hl, dl, O.mtree(d, 0n, b, hl, lf, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<U32> & D.Digest)}
def mt_phase1(d, b, hl, lf, v, s, n, h, ws, dl):
  match d:
    case 0n: {==}
    case 1n+p: {==}

# ---- the tree -----------------------------------------------------------------------

# The recursive tree over packed words (phase 0) is the reference tree over the
# chunk digests, and leaves the hasher and the word array as they were.
law mt_words:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hn: {Nat.is_le(O.e8(n), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.mtree(d, 0n, b, hl, O.LWords{}, O.pow2n(d), s, n, (h, (F.array__thaw(U32, t), junk))) == (h, (F.array__thaw(U32, t), MS.rtree(d, b, hl, clist(n, F.array__slots(U32, t), 0n), s))) : B.Buf & (Array<U32> & D.Digest)}
def mt_words(d, b, hl, dw, t, s, n, h, junk, e, hd, pf, hn):
  match d:
    case 0n:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Array<U32> & D.Digest, O.chunkn(F.array__thaw(U32, t), O.e8(s)), (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), O.e8(s))), chunk_read(dw, t, O.e8(s), hd, pf, F.nat__lt_le_trans(Nat.add(O.e8(s), 7n), O.e8(n), F.spec_common__pow2(dw), e8_bound(s, n, e), hn))) :
            {O.mt_leaf(h, _) == (h, (F.array__thaw(U32, t), MS.rtree(0n, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(D.Digest, MS.dhead(MS.ddrop(s, clist(n, F.array__slots(U32, t), 0n))), cw(F.array__slots(U32, t), Nat.add(s, 0n)), clist_at(s, n, F.array__slots(U32, t), 0n, e)) :
            {(h, (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), O.e8(s)))) == (h, (F.array__thaw(U32, t), _)) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, add_zero(s)) :
            {(h, (F.array__thaw(U32, t), cwb(F.array__slots(U32, t), O.e8(s)))) == (h, (F.array__thaw(U32, t), cw(F.array__slots(U32, t), _))) : B.Buf & (Array<U32> & D.Digest)}
          {==}
    case 1n+ +p:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MS.dlen(clist(n, F.array__slots(U32, t), 0n)), n, clist_len(n, F.array__slots(U32, t), 0n)) :
            {O.mtree(p, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(p)), 2n)), n), hl, O.LWords{}, Nat.div(Nat.double(O.pow2n(p)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(p)), 2n)), n, O.mtree(p, 0n, True{}, hl, O.LWords{}, Nat.div(Nat.double(O.pow2n(p)), 2n), s, n, (h, (F.array__thaw(U32, t), junk)))) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), _), hl, clist(n, F.array__slots(U32, t), 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(p)), 2n), O.pow2n(p), div_double(O.pow2n(p))) :
            {O.mtree(p, 1n, Nat.is_lt(Nat.add(s, _), n), hl, O.LWords{}, _, Nat.add(s, _), n, O.mtree(p, 0n, True{}, hl, O.LWords{}, _, s, n, (h, (F.array__thaw(U32, t), junk)))) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, clist(n, F.array__slots(U32, t), 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(p, 0n, True{}, hl, O.LWords{}, O.pow2n(p), s, n, (h, (F.array__thaw(U32, t), junk))), (h, (F.array__thaw(U32, t), MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s))), mt_words(p, True{}, hl, dw, t, s, n, h, junk, e, hd, pf, hn)) :
            {O.mtree(p, 1n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LWords{}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, _) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, clist(n, F.array__slots(U32, t), 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(p, 1n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LWords{}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s)))),
              O.mt_join(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), O.mtree(p, 0n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LWords{}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), D.zero())))),
              mt_phase1(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LWords{}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, h, F.array__thaw(U32, t), MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s))) :
            {_ == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, clist(n, F.array__slots(U32, t), 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(p, 0n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LWords{}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, clist(n, F.array__slots(U32, t), 0n), Nat.add(s, O.pow2n(p))))),
              mt_words(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, dw, t, Nat.add(s, O.pow2n(p)), n, h, D.zero(), {==}, hd, pf, hn)) :
            {O.mt_join(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), _) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, clist(n, F.array__slots(U32, t), 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, clist(n, F.array__slots(U32, t), 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          {==}
