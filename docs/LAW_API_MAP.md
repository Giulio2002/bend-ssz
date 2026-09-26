# Old-to-new law and API map (array-indexed migration)

Status, 2026-09-21 (iteration 17). **No `END_TO_END` or `ROOT_DOMAIN`
proposition has been changed.** `docs/LAW_MIGRATION.json` - the file the frozen
gate `automation/native_memory_acceptance.py` reads - therefore records every
original law as its own counterpart, with the equivalence argument being
identity. That is the honest state: the array/object migration happened in the
*runtime*, and the universal laws still speak about the list-based model API
that `src/model.bend` provides.

What that means concretely:

* the 29 `END_TO_END` and 13 `ROOT_DOMAIN` propositions are byte-for-byte the
  frozen ones and are checked (`benchmarks/evidence/check_*.log`);
* the production runtime is the generated typed owning object API
  (`types/fulu_obj.bend`, `types/generic_obj.bend`), which carries checked
  mutation/collection/cache/cost laws (`proofs/obj/*.bend`) and native evidence
  for all 5,440 official cases. Since 2026-09-22 it also carries **codec
  correctness laws on one stated class**: `proofs/obj/codec_*.bend` and
  `proofs/obj/gcodec_0.bend` hold, for every name whose encoding is a whole
  number of words at word-aligned positions (70 of the 109 Fulu names and 7 of
  the generic schemas), that decoding an encoding returns the object, that the
  encoding has the type's fixed size, and that a buffer one byte short or one
  byte long is rejected - stated over free word variables, so over every object
  of the type, and proved by computation against `T.<name>_encode` and
  `T.<name>_decode` themselves. The remaining names (sub-word leaves, variable
  size) have **no codec-correctness law yet**: those equations are not
  definitional and need the bit lemmas and the offset development;
* Since 2026-09-23 (Bend 2.0.25) the generated codec is also **connected to the
  independent specification** for 83 of the 109 Fulu names (88 since
  2026-09-26: the array-backed names and Validator, see below; and every fixed-size
  generic form)
  (`codegen/spec_laws.py` -> `proofs/obj/spec_fixed.bend`, `spec_bits.bend`,
  `spec_small.bend`, `spec_codec_{0..6}.bend`, `spec_unique_{0,1,small}.bend`):
  the bytes the encoder emits through `B.emit` satisfy
  `Decoding.decodes(Spec.<N>(), bytes, value)` of spec/decoding_relation.bend
  (encoder soundness against spec/codec.bend; for objects with packed storage
  every storage padding word is free); decoding a buffer of the size accepts and
  returns the object whose spec value is related to exactly that buffer's bytes;
  every other size is refused; and every spec value of those bytes equals the
  decoded value (via the frozen `deserialize_unique` and the name's legality
  witness). For `boolean` the rejection is characterized exactly: every byte
  above 1 is outside the spec image.
  **Buffers**: `proofs/obj/repr.bend` proves every perfect Array tree of depth d
  is the canonical tree of its words, so `spec_repr_*.bend` state the decode and
  view laws for EVERY perfect buffer array of the loader's depth (not a literal
  tree); `load.bend`/`spec_input_*.bend` state them for the buffer the real
  loader builds (`B.fill_at(B.alloc(n), 0, bytes)`, benchmarks/compact/objio.bend)
  from every byte list of the size. Arrays that are not perfect trees are not
  produced by Base's `Array.new`/`set`; they are outside this bridge.
  **Array-backed names** (2026-09-26, `codegen/spec_arr.py` ->
  `proofs/obj/spec_arr_{Blob,HistoricalBatch,SyncCommittee,BlobSidecar}.bend`,
  `spec_arr_unique_*.bend`, loop laws in `proofs/obj/arr_*.bend` from
  `codegen/arr_laws.py`): decode, view, spec parts, encoder soundness, rejection
  of every other size, uniqueness, and the encoder's bytes, for EVERY perfect
  buffer tree / storage tree (free trees, sizes symbolic: no closed size is
  compared or unfolded; BlobSidecar's blob sits at word 2, unaligned to the
  buffer's subtrees, and is handled by arr_shift/arr_enc). The loader law
  (`*_spec_input`) exists for all four; for BlobSidecar (its blob is not aligned
  to the buffer's subtrees) the input bytes are the words of the left half
  [x0, x1 | M1 .. M14] (every blob), the blob's last two words and the field
  words, and the loaded buffer is proved for every depth (`arr_enc.load_tail`). The BlobSidecar
  uniqueness law takes the bytes as a variable `by` with `eby: by == <bytes>`
  (a parameter typed with the 212 literal field words overflows the checker's
  stack); it is the same statement at `eby := {==}`.
  **Validator** (`spec_rec_Validator.bend`, `spec_rec_unique_Validator.bend`):
  the spec parts and encoding of the value of any words and boolean, a buffer
  whose byte 88 is above 1 is refused (whatever its other bytes), every size
  other than 121 is refused, a buffer of 121 bytes whose byte 88 is at most 1 is
  accepted and the spec relates exactly its bytes to the decoded object's value
  (`Validator_spec_decode`/`_view`/`_decoded`), the encoder emits exactly the
  spec bytes (`Validator_spec_bytes`; the encoder's `U32.mul(w, 256)` goes
  through `proofs/obj/word_mul.bend` `mul256`: `U32.mul(w, 256) == U32.shln(w,
  8n)` for every w), uniqueness.
  **Generic forms**: the aligned family covers 38 generic forms
  (`spec_gcodec/grepr/ginput/gunique_*`), Vector[uint32/64/128/256, 512] and
  Vector[uint32/64/128/256, 513] go through the array route (`spec_garr_*`:
  decode, view, loader, encoder bytes, parts, encoding, rejection, uniqueness).
  Uniqueness is proved with `proofs/decode_complete.bend` `image_unique` (which
  END_TO_END's frozen `deserialize_unique` is): on Bend 2.0.28 a module that
  imports END_TO_END together with `spec_fixed.bend` fails to resolve names.
  **Generic forms with sub-word leaves** (all 53: bool, uint8, uint16,
  Vector[bool/uint8/uint16, 1..513], BitVector[1..513] of partial words,
  Container(uint8), Container(uint16, uint16), Container(uint8, uint64, uint32), the
  progressive container of one uint8), `codegen/sub_laws.py` ->
  `proofs/obj/sub_pack.bend`, `sub_<N>.bend`, `sub_unique_<N>.bend`: decode, view,
  spec parts, encoding, the encoder's bytes, size rejection, uniqueness; for bool
  elements and bit vectors the decoder's validity check (every byte at most 1; the
  padding bits of the last byte clear) is the acceptance hypothesis and its failure
  is refused. The spec side is proved once for every length over byte lists
  (`sub_pack`: a byte of a word is below 256 by clearing its high bits one at a
  time; clear padding bits likewise; no case split over byte values); the 512/513-
  element vectors state it over every list of the length. The containers' joined
  words and the encoders' bytes are proved bit by bit (`codegen/bitsim.py`: per-bit
  lemmas of at most two variables).
* Since 2026-09-26 the spec connection covers **7 of the 21 variable-size names**
  (DataColumnsByRootIdentifier, IndexedAttestation, AttesterSlashing, Attestation,
  PendingAttestation, AggregateAndProof, SignedAggregateAndProof; the last four
  decode-side only, see "Bit lists")
  (see below and the AttesterSlashing paragraph after it) and 4 variable-size
  generic forms:
  the family "word-aligned fixed Data fields around ONE `List[uint64, N]`"
  (`codegen/var_laws.py`, `codegen/var_enc.py`): DataColumnsByRootIdentifier
  (`proofs/obj/var_codec_DataColumnsByRootIdentifier{,_unique,_rej,_enc}.bend`,
  stock) and IndexedAttestation (`proofs/obj/big_var_codec_IndexedAttestation*.bend`,
  `checkq --big`: its 2^17 list limit appears in the laws' types, which stock
  Bend overflows on). For every buffer `B.Buf{thaw(t), n}` on a perfect word
  tree of depth d < 29 with n <= 4 2^d: `ok_eval` (the validator returns
  `CHK(t, n)`, the Bool of the offset/length checks), `decode_accept` (CHK
  holds: the decoder returns `Some{OBJ(t, n)}`, an explicit object whose list
  storage is a copy of the buffer's words), `decode_spec` (then the buffer's
  bytes are the spec encoding of `VAL(t, n)`), `decode_unique` (every spec
  value of those bytes is `VAL(t, n)`), `decode_reject` (CHK fails: no spec
  value is related to the bytes) and `decode_none` (then the decoder returns
  None); for every object whose list storage is a perfect tree with room for
  its words: `encode_eval` (the encoder returns the object and an explicit
  output buffer) and `encode_spec` (whose bytes are the spec encoding of the
  object's value). The generic development (offsets, U32 division, aligned
  word copies, the spec layout of fixed parts around one variable part and its
  inversion) is `proofs/obj/v{spec,buf,u32,depth,copy,enc,enc2,fix,rej}.bend`.
  Not covered, and why: the 19 other variable-size names need, respectively,
  bit lists (Attestation, PendingAttestation: the runtime `O.ok_bitlist` /
  `O.bits_in` delimiter search), byte lists at unaligned lengths
  (ExecutionPayloadHeader: the masked last word of `O.copy_in`; it is also a
  grouped container), several variable fields and non-uint64 list elements
  (DataColumnSidecar: 3 lists of 48/2048-byte elements, a boxed field;
  ExecutionRequests: lists of records), and variable-size fields that are
  themselves variable-size containers (AttesterSlashing, AggregateAndProof,
  SignedAggregateAndProof, LightClient*, BeaconBlockBody, BeaconBlock,
  SignedBeaconBlock, ExecutionPayload, BeaconState): the decoder laws above are
  stated at buffer offset 0 and would have to be restated for a window at a
  symbolic offset to compose.
* **Nesting** (`codegen/var_nest.py`): `big_var_codec_IndexedAttestation_win.bend`
  restates the IndexedAttestation validator, reader and spec parts at a symbolic
  word-aligned window (off = 4 i, len) of a buffer; through them
  `big_var_codec_AttesterSlashing{,_unique,_rej}.bend` prove ok_eval,
  decode_accept, decode_spec, decode_unique, decode_reject and decode_none for
  AttesterSlashing (two IndexedAttestation fields), and
  `big_var_codec_AttesterSlashing_enc.bend` encode_eval/encode_spec through the
  windowed IndexedAttestation writer laws (`big_var_codec_IndexedAttestation_encw.bend`,
  `codegen/var_nest_enc.py`, stock lib `vnenc.bend`).
  Supporting stock libraries: `vnest.bend` (a word from its limbs, bytes at 4 k
  are word k), `vdig.bend` (the spec's four offset digits of a word's value are
  its limbs), `vfits.bend` (N.fits(4n, x) for x <= 2^a, a < 32, symbolically).
* **Bit lists** (`codegen/var_bits.py`, `var_bitc.py`, `var_win.py`; 2026-09-26):
  the runtime's delimiter search (`O.ok_bitlist`, `O.bits_in`) is related to the
  spec's delimiter encoding (spec/bitfields.bend) through byte facts proved by
  exhaustive case analysis over a byte's eight bits (`vbyte.bend`, generated)
  and the byte-string development `vbitl.bend` (the value bits `bl(bytes)` =
  every byte's bits, the last one cut before its highest set bit, pack with the
  delimiter back to the bytes; every delimiter encoding has that shape), with
  the runtime bridge `vbrt.bend` (the byte the validator reads is the spec's
  last byte; `copy_in` of any length). Laws (ok_eval, decode_accept,
  decode_none, decode_spec, decode_unique, decode_reject) for: the 18 generic
  BitList[N] forms (`var_bits_<X>{,_unique,_rej}.bend`, stock); PendingAttestation
  (`var_bitc_PendingAttestation*.bend`, stock) and Attestation
  (`big_var_bitc_Attestation*.bend`, big: its 131072-bit limit); and, through
  window laws (`var_win.py`: `big_var_win_bits131072.bend`,
  `big_var_win_Attestation.bend`, a uniform interface CHKw/ok_evalw/readw/
  specw/invw at a symbolic word-aligned window), AggregateAndProof and
  SignedAggregateAndProof (`big_var_win_<X>{,_top,_unique}.bend`). Buffers of
  depth d < 28. The value of a decoded bit list is stated from the buffer's
  bytes (`bl`); relating it to the decoded object's own bits (a view law) and
  the bit-list encoder laws are open.
* **Unaligned offsets** (`codegen/var_ua.py`, hand-written `vua.bend`,
  `vua_copy.bend`; 2026-09-26, stock). Generic in the offset and length, for
  a buffer of depth d < 31. U1: `B.read32` at ANY byte offset X returns
  `RW(t, X)` (`vua.rd_any`), whose limbs are the spec bytes [X, X + 4)
  (`vua.rd_bytes`); the word joins `B.join_sel(j, lo, hi)` have limbs
  j..3 of lo then 0..j - 1 of hi (`vua_bits.join1/2/3`, generated). U2:
  the shifted copies `O.scopy1/2/3` build the model `vua_copy.smone`
  (`vua_sc.scopy{1,2,3}_ok`, generated; U32.mul by 2^k is `word_mul`'s
  shift). The last source read may be one past the array, where Base Array
  masks the index to 0 (`vua_copy.get_wrap`). `copy_in` / `copy_into` of any
  length L at an offset with off & 3 = s (s = 1, 2, 3) returns
  `MK(L, dz, smone(s, NW(L), off >> 2, ...))` (`vua_sc.copy_in_ua{s}`,
  `copy_into_ua{s}`; the aligned case is `vbytes.copy_in_any`), and its first
  L bytes are the buffer's spec bytes [off, off + L) (`vua_copy.ci_bytes`).
  U3: a uint64 at any offset X is two four-byte reads
  (`vua_rd.rd64_any`, O.U64{RW(t, X), RW(t, X + 4)}) whose limbs are the
  spec bytes [X, X + 8) (`vua_rd.rd64_bytes`); bytes and bools are
  `vbrt.byte_at_ok` at any offset.
  U4 (copies): `vua_ct.copy_in_at` — copy_in of any length at ANY offset
  returns the storage `CT(d, t, off, L, dz)` (the aligned or the shifted copy
  by off & 3), whose first L bytes are the spec bytes [off, off + L)
  (`vua_ct.ct_bytes`).
  U4 (windows): the byte-offset window interface (`vua_win.bend`'s header:
  CHKw/ok_evalw/OBJw/readw/VALw/specw/invw at byte position x, window bytes
  `WX(t, x, L)`), with fixed-size readers at any offset (`vua_fix.rdx_<p>`,
  words `UR.RWN(t, x + 4 k)`); modules `var_winx_bits2048`,
  `var_winx_PendingAttestation` (stock), `big_var_winx_bits131072`,
  `big_var_winx_Attestation` (big), and List[uint64, N] children
  (`var_winx_l128_u64`, `var_winx_DataColumnsByRootIdentifier` stock;
  `big_var_winx_l131072_u64`, `big_var_winx_IndexedAttestation` big), from
  `codegen/var_win.py` (WINX); two variable fields of one child:
  `big_var_winx_AttesterSlashing` (offsets 8 and O1, both windows
  checked, inverted from the spec's two-part layout).
  Lists of variable-size elements (`codegen/var_winl.py`):
  `big_var_winx_l1_AttesterSlashing`, `big_var_winx_l8_Attestation`, proved
  per element count m (the runtime's offset walk unrolls; CK_m / OBJ_m /
  VAL_m), the inversion recovering m from the value; `vua_rd.rd_lt` covers
  the first read of a window shorter than 4 bytes, `vua_win.vsingle` the
  one-part shape of a variable container's spec parts.
  Containers with several variable fields (`codegen/var_winb.py`,
  BeaconBlockBody; tested on ExecutionRequests and
  DataColumnsByRootIdentifier): the validator's flat offset chain, the reader
  (by groups of eight fields), the spec parts laid out by `vua_lay.hdr_fp`,
  and the inversion reading the value's parts back part by part
  (`vua_lay`: lay_off, lay_pay, lay_end, fpos_w, fs_w, for any part list).
  `big_var_winx_BeaconBlockBody` (240 s), `big_var_winx_BeaconBlock` and
  `big_var_winx_SignedBeaconBlock` (about 250 s each; checkq --big), and
  their whole-buffer decoder laws `big_var_codec_<Name>` (ok_eval,
  decode_accept/spec/unique/reject/none from the window at x = 0).
  BeaconState's children: `big_var_winx_l1099511627776_u64` and
  `big_var_winx_l1099511627776_u8` (List[uint64/uint8, 2^40]: the count is
  bounded by the length's, `big_vu40` compares the 2^40 limit as a capacity),
  `vu8` (a byte string's uint8 items), and `codegen/var_winv.py`
  (List[Validator, 2^40], 121-byte records at any phase: `big_var_winx_l1099511627776_Validator`, 51 s).
* **Byte lists at any length, and the names nesting them** (2026-09-26,
  agent/codec-var-bytes; `codegen/var_bytes.py` with `var_bytes_enc.py`,
  `var_bytes_nest.py`, `var_bytes_nenc.py`): ExecutionPayloadHeader (a grouped
  container of word-aligned fixed fields, two packed-word byte vectors and one
  `ByteList[32]`), LightClientHeader (a boxed ExecutionPayloadHeader after its
  header) and LightClientOptimisticUpdate (a LightClientHeader, a boxed
  SyncAggregate) have the full law set (ok_eval, decode_accept, decode_spec,
  decode_unique, decode_reject, decode_none, encode_eval, encode_spec) in
  `proofs/obj/var_bytes_<Name>{,_unique,_rej,_enc}.bend`, all stock-checkable,
  over the same quantifiers as above (buffers on perfect trees of depth d < 29
  with n <= 4 2^d; objects whose storage trees are perfect with room for their
  words, the byte list's last storage word having no bytes past its length, the
  runtime's storage check). The masked last word of `O.copy_in` / `O.put_words`
  is proved once, symbolically in the length (`proofs/obj/vbytes.bend`
  `copy_in_any`, `mk_bytes`: the masked storage has the copied words' first L
  bytes, by clearing high bytes bit by bit; `vbenc.bend` `put_words_any`,
  `words_ok_b`); the value of the decoded byte list is the first L bytes of its
  storage (`vbspec.bend` `ybytes`). Every name's laws are first stated at a
  word-aligned window (off = 4 i, len) of a buffer (`_win`: ok_evalw, readw,
  specw; `_rej`: inv_p, rej_facts; `_enc`: putw at pos = 4 P over any tree,
  frame_lo, partsw) and the whole-buffer laws are the window laws at i = 0; a
  container nesting a covered name uses the child's window laws at the window
  after its header. Not covered, and why: LightClientBootstrap and
  LightClientUpdate hold a SyncCommittee (6156 words, array-backed: its value's
  parts are those of spec_arr_SyncCommittee, which the header layout here does
  not yet take as a symbolic word segment); LightClientUpdate and
  LightClientFinalityUpdate hold a second LightClientHeader whose offset is
  4k + (extra_data length), in general not word-aligned, so its reads and
  copies go through the runtime's shifted paths (`B.read32` split reads,
  `O.scopy1..3`), which have no laws yet; ExecutionPayload likewise (its
  transactions and withdrawals start after extra_data).
* **Several variable fields: DataColumnSidecar** (`codegen/var_multi.py` with
  `var_multi_enc.py`; 2026-09-26). Three lists of byte vectors (2048/48/48-byte
  elements, `O.Words` storage) between a uint64 and a boxed SignedBeaconBlockHeader
  and a `Vector[Bytes32, 4]`. For a buffer on a perfect word tree of depth d < 23
  with n <= 4 2^d: `ok_eval`, `decode_spec`
  (`var_codec_DataColumnSidecar.bend`, stock), `decode_accept`
  (`var_codec_DataColumnSidecar_acc.bend`, stock; the only importer of
  `vzeros.bend`, the zero trees up to depth 23), `decode_unique` (`_unique`),
  `decode_reject`, `decode_none` (`_rej`); for every object whose three list
  storages are perfect trees with room for their c0/c1/c2 elements (c <= 4096):
  `encode_eval`, `encode_spec` (`big_var_codec_DataColumnSidecar_enc.bend`, big:
  the output's size bounds, up to 8.8 MB, are closed facts). Libraries:
  `vmul.bend` (spec parts of a list of byte vectors), `vmv.bend` (the layout of
  one fixed part, three variable parts and fixed parts; list windows),
  `vmr.bend` (rejection: lists of byte vectors are whole elements; the inverse
  layout of three variable parts), `vme.bend` (storage checks of such lists;
  windows of a tree after a list copy).
* **Lists of fixed records, ExecutionRequests** (`codegen/var_rlist.py` with
  `var_rlist_er.py`; 2026-09-26, stock). Byte-offset window modules (the
  `vua_win.bend` interface: CHKw, ok_evalw, OBJw, readw, VALw, specw, invw, plus
  `linvr`: the spec bytes of any value of the list are whole records) for
  `l8192_DepositRequest`, `l16_WithdrawalRequest`, `l2_ConsolidationRequest`,
  `l16_SignedVoluntaryExit`, `l16_SignedBLSToExecutionChange`
  (`var_winx_<p>.bend`): the reader's record array is the tree of the records
  read at x + R j (`vua_fix.rdx_<record>`), the value's items the records' values
  over the same words. `var_winx_ExecutionRequests.bend` composes the three list
  windows at byte position x; `var_codec_ExecutionRequests.bend` gives the
  whole-buffer ok_eval, decode_accept, decode_spec, decode_unique, decode_reject
  and decode_none (the window at x = 0; d < 28). Libraries `vrl.bend` (Array.set
  of any element type on a perfect tree; positions of consecutive records),
  `vrc.bend` (window splits, the offset layout of three variable parts).
  Also (same interface): BeaconState's `l2048_Eth1Data` (stock) and, as `big_`
  files (the schema's limit is closed; the record storage depth is bounded from the
  window, not the limit), `l16777216_HistoricalSummary`, `l134217728_PendingDeposit`,
  `l134217728_PendingPartialWithdrawal`, `l262144_PendingConsolidation`. Boxed
  records (`codegen/var_rlist_box.py`): `l16_ProposerSlashing`, `l16_Deposit`, over
  `vua_fixb.bend` (readers at any byte position of records with boxed fields and
  packed vectors; Deposit.proof by copy_into, `CTN`: vua_ct's copy at a Nat position);
  the storage is the runtime array with the records set in turn, and Deposit's RX/RT/LOBJ
  take d. Packed lists of byte vectors (`codegen/var_rlist_bv.py`): `l4096_b48`
  (stock; the copy's depth bounded from the limit by right shifts only) and
  `big_var_winx_l16777216_b32` (depth from the window, zero arrays by `big_vvlz`).
  BeaconState's fixed fields at any byte position (`codegen/var_fixx.py`, all stock):
  `vfx_<p>.bend` for u64, b32, Fork, Checkpoint, BeaconBlockHeader, Eth1Data,
  SyncCommittee, v8192_b32, v65536_b32, v8192_u64, v64_u64 export OBJ(d, t, x),
  rdx (T.<p>_read at off = x), VAL(t, x) and prt(d, t, x, pf, hb, s, es) (the value's
  parts are the window slice UW.WX(t, x, S)); `vfx_bv4.bend` adds CHK, ok (bv4_ok_at)
  and inv. `vfxg.bend` proves them for every size: vectors are copied (vua_fixb.CTN),
  their values are arr_vec chunkings over UR.RWS(CNT(x, M), t, x) (CNT keeps the word
  count neutral, so no statement unfolds 2^16 elements), schemas are variables s with
  es: s == Spec.SchemaNN(), and positions are written x + C (a literal first argument of
  Nat.add unfolds in unary).
  Encoder (`codegen/var_rlist_enc.py`): `var_rlenc_ExecutionRequests.bend`
  (stock) has per list the write loop's model (WT/LW: the records' words at
  Q + W j), the putv run lemma (pvl), and the spec side (RWA: the records'
  words; lpart: the list's parts; LWlo/LWhi/LWown: windows of the output after
  the list write); `big_var_codec_ExecutionRequests_enc.bend` (checkq --big;
  closed 2^24-byte size bounds) has encode_eval and encode_spec for counts
  within the limits (hl_k) and record arrays on perfect trees (da_k < 31).
  after its header. LightClientBootstrap (a LightClientHeader, a SyncCommittee
  whose 6144 packed words are one symbolic segment of the header, `vsc.bend`
  `sc_parts`, and the branch) has ok_eval, decode_accept, decode_spec and
  decode_unique in `big_var_bytes_LightClientBootstrap{,_win,_unique}.bend`
  (checkq --big: its 24820-byte header makes stock Bend compare unary Nats past
  its stack; the size facts go through `vbsize.bend` with the size symbolic).
  Byte-offset windows (the `vua_win.bend` interface: CHKw, ok_evalw, OBJw,
  readw, VALw, specw with bytes `UW.WX(t, x, len)`, invw) for
  ExecutionPayloadHeader and LightClientHeader are in
  `var_bytesx_<Name>{,_inv}.bend` (`codegen/var_bytes_x.py`, stock; fixed fields
  via the rdx readers at `UR.RWN` words, byte vectors via `vbx.bend`
  `copy_into_at`, the byte list via `vua_ct.copy_in_at`; the child's window at
  FS + x). Bootstrap's decode_reject and decode_none are in
  `big_var_bytes_LightClientBootstrap_rej.bend` (checkq --big, 277 s / 3.9 GB):
  the big-name branches of `var_bytes_nest.rej_text` keep the literal header size
  away from stuck lengths (sizes summed symbolically then closed by
  `Nat.is_eq`, `vbsize.LN` for lengths beside the literal, `sfix` for a fixed
  field's size, `wv_g`/`haw_g` stated for a symbolic size). Not covered yet:
  Bootstrap's encoder laws.
  LightClientFinalityUpdate (two leading LightClientHeaders, the second at the
  runtime offset o1 + x) has ok_eval, decode_accept, decode_spec,
  decode_unique, decode_reject and decode_none in
  `var_bytesx_LightClientFinalityUpdate_dec.bend` over buffers of depth d < 28,
  from its byte-offset window `var_bytesx_LightClientFinalityUpdate{,_inv}.bend`
  (`codegen/var_bytes_x2.py`; the layout of two variable parts and windows split
  in two in `vbx2.bend`; stock, the _dec module peaks at 11.5 GB). Not covered
  yet: its encoder laws; LightClientUpdate (its two headers are separated by a
  SyncCommittee: the two-part layout with fixed parts between them and the
  big-header treatment of Bootstrap).
* **Lists of variable-size elements, and ExecutionPayload** (2026-09-26,
  agent/codec-var-bytes). `codegen/var_vlist.py`: the generic byte-offset window
  of a list of variable-size elements over any element window module (symbolic
  element count; the runtime's offsets-table loop by induction), instantiated for
  transactions, `big_vvl_l1048576_bl1073741824.bend` (checkq --big: CHKw,
  ok_evalw, OBJw, readw, VALw, specw, invw), with the ByteList[N] element windows
  `big_vvlb_bl1073741824`, `big_vvlb_bl32` and the libraries `vvl.bend` (the
  layout of n variable parts; the inversion YP/ALL/REP/LST, rep_h, inv_enc; stock),
  `vvlr.bend` (stock), `big_vvlu.bend`, `big_vvlz.bend`.
  `codegen/var_winx_c.py`: containers with several variable fields among fixed
  ones, each a child window module: `var_winx_ExecutionPayload.bend` (extra_data,
  transactions, withdrawals; keeps the var_winx_ name BeaconBlockBody imports,
  but imports big children: checkq --big, 62 s / 5.4 GB), over `vwc.bend`
  (fp_fix/fp_var, bv_*, fs_*, fp_len, bdr_skip, lsingle; stock). Its standard
  interface is keyed on T.ExecutionPayload_ok / T.ExecutionPayload_read.
* **Progressive lists** (`codegen/var_plist.py`): the generic forms
  ProgressiveList[uint32/uint64/uint128/uint256] (Gt3A9420DD8E, GtE83F21B20A,
  Gt1C2FA69562, GtA8457965E2) have the full set (ok_eval, decode_accept,
  decode_spec, decode_unique, decode_reject, decode_none, encode_eval,
  encode_spec) in `big_var_plist_<X>*.bend`, for buffer and storage depth < 28
  (n <= 2^29 bytes: the vcopy overflow lemmas need k < 31). They are big files
  because the unbounded list's storage depth (up to 2^27 words) makes the
  runtime's `B.zeros` cascade compare closed Array trees, which only the
  identity check of bendlang/bend#1075 does cheaply
  (`big_var_plist_zeros.bend`). Stock: `vlist.bend`, `var_elems.bend`.
* Root equality (updated 2026-09-24, Linux host; see WORK_LOG "Iteration 23"):
  laws exist for 108 of the 109 Fulu names, for the ACTUAL public root
  `T.<Name>_hash_tree_root(h, o)`, against the independent relational
  specification spec/root_relation.bend `roots` and the pinned package's SHA
  law, with no symbolic SHA normalization. Each law is
  `RR.roots(v_X(o), s, [D.bytes(root of T.X_hash_tree_root(h, o))])` for every
  hasher h and every object o with the representation invariant `rep_X(o, s)`,
  where `s == Spec.X()`. Checked: `root_names.bend` (75 Data-kind names, phase A;
  Mac check), `leaf_small.bend` (uint8, ParticipationFlags, uint32, Bytes1; Mac
  check), `root_types.bend` (25 Type-kind names incl. IndexedAttestation and
  AttesterSlashing (depth 15, through the variable-depth record OS.DV), the 4
  bit-list names (bitlist_obj), Blob, BlobSidecar and DataColumnSidecar (cells.bend);
  Linux PASS 1047 s, 4.08 GB VmHWM). Pending check: `root_big.bend` (Transaction,
  ExecutionPayload, BeaconBlockBody, BeaconBlock, SignedBeaconBlock: closed limit
  facts up to 2^30 that the checker evaluates once in unary; hours).
  BeaconState (2026-09-26, agent/root-packed): its law
  `BeaconState_root_correct` is in the BIG file big_root_BeaconState.bend
  (`checkq --big` PASS 686 s, 6.5 GB); all its shape laws are stock-checkable, in
  root_state.bend (stock PASS 400 s, 6.2 GB; importing root_types, which is
  unchanged). The closed facts with limits 2^24, 2^27 and 2^40
  (historical_roots, historical_summaries, pending_deposits,
  pending_partial_withdrawals, validators, balances, inactivity_scores, the two
  participation lists) are proved for a symbolic depth and instantiated in the
  goal's form (big_lim_st.bend, --big PASS 194 s); the other closed facts are
  evaluated. New field kinds: packed lists of uint8/uint16/Bytes32 for any limit
  and depth (blist_obj.bend, codegen/blist_laws.py, stock PASS 297 s), packed
  vectors of basic elements as fields, lists of Data containers of depth >= 14
  through OS.DV (validators: depth 40), and a one-word partial bit vector Data
  field (justification_bits).
  Generic forms (codegen/root_laws_generic.py --status, 2026-09-25): laws for
  123 of the 136 supported forms: 70 packed vectors of bool/uint8/16/32/64/128/256
  (packed_obj.bend, packed_bytes.bend: Linux PASS 624 s); 18 byte-storage forms;
  16 bit vectors of a length not a multiple of 32; 7 progressive lists
  (prog_root.bend PASS 573 s + prog_list.bend); 6 phase A containers
  (root_gnames.bend PASS 931 s); 3 uint leaves (gleaf.bend PASS); 3 phase B
  containers (root_gtypes.bend PASS 1298 s). The bit vectors are in
  gbits_small.bend (the 14 one-chunk vectors) and gbits_Gt05340E1F7E.bend
  (Bitvector[511]: PASS 602 s) / gbits_Gt0B0C03B454.bend (Bitvector[513]).
  The former single gbits.bend was stopped by the operator after 5 h. The cause
  was proof engineering, not the statements: a goal held the runtime root at the
  concrete hash length 64n while the object's words were exposed, so the
  checker reduced SHA-256 over them. The laws are unchanged. The proofs now keep
  the object opaque at 64n and do the rest for a symbolic hash length (see
  WORK_LOG 2026-09-25).
  2026-09-26 (agent/root-generic): 5 more forms, checked on stock Bend via
  checkq: GpF350A3C486 (progressive container; root_gnames.bend PASS 418 s),
  Gp4B0CA2906A, Gc85FA758A04, Gc60805EC295 and GuA2212AE21F (compatible union)
  in the new root_gtypes2.bend (PASS 557 s, 7.1 GB). Support: pcont.bend
  (generated; progressive-container trees `pc_<active>_ar`, union selector mix
  `msel_<k>`), pbits_obj.bend (progressive bit lists, PASS 295 s),
  wbits_obj.bend (bit vectors in byte storage, PASS 239 s), and partial-word
  bit vector records (Bitvector[1/2/8/257]) as phase A shapes with the
  representation fact rp_<p> (last word = its low bits, then zeros).
  No law for 8 forms: 2 unions whose option Gp66304057C3 has a List[uint16, 123]
  field, 1 container with progressive lists of uint8/uint64/containers and of
  progressive lists of a container with a List[uint16, 1024] field
  (Gc221EC01D83), 4 forms with uint16-list fields, and 1 bit list of tree
  depth 56. 2026-09-26 (agent/root-packed): Gc465214E502 (List[uint16, 1024]
  field; root_gtypes.bend stock PASS 529 s) and, with it, Gp66304057C3 and the
  unions GuAD91DEB870, Gu6DDF182530 (root_gtypes2.bend) now have laws; the
  Gc56D855869F (vectors of Data and Type-kind containers, codegen root_laws_b
  vecify; elements with a uint8 field carry their rp facts, ereps; root_gtypes
  PASS 522 s, root_gtypes2 PASS 555 s) too. The
  "bit list of depth 56" (GtF7582E0E9A) is a progressive bit list (Spec
  S.ProgressiveBits{}), not a depth-56 tree.
  2026-09-26 (agent/root-generic, second pass): ALL 136 supported generic forms
  now have a root law. GtF7582E0E9A (progressive bit list, pbits_obj),
  Gc221EC01D83 and Gp8A7851175B (22-slot progressive container) in
  root_gtypes2.bend (stock PASS 498 s, 7.6 GB). New: progressive-container
  trees of any slot count (pcont.bend PASS 236 s: the runtime tree is
  prog_root `pr` over the slot digests, merkleized by `pmerk`, pr_spec over a
  symbolic digest list); progressive-list fields of basic elements (`pk`,
  prog_list), of Data containers (`px`) and of boxed Type-kind elements (`ptl`:
  containers, progressive containers, and progressive lists of them through a
  Data mirror of the list, `mirror_seq`); plist_obj.bend (PASS 257 s).
  The representation invariants `rep_X` are hypotheses of the Type-kind root
  laws. Producers establishing them (2026-09-25):
  - Checked: every field setter of the 27 Type-kind containers with a
    `rep_<X>` keeps it (proofs/obj/prep_setters.bend, codegen/rep_laws.py,
    127 laws, Linux PASS 988 s). From rep_X(o, s) and the new field value's
    own invariant, rep_X(X_set_f(o, v), s) holds, with every other component
    unchanged.
  - Generated, being checked: for the 6 list types with a root law
    (cspec_<list>.bend), `default_rep`, `uncache_rep` (from the cache
    invariant), `set_rep`, `append_rep` (when the runtime guard accepts) and
    `read_rep`/`read_empty_rep` (the list decoder).
  - Not yet: the whole-container decoders (`X_read` of the 27 containers and
    of the list types not listed above) and container `default()`. So on the
    public API, `rep` is discharged for list values built by
    default/read/set/append/uncache and for setter chains starting from a
    value that has it. It is not yet discharged for a container decoded from
    bytes.
  The cached root (updated 2026-09-25, Linux checks):
  - Checked: the heap model proofs/obj/ctree.bend, which covers the node
    rule, the clean-node invariant as Data products (a function-typed
    invariant is linear in Bend 2.0.25), the sweep as level loops, and
    root = reference tree.
  - Checked: the locality lemmas proofs/obj/cloc.bend. A change at one leaf,
    `dput`, keeps every node that is clean for a range covering the leaf.
  - Checked: the runtime connection for BeaconState.validators
    (`l1099511627776_Validator`). proofs/obj/cloop.bend covers the U32 node
    step and level loop; cloop2.bend covers the leaf loop, element roots
    `d_Validator` and the shifted level ranges; cloop3.bend covers
    `csweep`, the padding to depth 40 and
    **`cached_root_correct`**. For a cache whose items and nodes are thawed
    perfect trees satisfying the invariant, `cached_root(64, h, c, seg)`
    returns `mix_len(64, rtree(40, 0 < n, 64, XL, 0), n)`, where XL is the
    element roots. It also returns a cache with an empty range in which every
    node holds its value (Linux PASS: cloop3 808 s, 3.11 GB VmHWM).
  - Checked (Linux): preservation by `cset` (cset.bend, `xl_set`; PASS 779 s)
    and by `capp` inside the capacity (cmut.bend, `xl_app`; PASS 778 s), the
    fresh-cache invariant (`fresh_cinv`), and `B.words_depth` (wdepth.bend
    PASS 562 s, wdstage.bend PASS 556 s: the minimal depth, stated without
    closed powers of two). cloop3.bend re-checked after the runtime now returns
    the empty range `[n, 0]` from `cached_root` (PASS 728 s).
  - Checked (Linux): the cost of the sweep (ccost.bend, PASS 528 s).
    `sweep_cost` says levels l+1 .. l+k rehash at most
    (rng(l, hi) - rng(l, lo)) + 3k nodes. The step counts are the ones that
    `clevels` proves the runtime runs. The whole sweep is (hi - lo) + 3d, and
    after one write it is at most 3d (O(log n), against 2^d - 1 for a full
    rehash).
  - Checked (Linux): the public API as an invariant-preserving interface
    (capi.bend, PASS 713 s: `root_eq`, `cset_eq`/`cset_inv`, `capp_eq`/
    `capp_inv` under the runtime's append guard `guard(n)`, `cache_eq`/
    `cache_inv` for `cache(o)`); the capacity-growing `capp` (cgrow.bend,
    PASS 749 s: `grow_eq`/`grow_inv`, the copy loop into a doubled array); and
    the history law (chist.bend, PASS 729 s: `hist_inv`). By `hist_inv`, every
    sequence of `cset`/`capp` calls whose preconditions hold keeps the cache
    valid. So, by `root_eq`, the root after any such history is the reference
    root of its elements.
  - Generated for the 11 other `_Cached` lists with Data-kind elements
    (codegen/cached_laws.py -> cached_<list>.bend: all eight parts, with each
    list's guard literal and limit depth). cached_l16_Withdrawal: Linux PASS
    737 s; the other 10 are being checked.
  - Spec link (cspec_<list>.bend, `cached_spec`) for the 6 lists that also
    have an uncached root law. The digest the cached root returns satisfies
    RR.roots for the list's value. cspec_l16_Withdrawal, which also holds the
    list producer laws: Linux PASS 1017 s; the other 5 are being checked.
    The lists are DepositRequest, WithdrawalRequest, ConsolidationRequest,
    Withdrawal, SignedVoluntaryExit and SignedBLSToExecutionChange.
  - Not yet: the 5 `_Cached` lists with Type-kind elements (bit lists,
    ProposerSlashing, AttesterSlashing, Attestation, Deposit), and the spec
    link for BeaconState's lists (validators and the 5 BeaconState-only
    lists). Their uncached law is not generated, because BeaconState's
    `l16777216_b32` field kind is unsupported and its 2^40 limit facts are
    closed. So for those lists cached = spec root is proved only up to the
    reference tree of the element roots.
* The public encoder is `<Name>_serialize -> O.Encoded{ok, bytes}`: it refuses
  representable-but-invalid objects (scalars out of range, bits or bytes set
  past a length, lengths over limits or not whole elements, storage too small
  for a length, empty boxes) instead of masking or merging them. For the 74
  Data names the law `serialize = valid ? encoded(encode) : refused` is checked
  (proofs/obj/serialize_*.bend). For the linear names the check is fused into
  the writers (codegen/generate.py `emit_putk`) and is covered by native
  regressions (tests_generated/invalid_objects.py) and the spectests, not yet by
  a law equating the fused flag with `<p>_valid`.
* `src/model.bend` is kept precisely because the frozen propositions are about
  it. Deleting it would delete checked coverage, which the operator instruction
  forbids until equivalent generated laws exist.

The rest of this document is the design of record for the translation that is
still to be carried out. Rows marked `planned` are still planned. Nothing below
is presented as done.

## 0. What the pinned runtime actually offers (measured, not assumed)

The migration target is constrained by facts about pinned Bend 2.0.16 that were
measured on this machine, not inferred. Evidence: `benchmarks/probes/` (sources
and numbers) and the emitted C at `build/native/bend-ssz.c`.

1. The native runtime has contiguous block storage. The emitted C defines
   `TAG_BUF` and `TAG_ARR` terms and the block layer around them
   (`build/native/bend-ssz.c:185-190`, `:3526-3620`). Its own comment states:
   *"A block owns one allocation in its physical class (an ARR of class c 2^c
   Terms in 2^c words, a BUF 2^c u32 in 2^buf_wcls(c) words) ... get, set, swap,
   size and new open no half."* So `Array<T>` is a contiguous block with O(1)
   indexed access, and `Array<U32>` is a packed u32 buffer - not a pointer-chasing
   tree, despite the `ALeaf/ANode` surface syntax.
2. Indexed access is fast enough for the contract: 2,740,473 indexed reads of an
   `Array<U32>` take under 1 ms (`benchmarks/probes/list_to_array.bend`,
   `SCAN_MS=0`), against a 1.75 ms budget (5x Go's 0.35 ms BeaconState decode).
   The current chunk-list decoder needs 24-27 ms for the same fixture.
3. **`Array<T>` has kind `Type`, not `Data`, so it cannot be duplicated.**
   `def twice(+a: Array<U32>)` is rejected with `expected: Data, observed: Type`
   (`benchmarks/probes/array_share.bend`). An array-backed decoder therefore
   cannot hand a shared view of the input to two sub-decoders; it must thread the
   buffer linearly and address it by index, returning the buffer with every
   result.
4. Base's file API yields a linked list: `File.read_bytes`/`File.read_at` return
   `List<&2, U32>` (`/Users/monkeair/.bend/bend2/base.bend:267-276`). There is no
   buffer-returning read. Converting a 2.74 MB byte list into an `Array<U32>`
   costs 5 ms (`FILL_MS=5`), which is already 14x Go's entire decode. This is why
   buffer-ready decode, input conversion and end-to-end ingestion must be
   reported as three separate numbers; the conversion cost is a property of the
   pinned Base, not of the SSZ code.
5. Allocation of decoded nodes is cheap: 200,000 two-field records build in 1 ms
   (`benchmarks/probes/record_alloc.bend`), about 5 ns per record.

Consequence for the architecture: the array migration is worth doing and is
where the remaining speed is, but it is a **different decoder** - linear buffer
threading plus index arithmetic - and therefore a different proof development
from the slice-based one now in `src/`. It cannot be a drop-in substitution of
one storage type inside the existing proofs.

## 1. Design that keeps every END_TO_END proposition byte-for-byte

The frozen propositions in `END_TO_END.bend` speak about `+List<U32>` input
bytes and `T.Value`. The migration keeps them **unchanged** by making the
list-level entry points *definitions on top of the array path* rather than
independent implementations:

```
store_of_list : +List<U32> -> Store                 (array fill, runtime)
deserialize_store : T.Schema -> Store -> Store & Maybe<CValue>   (primary)
deserialize (schema, xs) := forget(deserialize_store(schema, store_of_list(xs)))
```

Because the list entry point is *defined through* the array path, a law stated
about the list entry point is a law about the array path composed with the
bridge; it is not an adapter proved separately from the runtime. Two bridge
theorems carry the weight and are named in every row below:

* `store_denotation` - `store_bytes(store_of_list(xs)) == xs` for every byte list
  in domain (`bytes_domain(xs) == True{}`): filling an array from a list and
  reading it back by index yields the same byte sequence.
* `store_index` - `byte_at(s, i)` equals `IP.at(store_bytes(s), i)` for `i` below
  the size: the indexed read agrees with the denotation the specs quantify over.

Every law whose statement mentions only `T.Value`, `T.Schema` and byte lists
therefore **stays byte-for-byte**. Only laws that mention a *representation*
(`P.Slice`, `C.CValue`, `Packed.Packing`) need a migrated signature, and those
are internal lemmas, not END_TO_END propositions.

## 2. END_TO_END laws (29) - all stay byte-for-byte

| law | old proposition | new proposition | bridge | why not weaker |
|---|---|---|---|---|
| `decide_invalid` | over `T.Schema`, `Bool` | unchanged | none needed | statement never mentions storage |
| `illegal_invalid` | over `T.Schema` | unchanged | none needed | same |
| `serialize_illegal` | `API.serialize` on `T.Value` | unchanged | `encode_bridge` | `serialize` becomes `bytes_of_store(encode_store(...))`; same domain, same `None` cases |
| `serialize_correct` | `API.serialize` exactness | unchanged | `encode_bridge` | conclusion is the same equation on the same list |
| `accepted_spec` | `API.deserialize` sound | unchanged | `store_denotation`, `store_index` | premise and conclusion identical; only the proof route changes |
| `spec_accepted` | `API.deserialize` complete | unchanged | same | same |
| `deserialize_correct` | both directions | unchanged | same | same |
| `deserialize_unique` | injectivity | unchanged | same | same |
| `reject_decide` | rejection on illegal type | unchanged | same | same; body must be re-derived from the new entry point |
| `deserialize_rejection_correct` | both directions | unchanged | same | same |
| `root_accepted` | `API.hash_tree_root` sound | unchanged | `root_bridge` | root consumes compact values; conclusion is the same relation on the same 32 bytes |
| `hash_tree_root_correct` | sound + complete + total | unchanged | `root_bridge` | same three conjuncts, same domain |
| `named_valid`, `preserved`, `named_accepted_result`, `named_decoded`, `decoded_shape`, `named_rejected_result`, `named_root_accepted`, `named_outside`, `fulu_types_correct` | per-name Fulu composition over `T.Value` | unchanged | the same three bridges | the named layer is definitional over the generic layer; migrating storage under it changes no proposition |
| `legal_boolean_exists`, `boolean_image_exists`, `boolean_image_decoded`, `boolean_rejects_two`, `boolean_root_domain`, `empty_container_absurd`, `illegal_empty_container`, `checkpoint_named_legal` | closed witnesses | unchanged | none needed | closed terms; they only need the entry points to keep their types |

`memory_bench/law-statements.json` is the frozen byte-for-byte snapshot and must
keep matching after the migration; `automation/native_memory_acceptance.py`
checks exactly that, and no row above changes a character of any proposition.

## 3. ROOT_DOMAIN laws (13) - all stay byte-for-byte

`none_unless`, `domain_rejected`, `illegal_rejected`, `relation_unique`,
`generic_contract`, `named_contract`, `full_root_correct`, `with_previous_at`,
`with_previous`, `previous_at`, `previous_preserved`,
`serializable_root_compatibility`, `root_domain_strictly_broader`.

All of these are stated over `T.Schema`, `T.Value`, the relational root
semantics and 32-byte outputs. None mentions a storage representation. Twelve
are byte-for-byte as merged; the only work is re-deriving bodies that go
through the decoder, using `root_bridge`.

**`root_domain_strictly_broader` changed, as a strengthening.** As merged
from the root-domain worker (`ROOT_DOMAIN.bend` lines 222-225 there) it fixed
the witness depth at 3:

```
law root_domain_strictly_broader:
  for +r: Nat
  (@+xs: ... -> Broader.broader_facts(Witness.nest_schema(3n, r), Witness.nest_value(3n, r, xs))) &
  Exists(T.Schema, schema => Exists(T.Value, value => Broader.broader_facts(schema, value)))
```

It now quantifies over every depth `d` with premise `Nat.is_le(3n, d) == True`.
Instantiating `d := 3` discharges the premise by computation (`{==}`) and
gives the old statement exactly, so the generalised law is a strengthening.
That instantiation is not added as a separate checked law, for a measured
reason: a corollary `root_domain_strictly_broader_depth3(r) =
root_domain_strictly_broader(3n, r, {==})` made the checker normalize the
witness at the literal depth - the blow-up the generalisation was introduced to
avoid - and `ROOT_DOMAIN.bend` went from 5.03 GB to over the 6.8 GB cap in
two attempts (benchmarks/evidence/check_ROOT_DOMAIN.log records the passing
check without it). The frozen gate `automation/root_domain_acceptance.py`
requires the law by name, which the generalised law satisfies.

## 4. Public API surface

| old API | new API | status | bridge theorem | non-weakening argument |
|---|---|---|---|---|
| `ssz.deserialize(schema, +List<U32>) -> Maybe<T.Value>` | `ssz.deserialize_store(schema, Store) -> Store & Maybe<CValue>` primary; list form kept as a definition on top | planned | `store_denotation`, `store_index`, `value_denotation` | the list form is *defined* as fill + primary + forget, so its law is a law about the primary path; the accepted set is unchanged because the bridge is an isomorphism on byte lists in domain |
| `ssz.serialize(schema, T.Value) -> Maybe<+List<U32>>` | `ssz.encode(schema, CValue) -> Maybe<Store>` primary; list form defined as `bytes_of_store . encode` | planned | `encode_bridge`, `value_denotation` | same encoding function, same rejection set; the list form's proposition is unchanged |
| `ssz.hash_tree_root(schema, T.Value) -> Maybe<+List<U32>>` | `ssz.root(schema, CValue) -> Maybe<Digest>` primary, streaming; list form defined on top | planned | `root_bridge` | same relation, same 32-byte conclusion, same domain predicate |
| `ssz.valid`, `ssz.type_valid` | unchanged | done | none | schema-level only |
| schema constructors (`boolean_type` ... `compatible_union_type`, `chain`, `end`) | unchanged | done | none | schemas are Data and small; they are not a storage representation |
| value constructors (`boolean_value` ... `null_value`) | compact constructors on `CValue` plus the existing `T.Value` ones for the spec/oracle layer | planned | `value_denotation` | the compact constructors cover the same value space; `T.Value` stays as the specification's view only |
| `types/fulu.bend` `Name.{schema,to_ssz,from_ssz,valid,serialize,deserialize,hash_tree_root}` for all 109 names | same names, compact types (`Store`/`CValue`) | planned | per-name composition over the three generic bridges | the named layer is definitional; its laws quantify over the same closed name index |

## 5. Internal lemma surfaces that do change signature (not END_TO_END)

| old | new | why the change is forced | non-weakening |
|---|---|---|---|
| `P.Slice{chunks: +List<Chunk>, start, size}` | `Store` = linear `Array<U32>` + size, cursors are `Nat` indices | `Array` cannot be duplicated (probe 3), so a slice cannot carry its own storage | denotation `store_bytes` has the same type as `P.slice_bytes`, so every downstream law keeps its shape |
| `PK.byte_at_view`, `sub_view`, `adv_view`, `wf_*` | `store_index`, `store_take`, `store_drop`, `store_size` | same content over indices | each new lemma has the same conclusion with `store_bytes` in place of `slice_bytes` |
| `C.CValue` with `CCons/CEnd` child spine | `CValue` with array-backed children | the operator requires no linked spine in decoded sequences | `C.to_value` stays as the spec view; the child-order laws are restated over indexed access with the same order |
| `Pack.Packing`, `pack_list`, `pack_spec` | `store_of_list` + `store_denotation` | packing becomes a fill, not a chunk build | the packing round-trip law becomes the denotation law, same equation |

## 6. What has to be true before any row above can be marked done

1. `store_index` and `store_denotation` must be *proved*, not assumed. Both are
   statements about `Array.get`, whose Base definition descends `ANode` with
   `U32.shr`/`U32.and`/`U32.sub` index arithmetic; proving them needs the
   bit-level word lemmas that `proofs/word_*.bend` already provide for the
   existing limb code. This is the first real obstacle of the migration and it
   has not been started.

   **Measured, 2026-09-22.** The obstacle is now demonstrated rather than
   predicted, and it is larger than "needs the word lemmas":

   * the kernel does no symbolic algebra on native `U32`. `((x & 255) & 255) ==
     (x & 255)` does not check: `expected U32.and(U32.and(x, 255), 255)`,
     `observed U32.and(x, 255)`. The `proofs/word_*` and `proofs/compact/bits`
     lemmas are about the *specification's* bit-list `U32`, which is a
     different type from the runtime's native word, so they do not transfer;
   * there is no read-after-write law for `Array`. `Array.get(Array.set(a, i,
     v), i)` does not reduce on a symbolic `a`, because `Array.size` is stuck.
     Every statement of the form `store_index` needs exactly that lemma.

   Neither can be added as an axiom (the objective forbids it), and neither is
   derivable in the pinned kernel without induction over a symbolic tree. Until
   one of them is available, a universal law about array-backed storage can
   only be discharged where both sides reduce by computation - which is the
   aligned fixed class that `proofs/obj/codec_*.bend` covers (70 of 109 names,
   7 of 144 generic schemas, four laws each).
2. The decoder must be rewritten in linear buffer-threading style, and the whole
   `proofs/cursor_*.bend` development (about 3,500 lines) restated over indices,
   because every one of its laws currently quantifies over a duplicable
   `P.Slice`.
3. Only then do the rows in sections 2-4 become provable through the bridges.

Until 1 and 2 are done, the honest status of the migration is: measured,
designed, justified, and not implemented.
