# SSZ root round-trip and complete incremental cache requirement — 2026-09-22

User-requested acceptance requirement. This supplements existing codegen, owning-object, mutation, proof, performance and memory requirements; it does not mark any implementation or proof complete.

## Root preservation through serialization

For every valid object x of every supported generated type T and legal supported schema/configuration, prove against the actual public generated APIs:
decode_T(encode_T(x)) = Ok(y), with semantic_value(y) = semantic_value(x), and
hash_tree_root_T(y) = hash_tree_root_T(x) = independent_SSZ_root_T(x).
This means hash x, encode x, decode the bytes, then hash the decoded object and compare the full 32-byte roots; the root itself is not the object passed to encode. Account for affine APIs returning updated owning objects/cache state. Hashing may update caches but must preserve semantic values and canonical encoded bytes.

Apply the theorem after arbitrary valid field mutations and list appends, with cold, warm and dirty reachable caches. Cache metadata is not serialized. A newly decoded object's cold cache must yield the same root as the original warmed/modified object. Compose actual codec refinement and root/cache refinement; a model-only equation, assumed roundtrip, hash equality implying object equality, or fixture-only test is insufficient. Preserve existing codec identity and malformed-input laws. No unsafe, axioms, admissions or narrowed domains.

## Full retained list Merkle tree and nested invalidation

Retain every populated leaf digest and internal subtree digest, including the list's path to its declared SSZ limit depth and its length-mixed root, across public hash_tree_root calls. Represent wholly empty subtrees by shared canonical zero hashes; do not allocate the entire maximum-capacity tree. Packed indexed node storage is appropriate. Retained memory and allocation/growth costs must be reported.

The ordinary generated BeaconState object/public mutation/root APIs must retain and use this cache. A separate opt-in list wrapper that BeaconState discards, reconstructs or bypasses does not satisfy this requirement.

After warming a BeaconState root, replacing a single existing validator or one of its fields must recompute only the changed validator's necessary hash work, its validator-list ancestor path, the list length-mix node as needed, and the enclosing BeaconState ancestor path. Unchanged validators, other state fields and unrelated cached subtrees must not be rehashed or scanned. List length stays unchanged on replacement. A subsequent unmodified root call reuses the clean final root without new hash-pair work.

Use sparse dirty tracking or equivalent eager path updates. Multiple distant edits must visit only the union of affected paths, not every element in the interval between the first and last edit. Prove unaffected cached nodes remain unchanged and cache validity propagates to enclosing containers. Mutations cannot bypass invalidation through public aliases. Rejection must preserve semantic and cache validity invariants.

Append updates the new leaf, affected paths and length mix-in. At capacity growth preserve/reuse existing subtree hashes rather than rehashing every old element; disclose potentially linear storage allocation/copy cost separately. Do not claim all append storage work is worst-case logarithmic.

## Required proof and measurement evidence

Prove cache root equality to an independent uncached SSZ root after arbitrary supported mutation/append histories; prove node-preservation and explicit hash-work bounds linked to actual generated operations. For one fixed-size validator replacement, hash work is bounded by changed-validator work + O(log declared_list_limit) + enclosing-container depth, independent of the number of unchanged validators. Account separately for allocation/copying, dirty traversal, cache lookup and hash work; bounded hash count alone does not establish bounded runtime.

Add native tests using the public BeaconState API: cold/warm roots; one validator edit at first/middle/last indices; two widely separated edits; repeated edits; append at capacity boundaries; rejected mutations; encode/decode before and after these histories. Compare every full 32-byte root to independent recomputation and verify full canonical encoded bytes. Instrument actual hash calls and visited/updated cache nodes (with correspondence to production operations), and assert unrelated subtrees/validators are not revisited. Include reproducible scaling workloads, retained cache bytes and peak memory; distinguish first-root construction from warm/update costs. Benchmarks and finite tests supplement, not replace, universal proofs.

## Initial inspection (not acceptance evidence)

The current codegen/generate.py emit_seq_cache emits a heap-shaped Array<D.Digest> of leaves and internal nodes. Its lo/hi dirty interval sweeps all intervening leaves for separated edits; growth recreates the cache and marks the whole range dirty. Its root path also repads to the limit and mixes length on each call. These are concrete review targets. Establish integration with public BeaconState rather than assuming the existence of the helper proves it. All existing performance references, thresholds and proof-memory limits remain unchanged.

