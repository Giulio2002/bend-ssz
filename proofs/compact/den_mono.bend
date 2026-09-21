import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./cvm.bend as V
import ./cvm_mono.bend as V2
import ./cvm_mono_gen.bend as G
import ./den.bend as D

# FD is monotone in its level.
def fd_mono(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame, x: D.FD(t, d, h, fr)) -> D.FD(t, d, 1n+h, fr):
  match fr:
    case C.FDone{}: x
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, up}:
      V2.both(V.M(t, d, h, V.W8{fields, i, cnt, base, endp, fp, pend, start, has}), D.FD(t, d, h, up),
        V.M(t, d, 1n+h, V.W8{fields, i, cnt, base, endp, fp, pend, start, has}), D.FD(t, d, 1n+h, up),
        y => G.m_mono(t, d, h, V.W8{fields, i, cnt, base, endp, fp, pend, start, has}, y), y => fd_mono(t, d, h, up, y), x)
    case C.FRep{+elem, +left, +stride, +off, up}:
      V2.both(V.M(t, d, h, V.Rep{elem, left, off, stride}), D.FD(t, d, h, up),
        V.M(t, d, 1n+h, V.Rep{elem, left, off, stride}), D.FD(t, d, 1n+h, up),
        y => G.m_mono(t, d, h, V.Rep{elem, left, off, stride}, y), y => fd_mono(t, d, h, up, y), x)
    case C.FVarList{+elem, +i, +n, +base, +endp, up}:
      V2.both(V.M(t, d, h, V.VEl{elem, i, n, base, endp}), D.FD(t, d, h, up),
        V.M(t, d, 1n+h, V.VEl{elem, i, n, base, endp}), D.FD(t, d, 1n+h, up),
        y => G.m_mono(t, d, h, V.VEl{elem, i, n, base, endp}, y), y => fd_mono(t, d, h, up, y), x)
