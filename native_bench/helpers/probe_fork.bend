import Base
import ../../types/fulu.bend as F

def first(r: Maybe<&2, F.Fork>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1

def main() -> U32: first(F.Fork.deserialize([1,2,3,4,5,6,7,8,42,0,0,0,0,0,0,0]))
