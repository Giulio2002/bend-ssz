# Round 12 (agent/manual-spec-mutations-r12); fixed in agent/r11-fixes (../r11/REPORT.md, section Round 11 fixes)

## R12.0 Round 12 (agent/manual-spec-mutations-r12, base 6dfc82a55): scope and the proof-gap list

Round 9 to 11 sections live on their own branches (b0cf210c9, 93459f12b, 0d7c51c65; round 11 is on gate.git). Recomputed with
`r10/unmentioned10.py` on 6dfc82a55: 4,672 API-shaped definitions, **539** named by no proof file (`r12/results/unmentioned12.*`): the
same list as round 11 (get 240, set 131, read 117, ok 30, valid 21), all in rounds 9 to 11's or fixer G's families; the one name not
on round 11's list is `l4096_b2048_set_v` (the inner of `l4096_b2048_set`, G's set family). So this round followed the brief's five
focus areas instead: (1) leaf roots as reached through container roots, (2) bit list roots, (3) the serialize path of unions and
progressive containers, (4) the cached tree of a non-empty (decoded) list and uncache, (5) booleans and bit vector padding inside
containers. Fixers H and I's areas (X_default, offset order, BeaconState windows, cache growth / cset-after-root, nested reader offsets,
boxed element rejects, union selector decode) were not mutated. Every fault is a hand-designed pattern (`r12/gen_defs12.py`, one
docstring line per family) instantiated on each generated file with the shape; 3 instances were dropped as exact duplicates of earlier rounds.

## R12.1 Result

| | count |
|---|---|
| New faults | **169** (20 families) |
| (A) killed by a named law | **150** |
| (A) survived every checked root | **12** (3 critical, 8 gap-unreachable-through-api (contract gap), 1 equivalent) |
| (A) UNJUDGED (checker stack overflow twice at the pinned settings on every root; never counted as a kill) | **7** |
| (B) corpus on the unjudged | 4 of 7 run (e03): **4 KILLED** (17 / 10 / 239 / 39 disagreements, both "ref accepts, mutant rejects" and "ref rejects, mutant accepts"); e02 (3, BeaconState) not run: no BeaconState case under the corpus size cap |
| (B) corpus, proof-killed sample | 14 run: **11 KILLED** (a01/02, a03/01, a04/01, a05/01, a05/05, a07/01, a07/03, b01/02, c04/02, c04/05, e01/01), 3 SURVIVED: c03/01, c05/02 (X_valid refusals: the corpus only decodes, re-encodes and hashes, and a decoded value is always valid: cannot observe) and b02/01 (equivalent in U32: 8 len - 8 + hb = 8 (len - 1) + hb) |
| (B) corpus on a survivor | c02/03: SURVIVED (cannot observe: decoded values are valid, so putn = putk) |
| Probe p12a (public calls only) | 5 faults: d01/02, d01/03, d02/03 print a cached root different from hash_tree_root of the same list; d02/02 (designed equivalent) prints the same line; d01/16 not applicable (transactions not in the probe) |

Per family (A killed / survived / unjudged):

| family | fault | n | K / S / U |
|---|---|---|---|
| r12-a01-leaf-noswap | ByteVector / Bitvector leaf root: word 0 not byte-swapped (Bytes1..96, Fulu bit vectors 4/64/128/512, Bitvector 15/31) | 13 | 13 / 0 / 0 |
| r12-a02-leaf-last-drop | leaf root: last word left out of the chunk | 8 | 8 / 0 / 0 |
| r12-a03-leaf-right-align | single-word leaf root: bytes right-aligned in the chunk | 5 | 5 / 0 / 0 |
| r12-a04-leaf-word-order | leaf root: two adjacent words exchanged (also across a chunk boundary in Bytes48 / 96) | 6 | 6 / 0 / 0 |
| r12-a05-u64-as-u32 | container root: a uint64 field packed as its low 32 bits (18 containers, every other one of 36) | 18 | 18 / 0 / 0 |
| r12-a06-uint-width-mask | uint8 / 16 / 32 root masked to a narrower width | 3 | 3 / 0 / 0 |
| r12-a07-shared-chunks | src/obj.bend u64_chunk word order / high word unswapped, bool_chunk True as word 1 / in the last limb, u32_chunk in limb 1 | 5 | 5 / 0 / 0 |
| r12-b01-bitlist-depth | Bitlist[N] root depth one off (13 limits, +1; -1 for 1280, 1281, 2048) | 15 | 15 / 0 / 0 |
| r12-b02-delimiter | bit list decode: bit count 8 len - 8 + high bit (designed equivalent: killed, see R12.3) | 1 | 1 / 0 / 0 |
| r12-c01-ser-flag | X_serialize ignores the checked writer's flag (unions, progressive containers / lists) | 8 | 8 / 0 / 0 |
| r12-c02-ser-unchecked | X_serialize writes with putn (no validity) instead of putk | 8 | 0 / 8 / 0 |
| r12-c03-union-payload-ok | union validity: an option's payload validity dropped | 4 | 4 / 0 / 0 |
| r12-c04-union-sel-index | union writer: selector byte = option index | 7 | 7 / 0 / 0 |
| r12-c05-prog-valid-last | progressive container validity: last field dropped | 5 | 5 / 0 / 0 |
| r12-d01-cache-lo | X_cache: fresh dirty window starts at leaf 1 (17 cached kinds) | 17 | 15 / 2 / 0 |
| r12-d02-cache-depth0 | X_cache: depth of cap(0) instead of cap(n) | 18 | 16 / 2 / 0 |
| r12-d03-uncache-drop | X_uncache returns the empty list | 18 | 18 / 0 / 0 |
| r12-e01-bool-pos | Validator `slashed` check on byte 87 / 89 / 0 | 3 | 3 / 0 / 0 |
| r12-e02-vlist-ck | List[Validator] validity: element checks dropped / stride 120 / first element unchecked | 3 | 0 / 0 / 3 |
| r12-e03-bv-pad-pos | BitsStruct / ProgressiveBitsStruct: a bit vector's padding checked at the neighbouring byte | 4 | 0 / 0 / 4 |

Killing laws: `st_b4 .. st_b96`, `Bytes1_root_correct`, `bitvector_N_st` (a01-a04), `st_<Container>` (a05: AttestationData,
BeaconBlockHeader, BlobSidecar, ContributionAndProof, ...), `uintN_root_correct` (a06), `u64_root`, `bool_root`, `u32_root` (a07),
`bitlist_N_root_correct` (b01), `rd_go` (b02), `<T>_serialize_vrefuse_writer_marker` / `_vrefuse_f_A` (c01), `<T>_serialize_vreject_*`
(c03, c05), `rt0..rt3` (c04), `<Body>_vroot_<list>_cache_set_0 / _set_1_3 / _app_2` (d01, d02), `<Body>_serialize_vcoll_<list>_api_uncache`
(d03), `Validator_at` (e01). Every kill names a law. Focus areas (1), (2) and (5, Validator) are closed by the facades: no leaf root,
bit list root or boolean position fault survived a check that completed.

## R12.2 Findings

**Critical (3): the cached tree of a NON-EMPTY list is untested for two kinds.** The cache laws of 15 kinds include `cache_set_0` /
`cache_set_1_3`, which cache a 4-element list; `List[AttesterSlashing, 1]` (BeaconBlockBody.attester_slashings) and
`List[ConsolidationRequest, 2]` (ExecutionRequests.consolidations) have only `cache_app_*` / `cache_limit` / `cache_take_0`, which all
start from `X_cache(X_default())`. A fault that only matters when the list is non-empty at cache time survives:

| id | fault | public counter-example (probe p12a) |
|---|---|---|
| d01/02 | `l1_AttesterSlashing_cache`: dirty window starts at leaf 1 | `l1_AttesterSlashing_append(default, AttesterSlashing_default())`, `_cache`, `_cached_root` = 3411617860,... ; `hash_tree_root` of the same list = 3102059698,... |
| d01/03 | `l2_ConsolidationRequest_cache`: same | `[d, d]`: cached 2493962254,... vs 23566629,... |
| d02/03 | `l2_ConsolidationRequest_cache`: depth of an empty list | `[d, d]`: cached 2807177708,... vs 23566629,... |

Spec: `hash_tree_root(List[T, N]) = mix_in_length(merkleize(roots, limit=N), len)`; the cached root must equal it for any list the API
holds, including one decoded from bytes (the list field of `BeaconBlockBody_decode` / `ExecutionRequests_decode`) and then cached. What
would close it: the `cache_set_0`-shape law (cache of a non-empty list, then cached_root = plain root) for these two kinds.

**Gap-unreachable through the API (8, contract gap): X_serialize's use of the checked writer is not pinned.** `r12-c02` (all 8 of
CompatibleUnionBC, CompatibleUnionABCA, ProgressiveTestStruct, ProgressiveVarTestStruct, ProgressiveComplexTestStruct,
ProgressiveBitsStruct, ProgressiveSingleListContainerTestStruct, proglist_uint64): `X_senc_go` calls `X_putn` (no validity) instead of
`X_putk`, and every facade checks. The facades state `X_valid(bad) = False` (`_serialize_vreject_*`) and that `ser_done` refuses a poisoned
writer length (`_serialize_vrefuse_*`, which is why c01 dies), but no law states that `X_serialize` of an invalid value returns
`ok = False` end to end. The invalid values the facade exhibits (`O.Words{Array.new(U32, 0n, 0), 5}`: a length with no storage) are
hand-built records that no public setter, append or decoder produces, so through public calls only every value is valid and putn
writes what putk writes: not reachable, but docs/API_CONTRACTS.md promises the refusal for hand-built values, and this is the one link
of it no law covers. What would close it: one `X_serialize_vreject_e2e` law per type (`X_serialize(bad).ok = False` for the facade's
existing invalid witness).

## R12.3 Unjudged (7) and not critical

* `e03/01..04` (BitsStruct / ProgressiveBitsStruct: a bit vector's padding checked at the neighbouring byte): the decode facades overflow
  the checker stack on the mutant (twice, pinned settings; the unmutated facades check) and the `first_offset` laws check. **The corpus
  kills all four** (17 / 10 / 239 / 39 disagreements, valid inputs rejected and invalid ones accepted): corpus-gap-only.
* `e02/01..03` (List[Validator] element validity: checks of elements 0..n-2 dropped, stride 120, element 0 unchecked): reached only
  through `BeaconState_decode`; the BeaconState decode facade and `var_winx_l1099511627776_Validator` overflow the stack; no BeaconState
  corpus case under the size cap. Unjudged; critical-shaped (refusal path for 01 and 03: a state with validators[0].slashed = 2 accepted).
* `d02/02` equivalent in context: List[AttesterSlashing, 1] has length 0 or 1, and cap(0) = cap(1) = depth 0 (probe: same line).
* `b02/01` was designed as equivalent (8 len - 8 + high bit = 8 (len - 1) + high bit in U32) yet `rd_go` killed it: the law's statement
  is syntactic in the bit-count expression; not a finding.

## R12.4 Method notes

* Pass 1: `r12/run12.py` (round 11's runner) with `--k 1 --direct 0 --fac 1` for families a, b, c, e (`p1a.sh`) and `--fac 0 --k 2` for
  the cache families with the patch's `proofs:` header listing the kind's `cache_*` laws (`p1d.sh`); 120 s, stack retry once at the
  pinned settings. Leaf faults name the leaf's own facade and the two smallest containing-container facades.
* Probe: `r12/probes/p12a.bend` (generated by `r12/mkprobe12.py`) with `r3/apiprobe3.py` (`pr.sh`); corpus: `r9/corpus9.py` with
  `sizelimit-rt/kit/cases_corpus.jsonl` (`c1.sh`).
* Machine-readable: `r12/manual_round_12_survivors.json` (12 survivors and 7 unjudged).
