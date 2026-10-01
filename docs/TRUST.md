# Trust boundary

Trusted (not proved here):

- **The checker.** Bend main 01875127 (after the v2.0.34 release; its Base is byte-identical to
  v2.0.34's) plus one commit on the fork branch Giulio2002/bend `rigid-memo`, c55a7f03 (variant B),
  compiled with Bun into a release layout (`bin/bend` + `bend2/base.bend`). The lock pins no separate Bun: the
  compiled `bin/bend` embeds the Bun runtime, so its sha256 pins that runtime too.
  `toolchain.lock.json` pins the commit and the sha256 of `bin/bend`, `bend2/base.bend` and the
  sources it was built from (`bend2/main.ts`, `bend.ts`, `comp.ts`); `tools/check.sh` and
  `tools/check_fast.sh` refuse to run on any other bytes (`tools/verify_pins.py`). This is **not
  a Bend release and not upstream code**: c55a7f03 is the second form of the change that was the
  head of bendlang/bend#1210 (45663e0a, "A copy met after an unfold converts before either copy
  unfolds"; that pull request was **closed without being merged on 2026-09-30**); c55a7f03 itself
  was **never submitted upstream**. The trust story is the same as with the #1075 build
  pinned before it: every result here rests on upstream Bend plus a conversion change that
  upstream did not merge, so a reader must trust that commit (+27/-45 lines of
  `bend2/bend.ts` against 01875127) on their own review. What it does: stock Bend compares the two sides of a
  conversion with every def rigid (nothing unfolds) once, at the top; c55a7f03 asks the same
  rigid question again (`compare_call`) at the arguments of each pair of calls of one def before the
  full pass unfolds them, marks a rigid pair found unequal on the cell (`Var.u`) so no failing walk repeats,
  and no longer lets a rigid whnf fill a shared cell. The retry adds no stack frame per level, so a
  conversion recurses as deep as on stock 2.0.34 (45663e0a had halved it, and the earlier pin aa99b746
  of the branch `rigid-subterms`, two commits, is replaced by this smaller one). Rigid equality implies
  definitional equality (the rigid book knows no def, so it only equates what the full book also equates),
  so the change can only answer "equal" earlier, never differently; a "not equal" from it falls through to the
  unchanged comparison. Without it, a conversion whose sides meet only after a def unfolds
  evaluates closed limits (2^30 bytes and above) in unary and overflows, e.g. every bridge from a
  Fulu schema def to its closed limit (`lim_sym`'s `tx_schema` overflows on stock 2.0.34 and
  checks here). Every "checks" claim in this repository means "checks under c55a7f03".
  `tools/check_fast.sh` accepts an umbrella only on the exact line `ALL PROOFS CHECK` with exit 0
  (a def that relies on unsafe or foreign code makes this checker print `SOME PROOFS FAIL`,
  "Error: N defs rely on unsafe or foreign code", exit 1). On this checker that report walks the
  whole book, imports included (a probe that only imports a file with an `@unsafe def` fails with
  "1 def relies on unsafe or foreign code"); 2.0.28's covered only the top file's defs and the
  laws. `tools/verify_no_escapes.py`, run before any check, is a second guard over every file. It bans `@unsafe`, `def f?(` and foreign bodies (`import "x.js"`) in every `.bend`
  file, in every spelling the pinned parser accepts: it lexes comments, strings and char literals
  like the parser and allows whitespace, newlines and comments wherever the parser skips them
  (`@` newline `unsafe`, `: import "x.js"` on the def's line, `import"x.js"`). Its planted cases
  run on every invocation, and `--probe` runs each positive one through the pinned checker, which
  reports all 19 as relying on unsafe or foreign code. Soundness of the result rests on this checker.
- **The checker's logic has `Type : Type`.** The pinned checker accepts `def tt() -> Type: Type`
  and `tt2(Type)` for `def tt2(T: Type) -> Type: T` (probe run on the ssz server with the earlier pin aa99b746,
  2026-09-30: "ALL PROOFS CHECK"). A type theory with `Type : Type` is inconsistent in principle (Girard's
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
- **The stack is part of the setup, not of the logic.** A check that runs out of stack fails; it never
  accepts more. `tools/check.sh` pins the limits (`ulimit -s 16384`, a JSC budget of 10 MB) so a result
  does not depend on the shell. The gate is the full check at the pin; the 5 MB "headroom" run is informational
  (it passed on one tree and failed an umbrella on the next; at 2.5 MB 13 of 46 umbrellas fail; the failure rate is not monotone
  in the budget), and docs/BUILD.md says what was measured.
- **Mutation testing shows what the statements do not pin, and only the proofs count.** The mutation evidence
  (`tests_generated/mutation_testing.py`, docs/RESULTS.md) is proof-side only: a mutant of the generated
  runtime code must make the pinned checker reject a proof. Conformance and fuzz results are triage, never
  evidence; the first runtime counts were invalid (a crashing harness counts as a kill), so every runtime-stage
  result needs its unmutated baseline passing. After four rounds of proof laws, 140 survivors of the replay and of
  one new draw are gaps (validity of fixed-size types, bounds off by one, reported sizes, packing constants,
  under-allocation); 258 are excluded: 163 with a proof-level reason (an argument the callee never reads, a flag
  read only by `is_poisoned`, an accepted set that does not change), two classes by decision (`out_at(d+1)`, the
  aligned-or-slow path) and one uncoverable. A proof stack overflow is not counted as detection.
- **`--check-only`, not `--verdict`.** Every check here runs `bend <file> --check-only`, whose
  verdict line is followed by "Use --verdict for mathematical validity.": bend2's checker
  (`bend2/bend.ts`) has no proof. `--verdict` would also elaborate every checked definition to
  BendTT (`bend2/safe.ts`) and re-check it with the kernel proved in Lean (`bend2/bendtt.lean`,
  whose claims are that no checked def has type `Empty` and that live code halts); a definition
  bend2 accepts and the kernel rejects is reported as a mismatch. That would take bend.ts, the
  rigid-memo change included, out of the trusted base, and it would bear on the `Type : Type`
  question above through the kernel's own logic. This repository does not run it: the kernel is
  built separately with Lean v4.34.0, which `toolchain.lock.json` does not pin, and its cost on a
  full check (about 5,700 files) has not been measured. So "checks" means "accepted by bend2's
  checker at c55a7f03 under `--check-only`", not the kernel's verdict.
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
  bytes are in `frozen.lock.json`), and `codegen/impl/tool_generators.py --check` reruns the three
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
  of those encoders (`X_valid` and every def it reaches, wherever it lives - another encode file, `src/model.bend`, `src/obj.bend`, through an alias or a
  chain across files - whatever the def is called, whatever the shape of the call - a chain, another
  file, a match arm, a lambda, a function value, a helper with no `->` or a wrapped signature, a helper that carries the suffix
  `_encode` or `_serialize` - the premise of the validating-serializer statements), which are
  hashed; a law's proof is told from a helper by the `law` block of its name, not by the shape of its head. So a change to a src/ def
  cannot weaken or empty a premise without changing the lock. `tools/verify_frozen.py` checks
  all of this (after planting the changes listed in its `PLANTED`, and printing how many: some must trip the lock, among them a weakened
  `Checkpoint_valid` and `u8_valid` and a change planted in each shape of helper above, and some must not: the encoder entry point, a def only
  the encoder calls and the serializer, which the proofs pin down), and that
  `memory_bench/law-statements.json` holds END_TO_END's laws verbatim. `tools/check_fast.sh`
  runs it first, so a full check never passes on changed statements.
- **SHA-256.** The BendHub package `bend-collections@1.0.0.0` = `0xd9a2fae439ac7ff9e21e0853948f94fe`
  (bend-collections' Bend 2.0.34 port), vendored whole (142 files) at `vendor/bendhub/` and pinned
  in `toolchain.lock.json` by tree hash and by its BendHub id, which `tools/verify_pins.py`
  recomputes from the files (the first 128 bits of the sha256 of its manifest), so the vendored
  copy is exactly the published package (the checks use it unless `BEND_LIB` names another, which
  must hash the same). What is trusted from it: the FIPS 180-4 model and nothing else; the
  package's own proofs are checked as part of every check that imports them. Its FIPS 180-4
  model (`spec/crypto/sha.bend`) is part of the specification: `spec/merkle.bend`,
  `spec/progressive.bend` and the other root specs hash with it. Its byte API, which `src/`
  runs, is proved against that model inside the package. Every official root vector passing
  cross-checks the model.
- **Two Bend compilers, two roles.** The proofs are checked by the pinned rigid-subterms build (aa99b746: the checker, `bend <file>
  --check-only`). The runtime evidence (conformance, fuzzing, mutation testing, the Bun tests) runs programs compiled by stock
  Bend 2.0.34 (to C, and to JS for the Bun tests), `benchmarks/toolchain.json`. They share one Base (c742fae9, byte-identical, both
  pinned by sha256) and one front end, but they are different binaries doing different jobs: the checker never compiles or runs
  anything, the stock compiler never decides a proof. That is acceptable because the two evidences answer different questions
  and neither borrows the other's trust: a proof says what the Bend terms mean under the checker's rules; the runtime evidence
  says that the code the stock compiler emits for those same sources agrees with an independent oracle. It does NOT mean that
  what the compiler emits is what the proofs are about: a miscompilation in stock 2.0.34, or a difference between the checker's
  evaluation and the compiled program's, is covered only by the differential evidence (the official vectors, the fuzzing and the
  mutation testing, all against `codegen/oracle.py`), never by a proof. The rigid-subterms change is in the checker only; the
  compiler used for the evidence is unmodified upstream.
- **Compilation and the host.** Only Bend terms are verified; the Bend compiler, its runtime
  (and any native build) and the machine executing them are outside the proofs.

Not trusted: the generators (`codegen/`). Every file they emit is checked, so a generator bug
shows up as a file that fails to check. What a generator does decide is which statements are
proved: the statements to review are the facades' (`proofs/api/`) and the bridges' (`e2e/`),
whose conclusions are END_TO_END's model functions and `spec/`.

The premises and runtime limits the laws are stated under are listed in [PREMISES.md](PREMISES.md); they are part of what a reader must accept.

Not in the gate (limits of what "checks" covers):

- **Fixture provenance.** The committed fixtures are tied to the pinned upstream release archives only in a gate run
  (`tools/check_fast.sh --tarballs DIR`, stamp field `fixtures_tarballs_verified`); a run without it checks them against
  `fixtures.manifest.json` only.
