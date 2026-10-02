#!/bin/bash
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend
OUT=/srv/ssz-optimization/agents/crashhunt/out7
mkdir -p $OUT
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/pe_build.bend -o build/ch/pe > $OUT/compile_pe.log 2>&1
echo "compile pe rc=$?"; head -14 $OUT/compile_pe.log
for a in 4 8 4096 1048576 16777216 268435456 1073741820 4294967292; do
  ( ulimit -d 33554432; export SSZ_ARG=$a; s=$(date +%s); timeout 120 nice -n 19 build/ch/pe --threads 1 --gpu off > $OUT/pe_$a.out 2> $OUT/pe_$a.err; rc=$?; e=$(date +%s); echo "first_word $a rc=$rc sec=$((e - s)) :: $(tr '\n' ' ' < $OUT/pe_$a.out | cut -c1-200) :: $(head -c 200 $OUT/pe_$a.err | tr '\n' ' ')" ) | tee -a $OUT/pe_summary.txt
done
