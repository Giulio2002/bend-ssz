import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/byte_root.bend as Br
import ../../spec/value_domain.bend as VD
import ../../spec/primitives.bend as SP
import ../../spec/tree.bend as Tr
import ../../spec/limits.bend as Lim
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./mtree_spec.bend as MS
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./spec_fixed.bend as FX
import ./elems_obj.bend as EL
import ../../types/fulu_obj.bend as T
import ../../spec/codec.bend as Codec
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ./words_obj.bend as WO
import ./list_root.bend as LR
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ../compact/arith.bend as AR

# Byte vectors of whole chunks packed in words, as list elements (the cells of
# DataColumnSidecar: 2048 bytes, 512 words, 64 chunks, element depth 6). The
# element's runtime root (elems_obj.bend `er`, chunk reads clipped to the
# element) is the specification root of the element's bytes, which are the
# bytes of its words (the storage from word 512 j on).

def rw_le(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h

law e8_add:
  for +a: Nat
  for +b: Nat
  {O.e8(Nat.add(a, b)) == Nat.add(O.e8(a), O.e8(b)) : Nat}
def e8_add(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p:
      %e8_add(p, b) : {8n+_ == 8n+Nat.add(O.e8(p), O.e8(b)) : Nat}
      {==}

law mul_e8:
  for +j: Nat
  {Nat.mul(j, 512n) == O.e8(Nat.mul(j, 64n)) : Nat}
def mul_e8(j):
  match j:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, O.e8(Nat.add(64n, Nat.mul(p, 64n))), Nat.add(O.e8(64n), O.e8(Nat.mul(p, 64n))), e8_add(64n, Nat.mul(p, 64n))) :
        {Nat.add(512n, Nat.mul(p, 512n)) == _ : Nat}
      %Equal.sym(Nat, Nat.mul(p, 512n), O.e8(Nat.mul(p, 64n)), mul_e8(p)) :
        {Nat.add(512n, _) == Nat.add(O.e8(64n), O.e8(Nat.mul(p, 64n))) : Nat}
      {==}

# A clipped read inside the element is the word.
def rdv_in(+W: List<&2, U32>, +b: Nat, +j: Nat, +ew: Nat, +h: {Nat.is_lt(j, ew) == True{} : Bool})
    -> {EL.rdv(W, b, j, ew) == MR.wd(W, Nat.add(b, j)) : U32}:
  %Equal.sym(Bool, Nat.is_lt(j, ew), True{}, h) : {Bool.pick(U32, _, MR.wd(W, Nat.add(b, j)), 0) == MR.wd(W, Nat.add(b, j)) : U32}
  {==}

def lt8(+x: Nat, +m: Nat, +n: Nat, +hm: {Nat.is_lt(m, 8n) == True{} : Bool}, +h: {Nat.is_le(Nat.add(x, 8n), n) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(x, m), n) == True{} : Bool}:
  F.nat__lt_le_trans(Nat.add(x, m), Nat.add(x, 8n), n, F.nat__lt_add_left(m, 8n, x, hm), h)

# A chunk of the element at word e8(i0) is chunk i0 + c of the storage.
def ecw_cw(+W: List<&2, U32>, +i0: Nat, +c: Nat, +hc: {Nat.is_le(Nat.add(O.e8(c), 8n), 512n) == True{} : Bool})
    -> {EL.ecw(W, O.e8(i0), c, 512n) == MR.cw(W, Nat.add(i0, c)) : D.Digest}:
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 0n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 0n), 512n, lt8(O.e8(c), 0n, 512n, {==}, hc))) :
    {D.D{B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 1n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 2n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 3n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 4n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 1n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 1n), 512n, lt8(O.e8(c), 1n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 2n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 3n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 4n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 2n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 2n), 512n, lt8(O.e8(c), 2n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 3n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 4n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 3n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 3n), 512n, lt8(O.e8(c), 3n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 4n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 4n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 4n), 512n, lt8(O.e8(c), 4n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 5n), 512n, lt8(O.e8(c), 5n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n)), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 6n), 512n, lt8(O.e8(c), 6n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(_), B.swap32(EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %Equal.sym(U32, EL.rdv(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n), MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))), rdv_in(W, O.e8(i0), Nat.add(O.e8(c), 7n), 512n, lt8(O.e8(c), 7n, 512n, {==}, hc))) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 0n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(_)} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 0n) :
    {D.D{B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 1n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 1n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 2n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 2n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 3n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 3n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 4n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 4n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 5n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 5n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 6n)))), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 6n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, _)), B.swap32(MR.wd(W, Nat.add(O.e8(i0), Nat.add(O.e8(c), 7n))))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %WS.add_assoc(O.e8(i0), O.e8(c), 7n) :
    {D.D{B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, _))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(_, 0n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(_, 1n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 1n))), B.swap32(MR.wd(W, Nat.add(_, 2n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 1n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 2n))), B.swap32(MR.wd(W, Nat.add(_, 3n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 1n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 2n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 3n))), B.swap32(MR.wd(W, Nat.add(_, 4n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 1n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 2n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 3n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 4n))), B.swap32(MR.wd(W, Nat.add(_, 5n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 1n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 2n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 3n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 4n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 5n))), B.swap32(MR.wd(W, Nat.add(_, 6n))), B.swap32(MR.wd(W, Nat.add(Nat.add(O.e8(i0), O.e8(c)), 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  %e8_add(i0, c) :
    {D.D{B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 0n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 1n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 2n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 3n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 4n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 5n))), B.swap32(MR.wd(W, Nat.add(O.e8(Nat.add(i0, c)), 6n))), B.swap32(MR.wd(W, Nat.add(_, 7n)))} == MR.cw(W, Nat.add(i0, c)) : D.Digest}
  {==}

# The element's chunk digests are the storage's.
law eclist_cl:
  for +k: Nat
  for +W: List<&2, U32>
  for +i0: Nat
  for +c: Nat
  for +hk: {Nat.is_le(O.e8(Nat.add(k, c)), 512n) == True{} : Bool}
  {EL.eclist(k, W, O.e8(i0), 512n, c) == MR.clist(k, W, Nat.add(i0, c)) : List<&2, D.Digest>}
def eclist_cl(k, W, i0, c, hk):
  match k:
    case 0n: {==}
    case 1n+ +q:
      +hc = F.nat__le_trans(Nat.add(O.e8(c), 8n), O.e8(Nat.add(1n+q, c)), 512n,
        rw_le(Nat.add(8n, O.e8(c)), Nat.add(O.e8(c), 8n), O.e8(Nat.add(1n+q, c)), F.nat__add_comm(8n, O.e8(c)), WS.e8_le(c, q)), hk)
      +hq = rw_le(O.e8(Nat.add(1n+q, c)), O.e8(Nat.add(q, 1n+c)), 512n,
        Equal.cong(Nat, Nat, x => O.e8(x), Nat.add(1n+q, c), Nat.add(q, 1n+c), Equal.sym(Nat, Nat.add(q, 1n+c), 1n+Nat.add(q, c), MR.add_succ(q, c))), hk)
      %Equal.sym(D.Digest, EL.ecw(W, O.e8(i0), c, 512n), MR.cw(W, Nat.add(i0, c)), ecw_cw(W, i0, c, hc)) :
        {_ <> EL.eclist(q, W, O.e8(i0), 512n, 1n+c) == MR.clist(1n+q, W, Nat.add(i0, c)) : List<&2, D.Digest>}
      %Equal.sym(List<&2, D.Digest>, EL.eclist(q, W, O.e8(i0), 512n, 1n+c), MR.clist(q, W, Nat.add(i0, 1n+c)), eclist_cl(q, W, i0, 1n+c, hq)) :
        {MR.cw(W, Nat.add(i0, c)) <> _ == MR.clist(1n+q, W, Nat.add(i0, c)) : List<&2, D.Digest>}
      %MR.add_succ(i0, c) : {MR.cw(W, Nat.add(i0, c)) <> MR.clist(q, W, _) == MR.clist(1n+q, W, Nat.add(i0, c)) : List<&2, D.Digest>}
      {==}

# The element's root is the tree of depth 6 over the storage's chunks 64 j ..
def er_cells(+W: List<&2, U32>, +j: Nat, +hl: Nat)
    -> {EL.er(W, j, 512n, 6n, 64n, hl) == MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n) : D.Digest}:
  %Equal.sym(Nat, Nat.mul(j, 512n), O.e8(Nat.mul(j, 64n)), mul_e8(j)) :
    {MD.rtree(6n, True{}, hl, EL.eclist(64n, W, _, 512n, 0n), 0n) == MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n) : D.Digest}
  %Equal.sym(List<&2, D.Digest>, EL.eclist(64n, W, O.e8(Nat.mul(j, 64n)), 512n, 0n), MR.clist(64n, W, Nat.add(Nat.mul(j, 64n), 0n)), eclist_cl(64n, W, Nat.mul(j, 64n), 0n, {==})) :
    {MD.rtree(6n, True{}, hl, _, 0n) == MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n) : D.Digest}
  %MR.add_zero(Nat.mul(j, 64n)) : {MD.rtree(6n, True{}, hl, MR.clist(64n, W, _), 0n) == MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n) : D.Digest}
  {==}

# The bytes of cell j.
def cbytes(+W: List<&2, U32>, +j: Nat) -> +List<U32>:
  WS.btake(Nat.add(WS.e32(63n), 32n), FX.limbs(WS.wdrop(O.e8(Nat.mul(j, 64n)), W)))

def cchunks(+W: List<&2, U32>, +j: Nat,
    +cap: {Nat.is_le(O.e8(Nat.add(64n, Nat.mul(j, 64n))), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {Br.chunks(cbytes(W, j)) == MD.bytes_list(MR.clist(64n, W, Nat.mul(j, 64n))) : +List<+List<U32>>}:
  WS.chunk_scan(63n, 32n, W, Nat.mul(j, 64n), [], {==}, {==}, cap, {==})

def ccanon(+W: List<&2, U32>, +j: Nat,
    +cap: {Nat.is_le(O.e8(Nat.add(64n, Nat.mul(j, 64n))), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {Br.canonical_depth(cbytes(W, j), 6n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(cbytes(W, j)), MD.bytes_list(MR.clist(64n, W, Nat.mul(j, 64n))), cchunks(W, j, cap)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 6n) == True{} : Bool}
  {==}

def cgate(+hl: Nat, +ehl: {hl == 64n : Nat}, +W: List<&2, U32>, +j: Nat,
    +cap: {Nat.is_le(O.e8(Nat.add(64n, Nat.mul(j, 64n))), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {RR.bytevector_at_depth(2048n, 6n, cbytes(W, j)) == Some{D.bytes(MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(2048n, cbytes(W, j)), SP.byte_scope(2048n, cbytes(W, j)), WR.dom_pos(2048n, cbytes(W, j), {==})) :
    {Br.gate(_, 6n, cbytes(W, j)) == Some{D.bytes(MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, SP.byte_scope(2048n, cbytes(W, j)), True{}, WS.chunk_scope(63n, 32n, W, Nat.mul(j, 64n), {==}, cap)) :
    {Br.gate(_, 6n, cbytes(W, j)) == Some{D.bytes(MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(cbytes(W, j)), MD.bytes_list(MR.clist(64n, W, Nat.mul(j, 64n))), cchunks(W, j, cap)) :
    {Some{Tr.tree(6n, _)} == Some{D.bytes(MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n))} : Maybe<&2, +List<U32>>}
  {==}

# A cell is a specification root of its bytes.
def celem(+hl: Nat, +ehl: {hl == 64n : Nat}, +W: List<&2, U32>, +j: Nat,
    +cap: {Nat.is_le(O.e8(Nat.add(64n, Nat.mul(j, 64n))), F.spec_common__length(U32, W)) == True{} : Bool})
    -> RR.roots(S.BytesValue{cbytes(W, j)}, S.ByteVector{2048n}, [D.bytes(EL.er(W, j, 512n, 6n, 64n, hl))]):
  %Equal.sym(D.Digest, EL.er(W, j, 512n, 6n, 64n, hl), MD.rtree(6n, True{}, hl, MR.clist(64n, W, Nat.mul(j, 64n)), 0n), er_cells(W, j, hl)) :
    RR.roots(S.BytesValue{cbytes(W, j)}, S.ByteVector{2048n}, [D.bytes(_)])
  (6n, (ccanon(W, j, cap), cgate(hl, ehl, W, j, cap)))

def citems(k: Nat, +W: List<&2, U32>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{S.BytesValue{cbytes(W, i)}, citems(q, W, 1n+i)}

law croots:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  for +cap: {Nat.is_le(Nat.mul(Nat.add(k, i), 512n), F.spec_common__length(U32, W)) == True{} : Bool}
  RR.roots(citems(k, W, i), S.Repeat{S.ByteVector{2048n}}, MD.bytes_list(EL.elist(k, W, i, 512n, 6n, 64n, hl)))
def croots(k, W, i, hl, ehl, cap):
  match k:
    case 0n: {==}
    case 1n+ +q:
      +len = F.spec_common__length(U32, W)
      +le1 = AR.le_skip(q, i)
      +capm = F.nat__le_trans(Nat.mul(1n+i, 512n), Nat.mul(Nat.add(1n+q, i), 512n), len, EL.mul_le_left(1n+i, Nat.add(1n+q, i), 512n, le1), cap)
      +capi = rw_le(Nat.mul(1n+i, 512n), O.e8(Nat.add(64n, Nat.mul(i, 64n))), len, mul_e8(1n+i), capm)
      +capq = rw_le(Nat.mul(Nat.add(1n+q, i), 512n), Nat.mul(Nat.add(q, 1n+i), 512n), len,
        Equal.cong(Nat, Nat, x => Nat.mul(x, 512n), Nat.add(1n+q, i), Nat.add(q, 1n+i), Equal.sym(Nat, Nat.add(q, 1n+i), 1n+Nat.add(q, i), MR.add_succ(q, i))), cap)
      ([D.bytes(EL.er(W, i, 512n, 6n, 64n, hl))], (MD.bytes_list(EL.elist(q, W, 1n+i, 512n, 6n, 64n, hl)), (celem(hl, ehl, W, i, capi), (croots(q, W, 1n+i, hl, ehl, capq), {==}))))

law ccount:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  {Codec.count(citems(k, W, i)) == k : Nat}
def ccount(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Codec.count(citems(q, W, 1n+i)), q, ccount(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}

# The storage holds every cell.
def ccap(+K: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(Nat.mul(K, 512n), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(Nat.mul(Nat.add(K, 0n), 512n), F.spec_common__length(U32, F.array__slots(U32, t))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, t)), F.spec_common__pow2(dw), F.array__slots_length(U32, dw, t, pf)) :
    {Nat.is_le(Nat.mul(Nat.add(K, 0n), 512n), _) == True{} : Bool}
  %MR.add_zero(K) : {Nat.is_le(Nat.mul(_, 512n), F.spec_common__pow2(dw)) == True{} : Bool}
  room

# ---- the object -------------------------------------------------------------------

def kc(+n: U32) -> Nat: U32.to_nat(U32.div(n, 2048))

def eview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{citems(kc(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)}

def edig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: MD.rtree(depth, Nat.is_lt(0n, kc(n)), hl, EL.elist(kc(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n, 512n, 6n, 64n, hl), 0n)

def ldig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, kc(n)), hl, EL.elist(kc(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n, 512n, 6n, 64n, hl), 0n), U32.div(n, 2048))

# The representation invariant: a perfect word tree holding the elements.
def wfe(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(Nat.mul(kc(N), 512n), F.spec_common__pow2(dw)) == True{} : Bool}))))))

def rep_el(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfe(o), {Nat.is_le(kc(WO.len(o)), SH.ListOf_limit(s)) == True{} : Bool})

def rep_wfl(-o: O.Words, +s: S.Schema, +rep: rep_el(o, s)) -> wfe(o):
  (+w, +n) = rep
  w

def ok_el(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth))))

# The runtime root of the packed elements (O.elems_root, no length).
def ev_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: wfe(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.elems_root(hl, h, o, 512, 6, dU, seg) == (h, (o, edig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    {O.elems_root(hl, h, _, 512, 6, dU, seg) == (h, (_, edig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(dU), depth, edu) :
    {O.mt_words(N, O.mtree(_, 0n, Nat.is_lt(0n, kc(N)), hl, O.LElems{512n, 6n, 64n}, O.pow2n(_), 0n, kc(N), (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, edig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(depth, 0n, Nat.is_lt(0n, kc(N)), hl, O.LElems{512n, 6n, 64n}, O.pow2n(depth), 0n, kc(N), (h, (F.array__thaw(U32, t), D.zero()))),
      (h, (F.array__thaw(U32, t), MD.rtree(depth, Nat.is_lt(0n, kc(N)), hl, EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl), 0n))),
      EL.mt_elems(depth, Nat.is_lt(0n, kc(N)), hl, dw, t, 512n, 6n, 64n, 0n, kc(N), h, D.zero(), {==}, hd, pf, room)) :
    {O.mt_words(N, _) == (h, (O.Words{F.array__thaw(U32, t), N}, edig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, kc(N)), hl, EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl), 0n))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, kc(N)), hl, EL.elist(kc(N), F.array__slots(U32, _), 0n, 512n, 6n, 64n, hl), 0n))) : B.Buf & (O.Words & D.Digest)}
  {==}

def klen(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ks: {Nat.is_eq(kc(WO.len(o)), K) == True{} : Bool}) -> {Nat.is_eq(kc(N), K) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(kc(_), K) == True{} : Bool}
  ks

def keq(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ks: {Nat.is_eq(kc(WO.len(o)), K) == True{} : Bool}) -> {kc(N) == K : Nat}:
  WS.nat_eq(kc(N), K, klen(o, t, N, K, eo, ks))

def kle(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hv: {Nat.is_le(kc(WO.len(o)), L) == True{} : Bool}) -> {Nat.is_le(kc(N), L) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(kc(_), L) == True{} : Bool}
  hv

def hlen_k(+K: Nat, +L: Nat, +W: List<&2, U32>, +hl: Nat, +hv: {Nat.is_le(K, L) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(EL.elist(K, W, 0n, 512n, 6n, 64n, hl)), L) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(EL.elist(K, W, 0n, 512n, 6n, 64n, hl)), K, EL.elist_len(K, W, 0n, 512n, 6n, 64n, hl)) : {Nat.is_le(_, L) == True{} : Bool}
  hv

def minK(+K: Nat, +K2: Nat, +depth: Nat, +e: {K == K2 : Nat}, +hm: {Lim.minimal(K2, depth) == True{} : Bool}) -> {Lim.minimal(K, depth) == True{} : Bool}:
  %Equal.sym(Nat, K, K2, e) : {Lim.minimal(_, depth) == True{} : Bool}
  hm

# A vector of cells: its digest is a specification root of its elements.
def elenc(+hl: Nat, +ehl: {hl == 64n : Nat}, +N: U32, +R: D.Digest, +W: List<&2, U32>)
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, Codec.count(citems(kc(N), W, 0n)))) == Some{D.bytes(O.mix_len(hl, R, U32.div(N, 2048)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, Codec.count(citems(kc(N), W, 0n)), kc(N), ccount(kc(N), W, 0n)) :
    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, U32.div(N, 2048)))} : Maybe<&2, +List<U32>>}
  LR.mix_bytes(hl, ehl, R, U32.div(N, 2048))

# A list of cells: its digest (the element tree with the count mixed in) is a
# specification root of its elements.
def el_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat,
    +rep: rep_el(o, s),
    +ok: {ok_el(s, depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(eview(o), s, [D.bytes(ldig(hl, o, depth))]):
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, +room) = w5
  +c0 = DK.and_l(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth))), ok)
  +r1 = DK.and_r(SH.is_ListOf(s), Bool.and(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth))), ok)
  +c1 = DK.and_l(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(SH.ListOf_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth)), r1)
  +c2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth), r2)
  +c3 = DK.and_r(Nat.is_eq(SH.ByteVector_length(SH.ListOf_element(s)), 2048n), Lim.minimal(SH.ListOf_limit(s), depth), r2)
  +hvN = kle(o, t, N, SH.ListOf_limit(s), eo, hv)
  %Equal.sym(S.Schema, s, S.ListOf{SH.ListOf_element(s), SH.ListOf_limit(s)}, SH.ListOf_shape(s, c0)) :
    RR.roots(eview(o), _, [D.bytes(ldig(hl, o, depth))])
  %Equal.sym(S.Schema, SH.ListOf_element(s), S.ByteVector{SH.ByteVector_length(SH.ListOf_element(s))}, SH.ByteVector_shape(SH.ListOf_element(s), c1)) :
    RR.roots(eview(o), S.ListOf{_, SH.ListOf_limit(s)}, [D.bytes(ldig(hl, o, depth))])
  %Equal.sym(Nat, SH.ByteVector_length(SH.ListOf_element(s)), 48n, WS.nat_eq(SH.ByteVector_length(SH.ListOf_element(s)), 48n, c2)) :
    RR.roots(eview(o), S.ListOf{S.ByteVector{_}, SH.ListOf_limit(s)}, [D.bytes(ldig(hl, o, depth))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(eview(_), S.ListOf{S.ByteVector{2048n}, SH.ListOf_limit(s)}, [D.bytes(ldig(hl, _, depth))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.Sequence{citems(kc(N), F.array__slots(U32, _), 0n)}, S.ListOf{S.ByteVector{2048n}, SH.ListOf_limit(s)}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, kc(N)), hl, EL.elist(kc(N), F.array__slots(U32, _), 0n, 512n, 6n, 64n, hl), 0n), U32.div(N, 2048)))])
  %EL.elist_len(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl) :
    RR.roots(S.Sequence{citems(kc(N), F.array__slots(U32, t), 0n)}, S.ListOf{S.ByteVector{2048n}, SH.ListOf_limit(s)}, [D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl), 0n), U32.div(N, 2048)))])
  (MD.bytes_list(EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl)), (croots(kc(N), F.array__slots(U32, t), 0n, hl, ehl, ccap(kc(N), dw, t, pf, room)),
    (D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl))), hl, EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl), 0n)),
     ((depth, (c3, RS.at_depth_tree(SH.ListOf_limit(s), depth, hl, EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl), hdep, hlen_k(kc(N), SH.ListOf_limit(s), F.array__slots(U32, t), hl, hvN), ehl))),
      elenc(hl, ehl, N, MD.rtree(depth, Nat.is_lt(0n, MD.dlen(EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl))), hl, EL.elist(kc(N), F.array__slots(U32, t), 0n, 512n, 6n, 64n, hl), 0n), F.array__slots(U32, t))))))
