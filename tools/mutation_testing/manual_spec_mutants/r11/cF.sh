#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workcF --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11F.json --jobs 1  ../pkc/r11-f01-union-same-type/03.patch ../pkc/r11-h01-budget-strict/11.patch ../pkc/r11-h02-budget-unchecked/11.patch ../pkc/r11-c01-group-acc/11.patch ../pkc/r11-b03-bx-ok/04.patch > ../out/corpus11F.log 2>&1
echo done >> ../out/corpus11F.log
