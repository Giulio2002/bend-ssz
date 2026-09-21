# Operator review: reuse array foundations before re-deriving them

DSA has already implemented the exact foundation listed first in COMPACT_PROOF_PLAN:
`/Users/monkeair/work/published-snapshots/bend-collections/proofs/lib/array.bend`
(actual Base.Array new/get/swap/set, perfect mirror trees, slot denotation).
Inspect its u32/nat/list helpers and array2.bend as needed. Pinned source is
Giulio2002/bend-collections commit4f59da4; stock Bend2.0.16, installed Base hash
e149828ca05581f61d1b06cf2a7d1a744e394d29a4c8e1942e5062ecbf30f5b8.

Independent stock check of array.bend passes but reports2unsafe annotations.
Operator inspection of the unmodified v2.0.16 parser/CLI finds0explicit @unsafe
and2template instances, both imported LRU invariants.representation/identities.
Evidence: that repo's snapshot-evidence/template-annotation-audit.
Do NOT suppress this count or relax SSZ's zero-warning requirement. Inspect the
actual dependencies and adapt/extract the needed checked lemmas into a clean
SSZ proof foundation, preserving their propositions and actual Base connection.
Reuse is optional when genuinely unsuitable, but do not re-plan or re-derive
thousands of lines merely because the foundation was developed in another job.

The main missing objective is universal proof connection to the compact runtime,
not another pass of the legacy graph. Retain all existing good work, continue
remaining runtime/proof/performance gaps end-to-end. Existing case/gate passes
do not close COMPACT_PROOF_PLAN. No performance tradeoff for easier proofs.
Do not disturb an active stable-source benchmark; its final hashes must match.
