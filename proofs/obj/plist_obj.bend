import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
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
