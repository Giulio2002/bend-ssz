import Base
import ../../../types/fulu.bend as F
import ../../../types/schema.bend as T
def pick(r: Result<&1, &1, U32 & String, String>) -> F.Name:
  match r:
    case Done{s}: F.Name_Fork{}
    case Fail{e}: F.Name_Checkpoint{}
def present(-n: F.Name, r: Maybe<&2, F.Name.Value(n)>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1
def use(+n: F.Name) -> U32: present(n, F.Name.decode_result(n, None{}))
def main() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("X")
    IO.print(U32.show(use(pick(r))))
