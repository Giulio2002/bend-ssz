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


def swlb_text(s):
    """proofs/obj/vuw<s>.bend: the list model's bytes at byte s (swlb)."""
    M, H, MUL = MS[s], HS[s], 256 ** s
    zs = 'UW.ZB(k)'
    for _ in range(s):
        zs = 'Con{0, ' + zs + '}'
    rep = {'@Sn': f'{s}n', '@Rn': f'{4 - s}n', '@SHn': f'{8 * s}n', '@UPn': f'{32 - 8 * s}n', '@MUL': str(MUL), '@M': str(M), '@H': str(H),
           '@PL': 's' if s > 1 else '', '@ZS': zs, '@S': str(s)}
    t = SWLB
    for k in sorted(rep, key=len, reverse=True):
        t = t.replace(k, rep[k])
    return t


# the fixed-size values the runtime writes word by word (b<p>_pw<s>): prefix, constructor, words
FIXW = [('b32', 'Bytes32', 8), ('b20', 'Bytes20', 5), ('u256', 'Uint256', 8)]


def fixw_text(s):
    """proofs/obj/vuwf<s>.bend: the runtime's writers of FIXW at byte s of word i are the
    model SWc (putu_<p>), when the value's bytes there were zero."""
    MUL, UP = 256 ** s, 32 - 8 * s
    L = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T', 'import ../compact/found.bend as FD',
         'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB',
         'import ./vua.bend as UA', 'import ./vuw_bits.bend as UWB', 'import ./vuw.bend as UW', '',
         '# GENERATED by codegen/var_uw.py. Do not edit.',
         f'# The runtime\'s word-by-word writers at byte {s} of a word: the tree model SWc (see codegen/var_uw.py).', '']
    TH = 'FD.array__thaw(U32, {})'
    for p, cons, N in FIXW:
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


def outputs():
    out = {OUT: emit()}
    for s in (1, 2, 3):
        out[ROOT / f'proofs/obj/vuw{s}.bend'] = swlb_text(s)
        out[ROOT / f'proofs/obj/vuwf{s}.bend'] = fixw_text(s)
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
