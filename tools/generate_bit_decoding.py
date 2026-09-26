from pathlib import Path
# Octet decoding laws, independent of fixtures. The proof is symbolic: division by
# 2^k is a right shift (divmod lemmas per k) and mod 2 / and 1 read the low bit,
# so no 256-way case split is evaluated (was 30 s on every importing check).
b=[f'b{i}' for i in range(8)]
args=', '.join(b)
s='import Base\n\ndef octet(+x: U32) -> +List<Bool>:\n  ['+', '.join(f'U32.is_eq(U32.and(U32.shrn(x, {i}n), 1), 1)' for i in range(8))+']\n'
Path('src/bit_decoding.bend').write_text(s)
s='import Base\n\n# Arithmetic digit i = floor(x / 2^i) mod 2, in increasing significance.\ndef octet(+x: U32) -> +List<Bool>:\n  ['+', '.join(f'U32.is_eq(U32.mod(U32.div(x, {1<<i}), 2), 1)' for i in range(8))+']\n'
Path('spec/bit_decoding.bend').write_text(s)
def Z(n, tail='WNil{}'):
    s = tail
    for _ in range(n): s = 'WCon{False{}, %s}' % s
    return s
def W(bits, tail='WNil{}'):
    s = tail
    for b in reversed(bits): s = 'WCon{%s, %s}' % (b, s)
    return s
out = []
P = out.append
P('''import Base
import ../src/bit_decoding.bend as I
import ../spec/bit_decoding.bend as S
import ./power_division.bend as D
import ./word_split.bend as B

# Symbolic proof: division by 2^k is a right shift and the remainder mod 2 is
# the low bit, so both octet definitions read the same bits (no case split).

def embed1(w: Word(1n)) -> U32:
  U32{B.join(1n, 31n, w, Word.zero(31n))}

law and_low:
  for +x: U32
  {U32.and(x, 1) == embed1(B.take(1n, 32n, D.bits(x))) : U32}
def and_low(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n), U32, v => U32{v},
        Word.and(32n, w, B.join(1n, 31n, B.ones(1n), Word.zero(31n))),
        B.join(1n, 31n, B.take(1n, 32n, w), Word.zero(31n)),
        B.mask_take(1n, 31n, w))

law step_one:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  {U32.divmod.go.rec(m, b, 1, (q, 0)) == (WCon{b, q}, 0) : Word(1n+m) & U32}
def step_one(m, q, b):
  match b:
    case False{}: {==}
    case True{}: {==}

law divmod_one:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 1) == (w, 0) : Word(m) & U32}
def divmod_one(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 1), (t, 0), divmod_one(p, t)) :
            {U32.divmod.go.rec(p, b, 1, _) == (WCon{b, t}, 0) : Word(1n+p) & U32}
          step_one(p, t, b)

law div_one:
  for +x: U32
  {U32.div(x, 1) == x : U32}
def div_one(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 1), (w, 0), divmod_one(32n, w))
''')
for k in range(1, 8):
    d = 2 ** k; hi = 32 - k
    xs = ['x%d' % i for i in range(k - 1)]
    low = W(['b'] + xs)          # the k low bits after the shift
    full = W(['b'] + xs + ['True{}'], Z(hi - 1))
    one_hi = 'WCon{True{}, %s}' % Z(hi - 1)
    if k > 1:
        P('''def embed%(k)d(w: Word(%(k)dn)) -> U32:
  U32{B.join(%(k)dn, %(hi)dn, w, Word.zero(%(hi)dn))}
''' % locals())
    rF = W(xs + ['False{}']); rT = W(xs + ['True{}'])
    P('''law step%(k)d:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(%(k)dn)
  {U32.divmod.go.rec(m, b, %(d)d, (q, embed%(k)d(r))) ==
    (WCon{B.last(%(k)dn, r), q}, embed%(k)d(B.roll(%(k)dn, b, r))) : Word(1n+m) & U32}
def step%(k)d(m, q, b, r):
  match r:
    case %(rF)s: {==}
    case %(rT)s:
      %%Equal.sym(Bool, U32.is_ge(U32{%(full)s}, %(d)d), True{}, B.compare_zero(%(k)dn, %(low)s)) :
        {U32.divmod.go.fin(m, q, U32{%(full)s}, %(d)d, _) ==
          (WCon{True{}, q}, embed%(k)d(%(low)s)) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, %(full)s, B.join(%(k)dn, %(hi)dn, Word.zero(%(k)dn), %(one_hi)s)),
        B.join(%(k)dn, %(hi)dn, %(low)s, Word.zero(%(hi)dn)),
        B.subtract_prefix(%(k)dn, %(hi)dn, %(low)s, %(one_hi)s, %(one_hi)s))

law divmod%(k)d:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, %(d)d) == (B.quotient(%(k)dn, m, w), embed%(k)d(B.take(%(k)dn, m, w))) : Word(m) & U32}
def divmod%(k)d(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %%B.take_roll(%(k)dn, p, b, t) :
            {U32.divmod.go.rec(p, b, %(d)d, U32.divmod.go(p, t, %(d)d)) ==
              (WCon{B.last(%(k)dn, B.take(%(k)dn, p, t)), B.quotient(%(k)dn, p, t)}, embed%(k)d(_)) : Word(1n+p) & U32}
          %%Equal.sym(Word(p) & U32, U32.divmod.go(p, t, %(d)d),
            (B.quotient(%(k)dn, p, t), embed%(k)d(B.take(%(k)dn, p, t))), divmod%(k)d(p, t)) :
            {U32.divmod.go.rec(p, b, %(d)d, _) ==
              (WCon{B.last(%(k)dn, B.take(%(k)dn, p, t)), B.quotient(%(k)dn, p, t)}, embed%(k)d(B.roll(%(k)dn, b, B.take(%(k)dn, p, t)))) : Word(1n+p) & U32}
          step%(k)d(p, B.quotient(%(k)dn, p, t), b, B.take(%(k)dn, p, t))
''' % locals())
    if k == 1:
        P('''law remainder1:
  for +x: U32
  {U32.mod(x, 2) == embed1(B.take(1n, 32n, D.bits(x))) : U32}
def remainder1(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.mod.fin(qr), U32.divmod.go(32n, w, 2),
        (B.quotient(1n, 32n, w), embed1(B.take(1n, 32n, w))), divmod1(32n, w))
''')
    ws = ['y%d' % i for i in range(32)]
    P('''law quotient_shift%(k)d:
  for +w: Word(32n)
  {U32{B.quotient(%(k)dn, 32n, w)} == U32.shrn(U32{w}, %(k)dn) : U32}
def quotient_shift%(k)d(w):
  match w:
    case %(pat)s: {==}

law div_shift%(k)d:
  for +x: U32
  {U32.div(x, %(d)d) == U32.shrn(x, %(k)dn) : U32}
def div_shift%(k)d(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, %(d)d), U32{B.quotient(%(k)dn, 32n, w)}, U32.shrn(U32{w}, %(k)dn),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, %(d)d),
          (B.quotient(%(k)dn, 32n, w), embed%(k)d(B.take(%(k)dn, 32n, w))), divmod%(k)d(32n, w)),
        quotient_shift%(k)d(w))
''' % dict(locals(), pat=W(ws)))

def Ib(i): return 'U32.is_eq(U32.and(U32.shrn(x, %dn), 1), 1)' % i
def Sb(i): return 'U32.is_eq(U32.mod(U32.div(x, %d), 2), 1)' % (2 ** i)
for i in range(8):
    y = 'U32.shrn(x, %dn)' % i
    if i == 0:
        first = '''  %%Equal.sym(U32, U32.div(x, 1), x, div_one(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == %s : Bool}
''' % Ib(0)
    else:
        first = '''  %%Equal.sym(U32, U32.div(x, %d), %s, div_shift%d(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == %s : Bool}
''' % (2 ** i, y, i, Ib(i))
    P('''law bit%(i)d:
  for +x: U32
  {%(S)s == %(I)s : Bool}
def bit%(i)d(x):
%(first)s  %%Equal.sym(U32, U32.mod(%(y)s, 2), embed1(B.take(1n, 32n, D.bits(%(y)s))), remainder1(%(y)s)) :
    {U32.is_eq(_, 1) == %(I)s : Bool}
  %%Equal.sym(U32, U32.and(%(y)s, 1), embed1(B.take(1n, 32n, D.bits(%(y)s))), and_low(%(y)s)) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(%(y)s))), 1) == U32.is_eq(_, 1) : Bool}
  {==}
''' % dict(i=i, S=Sb(i), I=Ib(i), first=first, y=y))

P('''law octet_all:
  for +x: U32
  {I.octet(x) == S.octet(x) : +List<Bool>}
def octet_all(x):''')
for i in range(8):
    rhs = [Ib(j) for j in range(i)] + ['_'] + [Sb(j) for j in range(i + 1, 8)]
    P('''  %%Equal.sym(Bool, %s, %s, bit%d(x)) :
    {[%s] == [%s] : +List<Bool>}''' % (Sb(i), Ib(i), i, ', '.join(Ib(j) for j in range(8)), ', '.join(rhs)))
P('''  {==}

law embedded_correct:
  for +w: Word(8n)
  {I.octet(D.embed8(w)) == S.octet(D.embed8(w)) : +List<Bool>}
def embedded_correct(w):
  octet_all(D.embed8(w))

law octet_correct:
  for +x: U32
  for e: {U32.is_lt(x, 256) == True{} : Bool}
  {I.octet(x) == S.octet(x) : +List<Bool>}
def octet_correct(x, e):
  octet_all(x)
''')
Path('proofs/bit_decoding.bend').write_text('\n'.join(out))
