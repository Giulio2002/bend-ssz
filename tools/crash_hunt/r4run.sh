#!/bin/bash
# r4run.sh PROG CASE ARG [D K DEPTH] [TIMEOUT]: one case of a round-4 probe (server; nice 19, stack 16384 KB, ulimit -d 64 GiB, 120 s by default).
# Prints: the case, exit code, seconds, max RSS and the program's output on one line.
P=$1; C=$2; A=$3; DN=${4:-0}; K=${5:-0}; DEP=${6:-0}; TO=${7:-120}
ulimit -s 16384; ulimit -d ${R4_DMEM:-67108864}
s=$(date +%s.%N)
out=$( SSZ_CASE=$C SSZ_ARG=$A SSZ_D=$DN SSZ_K=$K SSZ_DEPTH=$DEP /usr/bin/time -f "MAXRSS_KB=%M" timeout $TO nice -n 19 $P --threads 1 --gpu off 2>&1 | tr '\n' ' ' | cut -c1-600 )
rc=${PIPESTATUS[0]}
e=$(date +%s.%N)
echo "case=$C arg=$A d=$DN k=$K dep=$DEP sec=$(echo "$e - $s" | bc | cut -c1-6) :: $out"
