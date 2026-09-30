import Base
import ./primitives.bend as P
import ./merkle.bend as M
import ./packing.bend as Pack
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as FIPS

# Exact perfect-tree capacity. General next-power-of-two selection is separate.
def capacity(depth: Nat) -> Nat:
  match depth:
    case 0n: 1n
    case 1n+p: Nat.double(capacity(p))

def drop(n: Nat, xs: +List<+List<U32>>) -> +List<+List<U32>>:
  match n:
    case 0n: xs
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{h, t}: drop(p, t)

def tree(+depth: Nat, +xs: +List<+List<U32>>) -> +List<U32>:
  match depth:
    case 0n:
      match xs:
        case Nil{}: M.zero_subtree(0n)
        case Con{h, t}: h
    case 1n+p:
      match xs:
        case Nil{}: M.zero_subtree(1n+p)
        case Con{h, t}: FIPS.sha256_bytes(List.append(&2, U32, tree(p, h <> t), tree(p, drop(capacity(p), h <> t))))

def checked(ok: Bool, depth: Nat, chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{tree(depth, chunks)}

def merkleize_at_depth(+depth: Nat, +chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  checked(Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), capacity(depth))), depth, chunks)
