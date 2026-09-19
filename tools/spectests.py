#!/usr/bin/env python3
"""All frozen cases, strict outputs, bounded transport batches, no expected-output leakage."""
import argparse
import datetime
import uuid
import time
import json
import os
from pathlib import Path
import subprocess
import sys
import snappy
from ruamel.yaml import YAML
ROOT=Path(__file__).resolve().parents[1]
BUN='/Users/monkeair/.bun/bin/bun'
PRELOAD=str(ROOT/'tools/bend_loader.ts')  # local loader: modules compiled by the pinned Bend 2.0.16
TOOLCHAIN=json.loads((ROOT/'automation/toolchain.json').read_text())
yaml=YAML(typ='safe')

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--report',type=Path,required=True)
    parser.add_argument('--backend-timeout',type=float,default=1800,help='per-batch wall-clock resource limit; timeout is always failure')
    args=parser.parse_args()
    sys.path.insert(0,str(ROOT/'tools'))
    from test_schemas import for_case, normalize
    from run_evidence import preserve_report, sha256_file
    inventory=json.loads((ROOT/'cases.json').read_text())
    rows=[{'case':case,'status':'failed'} for case in inventory]
    evidence={'backend':'pure Bend recursive SSZ APIs compiled by pinned Bend '+TOOLCHAIN['version']+' via tools/bend_loader.ts','requests':0,'batches':0,'backend_exits':[],'expected_outputs_sent_to_backend':False}
    evidence.update(run_id=str(uuid.uuid4()),started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),workspace=str(ROOT),backend_command=[BUN,'--smol','--preload',PRELOAD,'tools/primitive_backend.ts'],backend_diagnostics=[],runtime_sha256=sha256_file(BUN),bend_version=TOOLCHAIN['version'],bend_sha256=sha256_file(TOOLCHAIN['bend']['path']),base_sha256=sha256_file(TOOLCHAIN['base']['path']),inventory_sha256=sha256_file(ROOT/'cases.json'),source_sha256={str(p.relative_to(ROOT)):sha256_file(p) for folder,pattern in [('src','*.bend'),('types','*.bend'),('spec','*.bend'),('tools','*.py'),('tools','*.ts')] for p in sorted((ROOT/folder).glob(pattern))})
    requests,jobs=[],[]
    pending_bytes=0
    def flush():
        if not requests:return
        evidence['requests']+=len(requests);evidence['batches']+=1
        started=time.monotonic()
        try:
            result=subprocess.run(evidence['backend_command'],cwd=ROOT,env={**os.environ,'BEND_NO_TELEMETRY':'1'},input=json.dumps(requests),text=True,capture_output=True,timeout=args.backend_timeout)
            evidence['backend_exits'].append(result.returncode)
            if result.returncode:
                evidence['backend_diagnostics'].append({'batch':evidence['batches'],'cases':[row['case'] for row,*_ in jobs],'exit':result.returncode,'seconds':time.monotonic()-started,'stderr':result.stderr})
                raise RuntimeError(result.stderr[-2000:])
            outputs=json.loads(result.stdout)
            if not isinstance(outputs,list) or len(outputs)!=len(requests):raise RuntimeError('backend output count mismatch')
            for row,start,valid,data,value,root in jobs:
                try:
                    decoded=outputs[start]
                    if not valid:
                        if decoded!={'kind':'rejected'}:raise ValueError('expected semantic rejection; received '+str(decoded)[:500])
                        row.update(status='passed',evidence='Bend decoder returned None')
                    else:
                        serialized,hashed=outputs[start+1:start+3]
                        if decoded!={'kind':'accepted','value':value}:raise ValueError('decoded value mismatch: '+str(decoded)[:500])
                        if serialized!={'kind':'accepted','value':data}:raise ValueError('official encoded bytes mismatch: '+str(serialized)[:500])
                        if hashed!={'kind':'accepted','value':list(root)} or len(root)!=32:raise ValueError('official root mismatch: '+str(hashed)[:500])
                        row.update(status='passed',evidence='exact official bytes, value and 32-byte root')
                except Exception as exc:row['error']=str(exc)
        except Exception as exc:
            for row,*_ in jobs:row['error']='backend failure: '+str(exc)
        print(f"batch {evidence['batches']}: {sum(r['status']=='passed' for r in rows)} passed so far",flush=True)
        requests.clear();jobs.clear()
    interrupted=False
    try:
        for row in rows:
            case=row['case']
            try:
                path=ROOT/'fixtures'/case
                data=list(snappy.decompress((path/'serialized.ssz_snappy').read_bytes()))
                schema=for_case(case)
                req={'type':'generic','schema':schema}
                if '/ssz_static/' in case: req['name']=case.split('/')[4]
                valid='/ssz_static/' in case or case.split('/')[-2]=='valid'
                value,root=None,None
                if valid:
                    value=normalize(schema,yaml.load((path/'value.yaml').read_text()))
                    root_file='roots.yaml' if '/ssz_static/' in case else 'meta.yaml'
                    root=bytes.fromhex(yaml.load((path/root_file).read_text())['root'][2:])
                start=len(requests)
                requests.append({**req,'action':'decode','bytes':data})
                if valid:requests.extend([{**req,'action':action,'value':value} for action in ('serialize','root')])
                jobs.append((row,start,valid,data,value,root))
                pending_bytes+=len(data)
                if len(requests)>=192 or pending_bytes>=1024*1024:
                    flush();pending_bytes=0
            except Exception as exc:row['error']='fixture/transport failure: '+str(exc)
        flush()
    except KeyboardInterrupt:
        interrupted=True
        for row in rows:
            if row['status']=='failed' and 'error' not in row:
                row['error']='run interrupted before a backend result was obtained'
    evidence['complete']=not interrupted
    passed=sum(row['status']=='passed' for row in rows)
    report={'cases':rows,'evidence':evidence,'passed':passed,'failed':len(rows)-passed}
    evidence['finished_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    preserve_report(report,args.report)
    print(f'SSZ: {passed} passed, {len(rows)-passed} failed, {len(rows)} inventoried')
    return 130 if interrupted else (0 if passed==len(inventory) else 1)

if __name__=='__main__':sys.exit(main())
