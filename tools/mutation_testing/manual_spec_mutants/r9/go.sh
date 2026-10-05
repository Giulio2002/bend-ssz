#!/bin/bash
# go.sh BATCH PATCH_GLOB: on the server, from manualmut-r9: generate the round-9 definitions (gen_defs9.py), materialise them
# (mk9.py, duplicates of rounds 1-8 dropped) and run verdict (A) with run9.py (cheapest K roots that import the patched file and
# mention a changed symbol, the direct importers, then the facades; a checker stack overflow is retried once at the pinned
# settings and is never a kill). Never more than 4 jobs, nice 19.
set -u
B=/srv/ssz-optimization/agents/manualmut-r9
cd $B/tree
M=tools/mutation_testing/manual_spec_mutants
mkdir -p ../out
python3 $M/r9/gen_defs9.py . $M/defs > ../out/gen.log 2>&1
python3 $M/r9/mk9.py . $M/defs ../pk > ../out/mk.log 2>&1
tail -3 ../out/mk.log
nice -n 19 python3 $M/r9/run9.py --tree . --idx ../allcones.json --work ../work --out ../out/res_$1.json --jobs ${JOBS:-4} --k ${K:-3} --direct ${DIRECT:-1} --fac ${FAC:-1} $(ls ../pk/$2/*.patch) >> ../out/run_$1.log 2>&1
echo done >> ../out/run_$1.log
