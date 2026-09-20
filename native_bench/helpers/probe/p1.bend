import Base
import ../../../types/probe_fulu.bend as F
def first(r: Maybe<&2, F.Fork>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def main() -> U32: first(F.Fork.decode_result(None{}))
