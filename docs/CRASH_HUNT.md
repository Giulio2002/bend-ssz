# Crash hunt: can the typed object API be made to crash?

Auditor: agent/crash-hunt (off origin/main b1764b5a8). Rule under test: the library must never crash. Every public entry point
(`<Name>_decode`, `_ok`, `_encode`, `_serialize`, `_hash_tree_root`, constructors, getters, setters, list `_append`, the `O.*`
runtime) must return a value or an error value for every input a caller can construct. No library file was changed; the
frozen files (`spec/`, `schemas/`, END_TO_END, ROOT_DOMAIN, PROOF, HASH_PROOF, `frozen.lock.json`, `law-statements.json`) are untouched.
Machine-readable list: `docs/crash_hunt_findings.json`. Raw outputs: `docs/crash_hunt_evidence/`. Probes and runners: `tools/crash_hunt/`.


## 0. Status after the fix series (agent/crash-fix)

| finding | status | what changed | regression |
|---|---|---|---|
| CH-01 | FIXED (statements and lock moved, authorized: docs/crash_hunt_statement_diff.md) | the cell list's setter and appender refuse a cell whose length is not 2048 (guard and `words_blit` on an empty source) | `regress.sh` cases 1-5; `proofs/slop/crash/` laws; regenerated `l4096_b2048_api_*` statements |
| CH-02 | DOCUMENTED, not changed | `_encode` has the precondition `X_valid(o)`; `_serialize` refuses before allocating. A guard in `_encode` or in `O.out_new` changes the unfolding of `out_new(n)` that every encode bridge reasons with at a symbolic `n`; `_serialize` is the checked entry (docs/API_CONTRACTS.md) | - |
| CH-03 | DOCUMENTED, not changed | `_hash_tree_root` has the precondition `X_valid(o)`. Clamping the chunk count to the storage rewrites `words_root`'s `chunks_of(n)` that the root laws of every collection family unfold symbolically; the root of a valid object is the same, only the root of an invalid object differs | - |
| CH-04 | FIXED (statements and lock moved, authorized) | `n + 1 <= N` became `n < min(N, 2^32 - 1)` for every list that can reach 2^32 - 1 | `regress.sh` cases 6-8; `proofs/slop/crash/` laws; regenerated `*_api_append_*` statements |
| CH-05 | FIXED in the checked entry | `X_decode_checked` refuses a window of 2^31 bytes or more; `_decode` itself is unchanged (its statements are frozen and it is the subject of the decode bridges) | `regress.sh` case 11; slop law `decode_checked_2gib_refused` |
| CH-06 | FIXED in the checked entry | `X_decode_checked(buf, size)` refuses `size > B.size(buf)`; `X_decode` keeps its precondition (every decode statement is over `(buf, n)` with the buffer of size n, and a refusing `_decode` would need `n <= n` at every symbolic n) | `regress.sh` cases 9-10; slop laws |
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
