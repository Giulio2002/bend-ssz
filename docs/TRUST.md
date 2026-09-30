# Trust boundary

Trusted (not proved here):

- **The checker.** Bend 2.0.28 with bendlang/bend#1075 and its budget fix, commit 3ddfb036 of
  bendlang/bend, run on Bun 1.4.2. `toolchain.lock.json` pins the commit and the sha256 of every
  file the checker runs (`bend2/main.ts`, `bend.ts`, `comp.ts`, `base.bend`) and of the Bun
  binary; `tools/check.sh` and `tools/check_fast.sh` refuse to run on any other bytes
  (`tools/verify_pins.py`). This is **not a Bend release and not upstream code**: 3ddfb036 is on
  the branch of bendlang/bend#1075 ("Conversion checks syntactic identity before normalizing"),
  and that pull request was **closed without being merged on 2026-09-27**. Its five commits are
  not on Bend's main (which is 44 commits further on). What that means for trust: the checker
  every result here rests on is Bend 2.0.28 plus a conversion shortcut (two syntactically
  identical terms are equal without normalizing them) that upstream reviewed and declined to
  merge. The shortcut is sound in principle (syntactic identity implies definitional equality),
  but its implementation has had no upstream acceptance, so a reader must trust these five
  commits, and the rest of the checker, on their own review. The way out is a port of the proofs
  to a released Bend or current main: the slow closed facts (limits of 2^30 bytes and above) have
  to be rewritten on the proof side (for example once-computed literal constants), never by
  patching the checker. Until that port lands, every "checks" claim in this repository means
  "checks under 3ddfb036".
  `tools/check_fast.sh` accepts an umbrella only on the exact line `All terms check.` (never the
  checker's "All terms check, but N defs rely on unsafe or foreign code"). An umbrella whose first run
  printed "the machine stack overflowed" (nondeterministic under load on this checker) is run once more and the second run
  decides, again only on that exact line; the first log is kept as `<n>.log.try1` (docs/BUILD.md). That report covers only
  the top file's defs and the laws, so in an umbrella (which only imports) an unsafe dependency of
  a bridge def would not show; the guard for every def is `tools/verify_no_escapes.py`, run before
  any check. It bans `@unsafe`, `def f?(` and foreign bodies (`import "x.js"`) in every `.bend`
  file, in every spelling the pinned parser accepts: it lexes comments, strings and char literals
  like the parser and allows whitespace, newlines and comments wherever the parser skips them
  (`@` newline `unsafe`, `: import "x.js"` on the def's line, `import"x.js"`). Its planted cases
  run on every invocation, and `--probe` runs each positive one through the pinned checker, which
  reports all 19 as relying on unsafe or foreign code. #1075 compares syntactically identical terms before
  normalizing them; without it, some closed facts (limits of 2^30 bytes and above) would be
  evaluated in unary and not finish. Soundness of the result rests on this checker.
- **The checker's logic has `Type : Type`.** The pinned checker accepts `def tt() -> Type: Type`
  and `tt2(Type)` for `def tt2(T: Type) -> Type: T` (probe run on the ssz server, 2026-09-30:
  "All terms check."). A type theory with `Type : Type` is inconsistent in principle (Girard's
  paradox, in Hurkens' short form): some closed term of any type, `Empty` included, exists. The
  checker's other restrictions make the naive encodings fail (an independent probe found that
  Data cannot hold functions, Type values cannot be copied, and non-structural and mutual recursion
  are rejected), but no consistency argument for the logic exists. Nothing in this repository
  constructs such a term on purpose: the proofs use `Type` only as the type of type parameters
  (`-A: Type`, motives `P: A -> Type`), and every `Empty` they build comes from a contradictory
  equality (`logic__false_true` on `{False == True}`) or a structural case. So "checks" means
  "checks in the pinned checker's logic", which has no consistency proof; a reader must trust that
  none of the generated proofs is a disguised paradox, which review of the generators and of the
  proof style supports but does not prove.
- **The frozen specification.** `spec/*.bend` (an independent transcription of
  `vendor/consensus-specs/ssz/simple-serialize.md`, mapped in `spec/CORRESPONDENCE.md`),
  `spec/fulu_schemas.bend` and `schemas/fulu_mainnet.json`, and the statements of
  END_TO_END.bend, ROOT_DOMAIN.bend, PROOF.bend and HASH_PROOF.bend. These are reviewed, not
  proved. The `codegen/` generators never write them, but three spec files are the output of
  `tools/generate_*.py` scripts and carry no `# GENERATED` header:
  `spec/bit_packing.bend` (`tools/generate_bit_packing.py`, which also writes
  `src/bit_packing.bend` and `proofs/bit_packing.bend`), `spec/bit_decoding.bend`
  (`tools/generate_bit_decoding.py`, which also writes `src/bit_decoding.bend` and
  `proofs/bit_decoding.bend`) and `spec/fulu_schemas.bend` (`tools/generate_fulu_schema_proofs.py`,
  a transcription of `schemas/fulu_mainnet.json`). They are frozen like every spec file (their
  bytes are in `frozen.lock.json`), and `codegen/tool_generators.py --check` reruns the three
  scripts and requires the committed bytes, so the script is a record of how the text was
  produced, not a way to change it. What they are reviewed as is the text they contain.
  **Independence of the bit packing.** `spec/bit_packing.bend` and `src/bit_packing.bend` come
  from one template: `pack` (eight bits per byte, lowest index at weight 1, a short final group
  padded with `False`) is the same text in both, and only `octet` differs (the spec sums the bit
  weights with `U32.add`, the runtime combines them with `U32.or`). `proofs/bit_packing.bend`
  proves the two equal, so that proof establishes the `add`/`or` equivalence and nothing about
  the grouping: a grouping error in the template would sit in the spec and the runtime alike and
  no law would catch it. The grouping is reviewed against simple-serialize.md (the `Bitvector` /
  `Bitlist` rows of `spec/CORRESPONDENCE.md`) and cross-checked by the official `ssz_generic`
  bitvector and bitlist vectors, which all pass. `spec/bit_decoding.bend` and
  `src/bit_decoding.bend` share only the outer form (eight bits, lowest first); the spec reads
  digit i arithmetically (`(x / 2^i) mod 2`), the runtime by shift and mask.
  `frozen.lock.json` records the sha256 of every spec file (and the representations and
  normative sources it rests on), of the four roots' statement text (proof bodies excluded), of
  `types/fulu_model.bend` and `proofs/obj/generic_specs.bend` (what END_TO_END's per-name laws
  and the generic bridges quantify over), and, per file, of every statement in
  `e2e/STATEMENTS.txt` and every definition it reaches, transitively, on the premise side and the
  conclusion side: the object views, `rep` invariants and their helpers in `proofs/` and `e2e/`,
  and in `src/` and `types/` the helpers a statement names (`B.fill_at`, `B.alloc`, `D.bytes`,
  `O.e8` in the Branch `cap` premise, the object types) with everything they reach. Only the
  implementation under test is left out: the generated per-name encoder, decoder and root
  (`types/*_{encode_ssz,decode_ssz,hashtreeroot}_generated.bend`, which the bridges pin down) and
  the model API `src/model.bend` (which END_TO_END's laws pin down); but not the validity predicates
  of those encoders (`X_valid` and its helpers, the premise of the validating-serializer statements), which are
  hashed. So a change to a src/ def
  cannot weaken or empty a premise without changing the lock. `tools/verify_frozen.py` checks
  all of this (after planting seven changes: five that must trip the lock, among them a weakened
  `Checkpoint_valid` and `u8_valid`, and two that must not, the encoder and the serializer, which the proofs pin down), and that
  `memory_bench/law-statements.json` holds END_TO_END's laws verbatim. `tools/check_fast.sh`
  runs it first, so a full check never passes on changed statements.
- **SHA-256.** The BendHub package `0xe4067e0d858024083f36a7abe7281e89` (bend-collections),
  vendored at `vendor/bendhub/` and pinned by tree hash in `toolchain.lock.json` (the checks use
  the vendored copy unless `BEND_LIB` names another, which must hash the same). Its FIPS 180-4
  model (`spec/crypto/sha.bend`) is part of the specification: `spec/merkle.bend`,
  `spec/progressive.bend` and the other root specs hash with it. Its byte API, which `src/`
  runs, is proved against that model inside the package. Every official root vector passing
  cross-checks the model.
- **Compilation and the host.** Only Bend terms are verified; the Bend compiler, its runtime
  (and any native build) and the machine executing them are outside the proofs.

Not trusted: the generators (`codegen/`). Every file they emit is checked, so a generator bug
shows up as a file that fails to check. What a generator does decide is which statements are
proved: the statements to review are the facades' (`proofs/api/`) and the bridges' (`e2e/`),
whose conclusions are END_TO_END's model functions and `spec/`.

The premises and runtime limits the laws are stated under are listed in [PREMISES.md](PREMISES.md); they are part of what a reader must accept.

Not in the gate (limits of what "checks" covers):

- **Laws waiting for the checker port.** The read-back laws of the <!-- fig:rigid_count -->17<!-- /fig --> array-stored collections
  (`read_set`, `read_append`, and `other_set` of the boxed lists) are proved only for the rigid checker, on the out-of-tree branch
  `agent/solid3-rigid` (`proofs/obj/tarray.bend`, `coll_seq.bend`). They are not checked by `tools/check_fast.sh` and no claim of
  this repository covers them: <!-- fig:rigid_collections -->`l8192_DepositRequest`, `l16_WithdrawalRequest`, `l2_ConsolidationRequest`, `l1048576_bl1073741824`, `l16_Withdrawal`, `l2048_Eth1Data`, `l1099511627776_Validator`, `l16777216_HistoricalSummary`, `l134217728_PendingDeposit`, `l134217728_PendingPartialWithdrawal`, `l262144_PendingConsolidation`, `l16_ProposerSlashing`, `l1_AttesterSlashing`, `l8_Attestation`, `l16_Deposit`, `l16_SignedVoluntaryExit`, `l16_SignedBLSToExecutionChange`<!-- /fig -->.
- **Fixture provenance.** The committed fixtures are tied to the pinned upstream release archives only in a gate run
  (`tools/check_fast.sh --tarballs DIR`, stamp field `fixtures_tarballs_verified`); a run without it checks them against
  `fixtures.manifest.json` only.
