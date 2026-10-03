#!/bin/bash
# rt_sizes.sh TREE CASE N [TIMEOUT]: one case of size_probe.bend on TREE (compiled once into TREE/build/size_probe): the line it prints, seconds, max RSS.
T=$1; C=$2; N=$3; TO=${4:-900}
cd "$T" || exit 2
mkdir -p tools/spec_audit/size_limit_rt
cp ../kit/size_probe.bend tools/spec_audit/size_limit_rt/size_probe.bend
if [ ! -x build/size_probe ]; then
  BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000 nice -n 19 /srv/ssz-optimization/toolchain-2.0.34/bin/bend tools/spec_audit/size_limit_rt/size_probe.bend -o build/size_probe > build/size_probe.log 2>&1 || { echo "compile failed"; head -6 build/size_probe.log; exit 2; }
fi
ulimit -s 16384; ulimit -d ${RT_DMEM:-67108864}
s=$(date +%s.%N)
out=$( SSZ_CASE=$C SSZ_N=$N /usr/bin/time -f "MAXRSS_KB=%M" timeout $TO nice -n 19 build/size_probe --threads 1 --gpu off 2>&1 | tr '\n' ' ' | cut -c1-400 )
e=$(date +%s.%N)
echo "case $C n $N sec=$(echo "$e - $s" | bc) :: $out"
