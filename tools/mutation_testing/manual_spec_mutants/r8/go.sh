#!/bin/bash
# go.sh BATCH PATCH_GLOB: on the server, from manualmut-r8: materialise the round-8 patches from defs/r8_*.txt (mk8.py) and run verdict (A)
# with run8.py (cheapest K roots that import the patched file and mention a changed symbol, the direct importers, then the facades;
# a checker stack overflow is retried once at the pinned settings and is never a kill). Never more than 4 jobs, nice 19.
set -u
B=/srv/ssz-optimization/agents/manualmut-r8
cd $B/tree
M=tools/mutation_testing/manual_spec_mutants
mkdir -p ../out
python3 $M/r8/mk8.py . $M/defs ../pk > ../out/mk.log 2>&1
tail -3 ../out/mk.log
nice -n 19 python3 $M/r8/run8.py --tree . --idx ../allcones.json --work ../work --out ../out/res_$1.json --jobs ${JOBS:-4} --k ${K:-3} $(ls ../pk/$2/*.patch) >> ../out/run_$1.log 2>&1
echo done >> ../out/run_$1.log
