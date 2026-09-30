import Base

# Bit-level facts about U32 words that hold for every word (no case split over the 2^32 values):
# masking with zeros, the low bit, and the test `(z & 1) == 1`. codegen/coll_laws.py builds the
# read-back of single bits (proofs/obj/coll_bits.bend) on these.

def band_false(+x: Bool) -> {Bool.and(x, False{}) == False{} : Bool}:
  match x:
    case False{}: {==}
    case True{}: {==}

def bor_true(+x: Bool) -> {Bool.or(x, True{}) == True{} : Bool}:
  match x:
    case False{}: {==}
    case True{}: {==}

# a AND 0 = 0, at every width
def wand_zero(+n: Nat, +a: Word(n)) -> {Word.and(n, a, Word.zero(n)) == Word.zero(n) : Word(n)}:
  match n a:
    case 0n WNil{}: {==}
    case 1n+ +p WCon{+x, +s}:
      %Equal.sym(Bool, Bool.and(x, False{}), False{}, band_false(x)) : {WCon{_, Word.and(p, s, Word.zero(p))} == WCon{False{}, Word.zero(p)} : Word(1n+p)}
      %Equal.sym(Word(p), Word.and(p, s, Word.zero(p)), Word.zero(p), wand_zero(p, s)) : {WCon{False{}, _} == WCon{False{}, Word.zero(p)} : Word(1n+p)}
      {==}

# the low bit of a word
def low(x: U32) -> Bool:
  match x:
    case U32{w}:
      match w:
        case WCon{b, t}: b

# the run-time test of the low bit is the low bit
def low_test(+z: U32) -> {U32.is_eq(U32.and(z, 1), 1) == low(z) : Bool}:
  match z:
    case U32{WCon{True{}, +t}}:
      %Equal.sym(Word(31n), Word.and(31n, t, Word.zero(31n)), Word.zero(31n), wand_zero(31n, t)) : {U32.is_eq(U32{WCon{True{}, _}}, 1) == True{} : Bool}
      {==}
    case U32{WCon{False{}, +t}}:
      %Equal.sym(Word(31n), Word.and(31n, t, Word.zero(31n)), Word.zero(31n), wand_zero(31n, t)) : {U32.is_eq(U32{WCon{False{}, _}}, 1) == False{} : Bool}
      {==}

# ---- bytes ----
def band_true(+x: Bool) -> {Bool.and(x, True{}) == x : Bool}:
  match x:
    case False{}: {==}
    case True{}: {==}

# a bit of (old AND NOT mask) OR (new AND mask) inside the mask is the new bit
def sel(+x: Bool, +y: Bool) -> {Bool.or(Bool.and(x, False{}), Bool.and(y, True{})) == y : Bool}:
  match x y:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}: {==}

# the low byte of a word, as a word
def lo8(z: U32) -> U32:
  match z:
    case U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, t}}}}}}}}}: U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}}

def and255(+z: U32) -> {U32.and(z, 255) == lo8(z) : U32}:
  match z:
    case U32{WCon{+b0, WCon{+b1, WCon{+b2, WCon{+b3, WCon{+b4, WCon{+b5, WCon{+b6, WCon{+b7, +t}}}}}}}}}:
      %Equal.sym(Word(24n), Word.and(24n, t, Word.zero(24n)), Word.zero(24n), wand_zero(24n, t)) : {U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), _}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b0, True{}), b0, band_true(b0)) : {U32{WCon{_, WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b1, True{}), b1, band_true(b1)) : {U32{WCon{b0, WCon{_, WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b2, True{}), b2, band_true(b2)) : {U32{WCon{b0, WCon{b1, WCon{_, WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b3, True{}), b3, band_true(b3)) : {U32{WCon{b0, WCon{b1, WCon{b2, WCon{_, WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b4, True{}), b4, band_true(b4)) : {U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{_, WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b5, True{}), b5, band_true(b5)) : {U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{_, WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b6, True{}), b6, band_true(b6)) : {U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{_, WCon{Bool.and(b7, True{}), Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      %Equal.sym(Bool, Bool.and(b7, True{}), b7, band_true(b7)) : {U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{_, Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} : U32}
      {==}

# ---- a word that is at most 255 is its low byte ----
def fin_not_gt(+b: Bool, +c: Cmp, +h: {Cmp.is_gt(Word.cmp.fin(b, False{}, c)) == False{} : Bool}) -> {Cmp.is_gt(c) == False{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: h

def cmp_zero(+n: Nat) -> {Word.cmp(n, Word.zero(n), Word.zero(n)) == EQ{} : Cmp}:
  match n:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Cmp, Word.cmp(p, Word.zero(p), Word.zero(p)), EQ{}, cmp_zero(p)) : {Word.cmp.fin(False{}, False{}, _) == EQ{} : Cmp}
      {==}

def head_zero(+b: Bool, +h: {Cmp.is_gt(Bool.cmp(b, False{})) == False{} : Bool}) -> {b == False{} : Bool}:
  match b:
    case False{}: {==}
    case True{}: h

def tail_head2(+p: Nat, +b: Bool, +s: Word(p), +h: {Cmp.is_gt(Word.cmp.fin(b, False{}, Word.cmp(p, s, Word.zero(p)))) == False{} : Bool}, +es: {s == Word.zero(p) : Word(p)})
    -> {Cmp.is_gt(Bool.cmp(b, False{})) == False{} : Bool}:
  %cmp_zero(p) : {Cmp.is_gt(Word.cmp.fin(b, False{}, _)) == False{} : Bool}
  %es : {Cmp.is_gt(Word.cmp.fin(b, False{}, Word.cmp(p, _, Word.zero(p)))) == False{} : Bool}
  h

def tail_head(+p: Nat, +b: Bool, +s: Word(p), +h: {Cmp.is_gt(Word.cmp.fin(b, False{}, Word.cmp(p, s, Word.zero(p)))) == False{} : Bool}, +es: {s == Word.zero(p) : Word(p)})
    -> {b == False{} : Bool}:
  head_zero(b, tail_head2(p, b, s, h, es))

def tail_step(+p: Nat, +b: Bool, +s: Word(p), +h: {Cmp.is_gt(Word.cmp.fin(b, False{}, Word.cmp(p, s, Word.zero(p)))) == False{} : Bool}, +es: {s == Word.zero(p) : Word(p)})
    -> {WCon{b, s} == WCon{False{}, Word.zero(p)} : Word(1n+p)}:
  +hb = tail_head(p, b, s, h, es)
  %Equal.sym(Bool, b, False{}, hb) : {WCon{_, s} == WCon{False{}, Word.zero(p)} : Word(1n+p)}
  %Equal.sym(Word(p), s, Word.zero(p), es) : {WCon{False{}, _} == WCon{False{}, Word.zero(p)} : Word(1n+p)}
  {==}

# a word that does not compare above zero is zero
def tail_zero(+n: Nat, +t: Word(n), +h: {Cmp.is_gt(Word.cmp(n, t, Word.zero(n))) == False{} : Bool}) -> {t == Word.zero(n) : Word(n)}:
  match n t:
    case 0n WNil{}: {==}
    case 1n+ +p WCon{+b, +s}: tail_step(p, b, s, h, tail_zero(p, s, fin_not_gt(b, Word.cmp(p, s, Word.zero(p)), h)))

# the comparison of a word with 255 is above when its upper 24 bits compare above zero
def chain8(+b0: Bool, +b1: Bool, +b2: Bool, +b3: Bool, +b4: Bool, +b5: Bool, +b6: Bool, +b7: Bool, +c: Cmp, +h: {Cmp.is_le(Word.cmp.fin(b0, True{}, Word.cmp.fin(b1, True{}, Word.cmp.fin(b2, True{}, Word.cmp.fin(b3, True{}, Word.cmp.fin(b4, True{}, Word.cmp.fin(b5, True{}, Word.cmp.fin(b6, True{}, Word.cmp.fin(b7, True{}, c))))))))) == True{} : Bool}) -> {Cmp.is_gt(c) == False{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: Equal.sym(Bool, False{}, True{}, h)

def byte_tail(+v: U32, +h: {U32.is_le(v, 255) == True{} : Bool}) -> {lo8(v) == v : U32}:
  match v:
    case U32{WCon{+b0, WCon{+b1, WCon{+b2, WCon{+b3, WCon{+b4, WCon{+b5, WCon{+b6, WCon{+b7, +t}}}}}}}}}:
      %Equal.sym(Word(24n), t, Word.zero(24n), tail_zero(24n, t, chain8(b0, b1, b2, b3, b4, b5, b6, b7, Word.cmp(24n, t, Word.zero(24n)), h))) : {U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, Word.zero(24n)}}}}}}}}} == U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, _}}}}}}}}} : U32}
      {==}

# a byte value (at most 255) is its own low byte: v & 255 == v
def byte_id(+v: U32, +h: {U32.is_le(v, 255) == True{} : Bool}) -> {U32.and(v, 255) == v : U32}:
  Equal.trans(U32, U32.and(v, 255), lo8(v), v, and255(v), byte_tail(v, h))
