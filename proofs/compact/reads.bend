import Base
import ../../src/buffer.bend as B
import ./found_generated.bend as F
import ./arith.bend as A

# Every buffer read returns the buffer unchanged, at any index. Base.Array.get
# masks an out-of-range index into range, so a read past the capacity yields
# some word of the array: the scanner performs such reads only where it then
# discards the value, and the lemmas here let a proof carry on regardless.

# x & y <= y, at any width.
def and_le_w(+n: Nat, +x: Word(n), +y: Word(n)) -> {Nat.is_le(F.u32alg__uw(n, Word.and(n, x, y)), F.u32alg__uw(n, y)) == True{} : Bool}:
  match n:
    case 0n:
      match x y:
        case WNil{} WNil{}: {==}
    case 1n+p:
      match x y:
        case WCon{False{}, xt} WCon{False{}, yt}: F.nat__double_le(F.u32alg__uw(p, Word.and(p, xt, yt)), F.u32alg__uw(p, yt), and_le_w(p, xt, yt))
        case WCon{False{}, xt} WCon{True{}, yt}: F.nat__le_trans(Nat.double(F.u32alg__uw(p, Word.and(p, xt, yt))), Nat.double(F.u32alg__uw(p, yt)), 1n+Nat.double(F.u32alg__uw(p, yt)), F.nat__double_le(F.u32alg__uw(p, Word.and(p, xt, yt)), F.u32alg__uw(p, yt), and_le_w(p, xt, yt)), F.nat__le_succ(Nat.double(F.u32alg__uw(p, yt))))
        case WCon{True{}, xt} WCon{False{}, yt}: F.nat__double_le(F.u32alg__uw(p, Word.and(p, xt, yt)), F.u32alg__uw(p, yt), and_le_w(p, xt, yt))
        case WCon{True{}, xt} WCon{True{}, yt}: F.nat__double_le(F.u32alg__uw(p, Word.and(p, xt, yt)), F.u32alg__uw(p, yt), and_le_w(p, xt, yt))

def and_le(+x: U32, +y: U32) -> {Nat.is_le(U32.to_nat(U32.and(x, y)), U32.to_nat(y)) == True{} : Bool}:
  match x y:
    case U32{+xw} U32{+yw}:
      F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(U32{yw})) == True{} : Bool}, F.u32alg__uw(32n, Word.and(32n, xw, yw)), U32.to_nat(U32{Word.and(32n, xw, yw)}),
        Equal.sym(Nat, U32.to_nat(U32{Word.and(32n, xw, yw)}), F.u32alg__uw(32n, Word.and(32n, xw, yw)), F.u32__to_nat_word(Word.and(32n, xw, yw))),
        F.logic__subst(Nat, z => {Nat.is_le(F.u32alg__uw(32n, Word.and(32n, xw, yw)), z) == True{} : Bool}, F.u32alg__uw(32n, yw), U32.to_nat(U32{yw}),
          Equal.sym(Nat, U32.to_nat(U32{yw}), F.u32alg__uw(32n, yw), F.u32__to_nat_word(yw)),
          and_le_w(32n, xw, yw)))

# x <= P - 1 and 1 <= P give x < P.
def lt_of_le_pred(+x: Nat, +p: Nat, +h: {Nat.is_le(x, Nat.sub(p, 1n)) == True{} : Bool}, +hp: {Nat.is_le(1n, p) == True{} : Bool}) -> {Nat.is_lt(x, p) == True{} : Bool}:
  match p:
    case 0n: Empty.absurd({Nat.is_lt(x, 0n) == True{} : Bool}, F.logic__false_true(hp))
    case 1n+q:
      F.nat__le_lt_trans(x, q, 1n+q, F.logic__subst(Nat, z => {Nat.is_le(x, z) == True{} : Bool}, Nat.sub(q, 0n), q, F.nat__sub_zero(q), h), F.nat__lt_succ(q))

# The index Base.Array.get actually reads: masked into range.
def masked(+q: U32, +d: Nat) -> U32: U32.and(q, U32.sub(F.u32__pow2u(d), 1))

def mask_lt(+q: U32, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat(masked(q, d)), F.spec_common__pow2(d)) == True{} : Bool}:
  +m = U32.sub(F.u32__pow2u(d), 1)
  +mv = Equal.trans(Nat, U32.to_nat(m), Nat.sub(U32.to_nat(F.u32__pow2u(d)), 1n), Nat.sub(F.spec_common__pow2(d), 1n),
    F.u32__sub_nat(F.u32__pow2u(d), 1, F.u32__one_le_pow2u(d, hd)),
    Equal.cong(Nat, Nat, z => Nat.sub(z, 1n), U32.to_nat(F.u32__pow2u(d)), F.spec_common__pow2(d), F.u32__pow2u_value(d, hd)))
  lt_of_le_pred(U32.to_nat(masked(q, d)), F.spec_common__pow2(d),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(masked(q, d)), z) == True{} : Bool}, U32.to_nat(m), Nat.sub(F.spec_common__pow2(d), 1n), mv, and_le(q, m)),
    F.nat__pow2_pos(d))

# The word a read of index q returns, whatever q is.
def wd(t: F.array__Tree<U32>, +d: Nat, +q: U32) -> U32:
  F.flat__nthc(F.array__slots(U32, t), U32.to_nat(masked(q, d)))

def word_any(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(B.Buf{F.array__thaw(U32, t), n}, q) == (B.Buf{F.array__thaw(U32, t), n}, wd(t, d, q)) : B.Buf & U32}:
  +m = masked(q, d)
  +hm = mask_lt(q, d, hd)
  +x = F.flat__nthc(F.array__slots(U32, t), U32.to_nat(m))
  +hx = F.flat__nthc_nth(F.array__slots(U32, t), U32.to_nat(m), F.array__len_lt(U32, d, t, U32.to_nat(m), pf, hm))
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf)) : {B.rewrap(n, Array.get.at(U32, q, _)) == (B.Buf{F.array__thaw(U32, t), n}, wd(t, d, q)) : B.Buf & U32}
  %Equal.sym(Array<U32> & U32, Array.get.go(U32, F.array__thaw(U32, t), F.u32__pow2u(d), m, U32.is_lt(m, U32.shr(F.u32__pow2u(d)))), (F.array__thaw(U32, t), x), F.array__get_go(U32, d, t, m, x, hd, hm, hx, U32.is_lt(m, U32.shr(F.u32__pow2u(d))), {==}, pf)) : {B.rewrap(n, _) == (B.Buf{F.array__thaw(U32, t), n}, wd(t, d, q)) : B.Buf & U32}
  {==}

# ---- byte and four-byte reads at any index --------------------------------

def b8(t: F.array__Tree<U32>, +d: Nat, +i: U32) -> U32:
  B.byte_sel(U32.and(i, 3), wd(t, d, U32.shrn(i, 2n)))

def byte_any(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +i: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.byte_at(B.Buf{F.array__thaw(U32, t), n}, i) == (B.Buf{F.array__thaw(U32, t), n}, b8(t, d, i)) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(i, 2n)), (B.Buf{F.array__thaw(U32, t), n}, wd(t, d, U32.shrn(i, 2n))), word_any(d, t, n, U32.shrn(i, 2n), hd, pf)) : {B.byte_pick(U32.and(i, 3), _) == (B.Buf{F.array__thaw(U32, t), n}, b8(t, d, i)) : B.Buf & U32}
  {==}

def r32_pick(aligned: Bool, +j: U32, +lo: U32, +hi: U32) -> U32:
  match aligned:
    case True{}: lo
    case False{}: B.join_sel(j, lo, hi)

def r32(+t: F.array__Tree<U32>, +d: Nat, +i: U32) -> U32:
  r32_pick(U32.is_eq(U32.and(i, 3), 0), U32.and(i, 3), wd(t, d, U32.shrn(i, 2n)), wd(t, d, U32.add(U32.shrn(i, 2n), 1)))

def read32_case(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +i: U32, +c: Bool,
    +ec: {U32.is_eq(U32.and(i, 3), 0) == c : Bool},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32_choose(i, U32.and(i, 3), c, B.Buf{F.array__thaw(U32, t), n}) == (B.Buf{F.array__thaw(U32, t), n}, r32_pick(c, U32.and(i, 3), wd(t, d, U32.shrn(i, 2n)), wd(t, d, U32.add(U32.shrn(i, 2n), 1)))) : B.Buf & U32}:
  match c:
    case True{}:
      word_any(d, t, n, U32.shrn(i, 2n), hd, pf)
    case False{}:
      %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(i, 2n)), (B.Buf{F.array__thaw(U32, t), n}, wd(t, d, U32.shrn(i, 2n))), word_any(d, t, n, U32.shrn(i, 2n), hd, pf)) : {B.read32_split(i, U32.and(i, 3), _) == (B.Buf{F.array__thaw(U32, t), n}, B.join_sel(U32.and(i, 3), wd(t, d, U32.shrn(i, 2n)), wd(t, d, U32.add(U32.shrn(i, 2n), 1)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.add(U32.shrn(i, 2n), 1)), (B.Buf{F.array__thaw(U32, t), n}, wd(t, d, U32.add(U32.shrn(i, 2n), 1))), word_any(d, t, n, U32.add(U32.shrn(i, 2n), 1), hd, pf)) : {B.join_words(U32.and(i, 3), wd(t, d, U32.shrn(i, 2n)), _) == (B.Buf{F.array__thaw(U32, t), n}, B.join_sel(U32.and(i, 3), wd(t, d, U32.shrn(i, 2n)), wd(t, d, U32.add(U32.shrn(i, 2n), 1)))) : B.Buf & U32}
      {==}

def read32_any(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +i: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, i) == (B.Buf{F.array__thaw(U32, t), n}, r32(t, d, i)) : B.Buf & U32}:
  read32_case(d, t, n, i, U32.is_eq(U32.and(i, 3), 0), {==}, hd, pf)
