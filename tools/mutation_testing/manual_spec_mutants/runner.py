#!/usr/bin/env python3
"""runner.py: verdict (A) for hand-written spec mutants. Run on the ssz server, from anywhere.

  runner.py --tree TREE --work WORK --out RESULTS.json [--jobs 4] [--timeout 120] PATCH...

For each patch: a private hard-linked copy of the import cone of the facade proof file(s) it names (header lines
'# type:' and '# ops:'; ops default decode,encode,root), the one patched file copied and patched, and tools/check.sh on
each facade file (pinned checker, 120 s). Verdict per patch: KILLED (a law no longer checks; the failing laws are
listed), SURVIVED (ALL PROOFS CHECK: the proofs do not pin the rule), TIMEOUT (too slow, not a kill), ERROR (the
checker failed without naming a law: syntax or scope error in the patch; never counted as a kill).
The first killing facade stops the patch. The private tree is deleted afterwards.
"""
import argparse, concurrent.futures as cf, json, os, re, shutil, subprocess, sys, time

OPN = {'decode': 'decode_ssz', 'encode': 'encode_ssz', 'root': 'hashtreeroot'}
IMP = re.compile(r'^import\s+(\S+)', re.M)


def header(path):
    h = {}
    for l in open(path):
        if not l.startswith('#'):
            break
        m = re.match(r'# (\w+): (.*)', l)
        if m:
            h[m.group(1)] = m.group(2).strip()
        m = re.match(r'# MANUAL SPEC MUTANT (\S+)', l)
        if m:
            h['id'] = m.group(1)
    return h


def cone(tree, rel):
    seen, todo = set(), [rel]
    while todo:
        r = todo.pop()
        if r in seen:
            continue
        seen.add(r)
        for m in IMP.finditer(open(os.path.join(tree, r)).read()):
            t = m.group(1)
            if t == 'Base' or not t.endswith('.bend'):
                continue
            q = os.path.normpath(os.path.join(os.path.dirname(r), t))
            if os.path.exists(os.path.join(tree, q)):
                todo.append(q)
    return seen


def facades(h):
    out = []
    for t in h['type'].split(','):
        for op in h.get('ops', 'decode,encode,root').split(','):
            out.append((t, op, 'proofs/api/%s_%s_proof_generated.bend' % (t, OPN[op])))
    return out


def private_tree(tree, work, name, files, patch):
    d = os.path.join(work, name)
    shutil.rmtree(d, ignore_errors=True)
    for r in files:
        dst = os.path.join(d, r)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        os.link(os.path.join(tree, r), dst)
    os.makedirs(os.path.join(d, 'tools'))
    os.link(os.path.join(tree, 'tools/check.sh'), os.path.join(d, 'tools/check.sh'))
    target = patch['file']
    if target not in files:   # patched file outside the proof cone: still copy it so that the patch applies
        os.makedirs(os.path.dirname(os.path.join(d, target)), exist_ok=True)
        shutil.copy(os.path.join(tree, target), os.path.join(d, target))
    else:
        os.unlink(os.path.join(d, target))
        shutil.copy(os.path.join(tree, target), os.path.join(d, target))
    r = subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', patch['path']], cwd=d, capture_output=True, text=True)
    if r.returncode:
        raise RuntimeError('patch failed: ' + r.stdout + r.stderr)
    return d


def check(tree, d, facade, timeout, big=False):
    extra = dict(CHECK_STACK_KB="1048576", CHECK_JSC_STACK="800000000") if big else {}
    env = dict(os.environ, **extra, CHECK_PINS_VERIFIED='1', BEND_LIB=os.path.join(tree, 'vendor/bendhub'),
               BEND_LOCK=os.path.join(tree, 'toolchain.lock.json'), CHECK_TIMEOUT=str(timeout))
    t = time.time()
    r = subprocess.run(['nice', '-n', '19', 'bash', 'tools/check.sh', facade], cwd=d, env=env, capture_output=True, text=True)
    out = r.stdout + r.stderr
    secs = round(time.time() - t, 1)
    laws = sorted(set(re.findall(r'^Location: (\S+)', out, re.M)))
    if 'ALL PROOFS CHECK' in out and r.returncode == 0:
        v = 'SURVIVED'
    elif r.returncode == 124 or 'Terminated' in out:
        v = 'TIMEOUT'
    elif 'Maximum call stack' in out:
        v = 'STACK'
    elif laws or 'expected :' in out:
        v = 'KILLED'
    else:
        v = 'ERROR'
    msg = ''
    if v in ('KILLED', 'ERROR'):
        m = re.search(r'(- message[^\n]*|- expected[^\n]*\n- observed[^\n]*)', out)
        msg = (m.group(1) if m else out[-300:])[:300]
    return {'verdict': v, 'secs': secs, 'laws': laws, 'msg': msg}


def one(a, path):
    h = header(path)
    h['path'] = os.path.abspath(path)
    res = {'id': h['id'], 'type': h['type'], 'file': h['file'], 'checks': []}
    try:
        fs = facades(h)
        files = set()
        for _, _, f in fs:
            files |= cone(a.tree, f)
        d = private_tree(a.tree, a.work, h['id'].replace('/', '_'), files, h)
        verdict = 'SURVIVED'
        for t, op, f in fs:
            c = check(a.tree, d, f, a.timeout)
            if c['verdict'] == 'STACK':   # the checker ran out of stack on the mutant: retry once with a far larger stack
                c2 = check(a.tree, d, f, a.timeout, big=True)
                c2['first_try'] = 'STACK'
                c = c2 if c2['verdict'] != 'STACK' else dict(c2, verdict='CRASH')
            c.update(type=t, op=op)
            res['checks'].append(c)
            if c['verdict'] in ('KILLED', 'CRASH'):
                verdict = c['verdict']
                break
            if c['verdict'] in ('TIMEOUT', 'ERROR') and verdict == 'SURVIVED':
                verdict = c['verdict']
        res['A'] = verdict
        shutil.rmtree(d, ignore_errors=True)
    except Exception as e:
        res['A'] = 'ERROR'
        res['msg'] = str(e)[:300]
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True)
    ap.add_argument('--work', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--timeout', type=int, default=120)
    ap.add_argument('patches', nargs='+')
    a = ap.parse_args()
    a.tree = os.path.abspath(a.tree)
    os.makedirs(a.work, exist_ok=True)
    lock = '/srv/ssz-optimization/agents/.fullcheck.lock'
    if os.path.exists(lock) and subprocess.run(['flock', '-n', lock, 'true']).returncode:
        print('the full check holds the lock; not starting', file=sys.stderr)
        sys.exit(3)
    done = {}
    if os.path.exists(a.out):
        done = {r['id']: r for r in json.load(open(a.out))}
    todo = [p for p in a.patches if header(p)['id'] not in done]
    results = list(done.values())
    with cf.ThreadPoolExecutor(min(a.jobs, 4)) as ex:
        for r in ex.map(lambda p: one(a, p), todo):
            results.append(r)
            print(r['id'], r['A'], [c['laws'] or c['msg'][:60] for c in r['checks'] if c['verdict'] != 'SURVIVED'][:1], flush=True)
            json.dump(results, open(a.out, 'w'), indent=1)
    json.dump(results, open(a.out, 'w'), indent=1)


if __name__ == "__main__":
    main()
