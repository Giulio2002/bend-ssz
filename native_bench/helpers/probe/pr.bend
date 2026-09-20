import Base
import ../../../types/probe_fulu.bend as F
def pick(r: Result<&1, &1, U32 & String, String>) -> +List<U32>:
  match r:
    case Done{s}: [1, 2, 3]
    case Fail{e}: []
def present(r: Maybe<&2, F.Fork>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def main() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("X")
    IO.print(U32.show(present(F.Fork.deserialize(pick(r)))))
