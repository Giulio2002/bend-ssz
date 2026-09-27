import Base
import ../spec/primitives.bend as P

# The scope of a tree result (a 32-byte root, when there is one), on its own so
# that a module needing only this type (nat_bytes.bend) does not import tree.bend
# and, through it, the SHA-256 conformance proofs. tree.bend's result_scope is
# this definition.
def result_scope(result: Maybe<&2, +List<U32>>) -> Type:
  match result:
    case None{}: Unit
    case Some{root}: {P.byte_scope(32n, root) == True{} : Bool}
