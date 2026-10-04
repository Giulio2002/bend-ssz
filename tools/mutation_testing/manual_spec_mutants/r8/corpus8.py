#!/usr/bin/env python3
"""corpus8.py (round 8: corpus.py on the current objprog layout {x,g}<k>_generated.bend, corpus groups/indices remapped to types/obj_groups.json and generic_obj_index.json by name; official vectors skipped when python-snappy is absent): verdict (B) for hand-written spec mutants. Run on the ssz server.

  corpus.py --tree TREE --work WORK --cases cases.jsonl --out corpus.json PATCH...

For each patch: a private hard-linked copy of the import cone of the object-program source of every group that holds a
representative type of the patch (benchmarks/objprog/{x,g}<k>.bend), the one patched file copied and patched, the program
compiled with the runtime compiler (BEND_RUNTIME, default the 2.0.34 release), and then
  (1) the reference corpus (tools/spec_audit/cases.py, 48,279 cases) restricted to the representative types, run with the
      protocol of tools/spec_audit/run_bend.py (decode, re-encode, root; reject = non-zero exit),
  (2) the official vectors of those types (cases.json: ssz_generic through codegen.core.generic.case_names, ssz_static by
      directory name) with the protocol of benchmarks/checks/{generic_,}object_conformance.py.
Verdict B per patch: KILLED (the number of disagreeing corpus cases and official vectors is listed) or SURVIVED.
"""
import argparse, collections, concurrent.futures as cf, glob, json, os, re, shutil, subprocess, sys, tempfile, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from runner import header, cone   # noqa: E402  (runner.py runs main() on import only when executed as a script)


def locate(tree, t):
    fork = json.load(open(os.path.join(tree, 'types/obj_groups.json')))
    gen = json.load(open(os.path.join(tree, 'types/generic_obj_index.json')))['generated']
    n = t[4:] if t.startswith('Fulu') else t
    if n in fork and (t.startswith('Fulu') or t not in gen):
        return n, 'g', fork[n]['group']
    if t in gen:
        return t, 'x', gen[t]['group']
    if n in fork:
        return n, 'g', fork[n]['group']
    raise KeyError(t)


def build(tree, work, name, patch, groups, bend):
    d = os.path.join(work, name)
    shutil.rmtree(d, ignore_errors=True)
    files = set()
    for p, k in groups:
        files |= cone(tree, 'benchmarks/objprog/%s%d_generated.bend' % (p, k))
    for r in files:
        dst = os.path.join(d, r)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        os.link(os.path.join(tree, r), dst)
    if patch is not None:
        tgt = patch['file']
        os.makedirs(os.path.dirname(os.path.join(d, tgt)), exist_ok=True)
        if os.path.exists(os.path.join(d, tgt)):
            os.unlink(os.path.join(d, tgt))
        shutil.copy(os.path.join(tree, tgt), os.path.join(d, tgt))
        r = subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', patch['path']], cwd=d, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('patch failed ' + r.stdout + r.stderr)
    os.makedirs(os.path.join(d, 'build'), exist_ok=True)
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    for p, k in groups:
        out = os.path.join(d, 'build', 'obj-%s%d' % (p, k))
        t = time.time()
        r = subprocess.run(['nice', '-n', '19', bend, 'benchmarks/objprog/%s%d_generated.bend' % (p, k), '-o', out], cwd=d, env=env, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('compile failed %s%d: %s' % (p, k, (r.stdout + r.stderr)[-400:]))
    return d


CASE_TIMEOUT = 120
MAXHEX = 400000
REMAP = {}


def run_prog(prog, idx, data, tmp):
    inp = tempfile.mktemp(dir=tmp, suffix='.ssz')
    open(inp, 'wb').write(data)
    out = inp + '.out'
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(idx), 'SSZ_OPS': '1', 'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}
    try:
        r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=CASE_TIMEOUT)
        acc = r.returncode == 0 and 'DECODED=1' in r.stdout
        root = enc = None
        if acc:
            m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
            root = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')).hex() if m else None
            enc = open(out, 'rb').read() if os.path.exists(out) else None
        return acc, root, enc
    except subprocess.TimeoutExpired:
        return 'timeout', None, None
    finally:
        for p in (inp, out):
            if os.path.exists(p):
                os.unlink(p)


def corpus_cases(path, wanted):
    out = []
    for l in open(path):
        if '"type": "' not in l:
            continue
        m = re.search(r'"type": "([^"]+)"', l)
        if m and m.group(1) in wanted:
            c = json.loads(l)
            g = REMAP.get((c["src"], c["type"]))
            if g is None:
                continue
            c["group"], c["index"] = g
            if c['hex'] is not None and len(c['hex']) < MAXHEX:
                out.append(c)
    return out


def official(tree, wanted_fork, wanted_gen, snappy):
    """yield (kind, name, valid, data, want_root, src, group, index, case)"""
    sys.path.insert(0, tree)
    sys.path.insert(0, os.path.join(tree, 'tools'))
    os.chdir(tree)
    from codegen.core import generic as GEN
    gen = json.load(open('types/generic_obj_index.json'))['generated']
    fork = json.load(open('types/obj_groups.json'))
    owner = GEN.case_names()
    cases = json.load(open('cases.json'))
    res = []
    for c in cases:
        if '/ssz_generic/' in c:
            name = owner[c]
            if name not in wanted_gen and name not in wanted_fork:
                continue
            g = gen.get(name)
            src = 'x' if g else 'g'
            g = g or fork.get(name)
            if g is None:
                continue
            f = 'meta.yaml'
        elif '/ssz_static/' in c:
            name = c.split('/')[4]
            if name not in wanted_fork:
                continue
            g = fork[name]
            src = 'g'
            f = 'roots.yaml'
        else:
            continue
        d = os.path.join('fixtures', c)
        data = snappy.decompress(open(os.path.join(d, 'serialized.ssz_snappy'), 'rb').read())
        if len(data) * 2 >= MAXHEX:
            continue
        valid = '/ssz_static/' in c or '/valid/' in c
        want = None
        if valid:
            want = re.search(r'0x([0-9a-f]{64})', open(os.path.join(d, f)).read()).group(1)
        res.append((name, valid, data, want, src, g['group'], g['index'], c))
    return res


def one(a, path):
    h = header(path)
    h['path'] = os.path.abspath(path)
    res = {'id': h['id'], 'type': h['type']}
    t0 = time.time()
    try:
        types = h['type'].split(',')
        loc = [locate(a.tree, t) for t in types]
        groups = sorted({(p, k) for _, p, k in loc})
        d = build(a.tree, a.work, 'b_' + h['id'].replace('/', '_'), h, groups, a.bend)
        wanted = {n for n, _, _ in loc}
        cases = corpus_cases(a.cases, wanted)
        tmp = tempfile.mkdtemp(dir=a.work)
        bad = []
        def rc(c):
            prog = os.path.join(d, 'build', 'obj-%s%d' % ('x' if c['src'] == 'generic' else 'g', c['group']))
            if not os.path.exists(prog):
                return None
            acc, root, enc = run_prog(prog, c['index'], bytes.fromhex(c['hex']), tmp)
            rv = c['verdict']
            kind = None
            if acc == 'timeout':
                kind = 'timeout'
            elif rv == 'accept' and not acc:
                kind = 'ref accepts, mutant rejects'
            elif rv == 'reject' and acc:
                kind = 'ref rejects, mutant accepts'
            elif rv == 'accept' and acc:
                if enc != bytes.fromhex(c['hex']):
                    kind = 're-encoding differs'
                elif root != c['root']:
                    kind = 'root differs'
            return (c['id'], kind) if kind else None
        with cf.ThreadPoolExecutor(a.jobs) as ex:
            for r in ex.map(rc, cases):
                if r:
                    bad.append(r)
        # official vectors
        try:
            import snappy
        except ImportError:
            snappy = None
        ov = [] if snappy is None else official(a.tree, {n for n, p, _ in loc if p == 'g'} | set(), {n for n, p, _ in loc}, snappy)
        obad = []
        def ro(v):
            name, valid, data, want, src, grp, idx, c = v
            prog = os.path.join(d, 'build', 'obj-%s%d' % (src, grp))
            if not os.path.exists(prog):
                return None
            acc, root, enc = run_prog(prog, idx, data, tmp)
            if valid:
                ok = acc is True and enc == data and root == want
            else:
                ok = not acc
            return None if ok else c
        with cf.ThreadPoolExecutor(a.jobs) as ex:
            for r in ex.map(ro, ov):
                if r:
                    obad.append(r)
        kinds = collections.Counter(k for _, k in bad)
        real = [b for b in bad if b[1] != 'timeout']
        res.update(cases=len(cases), official=len(ov), corpus_bad=len(real), official_bad=len(obad), kinds=dict(kinds),
                   timeouts=kinds.get('timeout', 0),
                   examples=[f'{i}: {k}' for i, k in real[:4]] + obad[:3], B='KILLED' if (real or obad) else ('TIMEOUT-ONLY' if bad else 'SURVIVED'),
                   secs=round(time.time() - t0, 1))
        shutil.rmtree(d, ignore_errors=True)
        shutil.rmtree(tmp, ignore_errors=True)
    except Exception as e:
        res.update(B='ERROR', msg=str(e)[:400])
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True)
    ap.add_argument('--work', required=True)
    ap.add_argument('--cases', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--maxhex', type=int, default=400000)
    ap.add_argument('--case-timeout', type=int, default=120)
    ap.add_argument('--bend', default=os.environ.get('BEND_RUNTIME', '/srv/ssz-optimization/toolchain-2.0.34/bin/bend'))
    ap.add_argument('patches', nargs='+')
    a = ap.parse_args()
    global CASE_TIMEOUT, MAXHEX
    CASE_TIMEOUT, MAXHEX = a.case_timeout, a.maxhex
    a.tree = os.path.abspath(a.tree)
    global REMAP
    fork = json.load(open(os.path.join(a.tree, "types/obj_groups.json")))
    gen = json.load(open(os.path.join(a.tree, "types/generic_obj_index.json")))["generated"]
    REMAP = {("fulu", k): (v["group"], v["index"]) for k, v in fork.items()}
    REMAP.update({("generic", k): (v["group"], v["index"]) for k, v in gen.items()})
    a.work = os.path.abspath(a.work)
    a.cases = os.path.abspath(a.cases)
    a.out = os.path.abspath(a.out)
    a.patches = [os.path.abspath(p) for p in a.patches]
    done = {}
    if os.path.exists(a.out):
        done = {r['id']: r for r in json.load(open(a.out))}
    results = list(done.values())
    for p in a.patches:
        if header(p)['id'] in done:
            continue
        r = one(a, p)
        results.append(r)
        print(r['id'], r['B'], r.get('corpus_bad'), r.get('official_bad'), r.get('msg', '')[:100], flush=True)
        json.dump(results, open(a.out, 'w'), indent=1)


if __name__ == '__main__':
    main()
