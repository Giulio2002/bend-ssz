# Round 10 (agent/manual-spec-mutations-r10): proof gaps, container roots, writers, defaults, light-client / KZG

Fresh auditor. Faults planted on the tree of `agent/r8-fixes` 7650c30cc (fixer F's laws and dead-code removal included, so every
verdict below is already the F replay); nothing planted in fixer G's APIs (element get / set / len / append, container getters,
swaps, union selectors) or in code F removed. Tooling: `tools/mutation_testing/manual_spec_mutants/r10/` (gen_defs10.py, mk10.py
with the duplicate check against rounds 1-9, run10.py = run9.py, report10.py, probe `probes/p10a.bend`, the server scripts
`p1.sh p1h.sh h3.sh p2.sh pr.sh c1.sh c2.sh`); definitions `defs/r10_*.txt`; patches `patches/r10-*/NN.patch`; raw results
`r10/results/`; rows `r10/manual_round_10_survivors.json`.

## R10.0 Proof-gap list recomputed

`r10/unmentioned10.py` on agent/r8-fixes: 4,672 API-shaped definitions in types/, **780** named by no proof file (round 9: 802). By
suffix: get 338, set 216, read 117, swap 42, ok 30, valid 21, uncache 12, append 2, serialize 1, default 1. After removing fixer G's
families (get / set / swap, 596) 184 remain: the `_read` readers of fixed containers, bit vectors and scalar vectors (reached through
`X_decode`), the `_ok` / `_bx_ok` byte validators, the per-group `_gK_valid` predicates (round-9 e01), `_uncache` / `croot_read` of
the cached Fulu lists (F's cache laws), `pl_u128_append` / `pl_u256_append` (G), `BeaconState_serialize`, `bv128_default`. They are
unnamed but inside the facade cones, so this round planted faults in the code shapes they share (readers r01, validators l02,
defaults d01) and in the round-10 focus areas, and judged each by the proofs whose cone holds the file.

## R10.1 Result

| | count |
|---|---|
| New faults | **342** (generated from 10 hand-designed patterns over every file where the shape occurs: 318; hand-written: 24) |
| (A) killed by a named law | **291** |
| (A) survived every checked root | **12** (all r10-d01, default constructors) |
| (A) UNJUDGED (checker stack overflow twice / 120 s timeout on every root that holds the file; never counted as a kill) | **39** |
| Not counted | 30 first-version r10-h03 mutants (`D.node(hl, d_X, d_X)`: a linear digest used twice, rejected by the checker as ill-typed, not by a law); replaced by the 31 instances counted above |
| (B) corpus, 14 proof-killed sample | 12 KILLED, 1 SURVIVED (d01/06: a default, not observable), 1 ERROR (old h03/07 did not compile, see above) |
| (B) corpus, the 39 proof-unjudged | 32 KILLED by the corpus, 6 SURVIVED, 1 not run (d01/10, a default) (3 BeaconState: no corpus case under the size cap; 2 size-pass faults that no public entry point reaches; 1 refusal-path fault the valid-only corpus cannot reach) |
| (B) corpus on the 12 survivors | cannot observe: the corpus decodes valid bytes, re-encodes and hashes them; it never calls `X_default` |
| Probe p10a (public calls only) on the 12 survivors | **12 of 12 print a different line** than the unmutated build |

Per family (A killed / survived / unjudged):

| family | fault | instances | K / S / U |
|---|---|---|---|
| r10-h01-root-neighbour | container root: two neighbouring field roots exchanged | 65 containers (every Fulu container, generic test containers) | 65 / 0 / 0 |
| r10-h02-root-cross | container root: field roots exchanged across a pair boundary | 26 | 26 / 0 / 0 |
| r10-h03-root-dup-pad | container root: the odd last field root carried up unhashed instead of hashed with the zero chunk | 31 | 31 / 0 / 0 |
| r10-h04-root-zero-level | container root: zero subtree of depth k replaced by the zero chunk | 14 | 14 / 0 / 0 |
| r10-l01-kzg-sync-roots | SyncCommittee pubkeys Vector[Bytes48,512] element depth / tree depth; List[KZGCommitment,4096] depth, element depth, mix-in count; List[Cell,4096] element depth, mix-in count; FinalityBranch / ExecutionBranch depth; Bitvector[128] chunk byte order / padding side | 11 | 11 / 0 / 0 |
| r10-l02-kzg-decode | KZG list limit / alignment, Cell list alignment, DataColumnSidecar variable-field windows / offset order / first offset, LightClientUpdate / Bootstrap / FinalityUpdate windows, order, first offset | 11 | 9 / 0 / 2 |
| r10-p01-active-fields | progressive container active_fields bit order in the byte, byte order, polarity | 3 | 3 / 0 / 0 |
| r10-r01-reader-advance | decode: a field read at the previous field's offset | 60 | 50 / 0 / 10 |
| r10-w01-fixed-order | serialize: the first two fixed-part fields written at each other's position | 20 | 14 / 0 / 6 |
| r10-w02-var-slot | serialize: the offsets of two variable fields written into each other's slot | 14 | 11 / 0 / 3 |
| r10-w03-size-fixed-part | serialize: the size pass counts the fixed part 4 bytes too long | 27 | 17 / 0 / 10 |
| r10-w04-first-offset | serialize: the first offset 4 too small | 23 | 16 / 0 / 7 |
| r10-d01-default | default value of a type not all zero / a vector default one element short | 37 | 24 / 12 / 1 |

Killing laws: the facade `st_<Name>` / `stg_<Name>_k` root laws (h01-h04, l01, p01), `<Name>_spec_decode` / `rd_ok` / `okA..okF` /
`<Name>_decode_first_offset` (r01, l02), `<Name>_spec_bytes`, `rt_C`, `put_eval`, `rt_size`, `size_eval`, `<Name>_ms_size` (w01-w04),
`<X>_serialize_cap`, `vec_*_e2e_valid_default` and the `*_e2e_set_witness` laws (d01 length faults). Every round-10 focus area that
computes bytes or roots from a value is closed by the existing facades: no container root, writer, reader, KZG list or progressive
fault survived a check that completed.

## R10.2 Findings (critical: reachable through the public API, no law kills them)

**Default constructors are not tied to the spec default (r10-d01, 12 critical).** `X_default()` is the object API's constructor
(docs/API_CONTRACTS.md: "`X_default()` ... `serialize(default())` is the spec's zero encoding"; listed in types/runtime_index.json), and
the spec's *Default values* rule makes the default of every basic type, byte vector and bit vector all zero. No law states what
`X_default()` is for value-shaped kinds: the facades quantify over all values, the `_serialize_cap` / `vec_*_e2e_valid_default` laws pin
only the default's length, and the `*_e2e_set_witness` laws only the vector defaults inside the containers that have them. A
non-zero default therefore checks. Survivors (all with a probe line differing from the unmutated build, public calls only):

| id | default mutated | public counter-example (probe p10a) |
|---|---|---|
| d01/01 | `b20_default` (ExecutionAddress) byte 0 = 1 | `Bytes20_serialize(b20_default())`: checksum 200404057 -> 201327578, root `0,0` -> `16777216,0` |
| d01/02 | `b32_default` (Root, Hash32: every root field) | `Checkpoint_serialize(Checkpoint_default())`: ck 306242375 -> 2049052710, root changes |
| d01/03 | `b48_default` (BLSPubkey, KZGCommitment, KZGProof) | `Bytes48_serialize(b48_default())`, root changes |
| d01/04 | `b8_default` | `Bytes8_serialize(b8_default())` |
| d01/05 | `b96_default` (BLSSignature) | `Bytes96_serialize(b96_default())` |
| d01/09 | `bv128_default` bit 0 | `SyncCommitteeContribution_serialize(SyncCommitteeContribution_default())` |
| d01/11 | `bv512_default` bit 0 | `SyncAggregate_serialize(SyncAggregate_default())` |
| d01/12 | `bv64_default` bit 0 | `Attestation_serialize(Attestation_default())` (committee_bits) |
| d01/20 | `bv513_default` bit 0 | `bitvector_513_serialize(bv513_default())` |
| d01/21 | `bv5_default` bit 0 | `bitvector_5_serialize(bv5_default())` |
| d01/22 | `bool_default` = True | `boolean_serialize(bool_default())` |
| d01/23 | `u64_default` = 1 | `uint64_serialize(u64_default())`, `Checkpoint_serialize(Checkpoint_default())` (epoch) |

Each is an implementer-plausible slip (a constructor literal), reachable with no setter, and changes the bytes and root of every
container default that holds the field (Checkpoint, Validator, BeaconBlockHeader, SyncCommittee, Attestation, ...). What would close it:
one law per default-constructed kind `X_serialize(X_default()) = zero bytes of the fixed size` (or `X_default() = spec default`), the
generic counterpart of the `vec_*_e2e_valid_default` laws.

## R10.3 Unjudged (39) and not critical

The proofs could not judge these: every root holding the mutated file overflowed the checker stack twice at the pinned settings (or hit
120 s) on the mutant, though the same roots check the unmutated tree. That is itself a finding about the gate: a writer or reader
fault in these types turns the facade into a stack overflow rather than a named law failure (the full check reports it as a failure,
so a mutant would not merge, but the failure does not name a law). The corpus kills 32 of them (r01 x9, w01 x5,
w02 x2, w03 x8, w04 x7, l02/08). The rest:

* `r10-r01/11`, `r10-w01/03`, `r10-w02/05` (BeaconState reader / fixed-field order / offset slots): reachable through
  `BeaconState_decode` / `BeaconState_serialize`; no corpus case under the size cap; unjudged, critical-shaped (same faults are
  killed on every other type).
* `r10-w03/01` (BitsStruct), `r10-w03/16` (LightClientFinalityUpdate): **equivalent in context**: `X_encode` / `X_serialize` of these
  two types size the output with the writer cursor (`O.out_at` + `out_donem(m)`), and `X_size` has no caller in types/ or src/.
* `r10-l02/09` (LightClientUpdate decode: the o0 <= o1 offset check dropped): refusal path, the valid-only corpus cannot reach it; no
  targeted case this round; unjudged.
* `r10-d01/10` (`bv4_default`, BeaconState justification_bits): same shape as the 12 critical defaults; the BeaconState facade
  overflowed the stack; not in the probe (the BeaconState default is too large for the probe build).

## R10.4 Method notes

* Pass 1 (`p1.sh`, `p1h.sh`, `h3.sh`): the facade of the mutated operation only (`--k 0 --direct 0 --fac 1`). Pass 2 (`p2.sh`) for
  every non-killed fault: the 3 cheapest roots (proofs/**, e2e/**) that import the file and name a changed symbol, 1 direct importer,
  up to 3 facades; it killed 17 more (7 d01 vector defaults by `*_e2e_set_witness`, 3 by `vec_*_e2e_valid_default`, r01/58, 5 w03 and
  w04/04 by `ms_sizesym`, `vlit_rt_*`, `complex_default_serialize_100`, `rt_C`).
* The d01 faults on kinds with no facade of their own (Fulu bit vectors, Fulu vectors) were judged on the facades of the containing
  type (the patch header's `type:` was set to it; `r10/index10.json` still shows the kind).
* Corpus: `r9/corpus9.py` with `sizelimit-rt/kit/cases_corpus.jsonl` (`c1.sh`: 14 proof-killed sample; `c2.sh`: the unjudged).
* Probe: `r10/probes/p10a.bend` with `r3/apiprobe3.py` (`pr.sh`), 19 public cases (`X_serialize(X_default())` and
  `X_hash_tree_root(X_default())`).

## Round 10 fixes (agent/r10-fixes)

Scope: the 12 critical survivors of R10.2 (r10-d01 default constructors), `r10-d01/10` (bv4_default, BeaconState justification_bits),
`r10-l02/09` (LightClientUpdate decode with the o0 <= o1 test dropped) and the three BeaconState unjudged faults `r10-r01/11`, `r10-w01/03`,
`r10-w02/05`. Base: agent/access-laws 19cc482d5 (fixer G). No survivor was a code bug: each is closed by a generated law. No frozen statement
and no lock changed.

**1. New generator `codegen/proofs/slop/default_value_laws.py`** (files `proofs/slop/constants/<runtime>_<X>_default_<tag>_generated.bend`: 714 laws in 526 modules). The
spec's *Default values* rule (basic values zero / False, byte and bit vectors all zero, lists empty, a vector of N element defaults, a container
of field defaults, a union's first option) is computed here from the schema; the bytes and roots by the independent oracle
(codegen/core/independent_ssz_oracle.py), never from the generated code. Every law is by computation.

| Law | Covers | Pins |
|---|---|---|
| `<X>_default_serialize` | 224 names (every name whose default encodes to at most 2048 bytes; Fulu and generic) | `X_serialize(X_default())` is accepted and writes exactly the spec's default encoding (zero fixed parts, empty lists, each offset at the end of the fixed part) |
| `<X>_default_root` | 188 names (every name whose default's root takes at most 16 SHA-256 nodes in the oracle) | `X_hash_tree_root(hasher, X_default())` is the oracle's root of the spec default value (the 8 big-endian digest words) |
| `<R>_default_fields` | 105 records: every container and every field group of one (BeaconState g0..g4, ExecutionPayload, BeaconBlockBody, ...), the unions, the boxes | the default is the record of its fields' kind defaults, the kind named from each field's schema type (`ident`), not read from the default's body; a union's default is option 0 of its default; a box's default is the box of the default |
| `<kp>_default_zero` | 197 kinds: every other `_default` (basic values, byte / bit vectors, packed vectors and lists, bit lists, lists and vectors of composite elements) | the spec zero: `False{}`, `0`, `O.U64{0, 0}`, the record of ceil(n / 4) zero words, `O.words_new(n)` of the spec's n bytes (a vector) or 0 (a list); a bit list or composite list has length 0, a composite vector length N |

So every field kind's default is pinned once, every container's default is pinned field by field (BeaconState: `BeaconState_default_fields`
and `BeaconState_g0..g4_default_fields` over `v8192_b32`, `v65536_b32`, `v8192_u64`, `bv4`, the lists, `Checkpoint`, ...), and every name
small enough for the checker to encode or hash in a law also has its whole image and root stated. Above the caps (BeaconState,
HistoricalBatch, SyncCommittee, the light-client bootstrap / updates, BlobSidecar, ExecutionPayload's root, ...) the per-field laws and the
facades (serialize and hash_tree_root of every object) give the statement: the measured cost is about 4 ms per encoded byte and one second per
SHA-256 node (SyncCommittee's 24,624-byte image alone took 96 s, ExecutionPayload's root 87 s; a 24 KB byte-list literal overflows the stack).
**Coverage gate:** the generator stops when any `def <k>_default()` of either runtime has no law of this family (a kind with no schema type, a
representation with no zero literal, a record whose word count is not ceil(n / 4), a container field whose kind has no default).

**2. decode_literal_laws: out-of-order literals above the caps.** `<X>_decode_vlit_bad_order_<f>` (the default encoding with one offset one
byte below the one before it) is now emitted for every variable-size container up to 65,536 bytes, above the 2048-byte and 64-law caps of the
round-5 literals: new for LightClientUpdate and LightClientFinalityUpdate (the others already had theirs; BeaconState's 2.7 MB default keeps the
symbolic `BeaconState_decode_vlit_bad_order_sym_o<i>`).

**3. BeaconState windows** (round 7's ExecutionPayload approach, symbolic in the buffer / output and every field, so the 2.7 MB default never
appears):
* decode_literal_laws `<X>_decode_vlit_win_<step>` now also covers every reader step that reads a FIXED field: the field the next step binds is
  read at its own fixed-part position and size (the generator checks the generated reader against the schema and stops on a difference).
  104 new laws over the 24 variable-size containers with a generated reader (BeaconState: its g0..g4 fixed reads).
* new generator `codegen/proofs/slop/writer_window_laws.py` (`proofs/slop/alignment/<runtime>_<X>_writer_win_generated.bend`):
  `<X>_serialize_vwin_<step>` for every writer step of every container (`X_pw<i>`, `X_g<k>_pw<i>`, `X_put`, `X_g<k>_put`) that writes a field:
  each fixed field at `pos + p_f` and each variable field's offset into its own slot `_putv(out, pos, p_f, voff, f)`, checked against the
  schema. 155 laws over 70 containers (Fulu and generic).

Every new or changed file checks in under 35 s on the unmutated tree (the slowest: the `_default_image` modules of SyncCommitteeContribution,
BitsStruct, DepositRequest, SignedBeaconBlockHeader, PendingDeposit, 30 to 34 s; the window modules under 3 s).

**Replay** (each patch applied with `patch -p1` to a hard-linked copy of the tree with the new laws, the named file checked with tools/check.sh,
pinned settings; every failure read in the log: the law and the expected / observed terms):

| Fault | Killed by (law, file) | Also |
|---|---|---|
| r10-d01/01 b20_default | `b20_default_zero`, fulu_b20_default_zero | `Bytes20_default_serialize` (fulu_Bytes20_default_image) |
| r10-d01/02 b32_default | `b32_default_zero`, fulu_b32_default_zero | `Checkpoint_default_serialize` (fulu_Checkpoint_default_image) |
| r10-d01/03 b48_default | `b48_default_zero` | `Bytes48_default_serialize` |
| r10-d01/04 b8_default | `b8_default_zero` | `Bytes8_default_serialize` |
| r10-d01/05 b96_default | `b96_default_zero` | `Bytes96_default_serialize` |
| r10-d01/09 bv128_default | `bv128_default_zero` | `SyncCommitteeContribution_default_serialize`; on the base already `SyncCommitteeContribution_serialize_vcoll_bv128_api_zero` (round 9) |
| r10-d01/10 bv4_default (BeaconState) | `bv4_default_zero`, fulu_bv4_default_zero | on the base already `BeaconState_serialize_vcoll_bv4_api_zero` (round 9) |
| r10-d01/11 bv512_default | `bv512_default_zero` | `SyncAggregate_default_serialize`; round 9 `SyncAggregate_serialize_vcoll_bv512_api_zero` |
| r10-d01/12 bv64_default | `bv64_default_zero` | `Attestation_default_serialize`; round 9 `Attestation_serialize_vcoll_bv64_api_zero` |
| r10-d01/20 bv513_default | `bv513_default_zero`, generic_bv513_default_zero | `bitvector_513_default_serialize`; round 9 `bitvector_513_serialize_vcoll_bv513_api_zero` |
| r10-d01/21 bv5_default | `bv5_default_zero`, generic_bv5_default_zero | `bitvector_5_default_serialize`; round 9 `bitvector_5_serialize_vcoll_bv5_api_zero` |
| r10-d01/22 bool_default | `bool_default_zero`, fulu_bool_default_zero | `boolean_default_serialize` |
| r10-d01/23 u64_default | `u64_default_zero`, fulu_u64_default_zero | `uint64_default_serialize`, `Checkpoint_default_serialize` |
| r10-l02/09 LightClientUpdate o0 <= o1 dropped | `LightClientUpdate_decode_vlit_bad_order_sym_o1`, fulu_LightClientUpdate_decode_literal_order_sym (round 7) | see below |
| r10-r01/11 BeaconState proposer_lookahead read at 2736693 | `BeaconState_decode_vlit_win_g4_rd7`, fulu_BeaconState_decode_literal_win | |
| r10-w01/03 BeaconState genesis_time / block_roots swapped | `BeaconState_serialize_vwin_g0_pw0`, alignment/fulu_BeaconState_writer_win | |
| r10-w02/05 BeaconState offset slots 524464 / 524540 swapped | `BeaconState_serialize_vwin_g0_put`, alignment/fulu_BeaconState_writer_win | |

The bit-vector faults (d01/09, 10, 11, 12, 20, 21) were already killed on this base by round 9's `_api_zero` laws (agent/access-laws): the
auditor planted on agent/r8-fixes, before them. `r10-l02/09` is killed by the round-7 symbolic order law, which the auditor's pass 2 did not
select (it names `LightClientUpdate_v1` / `_c1`, not the changed symbols `LightClientUpdate_ok` / `_decode`). The new literal
`LightClientUpdate_decode_vlit_bad_order_finalized_header` passes on the mutant as well: with o1 < o0 the attested_header window has a wrapped
size, which the header's own validator refuses (its last variable field cannot reach the window end), so the dropped test is not observable on
any literal; the refusal itself is pinned by the symbolic law. The literal laws are kept: they pin the public refusal of an out-of-order table
for the two light-client updates, which no literal reached before.

Machine-readable: the `status` field of the 17 entries of `manual_round_10_survivors.json`; the replay runner
`tools/mutation_testing/manual_spec_mutants/r10/fix/` (`replay.sh`, `rp1.sh`, `rp1.txt`) and its logs `r10/fix/results/`.

**Checks** (fresh clone of 9f426b704 on the server, regenerate_all -j 8 reached its fixpoint in one pass): `tools/test_codegen.sh 8`: 53 unit
tests OK, ruff clean, 151/151 generators up to date; `tools/verify_frozen.py`: 42 files, 4 statement roots, 1915 statement_defs files match;
`tools/crash_hunt/regress.sh`: all cases pass; cold `CHECK_CACHE=0 tools/check_fast.sh --jobs 8 --no-cache` (nice 19, under the full-check
lock): all files check, 100 umbrellas (0 reused) in 1680 s, the slowest 481 s (FuluSignedBeaconBlock decode witness); the umbrella of the
light-client default modules took 424 s, each of its files under 35 s alone. Statement or lock changes: none.
