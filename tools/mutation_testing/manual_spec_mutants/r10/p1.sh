#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r10/tree
M=tools/mutation_testing/manual_spec_mutants
nice -n 19 python3 $M/r10/run10.py --tree . --idx ../allcones.json --work ../work --out ../out/res_p1.json --jobs 4 --k 0 --direct 0 --fac 1 $(ls ../pk/*/*.patch) > ../out/run_p1.log 2>&1
echo done >> ../out/run_p1.log
