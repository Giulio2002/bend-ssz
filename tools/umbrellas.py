#!/usr/bin/env python3
"""tools/umbrellas.py [--target S] [--costs FILE] [--out DIR] [--files LIST]: write umbrella files.

Bend has no module cache: `bend f.bend --check-only` checks every definition of f AND of every
module in f's import closure (main.ts book_read -> bend.ts book_valid walks the whole book). A
full sweep of ~5,300 files therefore re-checks the shared modules thousands of times. An
umbrella is a file that only imports a set of root files; one check of it checks each module in
the union of their closures exactly once. This script partitions the root files (the files no
other file imports; their closures cover every file) into umbrellas of about S estimated
seconds each, grouping roots whose closures overlap, and writes DIR/NNN.bend plus DIR/plan.tsv
(umbrella, estimated seconds, modules, roots), largest first. tools/check_fast.sh runs them.

Costs: FILE holds per-file check times (file, exit, ok, seconds, peak MB; tools/check_costs.tsv). A module's
own cost is estimated as its standalone time minus the estimated own costs of the rest of its
closure (clamped at 0); files missing from FILE get the median. Only the balance of the
partition depends on the costs, never its coverage: every file is in some umbrella's closure,
which the script asserts. Run from the repository root (reads import headers only).
"""
import argparse, json, os, re, statistics, subprocess, sys

IMPORT = re.compile(r'import\s+(\S+)(?:\s+as\s+\w+)?\s*(?:#.*)?$')


def bend_files():
    try:
        out = subprocess.check_output(['git', 'ls-files', '*.bend'], text=True,
                                      stderr=subprocess.DEVNULL).split()
    except (OSError, subprocess.CalledProcessError):  # a copy without .git (the ssz server's)
        out = []
        for d, ds, fs in os.walk('.'):
            ds[:] = sorted(x for x in ds if not x.startswith('.') and x not in ('build', 'node_modules'))
            out += [os.path.relpath(os.path.join(d, f)) for f in fs if f.endswith('.bend')]
    return sorted(f for f in out if not f.startswith(('tools/', 'vendor/')))


def imports(f):
    out = []
    with open(f) as h:
        for line in h:
            s = line.strip()
            if not s or s.startswith('#'):
                continue
            if not re.match(r'import(\s|$)', s):
                break
            m = IMPORT.match(s)
            p = m.group(1) if m else 'Base'
            if p == 'Base' or p.startswith('0x') or '@' in p.split('/')[0]:
                continue  # Base and hub packages: checked by every umbrella anyway
            out.append(os.path.normpath(os.path.join(os.path.dirname(f), p)))
    return out


SOLO_SECONDS = 100.0


def family_split(u, clo, w):
    """Split an oversized umbrella u = (cost, roots, modules) by root family and size: proofs/gate (and its slop/ folders),
    proofs/slop, proofs/api, proofs/obj, e2e and the rest are checked in separate umbrellas, and a family is cut into
    contiguous slices of its sorted names: about 200 roots per slice (gate, slop, api, obj), e2e in three, the rest
    (benchmarks, mixed leftovers) in halves from 4 roots. The cost model (stale standalone times) cannot see which roots are heavy;
    measured on the ssz server, the 2573-root umbrella (790 s) became parts of 35 to 375 s run side by side, and the
    largest parts (proofs/api 404 s, proofs/gate 397 s, benchmarks 394 s) were halved again to stay under 360 s.
    Roots only move between umbrellas, each stays in exactly one: coverage is unchanged."""
    cost, roots, _ = u
    fam = {}
    for r in roots:
        k = ('gate' if r.startswith('proofs/gate/') else 'slop' if r.startswith('proofs/slop/') else 'api' if r.startswith('proofs/api/')
             else 'obj' if r.startswith('proofs/obj/') else 'e2e' if r.startswith('e2e/') else 'rest')
        fam.setdefault(k, []).append(r)
    for k in [k for k, v in fam.items() if len(v) < 15 and k != 'rest']:
        fam.setdefault('rest', []).extend(fam.pop(k))
    parts = []
    for k, v in sorted(fam.items()):
        v = sorted(v)
        n = 3 if k == 'e2e' and len(v) > 100 else 2 if k == 'rest' and len(v) >= 4 else max(1, -(-len(v) // 200)) if k != 'rest' else 1
        parts += [v[i * len(v) // n:(i + 1) * len(v) // n] for i in range(n)]
    if len(parts) < 2:
        return [u]
    out = []
    for ps in parts:
        have = set()
        for r in ps:
            have |= clo[r]
        out.append((sum(w[m] for m in have), ps, len(have)))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--target', type=float, default=60.0, help='estimated seconds per umbrella')
    ap.add_argument('--costs', default='tools/check_costs.tsv')
    ap.add_argument('--out', default='build/umbrellas')
    ap.add_argument('--max-umb', type=float, default=0.0,
                    help='split an umbrella of 4 or more roots whose estimated seconds exceed this by root family (0: never); a split '
                         'repeats the imports its parts share, so it pays only for umbrellas that dominate the wall time')
    ap.add_argument('--hist', default='tools/umb_hist.tsv',
                    help='measured wall seconds of earlier umbrellas (first root, seconds); an umbrella whose first root is listed gets '
                         'that figure as its estimate (ordering and memory model), so the plan is predictive where it has been measured')
    ap.add_argument('--files', help='only cover these files (one per line) instead of all')
    a = ap.parse_args()

    files = bend_files()
    imp, todo = {}, list(files)
    while todo:
        f = todo.pop()
        if f not in imp:
            imp[f] = imports(f)
            todo += imp[f]
    # closures, children before parents
    order, state = [], {}
    for f0 in imp:
        stack = [(f0, 0)]
        while stack:
            f, i = stack.pop()
            if i == 0:
                if state.get(f) == 2:
                    continue
                if state.get(f) == 1:
                    sys.exit('umbrellas: import cycle through ' + f)
                state[f] = 1
            if i < len(imp[f]):
                stack.append((f, i + 1))
                g = imp[f][i]
                if state.get(g) != 2:
                    stack.append((g, 0))
            else:
                state[f] = 2
                order.append(f)
    idx = {f: i for i, f in enumerate(order)}
    clo = {}
    for f in order:
        s = {idx[f]}
        for g in imp[f]:
            s |= clo[g]
        clo[f] = frozenset(s)

    t = {}
    if os.path.exists(a.costs):
        for line in open(a.costs):
            p = line.rstrip('\n').split('\t')
            if len(p) >= 4 and p[0] in imp:
                t[p[0]] = float(p[3])
    base = min(t.values()) if t else 0.0
    own = {}
    for f in order:  # topological: the closure's other modules are already estimated
        if f in t:
            own[f] = max(0.0, t[f] - base - sum(own.get(order[j], 0.0) for j in clo[f] if j != idx[f]))
    med = statistics.median(own.values()) if own else 1.0
    w = [own.get(f, med) + 0.02 for f in order]

    want = files if not a.files else [l.strip() for l in open(a.files) if l.strip()]
    wanted = set(want)
    imported = {g for f in want for g in clo[f] if g != idx[f]}
    roots = sorted(f for f in want if idx[f] not in imported)

    # greedy: seed with the costliest unassigned root, then keep adding the root whose closure
    # adds the least new cost, until the umbrella reaches the target
    users = {}
    for r in roots:
        for m in clo[r]:
            users.setdefault(m, []).append(r)
    full = {r: sum(w[m] for m in clo[r]) for r in roots}
    left = set(roots)
    umbs = []
    while left:
        seed = max(left, key=lambda r: (full[r], r))
        have, members, cost = set(), [], 0.0
        marg = {r: full[r] for r in left}
        def add(r):
            nonlocal cost
            left.discard(r); marg.pop(r, None); members.append(r)
            for m in clo[r]:
                if m not in have:
                    have.add(m); cost += w[m]
                    for u in users[m]:
                        if u in marg:
                            marg[u] -= w[m]
        add(seed)
        while marg:
            r = min(marg, key=lambda r: (marg[r], r))
            if marg[r] > 0.5 and (cost >= a.target or cost + marg[r] > a.target * 1.15):
                break
            add(r)   # roots whose closure is already inside (marginal cost ~0) ride along even in a full umbrella:
                     # checking them again in an umbrella of their own (an expensive import, e.g. coll_words at ~400 s) would repeat it
        umbs.append((cost, sorted(members), len(have)))
    if a.max_umb > 0:
        def again(u, depth=0):
            g = family_split(u, clo, w) if u[0] > a.max_umb and len(u[1]) >= 4 and depth < 3 else [u]
            return [x for q in g for x in (again(q, depth + 1) if len(g) > 1 else [q])]
        split = [again(u) for u in umbs]
        # the parts of a split umbrella first (their estimate is far too low: they ran 200 to 375 s, the largest of the run),
        # the rest by estimate: umb_pool starts umbrellas in file order, longest first
        umbs = [p for g in split if len(g) > 1 for p in sorted(g, key=lambda u: -u[0])] + sorted((g[0] for g in split if len(g) == 1), key=lambda u: -u[0])
    else:
        umbs.sort(key=lambda u: -u[0])

    if os.path.exists(a.hist):
        hist, solos = {}, set()
        for line in open(a.hist):
            q = line.rstrip('\n').split('\t')
            if len(q) >= 2 and not line.startswith('#'):
                hist[q[0]] = float(q[1])
                if len(q) >= 3 and q[2] == 'solo':
                    solos.add(q[0])
        if hist:
            # a root marked `solo` in the history file and measured at SOLO_SECONDS or more on its own gets an umbrella of its own: the wall is
            # then the slowest single file, not the sum under load (the three block witness umbrellas of 412 to 462 s held files of
            # 35 to 174 s each standalone)
            def solo(c, ms, nm):
                big = [m for m in ms if m in solos and hist[m] >= SOLO_SECONDS]
                if len(ms) < 2 or not big:
                    return [(c, ms, nm)]
                rest = [m for m in ms if m not in big]
                return [(hist[m], [m], nm) for m in big] + ([(c, rest, nm)] if rest else [])
            umbs = [x for u in umbs for x in solo(*u)]
            umbs = sorted(((hist.get(ms[0], c), ms, nm) for c, ms, nm in umbs), key=lambda u: -u[0])
    covered = set().union(*[clo[r] for _, ms, _ in umbs for r in ms]) if umbs else set()
    miss = [f for f in want if idx[f] not in covered]
    assert not miss, 'umbrellas miss ' + ', '.join(miss[:5])

    os.makedirs(a.out, exist_ok=True)
    for f in os.listdir(a.out):
        if f.endswith('.bend') or f == 'plan.tsv':
            os.remove(os.path.join(a.out, f))
    up = os.path.relpath('.', a.out)
    with open(os.path.join(a.out, 'plan.tsv'), 'w') as plan:
        for n, (cost, ms, nm) in enumerate(umbs):
            name = '%03d.bend' % n
            with open(os.path.join(a.out, name), 'w') as h:
                h.write('# generated by tools/umbrellas.py: checks these roots and their imports once\n')
                h.write('import Base\n')
                for i, r in enumerate(ms):
                    h.write('import %s/%s as U%d\n' % (up, r, i))
            plan.write('%s\t%.1f\t%d\t%s\n' % (name, cost, nm, ' '.join(ms)))
    tot = sum(u[0] for u in umbs)
    print('umbrellas: %d files, %d roots -> %d umbrellas, estimated %.0f s total (%.0f s unshared)'
          % (len(wanted), len(roots), len(umbs), tot, sum(w)), file=sys.stderr)


if __name__ == '__main__':
    main()
