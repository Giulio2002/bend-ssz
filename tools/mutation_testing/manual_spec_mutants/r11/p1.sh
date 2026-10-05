#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
M=tools/mutation_testing/manual_spec_mutants
nice -n 19 python3 $M/r11/run11.py --tree . --idx ../allcones.json --work ../work --out ../out/res_p1.json --jobs 4 --k 2 --direct 1 --fac 2 $(cat ../run_list.txt | sed "s|^|../|") > ../out/run_p1.log 2>&1
echo done >> ../out/run_p1.log
