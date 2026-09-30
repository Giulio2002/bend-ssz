# bend-ssz

Pure-Bend SSZ for the 109 pinned mainnet Fulu names and the 136 supported forms of the official
`ssz_generic` suite (144 schemas in the suite; the 8 zero-length vectors and bit vectors are not SSZ types and are
refused; 5 of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`, so the object API has
109 Fulu + 131 generic = 240 names). For every name there is a generated typed object API (decode, encode,
hash_tree_root, field and element access), and machine-checked proofs relating it to an independent
transcription of the SSZ specification (`spec/`). The guarantee a user relies on is: the
end-to-end bridges (`e2e/`, statements in `e2e/STATEMENTS.txt`) composed with the laws of
END_TO_END.bend, under the premises listed in [docs/PREMISES.md](docs/PREMISES.md). For
<!-- fig:composed -->156<!-- /fig --> names, decode followed by encode (the input bytes back) and decode
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
    tools/check_fast.sh                     # the full check: every .bend file, through umbrellas (~3 min at 20 jobs);
                                            # on failure it bisects and prints the failing files
    tools/check.sh <file.bend>              # one file

See [docs/BUILD.md](docs/BUILD.md) for the checker and the resource limits.
