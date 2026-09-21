import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ../../src/buffer.bend as B
import ./found.bend as F
import ./reads.bend as Rd
import ./cvm.bend as V
import ./den.bend as D
import ./den_mono.bend as DM

# Soundness steps of the scanner for its leaf checks (tags 1, 2, 3 and the
# leaf schemas of tag 0): a successful run from the state establishes Den.

# ---- tag 1: the boolean byte v ----------------------------------------------

def t1_case(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), cond: Bool, e: {U32.is_le(v, 1) == cond : Bool},
    h: {C.run(p, C.usel(cond, 5, 6), s, fr, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T1{}, s, fr, a, b, c, v):
  match cond:
    case True{}: (e, DM.fd_mono(t, d, p, fr, ih(D.T5{}, s, fr, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T1{}, s, fr, a, b, c, v), ih(D.T6{}, s, fr, a, b, c, 0, h))

def sound_t1(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T1{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T1{}, s, fr, a, b, c, v):
  t1_case(t, d, n, p, s, fr, a, b, c, v, ih, U32.is_le(v, 1), {==}, h)

# ---- tag 2: a bit vector's last byte v, c its bits in use --------------------

def t2_case(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), cond: Bool, e: {U32.is_eq(v, (v .&. C.low_mask(c) : U32)) == cond : Bool},
    h: {C.run(p, C.usel(cond, 5, 6), s, fr, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T2{}, s, fr, a, b, c, v):
  match cond:
    case True{}: (e, DM.fd_mono(t, d, p, fr, ih(D.T5{}, s, fr, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T2{}, s, fr, a, b, c, v), ih(D.T6{}, s, fr, a, b, c, 0, h))

def sound_t2(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T2{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T2{}, s, fr, a, b, c, v):
  t2_case(t, d, n, p, s, fr, a, b, c, v, ih, U32.is_eq(v, (v .&. C.low_mask(c) : U32)), {==}, h)

# ---- tag 3: a bit list's last byte v -------------------------------------------

def t3_case(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), cond: Bool, e: {V.tail_ok(a, b, v, lim, big) == cond : Bool},
    h: {C.run(p, C.usel(cond, 5, 6), S.CBitList{lim, big, depth}, fr, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T3{}, S.CBitList{lim, big, depth}, fr, a, b, c, v):
  match cond:
    case True{}: (e, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CBitList{lim, big, depth}, fr, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CBitList{lim, big, depth}, fr, a, b, c, v), ih(D.T6{}, S.CBitList{lim, big, depth}, fr, a, b, c, 0, h))

def no_run(+t: F.array__Tree<U32>, +n: U32, h: {(D.bf(t, n), False{}) == (D.bf(t, n), True{}) : B.Buf & Bool}) -> Empty:
  F.logic__false_true(F.logic__pair_snd(B.Buf, Bool, D.bf(t, n), False{}, D.bf(t, n), True{}, h))

def sound_t3(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T3{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T3{}, s, fr, a, b, c, v):
  match s:
    case S.CBitList{+lim, +big, +depth}: t3_case(t, d, n, p, lim, big, depth, fr, a, b, c, v, ih, V.tail_ok(a, b, v, lim, big), {==}, h)
    case S.CBool{}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CBool{}, fr, a, b, c, v), no_run(t, n, h))
    case S.CUint{size}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CUint{size}, fr, a, b, c, v), no_run(t, n, h))
    case S.CBytes{len, dp}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CBytes{len, dp}, fr, a, b, c, v), no_run(t, n, h))
    case S.CByteList{lim, big, dp}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CByteList{lim, big, dp}, fr, a, b, c, v), no_run(t, n, h))
    case S.CBitVec{bits, bytes, dp}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CBitVec{bits, bytes, dp}, fr, a, b, c, v), no_run(t, n, h))
    case S.CVec{e1, e2, e3, e4, e5, e6}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CVec{e1, e2, e3, e4, e5, e6}, fr, a, b, c, v), no_run(t, n, h))
    case S.CVecVar{e1, e2, e3}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CVecVar{e1, e2, e3}, fr, a, b, c, v), no_run(t, n, h))
    case S.CList{e1, e2, e3, e4, e5, e6, e7}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CList{e1, e2, e3, e4, e5, e6, e7}, fr, a, b, c, v), no_run(t, n, h))
    case S.CListVar{e1, e2, e3, e4}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CListVar{e1, e2, e3, e4}, fr, a, b, c, v), no_run(t, n, h))
    case S.CCont{e1, e2, e3, e4, e5, e6, e7, e8, e9, e10}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CCont{e1, e2, e3, e4, e5, e6, e7, e8, e9, e10}, fr, a, b, c, v), no_run(t, n, h))
    case S.CPCont{e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CPCont{e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11}, fr, a, b, c, v), no_run(t, n, h))
    case S.CUnion{e1, e2}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CUnion{e1, e2}, fr, a, b, c, v), no_run(t, n, h))
    case S.CNull{}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CNull{}, fr, a, b, c, v), no_run(t, n, h))
    case S.CFLeaf{e1, e2, e3, e4}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CFLeaf{e1, e2, e3, e4}, fr, a, b, c, v), no_run(t, n, h))
    case S.CFNode{e1, e2, e3}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CFNode{e1, e2, e3}, fr, a, b, c, v), no_run(t, n, h))
    case S.CFNone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T3{}, S.CFNone{}, fr, a, b, c, v), no_run(t, n, h))

# ---- tag 0, leaf schemas -----------------------------------------------------

# A condition that selected the continuation, and the continuation's result.
def with_cond(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -A: Type, -B: Type, ea: A, pr: B & D.FD(t, d, p, fr)) -> (A & B) & D.FD(t, d, 1n+p, fr):
  (x, f) = pr
  ((ea, x), DM.fd_mono(t, d, p, fr, f))

def bool_leaf(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fr: C.Frame, +a: U32, +b: U32, +c: U32,
    ih: D.IH(t, d, n, p), cond: Bool, e: {U32.is_eq((b - a : U32), 1) == cond : Bool},
    h: {C.run(p, C.usel(cond, 1, 6), S.CBool{}, fr, a, b, c, (D.bf(t, n), Rd.b8(t, d, a))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CBool{}, fr, a, b, c, 0):
  match cond:
    case True{}: with_cond(t, d, p, fr, V.Is(U32.is_eq((b - a : U32), 1)), V.Is(U32.is_le(Rd.b8(t, d, a), 1)), e, ih(D.T1{}, S.CBool{}, fr, a, b, c, Rd.b8(t, d, a), h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CBool{}, fr, a, b, c, 0), ih(D.T6{}, S.CBool{}, fr, a, b, c, Rd.b8(t, d, a), h))

def t0_bool(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CBool{}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CBool{}, fr, a, b, c, v):
  bool_leaf(t, d, n, p, fr, a, b, c, ih, U32.is_eq((b - a : U32), 1), {==},
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq((b - a : U32), 1), 1, 6), S.CBool{}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      B.byte_at(D.bf(t, n), a), (D.bf(t, n), Rd.b8(t, d, a)), Rd.byte_any(d, t, n, a, hd, pf), h))

# A length check alone, then pop: uint, byte vector, byte list, null.
def len_leaf(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), cond: Bool,
    h: {C.run(p, C.usel(cond, 5, 6), s, fr, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Is(cond) & D.FD(t, d, 1n+p, fr):
  match cond:
    case True{}: ({==}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, s, fr, a, b, c, 0, h)))
    case False{}: Empty.absurd(V.Is(False{}) & D.FD(t, d, 1n+p, fr), ih(D.T6{}, s, fr, a, b, c, 0, h))

def t0_uint(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +size: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CUint{size}, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T0{}, S.CUint{size}, fr, a, b, c, v):
  len_leaf(t, d, n, p, S.CUint{size}, fr, a, b, c, v, ih, U32.is_eq((b - a : U32), size), h)

def t0_bytes(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +len: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CBytes{len, depth}, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T0{}, S.CBytes{len, depth}, fr, a, b, c, v):
  len_leaf(t, d, n, p, S.CBytes{len, depth}, fr, a, b, c, v, ih, U32.is_eq((b - a : U32), len), h)

def t0_bytelist(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CByteList{lim, big, depth}, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T0{}, S.CByteList{lim, big, depth}, fr, a, b, c, v):
  len_leaf(t, d, n, p, S.CByteList{lim, big, depth}, fr, a, b, c, v, ih, S.within((b - a : U32), lim, big), h)

def t0_null(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CNull{}, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T0{}, S.CNull{}, fr, a, b, c, v):
  len_leaf(t, d, n, p, S.CNull{}, fr, a, b, c, v, ih, U32.is_eq((b - a : U32), 0), h)

def padded(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, +v: U32, +c: U32,
    pr: V.Is(U32.is_eq(v, (v .&. C.low_mask(c) : U32))) & D.FD(t, d, p, fr))
    -> V.Is(U32.is_eq(v, (v .&. C.low_mask(c) : U32))) & D.FD(t, d, 1n+p, fr):
  (x, f) = pr
  (x, DM.fd_mono(t, d, p, fr, f))

# Bit vector: the length, then either whole bytes (pop) or the padding of the
# last byte (tag 2 with c = bits & 7).
def bitvec_pad(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +bits: U32, +bytes: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32,
    ih: D.IH(t, d, n, p), c2: Bool, e2: {U32.is_eq((bits .&. 7 : U32), 0) == c2 : Bool},
    h: {C.run(p, C.usel(c2, 5, 2), S.CBitVec{bits, bytes, depth}, fr, a, b, (bits .&. 7 : U32), (D.bf(t, n), Rd.b8(t, d, (a + bytes - 1 : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Is(V.pad_ok(bits, Rd.b8(t, d, (a + bytes - 1 : U32)))) & D.FD(t, d, 1n+p, fr):
  match c2:
    case True{}:
      %Equal.sym(Bool, U32.is_eq((bits .&. 7 : U32), 0), True{}, e2) : {Bool.or(_, U32.is_eq(Rd.b8(t, d, (a + bytes - 1 : U32)), (Rd.b8(t, d, (a + bytes - 1 : U32)) .&. C.low_mask((bits .&. 7 : U32)) : U32))) == True{} : Bool} & D.FD(t, d, 1n+p, fr)
      ({==}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CBitVec{bits, bytes, depth}, fr, a, b, (bits .&. 7 : U32), Rd.b8(t, d, (a + bytes - 1 : U32)), h)))
    case False{}:
      %Equal.sym(Bool, U32.is_eq((bits .&. 7 : U32), 0), False{}, e2) : {Bool.or(_, U32.is_eq(Rd.b8(t, d, (a + bytes - 1 : U32)), (Rd.b8(t, d, (a + bytes - 1 : U32)) .&. C.low_mask((bits .&. 7 : U32)) : U32))) == True{} : Bool} & D.FD(t, d, 1n+p, fr)
      padded(t, d, p, fr, Rd.b8(t, d, (a + bytes - 1 : U32)), (bits .&. 7 : U32),
        ih(D.T2{}, S.CBitVec{bits, bytes, depth}, fr, a, b, (bits .&. 7 : U32), Rd.b8(t, d, (a + bytes - 1 : U32)), h))


# (A & (B & F)) from A and (B & F).
def reassoc(-A: Type, -B: Type, -F: Type, ea: A, pr: B & F) -> (A & B) & F:
  (x, f) = pr
  ((ea, x), f)

def padded_tail(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, +a: U32, +b: U32, +lim: U32, +big: Bool, +v: U32,
    pr: V.Is(V.tail_ok(a, b, v, lim, big)) & D.FD(t, d, p, fr)) -> V.Is(V.tail_ok(a, b, v, lim, big)) & D.FD(t, d, 1n+p, fr):
  (x, f) = pr
  (x, DM.fd_mono(t, d, p, fr, f))

def bitvec_len(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +bits: U32, +bytes: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32,
    ih: D.IH(t, d, n, p), c1: Bool, e1: {U32.is_eq((b - a : U32), bytes) == c1 : Bool},
    h: {C.run(p, C.usel(c1, C.usel(U32.is_eq((bits .&. 7 : U32), 0), 5, 2), 6), S.CBitVec{bits, bytes, depth}, fr, a, b, (bits .&. 7 : U32), (D.bf(t, n), Rd.b8(t, d, (a + bytes - 1 : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CBitVec{bits, bytes, depth}, fr, a, b, 0, 0):
  match c1:
    case True{}:
      reassoc(V.Is(U32.is_eq((b - a : U32), bytes)), V.Is(V.pad_ok(bits, Rd.b8(t, d, (a + bytes - 1 : U32)))), D.FD(t, d, 1n+p, fr), e1,
        bitvec_pad(t, d, n, p, bits, bytes, depth, fr, a, b, ih, U32.is_eq((bits .&. 7 : U32), 0), {==}, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CBitVec{bits, bytes, depth}, fr, a, b, 0, 0),
      ih(D.T6{}, S.CBitVec{bits, bytes, depth}, fr, a, b, (bits .&. 7 : U32), Rd.b8(t, d, (a + bytes - 1 : U32)), h))

def t0_bitvec(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +bits: U32, +bytes: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CBitVec{bits, bytes, depth}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CBitVec{bits, bytes, depth}, fr, a, b, c, v):
  bitvec_len(t, d, n, p, bits, bytes, depth, fr, a, b, ih, U32.is_eq((b - a : U32), bytes), {==},
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq((b - a : U32), bytes), C.usel(U32.is_eq((bits .&. 7 : U32), 0), 5, 2), 6), S.CBitVec{bits, bytes, depth}, fr, a, b, (bits .&. 7 : U32), z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      B.byte_at(D.bf(t, n), (a + bytes - 1 : U32)), (D.bf(t, n), Rd.b8(t, d, (a + bytes - 1 : U32))), Rd.byte_any(d, t, n, (a + bytes - 1 : U32), hd, pf), h))

# Bit list: non-empty, then the delimiter byte (tag 3).
def bitlist_len(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32,
    ih: D.IH(t, d, n, p), c1: Bool, e1: {U32.is_eq((b - a : U32), 0) == c1 : Bool},
    h: {C.run(p, C.usel(c1, 6, 3), S.CBitList{lim, big, depth}, fr, a, b, c, (D.bf(t, n), Rd.b8(t, d, (b - 1 : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CBitList{lim, big, depth}, fr, a, b, c, 0):
  match c1:
    case True{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CBitList{lim, big, depth}, fr, a, b, c, 0),
      ih(D.T6{}, S.CBitList{lim, big, depth}, fr, a, b, c, Rd.b8(t, d, (b - 1 : U32)), h))
    case False{}:
      reassoc(V.Is(Bool.not(U32.is_eq((b - a : U32), 0))), V.Is(V.tail_ok(a, b, Rd.b8(t, d, (b - 1 : U32)), lim, big)), D.FD(t, d, 1n+p, fr),
        F.logic__subst(Bool, z => V.Is(Bool.not(z)), False{}, U32.is_eq((b - a : U32), 0), Equal.sym(Bool, U32.is_eq((b - a : U32), 0), False{}, e1), {==}),
        padded_tail(t, d, p, fr, a, b, lim, big, Rd.b8(t, d, (b - 1 : U32)),
          ih(D.T3{}, S.CBitList{lim, big, depth}, fr, a, b, c, Rd.b8(t, d, (b - 1 : U32)), h)))

def t0_bitlist(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CBitList{lim, big, depth}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CBitList{lim, big, depth}, fr, a, b, c, v):
  bitlist_len(t, d, n, p, lim, big, depth, fr, a, b, c, ih, U32.is_eq((b - a : U32), 0), {==},
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq((b - a : U32), 0), 6, 3), S.CBitList{lim, big, depth}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      B.byte_at(D.bf(t, n), (b - 1 : U32)), (D.bf(t, n), Rd.b8(t, d, (b - 1 : U32))), Rd.byte_any(d, t, n, (b - 1 : U32), hd, pf), h))

def no_run6_at(+t: F.array__Tree<U32>, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, x: B.Buf, +y: U32,
    h: {C.run(p, 6, s, fr, a, b, c, (x, y)) == (D.bf(t, n), True{}) : B.Buf & Bool}) -> Empty:
  match p:
    case 0n: F.logic__false_true(F.logic__pair_snd(B.Buf, Bool, x, False{}, D.bf(t, n), True{}, h))
    case 1n+q: F.logic__false_true(F.logic__pair_snd(B.Buf, Bool, x, False{}, D.bf(t, n), True{}, h))

# A run at tag 6 fails.
def no_run6(+t: F.array__Tree<U32>, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, pair: B.Buf & U32,
    h: {C.run(p, 6, s, fr, a, b, c, pair) == (D.bf(t, n), True{}) : B.Buf & Bool}) -> Empty:
  match pair:
    case (x, y): no_run6_at(t, n, p, s, fr, a, b, c, x, y, h)
