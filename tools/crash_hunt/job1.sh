#!/bin/bash
# Crash-hunt job 1, run on the server under the full-check lock. Everything bounded; nice 19; at most 4 programs at a time.
cd /srv/ssz-optimization/agents/crashhunt/repo || exit 1
ulimit -s 16384
export BEND_NO_TELEMETRY=1
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
OUT=/srv/ssz-optimization/agents/crashhunt/out1
PY=/srv/ssz-optimization/agents/rename-venv/bin/python
mkdir -p $OUT build/ch
t0=$(date +%s)
stamp() { echo "== $1 at +$(( $(date +%s) - t0 )) s"; df -h /srv | tail -1; }
stamp start
# A. probe A
BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/pa_objects.bend -o build/ch/pa > $OUT/compile_pa.log 2>&1
echo "compile pa rc=$?"; tail -5 $OUT/compile_pa.log
stamp compiled_pa
if [ -x build/ch/pa ]; then
  for spec in "1 0" "2 0" "3 0" "4 0" "5 4294967295" "5 3000000000" "6 1000000" "6 100000000" "6 1073741824" "6 4294967295" \
              "7 4294967295" "7 1000" "8 0" "9 0" "10 0" "11 1000" "11 100000000" "11 4294967295" "12 0" "13 0" "14 4294967295" "14 100"; do
    set -- $spec
    ( ulimit -v 8388608; export SSZ_CASE=$1 SSZ_ARG=$2; s=$(date +%s.%N); timeout 120 nice -n 19 build/ch/pa --threads 1 --gpu off > $OUT/pa_$1_$2.out 2> $OUT/pa_$1_$2.err; rc=$?; e=$(date +%s.%N); echo "case $1 arg $2 rc=$rc sec=$(echo "$e - $s" | bc)  :: $(tr '\n' ' ' < $OUT/pa_$1_$2.out | cut -c1-200) :: $(head -c 200 $OUT/pa_$1_$2.err | tr '\n' ' ')" ) | tee -a $OUT/pa_summary.txt
  done
fi
stamp probeA_done
# C. obj programs, 4 at a time
mk() { n=$1; src=benchmarks/objprog/$n.bend; BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 1200 $BEND $src -o build/obj-$n > $OUT/compile_$n.log 2>&1; echo "compile $n rc=$?"; }
export -f mk; export BEND OUT
ls benchmarks/objprog/ | sed 's/\.bend//' | grep -E '^(g|x)[0-9]+$' | xargs -P 4 -I{} bash -c 'mk {}' 
stamp programs_built
# D. hostile decode
nice -n 19 timeout 1800 $PY tools/crash_hunt/hostile_decode.py --repo . --out $OUT --jobs 4 --limit-seeds 1 --timeout 40 > $OUT/hostile.log 2>&1
tail -3 $OUT/hostile.log
stamp hostile_done
nice -n 19 timeout 1200 $PY tools/crash_hunt/scale_decode.py --repo . --out $OUT --mem-gb 12 --timeout 100 > $OUT/scale.log 2>&1
tail -30 $OUT/scale.log
FP="4 10 12 13 15 17 18 19 20 21 22 23 24 25 26"
mkf() { n=f$1; BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 1200 $BEND benchmarks/objprog/$n.bend -o build/fuzz-$n > $OUT/compile_$n.log 2>&1; echo "compile $n rc=$?"; }
export -f mkf
echo $FP | tr ' ' '\n' | xargs -P 4 -I{} bash -c 'mkf {}'
stamp fuzz_programs_built
nice -n 19 timeout 1500 $PY tools/crash_hunt/mutate_hostile.py --repo . --out $OUT --jobs 4 --timeout 60 > $OUT/mutate.log 2>&1
tail -3 $OUT/mutate.log
stamp all_done
