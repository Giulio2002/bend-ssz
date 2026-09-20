import Base
import ../../../types/fulu.bend as F
import ../../../types/schema.bend as T
def pick(r: Result<&1, &1, U32 & String, String>) -> F.Name:
  match r:
    case Done{s}: F.Name_Fork{}
    case Fail{e}: F.Name_Checkpoint{}
def use(+n: F.Name) -> T.Schema: F.Name.schema(n)
def main() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("X")
    v : T.Schema = use(pick(r))
    IO.print("ok")
