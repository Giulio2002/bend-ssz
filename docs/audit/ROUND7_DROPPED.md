# Round 7 audit: was anything dropped or weakened from 26ad79b4a to the r6 tip?

Range: `26ad79b4a` (Sat 2026-10-03 09:43) .. `e1b65e26f` (`gate/slop-laws-r6`, 9 commits on top of `origin/main` `0b80524f4`; not yet on
main), plus `agent/decode-amplification` `5c1f48b93` (one commit on `0b80524f4`). The trees compared:

| tag | commit | what |
|---|---|---|
| old | `26ad79b4a` | start of the range |
| b6 | `8bd2fc3e1` | end of the round-6 audit's range |
| main | `0b80524f4` | crash-fix6, round-6 restores (case 72, docs), stamp |
| tip | `e1b65e26f` | slop-laws r5 and r6 |
| da | `5c1f48b93` | decode budget |

This was a read-only audit. Nothing was fixed, and no frozen file was touched. The round-6 audit (`docs/audit/ROUND6_DROPPED.md`) covered old..b6.
I repeated its method over the whole range and looked hardest at what came after b6.

**Short answer.** After b6, the only law deleted is `decode_checked_2gib_refused`. The claim that replaces it holds: `_decode_vchecked_nmax_wrap`
and `_nmax_above` exist for all 240 names, and both pin the NMAX conjunct of `X_dchw` on their own. No other law, def, generated file or
gate rule was lost. These all change only as documented:

* the 10 frozen `read_append` statements of crash-fix6: premises identical, only the storage term of the conclusion changed;
* slop-laws r5/r6: 320 changed signatures, all `P<n>_` alias renumbering;
* decode budget: 72 changed signatures, all witness seeds.

What is weak is concentrated in two places:

* **Decode-checked acceptance.** No law and no regress case pins that `_decode_checked` ACCEPTS a window between 2^31 and NMAX. The size
  limit raised the cap, but only the refusals above NMAX are pinned. The r6 re-derivation turned the one mutant that tests this into a
  wider fault that nothing would kill.
* **The r6 mutant re-derivation.** One re-derived patch is broken. Three others changed which fault they encode. None of the 55 was re-run.

Runtime evidence is still at 42a429cd. A few docs drifted or overclaim.

## Findings (sorted by severity)

| # | severity | what was lost / weakened | commit | documented? intended? | restore |
|---|---|---|---|---|---|
| G1 | **coverage of public behaviour** | The size limit raised `X_decode_checked`'s cap from `size < 2^31` to `size <= NMAX`. No law and no regress case states that a window between 2^31 and NMAX is ACCEPTED. The laws pin only refusals there: `_nmax_above` at NMAX + 1, `_nmax_wrap` at 2^32 - 1, `_limit` at NMAX + 1, `decode_checked_lying_buf_refused` on storage. The only acceptance laws (`_accept`, `_budget_accept`, `decode_checked_inside_accepted`) use windows of at most 2048 bytes, and regress cases 9-11, 22, 40-45 and 73-76 are small or refusals. A runtime whose checked decoder went back to the 2^31 cap, or any lower one, passes every law. That is observable for every name whose decoder accepts more than 2^31 bytes (the progressive lists, `List[uint8, 2^40]`, BeaconState and the containers holding them). For bounded names it is equivalent: MUTATION_PROOFS round 3 judges `r2 d01/10, 12` this way. The re-derived `r2-d01-decode-checked/06` now encodes exactly that reversion (`is_lt(size, 2147483647)` in place of `is_le(size, 4294967264)`), but on Checkpoint, where it is equivalent. It survived round 2 and was never re-run. No mutant covers the reversion on an unbounded name. The one execution of the new range is a one-off hunter probe (CRASH_HUNT R4.1: `proglist_uint8_decode_checked` of an honest 4 GiB buffer, `Some` at NMAX), not a regress case. | `c1046db54` (cap raised, size limit); `e1b65e26f` (patch /06 widened) | No | Add a by-computation law per name, `X_decode_vchecked_nmax_at(buf)`: `X_dchw(4294967264, 4294967264, (buf, 1073741816)) == X_dgo(True{}, buf, 4294967264)`, which pins the guard as True at NMAX on a symbolic buffer. Add a regress case `proglist_uint8_decode_checked` of an honest NMAX buffer = `Some` (as the R4.1 probe). Add a cap-reversion mutant on `proglist_uint8_dchw`. Re-derive /06 as `is_lt(size, 4294967264)`. |
| G2 | **weakened check** | Of the 55 patches `rederive.py` re-derived in r6 (`rederived_patch_ids_r6.txt`): (a) `r3-p05-fulu-field-validity/10` is **broken**. The re-derived patch has an extra hunk that turns `case True{}: putn` into a second `case False{}` in `l1099511627776_u8_pk`, and it moves the 4294967294 into the *minimum* length of `words_ok`. The mutated file does not check (pinned checker, `rc=1` at `match ok`), so a run would record a compile failure, not the fault "the list is bounded by 4294967294 bytes". (b) `r2-d01-decode-checked/04` and `/10` (the cap off by one upward) became `is_le(size, 4294967295)`, which is always true. They now duplicate `/03` and `/12` (cap dropped), and no off-by-one fault at NMAX remains. (c) `/06`: see G1. (d) None of the 55 was re-run: no result file after `0b80524f4`. So the earlier kills of these faults are still not evidence for the current tree. All other 51 encode the same token change modulo the marker/cap mapping (checked by script over all 55, and 11 by hand). All 55 apply, and 54 of them check as a single mutated file. | `e1b65e26f` | Partly: `MUTATION_PROOFS.md` (round 6) and `rederive_report_r6.md` list the 5 that cannot be re-derived, not these | Rewrite p05/10 by hand as `O.words_ok(o, 0, 4294967294, False{}, 1)` (a bound above NMAX). Rewrite d01/04 and /10 as `is_le(size, 4294967265)`. Make `rederive.py` reject a re-derived patch whose `-` line count or hunk count differs from the original. Then run `runner.py` on the 55 and record the results. |
| G3 | **weakened evidence** (round-6 F3, still open) | All 10 runtime evidence stamps (`benchmarks/evidence/{object_conformance,generic_object_conformance,fuzz_objects,invalid_objects,object_cache,object_mutations,object_mutation_tests,negative_api,runtime_tests,mutation_testing}.json`) are at `42a429cd` (2026-10-02). The decode window, size limit, crash-fix5/6, the r5 laws' targets and the decode budget never went through the oracle-based runtime harnesses. | whole range | `docs/RESULTS.md:329` names 42a429cd. Not tracked as an open item. | `tools/run_evidence.sh` on the server at the merged tree, then commit the stamps. |
| G4 | **doc overclaim** (coverage) | `docs/TRUST.md` and `docs/API_CONTRACTS.md` (r6 restore F1) say that decoding the four progressive types between their proved bound (2^29 / 2^31) and NMAX is "CHECKED BY EXECUTION (the regression, invalid-object and runtime suites)". No regress case decodes any of these types above its bound (cases 62-64 are size/valid of ProgressiveTestStruct and a union size). The runtime suites run on spec vectors and their stamps predate the size limit (G3). The one execution is the hunter's probe (CRASH_HUNT R4.1 "big honest record lists", ProgressiveComplexTestStruct up to 4.29 GB, not repeatable). | `dead266d1` | No | Either add regress cases (for example `ProgressiveVarTestStruct_decode_checked` just above 2^29 bytes, about 0.6 GB), or say "checked once by the round-4 hunter probe". |
| G5 | weakened check (low, documented) | 5 mutant patches still cannot be re-derived: `r2-s05-poison/01`, `/02` (old `padd` / `is_poisoned`), `r3-l01/06`, `r3-u01/05` and `r4-a10/04`. On a run they are ERROR. 1216 of 1221 apply at tip, and the same holds on a merge of tip and the decode budget. | `e1b65e26f` | Yes (`rederive_report_r6.md`, MUTATION_PROOFS) | Hand-derive them against `O.padd`, `O.is_poisoned` and `O.mulc`, or retire them with a pointer to the round-4 a01/a03 patches that replace them. |
| G6 | decode budget: acceptance edge (low) | `O.dcost` saturates at 2^32 - 1 and the budget test is `X_dcost(size) <= budget`. So `budget = 2^32 - 1` accepts every size, including those whose bound did not fit (more than 32 GiB of heap words). `_budget_accept` uses 2^32 - 1 as "unlimited". API_CONTRACTS says "saturating" but not that a saturated cost passes the maximum budget. | `5c1f48b93` | Partly | Either refuse a saturated cost (`dcost < 2^32 - 1` as part of the test), or document 2^32 - 1 as "no budget". |
| G7 | doc overclaim (low) | The decode budget docs: the API_CONTRACTS row for `X_decode_checked` says the decode takes "at most `X_dcost(size)` words ... for every input". K is MEASURED (the next row says so). `docs/TRUST.md` does not list the measured K table as an assumption. `CRASH_HUNT.md` marks R4-02 "REOPENED, FIXED" while `_decode_checked` itself still amplifies about 30x (the fix is the opt-in `_decode_checked_budget`). | `5c1f48b93` | Partly | Say "measured bound" in the `_decode_checked` row, add K to TRUST.md, and mark R4-02 as "FIXED for callers of `_decode_checked_budget`". |
| G8 | doc drift (low) | `docs/CRASH_HUNT.md:21` (the CH-05 row) still says "the older law `decode_checked_2gib_refused` keeps its statement but now holds only because ...". The law was deleted in r6. | `e1b65e26f` | No | Say "deleted in r6 (round-6 F6)". |
| G9 | doc drift (low) | The docstring of `codegen/proofs/slop/decode_checked_laws.py` still describes the round-3 regime. It says the decoder accepts "below 2^31 bytes" and that `_limit` is `X_dchw(2^31, 2^31, (B.empty(), 2^29))`. The generated `_limit` is at NMAX + 1 with 2^30 words, and `_nmax_wrap` / `_nmax_above` are not listed. | `ed754d7b1` / `c1046db54` | No | Update the docstring. |
| G10 | process (info) | Merging `agent/decode-amplification` onto `e1b65e26f` conflicts in 224 generated `proofs/api/*_decode_ssz_proof_generated.bend` and in `proofs/gate/api_map.json`: r6 renumbered the aliases and the budget added restatements. These are generated files: regenerate after the merge, then run a cold full check. Patch applicability is unaffected (1216 / 5 on `git merge-tree` of the two). | - | - | Regenerate after the merge, then run `check_fast.sh --no-cache`. |
| G11 | coverage gate (info) | r5 widened `object_api_coverage_gate.SHAPE['decode_offsets']`: it now also accepts any conclusion that mentions `T.<X>_decode(` (and adds the `_decode_vlit_` form). This only adds entries (0 of 15,897 lost), but from now on a decode_offsets cell can be filled by a literal law alone. | `9d0ad145b` | Yes (commit message) | None needed. Keep in mind when a decode_offsets law is removed. |

## Round-6 findings: status at the r6 tip

| r6 | status |
|---|---|
| F1 progressive decode gap | documented (TRUST, API_CONTRACTS, size-limit diff §4, all four types); the "checked by execution" sentence overclaims (G4) |
| F2 dropped regress case | restored: case 72 (`pd_encode_22369622_len=0`) passes at tip and at da; r6 adds `vpoison_size_<kp>_above/_at` for 16 of 17 fixed-composite lists (the one-byte `l10_ProgressiveSingleFieldContainerTestStruct` is skipped, documented) and `vpoison_out_done` |
| F3 stale runtime evidence | **open** (G3) |
| F4 stale patches | 55 re-derived, 5 not (G5); one broken and three with a changed meaning, none re-run (G2) |
| F5 crash-fix6 unstamped | resolved: `ec8265b91` stamps 312db971c, then `0b80524f4` stamps dead266d1. Both are cold (88/88 umbrellas, 0 reused, 4,860 roots, 11,609 files). |
| F6 2gib law | deleted. Claim verified: 240/240 names have `_nmax_wrap` and `_nmax_above`, and each pins the `size <= NMAX` conjunct alone: at (NMAX + 1, n = 2^32 - 1, c = 2^30) the window and storage conjuncts are true, and at 2^32 - 1 `size + 3` wraps to 2. Storage is pinned at small sizes by `_storage` / `_real`. CRASH_HUNT row is stale (G8). |
| F7-F12 docs | fixed in `dead266d1` (PREMISES has no 2^31 regime left, the R3-03 row is closed, the guard widening is in the diff doc, the conclusion wording is corrected, MUTATION_PROOFS round 3 is restored, p3_cache uses `_ctake`) |

## What was checked and found intact

* **Names.** I extracted every top-level `def` / `law` / `type` header, up to its depth-0 `:`, from every `.bend` file outside vendor/build in
  all five trees:

  | tree | files | items |
  |---|---|---|
  | old | 10,471 | 142,210 |
  | b6 | 12,019 | 154,915 |
  | main | 12,022 | 155,018 |
  | tip | 14,315 | 175,924 |
  | da | 12,023 | 157,843 |

  Lost names:
  * old to b6: the 39 internal `*D` / `fitsBa` / `lt32Ba` lemmas that round 6 found (documented);
  * b6 to main: none;
  * main to tip: only `decode_checked_2gib_refused`;
  * main to da: none.

  No `.bend` file was deleted or renamed in the range: 4,299 added and 2,642 modified files from old to tip, and 8 added and 1,043 modified
  from main to da.
* **Changed signatures after b6.**
  * **b6 to main (crash-fix6), 15:**
    * the 10 frozen `read_append(_grow)` laws of `bl1073741824`, `bl32`, `l1099511627776_u8`, `bits131072` and `bits2048`. Premises are
      token-identical. Only the storage term of the conclusion changed: `O.merge_word(O.app_old(word, p & 3), ..)` for bytes,
      `BV2.close_t(d, upd(..), n)` for bits. That term is still an exact equation, and it is the runtime's new storage;
    * `view_app` and `view_app_u8` (not frozen; the same change);
    * `words_slice` (the R5-02 guard);
    * 2 probe functions (`_cget` to `_ctake`, r6 F11).

    All of this is as `docs/crash_fix6_statement_diff.md` says. `close_t` is `close_g(U32.is_lt((n >> 5) + 1, 2^d), ..)`, the runtime's
    `bits_close_sz` test on a thawed tree (lemma `close_thaw`), not an always-true condition. The round-6 open question (app_old clears only at
    s == 0) is resolved by the validity rule: `_valid` already requires the rest of the last word to be zero, so only a new word (s == 0) can
    carry dirty bytes (CRASH_HUNT R5-01).
  * **main to tip, 320:** all are `P<n>_` import-alias renumbering in `proofs/api` (normalised: 0 differ).
  * **main to da, 72:** all are witness seeds `22xxxxxxxx` in slop/gate/api constants (normalised: 0 differ). The doc says so.
* **Deleted lines main to tip** (outside patches and alias-only api files):
  * the 2gib law and its generator text;
  * the coverage-gate regexes, widened (G11);
  * the boxed-only branch of `container_field_validity`, replaced by a version that covers boxed and unboxed children up to depth 3. Every
    old law name is still emitted with an unchanged statement;
  * one hand override in `rederive.py`.

  The 22 modified `proofs/(gate/)slop/validity` files only gained lines.
* **Frozen.** After crash-fix6, `frozen.lock.json`, `e2e/STATEMENTS.txt`, END_TO_END / ROOT_DOMAIN / PROOF / HASH_PROOF, `spec/` and `schemas/` are
  unchanged at main, tip and da. crash-fix6's 7 `statement_defs` hashes are the ones its diff doc names. `tools/verify_frozen.py` passes at tip and at
  da (36 planted changes, 42 files, 4 roots, 1,915 statement_defs).
* **Generators.**
  * **Registry:** 146 at main, 147 at tip (`decode_literal_laws` added); none removed.
  * **Outputs:** I counted files and defs per `GENERATED by` header, searching the first 80 lines (imports push the header down).
    Totals for files / laws / defs:

    | tree | files | laws | defs |
    |---|---|---|---|
    | old | 9,609 | 3,042 | 111,228 |
    | b6 | 11,143 | 3,158 | 122,921 |
    | main | 11,143 | 3,158 | 122,950 |
    | tip | 13,390 | 3,158 | 142,337 |

  * **Falls:** the only def counts that fell are `deep_tree_list_children` (764 to 729, documented in r6) and `crash_fix_laws` (36 to 35, the 2gib
    law). `object_api_facade_proofs` seems to fall (709 to 657 files) only because added imports push its header past line 80: no file or name
    is lost.
  * **Growth main to tip:**
    * `decode_literal_laws` +1,072 files / 17,203 defs;
    * `object_api_coverage_gate` 3,348 to 4,485 files;
    * `tight_storage_root` 3 to 68;
    * `container_field_validity` 370 to 393 defs;
    * `writer_poison_laws` 301 to 317 files.
  * **Decode-checked laws:** 240 each of `nmax_wrap`, `nmax_above`, `limit`, `window` and `storage`; 216 `accept` / `short`; 181 `real`.
* **Coverage gate.**
  * **Entries:** `proofs/gate/api_map.json` has 12,473 entries at old, 15,897 at b6 and main, 18,753 at tip and 16,353 at da, with 0 entries lost
    at each step.
  * **MISSING:** `MISSING.txt` is 0 of 2,160 in every tree.
* **Checks and gates.**
  * **Harness unchanged:** `check_fast.sh`, `strictcheck.sh`, `verify_frozen.py`, `umbrellas.py`, `check_stamp.py`, `umbrella_cache.py`,
    `check.sh` and `codegen/tests` are unchanged after b6 (and over the whole range, except the new `test_decode_window.py` /
    `test_no_stale_marker.py` before b6).
  * **Stamps:** the main stamps after b6 are cold (`reused: 0`, 88/88).
  * **Strictcheck at tip** (server, nice 19): **150 checks passed, 0 failed**, against 149 at main, the +1 being `decode_literal_laws`.
  * **Not run here:** the full proof check of tip and of da. The gates in progress own it. Tip's `check_fast.json` is still main's (tested
    dead266d1).
* **Runtime.**
  * **Nothing removed:** no def was removed from `src/` or `types/` in the whole range.
  * **No stale callers:** a scan of `Alias.name(` calls in `tools/`, `benchmarks/`, `native_bench/` and `memory_bench/` finds only builtins.
  * **crash-fix6** only clears storage on append and guards the empty slice.
  * **Decode budget:** adds `_dcost`, `_dcb` and `_decode_checked_budget`; `_decode` and `_decode_checked` are text-identical.
* **Tests and corpora.**
  * **Regress cases:** cases 1-39 are unchanged in every tree, and cases are only appended. **Regress at tip: 72/72 pass; at da: 76/76 pass**
    (server, pinned toolchain).
  * **Survivor lists:** rounds 2/3 keep 96/76 entries; round 4 gained 48 entries.
  * **Unchanged:** `tests_generated/` and the corpora.
  * **Patches:** 846 at old, 1,054 at b6 and main, 1,221 at tip. GNU `patch -p1 --dry-run` applies:

    | tree | apply | fail |
    |---|---|---|
    | old | 783 | 63 |
    | b6 | 1,000 | 54 |
    | main | 994 | 60 |
    | tip | 1,216 | 5 |
    | da | 994 | 60 |
    | tip + da merge | 1,216 | 5 |

  * **Re-derived patches:** the 63 re-derived in `873dc8633` keep their fault (one hand override, r2-h04/05, now hits both uses of the count).

## Method

* **Trees:** `git archive` of the five commits, extracted on the Mac (reading only) and under `/srv/ssz-optimization/agents/audit-r7/` on the
  server.
* **Signatures:** a header extractor and diff (name sets per file and over all files, token diffs of signatures, normalisation of `P<n>_` and
  seeds), with the residue read by hand.
* **Generators:** counts per `GENERATED by` header.
* **Gate:** a flattening diff of `api_map.json`.
* **Patches:** GNU `patch -p1 --dry-run` per patch and tree. Token-level comparison of each re-derived patch's replacement against its
  predecessor. For every r6 re-derived patch, the patched file was checked alone with the pinned checker (`tools/check.sh`,
  toolchain-memo-788a6866, nice 19).
* **Server runs** (one or two jobs at a time, nice 19):
  * `tools/strictcheck.sh` and `tools/verify_frozen.py` at tip;
  * `tools/verify_frozen.py` at da;
  * `tools/crash_hunt/regress.sh` at tip and da.
* **Machine-readable findings:** `docs/audit/round7_dropped.json`.
