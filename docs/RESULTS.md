# Results

## Coverage

- 109 mainnet Fulu names (`codegen/fulu.yaml`, frozen in `schemas/fulu_mainnet.json`) and the
  `ssz_generic` forms: 136 supported schemas (15 official classes plus 121 structural forms such as `vec_uint16_4`,
  `bitlist_33`, `proglist_bool`) of the suite's 144; the other 8 (zero-length vectors and bit vectors) are not SSZ types
  and are refused. Five of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`
  (`uint16` and `uint128` exist only in the suite), so there are 131 generic names beside the 109 Fulu ones. Readable
  names come from `codegen/names.py`.
- 240 names have object-API facades (`proofs/api/`: 720 files), each with an encode, a decode and a
  hash_tree_root file.
- 124 names have end-to-end bridges (`e2e/manifest.json`: 66 fixed-size, 58 variable-size); its `uncovered`,
  `decode_uncovered` and `root_awaiting` lists are empty. `proofs/gate/MISSING.txt`: 0 of 2205 core (name, law) pairs lack a proving law.
  The remaining premises and limits are in [PREMISES.md](PREMISES.md); 8 word-storage vectors (512/513 elements) await their decode bridge.

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
