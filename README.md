# bend-ssz

Pure-Bend SSZ for the 109 pinned mainnet Fulu names and the 136 supported forms of the official
`ssz_generic` suite (144 schemas in the suite; the 8 zero-length vectors and bit vectors are not SSZ types and are
refused; 5 of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`, so the object API has
109 Fulu + 131 generic = 240 names). For every name there is a generated typed object API (decode, encode,
hash_tree_root, field and element access), and machine-checked proofs relating it to an independent
transcription of the SSZ specification (`spec/`). The guarantee a user relies on is: the
end-to-end bridges (`e2e/`, statements in `e2e/STATEMENTS.txt`) composed with the laws of
END_TO_END.bend, under the premises listed in [docs/PREMISES.md](docs/PREMISES.md), and for
objects read or changed through the API, the field, collection and setter laws, also listed in
`e2e/STATEMENTS.txt` (below, "Field, element and setter access"). For
<!-- fig:composed -->206<!-- /fig --> names, decode followed by encode (the input bytes back) and decode
followed by hash_tree_root (the spec root of the deserialized value) are single checked statements
(`e2e/<Name>_e2e_comp_generated.bend`, list in `e2e/COMPOSED.txt`). For the others it is not yet proved
that the decoded object satisfies the encode and root bridges' representation premises (PREMISES
section 1).

## What is proved

For every one of the <!-- fig:names -->240<!-- /fig --> names `X`, in the object API's own terms
(`proofs/api/X_<op>_proof_generated.bend`; these facades are stated over the generator's internal
object and view definitions, so they are building blocks, not the public statements; the public
statements are the bridges below):

| Operation | Laws for every name |
|---|---|
| encode | `encode_eval` (the bytes the encoder writes), `encode_spec` (they are the spec's encoding) |
| decode | `decode_accept` / `decode_spec` (a canonical encoding decodes to its value), `decode_reject` / `decode_none` (every other input is rejected), `decode_unique`, `ok_eval` (the validator) |
| hash_tree_root | `root` (the returned digest satisfies the spec's root relation for the object's value) |

`roundtrip`, `encoded_size`, `serialize_valid`, `reject_short` / `reject_long`, `decode_tree` and
`decode_input` exist for a subset of the names (the counts are in [docs/RESULTS.md](docs/RESULTS.md)).
`proofs/gate/MISSING.txt`: <!-- fig:missing -->0<!-- /fig --> of <!-- fig:core_pairs -->2160<!-- /fig --> core
(name, law) pairs lack a proving law.

These are then bridged to the list-based model of [END_TO_END.bend](END_TO_END.bend): the
`e2e/` files state, per name, that the object API's result is exactly `serialize`,
`deserialize` and `hash_tree_root` of END_TO_END's model at the object's value. END_TO_END's
laws (serialize_correct, deserialize_correct, deserialize_rejection_correct,
hash_tree_root_correct, ...) relate that model to the specification in `spec/`.
<!-- fig:bridged_full -->240<!-- /fig --> names have all four bridges (encode, decode accept, decode reject,
root); without the decode bridges: <!-- fig:no_dec_bridge -->none<!-- /fig -->.

### Field, element and setter access

The mutation API (`X_set_f`, `C_set`, `C_append`, `C_get`, ...) has its own laws. They are
public statements: they are listed in `e2e/STATEMENTS.txt` and locked in `frozen.lock.json`
like the bridges.

| Laws | Where | Statements | What they say |
|---|---|---|---|
| setter, spec value | `e2e/<Name>_e2e_set_generated.bend` | <!-- fig:set_view_count -->315<!-- /fig --> over <!-- fig:set_containers -->71<!-- /fig --> containers | for every object `o` and value `w`: `view(set_f(o, w)) == field_set(view(o), k, view_f(w))`, the spec value with field f (the k-th) replaced by `w`'s value and every other field unchanged (`proofs/obj/value_set.bend`) |
| setter, then root | same files | <!-- fig:set_root_count -->315<!-- /fig --> | the root of `set_f(o, w)` is `API.hash_tree_root` of that replaced spec value (under `rep`, through the setter-keeps-rep law, where the root bridge has that premise) |
| range-checked setter | same files | <!-- fig:set_checked_count -->11<!-- /fig --> setters | for the generic `uint8` / `uint16` fields, whose setter returns a flag: the flag is exactly the range check, a rejected value leaves the object unchanged, and an accepted one gives the spec value with the field replaced (then the root and encoding as above, given the new value's range invariant) |
| setter, then encode | same files | <!-- fig:set_encode_count -->114<!-- /fig --> | the same for the encoding, where the encode bridge has no premise but the object and `rep` |
| setter keeps rep | `proofs/obj/prep_setters{,_g1,_g2}.bend` | <!-- fig:obj_setter_laws -->211<!-- /fig --> over <!-- fig:obj_setter_containers -->36<!-- /fig --> containers (BeaconState included) | from `rep_X(o, s)` (and, for a field with its own invariant, that invariant of the new value) follows `rep_X(set_f(o, v), s)` |
| collections | `proofs/obj/coll_api_*.bend`, `proofs/obj/coll_seq.bend`, `proofs/obj/coll_bits.bend`, `proofs/obj/coll_bytes.bend` | <!-- fig:obj_coll_statements -->440<!-- /fig --> over <!-- fig:obj_coll_count -->41<!-- /fig --> collections | about the public `C_set` / `C_append` / `C_get`, with the guard the runtime computes from the object (it is the runtime's own test, read from the generated code; it is not compared with the spec's length limit): the flag returned is exactly that guard (index below the length the object reports; new length within the limit written in the generated type; a byte for byte elements); a rejected set or append returns the object unchanged; `C_get` outside the length is None; an accepted set keeps the length, an accepted append adds one; for the packed collections (Bytes32, Bytes48, uint64, bit lists, byte collections, the list of 2048-byte cells) a set value reads back at its index, every other index reads what it held, and an appended value reads back at the old length (with room in the storage or when the append reallocates it): read-back after set holds for <!-- fig:obj_coll_readback -->41<!-- /fig --> collections; for the lists stored as an array of elements, read-back, append and other-index laws (Data-element and boxed lists) are proved through `proofs/obj/tarray.bend` (`proofs/obj/coll_seq.bend`): they need the rigid checker (this branch, `agent/solid3-rigid`, is checked against it; `agent/solid3` has none of them). For <!-- fig:obj_coll_view -->33<!-- /fig --> of them the set is also stated against the spec value (`..._api_view_set`): the spec view of the collection after an accepted set is the view before with that one item replaced by the new element's view (`field_set`, `proofs/obj/value_set.bend`), for the lists and vectors of Bytes32, Bytes48 and uint64 (the views of the root bridges: `hview`, `pview`, `eview`, `uview`, `vview8`), for the twelve record lists (`xv_<list>`, the Data-element lists) and for the six byte collections (`BytesValue{wview}` with one byte replaced; `vview1` for the list of uint8); and an accepted append gives the view before with the new element's view at the end (`..._api_view_append`, with room in the storage: the Bytes32, Bytes48 and uint64 lists, the twelve record lists and the three byte lists; `..._api_view_append_grow`: the word lists when the append reallocates the storage) |

Not stated yet: setter-then-encode where the encode bridge also takes storage premises
(`hs*`, `hc*`; no law says a setter keeps them), the spec-value laws of the element setters for the bit lists, the cell list and the boxed lists, the
spec-value law of an append for the bit lists, for a byte list that reallocates the storage and for the boxed lists, and the relation of a collection's guards to the spec's length limit. Root and encoding of a list after an element setter follow from these laws and the existing
root and encode bridges only in the sense that the statement is about the very view those bridges use; no composed statement is listed.
The field swap laws of `proofs/obj/fields_*.bend` (<!-- fig:obj_swap_laws -->118<!-- /fig --> laws: the old value is handed back and the new one stored) are listed and locked; the other definitional field laws
and the helper-level collection laws (`proofs/obj/collections_*.bend`) are still checked but are no longer listed as statements (the setter spec-value laws and the collection laws state what they did).

Details: [docs/RESULTS.md](docs/RESULTS.md). Premises and known limits:
[docs/PREMISES.md](docs/PREMISES.md). What must be trusted: [docs/TRUST.md](docs/TRUST.md).

## Confirming what was checked

What a reader relies on is: the specification (`spec/`, mapped to `simple-serialize.md` in
`spec/CORRESPONDENCE.md`), the laws of END_TO_END.bend (the same text as
`memory_bench/law-statements.json`) and ROOT_DOMAIN.bend, the bridge statements
(`e2e/STATEMENTS.txt`) and the premises (`docs/PREMISES.md`). To confirm that exactly these were
checked, at the commit you rely on:

    python3 tools/verify_frozen.py          # spec/ and the roots' statements match frozen.lock.json
    python3 codegen/regen_all.py --check    # every generated file (bridges, STATEMENTS.txt, doc figures) is what the generators write
    python3 tools/verify_fixtures.py --tarballs   # the fixtures are the pinned consensus-spec-tests release files (fetches ~850 MB)
    git clone https://github.com/bendlang/bend T/bend-src && git -C T/bend-src checkout 3ddfb0366cc14622202aaa3808e695412241f23f
    # put Bun 1.4.2 (linux-x64) at T/bun-linux-x64/bun
    python3 tools/verify_pins.py --toolchain T   # checker, Bun and the vendored SHA-256 package match toolchain.lock.json
    BEND_TOOLCHAIN=T tools/check_fast.sh    # prints "all files check"

`check_fast.sh` repeats the two verifications itself and refuses to run on any mismatch. A change
to a frozen statement shows up as a change to `frozen.lock.json` (`git log -p frozen.lock.json`);
a change to a bridge statement as a change to `e2e/STATEMENTS.txt`. The trust base (checker,
SHA-256 package, compiler and host) is described in [docs/TRUST.md](docs/TRUST.md).

## Layout

`src/` runtime, `types/` the generated API per name, `spec/` the frozen specification,
`proofs/` the checked laws, `e2e/` the bridges to END_TO_END, `codegen/` the generators.
See [docs/LAYOUT.md](docs/LAYOUT.md).

## Regenerate and check

    python3 codegen/regen_all.py            # regenerate every generated file (idempotent)
    python3 codegen/regen_all.py --check    # fail if any generated file is stale
    tools/check_fast.sh                     # the full check: every .bend file, through umbrellas
                                            # (last recorded run: <!-- fig:check_wall -->11.8<!-- /fig --> min wall at 20 jobs);
                                            # on failure it bisects and prints the failing files
    tools/check.sh <file.bend>              # one file

See [docs/BUILD.md](docs/BUILD.md) for the checker and the resource limits.
