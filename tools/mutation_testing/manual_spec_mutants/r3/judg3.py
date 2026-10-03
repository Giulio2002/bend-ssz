#!/usr/bin/env python3
"""judg3.py OUT.json: the hand-written judgments of the round-3 survivors (fault id without the 'r3-' prefix -> verdict, counter-example,
reachability, evidence). Verdicts: critical | gap-unreachable | equivalent | unjudged. 'probe N' = a line of tools/.../r3/probes/*.bend
(SSZ_CASE N) that differs from the unmutated build; 'regress N' = tools/crash_hunt/regress.sh case N (a test, not a proof)."""
import json, sys

J = {}


def add(ids, verdict, counterexample, reachability, evidence):
    for i in ids.split():
        J['r3-' + i] = dict(verdict=verdict, counterexample=counterexample, reachability=reachability, evidence=evidence)


CLAIM = ('reachable only through the public record constructor O.Words{ws, n} / O.Bits (a claimed length over tiny storage; the API\'s own '
         'builders cannot reach it without 4 GiB of data); same class as CH-04 / R2-01 which the maintainers fixed with laws')

# ---- area 1: clean-chunk test, clean copy, tight storage (obj.bend) ----
add('w01-clean-chunk/07 w02-partial-word/01 w02-partial-word/02 w02-partial-word/03 w02-partial-word/08 w03-dispatch/01 w03-dispatch/02 w03-dispatch/05 w04-copy/05 w04-copy/06 w04-copy/07',
    'equivalent',
    'none: the fault only makes the clean test answer unclean more often (or the copy keeps junk the value cannot hold), and the unclean path is the clean copy, whose root is the root of the bytes',
    'O.words_root / O.words_root_prog (called by X_hash_tree_root of every ByteList / ByteVector / packed list)',
    'p3_bytes2 sweep (45 objects: n = 1,5,33,36,40,58,100 with junk at every word of the last chunk, tight storage) prints the baseline roots; regress 26 and 30 also equal. Only performance changes (the slow copy path is taken). '
    'A false "unclean" is value-neutral; only a false "clean" can change a root (those faults are killed, see w01/05, w02/05..07, w03/03..06).')
add('w02-partial-word/04', 'equivalent',
    'none for a valid object: the partial word is unclean only when the length is not a multiple of 4 and a byte past the length is set, which X_valid (O.words_ok tail_zero) refuses',
    'X_hash_tree_root precondition is X_valid (docs/API_CONTRACTS.md)', 'p3_bytes2 case 502..507 (junk past the partial word) equal; the value-relevant junk is in the words AFTER the partial word and is still detected')
add('w02-partial-word/06 w02-partial-word/07', 'critical',
    'bytelist_256: O.Words{ws, 40} with 0xDEADBEEF in word 12 (past the data, inside the last chunk): X_valid = True; X_hash_tree_root differs from the root of the same 40 bytes in clean storage (p3_bytes2 case 110..113 etc., 8..12 differ)',
    'public record constructor O.Words (docs/CRASH_HUNT.md R2-02 b: this is exactly the defect the crash-fix3 clean-chunk test fixed); called from every packed root: bl256_root -> O.words_root -> wr_size -> wr_cap -> wcn_k',
    'survives every proof root that mentions wcn_k / e32 (words_canon, words_cap, pbits_obj, prog_list: the laws are over well-formed objects with zero storage) and regress.sh (case 30 tests one junk position); p3_bytes2 KILLED (cases 110-115, 309-315, 425-431)')
add('w03-dispatch/03 w03-dispatch/04 w03-dispatch/06', 'critical',
    'bytelist_256: O.Words{Array.new(U32, 1n, 0) with byte 65, 5} (tight storage: 2 words for 5 bytes): X_valid = True, X_hash_tree_root = the root of the clamped (zero) storage instead of the root of the 5 bytes (p3_bytes2 cases 3, 4, 5: roots differ)',
    'public record constructor; X_hash_tree_root of bytelist_256 -> O.words_root -> wr_fit -> wr_slow (CH-11 / R2-02 c)',
    'no proof pins the tight-storage dispatch of the binary root (all roots checked pass); regress case 26 covers only the progressive variant (regress_w: SURVIVED for these three); p3_bytes2 KILLED')
add('w04-copy/01 w04-copy/02 w04-copy/03 w04-copy/04 w05-prog/02 w05-prog/04', 'critical',
    'bytelist_256 / proglist_uint8: a valid tight-storage or junk-holding object (cases 3, 4, 5, 110-115 of the probes) hashes to a wrong root: the clean copy loses the last word, copies junk, shifts words',
    'public record constructor; O.words_copy / O.wr_clean / O.wrp_clean',
    'every proof root passes (the copy path is outside the representation invariant of the laws); caught only by regress.sh cases 26 / 30 (a test, not a proof) and by the probes')
add('w05-prog/02', 'critical',
    'proglist_uint8: tight storage counts as uncovered: the root is the clamped root (probe prog cases 3, 5 differ)',
    'public record constructor', 'regress 26 KILLED; proofs pass')

# ---- area 3 ----
add('d01-checked-storage/01', 'equivalent', 'none: uint256 is 32 bytes, floor(32 / 4) = ceil(32 / 4)',
    'uint256_decode_checked', 'p3_decode: identical on all cases; the rounding only matters for sizes not a multiple of 4')
add('d01-checked-storage/02 d01-checked-storage/04', 'critical',
    'uint256_decode_checked(B.Buf{Array.new(U32, 0n, 0), 32}, 32) (a 1-word array claiming 32 bytes): unmutated None, mutated Some (probe decode cases 2, 3)',
    'public constructor B.Buf (a lying size field, R2-04); decode_checked is the documented entry for bytes of unknown origin',
    'the only laws on the storage test are for Checkpoint and proglist_uint8 (crash_fix_laws); the other 204 copies of the generated test are unpinned; the generator emits the same text for every type, so this is a per-copy coverage gap, not a generator bug')
add('d01-checked-storage/03 d01-checked-storage/05', 'critical',
    'uint256_decode_checked(B.alloc(32), 32) answers None (probe decode cases 1, 8) / bitvector_9_decode_checked(B.alloc(2), 2) answers None (cases 4, 6): the checked entry refuses honest buffers',
    'public: any caller of X_decode_checked(buf, B.size(buf)) on a uint256 / Bitvector[9]',
    'no law on these types; same remark as d01/02: the generator text is shared, the copy is unpinned')
add('g01-append-guard/03 g01-append-guard/05 g01-append-guard/06 g01-append-guard/12 g01-append-guard/13', 'critical',
    'append on a claimed count at the guard boundary: ProgressiveList[uint32] claiming 1073741816 elements (probe guards case 1: ok=1 len=1073741817 instead of refused), ProgressiveList[boolean] claiming 2^32 - 32 (case 2), ProgressiveList[SmallTestStruct] / [ProgressiveVarTestStruct] claiming 2^32 - 1 (cases 7, last: ok=1, len wraps to 0)',
    CLAIM, 'the R2-01 laws (pl_u32_append_max_refused etc.) test one count far above the guard, so any guard constant between the guard and that count survives; a law at guard - 1 / guard exists only for ProgressiveList[uint8]')
add('g01-append-guard/14', 'gap-unreachable',
    'ProgressiveBitlist append refused at n = 2^32 - 2 (a legal position)', 'needs 2^32 - 2 bits (512 MiB) or a claim; the effect is a refusal at the last legal position only',
    'regress 6 (n = 2^32 - 1) passes; not probed (the unmutated append would allocate 512 MiB)')
add('p05-fulu-field-validity/07 p01-words-ok-params/06', 'critical',
    'v8192_u64_valid(O.Words{Array.new(U32, 1n, 0), 8}) = True (a Vector[uint64, 8192] of 8 bytes is valid; probe misc case 16) / v65536_b32_valid of 32 bytes = True (probe last case 1)',
    'public record constructor + public X_valid (the documented precondition of X_hash_tree_root and of the setters of BeaconState fields)',
    'the validity laws of proofs/slop/validity pin one invalid shape per field (storage too small / one-word); the length-below-vector-size shape is unpinned')
add('p04-box-absent/03 p04-box-absent/06 p04-box-absent/09', 'critical',
    'the CH-12 defect again, in the copy of another type: AttesterSlashing_serialize(AttesterSlashing{BNone, default}) returns ok = 1 with 236 bytes (probe boxes cases 1, 2); BeaconBlockBody with an absent attestations / attester_slashings element returns ok = 1 (cases 4, 6)',
    'public constructor O.BNone{} (public type O.Boxed) + public X_serialize', 'regress 27 / 28 pin the AttesterSlashing_1 / _2 shapes only (p04/03 killed by regress, 06 and 09 not); proofs pass')
add('p04-box-absent/04', 'critical',
    'AttesterSlashing_valid(AttesterSlashing{BNone, default}) = True (probe boxes case 7)', 'public X_valid', 'regress does not call valid; proofs pass')
add('p04-box-absent/07', 'critical',
    'l8_Attestation_valid(Seq{fill(0n), 1}) = True: a list claiming one absent element is valid (probe last case 2); X_serialize of a container holding it still refuses through the checked writer',
    'public X_valid of the list and of every container that embeds it', 'redundant with the checked writer for serialize; the predicate itself lies')
add('p04-box-absent/08', 'critical',
    'BeaconBlockBody with one default Attestation serialises to different bytes (probe boxes case 5)', 'public X_serialize',
    'proof run UNJUDGED (checker stack overflow also with wide 600 s); probe KILLED')
add('p04-box-absent/15', 'critical',
    'serialize allocates O.out_new(n) with n = 2^31 + x for a value whose size pass is poisoned (CH-02: the refusal must come before the allocation): AttesterSlashing with an IndexedAttestation claiming attesting_indices of 8 bytes over a 1-word array',
    'public constructors; resource issue (2 GiB zero allocation per call), the output is still a refusal so no line-diff probe sees it',
    'equal output on every probed case (p3_boxes); not measured')
add('p04-box-absent/16 p04-box-absent/17', 'critical',
    'AttesterSlashing_serialize(AttesterSlashing{BNone, default}) returns ok = 1, 236 bytes (probe boxes cases 1, 2)', 'public',
    'regress 27 / 28 KILLED; proofs pass (the facade laws only reach valid values)')
add('p04-box-absent/18', 'gap-unreachable',
    'serialize refuses a valid value whose size is at least 2^30 bytes', 'needs a valid object of 1 GiB or more', 'not probed')
add('u01-union/08', 'critical',
    'CompatibleUnionABCA_serialize(c1{ProgressiveSingleListContainerTestStruct{O.Bits{[255], 3}}}) (bits 3..7 set past the 3 bits: invalid) returns ok = 1, 6 bytes (probe misc case 46)',
    'public constructors of the union arm and of O.Bits', 'proofs pass (union validity laws are by computation on one value per arm)')
add('u01-union/15', 'critical',
    'CompatibleUnionABCA_decode of bytes 00 05 (selector 0) returns Some (probe misc case 11), the specification says a Union[...] with selector 0 is invalid here', 'public X_decode',
    'proof run UNJUDGED (stack overflow, also wide); probe KILLED')
add('u01-union/16', 'equivalent',
    'none: with an empty window the selector read is the zero byte past the window, selector 0 is no arm, the answer is None',
    'X_decode (precondition size = B.size)', 'probe misc case 13 (Buf{[1], 0}) equal')

# ---- area 2 helpers, 4 ----
add('x02-bits-clear/02 x02-bits-clear/03 x02-bits-clear/04', 'critical',
    'Bitlist[9] / Bitlist[33] decode of ff 03 / ff ff 1f: the decoded object keeps the delimiter bit or clears the wrong bit: X_valid / X_serialize / X_hash_tree_root differ (probe misc cases 4-9, 19, 20)',
    'public X_decode of every Bitlist type (O.bits_in -> O.bits_clear -> O.clear_bit)',
    'no proof root that mentions clear_bit / clear_at fails (the var_bits_* laws state the decoded bits, not the cleared word); regress does not decode bit lists')
add('x03-bits-encode/04', 'critical', 'Bitlist[9] of 9 bits serialises to 1 byte instead of 2 (probe misc case 4)', 'public X_serialize (O.bits_size)',
    'proof run UNJUDGED (stack overflow, also wide)')
add('x07-bitlist-window/08', 'unjudged',
    'a list of variable-size elements whose first element is valid and whose second is invalid is accepted (and_pair or-ed)',
    'public X_decode of List[Attestation] / List[AttesterSlashing] (O.and_pair); List[Transaction] cannot reach it (every transaction is valid)',
    'proof run UNJUDGED; no probe built (needs two well-formed Attestation encodings of ~230 bytes)')
add('x08-cache/03', 'critical',
    'X_cache_at(arr, n, 32) accepts depth 32: dfill(1 + 32) allocates 2^33 digests (a hang / out-of-memory from a claim)', 'public X_cache_at (R2-03)',
    'regress 25 KILLED (pd_cache_at_huge_depth); proofs pass; not run in the probe (it would allocate)')
add('x09-unit/02 x09-unit/03', 'critical',
    'l16777216_b32_valid(O.Words{3 words, 16 bytes}) = True (a List[Bytes32] of 16 bytes, probe misc case 1) / l128_u16_valid(Words{.., 3}) = True (an odd byte count for uint16, case 2)',
    'public record constructor + X_valid', 'proofs pass (the unit_ok laws cover the 1, 4, 8-byte cases); regress does not reach')
add('x11-reads/01', 'critical',
    'uint16_decode of bytes 01 02 returns 1 instead of 513 (probe misc case 3)', 'public X_decode of uint16 and of every container with a uint16 field (O.rd_u16)',
    'every proof root passes: the uint16 facade laws are over values below 256 or the mask is not named; regress does not decode')
add('b01-beacon-state/03 b01-beacon-state/04 b01-beacon-state/07', 'critical',
    'FuluBeaconState: serialize(default) then decode answers None (probe state cases 1-3), the offsets are read at wrong positions / the window of a field is one byte short',
    'public X_decode', 'proof run UNJUDGED (checker stack overflow, also at the wide 600 s budget); probe KILLED')
add('b01-beacon-state/05', 'critical',
    'a BeaconState whose offsets are out of order (o3 < o2) is accepted: the wrapped window is validated as a huge list', 'public X_decode of hostile bytes',
    'proof run UNJUDGED; not probed (the accepted window would make the child scan 2^32 / 121 elements); by inspection the only test ordering o2 and o3')
add('b01-beacon-state/06', 'equivalent', 'none: every later offset must be at least o1 and at most len, so o1 > len is refused by the next test', 'X_decode',
    'implied by the following offset tests (o1 <= o2 <= len)')
add('b01-beacon-state/08', 'equivalent', 'none: the validity of a list of 32-byte elements depends only on the length of its window, which does not change', 'X_decode',
    'probe state: equal')
add('g02-cached-tree/01 g02-cached-tree/02 g02-cached-tree/03 g02-cached-tree/04 g02-cached-tree/05 g02-cached-tree/06 g02-cached-tree/07 g02-cached-tree/09 g02-cached-tree/10 g02-cached-tree/11', 'critical',
    'List[ProposerSlashing, 16] cached tree: X_cache(build(k)) then X_cached_root differs from the plain root (k = 1..16), a cached set / append leaves stale nodes, cget at i = n answers some, cset at i = n is accepted, the 16th cached append is refused (probe cache cases 1-16)',
    'public X_cache, X_cached_root, X_cset, X_capp, X_cget (honest objects, no constructor tricks)',
    'cached laws exist only for 11 of the 17 list types (proofs/obj/cached_*): List[ProposerSlashing, 16], List[Attestation, 8], List[Deposit, 16], List[Validator, 2^40], List[AttesterSlashing, 1] and the bytelist list have none; all proof roots pass; regress does not call the cache')
add('g02-cached-tree/08 g02-cached-tree/12', 'equivalent',
    'none: the root of an absent box is the zero chunk (bx_root BNone = D.zero()), so hashing a slot at i = n gives the stored zero; and a conservative dirty range only recomputes',
    'X_cached_root', 'probe cache: all 16 cases equal')
add('l01-fixed-elements/04 l01-fixed-elements/05', 'critical',
    'ExecutionPayload with three seeded Withdrawals serialises to different bytes (probe misc case 45)', 'public X_serialize', 'proof runs UNJUDGED (stack overflow, also wide); probe KILLED')
add('l01-fixed-elements/10', 'critical',
    'ExecutionPayload with withdrawals Seq{fill(5n), 17} (17 elements, limit 16, enough storage) serialises (ok = 1) instead of being refused (probe misc case 15)',
    'public constructor of the list record + X_serialize', 'proofs pass')

OUT = sys.argv[1]
json.dump(J, open(OUT, 'w'), indent=1)
print(len(J))
