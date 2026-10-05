#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r12/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r12/run12.py --tree . --idx ../allcones.json --work ../workd --out ../out/res_p1d.json --jobs 2 --k 2 --direct 0 --fac 0 $(sed "s|^|../|" ../list_d.txt) > ../out/run_p1d.log 2>&1
echo done >> ../out/run_p1d.log
