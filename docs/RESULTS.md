# Results

## Coverage

- 109 mainnet Fulu names (`codegen/fulu.yaml`, frozen in `schemas/fulu_mainnet.json`) and the
  `ssz_generic` forms: 136 supported schemas (15 official classes plus 121 structural forms such as `vec_uint16_4`,
  `bitlist_33`, `proglist_bool`) of the suite's 144; the other 8 (zero-length vectors and bit vectors) are not SSZ types
  and are refused. Five of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`
  (`uint16` and `uint128` exist only in the suite), so there are 131 generic names beside the 109 Fulu ones. Readable
  names come from `codegen/core/readable_type_names.py`.
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
| `encoded_size` | 75 |
| `reject_short` | 73 |
| `reject_long` | 73 |
| `decode_tree` | 118 |
| `decode_input` | 154 |
| `serialize_valid` | 235 |
| `decode_offsets` | 240 |
<!-- /fig -->
- End-to-end bridges (`e2e/manifest.json`): <!-- fig:bridged_i -->240<!-- /fig --> names have the encode bridge (i),
  <!-- fig:bridged_iv -->240<!-- /fig --> the root bridge (iv), <!-- fig:bridged_dec -->240<!-- /fig --> the decode bridges
  (ii)/(iii); <!-- fig:bridged_full -->240<!-- /fig --> have all four. Without (ii)/(iii): <!-- fig:no_dec_bridge -->none<!-- /fig -->.
  The manifest's open lists: <!-- fig:manifest_open -->`uncovered` empty, `decode_uncovered` empty, `root_awaiting` empty<!-- /fig -->.
  The remaining premises and limits are in [PREMISES.md](PREMISES.md).

All figures in this section are generated from the artifacts by `codegen/docs/documentation_figures.py`, which
`codegen/regenerate_all.py --check` runs.

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

## Object-mutation laws (field, element and setter access)

Public statements, listed in `e2e/STATEMENTS.txt` and locked in `frozen.lock.json`:

- setter laws, `e2e/<Name>_e2e_set_generated.bend` (`codegen/proofs/collections/setter_bridge_compositions.py`), for
  <!-- fig:set_containers -->71<!-- /fig --> containers (Fulu and generic, BeaconState included):
  <!-- fig:set_view_count -->315<!-- /fig --> spec-value laws `view(set_f(o, w)) == field_set(view(o), k, view_f(w))`
  (`proofs/obj/value_set.bend`), composed with the root bridge (<!-- fig:set_root_count -->315<!-- /fig -->
  statements) and the encode bridge (<!-- fig:set_encode_count -->208<!-- /fig --> statements) where the
  bridge's premises allow;
- setter-keeps-rep laws, `proofs/obj/prep_setters.bend` (`codegen/proofs/collections/setter_keeps_representation_laws.py`):
  <!-- fig:obj_setter_laws -->211<!-- /fig --> laws over <!-- fig:obj_setter_containers -->36<!-- /fig --> containers;
- collection laws of the public API, `proofs/obj/coll_api_*.bend`, `proofs/obj/coll_bits.bend`, `proofs/obj/coll_bytes.bend` (`codegen/proofs/collections/collection_api_laws.py`):
  <!-- fig:obj_coll_statements -->504<!-- /fig --> statements over <!-- fig:obj_coll_count -->41<!-- /fig -->
  collections: the flag is exactly the runtime's own guard (computed from the object, read from the generated code; it is not compared
  with the spec's length limit), rejection leaving the object unchanged, None outside the length, the length after an accepted set or
  append; read-back after set (and append, growth included) for <!-- fig:obj_coll_readback -->41<!-- /fig --> collections: the packed collections of whole-word
  elements (`proofs/obj/words_rw.bend`, `proofs/obj/coll_zeros.bend`, `coll_b32.bend`, `coll_b48.bend`, `coll_u64.bend`), the bit lists and byte collections (`proofs/obj/u32bits.bend`,
  `proofs/obj/coll_bits.bend`, `proofs/obj/coll_bytes.bend`) and the list of 2048-byte cells (`proofs/obj/cell_rw.bend`); the other-index law of the
  The spec-value set law of the 2 bit-list collections (`proofs/obj/bits_view.bend`, `codegen/proofs/collections/bit_list_set_view.py`: the word replace is a bit replace of the word-expanded storage, by the 32-way split on `i & 31`, then the view is `btk` of it) is in `coll_bits.bend`.
  Data-element lists. The array-list read-back and the boxed-list laws (`proofs/obj/tarray.bend`, `coll_seq.bend`) are in the gate like the rest, and for the five boxed lists the spec-value law `..._api_view_set` (`proofs/obj/tfz_boxed.bend`, `codegen/proofs/collections/boxed_list_set_view.py`: freezing the array `Array.set` writes is updating the frozen tree of mirrors, by one induction over the depth against `tarray.bend`'s `put`, then `view_seq.bend`'s induction over the items); the view of the new element is that of the stored box, `v_X_bx(th_X_bx(fz_X_bx(wrap v)))`, which the root bridges read of a stored element.
  The spec-value law, `..._api_view_set`, for <!-- fig:obj_coll_view -->41<!-- /fig --> collections: the spec view of the collection after an accepted
  set is the view before with that item replaced by the view of the new element (`proofs/obj/value_set.bend`'s `field_set`: the k-th item of
  a Sequence; `bytes_set` for a byte sequence). The view is the one the root bridges use (`hview`, `pview`, `eview`, `uview`, `vview8`, `xv_<list>`,
  `BytesValue{wview}`, `vview1`), so a reader can compose it with the root and encode bridges; `proofs/obj/view_b32.bend`, `view_b48.bend`, `view_u64.bend`,
  `view_seq.bend` (which also covers the boxed lists, over the frozen mirror trees of `root_types_light.bend`), `view_bytes.bend` and, for the list of 2048-byte cells, `view_cells.bend` (`codegen/proofs/collections/packed_list_set_view.py`, `codegen/proofs/collections/cell_list_set_view.py`: the same induction, with a cell's bytes the limbs of its 512-word window, `proofs/obj/words_list.bend`; it needs `hcap`, the blocks below the count inside the storage) prove it by one induction over the items and `proofs/obj/words_win.bend`'s word-level facts
  `proofs/obj/coll_root.bend` composes it with the collections' root laws (`ev_rs`, `el_rs`, `pv_rs`: the digest of an object is a specification root of its view under its representation invariant; for the list of Bytes32, `blist_obj.bend`'s `lh_core` on the written tree, with the size facts of the object and the room of its chunks from its `wfl` invariant; for the lists and vectors of uint64, `ul_rs` and `v8_rs` on the written object, whose `wfl` / `wf1` invariant is rebuilt: the zero tail of its last chunk is the old one, `proofs/obj/u64_tail.bend`): `..._api_root_set`, for <!-- fig:obj_coll_root -->32<!-- /fig --> collections, says the digest after an accepted set is a specification root of the view with that item replaced. The representation invariant is rebuilt for the written storage (the same tree shape, `words_win.bend`'s `tk_perfect`, the same length).
  The spec-value append law of the bit lists (`..._api_view_append` with room, `..._api_view_append_grow` when the storage is reallocated, `proofs/obj/bits_view.bend`: `view_snoc`, `view_snoc_grow`; the grow law derives that the new bit's word index is within the words copied, `kcov`, from the byte count of the new length and the schema limit, with no premise left on it) and of the boxed lists (`..._api_view_append`, `proofs/obj/tfz_boxed.bend`) is in `coll_bits.bend` and `coll_seq.bend`. An accepted append with room in the storage gives `seq_append`: the view before with the new element's view at the end (`..._api_view_append`; the word lists, the record lists and the byte lists), and `..._api_view_append_grow` when the append reallocates (the word lists: `proofs/obj/words_win.bend`'s `at_cpy_in` says the copy keeps the old words).
  (the byte collections: through the limbs of the written word, `proofs/obj/byte_bits.bend`, and the split of the index into word and offset, `proofs/obj/u32split.bend`).

The range-checked generic setters (<!-- fig:set_checked_count -->11<!-- /fig -->, `uint8` / `uint16` fields) have their
flag, rejection and accepted-value laws in the same files. Not stated: the spec-value
append law of a byte list whose append reallocates the storage; the root view of the record lists that have none; the
composed encode statement of a mutated list of the bit lists other than `bits131072` (they have no set law; `bits131072` is in `proofs/obj/encset_t_bits131072.bend`), and the root view of the runtime set of the uint16 lists (the runtime-level set object law, the composed encode with the premise `2 j = 4 q + s` derived, the read-back and the other-element laws over the runtime's `l1024_u16_set` and `l1024_u16_get` are in `proofs/obj/encset_r_<c>.bend`, `codegen/proofs/collections/uint16_list_runtime_set_laws.py`, over `halfword16.bend` (the sixteen-bit halfword read of a merged word) and `encset_r_base.bend`; the guard `U32.div(N, 2)` and the byte position `i * 2` are derived, the parity of `i` is the premise `(i * 2) & 3 = 0 or 2`; their tree-level composed encode is in `proofs/obj/encset_h_<c>.bend`, `codegen/proofs/collections/halfword_list_encode_after_set.py`, offsets 0 and 2, over `halfword.bend`; the element value is `v16of(v & 255, (v >> 8) & 255)`, it is `v` for `v <= 65535`: `proofs/obj/v16_rt.bend`, `codegen/proofs/collections/uint16_from_two_bytes.py`); see the design note below; the byte lists `bl32`, `bl256` and the list of uint8 are in `proofs/obj/encset_b_<c>.bend`, `codegen/proofs/collections/byte_list_encode_after_set.py`, with `tz_merge.bend`'s zero-tail lemma); and
setter-then-encode where a storage premise is not about one projection of the object or the setter is range-checked.
[PREMISES.md](PREMISES.md) section 9.

Design note, the composed root of a mutated list of records or of boxed containers. The 11 lists with a root view (`xv_<c>`: `l8192_DepositRequest`,
`l16_WithdrawalRequest`, `l2_ConsolidationRequest`, `l1048576_bl1073741824`, `l16_Withdrawal`, `l16_ProposerSlashing`, `l1_AttesterSlashing`, `l8_Attestation`,
`l16_Deposit`, `l16_SignedVoluntaryExit`, `l16_SignedBLSToExecutionChange`) already have the list-root law `rs_<c>` (`proofs/obj/root_types.bend`: the digest `xd_<c>` of an object
is a specification root of its view under `rep_<c>`, the element schema's `ok` and `eqs`) and the view-after-set law `..._api_view_set`. What is missing is the invariant
of the written list: `rep_<c>(set(o, i, v), s)` from `rep_<c>(o, s)`, which needs (a) an `ereps_set` lemma, generated per list from `view_seq.bend`'s
`<c>_xat_same` / `<c>_xat_other` (the element representations over the slots of the updated tree: the new element's, the old ones elsewhere; one induction on the count, deciding
`J == i0`), (b) the written array as the array of the updated tree (`amset_<c>` for the boxed lists; the record lists store the elements directly) and the new element's
representation as a premise (`rep_X(v, sE)`; for a boxed list `th_bx(fz_bx(wrap v))` is `wrap v` only given the element's own freeze/thaw law, which the container setters of
`proofs/obj/prep_setters.bend` already assume as `rv`), and (c) the composition of `rs_<c>` with the view law, as `coll_root.bend` does for the word families. The other six record lists (`Eth1Data`, `Validator`, `HistoricalSummary`, the three `Pending*` lists) have their view and list-root law in `root_state_light.bend` / `root_state.bend`
(module `STL` / `RSH`; their `rs_<c>` also takes `dv`, `edv`), and `coll_root.bend` composes them the same way (`seq_root_law`), so all 17 record and boxed lists have a root-after-set law.
The encode of a mutated list is stated in `proofs/obj/encset_<c>.bend` for these 17 lists (`codegen/proofs/collections/record_list_encode_after_set.py`): over the encode module's own mirror
types (`encx_<c>.bend`), `<c>_okl_set` says the written tree satisfies the encode bridge's premises `OKL` (for the boxed lists per element: `eoks_set`, from `xat_same` / `xat_other`,
the new element's `EOK` at the index and the old ones elsewhere; the depth of the perfect tree is unchanged, `tdm`), `<c>_vall_set` that the value of the written list is the old value with item i
replaced (`field_set`, by `xi_set` over the updated slots), `<c>_written` that the written object is the old array with the new element (its box) at i, and `<c>_api_encode_set` composes them
with `encx_specB`: the spec encode of the set value is the bytes `ENCL` of the written tree, under a bound on the byte count. The new element's `EOK` (boxed lists) and the byte-count bound are premises.

The lists of whole-word elements have the same composed statement in `proofs/obj/encset_w_<c>.bend` (`codegen/proofs/collections/word_list_encode_after_set.py`; the lists of uint64 `l131072_u64`, `l1099511627776_u64`,
of Bytes32 `l16777216_b32` and of Bytes48 `l4096_b48`; shared lemmas in `encset_w_base.bend`, `encset_w_base32.bend`, `encset_w_base48.bend`). Their encode bridge is over the window `MW{dw, T, N}`
with `OKT(dw, T, N)`: `<c>_okt_set` says the tree `WW.tk(words, dw, T, q, 0)` written at the element's words satisfies it (the perfect tree by `tk_perfect`, the room and the limit unchanged, the zero tail
of the word `N >> 2` untouched because the written words end before it: `wd_after` with `N = 4 M`, `ql_gen` / `ql_ge`), `<c>_vall_set` that the encode value `W.VALw` of the written tree is the old
value with item i replaced (the window reads `RWS` are the slots at aligned positions, `rwn_al`; the items over them are the view's `items2` / `items` / `eitems`, `rws_items`; then `view_u64.bend`'s `view_set_uitems`,
`view_b32.bend`'s and `view_b48.bend`'s `view_set`), `<c>_written` that the written mirror is the runtime's `words_write_u64` / `Bytes32_into_words` / `Bytes48_into_words`, and `<c>_api_encode_set`
the composition with `encx_spec`. No closed comparison on a limit is used: the room facts come from `N = 4 M` (`W.eqw`, `W.eLc`) by `qle`, and the premise of the set is `i < N / unit`.

Design note, the encode of a mutated list of sub-word elements (the byte lists `bl32`, `bl256`, `bl1073741824`, the list of uint8, the lists of uint16, the bit lists). Each has an encode bridge
(`encx_<c>.bend`, `vvlb_<c>.bend`, `vfx_*`: `OKT`, `VAL`, `encx_spec`), so the composed statement has the same three parts, but two of them need word-level facts the whole-word lists do not:
(a) the zero tail. For a byte, halfword or bit set inside the last word `N >> 2` the written word changes, so `OKT`'s `tail_zero(N & 3, slot(T', N >> 2))` needs a lemma that `O.merge_word(w, v, j, size)` /
`O.bit_merge` keeps the bits above the bytes in use zero when the position is below them (`shrn(merge(w, v, j), 8 r) == shrn(w, 8 r)` for `j < r`, `r` in 1..3; for the bit lists the `DL.HZ` tail
fact on `K`): a bit-level lemma on the 32-bit word (the bit-list machinery of `bits_view.bend`, `wmerge`, `zor` / `zan` over `BLf.wbits`, has the pieces) and a case split on `r` and `j`, as `u64_tail.bend` does for
the chunk tail; (b) the value. The encode value `W.VALw` reads bytes (`PB.it1` / `PB.it2` over the window `UW.WX`, `VS.bt` over the limbs) while the set laws state `PB.vview1` / `WO.wview` / `bytes_set` /
`BO.bview`: a bridge lemma per element width from the window to the view (the analogue of `rws_items`: the bytes of the window are the bytes of the slots, `UW.WX` against `UA.BYT` through `VS.bt`), then the
set laws (`VB.view_set_u8`, `view_bytes.bend`, `bits_view.bend`'s `view_set`) apply. The uint16 lists have an encode bridge but no collection set law yet (`coll_api_*` has none), so their composed
statement first needs the set and view laws. Everything else (the written mirror, `encx_spec`, the composition) is the same.

Status of that note: (a) is `tz_merge.bend` (`tz_merge`: for `b` in 1..2 and `s + b <= r <= 3`, `tail_zero(r, merge_word(old, x, s, b))` from `tail_zero(r, old)`, by `shrn` over `.&.` / `.|.`
and the closed masks, `codegen/proofs/collections/merged_word_zero_tail.py`, checks in 10 s); (b) is done for the byte lists `bl32`, `bl256` and the list of uint8 (`encset_b.bend`, with the `PB.it1` definitions of `pb_min.bend` and
`packed_bytes_light.bend` bridged) and, at tree level with the offset 0 or 2 as the two laws, for the three lists of uint16 (`encset_h.bend`, over `halfword.bend`: the bytes of a word after a halfword merge, by the
bit patterns of `byte_bits.bend`'s kind, 20 lemmas in 6 s; `it2_set2` replaces item `j` when the two bytes of element `j` are replaced). Every file checks in under 21 s. The bit list
`bits131072` (the only bit list with both a set law and an encode bridge) is done too, in `proofs/obj/encset_t_bits131072.bend` (`codegen/proofs/collections/bit_list_encode_after_set.py`, 12 s) over `proofs/obj/bitz.bend` (`bit_list_zero_tails.py`, 8 s). Its `OKT` has three tails on words of the bit storage: `tail_zero(nbytes(K) & 3, slot(T, nbytes(K) >> 2))`, `DL.HZ(RK(K), slot(T, K >> 5))` and
`bits_above_zero(K & 31, wd(T, dw, K >> 5))`. The proof states all three as `zlist(bdrB(r, wbits w))` (`HZ` already is; `bits_above_zero(r, w)` and `tail_zero(r, w)` for the literal `r` are equal to it, one closed
fact per `r`, by `wbits` of the mask and `zan`), preserve it under the merge by `bits_view.bend`'s `wset_i` (`wbits(bit_merge(v, x, shl_by(1, i & 31))) == lset(wbits x, i & 31, v)`) and one symbolic induction
(`zlist(bdrB(r, lset(L, k, v))) == zlist(bdrB(r, L))` for `k < r`), and take `k < r` from `n < K` and `n >> 5 == K >> 5` (`USP.split5`, `lt_cancel` of `encset_b_base.bend`) and, for the byte tail, from `n < K <= 8 nbytes(K)`
(`vbitenc.bend`'s `E3`). The value is `bits_view.bend`'s `view_set` over `CO.BITS(T, K) = btk(K, bitsof(slots T))`. The runtime-level collection set laws of the uint16 lists (read-back and other-element laws over `l1024_u16_set`,
needing `mul2` for the byte position `2 i`) are not built either: the tree-level laws take `2 j = 4 q + s` as a premise.

## Mutation testing (do the proofs notice wrong generated code?)

**The evidence is proof-side only.** `tests_generated/mutation_testing.py` mutates one site of a generated file
(`types/<Name>_{decode_ssz,encode_ssz,hashtreeroot}_generated.bend`) at a time and re-checks the one facade proof
`proofs/api/<Name>_<op>_proof_generated.bend` with the pinned checker, in a private tree holding only that proof's
import cone. A mutant is KILLED if the checker rejects it. A SURVIVOR is a gap (the locked statements do not pin
what the mutated definition does) or provably equivalent. Operators: a constant +1 or -1, a comparison flipped,
`+` turned into `-` (never `+ 0`), a validity result forced, and the two children of a hash_tree_root Merkle node
swapped. Draws are seeded; every record has file, line, column, before and after. 12 checks run at once (the
mutants are independent: each runs in its own copy of the cone), `nice -n 10`, never while a full check holds the
flock.

Why proofs only: the point is that every behavior the specification cares about is pinned by a locked statement.
A conformance or fuzz failure shows that a bug is visible to a test, not that a statement pins it. The fix for a
survivor is always a proof law that makes the mutant fail the checker, never a test. A survivor may be called
equivalent only with a proof-level reason (below). The conformance and fuzz harnesses are kept as an optional
triage (`--from-survivors`: does the survivor change any behavior at all?); they gate and classify nothing.

**A harness bug that made the first runtime counts worthless.** The first runtime stage reported "606 of 606
survivors killed". Every conformance kill was `ModuleNotFoundError: No module named 'snappy'`: the harness had
been started with a Python that lacks the module, so conformance crashed on every mutant, and a crash counts as a
failure. Only the fuzz kills were real (146 of 606). Rule: every runtime-stage result starts with its UNMUTATED
baseline passing (the harness now builds the unmutated programs and requires conformance and fuzz to pass before
any mutant; it refuses to run otherwise), a timeout is not a kill, and each kill keeps the tail of the failing
output. The proof-side numbers never used that Python and are unaffected. An earlier whole-tree run (997 mutants,
no hash_tree_root sites, shared rounds) is superseded for the same reason.

**Independent mutants.** A type's program imports the types it contains, so two mutants of one runtime round can
touch each other's result. The runtime stage builds rounds in which no mutant lies in the import cone of another's
type (12 rounds for 606 mutants); the proof batch needs no such care.

**Preconditions (each is a past failure).** (1) `python3 codegen/regenerate_all.py --check` must report every generator up to
date on the tree under test: round 2 once ran on a main whose facades were stale (no facade imported the new laws), which
inflated its survivors; the harness now refuses to start otherwise. (2) A runtime stage needs its unmutated baseline to
pass (see above). (3) The evidence file is stamped only from a run on the final tree.

**Rounds.** Replay = the earlier non-excluded survivors checked again on the new main (by file, def, operator, before,
after and line text); fresh = a new seed over every name and operation (up to 4 mutants each).

| round | main | draw | mutants | killed | survived | gaps after exclusions |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | pre-law | seed 20261002 | 2637 | 2031 (1899 mismatch, 122 stack overflow, 10 other) | 606 | 606 |
| 2 (stale facades, invalid) | cdae9e94 | replay 606 + seed 20261003 | 3438 | 2929 | 509 | not used |
| 3 | df8dbcf9 | replay 722 + seed 20261004 | 3494 | 3154 | 340 | 46 |
| 4 | 80cef74d | replay 565 + seed 20261005 | 3342 | 3270 | 72 | **9** (+41 open) |
| 5 (discarded: main moved) | 00cf555b | seed 20261006 | - | - | - | not used |
| 6 | 9e96b9d5 | replay 727 + seed 20261007 | 3504 | 3452 | 52 | 11 + 18 (all `_pwd` alignment guards, below) |
| 7 | 3ff8d509 | seed 20261008 | 2777 | 2736 | 41 | 9 (8 `is_le` guards, 1 accumulator flag) |
| 8 | 376669ac | replay 17 + seed 20261010 | 2794 | 2754 | 40 | **0** |

A stack overflow is a tooling accident, not a detection. The proving-law files (`proofs/obj`) also pass with every round-1
survivor applied: the facades only named the generated definitions, and no locked statement pinned them. Four rounds of
proof laws (validity, offsets and reported sizes, constants and root constants, capacity and comparison, collections)
closed the rest. The `out_at(d) -> out_at(d+1)` mutants were once excluded as harmless; the capacity laws kill them, so
they are drawn again.


**Round 4 in detail.** The 72 survivors: 41 aligned-or-slow (then open), 21 proof-equivalent and 10 gap records (one site
was found by both the replay and the fresh draw: 9 distinct gaps): reported sizes of three types, the offsets of the union
arms, one encoder field offset, and a proglist_bool case. Fixer C and fixer D closed them with proof laws (small2, cmp2, cmp3).

**Round 8, the first with no gap.** Replay of the 8 `is_lt` survivors of round 6 and the 9 survivors of round 7: 9 killed (the
`is_lt` guards now fail the checker: their facades import the `proofs/slop/alignment/*_writer_guard` laws; on the tree where they survived, the facades
imported no comparison law, which is why a replay on the tree of record is the rule), 8 survive, all `is_le`. Fresh round: 2777
mutants, 2745 killed, 32 survived: 29 proof-equivalent by the rules below and 3 more `is_le` guards. The `is_le` guards
(`is_eq(pos .&. 3, 0)` -> `is_le(pos .&. 3, 0)`) are **proof-equivalent**: for an unsigned U32, `x <= 0` holds exactly when
`x == 0`, and the law `le_eq` of `proofs/slop/alignment/writer_guard_library.bend` states it; the facade imports that library.

**Library targets (first pilot, seed 20261009, 10 files per group, 4 mutants per file, 120 s per check, none too slow).** The
loop also mutates the code the proofs rely on, not only the generated codec files (`--lib collections|e2e|sha256|spec`): each
mutant runs alone in a private tree; the checkers are the file itself and the two smallest proof files that import it; the
mutant is killed if any fails; a check over 120 s is reported as `too slow`, never as a kill. Pilot: collections 40 mutants, 40
killed; e2e 34, 33 killed; sha256 (vendored bend-collections 1.0.0.0) 36, 32 killed; spec 39, 36 killed. Survivors: e2e
`e2e_aapw.bend:64:129` (`eoF(d, t, 0 -> 1, ...)`: the argument is not in the result type; probably equivalent, to be confirmed);
sha256 `stream_correct` `&2 -> &1` twice (an erased label: equivalent) and `hex_digit`/`hex_word_go` in `packed/core_model.bend`
(the hex rendering of digests, not used by our laws, in a vendored package we cannot change: a gap of the package); **spec**:
`spec/byte_list.bend:11:100` (`Length.fits(4n -> 3n, ...)`), `spec/bytes.bend:6:54` (`size_fits`, `256n -> 255n`) and
`spec/bytes.bend:13:37` (`vector_domain`, `1n -> 2n` in the pattern `1n+p`): constants of the specification transcription that no
law catches. The spec is frozen: only copies in private trees were mutated.

**Audit of the exclusions** (`docs/mutation_testing/EXCLUSION_AUDIT.md`, `docs/mutation_testing/EXCLUSION_AUDIT_HIDDEN.json`; an independent re-derivation of every rule,
each checked by a Bend law or by a differential run of original against mutant). The first exclusion list hid 219 mutants. Verdict:

| rule | entries | verdict |
| --- | --- | --- |
| argument never read | 127 | sound for the site examined (45 Bend laws, one per callee, parameter and literal pair, all check); the key also hid 4 offset sites that are NOT equivalent |
| flag read only by `O.is_poisoned` | 30 | 29 sound, 1 unsound (`v4_b32_pk_ok`: in the LightClient types the flag is OR-ed into the running length that `ser_done` writes) |
| `words_ok` bounds / unit | 47 | sound for the site examined; the key also hid 35 sibling sites (`lo`, `unit`, `hi`) that change the accepted lengths |
| `bits_ok` limit | 1 | sound (Bend law) |
| vec_bool `ok_n` / `ok_nz` | 13 | sound; the key also covered 5 `case True{}` pattern sites that do not compile (invalid, harmless) |
| Transaction bound 2^30 -> 2^30+1 | 1 | NOT equivalent, killable by a proof law (no longer classified uncoverable) |

The defect was common to all rules: an entry was keyed by file, def, operator, before, after and line text, so it hid every site of
that line with the same literal while the rule had examined one column (42 of 219 entries matched more than one site). 41 real
mutants were hidden (4 offsets, 35 `words_ok` siblings, 1 flag, 1 bound) and 5 invalid ones. The key now includes the column (one
entry per site), the flag and bound entries are removed, and the rule "a flag is equivalent" requires that the consumers of the flag
across ALL facades were checked. The 41 are closed with proof laws (`agent/mutfix-hidden`).

**Final passes (budgeted; the loop stops here).** Corrected-key replay: 926 distinct survivors of all earlier rounds (one entry per
site, the column in the key): 676 now fail the checker, 250 survive, 248 of them proof-equivalent by the rules above and 2 (`is_lt`
of the `_pwd` alignment guard of `bitvector_16` and `bitvector_33`) survive only on a tree older than the final main: re-checked on the
final main they are killed (the `proofs/slop/alignment/` laws, formerly `zpwdcmp_*`). Library targets: **e2e** 822 mutants over 215 files, 783 killed, 30 survived (28 inside
the proof term of a lemma, statement unchanged; 2 statement survivors, `e2e_mw` p1028 `pw(10n)` -> `pw(11n)`, no caller needs the exact
bound, and `e2e_gvt` v2dD `shrn(8, 2n)` -> `shrn(9, 2n)`, the same value, both shown equivalent by fixer D), 9 too slow. **sha256**
(sample of 10 files): 36 mutants, 34 killed, 2 survived, both out of scope (a test-vector statement `stream_correct` and the hex
rendering `hex_digit`). **collections** (167 files): 616 mutants, 604 killed, 11 survived (all inside lemma proof terms), 1 too slow.
**spec, exhaustive** (every mutation site of the 32 spec files that has one: numeric constants +1 and -1, comparisons, `+`/`-`; checkers:
the file, its two smallest importers, up to 3 proof files that mention the mutated definition, and every module of
`proofs/slop/spec/` whose import cone contains the mutated file; at most 6 checks at once, nice 19, 120 s group kill).
First pass (main dc852a8f): 1049 mutants, 1018 killed, 31 survived (an earlier sampled pass of 232 mutants had found 8 of them). Fixer C
pinned the 31 in `proofs/slop/spec/` (generated by `codegen/proofs/slop/spec_constants*.py`). **Confirming pass
(tree of `agent/mut` 6cbcf4e7 plus the harness edit; `regenerate_all --check` clean; 690 s, budget 40 min): 1049 mutants, 1045 killed, 4
survived, 0 too slow, 0 not run. Critical: none.** The 4 survivors are the progressive-aggregate limit `0n` -> `1n` at
`root_relation.bend:143:52` and `:163:128` and `root_relation_serializable.bend:44:54` and `:64:181`; they are **proved equivalent**: the
laws `aggregate_progressive_ignores_limit`, `sequence_progressive_ignores_limit`, `roots_progressive_bits_any_limit` and
`roots_progressive_list_any_limit` of `proofs/slop/spec/root_relation.bend` and `root_relation_serializable.bend` state that
the roots of a progressive bits or list value are the same for every limit argument (the progressive branch ignores it), so changing the
constant cannot change what is proved.

| pass | mutants | killed | survived | critical |
| --- | --- | --- | --- | --- |
| codec scope, proof side, rounds 1-8 | about 24,000 (see the table above) | | 0 gaps at round 8 | 0 |
| codec replay, column key (926) | 926 | 676 | 250 (248 equivalent, 2 killed on the final main) | 0 |
| collections | 616 | 604 | 11 (proof terms) + 1 too slow | 0 |
| e2e | 822 | 783 | 30 (28 proof terms, 2 equivalent) + 9 too slow | 0 |
| sha256 (sample) | 36 | 34 | 2 (out of scope) | 0 |
| spec, exhaustive, first pass (main dc852a8f) | 1049 | 1018 | 31 | pinned afterwards |
| spec, exhaustive, confirming pass | 1049 | 1045 | 4 (all proved equivalent by laws) | **none** |

**Final limitations.** (1) 9 e2e mutants exceeded the 120 s budget and are unjudged: `e2e_bbsl.bend:395:50`, `e2e_dbb.bend:153:1175`,
`e2e_dbk.bend:72:3384` and `:64:210`, `e2e_dpx_tot.bend:60:3293`, `e2e_ml_l16_Deposit.bend:178:273`, `e2e_support.bend:18:87`,
`e2e_ulist.bend:76:24` and `:78:96`. (2) The exclusion rules were audited independently by sampling and by Bend laws
(docs/mutation_testing/EXCLUSION_AUDIT.md), not for every site. (3) Every equivalence relies on the pinned checker. (4) The hex rendering of the vendored
SHA-256 and its test-vector statements are out of scope. (5) For the library targets each mutant is checked by the file itself, the two
smallest direct importers and up to three files that mention the mutated definition: a survivor may be caught by a file outside that
sample. (6) The passes are samples (4 mutants per file for the libraries, 8 for the spec, 10 files for sha256), not exhaustive.

**Known out-of-scope item: the hex rendering of the vendored SHA-256.** `hex_digit` (`U32.is_lt(x, 10)`) and `hex_word_go`
(the shift `4n`) in `proofs/crypto/sha/packed/core_model.bend` of bend-collections 1.0.0.0 render a digest as a hex string. No
law of this repository reaches them (our laws use the byte API and the FIPS 180-4 model, never the hex strings), and the package
is pinned and vendored (`toolchain.lock.json`), so it is not changed here. Mutants in that rendering survive by design and are
listed as out of scope, not as gaps and not as equivalent; they would be reported to the package owner.

**Excluded** (`tests_generated/mutation_exclusions.json`; rules and reasons in `tests_generated/mutation_equivalence.py`): only
what has a proof-level reason, never "the tests pass": an argument the callee never reads (hl and seg of the hash_tree_root
leaf wrappers, the len argument of the fixed-size field readers, the proglist decode offsets), a flag read only by
`O.is_poisoned` (`(o, 0)` -> `(o, 1)`), `words_ok` / `bits_ok` changes that leave the accepted set unchanged, and the
vec_bool decoders (one caller passing the literal N). One bound is uncoverable (Transaction 2^30 -> 2^30+1 needs a 2^30+1-byte object). Nothing else is excluded.
The aligned-or-slow path test `pos .&. 3 == 0` was listed here as open (agreement only at sampled positions: the checker does
not fold symbolic index terms); it is now **closed by proof** (the cmp_all, cmp_unal and aligned_path_guard laws: every aligned
position, symbolic, and the unaligned path) and its three variants (`is_lt`, `is_le`, `is_ge` of the `is_eq`) are drawn
again as a regression guard, as is `out_at(d) -> out_at(d+1)` (killed by the capacity laws).

**Runtime of a round:** the fresh draw of about 2800 mutants takes 2750 s at 12 jobs on the ssz server; a replay of 565 mutants about 1000 s.
Result: `benchmarks/evidence/mutation_testing.json`.

## Conformance (official vectors, through the generated object API)

`benchmarks/evidence/object_conformance.json`: every `mainnet/fulu/ssz_static` case of
consensus-specs v1.6.1 (295 cases, 59 types; decode, re-encode byte for byte, root against
`roots.yaml`). `benchmarks/evidence/generic_object_conformance.json`: every `ssz_generic` case
(5,145, valid and invalid, all 10 families; the 8 zero-length schemas are rejected by
construction).

The fixtures these runs read are the pinned release files: `tools/verify_fixtures.py` checks every
committed fixture against `fixtures.manifest.json` (in every full check), and with `--tarballs`
fetches `general.tar.gz` and `mainnet.tar.gz`, requires their sha256 to be `upstream.lock.json`'s,
and requires the manifest to be exactly the archives' `ssz_generic` and `fulu/ssz_static` members,
each with the same sha256.

## Other test evidence (finite regressions, not laws)

All against the independent oracle `codegen/core/independent_ssz_oracle.py` (written from the specification, sharing
no code with the generated runtime) unless noted; last run <!-- fig:evidence_date -->2026-10-02<!-- /fig --> on the ssz server at
<!-- fig:evidence_commit -->496f797c<!-- /fig -->, all passing. The runtime is stock Bend 2.0.34; each file records the compiler, the sources,
the harness and the hash of every native program it ran (`benchmarks/checks/provenance.py`).

| File | Harness | What |
|---|---|---|
| `fuzz_objects.json` | `tests_generated/fuzz_objects.py` | <!-- fig:fuzz_types -->240<!-- /fig --> types (<!-- fig:fuzz_fulu -->109<!-- /fig --> Fulu, <!-- fig:fuzz_generic -->131<!-- /fig --> generic), seed 20260921: <!-- fig:fuzz_valid -->1,920<!-- /fig --> valid values (random, zero, maximal, empty, list-boundary), <!-- fig:fuzz_random -->15,360<!-- /fig --> random and <!-- fig:fuzz_boundary -->34,228<!-- /fig --> field-boundary corruptions (<!-- fig:fuzz_kinds -->16<!-- /fig --> kinds in all), <!-- fig:fuzz_history -->3,840<!-- /fig --> mutation-history steps through the object setters of <!-- fig:fuzz_setter_types -->64<!-- /fig --> types (the others are leaves and aliases without setters); <!-- fig:fuzz_mismatches -->0<!-- /fig --> mismatches; about <!-- fig:fuzz_elapsed -->3<!-- /fig --> minutes |
| `object_mutations.json` | `benchmarks/checks/object_mutations.py` | malformed variants of every ssz_static case (5,455 inputs); the verdict of each comes from the oracle; 0 disagreements |
| `object_mutation_tests.json` | `tests_generated/mutations.py` | 8 field/element updates through the object API against the oracle's re-encoding, rejections leave the value unchanged |
| `invalid_objects.json` | `tests_generated/invalid_objects.py` | 14 cases: representable but invalid objects (built with raw constructors) are refused by the checked encoder, each with a valid control |
| `negative_api.json` | `tests_generated/negative_api.py` | 7 programs: appending to vectors, use after move, duplication and a stale collection must not compile (for the stated reason), a positive control must |
| `object_cache.json` | `benchmarks/checks/object_cache.py` | cached validator-list roots under 7 modes and 100 seeded histories equal the uncached root and the oracle's |

`tests_generated/mutations.py` stays the eight hand-written update checks; the schema-driven corruption tests are the
field-boundary corruptions of `fuzz_objects.py` (`bounds` walks the schema and the value: every field start, offset slot,
offset target and collection element), counted separately above. The whole runtime evidence suite (`tools/run_evidence.sh`:
builds, eight harnesses, the Bun tests) takes about 6 minutes on the ssz server with warm program caches (the first build of
all programs adds about 15); `fuzz_objects.py` alone takes about 3 minutes. 45 of the 109 Fulu names have no setters in the generated API
(the basic types and aliases, `ProposerSlashing`, `AttesterSlashing`): `fuzz_objects.json` lists them, and their values get
valid, corrupted and boundary cases but no mutation histories; the 131 generic names have no fuzz programs, so they get the
same valid, corrupted and boundary cases only.

Every evidence file carries a provenance stamp: commit, time, runtime toolchain hashes, the
arguments, the sha256 of the tested sources (the whole `types/*.bend`, including the dispatch
modules `types/fulu_obj_*.bend` and `types/generic_obj_*.bend` the programs call, `src/*.bend`,
the drivers `benchmarks/objprog/*.bend` and `benchmarks/compact/*.bend`, and the vector set
`cases.json` + `fixtures.manifest.json`) and of the harness that produced it with the oracle and
schema readers it relies on. `python3 benchmarks/checks/provenance.py` says, for each file,
whether those hashes are the current tree's. Rebuild the programs with
`python3 benchmarks/quick.py --build all`, `--build-generic all`, `--build-fuzz all` and
`bend benchmarks/compact/<o>.bend -o build/compact-<o>`, then run the harnesses (on the ssz
server, with `BEND_RUNTIME` naming the pinned runtime compiler of `benchmarks/toolchain.json`).

Removed as stale on 2026-09-30: `spectests-js.json` (the JavaScript-runtime spectest run of
09-23; that runner no longer exists, and the native object-API conformance above covers the same
vectors). Moved to `docs/history/evidence/`: `native-comparison.json` and the driver artifacts
of the 09-21 memory comparison with Go (a macOS measurement of an earlier Bend, cited by
`docs/history/MEMORY_REVIEW.md`; performance, not correctness).
