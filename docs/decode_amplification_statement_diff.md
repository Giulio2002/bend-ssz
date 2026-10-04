# decode-amplification (R4-02 reopened): the statements that change

No existing statement changes: `e2e/STATEMENTS.txt` is unchanged, `_decode` and `_decode_checked` are unchanged (text for text), and no
premise is added anywhere. Everything below is new.

## 1. The runtime

Also (round 6, R6-03): `O.words_slice(o, p, n)` answers the empty slice for n > NMAX as for n = 0 (its word count and storage wrapped for
n >= 2^32 - 3); the only generated caller passes 2048.

| item | new |
|---|---|
| `src/obj.bend` | `dcost(size, k)` (with `dcost_k`, `dcost_go`): ((size >> 3) + 1) * k + 524288 heap words of 8 bytes, 2^32 - 1 when that does not fit U32; 524288 for k = 0 |
| every name X (types/<Name>_decode_ssz_generated.bend) | `X_dcost(size) = O.dcost(size, K)` with the name's K (codegen/decode_cost.json); `X_dcb(ok, buf, size)`; `X_decode_checked_budget(buf, size, budget) = X_dcb(X_dcost(size) < 2^32 - 1 and X_dcost(size) <= budget, buf, size)` (a saturated bound refused, R6-01): `X_decode_checked(buf, size)` or `(buf, None)` |

`codegen/impl/runtime_file_split.py` files `_decode_checked_budget` and `_dcost` with the decoder (roots of the decode file). Adding
definitions moves the def index of later runtime definitions, so the witness seeds of `proofs/slop/constants/*` (and their gate copies)
shift, with no change of meaning (as in crash-fix5).

## 2. New laws (per name, proofs/slop/validity/<runtime>_<X>_decode_checked_generated.bend, filed by api_gate under decode_offsets)

* `X_decode_vchecked_budget_refuse(buf, size, budget, h: (X_dcost(size) < 2^32 - 1 and X_dcost(size) <= budget) == False)`: `X_decode_checked_budget(buf, size, budget) == (buf, None)`
* `X_decode_vchecked_budget_agree(buf, size, budget, h: (X_dcost(size) < 2^32 - 1 and X_dcost(size) <= budget) == True)`: `X_decode_checked_budget(buf, size, budget) == X_decode_checked(buf, size)`
* `X_decode_vchecked_budget_cost`: `X_dcost(4096) == ((4096 >> 3) + 1) * K + 524288` (the literal)
* `X_decode_vchecked_budget_saturated` (K >= 8): `X_decode_checked_budget(B.empty(), 4294967264, 4294967295)` is None (R6-01)
* `X_decode_vchecked_budget_zero`: `X_decode_checked_budget(B.empty(), 8, 0)` is None
* `X_decode_vchecked_budget_accept` (names with a valid default window W of at most 2048 bytes): with the budget 2^32 - 1, W decodes, as by `X_decode_checked`

These laws are new (not frozen). Before round 6 the refuse / agree premises were `X_dcost(size) <= budget` alone (R6-01 adds the
saturation test). The gate facades (proofs/api/<Name>_decode_ssz_proof_generated.bend) restate the symbolic ones.

## 3. Frozen lock

`e2e/STATEMENTS.txt` is unchanged. `tools/verify_frozen.py` reports one statement_defs file, `src/obj.bend` (R6-03: `O.words_slice` now
answers the empty slice for n > NMAX, `Bool.or(n == 0, n > 4294967264)` in place of `n == 0`; the frozen statements that reach it, the cell
getter's, slice n = 2048 and are unchanged in meaning: equivalent). `--update` records it in `frozen.lock.json` (one hash). The budget
definitions themselves reach no frozen statement.
