#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r10/tree
nice -n 19 python3 tools/mutation_testing/manual_spec_mutants/r9/corpus9.py --tree . --work ../workc --cases /srv/ssz-optimization/agents/sizelimit-rt/kit/cases_corpus.jsonl --out ../out/corpus10b.json --jobs 1 $(cat ../corpus_list2.txt) > ../out/corpus10b.log 2>&1
echo done >> ../out/corpus10b.log
