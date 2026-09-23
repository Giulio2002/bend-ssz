"""Word-level equations proved bit by bit.

A law `{A(x) == B(x) : U32}` over a variable word x is proved by casing x on its
32 bits: both sides then normalize to words `U32{WCon{l0, ..}}` and
`U32{WCon{r0, ..}}` whose bits are Bool expressions over the bit variables
a0..a31 (`Bool.and(a7, True{})`, `Bool.or(.., Bool.and(a23, False{}))`, ...).
`proofs/compact/bits.bend` `word32_eq` then needs one equation `l_i == r_i` per
bit, and each of those is proved by casing the few bit variables it mentions.

The bit expressions are read off the checker's own normal form once (`refresh`
runs `bend` on a probe) and kept in codegen/bit_residuals.json, so that
generation is deterministic and needs no checker. Nothing is trusted: a wrong
or stale residual only makes the emitted proof fail to check.
"""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STORE = ROOT / 'codegen/bit_residuals.json'
BEND = '/Users/monkeair/.bend/bin/bend'
BITS = [f'a{i}' for i in range(32)]


def word(bits):
    s = 'WNil{}'
    for b in reversed(bits):
        s = f'WCon{{{b}, {s}}}'
    return f'U32{{{s}}}'


def split_word(s):
    s = s.strip()
    assert s.startswith('U32{WCon{'), s[:60]
    s = s[4:]
    out = []
    while s.startswith('WCon{'):
        s = s[5:]
        depth = 0
        for i, ch in enumerate(s):
            if ch in '({':
                depth += 1
            elif ch in ')}':
                depth -= 1
            elif ch == ',' and depth == 0:
                out.append(s[:i].strip())
                s = s[i + 1:].strip()
                break
    assert len(out) == 32, len(out)
    return out


def load():
    return json.loads(STORE.read_text()) if STORE.exists() else {}


def refresh(key, imports, lhs, rhs):
    """Probe the checker for the bit normal forms of `lhs == rhs` (x cased)."""
    probe = ROOT / 'build/bitfix' / f'{key}.bend'
    probe.parent.mkdir(parents=True, exist_ok=True)
    rel = lambda p: '../../' + p
    src = ['import Base'] + [f'import {rel(p)} as {a}' for p, a in imports]
    src += ['', f'def probe(+x: U32) -> {{{lhs} == {rhs} : U32}}:', '  match x:', f'    case {word(BITS)}: {{==}}', '']
    probe.write_text('\n'.join(src))
    r = subprocess.run([BEND, probe.name], cwd=probe.parent, capture_output=True, text=True,
                       env={'BEND_NO_TELEMETRY': '1', 'BUN_JSC_forceRAMSize': '3000000000', 'PATH': '/usr/bin:/bin'})
    out = r.stdout + r.stderr
    if 'All terms check.' in out:
        l = r_ = [None] * 32
        # the two sides are already the same term
        return {'lhs': 'same', 'rhs': 'same'}
    e = re.search(r'- expected : (.*)', out).group(1)
    o = re.search(r'- observed : (.*)', out).group(1)
    return {'lhs': split_word(e), 'rhs': split_word(o)}


def vars_of(expr):
    return sorted(set(re.findall(r'\ba(\d+)\b', expr)), key=int)


def emit(w, name, sig, lhs, rhs, res):
    """Emit `def {name}(+x: U32) -> {lhs == rhs : U32}` from residuals `res`."""
    if res['lhs'] == 'same':
        w(f'def {name}(+x: U32) -> {{{lhs} == {rhs} : U32}}:')
        w('  match x:')
        w(f'    case {word(BITS)}: {{==}}')
        return
    L, R = res['lhs'], res['rhs']
    for i in range(32):
        vs = vars_of(L[i] + ' ' + R[i])
        w(f'def {name}_b{i}(' + ', '.join(f'+a{v}: Bool' for v in vs) + f') -> {{{L[i]} == {R[i]} : Bool}}:')
        if not vs:
            w('  {==}')
            continue

        def cases(k, ind):
            if k == len(vs):
                w(f'{ind}{{==}}')
                return
            w(f'{ind}match a{vs[k]}:')
            for c in ('True{}', 'False{}'):
                w(f'{ind}  case {c}:')
                cases(k + 1, ind + '    ')
        cases(0, '  ')
    w(f'def {name}(+x: U32) -> {{{lhs} == {rhs} : U32}}:')
    w('  match x:')
    w(f'    case {word(BITS)}:')
    proofs = ', '.join(f'{name}_b{i}(' + ', '.join(f'a{v}' for v in vars_of(L[i] + ' ' + R[i])) + ')' for i in range(32))
    w(f'      BT.word32_eq({", ".join(L)}, {", ".join(R)}, {proofs})')
