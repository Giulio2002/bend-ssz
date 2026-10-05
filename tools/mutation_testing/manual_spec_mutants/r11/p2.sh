#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
M=tools/mutation_testing/manual_spec_mutants
nice -n 19 python3 $M/r11/run11.py --tree . --idx ../allcones.json --work ../work --out ../out/res_p2.json --jobs 4 --roots-json ../p2_plan.json $(cat ../p2_list.txt) > ../out/run_p2.log 2>&1
echo done >> ../out/run_p2.log
