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
for law,statement in [('octet_correct',f'{{I.octet({call}) == S.octet({call}) : U32}}'),('octet_bound',f'{{U32.is_lt(I.octet({call}), 256) == True{{}} : Bool}}')]:
    s+=f'law {law}:\n'+''.join(f'  for +{b}: Bool\n' for b in names)+f'  {statement}\ndef {law}({call}):\n  match '+ ' '.join(names)+':\n'
    for x in range(256):
        pat=' '.join('True{}' if x>>i&1 else 'False{}' for i in range(8))
        s+=f'    case {pat}: {{==}}\n'
    s+='\n'
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
