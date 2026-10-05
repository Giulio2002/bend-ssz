#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r11/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workc --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus11.json --jobs 3 $(ls ../pkc/*/*.patch) > ../out/corpus11.log 2>&1
echo done >> ../out/corpus11.log
