#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r12/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r12/run12.py --tree . --idx ../allcones.json --work ../work --out ../out/res_p1a.json --jobs 4 --k 1 --direct 0 --fac 1 $(sed "s|^|../|" ../list_a.txt) > ../out/run_p1a.log 2>&1
echo done >> ../out/run_p1a.log
