# SSZ iteration 23 progress snapshot (2026-09-25 16:16 CEST)

This is a source snapshot from the live iteration-23 workspace. The proof sweep and worker remain active; this snapshot does not claim full formal verification.

## Current proof sweep evidence

The recorded checks in `final_sweep.log` show these recent grouped results:

- PASS: `g_base` (102 proof modules), `g_l134217728_PendingDeposit`, `g_l134217728_PendingPartialWithdrawal`, `g_l16777216_HistoricalSummary`, `g_l16_SignedBLSToExecutionChange`, `g_l16_SignedVoluntaryExit`, `g_l16_WithdrawalRequest`, `g_l2_ConsolidationRequest`, `root_gtypes`, `HASH_PROOF`, `PROOF`, `END_TO_END`, and `ROOT_DOMAIN`.
- FAIL: `g_l16_Withdrawal` (checker stack overflow) and `g_l8192_DepositRequest` (checker exited 1; all-terms check false). These failures remain open; no cause is asserted here.
- In flight at snapshot time: the standalone `cspec_l16_Withdrawal` diagnostic and `root_big_Transaction` / `root_big_ExecutionPayload`. Three other `root_big_*` checks remain queued. The parallel sweep log says five large-root checks were pending when that two-at-a-time batch began.

The sweep has not completed. In particular, successful root-level checks do not establish complete codec correctness, complete Fulu type coverage, or the end-to-end object API claims. See `WORK_LOG.md`, `docs/LAW_API_MAP.md`, and `README.md` for scope and remaining obligations.

## Other validation evidence

The workspace work log reports prior iteration-23 results: 5,440/5,440 SSZ spec cases; runtime 51/51; object and generic conformance 295 and 5,145; mutation, negative-API, cache, invalid-object, and fresh-seed fuzz checks passed; performance gate 978 workloads / 327 operations within the configured limits; native decode-memory 15/15 within 32 MB. These are recorded worker results, not rerun as part of this publication. Earlier codec proof coverage of 83 names is still the last reported figure; no new complete codec sweep is available.

## Publication validation

The snapshot copied current source and selected sweep logs. `git diff --check` and Python syntax checks were run for code generators. No full proof sweep, runtime suite, benchmark gate, or independent audit was rerun for publication. Build artifacts and the operator-only parallel scheduler patch were excluded. The live worker was not stopped.
