#!/bin/bash
# rt_regress.sh TREE [SKIP...]: tools/crash_hunt/regress.sh of TREE with the cases SKIP... (case numbers) removed from the probe program and
# the expected list (a probe case that does not compile on a branch is reported, not allowed to hide the others).
T=$1; shift
cd "$T" || exit 2
ulimit -s 16384; export BEND_NO_TELEMETRY=1
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
OUT=${CH_OUT:-/dev/shm/rt_regress}; mkdir -p $OUT
cp tools/crash_hunt/pf_fixed.bend tools/crash_hunt/pf_rt.bend
cp tools/crash_hunt/regress_expected.txt $OUT/expected.txt
for c in "$@"; do
  sed -i "/^def case$c()/d; /^    case $c: case$c()/d" tools/crash_hunt/pf_rt.bend
  sed -i "/^$c /d" $OUT/expected.txt
done
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 "$BEND" tools/crash_hunt/pf_rt.bend -o "$OUT/pf" > "$OUT/compile.log" 2>&1 || { echo "compile failed"; head -8 "$OUT/compile.log"; exit 2; }
bad=0; n=0
while read -r c expect; do
  got=$( ( ulimit -d 33554432; export SSZ_CASE=$c; timeout 120 nice -n 19 "$OUT/pf" --threads 1 --gpu off 2>&1 | tr '\n' ' ' | sed 's/ *$//' ) )
  n=$((n+1))
  if [ "$got" = "$expect" ]; then echo "ok    case $c: $got"; else echo "FAIL  case $c: got '$got', expected '$expect'"; bad=$((bad+1)); fi
done < $OUT/expected.txt
rm -f tools/crash_hunt/pf_rt.bend
echo "regress: $n cases, $bad fail"
