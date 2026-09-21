import Base
import ../compact/found.bend as F
import ../../types/fulu_obj.bend as T

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

def validators_read_after_write(+d: Nat, +t: F.array__Tree<T.Validator>, +n: U32, +i: U32, +v: T.Validator, +x: T.Validator,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(T.Validator, F.array__slots(T.Validator, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T.Validator>},
    +pf: {F.array__perfect(T.Validator, d, t) == True{} : Bool},
    +hn: {U32.is_lt(i, n) == True{} : Bool})
    -> {T.l1099511627776_Validator_get(Pair.fst(T.l1099511627776_Validator_Seq, Bool,
          T.l1099511627776_Validator_set(T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, t), n}, i, v)), i)
        == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
        : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}:
  %Equal.sym(Bool, U32.is_lt(i, n), True{}, hn) : {T.l1099511627776_Validator_get(Pair.fst(T.l1099511627776_Validator_Seq, Bool,
      T.l1099511627776_Validator_put_in(_, F.array__thaw(T.Validator, t), n, i, v)), i)
    == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
    : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}
  %Equal.sym(Bool, U32.is_lt(i, n), True{}, hn) : {T.l1099511627776_Validator_get_in(_,
      Array.set(T.Validator, F.array__thaw(T.Validator, t), i, v), n, i)
    == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
    : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}
  %Equal.sym(Array<T.Validator> & T.Validator,
      Array.get(T.Validator, Array.set(T.Validator, F.array__thaw(T.Validator, t), i, v), i),
      (F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), v),
      F.array__get_set_same(T.Validator, d, t, i, v, x, hd, hi, hx, pf))
    : {T.l1099511627776_Validator_took(n, _)
    == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{v})
    : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}
  {==}

def validators_other_unchanged(+d: Nat, +t: F.array__Tree<T.Validator>, +n: U32, +i: U32, +j: U32, +v: T.Validator, +x: T.Validator, +y: T.Validator,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hj: {Nat.is_lt(U32.to_nat(j), F.spec_common__pow2(d)) == True{} : Bool},
    +ne: {Nat.is_eq(U32.to_nat(i), U32.to_nat(j)) == False{} : Bool},
    +hx: {F.spec_common__nth(T.Validator, F.array__slots(T.Validator, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T.Validator>},
    +hy: {F.spec_common__nth(T.Validator, F.array__slots(T.Validator, t), U32.to_nat(j)) == Some{y} : Maybe<&2, T.Validator>},
    +pf: {F.array__perfect(T.Validator, d, t) == True{} : Bool},
    +hn: {U32.is_lt(i, n) == True{} : Bool},
    +hm: {U32.is_lt(j, n) == True{} : Bool})
    -> {T.l1099511627776_Validator_get(Pair.fst(T.l1099511627776_Validator_Seq, Bool,
          T.l1099511627776_Validator_set(T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, t), n}, i, v)), j)
        == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
        : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}:
  %Equal.sym(Bool, U32.is_lt(i, n), True{}, hn) : {T.l1099511627776_Validator_get(Pair.fst(T.l1099511627776_Validator_Seq, Bool,
      T.l1099511627776_Validator_put_in(_, F.array__thaw(T.Validator, t), n, i, v)), j)
    == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
    : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}
  %Equal.sym(Bool, U32.is_lt(j, n), True{}, hm) : {T.l1099511627776_Validator_get_in(_,
      Array.set(T.Validator, F.array__thaw(T.Validator, t), i, v), n, j)
    == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
    : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}
  %Equal.sym(Array<T.Validator> & T.Validator,
      Array.get(T.Validator, Array.set(T.Validator, F.array__thaw(T.Validator, t), i, v), j),
      (F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), y),
      F.array__get_set_other(T.Validator, d, t, i, j, v, x, y, hd, hi, hj, ne, hx, hy, pf))
    : {T.l1099511627776_Validator_took(n, _)
    == (T.l1099511627776_Validator_Seq{F.array__thaw(T.Validator, F.array__upd(T.Validator, d, t, U32.to_nat(i), v)), n}, Some{y})
    : T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>}
  {==}
