#!/usr/bin/env python3
"""Round-3 crash hunt (b): differential test of the packed collections built through public setters only.

    python3 tools/crash_hunt/gen_packed_diff.py gen --repo . --out tools/crash_hunt/pd          (writes pd_<id>.bend)
    python3 tools/crash_hunt/gen_packed_diff.py run --repo . --out DIR [--only id,id] [--jobs 3]   (server; needs build/ch/pd_<id>)

Every program takes SSZ_N (appends), SSZ_SETS (sets at pseudo-random indices), SSZ_SEED, SSZ_OVER (1: one more append after the n appends;
at the limit it must be refused) and prints `n=.. [over_ok=..] len=.. valid=.. root=.. [ser_ok=.. ser_sz=.. ser_cs=..]`. The values come from
the LCG x' = x * 1664525 + 1013904223 mod 2^32, replicated in Python, so the reference port (ssz_ref: serialize / hash_tree_root) computes the
expected bytes and root of the same value. Vectors start from the default and only use set (SSZ_SETS of them).
"""
import argparse
import collections
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'spec_audit'))

M32 = 0xFFFFFFFF
BITS = {'u8': 8, 'u16': 16, 'u32': 32, 'u64': 64}


def nx(x):
    return (x * 1664525 + 1013904223) & M32


SPECS = []


EL = {'b32': 'import ../../../types/FuluBytes32_def_generated.bend as Bt', 'b48': 'import ../../../types/FuluBytes48_def_generated.bend as Bt',
      'u128': 'import ../../../types/uint128_def_generated.bend as Bt', 'u256': 'import ../../../types/uint256_def_generated.bend as Bt', 'cell': ''}


def add(file, prefix, kind, limit, shape, n=None):
    SPECS.append(dict(id=file, file=file, prefix=prefix, kind=kind, limit=limit, shape=shape, vn=n))


for b in (1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 16, 17, 31, 32, 33, 256, 257, 511, 512, 513, 1280, 1281):
    add('bitlist_%d' % b, 'bits%d' % b, 'bit', b, 'bitlist')
add('Fulu_bitlist_2048', 'bits2048', 'bit', 2048, 'bitlist')
add('Fulu_bitlist_131072', 'bits131072', 'bit', 131072, 'bitlist')
add('progbitlist', 'pbits', 'bit', None, 'progbits')
add('proglist_bool', 'pl_bool', 'bool', None, 'proglist')
add('proglist_uint8', 'pl_u8', 'u8', None, 'proglist')
add('proglist_uint16', 'pl_u16', 'u16', None, 'proglist')
add('proglist_uint32', 'pl_u32', 'u32', None, 'proglist')
add('proglist_uint64', 'pl_u64', 'u64', None, 'proglist')
add('list_uint16_123', 'l123_u16', 'u16', 123, 'list')
add('list_uint16_128', 'l128_u16', 'u16', 128, 'list')
add('list_uint16_1024', 'l1024_u16', 'u16', 1024, 'list')
add('Fulu_list_uint64_128', 'l128_u64', 'u64', 128, 'list')
add('Fulu_list_uint64_131072', 'l131072_u64', 'u64', 131072, 'list')
add('Fulu_list_uint64_1099511627776', 'l1099511627776_u64', 'u64', 2 ** 40, 'list')
add('Fulu_list_uint8_1099511627776', 'l1099511627776_u8', 'u8', 2 ** 40, 'list')
add('bytelist_256', 'bl256', 'u8', 256, 'bytelist')
add('Fulu_bytelist_32', 'bl32', 'u8', 32, 'bytelist')
add('FuluTransaction', 'bl1073741824', 'u8', 2 ** 30, 'bytelist')
for k, kind in (('uint8', 'u8'), ('uint16', 'u16'), ('uint32', 'u32'), ('uint64', 'u64')):
    for n in (1, 2, 3, 4, 5, 8, 16, 31, 512, 513):
        add('vec_%s_%d' % (k, n), 'v%d_%s' % (n, kind), kind, None, 'vector', n)
for n in (1, 2, 3, 4, 5, 8, 16, 31, 512, 513):
    add('vec_bool_%d' % n, 'v%d_bool' % n, 'bool', None, 'vector', n)
add('Fulu_vec_uint64_64', 'v64_u64', 'u64', None, 'vector', 64)
add('Fulu_vec_uint64_8192', 'v8192_u64', 'u64', None, 'vector', 8192)
add('proglist_uint128', 'pl_u128', 'u128', None, 'proglist')
add('proglist_uint256', 'pl_u256', 'u256', None, 'proglist')
add('Fulu_list_bytevec_32_16777216', 'l16777216_b32', 'b32', 16777216, 'list')
add('Fulu_list_bytevec_48_4096', 'l4096_b48', 'b48', 4096, 'list')
add('Fulu_list_bytevec_2048_4096', 'l4096_b2048', 'cell', 4096, 'list')
for n, f in ((17, 'b32'), (33, 'b32'), (65536, 'b32'), (8192, 'b32')):
    add('Fulu_vec_bytevec_32_%d' % n, 'v%d_b32' % n, 'b32', None, 'vector', n)
add('Fulu_vec_bytevec_48_512', 'v512_b48', 'b48', None, 'vector', 512)

VAL = {'u8': 'U32.shrn(x, 24n)', 'u16': 'U32.shrn(x, 16n)', 'u32': 'x', 'bool': 'U32.is_eq(U32.shrn(x, 31n), 1)', 'bit': 'U32.is_eq(U32.shrn(x, 31n), 1)',
       'u64': 'O.U64{x, nx(x)}'}


def _nx(k, e='x'):
    for _ in range(k):
        e = 'nx(%s)' % e
    return e


def _words(k):
    return ', '.join(_nx(j) if j else 'x' for j in range(k))


VAL.update({'u128': 'Bt.Uint128{%s}' % _words(4), 'u256': 'Bt.Uint256{%s}' % _words(8), 'b32': 'Bt.Bytes32{%s}' % _words(8),
            'b48': 'Bt.Bytes48{%s}' % _words(12), 'cell': 'O.words_setw(O.words_setw(O.words_new(2048), 0, x), 511, nx(x))'})
STEP = {'u64': 'nx(nx(x))', 'u128': _nx(4), 'u256': _nx(8), 'b32': _nx(8), 'b48': _nx(12), 'cell': 'nx(nx(x))'}
NWORDS = {'u128': 4, 'u256': 8, 'b32': 8, 'b48': 12}

PROG = '''import Base
import ../../../src/buffer.bend as B
import ../../../src/digest.bend as D
import ../../../src/obj.bend as O
import ../../../types/%(file)s_def_generated.bend as Dd
import ../../../types/%(file)s_hashtreeroot_generated.bend as Hh
import ../../../types/%(file)s_encode_ssz_generated.bend as Ee
%(ELIMP)s
import ../../../benchmarks/compact/objio.bend as IOx

# GENERATED by tools/crash_hunt/gen_packed_diff.py (round-3 crash hunt, differential test of %(file)s)

def nx(+x: U32) -> U32: (x * 1664525 + 1013904223 : U32)

def cs_go(+k: Nat, +i: U32, +acc: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k:
    case 0n:
      (b, +w) = pair
      (b, (acc * 31 + w : U32))
    case 1n+q:
      (b, +w) = pair
      cs_go(q, (i + 1 : U32), (acc * 31 + w : U32), B.word(b, (i + 1 : U32)))

def cs_fin(pair: B.Buf & U32) -> U32:
  (b, +x) = pair
  x

def cs_pick(zero: Bool, b: B.Buf, +words: U32) -> B.Buf & U32:
  match zero:
    case True{}: (b, 7)
    case False{}: cs_go(U32.to_nat((words - 1 : U32)), 0, 7, B.word(b, 0))

def csum(b: B.Buf, +words: U32) -> U32: cs_fin(cs_pick(U32.is_eq(words, 0), b, words))

def ser_line2(ok: Bool, pair: B.Buf & U32) -> String:
  (b, +n) = pair
  " ser_ok=" ++ O.pick_str(ok) ++ " ser_sz=" ++ U32.show(n) ++ " ser_cs=" ++ U32.show(csum(b, U32.shrn((n + 3 : U32), 2n)))

def ser_line(e: O.Encoded) -> String:
  match e:
    case O.Encoded{ok, b}: ser_line2(ok, B.size(b))

%(SERDEF)s

# ---- the builders: self-recursive over the previous step's result ------------------------------------------------------------
def app_loop(+k: Nat, +x: U32, st: %(OT)s & Bool) -> %(OT)s & U32:
  match k st:
    case 0n Tuple{o, ok}: (o, x)
    case 1n+q Tuple{o, ok}: app_loop(q, %(STEP)s, Dd.%(P)s_append(o, %(VAL)s))

def set_loop(+k: Nat, +x: U32, +len: U32, st: %(OT)s & Bool) -> %(OT)s & U32:
  match k st:
    case 0n Tuple{o, ok}: (o, x)
    case 1n+q Tuple{o, ok}: set_loop(q, %(STEP)s, len, Dd.%(P)s_set(o, U32.mod(U32.shrn(x, 4n), len), %(VAL)s))

# ---- the report ---------------------------------------------------------------------------------------------------------------
def g6(+n: U32, line: String, pair: B.Buf & (%(OT)s & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  gser(n, line ++ " root=" ++ IOx.words(d), o)

def g5(+n: U32, line: String, pair: %(OT)s & Bool) -> IO(Unit):
  (o, ok) = pair
  g6(n, line ++ " valid=" ++ O.pick_str(ok), Hh.%(P)s_root(64n, O.hasher(), o, 0))

def g4(+n: U32, line: String, pair: %(OT)s & U32) -> IO(Unit):
  (o, +x2) = pair
  g5(n, line, Ee.%(P)s_valid(o))

def g3(+n: U32, +sets: U32, over: String, +x: U32, pair: %(OT)s & U32) -> IO(Unit):
  (o, +len) = pair
  g4(n, "n=" ++ U32.show(n) ++ over ++ " len=" ++ U32.show(len), set_loop(U32.to_nat(O.pick(U32.is_eq(len, 0), 0, sets)), x, %(LENEXPR)s, (o, True{})))

def over_str(+ov: U32, ok: Bool) -> String:
  match ov:
    case 0: ""
    case _: " over_ok=" ++ O.pick_str(ok)

def g2(+n: U32, +sets: U32, +ov: U32, +x: U32, pair: %(OT)s & Bool) -> IO(Unit):
  (o, ok) = pair
  g3(n, sets, over_str(ov, ok), x, Dd.%(P)s_len(o))

def maybe_over(+ov: U32, +x: U32, o: %(OT)s) -> %(OT)s & Bool:
  match ov:
    case 0: (o, True{})
    case _: Dd.%(P)s_append(o, %(VAL)s)

def g1(+n: U32, +sets: U32, +ov: U32, pair: %(OT)s & U32) -> IO(Unit):
  (o, +x) = pair
  g2(n, sets, ov, x, maybe_over(ov, x, o))

def go(+n: U32, +sets: U32, +seed: U32, +ov: U32) -> IO(Unit): %(GO)s

def main() -> IO(Unit):
  do IO<Unit>:
    +n : U32 <- IOx.env_u32("SSZ_N")
    +sets : U32 <- IOx.env_u32("SSZ_SETS")
    +seed : U32 <- IOx.env_u32("SSZ_SEED")
    +ov : U32 <- IOx.env_u32("SSZ_OVER")
    go(n, sets, seed, ov)
'''


def ser_info(repo, file):
    enc = open(os.path.join(repo, 'types', file + '_encode_ssz_generated.bend')).read()
    m = re.search(r'^def (\w+)_serialize\((\+?)o: ([^)]*)\) -> (.*?)(?::\s|$)', enc, re.M)
    if not m:
        return None
    ret = m.group(4).strip()
    return (m.group(1) + '_serialize', ret != 'O.Encoded' and '&' in ret, m.group(2) == '+')


def render(repo, s):
    ot = 'O.Bits' if s['kind'] == 'bit' else 'O.Words'
    P = s['prefix']
    si = ser_info(repo, s['file'])
    if si:
        name, pair, plus = si
        if pair:
            serdef = ('def gser2(+n: U32, line: String, pair: %s & O.Encoded) -> IO(Unit):\n  (o, e) = pair\n  IO.print(line ++ ser_line(e))\n\n'
                      'def gser(+n: U32, line: String, o: %s) -> IO(Unit): gser2(n, line, Ee.%s(o))' % (ot, ot, name))
        else:
            serdef = 'def gser(+n: U32, line: String, o: %s) -> IO(Unit): IO.print(line ++ ser_line(Ee.%s(o)))' % (ot, name)
    else:
        serdef = 'def gser(+n: U32, line: String, o: %s) -> IO(Unit): IO.print(line)' % ot
    if s['shape'] == 'vector':
        go = 'g1(n, sets, ov, vec_sets(sets, seed, Dd.%s_default()))' % P
        extra = ('def vec_loop(+k: Nat, +x: U32, st: %s & Bool) -> %s & U32:\n  match k st:\n    case 0n Tuple{o, ok}: (o, x)\n'
                 '    case 1n+q Tuple{o, ok}: vec_loop(q, %s, Dd.%s_set(o, U32.mod(U32.shrn(x, 4n), %d), %s))\n\n'
                 'def vec_sets(+sets: U32, +seed: U32, o: %s) -> %s & U32: vec_loop(U32.to_nat(sets), seed, (o, True{}))\n') % (
                     ot, ot, STEP.get(s['kind'], 'nx(x)'), P, s['vn'], VAL[s['kind']], ot, ot)
        text = PROG % dict(file=s['file'], ELIMP=EL.get(s['kind'], ''), OT=ot, P=P, VAL=VAL[s['kind']], STEP=STEP.get(s['kind'], 'nx(x)'), SERDEF=serdef, SERCALL='""', GO=go,
                           LENEXPR='len')
        # vectors: no append; the report path reuses g1 with the over flag forced off by the caller (SSZ_OVER=0)
        text = text.replace('# ---- the report', extra + '\n# ---- the report')
        text = text.replace('Dd.%s_append(o, %s)' % (P, VAL[s['kind']]), '(o, True{})')
        text = text.replace('Dd.%s_len(o)' % P, 'Dd.%s_len(o)' % P)
        text = text.replace('set_loop(U32.to_nat(O.pick(U32.is_eq(len, 0), 0, sets)), x, len, (o, True{}))', '(o, x)')
        return text
    go = 'g1(n, sets, ov, app_loop(U32.to_nat(n), seed, (Dd.%s_default(), True{})))' % P
    return PROG % dict(file=s['file'], ELIMP=EL.get(s['kind'], ''), OT=ot, P=P, VAL=VAL[s['kind']], STEP=STEP.get(s['kind'], 'nx(x)'), SERDEF=serdef, SERCALL='""', GO=go, LENEXPR='len')


def cs(b):
    b = b + b'\0' * (-len(b) % 4)
    acc = 7
    for i in range(0, len(b), 4):
        acc = (acc * 31 + int.from_bytes(b[i:i + 4], 'little')) & M32
    return acc


def ref_type(s):
    k, sh = s['kind'], s['shape']
    el = ('bool',) if k == 'bool' else (('uint', 128) if k == 'u128' else ('uint', 256) if k == 'u256' else ('bytes', {'b32': 32, 'b48': 48, 'cell': 2048}[k]) if k in ('b32', 'b48', 'cell') else ('uint', BITS.get(k, 8)))
    if sh == 'list':
        return ('list', el, s['limit'])
    if sh == 'proglist':
        return ('proglist', el)
    if sh == 'bitlist':
        return ('bitlist', s['limit'])
    if sh == 'progbits':
        return ('progbits',)
    if sh == 'bytelist':
        return ('bytelist', s['limit'])
    return ('vector', el, s['vn'])


def value_of(s, x):
    k = s['kind']
    if k == 'u8':
        return x >> 24
    if k == 'u16':
        return x >> 16
    if k == 'u32':
        return x
    if k == 'u64':
        return x | (nx(x) << 32)
    if k in NWORDS:
        out, y = b'', x
        for _ in range(NWORDS[k]):
            out += y.to_bytes(4, 'little')
            y = nx(y)
        return out
    if k == 'cell':
        c = bytearray(2048)
        c[0:4] = x.to_bytes(4, 'little')
        c[2044:2048] = nx(x).to_bytes(4, 'little')
        return bytes(c)
    return (x >> 31) == 1


def step(s, x):
    k = s['kind']
    n = 2 if k in ('u64', 'cell') else NWORDS.get(k, 1)
    for _ in range(n):
        x = nx(x)
    return x


def expected(S, s, n, sets, seed, over):
    t = ref_type(s)
    lim = s['limit']
    if s['shape'] == 'vector':
        z = {'bool': False, 'b32': bytes(32), 'b48': bytes(48), 'cell': bytes(2048)}.get(s['kind'], 0)
        vals = [z] * s['vn']
        x = seed
        for _ in range(sets):
            vals[(x >> 4) % s['vn']] = value_of(s, x)
            x = step(s, x)
        over_ok = None
    else:
        vals, x = [], seed
        for _ in range(n):
            if lim is None or len(vals) < lim:
                vals.append(value_of(s, x))
            x = step(s, x)
        over_ok = None
        if over:
            over_ok = lim is None or len(vals) < lim
            if over_ok:
                vals.append(value_of(s, x))
        if vals:
            for _ in range(sets):
                vals[(x >> 4) % len(vals)] = value_of(s, x)
                x = step(s, x)
    if s['kind'] in ('u128', 'u256'):
        vals = [int.from_bytes(b, 'little') for b in vals]
    v = bytes(vals) if s['shape'] == 'bytelist' else vals
    root = S.hash_tree_root(t, v)
    ser = S.serialize(t, v)
    return len(vals), over_ok, root, ser


def scenarios(s):
    out = []
    if s['shape'] == 'vector':
        for sets in (0, 1, 3, 40):
            for seed in (1, 12345):
                out.append((0, sets, seed, 0))
        return out
    lim = s['limit']
    ns = {0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17, 31, 32, 33, 63, 64, 65, 127, 128, 129, 255, 256, 257, 1000, 1023, 1024, 1025}
    if lim is None:
        ns |= {4095, 4096, 4097, 20000, 65536}
        # progressive trees change shape at 1, 5, 21, 85, 341, 1365 chunks: test the chunk counts around each boundary
        epc = {'u8': 32, 'bool': 32, 'u16': 16, 'u32': 8, 'u64': 4, 'u128': 2, 'u256': 1, 'bit': 256}.get(s['kind'], 1)
        for c in (1, 2, 4, 5, 6, 20, 21, 22, 84, 85, 86, 340, 341, 342, 1364, 1365, 1366):
            for d in (0, 1):
                if c * epc + d <= 400000:
                    ns.add(c * epc + d)
            if epc > 1:
                ns.add(c * epc - 1)
    else:
        for d in (-2, -1, 0, 1, 2):
            if 0 <= lim + d <= 140000:
                ns.add(lim + d)
        ns = {n for n in ns if n <= max(lim + 2, 4)}
        if lim <= 140000:
            ns.add(lim)
    res = []
    for n in sorted(ns):
        for over in (0, 1):
            for sets in ((0, 7) if n % 3 == 0 or n < 40 else (0,)):
                res.append((n, sets, 99 + n, over))
    return res


def run_one(prog, case):
    n, sets, seed, over = case
    env = {**os.environ, 'SSZ_N': str(n), 'SSZ_SETS': str(sets), 'SSZ_SEED': str(seed), 'SSZ_OVER': str(over)}
    try:
        r = subprocess.run(['nice', '-n', '19', prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=120)
        return r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return 'timeout', '', ''


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('mode', choices=['gen', 'run'])
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs')
    ap.add_argument('--out', required=True)
    ap.add_argument('--only', default='')
    ap.add_argument('--jobs', type=int, default=3)
    a = ap.parse_args()
    only = [x for x in a.only.split(',') if x]
    specs = [s for s in SPECS if not only or s['id'] in only]
    if a.mode == 'gen':
        os.makedirs(a.out, exist_ok=True)
        for s in specs:
            open(os.path.join(a.out, 'pd_%s.bend' % s['id']), 'w').write(render(a.repo, s))
        print('generated', len(specs))
        return
    import ssz_ref as S
    tally = collections.Counter()
    findings = []

    def work(s):
        prog = os.path.join(a.repo, 'build', 'ch', 'pd_' + s['id'])
        res = []
        for case in scenarios(s):
            rc, so, se = run_one(prog, case)
            res.append((case, rc, so, se))
        return s, res
    with ThreadPoolExecutor(a.jobs) as ex:
        for s, res in ex.map(work, specs):
            bad = 0
            for case, rc, so, se in res:
                n, sets, seed, over = case
                exp_len, exp_over, root, ser = expected(S, s, n, sets, seed, over)
                line = so.strip().splitlines()[-1] if so.strip() else ''
                if rc != 0 or not line.startswith('n='):
                    tally['CRASH'] += 1
                    findings.append({'class': 'CRASH', 'id': s['id'], 'case': case, 'rc': rc, 'err': se[-200:]})
                    bad += 1
                    continue
                kv = dict(p.split('=', 1) for p in line.split())
                probs = []
                eroot = ','.join(str(int.from_bytes(root[i:i + 4], 'big')) for i in range(0, 32, 4))
                if kv.get('valid') != '1':
                    probs.append('valid=%s' % kv.get('valid'))
                if kv.get('root') != eroot:
                    probs.append('root differs')
                if s['shape'] != 'vector' and kv.get('len') != str(exp_len):
                    probs.append('len %s expected %s' % (kv.get('len'), exp_len))
                if exp_over is not None and kv.get('over_ok') != ('1' if exp_over else '0'):
                    probs.append('over_ok %s expected %s' % (kv.get('over_ok'), exp_over))
                if 'ser_ok' in kv:
                    if kv['ser_ok'] != '1' or kv['ser_sz'] != str(len(ser)) or kv['ser_cs'] != str(cs(ser)):
                        probs.append('serialize differs (ok=%s sz=%s expected %d)' % (kv['ser_ok'], kv['ser_sz'], len(ser)))
                if probs:
                    tally['WRONG'] += 1
                    bad += 1
                    findings.append({'class': 'WRONG', 'id': s['id'], 'case': case, 'why': probs, 'line': line[:200]})
                else:
                    tally['OK'] += 1
            print(s['id'], 'cases', len(res), 'bad', bad, flush=True)
    os.makedirs(a.out, exist_ok=True)
    json.dump({'tally': dict(tally), 'findings': findings[:300]}, open(os.path.join(a.out, 'packed_diff.json'), 'w'), indent=1)
    print('FINAL', dict(tally))


if __name__ == '__main__':
    main()
