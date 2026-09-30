# Correspondence: simple-serialize.md to spec/

This file maps each section of the normative source to the Bend transcription that the laws are
stated against, and lists every place where the transcription reads the prose in a particular
way. It describes the current tree only. The development notes it replaced are kept in
`docs/history/CORRESPONDENCE-development-notes.md`.

## Sources and independence

- Normative sources (vendored, hash-locked in `frozen.lock.json`):
  `vendor/consensus-specs/ssz/simple-serialize.md` (consensus-specs v1.6.1),
  `vendor/consensus-specs/fulu_mainnet.py`, and `schemas/fulu_mainnet.json` (the 109 Fulu names).
- `spec/*.bend` imports only the neutral representations `types/{schema,primitive,byte_alias,list_alias}.bend`,
  its own files, and the FIPS 180-4 SHA-256 model of the pinned BendHub package
  (`toolchain.lock.json`). It imports nothing from `src/` or `proofs/`: the specification is
  independent of the implementation.
- What is proved about the specification's relations is in END_TO_END.bend and ROOT_DOMAIN.bend;
  what is proved about the object API is in the `e2e/` bridges, under the premises of
  `docs/PREMISES.md`.

## Section by section

| simple-serialize.md | spec/ | Notes |
|---|---|---|
| Typing: basic and composite types, aliases | `types/schema.bend` (representation), `byte_alias.bend`, `list_alias.bend`, `compatibility.identical` | `byte` = `uint8`; `ByteVector`/`ByteList` are the byte forms of `Vector`/`List` |
| Illegal types | `type_legality.type_legal` (with `schema_forest`) | every bullet: empty vector and bit vector, empty (progressive) container, more than 256 active fields, trailing 0, count mismatch, `None` only first and then at least 2 options, empty CompatibleUnion, selectors 1..127 and distinct, mutual compatibility |
| Compatible unions: compatibility | `compatibility` (`derives`, `compatible`, `shared_positions`) | finite derivation trees, no fuel |
| Serialization: `uintN`, `boolean` | `primitives` (`uint_domain`, `limb_digits`, `boolean_encoding`) | little-endian base-256 digits of 8×U32 limbs; high digits outside the width must be zero |
| Serialization: `Bitvector[N]`, `Bitlist[N]`, `ProgressiveBitlist` | `bitfields`, `bit_packing` | bit vectors: no delimiter, padding bits zero; bit lists: data bits then a set delimiter, always |
| Serialization: vectors, containers, progressive containers, lists, progressive lists | `codec.encoding_for_legal_type`, `layout` (`fixed_parts`, `offsets_fit`), `bytes`, `byte_list` | the fixed_parts/variable_parts algorithm; offsets are the running total from the fixed size; the `< 2^32` assertion exactly where the prose applies it |
| Serialization: Union, CompatibleUnion | `codec` (`tagged`, `with_option`) | selector byte then the value; the `None` case is the single byte `0x00` |
| Deserialization | `decoding_relation.decodes` / `outside_image` | decoding is the image of serialization: accepted exactly on canonical encodings, with the encoded value. `layout_decoding` is an independent forward slicer used by the proofs |
| Merkleization: `pack`, `pack_bits`, chunk counts | `packing`, `bit_root`, `byte_root`, `root_relation` (`count`, `basic_bytes`) | |
| Merkleization: `merkleize`, zero hashes, limits | `tree`, `merkle`, `limits.minimal` | the least power-of-two depth covering the limit; limit 0 gives one zero chunk |
| Merkleization: `merkleize_progressive` | `progressive` | subtrees of 1, 4, 16, ... chunks, the remainder on the left |
| Merkleization: `mix_in_length`, `mix_in_active_fields`, `mix_in_selector` | `mixing`, `root_relation` (`length_mixed`, `active_root`) | length as uint256 little-endian |
| `hash_tree_root` | `root_relation.root_for_legal_type` over `value_domain.root_domain` | the root of a structurally valid value (`root_valid`) whose mixed lengths are uint256; no whole-object encoding is required. ROOT_DOMAIN.bend proves this domain strictly broader than the serializable values and the roots of serializable values unchanged |
| Fulu types (`fulu_mainnet.py`) | `fulu_schemas.bend` | transcribed from `schemas/fulu_mainnet.json`; the JSON matches the Python for all 109 names (light-client branch lengths are `floorlog2` of their generalized indices) |

## Deliberate readings and strictness

- **Unions.** A Union with more than 128 options, or with no option at all, is illegal
  (`type_legality`: at most 127 options after the first). The prose says only that selectors above
  127 "should not" be used and that there is at least one option. No reference type is affected.
- **No `None` in a CompatibleUnion.** A CompatibleUnion option may not be `None`
  (`type_legality.legal`: the options are checked with `legal(options, True{})`, and a `T.Null{}`
  outside the first option of a plain `Union` is `Empty`). The prose (EIP-7495's
  `CompatibleUnion`) does not state this; it lists only non-empty option types, and no reference
  type or official vector uses `None` there.
- **Duplicate field names** in a container or progressive container are illegal
  (`type_legality.named_fields`, `distinct_names`). The prose has no such rule; a Python container
  cannot express duplicates.
- **`mix_in_selector`** serializes the selector into a 32-byte chunk (`mixing.selector_chunk`),
  as the reference implementation and the official vectors do; the prose's "uint8 serialization"
  is read with that chunk padding.
- **Progressive container roots** place each field's root at its active slot, with zero chunks at
  the inactive slots in between (`root_relation.placed` / `active_root`), then
  `merkleize_progressive` and `mix_in_active_fields`. The prose writes
  `merkleize_progressive([hash_tree_root(element) for element in value])`; the reference
  implementation and the official vectors place roots at active slots, which this follows. No
  Fulu type is progressive.
- **Decoding as the image of serialization** implies every item of the prose's hardening list
  (first offset, monotone offsets, bounds, no trailing bytes, delimiter and padding bits, selector
  range).

## Errata: stale comments in the frozen files

Three comments in frozen spec files predate the proofs and are out of date. The files are frozen
(`frozen.lock.json`), so they are corrected here, not edited; the comments are not part of any
definition, and no statement depends on them.

- `spec/codec.bend` (lines 10-12) calls public type legality and its composition "separate
  unfinished obligations" and the file "not yet the complete public SSZ specification".
  END_TO_END.bend proves serialization exact for every legal type and None for every illegal one
  (`serialize_correct` and the laws after it).
- `spec/decoding_relation.bend` (line 7) calls type legality and decoding completeness
  "separate". END_TO_END.bend's `deserialize_correct` and `deserialize_rejection_correct` prove
  deserialization sound and complete on the canonical image, and rejection exactly outside it.
- `spec/root_relation.bend` (lines 22-25) calls public domain/totality and rejection equivalence
  "separate proof obligations". END_TO_END.bend's `hash_tree_root_correct` and ROOT_DOMAIN.bend
  prove the root sound, complete and total on the root domain.

## The schemas, and how they are cross-checked

- **Fulu.** `spec/fulu_schemas.bend` is the 109 names of `schemas/fulu_mainnet.json`, which is
  the structural form of the classes of `vendor/consensus-specs/fulu_mainnet.py`.
  `tools/verify_schemas.py` checks both steps with its own readers (the Python module is read
  with `ast`, never executed; the Bend file is parsed into terms): every name has the same
  structure (field names and order, widths, lengths, limits, nesting) in all three. Limits of
  2^32 and above are written `Nat.mul(2^30, 1024n)`-style in Bend and compared as integers.
- **Generic classes.** The 131 generic names are the forms of the official `ssz_generic` suite
  that are SSZ types. Their schemas come from the suite's README (`test_formats/ssz_generic`,
  vendored), read by the frozen `tools/test_schemas.py` (type declarations only, no reference SSZ
  code), and are written to `proofs/obj/generic_specs.bend` by `codegen/root_laws_generic.py`, so
  that file is generator output, not an independent transcription; it is hash-frozen. What makes
  it trustworthy is the cross-check: `tools/verify_schemas.py` resolves every one of the 5,145
  ssz_generic cases of `cases.json` to its schema with `tools/test_schemas.py` (144 schemas), and
  requires the 136 that are SSZ types (all but the 8 zero-length vectors and bit vectors), minus
  the 5 basic types shared with Fulu, to be exactly the 131 schemas of `generic_specs.bend`
  (parsed independently; the classes' field names `A`, `B`, .. appear as `f_A`, `f_B`, ..), with
  no schema there that has no case. Every case also has its fixture files.
- Both checks run in `tools/check_fast.sh` before anything is checked, and in
  `codegen/check_schema.py --check` (so in `regen_all.py --check`).

## Outside the transcription

Default values and `is_zero`, summaries and expansions, the JSON mapping, and `merkle-proofs.md`
(generalized indices, single and multi proofs) are not transcribed and nothing is proved about
them.
