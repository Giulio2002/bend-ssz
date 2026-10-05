#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r10
while pgrep -f "res_p1[.]json" >/dev/null; do sleep 15; done
cd tree
M=tools/mutation_testing/manual_spec_mutants
nice -n 19 python3 $M/r10/run10.py --tree . --idx ../allcones.json --work ../work --out ../out/res_p1h.json --jobs 4 --k 0 --direct 0 --fac 1 $(ls ../pk_all/r10-l0*/*.patch ../pk_all/r10-p01*/*.patch) > ../out/run_p1h.log 2>&1
echo done >> ../out/run_p1h.log
