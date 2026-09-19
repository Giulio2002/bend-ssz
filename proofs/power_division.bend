import Base
import ./word_split.bend as B

def bits(x: U32) -> Word(32n):
  U32{w} = x
  w


def embed8(w: Word(8n)) -> U32:
  U32{B.join(8n, 24n, w, Word.zero(24n))}

law step8:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(8n)
  {U32.divmod.go.rec(m, b, 256, (q, embed8(r))) ==
    (WCon{B.last(8n, r), q}, embed8(B.roll(8n, b, r))) : Word(1n+m) & U32}
def step8(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{True{}, WNil{}}}}}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 256), True{}, B.compare_zero(8n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WNil{}}}}}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 256, _) ==
          (WCon{True{}, q}, embed8(WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WNil{}}}}}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(8n, 24n, Word.zero(8n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}})),
        B.join(8n, 24n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WNil{}}}}}}}}}, Word.zero(24n)),
        B.subtract_prefix(8n, 24n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WNil{}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}))

law divmod8:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 256) == (B.quotient(8n, m, w), embed8(B.take(8n, m, w))) : Word(m) & U32}
def divmod8(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(8n, p, b, t) :
            {U32.divmod.go.rec(p, b, 256, U32.divmod.go(p, t, 256)) ==
              (WCon{B.last(8n, B.take(8n, p, t)), B.quotient(8n, p, t)}, embed8(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 256),
            (B.quotient(8n, p, t), embed8(B.take(8n, p, t))), divmod8(p, t)) :
            {U32.divmod.go.rec(p, b, 256, _) ==
              (WCon{B.last(8n, B.take(8n, p, t)), B.quotient(8n, p, t)}, embed8(B.roll(8n, b, B.take(8n, p, t)))) : Word(1n+p) & U32}
          step8(p, B.quotient(8n, p, t), b, B.take(8n, p, t))


law quotient_shift8:
  for +w: Word(32n)
  {U32{B.quotient(8n, 32n, w)} == U32.shrn(U32{w}, 8n) : U32}
def quotient_shift8(w):
  match w:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{x23, WCon{x24, WCon{x25, WCon{x26, WCon{x27, WCon{x28, WCon{x29, WCon{x30, WCon{x31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift8:
  for +x: U32
  {U32.div(x, 256) == U32.shrn(x, 8n) : U32}
def div_shift8(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 256), U32{B.quotient(8n, 32n, w)}, U32.shrn(U32{w}, 8n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 256),
          (B.quotient(8n, 32n, w), embed8(B.take(8n, 32n, w))), divmod8(32n, w)),
        quotient_shift8(w))

law remainder8:
  for +x: U32
  {U32.mod(x, 256) == embed8(B.take(8n, 32n, bits(x))) : U32}
def remainder8(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.mod.fin(qr), U32.divmod.go(32n, w, 256),
        (B.quotient(8n, 32n, w), embed8(B.take(8n, 32n, w))), divmod8(32n, w))


def embed16(w: Word(16n)) -> U32:
  U32{B.join(16n, 16n, w, Word.zero(16n))}

law step16:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(16n)
  {U32.divmod.go.rec(m, b, 65536, (q, embed16(r))) ==
    (WCon{B.last(16n, r), q}, embed16(B.roll(16n, b, r))) : Word(1n+m) & U32}
def step16(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 65536), True{}, B.compare_zero(16n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WNil{}}}}}}}}}}}}}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 65536, _) ==
          (WCon{True{}, q}, embed16(WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WNil{}}}}}}}}}}}}}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(16n, 16n, Word.zero(16n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}})),
        B.join(16n, 16n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WNil{}}}}}}}}}}}}}}}}}, Word.zero(16n)),
        B.subtract_prefix(16n, 16n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WNil{}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}))

law divmod16:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 65536) == (B.quotient(16n, m, w), embed16(B.take(16n, m, w))) : Word(m) & U32}
def divmod16(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(16n, p, b, t) :
            {U32.divmod.go.rec(p, b, 65536, U32.divmod.go(p, t, 65536)) ==
              (WCon{B.last(16n, B.take(16n, p, t)), B.quotient(16n, p, t)}, embed16(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 65536),
            (B.quotient(16n, p, t), embed16(B.take(16n, p, t))), divmod16(p, t)) :
            {U32.divmod.go.rec(p, b, 65536, _) ==
              (WCon{B.last(16n, B.take(16n, p, t)), B.quotient(16n, p, t)}, embed16(B.roll(16n, b, B.take(16n, p, t)))) : Word(1n+p) & U32}
          step16(p, B.quotient(16n, p, t), b, B.take(16n, p, t))


law quotient_shift16:
  for +w: Word(32n)
  {U32{B.quotient(16n, 32n, w)} == U32.shrn(U32{w}, 16n) : U32}
def quotient_shift16(w):
  match w:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{x23, WCon{x24, WCon{x25, WCon{x26, WCon{x27, WCon{x28, WCon{x29, WCon{x30, WCon{x31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift16:
  for +x: U32
  {U32.div(x, 65536) == U32.shrn(x, 16n) : U32}
def div_shift16(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 65536), U32{B.quotient(16n, 32n, w)}, U32.shrn(U32{w}, 16n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 65536),
          (B.quotient(16n, 32n, w), embed16(B.take(16n, 32n, w))), divmod16(32n, w)),
        quotient_shift16(w))

law remainder16:
  for +x: U32
  {U32.mod(x, 65536) == embed16(B.take(16n, 32n, bits(x))) : U32}
def remainder16(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.mod.fin(qr), U32.divmod.go(32n, w, 65536),
        (B.quotient(16n, 32n, w), embed16(B.take(16n, 32n, w))), divmod16(32n, w))


def embed24(w: Word(24n)) -> U32:
  U32{B.join(24n, 8n, w, Word.zero(8n))}

law step24:
  for +m: Nat
  for +q: Word(m)
  for +b: Bool
  for +r: Word(24n)
  {U32.divmod.go.rec(m, b, 16777216, (q, embed24(r))) ==
    (WCon{B.last(24n, r), q}, embed24(B.roll(24n, b, r))) : Word(1n+m) & U32}
def step24(m, q, b, r):
  match r:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}: {==}
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}:
      %Equal.sym(Bool, U32.is_ge(U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16777216), True{}, B.compare_zero(24n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WNil{}}}}}}}}}}}}}}}}}}}}}}}}})) :
        {U32.divmod.go.fin(m, q, U32{WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, 16777216, _) ==
          (WCon{True{}, q}, embed24(WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WNil{}}}}}}}}}}}}}}}}}}}}}}}}})) : Word(1n+m) & U32}
      Equal.cong(Word(32n), Word(1n+m) & U32, w => (WCon{True{}, q}, U32{w}),
        Word.sub(32n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, B.join(24n, 8n, Word.zero(24n), WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}})),
        B.join(24n, 8n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}, Word.zero(8n)),
        B.subtract_prefix(24n, 8n, WCon{b, WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}))

law divmod24:
  for +m: Nat
  for +w: Word(m)
  {U32.divmod.go(m, w, 16777216) == (B.quotient(24n, m, w), embed24(B.take(24n, m, w))) : Word(m) & U32}
def divmod24(m, w):
  match m:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %B.take_roll(24n, p, b, t) :
            {U32.divmod.go.rec(p, b, 16777216, U32.divmod.go(p, t, 16777216)) ==
              (WCon{B.last(24n, B.take(24n, p, t)), B.quotient(24n, p, t)}, embed24(_)) : Word(1n+p) & U32}
          %Equal.sym(Word(p) & U32, U32.divmod.go(p, t, 16777216),
            (B.quotient(24n, p, t), embed24(B.take(24n, p, t))), divmod24(p, t)) :
            {U32.divmod.go.rec(p, b, 16777216, _) ==
              (WCon{B.last(24n, B.take(24n, p, t)), B.quotient(24n, p, t)}, embed24(B.roll(24n, b, B.take(24n, p, t)))) : Word(1n+p) & U32}
          step24(p, B.quotient(24n, p, t), b, B.take(24n, p, t))


law quotient_shift24:
  for +w: Word(32n)
  {U32{B.quotient(24n, 32n, w)} == U32.shrn(U32{w}, 24n) : U32}
def quotient_shift24(w):
  match w:
    case WCon{x0, WCon{x1, WCon{x2, WCon{x3, WCon{x4, WCon{x5, WCon{x6, WCon{x7, WCon{x8, WCon{x9, WCon{x10, WCon{x11, WCon{x12, WCon{x13, WCon{x14, WCon{x15, WCon{x16, WCon{x17, WCon{x18, WCon{x19, WCon{x20, WCon{x21, WCon{x22, WCon{x23, WCon{x24, WCon{x25, WCon{x26, WCon{x27, WCon{x28, WCon{x29, WCon{x30, WCon{x31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law div_shift24:
  for +x: U32
  {U32.div(x, 16777216) == U32.shrn(x, 24n) : U32}
def div_shift24(x):
  match x:
    case U32{w}:
      Equal.trans(U32, U32.div(U32{w}, 16777216), U32{B.quotient(24n, 32n, w)}, U32.shrn(U32{w}, 24n),
        Equal.cong(Word(32n) & U32, U32, qr => U32.div.fin(qr), U32.divmod.go(32n, w, 16777216),
          (B.quotient(24n, 32n, w), embed24(B.take(24n, 32n, w))), divmod24(32n, w)),
        quotient_shift24(w))

law remainder24:
  for +x: U32
  {U32.mod(x, 16777216) == embed24(B.take(24n, 32n, bits(x))) : U32}
def remainder24(x):
  match x:
    case U32{w}:
      Equal.cong(Word(32n) & U32, U32, qr => U32.mod.fin(qr), U32.divmod.go(32n, w, 16777216),
        (B.quotient(24n, 32n, w), embed24(B.take(24n, 32n, w))), divmod24(32n, w))
