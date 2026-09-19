import Base
import ./lists.bend as Lists
import ./tree.bend as Tree
import ./sha256.bend as Hash
import ./primitives.bend as P

# Progressive trees consume 1, 4, 16, ... leaves on successive right branches.
def join(pair: +List<U32> & +List<+List<U32>>, next: +List<+List<U32>> -> +List<U32>) -> +List<U32>:
  (right, rest) = pair
  Hash.hash(Lists.append(U32, next(rest), right))

def tree(+fuel: Nat, +depth: Nat, chunks: +List<+List<U32>>) -> +List<U32>:
  match fuel:
    case 0n: P.pad(32n, [])
    case 1n+p:
      match chunks:
        case Nil{}: P.pad(32n, [])
        case Con{h, t}: join(Tree.consume(depth, h <> t), rest => tree(p, 2n+depth, rest))

def gate(ok: Bool, +chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{tree(Lists.length(+List<U32>, chunks), 0n, chunks)}

def merkleize(+chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  gate(Tree.valid_go(chunks, True{}), chunks)
