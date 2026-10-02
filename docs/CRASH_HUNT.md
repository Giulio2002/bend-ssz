# Crash hunt: can the typed object API be made to crash?

Auditor: agent/crash-hunt (off origin/main b1764b5a8). Rule under test: the library must never crash. Every public entry point
(`<Name>_decode`, `_ok`, `_encode`, `_serialize`, `_hash_tree_root`, constructors, getters, setters, list `_append`, the `O.*`
runtime) must return a value or an error value for every input a caller can construct. No library file was changed; the
frozen files (`spec/`, `schemas/`, END_TO_END, ROOT_DOMAIN, PROOF, HASH_PROOF, `frozen.lock.json`, `law-statements.json`) are untouched.
Machine-readable list: `docs/crash_hunt_findings.json`. Raw outputs: `docs/crash_hunt_evidence/`. Probes and runners: `tools/crash_hunt/`.


Later passes: section 6 (agent/crash-fix2: CH-03 fixed, CH-02 and CH-06 measured), the round-2 hunter report (R2.1 to R2.3) and
section 7 (agent/crash-fix3: R2-01 to R2-06, CH-11, CH-12) update the table below.

## 0. Status after the fix series (agent/crash-fix)

| finding | status | what changed | regression |
|---|---|---|---|
| CH-01 | FIXED (statements and lock moved, authorized: docs/crash_hunt_statement_diff.md) | the cell list's setter and appender refuse a cell whose length is not 2048 (guard and `words_blit` on an empty source) | `regress.sh` cases 1-5; `proofs/slop/crash/` laws; regenerated `l4096_b2048_api_*` statements |
| CH-02 | NOT FIXED, blocked by the statement rule (exact reason in section CH-02 below) | `_encode` has the precondition `X_valid(o)`; `_serialize` refuses before allocating. Any guard on the size pass answer falsifies a frozen END_TO_END encode theorem for objects of 2^31 .. 2^32 - 32 bytes | - |
| CH-03 | FIXED (`src/obj.bend` moved, statements unchanged) | every root clamps its chunk count to the storage: `O.cap_cnt`; identical root for every storage-valid object (proved), work bounded by the allocation for an invalid one | `regress.sh` cases 13-14; `proofs/obj/words_cap.bend` |
| CH-04 | FIXED (statements and lock moved, authorized) | `n + 1 <= N` became `n < min(N, 2^32 - 1)` for every list that can reach 2^32 - 1 | `regress.sh` cases 6-8; `proofs/slop/crash/` laws; regenerated `*_api_append_*` statements |
| CH-05 | FIXED in the checked entry | `X_decode_checked` refuses a window of 2^31 bytes or more; `_decode` itself is unchanged (its statements are frozen and it is the subject of the decode bridges) | `regress.sh` case 11; slop law `decode_checked_2gib_refused` |
| CH-06 | FIXED in the checked entry; `_decode` itself NOT changed (measured, section 6) | `X_decode_checked(buf, size)` refuses `size > B.size(buf)`; `X_decode` keeps its precondition (every decode statement is over `(buf, n)` with the buffer of size n, and a refusing `_decode` would need `n <= n` at every symbolic n) | `regress.sh` cases 9-10; slop laws |
| CH-07 | DOCUMENTED | the 2^31 byte size limit is part of the contract (docs/API_CONTRACTS.md) | - |
| CH-08 | DOCUMENTED | `_hash_tree_root` precondition `X_valid(o)`; no error channel | - |
| CH-09 | DOCUMENTED | `_build` / `_read` are unchecked by design (precondition `_ok`), with `_decode_checked` as the safe entry | - |
| CH-10 | FIXED | see section 2, CH-10 | `regress.sh` case 12; slop laws |

Reproduce the fixed behaviour: `tools/crash_hunt/regress.sh` (server). Sections 1-5 below are the hunter's report as filed.

## 1. Result in one page

| | |
|---|---|
| Findings | **9** (1 high, 3 medium, 4 low, 1 info) |
| CRASH (abort / OOM-class allocation / time blowup on a tiny object) | **3** (CH-02, CH-03, CH-09) |
| WRONG (accepts or returns a wrong value silently) | **5** (CH-01, CH-04, CH-05, CH-06, CH-07) |
| INFO (returns a value for an out-of-domain object; no error channel) | **1** (CH-08) |
| Hostile bytes through `_decode` (240 names, 40,508 runs, byte-level mutators, accepted inputs re-encode byte for byte) | **0 crashes, 0 wrong** |
| Mutation driver with extreme indices and seeds (set_elem / append / set_field, 10,656 runs) | **0 crashes, 0 wrong** |
| Large and wide inputs (up to 128 MiB, 1,048,576-element count bomb) | linear time and memory, 0 crashes |
| Cached-root API against the plain root (n = 0..16, growth through capp, past the limit, index 2^32-1) | all equal, 0 crashes |

The decoder side is solid: nothing a caller can put in a byte buffer of ordinary size crashes it or is accepted wrongly. Every
finding is on the object side (objects built by constructors or setters) or at the U32 size limits (inputs of 0.5 to 4 GiB). The one
finding a plain caller of a **checked setter** can hit with ordinary values is CH-01.

Not a finding: `Array.get/set` mask out-of-range indices (src/buffer.bend says so), so no out-of-range read or write ever aborts;
what they can do is alias, which is how the WRONG results below arise. There is no pop / remove / truncate API (grep of the
generator: 0), so there is no empty-list pop to underflow. Division is only by constants or by `4*ew`, `unit` (>= 1).

## 2. Findings, ranked

### CH-01 (HIGH, WRONG with a 2^32-iteration loop): `List[Cell, 4096]` setter and append copy by the length of the argument
Entry points: `Fulu_list_bytevec_2048_4096` `l4096_b2048_set(o, i, v)` and `l4096_b2048_append(o, v)` (the `column` field of `DataColumnSidecar`).
The element type is `O.Words`; the setter checks the index and the limit but not `v`'s length. `O.words_blit` (src/obj.bend:1354) copies
`(v.n + 3) >> 2` words and computes its loop count as `((v.n + 3) >> 2) - 1`.
* `v.n = 0`: the count underflows to 2^32 - 1, the loop runs 4 billion times (3 s native), writing around the whole storage; flag returned 1.
* `v.n = 4096` into index 1 of a 2-cell list whose storage is exactly 4096 bytes: the copy runs past the element and **wraps onto element 0** (read back: `cell_w0=4294967295`, flag 1).
* `v.n = 64`: a partial copy, flag 1; the old bytes of the cell stay.
Repro: `SSZ_CASE=1|2|3|4 build/ch/pa` (probe A, `tools/crash_hunt/pa_objects.bend`); results in `out2_pa_summary.txt` lines "case 1" to "case 4".
Why: the checked setter's guard is only `i < len`; `words_blit` trusts the source length. Every other vector element setter takes a typed record (`Bytes32_into_words`) and cannot hit this.
Fix (generator `codegen/impl/typed_object_runtime.py:703-704, 737`): (a) guard: `put_at` takes `Bool.and(U32.is_lt(i, n), U32.is_eq(v_len, es))` with `v_len` from `O.words_len(v)`; (b) harden `O.words_blit` to copy exactly `es/4` words (pass the word count as a constant; no `n - 1` underflow).
Proof impact: the guard text of the setter and append is stated by the generated collection laws (`proofs/obj/coll_api_*`, the `bytevec_2048_4096` instance of `set`/`append`, "the flag returned is exactly that guard"); they are regenerated from the same generator text and the new conjunct is part of the stated guard. Those are listed public statements in `e2e/STATEMENTS.txt`, so the lock needs a deliberate refresh for that one collection; no other name is touched. Fix (b) alone changes no statement but does not stop the wrong-size acceptance.

### CH-02 (MEDIUM, CRASH: disproportionate allocation): unchecked `_encode` allocates the poison size
Entry points: `<Name>_encode(o)` for every non-literal-depth variable-size name (e.g. `proglist_uint8_encode`).
Input: `proglist_uint8_encode(O.Words{Array.new(U32,2n,0), 1000})` (a 16-byte object claiming 1000 bytes). The size pass returns `2^31` ("storage cannot hold the length", `O.words_sizek`), and `enc_sized` hands that to `O.out_new`, which **allocates 2 GiB** (`encode_size=2147483648`, 1 s). For a claim of 2^32 - 1 bytes, `B.zeros_bytes` computes `(n + 3) >> 2 = 0` and returns a one-word array under a buffer that says 4,294,967,295 bytes (`encode_size=4294967295`).
Repro: `SSZ_CASE=7 SSZ_ARG=1000|4294967295 build/ch/pa`. Chain: `X_encode` -> `X_enc_sized(X_size(o))` -> `O.out_new(n)` (src/obj.bend:690, src/buffer.bend:401).
Why: only the serialize variant (`senc_go`) tests `O.is_poisoned(n)` before allocating; the plain encode variant (emit_api, `typed_object_runtime.py:3098-3128`) does not. `_serialize` is safe (refused, case 5 and 10).
Fix: in the plain `enc_sized` branch, test `O.is_poisoned(n)` first and return `B.empty()`-sized output (or make `_encode` undefined-by-contract and document it; the code already documents `_serialize` as the checked entry).
Proof impact: the `_e2e_encode` bridges are stated under `rep`; an added `is_poisoned` branch needs the bound "size < 2^31" that the bridges do not state today (PREMISES.md section 1 notes the missing bound for the writers). Medium to high effort, so the contract option (documentation, no code change) is the cheap one.

### CH-03 (MEDIUM, CRASH: time blowup from a tiny object): `_hash_tree_root` does work proportional to the claimed length
Entry points: `<Name>_hash_tree_root(h, o)` for every name holding `O.Words` or `O.Bits`.
Input: `proglist_uint8_hash_tree_root(h, O.Words{Array.new(U32,2n,0), n})`: n = 10^6: 0 s; 10^8: 2 s; 2^30: 19 s; 2^32 - 1: **75 s** (probe case 6). Bit list claiming 2^32 - 1 bits: 10 s (case 11). Output is a value (a root of masked reads), so this is a hang-class result on a 16-byte object, not a wrong-value finding.
Repro: `SSZ_CASE=6 SSZ_ARG=4294967295 build/ch/pa`. Chain: `X_hash_tree_root` -> `X_root` -> `O.words_root` (src/obj.bend:897) -> `mtree` over `chunks_of(n)` leaves reading masked words.
Why: `chunks_of(n)` is taken from the claimed length; the storage is never consulted (the invariant "bytes past the end are zero, room for whole chunks" is assumed).
Fix: clamp the chunk count in `words_root`, `words_root_prog`, `bits_root`, `bits_root_prog`, `elems_root(_prog)` to the storage capacity (`min(chunks_of(n), cap_words / 8)`); words beyond the capacity are zero by the invariant, so the value for every valid object is unchanged and the work is bounded by the allocation.
Proof impact: the root laws (`proofs/obj/root_*`, `words_root` unfolds) assume `rep`; the clamp is `Nat` arithmetic that equals `chunks_of(n)` under `rep` (capacity >= chunks): one extra equation per law family, no statement changes.

### CH-04 (MEDIUM, WRONG, reachable from a valid 512 MiB input): bit list length wraps at 2^32 - 1
Entry points: `progbitlist_append` (`pbits_append`), and for every finite bit list `bitsN_append` through `n + 1 <= N`.
Reproduced two ways: (a) a **valid** 536,870,912-byte progressive bit list decodes to 4,294,967,295 bits (the largest the decoder accepts: `len - 1 < 2^29`), and `pbits_append` returns flag 1 and a list of **0 bits** (probe C case 3: `append_ok=1 bits_after=0`); (b) `Bitlist[2048]` object claiming 2^32 - 1 bits: `bits2048_append` returns flag 1, length 0 (probe A case 9). The same `(n + 1 : U32)` guard exists for the byte-list append of progressive lists (`pl_u8_append` at a claimed 2^32 - 1: flag 1, case 14).
Chain: `pbits_append` -> `pbits_app_n` (guard `True{}` for no limit) -> `pbits_push` -> `O.bits_push` (src/obj.bend:1303: `bits_set(bits_of_words(k + 1 ...), k, v)` with k + 1 = 0).
Fix (generator `typed_object_runtime.py:739, 796, 870, 1980`, the `within("(n + 1 : U32)", limit)` guards): finite limit: `U32.is_lt(n, N)` instead of `n + 1 <= N`; no limit: `Bool.not(U32.is_eq(n, 4294967295))` (and for words lists `n + 1 <= 2^32 - 1` in bytes). Same in `grow`'s `(n + 1) * es`.
Proof impact: the stated guard of `C_append` changes form (equivalent for n < 2^32 - 1); the coll_api append laws are regenerated from the generator text; the equivalence `n + 1 <= N <=> n < N` for `n + 1` without wrap is one lemma; for the no-limit lists the guard stops being the constant True (laws state "flag = guard", so they follow). Lists below 2^32 - 1 elements behave identically.

### CH-05 (LOW, WRONG): byte-list decode of 2^32 - 31 .. 2^32 - 1 bytes accepts and returns garbage
`proglist_uint8_decode` (and every big byte or packed list: `Fulu_list_uint8_2^40`, `proglist_*`) on an input of 4,294,967,280 bytes returns `Some` with `len = 4294967280`, but `zeros_for` / `depth_for` compute `(n + 31)` mod 2^32 and allocate 8 words, and `copy_into` computes `(n + 3) >> 2 = 0` words for the last three sizes; the decoded object keeps the length and loses the data (probe C case 1: sizes 4294967295 and 4294967280 both `decode=some`; 4294967264 needs the 4 GiB copy and ran out of memory at the 11 GiB test cap, which is expected). Needs an input within 31 bytes of 4 GiB.
Chain: `X_decode` -> `X_ok` (big list: no upper bound) -> `X_read` -> `O.copy_in` / `O.zeros_for` (src/obj.bend:50-56, 354). Same wrap in `B.alloc`, `B.zeros_bytes`, `B.capacity` (src/buffer.bend:209, 401, 522), reachable through `O.words_new(n)`.
Fix: compute the ceilings without wrap as `bits_nbytes` already does (`(n >> 5) + ((n & 31) + 31 >> 5)`), or the minimal change: `_ok` of the big lists adds `U32.is_le(len, 4294967264)`.
Proof impact: the size-ceiling lemmas for `zeros_for` / `copy_in` are stated under `n < 2^31` ("depth below 31"); the wrap-free form equals the old one there. The `_ok` conjunct for big lists changes the `l*_ok` statements of 6 names (decode witnesses `isS(X_decode(...))` are for small inputs and still hold).

### CH-06 (LOW, WRONG): `_decode` does not check `size` against the buffer
`FuluCheckpoint_decode(B.empty(), 40)` returns `Some` (probe B case 1): the 40 bytes are read from a one-word array through the index mask (the word repeated). Any `size` larger than `B.size(buf)` is accepted over aliased garbage; with a huge `size` and a tiny buffer the validator also loops `size / elem` times.
Chain: `X_decode(buf, size)` (typed_object_runtime.py:3041) -> `X_ok(buf, 0, size)`. The buffer carries its own size; the second argument is redundant.
Fix: `X_built` / `X_decode` add `U32.is_le(size, B.size(buf))` (one `B.size` threading step) and return `None` otherwise.
Proof impact: the decode bridges (ii)/(iii) and `X_e2e_decode_witness` take buffers made by `alloc(n)` with `size = n`; the new conjunct is `n <= n`, so every witness still evaluates; the general decode bridges quantify over `(buf, n)` and need the premise `n <= size(buf)` (one hypothesis per bridge, or derive it from `alloc`).

### CH-07 (LOW, WRONG): objects of 2 GiB or more are refused, composite lists wrap silently
`proglist_uint8_serialize` of a valid 2,147,483,647-byte list returns ok; of a valid 2,147,483,648-byte list returns **refused** (probe A case 15): bit 31 of a size is the "invalid" marker (`O.poison`, `padd`), so a valid encoding of 2^31 bytes or more cannot be produced. For a list of fixed-size composites `n * 121` etc. is computed in U32 without the marker (`l*_szf: pick(n <= cap, n * es, poison)`): at n * es >= 2^32 the size silently wraps (reasoned from the code; it needs a 4 GiB object and was not run).
Fix: widen the size pass to a second word or return a flag beside the size; or document the 2^31 limit and make `_serialize` fail closed for `n * es >= 2^32` (an `is_le(n, 2^32 / es)` test next to the capacity test).
Proof impact: the writer-size bound is already an open item (PREMISES.md section 1, "no law states ... a bound on the size the writer returns"); the fix makes it explicit. Low for the proofs, medium for the code.

### CH-08 (INFO): `_hash_tree_root` has no error channel and hashes out-of-domain objects
`SmallTestStruct{70000, 5}` (uint16 field 70000) gives a root different from the one of 4464 (probe B cases 2, 3): the field is hashed as a 32-bit chunk, no error. `ContributionAndProof` with an empty box (`BNone`) hashes the box as the zero chunk, but the root of the default box is different (cases 6, 7); `_encode` writes the default for it. `_serialize` refuses both (case 4, and the existing `box_empty`). By design the checked entry is `_serialize` / `_valid`; reported so the contract is explicit.
Proposed: a `_hash_tree_root_checked` returning `Maybe` from `_valid`, or a documented precondition `X_valid(o)` on `_hash_tree_root`.

### CH-09 (LOW, CRASH by contract): the unchecked reader `_read` / `_build` aborts on hostile bytes
`X_build(buf, size)` / `X_read` are public symbols (emit_api) and are the half of decode that runs after `X_ok`. On 4 bytes `FC FF FF FF` the list reader for `List[Attestation, 8]` takes the count from the first offset (2^30), and every `first` word of 4096 or more ends in `bend: out of memory` after 11 to 33 s (probe E; `first = 4` and `8` are fine). Not reachable through `_decode`, which validates first.
Fix: do not export `_build` / `_read` (rename `_unchecked_*` in the generator) or document the `_ok` precondition; folding the validation into `_build` would double the work for `_decode`.
Proof impact: none for a rename of a non-statement symbol; the e2e statements call `_decode`, not `_build`.

### CH-10 (MEDIUM, WRONG): `serialize(default())` of a container with a vector of variable-size elements writes offsets and no element bytes
Found by the corpus work after the hunt. `ComplexTestStruct_serialize(ComplexTestStruct_default())` is accepted and writes 86 bytes where
the reference zero value has 100. The default of `vec_VarTestStruct_2` (a vector of two variable-size elements) held two ABSENT boxes
(`O.BNone`); the serializer writes the offset of every element but no bytes for an absent one, so the output is shorter than its own offsets.
Only one type has the pattern (vectors of variable-size elements are `vec_VarTestStruct_2` and the containers that hold it: ComplexTestStruct).
Repro: `SSZ_CASE=12 build/pf` of `tools/crash_hunt/pf_fixed.bend` (`complex_default_serialize_ok=1 size=86` before, `size=100` after).
Fix (generator `typed_object_runtime.py`, `emit_seq`): the default of a vector whose elements have storage of their own builds `count` present
default elements (`X_dfill`); lists and vectors of fixed-size elements are unchanged. Law: `complex_default_serialize_ok` and
`complex_default_serialize_100` (`proofs/slop/crash/crash_fix_laws_generated.bend`).

## 3. What was run, and what held

All on the server under `/srv/ssz-optimization/agents/crashhunt/`, nice 19, at most 4 programs at a time, stack 16384 KB. Programs: the 27 object programs of
`benchmarks/objprog/` (g0..g9, x0..x16) and the 15 fuzz programs holding list setters (f4, f10, f12, f13, f15, f17..f26), compiled
with the pinned toolchain (the 27 g and x programs in 84 s, the f programs in a few minutes); five probe programs of this audit (`tools/crash_hunt/p[a-e]_*.bend`).

| run | size | result |
|---|---|---|
| hostile `_decode`, all 240 names (`hostile_decode.py`): truncations at the type's own boundaries, u32 words overwritten with 0, 4, 2^31 - 1, 2^31, 2^32 - 4, 2^32 - 1, n + 4, 2 n at the plausible offset slots and the first 8 slots, byte flips, appended / prepended bytes, constant fills at 11..63 lengths, bit-list last-byte patterns, offset tables, union selector sweeps 0..7, 127..129, 255 | 16,508 (small) + 24,000 (large profile, shuffled from 164,601) | 0 crash, 0 wrong (accepted inputs re-encode to the same bytes; rejections clean) |
| mutation driver, 15 programs x seeds (zero, rand0, max) x every op x index in {0, 1, 2, 31..33, 127..129, 1023..1025, 4095..4097, 65535, 65536, 131071..131073, 2^20, 2^31 - 1, 2^31, 2^32 - 2, 2^32 - 1} x 8 seed values | 10,656 | 0 crash, 0 wrong (no set_elem accepted an index >= 2^20) |
| scale (`scale_decode_real.py`): progressive u8 list 64 KiB..128 MiB, u64 / bool lists, bit lists up to 8 MiB, Transaction up to 16 MiB | 16 | linear: 128 MiB in 4.5 s, 388 MB RSS; others 0.06..0.8 s |
| count bomb: ExecutionPayload with K empty transactions, offset table 4 B / element | K = 0..2^20 + 1 | 2^20 (the limit): 1.9 s, 99 MB RSS from 4 MB; 2^20 + 1 and 2^22: rejected in 0.05 s |
| big-size decode (probe C): byte list 1 MiB, 2 GiB, 2^32 - 1, 2^32 - 16, bit list 1 MiB, 2^29, 2^29 + 1 | 10 | see CH-04, CH-05; 2^29 + 1 rejected, 2 GiB decode `Some` in 5 s |
| cached roots vs plain (probe D): n = 0..16, capp 1 to 17, 15 -> 20 (past the limit), cget / cset at 2^32 - 1 | 30 | all equal, flags correct |
| probe A, objects through constructors and setters | 22 cases | CH-01 .. CH-04, CH-07; `get`/`set` with index 2^32 - 1 and `Words` claiming more than the storage: no crash, `serialize` refuses (cases 5, 10) |

Memory caps: the Bend native programs reserve their heap at start-up, so `ulimit -v` (and `ulimit -d` below 16 to 32 GiB) makes every program fail with
`bend: reservation failed`; the runs above used `ulimit -d` 32 GiB (11 GiB for probe C), and the runtime's own arena (`bend: out of memory`) is the effective cap.
A blowup therefore shows as that message or as a timeout (120 s), which the runners record.

Not run (reasoned only): objects of 4 GiB (CH-07's composite wrap), the 2^32 cached-tree depth (`pow2u(32)` wraps to 0 for lists above 2^31 elements), sizes above 2^32 - 1 (not representable).

## 4. Proposed order of fixes

1. CH-01 (high; a checked setter corrupts a list and can loop 2^32 times).
2. CH-04 (guards; no wrap at 2^32 - 1) and CH-03 (O(1) clamp of the chunk count): both small generator changes with a bounded proof effect.
3. CH-06 (decode size vs buffer), CH-05 (wrap-free ceilings), CH-09 (rename `_build`), CH-02 and CH-07 (need a decision: contract or code).

Reproduce: `git push` the branch to the gate, fetch it on the server, `bend tools/crash_hunt/pa_objects.bend -o build/ch/pa` (likewise `pb_api`, `pc_bigdecode`, `pd_cache`, `pe_build`),
run with `SSZ_CASE` / `SSZ_ARG` (see each file header); `tools/crash_hunt/hostile_decode.py`, `scale_decode_real.py`, `mutate_hostile_real.py`, `countbomb.py` need `build/obj-g*`, `build/obj-x*`, `build/fuzz-f*`
(`bend benchmarks/objprog/<g|x|f><k>.bend -o build/<obj-|fuzz->...`). The `job*.sh` files are the exact command lines used.

## 6. Second pass (agent/crash-fix2): CH-03 fixed, CH-02 and CH-06 measured

### CH-03: roots are bounded by the storage (FIXED)
`src/obj.bend`: `words_root`, `words_root_prog` (so `bits_root`, `bits_root_prog`), `elems_root`, `elems_root_prog` read the storage size
(`Array.size`) and hash `O.cap_cnt(k, m, u, w)` chunks or elements instead of `k = chunks_of(n)`: `k` if the words they need (`m`; `8 * k` for
bytes, `ew * k` for packed elements) fit the storage `w`, else `w / u`. The work is bounded by the allocation: a 16-byte object claiming
2^32 - 1 bytes hashes 1 chunk (regression cases 13 and 14, under a second; it was 75 s and 10 s).
For a storage-valid object the root is the old one, and that is proved, not assumed: `proofs/obj/words_cap.bend` has
`wr_unfold` / `wr_unfold0` / `wrp_unfold` / `er_unfold`, each rewriting the runtime root of `O.Words{thaw(t), N}` (`t` perfect of depth `dw`,
`8 * chunks <= 2^dw`: the invariant every root law already carries) to the unbounded term, through `F.array__size_thaw` and
`F.u32__pow2u_value`. The root laws (`proofs/obj/words_root.bend`, `list_root.bend`, `ulist_obj.bend`, `bitlist_obj.bend`, `prog_list.bend`,
`pbits_obj.bend`, `elems48.bend`, `cells.bend`) start with that rewrite and are otherwise unchanged; no root statement changed. 
`frozen.lock.json` did not move (`verify_frozen` passes without `--update`).

### CH-02: `_encode` allocation from the invalid marker (NOT FIXED: it would weaken a frozen theorem)
The two ways the brief names were both tried on paper against the frozen statements and fail the "stronger or equivalent" rule:
* Guard `enc_sized` on `O.is_poisoned(n)` (bit 31, as `_serialize` does). The END_TO_END encode theorems of the byte lists
  (`proglist_uint8_e2e_encode`, hypotheses `hM: len <= VB.NMAX() = 4294967264`, `hs: sdk(o, 31)`) hold for objects of 2^31 .. 2^32 - 32
  bytes, and such an object's size answer has bit 31 set. A refusing guard makes the theorem false there. The same collision exists for the
  marker itself: a valid size of exactly 2^31 is the leaf marker `pick(.., n, 2^31)`, and `O.padd` sums sizes with `(a + b) | ((a | b) & 2^31)`.
* A different marker (2^32 - 1, which a valid size never is and which `zeros_bytes` allocates as one word) needs `O.padd` to saturate; `O.padd`
  is unfolded by 66,734 occurrences in the size proofs (`encx_*_size_o`, `var_codec_*`).
Decision for Giulio: narrowing the e2e encode hypothesis `hM` to `len < 2^31` (the contract already says no object is that large, CH-07) lets
`enc_sized` test `O.is_poisoned(n)` with one rewrite per encode law. That narrows a frozen premise, so it is not done here.
`_serialize` remains the safe entry.

### CH-06: `_decode` itself refusing `size > B.size(buf)` (NOT DONE: measured cost)
Prototype on `FuluCheckpoint` (`X_decode(buf, size) = X_dchk(size, B.size(buf))`, `dgo(U32.is_le(size, n), ..)`): of its 9 proof files that mention the
decoder, 8 fail at the first law that states `Checkpoint_decode(buf, m) == (buf, None{})` for an arbitrary `buf` (`Checkpoint_spec_reject`,
needs a case split on the guard) or `Checkpoint_decode(buf, size) == Checkpoint_some(..)` (`decode_build`, needs `U32.is_le(n, n)` at the symbolic
size). The full count of what would be touched: 2,569 proof and witness files (all generated) with 14,687 occurrences of `_decode(`, in 19
generator files (`codegen/proofs/{bridges,laws,slop,composed,witnesses,collections,var}/`). Each needs one rewrite step in its generator text,
then a full recheck of those files. Not attempted; `X_decode_checked` is the safe entry (CH-05, CH-06).


# Round 2 (agent/crash-hunt-r2, off origin/main d21616e2b; branch agent/crash-fix2 29af0ebcc checked for CH-03)

Fresh auditor, same rule. Exclusions: CH-01 .. CH-10 (CH-02 and CH-06 are documented contracts; variants are reported). Machine-readable: the `round2` key of
`docs/crash_hunt_findings.json`. Probes: `tools/crash_hunt/{pg,ph,pi,pj}_r2.bend`, `gen_default_probe.py` + `check_defaults.py` (default fills against the
reference port), runners `run_cases.sh`, `r2run.sh`. Everything ran on the server under `agents/crashhunt-r2/` at nice 19, stack 16384 KB, `ulimit -d` 32 GiB, 120 s timeout.
No library file was changed.

## R2.1 Result in one page

| | |
|---|---|
| New findings | **6** (0 high, 3 medium, 3 low) |
| CRASH (hang / OOM-class allocation from a tiny object) | **2** (R2-03, R2-04) |
| WRONG (accepts, or answers silently wrong) | **4** (R2-01, R2-02, R2-05, R2-06) |
| Fixes verified on main | CH-01 (cell setter / append refuse length != 2048: lengths 0, 64, 4096), CH-04 for bit lists and byte / bool lists and every finite list, CH-10 and every default (**206 of 206** named types: `serialize(default())` and `hash_tree_root(default())` equal the reference zero value, bytes and root), CH-05 / CH-06 in `_decode_checked` |
| Fixes with a hole | CH-04 (R2-01: six list kinds have no limit and still wrap), CH-01 (R2-05: checks the claim, not the storage), CH-06 (R2-04: trusts `B.Buf.len`), CH-03 on branch crash-fix2 (R2-02, R2-03: Words fixed, composite lists and `_valid` not) |
| Objects built through setters (SignedBeaconBlock with 0..8 attestations and 0..131073 bits each, BeaconState with up to 300,000 validators / balances / participation bytes / pending deposits) | root of the built object equals root of `decode_checked(serialize(o))` in all 15 runs |
| Cached root vs plain root, 30,000 mixed `capp` / `cset` steps on `List[PendingDeposit, 2^27]`, compared every 1..1000 steps | 0 mismatches in 5 sequences of 20 to 30,000 steps |
| Repeated appends: 10^7 byte appends, 10^7 bit appends, 10^6 composite appends, 30,000 cached appends | linear, no quadratic copying |
| Honest large progressive roots at ulimit -s 16384 | byte list 10^9 bytes in 19 s / 1 GB, bit list 2^31 bits in 5 s / 0.5 GB; no stack problem |

## R2.2 Findings, ranked

### R2-02 (MEDIUM, WRONG, and a CRASH variant): `X_valid` does not guarantee what the contract says it guarantees
docs/API_CONTRACTS.md: `_hash_tree_root` has the precondition `X_valid(o)`, and "`X_valid(o)` first bounds the work by the storage". Three ways `valid` is true while the root is wrong or slow
(probe `ph_r2.bend`; `SSZ_CASE=1` byte list, `2` List[uint64, 131072], `3` progressive bit list; `SSZ_ARG` storage variant, `SSZ_N` claimed length):
* (a) **wrap at n >= 2^32 - 3.** `words_ok` computes `ceil(n/4) <= capacity` as `((n + 3) >> 2) <= c` (src/obj.bend:1485, 1590); `n + 3` wraps to 0..2, so `valid = 1` for `O.Words{4-word storage, 4294967295}` on
  every list without a limit (`proglist_*`, `Fulu_list_uint8_2^40`, `Fulu_list_uint64_2^40`; measured: valid = 1 at 4294967293, 4294967294, 4294967295 and valid = 0 at 4294967292; bit lists are fine, `bits_ok` has no wrap). `_serialize` still refuses (the size is >= 2^31, the marker), but the root of this "valid" object is the CH-03 hang on main (tens of seconds; CH-03 measured 75 s).
* (b) **bytes past the length inside the last chunk.** `valid` checks only the last partial word (`tail_zero`). `Words{8-word storage [1, 2, 0, 0, 0, 0, 0xdeadbeef, 0], 8}` is valid and serializes to the 8 bytes `01 00 00 00 02 00 00 00`,
  but its root (`ph` case 1 variant 6: `905782860,...`) differs from the root of the same bytes in clean storage (variant 5: `1649727631,...`). Same for the packed `uint64` list and the progressive bit list (words past the bit).
  `root(o) = root(decode(serialize(o)))` is therefore false for a valid object.
* (c) **storage smaller than one chunk.** `words_ok` needs `ceil(n/4)` words, the root reads `8 * ceil(n/32)`. A valid object of 8 bytes in a 2-word or 4-word array (storage sizes are powers of two, so n <= 28 bytes can land here) hashes
  through masked reads on main (aliased words) and, on branch crash-fix2, through `cap_cnt`, which clamps the chunk count to `storage / 8 = 0`: the root is that of an all-zero value (variants 0 and 1 of case 1 both print `1523027349,...`, variants 0 and 2 of case 2 both `2506658293,...`: the bytes are hashed as zeros).
  The commit message "proved equal for valid objects" holds for the representation invariant `rep`, not for `valid`.
Fix: `words_ok` / `bits_ok` state the whole-chunk invariant: `n + 3` replaced by the wrap-free `(n >> 2) + ((n & 3) + 3 >> 2)` (as `bits_nbytes` does), capacity `>= 8 * ceil(n / 32)` words, and the words from `ceil(n/4)` to the end of the last chunk zero (at most 7 reads); then CH-03's clamp is exact for valid objects. The alternative is to mask the chunk reads by the length in `mt_words`, which keeps `valid` as is and changes the root laws instead.
Proof impact: `words_ok` appears in the generated `*_valid` statements (the `valid` laws of every packed collection); strengthening it changes those statements and their lock entries, and the serialize bridge needs the extra conjunct. Medium.

### R2-01 (MEDIUM, WRONG): CH-04 is fixed only for lists whose limit is an element count; six list kinds still wrap in `(n + 1) * size`
`Fulu_list_uint64_1099511627776` (the `balances` / `inactivity_scores` field of BeaconState) and `proglist_uint16`, `proglist_uint32`, `proglist_uint64`, `proglist_uint128`, `proglist_uint256` have the append guard `True{}`
(`Bool.and(True{}, v <= 65535)` for uint16) and compute the new byte length `(n + 1) * es` in U32. For `n = floor((2^32 - 1) / es)` elements that is 2^32 and wraps to 0.
Repro (`pg_r2.bend`, `SSZ_CASE=1..6`, `SSZ_ARG` = claimed bytes): `Fulu_list_uint64_2^40_append(Words{16-word storage, 4294967288}, 1)` returns flag 1 and a list of **0 bytes** (`u64list append_ok=1 len_after=0`); the same for
`pl_u16` at 4294967294, `pl_u32` at 4294967292, `pl_u64` at 4294967288, `pl_u128` at 4294967280, `pl_u256` at 4294967264. One byte less gives the right length (`len_after=4294967288`). Both `Fulu_list_uint8_2^40` and `proglist_uint8` / `proglist_bool` are fine (`n < 2^32 - 1`).
A valid object reaches it: a 4,294,967,288-byte `List[uint64, 2^40]` decodes (`_decode` accepts up to 2^32 - 1 bytes, CH-05) and is then emptied by one append. Objects of 2 GiB or more are outside the documented limit, but the answer is flag 1, not a refusal.
Chain: `<kind>_append` -> `app_n` (guard `True{}`) -> `grow` -> `O.words_resize(O.words_fit(o, (n + 1) * es), (n + 1) * es)`.
Fix (generator, the same place as CH-04): guard `U32.is_lt(n, floor((2^32 - 1) / es))` for the packed lists without limit: 2147483647 (uint16), 1073741823, 536870911, 268435455, 134217727; for `List[uint64, 2^40]` the same bound with `min(N, .)`.
Proof impact: identical to the CH-04 regeneration (the append guard text and its laws; equivalent below the bound).
Variant, same call chain, lying object only (R2-06 below).

### R2-03 (MEDIUM, CRASH): CH-03 for lists of composites and for the cached tree: work and memory proportional to a claimed count, not fixed by branch crash-fix2
`<List>_Seq{items, n}` is an exported record; `n` is not tied to `Array.size(items)`. `X_valid` refuses `n > capacity` (`va_cap`), but the unchecked entries do not look at it:
* `X_root`: `l134217728_PendingDeposit_root(64n, h, Seq{one-leaf array, n}, 0)` hashes one (default) element per claimed index: n = 10^6 takes 7.9 s, n = 10^7 takes 61 s (6 us per element, identical on crash-fix2); a 16-byte object claiming the limit 2^27 takes about 14 minutes, and `List[Validator, 2^40]` accepts a claim up to 2^32 - 2 (hours). Lists with a small limit (`List[Attestation, 8]`) are bounded by the depth: n = 10^6 takes 0.11 s.
* `X_cache(o)` (public) allocates `2^(1 + ceil(log2 n))` digests of 32 bytes: n = 10^8 gives 8.4 GB resident from a 16-byte object (6.2 s); n = 2^32 - 1 would need 256 GB (OOM abort).
* `X_cache_at(arr, n, d)` (public, `d` a Nat): `d = 26` allocates 4 GB (3 s), `d = 40` is an OOM abort.
Repro: `pg_r2.bend` cases 12 (`SSZ_ARG` = n), 13, 14. Chain: `X_root` -> `leaves` (`is_lt(i, n)` only) -> `Attestation_bx_root` of `BNone` = default; `X_cache` -> `cache_at` -> `dfill(1n+d)`.
Fix: same shape as O.cap_cnt: in `X_root` / `X_cache` use `min(n, Array.size(items))` as the count (items past the storage cannot exist, so the value for a valid object is unchanged), and make `cache_at` internal or clamp `d` to `words_depth(Array.size)`.
Proof impact: the list root laws take `rep` (n <= capacity); the clamp is the identity there; one equation per law family (as for CH-03).

### R2-04 (LOW, CRASH-class): `X_decode_checked` trusts `B.Buf.len`; the "checked" entry still allocates and scans in proportion to a claim
`B.Buf{ws, len}` is a public constructor like `Words`. The CH-06 fix compares `size` with `B.size(buf)`, which is the field `len`, not the storage. `proglist_uint8_decode_checked(B.Buf{1-word array, 2147483647}, 2147483647)` returns `Some` and allocates 4 GB (2.7 s, `pi_r2.bend` case 3);
`proglist_bool_decode_checked` of the same buffer scans 2^29 aliased words and returns `Some` (6.1 s, 4 GB, case 4; the 8-byte buffer repeats, so every byte "is" 0 or 1). A buffer built by `B.alloc` is honest; this needs a hand-built `Buf`.
Fix: `dchk` also tests `U32.is_le(size, 4 * Array.size(ws))` (`B.Buf`'s array size is available without a read). Proof impact: slop laws of `_decode_checked` only.

### R2-05 (LOW, WRONG): the CH-01 guard checks the claimed length of the cell, not its storage
`l4096_b2048_set` / `_append` test `v.n == 2048`; `O.words_blit` then copies 512 words from `v.ws` through the index mask. `Words{1-word array, 2048}` (and any `v` whose storage is smaller than 512 words) is accepted with flag 1 and the cell receives the one word repeated (`pg_r2.bend` cases 9, 10: `cells append_ok=1 len_after=4096 / 2048`+). No crash, no out-of-range access; the list is still valid but the content is aliased.
Fix: guard with `words_ok(v, 2048, 2048, False, 1)` (storage and tail) or `U32.is_le(512, Array.size(vws))`. Proof impact: as CH-01 (the stated guard of this one collection).

### R2-06 (LOW, WRONG): `words_fit` decides "roomy" with a wrapping sum
`fit_sized` compares `(want + 31 >> 5) * 8 + 8` with the capacity; for `want >= 2^32 - 30` the sum wraps and is small, so a byte-list append at claimed length 2^32 - 32 .. 2^32 - 2 reports flag 1 without growing
(`pl_u8_append(Words{16-word storage, 4294967264}, 7)`: 0.1 s, flag 1, length 4294967265; at 4294967263 the same call grows to 4 GB). The byte is written through the index mask into the first words. An honest 4 GiB array has the room, so only a lying object reaches the aliasing.
Same family as CH-05 (wrap-free ceilings); fix: the `bits_nbytes` form `(n >> 5) + ((n & 31) + 31 >> 5)` in `fit_sized`, `depth_for`, `zeros_for`, `mask_last`. Proof impact as CH-05.

## R2.3 What was run

| run | size | result |
|---|---|---|
| default fills: `gen_default_probe.py` makes 6 programs for 206 named types (the 34 scalar aliases have no own default), compared by `check_defaults.py` with `ssz_ref.zero_value` (serialize bytes by a word checksum, root by value) | 206 types, 412 values | 206 match, 0 mismatch (includes BeaconState 2.7 MB, ComplexTestStruct 100 bytes, every progressive container and union) |
| `ph_r2` valid vs root on 7 storage variants x 3 types, wrap sizes 2^32 - 3 .. 2^32 - 1, main and crash-fix2 | 43 | R2-02 |
| `pg_r2` appends at the 2^32 limit, cell list, composite lists with a claimed count, `X_cache`, `X_cache_at`, bit lists | 32 | R2-01, R2-03, R2-05, R2-06 |
| `pi_r2` setter-built SignedBeaconBlock and BeaconState vs decode(serialize), decode_checked with lying Buf, `_ok` with a wrapping offset (ok = 0 in all 5), honest big roots | 28 | R2-04; rest equal |
| `pj_r2` cached vs plain, repeated appends | 10 | 0 mismatches, linear |
| branch crash-fix2: `pa` cases 6, 11 (Words / Bits claiming 2^32 - 1), 6 (2^30): 0.11 s each (75 s on main); case 7 `_encode` still allocates 2 GiB (CH-02, documented) | 4 | CH-03 fixed for Words / Bits; not for composites (R2-03); changes the root of valid small-storage objects (R2-02 c) |

Not run: an honest 4 GiB object appended at the wrap (R2-01 on a valid object, needs 4 GB of storage plus the decode; the claim-only form is the probe), new hostile-byte corpora (round 1 covered 40,508 runs with 0 findings and nothing in this round's reading of the decoder suggested a gap), the union payload setters beyond the 206-type defaults (constructors of a union are closed, a payload is a typed record).

## 7. Third pass (agent/crash-fix3): the six round-2 findings and two new ones

Branch `agent/crash-fix3` is `agent/crash-fix2` plus the round-2 hunter's commits, rebased onto main 5977f2a9c. Regression: `tools/crash_hunt/regress.sh`
(cases 1-30 of `pf_fixed.bend`, run on the server: 30 of 30 pass), `proofs/slop/crash/crash_fix_laws_generated.bend`, `codegen/tests/test_append_guards.py`,
and the round-2 probes `pg_r2` / `ph_r2` / `pi_r2` / `pj_r2` with `run_cases.sh`.

| id | status | what changed | regression |
|---|---|---|---|
| R2-01 | FIXED | every list kind guards its append: `n < min(limit, floor((2^32 - 32) / element size))` (the six kinds without a limit had the guard `True{}`); the generator asserts that no list kind has an unguarded append; `test_append_guards.py` reads every generated list type | `regress.sh` cases 15-18, laws `*_append_max_refused` |
| R2-02 (a) | wrap bounded, `valid` unchanged | `words_ok`'s `(n + 3) >> 2` still wraps for n >= 2^32 - 3, so `valid` is 1 for a claim of 4294967293..95 bytes in four words; the root of such an object is now bounded by the storage (0.11 s; it hung on main) and `_serialize` refuses it (size >= 2^31). Changing `words_ok` rewrites the text of the encoder validity laws of about 60 proof files (see section 7.2) | `ph_r2` case 1 variants 0 and 5 at n = 4294967293 / 4294967295: 0.11 s |
| R2-02 (b) | FIXED | the root checks that the last chunk is clean (no byte past the length in the words up to the end of the chunk, `O.wcn`); an object that is not is hashed through a clean copy, so `root(o) = root(decode(serialize(o)))` for every valid object. Proved for every represented object: `proofs/obj/words_zero.bend` (the zero bytes of `WS.cb` make the words zero) and `proofs/obj/words_canon.bend` | `regress.sh` case 30; `ph_r2` variants 3 and 6 print the root of variant 5 |
| R2-02 (c) = CH-11 | FIXED | a valid object of tight storage (ceil(n / 4) words, less than the 8 words per chunk the root reads) hashes as the same bytes in roomy storage: the root takes the clean-copy path (it is the crash-fix2 clamp that made this root the root of zeros) | `regress.sh` case 26; `ph_r2` variants 0, 1, 2 |
| R2-03 | FIXED | the root of a list of composites hashes `min(n, storage)` elements (the length mixed in is still the claim); `X_cache_at` clamps the depth to the array (`O.cache_dok`: below 32 and 2^d at most the array's size) | `regress.sh` cases 23-25 (a 16-byte object claiming 10^7 elements: 61 s on crash-fix2, now immediate) |
| R2-04 | FIXED | `X_decode_checked` also compares the window with the words the buffer's array holds (`B.stored`) | `regress.sh` case 22, law `decode_checked_lying_buf_refused` |
| R2-05 | FIXED | the cell setter and appender also test the storage of the argument (`words >= 2048 / 4`); the laws take its size as `vc` with the premise `es` | `regress.sh` cases 20-21, laws `cells_*_one_word_refused` |
| R2-06 | FIXED through the guard | the guard bound of R2-01 keeps `(n + 1) * es + 31` below 2^32, so the chunk rounding of `words_fit` / `zeros_for` never wraps | `regress.sh` case 19, law `pl_u8_append_wrap_refused` |
| CH-12 | FIXED | an absent box (`O.BNone`) was replaced by the default box in the size pass, so the checked writer never saw it and `AttesterSlashing_serialize` returned `ok` with 236 bytes: the size pass now keeps the absent box absent and the checked writer flags it | `regress.sh` cases 27-29; `tools/crash_hunt/gen_absent_box_probe.py` (17 name.field cases) |

### 7.1 CH-12: absent boxes (found by the manual-mutation auditor)
Repro: `AttesterSlashing_serialize(AttesterSlashing{O.BNone{}, IndexedAttestation_bx_default()})` returned `ok=1, size=236` (`tools/crash_hunt/pk_r3.bend`).
The checked writer chain does flag the absent box (`bx_putk` answers the marker 2^31 and `padd` keeps it: `AttesterSlashing_putk` answers 2147483884), but
`AttesterSlashing_size`, the first step of `_serialize`, went through `{p}_bx_size`, which returned `(bx_default(), 0)` for the empty box: the writer then wrote a
present default value and never saw the absence. Generator fix (`emit_box`, `typed_object_runtime.py`): `(O.BNone{}, 0)`.
Measured over every named type with a boxed field (`gen_absent_box_probe.py`: the default of the type with one box set to the empty box, 17 cases), before and
after: **ok=1 before for 6**, `AggregateAndProof.aggregate`, `AttesterSlashing.attestation_1` and `attestation_2`, `BeaconBlockBody.execution_payload`,
`BeaconBlock.body` and `BeaconState.latest_execution_payload_header` (the boxes whose content has a variable size); **ok=0 after for all 17** (the other 11
boxes hold fixed-size content, which `valid` already refused). The size answer of an absent box stays 0, so a plain `_encode` of an absent box does not allocate.

### 7.2 What did not change, and why
* `words_ok` / `bits_ok` / `X_valid`. The sizes of R2-02 (b) and (c) are decided in the root, where the proofs have the representation invariant (room for whole chunks,
  zero bytes past the length), not in `valid`: strengthening `valid` would add a premise to every frozen `X_e2e_serialize(o, v: valid(o))` theorem (a narrowing)
  and an OKT conjunct to about 20 encoder-law generators. The wrap of (a) is in the text of `wk_cap`, which about 60 encoder proof files unfold.
* `_encode` of an invalid object still allocates the marker (CH-02, section 6): a guard would falsify the e2e encode theorems for 2^31 .. 2^32 - 32 bytes.
* `_decode` itself (CH-06, section 6).
