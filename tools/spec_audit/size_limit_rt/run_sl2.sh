#!/bin/bash
cd /srv/ssz-optimization/agents/sizelimit-rt
R=$PWD
echo "== build"; bash kit/build_groups.sh $R/sl2 4 > build_sl2.log 2>&1; grep -vc "rc=0" build_sl2.log
echo "== corpus"; nice -n 19 python3 kit/rt_corpus.py --repo sl2 --cases kit/cases_corpus.jsonl --out res_corpus_sl2.jsonl --jobs 4 | tail -1
python3 kit/rt_diff.py res_corpus_main.jsonl res_corpus_sl2.jsonl kit/cases_corpus.jsonl
echo "== trees"; TREES=sl2 bash kit/run_trees.sh
echo "== regress sl2"; CH_OUT=/dev/shm/rt_regress_sl2 bash kit/rt_regress.sh $R/sl2 2>&1 | grep -v "^ok" | cut -c1-230
echo "== laws sl2"; python3 kit/rt_laws.py $R/sl2 proofs/slop/crash/crash_fix_laws_generated.bend proofs/slop/validity/fulu_marker_poison_generated.bend proofs/slop/validity/generic_marker_poison_generated.bend 2>&1 | grep -v "^PASS" | cut -c1-250
echo "== unit test"; (cd sl2 && python3 -m unittest codegen.tests.test_no_stale_marker 2>&1 | tail -3)
echo "== ladder"; rm -f ladder.json; python3 kit/rt_ladder.py --trees main,sl2 --root $R --out ladder_sl2.json --timeout 1800 | cut -c1-250
