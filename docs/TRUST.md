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
  checker's "All terms check, but N defs rely on unsafe or foreign code"). That report covers only
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
- **The frozen specification.** `spec/*.bend` (an independent transcription of
  `vendor/consensus-specs/ssz/simple-serialize.md`, mapped in `spec/CORRESPONDENCE.md`),
  `spec/fulu_schemas.bend` and `schemas/fulu_mainnet.json`, and the statements of
  END_TO_END.bend, ROOT_DOMAIN.bend, PROOF.bend and HASH_PROOF.bend. These are reviewed, not
  proved; the generators never write them. `frozen.lock.json` records the sha256 of every spec
  file (and the representations and normative sources it rests on), of the four roots'
  statement text (proof bodies excluded), of `types/fulu_model.bend` and
  `proofs/obj/generic_specs.bend` (what END_TO_END's per-name laws and the generic bridges
  quantify over), and, per file, of every bridge statement and every definition it reaches
  outside `src/`, `types/`, `spec/` (the object views, `rep` invariants and their helpers); `tools/verify_frozen.py` checks it, and that
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
