import ./basic_root.bend as Padding
import Base
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as FIPS
import ../src/mixing.bend as I
import ../src/merkle.bend as M
import ../src/primitives.bend as R
import ../spec/mixing.bend as S
import ../spec/primitives.bend as P
import ../types/primitive.bend as T
import ./integer_encoding.bend as E
import ./merkle.bend as Nodes
import ./primitives.bend as Basic
import ./primitive_invariants.bend as V

law branch_correct:
  for ok: Bool
  for +root: +List<U32>
  for +length: T.UInt
  {M.pair_checked(ok, root, R.uint_bytes(length)) == S.checked(ok, root, length) : Maybe<&2, +List<U32>>}
def branch_correct(ok, root, length):
  match ok:
    case False{}: {==}
    case True{}:
      %E.all_digits_correct(length) :
        {M.pair_checked(True{}, root, R.uint_bytes(length)) == Some{FIPS.sha256_bytes(List.append(&2, U32, root, _))} : Maybe<&2, +List<U32>>}
      Nodes.pair_branch(True{}, root, R.uint_bytes(length))

law mix_in_length_correct:
  for +root: +List<U32>
  for +length: T.UInt
  {I.mix_in_length(root, length) == S.mix_in_length(root, length) : Maybe<&2, +List<U32>>}
def mix_in_length_correct(root, length):
  %Basic.byte_scope_correct(32n, root) :
    {I.mix_in_length(root, length) == S.checked(_, root, length) : Maybe<&2, +List<U32>>}
  branch_correct(R.valid_bytes(32n, root), root, length)

law mix_in_length_rejection:
  for +root: +List<U32>
  for +length: T.UInt
  {R.is_some(I.mix_in_length(root, length)) == P.byte_scope(32n, root) : Bool}
def mix_in_length_rejection(root, length):
  %Basic.byte_scope_correct(32n, root) :
    {R.is_some(I.mix_in_length(root, length)) == _ : Bool}
  Nodes.pair_accepts(R.valid_bytes(32n, root), root, R.uint_bytes(length))

law mix_in_length_size:
  for +root: +List<U32>
  for +length: T.UInt
  {Basic.lengths(I.mix_in_length(root, length)) == Bool.pick(Maybe<&2, Nat>, P.byte_scope(32n, root), Some{32n}, None{}) : Maybe<&2, Nat>}
def mix_in_length_size(root, length):
  %Basic.byte_scope_correct(32n, root) :
    {Basic.lengths(I.mix_in_length(root, length)) == Bool.pick(Maybe<&2, Nat>, _, Some{32n}, None{}) : Maybe<&2, Nat>}
  Nodes.pair_length(R.valid_bytes(32n, root), root, R.uint_bytes(length))

law mix_in_length_bytes:
  for +root: +List<U32>
  for +length: T.UInt
  V.byte_result(I.mix_in_length(root, length))
def mix_in_length_bytes(root, length):
  Nodes.pair_domain(R.valid_bytes(32n, root), root, R.uint_bytes(length))

# Discharge the internal uint256 chunk invariant, independently of the root
# validation branch. This is universal over the representation, with no premise.
law length_encoding_size:
  for +length: T.UInt
  {List.length(&2, U32, R.uint_bytes(length)) == 32n : Nat}
def length_encoding_size(length):
  match length:
    case T.UInt{a, b, c, d, e, f, g, h}: {==}

law length_encoding_scope:
  for +length: T.UInt
  {P.byte_scope(32n, R.uint_bytes(length)) == True{} : Bool}
def length_encoding_scope(length):
  %length_encoding_size(length) : {P.byte_scope(_, R.uint_bytes(length)) == True{} : Bool}
  %Equal.sym(Bool, P.byte_scope(List.length(&2, U32, R.uint_bytes(length)), R.uint_bytes(length)), P.bytes_domain(R.uint_bytes(length)), V.scope_of_domain(R.uint_bytes(length))) :
    {_ == True{} : Bool}
  V.uint_bytes_domain(length)


law selector_chunk_correct:
  for +selector: U32
  {R.pad(32n, [selector]) == S.selector_chunk(selector) : +List<U32>}
def selector_chunk_correct(selector):
  Padding.padding_content([selector], 31n)

law selector_branch_correct:
  for ok: Bool
  for +root: +List<U32>
  for +selector: U32
  {M.pair_checked(ok, root, R.pad(32n, [selector])) == S.selector_checked(ok, root, selector) : Maybe<&2, +List<U32>>}
def selector_branch_correct(ok, root, selector):
  match ok:
    case False{}: {==}
    case True{}:
      %selector_chunk_correct(selector) :
        {M.pair_checked(True{}, root, R.pad(32n, [selector])) == Some{FIPS.sha256_bytes(List.append(&2, U32, root, _))} : Maybe<&2, +List<U32>>}
      Nodes.pair_branch(True{}, root, R.pad(32n, [selector]))

law mix_in_selector_correct:
  for +root: +List<U32>
  for +selector: U32
  {I.mix_in_selector(root, selector) == S.mix_in_selector(root, selector) : Maybe<&2, +List<U32>>}
def mix_in_selector_correct(root, selector):
  %Basic.byte_scope_correct(32n, root) :
    {I.mix_in_selector(root, selector) == S.selector_checked(Bool.and(_, U32.is_lt(selector, 256)), root, selector) : Maybe<&2, +List<U32>>}
  selector_branch_correct(Bool.and(R.valid_bytes(32n, root), U32.is_lt(selector, 256)), root, selector)

law mix_in_selector_rejection:
  for +root: +List<U32>
  for +selector: U32
  {R.is_some(I.mix_in_selector(root, selector)) == S.selector_domain(root, selector) : Bool}
def mix_in_selector_rejection(root, selector):
  %Basic.byte_scope_correct(32n, root) :
    {R.is_some(I.mix_in_selector(root, selector)) == Bool.and(_, U32.is_lt(selector, 256)) : Bool}
  Nodes.pair_accepts(Bool.and(R.valid_bytes(32n, root), U32.is_lt(selector, 256)), root, R.pad(32n, [selector]))

law mix_in_selector_size:
  for +root: +List<U32>
  for +selector: U32
  {Basic.lengths(I.mix_in_selector(root, selector)) == Bool.pick(Maybe<&2, Nat>, S.selector_domain(root, selector), Some{32n}, None{}) : Maybe<&2, Nat>}
def mix_in_selector_size(root, selector):
  %Basic.byte_scope_correct(32n, root) :
    {Basic.lengths(I.mix_in_selector(root, selector)) == Bool.pick(Maybe<&2, Nat>, Bool.and(_, U32.is_lt(selector, 256)), Some{32n}, None{}) : Maybe<&2, Nat>}
  Nodes.pair_length(Bool.and(R.valid_bytes(32n, root), U32.is_lt(selector, 256)), root, R.pad(32n, [selector]))

law mix_in_selector_bytes:
  for +root: +List<U32>
  for +selector: U32
  V.byte_result(I.mix_in_selector(root, selector))
def mix_in_selector_bytes(root, selector):
  Nodes.pair_domain(Bool.and(R.valid_bytes(32n, root), U32.is_lt(selector, 256)), root, R.pad(32n, [selector]))

law selector_chunk_scope:
  for +selector: U32
  for e: {U32.is_lt(selector, 256) == True{} : Bool}
  {P.byte_scope(32n, R.pad(32n, [selector])) == True{} : Bool}
def selector_chunk_scope(selector, e):
  %Basic.padded_length(32n, [selector]) : {P.byte_scope(_, R.pad(32n, [selector])) == True{} : Bool}
  %Equal.sym(Bool, P.byte_scope(List.length(&2, U32, R.pad(32n, [selector])), R.pad(32n, [selector])), P.bytes_domain(R.pad(32n, [selector])), V.scope_of_domain(R.pad(32n, [selector]))) : {_ == True{} : Bool}
  Padding.pad_preserves_domain(32n, [selector], V.and_true(U32.is_lt(selector, 256), True{}, e, {==}))
