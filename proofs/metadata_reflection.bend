import Base
import ../spec/compatibility.bend as S
import ./word_facts.bend as W
import ./primitive_invariants.bend as V

law comparison_tail:
  for +a: Char
  for +b: Char
  for result: (String & String) & Cmp
  {String.eq.fin(String.cmp.rec(a, b, result)) == String.eq.fin(result) : Bool}
def comparison_tail(a, b, result):
  ((x, y), c) = result
  {==}

law comparison_step:
  for +a: Char
  for +b: Char
  for +x: String
  for +y: String
  for +c: Cmp
  {String.eq.fin(String.cmp.fin(x, y, ((a, b), c))) == Bool.and(Cmp.is_eq(c), String.eq(x, y)) : Bool}
def comparison_step(a, b, x, y, c):
  match c:
    case LT{}: {==}
    case GT{}: {==}
    case EQ{}: comparison_tail(a, b, String.cmp(x, y))

law string_cons:
  for +a: U32
  for +b: U32
  for +x: String
  for +y: String
  {String.eq(SCon{Chr{a}, x}, SCon{Chr{b}, y}) == Bool.and(U32.is_eq(a, b), String.eq(x, y)) : Bool}
def string_cons(a, b, x, y):
  comparison_step(Chr{a}, Chr{b}, x, y, U32.cmp(a, b))

law string_sound:
  for +a: String
  for +b: String
  for +same: {String.eq(a, b) == True{} : Bool}
  {a == b : String}
def string_sound(a, b, same):
  match a b:
    case SNil{} SNil{}: {==}
    case SNil{} SCon{h, t}: Empty.absurd({SNil{} == SCon{h, t} : String}, W.false_true(same))
    case SCon{h, t} SNil{}: Empty.absurd({SCon{h, t} == SNil{} : String}, W.false_true(same))
    case SCon{Chr{x}, xs} SCon{Chr{y}, ys}:
      +both = Equal.trans(Bool, Bool.and(U32.is_eq(x, y), String.eq(xs, ys)), String.eq(SCon{Chr{x}, xs}, SCon{Chr{y}, ys}), True{}, Equal.sym(Bool, String.eq(SCon{Chr{x}, xs}, SCon{Chr{y}, ys}), Bool.and(U32.is_eq(x, y), String.eq(xs, ys)), string_cons(x, y, xs, ys)), same)
      %W.u32_equal_sound(x, y, V.and_left(U32.is_eq(x, y), String.eq(xs, ys), both)) : {SCon{Chr{x}, xs} == SCon{Chr{_}, ys} : String}
      %string_sound(xs, ys, V.and_right(U32.is_eq(x, y), String.eq(xs, ys), both)) : {SCon{Chr{x}, xs} == SCon{Chr{x}, _} : String}
      {==}

law names_sound:
  for +a: +List<String>
  for +b: +List<String>
  for +same: {S.names_equal(a, b) == True{} : Bool}
  {a == b : +List<String>}
def names_sound(a, b, same):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{h, t}: Empty.absurd({[] == h <> t : +List<String>}, W.false_true(same))
    case Con{h, t} Nil{}: Empty.absurd({h <> t == [] : +List<String>}, W.false_true(same))
    case Con{h, t} Con{i, u}:
      %string_sound(h, i, V.and_left(String.eq(h, i), S.names_equal(t, u), same)) : {h <> t == _ <> u : +List<String>}
      %names_sound(t, u, V.and_right(String.eq(h, i), S.names_equal(t, u), same)) : {h <> t == h <> _ : +List<String>}
      {==}

law bit_sound:
  for +a: Bool
  for +b: Bool
  for same: {Bool.not(Bool.xor(a, b)) == True{} : Bool}
  {a == b : Bool}
def bit_sound(a, b, same):
  match a b:
    case False{} False{}: {==}
    case True{} True{}: {==}
    case False{} True{}: Empty.absurd({False{} == True{} : Bool}, W.false_true(same))
    case True{} False{}: Empty.absurd({True{} == False{} : Bool}, W.false_true(same))

law bits_sound:
  for +a: +List<Bool>
  for +b: +List<Bool>
  for +same: {S.bits_equal(a, b) == True{} : Bool}
  {a == b : +List<Bool>}
def bits_sound(a, b, same):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{h, t}: Empty.absurd({[] == h <> t : +List<Bool>}, W.false_true(same))
    case Con{h, t} Nil{}: Empty.absurd({h <> t == [] : +List<Bool>}, W.false_true(same))
    case Con{h, t} Con{i, u}:
      %bit_sound(h, i, V.and_left(Bool.not(Bool.xor(h, i)), S.bits_equal(t, u), same)) : {h <> t == _ <> u : +List<Bool>}
      %bits_sound(t, u, V.and_right(Bool.not(Bool.xor(h, i)), S.bits_equal(t, u), same)) : {h <> t == h <> _ : +List<Bool>}
      {==}

law selectors_sound:
  for +a: +List<U32>
  for +b: +List<U32>
  for +same: {S.selectors_equal(a, b) == True{} : Bool}
  {a == b : +List<U32>}
def selectors_sound(a, b, same):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{h, t}: Empty.absurd({[] == h <> t : +List<U32>}, W.false_true(same))
    case Con{h, t} Nil{}: Empty.absurd({h <> t == [] : +List<U32>}, W.false_true(same))
    case Con{h, t} Con{i, u}:
      %W.u32_equal_sound(h, i, V.and_left(U32.is_eq(h, i), S.selectors_equal(t, u), same)) : {h <> t == _ <> u : +List<U32>}
      %selectors_sound(t, u, V.and_right(U32.is_eq(h, i), S.selectors_equal(t, u), same)) : {h <> t == h <> _ : +List<U32>}
      {==}
