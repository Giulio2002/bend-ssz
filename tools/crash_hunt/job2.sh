#!/bin/bash
# Crash-hunt job 2 (runs under job1's lock slot): probe A and B with the corrected cap, hostile decode, scale.
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend
OUT=/srv/ssz-optimization/agents/crashhunt/out2
PY=/srv/ssz-optimization/agents/rename-venv/bin/python
mkdir -p $OUT
t0=$(date +%s)
stamp() { echo "== $1 at +$(( $(date +%s) - t0 )) s"; df -h /srv | tail -1; }
stamp start
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/pa_objects.bend -o build/ch/pa > $OUT/compile_pa.log 2>&1
echo "compile pa rc=$?"; head -12 $OUT/compile_pa.log
CAPKB=8388608
( ulimit -d $CAPKB; SSZ_CASE=2 timeout 60 build/ch/pb --threads 1 --gpu off ) > $OUT/captest.out 2>&1 || { echo "cap test failed: $(cat $OUT/captest.out | head -c 200)"; CAPKB=unlimited; }
echo "cap test: $(cat $OUT/captest.out | head -c 200) CAPKB=$CAPKB"
if [ "$CAPKB" = "unlimited" ]; then MEMGB=1000; else MEMGB=8; fi
if [ -x build/ch/pb ]; then
  for c in 1 2 3 4 5; do
    ( ulimit -d $CAPKB; export SSZ_CASE=$c; timeout 60 nice -n 19 build/ch/pb --threads 1 --gpu off > $OUT/pb_$c.out 2> $OUT/pb_$c.err; echo "pb case $c rc=$? :: $(tr '\n' ' ' < $OUT/pb_$c.out) :: $(head -c 200 $OUT/pb_$c.err | tr '\n' ' ')" ) | tee -a $OUT/pb_summary.txt
  done
fi
if [ -x build/ch/pa ]; then
  for spec in "12 0" "13 0" "1 0" "2 0" "3 0" "4 0" "5 4294967295" "5 3000000000" "6 1000000" "6 100000000" "6 1073741824" "6 4294967295" \
              "7 4294967295" "7 1000" "8 0" "9 0" "10 0" "11 1000" "11 100000000" "11 4294967295" "14 4294967295" "14 100"; do
    set -- $spec
    ( ulimit -d $CAPKB; export SSZ_CASE=$1 SSZ_ARG=$2; s=$(date +%s); timeout 120 nice -n 19 build/ch/pa --threads 1 --gpu off > $OUT/pa_$1_$2.out 2> $OUT/pa_$1_$2.err; rc=$?; e=$(date +%s); echo "case $1 arg $2 rc=$rc sec=$((e - s)) :: $(tr '\n' ' ' < $OUT/pa_$1_$2.out | cut -c1-200) :: $(head -c 200 $OUT/pa_$1_$2.err | tr '\n' ' ')" ) | tee -a $OUT/pa_summary.txt
  done
fi
stamp probes_done
nice -n 19 timeout 1500 $PY tools/crash_hunt/hostile_decode.py --repo . --out $OUT --jobs 4 --limit-seeds 1 --timeout 40 --mem-gb $MEMGB > $OUT/hostile.log 2>&1
tail -3 $OUT/hostile.log
stamp hostile_done
nice -n 19 timeout 900 $PY tools/crash_hunt/scale_decode_real.py --repo . --out $OUT --mem-gb $MEMGB --timeout 100 > $OUT/scale.log 2>&1
tail -30 $OUT/scale.log
stamp job2_done
