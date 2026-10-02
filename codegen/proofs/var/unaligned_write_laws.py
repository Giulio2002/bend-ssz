#!/usr/bin/env python3
"""The unaligned-offset WRITE layer: the byte structure of the words the runtime's
writers OR into the output at a byte offset X = 4 q + s (s = 1, 2, 3).

    python3 codegen/proofs/var/unaligned_write_laws.py [--check]

proofs/obj/vuw_bits.bend (generated here, stock). Every lemma is proved by computing
each output bit symbolically (the words are taken apart into their 32 bits) and
closing every bit position by a case split over the few bits it mentions; a
hypothesis about a word's bytes is taken apart into facts about its bits first.
With SHL_s(x) = x << 8 s, SHR_s(x) = x >> (32 - 8 s), M_s the mask of the low s
bytes and H_s the mask of the high 4 - s bytes:

  zl_s   bytes s..3 of w are zero                 ->  w == w & M_s
  zh_s   bytes 0..s-1 of w are zero               ->  w == w & H_s
  zw     all four bytes of w are zero             ->  w == 0
  blo_s  the limbs of (d & M_s) | (SHL_s(x) | (c & M_s)): the low s limbs of
         (d & M_s) | (c & M_s), then limbs 0..3-s of x   (a word the writer fills
         after the s bytes already there)
  bhi_s  limbs s..3 of d | (c & M_s) are those of d
  blz_s  limbs 0..s-1 of (d & H_s) | c are those of c
  car_s  limbs 0..s-1 of SHR_s(x) are limbs 4-s..3 of x
  cm_s   SHR_s(x) == SHR_s(x) & M_s
  or0r   x | 0 == x
  orc    a | b == b | a

proofs/obj/vuw.bend (hand-written): the writers' tree and list models (ORW, ORS, SWc, SWL)
and the tree model's words (swc_slots). proofs/obj/vuw<s>.bend (generated here, s = 1, 2, 3):
the list model's bytes (swlb): writing ws at byte s of the first of the words W splices
their limbs into W's bytes there, when those bytes were zero.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys
from codegen.core import generated_file_writer as writer  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('unaligned_write_laws', globals())
OUT = ROOT / 'proofs/obj/vuw_bits.bend'

T, F = ('T',), ('F',)
MS = {1: 255, 2: 65535, 3: 16777215}
HS = {1: 4294967040, 2: 4294901760, 3: 4278190080}


def v(n):
    return ('var', n)


def b_and(x, y):
    if x == T:
        return y
    if x == F:
        return F
    return ('and', x, y)


def b_or(x, y):
    if x == T:
        return T
    if x == F:
        return y
    return ('or', x, y)


def const(c):
    return [T if (c >> i) & 1 else F for i in range(32)]


def w_and(xs, ys):
    return [b_and(x, y) for x, y in zip(xs, ys)]


def w_or(xs, ys):
    return [b_or(x, y) for x, y in zip(xs, ys)]


def shrn(xs, k):
    return xs[k:] + [F] * k


def shln(xs, k):
    return [F] * k + xs[:32 - k]


def limb(xs):
    return [w_and(xs, const(255)), w_and(shrn(xs, 8), const(255)), w_and(shrn(xs, 16), const(255)), shrn(xs, 24)]


def bits(name):
    return [v(f'{name}{i}') for i in range(32)]


def show(e):
    if e == T:
        return 'True{}'
    if e == F:
        return 'False{}'
    if e[0] == 'var':
        return e[1]
    op = 'Bool.and' if e[0] == 'and' else 'Bool.or'
    return f'{op}({show(e[1])}, {show(e[2])})'


def vars_of(e, acc):
    if e[0] == 'var':
        if e[1] not in acc:
            acc.append(e[1])
    elif e[0] in ('and', 'or'):
        vars_of(e[1], acc)
        vars_of(e[2], acc)
    return acc


def rename(e, mp):
    if e[0] == 'var':
        return v(mp[e[1]])
    if e[0] in ('and', 'or'):
        return (e[0], rename(e[1], mp), rename(e[2], mp))
    return e


def subst(e, mp):
    """e with the variables of mp replaced by constants (and re-reduced)."""
    if e[0] == 'var':
        return mp.get(e[1], e)
    if e[0] == 'and':
        return b_and(subst(e[1], mp), subst(e[2], mp))
    if e[0] == 'or':
        return b_or(subst(e[1], mp), subst(e[2], mp))
    return e


def word(bs):
    return 'U32{' + ''.join(f'WCon{{{show(b)}, ' for b in bs) + 'WNil{}' + '}' * len(bs) + '}'


def pat(name):
    return 'U32{' + ''.join(f'WCon{{+{name}{i}, ' for i in range(32)) + 'WNil{}' + '}' * 32 + '}'


class Gen:
    def __init__(self):
        self.L = []
        self.cases = {}

    def w(self, s=''):
        self.L.append(s)

    # a proof of {x == y : Bool} for two bit expressions
    def pos(self, x, y, facts=None):
        """facts: {var: proof of {var == False{} : Bool}} usable by the case split."""
        if x == y:
            return '{==}'
        vs = vars_of(y, vars_of(x, []))
        mp = {n: f'a{i}' for i, n in enumerate(vs)}
        key = (show(rename(x, mp)), show(rename(y, mp)))
        fv = [n for n in vs if facts and n in facts]
        key = key + (tuple(mp[n] for n in fv),)
        if key not in self.cases:
            name = f'bk{len(self.cases)}'
            self.cases[key] = (name, rename(x, mp), rename(y, mp), [mp[n] for n in vs], [mp[n] for n in fv])
        name = self.cases[key][0]
        return f'{name}({", ".join(vs)}{"".join(", " + facts[n] for n in fv)})'

    def emit_cases(self):
        out = []
        for key, (name, x, y, vs, fv) in self.cases.items():
            hs = ''.join(f', +h{a}: {{{a} == False{{}} : Bool}}' for a in fv)
            out.append(f'def {name}({", ".join(f"+{a}: Bool" for a in vs)}{hs}) -> {{{show(x)} == {show(y)} : Bool}}:')
            out.extend(self.split(x, y, vs, fv, 1, {}))
            out.append('')
        return out

    def split(self, x, y, vs, fv, ind, env):
        pad = '  ' * ind
        if x == y:
            return [pad + '{==}']
        if not vs:
            raise ValueError(f'position not closed: {show(x)} vs {show(y)}')
        a, rest = vs[0], vs[1:]
        out = [pad + f'match {a}:']
        for val, c in (('True{}', T), ('False{}', F)):
            out.append(pad + f'  case {val}:')
            if a in fv and c == T:
                out.append(pad + f'    Empty.absurd({{{show(subst(x, {a: c}))} == {show(subst(y, {a: c}))} : Bool}}, FD.logic__true_false(h{a}))')
                continue
            out.extend(self.split(subst(x, {a: c}), subst(y, {a: c}), rest, fv, ind + 2, env))
        return out

    def weq(self, xs, ys, facts=None):
        return ('UB.weq(' + ', '.join(show(b) for b in xs) + ', ' + ', '.join(show(b) for b in ys) + ', '
                + ', '.join(self.pos(x, y, facts) for x, y in zip(xs, ys)) + ')')

    def l4(self, xw, yw, facts=None):
        return ('UB.l4(' + ', '.join(word(b) for b in xw) + ', ' + ', '.join(word(b) for b in yw) + ', '
                + ', '.join(self.weq(a, b, facts) for a, b in zip(xw, yw)) + ')')

    def lk(self, xw, yw, facts=None):
        """A proof that two lists of len(xw) words are equal, word by word."""
        k = len(xw)
        if k == 4:
            return self.l4(xw, yw, facts)
        return f'L{k}(' + ', '.join(word(b) for b in xw) + ', ' + ', '.join(word(b) for b in yw) + ', ' + ', '.join(self.weq(a, b, facts) for a, b in zip(xw, yw)) + ')'


def emit():
    g = Gen()
    w = g.w
    head = ['import Base', 'import ../../src/primitives.bend as I', 'import ../compact/found.bend as FD', 'import ./vspec.bend as VS',
            'import ./vua_bits.bend as UB', 'import ./word_mul.bend as WM', '',
            '# GENERATED by unaligned_write_laws (codegen). Do not edit.',
            '# The byte structure of the words the runtime ORs into its output at an unaligned', '# byte offset (see codegen/proofs/var/unaligned_write_laws.py).', '']
    # list equalities of 1..3 words
    for k in (1, 2, 3):
        xs = [f'x{i}' for i in range(k)]
        ys = [f'y{i}' for i in range(k)]
        lst = lambda zs: '[' + ', '.join(zs) + ']'  # noqa: E731
        w(f'def L{k}(' + ', '.join(f'+{a}: U32' for a in xs + ys) + ', ' + ', '.join(f'+e{i}: {{x{i} == y{i} : U32}}' for i in range(k))
          + f') -> {{{lst(xs)} == {lst(ys)} : +List<U32>}}:')
        for i in range(k):
            cur = ys[:i] + ['_'] + xs[i + 1:]
            w(f'  %Equal.sym(U32, x{i}, y{i}, e{i}) : {{{lst(cur)} == {lst(ys)} : +List<U32>}}')
        w('  {==}')
        w('')
    # bit projections
    for i in range(32):
        p = 'U32{' + ''.join('WCon{_, ' for _ in range(i)) + 'WCon{+b, _}' + '}' * i + '}'
        w(f'def B{i}(+x: U32) -> Bool:')
        w('  match x:')
        w(f'    case {p}: b')
        w('')
    w('def EL(xs: +List<U32>, k: Nat) -> U32:')
    w('  match xs:')
    w('    case Nil{}: 0')
    w('    case Con{h, t}:')
    w('      match k:')
    w('        case 0n: h')
    w('        case 1n+p: EL(t, p)')
    w('')
    W = bits('w')
    X = bits('x')
    C = bits('c')
    Dd = bits('d')
    A = bits('a')
    Bb = bits('b')
    zero = const(0)

    def zs(k):
        return '[' + ', '.join(['0'] * k) + ']'

    def hyp_facts(hname, lhs_words, rhs_words, list_expr_l, list_expr_r):
        """Proofs of {var == False} for every bit the hypothesis pins (bit i of word j of the list)."""
        facts = {}
        lines = []
        for j, (lw, rw) in enumerate(zip(lhs_words, rhs_words)):
            for i in range(32):
                lb = lw[i]
                if lb in (T, F) or (lb[0] == 'and' and lb[2] == F):
                    continue
                assert rw[i] == F
                vs = vars_of(lb, [])
                assert len(vs) == 1, lb
                a = vs[0]
                if a in facts:
                    continue
                e = f'Equal.cong(+List<U32>, Bool, z => B{i}(EL(z, {j}n)), {list_expr_l}, {list_expr_r}, {hname})'
                # e : {lb == False}; lb is a, or Bool.and(a, True{})
                pf = e if lb == v(a) else f'Equal.trans(Bool, {a}, {show(lb)}, False{{}}, {g.pos(v(a), lb)}, {e})'
                nm = f'f{a}'
                lines.append(f'      +{nm} = {pf}')
                facts[a] = nm
        return facts, lines

    for s in (1, 2, 3):
        sh, up = 8 * s, 32 - 8 * s
        M, H = MS[s], HS[s]
        # zl: bytes s..3 zero -> w == w & M
        lw = limb(W)[s:]
        w(f'# Bytes {s}..3 of w are zero: w keeps only its low {s} byte{"s" if s > 1 else ""}.')
        w(f'def zl{s}(+w: U32, +h: {{VS.bdr({s}n, I.limb(w)) == {zs(4 - s)} : +List<U32>}}) -> {{w == U32.and(w, {M}) : U32}}:')
        w('  match w:')
        w(f'    case {pat("w")}:')
        facts, lines = hyp_facts('h', lw, [zero] * (4 - s), f'VS.bdr({s}n, I.limb({word(W)}))', zs(4 - s))
        g.L.extend(lines)
        w('      ' + g.weq(W, w_and(W, const(M)), facts))
        w('')
        lw = limb(W)[:s]
        w(f'# Bytes 0..{s - 1} of w are zero: w keeps only its high {4 - s} byte{"s" if 4 - s > 1 else ""}.')
        w(f'def zh{s}(+w: U32, +h: {{VS.bt({s}n, I.limb(w)) == {zs(s)} : +List<U32>}}) -> {{w == U32.and(w, {H}) : U32}}:')
        w('  match w:')
        w(f'    case {pat("w")}:')
        facts, lines = hyp_facts('h', lw, [zero] * s, f'VS.bt({s}n, I.limb({word(W)}))', zs(s))
        g.L.extend(lines)
        w('      ' + g.weq(W, w_and(W, const(H)), facts))
        w('')
        # blo
        dm, cm = w_and(Dd, const(M)), w_and(C, const(M))
        lhs = limb(w_or(dm, w_or(shln(X, sh), cm)))
        rhs = limb(w_or(dm, cm))[:s] + limb(X)[:4 - s]
        w(f'# A word filled after its low {s} byte{"s" if s > 1 else ""}: those bytes, then limbs 0..{3 - s} of x.')
        w(f'def blo{s}(+d: U32, +x: U32, +c: U32) -> {{I.limb(U32.or(U32.and(d, {M}), U32.or(U32.shln(x, {sh}n), U32.and(c, {M})))) == '
          f'List.append(&2, U32, VS.bt({s}n, I.limb(U32.or(U32.and(d, {M}), U32.and(c, {M})))), VS.bt({4 - s}n, I.limb(x))) : +List<U32>}}:')
        w('  match d x c:')
        w(f'    case {pat("d")} {pat("x")} {pat("c")}:')
        w('      ' + g.l4(lhs, rhs))
        w('')
        # bhi
        lhs = limb(w_or(Dd, cm))[s:]
        rhs = limb(Dd)[s:]
        w(f'# OR-ing a word of low {s} byte{"s" if s > 1 else ""} leaves limbs {s}..3 alone.')
        w(f'def bhi{s}(+d: U32, +c: U32) -> {{VS.bdr({s}n, I.limb(U32.or(d, U32.and(c, {M})))) == VS.bdr({s}n, I.limb(d)) : +List<U32>}}:')
        w('  match d c:')
        w(f'    case {pat("d")} {pat("c")}:')
        w('      ' + g.lk(lhs, rhs))
        w('')
        # blz
        lhs = limb(w_or(w_and(Dd, const(H)), C))[:s]
        rhs = limb(C)[:s]
        w(f'# Into a word whose low {s} byte{"s are" if s > 1 else " is"} zero, an OR puts limbs 0..{s - 1} of c.')
        w(f'def blz{s}(+d: U32, +c: U32) -> {{VS.bt({s}n, I.limb(U32.or(U32.and(d, {H}), c))) == VS.bt({s}n, I.limb(c)) : +List<U32>}}:')
        w('  match d c:')
        w(f'    case {pat("d")} {pat("c")}:')
        w('      ' + g.lk(lhs, rhs))
        w('')
        # car
        lhs = limb(shrn(X, up))[:s]
        rhs = limb(X)[4 - s:]
        w(f'# The carry of a word at byte {s}: its low limbs are the word\'s top {s}.')
        w(f'def car{s}(+x: U32) -> {{VS.bt({s}n, I.limb(U32.shrn(x, {up}n))) == VS.bdr({4 - s}n, I.limb(x)) : +List<U32>}}:')
        w('  match x:')
        w(f'    case {pat("x")}:')
        w('      ' + g.lk(lhs, rhs))
        w('')
        w(f'def cm{s}(+x: U32) -> {{U32.shrn(x, {up}n) == U32.and(U32.shrn(x, {up}n), {M}) : U32}}:')
        w('  match x:')
        w(f'    case {pat("x")}:')
        w('      ' + g.weq(shrn(X, up), w_and(shrn(X, up), const(M))))
        w('')
    # tail zeros: x >> 8R == 0 (O.tail_zero for R = n & 3)
    def u32_facts(hname, sh):
        facts, lines = {}, []
        for i in range(32 - sh):
            a = f'x{i + sh}'
            e = f'Equal.cong(U32, Bool, z => B{i}(z), U32.shrn({word(X)}, {sh}n), 0, {hname})'
            lines.append(f'      +f{a} = {e}')
            facts[a] = f'f{a}'
        return facts, lines
    for R in (1, 2, 3):
        w(f'# Bytes {R}..3 of x are zero (x >> {8 * R} == 0): its limbs are its first {R}, then zeros.')
        w(f'def tzl{R}(+x: U32, +h: {{U32.shrn(x, {8 * R}n) == 0 : U32}}) -> {{I.limb(x) == List.append(&2, U32, VS.bt({R}n, I.limb(x)), {zs(4 - R)}) : +List<U32>}}:')
        w('  match x:')
        w(f'    case {pat("x")}:')
        facts, lines = u32_facts('h', 8 * R)
        g.L.extend(lines)
        w('      ' + g.l4(limb(X), limb(X)[:R] + [zero] * (4 - R), facts))
        w('')
        for s2 in (1, 2, 3):
            if s2 + R > 4:
                continue
            w(f'# ... and its top {s2} byte{"s" if s2 > 1 else ""} (the carry of a write at byte {s2}) are zero.')
            w(f'def tzc{s2}{R}(+x: U32, +h: {{U32.shrn(x, {8 * R}n) == 0 : U32}}) -> {{U32.shrn(x, {32 - 8 * s2}n) == 0 : U32}}:')
            w('  match x:')
            w(f'    case {pat("x")}:')
            facts, lines = u32_facts('h', 8 * R)
            g.L.extend(lines)
            w('      ' + g.weq(shrn(X, 32 - 8 * s2), zero, facts))
            w('')
    # a byte OR-ed in at byte s: limb s of w gains the byte, the others stay
    V = bits('v')
    vb = w_and(V, const(255))
    for s2 in (0, 1, 2, 3):
        x = vb if s2 == 0 else shln(vb, 8 * s2)
        xs = 'U32.and(v, 255)' if s2 == 0 else f'U32.shln(U32.and(v, 255), {8 * s2}n)'
        lw = limb(W)
        rw = [lw[j] if j != s2 else w_or(lw[j], vb) for j in range(4)]
        names = ['U32.and(w, 255)', 'U32.and(U32.shrn(w, 8n), 255)', 'U32.and(U32.shrn(w, 16n), 255)', 'U32.shrn(w, 24n)']
        names[s2] = f'U32.or({names[s2]}, U32.and(v, 255))'
        w(f'# The byte v OR-ed in at byte {s2} of w.')
        w(f'def orbl{s2}(+w: U32, +v: U32) -> {{I.limb(U32.or(w, {xs})) == [{", ".join(names)}] : +List<U32>}}:')
        w('  match w v:')
        w(f'    case {pat("w")} {pat("v")}:')
        w('      ' + g.l4(limb(w_or(W, x)), rw))
        w('')
    # zw
    lw = limb(W)
    w('# All four bytes of w are zero: w is zero.')
    w(f'def zw(+w: U32, +h: {{I.limb(w) == {zs(4)} : +List<U32>}}) -> {{w == 0 : U32}}:')
    w('  match w:')
    w(f'    case {pat("w")}:')
    facts, lines = hyp_facts('h', lw, [zero] * 4, f'I.limb({word(W)})', zs(4))
    g.L.extend(lines)
    w('      ' + g.weq(W, zero, facts))
    w('')
    w('def or0r(+x: U32) -> {U32.or(x, 0) == x : U32}:')
    w('  match x:')
    w(f'    case {pat("x")}:')
    w('      ' + g.weq(w_or(X, zero), X))
    w('')
    w('def orc(+a: U32, +b: U32) -> {U32.or(a, b) == U32.or(b, a) : U32}:')
    w('  match a b:')
    w(f'    case {pat("a")} {pat("b")}:')
    w('      ' + g.weq(w_or(A, Bb), w_or(Bb, A)))
    w('')
    body = g.L
    return '\n'.join(head + ['# ---- one-bit cases ' + '-' * 70, ''] + g.emit_cases() + body) + '\n'


SWLB = TEMPLATES.text('SWLB')


# The open model's bytes (its carry out dropped): only the first 4 |ws| - s bytes of the
# words' limbs land, up to the end of the last word written.
SWLBO = TEMPLATES.text('SWLBO')

def swlb_text(s):
    """proofs/obj/vuw<s>.bend: the list model's bytes at byte s (swlb)."""
    M, H, MUL = MS[s], HS[s], 256 ** s
    zs = 'UW.ZB(k)'
    for _ in range(s):
        zs = 'Con{0, ' + zs + '}'
    rep = {'@Sn': f'{s}n', '@Rn': f'{4 - s}n', '@SHn': f'{8 * s}n', '@UPn': f'{32 - 8 * s}n', '@MUL': str(MUL), '@M': str(M), '@H': str(H),
           '@PL': 's' if s > 1 else '', '@ZS': zs, '@S': str(s)}
    t = SWLB + SWLBO
    for k in sorted(rep, key=len, reverse=True):
        t = t.replace(k, rep[k])
    return t


# the fixed-size values the runtime writes word by word (b<p>_pw<s>): prefix, constructor, words
FIXW = [('b32', 'Bytes32', 8), ('b20', 'Bytes20', 5), ('u256', 'Uint256', 8)]
# the others, one module per writer (proofs/obj/vuwf<s>_<p>.bend), so a user imports only its own
FIXW1 = [('b48', 'Bytes48', 12), ('b96', 'Bytes96', 24), ('bv512', 'Bitvector512', 16), ('bv64', 'Bitvector64', 2), ('b4', 'Bytes4', 1)]
# the generic types' (types/generic_obj.bend) full-word vectors
FIXWG = [('bv256', 'Bitvector256', 8)]


def fixw_text(s, writers=None, tmod='fulu_obj'):
    """proofs/obj/vuwf<s>.bend: the runtime's writers of FIXW at byte s of word i are the
    model SWc (putu_<p>), when the value's bytes there were zero: the first word's OR, the
    interior stores as vuw.RS2 over the literal offsets 1 .. N - 1 (vuw.rs2_swo: the open model SWo), the carry's or_skip."""
    MUL, UP, Rn = 256 ** s, 32 - 8 * s, 4 - s
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', 'import ../compact/found.bend as FD',
         'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
         'import ./vua.bend as UA', 'import ./vuw_bits.bend as UWB', 'import ./vuw.bend as UW', '',
         '# GENERATED by unaligned_write_laws (codegen). Do not edit.',
         f'# The runtime\'s word-by-word writers at byte {s} of a word: the tree model SWc (see codegen/proofs/var/unaligned_write_laws.py).', '']
    TH = 'FD.array__thaw(U32, {})'
    for p, cons, N in (FIXW if writers is None else writers):
        ws = [f'w{k}' for k in range(N)]
        m = 4 * N
        M4 = 4 * (N - 1)
        q = 'U32.shrn(pos, 2n)'
        v0 = f'U32.mul(w0, {MUL})'
        carry = f'U32.shrn(w{N - 1}, {UP}n)'
        WS1 = '[' + ', '.join(ws[1:]) + ']'
        JS = '[' + ', '.join(str(k) for k in range(1, N)) + ']'
        model = f'UW.SWc({s}, [{", ".join(ws)}], dd, U, i, 0)'
        RHS = TH.format(model)
        SW = f'UW.SWo({s}, {WS1}, dd, D1, Nat.add(1n, i), O.shr_over(w0, {s}))'
        Dm = f'UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, {s}), 0))'
        SWm = f'UW.SWo({s}, {WS1}, dd, {Dm}, 1n+i, O.shr_over(w0, {s}))'
        sig = (f'def putu_{p}(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, ' + ', '.join(f'+{w}: U32' for w in ws) + TEMPLATES.render('fixw_text', s=s, N=N, m=m, p=p, TH=TH, cons=cons, ws=ws, RHS=RHS))
        L.append(f'# {p} at byte {s} of word i.')
        L.append(sig)
        L.append(f'  +e3 = UW.ua_3(pos, i, {s}n, {s}, {{==}}, e, {{==}})')
        L.append(f'  +eq = UW.ua_q(pos, i, {s}n, e, {{==}})')
        L.append('  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})')
        L.append(f'  +hi0 = UW.lt_off(0n, {N}n, i, VB.pw(dd), {{==}}, hl)')
        L.append(f'  +eq0 = VB.add_at({q}, 0, i, dd, eq, hd32, hi0)')
        L.append(f'  +D1 = UW.ORW(dd, U, i, {v0})')
        L.append(f'  +pf1 = UW.orw_perfect(dd, U, i, {v0}, pf)')
        L.append('  +X0 = Nat.add(A.quad(i), ' + f'{s}n)')
        L.append('  +B = UA.BYT(U)')
        # the zero words after the first: bytes 4 + 4 i .. 4 i + 4 N of U, then of D1
        L.append(f'  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, {Rn}n), FD.nat__add_comm(4n, A.quad(i)),')
        L.append(f'    Equal.sym(Nat, Nat.add(X0, {Rn}n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), {s}n, {Rn}n)))')
        L.append(f'  +zU = Equal.trans(+List<U32>, VS.bt({M4}n, VS.bdr(4n+A.quad(i), B)), VS.bt({M4}n, VS.bdr({Rn}n, VS.bdr(X0, B))), UW.ZB({M4}n),')
        L.append(f'    Equal.trans(+List<U32>, VS.bt({M4}n, VS.bdr(4n+A.quad(i), B)), VS.bt({M4}n, VS.bdr(Nat.add(X0, {Rn}n), B)), VS.bt({M4}n, VS.bdr({Rn}n, VS.bdr(X0, B))),')
        L.append(f'      Equal.cong(Nat, +List<U32>, z => VS.bt({M4}n, VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, {Rn}n), epos),')
        L.append(f'      Equal.cong(+List<U32>, +List<U32>, z => VS.bt({M4}n, z), VS.bdr(Nat.add(X0, {Rn}n), B), VS.bdr({Rn}n, VS.bdr(X0, B)), UW.bdr_add(X0, {Rn}n, B))),')
        L.append(f'    Equal.trans(+List<U32>, VS.bt({M4}n, VS.bdr({Rn}n, VS.bdr(X0, B))), VS.bt({M4}n, VS.bdr({Rn}n, VS.bt({m}n, VS.bdr(X0, B)))), UW.ZB({M4}n),')
        L.append(f'      UW.bt_bdr_bt({M4}n, {Rn}n, {m}n, VS.bdr(X0, B), {{==}}),')
        L.append(f'      FD.logic__subst(+List<U32>, z => {{VS.bt({M4}n, VS.bdr({Rn}n, z)) == UW.ZB({M4}n) : +List<U32>}}, UW.ZB({m}n), VS.bt({m}n, VS.bdr(X0, B)),')
        L.append(f'        Equal.sym(+List<U32>, VS.bt({m}n, VS.bdr(X0, B)), UW.ZB({m}n), hz), UW.zb_win({Rn}n, {M4}n, {m}n, {{==}}))))')
        L.append(f'  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), {v0}), pf, hi0)')
        L.append(f'  +hzr = FD.logic__subst(+List<U32>, z => {{VS.bt({M4}n, z) == UW.ZB({M4}n) : +List<U32>}}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(D1)),')
        L.append(f'    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(D1)), VS.bdr(4n+A.quad(i), B), fr), zU)')
        L.append(f'  +hlr = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add({N - 1}n, 1n+i), Nat.add(1n+i, {N - 1}n), FD.nat__add_comm({N - 1}n, 1n+i),')
        L.append(f'    FD.nat__lt_le(Nat.add({N}n, i), VB.pw(dd), hl))')
        C = f'O.shr_over(w0, {s})'
        SW1 = f'UW.SWo({s}, {WS1}, dd, D1, 1n+i, {C})'
        IDX = f'Nat.add(List.length(&2, U32, {WS1}), 1n+i)'
        CRYc = f'UW.CRY({s}, {WS1}, {C})'
        L.append(f'  +rs0 = UW.rs2_swo({s}, {WS1}, {JS}, dd, D1, {q}, i, 1n, w0, eq, {{==}}, hd, pf1, hlr, hzr)')
        L.append(f'  +rs = Equal.trans(Array<U32>, UW.RS2({s}, {WS1}, {JS}, {TH.format("D1")}, {q}, w0), {TH.format(f"UW.SWo({s}, {WS1}, dd, D1, Nat.add(1n, i), {C})")}, {TH.format(SW1)}, rs0,')
        L.append(f'    Equal.cong(Nat, Array<U32>, z => {TH.format(f"UW.SWo({s}, {WS1}, dd, D1, z, {C})")}, Nat.add(1n, i), 1n+i, {{==}}))')
        L.append(f'  +pfS = UW.swo_perfect({s}, {WS1}, dd, D1, 1n+i, {C}, pf1)')
        L.append(f'  +eqN = FD.logic__subst(Nat, z => {{U32.to_nat(U32.add({q}, {N})) == z : Nat}}, Nat.add({N}n, i), {IDX}, {{==}}, VB.add_at({q}, {N}, i, dd, eq, hd32, hl))')
        L.append(f'  +hlN = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add({N}n, i), {IDX}, {{==}}, hl)')
        L.append(f'  +eos = UW.orskip_rt(dd, {SW1}, U32.add({q}, {N}), {IDX}, {CRYc}, eqN, hd32, hlN, pfS)')
        L.append(f'  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pwd(U32.is_eq(_, 0), U32.and(pos, 3), {TH.format("U")}, {q}, {", ".join(ws)}) == {RHS} : Array<U32>}}')
        L.append(f'  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pwd(U32.is_eq({s}, 0), _, {TH.format("U")}, {q}, {", ".join(ws)}) == {RHS} : Array<U32>}}')
        L.append(f'  %Equal.sym(Array<U32>, O.or_word({TH.format("U")}, U32.add({q}, 0), {v0}), {TH.format("D1")}, UW.orw_rt(dd, U, U32.add({q}, 0), i, {v0}, eq0, hd32, hi0, pf)) :')
        L.append(f'    {{O.or_skip(UW.RS2({s}, {WS1}, {JS}, _, {q}, w0), U32.add({q}, {N}), {carry}) == {RHS} : Array<U32>}}')
        L.append(f'  %Equal.sym(Array<U32>, UW.RS2({s}, {WS1}, {JS}, {TH.format("D1")}, {q}, w0), {TH.format(SW1)}, rs) :')
        L.append(f'    {{O.or_skip(_, U32.add({q}, {N}), {carry}) == {RHS} : Array<U32>}}')
        L.append(f'  %Equal.sym(Array<U32>, O.or_skip({TH.format(SW1)}, U32.add({q}, {N}), {CRYc}), {TH.format(f"UW.ORS(dd, {SW1}, {IDX}, {CRYc})")}, eos) :')
        L.append(f'    {{_ == {RHS} : Array<U32>}}')
        SWm = f'UW.SWo({s}, {WS1}, dd, {Dm}, 1n+i, {C})'
        MOD1 = f'UW.SWc({s}, {WS1}, dd, {Dm}, 1n+i, {C})'
        L.append(f'  Equal.cong(FD.array__Tree<U32>, Array<U32>, z => {TH.format("z")}, UW.ORS(dd, {SW1}, {IDX}, {CRYc}), {MOD1},')
        L.append(f'    Equal.trans(FD.array__Tree<U32>, UW.ORS(dd, {SW1}, {IDX}, {CRYc}), UW.ORS(dd, {SWm}, {IDX}, {CRYc}), {MOD1},')
        L.append(f'      Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo({s}, {WS1}, dd, UW.ORW(dd, U, i, z), 1n+i, {C}), {IDX}, {CRYc}), {v0}, U32.or(O.shl_bytes(w0, {s}), 0),')
        L.append(f'        Equal.sym(U32, U32.or({v0}, 0), {v0}, UWB.or0r({v0}))),')
        L.append(f'      Equal.sym(FD.array__Tree<U32>, {MOD1}, UW.ORS(dd, {SWm}, {IDX}, {CRYc}), UW.swc_swo({s}, {WS1}, dd, {Dm}, 1n+i, {C}))))')
        L.append('')
    return '\n'.join(L) + '\n'


PUTW = TEMPLATES.text('PUTW')


HLE_O = """
# 4 + 4 M <= 4 NW = L + @S: the words after the first lie in the first L bytes' window.
def hle_o(+M: Nat, +NW: Nat, +L: Nat, +hL: {Nat.add(L, @Sn) == A.quad(NW) : Nat}, +h: {Nat.is_le(4n+A.quad(M), A.quad(NW)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(@Rn, A.quad(M)), L) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(4n+A.quad(M), z) == True{} : Bool}, A.quad(NW), Nat.add(@Sn, L),
    Equal.trans(Nat, A.quad(NW), Nat.add(L, @Sn), Nat.add(@Sn, L), Equal.sym(Nat, Nat.add(L, @Sn), A.quad(NW), hL), FD.nat__add_comm(L, @Sn)), h)

"""

PUTWO_EQS = """  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(UW.SLW(TS))) == True{} : Bool}, NW, 1n+Nat.add(M, KN), Equal.sym(Nat, 1n+Nat.add(M, KN), NW, eNW),
    FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hnw))
  +eD = FD.logic__subst(Nat, z => {D3 == UW.SWo(@S, VS.wtake(z, UW.SLW(TS)), dd, U, i, 0) : FD.array__Tree<U32>}, 1n+Nat.add(M, KN), NW, eNW, UW.asm_o(@S, dd, U, i, UW.SLW(TS), M, KN, hLS))
  +eC = FD.logic__subst(Nat, z => {C3 == UW.CRY(@S, VS.wtake(z, UW.SLW(TS)), 0) : U32}, 1n+Nat.add(M, KN), NW, eNW, UW.asm_c(@S, dd, U, i, UW.SLW(TS), M, KN, hLS))
  +hc3 = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == True{} : Bool}, UW.CRY(@S, VS.wtake(NW, UW.SLW(TS)), 0), C3, Equal.sym(U32, C3, UW.CRY(@S, VS.wtake(NW, UW.SLW(TS)), 0), eC), hc)
"""

PUTWO_END = """  %Equal.sym(Bool, U32.is_eq(C3, 0), True{}, hc3) :
    {O.put_fin(n, O.pw_carry_skip(_, U32.add(Q, NWU), FD.array__thaw(U32, D3), FD.array__thaw(U32, TS), C3)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  Equal.cong(FD.array__Tree<U32>, Array<U32> & O.Words, z => (FD.array__thaw(U32, z), O.Words{FD.array__thaw(U32, TS), n}), D3, UW.SWo(@S, VS.wtake(NW, UW.SLW(TS)), dd, U, i, 0), eD)
"""


def _putwo(t):
    """putwu_o from putwu's text: room only for the run's own NW(n) words (i + NW <= pw),
    zero bytes only up to the end of its last word (L = 4 NW - s), and a zero carry out,
    so the write is the open model SWo (the runtime skips the zero carry)."""
    i = t.index("# The runtime's byte-range write of the n > 0 bytes")
    u = t[i:]

    def rep(a, b):
        nonlocal u
        assert a in u, a[:90]
        u = u.replace(a, b)
    rep("# The runtime's byte-range write of the n > 0 bytes held in TS at byte @S of word i\n"
        "# (pos = 4 i + @S) is the model SWc of the source's first NW(n) words, when the output's\n"
        "# bytes there were zero.",
        "# The same write when its carry out of the last word is zero: the open model SWo, with\n"
        "# room for the run's own words only and zero bytes only up to the end of its last word.")
    rep('def putwu(', 'def putwu_o(')
    rep('+hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool},\n'
        '    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(U))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>},',
        '+hl: {Nat.is_le(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool},\n'
        '    +L: Nat, +hL: {Nat.add(L, @Sn) == A.quad(VC.NW(n)) : Nat},\n'
        '    +hz: {VS.bt(L, VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(U))) == UW.ZB(L) : +List<U32>},\n'
        '    +hc: {U32.is_eq(UW.CRY(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), 0), 0) == True{} : Bool},')
    rep('UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)', 'UW.SWo(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)')
    rep('FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl)', 'hl')
    rep('+hi0 = FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl)',
        '+hi0 = FD.nat__lt_le_trans(i, Nat.add(NW, i), VB.pw(dd), FD.nat__lt_le_trans(i, 1n+i, Nat.add(NW, i), FD.nat__lt_succ(i), Order.add_right(1n, NW, i, hNW1)), hl)')
    rep('FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl), pf, pfS)', 'hi0, pf, pfS)')
    rep('+hle = FD.nat__le_trans(Nat.add(@Rn, A.quad(M)), 4n+A.quad(M), A.quad(NW), Order.add_right(@Rn, 4n, A.quad(M), {==}), UW.quad_le(1n+M, NW, h1M))',
        '+hle = hle_o(M, NW, L, hL, UW.quad_le(1n+M, NW, h1M))')
    rep('VS.bdr(@Rn, VS.bt(A.quad(NW), VS.bdr(X0, B)))', 'VS.bdr(@Rn, VS.bt(L, VS.bdr(X0, B)))')
    rep('UW.bt_bdr_bt(A.quad(M), @Rn, A.quad(NW), VS.bdr(X0, B), hle)', 'UW.bt_bdr_bt(A.quad(M), @Rn, L, VS.bdr(X0, B), hle)')
    rep('UW.ZB(A.quad(NW)), VS.bt(A.quad(NW), VS.bdr(X0, B)),\n        Equal.sym(+List<U32>, VS.bt(A.quad(NW), VS.bdr(X0, B)), UW.ZB(A.quad(NW)), hz), UW.zb_win(@Rn, A.quad(M), A.quad(NW), hle)',
        'UW.ZB(L), VS.bt(L, VS.bdr(X0, B)),\n        Equal.sym(+List<U32>, VS.bt(L, VS.bdr(X0, B)), UW.ZB(L), hz), UW.zb_win(@Rn, A.quad(M), L, hle)')
    j = u.index('  +pc = pcarry_b(')
    k = u.index('  %Equal.sym(Bool, U32.is_eq(n, 0), False{}, hn)')
    u = u[:j] + PUTWO_EQS + u[k:]
    j = u.index('  %Equal.sym(Array<U32> & Array<U32>, O.pw_carry_skip(U32.is_eq(C3, 0)')
    u = u[:j] + PUTWO_END
    return t + HLE_O + u


PUTW = _putwo(PUTW)

def putw_text(s):
    """proofs/obj/vuwp<s>.bend: O.put_words at byte s of a word is the model SWc (putwu)."""
    rep = {'@Sn': f'{s}n', '@Rn': f'{4 - s}n', '@SHn': f'{8 * s}n', '@UPn': f'{32 - 8 * s}n', '@MUL': str(256 ** s),
           '@PWMID': f'pw_mid{s}', '@PWOR': f'pw_or{s}', '@SCOPY': f'scopy{4 - s}', '@S': str(s)}
    t = PUTW
    for k in sorted(rep, key=len, reverse=True):
        t = t.replace(k, rep[k])
    return t


# byte vectors written by O.put_words when unaligned: prefix, bytes, words, words_ok_b's k and unit
WORDSF = [('b256', 256, 64, 9, 1), ('v4_b32', 128, 32, 8, 32)]


def wordsf_text(s):
    """proofs/obj/vuwk<s>.bend: the byte-vector writers <p>_putk at byte s (validity, then
    O.put_words): the model SWc of the vector's words."""
    L = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T', 'import ../compact/found.bend as FD',
         'import ../compact/arith.bend as A', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA',
         'import ./vbenc.bend as VBE', 'import ./vuw.bend as UW', f'import ./vuwp{s}.bend as UP', '',
         '# GENERATED by unaligned_write_laws (codegen). Do not edit.',
         f'# The byte-vector writers at byte {s} of a word: the tree model SWc (see codegen/proofs/var/unaligned_write_laws.py).', '']
    for p, n, W, kk, unit in WORDSF:
        OBJ = f'O.Words{{FD.array__thaw(U32, TB), {n}}}'
        RHS = f'(FD.array__thaw(U32, UW.SWc({s}, VS.wtake({W}n, UW.SLW(TB)), dd, U, i, 0)), ({OBJ}, 0))'
        TY = 'Array<U32> & (O.Words & U32)'
        L.append(TEMPLATES.render('wordsf_text', p=p, n=n, s=s, W=W, OBJ=OBJ, RHS=RHS, TY=TY, kk=kk, unit=unit))
    return '\n'.join(L) + '\n'


def outputs():
    out = {OUT: emit()}
    for s in (1, 2, 3):
        out[ROOT / f'proofs/obj/vuw{s}.bend'] = swlb_text(s)
        out[ROOT / f'proofs/obj/vuwf{s}.bend'] = fixw_text(s)
        for w in FIXW1:
            out[ROOT / f'proofs/obj/vuwf{s}_{w[0]}.bend'] = fixw_text(s, [w])
        for w in FIXWG:
            out[ROOT / f'proofs/obj/vuwf{s}_{w[0]}.bend'] = fixw_text(s, [w], 'generic_obj')
        out[ROOT / f'proofs/obj/vuwp{s}.bend'] = putw_text(s)
        out[ROOT / f'proofs/obj/vuwk{s}.bend'] = wordsf_text(s)
    return out


def main():
    out = outputs()
    from codegen.impl import runtime_file_split as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale: ', 'unaligned write layer is current')
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
