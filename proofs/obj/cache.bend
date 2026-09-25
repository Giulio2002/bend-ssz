import Base
import ../compact/found.bend as F
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T

# Laws of the cached Merkle tree of BeaconState.validators
# (the _cache / _cset / _capp / _cached_root API of types/fulu_obj.bend).
#
# The cache is a heap of digests over the element array's capacity together
# with the range [lo, hi] of element indices whose leaves have changed since
# the last root. What is proved here, for an arbitrary cache, index and value:
#
#   cset_accepted     a write replaces the element and widens the dirty range
#                     to cover it, leaving the digests, the length, the depth
#                     and every other element alone;
#   cset_rejected     an out-of-range write changes nothing at all;
#   capp_rejected     an append past the list limit changes nothing at all;
#   capp_fits         an append inside the capacity stores the element, adds
#                     one to the length and widens the range to the new leaf;
#   capp_grows        an append that fills the capacity moves to a fresh tree
#                     with every leaf dirty (the rebuild that amortises);
#   sweep_empty       a root with an empty dirty range walks nothing: a warm
#                     root re-reads the cached digests and hashes nothing;
#   leaf_zero         a leaf past the length is the zero chunk, which is what
#                     SSZ merkleization pads a list with;
#   leaf_hashes       a leaf inside the length is the element's own root;
#   node_hashes       an internal node is the hash of its two children;
#   pad_zero_subtree  the levels between the capacity and the list's limit
#                     depth fold in the zero subtree root of each level;
#   croot_mixes_len   the returned root is the tree root with the length mixed
#                     in, and the returned cache has an empty dirty range.
#
# The premises on the arrays are the ones the array lemmas of
# proofs/compact/found.bend need: a perfect tree of depth d < 32 (which is what
# Array.new builds and Array.set preserves), an index inside it, and the value
# currently stored there.
#
# Not proved here: that the whole cached root equals the whole uncached root
# after an arbitrary history. That needs a statement about the uncached
# streaming merkleization (src/merkle_fast.bend) in terms of the leaves it is
# given, which the Merkle stack has no proof of yet; the two are compared
# instead by benchmarks/checks/object_cache.py on real and synthetic states,
# after writes and after appends, against an independent Python oracle, and by
# the differential fuzz campaign in tests_generated/fuzz_objects.py.

def validators_cset_accepted(arr: Array<T.Validator>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, +i: U32, v: T.Validator)
    -> {T.l1099511627776_Validator_cset_in(True{}, arr, n, d, nodes, lo, hi, i, v)
        == (T.l1099511627776_Validator_Cached{Array.set(T.Validator, arr, i, v), n, d, nodes,
              O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})
        : T.l1099511627776_Validator_Cached & Bool}:
  {==}

def validators_cset_rejected(arr: Array<T.Validator>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, +i: U32, v: T.Validator)
    -> {T.l1099511627776_Validator_cset_in(False{}, arr, n, d, nodes, lo, hi, i, v)
        == (T.l1099511627776_Validator_Cached{arr, n, d, nodes, lo, hi}, False{})
        : T.l1099511627776_Validator_Cached & Bool}:
  {==}

def validators_capp_rejected(arr: Array<T.Validator>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: T.Validator)
    -> {T.l1099511627776_Validator_capp_in(False{}, arr, n, d, nodes, lo, hi, v)
        == (T.l1099511627776_Validator_Cached{arr, n, d, nodes, lo, hi}, False{})
        : T.l1099511627776_Validator_Cached & Bool}:
  {==}

def validators_capp_fits(arr: Array<T.Validator>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: T.Validator)
    -> {T.l1099511627776_Validator_capp_fit(True{}, arr, n, d, nodes, lo, hi, v)
        == T.l1099511627776_Validator_Cached{Array.set(T.Validator, arr, n, v), (n + 1 : U32), d, nodes,
             O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)}
        : T.l1099511627776_Validator_Cached}:
  {==}

def validators_capp_grows(arr: Array<T.Validator>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: T.Validator)
    -> {T.l1099511627776_Validator_capp_fit(False{}, arr, n, d, nodes, lo, hi, v)
        == T.l1099511627776_Validator_Cached{
             Array.set(T.Validator, T.l1099511627776_Validator_room(arr, n), n, v), (n + 1 : U32), 1n+d,
             T.l1099511627776_Validator_dfill(2n+d), 0, (O.pow2u(1n+d) - 1 : U32)}
        : T.l1099511627776_Validator_Cached}:
  {==}

# A root with nothing dirty walks no node at all.
def validators_sweep_empty(+hl: Nat, +d: Nat, +lo: U32, +hi: U32, +n: U32, +seg: U32, ts: T.l1099511627776_Validator_TS)
    -> {T.l1099511627776_Validator_sweep_pick(hl, False{}, d, lo, hi, n, seg, ts) == ts : T.l1099511627776_Validator_TS}:
  {==}

# A leaf past the length is the zero chunk.
def validators_leaf_zero(+hl: Nat, +k: U32, +i: U32, +seg: U32, ts: T.l1099511627776_Validator_TS)
    -> {T.l1099511627776_Validator_leaf_step(hl, False{}, k, i, seg, ts)
        == T.l1099511627776_Validator_ts_store(ts, k, D.zero()) : T.l1099511627776_Validator_TS}:
  {==}

# A leaf inside the length is the element's own hash_tree_root, stored at that
# leaf; the element is read out of the packed array at its index.
def validators_leaf_hashes(+hl: Nat, +d: Nat, +t: F.array__Tree<T.Validator>, nodes: Array<D.Digest>, h: B.Buf, +k: U32, +i: U32, +seg: U32, +x: T.Validator,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(T.Validator, F.array__slots(T.Validator, t), U32.to_nat(i)) == Some{x} : Maybe<&2, T.Validator>},
    +pf: {F.array__perfect(T.Validator, d, t) == True{} : Bool})
    -> {T.l1099511627776_Validator_leaf_step(hl, True{}, k, i, seg,
          T.l1099511627776_Validator_TS{h, F.array__thaw(T.Validator, t), nodes})
        == T.l1099511627776_Validator_leaf_fin(k, F.array__thaw(T.Validator, t), nodes,
             T.Validator_root(hl, h, x, (seg + 64 : U32)))
        : T.l1099511627776_Validator_TS}:
  %Equal.sym(Array<T.Validator> & T.Validator, Array.get(T.Validator, F.array__thaw(T.Validator, t), i),
      (F.array__thaw(T.Validator, t), x), F.array__get(T.Validator, d, t, i, x, hd, hi, hx, pf))
    : {T.l1099511627776_Validator_leaf_go(hl, k, seg, nodes, h, _)
    == T.l1099511627776_Validator_leaf_fin(k, F.array__thaw(T.Validator, t), nodes,
         T.Validator_root(hl, h, x, (seg + 64 : U32)))
    : T.l1099511627776_Validator_TS}
  {==}

# The digest a leaf step stores is the digest the element hashed to.
def validators_leaf_stores(+k: U32, h: B.Buf, arr: Array<T.Validator>, nodes: Array<D.Digest>, +dg: D.Digest)
    -> {T.l1099511627776_Validator_leaf_fin(k, arr, nodes, (h, dg))
        == T.l1099511627776_Validator_TS{h, arr, Array.set(D.Digest, nodes, k, dg)} : T.l1099511627776_Validator_TS}:
  {==}

# An internal node is the hash of its two children, read out of the node array
# at 2j and 2j+1 and stored at j.
def validators_node_hashes(+hl: Nat, +dn: Nat, +t: F.array__Tree<D.Digest>, arr: Array<T.Validator>, h: B.Buf, +j: U32, +dl: D.Digest, +dr: D.Digest,
    +hd: {Nat.is_lt(dn, 32n) == True{} : Bool},
    +hle: {Nat.is_lt(U32.to_nat((2 * j : U32)), F.spec_common__pow2(dn)) == True{} : Bool},
    +hr: {Nat.is_lt(U32.to_nat((2 * j + 1 : U32)), F.spec_common__pow2(dn)) == True{} : Bool},
    +hx: {F.spec_common__nth(D.Digest, F.array__slots(D.Digest, t), U32.to_nat((2 * j : U32))) == Some{dl} : Maybe<&2, D.Digest>},
    +hy: {F.spec_common__nth(D.Digest, F.array__slots(D.Digest, t), U32.to_nat((2 * j + 1 : U32))) == Some{dr} : Maybe<&2, D.Digest>},
    +pf: {F.array__perfect(D.Digest, dn, t) == True{} : Bool})
    -> {T.l1099511627776_Validator_node_step(hl, j, T.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)})
        == T.l1099511627776_Validator_TS{h, arr,
             Array.set(D.Digest, F.array__thaw(D.Digest, t), j, D.node(hl, dl, dr))}
        : T.l1099511627776_Validator_TS}:
  %Equal.sym(Array<D.Digest> & D.Digest, Array.get(D.Digest, F.array__thaw(D.Digest, t), (2 * j : U32)),
      (F.array__thaw(D.Digest, t), dl), F.array__get(D.Digest, dn, t, (2 * j : U32), dl, hd, hle, hx, pf))
    : {T.l1099511627776_Validator_node_go(hl, j, h, arr, _)
    == T.l1099511627776_Validator_TS{h, arr, Array.set(D.Digest, F.array__thaw(D.Digest, t), j, D.node(hl, dl, dr))}
    : T.l1099511627776_Validator_TS}
  %Equal.sym(Array<D.Digest> & D.Digest, Array.get(D.Digest, F.array__thaw(D.Digest, t), (2 * j + 1 : U32)),
      (F.array__thaw(D.Digest, t), dr), F.array__get(D.Digest, dn, t, (2 * j + 1 : U32), dr, hd, hr, hy, pf))
    : {T.l1099511627776_Validator_node_fin(hl, j, h, arr, dl, _)
    == T.l1099511627776_Validator_TS{h, arr, Array.set(D.Digest, F.array__thaw(D.Digest, t), j, D.node(hl, dl, dr))}
    : T.l1099511627776_Validator_TS}
  {==}

# Above the capacity the tree is padded with the zero subtree root of each
# level, one hash per level, up to the list's limit depth.
def validators_pad_zero_subtree(+hl: Nat, +q: Nat, +lvl: U32, +r: D.Digest, h: B.Buf, +z: D.Digest)
    -> {T.l1099511627776_Validator_pad_go(hl, 1n+q, lvl, r, (h, z))
        == T.l1099511627776_Validator_pad_go(hl, q, (lvl + 1 : U32), D.node(hl, r, z), (h, D.zconst(U32.to_nat((lvl + 1 : U32)))))
        : B.Buf & D.Digest}:
  {==}

def validators_pad_done(+hl: Nat, +lvl: U32, +r: D.Digest, h: B.Buf, +z: D.Digest)
    -> {T.l1099511627776_Validator_pad_go(hl, 0n, lvl, r, (h, z)) == (h, r) : B.Buf & D.Digest}:
  {==}

# The root the API returns is the tree root with the length mixed in, and the
# cache it returns has the dirty range [n, 0]: empty for n > 0 (lo > hi), so the
# next root hashes nothing unless something is written; for n = 0 it is the one
# zero leaf. A write at i < n then narrows it to [i, i], an append to [n, n].
def validators_croot_mixes_len(+hl: Nat, +n: U32, +d: Nat, arr: Array<T.Validator>, nodes: Array<D.Digest>, h: B.Buf, +r: D.Digest)
    -> {T.l1099511627776_Validator_croot_fin(hl, n, d, arr, nodes, (h, r))
        == (h, (T.l1099511627776_Validator_Cached{arr, n, d, nodes, n, 0}, O.mix_len(hl, r, n)))
        : B.Buf & (T.l1099511627776_Validator_Cached & D.Digest)}:
  {==}
