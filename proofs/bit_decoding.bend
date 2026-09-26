import Base
import ../src/bit_decoding.bend as I
import ../spec/bit_decoding.bend as S
import ./power_division.bend as D
import ./word_split.bend as B

# Symbolic proof: division by 2^k is a right shift and the remainder mod 2 is
# the low bit, so both octet definitions read the same bits (no case split).

def embed1(w: Word(1n)) -> U32:
  U32{B.join(1n, 31n, w, Word.zero(31n))}

law and_low:
  for +x: U32
  {U32.and(x, 1) == embed1(B.take(1n, 32n, D.bits(x))) : U32}
def and_low(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n), U32, v => U32{v},
        Word.and(32n, w, B.join(1n, 31n, B.ones(1n), Word.zero(31n))),
        B.join(1n, 31n, B.take(1n, 32n, w), Word.zero(31n)),
        B.mask_take(1n, 31n, w))

law step_one:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  {U32.divmod.go.rec(m, b, 1, (q, 0)) == (WCon{b, q}, 0) : Word(1n+m) & U32}
def step_one(m, q, b):
  match b:
    case False{}: {==}
    case True{}: {==}

law divmod_one:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 1) == (w, 0) : Word(m) & U32}
def divmod_one(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 1), (t, 0), divmod_one(p, t)) :
            {U32.divmod.go.rec(p, b, 1, _) == (WCon{b, t}, 0) : Word(1n+p) & U32}
          step_one(p, t, b)

law div_one:
  for +x: U32
  {U32.div(x, 1) == x : U32}
def div_one(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 1), (w, 0), divmod_one(32n, w))

law step1:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(1n)
  {U32.divmod.go.rec(m, b, 2, (q, embed1(r))) ==
    (WCon{B.last(1n, r), q}, embed1(B.roll(1n, b, r))) : Word(1n+m) & U32}
def step1(m, q, b, r):
  match r:
    case WCon{False{}, WNil{}}: {==}
    case WCon{True{}, WNil{}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 2), True{}, B.compare_zero(1n, WCon{b, WNil{}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 2, _) ==
          (WCon{True{}, q}, embed1(WCon{b, WNil{}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(1n, 31n, Word.zero(1n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(1n, 31n, WCon{b, WNil{}}, Word.zero(31n)),
        B.subtract_prefix(1n, 31n, WCon{b, WNil{}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod1:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 2) == (B.quotient(1n, m, w), embed1(B.take(1n, m, w))) : Word(m) & U32}
def divmod1(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(1n, p, b, t) :
            {U32.divmod.go.rec(p, b, 2, U32.divmod.go(p, t, 2)) ==
              (WCon{B.last(1n, B.take(1n, p, t)), B.quotient(1n, p, t)}, embed1(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 2),
            (B.quotient(1n, p, t), embed1(B.take(1n, p, t))), divmod1(p, t)) :
            {U32.divmod.go.rec(p, b, 2, _) ==
              (WCon{B.last(1n, B.take(1n, p, t)), B.quotient(1n, p, t)}, embed1(B.roll(1n, b, B.take(1n, p, t)))) : Word(1n+p) & U32}
          step1(p, B.quotient(1n, p, t), b, B.take(1n, p, t))

law remainder1:
  for +x: U32
  {U32.mod(x, 2) == embed1(B.take(1n, 32n, D.bits(x))) : U32}
def remainder1(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.mod.fin(qr), U32.divmod.go(32n, w, 2),
        (B.quotient(1n, 32n, w), embed1(B.take(1n, 32n, w))), divmod1(32n, w))

law quotient_shift1:
  for +w: Word(32n)
  {U32{B.quotient(1n, 32n, w)} == U32.shrn(U32{w}, 1n) : U32}
def quotient_shift1(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift1:
  for +x: U32
  {U32.div(x, 2) == U32.shrn(x, 1n) : U32}
def div_shift1(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 2), U32{B.quotient(1n, 32n, w)}, U32.shrn(U32{w}, 1n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 2),
          (B.quotient(1n, 32n, w), embed1(B.take(1n, 32n, w))), divmod1(32n, w)),
        quotient_shift1(w))

def embed2(w: Word(2n)) -> U32:
  U32{B.join(2n, 30n, w, Word.zero(30n))}

law step2:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(2n)
  {U32.divmod.go.rec(m, b, 4, (q, embed2(r))) ==
    (WCon{B.last(2n, r), q}, embed2(B.roll(2n, b, r))) : Word(1n+m) & U32}
def step2(m, q, b, r):
  match r:
    case WCon{x0, WCon{False{}, WNil{}}}: {==}
    case WCon{x0, WCon{True{}, WNil{}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 4), True{}, B.compare_zero(2n, WCon{b, WCon{x0, WNil{}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 4, _) ==
          (WCon{True{}, q}, embed2(WCon{b, WCon{x0, WNil{}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(2n, 30n, Word.zero(2n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(2n, 30n, WCon{b, WCon{x0, WNil{}}}, Word.zero(30n)),
        B.subtract_prefix(2n, 30n, WCon{b, WCon{x0, WNil{}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod2:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 4) == (B.quotient(2n, m, w), embed2(B.take(2n, m, w))) : Word(m) & U32}
def divmod2(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(2n, p, b, t) :
            {U32.divmod.go.rec(p, b, 4, U32.divmod.go(p, t, 4)) ==
              (WCon{B.last(2n, B.take(2n, p, t)), B.quotient(2n, p, t)}, embed2(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 4),
            (B.quotient(2n, p, t), embed2(B.take(2n, p, t))), divmod2(p, t)) :
            {U32.divmod.go.rec(p, b, 4, _) ==
              (WCon{B.last(2n, B.take(2n, p, t)), B.quotient(2n, p, t)}, embed2(B.roll(2n, b, B.take(2n, p, t)))) : Word(1n+p) & U32}
          step2(p, B.quotient(2n, p, t), b, B.take(2n, p, t))

law quotient_shift2:
  for +w: Word(32n)
  {U32{B.quotient(2n, 32n, w)} == U32.shrn(U32{w}, 2n) : U32}
def quotient_shift2(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift2:
  for +x: U32
  {U32.div(x, 4) == U32.shrn(x, 2n) : U32}
def div_shift2(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 4), U32{B.quotient(2n, 32n, w)}, U32.shrn(U32{w}, 2n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 4),
          (B.quotient(2n, 32n, w), embed2(B.take(2n, 32n, w))), divmod2(32n, w)),
        quotient_shift2(w))

def embed3(w: Word(3n)) -> U32:
  U32{B.join(3n, 29n, w, Word.zero(29n))}

law step3:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(3n)
  {U32.divmod.go.rec(m, b, 8, (q, embed3(r))) ==
    (WCon{B.last(3n, r), q}, embed3(B.roll(3n, b, r))) : Word(1n+m) & U32}
def step3(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{False{}, WNil{}}}}: {==}
    case WCon{x0, WCon{x1, WCon{True{}, WNil{}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8), True{}, B.compare_zero(3n, WCon{b, WCon{x0, WCon{x1, WNil{}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 8, _) ==
          (WCon{True{}, q}, embed3(WCon{b, WCon{x0, WCon{x1, WNil{}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(3n, 29n, Word.zero(3n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(3n, 29n, WCon{b, WCon{x0, WCon{x1, WNil{}}}}, Word.zero(29n)),
        B.subtract_prefix(3n, 29n, WCon{b, WCon{x0, WCon{x1, WNil{}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod3:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 8) == (B.quotient(3n, m, w), embed3(B.take(3n, m, w))) : Word(m) & U32}
def divmod3(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(3n, p, b, t) :
            {U32.divmod.go.rec(p, b, 8, U32.divmod.go(p, t, 8)) ==
              (WCon{B.last(3n, B.take(3n, p, t)), B.quotient(3n, p, t)}, embed3(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 8),
            (B.quotient(3n, p, t), embed3(B.take(3n, p, t))), divmod3(p, t)) :
            {U32.divmod.go.rec(p, b, 8, _) ==
              (WCon{B.last(3n, B.take(3n, p, t)), B.quotient(3n, p, t)}, embed3(B.roll(3n, b, B.take(3n, p, t)))) : Word(1n+p) & U32}
          step3(p, B.quotient(3n, p, t), b, B.take(3n, p, t))

law quotient_shift3:
  for +w: Word(32n)
  {U32{B.quotient(3n, 32n, w)} == U32.shrn(U32{w}, 3n) : U32}
def quotient_shift3(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift3:
  for +x: U32
  {U32.div(x, 8) == U32.shrn(x, 3n) : U32}
def div_shift3(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 8), U32{B.quotient(3n, 32n, w)}, U32.shrn(U32{w}, 3n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 8),
          (B.quotient(3n, 32n, w), embed3(B.take(3n, 32n, w))), divmod3(32n, w)),
        quotient_shift3(w))

def embed4(w: Word(4n)) -> U32:
  U32{B.join(4n, 28n, w, Word.zero(28n))}

law step4:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(4n)
  {U32.divmod.go.rec(m, b, 16, (q, embed4(r))) ==
    (WCon{B.last(4n, r), q}, embed4(B.roll(4n, b, r))) : Word(1n+m) & U32}
def step4(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{False{}, WNil{}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{True{}, WNil{}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16), True{}, B.compare_zero(4n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WNil{}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16, _) ==
          (WCon{True{}, q}, embed4(WCon{b, WCon{x0, WCon{x1, WCon{x2, WNil{}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(4n, 28n, Word.zero(4n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(4n, 28n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WNil{}}}}}, Word.zero(28n)),
        B.subtract_prefix(4n, 28n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WNil{}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod4:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 16) == (B.quotient(4n, m, w), embed4(B.take(4n, m, w))) : Word(m) & U32}
def divmod4(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(4n, p, b, t) :
            {U32.divmod.go.rec(p, b, 16, U32.divmod.go(p, t, 16)) ==
              (WCon{B.last(4n, B.take(4n, p, t)), B.quotient(4n, p, t)}, embed4(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 16),
            (B.quotient(4n, p, t), embed4(B.take(4n, p, t))), divmod4(p, t)) :
            {U32.divmod.go.rec(p, b, 16, _) ==
              (WCon{B.last(4n, B.take(4n, p, t)), B.quotient(4n, p, t)}, embed4(B.roll(4n, b, B.take(4n, p, t)))) : Word(1n+p) & U32}
          step4(p, B.quotient(4n, p, t), b, B.take(4n, p, t))

law quotient_shift4:
  for +w: Word(32n)
  {U32{B.quotient(4n, 32n, w)} == U32.shrn(U32{w}, 4n) : U32}
def quotient_shift4(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift4:
  for +x: U32
  {U32.div(x, 16) == U32.shrn(x, 4n) : U32}
def div_shift4(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 16), U32{B.quotient(4n, 32n, w)}, U32.shrn(U32{w}, 4n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 16),
          (B.quotient(4n, 32n, w), embed4(B.take(4n, 32n, w))), divmod4(32n, w)),
        quotient_shift4(w))

def embed5(w: Word(5n)) -> U32:
  U32{B.join(5n, 27n, w, Word.zero(27n))}

law step5:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(5n)
  {U32.divmod.go.rec(m, b, 32, (q, embed5(r))) ==
    (WCon{B.last(5n, r), q}, embed5(B.roll(5n, b, r))) : Word(1n+m) & U32}
def step5(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{False{}, WNil{}}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{True{}, WNil{}}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 32), True{}, B.compare_zero(5n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WNil{}}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 32, _) ==
          (WCon{True{}, q}, embed5(WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WNil{}}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(5n, 27n, Word.zero(5n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(5n, 27n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WNil{}}}}}}, Word.zero(27n)),
        B.subtract_prefix(5n, 27n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WNil{}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod5:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 32) == (B.quotient(5n, m, w), embed5(B.take(5n, m, w))) : Word(m) & U32}
def divmod5(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(5n, p, b, t) :
            {U32.divmod.go.rec(p, b, 32, U32.divmod.go(p, t, 32)) ==
              (WCon{B.last(5n, B.take(5n, p, t)), B.quotient(5n, p, t)}, embed5(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 32),
            (B.quotient(5n, p, t), embed5(B.take(5n, p, t))), divmod5(p, t)) :
            {U32.divmod.go.rec(p, b, 32, _) ==
              (WCon{B.last(5n, B.take(5n, p, t)), B.quotient(5n, p, t)}, embed5(B.roll(5n, b, B.take(5n, p, t)))) : Word(1n+p) & U32}
          step5(p, B.quotient(5n, p, t), b, B.take(5n, p, t))

law quotient_shift5:
  for +w: Word(32n)
  {U32{B.quotient(5n, 32n, w)} == U32.shrn(U32{w}, 5n) : U32}
def quotient_shift5(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift5:
  for +x: U32
  {U32.div(x, 32) == U32.shrn(x, 5n) : U32}
def div_shift5(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 32), U32{B.quotient(5n, 32n, w)}, U32.shrn(U32{w}, 5n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 32),
          (B.quotient(5n, 32n, w), embed5(B.take(5n, 32n, w))), divmod5(32n, w)),
        quotient_shift5(w))

def embed6(w: Word(6n)) -> U32:
  U32{B.join(6n, 26n, w, Word.zero(26n))}

law step6:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(6n)
  {U32.divmod.go.rec(m, b, 64, (q, embed6(r))) ==
    (WCon{B.last(6n, r), q}, embed6(B.roll(6n, b, r))) : Word(1n+m) & U32}
def step6(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{False{}, WNil{}}}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{True{}, WNil{}}}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 64), True{}, B.compare_zero(6n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WNil{}}}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 64, _) ==
          (WCon{True{}, q}, embed6(WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WNil{}}}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(6n, 26n, Word.zero(6n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(6n, 26n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WNil{}}}}}}}, Word.zero(26n)),
        B.subtract_prefix(6n, 26n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WNil{}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod6:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 64) == (B.quotient(6n, m, w), embed6(B.take(6n, m, w))) : Word(m) & U32}
def divmod6(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(6n, p, b, t) :
            {U32.divmod.go.rec(p, b, 64, U32.divmod.go(p, t, 64)) ==
              (WCon{B.last(6n, B.take(6n, p, t)), B.quotient(6n, p, t)}, embed6(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 64),
            (B.quotient(6n, p, t), embed6(B.take(6n, p, t))), divmod6(p, t)) :
            {U32.divmod.go.rec(p, b, 64, _) ==
              (WCon{B.last(6n, B.take(6n, p, t)), B.quotient(6n, p, t)}, embed6(B.roll(6n, b, B.take(6n, p, t)))) : Word(1n+p) & U32}
          step6(p, B.quotient(6n, p, t), b, B.take(6n, p, t))

law quotient_shift6:
  for +w: Word(32n)
  {U32{B.quotient(6n, 32n, w)} == U32.shrn(U32{w}, 6n) : U32}
def quotient_shift6(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift6:
  for +x: U32
  {U32.div(x, 64) == U32.shrn(x, 6n) : U32}
def div_shift6(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 64), U32{B.quotient(6n, 32n, w)}, U32.shrn(U32{w}, 6n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 64),
          (B.quotient(6n, 32n, w), embed6(B.take(6n, 32n, w))), divmod6(32n, w)),
        quotient_shift6(w))

def embed7(w: Word(7n)) -> U32:
  U32{B.join(7n, 25n, w, Word.zero(25n))}

law step7:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(7n)
  {U32.divmod.go.rec(m, b, 128, (q, embed7(r))) ==
    (WCon{B.last(7n, r), q}, embed7(B.roll(7n, b, r))) : Word(1n+m) & U32}
def step7(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{False{}, WNil{}}}}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{True{}, WNil{}}}}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 128), True{}, B.compare_zero(7n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WNil{}}}}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 128, _) ==
          (WCon{True{}, q}, embed7(WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WNil{}}}}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(7n, 25n, Word.zero(7n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(7n, 25n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WNil{}}}}}}}}, Word.zero(25n)),
        B.subtract_prefix(7n, 25n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WNil{}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod7:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 128) == (B.quotient(7n, m, w), embed7(B.take(7n, m, w))) : Word(m) & U32}
def divmod7(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(7n, p, b, t) :
            {U32.divmod.go.rec(p, b, 128, U32.divmod.go(p, t, 128)) ==
              (WCon{B.last(7n, B.take(7n, p, t)), B.quotient(7n, p, t)}, embed7(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 128),
            (B.quotient(7n, p, t), embed7(B.take(7n, p, t))), divmod7(p, t)) :
            {U32.divmod.go.rec(p, b, 128, _) ==
              (WCon{B.last(7n, B.take(7n, p, t)), B.quotient(7n, p, t)}, embed7(B.roll(7n, b, B.take(7n, p, t)))) : Word(1n+p) & U32}
          step7(p, B.quotient(7n, p, t), b, B.take(7n, p, t))

law quotient_shift7:
  for +w: Word(32n)
  {U32{B.quotient(7n, 32n, w)} == U32.shrn(U32{w}, 7n) : U32}
def quotient_shift7(w):
  match w:
    case WCon{y0, WCon{y1, WCon{y2, WCon{y3, WCon{y4, WCon{y5, WCon{y6, WCon{y7, WCon{y8, WCon{y9, WCon{y10, WCon{y11, WCon{y12, WCon{y13, WCon{y14, WCon{y15, WCon{y16, WCon{y17, WCon{y18, WCon{y19, WCon{y20, WCon{y21, WCon{y22, WCon{y23, WCon{y24, WCon{y25, WCon{y26, WCon{y27, WCon{y28, WCon{y29, WCon{y30, WCon{y31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift7:
  for +x: U32
  {U32.div(x, 128) == U32.shrn(x, 7n) : U32}
def div_shift7(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 128), U32{B.quotient(7n, 32n, w)}, U32.shrn(U32{w}, 7n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 128),
          (B.quotient(7n, 32n, w), embed7(B.take(7n, 32n, w))), divmod7(32n, w)),
        quotient_shift7(w))

law bit0:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 1), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1) : Bool}
def bit0(x):
  %Equal.sym(U32, U32.div(x, 1), x, div_one(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 0n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 0n)))), remainder1(U32.shrn(x, 0n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 0n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 0n)))), and_low(U32.shrn(x, 0n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 0n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit1:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 2), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1) : Bool}
def bit1(x):
  %Equal.sym(U32, U32.div(x, 2), U32.shrn(x, 1n), div_shift1(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 1n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 1n)))), remainder1(U32.shrn(x, 1n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 1n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 1n)))), and_low(U32.shrn(x, 1n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 1n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit2:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 4), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1) : Bool}
def bit2(x):
  %Equal.sym(U32, U32.div(x, 4), U32.shrn(x, 2n), div_shift2(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 2n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 2n)))), remainder1(U32.shrn(x, 2n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 2n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 2n)))), and_low(U32.shrn(x, 2n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 2n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit3:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 8), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1) : Bool}
def bit3(x):
  %Equal.sym(U32, U32.div(x, 8), U32.shrn(x, 3n), div_shift3(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 3n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 3n)))), remainder1(U32.shrn(x, 3n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 3n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 3n)))), and_low(U32.shrn(x, 3n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 3n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit4:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 16), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1) : Bool}
def bit4(x):
  %Equal.sym(U32, U32.div(x, 16), U32.shrn(x, 4n), div_shift4(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 4n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 4n)))), remainder1(U32.shrn(x, 4n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 4n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 4n)))), and_low(U32.shrn(x, 4n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 4n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit5:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 32), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1) : Bool}
def bit5(x):
  %Equal.sym(U32, U32.div(x, 32), U32.shrn(x, 5n), div_shift5(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 5n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 5n)))), remainder1(U32.shrn(x, 5n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 5n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 5n)))), and_low(U32.shrn(x, 5n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 5n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit6:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 64), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1) : Bool}
def bit6(x):
  %Equal.sym(U32, U32.div(x, 64), U32.shrn(x, 6n), div_shift6(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 6n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 6n)))), remainder1(U32.shrn(x, 6n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 6n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 6n)))), and_low(U32.shrn(x, 6n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 6n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law bit7:
  for +x: U32
  {U32.is_eq(U32.mod(U32.div(x, 128), 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1) : Bool}
def bit7(x):
  %Equal.sym(U32, U32.div(x, 128), U32.shrn(x, 7n), div_shift7(x)) :
    {U32.is_eq(U32.mod(_, 2), 1) == U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1) : Bool}
  %Equal.sym(U32, U32.mod(U32.shrn(x, 7n), 2), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 7n)))), remainder1(U32.shrn(x, 7n))) :
    {U32.is_eq(_, 1) == U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1) : Bool}
  %Equal.sym(U32, U32.and(U32.shrn(x, 7n), 1), embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 7n)))), and_low(U32.shrn(x, 7n))) :
    {U32.is_eq(embed1(B.take(1n, 32n, D.bits(U32.shrn(x, 7n)))), 1) == U32.is_eq(_, 1) : Bool}
  {==}

law octet_all:
  for +x: U32
  {I.octet(x) == S.octet(x) : +List<Bool>}
def octet_all(x):
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 1), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), bit0(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [_, U32.is_eq(U32.mod(U32.div(x, 2), 2), 1), U32.is_eq(U32.mod(U32.div(x, 4), 2), 1), U32.is_eq(U32.mod(U32.div(x, 8), 2), 1), U32.is_eq(U32.mod(U32.div(x, 16), 2), 1), U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 2), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), bit1(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), _, U32.is_eq(U32.mod(U32.div(x, 4), 2), 1), U32.is_eq(U32.mod(U32.div(x, 8), 2), 1), U32.is_eq(U32.mod(U32.div(x, 16), 2), 1), U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 4), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), bit2(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), _, U32.is_eq(U32.mod(U32.div(x, 8), 2), 1), U32.is_eq(U32.mod(U32.div(x, 16), 2), 1), U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 8), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), bit3(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), _, U32.is_eq(U32.mod(U32.div(x, 16), 2), 1), U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 16), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), bit4(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), _, U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), bit5(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), _, U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), bit6(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), _, U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)] : +List<Bool>}
  %Equal.sym(Bool, U32.is_eq(U32.mod(U32.div(x, 128), 2), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1), bit7(x)) :
    {[U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)] == [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), _] : +List<Bool>}
  {==}

law embedded_correct:
  for +w: Word(8n)
  {I.octet(D.embed8(w)) == S.octet(D.embed8(w)) : +List<Bool>}
def embedded_correct(w):
  octet_all(D.embed8(w))

law octet_correct:
  for +x: U32
  for e: {U32.is_lt(x, 256) == True{} : Bool}
  {I.octet(x) == S.octet(x) : +List<Bool>}
def octet_correct(x, e):
  octet_all(x)
