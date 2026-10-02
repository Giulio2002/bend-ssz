#!/usr/bin/env python3
"""Apply ONE mutant to a private hard-linked tree and re-check one facade proof file with the pinned checker (server only).

    python3 tools/mutant_facade_run.py BASE_TREE WORK_DIR JOBS.json [-j N]

JOBS.json: [{"id": ..., "file": "types/X_encode_ssz_generated.bend", "line": L, "col": C, "before": "8", "after": "9",
             "facade": "proofs/api/X_encode_ssz_proof_generated.bend"}, ...]  (line 1-based, col as in the mutation report)
or, instead of line/col, "replace": ["old text", "new text"] applied once. Each job: `cp -al BASE WORK/<id>`, the one file is
replaced (never edited in place: the base shares its inodes), tools/check.sh runs on the facade, the tree is deleted at once.
Output: one line per job `id PASS|FAIL seconds first-error-line`, and JOBS.json.res. PASS = the mutant survives that facade.
"""
import json, os, pathlib, re, shutil, subprocess, sys, time, concurrent.futures as cf

base = pathlib.Path(sys.argv[1]).resolve(); work = pathlib.Path(sys.argv[2]).resolve(); jobs = json.load(open(sys.argv[3]))
nj = int(sys.argv[sys.argv.index('-j') + 1]) if '-j' in sys.argv else 3
work.mkdir(parents=True, exist_ok=True)


def one(j):
    t0 = time.time(); tree = work / str(j['id'])
    if tree.exists(): shutil.rmtree(tree)
    subprocess.run(['cp', '-al', str(base), str(tree)], check=True)
    try:
        f = tree / j['file']; txt = f.read_text()
        if 'replace' in j:
            assert txt.count(j['replace'][0]) == 1, 'replace target is not unique'
            txt = txt.replace(j['replace'][0], j['replace'][1])
        else:
            lines = txt.split('\n'); L = lines[j['line'] - 1]
            assert L[j['col']:j['col'] + len(j['before'])] == j['before'], 'site moved'
            lines[j['line'] - 1] = L[:j['col']] + j['after'] + L[j['col'] + len(j['before']):]; txt = '\n'.join(lines)
        f.unlink(); f.write_text(txt)
        env = dict(os.environ, CHECK_PINS_VERIFIED='1')
        r = subprocess.run(['bash', 'tools/check.sh', j['facade']], cwd=tree, capture_output=True, text=True, env=env)
        out = r.stdout + r.stderr
        res = 'PASS' if 'ALL PROOFS CHECK' in out else 'FAIL'
        err = ' | '.join(l.strip() for l in out.split('\n') if l.startswith(('- expected', '- observed', '- message')))[:300]
        m = re.search(r'CHECK_TIME (\S+)', out)
        return {'id': j['id'], 'result': res, 'seconds': float(m.group(1)) if m else round(time.time() - t0, 1), 'error': err}
    except Exception as e:
        return {'id': j['id'], 'result': 'ERROR', 'seconds': 0, 'error': repr(e)}
    finally:
        shutil.rmtree(tree, ignore_errors=True)


with cf.ThreadPoolExecutor(nj) as ex:
    res = []
    for r in ex.map(one, jobs):
        print(r['id'], r['result'], r['seconds'], r['error'], flush=True); res.append(r)
json.dump(res, open(sys.argv[3] + '.res', 'w'), indent=1)
