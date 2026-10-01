"""Mutation testing of the generated runtime and of the proofs that reach it.

    python3 tests_generated/mutation_testing.py --scratch DIR [--per-type 5] [--seed N] [--types A,B] [--no-proofs]

The question: would the evidence suite notice if the generated encoder, decoder or root code were wrong? The
other harnesses feed corrupted INPUT to correct code; this one corrupts the CODE and requires the harnesses to fail.

Runtime side. For every Fulu name and every generic name, MUTANTS_PER_TYPE (default 5) mutants are drawn, seeded
and deterministic, from the sites of types/<Name>_{decode,encode,hashtreeroot}_ssz_generated.bend (the code the
object programs run): a numeric constant changed by +1 (an offset, a size, a depth), a comparison flipped
(is_eq -> is_lt, is_lt -> is_le, is_le -> is_lt), an addition turned into a subtraction, a validity result
forced (True{} -> False{}, False{} -> True{}). The sites are drawn round-robin over the operators. The mutants
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
OPERATORS = ('const+1', 'cmp', 'addsub', 'valid')
CMP = {'U32.is_eq(': 'U32.is_lt(', 'U32.is_lt(': 'U32.is_le(', 'U32.is_le(': 'U32.is_lt('}


def code_lines(text):
    for i, line in enumerate(text.split('\n')):
        s = line.strip()
        if s and not s.startswith('#') and not s.startswith('import'):
            yield i, line


def sites(text):
    """[(line index, column, operator, before, after)] for every mutable site of a generated file."""
    out = []
    for i, line in code_lines(text):
        for m in re.finditer(r'(?<![\w.])(\d+)(n?)(?![\w.])', line):
            out.append((i, m.start(), 'const+1', m.group(0), str(int(m.group(1)) + 1) + m.group(2)))
        for a, b in CMP.items():
            for m in re.finditer(re.escape(a), line):
                out.append((i, m.start(), 'cmp', a, b))
        for m in re.finditer(r' \+ (?=\d+ : U32\))', line):
            out.append((i, m.start(), 'addsub', ' + ', ' - '))
        if re.search(r'\(buf, (True|False)\{\}\)|-> Bool: (True|False)\{\}$', line):
            for m in re.finditer(r'(True|False)\{\}', line):
                out.append((i, m.start(), 'valid', m.group(0), 'False{}' if m.group(1) == 'True' else 'True{}'))
    return out


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
        fs = {op: root / f'types/{pre}_{op}_ssz_generated.bend' for op in OPS}
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
        for s in sites(text):
            pool[s[2]].append((op, f, s, def_name(text, s[0])))
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--scratch', required=True, help='a COPY of the tree with its build/ (never the real tree)')
    ap.add_argument('--per-type', type=int, default=5)
    ap.add_argument('--seed', type=int, default=20261001)
    ap.add_argument('--types', default=None)
    ap.add_argument('--workers', type=int, default=8)
    ap.add_argument('--no-proofs', action='store_true')
    ap.add_argument('--proof-names', type=int, default=8)
    ap.add_argument('--out', default=str(ROOT / 'benchmarks/evidence/mutation_testing.json'))
    a = ap.parse_args()
    S = pathlib.Path(a.scratch).resolve()
    if S == ROOT:
        raise SystemExit('mutation_testing: --scratch must be a copy, not the real tree')
    sc = Scratch(S)
    started = time.monotonic()
    groups = json.loads((S / 'types/obj_groups.json').read_text())
    gen_index = json.loads((S / 'types/generic_obj_index.json').read_text())['generated']
    fuzz_ops = json.loads((S / 'types/obj_fuzz_ops.json').read_text())
    names = [(n, 'fulu') for n in groups] + [(n, 'generic') for n in gen_index if n not in groups]
    if a.types:
        want = set(a.types.split(','))
        names = [x for x in names if x[0] in want]
    plan = {}
    for n, fam in names:
        pre, picked = draw(S, n, a.per_type, a.seed)
        plan[n] = (fam, pre, picked)
    programs = sorted({('g', g['group']) for g in groups.values()} | {('x', g['group']) for g in gen_index.values()}
                      | {('f', e['program']) for e in fuzz_ops.values()})
    cone = {}
    for kind, k in programs:
        entry = S / f'benchmarks/objprog/{kind if kind != "g" else "g"}{k}.bend'
        cone[(kind, k)] = {c for c in import_cone(entry)}
    orig = {}
    for n, (fam, pre, picked) in plan.items():
        for op, f, s, dn in picked:
            orig[f] = f.read_text()
    results = []
    rounds = max([len(p[2]) for p in plan.values()] or [0])
    for rd in range(rounds):
        batch = [(n, fam, pre) + (plan[n][2][rd],) for n, (fam, pre, _) in plan.items() if len(plan[n][2]) > rd]
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
            rec = {'type': n, 'family': fam, 'round': rd, 'file': f.relative_to(S).as_posix(), 'line': s[0] + 1,
                   'operator': s[2], 'before': s[3], 'after': s[4], 'def': dn, 'in': op}
            if n in invalid:
                rec['outcome'] = 'invalid'
            else:
                (rc1, o1), (rc2, o2) = jobs[n][0].result(), jobs[n][1].result()
                rec['conformance'] = 'fail' if rc1 else 'pass'
                rec['fuzz'] = 'fail' if rc2 else 'pass'
                rec['outcome'] = 'killed' if (rc1 or rc2) else 'survived'
                if rec['outcome'] == 'killed':
                    rec['killed_by'] = [k for k, rc in (('conformance', rc1), ('fuzz', rc2)) if rc]
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
                site = next(x for x in sites(text) if x[0] + 1 == r['line'] and x[3] == r['before'] and x[2] == r['operator'])
                f.write_text(apply(text, site))
                api = S / f"proofs/api/{pre}_{r['in']}_ssz_proof_generated.bend"
                rec = {k: r[k] for k in ('type', 'file', 'line', 'operator', 'before', 'after', 'def', 'in')}
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
