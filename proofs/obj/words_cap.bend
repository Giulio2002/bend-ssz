import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../compact/found_generated.bend as F
import ./words_canon.bend as WCN

# The roots hash the object's chunks, bounded by the storage (O.wr_size, O.cap_cnt: docs/CRASH_HUNT.md CH-03, R2-02). For an object whose
# storage holds its whole chunks (the representation every law states: a perfect tree of depth dw with 8 * chunks <= 2^dw words) the root is
# the one of the plain definition. These lemmas rewrite the runtime root to that form; the root laws start from it.

def wr_unfold(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +dw: Nat, +t: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)) == True{} : Bool},
    +canon: {O.wcn_k(O.chunks_of(N), N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool})
    -> {O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, t, pf)) :
    {O.wr_size(hl, h, dU, N, _) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), F.spec_common__pow2(dw), F.u32__pow2u_value(dw, hd)) :
    {O.wr_cap(Nat.is_le(O.e8(O.chunks_of(N)), _), hl, h, dU, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Bool, Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)), True{}, cap) :
    {O.wr_cap(_, hl, h, dU, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Array<U32> & Bool, O.wcn_k(O.chunks_of(N), N, F.u32__pow2u(dw), F.array__thaw(U32, t)), (F.array__thaw(U32, t), True{}), canon) :
    {O.wr_zc(hl, h, dU, N, F.u32__pow2u(dw), _) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  {==}

def le0(+x: Nat) -> {Nat.is_le(0n, x) == True{} : Bool}:
  match x:
    case 0n: {==}
    case 1n+p: {==}

# An empty object (no chunks) needs no room whatever the storage, and has no chunk to be unclean.
def wr_unfold0(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +dw: Nat, +t: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +e0: {O.chunks_of(N) == 0n : Nat})
    -> {O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, t, pf)) :
    {O.wr_size(hl, h, dU, N, _) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, O.chunks_of(N), 0n, e0) :
    {O.wr_cap(Nat.is_le(O.e8(_), U32.to_nat(F.u32__pow2u(dw))), hl, h, dU, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Bool, Nat.is_le(0n, U32.to_nat(F.u32__pow2u(dw))), True{}, le0(U32.to_nat(F.u32__pow2u(dw)))) :
    {O.wr_cap(_, hl, h, dU, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Array<U32> & Bool, O.wcn_k(O.chunks_of(N), N, F.u32__pow2u(dw), F.array__thaw(U32, t)), (F.array__thaw(U32, t), True{}), WCN.canon0(N, F.u32__pow2u(dw), F.array__thaw(U32, t), e0)) :
    {O.wr_zc(hl, h, dU, N, F.u32__pow2u(dw), _) == O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) : B.Buf & (O.Words & D.Digest)}
  {==}

# The packed-element root: the element count is bounded by the storage the same way (O.er_size). Whenever the elements fit the storage
# (count * ew <= 2^dw words, the wfe invariant) the bound is the count itself.
def er_unfold(+hl: Nat, -h: B.Buf, +ew: U32, +ed: U32, +dU: U32, +seg: U32, +N: U32, +dw: Nat, +t: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +cap: {Nat.is_le(Nat.mul(U32.to_nat(U32.div(N, (4 * ew : U32))), U32.to_nat(ew)), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {O.elems_root(hl, h, O.Words{F.array__thaw(U32, t), N}, ew, ed, dU, seg) == O.er_cnt(hl, h, ew, ed, dU, N, F.array__thaw(U32, t), U32.to_nat(U32.div(N, (4 * ew : U32)))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, t, pf)) :
    {O.er_size(hl, h, ew, ed, dU, N, _) == O.er_cnt(hl, h, ew, ed, dU, N, F.array__thaw(U32, t), U32.to_nat(U32.div(N, (4 * ew : U32)))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), F.spec_common__pow2(dw), F.u32__pow2u_value(dw, hd)) :
    {O.er_cnt(hl, h, ew, ed, dU, N, F.array__thaw(U32, t), O.cap_cnt(U32.to_nat(U32.div(N, (4 * ew : U32))), Nat.mul(U32.to_nat(U32.div(N, (4 * ew : U32))), U32.to_nat(ew)), U32.to_nat(ew), _)) == O.er_cnt(hl, h, ew, ed, dU, N, F.array__thaw(U32, t), U32.to_nat(U32.div(N, (4 * ew : U32)))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Bool, Nat.is_le(Nat.mul(U32.to_nat(U32.div(N, (4 * ew : U32))), U32.to_nat(ew)), F.spec_common__pow2(dw)), True{}, cap) :
    {O.er_cnt(hl, h, ew, ed, dU, N, F.array__thaw(U32, t), O.cap_cnt_go(_, U32.to_nat(U32.div(N, (4 * ew : U32))), U32.to_nat(ew), F.spec_common__pow2(dw))) == O.er_cnt(hl, h, ew, ed, dU, N, F.array__thaw(U32, t), U32.to_nat(U32.div(N, (4 * ew : U32)))) : B.Buf & (O.Words & D.Digest)}
  {==}

# The progressive packed-bytes root, bounded by the storage the same way (O.wrp_size).
def wrp_unfold(+hl: Nat, -h: B.Buf, +seg: U32, +N: U32, +dw: Nat, +t: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)) == True{} : Bool},
    +canon: {O.wcn_k(O.chunks_of(N), N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool})
    -> {O.words_root_prog(hl, h, O.Words{F.array__thaw(U32, t), N}, seg) == O.mt_words(N, O.prog_root(hl, O.LWords{}, O.chunks_of(N), h, F.array__thaw(U32, t))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, t, pf)) :
    {O.wrp_size(hl, h, N, _) == O.mt_words(N, O.prog_root(hl, O.LWords{}, O.chunks_of(N), h, F.array__thaw(U32, t))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), F.spec_common__pow2(dw), F.u32__pow2u_value(dw, hd)) :
    {O.wrp_cap(Nat.is_le(O.e8(O.chunks_of(N)), _), hl, h, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == O.mt_words(N, O.prog_root(hl, O.LWords{}, O.chunks_of(N), h, F.array__thaw(U32, t))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Bool, Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)), True{}, cap) :
    {O.wrp_cap(_, hl, h, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == O.mt_words(N, O.prog_root(hl, O.LWords{}, O.chunks_of(N), h, F.array__thaw(U32, t))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Array<U32> & Bool, O.wcn_k(O.chunks_of(N), N, F.u32__pow2u(dw), F.array__thaw(U32, t)), (F.array__thaw(U32, t), True{}), canon) :
    {O.wrp_zc(hl, h, N, F.u32__pow2u(dw), _) == O.mt_words(N, O.prog_root(hl, O.LWords{}, O.chunks_of(N), h, F.array__thaw(U32, t))) : B.Buf & (O.Words & D.Digest)}
  {==}

# A count within the 2^dw slots of a perfect tree is within the U32 size of its array (the clamp of a list root and of a cache,
# docs/CRASH_HUNT.md R2-03, is the count itself for such a list).
def le_u32_pow2(+N: U32, +dw: Nat, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {U32.is_le(N, F.u32__pow2u(dw)) == True{} : Bool}:
  %Equal.sym(Cmp, U32.cmp(N, F.u32__pow2u(dw)), Nat.cmp(U32.to_nat(N), U32.to_nat(F.u32__pow2u(dw))), F.u32__u32_cmp(N, F.u32__pow2u(dw))) :
    {Cmp.is_le(_) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), F.spec_common__pow2(dw), F.u32__pow2u_value(dw, hd)) :
    {Cmp.is_le(Nat.cmp(U32.to_nat(N), _)) == True{} : Bool}
  hn
