# Results

## Coverage

- 109 mainnet Fulu names (`codegen/fulu.yaml`, frozen in `schemas/fulu_mainnet.json`) and the
  `ssz_generic` forms: 136 supported schemas (15 official classes plus 121 structural forms such as `vec_uint16_4`,
  `bitlist_33`, `proglist_bool`) of the suite's 144; the other 8 (zero-length vectors and bit vectors) are not SSZ types
  and are refused. Five of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`
  (`uint16` and `uint128` exist only in the suite), so there are 131 generic names beside the 109 Fulu ones. Readable
  names come from `codegen/names.py`.
- <!-- fig:names -->240<!-- /fig --> names have object-API facades (`proofs/api/`: <!-- fig:facade_files -->720<!-- /fig --> files), each
  with an encode, a decode and a hash_tree_root file. `proofs/gate/MISSING.txt`: <!-- fig:missing -->0<!-- /fig --> of
  <!-- fig:core_pairs -->2160<!-- /fig --> core (name, law) pairs lack a proving law. Laws per name (from
  `proofs/gate/api_map.json`; the first nine are the core laws, which every name has):
<!-- fig:law_table -->
| Law | Names |
|---|---|
| `root` | 240 |
| `ok_eval` | 240 |
| `decode_accept` | 240 |
| `decode_spec` | 240 |
| `decode_unique` | 240 |
| `decode_reject` | 240 |
| `decode_none` | 240 |
| `encode_eval` | 240 |
| `encode_spec` | 240 |
| `roundtrip` | 73 |
| `encoded_size` | 73 |
| `reject_short` | 73 |
| `reject_long` | 73 |
| `decode_tree` | 118 |
| `decode_input` | 126 |
| `serialize_valid` | 74 |
<!-- /fig -->
- End-to-end bridges (`e2e/manifest.json`): <!-- fig:bridged_i -->240<!-- /fig --> names have the encode bridge (i),
  <!-- fig:bridged_iv -->240<!-- /fig --> the root bridge (iv), <!-- fig:bridged_dec -->232<!-- /fig --> the decode bridges
  (ii)/(iii); <!-- fig:bridged_full -->232<!-- /fig --> have all four. Without (ii)/(iii): <!-- fig:no_dec_bridge -->`vec_uint128_512`, `vec_uint128_513`, `vec_uint256_512`, `vec_uint256_513`, `vec_uint32_512`, `vec_uint32_513`, `vec_uint64_512`, `vec_uint64_513`<!-- /fig -->.
  The manifest's open lists: <!-- fig:manifest_open -->`uncovered` empty, `decode_uncovered` empty, `root_awaiting` empty<!-- /fig -->.
  The remaining premises and limits are in [PREMISES.md](PREMISES.md).

All figures in this section are generated from the artifacts by `codegen/doc_figures.py`, which
`codegen/regen_all.py --check` runs.

## Object-API laws (`proofs/api/<Name>_{encode_ssz,decode_ssz,hashtreeroot}_proof_generated.bend`)

Each facade restates, for the generated functions in `types/<Name>_*_generated.bend`, the laws
proved in `proofs/obj/`, and discharges each one by its proving law:

- **encode**: `encode_eval` gives the exact bytes `X_encode` writes for an object; `encode_spec`
  shows those bytes are `Decoding.decodes(Spec.X(), bytes, value)`, the spec's canonical
  encoding of the object's value; `encoded_size`, `serialize_valid` and `roundtrip` follow.
- **decode**: `decode_accept` / `decode_spec` / `decode_input`: an input that is a canonical
  encoding decodes to an object whose value is the encoded one; `decode_reject` / `decode_none`:
  every other input returns `None`; `decode_unique`: two accepted inputs with one value are equal;
  `reject_short` / `reject_long` for fixed-size names.
- **hash_tree_root**: `root`: the digest is the spec's root (`spec/root_relation.bend`) of the
  object's value.

## End-to-end bridges (`e2e/`)

For each covered name (`e2e/manifest.json`), in the terms of END_TO_END.bend's model API:

- (i) `<Name>_e2e_encode`: `Some(bytes of X_encode(o)) == API.serialize(Spec.X(), value(o))`;
- (ii)/(iii) `<Name>_e2e_decode_accept` / `_decode_view` / `_decode_reject`: the object decoder
  accepts exactly what `API.deserialize` accepts, with the same value, and rejects the rest;
- (iv) `<Name>_e2e_root`: the object's root is `API.hash_tree_root(Spec.X(), value(o))`.

Combined with END_TO_END's laws, each bridge says the object API meets the specification
directly. END_TO_END's statements are frozen; only their proofs were changed.

## Conformance (official vectors, through the generated object API)

`benchmarks/evidence/object_conformance.json`: every `mainnet/fulu/ssz_static` case of
consensus-specs v1.6.1 (295 cases, 59 types; decode, re-encode byte for byte, root against
`roots.yaml`). `benchmarks/evidence/generic_object_conformance.json`: every `ssz_generic` case
(5,145, valid and invalid, all 10 families; the 8 zero-length schemas are rejected by
construction). Both files carry a provenance stamp (commit, time, runtime toolchain hashes, and
the sha256 of the tested sources); `python3 benchmarks/checks/provenance.py` says whether the
stamped sources are the current tree's. Rebuild: `python3 benchmarks/quick.py --build all`,
`--build-generic all`, then the two scripts in `benchmarks/checks/` (on the ssz server, with
`BEND_RUNTIME` naming the pinned runtime compiler of `benchmarks/toolchain.json`).
