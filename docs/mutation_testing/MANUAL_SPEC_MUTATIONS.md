# Manual, spec-driven mutation audit

Auditor: independent (branch `agent/manual-spec-mutations`). Tree: `origin/main` 9e1c9844 (the tree the automated mutation run closed).
Reference: `ssz/simple-serialize.md` of consensus-specs v1.6.1 (5fa6edcc), read rule by rule, plus the 60 rules of `docs/SPEC_AUDIT.md` section 4.
Nothing in `spec/`, `schemas/`, the frozen roots or any generated file of the real tree was touched: every fault is a patch applied to a private,
hard-linked copy of the import cone on the ssz server. Patches, fault definitions, runner and raw results: `tools/mutation_testing/manual_spec_mutants/`.

The automated campaign asks "does a random edit survive". This audit asks, per rule of the specification: which edit would an implementer who misreads
or mishandles that rule write, and does anything notice. Every fault is a hand-written, rule-specific edit with its reason (`spec:`, `fault:`, `why:`
in the header of its patch).

## 1. Result in one page

| | count |
|---|---|
| Faults (patches, 52 rule slugs, 3 to 12 per rule) | **270** |
| (A) proofs: killed by a named law | **198** (8 of them are behavior-preserving edits that a law mentions textually, see section 6) |
| (A) proofs: UNJUDGED (the checker exhausts its stack on the mutant, with the pinned settings of `tools/check.sh`: no verdict, **not counted as a detection**) | **66** |
| (A) proofs: SURVIVED (`ALL PROOFS CHECK` on every checked facade) | **6** (4 real, 2 equivalent) |
| (B) reference corpus + official vectors, run for all 270: faults the corpus kills / does not kill | 201 (+1 by timeouts only) / 68 |
| Killed **only** by the corpus (proofs survive, corpus kills) | **0** |
| Killed by neither proofs (judged) nor corpus | **5 critical**: 4 survivors (4.1 to 4.4) and 1 unjudged decoder fault that only a probe sees (4.5) |
| Equivalent (no behavior change, argued) | 14 (6 survive A, 8 are killed by A anyway) |

By class (C): proofs 198; unjudged by proofs but killed by the corpus 39; unjudged and the corpus misses it but a differential probe finds a distinguishing input 1 (critical);
unjudged with no difference found by corpus or probe 22 (redundant checks, 4.6); equivalent 6; critical survivors 4.

What the numbers say. The proofs are strong where they are judged (198 of 204 judged faults die, every one on a named law), and they are the only line of defense for
every fault of the *refusal* side of the checked serializer (`<Name>_serialize` on an invalid but representable object): the corpus, built by serializing valid values and mutating
bytes, cannot construct such an object (26 encode-validity faults killed by proofs are invisible to the corpus). The weak spots are (i) four validity checks that no
facade law pins (section 4), (ii) the decoder acceptance side of variable-size types, where 66 faults make the checker diverge instead of fail (section 5), and
(iii) the representativeness of the checked files: 4 of the 6 survivors are in code that other proofs outside the facade cone do pin or may pin (section 6).

## 2. Verdict labels

* **A proofs.** `runner.py`: a private hard-linked copy of the import cone of the facade proof file(s) `proofs/api/<Name>_<op>_proof_generated.bend` (they import the
  `proofs/mutation_coverage/<group>/` laws), the one patched file copied and patched, `tools/check.sh` (pinned checker, 120 s per file, at most 4 at a time at nice 19, only
  while `.fullcheck.lock` was free at start). KILLED: a law no longer checks (its name is listed). UNJUDGED: the checker dies with `RangeError: Maximum call stack size exceeded`
  on the mutant at the pinned settings (`ulimit -s 16384`, JSC 10 MB), and again with 1 GB / 800 MB; all 61 UNJUDGED faults of the first pass were re-run one at a time at the pinned
  settings (`recheck.py`, `results/recheck.json`): all 61 overflow again (the 5 later ones overflowed at their first, pinned run). No fault was counted as killed because of a crash.
  SURVIVED: ALL PROOFS CHECK. 9 early faults that were ill-typed Bend (a scope error or an affine violation in my patch, found because the runtime compiler refused them) were rewritten and re-run;
  every other fault compiles, so every KILLED is a law failure, not a type error.
* **B corpus.** `corpus.py`: the group program(s) of the representative type(s) (`benchmarks/objprog/{x,g}<k>.bend`) compiled from the mutated cone with the 2.0.34 runtime compiler, then the
  48,279-case corpus of `tools/spec_audit` restricted to those types (protocol of `run_bend.py`: decode, re-encode with the checked `<Name>_serialize`, root) and the official vectors of
  those types. Ran for all 270 (cases above 30 KB of hex skipped in the bulk run; the first 29 faults ran with a 200 KB cap).
* **B3 probe.** `probe.py`: for faults the corpus does not kill, the mutant against the unmutated program on up to 17,617 derived inputs (every offset-looking slot rewritten to value-4..value+4, 0, len, len+1, 2^32-1, adjacent-offset swaps, truncations, appended bytes, byte values 00 01 02 7f 80 81 ff).
* **Targeted.** `targeted/oinvalid2.bend` + `targeted.py`: invalid, representable objects built with the record constructors (the technique of `benchmarks/compact/oinvalid.bend`) printing whether `<Name>_serialize` accepted them, 17 expectations, all met by the unmutated tree.
* **(C)** see section 1.

## 3. What could not be instantiated

The 240 names contain no plain `Union`: only `CompatibleUnionA`, `CompatibleUnionBC`, `CompatibleUnionABCA` (selectors 1..127, no `None`). The spec's `Union` rules (`None` only at selector 0, selector 0 with a payload,
`None` with a payload, selectors 128..255 on a plain union, the wrong selector byte for `None`) have no generated code to mutate; they live in `spec/` and are checked only at spec level (`SPEC_AUDIT.md` 4.4).
The same holds for type legality (4.7: `Vector[T,0]`, empty containers, duplicate names) and for the `2**32` size assertion, which exists in the generated code only as 32-bit length arithmetic (faults `s01`).
The faults the brief names for unions are written for the closest generated rule, the compatible-union selector and payload window (`n01` to `n04`).

## 4. CRITICAL findings (nothing judged catches them)

Criterion applied (coordinator): an issue in the object API, with a counterexample built from public calls. `src/obj.bend:1420-1428` documents the contract: the record constructors are ordinary Bend data, "a caller can
build a value no decoder or checked setter would produce: a length over its limit, storage too small, bytes set past its length, a packed boolean above 1", and "the public `{Name}_serialize` refuses an invalid value
instead of truncating, wrapping or merging it". 4.1 to 4.4 are violations of exactly that contract; each was confirmed on the compiled mutant by a targeted case that the unmutated tree passes and the mutant fails.
Full records with patch lines, call chains and reachability: `results/survivors.json`.

### 4.1 `b04-boolean-packed-validity/01`: packed boolean bytes above 1 are accepted by `serialize`

* Patch (`src/obj.bend:1505`, `bo_go`): `U32.is_eq((x .&. 4278124286 : U32), 0)` -> `U32.is_eq((x .&. 4244438268 : U32), 0)` (0xFEFEFEFE -> 0xFCFCFCFC: a byte of 2 or 3 passes).
* Spec rule: boolean is `0x00` or `0x01` (simple-serialize.md 204-209); a Vector[boolean] must never serialize a byte above 1.
* API entry and chain: `vec_bool_5_serialize` -> `vec_bool_5_senc_out(v5_bool_putk(O.out_at(1n), 0, o))` -> `v5_bool_pk(.., v5_bool_valid(o))` -> `v5_bool_valid = O.bools_ok(O.words_ok(o, 5, 5, False{}, 1))` -> `O.bools_ok` -> `O.bo_go` (the mutated constant). Same for `vec_bool_16` and `proglist_bool`.
* Counterexample: `vec_bool_5_e.vec_bool_5_serialize(O.Words{Array.set(U32, Array.new(U32, 2n, 0), 0, 513), 5})` (bytes `01 02 00 00 00`). Baseline: `Encoded{ok = False}`. Mutant: `Encoded{ok = True}` with the bytes `01 02 00 00 00`.
* Reachability: needs a raw `O.Words` (no setter writes a byte above 1, every decoder rejects it); the contract above names this case. Verdict: **critical**.
* Corpus: cannot observe it (decode never yields such an object; 341 cases + 198 vectors pass). Proofs: no proof file mentions the constant; `generic_vec_bool_*` `..._serialize_vsym` states the validity as `O.bools_ok(O.wk_cap(...))` and leaves `O.bools_ok` abstract. Missing: a law `bools_ok(Words{ws, n}) == (every byte of the first n is 0 or 1)`, and an `invalid_objects.py` case.

### 4.2 `c02-fixed-field-offsets/05`: `FixedTestStruct_valid` checks no field

* Patch (`types/FixedTestStruct_encode_ssz_generated.bend:19`): `... FixedTestStruct{+f_A, +f_B, +f_C}: uint8_e.u8_valid(f_A)` -> `... : True{}`.
* Spec rule: a container value is valid only if its fields are (uint8 < 256).
* Chain: `FixedTestStruct_serialize` -> `FixedTestStruct_ser_pick(FixedTestStruct_valid(o), o)`.
* Counterexample: `FixedTestStruct_e.FixedTestStruct_serialize(FixedTestStruct_d.FixedTestStruct{300, O.U64{0, 0}, 0})`: baseline refuses; mutant returns `ok = True` and the 13 bytes `2c 00 ...` (300 truncated). The checked setter `FixedTestStruct_set_f_A(o, 300)` refuses, so this is the raw-constructor case of the contract. Verdict: **critical at facade level**.
* FixedTestStruct is one of **five names whose encode facade has no `serialize_valid` law at all** (FixedTestStruct, SingleFieldTestStruct, SmallTestStruct, ProgressiveSingleFieldContainerTestStruct, FuluBeaconState). The composed file `e2e/FixedTestStruct_e2e_ser_generated.bend` derives the field range from the validity premise (`ltp8(f_A, v)`), which should reject this mutant; **that e2e check was not run** (see section 6).

### 4.3 `c06-container-validity-composition/03` and `/04`: `SmallTestStruct_valid` and `SingleFieldTestStruct_valid`

* `SmallTestStruct_valid`: `Bool.and(uint16_e.u16_valid(f_A), uint16_e.u16_valid(f_B))` -> `uint16_e.u16_valid(f_A)`; counterexample `SmallTestStruct_e.SmallTestStruct_serialize(SmallTestStruct_d.SmallTestStruct{1, 70000})`: baseline refuses, mutant accepts (B truncated to 0x1170). Also checked on the containing names ProgressiveTestStruct and ProgressiveComplexTestStruct (A survives).
* `SingleFieldTestStruct_valid`: `uint8_e.u8_valid(f_A)` -> `True{}`; counterexample `SingleFieldTestStruct{300}`: baseline refuses, mutant returns the byte `2c`. No other name contains this container.
* Same status as 4.2: no facade law, e2e `*_e2e_ser_generated.bend` argued but not run. Verdict: **critical at facade level**.
  (`ProgressiveSingleFieldContainerTestStruct` has the same gap in its own facade but is killed through `CompatibleUnionA`/`ABCA`, law `rt0`.)

### 4.4 Not a survivor after all: `bv03-bitvector-padding-encode/02` (bits-above-length table entry for 5 bits)

`O.bits_above_zero` entry `case 5` (`4294967264` -> `4294967232`): no facade kills it (bitlist_5, BitsStruct, FuluAttestation survive; `bitlist_5_serialize(O.Bits{[32], 5})` accepts a stray bit 5, confirmed). The law that pins the entry exists, `bz_5` in `proofs/obj/bitz.bend`
(it kills the mutant when checked directly: `expected ... U32.and(x, 4294967264)`), but **no facade imports that file**; it is reached only from composed proofs. Classified as killed by a proof outside the facade cone (counted in the 198).

### 4.5 `c03-first-offset-decode/05`: ComplexTestStruct accepts a first offset above the fixed part

* Patch (`types/ComplexTestStruct_decode_ssz_generated.bend:137`): `ComplexTestStruct_c0(U32.is_eq(o0, 71), ...)` -> `ComplexTestStruct_c0(U32.is_le(71, o0), ...)`.
* Spec rule: the first offset must equal the fixed-part size (simple-serialize.md 303-316).
* Counterexample (public decode on bytes): `ComplexTestStruct_decode` on the valid case `B.len1_rand` (104 bytes) with the four bytes at offset 2 set to 73; `results/c03_05_counterexamples.json` holds 76 such byte strings (e.g. the `max` case with first offset 73: `ffff49000000ff4b0000004e000000ff...`). The unmutated program rejects; the mutant returns a decoded object whose re-encoding differs from the input.
* Reachability: public decode of a byte string. Verdict: **critical**. Proofs: UNJUDGED (checker overflow). Corpus: 400 cases and 123 vectors pass; none of them shifts the first offset onto a variable part that can absorb the shift (the corpus mutates offsets of base values whose next part is too short or odd). Missing: corpus cases "first offset = fixed size + 2/4 with a first variable part of at least that many bytes" for every container, and a judged proof of `ok_len` for variable containers.

### 4.6 The other survivors (not critical)

* `f03-attestation-bitlist/06` (Bitvector[64] length check, inside Attestation): equivalent, dead code (`bv64_ok` is never called inside a container; no name is a standalone Bitvector[64]).
* `z01-designed-equivalent/02` (an unused scratch-segment argument of `bits_root`): equivalent by construction (designed control; the other designed control, an output-buffer capacity, is killed by a law that mentions it).

## 5. The 66 UNJUDGED faults

All are validators of variable-size types (offset order and range, first offset, list limit and alignment, union selector and payload window, composite-list offsets). Per rule: `c04` 11, `q01` 10, `n01` 7, `q02` 7, `q03` 7, `l01` 6, `c03` 6, `n02` 4, `l04` 2, `m03` 2, one each in `l02`, `bl04`, `c05`, `c06`.
On the mutant the checker does not report a mismatching law; it recurses until the stack is gone (also with 1 GB). A CI run would fail (non-zero exit), but the failure names no law and gives no counterexample, so it is not counted as a detection.
Of the 66: 39 are killed by the corpus (behavior changes), 1 is the critical 4.5, and 22 show no difference on the corpus and on up to 17,617 probe inputs each: these are checks the later validators make redundant (a decreasing or out-of-range offset
yields a wrapped window length that the child's length-bounded validator rejects). They are *not* proven equivalent in general: for an element type with no length bound the check would matter. Three of the 66 (`c03/04`, `c03/06`, `n01/04`) are marked equivalent with an argument (a too-short input cannot satisfy the later offset checks; an empty union input reads selector 0, which is no option).
An open question for the maintainers: why does a changed comparison in these validators make the checker diverge (the laws appear to normalize a symbolic input until the stack is exhausted)? A bounded-fuel formulation would turn the 66 into judged kills.

## 6. Method findings

* **Representative types decide the verdict for shared code.** Faults in `src/obj.bend` or `src/buffer.bend` survived on the first representative type and died on a second: `bl04/02`, `bl05/03` and `s01/01` died on the FuluAttestation or progbitlist facade after surviving on `bitlist_5`, `bitlist_8` or `bitlist_513`; `u02/01`, `u02/05`, `m03/02`, `m03/05`, `m03/06` and `m03/07` were invisible to the corpus on a standalone `uint16`, `uint32` or `VarTestStruct` (a list at the end of a container has no neighbor bytes) and died on `ComplexTestStruct`. The facade of one name does not import the laws of another, so a helper pinned by FuluAttestation's facade is unpinned in bitlist_5's.
* **Facades are not the whole proof set.** `proofs/obj/bitz.bend` (law `bz_5`) and the composed `e2e/*_e2e_*_generated.bend` files are not imported by any facade. For 4.2 and 4.3 the e2e files were identified from source but not run (below).
* **A-kills can be behavior-preserving.** Proofs are written against the implementation's shape, so they fail for any change of a definition they mention (a larger output buffer, a refactored redundant check): 8 faults marked equivalent are killed by a law.
* **Corpus blind spots measured.** Of the 198 faults killed by proofs, the corpus (run for all 270) also kills 163 and misses 35: 26 encode-validity faults (unreachable by construction: the corpus decodes bytes, so `serialize` only ever sees valid objects), the equivalent ones (`b01/03`, `bl01/02`, `p02/04`, `bl06/01`, `m03/01`, `p01/06`, `u04/03`, `z01/01`) and size-limit faults that need inputs of 512 MiB (`s01/*`). For the 66 UNJUDGED faults the corpus kills 39 and misses 27 (22 redundant checks, 1 real: 4.5, 3 equivalent, 1 timeouts). The 20-fault random sample (seed 20261002, drawn from the faults the proofs rejected) agrees: 17 of 20 killed by the corpus; the 3 others (`bv03/01`, `c06/01`, `l02/03`) are encode-validity faults. The one real hole the probe found in the corpus is 4.5 (a first offset shifted onto a variable part that can absorb it).
* **Blocked by the full-check lock.** From 18:30 the `.fullcheck.lock` was held back to back by other agents' full checks; `queue.sh` (waiting for the lock) has the e2e checks for 4.2, 4.3 and the remaining facade re-runs queued. If they did not run, the e2e verdicts for `c02/05`, `c06/03`, `c06/04` are open and stated as such above.

## 7. The five rules whose faults were hardest to catch

1. **Refusal of invalid objects by the checked serializer** (the contract of `src/obj.bend:1420-1428`): 26 killed-by-proof faults are invisible to the corpus and the repository's finite `invalid_objects.py` (13 survived B2 as well); the proofs pin most but not the packed-boolean scan (4.1).
2. **Container validity composition** for the five names with no `serialize_valid` law (4.2, 4.3).
3. **Variable-size decoder acceptance** (offset order/range, first offset, list limits, union windows): 66 faults leave the checker without a verdict, 1 is a real fault the corpus misses (4.5), 22 are redundant checks.
4. **Bit-level tables and padding** (`bits_above_zero`, `low_mask`, bit-list stray bits): pinned only by `bitz.bend` or per-name facades; a facade of the wrong name sees nothing (4.4).
5. **32-bit size and wrap arithmetic** (`bits_nbytes`, `chunks_of`, the 2^29 bit-list guard, size-pass capacity checks): the corpus cannot reach it (inputs of 512 MiB); only the FuluAttestation facade pins `bits_nbytes`.

## 8. Reproduce

On the ssz server, from a checkout with `tools/mutation_testing/manual_spec_mutants/` and a built `build/` for the corpus programs:

```
python3 tools/mutation_testing/manual_spec_mutants/mk_patches.py TREE tools/mutation_testing/manual_spec_mutants/defs OUT      # definitions -> patches
tools/mutation_testing/manual_spec_mutants/run.sh [--corpus] PATCH...      # A (and B with CASES=cases.jsonl of tools/spec_audit/cases.py), JSON in $OUT
python3 .../probe.py | targeted.py | invalid.py | recheck.py | e2e_check.py | report.py     # the other verdicts and the tables
```

Raw results of this run: `results/{results,corpus,probe,targeted,recheck,survivors,tally,index}.json`, `results/invalid_b2.json`, `results/c03_05_counterexamples.json`.

## 9. Every fault

Columns: A proofs (killed: the failing law and the facade it was found on), B corpus + vectors (cases/vectors that disagree, of those run), other (probe / targeted), C classification.


### uintN: little-endian, exact width, range, root chunk (SSZ 4.1)


`u01-uint-encode-byte-order`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| u01-uint-encode-byte-order/01 | uintN serializes little-endian (byte 0 is the least significant) | uint16 writer emits the high byte first (big-endian, the network-byte-order habit) (`src/obj.bend`) | KILLED: uint16_spec_bytes (uint16 encode) | KILLED (24/44 cases, 6/11 vectors differ) | - | proofs |
| u01-uint-encode-byte-order/02 | uint64 little-endian: low 32-bit limb at the lower address | aligned 64-bit write stores the high limb first (limb order swapped, bytes inside limbs right) (`src/obj.bend`) | KILLED: uint64_spec_bytes (uint64 encode) | KILLED (76/337 cases, 6/33 vectors differ) | - | proofs |
| u01-uint-encode-byte-order/03 | uint64 little-endian, also when the value is at an unaligned offset | the unaligned 64-bit path writes the limbs in swapped order (`src/obj.bend`) | KILLED: FixedTestStruct_spec_bytes (FixedTestStruct encode) | KILLED (151/337 cases, 15/33 vectors differ) | - | proofs |
| u01-uint-encode-byte-order/04 | uint32 little-endian, aligned write | the aligned 32-bit write stores the byte-swapped word (`src/obj.bend`) | KILLED: uint32_spec_bytes (uint32 encode) | KILLED (36/53 cases, 6/11 vectors differ) | - | proofs |
| u01-uint-encode-byte-order/05 | uint128 little-endian: limb 0 is the least significant | the aligned 128-bit writer swaps limbs 0 and 1 (`types/uint128_encode_ssz_generated.bend`) | KILLED: uint128_spec_bytes (uint128 encode) | KILLED (92/142 cases, 5/11 vectors differ) | - | proofs |
| u01-uint-encode-byte-order/06 | uint256 little-endian: limb 7 is the most significant and is written last | the aligned 256-bit writer stores the top two limbs swapped (`types/uint256_encode_ssz_generated.bend`) | KILLED: uint256_spec_bytes (uint256 encode) | KILLED (86/164 cases, 6/11 vectors differ) | - | proofs |
| u01-uint-encode-byte-order/07 | uint256 little-endian; width 32 bytes | the writer reports an encoded length of 31 bytes (one byte short) (`types/uint256_encode_ssz_generated.bend`) | KILLED: uint256_spec_bytes (uint256 encode) | KILLED (147/164 cases, 8/11 vectors differ) | - | proofs |

`u02-uint-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| u02-uint-decode/01 | uint16 decodes exactly its two bytes (the bytes after them belong to the next field) | the 16-bit reader keeps three bytes (mask 0xFFFFFF instead of 0xFFFF) (`src/obj.bend`) | KILLED: uint16_spec_decode (uint16 decode) | KILLED (138/378 cases, 80/106 vectors differ) | probe DISTINGUISHED (1966 inputs) | proofs |
| u02-uint-decode/02 | uint64 little-endian decode: the first limb read is the low one | the 64-bit reader returns (hi, lo) (`src/obj.bend`) | KILLED: FixedTestStruct_spec_decode (FixedTestStruct decode) | KILLED (227/337 cases, 21/33 vectors differ) | - | proofs |
| u02-uint-decode/03 | uint256 little-endian decode | the 256-bit reader swaps limbs 6 and 7 (`types/uint256_decode_ssz_generated.bend`) | KILLED: uint256_spec_decode (uint256 decode) | KILLED (86/164 cases, 6/11 vectors differ) | - | proofs |
| u02-uint-decode/04 | uint128 little-endian decode: the byte at offset 4 starts limb 1 | the 128-bit reader reads limb 1 from offset 8 (skips a limb) (`types/uint128_decode_ssz_generated.bend`) | KILLED: uint128_spec_decode (uint128 decode) | KILLED (88/142 cases, 5/11 vectors differ) | - | proofs |
| u02-uint-decode/05 | uint32 little-endian decode of an SSZ offset or scalar at an unaligned position | the unaligned 4-byte read joins the two words with the wrong shift (8 instead of 16 for a 2-byte misalignment) (`src/buffer.bend`) | KILLED: join2 (uint32 decode) | KILLED (81/387 cases, 68/106 vectors differ) | probe DISTINGUISHED (2012 inputs) | proofs |

`u03-uint-width`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| u03-uint-width/01 | deserialize requires exactly N/8 bytes (short input rejected) | the uint16 length check accepts any length at most 2 (`types/uint16_decode_ssz_generated.bend`) | KILLED: uint16_ok_eval (uint16 decode) | KILLED (5/44 cases, 1/11 vectors differ) | - | proofs |
| u03-uint-width/02 | deserialize requires exactly N/8 bytes (trailing bytes rejected) | the uint64 length check accepts any length at least 8 (`types/uint64_decode_ssz_generated.bend`) | KILLED: uint64_ok_eval (uint64 decode) | KILLED (9/96 cases, 2/11 vectors differ) | - | proofs |
| u03-uint-width/03 | deserialize requires exactly 32 bytes for uint256 | the uint256 length check is removed (`types/uint256_decode_ssz_generated.bend`) | KILLED: uint256_ok_eval (uint256 decode) | KILLED (17/164 cases, 3/11 vectors differ) | - | proofs |
| u03-uint-width/04 | deserialize requires exactly 4 bytes for uint32 | the uint32 length check demands 3 bytes (`types/uint32_decode_ssz_generated.bend`) | KILLED: uint32_ok_eval (uint32 decode) | KILLED (43/53 cases, 9/11 vectors differ) | - | proofs |
| u03-uint-width/05 | deserialize requires exactly one byte for uint8 | the uint8 length check accepts two bytes (a uint16 slip) (`types/uint8_decode_ssz_generated.bend`) | KILLED: uint8_ok_eval (uint8 decode) | KILLED (10/16 cases, 3/11 vectors differ) | - | proofs |
| u03-uint-width/06 | deserialize requires exactly 16 bytes for uint128 | the uint128 length check accepts at least 16 (a uint256 value prefix) (`types/uint128_decode_ssz_generated.bend`) | KILLED: uint128_ok_eval (uint128 decode) | KILLED (9/142 cases, 2/11 vectors differ) | - | proofs |

`u04-uint-range`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| u04-uint-range/01 | a uint8 value is below 2^8; the serializer must not truncate a larger one | the uint8 validity bound is 256 instead of 255 (accepts 256 and truncates it) (`types/uint8_encode_ssz_generated.bend`) | KILLED: uint8_serialize_vdom (uint8 encode) | SURVIVED (0/16 cases, 0/11 vectors differ) | - | proofs |
| u04-uint-range/02 | a uint16 value is below 2^16 | the uint16 validity bound is dropped (any 32-bit word is accepted and truncated on write) (`types/uint16_encode_ssz_generated.bend`) | KILLED: uint16_serialize_vdom (uint16 encode) | SURVIVED (0/44 cases, 0/11 vectors differ) | - | proofs |
| u04-uint-range/03 | single-byte write must keep only the low byte | the byte writer does not mask its argument to 8 bits (`src/obj.bend`) | KILLED: FixedTestStruct_spec_bytes (FixedTestStruct encode) | SURVIVED (0/257 cases, 0/33 vectors differ) | - | proofs - the byte writer is reached by serialize only after u8_valid, so its argument is always <= 255; killed by FixedTestStruct_spec_bytes because that law quantifies over all words |

`u05-uint-root-chunk`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| u05-uint-root-chunk/01 | hash_tree_root of a uintN is its little-endian serialization right-padded to 32 bytes | the 32-bit scalar chunk is built without the byte swap (big-endian value in the first word) (`src/obj.bend`) | KILLED: u32_root (uint16 root) | KILLED (26/44 cases, 7/11 vectors differ) | - | proofs |
| u05-uint-root-chunk/02 | hash_tree_root(uint64) = 8 little-endian bytes then 24 zero bytes | the 64-bit chunk puts the high limb first (`src/obj.bend`) | KILLED: u64_root (uint64 root) | KILLED (76/96 cases, 6/11 vectors differ) | - | proofs |
| u05-uint-root-chunk/03 | hash_tree_root(uint64): the chunk has 24 zero padding bytes | the 64-bit chunk duplicates the low limb into the padding (`src/obj.bend`) | KILLED: u64_root (uint64 root) | KILLED (66/96 cases, 7/11 vectors differ) | - | proofs |
| u05-uint-root-chunk/04 | hash_tree_root(uint256) is its 32 little-endian bytes (no hashing of a single chunk) | the top limb of the 256-bit chunk is not byte-swapped (`types/uint256_hashtreeroot_generated.bend`) | KILLED: st_u256 (uint256 root) | KILLED (82/164 cases, 6/11 vectors differ) | - | proofs |
| u05-uint-root-chunk/05 | hash_tree_root(uint128) is 16 little-endian bytes padded with 16 zero bytes | the padding is not zero: limb 3 is repeated into limb 4 (`types/uint128_hashtreeroot_generated.bend`) | KILLED: st_u128 (uint128 root) | KILLED (103/142 cases, 7/11 vectors differ) | - | proofs |

### boolean


`b01-boolean-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| b01-boolean-decode/01 | boolean decodes only 0x00 and 0x01 | the boolean validator accepts 2 as well (bound 2 instead of 1) (`src/obj.bend`) | KILLED: okb (boolean decode) | KILLED (1/10 cases, 1/6 vectors differ) | - | proofs |
| b01-boolean-decode/02 | boolean decodes only 0x00 and 0x01 (every other byte value is invalid) | the boolean validator accepts every byte value (non-zero is true) (`src/obj.bend`) | KILLED: okb (boolean decode) | KILLED (3/10 cases, 4/6 vectors differ) | - | proofs |
| b01-boolean-decode/03 | boolean 0x01 decodes to true | the boolean reader treats every non-zero byte as true (the validator already rejects >1, so this should be dead in behavior) (`src/obj.bend`) | KILLED: boolean_spec_decode_0 (boolean decode) | SURVIVED (0/10 cases, 0/6 vectors differ) | probe NO-DIFFERENCE (15 inputs) | proofs - the reader runs only after the validator, which admits 0 and 1 only; for those inputs 'v == 1' and 'v != 0' agree. Proof-level: killed by boolean_spec_decode_0 only because the law mentions the reader's text |
| b01-boolean-decode/04 | boolean is exactly one byte | the boolean length check accepts any length at least 1 (trailing bytes ignored) (`types/boolean_decode_ssz_generated.bend`) | KILLED: boolean_ok_eval (boolean decode) | KILLED (4/10 cases, 0/6 vectors differ) | - | proofs |
| b01-boolean-decode/05 | boolean is exactly one byte (empty input is invalid) | the boolean length check accepts the empty input (reads a missing byte as 0 = false) (`types/boolean_decode_ssz_generated.bend`) | KILLED: boolean_ok_eval (boolean decode) | KILLED (1/10 cases, 0/6 vectors differ) | - | proofs |

`b02-boolean-encode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| b02-boolean-encode/01 | true serializes as 0x01 | true is written as 0xFF (`src/obj.bend`) | KILLED: boolean_true_spec_bytes (boolean encode) | KILLED (1/10 cases, 1/6 vectors differ) | - | proofs |
| b02-boolean-encode/02 | false serializes as 0x00, true as 0x01 | the boolean writer writes the byte 1 for false and nothing for true (the arms are swapped) (`src/obj.bend`) | KILLED: boolean_true_spec_bytes (boolean encode) | KILLED (2/10 cases, 2/6 vectors differ) | - | proofs |

`b03-boolean-root`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| b03-boolean-root/01 | hash_tree_root(true) = 0x01 followed by 31 zero bytes | the true chunk has its 1 in the last byte of the first word instead of the first byte (`src/obj.bend`) | KILLED: bool_root (boolean root) | KILLED (1/10 cases, 1/6 vectors differ) | - | proofs |
| b03-boolean-root/02 | hash_tree_root(false) = 32 zero bytes | the false chunk is the true chunk (the arms are swapped) (`src/obj.bend`) | KILLED: bool_root (boolean root) | KILLED (1/10 cases, 1/6 vectors differ) | - | proofs |

`b04-boolean-packed-validity`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| b04-boolean-packed-validity/01 | every boolean byte is 0 or 1 (a packed boolean vector must not hold 2) | the packed-boolean scan lets bit 1 of each byte through (mask 0xFCFCFCFC) (`src/obj.bend`) | SURVIVED | SURVIVED (0/341 cases, 0/198 vectors differ) | targeted KILLED | survivor: critical - documented contract (src/obj.bend:1420-1428) lists exactly this case: 'a packed boolean above 1' must be refused by the public {Name}_serialize |
| b04-boolean-packed-validity/02 | every element of a Vector[boolean, 5] must be 0x00 or 0x01 | the vector validator checks only the first four elements (loop bound n-2 instead of n-1) (`types/vec_bool_5_decode_ssz_generated.bend`) | KILLED: vec_bool_5_at (vec_bool_5 decode) | KILLED (10/88 cases, 8/19 vectors differ) | - | proofs |
| b04-boolean-packed-validity/03 | Vector[boolean, N] has exactly N bytes | the Vector[boolean,5] length check accepts any length at most 5 (`types/vec_bool_5_decode_ssz_generated.bend`) | KILLED: vec_bool_5_ok_eval (vec_bool_5 decode) | KILLED (9/88 cases, 5/19 vectors differ) | - | proofs |

### Vector[T,N]: length


`v01-vector-length-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| v01-vector-length-decode/01 | a Vector[T,N] value has exactly N elements (N*size bytes) | vector validator accepts any length at most 10 bytes (`types/vec_uint16_5_decode_ssz_generated.bend`) | KILLED: vec_uint16_5_ok_eval (vec_uint16_5 decode) | KILLED (13/208 cases, 7/16 vectors differ) | - | proofs |
| v01-vector-length-decode/02 | a Vector[T,N] value has exactly N elements; extra bytes are invalid | vector validator accepts any length at least 10 bytes (`types/vec_uint16_5_decode_ssz_generated.bend`) | KILLED: vec_uint16_5_ok_eval (vec_uint16_5 decode) | KILLED (14/208 cases, 6/16 vectors differ) | - | proofs |
| v01-vector-length-decode/03 | Vector[uint16, 5] is 10 bytes | the reader copies only 8 bytes (a 4-element vector), the fifth element is lost (`types/vec_uint16_5_decode_ssz_generated.bend`) | KILLED: vec_uint16_5_spec_decode (vec_uint16_5 decode) | KILLED (181/208 cases, 3/16 vectors differ) | - | proofs |
| v01-vector-length-decode/04 | Vector[uint64, 5] is exactly 40 bytes | the length check compares against 5 (the element count) instead of 40 bytes (`types/vec_uint64_5_decode_ssz_generated.bend`) | KILLED: vec_uint64_5_ok_eval (vec_uint64_5 decode) | KILLED (220/247 cases, 3/16 vectors differ) | - | proofs |
| v01-vector-length-decode/05 | Vector[byte, 3] is exactly three bytes | the byte-vector length check accepts 4 bytes (rounded up to the word size) (`types/vec_uint8_3_decode_ssz_generated.bend`) | KILLED: vec_uint8_3_ok_eval (vec_uint8_3 decode) | KILLED (20/91 cases, 13/16 vectors differ) | - | proofs |

`v02-vector-length-encode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| v02-vector-length-encode/01 | serializing a Vector[uint16,5] requires exactly five elements | validity accepts a vector of up to 11 bytes (hi bound 11) (`types/vec_uint16_5_encode_ssz_generated.bend`) | KILLED: vec_uint16_5_serialize_vsym (vec_uint16_5 encode) | SURVIVED (0/208 cases, 0/16 vectors differ) | - | proofs |
| v02-vector-length-encode/02 | serializing a Vector[uint16,5] requires exactly five elements | validity accepts a vector of 9 bytes or more (lower bound 9) (`types/vec_uint16_5_encode_ssz_generated.bend`) | KILLED: vec_uint16_5_serialize_vsym (vec_uint16_5 encode) | SURVIVED (0/208 cases, 0/16 vectors differ) | - | proofs |
| v02-vector-length-encode/03 | vector elements are whole uint16s | validity ignores the element size (unit 1 instead of 2) (`types/vec_uint16_5_encode_ssz_generated.bend`) | KILLED: vec_uint16_5_serialize_vsym (vec_uint16_5 encode) | SURVIVED (0/208 cases, 0/16 vectors differ) | - | proofs |
| v02-vector-length-encode/04 | the serialization of Vector[uint16,5] has 10 bytes | the encoder reports 12 bytes (rounded up to a word multiple) (`types/vec_uint16_5_encode_ssz_generated.bend`) | KILLED: vec_uint16_5_spec_bytes (vec_uint16_5 encode) | SURVIVED (0/208 cases, 0/16 vectors differ) | - | proofs |
| v02-vector-length-encode/05 | Vector[byte, 3] has no padding in its serialization | validity accepts any length at most 4 (hi bound 4) (`types/vec_uint8_3_encode_ssz_generated.bend`) | KILLED: vec_uint8_3_serialize_vsym (vec_uint8_3 encode) | SURVIVED (0/91 cases, 0/16 vectors differ) | - | proofs |

### List[T,N]: limit, alignment, tail


`l01-list-limit-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| l01-list-limit-decode/01 | a List[uint16,1024] has at most 1024 elements | the limit check allows 1025 elements (`types/list_uint16_1024_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/334 cases, 0/95 vectors differ) | - | unjudged+corpus |
| l01-list-limit-decode/02 | a List[uint16,1024] may have exactly 1024 elements | the limit check is strict (rejects 1024 elements) (`types/list_uint16_1024_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/334 cases, 15/95 vectors differ) | - | unjudged+corpus |
| l01-list-limit-decode/03 | the list limit counts elements, not bytes | the limit is compared with the byte length (`types/list_uint16_1024_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (2/334 cases, 35/95 vectors differ) | - | unjudged+corpus |
| l01-list-limit-decode/04 | the limit of a List[uint16,1024] is enforced | no limit check at all (`types/list_uint16_1024_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/334 cases, 0/95 vectors differ) | - | unjudged+corpus |
| l01-list-limit-decode/05 | ByteList[256] has at most 256 bytes | the limit check allows 257 bytes (`types/bytelist_256_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/400 cases, 0/123 vectors differ) | - | unjudged+corpus |
| l01-list-limit-decode/06 | ByteList[256] may have exactly 256 bytes | the limit check is strict (`types/bytelist_256_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/400 cases, 12/123 vectors differ) | - | unjudged+corpus |

`l02-list-element-alignment`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| l02-list-element-alignment/01 | the scope of a List[uint16] is a multiple of 2 bytes | no alignment check (odd byte lengths accepted) (`types/list_uint16_1024_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (21/334 cases, 2/95 vectors differ) | - | unjudged+corpus |
| l02-list-element-alignment/02 | list elements are whole; the byte length of a List[uint16] is even | the unit check of a packed collection tests bit 1 instead of bit 0 (`src/obj.bend`) | KILLED: valid (VarTestStruct encode) | KILLED (61/334 cases, 28/95 vectors differ) | - | proofs |
| l02-list-element-alignment/03 | list elements are whole | the unit check is dropped from the packed-collection validity (`src/obj.bend`) | KILLED: words_ok_u64 (VarTestStruct encode) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | proofs |

`l03-list-limit-encode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| l03-list-limit-encode/01 | serializing a List[uint16,1024] with 1025 elements is invalid | the encoder's validity bound is 2050 bytes (1025 elements) (`types/list_uint16_1024_encode_ssz_generated.bend`) | KILLED: valid (VarTestStruct encode) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | proofs |
| l03-list-limit-encode/02 | serializing a List[uint16,1024] with 1024 elements is valid | the encoder's validity bound is 2046 bytes (limit-1) (`types/list_uint16_1024_encode_ssz_generated.bend`) | KILLED: valid (VarTestStruct encode) | KILLED (1/334 cases, 15/95 vectors differ) | - | proofs |
| l03-list-limit-encode/03 | serializing a ByteList[256] of 257 bytes is invalid | the encoder's validity bound is 257 (`types/bytelist_256_encode_ssz_generated.bend`) | KILLED: valid (ComplexTestStruct encode) | SURVIVED (0/400 cases, 0/123 vectors differ) | - | proofs |
| l03-list-limit-encode/04 | list limit is an upper bound on the length | a packed collection is valid at hi (the strict form n < hi) so the limit itself is refused (`src/obj.bend`) | KILLED: words_ok_u64 (VarTestStruct encode) | KILLED (1/334 cases, 15/95 vectors differ) | - | proofs |
| l03-list-limit-encode/05 | list limit is an upper bound on the length | any packed collection is valid regardless of the upper bound (big = True) (`src/obj.bend`) | KILLED: words_ok_u64 (ComplexTestStruct encode) | SURVIVED (0/400 cases, 0/123 vectors differ) | - | proofs |

`l04-list-tail-bytes`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| l04-list-tail-bytes/01 | serialization of a 2-byte-aligned list writes exactly its bytes (nothing past the length) | the tail check of the last storage word tests the wrong shift for a half word (`src/obj.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | unjudged, no difference found |
| l04-list-tail-bytes/02 | serialization contains exactly the bytes of the list | the 2-byte-tail check is weakened (shift 24 instead of 16) (`src/obj.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | unjudged, no difference found |

### Bitvector[N]


`bv01-bitvector-length`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bv01-bitvector-length/01 | Bitvector[5] is exactly 1 byte | length check accepts at most 1 byte (empty accepted) (`types/bitvector_5_decode_ssz_generated.bend`) | KILLED: bitvector_5_ok_eval (bitvector_5 decode) | KILLED (1/28 cases, 0/6 vectors differ) | - | proofs |
| bv01-bitvector-length/02 | Bitvector[9] is exactly 2 bytes | length check accepts 2 or more bytes (trailing bytes ignored) (`types/bitvector_9_decode_ssz_generated.bend`) | KILLED: bitvector_9_ok_eval (bitvector_9 decode) | KILLED (11/46 cases, 0/6 vectors differ) | - | proofs |
| bv01-bitvector-length/03 | Bitvector[512] is exactly 64 bytes | length check demands 65 bytes (N/8+1 as for a bitlist) (`types/Fulu_bitvector_512_decode_ssz_generated.bend`) | KILLED: bitvector_512_ok_eval (bitvector_512 decode) | KILLED (279/290 cases, 6/6 vectors differ) | - | proofs |

`bv02-bitvector-padding-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bv02-bitvector-padding-decode/01 | the unused high bits of the last byte of a Bitvector must be zero (deserialization) | no padding check (`types/bitvector_5_decode_ssz_generated.bend`) | KILLED: bitvector_5_at (bitvector_5 decode) | KILLED (3/28 cases, 3/6 vectors differ) | - | proofs |
| bv02-bitvector-padding-decode/02 | bits 5..7 of the last byte of Bitvector[5] must be zero | the padding mask for 5 used bits is 63 (bit 5 may be set) (`src/obj.bend`) | KILLED: pz5_5 (bitvector_5 decode) | KILLED (1/28 cases, 3/6 vectors differ) | - | proofs |
| bv02-bitvector-padding-decode/03 | bits 1..7 of the second byte of Bitvector[9] must be zero | the padding mask for one used bit is 3 (`src/obj.bend`) | KILLED: pz1_1 (bitvector_9 decode) | KILLED (1/46 cases, 0/6 vectors differ) | - | proofs |
| bv02-bitvector-padding-decode/04 | padding bits are in the last byte | the padding check inspects byte 0 instead of byte 1 (`types/bitvector_9_decode_ssz_generated.bend`) | KILLED: bitvector_9_at (bitvector_9 decode) | KILLED (16/46 cases, 2/6 vectors differ) | - | proofs |
| bv02-bitvector-padding-decode/05 | bit 7 of the last byte of Bitvector[7] must be zero | the padding mask for 7 used bits accepts bit 7 (mask 255) (`src/obj.bend`) | KILLED: pz7_7 (bitvector_7 decode) | KILLED (2/27 cases, 0/3 vectors differ) | - | proofs |
| bv02-bitvector-padding-decode/06 | the padding bits are those above the used bits (bits r..7) | the padding test is inverted: it requires the padding to be non-zero (`src/obj.bend`) | KILLED: bitvector_15_at (bitvector_5 decode) | KILLED (13/28 cases, 6/6 vectors differ) | - | proofs |

`bv03-bitvector-padding-encode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bv03-bitvector-padding-encode/01 | serializing a Bitvector[5] whose value has bits above 5 is invalid (padding must be zero) | the validity bound is 64 (bit 5 allowed) (`types/bitvector_5_encode_ssz_generated.bend`) | KILLED: bitvector_5_serialize_vdom (bitvector_5 encode) | SURVIVED (0/28 cases, 0/6 vectors differ) | - | proofs |
| bv03-bitvector-padding-encode/02 | serializing a Bitlist[5] (or a bit vector) whose last storage word has a set bit between the length and the delimiter position is invalid | the above-N table entry for r=5 masks from bit 6 (a stray bit 5 is accepted) (`src/obj.bend`) | KILLED: bz_5 in proofs/obj/bitz.bend, checked directly with the mutant (no facade imports that file) | SURVIVED (0/79 cases, 0/35 vectors differ) | targeted KILLED | proofs - the facade cone does not contain proofs/obj/bitz.bend, whose law bz_5 pins this table entry (it kills the mutant when checked directly: expected U32.and(x, 4294967264), observed ...232); that file is reached only from composed proofs outside the facades (see section 4.3) |
| bv03-bitvector-padding-encode/03 | a Bitvector[9] value has bits 9..15 clear | the validity bound is 1024 (bit 9 allowed) (`types/bitvector_9_encode_ssz_generated.bend`) | KILLED: bitvector_9_serialize_vdom (bitvector_9 encode) | SURVIVED (0/46 cases, 0/6 vectors differ) | - | proofs |

`bv04-bitvector-root`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bv04-bitvector-root/01 | hash_tree_root(Bitvector[N]) merkleizes the packed bits (little-endian bytes padded to 32) | the packed word is not byte-swapped into the chunk (`types/bitvector_5_hashtreeroot_generated.bend`) | KILLED: bitvector_5_st (bitvector_5 root) | KILLED (9/28 cases, 2/6 vectors differ) | - | proofs |
| bv04-bitvector-root/02 | Bitvector[512] has two chunks; root = hash(chunk0, chunk1) | the two chunks are hashed in the wrong order (`types/Fulu_bitvector_512_hashtreeroot_generated.bend`) | KILLED: st_bv512 (bitvector_512 root) | KILLED (263/290 cases, 1/6 vectors differ) | - | proofs |
| bv04-bitvector-root/03 | Bitvector[512] root has no length mixing | the root mixes in the bit count 512 like a Bitlist (`types/Fulu_bitvector_512_hashtreeroot_generated.bend`) | KILLED: st_bv512 (bitvector_512 root) | KILLED (265/290 cases, 3/6 vectors differ) | - | proofs |

### Bitlist[N]


`bl01-bitlist-delimiter-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bl01-bitlist-delimiter-decode/01 | a Bitlist value's last byte must be non-zero (it holds the delimiter bit) | a zero last byte is accepted (no delimiter required) (`src/obj.bend`) | KILLED: okA (bitlist_5 decode) | KILLED (10/51 cases, 2/29 vectors differ) | - | proofs |
| bl01-bitlist-delimiter-decode/02 | an empty byte string is not a Bitlist value | the empty input is accepted (`src/obj.bend`) | KILLED: okA (bitlist_5 decode) | SURVIVED (0/401 cases, 0/152 vectors differ) | probe NO-DIFFERENCE (4544 inputs) | proofs - for an empty window len - 1 wraps to 2^32 - 1, so the bit-count test (<= limit, or < 2^29 when unbounded) rejects it anyway |
| bl01-bitlist-delimiter-decode/03 | the delimiter is the highest set bit of the last byte (bit 7 counts) | a last byte of exactly 128 is treated as delimiter at bit 6 (`src/obj.bend`) | KILLED: hb7 (bitlist_8 decode) | KILLED (1/56 cases, 1/29 vectors differ) | - | proofs |
| bl01-bitlist-delimiter-decode/04 | a bit list of length n has its delimiter at bit n | the decoder never clears the delimiter, it stays in the value (`src/obj.bend`) | KILLED: rd_go (bitlist_8 decode) | KILLED (30/56 cases, 25/29 vectors differ) | - | proofs |
| bl01-bitlist-delimiter-decode/05 | the number of bits is 8*(len-1) + index of the delimiter | the bit count is taken as 8*(len-1) (the delimiter index is ignored) (`src/obj.bend`) | KILLED: rd_go (bitlist_8 decode) | KILLED (16/56 cases, 12/29 vectors differ) | - | proofs |
| bl01-bitlist-delimiter-decode/06 | the delimiter is the highest set bit of the last byte (last byte 0b10 puts it at bit 1) | the lowest threshold of the high-bit table is 3: a last byte of 2 puts the delimiter at bit 0 (`src/obj.bend`) | KILLED: hb1 (bitlist_5 decode) | KILLED (1/51 cases, 1/29 vectors differ) | - | proofs |

`bl02-bitlist-limit-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bl02-bitlist-limit-decode/01 | a Bitlist[N] has at most N bits | the limit check accepts N+1 bits (`src/obj.bend`) | KILLED: okA (bitlist_5 decode) | KILLED (2/51 cases, 1/29 vectors differ) | - | proofs |
| bl02-bitlist-limit-decode/02 | a Bitlist[N] may have exactly N bits | the limit check is strict (N bits rejected) (`src/obj.bend`) | KILLED: okA (bitlist_5 decode) | KILLED (3/51 cases, 6/29 vectors differ) | - | proofs |
| bl02-bitlist-limit-decode/03 | the Bitlist limit is in bits | the limit is compared with the byte count (`src/obj.bend`) | KILLED: okA (bitlist_513 decode) | KILLED (5/71 cases, 0/25 vectors differ) | - | proofs |
| bl02-bitlist-limit-decode/04 | the Bitlist limit is enforced | the limit check is ignored (always true) (`src/obj.bend`) | KILLED: okA (bitlist_5 decode) | KILLED (23/51 cases, 1/29 vectors differ) | - | proofs |

`bl03-bitlist-encode-delimiter`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bl03-bitlist-encode-delimiter/01 | serialization appends one 1 bit at index len (the delimiter) | no delimiter is written (`src/obj.bend`) | KILLED: put_bits2 (bitlist_5 encode) | KILLED (17/51 cases, 25/29 vectors differ) | - | proofs |
| bl03-bitlist-encode-delimiter/02 | the delimiter is at bit len%8 of byte len/8 (a new byte when len%8==0) | the delimiter is placed at the byte of ceil(len/8) (`src/obj.bend`) | KILLED: put_bits2 (bitlist_8 encode) | KILLED (16/56 cases, 12/29 vectors differ) | - | proofs |
| bl03-bitlist-encode-delimiter/03 | the delimiter is bit number len | the delimiter is bit len+1 (`src/obj.bend`) | KILLED: put_bits2 (bitlist_5 encode) | KILLED (17/51 cases, 25/29 vectors differ) | - | proofs |

`bl04-bitlist-size`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bl04-bitlist-size/01 | a Bitlist of len bits serializes to len/8 + 1 bytes | the size pass reports ceil(len/8) bytes (`src/obj.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (14/56 cases, 13/29 vectors differ) | - | unjudged+corpus |
| bl04-bitlist-size/02 | a Bitlist of len bits serializes to len/8 + 1 bytes | the size pass of the checked serializer reports ceil(len/8) (`src/obj.bend`) | KILLED: encode_eval (progbitlist encode) | KILLED (51/491 cases, 264/737 vectors differ) | - | proofs |

`bl05-bitlist-encode-validity`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bl05-bitlist-encode-validity/01 | serializing a Bitlist[5] with 6 bits is invalid | the validity bound is limit+1 (`src/obj.bend`) | KILLED: bitlist_5_serialize_vover (bitlist_5 encode) | SURVIVED (0/51 cases, 0/29 vectors differ) | - | proofs |
| bl05-bitlist-encode-validity/02 | a Bitlist[5] may have 5 bits | the validity bound is strict (limit-1) (`src/obj.bend`) | KILLED: bitlist_5_serialize_vin (bitlist_5 encode) | KILLED (3/51 cases, 6/29 vectors differ) | - | proofs |
| bl05-bitlist-encode-validity/03 | bits past the length (before the delimiter) must be zero in the value | the stray-bit check on the last word is dropped (`src/obj.bend`) | KILLED: valid_eval (FuluAttestation encode) | SURVIVED (0/486 cases, 0/737 vectors differ) | - | proofs |

`bl06-bitlist-root`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| bl06-bitlist-root/01 | hash_tree_root(Bitlist) = mix_in_length(merkleize(pack_bits(bits)), len): the delimiter is not chunked | the delimiter byte is included in the chunked data (bits_nbytes(k+1)) (`src/obj.bend`) | KILLED: bst (bitlist_5 root) | SURVIVED (0/51 cases, 0/29 vectors differ) | probe NO-DIFFERENCE (134 inputs) | proofs - the extra byte chunked is always zero storage (the delimiter is cleared, bytes past the length are zero); a zero chunk is the virtual padding, so the root is unchanged for every length |
| bl06-bitlist-root/02 | the mixed-in length of a Bitlist is its number of bits | the mixed length counts the delimiter (k+1) (`src/obj.bend`) | KILLED: bst (bitlist_5 root) | KILLED (17/51 cases, 25/29 vectors differ) | - | proofs |
| bl06-bitlist-root/03 | the Bitlist[5] limit is one chunk (depth 0) | the tree depth is 1 (one level too deep) (`types/bitlist_5_hashtreeroot_generated.bend`) | KILLED: bitlist_5_root_correct (bitlist_5 root) | KILLED (17/51 cases, 25/29 vectors differ) | - | proofs |
| bl06-bitlist-root/04 | Bitlist[513] has chunk limit (513+255)//256 = 3, depth 2 | the depth is 1 (floor(513/256)) (`types/bitlist_513_hashtreeroot_generated.bend`) | KILLED: bitlist_513_root_correct (bitlist_513 root) | KILLED (54/71 cases, 25/25 vectors differ) | - | proofs |
| bl06-bitlist-root/05 | Bitlist[513] has chunk limit 3, depth 2 | the depth is 3 (next power of two of the bit limit rounded up twice) (`types/bitlist_513_hashtreeroot_generated.bend`) | KILLED: bitlist_513_root_correct (bitlist_513 root) | KILLED (54/71 cases, 25/25 vectors differ) | - | proofs |
| bl06-bitlist-root/06 | the Bitlist root mixes the length with a 32-byte little-endian chunk | the length chunk is built without byte swap (big-endian) (`src/obj.bend`) | KILLED: mix_bytes (bitlist_513 root) | KILLED (53/71 cases, 20/25 vectors differ) | - | proofs |

### Containers: fixed part, first offset, offsets, variable parts (4.3, 4.8)


`c01-fixed-container-scope`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| c01-fixed-container-scope/01 | a fixed-size container is deserialized from exactly its size (trailing bytes are invalid) | the scope check accepts any length at least 13 (trailing bytes ignored) (`types/FixedTestStruct_decode_ssz_generated.bend`) | KILLED: FixedTestStruct_ok_eval (FixedTestStruct decode) | KILLED (14/241 cases, 1/22 vectors differ) | - | proofs |
| c01-fixed-container-scope/02 | a fixed-size container is deserialized from exactly its size (short input invalid) | the scope check accepts any length at most 13 (`types/FixedTestStruct_decode_ssz_generated.bend`) | KILLED: FixedTestStruct_ok_eval (FixedTestStruct decode) | KILLED (11/241 cases, 0/22 vectors differ) | - | proofs |
| c01-fixed-container-scope/03 | Checkpoint is exactly 40 bytes | the scope check demands 32 (the root size only) (`types/FuluCheckpoint_decode_ssz_generated.bend`) | KILLED: Checkpoint_ok_eval (FuluCheckpoint decode) | KILLED (240/265 cases, 5/5 vectors differ) | - | proofs |
| c01-fixed-container-scope/04 | Checkpoint is exactly 40 bytes | the scope check accepts 40 or more (`types/FuluCheckpoint_decode_ssz_generated.bend`) | KILLED: Checkpoint_ok_eval (FuluCheckpoint decode) | KILLED (14/265 cases, 0/5 vectors differ) | - | proofs |

`c02-fixed-field-offsets`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| c02-fixed-field-offsets/01 | fields of a fixed container are laid out back to back (field C at offset 1+8) | field C is read from offset 8 (overlapping field B) (`types/FixedTestStruct_decode_ssz_generated.bend`) | KILLED: FixedTestStruct_spec_decode (FixedTestStruct decode) | KILLED (173/241 cases, 17/22 vectors differ) | - | proofs |
| c02-fixed-field-offsets/02 | fields of a fixed container are written back to back (field C at offset 9) | field C is written at offset 8 (`types/FixedTestStruct_encode_ssz_generated.bend`) | KILLED: FixedTestStruct_spec_bytes (FixedTestStruct encode) | KILLED (194/241 cases, 18/22 vectors differ) | - | proofs |
| c02-fixed-field-offsets/03 | fields are serialized in declaration order | fields A and C are swapped on the wire (`types/FixedTestStruct_encode_ssz_generated.bend`) | KILLED: FixedTestStruct_spec_bytes (FixedTestStruct encode) | KILLED (193/241 cases, 19/22 vectors differ) | - | proofs |
| c02-fixed-field-offsets/04 | a fixed container serializes to exactly its size | the reported length is 12 (`types/FixedTestStruct_encode_ssz_generated.bend`) | KILLED: FixedTestStruct_spec_bytes (FixedTestStruct encode) | KILLED (216/241 cases, 21/22 vectors differ) | - | proofs |
| c02-fixed-field-offsets/05 | a container value is valid only if all its fields are valid | the container validity checks no field (field A is not range-checked) (`types/FixedTestStruct_encode_ssz_generated.bend`) | SURVIVED | SURVIVED (0/241 cases, 0/22 vectors differ) | targeted KILLED | survivor: critical - the facade has no serialize_valid law (FixedTestStruct is one of five names without one); the composed file e2e/FixedTestStruct_e2e_ser_generated.bend derives the range of field A from the validity premise (ltp8(f_A, v)) and should reject the mutant (see 4.3) |

`c03-first-offset-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| c03-first-offset-decode/01 | the first offset must equal the size of the fixed part (7) | the first offset may be any value at least 7 (gap bytes accepted) (`types/VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (13/334 cases, 0/95 vectors differ) | - | unjudged+corpus |
| c03-first-offset-decode/02 | the first offset must equal the size of the fixed part (7) | the first offset may be any value at most 7 (overlap with the fixed part accepted) (`types/VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (22/334 cases, 0/95 vectors differ) | - | unjudged+corpus |
| c03-first-offset-decode/03 | the first offset must equal the size of the fixed part (7) | the first offset is not checked (`types/VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (35/334 cases, 0/95 vectors differ) | - | unjudged+corpus |
| c03-first-offset-decode/04 | a container shorter than its fixed part is invalid | the minimum length check is 6 instead of 7 (`types/VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/334 cases, 0/95 vectors differ) | probe NO-DIFFERENCE (3308 inputs) | equivalent - a 6-byte input still needs o0 == 7, and 7 > len = 6 makes the list window length wrap to a huge value that the list validator rejects |
| c03-first-offset-decode/05 | the first offset of ComplexTestStruct must be 71 | the first offset check accepts any offset at least 71 (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe DISTINGUISHED (12043 inputs) | unjudged+probe - the corpus has no case that shifts the first offset of ComplexTestStruct onto a variable part that can absorb the shift; the probe finds 76 |
| c03-first-offset-decode/06 | the container is at least as long as its fixed part (71) | the minimum length is 70 (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (17617 inputs) | equivalent - len = 70 < 71: the later offsets must satisfy o1 <= len and o1 >= o0 = 71, which is impossible |

`c04-offset-order-and-range`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| c04-offset-order-and-range/01 | offsets must be non-decreasing | the second offset is only checked against the buffer length (out-of-order accepted) (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found - redundant check: a decreasing offset gives a wrapped window that the child validator (length-bounded) rejects |
| c04-offset-order-and-range/02 | every offset must lie within the buffer | the second offset is not checked against the buffer length (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found - redundant check: see c04/01 |
| c04-offset-order-and-range/03 | equal consecutive offsets are legal (an empty variable part) | offsets must strictly increase (empty variable parts rejected) (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (59/400 cases, 12/123 vectors differ) | - | unjudged+corpus |
| c04-offset-order-and-range/04 | the third offset must not be below the second, nor beyond the buffer | the third offset is not checked at all (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found - redundant check: see c04/01 |
| c04-offset-order-and-range/05 | the last offset must not be beyond the buffer | the last offset may equal len+1 would be allowed (bound is len + 1 via is_le(o3, len+1)) (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found - redundant check: o3 = len + 1 wraps the last window |
| c04-offset-order-and-range/06 | the last offset must be within the buffer | the last offset is not compared with the buffer length (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found - redundant check: o3 > len wraps the last window |
| c04-offset-order-and-range/07 | a variable part ends where the next offset starts | the first variable part (a List[uint16]) is given the rest of the buffer instead of the bytes up to the next offset (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (75/400 cases, 70/123 vectors differ) | - | unjudged+corpus |
| c04-offset-order-and-range/08 | a variable part ends where the next offset starts | the ByteList part is validated with the window up to the end of the buffer (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (4/400 cases, 57/123 vectors differ) | - | unjudged+corpus |
| c04-offset-order-and-range/09 | the last variable part ends at the end of the buffer | the last variable part (Vector[VarTestStruct,2]) is validated without the last byte (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (119/400 cases, 84/123 vectors differ) | - | unjudged+corpus |
| c04-offset-order-and-range/10 | the second offset is stored right after the first one at fixed position 7 | the second offset is read from position 6 (`types/ComplexTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (100/400 cases, 80/123 vectors differ) | - | unjudged+corpus |
| c04-offset-order-and-range/11 | variable-size progressive container: first offset equals the fixed part size (9) | the first offset may be any value at least 9 (`types/ProgressiveVarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/373 cases, 0/134 vectors differ) | - | unjudged+corpus |

`c05-offset-encode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| c05-offset-encode/01 | the offset of the first variable part is the fixed size (7) | the offset written is the fixed size plus 4 (`types/list_uint16_1024_encode_ssz_generated.bend`) | KILLED: putv_f_B (VarTestStruct encode) | KILLED (138/334 cases, 80/95 vectors differ) | - | proofs |
| c05-offset-encode/02 | the offset is written into the fixed part at its slot | the offset is written 4 bytes further (at the slot after the real one) (`types/list_uint16_1024_encode_ssz_generated.bend`) | KILLED: putv_f_B (VarTestStruct encode) | KILLED (138/334 cases, 80/95 vectors differ) | - | proofs |
| c05-offset-encode/03 | the offset of the first variable part equals the fixed-part size (7) | the running offset starts at 8 (`types/VarTestStruct_encode_ssz_generated.bend`) | KILLED: rt_C (VarTestStruct encode) | KILLED (138/334 cases, 80/95 vectors differ) | - | proofs |
| c05-offset-encode/04 | the serialization length is fixed part + variable parts | the size pass starts at 6 (`types/VarTestStruct_encode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (138/334 cases, 80/95 vectors differ) | - | unjudged+corpus |
| c05-offset-encode/05 | field C (uint8) is at fixed offset 6, the offset slot at 2 | field C is written at offset 5 (`types/VarTestStruct_encode_ssz_generated.bend`) | KILLED: rt_C (VarTestStruct encode) | KILLED (81/334 cases, 68/95 vectors differ) | - | proofs |
| c05-offset-encode/06 | the offset is a little-endian uint32 | the aligned 32-bit store (offsets are stored with it) writes big-endian (`src/obj.bend`) | KILLED: w32_anyW (VarTestStruct encode) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | proofs |
| c05-offset-encode/07 | offset i = fixed part + lengths of the variable parts before i | the running offset does not advance past the first variable part (`types/list_uint16_128_encode_ssz_generated.bend`) | KILLED: putv_f_B (ComplexTestStruct encode) | KILLED (57/400 cases, 63/123 vectors differ) | - | proofs |
| c05-offset-encode/08 | offset i = fixed part + lengths of the variable parts before i | the running offset advances by the part length plus one (`types/bytelist_256_encode_ssz_generated.bend`) | KILLED: putv_f_D (ComplexTestStruct encode) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| c05-offset-encode/09 | sizes add up exactly | the checked size accumulator adds one extra byte (`src/obj.bend`) | KILLED: padd_ok (ComplexTestStruct encode) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| c05-offset-encode/10 | variable parts follow the fixed part in field order | not a single-character change: the first fixed-size field is written at the wrong position (pos+1) (`types/ComplexTestStruct_encode_ssz_generated.bend`) | KILLED: rt_C (ComplexTestStruct encode) | KILLED (44/400 cases, 66/123 vectors differ) | - | proofs |

`c06-container-validity-composition`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| c06-container-validity-composition/01 | a container is valid only if every field is valid (the uint8 field C is range-checked) | validity forgets field C (`types/VarTestStruct_encode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | unjudged, no difference found |
| c06-container-validity-composition/02 | serialize refuses an invalid value (the poison flag of field validity reaches the result) | the poison of the scalar fields is not merged into the final flag (`types/VarTestStruct_encode_ssz_generated.bend`) | KILLED: rt_C (VarTestStruct encode) | SURVIVED (0/334 cases, 0/95 vectors differ) | - | proofs |
| c06-container-validity-composition/03 | a container value is valid only if every field is valid (SmallTestStruct has two uint16 fields) | the validity of field B is not checked (`types/SmallTestStruct_encode_ssz_generated.bend`) | SURVIVED | SURVIVED (0/105 cases, 0/22 vectors differ) | targeted KILLED | survivor: critical - same situation as c02/05 for SmallTestStruct (no serialize_valid law in its facade; e2e/SmallTestStruct_e2e_ser_generated.bend) |
| c06-container-validity-composition/04 | a container value is valid only if its field is valid (uint8 range) | the field validity is not checked (`types/SingleFieldTestStruct_encode_ssz_generated.bend`) | SURVIVED | SURVIVED (0/11 cases, 0/22 vectors differ) | targeted KILLED | survivor: critical - SingleFieldTestStruct is a leaf name (no other name contains it) with no serialize_valid law in its facade; e2e/SingleFieldTestStruct_e2e_ser_generated.bend |
| c06-container-validity-composition/05 | a progressive container value is valid only if its field is valid (uint8 range) | the field validity is not checked (`types/ProgressiveSingleFieldContainerTestStruct_encode_ssz_generated.bend`) | KILLED: rt0 (CompatibleUnionA encode) | SURVIVED (0/11 cases, 0/58 vectors differ) | targeted KILLED | proofs |

### Unions (CompatibleUnion; a plain Union is not instantiated in the 240 names)


`n01-union-selector-decode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| n01-union-selector-decode/01 | only the declared selectors are valid; selector 0 is not an option of a CompatibleUnion | selectors up to 1 accepted (selector 0 with a payload reads as option 1) (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (3/48 cases, 6/106 vectors differ) | - | unjudged+corpus |
| n01-union-selector-decode/02 | selectors outside the declared options are invalid (including 128..255) | any selector at least 1 is accepted (out-of-bounds selectors read as option 1) (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (11/48 cases, 42/106 vectors differ) | - | unjudged+corpus |
| n01-union-selector-decode/03 | selectors above 127 must not be accepted | the selector check keeps only the low 7 bits (selector 129 reads as 1) (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (0/48 cases, 6/106 vectors differ) | - | unjudged+corpus |
| n01-union-selector-decode/04 | an empty input is not a union value (no selector byte) | the empty input is accepted (selector read as 0 past the end) (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/48 cases, 0/106 vectors differ) | probe NO-DIFFERENCE (69 inputs) | equivalent - an empty input reads its selector from past the buffer as 0, which is not an option of a CompatibleUnion: rejected by the selector test anyway |
| n01-union-selector-decode/05 | selector 3 selects the third option (ProgressiveVarTestStruct) | selector 4 is validated against the third option too (the test is <= 4 at option 3) (`types/CompatibleUnionABCA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/81 cases, 0/259 vectors differ) | probe NO-DIFFERENCE (592 inputs) | unjudged, no difference found |
| n01-union-selector-decode/06 | the last selector (4) selects the fourth option; selector 5 is invalid | the last selector test is dropped (anything not 1..3 is option 4) (`types/CompatibleUnionABCA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (8/81 cases, 35/259 vectors differ) | - | unjudged+corpus |
| n01-union-selector-decode/07 | selector 2 selects the second option | selector 2 and 3 are swapped in the validator chain (`types/CompatibleUnionABCA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (13/81 cases, 66/259 vectors differ) | - | unjudged+corpus |

`n02-union-payload-window`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| n02-union-payload-window/01 | the payload is the bytes after the selector byte | the payload window length is len (the selector byte counted) (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (7/48 cases, 31/106 vectors differ) | - | unjudged+corpus |
| n02-union-payload-window/02 | the payload starts right after the selector byte | the payload is read from the selector offset (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/48 cases, 0/106 vectors differ) | probe NO-DIFFERENCE (69 inputs) | unjudged, no difference found |
| n02-union-payload-window/03 | the decoded union value holds the payload read after the selector | the reader reads the payload at offset +2 (`types/CompatibleUnionA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (5/48 cases, 28/106 vectors differ) | - | unjudged+corpus |
| n02-union-payload-window/04 | selector 3 payload is a ProgressiveVarTestStruct with its own offsets measured from the payload start | the third option's payload is validated with the selector byte inside the window (`types/CompatibleUnionABCA_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (0/81 cases, 30/259 vectors differ) | - | unjudged+corpus |

`n03-union-encode`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| n03-union-encode/01 | the serialization starts with the selector byte of the option (1) | the selector byte written is 0 (`types/CompatibleUnionA_encode_ssz_generated.bend`) | KILLED: rt0 (CompatibleUnionA encode) | KILLED (6/48 cases, 30/106 vectors differ) | - | proofs |
| n03-union-encode/02 | the serialization starts with the selector byte of the option (1) | the selector byte written is 129 (high bit set) (`types/CompatibleUnionA_encode_ssz_generated.bend`) | KILLED: rt0 (CompatibleUnionA encode) | KILLED (6/48 cases, 30/106 vectors differ) | - | proofs |
| n03-union-encode/03 | the payload follows the selector byte | the payload is written at pos+2 (`types/CompatibleUnionA_encode_ssz_generated.bend`) | KILLED: rt0 (CompatibleUnionA encode) | KILLED (5/48 cases, 28/106 vectors differ) | - | proofs |
| n03-union-encode/04 | the serialization length is 1 + payload length | the size pass reports payload length only (`types/CompatibleUnionA_encode_ssz_generated.bend`) | KILLED: rt0 (CompatibleUnionA encode) | KILLED (6/48 cases, 30/106 vectors differ) | - | proofs |
| n03-union-encode/05 | a union value is valid only if its payload is valid | validity does not check the payload (`types/CompatibleUnionA_encode_ssz_generated.bend`) | KILLED: rt0 (CompatibleUnionA encode) | SURVIVED (0/48 cases, 0/106 vectors differ) | - | proofs |
| n03-union-encode/06 | option 2 is serialized with selector 2 | option 2 is written with selector 3 (`types/CompatibleUnionABCA_encode_ssz_generated.bend`) | KILLED: rt1 (CompatibleUnionABCA encode) | KILLED (12/81 cases, 30/259 vectors differ) | - | proofs |
| n03-union-encode/07 | option 4 is serialized with selector 4 | option 4 is written with selector 1 (`types/CompatibleUnionABCA_encode_ssz_generated.bend`) | KILLED: rt3 (CompatibleUnionABCA encode) | KILLED (1/81 cases, 30/259 vectors differ) | - | proofs |

`n04-union-root`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| n04-union-root/01 | root = mix_in_selector(root(value), selector) with selector 1 | selector 0 is mixed in (`types/CompatibleUnionA_hashtreeroot_generated.bend`) | KILLED: stc_CompatibleUnionA_0 (CompatibleUnionA root) | KILLED (6/48 cases, 30/106 vectors differ) | - | proofs |
| n04-union-root/02 | the root of a union mixes in the selector | no selector is mixed in (the payload root is returned) (`types/CompatibleUnionA_hashtreeroot_generated.bend`) | KILLED: stc_CompatibleUnionA_0 (CompatibleUnionA root) | KILLED (6/48 cases, 30/106 vectors differ) | - | proofs |
| n04-union-root/03 | option 2 mixes in selector 2 | option 2 mixes in selector 1 (`types/CompatibleUnionABCA_hashtreeroot_generated.bend`) | KILLED: stc_CompatibleUnionABCA_1 (CompatibleUnionABCA root) | KILLED (12/81 cases, 30/259 vectors differ) | - | proofs |
| n04-union-root/04 | option 4 mixes in selector 4 | option 4 mixes in selector 3 (`types/CompatibleUnionABCA_hashtreeroot_generated.bend`) | KILLED: stc_CompatibleUnionABCA_3 (CompatibleUnionABCA root) | KILLED (1/81 cases, 30/259 vectors differ) | - | proofs |
| n04-union-root/05 | mix_in_selector(root, selector) = hash(root || selector as a 32-byte chunk) | root and selector chunk are hashed in the wrong order (`src/obj.bend`) | KILLED: mix_bytes (CompatibleUnionBC root) | KILLED (25/190 cases, 60/156 vectors differ) | - | proofs |

### Merkleization: zero hashes, depth from the limit, packing, mix_in_length, container roots (4.6)


`m01-zero-subtree-levels`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| m01-zero-subtree-levels/01 | padding chunks beyond the data are zero subtrees: the virtual node at height d+1 is zero_hash(d+1) | an empty right subtree of height d+1 uses the zero hash of height d (one level too low) (`src/obj.bend`) | KILLED: mt_words (bitlist_513 root) | KILLED (188/405 cases, 80/120 vectors differ) | - | proofs |
| m01-zero-subtree-levels/02 | zero_hash(1) = SHA-256(32 zero bytes || 32 zero bytes) | one word of the constant Z(1) is off by one (`src/digest.bend`) | KILLED: zhex (bitlist_513 root) | KILLED (175/405 cases, 45/120 vectors differ) | - | proofs |
| m01-zero-subtree-levels/03 | zero_hash(2) = SHA-256(zero_hash(1) || zero_hash(1)) | one word of the constant Z(2) is off by one (`src/digest.bend`) | KILLED: zhex (bitlist_513 root) | KILLED (125/405 cases, 29/120 vectors differ) | - | proofs |
| m01-zero-subtree-levels/04 | zero_hash(0) is 32 zero bytes | Z(0) is not zero (first word 1) (`src/digest.bend`) | KILLED: zhex (bitlist_513 root) | KILLED (51/71 cases, 9/25 vectors differ) | - | proofs |
| m01-zero-subtree-levels/05 | a missing leaf is the zero chunk | an out-of-range leaf at the bottom level is Z(1) instead of Z(0) (`src/obj.bend`) | KILLED: mt_words (bitlist_513 root) | KILLED (51/71 cases, 9/25 vectors differ) | - | proofs |

`m02-depth-from-limit`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| m02-depth-from-limit/01 | a Vector[uint64,5] has 2 chunks: depth 1 | depth 0 (a single chunk: the second chunk is dropped) (`types/vec_uint64_5_hashtreeroot_generated.bend`) | KILLED: vec_uint64_5_root_correct (vec_uint64_5 root) | KILLED (220/247 cases, 3/16 vectors differ) | - | proofs |
| m02-depth-from-limit/02 | a Vector[uint64,5] has 2 chunks: depth 1 | depth 2 (padded to 4 chunks) (`types/vec_uint64_5_hashtreeroot_generated.bend`) | KILLED: vec_uint64_5_root_correct (vec_uint64_5 root) | KILLED (220/247 cases, 3/16 vectors differ) | - | proofs |
| m02-depth-from-limit/03 | a Vector[uint16,5] is 10 bytes: one chunk, depth 0 | depth 1 (a spurious zero sibling) (`types/vec_uint16_5_hashtreeroot_generated.bend`) | KILLED: vec_uint16_5_root_correct (vec_uint16_5 root) | KILLED (181/208 cases, 3/16 vectors differ) | - | proofs |
| m02-depth-from-limit/04 | List[uint16,1024] has chunk limit 1024*2/32 = 64: depth 6 regardless of the length | depth 5 (`types/list_uint16_1024_hashtreeroot_generated.bend`) | KILLED: st_VarTestStruct (VarTestStruct root) | KILLED (138/334 cases, 80/95 vectors differ) | - | proofs |
| m02-depth-from-limit/05 | List[uint16,1024] has chunk limit 64: depth 6 | depth 7 (`types/list_uint16_1024_hashtreeroot_generated.bend`) | KILLED: st_VarTestStruct (VarTestStruct root) | KILLED (138/334 cases, 80/95 vectors differ) | - | proofs |
| m02-depth-from-limit/06 | ByteList[256] has chunk limit 8: depth 3 | depth 8 (the byte limit is used as the depth) (`types/bytelist_256_hashtreeroot_generated.bend`) | KILLED: st_ComplexTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| m02-depth-from-limit/07 | List[uint16,128] has chunk limit 8: depth 3 | depth 2 (`types/list_uint16_128_hashtreeroot_generated.bend`) | KILLED: st_ComplexTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| m02-depth-from-limit/08 | Bitlist[131072] has chunk limit 512: depth 9 | depth 8 (`types/Fulu_bitlist_131072_hashtreeroot_generated.bend`) | KILLED: st_Attestation (FuluAttestation root) | KILLED (251/366 cases, 5/5 vectors differ) | - | proofs |
| m02-depth-from-limit/09 | Bitlist[131072] has chunk limit 512: depth 9 | depth 10 (`types/Fulu_bitlist_131072_hashtreeroot_generated.bend`) | KILLED: st_Attestation (FuluAttestation root) | KILLED (251/366 cases, 5/5 vectors differ) | - | proofs |

`m03-chunk-count-packing`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| m03-chunk-count-packing/01 | pack: the chunk count is ceil(bytes/32) | chunk count computed as floor(bytes/32) + 1 style: adds 32 (an extra chunk when bytes is a multiple of 32) (`src/obj.bend`) | KILLED: minimal_view (VarTestStruct root) | SURVIVED (0/734 cases, 0/218 vectors differ) | probe NO-DIFFERENCE (2303 inputs) | proofs - an extra chunk is a zero chunk (storage past the length is zero), identical to the virtual zero padding of the fixed-depth tree |
| m03-chunk-count-packing/02 | pack: the chunk count is ceil(bytes/32) | chunk count computed as (n + 30) / 32 (drops the partial last chunk when bytes = 32k+1) (`src/obj.bend`) | KILLED: minimal_view (VarTestStruct root) | KILLED (14/734 cases, 26/218 vectors differ) | probe NO-DIFFERENCE (2303 inputs) | proofs |
| m03-chunk-count-packing/03 | pack: chunk i holds bytes 32i..32i+31 (eight 32-bit words) | the chunk stride is four words (the leaf i starts at word 4i) (`src/obj.bend`) | KILLED: mt_words (vec_uint64_8 root) | KILLED (205/247 cases, 1/16 vectors differ) | - | proofs |
| m03-chunk-count-packing/04 | mtree combines the left subtree (chunks 0..) with the right subtree (the next chunks) | the right subtree starts at the same chunk as the left one (start not advanced by half the width) (`src/obj.bend`) | KILLED: mt_words (vec_uint64_8 root) | KILLED (218/247 cases, 1/16 vectors differ) | - | proofs |
| m03-chunk-count-packing/05 | the last (partial) chunk is padded with zero bytes: bytes after the data in the last word are zero | the decoder's copy does not mask the last word (the bytes of the next field remain) (`src/obj.bend`) | KILLED: ci_case (VarTestStruct decode) | KILLED (40/734 cases, 59/218 vectors differ) | - | proofs |
| m03-chunk-count-packing/06 | the last partial word keeps only its n mod 4 low bytes | the mask keeps one byte too many (rem+1) (`src/obj.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (38/734 cases, 53/218 vectors differ) | - | unjudged+corpus |
| m03-chunk-count-packing/07 | a list at an unaligned byte offset is copied byte-exact | a copy from a source offset of 3 mod 4 uses the shift for 2 mod 4 (`src/obj.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (144/734 cases, 102/218 vectors differ) | - | unjudged+corpus |
| m03-chunk-count-packing/08 | a list at an unaligned byte offset is written byte-exact | the writer treats every destination as aligned (`src/obj.bend`) | KILLED: put_words_ok (VarTestStruct encode) | KILLED (85/334 cases, 56/95 vectors differ) | - | proofs |

`m04-mix-in-length`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| m04-mix-in-length/01 | mix_in_length(root, length) = hash(root || length as 32-byte little-endian) | the length chunk is built without the byte swap (`src/obj.bend`) | KILLED: mix_bytes (VarTestStruct root) | KILLED (126/334 cases, 67/95 vectors differ) | - | proofs |
| m04-mix-in-length/02 | mix_in_length(root, length) = hash(root || length chunk): root first | operands swapped (`src/obj.bend`) | KILLED: mix_bytes (VarTestStruct root) | KILLED (138/334 cases, 80/95 vectors differ) | - | proofs |
| m04-mix-in-length/03 | the mixed length of a List[uint16] is the element count | the byte length is mixed in (`types/list_uint16_1024_hashtreeroot_generated.bend`) | KILLED: st_VarTestStruct (VarTestStruct root) | KILLED (126/334 cases, 67/95 vectors differ) | - | proofs |
| m04-mix-in-length/04 | the mixed length of a List[uint16] is the element count | the count is divided by 4 (shift by the 32-bit word size) (`types/list_uint16_1024_hashtreeroot_generated.bend`) | KILLED: st_VarTestStruct (VarTestStruct root) | KILLED (126/334 cases, 67/95 vectors differ) | - | proofs |
| m04-mix-in-length/05 | the mixed length of a ByteList is the byte count | the byte count is halved (`types/bytelist_256_hashtreeroot_generated.bend`) | KILLED: st_ComplexTestStruct (ComplexTestStruct root) | KILLED (41/400 cases, 68/123 vectors differ) | - | proofs |
| m04-mix-in-length/06 | mix_in_length is applied once for the list | mix_count mixes the byte length unshifted whatever the element size (`src/obj.bend`) | KILLED: ul_st (ComplexTestStruct root) | KILLED (85/400 cases, 70/123 vectors differ) | - | proofs |

`m05-container-root`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| m05-container-root/01 | a 3-field container pads to 4 leaves with a zero chunk | the fourth leaf is the hash of two zero chunks (Z(1)) instead of the zero chunk (`types/FixedTestStruct_hashtreeroot_generated.bend`) | KILLED: st_FixedTestStruct (FixedTestStruct root) | KILLED (216/241 cases, 21/22 vectors differ) | - | proofs |
| m05-container-root/02 | field roots are merkleized in declaration order | leaves A and B are swapped (`types/FixedTestStruct_hashtreeroot_generated.bend`) | KILLED: st_FixedTestStruct (FixedTestStruct root) | KILLED (201/241 cases, 19/22 vectors differ) | - | proofs |
| m05-container-root/03 | a 3-field container pads to 4 leaves: the tree is ((A,B),(C,0)) | unbalanced tree (A, (B, C)) without padding (`types/FixedTestStruct_hashtreeroot_generated.bend`) | KILLED: st_FixedTestStruct (FixedTestStruct root) | KILLED (216/241 cases, 21/22 vectors differ) | - | proofs |
| m05-container-root/04 | a 2-field container root is hash(root(epoch), root(root)) | the two field roots are swapped (`types/FuluCheckpoint_hashtreeroot_generated.bend`) | KILLED: st_Checkpoint (FuluCheckpoint root) | KILLED (239/265 cases, 5/5 vectors differ) | - | proofs |
| m05-container-root/05 | a 1-field container has chunk_count 1: its root is the field root itself (no hashing) | the single field root is hashed with a zero chunk (`types/SingleFieldTestStruct_hashtreeroot_generated.bend`) | KILLED: st_SingleFieldTestStruct (SingleFieldTestStruct root) | KILLED (5/11 cases, 21/22 vectors differ) | - | proofs |
| m05-container-root/06 | a 7-field container pads to 8 leaves with a zero chunk | the eighth leaf is the hash of two zero chunks (Z(1)) instead of the zero chunk (`types/ComplexTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ComplexTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| m05-container-root/07 | field roots are merkleized in declaration order | leaves E and F are swapped (`types/ComplexTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ComplexTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| m05-container-root/08 | Vector[FixedTestStruct,4] has 4 leaves: depth 2 | depth 1 (only the first two elements are hashed) (`types/vec_FixedTestStruct_4_hashtreeroot_generated.bend`) | KILLED: st_v4_FixedTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |
| m05-container-root/09 | Vector[FixedTestStruct,4] has 4 leaves: depth 2 | depth 3 (padded to 8 leaves) (`types/vec_FixedTestStruct_4_hashtreeroot_generated.bend`) | KILLED: st_v4_FixedTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |

`m06-vector-composite`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| m06-vector-composite/01 | Vector[VarTestStruct,2] has 2 leaves: depth 1 | depth 2 (`types/vec_VarTestStruct_2_hashtreeroot_generated.bend`) | KILLED: st_v2_VarTestStruct (ComplexTestStruct root) | KILLED (100/400 cases, 80/123 vectors differ) | - | proofs |

### Progressive types (4.5)


`p01-progressive-growth`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| p01-progressive-growth/01 | merkleize_progressive: subtree sizes grow by a factor 4 (1, 4, 16, ...) | the subtree depth grows by 1 per level (sizes 1, 2, 4, ...: binary growth) (`src/obj.bend`) | KILLED: pt_run (proglist_uint16 root) | KILLED (8/157 cases, 18/131 vectors differ) | - | proofs |
| p01-progressive-growth/02 | merkleize_progressive: subtree sizes grow by a factor 4 | the depth grows by 3 per level (factor 8) (`src/obj.bend`) | KILLED: pt_run (proglist_uint16 root) | KILLED (8/157 cases, 18/131 vectors differ) | - | proofs |
| p01-progressive-growth/03 | merkleize_progressive starts with num_leaves = 1 (the first subtree has one chunk) | the first subtree has two chunks (start depth 1) (`src/obj.bend`) | KILLED: prog_st (proglist_uint16 root) | KILLED (132/157 cases, 45/131 vectors differ) | - | proofs |
| p01-progressive-growth/04 | merkleize_progressive(chunks) = hash(merkleize_progressive(rest), merkleize(first)): the rest is the LEFT child | the two children are swapped (subtree left, rest right) (`src/obj.bend`) | KILLED: pt_run (proglist_uint16 root) | KILLED (127/157 cases, 35/131 vectors differ) | - | proofs |
| p01-progressive-growth/05 | merkleize_progressive of no chunks is the zero chunk | the empty progressive tree is not special-cased (treated as one zero leaf, hashed) (`src/obj.bend`) | KILLED: prog_st (proglist_uint16 root) | KILLED (1/157 cases, 3/131 vectors differ) | - | proofs |
| p01-progressive-growth/06 | the recursion on the rest continues while chunks remain | fuel bound is too small: only n/2 + 1 steps (`src/obj.bend`) | KILLED: prog_st (proglist_uint16 root) | SURVIVED (0/157 cases, 0/131 vectors differ) | probe NO-DIFFERENCE (1295 inputs) | proofs - the fuel only bounds the recursion; n/2 + 1 steps are more than the log4(n) + 1 levels the progressive tree needs (killed by proofs because a law mentions the fuel expression) |

`p02-progressive-length-mix`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| p02-progressive-length-mix/01 | progressive list root = mix_in_length(merkleize_progressive(chunks), element count) | the byte length is mixed in (`types/proglist_uint16_hashtreeroot_generated.bend`) | KILLED: proglist_uint16_root_correct (proglist_uint16 root) | KILLED (132/157 cases, 45/131 vectors differ) | - | proofs |
| p02-progressive-length-mix/02 | progressive list of uint64 mixes in the element count (bytes / 8) | shift 2 (bytes / 4) (`types/proglist_uint64_hashtreeroot_generated.bend`) | KILLED: proglist_uint64_root_correct (proglist_uint64 root) | KILLED (252/287 cases, 38/135 vectors differ) | - | proofs |
| p02-progressive-length-mix/03 | progressive bitlist: chunks exclude the delimiter | the delimiter byte is chunked (`src/obj.bend`) | KILLED: pst (progbitlist root) | KILLED (3/69 cases, 213/703 vectors differ) | - | proofs |
| p02-progressive-length-mix/04 | a ProgressiveBitlist value is non-empty (it has at least the delimiter byte) | the empty input is accepted (the length test is <= instead of <) (`src/obj.bend`) | KILLED: okA (progbitlist decode) | SURVIVED (0/842 cases, 0/994 vectors differ) | probe NO-DIFFERENCE (11106 inputs) | proofs - same wrap of len - 1 as bl01/02: the 2^29 guard of the unbounded Bitlist rejects the empty window |

`p03-progressive-container`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| p03-progressive-container/01 | mix_in_active_fields: the active_fields [1,0,1,0,1] pack little-endian-bit-first into 0b10101 = 21 | the bits are packed most-significant first (168) (`types/ProgressiveVarTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveVarTestStruct (ProgressiveVarTestStruct root) | KILLED (114/373 cases, 80/134 vectors differ) | - | proofs |
| p03-progressive-container/02 | active_fields marks slots 0, 2 and 4 as present | the active_fields chunk has the three fields densely packed (0b111 = 7) (`types/ProgressiveVarTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveVarTestStruct (ProgressiveVarTestStruct root) | KILLED (114/373 cases, 80/136 vectors differ) | - | proofs |
| p03-progressive-container/03 | inactive slots contribute a zero chunk (EIP-7495): field B is at slot 2, C at slot 4 | inactive slots are omitted: the field roots are packed densely (B right after A) (`types/ProgressiveVarTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveVarTestStruct (ProgressiveVarTestStruct root) | KILLED (114/373 cases, 80/134 vectors differ) | - | proofs |
| p03-progressive-container/04 | merkleize_progressive(field roots): hash(rest, first chunk), the first chunk on the right | the first field root is on the left (`types/ProgressiveVarTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveVarTestStruct (ProgressiveVarTestStruct root) | KILLED (114/373 cases, 80/136 vectors differ) | - | proofs |
| p03-progressive-container/05 | the mixed-in active_fields is a 32-byte chunk | the active_fields is not mixed in (the progressive root is returned) (`types/ProgressiveVarTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveVarTestStruct (ProgressiveVarTestStruct root) | KILLED (114/373 cases, 80/134 vectors differ) | - | proofs |
| p03-progressive-container/06 | active_fields [1] = 0b1: mix_in_active_fields(root, 1) | active_fields chunk is 0 (`types/ProgressiveSingleFieldContainerTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveSingleFieldContainerTestStruct (ProgressiveSingleFieldContainerTestStruct root) | KILLED (5/11 cases, 21/54 vectors differ) | - | proofs |
| p03-progressive-container/07 | merkleize_progressive([A]) = hash(zero, A) | the one-field progressive tree is the field root itself (merkleize, not merkleize_progressive) (`types/ProgressiveSingleFieldContainerTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveSingleFieldContainerTestStruct (ProgressiveSingleFieldContainerTestStruct root) | KILLED (5/11 cases, 21/58 vectors differ) | - | proofs |
| p03-progressive-container/08 | merkleize_progressive([A]) = hash(rest=zero, first=A) | children swapped: hash(A, zero) (`types/ProgressiveSingleFieldContainerTestStruct_hashtreeroot_generated.bend`) | KILLED: st_ProgressiveSingleFieldContainerTestStruct (ProgressiveSingleFieldContainerTestStruct root) | KILLED (4/11 cases, 17/54 vectors differ) | - | proofs |

### Lists and vectors of composite elements (4.2, 4.8)


`q01-composite-list-offsets`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| q01-composite-list-offsets/01 | a list of variable-size elements: the first offset must be a multiple of 4 (offset area is whole 4-byte slots) | the first-offset alignment test is dropped (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/56 vectors differ) | probe NO-DIFFERENCE (12783 inputs) | unjudged, no difference found |
| q01-composite-list-offsets/02 | the first offset must not exceed the buffer | the first-offset range test is dropped (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/56 vectors differ) | probe NO-DIFFERENCE (12783 inputs) | unjudged, no difference found |
| q01-composite-list-offsets/03 | a non-empty list's first offset is at least 4 (at least one offset slot) | the lower bound on the first offset is dropped (first offset 0 gives count 0 with non-empty input) (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/56 vectors differ) | probe NO-DIFFERENCE (12783 inputs) | unjudged, no difference found |
| q01-composite-list-offsets/04 | every element offset is validated (the last pair too) | the validation loop runs one iteration too few (the last element is not validated) (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (27/400 cases, 11/56 vectors differ) | - | unjudged+corpus |
| q01-composite-list-offsets/05 | offsets must be non-decreasing | the non-decreasing test is dropped (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/56 vectors differ) | probe NO-DIFFERENCE (12783 inputs) | unjudged, no difference found |
| q01-composite-list-offsets/06 | offsets must lie within the buffer | the upper-bound test is dropped (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/56 vectors differ) | probe NO-DIFFERENCE (12783 inputs) | unjudged, no difference found |
| q01-composite-list-offsets/07 | equal consecutive offsets give an empty element, which is legal | offsets must strictly increase (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/56 vectors differ) | probe NO-DIFFERENCE (12783 inputs) | unjudged, no difference found |
| q01-composite-list-offsets/08 | each element's window ends at the next offset | the element window length is the end offset b instead of b - a (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (28/400 cases, 4/56 vectors differ) | - | unjudged+corpus |
| q01-composite-list-offsets/09 | the last element ends at the end of the buffer | the last element's end is len-1 in the validation walk (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (35/400 cases, 19/56 vectors differ) | - | unjudged+corpus |
| q01-composite-list-offsets/10 | the element count is first_offset / 4 | the reader's count is first/4 + 1 (storage and count) (`types/proglist_VarTestStruct_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (32/400 cases, 15/56 vectors differ) | - | unjudged+corpus |

`q02-fixed-composite-list`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| q02-fixed-composite-list/01 | a List[ConsolidationRequest, 2] has at most 2 elements | the count limit is 3 (`types/Fulu_list_ConsolidationRequest_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (1/397 cases, 0/5 vectors differ) | - | unjudged+corpus |
| q02-fixed-composite-list/02 | a List[ConsolidationRequest, 2] may have exactly 2 elements | the count limit is strict (`types/Fulu_list_ConsolidationRequest_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (45/397 cases, 1/5 vectors differ) | - | unjudged+corpus |
| q02-fixed-composite-list/03 | the scope of a list of 116-byte elements is a multiple of 116 | the divisibility test is dropped (`types/Fulu_list_ConsolidationRequest_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (10/397 cases, 0/5 vectors differ) | - | unjudged+corpus |
| q02-fixed-composite-list/04 | ConsolidationRequest is 116 bytes | the element size constant is 115 (`types/Fulu_list_ConsolidationRequest_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (71/397 cases, 3/5 vectors differ) | - | unjudged+corpus |
| q02-fixed-composite-list/05 | serializing a List[ConsolidationRequest,2] with 3 elements is invalid | the validity bound is 3 (`types/Fulu_list_ConsolidationRequest_2_encode_ssz_generated.bend`) | KILLED: pvl_l2_ConsolidationRequestW (FuluExecutionRequests encode) | SURVIVED (0/397 cases, 0/5 vectors differ) | - | proofs |
| q02-fixed-composite-list/06 | List[ConsolidationRequest,2] has chunk limit 2: depth 1 | depth 0 (`types/Fulu_list_ConsolidationRequest_2_hashtreeroot_generated.bend`) | KILLED: st_l2_ConsolidationRequest (FuluExecutionRequests root) | KILLED (159/397 cases, 5/5 vectors differ) | - | proofs |
| q02-fixed-composite-list/07 | the list root mixes in the element count | the count mixed in is n+1 (`types/Fulu_list_ConsolidationRequest_2_hashtreeroot_generated.bend`) | KILLED: st_l2_ConsolidationRequest (FuluExecutionRequests root) | KILLED (159/397 cases, 5/5 vectors differ) | - | proofs |
| q02-fixed-composite-list/08 | the first offset of ExecutionRequests equals its fixed part (12) | the first offset test is is_le(12, o0) (`types/FuluExecutionRequests_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (3/397 cases, 0/5 vectors differ) | - | unjudged+corpus |
| q02-fixed-composite-list/09 | offsets must be non-decreasing | the order check of the second offset is dropped (`types/FuluExecutionRequests_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/397 cases, 0/5 vectors differ) | probe NO-DIFFERENCE (9672 inputs) | unjudged, no difference found |
| q02-fixed-composite-list/10 | offsets must lie within the buffer | the bound of the last offset is dropped (`types/FuluExecutionRequests_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/397 cases, 0/5 vectors differ) | probe NO-DIFFERENCE (9672 inputs) | unjudged, no difference found |

### Fulu names: byte vectors, attestation, hash message length


`f01-bytevector-root`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| f01-bytevector-root/01 | pack: the last chunk is right-padded with zero bytes (Bytes48 = 1.5 chunks) | the padding of the partial chunk starts with a 1 byte (PKCS-style padding) (`types/FuluBytes48_hashtreeroot_generated.bend`) | KILLED: st_b48 (FuluBytes48 root) | KILLED (265/290 cases, 0/0 vectors differ) | - | proofs |
| f01-bytevector-root/02 | Bytes48 root = hash(chunk0, chunk1) in order | the two chunks are hashed in swapped order (`types/FuluBytes48_hashtreeroot_generated.bend`) | KILLED: st_b48 (FuluBytes48 root) | KILLED (264/290 cases, 0/0 vectors differ) | - | proofs |
| f01-bytevector-root/03 | 3 chunks pad to 4 leaves with the zero chunk (Z(0)) | the padding leaf is the hash of two zero chunks (Z(1)) (`types/FuluBytes96_hashtreeroot_generated.bend`) | KILLED: st_b96 (FuluBytes96 root) | KILLED (266/291 cases, 0/0 vectors differ) | - | proofs |
| f01-bytevector-root/04 | 3 chunks pad to 4 leaves: the tree is ((c0,c1),(c2,zero)) | no padding: (c0,c1) hashed with c2 directly (`types/FuluBytes96_hashtreeroot_generated.bend`) | KILLED: st_b96 (FuluBytes96 root) | KILLED (266/291 cases, 0/0 vectors differ) | - | proofs |

`f02-hash-message-length`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| f02-hash-message-length/01 | every Merkle node hashes the 64-byte concatenation of its two children | the node message length parameter is 32 (only the left child hashed) (`types/FuluBytes48_hashtreeroot_generated.bend`) | KILLED: Bytes48_root_correct (FuluBytes48 root) | KILLED (265/290 cases, 0/0 vectors differ) | - | proofs |
| f02-hash-message-length/02 | every Merkle node hashes the 64-byte concatenation of its two children | the node message length parameter is 63 (`types/FixedTestStruct_hashtreeroot_generated.bend`) | KILLED: FixedTestStruct_root_correct (FixedTestStruct root) | KILLED (216/241 cases, 21/22 vectors differ) | - | proofs |

`f03-attestation-bitlist`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| f03-attestation-bitlist/01 | aggregation_bits is a Bitlist[131072] | the limit is 131073 (`types/Fulu_bitlist_131072_decode_ssz_generated.bend`) | KILLED: okw (FuluAttestation decode) | KILLED (1/366 cases, 0/5 vectors differ) | - | proofs |
| f03-attestation-bitlist/02 | aggregation_bits may have exactly 131072 bits | the limit is 131071 (`types/Fulu_bitlist_131072_decode_ssz_generated.bend`) | KILLED: okw (FuluAttestation decode) | KILLED (1/366 cases, 0/5 vectors differ) | - | proofs |
| f03-attestation-bitlist/03 | aggregation_bits has a limit | the bitlist is treated as unbounded (big) (`types/Fulu_bitlist_131072_decode_ssz_generated.bend`) | KILLED: okw (FuluAttestation decode) | KILLED (1/366 cases, 0/5 vectors differ) | - | proofs |
| f03-attestation-bitlist/04 | serializing a Bitlist[131072] with more bits is invalid | the validity limit is 131073 (`types/Fulu_bitlist_131072_encode_ssz_generated.bend`) | KILLED: put_eval (FuluAttestation encode) | SURVIVED (0/366 cases, 0/5 vectors differ) | - | proofs |
| f03-attestation-bitlist/05 | Attestation's first offset equals the fixed part size (236) | any first offset at least 236 is accepted (`types/FuluAttestation_decode_ssz_generated.bend`) | KILLED: ok_len (FuluAttestation decode) | KILLED (4/366 cases, 0/5 vectors differ) | - | proofs |
| f03-attestation-bitlist/06 | committee_bits is a Bitvector[64]: exactly 8 bytes | any length at least 8 is accepted (`types/Fulu_bitvector_64_decode_ssz_generated.bend`) | SURVIVED | SURVIVED (0/366 cases, 0/5 vectors differ) | probe NO-DIFFERENCE (8331 inputs); targeted SURVIVED | equivalent - dead code: Bitvector[64]'s own length check bv64_ok is never called inside Attestation (a fixed field is checked by bv64_ok_at after the container checked its total length); no name is a standalone Bitvector[64]. 13,018 probe inputs: no difference |
| f03-attestation-bitlist/07 | aggregation_bits root mixes in the number of bits, not bytes | the length mixed in is the byte count (bits_nbytes) (`src/obj.bend`) | KILLED: bst (FuluAttestation root) | KILLED (143/366 cases, 4/5 vectors differ) | - | proofs |

### Lists and vectors of composite elements (4.2, 4.8)


`q03-vector-of-variable`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| q03-vector-of-variable/01 | a Vector[T,2] of variable-size elements has exactly 2 offsets: the first offset is 8 | the first offset may be any value at least 8 (more elements than N) (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found |
| q03-vector-of-variable/02 | a Vector[T,2] of variable-size elements has exactly 2 offsets: the first offset is 8 | the first offset may be any value at most 8 (fewer elements than N) (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found |
| q03-vector-of-variable/03 | an empty scope is not a Vector[T,2] (a vector has no empty value) | the empty scope is accepted as an empty list would be (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | TIMEOUT-ONLY | probe DISTINGUISHED (12043 inputs) | unjudged+corpus |
| q03-vector-of-variable/04 | designed control: with first == 8 required, the alignment test of the first offset is implied | the alignment test (first mod 4 == 0) is dropped (expected equivalent: first == 8 already implies it) (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | equivalent - first == 8 already implies first mod 4 == 0 |
| q03-vector-of-variable/05 | designed control: with first == 8 required, the bound first <= len is NOT implied (len may be < 8) | the bound first <= len is dropped (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found |
| q03-vector-of-variable/06 | each element's window ends at the next offset | the element window length is the end offset b instead of b - a (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | KILLED (123/400 cases, 83/123 vectors differ) | - | unjudged+corpus |
| q03-vector-of-variable/07 | offsets must be in order and within the buffer | the order test between consecutive offsets is dropped (`types/vec_VarTestStruct_2_decode_ssz_generated.bend`) | UNJUDGED (stack overflow of the checker with the pinned settings) | SURVIVED (0/400 cases, 0/123 vectors differ) | probe NO-DIFFERENCE (12043 inputs) | unjudged, no difference found |

### Designed equivalent controls


`z01-designed-equivalent`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| z01-designed-equivalent/01 | designed control: encoder buffer capacity is not part of the contract (out_at(0n) holds 1 word, 2 bytes need 1 word) | the output buffer is allocated with depth 1 instead of 0 (capacity only) (`types/uint16_encode_ssz_generated.bend`) | KILLED: uint16_encode_capsym (uint16 encode) | SURVIVED (0/44 cases, 0/11 vectors differ) | - | proofs - output buffer capacity only (the length is given separately) |
| z01-designed-equivalent/02 | designed control: the seg parameter is only a scratch-segment index | unused parameter replaced (`src/obj.bend`) | SURVIVED | SURVIVED (0/51 cases, 0/29 vectors differ) | probe NO-DIFFERENCE (134 inputs); targeted SURVIVED | equivalent - the scratch-segment parameter is unused on this path |

### 32-bit size limits


`s01-size-overflow`

| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |
|---|---|---|---|---|---|---|
| s01-size-overflow/01 | the byte count of a Bitlist of n bits is ceil(n/8) for every n (no 32-bit wrap) | ceil(n/8) is computed as (n + 7) >> 3 in 32-bit arithmetic (wraps above 2^32 - 8) (`src/obj.bend`) | KILLED: E3 (bitlist_513 encode) | SURVIVED (0/140 cases, 0/728 vectors differ) | probe NO-DIFFERENCE (7113 inputs); targeted KILLED | proofs |
| s01-size-overflow/02 | a Bitlist without limit still has a bit count that fits 32 bits (8 * (len - 1) + position < 2^32) | the unbounded Bitlist decoder drops the 2^29-byte guard (bit count may wrap) (`src/obj.bend`) | KILLED: okA (progbitlist decode) | SURVIVED (0/69 cases, 0/703 vectors differ) | probe NO-DIFFERENCE (1479 inputs) | proofs |
| s01-size-overflow/03 | pack: the chunk count is ceil(bytes/32) for every byte count below 2^32 | the chunk count is computed in 32-bit arithmetic ((n + 31) wraps above 2^32 - 32) (`src/obj.bend`) | KILLED: minimal_view (VarTestStruct root) | SURVIVED (0/405 cases, 0/120 vectors differ) | probe NO-DIFFERENCE (1964 inputs) | proofs |
| s01-size-overflow/04 | a collection whose storage cannot hold its length is invalid (no out-of-range access, no wrapped size) | the size pass of a packed collection does not check that the storage holds the length (`src/obj.bend`) | KILLED: sizex (VarTestStruct encode) | SURVIVED (0/403 cases, 0/798 vectors differ) | - | proofs |
| s01-size-overflow/05 | a Bitlist whose storage cannot hold its bits is invalid | the bit-list size pass does not check that the storage holds the bits (`src/obj.bend`) | KILLED: encode_eval (progbitlist encode) | SURVIVED (0/435 cases, 0/708 vectors differ) | - | proofs |
