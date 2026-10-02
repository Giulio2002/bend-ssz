import Base
import ../../../types/schema.bend as T
import ../../../types/primitive.bend as P
import ../../../spec/codec.bend as Codec
import ../../../spec/primitives.bend as Prim
import ../../../spec/bit_decode.bend as BitDec
import ../../../spec/bytes.bend as Bytes
import ../../../spec/byte_list.bend as ByteList
import ../../../spec/bit_root.bend as BitRoot
import ../../../spec/byte_root.bend as ByteRoot
import ../../../spec/layout_decoding.bend as Lay
import ../../../spec/limits.bend as Limits
import ../../../spec/progressive.bend as Prog
import ../../../spec/mixing.bend as Mix
import ../../../spec/packing.bend as Pack
import ../../../proofs/obj/generic_specs_generated.bend as G
import ../../../spec/fulu_schemas.bend as F

def c34() -> {BitRoot.bitlist_at_depth(8n, 0n, [False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}]) == Some{[75, 79, 150, 40, 107, 0, 92, 109, 185, 90, 168, 95, 116, 79, 230, 67, 167, 152, 90, 134, 165, 203, 175, 238, 92, 138, 115, 9, 238, 139, 162, 77]} : Maybe<&2, +List<U32>>}:
  {==}

def c35() -> {BitRoot.bitlist_at_depth(8n, 0n, [False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}]) == None{} : Maybe<&2, +List<U32>>}:
  {==}
