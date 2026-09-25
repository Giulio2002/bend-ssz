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
| `proofs/obj/spec_*.bend`, `serialize_*.bend` | codec laws against the independent spec (`codegen/spec_laws.py`) |
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
/opt/homebrew/bin/python3 codegen/spec_laws.py         # codec spec laws
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
only ones missing from that stock-checkable set. `proofs/obj/big_root_all.bend`
checks the five big root laws in one process (332 s, 3.9 GB with #1075).
