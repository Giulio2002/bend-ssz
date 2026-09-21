import Base
import ../types/schema.bend as T

# Reflection lemmas for the actual Base comparison, not assumed arithmetic facts.
def false_motive(b: Bool) -> Type:
  match b:
    case False{}: Unit
    case True{}: Empty

def false_true(e: {False{} == True{} : Bool}) -> Empty:
  %e : false_motive(_)
  Unit{}

law cmp_tail:
  for c: Cmp
  for a: Bool
  for b: Bool
  for e: {Cmp.is_eq(Word.cmp.fin(a, b, c)) == True{} : Bool}
  {Cmp.is_eq(c) == True{} : Bool}
def cmp_tail(c, a, b, e):
  match c:
    case LT{}: e
    case GT{}: e
    case EQ{}: {==}

law cmp_head:
  for c: Cmp
  for a: Bool
  for b: Bool
  for e: {Cmp.is_eq(Word.cmp.fin(a, b, c)) == True{} : Bool}
  {a == b : Bool}
def cmp_head(c, a, b, e):
  match c:
    case LT{}: Empty.absurd({a == b : Bool}, false_true(e))
    case GT{}: Empty.absurd({a == b : Bool}, false_true(e))
    case EQ{}:
      match a b:
        case False{} False{}: {==}
        case True{} True{}: {==}
        case False{} True{}: Empty.absurd({False{} == True{} : Bool}, false_true(e))
        case True{} False{}: Empty.absurd({True{} == False{} : Bool}, false_true(e))

law word_compare_sound:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  for +e: {Cmp.is_eq(Word.cmp(n, a, b)) == True{} : Bool}
  {a == b : Word(n)}
def word_compare_sound(n, a, b, e):
  match n:
    case 0n:
      match a b:
        case WNil{} WNil{}: {==}
    case 1n+p:
      match a b:
        case WCon{ah, at} WCon{bh, bt}:
          %cmp_head(Word.cmp(p, at, bt), ah, bh, e) : {WCon{ah, at} == WCon{_, bt} : Word(1n+p)}
          %word_compare_sound(p, at, bt, cmp_tail(Word.cmp(p, at, bt), ah, bh, e)) : {WCon{ah, at} == WCon{ah, _} : Word(1n+p)}
          {==}

law u32_equal_sound:
  for +a: U32
  for +b: U32
  for e: {U32.is_eq(a, b) == True{} : Bool}
  {a == b : U32}
def u32_equal_sound(a, b, e):
  match a b:
    case U32{aw} U32{bw}:
      %word_compare_sound(32n, aw, bw, e) : {U32{aw} == U32{_} : U32}
      {==}

law and_zero:
  for +n: Nat
  for w: Word(n)
  {Word.and(n, w, Word.zero(n)) == Word.zero(n) : Word(n)}
def and_zero(n, w):
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

law masked_byte_bound:
  for +x: U32
  {U32.is_lt(U32.and(x, 255), 256) == True{} : Bool}
def masked_byte_bound(x):
  match x:
    case U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, hi}}}}}}}}}:
      %Equal.sym(Word(24n), Word.and(24n, hi, Word.zero(24n)), Word.zero(24n), and_zero(24n, hi)) : {U32.is_lt(U32{WCon{Bool.and(b0, True{}), WCon{Bool.and(b1, True{}), WCon{Bool.and(b2, True{}), WCon{Bool.and(b3, True{}), WCon{Bool.and(b4, True{}), WCon{Bool.and(b5, True{}), WCon{Bool.and(b6, True{}), WCon{Bool.and(b7, True{}), _}}}}}}}}}, 256) == True{} : Bool}
      {==}

law shifted_byte_bound:
  for x: U32
  {U32.is_lt(U32.shrn(x, 24n), 256) == True{} : Bool}
def shifted_byte_bound(x):
  match x:
    case U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{b8, WCon{b9, WCon{b10, WCon{b11, WCon{b12, WCon{b13, WCon{b14, WCon{b15, WCon{b16, WCon{b17, WCon{b18, WCon{b19, WCon{b20, WCon{b21, WCon{b22, WCon{b23, WCon{b24, WCon{b25, WCon{b26, WCon{b27, WCon{b28, WCon{b29, WCon{b30, WCon{b31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}

def is_some_value(m: Maybe<&2, T.Value>) -> Bool:
  match m:
    case None{}: False{}
    case Some{v}: True{}

law none_some:
  for +v: T.Value
  for +e: {None{} == Some{v} : Maybe<&2, T.Value>}
  Empty
def none_some(v, e):
  false_true(Equal.cong(Maybe<&2, T.Value>, Bool, is_some_value, None{}, Some{v}, e))

# Reflexivity of the actual Base word comparison. It lives here, next to the
# other comparison reflection lemmas, because the type validator needs only
# this fact: importing it from the decoder module pulled the whole decoder
# (src/decode, src/ssz, decode_top) into the validator proofs and cost the
# checker about 1.5 GB for one lemma.
law word_compare_reflexive:
  for +n: Nat
  for +w: Word(n)
  {Word.cmp(n, w, w) == EQ{} : Cmp}
def word_compare_reflexive(n, w):
  match n:
    case 0n: {==}
    case 1n+p:
      match w:
        case WCon{False{}, t}: Equal.cong(Cmp, Cmp, c => Word.cmp.fin(False{}, False{}, c), Word.cmp(p, t, t), EQ{}, word_compare_reflexive(p, t))
        case WCon{True{}, t}: Equal.cong(Cmp, Cmp, c => Word.cmp.fin(True{}, True{}, c), Word.cmp(p, t, t), EQ{}, word_compare_reflexive(p, t))

law word_equal_reflexive:
  for +w: U32
  {U32.is_eq(w, w) == True{} : Bool}
def word_equal_reflexive(w):
  match w:
    case U32{bits}: Equal.cong(Cmp, Bool, c => Cmp.is_eq(c), Word.cmp(32n, bits, bits), EQ{}, word_compare_reflexive(32n, bits))
