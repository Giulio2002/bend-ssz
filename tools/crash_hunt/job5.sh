#!/bin/bash
# Crash-hunt job 5: the cases job4 could not run (compile error in probe B, cap too small for probe A case 15 and the ExecutionPayload program).
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend
OUT=/srv/ssz-optimization/agents/crashhunt/out5
PY=/srv/ssz-optimization/agents/rename-venv/bin/python
mkdir -p $OUT
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/pb_api.bend -o build/ch/pb > $OUT/compile_pb.log 2>&1
echo "compile pb rc=$?"; head -12 $OUT/compile_pb.log
for c in 1 2 3 4 5 6 7; do
  ( ulimit -d 33554432; export SSZ_CASE=$c; timeout 60 nice -n 19 build/ch/pb --threads 1 --gpu off > $OUT/pb_$c.out 2> $OUT/pb_$c.err; echo "pb case $c rc=$? :: $(tr '\n' ' ' < $OUT/pb_$c.out) :: $(head -c 200 $OUT/pb_$c.err | tr '\n' ' ')" ) | tee -a $OUT/pb_summary.txt
done
for a in 2147483647 2147483648; do
  ( ulimit -d 33554432; export SSZ_CASE=15 SSZ_ARG=$a; s=$(date +%s); timeout 120 nice -n 19 build/ch/pa --threads 1 --gpu off > $OUT/pa_15_$a.out 2> $OUT/pa_15_$a.err; rc=$?; e=$(date +%s); echo "pa case 15 arg $a rc=$rc sec=$((e - s)) :: $(tr '\n' ' ' < $OUT/pa_15_$a.out | cut -c1-200) :: $(head -c 200 $OUT/pa_15_$a.err | tr '\n' ' ')" ) | tee -a $OUT/pa_summary.txt
done
nice -n 19 timeout 600 $PY tools/crash_hunt/countbomb.py --repo . --out $OUT --mem-gb 24 > $OUT/countbomb.log 2>&1
cut -c1-230 $OUT/countbomb.log
echo "== big hostile corpus (cap 32 GB data, Bend arena is the real limit)"
CH_BIG=1 nice -n 19 timeout 1500 $PY tools/crash_hunt/hostile_decode.py --repo . --out $OUT --jobs 4 --limit-seeds 2 --timeout 30 --mem-gb 32 > $OUT/hostile_big.log 2>&1
tail -3 $OUT/hostile_big.log
