import Base
import ../../../types/fulu.bend as F
import ../../../types/schema.bend as T
def pick(r: Result<&1, &1, U32 & String, String>) -> F.Name:
  match r:
    case Ok{s}: F.Name_Fork{}
    case Err{e}: F.Name_Checkpoint{}
def use(+n: F.Name) -> T.Value: F.Name.to_ssz(n, F.Name.default(n))
def main() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("X")
    v : T.Value = use(pick(r))
    IO.print("ok")
