"""Symbolic closed-inventory specialization avoids expanding large Nat literals.
This indexes actual named schemas; typed-wrapper and frozen-schema-identity
composition remain separate proof obligations.
"""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
names=list(json.loads((ROOT/'schemas/fulu_mainnet.json').read_text()))
lines=['import Base','import ../types/fulu.bend as F','import ../types/schema.bend as T','import ../src/ssz.bend as API','import ../spec/type_legality.bend as Legal','import ../spec/codec.bend as S','import ./fulu_legality.bend as Named','import ./codec_composition.bend as Codec','','# Closed proof index over every frozen public name, including untested types.','type Name is Data:']
lines+=['  '+n+'{}' for n in names]
lines+=['','def schema(name: Name) -> T.Schema:','  match name:']+['    case '+n+'{}: F.'+n+'.schema()' for n in names]
lines+=['','law type_legal:','  for +name: Name','  Legal.type_legal(schema(name))','def type_legal(name):','  match name:']+['    case '+n+'{}: Named.'+n+'_normative_legal()' for n in names]
lines+=['','law validator_accepts:','  for +name: Name','  {API.type_valid(schema(name)) == True{} : Bool}','def validator_accepts(name):','  match name:']+['    case '+n+'{}: Named.'+n+'_validator_accepts()' for n in names]
lines+=['''
# Every input value is covered, including wrong tags, lengths and bounds. The
# type-validity premise of the recursive theorem is discharged for each name.
# This is actual generic API serialization AT every named schema; it does not
# claim all typed adapters, decoding or roots have been composed yet.
law serialize_at_every_named_schema:
  for +name: Name
  for +value: T.Value
  {API.serialize(schema(name), value) == S.encoding_for_legal_type(schema(name), value) : Maybe<&2, +List<U32>>}
def serialize_at_every_named_schema(name, value):
  Codec.serialize_for_valid_type(schema(name), value, validator_accepts(name))
''']
(ROOT/'proofs/fulu_serialization_inventory.bend').write_text('\n'.join(lines))
