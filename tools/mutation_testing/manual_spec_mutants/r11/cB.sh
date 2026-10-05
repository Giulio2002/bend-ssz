#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workcB --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11B.json --jobs 1  ../pkc/r11-b03-bx-ok/09.patch ../pkc/r11-b03-bx-ok/11.patch ../pkc/r11-a04-vector-count/01.patch > ../out/corpus11B.log 2>&1
echo done >> ../out/corpus11B.log
