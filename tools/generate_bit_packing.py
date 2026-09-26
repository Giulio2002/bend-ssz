"""Generate intrinsic eight-bit case analysis, never fixture-dependent proofs."""
from pathlib import Path
names=[f'b{i}' for i in range(8)]
args=', '.join(f'+{n}: Bool' for n in names)
def tree(op, terms):
    v='0'
    for t in reversed(terms): v=f'U32.{op}({t}, {v})'
    return v
runtime=tree('or',[f'Bool.pick(U32, {b}, {1<<i}, 0)' for i,b in enumerate(names)])
model=tree('add',[f'Bool.pick(U32, {b}, {1<<i}, 0)' for i,b in enumerate(names)])
files={}
for path,expr in [('src/bit_packing.bend',runtime),('spec/bit_packing.bend',model)]:
    s='import Base\n\n# Bits are in increasing index order; bit i has weight 2^i.\n'
    s+=f'def octet({args}) -> U32:\n  {expr}\n\n'
    s+='def pack(bits: +List<Bool>) -> +List<U32>:\n  match bits:\n'
    s+='    case Nil{}: []\n'
    for size in range(1,9):
        tail='tail' if size==8 else 'Nil{}'
        for b in reversed(names[:size]):tail=f'Con{{{b}, {tail}}}'
        call=', '.join(names[:size]+['False{}']*(8-size))
        rest='pack(tail)' if size==8 else '[]'
        s+=f'    case {tail}: octet({call}) <> {rest}\n'
    files[path]=s
s='import Base\nimport ../src/bit_packing.bend as I\nimport ../spec/bit_packing.bend as S\nimport ../spec/primitives.bend as P\nimport ./primitive_invariants.bend as V\n\n'
call=', '.join(names)
# Symbolic in the eight bits (no 256-way case splits): each pick is its bit's
# word, the model's sum of disjoint single-bit words is their or (add_or), and
# the or of the bit words is the byte word (Bool.or(b, False) == b per bit).
F = 'False{}'
def wd(xs):
    t = 'WNil{}'
    for x in reversed(xs):
        t = 'WCon{' + x + ', ' + t + '}'
    return t
Z = lambda k, x: wd([F] * k + [x] + [F] * (31 - k))
ZERO = wd([F] * 32)
BYTE = 'U32{' + wd(names + [F] * 24) + '}'
s += """def or_false(+x: Bool) -> {Bool.or(x, False{}) == x : Bool}:
  match x:
    case True{}: {==}
    case False{}: {==}

def whead(-n: Nat, w: Word(1n+n)) -> Bool:
  match w:
    case WCon{h, t}: h

def wtail(-n: Nat, w: Word(1n+n)) -> Word(n):
  match w:
    case WCon{h, t}: t

def disc(x: Bool) -> Type:
  match x:
    case True{}: Unit
    case False{}: Empty

def true_false(e: {True{} == False{} : Bool}) -> Empty:
  %Equal.sym(Bool, False{}, True{}, Equal.sym(Bool, True{}, False{}, e)) : disc(_)
  Unit{}

# Adding words with no common bit is their or.
law add_or:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  for h: {Word.and(n, a, b) == Word.zero(n) : Word(n)}
  {Word.adc(n, a, b, False{}, False{}) == Word.or(n, a, b) : Word(n)}
def add_or(n, a, b, h):
  match n:
    case 0n:
      match a b:
        case WNil{} WNil{}: {==}
    case 1n+ +p:
      match a b:
        case WCon{False{}, +at} WCon{False{}, +bt}:
          Equal.cong(Word(p), Word(1n+p), t => WCon{False{}, t}, Word.adc(p, at, bt, False{}, False{}), Word.or(p, at, bt),
            add_or(p, at, bt, Equal.cong(Word(1n+p), Word(p), w => wtail(p, w), WCon{False{}, Word.and(p, at, bt)}, WCon{False{}, Word.zero(p)}, h)))
        case WCon{False{}, +at} WCon{True{}, +bt}:
          Equal.cong(Word(p), Word(1n+p), t => WCon{True{}, t}, Word.adc(p, at, bt, False{}, False{}), Word.or(p, at, bt),
            add_or(p, at, bt, Equal.cong(Word(1n+p), Word(p), w => wtail(p, w), WCon{False{}, Word.and(p, at, bt)}, WCon{False{}, Word.zero(p)}, h)))
        case WCon{True{}, +at} WCon{False{}, +bt}:
          Equal.cong(Word(p), Word(1n+p), t => WCon{True{}, t}, Word.adc(p, at, bt, False{}, False{}), Word.or(p, at, bt),
            add_or(p, at, bt, Equal.cong(Word(1n+p), Word(p), w => wtail(p, w), WCon{False{}, Word.and(p, at, bt)}, WCon{False{}, Word.zero(p)}, h)))
        case WCon{True{}, +at} WCon{True{}, +bt}:
          Empty.absurd({Word.adc(1n+p, WCon{True{}, at}, WCon{True{}, bt}, False{}, False{}) == Word.or(1n+p, WCon{True{}, at}, WCon{True{}, bt}) : Word(1n+p)},
            true_false(Equal.cong(Word(1n+p), Bool, w => whead(p, w), WCon{True{}, Word.and(p, at, bt)}, WCon{False{}, Word.zero(p)}, h)))

"""
for k in range(8):
    s += f'def pick{k}(+x: Bool) -> {{Bool.pick(U32, x, {1 << k}, 0) == U32{{{Z(k, "x")}}} : U32}}:\n  match x:\n    case True{{}}: {{==}}\n    case False{{}}: {{==}}\n'
s += '\n'
# the or of the bit words from bit k up, as a word term
def orw(k):
    t = ZERO
    for m in reversed(range(k, 8)):
        t = f'Word.or(32n, {Z(m, names[m])}, {t})'
    return t
for k in range(8):
    s += f'def disj{k}(+x: Bool, {", ".join("+" + n + ": Bool" for n in names[k + 1:])}{", " if k < 7 else ""}) -> {{Word.and(32n, {Z(k, "x")}, {orw(k + 1)}) == Word.zero(32n) : Word(32n)}}:\n  match x:\n    case True{{}}: {{==}}\n    case False{{}}: {{==}}\n'
s += '\n'
picks = [f'Bool.pick(U32, {n}, {1 << k}, 0)' for k, n in enumerate(names)]
zs = [f'U32{{{Z(k, n)}}}' for k, n in enumerate(names)]
def chain(op, ts):
    v = '0'
    for t in reversed(ts):
        v = f'U32.{op}({t}, {v})'
    return v
# model octet: picks -> bit words -> or chain -> byte word
s += 'law model_octet:\n' + ''.join(f'  for +{n}: Bool\n' for n in names) + f'  {{S.octet({call}) == {BYTE} : U32}}\ndef model_octet({call}):\n'
for k in range(8):
    cur = zs[:k] + ['_'] + picks[k + 1:]
    s += f'  %Equal.sym(U32, {picks[k]}, {zs[k]}, pick{k}({names[k]})) :\n    {{{chain("add", cur)} == {BYTE} : U32}}\n'
# adds -> ors, innermost first: add(Zk, U32{orw(k+1)}) == or(...)
def mixed(k):
    # adds for positions < k, the or word from k on, as U32{orw(k)}
    v = f'U32{{{orw(k)}}}'
    for m in reversed(range(k)):
        v = f'U32.add({zs[m]}, {v})'
    return v
for k in reversed(range(8)):
    rest = f'U32{{{orw(k + 1)}}}'
    s += (f'  %Equal.sym(U32, U32.add({zs[k]}, {rest}), U32{{{orw(k)}}}, '
          f'Equal.cong(Word(32n), U32, v => U32{{v}}, Word.adc(32n, {Z(k, names[k])}, {orw(k + 1)}, False{{}}, False{{}}), {orw(k)}, '
          f'add_or(32n, {Z(k, names[k])}, {orw(k + 1)}, disj{k}({", ".join(names[k:])})))) :\n')
    inner = f'U32{{{orw(k + 1)}}}'
    v = '_'
    for m in reversed(range(k)):
        v = f'U32.add({zs[m]}, {v})'
    s += f'    {{{v} == {BYTE} : U32}}\n'
for k in range(8):
    cur = names[:k] + ['_'] + [f'Bool.or({n}, False{{}})' for n in names[k + 1:]]
    s += f'  %Equal.sym(Bool, Bool.or({names[k]}, False{{}}), {names[k]}, or_false({names[k]})) :\n    {{U32{{{wd(cur + [F] * 24)}}} == {BYTE} : U32}}\n'
s += '  {==}\n\n'
# runtime octet: picks -> bit words -> or chain -> byte word
s += 'law runtime_octet:\n' + ''.join(f'  for +{n}: Bool\n' for n in names) + f'  {{I.octet({call}) == {BYTE} : U32}}\ndef runtime_octet({call}):\n'
for k in range(8):
    cur = zs[:k] + ['_'] + picks[k + 1:]
    s += f'  %Equal.sym(U32, {picks[k]}, {zs[k]}, pick{k}({names[k]})) :\n    {{{chain("or", cur)} == {BYTE} : U32}}\n'
for k in range(8):
    cur = names[:k] + ['_'] + [f'Bool.or({n}, False{{}})' for n in names[k + 1:]]
    s += f'  %Equal.sym(Bool, Bool.or({names[k]}, False{{}}), {names[k]}, or_false({names[k]})) :\n    {{U32{{{wd(cur + [F] * 24)}}} == {BYTE} : U32}}\n'
s += '  {==}\n\n'
s += 'law octet_correct:\n' + ''.join(f'  for +{n}: Bool\n' for n in names) + f'  {{I.octet({call}) == S.octet({call}) : U32}}\ndef octet_correct({call}):\n'
s += f'  Equal.trans(U32, I.octet({call}), {BYTE}, S.octet({call}), runtime_octet({call}), Equal.sym(U32, S.octet({call}), {BYTE}, model_octet({call})))\n\n'
s += 'law octet_bound:\n' + ''.join(f'  for +{n}: Bool\n' for n in names) + f'  {{U32.is_lt(I.octet({call}), 256) == True{{}} : Bool}}\ndef octet_bound({call}):\n'
s += f'  %Equal.sym(U32, I.octet({call}), {BYTE}, runtime_octet({call})) : {{U32.is_lt(_, 256) == True{{}} : Bool}}\n  {{==}}\n\n'
s+='law pack_correct:\n  for +bits: +List<Bool>\n  {I.pack(bits) == S.pack(bits) : +List<U32>}\ndef pack_correct(bits):\n  match bits:\n    case Nil{}: {==}\n'
for size in range(1,9):
    tail='tail' if size==8 else 'Nil{}'
    for b in reversed(names[:size]):tail=f'Con{{{b}, {tail}}}'
    call=', '.join(names[:size]+['False{}']*(8-size))
    rest='I.pack(tail)' if size==8 else '[]'
    s+=f'    case {tail}:\n'
    if size==8:s+='      %pack_correct(tail) : {I.pack(bits) == S.octet('+call+') <> _ : +List<U32>}\n'
    s+=f'      Equal.cong(U32, +List<U32>, x => x <> {rest}, I.octet({call}), S.octet({call}), octet_correct({call}))\n'
s+='\nlaw pack_bytes:\n  for +bits: +List<Bool>\n  {P.bytes_domain(I.pack(bits)) == True{} : Bool}\ndef pack_bytes(bits):\n  match bits:\n    case Nil{}: {==}\n'
for size in range(1,9):
    tail='tail' if size==8 else 'Nil{}'
    for b in reversed(names[:size]):tail=f'Con{{{b}, {tail}}}'
    call=', '.join(names[:size]+['False{}']*(8-size))
    rest='I.pack(tail)' if size==8 else '[]'
    proof='pack_bytes(tail)' if size==8 else '{==}'
    s+=f'    case {tail}: V.and_true(U32.is_lt(I.octet({call}), 256), P.bytes_domain({rest}), octet_bound({call}), {proof})\n'
files['proofs/bit_packing.bend']=s
for p,s in files.items():Path(p).write_text(s)
# Independent ceil(n/8) characterization by quotient/remainder blocks.
p=Path('spec/bit_packing.bend')
s=p.read_text()+'\n# Exactly ceil(n / 8): zero bytes for zero bits, then one per block of eight.\ndef byte_count(n: Nat) -> Nat:\n  match n:\n    case 0n: 0n\n'
for n in range(1,8):s+=f'    case {n}n: 1n\n'
s+='    case 8n+p: 1n+byte_count(p)\n';p.write_text(s)
p=Path('proofs/bit_packing.bend')
s=p.read_text()+'\nlaw pack_length:\n  for +bits: +List<Bool>\n  {List.length(&2, U32, I.pack(bits)) == S.byte_count(List.length(&2, Bool, bits)) : Nat}\ndef pack_length(bits):\n  match bits:\n    case Nil{}: {==}\n'
for size in range(1,9):
    tail='tail' if size==8 else 'Nil{}'
    for b in reversed(names[:size]):tail=f'Con{{{b}, {tail}}}'
    proof='Equal.cong(Nat, Nat, n => 1n+n, List.length(&2, U32, I.pack(tail)), S.byte_count(List.length(&2, Bool, tail)), pack_length(tail))' if size==8 else '{==}'
    s+=f'    case {tail}: {proof}\n'
p.write_text(s)
