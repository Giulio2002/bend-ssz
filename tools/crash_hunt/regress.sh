#!/bin/bash
# tools/crash_hunt/regress.sh: the regression run of the crash-hunt fixes (docs/CRASH_HUNT.md). Run ON THE SERVER from the repository
# root: compiles tools/crash_hunt/pf_fixed.bend with the pinned toolchain, runs every case under a 60 s timeout and compares the
# output line with tools/crash_hunt/regress_expected.txt. Exit 0 iff every case printed the expected line (a crash, a hang or a
# different value fails it). BEFORE the fixes (origin/main b1764b5a8) cases 1-4, 6-8, 9, 11 and 12 print the other value.
cd "$(dirname "$0")/../.." || exit 2
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
OUT=${CH_OUT:-/tmp/crash_hunt_regress}
mkdir -p "$OUT"
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 "$BEND" tools/crash_hunt/pf_fixed.bend -o "$OUT/pf" > "$OUT/compile.log" 2>&1 || { echo "compile failed"; tail -5 "$OUT/compile.log"; exit 2; }
bad=0
while read -r c expect; do
  got=$( ( ulimit -d 16777216; export SSZ_CASE=$c; timeout 60 nice -n 19 "$OUT/pf" --threads 1 --gpu off 2>&1 | tr '\n' ' ' | sed 's/ *$//' ) )
  if [ "$got" = "$expect" ]; then echo "ok    case $c: $got"; else echo "FAIL  case $c: got '$got', expected '$expect'"; bad=$((bad+1)); fi
done < tools/crash_hunt/regress_expected.txt
rm -rf "$OUT"
[ $bad = 0 ] && echo "crash-hunt regression: all cases pass" || echo "crash-hunt regression: $bad case(s) FAIL"
exit $((bad > 0))
