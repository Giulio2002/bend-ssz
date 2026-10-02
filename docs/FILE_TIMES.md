# Files over 120 s: documented exceptions

Every file should check in under 120 s on a quiet server (tools/check.sh: 12 GB, 2 CPUs). The composed
end-to-end files below do not, and cannot without changing a frozen statement. Seconds are single-file
checks from the file-times sweep on a loaded server (load 15-40; a quiet server is roughly 1.3x faster),
except where marked (own run).

| File | Seconds | What dominates | Why it cannot go lower without a frozen change |
|---|---|---|---|
| e2e/FuluBeaconState_e2e_comp_generated.bend | 203 (228 own run, before the dbs split: 317) | union of its imports: dec (DB, 59 s), root (RB, 47 s), the encode bridge (EB, 103 s), decrep (~122 s) | EB is the locked encode bridge (statement_defs); DB/RB/decrep are premises the composed theorem names. The proof of `p_rep` itself costs about 0 s |
| e2e/FuluBeaconState_e2e_decrep_generated.bend | 111 (own run ~122 after the split, before ~152) | drl_* list modules, dfx, DB | the rep-invariant premises name these modules |
| e2e/FuluBeaconBlock_e2e_decrep_generated.bend | 333 | e2e_dbk (186 s) = e2e_dbb (169 s) + 17 s; dbb = e2e_rec_BeaconBlockBody (150 s) + small | e2e_rec_* are locked (`statement_defs`): the record and its imports (bbsl 52, bbatt 43, epr 36, ml_* 30 each, encx_* 36-40) are what the statements reach |
| e2e/FuluBeaconBlock_e2e_comp_generated.bend | 488 | union of decrep (333), dec (187), EB, RB | as above, plus the locked encode bridge EB |
| e2e/FuluBeaconBlockBody_e2e_decrep_generated.bend | 295 | e2e_dbb / e2e_rec_BeaconBlockBody | locked record module |
| e2e/FuluBeaconBlockBody_e2e_comp_generated.bend | 366 | decrep + dec + EB + RB | locked record module and EB |
| e2e/FuluSignedBeaconBlock_e2e_decrep_generated.bend | 252 | e2e_rec_SignedBeaconBlock plus the Block record | locked record modules |
| e2e/FuluSignedBeaconBlock_e2e_comp_generated.bend | 286 | decrep + dec + EB + RB | locked record modules and EB |

Generator-only cuts applied so far (statements and frozen.lock.json unchanged): the BeaconState premise
lemmas that name EB moved out of e2e_dbs.bend into e2e_dbs_sz.bend (e2e_dbs 117 s to 33 s), and p_hZ of
the BeaconState decrep moved into its own module. They do not apply to the Block family: its decrep does
not import EB at all; its cost is the locked record modules.
