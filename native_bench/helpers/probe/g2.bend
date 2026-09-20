import Base
import ../../../types/fulu.bend as F
import ../../../types/schema.bend as T
def first(r: Maybe<&2, F.Fork>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def main() -> U32: first(F.Name.from_ssz(F.Name_Fork{}, T.NullValue{}))
