"""The OKW twins: container encodings below 2^31 bytes (the object API's own limit: O.padd keeps bit 31 as the
poison flag), in place of the OK predicates' 4 2^28 (the depth-28 trees).

A container's iface (codegen/var_cont_enc.py iface_text) proves its size, offsets and parts under OKT, whose
last conjunct bounds its bytes ENDC by 4 2^k (k = 28, kept symbolic). The twins here take OKTW instead: the
children containers' OKW, and ENDC < 2^31. Their chains (okoC, szC, partsC, validC, encE, specC, ...) are the
same proofs with the bound B = ENDC itself (ENDC <= ENDC) and B < 2^31 where a sum must stay below the poison
bit (vconts.pstepB) or fit four bytes (vconts.fitcB, vbsize.fitsB). The children lists' size and spec lemmas get
B twins too (list_btwins: encx_specB, szxB).

These are text passes over the generated modules (like deep.dify): the old names and their proofs stay as they
are; the twins are added next to them."""
import re

import deep

K28 = '+k: Nat, +ek: {k == 28n : Nat}'
# the laws on OK(m) that get an O twin on OKW(m) (putx / putx_bytes: by goO; bndx: its bound is k's)
OLAWS = ('szx', 'encx_spec', 'domx', 'maxx')
# the companion's (<iface>_o: okw_companion): the size and validity passes on OKW (their importers alone pay for them)
OLAWS_C = OLAWS + ('sizex', 'validx')


def _blocks(t):
    return deep._blocks(t)


def _block_text(t, name):
    """(start, end) of the def (or law and its def) name: its own lines only (not a type or comment after it)."""
    for n, kind, a, b in _blocks(t):
        if n == name and kind != 'lawonly':
            lines = t[a:b].split('\n')
            keep = 1
            for i, l in enumerate(lines[1:], 1):
                if l.startswith((' ', 'def ' + n + '(')) or (kind == 'law' and l.startswith('def ')):
                    keep = i + 1
                elif l.strip() and not l.startswith(' '):
                    break
            return a, a + len('\n'.join(lines[:keep])) + 1
    return None


def _calls(s, name):
    """[(start, end, args)] of the calls name( in s (name exact, not a suffix of a longer name)."""
    out = []
    for m in re.finditer(r'(?<![\w.])' + re.escape(name) + r'\(', s):
        args, e = deep._args(s, m.end())
        out.append((m.start(), e, args))
    return out


def _rewrite_calls(s, name, fn):
    """s with every call name(args) replaced by fn(args) (a string, or None to keep it); the arguments first
    (nested calls of name rewritten inside out)."""
    if name + '(' not in s:
        return s
    out, pos = [], 0
    for a, e, args in _calls(s, name):
        if a < pos:
            continue
        args = [_rewrite_calls(x, name, fn) for x in args]
        new = fn(args)
        if new is None:
            new = name + '(' + ', '.join(args) + ')'
        out.append(s[pos:a] + new)
        pos = e
    out.append(s[pos:])
    return ''.join(out)


# ---- the children lists: B twins -------------------------------------------------------------------------------

def list_btwins(t):
    """t with, for each encx_spec-like def (+dx: Nat, +hdx: dx < 30, +hL: X <= 4 2^dx), its B twin <name>B
    (+B: Nat, +hB: B < 2^31, +hL: X <= B); and for each record list's szx_<p> (dd-based), szxB_<p>(A, N, h32)."""
    out = []
    for name, kind, a, b in _blocks(t):
        if kind != 'def':
            continue
        blk = t[a:b]
        hdr = deep._hdr(blk)
        m = re.search(r'\+dx: Nat, \+hdx: \{Nat\.is_lt\(dx, 30n\) == True\{\} : Bool\},\s*\+hL: \{Nat\.is_le\((.*), A\.quad\(VB\.pw\(dx\)\)\) == True\{\} : Bool\}\)', hdr, re.S)
        if m and f'def {name}B(' not in t:
            X = m.group(1)
            nb = blk.replace(f'def {name}(', f'def {name}B(', 1)
            nb = nb.replace(m.group(0), '+B: Nat, +hB: {Nat.is_lt(B, VB.pw(31n)) == True{} : Bool},\n    +hL: {Nat.is_le(' + X + ', B) == True{} : Bool})', 1)
            nb = _rewrite_calls(nb, 'VBZ.fitq', lambda g: f'VBZ.fitsB({g[1]}, B, hL, hB)' if g[0] == 'dx' else None)
            assert not re.search(r'\bdx\b|\bhdx\b', nb), (name, [l for l in nb.split('\n') if re.search(r'\bdx\b', l)][:2])
            out.append('\n' + nb.rstrip('\n') + '\n')
        ms = re.fullmatch(r'szx_(\w+)W', name)
        if ms and f'def szxB_{ms.group(1)}(' not in t:
            p = ms.group(1)
            ps, _ = deep._args(blk, blk.index('(') + 1)
            A_, N_ = ps[0].lstrip('+').split(':')[0], ps[1].lstrip('+').split(':')[0]
            ret = re.search(r'\) -> (\{.*?\}):\n', blk, re.S).group(1)
            LLt = re.search(r'== (LL_\w+\(.*?\)) : Nat\}$', ret).group(1)
            body = blk[len(deep._hdr(blk)):]
            ym = re.search(r'VRX\.yl32\(q, r, ' + re.escape(LLt) + r', hl32\)', body)
            assert ym, (name, body[:200])
            body = body.replace(ym.group(0), 'h32')
            out.append(f'\n# szx_{p} with its bytes below 2^32 (no tree): the OKW twins\' size.\n'
                       f'def szxB_{p}({ps[0]}, {ps[1]}, +h32: {{Nat.is_lt({LLt}, FD.spec_common__pow2(32n)) == True{{}} : Bool}}) -> {ret}:\n'
                       + body.rstrip('\n') + '\n')
    return t.rstrip('\n') + '\n' + ''.join(out) if out else t


# ---- the container ifaces -------------------------------------------------------------------------------------

def _okt_line(t, name):
    m = re.search(r'^def ' + name + r'\((.*?)\) -> Bool: (.*)$', t, re.M)
    return m


def okw_iface(t, child_okw, olaws=OLAWS, keep=False):
    """The container iface t with its OKW twins. child_okw: the aliases (with the dot) of the children container
    ifaces that have OKW. Returns (text, bad): bad lists the uses of k this pass does not handle."""
    bad = []
    m = _okt_line(t, 'OKT')
    if not m or 'def OKTW(' in t:
        return t, bad
    OPS = m.group(1)
    OAS = ', '.join(p.lstrip('+').split(':')[0].strip() for p in deep._args(OPS + ')', 0)[0])
    ENDC = f'ENDC({OAS})'

    def child_ok(s):
        for al in child_okw:
            s = re.sub(r'(?<![\w.])' + re.escape(al) + r'OK\(', al + 'OKW(', s)
        return s

    ENDX = re.search(r'^def ENDC\(.*?\) -> Nat: (.*)$', t, re.M).group(1)
    ms = re.fullmatch(r'ENDCs\((.*), (\d+n)\)', ENDX)
    if ms:   # (U32 mode: ENDC is ENDCs at its fixed size)
        sb = re.search(r'^def ENDCs\(.*?, \+F: Nat\) -> Nat: (.*)$', t, re.M).group(1)
        ENDX = re.sub(r'(?<![\w.])F(?![\w.])', ms.group(2), sb)

    def bound(s):
        # the bytes' bound: ENDC <= 4 2^28 becomes ENDC < 2^31 (ENDC by name)
        return s.replace(f'Nat.is_le({ENDX}, A.quad(VB.pw(28n)))', f'Nat.is_lt({ENDC}, VB.pw(31n))')
    body = bound(child_ok(m.group(2)))
    new = [f'\n# ---- OKW: the encoding below 2^31 bytes (the object API\'s limit: O.padd\'s poison bit), the children OKW ----\n'
           f'def OKTW({OPS}) -> Bool: {body}\n']
    # the extractors (okrN, ok_*): one-line defs on +h: {OKT(...)}
    ext = []
    for name, kind, a, b in _blocks(t):
        blk = t[a:b]
        if kind == 'def' and re.match(r'(okr\d+|ok_\w+)$', name) and '+h: {OKT(' in blk.split('\n')[0]:
            ext.append(name)
    chain = []
    for name, kind, a, b in _blocks(t):
        blk = t[a:b]
        if kind == 'def' and K28 in deep._hdr(blk) and name != 'okbk':
            chain.append(name)

    # the other consumers of OKT (lenE and kin): twins on OKTW (the dify twin goW: changed in place below)
    cons = []
    for name, kind, a, b in _blocks(t):
        blk = t[a:b]
        if (kind == 'def' and '+h: {OKT(' in deep._hdr(blk) and name not in ext and name not in chain and name != 'okbk'
                and not name.endswith('W') and name + 'W' not in {x for x, _, _, _ in _blocks(t)}):
            cons.append(name)

    def rw(s, in_chain):
        s = child_ok(s)
        s = s.replace('{OKT(', '{OKTW(')
        s = bound(s)
        for n in ext + cons:
            s = re.sub(r'(?<![\w.])' + n + r'\(', n + 'W(', s)
        # the chains: drop k, ek (or 28n, {==}) and rename
        for n in chain:
            def cf(g, n=n):
                for i in range(len(g) - 1):
                    if g[i:i + 2] in (['k', 'ek'], ['28n', '{==}']):
                        return f'{n}W(' + ', '.join(g[:i] + g[i + 2:]) + ')'
                return None
            s = _rewrite_calls(s, n, cf)
        s = _rewrite_calls(s, 'okbk', lambda g: f'FD.nat__le_refl({ENDC})' if g[-2:] in (['k', 'ek'], ['28n', '{==}']) else None)
        s = _rewrite_calls(s, 'CS.pstep', lambda g: 'CS.pstepB(' + ', '.join(g[:4] + [ENDC, f'ok_bndW({OAS}, h)'] + g[6:]) + ')'
                           if g[4] == 'k' and g[5] == 'CS.hk29(k, ek)' else None)
        s = _rewrite_calls(s, 'CS.fitc', lambda g: 'CS.fitcB(' + ', '.join(g[:3] + [ENDC, f'ok_bndW({OAS}, h)'] + g[5:]) + ')'
                           if g[3:5] == ['k', 'ek'] else None)
        # children: containers' OKW laws (a wide child's size module: its sizez / validx O laws, okw_size); lists' B twins
        if 'sizex' in olaws:
            s = re.sub(r'(?<![\w.])(ES_\w+)\.(sizez|sizex|validx|szs)\(', r'\1.\2O(', s)
        for al in child_okw:
            for law in olaws:
                s = _rewrite_calls(s, al + law, lambda g, al=al, law=law: f'{al}{law}O(' + ', '.join(g) + ')')
        # the lists' encx_spec (k, CS.hk30(k, ek), bound) and szx (2n+k, CS.ek2(k, ek), bound)
        for mm in set(re.findall(r'(?<![\w.])(\w+\.encx_spec\w*)\(', s)):
            s = _rewrite_calls(s, mm, lambda g, mm=mm: f'{mm}B(' + ', '.join(g[:-3] + [ENDC, f'ok_bndW({OAS}, h)', g[-1]]) + ')'
                               if len(g) >= 3 and g[-3] == 'k' and g[-2] == 'CS.hk30(k, ek)' else None)
        for al in set(re.findall(r'(?<![\w.])(\w+)\.szx\(', s)):
            def szs(g, al=al):
                if len(g) == 6 and g[3] == '2n+k' and g[4] == 'CS.ek2(k, ek)':
                    return (f'{al}.szxS({g[0]}, {g[1]}, {g[2]}, FD.nat__le_lt_trans({al}.LL({g[0]}, {g[1]}), {ENDC}, VB.pw(31n), {g[5]}, '
                            f'ok_bndW({OAS}, h)))')
                return None
            s = _rewrite_calls(s, al + '.szx', szs)
        for mm in set(re.findall(r'(?<![\w.])(\w+\.szx_\w+)\(', s)):
            def szb(g, mm=mm):
                if len(g) == 7 and g[4] == 'k' and g[5] == 'CS.hk29(k, ek)' and g[6].startswith('VRX.nwn_le('):
                    nw, _ = deep._args(g[6], len('VRX.nwn_le('))
                    al, p = mm.split('.szx_')
                    return f'{al}.szxB_{p}({g[0]}, {g[1]}, CS.lt32B({nw[0]}, {ENDC}, {nw[2]}, ok_bndW({OAS}, h)))'
                return None
            s = _rewrite_calls(s, mm, szb)
        s = s.replace('A.quad(VB.pw(k))', ENDC)
        return s

    # the extractors' twins
    for n in ext:
        a, b = _block_text(t, n)
        blk = t[a:b]
        nb = blk.replace(f'def {n}(', f'def {n}W(', 1)
        nb = rw(nb, False)
        new.append(nb.rstrip('\n') + '\n')
    assert 'ok_bnd' in ext
    for n in chain:
        a, b = _block_text(t, n)
        blk = t[a:b]
        nb = blk.replace(f'def {n}(', f'def {n}W(', 1).replace(', ' + K28, '')
        nb = rw(nb, True)
        for l in nb.split('\n'):
            if re.search(r'(?<![\w.])(k|ek)(?![\w.])', l) and not l.lstrip().startswith('#'):
                bad.append((n + 'W', l.strip()[:160]))
        new.append('\n' + nb.rstrip('\n') + '\n')
    for n in cons:
        a, b = _block_text(t, n)
        nb = rw(t[a:b].replace(f'def {n}(', f'def {n}W(', 1), False)
        for n2 in cons:
            nb = re.sub(r'(?<![\w.])' + n2 + r'\(', n2 + 'W(', nb) if n2 != n else nb
        new.append('\n' + nb.rstrip('\n') + '\n')
    # (before the interface's type MW, in dependency order: every def declared before its first use)
    new = _topo(''.join(new))
    ti = t.find('\ntype MW is Data:')
    ci = t.rfind('\n# ', 0, ti) if ti >= 0 else -1
    at = ci + 1 if ci >= 0 and t[ci:ti].count('\n') <= 2 else (ti + 1 if ti >= 0 else len(t))
    t = t[:at] + new.lstrip('\n') + '\n' + t[at:]
    # OKW(m)
    mo = re.search(r'^def OK\(m: MW\) -> Bool:\n(.*?)\n(?=\S)', t + '\n#', re.M | re.S)
    if mo:
        okw_def = mo.group(0).replace('def OK(m: MW)', 'def OKW(m: MW)', 1).replace('OKT(', 'OKTW(')
        t = t.replace(mo.group(0), mo.group(0) + okw_def, 1)
    # goO: goW on OKTW (its hs31 from OKTW's bound), the writer's putxO
    ab = _block_text(t, 'goW')
    if ab:
        a, b = ab
        blk = t[a:b]
        nb = blk.replace('def goW(', 'def goO(', 1).replace('+h: {OKT(', '+h: {OKTW(', 1)
        mh = re.search(r' \+hs31: \{Nat\.is_lt\((.*?), VB\.pw\(31n\)\) == True\{\} : Bool\},', nb)
        if mh:
            X = mh.group(1)
            nb = nb.replace(mh.group(0), '', 1)
            hdr = deep._hdr(nb)
            body = nb[len(hdr):]
            for n in ext:
                body = re.sub(r'(?<![\w.])' + n + r'\(', n + 'W(', body)
            body = child_ok(body)
            if child_okw:   # (the writer's children on OKW: its putxO)
                body = re.sub(r'(?<![\w.])K\.putxW\(', 'K.putxO(', body)
            hs = (f'  +hs31 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(31n)) == True{{}} : Bool}}, {ENDC}, {X}, '
                  f'Equal.sym(Nat, {X}, {ENDC}, lenEW({OAS}, h)), ok_bndW({OAS}, h))\n')
            t = t[:b] + '\n' + (hdr + hs + body).rstrip('\n') + '\n' + t[b:]
        else:
            bad.append(('goW', 'no hs31'))
    # the E helpers (U32 mode: the laws' bodies go through putxEW / putx_bytesEW): O copies on OKW, no hs31
    for law, base in (('putxEO', 'putxEW'), ('putx_bytesEO', 'putx_bytesEW')):
        ab = _block_text(t, base)
        if not ab:
            continue
        a, b = ab
        nb = t[a:b].replace(f'def {base}(', f'def {law}(', 1)
        nb = re.sub(r', \+hs31: \{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', '', nb, count=1)
        nb = nb.replace('{OK(m) == True{} : Bool}', '{OKW(m) == True{} : Bool}')
        nb = _rewrite_calls(nb, 'goW', lambda g: 'goO(' + ', '.join(x for x in g if x != 'hs31' and 'hs31' not in x) + ')')
        t = t[:b] + '\n' + nb.rstrip('\n') + '\n' + t[b:]
    # the laws on OKW: putxO / putx_bytesO (no hs31: from OKW), szxO, encx_specO
    for law, base in (('putxO', 'putxW'), ('putx_bytesO', 'putx_bytesW')):
        ab = _block_text(t, base)
        if not ab:
            continue
        a, b = ab
        blk = t[a:b]
        nb = blk.replace(f'law {base}:', f'law {law}:', 1).replace(f'def {base}(', f'def {law}(', 1)
        nb = re.sub(r'\n  for \+hs31: [^\n]*', '', nb, count=1)
        nb = nb.replace('  for +hok: {OK(m) == True{} : Bool}', '  for +hok: {OKW(m) == True{} : Bool}', 1)
        nb = re.sub(r'(def ' + law + r'\([^)]*?), hs31(, )', r'\1\2', nb, count=1)
        nb = _rewrite_calls(nb, 'goW', lambda g: 'goO(' + ', '.join(x for x in g if x != 'hs31') + ')')
        for eb in ('putxEW', 'putx_bytesEW'):
            nb = _rewrite_calls(nb, eb, lambda g, eb=eb: eb[:-1] + 'O(' + ', '.join(x for x in g if 'hs31' not in x) + ')')
        t = t[:b] + '\n' + nb.rstrip('\n') + '\n' + t[b:]
    for law in olaws:
        ab = _block_text(t, law)
        if not ab or f'law {law}O:' in t or '{OK(m) == True{} : Bool}' not in t[ab[0]:ab[1]]:
            continue
        # (U32 mode: the law's body is its E helper's; the helper's O copy first)
        eab = _block_text(t, law + 'E')
        if eab and '{OK(m) == True{} : Bool}' in t[eab[0]:eab[1]]:
            a, b = eab
            ne = t[a:b].replace(f'def {law}E(', f'def {law}EO(', 1).replace('{OK(m) == True{} : Bool}', '{OKW(m) == True{} : Bool}')
            ne = rw(ne, False)
            t = t[:b] + '\n' + ne.rstrip('\n') + '\n' + t[b:]
            ab = _block_text(t, law)
        a, b = ab
        blk = t[a:b]
        nb = blk.replace(f'law {law}:', f'law {law}O:', 1).replace(f'def {law}(', f'def {law}O(', 1)
        nb = nb.replace('{OK(m) == True{} : Bool}', '{OKW(m) == True{} : Bool}')
        nb = re.sub(r'(?<![\w.])' + law + r'E\(', law + 'EO(', nb)
        nb = rw(nb, False)
        for l in nb.split('\n'):
            if re.search(r'(?<![\w.])(k|ek)(?![\w.])', l):
                bad.append((law + 'O', l.strip()[:160]))
        t = t[:b] + '\n' + nb.rstrip('\n') + '\n' + t[b:]
    # only the twins the O laws reach
    created = {'OKTW'} | {n + 'W' for n in ext + chain + cons}
    bl = {n: t[a:b] for n, k, a, b in _blocks(t)}
    # (keep: and the extractors and lenEW, the size modules' O laws read them: okw_size)
    reach, st = set(), (['goO', 'putxO', 'putx_bytesO', 'putxEO', 'putx_bytesEO'] + [x + 'EO' for x in olaws] + [x + 'O' for x in olaws]
                        + ([n + 'W' for n in ext] + ['lenEW'] if keep else []))
    while st:
        n = st.pop()
        if n in reach or n not in bl:
            continue
        reach.add(n)
        st.extend(x for x in re.findall(r'(?<![\w.])(\w+)\(', bl[n]) if x in bl)
    for n in sorted(created - reach):
        ab = _block_text(t, n)
        if ab:
            t = t[:ab[0]] + t[ab[1]:]
    return t, bad


def okw_writer(t, child_okw):
    """A container writer's O twins: its W twins that meet a child container (its OK, putxW, putx_bytesW, szx) or an
    O twin, copied as <name without W>O with the children on OKW (OKW, putxO, putx_bytesO, szxO)."""
    if not child_okw:
        return t
    tb = deep._twin_blocks(t)
    names = [n for n, _, _, _ in tb]
    pat = '|'.join(re.escape(al) + r'(?:OK|putxW|putx_bytesW|szx)\(' for al in child_okw)
    aff = {n for n, _, a, b in tb if re.search(pat, t[a:b])}
    changed = True
    while changed:
        changed = False
        for n, _, a, b in tb:
            if n not in aff and any(re.search(r'(?<![\w.])' + re.escape(m) + r'\(', t[a:b]) for m in aff):
                aff.add(n)
                changed = True
    oname = lambda n: n[:-1] + 'O'  # noqa: E731
    new = []
    for n, kind, a, b in tb:
        if n not in aff:
            continue
        ab = _block_text(t, n)
        blk = t[ab[0]:ab[1]]
        blk = blk.replace(f'def {n}(', f'def {oname(n)}(', 1).replace(f'law {n}:', f'law {oname(n)}:', 1)
        for al in child_okw:
            blk = re.sub(r'(?<![\w.])' + re.escape(al) + r'OK\(', al + 'OKW(', blk)
            for law in ('putx', 'putx_bytes'):
                # the child's O law: no hs31 (its OKW bounds its bytes); hs31 follows hl (argument 11)
                blk = _rewrite_calls(blk, al + law + 'W', lambda g, al=al, law=law: f'{al}{law}O(' + ', '.join(g[:11] + g[12:]) + ')' if len(g) == 15 else None)
            blk = re.sub(r'(?<![\w.])' + re.escape(al) + r'szx\(', al + 'szxO(', blk)
        for m in aff:
            blk = re.sub(r'(?<![\w.])' + re.escape(m) + r'\(', oname(m) + '(', blk)
        new.append(blk)
    return t.rstrip('\n') + '\n' + _topo('\n' + '\n'.join(new))

def _topo(seg):
    """The defs of seg in dependency order (a def after the defs it calls), comments kept with their def."""
    blocks = [(n, seg[x:y]) for n, k, x, y in deep._blocks(seg)]
    head = seg[:deep._blocks(seg)[0][2]] if blocks else seg
    names = {n for n, _ in blocks}
    deps = {n: set(re.findall(r'(?<![\w.])(\w+)\(', blk)) & names - {n} for n, blk in blocks}
    order, done = [], set()

    def visit(n):
        if n in done:
            return
        done.add(n)
        for d in sorted(deps[n]):
            visit(d)
        order.append(n)
    for n, _ in blocks:
        visit(n)
    bd = dict(blocks)
    return head + ''.join('\n' + bd[n].strip('\n') + '\n' for n in order)


# ==== the size modules (codegen/var_cont_top.py: big_encx_<C>_size, the runtime's size and validity passes) ====
SLAWS = ('sizex', 'szs', 'sizez', 'validx')


def okw_size(t, child_okw, es_aliases):
    """A size module's O laws (sizexO, szsO, sizezO, validxO on CI.OKW): its chains on CI.OKTW with the bound
    B = ENDC (ENDC <= ENDC, ENDC < 2^31: CI.ok_bndW). child_okw: the children container ifaces with OKW (their
    sizex / validx / szx: the O laws); es_aliases: the children's size modules (sizez / validx: the O laws).
    Returns (text, bad): bad lists the uses of k this pass does not handle."""
    bad = []
    if 'law sizexO:' in t or 'def SZS(' not in t:
        return t, bad
    hdr = deep._hdr(t[t.index('\ndef SZS(') + 1:])
    OAS = ', '.join(p.lstrip('+').split(':')[0].strip() for p in deep._args(hdr, hdr.index('(') + 1)[0])
    B = f'CI.ENDC({OAS})'
    BND = f'CI.ok_bndW({OAS}, h)'
    tw = [n for n, kind, a, b in _blocks(t) if kind == 'def' and '{CI.OKT(' in deep._hdr(t[a:b])]
    chain = [n for n in tw if K28 in deep._hdr(t[slice(*_block_text(t, n))])]

    def children(s):
        for al in child_okw:
            s = re.sub(r'(?<![\w.])' + re.escape(al) + r'(OK|sizex|validx|szx)\(', lambda mm: al + mm.group(1) + ('W(' if mm.group(1) == 'OK' else 'O('), s)
        for al in es_aliases:
            s = re.sub(r'(?<![\w.])' + re.escape(al) + r'(sizez|validx|sizex|szs)\(', lambda mm: al + mm.group(1) + 'O(', s)
        return s

    def rw(s):
        s = s.replace('{CI.OKT(', '{CI.OKTW(')
        s = children(s)
        s = re.sub(r'(?<![\w.])CI\.(ok_\w+)\(', lambda mm: f'CI.{mm.group(1)}W(', s)
        s = re.sub(r'(?<![\w.])CI\.lenE\(', 'CI.lenEW(', s)
        for n in tw:
            def cf(g, n=n):
                for i in range(len(g) - 1):
                    if g[i:i + 2] in (['k', 'ek'], ['28n', '{==}']):
                        return f'{n}W(' + ', '.join(g[:i] + g[i + 2:]) + ')'
                return f'{n}W(' + ', '.join(g) + ')'
            s = _rewrite_calls(s, n, cf)
        s = _rewrite_calls(s, 'CI.okbk', lambda g: f'FD.nat__le_refl({B})' if g[-2:] == ['k', 'ek'] else None)
        s = re.sub(r'\n  \+hk = FD\.logic__subst\(Nat, z => \{Nat\.is_lt\(z, 29n\) == True\{\} : Bool\}, 28n, k, Equal\.sym\(Nat, k, 28n, ek\), \{==\}\)', '', s)
        s = s.replace('A.quad(VB.pw(k))', B)
        # O.padd below 2^31
        s = _rewrite_calls(s, 'VCN.padd_dd', lambda g: (f'VCN.padd_ddW({g[0]}, {g[1]}, 0n, {{==}}, FD.nat__le_lt_trans(Nat.add(U32.to_nat({g[0]}), U32.to_nat({g[1]})), '
                                                        f'{B}, VB.pw(31n), {g[4]}, {BND}))') if g[2:4] == ['k', 'hk'] else None)
        # a record list's bytes (i * RS): below 2^32
        s = _rewrite_calls(s, 'VRX.mulq', lambda g: (f'VRX.mulqW({", ".join(g[1:7])}, CS.lt32B(A.quad(Nat.mul({g[2]}, {g[4]})), {B}, {g[8]}, {BND}))')
                           if g[0] == 'k' and g[7] == 'hk' else None)
        # the lists' sizes: szs / szx at 2 + k (their strict S forms), szx_<p> at k (szxB_<p>)
        for mm in set(re.findall(r'(?<![\w.])(\w+)\.szs\(', s)):
            s = _rewrite_calls(s, mm + '.szs', lambda g, mm=mm: (f'{mm}.szsS({g[0]}, {g[1]}, {g[2]}, FD.nat__le_lt_trans({mm}.LL({g[0]}, {g[1]}), {B}, VB.pw(31n), {g[5]}, {BND}))')
                               if len(g) == 6 and g[3] == 'Nat.add(2n, k)' else None)
        for mm in set(re.findall(r'(?<![\w.])(\w+)\.szx\(', s)):
            s = _rewrite_calls(s, mm + '.szx', lambda g, mm=mm: (f'{mm}.szxS({g[0]}, {g[1]}, {g[2]}, FD.nat__le_lt_trans({mm}.LL({g[0]}, {g[1]}), {B}, VB.pw(31n), {g[5]}, {BND}))')
                               if len(g) == 6 and g[3] in ('2n+k', 'Nat.add(2n, k)') else None)
        for mm in set(re.findall(r'(?<![\w.])(\w+\.szx_\w+)\(', s)):
            def szb(g, mm=mm):
                if len(g) == 7 and g[4] == 'k' and g[5] == 'CS.hk29(k, ek)' and g[6].startswith('VRX.nwn_le('):
                    nw, _ = deep._args(g[6], len('VRX.nwn_le('))
                    al, p = mm.split('.szx_')
                    return f'{al}.szxB_{p}({g[0]}, {g[1]}, CS.lt32B({nw[0]}, {B}, {nw[2]}, {BND}))'
                return None
            s = _rewrite_calls(s, mm, szb)
        return s

    new = []
    for n in tw:
        a, b = _block_text(t, n)
        nb = t[a:b].replace(f'def {n}(', f'def {n}W(', 1).replace(', ' + K28, '')
        nb = rw(nb)
        for l in nb.split('\n'):
            if re.search(r'(?<![\w.])(k|ek|hk)(?![\w.])', l) and not l.lstrip().startswith('#'):
                bad.append((n + 'W', l.strip()[:200]))
        new.append('\n' + nb.rstrip('\n') + '\n')
    for law in SLAWS:
        ab = _block_text(t, law)
        if not ab:
            continue
        nb = t[ab[0]:ab[1]].replace(f'law {law}:', f'law {law}O:', 1).replace(f'def {law}(', f'def {law}O(', 1)
        nb = nb.replace('{CI.OK(m) == True{} : Bool}', '{CI.OKW(m) == True{} : Bool}')
        for l2 in SLAWS:
            nb = re.sub(r'(?<![\w.])' + l2 + r'\(', l2 + 'O(', nb)
        nb = re.sub(r'(?<![\w.])CI\.szx\(', 'CI.szxO(', nb)
        nb = rw(nb)
        new.append('\n' + nb.rstrip('\n') + '\n')
    head = ('\n# ---- OKW: the laws on CI.OKW (the encoding below 2^31 bytes; codegen/okw.py okw_size), the chains with the bound '
            'ENDC ----\n')
    return t.rstrip('\n') + '\n' + head + _topo(''.join(new)), bad


# ==== companions: the O laws in their own module (<m>_o), so that only their callers check them ====
CALIAS = 'OB'   # (the companion's alias of its base module)


def _names(t):
    return {n for n, k, a, b in _blocks(t)} | set(re.findall(r'^type (\w+)', t, re.M))


def okw_companion(base, full, stem, what):
    """The companion module of base (proofs/obj/<stem>.bend): the blocks of full that base lacks, the base's
    names in them qualified (OB.name), with the base's imports and the base itself as OB."""
    have = _names(base)
    def own(s, n):
        ab = _block_text(s, n)
        return s[ab[0]:ab[1]] if ab else ''
    bl = [(n, own(full, n)) for n, k, a, b in _blocks(full) if n not in have and k != 'lawonly']
    # (the blocks of both: the same text, or the companion would read a different one)
    diff = [n for n, k, a, b in _blocks(full) if n in have and k != 'lawonly' and own(full, n).strip() != own(base, n).strip()]
    if diff:
        raise SystemExit(f'okw_companion: {stem}: blocks that differ from the base: {diff[:5]}')
    if not bl:
        return None
    mine = {n for n, _ in bl}
    pat = re.compile(r'(?<![\w.+])(' + '|'.join(sorted((re.escape(x) for x in have - mine), key=len, reverse=True)) + r')(?![\w])(?!\s*=[^=>])')
    body = ''.join('\n' + pat.sub(lambda m: CALIAS + '.' + m.group(1), blk).strip('\n') + '\n' for _, blk in bl)
    imps = [ln for ln in base.split('\n') if ln.startswith('import ')]
    head = '\n'.join(imps + [f'import ./{stem}.bend as {CALIAS}', '',
                             f'# GENERATED (codegen/okw.py okw_companion). Do not edit.',
                             f'# {what}', ''])
    return head + '\n' + _topo(body).lstrip('\n')


def okw_relink(t, comps):
    """t's calls of a name its import (./<stem>.bend as AL) lacks but that module's companion (comps: stem -> its
    names) has: through the companion (ALo), imported next to it."""
    for m in list(re.finditer(r'^import \./(\w+)\.bend as (\w+)$', t, re.M)):
        stem, al = m.group(1), m.group(2)
        if stem not in comps:
            continue
        names = comps[stem]
        t2 = re.sub(r'(?<![\w.])' + re.escape(al) + r'\.(\w+)(?=[({])', lambda mm: (al + 'o.' + mm.group(1)) if mm.group(1) in names else mm.group(0), t)
        if t2 != t:
            t = t2
            line = f'import ./{stem}_o.bend as {al}o'
            if line not in t:
                t = t.replace(m.group(0), m.group(0) + '\n' + line, 1)
    return t
