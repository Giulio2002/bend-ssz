# Decode amplification (R4-02 reopened)

`_decode` builds the object of a valid input in the runtime's heap. The heap it takes per input byte depends on the shape of the input:
a list of variable-size elements costs an array slot and a boxed element per 4-byte offset, so an input made of empty elements
(1,048,576 empty transactions, a 4 MiB offset table) takes about 30 times its size. The deployed runtime (the Prysm FFI shim) reserves
an 8 GiB Bend heap and exits on out-of-memory, so a few hundred MB of such valid input would kill the node. This document measures the
amplification of every one of the 240 names, explains why the per-element cost cannot be cut below a few heap bytes per input byte in
this representation, and describes the mitigation: an opt-in decode budget.

## 1. Measurement

`tools/decode_amp/measure.py` (server, one program at a time): for every name, every list-like node of its type (lists, progressive
lists, byte lists, bit lists, progressive bit lists) reached from the root through containers, the options of unions and one element of
an enclosing list is filled with copies of the smallest value of its element (an empty inner list, an empty bit list of 1 byte, a zero
fixed element), the rest of the value smallest; and, for the elements of variable-size lists, short non-empty elements too (byte lists of
1, 2, 3, 4, 5, 31, 32, 33 bytes, bit lists of 1, 7, 8, 9, 31, 32, 33 bits, inner lists of 1 or 2 fixed elements, and these as fields of
container elements: a 1-byte byte list holds a whole chunk and its slack, so it can cost more per input byte than an empty one); 438 shapes. The count is the one closest below 32 MiB of input that is worst for the
storage rounding (a power of two plus one element: the array then has twice the slots it needs; 2^k bytes for a byte list; 2^k + 1
bytes for a bit list), capped at the list's limit. Each shape is checked against the independent oracle (codegen/core/independent_ssz_oracle.py)
at a small count, encoded, and decoded once by the compiled object program of its group (`benchmarks/objprog/{g,x}<k>`, built with the
stock 2.0.34 compiler as the Prysm library is; SSZ_MODE 1: one `_decode`, the object forced) under `/usr/bin/time`. The same input given
to a fixed-size name of the same program, which refuses it at once, gives the peak of the program and the input buffer.

* **ratio**: (peak - refused peak) / input bytes: the decode's own heap (the object and the decode's transients) per input byte.
* **slope**: (peak at the count - peak at a quarter of the count) / (difference of the inputs): the cost of one more input byte, the
  constants cancelled; it also counts the input buffer (about 2 bytes per byte: the buffer's word array rounded to a power of two), so it
  is above the decode's own density.

Every shape is accepted by its program. For a name whose largest encoding is below 128 KiB the ratio is dominated by the program's
constants (its accept path allocates about 1 MB more than its refuse path); those rows are marked `small` in the table.

The worst shapes (before; full table in section 5):

| name | shape | input | decoded heap per input byte | slope |
|---|---|---:|---:|---:|
| BeaconBlock, BeaconBlockBody, SignedBeaconBlock, ExecutionPayload | `transactions` of 2^19 + 1 transactions of 1 byte | 2.6 MB | 28.5 - 28.7 | 30.4 - 30.5 |
| the same | 2^19 + 1 empty transactions (2 bytes: 23.8; 4 bytes: 17.6; longer is lower) | 2.1 MB | 27.4 - 28.0 | 29.4 - 30.2 |
| ProgressiveComplexTestStruct, ProgressiveTestStruct | `f_F` / `f_D` of 2^22 + 1 empty inner lists | 16.8 MB | 22.0 | 24.0 |
| ProgressiveComplexTestStruct | `f_H` of empty ProgressiveVarTestStructs (10 bytes each) | 29.4 MB | 16.0 | 17.2 |
| every other name | | | at most 2.6 (BeaconState: pending deposits) | at most 4.1 |

A block's transaction list is capped at 1,048,576 entries (4 MiB of offsets, about 120 MB decoded); the progressive containers have no
such cap: a 600 MiB ProgressiveComplexTestStruct of empty inner lists decodes to about 14 GB.

## 2. Why the per-element cost stays above about 6 bytes per input byte

The object of a list of variable-size elements is an `Array<O.Boxed<T>>` (the element boxed, a representation of the generated runtime
used by every operation and every proof of these lists). `tools/decode_amp/mb/mb.bend` builds 2^22 elements of three kinds into such an
array (stock 2.0.34, peak RSS):

| element | heap bytes per element |
|---|---:|
| `O.BNone{}` (no element object at all: the array slot only) | 24 |
| `O.BSome{O.Words{Array.new(U32, 0n, 0), 0}, O.BNone{}}` (a box, a Words, a one-word array) | 63 |
| `O.BSome{O.Words{O.zeros_for(0), 0}, O.BNone{}}` (the decoded empty transaction: an 8-word array) | 86 |

The array itself is a tree whose slots cost 24 bytes each, and the decoder sizes it to a power of two (twice the slots for a count just
above one). An element takes at least 4 input bytes (its offset), so even with no element object at all the floor is 6, and 12 at the
worst count. Sharing one constant for every empty element is not possible: arrays and `Words` are linear values in the runtime (not
`Data`), so each element is its own object; and the absent box `O.BNone` already means "taken" (its root is the zero chunk, the
`_take` / `_ctake` of crash-fix5), not "the default element". The cheapest change in reach, a one-word array for an empty byte list
(86 to 63 bytes per element), would move the transactions shape from 28 to about 21 bytes per byte, still far from 4, and changes the
decoded representation that every decode and root proof of the byte lists reasons about. The target of at most about 4 heap bytes per
input byte is therefore not reachable for these shapes without a different representation of lists of variable-size elements (a flat
array of offsets into one byte store, say), which is a redesign of the runtime and of its proofs; the decoder is unchanged, and the
protection is the budget.

## 3. The mitigation: an opt-in decode budget

The protection is opt-in: only callers of `X_decode_checked_budget` get it. `X_decode_checked` and `_decode` are unchanged and have no
memory limit. The bound is a MEASURED estimate, not a proved bound: K = ceil(1.25 x the worst density measured over the name's shapes + 1);
the laws state what the budget does with the bound, not that the bound is the decode's true cost. A bound that saturates (2^32 - 1: it
does not fit 32 bits) is refused whatever the budget (docs/CRASH_HUNT.md R6-01), so the largest budget, 2^32 - 1, means "up to 2^32 - 2
words" (about 32 GiB), not "no limit": an embedder with a heap of 32 GiB or more clamps to it and still refuses what does not fit.

The bound covers `_decode` alone (R6-02, measured by the round-6 hunter, docs/crash_hunt_evidence/r6): a caller that flattens the decoded
object (`X_flat`, the Prysm shim's path) or dumps it (`X_dump`) allocates more, and must leave that headroom in its budget:

| name / shape | decode only | decode + X_flat | decode + X_dump | K |
|---|---:|---:|---:|---:|
| BeaconState pending_partial_withdrawals / pending_deposits | 2.5 | 6.9 | - | 7 |
| BeaconState validators | 2.1 | 6.5 | 19.1 | 7 |
| DataColumnSidecar, column at 4096 | 2.0 | 6.1 | 18.3 | 6 |
| ExecutionPayload, 2^19 + 1 one-byte transactions | 28.4 | 28.8 | 38.8 | 40 |
| ProgressiveComplexTestStruct f_F, empty inner lists | 21.6 | 21.8 | 30.6 | 31 |

(heap bytes per input byte; the flat stream adds about 4 per packed input byte, the dump about 16.)

Every name X has (types/<Name>_decode_ssz_generated.bend):

    X_dcost(size)                          = O.dcost(size, K)  =  ((size >> 3) + 1) * K + 524288   heap words of 8 bytes (2^32 - 1 if it does not fit)
    X_decode_checked_budget(buf, size, b)  = None (nothing read, nothing allocated)   when X_dcost(size) > b
                                           = X_decode_checked(buf, size)              otherwise

K is the name's heap bytes per input byte, from the measurement (codegen/decode_cost.json, written by tools/decode_amp/k_table.py):
`ceil(1.25 * D + 1)` with D the worst density over the name's shapes (the ratio of inputs of at least 128 KiB and the slope over at
least 1 MiB); a name whose largest encoding at 48 bytes per byte fits the constant 4 MiB has K = 0. The bound holds for every shape:
a list of variable-size elements filled with elements of length l costs per input byte a mix of its empty-element density and the
element's own density, so the worst is one of the measured shapes (empty elements, or the element type's own worst shape one level
down). Every one of the 438 measured shapes decodes within its bound (section 5, last column: bound / decoded heap, at least 1.4). K is
measured, not proved: the laws say what the budget does with the bound, not that the bound is the decode's true cost. A name's K is
at least that of every name nested in it, by structure, aliases included (a block charges at least its body and its payload,
BlobSidecar at least its Blob: docs/CRASH_HUNT.md R6-04); decode_checked_laws.py stops when that does not hold.

K by name (the others 0, or 4 to 7: byte, bit and packed lists 5 to 7, BeaconState 7, DataColumnSidecar 6):

| name | K |
|---|---:|
| ExecutionPayload, BeaconBlockBody, BeaconBlock, SignedBeaconBlock | 40 |
| ProgressiveComplexTestStruct, ProgressiveTestStruct | 31 |

`X_decode_checked` is unchanged: its decode is always within `X_dcost(size)`, which is at most 40 x size + 4 MiB bytes, so "a fixed
multiple of its size" holds for it as it is (an explicit default budget proportional to the input would never refuse: every K is below
it). An embedder with a fixed heap calls `X_decode_checked_budget` with what its heap leaves after the input buffer. The Prysm shim's
8 GiB heap is 2^30 words: a block of up to about 200 MB, any BeaconState of up to about 1 GB, and no 600 MiB progressive container of
empty lists (bound 2,438,463,519 words) get through.

Laws (proofs/slop/validity/<runtime>_<X>_decode_checked_generated.bend, for every name): `_budget_refuse` (bound saturated or above the budget:
the buffer and None, for every buffer, size and budget), `_budget_agree` (otherwise `X_decode_checked(buf, size)`), `_budget_cost` (the bound
of 4096 bytes is the literal ((4096 >> 3) + 1) * K + 524288), `_budget_zero` (a budget of 0 refuses) and, with a valid default window,
`_budget_accept` (the budget 2^32 - 1 decodes it), and for K >= 8 `_budget_saturated` (the bound of NMAX bytes saturates: refused with the
budget 2^32 - 1). The decode statements are unchanged (docs/decode_amplification_statement_diff.md).

## 4. Regression

`tools/crash_hunt/regress.sh` cases 73-76: the bound of an ExecutionPayload of 65,537 empty transactions (262,676 bytes) is 1,837,688
words; one word below it the budget decode is None, at it the payload decodes; the bound of a 600 MiB ProgressiveComplexTestStruct is
2,438,463,519 words, above the 2^30 words of an 8 GiB heap. Cases 77-78 (round 6): ProgressiveComplexTestStruct of 2^31 bytes with
the budget 2^32 - 1 is refused (its bound saturates, R6-01); `O.words_slice(o, 0, 2^32 - 1)` answers the empty slice at once (R6-03).

## 5. All names

The worst shape of every name (the largest ratio among its inputs of at least 128 KiB; for a name with no such input, its largest input,
marked `small`: its ratio is dominated by the program's constants and its decode is within the bound's constant). The decoder is not
changed by this branch, so the table is both the before and the after; the last column is the bound X_dcost(input) over the measured
decoded heap. Peak RSS in KiB; `refused`: the same program refusing the same input. Raw data: tools/decode_amp/measure_before.json.

| name | worst shape | input bytes | peak RSS KiB | refused KiB | ratio | slope | K | bound / decoded |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| SignedBeaconBlock | `message.body.execution_payload.transactions.[1B]` | 2,622,565 | 80,868 | 7412 | 28.68 | 30.37 | 40 | 1.5 |
| BeaconBlock | `body.execution_payload.transactions.[1B]` | 2,622,465 | 81,216 | 7824 | 28.66 | 30.37 | 40 | 1.5 |
| BeaconBlockBody | `execution_payload.transactions.[1B]` | 2,622,381 | 81,216 | 7824 | 28.66 | 30.51 | 40 | 1.5 |
| ExecutionPayload | `transactions.[1B]` | 2,621,973 | 80,768 | 7832 | 28.48 | 30.5 | 40 | 1.5 |
| ProgressiveComplexTestStruct | `f_F.[]` | 16,777,250 | 396,140 | 36292 | 21.96 | 24.0 | 31 | 1.4 |
| ProgressiveTestStruct | `f_D.[]` | 16,777,236 | 396,096 | 36248 | 21.96 | 24.0 | 31 | 1.4 |
| Blob | `(fixed)` | 131,072 | 4,388 | 4040 | 2.72 | - | 5 | 13.6 |
| BeaconState | `pending_deposits.[]` | 27,903,825 | 108,520 | 36496 | 2.64 | 3.82 | 7 | 2.7 |
| ExecutionRequests | `deposits.[]` | 786,636 | 6,664 | 4768 | 2.47 | - | 5 | 4.2 |
| AttesterSlashing | `attestation_1.attesting_indices.[]` | 524,760 | 5,552 | 4384 | 2.28 | - | 4 | 5.3 |
| HistoricalBatch | `(fixed)` | 524,288 | 5,172 | 4004 | 2.28 | - | 4 | 5.3 |
| proglist_uint16 | `[]` | 16,777,218 | 69,296 | 35880 | 2.04 | 4.02 | 7 | 3.6 |
| CompatibleUnionABCA | `<2>.f_C.bits` | 16,777,222 | 69,312 | 36244 | 2.02 | 4.02 | 7 | 3.6 |
| CompatibleUnionBC | `<2>.f_C.bits` | 16,777,222 | 69,312 | 36224 | 2.02 | 4.02 | 7 | 3.6 |
| ProgressiveBitsStruct | `f_F.bits` | 16,777,642 | 69,304 | 36232 | 2.02 | 4.02 | 7 | 3.6 |
| ProgressiveSingleListContainerTestStruct | `f_C.bits` | 16,777,221 | 69,300 | 36228 | 2.02 | 4.02 | 7 | 3.6 |
| ProgressiveVarTestStruct | `f_C.bits` | 16,777,226 | 69,364 | 36260 | 2.02 | 4.02 | 7 | 3.6 |
| progbitlist | `bits` | 16,777,217 | 69,316 | 36244 | 2.02 | 4.02 | 7 | 3.6 |
| proglist_uint128 | `[]` | 16,777,232 | 68,916 | 35860 | 2.02 | 4.02 | 7 | 3.6 |
| proglist_uint64 | `[]` | 16,777,224 | 68,904 | 35872 | 2.02 | 3.99 | 6 | 3.1 |
| proglist_uint8 | `[]` | 16,777,217 | 69,244 | 36224 | 2.02 | 4.02 | 7 | 3.6 |
| proglist_uint32 | `[]` | 16,777,220 | 69,288 | 36292 | 2.01 | 4.02 | 7 | 3.6 |
| Transaction | `bytes` | 33,554,432 | 101,916 | 36264 | 2.0 | 3.0 | 5 | 2.6 |
| proglist_bool | `[]` | 16,777,217 | 68,964 | 36228 | 2.0 | 4.0 | 6 | 3.1 |
| proglist_uint256 | `[]` | 16,777,248 | 68,892 | 36276 | 1.99 | 3.99 | 6 | 3.1 |
| DataColumnSidecar | `column.[]` | 4,196,708 | 20,152 | 12076 | 1.97 | 3.97 | 6 | 3.6 |
| IndexedAttestation | `attesting_indices.[]` | 524,524 | 5,532 | 4848 | 1.34 | - | 3 | 8.2 |
| BlobSidecar | `(fixed)` | 131,928 | 4,564 | 4456 | 0.84 | - | 5 | 43.9 |
| AggregateAndProof | `aggregate.aggregation_bits.bits` | 16,729 | 2,864 | 2856 | small | - | 0 | 512.0 |
| Attestation | `aggregation_bits.bits` | 16,621 | 2,896 | 2912 | small | - | 0 | 4194304.0 |
| AttestationData | `(fixed)` | 128 | 2,484 | 2516 | small | - | 0 | 4194304.0 |
| BLSPubkey | `(fixed)` | 48 | 2,464 | 2464 | small | - | 0 | 4194304.0 |
| BLSSignature | `(fixed)` | 96 | 2,484 | 2508 | small | - | 0 | 4194304.0 |
| BLSToExecutionChange | `(fixed)` | 76 | 2,884 | 2536 | small | - | 0 | 11.8 |
| BeaconBlockHeader | `(fixed)` | 112 | 2,464 | 2444 | small | - | 0 | 204.8 |
| BitsStruct | `f_A.bits` | 13 | 2,504 | 2520 | small | - | 0 | 4194304.0 |
| BlobIdentifier | `(fixed)` | 40 | 3,608 | 3116 | small | - | 0 | 8.3 |
| BlobIndex | `(fixed)` | 8 | 3,256 | - | small | - | 0 | 4194304.0 |
| Bytes1 | `(fixed)` | 1 | 2,084 | - | small | - | 0 | 4194304.0 |
| Bytes20 | `(fixed)` | 20 | 2,084 | 2084 | small | - | 0 | 4194304.0 |
| Bytes32 | `(fixed)` | 32 | 2,092 | 2064 | small | - | 0 | 146.3 |
| Bytes4 | `(fixed)` | 4 | 2,072 | 2456 | small | - | 0 | 4194304.0 |
| Bytes48 | `(fixed)` | 48 | 2,452 | 2396 | small | - | 0 | 73.1 |
| Bytes8 | `(fixed)` | 8 | 2,492 | 2444 | small | - | 0 | 85.3 |
| Bytes96 | `(fixed)` | 96 | 2,412 | 2008 | small | - | 0 | 10.1 |
| Cell | `(fixed)` | 2,048 | 2,892 | 2852 | small | - | 0 | 102.4 |
| CellIndex | `(fixed)` | 8 | 2,844 | - | small | - | 0 | 4194304.0 |
| Checkpoint | `(fixed)` | 40 | 2,468 | - | small | - | 0 | 4194304.0 |
| ColumnIndex | `(fixed)` | 8 | 2,632 | - | small | - | 0 | 4194304.0 |
| CommitmentIndex | `(fixed)` | 8 | 2,924 | - | small | - | 0 | 4194304.0 |
| CommitteeIndex | `(fixed)` | 8 | 2,488 | - | small | - | 0 | 4194304.0 |
| CompatibleUnionA | `(fixed)` | 2 | 2,444 | 2496 | small | - | 0 | 4194304.0 |
| ComplexTestStruct | `f_E.f_B.[]` | 1,126 | 2,452 | 2488 | small | - | 0 | 4194304.0 |
| ConsolidationRequest | `(fixed)` | 116 | 2,548 | 2888 | small | - | 0 | 4194304.0 |
| ContributionAndProof | `(fixed)` | 264 | 2,424 | 2468 | small | - | 0 | 4194304.0 |
| CurrentSyncCommitteeBranch | `(fixed)` | 192 | 2,472 | 2456 | small | - | 0 | 256.0 |
| CustodyIndex | `(fixed)` | 8 | 2,440 | - | small | - | 0 | 4194304.0 |
| DataColumnsByRootIdentifier | `columns.[]` | 556 | 2,892 | 2892 | small | - | 0 | 4194304.0 |
| Deposit | `(fixed)` | 1,240 | 2,448 | 2464 | small | - | 0 | 4194304.0 |
| DepositData | `(fixed)` | 184 | 2,488 | 2440 | small | - | 0 | 85.3 |
| DepositMessage | `(fixed)` | 88 | 2,520 | 2440 | small | - | 0 | 51.2 |
| DepositRequest | `(fixed)` | 192 | 2,496 | 2512 | small | - | 0 | 4194304.0 |
| Domain | `(fixed)` | 32 | 2,464 | 2512 | small | - | 0 | 4194304.0 |
| DomainType | `(fixed)` | 4 | 2,080 | - | small | - | 0 | 4194304.0 |
| Epoch | `(fixed)` | 8 | 2,492 | 2460 | small | - | 0 | 128.0 |
| Eth1Block | `(fixed)` | 48 | 2,436 | 2440 | small | - | 0 | 4194304.0 |
| Eth1Data | `(fixed)` | 72 | 2,444 | 2468 | small | - | 0 | 4194304.0 |
| Ether | `(fixed)` | 8 | 2,488 | 2456 | small | - | 0 | 128.0 |
| ExecutionAddress | `(fixed)` | 20 | 2,460 | 2844 | small | - | 0 | 4194304.0 |
| ExecutionBranch | `(fixed)` | 128 | 3,320 | 3180 | small | - | 0 | 29.3 |
| ExecutionPayloadHeader | `extra_data.bytes` | 616 | 2,856 | 2508 | small | - | 0 | 11.8 |
| FinalityBranch | `(fixed)` | 224 | 2,076 | 2476 | small | - | 0 | 4194304.0 |
| FixedTestStruct | `(fixed)` | 13 | 2,456 | 2452 | small | - | 0 | 1024.0 |
| Fork | `(fixed)` | 16 | 2,488 | 2464 | small | - | 0 | 170.7 |
| ForkData | `(fixed)` | 36 | 2,480 | 2480 | small | - | 0 | 4194304.0 |
| ForkDigest | `(fixed)` | 4 | 2,544 | - | small | - | 0 | 4194304.0 |
| G1Point | `(fixed)` | 48 | 2,436 | 2428 | small | - | 0 | 512.0 |
| G2Point | `(fixed)` | 96 | 2,476 | 2504 | small | - | 0 | 4194304.0 |
| Gwei | `(fixed)` | 8 | 2,476 | 2492 | small | - | 0 | 4194304.0 |
| Hash32 | `(fixed)` | 32 | 2,080 | 2492 | small | - | 0 | 4194304.0 |
| HistoricalSummary | `(fixed)` | 64 | 2,472 | 2408 | small | - | 0 | 64.0 |
| KZGCommitment | `(fixed)` | 48 | 3,524 | 2820 | small | - | 0 | 5.8 |
| KZGProof | `(fixed)` | 48 | 2,844 | 2876 | small | - | 0 | 4194304.0 |
| LightClientBootstrap | `header.execution.extra_data.bytes` | 25,680 | 3,960 | 3188 | small | - | 0 | 5.3 |
| LightClientFinalityUpdate | `attested_header.execution.extra_data.bytes` | 2,088 | 4,104 | 2820 | small | - | 0 | 3.2 |
| LightClientHeader | `execution.extra_data.bytes` | 860 | 3,544 | 2736 | small | - | 0 | 5.1 |
| LightClientOptimisticUpdate | `attested_header.execution.extra_data.bytes` | 1,032 | 3,620 | 2852 | small | - | 0 | 5.3 |
| LightClientUpdate | `attested_header.execution.extra_data.bytes` | 26,904 | 4,344 | 3532 | small | - | 0 | 5.0 |
| MatrixEntry | `(fixed)` | 2,112 | 2,860 | 2836 | small | - | 0 | 170.7 |
| NextSyncCommitteeBranch | `(fixed)` | 192 | 2,488 | 2500 | small | - | 0 | 4194304.0 |
| NodeID | `(fixed)` | 32 | 2,512 | 2488 | small | - | 0 | 170.7 |
| ParticipationFlags | `(fixed)` | 1 | 2,408 | - | small | - | 0 | 4194304.0 |
| PayloadId | `(fixed)` | 8 | 2,852 | - | small | - | 0 | 4194304.0 |
| PendingAttestation | `aggregation_bits.bits` | 405 | 2,496 | 2480 | small | - | 0 | 256.0 |
| PendingConsolidation | `(fixed)` | 16 | 2,488 | 2076 | small | - | 0 | 9.9 |
| PendingDeposit | `(fixed)` | 192 | 2,464 | 2456 | small | - | 0 | 512.0 |
| PendingPartialWithdrawal | `(fixed)` | 24 | 2,488 | 2488 | small | - | 0 | 4194304.0 |
| PowBlock | `(fixed)` | 96 | 2,456 | 2488 | small | - | 0 | 4194304.0 |
| ProgressiveSingleFieldContainerTestStruct | `(fixed)` | 1 | 2,532 | - | small | - | 0 | 4194304.0 |
| ProposerSlashing | `(fixed)` | 416 | 2,484 | 2468 | small | - | 0 | 256.0 |
| Root | `(fixed)` | 32 | 2,504 | 2472 | small | - | 0 | 128.0 |
| RowIndex | `(fixed)` | 8 | 2,844 | - | small | - | 0 | 4194304.0 |
| SignedAggregateAndProof | `message.aggregate.aggregation_bits.bits` | 16,829 | 2,848 | 2864 | small | - | 0 | 4194304.0 |
| SignedBLSToExecutionChange | `(fixed)` | 172 | 2,508 | 2496 | small | - | 0 | 341.3 |
| SignedBeaconBlockHeader | `(fixed)` | 208 | 2,436 | 2484 | small | - | 0 | 4194304.0 |
| SignedContributionAndProof | `(fixed)` | 360 | 2,484 | 2468 | small | - | 0 | 256.0 |
| SignedVoluntaryExit | `(fixed)` | 112 | 2,456 | 2072 | small | - | 0 | 10.7 |
| SigningData | `(fixed)` | 64 | 2,480 | 2544 | small | - | 0 | 4194304.0 |
| SingleAttestation | `(fixed)` | 240 | 2,516 | 2464 | small | - | 0 | 78.8 |
| SingleFieldTestStruct | `(fixed)` | 1 | 2,488 | - | small | - | 0 | 4194304.0 |
| Slot | `(fixed)` | 8 | 2,456 | 2508 | small | - | 0 | 4194304.0 |
| SmallTestStruct | `(fixed)` | 4 | 2,456 | - | small | - | 0 | 4194304.0 |
| SubnetID | `(fixed)` | 8 | 2,464 | 2488 | small | - | 0 | 4194304.0 |
| SyncAggregate | `(fixed)` | 160 | 2,488 | 2440 | small | - | 0 | 85.3 |
| SyncAggregatorSelectionData | `(fixed)` | 16 | 2,012 | 2520 | small | - | 0 | 4194304.0 |
| SyncCommittee | `(fixed)` | 24,624 | 2,848 | 2840 | small | - | 0 | 512.0 |
| SyncCommitteeContribution | `(fixed)` | 160 | 2,436 | 2432 | small | - | 0 | 1024.0 |
| SyncCommitteeMessage | `(fixed)` | 144 | 2,468 | 2388 | small | - | 0 | 51.2 |
| Validator | `(fixed)` | 121 | 2,456 | 2084 | small | - | 0 | 11.0 |
| ValidatorIndex | `(fixed)` | 8 | 2,012 | - | small | - | 0 | 4194304.0 |
| VarTestStruct | `f_B.[]` | 1,033 | 2,504 | 2456 | small | - | 0 | 85.3 |
| Version | `(fixed)` | 4 | 2,472 | - | small | - | 0 | 4194304.0 |
| VersionedHash | `(fixed)` | 32 | 2,476 | 2452 | small | - | 0 | 170.7 |
| VoluntaryExit | `(fixed)` | 16 | 2,488 | 2472 | small | - | 0 | 256.0 |
| Withdrawal | `(fixed)` | 44 | 2,424 | 2508 | small | - | 0 | 4194304.0 |
| WithdrawalIndex | `(fixed)` | 8 | 2,856 | - | small | - | 0 | 4194304.0 |
| WithdrawalRequest | `(fixed)` | 76 | 2,508 | 2464 | small | - | 0 | 93.1 |
| bitlist_1 | `bits` | 1 | 2,076 | 2488 | small | - | 0 | 4194304.0 |
| bitlist_15 | `bits` | 2 | 2,420 | 2504 | small | - | 0 | 4194304.0 |
| bitlist_16 | `bits` | 3 | 2,080 | 2436 | small | - | 0 | 4194304.0 |
| bitlist_17 | `bits` | 3 | 2,472 | 2456 | small | - | 0 | 256.0 |
| bitlist_2 | `bits` | 1 | 2,016 | 2452 | small | - | 0 | 4194304.0 |
| bitlist_3 | `bits` | 1 | 2,508 | - | small | - | 0 | 4194304.0 |
| bitlist_31 | `bits` | 3 | 2,456 | 2440 | small | - | 0 | 256.0 |
| bitlist_32 | `bits` | 5 | 2,424 | 2504 | small | - | 0 | 4194304.0 |
| bitlist_33 | `bits` | 5 | 2,476 | - | small | - | 0 | 4194304.0 |
| bitlist_4 | `bits` | 1 | 2,508 | - | small | - | 0 | 4194304.0 |
| bitlist_5 | `bits` | 1 | 2,084 | - | small | - | 0 | 4194304.0 |
| bitlist_511 | `bits` | 33 | 2,424 | - | small | - | 0 | 4194304.0 |
| bitlist_512 | `bits` | 65 | 2,424 | - | small | - | 0 | 4194304.0 |
| bitlist_513 | `bits` | 65 | 2,488 | - | small | - | 0 | 4194304.0 |
| bitlist_6 | `bits` | 1 | 2,476 | - | small | - | 0 | 4194304.0 |
| bitlist_7 | `bits` | 1 | 2,476 | - | small | - | 0 | 4194304.0 |
| bitlist_8 | `bits` | 2 | 2,464 | 2416 | small | - | 0 | 85.3 |
| bitlist_9 | `bits` | 2 | 2,448 | 2400 | small | - | 0 | 85.3 |
| bitvector_1 | `(fixed)` | 1 | 2,076 | - | small | - | 0 | 4194304.0 |
| bitvector_15 | `(fixed)` | 2 | 2,456 | 2412 | small | - | 0 | 93.1 |
| bitvector_16 | `(fixed)` | 2 | 2,448 | 2464 | small | - | 0 | 4194304.0 |
| bitvector_17 | `(fixed)` | 3 | 2,436 | 2448 | small | - | 0 | 4194304.0 |
| bitvector_2 | `(fixed)` | 1 | 2,448 | - | small | - | 0 | 4194304.0 |
| bitvector_3 | `(fixed)` | 1 | 2,484 | - | small | - | 0 | 4194304.0 |
| bitvector_31 | `(fixed)` | 4 | 2,452 | 2068 | small | - | 0 | 10.7 |
| bitvector_32 | `(fixed)` | 4 | 2,436 | 2104 | small | - | 0 | 12.3 |
| bitvector_33 | `(fixed)` | 5 | 2,372 | 2436 | small | - | 0 | 4194304.0 |
| bitvector_4 | `(fixed)` | 1 | 2,400 | - | small | - | 0 | 4194304.0 |
| bitvector_5 | `(fixed)` | 1 | 2,464 | - | small | - | 0 | 4194304.0 |
| bitvector_511 | `(fixed)` | 64 | 2,436 | 2388 | small | - | 0 | 85.3 |
| bitvector_512 | `(fixed)` | 64 | 2,412 | 2452 | small | - | 0 | 4194304.0 |
| bitvector_513 | `(fixed)` | 65 | 2,452 | 2444 | small | - | 0 | 512.0 |
| bitvector_6 | `(fixed)` | 1 | 2,460 | - | small | - | 0 | 4194304.0 |
| bitvector_7 | `(fixed)` | 1 | 2,476 | - | small | - | 0 | 4194304.0 |
| bitvector_8 | `(fixed)` | 1 | 2,464 | - | small | - | 0 | 4194304.0 |
| bitvector_9 | `(fixed)` | 2 | 2,492 | 2496 | small | - | 0 | 4194304.0 |
| boolean | `(fixed)` | 1 | 2,412 | - | small | - | 0 | 4194304.0 |
| uint128 | `(fixed)` | 16 | 2,468 | 2484 | small | - | 0 | 4194304.0 |
| uint16 | `(fixed)` | 2 | 2,452 | - | small | - | 0 | 4194304.0 |
| uint256 | `(fixed)` | 32 | 2,444 | 2476 | small | - | 0 | 4194304.0 |
| uint32 | `(fixed)` | 4 | 2,444 | 2460 | small | - | 0 | 4194304.0 |
| uint64 | `(fixed)` | 8 | 2,444 | 2408 | small | - | 0 | 113.8 |
| uint8 | `(fixed)` | 1 | 2,460 | - | small | - | 0 | 4194304.0 |
| vec_bool_1 | `(fixed)` | 1 | 2,452 | - | small | - | 0 | 4194304.0 |
| vec_bool_16 | `(fixed)` | 16 | 2,500 | 2548 | small | - | 0 | 4194304.0 |
| vec_bool_2 | `(fixed)` | 2 | 2,496 | 2484 | small | - | 0 | 341.3 |
| vec_bool_3 | `(fixed)` | 3 | 2,484 | - | small | - | 0 | 4194304.0 |
| vec_bool_31 | `(fixed)` | 31 | 2,484 | 2436 | small | - | 0 | 85.3 |
| vec_bool_4 | `(fixed)` | 4 | 2,472 | 2516 | small | - | 0 | 4194304.0 |
| vec_bool_5 | `(fixed)` | 5 | 2,464 | 2080 | small | - | 0 | 10.7 |
| vec_bool_512 | `(fixed)` | 512 | 2,440 | 2468 | small | - | 0 | 4194304.0 |
| vec_bool_513 | `(fixed)` | 513 | 2,516 | 2504 | small | - | 0 | 341.3 |
| vec_bool_8 | `(fixed)` | 8 | 2,468 | 2492 | small | - | 0 | 4194304.0 |
| vec_uint128_1 | `(fixed)` | 16 | 2,016 | - | small | - | 0 | 4194304.0 |
| vec_uint128_16 | `(fixed)` | 256 | 2,460 | 2460 | small | - | 0 | 4194304.0 |
| vec_uint128_2 | `(fixed)` | 32 | 2,460 | 2476 | small | - | 0 | 4194304.0 |
| vec_uint128_3 | `(fixed)` | 48 | 2,508 | 2412 | small | - | 0 | 42.7 |
| vec_uint128_31 | `(fixed)` | 496 | 2,476 | 2508 | small | - | 0 | 4194304.0 |
| vec_uint128_4 | `(fixed)` | 64 | 2,436 | 2396 | small | - | 0 | 102.4 |
| vec_uint128_5 | `(fixed)` | 80 | 2,512 | 2088 | small | - | 0 | 9.7 |
| vec_uint128_512 | `(fixed)` | 8,192 | 2,460 | 2844 | small | - | 0 | 4194304.0 |
| vec_uint128_513 | `(fixed)` | 8,208 | 2,796 | 2820 | small | - | 0 | 4194304.0 |
| vec_uint128_8 | `(fixed)` | 128 | 2,512 | 2480 | small | - | 0 | 128.0 |
| vec_uint16_1 | `(fixed)` | 2 | 2,088 | - | small | - | 0 | 4194304.0 |
| vec_uint16_16 | `(fixed)` | 32 | 2,428 | 2496 | small | - | 0 | 4194304.0 |
| vec_uint16_2 | `(fixed)` | 4 | 2,488 | - | small | - | 0 | 4194304.0 |
| vec_uint16_3 | `(fixed)` | 6 | 2,376 | 2456 | small | - | 0 | 4194304.0 |
| vec_uint16_31 | `(fixed)` | 62 | 2,456 | 2484 | small | - | 0 | 4194304.0 |
| vec_uint16_4 | `(fixed)` | 8 | 2,472 | 2432 | small | - | 0 | 102.4 |
| vec_uint16_5 | `(fixed)` | 10 | 2,420 | 2424 | small | - | 0 | 4194304.0 |
| vec_uint16_512 | `(fixed)` | 1,024 | 2,456 | 2424 | small | - | 0 | 128.0 |
| vec_uint16_513 | `(fixed)` | 1,026 | 2,088 | 2472 | small | - | 0 | 4194304.0 |
| vec_uint16_8 | `(fixed)` | 16 | 2,456 | 2456 | small | - | 0 | 4194304.0 |
| vec_uint256_1 | `(fixed)` | 32 | 2,484 | - | small | - | 0 | 4194304.0 |
| vec_uint256_16 | `(fixed)` | 512 | 2,516 | 2392 | small | - | 0 | 33.0 |
| vec_uint256_2 | `(fixed)` | 64 | 2,468 | 2484 | small | - | 0 | 4194304.0 |
| vec_uint256_3 | `(fixed)` | 96 | 2,088 | 2088 | small | - | 0 | 4194304.0 |
| vec_uint256_31 | `(fixed)` | 992 | 2,484 | 2468 | small | - | 0 | 256.0 |
| vec_uint256_4 | `(fixed)` | 128 | 2,080 | 2444 | small | - | 0 | 4194304.0 |
| vec_uint256_5 | `(fixed)` | 160 | 2,080 | 2468 | small | - | 0 | 4194304.0 |
| vec_uint256_512 | `(fixed)` | 16,384 | 2,480 | 2884 | small | - | 0 | 4194304.0 |
| vec_uint256_513 | `(fixed)` | 16,416 | 2,400 | 2852 | small | - | 0 | 4194304.0 |
| vec_uint256_8 | `(fixed)` | 256 | 2,088 | 2436 | small | - | 0 | 4194304.0 |
| vec_uint32_1 | `(fixed)` | 4 | 2,432 | - | small | - | 0 | 4194304.0 |
| vec_uint32_16 | `(fixed)` | 64 | 2,484 | 2468 | small | - | 0 | 256.0 |
| vec_uint32_2 | `(fixed)` | 8 | 2,404 | 2484 | small | - | 0 | 4194304.0 |
| vec_uint32_3 | `(fixed)` | 12 | 2,464 | - | small | - | 0 | 4194304.0 |
| vec_uint32_31 | `(fixed)` | 124 | 2,076 | 2468 | small | - | 0 | 4194304.0 |
| vec_uint32_4 | `(fixed)` | 16 | 2,464 | 2464 | small | - | 0 | 4194304.0 |
| vec_uint32_5 | `(fixed)` | 20 | 2,400 | 2480 | small | - | 0 | 4194304.0 |
| vec_uint32_512 | `(fixed)` | 2,048 | 2,076 | 2088 | small | - | 0 | 4194304.0 |
| vec_uint32_513 | `(fixed)` | 2,052 | 2,488 | 2464 | small | - | 0 | 170.7 |
| vec_uint32_8 | `(fixed)` | 32 | 2,088 | 2480 | small | - | 0 | 4194304.0 |
| vec_uint64_1 | `(fixed)` | 8 | 2,476 | - | small | - | 0 | 4194304.0 |
| vec_uint64_16 | `(fixed)` | 128 | 2,432 | 2476 | small | - | 0 | 4194304.0 |
| vec_uint64_2 | `(fixed)` | 16 | 2,016 | 2408 | small | - | 0 | 4194304.0 |
| vec_uint64_3 | `(fixed)` | 24 | 2,456 | 2508 | small | - | 0 | 4194304.0 |
| vec_uint64_31 | `(fixed)` | 248 | 2,460 | 2444 | small | - | 0 | 256.0 |
| vec_uint64_4 | `(fixed)` | 32 | 2,460 | 2444 | small | - | 0 | 256.0 |
| vec_uint64_5 | `(fixed)` | 40 | 2,476 | 2076 | small | - | 0 | 10.2 |
| vec_uint64_512 | `(fixed)` | 4,096 | 2,508 | 2452 | small | - | 0 | 73.1 |
| vec_uint64_513 | `(fixed)` | 4,104 | 2,488 | 2460 | small | - | 0 | 146.3 |
| vec_uint64_8 | `(fixed)` | 64 | 2,456 | 2476 | small | - | 0 | 4194304.0 |
| vec_uint8_1 | `(fixed)` | 1 | 2,428 | - | small | - | 0 | 4194304.0 |
| vec_uint8_16 | `(fixed)` | 16 | 2,480 | 2460 | small | - | 0 | 204.8 |
| vec_uint8_2 | `(fixed)` | 2 | 2,496 | 2496 | small | - | 0 | 4194304.0 |
| vec_uint8_3 | `(fixed)` | 3 | 2,480 | 2496 | small | - | 0 | 4194304.0 |
| vec_uint8_31 | `(fixed)` | 31 | 2,512 | 2512 | small | - | 0 | 4194304.0 |
| vec_uint8_4 | `(fixed)` | 4 | 2,512 | 2480 | small | - | 0 | 128.0 |
| vec_uint8_5 | `(fixed)` | 5 | 2,464 | 2448 | small | - | 0 | 256.0 |
| vec_uint8_512 | `(fixed)` | 512 | 2,464 | 2452 | small | - | 0 | 341.3 |
| vec_uint8_513 | `(fixed)` | 513 | 2,076 | 2464 | small | - | 0 | 4194304.0 |
| vec_uint8_8 | `(fixed)` | 8 | 2,512 | 2440 | small | - | 0 | 56.9 |

Measured shapes in all: 438; above their bound: 0.
