"""Containers of byte-offset uint fields (the generic Container(uint8),
Container(uint16, uint16), Container(uint8, uint64, uint32) and the progressive
container of one uint8): part of codegen/proofs/laws/sub_laws.py.

Expressions are small ASTs: ('v', name) | ('c', int) | ('or', a, b) | ('and', a, c)
| ('mul', a, c) | ('shrn', a, k) | ('shln', a, k) | ('join', j, lo, hi) | ('bsel', k, a).
"""
from codegen.core.bendtext import wp  # noqa: E402
from codegen.proofs.support import bitsim as BS

MULK = {256: ('WM.mul256', 8), 65536: ('WM.mul65536', 16), 16777216: ('WM.mul16777216', 24)}


def src(e, hole=None, path=()):
    if hole is not None and path == hole:
        return '_'
    t = e[0]
    sub = lambda i: src(e[i], hole, path + (i,))
    if t == 'v':
        return e[1]
    if t == 'c':
        return str(e[1])
    if t == 'or':
        return f'U32.or({sub(1)}, {sub(2)})'
    if t == 'and':
        return f'U32.and({sub(1)}, {e[2]})'
    if t == 'mul':
        return f'U32.mul({sub(1)}, {e[2]})'
    if t == 'shrn':
        return f'U32.shrn({sub(1)}, {e[2]}n)'
    if t == 'shln':
        return f'U32.shln({sub(1)}, {e[2]}n)'
    if t == 'join':
        return f'B.join_sel({e[1]}, {sub(2)}, {sub(3)})'
    if t == 'bsel':
        return f'B.byte_sel({e[1]}, {sub(2)})'
    raise ValueError(t)


def subst(e, env):
    if e[0] == 'v':
        return ('v', env.get(e[1], e[1]))
    return tuple(subst(x, env) if isinstance(x, tuple) else x for x in e)


def bits(e, words):
    """The bits of e, words: var -> bit list."""
    t = e[0]
    if t == 'v':
        return words[e[1]]
    if t == 'c':
        return BS.const(e[1])
    if t == 'or':
        return BS.or_(bits(e[1], words), bits(e[2], words))
    if t == 'and':
        return BS.and_(bits(e[1], words), BS.const(e[2]))
    if t == 'shrn':
        return BS.shrn(bits(e[1], words), e[2])
    if t == 'shln':
        return BS.shln(bits(e[1], words), e[2])
    if t == 'join':
        j, lo, hi = e[1], bits(e[2], words), bits(e[3], words)
        return BS.or_(BS.shrn(lo, 8 * j), BS.shln(hi, 32 - 8 * j))
    if t == 'bsel':
        x = bits(e[2], words)
        return BS.shrn(x, 24) if e[1] == 3 else BS.and_(BS.shrn(x, 8 * e[1]), BS.const(255))
    raise ValueError(t)


def vars_of(e, acc=None):
    acc = [] if acc is None else acc
    if e[0] == 'v':
        if e[1] not in acc:
            acc.append(e[1])
    else:
        for x in e[1:]:
            if isinstance(x, tuple):
                vars_of(x, acc)
    return acc


def muls(e, path=()):
    """Paths of the mul nodes, innermost first."""
    out = []
    for i, x in enumerate(e):
        if isinstance(x, tuple):
            out += muls(x, path + (i,))
    if e[0] == 'mul':
        out.append(path)
    return out


def at(e, path):
    for i in path:
        e = e[i]
    return e


def put(e, path, new):
    if not path:
        return new
    i = path[0]
    return tuple(put(x, path[1:], new) if j == i else x for j, x in enumerate(e))


class Prover:
    """Equalities of U32 expressions over free words, proved bit by bit."""
    def __init__(self, prefix):
        self.L = BS.Lemmas(prefix + '_b')
        self.lines = []
        self.n = 0
        self.prefix = prefix

    def eq(self, lhs, rhs):
        """A def name proving {src(lhs) == src(rhs) : U32} for all its variables."""
        self.n += 1
        name = f'{self.prefix}_e{self.n}'
        vs = vars_of(lhs, vars_of(rhs))
        top = []
        w = top.append
        # rewrite the multiplications by 2^8k into shifts first (they are stuck on a word
        # whose bits are variables)
        cur = lhs
        steps = []
        for p in muls(lhs):
            node = at(cur, p)
            lem, k = MULK[node[2]]
            steps.append((p, node, lem, k, cur))
            cur = put(cur, p, ('shln', node[1], k))
        sig = ', '.join(f'+{v}: U32' for v in vs)
        if steps:
            w(f'def {name}({sig}) -> {{{src(lhs)} == {src(rhs)} : U32}}:')
            state = lhs
            for p, node, lem, k, before in steps:
                w(f'  %Equal.sym(U32, {src(node)}, U32.shln({src(node[1])}, {k}n), {lem}({src(node[1])})) :')
                w(f'    {{{src(state, hole=p)} == {src(rhs)} : U32}}')
                state = put(state, p, ('shln', node[1], k))
            w(f'  {name}b({", ".join(vs)})')
            w('')
            name_b = f'{name}b'
        else:
            name_b = name
        # the bit-level proof, every variable a bit pattern
        w = self.lines.append
        env = {v: [f'{v}b{i}' for i in range(32)] for v in vs}
        pats = {v: wp(env[v]) for v in vs}
        L2 = subst(cur, {})
        lb = bits(cur, env)
        rb = bits(rhs, env)
        ql, pl = self.L.word_eq(lb)
        qr, pr = self.L.word_eq(rb)
        if ql != qr:
            raise ValueError(f'not equal: {src(cur)} vs {src(rhs)}\n{ql}\n{qr}')
        Q = wp(ql)
        ls = src(subst_src(cur, pats))
        rs = src(subst_src(rhs, pats))
        w(f'def {name_b}({sig}) -> {{{src(cur)} == {src(rhs)} : U32}}:')
        w(f'  match {" ".join(vs)}:')
        w(f'    case {" ".join(pats[v] for v in vs)}:')
        lp = pl or '{==}'
        rp = pr or '{==}'
        w(f'      Equal.trans(U32, {ls}, {Q}, {rs}, {lp}, Equal.sym(U32, {rs}, {Q}, {rp}))')
        w('')
        self.lines += top
        return name


def subst_src(e, pats):
    if e[0] == 'v':
        return ('v', pats.get(e[1], e[1]))
    return tuple(subst_src(x, pats) if isinstance(x, tuple) else x for x in e)
