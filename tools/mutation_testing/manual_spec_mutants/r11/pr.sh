#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
M=tools/mutation_testing/manual_spec_mutants
P=""; for x in r11-d02-cache-grow-window/01 r11-d02-cache-grow-window/02 r11-d02-cache-grow-window/03 r11-d02-cache-grow-window/04 r11-d02-cache-grow-window/05 r11-d02-cache-grow-window/06 r11-d03-cset-lo/04 r11-d03-cset-lo/05 r11-d04-cset-hi/03 r11-d05-cache-depth/04 r11-d06-capp-lo/01 r11-d07-croot-reset/01 r11-f01-union-same-type/02 r11-d03-cset-lo/03 r11-d01-cache-window/03; do P="$P ../pk/$x.patch"; done
PROBE=$M/r11/probes/p11a.bend CASES=1,2,3,4,5,6,7,8,9,10 nice -n 19 python3 $M/r3/apiprobe3.py --tree . --work /srv/ssz-optimization/agents/manualmut-r11/workp --out ../out/api_p11a.json --jobs 1 $P > ../out/api_p11a.log 2>&1
echo done >> ../out/api_p11a.log
