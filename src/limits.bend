import Base
import ./tree.bend as T

# At most limit iterations suffice mathematically; doubling stops much earlier.
# Fuel is derived from the input, not a caller resource bound or rejection case.
def choose(fits: Bool, depth: Nat, next: Unit -> Nat) -> Nat:
  match fits:
    case True{}: depth
    case False{}: next(Unit{})

def search(fuel: Nat, +limit: Nat, +depth: Nat, +capacity: Nat) -> Nat:
  match fuel:
    case 0n: depth
    case 1n+p: choose(Nat.is_le(limit, capacity), depth, u => search(p, limit, 1n+depth, Nat.double(capacity)))

def depth(+limit: Nat) -> Nat: search(limit, limit, 0n, 1n)

def gate(ok: Bool, limit: Nat, chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: T.merkleize_at_depth(depth(limit), chunks)

def merkleize(+limit: Nat, +chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  gate(Nat.is_le(List.length(&2, +List<U32>, chunks), limit), limit, chunks)

def merkleize_default(+chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  merkleize(List.length(&2, +List<U32>, chunks), chunks)
