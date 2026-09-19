import Base
import ./primitives.bend as P

# Tail-recursive byte validation and chunk accumulation. The in-progress buffer
# has at most 31 bytes; completed chunks are reversed once at the end.
def valid_go(xs: +List<U32>, ok: Bool) -> Bool:
  match xs:
    case Nil{}: ok
    case Con{h, t}: valid_go(t, Bool.and(ok, U32.is_lt(h, 256)))

def finish(room: Nat, buffer: +List<U32>, chunks: +List<+List<U32>>) -> +List<+List<U32>>:
  match buffer:
    case Nil{}: List.reverse(&2, +List<U32>, chunks)
    case Con{h, t}: List.reverse(&2, +List<U32>, List.append(&2, U32, h <> t, P.pad(1n+room, [])) <> chunks)

def scan(xs: +List<U32>, room: Nat, buffer: +List<U32>, chunks: +List<+List<U32>>) -> +List<+List<U32>>:
  match xs:
    case Nil{}: finish(room, buffer, chunks)
    case Con{h, t}:
      match room:
        case 0n: scan(t, 31n, [], List.append(&2, U32, buffer, [h]) <> chunks)
        case 1n+p: scan(t, p, List.append(&2, U32, buffer, [h]), chunks)

def checked(ok: Bool, xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  match ok:
    case False{}: None{}
    case True{}: Some{scan(xs, 31n, [], [])}

def pack(+xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  checked(valid_go(xs, True{}), xs)
