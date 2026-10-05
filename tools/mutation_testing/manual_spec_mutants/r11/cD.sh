#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workcD --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11D.json --jobs 1  ../pkc/r11-b03-bx-ok/12.patch ../pkc/r11-a02-word-readback/01.patch ../pkc/r11-a03-tail-keep/01.patch ../pkc/r11-a05-vector-storage/01.patch > ../out/corpus11D.log 2>&1
echo done >> ../out/corpus11D.log
