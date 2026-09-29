# bend-ssz

Pure-Bend SSZ for the 109 pinned mainnet Fulu names and the 136 supported forms of the official
`ssz_generic` suite (144 schemas in the suite; the 8 zero-length vectors and bit vectors are not SSZ types and are
refused; 5 of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`, so the object API has
109 Fulu + 131 generic = 240 names). For every name there is a generated typed object API (decode, encode,
hash_tree_root, field and element access), and machine-checked proofs that this API computes
exactly what an independent transcription of the SSZ specification says.

## What is proved

For every name `X`, in the object API's own terms (`proofs/api/X_<op>_proof_generated.bend`):

| Operation | Laws |
|---|---|
| encode | `encode_eval` (the bytes the encoder writes), `encode_spec` (they are the spec's encoding), `encoded_size`, `serialize_valid`, `roundtrip` |
| decode | `decode_accept` / `decode_spec` (a canonical encoding decodes to its value), `decode_reject` / `decode_none` (every other input is rejected), `decode_unique`, `reject_short` / `reject_long` |
| hash_tree_root | `root` (the returned digest satisfies the spec's root relation for the object's value) |

These are then bridged to the list-based model of [END_TO_END.bend](END_TO_END.bend): the
`e2e/` files state, per name, that the object API's result is exactly `serialize`,
`deserialize` and `hash_tree_root` of END_TO_END's model at the object's value. END_TO_END's
laws (serialize_correct, deserialize_correct, deserialize_rejection_correct,
hash_tree_root_correct, ...) relate that model to the specification in `spec/`.

Details: [docs/RESULTS.md](docs/RESULTS.md). Premises and known limits:
[docs/PREMISES.md](docs/PREMISES.md). What must be trusted: [docs/TRUST.md](docs/TRUST.md).

## Layout

`src/` runtime, `types/` the generated API per name, `spec/` the frozen specification,
`proofs/` the checked laws, `e2e/` the bridges to END_TO_END, `codegen/` the generators.
See [docs/LAYOUT.md](docs/LAYOUT.md).

## Regenerate and check

    python3 codegen/regen_all.py            # regenerate every generated file (idempotent)
    python3 codegen/regen_all.py --check    # fail if any generated file is stale
    tools/check_fast.sh                     # check every .bend file through umbrellas (~4 min at 20 jobs)
    tools/check_all.sh                      # check every .bend file one by one (~55 min at 20 jobs)

See [docs/BUILD.md](docs/BUILD.md) for the checker, the resource limits and the per-file commands.
