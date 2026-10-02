#!/usr/bin/env python3
"""Crash hunt: large and wide inputs through the compiled decode programs; records wall time and peak RSS per run.

    python3 tools/crash_hunt/scale_decode.py --repo . --out DIR [--mem-gb 12] [--timeout 120]

A few bytes forcing a large allocation, a count bomb (an offset table of empty elements), long progressive lists, long bit
lists. Expectation: time and memory grow about linearly with the input; anything else is a finding.
"""
import argparse
import json
import os
import resource
import subprocess
import sys
import tempfile
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hostile_decode import u32  # noqa: E402


def run(prog, idx, data, tmp, mem_gb, timeout):
    inp = os.path.join(tmp, 'in.ssz')
    out = inp + '.out'
    open(inp, 'wb').write(data)
    if os.path.exists(out):
        os.unlink(out)
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(idx), 'SSZ_OPS': '1', 'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}

    def lim():
        resource.setrlimit(resource.RLIMIT_AS, (int(mem_gb * 2**30), int(mem_gb * 2**30)))
        os.nice(19)
    t0 = time.time()
    p = subprocess.Popen([prog, '--threads', '1', '--gpu', 'off'], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, preexec_fn=lim)
    deadline = t0 + timeout
    timed_out = False
    while True:
        pid, status, ru = os.wait4(p.pid, os.WNOHANG)
        if pid:
            break
        if time.time() > deadline:
            p.kill()
            timed_out = True
            pid, status, ru = os.wait4(p.pid, 0)
            break
        time.sleep(0.05)
    so = p.stdout.read().decode(errors='replace')
    se = p.stderr.read().decode(errors='replace')
    sec = time.time() - t0
    rc = os.waitstatus_to_exitcode(status)
    same = os.path.exists(out) and open(out, 'rb').read() == data
    if timed_out:
        v = 'CRASH(timeout)'
    elif rc == 0 and 'DECODED=1' in so:
        v = 'ACCEPT' if same else 'WRONG(reencode differs)'
    elif rc == 1 and 'DECODED=0' in so:
        v = 'REJECT'
    else:
        v = 'CRASH(rc=%d %s)' % (rc, se[-150:].replace('\n', ' '))
    return {'verdict': v, 'sec': round(sec, 2), 'maxrss_mb': round(ru.ru_maxrss / 1024), 'input_mb': round(len(data) / 2**20, 2)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--out', required=True)
    ap.add_argument('--mem-gb', type=float, default=12)
    ap.add_argument('--timeout', type=int, default=120)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    groups = json.load(open(os.path.join(repo, 'types/obj_groups.json')))
    generic = json.load(open(os.path.join(repo, 'types/generic_obj_index.json')))['generated']

    def prog(name):
        g = groups.get(name) or generic[name]
        return os.path.join(repo, 'build', 'obj-%s%d' % ('g' if name in groups else 'x', g['group'])), g['index']
    seeds = {}
    for l in open(os.path.join(repo, 'tools/spec_audit/data/cases_sample.jsonl')):
        c = json.loads(l)
        if c['verdict'] == 'accept' and c['label'] == 'zero':
            seeds[c['type']] = bytes.fromhex(c['hex'])
    cases = []
    for lg in (16, 20, 24, 27):
        cases.append(('proglist_uint8', 'bytes 2^%d' % lg, b'\x55' * (1 << lg)))
    for lg in (16, 20, 23):
        cases.append(('proglist_uint64', 'u64 2^%d bytes' % lg, b'\x55' * (1 << lg)))
        cases.append(('proglist_bool', 'bool 2^%d bytes' % lg, b'\x01' * (1 << lg)))
        cases.append(('progbitlist', 'bits 2^%d bytes' % lg, b'\x55' * ((1 << lg) - 1) + b'\x01'))
    for lg in (16, 20, 24):
        cases.append(('Transaction', 'bytes 2^%d' % lg, b'\x55' * (1 << lg)))
    for lg in (16, 20):
        cases.append(('proglist_SmallTestStruct', '2^%d elements' % lg, b'\x01\x00\x02\x00' * (1 << lg)))
    vt = seeds.get('VarTestStruct')
    if vt:
        # VarTestStruct zero: A uint16, offset 7, C uint8, then the empty list; build the element with offset fixed at 7
        for lg in (12, 16, 18):
            k = 1 << lg
            body = b''.join(vt for _ in range(k))
            offs = b''.join(u32(4 * k + 7 * i) for i in range(k))
            cases.append(('proglist_VarTestStruct', '2^%d variable elements' % lg, offs + body))
    ep = seeds.get('FuluExecutionPayload') or seeds.get('ExecutionPayload')
    epn = 'FuluExecutionPayload' if 'FuluExecutionPayload' in seeds else 'ExecutionPayload'
    if ep and len(ep) == 528 and int.from_bytes(ep[504:508], 'little') == 528:
        for k in (1 << 10, 1 << 16, 1 << 20, (1 << 20) + 1):
            tx = b''.join(u32(4 * k) for _ in range(k))
            m = bytearray(ep)
            m[508:512] = u32(528 + 4 * k)  # withdrawals offset after the transaction part
            cases.append((epn, 'count bomb: %d empty transactions' % k, bytes(m) + tx))
    else:
        print('no ExecutionPayload zero seed of 528 bytes; skipped (seed len %s)' % (len(ep) if ep else None))
    res = []
    tmp = tempfile.mkdtemp(prefix='scale-', dir=a.out)
    for name, label, data in cases:
        try:
            pr, idx = prog(name)
        except KeyError:
            print('no program for', name)
            continue
        if not os.path.exists(pr):
            print('no build for', name, pr)
            continue
        r = run(pr, idx, data, tmp, a.mem_gb, a.timeout)
        r.update(type=name, label=label)
        res.append(r)
        print(json.dumps(r), flush=True)
    json.dump(res, open(os.path.join(a.out, 'scale_decode.json'), 'w'), indent=1)


if __name__ == '__main__':
    main()
