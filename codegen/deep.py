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


_DEFLAW = re.compile(r'(def|law) (\w+)')


def _blocks(text):
    """[(name, kind, start, end)] of the top-level defs and laws (a law's block runs through its def)."""
    out = []
    starts = [m.start() for m in re.finditer(r'^(?:def|law) ', text, re.M)] + [len(text)]
    i = 0
    while i < len(starts) - 1:
        a = starts[i]
        m = _DEFLAW.match(text, a)
        kind, name = m.group(1), m.group(2)
        b = starts[i + 1]
        if kind == 'law':
            # its def follows (else a law whose def comes later: a block of its own, never twinned)
            if text.startswith(f'def {name}(', b):
                b = starts[i + 2]
                i += 1
            else:
                kind = 'lawonly'
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

    ale = re.compile(r'(?<![\w.])VB\.add_le_at\(')

    def go(t):
        # VB.add_le_at(a, c, i, k, ea, hk, h: c + i <= 2^k): the UMAX form VB.add_nw(a, c, i, ea, h: c + i <= UMAX)
        while True:
            m = ale.search(t)
            if not m:
                break
            a = m.end()
            b = _close(t, a)
            args = _split_args(t[a:b])
            if len(args) != 7 or args[3].strip() != 'k' or args[5].strip() != 'hk':
                break
            h = args[6].replace('VB.pw(k)', 'U32.to_nat(VB.UMAX())')
            t = t[:m.start()] + 'VB.add_nw(' + ','.join(args[:3] + [args[4], h]).lstrip() + ')' + t[b + 1:]
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
        if m.group(1) in ('vbytes', 'vbspec', 'vua_copy', 'vua_sc', 'vua_ct', 'vbx', 'vbenc', 'vuw', 'vputwd', 'vuwd') and p.exists():
            al[m.group(2) + '.'] = chain_names(p.read_text())
    return uify(text, al)[0]


# ---- the encoder-window interface at any output depth dd < 31 (was dd < 29) --------------------------
# dify() gives each definition with an output-depth hypothesis `{Nat.is_lt(dd, 29n) == True{} : Bool}` a twin
# name+'W' at dd < 31; the old name stays as a wrapper (its hypothesis lifted by nat__lt_trans), so callers
# keep working until they switch to the W names. Steps from 29 to 31 or 32 in the twins' bodies are rewritten;
# anything else that needs dd < 29 (e.g. a sum bounded by 2^(2 + dd) < 2^31) is reported for a hand fix.

_DD = re.compile(r'\{Nat\.is_lt\((dd), 29n\) == True\{\} : Bool\}')   # the output tree's depth only


def _dd_sig(block, kind):
    """(names, index of the depth hypothesis, its variable) or None."""
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
    for j, t in enumerate(types):
        m = _DD.fullmatch(t)
        if m:
            return names, j, m.group(1)
    return None


def dd_names(text):
    out = {}
    for name, kind, a, b in _blocks(text):
        try:
            s = _dd_sig(text[a:b], kind)
        except (ValueError, AssertionError):
            s = None
        if s:
            out[name] = s[1]
    return out


def _hdr(blk):
    """A def's header through its ':' (the first ':' after the parameters outside any bracket), ending in a newline."""
    i, d = _close(blk, blk.index('(') + 1) + 1, 0
    while True:
        c = blk[i]
        if c in '({[':
            d += 1
        elif c in ')}]':
            d -= 1
        elif c == ':' and d == 0:
            return blk[:i + 1] + '\n'
        i += 1


def dify(text, aliases, fd='FD', skip=()):
    """text with the dd < 29 definitions doubled (name+'W' at dd < 31) and the old names as wrappers.
    aliases: {prefix ('X.'): set of that module's twinned names}; fd: the alias of proofs/compact/found.bend.
    A name whose W is written by hand already (in the text) keeps its own proof and is not twinned, but the
    twins call its W; the names in skip are neither twinned nor renamed (dd < 29 helpers no twin needs)."""
    blocks = _blocks(text)
    mine = {}
    for name, kind, a, b in blocks:
        if name in skip:
            continue
        try:
            s = _dd_sig(text[a:b], kind)
        except (ValueError, AssertionError):
            s = None
        if s:
            mine[name] = (kind, s)
    defined = {n for n, _, _, _ in blocks}
    hand = {n for n in mine if n + 'W' in defined}
    for n in hand:
        del mine[n]
    local = set(mine)
    allc = {('' + n) for n in local | hand}
    for p, ns in aliases.items():
        allc |= {p + n for n in ns}
    pat = re.compile(r'(?<![\w.])(' + '|'.join(re.escape(x) for x in sorted(allc, key=len, reverse=True)) + r')\(') if allc else None
    out, pos = [], 0
    bad = []
    for name, kind, a, b in blocks:
        if kind == 'lawonly' and '{Nat.is_lt(dd, 29n) == True{} : Bool}' in text[a:b]:
            bad.append((name, 'a law at dd < 29 whose def does not follow it'))
        if name not in mine or kind == 'lawonly':
            continue
        blk = text[a:b]
        _, (names, j, v) = mine[name]
        hn = names[j]
        tw = blk.replace(f'{{Nat.is_lt({v}, 29n) == True{{}} : Bool}}', f'{{Nat.is_lt({v}, 31n) == True{{}} : Bool}}')
        if kind == 'def':
            tw = tw.replace(f'def {name}(', f'def {name}W(', 1)
        else:
            tw = tw.replace(f'law {name}:', f'law {name}W:', 1).replace(f'\ndef {name}(', f'\ndef {name}W(', 1)
        tw = tw.replace(f'{fd}.nat__lt_trans({v}, 29n, 31n, {hn}, {{==}})', hn)
        for k in ('32n', '33n'):
            tw = tw.replace(f'{fd}.nat__lt_trans({v}, 29n, {k}, {hn}, {{==}})', f'{fd}.nat__lt_trans({v}, 31n, {k}, {hn}, {{==}})')
        if pat:
            tw = pat.sub(lambda m: m.group(1) + 'W(', tw)
            # the header's own name was renamed twice
            tw = tw.replace(f'def {name}WW(', f'def {name}W(').replace(f'law {name}WW:', f'law {name}W:')
        # the byte-offset step X + c (UR.offx at d < 30) becomes UR.offx31 (any d < 31: its sum is below 2^32)
        tl = tw.split('\n')
        for i, l in enumerate(tl):
            s30 = f'{fd}.nat__lt_trans({v}, 29n, 30n, {hn}, {{==}})'
            if s30 in l and '.offx(' in l and l.count(s30) == l.count('.offx('):
                tl[i] = l.replace(s30, hn).replace('.offx(', '.offx31(')
        tw = '\n'.join(tl)
        for l in tw.split('\n'):
            if re.search(r'nat__lt_trans\(%s, 29n' % re.escape(v), l) or re.search(r'nat__\w+\(%s, 28n' % re.escape(v), l) \
                    or re.search(r'2n\+%s, .*\b%s\b' % (re.escape(v), re.escape(hn)), l):
                bad.append((name, l.strip()))
        # the wrapper
        args = [f'{fd}.nat__lt_trans({v}, 29n, 31n, {hn}, {{==}})' if i == j else n for i, n in enumerate(names)]
        if kind == 'def':
            hdr = _hdr(blk)
            wrap = hdr + f'  {name}W(' + ', '.join(args) + ')\n'
        else:
            hdr = blk[:blk.index(f'\ndef {name}(') + 1]
            wrap = hdr + f'def {name}(' + ', '.join(names) + f'):\n  {name}W(' + ', '.join(args) + ')\n'
        out.append(text[pos:a] + tw.rstrip('\n') + '\n\n' + wrap)
        pos = b
    out.append(text[pos:])
    return ''.join(out), set(local) | hand, bad


_OFFADD = re.compile(r'VF\.off_add\((\w+), (\w+), P, (\w+), 2n\+dd, e, \{==\}, (\w+), VF\.in_q\(\3, P, dd, VF\.in_le\(0n, \3, (\w+), P, VB\.pw\(dd\), \{==\}, hb\)\)\)')


def dify_fix(text, fd='F'):
    """dify for the fixed-size writer modules (var_fix_types and kin): the field offsets' sums at any depth
    dd < 31 by VF.off_add_lt (a field's first word lies inside the tree: VF.in_lt, VF.q32lt)."""
    t, mine, bad = dify(text, {}, fd)
    t = _OFFADD.sub(lambda m: f'VF.off_add_lt({m.group(1)}, {m.group(2)}, P, {m.group(3)}, e, {{==}}, VF.q32lt({m.group(3)}, P, dd, {m.group(4)}, VF.in_lt({m.group(3)}, {m.group(5)}, P, VB.pw(dd), {{==}}, hb)))', t)
    left = [b for b in bad if 'VF.off_add(' not in b[1]]
    if left:
        raise SystemExit('deep.dify_fix: ' + repr([(a, b[:160]) for a, b in left[:3]]))
    return t


def _args(s, i):
    """The top-level arguments of the call whose '(' is s[i - 1], and the index after its ')'."""
    out, d, a = [], 0, i
    while True:
        c = s[i]
        if c in '([{':
            d += 1
        elif c in ')]}':
            if d == 0:
                out.append(s[a:i].strip())
                return out, i + 1
            d -= 1
        elif c == ',' and d == 0:
            out.append(s[a:i].strip())
            a = i + 1
        i += 1


def narrow(text):
    """{name: [arg index]} of a module's defs with a premise {Nat.is_lt(x, 28n|29n|30n)} (a depth bound below 31)."""
    out = {}
    for m in re.finditer(r'^def (\w+)\(', text, re.M):
        args, _ = _args(text, m.end())
        ix = [k for k, a in enumerate(args) if re.search(r':\s*\{Nat\.is_lt\(\w+, (?:28|29|30)n\) == True\{\} : Bool\}$', a)]
        if ix:
            out[m.group(1)] = ix
    return out


def w_names(text):
    """The names X of a module that also define XW (its dd < 31 twins)."""
    defined = set(re.findall(r'^(?:def|law) (\w+)', text, re.M))
    return {n for n in dd_names(text) if n + 'W' in defined}


# The twins whose premises differ from their dd < 29 originals (the old names keep their own proofs):
# a caller's twin must supply the new premise by hand (see scratchpad encwin_recipe.md).
CHANGED = {
    'fposW': 'hk strict: 4 k < L (a field starts inside its record)',
    'mulqW': '(i, j, Ru, W, eR, ei, hm: 4 (j W) < 2^32), no dd',
    'rposW': 'hW: 1 <= W after hd',
    'vposW': 'hl32: 4 q + (r + L) < 2^32 after hl (or VCN.vposS with a < L)',
    'padd_ddW': 'h: a + b < 2^31 (a valid encoding is shorter than 2^31 bytes)',
    'cnextW': 'hb: F0 + SUM ks + k < 2^31',
    'cnext_rW': 'hb: SUM ks + F0 + k < 2^31',
    'pposW': 'hm: 1 <= m after hk',
    'proomW': 'hm: 1 <= m after hk',
    'posbW': 'hR: 1 <= R after hd',
    'arm_eW': 'hl32: 4 q + (r + (1 + E)) < 2^32 after hl',
    'posWW': 'hW: 1 <= W before hb (VRL.posW twin)',
}


def dify_out(out, strict=True, handled=(), post=None, skip=()):
    """dify every generated module of out ({path: text}, in dependency order): each call into an imported module's
    twinned name (from out itself or from proofs/obj on disk) goes to its W version. Returns the new out; with strict,
    leftover dd < 29 steps (the spots that need a strict bound by hand) and calls of a CHANGED twin raise, except the
    names in handled (the generator supplies their new premise itself: fix the twins' text after this call)."""
    from pathlib import Path
    res, reg, allbad = {}, {}, []
    for q, t in out.items():
        q = Path(q)
        if '{Nat.is_lt(dd, 29n) == True{} : Bool}' not in t or not (set(dd_names(t)) - w_names(t) - set(skip)):
            res[q] = t  # nothing at dd < 29, or twinned already (dify_fix)
            reg[q.stem] = w_names(t) if '{Nat.is_lt(dd, 29n) == True{} : Bool}' in t else set()
            continue
        fdm = re.search(r'^import \.\./compact/found\.bend as (\w+)', t, re.M)
        fd = fdm.group(1) if fdm else 'FD'
        al = {}
        for m in re.finditer(r'^import \./(\w+)\.bend as (\w+)', t, re.M):
            stem, a = m.group(1), m.group(2)
            if stem not in reg:
                src = q.parent / f'{stem}.bend'
                reg[stem] = w_names(src.read_text()) if src.exists() else set()
            if reg[stem]:
                al[a + '.'] = reg[stem]
        t2, mine, bad = dify(t, al, fd, skip)
        nar = {}
        for m in re.finditer(r'^import \./(\w+)\.bend as (\w+)', t, re.M):
            src = out.get(q.parent / f'{m.group(1)}.bend') or (res.get(q.parent / f'{m.group(1)}.bend'))
            if src is None and (q.parent / f'{m.group(1)}.bend').exists():
                src = (q.parent / f'{m.group(1)}.bend').read_text()
            for n, ix in narrow(src or '').items():
                nar[m.group(2) + '.' + n] = ix
        for n, ix in narrow(t2).items():
            nar[n] = ix
        if nar:
            cre = re.compile(r'(?<![\w.])(' + '|'.join(re.escape(x) for x in sorted(nar, key=len, reverse=True)) + r')\(')
            for _, _, ta, tb in _twin_blocks(t2):
                blk = t2[ta:tb]
                hyp31 = {h for h in re.findall(r'\+(\w+): \{Nat\.is_lt\(dd, 31n\) == True\{\} : Bool\}', blk)
                         if not re.search(r'^\s*\+' + h + r' = ', blk, re.M)}
                if not hyp31:
                    continue
                for m in cre.finditer(blk):
                    try:
                        args, _ = _args(blk, m.end())
                    except IndexError:
                        continue
                    if any(k < len(args) and args[k] in hyp31 for k in nar[m.group(1)]):
                        ln = blk[blk.rfind('\n', 0, m.start()) + 1:blk.find('\n', m.start())]
                        bad.append((m.group(1), 'a dd < 31 premise passed to a narrower bound: ' + ln.strip()[:120]))
        for n, why in CHANGED.items():
            if n in handled:
                continue
            for m in re.finditer(r'(?<![\w])(\w+\.)?' + n + r'\(', t2):
                if m.group(1) and m.group(1) in al or not m.group(1) and not re.search(r'^def ' + n + r'\(', t2, re.M):
                    ln = t2[t2.rfind('\n', 0, m.start()) + 1:t2.find('\n', m.start())]
                    if not ln.startswith('def '):
                        bad.append((n, 'changed premise (' + why + ') @@ ' + ln.strip()))
        if post:
            # the generator's own strict-bound pass: it may change the twins (and report its own leftovers);
            # ORIG: the module before dify (for an old name whose twin changes its premises: restore_old)
            global ORIG
            ORIG = t
            t2, pbad = post(q, t2, res)
            tw = ''.join(t2[a:b] for _, _, a, b in _twin_blocks(t2))
            bad = [b for b in bad if b[1].startswith('changed premise') or (re.search(r'(?<![\w.])' + re.escape(b[0]) + r'\(', tw) if b[1].startswith('a dd < 31') else b[1] in tw)] + list(pbad)
            if any(b[1].startswith('changed premise') for b in bad):
                bad = [b for b in bad if not b[1].startswith('changed premise') or b[1].split(' @@ ', 1)[1] in tw]
        reg[q.stem] = mine
        res[q] = t2
        allbad += [(q.name,) + b for b in bad]
    if strict and allbad:
        raise SystemExit('deep.dify_out: steps left at dd < 29: ' + repr(allbad[:6]))
    return res


def _twin_blocks(text):
    """[(name, kind, start, end)] of the W twins (name ends in W and its dd < 29 original is defined too)."""
    bl = _blocks(text)
    names = {n for n, _, _, _ in bl}
    return [b for b in bl if b[0].endswith('W') and b[0][:-1] in names and b[1] != 'lawonly']


def _params(blk, kind, name):
    """(start index of the def's parameter list in blk, [params]) of a def or a law's def."""
    i = blk.index(f'def {name}(') + len(f'def {name}(')
    args, _ = _args(blk, i)
    return i, args


def premise_sigs(text, new):
    """{twin name: index of its parameter new} (the twins that take premise new)."""
    out = {}
    for name, kind, a, b in _twin_blocks(text):
        _, ps = _params(text[a:b], kind, name)
        for k, p in enumerate(ps):
            if p.lstrip('+').split(':')[0].strip() == new:
                out[name] = k
    return out


def derive32(ex, anchor, new, decl, derive):
    """The new-premise twin of a derived anchor expression ex, or None: a room lemma F(.., anchor) becomes
    derive[F](.., new); a logic__subst(T, z => {P}, a, b, e, anchor) becomes logic__subst(T, z => decl({P}), a, b, e, new)."""
    dm = re.match(r'([\w.]+)\(', ex)
    if not dm:
        return None
    fn = dm.group(1)
    args, _ = _args(ex, dm.end())
    if fn.endswith('logic__subst'):
        mo = re.fullmatch(r'(\w+) => (\{.*\})', args[1], re.S) if len(args) == 6 else None
        if not mo or args[5] != anchor:
            return None
        try:
            mot = decl(mo.group(2))
        except (AssertionError, AttributeError, IndexError):
            return None
        return fn + '(' + ', '.join([args[0], mo.group(1) + ' => ' + mot] + args[2:5] + [new]) + ')'
    f = derive.get(fn.split('.')[-1])
    if not f or args[-1] != anchor:
        return None
    return (fn.rsplit('.', 1)[0] + '.' + f if '.' in fn else f) + '(' + ', '.join(args[:-1] + [new]) + ')'


def add_premise(text, anchor, new, decl, imported, wrap=None, wrap_needs=(), derive=None, needed_only=False, seeds=()):
    """The W twins of text that take premise anchor also take new (right after it, of type decl(anchor's type)), and
    every call in a twin to a twin taking new (local, or imported: {'X.': {name: index of new}}) passes new right
    after the argument at anchor's place. Returns (text, bad): bad lists the calls whose anchor argument is not
    the caller's own anchor (a derived region: its new bound must be supplied by hand)."""
    # 1. the headers (with needed_only: just the twins that call a twin taking new, and so on up)
    tb = _twin_blocks(text)
    need = None
    if needed_only:
        have = {n for n, k, a, b in tb if re.search(r'[+ ]' + re.escape(new) + r':', text[a:b][:len(_hdr(text[a:b])) if k == 'def' else text[a:b].index('def ')])}
        calls = {}
        for n, k, a, b in tb:
            calls[n] = set(re.findall(r'(?<![\w.])([\w]+(?:\.\w+)?)\(', text[a:b]))
        ext = {p + n for p, d in imported.items() for n in d} | set(seeds)
        need = set(have)
        changed = True
        while changed:
            changed = False
            for n in calls:
                if n not in need and (calls[n] & (need | ext)):
                    need.add(n)
                    changed = True
    out, pos = [], 0
    for name, kind, a, b in tb:
        blk = text[a:b]
        if need is not None and name not in need:
            out.append(text[pos:a] + blk)
            pos = b
            continue
        if kind == 'def':
            i, ps = _params(blk, kind, name)
            hit = [p for p in ps if p.lstrip('+').split(':')[0].strip() == anchor and ':' in p]
            if any(p.lstrip('+').split(':')[0].strip() == new for p in ps):
                hit = []   # written by hand with it already
            if hit:
                p = hit[0]
                ty = p.split(':', 1)[1].strip()
                j = blk.index(p, i)
                blk = blk[:j + len(p)] + f', +{new}: {decl(ty)}' + blk[j + len(p):]
        else:
            m = re.search(r'^  for \+' + re.escape(anchor) + r': (.*)$', blk, re.M)
            if m and re.search(r'^  for \+' + re.escape(new) + r': ', blk, re.M):
                m = None
            if m:
                blk = blk[:m.end()] + f'\n  for +{new}: {decl(m.group(1))}' + blk[m.end():]
                i, ps = _params(blk, kind, name)
                k = [q.strip() for q in ps].index(anchor)
                j = blk.index(ps[k], i)
                blk = blk[:j + len(ps[k])] + f', {new}' + blk[j + len(ps[k]):]
        out.append(text[pos:a] + blk)
        pos = b
    out.append(text[pos:])
    text = ''.join(out)
    # 2. the calls
    sigs = {n: k for n, k in premise_sigs(text, new).items()}
    anc = {n: k for n, k in premise_sigs(text, anchor).items()}
    callee = {n: anc[n] for n in sigs}
    for p, d in imported.items():
        for n, k in d.items():
            callee[p + n] = k
    bad = []
    if not callee:
        return text, bad
    cre = re.compile(r'(?<![\w.])(' + '|'.join(re.escape(x) for x in sorted(callee, key=len, reverse=True)) + r')\(')
    out, pos = [], 0
    for name, kind, a, b in _twin_blocks(text):
        blk = text[a:b]
        hdr_end = len(_hdr(blk)) if kind == 'def' else blk.index('):\n', blk.index(f'def {name}(')) + 3
        has = name in sigs
        edits = []
        for m in cre.finditer(blk):
            if m.start() < hdr_end:
                continue
            args, _ = _args(blk, m.end())
            k = callee[m.group(1)]
            ins = new
            comp = args[k] + new[2:] if re.fullmatch(r'\w+', args[k]) else None   # a companion premise: hle -> hle32 / hle31
            if args[k] != anchor and comp and re.search(r'[+ ]' + re.escape(comp) + r':', blk[:hdr_end]):
                ins = comp
            elif not has:
                bad.append((name, f'calls {m.group(1)} (takes {new}) without {new} in scope'))
                continue
            elif args[k] != anchor:
                ex = args[k]
                lm = None
                if re.fullmatch(r'\w+', ex):   # the nearest let binding before the call
                    for lm in re.finditer(r'^\s*\+' + re.escape(ex) + r' = ', blk[:m.start()], re.M):
                        pass
                if lm:   # a let-bound derivation
                    em_ = re.match(r'[\w.]+\(', blk[lm.end():])
                    if em_:
                        _, e2 = _args(blk, lm.end() + em_.end())
                        ex = blk[lm.end():e2]
                ins = derive32(ex, anchor, new, decl, derive or {})
                f = ins is not None
                if not f:
                    bad.append((name, f'{m.group(1)}: the {anchor} argument is derived ({args[k][:60]}): supply its {new} by hand'))
                    continue
            if ins in args[k + 1:]:
                continue   # passed by hand already
            # the end of argument k
            j, d, cnt = m.end(), 0, 0
            while True:
                c = blk[j]
                if c in '([{':
                    d += 1
                elif c in ')]}':
                    if d == 0:
                        break
                    d -= 1
                elif c == ',' and d == 0:
                    if cnt == k:
                        break
                    cnt += 1
                j += 1
            edits.append((j, ins))
        for j, ins in sorted(edits, reverse=True):
            blk = blk[:j] + f', {ins}' + blk[j:]
        out.append(text[pos:a] + blk)
        pos = b
    out.append(text[pos:])
    text = ''.join(out)
    # 3. the old names' wrappers: their call of the twin gets wrap (the premise derived at dd < 29)
    if wrap and sigs:
        wre = re.compile(r'(?<![\w.])(' + '|'.join(re.escape(x) for x in sorted(sigs, key=len, reverse=True)) + r')\(')
        out, pos = [], 0
        for name, kind, a, b in _blocks(text):
            if name + 'W' not in sigs or kind == 'lawonly':
                continue
            blk = text[a:b]
            _, ps = _params(blk, kind, name)
            pn = {p.lstrip('+').split(':')[0].strip() for p in ps}
            body = blk.index(f'def {name}(')
            start = len(_hdr(blk[body:])) + body if kind == 'def' else blk.index('):\n', body) + 3
            m = wre.search(blk, start)
            if not m or m.group(1) != name + 'W':
                continue
            if not set(wrap_needs) <= pn:
                bad.append((name, f'the wrapper lacks {sorted(set(wrap_needs) - pn)} for {new}'))
                continue
            args, _ = _args(blk, m.end())
            k = anc[name + 'W']
            j, d, cnt = m.end(), 0, 0
            while True:
                c = blk[j]
                if c in '([{':
                    d += 1
                elif c in ')]}':
                    if d == 0:
                        break
                    d -= 1
                elif c == ',' and d == 0:
                    if cnt == k:
                        break
                    cnt += 1
                j += 1
            tps = ps if kind == 'def' else ['+' + x.group(1) + ': ' + x.group(2) for x in re.finditer(r'^  for \+(\w+): (.*)$', blk, re.M)]
            w = wrap(tps[[q.lstrip('+').split(':')[0].strip() for q in tps].index(anchor)].split(':', 1)[1].strip(), tps) if callable(wrap) else wrap
            blk = blk[:j] + f', {w}' + blk[j:]
            out.append(text[pos:a] + blk)
            pos = b
        out.append(text[pos:])
        text = ''.join(out)
    return text, bad


def region_x(ty):
    """X of a premise type {Nat.is_le(X, VB.pw(dd)) == True{} : Bool} (a region's end in the output tree)."""
    m = re.fullmatch(r'\{Nat\.is_le\((.*), VB\.pw\(dd\)\) == True\{\} : Bool\}', ty.strip())
    return m.group(1) if m else None


def region32(fd):
    """The decl of hr32 from its anchor's type: 4 X < 2^32 (the region ends inside U32 positions)."""
    return lambda ty: '{Nat.is_lt(A.quad(' + region_x(ty) + '), ' + fd + '.spec_common__pow2(32n)) == True{} : Bool}'


def strict_eoff(anchor='hR', off='eoff', hq='hq'):
    """A dify_out post pass for the container encoders' header offsets: every twin taking the region premise anchor
    (X <= 2^dd) also takes hr32: 4 X < 2^32, and offW's sum pos + c is taken strictly below 2^32 (VF.off_add_lt,
    VF.q32r with hqX: hq's k + P <= X). The old names' wrappers derive hr32 at dd < 29 (VF.r32w)."""
    def post(q, t, res):
        fdm = re.search(r'^import \.\./compact/found\.bend as (\w+)', t, re.M)
        fd = fdm.group(1) if fdm else 'FD'
        bad = []
        imp = {}
        for mi in re.finditer(r'^import \./(\w+)\.bend as (\w+)', t, re.M):
            src = res.get(q.parent / f'{mi.group(1)}.bend')
            if src is None and (q.parent / f'{mi.group(1)}.bend').exists():
                src = (q.parent / f'{mi.group(1)}.bend').read_text()
            if src:
                h = premise_sigs(src, anchor)
                d = {n: h[n] for n in premise_sigs(src, 'hr32') if n in h}
                if d:
                    imp[mi.group(2) + '.'] = d
        t, b1 = add_premise(t, anchor, 'hr32', region32(fd), imp,
                            wrap=lambda ty, ps: f'VF.r32w({region_x(ty)}, dd, hdd, {anchor})', wrap_needs=('dd', 'hdd', anchor))
        bad += b1
        W = off + 'W'
        if f'def {W}(' in t:
            a = t.index(f'def {W}(')
            b = t.index('\ndef ', a + 1) + 1
            blk = t[a:b]
            _, ps = _params(blk, 'def', W)
            X = region_x([p for p in ps if p.lstrip('+').startswith(anchor + ':')][0].split(':', 1)[1])
            m = re.search(r'VF\.off_add\(pos, c, P, k, 2n\+dd, (\w+), ec, hdd, VF\.in_q\(k, P, dd, ' + hq + r'\((k, dd, P, \w+, hk), ' + anchor + r'\)\)\)', blk)
            if not m:
                bad.append((W, 'unrecognized body'))
            else:
                blk = blk[:m.start()] + (f'VF.off_add_lt(pos, c, P, k, {m.group(1)}, ec, VF.q32r(Nat.add(k, P), {X}, '
                                         f'{hq}X({m.group(2)}, {fd}.nat__le_refl({X})), hr32))') + blk[m.end():]
                t = t[:a] + blk + t[b:]
                # hqX: hq with the tree's 2^dd replaced by X itself (its anchor premise becomes X <= X)
                ha = t.index(f'def {hq}(')
                hb = t.index('\ndef ', ha + 1) + 1
                hx = t[ha:hb].replace(f'def {hq}(', f'def {hq}X(', 1).replace('VB.pw(dd)', X)
                t = t[:hb] + hx + '\n' + t[hb:] if not t[hb - 2:hb] == '\n\n' else t[:hb] + hx + t[hb:]
        return t, bad
    return post


def chain_posts(*ps):
    """dify_out post passes applied in turn."""
    def post(q, t, res):
        bad = []
        for p in ps:
            t, b = p(q, t, res)
            bad += b
        return t, bad
    return post


def rename_in_twins(pairs):
    """A post pass: in the W twins, each call old( becomes new( (a library twin whose depth variable is not dd)."""
    def post(q, t, res):
        out, pos = [], 0
        for _, _, a, b in _twin_blocks(t):
            blk = t[a:b]
            for o, n in pairs.items():
                blk = re.sub(r'(?<![\w.])' + re.escape(o) + r'\(', n + '(', blk)
            out.append(t[pos:a] + blk)
            pos = b
        out.append(t[pos:])
        return ''.join(out), []
    return post


HL = re.compile(r'\{Nat\.is_le\(Nat\.add\((.*), (\w+)\.NWN\(Nat\.add\((.*), (.*)\)\)\), VB\.pw\(dd\)\) == True\{\} : Bool\}')


def hl32_decl(fd):
    """hl32's type from hl's: {q + NWN(r + L) <= 2^dd} gives {4 q + (r + L) < 2^32} (splits at the top-level commas)."""
    def decl(ty):
        ty = ty.strip()
        assert ty.startswith('{Nat.is_le(Nat.add(') and ty.endswith(', VB.pw(dd)) == True{} : Bool}'), ty
        inner = ty[len('{Nat.is_le(Nat.add('):-len(', VB.pw(dd)) == True{} : Bool}')]
        a, _ = _args(inner + ')', 0)
        q, nwn = a[0], a[1]
        m = re.match(r'(\w+)\.NWN\(Nat\.add\(', nwn)
        b, _ = _args(nwn, m.end())
        return '{Nat.is_lt(Nat.add(A.quad(' + q + '), Nat.add(' + b[0] + ', ' + b[1] + ')), ' + fd + '.spec_common__pow2(32n)) == True{} : Bool}'
    return decl


def hl32_wrap(vrx='VRX'):
    """The old names' hl32 at dd < 29: VRX.hl32w(q, r, L, dd, hd, hl) (hd: the dd < 29 premise's name)."""
    def wrap(ty, ps):
        ty = ty.strip()
        inner = ty[len('{Nat.is_le(Nat.add('):-len(', VB.pw(dd)) == True{} : Bool}')]
        a, _ = _args(inner + ')', 0)
        m = re.match(r'(\w+)\.NWN\(Nat\.add\(', a[1])
        b, _ = _args(a[1], m.end())
        hd = [p.lstrip('+').split(':')[0].strip() for p in ps if '{Nat.is_lt(dd, 29n) == True{} : Bool}' in p][0]
        return f'{vrx}.hl32w({a[0]}, {b[0]}, {b[1]}, dd, {hd}, hl)'
    return wrap


def hl32_pass(vrx='VRX', derive=None, needed_only=False):
    """A dify_out post pass: every twin taking hl (q + NWN(r + L) <= 2^dd) also takes hl32 (4 q + (r + L) < 2^32);
    the calls pass it on (through the room lemmas' 32 variants, derive: {name: name32}); the old names derive it."""
    der = {'froom': 'froom32', 'rroom': 'rroom32'}
    der.update(derive or {})

    def post(q, t, res):
        fdm = re.search(r'^import \.\./compact/found\.bend as (\w+)', t, re.M)
        fd = fdm.group(1) if fdm else 'FD'
        imp = {}
        for mi in re.finditer(r'^import \./(\w+)\.bend as (\w+)', t, re.M):
            src = res.get(q.parent / f'{mi.group(1)}.bend')
            if src is None and (q.parent / f'{mi.group(1)}.bend').exists():
                src = (q.parent / f'{mi.group(1)}.bend').read_text()
            if src:
                h = premise_sigs(src, 'hl')
                d = {n: h[n] for n in premise_sigs(src, 'hl32') if n in h}
                if d:
                    imp[mi.group(2) + '.'] = d
        vm = re.search(r'^import \./vrecx\.bend as (\w+)$', t, re.M)
        if vm:
            va = vm.group(1)
        else:
            va = vrx
            t = re.sub(r'^(import \./\w+\.bend as \w+\n)(?!import)', lambda m: m.group(1) + f'import ./vrecx.bend as {va}\n', t, count=1, flags=re.M)
        t, bad = add_premise(t, 'hl', 'hl32', hl32_decl(fd), imp, wrap=hl32_wrap(va), wrap_needs=('dd', 'hl'), derive=der, needed_only=needed_only)
        if 'hl32w(' not in t and not vm:
            t = t.replace(f'import ./vrecx.bend as {va}\n', '', 1)
        return t, bad
    return post


def edit_calls(text, name, fn, rename=None):
    """In the W twins, every call name(args) becomes name(fn(args, blk)) (fn returns the new argument list, or None
    to leave it); blk is the enclosing twin's text (for its premises). name may be qualified (X.f) or local."""
    out, pos = [], 0
    cre = re.compile(r'(?<![\w.])' + re.escape(name) + r'\(')
    for tn, kind, a, b in _twin_blocks(text):
        blk = text[a:b]
        start = len(_hdr(blk)) if kind == 'def' else blk.index('):\n', blk.index(f'def {tn}(')) + 3
        o, p = [], start
        for m in cre.finditer(blk, start):
            if m.start() < p:
                continue
            args, end = _args(blk, m.end())
            new = fn(args, blk)
            if new is None:
                continue
            o.append(blk[p:m.start()] + (rename or name) + '(' + ', '.join(new) + ')')
            p = end
        o.append(blk[p:])
        out.append(text[pos:a] + blk[:start] + ''.join(o))
        pos = b
    out.append(text[pos:])
    return ''.join(out)


def param_type(blk, name, pname):
    """The type text of parameter pname of the def (or law's def) name in blk, or None."""
    i = blk.index(f'def {name}(') + len(f'def {name}(')
    ps, _ = _args(blk, i)
    for p in ps:
        if p.lstrip('+').split(':')[0].strip() == pname and ':' in p:
            return p.split(':', 1)[1].strip()
    return None


def hl32_parts(ty):
    """(q, r, L) of an hl32 type {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, L)), ..pow2(32n)) == True{} : Bool}."""
    inner = ty.strip()[len('{Nat.is_lt(Nat.add('):]
    a, _ = _args(inner, 0)
    q = a[0][len('A.quad('):-1]
    b, _ = _args(a[1], len('Nat.add('))
    return q, b[0], b[1]


def twin_name(blk):
    return re.match(r'(?:law (\w+):|def (\w+)\()', blk).group(1) or re.match(r'def (\w+)\(', blk).group(1)


ORIG = ''


def restore_old(t, name):
    """The old name's own proof back (from ORIG, the module before dify) in place of its wrapper: for a twin whose
    premises changed, the wrapper no longer fits."""
    for n, kind, a, b in _blocks(ORIG):
        if n == name:
            orig = ORIG[a:b]
            break
    else:
        return t
    for n, kind, a, b in _blocks(t):
        if n == name:
            return t[:a] + orig + t[b:]
    return t


def hs31_decl(ty):
    """hs31's type from hl's: {q + NWN(r + L) <= 2^dd} gives {L < 2^31}."""
    ty = ty.strip()
    inner = ty[len('{Nat.is_le(Nat.add('):-len(', VB.pw(dd)) == True{} : Bool}')]
    a, _ = _args(inner + ')', 0)
    m = re.match(r'(\w+)\.NWN\(Nat\.add\(', a[1])
    b, _ = _args(a[1], m.end())
    return '{Nat.is_lt(' + b[1] + ', VB.pw(31n)) == True{} : Bool}'


def hs31_pass(vrx='VRX', derive=None, needed_only=True, seeds=()):
    """A dify_out post pass for the fused-check writers (containers, variable lists): every twin taking hl also
    takes hs31 (the region's length L < 2^31, O.padd's poison bit), right after hl; the calls pass it on
    (the room lemmas' 31 variants, derive); the old names derive it at dd < 29 (VRX.hs31w)."""
    der = {'froom': 'froom31', 'rroom': 'rroom31', 'croom': 'croom31', 'proomW': 'proom31'}
    der.update(derive or {})

    def wrap(ty, ps):
        ty = ty.strip()
        inner = ty[len('{Nat.is_le(Nat.add('):-len(', VB.pw(dd)) == True{} : Bool}')]
        a, _ = _args(inner + ')', 0)
        m = re.match(r'(\w+)\.NWN\(Nat\.add\(', a[1])
        b, _ = _args(a[1], m.end())
        hd = [p.lstrip('+').split(':')[0].strip() for p in ps if '{Nat.is_lt(dd, 29n) == True{} : Bool}' in p][0]
        return f'{va}.hs31w({a[0]}, {b[0]}, {b[1]}, dd, {hd}, hl)'

    def post(q, t, res):
        nonlocal va
        imp = {}
        for mi in re.finditer(r'^import \./(\w+)\.bend as (\w+)', t, re.M):
            src = res.get(q.parent / f'{mi.group(1)}.bend')
            if src is None and (q.parent / f'{mi.group(1)}.bend').exists():
                src = (q.parent / f'{mi.group(1)}.bend').read_text()
            if src:
                h = premise_sigs(src, 'hl')
                d = {n: h[n] for n in premise_sigs(src, 'hs31') if n in h}
                if d:
                    imp[mi.group(2) + '.'] = d
        vm = re.search(r'^import \./vrecx\.bend as (\w+)$', t, re.M)
        if vm:
            va = vm.group(1)
        else:
            va = vrx
            t = re.sub(r'^(import \./\w+\.bend as \w+\n)(?!import)', lambda m: m.group(1) + f'import ./vrecx.bend as {va}\n', t, count=1, flags=re.M)
        t, bad = add_premise(t, 'hl', 'hs31', hs31_decl, imp, wrap=wrap, wrap_needs=('dd', 'hl'), derive=der, needed_only=needed_only, seeds=seeds)
        if 'hs31w(' not in t and not vm:
            t = t.replace(f'import ./vrecx.bend as {va}\n', '', 1)
        return t, bad
    va = vrx
    return post
