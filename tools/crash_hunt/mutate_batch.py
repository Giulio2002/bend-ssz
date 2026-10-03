#!/usr/bin/env python3
"""Round-3 crash hunt (c): hostile decode at scale for the real Fulu containers, one process per chunk of mutants.

    python3 tools/crash_hunt/mutate_batch.py --repo . --cs /srv/ssz-optimization/agents/specaudit/cs --name SignedBeaconBlock \
        --per-seed 35000 --seeds zero,rand0,rand1 --chunk 5000 --jobs 3 --out DIR [--ref-limit N]

Builds mutants of valid encodings from the reference port (tools/spec_audit/ssz_ref.py), runs build/ch/mb_<name> (see gen_mutbatch.py)
and judges every line:
  CRASH   the program did not finish a chunk (signal, abort, timeout, out of memory) -> the last printed mutant is the culprit
  WRONG   accepted something the reference rejects, or rejected something the reference accepts, or accepted with
          serialize(decode(x)) != x (SSZ is canonical), or serialize refused an accepted object
Mutation classes: offset slot values (edge values, neighbours, copies of other slots), swaps, equal offsets, two-slot combos, byte flips,
truncations at every byte boundary of the first 4096 bytes and at every offset target +-{0,1,4}, sizes past the buffer.
"""
import argparse
import collections
import json
import os
import random
import struct
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'spec_audit'))
import ssz_ref as S  # noqa: E402
from refparse import Ref  # noqa: E402


def slots(t, data, base, out):
    """absolute byte positions of every offset word of the encoding `data` (of type t, starting at `base`)"""
    k = t[0]
    try:
        if k in ('container', 'progcontainer'):
            fts = [ft for _, ft in t[1]]
            pos, offs = 0, []
            for ft in fts:
                if S.is_variable_size(ft):
                    offs.append((pos, S.u32(data[pos:pos + 4])))
                    pos += 4
                else:
                    pos += S.fixed_size(ft)
            for p, _ in offs:
                out.append(base + p)
            j = 0
            pos = 0
            for ft in fts:
                if S.is_variable_size(ft):
                    s = offs[j][1]
                    e = offs[j + 1][1] if j + 1 < len(offs) else len(data)
                    slots(ft, data[s:e], base + s, out)
                    pos += 4
                    j += 1
                else:
                    pos += S.fixed_size(ft)
        elif k in ('list', 'proglist', 'vector'):
            et = t[1]
            if S.is_variable_size(et) and len(data) >= 4:
                first = S.u32(data[:4])
                n = first // 4
                offs = [S.u32(data[4 * i:4 * i + 4]) for i in range(n)]
                for i in range(n):
                    out.append(base + 4 * i)
                    e = offs[i + 1] if i + 1 < n else len(data)
                    slots(et, data[offs[i]:e], base + offs[i], out)
        elif k == 'union' and len(data) > 1:
            sel = data[0]
            if sel < len(t[1]) and t[1][sel] != ('null',):
                slots(t[1][sel], data[1:], base + 1, out)
    except (IndexError, ValueError):
        pass


def edits_to_words(buf, edits):
    """edits [(pos, 4 bytes)] -> {word index: new word}; None if more than 2 words are touched"""
    b = bytearray(buf)
    touched = set()
    for pos, val in edits:
        for j in range(4):
            if pos + j < len(b):
                b[pos + j] = val[j]
                touched.add((pos + j) // 4)
    if len(touched) > 2:
        return None
    res = {}
    for w in touched:
        res[w] = struct.unpack('<I', bytes(b[4 * w:4 * w + 4]).ljust(4, b'\0'))[0]
    return res


def mk_ops(seed, size, edits):
    """one op of 7 words, or None. The seed buffer is zero padded to whole words."""
    ws = edits_to_words(seed, edits)
    if ws is None:
        return None
    padded = seed + b'\0' * (-len(seed) % 4)
    idx = sorted(ws)
    while len(idx) < 2:
        idx.append(idx[0] if idx else 0)
    a, b = idx[0], idx[1]
    new = lambda i: ws.get(i, struct.unpack('<I', padded[4 * i:4 * i + 4])[0])
    old = lambda i: struct.unpack('<I', padded[4 * i:4 * i + 4])[0]
    if a == b:  # the second write repeats the first: writing the new value twice, restoring twice
        return (size, a, new(a), old(a), a, new(a), old(a))
    return (size, a, new(a), old(a), b, new(b), old(b))


def apply_edits(seed, size, edits):
    b = bytearray(seed)
    for pos, val in edits:
        for j in range(4):
            if pos + j < len(b):
                b[pos + j] = val[j]
    return bytes(b[:size]) if size <= len(b) else None


def u32b(x):
    return struct.pack('<I', x & 0xFFFFFFFF)


def gen_mutants(seed, sl, rng, n):
    """list of (size, edits, label)"""
    L = len(seed)
    out = []
    vals = [0, 1, 2, 3, 4, 5, 7, 8, 2**31 - 1, 2**31, 2**32 - 1, 2**32 - 4, L, L + 1, L - 1, L + 4, L - 4, 2**16, 2**20, 2**24]
    orig = {p: S.u32(seed[p:p + 4]) for p in sl}
    # A: one slot, edge values and neighbours
    for p in sl:
        o = orig[p]
        cand = set(vals) | {o + 1, o - 1, o + 4, o - 4, o + 16, o * 2, o + 2**20, o | 2**31, o ^ 1, o ^ 4}
        cand |= {orig[q] for q in rng.sample(sl, min(6, len(sl)))}
        for v in sorted(cand):
            out.append((L, [(p, u32b(v))], 'slot'))
    # B: swaps and equal offsets
    for i in range(len(sl) - 1):
        p, q = sl[i], sl[i + 1]
        out.append((L, [(p, u32b(orig[q])), (q, u32b(orig[p]))], 'swap_adj'))
        out.append((L, [(p, u32b(orig[q]))], 'equal_next'))
        out.append((L, [(q, u32b(orig[p]))], 'equal_prev'))
    for _ in range(min(len(sl) * 4, 4000)):
        if len(sl) >= 2:
            p, q = rng.sample(sl, 2)
            out.append((L, [(p, u32b(orig[q])), (q, u32b(orig[p]))], 'swap_any'))
    # F: truncations at every boundary of the first 4096 bytes, around every offset target, past the buffer
    for s in range(0, min(L, 4096) + 1):
        out.append((s, [], 'trunc_low'))
    tg = set()
    for p in sl:
        for d in (-4, -1, 0, 1, 4):
            if 0 <= orig[p] + d <= L:
                tg.add(orig[p] + d)
        for d in (0, 1, 4):
            tg.add(min(L, p + d))
    for s in sorted(tg):
        out.append((s, [], 'trunc_target'))
    for d in range(1, 9):
        out.append((L + d, [], 'size_past'))
    for _ in range(300):
        out.append((rng.randrange(0, L + 1), [], 'trunc_rand'))
    # C: random mutants until n
    guard = 0
    while len(out) < n and guard < 20 * n:
        guard += 1
        r = rng.random()
        if r < 0.30 and len(sl) >= 2:
            p, q = rng.sample(sl, 2)
            out.append((L, [(p, u32b(rng.choice(vals + [orig[q], orig[p] + rng.randrange(-64, 64)]))), (q, u32b(rng.choice(vals + [orig[p]])))], 'slot2'))
        elif r < 0.45 and sl:
            p = rng.choice(sl)
            out.append((L, [(p, u32b(rng.choice(vals) + rng.randrange(-8, 9)))], 'slot_rand'))
        elif r < 0.85:
            k = rng.choice([1, 1, 2, 3])
            ed = []
            for _ in range(k):
                pos = rng.randrange(0, L)
                near = rng.random() < 0.5 and sl
                if near:
                    pos = rng.choice(sl) + rng.randrange(-4, 8)
                    pos = max(0, min(L - 1, pos))
                b = bytearray(seed[pos:pos + 4].ljust(4, b'\0'))
                b[rng.randrange(0, 4)] ^= 1 << rng.randrange(0, 8)
                ed.append((pos, bytes(b)))
            out.append((L, ed, 'flip'))
        else:
            out.append((rng.randrange(max(0, L - 64), L + 1), [], 'trunc_tail'))
    rng.shuffle(out)
    return out


def run_chunk(prog, seedfile, ops, every, tmp, tag, timeout):
    opsf = os.path.join(tmp, 'ops_%s.bin' % tag)
    with open(opsf, 'wb') as f:
        f.write(struct.pack('<I', len(ops) + 1))
        for o in ops:
            f.write(struct.pack('<7I', *[x & 0xFFFFFFFF for x in o]))
        f.write(struct.pack('<7I', 0, 0, 0, 0, 0, 0, 0))   # the sentinel: size 0, no-op writes
    env = {**os.environ, 'SSZ_INPUT': seedfile, 'SSZ_OPS': opsf, 'SSZ_ROOT_EVERY': str(every)}
    t0 = time.time()
    try:
        p = subprocess.Popen(['nice', '-n', '19', prog, '--threads', '1', '--gpu', 'off'], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                             preexec_fn=lambda: __import__('resource').setrlimit(__import__('resource').RLIMIT_STACK, (16384 * 1024, 16384 * 1024)))
        so, se = p.communicate(timeout=timeout)
        rc = p.returncode
    except subprocess.TimeoutExpired:
        p.kill()
        so, se = p.communicate()
        rc = 'timeout'
    os.unlink(opsf)
    return rc, so, se, time.time() - t0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--name', required=True)
    ap.add_argument('--per-seed', type=int, default=35000)
    ap.add_argument('--seeds', default='zero,rand0,rand1')
    ap.add_argument('--chunk', type=int, default=5000)
    ap.add_argument('--jobs', type=int, default=3)
    ap.add_argument('--timeout', type=int, default=1500)
    ap.add_argument('--root-every', type=int, default=0)
    ap.add_argument('--ref-limit', type=int, default=10**9, help='judge at most this many mutants with the (slow) reference')
    ap.add_argument('--out', required=True)
    ap.add_argument('--rng', default='r3')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    ref = Ref(a.cs)
    t = ref.type_of(a.name)
    prog = os.path.join(a.repo, 'build', 'ch', 'mb_' + a.name)
    rng = random.Random('%s/%s' % (a.rng, a.name))
    seeds = []
    for lab in a.seeds.split(','):
        if lab == 'zero':
            v = S.zero_value(t)
        else:
            v = S.random_value(t, random.Random('%s/%s/%s' % (a.rng, a.name, lab)), 3)
        seeds.append((lab, S.serialize(t, v)))
    tally = collections.Counter()
    cls = collections.Counter()
    findings = []
    ref_budget = a.ref_limit
    for lab, seed in seeds:
        sl = []
        slots(t, seed, 0, sl)
        sl = sorted(set(sl))
        print('seed', lab, 'len', len(seed), 'slots', len(sl), flush=True)
        seedfile = os.path.join(a.out, 'seed_%s_%s.bin' % (a.name, lab))
        open(seedfile, 'wb').write(seed)
        muts = gen_mutants(seed, sl, rng, a.per_seed)
        ops, meta = [], []
        for size, edits, label in muts:
            o = mk_ops(seed, size, edits)
            if o is None:
                continue
            ops.append(o)
            meta.append((size, edits, label))
        print('  mutants', len(ops), flush=True)
        chunks = [(i, ops[i:i + a.chunk], meta[i:i + a.chunk]) for i in range(0, len(ops), a.chunk)]

        def work(c):
            i0, co, cm = c
            tag = '%s_%s_%d' % (a.name, lab, i0)
            rc, so, se, sec = run_chunk(prog, seedfile, co, a.root_every, a.out, tag, a.timeout)
            return c, rc, so, se, sec
        with ThreadPoolExecutor(a.jobs) as ex:
            for c, rc, so, se, sec in ex.map(work, chunks):
                i0, co, cm = c
                lines = [l for l in so.splitlines() if l.startswith(a.name + ' ')]
                done = so.rstrip().endswith('DONE')
                got = {}
                for l in lines:
                    parts = l.split()
                    got[int(parts[1])] = parts[2:]
                if not done or rc != 0:
                    last = max(got) if got else -1
                    culprit = last + 1
                    tally['CRASH'] += 1
                    cls['CRASH:%s' % (cm[culprit][2] if culprit < len(cm) else '?')] += 1
                    findings.append({'class': 'CRASH', 'seed': lab, 'chunk': i0, 'rc': rc, 'culprit_index': i0 + culprit, 'op': list(co[culprit]) if culprit < len(co) else None,
                                     'kind': cm[culprit][2] if culprit < len(cm) else None, 'stderr': se[-300:], 'sec': round(sec, 1)})
                    print('CRASH', lab, i0, rc, se[-200:], flush=True)
                for j in range(len(co)):
                    if j not in got:
                        continue
                    size, edits, label = cm[j]
                    parts = got[j]
                    acc = parts[0] == 'd=1'
                    exp = None
                    if ref_budget > 0:
                        data = apply_edits(seed, size, edits)
                        if data is None:
                            exp = False
                        else:
                            ref_budget -= 1
                            try:
                                v = S.deserialize(t, data)
                                exp = S.serialize(t, v) == data
                            except (S.Reject, IndexError, ValueError, AssertionError):
                                exp = False
                    verdict = 'OK'
                    why = ''
                    if acc:
                        kv = dict(p.split('=') for p in parts[1:])
                        if kv.get('e') != '1':
                            verdict, why = 'WRONG', 'accepted but serialize refused'
                        elif kv.get('a') != kv.get('b') or int(kv.get('sz')) != size:
                            verdict, why = 'WRONG', 'serialize(decode(x)) != x (sz %s vs %d)' % (kv.get('sz'), size)
                        elif exp is False:
                            verdict, why = 'WRONG', 'accepted, the reference rejects'
                    elif exp is True:
                        verdict, why = 'WRONG', 'rejected, the reference accepts'
                    tally[verdict] += 1
                    tally['accepted' if acc else 'rejected'] += 1
                    cls['%s:%s' % (label, 'acc' if acc else 'rej')] += 1
                    if verdict != 'OK' and len(findings) < 200:
                        findings.append({'class': verdict, 'why': why, 'seed': lab, 'index': i0 + j, 'size': size, 'kind': label,
                                         'edits': [[p, v.hex()] for p, v in edits], 'line': ' '.join(parts)[:200]})
                print('  chunk', i0, 'rc', rc, 'sec', round(sec, 1), 'lines', len(got), 'tally', dict(tally), flush=True)
    res = {'name': a.name, 'tally': dict(tally), 'classes': dict(cls), 'findings': findings[:200]}
    json.dump(res, open(os.path.join(a.out, 'mutate_batch_%s.json' % a.name), 'w'), indent=1)
    print('FINAL', json.dumps(res['tally']), flush=True)


if __name__ == '__main__':
    main()
