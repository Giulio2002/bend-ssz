# Trust boundary

Trusted (not proved here):

- **The checker.** Bend main 01875127 (after the v2.0.34 release; its Base is byte-identical to
  v2.0.34's) plus two commits on the fork branch Giulio2002/bend `rigid-subterms`, 45663e0a and
  aa99b746, compiled with Bun 1.4.2 into a release layout (`bin/bend` + `bend2/base.bend`).
  `toolchain.lock.json` pins the commit and the sha256 of `bin/bend`, `bend2/base.bend` and the
  sources it was built from (`bend2/main.ts`, `bend.ts`, `comp.ts`); `tools/check.sh` and
  `tools/check_fast.sh` refuse to run on any other bytes (`tools/verify_pins.py`). This is **not
  a Bend release and not upstream code**: the branch is that of bendlang/bend#1210 ("A copy met
  after an unfold converts before either copy unfolds"), and that pull request was **closed
  without being merged on 2026-09-30**. The trust story is the same as with the #1075 build
  pinned before it: every result here rests on upstream Bend plus a conversion change that
  upstream did not merge, so a reader must trust those two commits (about 70 lines of
  `bend2/bend.ts`) on their own review. What they do: stock Bend compares the two sides of a
  conversion with every def rigid (nothing unfolds) once, at the top; 45663e0a asks the same
  rigid question again at each pair of calls of one def before the full pass unfolds them,
  remembers the cell pairs those walks compared, and no longer lets a rigid evaluation fill a
  shared cell; aa99b746 keeps that memo off the full pass's recursion, so a conversion recurses as
  deep as on stock 2.0.34 (45663e0a had halved it). Rigid equality implies definitional equality
  (the rigid book knows no def, so it only equates what the full book also equates), so the change
  can only answer "equal" earlier, never differently; a "not equal" from it falls through to the
  unchanged comparison. Without it, a conversion whose sides meet only after a def unfolds
  evaluates closed limits (2^30 bytes and above) in unary and overflows, e.g. every bridge from a
  Fulu schema def to its closed limit (`lim_sym`'s `tx_schema` overflows on stock 2.0.34 and
  checks here). Every "checks" claim in this repository means "checks under aa99b746".
  `tools/check_fast.sh` accepts an umbrella only on the exact line `ALL PROOFS CHECK` with exit 0
  (a def that relies on unsafe or foreign code makes this checker print `SOME PROOFS FAIL`,
  "Error: N defs rely on unsafe or foreign code", exit 1). That report covers only
  the top file's defs and the laws, so in an umbrella (which only imports) an unsafe dependency of
  a bridge def would not show; the guard for every def is `tools/verify_no_escapes.py`, run before
  any check. It bans `@unsafe`, `def f?(` and foreign bodies (`import "x.js"`) in every `.bend`
  file, in every spelling the pinned parser accepts: it lexes comments, strings and char literals
  like the parser and allows whitespace, newlines and comments wherever the parser skips them
  (`@` newline `unsafe`, `: import "x.js"` on the def's line, `import"x.js"`). Its planted cases
  run on every invocation, and `--probe` runs each positive one through the pinned checker, which
  reports all 19 as relying on unsafe or foreign code. Soundness of the result rests on this checker.
- **The checker's logic has `Type : Type`.** The pinned checker accepts `def tt() -> Type: Type`
  and `tt2(Type)` for `def tt2(T: Type) -> Type: T` (probe run on the ssz server with aa99b746,
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
  the model API `src/model.bend` (which END_TO_END's laws pin down). So a change to a src/ def
  cannot weaken or empty a premise without changing the lock. `tools/verify_frozen.py` checks
  all of this (after planting four changes, three that must trip the lock and the encoder, which
  must not), and that
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
- **Compilation and the host.** Only Bend terms are verified; the Bend compiler, its runtime
  (and any native build) and the machine executing them are outside the proofs.

Not trusted: the generators (`codegen/`). Every file they emit is checked, so a generator bug
shows up as a file that fails to check. What a generator does decide is which statements are
proved: the statements to review are the facades' (`proofs/api/`) and the bridges' (`e2e/`),
whose conclusions are END_TO_END's model functions and `spec/`.

The premises and runtime limits the laws are stated under are listed in [PREMISES.md](PREMISES.md); they are part of what a reader must accept.
