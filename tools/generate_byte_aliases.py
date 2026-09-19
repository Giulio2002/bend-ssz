"""Emit exact fixed byte-vector aliases and their codec refinement proofs."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def generate():
    schemas=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
    code=['import Base\nimport ../types/byte_alias.bend as A\nimport ../src/byte_alias.bend as I\n']
    proof=['''import Base
import ../types/fulu_bytes.bend as F
import ../spec/bytes.bend as S
import ../src/primitives.bend as P
import ./bytes.bend as B
import ./byte_root.bend as ByteRoot
import ./tree.bend as Tree
import ../spec/byte_root.bend as RootSpec
import ./primitives.bend as Basic
''']
    for name,schema in schemas.items():
        if schema['kind']!='bytes':continue
        n=schema['length']
        bound = f'Nat.mul({n//1024}n, 1024n)' if n >= 1024 else f'{n}n'
        code.append(f'''
# Frozen SSZ Vector[byte, {n}]. Root uses canonical packed-byte Merkleization.
def {name}() -> Data: +List<U32>
def {name}.tag() -> A.ByteAlias: A.{name}{{}}
def {name}.length() -> Nat: A.size({name}.tag())
def {name}.valid(+xs: {name}()) -> Bool: I.valid({name}.tag(), xs)
def {name}.serialize(+xs: {name}()) -> Maybe<&2, +List<U32>>: I.serialize({name}.tag(), xs)
def {name}.deserialize(+xs: +List<U32>) -> Maybe<&2, {name}()>: I.deserialize({name}.tag(), xs)
def {name}.hash_tree_root(+xs: {name}()) -> Maybe<&2, +List<U32>>: I.hash_tree_root({name}.tag(), xs)
''')
        if name == 'Blob':
            proof.append(f'# {name}: generic byte-codec theorems apply, but direct large-bound\n# specialization is covered by the closed-inventory laws in fulu_byte_inventory.bend.\n')
            continue
        proof.append(f'''
law {name}.domain_correct:
  for +xs: F.{name}()
  {{F.{name}.valid(xs) == S.vector_domain({bound}, xs) : Bool}}
def {name}.domain_correct(xs): B.vector_domain_correct({bound}, xs)
law {name}.serialize_correct:
  for +xs: F.{name}()
  {{F.{name}.serialize(xs) == S.vector_encoding({bound}, xs) : Maybe<&2, +List<U32>>}}
def {name}.serialize_correct(xs): B.vector_serialize_correct({bound}, xs)
law {name}.deserialize_correct:
  for +xs: +List<U32>
  {{F.{name}.deserialize(xs) == S.vector_decoding({bound}, xs) : Maybe<&2, +List<U32>>}}
def {name}.deserialize_correct(xs): B.vector_deserialize_correct({bound}, xs)
law {name}.rejection_correct:
  for +xs: +List<U32>
  {{P.is_some(F.{name}.deserialize(xs)) == S.vector_domain({bound}, xs) : Bool}}
def {name}.rejection_correct(xs): B.vector_rejection_correct({bound}, xs)
law {name}.root_correct:
  for +xs: F.{name}()
  for +depth: Nat
  for minimal: {{RootSpec.canonical_depth(xs, depth) == True{{}} : Bool}}
  {{F.{name}.hash_tree_root(xs) == RootSpec.at_depth({bound}, depth, xs) : Maybe<&2, +List<U32>>}}
def {name}.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct({bound}, xs, depth, minimal)
law {name}.root_refinement:
  for +xs: F.{name}()
  {{F.{name}.hash_tree_root(xs) == RootSpec.at_depth({bound}, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}}
def {name}.root_refinement(xs): ByteRoot.hash_tree_root_refinement({bound}, xs)
law {name}.root_rejection:
  for +xs: F.{name}()
  {{P.is_some(F.{name}.hash_tree_root(xs)) == S.vector_domain({bound}, xs) : Bool}}
def {name}.root_rejection(xs): ByteRoot.hash_tree_root_rejection({bound}, xs)
law {name}.root_scope:
  for +xs: F.{name}()
  Tree.result_scope(F.{name}.hash_tree_root(xs))
def {name}.root_scope(xs): ByteRoot.hash_tree_root_scope({bound}, xs)
law {name}.root_length:
  for +xs: F.{name}()
  {{Basic.lengths(F.{name}.hash_tree_root(xs)) == Basic.expected_root_length(F.{name}.hash_tree_root(xs)) : Maybe<&2, Nat>}}
def {name}.root_length(xs): ByteRoot.hash_tree_root_length({bound}, xs)

''')
    return '\n'.join(code), '\n'.join(proof)

if __name__=='__main__':
    code,proof=generate()
    (ROOT/'types/fulu_bytes.bend').write_text(code)
    (ROOT/'proofs/fulu_bytes.bend').write_text(proof)
