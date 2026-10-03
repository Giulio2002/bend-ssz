# Removing the 2^31 byte limit (CH-02, CH-07, R3-03): design and spike

## Where the limit lives
* The size pass is fused with validity: every writer returns a U32 count whose bit 31 means "invalid", and the cursors add with `O.padd`
  (`(a + b) | ((a | b) & 2^31)`); `O.is_poisoned(m) = 2^31 <= m`; `O.pz(ok)` is 0 or 2^31. So a valid size is at most 2^31 - 1 (CH-07), `_encode`
  allocates from the marker of an invalid object (CH-02), and `n * es` is plain U32 multiplication in `szf`, `va_cap`, `pt` (R3-03).
* The proofs carry the same bound in four forms: `O.padd` is reasoned about only for sums below 2^31 (`proofs/obj/venc.bend` `padd_ok` on `Word(31n)`,
  `vcont.bend` `padd_dd` / `padd_ddW`); 180 files state `VB.pw(31n)` (the BeaconState encode theorem's `hZ`, the byte-list `hm*` premises); 53 files use
  `Word(31n)`; output-buffer depths are `dd < 29` / `dd < 31` throughout (`encx_*`, `container_encoder_*`). 1385 files print the literal 2147483648.

## Options
(a) Marker 0xFFFFFFFF with saturating `padd` (`a + b` if it does not wrap and is below the marker, else the marker). Valid sizes up to 2^32 - 2; the existing
    `NMAX = 2^32 - 32` premises (chunk rounding) are then the real limit, so every size the theorems already allow is representable. The writers' flag
    propagation `voff | O.pz(valid)` keeps working unchanged (OR with all ones is the marker); the fixed-type case `voff & 2^31` becomes `voff & marker`.
    n * es: `szf` / `va_cap` test `n <= (2^32 - 2) / es` (a literal per type), so the product never wraps and the marker is never produced by a valid size.
(b) A separate validity flag next to the size: every writer, cursor, `pk`, `putk`, `senc` and ~1000 lemma statements change type (a pair per call). Largest churn.
(c) U64 sizes with the marker outside 32 bits: removes the wrap entirely, but offsets/positions are U32 words in the arrays, every `pos + i * es` and every
    `U32.to_nat(O.padd ..)` lemma changes type, and Bend U64 is a pair of U32 (carry code in every cursor). Second largest churn, slower code.

## Choice: (a)
Least proof churn and no new types. The proof work splits in two:
1. Implementation (generators only): marker and `padd` in `src/obj.bend`; five marker literals in `typed_object_runtime.py`; checked `n * es`; the decode window limit
   `size < 2^31` becomes `size <= 4294967264`; `_encode` / `_serialize` refuse before allocating (`ser_done` / `senc_go` already test `is_poisoned`, so the marker
   test is the only change); the append bounds go back to `min(limit, floor((2^32 - 2) / es))` (the type's limit, and total size below 2^32 - 1).
2. Proofs: re-prove `padd_ok` (and `padd_dd`, `padd_ddW`) for the saturating definition, then lift the bounds `pw(31n)` to the `NMAX` bound and `dd < 29 / 31` to the depth
   of a 2^32-byte buffer (`dd < 31` already covers 2^32 bytes), `Word(31n)` lemmas to `Word(32n)`. These are the premise changes the coordinator approved (they remove
   the 2^31 restriction and match the existing frozen premises); no theorem is weakened.

## Spike (tree 5e05b78b2 + the implementation part of step 1 only, regenerated with `--only typed_object_runtime,runtime_file_split`)
* Source change: 11 lines in `src/obj.bend` (poison, pz, padd, is_poisoned, two size pickers), 6 literals in the runtime generator.
* Regeneration touched 411 files (every type that has a size pass).
* Proof check on the unchanged proofs: `venc.bend`, `vcont.bend`, `vconts.bend` and the `encx_*` list files fail at once (2.3 to 5.6 s each; they stop at `padd_ok`, whose statement
  still names the old definition). The closure of `venc.bend` is the whole encoder family (134 `encx_*` files plus the e2e / api files), so the first re-proof of `padd_ok`
  (a ~25-line Nat proof: no wrap, `a <= a + b`, `a + b < marker`, all from `U32.is_lt_nat` / `u32__pow2u_value`, no big-literal comparison) is the gate for everything else.
* Not measured yet: the lifted bounds. Estimate from counts: 180 + 53 files by generator (templates `*.tpl`, `beacon_state_encode_record.py`, `container_encoder_*`), each re-proved by
  regeneration; the BeaconState size and window files are the ones at risk for the 2 minute limit (they are 145 to 175 s today only for the block family).

## Status
Done on `agent/size-limit` (devtools-sl on gate.git): marker 4294967295, saturating `padd`, `O.mulc` (checked `n * es`), `out_donem` (CH-02), the decode limit
`size <= 4294967264`, the append bounds at floor(NMAX / element size), all generated outputs regenerated, the proofs lifted from `2^31` to `NMAX` (changed statements:
docs/size_limit_statement_diff.md), regress cases 46-57, laws that compute on the generated writers (`proofs/slop/validity/*_marker_poison_generated.bend`,
`crash_fix_laws`). Documented exception: the DECODE side of the progressive record-list families keeps its `len < 2^31` window facts (section 4 of the diff document).
R3-03 (a wrapped `n * es`), CH-02 and CH-07 are closed.
