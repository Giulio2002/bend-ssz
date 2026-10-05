#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r10/tree
M=tools/mutation_testing/manual_spec_mutants
nice -n 19 python3 $M/r10/run10.py --tree . --idx ../allcones.json --work ../work --out ../out/res_h3.json --jobs 1 --k 0 --direct 0 --fac 1 $(ls ../pk_v2/r10-h03*/*.patch) > ../out/run_h3.log 2>&1
echo done >> ../out/run_h3.log
