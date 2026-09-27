import Base
import ../compact/found.bend as F
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d

# Element laws of a list of objects: BeaconState.validators, whose elements are
# whole Validator objects held in one packed native array (no linked list).
#
# Reading element i right after writing it returns the value written, and
# reading any other element j returns what was there before; in both cases the
# list keeps its length and every other element. The premises are the ones the
# array lemmas of proofs/compact/found.bend need: the storage is a perfect tree
# of depth d < 32 (which is what Array.new builds and Array.set preserves), the
# index is inside it and inside the length, and x (resp. y) is the value the
# element holds before the write. Nothing else is assumed about the list.
#
# The proof rewrites the two range guards to True with the index premise, then
# uses get-after-set on the underlying array.

def validators_read_after_write(+d: Nat, +t: F.array__Tree<FuluValidator_d.Validator>, +n: U32, +i: U32, +v: FuluValidator_d.Validator, +x: FuluValidator_d.Validator,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, t), U32.to_nat(i)) == Some{x} : Maybe<&2, FuluValidator_d.Validator>},
    +pf: {F.array__perfect(FuluValidator_d.Validator, d, t) == True{} : Bool},
    +hn: {U32.is_lt(i, n) == True{} : Bool})
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_get(Pair.fst(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool,
          Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_set(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, t), n}, i, v)), i)
        == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}:
  %Equal.sym(Bool, U32.is_lt(i, n), True{}, hn) : {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_get(Pair.fst(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool,
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_put_in(_, F.array__thaw(FuluValidator_d.Validator, t), n, i, v)), i)
    == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
    : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}
  %Equal.sym(Bool, U32.is_lt(i, n), True{}, hn) : {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_get_in(_,
      Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, t), i, v), n, i)
    == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
    : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}
  %Equal.sym(Array<FuluValidator_d.Validator> & FuluValidator_d.Validator,
      Array.get(FuluValidator_d.Validator, Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, t), i, v), i),
      (F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), v),
      F.array__get_set_same(FuluValidator_d.Validator, d, t, i, v, x, hd, hi, hx, pf))
    : {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_took(n, _)
    == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
    : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}
  {==}

def validators_other_unchanged(+d: Nat, +t: F.array__Tree<FuluValidator_d.Validator>, +n: U32, +i: U32, +j: U32, +v: FuluValidator_d.Validator, +x: FuluValidator_d.Validator, +y: FuluValidator_d.Validator,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hj: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(d)) == True{} : Bool},
    +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool},
    +hx: {F.spec_common__nth(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, t), U32.to_nat(i)) == Some{x} : Maybe<&2, FuluValidator_d.Validator>},
    +hy: {F.spec_common__nth(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, t), U32.to_nat(j)) == Some{y} : Maybe<&2, FuluValidator_d.Validator>},
    +pf: {F.array__perfect(FuluValidator_d.Validator, d, t) == True{} : Bool},
    +hn: {U32.is_lt(i, n) == True{} : Bool},
    +hm: {U32.is_lt(j, n) == True{} : Bool})
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_get(Pair.fst(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool,
          Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_set(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, t), n}, i, v)), j)
        == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}:
  %Equal.sym(Bool, U32.is_lt(i, n), True{}, hn) : {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_get(Pair.fst(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool,
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_put_in(_, F.array__thaw(FuluValidator_d.Validator, t), n, i, v)), j)
    == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
    : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}
  %Equal.sym(Bool, U32.is_lt(j, n), True{}, hm) : {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_get_in(_,
      Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, t), i, v), n, j)
    == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
    : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}
  %Equal.sym(Array<FuluValidator_d.Validator> & FuluValidator_d.Validator,
      Array.get(FuluValidator_d.Validator, Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, t), i, v), j),
      (F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), y),
      F.array__get_set_other(FuluValidator_d.Validator, d, t, i, j, v, x, y, hd, hi, hj, ne, hx, hy, pf))
    : {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_took(n, _)
    == (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
    : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & Maybe<&1, FuluValidator_d.Validator>}
  {==}
