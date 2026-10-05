#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workcC --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11C.json --jobs 1  ../pkc/r11-a01-reader-base/10.patch ../pkc/r11-a01-reader-base/11.patch ../pkc/r11-a01-reader-base/12.patch ../pkc/r11-b03-bx-ok/10.patch > ../out/corpus11C.log 2>&1
echo done >> ../out/corpus11C.log
