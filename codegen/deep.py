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
