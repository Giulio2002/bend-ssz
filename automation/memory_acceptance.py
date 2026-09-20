"""Frozen semantics, proof statements, full conformance and process-memory cap."""
import hashlib,json,os,re,subprocess,sys
from pathlib import Path
import snappy
ROOT=Path(__file__).resolve().parents[1]
os.chdir(ROOT)
expected=json.loads((ROOT/'memory_bench/law-statements.json').read_text())
actual={m.group(1):m.group(0) for m in re.finditer(r'(?ms)^law (\w+):\n.*?(?=^def \1\()', (ROOT/'END_TO_END.bend').read_text())}
if any(actual.get(k)!=v for k,v in expected.items()):raise SystemExit('Existing END_TO_END propositions must remain unchanged')
subprocess.run([sys.executable,'automation/acceptance.py'],check=True)
output=ROOT/'build/memory';output.mkdir(parents=True,exist_ok=True)
rows=[]
for case in json.loads((ROOT/'memory_bench/cases.json').read_text()):
 data=snappy.decompress((ROOT/'fixtures'/case['case']/'serialized.ssz_snappy').read_bytes())
 if hashlib.sha256(data).hexdigest()!=case['sha256']:raise SystemExit('fixture hash mismatch')
 path=output/(case['case'].split('/')[-1]+'.ssz');path.write_bytes(data)
 samples=[]
 for _ in range(3):
  p=subprocess.run(['/Users/monkeair/.bun/bin/bun','--smol','--preload','tools/bend_loader.ts','memory_bench/deserialize.ts',str(path)],text=True,capture_output=True,check=True,timeout=600)
  sample=json.loads(p.stdout);samples.append(sample)
 row={'case':case['case'],'samples':samples};rows.append(row)
 (output/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
 if any(s['max_rss_kib']>256*1024 for s in samples):raise SystemExit('Peak deserialize RSS must be <=256 MiB on every sample: '+case['case'])
print('PASS: unchanged theorem statements, all proof/runtime/spectest gates, and 15 bounded-memory decodes')
