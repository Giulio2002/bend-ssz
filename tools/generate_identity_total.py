"""Generate total identity comparison equivalence, including Named helpers.
Includes the runtime Named identity branch.
"""
from pathlib import Path
source=Path('tools/generate_identity_equivalence.py').read_text()
# Retain the exact constructor cases and arithmetic/metadata refinements, but
# remove the representation restriction and prove the additional Named branch.
source=source.replace("out+='''\nlaw and_equal:", "out+='''\nlaw and_equal:")
source=source.replace('  for +public: {unnamed(a) == True{} : Bool}\n','')
source=source.replace('def equal(a, b, public):','def equal(a, b):')
source=source.replace("return f'equal({pp(x)}, {pp(y)}, {p})'", "return f'equal({pp(x)}, {pp(y)})'")
start=source.index("  if n==m=='Named':")
end=source.index("  elif n==m=='Unsigned':",start)
source=source[:start]+'''  if n==m=='Named':
   proof=join(same(f'String.eq({x[0]}, {y[0]})'),rec(x[1],y[1]))[2]
'''+source[end:]
source=source.replace("Path('proofs/identity_equivalence.bend').write_text(out)","Path('proofs/identity_total.bend').write_text(out)")
exec(compile(source,'identity-total-generator','exec'))
