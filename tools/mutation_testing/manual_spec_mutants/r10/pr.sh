#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r10/tree
M=tools/mutation_testing/manual_spec_mutants
P=""; for i in 01 02 03 04 05 09 10 11 12 20 21 22 23; do P="$P ../pk_v2/r10-d01-default/$i.patch"; done
PROBE=$M/r10/probes/p10a.bend CASES=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 nice -n 19 python3 $M/r3/apiprobe3.py --tree . --work /srv/ssz-optimization/agents/manualmut-r10/workp --out ../out/api_p10a.json --jobs 1 $P > ../out/api_p10a.log 2>&1
echo done >> ../out/api_p10a.log
