# Retired.
#
# This module proved element-count bounds for the list decoder budget. That decoder (`decode_go`, its fuel argument and
# the `sequence`/`accumulate`/`nat_gate` helpers) no longer exists: the public
# entry point is the packed cursor decoder in src/decode.bend, which recurses
# on the schema and the remaining element count and therefore needs no
# traversal budget at all.
#
# What replaced the content of this module:
#   proofs/cursor_leaves.bend, proofs/cursor_walk.bend, proofs/cursor_sound.bend
#     - soundness of the packed decoder (an accepted region re-encodes to itself)
#   proofs/complete_leaves.bend, proofs/complete_walk.bend,
#   proofs/complete_regions.bend, proofs/complete_step.bend,
#   proofs/complete_decode.bend
#     - completeness of the packed decoder, by the decoder's own recursion
#   proofs/encoding_domain.bend, proofs/packed_domain.bend,
#   proofs/decode_image.bend
#     - the public list entry point: the canonical image is accepted exactly
#
# The file is kept (empty) so that the module inventory in the evidence files
# keeps resolving; it declares no laws.
