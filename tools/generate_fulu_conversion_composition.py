"""UNVERIFIED scratch: named conversion composition currently hits checker stack limits."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'types/fulu.bend').read_text()
lines=['import Base','import ../types/fulu.bend as F','import ../types/schema.bend as T','import ../spec/representation.bend as S','import ../spec/codec.bend as Encoding','import ../proofs/representation_erasure.bend as Erasure','import ../proofs/codec_shape.bend as Shape','import ../proofs/fulu_adapter_complete.bend as Adapter','']
for line in s.splitlines():
 if '.to_ssz(v: ' not in line:continue
 name=line.split()[1].split('.')[0];typ=line.split('.to_ssz(v: ')[1].split(') -> T.Value: ')[0]
 lines += [f'''law {name}_conversion_complete:
  for +original: T.Value
  for valid: {{S.shape(original, F.{name}.schema()) == True{{}} : Bool}}
  {{Adapter.present(F.{typ}, F.{name}.from_ssz(original)) == True{{}} : Bool}}
def {name}_conversion_complete(original, valid):
  Adapter.{name}_conversion_complete_erased(original, Erasure.shape_erased_true(original, F.{name}.schema(), valid))

law {name}_encoding_conversion_complete:
  for +original: T.Value
  for +bytes: +List<U32>
  for encoded: {{Encoding.encoding_for_legal_type(F.{name}.schema(), original) == Some{{bytes}} : Maybe<&2, +List<U32>>}}
  {{Adapter.present(F.{typ}, F.{name}.from_ssz(original)) == True{{}} : Bool}}
def {name}_encoding_conversion_complete(original, bytes, encoded):
  {name}_conversion_complete(original, Shape.accepted_shape(F.{name}.schema(), original, bytes, encoded))
''']
(ROOT/'build/fulu_conversion_composition.candidate.bend').write_text('\n'.join(lines))
