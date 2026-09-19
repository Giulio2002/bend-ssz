"""Structural identity soundness; unrestricted schemas, no legality premise."""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def pat(n,k,p):return 'T.'+n+'{'+', '.join(p+str(i) for i in range(k))+'}'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/primitives.bend as IP
import ../spec/compatibility.bend as S
import ../spec/primitives.bend as SP
import ./primitives.bend as P
import ./validator_metadata.bend as M
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

# Structural identity soundness includes internal Named nodes.
law identical_sound:
  for +a: T.Schema
  for +b: T.Schema
  for +accepted: {I.identical(a, b) == True{} : Bool}
  {S.identical(a, b) == True{} : Bool}
def identical_sound(a, b, accepted):
  match a b:
'''
for n,k in cs:
 for m,l in cs:
  a=pat(n,k,'a');b=pat(m,l,'b')
  s+=f'    case {a} {b}:\n'
  ind='      '
  if (n,m) in [('ByteVector','Vector'),('ByteList','ListOf'),('Vector','ByteVector'),('ListOf','ByteList')]:
   lhs=n in ('Vector','ListOf'); child='a0' if lhs else 'b0'; cap='a1' if lhs else 'a0'; cap2='b0' if lhs else 'b1'
   s=s[:s.rfind('    case ')]
   for q,r in cs:
    c=pat(q,r,'c');aa=a.replace('a0',c) if lhs else a;bb=b if lhs else b.replace('b0',c)
    s+=f'    case {aa} {bb}:\n'
    if q=='Unsigned':
     s+=ind+f'    %P.width_correct(c0) : {{Bool.and(Nat.is_eq({cap}, {cap2}), Nat.is_eq(_, 1n)) == True{{}} : Bool}}\n'+ind+'    accepted\n'
    else:s+=ind+f'    Empty.absurd({{S.identical({aa}, {bb}) == True{{}} : Bool}}, W.false_true(accepted))\n'
  elif n!=m or n == 'Repeat':
   s+=ind+f'Empty.absurd({{S.identical({a}, {b}) == True{{}} : Bool}}, W.false_true(accepted))\n'
  elif n=='Named':
   s+=ind+'V.and_true(String.eq(a0, b0), S.identical(a1, b1), V.and_left(String.eq(a0, b0), I.identical(a1, b1), accepted), identical_sound(a1, b1, V.and_right(String.eq(a0, b0), I.identical(a1, b1), accepted)))\n'
  elif n=='Unsigned':
   s+=ind+'%P.width_correct(a0) : {Nat.is_eq(_, SP.byte_width(b0)) == True{} : Bool}\n'+ind+'%P.width_correct(b0) : {Nat.is_eq(IP.width(a0), _) == True{} : Bool}\n'+ind+'accepted\n'
  elif n in ['Boolean','ByteVector','ByteList','BitVector','BitList','ProgressiveBits','Null','End']:
   s+=ind+'accepted\n'
  elif n in ['Vector','ListOf']:
   pre='Nat.is_eq(a1, b1)';old='I.identical(a0, b0)';new='S.identical(a0, b0)'
   s+=ind+f'V.and_true({pre}, {new}, V.and_left({pre}, {old}, accepted), identical_sound(a0, b0, V.and_right({pre}, {old}, accepted)))\n'
  elif n in ['Union','ProgressiveList']:
   s+=ind+'identical_sound(a0, b0, accepted)\n'
  elif n=='Chain':
   s+=ind+'V.and_true(S.identical(a0, b0), S.identical(a1, b1), identical_sound(a0, b0, V.and_left(I.identical(a0, b0), I.identical(a1, b1), accepted)), identical_sound(a1, b1, V.and_right(I.identical(a0, b0), I.identical(a1, b1), accepted)))\n'
  elif n in ['Container','CompatibleUnion']:
   f='names_equal' if n=='Container' else 'selectors_equal';pre=f'I.{f}(a0, b0)';old='I.identical(a1, b1)';new='S.identical(a1, b1)'
   s+=ind+f'%M.{f}(a0, b0) : {{Bool.and(_, {new}) == True{{}} : Bool}}\n'+ind+f'V.and_true({pre}, {new}, V.and_left({pre}, {old}, accepted), identical_sound(a1, b1, V.and_right({pre}, {old}, accepted)))\n'
  elif n=='ProgressiveContainer':
   pre='I.names_equal(a0, b0)';bits='I.bools_equal(a2, b2)';old='I.identical(a1, b1)';new='S.identical(a1, b1)';rest=f'Bool.and({bits}, {old})';proof=f'V.and_right({pre}, {rest}, accepted)'
   s+=ind+f'%M.names_equal(a0, b0) : {{Bool.and(_, Bool.and(S.bits_equal(a2, b2), {new})) == True{{}} : Bool}}\n'+ind+f'%M.bits_equal(a2, b2) : {{Bool.and({pre}, Bool.and(_, {new})) == True{{}} : Bool}}\n'+ind+f'V.and_true({pre}, Bool.and({bits}, {new}), V.and_left({pre}, {rest}, accepted), V.and_true({bits}, {new}, V.and_left({bits}, {old}, {proof}), identical_sound(a1, b1, V.and_right({bits}, {old}, {proof}))))\n'
  else:raise Exception(n)
# The checker needs element tags exposed even in mismatching vector pairs.
blocks=re.split(r'(?=^    case )',s,flags=re.M)
expanded=[]
for block in blocks:
    work=[block]
    for var,tag in [('a0','d'),('b0','e')]:
        next_work=[]
        for part in work:
            if re.search(r'T\.(Vector|ListOf)\{'+var+r',',part.split('\n')[0]):
                for cn,arity in cs:
                    term=pat(cn,arity,tag)
                    next_work.append(re.sub(r'\b'+var+r'\b',term,part))
            else: next_work.append(part)
        work=next_work
    expanded.extend(work)
s=''.join(expanded)
Path('proofs/compatibility_identity.bend').write_text(s)
