# crash-fix5 (round 4: R4-01, R4-03, R4-04, R4-05, R4-06, the `_ctake` root): the statements that change

`tools/verify_frozen.py` passes WITHOUT `--update` (42 files, 4 statement roots, 1915 statement_defs files): no frozen statement and no definition a frozen
statement reaches changes (the generated `_valid`, `_size`, `_root` and `_putk` of the names are the implementation under test). `frozen.lock.json` is untouched.
Every change below is stronger or equivalent; none narrows a premise.

## 1. The runtime (types/, src/obj.bend)

| item | old | new |
|---|---|---|
| R4-05 `_valid` of a packed list without a limit (`proglist_uint*`, `proglist_bool`, `List[uint8 / uint64, 2^40]`) | `O.words_ok(o, 0, 0, True{}, unit)` (no upper bound) | `O.words_ok(o, 0, 4294967264, False{}, unit)` (at most NMAX bytes) |
| R4-05 `_valid` of a list of fixed-size elements that can pass NMAX (`proglist_SmallTestStruct`, `List[Validator, 2^40]`, `List[PendingDeposit, 2^27]`), and of a container or union that can pass NMAX (BeaconState, BeaconBlockBody, BeaconBlock, SignedBeaconBlock, ExecutionPayload, ProgressiveTestStruct, ProgressiveComplexTestStruct) | the fields' checks | `X_valid(o) = X_vsz(X_valid_f(o))`: the fields' checks (`X_valid_f`, the old body) and the size pass not the marker (`Bool.not(O.is_poisoned(size))`). A parent container and the list's checked writer call `X_valid_f` (the parent tests its own total). |
| R4-01 the clean copy of the root path (`O.words_copy`) | `zeros_for(n)`: `(n + 31) >> 5` wraps for n > 2^32 - 32 (8 words for a 4 GiB claim) | `O.zeros_copy(n)`: `(n >> 5) * 8 + ((n & 31) + 31 >> 5) * 8 + 8` words, no wrap |
| R4-03 the size pass of a list of variable-size elements (`_sz_fin`, seven lists) | `O.padd((4 * n : U32), m)` | `O.padd(O.mul4c(n), m)`, `O.mul4c(n) = pick(n <= NMAX / 4, 4 n, marker)` (new in `src/obj.bend`) |
| R4-04 a union's size (`CompatibleUnion*_sz<i>`, four defs) | `(m + 1 : U32)` (the marker wrapped to 0) | `O.padd(m, 1)` |
| the root of an absent box (`X_bx_root` of `O.BNone`, every boxed kind) | `(h, (X_bx_default(), D.zero()))`: the box came back as the default element | `(h, (O.BNone{}, D.zero()))`: it stays absent, so the cached root after `_ctake` is the plain root of the uncached list |

## 2. Proof statements that change (not frozen)

* The list lemmas `valid_<list>` (`proofs/obj/encx_l1099511627776_Validator`, `encx_l134217728_PendingDeposit`, `encx_pl_SmallTestStruct` and its D twin) state `T.<list>_valid_f(...) == (.., True{})` (was `_valid`): the same claim on the renamed fields' check. New `validx_f` laws (the list's and each wrapped container's MW law of its fields' check); the `validx` laws keep their statement (`T.X_valid(TH(m)) == (TH(m), True{})`) and now also prove the size pass within NMAX from OK (`VB.np_qk` / `VB.np_le`, `sizex` / `sizez`).
* The container chains `validC` / `rvalidC` (and their OKW twins `validCW` / `rvalidCW`) of the wrapped containers state `T.X_valid_f(K.OBJC(..)) == (.., True{})` (was `_valid`); new `validx_fO`, `validx_fW`, `bndxW` on OKW.
* `proofs/slop/validity/generic_proglist_*`: the symbolic `vsym` laws state the new `words_ok(o, 0, 4294967264, False{}, unit)` range (`Bool.or(False{}, U32.is_le(n, 4294967264))`).
* The union arms' size models `SZ<j>` are `O.padd(SZ(x), 1)` (was `SZ(x) + 1`), proved equal to `1 + length` by the new `VU.padd1_at`.
* The variable-element lists' size model `SZSb` is `O.padd(O.mul4c(N), SZA(..))`, rewritten to the old form by the new `VE.mul4c_q` under the list's bound.
* `proofs/slop/constants/*_mc_ser` of VarTestStruct and ProgressiveVarTestStruct (and their gate and facade restatements): the seeds of the witness values shift with the runtime's def index (no change of meaning).

## 3. New lemmas

`proofs/obj/vbuf.bend`: `u_le_nmax_dw`, `u_le_nmax_n`, `np_qk`, `np_le`. `proofs/obj/venc.bend`: `mul4c_q`. `proofs/obj/vunion.bend`: `padd1_at`.
