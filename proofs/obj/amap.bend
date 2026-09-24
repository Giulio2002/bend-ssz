import Base
import ../compact/found.bend as F

# Mirror-tree facts shared by the generated laws of lists of Type-kind elements
# (codegen/root_laws_b.py tlist_laws emits, per list, the Base Array size /
# swap / set laws over the image of a Data mirror tree, from the template
# codegen/amap_template.bend, found.bend's array__swap_go adapted).

# An update of the mirror undone by the update with the old value.
def tupd_restore(-A: Data, +d: Nat, +t: F.array__Tree<A>, +j: Nat, +z: A, +x: A,
    +hj: {Nat.is_lt(j, F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(A, F.array__slots(A, t), j) == Some{x} : Maybe<&2, A>},
    +b: Bool, +eb: {F.array__ndec(d, j) == b : Bool},
    +pf: {F.array__perfect(A, d, t) == True{} : Bool})
    -> {F.array__tupd(A, d, F.array__tupd(A, d, t, j, z, b), j, x, b) == t : F.array__Tree<A>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(A, y, j, x, hj, hx) : {F.TLeaf{_} == F.TLeaf{y} : F.array__Tree<A>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({F.array__tupd(A, 0n, F.array__tupd(A, 0n, F.TNode{l, r}, j, z, b), j, x, b) == F.TNode{l, r} : F.array__Tree<A>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({F.array__tupd(A, 1n+p, F.array__tupd(A, 1n+p, F.TLeaf{y}, j, z, b), j, x, b) == F.TLeaf{y} : F.array__Tree<A>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +pl = F.array__pf_left(A, p, l, r, pf)
      +hxl = Equal.trans(Maybe<&2, A>, F.spec_common__nth(A, F.array__slots(A, l), j), F.spec_common__nth(A, F.spec_common__append(A, F.array__slots(A, l), F.array__slots(A, r)), j), Some{x},
        Equal.sym(Maybe<&2, A>, F.spec_common__nth(A, F.spec_common__append(A, F.array__slots(A, l), F.array__slots(A, r)), j), F.spec_common__nth(A, F.array__slots(A, l), j),
          F.list__nth_append_left(A, F.array__slots(A, l), F.array__slots(A, r), j, F.array__len_lt(A, p, l, j, pl, eb))), hx)
      %Equal.sym(F.array__Tree<A>, F.array__tupd(A, p, F.array__tupd(A, p, l, j, z, F.array__ndec(p, j)), j, x, F.array__ndec(p, j)), l,
          tupd_restore(A, p, l, j, z, x, eb, hxl, F.array__ndec(p, j), {==}, pl)) :
        {F.TNode{_, r} == F.TNode{l, r} : F.array__Tree<A>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +pl = F.array__pf_left(A, p, l, r, pf)
      +k = Nat.sub(j, F.spec_common__pow2(p))
      +le = F.nat__not_lt_le(j, F.spec_common__pow2(p), eb)
      +hxr = Equal.trans(Maybe<&2, A>, F.spec_common__nth(A, F.array__slots(A, r), k), F.spec_common__nth(A, F.spec_common__append(A, F.array__slots(A, l), F.array__slots(A, r)), j), Some{x},
        Equal.sym(Maybe<&2, A>, F.spec_common__nth(A, F.spec_common__append(A, F.array__slots(A, l), F.array__slots(A, r)), j), F.spec_common__nth(A, F.array__slots(A, r), k), F.array__right_nth(A, p, l, r, j, pl, le)), hx)
      %Equal.sym(F.array__Tree<A>, F.array__tupd(A, p, F.array__tupd(A, p, r, k, z, F.array__ndec(p, k)), k, x, F.array__ndec(p, k)), r,
          tupd_restore(A, p, r, k, z, x, F.array__upper_lt(j, p, hj, le), hxr, F.array__ndec(p, k), {==}, F.array__pf_right(A, p, l, r, pf))) :
        {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<A>}
      {==}

def upd_restore(-A: Data, +d: Nat, +t: F.array__Tree<A>, +j: Nat, +z: A, +x: A,
    +hj: {Nat.is_lt(j, F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(A, F.array__slots(A, t), j) == Some{x} : Maybe<&2, A>},
    +pf: {F.array__perfect(A, d, t) == True{} : Bool})
    -> {F.array__upd(A, d, F.array__upd(A, d, t, j, z), j, x) == t : F.array__Tree<A>}:
  tupd_restore(A, d, t, j, z, x, hj, hx, F.array__ndec(d, j), {==}, pf)

