#!/bin/bash
# go.sh: on the server, from manualmut-r4: materialise the round-4 patches from defs/r4_*.txt and run verdict (A) with the round-3 runner
# (cheapest roots that import the patched file and mention a changed symbol, then the facades). Never more than 4 jobs, nice 19.
set -u
B=/srv/ssz-optimization/agents/manualmut-r4
cd $B/tree
M=tools/mutation_testing/manual_spec_mutants
mkdir -p ../out
python3 $M/r4/mk4.py . $M/defs ../pk > ../out/mk.log 2>&1
tail -3 ../out/mk.log
nice -n 19 python3 $M/r3/run3.py --tree . --idx ../allcones.json --work ../work --out ../out/res_all.json --jobs ${JOBS:-4} --k ${K:-6} $(ls ../pk/r4-*/*.patch) >> ../out/run.log 2>&1
echo done >> ../out/run.log
