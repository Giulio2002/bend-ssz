# Crash hunt: can the typed object API be made to crash?

Auditor: agent/crash-hunt (off origin/main b1764b5a8). Rule under test: the library must never crash. Every public entry point
(`<Name>_decode`, `_ok`, `_encode`, `_serialize`, `_hash_tree_root`, constructors, getters, setters, list `_append`, the `O.*`
runtime) must return a value or an error value for every input a caller can construct. No library file was changed; the
frozen files (`spec/`, `schemas/`, END_TO_END, ROOT_DOMAIN, PROOF, HASH_PROOF, `frozen.lock.json`, `law-statements.json`) are untouched.
Machine-readable list: `docs/crash_hunt_findings.json`. Raw outputs: `docs/crash_hunt_evidence/`. Probes and runners: `tools/crash_hunt/`.


Later passes: section 6 (agent/crash-fix2: CH-03 fixed, CH-02 and CH-06 measured), the round-2 hunter report (R2.1 to R2.3),
section 7 (agent/crash-fix3: R2-01 to R2-06, CH-11, CH-12), the round-3 hunter report (R3.1 to R3.4, R3-01 to R3-04), the round-4 hunter report (R4.1 to R4.4, R4-01 to R4-06) and the round-5 hunter report (R5.1 to R5.4, R5-01, R5-02, last section) update the table below.

## 0. Status after the fix series (agent/crash-fix)

| finding | status | what changed | regression |
|---|---|---|---|
| CH-01 | FIXED (statements and lock moved, authorized: docs/crash_hunt_statement_diff.md) | the cell list's setter and appender refuse a cell whose length is not 2048 (guard and `words_blit` on an empty source) | `regress.sh` cases 1-5; `proofs/slop/crash/` laws; regenerated `l4096_b2048_api_*` statements |
| CH-02 | FIXED by agent/size-limit (docs/size_limit_statement_diff.md; the blocking statement rule was lifted by the authorized lift of the 2^31 premises; the older text below is the history) | `_encode` has the precondition `X_valid(o)`; `_serialize` refuses before allocating. Any guard on the size pass answer falsifies a frozen END_TO_END encode theorem for objects of 2^31 .. 2^32 - 32 bytes | - |
| CH-03 | FIXED (`src/obj.bend` moved, statements unchanged) | every root clamps its chunk count to the storage: `O.cap_cnt`; identical root for every storage-valid object (proved), work bounded by the allocation for an invalid one | `regress.sh` cases 13-14; `proofs/obj/words_cap.bend` |
| CH-04 | FIXED (statements and lock moved, authorized) | `n + 1 <= N` became `n < min(N, 2^32 - 1)` for every list that can reach 2^32 - 1 | `regress.sh` cases 6-8; `proofs/slop/crash/` laws; regenerated `*_api_append_*` statements |
| CH-05 | FIXED in the checked entry | `X_decode_checked` / `X_dchw` refuse a window above NMAX (`size > 4294967264`, the size limit); `_decode` refuses a window outside the buffer (the decode window, `hwin`). (Before the size limit: "refuses a window of 2^31 bytes or more; `_decode` itself is unchanged".) The cap is pinned by `*_decode_vchecked_nmax_above` / `_limit`; the older law `decode_checked_2gib_refused` keeps its statement but now holds only because its one-word storage cannot hold 2^31 bytes (audit round 6 F6) | `regress.sh` case 11; slop laws `*_decode_vchecked_nmax_above`, `*_decode_vchecked_limit` |
| CH-06 | FIXED in `_decode` itself (agent/decode-window) | `X_decode(buf, size)` answers `(buf, None{})` when `size > B.size(buf)` (a U32 comparison with the buffer's size field: nothing wraps, no size cap); otherwise it is `X_decode_in` (the old body). `X_decode_checked` stays (it also tests the storage and the 2^31 bound) | `regress.sh` cases 9-10 and 40-45; `proofs/obj/decode_window_*_generated.bend` (`X_win_out`: outside the buffer the result is None); docs/decode_window_statement_diff.md |
| CH-07 | FIXED by agent/size-limit | no 2^31 cap: the marker is 4294967295, `O.padd` saturates, a valid object is at most NMAX = 4294967264 bytes; theorem premises lifted from `x < 2^31` to `x <= NMAX` (docs/size_limit_statement_diff.md); `regress.sh` cases 46-57 | docs/SIZE_LIMIT_DESIGN.md |
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
> **Superseded (size limit, docs/size_limit_statement_diff.md; audit round 6 F9):** the text below describes the 2^31 regime of its time. Since the size limit the marker is 4294967295, a valid object may have up to NMAX = 4294967264 bytes, `_encode` of an invalid object returns the empty buffer (CH-02 fixed, regress case 72) and every fixed-count product is `O.mulc` (R3-03 closed).
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

**Done in agent/decode-window.** The cost was not in the generators' number of occurrences but in three shapes: a law over a literal window and a buffer of that
literal size needs nothing (the guard `U32.is_le(40, 40)` evaluates); a law over `(BF(t, n), n)` needs `U32.is_le(n, n)`, and a refusal over a free buffer
needs the case split of the guard. `X_decode` is now `X_dwin(size, B.size(buf))` over `X_decode_in` (the old body); one lemma module per decoder
(`proofs/obj/decode_window_<Name>_generated.bend`, `codegen/proofs/laws/decode_window_laws.py`) carries a law proved on `_decode_in` to `_decode`
(`X_win_none`, `X_win_none_f` for a free buffer variable, `X_win_some` with `hle`, and `X_win_out`: outside the buffer the result is None); the wrapping of the
generated laws is one function of `runtime_file_split.rewire` (`codegen/proofs/support/decode_window.py`), so no generator emits a decode proof by itself. The
only statements that change are the 282 `decode_build` / `decode_fields` laws of `decoder_offsets` (premise `hwin`, the window is inside the buffer; with their
gate and facade restatements): docs/decode_window_statement_diff.md. The importer closure of all 1,955 changed files (5,594 with their importers) checks (51 of 51
umbrellas); `regress.sh` cases 40-45 (empty buffer, window past the end, window 2^32 - 1, the empty window of an empty buffer).


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
* `_encode` of an invalid object still allocates the marker (CH-02, section 6): a guard would falsify the e2e encode theorems for 2^31 .. 2^32 - 32 bytes. *(Superseded: fixed by the size limit, `_encode` of an invalid object returns the empty buffer; regress case 72.)*
* `_decode` itself (CH-06, section 6).


# Round 3 (agent/crash-hunt-r3, off origin/main b1e3c20ee)

Fresh auditor, same rule. Exclusions: CH-01 .. CH-12 and R2-01 .. R2-06 (CH-02, CH-06 and R2-02 (a) are documented contracts; variants are reported). Machine-readable:
the `round3` key of `docs/crash_hunt_findings.json`. No library file was changed. Everything ran on the server under `agents/crashhunt-r3/`, nice 19, at most 4
programs at a time, stack 16384 KB, 120 s timeout per run, `df` 18 GB free at the end. Probes and generators: `tools/crash_hunt/` (the files named below).

## R3.1 Result in one page

| | |
|---|---|
| New findings | **4** (0 high, 3 medium, 1 low) |
| CRASH (abort / OOM-class allocation / hang from a few words of input) | **1** (R3-02) |
| WRONG (accepts, or answers silently wrong) | **3** (R3-01, R3-03, R3-04) |
| Regression of the earlier fixes (`regress.sh`, 30 cases, on b1e3c20ee) | **30 of 30 pass** |
| Hostile decode at scale, real Fulu containers (`mutate_batch.py`, offset slots set to edge values / neighbours / copies, swaps, equal offsets, two-slot combos, byte flips, truncation at every byte of the first 4096 bytes and at every offset target, sizes past the buffer) | SignedBeaconBlock **348,939**, BeaconBlockBody **349,834**, BeaconState **221,520** mutants: **0 crashes, 0 wrong** (every verdict of the two block types is compared with the reference port; 6,200 BeaconState verdicts; every accepted mutant is re-serialized and must equal its input) |
| Same, the ten variable-size generic types (BitsStruct, CompatibleUnionA / BC / ABCA, ComplexTestStruct, ProgressiveComplexTestStruct, ProgressiveSingleListContainerTestStruct, ProgressiveTestStruct, ProgressiveVarTestStruct, VarTestStruct) | **1,150,970** mutants, every verdict compared with the reference: **0 crashes, 0 wrong** |
| Differential test of 102 packed collections built by `_append` / `_set` only (all bit lists, progressive lists, byte lists, lists and vectors of uint8..uint256, bool, Bytes32, Bytes48, cells; n = 0 .. limit + 2, one append past the limit, 0 / 7 sets, and for the progressive lists the chunk counts 1, 2, 4, 5, 6, 20 .. 22, 84 .. 86, 340 .. 342, 1364 .. 1366 around the shape changes of the progressive tree): serialize bytes, root, `valid`, length against the reference port | **5,748 scenario runs (4,068 + 1,680 progressive boundaries), 0 mismatches** |
| Cached root against plain root against the reference, every one of the 18 lists of composites (`_cache`, `_capp`, `_cset`, n = 0 .. limit + 2, sets) | **426 scenarios, 0 mismatches** |
| Containers built through setters only (71 named containers incl. BeaconState, BeaconBlockBody, ExecutionPayload(Header); 183 scalar / byte-vector / bitvector fields set from an LCG, 3 seeds), serialize bytes and root against the reference | **213 scenarios, 0 mismatches** |
| Lying objects into every entry point (`_valid`, `_root`, `_serialize`, `_append`, `_set`, `_get`, `_len`) of the same 102 collections, claims 33, 100, limit, limit + 1, 2^31 - 1, 2^31, 2^32 - 32, 2^32 - 5, 2^32 - 1 over 8 words of storage | **7,608 runs: no abort, no hang; 18 runs allocate 4 GB (R3-02), set / get alias (R3-04)** |
| Absent boxes as list elements (`Seq{fill, n}`, 11 list and vector kinds) | `valid = 0` for all 9 kinds of boxed elements (the 2 others hold no box) |

The decoder side is again clean at a scale of two million mutants. The three medium findings are on the object side: a **getter that removes the element it
returns** (R3-01), an **append whose allocation follows the claimed length** and aborts the process (R3-02), and a **U32 wrap of `n * element size`** that a
valid object reaches (R3-03, a variant of CH-07).

## R3.2 Findings, ranked

### R3-01 (MEDIUM, WRONG): `_get` / `_cget` of a list of boxed elements MOVES the element out of the list
Entry points: `_get(o, i)` and the cached `_cget(c, i)` of the nine list and vector kinds whose elements are boxed (`O.Boxed<..>`, non-copyable): `Fulu_list_Attestation_8`
(`BeaconBlockBody.attestations`), `Fulu_list_Deposit_16`, `Fulu_list_AttesterSlashing_1`, `Fulu_list_ProposerSlashing_16`, `Fulu_list_bytelist_1073741824_1048576`
(`ExecutionPayload.transactions`), `proglist_VarTestStruct`, `proglist_ProgressiveVarTestStruct`, `proglist_proglist_VarTestStruct`, `vec_VarTestStruct_2`
(`ComplexTestStruct`; `_cget` exists for the first five).
Repro (`tools/crash_hunt/pl_r3.bend`, `pm_r3.bend`; server, `SSZ_CASE`): a list of two default attestations, case 1:
`valid0=1 get0=some valid_after_get=0 root_after_get=<other root> get0_again=some`; case 4 (vector of two `VarTestStruct`): `vec_get0=some valid_after_get=0`;
case 5 (transactions list with one empty transaction): `tx_get0=some valid_after_get=0`; `pm_r3` case 13 (cached list, `_cget(0)`): `cached_root_after_cget`
is the old root while the plain root of `uncache(c)` is another one.
Chain: `X_get` -> `get_in` -> `at(arr, n, i) = took(n, Array.swap(arr, i, O.BNone{}))`, `took` returns `(Seq{arr', n}, Some{bx_unbox(v)})`. The returned list has the empty box
at index `i`, the element lives only in the `Some`.
Why it matters: `X_valid` of the returned list is 0 (an absent box is invalid, CH-12), so `_serialize` of any container that holds it answers `ok = 0`; the root is another one;
a second `_get` of the same index returns `Some{default element}` instead of `None` or the element. A caller that reads an element and then serializes loses the data silently.
`_cget` does not even mark the slot dirty: the cached root stays the old one while the list holds a hole.
No law states that `_get` leaves a boxed list unchanged: the generated laws of these kinds are `api_get_outside`, `api_set_flag`, `api_append_flag` and friends (the read-after-write laws
`api_read_append` / `api_other_set` exist only for the unboxed kinds, e.g. `SignedVoluntaryExit`), so the statements are consistent with the behaviour; the name and the `Maybe` result are not.
Fix (generator, `emit_collection`, the boxed `at` / `took` / `ctook`): a non-copyable element cannot be both returned and kept, so rename the boxed variants `_take` / `_ctake`
(documented: the list has a hole until `_set` puts an element back; `_ctake` marks the slot dirty), keep `_get` for the unboxed kinds. Proof impact: the `get_outside` laws of the nine kinds
move to the new name (statement text and lock entry), no semantic change; nothing else mentions the boxed `get`.

### R3-02 (MEDIUM, CRASH): `_append` allocates and copies in proportion to the CLAIMED length: an abort from a hand-built object, `_force` / `_dump` likewise
Entry points: `_append` / `_capp` of every list, `_force`, `_dump`.
* **Composite lists, abort.** `Fulu_list_Validator_1099511627776_append(Seq{fill(0n), 67108864}, default)` prints `bend: an array past the deepest block class 31` and exits 1 after 0.1 s
  (`pm_r3.bend` case 1, `SSZ_ARG=67108864`). The same for `Fulu_list_PendingDeposit_134217728` at 33,554,432 (case 2), and for the cached `_capp` (case 6). One element below the abort the call
  succeeds with flag 1 and **8.4 GB** resident (case 1 at 67,108,863: 5.8 s; at 10^7: 2.1 GB, 1.5 s). The object has one slot of storage and is a few words.
  Chain: `X_append` -> `app_in(ok = n < 4294967295)` -> `room` -> `room_pick(is_lt(n, Array.size))` false -> `copy(n, ..)` and `fill(cap(n + 1))`: a tree of `2^ceil(log2(n + 1))` elements.
  An honest list reaches it too: 2^26 validators (8 GB of records) or 2^25 pending deposits, and the next `_append` aborts (both are above the documented 2^31 byte limit, which `_append` does not test).
* **Packed lists, 4 GB.** `pl_u8_append(O.Words{8 words, 2147483647}, 7)` and the same for the other 8 packed kinds without a usable limit (`proglist_bool`, `proglist_uint16 .. 256`, `Fulu_list_uint64_2^40`, `Fulu_list_uint8_2^40`)
  allocate 4.2 GB for an object of 32 bytes (18 runs of `gen_lie.py`: 9 kinds, claims 2^31 - 1 and 2^31; 2.6 to 3.3 s, flag 1, claimed length + 1). R2-06 documented the aliasing at the end of this range; the allocation
  of the whole claim is the same cause.
* **`_force` / `_dump`.** `l8_Attestation_force(Seq{one slot, 10^8})` loops 10^8 times (4.4 s, 2^32 - 1 would take 3 minutes); `pl_u8_dump(O.Words{2 words, 10^8}, Nil)` builds a list of 10^8 entries
  (1.4 s, 1.5 GB; 2^32 - 1 is an out-of-memory abort). Both are the test-oracle helpers, public symbols (`pm_r3.bend` cases 11, 12).
Why: the append guards bound the claim by the LIMIT (R2-01) but never compare it with the STORAGE, so a claim the storage cannot hold makes `room` / `grow` allocate for the claim. R2-03 clamped
the roots and the cache for exactly this reason; the append, `force` and `dump` paths were not.
Fix (generator, the append guards of R2-01): add the storage test `n <= Array.size(arr)` (composite lists), `ceil(n / es) <= capacity` in the wrap-free form (packed lists) and
`(k >> 5) + 1 <= capacity` (bit lists) to `ok` of `app_in` / `app_n` / `push`, so the allocation is at most twice what exists; for the fixed-size composites also `n < floor((2^31 - 1) / es)`
(17,747,798 validators, 11,184,810 pending deposits, the same bound as R3-03); `fo` / `du` / `dump_bytes` take `min(n, storage)` like `O.cap_cnt`.
Proof impact: the append guard text of every list changes (`api_append_flag`, `api_append_rejected`: "flag = `is_lt(n, N)`" becomes "flag = `is_lt(n, N)` and the storage test"; for a
representable object the storage test is the identity, `n <= size`), regenerated from the generator text, statements move in `e2e/STATEMENTS.txt` and the lock as in R2-01. The cheap part
(abort only) is the `n < floor((2^31 - 1) / es)` bound, which changes the guard of two lists.

### R3-03 (MEDIUM, WRONG, variant of CH-07): `n * element size` wraps for a VALID list of fixed-size composites, and `_serialize` answers ok with a wrong, short encoding
> **Superseded (size limit, docs/size_limit_statement_diff.md; audit round 6 F9):** the text below describes the 2^31 regime of its time. Since the size limit the marker is 4294967295, a valid object may have up to NMAX = 4294967264 bytes, `_encode` of an invalid object returns the empty buffer (CH-02 fixed, regress case 72) and every fixed-count product is `O.mulc` (R3-03 closed).
Entry points: `l134217728_PendingDeposit_size` / `_valid` / `_putk` and `l1099511627776_Validator_*` (so `BeaconState_serialize` through `pending_deposits` and `validators`); 192-byte and
121-byte elements.
Repro (`pm_r3.bend`, server, 8.4 GB for the storage of 2^25 slots): the size pass of `Seq{fill(25n), n}` (default pending deposits, `n <= storage`, `n <= limit`: a valid object) prints
`size=1920000000` for n = 10^7 (right), `size=5832704` for n = 22,400,000 (true size 4,300,800,000: wrapped), `size=2041032704` for n = 33,000,000 (true 6.3 GB, looks encodable); `_valid` is 1 for 22,400,000.
`BeaconState_serialize(BeaconState_set_pending_deposits(BeaconState_default(), that list))` (case 9) prints **`ok=1 size=8570513`** (= 2,737,809 + 5,832,704) where the true encoding is 4,303,537,809 bytes.
Chain: `szf(n, c) = pick(n <= c, (n * 192 : U32), 2^31)`, `ptn_fin` `(n * 192 : U32)`, `pt` writes at `pos + i * 192` in U32: every term wraps; the size is below 2^31, so the marker is not set.
CH-07 documented that an object of 2^31 bytes or more is refused and named this wrap; the contract as written ("no object of 2^31 bytes or more is encodable") is not what the code does for a list
of fixed-size composites whose product is in [2^32, 2^32 + 2^31): it is accepted and truncated. Rule: the library must never silently wrap 32-bit arithmetic.
Only the two lists with an element above 2^31 / limit bytes can reach it (`Validator` at n >= 35,495,597, `PendingDeposit` at n >= 22,369,621; `PendingPartialWithdrawal` is capped by its limit below 2^32).
Fix (generator, `szf` / `va_cap` / `putn`): refuse `n > floor((2^31 - 1) / es)` (the marker answer) next to the capacity test, i.e. the bound of R3-02. Proof impact: `szf` and `va_cap` of two list
encoders (text of their size / validity laws, the BeaconState e2e encode theorems carry the hypothesis `hM`), as the R2-01 regeneration.

### R3-04 (LOW, WRONG, lying objects only): `_set` / `_get` / `cache_at` answer from aliased storage for a claim the storage does not hold
For every one of the 102 packed collections, an object that claims more than its storage holds (`O.Words{8 words, claim}`) answers `set_last = 1` (index `claim - 1`) and `get = some`: the write lands
in the word that the index mask selects, so it corrupts another element; `_valid` is 0 and `_serialize` refuses (`gen_lie.py`, ops 5, 6; hand-checked with `bitlist_9` at claims 100 .. 2^32 - 1).
`<List>_cache_at(arr, n, d)` with a depth `d` that does not match `n` (`pm_r3.bend` case 10: n = 7, d = 0, 1, 2, 4) answers roots that differ from `d = 3`, with no error (d = 4 is clamped to 0 by `O.cache_dok`).
No crash and no way for an honest object to get there; the index mask is documented in `src/buffer.bend`. Fix: the setters test `i < ceil(claim)` against the storage (the R2-05 storage test) and
`cache_at` derives `d` from `n` instead of taking it. Proof impact as R2-05 for the guard text; `cache_at` is stated with `d` symbolic in the cache laws (a larger change), so the documentation option is the cheap one.

## R3.3 Not findings (checked, behaves)
* Hostile hasher argument: `_hash_tree_root(h, o)` with `h` = `B.empty()`, `B.alloc(0)`, `B.alloc(100000)` or a `B.Buf` claiming 2^32 - 1 bytes gives the same root as `O.hasher()` (`ph3_r3.bend`, 13 runs).
* Absent boxes: `_valid` is 0 for an absent element of every list kind of boxed elements (`pa3_r3.bend`, 9 of 9), CH-12 holds for fields.
* Every fix of rounds 1 and 2 holds on b1e3c20ee for every list kind (not only the ones named): the append at the claimed limit and at 2^32 - 1 is refused for all 102 packed kinds; the cell list refuses lengths 0, 64,
  4096 and a one-word storage; `_valid` / `_serialize` / `_root` of all 102 kinds on claims 2^31 .. 2^32 - 1 return a value in under 8 s (none slower; most take 0.1 s), so no packed kind needs the R2-03 clamp more than the ones named; the append at claims 2^32 - 32, 2^32 - 5, 2^32 - 1 is refused by every kind but the progressive bit list, whose limit is `k < 2^32 - 1` by design (R2).
* Cached root = plain root = reference for all 18 composite lists, including the progressive list, up to the limit and one past it (refused by both).
* `X_decode_checked` of a hand-built `B.Buf` claiming 16 .. 2^32 - 1 bytes over a one-word array (window = claim and claim - 1), ten names (BeaconState, BeaconBlockBody, SignedBeaconBlock, ExecutionPayload, DataColumnSidecar, LightClientUpdate, ProgressiveTestStruct, CompatibleUnionABCA, Checkpoint, Validator): `None` in all 22 answers (`pd3_r3.bend`); the R2-04 fix is in the shared `dchk`.
* Truncation of a valid BeaconState at every byte of its first 4096 bytes, at every offset target +-{0,1,4} and 600 random sizes: `None` in all cases except the full length (also `None` for every size beyond `B.size(buf)`).
* Repeated `_cset` + `_cached_root` cycles: 50 us per cycle for 10^3, 65,536 and 2 x 10^5 elements (`pr_r3.bend`): no quadratic behaviour.

## R3.4 What was run

| run | size | result |
|---|---|---|
| `tools/crash_hunt/regress.sh` | 30 cases | 30 of 30 pass on b1e3c20ee |
| `mutate_batch.py` + `gen_mutbatch.py` (one process per chunk of 5000 mutants, `decode_checked` -> `serialize` -> root every k-th accepted) | BeaconState, BeaconBlockBody, SignedBeaconBlock: 920,293 mutants; ten generic types: 1,150,970 | 0 CRASH, 0 WRONG (accept / reject equal to the reference port on every verdict that was compared; canonical re-encoding on every accepted mutant) |
| `gen_packed_diff.py` (102 programs `pd_*`) | 5,748 scenario runs | 0 mismatches |
| `gen_cache_diff.py` (18 programs `cd_*`) | 426 scenarios | 0 mismatches |
| `gen_setters.py` (71 programs `st_*`) | 213 scenarios | 0 mismatches |
| `gen_lie.py` (102 programs `lie_*`) | 7,608 runs | R3-02 (18 runs over 3 GB), R3-04; the other runs return a value in 0.1 s |
| hand probes `pl_r3` (get), `pm_r3` (claims, size wrap, force / dump, cache_at, cget), `pa3_r3` (absent elements), `ph3_r3` (hasher), `pr_r3` (repeated cset + cached_root: 50 us per cycle for n = 10^3 .. 2 x 10^5, no growth with n) | about 80 runs | R3-01 .. R3-04 |

Not run: honest objects of 2^31 bytes or more (the wrap of R3-03 was reached by a valid object of 2^25 slots, which needs 8.4 GB, not by 22 million separate appends); the 240 names one by one through
the batch mutation driver (the three real containers and the ten variable-size generic types were; the 102 packed collections went through the differential and lying-object sweeps instead); the union selectors of the 200 other names (round 1 swept them).
Generated programs are not committed: `gen_*.py` rebuild them (`gen ... --out tools/crash_hunt/<dir>`; compile with the pinned toolchain, one program per name).


## 8. Fourth pass (agent/crash-fix4): the four round-3 findings

Branch `agent/crash-fix4` is main (b1e3c20ee, then f683ee2c6) plus the round-3 hunter's commits and these fixes. Regression: `tools/crash_hunt/regress.sh`
(cases 1-39 of `pf_fixed.bend`; cases 31-39 are new, 39 of 39 pass), `proofs/slop/crash/crash_fix_laws_generated.bend` (nine new laws),
`codegen/tests/test_append_guards.py`, and the round-3 campaigns re-run on the fixed tree (`tools/crash_hunt/run_round3.sh` (b), (d): 167 packed collections built by
`_append` / `_set` against the reference with 0 mismatches, 18 lists of composites cached = plain on every scenario, 7,608 lying-object runs with no abort, no hang and no allocation in
proportion to a claim).

| id | status | what changed | regression |
|---|---|---|---|
| R3-01 | FIXED by renaming the boxed getters | `_get` / `_cget` of the nine kinds with boxed elements are `_take` / `_ctake`; `_ctake` marks the slot dirty; `_get` / `_cget` stay for the copyable kinds | `regress.sh` cases 38, 39; laws `unboxed_get_keeps_the_list`, `boxed_take_leaves_a_hole`; probes `pl_r3`, `pm_r3` (renamed) |
| R3-02 | FIXED | every append guard also tests the storage: `n <= Array.size(arr)` (composite lists, cached `_capp`), `ceil(n * es / 4) <= words of storage` (packed lists, cells), `ceil(ceil(k / 8) / 4) <= words` (bit lists); `_force` and `_dump` visit `min(n, storage)` elements; `O.dump_bytes` clamps to the storage | `regress.sh` cases 31-37; laws `*_claim_over_storage_refused`, `pl_u8_append_tight_storage_accepted`; `test_append_guards.py` |
| R3-03 | CLOSED (size limit) | every fixed-count product is the checked `O.mulc(n, es)` (the marker above floor(NMAX / es)); the append / `_capp` guard of a list of fixed-size composites is the count whose encoding stays within NMAX: 35,495,597 validators (121 bytes), 22,369,621 pending deposits (192), the list limit 134,217,728 for pending partial withdrawals (24), and 1,073,741,816 for the progressive list of 4-byte records `pl_SmallTestStruct` (was 536,870,911 under the 2^31 regime). A hand-built list beyond the bound is refused by `_valid` / `_serialize` and encodes to the empty buffer (regress case 72) | `test_append_guards.py`; regress cases 51-57, 72 |
| R3-04 | DOCUMENTED | lying objects (claim larger than storage) answer `_set` / `_get` / `_cache_at` from aliased storage; nothing allocates in proportion to the claim and no honest object reaches it: `docs/API_CONTRACTS.md` | - |

### 8.1 R3-01: why a rename, and what it costs
A getter that returns the element and leaves the list intact needs a copy of the element. The nine kinds hold their elements in `O.Boxed<..>` (a non-copyable
`Type`, not `Data`: the proofs use affine arrays of boxes), and none of them has a clone function; one would be the size of a serializer plus a decoder
per type (`_serialize` then `_decode`), proved against the spec. Moving the element out and leaving the empty box in its slot is the only operation the representation
allows, and it is what the old `_get` did; the fault was the name and the cached root, not the arithmetic. The least statement churn that makes a getter NOT corrupt the list
is therefore the rename, and only for the kinds where it is true:
* `X_take(o, i)` / `X_ctake(c, i)`: `Some{element}` and the object with the empty box at `i` (not valid until `_set` puts an element back; `_serialize` refuses it, CH-12);
  `_ctake` also marks leaf `i` dirty (`lo` / `hi`), so the next `_cached_root` is the root of the object it returned (before, it stayed at the old value, and the first
  `_cached_root` after it silently put a default element back).
* Statement diff: the statements of the nine kinds that name the getter (`api_get_outside`, `api_read_set`, `api_read_append`, `api_other_set`, their witnesses) now say
  `X_take`; the statement of each is otherwise unchanged (they already stated that the element is taken out of its slot: `Array.set(.., O.BNone{})` in the result of `read_set`
  / `read_append`, which is how the hunter's report found "no law states that `get` leaves a boxed list unchanged"). The copyable kinds keep `_get`.

### 8.2 R3-02: the storage test
The append guards bounded the CLAIM by the limit (R2-01) but never compared it with the storage, so `room` / `grow` allocated for the claim (`Fulu_list_Validator_1099511627776_append(Seq{one slot, 67108864}, default)`:
"an array past the deepest block class 31", 0.1 s; 67108863: 8.4 GB). The guard of every append is now `guard(n) and storage_ok`, with `storage_ok` read from the object
before anything is allocated:
* composite lists: `X_append(o, v) = X_app_sz(n, v, Array.size(arr))`, `X_app_sz` tests `U32.is_le(n, sc)`; the cached `_capp` the same (`X_capp_sz`);
* packed lists, byte lists, cells: `X_app_n` -> `X_app_c(v, n, O.words_cap(o))` tests `U32.is_le(ceil(n * es / 4), sc)` (the sum cannot wrap where the count test passes, and its value
  is ignored where it fails); bit lists the same with `O.bits_cap` and `ceil(ceil(k / 8) / 4)`;
* `X_force` / `X_dump`: `min(n, sc)`; `O.dump_bytes` (the packed and bit lists' dump) clamps to the bytes the storage holds.
For every represented object the storage test is the identity (the proofs hold the storage as a perfect tree of depth d with n <= 2^d: `F.u32__pow2u(d)`; for the generic
`-arr` laws the size is a parameter `sc` with the premise `esc: {Array.size(arr) == (arr, sc)}`, as the cell laws take `vc`), so the proofs only gained the rewrite of `Array.size` before
the guard (`capi.bend` `le_store`, `cgrow.bend`, the generated `cached_*` and `cspec_*` files, `coll_api_*`, `coll_seq`, `coll_bits`, `coll_bytes`). The premise-satisfiability witnesses (`e2e/*_api_witness`)
supply `sc` (the 2^d slots of the concrete array); the number of witnessed collection statements is unchanged (374 + 7 root).
Not done: the setter and getter guards (R3-04).

### 8.3 R3-03: what was done and what was not
> **Superseded (size limit, docs/size_limit_statement_diff.md; audit round 6 F9):** the text below describes the 2^31 regime of its time. Since the size limit the marker is 4294967295, a valid object may have up to NMAX = 4294967264 bytes, `_encode` of an invalid object returns the empty buffer (CH-02 fixed, regress case 72) and every fixed-count product is `O.mulc` (R3-03 closed).
`n * element size` is U32 arithmetic in the size pass (`szf`), the validity of the list (`va_cap`) and the writer positions (`pt`: `pos + i * es`) of a list of fixed-size composites,
and it wraps for n >= 2^32 / es (35,495,597 validators of 121 bytes; 22,369,621 pending deposits of 192 bytes). Done: the guard of `_append` and `_capp` for such a list is the
count whose encoding stays below 2^31 bytes (so the API never builds a list that can wrap; `_decode` cannot, the buffer is below 2^32 bytes and refused from 2^31; the setters keep the length).
NOT done: `X_valid`, `szf` and the writers of a HAND-BUILT list beyond that count still wrap, so such a valid hand-built object (storage of 2^25 slots or more: 4.3 GB and up) is accepted by
`_serialize` with a wrapped size (the hunter's repro `pm_r3` cases 7-9 needs 8.4 GB). Why: the refusal has to be a conjunct of `X_valid` and of the size pass, and the proofs reach those
two through the encode record of BeaconState (`OKL_<list>` -> `valid_<list>`, `sizex_<list>`, `putk_rt_<list>`, `putx_<list>W` in `proofs/obj/encx_<list>_generated.bend`, consumed by the
window generators of `container_encoder_windows.py` / `container_encoder_top_laws.py` and their D / O twins). The new fact `n * es < 2^31` is not in `OKL` (a perfect tree of depth < 31 holding n <= 2^dim
elements, and for two of the lists n <= limit); it follows from the record's size bound (`CI.ok_bnd`: the total end <= 2^30; the e2e theorem's `hZ`), which is in scope in the size module
and in the e2e top lemma but not in the writer windows. The proof needs (a) `fit(n) = n < 2^K and n * es < 2^31` as the runtime test (K the least exponent with es * 2^K >= 2^31: 25, 24, 27;
both tests are decided in U32 without a literal Nat comparison: the proof from `Nat.is_lt(Nat.mul(N, es), pw(31))` is symbolic: `fit_of`), (b) a new premise `hLL: LL(A, N) < pw(31)` on `valid_`, `sizex_`, `putk_rt_` and `putx_W`
of the three lists, supplied from `CI.ok_bnd` and the sum `ENDCs` in the size module and from a new premise of the window lemmas in the writer windows, and (c) the same in the O twins. That is the
`OKT`-conjunct change that section 7.2 declined for `words_ok`, for three lists instead of sixty; it adds a hypothesis to the frozen BeaconState encode theorem's windows (derived from `hZ`, not new in the theorem), so it was
not done here without the coordinator's decision. Measured exposure: the hunter's cases 7, 8, 9 are unchanged (size 5832704 for 22,400,000 pending deposits, `valid` 1, `BeaconState_serialize` ok=1).

### 8.4 R3-04: documented
The setters and getters of the 28 collections with API laws (`coll_api_*`) use the claim `n` as the length: `put_at(i < n, ..)`. A storage test there would be a conjunct of `GS` / `GG`, which the read-after-write laws,
the view laws and the root laws (`root_set_law`, `view_set_law`, the cell laws' `GSV` / `HGV`) take as premises or match textually (`GS != 'Bool.and(Bool.and(..'` in `cells_readback`), so it is a larger change than R3-02's
append (where the guard is read once). The consequence of leaving it: an object that claims more than it holds answers `set` / `get` from the word the index mask selects (no abort, no allocation); `X_valid` of
such an object is 0, so `_serialize` refuses it and no honest path reaches it. Recorded in `docs/API_CONTRACTS.md`. `X_cache_at(arr, n, d)` takes `d` as given (the cache laws state it with `d` symbolic).


# Round 4 (agent/crash-hunt-r4, off origin/main 506290081)

Fresh auditor, same rule. Focus: the size arithmetic of agent/size-limit (marker 4294967295, saturating `O.padd`, `O.mulc`, valid objects up to
NMAX = 4294967264 bytes), the decode window of agent/decode-window, differential runs near the new limits, resource blowups. Exclusions: CH-01 .. CH-12,
R2-01 .. R2-06, R3-01 .. R3-04. Machine-readable: the `round4` key of `docs/crash_hunt_findings.json`. No library file was changed. Everything ran on the
server under `agents/crashhunt-r4/`, nice 19, at most 4 programs at a time and one big object at a time, stack 16384 KB, `ulimit -d` 32 to 128 GiB,
120 s timeout (600 s for the 30 to 60 GB runs). Probe: `tools/crash_hunt/pn_r4.bend` (cases 1-19, header), runner `tools/crash_hunt/r4run.sh`, sweep
`tools/crash_hunt/gen_lie_r4.py` + `compile_lie_r4.sh`. `df /srv`: 14 GB free at the end.

## R4.1 Result in one page

| | |
|---|---|
| New findings | **4** (0 high, 1 medium, 3 low) and 2 info |
| CRASH (abort / OOM / hang) | **1** (R4-02) |
| WRONG (accepts, or answers silently wrong) | **3** (R4-01, R4-03 latent, R4-04) |
| INFO | **2** (R4-05 `_valid` admits objects above NMAX, R4-06 stale contract text) |
| Regression of the earlier fixes (`regress.sh`, 57 cases incl. the 4 GiB ones, on 506290081) | **57 of 57 pass** |
| Lying objects at the new limits (`gen_lie_r4.py`: all 102 packed collections, 8 words of storage, claims of round 3 plus NMAX - 1, NMAX, NMAX + 1, 2^32 - 4, 2^32 - 2 and floor(NMAX / es) * es +- es, ops valid / root / serialize / append / set / get / len) | **11,656 runs: 0 abort, 0 hang, 0 runs over 3 GB, 0 slower than 8 s**; the runner's 43 "serialize accepted" verdicts are all claims the 8 words really hold (bit lists of <= 256 bits, vectors of their exact length): honest objects, OK |
| padd saturation (ProgressiveComplexTestStruct, f_D = a 4 GiB-storage `proglist_uint64`, f_C sized so the total is NMAX, NMAX + 1, 2^32 - 2, exactly the marker 2^32 - 1, 2^32 + 5, and NMAX + 2^29 (wrap)) | total NMAX: `ser_ok=1 len=4294967264`, `_encode` the same; every other total: size >= NMAX + 1 or the marker, `ser_ok=0`, `_encode` length 0 (no allocation from the marker). OK |
| append at the bounds, honest 4 GiB storage | `pl_u8` at NMAX - 1: flag 1, length NMAX, then `_serialize` ok with 4,294,967,264 bytes (8.4 GB RSS); at NMAX: flag 0. `pl_u16` at 2,147,483,631 elements: flag 1 (NMAX bytes); at 2,147,483,632: flag 0. OK |
| decode window | `proglist_uint8_decode_checked` of an honest 4 GiB buffer: size NMAX `Some` (len NMAX), NMAX + 1 and 2^32 - 1 `None`. OK (plain `_decode` answers `Some` with a lying object for NMAX + 1 .. 2^32 - 1: CH-05, unchanged, not counted) |
| near-limit roots against the reference (zero-hash formula in Python on the server) | `proglist_uint8` of 2^32 - 4 bytes, `proglist_uint64` of 2^32 - 8 bytes, `List[uint8, 2^40]` of 2^32 - 4 bytes, each with one data word near the end, clean storage: **equal to the reference** (80 s, 4.2 GB each) |
| big honest record lists | `ProgressiveComplexTestStruct_decode_checked` with f_E = 2^26 + 1 .. 1,073,741,808 SmallTestStructs (up to a 4.29 GB input): `Some`, linear (12.6 GB RSS at the top); appends at 2^26 .. 2^29 SmallTestStructs and 2^26 PendingPartialWithdrawals (array grows to depth 27, 6.3 GB): flag 1 |
| union with a 2^32 - 1-bit payload (valid) | `CompatibleUnionBC` size 536,870,917, serialize and encode ok. OK |

The new size arithmetic itself holds where it is used: `padd`, `mulc`, `is_poisoned`, the append bounds and the checked decode window behave at every edge tried.
The findings are in the parts the size-limit change did not touch: a clean-copy allocation that still rounds in U32 (R4-01), an in-memory representation that does not
fit the runtime's heap for the largest inputs the decoder now accepts (R4-02), a `4 * n` left out of `mulc` (R4-03) and a `+ 1` left out of `padd` (R4-04).

## R4.2 Findings, ranked

### R4-02 (MEDIUM, CRASH): `_decode_checked` of a VALID 3.8 to 4.29 GB input aborts the process: the decoded object does not fit the runtime heap
Entry points: `ProgressiveComplexTestStruct_decode_checked` / `_decode` (and `ProgressiveTestStruct`, and every container that holds a list of variable-size elements without a small limit:
`proglist_proglist_VarTestStruct`, `proglist_ProgressiveVarTestStruct`, by the same arithmetic `proglist_VarTestStruct`).
Repro (`pn_r4.bend`, server, `R4_DMEM=134217728 tools/crash_hunt/r4run.sh build/ch/pn4 CASE ARG 0 0 0 600`):
* case 18, ARG = 1,073,741,808: a valid encoding of 4,294,967,262 bytes whose f_F holds 1,073,741,808 empty inner lists (an offset table of equal offsets): **`bend: out of memory`, exit 1, after 74 s at 61.9 GB RSS**.
  ARG = 2^29 (2 GiB input): `Some`, 37.8 GB, 60 s. ARG = 2^24: 1 GB above the 4 GiB input.
* case 19, ARG = 306,783,373: f_H holds 306,783,373 default ProgressiveVarTestStructs (10 bytes each, 4,294,967,252 bytes): **`bend: out of memory`, exit 1, after 52 s at 61.9 GB**. ARG = 2^28 (3.76 GB): `Some`, 56.6 GB.
Why: the decoder builds one boxed element per offset; an empty `proglist_VarTestStruct` costs about 64 bytes of heap for its 4 input bytes, a ProgressiveVarTestStruct about 195 bytes for 14 (amplification 13 to 16).
The native runtime's heap stops at the same 61.9 GB in every run with `ulimit -d` at 128 GiB and 200 GB of free memory on the machine, so the abort is the runtime's heap limit, not the machine's. Before agent/size-limit the window was
below 2^31 bytes (at most 2^29 offsets, 38 GB): the lift to NMAX made these inputs decodable in principle and they now abort. Inputs up to about 3.5 GB of such lists decode.
Fix options (generator, the `_ok` of the variable-size-element lists, or only `_dchw`): (a) a count bound in `X_decode_checked` for a list of variable-size elements (for example 2^28 elements, documented as
a capacity limit next to NMAX), (b) a cheaper representation of an empty element (the default inner list allocates its own array leaf), (c) document the practical limit. (a) touches only the checked entry
(its slop laws, as R2-04 did); the frozen decode statements are about `_decode`.

### R4-01 (LOW, WRONG): a `_valid` packed list above NMAX hashes to a wrong root: the clean-copy path of CH-11 / R2-02 (b) allocates with a wrapping `zeros_for`
Entry points: `_hash_tree_root` / `_root` of the packed lists without a limit: `proglist_uint8`, `proglist_uint16 .. uint128`, `proglist_bool`, `Fulu_list_uint8_1099511627776`, `Fulu_list_uint64_1099511627776`
(measured on `proglist_uint8`, `proglist_uint64`, `List[uint8, 2^40]`).
Repro (`pn_r4.bend` cases 1-6; 4 GiB storage `Array.new(U32, 30n, 0)`, word 2^30 - 3 = 0x11223344 is data, word 2^30 - 1 is a non-zero byte past the length):
`proglist_uint8` claim 4,294,967,292: `valid=1`, root `3092528689,...` (dirty tail) against `2732131542,...` (same bytes, clean storage), and the reference root is `2732131542,...`;
`proglist_uint64` at 4,294,967,288 and `List[uint8, 2^40]` at 4,294,967,292: the same split (clean = reference, dirty differs). 80 s and 4.2 GB each.
Chain: `X_root` -> `words_root` / `words_root_prog` -> `wr_cap` finds the last chunk dirty (`wcn_k`) -> `wr_slow` (covered) -> `wr_clean(words_copy(n, ws))` -> `zeros_for(n)`: `(n + 31) >> 5` wraps for
n > NMAX and the copy gets 8 words; `cc_go` copies 2^30 words into them through the index mask, so every chunk of the root reads the last words of the list.
Why it is reachable: `words_ok` has no upper bound for the lists without a limit (`big`), so `_valid` is 1 for NMAX < n <= 2^32 - 4 in honest 4 GiB storage (R2-02 (a) is only the wrap at 2^32 - 3 .. 2^32 - 1);
the root's precondition is `_valid`. Hand-built objects only (append stops at NMAX, `_decode_checked` refuses the window, plain `_decode` makes a lying object instead: CH-05).
Fix: in `wr_slow` / `wrp_slow` take the clean copy only for n <= NMAX (else the `cap_cnt` path), or size the copy wrap-free (`(n >> 5) + ((n & 31) + 31 >> 5)`, as `bits_nbytes`); or bound `words_ok` by NMAX for
`big` lists (R4-05). Proof impact: the first two change `src/obj.bend` only, under `rep` the copy is never taken above NMAX (`words_canon.bend` is stated for represented objects, below NMAX); the third
changes the `*_valid` statements (the narrowing section 7.2 declined).

### R4-04 (LOW, WRONG, regression of the marker change): a union's `_size` of an invalid payload is 0
Entry points: `CompatibleUnionA_size`, `CompatibleUnionBC_size`, `CompatibleUnionABCA_size` (four `sz*` defs), so `_encode`.
Repro (`pn_r4.bend` case 17): `CompatibleUnionBC_c0{ProgressiveSingleListContainerTestStruct{O.Bits{1-word array, 4294967295 or 1000}}}`: **`size=0`**, `valid=0`, `ser_ok=0`, `enc_len=0`.
Chain: the payload's size pass answers the marker 4294967295 and the union adds the selector byte with a plain `(m + 1 : U32)`, which wraps to 0. With the old marker 2^31 the sum kept bit 31, so this is
the one size site that the marker change made silently wrong. `_serialize` is not affected (the checked writer sees `valid = 0`); `_size` answers a valid-looking 0 and `_encode` allocates nothing and
returns length 0 by accident. No container holds a union today, so no container size under-counts.
Fix (generator, union size): `O.padd(m, 1)`. Proof impact: the union size laws state `m + 1` for a valid payload (size <= NMAX - 1, equal); one rewrite per union.

### R4-03 (LOW, WRONG, latent): `4 * n` of a list of variable-size elements is plain U32
`pl_pl_VarTestStruct_sz_fin` is `O.padd((4 * n : U32), m)` and the writer starts its cursor at `(4 * n : U32)` with offsets `(4 * i : U32)` (all seven variable-size-element lists, `grep "4 \* n"`).
For n >= 2^30 the offset table wraps: 2^30 empty inner lists would have size 0 and `ProgressiveComplexTestStruct_serialize` would answer ok with 30 bytes. Only `proglist_proglist_VarTestStruct` can get there
(its elements may be empty; VarTestStruct and ProgressiveVarTestStruct elements are at least 7 and 9 bytes, so `padd` saturates first), its append bound is `n < 2^32 - 1`, and `_decode` cannot (4 n > NMAX).
Not reachable in practice: building 2^30 honest elements aborts with `bend: out of memory` at 61.9 GB (case 16, 60 s; 2^26 elements: `ser_ok=1 len=268435486`, 4.7 GB).
Fix: `O.mulc(n, 4)` in the size pass (the writer then never runs, the size is the marker), or the append bound `n < floor(NMAX / 4)` for these lists. Proof impact: the var-list size laws and the append guard text of one list.

### R4-05 (INFO): `_valid` = 1 for objects the size limit says cannot exist
`words_ok` has no NMAX bound (big lists, NMAX < n <= 2^32 - 4 in 4 GiB storage), `va_cap` of the fixed-size composite lists tests only the storage (Validator lists of 35,495,598 or more), and a container's
`_valid` does not add its fields' sizes: `ProgressiveComplexTestStruct` with totals NMAX + 1 .. 2^32 + 5 answers `valid=1`, `ser_ok=0`. The contract ("no object of more than NMAX bytes is encodable") holds for
`_serialize`; `_valid` and `_serialize` disagree above NMAX, and `_hash_tree_root` takes `_valid` as its precondition (R4-01). Proposed: state it in docs/API_CONTRACTS.md ("valid does not imply encodable above
NMAX"), or bound `words_ok` for big lists.

### R4-06 (INFO): docs/API_CONTRACTS.md still describes the 2^31 limit in its table
Rows `X_decode_checked` ("`size < 2^31`"), `X_serialize` ("an encoding of 2^31 bytes or more (CH-07: ... bit 31 reserved as the invalid marker, so the largest object is 2^31 - 1 bytes)" and the R3-03 "known gap"),
`X_encode` ("the size pass answers the marker 2^31, which `_encode` allocates (CH-02)") and `X_set` / `X_append` ("the count whose encoding stays below 2^31 bytes (17,747,798 validators, ...)") contradict the
closing paragraph and the code (`size <= 4294967264`, marker 4294967295, `_encode` empty, 35,495,597 validators). Documentation only.

## R4.3 Not findings (checked, behaves)
* No stale marker: no generated type or `src/` file compares a size with 2147483648 (the two hits in `bitvector_31` / `bitvector_511` and `bits_above_zero` are bit masks); every checked writer tests `is_poisoned`.
* `out_done` of `_encode` is only reached when the size pass is not poisoned (`enc_go`): every poisoned total of the padd sweep gave length 0, no 4 GiB allocation.
* `_decode` (plain) of a hand-built `B.Buf` whose size field exceeds its storage still reads aliased words: documented in API_CONTRACTS (`_decode_checked` is the entry for bytes of unknown origin; R2-04).
* Progressive bit lists: the decoder's `len - 1 < 2^29` and the append bound `k < 2^32 - 1` agree; a union holding a 2^32 - 1-bit list serializes at 536,870,917 bytes.

## R4.4 What was run

| run | size | result |
|---|---|---|
| `regress.sh` | 57 cases | 57 of 57 pass on 506290081 |
| `gen_lie_r4.py` (102 programs, compiled with the pinned toolchain, then deleted) | 11,656 runs | 0 CRASH; 43 runner verdicts on honest objects (above) |
| `pn_r4.bend` cases 1-19 | 52 runs, 0.1 s to 80 s, up to 62 GB | R4-01 .. R4-05; the OK rows of R4.1 |
| reference roots (Python, zero-hash formula, server) | 4 roots | clean storage = reference; the dirty tail of R4-01 differs |

Not run: `proglist_VarTestStruct` inside a decode at the limit (same arithmetic as R4-02: about 11 input bytes per element, not measured); the union selectors and hostile byte corpora (rounds 1 and 3 covered
2 million mutants and nothing in the decode-window change touches the validators below the top-level window test).

## R4.5 crash-fix5 (agent/crash-fix5): status

| finding | status | fix | evidence |
|---|---|---|---|
| R4-01 | FIXED | the clean copy of the root path is allocated by `O.zeros_copy(n)` (no wrap of `n + 31`); with R4-05 such an object is also not valid | `pn_r4` cases 1/2 at 4,294,967,292: `valid=0`, dirty root = clean root = the reference `2732131542,...` (before: `3092528689,...` for the dirty tail); `regress.sh` cases 58-60 |
| R4-02 | ACCEPTED by decision (Giulio) | none: a resource limit of the native runtime's heap, documented in docs/API_CONTRACTS.md (`X_decode_checked`) | - |
| R4-03 | FIXED | `O.mul4c(n)` (checked `4 n`) in the size pass of the seven lists of variable-size elements; the writer runs only after a size pass within NMAX | `regress.sh` case 65 (`sz_fin` at 2^30 elements: the marker, was 0) |
| R4-04 | FIXED | `O.padd(m, 1)` in the four union size defs | `pn_r4` case 17: `size=4294967295` (was 0); `regress.sh` case 64 |
| R4-05 | FIXED | `_valid` is 0 above NMAX: packed lists `words_ok(.., NMAX, False{}, ..)`, lists of fixed-size elements and containers / unions that can pass NMAX `X_vsz(X_valid_f(o))` | `regress.sh` cases 59-63 (proglist_uint8 at NMAX + 1: 0, at NMAX: 1; 35,495,598 validators: 0; ProgressiveTestStruct of NMAX + 1 bytes: 0, of NMAX: 1) |
| R4-06 | FIXED | docs/API_CONTRACTS.md rows `X_decode_checked`, `X_serialize`, `X_encode`, `X_hash_tree_root`, `X_set` / `X_append`, `X_take` / `X_ctake` | - |
| manual audit r4 probe p4_size case 17 (`_ctake` then root) | FIXED | the root of an absent box keeps it absent (`(O.BNone{}, D.zero())`; it came back as the default element, so the next root, cached or plain, hashed a default element) | `regress.sh` case 66 (Deposit list, append 3, cache, root, `ctake(1)`: cached root = plain root of the uncached list) |

Audit of every plain `+` on a size (R4-04's class), in the generated `types/` and `src/`: the size passes add with `O.padd` (containers, groups, variable-element
lists, unions now) and multiply with `O.mulc` / `O.mul4c`. The remaining plain additions near a size are not on a value that can be the marker: `(i + 1)` loop
indices; `bits_size` / `bsz_pick` `(k >> 3) + 1` and `(k >> 5) + 1` (a bit count, at most 2^29 + 1); `erp_size` `ew + 7` (a literal element width); the
storage tests `(n + 3) >> 2` of `wsz_pick` / `wk_cap` (n > NMAX is now refused by `_valid` before, and the size pass answers n itself, past NMAX); `fit_sized`
`want + 31` (the append's `(n + 1) * es`, bounded by the append guard); `grow_sized` / `scratch_base` (the hash scratch of a buffer); the writers' cursors
`pos + cur` (they run only after a size pass within NMAX).



# Round 5 (agent/crash-hunt-r5, off origin/main 8bd2fc3e1)

Fresh auditor, same rule, last planned round. Focus: bypasses of the round-4 fixes (`O.zeros_copy` in the root's clean copy, `_valid` vs `_serialize`
around NMAX for every kind with a size check and the containers that nest them, union sizes, `O.mul4c`, `_take` / `_ctake` with the zero-leaf root),
a differential run of objects built through the public setters, and hostile decode with the decode window. Exclusions: CH-01 .. CH-12, R2-01 .. R2-06,
R3-01 .. R3-04, R4-01 .. R4-06; accepted by Giulio and not reported: R4-02 and out-of-memory on huge VALID inputs, the ProgressiveTestStruct /
ProgressiveComplexTestStruct 2^31 decode premise, standalone lists of variable-size elements keeping `_valid` 1 above NMAX. Machine-readable: the
`round5` key of `docs/crash_hunt_findings.json`. No library file was changed. Everything ran on the server under `agents/crashhunt-r5/`, nice 19, at
most 4 programs at a time, stack 16384 KB, 120 s per run (300 s for the 4 GiB-storage runs), one big object at a time. Probes, generators and runners:
`tools/crash_hunt/r5/`. `df /srv`: 14 GB free during the run; built programs deleted at the end.

## R5.1 Result in one page

| | |
|---|---|
| New findings | **1** low (WRONG) and **1** info |
| CRASH (abort / OOM / hang) | **0** |
| WRONG | **1** (R5-01: `_append` into a VALID object with spare storage that is not zero answers `ok` and returns an object `_serialize` refuses) |
| INFO | **1** (R5-02: `O.words_slice(o, p, 0)` runs a 2^32-iteration loop, 2 s, for an empty slice) |
| Regression of the earlier fixes (`regress.sh`, 66 cases incl. the 4 GiB ones, on 8bd2fc3e1) | **66 of 66 pass** |
| (a) root clean copy, every packed kind (`gen_dirty.py`: the 102 packed collections of `gen_packed_diff.SPECS` - bit lists, progressive bit list, bool / uint8 .. uint256 lists and vectors, byte lists, the transaction, lists / vectors of Bytes32, Bytes48 and cells - at 0..69 bytes, the chunk and word boundaries up to 4097 bytes / 8193 bits, the limit and limit - 1, storage depths tight, tight + 1 and tight + 3; every word of storage past the data `0xA5A5A5A5` / `0x01010101` / all ones) | **5,757 runs: 0 abort, 0 root differing from the root of the same bytes in clean roomy storage** (the 297 `valid differs` are bit lists of a multiple of 32 bits whose delimiter word is dirty: not valid by the representation rule, `bits_ok`) |
| (a) `_valid` / `_size` / `_serialize` of the nested containers around NMAX (`ps_r5.bend`: four transactions in lazily shared 1 GiB storage inside ExecutionPayload -> BeaconBlockBody -> BeaconBlock -> SignedBeaconBlock, totals putting each level at NMAX and NMAX + 1, and 2^32 - 1) | each level: size NMAX `valid=1`, NMAX + 1 `valid=0` and the marker above it; the levels below stay valid; `SignedBeaconBlock_serialize` refuses every total above NMAX without allocating (2.4 to 3 s, 4.2 GB RSS of shared storage). OK |
| (a) plain and cached lists in LOCKSTEP (`gen_lock.py`: the 5 boxed kinds with `_take` / `_ctake` and the 13 unboxed cached kinds with `_get` / `_cget`; 400 random steps of append / capp, set / cset, take / ctake (get / cget) at indices 0..19, `root(L) == cached_root(C)` after every step, `root(L) == root(uncache(C))` at the end) | **boxed: 1,500 runs (300 seeds x 5 kinds), unboxed: 1,950 runs (150 seeds x 13 kinds), 0 disagreement** (the cached root is the plain root after take, set, append and take again, through every growth of the array) |
| (a) twin lists for the boxed kinds without a cache (`gen_twin.py`: `proglist_VarTestStruct`, `proglist_ProgressiveVarTestStruct`, `proglist_proglist_VarTestStruct`, `vec_VarTestStruct_2`; one list gets `take(i)` before every `set(i)`) | **800 runs, 0 root differing, both lists valid at the end** |
| (a) union sizes, `O.mul4c`, `O.padd` | read: every union size adds its selector with `O.padd`; no union payload can reach NMAX (largest union: 536,870,917 bytes); the offset tables use `O.mul4c` in the size pass and the writers run only after it (no new site) |
| (b) setter / append CHAINS in one process (`chain.bend.in` + `chain_run.py`: the 28 Fulu fuzz groups compiled with a driver that decodes the start value and then applies the whole chain of `types/obj_fuzz_ops.json` operations without re-decoding; the mirror of `tests_generated/fuzz_objects.py` gives the expected acceptance of every step, bytes and root) | **64 names with operations, 5,120 chains of 60, 200 and 600 steps (1,356,800 operations), 0 differences** in flags, checked encoding or root; every append op run from the empty value to its limit + 2 for the limits up to 8,192 (`--to-limit`: 8 lists incl. the 4,096-cell `DataColumnSidecar.column` and the 8,192 deposit requests): the two past-limit appends refused, OK |
| (c) hostile decode (`hostile_r5.py`: valid values of every name, every offset slot rewritten to 0, 1, 3, 4, its neighbours, len - 1, len, len + 1, 2^31, NMAX - 1, NMAX, NMAX + 1, 2^32 - 4, 2^32 - 1, a cut at every slot and the middle, one and four trailing bytes; the oracle decides) | **Fulu (109 names): 17,615 + 76,480 + 153,272 cases, generic (131 names through a decode-only driver of the 18 generic groups): 33,843 cases; 281,210 in all: 0 abort, 0 disagreement with the oracle, every accepted input re-encodes to itself with the oracle's root** |

The round-4 fixes hold where they were aimed: the clean copy is right at every size and kind tried, the nested size checks agree level by level, the cached roots
follow every take. The one new WRONG is in the appends, which the R2-02 (b) / CH-11 change (valid objects may carry non-zero spare storage) did not revisit.

## R5.2 Findings, ranked

### R5-01 (LOW, WRONG): `_append` into a valid object whose storage past its length is not zero returns `ok` and an object `_serialize` refuses
Entry points: `_append` of every packed list of 1- and 2-byte elements (`proglist_uint8`, `proglist_uint16`, `proglist_bool`, `List[uint8, 2^40]`, `list_uint16_*`,
the byte lists `bytelist_256`, `Fulu_bytelist_32`, `FuluTransaction`) when the length is a multiple of 4, and of every bit list (`bitlist_N`, `Fulu_bitlist_2048`,
`Fulu_bitlist_131072`, `progbitlist`) when the bit count is 31 mod 32; through them the field appends of the containers.
Repro (`tools/crash_hunt/r5/pq_r5.bend`, `SSZ_CASE=1..4`, `SSZ_D=0` dirty / `1` the same data in zero storage):
`pl_u8_append(O.Words{[0xA5A5A5A5 x 4], 4}, 7)`: `valid0=1 append=1 valid1=0 ser_ok=0 ser_size=0`; clean storage: `valid1=1 ser_ok=1 ser_size=5`.
`pl_u16_append` at 4 bytes: the same (clean: 6 bytes). `bits33_append(O.Bits{[0x7FFFFFFF, all ones x 3], 31}, True)` and `pbits_append` of the same:
`valid0=1 append=1 valid1=0 ser_ok=0` (clean: `ser_ok=1 ser_size=5`).
Chain: `X_append` -> `app_c` (guard true) -> `grow` -> `O.words_fit` (`fit_pick` roomy: the array is kept as it is) -> `words_write` at byte n, which merges only
the element's bytes into word n >> 2 (`merge_word`); the other bytes of that word are the old spare storage. The new length makes them bytes of the last word past
the length, which `words_ok` (`tail_zero`) requires to be zero. For a bit list the push of bit 31 of a word makes the next word the delimiter word, which `bits_ok`
requires to be zero above the length.
Why it is reachable: `_valid` accepts non-zero storage past the length (only the rest of the last word must be zero), and the contract says so: "For a valid
object the root is the spec root whatever spare storage it has" (docs/API_CONTRACTS.md, CH-11, R2-02 (b)). Such an object comes from the public constructors
(`O.Words{..}`, `O.Bits{..}`, a container's `set_<field>`); objects built by `_decode` and `_append` alone keep their storage zero, so honest use does not get there.
The result is silent: the append answers `ok`, the root of the new object is right (the clean copy), and only the later `_serialize` refuses (`_valid` 0) a value
the specification encodes.
Fix (runtime): in the roomy branch of the append, clear the spare part of the word the element goes into, i.e. write the element with the mask that also covers the
bytes above it when the new element starts a word (`n & 3 == 0` for 1- and 2-byte elements; `words_setw` of the element instead of `merge_word`), and for a bit
list zero word `(k + 1) >> 5` when the push fills bit 31 of a word. Alternative: take the copying branch (`grow_to`, which copies only `ceil(n / 4)` words into
zero storage) when the word past the data is not zero. Proof impact: for a represented object (zero storage past the length, `words_canon.bend`) the extra clear
writes zero over zero, so the append and read-after-write laws keep their statements; the text of the append writer changes (the per-kind append guard laws
regenerate, as in R2-01).

### R5-02 (INFO): `O.words_slice(o, p, 0)` runs 2^32 iterations for an empty slice
`words_slice` loops `(n + 3 >> 2) - 1` times: for `n = 0` that is 2^32 - 1 iterations (and for `n >= 2^32 - 3`, where `n + 3` wraps, the same). Measured
(`tools/crash_hunt/r5/pr_r5.bend`): `SSZ_CASE=1 SSZ_ARG=0` returns `n=0` after 2.1 s (7.7 MB); `n = 8`: 0.11 s. CH-01 added the empty guard to its sibling
`words_blit` (`bl_some`) but not here. The only generated caller passes 2048 (the cell getter), so no typed entry point reaches it; `O.*` is documented as assuming
the representation invariant of its arguments, which `n = 0` does not violate. Fix: the same guard as `bl_some` (`U32.is_eq(n, 0)` returns the empty Words) and the
wrap-free word count `(n >> 2) + ((n & 3) + 3 >> 2)`; `proofs/obj/cell_rw.bend` states it for `n = 2048` only.

## R5.3 Not findings (checked, behaves)
* Nested NMAX: every container that can pass NMAX has the size test in `_valid` (`maxsize.py`: the 240 names, largest encoding against NMAX: BeaconState,
  BeaconBlockBody, BeaconBlock, SignedBeaconBlock, ExecutionPayload, ProgressiveTestStruct, ProgressiveComplexTestStruct and the 7 progressive packed lists; all
  have it, or `words_ok` with `hi = NMAX`); unions cannot reach NMAX.
* `O.zeros_copy` and `wr_slow` / `wrp_slow`: tight storage (`ceil(n / 4)` words), exactly full storage and spare dirty words, for every packed kind: the root of the bytes.
* The writers read only the `ceil(n / 4)` words of a valid object (`put_words`, the shifted copies stop at `mid <= nw - 1`), so spare storage never reaches an encoding.
* `_decode` (plain) now has the window test `size <= B.size(buf)`; with it and the oracle's verdict, no offset at or near NMAX, no cut and no trailing byte is accepted
  wrongly in any of the 240 names.
* Bit lists of a multiple of 32 bits need a zero delimiter word in storage (`bits_ok`), so a dirty word there makes the object invalid rather than changing its root: by design.

## R5.4 What was run

| run | size | result |
|---|---|---|
| `regress.sh` | 66 cases | 66 of 66 pass on 8bd2fc3e1 |
| `gen_dirty.py` (102 programs) | 5,757 runs | 0 CRASH, 0 WRONG (first pass had a probe bug: a whole last word written at index `n >> 2` past exactly full storage; fixed, rerun) |
| `gen_lock.py` (18 programs) | 3,450 runs x 400 steps | 0 disagreement |
| `gen_twin.py` (4 programs) | 800 runs x 400 steps | 0 disagreement |
| `chain_run.py` (28 chain drivers) | 5,120 chains, 1,356,800 operations; 8 append-to-limit runs | 0 difference |
| `hostile_r5.py` (28 chain drivers + 18 generic decode drivers) | 281,210 cases (240 names) | 0 CRASH, 0 WRONG |
| `pq_r5.bend`, `pr_r5.bend`, `ps_r5.bend` | 8 + 6 + 11 runs | R5-01, R5-02, the nested NMAX rows |

Not run: the 131 generic names through setter chains (they have no fuzz-operation table; their setters were covered by round 3's `gen_packed_diff.py` for the

## R5.5 crash-fix6 (agent/crash-fix6): status

| finding | status | fix | evidence |
|---|---|---|---|
| R5-01 | FIXED | bytes: the append of a 1- or 2-byte element writes with `O.words_write_app` (`O.put_in_app`), which merges into `O.app_old(old, s)` = 0 when the element starts its word (`s = p & 3 = 0`), the old word otherwise; the set keeps `words_write`. Bits: the push ends with `O.bits_close(k, b)`, which writes word `(k >> 5) + 1` back as `O.app_old31(x, k & 31)` = 0 when bit 31 of a word was pushed, the old word otherwise, when that word is inside the storage (after the fit it always is). Both the roomy branch and the copying branch go through it | `regress.sh` cases 67-70 (`pl_u8` / `pl_u16` at 4 bytes and `bits33` / `progbitlist` at 31 bits in `0xA5A5A5A5` / all-ones storage, append: `valid=1 ser_ok=1`, 5 / 6 / 5 / 5 bytes; before: `valid1=0 ser_ok=0`) |
| R5-02 | FIXED | `O.words_slice(o, p, n)` returns `(o, empty)` for `n = 0` (`sl_some`, the guard of `bl_some`) | `regress.sh` case 71 (`words_slice(o, 5, 0)`: `n=0` at once; before: 2.1 s) |

The append laws (`read_append`, `read_append_grow` of the three byte lists and the two bit lists in `proofs/obj/coll_bytes.bend` / `coll_bits.bend`) state the
new storage exactly (`O.app_old`, `BV2.close_t`); for zero spare storage it is the old storage (zero over zero), and the `view_append` laws keep their
statements. List: docs/crash_fix6_statement_diff.md.
packed kinds and by the lockstep / twin probes above for the composite lists); appends to the limits above 8,192 (the 131,072-bit `aggregation_bits` run was stopped at 900 s: the Python mirror copies the whole value per step).
