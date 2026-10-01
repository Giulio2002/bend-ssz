"""Mutation testing of the generated runtime and of the proofs that reach it.

    python3 tests_generated/mutation_testing.py --scratch DIR [--per-type 5] [--seed N] [--types A,B] [--no-proofs]

The question: would the evidence suite notice if the generated encoder, decoder or root code were wrong? The
other harnesses feed corrupted INPUT to correct code; this one corrupts the CODE and requires the harnesses to fail.

Runtime side. For every Fulu name and every generic name, MUTANTS_PER_TYPE (default 5) mutants are drawn, seeded
and deterministic, from the sites of types/<Name>_{decode_ssz,encode_ssz,hashtreeroot}_generated.bend (the code the
object programs run): a numeric constant changed by +1 or -1 (an offset, a size, a depth; -1 on out_at(d) is an under-allocated buffer; +1 on out_at(d) and the alignment test `pos .&. 3 == 0` are not drawn: round 1 classed them), a comparison flipped
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
CMP = {'U32.is_eq(': 'U32.is_lt(', 'U32.is_lt(': 'U32.is_le(', 'U32.is_le(': 'U32.is_lt('}


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
            in_out_at = re.search(r'out_at\(' + re.escape(m.group(0)) + r'\)', line[max(0, m.start() - 7):m.end() + 1])
            if keep_classed or not in_out_at:   # out_at(d) +1 only adds zero words: round 1 classes it (all killed by conformance, no proof pins it)
                out.append((i, m.start(), 'const+1', m.group(0), str(int(m.group(1)) + 1) + m.group(2)))
            if int(m.group(1)) >= 1:   # one too small: an under-allocated buffer, a limit or size one short
                out.append((i, m.start(), 'const-1', m.group(0), str(int(m.group(1)) - 1) + m.group(2)))
        for a, b in CMP.items():
            for m in re.finditer(re.escape(a), line):
                if '.&. 3' in line and not keep_classed:   # the aligned-or-slow path choice: round 1 classes it, not redrawn
                    continue
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
    file, def, operator, before, after and the line's text; a class and the reason are recorded with each entry).
    Such sites are never drawn and never reported as survivors."""
    global _EXCL
    if _EXCL is None:
        _EXCL = set()
        if EXCLUSIONS_FILE.exists():
            for e in json.loads(EXCLUSIONS_FILE.read_text())['entries']:
                _EXCL.add((e['file'], e['def'], e['operator'], e['before'], e['after'], e['text']))
    return (rel, dn, st[2], st[3], st[4], line.strip()[:200]) in _EXCL


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


def classify(rec):
    """The cause group of a mutation: what a gap in it would mean."""
    text = rec.get('text', '')
    d = rec.get('def') or ''
    if rec['in'] == 'hashtreeroot':
        return 'merkle-structure' if rec['operator'] == 'swap' else 'hashtreeroot-constant'
    if rec['operator'] == 'valid' or re.search(r'(^|_)(valid|ok|ok_at|ok_len|c\d+)($|_)', d):
        return 'validity-check'
    if re.search(r'out_at\(|alloc|cap', text):
        return 'capacity'
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
                   and lines[st[0]].strip()[:200] == r0['text'] and def_name(text, st[0]) == r0['def']]
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
        p = subprocess.run([str(S / 'tools/check.sh'), t['api'].relative_to(S).as_posix()], cwd=d, env=env,
                           capture_output=True, text=True)
        shutil.rmtree(d, ignore_errors=True)
        return p.stdout + p.stderr, time.monotonic() - t0

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
                q = subprocess.run([str(S / 'tools/check.sh'), p.relative_to(S).as_posix()], cwd=d, env=env,
                                   capture_output=True, text=True, timeout=a.deep_timeout)
            except subprocess.TimeoutExpired:
                res['outcome'] = 'timeout'
                break
            out = q.stdout + q.stderr
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--scratch', required=False, help='a COPY of the tree with its build/ (never the real tree)')
    ap.add_argument('--per-type', type=int, default=5)
    ap.add_argument('--seed', type=int, default=20261001)
    ap.add_argument('--types', default=None)
    ap.add_argument('--workers', type=int, default=8)
    ap.add_argument('--no-proofs', action='store_true')
    ap.add_argument('--proof-wide', type=int, default=0, help='proof side only, wide: this many mutants per name and operation')
    ap.add_argument('--proof-jobs', type=int, default=12)
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
