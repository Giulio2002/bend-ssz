#!/bin/bash
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend
OUT=/srv/ssz-optimization/agents/crashhunt/out6
mkdir -p $OUT
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/pd_cache.bend -o build/ch/pd > $OUT/compile_pd.log 2>&1
echo "compile pd rc=$?"; head -14 $OUT/compile_pd.log
run() { ( ulimit -d 33554432; export SSZ_CASE=$1 SSZ_ARG=$2 SSZ_ARG2=$3; timeout 60 nice -n 19 build/ch/pd --threads 1 --gpu off 2>&1 | tr '\n' ' ' | sed "s/^/case $1 $2 $3 :: /"; echo " rc=${PIPESTATUS[0]}" ); }
for n in 0 1 2 3 4 5 8 9 15 16; do run 1 $n 0; done
for spec in "0 1" "0 5" "3 4" "3 9" "4 5" "8 9" "15 16" "16 17" "15 20" "0 17"; do set -- $spec; run 2 $1 $2; done
run 3 4294967295 0; run 3 3 0; run 3 2 0
