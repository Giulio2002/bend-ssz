import Base
import ../../spec/codec.bend as Codec
import ../../spec/schema.bend as SC
import ../../types/schema.bend as S

# Hand-written. The parts of a container value, one step: stated for any v, sch equal to the
# Sequence and the Container, so an instance names its value and schema as they are defined
# (XVw(..), Spec.X()) and no conversion unfolds Codec.parts of the whole container:
# Codec.aggregate is strict, so the checker's conversion would evaluate every field's parts
# (scratchpad checker_findings item 2).
law seq_parts:
  for +v: S.Value
  for +sch: S.Schema
  for +items: S.Value
  for +names: +List<String>
  for +fields: S.Schema
  for +ev: {v == S.Sequence{items} : S.Value}
  for +es: {sch == S.Container{names, fields} : S.Schema}
  {Codec.parts(v, sch) == Codec.aggregate(Codec.parts(items, fields), SC.fixed_size(fields)) : Maybe<&2, +List<S.Part>>}
def seq_parts(v, sch, items, names, fields, ev, es):
  %Equal.sym(S.Value, v, S.Sequence{items}, ev) :
    {Codec.parts(_, sch) == Codec.aggregate(Codec.parts(items, fields), SC.fixed_size(fields)) : Maybe<&2, +List<S.Part>>}
  %Equal.sym(S.Schema, sch, S.Container{names, fields}, es) :
    {Codec.parts(S.Sequence{items}, _) == Codec.aggregate(Codec.parts(items, fields), SC.fixed_size(fields)) : Maybe<&2, +List<S.Part>>}
  {==}
