#!/usr/bin/env python3
"""tools/closure_self_times.py ROOT.bend --out DIR [--jobs 3] [--scratch-tree]: the cost each module adds to a slow file.

A root file's time is the time of every module of its import closure, checked once each. This tool measures, for each
module M of that closure, t(M) (the file alone) and t(H(M)) (the same file cut before its first def/law: imports only);
self(M) = t(M) - t(H(M)) is what M's own definitions cost, and t(H(M)) what its imports cost. The modules with a large
self time are what to restructure; a module whose imports are slow and whose own time is small needs nothing.

The header variants are written next to the module (so its relative imports resolve) and deleted after the run: run it
only in a scratch copy of the tree (--scratch-tree says so), never in a tree a planner will read. Wall seconds under
BUN_JSC_numberOfGCMarkers=1 (one GC thread: the CPU of a check inflates with the machine's load otherwise); nice 19; the
load gate and the full-check lock of tools/file_times.py apply. DIR/closure.jsonl gets one line per module.
"""
import argparse
import concurrent.futures as cf
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import file_times as FT  # noqa: E402

ROOT = FT.ROOT


def closure(f):
    seen, todo = [], [f]
    while todo:
        x = todo.pop()
        if x in seen:
            continue
        seen.append(x)
        todo += FT.imports_of(x)
    return seen


def timed(f):
    env = dict(os.environ, CHECK_PINS_VERIFIED='1', BUN_JSC_numberOfGCMarkers='1', BUN_JSC_useConcurrentGC='0')
    t0 = time.time()
    r = subprocess.run(['nice', '-n', '19', 'tools/check.sh', f], cwd=ROOT, capture_output=True, text=True, env=env)
    return time.time() - t0, 'ALL PROOFS CHECK' in (r.stdout + r.stderr)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('root')
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--max-load', type=float, default=48.0)
    ap.add_argument('--scratch-tree', action='store_true')
    a = ap.parse_args()
    if not a.scratch_tree:
        sys.exit('closure_self_times: writes temporary header files into the tree: pass --scratch-tree in a scratch copy')
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    mods = [m for m in closure(a.root) if m.endswith('.bend') and not m.startswith(('src/', 'spec/', 'types/'))]
    print(len(mods), 'modules in the closure (src/, spec/, types/ excluded)', flush=True)

    def job(m):
        while FT.full_check_running(FT.LOCK) or FT.load1() > a.max_load:
            time.sleep(20)
        text = (ROOT / m).read_text().split('\n')
        st = [i for i, l in enumerate(text) if re.match(r'(def|law|type) ', l)]
        h = os.path.join(os.path.dirname(m), '_h_' + os.path.basename(m))
        (ROOT / h).write_text('\n'.join(text[:st[0]] if st else text) + '\n')
        try:
            th, ok1 = timed(h)
        finally:
            (ROOT / h).unlink()
        tf, ok2 = timed(m)
        r = {'file': m, 'wall': round(tf, 1), 'header_wall': round(th, 1), 'self_wall': round(tf - th, 1), 'defs': len(st), 'ok': ok1 and ok2}
        with open(out / 'closure.jsonl', 'a') as fh:
            fh.write(json.dumps(r) + '\n')
        return r

    with cf.ThreadPoolExecutor(a.jobs) as ex:
        rows = list(ex.map(job, mods))
    for r in sorted(rows, key=lambda r: -r['self_wall'])[:40]:
        print(f'{r["self_wall"]:7.1f} s self  {r["header_wall"]:7.1f} s imports  {r["wall"]:7.1f} s  {r["file"]}')


if __name__ == '__main__':
    main()
