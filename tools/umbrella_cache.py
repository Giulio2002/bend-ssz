#!/usr/bin/env python3
"""A sound result cache for umbrella checks (tools/check_fast.sh).

    python3 tools/umbrella_cache.py key ROOT... [--settings S]       print the cache key of the umbrella over these roots; exit 3
                                                                       when it is not cacheable (an import cannot be resolved exactly)
    python3 tools/umbrella_cache.py lookup KEY                       print the entry and exit 0, or exit 1 when absent
    python3 tools/umbrella_cache.py store KEY --seconds S --peak-mb M [--roots R...]   record a PASS
    python3 tools/umbrella_cache.py prepare PLAN SETTINGS.tsv OUT [--recheck K]   keys, hits and the K safety rechecks of a whole plan
    python3 tools/umbrella_cache.py clear                            delete every entry
    python3 tools/umbrella_cache.py verify-rows STAMP.json           recompute the key of every cached row of a stamp

What is cached, and why it is sound. One umbrella is `bend U.bend --check-only` over a file that only imports its root
files, so its verdict is a function of (a) the checker, (b) the settings it ran under, (c) the bytes of every module
in the import closure of the roots, and nothing else. The key is the sha256 over all of those:

  checker identity   sha256 of the checker's own files (a compiled release: bin/bend and bend2/base.bend; a source layout: the bun binary
                     and every bend-src/bend2/*.ts) plus toolchain.lock.json's pinned hashes of the same files, and tools/check.sh (the
                     wrapper that sets the limits). `import Base` is the checker's own file.
  settings           the string the caller passes (--settings): ulimit -s, the JSC stack budget, the memory cap, the JSC heap hint,
                     the timeout, the cpu quota, and the Bun flags. A different setting is a different key.
  roots and closure  the sorted root paths, then for every module of their transitive closure (children included once) its
                     repository-relative path and the sha256 of its bytes. The umbrella file itself is `import Base` plus one import line
                     per root, so the roots stand for its bytes (its relative prefix depends on where the run directory is).
                     Imports are resolved exactly as the checker does (bend2/bend.ts): `import Base` is the checker's; `import 0x<id>/p.bend`
                     is BEND_LIB/0x<id>/p.bend (vendor/bendhub); any other path is relative to the importing file. EVERY line that starts
                     with `import` is read, wherever it stands in the file. An import that cannot be parsed or whose file does not exist (or a
                     package-name import, which the checker resolves through a mutable name table) makes the umbrella NOT cacheable: it is
                     always rerun.

Only a pass is stored (rc 0 and the exact line ALL PROOFS CHECK, decided by the caller); a failure, timeout or out-of-memory is never stored.
An entry is {key, roots, seconds, peak_mb, commit, utc}. The store is the directory UMB_CACHE_DIR (default
/srv/ssz-optimization/agents/umbcache), outside any repository copy; each entry is written atomically.
"""
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE_DIR = os.environ.get('UMB_CACHE_DIR', '/srv/ssz-optimization/agents/umbcache')
IMPORT_LINE = re.compile(r'^\s*import(\s|$)')
IMPORT = re.compile(r'^\s*import\s+(\S+)(?:\s+as\s+\w+)?\s*(?:#.*)?$')


class NotCacheable(Exception):
    pass


def sha(b):
    return hashlib.sha256(b).hexdigest()


def file_sha(path):
    with open(path, 'rb') as f:
        return sha(f.read())


def toolchain_dir():
    return os.environ.get('BEND_TOOLCHAIN', '/srv/ssz-optimization/toolchain-memo-788a6866')


def bend_lib():
    lib = os.environ.get('BEND_LIB') or os.path.join(ROOT, 'vendor/bendhub')
    return lib if os.path.isabs(lib) else os.path.join(ROOT, lib)


def checker_identity(lock_path=None):
    """The checker's files and the lock's pinned hashes: the same bytes tools/verify_pins.py compares, hashed again here."""
    t = toolchain_dir()
    parts = []
    if os.path.exists(os.path.join(t, 'bin/bend')) and os.path.exists(os.path.join(t, 'bend2/base.bend')):
        names = ['bin/bend', 'bend2/base.bend'] + sorted(
            os.path.join('bend2', f) for f in os.listdir(os.path.join(t, 'bend2')) if f.endswith('.ts'))
    else:
        names = ['bun-linux-x64/bun'] + sorted(
            os.path.relpath(os.path.join(d, f), t) for d, _, fs in os.walk(os.path.join(t, 'bend-src/bend2')) for f in fs if f.endswith('.ts'))
        names.append('bend-src/bend2/base.bend')
    for n in names:
        p = os.path.join(t, n)
        if not os.path.exists(p):
            raise NotCacheable('checker file missing: ' + n)
        parts.append(f'{n}\0{file_sha(p)}')
    lock = lock_path or os.environ.get('BEND_LOCK') or os.path.join(ROOT, 'toolchain.lock.json')
    if not os.path.isabs(lock):
        lock = os.path.join(ROOT, lock)
    with open(lock, 'rb') as f:
        parts.append('lock\0' + sha(f.read()))
    parts.append('check.sh\0' + file_sha(os.path.join(ROOT, 'tools/check.sh')))
    return sha('\n'.join(parts).encode())


def resolve_imports(path, text):
    """The files a module imports, as absolute paths; raises NotCacheable on anything not resolved exactly."""
    out = []
    for line in text.split('\n'):
        if not IMPORT_LINE.match(line):
            continue
        m = IMPORT.match(line)
        if not m:
            raise NotCacheable(f'{os.path.relpath(path, ROOT)}: unparsed import line {line.strip()[:60]!r}')
        p = m.group(1)
        if p == 'Base':
            continue
        if p.startswith('0x'):
            target = os.path.normpath(os.path.join(bend_lib(), p))
        elif '@' in p.split('/')[0] or not (p.startswith('./') or p.startswith('../')):
            raise NotCacheable(f'{os.path.relpath(path, ROOT)}: import {p} is not a path')
        else:
            target = os.path.normpath(os.path.join(os.path.dirname(path), p))
        if not os.path.isfile(target):
            raise NotCacheable(f'{os.path.relpath(path, ROOT)}: import {p} does not resolve')
        out.append(target)
    return out


_MODULES = {}   # path -> (sha256, imports or the NotCacheable it raised): a run reads each file once


def module(p):
    if p not in _MODULES:
        if not os.path.isfile(p):
            raise NotCacheable('root does not exist: ' + os.path.relpath(p, ROOT))
        with open(p, 'rb') as f:
            data = f.read()
        try:
            imps = resolve_imports(p, data.decode('utf-8', 'surrogateescape'))
        except NotCacheable as e:
            imps = e
        _MODULES[p] = (sha(data), imps)
    h, imps = _MODULES[p]
    if isinstance(imps, NotCacheable):
        raise imps
    return h, imps


def closure(roots):
    """{path: sha256} of every module reachable from the roots (the roots included)."""
    seen = {}
    todo = [os.path.normpath(os.path.join(ROOT, r)) for r in roots]
    while todo:
        p = todo.pop()
        if p in seen:
            continue
        h, imps = module(p)
        seen[p] = h
        todo += imps
    return seen


def rel(p):
    for base in (ROOT, os.path.dirname(bend_lib())):
        if p.startswith(base + os.sep):
            return os.path.relpath(p, base) if base == ROOT else 'LIB/' + os.path.relpath(p, bend_lib())
    return p


def key(roots, settings='', ident=None):
    """The cache key of the umbrella over `roots` (repository-relative paths); NotCacheable if an import is not exact."""
    clo = closure(sorted(roots))
    h = hashlib.sha256()
    h.update(('checker\0' + (ident or checker_identity()) + '\n').encode())
    h.update(('settings\0' + settings + '\n').encode())
    h.update(('roots\0' + '\0'.join(sorted(roots)) + '\n').encode())
    for p in sorted(clo, key=rel):
        h.update(f'{rel(p)}\0{clo[p]}\n'.encode())
    return h.hexdigest()


def entry_path(k):
    return os.path.join(CACHE_DIR, k + '.json')


def lookup(k):
    try:
        with open(entry_path(k)) as f:
            e = json.load(f)
    except (OSError, ValueError):
        return None
    return e if e.get('key') == k else None


def commit():
    try:
        return subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True, stderr=subprocess.DEVNULL).strip()
    except (OSError, subprocess.CalledProcessError):
        return os.environ.get('EVIDENCE_COMMIT', 'unknown')


def store(k, roots, seconds, peak_mb):
    os.makedirs(CACHE_DIR, exist_ok=True)
    e = {'key': k, 'roots': sorted(roots), 'seconds': seconds, 'peak_mb': peak_mb, 'commit': commit(),
         'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
    fd, tmp = tempfile.mkstemp(dir=CACHE_DIR, prefix='.tmp')
    with os.fdopen(fd, 'w') as f:
        json.dump(e, f)
    os.replace(tmp, entry_path(k))
    return e


def clear():
    n = 0
    if os.path.isdir(CACHE_DIR):
        for f in os.listdir(CACHE_DIR):
            if f.endswith('.json') or f.startswith('.tmp'):
                os.remove(os.path.join(CACHE_DIR, f))
                n += 1
    return n


def prepare(plan, settings_tsv, out, k_recheck):
    """For every umbrella of the plan: its key (or '-' when not cacheable), whether the cache holds it, and which K hits are
    re-run anyway (the safety net: the cache is never trusted blindly). Writes `out` (u, key, state, seconds, peak_mb, commit,
    utc) with state one of miss, hit, recheck, uncacheable, and prints a one-line summary."""
    import random
    sett = dict(l.rstrip('\n').split('\t', 1) for l in open(settings_tsv) if l.strip())
    ident = checker_identity()
    rows = []
    for l in open(plan):
        f = l.rstrip('\n').split('\t')
        u, roots = f[0], f[3].split()
        try:
            k = key(roots, sett.get(u, ''), ident)
        except NotCacheable as e:
            rows.append([u, '-', 'uncacheable', '', '', '', str(e)[:80]])
            continue
        e = lookup(k)
        rows.append([u, k, 'hit' if e else 'miss', *(([str(e['seconds']), str(e['peak_mb']), e['commit'], e['utc']]) if e else ['', '', '', ''])])
    hits = [r for r in rows if r[2] == 'hit']
    for r in random.SystemRandom().sample(hits, min(k_recheck, len(hits))):
        r[2] = 'recheck'
    with open(out, 'w') as h:
        for r in rows:
            h.write('\t'.join(r) + '\n')
    c = {st: sum(r[2] == st for r in rows) for st in ('hit', 'recheck', 'miss', 'uncacheable')}
    print('umbrella cache: %d umbrellas: %d reused, %d re-run as a safety check, %d to run, %d not cacheable' % (
        len(rows), c['hit'], c['recheck'], c['miss'], c['uncacheable']))


def verify_rows(stamp):
    """Recompute the key of each cached row of a stamp from the current tree; the list of rows that no longer match."""
    st = json.load(open(stamp))
    bad = []
    ident = None
    for r in st.get('umbrellas', []):
        if not r.get('cached'):
            continue
        try:
            ident = ident or checker_identity()
            k = key(r['roots_list'], r.get('settings', ''), ident)
        except (NotCacheable, KeyError) as e:
            bad.append((r['umbrella'], 'not recomputable: %s' % e))
            continue
        if k != r.get('cache_key'):
            bad.append((r['umbrella'], 'key %s != stamped %s' % (k[:12], str(r.get('cache_key'))[:12])))
    return bad


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    cmd, rest = a[0], a[1:]

    def opt(name, default=None):
        if name in rest:
            i = rest.index(name)
            v = rest[i + 1]
            del rest[i:i + 2]
            return v
        return default
    if cmd == 'key':
        settings = opt('--settings', '')
        try:
            print(key(rest, settings))
        except NotCacheable as e:
            print('not cacheable: %s' % e, file=sys.stderr)
            sys.exit(3)
    elif cmd == 'lookup':
        e = lookup(rest[0])
        if e is None:
            sys.exit(1)
        print(json.dumps(e))
    elif cmd == 'store':
        s, m = float(opt('--seconds')), int(opt('--peak-mb'))
        roots = opt('--roots', '')
        store(rest[0], roots.split() if roots else [], s, m)
    elif cmd == 'prepare':
        k = int(opt('--recheck', '3'))
        prepare(rest[0], rest[1], rest[2], k)
    elif cmd == 'clear':
        print('cleared %d entries' % clear())
    elif cmd == 'verify-rows':
        bad = verify_rows(rest[0])
        for u, why in bad:
            print('cached umbrella %s: %s' % (u, why))
        sys.exit(1 if bad else 0)
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
