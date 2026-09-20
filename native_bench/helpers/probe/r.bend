import Base
import ../../../types/probe_fulu.bend as F
import ../../../types/schema.bend as T
def pick(r: Result<&1, &1, U32 & String, String>) -> Maybe<&2, T.Value>:
  match r:
    case Done{s}: Some{T.NullValue{}}
    case Fail{e}: None{}
def present(r: Maybe<&2, F.Fork>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def main() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("X")
    IO.print(U32.show(present(F.Fork.decode_result(pick(r)))))
