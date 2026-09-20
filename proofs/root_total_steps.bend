import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/root.bend as IR
import ../src/cached_tree.bend as Cache
import ../src/bit_root.bend as IBits
import ../src/nat_bytes.bend as ILen
import ../src/limits.bend as ILimits
import ../src/progressive.bend as IProgressive
import ../src/primitives.bend as IP
import ../src/packing.bend as IPack
import ../src/mixing.bend as IMixing
import ../src/codec.bend as IC
import ../src/schema.bend as IS
import ../spec/codec.bend as SC
import ../spec/primitives.bend as SP
import ../spec/packing.bend as SPack
import ../spec/nat_bytes.bend as SLen
import ../spec/mixing.bend as SMixing
import ../spec/progressive.bend as SProgressive
import ./root_steps.bend as G
import ./root_scope.bend as Scope
import ./cached_tree.bend as CacheLaws
import ./root_relation_merkle.bend as Merkle
import ./limits.bend as LimitLaws
import ./progressive.bend as ProgressiveLaws
import ./bit_list_root.bend as BitListRoot
import ./nat_bytes.bend as Lengths
import ./mixing.bend as MixingLaws
import ./packing.bend as Packing
import ./tree.bend as Tree
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ../src/bit_packing.bend as IBitPack
import ./bit_packing.bend as BitPackLaws
import ../spec/layout.bend as E
import ../src/byte_list.bend as IByteList
import ./byte_list.bend as ByteListLaws
import ./bit_chunk_count.bend as Count
import ./nat_order.bend as Order
import ./nat_algebra.bend as A
import ./decode_facts.bend as F
import ./schema_lookups.bend as DG
import ./layout_image_headers.bend as H

# Presence (totality) building blocks for actual recursive roots.
def present(result: Maybe<&2, +List<+List<U32>>>) -> Bool:
  match result:
    case None{}: False{}
    case Some{rs}: True{}

def parts_present(result: Maybe<&2, +List<T.Part>>) -> Bool:
  match result:
    case None{}: False{}
    case Some{ps}: True{}

law single_present:
  for +m: Maybe<&2, +List<U32>>
  for +e: {IP.is_some(m) == True{} : Bool}
  {present(IR.single(m)) == True{} : Bool}
def single_present(m, e):
  match m:
    case None{}: e
    case Some{x}: {==}

law merkle_present:
  for +limit: Nat
  for +rs: +List<+List<U32>>
  for +size: Nat
  for +domain: {SPack.chunks_domain(rs) == True{} : Bool}
  for +count: {Nat.is_le(List.length(&2, +List<U32>, rs), limit) == True{} : Bool}
  {IP.is_some(Cache.merkleize(limit, rs, Cache.zeros(size))) == True{} : Bool}
def merkle_present(limit, rs, size, domain, count):
  %Equal.sym(Maybe<&2, +List<U32>>, Cache.merkleize(limit, rs, Cache.zeros(size)), ILimits.merkleize(limit, rs), CacheLaws.merkleize_correct(limit, rs, size)) : {IP.is_some(_) == True{} : Bool}
  %Equal.sym(Bool, IP.is_some(ILimits.merkleize(limit, rs)), Bool.and(SPack.chunks_domain(rs), Nat.is_le(List.length(&2, +List<U32>, rs), limit)), LimitLaws.merkleize_rejection(limit, rs)) : {_ == True{} : Bool}
  V.and_true(SPack.chunks_domain(rs), Nat.is_le(List.length(&2, +List<U32>, rs), limit), domain, count)

law progressive_present:
  for +rs: +List<+List<U32>>
  for +size: Nat
  for +domain: {SPack.chunks_domain(rs) == True{} : Bool}
  {IP.is_some(Cache.progressive(rs, Cache.zeros(size))) == True{} : Bool}
def progressive_present(rs, size, domain):
  %Equal.sym(Maybe<&2, +List<U32>>, Cache.progressive(rs, Cache.zeros(size)), SProgressive.merkleize(rs), Merkle.cached_progressive_correct(rs, size)) : {IP.is_some(_) == True{} : Bool}
  %ProgressiveLaws.merkleize_correct(rs) : {IP.is_some(_) == True{} : Bool}
  %Equal.sym(Bool, IP.is_some(IProgressive.merkleize(rs)), SPack.chunks_domain(rs), ProgressiveLaws.exact_acceptance(rs)) : {_ == True{} : Bool}
  domain

law merkle_scope:
  for +limit: Nat
  for +rs: +List<+List<U32>>
  for +prog: Bool
  for +size: Nat
  Tree.result_scope(IR.merkle(Some{rs}, limit, prog, Cache.zeros(size)))
def merkle_scope(limit, rs, prog, size): Scope.merkle_scope(Some{rs}, limit, prog, size)

def fits_length(length: Maybe<&2, Nat>) -> Type:
  match length:
    case None{}: Unit
    case Some{n}: {SLen.fits(32n, n) == True{} : Bool}

law mixed_present:
  for +root: Maybe<&2, +List<U32>>
  for +length: Maybe<&2, Nat>
  for +rp: {IP.is_some(root) == True{} : Bool}
  for scope: Tree.result_scope(root)
  for fits: fits_length(length)
  {IP.is_some(IR.length_mix(root, length)) == True{} : Bool}
def mixed_present(root, length, rp, scope, fits):
  match length:
    case None{}: rp
    case Some{n}:
      %Equal.sym(Bool, IP.is_some(IBits.mix_length_bytes(root, ILen.encode(32n, n))), Bool.and(IP.is_some(root), IP.is_some(ILen.encode(32n, n))), BitListRoot.mix_acceptance(root, ILen.encode(32n, n), scope, Lengths.length_scope(n))) : {_ == True{} : Bool}
      V.and_true(IP.is_some(root), IP.is_some(ILen.encode(32n, n)), rp, Equal.trans(Bool, IP.is_some(ILen.encode(32n, n)), SLen.fits(32n, n), True{}, Lengths.encode_acceptance(32n, n), fits))

def limit_ok(prog: Bool, rs: +List<+List<U32>>, limit: Nat) -> Type:
  match prog:
    case False{}: {Nat.is_le(List.length(&2, +List<U32>, rs), limit) == True{} : Bool}
    case True{}: Unit

law aggregate_present:
  for +limit: Nat
  for +rs: +List<+List<U32>>
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +domain: {SPack.chunks_domain(rs) == True{} : Bool}
  for count: limit_ok(prog, rs, limit)
  for fits: fits_length(length)
  {present(IR.single(IR.length_mix(IR.merkle(Some{rs}, limit, prog, Cache.zeros(size)), length))) == True{} : Bool}
def aggregate_present(limit, rs, prog, length, size, domain, count, fits):
  match prog:
    case False{}: single_present(IR.length_mix(Cache.merkleize(limit, rs, Cache.zeros(size)), length), mixed_present(Cache.merkleize(limit, rs, Cache.zeros(size)), length, merkle_present(limit, rs, size, domain, count), merkle_scope(limit, rs, False{}, size), fits))
    case True{}: single_present(IR.length_mix(Cache.progressive(rs, Cache.zeros(size)), length), mixed_present(Cache.progressive(rs, Cache.zeros(size)), length, progressive_present(rs, size, domain), merkle_scope(limit, rs, True{}, size), fits))

law composite_present:
  for +result: Maybe<&2, +List<+List<U32>>>
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +exists: {present(result) == True{} : Bool}
  for scope: Scope.roots_scope(result)
  for count: G.rel_single(outs => limit_ok(prog, outs, limit), result)
  for fits: fits_length(length)
  {present(IR.single(IR.length_mix(IR.merkle(result, limit, prog, Cache.zeros(size)), length))) == True{} : Bool}
def composite_present(result, limit, prog, length, size, exists, scope, count, fits):
  match result:
    case None{}: Empty.absurd({present(IR.single(IR.length_mix(IR.merkle(None{}, limit, prog, Cache.zeros(size)), length))) == True{} : Bool}, W.false_true(exists))
    case Some{rs}: aggregate_present(limit, rs, prog, length, size, scope, count, fits)

law active_domain:
  for +active: +List<Bool>
  for +rs: +List<+List<U32>>
  for +domain: {SPack.chunks_domain(rs) == True{} : Bool}
  {SPack.chunks_domain(IR.active_chunks(active, rs)) == True{} : Bool}
def active_domain(active, rs, domain):
  match active:
    case Nil{}: {==}
    case Con{bit, rest}:
      match bit:
        case False{}: V.and_true(SP.byte_scope(32n, IP.pad(32n, [])), SPack.chunks_domain(IR.active_chunks(rest, rs)), Scope.padded_scope([], {==}), active_domain(rest, rs, domain))
        case True{}:
          match rs:
            case Nil{}: {==}
            case Con{h, t}: V.and_true(SP.byte_scope(32n, h), SPack.chunks_domain(IR.active_chunks(rest, t)), V.and_left(SP.byte_scope(32n, h), SPack.chunks_domain(t), domain), active_domain(rest, t, V.and_right(SP.byte_scope(32n, h), SPack.chunks_domain(t), domain)))

law active_present:
  for +result: Maybe<&2, +List<+List<U32>>>
  for +active: +List<Bool>
  for +size: Nat
  for +exists: {present(result) == True{} : Bool}
  for scope: Scope.roots_scope(result)
  {present(IR.active_root(result, active, Cache.zeros(size))) == True{} : Bool}
def active_present(result, active, size, exists, scope):
  match result:
    case None{}: Empty.absurd({present(IR.active_root(None{}, active, Cache.zeros(size))) == True{} : Bool}, W.false_true(exists))
    case Some{rs}:
      single_present(IBits.mix_length_bytes(Cache.progressive(IR.active_chunks(active, rs), Cache.zeros(size)), Some{IP.pad(32n, IBitPack.pack(active))}),
        %Equal.sym(Bool, IP.is_some(IBits.mix_length_bytes(Cache.progressive(IR.active_chunks(active, rs), Cache.zeros(size)), Some{IP.pad(32n, IBitPack.pack(active))})), Bool.and(IP.is_some(Cache.progressive(IR.active_chunks(active, rs), Cache.zeros(size))), True{}), BitListRoot.mix_acceptance(Cache.progressive(IR.active_chunks(active, rs), Cache.zeros(size)), Some{IP.pad(32n, IBitPack.pack(active))}, Scope.merkle_scope(Some{IR.active_chunks(active, rs)}, 0n, True{}, size), Scope.padded_scope(IBitPack.pack(active), BitPackLaws.pack_bytes(active)))) : {_ == True{} : Bool}
        V.and_true(IP.is_some(Cache.progressive(IR.active_chunks(active, rs), Cache.zeros(size))), True{}, progressive_present(IR.active_chunks(active, rs), size, active_domain(active, rs, scope)), {==}))

law selector_present:
  for +root: +List<U32>
  for +selector: U32
  for +scope: {SP.byte_scope(32n, root) == True{} : Bool}
  for +small: {U32.is_lt(selector, 256) == True{} : Bool}
  {present(IR.selector_mix(Some{root}, selector)) == True{} : Bool}
def selector_present(root, selector, scope, small):
  single_present(IMixing.mix_in_selector(root, selector),
    %Equal.sym(Bool, IP.is_some(IMixing.mix_in_selector(root, selector)), SMixing.selector_domain(root, selector), MixingLaws.mix_in_selector_rejection(root, selector)) : {_ == True{} : Bool}
    V.and_true(SP.byte_scope(32n, root), U32.is_lt(selector, 256), scope, small))

def single_ok(result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case Some{Con{root, Nil{}}}: {SP.byte_scope(32n, root) == True{} : Bool}
    case _: Empty

law unwrap_list_present:
  for +rs: +List<+List<U32>>
  for +selector: U32
  for known: single_ok(Some{rs})
  for +small: {U32.is_lt(selector, 256) == True{} : Bool}
  {present(IR.selector_mix(IR.unwrap(Some{rs}), selector)) == True{} : Bool}
def unwrap_list_present(rs, selector, known, small):
  match rs:
    case Nil{}:
      match known:
    case Con{root, rest}:
      match rest:
        case Nil{}: selector_present(root, selector, known, small)
        case Con{a, b}:
          match known:

law unwrap_present:
  for +result: Maybe<&2, +List<+List<U32>>>
  for +selector: U32
  for known: single_ok(result)
  for +small: {U32.is_lt(selector, 256) == True{} : Bool}
  {present(IR.selector_mix(IR.unwrap(result), selector)) == True{} : Bool}
def unwrap_present(result, selector, known, small):
  match result:
    case None{}:
      match known:
    case Some{rs}: unwrap_list_present(rs, selector, known, small)

law tagged_parts:
  for +selector: U32
  for +r: Maybe<&2, +List<T.Part>>
  for +encodable: {parts_present(SC.tagged(selector, r)) == True{} : Bool}
  {parts_present(r) == True{} : Bool}
def tagged_parts(selector, r, encodable):
  match r:
    case None{}: encodable
    case Some{ps}: {==}

law union_present:
  for +found: Maybe<&2, T.Schema>
  for +v: T.Value
  for +selector: U32
  for +size: Nat
  for +encodable: {parts_present(SC.with_option(found, s => SC.tagged(selector, SC.parts(v, s)))) == True{} : Bool}
  for small: DG.selection(selector, found)
  for recur: @+s: T.Schema -> @+same: {found == Some{s} : Maybe<&2, T.Schema>} -> {parts_present(SC.parts(v, s)) == True{} : Bool} -> single_ok(IR.roots_go(v, s, [], Cache.zeros(size)))
  {present(IR.with_schema(found, s => IR.selector_mix(IR.unwrap(IR.roots_go(v, s, [], Cache.zeros(size))), selector))) == True{} : Bool}
def union_present(found, v, selector, size, encodable, small, recur):
  match found:
    case None{}: Empty.absurd({present(IR.with_schema(None{}, s => IR.selector_mix(IR.unwrap(IR.roots_go(v, s, [], Cache.zeros(size))), selector))) == True{} : Bool}, W.false_true(encodable))
    case Some{s}:
      (valid, bound) = small
      unwrap_present(IR.roots_go(v, s, [], Cache.zeros(size)), selector, recur(s, {==}, tagged_parts(selector, SC.parts(v, s), encodable)), bound)


law bytes_fragment:
  for +width: Maybe<&2, Nat>
  for +bytes: +List<U32>
  {SC.bytes(Some{[SC.fragment(width, bytes)]}) == Some{bytes} : Maybe<&2, +List<U32>>}
def bytes_fragment(width, bytes):
  match width:
    case None{}: {==}
    case Some{n}: {==}

law packed_valid:
  for +bytes: +List<U32>
  for +domain: {SP.bytes_domain(bytes) == True{} : Bool}
  {IPack.valid_go(bytes, True{}) == True{} : Bool}
def packed_valid(bytes, domain):
  Equal.trans(Bool, IPack.valid_go(bytes, True{}), SP.bytes_domain(bytes), True{}, Packing.valid_go_correct(bytes, True{}), domain)

law scan_domain:
  for +bytes: +List<U32>
  for +domain: {SP.bytes_domain(bytes) == True{} : Bool}
  {SPack.chunks_domain(IPack.scan(bytes, 31n, [], [])) == True{} : Bool}
def scan_domain(bytes, domain):
  %packed_valid(bytes, domain) : Packing.result_domain(IPack.checked(_, bytes))
  Packing.pack_domain(bytes)

law packed_length:
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for +count: Nat
  for +w: Nat
  for +enc: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  for +shape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, count, Some{w}) : +List<Maybe<&2, Nat>>}
  {List.length(&2, U32, bytes) == Nat.mul(count, w) : Nat}
def packed_length(cps, bytes, count, w, enc, shape):
  %enc : V.sized(Nat.mul(count, w), _)
  F.encoded_sized(cps, Nat.mul(count, w),
    %Equal.sym(+List<Maybe<&2, Nat>>, H.widths(cps), List.replicate(Maybe<&2, Nat>, count, Some{w}), shape) : {F.total(_) == Some{Nat.mul(count, w)} : Maybe<&2, Nat>}
    F.copies_total(count, w))

law packed_count:
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for +count: Nat
  for +w: Nat
  for +limit: Nat
  for +enc: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  for +shape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, count, Some{w}) : +List<Maybe<&2, Nat>>}
  for +bound: {Nat.is_le(count, limit) == True{} : Bool}
  {Nat.is_le(List.length(&2, +List<U32>, IPack.scan(bytes, 31n, [], [])), IR.count_limit(Some{w}, limit)) == True{} : Bool}
def packed_count(cps, bytes, count, w, limit, enc, shape, bound):
  %Equal.sym(Nat, List.length(&2, +List<U32>, IPack.scan(bytes, 31n, [], [])), IByteList.chunk_limit(List.length(&2, U32, bytes)), ByteListLaws.packed_count(bytes)) : {Nat.is_le(_, IR.count_limit(Some{w}, limit)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, bytes), Nat.mul(count, w), packed_length(cps, bytes, count, w, enc, shape)) : {Nat.is_le(IByteList.chunk_limit(_), IR.count_limit(Some{w}, limit)) == True{} : Bool}
  Count.quotient_monotone(Nat.add(Nat.mul(count, w), 31n), Nat.add(Nat.mul(limit, w), 31n), 31n, 0n, 0n, Order.add_right(Nat.mul(count, w), Nat.mul(limit, w), 31n, A.mul_coefficient(count, limit, w, bound)))

def bytes_of(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{xs}: xs

law basic_bytes:
  for +w: Nat
  for +cps: +List<T.Part>
  for +encm: Maybe<&2, +List<U32>>
  for +width: Maybe<&2, Nat>
  for +count: Nat
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +enc: {E.encoding(cps) == encm : Maybe<&2, +List<U32>>}
  for +encodable: {parts_present(SC.one(encm, width)) == True{} : Bool}
  for count_ok: @+bytes: +List<U32> -> @+e: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>} -> limit_ok(prog, IPack.scan(bytes, 31n, [], []), IR.count_limit(Some{w}, limit))
  for fits: fits_length(length)
  {present(IR.single(IR.length_mix(IR.merkle(IR.packed(SC.bytes(SC.one(encm, width))), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}
def basic_bytes(w, cps, encm, width, count, limit, prog, length, size, enc, encodable, count_ok, fits):
  match encm:
    case None{}: Empty.absurd({present(IR.single(IR.length_mix(IR.merkle(IR.packed(SC.bytes(SC.one(None{}, width))), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}, W.false_true(encodable))
    case Some{bytes}:
      %Equal.sym(Maybe<&2, +List<U32>>, SC.bytes(Some{[SC.fragment(width, bytes)]}), Some{bytes}, bytes_fragment(width, bytes)) : {present(IR.single(IR.length_mix(IR.merkle(IR.packed(_), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}
      %Equal.sym(Bool, IPack.valid_go(bytes, True{}), True{}, packed_valid(bytes, DG.layout_bytes(cps, bytes, enc))) : {present(IR.single(IR.length_mix(IR.merkle(IPack.checked(_, bytes), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}
      aggregate_present(IR.count_limit(Some{w}, limit), IPack.scan(bytes, 31n, [], []), prog, length, size, scan_domain(bytes, DG.layout_bytes(cps, bytes, enc)), count_ok(bytes, enc), fits)


law basic_present:
  for +w: Nat
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for +width: Maybe<&2, Nat>
  for +count: Nat
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +encodable: {parts_present(SC.require(ok, SC.aggregate(r, width))) == True{} : Bool}
  for count_ok: @+cps: +List<T.Part> -> {r == Some{cps} : Maybe<&2, +List<T.Part>>} -> @+bytes: +List<U32> -> @+e: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>} -> limit_ok(prog, IPack.scan(bytes, 31n, [], []), IR.count_limit(Some{w}, limit))
  for fits: fits_length(length)
  {present(IR.single(IR.length_mix(IR.merkle(IR.packed(SC.bytes(SC.require(ok, SC.aggregate(r, width)))), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}
def basic_present(w, ok, r, width, count, limit, prog, length, size, encodable, count_ok, fits):
  match ok:
    case False{}: Empty.absurd({present(IR.single(IR.length_mix(IR.merkle(IR.packed(SC.bytes(None{})), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}, W.false_true(encodable))
    case True{}:
      match r:
        case None{}: Empty.absurd({present(IR.single(IR.length_mix(IR.merkle(IR.packed(SC.bytes(None{})), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length))) == True{} : Bool}, W.false_true(encodable))
        case Some{cps}: basic_bytes(w, cps, E.encoding(cps), width, count, limit, prog, length, size, {==}, encodable, count_ok(cps, {==}), fits)
