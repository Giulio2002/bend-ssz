import Base
import ./buffer.bend as B
import ./cschema.bend as CS
import ./cscan.bend as SC
import ./croot.bend as R
import ./digest.bend as D

# The compact primary SSZ API.
#
# Input is a `Buf`: one packed `Array<U32>`, four bytes per word. The caller
# owns it, passes it to an operation and receives it back with the result -
# that is the input lifetime contract, and it is what keeps the runtime free of
# copies: decoding validates in place and byte payloads are never materialised.
#
# Every operation goes through one dispatcher. That is not decoration: the
# pinned 2.0.16 native backend inlines a consumer into each branch of a
# producer when two *different* large walkers are chained through the same
# linear buffer, and compiling that exceeded seven gigabytes. Routing both
# walkers through a single definition keeps a program that validates and then
# roots the same buffer a self-chain, which compiles in seconds.
# `build/t_api2.bend` versus `build/t_api.bend` records the difference.
#
# ops:
#   0  validate: is the window a legal encoding of the schema?
#   1  hash_tree_root
type Outcome is Data:
  Out{ok: Bool, root: D.Digest}

def of_valid(pair: B.Buf & Bool) -> B.Buf & Outcome:
  (buf, ok) = pair
  (buf, Out{ok, D.zero()})

def of_root(pair: B.Buf & D.Digest) -> B.Buf & Outcome:
  (buf, d) = pair
  (buf, Out{True{}, d})

# The `guard` argument makes this a recursive definition. That is deliberate:
# the pinned backend inlines a non-recursive consumer into every branch of the
# walker that produced its buffer, and with two large walkers in one program
# that exceeded seven gigabytes at compile time. A recursive definition is not
# inlined, so callers chain into this one entry point instead. Callers pass
# `0n`; the other branch is unreachable.
def dispatch(+op: U32, +schema: CS.CS, +size: U32, buf: B.Buf) -> B.Buf & Outcome:
  match op:
    case 0: of_valid(SC.valid_at(schema, size, buf))
    case _: of_root(R.root(schema, size, buf))

def run_go(+guard: Nat, +op: U32, +schema: CS.CS, +size: U32, buf: B.Buf) -> B.Buf & Outcome:
  match guard:
    case 0n: dispatch(op, schema, size, buf)
    case 1n+p: run_go(p, op, schema, size, buf)

def run(+op: U32, +schema: CS.CS, +size: U32, buf: B.Buf) -> B.Buf & Outcome:
  run_go(0n, op, schema, size, buf)

def accepted(o: Outcome) -> Bool:
  match o:
    case Out{+ok, d}: ok

def root_of(o: Outcome) -> D.Digest:
  match o:
    case Out{ok, +d}: d
