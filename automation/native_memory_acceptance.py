"""Preserve the old semantic contract and require honest native comparison evidence."""
import json,re,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
expected=json.loads((root/'memory_bench/law-statements.json').read_text())
actual={m.group(1):m.group(0) for m in re.finditer(r'(?ms)^law (\w+):\n.*?(?=^def \1\()', (root/'END_TO_END.bend').read_text())}
mapping_path=root/'docs/LAW_MIGRATION.json'
if not mapping_path.is_file():raise SystemExit('Missing old-to-array law correspondence map')
mapping=json.loads(mapping_path.read_text())
if set(mapping)!=set(expected):raise SystemExit('Every original law requires a correspondence entry')
for old,row in mapping.items():
    if not isinstance(row,dict) or row.get('original_statement')!=expected[old]:raise SystemExit('Original law evidence changed: '+old)
    name=row.get('new_law')
    if name not in actual or row.get('new_statement')!=actual[name] or not row.get('equivalence_argument'):raise SystemExit('Missing checked counterpart or equivalence explanation: '+old)
print('Law map complete; independent semantic audit must verify non-weakening')
subprocess.run([sys.executable,'automation/root_domain_acceptance.py'],cwd=root,check=True)
subprocess.run([sys.executable,'native_bench/run.py'],cwd=root,check=True)
print('Native comparison and prior proof/conformance gates passed; memory optimality and proof linkage require independent audit')

report=json.loads((root/'build/native/comparison.json').read_text())
if not report.get('complete') or len(report.get('cases',[])) != 5:
    raise SystemExit('Incomplete native memory report')
for case in report['cases']:
    samples=[s for s in case['samples'] if s['implementation']=='bend']
    if len(samples)<3: raise SystemExit('Need 3 native Bend samples per fixture')
    for sample in samples:
        base=sample.get('baseline_rss_bytes');peak=sample.get('decode_peak_rss_bytes');overhead=sample.get('decode_overhead_bytes')
        if any(type(x) is not int or x<0 for x in [base,peak,overhead]):
            raise SystemExit('Missing real native decode-phase memory measurements')
        if not sample.get('verified') or overhead!=max(0,peak-base) or overhead>32000000:
            raise SystemExit('Native decode overhead exceeds 32 MB or evidence is inconsistent')
print('Native decode overhead <=32,000,000 bytes in all 15 samples; semantic audit still required')
