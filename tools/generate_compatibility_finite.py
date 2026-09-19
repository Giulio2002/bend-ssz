"""Construct finite actual traversals from constructor-local evidence."""
from pathlib import Path
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ../proofs/compatibility_monotone.bend as Mono
import ../proofs/primitive_invariants.bend as V
import ../proofs/nat_algebra.bend as A
import ../proofs/compatibility_choice.bend as Choice
import ../proofs/compatibility_equations.bend as Equations

def code(mode: S.Judgement) -> U32:
  match mode:
    case S.Pair{}: 0
    case S.All{}: 1
    case S.Row{}: 2
    case S.Slots{}: 3

# An operational witness, not an independent definition of SSZ compatibility.
def finite(+mode: S.Judgement, +a: T.Schema, +b: T.Schema) -> Type:
  Exists(Nat, fuel => {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool})

law lift:
  for +fuel: Nat
  for +extra: Nat
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool}
  {I.compatible_go(Nat.add(fuel, extra), code(mode), a, b) == True{} : Bool}
def lift(fuel, extra, mode, a, b, accepted):
  match mode:
    case S.Pair{}: Mono.monotone(fuel, extra, Mono.Pair{}, a, b, accepted)
    case S.All{}: Mono.monotone(fuel, extra, Mono.All{}, a, b, accepted)
    case S.Row{}: Mono.monotone(fuel, extra, Mono.Row{}, a, b, accepted)
    case S.Slots{}: Mono.monotone(fuel, extra, Mono.Slots{}, a, b, accepted)

law lift_right:
  for +left: Nat
  for +right: Nat
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {I.compatible_go(right, code(mode), a, b) == True{} : Bool}
  {I.compatible_go(Nat.add(left, right), code(mode), a, b) == True{} : Bool}
def lift_right(left, right, mode, a, b, accepted):
  %A.add_commute(right, left) : {I.compatible_go(_, code(mode), a, b) == True{} : Bool}
  lift(right, left, mode, a, b, accepted)
'''
for tag,params,pa,pb,cond in [
 ('Vector','+x: T.Schema\n  for +y: T.Schema\n  for +n: Nat\n  for +m: Nat','T.Vector{x, n}','T.Vector{y, m}','Nat.is_eq(n, m)'),
 ('ListOf','+x: T.Schema\n  for +y: T.Schema\n  for +n: Nat\n  for +m: Nat','T.ListOf{x, n}','T.ListOf{y, m}','Nat.is_eq(n, m)'),
 ('Container','+x: T.Schema\n  for +y: T.Schema\n  for +n: +List<String>\n  for +m: +List<String>','T.Container{n, x}','T.Container{m, y}','I.names_equal(n, m)'),
 ('Named','+x: T.Schema\n  for +y: T.Schema\n  for +n: String\n  for +m: String','T.Named{n, x}','T.Named{m, y}','String.eq(n, m)')]:
 proof=f'V.and_true({cond}, I.compatible_go(fuel, 0, x, y), meta, accepted)'
 if tag in ['Vector','ListOf']:
  proof=f'%Equal.sym(Bool, I.compatible_go(1n+fuel, 0, {pa}, {pb}), Bool.and({cond}, I.compatible_go(fuel, 0, x, y)), Equations.{tag}(fuel, x, y, n, m)) : {{_ == True{{}} : Bool}}\n    '+proof
 s+=f'''
law {tag}:
  for {params}
  for meta: {{{cond} == True{{}} : Bool}}
  for child: finite(S.Pair{{}}, x, y)
  finite(S.Pair{{}}, {pa}, {pb})
def {tag}(x, y, n, m, meta, child):
  (+fuel, accepted) = child
  (1n+fuel, {proof})
'''
s+='''
law progressive_list:
  for +x: T.Schema
  for +y: T.Schema
  for child: finite(S.Pair{}, x, y)
  finite(S.Pair{}, T.ProgressiveList{x}, T.ProgressiveList{y})
def progressive_list(x, y, child):
  (+fuel, accepted) = child
  (1n+fuel, accepted)
'''
for name,mode,pars,a,b,lmode,la,lb,rmode,ra,rb in [
 ('chain', 'Pair', ['ah','at','bh','bt'],'T.Chain{ah, at}','T.Chain{bh, bt}','Pair','ah','bh','Pair','at','bt'),
 ('all','All',['h','t','b'],'T.Chain{h, t}','b','Row','h','b','All','t','b'),
 ('row','Row',['a','h','t'],'a','T.Chain{h, t}','Pair','a','h','Row','a','t'),
 ('slots','Slots',['na','fa','at','nb','fb','bt'],'T.Chain{T.Named{na, fa}, at}','T.Chain{T.Named{nb, fb}, bt}','Pair','T.Named{na, fa}','T.Named{nb, fb}','Slots','at','bt')]:
 s+=f'\nlaw {name}:\n'+''.join(f'  for +{p}: '+('String' if p in ['na','nb'] else 'T.Schema')+'\n' for p in pars)
 s+=f'''  for left: finite(S.{lmode}{{}}, {la}, {lb})
  for right: finite(S.{rmode}{{}}, {ra}, {rb})
  finite(S.{mode}{{}}, {a}, {b})
def {name}({', '.join(pars)}, left, right):
  (+lf, lok) = left
  (+rf, rok) = right
  (1n+Nat.add(lf, rf), V.and_true(I.compatible_go(Nat.add(lf, rf), code(S.{lmode}{{}}), {la}, {lb}), I.compatible_go(Nat.add(lf, rf), code(S.{rmode}{{}}), {ra}, {rb}), lift(lf, rf, S.{lmode}{{}}, {la}, {lb}, lok), lift_right(lf, rf, S.{rmode}{{}}, {ra}, {rb}, rok)))
'''
# Recursive constructor witnesses remain valid with the identity rule.
s+='''
law compatible_union:
  for +sa: +List<U32>
  for +sb: +List<U32>
  for +a: T.Schema
  for +b: T.Schema
  for child: finite(S.All{}, a, b)
  finite(S.Pair{}, T.CompatibleUnion{sa, a}, T.CompatibleUnion{sb, b})
def compatible_union(sa, sb, a, b, child):
  (+fuel, accepted) = child
  (1n+fuel, Choice.recursive_accepts(I.identical(T.CompatibleUnion{sa, a}, T.CompatibleUnion{sb, b}), I.compatible_go(fuel, 1, a, b), accepted))

law progressive:
  for +na: +List<String>
  for +fa: T.Schema
  for +aa: +List<Bool>
  for +nb: +List<String>
  for +fb: T.Schema
  for +ab: +List<Bool>
  for positions: {I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n) == True{} : Bool}
  for child: finite(S.Slots{}, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb))
  finite(S.Pair{}, T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab})
def progressive(na, fa, aa, nb, fb, ab, positions, child):
  (+fuel, accepted) = child
  (1n+fuel, Choice.recursive_accepts(I.identical(T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab}), Bool.and(I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n), I.compatible_go(fuel, 3, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb))), V.and_true(I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n), I.compatible_go(fuel, 3, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb)), positions, accepted)))
'''
s+='''
law slots_end_left:
  for +other: T.Schema
  finite(S.Slots{}, T.End{}, other)
def slots_end_left(other):
  match other:
'''
ns={}
exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
for obj in ns['variants']('x',['Chain']):
 s+=f"    case {ns['pp'](obj)}: (1n, {{==}})\n"
s+='''
law slots_end_right:
  for +other: T.Schema
  finite(S.Slots{}, other, T.End{})
def slots_end_right(other):
  match other:
'''
ns={}
exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
for obj in ns['variants']('x',['Chain']):
 s+=f"    case {ns['pp'](obj)}: (1n, {{==}})\n"
s+='''
law skip_left:
  for +at: T.Schema
  for +bh: T.Schema
  for +bt: T.Schema
  for child: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{T.Null{}, at}, T.Chain{bh, bt})
def skip_left(at, bh, bt, child):
  match bh:
'''
for obj in ns['variants']('x',[]):
 s+=f"    case {ns['pp'](obj)}:\n      (+fuel, accepted) = child\n      (1n+fuel, accepted)\n"
s+='''
law skip_right:
  for +ah: T.Schema
  for +at: T.Schema
  for +bt: T.Schema
  for child: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{ah, at}, T.Chain{T.Null{}, bt})
def skip_right(ah, at, bt, child):
  match ah:
'''
for obj in ns['variants']('x',[]):
 s+=f"    case {ns['pp'](obj)}:\n      (+fuel, accepted) = child\n      (1n+fuel, accepted)\n"
s+='''
law slots_named:
  for +na: String
  for +fa: T.Schema
  for +at: T.Schema
  for +nb: String
  for +fb: T.Schema
  for +bt: T.Schema
  for names: {String.eq(na, nb) == True{} : Bool}
  for head: finite(S.Pair{}, fa, fb)
  for tail: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{T.Named{na, fa}, at}, T.Chain{T.Named{nb, fb}, bt})
def slots_named(na, fa, at, nb, fb, bt, names, head, tail):
  slots(na, fa, at, nb, fb, bt, Named(fa, fb, na, nb, names, head), tail)
'''
Path('proofs/compatibility_finite.bend').write_text(s.replace('import ../proofs/', 'import ./'))
