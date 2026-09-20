import Base
import ../../../types/fulu.bend as F
import ../../../types/schema.bend as T
import ../../../types/primitive.bend as P
import ../../../src/ssz.bend as API
def first(r: Maybe<&2, F.Fork>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def second(r: Maybe<&2, +List<U32>>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def main() -> U32: first(F.Fork.deserialize([1]))
