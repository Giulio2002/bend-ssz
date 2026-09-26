"""Closed bounds of the DataColumnSidecar encoder sizes, on U32 words (no unary Nat of millions): used by codegen/var_multi_enc.py."""
import re

X0, X1, QXV = 512 * 4096, 12 * 4096, 89 + 512 * 4096 + 2 * 12 * 4096
TRUE = 'True{} : Bool'


def tn(v):
    return f'U32.to_nat({v})'


def quadw(v):
    return f'U32.add(U32.add({v}, {v}), U32.add({v}, {v}))'


def pw_chain(name, fn, top):
    """{fn(topn) == U32.to_nat(2^top)} by steps pw_s(k, k1, ek, w, e, hc) (k1 = 1n+k stays a literal)."""
    L = [f'def {name}_s(+k: Nat, +k1: Nat, +ek: {{1n+k == k1 : Nat}}, +w: U32, +e: {{{fn}(k) == U32.to_nat(w) : Nat}},\n'
         f'    +hc: {{VA.CY(w, w) == False{{}} : Bool}}) -> {{{fn}(k1) == U32.to_nat(U32.add(w, w)) : Nat}}:\n'
         f'  %ek : {{{fn}(_) == U32.to_nat(U32.add(w, w)) : Nat}}\n'
         f'  Equal.trans(Nat, Nat.double({fn}(k)), Nat.double(U32.to_nat(w)), U32.to_nat(U32.add(w, w)),\n'
         f'    Equal.cong(Nat, Nat, z => Nat.double(z), {fn}(k), U32.to_nat(w), e), dblw(w, hc))\n']
    # one lemma per step (a nested proof term would be re-checked inline); step k's word is the literal 2^k,
    # so the next step compares U32.add(2^k, 2^k) with 2^(k+1) argument-wise, on words
    L.append(f'def {name}0() -> {{{fn}(0n) == U32.to_nat(1) : Nat}}: {{==}}\n')
    for k in range(top):
        w = 1 << k
        L.append(f'def {name}{k + 1}() -> {{{fn}({k + 1}n) == U32.to_nat({2 * w}) : Nat}}:\n'
                 f'  Equal.trans(Nat, {fn}({k + 1}n), U32.to_nat(U32.add({w}, {w})), U32.to_nat({2 * w}), {name}_s({k}n, {k + 1}n, {{==}}, {w}, {name}{k}(), {{==}}),\n'
                 f'    Equal.cong(U32, Nat, z => U32.to_nat(z), U32.add({w}, {w}), {2 * w}, {{==}}))\n')
    return '\n'.join(L)


def text():
    q = quadw(QXV)
    return f'''
# ---- the closed bounds, on U32 words ------------------------------------------------------------
# Unary Nat arithmetic on these millions costs tens of seconds (and a def compared with its body
# evaluates the number): every closed quantity is U32.to_nat of a word, sums and quads go through
# VA.add_nc (the carry is decided on the words), comparisons through VA.le_nat.

def dblw(+w: U32, +hc: {{VA.CY(w, w) == False{{}} : Bool}}) -> {{Nat.double(U32.to_nat(w)) == U32.to_nat(U32.add(w, w)) : Nat}}:
  +n = U32.to_nat(w)
  Equal.trans(Nat, Nat.double(n), Nat.add(n, Nat.add(n, 0n)), U32.to_nat(U32.add(w, w)), FD.u32__double_pow(n),
    Equal.trans(Nat, Nat.add(n, Nat.add(n, 0n)), Nat.add(n, n), U32.to_nat(U32.add(w, w)),
      Equal.cong(Nat, Nat, z => Nat.add(n, z), Nat.add(n, 0n), n, FD.nat__add_zero(n)), Equal.sym(Nat, U32.to_nat(U32.add(w, w)), Nat.add(n, n), VA.add_nc(w, w, hc))))

def quadw(+w: U32, +h1: {{VA.CY(w, w) == False{{}} : Bool}}, +h2: {{VA.CY(U32.add(w, w), U32.add(w, w)) == False{{}} : Bool}})
    -> {{A.quad(U32.to_nat(w)) == U32.to_nat({quadw('w')}) : Nat}}:
  Equal.trans(Nat, Nat.double(Nat.double(U32.to_nat(w))), Nat.double(U32.to_nat(U32.add(w, w))), U32.to_nat({quadw('w')}),
    Equal.cong(Nat, Nat, z => Nat.double(z), Nat.double(U32.to_nat(w)), U32.to_nat(U32.add(w, w)), dblw(w, h1)), dblw(U32.add(w, w), h2))

# a Nat bound z <= to_nat(b) from the words: to_nat(a) == z and a <= b
def lew(+z: Nat, +a: U32, +b: U32, +e: {{U32.to_nat(a) == z : Nat}}, +h: {{U32.is_le(a, b) == True{{}} : Bool}}) -> {{Nat.is_le(z, U32.to_nat(b)) == {TRUE}}}:
  FD.logic__subst(Nat, y => {{Nat.is_le(y, U32.to_nat(b)) == {TRUE}}}, U32.to_nat(a), z, e, VA.le_nat(a, b, h))

{pw_chain('pws', 'VB.pw', 24)}
{pw_chain('pwn', 'O.pow2n', 23)}
def eM0() -> {{VM.mulE(512n, U32.to_nat(4096)) == {tn(X0)} : Nat}}: FD.nat__eq_from_is_eq(VM.mulE(512n, U32.to_nat(4096)), {tn(X0)}, {{==}})
def eM1() -> {{VM.mulE(12n, U32.to_nat(4096)) == {tn(X1)} : Nat}}: FD.nat__eq_from_is_eq(VM.mulE(12n, U32.to_nat(4096)), {tn(X1)}, {{==}})
def lM512(+c: Nat, +h: {{Nat.is_le(c, U32.to_nat(4096)) == {TRUE}}}) -> {{Nat.is_le(VM.mulE(512n, c), {tn(X0)}) == {TRUE}}}:
  %eM0() : {{Nat.is_le(VM.mulE(512n, c), _) == {TRUE}}}
  VME.mulE_mono(512n, c, U32.to_nat(4096), h)
def lM12(+c: Nat, +h: {{Nat.is_le(c, U32.to_nat(4096)) == {TRUE}}}) -> {{Nat.is_le(VM.mulE(12n, c), {tn(X1)}) == {TRUE}}}:
  %eM1() : {{Nat.is_le(VM.mulE(12n, c), _) == {TRUE}}}
  VME.mulE_mono(12n, c, U32.to_nat(4096), h)
def e89() -> {{U32.to_nat(89) == 89n : Nat}}: FD.nat__eq_from_is_eq(U32.to_nat(89), 89n, {{==}})
def e31() -> {{U32.to_nat(31) == 31n : Nat}}: FD.nat__eq_from_is_eq(U32.to_nat(31), 31n, {{==}})

# 89 + X0 + X1 + X1 == QX, on words
def eQX() -> {{Nat.add(Nat.add(Nat.add(89n, {tn(X0)}), {tn(X1)}), {tn(X1)}) == {tn(QXV)} : Nat}}:
  +A1 = U32.add(89, {X0})
  +A2 = U32.add(A1, {X1})
  +A3 = U32.add(A2, {X1})
  +s = Equal.trans(Nat, Nat.add(Nat.add(Nat.add(U32.to_nat(89), {tn(X0)}), {tn(X1)}), {tn(X1)}), Nat.add(Nat.add(U32.to_nat(A1), {tn(X1)}), {tn(X1)}), U32.to_nat(A3),
    Equal.cong(Nat, Nat, z => Nat.add(Nat.add(z, {tn(X1)}), {tn(X1)}), Nat.add(U32.to_nat(89), {tn(X0)}), U32.to_nat(A1), Equal.sym(Nat, U32.to_nat(A1), Nat.add(U32.to_nat(89), {tn(X0)}), VA.add_nc(89, {X0}, {{==}}))),
    Equal.trans(Nat, Nat.add(Nat.add(U32.to_nat(A1), {tn(X1)}), {tn(X1)}), Nat.add(U32.to_nat(A2), {tn(X1)}), U32.to_nat(A3),
      Equal.cong(Nat, Nat, z => Nat.add(z, {tn(X1)}), Nat.add(U32.to_nat(A1), {tn(X1)}), U32.to_nat(A2), Equal.sym(Nat, U32.to_nat(A2), Nat.add(U32.to_nat(A1), {tn(X1)}), VA.add_nc(A1, {X1}, {{==}}))),
      Equal.sym(Nat, U32.to_nat(A3), Nat.add(U32.to_nat(A2), {tn(X1)}), VA.add_nc(A2, {X1}, {{==}}))))
  Equal.trans(Nat, Nat.add(Nat.add(Nat.add(89n, {tn(X0)}), {tn(X1)}), {tn(X1)}), Nat.add(Nat.add(Nat.add(U32.to_nat(89), {tn(X0)}), {tn(X1)}), {tn(X1)}), {tn(QXV)},
    Equal.cong(Nat, Nat, z => Nat.add(Nat.add(Nat.add(z, {tn(X0)}), {tn(X1)}), {tn(X1)}), 89n, U32.to_nat(89), Equal.sym(Nat, U32.to_nat(89), 89n, e89())),
    Equal.trans(Nat, Nat.add(Nat.add(Nat.add(U32.to_nat(89), {tn(X0)}), {tn(X1)}), {tn(X1)}), U32.to_nat(A3), {tn(QXV)}, s,
      Equal.cong(U32, Nat, z => U32.to_nat(z), A3, {QXV}, {{==}})))

def eqQX() -> {{A.quad({tn(QXV)}) == U32.to_nat({q}) : Nat}}: quadw({QXV}, {{==}}, {{==}})

def cQ() -> {{Nat.is_le(Nat.add(31n, A.quad({tn(QXV)})), VB.pw(24n)) == {TRUE}}}:
  +e = Equal.trans(Nat, Nat.add(31n, A.quad({tn(QXV)})), Nat.add(U32.to_nat(31), U32.to_nat({q})), U32.to_nat(U32.add(31, {q})),
    Equal.trans(Nat, Nat.add(31n, A.quad({tn(QXV)})), Nat.add(U32.to_nat(31), A.quad({tn(QXV)})), Nat.add(U32.to_nat(31), U32.to_nat({q})),
      Equal.cong(Nat, Nat, z => Nat.add(z, A.quad({tn(QXV)})), 31n, U32.to_nat(31), Equal.sym(Nat, U32.to_nat(31), 31n, e31())),
      Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(31), z), A.quad({tn(QXV)}), U32.to_nat({q}), eqQX())),
    Equal.sym(Nat, U32.to_nat(U32.add(31, {q})), Nat.add(U32.to_nat(31), U32.to_nat({q})), VA.add_nc(31, {q}, {{==}})))
  %Equal.sym(Nat, VB.pw(24n), U32.to_nat(16777216), pws24()) : {{Nat.is_le(Nat.add(31n, A.quad({tn(QXV)})), _) == {TRUE}}}
  lew(Nat.add(31n, A.quad({tn(QXV)})), U32.add(31, {q}), 16777216, Equal.sym(Nat, Nat.add(31n, A.quad({tn(QXV)})), U32.to_nat(U32.add(31, {q})), e), {{==}})

def cS() -> {{Nat.is_le(A.quad({tn(QXV)}), U32.to_nat(16777216)) == {TRUE}}}:
  lew(A.quad({tn(QXV)}), {q}, 16777216, Equal.sym(Nat, A.quad({tn(QXV)}), U32.to_nat({q}), eqQX()), {{==}})

def cD() -> {{Nat.is_le({tn(QXV)}, O.pow2n(23n)) == {TRUE}}}:
  %Equal.sym(Nat, O.pow2n(23n), U32.to_nat(8388608), pwn23()) : {{Nat.is_le({tn(QXV)}, _) == {TRUE}}}
  VA.le_nat({QXV}, 8388608, {{==}})

def cH0() -> {{Nat.is_le(A.quad({tn(X0)}), U32.to_nat(8388608)) == {TRUE}}}:
  lew(A.quad({tn(X0)}), {quadw(X0)}, 8388608, Equal.sym(Nat, A.quad({tn(X0)}), U32.to_nat({quadw(X0)}), quadw({X0}, {{==}}, {{==}})), {{==}})

def cH1() -> {{Nat.is_le(A.quad({tn(X1)}), U32.to_nat(196608)) == {TRUE}}}:
  lew(A.quad({tn(X1)}), {quadw(X1)}, 196608, Equal.sym(Nat, A.quad({tn(X1)}), U32.to_nat({quadw(X1)}), quadw({X1}, {{==}}, {{==}})), {{==}})
'''


def fill(txt):
    '''The encoder text with the closed quantities as words: MX0/MX1/QX are U32.to_nat of literals.'''
    txt = txt.replace('@U32BOUNDS', text())
    for a, b in [('MX0', tn(X0)), ('MX1', tn(X1)), ('QX', tn(QXV))]:
        txt = re.sub(r'(?<![\w.])' + a + r'\(\)', b, txt)
    return txt
