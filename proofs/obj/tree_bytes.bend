import Base
import ../../src/obj.bend as O
import ../../src/buffer.bend as B
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/bytes.bend as Bytes
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ./spec_fixed.bend as SF
import ./words_spec.bend as WS
import ./words_obj_light.bend as WO
import ./arr_spec_generated.bend as AS

# Byte storage held in a words tree, over the tree itself: the storage [l | r] of a byte vector
# whose bytes are the limbs of l's words (r its padding). Stated over the variable trees l and r,
# so a caller never spells out the 2^d words and no comparison exceeds the checker's identity
# budget (the per-name literal laws, instantiated at 1024 leaf terms, made the checker run the
# encoder). The per-name companions (spec_laws: <n>_ob, <n>_spec_encode_t) and the bridges
# compose these with the tree-form encoder law (<n>_tb).

# the first n elements of xs ++ ys are xs, n its length
law btake_app:
  for +xs: +List<U32>
  for +ys: +List<U32>
  {WS.btake(List.length(&2, U32, xs), List.append(&2, U32, xs, ys)) == xs : +List<U32>}
def btake_app(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(+List<U32>, +List<U32>, z => h <> z, WS.btake(List.length(&2, U32, t), List.append(&2, U32, t, ys)), t, btake_app(t, ys))

# the byte view of storage [l | r] at its byte length: the limbs of l's words
def view(+d: Nat, +l: F.array__Tree<U32>, +r: F.array__Tree<U32>, +N: U32,
    +pl: {F.array__perfect(U32, d, l) == True{} : Bool},
    +hN: {Nat.is_eq(A.quad(F.spec_common__pow2(d)), U32.to_nat(N)) == True{} : Bool})
    -> {WO.wview(O.Words{ANode{F.array__thaw(U32, l), F.array__thaw(U32, r)}, N}) == SF.limbs(F.array__slots(U32, l)) : +List<U32>}:
  +X = SF.limbs(F.array__slots(U32, l))
  +Y = SF.limbs(F.array__slots(U32, r))
  +eW = F.nat__eq_from_is_eq(SF.wlen(F.array__slots(U32, l)), U32.to_nat(N), AS.wlen_tree(d, l, U32.to_nat(N), pl, hN))
  +eL = Equal.trans(Nat, List.length(&2, U32, X), SF.wlen(F.array__slots(U32, l)), U32.to_nat(N), AS.len_limbs(F.array__slots(U32, l)), eW)
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, l)), l, F.array__freeze_thaw(U32, l)) :
    {WS.btake(U32.to_nat(N), SF.limbs(F.array__slots(U32, F.TNode{_, F.array__freeze(U32, F.array__thaw(U32, r))}))) == X : +List<U32>}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, r)), r, F.array__freeze_thaw(U32, r)) :
    {WS.btake(U32.to_nat(N), SF.limbs(F.array__slots(U32, F.TNode{l, _}))) == X : +List<U32>}
  %Equal.sym(+List<U32>, SF.limbs(F.spec_common__append(U32, F.array__slots(U32, l), F.array__slots(U32, r))), List.append(&2, U32, X, Y), AS.limbs_app(F.array__slots(U32, l), F.array__slots(U32, r))) :
    {WS.btake(U32.to_nat(N), _) == X : +List<U32>}
  %eL : {WS.btake(_, List.append(&2, U32, X, Y)) == X : +List<U32>}
  btake_app(X, Y)

# the parts of a byte vector of n > 0 bytes, the limbs of a word list
def bpart(+xs: +List<U32>, +n: Nat, +en: {n == SF.wlen(xs) : Nat}, +hn: {Nat.is_lt(0n, n) == True{} : Bool},
    +fit: {Bytes.size_fits(SF.wlen(xs)) == True{} : Bool})
    -> {Codec.parts(S.BytesValue{SF.limbs(xs)}, S.ByteVector{n}) == Some{[S.Fixed{SF.limbs(xs)}]} : Maybe<&2, +List<S.Part>>}:
  match xs:
    case Nil{}:
      Empty.absurd({Codec.parts(S.BytesValue{SF.limbs([])}, S.ByteVector{n}) == Some{[S.Fixed{SF.limbs([])}]} : Maybe<&2, +List<S.Part>>},
        F.logic__false_true(F.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, n, 0n, en, hn)))
    case Con{+h, +t}: SF.bytes_part_n(h, t, n, en, fit)

# the byte vector of the limbs of a perfect tree's words: its parts at ByteVector{n}, n = 4 * 2^d
def tparts(+d: Nat, +l: F.array__Tree<U32>, +n: Nat, +pl: {F.array__perfect(U32, d, l) == True{} : Bool},
    +hN: {Nat.is_eq(A.quad(F.spec_common__pow2(d)), n) == True{} : Bool}, +hn: {Nat.is_lt(0n, n) == True{} : Bool},
    +fit: {Bytes.size_fits(n) == True{} : Bool})
    -> {Codec.parts(S.BytesValue{SF.limbs(F.array__slots(U32, l))}, S.ByteVector{n}) == Some{[S.Fixed{SF.limbs(F.array__slots(U32, l))}]} : Maybe<&2, +List<S.Part>>}:
  +eW = F.nat__eq_from_is_eq(SF.wlen(F.array__slots(U32, l)), n, AS.wlen_tree(d, l, n, pl, hN))
  bpart(F.array__slots(U32, l), n, Equal.sym(Nat, SF.wlen(F.array__slots(U32, l)), n, eW), hn,
    F.logic__subst(Nat, z => {Bytes.size_fits(z) == True{} : Bool}, n, SF.wlen(F.array__slots(U32, l)), Equal.sym(Nat, SF.wlen(F.array__slots(U32, l)), n, eW), fit))

# a pair's second component is its listed bytes (F.emitted's form)
def pk(e: B.Buf & +List<U32>) -> {Pair.snd(B.Buf, +List<U32>, e) == SF.listed(e) : +List<U32>}:
  (b, xs) = e
  {==}

# the first |xs| + k elements of xs ++ ys are xs then the first k of ys
law take_app:
  for +xs: List<&2, U32>
  for +ys: List<&2, U32>
  for +k: Nat
  {F.spec_common__take(U32, F.spec_common__append(U32, xs, ys), Nat.add(F.spec_common__length(U32, xs), k)) == F.spec_common__append(U32, xs, F.spec_common__take(U32, ys, k)) : List<&2, U32>}
def take_app(xs, ys, k):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{h, z}, F.spec_common__take(U32, F.spec_common__append(U32, t, ys), Nat.add(F.spec_common__length(U32, t), k)), F.spec_common__append(U32, t, F.spec_common__take(U32, ys, k)), take_app(t, ys, k))
