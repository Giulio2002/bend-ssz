# Trust boundary

Trusted (not proved here):

- **The checker.** Bend 2.0.28 with bendlang/bend#1075 and its budget fix, commit 3ddfb036 of
  bendlang/bend, run on Bun 1.4.2. `toolchain.lock.json` pins the commit and the sha256 of every
  file the checker runs (`bend2/main.ts`, `bend.ts`, `comp.ts`, `base.bend`) and of the Bun
  binary; `tools/check.sh` and `tools/check_fast.sh` refuse to run on any other bytes
  (`tools/verify_pins.py`). #1075 compares syntactically identical terms before
  normalizing them; without it, some closed facts (limits of 2^30 bytes and above) would be
  evaluated in unary and not finish. Soundness of the result rests on this checker.
- **The frozen specification.** `spec/*.bend` (an independent transcription of
  `vendor/consensus-specs/ssz/simple-serialize.md`, mapped in `spec/CORRESPONDENCE.md`),
  `spec/fulu_schemas.bend` and `schemas/fulu_mainnet.json`, and the statements of
  END_TO_END.bend, ROOT_DOMAIN.bend, PROOF.bend and HASH_PROOF.bend. These are reviewed, not
  proved; the generators never write them. `frozen.lock.json` records the sha256 of every spec
  file (and the representations and normative sources it rests on) and of the four roots'
  statement text (proof bodies excluded); `tools/verify_frozen.py` checks it, and that
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
