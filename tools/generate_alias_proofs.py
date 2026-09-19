"""Compose checked primitive laws through each frozen named primitive entry point."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
WIDTH={1:'U8',4:'U32Width',8:'U64',32:'U256'}

def generate():
    out=['''import Base
import ../types/primitive.bend as T
import ../types/fulu_primitives.bend as F
import ../spec/primitives.bend as S
import ./integer_encoding.bend as E
import ./integer_decoding.bend as D
import ./encoding_complete.bend as C
import ./primitives.bend as P
import ./primitive_invariants.bend as V
import ./boolean_canonical.bend as B
''']
    schemas=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
    for name,schema in schemas.items():
        if schema['kind']=='bool':
            out.append('''
law boolean.serialize_correct:
  for b: Bool
  {F.boolean.serialize(b) == S.boolean_encoding(b) : +List<U32>}
def boolean.serialize_correct(b): P.boolean_serialize_correct(b)
law boolean.deserialize_correct:
  for xs: +List<U32>
  {F.boolean.deserialize(xs) == S.boolean_decoding(xs) : Maybe<&2, Bool>}
def boolean.deserialize_correct(xs): P.boolean_deserialize_correct(xs)
law boolean.root_correct:
  for b: Bool
  {F.boolean.hash_tree_root(b) == S.boolean_hash_tree_root(b) : +List<U32>}
def boolean.root_correct(b): P.boolean_hash_tree_root_correct(b)
law boolean.decoding_complete:
  for b: Bool
  {F.boolean.deserialize(S.boolean_encoding(b)) == Some{b} : Maybe<&2, Bool>}
def boolean.decoding_complete(b): P.boolean_decoding_complete(b)
law boolean.accepted_sound:
  for +xs: +List<U32>
  for b: Bool
  for e: {F.boolean.deserialize(xs) == Some{b} : Maybe<&2, Bool>}
  {S.boolean_encoding(b) == xs : +List<U32>}
def boolean.accepted_sound(xs, b, e): B.boolean_accepted_sound(xs, b, e)
law boolean.root_length:
  for b: Bool
  {List.length(&2, U32, F.boolean.hash_tree_root(b)) == 32n : Nat}
def boolean.root_length(b): P.boolean_root_length(b)
''')
        elif schema['kind']=='uint':
            w='T.'+WIDTH[schema['size']]+'{}'; n=schema['size']
            out.append(f'''
law {name}.serialize_correct:
  for +v: F.{name}()
  {{F.{name}.serialize(v) == S.uint_encoding({w}, v) : Maybe<&2, +List<U32>>}}
def {name}.serialize_correct(v): E.uint_serialize_correct({w}, v)
law {name}.deserialize_correct:
  for +xs: +List<U32>
  {{F.{name}.deserialize(xs) == S.uint_decoding({w}, xs) : Maybe<&2, T.UInt>}}
def {name}.deserialize_correct(xs): D.uint_deserialize_correct({w}, xs)
law {name}.rejection_correct:
  for +xs: +List<U32>
  {{P.integer_rejected(F.{name}.deserialize(xs)) == Bool.not(S.byte_scope({n}n, xs)) : Bool}}
def {name}.rejection_correct(xs): P.uint_rejection_correct({w}, xs)
law {name}.root_correct:
  for +v: F.{name}()
  {{F.{name}.hash_tree_root(v) == S.uint_hash_tree_root({w}, v) : Maybe<&2, +List<U32>>}}
def {name}.root_correct(v): E.uint_hash_tree_root_correct({w}, v)
law {name}.domain_correct:
  for +v: F.{name}()
  {{F.{name}.valid(v) == S.uint_domain({w}, v) : Bool}}
def {name}.domain_correct(v): E.uint_domain_correct({w}, v)
law {name}.serialized_scope:
  for +v: F.{name}()
  V.scoped({n}n, F.{name}.serialize(v))
def {name}.serialized_scope(v): V.uint_serialized_scope({w}, v)
law {name}.decoding_complete:
  for +v: F.{name}()
  for +xs: +List<U32>
  for e: {{S.uint_encoding({w}, v) == Some{{xs}} : Maybe<&2, +List<U32>>}}
  {{F.{name}.deserialize(xs) == Some{{v}} : Maybe<&2, T.UInt>}}
def {name}.decoding_complete(v, xs, e): C.uint_decoding_complete({w}, v, xs, e)
law {name}.accepted_sound:
  for +xs: +List<U32>
  for +v: F.{name}()
  for e: {{F.{name}.deserialize(xs) == Some{{v}} : Maybe<&2, T.UInt>}}
  {{S.uint_encoding({w}, v) == Some{{xs}} : Maybe<&2, +List<U32>>}}
def {name}.accepted_sound(xs, v, e): C.uint_accepted_sound({w}, xs, v, e)
law {name}.accepted_domain:
  for +xs: +List<U32>
  for +v: F.{name}()
  for e: {{F.{name}.deserialize(xs) == Some{{v}} : Maybe<&2, T.UInt>}}
  {{F.{name}.valid(v) == True{{}} : Bool}}
def {name}.accepted_domain(xs, v, e): C.uint_accepted_domain({w}, xs, v, e)
law {name}.root_length:
  for +v: F.{name}()
  {{P.lengths(F.{name}.hash_tree_root(v)) == P.expected_root_length(F.{name}.serialize(v)) : Maybe<&2, Nat>}}
def {name}.root_length(v): P.uint_root_length({w}, v)
''')
    return '\n'.join(out)

if __name__=='__main__':
    (ROOT/'proofs/fulu_primitives.bend').write_text(generate())
