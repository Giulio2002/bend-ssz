# Round 11 (agent/manual-spec-mutations-r11) and the round 11 fixes (agent/r11-fixes, which also close round 12, see ../r12/REPORT.md)

## R11.0 Proof-gap list recomputed (round 11, agent/manual-spec-mutations-r11)

Round 9 and 10 sections live on their own branches (b0cf210c9, 93459f12b); this section continues from them. `r10/unmentioned10.py`
on fixer G's tree (agent/access-laws 19cc482d5): 4,672 API-shaped definitions in types/, **539** named by no proof file
(`r11/unmentioned.json`). By suffix: get 240, set 131, read 117, ok 30, valid 21. The get / set names left are the inner helpers
`*_get_n`, `*_get_in`, `*_set_n` behind the public `X_get` / `X_set`, which G's element and field laws name (G's family); `_uncache`,
`_append` and `BeaconState_serialize` are now named. Left for this round: the `_read` readers (117), the `_ok` / `_bx_ok`
validators (30), the per-group `_gK_valid` predicates (21) and `croot_read`; H's families (X_default, offset order, BeaconState windows)
were not touched. Every check ran on a private hard-linked tree of agent/access-laws 19cc482d5, so G's laws count.

## R11.1 Result

| | count |
|---|---|
| New faults | **177** (133 from 12 generated patterns instantiated on every unmentioned function with the shape, 33 of them a 1-in-6 sample of 202 budget-wrapper instances; 44 from 11 hand-designed patterns on the cached lists, progressive lists and the same-type union options; 2 more were dropped as duplicates of earlier rounds) |
| (A) killed by a named law | **115** (114 in pass 1: the facade of the mutated operation first, then the 2 cheapest sym-mentioning laws, 1 direct importer; 1 in pass 2: the facade of the containing type) |
| (A) survived every checked root | **50** (6 critical, 1 gap-unreachable, 43 equivalent: 21 dead code, 17 equivalent in context, 5 equivalent) |
| (A) UNJUDGED (checker stack overflow twice at the pinned settings, or a 120 s timeout; never counted as a kill) | **12** (the same roots check the unmutated tree in 39 to 100 s: `r11/ctl.py`) |
| (B) corpus on the unjudged | 10 of 12 run: **9 KILLED** (a01/09-12, b03/01, b03/10, b03/11, b03/12, f01/02), 1 SURVIVED (b03/09: needs a transaction over 2^30 bytes) |
| (B) corpus, proof-killed sample | 14 run: 4 KILLED, 10 SURVIVED (cannot observe: budget wrappers, X_valid refusals and append are not on the corpus path; a Bytes1 / top-level reader at offset 0) |
| Probe p11a (public calls only) | 15 faults: 8 print a different line (d02/03, /05, /06, d03/03 control, d03/04, d03/05, d04/03, f01/02); the expected equivalents (d06, d07, d05/04, d02/04) print the same lines |

Per family (A killed / survived / unjudged):

| family | fault | n | K / S / U |
|---|---|---|---|
| r11-a01-reader-base | container `_read`: a field read at its in-container offset without the container's own `off` | 22 | 5 / 13 / 4 |
| r11-a02-word-readback | multi-word scalar reader: the last word read at the previous word's offset | 4 | 4 / 0 / 0 |
| r11-a03-tail-keep | bit vector / Bytes1 reader: the partial last word not masked | 11 | 11 / 0 / 0 |
| r11-a04-vector-count | basic vector reader copies one element short | 14 | 14 / 0 / 0 |
| r11-a05-vector-storage | basic vector reader allocates one word short | 5 | 5 / 0 / 0 |
| r11-b01-ok-len | fixed-size `_ok`: a longer window accepted | 15 | 0 / 15 / 0 |
| r11-b02-ok-pad | bit vector padding check one bit loose / on the wrong byte | 4 | 4 / 0 / 0 |
| r11-b03-bx-ok | boxed field validator returns True | 12 | 1 / 6 / 5 |
| r11-c01-group-acc | group validity: the accumulator dropped at the last field | 13 | 9 / 4 / 0 |
| r11-h01-budget-strict | decode_checked_budget: cost == budget refused | 17 | 17 / 0 / 0 |
| r11-h02-budget-unchecked | decode_checked_budget calls X_decode, not X_decode_checked | 16 | 16 / 0 / 0 |
| r11-d01-cache-window | fresh cache marks only leaves 0..n-1 dirty | 7 | 7 / 0 / 0 |
| r11-d02-cache-grow-window | growth by capp marks only leaves 0..n dirty | 6 | 0 / 4 / 2 |
| r11-d03-cset-lo / d04-cset-hi | cset does not widen the dirty window's low / high end | 7 + 3 | 5 / 2 / 0, 2 / 1 / 0 |
| r11-d05-cache-depth | cache depth capacity(n + 1) | 6 | 5 / 1 / 0 |
| r11-d06 / d07 | capp low end; window reset (0, 0) (both designed as equivalent) | 1 + 1 | 0 / 1 / 0 each |
| r11-d08-grow-reuse | growth keeps the old node array | 2 | 2 / 0 / 0 |
| r11-e01-prog-append-len | progressive list append leaves the byte length at n * size | 6 | 6 / 0 / 0 |
| r11-e02-prog-len | len as n >> 3; len rounded up (designed as equivalent) | 2 | 0 / 2 / 0 |
| r11-f01-union-same-type | CompatibleUnionABCA option 4 (same payload type as option 1): root mixes 1, decode builds option 1, payload validity skipped | 3 | 2 / 0 / 1 |

Killing laws: `<Name>_spec_decode` (a02-a05), `okD` (b02), `rdw_go` (a01 on ExecutionPayloadHeader), `ContributionAndProof_spec_decode`
(a01/21, pass 2), `st_d` (b03/04), `<Name>_serialize_vreject_*` (c01), `<Name>_decode_vchecked_budget_refuse` / `_agree` (h01 / h02, every
sampled type), `<Body>_vroot_<list>_cache_app_1 / _app_3 / _set_0 / _set_1_3` (d01, d03, d04, d05, d08), `proglist_<T>_serialize_vcoll_*_api_len`
(e01), `stc_CompatibleUnionABCA_3`, `rt3` (f01). Every kill names a law (no ill-typed mutant).

## R11.2 Findings (critical: reachable through the public API, no law kills them, a probe shows the wrong answer)

**The cached-tree API diverges from hash_tree_root on paths no law exercises (6 critical, 2 more argued).** The public cached-list
API (`X_cache`, `X_capp`, `X_cset`, `X_cached_root`, `X_uncache`) has generated laws per list kind
(`proofs/slop/validity/fulu_<Container>_vroot_<list>_cache_*`), but they stop at three appends and do not cover a set after a root
for two kinds:

| id | fault | public counter-example (probe p11a) |
|---|---|---|
| d02/03 | List[Attestation, 8]: growth marks only leaves 0..n dirty | `l8_Attestation_cache(default)`, `capp` x5, `cached_root` != `hash_tree_root(uncache(c))` (depth 2 -> 3 leaves node 7 = D.zero, not Z(1)) |
| d02/05 | transactions List[ByteList, 2^20]: same | `capp` x5 of [i]: cached root 3416030,... vs 3932456843,... |
| d02/06 | List[ProgressiveSingleFieldContainerTestStruct, 10]: same | `capp` x5: cached root differs |
| d03/04 | List[AttesterSlashing, 1]: cset does not lower the window's low end | `cache([default])`, `cached_root`, `cset(0, slashing with slot 7)`, `cached_root`: the stale root |
| d03/05 | transactions: same | `[01, 02]`, root, `cset(0, [03])`, root: stale |
| d04/03 | transactions: cset does not raise the window's high end | `[01, 02]`, root, `cset(1, [03])`, root: stale |
| d02/01, d02/02 | ProposerSlashing_16, Deposit_16: growth window (same generated code as d02/03) | argued; the body root facade timed out (unjudged), the probe has no case for these lists |

Spec: `hash_tree_root(List[T, N]) = mix_in_length(merkleize(roots, limit=N), len)`; the cached root must equal it after any public
sequence. What would close it: a growth law past depth 2 for every cached kind (five appends from empty, cached root = plain root;
today `cache_app_1` / `cache_app_3` stop at depth 2, where the missing padding parents happen to be leaves), and the `cache_set_0` /
`cache_set_1_3` laws (present for l16 / l8 / l10) for `l1_AttesterSlashing` and the transactions list.

## R11.3 Unjudged (12)

Every root that reaches these faults overflowed the checker stack twice at the pinned settings (or timed out); the unmutated roots
check. Not counted as kills.

* `a01/09..12` (ExecutionPayload readers not rebased on `off`): reached with off != 0 through `BeaconBlockBody_decode` ->
  `ExecutionPayload_bx_read`; **the corpus kills all four** (BeaconBlockBody cases: 43 / 39 / 24 / 40 disagreements).
* `b03/01, /10, /11, /12` (a boxed element's own validity skipped: AttesterSlashing in the body, ProgressiveVarTestStruct,
  VarTestStruct, nested progressive list): refusal path; **the corpus kills all four** (4 / 25 / 85 / 5 invalid cases accepted).
* `b03/09` (transaction element's ByteList[2^30] check skipped): only an input over 2^30 bytes reaches it; corpus cannot build one.
* `f01/02` (CompatibleUnionABCA selector 4 decodes to option 1): **probe and corpus kill it** (`serialize(c3{default})` then
  `decode`: selector 1).
* `d02/01, d02/02`: see R11.2.

## R11.4 Not critical (reasoned, 44)

* **Dead code (21, equivalent in context):** the 15 `b01` faults (`X_ok` of a field kind: bv128, bv64, b256, v17_b32, v33_b32, v65536_b32,
  v8192_b32, v512_b48, v64_u64, v8192_u64, bv1280, bv1281, bv256, bv257, v4_FixedTestStruct) and 6 `b03` faults (DepositData, Deposit,
  ProposerSlashing, SignedBeaconBlockHeader, SyncAggregate, SyncCommitteeContribution `_bx_ok`): grep finds no caller in types/ or src/
  (containers validate these kinds with `X_ok_at`, and the kinds have no public `X_decode`). They are the bulk of the "unmentioned
  `_ok`" list: dead generated helpers, which explains why no proof names them.
* **Top-level readers (13, equivalent in context):** `a01/01-04, 13-20, 22`: `X_read` is called only by `X_decode` / `X_build` of
  its own file at off = 0 (no `X_bx_read` / `X_read` caller elsewhere); the two nested ones were judged on the container's facade
  (a01/21 killed by `ContributionAndProof_spec_decode`; a01/09-12 unjudged above).
* `c01/05` **gap-unreachable**: BeaconState_g2 validity keeps only next_sync_committee's; the other g2 fields can be invalid only
  through a raw value (Bitvector4 with padding bits, Words of the wrong length) no setter writes. No vreject law covers a g2 field
  before the last (the facade has them for g0, g1, g3, g4).
* `c01/08, 09, 10` equivalent (the group validates one field; the accumulator is the literal True).
* `d02/04` (limit 1: growth never runs), `d05/04` (depth clamped by `cache_dok` to the 1-slot storage; probe same line), `d06`
  (lo <= n always), `d07` (rehash of a clean leaf), `e02/01` (shrn 3 = div 8), `e02/02` (byte length always a multiple of 16).

## R11.5 Method notes

* Pass 1 `r11/run11.py` (round 10's runner with the facades first): `--k 2 --direct 1 --fac 2`, 120 s, stack retry once at the pinned
  settings. Pass 2 (`p2_plan.json`): the decode facades of the CONTAINING types for readers / validators reached only when nested
  (`pass2_11.py`'s cone-based choice was too broad: every Fulu facade's cone holds most types).
* Probe: `r11/probes/p11a.bend` with `r3/apiprobe3.py`; corpus: `r9/corpus9.py` with `sizelimit-rt/kit/cases_corpus.jsonl`
  (patch type headers retargeted to the containing type in `pkc/`).
* Budget wrappers: 202 instances generated (one per decoder), 34 sampled (one in six; one BeaconState instance dropped), all killed.
* Machine-readable: `r11/manual_round_11_survivors.json` (50 survivors and 12 unjudged, with reachability,
  counter-example, verdict and evidence: proof roots, probe lines, corpus counts).

## Round 11 fixes (agent/r11-fixes, with round 12's items)

Every gap closed by GENERATED laws (no generated file edited by hand). Base 6dfc82a55, merged with 1eb2fc98e (the README commit of the old
main; the rewritten GitHub main was not merged). Replay: `r11/replay_fix11.py` with `r11/replay_plan.json` (a hard-linked copy of the
regenerated tree per fault, the audit patch applied, the named law files checked at the pinned settings; a kill is a failed check whose
`Location:` is in the law file); results in `r11/results/replay_fix11.{json,log}`; `r11/status11.py` wrote `fix_status` / `fix_law` /
`fix_location` / `fix_note` into `manual_round_11_survivors.json` and `manual_round_12_survivors.json`.

**Law families added** (each new file checks in under 60 s; the slowest, `l16_Deposit` grow_5, in 21 s):

| family | generator | kinds |
|---|---|---|
| `<X>_vroot_<kp>_cache_app_5` (5 appends, one root) and `_grow_k`, k = 1 .. min(5, limit) (a root after every append, from the rooted empty tree) | cached_list_roots | all 18 cached list kinds (app_5 / grow_5 on the 16 with limit >= 5; the limit-1 and limit-2 lists up to their limit) |
| `_cache_set_0` / `_set_<min(4, limit) - 1>` / `_set_1_3` for every kind (the limit-1 list too); the transactions list states the dirty window after the sets | cached_list_roots | 18 |
| `_cache_nonempty_k` (round 12: cache of a list of 1, 2 and 3 elements = plain root) | cached_list_roots | 18 |
| coverage gate (round 8's, extended): app_<min(5,L)>, grow_<min(5,L)>, set_0, set_<min(4,L)-1>, nonempty_1, nonempty_<min(2,L)> per kind | cached_list_roots | 18 |
| `<X>_decode_vlit_fwin_<step>`: each reader step of a container that a parent reads reads its fixed field at off + its schema position (gate: every fixed field) | decode_literal_laws | 39 nested containers, 140 steps |
| `<X>_decode_vlit_bad_box_<f>` + gate: every type in a boxed position (container field, element of a list / vector of variable elements) is refused, inside some parent, when one invalid boxed value sits there | decode_literal_laws | every boxed type; 1 new literal (BeaconBlockBody.execution_requests), the others were already emitted by the round-5 literals (the gate now requires them) |
| `<X>_decode_vlit_ok_sel_<s>` (selector s decodes to the option of s) and `_bad_sel_<s>` (0, 255, the neighbours of the declared selectors) | decode_literal_laws | 3 compatible unions, 7 + 7 laws |
| `<X>_decode_vlit_vwin_<step>` (round 12): a validator step checking a fixed field in place checks it at off + its position | decode_literal_laws | BitsStruct, ProgressiveBitsStruct, BeaconState |
| `<X>_decode_vlit_ck_<p>_step / _end / _first` (round 12): the element loop of fixed checked elements (verdict kept, stride, first element) + gate | decode_literal_laws | 12 loops (List[Validator], 11 bool vectors / lists) |
| `<X>_serialize_vwriter_checked` (round 12): `X_senc_go(False, n, o)` writes with `X_putk` | container_field_validity | 37 names with a checked serializer |

Why the 5-element laws compare with a fresh cache: past depth 2 a plain root spells an empty subtree as its constant `D.zconst(h)` and a
cached tree as `D.node(hl, zero, zero)`: one digest at hl = 64, two terms for the symbolic hl the laws use (at a literal hl the checker runs
SHA-256 for over 5 minutes). The nonempty laws tie a fresh cache to the plain root. The transactions list: a non-empty byte-list element roots
over 2^25 chunks (checker timeout) and a symbolic one leaves the two leaf pipelines stuck at different points, so its set laws state the
dirty window itself.

**Dead code removed** (Giulio's standing call; `git grep -w` over src/, types/, proofs/, e2e/, codegen/, tools/ (the audit patches
excepted) and benchmarks/: no reference but the generated runtime index): typed_object_runtime no longer emits the window validator of a
fixed-size kind that no decoder and no union option takes (WINDOW_OK): `X_ok` and `X_ok_len` of bv64, bv128, bv1280, bv1281, bv256,
bv257, b256, v17_b32, v33_b32, v65536_b32, v8192_b32, v512_b48, v64_u64, v8192_u64, v4_FixedTestStruct (30 definitions: all 15 b01),
nor `X_bx_ok` of a box of a fixed-size value: Deposit, DepositData, ProposerSlashing, SignedBeaconBlockHeader, SyncAggregate,
SyncCommitteeContribution (6 b03). runtime_file_split takes `X_ok_at` as the decode entry of an owner without `X_ok`, so every frozen
def file is byte-identical. No proof referenced them; no frozen statement changed.

**Replay** (every fault killed by name unless stated):

| fault | killing law | s |
|---|---|---|
| r11-d02/01 | BeaconBlockBody_vroot_l16_ProposerSlashing_cache_app_5 | 9.3 |
| r11-d02/02 | BeaconBlockBody_vroot_l16_Deposit_cache_app_5 | 40.0 |
| r11-d02/03 | BeaconBlockBody_vroot_l8_Attestation_cache_app_5 | 5.7 |
| r11-d02/05 | ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_5 | 2.0 |
| r11-d02/06 | ProgressiveComplexTestStruct_vroot_l10_ProgressiveSingleFieldContainerTestStruct_cache_app_5 | 1.9 |
| r11-d03/04 | BeaconBlockBody_vroot_l1_AttesterSlashing_cache_set_0 | 3.2 |
| r11-d03/05 | ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0 | 1.0 |
| r11-d04/03 | ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3 | 1.0 |
| r11-a01/09 | ExecutionPayload_decode_vlit_fwin_g0_rd6 | 0.7 |
| r11-a01/10 | ExecutionPayload_decode_vlit_fwin_g1_rd9 | 0.7 |
| r11-a01/11 | ExecutionPayload_decode_vlit_win_g1_rd4 (round 7's window law; not in the audit's root selection) | 0.7 |
| r11-a01/12 | ExecutionPayload_decode_vlit_fwin_g2_read | 0.7 |
| r11-b03/01 | BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_attestation_1_off_plus | 6.2 |
| r11-b03/10 | ProgressiveComplexTestStruct_decode_vlit_bad_f_H_elem_f_B_ragged_1 | 1.4 |
| r11-b03/11 | ComplexTestStruct_decode_vlit_bad_f_G_e0_f_B_ragged_1 | 1.3 |
| r11-b03/12 | ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off5 | 0.8 |
| r11-f01/02 | CompatibleUnionABCA_decode_vlit_ok_sel_4 | 0.7 |
| r12-d01/02 | BeaconBlockBody_vroot_l1_AttesterSlashing_cache_nonempty_1 | 1.9 |
| r12-d01/03 | ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_1 | 0.9 |
| r12-d02/03 | ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_2 | 1.0 |
| r12-c02/01, /02, /08 | CompatibleUnionBC / CompatibleUnionABCA / proglist_uint64 `_serialize_vwriter_checked` | 0.5 to 0.6 |
| r12-c02/03 .. /07 | none: **equivalent**, `X_putk` is defined as `X_putn` for these five progressive containers (the validity is carried by the field writers), so the mutant is the same function | |
| r12-e03/01 .. /04 | BitsStruct_decode_vlit_vwin_c2, _c1; ProgressiveBitsStruct_decode_vlit_vwin_c7, _c8 | 0.5 to 0.6 |
| r12-e02/01, /02 | BeaconState_decode_vlit_ck_l1099511627776_Validator_step | 0.6 |
| r12-e02/03 | BeaconState_decode_vlit_ck_l1099511627776_Validator_first | 0.5 |

* d02/01 and d02/02 (unjudged on the body facade) are now judged: killed by their kinds' `cache_app_5` in 9 s and 40 s.
* b03/09 (the transaction element's own check): **documented as unreachable in practice**: the only invalid element is a byte list over
  2^30 bytes (a 1 GiB input); no symbolic law is cheap (its root unfolds 2^25 chunks), and the list validator calls `bl1073741824_bx_ok`
  through the same generated template the bad-box laws pin for every other boxed kind. The bad-box gate exempts byte lists for this reason.
* r12 c02 on the other three kinds: the e2e refusal laws that already exist (`_serialize_vrefuse_*`) are refused before the writer runs,
  which is why c02 survived them; `_serialize_vwriter_checked` pins the writer itself for all 37 names with a checked serializer.
* Not done: a decoded-list variant of the nonempty cache laws (a cache of `X_decode`'s list): the decode of the owning container is the cost
  that made the facades unjudged; the nonempty laws cache the same lists the decoder builds.

**Checks** (fresh tree on the server at 71854982b, regenerated with `regenerate_all -j 8`: one pass): cold `CHECK_CACHE=0
tools/check_fast.sh --jobs 8 --no-cache`: all 97 umbrellas pass (0 reused), 1434 s (stamp: `r11/results/check_fast_r11fix.json`);
`tools/crash_hunt/regress.sh`: all cases pass; `tools/verify_frozen.py`: 1915 statement_defs files match; `tools/test_codegen.sh 8`: 53
unit tests OK, 149/149 generators up to date once the check's own evidence file is set back (its new wall time makes documentation_figures
stale; the coordinator's stamp records it); ruff is not installed on the server (lint skipped).
