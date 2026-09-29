# Trust boundary

Trusted (not proved here):

- **The checker.** Bend 2.0.28 with bendlang/bend#1075 and its budget fix, run on Bun
  (`tools/check.sh` runs it; the toolchain path comes from `BEND_TOOLCHAIN`). #1075 compares syntactically identical terms before
  normalizing them; without it, some closed facts (limits of 2^30 bytes and above) would be
  evaluated in unary and not finish. Soundness of the result rests on this checker.
- **The frozen specification.** `spec/*.bend` (an independent transcription of
  `vendor/consensus-specs/ssz/simple-serialize.md`, mapped in `spec/CORRESPONDENCE.md`),
  `spec/fulu_schemas.bend` and `schemas/fulu_mainnet.json`, and the statements of
  END_TO_END.bend, ROOT_DOMAIN.bend, PROOF.bend and HASH_PROOF.bend. These are reviewed, not
  proved; the generators never write them.
- **SHA-256.** The BendHub package `0xe4067e0d858024083f36a7abe7281e89` (bend-collections),
  whose byte API is proved against its own vendored FIPS 180-4 model.
- **Compilation and the host.** Only Bend terms are verified; the Bend compiler, its runtime
  (and any native build) and the machine executing them are outside the proofs.

Not trusted: the generators (`codegen/`). Every file they emit is checked, so a generator bug
shows up as a file that fails to check. What a generator does decide is which statements are
proved: the statements to review are the facades' (`proofs/api/`) and the bridges' (`e2e/`),
whose conclusions are END_TO_END's model functions and `spec/`.

The premises and runtime limits the laws are stated under are listed in [PREMISES.md](PREMISES.md); they are part of what a reader must accept.
