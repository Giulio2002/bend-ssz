#!/bin/bash
# run.sh [--corpus] PATCH...   (run on the ssz server, from a repository checkout: tools/mutation_testing/manual_spec_mutants/run.sh)
#   A: runner.py (proof side), results in $OUT/results.json
#   B: with --corpus, corpus.py: compile the mutated type's object program and run the differential corpus + official vectors
# Environment: TREE (default .), WORK (private trees, default /srv/ssz-optimization/agents/manualmut/work), OUT (default $WORK/../out),
#   JOBS (default 4, never more), CASES (cases.jsonl of tools/spec_audit/cases.py).
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
TREE=${TREE:-$(cd "$HERE/../../.." && pwd)}
WORK=${WORK:-/srv/ssz-optimization/agents/manualmut/work}
OUT=${OUT:-$WORK/../out}
mkdir -p "$OUT" "$WORK"
CORPUS=0; [ "${1:-}" = "--corpus" ] && { CORPUS=1; shift; }
python3 "$HERE/runner.py" --tree "$TREE" --work "$WORK" --out "$OUT/results.json" --jobs "${JOBS:-4}" "$@"
if [ "$CORPUS" = 1 ]; then
  python3 "$HERE/corpus.py" --tree "$TREE" --work "$WORK" --out "$OUT/corpus.json" --cases "${CASES:?CASES=cases.jsonl}" "$@"
fi
