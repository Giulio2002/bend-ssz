import Base
import ./buffer.bend as B
import ./cschema.bend as CS
import ./cscan.bend as SC
import ./croot.bend as R
import ./digest.bend as D

# The compact primary SSZ operations.
#
# Input is a `Buf`: one packed `Array<U32>`, four bytes per word. The caller
# owns it, passes it to an operation and receives it back with the result -
# that is the input lifetime contract, and it is what keeps the runtime free of
# copies: decoding validates in place and byte payloads are never materialised.
#
# Each operation is its own entry point, so a program pays compile time only
# for the walkers it uses (validator alone: ~2 GB; validator and root chained:
# ~5.2 GB). An earlier single dispatcher over both walkers was a workaround for
# a compile blow-up that went away with the generated-schema fix, and by then
# it cost more than it saved (5.0 to over 6.5 GB, see WORK_LOG).

# Is the window [off, off + len) a canonical encoding of `schema`?
def validate_in(schema: CS.CS, +off: U32, +len: U32, buf: B.Buf) -> B.Buf & Bool:
  SC.valid_in(schema, off, len, buf)

def validate(schema: CS.CS, +size: U32, buf: B.Buf) -> B.Buf & Bool: validate_in(schema, 0, size, buf)

# hash_tree_root of a validated window. Intermediate digests and the
# zero-subtree table live in the buffer's own scratch (`src/buffer.bend`); the
# table is computed (63 hashes) the first time a buffer is hashed and reused by
# every later root of it, as fastssz reuses its package-level zero-hash table.
def root_in(schema: CS.CS, +off: U32, +len: U32, buf: B.Buf) -> B.Buf & D.Digest:
  R.root_in(schema, off, len, buf)

def root(schema: CS.CS, +size: U32, buf: B.Buf) -> B.Buf & D.Digest: root_in(schema, 0, size, buf)
