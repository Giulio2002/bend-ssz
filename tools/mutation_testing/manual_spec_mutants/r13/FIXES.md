# Manual spec mutations, round 13: fixes (fixer J)

Input: branch `agent/manual-spec-mutations-r13` at 228e0949e (gate.git), report `docs/mutation_testing/MANUAL_SPEC_MUTATIONS_R13.md` and
`r13/manual_round_13_survivors.json` there. Base: origin/main bca747d41. Only generated laws were added (three generators changed, every
law by computation or one rewrite); no runtime, spec, schema, END_TO_END / ROOT_DOMAIN / PROOF / HASH_PROOF or frozen-lock change.

## F1. `O.copy_in` at unaligned offsets (s01-copy/09, /10: corpus-only before)

`proofs/obj/vcopy.bend` proves `copy_in` for a word-aligned range only, so the dispatch `ci_pick(off & 3)` was pinned by no completing proof.

* **`unaligned_read_laws`** writes `proofs/obj/vua_ci{0,1,2,3}_generated.bend`: `O.copy_in` on a literal buffer of 32 marked bytes (none
  zero, every neighbour different) at the offsets s and 4 + s (s = off & 3 = 0, 1, 2, 3) and every length 1 to 9. Each law `ci_o<off>_n<n>`
  states the copy's length and its first four words: the source bytes [off, off + n) shifted to byte 0, the rest of the last word and the
  words after it zero (the mask). 72 laws, 4 files, about 1.5 s each.
* **`decode_literal_laws`**: `<X>_decode_vlit_rt_ua<s>_<f>` for every variable-size container X and every variable field f that the
  decoder copies (a byte list, a list of fixed elements any bytes of which are valid, a bit list, or one level down a list / container
  holding one): a literal whose field f holds about 9 marked bytes starting at a byte offset s mod 4 (s = 1, 2, 3; an earlier variable
  field padded by 1 to 3 bytes or elements to shift it, every other variable part the default's) decodes and serializes back to the same
  size and words. The decode facade itself pins the shift. 59 laws (one file each, 1 to 6 s) over the 7 containers where a variable field
  can start unaligned: ExecutionPayload (transactions, withdrawals at s = 1, 2, 3), ComplexTestStruct (B, D, E, G), VarTestStruct (B at
  7), ProgressiveBitsStruct, ProgressiveComplexTestStruct, ProgressiveTestStruct, ProgressiveVarTestStruct. Every other Fulu container
  (BeaconBlockBody, DataColumnSidecar, LightClientUpdate, ...) has only fixed parts and variable elements of whole words before each
  variable field, so no field there can start unaligned (BeaconState's 2.7 MB default exceeds the literal cap; its byte copies are the
  same `copy_in`, pinned by vua_ci).

## F2. Full lists in decode: the count-at-limit law (r2-random-api/16, /17)

**`decode_literal_laws`** (`count_at_laws`) writes `<runtime>_<X>_decode_literal_count_at_generated.bend` for every name X whose own
definitions validate a list p (`p_ok`), symbolic in the buffer and the position (no list bytes are built):

| list kind | `_count_at_<p>` (accepted) | `_count_over_<p>` (refused) |
|---|---|---|
| fixed elements of S bytes | `p_ok(buf, off, N * S) == (buf, True)` | `p_ok(buf, off, (N + 1) * S) == (buf, False)` |
| byte list | length N | length N + 1 |
| bit list | last byte the delimiter of exactly N bits (premise on `B.byte_at`) | of N + 1 bits |
| variable elements | `p_head(len, off, (buf, 4N))` is the accepting branch `p_first(True, ..)` whenever 4N <= len | (N + 1 is `_bad_count_<p>`, round 7) |

35 files, 56 `count_at` and 53 `count_over` laws over 51 lists. BeaconState: historical_roots, eth1_data_votes, historical_summaries,
pending_partial_withdrawals and pending_consolidations (`p_ok(buf, off, 4194304)`, i.e. 262144 elements, accepted; 262145 refused).
BeaconState lists with no law: validators, balances, the participation lists and inactivity_scores (limit 2^40: the generated check has no
count test, NMAX bounds them) and pending_deposits (134217728 * 192 bytes > 2^32: the count test can never fail on a U32 length). The
largest bit list (Attestation's 131072 bits) checks in 2 s, also at a quarter of the pinned stack budget. Every file checks in under 2 s.

## F3. Progressive append bounds for every kind (p01/03, /04, and /06, /07)

**`append_guard_bounds`**:
* the element default is found by type when it is not `<T>_default` (Uint128 `u128_default`, Uint256 `u256_default`, the inner list's
  `pl_VarTestStruct_default`): proglist_uint128 and proglist_uint256 get `_appb_below / _at / _fit / _short` (uint128 also `_above`);
* a refused count is stated when only (n + 1) * U wraps (`proglist_uint256 _appb_at`, n = 134217727, the case p01/04 plants);
* a collection that is only an element of another one (proglist_VarTestStruct inside proglist_proglist_VarTestStruct) is filed under the
  owners of the collection that holds it;
* a list of composites whose bound is 2^32 - 1 gets `_appb_at_sz` / `_appb_below_sz`: the guard step `p_app_sz(n, v, (storage, G))` at
  n = G refused and n = G - 1 accepted (no array of 2^32 slots exists, so `p_append` cannot reach the bound).
Side effect of the default lookup: three lists of byte vectors gained their append-bound laws too (BeaconBlockBody and DataColumnSidecar
`l4096_b48`, BeaconState `l16777216_b32`). New / changed: 11 files (9 new), each under 1.1 s. Every progressive list kind now has an
append-bound law: uint8, 16, 32, 64, 128, 256, bool, SmallTestStruct, VarTestStruct, proglist_VarTestStruct, ProgressiveVarTestStruct
and the progressive bit list.

## Replay (pinned checker, 16384 KB stack, mutant applied to the regenerated tree)

| fault | before | killing law (file) |
|---|---|---|
| r13-s01-copy/09 (s = 2 copied with the 1-byte shift) | corpus only (facades unjudged) | `ci_o2_n*` (`proofs/obj/vua_ci2_generated.bend`), `ComplexTestStruct_decode_vlit_rt_ua3_f_E`, `_rt_ua3_f_G`, `ExecutionPayload_decode_vlit_rt_ua2_transactions` |
| r13-s01-copy/10 (s = 3 copied with the 2-byte shift) | corpus only | `ci_o3_n*` (`vua_ci3`), `VarTestStruct_decode_vlit_rt_ua3_f_B`, `ComplexTestStruct_decode_vlit_rt_ua1_f_D / ua1_f_E / ua1_f_G / ua2_f_E / ua3_f_B / ua3_f_D / ua3_f_G`, `ExecutionPayload_decode_vlit_rt_ua3_transactions` |
| r13-r2-random-api/16 (HistoricalSummary list of 2^24 refused) | unjudged | `BeaconState_decode_vlit_count_at_l16777216_HistoricalSummary` |
| r13-r2-random-api/17 (262144 pending consolidations refused) | unjudged | `BeaconState_decode_vlit_count_at_l262144_PendingConsolidation` |
| r13-p01-prog-bound/01 (uint16) | killed | `proglist_uint16_serialize_vcoll_pl_u16_appb_at` (unchanged) |
| r13-p01-prog-bound/02 (uint64) | killed | `proglist_uint64 / ProgressiveTestStruct / ProgressiveComplexTestStruct ..._pl_u64_appb_at` (unchanged) |
| r13-p01-prog-bound/03 (uint128) | survived | `proglist_uint128_serialize_vcoll_pl_u128_appb_at` |
| r13-p01-prog-bound/04 (uint256) | survived | `proglist_uint256_serialize_vcoll_pl_u256_appb_at` |
| r13-p01-prog-bound/05 (uint8) | killed | `proglist_uint8 / ProgressiveTestStruct ..._pl_u8_appb_at` (unchanged) |
| r13-p01-prog-bound/06 (proglist_VarTestStruct, 2^32 - 1) | survived | `ProgressiveTestStruct / ProgressiveComplexTestStruct _serialize_vcoll_pl_VarTestStruct_appb_at_sz` |
| r13-p01-prog-bound/07 (proglist_proglist_VarTestStruct) | survived | `ProgressiveTestStruct / ProgressiveComplexTestStruct _serialize_vcoll_pl_pl_VarTestStruct_appb_at_sz` |

Every killing file fails in under 6 s by a statement mismatch (no stack overflow). The r2/16, /17 patches carry a hunk header one line
longer than the file has at its end; they were applied with `patch -p1`.

## Checks

All on the ssz server, tree `agents/fixJ-r13/tree` (a fresh clone of gate.git at bca747d41 plus this change), nice 19, at most 8 jobs.

* Regeneration: `codegen/regenerate_all.py -j 8` (all passes) then `tools/test_codegen.sh 8`: 53 unit tests OK; ruff is not installed on
  the server (lint skipped); `regenerate_all --check`: **148/149 generators up to date**. The one stale generator is
  `documentation_figures`, which fails only because `docs/` was deleted on main (`FileNotFoundError: docs/RESULTS.md`); docs/ was not
  recreated. The regeneration also refreshed the coverage gate (`proofs/gate/slop/validity/*`, the api facades, `proofs/gate/api_map.json`).
* Cold full check: `CHECK_CACHE=0 tools/check_fast.sh --jobs 8 --no-cache`: **all files check**, 96 umbrellas (14942 files, 0 reused
  from the cache) in 1436 s; slowest umbrella 382 s. The stamp (for the pre-squash commit 034621f7, same sources) was kept out of the
  commit (`agents/fixJ-r13/full1_stamp.json` on the server).
* `tools/crash_hunt/regress.sh`: all cases pass.
* `tools/verify_frozen.py`: 36 planted changes ok; 42 files, 4 statement roots, 1915 statement_defs files match.
* New files: the slowest is 6 s (single-file `tools/check.sh`), all far under 2 minutes; no closed term over a large Nat literal.
