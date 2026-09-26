# The schema-driven SSZ generator

The production SSZ implementation is generated. This file records what the
generator reads, what it writes, how to regenerate it reproducibly, and which
modules are *not* generated and why.

## Inputs

| Input | Role | Frozen? |
| --- | --- | --- |
| `codegen/fulu.yaml` | the 109 mainnet Fulu names, in consensus-spec notation, with symbolic mainnet constants | generator input (editable) |
| `tools/test_schemas.py` | the schema of every official `ssz_generic` case | **protected**, read only |
| `schemas/fulu_mainnet.json` | the independent pinned inventory the YAML is checked against | **protected** |
| `spec/*.bend` | the independent mathematical SSZ specification the laws are stated against | **protected** |

`codegen/schema.py` resolves the YAML into a small type tree (`Ty`).
`codegen/check_schema.py` compares every resolved name with the frozen
`schemas/fulu_mainnet.json` (109/109 identical) and requires ten malformed
documents to be rejected, so the YAML cannot drift from the consensus schema
without the check failing.

`codegen/generic.py` translates the frozen `ssz_generic` descriptions into the
same `Ty` tree. It adds no independent notion of what those cases mean: the
descriptions come from the protected runner input. Eight of the 144 distinct
descriptions are refused as not SSZ types at all (a zero-length vector, a
zero-length bit vector); they are recorded in
`types/generic_obj_index.json` under `unsupported`, no codec is generated for
them, and every official case that uses one is an invalid case.

## Outputs

| Output | Contents |
| --- | --- |
| `types/fulu_obj.bend` | the typed owning objects of the 109 Fulu names: a record per container, and per distinct shape a validator (`_ok`), reader (`_read`), size, writer (`_put`), root, force fold, field access/update, list append and the mutation entry point the fuzz campaign drives |
| `types/fulu_obj_g<k>.bend`, `benchmarks/objprog/g<k>.bend` | the measured programs, twelve names each |
| `types/fulu_obj_f<k>.bend`, `benchmarks/objprog/f<k>.bend` | the mutation/fuzz drivers, four names each |
| `types/generic_obj.bend` | the same generated code for the 136 supported generic SSZ forms |
| `types/generic_obj_g<k>.bend`, `benchmarks/objprog/x<k>.bend` | the generic conformance programs, eight schemas each |
| `types/obj_groups.json`, `types/obj_fuzz_ops.json`, `types/generic_obj_index.json` | the name → program/index tables the checks and benchmarks dispatch on |
| `proofs/obj/*.bend` | the generated mutation, collection, cache and cost laws (`codegen/laws.py`) |
| `proofs/obj/spec_*.bend`, `serialize_*.bend` | codec laws against the independent spec (`codegen/spec_laws.py`); `spec_g*` the same for the generic forms; `spec_arr_*`/`spec_garr_*` the names with array-backed storage (`codegen/spec_arr.py`); `spec_rec_Validator` with `word_mul.bend` (`U32.mul(w, 2^8k) == U32.shln(w, 8k)`, from `codegen/word_mul.bend.in`); `sub_pack`, `sub_*` the generic forms with sub-word leaves (`codegen/sub_laws.py`, with `bitsim.py`, `sub_cont.py`) |
| `proofs/obj/arr_copy.bend`, `arr_emit.bend`, `arr_shift.bend`, `arr_spec.bend`, `arr_vec.bend` | the loop laws of the runtime copy (`acopy`), emit and loader over perfect array trees for symbolic counts, and the spec side of word lists of symbolic length (`codegen/arr_laws.py`, called by `spec_laws.py`) |
| `proofs/obj/var_codec_<Name>{,_unique,_rej,_enc}.bend`, `big_var_codec_<Name>*.bend`, `var_fix_types.bend` | spec-connected codec laws of the variable-size names with word-aligned fixed fields around one `List[uint64, N]` (`codegen/var_laws.py`, encoder laws `codegen/var_enc.py`); a name whose list limit is 2^16 or more (IndexedAttestation) goes to `big_*` |
| `proofs/obj/var_bytes_<Name>{,_win,_unique,_rej,_enc}.bend`, `var_bytes_fix.bend`, `var_bytes_wput.bend` | spec-connected codec laws of the names whose variable part is a byte list at any length (ExecutionPayloadHeader) or a covered name (LightClientHeader, LightClientOptimisticUpdate), at a word-aligned window and on the whole buffer (`codegen/var_bytes.py`, encoders `var_bytes_enc.py`, nesting `var_bytes_nest.py`/`var_bytes_nenc.py`; libraries `proofs/obj/v{bytes,bspec,benc}.bend`); all stock |
| `proofs/obj/var_codec_DataColumnSidecar{,_acc,_unique,_rej}.bend`, `big_var_codec_DataColumnSidecar_enc.bend`, `v{mul,mv,mr,me,zeros}.bend`, `var_fix_types_m.bend` | DataColumnSidecar (three lists of byte vectors): decoder laws (stock) and encoder laws (big) (`codegen/var_multi.py`, `var_multi_enc.py`) |
| `proofs/obj/vrejf.bend`, `fixrej_*.bend`; `vrejb.bend`, `fixchk_bool{f,g}.bend`, `fixchk_Validator.bend`; `vrejp.bend`, `fixchk_pad.bend` | ok_eval (the validator T.<p>_ok on any buffer / a window at byte position x returns the length check and the byte checks of the window's bytes) and decode_reject (a byte list that fails those checks is outside the spec image) for every fixed-size Fulu name and generic form: length-only validators (`codegen/fix_reject.py`), booleans and boolean vectors and Validator's slashed byte (`fix_reject_chk.py`), bit vectors' padding bits (`fix_reject_pad.py`) |
| `proofs/gate/api_map.json`, `proofs/gate/MISSING.txt`, `proofs/gate/{big_,}g__<file>.bend` | the object API's coverage map (every Fulu name and generic form, every law, the proving file and law, stock or big), the missing (name, law) pairs, and the gate: per (name, proving file) a module restating each proving law and discharging it by application (`codegen/api_gate.py`, derived by parsing proofs/obj) |
| `proofs/obj/vuw_bits.bend`, `vuw{1,2,3}.bend`, `vuwf{1,2,3}.bend`, `vuwp{1,2,3}.bend`; `vuw.bend` (hand-written) | the runtime's writers at an unaligned byte position 4 i + s: bit lemmas, the model SWc and its bytes, O.w32, the word-by-word writers, O.put_words (`codegen/var_uw.py`) |
| `proofs/obj/vfx_<p>.bend`, `vfxg.bend` | BeaconState's fixed fields at any byte position (`codegen/var_fixx.py`, `var_fixx_bv4.py`); stock |
| `proofs/obj/vfx_<p>.bend`, `vfxg.bend` | BeaconState's fixed fields at any byte position (`codegen/var_fixx.py`, `var_fixx_bv4.py`); LightClientUpdate's others (`vfx_v6_b32`, `vfx_v7_b32`, `vfx_SyncAggregate`: `codegen/var_winb_lc.py`); stock |
| `proofs/obj/{big_,}var_winx_<list>.bend` (record lists; boxed ones and `vua_fixb.bend` by `var_rlist_box.py`, byte-vector lists by `var_rlist_bv.py`), `var_winx_ExecutionRequests.bend`, `var_codec_ExecutionRequests.bend`, `v{rl,rc}.bend` | byte-offset window modules of lists of fixed records and of ExecutionRequests, and its whole-buffer decoder laws (`codegen/var_rlist.py`, `var_rlist_er.py`); stock |
| `proofs/obj/var_bytesx_<Name>{,_inv}.bend`, `vbx_fix.bend` | the same names at a window at any byte offset (the `vua_win.bend` interface), for nesting at unaligned offsets (`codegen/var_bytes_x.py`; library `proofs/obj/vbx.bend`); ExecutionPayloadHeader, LightClientHeader; and LightClientFinalityUpdate (two leading variable fields, `codegen/var_bytes_x2.py`, library `vbx2.bend`) with its whole-buffer decoder laws `_dec`; stock |
| `proofs/obj/var_winx_<list>.bend`, `var_winx_ExecutionRequests.bend`, `var_codec_ExecutionRequests.bend`, `v{rl,rc}.bend` | byte-offset window modules of lists of fixed records and of ExecutionRequests, its whole-buffer decoder laws (`codegen/var_rlist.py`, `var_rlist_er.py`; stock), and its encoder laws `var_rlenc_ExecutionRequests.bend` (stock) and `big_var_codec_ExecutionRequests_enc.bend` (big; `var_rlist_enc.py`) |
| `proofs/obj/var_bytesx_<Name>{,_inv}.bend`, `vbx_fix.bend` | the same names at a window at any byte offset (the `vua_win.bend` interface), for nesting at unaligned offsets (`codegen/var_bytes_x.py`; library `proofs/obj/vbx.bend`); ExecutionPayloadHeader, LightClientHeader; stock |
| `proofs/obj/big_vvl_<list>.bend`, `big_vvlb_<bytelist>.bend`, `big_vvlz.bend` (libraries `vvl.bend`, `vvlr.bend` stock, `big_vvlu.bend`) | byte-offset windows of lists of variable-size elements and of ByteList[N] (`codegen/var_vlist.py`); big |
| `proofs/obj/var_winx_ExecutionPayload.bend` (library `vwc.bend`, stock) | ExecutionPayload's byte-offset window over its children's windows (`codegen/var_winx_c.py`); checkq --big |
| `proofs/obj/sha_node.bend` | the SHA node bridge: runtime node = spec 64-byte message hash, via the pinned package law (`codegen/sha_laws.py`) |
| `proofs/obj/schema_shapes.bend` | Bool shape tests and shape laws for every schema constructor (`codegen/schema_shapes.py`) |
| `proofs/obj/root_names.bend`, `bits_leaf.bend`, `valid_names.bend` | phase-A root laws (Data-kind names: `X_root_correct`, `X_decoded_root_correct`) and generated-validity agreement (`codegen/root_laws.py`) |
| `proofs/obj/root_types.bend` | phase-B root laws (Type-kind containers, byte storage, boxes, lists of Data containers) with digest witnesses (`codegen/root_laws_b.py`); `--status` prints per-name coverage and the reason for every uncovered name; `--only N1,N2 --out F` writes a bisection probe (not a gate) |
| `proofs/obj/big_root_<Name>.bend` | BIG: the root laws of Transaction, ExecutionPayload, BeaconBlockBody, BeaconBlock, SignedBeaconBlock (their 2^30-byte limit fact is proved symbolically; see "Big proofs" below) and of BeaconState (2^24/2^27/2^40 limit facts, proofs/obj/big_lim_st.bend) |
| `proofs/obj/root_state.bend` | phase-B root laws of the shapes only BeaconState uses (`codegen/root_laws_b.py`, SPLIT_NAMES): generated after every other name and importing root_types as RT, so root_types does not grow; stock-checkable |
| `proofs/obj/blist_obj.bend` | root laws of List[uint8/uint16/Bytes32, L] held as byte storage, for any limit and depth (`codegen/blist_laws.py`) |

## Regeneration

```
/opt/homebrew/bin/python3 codegen/check_schema.py      # YAML vs frozen inventory
/opt/homebrew/bin/python3 codegen/generate.py          # types/, benchmarks/objprog/
/opt/homebrew/bin/python3 codegen/laws.py              # proofs/obj/
/opt/homebrew/bin/python3 codegen/spec_laws.py         # codec spec laws (also writes arr_*.bend; --no-big accepted)
/opt/homebrew/bin/python3 codegen/sub_laws.py          # codec spec laws of the generic sub-word forms (--no-big accepted)
/opt/homebrew/bin/python3 codegen/var_laws.py          # variable-size codec spec laws, incl. nesting (var_nest.py) [--no-big]
/opt/homebrew/bin/python3 codegen/var_plist.py         # progressive-list generic forms [--no-big]
/opt/homebrew/bin/python3 codegen/var_bits.py          # bit-list byte facts, generic BitList[N] laws [--no-big]
/opt/homebrew/bin/python3 codegen/var_bitc.py          # Attestation, PendingAttestation [--no-big]
/opt/homebrew/bin/python3 codegen/var_win.py           # window laws; AggregateAndProof, SignedAggregateAndProof [--no-big]
/opt/homebrew/bin/python3 codegen/var_ua.py            # unaligned offsets: word-join limbs, shifted-copy loops (vua_bits, vua_sc, vua_fix)
/opt/homebrew/bin/python3 codegen/var_uw.py            # unaligned writes: bit lemmas, SWc bytes, the writers at byte s (vuw_bits, vuw{1,2,3}, vuwf{1,2,3}, vuwp{1,2,3})
/opt/homebrew/bin/python3 codegen/var_winl.py          # byte-offset windows of List[AttesterSlashing,1], List[Attestation,8] [--no-big]
/opt/homebrew/bin/python3 codegen/var_winb.py          # byte-offset windows of containers with several variable fields (BeaconBlockBody, once its children exist) [--no-big]
/opt/homebrew/bin/python3 codegen/var_winb_lc.py       # LightClientUpdate's fixed-field modules; its window (var_winb's symbolic path) with --window, not yet checking
/opt/homebrew/bin/python3 codegen/var_winv.py          # byte-offset window of List[Validator, 2^40] (121-byte records at any phase) [--no-big]
/opt/homebrew/bin/python3 codegen/var_bytes.py         # byte lists at any length, and the names nesting them [--no-big]
/opt/homebrew/bin/python3 codegen/var_multi.py         # DataColumnSidecar (three lists of byte vectors); encoder big_ file
/opt/homebrew/bin/python3 codegen/fix_reject.py        # ok_eval / decode_reject, fixed-size names (also fix_reject_chk.py, fix_reject_pad.py)
/opt/homebrew/bin/python3 codegen/api_gate.py         # object API coverage map, missing list, gate modules (proofs/gate)
/opt/homebrew/bin/python3 codegen/var_rlist.py         # lists of fixed records (byte-offset windows), ExecutionRequests
/opt/homebrew/bin/python3 codegen/var_bytes_x.py       # the same names at any byte offset
/opt/homebrew/bin/python3 codegen/var_vlist.py         # lists of variable-size elements (transactions), ByteList[N] windows [--no-big]
/opt/homebrew/bin/python3 codegen/var_winx_c.py        # containers with several variable fields over child windows (ExecutionPayload; big children) [--no-big]
/opt/homebrew/bin/python3 codegen/var_top.py           # whole-buffer decoder laws of Transaction and ExecutionPayload; Transaction encoder [--no-big]
/opt/homebrew/bin/python3 codegen/var_agg_enc.py       # Attestation writer at a word position; AggregateAndProof, SignedAggregateAndProof encoders [--no-big]
/opt/homebrew/bin/python3 codegen/sha_laws.py          # SHA node bridge
/opt/homebrew/bin/python3 codegen/schema_shapes.py     # schema shape laws
/opt/homebrew/bin/python3 codegen/root_laws.py         # phase-A root laws, validity agreement
/opt/homebrew/bin/python3 codegen/blist_laws.py        # packed lists of uint8/uint16/Bytes32
/opt/homebrew/bin/python3 codegen/root_laws_b.py       # phase-B root laws (root_types, root_state, big_root_*)
/opt/homebrew/bin/python3 codegen/generate.py --check   # fails if anything is stale
```

Every law generator takes `--check` as well (all current on the final source,
2026-09-23).

Generation is deterministic: the same inputs give byte-identical outputs, and
`--check` is the gate that the checked-in sources match the schema. (The
definition reorder walks callee names in sorted order; iterating a raw `set`
there once made the order depend on Python's per-process hash seed. Checked with
`PYTHONHASHSEED=1,2,3 generate.py --check`.) A malformed
or unsupported YAML document raises `SchemaError` naming the offending type and
expression; the generator never guesses a layout.

## Why the generator is not trusted

The generator has no correctness laws. It is an ordinary Python program that
emits Bend source. Nothing is believed because the generator produced it:

* every emitted law is checked by the stock pinned Bend kernel, with no
  `@unsafe`, no axiom and no admitted hole;
* the emitted codecs are checked against *independent* oracles - the official
  case vectors, `codegen/oracle.py` (written from the specification, not from
  the generator) and the `spec/*.bend` transcription - never against a second
  copy of the generator's own algorithm.

## What is still hand-written, and why

| Module | Role | Why it is not generated |
| --- | --- | --- |
| `src/buffer.bend`, `src/obj.bend`, `src/merkle_fast.bend`, `src/digest.bend` | packed buffers, owning collections, recursive Merkle trees with the spec's shape (`O.mtree`/`ctree`/`ptree`, zero-subtree constants checked against spec/merkle.bend), the pinned BendHub SHA-256 | shared runtime primitives; generating 109 copies of them would multiply the proof graph instead of sharing it. The operator requirement is explicit that codegen-only does not mean deleting reusable runtime support. |
| `spec/*.bend` | the independent mathematical SSZ definitions | must stay independent of the generator, or the proofs would compare the implementation with itself |
| `src/model.bend` and the list-based modules under it (`src/ssz.bend`, `types/fulu.bend`) | the model the 29 frozen `END_TO_END` and 13 `ROOT_DOMAIN` propositions are stated about, and the API the 51 protected Bun runtime tests exercise through `tools/generic_transport.ts` / `tools/primitive_backend.ts` | removing them would delete checked frozen propositions and break protected tests. They are **not** a production path and no longer carry the official cases: `tools/spectests.py` runs all 5,440 official cases natively through the generated programs (iteration 19). `tools/generic_transport.ts` accepts arbitrary schema descriptions at run time, which a per-schema generated API cannot, so it stays as the model's test transport. See `docs/LAW_API_MAP.md` for the remaining obligation. |

Removed in iteration 20, because no production, measured or test entry point
reached them any more: the compact window scanner `src/cscan.bend`, its schema
compiler `src/cschema.bend`/`src/ccompile.bend`, the generated compact schema
tables `types/{fulu,generic}_cschema{,_index}.bend` and `types/generic_spec.bend`,
their generators `tools/generate_cschema{,_generic}.py`,
`tools/generate_generic_programs.py`, `tools/generate_compact_{mono,walk}.py`,
the checks `benchmarks/checks/{compile_equiv,ref_validate}.py`, and the scanner
proof modules `proofs/compact/{cv,cv_mono,cvm,cvm_mono,cvm_mono_gen,den,den_mono,sound,sound_leaf,sound_seq,sound_cont}.bend`.
Those proofs were about the scanner, which is not the generated validator, so
they covered no production code; nothing about the production path is lost.
Their reusable foundations are kept and used by the generated-path proofs:
`proofs/compact/found.bend` (the checked `Base.Array` get/set/swap/new/clone
laws over a mirror tree), `buf.bend`/`reads.bend` (the byte denotation of the
packed input buffer and `B.read32`), `bits.bend`, `arith.bend`.

## The import graph, computed (2026-09-22, re-run after the iteration-20 removals)

The codegen-only requirement is a statement about reachability, so it is
answered by a reachability computation rather than by reading import lines:

```
/opt/homebrew/bin/python3 codegen/import_graph.py [--check]
```

It parses every `import ... .bend` edge in the workspace and reports what each
class of entry point reaches. Result on this source:

| Entry points | Reaches, in `src/` |
| --- | --- |
| production: `types/fulu_obj.bend`, `types/generic_obj.bend` | `buffer`, `digest`, `merkle_fast`, `obj` - and nothing else |
| the ten measured programs `benchmarks/objprog/g*.bend`, the seventeen generic programs `x*.bend`, `native_bench/driver.bend` | no module beyond the four above |
| proof roots `PROOF`, `END_TO_END`, `ROOT_DOMAIN`, `HASH_PROOF` | 30 modules, **none shared with production** |
| legacy list model `src/ssz.bend`, `types/fulu.bend` (frozen propositions, protected runtime tests) | 29 modules, **none shared with production** |
| `spec/*.bend` | none - the independent specification shares no runtime module |

Outside `src/`, the production path also reaches the pinned BendHub SHA package
`0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend`, imported by `src/digest.bend`.
No `src/` module is unreachable from every entry point, so nothing is dead that
is merely unlisted.

`--check` fails if the production path ever reaches a module outside the four
runtime primitives (plus `sha256`/`merkle`), which is the property the
codegen-only requirement asks for. It is the audit to re-run after any import
change.

The legacy modules therefore remain in the tree but on no production or
measured path: they carry the frozen `END_TO_END`/`ROOT_DOMAIN` propositions and
the protected runtime tests, and `docs/LAW_API_MAP.md` records
what has to be proved about the generated path before they can be retired.

## Regeneration check, recorded

On the iteration-20 source: `codegen/check_schema.py` → `109 frozen names; 109
YAML names; 10 malformed documents; OK`; `codegen/generate.py --check` →
`generated sources are current`; `codegen/laws.py --check` → `generated laws are
current`; `codegen/import_graph.py --check` → `OK: the production path reaches
only the shared runtime primitives`.

## Big proofs (`big_*` files) and `--no-big`

A proof file named `proofs/obj/big_*.bend` is BIG: it holds a law whose
closed facts involve numbers too large for stock Bend 2.0.28 to evaluate (the
2^30-byte Transaction limit, the 2^40 BeaconState limits). Those facts are
proved symbolically (`big_lim_sym.bend`, `big_lim_bl.bend`) and instantiated
in exactly the form of the goal, which checks with a checker that compares
syntactically identical terms before normalizing them (bendlang/bend#1075).
Stock 2.0.28 evaluates them in unary and runs out of memory.

Every generator takes `--no-big`: it then writes no `big_*` file, and every
file it writes checks on stock Bend. The laws of the `big_*` files are the
only ones missing from that stock-checkable set. `codegen/var_laws.py` writes
`big_var_codec_IndexedAttestation*.bend` (the 131072-element list limit sits in
the laws' types; stock 2.0.28 overflows its stack on `U32.to_nat(131072)` there)
and the AttesterSlashing files built on it; `codegen/var_plist.py` writes
`big_var_plist_*.bend` (unbounded list storage depth; see LAW_API_MAP.md). `proofs/obj/big_root_all.bend`
checks the five big root laws in one process (332 s, 3.9 GB with #1075).
