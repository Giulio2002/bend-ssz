"""Complete the all-byte uint32 offset value bridge from checked word assembly."""
from pathlib import Path
p=Path('proofs/layout_offset_value.bend');s=p.read_text().split('# Generated all-byte bridge.')[0]
s=s.replace('import ./packing.bend as P','import ./packing.bend as P\nimport ./nat_bytes.bend as Digits\nimport ./primitive_invariants.bend as V\nimport ./word_facts.bend as Facts\nimport ../spec/layout_decoding.bend as Layout\nimport ../types/schema.bend as T') if 'import ./nat_bytes.bend as Digits' not in s else s
s+='''# Generated all-byte bridge.
law four_bytes:
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  for ea: {U32.is_lt(a, 256) == True{} : Bool}
  for eb: {U32.is_lt(b, 256) == True{} : Bool}
  for ec: {U32.is_lt(c, 256) == True{} : Bool}
  for ed: {U32.is_lt(d, 256) == True{} : Bool}
  {U32.to_nat(S.limb_value([a, b, c, d], 0n)) == N.value([a, b, c, d]) : Nat}
def four_bytes(a, b, c, d, ea, eb, ec, ed):
'''
orig=['a','b','c','d'];emb=lambda x:f'D.embed8(W.take(8n, 32n, D.bits({x})))'
for i,x in enumerate(orig):
 arr=[emb(y) if j<i else '_' if j==i else y for j,y in enumerate(orig)];ls='['+', '.join(arr)+']'
 s+=f'  %Equal.sym(U32, {x}, {emb(x)}, Integer.byte_shape({x}, e{x})) : {{U32.to_nat(S.limb_value({ls}, 0n)) == N.value({ls}) : Nat}}\n'
s+='  embedded_limb_value('+', '.join(f'W.take(8n, 32n, D.bits({x}))' for x in orig)+')\n'
s+='''
law scope_value:
  for +xs: +List<U32>
  for +scope: {S.byte_scope(4n, xs) == True{} : Bool}
  {U32.to_nat(S.limb_value(xs, 0n)) == N.value(xs) : Nat}
def scope_value(xs, scope):
  match xs:
'''
def cons(heads,tail='Nil{}'):
 for h in reversed(heads):tail=f'Con{{{h}, {tail}}}'
 return tail
def list_expr(heads,tail='[]'):
 return ' <> '.join(heads+[tail]) if heads else tail
def extract(heads,tail='[]'):
 pr='scope';out=[]
 for i,h in enumerate(heads):
  a=f'U32.is_lt({h}, 256)';b=f'S.byte_scope({3-i}n, {list_expr(heads[i+1:],tail)})'
  out.append(f'V.and_left({a}, {b}, {pr})');pr=f'V.and_right({a}, {b}, {pr})'
 return out,pr
for size in range(4):
 heads=orig[:size];ls=list_expr(heads);_,bad=extract(heads)
 s+=f'    case {cons(heads)}: Empty.absurd({{U32.to_nat(S.limb_value({ls}, 0n)) == N.value({ls}) : Nat}}, Facts.false_true({bad}))\n'
pr,_=extract(orig);s+=f'    case {cons(orig)}: four_bytes(a, b, c, d, '+', '.join(pr)+')\n'
_,bad=extract(orig,'e <> tail');ls=list_expr(orig,'e <> tail');s+=f'    case {cons(orig,"Con{e, tail}")}: Empty.absurd({{U32.to_nat(S.limb_value({ls}, 0n)) == N.value({ls}) : Nat}}, Facts.false_true({bad}))\n'
s+='''
# Every representable normative offset is read as exactly that natural number.
# Fits is the protocol's uint32 range, not a runtime or fixture-size cap.
law offset_digits:
  for +offset: Nat
  for fit: {N.fits(4n, offset) == True{} : Bool}
  {U32.to_nat(S.limb_value(N.digits(4n, offset), 0n)) == offset : Nat}
def offset_digits(offset, fit):
  Equal.trans(Nat, U32.to_nat(S.limb_value(N.digits(4n, offset), 0n)), N.value(N.digits(4n, offset)), offset, scope_value(N.digits(4n, offset), Digits.digits_scope(4n, offset)), Digits.digits_value(4n, offset, fit))

law field_offset:
  for +offset: Nat
  for fit: {N.fits(4n, offset) == True{} : Bool}
  {Layout.field(None{}, N.digits(4n, offset)) == T.Offset{offset} : T.Header}
def field_offset(offset, fit):
  Equal.cong(Nat, T.Header, x => T.Offset{x}, U32.to_nat(S.limb_value(N.digits(4n, offset), 0n)), offset, offset_digits(offset, fit))
'''
p.write_text(s)
