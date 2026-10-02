#!/bin/bash
# Probe C: decode with sizes near 2^32 (job1's mutate step runs this first). Bounded; nice 19; one program at a time.
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend
OUT=/srv/ssz-optimization/agents/crashhunt/out3
mkdir -p $OUT
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/pc_bigdecode.bend -o build/ch/pc > $OUT/compile_pc.log 2>&1
echo "compile pc rc=$?"; head -12 $OUT/compile_pc.log
# case size depth fill   (depth = log2 of the words of the input array; fill = every word)
for spec in "1 1048576 18 0" "1 2147483648 29 1431655765" "1 4294967295 30 1431655765" "1 4294967280 30 1431655765" "1 4294967264 30 1431655765" \
            "2 1048576 18 2155905152" "2 536870913 27 2155905152" "2 536870912 27 2155905152" "3 536870912 27 2155905152" "3 1048576 18 2155905152"; do
  set -- $spec
  ( ulimit -d 11534336; export SSZ_CASE=$1 SSZ_ARG=$2 SSZ_DEPTH=$3 SSZ_FILL=$4; s=$(date +%s); timeout 120 nice -n 19 build/ch/pc --threads 1 --gpu off > $OUT/pc_$1_$2.out 2> $OUT/pc_$1_$2.err; rc=$?; e=$(date +%s); echo "case $1 size $2 depth $3 rc=$rc sec=$((e - s)) :: $(tr '\n' ' ' < $OUT/pc_$1_$2.out | cut -c1-200) :: $(head -c 200 $OUT/pc_$1_$2.err | tr '\n' ' ')" ) | tee -a $OUT/pc_summary.txt
done
