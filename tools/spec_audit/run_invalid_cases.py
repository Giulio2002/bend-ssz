#!/usr/bin/env python3
"""Run the object-level corpus (data/invalid_cases.json, made by invalid_cases.py) against the compiled object API.

    python3 tools/spec_audit/run_invalid_cases.py --repo . --cases tools/spec_audit/data/invalid_cases.json --work DIR [--patch P] [--jobs 4]

One Bend program holds every case: it builds the value with the RAW record constructors (a state no decoder or checked setter
produces), calls the public checked encoder `<Name>_serialize` and prints `ACCEPTED=1` and writes the bytes to SSZ_OUTPUT, or
prints `ACCEPTED=0`. SSZ_CASE selects the case. A case disagrees when the reference refuses and Bend accepts, when the reference
serializes and Bend refuses, or when both serialize and the bytes differ.

The program is compiled in a private hard-linked copy of its import closure under --work (the repository is not touched); with
--patch the one patched file of the closure is copied and patched there (the mutated trees of the manual spec mutants).
Server only (the Bend runtime compiler, the 2.0.34 release): nothing here runs on a laptop.
"""
import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from invalid_cases import expand  # noqa: E402

BEND = os.environ.get('BEND_RUNTIME', '/srv/ssz-optimization/toolchain-2.0.34/bin/bend')


# ---- reading the generated modules -----------------------------------------------------------------------------------------

class Types:
    def __init__(self, repo):
        self.repo = repo
        self.imports = {}       # alias -> path relative to types/
        self.info = {}

    def text(self, base, kind):
        return open(os.path.join(self.repo, 'types', '%s_%s_generated.bend' % (base, kind))).read()

    def add_imports(self, txt):
        for m in re.finditer(r'^import (\S+) as (\w+)$', txt, re.M):
            path, alias = m.groups()
            if path.startswith('./'):
                self.imports[alias] = path[2:]
            elif path.startswith('../'):
                self.imports[alias] = path          # ../src/x.bend: same depth from build/ as from types/

    def get(self, base):
        if base in self.info:
            return self.info[base]
        d = self.text(base, 'def')
        e = self.text(base, 'encode_ssz')
        self.add_imports(d)
        m = re.search(r'^def (\w+_serialize)\((\+?)o: ([^)]+)\) -> (.+?):', e, re.M)
        fn, plus, arg, res = m.groups() if m else (None, '', '', 'O.Encoded')
        direct = res.strip() == 'O.Encoded'
        r = None if direct else res.split(' & O.Encoded')[0]
        dm = re.search(r'^def (\w+)_default\(\) -> (\w+): (.*)$', d, re.M)
        default = dm.group(3) if dm else None
        rec = re.search(r'^type (\w+) is (?:Data|Type):\n  (\w+)\{(.*)\}$', d, re.M)
        self.info[base] = {'fn': fn, 'direct': direct, 'res': r, 'arg': arg, 'default': default,
                           'ctor': rec.group(2) if rec else None, 'fields': rec.group(3) if rec else '', 'def': d}
        return self.info[base]


def split_top(s):
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in '({[':
            depth += 1
        elif ch in ')}]':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


# ---- lowering --------------------------------------------------------------------------------------------------------------

def depth_for(nwords):
    return max(0, math.ceil(math.log2(max(nwords, 1))))


def array(depth, words):
    e = 'Array.new(U32, %dn, 0)' % depth
    for i, w in enumerate(words):
        if w:
            e = 'Array.set(U32, %s, %d, %d)' % (e, i, w)
    return e


def bytes_to_words(bs):
    bs = list(bs) + [0] * (-len(bs) % 4)
    return [int.from_bytes(bytes(bs[i:i + 4]), 'little') for i in range(0, len(bs), 4)]


def bits_to_words(bits, nwords):
    ws = [0] * nwords
    for i, b in enumerate(bits):
        if b:
            ws[i // 32] |= 1 << (i % 32)
    return ws


def lower_value(T, v, default_arg=None, base=None):
    """the Bend expression of a neutral value. `default_arg` is the text of the field's default (a container field), `base` the
    type name of a named top-level or union payload value."""
    if 'u' in v:
        return str(v['u'])
    if 'elems' in v:
        es = v['elems']
        bs = []
        for x in es:
            bs += list(int(x).to_bytes(v['esize'], 'little'))
        ws = bytes_to_words(bs)
        return 'O.Words{%s, %d}' % (array(depth_for(len(ws)), ws), len(bs))
    if 'rawwords' in v:
        return 'O.Words{%s, %d}' % (array(v['depth'], v['rawwords']), v['len'])
    if 'bits' in v or 'rawbits' in v:
        if 'bits' in v:
            k = len(v['bits'])
            ws = bits_to_words(v['bits'], k // 32 + 1)
            depth = depth_for(k // 32 + 1)
        else:
            k, ws, depth = v['k'], v['rawbits'], v['depth']
        if base and T.get(base)['ctor'] and re.fullmatch(r'w0: U32', T.get(base)['fields']):      # a one-word bit vector
            return '%s_d.%s{%d}' % (base, T.get(base)['ctor'], ws[0])
        return 'O.Bits{%s, %d}' % (array(depth, ws), k)
    if 'items' in v:
        alias = re.match(r'(\w+)\.', default_arg).group(1)
        base2 = re.sub(r'_d$', '', alias)
        T.get(base2)
        info = T.info[base2]
        seq = re.search(r'^def (\w+)_default\(\) -> (\w+): (\w+)\{(\w+)\(0n\), 0\}$', info['def'], re.M)
        fill = seq.group(4)
        return '%s.%s{%s.%s(%dn), %d}' % (alias, seq.group(3), alias, fill, depth_for(v['items']), v['items'])
    if 'fields' in v:
        b = v.get('type') or base
        info = T.get(b)
        m = re.match(r'(\w+)\{(.*)\}$', info['default'])
        args = split_top(m.group(2))
        for name, x in v['fields'].items():
            i = v['_idx'][name]
            args[i] = lower_value(T, x, default_arg=args[i], base=None)
        return '%s_d.%s{%s}' % (b, m.group(1), ', '.join(args))
    if 'union' in v:
        sel, payload = v['union']
        info = T.get(base)
        ctors = re.findall(r'^  (\w+_c\d+)\{', info['def'], re.M)
        pb = payload.get('type')
        return '%s_d.%s{%s}' % (base, ctors[v['opt']], lower_value(T, payload, base=pb))
    raise ValueError(v)


def driver(T, cases):
    L = ['import Base', 'import ../src/buffer.bend as B', 'import ../src/obj.bend as O', 'import ../benchmarks/compact/objio.bend as IOx']
    bodies, snds = [], {}
    for i, c in enumerate(cases):
        info = T.get(c['type'])
        obj = lower_value(T, c['value'], base=c['type'])
        call = '%s_e.%s(%s)' % (c['type'], info['fn'], obj)
        if info['direct']:
            bodies.append('def case_%d() -> IO(Unit): show_enc(%s)' % (i, call))
        else:
            h = snds.setdefault(info['res'], 'snd_%d' % len(snds))
            bodies.append('def case_%d() -> IO(Unit): %s(%s)' % (i, h, call))
    # every module the cases (and the field defaults they spell out) mention
    mods = {}
    for c in cases:
        mods['%s_d' % c['type']] = '%s_def_generated.bend' % c['type']
        mods['%s_e' % c['type']] = '%s_encode_ssz_generated.bend' % c['type']
    text = '\n'.join(bodies)
    for alias, path in T.imports.items():
        if alias in ('O', 'B'):
            continue
        if re.search(r'\b%s\.' % re.escape(alias), text):
            mods.setdefault(alias, path)
    for alias, path in sorted(mods.items()):
        L.append('import %s as %s' % (path if path.startswith('..') else '../types/' + path, alias))
    # nested payload modules named in the cases
    L += ['',
          'def show_ok(ok: Bool, b: B.Buf) -> IO(Unit):',
          '  match ok:',
          '    case True{}:',
          '      do IO<Unit>:',
          '        IO.print("ACCEPTED=1")',
          '        IOx.emit_encoding(B.size(b))',
          '    case False{}: IO.print("ACCEPTED=0")',
          '',
          'def show_enc(e: O.Encoded) -> IO(Unit):',
          '  match e:',
          '    case O.Encoded{ok, b}: show_ok(ok, b)', '']
    for r, h in snds.items():
        L += ['def %s(pair: %s & O.Encoded) -> IO(Unit):' % (h, r), '  (o, e) = pair', '  show_enc(e)', '']
    L += bodies + ['', 'def run(+i: U32) -> IO(Unit):', '  match i:']
    for i in range(len(cases)):
        L.append('    case %d: case_%d()' % (i, i))
    L += ['    case _: IO.print("NOCASE=1")', '', 'def main() -> IO(Unit):', '  do IO<Unit>:',
          '    +i : U32 <- IOx.env_u32("SSZ_CASE")', '    run(i)', '']
    return '\n'.join(L)


# ---- building and running --------------------------------------------------------------------------------------------------

def closure(repo, start):
    seen, todo = set(), [start]
    while todo:
        f = todo.pop()
        if f in seen:
            continue
        seen.add(f)
        for m in re.finditer(r'^import (\S+\.bend)', open(os.path.join(repo, f)).read(), re.M):
            p = os.path.normpath(os.path.join(os.path.dirname(f), m.group(1)))
            if os.path.exists(os.path.join(repo, p)):
                todo.append(p)
    return seen


def build(repo, work, text, patch):
    d = os.path.join(work, 'tree')
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(os.path.join(d, 'build'))
    src = os.path.join(repo, 'build', 'rawobj_driver.bend')
    drv = os.path.join(d, 'build', 'rawobj_driver.bend')
    open(drv, 'w').write(text)
    # the closure of the driver: its imports are written relative to build/ (a sibling of types/ and src/)
    files = set()
    for m in re.finditer(r'^import (\S+\.bend)', text, re.M):
        p = os.path.normpath(os.path.join('build', m.group(1)))
        files |= closure(repo, p)
    for f in files:
        os.makedirs(os.path.dirname(os.path.join(d, f)), exist_ok=True)
        os.link(os.path.join(repo, f), os.path.join(d, f))
    if patch:
        tgt = None
        for l in open(patch):
            if l.startswith('+++ b/'):
                tgt = l[6:].strip()
        assert tgt, 'no target in patch'
        dst = os.path.join(d, tgt)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.exists(dst):
            os.unlink(dst)
        shutil.copy(os.path.join(repo, tgt), dst)
        r = subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', os.path.abspath(patch)], cwd=d, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('patch failed: ' + r.stdout + r.stderr)
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    out = os.path.join(d, 'build', 'rawobj')
    r = subprocess.run(['nice', '-n', '19', BEND, 'build/rawobj_driver.bend', '-o', out], cwd=d, env=env, capture_output=True, text=True)
    if r.returncode:
        return None, d, (r.stdout + r.stderr)[-1500:]
    return out, d, ''


def run_case(prog, i, tmp):
    out = os.path.join(tmp, 'o%d' % i)
    env = {**os.environ, 'SSZ_CASE': str(i), 'SSZ_OUTPUT': out}
    try:
        r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=120)
    except subprocess.TimeoutExpired:
        return {'bend': 'TIMEOUT'}
    if r.returncode != 0 or ('ACCEPTED=' not in r.stdout):
        return {'bend': 'ERROR', 'tail': (r.stdout + r.stderr)[-200:]}
    if 'ACCEPTED=1' in r.stdout:
        data = open(out, 'rb').read() if os.path.exists(out) else b''
        return {'bend': 'accept', 'hex': data.hex()}
    return {'bend': 'refuse'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cases', required=True)
    ap.add_argument('--work', required=True)
    ap.add_argument('--patch', default=None)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--out', default=None)
    ap.add_argument('--keep', action='store_true')
    ap.add_argument('--emit-driver', default=None, help='write the Bend program here and stop')
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    cases = json.load(open(a.cases))['cases']
    for c in cases:
        c['value'] = expand(c['value'])
    T = Types(repo)
    text = driver(T, cases)
    if a.emit_driver:
        open(a.emit_driver, 'w').write(text)
        return 0
    os.makedirs(a.work, exist_ok=True)
    prog, d, err = build(repo, os.path.abspath(a.work), text, a.patch)
    if prog is None:
        print('COMPILE FAILED\n' + err)
        return 2
    tmp = tempfile.mkdtemp(prefix='rawobj-', dir=a.work)
    with ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(lambda i: run_case(prog, i, tmp), range(len(cases))))
    bad, tally = [], {}
    for c, r in zip(cases, res):
        want, got = c['verdict'], r['bend']
        kind = None
        if got in ('TIMEOUT', 'ERROR'):
            kind = 'run failed'
        elif want == 'refuse' and got == 'accept':
            kind = 'reference refuses, Bend accepts'
        elif want == 'accept' and got == 'refuse':
            kind = 'reference serializes, Bend refuses'
        elif want == 'accept' and r['hex'] != c['hex']:
            kind = 'both serialize, bytes differ'
        k = (c['class'], 'AGREE' if kind is None else 'DISAGREE')
        tally[k] = tally.get(k, 0) + 1
        if kind:
            bad.append({'id': c['id'], 'class': c['class'], 'kind': kind, 'want': want, 'bend': r})
    summary = {'cases': len(cases), 'disagreements': len(bad), 'by_class': {'%s/%s' % k: v for k, v in sorted(tally.items())}, 'bad': bad}
    if a.out:
        json.dump(summary, open(a.out, 'w'), indent=1)
    print('cases %d, disagreements %d' % (len(cases), len(bad)))
    for k, v in sorted(tally.items()):
        print('  %-16s %-9s %d' % (k[0], k[1], v))
    for b in bad[:30]:
        print('  ', b['id'], '|', b['kind'], '|', str(b['bend'])[:100])
    shutil.rmtree(tmp, ignore_errors=True)
    if not a.keep:
        shutil.rmtree(d, ignore_errors=True)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
