#!/usr/bin/env python3
"""regen_all.py --touched: regenerate only the generators whose inputs changed (a dev-loop speedup).

    python3 codegen/regen_all.py --touched [-j N] [-v] [--passes K]
    python3 codegen/regen_all.py --touched --force a,b         # also rerun these generators (and whatever they change)
    python3 codegen/regen_all.py --reset-stamps                # forget what was recorded

Every generator run is traced (codegen/regen_trace/sitecustomize.py): the files it read, the directories it
listed, the modules it loaded (its own source included). build/regen_stamps.json records, per generator,
those inputs and their SHA-256 as of the generator's last clean run. A generator is dirty when it has no
stamp yet, or an input's content (or a listed directory's entries) differs from the stamp. --touched:
  1. runs `--check` on the generators with no stamp (first use in a checkout: about the cost of
     regen_all --check; afterwards never) and stamps the clean ones;
  2. runs the dirty generators (regen_all's write pass: generate first, the pool, the LAST ones one by one);
  3. repeats from the new hashes until nothing is dirty (a generator's outputs are the inputs of the
     generators after it, so its dependents come up dirty by themselves, once).
It prints CHANGED <file> for every file a generator rewrote with other content, and writes them to
build/regen_changed.txt. Only what changed since the stamps is regenerated, so a clean checkout costs
one hash pass (seconds).

This is NOT a gate: a stamp says "this generator's inputs are what they were when it last ran clean".
`regen_all.py --check` (every generator's own --check) stays the authority; the full-run outputs and a
--touched run are byte-identical (docs/BUILD.md, "Fast iteration"). tool_generators (which copies the
whole tree to a scratch dir) is stamped on tools/*.py and its own source only; regen_all --check still runs
it in full.
"""
import hashlib
import json
import os
import sys
import tempfile
import time
from pathlib import Path

_m = sys.modules.get('__main__')
if hasattr(_m, 'write_pass') and hasattr(_m, 'JOBS'):   # run as `python3 codegen/regen_all.py`: share its globals (JOBS)
    RA = _m
else:
    import regen_all as RA

ROOT = RA.ROOT
STAMPS = ROOT / 'build' / 'regen_stamps.json'
CHANGED = ROOT / 'build' / 'regen_changed.txt'
TRACE_DIR = ROOT / 'codegen' / 'regen_trace'
OPAQUE = {'tool_generators': ('tools/', 'codegen/tool_generators.py', 'codegen/regen_all.py')}
state = {'stamps': {}, 'changed': set()}


def sha(rel):
    try:
        return hashlib.sha256((ROOT / rel).read_bytes()).hexdigest()
    except OSError:
        return None


def lsha(rel):
    try:
        return hashlib.sha256('\0'.join(sorted(x for x in os.listdir(ROOT / rel) if x != '__pycache__' and not (rel == '.' and x in ('build', '.git')))).encode()).hexdigest()
    except OSError:
        return None


def merge(tdir):
    files, dirs, changed = {}, {}, set()
    for p in Path(tdir).glob('*.json'):
        try:
            d = json.loads(p.read_text())
        except ValueError:
            continue
        files.update(d['files'])
        dirs.update(d['dirs'])
        changed.update(d.get('changed', []))
    return files, dirs, changed


def traced_run(path, args):
    """regen_all.run, but recording the run's inputs as the generator's stamp when it succeeded"""
    t0 = time.time()
    name = Path(path).stem
    with tempfile.TemporaryDirectory(prefix='regen_trace_') as td:
        env = dict(os.environ, REGEN_TRACE=td, REGEN_ROOT=str(ROOT),
                   PYTHONPATH=str(TRACE_DIR) + (os.pathsep + os.environ['PYTHONPATH'] if os.environ.get('PYTHONPATH') else ''))
        r = RA.subprocess.run([sys.executable, str(path)] + args, cwd=ROOT, capture_output=True, text=True, env=env)
        out = (r.stdout + r.stderr).strip()
        bad = r.returncode != 0 or any(w in out.lower() for w in RA.FAIL_WORDS)
        files, dirs, changed = merge(td)
    if '--check' not in args:
        state['changed'] |= changed
    ok = (not bad) if '--check' in args else not (bad and ('traceback' in out.lower() or 'systemexit' in out.lower()))
    if ok:
        if name in OPAQUE:
            files = {k: v for k, v in files.items() if k.startswith(OPAQUE[name]) and k.endswith('.py')}
            for k in ROOT.joinpath('tools').glob('*.py'):
                files.setdefault(str(k.relative_to(ROOT)), sha(str(k.relative_to(ROOT))))
            dirs = {}
        state['stamps'][name] = {'files': files, 'dirs': dirs}
    else:
        state['stamps'].pop(name, None)
    return bad, out, time.time() - t0


def dirty(g, cache):
    s = state['stamps'].get(g)
    if s is None:
        return True
    for f, h in s['files'].items():
        if f not in cache:
            cache[f] = sha(f)
        if cache[f] != h:
            return True
    for d, h in s['dirs'].items():
        if ('d', d) not in cache:
            cache[('d', d)] = lsha(d)
        if cache[('d', d)] != h:
            return True
    return False


def save():
    STAMPS.parent.mkdir(exist_ok=True)
    tmp = STAMPS.with_suffix('.tmp')
    tmp.write_text(json.dumps(state['stamps']))
    os.replace(tmp, STAMPS)


def touched(order, have, verbose, passes):
    if STAMPS.exists():
        try:
            state['stamps'] = json.loads(STAMPS.read_text())
        except ValueError:
            state['stamps'] = {}
    state['stamps'] = {g: s for g, s in state['stamps'].items() if g in order}
    RA.run = traced_run                      # run_many / write_pass / check use the module global
    t0 = time.time()
    fresh = [g for g in order if g not in state['stamps']]
    if fresh:
        print(f'touched: {len(fresh)} generators have no stamp, checking them first', flush=True)
        RA.check(fresh, have, verbose)       # clean ones are stamped by traced_run
        save()
    rerun = {}
    for k in range(1, passes + 1):
        cache = {}
        d = [g for g in order if dirty(g, cache)]
        if not d:
            break
        print(f'touched pass {k}: {len(d)} dirty: {", ".join(d)}', flush=True)
        failed = {}
        for grp in RA.write_groups(order):     # dirtiness is re-read before each group: a group's outputs feed the next
            cache = {}
            todo = [g for g in grp if dirty(g, cache)]
            for g in todo:
                rerun[g] = rerun.get(g, 0) + 1
            for g, (bad, out, dt) in zip(todo, RA.run_many(todo, have, [])):
                if bad and ('traceback' in out.lower() or 'systemexit' in out.lower()):
                    failed[g] = out[-600:]
                    print(f'pass {k} {g} FAILED ({dt:.0f} s): {out.strip().splitlines()[-1][:200] if out.strip() else ""}', flush=True)
                elif verbose:
                    print(f'pass {k} {g} ({dt:.0f} s)', flush=True)
        save()
        if failed:
            for g, o in failed.items():
                print(f'FAIL  {g}: {o}', flush=True)
            raise SystemExit('touched: a generator failed')
    else:
        cache = {}
        left = [g for g in order if dirty(g, cache)]
        if left:
            raise SystemExit(f'touched: still dirty after {passes} passes (an input cycle?): {", ".join(left)}')
    ch = sorted(state['changed'])
    CHANGED.write_text(''.join(c + '\n' for c in ch))
    for c in ch:
        print('CHANGED ' + c)
    print(f'touched: converged in {time.time() - t0:.0f} s; reruns: {rerun or "none"}; {len(ch)} files changed')


def main(a, order, have):
    if '--reset-stamps' in a:
        STAMPS.unlink(missing_ok=True)
        return
    if '--force' in a:                       # --force a,b: treat these generators as dirty (their stamps are dropped)
        if STAMPS.exists():
            st = json.loads(STAMPS.read_text())
            for g in a[a.index('--force') + 1].split(','):
                st.pop(g, None)
            STAMPS.write_text(json.dumps(st))
    passes = int(a[a.index('--passes') + 1]) if '--passes' in a else 6
    touched(order, have, '-v' in a, passes)
