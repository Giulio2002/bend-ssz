"""Generate uniform checked proof terms for the three SSZ limb split positions.

This generates universally quantified laws, not test vectors or an oracle.
Every output is independently checked by the unmodified Bend checker.
"""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def cons(bits, tail='WNil{}'):
    for bit in reversed(bits):
        tail = f'WCon{{{bit}, {tail}}}'
    return tail

def generate():
    out = ['import Base\nimport ./word_split.bend as B\n\ndef bits(x: U32) -> Word(32n):\n  U32{w} = x\n  w\n']
    for k in (8,16,24):
        high = 32-k
        power = 1 << k
        low = cons(['b'] + [f'x{i}' for i in range(k-1)])
        hi_one = cons(['True{}'] + ['False{}']*(high-1))
        shift_true = cons(['b']+[f'x{i}' for i in range(k-1)]+['True{}']+['False{}']*(high-1))
        zero_high = f'Word.zero({high}n)'
        out.append(f'''
def embed{k}(w: Word({k}n)) -> U32:
  U32{{B.join({k}n, {high}n, w, Word.zero({high}n))}}

law step{k}:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word({k}n)
  {{U32.divmod.go.rec(m, b, {power}, (q, embed{k}(r))) ==
    (WCon{{B.last({k}n, r), q}}, embed{k}(B.roll({k}n, b, r))) : Word(1n+m) & U32}}
def step{k}(m, q, b, r):
  match r:
    case {cons([f'x{i}' for i in range(k-1)]+['False{}'])}: {{==}}
    case {cons([f'x{i}' for i in range(k-1)]+['True{}'])}:
      %Equal.sym(Bool, U32.is_ge(U32{{{shift_true}}}, {power}), True{{}}, B.compare_zero({k}n, {low})) :
        {{U32.divmod.go.fin(m, q, U32{{{shift_true}}}, {power}, _) ==
          (WCon{{True{{}}, q}}, embed{k}({low})) : Word(1n+m) & U32}}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{{True{{}}, q}}, U32{{w}}),
        Word.sub(32n, {shift_true}, B.join({k}n, {high}n, Word.zero({k}n), {hi_one})),
        B.join({k}n, {high}n, {low}, {zero_high}),
        B.subtract_prefix({k}n, {high}n, {low}, {hi_one}, {hi_one}))

law divmod{k}:
  for +m: Nat
  for +w: Word(m)
  {{U32.divmod.go(m, w, {power}) == (B.quotient({k}n, m, w), embed{k}(B.take({k}n, m, w))) : Word(m) & U32}}
def divmod{k}(m, w):
  match m:
    case 0n:
      match w:
        case WNil{{}}: {{==}}
    case 1n+p:
      match w:
        case WCon{{b, t}}:
          %B.take_roll({k}n, p, b, t) :
            {{U32.divmod.go.rec(p, b, {power}, U32.divmod.go(p, t, {power})) ==
              (WCon{{B.last({k}n, B.take({k}n, p, t)), B.quotient({k}n, p, t)}}, embed{k}(_)) : Word(1n+p) & U32}}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, {power}),
            (B.quotient({k}n, p, t), embed{k}(B.take({k}n, p, t))), divmod{k}(p, t)) :
            {{U32.divmod.go.rec(p, b, {power}, _) ==
              (WCon{{B.last({k}n, B.take({k}n, p, t)), B.quotient({k}n, p, t)}}, embed{k}(B.roll({k}n, b, B.take({k}n, p, t)))) : Word(1n+p) & U32}}
          step{k}(p, B.quotient({k}n, p, t), b, B.take({k}n, p, t))
''')
        out.append(f'''
law quotient_shift{k}:
  for +w: Word(32n)
  {{U32{{B.quotient({k}n, 32n, w)}} == U32.shrn(U32{{w}}, {k}n) : U32}}
def quotient_shift{k}(w):
  match w:
    case {cons([f'x{i}' for i in range(32)])}: {{==}}

law div_shift{k}:
  for +x: U32
  {{U32.div(x, {power}) == U32.shrn(x, {k}n) : U32}}
def div_shift{k}(x):
  match x:
    case U32{{w}}:
      Equal.trans(U32, U32.div(U32{{w}}, {power}), U32{{B.quotient({k}n, 32n, w)}}, U32.shrn(U32{{w}}, {k}n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, {power}),
          (B.quotient({k}n, 32n, w), embed{k}(B.take({k}n, 32n, w))), divmod{k}(32n, w)),
        quotient_shift{k}(w))

law remainder{k}:
  for +x: U32
  {{U32.mod(x, {power}) == embed{k}(B.take({k}n, 32n, bits(x))) : U32}}
def remainder{k}(x):
  match x:
    case U32{{w}}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.mod.fin(qr), U32.divmod.go(32n, w, {power}),
        (B.quotient({k}n, 32n, w), embed{k}(B.take({k}n, 32n, w))), divmod{k}(32n, w))
''')
    return '\n'.join(out)

if __name__ == '__main__':
    (ROOT/'proofs/power_division.bend').write_text(generate())
