import Base
import ../../src/buffer.bend as B
import ./found.bend as F
import ./bits.bend as W
import ./arith.bend as A

# Byte denotation of the packed buffer (src/buffer.bend), proved against the
# actual readers.
#
# A buffer is `B.Buf{thaw(t), n}` for a perfect mirror tree `t` of words
# (found.bend: the checked Base.Array laws). Its bytes are the little-endian
# unpacking of the tree's slots: word k holds bytes 4k .. 4k+3. `B.byte_at` is
# shown to read exactly that byte, so every later proof can reason about
# the input as the byte list the independent specifications quantify over.

# ---- specification view ---------------------------------------------------

def unpack(ws: List<&2, U32>) -> List<&2, U32>:
  match ws:
    case Nil{}: Nil{}
    case Con{+w, rest}:
      Con{B.byte_sel(0, w), Con{B.byte_sel(1, w), Con{B.byte_sel(2, w), Con{B.byte_sel(3, w), unpack(rest)}}}}

# The byte at index k of a buffer whose words are the slots of t.
def at(t: F.array__Tree<U32>, +k: Nat) -> U32:
  F.flat__nthc(unpack(F.array__slots(U32, t)), k)

# ---- unpacking: byte 4q + k is byte k of word q ----------------------------

def at_unpack0(ws: List<&2, U32>, +q: Nat) -> {F.flat__nthc(unpack(ws), Nat.double(Nat.double(q))) == B.byte_sel(0, F.flat__nthc(ws, q)) : U32}:
  match ws q:
    case Nil{} _: {==}
    case Con{w, rest} 0n: {==}
    case Con{w, rest} 1n+p: at_unpack0(rest, p)

def at_unpack1(ws: List<&2, U32>, +q: Nat) -> {F.flat__nthc(unpack(ws), 1n+Nat.double(Nat.double(q))) == B.byte_sel(1, F.flat__nthc(ws, q)) : U32}:
  match ws q:
    case Nil{} _: {==}
    case Con{w, rest} 0n: {==}
    case Con{w, rest} 1n+p: at_unpack1(rest, p)

def at_unpack2(ws: List<&2, U32>, +q: Nat) -> {F.flat__nthc(unpack(ws), 2n+Nat.double(Nat.double(q))) == B.byte_sel(2, F.flat__nthc(ws, q)) : U32}:
  match ws q:
    case Nil{} _: {==}
    case Con{w, rest} 0n: {==}
    case Con{w, rest} 1n+p: at_unpack2(rest, p)

def at_unpack3(ws: List<&2, U32>, +q: Nat) -> {F.flat__nthc(unpack(ws), 3n+Nat.double(Nat.double(q))) == B.byte_sel(3, F.flat__nthc(ws, q)) : U32}:
  match ws q:
    case Nil{} _: {==}
    case Con{w, rest} 0n: {==}
    case Con{w, rest} 1n+p: at_unpack3(rest, p)

# ---- word facts --------------------------------------------------------------

def and_zero(+n: Nat, w: Word(n)) -> {Word.and(n, w, Word.zero(n)) == Word.zero(n) : Word(n)}:
  match n:
    case 0n: {==}
    case 1n+p:
      match w:
        case WCon{False{}, t}:
          %and_zero(p, t) : {WCon{False{}, Word.and(p, t, Word.zero(p))} == WCon{False{}, _} : Word(1n+p)}
          {==}
        case WCon{True{}, t}:
          %and_zero(p, t) : {WCon{False{}, Word.and(p, t, Word.zero(p))} == WCon{False{}, _} : Word(1n+p)}
          {==}

def pad_value(+n: Nat, w: Word(n)) -> {Word.to_nat(1n+n, Word.shr.pad(n, w)) == Word.to_nat(n, w) : Nat}:
  match n:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{False{}, t}:
          %Equal.sym(Nat, Word.to_nat(1n+p, Word.shr.pad(p, t)), Word.to_nat(p, t), pad_value(p, t)) : {Nat.double(_) == Nat.double(Word.to_nat(p, t)) : Nat}
          {==}
        case WCon{True{}, t}:
          %Equal.sym(Nat, Word.to_nat(1n+p, Word.shr.pad(p, t)), Word.to_nat(p, t), pad_value(p, t)) : {1n+Nat.double(_) == 1n+Nat.double(Word.to_nat(p, t)) : Nat}
          {==}

# i >> 2 keeps the high thirty bits.
def quarter_value(+b0: Bool, +b1: Bool, +t: Word(30n)) -> {U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, t}}}, 2n)) == Word.to_nat(30n, t) : Nat}:
  Equal.trans(Nat, Word.to_nat(32n, Word.shr.pad(31n, Word.shr.pad(30n, t))), Word.to_nat(31n, Word.shr.pad(30n, t)), Word.to_nat(30n, t),
    pad_value(31n, Word.shr.pad(30n, t)), pad_value(30n, t))

# i & 3 keeps the low two bits.
def low_sel(+b0: Bool, +b1: Bool, +t: Word(30n)) -> {U32{WCon{b0, WCon{b1, Word.zero(30n)}}} == U32.and(U32{WCon{b0, WCon{b1, t}}}, 3) : U32}:
  match b0 b1:
    case False{} False{}:
      %Equal.sym(Word(30n), Word.and(30n, t, Word.zero(30n)), Word.zero(30n), and_zero(30n, t)) : {U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}} == U32{WCon{False{}, WCon{False{}, _}}} : U32}
      {==}
    case False{} True{}:
      %Equal.sym(Word(30n), Word.and(30n, t, Word.zero(30n)), Word.zero(30n), and_zero(30n, t)) : {U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}} == U32{WCon{False{}, WCon{True{}, _}}} : U32}
      {==}
    case True{} False{}:
      %Equal.sym(Word(30n), Word.and(30n, t, Word.zero(30n)), Word.zero(30n), and_zero(30n, t)) : {U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}} == U32{WCon{True{}, WCon{False{}, _}}} : U32}
      {==}
    case True{} True{}:
      %Equal.sym(Word(30n), Word.and(30n, t, Word.zero(30n)), Word.zero(30n), and_zero(30n, t)) : {U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}} == U32{WCon{True{}, WCon{True{}, _}}} : U32}
      {==}

# ---- reads -----------------------------------------------------------------

# Word q of a buffer built on a perfect tree of depth d is slot q.
def word_read(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hq: {Nat.is_lt(U32.to_nat(q), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(B.Buf{F.array__thaw(U32, t), n}, q) == (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), U32.to_nat(q))) : B.Buf & U32}:
  +x = F.flat__nthc(F.array__slots(U32, t), U32.to_nat(q))
  +hx = F.flat__nthc_nth(F.array__slots(U32, t), U32.to_nat(q), F.array__len_lt(U32, d, t, U32.to_nat(q), pf, hq))
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), q), (F.array__thaw(U32, t), x), F.array__get(U32, d, t, q, x, hd, hq, hx, pf)) : {B.rewrap(n, _) == (B.Buf{F.array__thaw(U32, t), n}, x) : B.Buf & U32}
  {==}

# The four cases of the low two bits.
def byte_at_bits(+t: F.array__Tree<U32>, +n: U32, +b0: Bool, +b1: Bool, +r: Word(30n))
    -> {B.byte_pick(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}, (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)))) == (B.Buf{F.array__thaw(U32, t), n}, at(t, U32.to_nat(U32{WCon{b0, WCon{b1, r}}}))) : B.Buf & U32}:
  match b0 b1:
    case False{} False{}:
      %at_unpack0(F.array__slots(U32, t), Word.to_nat(30n, r)) : {(B.Buf{F.array__thaw(U32, t), n}, _) == (B.Buf{F.array__thaw(U32, t), n}, at(t, Nat.double(Nat.double(Word.to_nat(30n, r))))) : B.Buf & U32}
      {==}
    case True{} False{}:
      %at_unpack1(F.array__slots(U32, t), Word.to_nat(30n, r)) : {(B.Buf{F.array__thaw(U32, t), n}, _) == (B.Buf{F.array__thaw(U32, t), n}, at(t, 1n+Nat.double(Nat.double(Word.to_nat(30n, r))))) : B.Buf & U32}
      {==}
    case False{} True{}:
      %at_unpack2(F.array__slots(U32, t), Word.to_nat(30n, r)) : {(B.Buf{F.array__thaw(U32, t), n}, _) == (B.Buf{F.array__thaw(U32, t), n}, at(t, 2n+Nat.double(Nat.double(Word.to_nat(30n, r))))) : B.Buf & U32}
      {==}
    case True{} True{}:
      %at_unpack3(F.array__slots(U32, t), Word.to_nat(30n, r)) : {(B.Buf{F.array__thaw(U32, t), n}, _) == (B.Buf{F.array__thaw(U32, t), n}, at(t, 3n+Nat.double(Nat.double(Word.to_nat(30n, r))))) : B.Buf & U32}
      {==}

# Byte i of such a buffer is byte i of its unpacked words.
def byte_at_value(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +i: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hq: {Nat.is_lt(U32.to_nat(U32.shrn(i, 2n)), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.byte_at(B.Buf{F.array__thaw(U32, t), n}, i) == (B.Buf{F.array__thaw(U32, t), n}, at(t, U32.to_nat(i))) : B.Buf & U32}:
  match i:
    case U32{WCon{+b0, WCon{+b1, +r}}}:
      %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n)))), word_read(d, t, n, U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n), hd, hq, pf)) : {B.byte_pick(U32.and(U32{WCon{b0, WCon{b1, r}}}, 3), _) == (B.Buf{F.array__thaw(U32, t), n}, at(t, U32.to_nat(U32{WCon{b0, WCon{b1, r}}}))) : B.Buf & U32}
      %low_sel(b0, b1, r) : {B.byte_pick(_, (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n))))) == (B.Buf{F.array__thaw(U32, t), n}, at(t, U32.to_nat(U32{WCon{b0, WCon{b1, r}}}))) : B.Buf & U32}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n)), Word.to_nat(30n, r), quarter_value(b0, b1, r)) : {B.byte_pick(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}, (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), _))) == (B.Buf{F.array__thaw(U32, t), n}, at(t, U32.to_nat(U32{WCon{b0, WCon{b1, r}}}))) : B.Buf & U32}
      byte_at_bits(t, n, b0, b1, r)

# ---- four-byte little-endian reads -----------------------------------------

# Word q of the buffer, once q is known to be below the capacity.
def word_at(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32, +qq: Nat,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +eq: {U32.to_nat(q) == qq : Nat},
    +hq: {Nat.is_lt(qq, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(B.Buf{F.array__thaw(U32, t), n}, q) == (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), qq)) : B.Buf & U32}:
  %eq : {B.word(B.Buf{F.array__thaw(U32, t), n}, q) == (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), _)) : B.Buf & U32}
  word_read(d, t, n, q, hd, F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, qq, U32.to_nat(q), Equal.sym(Nat, U32.to_nat(q), qq, eq), hq), pf)

def read32_aligned(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +r: Word(30n),
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(A.quad(Word.to_nat(30n, r)), 4n), A.quad(F.spec_common__pow2(d))) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, U32{WCon{False{}, WCon{False{}, r}}}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}:
  %low_sel(False{}, False{}, r) : {B.read32_choose(U32{WCon{False{}, WCon{False{}, r}}}, _, U32.is_eq(_, 0), B.Buf{F.array__thaw(U32, t), n}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(U32{WCon{False{}, WCon{False{}, r}}}, 2n)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), word_at(d, t, n, U32.shrn(U32{WCon{False{}, WCon{False{}, r}}}, 2n), Word.to_nat(30n, r), hd, quarter_value(False{}, False{}, r), A.room_aligned(Word.to_nat(30n, r), F.spec_common__pow2(d), hr), pf)) : {_ == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  Equal.cong(U32, B.Buf & U32, x => (B.Buf{F.array__thaw(U32, t), n}, x), F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), W.asm(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r)))),
    Equal.trans(U32, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), W.asm(B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)))), W.asm(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r)))), W.reassemble(F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))),
      Equal.sym(U32, W.asm(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r)))), W.asm(B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)))), W.asm_cong(at(t, A.quad(Word.to_nat(30n, r))), at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), at_unpack0(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack1(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack2(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack3(F.array__slots(U32, t), Word.to_nat(30n, r))))))

def read32_off1(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +r: Word(30n),
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(1n+A.quad(Word.to_nat(30n, r)), 4n), A.quad(F.spec_common__pow2(d))) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, U32{WCon{True{}, WCon{False{}, r}}}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}:
  +room = A.room_unaligned(0n, Word.to_nat(30n, r), F.spec_common__pow2(d), hr)
  +qv = quarter_value(True{}, False{}, r)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), 1n+A.quad(Word.to_nat(30n, r))) == True{} : Bool}, Word.to_nat(30n, r), U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), Word.to_nat(30n, r), qv),
    F.logic__subst(Nat, z => {Nat.is_le(z, 1n+A.quad(Word.to_nat(30n, r))) == True{} : Bool}, 1n+Word.to_nat(30n, r), Nat.add(Word.to_nat(30n, r), 1n), Equal.sym(Nat, Nat.add(Word.to_nat(30n, r), 1n), 1n+Word.to_nat(30n, r), F.flat__add_one(Word.to_nat(30n, r))),
      F.nat__le_trans(1n+Word.to_nat(30n, r), 1n+A.quad(Word.to_nat(30n, r)), 1n+A.quad(Word.to_nat(30n, r)), A.quad_ge(Word.to_nat(30n, r)), A.le_skip(0n, 1n+A.quad(Word.to_nat(30n, r))))))
  +q1v = Equal.trans(Nat, U32.to_nat(U32.add(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n), 1)), Nat.add(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), 1n), 1n+Word.to_nat(30n, r), A.add_le(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n), 1, U32{WCon{True{}, WCon{False{}, r}}}, h1),
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), 1n), Nat.add(Word.to_nat(30n, r), 1n), 1n+Word.to_nat(30n, r), Equal.cong(Nat, Nat, z => Nat.add(z, 1n), U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), Word.to_nat(30n, r), qv), F.flat__add_one(Word.to_nat(30n, r))))
  %low_sel(True{}, False{}, r) : {B.read32_choose(U32{WCon{True{}, WCon{False{}, r}}}, _, U32.is_eq(_, 0), B.Buf{F.array__thaw(U32, t), n}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), word_at(d, t, n, U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n), Word.to_nat(30n, r), hd, qv, F.nat__lt_trans(Word.to_nat(30n, r), 1n+Word.to_nat(30n, r), F.spec_common__pow2(d), F.nat__lt_succ(Word.to_nat(30n, r)), room), pf)) : {B.read32_split(U32{WCon{True{}, WCon{False{}, r}}}, U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, _) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.add(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n), 1)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), word_at(d, t, n, U32.add(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n), 1), 1n+Word.to_nat(30n, r), hd, q1v, room, pf)) : {B.join_words(U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), _) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  Equal.cong(U32, B.Buf & U32, x => (B.Buf{F.array__thaw(U32, t), n}, x), B.join_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r)))),
    Equal.trans(U32, B.join_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), W.asm(B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)))), W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r)))), W.join_asm1(F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))),
      Equal.sym(U32, W.asm(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r)))), W.asm(B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)))), W.asm_cong(at(t, 1n+A.quad(Word.to_nat(30n, r))), at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), at_unpack1(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack2(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack3(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack0(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))))))

def read32_off2(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +r: Word(30n),
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(2n+A.quad(Word.to_nat(30n, r)), 4n), A.quad(F.spec_common__pow2(d))) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, U32{WCon{False{}, WCon{True{}, r}}}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}:
  +room = A.room_unaligned(1n, Word.to_nat(30n, r), F.spec_common__pow2(d), hr)
  +qv = quarter_value(False{}, True{}, r)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), 2n+A.quad(Word.to_nat(30n, r))) == True{} : Bool}, Word.to_nat(30n, r), U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), qv),
    F.logic__subst(Nat, z => {Nat.is_le(z, 2n+A.quad(Word.to_nat(30n, r))) == True{} : Bool}, 1n+Word.to_nat(30n, r), Nat.add(Word.to_nat(30n, r), 1n), Equal.sym(Nat, Nat.add(Word.to_nat(30n, r), 1n), 1n+Word.to_nat(30n, r), F.flat__add_one(Word.to_nat(30n, r))),
      F.nat__le_trans(1n+Word.to_nat(30n, r), 1n+A.quad(Word.to_nat(30n, r)), 2n+A.quad(Word.to_nat(30n, r)), A.quad_ge(Word.to_nat(30n, r)), A.le_skip(1n, 1n+A.quad(Word.to_nat(30n, r))))))
  +q1v = Equal.trans(Nat, U32.to_nat(U32.add(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n), 1)), Nat.add(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), 1n), 1n+Word.to_nat(30n, r), A.add_le(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n), 1, U32{WCon{False{}, WCon{True{}, r}}}, h1),
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), 1n), Nat.add(Word.to_nat(30n, r), 1n), 1n+Word.to_nat(30n, r), Equal.cong(Nat, Nat, z => Nat.add(z, 1n), U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), qv), F.flat__add_one(Word.to_nat(30n, r))))
  %low_sel(False{}, True{}, r) : {B.read32_choose(U32{WCon{False{}, WCon{True{}, r}}}, _, U32.is_eq(_, 0), B.Buf{F.array__thaw(U32, t), n}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), word_at(d, t, n, U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n), Word.to_nat(30n, r), hd, qv, F.nat__lt_trans(Word.to_nat(30n, r), 1n+Word.to_nat(30n, r), F.spec_common__pow2(d), F.nat__lt_succ(Word.to_nat(30n, r)), room), pf)) : {B.read32_split(U32{WCon{False{}, WCon{True{}, r}}}, U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, _) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.add(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n), 1)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), word_at(d, t, n, U32.add(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n), 1), 1n+Word.to_nat(30n, r), hd, q1v, room, pf)) : {B.join_words(U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), _) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  Equal.cong(U32, B.Buf & U32, x => (B.Buf{F.array__thaw(U32, t), n}, x), B.join_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r)))),
    Equal.trans(U32, B.join_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), W.asm(B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)))), W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r)))), W.join_asm2(F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))),
      Equal.sym(U32, W.asm(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r)))), W.asm(B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)))), W.asm_cong(at(t, 2n+A.quad(Word.to_nat(30n, r))), at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), at_unpack2(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack3(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack0(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)), at_unpack1(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))))))

def read32_off3(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +r: Word(30n),
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(3n+A.quad(Word.to_nat(30n, r)), 4n), A.quad(F.spec_common__pow2(d))) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, U32{WCon{True{}, WCon{True{}, r}}}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}:
  +room = A.room_unaligned(2n, Word.to_nat(30n, r), F.spec_common__pow2(d), hr)
  +qv = quarter_value(True{}, True{}, r)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), 3n+A.quad(Word.to_nat(30n, r))) == True{} : Bool}, Word.to_nat(30n, r), U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), qv),
    F.logic__subst(Nat, z => {Nat.is_le(z, 3n+A.quad(Word.to_nat(30n, r))) == True{} : Bool}, 1n+Word.to_nat(30n, r), Nat.add(Word.to_nat(30n, r), 1n), Equal.sym(Nat, Nat.add(Word.to_nat(30n, r), 1n), 1n+Word.to_nat(30n, r), F.flat__add_one(Word.to_nat(30n, r))),
      F.nat__le_trans(1n+Word.to_nat(30n, r), 1n+A.quad(Word.to_nat(30n, r)), 3n+A.quad(Word.to_nat(30n, r)), A.quad_ge(Word.to_nat(30n, r)), A.le_skip(2n, 1n+A.quad(Word.to_nat(30n, r))))))
  +q1v = Equal.trans(Nat, U32.to_nat(U32.add(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n), 1)), Nat.add(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), 1n), 1n+Word.to_nat(30n, r), A.add_le(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n), 1, U32{WCon{True{}, WCon{True{}, r}}}, h1),
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), 1n), Nat.add(Word.to_nat(30n, r), 1n), 1n+Word.to_nat(30n, r), Equal.cong(Nat, Nat, z => Nat.add(z, 1n), U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), qv), F.flat__add_one(Word.to_nat(30n, r))))
  %low_sel(True{}, True{}, r) : {B.read32_choose(U32{WCon{True{}, WCon{True{}, r}}}, _, U32.is_eq(_, 0), B.Buf{F.array__thaw(U32, t), n}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), word_at(d, t, n, U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n), Word.to_nat(30n, r), hd, qv, F.nat__lt_trans(Word.to_nat(30n, r), 1n+Word.to_nat(30n, r), F.spec_common__pow2(d), F.nat__lt_succ(Word.to_nat(30n, r)), room), pf)) : {B.read32_split(U32{WCon{True{}, WCon{True{}, r}}}, U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, _) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  %Equal.sym(B.Buf & U32, B.word(B.Buf{F.array__thaw(U32, t), n}, U32.add(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n), 1)), (B.Buf{F.array__thaw(U32, t), n}, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), word_at(d, t, n, U32.add(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n), 1), 1n+Word.to_nat(30n, r), hd, q1v, room, pf)) : {B.join_words(U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), _) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r))))) : B.Buf & U32}
  Equal.cong(U32, B.Buf & U32, x => (B.Buf{F.array__thaw(U32, t), n}, x), B.join_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r)))),
    Equal.trans(U32, B.join_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), W.asm(B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)))), W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r)))), W.join_asm3(F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r)), F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))),
      Equal.sym(U32, W.asm(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r)))), W.asm(B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)))), W.asm_cong(at(t, 3n+A.quad(Word.to_nat(30n, r))), at(t, 4n+A.quad(Word.to_nat(30n, r))), at(t, 5n+A.quad(Word.to_nat(30n, r))), at(t, 6n+A.quad(Word.to_nat(30n, r))), B.byte_sel(3, F.flat__nthc(F.array__slots(U32, t), Word.to_nat(30n, r))), B.byte_sel(0, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(1, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), B.byte_sel(2, F.flat__nthc(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))), at_unpack3(F.array__slots(U32, t), Word.to_nat(30n, r)), at_unpack0(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)), at_unpack1(F.array__slots(U32, t), 1n+Word.to_nat(30n, r)), at_unpack2(F.array__slots(U32, t), 1n+Word.to_nat(30n, r))))))

def read32_bits(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +b0: Bool, +b1: Bool, +r: Word(30n),
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(U32.to_nat(U32{WCon{b0, WCon{b1, r}}}), 4n), A.quad(F.spec_common__pow2(d))) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, U32{WCon{b0, WCon{b1, r}}}) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, U32.to_nat(U32{WCon{b0, WCon{b1, r}}})), at(t, 1n+U32.to_nat(U32{WCon{b0, WCon{b1, r}}})), at(t, 2n+U32.to_nat(U32{WCon{b0, WCon{b1, r}}})), at(t, 3n+U32.to_nat(U32{WCon{b0, WCon{b1, r}}})))) : B.Buf & U32}:
  match b0 b1:
    case False{} False{}: read32_aligned(d, t, n, r, hd, hr, pf)
    case True{} False{}: read32_off1(d, t, n, r, hd, hr, pf)
    case False{} True{}: read32_off2(d, t, n, r, hd, hr, pf)
    case True{} True{}: read32_off3(d, t, n, r, hd, hr, pf)

# Four little-endian bytes at i, when they lie inside the capacity.
def read32_value(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +i: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(U32.to_nat(i), 4n), A.quad(F.spec_common__pow2(d))) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(B.Buf{F.array__thaw(U32, t), n}, i) == (B.Buf{F.array__thaw(U32, t), n}, W.asm(at(t, U32.to_nat(i)), at(t, 1n+U32.to_nat(i)), at(t, 2n+U32.to_nat(i)), at(t, 3n+U32.to_nat(i)))) : B.Buf & U32}:
  match i:
    case U32{WCon{+b0, WCon{+b1, +r}}}: read32_bits(d, t, n, b0, b1, r, hd, hr, pf)
