# Base 2.0.34 port of four blocks of bend-collections proofs/lib/array.bend, read by
# tools/generate_compact_foundation.py in place of the snapshot's blocks of the same name.
# Bend 2.0.30 gave Array.get.go and Array.swap.go the branch Bool (U32.is_lt(i, U32.shr(n)))
# and dropped Array.get.if/Array.swap.if; these are the snapshot's proofs restated for that,
# verbatim from bend-collections commit dfb7244b195f32a47fd6bd26af9a62550c46276e (branch
# integrate-2034), with that file's import aliases (the snapshot's array.bend has the same).

def get_go(-T: Data, +d: Nat, +t: Tree<T>, +i: U32, +x: T, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), SC.pow2(d)) == True{} : Bool}, +hx: {SC.nth(T, slots(T, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(U.pow2u(d))) == b : Bool}, +pf: {perfect(T, d, t) == True{} : Bool}) -> {Array.get.go(T, thaw(T, t), U.pow2u(d), i, b) == (thaw(T, t), x) : Array<T> & T}:
  match d t b:
    case 0n TLeaf{+y} _:
      %leaf_value(T, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{y}, y) == (ALeaf{y}, _) : Array<T> & T}
      {==}
    case 0n TNode{l, r} _:
      Empty.absurd({Array.get.go(T, thaw(T, TNode{l, r}), 1, i, b) == (thaw(T, TNode{l, r}), x) : Array<T> & T}, L.false_true(pf))
    case 1n+p TLeaf{y} _:
      Empty.absurd({Array.get.go(T, ALeaf{y}, U.pow2u(1n+p), i, b) == (ALeaf{y}, x) : Array<T> & T}, L.false_true(pf))
    case 1n+ +p TNode{+l, +r} True{}:
      +hp = N.lt_trans(p, 1n+p, 32n, N.lt_succ(p), hd)
      +pl = pf_left(T, p, l, r, pf)
      +hil = lt_bridge(i, p, hp, True{}, L.subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd), eb))
      %Equal.sym(U32, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd)) : {Array.swap.lo(T, thaw(T, r), Array.get.go(T, thaw(T, l), _, i, U32.is_lt(i, U32.shr(_)))) == (ANode{thaw(T, l), thaw(T, r)}, x) : Array<T> & T}
      %Equal.sym(Array<T> & T, Array.get.go(T, thaw(T, l), U.pow2u(p), i, U32.is_lt(i, U32.shr(U.pow2u(p)))), (thaw(T, l), x), get_go(T, p, l, i, x, hp, hil, Equal.trans(Maybe<&2, T>, SC.nth(T, slots(T, l), U32.to_nat(i)), SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), U32.to_nat(i)), Some{x}, Equal.sym(Maybe<&2, T>, SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), U32.to_nat(i)), SC.nth(T, slots(T, l), U32.to_nat(i)), LL.nth_append_left(T, slots(T, l), slots(T, r), U32.to_nat(i), len_lt(T, p, l, U32.to_nat(i), pl, hil))), hx), U32.is_lt(i, U32.shr(U.pow2u(p))), {==}, pl)) : {Array.swap.lo(T, thaw(T, r), _) == (ANode{thaw(T, l), thaw(T, r)}, x) : Array<T> & T}
      {==}
    case 1n+ +p TNode{+l, +r} False{}:
      +hp = N.lt_trans(p, 1n+p, 32n, N.lt_succ(p), hd)
      +pl = pf_left(T, p, l, r, pf)
      +le = N.not_lt_le(U32.to_nat(i), SC.pow2(p), lt_bridge(i, p, hp, False{}, L.subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd), eb)))
      +j = U32.sub(i, U.pow2u(p))
      +ej = sub_bridge(i, p, hp, le)
      +hir = L.subst(Nat, n => {Nat.is_lt(n, SC.pow2(p)) == True{} : Bool}, Nat.sub(U32.to_nat(i), SC.pow2(p)), U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), Nat.sub(U32.to_nat(i), SC.pow2(p)), ej), upper_lt(U32.to_nat(i), p, hi, le))
      +hxr = L.subst(Nat, n => {SC.nth(T, slots(T, r), n) == Some{x} : Maybe<&2, T>}, Nat.sub(U32.to_nat(i), SC.pow2(p)), U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), Nat.sub(U32.to_nat(i), SC.pow2(p)), ej), Equal.trans(Maybe<&2, T>, SC.nth(T, slots(T, r), Nat.sub(U32.to_nat(i), SC.pow2(p))), SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), U32.to_nat(i)), Some{x}, Equal.sym(Maybe<&2, T>, SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), U32.to_nat(i)), SC.nth(T, slots(T, r), Nat.sub(U32.to_nat(i), SC.pow2(p))), right_nth(T, p, l, r, U32.to_nat(i), pl, le)), hx))
      %Equal.sym(U32, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd)) : {Array.swap.hi(T, thaw(T, l), Array.get.go(T, thaw(T, r), _, U32.sub(i, _), U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (ANode{thaw(T, l), thaw(T, r)}, x) : Array<T> & T}
      %Equal.sym(Array<T> & T, Array.get.go(T, thaw(T, r), U.pow2u(p), j, U32.is_lt(j, U32.shr(U.pow2u(p)))), (thaw(T, r), x), get_go(T, p, r, j, x, hp, hir, hxr, U32.is_lt(j, U32.shr(U.pow2u(p))), {==}, pf_right(T, p, l, r, pf))) : {Array.swap.hi(T, thaw(T, l), _) == (ANode{thaw(T, l), thaw(T, r)}, x) : Array<T> & T}
      {==}

def swap_go(-T: Data, +d: Nat, +t: Tree<T>, +i: U32, +v: T, +x: T, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), SC.pow2(d)) == True{} : Bool}, +hx: {SC.nth(T, slots(T, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(U.pow2u(d))) == b : Bool}, +pf: {perfect(T, d, t) == True{} : Bool}) -> {Array.swap.go(T, thaw(T, t), U.pow2u(d), i, v, b) == (thaw(T, upd(T, d, t, U32.to_nat(i), v)), x) : Array<T> & T}:
  match d t b:
    case 0n TLeaf{+y} _:
      %leaf_value(T, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{v}, y) == (ALeaf{v}, _) : Array<T> & T}
      {==}
    case 0n TNode{l, r} _:
      Empty.absurd({Array.swap.go(T, thaw(T, TNode{l, r}), 1, i, v, b) == (thaw(T, upd(T, 0n, TNode{l, r}, U32.to_nat(i), v)), x) : Array<T> & T}, L.false_true(pf))
    case 1n+p TLeaf{y} _:
      Empty.absurd({Array.swap.go(T, ALeaf{y}, U.pow2u(1n+p), i, v, b) == (thaw(T, upd(T, 1n+p, TLeaf{y}, U32.to_nat(i), v)), x) : Array<T> & T}, L.false_true(pf))
    case 1n+ +p TNode{+l, +r} True{}:
      +hp = N.lt_trans(p, 1n+p, 32n, N.lt_succ(p), hd)
      +pl = pf_left(T, p, l, r, pf)
      +hil = lt_bridge(i, p, hp, True{}, L.subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd), eb))
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd)) : {Array.swap.lo(T, thaw(T, r), Array.swap.go(T, thaw(T, l), _, i, v, U32.is_lt(i, U32.shr(_)))) == (thaw(T, upd(T, 1n+p, TNode{l, r}, ti, v)), x) : Array<T> & T}
      %Equal.sym(Bool, Nat.is_lt(ti, SC.pow2(p)), True{}, hil) : {Array.swap.lo(T, thaw(T, r), Array.swap.go(T, thaw(T, l), U.pow2u(p), i, v, U32.is_lt(i, U32.shr(U.pow2u(p))))) == (thaw(T, tupd(T, 1n+p, TNode{l, r}, ti, v, _)), x) : Array<T> & T}
      %Equal.sym(Array<T> & T, Array.swap.go(T, thaw(T, l), U.pow2u(p), i, v, U32.is_lt(i, U32.shr(U.pow2u(p)))), (thaw(T, upd(T, p, l, ti, v)), x), swap_go(T, p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, T>, SC.nth(T, slots(T, l), ti), SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), ti), Some{x}, Equal.sym(Maybe<&2, T>, SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), ti), SC.nth(T, slots(T, l), ti), LL.nth_append_left(T, slots(T, l), slots(T, r), ti, len_lt(T, p, l, ti, pl, hil))), hx), U32.is_lt(i, U32.shr(U.pow2u(p))), {==}, pl)) : {Array.swap.lo(T, thaw(T, r), _) == (thaw(T, TNode{tupd(T, p, l, ti, v, ndec(p, ti)), r}), x) : Array<T> & T}
      {==}
    case 1n+ +p TNode{+l, +r} False{}:
      +hp = N.lt_trans(p, 1n+p, 32n, N.lt_succ(p), hd)
      +pl = pf_left(T, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = lt_bridge(i, p, hp, False{}, L.subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd), eb))
      +le = N.not_lt_le(ti, SC.pow2(p), nb)
      +j = U32.sub(i, U.pow2u(p))
      +k = Nat.sub(ti, SC.pow2(p))
      +ej = sub_bridge(i, p, hp, le)
      +hir = L.subst(Nat, n => {Nat.is_lt(n, SC.pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), upper_lt(ti, p, hi, le))
      +hxr = L.subst(Nat, n => {SC.nth(T, slots(T, r), n) == Some{x} : Maybe<&2, T>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, T>, SC.nth(T, slots(T, r), k), SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), ti), Some{x}, Equal.sym(Maybe<&2, T>, SC.nth(T, SC.append(T, slots(T, l), slots(T, r)), ti), SC.nth(T, slots(T, r), k), right_nth(T, p, l, r, ti, pl, le)), hx))
      +ih = swap_go(T, p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, U32.shr(U.pow2u(p))), {==}, pf_right(T, p, l, r, pf))
      +ih2 = L.subst(Nat, n => {Array.swap.go(T, thaw(T, r), U.pow2u(p), j, v, U32.is_lt(j, U32.shr(U.pow2u(p)))) == (thaw(T, upd(T, p, r, n, v)), x) : Array<T> & T}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(U.pow2u(1n+p)), U.pow2u(p), U.shr_pow2u(p, hd)) : {Array.swap.hi(T, thaw(T, l), Array.swap.go(T, thaw(T, r), _, U32.sub(i, _), v, U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (thaw(T, upd(T, 1n+p, TNode{l, r}, ti, v)), x) : Array<T> & T}
      %Equal.sym(Bool, Nat.is_lt(ti, SC.pow2(p)), False{}, nb) : {Array.swap.hi(T, thaw(T, l), Array.swap.go(T, thaw(T, r), U.pow2u(p), j, v, U32.is_lt(j, U32.shr(U.pow2u(p))))) == (thaw(T, tupd(T, 1n+p, TNode{l, r}, ti, v, _)), x) : Array<T> & T}
      %Equal.sym(Array<T> & T, Array.swap.go(T, thaw(T, r), U.pow2u(p), j, v, U32.is_lt(j, U32.shr(U.pow2u(p)))), (thaw(T, upd(T, p, r, k, v)), x), ih2) : {Array.swap.hi(T, thaw(T, l), _) == (thaw(T, TNode{l, tupd(T, p, r, k, v, ndec(p, k))}), x) : Array<T> & T}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def get(-T: Data, +d: Nat, +t: Tree<T>, +i: U32, +x: T, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), SC.pow2(d)) == True{} : Bool}, +hx: {SC.nth(T, slots(T, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T>}, +pf: {perfect(T, d, t) == True{} : Bool}) -> {Array.get(T, thaw(T, t), i) == (thaw(T, t), x) : Array<T> & T}:
  %Equal.sym(Array<T> & U32, Array.size(T, thaw(T, t)), (thaw(T, t), U.pow2u(d)), size_thaw(T, d, t, pf)) : {Array.get.at(T, i, _) == (thaw(T, t), x) : Array<T> & T}
  %Equal.sym(U32, U32.and(i, U32.sub(U.pow2u(d), 1)), i, U.mask_pow2u(i, d, hd, hi)) : {Array.get.go(T, thaw(T, t), U.pow2u(d), _, U32.is_lt(_, U32.shr(U.pow2u(d)))) == (thaw(T, t), x) : Array<T> & T}
  get_go(T, d, t, i, x, hd, hi, hx, U32.is_lt(i, U32.shr(U.pow2u(d))), {==}, pf)

def swap(-T: Data, +d: Nat, +t: Tree<T>, +i: U32, +v: T, +x: T, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), SC.pow2(d)) == True{} : Bool}, +hx: {SC.nth(T, slots(T, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T>}, +pf: {perfect(T, d, t) == True{} : Bool}) -> {Array.swap(T, thaw(T, t), i, v) == (thaw(T, upd(T, d, t, U32.to_nat(i), v)), x) : Array<T> & T}:
  %Equal.sym(Array<T> & U32, Array.size(T, thaw(T, t)), (thaw(T, t), U.pow2u(d)), size_thaw(T, d, t, pf)) : {Array.swap.at(T, i, v, _) == (thaw(T, upd(T, d, t, U32.to_nat(i), v)), x) : Array<T> & T}
  %Equal.sym(U32, U32.and(i, U32.sub(U.pow2u(d), 1)), i, U.mask_pow2u(i, d, hd, hi)) : {Array.swap.go(T, thaw(T, t), U.pow2u(d), _, v, U32.is_lt(_, U32.shr(U.pow2u(d)))) == (thaw(T, upd(T, d, t, U32.to_nat(i), v)), x) : Array<T> & T}
  swap_go(T, d, t, i, v, x, hd, hi, hx, U32.is_lt(i, U32.shr(U.pow2u(d))), {==}, pf)

