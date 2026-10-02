import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ./schema_shapes_generated.bend as SH
import ./bitlist_obj_light.bend as BO

# The definitions of pbits_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

# The object represents a value of the progressive bit list schema s.
def rep_pbits(o: O.Bits, +s: S.Schema) -> Data:
  BO.wfb(o)

def ok_pbits(+s: S.Schema) -> Bool: SH.is_ProgressiveBits(s)
