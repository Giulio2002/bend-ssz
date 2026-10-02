#!/bin/bash
# tools/spec_audit/run_spec_cases.sh [JOBS] [LOGDIR] [GLOB]: check every generated spec-level proof by computation with
# tools/check.sh. Run from the repository root on the server. JOBS defaults to 2 (the server is shared: never more than 2 checks
# at a time, at nice 19) and the script refuses to start while the full-check lock is held (FULLCHECK_LOCK, default
# /srv/ssz-optimization/agents/.fullcheck.lock; set it empty to skip the test). GLOB selects files inside spec_cases (default *).
# Each file is checked under the checker's own caps with a 300 s timeout; the files are sized to check in under 120 s unloaded.
J=${1:-2}; L=${2:-/tmp/specaudit-spec-logs}; P=${3:-*}
LOCK=${FULLCHECK_LOCK-/srv/ssz-optimization/agents/.fullcheck.lock}
if [ -n "$LOCK" ] && [ -e "$LOCK" ] && ! flock -n "$LOCK" true; then echo "run_spec_cases: the full check holds $LOCK; not starting" >&2; exit 3; fi
mkdir -p "$L"; : > "$L/results.tsv"
ls tools/spec_audit/spec_cases/$P.bend | xargs -P "$J" -I{} bash -c '
  f={}; b=$(basename $f .bend); s=$(date +%s)
  CHECK_TIMEOUT=300 nice -n 19 tools/check.sh $f > '"$L"'/$b.log 2>&1; rc=$?
  ok=$(grep -c "ALL PROOFS CHECK" '"$L"'/$b.log)
  printf "%s\t%s\t%s\t%s\n" $b $rc $ok $(( $(date +%s) - s )) >> '"$L"'/results.tsv'
sort -o "$L/results.tsv" "$L/results.tsv"
echo "files $(wc -l < $L/results.tsv)  passed $(awk -F'\t' '$3==1' $L/results.tsv | wc -l)  failed $(awk -F'\t' '$3!=1' $L/results.tsv | wc -l)  slowest $(sort -k4 -n -r $L/results.tsv | head -1)"
awk -F'\t' '$3!=1 {print "FAIL", $1}' "$L/results.tsv"
