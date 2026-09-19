#!/usr/bin/env python3
"""Benchmark identical frozen mainnet Fulu SSZ fixtures, correctness first."""
import argparse,datetime,hashlib,json,os,platform,statistics,subprocess,sys,time
from pathlib import Path
import snappy
from ruamel.yaml import YAML
ROOT=Path(__file__).resolve().parent
BUN='/Users/monkeair/.bun/bin/bun'
def run(cmd,cwd):
 p=subprocess.run(cmd,cwd=cwd,text=True,stdout=subprocess.PIPE,check=True,env={**os.environ,'BEND_NO_TELEMETRY':'1'})
 return p.stdout

def main():
 p=argparse.ArgumentParser();p.add_argument('--type',choices=['BeaconState'],default='BeaconState');p.add_argument('--case',default='all',help='all or case_0 through case_4');p.add_argument('--samples',type=int,default=5);p.add_argument('--output',default='results.json');a=p.parse_args()
 if a.samples<3:p.error('use at least 3 samples')
 cases=[c for c in json.loads((ROOT.parent/'cases.json').read_text()) if '/'+a.type+'/' in c and (a.case=='all' or c.endswith('/'+a.case))]
 if not cases:p.error('no matching fixtures')
 run(['go','build','-o','benchmark','.'],ROOT/'fastssz')
 results={'complete':False,'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'machine':platform.platform(),'cpu':run(['sysctl','-n','machdep.cpu.brand_string'],ROOT).strip(),'type':a.type,'samples':a.samples,'source':json.loads((ROOT/'source.json').read_text()),'go_modules':run(['go','list','-m','all'],ROOT/'fastssz'),'method':'Named public APIs. Native input representations prebuilt. Correctness verifies exact serialized bytes and official root before timing. Fresh allocating deserialization/serialization; no cached Merkle tree. Compilation, disk IO and host representation conversion excluded. One untimed warmup per operation after correctness. Go: >=300ms per sample, single GOMAXPROCS; Bend: one operation per sample with --smol. GC enabled; no forced GC. Other workflows remain running: exploratory, shared-machine results.','cases':[]}
 results['updated_at']=results['started_at']
 results['selected_cases']=cases
 results['benchmark_sha256']={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [ROOT/'benchmark.ts',ROOT/'fastssz/main.go',ROOT/'fastssz/go.mod',ROOT/'fastssz/go.sum']}
 (ROOT/a.output).write_text(json.dumps(results,indent=2)+'\n')
 inputs=ROOT/'inputs';inputs.mkdir(exist_ok=True)
 for i,c in enumerate(cases):
  path=ROOT.parent/'fixtures'/c;data=snappy.decompress((path/'serialized.ssz_snappy').read_bytes());root=YAML(typ='safe').load((path/'roots.yaml').read_text())['root'].removeprefix('0x');f=inputs/(c.split('/')[-1]+'.ssz');f.write_bytes(data)
  metadata=YAML(typ='safe').load((path/'value.yaml').read_text())
  row={'case':c,'validators':len(metadata['validators']),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'root':root,'results':{}}
  cmds={'fastssz':[str(ROOT/'fastssz/benchmark'),str(f),root,str(a.samples)],'bend':[BUN,'--smol','--preload',str(ROOT.parent/'tools/bend_loader.ts'),str(ROOT/'benchmark.ts'),str(f),root,str(a.samples)]}
  print(f'Benchmarking {c}: {len(data):,} bytes',flush=True)
  for impl in (['fastssz','bend'] if i%2==0 else ['bend','fastssz']):
   print('Running '+impl,flush=True);row['results'][impl]=json.loads(run(cmds[impl],ROOT.parent if impl=='bend' else ROOT/'fastssz'))
   (ROOT/(c.split('/')[-1]+'.'+impl+'.json')).write_text(json.dumps(row['results'][impl],indent=2)+'\n')
  row['summary']={}
  for op in ['deserialize','serialize','hash_tree_root']:
   values={k:statistics.median(v['operations'][op]['ns_per_op']) for k,v in row['results'].items()};row['summary'][op]={'fastssz_ms':values['fastssz']/1e6,'bend_ms':values['bend']/1e6,'bend_over_fastssz':values['bend']/values['fastssz']}
  results['cases'].append(row);results['updated_at']=datetime.datetime.now(datetime.timezone.utc).isoformat();(ROOT/a.output).write_text(json.dumps(results,indent=2)+'\n')
  print(json.dumps(row['summary'],indent=2),flush=True)
 results['complete']=True;(ROOT/a.output).write_text(json.dumps(results,indent=2)+'\n')
 lines=['# Fulu BeaconState SSZ benchmark','',results['method'],'','| Fixture | Bytes | Operation | fastssz ms | Bend ms | Bend / fastssz |','|---|---:|---|---:|---:|---:|']
 for c in results['cases']:
  for op,s in c['summary'].items():lines.append(f"| {c['case'].split('/')[-1]} | {c['bytes']} | {op} | {s['fastssz_ms']:.3f} | {s['bend_ms']:.3f} | {s['bend_over_fastssz']:.1f}× |")
 (ROOT/'RESULTS.md').write_text('\n'.join(lines)+'\n')
if __name__=='__main__':main()
