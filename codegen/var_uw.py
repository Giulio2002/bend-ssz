#!/usr/bin/env python3
"""The unaligned-offset WRITE layer: the byte structure of the words the runtime's
writers OR into the output at a byte offset X = 4 q + s (s = 1, 2, 3).

    python3 codegen/var_uw.py [--check]

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
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
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


def facts_from(h, lhs_words, rhs_words, projs):
    """Bit facts {var == False} from the hypothesis h : {lhs == rhs} over explicit word lists:
    the projection of word j, bit i is lhs bit on one side and False on the other."""
    out = {}
    for j, (lw, rw) in enumerate(zip(lhs_words, rhs_words)):
        for i in range(32):
            lb, rb = lw[i], rw[i]
            if lb == F or lb == T:
                continue
            assert rb == F, (lb, rb)
            out[(j, i)] = lb
    return out


def emit():
    g = Gen()
    w = g.w
    head = ['import Base', 'import ../../src/primitives.bend as I', 'import ../compact/found.bend as FD', 'import ./vspec.bend as VS',
            'import ./vua_bits.bend as UB', 'import ./word_mul.bend as WM', '',
            '# GENERATED by codegen/var_uw.py. Do not edit.',
            '# The byte structure of the words the runtime ORs into its output at an unaligned', '# byte offset (see codegen/var_uw.py).', '']
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


SWLB = r'''import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vuw_bits.bend as UWB
import ./vuw.bend as UW
import ./vua.bend as UA
import ./vfix.bend as VF
import ./word_mul.bend as WM
import ../../proofs/nat_order.bend as Order

# GENERATED by codegen/var_uw.py. Do not edit.
# The list model of the writers at byte @S of a word: writing ws there splices their
# limbs into the words' bytes (see codegen/var_uw.py).

# The bytes of a word written after its low @S byte@PL, when its other bytes are zero.
def e1(+h: U32, +w: U32, +c: U32, +eh: {h == U32.and(h, @M) : U32}, +hc: {c == U32.and(c, @M) : U32})
    -> {I.limb(U32.or(h, U32.or(O.shl_bytes(w, @S), c))) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))) : +List<U32>}:
  +t2 = FD.logic__subst(U32, z => {I.limb(U32.or(z, U32.or(U32.shln(w, @SHn), U32.and(c, @M)))) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(z, U32.and(c, @M)))), VS.bt(@Rn, I.limb(w))) : +List<U32>},
    U32.and(h, @M), h, Equal.sym(U32, h, U32.and(h, @M), eh), UWB.blo@S(h, w, c))
  +t3 = FD.logic__subst(U32, z => {I.limb(U32.or(h, U32.or(U32.shln(w, @SHn), z))) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, z))), VS.bt(@Rn, I.limb(w))) : +List<U32>},
    U32.and(c, @M), c, Equal.sym(U32, c, U32.and(c, @M), hc), t2)
  FD.logic__subst(U32, z => {I.limb(U32.or(h, U32.or(z, c))) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))) : +List<U32>},
    U32.shln(w, @SHn), U32.mul(w, @MUL), Equal.sym(U32, U32.mul(w, @MUL), U32.shln(w, @SHn), WM.mul@MUL(w)), t3)

# The carry of w into a word whose low @S byte@PL are zero.
def e2(+t0: U32, +w: U32, +ez: {t0 == U32.and(t0, @H) : U32})
    -> {VS.bt(@Sn, I.limb(U32.or(t0, O.shr_over(w, @S)))) == VS.bdr(@Rn, I.limb(w)) : +List<U32>}:
  +b = FD.logic__subst(U32, z => {VS.bt(@Sn, I.limb(U32.or(z, U32.shrn(w, @UPn)))) == VS.bt(@Sn, I.limb(U32.shrn(w, @UPn))) : +List<U32>},
    U32.and(t0, @H), t0, Equal.sym(U32, t0, U32.and(t0, @H), ez), UWB.blz@S(t0, U32.shrn(w, @UPn)))
  Equal.trans(+List<U32>, VS.bt(@Sn, I.limb(U32.or(t0, U32.shrn(w, @UPn)))), VS.bt(@Sn, I.limb(U32.shrn(w, @UPn))), VS.bdr(@Rn, I.limb(w)), b, UWB.car@S(w))

def base(+b: Bool, +h: U32, +t: List<&2, U32>, +c: U32, +eb: {U32.is_eq(c, 0) == b : Bool}, +hc: {c == U32.and(c, @M) : U32})
    -> {List.append(&2, U32, I.limb(UW.ORVb(b, h, c)), FX.limbs(t)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, VS.bdr(@Sn, I.limb(h)), FX.limbs(t))) : +List<U32>}:
  match b:
    case True{}:
      %Equal.sym(U32, c, 0, FD.u32alg__eq_of(c, 0, eb)) :
        {List.append(&2, U32, I.limb(h), FX.limbs(t)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, _))), List.append(&2, U32, VS.bdr(@Sn, I.limb(h)), FX.limbs(t))) : +List<U32>}
      %Equal.sym(U32, U32.or(h, 0), h, UWB.or0r(h)) :
        {List.append(&2, U32, I.limb(h), FX.limbs(t)) == List.append(&2, U32, VS.bt(@Sn, I.limb(_)), List.append(&2, U32, VS.bdr(@Sn, I.limb(h)), FX.limbs(t))) : +List<U32>}
      {==}
    case False{}:
      +e = FD.logic__subst(U32, z => {VS.bdr(@Sn, I.limb(U32.or(h, z))) == VS.bdr(@Sn, I.limb(h)) : +List<U32>}, U32.and(c, @M), c, Equal.sym(U32, c, U32.and(c, @M), hc), UWB.bhi@S(h, c))
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, z, FX.limbs(t))),
        VS.bdr(@Sn, I.limb(U32.or(h, c))), VS.bdr(@Sn, I.limb(h)), e)

# The list model's bytes: the low @S byte@PL of the first word (with the carry c), the
# limbs of ws, then the words' bytes after them.
law swlb:
  for +ws: +List<U32>
  for +W: List<&2, U32>
  for +c: U32
  for +hl: {Nat.is_lt(List.length(&2, U32, ws), VB.len(W)) == True{} : Bool}
  for +hz: {VS.bt(A.quad(List.length(&2, U32, ws)), VS.bdr(@Sn, FX.limbs(W))) == UW.ZB(A.quad(List.length(&2, U32, ws))) : +List<U32>}
  for +hc: {c == U32.and(c, @M) : U32}
  {FX.limbs(UW.SWL(@S, ws, W, c)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(FD.flat__nthc(W, 0n), c))), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(List.length(&2, U32, ws))), FX.limbs(W)))) : +List<U32>}
def swlb(ws, W, c, hl, hz, hc):
  match ws W:
    case _ Nil{}: Empty.absurd({FX.limbs(UW.SWL(@S, ws, Nil{}, c)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(FD.flat__nthc(Nil{}, 0n), c))), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(List.length(&2, U32, ws))), FX.limbs(Nil{})))) : +List<U32>}, FD.nat__lt_zero_absurd(List.length(&2, U32, ws), hl))
    case Nil{} Con{+h, +t}: base(U32.is_eq(c, 0), h, t, c, {==}, hc)
    case Con{+w, +r} Con{+h, +t}:
      match t:
        case Nil{}: Empty.absurd({FX.limbs(UW.SWL(@S, Con{w, r}, Con{h, Nil{}}, c)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, FX.limbs(Con{w, r}), VS.bdr(Nat.add(@Sn, A.quad(List.length(&2, U32, Con{w, r}))), FX.limbs(Con{h, Nil{}})))) : +List<U32>}, FD.nat__lt_zero_absurd(List.length(&2, U32, r), hl))
        case Con{+t0, +tr}:
          +k = A.quad(List.length(&2, U32, r))
          +HZ = VS.bt(A.quad(List.length(&2, U32, Con{w, r})), VS.bdr(@Sn, FX.limbs(Con{h, Con{t0, tr}})))
          +ha = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(@Rn, z), HZ, UW.ZB(A.quad(List.length(&2, U32, Con{w, r}))), hz)
          +hb = Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@Rn, z), HZ, UW.ZB(A.quad(List.length(&2, U32, Con{w, r}))), hz)
          +hc0 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(@Sn, z), VS.bt(Nat.add(@Sn, k), FX.limbs(Con{t0, tr})), @ZS, hb)
          +hzi = Equal.trans(+List<U32>, VS.bt(k, VS.bdr(@Sn, FX.limbs(Con{t0, tr}))), VS.bdr(@Sn, VS.bt(Nat.add(@Sn, k), FX.limbs(Con{t0, tr}))), UW.ZB(k),
            Equal.sym(+List<U32>, VS.bdr(@Sn, VS.bt(Nat.add(@Sn, k), FX.limbs(Con{t0, tr}))), VS.bt(k, VS.bdr(@Sn, FX.limbs(Con{t0, tr}))), VS.bdr_bt(@Sn, k, FX.limbs(Con{t0, tr}))),
            Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@Sn, z), VS.bt(Nat.add(@Sn, k), FX.limbs(Con{t0, tr})), @ZS, hb))
          +eh = UWB.zl@S(h, ha)
          +ez = UWB.zh@S(t0, hc0)
          +ih = swlb(r, Con{t0, tr}, O.shr_over(w, @S), hl, hzi, UWB.cm@S(w))
          %Equal.sym(+List<U32>, I.limb(U32.or(h, U32.or(O.shl_bytes(w, @S), c))), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), e1(h, w, c, eh, hc)) :
            {List.append(&2, U32, _, FX.limbs(UW.SWL(@S, r, Con{t0, tr}, O.shr_over(w, @S)))) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, FX.limbs(Con{w, r}), VS.bdr(Nat.add(@Sn, A.quad(List.length(&2, U32, Con{w, r}))), FX.limbs(Con{h, Con{t0, tr}})))) : +List<U32>}
          %Equal.sym(+List<U32>, FX.limbs(UW.SWL(@S, r, Con{t0, tr}, O.shr_over(w, @S))), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(t0, O.shr_over(w, @S)))), List.append(&2, U32, FX.limbs(r), VS.bdr(Nat.add(@Sn, k), FX.limbs(Con{t0, tr})))), ih) :
            {List.append(&2, U32, List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), _) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, FX.limbs(Con{w, r}), VS.bdr(Nat.add(@Sn, A.quad(List.length(&2, U32, Con{w, r}))), FX.limbs(Con{h, Con{t0, tr}})))) : +List<U32>}
          %Equal.sym(+List<U32>, VS.bt(@Sn, I.limb(U32.or(t0, O.shr_over(w, @S)))), VS.bdr(@Rn, I.limb(w)), e2(t0, w, ez)) :
            {List.append(&2, U32, List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), List.append(&2, U32, _, List.append(&2, U32, FX.limbs(r), VS.bdr(Nat.add(@Sn, k), FX.limbs(Con{t0, tr}))))) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, FX.limbs(Con{w, r}), VS.bdr(Nat.add(@Sn, A.quad(List.length(&2, U32, Con{w, r}))), FX.limbs(Con{h, Con{t0, tr}})))) : +List<U32>}
          {==}
# The tree model's bytes: writing ws at byte @S of word i (no carry before) splices their
# limbs into the tree's bytes at 4 i + @S, when those were zero.
def swcb(+ws: +List<U32>, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hr: {Nat.is_lt(Nat.add(i, List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(A.quad(List.length(&2, U32, ws)), VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D))) == UW.ZB(A.quad(List.length(&2, U32, ws))) : +List<U32>})
    -> {UA.BYT(UW.SWc(@S, ws, dd, D, i, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(i), @Sn), FX.limbs(ws)) : +List<U32>}:
  +SL = UW.SLW(D)
  +Wd = VB.wdr(i, UW.SLW(D))
  +k = List.length(&2, U32, ws)
  +eL = Equal.sym(Nat, VB.len(UW.SLW(D)), VB.pw(dd), FD.array__slots_length(U32, dd, D, pf))
  +hi2 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(i, k), z) == True{} : Bool}, VB.pw(dd), VB.len(UW.SLW(D)), eL, hr)
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(i, z) == True{} : Bool}, VB.pw(dd), VB.len(UW.SLW(D)), eL, UW.lt_add_l(i, k, VB.pw(dd), hr))
  +eW = Equal.trans(+List<U32>, VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D)), VS.bdr(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), VS.bdr(@Sn, FX.limbs(VB.wdr(i, UW.SLW(D)))),
    UW.bdr_add(A.quad(i), @Sn, UA.BYT(D)),
    Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@Sn, z), VS.bdr(A.quad(i), UA.BYT(D)), FX.limbs(VB.wdr(i, UW.SLW(D))), UW.bdr_limbs_w(i, UW.SLW(D))))
  +hz2 = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(k), z) == UW.ZB(A.quad(k)) : +List<U32>}, VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D)), VS.bdr(@Sn, FX.limbs(VB.wdr(i, UW.SLW(D)))), eW, hz)
  +sw = swlb(ws, VB.wdr(i, UW.SLW(D)), 0, UW.lt_wdr(i, k, UW.SLW(D), hi2), hz2, {==})
  +RHS = UW.SPL(UA.BYT(D), Nat.add(A.quad(i), @Sn), FX.limbs(ws))
  +SWLt = UW.SWL(@S, ws, VB.wdr(i, UW.SLW(D)), 0)
  %Equal.sym(List<&2, U32>, UW.SLW(UW.SWc(@S, ws, dd, D, i, 0)), VF.app(VS.wtake(i, UW.SLW(D)), SWLt), UW.swc_slots(@S, ws, dd, D, i, 0, pf, hr)) :
    {FX.limbs(_) == RHS : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(VF.app(VS.wtake(i, UW.SLW(D)), SWLt)), List.append(&2, U32, FX.limbs(VS.wtake(i, UW.SLW(D))), FX.limbs(SWLt)), VF.limbs_app(VS.wtake(i, UW.SLW(D)), SWLt)) :
    {_ == RHS : +List<U32>}
  %VS.bt_limbs(i, UW.SLW(D)) : {List.append(&2, U32, _, FX.limbs(SWLt)) == RHS : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(SWLt), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(FD.flat__nthc(VB.wdr(i, UW.SLW(D)), 0n), 0))), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(k)), FX.limbs(VB.wdr(i, UW.SLW(D)))))), sw) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), _) == RHS : +List<U32>}
  %Equal.sym(U32, FD.flat__nthc(VB.wdr(i, UW.SLW(D)), 0n), FD.flat__nthc(UW.SLW(D), i), UW.nthc_wdr(i, UW.SLW(D))) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(_, 0))), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(k)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %Equal.sym(U32, U32.or(FD.flat__nthc(UW.SLW(D), i), 0), FD.flat__nthc(UW.SLW(D), i), UWB.or0r(FD.flat__nthc(UW.SLW(D), i))) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, I.limb(_)), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(k)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %UW.slot_limb(UW.SLW(D), i, hl) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, _), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(k)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(@Sn, VS.bt(Nat.add(@Sn, @Rn), VS.bdr(A.quad(i), UA.BYT(D)))), VS.bt(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), VS.bt_bt(@Sn, @Rn, VS.bdr(A.quad(i), UA.BYT(D)))) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, _, List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(k)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %UW.bdr_limbs_w(i, UW.SLW(D)) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, A.quad(k)), _)))) == RHS : +List<U32>}
  %UW.len_limbs_q(ws) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), List.append(&2, U32, FX.limbs(ws), VS.bdr(Nat.add(@Sn, _), VS.bdr(A.quad(i), UA.BYT(D)))))) == RHS : +List<U32>}
  UW.spl_comb(UA.BYT(D), A.quad(i), @Sn, FX.limbs(ws))
# The four-byte write at byte @S of word i splices the limbs of x in.
def w32b(+x: U32, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hr: {Nat.is_lt(1n+i, VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(4n, VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D))) == UW.ZB(4n) : +List<U32>})
    -> {UA.BYT(UW.W32M(@S, dd, D, i, x)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(i), @Sn), I.limb(x)) : +List<U32>}:
  +D1 = UW.ORW(dd, D, i, O.shl_bytes(x, @S))
  +hr1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, 1n+i, Nat.add(i, 1n), Equal.sym(Nat, Nat.add(i, 1n), 1n+i, Equal.trans(Nat, Nat.add(i, 1n), 1n+Nat.add(i, 0n), 1n+i, FD.nat__add_succ(i, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(i, 0n), i, FD.nat__add_zero(i)))), hr)
  +es = UW.orw_ors_slots(dd, D1, 1n+i, O.shr_over(x, @S), UW.orw_perfect(dd, D, i, O.shl_bytes(x, @S), pf), hr)
  +b = swcb([x], dd, D, i, pf, hr1, hz)
  +e1 = Equal.cong(List<&2, U32>, +List<U32>, z => FX.limbs(z), UW.SLW(UW.W32M(@S, dd, D, i, x)), UW.SLW(UW.ORS(dd, D1, 1n+i, O.shr_over(x, @S))), es)
  +e2 = Equal.cong(U32, +List<U32>, z => FX.limbs(UW.SLW(UW.ORS(dd, UW.ORW(dd, D, i, z), 1n+i, O.shr_over(x, @S)))), O.shl_bytes(x, @S), U32.or(O.shl_bytes(x, @S), 0),
    Equal.sym(U32, U32.or(O.shl_bytes(x, @S), 0), O.shl_bytes(x, @S), UWB.or0r(O.shl_bytes(x, @S))))
  Equal.trans(+List<U32>, UA.BYT(UW.W32M(@S, dd, D, i, x)), UA.BYT(UW.SWc(@S, [x], dd, D, i, 0)), UW.SPL(UA.BYT(D), Nat.add(A.quad(i), @Sn), I.limb(x)),
    Equal.trans(+List<U32>, UA.BYT(UW.W32M(@S, dd, D, i, x)), FX.limbs(UW.SLW(UW.ORS(dd, D1, 1n+i, O.shr_over(x, @S)))), UA.BYT(UW.SWc(@S, [x], dd, D, i, 0)), e1, e2), b)
'''


# The open model's bytes (its carry out dropped): only the first 4 |ws| - s bytes of the
# words' limbs land, up to the end of the last word written.
SWLBO = r'''
# The open list model's bytes: the low @S byte@PL of the first word (with the carry c),
# the first 4 |ws| - @S bytes of the limbs of ws = w : r, then the words' bytes after the
# last one written.
law swlbo:
  for +r: +List<U32>
  for +w: U32
  for +W: List<&2, U32>
  for +c: U32
  for +hl: {Nat.is_le(1n+List.length(&2, U32, r), VB.len(W)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, r))), VS.bdr(@Sn, FX.limbs(W))) == UW.ZB(Nat.add(@Rn, A.quad(List.length(&2, U32, r)))) : +List<U32>}
  for +hc: {c == U32.and(c, @M) : U32}
  {FX.limbs(UW.SWLo(@S, Con{w, r}, W, c)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(FD.flat__nthc(W, 0n), c))), List.append(&2, U32, VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, r))), FX.limbs(Con{w, r})), VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(W)))) : +List<U32>}
def swlbo(r, w, W, c, hl, hz, hc):
  match r W:
    case _ Nil{}: Empty.absurd({FX.limbs(UW.SWLo(@S, Con{w, r}, Nil{}, c)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(FD.flat__nthc(Nil{}, 0n), c))), List.append(&2, U32, VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, r))), FX.limbs(Con{w, r})), VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(Nil{})))) : +List<U32>}, FD.logic__false_true(hl))
    case Nil{} Con{+h, +t}:
      +ha = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(@Rn, z), VS.bt(@Rn, VS.bdr(@Sn, FX.limbs(Con{h, t}))), UW.ZB(@Rn), hz)
      +eh = UWB.zl@S(h, ha)
      %Equal.sym(+List<U32>, I.limb(U32.or(h, U32.or(O.shl_bytes(w, @S), c))), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), e1(h, w, c, eh, hc)) :
        {List.append(&2, U32, _, FX.limbs(t)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, VS.bt(@Rn, FX.limbs([w])), VS.bdr(4n, FX.limbs(Con{h, t})))) : +List<U32>}
      {==}
    case Con{+w2, +r2} Con{+h, +t}:
      match t:
        case Nil{}: Empty.absurd({FX.limbs(UW.SWLo(@S, Con{w, Con{w2, r2}}, Con{h, Nil{}}, c)) == List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, Con{w2, r2}))), FX.limbs(Con{w, Con{w2, r2}})), VS.bdr(4n+A.quad(List.length(&2, U32, Con{w2, r2})), FX.limbs(Con{h, Nil{}})))) : +List<U32>}, FD.logic__false_true(hl))
        case Con{+t0, +tr}:
          +X = A.quad(List.length(&2, U32, r2))
          +L2 = FX.limbs(Con{t0, tr})
          +HZ = VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, Con{w2, r2}))), VS.bdr(@Sn, FX.limbs(Con{h, Con{t0, tr}})))
          +ZZ = UW.ZB(Nat.add(@Rn, A.quad(List.length(&2, U32, Con{w2, r2}))))
          +ha = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(@Rn, z), HZ, ZZ, hz)
          +hb = Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@Rn, z), HZ, ZZ, hz)
          +hb2 = Equal.trans(+List<U32>, VS.bt(4n+X, L2), VS.bdr(@Rn, HZ), UW.ZB(4n+X), {==}, Equal.trans(+List<U32>, VS.bdr(@Rn, HZ), VS.bdr(@Rn, ZZ), UW.ZB(4n+X), hb, {==}))
          +hc0 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(@Sn, z), VS.bt(4n+X, L2), UW.ZB(4n+X), hb2)
          +hzi = Equal.trans(+List<U32>, VS.bt(Nat.add(@Rn, X), VS.bdr(@Sn, L2)), VS.bt(Nat.add(@Rn, X), VS.bdr(@Sn, VS.bt(4n+X, L2))), UW.ZB(Nat.add(@Rn, X)),
            UW.bt_bdr_bt(Nat.add(@Rn, X), @Sn, 4n+X, L2, FD.nat__le_refl(4n+X)),
            Equal.trans(+List<U32>, VS.bt(Nat.add(@Rn, X), VS.bdr(@Sn, VS.bt(4n+X, L2))), VS.bt(Nat.add(@Rn, X), VS.bdr(@Sn, UW.ZB(4n+X))), UW.ZB(Nat.add(@Rn, X)),
              Equal.cong(+List<U32>, +List<U32>, z => VS.bt(Nat.add(@Rn, X), VS.bdr(@Sn, z)), VS.bt(4n+X, L2), UW.ZB(4n+X), hb2),
              UW.zb_win(@Sn, Nat.add(@Rn, X), 4n+X, FD.nat__le_refl(4n+X))))
          +eh = UWB.zl@S(h, ha)
          +ez = UWB.zh@S(t0, hc0)
          +ih = swlbo(r2, w2, Con{t0, tr}, O.shr_over(w, @S), hl, hzi, UWB.cm@S(w))
          +RHS = List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), List.append(&2, U32, VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, Con{w2, r2}))), FX.limbs(Con{w, Con{w2, r2}})), VS.bdr(4n+A.quad(List.length(&2, U32, Con{w2, r2})), FX.limbs(Con{h, Con{t0, tr}}))))
          %Equal.sym(+List<U32>, I.limb(U32.or(h, U32.or(O.shl_bytes(w, @S), c))), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), e1(h, w, c, eh, hc)) :
            {List.append(&2, U32, _, FX.limbs(UW.SWLo(@S, Con{w2, r2}, Con{t0, tr}, O.shr_over(w, @S)))) == RHS : +List<U32>}
          %Equal.sym(+List<U32>, FX.limbs(UW.SWLo(@S, Con{w2, r2}, Con{t0, tr}, O.shr_over(w, @S))), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(t0, O.shr_over(w, @S)))), List.append(&2, U32, VS.bt(Nat.add(@Rn, X), FX.limbs(Con{w2, r2})), VS.bdr(4n+X, L2))), ih) :
            {List.append(&2, U32, List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), _) == RHS : +List<U32>}
          %Equal.sym(+List<U32>, VS.bt(@Sn, I.limb(U32.or(t0, O.shr_over(w, @S)))), VS.bdr(@Rn, I.limb(w)), e2(t0, w, ez)) :
            {List.append(&2, U32, List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(h, c))), VS.bt(@Rn, I.limb(w))), List.append(&2, U32, _, List.append(&2, U32, VS.bt(Nat.add(@Rn, X), FX.limbs(Con{w2, r2})), VS.bdr(4n+X, L2)))) == RHS : +List<U32>}
          {==}

# The open tree model's bytes: writing w : r at byte @S of word i (no carry before, the
# carry out dropped) splices the first 4 |w : r| - @S bytes of their limbs into the tree's
# bytes at 4 i + @S, when those were zero; the run's own words suffice (i + |w : r| <= 2^dd).
def swcbo(+w: U32, +r: +List<U32>, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(i, 1n+List.length(&2, U32, r)), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, r))), VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D))) == UW.ZB(Nat.add(@Rn, A.quad(List.length(&2, U32, r)))) : +List<U32>})
    -> {UA.BYT(UW.SWo(@S, Con{w, r}, dd, D, i, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(i), @Sn), VS.bt(Nat.add(@Rn, A.quad(List.length(&2, U32, r))), FX.limbs(Con{w, r}))) : +List<U32>}:
  +LZ = Nat.add(@Rn, A.quad(List.length(&2, U32, r)))
  +Y = VS.bt(LZ, FX.limbs(Con{w, r}))
  +eL = Equal.sym(Nat, VB.len(UW.SLW(D)), VB.pw(dd), FD.array__slots_length(U32, dd, D, pf))
  +hi2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(i, 1n+List.length(&2, U32, r)), z) == True{} : Bool}, VB.pw(dd), VB.len(UW.SLW(D)), eL, hr)
  +hi = FD.nat__lt_le_trans(i, Nat.add(i, 1n+List.length(&2, U32, r)), VB.pw(dd),
    FD.logic__subst(Nat, z => {Nat.is_lt(i, z) == True{} : Bool}, 1n+Nat.add(i, List.length(&2, U32, r)), Nat.add(i, 1n+List.length(&2, U32, r)),
      Equal.sym(Nat, Nat.add(i, 1n+List.length(&2, U32, r)), 1n+Nat.add(i, List.length(&2, U32, r)), FD.nat__add_succ(i, List.length(&2, U32, r))),
      FD.nat__le_lt_succ(i, Nat.add(i, List.length(&2, U32, r)), Order.below_sum(i, List.length(&2, U32, r)))), hr)
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(i, z) == True{} : Bool}, VB.pw(dd), VB.len(UW.SLW(D)), eL, hi)
  +eW = Equal.trans(+List<U32>, VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D)), VS.bdr(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), VS.bdr(@Sn, FX.limbs(VB.wdr(i, UW.SLW(D)))),
    UW.bdr_add(A.quad(i), @Sn, UA.BYT(D)),
    Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@Sn, z), VS.bdr(A.quad(i), UA.BYT(D)), FX.limbs(VB.wdr(i, UW.SLW(D))), UW.bdr_limbs_w(i, UW.SLW(D))))
  +hz2 = FD.logic__subst(+List<U32>, z => {VS.bt(LZ, z) == UW.ZB(LZ) : +List<U32>}, VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(D)), VS.bdr(@Sn, FX.limbs(VB.wdr(i, UW.SLW(D)))), eW, hz)
  +sw = swlbo(r, w, VB.wdr(i, UW.SLW(D)), 0, UW.le_wdr(i, 1n+List.length(&2, U32, r), UW.SLW(D), hi2), hz2, {==})
  +eY = VS.bt_len(LZ, FX.limbs(Con{w, r}), FD.logic__subst(Nat, z => {Nat.is_le(LZ, z) == True{} : Bool}, 4n+A.quad(List.length(&2, U32, r)), List.length(&2, U32, FX.limbs(Con{w, r})),
    Equal.sym(Nat, List.length(&2, U32, FX.limbs(Con{w, r})), A.quad(List.length(&2, U32, Con{w, r})), UW.len_limbs_q(Con{w, r})), Order.add_right(@Rn, 4n, A.quad(List.length(&2, U32, r)), {==})))
  +RHS = UW.SPL(UA.BYT(D), Nat.add(A.quad(i), @Sn), Y)
  +SWLt = UW.SWLo(@S, Con{w, r}, VB.wdr(i, UW.SLW(D)), 0)
  %Equal.sym(List<&2, U32>, UW.SLW(UW.SWo(@S, Con{w, r}, dd, D, i, 0)), VF.app(VS.wtake(i, UW.SLW(D)), SWLt), UW.swo_slots(@S, Con{w, r}, dd, D, i, 0, pf, hr)) :
    {FX.limbs(_) == RHS : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(VF.app(VS.wtake(i, UW.SLW(D)), SWLt)), List.append(&2, U32, FX.limbs(VS.wtake(i, UW.SLW(D))), FX.limbs(SWLt)), VF.limbs_app(VS.wtake(i, UW.SLW(D)), SWLt)) :
    {_ == RHS : +List<U32>}
  %VS.bt_limbs(i, UW.SLW(D)) : {List.append(&2, U32, _, FX.limbs(SWLt)) == RHS : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(SWLt), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(FD.flat__nthc(VB.wdr(i, UW.SLW(D)), 0n), 0))), List.append(&2, U32, Y, VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(VB.wdr(i, UW.SLW(D)))))), sw) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), _) == RHS : +List<U32>}
  %Equal.sym(U32, FD.flat__nthc(VB.wdr(i, UW.SLW(D)), 0n), FD.flat__nthc(UW.SLW(D), i), UW.nthc_wdr(i, UW.SLW(D))) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, I.limb(U32.or(_, 0))), List.append(&2, U32, Y, VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %Equal.sym(U32, U32.or(FD.flat__nthc(UW.SLW(D), i), 0), FD.flat__nthc(UW.SLW(D), i), UWB.or0r(FD.flat__nthc(UW.SLW(D), i))) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, I.limb(_)), List.append(&2, U32, Y, VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %UW.slot_limb(UW.SLW(D), i, hl) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, _), List.append(&2, U32, Y, VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(@Sn, VS.bt(Nat.add(@Sn, @Rn), VS.bdr(A.quad(i), UA.BYT(D)))), VS.bt(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), VS.bt_bt(@Sn, @Rn, VS.bdr(A.quad(i), UA.BYT(D)))) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, _, List.append(&2, U32, Y, VS.bdr(4n+A.quad(List.length(&2, U32, r)), FX.limbs(VB.wdr(i, UW.SLW(D))))))) == RHS : +List<U32>}
  %UW.bdr_limbs_w(i, UW.SLW(D)) :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), List.append(&2, U32, Y, VS.bdr(4n+A.quad(List.length(&2, U32, r)), _)))) == RHS : +List<U32>}
  %eY :
    {List.append(&2, U32, VS.bt(A.quad(i), UA.BYT(D)), List.append(&2, U32, VS.bt(@Sn, VS.bdr(A.quad(i), UA.BYT(D))), List.append(&2, U32, Y, VS.bdr(Nat.add(@Sn, _), VS.bdr(A.quad(i), UA.BYT(D)))))) == RHS : +List<U32>}
  UW.spl_comb(UA.BYT(D), A.quad(i), @Sn, Y)
'''

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
FIXW1 = [('b48', 'Bytes48', 12), ('b96', 'Bytes96', 24), ('bv512', 'Bitvector512', 16), ('bv64', 'Bitvector64', 2)]


def fixw_text(s, writers=None):
    """proofs/obj/vuwf<s>.bend: the runtime's writers of FIXW at byte s of word i are the
    model SWc (putu_<p>), when the value's bytes there were zero."""
    MUL, UP = 256 ** s, 32 - 8 * s
    L = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T', 'import ../compact/found.bend as FD',
         'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
         'import ./vua.bend as UA', 'import ./vuw_bits.bend as UWB', 'import ./vuw.bend as UW', '',
         '# GENERATED by codegen/var_uw.py. Do not edit.',
         f'# The runtime\'s word-by-word writers at byte {s} of a word: the tree model SWc (see codegen/var_uw.py).', '']
    TH = 'FD.array__thaw(U32, {})'
    for p, cons, N in (FIXW if writers is None else writers):
        ws = [f'w{k}' for k in range(N)]
        m = 4 * N
        q = 'U32.shrn(pos, 2n)'
        idx = lambda k: 'i' if k == 0 else f'{k}n+i'  # noqa: E731
        vals = [f'U32.mul(w0, {MUL})'] + [f'U32.or(U32.mul(w{k}, {MUL}), U32.shrn(w{k - 1}, {UP}n))' for k in range(1, N)]
        D = ['U']
        for k in range(N):
            D.append(f'UW.ORW(dd, {D[k]}, {idx(k)}, {vals[k]})')
        carry = f'U32.shrn(w{N - 1}, {UP}n)'
        model = f'UW.SWc({s}, [{", ".join(ws)}], dd, U, i, 0)'
        RHS = TH.format(model)
        # the runtime's body with layer j (the result of op j, j = 1..N) as a hole
        def body(j, hole):
            e = hole
            for k in range(j, N):
                e = f'Array.set(U32, {e}, U32.add({q}, {k}), {vals[k]})'
            return f'O.or_skip({e}, U32.add({q}, {N}), {carry})'
        sig = (f'def putu_{p}(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, ' + ', '.join(f'+{w}: U32' for w in ws) + ',\n'
               f'    +e: {{U32.to_nat(pos) == Nat.add(A.quad(i), {s}n) : Nat}}, +hd: {{Nat.is_lt(dd, 31n) == True{{}} : Bool}},\n'
               f'    +hl: {{Nat.is_lt(Nat.add({N}n, i), VB.pw(dd)) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, dd, U) == True{{}} : Bool}},\n'
               f'    +hz: {{VS.bt({m}n, VS.bdr(Nat.add(A.quad(i), {s}n), UA.BYT(U))) == UW.ZB({m}n) : +List<U32>}})\n'
               f'    -> {{T.{p}_put({TH.format("U")}, pos, T.{cons}{{{", ".join(ws)}}}) == {RHS} : Array<U32>}}:')
        L.append(f'# {p} at byte {s} of word i.')
        L.append(sig)
        L.append(f'  +e3 = UW.ua_3(pos, i, {s}n, {s}, {{==}}, e, {{==}})')
        L.append(f'  +eq = UW.ua_q(pos, i, {s}n, e, {{==}})')
        L.append('  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})')
        for k in range(N):
            L.append(f'  +hi{k} = UW.lt_off({k}n, {N}n, i, VB.pw(dd), {{==}}, hl)')
        for k in range(N + 1):
            L.append(f'  +eq{k} = VB.add_at({q}, {k}, i, dd, eq, hd32, {"hl" if k == N else f"hi{k}"})')
        L.append('  +pf0 = pf')
        for k in range(N):
            L.append(f'  +pf{k + 1} = UW.orw_perfect(dd, {D[k]}, {idx(k)}, {vals[k]}, pf{k})')
        # zero words 1..N-1
        for j in range(1, N):
            d = 4 * j - s
            m2 = m - d
            chain = f'UW.zslot(dd, U, i, {s}n, {m}n, {j}n, {d}n, {m2}n, {m2 - 4}n, pf, hz, {{==}}, {{==}}, {{==}}, {{==}}, hi{j})'
            # slot(D_j, j + i) == slot(D_{j-1}, j + i) == ... == slot(U, j + i) == 0
            e = chain
            for t in range(1, j + 1):
                st = f'UW.slot_orw_other(dd, {D[t - 1]}, {idx(t - 1)}, {idx(j)}, {vals[t - 1]}, pf{t - 1}, hi{t - 1}, UW.ne_off({t - 1}n, {j}n, i, {{==}}))'
                e = f'Equal.trans(U32, VB.slot({D[t]}, {idx(j)}), VB.slot({D[t - 1]}, {idx(j)}), 0, {st}, {e})'
            L.append(f'  +hz{j} = {e}')
        L.append(f'  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pwd(U32.is_eq(_, 0), U32.and(pos, 3), {TH.format("U")}, {q}, {", ".join(ws)}) == {RHS} : Array<U32>}}')
        L.append(f'  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pwd(U32.is_eq({s}, 0), _, {TH.format("U")}, {q}, {", ".join(ws)}) == {RHS} : Array<U32>}}')
        # layer 1: the or_word
        L.append(f'  %Equal.sym(Array<U32>, O.or_word({TH.format("U")}, U32.add({q}, 0), {vals[0]}), {TH.format(D[1])}, UW.orw_rt(dd, U, U32.add({q}, 0), i, {vals[0]}, eq0, hd32, hi0, pf)) :')
        L.append(f'    {{{body(1, "_")} == {RHS} : Array<U32>}}')
        for j in range(2, N + 1):
            k = j - 1
            L.append(f'  %Equal.sym(Array<U32>, Array.set(U32, {TH.format(D[k])}, U32.add({q}, {k}), {vals[k]}), {TH.format(D[j])},')
            L.append(f'      UW.set_orw(dd, {D[k]}, U32.add({q}, {k}), {idx(k)}, {vals[k]}, eq{k}, hd32, hi{k}, pf{k}, hz{k})) :')
            L.append(f'    {{{body(j, "_")} == {RHS} : Array<U32>}}')
        L.append(f'  %Equal.sym(Array<U32>, O.or_skip({TH.format(D[N])}, U32.add({q}, {N}), {carry}), {TH.format(f"UW.ORS(dd, {D[N]}, {N}n+i, {carry})")},')
        L.append(f'      UW.orskip_rt(dd, {D[N]}, U32.add({q}, {N}), {N}n+i, {carry}, eq{N}, hd32, hl, pf{N})) :')
        L.append(f'    {{_ == {RHS} : Array<U32>}}')
        # the first word: mul vs mul | 0
        rest = D[N].replace(f'UW.ORW(dd, U, i, {vals[0]})', 'UW.ORW(dd, U, i, z)')
        L.append(f'  Equal.cong(U32, Array<U32>, z => {TH.format(f"UW.ORS(dd, {rest}, {N}n+i, {carry})")}, {vals[0]}, U32.or({vals[0]}, 0),')
        L.append(f'    Equal.sym(U32, U32.or({vals[0]}, 0), {vals[0]}, UWB.or0r({vals[0]})))')
        L.append('')
    return '\n'.join(L) + '\n'


PUTW = r'''import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vua.bend as UA
import ./vua_copy.bend as UC
import ./vua_sc.bend as USC
import ./vcopy.bend as VC
import ./vuw_bits.bend as UWB
import ./vuw.bend as UW
import ./word_mul.bend as WM

# GENERATED by codegen/var_uw.py. Do not edit.
# The runtime's byte-range write O.put_words at byte @S of a word: its shifted copy
# (smone) and OR loop are the model SWo, and the whole write is SWc (see codegen/var_uw.py).

# The shifted copy of m words into zero words at j is the model, after the carry of
# source word x.
law sm_swo:
  for +m: Nat
  for +x: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: FD.array__Tree<U32>
  for +TS: FD.array__Tree<U32>
  for +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool}
  for +hx: {Nat.is_lt(Nat.add(m, x), VB.pw(ds)) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(m, j), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(A.quad(m), VS.bdr(A.quad(j), UA.BYT(D))) == UW.ZB(A.quad(m)) : +List<U32>}
  {UC.smone(@Rn, m, x, j, dd, ds, D, TS) == UW.SWo(@S, VS.wtake(m, VB.wdr(1n+x, UW.SLW(TS))), dd, D, j, O.shr_over(VB.slot(TS, x), @S)) : FD.array__Tree<U32>}
def sm_swo(m, x, j, dd, ds, D, TS, pfD, pfS, hx, hj, hz):
  match m:
    case 0n: {==}
    case 1n+ +p:
      +SL = UW.SLW(TS)
      +eS = Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS))
      +hx1 = FD.nat__le_lt_trans(1n+x, 1n+Nat.add(p, x), VB.pw(ds), Order.left_below_sum(p, x), hx)
      +hx0 = FD.nat__lt_trans(x, 1n+x, VB.pw(ds), FD.nat__lt_succ(x), hx1)
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_lt(1n+x, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), eS, hx1)
      +hj0 = FD.nat__lt_le_trans(j, 1n+Nat.add(p, j), VB.pw(dd), FD.nat__le_lt_succ(j, Nat.add(p, j), Order.left_below_sum(p, j)), hj)
      +hzj = FD.logic__subst(Nat, z => {VS.bt(4n+A.quad(p), VS.bdr(z, UA.BYT(D))) == UW.ZB(4n+A.quad(p)) : +List<U32>}, A.quad(j), Nat.add(A.quad(j), 0n),
        Equal.sym(Nat, Nat.add(A.quad(j), 0n), A.quad(j), FD.nat__add_zero(A.quad(j))), hz)
      +ez = UW.zslot_g(dd, D, j, 0n, 4n+A.quad(p), 0n, 0n, pfD, hzj, {==}, FD.nat__zero_le(A.quad(p)), hj0)
      +w0 = VB.slot(TS, x)
      +w1 = VB.slot(TS, 1n+x)
      +v1 = U32.or(O.shl_bytes(w1, @S), O.shr_over(w0, @S))
      +vj = UA.jn(@Rn, UC.RS(ds, TS, x), UC.RS(ds, TS, 1n+x))
      +ev = Equal.trans(U32, vj, U32.or(U32.shrn(w0, @UPn), U32.shln(w1, @SHn)), U32.or(VB.slot(D, j), v1),
        Equal.trans(U32, vj, U32.or(U32.shrn(w0, @UPn), U32.shln(UC.RS(ds, TS, 1n+x), @SHn)), U32.or(U32.shrn(w0, @UPn), U32.shln(w1, @SHn)),
          Equal.cong(U32, U32, z => U32.or(U32.shrn(z, @UPn), U32.shln(UC.RS(ds, TS, 1n+x), @SHn)), UC.RS(ds, TS, x), w0, UC.rs_lt(ds, TS, x, hx0)),
          Equal.cong(U32, U32, z => U32.or(U32.shrn(w0, @UPn), U32.shln(z, @SHn)), UC.RS(ds, TS, 1n+x), w1, UC.rs_lt(ds, TS, 1n+x, hx1))),
        Equal.trans(U32, U32.or(U32.shrn(w0, @UPn), U32.shln(w1, @SHn)), U32.or(U32.shln(w1, @SHn), U32.shrn(w0, @UPn)), U32.or(VB.slot(D, j), v1),
          UWB.orc(U32.shrn(w0, @UPn), U32.shln(w1, @SHn)),
          Equal.trans(U32, U32.or(U32.shln(w1, @SHn), U32.shrn(w0, @UPn)), v1, U32.or(VB.slot(D, j), v1),
            Equal.cong(U32, U32, z => U32.or(z, U32.shrn(w0, @UPn)), U32.shln(w1, @SHn), U32.mul(w1, @MUL), Equal.sym(U32, U32.mul(w1, @MUL), U32.shln(w1, @SHn), WM.mul@MUL(w1))),
            Equal.trans(U32, v1, U32.or(0, v1), U32.or(VB.slot(D, j), v1), Equal.sym(U32, U32.or(0, v1), v1, UW.or0l(v1)),
              Equal.cong(U32, U32, z => U32.or(z, v1), 0, VB.slot(D, j), Equal.sym(U32, VB.slot(D, j), 0, ez))))))
      +Dj = FD.array__upd(U32, dd, D, j, vj)
      +fr = UW.upd_frame(dd, D, j, vj, pfD, hj0)
      +hzb = Equal.trans(+List<U32>, VS.bt(A.quad(p), VS.bdr(4n, VS.bdr(A.quad(j), UA.BYT(D)))), VS.bdr(4n, VS.bt(Nat.add(4n, A.quad(p)), VS.bdr(A.quad(j), UA.BYT(D)))), UW.ZB(A.quad(p)),
        Equal.sym(+List<U32>, VS.bdr(4n, VS.bt(Nat.add(4n, A.quad(p)), VS.bdr(A.quad(j), UA.BYT(D)))), VS.bt(A.quad(p), VS.bdr(4n, VS.bdr(A.quad(j), UA.BYT(D)))), VS.bdr_bt(4n, A.quad(p), VS.bdr(A.quad(j), UA.BYT(D)))),
        Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(4n, z), VS.bt(4n+A.quad(p), VS.bdr(A.quad(j), UA.BYT(D))), UW.ZB(4n+A.quad(p)), hz))
      +eb4 = Equal.trans(+List<U32>, VS.bdr(4n+A.quad(j), UA.BYT(Dj)), VS.bdr(4n+A.quad(j), UA.BYT(D)), VS.bdr(4n, VS.bdr(A.quad(j), UA.BYT(D))), fr,
        Equal.trans(+List<U32>, VS.bdr(4n+A.quad(j), UA.BYT(D)), VS.bdr(Nat.add(A.quad(j), 4n), UA.BYT(D)), VS.bdr(4n, VS.bdr(A.quad(j), UA.BYT(D))),
          Equal.cong(Nat, +List<U32>, z => VS.bdr(z, UA.BYT(D)), 4n+A.quad(j), Nat.add(A.quad(j), 4n), FD.nat__add_comm(4n, A.quad(j))),
          UW.bdr_add(A.quad(j), 4n, UA.BYT(D))))
      +hz1 = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(p), z) == UW.ZB(A.quad(p)) : +List<U32>}, VS.bdr(4n, VS.bdr(A.quad(j), UA.BYT(D))), VS.bdr(4n+A.quad(j), UA.BYT(Dj)),
        Equal.sym(+List<U32>, VS.bdr(4n+A.quad(j), UA.BYT(Dj)), VS.bdr(4n, VS.bdr(A.quad(j), UA.BYT(D))), eb4), hzb)
      +hxp = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(ds)) == True{} : Bool}, 1n+Nat.add(p, x), Nat.add(p, 1n+x), Equal.sym(Nat, Nat.add(p, 1n+x), 1n+Nat.add(p, x), FD.nat__add_succ(p, x)), hx)
      +hjp = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +ih = sm_swo(p, 1n+x, 1n+j, dd, ds, Dj, TS, FD.array__upd_perfect(U32, dd, D, j, vj, pfD), pfS, hxp, hjp, hz1)
      %Equal.sym(List<&2, U32>, VB.wdr(1n+x, UW.SLW(TS)), Con{FD.flat__nthc(UW.SLW(TS), 1n+x), VB.wdr(2n+x, UW.SLW(TS))}, UW.wdr_con(UW.SLW(TS), 1n+x, hl1)) :
        {UC.smone(@Rn, 1n+p, x, j, dd, ds, D, TS) == UW.SWo(@S, VS.wtake(1n+p, _), dd, D, j, O.shr_over(w0, @S)) : FD.array__Tree<U32>}
      %ev :
        {UC.smone(@Rn, 1n+p, x, j, dd, ds, D, TS) == UW.SWo(@S, VS.wtake(p, VB.wdr(2n+x, UW.SLW(TS))), dd, FD.array__upd(U32, dd, D, j, _), 1n+j, O.shr_over(w1, @S)) : FD.array__Tree<U32>}
      ih

# The OR loop over source words J .. J + k, into words J + i .., after the carry c.
law pwor:
  for +k: Nat
  for +j: U32
  for +J: Nat
  for +q: U32
  for +i: Nat
  for +c: U32
  for +dd: Nat
  for +ds: Nat
  for +D: FD.array__Tree<U32>
  for +TS: FD.array__Tree<U32>
  for +ej: {U32.to_nat(j) == J : Nat}
  for +eq: {U32.to_nat(q) == i : Nat}
  for +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +hds: {Nat.is_lt(ds, 31n) == True{} : Bool}
  for +hjs: {Nat.is_lt(Nat.add(k, J), VB.pw(ds)) == True{} : Bool}
  for +hji: {Nat.is_lt(Nat.add(Nat.add(k, J), i), VB.pw(dd)) == True{} : Bool}
  for +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool}
  {O.pw_or@S(k, j, q, c, FD.array__thaw(U32, D), (FD.array__thaw(U32, TS), VB.slot(TS, J))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+k, VB.wdr(J, UW.SLW(TS))), dd, D, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+k, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
def pwor(k, j, J, q, i, c, dd, ds, D, TS, ej, eq, hd, hds, hjs, hji, pfD, pfS):
  match k:
    case 0n:
      +SL = UW.SLW(TS)
      +w = VB.slot(TS, J)
      +v = U32.or(U32.mul(w, @MUL), c)
      +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
      +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
      +hJs = FD.nat__le_lt_trans(J, Nat.add(0n, J), VB.pw(ds), Order.left_below_sum(0n, J), hjs)
      +hJ = FD.logic__subst(Nat, z => {Nat.is_lt(J, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hJs)
      +hJi = FD.nat__le_lt_trans(Nat.add(J, i), Nat.add(Nat.add(0n, J), i), VB.pw(dd), Order.add_right(J, Nat.add(0n, J), i, Order.left_below_sum(0n, J)), hji)
      +hJi2 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, J, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), J, ej), hJi)
      +eqj = FD.logic__subst(Nat, z => {U32.to_nat(U32.add(q, j)) == Nat.add(z, i) : Nat}, U32.to_nat(j), J, ej, VB.add_at(q, j, i, dd, eq, hd32, hJi2))
      +D1 = UW.ORW(dd, D, Nat.add(J, i), v)
      +ew = UW.wdr_con(UW.SLW(TS), J, hJ)
      %Equal.sym(List<&2, U32>, VB.wdr(J, UW.SLW(TS)), Con{w, VB.wdr(1n+J, UW.SLW(TS))}, ew) :
        {O.pw_or@S(0n, j, q, c, FD.array__thaw(U32, D), (FD.array__thaw(U32, TS), w)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n, _), dd, D, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(List<&2, U32>, VB.wdr(J, UW.SLW(TS)), Con{w, VB.wdr(1n+J, UW.SLW(TS))}, ew) :
        {O.pw_or@S(0n, j, q, c, FD.array__thaw(U32, D), (FD.array__thaw(U32, TS), w)) == (FD.array__thaw(U32, UW.SWo(@S, [w], dd, D, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n, _), c))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, D), U32.add(q, j), v), FD.array__thaw(U32, D1), UW.orw_rt(dd, D, U32.add(q, j), Nat.add(J, i), v, eqj, hd32, hJi, pfD)) :
        {(_, (FD.array__thaw(U32, TS), U32.shrn(w, @UPn))) == (FD.array__thaw(U32, UW.SWo(@S, [w], dd, D, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, [w], c))) : Array<U32> & (Array<U32> & U32)}
      {==}
    case 1n+ +e:
      +SL = UW.SLW(TS)
      +w = VB.slot(TS, J)
      +v = U32.or(U32.mul(w, @MUL), c)
      +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
      +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
      +hJs = FD.nat__le_lt_trans(J, Nat.add(1n+e, J), VB.pw(ds), Order.left_below_sum(1n+e, J), hjs)
      +hJ = FD.logic__subst(Nat, z => {Nat.is_lt(J, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hJs)
      +hJi = FD.nat__le_lt_trans(Nat.add(J, i), Nat.add(Nat.add(1n+e, J), i), VB.pw(dd), Order.add_right(J, Nat.add(1n+e, J), i, Order.left_below_sum(1n+e, J)), hji)
      +hJi2 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, J, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), J, ej), hJi)
      +eqj = FD.logic__subst(Nat, z => {U32.to_nat(U32.add(q, j)) == Nat.add(z, i) : Nat}, U32.to_nat(j), J, ej, VB.add_at(q, j, i, dd, eq, hd32, hJi2))
      +D1 = UW.ORW(dd, D, Nat.add(J, i), v)
      +ew = UW.wdr_con(UW.SLW(TS), J, hJ)
      +h1 = FD.nat__le_lt_trans(1n+J, 1n+Nat.add(e, J), VB.pw(ds), Order.left_below_sum(e, J), hjs)
      +ej1 = VB.add_at(j, 1, J, ds, ej, hds32, h1)
      +hjs1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(ds)) == True{} : Bool}, 1n+Nat.add(e, J), Nat.add(e, 1n+J), Equal.sym(Nat, Nat.add(e, 1n+J), 1n+Nat.add(e, J), FD.nat__add_succ(e, J)), hjs)
      +hji1 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(e, J), Nat.add(e, 1n+J), Equal.sym(Nat, Nat.add(e, 1n+J), 1n+Nat.add(e, J), FD.nat__add_succ(e, J)), hji)
      +ih = pwor(e, U32.add(j, 1), 1n+J, q, i, U32.shrn(w, @UPn), dd, ds, D1, TS, ej1, eq, hd, hds, hjs1, hji1, UW.orw_perfect(dd, D, Nat.add(J, i), v, pfD), pfS)
      %Equal.sym(List<&2, U32>, VB.wdr(J, UW.SLW(TS)), Con{w, VB.wdr(1n+J, UW.SLW(TS))}, ew) :
        {O.pw_or@S(1n+e, j, q, c, FD.array__thaw(U32, D), (FD.array__thaw(U32, TS), w)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(2n+e, _), dd, D, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(2n+e, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(List<&2, U32>, VB.wdr(J, UW.SLW(TS)), Con{w, VB.wdr(1n+J, UW.SLW(TS))}, ew) :
        {O.pw_or@S(1n+e, j, q, c, FD.array__thaw(U32, D), (FD.array__thaw(U32, TS), w)) == (FD.array__thaw(U32, UW.SWo(@S, Con{w, VS.wtake(1n+e, VB.wdr(1n+J, UW.SLW(TS)))}, dd, D, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(2n+e, _), c))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, D), U32.add(q, j), v), FD.array__thaw(U32, D1), UW.orw_rt(dd, D, U32.add(q, j), Nat.add(J, i), v, eqj, hd32, hJi, pfD)) :
        {O.pw_or@S(e, U32.add(j, 1), q, U32.shrn(w, @UPn), _, Array.get(U32, FD.array__thaw(U32, TS), U32.add(j, 1))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+e, VB.wdr(1n+J, UW.SLW(TS))), dd, D1, 1n+Nat.add(J, i), U32.shrn(w, @UPn))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+e, VB.wdr(1n+J, UW.SLW(TS))), U32.shrn(w, @UPn)))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), U32.add(j, 1)), (FD.array__thaw(U32, TS), VB.slot(TS, 1n+J)), VB.get_n(ds, TS, U32.add(j, 1), 1n+J, ej1, hds32, h1, pfS)) :
        {O.pw_or@S(e, U32.add(j, 1), q, U32.shrn(w, @UPn), FD.array__thaw(U32, D1), _) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+e, VB.wdr(1n+J, UW.SLW(TS))), dd, D1, 1n+Nat.add(J, i), U32.shrn(w, @UPn))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+e, VB.wdr(1n+J, UW.SLW(TS))), U32.shrn(w, @UPn)))) : Array<U32> & (Array<U32> & U32)}
      ih

# The shifted copy of the run's middle words (mid of them, none when mid is zero).
def pmid_f(+M: Nat, +mid: U32, +q: U32, +i: Nat, +dd: Nat, +ds: Nat, +D1: FD.array__Tree<U32>, +TS: FD.array__Tree<U32>,
    +em: {U32.to_nat(mid) == M : Nat}, +eb: {U32.is_eq(mid, 0) == False{} : Bool}, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hms: {Nat.is_lt(M, VB.pw(ds)) == True{} : Bool}, +hmd: {Nat.is_le(Nat.add(M, 1n+i), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(A.quad(M), VS.bdr(A.quad(1n+i), UA.BYT(D1))) == UW.ZB(A.quad(M)) : +List<U32>},
    +pfD: {FD.array__perfect(U32, dd, D1) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.@PWMID_run(False{}, mid, q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), O.shr_over(VB.slot(TS, 0n), @S)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, O.shr_over(VB.slot(TS, 0n), @S))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), O.shr_over(VB.slot(TS, 0n), @S)))) : Array<U32> & (Array<U32> & U32)}:
  match M:
    case 0n:
      +e0 = FD.u32__injective(mid, 0, em)
      Empty.absurd({O.@PWMID_run(False{}, mid, q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), O.shr_over(VB.slot(TS, 0n), @S)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(0n, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, O.shr_over(VB.slot(TS, 0n), @S))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(0n, VB.wdr(1n, UW.SLW(TS))), O.shr_over(VB.slot(TS, 0n), @S)))) : Array<U32> & (Array<U32> & U32)},
        FD.logic__true_false(FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, mid, 0, e0, eb)))
    case 1n+ +p:
      +C1 = O.shr_over(VB.slot(TS, 0n), @S)
      +SL = UW.SLW(TS)
      +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
      +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
      +lt1 = FD.nat__lt_le_trans(1n+i, 1n+Nat.add(p, 1n+i), VB.pw(dd), FD.nat__lt_le_trans(i, 1n+i, Nat.add(p, 1n+i), FD.nat__lt_succ(i), Order.left_below_sum(p, 1n+i)), hmd)
      +eq1 = VB.add_at(q, 1, i, dd, eq, hd32, lt1)
      +hle = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(ds)) == True{} : Bool}, 1n+p, Nat.add(1n+p, 0n), Equal.sym(Nat, Nat.add(1n+p, 0n), 1n+p, FD.nat__add_zero(1n+p)), FD.nat__lt_le(1n+p, VB.pw(ds), hms))
      +hi = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 0n), VB.pw(ds)) == True{} : Bool}, 1n+p, U32.to_nat(mid), Equal.sym(Nat, U32.to_nat(mid), 1n+p, em), hle)
      +hj = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n+i), VB.pw(dd)) == True{} : Bool}, 1n+p, U32.to_nat(mid), Equal.sym(Nat, U32.to_nat(mid), 1n+p, em), hmd)
      +sc = USC.@SCOPY_ok(mid, 0, U32.add(q, 1), 0n, 1n+i, dd, ds, D1, TS, {==}, eq1, hd, hds, hi, hj, pfD, pfS)
      +hx = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(ds)) == True{} : Bool}, 1n+p, Nat.add(1n+p, 0n), Equal.sym(Nat, Nat.add(1n+p, 0n), 1n+p, FD.nat__add_zero(1n+p)), hms)
      +sm = sm_swo(1n+p, 0n, 1n+i, dd, ds, D1, TS, pfD, pfS, hx, hmd, hz)
      +hl = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(UW.SLW(TS))) == True{} : Bool}, 1n+p, Nat.add(p, 1n),
        Equal.sym(Nat, Nat.add(p, 1n), 1n+p, Equal.trans(Nat, Nat.add(p, 1n), 1n+Nat.add(p, 0n), 1n+p, FD.nat__add_succ(p, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(p, 0n), p, FD.nat__add_zero(p)))),
        FD.logic__subst(Nat, z => {Nat.is_lt(1n+p, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hms))
      +ecry = Equal.trans(U32, UW.CRY(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), C1), O.shr_over(FD.flat__nthc(UW.SLW(TS), Nat.add(p, 1n)), @S), O.shr_over(FD.flat__nthc(UW.SLW(TS), 1n+p), @S),
        UW.cry_take(@S, p, 1n, UW.SLW(TS), C1, hl),
        Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(UW.SLW(TS), z), @S), Nat.add(p, 1n), 1n+p,
          Equal.trans(Nat, Nat.add(p, 1n), 1n+Nat.add(p, 0n), 1n+p, FD.nat__add_succ(p, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(p, 0n), p, FD.nat__add_zero(p)))))
      %Equal.sym(Array<U32> & Array<U32>, O.@SCOPY(mid, 0, U32.add(q, 1), FD.array__thaw(U32, D1), FD.array__thaw(U32, TS)), (FD.array__thaw(U32, UC.smone(@Rn, U32.to_nat(mid), 0n, 1n+i, dd, ds, D1, TS)), FD.array__thaw(U32, TS)), sc) :
        {O.@PWMID_carry(mid, _) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), C1))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), mid), (FD.array__thaw(U32, TS), VB.slot(TS, 1n+p)), VB.get_n(ds, TS, mid, 1n+p, em, hds32, hms, pfS)) :
        {O.@PWMID_c(FD.array__thaw(U32, UC.smone(@Rn, U32.to_nat(mid), 0n, 1n+i, dd, ds, D1, TS)), _) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), C1))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(Nat, U32.to_nat(mid), 1n+p, em) :
        {(FD.array__thaw(U32, UC.smone(@Rn, _, 0n, 1n+i, dd, ds, D1, TS)), (FD.array__thaw(U32, TS), U32.shrn(VB.slot(TS, 1n+p), @UPn))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), C1))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(FD.array__Tree<U32>, UC.smone(@Rn, 1n+p, 0n, 1n+i, dd, ds, D1, TS), UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1), sm) :
        {(FD.array__thaw(U32, _), (FD.array__thaw(U32, TS), U32.shrn(VB.slot(TS, 1n+p), @UPn))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), C1))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(U32, UW.CRY(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), C1), O.shr_over(FD.flat__nthc(UW.SLW(TS), 1n+p), @S), ecry) :
        {(FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)), (FD.array__thaw(U32, TS), U32.shrn(VB.slot(TS, 1n+p), @UPn))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)), (FD.array__thaw(U32, TS), _)) : Array<U32> & (Array<U32> & U32)}
      {==}

def pmid_b(+b: Bool, +M: Nat, +mid: U32, +q: U32, +i: Nat, +dd: Nat, +ds: Nat, +D1: FD.array__Tree<U32>, +TS: FD.array__Tree<U32>,
    +em: {U32.to_nat(mid) == M : Nat}, +eb: {U32.is_eq(mid, 0) == b : Bool}, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hms: {Nat.is_lt(M, VB.pw(ds)) == True{} : Bool}, +hmd: {Nat.is_le(Nat.add(M, 1n+i), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(A.quad(M), VS.bdr(A.quad(1n+i), UA.BYT(D1))) == UW.ZB(A.quad(M)) : +List<U32>},
    +pfD: {FD.array__perfect(U32, dd, D1) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.@PWMID_run(b, mid, q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), O.shr_over(VB.slot(TS, 0n), @S)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, O.shr_over(VB.slot(TS, 0n), @S))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), O.shr_over(VB.slot(TS, 0n), @S)))) : Array<U32> & (Array<U32> & U32)}:
  match b:
    case True{}:
      +e0 = Equal.trans(Nat, 0n, U32.to_nat(mid), M, Equal.cong(U32, Nat, z => U32.to_nat(z), 0, mid, Equal.sym(U32, mid, 0, FD.u32alg__eq_of(mid, 0, eb))), em)
      %e0 : {(FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), O.shr_over(VB.slot(TS, 0n), @S))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(_, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, O.shr_over(VB.slot(TS, 0n), @S))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), O.shr_over(VB.slot(TS, 0n), @S)))) : Array<U32> & (Array<U32> & U32)}
      %e0 : {(FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), O.shr_over(VB.slot(TS, 0n), @S))) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(0n, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, O.shr_over(VB.slot(TS, 0n), @S))), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(_, VB.wdr(1n, UW.SLW(TS))), O.shr_over(VB.slot(TS, 0n), @S)))) : Array<U32> & (Array<U32> & U32)}
      {==}
    case False{}: pmid_f(M, mid, q, i, dd, ds, D1, TS, em, eb, eq, hd, hds, hms, hmd, hz, pfD, pfS)

# The OR loop over the run's last words (k of them, none when k is zero).
def ptail_f(+KN: Nat, +K: U32, +j: U32, +J: Nat, +q: U32, +i: Nat, +c: U32, +dd: Nat, +ds: Nat, +D2: FD.array__Tree<U32>, +TS: FD.array__Tree<U32>,
    +ek: {U32.to_nat(K) == KN : Nat}, +eb: {U32.is_eq(K, 0) == False{} : Bool}, +ej: {U32.to_nat(j) == J : Nat}, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hjs: {Nat.is_le(Nat.add(KN, J), VB.pw(ds)) == True{} : Bool}, +hji: {Nat.is_le(Nat.add(Nat.add(KN, J), i), VB.pw(dd)) == True{} : Bool},
    +pfD: {FD.array__perfect(U32, dd, D2) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.@PWOR_run(False{}, j, K, q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), c) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(KN, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(KN, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}:
  match KN:
    case 0n:
      +e0 = FD.u32__injective(K, 0, ek)
      Empty.absurd({O.@PWOR_run(False{}, j, K, q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), c) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(0n, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(0n, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)},
        FD.logic__true_false(FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, K, 0, e0, eb)))
    case 1n+ +p:
      +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
      +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+p, U32.to_nat(K), Equal.sym(Nat, U32.to_nat(K), 1n+p, ek), FD.nat__zero_le(p))
      +ek1 = Equal.trans(Nat, U32.to_nat(U32.sub(K, 1)), Nat.sub(p, 0n), p,
        FD.logic__subst(Nat, z => {U32.to_nat(U32.sub(K, 1)) == Nat.sub(z, 1n) : Nat}, U32.to_nat(K), 1n+p, ek, FD.u32__sub_nat(K, 1, h1)), FD.nat__sub_zero(p))
      +hJs = FD.nat__le_lt_trans(J, Nat.add(p, J), VB.pw(ds), Order.left_below_sum(p, J), FD.nat__succ_le_lt(Nat.add(p, J), VB.pw(ds), hjs))
      +hjs1 = FD.nat__succ_le_lt(Nat.add(p, J), VB.pw(ds), hjs)
      +hji1 = FD.nat__succ_le_lt(Nat.add(Nat.add(p, J), i), VB.pw(dd), hji)
      %Equal.sym(Nat, U32.to_nat(U32.sub(K, 1)), p, ek1) :
        {O.@PWOR(_, j, q, c, FD.array__thaw(U32, D2), Array.get(U32, FD.array__thaw(U32, TS), j)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+p, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
      %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), j), (FD.array__thaw(U32, TS), VB.slot(TS, J)), VB.get_n(ds, TS, j, J, ej, hds32, hJs, pfS)) :
        {O.@PWOR(p, j, q, c, FD.array__thaw(U32, D2), _) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(1n+p, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n+p, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
      pwor(p, j, J, q, i, c, dd, ds, D2, TS, ej, eq, hd, hds, hjs1, hji1, pfD, pfS)

def ptail_b(+b: Bool, +KN: Nat, +K: U32, +j: U32, +J: Nat, +q: U32, +i: Nat, +c: U32, +dd: Nat, +ds: Nat, +D2: FD.array__Tree<U32>, +TS: FD.array__Tree<U32>,
    +ek: {U32.to_nat(K) == KN : Nat}, +eb: {U32.is_eq(K, 0) == b : Bool}, +ej: {U32.to_nat(j) == J : Nat}, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hjs: {Nat.is_le(Nat.add(KN, J), VB.pw(ds)) == True{} : Bool}, +hji: {Nat.is_le(Nat.add(Nat.add(KN, J), i), VB.pw(dd)) == True{} : Bool},
    +pfD: {FD.array__perfect(U32, dd, D2) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.@PWOR_run(b, j, K, q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), c) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(KN, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(KN, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}:
  match b:
    case True{}:
      +e0 = Equal.trans(Nat, 0n, U32.to_nat(K), KN, Equal.cong(U32, Nat, z => U32.to_nat(z), 0, K, Equal.sym(U32, K, 0, FD.u32alg__eq_of(K, 0, eb))), ek)
      %e0 : {(FD.array__thaw(U32, D2), (FD.array__thaw(U32, TS), c)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(_, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(KN, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
      %e0 : {(FD.array__thaw(U32, D2), (FD.array__thaw(U32, TS), c)) == (FD.array__thaw(U32, UW.SWo(@S, VS.wtake(0n, VB.wdr(J, UW.SLW(TS))), dd, D2, Nat.add(J, i), c)), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(_, VB.wdr(J, UW.SLW(TS))), c))) : Array<U32> & (Array<U32> & U32)}
      {==}
    case False{}: ptail_f(KN, K, j, J, q, i, c, dd, ds, D2, TS, ek, eb, ej, eq, hd, hds, hjs, hji, pfD, pfS)

# The carry into the word after the run.
def pcarry_b(+b: Bool, +dd: Nat, +D3: FD.array__Tree<U32>, +TS: FD.array__Tree<U32>, +a: U32, +A2: Nat, +c: U32, +ea: {U32.to_nat(a) == A2 : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hA: {Nat.is_lt(A2, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D3) == True{} : Bool})
    -> {O.pw_carry_skip(b, a, FD.array__thaw(U32, D3), FD.array__thaw(U32, TS), c) == (FD.array__thaw(U32, UW.ORSb(b, dd, D3, A2, c)), FD.array__thaw(U32, TS)) : Array<U32> & Array<U32>}:
  match b:
    case True{}: {==}
    case False{}:
      %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, D3), a, c), FD.array__thaw(U32, UW.ORW(dd, D3, A2, c)), UW.orw_rt(dd, D3, a, A2, c, ea, FD.nat__lt_trans(dd, 31n, 32n, hd, {==}), hA, pf)) :
        {(_, FD.array__thaw(U32, TS)) == (FD.array__thaw(U32, UW.ORW(dd, D3, A2, c)), FD.array__thaw(U32, TS)) : Array<U32> & Array<U32>}
      {==}

# The runtime's byte-range write of the n > 0 bytes held in TS at byte @S of word i
# (pos = 4 i + @S) is the model SWc of the source's first NW(n) words, when the output's
# bytes there were zero.
def putwu(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), @Sn) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(i), @Sn), UA.BYT(U))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  +SL = UW.SLW(TS)
  +NWU = VC.nwu(n)
  +NW = VC.NW(n)
  +Q = U32.shrn(pos, 2n)
  +MID = O.pw_mid(n, @S, VC.nwu(n))
  +M = U32.to_nat(O.pw_mid(n, @S, VC.nwu(n)))
  +K = U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, @S, VC.nwu(n)))
  +KN = U32.to_nat(U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, @S, VC.nwu(n))))
  +C1 = O.shr_over(VB.slot(TS, 0n), @S)
  +e3 = UW.ua_3(pos, i, @Sn, @S, {==}, e, {==})
  +eq = UW.ua_q(pos, i, @Sn, e, {==})
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
  +W1 = U32.to_nat(U32.sub(VC.nwu(n), 1))
  +eW1 = FD.u32__sub_nat(VC.nwu(n), 1, hNW1)
  +hM = UW.mid_le_g(U32.is_lt(U32.add(n, @S), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, @S), 4), 2n)), U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, @S), 4), 2n), {==})
  +eKN = FD.u32__sub_nat(U32.sub(VC.nwu(n), 1), O.pw_mid(n, @S, VC.nwu(n)), hM)
  +eMK = Equal.trans(Nat, Nat.add(M, KN), Nat.add(M, Nat.sub(W1, M)), W1, Equal.cong(Nat, Nat, z => Nat.add(M, z), KN, Nat.sub(W1, M), eKN), FD.nat__sub_add(W1, M, hM))
  +eNW = Equal.trans(Nat, 1n+Nat.add(M, KN), 1n+W1, NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(M, KN), W1, eMK),
    Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)))
  +h1M = FD.logic__subst(Nat, z => {Nat.is_le(1n+M, z) == True{} : Bool}, 1n+W1, NW, Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)), hM)
  +hms = FD.nat__lt_le_trans(M, NW, VB.pw(ds), FD.nat__succ_le_lt(M, NW, h1M), hnw)
  +hmd = FD.nat__le_trans(Nat.add(M, 1n+i), Nat.add(NW, i), VB.pw(dd),
    FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(NW, i)) == True{} : Bool}, Nat.add(1n+M, i), Nat.add(M, 1n+i), Equal.sym(Nat, Nat.add(M, 1n+i), 1n+Nat.add(M, i), FD.nat__add_succ(M, i)), Order.add_right(1n+M, NW, i, h1M)),
    FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +eKM = Equal.trans(Nat, Nat.add(KN, 1n+M), 1n+Nat.add(KN, M), NW, FD.nat__add_succ(KN, M),
    Equal.trans(Nat, 1n+Nat.add(KN, M), 1n+Nat.add(M, KN), NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(KN, M), Nat.add(M, KN), FD.nat__add_comm(KN, M)), eNW))
  +hjs = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(ds)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), hnw)
  +hji = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +ej = VB.add_at(O.pw_mid(n, @S, VC.nwu(n)), 1, M, 1n+ds, {==}, VB.lt32s(ds, hds), VB.le_pw_lt(1n+M, ds, FD.nat__le_trans(1n+M, NW, VB.pw(ds), h1M, hnw)))
  +h0s = FD.nat__lt_le_trans(0n, NW, VB.pw(ds), FD.nat__lt_le_trans(0n, 1n, NW, {==}, hNW1), hnw)
  +hi0 = FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl)
  +D1 = UW.SWo(@S, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0)
  +pf1 = UW.swo_perfect(@S, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0, pf)
  +D2 = UW.SWo(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)
  +C2 = UW.CRY(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), C1)
  +pf2 = UW.swo_perfect(@S, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1, pf1)
  +D3 = UW.SWo(@S, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2)
  +C3 = UW.CRY(@S, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), C2)
  +pf3 = UW.swo_perfect(@S, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2, pf2)
  +X0 = Nat.add(A.quad(i), @Sn)
  +B = UA.BYT(U)
  +hle = FD.nat__le_trans(Nat.add(@Rn, A.quad(M)), 4n+A.quad(M), A.quad(NW), Order.add_right(@Rn, 4n, A.quad(M), {==}), UW.quad_le(1n+M, NW, h1M))
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, @Rn), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, @Rn), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), @Sn, @Rn)))
  +zU = Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(@Rn, VS.bdr(X0, B))), UW.ZB(A.quad(M)),
    Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(Nat.add(X0, @Rn), B)), VS.bt(A.quad(M), VS.bdr(@Rn, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt(A.quad(M), VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, @Rn), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(A.quad(M), z), VS.bdr(Nat.add(X0, @Rn), B), VS.bdr(@Rn, VS.bdr(X0, B)), UW.bdr_add(X0, @Rn, B))),
    Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(@Rn, VS.bdr(X0, B))), VS.bt(A.quad(M), VS.bdr(@Rn, VS.bt(A.quad(NW), VS.bdr(X0, B)))), UW.ZB(A.quad(M)),
      UW.bt_bdr_bt(A.quad(M), @Rn, A.quad(NW), VS.bdr(X0, B), hle),
      FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(M), VS.bdr(@Rn, z)) == UW.ZB(A.quad(M)) : +List<U32>}, UW.ZB(A.quad(NW)), VS.bt(A.quad(NW), VS.bdr(X0, B)),
        Equal.sym(+List<U32>, VS.bt(A.quad(NW), VS.bdr(X0, B)), UW.ZB(A.quad(NW)), hz), UW.zb_win(@Rn, A.quad(M), A.quad(NW), hle))))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), U32.or(O.shl_bytes(VB.slot(TS, 0n), @S), 0)), pf, hi0)
  +eA1 = Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n, z), UW.SLW(TS), Con{VB.slot(TS, 0n), VB.wdr(1n, UW.SLW(TS))},
    UW.wdr_con(UW.SLW(TS), 0n, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s)))
  +eD1 = Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(@S, z, dd, U, i, 0), VS.wtake(1n, UW.SLW(TS)), [VB.slot(TS, 0n)], eA1)
  +hz1a = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(M), z) == UW.ZB(A.quad(M)) : +List<U32>}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(@S, [VB.slot(TS, 0n)], dd, U, i, 0))),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(@S, [VB.slot(TS, 0n)], dd, U, i, 0))), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hz1 = FD.logic__subst(FD.array__Tree<U32>, z => {VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), UA.BYT(z))) == UW.ZB(A.quad(M)) : +List<U32>}, UW.SWo(@S, [VB.slot(TS, 0n)], dd, U, i, 0), D1,
    Equal.sym(FD.array__Tree<U32>, D1, UW.SWo(@S, [VB.slot(TS, 0n)], dd, U, i, 0), eD1), hz1a)
  +eC1 = UW.cry_take(@S, 0n, 0n, UW.SLW(TS), 0, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s))
  +pw1 = pwor(0n, 0, 0n, Q, i, 0, dd, ds, U, TS, {==}, eq, hd, hds, h0s, FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl), pf, pfS)
  +pm = pmid_b(U32.is_eq(MID, 0), M, MID, Q, i, dd, ds, D1, TS, {==}, {==}, eq, hd, hds, hms, hmd, hz1, pf1, pfS)
  +pt = ptail_b(U32.is_eq(K, 0), KN, K, U32.add(MID, 1), 1n+M, Q, i, C2, dd, ds, D2, TS, {==}, {==}, ej, eq, hd, hds, hjs, hji, pf2, pfS)
  +pc = pcarry_b(U32.is_eq(C3, 0), dd, D3, TS, U32.add(Q, NWU), Nat.add(NW, i), C3, VB.add_at(Q, NWU, i, dd, eq, hd32, hl), hd, hl, pf3)
  +fin = FD.logic__subst(Nat, z => {UW.ORS(dd, D3, Nat.add(z, i), C3) == UW.SWc(@S, VS.wtake(z, UW.SLW(TS)), dd, U, i, 0) : FD.array__Tree<U32>}, 1n+Nat.add(M, KN), NW, eNW,
    UW.asm(@S, dd, U, i, UW.SLW(TS), M, KN, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(UW.SLW(TS))) == True{} : Bool}, NW, 1n+Nat.add(M, KN), Equal.sym(Nat, 1n+Nat.add(M, KN), NW, eNW),
      FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hnw))))
  %Equal.sym(Bool, U32.is_eq(n, 0), False{}, hn) : {O.put_fin(n, O.pw_empty(_, U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), @S, e3) : {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), @S, e3) : {O.put_fin(n, O.pw_un(_, n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), 0), (FD.array__thaw(U32, TS), VB.slot(TS, 0n)), VB.get_n(ds, TS, 0, 0n, {==}, hds32, h0s, pfS)) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.@PWOR_at(U32.add(MID, 1), K, Q, O.@PWMID(MID, Q, O.@PWOR(0n, 0, Q, 0, FD.array__thaw(U32, U), _))))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.@PWOR(0n, 0, Q, 0, FD.array__thaw(U32, U), (FD.array__thaw(U32, TS), VB.slot(TS, 0n))), (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), UW.CRY(@S, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0))), pw1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.@PWOR_at(U32.add(MID, 1), K, Q, O.@PWMID(MID, Q, _)))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, UW.CRY(@S, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0), C1, eC1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.@PWOR_at(U32.add(MID, 1), K, Q, O.@PWMID(MID, Q, (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), _)))))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.@PWMID_run(U32.is_eq(MID, 0), MID, Q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), C1), (FD.array__thaw(U32, D2), (FD.array__thaw(U32, TS), C2)), pm) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.@PWOR_at(U32.add(MID, 1), K, Q, _))) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.@PWOR_run(U32.is_eq(K, 0), U32.add(MID, 1), K, Q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), C2), (FD.array__thaw(U32, D3), (FD.array__thaw(U32, TS), C3)), pt) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), _)) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & Array<U32>, O.pw_carry_skip(U32.is_eq(C3, 0), U32.add(Q, NWU), FD.array__thaw(U32, D3), FD.array__thaw(U32, TS), C3), (FD.array__thaw(U32, UW.ORSb(U32.is_eq(C3, 0), dd, D3, Nat.add(NW, i), C3)), FD.array__thaw(U32, TS)), pc) :
    {O.put_fin(n, _) == (FD.array__thaw(U32, UW.SWc(@S, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  Equal.cong(FD.array__Tree<U32>, Array<U32> & O.Words, z => (FD.array__thaw(U32, z), O.Words{FD.array__thaw(U32, TS), n}), UW.ORS(dd, D3, Nat.add(NW, i), C3), UW.SWc(@S, VS.wtake(NW, UW.SLW(TS)), dd, U, i, 0), fin)
'''


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
         '# GENERATED by codegen/var_uw.py. Do not edit.',
         f'# The byte-vector writers at byte {s} of a word: the tree model SWc (see codegen/var_uw.py).', '']
    for p, n, W, kk, unit in WORDSF:
        OBJ = f'O.Words{{FD.array__thaw(U32, TB), {n}}}'
        RHS = f'(FD.array__thaw(U32, UW.SWc({s}, VS.wtake({W}n, UW.SLW(TB)), dd, U, i, 0)), ({OBJ}, 0))'
        TY = 'Array<U32> & (O.Words & U32)'
        L.append(f'''# {p} ({n} bytes) at byte {s} of word i.
def wputu_{p}(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +dB: Nat, +TB: FD.array__Tree<U32>,
    +e: {{U32.to_nat(pos) == Nat.add(A.quad(i), {s}n) : Nat}}, +hd: {{Nat.is_lt(dd, 31n) == True{{}} : Bool}},
    +hl: {{Nat.is_lt(Nat.add({W}n, i), VB.pw(dd)) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, dd, U) == True{{}} : Bool}},
    +pfB: {{FD.array__perfect(U32, dB, TB) == True{{}} : Bool}}, +hdB: {{Nat.is_lt(dB, 31n) == True{{}} : Bool}}, +hrB: {{Nat.is_le({W}n, VB.pw(dB)) == True{{}} : Bool}},
    +hz: {{VS.bt({4 * W}n, VS.bdr(Nat.add(A.quad(i), {s}n), UA.BYT(U))) == UW.ZB({4 * W}n) : +List<U32>}})
    -> {{T.{p}_putk(FD.array__thaw(U32, U), pos, {OBJ}) == {RHS} : {TY}}}:
  +e3 = UW.ua_3(pos, i, {s}n, {s}, {{==}}, e, {{==}})
  %Equal.sym(O.Words & Bool, T.{p}_valid({OBJ}), ({OBJ}, True{{}}), VBE.words_ok_b(dB, TB, {n}, {n}, {n}, {kk}n, pfB, hdB, {{==}}, {{==}}, {{==}}, {{==}}, hrB, {{==}}, {unit}, {{==}})) :
    {{T.{p}_pk(FD.array__thaw(U32, U), pos, _) == {RHS} : {TY}}}
  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pk_ok(T.{p}_pw(U32.is_eq(_, 0), FD.array__thaw(U32, U), pos, FD.array__thaw(U32, TB), {n})) == {RHS} : {TY}}}
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, U), pos, {OBJ}), (FD.array__thaw(U32, UW.SWc({s}, VS.wtake({W}n, UW.SLW(TB)), dd, U, i, 0)), {OBJ}),
      UP.putwu(dd, U, pos, i, dB, TB, {n}, e, {{==}}, hd, hdB, {{==}}, hrB, hl, hz, pf, pfB)) :
    {{T.{p}_pk_ok(_) == {RHS} : {TY}}}
  {{==}}
''')
    return '\n'.join(L) + '\n'


def outputs():
    out = {OUT: emit()}
    for s in (1, 2, 3):
        out[ROOT / f'proofs/obj/vuw{s}.bend'] = swlb_text(s)
        out[ROOT / f'proofs/obj/vuwf{s}.bend'] = fixw_text(s)
        for w in FIXW1:
            out[ROOT / f'proofs/obj/vuwf{s}_{w[0]}.bend'] = fixw_text(s, [w])
        out[ROOT / f'proofs/obj/vuwp{s}.bend'] = putw_text(s)
        out[ROOT / f'proofs/obj/vuwk{s}.bend'] = wordsf_text(s)
    return out


def main():
    out = outputs()
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('unaligned write layer is current')
        return
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
