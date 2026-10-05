#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workcE --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11E.json --jobs 1  ../pkc/r11-b02-ok-pad/01.patch ../pkc/r11-c01-group-acc/01.patch ../pkc/r11-e01-prog-append-len/01.patch ../pkc/r11-f01-union-same-type/01.patch > ../out/corpus11E.log 2>&1
echo done >> ../out/corpus11E.log
