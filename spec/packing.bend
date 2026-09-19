import Base
import ./primitives.bend as P

# Normative pack after serialization: collect consecutive groups of 32 bytes,
# append only a nonempty final partial group, right-padded with zeroes.
# room counts slots AFTER the next byte; public scan starts at 31.
def finish(room: Nat, buffer: +List<U32>, chunks: +List<+List<U32>>) -> +List<+List<U32>>:
  match buffer:
    case Nil{}: chunks
    case Con{h, t}: List.append(&2, +List<U32>, chunks, [List.append(&2, U32, h <> t, P.zero_bytes(1n+room))])

def scan(xs: +List<U32>, room: Nat, +buffer: +List<U32>, +chunks: +List<+List<U32>>) -> +List<+List<U32>>:
  match xs:
    case Nil{}: finish(room, buffer, chunks)
    case Con{h, t}:
      match room:
        case 0n: scan(t, 31n, [], List.append(&2, +List<U32>, chunks, [List.append(&2, U32, buffer, [h])]))
        case 1n+p: scan(t, p, List.append(&2, U32, buffer, [h]), chunks)

def checked(ok: Bool, xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  match ok:
    case False{}: None{}
    case True{}: Some{scan(xs, 31n, [], [])}

def pack(+xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  checked(P.bytes_domain(xs), xs)

# Public postcondition: each returned item is an exact SSZ chunk.
def chunks_domain(chunks: +List<+List<U32>>) -> Bool:
  match chunks:
    case Nil{}: True{}
    case Con{h, t}: Bool.and(P.byte_scope(32n, h), chunks_domain(t))
