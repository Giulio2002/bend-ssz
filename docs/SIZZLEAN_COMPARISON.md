# SizzLean comparison and root-domain correction

Reviewed source: etheorem/etheorem commit
`d30e899c2dabeec84789b3b500fe44e06994cf61`, checked out read-only at
`/Users/monkeair/work/ssz-lean-review`. This is source inspection, not a fresh
Lean build or a complete independent audit of SizzLean.

The 13 September announcement is useful context, but the actual theorem types
and proof ledger are more precise than the phrase “end to end.”

## Does it have our root-domain restriction?

Not in the fresh cached-root theorem inspected.
`SizzLean/Proofs/Merkle/CachedSSZ.lean:64` states that the root of
`CachedSSZ.ofValue H v` equals `SSZType.hashTreeRoot H shape (toRepr v)`,
assuming a Hasher, representation instance and `BasicSupported shape`.
There is no `EncodedFits` premise. Composite root construction recurses over
child roots directly. Its theorem explicitly excludes hash-consing/FastBox
runtime optimization from that proof scope.

Their codec theorems do have `EncodedFits s x`, defined in
`Spec/MaxByteLength.lean:102` as serialized size below `MAX_LENGTH = 2^32`.
That is an encoding precondition, separated from the fresh-root theorem.
Our root relation instead includes existence of a full normative encoding and
our public root implementation gates on codec validity. We should separate
these domains rather than claim they coincide without proof.

## Other differences

| Topic | SizzLean inspected source | Current Bend snapshot |
|---|---|---|
| Codec properties | Roundtrip, injectivity, schema-derived size bound, under stated guards | Independent exact encoding equality; decoder soundness/completeness, uniqueness and exact rejection |
| Decoder canonicality | Ledger explicitly says injectivity does not establish it; invalid vectors provide empirical evidence | Public theorem covers exact canonical image and rejection |
| Root theorem | Fresh cached-root agreement on BasicSupported, no EncodedFits | Root relation and totality require serialization-domain conditions |
| Extended SSZ forms | Unions, progressive lists/bitlists/containers and compatible unions deliberately excluded | Implemented and covered by pinned generic fixtures/proofs |
| Crypto trust | Native SHA uses three stated FFI-equivalence axioms; pure SHA model separately proved | Actual Bend SHA refines vendored FIPS model through checked proofs |
| Execution trust | Compiler/runtime, implemented_by cache substitutions and hash-consing scope qualifications | Compiler/Bun/loader/transport and machine/resource bounds |
| Reference vectors | README pins v1.6.0-beta.0, both presets/multiple forks, explicitly skipped forms | v1.6.1: mainnet Fulu and complete selected generic inventory |

Neither library's headline should be interpreted as a proof of every emitted
machine instruction, compiler behavior, arbitrary runtime optimization or
cryptographic assumption. Their stated native FFI and cache boundaries are not
an acceptable replacement for the user's already-proved Bend SHA.

## Can we copy it?

The package declares **LGPL-3.0-only** in its lakefile and refers to the root
LICENSE. Reusing/porting its source is possible under that license's terms,
including required notices and source obligations when distributing covered
work; it is not an MIT/public-domain copy-and-relicense option. No SizzLean source
has been copied into the Bend implementation by this comparison.

Lean proof terms cannot simply be pasted into Bend or cited as if they prove
Bend's implementation. Reuse the design separation and proof decomposition, then
implement and check Bend proofs for our actual APIs. If any source is actually
ported, retain explicit provenance/license notices and review that distribution's
license requirements. The preferred immediate change is an independent
implementation against the pinned Ethereum SSZ reference.

## Correction acceptance contract

1. Define independent structural/type-value validity separately from successful
   whole-object serialization. Keep uint256 mixed-length requirements explicit
   where the normative operation needs them.
2. Define Merkleization semantics without requiring whole-parent encoding to
   exist; preserve the normative type bounds, child roots, padding and mixing.
3. Make actual public roots implement that domain. Do not merely drop a theorem
   premise, rename a restrictive predicate, or validate a shadow implementation.
4. Prove root soundness, completeness, exact 32-byte output, full stated-domain
   totality and relevant rejection, composed through all 109 Fulu names.
5. Preserve all serialization/decoding/rejection guarantees and prior root results
   on the serializable domain. Explicitly identify the legitimate strengthening
   of the old root contract rather than pretending its statement is unchanged.
6. Supply symbolic evidence that the new root domain is strictly broader than
   the whole-parent-encoding domain for an appropriate composite shape. Do not
   allocate gigabytes just to demonstrate the issue. Merely small-fixture tests
   cannot settle this mathematical domain question.
7. Recheck all proof roots with zero unsafe annotations and all 5,440 official
   cases. Obtain independent semantic review of the changed specification.
8. Initial sequencing held publication/research for correction. The user subsequently
   authorized publishing this current qualified snapshot and starting sequential
   deserialization research now. Root-domain correction remains separate; any later
   integration requires fresh full acceptance and review.

Source links (pinned commit):
- https://github.com/etheorem/etheorem/blob/d30e899c2dabeec84789b3b500fe44e06994cf61/packages/SizzLean/SizzLean/Proofs/Merkle/CachedSSZ.lean
- https://github.com/etheorem/etheorem/blob/d30e899c2dabeec84789b3b500fe44e06994cf61/packages/SizzLean/SizzLean/Spec/MaxByteLength.lean
- https://github.com/etheorem/etheorem/blob/d30e899c2dabeec84789b3b500fe44e06994cf61/packages/SizzLean/docs/PROOF_LEDGER.md
- https://github.com/etheorem/etheorem/blob/d30e899c2dabeec84789b3b500fe44e06994cf61/packages/SizzLean/README.md
- https://github.com/etheorem/etheorem/blob/d30e899c2dabeec84789b3b500fe44e06994cf61/packages/SizzLean/lakefile.lean
