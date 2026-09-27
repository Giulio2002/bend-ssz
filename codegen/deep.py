"""The deep decode laws (any tree depth d < 31, n <= VB.NMAX): shared text passes for the window
generators.

A window lemma's hypotheses bound the window by the tree, x + len <= 4 2^d; at d = 30 that is 2^32,
so the byte arithmetic of the window's end needs its own bound below 2^32 (every window lies in a
buffer of n bytes, n a U32). thread() adds that hypothesis, hw32, next to every window hypothesis of
the given shape, and passes it on in every call of a local definition that takes it, right after the
window hypothesis's argument (which must be the caller's own window hypothesis, `hw`).
"""
import re


def _split_args(s):
    """Top-level comma split; <..> counts as a bracket only as a type application (X<..>), never in
    => / -> or a comparison."""
    out, cur, d = [], '', 0
    for j, ch in enumerate(s):
        if ch in '({[' or (ch == '<' and j > 0 and (s[j - 1].isalnum() or s[j - 1] == '_') and j + 1 < len(s) and s[j + 1] != ' '):
            d += 1
        elif ch in ')}]' or (ch == '>' and j > 0 and s[j - 1] not in '=-' and s[j - 1] != ' '):
            d -= 1
        if ch == ',' and d == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    out.append(cur)
    return out


def _close(s, i):
    """The index of the ')' closing the '(' at s[i - 1]."""
    d = 1
    while d:
        c = s[i]
        if c == '(':
            d += 1
        elif c == ')':
            d -= 1
        i += 1
    return i - 1


def thread(text, hw_decl, hw32_decl, hw='hw', hw32='hw32', callee_ok=None):
    """Add `+hw32: ..` after every `+hw: ..` of the shape hw_decl in a definition's parameters (and a
    `for +hw32: ..` line after every `for +hw: ..` law line), and thread the argument through the calls.
    hw_decl / hw32_decl: the hypotheses' types as they are written (without the name)."""
    P = f'+{hw}: {hw_decl}'
    Q = f'+{hw32}: {hw32_decl}'
    # the definitions that take it: their name and the index of the window hypothesis
    takers = {}
    for m in re.finditer(r'^def (\w+)\(', text, re.M):
        a = m.end()
        b = _close(text, a)
        ps = [p.strip() for p in _split_args(text[a:b])]
        if P in ps:
            takers[m.group(1)] = ps.index(P)
    # laws: `for +hw: ..` lines, and their def line `def name(args):`
    law_takers = {}
    for m in re.finditer(r'^law (\w+):\n((?:  for .*\n)+)', text, re.M):
        fors = [l[len('  for '):].strip() for l in m.group(2).rstrip('\n').split('\n')]
        if P in fors:
            law_takers[m.group(1)] = fors.index(P)
    if not takers and not law_takers:
        return text
    # parameters
    text = text.replace(P + ',', P + ', ' + Q + ',').replace(P + ')', P + ', ' + Q + ')')
    text = text.replace(f'  for {P}\n', f'  for {P}\n  for {Q}\n')
    # law defs: def name(args) with positional names
    for name, k in law_takers.items():
        m = re.search(rf'^def {name}\(([^)]*)\):', text, re.M)
        args = [a.strip() for a in m.group(1).split(',')]
        assert args[k] == hw, (name, args)
        args.insert(k + 1, hw32)
        text = text[:m.start(1)] + ', '.join(args) + text[m.end(1):]
        takers[name] = k
    # calls (innermost first: an argument may itself be such a call)
    pat = re.compile(r'(?<![\w.])(' + '|'.join(sorted(takers, key=len, reverse=True)) + r')\(')

    def calls(t):
        out, i = [], 0
        while True:
            m = pat.search(t, i)
            if not m:
                out.append(t[i:])
                return ''.join(out)
            a = m.end()
            line_start = t.rfind('\n', 0, m.start()) + 1
            if t[line_start:m.start()] == 'def ':
                out.append(t[i:a])
                i = a
                continue
            b = _close(t, a)
            args = _split_args(calls(t[a:b]))
            k = takers[m.group(1)]
            if len(args) <= k:
                raise SystemExit(f'deep.thread: call {m.group(1)}({t[a:b][:120]}..) has no argument {k}')
            if args[k].strip() == hw:
                arg32 = hw32
            elif callee_ok and callee_ok(m.group(1), args[k].strip()):
                arg32 = callee_ok(m.group(1), args[k].strip())
            else:
                raise SystemExit(f'deep.thread: call {m.group(1)}(..) passes {args[k].strip()[:100]!r} as {hw}')
            args.insert(k + 1, (' ' if args[k].startswith(' ') else '') + arg32)
            out.append(t[i:a] + ','.join(args) + ')')
            i = b + 1
    return calls(text)


def _defs(text):
    """{name: (start, header end, params [str], rest of the header after ')')} of the top-level defs."""
    out = {}
    for m in re.finditer(r'^def (\w+)\(', text, re.M):
        a = m.end()
        b = _close(text, a)
        e = text.index(':\n', b)
        out[m.group(1)] = (m.start(), a, b, [p.strip() for p in _split_args(text[a:b])], text[b + 1:e])
    return out


def compat(text, names, hw_decl, hw32_decl, sum_term, db_old=28, db=31, suffix='D', hw='hw', hw32='hw32', hw32_term=None):
    """Rename the deep interface defs `names` to name+suffix and add wrappers under the old names with the old
    hypotheses (d < db_old, no hw32): the deep def's hw32 is VB.hw32of of the old window bound. sum_term: the
    window's end (the hw bound's left side). Callers of the old interface stay as they are."""
    P = f'+{hw}: {hw_decl}'
    Q = f'+{hw32}: {hw32_decl}'
    HD = '+hd: {Nat.is_lt(d, %dn) == True{} : Bool}'
    ds = _defs(text)
    for nm in names:
        if nm not in ds:
            raise SystemExit(f'deep.compat: no def {nm}')
    pat = re.compile(r'(?<![\w.])(' + '|'.join(sorted(names, key=len, reverse=True)) + r')\(')
    text = pat.sub(lambda m: m.group(1) + suffix + '(', text)
    wrappers = []
    for nm in names:
        _, a, b, ps, rest = ds[nm]
        assert P in ps and Q in ps and HD % db in ps, (nm, ps)
        old = [HD % db_old if p == HD % db else p for p in ps if p != Q]
        args = []
        for p in ps:
            name = p.split(':')[0].strip().lstrip('+')
            if p == HD % db:
                args.append(f'FD.nat__lt_trans(d, {db_old}n, {db}n, hd, {{==}})')
            elif p == Q:
                args.append(hw32_term or f'VB.hw32of(d, {sum_term}, FD.nat__lt_trans(d, {db_old}n, 30n, hd, {{==}}), {hw})')
            else:
                args.append(name)
        wrappers.append(f'def {nm}(' + ', '.join(old) + ')' + rest + ':\n  ' + nm + suffix + '(' + ', '.join(args) + ')\n')
    return text.rstrip('\n') + '\n\n# ---- the window interface as it was (d < %d, no hw32), for the callers not yet deep ----\n\n' % db_old + '\n'.join(wrappers)


# ---- the copy lemmas at any length L with 31 + L <= UMAX (every window of an n <= NMAX buffer) ----------
# The copy chain's lemmas took a bound 31 + L <= 2^k, k < 31 (the triple k, hk, hy): the storage of
# at most 2^30 bytes. uify() gives each such definition a twin name+'U' with the one hypothesis
# hy: 31 + L <= UMAX, and keeps the old name as a wrapper (hy from VC.hyU), so every caller stays.

HK = '{Nat.is_lt(k, 31n) == True{} : Bool}'
_HY = re.compile(r'\{Nat\.is_le\(((?:VC\.)?YL\((\w+)\)), VB\.pw\(k\)\) == True\{\} : Bool\}')
# the leaf lemmas of proofs/obj/vcopy.bend: (L, k, hk, hy) -> (L, hy)
VC_LEAVES = {'ey31': 'ey31u', 'eq_q': 'eq_qu', 'eM': 'eMu', 'eWZ': 'eWZu', 'eNW': 'eNWu', 'nw_le_wz': 'nw_le_wzu', 'wz_le': 'wz_leu'}


def _blocks(text):
    """[(name, kind, start, end)] of the top-level defs and laws (a law's block runs through its def)."""
    out = []
    starts = [m.start() for m in re.finditer(r'^(?:def|law) ', text, re.M)] + [len(text)]
    i = 0
    while i < len(starts) - 1:
        a = starts[i]
        m = re.match(r'(def|law) (\w+)', text[a:])
        kind, name = m.group(1), m.group(2)
        b = starts[i + 1]
        if kind == 'law':
            # its def follows
            assert text[b:].startswith(f'def {name}('), name
            b = starts[i + 2]
            i += 1
        # trailing comments / blank lines belong to the next block
        seg = text[a:b]
        k = len(seg.rstrip('\n'))
        lines = seg[:k].split('\n')
        while lines and lines[-1].startswith('#'):
            lines.pop()
        e = a + len('\n'.join(lines).rstrip('\n')) + 1
        out.append((name, kind, a, min(e, b)))
        i += 1
    return out


def chain_sig(block, kind):
    """(params, k index, hk index, hy index, L name) when the block takes the triple, else None."""
    if kind == 'def':
        a = block.index('(') + 1
        b = _close(block, a)
        ps = [p.strip() for p in _split_args(block[a:b])]
        names = [p.split(':')[0].strip().lstrip('+') for p in ps]
        types = [p.split(':', 1)[1].strip() if ':' in p else '' for p in ps]
    else:
        fors = re.findall(r'^  for (.*)$', block, re.M)
        names = [f.split(':')[0].strip().lstrip('+') for f in fors]
        types = [f.split(':', 1)[1].strip() for f in fors]
        m = re.search(r'^def \w+\(([^)]*)\):', block, re.M)
        assert [x.strip() for x in m.group(1).split(',')] == names, block[:80]
        ps = fors
    if not ('k' in names and 'hk' in names and 'hy' in names):
        return None
    if types[names.index('hk')] != HK:
        return None
    m = _HY.fullmatch(types[names.index('hy')])
    if not m:
        return None
    return ps, names, names.index('k'), names.index('hk'), names.index('hy'), m.group(2)


def uify(text, alias_chain, own_chain=None):
    """text with the copy-chain definitions doubled (name+'U', hy: 31 + L <= UMAX) and the old names as wrappers.
    alias_chain: {prefix ('' for local, 'VBY.' ...): {name: (k index, hk index)}} of the chain definitions called
    (the local ones are found here). Returns (text, {name: (k index, hk index)}) of this file's chain defs."""
    blocks = _blocks(text)
    mine = {}
    for name, kind, a, b in blocks:
        s = chain_sig(text[a:b], kind)
        if s:
            mine[name] = s
    calls = {p: dict(v) for p, v in alias_chain.items()}
    calls.setdefault('', {}).update({n: (s[2], s[3]) for n, s in mine.items()})
    out, pos = [], 0
    for name, kind, a, b in blocks:
        if name not in mine:
            continue
        ps, names, ik, ihk, ihy, Lv = mine[name]
        blk = text[a:b]
        new = _u_block(blk, kind, name, ps, names, ik, ihk, ihy, Lv, calls)
        wrap = _u_wrapper(blk, kind, name, ps, names, ik, ihk, ihy, Lv)
        out.append(text[pos:a] + new + '\n' + wrap)
        pos = b
    out.append(text[pos:])
    return ''.join(out), {n: (s[2], s[3]) for n, s in mine.items()}


def _hyU_type(Lv, yl):
    return '{Nat.is_le(%s, U32.to_nat(VB.UMAX())) == True{} : Bool}' % yl


def _u_calls(body, calls):
    """Chain calls renamed to their U twins without the k and hk arguments; the vcopy leaves likewise."""
    leaves = {'VC.': {n: (1, 2) for n in VC_LEAVES}}
    allc = {}
    for p, v in list(calls.items()) + list(leaves.items()):
        for n, ix in v.items():
            allc[p + n] = ix
    pat = re.compile(r'(?<![\w.])(' + '|'.join(re.escape(x) for x in sorted(allc, key=len, reverse=True)) + r')\(')

    def go(t):
        res, i = [], 0
        while True:
            m = pat.search(t, i)
            if not m:
                res.append(t[i:])
                return ''.join(res)
            a = m.end()
            b = _close(t, a)
            args = _split_args(go(t[a:b]))
            ik, ihk = allc[m.group(1)]
            args = [x for j, x in enumerate(args) if j not in (ik, ihk)]
            if args and args[0].startswith(' '):
                args[0] = args[0][1:]
            nm = m.group(1)
            base = nm.split('.')[-1]
            pre = nm[:len(nm) - len(base)]
            un = VC_LEAVES[base] if pre == 'VC.' and base in VC_LEAVES else base + 'U'
            res.append(t[i:m.start()] + pre + un + '(' + ','.join(args).lstrip() + ')')
            i = b + 1
    return go(body)


def _u_block(blk, kind, name, ps, names, ik, ihk, ihy, Lv, calls):
    yl = _HY.fullmatch(ps[ihy].split(':', 1)[1].strip()).group(1)
    if kind == 'def':
        a = blk.index('(') + 1
        b = _close(blk, a)
        rest = blk[b:]
        keep = [p for j, p in enumerate(_split_args(blk[a:b])) if j not in (ik, ihk)]
        head = blk[:a].replace(f'def {name}(', f'def {name}U(')
        hy_old = ps[ihy]
        params = ','.join(keep)
        params = params.replace(hy_old.split(':', 1)[1].strip(), _hyU_type(Lv, yl))
        if params.startswith(' '):
            params = params[1:]
        new = head + params + rest
        hdr_end = a + len(params) + len(new) - len(head) - len(params) - len(rest)
    else:
        lines = blk.split('\n')
        out = []
        for ln in lines:
            if ln.startswith(f'law {name}:'):
                out.append(f'law {name}U:')
            elif ln.startswith('  for '):
                f = ln[len('  for '):]
                nm = f.split(':')[0].strip().lstrip('+')
                if nm in ('k', 'hk'):
                    continue
                if nm == 'hy':
                    ln = f'  for +hy: {_hyU_type(Lv, yl)}'
                out.append(ln)
            elif ln.startswith(f'def {name}('):
                args = [x.strip() for x in ln[len(f'def {name}('):ln.index('):')].split(',')]
                args = [x for j, x in enumerate(args) if j not in (ik, ihk)]
                out.append(f'def {name}U(' + ', '.join(args) + '):' + ln[ln.index('):') + 2:])
            else:
                out.append(ln)
        new = '\n'.join(out)
    # the body: calls
    if kind == 'def':
        a = new.index('(') + 1
        b = _close(new, a)
        e = new.index(':\n', b)
        body_start = e + 2
    else:
        body_start = new.index('\n', new.index(f'def {name}U(')) + 1
    body = _u_calls(new[body_start:], calls)
    for bad in [r'(?<![\w.])k(?![\w])', r'(?<![\w.])hk(?![\w])', r'VB\.pw\(k\)']:
        if re.search(bad, body):
            raise SystemExit(f'deep.uify: {name}: {bad} left in the body:\n' + body[:600])
    return new[:body_start] + body


def _u_wrapper(blk, kind, name, ps, names, ik, ihk, ihy, Lv):
    args = []
    for j, nm in enumerate(names):
        if j in (ik, ihk):
            continue
        args.append(f'VC.hyU({Lv}, k, hk, hy)' if j == ihy else nm)
    call = f'{name}U(' + ', '.join(args) + ')'
    if kind == 'def':
        a = blk.index('(') + 1
        b = _close(blk, a)
        e = blk.index(':\n', b)
        return blk[:e + 2] + '  ' + call + '\n'
    hdr = blk[:blk.index(f'\ndef {name}(') + 1]
    return hdr + f'def {name}(' + ', '.join(names) + '):\n  ' + call + '\n'


def chain_names(text):
    """{name: (k index, hk index)} of a file's definitions that take the triple (k, hk, hy)."""
    out = {}
    for name, kind, a, b in _blocks(text):
        s = chain_sig(text[a:b], kind)
        if s:
            out[name] = (s[2], s[3])
    return out


def uify_file(text, obj_dir):
    """uify() with the chain definitions of the modules text imports from obj_dir."""
    al = {}
    for m in re.finditer(r'^import \./(\w+)\.bend as (\w+)', text, re.M):
        p = obj_dir / f'{m.group(1)}.bend'
        if m.group(1) in ('vbytes', 'vbspec', 'vua_copy', 'vua_sc', 'vua_ct', 'vbx') and p.exists():
            al[m.group(2) + '.'] = chain_names(p.read_text())
    return uify(text, al)[0]
