#!/bin/bash
cd /srv/ssz-optimization/agents/manualmut-r10
while pgrep -f "p1h[.]sh" >/dev/null; do sleep 15; done
python3 - <<PY > p2_list.txt
import json
ids=[]
for f in ("out/res_p1.json","out/res_p1h.json"):
    for r in json.load(open(f)):
        if r["A"]!="KILLED": ids.append(r["id"])
print(" ".join("../pk_all/%s.patch"%i for i in ids))
PY
cd tree
M=tools/mutation_testing/manual_spec_mutants
nice -n 19 python3 $M/r10/run10.py --tree . --idx ../allcones.json --work ../work --out ../out/res_p2.json --jobs 3 --k 3 --direct 1 --fac 3 $(cat ../p2_list.txt) > ../out/run_p2.log 2>&1
echo done >> ../out/run_p2.log
