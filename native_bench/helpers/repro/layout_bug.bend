# Minimal reproducer for a pinned Bend 2.0.16 NATIVE C backend limitation.
#
#   bend native_bench/helpers/repro/layout_bug.bend -o /tmp/x
#   Error: a constructor outside its layout: <module>.Rec
#
# The same file checks and runs on the JavaScript backend (`bend <file>`).
# Shape: a Name-indexed dependent dispatch (`Name.Value`) whose arms have
# different native layouts - a record containing another record, a bare
# multi-word record, and a boxed list - consumed through a per-type wrapper
# that applies the dispatch at a CONSTANT name with a runtime payload.
# This is exactly the generated shape of types/fulu.bend (Name.Value /
# Name.from_ssz + `def X.decode_result(r) = Name.decode_result(Name_X{}, r)`).
import Base

type Wide is Data:
  Wide{a: U32, b: U32, c: U32, d: U32, e: U32, f: U32, g: U32, h: U32}

type Rec is Data:
  Rec{p: +List<U32>, q: +List<U32>, w: Wide}

def Boxed() -> Data: +List<+List<U32>>

type Name is Data:
  Name_Rec{}
  Name_Wide{}
  Name_Boxed{}

def Name.Value(n: Name) -> Data:
  match n:
    case Name_Rec{}: Rec
    case Name_Wide{}: Wide
    case Name_Boxed{}: Boxed()

def Rec.from_bytes(xs: +List<U32>) -> Maybe<&2, Rec>:
  match xs:
    case Nil{}: None{}
    case Con{+h, t}: Some{Rec{t, [], Wide{h, h, h, h, h, h, h, h}}}

def Wide.from_bytes(xs: +List<U32>) -> Maybe<&2, Wide>:
  match xs:
    case Nil{}: None{}
    case Con{+h, t}: Some{Wide{h, h, h, h, h, h, h, h}}

def Boxed.from_bytes(xs: +List<U32>) -> Maybe<&2, Boxed()>: Some{[xs]}

def Name.from_bytes(name: Name, xs: +List<U32>) -> Maybe<&2, Name.Value(name)>:
  match name:
    case Name_Rec{}: Rec.from_bytes(xs)
    case Name_Wide{}: Wide.from_bytes(xs)
    case Name_Boxed{}: Boxed.from_bytes(xs)

# The failing shape: constant name, runtime payload, wrapper return type.
def Rec.decode(xs: +List<U32>) -> Maybe<&2, Rec>: Name.from_bytes(Name_Rec{}, xs)

def pick(r: Result<&1, &1, U32 & String, String>) -> +List<U32>:
  match r:
    case Done{s}: [1, 2, 3]
    case Fail{e}: []

def present(r: Maybe<&2, Rec>) -> U32:
  match r:
    case None{}: 0
    case Some{v}: 1

def main() -> IO(Unit):
  do IO<Unit>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env("X")
    IO.print(U32.show(present(Rec.decode(pick(r)))))
