#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workcA --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11A.json --jobs 1  ../pkc/r11-a01-reader-base/09.patch ../pkc/r11-b03-bx-ok/01.patch ../pkc/r11-f01-union-same-type/02.patch > ../out/corpus11A.log 2>&1
echo done >> ../out/corpus11A.log
