# Operator: independent benchmark calibration

The 2026-09-21 benchmark was stopped by the operator after 513 completed rows,
with no over-limit rows, because calibration based solely on Bend forced Go
HistoricalBatch deserialize through five million repetitions per sample. One
Go sample exceeded 14 minutes; five samples and more fixtures would waste hours.
This was a harness scheduling issue, not a codec failure or a completed gate.
Partial evidence is retained in control/benchmark-calibration-20260921 outside
the workspace. It must not be presented as full acceptance.

benchmarks/run.py now calibrates each side separately toward 250 ms, retains
five or more alternating samples, divides each time by its own actual count,
and records both counts. The existing operations_per_sample field is Bend's;
reference_operations_per_sample is Go's. Reference code, workload bytes,
correctness checks, timers, consumption, thresholds and frozen gate unchanged.
Synthetic regression checks cover large speed asymmetry in both directions,
normalization, count selection and alternating order. Preserve source guards.

Rerun the full performance gate on stable source. Do not use the interrupted
rows as current acceptance. After performance, continue the universal compact
proof plan; read OPERATOR_ARRAY_PROOF_REUSE.md for the DSA array-proof lead.
