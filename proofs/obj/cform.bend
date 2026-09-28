import Base
import ../compact/found.bend as F
import ../../src/obj.bend as O
import ./dk.bend as DK
import ./words_obj_light.bend as WO
import ./list_obj_light.bend as LO
import ./pv_obj_light.bend as PV

# The concrete form of byte storage held by a representation invariant: its
# word tree and length as values. A container law computes the digest witness
# of a byte storage field from these values (the field itself is erased).
def CF(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(U32, N => {o == O.Words{F.array__thaw(U32, t), N} : O.Words}))

def cf1(-o: O.Words, +w: WO.wf1(o)) -> CF(o):
  (+t, +w1) = w
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+q, +w4) = w3
  (+r, +w5) = w4
  (+eo, +w6) = w5
  (t, (N, eo))

def cf0(-o: O.Words, +w: LO.wf0(o)) -> CF(o):
  (+t, +w1) = w
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+eo, +w4) = w3
  (t, (N, eo))

def cfl(-o: O.Words, +w: LO.wfl(o)) -> CF(o):
  match w:
    case Inl{+a}: cf0(o, a)
    case Inr{+b}: cf1(o, b)

def cfv(-o: O.Words, +w: PV.wfv(o)) -> CF(o):
  (+t, +w1) = w
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+q, +w4) = w3
  (+eo, +w5) = w4
  (t, (N, eo))
