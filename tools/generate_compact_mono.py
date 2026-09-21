#!/usr/bin/env python3
"""Generate the monotonicity proof of proofs/compact/cvm.bend's M.

`M(t, d, 1n+g, job)` is a type built from `&`, `If`, `Shallow`, `VarStep`,
atoms (`Is(..)`, `Unit`, `Empty`) and recursive `M(t, d, g, J)` occurrences.
Lifting it to level 2 + g is structural: every recursive occurrence is mapped
by the induction hypothesis and every connective by its map lemma
(proofs/compact/cvm_mono.bend). This script parses each clause of M's
definition and writes the corresponding proof term, so the proof follows the
definition exactly; Bend checks every step.

    python3 tools/generate_compact_mono.py
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'proofs/compact/cvm.bend'
OUT = ROOT / 'proofs/compact/cvm_mono_gen.bend'


def split_top(s, sep):
    out, depth, cur, i = [], 0, '', 0
    while i < len(s):
        ch = s[i]
        if ch in '([{':
            depth += 1
        elif ch in ')]}':
            depth -= 1
        if depth == 0 and s.startswith(sep, i):
            out.append(cur.strip())
            cur = ''
            i += len(sep)
            continue
        cur += ch
        i += 1
    out.append(cur.strip())
    return out


def strip_parens(s):
    s = s.strip()
    while s.startswith('(') and s.endswith(')'):
        depth = 0
        ok = True
        for i, ch in enumerate(s):
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
                if depth == 0 and i != len(s) - 1:
                    ok = False
                    break
        if not ok:
            break
        s = s[1:-1].strip()
    return s


def call(s):
    """(head, args) if s is `head(args)` at top level, else None."""
    s = s.strip()
    m = re.match(r'^([A-Za-z_][A-Za-z0-9_.]*)\((.*)\)$', s, re.S)
    if not m:
        return None
    head, inner = m.group(1), m.group(2)
    # make sure the outer parens match
    depth = 0
    for i, ch in enumerate(s[len(head):]):
        if ch in '([{':
            depth += 1
        elif ch in ')]}':
            depth -= 1
            if depth == 0 and i != len(s[len(head):]) - 1:
                return None
    return head, split_top(inner, ',')


def lift(s):
    """The type at the higher level: recursive M's at g become 1n+g."""
    return s.replace('M(t, d, g, ', 'M(t, d, 1n+g, ')


def mapper(e):
    """A lambda mapping a proof of e (level g) to a proof of lift(e)."""
    e = strip_parens(e)
    parts = split_top(e, '&')
    if len(parts) > 1:
        a, b = parts[0], ' & '.join(parts[1:])
        fa, fb = mapper(a), mapper(b)
        if fa is None and fb is None:
            return None
        return f'y => V2.both({a}, {b}, {lift(a)}, {lift(b)}, {fa or "z => z"}, {fb or "z => z"}, y)'
    c = call(e)
    if c is None:
        return None
    head, args = c
    head = head[2:] if head.startswith('V.') else head
    if head == 'M':
        return f'y => m_mono(t, d, g, {args[3]}, y)'
    if head == 'If':
        cond, a, b = args
        fa, fb = mapper(a), mapper(b)
        if fa is None and fb is None:
            return None
        return f'y => V2.if_map({cond}, {a}, {b}, {lift(a)}, {lift(b)}, {fa or "z => z"}, {fb or "z => z"}, y)'
    if head == 'Shallow':
        r, a = args
        fa = mapper(a)
        if fa is None:
            return None
        return f'y => V2.shallow_map({r}, {a}, {lift(a)}, {fa}, y)'
    if head == 'VarStep':
        last, child, cend, endp, a, b, r = args
        return (f'y => V2.varstep_map({last}, {child}, {cend}, {endp}, {a}, {b}, {r}, {lift(a)}, {lift(b)}, {lift(r)}, '
                f'{mapper(a) or "z => z"}, {mapper(b) or "z => z"}, {mapper(r) or "z => z"}, y)')
    return None


def qualify(s):
    """Names of cvm.bend used unqualified inside it get the module alias."""
    s = re.sub(r'(?<![A-Za-z0-9_.])(If|Is|Shallow|VarStep|M|el_at|var_at|pad_ok|tail_ok|list_head_ok|b8|r32)\(', r'V.\1(', s)
    s = re.sub(r'(?<![A-Za-z0-9_.])(Node|Rep|VEl|W8|W15|W16)\{', r'V.\1{', s)
    return s


def clauses(text):
    """The `case` clauses of M's `1n+ +g` branch: (job pattern, schema pattern or None, body)."""
    start = text.index('def M(')
    end = text.index('\ndef CVm(')
    body = text[start:end]
    body = body[body.index('    case 1n+ +g:'):]
    lines = body.split('\n')
    out = []
    job, cs, cur = None, None, None
    for line in lines[2:]:
        m_job = re.match(r'^        case (V?\.?[A-Za-z0-9]+\{.*\}):\s*$', line)
        m_cs = re.match(r'^            case (S\.[A-Za-z0-9]+\{.*\}|_):(.*)$', line)
        if m_job:
            if cur is not None:
                out.append((job, cs, '\n'.join(cur)))
            job, cs, cur = m_job.group(1), None, []
        elif m_cs:
            if cur is not None and cs is not None:
                out.append((job, cs, '\n'.join(cur)))
            elif cur is not None and cur and cs is None and job.startswith('Node'):
                pass
            cs, cur = m_cs.group(1), [m_cs.group(2)]
        elif line.startswith('          match cs:'):
            cur = []
        elif cur is not None and line.strip() and not line.strip().startswith('#'):
            cur.append(line)
    out.append((job, cs, '\n'.join(cur)))
    return out


def main():
    text = SRC.read_text()
    lines = ['import Base',
             'import ../../src/cschema.bend as S',
             'import ../../src/cscan.bend as C',
             'import ./found.bend as F',
             'import ./reads.bend as Rd',
             'import ./cvm.bend as V',
             'import ./cvm_mono.bend as V2',
             '',
             '# GENERATED by tools/generate_compact_mono.py from proofs/compact/cvm.bend.',
             '# M is monotone in its level.',
             '',
             'def m_mono(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, job: V.Job, x: V.M(t, d, h, job)) -> V.M(t, d, 1n+h, job):',
             '  match h:',
             '    case 0n:',
             '      match job:',
             '        case V.Rep{+elem, +left, +off, +stride}: V2.zero_rep(t, d, elem, Nat.is_eq(left, 0n), off, stride, left, {==}, x)',
             '        case V.VEl{+elem, +i, +n, +base, +endp}: V2.zero_vel(t, d, elem, Nat.is_eq(i, n), i, n, base, endp, {==}, x)',
             '        case V.Node{cs, a, b}:',
             '          match x:',
             '        case V.W8{fields, i, cnt, base, endp, fp, pend, start, has}:',
             '          match x:',
             '        case V.W15{fields, i, cnt, base, endp, fp, pend, start, v}:',
             '          match x:',
             '        case V.W16{fields, i, cnt, base, v}:',
             '          match x:',
             '    case 1n+ +g:',
             '      match job:']
    node_cases = []
    for job, cs, body in clauses(text):
        body = qualify(' '.join(x.strip() for x in body.split('\n')).strip())
        f = mapper(body)
        proof = f'({f})(x)' if f else 'x'
        if job.startswith('Node'):
            if cs == '_':
                node_cases.append(('_', None))
            else:
                node_cases.append((cs, proof))
        else:
            lines.append(f'        case V.{job}: {proof}')
    lines.append('        case V.Node{cs, +a, +b}:')
    lines.append('          match cs:')
    for cs, proof in node_cases:
        if cs == '_':
            for k in ['S.CFLeaf{f, hoff, hsize, fixed}', 'S.CFNode{lo, hi, split}', 'S.CFNone{}']:
                lines.append(f'            case {k}:')
                lines.append('              match x:')
        else:
            lines.append(f'            case {cs}: {proof}')
    OUT.write_text('\n'.join(lines) + '\n')
    print(OUT.relative_to(ROOT), len(lines), 'lines')


if __name__ == '__main__':
    main()
