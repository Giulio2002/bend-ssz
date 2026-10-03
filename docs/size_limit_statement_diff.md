# Size limit (CH-02, CH-07, R3-03): the statements that change

Design: docs/SIZE_LIMIT_DESIGN.md, option (a). The marker of an invalid size is `4294967295` (it was `2147483648`); `O.padd` saturates (it returns
`a + b` when that neither wraps nor reaches the marker, else the marker); `O.is_poisoned(m) = U32.is_lt(4294967264, m)`; `n * es` of a fixed element size
is `O.mulc(n, es) = pick(n <= floor(4294967264 / es), n * es, marker)`. A valid object may now be up to `NMAX = 4294967264` bytes (`VB.NMAX()`, the existing chunk-rounding
limit). Every theorem keeps its conclusion; a bound `x < 2^31` (`Nat.is_lt(x, VB.pw(31n))`) becomes `x <= NMAX` (`Nat.is_le(x, U32.to_nat(VB.NMAX()))`), which is
weaker as a premise (the theorem covers strictly more objects) and stronger as a conclusion. The generated sources are in the diff of `agent/size-limit`; the machine
extract of every changed frozen statement line is `docs/size_limit_statement_diff_full.txt` (286 lines, 23 files, `-` old and `+` new).

`tools/verify_frozen.py` reports exactly 23 statement files whose hash changes (and nothing else: the specification, the roots, the model, the whole-file locks and
`law-statements.json` are untouched). They are listed below with the reason; `frozen.lock.json` is updated only after this document matches that list.

## 1. The implementation definitions the statements reach (`src/obj.bend`)

| def | old | new |
|---|---|---|
| `poison()` and the `False` arm of `pz` | `2147483648` | `4294967295` |
| `padd(a, b)` | `(a + b) .\|. ((a .\|. b) .&. 2147483648)` | `pick(Bool.and(U32.is_le(a, a + b), U32.is_lt(a + b, 4294967295)), a + b, 4294967295)` |
| `is_poisoned(m)` | `U32.is_le(2147483648, m)` | `U32.is_lt(4294967264, m)` |
| the two size pickers (`wsz_pick`, `bsz_pick`) | marker `2147483648` | marker `4294967295` |
| new `mulc(n, es)` | (plain `n * es`) | the checked product above |
| new `out_donep(bad, m, out)`, `out_donem(m, out)` | (the unchecked `_encode` built `B.Buf{out, m}` from the marker) | a poisoned length gives `B.empty()` (CH-02) |

## 2. The frozen statement files that change

Lifted bounds (`pw(31n)` strict to `NMAX`, weaker premise, the same conclusion):

* `e2e/e2e_encld`: `PW1`, `nmaxD`, `ok_pu8`, `ok_pu64`, `lb2_pu8`, `lb2_pu64` (the word-list window facts), `PRL_pl_SmallTestStruct`'s byte bound, `PM_pl_VarTestStruct` and `mk2_pl_VarTestStruct` (`hll`).
* `e2e/e2e_encq2d`: `TOT_ProgressiveTestStruct`, `TOT_ProgressiveComplexTestStruct` (the total-size premise: `<= NMAX`), and the two `c1f_*` bridges.
* `e2e/e2e_epr`: `SZOK`.
* `e2e/e2e_rec_BeaconBlock`, `e2e/e2e_rec_BeaconBlockBody`, `e2e/e2e_rec_SignedBeaconBlock`: `pre_lt` / `sub_lt` (now `is_le`), `SZW`, `kX`, `kS`.
* `e2e/FuluBeaconState_e2e` (`obC` is stated at output-tree depth `k == 30n`, was 29n; `okw`, `bndz`, `fin`, `kS`, `FuluBeaconState_e2e_encode`: the byte-list and bitlist premises `hm7`, `hm12`, `hm15`, `hm16`, `hm21` and the total `hZ` at `NMAX`).
* `e2e/FuluBeaconState_e2e_witness`: `szr_lt`, the `premise_hm*`, `premise_hZ`, `premise_ne_*`, `FuluBeaconState_e2e_witness_size` and `_nonempty` (the default and the non-empty object satisfy the lifted premises).
* `e2e/Fulu{BeaconBlock,BeaconBlockBody,BeaconState,ExecutionPayload,SignedBeaconBlock}_e2e_comp`: the composed decode theorems `acc`, `ge`, `gr`, `*_e2e_decode_encode`, `*_e2e_decode_root`: the window premise `hS: U32.is_le(n, VB.NMAX())` and the size premises at `NMAX` (the decoder refuses `size > 4294967264`, see section 5).

Append bounds are the true limits (the old ones were halved by the poison bit):

* `types/Fulu_list_Validator_1099511627776_def`: `append` and `capp` admit `n < 35495597 = floor(4294967264 / 121)` (was `17747798 = floor(2^31 / 121)`); `Fulu_list_PendingDeposit_134217728_def` (192-byte element) from `11184810 = floor(2^31 / 192)` to `22369621 = floor(NMAX / 192)`; `Fulu_list_PendingPartialWithdrawal_134217728_def` (24-byte element) from `89478485 = floor(2^31 / 24)` to its list limit `134217728` (`floor(NMAX / 24)` is larger, so the type's own limit now binds).
* `proofs/obj/coll_api_3`, `coll_api_4`, `coll_seq` (`*_api_append_flag`, `_rejected`, `_length`, `_read_append`, `_view_append`) and `e2e/l1099511627776_Validator_api_witness`, `l134217728_PendingDeposit_api_witness`, `l134217728_PendingPartialWithdrawal_api_witness`: the same guard literal in the statements and in the witnesses (a list at the old bound now appends; the rejected witness is stated at the new bound).

## 3. The statements that gain a premise

* `N <= NMAX` (`Nat.is_le(U32.to_nat(N), U32.to_nat(VB.NMAX()))`) on the encode laws of the unbounded counts (the checked product `O.mulc` of a count is exact only below that bound; above it the writer returns the marker and the law is not about it). The laws that bounded the count by the old limit state `N <= NMAX`.
* `hS: {Nat.is_le(.., NMAX)}` on `encode_eval` of the progressive word lists (`progressive_word_list_codec_laws`).
* The decoders' `dchw` laws gain the conjunct `size <= 4294967264` (the window the checked decoder accepts), compatible with the decode window `size <= B.size(buf)`.

## 4. The statements deliberately kept at 2^31 (documented, not weakened)

The progressive record-list families (`pl_SmallTestStruct`, `l10_*`, `pl_VarTestStruct`, `pl_pl_VarTestStruct`, `pl_ProgressiveVarTestStruct`) keep the old shape of their DECODE window facts: the list window is shorter than 2^31 bytes (`h31: len < 2^31`), the record count at most 2^29 and the output tree depth below 30 (`ER.LDEP < 30n`). With the byte bound at `NMAX` the count could reach 2^30 - 8 and the depth 30, which is a different tree shape with its own lemmas (`CC29`, `PDW`, `wd_min`). Consequences:

* the decode composed theorems of `ProgressiveTestStruct` and `ProgressiveComplexTestStruct` still carry their old premises (`1 + n < 2^31`, `258 + n < 2^29`): those two decode statements (`e2e/*_e2e_comp`) are NOT in the changed list above;
* the encode side of the same types is lifted: `TOT_ProgressiveTestStruct` / `TOT_ProgressiveComplexTestStruct` are `<= NMAX`, and the decode proofs convert (`VB.le_pw31_nmax`) their strict facts to those premises;
* the variable-size list twins `encx_pl_*_d` (`OKT`) are now stated at `LL <= NMAX` and use the base size lemmas `szsS`, `szlS`, `speclB`; the strict `*D` copies of the size lemmas are gone;
* the runtime accepts and encodes progressive lists up to `NMAX`; only the proof coverage of their DECODE for windows between 2^31 and `NMAX` is absent (the decoder returns a value or `None`, never a poisoned buffer: the regression and invalid-object suites cover it by execution).

## 5. Runtime: what a reader of the proofs should not assume

* `X_decode_checked` / `X_dchw` accept `size <= 4294967264` (was `size < 2^31`).
* `X_encode` of an invalid object no longer allocates from the marker (`out_donem`): it returns the empty buffer; `serialize` returns `ok = 0`.
* Every fixed-count product is `O.mulc`; the model and the writers use the same def, and the `szx*` lemmas prove `to_nat(O.mulc(N, RS)) == LL` from `N <= NMAX`-bounds.

## 6. Checks

The cold pinned full check, the regress and hunter runs and the unit tests are listed in docs/CRASH_HUNT.md (CH-02, CH-07, R3-03 closed).
