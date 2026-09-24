import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ./mtree_defs.bend as MS
import ./mtree_run.bend as MR
import ../../proofs/nat_order.bend as Order
import ../../proofs/nat_algebra.bend as NA

# Packed fixed-size elements (src/obj.bend elems_root): element i occupies words
# [i * ew, (i + 1) * ew) of the array; its root is the tree of depth `ed` over
# its nce chunks, the words past the element read as zero (LClip); the list
# root is the tree over the element roots (LElems). Runtime side: on any
# perfect word tree holding the elements, these trees are the reference trees
# over the element chunk digests (the same argument as proofs/obj/mtree_run.bend
# for whole chunks), and the word array comes back unchanged.

# Word j of the element at word b: the word if j < ew, else zero.
def rdv(+W: List<&2, U32>, +b: Nat, +j: Nat, +ew: Nat) -> U32: Bool.pick(U32, Nat.is_lt(j, ew), MR.wd(W, Nat.add(b, j)), 0)

law rd_get:
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for +b: Nat
  for +j: Nat
  for +ew: Nat
  for +c: Bool
  for +ec: {Nat.is_lt(j, ew) == c : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(b, ew), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.rdc(c, F.array__thaw(U32, t), Nat.add(b, j)) == (F.array__thaw(U32, t), Bool.pick(U32, c, MR.wd(F.array__slots(U32, t), Nat.add(b, j)), 0)) : Array<U32> & U32}
def rd_get(dw, t, b, j, ew, c, ec, hd, pf, hr):
  match c:
    case True{}:
      MR.get_at(dw, t, Nat.add(b, j), hd, pf, F.nat__lt_le_trans(Nat.add(b, j), Nat.add(b, ew), F.spec_common__pow2(dw), F.nat__lt_add_left(j, ew, b, ec), hr))
    case False{}: {==}

# The chunk digest of chunk c of the element at word b (big-endian for SHA).
def ecw(+W: List<&2, U32>, +b: Nat, +c: Nat, +ew: Nat) -> D.Digest:
  D.D{B.swap32(rdv(W, b, Nat.add(O.e8(c), 0n), ew)), B.swap32(rdv(W, b, Nat.add(O.e8(c), 1n), ew)), B.swap32(rdv(W, b, Nat.add(O.e8(c), 2n), ew)), B.swap32(rdv(W, b, Nat.add(O.e8(c), 3n), ew)),
      B.swap32(rdv(W, b, Nat.add(O.e8(c), 4n), ew)), B.swap32(rdv(W, b, Nat.add(O.e8(c), 5n), ew)), B.swap32(rdv(W, b, Nat.add(O.e8(c), 6n), ew)), B.swap32(rdv(W, b, Nat.add(O.e8(c), 7n), ew))}

law echunk_read:
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for +b: Nat
  for +c: Nat
  for +ew: Nat
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(b, ew), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.echunkn(F.array__thaw(U32, t), b, c, ew) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
def echunk_read(dw, t, b, c, ew, hd, pf, hr):
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 0n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 0n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 0n), ew, Nat.is_lt(Nat.add(O.e8(c), 0n), ew), {==}, hd, pf, hr)) :
    {O.ec0(b, O.e8(c), ew, _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 1n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 1n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 1n), ew, Nat.is_lt(Nat.add(O.e8(c), 1n), ew), {==}, hd, pf, hr)) :
    {O.ec1(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 2n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 2n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 2n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 2n), ew, Nat.is_lt(Nat.add(O.e8(c), 2n), ew), {==}, hd, pf, hr)) :
    {O.ec2(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 3n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 3n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 3n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 3n), ew, Nat.is_lt(Nat.add(O.e8(c), 3n), ew), {==}, hd, pf, hr)) :
    {O.ec3(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 2n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 4n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 4n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 4n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 4n), ew, Nat.is_lt(Nat.add(O.e8(c), 4n), ew), {==}, hd, pf, hr)) :
    {O.ec4(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 2n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 3n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 5n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 5n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 5n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 5n), ew, Nat.is_lt(Nat.add(O.e8(c), 5n), ew), {==}, hd, pf, hr)) :
    {O.ec5(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 2n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 3n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 4n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 6n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 6n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 6n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 6n), ew, Nat.is_lt(Nat.add(O.e8(c), 6n), ew), {==}, hd, pf, hr)) :
    {O.ec6(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 2n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 3n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 4n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 5n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  %Equal.sym(Array<U32> & U32, O.rdc(Nat.is_lt(Nat.add(O.e8(c), 7n), ew), F.array__thaw(U32, t), Nat.add(b, Nat.add(O.e8(c), 7n))), (F.array__thaw(U32, t), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 7n), ew)), rd_get(dw, t, b, Nat.add(O.e8(c), 7n), ew, Nat.is_lt(Nat.add(O.e8(c), 7n), ew), {==}, hd, pf, hr)) :
    {O.ec7(b, O.e8(c), ew, rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 0n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 1n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 2n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 3n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 4n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 5n), ew), rdv(F.array__slots(U32, t), b, Nat.add(O.e8(c), 6n), ew), _) == (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, c, ew)) : Array<U32> & D.Digest}
  {==}

# The chunk digests c, c + 1, ... (k of them) of the element at word b.
def eclist(k: Nat, +W: List<&2, U32>, +b: Nat, +ew: Nat, +c: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: ecw(W, b, c, ew) <> eclist(q, W, b, ew, 1n+c)

law eclist_len:
  for +k: Nat
  for +W: List<&2, U32>
  for +b: Nat
  for +ew: Nat
  for +c: Nat
  {MS.dlen(eclist(k, W, b, ew, c)) == k : Nat}
def eclist_len(k, W, b, ew, c):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %eclist_len(q, W, b, ew, 1n+c) : {1n+MS.dlen(eclist(q, W, b, ew, 1n+c)) == 1n+_ : Nat}
      {==}

law eclist_at:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, U32>
  for +b: Nat
  for +ew: Nat
  for +c: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MS.dhead(MS.ddrop(s, eclist(k, W, b, ew, c))) == ecw(W, b, Nat.add(s, c), ew) : D.Digest}
def eclist_at(s, k, W, b, ew, c, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MS.dhead(MS.ddrop(0n, eclist(0n, W, b, ew, c))) == ecw(W, b, Nat.add(0n, c), ew) : D.Digest}, MS.false_true(e))
        case 1n+q: {==}
    case 1n+ +p:
      match k:
        case 0n: Empty.absurd({MS.dhead(MS.ddrop(1n+p, eclist(0n, W, b, ew, c))) == ecw(W, b, Nat.add(1n+p, c), ew) : D.Digest}, MS.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p, c) :
            {MS.dhead(MS.ddrop(p, eclist(q, W, b, ew, 1n+c))) == ecw(W, b, _, ew) : D.Digest}
          eclist_at(p, q, W, b, ew, 1n+c, e)

law ct_phase1:
  for +d: Nat
  for +c: Bool
  for +hl: Nat
  for +b: Nat
  for +ew: Nat
  for +v: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for -ws: Array<U32>
  for +dl: D.Digest
  {O.ctree(d, 1n, c, hl, b, ew, v, s, n, (h, (ws, dl))) == O.mt_join(hl, dl, O.ctree(d, 0n, c, hl, b, ew, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<U32> & D.Digest)}
def ct_phase1(d, c, hl, b, ew, v, s, n, h, ws, dl):
  match d:
    case 0n: {==}
    case 1n+p: {==}

# The element's own tree (phase 0) is the reference tree over its chunk digests.
law ct_words:
  for +d: Nat
  for +c: Bool
  for +hl: Nat
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for +b: Nat
  for +ew: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == c : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(b, ew), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.ctree(d, 0n, c, hl, b, ew, O.pow2n(d), s, n, (h, (F.array__thaw(U32, t), junk))) == (h, (F.array__thaw(U32, t), MS.rtree(d, c, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s))) : B.Buf & (Array<U32> & D.Digest)}
def ct_words(d, c, hl, dw, t, b, ew, s, n, h, junk, e, hd, pf, hr):
  match d:
    case 0n:
      match c:
        case False{}: {==}
        case True{}:
          %Equal.sym(Array<U32> & D.Digest, O.echunkn(F.array__thaw(U32, t), b, s, ew), (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, s, ew)), echunk_read(dw, t, b, s, ew, hd, pf, hr)) :
            {O.mt_leaf(h, _) == (h, (F.array__thaw(U32, t), MS.rtree(0n, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(D.Digest, MS.dhead(MS.ddrop(s, eclist(n, F.array__slots(U32, t), b, ew, 0n))), ecw(F.array__slots(U32, t), b, Nat.add(s, 0n), ew), eclist_at(s, n, F.array__slots(U32, t), b, ew, 0n, e)) :
            {(h, (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, s, ew))) == (h, (F.array__thaw(U32, t), _)) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :
            {(h, (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, s, ew))) == (h, (F.array__thaw(U32, t), ecw(F.array__slots(U32, t), b, _, ew))) : B.Buf & (Array<U32> & D.Digest)}
          {==}
    case 1n+ +p:
      match c:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MS.dlen(eclist(n, F.array__slots(U32, t), b, ew, 0n)), n, eclist_len(n, F.array__slots(U32, t), b, ew, 0n)) :
            {O.ctree(p, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(p)), 2n)), n), hl, b, ew, Nat.div(Nat.double(O.pow2n(p)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(p)), 2n)), n, O.ctree(p, 0n, True{}, hl, b, ew, Nat.div(Nat.double(O.pow2n(p)), 2n), s, n, (h, (F.array__thaw(U32, t), junk)))) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), _), hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(p)), 2n), O.pow2n(p), MR.div_double(O.pow2n(p))) :
            {O.ctree(p, 1n, Nat.is_lt(Nat.add(s, _), n), hl, b, ew, _, Nat.add(s, _), n, O.ctree(p, 0n, True{}, hl, b, ew, _, s, n, (h, (F.array__thaw(U32, t), junk)))) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ctree(p, 0n, True{}, hl, b, ew, O.pow2n(p), s, n, (h, (F.array__thaw(U32, t), junk))), (h, (F.array__thaw(U32, t), MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s))), ct_words(p, True{}, hl, dw, t, b, ew, s, n, h, junk, e, hd, pf, hr)) :
            {O.ctree(p, 1n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, b, ew, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, _) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ctree(p, 1n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, b, ew, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s)))),
              O.mt_join(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), O.ctree(p, 0n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, b, ew, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), D.zero())))),
              ct_phase1(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, b, ew, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, h, F.array__thaw(U32, t), MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s))) :
            {_ == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ctree(p, 0n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, b, ew, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), Nat.add(s, O.pow2n(p))))),
              ct_words(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, dw, t, b, ew, Nat.add(s, O.pow2n(p)), n, h, D.zero(), {==}, hd, pf, hr)) :
            {O.mt_join(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), _) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, eclist(n, F.array__slots(U32, t), b, ew, 0n), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          {==}

# ---- the tree over the element roots -----------------------------------------------

law lt_sle:
  for +s: Nat
  for +n: Nat
  for +e: {Nat.is_lt(s, n) == True{} : Bool}
  {Nat.is_le(1n+s, n) == True{} : Bool}
def lt_sle(s, n, e):
  match s n:
    case 0n 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, MS.false_true(e))
    case 0n 1n+q: Order.zero_le(q)
    case 1n+p 0n: Empty.absurd({Nat.is_le(2n+p, 0n) == True{} : Bool}, MS.false_true(e))
    case 1n+ +p 1n+ +q: lt_sle(p, q, e)

law mul_le_left:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +ab: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.mul(a, c), Nat.mul(b, c)) == True{} : Bool}
def mul_le_left(a, b, c, ab):
  match a b:
    case 0n _: Order.zero_le(Nat.mul(b, c))
    case 1n+p 0n: Empty.absurd({Nat.is_le(Nat.mul(1n+p, c), 0n) == True{} : Bool}, MS.false_true(ab))
    case 1n+ +p 1n+ +q: Order.add_left(c, Nat.mul(p, c), Nat.mul(q, c), mul_le_left(p, q, c, ab))

# Element s < n of an array holding n elements of ew words lies inside it.
def elem_in(+s: Nat, +n: Nat, +ew: Nat, +P: Nat, +e: {Nat.is_lt(s, n) == True{} : Bool}, +hK: {Nat.is_le(Nat.mul(n, ew), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.mul(s, ew), ew), P) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(Nat.mul(s, ew), ew), Nat.add(ew, Nat.mul(s, ew)), NA.add_commute(Nat.mul(s, ew), ew)) : {Nat.is_le(_, P) == True{} : Bool}
  Order.transitive(Nat.mul(1n+s, ew), Nat.mul(n, ew), P, mul_le_left(1n+s, n, ew, lt_sle(s, n, e)), hK)

# The root of element i: the tree of depth ed over its nce chunk digests.
def er(+W: List<&2, U32>, +i: Nat, +ew: Nat, +ed: Nat, +nce: Nat, +hl: Nat) -> D.Digest:
  MS.rtree(ed, Nat.is_lt(0n, nce), hl, eclist(nce, W, Nat.mul(i, ew), ew, 0n), 0n)

def elist(k: Nat, +W: List<&2, U32>, +i: Nat, +ew: Nat, +ed: Nat, +nce: Nat, +hl: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: er(W, i, ew, ed, nce, hl) <> elist(q, W, 1n+i, ew, ed, nce, hl)

law elist_len:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +ew: Nat
  for +ed: Nat
  for +nce: Nat
  for +hl: Nat
  {MS.dlen(elist(k, W, i, ew, ed, nce, hl)) == k : Nat}
def elist_len(k, W, i, ew, ed, nce, hl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %elist_len(q, W, 1n+i, ew, ed, nce, hl) : {1n+MS.dlen(elist(q, W, 1n+i, ew, ed, nce, hl)) == 1n+_ : Nat}
      {==}

law elist_at:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +ew: Nat
  for +ed: Nat
  for +nce: Nat
  for +hl: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MS.dhead(MS.ddrop(s, elist(k, W, i, ew, ed, nce, hl))) == er(W, Nat.add(s, i), ew, ed, nce, hl) : D.Digest}
def elist_at(s, k, W, i, ew, ed, nce, hl, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MS.dhead(MS.ddrop(0n, elist(0n, W, i, ew, ed, nce, hl))) == er(W, Nat.add(0n, i), ew, ed, nce, hl) : D.Digest}, MS.false_true(e))
        case 1n+q: {==}
    case 1n+ +p:
      match k:
        case 0n: Empty.absurd({MS.dhead(MS.ddrop(1n+p, elist(0n, W, i, ew, ed, nce, hl))) == er(W, Nat.add(1n+p, i), ew, ed, nce, hl) : D.Digest}, MS.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p, i) :
            {MS.dhead(MS.ddrop(p, elist(q, W, 1n+i, ew, ed, nce, hl))) == er(W, _, ew, ed, nce, hl) : D.Digest}
          elist_at(p, q, W, 1n+i, ew, ed, nce, hl, e)

# The tree over the elements (phase 0) is the reference tree over the element roots.
law mt_elems:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for +ew: Nat
  for +ed: Nat
  for +nce: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hK: {Nat.is_le(Nat.mul(n, ew), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.mtree(d, 0n, b, hl, O.LElems{ew, ed, nce}, O.pow2n(d), s, n, (h, (F.array__thaw(U32, t), junk))) == (h, (F.array__thaw(U32, t), MS.rtree(d, b, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s))) : B.Buf & (Array<U32> & D.Digest)}
def mt_elems(d, b, hl, dw, t, ew, ed, nce, s, n, h, junk, e, hd, pf, hK):
  match d:
    case 0n:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ctree(ed, 0n, Nat.is_lt(0n, nce), hl, Nat.mul(s, ew), ew, O.pow2n(ed), 0n, nce, (h, (F.array__thaw(U32, t), D.zero()))),
              (h, (F.array__thaw(U32, t), MS.rtree(ed, Nat.is_lt(0n, nce), hl, eclist(nce, F.array__slots(U32, t), Nat.mul(s, ew), ew, 0n), 0n))),
              ct_words(ed, Nat.is_lt(0n, nce), hl, dw, t, Nat.mul(s, ew), ew, 0n, nce, h, D.zero(), {==}, hd, pf, elem_in(s, n, ew, F.spec_common__pow2(dw), e, hK))) :
            {_ == (h, (F.array__thaw(U32, t), MS.rtree(0n, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(D.Digest, MS.dhead(MS.ddrop(s, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl))), er(F.array__slots(U32, t), Nat.add(s, 0n), ew, ed, nce, hl), elist_at(s, n, F.array__slots(U32, t), 0n, ew, ed, nce, hl, e)) :
            {(h, (F.array__thaw(U32, t), er(F.array__slots(U32, t), s, ew, ed, nce, hl))) == (h, (F.array__thaw(U32, t), _)) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :
            {(h, (F.array__thaw(U32, t), er(F.array__slots(U32, t), s, ew, ed, nce, hl))) == (h, (F.array__thaw(U32, t), er(F.array__slots(U32, t), _, ew, ed, nce, hl))) : B.Buf & (Array<U32> & D.Digest)}
          {==}
    case 1n+ +p:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MS.dlen(elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl)), n, elist_len(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl)) :
            {O.mtree(p, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(p)), 2n)), n), hl, O.LElems{ew, ed, nce}, Nat.div(Nat.double(O.pow2n(p)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(p)), 2n)), n, O.mtree(p, 0n, True{}, hl, O.LElems{ew, ed, nce}, Nat.div(Nat.double(O.pow2n(p)), 2n), s, n, (h, (F.array__thaw(U32, t), junk)))) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), _), hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(p)), 2n), O.pow2n(p), MR.div_double(O.pow2n(p))) :
            {O.mtree(p, 1n, Nat.is_lt(Nat.add(s, _), n), hl, O.LElems{ew, ed, nce}, _, Nat.add(s, _), n, O.mtree(p, 0n, True{}, hl, O.LElems{ew, ed, nce}, _, s, n, (h, (F.array__thaw(U32, t), junk)))) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(p, 0n, True{}, hl, O.LElems{ew, ed, nce}, O.pow2n(p), s, n, (h, (F.array__thaw(U32, t), junk))), (h, (F.array__thaw(U32, t), MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s))), mt_elems(p, True{}, hl, dw, t, ew, ed, nce, s, n, h, junk, e, hd, pf, hK)) :
            {O.mtree(p, 1n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LElems{ew, ed, nce}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, _) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(p, 1n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LElems{ew, ed, nce}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s)))),
              O.mt_join(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), O.mtree(p, 0n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LElems{ew, ed, nce}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), D.zero())))),
              MR.mt_phase1(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LElems{ew, ed, nce}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, h, F.array__thaw(U32, t), MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s))) :
            {_ == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(p, 0n, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, O.LElems{ew, ed, nce}, O.pow2n(p), Nat.add(s, O.pow2n(p)), n, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), Nat.add(s, O.pow2n(p))))),
              mt_elems(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, dw, t, ew, ed, nce, Nat.add(s, O.pow2n(p)), n, h, D.zero(), {==}, hd, pf, hK)) :
            {O.mt_join(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), _) == (h, (F.array__thaw(U32, t), D.node(hl, MS.rtree(p, True{}, hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), s), MS.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), n), hl, elist(n, F.array__slots(U32, t), 0n, ew, ed, nce, hl), Nat.add(s, O.pow2n(p)))))) : B.Buf & (Array<U32> & D.Digest)}
          {==}
