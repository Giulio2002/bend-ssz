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

## Regeneration

```
/opt/homebrew/bin/python3 codegen/check_schema.py      # YAML vs frozen inventory
/opt/homebrew/bin/python3 codegen/generate.py          # types/, benchmarks/objprog/
/opt/homebrew/bin/python3 codegen/laws.py              # proofs/obj/
/opt/homebrew/bin/python3 codegen/generate.py --check   # fails if anything is stale
```

Generation is deterministic: the same inputs give byte-identical outputs, and
`--check` is the gate that the checked-in sources match the schema. A malformed
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
| `src/buffer.bend`, `src/obj.bend`, `src/merkle_fast.bend`, `src/digest.bend` | packed buffers, owning collections, streaming Merkleization, the pinned BendHub SHA-256 | shared runtime primitives; generating 109 copies of them would multiply the proof graph instead of sharing it. The operator requirement is explicit that codegen-only does not mean deleting reusable runtime support. |
| `spec/*.bend` | the independent mathematical SSZ definitions | must stay independent of the generator, or the proofs would compare the implementation with itself |
| `src/model.bend` and the list-based modules under it | the model the 29 frozen `END_TO_END` propositions are stated about, and the transport the 5,440 official cases run through in `tools/spectests.py` | removing them would delete checked propositions that the frozen acceptance gate requires, before equivalent generated laws exist. See `docs/LAW_API_MAP.md` and `WORK_LOG.md` for the exact remaining obligation. |
| `src/cscan.bend`, `src/cschema.bend`, `src/ccompile.bend`, `src/croot.bend` | the compact window scanner and its schema compiler | `proofs/compact/sound.bend` is a *universal* checked soundness proof of this scanner. It is no longer a production entry point and no benchmark uses it; it is kept as proof-carrying reference code until the generated validators have their own universal proofs, because deleting it would delete proof coverage with nothing to replace it. |
