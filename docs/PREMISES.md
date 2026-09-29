# Premises and limits

Every premise and runtime limit that remains, by name. Source of truth: `e2e/manifest.json`
(written by `codegen/e2e_bridge.py`; the per-name `premise` field and `input_bounds`,
`input_bound_short`, `word_storage`, `decoded_premises`) and `proofs/gate/MISSING.txt`
(0 of 2205 core (name, law) pairs of the object API lack a proving law). The manifest's
`uncovered`, `decode_uncovered` and `root_awaiting` lists are empty: every one of the 124 bridged
variable- and fixed-size names has its encode (i), decode (ii)/(iii) and root (iv) bridge.

## 1. Object validity: `rep`

The laws are about objects satisfying the API's representation invariant (`rep`: the root law's
invariant; `rep_v*` / `rep_bits` / `rep_pl*` for generic forms). Everything the API produces
(decode, constructors, setters, append) satisfies it, by the producer laws. Storage premises
(`hs*`, `hc`, `hd*`, `hsP`: a words tree at depth below 31, or below 28 for `hs11` of the block
body and `hB`, the extra data) hold of every decoded object; the encode laws take depth below 31,
the root law below 32.

## 2. Runtime limits

- **Container encode limit, 2^31 - 1 bytes.** The encode laws for containers with unbounded
  parts are on the OKW laws and the D twins (`encx_d.py`, bound of OKT at 2^31 - 1): the
  encoding is below 2^31 bytes. The manifest calls it the object API's own limit.
- **Decode NMAX = 2^32 - 32.** The decode laws hold for inputs `n <= VB.NMAX()` (premise `hS`,
  written `hN` in the decode_view statements: `U32.is_le(n, VB.NMAX()) == True`). 52 of the 58
  variable-size bridged names use it. Other input bounds: 2^30 for FuluExecutionPayloadHeader,
  FuluLightClientBootstrap, FuluLightClientHeader, FuluLightClientOptimisticUpdate; 2^29 for
  FuluLightClientFinalityUpdate and `progbitlist`.
- **`input_bound_short` (20 names).** The bound does not admit every legal encoding: the 5
  Fulu containers whose largest encodings exceed any U32 length (FuluBeaconState 152862724982449
  bytes; FuluBeaconBlockBody, FuluBeaconBlock, FuluSignedBeaconBlock, FuluExecutionPayload about
  2^50), and the 15 progressive forms (unbounded): CompatibleUnionABCA, CompatibleUnionBC,
  ProgressiveTestStruct, ProgressiveBitsStruct, ProgressiveComplexTestStruct,
  ProgressiveSingleListContainerTestStruct, ProgressiveVarTestStruct, `progbitlist`, and
  `proglist_{bool,uint8,uint16,uint32,uint64,uint128,uint256}`.
- **Progressive bit lists, 2^29 bytes.** A progressive bit-list field is bounded at 2^29 bytes
  in decode (`PBQ`, section 4) and in the encode bridges (a bit list at its constant bound
  2^29 + 1 in the totals; `hK: 32 + K <= 2^30` for `progbitlist`, the encode laws' word arithmetic;
  bit lists `EP.SDPB` at `K <= 2^32 - 8`). A decoded list can exceed these, so they stay premises.

## 3. Total-size premises (encode, section (i))

- **`hZ`**: the encoding is below 2^31 bytes (each part's byte count is a witness; `SZW` /
  `SZOK` / `SZR` of the record). On FuluBeaconState, FuluBeaconBlockBody, FuluBeaconBlock,
  FuluSignedBeaconBlock, FuluExecutionPayload. Nothing in the object bounds a list's length, so
  it stays a premise.
- **`hM_j`** (manifest spelling; `hm_j` in the brief): FuluBeaconState only. Each byte-storage
  list `j` has its bytes below 2^31, its share of the total that `hZ` bounds.
- **Per-object totals `TOT_<Name>`**: ProgressiveTestStruct, ProgressiveComplexTestStruct: the
  fixed part plus the measures of the list fields below 2^31, plus one size measure per unbounded
  list field (word-list length, 4 N of a record list, `EL.LL` of a variable-element list).
- **Per-part budgets `hzb4`, `hzb5`**: on the block-level attester-slashings and attestations
  lists of FuluBeaconBlockBody, FuluBeaconBlock and FuluSignedBeaconBlock (the block and signed block repeat the premises of their body): each list's own encode record bounds its bytes by
  4 * 2^28 (`e2e_bbsl.SZ1`, `e2e_bbatt.SZ8`); the lists' OK laws bound them and nothing in
  the object does. `hs4` / `hs5` are the same lists' storage premises.

## 4. Decode premises

- **`hS`/`hN`**: `n <= NMAX` as above; DataColumnSidecar's decode_view takes
  `hn` (buffer depth), `hN: U32.is_le(n, VB.NMAX()) == True` and `hchk: DC.CHK(t, n)`
  (the decoder's acceptance check) like every other decode bridge.
- **`PBQ`**: on unions **CompatibleUnionABCA** and **CompatibleUnionBC**, and on
  ProgressiveBitsStruct, ProgressiveComplexTestStruct, ProgressiveSingleListContainerTestStruct and
  ProgressiveVarTestStruct: `hPB: PBQ(t, n) == True`, every progressive-bit-list field `[O, E)`
  inside the input has `E - O <= 2^29`.
- **`hN` for FuluSyncCommittee / FuluSignedContributionAndProof (root and encode)**: the
  pubkeys' length 24576 (`rep` fixes only the element count), with `hc`, the pubkeys' storage at
  depth 13.

## 5. Encode-record gaps: depth 31 versus the root law's 32

The LightClient names still carry them: FuluLightClientBootstrap, FuluLightClientHeader,
FuluLightClientOptimisticUpdate (`hs`: each storage field at depth below 31; the encode
laws take dw < 31, the root law dw < 32, so the dw = 31 case is not covered), and
FuluLightClientUpdate / FuluLightClientFinalityUpdate (`hA`, `hF`: `e2e_mw.SHS_L` of the two headers,
`h1`, `h2`, `h4`, `hB`: sync-committee pubkeys and branches below 31). The premises are dropped
when the encode laws take dw < 32.

## 6. The `hv` exceptions

`hv`: the last word of a bit list has its bits at or above the length K clear.
- Proved, not premises: for the 12 names of `decoded_premises.hv_SDB` (BitsStruct,
  FuluAggregateAndProof, FuluAttestation, FuluBeaconBlock, FuluBeaconBlockBody,
  FuluPendingAttestation, FuluSignedAggregateAndProof, FuluSignedBeaconBlock,
  ProgressiveBitsStruct, ProgressiveComplexTestStruct,
  ProgressiveSingleListContainerTestStruct, ProgressiveVarTestStruct) each accepted
  input's object satisfies it (`decoded_hv` in `<Name>_e2e_dec_generated.bend`). The premise
  stays in the (i) statement, carried "until a lemma derives it".
- Exceptions still premises: for the progressive bit lists the size bounds `K + 32 <= 2^30`
  (a decoded list can exceed them); ProgressiveBitsStruct's 1281-bit vector premise `SDW81`
  (`HB81`), a separate fixed-size fact; `hv0..hv2` of FuluDataColumnSidecar and `hv11` (`hv114`,
  `hv1140` in the block and signed block) of the block body: object API validity, each list a whole
  number of elements (`O.unit_ok`: blocks, 48-byte commitments).

## 7. Word-storage bridges

`word_storage` covers 44 `vec_uint{32,64,128,256}_N` forms; the eight of 512 and 513 elements
(`vec_uint32_512/513`, `vec_uint64_...`, `vec_uint128_...`, `vec_uint256_...`) still await
their (ii)/(iii) bridge.
