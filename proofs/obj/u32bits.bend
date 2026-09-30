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
