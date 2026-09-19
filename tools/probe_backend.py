#!/usr/bin/env python3
"""Diagnostic repeated exact comparison of one valid case, not full acceptance."""
import argparse
import datetime
import json
import os
from pathlib import Path
import subprocess
import time
import uuid
import snappy
from spectests import ROOT,BUN,PRELOAD,yaml
from test_schemas import for_case,normalize
from run_evidence import preserve_report,sha256_file


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--case',required=True)
    p.add_argument('--report',type=Path,required=True)
    p.add_argument('--repeat',type=int,default=3)
    p.add_argument('--timeout',type=float,default=1800)
    p.add_argument('--smol',action='store_true')
    a=p.parse_args()
    if a.repeat<1:p.error('repeat must be positive')
    if a.case not in json.loads((ROOT/'cases.json').read_text()):p.error('case outside frozen inventory')
    if '/ssz_static/' not in a.case and a.case.split('/')[-2]!='valid':p.error('expected a valid case')
    path=ROOT/'fixtures'/a.case
    schema=for_case(a.case)
    data=list(snappy.decompress((path/'serialized.ssz_snappy').read_bytes()))
    value=normalize(schema,yaml.load((path/'value.yaml').read_text()))
    root_file='roots.yaml' if '/ssz_static/' in a.case else 'meta.yaml'
    root=list(bytes.fromhex(yaml.load((path/root_file).read_text())['root'][2:]))
    req={'type':'generic','schema':schema}
    if '/ssz_static/' in a.case:req['name']=a.case.split('/')[4]
    requests=[{**req,'action':'decode','bytes':data}]+[{**req,'action':action,'value':value} for action in ('serialize','root')]
    command=[BUN]+(['--smol'] if a.smol else [])+['--preload',PRELOAD,'tools/primitive_backend.ts']
    evidence={'kind':'single-case diagnostic, not official acceptance','run_id':str(uuid.uuid4()),'command':command,'case':a.case,'started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'runtime_sha256':sha256_file(BUN),'expected_outputs_sent_to_backend':False}
    attempts=[]
    for i in range(a.repeat):
        start=time.monotonic();row={'attempt':i+1,'status':'failed'}
        try:
            r=subprocess.run(command,cwd=ROOT,env={**os.environ,'BEND_NO_TELEMETRY':'1'},input=json.dumps(requests),text=True,capture_output=True,timeout=a.timeout)
            row.update(exit=r.returncode,stderr=r.stderr)
            if r.returncode:raise RuntimeError('backend process failed')
            if json.loads(r.stdout)!=[{'kind':'accepted','value':x} for x in (value,data,root)]:raise RuntimeError('official value, bytes or root mismatch')
            row['status']='passed'
        except Exception as exc:row['error']=str(exc)
        row['seconds']=time.monotonic()-start;attempts.append(row)
        print(json.dumps(row),flush=True)
    evidence['finished_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    preserve_report({'evidence':evidence,'attempts':attempts},a.report)
    return 0 if all(x['status']=='passed' for x in attempts) else 1

if __name__=='__main__':raise SystemExit(main())
