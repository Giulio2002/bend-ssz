#!/bin/bash
# usage: run_cases.sh PROG "case arg" ...   (server, from the repo root). One line per case: rc, seconds, maxrss, output.
P=$1; shift
ulimit -s 16384; ulimit -d ${CH_DMEM:-33554432}
for spec in "$@"; do
  set -- $spec
  s=$(date +%s.%N)
  out=$( SSZ_CASE=$1 SSZ_ARG=$2 /usr/bin/time -f "MAXRSS=%MKB" timeout ${CH_TO:-120} nice -n 19 $P --threads 1 --gpu off 2>&1 | tr '\n' ' ' | cut -c1-300 )
  rc=${PIPESTATUS[0]}
  e=$(date +%s.%N)
  echo "case $1 arg $2 sec=$(echo "$e - $s" | bc) :: $out"
done
