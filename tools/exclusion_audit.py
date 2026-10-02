#!/usr/bin/env python3
"""Independent audit of the proof-equivalent exclusions of tests_generated/mutation_exclusions.json.

    python3 tools/exclusion_audit.py structural [--json OUT]     re-derive every rule over EVERY site the entry key matches
    python3 tools/exclusion_audit.py laws-unread types            Bend laws original == mutant for the unread-argument rule (45 laws)
    python3 tools/exclusion_audit.py laws-boolvec                 Bend laws for the vec_bool rule (private mutant modules in types/_audit_*)
    python3 tools/exclusion_audit.py laws-misc proofs             the bits_ok / words_ok(big) laws and the Transaction kill law
    python3 tools/exclusion_audit.py poison                       which serialize defs reach each pk_ok flag, fixed or computed length
    python3 tools/exclusion_audit.py diff-poison DIR              cases.json for the differential run
    python3 tools/exclusion_audit.py run-diff DIR/cases.json      serialize(default) original vs flag 0 -> 1 (runs bend, server only)
(the words_ok rule's runtime differential is described in docs/mutation_testing/EXCLUSION_AUDIT.md)

Run from the repository root (a private tree; never the Mac). Nothing here shares code with
tests_generated/mutation_equivalence.py: the call parser, the callee resolution (through the file's import
aliases, not by bare name), the comment stripping and the words_ok set comparison are written again.

An exclusion entry is keyed by (file, def, operator, before, after, line text), so it hides EVERY site of the
line with that operator and text, not the one the rule looked at. This tool therefore enumerates all sites a key
matches (the generator's own sites()) and checks each one.
"""
import collections, json, pathlib, re, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / 'tests_generated'))
import mutation_testing as MT  # sites(), def_name(): the same site enumeration the draws use

ROOT = pathlib.Path('.')
EXCL = json.loads((ROOT / 'tests_generated/mutation_exclusions.json').read_text())['entries']


def rule_of(e):
    r = e['reason']
    if e['class'] == 'uncoverable': return 'uncoverable'
    if r.startswith('argument never read'): return 'unread-arg'
    if r.startswith('the flag is only read'): return 'poison-flag'
    if r.startswith('words_ok'): return 'words_ok'
    if r.startswith('bits_ok'): return 'bits_ok'
    if 'ok_n' in r: return 'boolvec'
    return 'other'


def strip_comments(t):
    return '\n'.join(l.split('#', 1)[0] for l in t.split('\n'))


def aliases(text):
    return {m.group(2): m.group(1) for m in re.finditer(r'^import\s+(\S+)\s+as\s+(\w+)\s*$', text, re.M)}


def defs_of(text):
    """{name: (params_text, body_text)} by top-level `def name(...)`: the body runs to the next unindented line that
    starts a def/type/import (a def's continuation lines are indented). Parenthesis-balanced parameter list."""
    out, lines, i = {}, text.split('\n'), 0
    while i < len(lines):
        m = re.match(r'def (\w+)\(', lines[i])
        if m:
            j = i; s = '\n'.join(lines[i:])
            k = m.end(); d = 1
            while d and k < len(s):
                d += (s[k] == '(') - (s[k] == ')'); k += 1
            params = s[m.end():k - 1]
            e = i + 1
            while e < len(lines) and (lines[e].startswith((' ', '\t')) or lines[e].strip() == '' or lines[e].startswith('#')):
                e += 1
            out.setdefault(m.group(1), []).append((params, '\n'.join(lines[i:e])))
            i = e
        else:
            i += 1
    return out


def split_top(s):
    out, d, cur = [], 0, ''
    for c in s:
        if c in '([{<': d += 1
        if c in ')]}>': d -= 1
        if c == ',' and d == 0: out.append(cur); cur = ''
        else: cur += c
    out.append(cur); return out


def call_at(line, col):
    """the innermost call `head(args)` whose argument list contains column col: (head, [arg spans])"""
    best = None
    for m in re.finditer(r'((?:\w+\.)*\w+)\(', line):
        a = m.end(); d = 1; j = a
        while j < len(line) and d:
            d += (line[j] == '(') - (line[j] == ')'); j += 1
        if d or not (a <= col < j - 1): continue
        spans, st, dd = [], a, 0
        for i in range(a, j - 1):
            c = line[i]
            if c in '([{<': dd += 1
            elif c in ')]}>': dd -= 1
            elif c == ',' and dd == 0: spans.append((st, i)); st = i + 1
        spans.append((st, j - 1))
        if best is None or (j - a) < best[2]: best = (m.group(1), spans, j - a)
    return best


_cache = {}
def module(path):
    p = pathlib.Path(path)
    if p not in _cache:
        t = p.read_text(); _cache[p] = (t, aliases(t), defs_of(strip_comments(t)))
    return _cache[p]


def resolve(file, head):
    """(file, name) of a call head `alias.name` or local `name`; None if not found"""
    t, al, ds = module(file)
    if '.' in head:
        a, n = head.rsplit('.', 1)
        if a not in al: return None
        tgt = (pathlib.Path(file).parent / al[a]).resolve().relative_to(pathlib.Path('.').resolve())
        return str(tgt), n
    return file, head


def entry_sites(e):
    """every (line index, col) the key of entry e matches in its file"""
    text = pathlib.Path(e['file']).read_text(); lines = text.split('\n'); out = []
    for (i, col, op, b, a) in MT.sites(text):
        if op == e['operator'] and b == e['before'] and a == e['after'] and MT.def_name(text, i) == e['def'] and lines[i].strip()[:200] == e['text']:
            out.append((i, col))
    return out


def check_unread(e, i, col):
    line = pathlib.Path(e['file']).read_text().split('\n')[i]
    c = call_at(line, col)
    if not c: return 'FAIL', 'site is not inside a call'
    head, spans, _ = c
    idx = [k for k, (a, b) in enumerate(spans) if a <= col < b]
    if len(idx) != 1: return 'FAIL', 'argument not found'
    a, b = spans[idx[0]]
    if line[a:b].strip() != e['before']: return 'FAIL', 'the mutated literal is not the whole argument (%r)' % line[a:b].strip()
    r = resolve(e['file'], head)
    if not r: return 'FAIL', 'callee %s not resolved' % head
    f, n = r
    if not pathlib.Path(f).exists(): return 'FAIL', 'callee file %s missing' % f
    ds = module(f)[2].get(n)
    if not ds: return 'FAIL', 'def %s not in %s' % (n, f)
    if len(ds) != 1: return 'FAIL', 'def %s defined %d times' % (n, len(ds))
    params, body = ds[0]
    ps = split_top(params)
    if idx[0] >= len(ps): return 'FAIL', 'arity'
    pn = re.sub(r'^[+\-]', '', ps[idx[0]].split(':')[0].strip())
    head_end = body.split('\n', 1)
    rest = body[body.index(')') :] if False else body
    # the parameter must not occur in the body after the signature (the signature holds its declaration)
    sig_end = 0; d = 0
    for k, ch in enumerate(body):
        if ch == '(': d += 1
        if ch == ')':
            d -= 1
            if d == 0: sig_end = k; break
    tail = body[sig_end + 1:]
    tail = re.sub(r'^\s*->[^:\n]*', '', tail, count=1) if False else tail
    # drop the return type text up to the first ':' at depth 0 following '->'
    m = re.match(r'\s*->(.*?):(?=\s|$)', tail, re.S)
    code = tail[m.end():] if m else tail
    if re.search(r'(?<![\w.])' + re.escape(pn) + r'(?![\w])', code): return 'READ', '%s.%s reads %s' % (f, n, pn)
    return 'OK', '%s.%s never reads %s' % (f, n, pn)


U32MAX = (1 << 32) - 1


def acc_set(lo, hi, big, unit):
    """the accepted byte lengths n in [0, 2^32) of O.words_ok's length test as (first, last, step, count) or None if empty:
    lo <= n, (big or n <= hi), unit | n. unit_ok (src/obj.bend) is a mask for 1,2,4,8,32 and U32.mod otherwise: unit | n."""
    if unit <= 0: return 'unit0'
    top = U32MAX if big else min(hi, U32MAX)
    first = -(-lo // unit) * unit; last = (top // unit) * unit
    if first > last: return None
    return (first, last, unit, (last - first) // unit + 1)


def same_set(A, B):
    if A == 'unit0' or B == 'unit0': return False
    if A is None or B is None: return A is B
    if A[0] != B[0] or A[1] != B[1]: return False
    return A[3] == 1 or A[2] == B[2]


def witness(A, B):
    """an n in exactly one of the two sets"""
    def mem(S, n): return S not in (None, 'unit0') and S[0] <= n <= S[1] and (n - S[0]) % S[2] == 0
    cand = set()
    for S in (A, B):
        if S not in (None, 'unit0'): cand |= {S[0], S[1], S[0] + S[2], S[0] - 1, S[1] + 1}
    for n in sorted(cand):
        if 0 <= n <= U32MAX and mem(A, n) != mem(B, n): return n
    for n in range(0, 4096):
        if mem(A, n) != mem(B, n): return n


def check_words(e, i, col):
    line = pathlib.Path(e['file']).read_text().split('\n')[i]
    c = call_at(line, col)
    if not c or c[0] != 'O.words_ok': return 'UNPROVEN', 'site is not an argument of O.words_ok (innermost call %s)' % (c[0] if c else None), None
    head, spans, _ = c
    args = [line[a:b].strip() for a, b in spans]
    idx = [k for k, (a, b) in enumerate(spans) if a <= col < b][0]
    if len(args) != 5 or args[idx] != e['before']: return 'UNPROVEN', 'argument is not the bare literal', None
    try: lo, hi, unit = (int(args[1]), int(args[2]), int(args[4]))
    except ValueError: return 'UNPROVEN', 'non-literal bounds', None
    big = args[3] == 'True{}'
    new = list((lo, hi, unit)); k = {1: 0, 2: 1, 4: 2}.get(idx)
    if k is None: return 'UNPROVEN', 'argument %d (o or big) is not a numeric bound' % idx, None
    new[k] = int(e['after'])
    A = acc_set(lo, hi, big, unit); B = acc_set(new[0], new[1], big, new[2])
    if same_set(A, B): return 'EQUIVALENT', 'words_ok(%s) accepts the same lengths as words_ok(%s)' % (args[1:], new), None
    return 'DIFFERS', 'arg %d (%s) %s -> %s: accepted lengths differ' % (idx, ['o', 'lo', 'hi', 'big', 'unit'][idx], e['before'], e['after']), witness(A, B)


def check_bits(e, i, col):
    line = pathlib.Path(e['file']).read_text().split('\n')[i]
    c = call_at(line, col)
    if not c or c[0] != 'O.bits_ok': return 'UNPROVEN', 'not an O.bits_ok argument', None
    args = [line[a:b].strip() for a, b in c[1]]
    if len(args) == 3 and args[1] == e['before'] and args[2] == 'True{}':
        t = pathlib.Path('src/obj.bend').read_text()
        m = re.search(r'def bits_ok\(.*?\n(?=\n|def )', t, re.S)
        if m and 'Bool.or(big, U32.is_le(k, limit))' in m.group(0) and m.group(0).count('limit') == 2:
            return 'EQUIVALENT', 'bits_ok reads `limit` only in Bool.or(big, is_le(k, limit)); big = True{} makes the or True{} for every k', None
    return 'UNPROVEN', 'shape', None


def repo_text():
    out = {}
    for d in ('types', 'src', 'proofs', 'e2e', 'spec', 'benchmarks', 'tests_generated'):
        for f in pathlib.Path(d).rglob('*.bend'): out[str(f)] = f.read_text()
    for f in pathlib.Path('.').glob('*.bend'): out[str(f)] = f.read_text()
    return out


def check_boolvec(e, i, col, R):
    """vec_bool decoders. ok_nz(empty, buf, off, n) <- ok_n(buf, off, n) = ok_nz(is_eq(n, 0), ..) <- ok_at = ok_n(buf, off, N) with N literal.
    Every name is looked up in the WHOLE repo: any other mention (a proof, another module) breaks the argument."""
    f = e['file']; t = R[f]
    m = re.match(r'(\w+)_ok_n(z?)$', e['def'])
    if not m: return 'UNPROVEN', 'def name'
    pre = m.group(1)
    N = re.search(re.escape(pre) + r'_ok_n\(buf, off, (\d+)\)', t)
    if not N: return 'UNPROVEN', 'no literal caller'
    N = int(N.group(1))
    refs = {nm: [(g, ln) for g, tx in R.items() if (nm + '(') in tx for ln, l in enumerate(tx.split('\n')) if (nm + '(') in l and re.search(r'(?<![\w])' + re.escape(nm) + r'\(', l.split('#')[0]) and not l.startswith('def ' + nm)]
            for nm in (pre + '_ok_nz', pre + '_ok_n', pre + '_ok_at')}
    n_nz = refs[pre + '_ok_nz']; n_n = refs[pre + '_ok_n']
    where = lambda r: [(g, ln + 1) for g, ln in r]
    if [g for g, _ in n_nz] != [f] or [g for g, _ in n_n] != [f]:
        # callers by qualified name in other files
        return 'UNPROVEN', 'other callers: nz=%s n=%s' % (where(n_nz), where(n_n))
    # the mutated operator
    if N < 1: return 'UNPROVEN', 'N = %d' % N
    # sites: for 'valid' the key also covers `case True{}` (the pattern); both reported by the caller
    line = t.split('\n')[i]
    if e['operator'] == 'valid':
        if col == line.index('case True{}') + 5:
            return 'INVALID?', 'the pattern of a case: `case False{}` duplicates the next case (the compiler rejects or the branch is dead)'
        return 'EQUIVALENT', 'the True{} branch of ok_nz is reached only when is_eq(n, 0) with n = %d (the only chain: ok_at -> ok_n -> ok_nz, no other mention in the repo)' % N
    if e['operator'] in ('cmp', 'const+1'):
        if 'is_eq(n, 0)' not in line: return 'UNPROVEN', 'shape'
        return 'EQUIVALENT', 'ok_n is called only by ok_at with n = %d: is_lt(%d, 0) = is_eq(%d, 0) = False{} (and is_eq(%d, 1) = False{} for %d != 1)' % (N, N, N, N, N), None
    return 'UNPROVEN', 'operator'


B1_LAWS = '''import Base
import ../src/buffer.bend as B
import ../src/digest.bend as D
import ../src/merkle_fast.bend as M
import ../src/obj.bend as O
import ./FuluBytes1_def_generated.bend as FuluBytes1_d
import ./FuluBytes1_hashtreeroot_generated.bend as AUD

def law_b1_root_0_64n_63n(h: B.Buf, +w0: U32, +seg: U32) -> {AUD.b1_root(64n, h, FuluBytes1_d.Bytes1{w0}, seg) == AUD.b1_root(63n, h, FuluBytes1_d.Bytes1{w0}, seg) : B.Buf & D.Digest}: {==}

def law_b1_root_0_64n_65n(h: B.Buf, +w0: U32, +seg: U32) -> {AUD.b1_root(64n, h, FuluBytes1_d.Bytes1{w0}, seg) == AUD.b1_root(65n, h, FuluBytes1_d.Bytes1{w0}, seg) : B.Buf & D.Digest}: {==}

def law_b1_root_3_0_1(+hl: Nat, h: B.Buf, +w0: U32) -> {AUD.b1_root(hl, h, FuluBytes1_d.Bytes1{w0}, 0) == AUD.b1_root(hl, h, FuluBytes1_d.Bytes1{w0}, 1) : B.Buf & D.Digest}: {==}
'''


MISC_LAWS = {
'_audit_bits.bend': '''import Base
import ../src/obj.bend as O

def bits_limit_inert(o: O.Bits) -> {O.bits_ok(o, 0, True{}) == O.bits_ok(o, 1, True{}) : O.Bits & Bool}:
  match o:
    case O.Bits{ws, +k}: {==}

def words_hi_inert_big(o: O.Words) -> {O.words_ok(o, 0, 0, True{}, 4) == O.words_ok(o, 0, 1, True{}, 4) : O.Words & Bool}:
  match o:
    case O.Words{ws, +n}: {==}
''',
# the Transaction bound: this law CHECKS for the original (TX = the real module) and FAILS for a copy with 1073741825 (mutant):
# a proof-level kill of a mutant classed 'uncoverable'
'_audit_tx.bend': '''import Base
import ../src/obj.bend as O
import ../types/FuluTransaction_encode_ssz_generated.bend as TX

def snd(p: O.Words & Bool) -> Bool:
  (o, b) = p
  b

def l_last(+n: U32, p: Array<U32> & U32) -> {snd(O.wk_last(False{}, n, p)) == False{} : Bool}:
  match p:
    case Tuple{ws, +x}: {==}

def l_cap(+n: U32, p: Array<U32> & U32) -> {snd(O.wk_cap(False{}, n, p)) == False{} : Bool}:
  match p:
    case Tuple{ws, +c}: l_last(n, Array.get(U32, ws, U32.shrn(n, 2n)))

def tx_valid_refuses_2p30_plus_1(ws: Array<U32>) -> {snd(TX.bl1073741824_valid(O.Words{ws, 1073741825})) == False{} : Bool}:
  l_cap(1073741825, Array.size(U32, ws))
''',
}


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'structural'
    if cmd == 'structural':
        R = repo_text()
        tally = collections.defaultdict(collections.Counter); hidden = []; multi = 0; noeq = []
        for e in EXCL:
            rl = rule_of(e); sites = entry_sites(e); eqn = 0
            if len(sites) != 1: multi += 1
            for (i, col) in sites:
                wit = None
                if rl == 'unread-arg': v, why = check_unread(e, i, col)
                elif rl == 'words_ok': v, why, wit = check_words(e, i, col)
                elif rl == 'bits_ok': v, why, wit = check_bits(e, i, col)
                elif rl == 'boolvec': v, why = check_boolvec(e, i, col, R)[:2]
                elif rl == 'poison-flag': v, why = 'DEFERRED', 'consumer audit'
                else: v, why = 'DEFERRED', rl
                if v == 'OK': v = 'EQUIVALENT'
                eqn += v in ('EQUIVALENT', 'DEFERRED')
                tally[rl][v] += 1
                if v not in ('EQUIVALENT', 'DEFERRED'):
                    hidden.append({'rule': rl, 'file': e['file'], 'def': e['def'], 'line': i + 1, 'col': col, 'operator': e['operator'],
                                   'before': e['before'], 'after': e['after'], 'verdict': v, 'why': why, 'witness_n': wit})
            if not eqn: noeq.append((e['file'], e['def'], e['operator']))
        print(json.dumps({k: dict(v) for k, v in tally.items()}, indent=1)); print('entries whose key matches != 1 site:', multi, '; entries with no equivalent site:', len(noeq), noeq)
        out = pathlib.Path(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[2] == '--json' else None
        if out: out.write_text(json.dumps(hidden, indent=1))
        for h in hidden: print('HIDDEN', h['rule'], h['file'].split('/')[-1], h['line'], h['col'], h['operator'], h['before'], '->', h['after'], h['verdict'], '|', h['why'], h['witness_n'])
    elif cmd == 'migrate':
        # rewrite tests_generated/mutation_exclusions.json with one entry per EQUIVALENT site (column added); the sibling sites the old key hid are
        # dropped (they are drawn again), and so are the two entries this audit found unsound (ExecutionBranch flag, Transaction bound)
        R = repo_text(); new = []
        for e in EXCL:
            rl = rule_of(e)
            if rl == 'uncoverable' or (rl == 'poison-flag' and e['file'].endswith('FuluExecutionBranch_encode_ssz_generated.bend')): continue
            for (i, col) in entry_sites(e):
                if rl == 'unread-arg': v = check_unread(e, i, col)[0]
                elif rl == 'words_ok': v = check_words(e, i, col)[0]
                elif rl == 'bits_ok': v = check_bits(e, i, col)[0]
                elif rl == 'boolvec': v = check_boolvec(e, i, col, R)[0]
                else: v = 'EQUIVALENT'
                if v in ('OK', 'EQUIVALENT'):
                    ln = pathlib.Path(e['file']).read_text().split('\n')[i]
                    new.append({**{k: e[k] for k in ('file', 'def', 'operator', 'before', 'after', 'text')}, 'col': col - (len(ln) - len(ln.lstrip())),
                                'class': e['class'], 'reason': e['reason']})
        d = json.loads(pathlib.Path('tests_generated/mutation_exclusions.json').read_text())
        d['note'] = 'mutations that are never drawn and never reported (rules and reasons: tests_generated/mutation_equivalence.py; one entry per site: file, def, operator, literal, line text, column)'
        d['entries'] = sorted(new, key=lambda e: (e['class'], e['file'], e['text'], e['col']))
        pathlib.Path('tests_generated/mutation_exclusions.json').write_text(json.dumps(d, indent=1) + '\n')
        print(len(EXCL), '->', len(new))
    elif cmd == 'laws-misc':
        out = pathlib.Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
        for n, t in MISC_LAWS.items(): (out / n).write_text(t)
    elif cmd == 'laws-unread':
        # for each distinct (callee, parameter, before, after) of the unread-argument rule: a Bend law that the original and the
        # mutated call are EQUAL for all other arguments; written next to the callee (its import aliases resolve there)
        out = pathlib.Path(sys.argv[2]); seen = {}
        for e in EXCL:
            if rule_of(e) != 'unread-arg': continue
            for (i, col) in entry_sites(e):
                line = pathlib.Path(e['file']).read_text().split('\n')[i]
                c = call_at(line, col)
                if not c: continue
                head, spans, _ = c
                idx = [k for k, (a, b) in enumerate(spans) if a <= col < b]
                if len(idx) != 1 or line[spans[idx[0]][0]:spans[idx[0]][1]].strip() != e['before']: continue
                f, n = resolve(e['file'], head); seen.setdefault((f, n, idx[0], e['before'], e['after']), 0); seen[(f, n, idx[0], e['before'], e['after'])] += 1
        files = collections.defaultdict(list)
        for (f, n, k, b, a), cnt in sorted(seen.items()):
            params, body = module(f)[2][n][0]
            ps = [x.strip() for x in split_top(params)]
            m = re.match(r'def %s\(.*?\)\s*->\s*(.*?):' % re.escape(n), body, re.S)
            names = [re.sub(r'^[+\-]', '', x.split(':')[0].strip()) for x in ps]
            def call(v): return 'AUD.%s(%s)' % (n, ', '.join(v if j == k else names[j] for j in range(len(ps))))
            sig = ', '.join(x for j, x in enumerate(ps) if j != k)
            files[f].append((n, k, b, a, cnt, 'def law_%s_%d_%s_%s(%s) -> {%s == %s : %s}: {==}' % (n, k, b.replace('-', 'm'), a.replace('-', 'm'), sig, call(b), call(a), m.group(1))))
        out.mkdir(parents=True, exist_ok=True)
        for f, laws in files.items():
            t = module(f)[0]
            imps = [l for l in t.split('\n') if l.startswith('import ')]
            name = pathlib.Path(f).stem
            (out / ('_audit_unread_%s.bend' % name)).write_text('\n'.join(imps) + '\nimport ./%s as AUD\n\n' % pathlib.Path(f).name + '\n\n'.join(l[-1] for l in laws) + '\n')
        # b1_root matches on its (single-constructor) record argument, so with `o` a variable the kernel keeps the unused `+hl`/`+seg`
        # threaded through the stuck match and `{==}` fails; the same laws with `o = Bytes1{w0}` (the only constructor) hold.
        (out / '_audit_unread_FuluBytes1_hashtreeroot_generated.bend').write_text(B1_LAWS)
        print(len(seen), 'laws in', len(files), 'files;', sum(seen.values()), 'sites')
    elif cmd == 'poison':
        # the encoders of types/ as a call graph (qualified `alias.name(` and local `name(` references); for each excluded pk_ok def,
        # the *_serialize defs that reach it, and whether the serialize's final length is a literal (a fixed-size top level: the flag
        # reaches only O.is_poisoned) or a computed count m (the flag is OR-ed/added INTO the length)
        enc = {f: module(str(f)) for f in sorted(pathlib.Path('types').glob('*_encode_ssz_generated.bend'))}
        node = {}   # (file, def) -> set of (file, def)
        for f, (t, al, ds) in enc.items():
            fa = {a: str((pathlib.Path(f).parent / tgt).resolve().relative_to(pathlib.Path('.').resolve())) for a, tgt in al.items()}
            for n, lst in ds.items():
                body = lst[0][1]
                refs = set()
                for m in re.finditer(r'(?<![\w.])((?:\w+\.)?\w+)\(', body):
                    h = m.group(1)
                    if '.' in h:
                        a_, nm = h.split('.', 1)
                        if a_ in fa and fa[a_].endswith('_encode_ssz_generated.bend'): refs.add((fa[a_], nm))
                    elif h in ds: refs.add((str(f), h))
                node[(str(f), n)] = refs
        rev = collections.defaultdict(set)
        for k, vs in node.items():
            for v in vs: rev[v].add(k)
        out = []
        for e in EXCL:
            if rule_of(e) != 'poison-flag': continue
            start = (e['file'], e['def']); seen = {start}; todo = [start]
            while todo:
                for u in rev[todo.pop()]:
                    if u not in seen: seen.add(u); todo.append(u)
            sers = sorted(k for k in seen if re.search(r'_serialize$', k[1]))
            fin = []
            for (f, n) in sers:
                t = module(f)[0]
                m = re.search(r'ser_done\(O\.is_poisoned\((\w+)\), ([^,]+), out\)', t)
                fin.append((f.split('/')[-1], n, m.group(2).strip() if m else '?'))
            out.append((e['file'], e['def'], fin))
        for f, d, fin in out:
            lits = [x for x in fin if x[2].isdigit()]; var = [x for x in fin if not x[2].isdigit()]
            print('%-60s %-18s reaches %d serialize defs: fixed-length %d, count-length %s' % (f.split('/')[-1], d, len(fin), len(lits), [(x[0], x[2]) for x in var]))
    elif cmd == 'diff-poison':
        # differential run: serialize(default object) of the ORIGINAL encoders vs the encoders with the pk_ok flag 0 -> 1, per
        # excluded entry and per top-level serialize reaching it (the chain of files is copied as types/_audit_*.bend and rewired).
        # Prints one `entry|serialize|orig|mut` line per pair to the output directory's cases.json; the runner (shell) runs the mains.
        out = pathlib.Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
        enc = {str(f): module(str(f)) for f in sorted(pathlib.Path('types').glob('*_encode_ssz_generated.bend'))}
        node = {}
        for f, (t, al, ds) in enc.items():
            fa = {a: str((pathlib.Path(f).parent / tgt).resolve().relative_to(pathlib.Path('.').resolve())) for a, tgt in al.items()}
            for n, lst in ds.items():
                refs = set()
                for m in re.finditer(r'(?<![\w.])((?:\w+\.)?\w+)\(', lst[0][1]):
                    h = m.group(1)
                    if '.' in h:
                        a_, nm = h.split('.', 1)
                        if a_ in fa and fa[a_] in enc: refs.add((fa[a_], nm))
                    elif h in ds: refs.add((f, h))
                node[(f, n)] = refs
        rev = collections.defaultdict(set)
        for k, vs in node.items():
            for v in vs: rev[v].add(k)
        cases = []
        for e in EXCL:
            if rule_of(e) != 'poison-flag': continue
            start = (e['file'], e['def']); seen = {start}; todo = [start]
            while todo:
                for u in rev[todo.pop()]:
                    if u not in seen: seen.add(u); todo.append(u)
            for top in sorted(k for k in seen if k[1].endswith('_serialize')):
                chain = {k[0] for k in seen}   # every file with a def on a path to the flag (over-approximate: all are copied and rewired)
                cases.append({'entry': start, 'top': top, 'files': sorted(chain)})
        json.dump(cases, open(out / 'cases.json', 'w'), indent=1)
        print(len(cases), 'cases')
    elif cmd == 'run-diff':
        import subprocess
        cases = json.load(open(sys.argv[2]))
        T = '/srv/ssz-optimization/toolchain-memo-788a6866'
        env = dict(__import__('os').environ, BEND_NO_TELEMETRY='1', BEND_LIB='vendor/bendhub')
        def run(path):
            try: r = subprocess.run([T + '/bin/bend', path], capture_output=True, text=True, env=env, timeout=90)
            except subprocess.TimeoutExpired: return 'TIMEOUT'
            return (r.stdout + r.stderr).strip().split('\n')[-1][:100]
        res = []
        for c in cases:
            efile, edef = c['entry']; tfile, tdef = c['top']
            if len(sys.argv) > 3 and sys.argv[3] not in efile: continue
            tt, tal, tds = module(tfile)
            sig = tds[tdef][0][0]
            stem = pathlib.Path(tfile).name.replace('_encode_ssz_generated.bend', '')
            short = tdef[:-len('_serialize')]
            if sig.strip().startswith('o: O.Words'):
                vt = tt
                m = re.search(r'O\.words_ok\(o, (\d+), (\d+)', tt)
                if not m: res.append((efile, tfile, 'NO-OBJECT')); continue
                obj = 'O.words_new(%s)' % m.group(1)
                tdecl = 'O.Words'
            else:
                obj = 'D0.%s_default()' % short; tdecl = 'D0.%s' % short
            mains = {}
            for tag in ('orig', 'mut'):
                chain = c['files']
                names = {f: ('_audit_' + pathlib.Path(f).name) for f in chain}
                for f in chain:
                    txt = pathlib.Path(f).read_text()
                    if tag == 'mut':
                        for g in chain: txt = txt.replace('./' + pathlib.Path(g).name, './' + names[g])
                        if f == efile:
                            ln = txt.split('\n'); idx = [i for i, l in enumerate(ln) if l.startswith('def %s(' % edef)][0]
                            j = idx + 1
                            while j < len(ln) and ln[j].startswith(' '): j += 1
                            blk = '\n'.join(ln[idx:j]); assert '(out, (o, 0))' in blk
                            ln[idx:j] = [blk.replace('(out, (o, 0))', '(out, (o, 1))')]; txt = '\n'.join(ln)
                        pathlib.Path('types/' + names[f]).write_text(txt)
                mod = ('./' + names[tfile]) if tag == 'mut' else ('./' + pathlib.Path(tfile).name)
                defmod = './%s_def_generated.bend' % stem
                has_def = pathlib.Path('types/' + stem + '_def_generated.bend').exists()
                mp = pathlib.Path('types/_audit_main_%s.bend' % tag)
                mp.write_text("import Base\nimport ../src/buffer.bend as B\nimport ../src/obj.bend as O\nimport %s as D0\nimport %s as LC\n\n"
                              "def fin3(ok: Bool, p: B.Buf & U32) -> U32:\n  (b2, +n) = p\n  O.pick(ok, n, 4294967295)\n\n"
                              "def fin2(e: O.Encoded) -> U32:\n  match e:\n    case O.Encoded{ok, bytes}: fin3(ok, B.size(bytes))\n\n"
                              "def fin(p: %s & O.Encoded) -> U32:\n  (o, e) = p\n  fin2(e)\n\n"
                              "def main() -> U32: fin(LC.%s(%s))\n" % (defmod, mod, tdecl.replace('D0.D0.', 'D0.'), tdef, obj))
                mains[tag] = run('types/_audit_main_%s.bend' % tag)
            for f in pathlib.Path('types').glob('_audit_*'): f.unlink()
            res.append((efile.split('/')[-1], edef, tfile.split('/')[-1], tdef, mains['orig'], mains['mut']))
            print(res[-1], flush=True)
        json.dump(res, open(sys.argv[2] + '.res', 'w'), indent=1)
    elif cmd == 'laws-boolvec':
        # for each boolvec site: a MUTANT module holding only the mutated chain (ok_nz, ok_n, ok_at) over the ORIGINAL helpers, and the
        # law ok_at(orig) == ok_at(mutant) for all buf, off (ok_at is the only entry into ok_n/ok_nz); the `case True{}` pattern sites
        # are compiled in a full mutant copy instead (expected: rejected)
        import subprocess, os
        T = '/srv/ssz-optimization/toolchain-memo-788a6866'
        env = dict(os.environ, BEND_NO_TELEMETRY='1', BEND_LIB='vendor/bendhub')
        k = 0
        for e in EXCL:
            if rule_of(e) != 'boolvec': continue
            f = pathlib.Path(e['file']); pre = re.match(r'(\w+)_ok_n', e['def']).group(1)
            for (i, col) in entry_sites(e):
                k += 1; lines = f.read_text().split('\n'); L = lines[i]
                is_pat = e['operator'] == 'valid' and L.startswith('    case True{}') and col == L.index('case True{}') + 5
                lines[i] = L[:col] + e['after'] + L[col + len(e['before']):]
                if is_pat:
                    mut = pathlib.Path('types/_audit_bv%d.bend' % k); mut.write_text('\n'.join(lines))
                    r = subprocess.run([T + '/bin/bend', str(mut), '--check-only'], capture_output=True, text=True, env=env)
                    mm_ = (r.stdout + r.stderr).strip().split('\n'); print('PATTERN-SITE', f.name, i + 1, 'full mutant copy ->', mm_[0][:40], '|', ' '.join(mm_[1:4])[:160]); mut.unlink(); continue
                # the mutated chain only
                mtext = '\n'.join(lines); chain = []
                for nm in ('_ok_nz', '_ok_n', '_ok_at'):
                    mm = re.search(r'^def %s%s\(.*?(?=^def |\Z)' % (re.escape(pre), nm), mtext, re.M | re.S); chain.append(mm.group(0).rstrip() + '\n')
                chain = [c.replace(pre + '_ck(', 'ORIG.' + pre + '_ck(') for c in chain]
                imps = [l for l in f.read_text().split('\n') if l.startswith('import ')]
                mut = pathlib.Path('types/_audit_bv%d.bend' % k)
                mut.write_text('\n'.join(imps) + '\nimport ./%s as ORIG\n\n' % f.name + '\n'.join(chain))
                law = pathlib.Path('types/_audit_bvlaw%d.bend' % k)
                law.write_text('import Base\nimport ../src/buffer.bend as B\nimport ./%s as ORIG\nimport ./%s as MUT\n\n'
                               'def bv_law(buf: B.Buf, +off: U32) -> {ORIG.%s_ok_at(buf, off) == MUT.%s_ok_at(buf, off) : B.Buf & Bool}: {==}\n' % (f.name, mut.name, pre, pre))
                r = subprocess.run([T + '/bin/bend', str(law), '--check-only'], capture_output=True, text=True, env=env)
                msg = (r.stdout + r.stderr).strip().split('\n')
                print('LAW', f.name, e['def'], e['operator'], e['before'], '->', e['after'], msg[0][:40], '|', ' '.join(msg[1:4])[:140] if 'FAIL' in msg[0] else '', flush=True)
                law.unlink(); mut.unlink()
    else:
        print('unknown command'); sys.exit(2)


if __name__ == '__main__':
    main()
