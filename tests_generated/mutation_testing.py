"""Mutation testing of the generated runtime and of the proofs that reach it.

    python3 tests_generated/mutation_testing.py --scratch DIR [--per-type 5] [--seed N] [--types A,B] [--no-proofs]

The question: would the evidence suite notice if the generated encoder, decoder or root code were wrong? The
other harnesses feed corrupted INPUT to correct code; this one corrupts the CODE and requires the harnesses to fail.

Runtime side. For every Fulu name and every generic name, MUTANTS_PER_TYPE (default 5) mutants are drawn, seeded
and deterministic, from the sites of types/<Name>_{decode_ssz,encode_ssz,hashtreeroot}_generated.bend (the code the
object programs run): a numeric constant changed by +1 or -1 (an offset, a size, a depth; out_at(d) +1 is an over-allocated buffer, -1 an under-allocated one; a comparison is flipped to each of is_lt / is_le / is_ge), a comparison flipped
(is_eq -> is_lt, is_lt -> is_le, is_le -> is_lt), an addition turned into a subtraction, a validity result
forced (True{} -> False{}, False{} -> True{}), the two children of a hash_tree_root node swapped
(D.node(h, a, b) -> D.node(h, b, a); only the root files have them). The sites are drawn round-robin over the operators. The mutants
are applied in rounds, one per type per round, in a SCRATCH COPY of the tree (--scratch: never the real tree);
the programs (build/obj-g<k>, obj-x<k>, fuzz-f<k>) are rebuilt through benchmarks/quick.py (cached by import
cone, QUICK_NO_GENERATE=1 so the generator does not overwrite the mutant); then, for each mutant, the suite is
run for the mutated type only:

    official vectors   object_conformance.py --only <Name>  /  generic_object_conformance.py --only <Name>
    fuzzing            fuzz_objects.py --only <Name>   (valid values, random and field-boundary corruptions,
                       setter histories: against the independent oracle)

A mutant is KILLED if either exits non-zero; it SURVIVES if both pass; it is INVALID if a program that imports it
no longer compiles (excluded from the rate). A survivor is a gap in the tests, or an equivalent mutant: the
survivors are listed with the def they sit in. Not run per mutant: the Bun tests, invalid_objects, negative_api,
mutations.py and object_cache (they exercise other programs); a survivor in a validity or serializer def is
therefore the place those would have to cover.

Proof side. A handful of the runtime mutants (compiled, not invalid) of PROOF_NAMES names are applied one at a time
and the facade proof file that reaches that code (proofs/api/<Name>_<op>_ssz_proof_generated.bend, whose statements
are locked: the mutant changes definitions, never a statement) is re-checked with the pinned checker
(tools/check.sh). The check must FAIL. A mutant whose proof still checks is reported (equivalent, or not reached).

The result is benchmarks/evidence/mutation_testing.json, with the list of mutants and their outcomes.
"""
import argparse
import collections
import concurrent.futures as cf
import hashlib
import json
import os
import pathlib
import random
import re
import shutil
import subprocess
import sys
import time

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'benchmarks/checks'))
from provenance import stamp  # noqa: E402

OPS = ('decode', 'encode', 'hashtreeroot')
OPERATORS = ('const+1', 'const-1', 'cmp', 'addsub', 'valid', 'swap')
CMP = {'U32.is_eq(': ['U32.is_lt(', 'U32.is_le(', 'U32.is_ge('], 'U32.is_lt(': ['U32.is_le('], 'U32.is_le(': ['U32.is_lt(']}


def code_lines(text):
    for i, line in enumerate(text.split('\n')):
        s = line.strip()
        if s and not s.startswith('#') and not s.startswith('import'):
            yield i, line


def node_calls(line):
    """[(start, end, args)] for each D.node(...) call on one line: args split at the top level."""
    out = []
    for m in re.finditer(r'D\.node\(', line):
        depth, args, cur, j = 1, [], '', m.end()
        while j < len(line) and depth:
            c = line[j]
            if c in '([{':
                depth += 1
            elif c in ')]}':
                depth -= 1
            if depth == 0:
                break
            if c == ',' and depth == 1:
                args.append(cur.strip())
                cur = ''
            else:
                cur += c
            j += 1
        args.append(cur.strip())
        if depth == 0 and len(args) == 3:
            out.append((m.start(), j + 1, args))
    return out


def sites(text, keep_classed=False):
    """[(line index, column, operator, before, after)] for every mutable site of a generated file."""
    out = []
    for i, line in code_lines(text):
        for m in re.finditer(r'(?<![\w.])(\d+)(n?)(?![\w.])', line):
            out.append((i, m.start(), 'const+1', m.group(0), str(int(m.group(1)) + 1) + m.group(2)))
            if int(m.group(1)) >= 1:   # one too small: an under-allocated buffer, a limit or size one short
                out.append((i, m.start(), 'const-1', m.group(0), str(int(m.group(1)) - 1) + m.group(2)))
        for a, bs in CMP.items():
            for m in re.finditer(re.escape(a), line):
                for b in bs:
                    out.append((i, m.start(), 'cmp', a, b))
        for m in re.finditer(r' \+ (?=[1-9]\d* : U32\))', line):   # `+ 0` -> `- 0` changes nothing: not drawn
            out.append((i, m.start(), 'addsub', ' + ', ' - '))
        for st, en, args in node_calls(line):   # hash_tree_root: the two children of a Merkle node swapped
            if args[1] != args[2]:
                out.append((i, st, 'swap', line[st:en], f'D.node({args[0]}, {args[2]}, {args[1]})'))
        if re.search(r'\(buf, (True|False)\{\}\)|-> Bool: (True|False)\{\}$', line):
            for m in re.finditer(r'(True|False)\{\}', line):
                out.append((i, m.start(), 'valid', m.group(0), 'False{}' if m.group(1) == 'True' else 'True{}'))
    return out


EXCLUSIONS_FILE = pathlib.Path(__file__).with_name('mutation_exclusions.json')
_EXCL = None


def excluded(rel, dn, st, line):
    """True if this mutation is on the known-equivalent / uncoverable list (tests_generated/mutation_exclusions.json:
    file, def, operator, before, after, the line's text and the COLUMN of the site within it; a class and the reason are recorded
    with each entry). One entry hides one site: a sibling site of the same line with the same literal is drawn on its own.
    Such sites are never drawn and never reported as survivors."""
    global _EXCL
    if _EXCL is None:
        _EXCL = set()
        if EXCLUSIONS_FILE.exists():
            for e in json.loads(EXCLUSIONS_FILE.read_text())['entries']:
                _EXCL.add((e['file'], e['def'], e['operator'], e['before'], e['after'], e['text'], e['col']))
    return (rel, dn, st[2], st[3], st[4], line.strip()[:200], st[1] - (len(line) - len(line.lstrip()))) in _EXCL


def def_name(text, lineno):
    lines = text.split('\n')
    for j in range(lineno, -1, -1):
        m = re.match(r'def (\w+)', lines[j])
        if m:
            return m.group(1)
    return None


def apply(text, site):
    i, col, _op, before, after = site
    lines = text.split('\n')
    assert lines[i][col:col + len(before)] == before, (lines[i], col, before)
    lines[i] = lines[i][:col] + after + lines[i][col + len(before):]
    return '\n'.join(lines)


def type_files(root, name):
    for pre in ('Fulu' + name, name):
        fs = {op: root / (f'types/{pre}_{op}_generated.bend' if op == 'hashtreeroot'
                          else f'types/{pre}_{op}_ssz_generated.bend') for op in OPS}
        if fs['decode'].exists() and fs['encode'].exists():
            return pre, {op: f for op, f in fs.items() if f.exists()}
    return None, {}


def draw(root, name, n, seed):
    """n mutants of a type, round-robin over the operators, seeded."""
    pre, files = type_files(root, name)
    rng = random.Random(f'{seed}:{name}')
    pool = collections.defaultdict(list)
    for op, f in sorted(files.items()):
        text = f.read_text()
        lines = text.split('\n')
        for s in sites(text):
            dn = def_name(text, s[0])
            if excluded(f.relative_to(root).as_posix(), dn, s, lines[s[0]]):
                continue
            pool[s[2]].append((op, f, s, dn))
    for v in pool.values():
        v.sort(key=lambda x: (x[0], x[2][0], x[2][1], x[2][3]))
        rng.shuffle(v)
    picked, ops = [], [o for o in OPERATORS if pool[o]]
    rng.shuffle(ops)
    while len(picked) < n and any(pool[o] for o in ops):
        for o in ops:
            if pool[o] and len(picked) < n:
                picked.append(pool[o].pop())
    return pre, picked


def import_cone(entry):
    seen, todo = [], [entry.resolve()]
    while todo:
        f = todo.pop()
        if f in seen:
            continue
        seen.append(f)
        for m in re.finditer(r'^import\s+(\S+\.bend)', f.read_text(), re.M):
            if not m.group(1).startswith('0x'):
                todo.append((f.parent / m.group(1)).resolve())
    return seen


class Scratch:
    def __init__(self, root):
        self.root = root
        self.env = {**os.environ, 'QUICK_NO_GENERATE': '1', 'EVIDENCE_NO_STAMP': '1', 'BEND_NO_TELEMETRY': '1'}

    def build(self, kind, k):
        flag = {'g': '--build', 'x': '--build-generic', 'f': '--build-fuzz'}[kind]
        r = subprocess.run([sys.executable, 'benchmarks/quick.py', flag, str(k)], cwd=self.root, env=self.env,
                           capture_output=True, text=True)
        return r.returncode == 0, (r.stdout + r.stderr)[-6000:]

    def build_all(self, programs, workers):
        with cf.ThreadPoolExecutor(workers) as ex:
            res = list(ex.map(lambda p: (p, self.build(*p)), programs))
        return {p: r for p, r in res}

    def test(self, cmd, suffix, timeout):
        env = {**self.env, 'SSZ_TMP_SUFFIX': suffix}
        try:
            r = subprocess.run([sys.executable] + cmd, cwd=self.root, env=env, capture_output=True, text=True,
                               timeout=timeout)
            return r.returncode, (r.stdout + r.stderr)[-400:]
        except subprocess.TimeoutExpired:
            return 124, 'timeout'


FULLCHECK_LOCK = '/srv/ssz-optimization/agents/.fullcheck.lock'


def wait_flock():
    """Never start a check while a full check holds the lock (the server is shared): test it, do not rely on a freeze."""
    while os.path.exists(FULLCHECK_LOCK):
        r = subprocess.run(['flock', '-n', FULLCHECK_LOCK, 'true'], capture_output=True)
        if r.returncode == 0:
            return
        time.sleep(15)


def run_guarded(cmd, cwd, env, timeout):
    """One private check: waits for the flock, runs at nice 19 in its own process group, and on the time limit kills the
    WHOLE group (check.sh and the bend it started), then reaps it. Returns (returncode, output); raises TimeoutExpired."""
    import signal
    wait_flock()
    p = subprocess.Popen(['nice', '-n', '19'] + cmd, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True, start_new_session=True)
    try:
        out, _ = p.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(p.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        p.communicate()
        raise
    return p.returncode, out


def classify(rec):
    """The cause group of a mutation: what a gap in it would mean."""
    text = rec.get('text', '')
    d = rec.get('def') or ''
    if rec['in'] == 'hashtreeroot':
        return 'merkle-structure' if rec['operator'] == 'swap' else 'hashtreeroot-constant'
    if rec['operator'] == 'valid' or re.search(r'(^|_)(valid|ok|ok_at|ok_len|c\d+)($|_)', d):
        return 'validity-check'
    if re.search(r'out_at\(|alloc|cap', text):
        return 'capacity-1' if rec['operator'] == 'const-1' else 'capacity'
    if re.search(r'(^|_)(size|bx_size|len|sz)($|_)', d) or d.endswith('_size'):
        return 'reported-size'
    if rec['in'] == 'decode' and re.search(r'(rd\d*|_at|off|read|build)', d):
        return 'offset'
    if rec['operator'] == 'cmp':
        return 'comparison'
    return 'constant' if rec['operator'] == 'const+1' else 'arithmetic'


def api_file(S, pre, op):
    return S / (f'proofs/api/{pre}_hashtreeroot_proof_generated.bend' if op == 'hashtreeroot'
                else f'proofs/api/{pre}_{op}_ssz_proof_generated.bend')


def proof_wide(S, a, names):
    """Proof side, wide: for every name and operation with a facade proof, up to --proof-wide seeded mutants of the
    generated definitions it reaches; each is applied alone and the one proof file is re-checked (tools/check.sh,
    the pinned checker). Up to --proof-jobs checks run at once, each in a private tree holding the proof's import cone (same
    relative paths) with only its own mutant applied, so no check sees another's mutant."""
    memo = {}

    def cone_of(f):
        f = f.resolve()
        if f not in memo:
            memo[f] = {c for c in import_cone(f)}
        return memo[f]

    tasks = []
    for n, fam in names:
        pre, files = type_files(S, n)
        if not pre:
            continue
        for op, f in sorted(files.items()):
            api = api_file(S, pre, op)
            if not api.exists():
                continue
            text = f.read_text()
            rng = random.Random(f'{a.seed}:wide:{n}:{op}')
            pool = collections.defaultdict(list)
            lines = text.split('\n')
            for st in sites(text):
                if excluded(f.relative_to(S).as_posix(), def_name(text, st[0]), st, lines[st[0]]):
                    continue
                pool[st[2]].append(st)
            for v in pool.values():
                v.sort(key=lambda x: (x[0], x[1], x[3]))
                rng.shuffle(v)
            ops = [o for o in OPERATORS if pool[o]]
            rng.shuffle(ops)
            picked = []
            while len(picked) < a.proof_wide and any(pool[o] for o in ops):
                for o in ops:
                    if pool[o] and len(picked) < a.proof_wide:
                        picked.append(pool[o].pop())
            for st in picked:
                tasks.append({'type': n, 'family': fam, 'file': f, 'api': api, 'site': st, 'in': op,
                              'def': def_name(text, st[0])})
    if a.replay:
        tasks, gone = [], 0
        for r0 in json.load(open(a.replay))['survivors']:
            f = S / r0['file']
            if not f.exists():
                gone += 1
                continue
            text = f.read_text()
            lines = text.split('\n')
            hit = [st for st in sites(text, True) if st[2] == r0['operator'] and st[3] == r0['before'] and st[4] == r0['after']
                   and lines[st[0]].strip()[:200] == r0['text'] and def_name(text, st[0]) == r0['def']
                   and st[1] == r0.get('col', st[1])]
            api = S / r0['checked']
            if hit and api.exists():
                tasks.append({'type': r0['type'], 'family': r0.get('family', ''), 'file': f, 'api': api, 'site': hit[0],
                              'in': r0['in'], 'def': r0['def']})
            else:
                gone += 1
        print(f'replay: {len(tasks)} survivors found again, {gone} gone (the site or its proof no longer exists)', flush=True)
    print(f'proof-wide: {len(tasks)} mutants over {len({t["api"] for t in tasks})} proof files', flush=True)
    tmp = pathlib.Path(os.environ.get('MUT_TMP', '/tmp')) / f'mutwide-{os.getpid()}'

    def run(t):
        """one mutant, alone in a private tree: the proof's import cone copied at the same relative paths."""
        st = t['site']
        d = tmp / f'{t["type"]}-{t["in"]}-{st[0]}-{st[1]}-{st[2]}'
        for f in cone_of(t['api']):
            dest = d / f.relative_to(S)
            dest.parent.mkdir(parents=True, exist_ok=True)
            if f == t['file'].resolve():
                dest.write_text(apply(f.read_text(), st))
            else:
                shutil.copyfile(f, dest)
        env = {**os.environ, 'CHECK_PINS_VERIFIED': '1', 'CHECK_MEMMAX': '12G'}
        t0 = time.monotonic()
        try:
            rc, out = run_guarded([str(S / 'tools/check.sh'), t['api'].relative_to(S).as_posix()], d, env, 900)
        except subprocess.TimeoutExpired:
            rc, out = 124, 'timeout'
        shutil.rmtree(d, ignore_errors=True)
        return out, time.monotonic() - t0

    results = []
    with cf.ThreadPoolExecutor(a.proof_jobs) as ex:
        futs = [(t, ex.submit(run, t)) for t in tasks]
        for n_done, (t, fu) in enumerate(futs, 1):
            out, secs = fu.result()
            st = t['site']
            rec = {'type': t['type'], 'family': t['family'], 'file': t['file'].relative_to(S).as_posix(),
                   'line': st[0] + 1, 'col': st[1], 'operator': st[2], 'before': st[3], 'after': st[4], 'def': t['def'],
                   'in': t['in'], 'checked': t['api'].relative_to(S).as_posix(), 'seconds': round(secs, 1),
                   'text': t['file'].read_text().split('\n')[st[0]].strip()[:200]}
            rec['outcome'] = 'killed' if 'ALL PROOFS CHECK' not in out else 'survived'
            if rec['outcome'] == 'killed':
                m = re.search(r'Error:[^\n]*(\n- [^\n]*)?', out)
                rec['error'] = m.group(0)[:160] if m else out[-160:]
            rec['cause'] = classify(rec)
            results.append(rec)
            if n_done % 50 == 0 or n_done == len(futs):
                print(f'proof-wide: {n_done}/{len(futs)} checked, '
                      f'{sum(1 for r in results if r["outcome"] == "survived")} survived, '
                      f'{time.monotonic() - started_global:.0f}s', flush=True)
    shutil.rmtree(tmp, ignore_errors=True)
    return results


def deep_proof(S, a):
    """The facade proof (proofs/api) only names the generated definitions: its statements are discharged by
    proving-law files (proofs/obj, the facade's P<k>_PRV imports) where the definitions are unfolded, and Bend
    checks only the file it is given. A facade survivor is therefore re-checked against those files: it is
    killed if any of them fails with the mutant applied, a gap in the proofs only if all still check."""
    surv = json.load(open(a.deep_from))['survivors']
    tmp = pathlib.Path(os.environ.get('MUT_TMP', '/tmp')) / f'mutdeep-{os.getpid()}'
    memo = {}

    def cone_of(f):
        f = f.resolve()
        if f not in memo:
            memo[f] = {c for c in import_cone(f)}
        return memo[f]

    def run(i, r):
        f = (S / r['file']).resolve()
        text = f.read_text()
        st = next(x for x in sites(text, True) if x[0] + 1 == r['line'] and x[3] == r['before'] and x[2] == r['operator'] and x[1] == r.get('col', x[1]))
        api = S / r['checked']
        prv = sorted({(api.parent / m.group(1)).resolve() for m in re.finditer(r'^import (\.\./obj/\S+\.bend) as P\d+_PRV', api.read_text(), re.M)})
        prv = [p for p in prv if f in cone_of(p)]
        d = tmp / str(i)
        for p in prv:
            for c in cone_of(p):
                dest = d / c.relative_to(S)
                if not dest.exists():
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_text(apply(text, st)) if c == f else shutil.copyfile(c, dest)
        env = {**os.environ, 'CHECK_PINS_VERIFIED': '1', 'CHECK_MEMMAX': '12G'}
        res = {'prv_files': [p.relative_to(S).as_posix() for p in prv], 'outcome': 'survived'}
        t0 = time.monotonic()
        for p in prv:
            try:
                _rc, out = run_guarded([str(S / 'tools/check.sh'), p.relative_to(S).as_posix()], d, env, a.deep_timeout)
            except subprocess.TimeoutExpired:
                res['outcome'] = 'timeout'
                break
            if 'ALL PROOFS CHECK' not in out:
                m = re.search(r'Error:[^\n]*(\n- [^\n]*)?', out)
                res.update(outcome='killed', killed_in=p.relative_to(S).as_posix(), error=(m.group(0)[:160] if m else out[-160:]))
                break
        if not prv:
            res['outcome'] = 'no proving-law file reaches it'
        res['seconds'] = round(time.monotonic() - t0, 1)
        shutil.rmtree(d, ignore_errors=True)
        return res

    out = []
    with cf.ThreadPoolExecutor(a.proof_jobs) as ex:
        futs = [(r, ex.submit(run, i, r)) for i, r in enumerate(surv)]
        for n_done, (r, fu) in enumerate(futs, 1):
            out.append({**{k: r[k] for k in ('type', 'file', 'line', 'col', 'operator', 'before', 'after', 'def', 'in', 'cause', 'text', 'checked')}, **fu.result()})
            if n_done % 25 == 0 or n_done == len(futs):
                print(f'deep: {n_done}/{len(futs)}, survived so far {sum(1 for o in out if o["outcome"] == "survived")}, '
                      f'{time.monotonic() - started_global:.0f}s', flush=True)
    shutil.rmtree(tmp, ignore_errors=True)
    return out


LIB_GROUPS = {
    'collections': ['proofs/obj/coll_*.bend', 'proofs/obj/tarray.bend', 'proofs/obj/view_*.bend', 'proofs/obj/root_*.bend',
                    'proofs/obj/words_*.bend', 'proofs/obj/fields_*.bend', 'proofs/obj/cached_*.bend', 'proofs/obj/cspec_*.bend',
                    'proofs/obj/gbits_*.bend', 'proofs/obj/gvalid_*.bend', 'proofs/obj/fixrej_*.bend', 'proofs/obj/vua_*.bend',
                    'proofs/obj/vvl_*.bend', 'proofs/obj/encset_*.bend'],
    'e2e': ['e2e/e2e_*.bend'],
    'sha256': ['vendor/bendhub/0xd9a2fae439ac7ff9e21e0853948f94fe/**/*.bend'],
    'spec': ['spec/*.bend'],
}
HUB = '0xd9a2fae439ac7ff9e21e0853948f94fe'


def lib_importers(S):
    """file -> the proof files that import it directly (relative imports; the hub package by its 0x path)."""
    rev = collections.defaultdict(set)
    roots = [S / d for d in ('proofs', 'e2e', 'spec', 'vendor/bendhub')]
    for r in roots:
        for f in r.rglob('*.bend'):
            for m in re.finditer(r'^import\s+(\S+\.bend)', f.read_text(), re.M):
                t = m.group(1)
                tgt = (S / 'vendor/bendhub' / t).resolve() if t.startswith('0x') else (f.parent / t).resolve()
                rev[tgt].add(f.resolve())
    return rev


def lib_wide(S, a):
    """Mutants of the library code the proofs rely on: a draw of --lib-per-file mutants for each file of a group; each
    runs alone in a private tree (the union import cone of its checkers, the package copied whole for the SHA-256
    vendor); the checkers are the file itself, the two smallest proof files that import it and every spec pin of proofs/mutation_coverage/spec that imports it, and the mutant is
    killed if any of them fails. A check over --lib-timeout seconds is `too slow`, not a kill."""
    import glob
    files = []
    for pat in LIB_GROUPS[a.lib]:
        files += sorted(pathlib.Path(g).resolve() for g in glob.glob(str(S / pat), recursive=True))
    files = sorted(set(files))
    if a.lib_only:
        want = {(S / w).resolve() for w in a.lib_only.split(',')}
        files = [f for f in files if f in want]
    if a.lib_files:
        files = files[:a.lib_files]
    rev = lib_importers(S)
    memo = {}

    def cone_of(f):
        f = f.resolve()
        if f not in memo:
            memo[f] = {c for c in import_cone(f)}
        return memo[f]
    tasks = []
    for f in files:
        text = f.read_text()
        rng = random.Random(f'{a.seed}:lib:{f.relative_to(S)}')
        lines = text.split('\n')
        pool = collections.defaultdict(list)
        for st in sites(text):
            if st[2] in ('swap', 'valid'):
                continue
            if excluded(f.relative_to(S).as_posix(), def_name(text, st[0]), st, lines[st[0]]):
                continue
            pool[st[2]].append(st)
        for v in pool.values():
            v.sort(key=lambda x: (x[0], x[1], x[3]))
            rng.shuffle(v)
        ops = [o for o in OPERATORS if pool[o]]
        rng.shuffle(ops)
        picked = []
        while len(picked) < a.lib_per_file and any(pool[o] for o in ops):
            for o in ops:
                if pool[o] and len(picked) < a.lib_per_file:
                    picked.append(pool[o].pop())
        imps = sorted((i for i in rev.get(f, ()) if i != f), key=lambda i: i.stat().st_size)[:2]
        # the spec pins (proofs/mutation_coverage/spec, codegen/proofs/mutation_coverage/spec_constants*.py) exist to fail a mutated
        # spec constant: every one whose import cone contains the mutated file is a checker, whatever its size
        pin_dir = (S / 'proofs/mutation_coverage/spec').resolve()
        imps += sorted((i for i in pin_dir.glob('*.bend') if i not in imps and f in cone_of(i)), key=lambda i: i.name)
        for st in picked:
            tasks.append({'file': f, 'site': st, 'checkers': [f] + imps, 'def': def_name(text, st[0])})
    # also check against the proof files that USE the mutated definition: a facade that names Schema10 fails when
    # Schema10 changes, while the two smallest importers of the file may not mention it at all
    need = {t['def'] for t in tasks if t['def']}
    users = collections.defaultdict(list)
    tokre = re.compile(r'\b\w+\b')
    for r in [S / d for d in ('proofs', 'e2e')]:
        for c in r.rglob('*.bend'):
            toks = set(tokre.findall(c.read_text())) & need
            for tk in toks:
                users[tk].append(c.resolve())
    for t in tasks:
        cand = [c for c in users.get(t['def'], []) if c != t['file']]
        cand.sort(key=lambda c: c.stat().st_size)
        extra = []
        for c in cand[:60]:
            if t['file'] in cone_of(c):
                extra.append(c)
            if len(extra) >= 3:
                break
        t['checkers'] = list(dict.fromkeys(t['checkers'] + extra))
    if a.lib_pins:
        pins = sorted(pathlib.Path(g).resolve() for g in glob.glob(str(S / a.lib_pins)))
        for t in tasks:
            t['checkers'] = list(dict.fromkeys(t['checkers'] + [c for c in pins if t['file'] in cone_of(c)]))
    random.Random(f'{a.seed}:order').shuffle(tasks)
    deadline = time.monotonic() + a.lib_budget if a.lib_budget else None
    print(f'lib {a.lib}: {len(tasks)} mutants over {len(files)} files', flush=True)
    tmp = pathlib.Path(os.environ.get('MUT_TMP', '/tmp')) / f'mutlib-{os.getpid()}'

    def run(i, t):
        st, f = t['site'], t['file']
        if deadline and time.monotonic() > deadline:
            return {'outcome': 'not run', 'seconds': 0}
        d = tmp / str(i)
        hub = (S / 'vendor/bendhub' / HUB).resolve()
        inhub = hub in f.parents
        cones = set()
        for c in t['checkers']:
            cones |= cone_of(c)
        cones.add(f)
        for c in cones:
            dest = d / c.relative_to(S)
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(apply(c.read_text(), st)) if c == f else shutil.copyfile(c, dest)
        env = {**os.environ, 'CHECK_PINS_VERIFIED': '1', 'CHECK_MEMMAX': '12G'}
        if inhub or any(HUB in c.read_text() for c in t['checkers'] if c.exists()):
            # the package is imported by its 0x path: give the private tree its own copy, mutated
            dst = d / 'vendor/bendhub' / HUB
            if not dst.exists():
                shutil.copytree(hub, dst)
            if inhub:
                (dst / f.relative_to(hub)).write_text(apply(f.read_text(), st))
            env['BEND_LIB'] = str(d / 'vendor/bendhub')
        res, t0, slow = {'outcome': 'survived'}, time.monotonic(), False
        for c in t['checkers']:
            if not (d / c.relative_to(S)).exists():
                continue
            try:
                _rc, out = run_guarded([str(S / 'tools/check.sh'), c.relative_to(S).as_posix()], d, env, a.lib_timeout)
            except subprocess.TimeoutExpired:
                slow = True
                continue
            if 'ALL PROOFS CHECK' not in out:
                m = re.search(r'Error:[^\n]*(\n- [^\n]*)?', out)
                res = {'outcome': 'killed', 'killed_in': c.relative_to(S).as_posix(), 'error': (m.group(0)[:160] if m else out[-160:])}
                break
        if res['outcome'] == 'survived' and slow:
            res['outcome'] = 'too slow'
        res['seconds'] = round(time.monotonic() - t0, 1)
        shutil.rmtree(d, ignore_errors=True)
        return res

    results = []
    with cf.ThreadPoolExecutor(a.proof_jobs) as ex:
        futs = [(t, ex.submit(run, i, t)) for i, t in enumerate(tasks)]
        for n_done, (t, fu) in enumerate(futs, 1):
            st = t['site']
            r = fu.result()
            rec = {'file': t['file'].relative_to(S).as_posix(), 'line': st[0] + 1, 'col': st[1], 'operator': st[2],
                   'before': st[3], 'after': st[4], 'def': t['def'], 'in': 'lib', 'cause': 'lib-' + a.lib,
                   'checked': [c.relative_to(S).as_posix() for c in t['checkers']],
                   'text': t['file'].read_text().split('\n')[st[0]].strip()[:200], **r}
            results.append(rec)
            with open(a.out + '.partial', 'a') as pf:
                pf.write(json.dumps(rec) + '\n')
            if n_done % 50 == 0 or n_done == len(futs):
                print(f'lib: {n_done}/{len(futs)}, survived so far {sum(1 for x in results if x["outcome"] == "survived")}, '
                      f'too slow {sum(1 for x in results if x["outcome"] == "too slow")}, {time.monotonic() - started_global:.0f}s', flush=True)
    shutil.rmtree(tmp, ignore_errors=True)
    return results


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--scratch', required=False, help='a COPY of the tree with its build/ (never the real tree)')
    ap.add_argument('--per-type', type=int, default=5)
    ap.add_argument('--seed', type=int, default=20261001)
    ap.add_argument('--types', default=None)
    ap.add_argument('--workers', type=int, default=8)
    ap.add_argument('--no-proofs', action='store_true')
    ap.add_argument('--proof-wide', type=int, default=0, help='proof side only, wide: this many mutants per name and operation')
    ap.add_argument('--proof-jobs', type=int, default=6)
    ap.add_argument('--lib', default=None, choices=sorted(LIB_GROUPS), help='mutate the library code of this group (collections, e2e, sha256, spec) instead of the generated codec files')
    ap.add_argument('--lib-per-file', type=int, default=4)
    ap.add_argument('--lib-files', type=int, default=0, help='only the first N files of the group (a pilot)')
    ap.add_argument('--lib-budget', type=int, default=0, help='seconds: after this no new mutant starts (it is reported `not run`)')
    ap.add_argument('--lib-pins', default=None, help='glob of extra checkers (relative to the root) added for every mutant whose cone they reach, e.g. proofs/obj/specpin_*.bend')
    ap.add_argument('--lib-only', default=None, help='only these files of the group (comma-separated paths relative to the root)')
    ap.add_argument('--lib-timeout', type=int, default=120, help='a mutant check over this many seconds is `too slow`, not a kill')
    ap.add_argument('--replay', default=None, help='with --proof-wide: instead of drawing, re-check the survivors of this earlier report (by file, def, operator, before, after and line text) on the current tree')
    ap.add_argument('--restamp', default=None, help='recompute the provenance of this result file for the tree this script is in (after the programs of this tree are built); runs nothing')
    ap.add_argument('--deep-timeout', type=int, default=900)
    ap.add_argument('--deep-from', default=None, help='deep proof stage for the survivors of this --proof-wide report: the facade passed, so re-check the proving-law files (the facade\'s P<k>_PRV imports) where the mutated definitions are unfolded')
    ap.add_argument('--from-survivors', default=None, help='runtime stage for the proof-side survivors of this --proof-wide report: exactly those mutants run through conformance and fuzzing')
    ap.add_argument('--proof-names', type=int, default=8)
    ap.add_argument('--out', default=str(ROOT / 'benchmarks/evidence/mutation_testing.json'))
    a = ap.parse_args()
    if a.restamp:
        f = pathlib.Path(a.restamp)
        d = json.loads(f.read_text())
        d['provenance'] = stamp(__file__)
        f.write_text(json.dumps(d, indent=1) + '\n')
        print(f'restamped {f}: commit {d["provenance"].get("git", d["provenance"]).get("commit") if isinstance(d["provenance"], dict) else "?"}')
        return
    if not a.scratch:
        raise SystemExit('mutation_testing: --scratch is required')
    S = pathlib.Path(a.scratch).resolve()
    if S == ROOT:
        raise SystemExit('mutation_testing: --scratch must be a copy, not the real tree')
    # precondition: every generated file of the tree under test is what its generator writes. A stale facade (no
    # proof law imported) or stale types made a whole round invalid once; nothing runs on such a tree.
    r = subprocess.run([sys.executable, 'codegen/regen_all.py', '--check'], cwd=S, capture_output=True, text=True)
    last = (r.stdout + r.stderr).strip().split('\n')[-1] if (r.stdout + r.stderr).strip() else ''
    if r.returncode != 0:
        raise SystemExit(f'mutation_testing: codegen/regen_all.py --check fails on {S} (generated files are stale):\n' + (r.stdout + r.stderr)[-1200:])
    print(f'precondition: regen_all --check: {last}', flush=True)
    sc = Scratch(S)
    global started_global
    started = started_global = time.monotonic()
    groups = json.loads((S / 'types/obj_groups.json').read_text())
    gen_index = json.loads((S / 'types/generic_obj_index.json').read_text())['generated']
    fuzz_ops = json.loads((S / 'types/obj_fuzz_ops.json').read_text())
    names = [(n, 'fulu') for n in groups] + [(n, 'generic') for n in gen_index if n not in groups]
    if a.types:
        want = set(a.types.split(','))
        names = [x for x in names if x[0] in want]
    if a.lib:
        res = lib_wide(S, a)
        sv = [r for r in res if r['outcome'] == 'survived']
        slow = [r for r in res if r['outcome'] == 'too slow']
        notrun = sum(1 for r in res if r['outcome'] == 'not run')
        rep = {'group': a.lib, 'seed': a.seed, 'lib_per_file': a.lib_per_file, 'mutants': len(res),
               'killed': sum(1 for r in res if r['outcome'] == 'killed'), 'survived': len(sv), 'too_slow': len(slow), 'not_run': notrun,
               'survivors_by_operator': dict(collections.Counter(r['operator'] for r in sv)),
               'survivors': sv, 'too_slow_list': slow, 'results': res, 'elapsed_s': round(time.monotonic() - started, 1),
               'provenance': stamp(__file__)}
        pathlib.Path(a.out).write_text(json.dumps(rep, indent=1) + '\n')
        print(f"lib {a.lib}: {rep['mutants']} mutants, {rep['killed']} killed, {rep['survived']} survived, {rep['too_slow']} too slow; {rep['elapsed_s']}s")
        return
    if a.deep_from:
        res = deep_proof(S, a)
        rep = {'seed': a.seed, 'survivors_in': len(res), 'killed': sum(1 for o in res if o['outcome'] == 'killed'),
               'survived': sum(1 for o in res if o['outcome'] == 'survived'),
               'other': dict(collections.Counter(o['outcome'] for o in res if o['outcome'] not in ('killed', 'survived'))),
               'results': res, 'elapsed_s': round(time.monotonic() - started, 1), 'provenance': stamp(__file__)}
        pathlib.Path(a.out).write_text(json.dumps(rep, indent=1) + '\n')
        print(f"deep proof stage: {rep['survived']} survived of {rep['survivors_in']} ({rep['killed']} killed, {rep['other']}); {rep['elapsed_s']}s")
        return
    if a.proof_wide:
        res = proof_wide(S, a, names)
        sv = [r for r in res if r['outcome'] == 'survived']
        seen, dedup = set(), []
        for r in sv:
            k = (r['file'], r['line'], r['col'], r['operator'], r['before'], r['after'])
            if k not in seen:
                seen.add(k)
                dedup.append(r)
        rep = {'seed': a.seed, 'proof_per_file': a.proof_wide, 'mutants': len(res),
               'killed': sum(1 for r in res if r['outcome'] == 'killed'), 'survived': len(sv),
               'survivors_by_cause': dict(collections.Counter(r['cause'] for r in dedup)),
               'survivors': dedup, 'results': res, 'elapsed_s': round(time.monotonic() - started, 1),
               'provenance': stamp(__file__)}
        pathlib.Path(a.out).write_text(json.dumps(rep, indent=1) + '\n')
        print(f"proof-wide: {rep['mutants']} mutants, {rep['killed']} killed, {rep['survived']} survived; "
              f"by cause {rep['survivors_by_cause']}; {rep['elapsed_s']}s")
        return
    plan = {}
    if a.from_survivors:
        want = collections.defaultdict(list)
        for r in json.load(open(a.from_survivors))['survivors']:
            want[r['type']].append(r)
        names = [x for x in names if x[0] in want]
        for n, fam in names:
            pre, files = type_files(S, n)
            picked = []
            for r in want[n]:
                f = S / r['file']
                text = f.read_text()
                site = next(x for x in sites(text, True) if x[0] + 1 == r['line'] and x[3] == r['before'] and x[2] == r['operator'] and x[1] == r.get('col', x[1]))
                picked.append((r['in'], f, site, def_name(text, site[0])))
            plan[n] = (fam, pre, picked)
    for n, fam in ([] if a.from_survivors else names):
        pre, picked = draw(S, n, a.per_type, a.seed)
        plan[n] = (fam, pre, picked)
    programs = sorted({('g', g['group']) for g in groups.values()} | {('x', g['group']) for g in gen_index.values()}
                      | {('f', e['program']) for e in fuzz_ops.values()})
    cone = {}
    for kind, k in programs:
        entry = S / f'benchmarks/objprog/{kind if kind != "g" else "g"}{k}.bend'
        cone[(kind, k)] = {c for c in import_cone(entry)}
    # baseline: the unmutated tree must pass what a mutant is required to fail (a missing module or a stale program
    # would otherwise "kill" every mutant)
    if plan:
        n0, (fam0, _p, _k) = next(iter(plan.items()))
        base_built = sc.build_all(programs, a.workers)
        bad = [p for p, (ok, o) in base_built.items() if not ok]
        if bad:
            raise SystemExit(f'baseline: the unmutated programs {bad[:3]} do not build:\n' + base_built[bad[0]][1][-800:])
        conf0 = (['benchmarks/checks/object_conformance.py', '--only', n0] if fam0 == 'fulu' else
                 ['benchmarks/checks/generic_object_conformance.py', '--only', n0])
        for what, cmd in (('conformance', conf0), ('fuzz', ['tests_generated/fuzz_objects.py', '--only', n0, '--budget', '60'])):
            rc, out = sc.test(cmd, 'base', 900)
            if rc:
                raise SystemExit(f'baseline: {what} fails on the UNMUTATED tree for {n0} (rc {rc}): {out.strip()[-300:]}')
        print(f'baseline: conformance and fuzz pass unmutated on {n0}', flush=True)
    orig = {}
    for n, (fam, pre, picked) in plan.items():
        for op, f, s, dn in picked:
            orig[f] = f.read_text()
    results = []
    # independent rounds: a mutant shares a round only with mutants whose file is outside the import cone of its
    # type's files (and the reverse), so a failing test is that mutant's alone (no cross-type contamination)
    tcone = {}
    for n, (fam, pre, picked) in plan.items():
        c = set()
        for f in type_files(S, n)[1].values():
            c |= {x for x in import_cone(f)}
        tcone[n] = c
    todo = [(n, fam, pre, pk) for n, (fam, pre, picked) in plan.items() for pk in picked]
    schedule = []
    while todo:
        cur, rest = [], []
        for t in todo:
            n, fam, pre, pk = t
            fa = pk[1].resolve()
            ok = not any(u[0] == n or fa in tcone[u[0]] or u[3][1].resolve() in tcone[n] for u in cur)
            (cur if ok else rest).append(t)
        schedule.append(cur)
        todo = rest
    print(f'runtime stage: {sum(len(b) for b in schedule)} mutants in {len(schedule)} independent rounds', flush=True)
    rounds = len(schedule)
    for rd in range(rounds):
        batch = schedule[rd]
        for f, t in orig.items():
            f.write_text(t)
        applied = {}
        for n, fam, pre, (op, f, s, dn) in batch:
            applied[n] = (op, f, s, dn)
            f.write_text(apply(orig[f], s))
        built = sc.build_all(programs, a.workers)
        invalid = set()
        defs = {n: set(re.findall(r'^def (\w+)', applied[n][1].read_text(), re.M)) for n in applied}
        for attempt in range(8):
            bad_programs = [p for p, (ok, _) in built.items() if not ok]
            if not bad_programs:
                break
            found = set()
            for p in bad_programs:
                # the def the compiler names in its error belongs to the mutated file that defines it
                for loc in re.findall(r'^Location: (\w+)', built[p][1], re.M):
                    found |= {n for n in applied if n not in invalid and loc in defs[n]}
            if not found:
                # no mapping: each mutant in the program's cone alone
                for p in bad_programs:
                    for n in [n for n in applied if applied[n][1].resolve() in cone[p] and n not in invalid]:
                        for f, t in orig.items():
                            f.write_text(t)
                        op, f, s_, dn = applied[n]
                        f.write_text(apply(orig[f], s_))
                        if not sc.build(*p)[0]:
                            found.add(n)
            invalid |= found
            for f, t in orig.items():
                f.write_text(t)
            for n in applied:
                if n not in invalid:
                    op, f, s_, dn = applied[n]
                    f.write_text(apply(orig[f], s_))
            built = sc.build_all(bad_programs, a.workers)
            built = {**{p: (True, '') for p in programs if p not in bad_programs}, **built}
        jobs = {}
        with cf.ThreadPoolExecutor(a.workers) as ex:
            for n, (op, f, s, dn) in applied.items():
                fam = plan[n][0]
                if n in invalid:
                    continue
                conf = (['benchmarks/checks/object_conformance.py', '--only', n] if fam == 'fulu' else
                        ['benchmarks/checks/generic_object_conformance.py', '--only', n])
                suffix = hashlib.sha256(f'{n}{rd}'.encode()).hexdigest()[:8]
                jobs[n] = (ex.submit(sc.test, conf, suffix + 'c', 900),
                           ex.submit(sc.test, ['tests_generated/fuzz_objects.py', '--only', n, '--budget', '900'],
                                     suffix + 'f', 1200))
        for n, (op, f, s, dn) in applied.items():
            fam = plan[n][0]
            rec = {'type': n, 'family': fam, 'round': rd, 'file': f.relative_to(S).as_posix(), 'line': s[0] + 1, 'col': s[1],
                   'operator': s[2], 'before': s[3], 'after': s[4], 'def': dn, 'in': op}
            if n in invalid:
                rec['outcome'] = 'invalid'
            else:
                (rc1, o1), (rc2, o2) = jobs[n][0].result(), jobs[n][1].result()
                rec['conformance'] = 'fail' if rc1 else 'pass'
                rec['fuzz'] = 'fail' if rc2 else 'pass'
                rec['outcome'] = 'killed' if (rc1 or rc2) else 'survived'
                if 124 in (rc1, rc2):   # a timeout is not a detection
                    rec['outcome'] = 'timeout' if rec['outcome'] == 'killed' and not (rc1 not in (0, 124) or rc2 not in (0, 124)) else rec['outcome']
                if rec['outcome'] == 'killed':
                    rec['killed_by'] = [k for k, rc in (('conformance', rc1), ('fuzz', rc2)) if rc and rc != 124]
                    rec['tail'] = {k: o.strip().replace('\n', ' | ')[-220:] for k, rc, o in (('conformance', rc1, o1), ('fuzz', rc2, o2)) if rc and rc != 124}
            results.append(rec)
        done = sum(1 for r in results if r['outcome'] == 'killed')
        print(f'round {rd + 1}/{rounds}: {len(results)} mutants, {done} killed, '
              f'{sum(1 for r in results if r["outcome"] == "survived")} survived, {len(invalid)} invalid in this round, '
              f'{time.monotonic() - started:.0f}s', flush=True)
    for f, t in orig.items():
        f.write_text(t)

    proofs = []
    if not a.no_proofs:
        rng = random.Random(f'{a.seed}:proofs')
        usable = sorted({r['type'] for r in results if r['outcome'] != 'invalid' and r['family'] == 'fulu'
                         and (S / 'types' / f"{plan[r['type']][1]}_decode_ssz_generated.bend").stat().st_size < 12000})
        chosen = rng.sample(usable, min(a.proof_names, len(usable)))
        for n in chosen:
            muts = [r for r in results if r['type'] == n and r['outcome'] != 'invalid']
            for r in muts[:2]:
                f = S / r['file']
                pre = plan[n][1]
                text = f.read_text()
                site = next(x for x in sites(text, True) if x[0] + 1 == r['line'] and x[3] == r['before'] and x[2] == r['operator'] and x[1] == r.get('col', x[1]))
                f.write_text(apply(text, site))
                api = S / (f"proofs/api/{pre}_hashtreeroot_proof_generated.bend" if r['in'] == 'hashtreeroot'
                           else f"proofs/api/{pre}_{r['in']}_ssz_proof_generated.bend")
                rec = {k: r[k] for k in ('type', 'file', 'line', 'col', 'operator', 'before', 'after', 'def', 'in')}
                rec['checked'] = api.relative_to(S).as_posix()
                if api.exists():
                    env = {**os.environ, 'CHECK_PINS_VERIFIED': '1', 'CHECK_MEMMAX': '12G'}
                    t0 = time.monotonic()
                    p = subprocess.run(['tools/check.sh', rec['checked']], cwd=S, env=env, capture_output=True, text=True)
                    out = p.stdout + p.stderr
                    rec['seconds'] = round(time.monotonic() - t0, 1)
                    rec['outcome'] = 'killed' if 'ALL PROOFS CHECK' not in out else 'survived'
                    if rec['outcome'] == 'killed':
                        m = re.search(r'Error:[^\n]*(\n- [^\n]*)?', out)
                        rec['error'] = m.group(0)[:160] if m else out[-160:]
                else:
                    rec['outcome'] = 'no proof file'
                f.write_text(text)
                proofs.append(rec)
            print(f'proof mutants of {n}: {[p["outcome"] for p in proofs if p["type"] == n]}', flush=True)

    valid = [r for r in results if r['outcome'] != 'invalid']
    by = lambda key: {k: {'mutants': sum(1 for r in valid if r[key] == k),
                          'killed': sum(1 for r in valid if r[key] == k and r['outcome'] == 'killed')}
                      for k in sorted({r[key] for r in valid})}
    report = {'seed': a.seed, 'per_type': a.per_type, 'types': len(plan),
              'mutants_drawn': len(results), 'invalid': len(results) - len(valid), 'valid': len(valid),
              'killed': sum(1 for r in valid if r['outcome'] == 'killed'),
              'survived': sum(1 for r in valid if r['outcome'] == 'survived'),
              'kill_rate': round(sum(1 for r in valid if r['outcome'] == 'killed') / max(1, len(valid)), 4),
              'by_operator': by('operator'), 'by_family': by('family'), 'by_file': by('in'),
              'killed_by': dict(collections.Counter(k for r in valid for k in r.get('killed_by', []))),
              'survivors': [r for r in valid if r['outcome'] == 'survived'],
              'proof_mutants': proofs,
              'proof_killed': sum(1 for p in proofs if p['outcome'] == 'killed'),
              'proof_survived': sum(1 for p in proofs if p['outcome'] == 'survived'),
              'elapsed_s': round(time.monotonic() - started, 1),
              'mutants': results,
              'method': 'see the docstring of tests_generated/mutation_testing.py and docs/RESULTS.md',
              'provenance': stamp(__file__)}
    pathlib.Path(a.out).write_text(json.dumps(report, indent=1) + '\n')
    print(f"{report['valid']} valid mutants of {report['types']} types: {report['killed']} killed, "
          f"{report['survived']} survived (kill rate {report['kill_rate']:.1%}), {report['invalid']} invalid; "
          f"proofs: {report['proof_killed']} killed, {report['proof_survived']} survived; {report['elapsed_s']}s")


if __name__ == '__main__':
    main()
