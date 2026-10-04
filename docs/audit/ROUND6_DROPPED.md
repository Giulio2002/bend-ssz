# Round 6 audit: was anything dropped in the last day of commits?

Range: `26ad79b4a` (Sat 2026-10-03 09:43) .. `origin/main` `8bd2fc3e1` (50 commits), plus `origin/agent/crash-fix6` `312db971c`
(32 commits on top of main). `agent/slop-laws-r5` is **not on origin** (`git ls-remote` lists only `crash-fix5` and `crash-fix6`), so it
was not audited. This was a read-only audit. Nothing was fixed, and no frozen file was touched.

**Short answer.** No law, theorem, end-to-end statement, generated module, generator, strictcheck item, gate rule or unit test was
deleted or disabled in the range. All 4,214 statement texts that changed trace to a documented change: the decode window, the size limit,
or crash-fix5/6. What was lost or weakened is smaller:

* one proof-coverage gap that is documented but never surfaced in the user-facing docs;
* one regression case dropped without a reason;
* runtime evidence and mutant patches that were not refreshed;
* a set of doc drifts.

## Findings (sorted by severity)

| # | severity | what was lost / weakened | commit | documented? intended? | restore |
|---|---|---|---|---|---|
| F1 | **coverage of public behaviour** (documented gap) | The runtime now accepts and decodes objects of 2^31..NMAX bytes, but the composed DECODE theorems of the progressive types still carry the old bounds. `ProgressiveTestStruct_e2e_decode_{encode,root}` keep `h31: 1 + n < 2^31`; `ProgressiveComplexTestStruct` keeps its 2^31 / 2^29 premises; `ProgressiveVarTestStruct` and `ProgressiveSingleListContainerTestStruct` keep `h31: n < 2^29` (a pre-existing premise whose gap grew with the runtime domain). The decode window facts of the progressive record-list families (`pl_SmallTestStruct`, `l10_*`, `pl_VarTestStruct`, `pl_pl_VarTestStruct`, `pl_ProgressiveVarTestStruct`) stay at `len < 2^31` and depth < 30. Decode of these types between 2^31 (2^29) and NMAX bytes is covered by execution only. | `30a79a922`, `28b4d95a2` | Partly. `docs/size_limit_statement_diff.md` §4 names ProgressiveTestStruct and ProgressiveComplexTestStruct only. The two 2^29 types are not named. `docs/TRUST.md` and `docs/API_CONTRACTS.md` say nothing about the gap, and `docs/PREMISES.md` still describes the whole tree at 2^31 (F8). Intended as a deferral. | Lift the progressive decode window facts to NMAX: the depth-30 tree lemmas `CC29`, `PDW` and `wd_min` named in §4, in `codegen/proofs/var/deep_tree_list_children.py` and `codegen/proofs/decoded/progressive_variable_list_decoded_facts.py`, then restate the four `*_e2e_comp` decode premises at `<= NMAX`. Until then, list the four types and their bounds in TRUST.md / API_CONTRACTS.md. |
| F2 | **lost test** | Regress case 58 (`pd_encode_22369622_len=0`: the unchecked `_encode` of a PendingDeposit list one element past NMAX/192 returns the empty buffer, CH-02 `out_donem`) was deleted together with its probe function. 3ac5a98d8 then reused the number 58 for `copy_words_4294967292`, so the net diff of `regress_expected.txt` hides the drop. I found no law that states `X_encode` of a poisoned size returns `B.empty()`: `out_donep`/`out_donem` appear in no statement except on the valid branch. The `writer_poison_laws` pin `X_senc_out` (the serialize path), not `_encode`. What remains is regress case 49 (`proglist_uint8`, a packed list). The unchecked encode of an over-NMAX **fixed-composite** list is now checked by nothing. | `c9214f106` | No. The commit message says only "drop regress case 58". Probably memory or time (28b4d95a2 doubled the regress heap), but that is unconfirmed. | Re-add it as case 72 (`pd_encode_22369622_len=0`), or add a by-computation law `X_encode(o with poisoned size) == (o, B.empty())` per writer kind to `codegen/proofs/slop/writer_poison_laws.py`. |
| F3 | **weakened evidence** | All 10 runtime evidence stamps in `benchmarks/evidence/*.json` (conformance, fuzz, invalid objects, object mutations, cache, runtime tests, mutation testing) are still at `42a429cd` (2026-10-02), from before the range. `benchmarks/checks/provenance.py` exits 1 at origin/main because 452 hashed `types/`/`src/` files changed. So the decode window, the size limit and crash-fix5/6 never went through the oracle-based runtime harnesses. `docs/RESULTS.md` names 42a429cd honestly, but no gate requires the stamps to be current. | the whole range | Not called out | Run `tools/run_evidence.sh` on the server at the tree after crash-fix6 lands, and commit the stamps. |
| F4 | **weakened check** | 55 of the 1,054 manual spec-mutant patches no longer apply at origin/main (61 at crash-fix6), after 873dc8633 had re-derived 63 so that all applied. The largest groups are r2-d01-decode-checked (14), r2-s05-poison (5), r3-l01 (5) and r3-d01 (4). crash-fix6 adds r2-a01-bytelist-append-grow/01,/02, r2-a01-bytelist-append-guard/05, r2-a03-bits-append/04,/05 and r2-s03-element-access/16. On a re-run they become ERROR, so the earlier kills of those faults are not evidence for the current tree. No patch was deleted, and no survivor list shrank by deletion. | `39dfc8ed2`..`3ac5a98d8`, `312db971c` | No | `tools/mutation_testing/manual_spec_mutants/rederive.py` on the post-crash-fix6 tree, then extend `rederived_patch_ids.txt`. |
| F5 | **gate (process)** | crash-fix6 carries main's stamp (`benchmarks/evidence/check_fast.json`, tested commit 3ac5a98d8). `check_stamp.py verify` fails on it: the frozen lock hash changes from e1bc4660 to ccdf9c1e and the sources change. It changes 10 frozen statements and `src/obj.bend`. | `312db971c` | n/a | A cold `check_fast.sh --no-cache` full check, with localization, plus strictcheck on the crash-fix6 tree before merging. Here, strictcheck (149/149) and verify_frozen pass on it; the proof check was not run. |
| F6 | weakened law (low) | `decode_checked_2gib_refused` (`proofs/slop/crash/crash_fix_laws_generated.bend:66`) has an unchanged statement but no longer pins a size cap. It holds only because the one-word storage cannot hold 2^31 bytes (the storage test). The NMAX cap is pinned elsewhere, by `*_decode_vchecked_nmax_above/_limit` (ed754d7b1). The name and the CH-05 row that cites it are now misleading. | `28b4d95a2` (meaning changed) | No | Rename it, or restate it at a storage-sufficient buffer of 4294967265 bytes (or drop it in favour of `_vchecked_limit`), and update the CH-05 row. |
| F7 | undocumented widening (low) | The append guard of `pl_SmallTestStruct` went from `n < 536870911` to `n < 1073741816` (`types/proglist_SmallTestStruct_def_generated.bend:133`). The arithmetic is right (floor(NMAX/4)), but `size_limit_statement_diff.md` §2 lists only the three Fulu lists, and `docs/CRASH_HUNT.md:449` still says 536,870,911. | `c1046db54` / `28b4d95a2` | No | Add it to the size-limit diff doc; fix the CRASH_HUNT row. |
| F8 | doc drift (medium) | `docs/PREMISES.md` was untouched in the range and still describes the 2^31 regime. Line 97 says "poisoned past 2^31"; 259-261 give the container encode limit as 2^31 - 1 and OKT at 2^31 - 1; 277 and 282 put `hZ` / `hm<j>` below 2^31; 284-286 have `h31: n < 2^31`; 295 has TOT below 2^31. The code states all of these at NMAX (for example `e2e/FuluBeaconState_e2e_comp`, `h31: n <= NMAX`). | the size-limit series | No | Rewrite §2/§3 at NMAX, keeping only the F1 exceptions, with a pointer to `size_limit_statement_diff.md` §4. |
| F9 | doc drift (low) | `docs/CRASH_HUNT.md`. Line 21 (the CH-05 row) still says `_decode_checked` "refuses a window of 2^31 bytes or more" and that "`_decode` itself is unchanged", both false since the size limit and the decode window. Line 449 (R3-03) still reads PARTIAL with the 2^31 counts, while CH-07 and 28b4d95a2 say R3-03 is closed. Older sections (172-178, 317, 384-400, 482-488) have no "superseded" marker. `docs/API_CONTRACTS.md:20` lists `X_get` generically for the boxed kinds that only have `_take` (cosmetic; crash-fix6 updates the file). | size-limit and decode-window series | No | Update the rows and mark the superseded sections. |
| F10 | doc error (low) | `docs/size_limit_statement_diff.md` (intro) says the change `x < 2^31` to `x <= NMAX` is "stronger as a conclusion". It is **weaker** as a conclusion, since NMAX is about 2^32. 246 lemma conclusions changed this way. All are internal lemmas except the two non-vacuity witnesses `FuluBeaconState_e2e_witness_size` / `_size_nonempty`, whose conclusion only has to meet the (lifted) premise. No public law is weakened by it, but the stated justification is wrong. | `28b4d95a2` | Wrong claim | Correct the sentence: weaker premise = stronger theorem; weaker lemma conclusion = acceptable only because every consumer checks. |
| F11 | stale probe (low, pre-range) | `tools/mutation_testing/manual_spec_mutants/r3/probes/p3_cache.bend:78-79` calls `LP.l16_ProposerSlashing_cget`, which crash-fix4 (666ae43eb, before the range) renamed to `_ctake`. It is the only stale caller of a renamed entry. | e67546033 | No | Rename the call to `_ctake`. |
| F12 | doc loss (low) | `docs/mutation_testing/MUTATION_PROOFS.md` lost its section "Manual spec-mutation audit, round 3" (about 25 rows of which law kills which fault, plus the Equivalent / Limitations paragraph) when it was replaced by the "second branch" section. The laws themselves are intact (their counts are equal or higher). | `c78765bb0` | No | Restore the section from 26ad79b4a. |

Open question, not a regression of the range: crash-fix6's `O.app_old` clears the rest of a word only when the appended element starts it
(s == 0), and `app_old31` only at bit 31. Dirty bytes or bits after a new last element at s > 0 stay. Whether that matters depends on the
CH-11 rule for partial last words. Ask the crash-fix6 author.

## What was checked and found intact

* **Law and theorem names.** I extracted every top-level `law` block and every `def` signature from all `.bend` files of the three trees (old
  10,471 files / 138,013 items; main 12,019 / 150,718; crash-fix6 12,022 / 150,818):
  * **Lost:** 0 `law` blocks. 39 `def`s were lost, all internal 2^31 helper lemmas:
    * the 12 strict `*D` size lemmas (`bsucD`, `lsucD`, `t31D`, `t31sD`, `mul4kD`, `sza_valD`, `szwb_valD`, `szlD`, `szsb_valD`, `szsD`, `ok_bq`, `hk30q`) in each of `encx_pl_VarTestStruct_d`, `encx_pl_pl_VarTestStruct_d` and `encx_pl_ProgressiveVarTestStruct_d`;
    * `fitsBa` in `vbsize.bend` and `vconts.bend`;
    * `lt32Ba` in `vconts.bend`.
  * These are documented ("the strict *D copies of the size lemmas are gone", size_limit diff §4), and they are what the drop of `deep_tree_list_children`'s def count (764 to 729) shows.
  * **Nothing lost:** main to crash-fix6 lost nothing, and no file lost a `law` block.
* **End-to-end statements.** `e2e/STATEMENTS.txt` has 5,240 statements in 1,334 files and the same 5,827 statement / helper names in all three trees.
* **Frozen files.** END_TO_END / ROOT_DOMAIN / PROOF / HASH_PROOF, `spec/`, `schemas/`, `law-statements.json`, `fulu_model.bend` and `generic_specs` are byte-unchanged. `frozen.lock.json` changed twice:
  * **Size limit (28b4d95a2):** 23 statement_defs files. Each one is named in `size_limit_statement_diff.md`.
  * **crash-fix6:** `coll_bytes`, `coll_bits`, `bits_view`, `src/obj.bend` and the 3 Fulu byte-list def files, as `crash_fix6_statement_diff.md` says. Its 12 changed signatures are exactly the 10 `read_append(_grow)` laws plus `view_app` / `view_app_u8`, with premises identical and only the storage term of the conclusion changed (`O.app_old`, `BV2.close_t`).
  * **Verification:** `tools/verify_frozen.py` passes (36 planted changes, 42 files, 4 roots, 1,915 statement_defs) on the server at both tips.
* **Changed statement texts.** 4,214 signatures changed from old to main. After normalising the documented rewrites, 3,877 compare equal:
  * the renumbered import aliases `P<n>_`;
  * `Nat.is_lt(x, pw(31n))` to `Nat.is_le(x, NMAX)`;
  * `U32.mul` to `O.mulc`;
  * marker 2147483648 to 4294967295, and 2147483647 to 4294967264;
  * the witness seeds `2271xxxxxx`;
  * the added `hwin`/`hS` premises.

  I classified the remaining 337 by hand. All of them fall into documented categories:
  * `hwin` on exactly 240 `_decode_build` + 42 `_decode_fields` in each of slop, gate and facade (282 x 3), and nowhere else;
  * `hS: N <= NMAX` on the 4 `encode_eval` of `proglist_uint{32,64,128,256}`, in obj, gate and api;
  * `hs31`/`hN` (`LL <= NMAX`) on 14 `szx_*W` and 14 `szxB_*`, where the old `szxB` premise `LL < 2^32` is narrowed to NMAX because `O.mulc` refuses above it (internal);
  * `_valid` to `_valid_f` in `validC`/`rvalidC`;
  * proglist `vsym` at `words_ok(.., 4294967264, False)`;
  * the union `a31` lemmas restated as `is_poisoned == False`;
  * depth `29n` to `30n`;
  * the append-guard literals of the 3 Fulu lists;
  * the dchw `size <= NMAX` conjunct.

  No conclusion became a disjunction, and none of the public statements gained a hypothesis other than `hwin` (decode window) and `hS`.
* **Generators.**
  * **Registry:** 142 generators at old, 146 at main and crash-fix6. None was removed; the 4 added are `decode_window_laws`, `decode_checked_laws`, `append_guard_bounds` and `writer_poison_laws`.
  * **Outputs:** I counted output files and laws/defs per `GENERATED by` header, reading the whole header. The only generator whose def count fell is `deep_tree_list_children` (the documented `*D` lemmas above). Totals:

    | tree | files | laws | defs |
    |---|---|---|---|
    | old | 9,694 | 3,018 | 110,074 |
    | main | 11,229 | 3,134 | 121,777 |
    | crash-fix6 | 11,231 | 3,134 | 121,806 |

  * **Deletions:** none. `git diff --name-status` shows 0 deleted and 0 renamed files in the range: 1,799 added and 2,507 modified at main, 15 added and 27 modified in crash-fix6.
  * **Gate regex:** the coverage gate's `validators()` regex was moved to `_decode_in`, and it still finds 240 of 240 decoders in all three trees.
* **Coverage gate.**
  * **Entries:** `proofs/gate/api_map.json` went from 7,320 to 10,102 entries over 240 names. 0 (name, kind, law) entries were dropped and no cell was emptied.
  * **MISSING:** `MISSING.txt` reads 0 of 2,160 in every tree.
  * **SHAPE widening:** SHAPE now also accepts `senc_go`/`senc_sized`/`senc_out` conclusions for serialize_valid. That only adds entries, and every cell keeps its old proving laws.
* **Checks and gates.**
  * **Harness unchanged:** `tools/check_fast.sh`, `strictcheck.sh`, `verify_frozen.py`, `umbrellas.py`, `umb_pool.py`, `summary_rows.py`, `umbrella_cache.py`, `check_stamp.py` and `check.sh` are byte-identical across the range. The umbrella planner change (8d8a94d80), summary_rows (093c73f80) and the umbrella cache (8cc384e4f) all landed before 26ad79b4a.
  * **No new exceptions:** no new skip, exception or allow list appeared in a gate. The only new allow list is the 3 legitimate 2^31 literals in the new `test_no_stale_marker.py`.
  * **Strictcheck:** run on the server, 145 checks at old and 149 at main and crash-fix6, all passed. The +4 are exactly the 4 new generators, and none was removed. I could not find the source of the "139" figure; the old tree gives 145.
  * **Full-check stamps:**

    | stamp | files | umbrellas | roots | reused |
    |---|---|---|---|---|
    | old | 10,065 | 84 | 4,199 | 0 |
    | main (tested commit 3ac5a98d8) | 11,609 | 88 | 4,860 | 0 |

    11,609 is every `.bend` file outside `tools/` and `vendor/`, and the planner asserts closure coverage. Every stamp in the range reused 0 umbrellas from the cache. The only FAILED stamp in the range (c1046db54, a WIP of the size limit) is superseded by passing stamps.
* **Runtime API.**
  * **Nothing removed:** no def in `src/`, `types/`, `benchmarks/`, `native_bench/`, `memory_bench/`, `tools/` or `tests/` disappeared.
  * **Renames:** the `_take`/`_ctake` rename predates the range (crash-fix4, 666ae43eb). In the range, `X_valid` and `X_decode` were kept, with `X_valid_f`/`X_vsz` and `X_decode_in`/`X_dwgo`/`X_dwin` added beside them.
  * **Acceptance widenings:** only the intended ones (objects up to NMAX, `decode_checked` at `<= 4294967264`, the append guards) plus F7.
  * **Narrowing elsewhere:** packed `_valid` is now bounded at NMAX, plus `mulc`/`mul4c`, the union `padd`, `_decode` refusing an outside window, and `_encode` of an invalid value now returning `B.empty`.
  * **crash-fix6** widens nothing.
* **Tests and corpora.**
  * **Regress cases:** cases 1-39 are unchanged, and cases were only appended (40-71), except F2.
  * **Unit tests:** none was deleted or skipped. `test_append_guards.py` moved its bound to NMAX and still matches 17/17 and 20/20 files.
  * **Mutation exclusions:** `tests_generated/mutation_exclusions.json` is unchanged.
  * **Oversized-hex skip:** the 22 oversized-hex cases are skipped only in the new A/B kit (`tools/spec_audit/size_limit_rt/rt_corpus.py --max-hex 400000`, added in 7610f14a8). The main corpus runner `run_bend.py` has no size skip and no corpus case was removed.

## Method

* **Trees:** `git archive` of `26ad79b4a`, `origin/main` and `origin/agent/crash-fix6`, extracted on the Mac (reading only) and on the server under
  `/srv/ssz-optimization/agents/audit-r6/{old,main,cf6}`.
* **Extraction:** every `law NAME:` block and every `def NAME` header up to its depth-0 `:`, over all `.bend` files outside vendor/build. Then:
  * a name diff per file;
  * a signature diff per (file, name): params diffed as a list and the result separately;
  * normalisation of the documented rewrites, then the residue reviewed by hand.
* **Generator counts:** files per `GENERATED by <gen>` header, with the `law`/`def` counts of those files.
* **Server runs** (nice 19, at most 2 jobs): `tools/verify_frozen.py` and `tools/strictcheck.sh` at old (strictcheck only), main and crash-fix6.
  No proof check was run: the stamp covers main, and crash-fix6 still needs its own (F5).
* **Machine-readable findings:** `docs/audit/round6_dropped.json`.
