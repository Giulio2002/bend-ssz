# Working on bend-ssz (agents read this first)

## Be impatient: keep the loop fast

Slow iteration is the most expensive bug in this project. Proof checking, regeneration and queueing can turn a
one-line fix into an hour and a half. Treat that as a defect to fix, not something to wait out.

**Rule.** Whenever proof checking (or the regenerate / check / queue steps around it) is more than half of an
iteration, or one iteration takes more than about five minutes, stop the feature work and optimize the tooling
first. Report before and after in seconds.

**The loop, cheapest first:**
1. Regenerate only what you changed: `python3 codegen/regen_all.py --only <generator>[,<generator>]`. The full
   `regen_all.py` repeats up to 16 fixpoint passes (e2e_compose alone is 120 s per pass); never use it in the loop.
2. Check the single file you touched, on the server: `tools/check.sh <file.bend>` (about 1 to 3 minutes). No lock.
3. Only when the single files pass, run one full check for the batch of fixes:
   `flock /srv/ssz-optimization/agents/.fullcheck.lock tools/check_fast.sh --jobs 12 --no-localize --out <dir>`.
   `--no-localize` skips bisecting failed groups, which cost 805 s on top of a 453 s run. Read the failing umbrella
   log directly. Use `--files <list>` for a partial run while iterating.
4. Localization (drop `--no-localize`), strictcheck and the recorded stamp are for the final gate only.

**Other levers, in order of payoff:**
- A full run takes as long as its slowest umbrella (the FuluBeaconState witness is 431 s, the block witnesses
  170 to 185 s). Split or trim the slowest file rather than adding more jobs.
- Make generators idempotent: if `regen_all.py` needs more than two passes, two generators undo each other's output.
- A module cache or any incremental checker may be used in the dev loop only. It never counts for a gate, a stamp
  or a claim, and the docs must say so.
- One-at-a-time locks are for full runs only. Single-file checks run freely within the memory caps.

**Proofs that check fast.** Bend's `Nat` is unary: comparing two spellings of a large number makes the checker
recurse once per unit, and deep recursion overflows the stack, sometimes only under load (the pin, 16384 KB of
stack and 10 MB for the JavaScript engine, gives about 58,600 levels; 5 MB about 28,800, where one umbrella failed on one tree; 2.5 MB about 14,100,
where 13 of 46 umbrellas fail). So:
state each big constant once, keep sizes symbolic (a variable, never `Nat.add(0n, 524464)` on a literal start),
reach large literals through an equality test (`Nat.is_eq`) instead of a conversion, put the small operand first
in additions (`Nat.add` recurses on its first argument), and prove a bound from a 32-bit equation and an existing
lemma instead of evaluating the limit. Keep every conversion far below the limit: the gate is the full check at the pinned budget (docs/BUILD.md); the run at
half the budget is informational and does not always pass, so shallow proofs are what keep a result stable.

**Never trade soundness for speed.** These shortcuts change how you iterate, not what counts as checked. The final
gate stays the full check with localization, every pinned tool, no cache, and strictcheck.

## Standing rules

- Nothing heavy on the laptop: no bend, bun, regen_all, generator `--check` or whole-tree verifier. Use the server
  (root@build-server.example, /srv/ssz-optimization/agents) with `nice -n 10`, memory caps and timeouts.
- Generated files change only through their generators. Never edit `spec/`, `schemas/`, END_TO_END, ROOT_DOMAIN,
  PROOF, HASH_PROOF, `law-statements.json` or `frozen.lock.json` except for a deliberate, announced change. Never
  weaken a law.
- Never patch or fork Bend for the proofs; the pinned checker is listed in `toolchain.lock.json`.
- Kill only your own PIDs. Never `pkill` by name; never `rm` with wildcards outside your own directories.
- Deliver on branches and merge through the coordinator; do not push to main.
