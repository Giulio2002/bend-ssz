#!/bin/bash
# run_trees.sh: the invalid-object corpus, the byte-window corpus and the empty-input check of every tree in $TREES (default: main sl).
# Run from sizelimit-rt/. RT_TMP (tmpfs) takes the outputs of the cases: a tree that accepts an invalid object writes GiB.
cd /srv/ssz-optimization/agents/sizelimit-rt
for t in ${TREES:-main sl}; do
  export RT_TMP=/dev/shm/rt_$t; mkdir -p $RT_TMP
  W=/srv/ssz-optimization/agents/sizelimit-rt/work_$t; mkdir -p $W
  echo "== $t invalid_cases"; (cd $t && nice -n 19 python3 tools/spec_audit/run_invalid_cases.py --repo . --cases tools/spec_audit/data/invalid_cases.json --work $W --out ../res_invalid_$t.json --jobs 4 2>&1 | head -14)
  echo "== $t bytes_cases"; (cd $t && nice -n 19 python3 tools/spec_audit/run_bytes_cases.py --repo . --cases tools/spec_audit/data/invalid_bytes_cases.jsonl --work $W --out ../res_bytes_$t.json 2>&1 | tail -3)
  echo "== $t empty_input"; (cd $t/tools/spec_audit && nice -n 19 python3 run_empty_input.py --repo ../.. --cs /srv/ssz-optimization/agents/specaudit/cs --work $W --out ../../../res_empty_$t.json 2>&1 | tail -3)
  rm -rf $W $RT_TMP
done
