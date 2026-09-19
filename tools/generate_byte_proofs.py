"""Generate uniform bit-constructor proof terms; no fixtures or expected data."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def con(xs,tail='WNil{}'):
    for x in reversed(xs):tail=f'WCon{{{x}, {tail}}}'
    return tail

def word(name):return con([f'{name}{i}' for i in range(8)])
def slot(name,k):return con(['False{}']*k+[f'{name}{i}' for i in range(8)]+['False{}']*(24-k))
def tail(names):return con(['False{}']*(32-8*len(names))+[f'{a}{i}' for a in names for i in range(8)])

def generate():
    out=['import Base\nimport ./word_split.bend as B\nimport ./power_division.bend as D\n']
    for k in (8,16,24):
        shift=f'U32.shrn(x, {k}n)'
        # U32.shln expands a fixed count to the same nested Word.shl as constant-first multiplication.
        out.append(f'''
law multiply_shift{k}:
  for +x: U32
  {{U32.mul({1<<k}, x) == U32.shln(x, {k}n) : U32}}
def multiply_shift{k}(x):
  match x:
    case U32{{w}}:
      Equal.cong(Word(32n), U32, w => U32{{w}},
        Word.add(32n, Word.zero(32n), D.bits(U32.shln(U32{{w}}, {k}n))),
        D.bits(U32.shln(U32{{w}}, {k}n)), B.add_zero_left(32n, D.bits(U32.shln(U32{{w}}, {k}n))))
''')
    for op in ('or','add'):
        for count in (2,3,4):
            names=list('abcd')[4-count:]
            first=names[0]; pos=(4-count)*8
            expr=f'U32.shln(D.embed8({names[-1]}), 24n)'
            for name in reversed(names[:-1]):
                k='abcd'.index(name)*8
                val=f'U32.shln(D.embed8({name}), {k}n)' if k else f'D.embed8({name})'
                expr=f'U32.{op}({val}, {expr})'
            result='B.join(8n, 8n, c, d)'
            if count>=3:result=f'B.join(8n, 16n, b, {result})'
            if count==4:result=f'B.join(8n, 24n, a, {result})'
            elif count==3:result=f'B.join(8n, 24n, Word.zero(8n), {result})'
            else:result=f'B.join(16n, 16n, Word.zero(16n), {result})'
            out.append(f'\nlaw pack_{op}{count}:\n'+''.join(f'  for +{a}: Word(8n)\n' for a in names)+f'  {{{expr} == U32{{{result}}} : U32}}\ndef pack_{op}{count}('+', '.join(names)+'):\n  match '+' '.join(names)+':\n    case '+' '.join(word(a) for a in names)+':\n')
            if count>2:
                tailnames=names[1:]
                old=f'U32.shln(D.embed8({tailnames[-1]}), 24n)'
                for a in reversed(tailnames[:-1]):old=f'U32.{op}(U32.shln(D.embed8({a}), {"abcd".index(a)*8}n), {old})'
                # In the branch all word binders have become their constructor patterns.
                for a in tailnames:old=old.replace(f'({a})',f'({word(a)})')
                new='U32{'+tail(tailnames)+'}'
                lowval='U32{'+slot(first,pos)+'}'
                out.append(f'      %Equal.sym(U32, {old}, {new}, pack_{op}{count-1}('+', '.join(word(a) for a in tailnames)+f')) :\n        {{U32.{op}({lowval}, _) == U32{{{tail(names)}}} : U32}}\n')
            split=pos+8
            low=con(['False{}']*pos+[f'{first}{i}' for i in range(8)])
            high=con([f'{a}{i}' for a in names[1:] for i in range(8)])
            out.append(f'''      Equal.cong(Word(32n), U32, w => U32{{w}},
        Word.{op}(32n, B.join({split}n, {32-split}n, {low}, Word.zero({32-split}n)), B.join({split}n, {32-split}n, Word.zero({split}n), {high})),
        B.join({split}n, {32-split}n, {low}, {high}), B.join_{op}({split}n, {32-split}n, {low}, {high}))
''')
    return '\n'.join(out)

if __name__=='__main__':
    (ROOT/'proofs/byte_arithmetic.bend').write_text(generate())
