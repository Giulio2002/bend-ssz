import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/codec.bend as Codec
import ./schema_shapes.bend as SH
import ../compact/found.bend as F
import ./obj_support.bend as OS
import ./cform.bend as CF
import ./list_obj.bend as LO
import ./prog_list.bend as PG

# Support for progressive lists as container fields (codegen/root_laws_b.py,
# generic forms): the digest witness of packed progressive lists (prog_list
# `pdig`). Their merkleization is pcont.bend `pmerk`.

def pdwc(+hl: Nat, -o: O.Words, +sh: Nat, +c: CF.CF(o)) -> OS.DW(PG.pdig(hl, o, sh)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(PG.pdig(hl, _, sh))
  (PG.pdig(hl, O.Words{F.array__thaw(U32, t), N}, sh), {==})

def pdwd(+hl: Nat, -o: O.Words, +sh: Nat, +w: LO.wfl(o)) -> OS.DW(PG.pdig(hl, o, sh)):
  pdwc(hl, o, sh, CF.cfl(o, w))

# A progressive list of composite elements (basic_size of the element schema is
# None): the specification's sequence relation is the element roots' relation.
def plist_none(-items: S.Value, -E: S.Schema, -outs: +List<+List<U32>>, +e: {RR.basic_size(E) == None{} : Maybe<&2, Nat>},
    p: RR.sequence(None{}, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), 0n, True{}, Some{Codec.count(items)}, outs))
    -> RR.roots(S.Sequence{items}, S.ProgressiveList{E}, outs):
  %Equal.sym(Maybe<&2, Nat>, RR.basic_size(E), None{}, e) : RR.sequence(_, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), 0n, True{}, Some{Codec.count(items)}, outs)
  p

# A progressive list schema is composite: no basic size.
def bs_plist(+E: S.Schema, +k: {SH.is_ProgressiveList(E) == True{} : Bool}) -> {RR.basic_size(E) == None{} : Maybe<&2, Nat>}:
  %Equal.sym(S.Schema, E, S.ProgressiveList{SH.ProgressiveList_element(E)}, SH.ProgressiveList_shape(E, k)) : {RR.basic_size(_) == None{} : Maybe<&2, Nat>}
  {==}

# A progressive container schema is composite: no basic size.
def bs_pcont(+E: S.Schema, +k: {SH.is_ProgressiveContainer(E) == True{} : Bool}) -> {RR.basic_size(E) == None{} : Maybe<&2, Nat>}:
  %Equal.sym(S.Schema, E, S.ProgressiveContainer{SH.ProgressiveContainer_names(E), SH.ProgressiveContainer_fields(E), SH.ProgressiveContainer_active(E)}, SH.ProgressiveContainer_shape(E, k)) : {RR.basic_size(_) == None{} : Maybe<&2, Nat>}
  {==}
