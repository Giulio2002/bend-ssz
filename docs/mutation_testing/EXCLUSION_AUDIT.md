# Audit of the mutation loop's proof-equivalent exclusions

`tests_generated/mutation_exclusions.json` hides 219 mutants from the loop: 218 `proof-equivalent` and 1 `uncoverable`. This
audit re-derives every rule independently (no code shared with `tests_generated/mutation_equivalence.py`), and checks each rule by
a Bend proof or by a differential run of original against mutant. Tool: `tools/mutation_testing/exclusion_audit.py` (and
`tools/mutation_testing/exclusion_audit_words.py`); all runs were on the server in a private copy of the tree, the mutant files were deleted after each batch.
The mutants the exclusions wrongly hide are in `docs/mutation_testing/EXCLUSION_AUDIT_HIDDEN.json`.

## Result

| rule | entries | verdict | evidence |
|---|---|---|---|
| argument never read | 127 | sound for the site the rule examined; the entry key also hides 4 other sites that are NOT equivalent | 45 Bend laws (one per callee, parameter and literal pair), all check |
| flag read only by `O.is_poisoned` | 30 | 29 sound, 1 UNSOUND (`v4_b32_pk_ok`) | reaching-serializer analysis plus a differential run of 38 serialize cases |
| `words_ok` bounds / unit | 47 | sound for the site examined; the key also hides 35 sibling sites that are NOT equivalent | exact interval comparison, runtime differential on all 83 keyed sites |
| `bits_ok` limit | 1 | sound | Bend law |
| vec_bool `ok_n` / `ok_nz` | 13 | sound; the key also covers 5 `case True{}` pattern sites, which do not compile (harmless) | 13 Bend laws, repo-wide caller scan, compile of the 5 pattern sites |
| `uncoverable` (Transaction 2^30 to 2^30+1) | 1 | NOT equivalent, and killable by a proof law | a Bend law that checks for the original and fails for the mutant |

So 41 real mutants are wrongly hidden (4 + 35 + 1 + 1) and 5 invalid ones; no entry is wholly wrong except the two named, and every
other entry has at least one site that is truly equivalent (the tool checks that: 0 entries without an equivalent site).

## A defect common to all rules: the key is wider than the rule

An entry is keyed by (file, def, operator, before, after, line text). The draws skip every site on that line with that operator and
literal, but the rule examined one column. 42 of the 219 entries match more than one site. The siblings are real
mutants the loop never draws:

- argument never read: `u64_read(buf, (off + 8 : U32), 8)`. The rule examined the length argument (`8`, never read); the key
  also hides the `8` of `off + 8`, which is the read offset. 4 sites: FuluAttestationData (line 34), FuluPendingConsolidation (18),
  FuluPowBlock (25), SmallTestStruct (18), all `*_decode_ssz_generated.bend`.
- `words_ok(o, 16, 16, False{}, 16)`: the rule examined `hi` (16 to 17: the unit 16 still refuses 17); the key also hides `lo`
  (16 to 17 refuses the valid length 16) and `unit` (16 to 17). The same for `hi` minus 1, `lo` plus 1 and the proglist `words_ok(o, 0, 0, True{}, u)`
  (`lo` 0 to 1 refuses the empty list). 35 sites, each with a witness length in the JSON.

Fix for the loop: key on the column as well (file, def, operator, before, after, text, column), or make the rule's checker run for
every matching site and drop the entry when any site fails (`tools/mutation_testing/exclusion_audit.py structural` is that checker).

## Rule by rule

### 1. Argument never read (127 entries, 131 sites)

Rule: the mutated literal is the whole direct argument of a call and the callee's body never mentions that parameter. Sound because
Bend is pure and total: a function that does not mention a parameter cannot depend on it, so `f(.., a, ..)` and `f(.., b, ..)` are
definitionally equal. Independent re-check: own call parser, callee resolved through the file's import alias to its file (the
original looks a def up by bare name across all files), comment-stripped body, the parameter token absent, def unique. 127 of 131
sites pass; the 4 failures are the offset siblings above (the literal is not the whole argument; it sits inside `off + k`).
Proof: `python3 tools/mutation_testing/exclusion_audit.py laws-unread types` writes 25 files with 45 laws
`def law(...) -> {AUD.f(.., 8, ..) == AUD.f(.., 7, ..) : T}: {==}` (one per distinct callee, parameter, literal pair); all check.
One callee, `b1_root`, matches on its record argument, so with `o` a variable the kernel keeps the unused `+hl` threaded through
the stuck match and `{==}` fails; the same laws with `o = Bytes1{w0}` (the only constructor) check, which is the full domain.
Verdict: sound.

### 2. Flag read only by `O.is_poisoned` (30 entries)

Rule: in `X_pk_ok`, `(out, (o, 0))` to `(o, 1)` is invisible because the flag only reaches `is_poisoned(fl) = 2^31 <= fl`.
This is true only when the flag stays a flag. In a variable-size container the flag is OR-ed into the running length (`cur .|. fl`),
and that length is what `ser_done` writes. Analysis (`tools/mutation_testing/exclusion_audit.py poison`): the call graph of the encoders; for each
entry, every `*_serialize` that reaches the def, and whether its final length is a literal (flag reaches only `is_poisoned`) or a computed count.

- 29 entries reach only fixed-length serializers. Differential run (`run-diff`: the encoders with the flag 0 to 1 against the original, copies in
  private `types/_audit_*` files; `serialize(default)` length compared): all equal, including Cell to MatrixEntry (2112/2112).
  Blob and BlobSidecar timed out (131072-byte objects in the interpreter): sound by the structural argument only.
- UNSOUND: `types/FuluExecutionBranch_encode_ssz_generated.bend`, `v4_b32_pk_ok`, `(out, (o, 0))` to `(out, (o, 1))`. The
  consumers `LightClientHeader` and the Bootstrap, FinalityUpdate, OptimisticUpdate and Update containers use the flag as part of the
  length. Counterexample, `serialize(default)`: LightClientHeader 828 to 829, Bootstrap 25648 to 25649, FinalityUpdate 2056 to 2058,
  OptimisticUpdate 1000 to 1001, Update 26872 to 26874. This mutant is a real survivor of the proof loop because the loop checks only the
  ExecutionBranch facade; the runtime suite for the mutated type does not run LightClientHeader. It goes back to the fixers: it needs a
  law on a consumer's serialize (not a flag read), or a runtime check of the consumers.

### 3. `words_ok` (47 entries, 83 keyed sites)

Rule: the accepted length set {n : lo <= n <= hi (hi unbounded when big), unit | n} is unchanged. `words_ok` is
`wk_cap(and(and(le(lo,n), or(big, le(n,hi))), unit_ok(unit,n)), n, size)`; the other arguments of `wk_cap` do not mention lo, hi or unit,
so equal sets give equal functions; `unit_ok` is a mask for 1, 2, 4, 8, 32 and `U32.mod` otherwise, each exactly "unit divides n".
Independent check: the sets are compared exactly over all n in [0, 2^32) (first, last, step, count: no sampling; the original samples when
the range is over 5 million) for every keyed site. 48 equivalent, 35 differ. Runtime differential
(`tools/mutation_testing/exclusion_audit_words.py`): a Bend program calls `O.words_ok` with the original and the mutated literals on about 100 boundary lengths
per site (`Words{zeros(n+4), n}`); the model and the runtime agree on all 83 sites (48 equal, 35 differ, 0 mismatches).
A Bend law for the `big` case: `words_ok(o, 0, 0, True{}, 4) == words_ok(o, 0, 1, True{}, 4)` checks (`tools/mutation_testing/exclusion_audit.py laws-misc`).
Verdict: sound for the examined site; the 35 siblings are hidden mutants (JSON).

### 4. `bits_ok` (1 entry)

`pbits_valid`: `bits_ok(o, 0, True{})` to `bits_ok(o, 1, True{})`; `limit` is read only under `Bool.or(big, ..)`. Law
`bits_ok(o, 0, True{}) == bits_ok(o, 1, True{})` checks. Sound.

### 5. vec_bool decoders (13 entries)

Rule: `ok_nz(empty, ..)` is called only by `ok_n`, which passes `is_eq(n, 0)`, and `ok_n` only by `ok_at` with the literal N >= 1.
The tool scans the whole repo (types, src, proofs, e2e, spec, benchmarks): no other caller of `*_ok_n` or `*_ok_nz`. A mutant module holding
only the mutated chain (`ok_nz`, `ok_n`, `ok_at`) over the original helpers is compared with the original: the law
`ORIG.vN_bool_ok_at(buf, off) == MUT.vN_bool_ok_at(buf, off)` checks for all 13. The 5 sibling sites (the `case True{}` pattern turned into
`case False{}`) do not compile ("cases for True"), so they are invalid mutants and cannot survive. Sound.

### 6. Uncoverable (1 entry)

`bl1073741824_valid`, 2^30 to 2^30+1. Not equivalent: the mutant accepts a Transaction of 2^30+1 bytes. "Not constructible" holds for
a test, not for a proof. `tools/mutation_testing/exclusion_audit.py laws-misc` writes `tx_valid_refuses_2p30_plus_1`: for every array `ws`,
`snd(TX.bl1073741824_valid(Words{ws, 1073741825})) == False{}` (the original refuses by evaluation, the rest by `wk_cap`/`wk_last` with a
`False{}` first argument). It checks for the original and fails for the mutant (`expected wk_cap(True{}, ..)`, `observed wk_cap(False{}, ..)`).
Verdict: unsound as an exclusion; a new law kills it.

## Reproduce

Server only, in a private copy: `python3 tools/mutation_testing/exclusion_audit.py structural --json OUT` (all sites, all rules),
`laws-unread types` then `bend --check-only` on each `types/_audit_unread_*.bend`, `laws-boolvec`, `laws-misc proofs`,
`poison`, `diff-poison DIR` and `run-diff DIR/cases.json`, `tools/mutation_testing/exclusion_audit_words.py cases` and `gen`. Delete `types/_audit_*` and `proofs/_audit_*` afterwards.

## Closure (agent/mutfix-hidden)

Each of the 41 hidden mutants was applied alone to a private hard-linked tree and its own facade re-checked with the pinned checker
(`tools/mutation_testing/mutant_facade_run.py`; the trees are deleted at once). Result:

* 35 hidden `words_ok` siblings and 4 hidden read offsets: all FAIL with a statement mismatch on their own facade. The existing laws
  already kill them (`X_serialize_vsym` states every constant of the validity pass symbolically; `X_decode_fields` pins the read
  offsets); they were never drawn because the exclusion key hid them. No new law is needed.
* Transaction `2^30 -> 2^30+1`: FAILs on the Transaction facade (`expected ..<= 1073741825.. observed ..<= 1073741824..`), killed by the
  existing `Transaction_serialize_vsym`. The `uncoverable` entry is removed.
* ExecutionBranch `v4_b32_pk_ok` flag `0 -> 1`: PASSED its own facade (the light-client and DataColumnSidecar facades already failed it,
  which the loop never checks for a mutant of this file). New generator `codegen/proofs/mutation_coverage/poison_flag.py` writes
  `proofs/mutation_coverage/validity/<runtime>_<X>_poison_flag.bend` for every words name (76 files): `X_serialize_vflag(out, o): {T.P_pk_ok((out, o)) == (out, (o, 0))}`,
  filed by object_api_coverage_gate in the name's encode facade. The unmutated facade passes; the mutant fails with
  `expected (out, o, 1)`, `observed (out, o, 0)`. The 29 pk-flag exclusions of the other names now die as well.
* Exclusion key: `tests_generated/mutation_testing.excluded` and `mutation_equivalence.py` key on (file, def, operator, before, after,
  line text, column); `mutation_exclusions.json` has one entry per equivalent site (218 entries; the two unsound entries are gone, siblings
  are drawn). `pk_equiv` no longer applies to FuluExecutionBranch.

The outcome of each mutant is in the `closed` field of `docs/mutation_testing/EXCLUSION_AUDIT_HIDDEN.json`.
