#!/bin/bash
# rt_probes.sh TREE OUTFILE: the hunter probes (tools/crash_hunt pa_objects, pb_api, pc_bigdecode: the case lists of job1/job3/job5) on TREE, one line per case
# (rc, output, MAXRSS); `diff` two OUTFILEs to see what a branch changes. Pinned compiler for the probes; ulimit -d 32 GiB; one case at a time.
T=$1; O=$2
cd "$T" || exit 2
ulimit -s 16384; export BEND_NO_TELEMETRY=1
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
B=/dev/shm/rt_probes_$$; mkdir -p $B; : > $O
for p in pa_objects pb_api pc_bigdecode; do
  BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 $BEND tools/crash_hunt/$p.bend -o $B/$p > $B/$p.log 2>&1 || echo "compile $p FAILED: $(head -c 300 $B/$p.log | tr '\n' ' ')" >> $O
done
one() { # name cmdline... ; env passed by caller
  out=$( ( ulimit -d 33554432; /usr/bin/time -f "MAXRSS=%MKB" timeout 120 nice -n 19 "$@" --threads 1 --gpu off 2>&1 ) | tr '\n' ' ' | cut -c1-300 )
  echo "$out"
}
if [ -x $B/pa_objects ]; then
  for spec in "1 0" "2 0" "3 0" "4 0" "5 4294967295" "5 3000000000" "6 1000000" "6 100000000" "6 1073741824" "6 4294967295" "7 4294967295" "7 1000" "8 0" "9 0" "10 0" "11 1000" "11 100000000" "11 4294967295" "12 0" "13 0" "14 4294967295" "14 100" "15 2147483647" "15 2147483648" "15 4294967264" "15 4294967295"; do
    set -- $spec; echo "pa $1 $2 :: $(SSZ_CASE=$1 SSZ_ARG=$2 one $B/pa_objects | sed 's/MAXRSS=[0-9]*KB//')" >> $O
  done
fi
if [ -x $B/pb_api ]; then
  for c in 1 2 3 4 5 6 7; do echo "pb $c :: $(SSZ_CASE=$c one $B/pb_api | sed 's/MAXRSS=[0-9]*KB//')" >> $O; done
fi
if [ -x $B/pc_bigdecode ]; then
  for spec in "1 1048576 18 0" "1 2147483648 29 1431655765" "1 4294967295 30 1431655765" "1 4294967280 30 1431655765" "1 4294967264 30 1431655765" "2 1048576 18 2155905152" "2 536870913 27 2155905152" "2 536870912 27 2155905152" "3 536870912 27 2155905152" "3 1048576 18 2155905152"; do
    set -- $spec; echo "pc $1 $2 :: $(SSZ_CASE=$1 SSZ_ARG=$2 SSZ_DEPTH=$3 SSZ_FILL=$4 one $B/pc_bigdecode | sed 's/MAXRSS=[0-9]*KB//')" >> $O
  done
fi
rm -rf $B
wc -l $O
