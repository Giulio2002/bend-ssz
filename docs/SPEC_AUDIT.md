# Specification audit: how faithful is `spec/` to the Ethereum SSZ reference?

Auditor: independent (agent/specaudit). Tree audited: `origin/main` 21434d34; the branch sits on 4347aa3d, where `spec/`, `schemas/`,
`codegen/fulu.yaml` and `types/` are byte-identical to 21434d34 (the later commits add proofs only). The frozen `spec/`, `schemas/`, `END_TO_END.bend`,
`ROOT_DOMAIN.bend`, `PROOF.bend`, `HASH_PROOF.bend` and everything in `frozen.lock.json` are untouched; this branch adds
`docs/SPEC_AUDIT.md` and `tools/spec_audit/` only).

Reference: `github.com/ethereum/consensus-specs` tag **v1.6.1**, commit 5fa6edcca8ab4cf548653e6680b17b9d3e04d225 (the pin in
`upstream.lock.json`; the same tag the test vectors in `fixtures.manifest.json` come from). Files used: `ssz/simple-serialize.md`
(byte-identical to the vendored copy), `specs/{phase0,altair,bellatrix,capella,deneb,electra,fulu}/**/*.md`, `presets/mainnet/*.yaml`,
`configs/mainnet.yaml`, `tests/generators/runners/ssz_generic_cases/*.py`. The vendored `fulu_mainnet.py` is **not** used as a
reference (it is generated from the same markdown and is itself one of the things being cross-checked).

## 1. Result in one page

| | |
|---|---|
| Real transcription errors (Bend differs from the reference) | **none found** |
| Constants, sizes, limits, field names and active-field bits compared mechanically | 6,841 items (172 scalar constants, 3,413 numeric attributes, 3,180 field names/orders, 76 protocol-rule probes); **0 mismatches** |
| Names compared | 109 Fulu names (3 sources each: `schemas/fulu_mainnet.json`, `spec/fulu_schemas.bend`, `codegen/fulu.yaml`) and 131 generic names (`proofs/obj/generic_specs.bend`) against the reference markdown/python |
| Semantic rules read and audited | 60 rules in the tables of section 4.1 to 4.8, plus the root-domain paragraph 4.9 |
| Differential cases (reference port -> compiled Bend object programs) | 48,279 cases over all 240 names, 37,138 accepted and 11,141 rejected by the reference: **0 disagreements** (verdict, re-encoding and `hash_tree_root` all equal) |
| The oracle itself (`ssz_ref.py`) against the official vectors of the pinned release | 5,432 of 5,432 (3,003 valid: decode, re-encode, root; 2,429 invalid: reject): the 5,137 `ssz_generic` cases that have a type plus the 295 `mainnet/fulu/ssz_static` cases (`official_vectors.py`) |
| Second reference (remerkleable at the pyspec's pinned commit) vs the markdown port | 44,290 cases (all 4,000-byte-or-shorter cases of all types but two): 34,546 accepted by both with equal roots and equal re-encodings, 9,671 rejected by both; 73 disagreements, all "port rejects, remerkleable accepts" for one reason (first offset is not the fixed size), all rejected by a later remerkleable commit (2f0baee) |
| Spec-level proofs by computation (`tools/check.sh` on `spec/*.bend`) | 375 files, 2,570 statements, all check; slowest file 87 s on a loaded server (typically 1 to 15 s) |
| Self-tests (the tools do detect errors) | constants: 7 of 7 injected single-number errors found; runtime harness: 200 of 200 corrupted expectations reported |
| Coverage gaps and judgement calls | section 6 (b) and (c) |

The transcription is faithful at every point this audit could reach. What the audit cannot show is listed under (b): chiefly the
2^32 size boundary, plain `Union` types (no Fulu or generic type is one), the 256-field progressive-container limit, and limits
above about 10^6 elements.

## 2. Method and what is independent of what

* **Reference side.** Two independent readings of the reference. (1) `tools/spec_audit/refparse.py` reads the markdown tables,
  the python code blocks (container classes) and the preset/config YAML at the tag, with the fork-override order of
  `pysetup/md_doc_paths.py`; it evaluates constant expressions (including `floorlog2`, `ceillog2` and `get_generalized_index`, the
  last re-implemented from `ssz/merkle-proofs.md`). Nothing is executed from pyspec. (2) `tools/spec_audit/ssz_ref.py` is a port
  of `ssz/simple-serialize.md` written from the prose (serialization, deserialization with the hardening list, Merkleization,
  progressive types, unions). A third source, remerkleable at commit 667eab00 (the one `pyproject.toml` of the tag pins), is
  run on the same cases by `rk_oracle.py` under Python 3.12 (it does not import on 3.14).
* **Bend side.** Text only for the constants audit: `spec/*.bend`, `spec/fulu_schemas.bend`, `schemas/fulu_mainnet.json`,
  `codegen/fulu.yaml`, `types/byte_alias.bend`, `types/list_alias.bend`, `proofs/obj/generic_specs.bend`, and the generated
  `types/*_def_generated.bend` names. Executed: the native object programs built by the repository's own pipeline
  (`benchmarks/quick.py`, Bend 2.0.34 runtime) and the pinned checker (`tools/check.sh`) on small computation proofs.
* **Why runtime agreement is evidence about the specification.** `END_TO_END.bend` and the `e2e/` bridges prove the object API
  equal to `spec/*.bend` (premises in `docs/PREMISES.md`). The runtime differential therefore tests the specification through
  the proved implementation; the spec-level computations (section 5.3) test the specification directly where its definitions
  are computable.
* **Reproduce.** `tools/spec_audit/run_all.sh` on the server (steps and prerequisites in section 7). All results were produced on the server;
  scratch is under `/tmp` (tmpfs) and `/srv/ssz-optimization/agents/specaudit`.

## 3. Constants audit (`tools/spec_audit/constants.py`, report in `tools/spec_audit/data/constants_report.md`)

Run: `python3 tools/spec_audit/constants.py --repo . --cs <consensus-specs at v1.6.1>`; exit status 1 on any mismatch. Tables:

| table | content | rows | result |
|---|---|---|---|
| A | the 42 numeric constants of `codegen/fulu.yaml` against presets/config/markdown (the three `*_GINDEX_ELECTRA` and `EXECUTION_PAYLOAD_GINDEX` are recomputed from the reference containers with `get_generalized_index`, not read from the "(= 169)" comments) | 42 | all match |
| A2 | the reference against itself: preset YAML vs the markdown table of the same name | 130 | all match |
| A3 | constants the reference types depend on that the yaml does not list | 0 | none missing |
| B | every name: field names and order, types, lengths, limits, nesting, in `schemas/fulu_mainnet.json`, `spec/fulu_schemas.bend` and `codegen/fulu.yaml` vs the markdown class | 109 | all match (3 sources each); no `(Container)` class of the forks up to Fulu is missing from the Bend side, and no Bend name is missing from the reference |
| C | `types/byte_alias.bend` sizes (24 aliases) and `list_alias.bend` (Transaction = 2^30) | 25 | all match |
| D | the 131 generic names (`proofs/obj/generic_specs.bend`) vs `ssz_generic_cases` (container, progressive-container, compatible-union classes, and the size families of vectors, bit vectors, bit lists, progressive lists) | 140 (131 match, 9 reference-only) | all match; `ModifiedTestStruct1..9` exist only in the reference (invalid-case helpers that map to the same schemas, no generated type) |
| E | protocol constants inside `spec/*.bend`: BYTES_PER_LENGTH_OFFSET (4), BYTES_PER_CHUNK (32), BITS_PER_BYTE (8), uint widths, bit weights, chunk-count formulas, delimiter room (7), union selector bounds (127/128, 1..127, at least 2 options after None), 256 active fields, progressive growth (x4, first leaf 1), 2^32 total size (four-fold /256) and the byte/limb radices | 87 (76 probes) | all match |
| F | limits in the names of the generated `types/*_generated.bend` files vs limits occurring in the reference types | informational | the `vec_uint8_N` files are the generic byte-vector schemas; the reference-only entries (`bitvector_4/64/128/512`, `bitlist_2048/131072`, `vec_uint64_64/8192`) are Fulu limits for which the object runtime uses a different generated shape (their roots and encodings are exercised by the differential run) |
| G | every numeric literal in `spec/*.bend` other than 0, 1, 2 (the arity annotation `&2` and base cases) that no probe in table E claims | 0 | complete: no unexplained numeric constant remains in the specification files |

Notes: (i) `schemas/fulu_mainnet.json` stores list/bitlist/bytelist limits as decimal strings and lengths as integers; the tool
normalizes (a representation detail, not an error). (ii) The tool treats `Vector[uint8, N]`/`ByteVector[N]` and
`List[uint8, N]`/`ByteList[N]` as equal, as the document's alias section requires. (iii) Self-test `tools/spec_audit/selftest.sh`
injects seven single-number errors (a bit-vector length, a branch length in the JSON, a preset in the yaml, the offset width, the
union selector bound, the progressive growth factor, a cell size) and requires a MISMATCH each time: all seven are reported.

## 4. Semantic audit, rule by rule

Reference line numbers are those of `ssz/simple-serialize.md` at v1.6.1. "Bend" is `file:line` in the audited tree. Verdict
**=** means the definition says what the reference says; "judgement" means a documented choice (section 6 (c)).

### 4.1 Basic types

| rule | reference | Bend | verdict |
|---|---|---|---|
| `uintN`, N in {8,16,32,64,128,256}, little-endian, exact N/8 bytes | 44, 197-202 | widths `primitives.bend:36-43` (1,2,4,8,16,32); little-endian digits `limb_digits` 46-48, `full_digits` 50-58; `uint_encoding` 90-91; `uint_domain` 74-75 (value < 256^width: high digits zero, `fits` 65-71) | = |
| decode: exactly N/8 bytes, every byte < 256 | 325-338 (scope) | `byte_scope` 94-103, `uint_decoding` 126-127 (`integer_value` 117-119 rebuilds eight 32-bit limbs) | = (rejects short, long, byte >= 256) |
| `boolean`: 0x00 / 0x01 only, single byte | 204-209 | encode 5-8; decode 10-25 (`Nil` rejects, extra bytes reject, only 0/1 accepted) | = |
| `byte` equals `uint8` | 45, 110-111 | `identical` 40-64 treats `ByteVector`/`Vector{Unsigned U8}` and `ByteList`/`ListOf{Unsigned U8}` as the same; schemas use `Unsigned{U8}` | = |
| root of a basic value: serialization right-padded to one chunk | 407, 360-365 | `uint_hash_tree_root` 129-131 (pad to 32), `boolean_hash_tree_root` 33-34, `root_relation.bend:128-132` | = |

### 4.2 Vectors, lists, bit vectors, bit lists

| rule | reference | Bend | verdict |
|---|---|---|---|
| `Vector[T,0]`, `Bitvector[0]` illegal | 152 | `type_legality.bend:53,55,57` (`0 < n`), `bytes.bend:10-13`, `bitfields.bend:5-6` | = |
| vector length must equal N, list length at most N | 71-75 | `codec.bend:98` (`0 < n` and `count == n`), `codec.bend:99` (`count <= n`), `byte_list.bend:11`, `bytes.bend:13` | = |
| fixed/variable classification (variable = lists, unions, bitlists, progressive lists, containers containing one) | 101-106 | `schema.bend:17-29` (None = variable: `ListOf`, `ByteList`, `BitList`, `ProgressiveList`, `ProgressiveBits`, `Union`, `CompatibleUnion` fall to `case _`); `times`/`sum` 7-15 | = |
| `Bitvector[N]` serialization: bit i at byte i/8, bit i%8, `(N+7)//8` bytes, padding zero | 211-218 | `bit_packing.bend:4-17` (weights 1..128, `pack`), `byte_count` 20-30, `bitfields.bend:16-17`; `schema.bend:22`, `codec.bend:78` `(n+7)/8` | = |
| `Bitlist[N]` serialization: length/8+1 bytes, delimiter bit set at index len, rest zero, length <= N | 220-232 | `bitfields.bend:21-22` (append `True` then `pack`; this puts the delimiter in a new byte when len%8==0), `list_domain` 8-9 | = |
| `Bitvector[N]` decode: exact byte count, padding bits zero | 325-338 | `bit_decode.bend:28-43` (`take` requires all remaining bits zero, `byte_scope(byte_count(size))`, `0 < size`) | = |
| `Bitlist[N]` decode: non-empty, last byte non-zero, delimiter is the highest set bit, at most 7 zero bits above it, length <= N | 317-320 | `bit_decode.bend:45-70` (`delimiter` scans from the top with room 7: an all-zero last byte never borrows, empty input is `None`; `bounded` 59-62 enforces `<= capacity`) | = |
| size assertion `< 2**32` for vectors, lists and containers (not for bit lists, unions) | 244 | `layout.bend:47` (`N.fits(4n, fixed+variable)`), `bytes.bend:5-13`, `byte_list.bend:11`; absent from `bitfields.bend` and `codec.bend:50-54` (union), as in the reference | = |
| `chunk_count`: Bitlist/Bitvector `(N+255)//256`; basic list/vector `(N*size+31)//32`; composite N; container `len(fields)` | 349-357 | `bit_root.bend:10-11`; `root_relation.bend:99-102` (`sequence_limit`), `byte_list.bend:19-20`, `root_relation.bend:164` (`count(fields)`) | = |
| list root = `mix_in_length(merkleize(pack(value), limit=chunk_count), len)`; empty list = zero subtree of the limit's depth | 411-416, 423-424 | `root_relation.bend:104-105,161-163`, `bit_root.bend:38-45`, `byte_list.bend:22-29`; empty chunks give `zero_subtree` (`tree.bend:25,29`, `merkle.bend:16-21`) | = (limit 0 gives one zero chunk, depth 0) |
| vector root = `merkleize(pack(value))` (basic) or of child roots (composite), no length mix | 407, 419 | `root_relation.bend:161` (`False`, `None` length); `byte_root.bend:7-18`, `bit_root.bend:21-26` | = |

### 4.3 Containers (fixed and variable parts, offsets)

| rule | reference | Bend | verdict |
|---|---|---|---|
| fixed part holds fixed-size fields and one 4-byte offset per variable field; variable parts follow in order | 234-254 | `layout.bend:10-34` (`slot`, `fixed_size`, `payloads`, `fixed_parts`), `encoding` 44-47; `codec.bend:101` | = |
| offset i = sum of fixed lengths + variable lengths before i | 247-250 | `layout.bend:28-34` (running `offset` starts at the fixed size, grows by each variable payload) | = |
| decoding: first offset equals the fixed-part size, offsets non-decreasing, each end within the input, last variable part ends at the input end, no trailing bytes after a fixed-size container, shorter than the fixed part rejected | 303-316, 325-331 | `layout_decoding.bend:87-98` (`start == position`, `start <= end`, `end <= total`, empty payload required at the end 89-92), `read` 55-58 (`cut` fails on a short input), `decoding` 107-108 (byte domain and `total < 2^32`) | = |
| equal consecutive offsets encode an empty child | (implicit in `b""` of a zero-length variable part) | `layout_decoding.bend:83-86` | = |
| decoding is the image of serialization (canonical bytes only) | 294-296 | `decoding_relation.bend:8-12` (`decodes`, `outside_image`) | = (also implies the "mismatching minimum element size" and "not aligned with element size" hardening items, because a slice that is not a valid child encoding is not in the image) |
| progressive container serializes like a container | 234 | `codec.bend:102` | = |

### 4.4 Unions and compatible unions

| rule | reference | Bend | verdict |
|---|---|---|---|
| serialization: selector byte then payload; `None` is the single byte 0x00 | 272-280 | `codec.bend:50-59,104-108`, `Null` fragment `codec.bend:84` (empty payload, selector 0) | = |
| a union is variable-size even if every option is fixed | 269-270 | `schema.bend:17-29` (`Union` falls to `None`); `codec.bend:50-54` always `T.Variable` | = |
| `None` only at selector 0; at least 2 options when the first is `None`; at least 1 option | 266-268, 161-162 | `type_legality.bend:63` (`None` first needs >= 1 option after it), `:64`, `:65` (`Union{other}: Empty`), `:69` (`Null` elsewhere is `Empty`) | = |
| selectors above 127 "should not be used"; out-of-bounds selector rejected on decode | 264-265, 331 | `type_legality.bend:63-64` (at most 127 options after the first: selectors 0..127), `schema.bend:31-37` (`option` is `None` past the chain), `codec.bend:56-59` | = / judgement (the prose says "should not"; the Bend makes a 129th option illegal) |
| `None` root = `mix_in_selector(Bytes32(), 0)`; other = `mix_in_selector(root(value), selector)` | 427-430 | `root_relation.bend:145-147,167-171`, `mixing.bend:18-30` | = |
| `mix_in_selector` appends the uint8 selector as a 32-byte chunk | 401-402 | `mixing.bend:21-22` (selector then 31 zero bytes), domain `selector < 256` 19 | judgement: the prose says "`uint8` serialization"; the vectors and remerkleable use a 32-byte little-endian chunk, which is what the Bend does (CORRESPONDENCE.md records it) |
| `CompatibleUnion`: selectors in 1..127, distinct, non-empty, options mutually compatible; serialization `selector || payload`; no `None` option (Bend choice) | 163-167, 282-290 | `type_legality.bend:44-47,66`, `compatibility.bend` (see 4.7), `codec.bend:107` | = / judgement (no `None` in a compatible union is not stated by the prose) |
| default of `CompatibleUnion` is an error | 143 | not transcribed (defaults are out of scope, CORRESPONDENCE.md) | n/a |

### 4.5 Progressive types

| rule | reference | Bend | verdict |
|---|---|---|---|
| `ProgressiveList`, `ProgressiveBitlist` serialize as `List`/`Bitlist` without limit | 234, 220-232 | `codec.bend:100` (no `require`), `codec.bend:80` (`list_encoding(length, bits)`) | = |
| `merkleize_progressive(chunks, num_leaves=1)`: empty is Bytes32(); else `hash(merkleize_progressive(chunks[num_leaves:], num_leaves*4), merkleize(chunks[:num_leaves], num_leaves))` | 386-395 | `progressive.bend:12-26` (depth 0, +2 per step = x4, left = remainder, right = `Tree.tree(depth, ...)` = binary tree of the first 2^depth chunks; fuel = number of chunks, which suffices because each step consumes at least one) | = |
| progressive list/bitlist root = `mix_in_length(merkleize_progressive(pack/pack_bits), len)` | 413-418, 425-426 | `root_relation.bend:143,163` (`aggregate(True, ...)`) | = |
| progressive container: `active_fields` <= 256 entries, no trailing 0, as many 1s as fields, non-empty | 155-160 | `type_legality.bend:62` | = |
| progressive container root: `mix_in_active_fields(merkleize_progressive(field roots at active slots), active_fields)` | 396-398, 421-422 | `root_relation.bend:107-117` (`placed`: root at each active slot, zero chunk at each inactive slot; `active_root` hashes with `pack_bits(active)` padded to a chunk) | judgement: the prose writes the list of element roots without the inactive slots; EIP-7495, the pyspec and the official vectors place zero chunks (section 5.2 shows the two readings give different roots for sparse containers, and the vectors fix the Bend reading) |
| compatible Merkleization for progressive types | 169-187 | `compatibility.bend:67-157` | = / judgement (4.7) |

### 4.6 Merkleization

| rule | reference | Bend | verdict |
|---|---|---|---|
| `pack`: serialize, right-pad to a multiple of 32, split; empty gives no chunks | 360-365 | `packing.bend:7-27` (the empty final partial group is not appended: `finish` on an empty buffer) | = |
| `pack_bits`: pack the bits (delimiter excluded) | 366-369 | `bit_root.bend:15-16` (`Pack.scan(Bits.pack(bits), 31n, ...)`) | = |
| `next_pow_of_two`: 0 -> 1, 1 -> 1, 2 -> 2, 3 -> 4 | 370-372 | `limits.bend:5-13` (`minimal(limit, depth)`: capacity(depth) >= limit and capacity(depth-1) < limit; limit 0 and 1 give depth 0) | = (unique depth) |
| `merkleize(chunks, limit)`: error if len > limit; pad to next_pow_of_two(limit); empty input is one zero chunk; 1 chunk is itself | 373-385 | `limits.bend:17-18` (`len <= limit`, chunks are 32-byte), `tree.bend:21-30` (`depth 0` returns the chunk, empty gives `zero_subtree`), `merkle.bend:16-21` | = |
| no limit: pad to next_pow_of_two(len) | 377-378 | `byte_root.bend:11-12` (`minimal(len(chunks), depth)`), vectors and containers use `chunk_count`/`count` as the limit which equals the chunk count of a valid value | = |
| zero hashes: `zero_subtree(d)` = hash of two zero_subtree(d-1), leaf = 32 zero bytes | (merkleize, virtual padding) | `merkle.bend:16-21` | = |
| `mix_in_length(root, n)` = hash(root || uint256 LE n) | 399-400 | `mixing.bend:8-14` (`full_digits` of a 256-bit value), `bit_root.bend:31-36` with `nat_bytes.bend:7-17` (`encoding(32n, len)`) | = |
| container root = merkleize of field roots (limit = field count) | 419-420 | `root_relation.bend:164` | = |
| hash is SHA-256 | (hash) | `merkle.bend:5-21` with the FIPS 180-4 package (`import 0xd9a2...`) | = (independent of the runtime SHA) |

### 4.7 Type legality and compatibility

| rule | reference | Bend | verdict |
|---|---|---|---|
| empty containers, empty progressive containers illegal | 153-154 | `type_legality.bend:24-25,61-62` (`0 < field_count`) | = |
| duplicate field names illegal | (not in the prose) | `type_legality.bend:14-25` | judgement (stricter; a python class cannot express duplicates) |
| compatible: self; byte/uint8; Bitlist/Bitvector same N; List/Vector same N and compatible element; ProgressiveList compatible element; Container same names in the same order and compatible fields; ProgressiveContainer: active slots with shared names have compatible types and no other name is shared; CompatibleUnion: all options pairwise compatible; all others incompatible | 169-187 | `compatibility.bend:40-64` (`identical`), `:103-157` (`derives`: `Step` for List/Vector/ProgressiveList/Container/ProgressiveContainer/CompatibleUnion, `Fork` for the pairwise rows), `:97-101` (`shared_positions`: a name shared at a different index is rejected), `:158-162` | = / judgement for the sparse progressive-container reading (a slot active in one type and inactive in the other is allowed as long as names do not collide elsewhere; this is EIP-7495's rule) |

### 4.8 Deserialization: every rejection condition

| reference condition (lines 325-338 and implicit) | Bend | evidence |
|---|---|---|
| offsets out of order, out of range | `layout_decoding.bend:87-98` | runtime: 1495 "offsets out of order or range" and 111 + 19 list-first-offset rejections, all rejected by the Bend programs; spec-level `lay_*` files |
| scope: extra unused bytes | `layout_decoding.bend:89-92`; image (`decoding_relation.bend`) | 567 "extra bytes after a fixed-size container" rejections plus the appended-byte mutations on every valid case |
| scope not aligned with element size | image (list serialization is a multiple of the element size) | 1786 rejections |
| more elements than the limit | `codec.bend:99`, `byte_list.bend:11`, `bitfields.bend:8-9`, `bit_decode.bend:59-62` | boundary cases L-1, L, L+1 for every list-like field with L up to 1.1 M elements (section 5) |
| out-of-bounds union selector | `schema.bend:31-37`, `codec.bend:56-59` | 98 compatible-union rejections (+3 empty); plain unions at spec level (`uni_*`) |
| out-of-bounds compatible-union selector | `schema.bend:44-47` | same |
| incomplete / corrupted / inner-invalid compatible-union payload | image of `tagged(parts(...))` (`codec.bend:50-54,107`) | truncated and byte-flipped payloads in the `CompatibleUnion*` cases |
| boolean not 0/1; wrong uint length | `primitives.bend:19-25,126-127` | 668 boolean + 380 uint-length rejections |
| bit vector padding bits set, wrong length | `bit_decode.bend:28-43` | 113 padding-bit + 322 length rejections |
| bit list: empty, no delimiter, delimiter beyond the limit | `bit_decode.bend:45-70` | 379 delimiter + 260 limit rejections |
| first offset not the fixed size | `layout_decoding.bend:98` (`start == position`) | 3130 rejections (+634 "shorter than the fixed part") |
| empty vector type | `type_legality.bend:53-57` | `vec_*_0`, `bitvector_0` are unsupported-by-design names whose official cases are all invalid |

### 4.9 How the Bend root and domain definitions treat empty lists and limits

`value_domain.bend:70-135` defines the root domain: `root_valid` demands exactly the structural conditions of the reference
(vector length N > 0, list length <= limit, byte list <= limit, bit vector exactly N bits, selector names an option) and no
serialization condition, so a value whose serialization would exceed 2^32 bytes still has a root, as `hash_tree_root` has no such
assertion (`ROOT_DOMAIN.bend` proves the domain strictly larger than the serializable one). `mixing_lengths` (27-56) adds only that
every mixed length fits in a uint256. Empty lists: `Pack.scan` gives no chunks, `Tree.tree` of no chunks is `zero_subtree(depth)`
at the depth of the **limit**, never of the length, and the length 0 is mixed in. A limit of 0 gives depth 0 (one zero chunk), as
`next_pow_of_two(0) = 1`. Checked at runtime on every list-like field at length 0 and by `root_*` computations (section 5.3).

## 5. Differential boundary tests

### 5.1 Corpus (`tools/spec_audit/cases.py`)

Types: all 240 names (109 Fulu from the markdown classes, 131 generic from the generator sources). For each type the reference
port builds valid encodings (zero, all-max, three random values, every list-like field at lengths 0, 1, 2, limit-1, limit; the
progressive growth boundaries 3, 4, 5, 20, 21, 22, 85, 86 for progressive lists and bit lists; bit lists at 7/8/9/15/16/17/255/256/257
bits, one level of list-of-container nested) and invalid ones: limit+1 of every list-like field (up to 1.1 M elements), first
offset wrong (0, 1, 3, 4, 5, orig+-1, orig+4, orig-4, total, total+1, 2^31, 2^32-1) at **every** offset slot of nested variable
parts, adjacent offsets swapped, truncated (1 and 4 bytes), appended 0x00/0x01, prepended 0x00, empty, single-byte flips, wrong
lengths of basic types, boolean 0x02/0xff, bit vectors with each padding bit set, bit lists with no delimiter, empty, zero last
byte, delimiter at limit/limit+1/limit+2, too many bytes, compatible-union selectors 0..5/127/128/255/max+1 with empty, short and
8-byte payloads. The reference verdict (accept/reject with the reason) and for accepted cases the root are computed by the port.
48,279 cases; reasons of the rejections and families are in `data/cases_summary.json`; a 1,252-case sample is in
`data/cases_sample.jsonl` (the whole corpus is regenerated from the seed in `cases.py`; it is several hundred MB).

### 5.2 Results

* **Compiled Bend object programs** (`run_bend.py`, the protocol of `benchmarks/checks/generic_object_conformance.py`:
  `build/obj-x<k>` generic, `build/obj-g<k>` Fulu, `SSZ_MODE=0`): 48,277 cases (two cases longer than 2 MB are listed without their bytes): 37,136 accepted by both, 11,141 rejected by both. For every accepted case the program re-encoded to the
  input bytes and produced the reference root; for every rejected case it refused. Disagreements: **0**
  (`data/bend_runtime.json`). `selftest_run.py` corrupts 200 reference expectations and the harness reports 200.
* **The oracle against ground truth.** `official_vectors.py` runs the markdown port over the official vectors of the pinned
  release (extracted from the release tarballs in the repository's tarball cache): all 5,137 typed `ssz_generic` cases (valid:
  decode, re-encode to the same bytes, the official root; invalid: reject) and all 295 `mainnet/fulu/ssz_static` cases pass. The 8
  invalid cases of zero-length vector types have no type to run.
* **Second reference.** `rk_oracle.py` ran the corpus through remerkleable at 667eab00 (the commit `pyproject.toml` of v1.6.1 pins): 44,290 of the 48,279 cases (the others are longer than 4,000 bytes, which remerkleable decodes in minutes and gigabytes for the large bit lists, or belong to `ProgressiveBitsStruct` and `ProgressiveComplexTestStruct`, which it cannot decode in reasonable time; the port and the Bend programs ran all of them). 34,546 cases were accepted by both, with equal roots and equal re-encodings; 9,671 were rejected by both. **73 cases are accepted by remerkleable and rejected by the port and by the Bend** (`data/rk_oracle.json`), all of one kind: a container whose first offset is not the size of its fixed part (14 types; for example `VarTestStruct` `ffff0b000000ffffffffff`, fixed part 7 bytes, first offset 11). The hardening list requires rejecting offsets out of range; the Bend and the port reject, remerkleable at the pinned commit is lax. The later remerkleable commit 2f0baee ("Reject non-canonical container offsets", PR 22) rejects all 73 (checked).
* **The progressive-container reading.** With the literal prose reading (field roots only, no zero chunks for inactive slots;
  `ssz_ref.hash_tree_root_prose_progressive_container`) the roots of `ProgressiveVarTestStruct` (`active_fields=[1,0,1,0,1]`) and
  `ProgressiveComplexTestStruct` and `ProgressiveSingleListContainerTestStruct` (every sparse one; `progressive_reading.py`) differ
  from the slot-placed reading that remerkleable, the official vectors and the Bend use;
  the Bend follows the slot-placed reading (CORRESPONDENCE.md "Progressive container roots"). See (c).

### 5.3 Spec-level proofs by computation (`specgen.py`, `spec_cases/`, `run_spec_cases.sh`)

The runtime run goes through the proved implementation. To reach `spec/*.bend` itself, `specgen.py` writes
`def cN() -> {f(args) == expected : T}: {==}` statements for the computable specification functions and `tools/check.sh` checks
them (the checker evaluates `f`; the file is accepted only if it reduces to the reference value, verified by a negative test:
changing one expected byte makes the checker report the mismatch):

| group | specification function | what it fixes | statements |
|---|---|---|---|
| `ser_*` | `codec.encoding_for_legal_type(schema, value)` of `G.<name>()`/`F.<name>()` | serialization of accepted reference values, all generic and 30+ Fulu schemas | 1,064 |
| `serneg_*` | the same function | `None` for limit+1, vector length -1/+1, uint out of range, bad compatible-union selector; `Some` at the limit | 260 |
| `dec_*` | `boolean_decoding`, `uint_decoding`, `bitvector_deserialize`, `bitlist_deserialize`, `Bytes.vector_decoding`, `ByteList.decoding` | accept/reject and decoded value, including byte values >= 256 | 893 |
| `lay_*` | `layout_decoding.decoding(widths, bytes)` | first offset, order, range, tail, short input, with the reference slices | 203 |
| `root_*` | `ByteList.at_depth`, `BitRoot.bitlist_at_depth`, `bitvector_at_depth`, `ByteRoot.at_depth`, `Limits.at_depth`, `Prog.merkleize`, `Mix.mix_in_selector`, `mix_in_length` | limit-based depth at limit-1/limit/limit+1, empty input, zero padding, progressive growth boundaries 1/4/16, mixing, `None` union root | 135 |
| `uni_*` | codec of plain `Union[None, uint64, uint32]`, a 128-option union (selectors 127 ok, 128 rejected), union of a byte list and a bool vector | selector byte, `None` = 0x00, payload bounds | 15 |

Result: all 375 files check (`data/spec_cases_results.tsv`): the checker reduced every `f(args)` to the reference value. A first run with larger files had four `root_*` files over the 300 s cap on a server at load 40 to 250; the files were split (at most 2 hash-heavy statements each, progressive boundary 21 instead of 22) and re-run, all passing; no statement ever reported a mismatch.

## 6. Findings, ranked

### (a) Real transcription errors

None. Every constant, size, limit, field name and order, every serialization and deserialization rule, the Merkleization
functions and the legality/compatibility judgements agree with the reference at v1.6.1, as far as sections 3 to 5 reach. No patch
file is produced because there is nothing to patch (`spec/` is frozen; a patch would go to `tools/spec_audit/patches/`).

### (b) Constants or rules that nothing in the proofs or tests pins (coverage)

1. **The 2^32 total-size boundary.** The assertion `sum(...) < 2**32` is in the Bend (`layout.bend:47`, `bytes.bend:6-13`,
   `byte_list.bend:11`, `layout_decoding.bend:108`) and its constant is checked (table E), but no vector, no runtime case and no
   computation can reach a 4 GiB value (Bend `Nat` is unary and the programs cannot build one). Only the proofs about
   `N.fits(4n, ...)` fix its behaviour.
2. **Plain `Union` types.** No Fulu or generic type is a plain `Union`, so no official vector and no object program exercises
   `T.Union`; the only evidence is the `uni_*` spec-level computations (serialization only) added here; the union legality bounds are pinned by `proofs/slop/spec/type_legality.bend`.
   The union decoding rejections (bad selector, `None` with payload) are only characterized by the image relation.
3. **Union selector 127/128 and more than 128 options** (the "should not" rule): exercised by `uni_*` only for serialization.
4. **Progressive container limits** (256 active fields, `active_fields` ending in 0, count mismatch): legality is a `Type`
   (a relation), not computable, so it is covered by the validator-equivalence proofs, not by an example; the official vectors
   have at most 22 active fields.
5. **Type legality in general** (`type_legality.legal` is relational): the constants (0 < N, 127, 128, 256, 1..127) are
   checked (table E), the judgement is not evaluated on examples here. The repository's own mutation program
   (`docs/mutation_testing/MUTATION_PROOFS.md` section 8, `codegen/proofs/slop/spec_constants*.py`, `proofs/slop/spec/*.bend`, present from 14046e6e)
   closes the other side: it shows which spec literals a proof would notice moving (the 2^32 divisions, `255n`, the pack room
   `31n`, `capacity`, the union bounds 0/127, the sync-committee size, the erase placeholders). This audit did not re-run those
   mutants; it adds the missing half, that each literal equals the reference. Between the two, a spec constant is covered when it
   appears in table E here **and** is either killed by a law/pin there or listed as equivalent.
6. **Large limits.** Boundary L-1/L/L+1 is exercised for limits up to 1.1 M elements or 2 MB of encoding. For limits above that
   (validator registry 2^40, `HISTORICAL_ROOTS_LIMIT` 2^24, pending deposits 2^27) only lengths 0..3 are run; the limit's depth
   is still exercised (zero-subtree padding to depth 40) because a short list is Merkleized to the limit's depth, and
   `limits.minimal` is the same definition for all limits.
7. **Not transcribed, nothing audited:** default values and `is_zero`, summaries/expansions, the JSON mapping, and
   `merkle-proofs.md` (generalized indices; the four gindex constants the schemas depend on were recomputed here and match).
8. **Deserialization rejection of lists of variable-size elements and unions has no independent forward decoder in `spec/`**;
   the specification states it as "the image of serialization". This is sound if serialization is exact (it was checked at 1,064+
   points here and by the official vectors) but the rejection side is therefore tested through the implementation only.

### (c) Ambiguities in the reference and judgement calls in the Bend

1. **Progressive container root.** The prose (line 421) writes `merkleize_progressive([hash_tree_root(element) for element in
   value])`, which has one chunk per field; EIP-7495, remerkleable and the vectors put a zero chunk at each inactive slot. The Bend
   follows the latter. A literal reading of the prose would give different roots for any sparse `active_fields`.
2. **`mix_in_selector`** ("`uint8` serialization", line 402) is read as a 32-byte chunk. All implementations and the vectors agree.
3. **Union selectors above 127**: "should not" (prose) becomes "illegal" (Bend: at most 128 options). Harmless for every real type.
4. **Compatible unions**: `None` options are excluded (prose silent); duplicate field names are illegal (prose silent).
5. **Sparse progressive-container compatibility**: reading of "all `1` entries in both type's `active_fields` correspond to fields
   with shared names" as the intersection of active slots, plus "no other name shared"; the union-of-slots reading would be stricter.
6. **The pyspec's own ssz library is looser than the prose.** remerkleable at the commit pinned by v1.6.1 accepts a container whose
   first offset is not the fixed-part size (it was fixed upstream later by "Reject non-canonical container offsets"); the Bend
   and the port reject it as the hardening list requires. See section 5.2 for the cases.
7. **`byte` aliasing of schemas**: `Vector[uint8, N]` vs `ByteVector[N]` are distinct constructors in the Bend schema and equal in
   `identical`; the generic `vec_uint8_N` names use the first form and Fulu the second; roots and encodings agree.

### (d) Verified fine (evidence in sections 3 to 5)

All 42 preset/constant values; all 109 Fulu names, field by field, in three Bend-side sources; the 131 generic schemas; byte-alias and
`Transaction` sizes; the four generalized-index constants; BYTES_PER_LENGTH_OFFSET/BYTES_PER_CHUNK/BITS_PER_BYTE and every derived
number in `spec/*.bend` (no unexplained literal remains); little-endian encodings and uint widths; boolean strictness; bit vector and
bit list encodings (delimiter, padding, limit) and their rejections; vector/list/container layout and the offset rules;
compatible-union selector handling; `pack`, `pack_bits`, `chunk_count`, `merkleize` with limits (empty input, limit 0/1, limit-based
depth, virtual zero padding), `mix_in_length`, `mix_in_selector`, progressive Merkleization at the 1/4/16 boundaries, and the root of
`None`; the root domain (structural validity, no 2^32 condition, empty lists at the limit's depth).

## 7. Reproduce

On the ssz server (nothing on a laptop), from a checkout of the audited tree with `tools/spec_audit/` added:

```
git clone --depth 1 --branch v1.6.1 https://github.com/ethereum/consensus-specs.git $W/cs      # 5fa6edcc
python3 tools/spec_audit/constants.py --repo . --cs $W/cs                                       # table of section 3
tools/spec_audit/selftest.sh $W/cs                                                              # injected errors are found
export BEND_RUNTIME=/srv/ssz-optimization/toolchain-2.0.34/bin/bend BEND_NO_TELEMETRY=1 \
       BUN=/srv/ssz-optimization/toolchain-2.0.28/bun-linux-x64/bun
PY=/srv/ssz-optimization/agents/rename-venv/bin/python
$PY tools/spec_audit/official_vectors.py --repo . --cs $W/cs --fx $FX                           # the port vs the official vectors (FX: see run_all.sh)
$PY benchmarks/quick.py --build-generic all ; $PY benchmarks/quick.py --build all               # about 3 minutes, native programs
python3 tools/spec_audit/cases.py --repo . --cs $W/cs --out $W/cases --per-type 400
python3 tools/spec_audit/run_bend.py --repo . --cases $W/cases/cases.jsonl --out $W/cases --jobs 6
/tmp/sa312/bin/python tools/spec_audit/rk_oracle.py --repo . --cs $W/cs --cases $W/cases/cases.jsonl --out $W/cases
/tmp/sa312/bin/python tools/spec_audit/progressive_reading.py $W/cs
python3 tools/spec_audit/specgen.py --repo . --cs $W/cs --cases $W/cases/cases.jsonl --out tools/spec_audit/spec_cases
tools/spec_audit/run_spec_cases.sh 2 $W/spec-logs
python3 tools/spec_audit/summarize.py $W/cases tools/spec_audit/data $W/spec-logs
```

`run_all.sh` chains these. The remerkleable environment (`uv python install 3.12`, `pip install` of the pinned commit) lives under
`/tmp` and is recreated by `run_all.sh` when absent. The files under `tools/spec_audit/`: `constants.py`, `refparse.py`,
`bendparse.py` (constants audit), `ssz_ref.py`, `cases.py`, `run_bend.py`, `rk_oracle.py`, `official_vectors.py`, `progressive_reading.py`, `selftest.sh`, `selftest_run.py`
(differential), `specgen.py`, `spec_cases/`, `run_spec_cases.sh` (spec-level proofs: at most 2 checks at a time at nice 19, refuses to start while the
full-check lock is held), `summarize.py`, `run_all.sh`, `data/`. `PY` is a python with python-snappy and ruamel.yaml (the repository requirements).

## 8. Invalid objects and window cases (additive: `invalid_cases.py`, `invalid_bytes_cases.py`, `run_*`)

**Why.** The manual spec-mutation auditor (branch `agent/manual-spec-mutations`, 268 hand-written faults) found 34 faults that the proofs reject
(result KILLED) and that the 48,279-case corpus of section 5 and the official vectors never reach, and 9 faults that survived the proofs.
The corpus starts from BYTES: it decodes them and re-encodes what was accepted, so every object the Bend side serializes came out of a decoder
and is valid. Code that differs only on an invalid object (the validity pass of every `<Name>_serialize`) is unreachable from it. Per fault,
`tools/spec_audit/data/manual_fault_results.tsv` has the row (the 34 are the faults with A = KILLED and no corpus or official disagreement; 4 of
them, `u02/01`, `u02/05`, `bl01/02`, `p02/04`, had no corpus run at all in the merged results).

**Result.** 20 of the 34 corpus-missed faults and 6 of the 9 proof survivors are now caught (26 of 43). The remaining 17 are not caught by any
input the runtime can take (section 8.4): 12 are equivalent at runtime or masked by a second check, 2 are designed controls, 3 need inputs of
512 MB to 4 GB. The old corpus is untouched; everything is new files.

### 8.1 What was added

| file | content | count |
|---|---|---:|
| `invalid_cases.py` -> `data/invalid_cases.json` | object-level cases: NEUTRAL values (numbers, bit lists, element lists, field maps), the reference port decides refuse or serialize (bytes, root) | 200 (+ 75 reruns through the unchecked `<Name>_encode`) |
| `run_invalid_cases.py` | lowers every value to the raw record constructors of the compiled object API (a state no decoder or checked setter produces), one Bend program for all cases, one process per case; `--patch` for a mutated tree | |
| `invalid_bytes_cases.py` -> `data/invalid_bytes_cases.jsonl` | byte-level rows (cases.jsonl schema): every raw window of a pool for every variable field of 11 containers (valid values around it: zero, two random), and progressive lists at the chunk boundaries | 985 + 336 |
| `run_bytes_cases.py` | the rows against programs built from a tree with an optional patch (the same protocol as `run_bend.py`) | |
| `run_empty_input.py` | `G.decode(i, buf, 0)`: the empty input for all 240 names (an empty file cannot be loaded by the object programs) | 240 names |
| `data/manual_fault_results.tsv` | the 43 faults: result and reason | 43 |

Object-level cases by class (every case: the reference verdict, 125 refused and 75 serialized with their bytes):

| class | cases | what it guards |
|---|---:|---|
| uint-range | 9 | uint8 / uint16 above their width |
| bit-padding | 21 | bits above the length of a bit vector; stray bits of a bit list before its delimiter |
| limit | 36 | list / bit list one past the limit, vector one short or long |
| storage | 19 | storage smaller than the length, byte length that is not whole elements |
| field-validity | 22 | each field of SmallTestStruct, SingleField, ProgressiveSingleField, FixedTestStruct, VarTestStruct, ComplexTestStruct out of range among valid ones |
| union-payload | 2 | CompatibleUnionA with an out-of-range payload |
| bool-bytes | 15 | packed boolean vector with a byte 2, 3 or 255 |
| absent-box | 1 | the default ComplexTestStruct (see 8.3) |
| valid-bytes | 75 | valid objects at the boundaries: serialize bytes (offsets, lengths, padding); each also through `<Name>_encode` (+75 runs) |

On the clean tree: object cases 200 of 200 agree with the reference (1 known open, 8.3); byte cases 1,321 of 1,321; empty input 240 of 240.

### 8.2 Why the old corpus could not see them (the 20 caught)

| class | faults | reason |
|---|---|---|
| encode of an invalid object | bl05/01, bl05/03, bv03/01, bv03/02, bv03/03, f03/04, l02/03, l03/01, l03/03, l03/05, q02/05, u04/01, u04/02, v02/05, b04/01, n03/05 (16 + b04) | needs a value no decoder produces: padding bits, limit + 1, a wrong vector length, out-of-range scalars, packed boolean 2, a union payload |
| container field validity | c02/05, c06/02, c06/03, c06/04, c06/05 | the poison of ONE field must reach the result: needs a container with one invalid field among valid ones |
| unchecked encoder | v02/04 | `<Name>_encode` is not the path of `G.encode` (that uses `_serialize`), valid objects must go through it too |
| valid objects at a type the run did not cover | c05/06, m03/05 | the old corpus run of the auditor used one representative type (VarTestStruct: its offset is not 4-aligned; its list is the last field). The same corpus on ComplexTestStruct / FuluAttestation / ExecutionRequests catches them (40 and 13 cases); the object cases catch c05/06 with 26 |
| missing run | u02/01, u02/05 | the old corpus catches both (315 and 210 cases on VarTestStruct, SmallTestStruct, ComplexTestStruct); the merged results had no row |

### 8.3 A finding

`ComplexTestStruct_serialize(ComplexTestStruct_default())` is ACCEPTED and writes 86 bytes where the reference zero value has 100: the default
of a vector of variable-size elements (`vec_VarTestStruct_2_default`) holds boxes with no value (`O.BNone{}`), and the serializer writes their
offsets but no bytes instead of refusing (a boxed field with no value is refused elsewhere: `box_empty` of `tests_generated/invalid_objects.py`).
The case `absent-box/ComplexTestStruct/default_boxes` records it (marked `known`, reported as KNOWN-OPEN, not counted as a disagreement).
All other cases build vector fields with present elements. Not fixed here.

### 8.4 The 17 not caught, and why no case can

| fault | reason |
|---|---|
| b01/03 | dead behind the validator (every byte above 1 is refused before the reader runs) |
| bl01/02, p02/04 | the empty window is accepted by the mutated check and refused by a later one: no input, not even the empty one for all 240 names, differs |
| bl06/01 | the delimiter byte it adds to the chunked data is zero storage that is already zero: no root differs (also at the progressive chunk boundaries) |
| p01/06 | the fuel bound n/2 + 1 is never short of the number of subtrees |
| f03/06 | the window of a fixed field is 8 bytes by the layout |
| s01/04, s01/05 | redundant: the validity pass refuses the same storage |
| u04/03 | the byte writer only sees values the validity pass already bounded |
| v02/01, v02/02, v02/03 | masked by the unit check / equal bounds |
| z01/01, z01/02 | designed controls (capacity only, unused parameter) |
| s01/01, s01/02, s01/03 | need 512 MB to 4 GB inputs (bit count above 2^32 - 8, 2^29 bytes, 2^32 - 32 bytes): not run |

### 8.5 Reproduce (server)

    python3 tools/spec_audit/invalid_cases.py --repo . --cs <cs> --out tools/spec_audit/data/invalid_cases.json
    python3 tools/spec_audit/run_invalid_cases.py --repo . --cases tools/spec_audit/data/invalid_cases.json --work DIR [--patch P]
    python3 tools/spec_audit/invalid_bytes_cases.py --repo . --cs <cs> --out tools/spec_audit/data/invalid_bytes_cases.jsonl
    python3 tools/spec_audit/run_bytes_cases.py --repo . --cases tools/spec_audit/data/invalid_bytes_cases.jsonl --work DIR [--types A,B] [--patch P]
    python3 tools/spec_audit/run_empty_input.py --repo . --cs <cs> --work DIR [--patch P]

The patches are those of `agent/manual-spec-mutations` (`/srv/ssz-optimization/agents/manualmut/patches/<id>.patch`). A build is one compile of the
import closure of the program (8 to 15 s); 4 jobs at nice 19.
