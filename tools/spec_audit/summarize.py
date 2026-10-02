#!/usr/bin/env python3
"""Reduce a differential run to the small files committed under tools/spec_audit/data/.

    python3 tools/spec_audit/summarize.py WORKDIR_WITH_CASES tools/spec_audit/data [SPEC_LOGDIR]

Writes cases_summary.json (counts per type, per verdict, per rejection reason, per case family), cases_sample.jsonl (up to 6
short cases per type, to inspect the corpus without regenerating it), copies bend_runtime.json and rk_oracle.json, and, when a
spec-case log directory is given, spec_cases_results.tsv.
"""
import collections
import json
import os
import shutil
import sys

src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)
per_type = collections.defaultdict(lambda: collections.Counter())
reasons, fam, sample_n = collections.Counter(), collections.Counter(), collections.Counter()
total = collections.Counter()
with open(os.path.join(dst, 'cases_sample.jsonl'), 'w') as sample:
    for line in open(os.path.join(src, 'cases.jsonl')):
        c = json.loads(line)
        per_type[c['type']][c['verdict']] += 1
        total[c['verdict']] += 1
        if c['verdict'] == 'reject':
            reasons[c['reason'].split(':')[0]] += 1
        f = c['label'].split('|')[-1]
        fam[''.join(ch for ch in f.split('@')[0].split('=')[0] if not ch.isdigit())[:30]] += 1
        if c['hex'] is not None and c['len'] <= 300 and sample_n[c['type']] < 6:
            sample_n[c['type']] += 1
            sample.write(json.dumps({k: c[k] for k in ('type', 'label', 'hex', 'verdict', 'reason', 'root')}) + '\n')
json.dump({'cases': sum(total.values()), 'by_verdict': dict(total), 'types': len(per_type),
           'by_type': {k: dict(v) for k, v in sorted(per_type.items())},
           'reference_rejection_reasons': dict(reasons.most_common()),
           'case_families': dict(fam.most_common(60))}, open(os.path.join(dst, 'cases_summary.json'), 'w'), indent=1)
for f in ('bend_runtime.json', 'rk_oracle.json'):
    if os.path.exists(os.path.join(src, f)):
        shutil.copy(os.path.join(src, f), os.path.join(dst, f))
if len(sys.argv) > 3:
    shutil.copy(os.path.join(sys.argv[3], 'results.tsv'), os.path.join(dst, 'spec_cases_results.tsv'))
print('wrote', os.listdir(dst))
