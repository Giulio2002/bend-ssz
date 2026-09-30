import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../spec/progressive.bend as PS
import ../../spec/tree.bend as Tr
import ../../spec/primitives.bend as SP
import ../../proofs/nat_order.bend as Order
import ../../proofs/nat_algebra.bend as NA
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./mtree_spec.bend as MS
import ./words_spec.bend as WS
import ./sha_node.bend as SN
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as VF

# The progressive chunk tree (SSZ merkleize_progressive) of the runtime:
# O.ptree over packed words is `pr` over the chunk digests (pt_run), and the
# bytes of `pr` are the specification's spec/progressive.bend `tree` (pr_spec).
#
# pr mirrors O.ptree: fuel g, the flag `s < n`, the depth of the right subtree
# (0, 2, 4, ...: capacities 1, 4, 16, ...) and its first chunk s. The right
# subtree is the reference tree of that depth at s (mtree_run mt_words), the
# left input is the recursion on the remaining chunks.
def pr(g: Nat, inside: Bool, +hl: Nat, +dep: Nat, +s: Nat, +n: Nat, +L: List<&2, D.Digest>) -> D.Digest:
  match g:
    case 0n: D.zero()
    case 1n+k:
      match inside:
        case False{}: D.zero()
        case True{}:
          D.node(hl, pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, L),
            MD.rtree(dep, True{}, hl, L, s))

# ---- the runtime tree is pr ------------------------------------------------------

law pt_run:
  for +g: Nat
  for +b: Bool
  for +hl: Nat
  for +dep: Nat
  for +s: Nat
  for +n: Nat
  for +dw: Nat
  for +t: F.array__Tree<U32>
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}
  for +hn: {Nat.is_le(O.e8(n), F.spec_common__pow2(dw)) == True{} : Bool}
  {O.ptree(g, b, hl, O.LWords{}, dep, s, n, (h, (F.array__thaw(U32, t), junk))) == (h, (F.array__thaw(U32, t), pr(g, b, hl, dep, s, n, MR.clist(n, F.array__slots(U32, t), 0n)))) : B.Buf & (Array<U32> & D.Digest)}
def pt_run(g, b, hl, dep, s, n, dw, t, h, junk, e, hd, pf, hn):
  match g:
    case 0n: {==}
    case 1n+ +k:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ptree(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, O.LWords{}, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, (h, (F.array__thaw(U32, t), junk))),
              (h, (F.array__thaw(U32, t), pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, MR.clist(n, F.array__slots(U32, t), 0n)))),
              pt_run(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, dw, t, h, junk, {==}, hd, pf, hn)) :
            {O.pt_right(hl, O.LWords{}, dep, s, n, _) == (h, (F.array__thaw(U32, t), pr(1n+k, True{}, hl, dep, s, n, MR.clist(n, F.array__slots(U32, t), 0n)))) : B.Buf & (Array<U32> & D.Digest)}
          %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(dep, 0n, True{}, hl, O.LWords{}, O.pow2n(dep), s, n, (h, (F.array__thaw(U32, t), D.zero()))),
              (h, (F.array__thaw(U32, t), MD.rtree(dep, True{}, hl, MR.clist(n, F.array__slots(U32, t), 0n), s))),
              MR.mt_words(dep, True{}, hl, dw, t, s, n, h, D.zero(), e, hd, pf, hn)) :
            {O.mt_join(hl, pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, MR.clist(n, F.array__slots(U32, t), 0n)), _) == (h, (F.array__thaw(U32, t), pr(1n+k, True{}, hl, dep, s, n, MR.clist(n, F.array__slots(U32, t), 0n)))) : B.Buf & (Array<U32> & D.Digest)}
          {==}

# ---- arithmetic ------------------------------------------------------------------

law pow2_pos:
  for +d: Nat
  {Nat.is_le(1n, O.pow2n(d)) == True{} : Bool}
def pow2_pos(d):
  match d:
    case 0n: {==}
    case 1n+ +p: Order.transitive(1n, O.pow2n(p), Nat.double(O.pow2n(p)), pow2_pos(p), F.nat__double_self_le(O.pow2n(p)))

law pow2_add2:
  for +d: Nat
  {O.pow2n(Nat.add(d, 2n)) == Nat.double(Nat.double(O.pow2n(d))) : Nat}
def pow2_add2(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, O.pow2n(Nat.add(p, 2n)), Nat.double(Nat.double(O.pow2n(p))), pow2_add2(p)) : {Nat.double(_) == Nat.double(Nat.double(Nat.double(O.pow2n(p)))) : Nat}
      {==}

law dbl_add:
  for +a: Nat
  for +b: Nat
  {Nat.double(Nat.add(a, b)) == Nat.add(Nat.double(a), Nat.double(b)) : Nat}
def dbl_add(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.double(Nat.add(p, b)), Nat.add(Nat.double(p), Nat.double(b)), dbl_add(p, b)) : {2n+_ == 2n+Nat.add(Nat.double(p), Nat.double(b)) : Nat}
      {==}

def q4(+x: Nat) -> Nat: Nat.double(Nat.double(x))

def q4_add(+a: Nat, +b: Nat) -> {q4(Nat.add(a, b)) == Nat.add(q4(a), q4(b)) : Nat}:
  %Equal.sym(Nat, Nat.double(Nat.add(a, b)), Nat.add(Nat.double(a), Nat.double(b)), dbl_add(a, b)) : {Nat.double(_) == Nat.add(q4(a), q4(b)) : Nat}
  dbl_add(Nat.double(a), Nat.double(b))

def rw_le_l(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h

def rw_le_r(+a: Nat, +b: Nat, +c: Nat, +e: {b == c : Nat}, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(a, c) == True{} : Bool}:
  %e : {Nat.is_le(a, _) == True{} : Bool}
  h

# The fuel bound n <= s + (1 + k) moves to the next subtree: n <= (s + P) + k, P >= 1.
def fuel_step(+n: Nat, +s: Nat, +P: Nat, +k: Nat,
    +h: {Nat.is_le(n, Nat.add(s, 1n+k)) == True{} : Bool},
    +hp: {Nat.is_le(1n, P) == True{} : Bool})
    -> {Nat.is_le(n, Nat.add(Nat.add(s, P), k)) == True{} : Bool}:
  +a1 = Order.add_right(1n, P, k, hp)
  +a2 = Order.add_left(s, 1n+k, Nat.add(P, k), a1)
  +a3 = Order.transitive(n, Nat.add(s, 1n+k), Nat.add(s, Nat.add(P, k)), h, a2)
  rw_le_r(n, Nat.add(s, Nat.add(P, k)), Nat.add(Nat.add(s, P), k), Equal.sym(Nat, Nat.add(Nat.add(s, P), k), Nat.add(s, Nat.add(P, k)), WS.add_assoc(s, P, k)), a3)

# With s < n the fuel bound n <= s + g leaves no room for g = 0.
def fuel_zero(+n: Nat, +s: Nat, +e: {Nat.is_lt(s, n) == True{} : Bool},
    +h: {Nat.is_le(n, Nat.add(s, 0n)) == True{} : Bool}) -> Empty:
  Order.le_lt_conflict(n, s, rw_le_r(n, Nat.add(s, 0n), s, MR.add_zero(s), h), e)

# The depth bound 2^dep <= 4s + 1 moves to the next subtree (depth + 2, s + 2^dep).
def dep_step(+dep: Nat, +s: Nat,
    +pw: {Nat.is_le(O.pow2n(dep), Nat.add(q4(s), 1n)) == True{} : Bool})
    -> {Nat.is_le(O.pow2n(Nat.add(dep, 2n)), Nat.add(q4(Nat.add(s, O.pow2n(dep))), 1n)) == True{} : Bool}:
  +a1 = Order.left_below_sum(q4(s), q4(O.pow2n(dep)))
  +a2 = Order.transitive(q4(O.pow2n(dep)), Nat.add(q4(s), q4(O.pow2n(dep))), Nat.add(Nat.add(q4(s), q4(O.pow2n(dep))), 1n), a1,
    Order.below_sum(Nat.add(q4(s), q4(O.pow2n(dep))), 1n))
  +a3 = rw_le_r(q4(O.pow2n(dep)), Nat.add(Nat.add(q4(s), q4(O.pow2n(dep))), 1n), Nat.add(q4(Nat.add(s, O.pow2n(dep))), 1n),
    Equal.cong(Nat, Nat, x => Nat.add(x, 1n), Nat.add(q4(s), q4(O.pow2n(dep))), q4(Nat.add(s, O.pow2n(dep))), Equal.sym(Nat, q4(Nat.add(s, O.pow2n(dep))), Nat.add(q4(s), q4(O.pow2n(dep))), q4_add(s, O.pow2n(dep)))), a2)
  rw_le_l(q4(O.pow2n(dep)), O.pow2n(Nat.add(dep, 2n)), Nat.add(q4(Nat.add(s, O.pow2n(dep))), 1n), Equal.sym(Nat, O.pow2n(Nat.add(dep, 2n)), q4(O.pow2n(dep)), pow2_add2(dep)), a3)

law pow2_lt_inv:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_lt(O.pow2n(a), O.pow2n(b)) == True{} : Bool}
  {Nat.is_lt(a, b) == True{} : Bool}
def pow2_lt_inv(a, b, h):
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, MD.false_true(h))
    case 0n 1n+q: {==}
    case 1n+p 0n: Empty.absurd({Nat.is_lt(1n+p, 0n) == True{} : Bool}, Order.le_lt_conflict(1n, Nat.double(O.pow2n(p)), pow2_pos(1n+p), h))
    case 1n+ +p 1n+ +q: pow2_lt_inv(p, q, F.nat__bit_double_lt(False{}, O.pow2n(p), O.pow2n(q), h))

law lt_succ:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_lt(a, b) == True{} : Bool}
  {Nat.is_le(1n+a, b) == True{} : Bool}
def lt_succ(a, b, e):
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, MD.false_true(e))
    case 0n 1n+ +q: Order.zero_le(q)
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(2n+p, 0n) == True{} : Bool}, MD.false_true(e))
    case 1n+ +p 1n+ +q: lt_succ(p, q, e)

def q4_succ(+s: Nat) -> {Nat.is_lt(Nat.add(q4(s), 1n), q4(1n+s)) == True{} : Bool}:
  %NA.add_commute(q4(s), 4n) : {Nat.is_lt(Nat.add(q4(s), 1n), _) == True{} : Bool}
  F.nat__lt_add_left(1n, 4n, q4(s), {==})

# Inside the chunks (s < n) with 4n <= 2^m the depth is below m.
def dep_below(+dep: Nat, +s: Nat, +n: Nat, +m: Nat,
    +pw: {Nat.is_le(O.pow2n(dep), Nat.add(q4(s), 1n)) == True{} : Bool},
    +e: {Nat.is_lt(s, n) == True{} : Bool},
    +hm: {Nat.is_le(q4(n), O.pow2n(m)) == True{} : Bool})
    -> {Nat.is_lt(dep, m) == True{} : Bool}:
  # 4s + 1 < 4s + 4 = 4(s + 1) <= 4n
  +a1 = Order.double_monotone(Nat.double(1n+s), Nat.double(n), Order.double_monotone(1n+s, n, lt_succ(s, n, e)))
  +a2 = F.nat__lt_le_trans(Nat.add(q4(s), 1n), q4(1n+s), q4(n), q4_succ(s), a1)
  +a3 = F.nat__le_lt_trans(O.pow2n(dep), Nat.add(q4(s), 1n), q4(n), pw, a2)
  pow2_lt_inv(dep, m, F.nat__lt_le_trans(O.pow2n(dep), q4(n), O.pow2n(m), a3, hm))

# ---- the bytes of pr are the specification's progressive tree ----------------------

def pr_out(+s: Nat, +n: Nat, +L: List<&2, D.Digest>, +en: {MD.dlen(L) == n : Nat}, +e: {Nat.is_lt(s, n) == False{} : Bool})
    -> {Nat.is_lt(s, MD.dlen(L)) == False{} : Bool}:
  %Equal.sym(Nat, MD.dlen(L), n, en) : {Nat.is_lt(s, _) == False{} : Bool}
  e

def pr_in(+s: Nat, +n: Nat, +L: List<&2, D.Digest>, +en: {MD.dlen(L) == n : Nat}, +e: {Nat.is_lt(s, n) == True{} : Bool})
    -> {Nat.is_lt(s, MD.dlen(L)) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(L), n, en) : {Nat.is_lt(s, _) == True{} : Bool}
  e

def pr_zero(+g: Nat, +fs: Nat, +hl: Nat, +dep: Nat, +s: Nat, +n: Nat, +L: List<&2, D.Digest>)
    -> {D.bytes(pr(g, False{}, hl, dep, s, n, L)) == PS.tree(fs, dep, []) : +List<U32>}:
  match g fs:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+k 0n: {==}
    case 1n+k 1n+q: {==}

# Past the chunks (s >= n) both are the zero chunk.
def pr_past(+g: Nat, +fs: Nat, +hl: Nat, +dep: Nat, +s: Nat, +n: Nat, +L: List<&2, D.Digest>,
    +en: {MD.dlen(L) == n : Nat}, +e: {Nat.is_lt(s, n) == False{} : Bool})
    -> {D.bytes(pr(g, False{}, hl, dep, s, n, L)) == PS.tree(fs, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}:
  %Equal.sym(List<&2, D.Digest>, MD.ddrop(s, L), [], MS.ddrop_past(s, L, pr_out(s, n, L, en, e))) :
    {D.bytes(pr(g, False{}, hl, dep, s, n, L)) == PS.tree(fs, dep, MD.bytes_list(_)) : +List<U32>}
  pr_zero(g, fs, hl, dep, s, n, L)

law pr_spec:
  for +g: Nat
  for +fs: Nat
  for +b: Bool
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  for +dep: Nat
  for +s: Nat
  for +n: Nat
  for +m: Nat
  for +L: List<&2, D.Digest>
  for +en: {MD.dlen(L) == n : Nat}
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hg: {Nat.is_le(n, Nat.add(s, g)) == True{} : Bool}
  for +hfs: {Nat.is_le(n, Nat.add(s, fs)) == True{} : Bool}
  for +pw: {Nat.is_le(O.pow2n(dep), Nat.add(q4(s), 1n)) == True{} : Bool}
  for +hm: {Nat.is_le(q4(n), O.pow2n(m)) == True{} : Bool}
  for +hm64: {Nat.is_lt(m, 64n) == True{} : Bool}
  {D.bytes(pr(g, b, hl, dep, s, n, L)) == PS.tree(fs, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
def pr_spec(g, fs, b, hl, ehl, dep, s, n, m, L, en, e, hg, hfs, pw, hm, hm64):
  match g:
    case 0n:
      match b:
        case False{}: pr_past(0n, fs, hl, dep, s, n, L, en, e)
        case True{}: Empty.absurd({D.bytes(pr(0n, True{}, hl, dep, s, n, L)) == PS.tree(fs, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}, fuel_zero(n, s, e, hg))
    case 1n+ +k:
      match fs:
        case 0n:
          match b:
            case False{}: pr_past(1n+k, 0n, hl, dep, s, n, L, en, e)
            case True{}: Empty.absurd({D.bytes(pr(1n+k, True{}, hl, dep, s, n, L)) == PS.tree(0n, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}, fuel_zero(n, s, e, hfs))
        case 1n+ +q:
          match b:
            case False{}: pr_past(1n+k, 1n+q, hl, dep, s, n, L, en, e)
            case True{}:
              +hd = F.nat__lt_trans(dep, m, 64n, dep_below(dep, s, n, m, pw, e, hm), hm64)
              +ih = pr_spec(k, q, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, ehl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, m, L, en, {==},
                fuel_step(n, s, O.pow2n(dep), k, hg, pow2_pos(dep)), fuel_step(n, s, O.pow2n(dep), q, hfs, pow2_pos(dep)), dep_step(dep, s, pw), hm, hm64)
              # the node is the hash of the two inputs' bytes
              %Equal.sym(+List<U32>, D.bytes(D.node(hl, pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, L), MD.rtree(dep, True{}, hl, L, s))),
                  VF.sha256_bytes(List.append(&2, U32, D.bytes(pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, L)), D.bytes(MD.rtree(dep, True{}, hl, L, s)))),
                  SN.node_at(hl, ehl, pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, L), MD.rtree(dep, True{}, hl, L, s))) :
                {_ == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              %Equal.sym(+List<U32>, D.bytes(pr(k, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, L)),
                  PS.tree(q, Nat.add(dep, 2n), MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(dep)), L))), ih) :
                {VF.sha256_bytes(List.append(&2, U32, _, D.bytes(MD.rtree(dep, True{}, hl, L, s)))) == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              %Equal.sym(+List<U32>, D.bytes(MD.rtree(dep, True{}, hl, L, s)), Tr.tree(dep, MD.bytes_list(MD.ddrop(s, L))), MS.rtree_spec(dep, True{}, hl, L, s, pr_in(s, n, L, en, e), hd, ehl)) :
                {VF.sha256_bytes(List.append(&2, U32, PS.tree(q, Nat.add(dep, 2n), MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(dep)), L))), _)) == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              # the remaining chunks are the chunks from s with the right subtree's dropped
              %MS.ddrop_add(s, O.pow2n(dep), L) :
                {VF.sha256_bytes(List.append(&2, U32, PS.tree(q, Nat.add(dep, 2n), MD.bytes_list(_)), Tr.tree(dep, MD.bytes_list(MD.ddrop(s, L))))) == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              %MS.drop_bytes(O.pow2n(dep), MD.ddrop(s, L)) :
                {VF.sha256_bytes(List.append(&2, U32, PS.tree(q, Nat.add(dep, 2n), _), Tr.tree(dep, MD.bytes_list(MD.ddrop(s, L))))) == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              %MS.capacity_pow2(dep) :
                {VF.sha256_bytes(List.append(&2, U32, PS.tree(q, Nat.add(dep, 2n), Tr.drop(_, MD.bytes_list(MD.ddrop(s, L)))), Tr.tree(dep, MD.bytes_list(MD.ddrop(s, L))))) == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              %Equal.sym(Nat, Nat.add(dep, 2n), Nat.add(2n, dep), NA.add_commute(dep, 2n)) :
                {VF.sha256_bytes(List.append(&2, U32, PS.tree(q, _, Tr.drop(Tr.capacity(dep), MD.bytes_list(MD.ddrop(s, L)))), Tr.tree(dep, MD.bytes_list(MD.ddrop(s, L))))) == PS.tree(1n+q, dep, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
              # the chunks from s are nonempty, so the specification's step applies
              %Equal.sym(List<&2, D.Digest>, MD.ddrop(s, L), Con{MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L))}, MS.ddrop_eta(s, L, pr_in(s, n, L, en, e))) :
                {VF.sha256_bytes(List.append(&2, U32, PS.tree(q, 2n+dep, Tr.drop(Tr.capacity(dep), MD.bytes_list(_))), Tr.tree(dep, MD.bytes_list(_)))) == PS.tree(1n+q, dep, MD.bytes_list(_)) : +List<U32>}
              {==}
