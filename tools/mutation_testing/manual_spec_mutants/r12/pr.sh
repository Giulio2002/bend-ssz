#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r12/tree
PROBE=tools/mutation_testing/manual_spec_mutants/r12/probes/p12a.bend CASES=1,2,3 nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r3/apiprobe3.py --tree . --work /srv/ssz-optimization/agents/manualmut-r12/workp --out ../out/api_p12a.json --jobs 1 ../pk/r12-d01-cache-lo/02.patch ../pk/r12-d01-cache-lo/03.patch ../pk/r12-d02-cache-depth0/02.patch ../pk/r12-d02-cache-depth0/03.patch ../pk/r12-d01-cache-lo/16.patch > ../out/api_p12a.log 2>&1
echo done >> ../out/api_p12a.log
