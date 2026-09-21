# Independent benchmark calibration

The old harness used Bend's calibrated repetition count for both sides.
HistoricalBatch Go decoding spent over 14 minutes in one 5-million-operation
sample. The operator preserved the incomplete run and stopped only its process
tree. The 513 completed rows had no threshold violations; this is NOT a full
acceptance report. Its source manifest predates the calibration-only fix.

The new harness independently calibrates each side toward 250ms, records both
counts, retains at least five alternating samples, and normalizes by each
side's actual count. Workloads, reference code, native timed operations,
correctness checks and frozen acceptance thresholds are unchanged. Bend's
validated-view decode and Go's object materialization remain different work.

Run the deterministic regression check from the repository root:
`python3 snapshot-evidence/independent-calibration/check.py`

The real native smoke uses the existing binaries from the interrupted run and
HistoricalBatch.small-fixture.ssz, with five samples on each side. It confirms
calibration execution, not overall acceptance or a universal speed claim.
A full fresh performance run remains required.
