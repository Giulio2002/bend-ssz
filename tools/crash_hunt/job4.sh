#!/bin/bash
# Crash-hunt job 4 (programs are already built by job1): probe B/C, count bomb, mutation driver with a discovered cap, big hostile corpus.
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend
OUT=/srv/ssz-optimization/agents/crashhunt/out4
PY=/srv/ssz-optimization/agents/rename-venv/bin/python
mkdir -p $OUT
t0=$(date +%s)
stamp() { echo "== $1 at +$(( $(date +%s) - t0 )) s"; df -h /srv | tail -1; }
stamp start
for p in pb_api pc_bigdecode; do
  BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/$p.bend -o build/ch/${p%%_*} > $OUT/compile_$p.log 2>&1
  echo "compile $p rc=$?"; head -12 $OUT/compile_$p.log
done
for c in 1 2 3 4 5 6 7; do
  ( ulimit -d 8388608; export SSZ_CASE=$c; timeout 60 nice -n 19 build/ch/pb --threads 1 --gpu off > $OUT/pb_$c.out 2> $OUT/pb_$c.err; echo "pb case $c rc=$? :: $(tr '\n' ' ' < $OUT/pb_$c.out) :: $(head -c 200 $OUT/pb_$c.err | tr '\n' ' ')" ) | tee -a $OUT/pb_summary.txt
done
# probe C: size, depth(log2 words), fill word
for spec in "1 1048576 18 0" "1 2147483648 29 1431655765" "1 4294967295 30 1431655765" "1 4294967280 30 1431655765" "1 4294967264 30 1431655765" \
            "2 1048576 18 2155905152" "2 536870913 27 2155905152" "2 536870912 27 2155905152" "3 536870912 27 2155905152" "3 1048576 18 2155905152"; do
  set -- $spec
  ( ulimit -d 11534336; export SSZ_CASE=$1 SSZ_ARG=$2 SSZ_DEPTH=$3 SSZ_FILL=$4; s=$(date +%s); timeout 120 nice -n 19 build/ch/pc --threads 1 --gpu off > $OUT/pc_$1_$2.out 2> $OUT/pc_$1_$2.err; rc=$?; e=$(date +%s); echo "case $1 size $2 depth $3 rc=$rc sec=$((e - s)) :: $(tr '\n' ' ' < $OUT/pc_$1_$2.out | cut -c1-200) :: $(head -c 200 $OUT/pc_$1_$2.err | tr '\n' ' ')" ) | tee -a $OUT/pc_summary.txt
done
stamp probes_done
nice -n 19 timeout 600 $PY tools/crash_hunt/countbomb.py --repo . --out $OUT --mem-gb 8 > $OUT/countbomb.log 2>&1
cat $OUT/countbomb.log | cut -c1-220
stamp countbomb_done
# cap discovery for the fuzz programs (they reserve more address space than the object programs)
: > /tmp/ch_empty.ssz
CAP=1000
for kb in 8388608 16777216 33554432 67108864; do
  ( ulimit -d $kb; SSZ_MODE=1 SSZ_INDEX=7 SSZ_SEL=0 SSZ_IDX=0 SSZ_SEED=0 SSZ_INPUT=/tmp/ch_empty.ssz SSZ_OUTPUT=/tmp/ch_o build/fuzz-f4 > /dev/null 2> $OUT/capdisc.err )
  if ! grep -q "reservation failed" $OUT/capdisc.err; then CAP=$((kb / 1048576)); break; fi
done
echo "fuzz program cap ${CAP} GB"
nice -n 19 timeout 1200 $PY tools/crash_hunt/mutate_hostile_real.py --repo . --out $OUT --jobs 4 --timeout 60 --mem-gb $CAP > $OUT/mutate.log 2>&1
tail -3 $OUT/mutate.log
stamp mutate_done
CH_BIG=1 nice -n 19 timeout 1200 $PY tools/crash_hunt/hostile_decode.py --repo . --out $OUT --jobs 4 --limit-seeds 2 --timeout 30 --mem-gb 8 > $OUT/hostile_big.log 2>&1
tail -3 $OUT/hostile_big.log
stamp job4_done
