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
| Killed only by the corpus: proofs survive, corpus kills / proofs UNJUDGED, corpus kills | **0** / 39 |
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
  `proofs/slop/<group>/` laws), the one patched file copied and patched, `tools/check.sh` (pinned checker, 120 s per file, at most 4 at a time at nice 19, only
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

`O.bits_above_zero` entry `case 5` (`4294967264` -> `4294967232`): no facade kills it (bitlist_5, BitsStruct, FuluAttestation survive; `bitlist_5_serialize(O.Bits{[32], 5})` accepts a stray bit 5, confirmed). The law that pins the entry exists, `bz_5` in `proofs/obj/bitz_generated.bend`
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
Of the 66: 39 are killed by the corpus (behavior changes), 1 is the critical 4.5, 4 are equivalent with an argument, and 22 show no difference on the corpus and on up to 17,617 probe inputs each: these are checks the later validators make redundant (a decreasing or out-of-range offset
yields a wrapped window length that the child's length-bounded validator rejects). They are *not* proven equivalent in general: for an element type with no length bound the check would matter. Four of the 66 (`c03/04`, `c03/06`, `n01/04`, `q03/04`) are marked equivalent with an argument (a too-short input cannot satisfy the later offset checks; an empty union input reads selector 0, which is no option; `first == 8` implies the alignment test).
An open question for the maintainers: why does a changed comparison in these validators make the checker diverge (the laws appear to normalize a symbolic input until the stack is exhausted)? A bounded-fuel formulation would turn the 66 into judged kills.

## 6. Method findings

* **Representative types decide the verdict for shared code.** Faults in `src/obj.bend` or `src/buffer.bend` survived on the first representative type and died on a second: `bl04/02`, `bl05/03` and `s01/01` died on the FuluAttestation or progbitlist facade after surviving on `bitlist_5`, `bitlist_8` or `bitlist_513`; `u02/01`, `u02/05`, `m03/02`, `m03/05`, `m03/06` and `m03/07` were invisible to the corpus on a standalone `uint16`, `uint32` or `VarTestStruct` (a list at the end of a container has no neighbor bytes) and died on `ComplexTestStruct`. The facade of one name does not import the laws of another, so a helper pinned by FuluAttestation's facade is unpinned in bitlist_5's.
* **Facades are not the whole proof set.** `proofs/obj/bitz_generated.bend` (law `bz_5`) and the composed `e2e/*_e2e_*_generated.bend` files are not imported by any facade. For 4.2 and 4.3 the e2e files were identified from source but not run (below).
* **A-kills can be behavior-preserving.** Proofs are written against the implementation's shape, so they fail for any change of a definition they mention (a larger output buffer, a refactored redundant check): 8 faults marked equivalent are killed by a law.
* **Corpus blind spots measured.** Of the 198 faults killed by proofs, the corpus (run for all 270) also kills 163 and misses 35: 26 encode-validity faults (unreachable by construction: the corpus decodes bytes, so `serialize` only ever sees valid objects), the equivalent ones (`b01/03`, `bl01/02`, `p02/04`, `bl06/01`, `m03/01`, `p01/06`, `u04/03`, `z01/01`) and size-limit faults that need inputs of 512 MiB (`s01/*`). For the 66 UNJUDGED faults the corpus kills 39 and misses 27 (22 redundant checks, 1 real: 4.5, 3 equivalent, 1 timeouts). The 20-fault random sample (seed 20261002, drawn from the faults the proofs rejected) agrees: 17 of 20 killed by the corpus; the 3 others (`bv03/01`, `c06/01`, `l02/03`) are encode-validity faults. The one real hole the probe found in the corpus is 4.5 (a first offset shifted onto a variable part that can absorb it).
* **Blocked by the full-check lock.** From about 18:30 to 19:05 the `.fullcheck.lock` was held back to back by other agents' full checks, so the composed e2e checks for 4.2 and 4.3 (`e2e/{FixedTestStruct,SmallTestStruct,SingleFieldTestStruct}_e2e_ser_generated.bend`, queued in `queue.sh`) and the facade re-run of the 5 latest UNJUDGED faults did not run; the queue was cancelled. The e2e verdicts for `c02/05`, `c06/03`, `c06/04` are therefore open: by reading, the `ser` file derives the field range from the validity premise (`ltp8(f_A, v)`) and should reject these mutants; if it does, they move from critical to killed by proofs outside the facades. `e2e_check.py` runs them in under 2 minutes once the lock is free.

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
| bv03-bitvector-padding-encode/02 | serializing a Bitlist[5] (or a bit vector) whose last storage word has a set bit between the length and the delimiter position is invalid | the above-N table entry for r=5 masks from bit 6 (a stray bit 5 is accepted) (`src/obj.bend`) | KILLED: bz_5 in proofs/obj/bitz_generated.bend, checked directly with the mutant (no facade imports that file) | SURVIVED (0/79 cases, 0/35 vectors differ) | targeted KILLED | proofs - the facade cone does not contain proofs/obj/bitz_generated.bend, whose law bz_5 pins this table entry (it kills the mutant when checked directly: expected U32.and(x, 4294967264), observed ...232); that file is reached only from composed proofs outside the facades (see section 4.3) |
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

# Round 2 (agent/manual-spec-mutations-r2)

Auditor: independent, fresh (round 2). Base: `origin/main` d21616e2b; the `O.cap_cnt` faults (area 6) are against the crash-fix2 tip 29af0ebcc.
Machine-readable: `docs/mutation_testing/manual_round_2_survivors.json` (every fault the proofs did not kill: 96 entries). Patches:
`tools/mutation_testing/manual_spec_mutants/patches/r2-*` (317 faults, 33 rule slugs), definitions `defs/r2_0*.txt`, drivers `r2/`
(`run2.py`, `apiprobe.py`, `baseline.py`, `report2.py`), probes `r2/probes/*.bend`, raw results `results/r2/` (all 317 rows: `round2_section.md`).
None of the 270 round-1 faults or 8 round-1 survivors is repeated (13 of my first drafts duplicated round-1 faults and were removed before running).

## R2.1 Result

| | count |
|---|---|
| Faults | **317** (302 on d21616e2b, 15 on 29af0ebcc) |
| (A) killed by a named law | **221** (all 63 killing roots re-checked unmutated: they pass, `results/r2/baseline.json`; the 15 fix2 faults were killed by `words_cap.bend`/`cells.bend`, whose baseline is the fix2 tip's own check) |
| (A) survived every checked root | **71** |
| (A) UNJUDGED (checker stack overflow at the pinned settings, or timeout; not a kill) | **25** |
| (B') API probe (public X_append/X_set/X_get/X_len/X_serialize/X_decode_checked driven by `r2/probes/*.bend`): kills among the 96 non-killed | **26** (all became critical) |
| Verdict critical | 28 |

Method change that matters: round 1 judged a fault only against the facade files `proofs/api/<Name>_<op>_proof_generated.bend`. The laws about
collection operations, validity helpers, blits and crash fixes live in `proofs/obj`, `proofs/slop` and are in NO facade cone (the crash-fix laws
file is imported by nothing in `proofs/api`). `run2.py` therefore judges against (1) explicit roots, (2) the cheapest proof roots that import the
patched file AND mention a changed identifier (`tools/check_costs.tsv` cost <= 60 s, K = 4), (3) direct importers, (4) the facades. A kill needs a
failing root that passes unmutated (baseline.py). The reference corpus (B) was NOT run: it only decodes, re-encodes and hashes valid values and
cannot reach append/set/get/X_valid/decode_checked at all; the targeted API probes replace it for those faults. Limit: stage 1 only (K = 4 +
2 direct + 2 facades); the re-check with K = 12 was run for the helper survivors (area 5/7 and a07), see the JSON `evidence`.

## R2.2 Findings (critical, nothing catches them)

1. **Collection API guards are unpinned** (`r2-a01-*`, `r2-a03-*`, `r2-a06-cells/08..10`, `r2-a07-words-blit/04`): `bl256_append` guard `n < 256`
   (`n <= 256`, `n < 255`, value `<= 256`, `||` for `&&`, index n+1, size not grown), `bl256_set` bound and value check, `bl256_get` bound,
   `bits9_append/set`, `bits_push` index and length, `List[Cell,4096]` `len` (/2047), `get` (slice 2047, element i+1) and `set` at index 1
   (`O.words_blit` base = byte offset). No proof file names these definitions (they have no callers inside the library: only a law that names
   them can pin them). Counter-examples (public calls, `api_probe.bend`): 257th append returns True, `get(len)` answers `some`, `set(len)` is accepted,
   `append(.., 256)` is accepted, empty Bitlist[9] `append(True)` then `get(0)` = `some False`, `len` of a 4192256-byte cell list = 2048, `set(1, cell)` then `get(1)` word 0 = 0.
2. **A uint8 field out of range is accepted by `X_serialize`** (`r2-s05-poison/03`: `pz(False)` = bit 30 instead of 31): `VarTestStruct{1, [], 300}` serializes to 7 bytes (probe case 14). Nothing pins `pz`.
3. **`X_valid` of containers is unpinned and not on the serialize path** (`r2-v01..v06`, 34 faults survive/unjudged): `AttesterSlashing_valid`,
   `IndexedAttestation_valid`, `Attestation_valid`, the `ExecutionPayload` group conjunction (g0/g1/g2) and the element loop of
   `List[Transaction,..]` can drop any field or element and nothing fails. `X_serialize` for these types does not call `X_valid`
   (fused poison path), so the probe sees the same serialize outcome: the faults are reachable only through the public `X_valid`, the documented
   precondition of `X_hash_tree_root` (docs/API_CONTRACTS.md).
4. **Baseline observation (unmutated tree)**: `AttesterSlashing_serialize(AttesterSlashing{O.BNone{}, default})` answers `ok = True`, 236 bytes (an absent box is written as an empty element), against the contract "refuses an absent box" (valid_probe case 2/3). Not investigated further.
5. **Baseline finding (unmutated tree, d21616e2b)**: `X_valid` accepts storage of only ceil(n/4) words (`O.words_ok`), but `O.words_root` reads 8 words per chunk. `bytelist_256` with `O.Words{Array.new(U32,0n,0), 1}` is valid
   and its root differs from the root of the same byte in roomy storage (`tight_1` vs `roomy_1`; `tight_16` vs `roomy_16`; probe `r2/probes/tight_root.bend`): the value of `hash_tree_root` of a VALID object depends on
   spare storage (Array.get masks out-of-range indices). The crash-fix2 clamp turns the out-of-range read into a zero root for such objects. Reachable by the public record constructor only; the API's own builders always leave a spare chunk.
6. `elems_root_prog` clamp (`r2-k01-cap-cnt/13`): no law, but no type calls it (dead code). The other clamp-branch faults (04..06) only change objects with storage smaller than their chunks (see 5).

## R2.3 Not critical (reasoned)

Equivalent or unreachable: streaming merkleizer faults (`r2-h09-*`, 6): no root of the object runtime calls it (types use only `M.ready`, `M.shl_by`, `M.shr_by`; zero hashes come from `D.zconst`);
`O.words_blit` empty guard and word rounding (callers fix n = 2048); `words_fit` slack; `X_decode_checked` bound variants (fixed-size Checkpoint answers None for every size but 40; variable types need a >= 2 GiB buffer);
`B.alloc` depth-table faults (input-buffer constructor, not an X_ entry point); `byte_mask` case 3 (no 3-byte write exists). Killed in bulk: the zero-hash constants at levels 6..63, element chunking,
tree split/depth/progressive faults, the unaligned writer/bulk copy lanes, the buffer reads (see the table below).

## R2.4 Unjudged (25)

The checker overflows its stack (also at 1 GB) on every mutant of `Fulu_list_Attestation_8` first-offset (11), and on several validity/writer mutants. Not counted as kills; listed with verdict `unjudged` in the JSON.

## R2.5 Every fault (A and killer)


| fault | type | file | fault | A | killed by | B |
|---|---|---|---|---|---|---|
| r2-a01-bytelist-append-grow/01 | bytelist_256 | types/bytelist_256_def_generated.bend | room is made for n elements, not n + 1 (storage can be one word short, the write lands outside the array) | SURVIVED |  |  |
| r2-a01-bytelist-append-grow/02 | bytelist_256 | types/bytelist_256_def_generated.bend | the length is resized to n (the appended element is not counted) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/01 | bytelist_256 | types/bytelist_256_def_generated.bend | the append guard is n <= 256 (a 257th element is accepted) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/02 | bytelist_256 | types/bytelist_256_def_generated.bend | the append guard is n < 255 (the 256th element is refused) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/03 | bytelist_256 | types/bytelist_256_def_generated.bend | the append value range is v <= 256 (the value 256 is stored and spills into the next byte) | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/04 | bytelist_256 | types/bytelist_256_def_generated.bend | the two append conditions are or-ed | SURVIVED |  |  |
| r2-a01-bytelist-append-guard/05 | bytelist_256 | types/bytelist_256_def_generated.bend | the value is written at index n + 1 (a hole at n, the length grows by one) | SURVIVED |  |  |
| r2-a01-bytelist-getter/01 | bytelist_256 | types/bytelist_256_def_generated.bend | the getter bound is i <= n (index n reads the zero padding and answers Some(0)) | SURVIVED |  |  |
| r2-a01-bytelist-setter/01 | bytelist_256 | types/bytelist_256_def_generated.bend | the setter bound is i <= n (an element one past the end is written, the length unchanged) | SURVIVED |  |  |
| r2-a01-bytelist-setter/02 | bytelist_256 | types/bytelist_256_def_generated.bend | the setter does not check the value range (v up to 2^32 - 1 is merged into the word) | SURVIVED |  |  |
| r2-a02-large-limit-append/01 | Fulu_list_uint8_1099511627776 | types/Fulu_list_uint8_1099511627776_def_generated.bend | the guard is n <= 4294967295 (always true: the append at n = 2^32 - 1 wraps the count to 0) | KILLED | l1099511627776_u8_api_witness_generated.bend: l1099511627776_u8_api_append_flag |  |
| r2-a02-large-limit-append/02 | Fulu_list_uint8_1099511627776 | types/Fulu_list_uint8_1099511627776_def_generated.bend | the guard is n < 4294967294 (one element less) | KILLED | l1099511627776_u8_api_witness_generated.bend: l1099511627776_u8_api_append_flag |  |
| r2-a02-large-limit-append/03 | Fulu_list_uint8_1099511627776 | types/Fulu_list_uint8_1099511627776_def_generated.bend | the guard is the wrapped sum (n + 1) <= 4294967295 | KILLED | l1099511627776_u8_api_witness_generated.bend: l1099511627776_u8_api_append_flag |  |
| r2-a02-large-limit-append/04 | proglist_uint8 | types/proglist_uint8_def_generated.bend | the guard is n <= 4294967295 (always true) | KILLED | crash_fix_laws_generated.bend: pl_u8_append_max_refused |  |
| r2-a02-large-limit-append/05 | progbitlist | types/progbitlist_def_generated.bend | the guard is n <= 4294967295 (always true) | KILLED | crash_fix_laws_generated.bend: pbits_append_max_refused |  |
| r2-a03-bits-append/01 | bitlist_9 | types/bitlist_9_def_generated.bend | the append guard is n <= 9 (a tenth bit is accepted) | SURVIVED |  |  |
| r2-a03-bits-append/02 | bitlist_9 | types/bitlist_9_def_generated.bend | the append guard is n < 8 (the ninth bit is refused) | SURVIVED |  |  |
| r2-a03-bits-append/03 | bitlist_9 | types/bitlist_9_def_generated.bend | the setter bound is i <= n (the bit past the end is set, length unchanged) | SURVIVED |  |  |
| r2-a03-bits-append/04 | bitlist_9 | src/obj.bend | the new bit is stored at index k + 1 | SURVIVED |  |  |
| r2-a03-bits-append/05 | bitlist_9 | src/obj.bend | the length stays k after the push | SURVIVED |  |  |
| r2-a03-bits-append/06 | bitlist_9 | src/obj.bend | bit_merge is inverted (True clears, False sets) | KILLED | u32bits.bend: bit_merge_other |  |
| r2-a04-element-array-append/01 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the append guard is n <= 16 (a 17th element is accepted) | KILLED | cspec_l16_WithdrawalRequest.bend: app_eq |  |
| r2-a04-element-array-append/02 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the room test is n <= cap (an append at n = cap writes one past the storage) | KILLED | cached_l16_WithdrawalRequest.bend: grow_eq |  |
| r2-a04-element-array-append/03 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the copy loop moves n - 1 elements (the last element is lost) | KILLED | cached_l16_WithdrawalRequest.bend: room_pick_eq |  |
| r2-a04-element-array-append/04 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the new storage is sized for n elements (not n + 1) | KILLED | cached_l16_WithdrawalRequest.bend: room_pick_eq |  |
| r2-a04-element-array-append/05 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the count becomes n + 2 | KILLED | collections_0.bend: l16_WithdrawalRequest_append_length |  |
| r2-a04-element-array-append/06 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the setter bound is i <= n | KILLED | cspec_l16_WithdrawalRequest.bend: set_eq |  |
| r2-a04-element-array-append/07 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the getter bound is i <= n (index n answers the default element) | KILLED | l16_WithdrawalRequest_api_witness_generated.bend: l16_WithdrawalRequest_api_get_outside |  |
| r2-a05-cached-append/01 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the cached append guard is n <= 16 | KILLED | cached_l16_WithdrawalRequest.bend: capp_eq |  |
| r2-a05-cached-append/02 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the fit test is n <= 2^d (the leaf 2^d is stored in a tree of 2^d leaves) | KILLED | cached_l16_WithdrawalRequest.bend: capp_eq |  |
| r2-a05-cached-append/03 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the deepened cache keeps depth d | KILLED | cached_l16_WithdrawalRequest.bend: grow_eq |  |
| r2-a05-cached-append/04 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the dirty range after deepening is 0 .. 2^d - 1 (the new right half is never hashed) | KILLED | cached_l16_WithdrawalRequest.bend: grow_eq |  |
| r2-a05-cached-append/05 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | only the lower dirty bound is updated (hi keeps its value) | KILLED | cached_l16_WithdrawalRequest.bend: set_state |  |
| r2-a05-cached-append/06 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_def_generated.bend | the cached set bound is i <= n | KILLED | cached_l16_WithdrawalRequest.bend: cset_eq |  |
| r2-a06-cells/01 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the setter takes a cell of at most 2048 bytes (a shorter cell is written and the tail of the old cell is kept) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_set_flag |  |
| r2-a06-cells/02 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the setter takes a cell of at least 2048 bytes (a longer cell overruns the next one) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_set_flag |  |
| r2-a06-cells/03 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the setter bound is i <= n (writes the cell after the last) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_set_flag |  |
| r2-a06-cells/04 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append guard is n + 1 < 4096 (4095 cells at most) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/05 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append guard is n + 1 <= 4097 (4097 cells) | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/06 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append length check is dropped | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/07 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the append length check is vn <= 2048 | KILLED | l4096_b2048_api_witness_generated.bend: l4096_b2048_api_append_flag |  |
| r2-a06-cells/08 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the count divides by 2047 | SURVIVED |  |  |
| r2-a06-cells/09 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the getter slices 2047 bytes | UNJUDGED |  |  |
| r2-a06-cells/10 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the getter starts at byte 2048 (i + 1) | UNJUDGED |  |  |
| r2-a06-cells/11 | FuluDataColumnSidecar | types/Fulu_list_bytevec_2048_4096_def_generated.bend | the room is made for n cells (the write lands outside the storage) | SURVIVED |  |  |
| r2-a07-words-blit/01 | FuluDataColumnSidecar | src/obj.bend | the empty test is n <= 0 (same as n = 0 on an unsigned count) | SURVIVED |  |  |
| r2-a07-words-blit/02 | FuluDataColumnSidecar | src/obj.bend | the empty guard is removed (the loop count n/4 - 1 wraps to 2^32 - 1 for n = 0) | SURVIVED |  |  |
| r2-a07-words-blit/03 | FuluDataColumnSidecar | src/obj.bend | the word count drops the rounding (n >> 2 words, a final partial word is not copied) | SURVIVED |  |  |
| r2-a07-words-blit/04 | FuluDataColumnSidecar | src/obj.bend | the destination word base is p (not p >> 2) | SURVIVED |  |  |
| r2-a07-words-blit/05 | FuluDataColumnSidecar | src/obj.bend | the destination word is stored at base + j + 1 (one word late) | KILLED | cell_rw.bend: blc0 |  |
| r2-a07-words-blit/06 | FuluDataColumnSidecar | src/obj.bend | the source index advances by 2 (every second word) | KILLED | cell_rw.bend: blc_step |  |
| r2-a07-words-blit/07 | FuluDataColumnSidecar | src/obj.bend | the returned source length is n + 1 | SURVIVED |  |  |
| r2-a08-words-fit/01 | bytelist_256 | src/obj.bend | the room test is `want-chunks <= cap` replaced by `< cap` (grows one append early, equivalent in result) | KILLED | words_rw.bend: fit_roomy |  |
| r2-a08-words-fit/02 | bytelist_256 | src/obj.bend | the room test is `<= cap + 8` (a full chunk of slack is assumed: storage can be too small by up to eight words) | KILLED | words_rw.bend: fit_roomy |  |
| r2-a08-words-fit/03 | bytelist_256 | src/obj.bend | the grow copies ceil(n/4) - 1 words (the last word is lost) | KILLED | words_rw.bend: fit_grow |  |
| r2-a08-words-fit/04 | bytelist_256 | src/obj.bend | the grown storage is sized for n bytes (not want) | KILLED | words_rw.bend: fit_grow |  |
| r2-b01-buffer-reads/01 | VarTestStruct | src/buffer.bend | byte 1 is selected with a 16-bit shift | KILLED | g__sub_boolean_generated.bend: sel1 |  |
| r2-b01-buffer-reads/02 | VarTestStruct | src/buffer.bend | byte 3 is selected with a 16-bit shift | KILLED | g__sub_boolean_generated.bend: sel3 |  |
| r2-b01-buffer-reads/03 | VarTestStruct | src/buffer.bend | byte 0 keeps seven bits (mask 127) | KILLED | g__sub_boolean_generated.bend: sel0 |  |
| r2-b01-buffer-reads/04 | VarTestStruct | src/buffer.bend | the in-word index is i mod 2 | KILLED | reads.bend: byte_any |  |
| r2-b01-buffer-reads/05 | VarTestStruct | src/buffer.bend | the word index is i / 8 | KILLED | reads.bend: byte_any |  |
| r2-b02-unaligned-read/01 | VarTestStruct | src/buffer.bend | the high part is shifted by 16 | KILLED | vua_bits.bend: joinC1 |  |
| r2-b02-unaligned-read/02 | VarTestStruct | src/buffer.bend | the high part is shifted by 16 | KILLED | vua_bits.bend: joinC3 |  |
| r2-b02-unaligned-read/03 | VarTestStruct | src/buffer.bend | the low part is shifted by 16 | KILLED | vua_bits.bend: joinC3 |  |
| r2-b02-unaligned-read/04 | VarTestStruct | src/buffer.bend | the high part is two words on | KILLED | reads.bend: read32_case |  |
| r2-b02-unaligned-read/05 | VarTestStruct | src/buffer.bend | an offset is taken as aligned iff i mod 2 = 0 (offsets 2 mod 4 read the whole word) | KILLED | reads.bend: read32_any |  |
| r2-b02-unaligned-read/06 | ComplexTestStruct | src/buffer.bend | the high word is read at i + 8 | KILLED | var_fix_types.bend: rd_u64 |  |
| r2-b02-unaligned-read/07 | ComplexTestStruct | src/buffer.bend | the pair is (high, low) | KILLED | var_fix_types.bend: rd_u64 |  |
| r2-b03-byte-swap/01 | FuluCheckpoint | src/buffer.bend | byte 1 goes to bits 8..15 | KILLED | root_leaf.bend: swap0 |  |
| r2-b03-byte-swap/02 | FuluCheckpoint | src/buffer.bend | the mask of byte 0 is dropped | KILLED | root_leaf.bend: swap0 |  |
| r2-b03-byte-swap/03 | FuluCheckpoint | src/buffer.bend | the top byte is shifted by 16 | KILLED | root_leaf.bend: swap2 |  |
| r2-b04-storage-depth/01 | VarTestStruct | src/buffer.bend | the threshold of the 2-bit step is 3 (w = 3 words gets depth 1: an array of two words) | KILLED | vdepth.bend: u2 |  |
| r2-b04-storage-depth/02 | VarTestStruct | src/buffer.bend | the threshold of the 4-bit step is 5 | KILLED | vdepth.bend: u4 |  |
| r2-b04-storage-depth/03 | ComplexTestStruct | src/buffer.bend | the threshold of the 8-bit step is 17 | KILLED | vdepth.bend: u8 |  |
| r2-b04-storage-depth/04 | FuluDataColumnSidecar | src/buffer.bend | the threshold of the 16-bit step is 257 | KILLED | vdepth.bend: u16 |  |
| r2-b04-storage-depth/05 | FuluDataColumnSidecar | src/buffer.bend | the two-level threshold is 65537 | KILLED | vdepth.bend: unz |  |
| r2-b04-storage-depth/06 | bytelist_256 | src/buffer.bend | the threshold of the 2-bit step is 3 | KILLED | vdepth.bend: st2c |  |
| r2-b04-storage-depth/07 | bytelist_256 | src/buffer.bend | the threshold of the 4-bit step is 5 | KILLED | vdepth.bend: st4c |  |
| r2-b04-storage-depth/08 | bytelist_256 | src/buffer.bend | the last bit adds nothing (m = 1 is not rounded up) | KILLED | vdepth.bend: st0c |  |
| r2-b04-storage-depth/09 | FuluBytes48 | src/buffer.bend | 5 words get depth 2 (an array of four words for five) | SURVIVED |  |  |
| r2-b04-storage-depth/10 | FuluBytes48 | src/buffer.bend | 9 words get depth 3 | SURVIVED |  |  |
| r2-b04-storage-depth/11 | FuluBytes48 | src/buffer.bend | the loop halves with floor ((need) >> 1 instead of (need + 1) >> 1) | SURVIVED |  |  |
| r2-d01-decode-checked/01 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the window test is size < n (a window that is exactly the buffer is refused) | KILLED | crash_fix_laws_generated.bend: decode_checked_inside_accepted |  |
| r2-d01-decode-checked/02 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the window-inside-buffer test is dropped (a size past the buffer is decoded: out-of-bounds reads) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-d01-decode-checked/03 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is dropped (any size up to the buffer length is decoded) | SURVIVED |  |  |
| r2-d01-decode-checked/04 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is size <= 2^31 (the 2 GiB window is accepted) | SURVIVED |  |  |
| r2-d01-decode-checked/05 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is size < 2^32 - 1 (everything below the U32 maximum is accepted) | SURVIVED |  |  |
| r2-d01-decode-checked/06 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the 2^31 bound is size < 2^31 - 1 (the window 2^31 - 1 is refused) | SURVIVED |  |  |
| r2-d01-decode-checked/07 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the two conditions are or-ed (either one accepts) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-d01-decode-checked/08 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the buffer test is n <= size (reversed comparison: only windows at least the buffer length pass) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-d01-decode-checked/09 | VarTestStruct | types/VarTestStruct_decode_ssz_generated.bend | the window-inside-buffer test is dropped | SURVIVED |  |  |
| r2-d01-decode-checked/10 | VarTestStruct | types/VarTestStruct_decode_ssz_generated.bend | the 2^31 bound is size <= 2^31 | SURVIVED |  |  |
| r2-d01-decode-checked/11 | VarTestStruct | types/VarTestStruct_decode_ssz_generated.bend | the two conditions are or-ed | SURVIVED |  |  |
| r2-d01-decode-checked/12 | bitlist_9 | types/bitlist_9_decode_ssz_generated.bend | the 2^31 bound is dropped | SURVIVED |  |  |
| r2-d01-decode-checked/13 | bitlist_9 | types/bitlist_9_decode_ssz_generated.bend | the window-inside-buffer test is dropped | SURVIVED |  |  |
| r2-d01-decode-checked/14 | FuluCheckpoint | types/FuluCheckpoint_decode_ssz_generated.bend | the checked entry passes the window size as the buffer size (the comparison is vacuous) | KILLED | crash_fix_laws_generated.bend: decode_checked_empty_buffer_refused |  |
| r2-h01-mix-in-length/01 | VarTestStruct | src/obj.bend | the length is put in the second word | KILLED | list_obj.bend: mix_bytes |  |
| r2-h01-mix-in-length/02 | VarTestStruct | src/obj.bend | the length mixed in is n + 1 | KILLED | list_obj.bend: mix_bytes |  |
| r2-h01-mix-in-length/03 | bitlist_9 | src/obj.bend | the byte count ceil(k/8) is mixed in | KILLED | pbits_obj.bend: bst |  |
| r2-h01-mix-in-length/04 | bitlist_9 | src/obj.bend | the count includes the delimiter bit (k + 1) | KILLED | pbits_obj.bend: bst |  |
| r2-h02-chunk-count/01 | bytelist_256 | src/obj.bend | the chunk-presence flag is 0 <= chunks (always true) | KILLED | pv_obj.bend: bv_state |  |
| r2-h02-chunk-count/02 | bytelist_256 | src/obj.bend | the tree width is 2^depth * 2 | KILLED | pv_obj.bend: bv_state |  |
| r2-h03-subtree-split/01 | bytelist_256 | src/obj.bend | the right half starts at s + w | KILLED | mtree_run.bend: mt_words |  |
| r2-h03-subtree-split/02 | bytelist_256 | src/obj.bend | the right half is inside iff s + w/2 <= n | KILLED | mtree_run.bend: mt_words |  |
| r2-h03-subtree-split/03 | FuluDataColumnSidecar | src/obj.bend | the zero subtree of an element's empty right half uses Z(d - 1) | KILLED | elems_obj.bend: ct_words |  |
| r2-h03-subtree-split/04 | FuluDataColumnSidecar | src/obj.bend | the element tree's right half starts at s + w | KILLED | elems_obj.bend: ct_words |  |
| r2-h03-subtree-split/05 | bytelist_256 | src/obj.bend | the join hashes right // left | KILLED | mtree_run.bend: mt_words |  |
| r2-h03-subtree-split/06 | bytelist_256 | src/obj.bend | the seventh word is read from b + 6 (repeats a word) | KILLED | mtree_run.bend: chunk_read |  |
| r2-h03-subtree-split/07 | bytelist_256 | src/obj.bend | the last word of a chunk is not byte-swapped | KILLED | mtree_run.bend: chunk_read |  |
| r2-h04-element-chunks/01 | FuluDataColumnSidecar | src/obj.bend | word 8c+4 is taken inside the element when j + 4 <= ew (reads the next element's first word) | KILLED | elems_obj.bend: echunk_read |  |
| r2-h04-element-chunks/02 | FuluDataColumnSidecar | src/obj.bend | the first word of the chunk is read unconditionally | KILLED | elems_obj.bend: echunk_read |  |
| r2-h04-element-chunks/03 | FuluDataColumnSidecar | src/obj.bend | the chunk count of an element is floor(ew / 8) | KILLED | elems48.bend: ev_st |  |
| r2-h04-element-chunks/04 | FuluDataColumnSidecar | src/obj.bend | element i starts at word i * (ew + 1) | KILLED | elems_obj.bend: mt_elems |  |
| r2-h04-element-chunks/05 | FuluDataColumnSidecar | src/obj.bend | the element count divides by 4 ew + 4 | KILLED | cells.bend: ev_st |  |
| r2-h05-scalar-chunks/01 | FuluBeaconBlockHeader | src/obj.bend | true is chunk 0x00000001 in the first word (big-endian word, wrong byte) | KILLED | root_leaf.bend: bool_root |  |
| r2-h05-scalar-chunks/02 | FuluValidator | src/obj.bend | false is the all-ones chunk word | KILLED | root_leaf.bend: bool_root |  |
| r2-h05-scalar-chunks/03 | FuluCheckpoint | src/obj.bend | the value is not byte-swapped | KILLED | leaf_small.bend: u32_root |  |
| r2-h05-scalar-chunks/04 | FuluCheckpoint | src/obj.bend | the two words are swapped (high word first) | KILLED | root_leaf.bend: u64_root |  |
| r2-h05-scalar-chunks/05 | FuluCheckpoint | src/obj.bend | the high word is dropped | KILLED | root_leaf.bend: u64_root |  |
| r2-h06-bit-roots/01 | bitlist_513 | src/obj.bend | the chunked bytes are k (bit count) instead of ceil(k / 8) | KILLED | pbits_obj.bend: bst |  |
| r2-h06-bit-roots/02 | progbitlist | src/obj.bend | the byte count is used as the mixed length | KILLED | pbits_obj.bend: pst |  |
| r2-h06-bit-roots/03 | bitlist_513 | src/obj.bend | the byte count is floor(k / 8) | KILLED | vbitenc.bend: E3 |  |
| r2-h07-progressive/01 | ProgressiveTestStruct | src/obj.bend | the remainder is inside when s + 2^dep <= n (an empty remainder is hashed as a node) | KILLED | prog_root.bend: pt_run |  |
| r2-h07-progressive/02 | ProgressiveTestStruct | src/obj.bend | the segment's tree has width 2^(dep+1) | KILLED | prog_root.bend: pt_run |  |
| r2-h07-progressive/03 | ProgressiveTestStruct | src/obj.bend | the fuel is the chunk count (designed equivalent: log4 n steps suffice) | KILLED | pbits_obj.bend: pst |  |
| r2-h07-progressive/04 | ProgressiveTestStruct | src/obj.bend | the emptiness flag is 0 <= n (an empty list is hashed as a node) | KILLED | pbits_obj.bend: pst |  |
| r2-h08-zero-hashes/01 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(6) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/02 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(18) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/03 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(20) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/04 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(40) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/05 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(41) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/06 | FuluExecutionRequests | src/digest.bend | the first word of the constant Z(63) is off by one | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/07 | FuluExecutionRequests | src/digest.bend | Z(0) is not zero (first word 1) | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/08 | FuluExecutionRequests | src/digest.bend | the table ends one level early: Z(63) answers the zero chunk | KILLED | mtree_spec.bend: zhex |  |
| r2-h08-zero-hashes/09 | FuluExecutionRequests | src/digest.bend | the node hashes right // left | KILLED | FuluExecutionRequests_hashtreeroot_proof_generated.bend: hash_pair_packed |  |
| r2-h08-zero-hashes/10 | FuluExecutionRequests | src/digest.bend | the message length is hl - 1 (63 bytes) | KILLED | FuluExecutionRequests_hashtreeroot_proof_generated.bend: hash_pair_packed |  |
| r2-h09-streaming-merkleizer/01 | FuluExecutionRequests | src/merkle_fast.bend | the empty tree answers Z(0) | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/02 | FuluExecutionRequests | src/merkle_fast.bend | the depth rounds down: (limit + 1) is replaced by limit | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/03 | FuluExecutionRequests | src/merkle_fast.bend | climb hashes the stack entry on the right | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/04 | FuluExecutionRequests | src/merkle_fast.bend | the start is 4^k / 3 | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/05 | FuluExecutionRequests | src/merkle_fast.bend | the table fill hashes Z(k) with the zero chunk | SURVIVED |  |  |
| r2-h09-streaming-merkleizer/06 | FuluExecutionRequests | src/merkle_fast.bend | the table is never filled | SURVIVED |  |  |
| r2-h10-reference-library/01 | FuluExecutionRequests | src/merkle.bend | zero_hash(d + 1) hashes the child with the zero chunk | KILLED | cached_tree.bend: built_lookup |  |
| r2-h10-reference-library/02 | FuluExecutionRequests | src/merkle.bend | the right operand's length is not checked | KILLED | merkle.bend: hash_pair_correct |  |
| r2-h10-reference-library/03 | FuluExecutionRequests | src/mixing.bend | the selector bound is dropped | KILLED | mixing.bend: mix_in_selector_correct |  |
| r2-h10-reference-library/04 | FuluExecutionRequests | src/mixing.bend | the selector chunk is padded on the left (31 zero bytes then the selector would be big-endian; here the pad length is 31) | KILLED | mixing.bend: mix_in_selector_correct |  |
| r2-h10-reference-library/05 | FuluExecutionRequests | src/mixing.bend | the root and the root length chunk are mixed in the other order | KILLED | mixing.bend: mix_in_length_correct |  |
| r2-h10-reference-library/06 | ProgressiveTestStruct | src/progressive.bend | the depth grows by 1 (2x) instead of 2 (4x) | KILLED | cached_tree.bend: progressive_go_correct |  |
| r2-h10-reference-library/07 | ProgressiveTestStruct | src/progressive.bend | the segment is the left operand | KILLED | cached_tree.bend: progressive_join |  |
| r2-h10-reference-library/08 | ProgressiveTestStruct | src/progressive.bend | the fuel is one less than the chunk count | KILLED | cached_tree.bend: progressive_gate_correct |  |
| r2-h10-reference-library/09 | bytelist_256 | src/packing.bend | a chunk completes after 30 bytes (room starts at 30) | KILLED | packing.bend: checked_correct |  |
| r2-h10-reference-library/10 | bytelist_256 | src/packing.bend | after a full chunk the room is 30 | KILLED | packing.bend: scan_correct |  |
| r2-h10-reference-library/11 | bytelist_256 | src/packing.bend | the pad is one byte short | KILLED | packing.bend: finish_correct |  |
| r2-h10-reference-library/12 | ProgressiveTestStruct | src/tree.bend | the missing subtree of depth 1+p is zero_hash(p) | KILLED | cached_tree.bend: consume_correct |  |
| r2-h10-reference-library/13 | ProgressiveTestStruct | src/tree.bend | residual chunks are ignored | KILLED | tree.bend: finish_drop |  |
| r2-h10-reference-library/14 | bitlist_9 | src/bit_root.bend | the limit is (n + 256) / 256 | KILLED | bit_chunk_count.bend: count_bits |  |
| r2-h10-reference-library/15 | bitlist_9 | src/bit_root.bend | the bit count is encoded in 8 bytes | KILLED | bit_list_root.bend: list_gate_correct |  |
| r2-h10-reference-library/16 | bitlist_9 | src/root.bend | the count is encoded in 8 bytes | KILLED | root_scope.bend: length_mix_scope |  |
| r2-h10-reference-library/17 | FuluExecutionRequests | src/root.bend | the basic-size limit rounds down | KILLED | root_total_steps.bend: packed_sound |  |
| r2-h10-reference-library/18 | ProgressiveTestStruct | src/root.bend | an inactive field contributes nothing (the slot is skipped) | KILLED | root_total_steps.bend: placed_chunks |  |
| r2-h10-reference-library/19 | ProgressiveTestStruct | src/root.bend | the active-field chunk is padded to 31 bytes | KILLED | root_scope.bend: active_scope |  |
| r2-h10-reference-library/20 | CompatibleUnionBC | src/root.bend | the selector chunk is the selector plus one | KILLED | root_scope.bend: selector_scope |  |
| r2-h10-reference-library/21 | FuluExecutionRequests | src/root.bend | the count of a vector may be any value at most n | KILLED | root_domain_steps.bend: valid_value_correct |  |
| r2-h10-reference-library/22 | FuluExecutionRequests | src/root.bend | the list limit is strict (count < n) | KILLED | root_domain_steps.bend: valid_value_correct |  |
| r2-k01-cap-cnt/01 | bytelist_256 | src/obj.bend | the two arms of the clamp are swapped (a fitting object is hashed over w / u items) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/02 | bytelist_256 | src/obj.bend | the clamp tests m < w (an object whose items exactly fill the storage is clamped to w / u = k: designed equivalent) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/03 | bytelist_256 | src/obj.bend | the clamp admits objects that overrun the storage by up to one item (m <= w + u) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/04 | bytelist_256 | src/obj.bend | an object that overruns its storage is hashed over the items the storage holds, w / u: here one more (ceil) | SURVIVED |  |  |
| r2-k01-cap-cnt/05 | bytelist_256 | src/obj.bend | an object that overruns its storage is hashed over w / u items: here w / (u + 1) | SURVIVED |  |  |
| r2-k01-cap-cnt/06 | bytelist_256 | src/obj.bend | an object that overruns its storage is hashed over w / u items: here w items (words taken for chunks) | SURVIVED |  |  |
| r2-k01-cap-cnt/07 | bytelist_256 | src/obj.bend | the object's words are 8 per chunk (m = e8(chunks)) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/08 | bytelist_256 | src/obj.bend | a chunk is 8 words | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/09 | bytelist_256 | src/obj.bend | the root is bounded by the storage (CH-03) | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/10 | proglist_uint8 | src/obj.bend | the progressive packed-bytes root is bounded by the storage (CH-03) | KILLED | words_cap.bend: wrp_unfold |  |
| r2-k01-cap-cnt/11 | FuluDataColumnSidecar | src/obj.bend | an element sequence is bounded by the storage: m = count * ew words | KILLED | words_cap.bend: er_unfold |  |
| r2-k01-cap-cnt/12 | FuluDataColumnSidecar | src/obj.bend | an element sequence is bounded by the storage: an element is ew words | KILLED | words_cap.bend: er_unfold |  |
| r2-k01-cap-cnt/13 | FuluDataColumnSidecar | src/obj.bend | the progressive element root is bounded by the storage | SURVIVED |  |  |
| r2-k01-cap-cnt/14 | bytelist_256 | src/obj.bend | an empty data tree is the zero tree | KILLED | words_cap.bend: wr_unfold |  |
| r2-k01-cap-cnt/15 | FuluDataColumnSidecar | src/obj.bend | an empty element sequence is the zero tree | KILLED | cells.bend: ev_st |  |
| r2-o01-first-offset/01 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the first offset may be any value at least 8 | KILLED | var_codec_AttesterSlashing.bend: st_a |  |
| r2-o01-first-offset/02 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the first offset may be any value at most 8 | KILLED | var_codec_AttesterSlashing.bend: st_a |  |
| r2-o01-first-offset/03 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the first offset check is dropped | KILLED | var_codec_AttesterSlashing.bend: st_a |  |
| r2-o01-first-offset/04 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the order test o0 <= o1 is dropped (the first element window is negative) | KILLED | var_codec_AttesterSlashing.bend: st_b |  |
| r2-o01-first-offset/05 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the bound o1 <= len is dropped | KILLED | var_codec_AttesterSlashing.bend: st_b |  |
| r2-o01-first-offset/06 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the bound is o1 < len (an empty second element is refused: it is invalid anyway) | KILLED | var_codec_AttesterSlashing.bend: st_b |  |
| r2-o01-first-offset/07 | FuluAttesterSlashing | types/FuluAttesterSlashing_decode_ssz_generated.bend | the minimum length is 4 (the second offset is read past the end) | KILLED | var_codec_AttesterSlashing.bend: ok_eval |  |
| r2-o02-list-of-variable-first-offset/01 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the alignment test (first mod 4 = 0) is dropped | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/02 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the count limit is 9 | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/03 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the count limit is 7 | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/04 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the count limit is dropped | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/05 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the bound first <= len is dropped (the count may exceed what the input holds) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/06 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the lower bound 4 is dropped (first offset 0: count 0 and a non-empty input is accepted) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/07 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the alignment and bound conjunction is an or | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/08 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the empty scope is refused | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/09 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the last element's end is read one offset past (i + 3 == n selects len) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/10 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the element is validated only when it is the first window (acc kept True afterwards) | UNJUDGED |  |  |
| r2-o02-list-of-variable-first-offset/11 | FuluBeaconBlockBody | types/Fulu_list_Attestation_8_decode_ssz_generated.bend | the accumulated validity of the earlier elements is ignored when the element is not validated (acc lost) | UNJUDGED |  |  |
| r2-o03-dfill/01 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | the default fills one element (dfill count 1) | SURVIVED |  |  |
| r2-o03-dfill/02 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | every slot is filled at index 0 (the second slot stays absent) | SURVIVED |  |  |
| r2-o03-dfill/03 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | the filler is the empty box (the absent element the CH-10 fix removed) | SURVIVED |  |  |
| r2-o03-dfill/04 | ComplexTestStruct | types/vec_VarTestStruct_2_def_generated.bend | the stored count is 1 (elements fill both slots but the count is one) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: ComplexTestStruct_mc_ser |  |
| r2-s01-bulk-copy/01 | FuluBytes96 | src/obj.bend | the last lane of a block stores to b + 6 (overwrites lane 6, lane 7 is left zero) | KILLED | arr_shift.bend: c7 |  |
| r2-s01-bulk-copy/02 | FuluBytes96 | src/obj.bend | lane 3 reads source word a + 3 instead of a + 4 (one lane repeated) | KILLED | arr_shift.bend: c3 |  |
| r2-s01-bulk-copy/03 | FuluBytes96 | src/obj.bend | the destination advances by 7 words per block | KILLED | arr_shift.bend: blk |  |
| r2-s01-bulk-copy/04 | FuluBytes96 | src/obj.bend | the tail loop advances the destination by 2 | KILLED | vbuf.bend: tail |  |
| r2-s01-bulk-copy/05 | FuluBytes48 | src/obj.bend | the tail count is nw & 3 (words 4..7 of the remainder are not copied) | KILLED | arr_shift.bend: acp |  |
| r2-s01-bulk-copy/06 | FuluBytes96 | src/obj.bend | the block count is nw / 4 | KILLED | arr_shift.bend: acp |  |
| r2-s01-bulk-copy/07 | ComplexTestStruct | src/obj.bend | offset 1 mod 4 uses the plain copy | UNJUDGED |  |  |
| r2-s01-bulk-copy/08 | ComplexTestStruct | src/obj.bend | offset 2 mod 4 uses the 24-bit shift (scopy3) | UNJUDGED |  |  |
| r2-s01-bulk-copy/09 | ComplexTestStruct | src/obj.bend | an empty range is copied as if it had a word (the empty test is n = 1) | KILLED | arr_copy.bend: read_al |  |
| r2-s01-bulk-copy/10 | ComplexTestStruct | src/obj.bend | the source word index is off >> 3 | KILLED | arr_copy.bend: read_al |  |
| r2-s01-bulk-copy/11 | ComplexTestStruct | src/obj.bend | floor(n / 4) words are copied (a partial last word is dropped) | KILLED | arr_copy.bend: read_al |  |
| r2-s01-bulk-copy/12 | ComplexTestStruct | src/obj.bend | the mask applies to the word before the last | KILLED | vcopy.bend: mask_keep |  |
| r2-s01-bulk-copy/13 | ComplexTestStruct | src/obj.bend | the tail word uses << 16 (the constant of the 2-byte shift) | KILLED | ComplexTestStruct_decode_ssz_proof_generated.bend: sc1tail |  |
| r2-s01-bulk-copy/14 | ComplexTestStruct | src/obj.bend | the tail word shifts the carry by 8 (not 16) | KILLED | ComplexTestStruct_decode_ssz_proof_generated.bend: sc2tail |  |
| r2-s01-bulk-copy/15 | ComplexTestStruct | src/obj.bend | the tail word uses << 16 | KILLED | ComplexTestStruct_decode_ssz_proof_generated.bend: sc3tail |  |
| r2-s01-bulk-copy/16 | FuluBytes96 | src/obj.bend | lane 5 uses << 8 for the high part | KILLED | vbx.bend: sc1c5 |  |
| r2-s01-bulk-copy/17 | FuluBytes96 | src/obj.bend | lane 2 reads the next source word one too far (a + 5) | KILLED | vbx.bend: sc2c2 |  |
| r2-s01-bulk-copy/18 | FuluBytes96 | src/obj.bend | lane 6 shifts the carry by 16 | KILLED | vbx.bend: sc3c6 |  |
| r2-s01-bulk-copy/19 | FuluBytes96 | src/obj.bend | the block advances the destination by 9 | KILLED | vbx.bend: sc1blk |  |
| r2-s02-unaligned-writer/01 | ComplexTestStruct | src/obj.bend | position 1 mod 4 uses the 16-bit family (pw_run2) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/02 | ComplexTestStruct | src/obj.bend | position 2 mod 4 uses the 24-bit family (pw_run3) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/03 | VarTestStruct | src/obj.bend | the carry shift is >> 16 | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/04 | VarTestStruct | src/obj.bend | the word is shifted by 16 on the last step | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/05 | ComplexTestStruct | src/obj.bend | the carry is >> 16 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/06 | ComplexTestStruct | src/obj.bend | the carry is >> 8 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: pwor |  |
| r2-s02-unaligned-writer/07 | ComplexTestStruct | src/obj.bend | the interior count is (n + s - 3) >> 2 (one word too many when n + s is 3 mod 4) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/08 | ComplexTestStruct | src/obj.bend | the short-range test is n + s <= 4 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/09 | ComplexTestStruct | src/obj.bend | the carry is skipped when it is at most 1 (a carry of exactly 1 is lost) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/10 | ComplexTestStruct | src/obj.bend | the carry lands at word q + nw - 1 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: putwu |  |
| r2-s02-unaligned-writer/11 | FuluBytes96 | src/obj.bend | the partial-word test is n & 3 = 1 (a 2 or 3 byte tail is stored whole and overwrites its neighbour) | KILLED | arr_copy.bend: put_al |  |
| r2-s02-unaligned-writer/12 | FuluBytes96 | src/obj.bend | it is OR-ed at word q + nw | UNJUDGED |  |  |
| r2-s02-unaligned-writer/13 | ComplexTestStruct | src/obj.bend | an empty range is written as a one-word range (the empty test is n = 1) | KILLED | arr_copy.bend: put_al |  |
| r2-s02-unaligned-writer/14 | ComplexTestStruct | src/obj.bend | the destination word is p >> 3 | KILLED | arr_copy.bend: put_al |  |
| r2-s02-unaligned-writer/15 | ComplexTestStruct | src/obj.bend | the spill constant for p = 1 mod 4 is x >> 16 | KILLED | vuwf1_bv64.bend: putu_bv64 |  |
| r2-s02-unaligned-writer/16 | ComplexTestStruct | src/obj.bend | the spill constant for p = 2 mod 4 is x >> 24 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e2 |  |
| r2-s02-unaligned-writer/17 | ComplexTestStruct | src/obj.bend | the spill constant for p = 3 mod 4 is x >> 16 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e2 |  |
| r2-s02-unaligned-writer/18 | ComplexTestStruct | src/obj.bend | the spill goes to word p >> 2 + 2 | KILLED | vuw.bend: w32u_rt |  |
| r2-s02-unaligned-writer/19 | ComplexTestStruct | src/obj.bend | shift by 2 bytes becomes 1 byte (x * 256) | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e1 |  |
| r2-s02-unaligned-writer/20 | ComplexTestStruct | src/obj.bend | shift by 3 bytes becomes 2 bytes | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: e1 |  |
| r2-s02-unaligned-writer/21 | ComplexTestStruct | src/obj.bend | the byte position is p mod 2 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: put_bits2 |  |
| r2-s02-unaligned-writer/22 | ComplexTestStruct | src/obj.bend | the high byte is written at p + 2 | KILLED | ComplexTestStruct_encode_ssz_proof_generated.bend: w16_anyW |  |
| r2-s02-unaligned-writer/23 | ComplexTestStruct | src/obj.bend | hi is stored at p + 8 | UNJUDGED |  |  |
| r2-s02-unaligned-writer/24 | ComplexTestStruct | src/obj.bend | hi goes to word + 2 | KILLED | var_fix_types.bend: put_u64W |  |
| r2-s02-unaligned-writer/25 | ComplexTestStruct | src/obj.bend | true writes the byte 2 | SURVIVED |  |  |
| r2-s03-element-access/01 | bytelist_256 | src/obj.bend | a 3-byte write uses the 2-byte mask | SURVIVED |  |  |
| r2-s03-element-access/02 | bytelist_256 | src/obj.bend | a 2-byte write uses the 1-byte mask | KILLED | encset_r_l1024_u16.bend: hw_go_0_1 |  |
| r2-s03-element-access/03 | bytelist_256 | src/obj.bend | the old word is not cleared (the new bytes are OR-ed into the old ones) | KILLED | encset_r_l1024_u16.bend: shr_merge |  |
| r2-s03-element-access/04 | bytelist_256 | src/obj.bend | the written value is not masked (a wide value spills into the neighbours) | KILLED | encset_r_l1024_u16.bend: shr_merge |  |
| r2-s03-element-access/05 | bytelist_256 | src/obj.bend | the mask is not shifted to position s | KILLED | encset_r_l1024_u16.bend: byte_go_1 |  |
| r2-s03-element-access/06 | bytelist_256 | src/obj.bend | the in-word position is p mod 2 | KILLED | encset_r_l1024_u16.bend: ww_obj |  |
| r2-s03-element-access/07 | bytelist_256 | src/obj.bend | the in-word shift is ignored (always the first byte of the word) | KILLED | encset_r_l1024_u16.bend: ba_obj |  |
| r2-s03-element-access/08 | bytelist_256 | src/obj.bend | a 3-byte read keeps 2 bytes | KILLED | vbytes.bend: keep3 |  |
| r2-s03-element-access/09 | bytelist_256 | src/obj.bend | a shift of 3 bytes is x >> 16 | KILLED | encset_r_l1024_u16.bend: byte_go_3 |  |
| r2-s03-element-access/10 | Fulu_list_uint64_128 | src/obj.bend | the pair is (hi, lo) | KILLED | coll_u64.bend: u64_read |  |
| r2-s03-element-access/11 | Fulu_list_uint64_128 | src/obj.bend | it is read two words later | KILLED | coll_u64.bend: u64_read |  |
| r2-s03-element-access/12 | Fulu_list_uint64_128 | src/obj.bend | hi is written two words later | KILLED | coll_u64.bend: u64_write |  |
| r2-s03-element-access/13 | bitlist_9 | src/obj.bend | bit i is bit i mod 16 of word i / 32 | SURVIVED |  |  |
| r2-s03-element-access/14 | bitlist_9 | src/obj.bend | the word index of the write is i / 16 | SURVIVED |  |  |
| r2-s03-element-access/15 | bitlist_9 | src/obj.bend | the bit position is i mod 16 | SURVIVED |  |  |
| r2-s03-element-access/16 | Fulu_list_bytevec_2048_4096 | src/obj.bend | the slice copies floor(n / 4) words | SURVIVED |  |  |
| r2-s03-element-access/17 | Fulu_list_bytevec_2048_4096 | src/obj.bend | it starts at word p >> 2 + 1 | KILLED | cell_rw.bend: slc_step |  |
| r2-s04-packed-validity/01 | VarTestStruct | src/obj.bend | the evenness test is n & 3 = 0 | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: valid |  |
| r2-s04-packed-validity/02 | Fulu_list_uint64_128 | src/obj.bend | the divisibility test is n & 3 = 0 | KILLED | venc.bend: words_ok_u64 |  |
| r2-s04-packed-validity/03 | Fulu_list_uint64_128 | src/obj.bend | the divisibility test is n & 1 = 0 | SURVIVED |  |  |
| r2-s04-packed-validity/04 | Fulu_list_bytevec_2048_4096 | src/obj.bend | the divisibility test is n & 15 = 0 | SURVIVED |  |  |
| r2-s04-packed-validity/05 | Fulu_list_bytevec_2048_4096 | src/obj.bend | the general case tests n / unit = 0 | KILLED | spec_arr_SyncCommittee.bend: SyncCommittee_spec_bytes |  |
| r2-s04-packed-validity/06 | VarTestStruct | src/obj.bend | the lower bound is strict (n > lo) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/07 | VarTestStruct | src/obj.bend | the upper bound applies only when big (and instead of or) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/08 | VarTestStruct | src/obj.bend | the storage test is ceil(n / 4) < capacity (a full array is refused) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/09 | VarTestStruct | src/obj.bend | the storage check counts n / 4 words (floor: a partial last word may be missing) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/10 | VarTestStruct | src/obj.bend | the tail test uses n mod 2 (r = 3 is tested like r = 1) | KILLED | arr_copy.bend: vok |  |
| r2-s04-packed-validity/11 | bitlist_9 | src/obj.bend | storage is required only through word nbits >> 5 - 1 | KILLED | encx_bits6.bend: valid |  |
| r2-s04-packed-validity/12 | bitlist_9 | src/obj.bend | r is nbits mod 16 | KILLED | encx_bits6.bend: valid |  |
| r2-s04-packed-validity/13 | bitlist_9 | src/obj.bend | the limit applies only when big (and instead of or) | KILLED | vbitcont.bend: valid_eval |  |
| r2-s04-packed-validity/14 | bitvector_9 | src/obj.bend | the check reads word k >> 5 + 1 | KILLED | vuwl_bv1281.bend: valid |  |
| r2-s05-poison/01 | VarTestStruct | src/obj.bend | the poison bit is not kept (a plain sum) | KILLED | venc.bend: padd_ok |  |
| r2-s05-poison/02 | VarTestStruct | src/obj.bend | the poison test is strictly above 2^31 (exactly 2^31 is not detected) | SURVIVED |  |  |
| r2-s05-poison/03 | VarTestStruct | src/obj.bend | a false flag contributes bit 30 | SURVIVED |  |  |
| r2-s05-poison/04 | VarTestStruct | src/obj.bend | the storage test is ceil(n / 4) < capacity | KILLED | var_plist_proglist_uint256_enc.bend: encode_eval |  |
| r2-s05-poison/05 | bitlist_9 | src/obj.bend | the storage test is (k >> 5) + 1 < capacity | KILLED | var_bits_enc_bitlist_32.bend: encode_eval |  |
| r2-s05-poison/06 | VarTestStruct | src/obj.bend | the output length is m + 1 | KILLED | VarTestStruct_encode_ssz_proof_generated.bend: VarTestStruct_mc_ser |  |
| r2-v01-composite-validity/01 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | field attestation_1's validity is not consulted | UNJUDGED |  |  |
| r2-v01-composite-validity/02 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | field attestation_2's validity is not consulted | UNJUDGED |  |  |
| r2-v01-composite-validity/03 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | the running conjunction is an or at the last field | SURVIVED |  |  |
| r2-v01-composite-validity/04 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | the running conjunction is an or at the first step | SURVIVED |  |  |
| r2-v01-composite-validity/05 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | the validity of attesting_indices is not consulted | UNJUDGED |  |  |
| r2-v01-composite-validity/06 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | the field validity is or-ed with the accumulator | SURVIVED |  |  |
| r2-v02-box-absent/01 | FuluAttesterSlashing | types/FuluAttesterSlashing_encode_ssz_generated.bend | an empty box is valid | SURVIVED |  |  |
| r2-v02-box-absent/02 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | an empty box is valid | SURVIVED |  |  |
| r2-v02-box-absent/03 | FuluAttesterSlashing | types/FuluIndexedAttestation_encode_ssz_generated.bend | an empty box contributes no poison to the running size (the encoder writes nothing for it and reports a valid size) | KILLED | IndexedAttestation_generated.bend: IndexedAttestation_mc_bxpoison_IndexedAttestation |  |
| r2-v03-element-array-validity/01 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the storage check n <= capacity is dropped from the validity | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/02 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the storage check is n < capacity (a full array is refused) | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/03 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the limit check is dropped (Bool.or(True, ...)) | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/04 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the limit check is n <= 17 | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/05 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the size pass does not check the storage (size = n * 76 whatever the array holds) | KILLED | encx_l16_WithdrawalRequest.bend: sizex_l16_WithdrawalRequest |  |
| r2-v03-element-array-validity/06 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the size-pass storage check is n < c | KILLED | encx_l16_WithdrawalRequest.bend: sizex_l16_WithdrawalRequest |  |
| r2-v03-element-array-validity/07 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the running size reported by putn is 75 n | KILLED | var_rlenc_ExecutionRequests.bend: pvl_l16_WithdrawalRequestW |  |
| r2-v03-element-array-validity/08 | FuluExecutionRequests | types/Fulu_list_WithdrawalRequest_16_encode_ssz_generated.bend | the intermediate elements are written at pos + 75 i | KILLED | var_rlenc_ExecutionRequests.bend: ptl_l16_WithdrawalRequestW |  |
| r2-v04-group-validity/01 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the group g2 step keeps only the last group's validity (the running conjunction is replaced by ok) | SURVIVED |  |  |
| r2-v04-group-validity/02 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the final step ignores the last group (acc only) | SURVIVED |  |  |
| r2-v04-group-validity/03 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of group g0 is not carried into the conjunction (acc dropped at the second step) | SURVIVED |  |  |
| r2-v04-group-validity/04 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of group g1 (extra_data, transactions, withdrawals) is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/05 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of group g0 (logs_bloom) is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/07 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of the transactions list is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/08 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the validity of the withdrawals list is not consulted | UNJUDGED |  |  |
| r2-v04-group-validity/09 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the last field's validity is combined with the accumulator by or | SURVIVED |  |  |
| r2-v04-group-validity/10 | FuluExecutionPayload | types/FuluExecutionPayload_encode_ssz_generated.bend | the logs_bloom validity is combined with the accumulator by or | SURVIVED |  |  |
| r2-v05-attestation/01 | FuluAttestation | types/FuluAttestation_encode_ssz_generated.bend | the validity of aggregation_bits (the only checked field of Attestation) is not consulted | UNJUDGED |  |  |
| r2-v05-attestation/02 | FuluAttestation | types/FuluAttestation_encode_ssz_generated.bend | the field validity is or-ed with the accumulator | SURVIVED |  |  |
| r2-v06-composite-list-validity/01 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | an element's validity is combined with all earlier ones (conjunction) | SURVIVED |  |  |
| r2-v06-composite-list-validity/02 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | an element's validity is combined with all earlier ones (conjunction) | SURVIVED |  |  |
| r2-v06-composite-list-validity/03 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | every one of the n elements is checked | KILLED | encx_l1048576_bl1073741824.bend: valid_l |  |
| r2-v06-composite-list-validity/04 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | the list is valid iff the loop result is valid | SURVIVED |  |  |
| r2-v06-composite-list-validity/05 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | the count may not exceed the storage | KILLED | encx_l1048576_bl1073741824.bend: valid_l |  |
| r2-v06-composite-list-validity/06 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | List[Transaction, 1048576] holds at most 1048576 transactions | KILLED | encx_l1048576_bl1073741824.bend: valid_l |  |
| r2-v06-composite-list-validity/07 | FuluExecutionPayload | types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend | an element is validated in place (swapped out and set back) | KILLED | encx_l1048576_bl1073741824.bend: va_go |  |
