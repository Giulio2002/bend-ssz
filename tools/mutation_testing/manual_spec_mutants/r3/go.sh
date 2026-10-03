#!/bin/bash
# go.sh: on the server, from manualmut-r3: regenerate the round-3 patches from the defs and run (A) on those not yet judged. Never more than 4 jobs.
set -u
B=/srv/ssz-optimization/agents/manualmut-r3
cd $B/tree
M=tools/mutation_testing/manual_spec_mutants
python3 $M/r3/mk3.py . $M/defs ../pk > ../out/mk.log 2>&1
tail -3 ../out/mk.log
nice -n 19 python3 $M/r3/run3.py --tree . --idx ../allcones.json --work ../work --out ../out/res_all.json --jobs 3 --k 6 $(ls ../pk/r3-*/*.patch | grep -v "r3-b0" ; ls ../pk/r3-b0*/*.patch) >> ../out/run.log 2>&1
echo done >> ../out/run.log
