# Manual spec mutations, round 14: fixes (fixer K)

Input: branch `agent/manual-spec-mutations-r14` at f5b725282 (gate.git), `r14/manual_round_14_survivors.json` and
`patches/r14-a02-sampled-api2/{05,25}.patch` there. Base: origin/main d6f809a26. Only generated laws changed (`decode_checked_laws`) and the
api coverage gate now requires them; no runtime, spec, schema, END_TO_END / ROOT_DOMAIN / PROOF / HASH_PROOF or frozen-lock change.

## F1. The storage test at the type's own size (a02/25, critical)

`vec_uint64_513_dchw` counting storage in 32-byte chunks (`(size + 31) >> 5`) instead of words survived: the type's default (4104 bytes) is above
the 2048-byte literal cap, so its only storage law was `dchw(8, 8, (B.empty(), 1)) == None`, whose buffer claims 0 bytes; the decoder's own
window test refuses it whatever the storage test says.

**`decode_checked_laws`**, for every name X with a checked decoder (240 names: 109 Fulu + 131 generic), S a valid size of X (the fixed size; the
default encoding's size when not empty; for a list whose default is empty, a list of one default element), W = ceil(S / 4):

* `<X>_decode_vchecked_storage_size(buf)`: `X_dchw(S, S, (buf, W - 1)) == (buf, None)`. The buffer is a variable, so with a weakened storage
  test the guard lets the window through and the decode of `buf` is stuck: the statement fails by name. 240 names.
* `<X>_decode_vchecked_accept_size(buf)`: `X_dchw(S, S, (buf, W)) == X_dgo(True, buf, S)`, for the 24 names without a literal window
  (the 216 others already pin acceptance at exactly W words on the literal: `_accept`). The 24: BeaconState, Blob, BlobSidecar,
  HistoricalBatch, LightClientBootstrap, LightClientFinalityUpdate, LightClientUpdate, MatrixEntry, SyncCommittee, Transaction, the seven
  generic progressive lists and vec_uint{32_513, 64_512, 64_513, 128_512, 128_513, 256_512, 256_513}.
* The generator stops when a name has no valid size (or S > NMAX). The old `_storage` laws stay.

## F2. The empty list decodes (a02/05)

`<X>_decode_vchecked_empty`: for every list, byte list and progressive list at top level, `X_decode(B.empty(), 0)` and
`X_decode_checked(B.empty(), 0)` are both Some value of length 0 (`<p>_len`, p the list's validator prefix; None reads as 2^32 - 1).
8 names: Fulu Transaction and the generic proglist_{bool, uint8, uint16, uint32, uint64, uint128, uint256} (no other top-level list name has a
checked decoder; bit lists are excluded, their empty encoding is invalid). The generator stops when such a list has no length function.

## Gate

`object_api_coverage_gate` (`required_laws`): every name with a checked decoder must have `<X>_decode_vchecked_storage_size` among its
`decode_offsets` laws, and every list / byte list / progressive list also `<X>_decode_vchecked_empty`; the gate stops otherwise.

## Replay (pinned checker, 16384 KB stack, mutant applied to the regenerated tree)

Replay set per mutant (auditor's hint): every proof file that imports the mutated types module (callers), the name's constants file
(`proofs/slop/constants/<X>_generated.bend`) and its decode_checked file.

| fault | before | killing law (file) |
|---|---|---|
| r14-a02-sampled-api2/25 (storage in 32-byte chunks) | survived | `vec_uint64_513_decode_vchecked_storage_size` (`proofs/slop/validity/generic_vec_uint64_513_decode_checked_generated.bend`, 0.7 s; also through `proofs/api/vec_uint64_513_decode_ssz_proof_generated.bend`): expected the stuck `vec_uint64_513_dwin(4104, B.size(buf))`, observed `(buf, None)` required. Constants file, offsets, decode_window, spec_garr, fixrej_g3 pass (as expected, they do not reach the storage test). |
| r14-a02-sampled-api2/05 (empty window refused) | corpus only | `proglist_uint8_decode_vchecked_empty` (`generic_proglist_uint8_decode_checked_generated.bend`, 0.7 s). Also killed by the existing `proglist_uint8_decode_vlit_ok_default` (`generic_proglist_uint8_decode_literal_ok_generated.bend`, round 5) and `ProgressiveTestStruct_decode_vchecked_accept`: the round-14 replay had not run those callers. The api / var_plist / var_winp / var_winx facades still overflow the stack under the mutant, as reported. |

Every killing file fails by a statement mismatch in under 1 s.

## Checks

All on the ssz server, tree `agents/fixK-r14/tree` (a fresh clone of gate.git: origin/main d6f809a26 plus this change), nice 19, at most 8 jobs.

* Regeneration: `codegen/regenerate_all.py` (all generators); `tools/test_codegen.sh 8`: 53 unit tests OK, ruff not installed on the
  server (lint skipped), **151/151 generators up to date**. The regeneration refreshed the api facades (`proofs/api/*_decode_ssz_proof`),
  `proofs/gate/api_map.json` and the gate modules of the 240 decode_checked files.
* New / changed files, single-file `tools/check.sh`: all 240 decode_checked files pass; slowest 13.8 s (vec_bool_513), all far under 2
  minutes; every new literal is a U32 (no closed term over a large Nat literal).
* Cold full check: `CHECK_CACHE=0 tools/check_fast.sh --jobs 8 --no-cache`: **all files check**, 101 umbrellas (15958 files, 0 reused
  from the cache) in 1570 s. The stamp was kept out of the commit (`agents/fixK-r14/full1/stamp.json` on the server).
* `tools/crash_hunt/regress.sh`: all cases pass.
* `tools/verify_frozen.py`: 36 planted changes ok; 42 files, 4 statement roots, 1915 statement_defs files match.
