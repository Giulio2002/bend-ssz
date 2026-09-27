import Base
import ../../spec/nat_bytes.bend as N
import ../compact/found.bend as F
import ../../proofs/nat_order.bend as Order

# The spec's 4-byte size bound N.fits(4n, x) for every x <= 2^a with a < 32,
# proved symbolically in a (no closed power of two is ever evaluated): each
# base-256 quotient step takes x <= 2^(8+b) to x / 256 <= 2^b.

def pv(qr: Nat & Nat) -> Nat:
  (q, r) = qr
  Nat.add(r, Nat.mul(q, 256n))

def dreset(+p: Nat, +d: Nat, +r: Nat, +equal: {r == 255n : Nat},
    +recur: {pv(Nat.divmod.go(p, r, 1n+d, 0n)) == Nat.add(p, Nat.mul(1n+d, 256n)) : Nat})
    -> {pv(Nat.divmod.go(p, r, 1n+d, 0n)) == 1n+Nat.add(p, Nat.add(r, Nat.mul(d, 256n))) : Nat}:
  %Equal.sym(Nat, r, 255n, equal) : {pv(Nat.divmod.go(p, r, 1n+d, 0n)) == 1n+Nat.add(p, Nat.add(_, Nat.mul(d, 256n))) : Nat}
  %F.nat__add_succ(p, Nat.add(255n, Nat.mul(d, 256n))) : {pv(Nat.divmod.go(p, r, 1n+d, 0n)) == _ : Nat}
  recur

law dvalue:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for +sum: {Nat.add(m, r) == 255n : Nat}
  {pv(Nat.divmod.go(n, m, d, r)) == Nat.add(n, Nat.add(r, Nat.mul(d, 256n))) : Nat}
def dvalue(n, m, d, r, sum):
  match n:
    case 0n: {==}
    case 1n+p:
      match m:
        case 0n:
          dreset(p, d, r, sum, dvalue(p, r, 1n+d, 0n, Equal.trans(Nat, Nat.add(r, 0n), r, 255n, F.nat__add_zero(r), sum)))
        case 1n+q:
          %F.nat__add_succ(p, Nat.add(r, Nat.mul(d, 256n))) : {pv(Nat.divmod.go(p, q, d, 1n+r)) == _ : Nat}
          dvalue(p, q, d, 1n+r, Equal.trans(Nat, Nat.add(q, 1n+r), 1n+Nat.add(q, r), 255n, F.nat__add_succ(q, r), sum))

def pproj(qr: Nat & Nat) -> {pv(qr) == Nat.add(Nat.mod.fin(qr), Nat.mul(Nat.div.fin(qr), 256n)) : Nat}:
  (q, r) = qr
  {==}

# x = x mod 256 + 256 (x / 256).
def recompose(+n: Nat) -> {Nat.add(Nat.mod(n, 256n), Nat.mul(Nat.div(n, 256n), 256n)) == n : Nat}:
  %pproj(Nat.divmod(n, 256n)) : {_ == n : Nat}
  Equal.trans(Nat, pv(Nat.divmod(n, 256n)), Nat.add(n, 0n), n, dvalue(n, 255n, 0n, 0n, {==}), F.nat__add_zero(n))

law mul_mono:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.mul(a, c), Nat.mul(b, c)) == True{} : Bool}
def mul_mono(a, b, c, h):
  match a b:
    case 0n _: F.nat__zero_le(Nat.mul(b, c))
    case 1n+p 0n: Empty.absurd({Nat.is_le(Nat.mul(1n+p, c), Nat.mul(0n, c)) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: F.nat__le_add_left(Nat.mul(p, c), Nat.mul(q, c), c, mul_mono(p, q, c, h))

def no_wrap(+a: Nat, +h: {Nat.is_le(Nat.add(256n, a), Nat.add(a, 255n)) == True{} : Bool}) -> Empty:
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(256n, a), z) == True{} : Bool}, Nat.add(a, 255n), Nat.add(255n, a), F.nat__add_comm(a, 255n), h)
  F.logic__true_false(Equal.trans(Bool, True{}, Nat.is_lt(a, a), False{}, Equal.sym(Bool, Nat.is_lt(a, a), True{}, F.nat__succ_le_lt(a, a, h2)), F.nat__lt_irrefl(a)))

def dle_go(+x: Nat, +y: Nat, +h: {Nat.is_le(x, Nat.add(Nat.mul(y, 256n), 255n)) == True{} : Bool}, +b: Bool,
    +eb: {Nat.is_le(Nat.div(x, 256n), y) == b : Bool}) -> {Nat.is_le(Nat.div(x, 256n), y) == True{} : Bool}:
  match b:
    case True{}: eb
    case False{}:
      +q = Nat.div(x, 256n)
      +le1 = F.nat__lt_succ_le_succ(y, q, F.nat__not_le_lt(q, y, eb))
      +mm = mul_mono(1n+y, q, 256n, le1)
      +le2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(q, 256n), z) == True{} : Bool}, Nat.add(Nat.mod(x, 256n), Nat.mul(q, 256n)), x, recompose(x),
        Order.left_below_sum(Nat.mod(x, 256n), Nat.mul(q, 256n)))
      Empty.absurd({Nat.is_le(Nat.div(x, 256n), y) == True{} : Bool},
        no_wrap(Nat.mul(y, 256n), F.nat__le_trans(Nat.add(256n, Nat.mul(y, 256n)), x, Nat.add(Nat.mul(y, 256n), 255n),
          F.nat__le_trans(Nat.mul(1n+y, 256n), Nat.mul(q, 256n), x, mm, le2), h)))

# x <= 256 y + 255 gives x / 256 <= y.
def dle(+x: Nat, +y: Nat, +h: {Nat.is_le(x, Nat.add(Nat.mul(y, 256n), 255n)) == True{} : Bool})
    -> {Nat.is_le(Nat.div(x, 256n), y) == True{} : Bool}:
  dle_go(x, y, h, Nat.is_le(Nat.div(x, 256n), y), {==})

def D8(+y: Nat) -> Nat: Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(y))))))))

law m256:
  for +y: Nat
  {Nat.mul(y, 256n) == D8(y) : Nat}
def m256(y):
  match y:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.mul(p, 256n), D8(p), m256(p)) : {Nat.add(256n, _) == D8(1n+p) : Nat}
      {==}

# x <= 2^(8+b) gives x / 256 <= 2^b.
def step(+x: Nat, +b: Nat, +h: {Nat.is_le(x, F.spec_common__pow2(8n+b)) == True{} : Bool})
    -> {Nat.is_le(Nat.div(x, 256n), F.spec_common__pow2(b)) == True{} : Bool}:
  +y = F.spec_common__pow2(b)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(x, z) == True{} : Bool}, D8(y), Nat.mul(y, 256n), Equal.sym(Nat, Nat.mul(y, 256n), D8(y), m256(y)), h)
  dle(x, y, F.nat__le_trans(x, Nat.mul(y, 256n), Nat.add(Nat.mul(y, 256n), 255n), h1, F.nat__le_add_right(Nat.mul(y, 256n), 255n)))

def zero_of(+q: Nat, +h: {Nat.is_le(q, 0n) == True{} : Bool}) -> {q == 0n : Nat}:
  match q:
    case 0n: {==}
    case 1n+p: Empty.absurd({1n+p == 0n : Nat}, F.logic__false_true(h))

def zfits(+w: Nat) -> {N.fits(w, 0n) == True{} : Bool}:
  match w:
    case 0n: {==}
    case 1n+p: zfits(p)

# x <= 255: every base-256 quotient is 0.
def small(+w: Nat, +x: Nat, +h: {Nat.is_le(x, 255n) == True{} : Bool}) -> {N.fits(1n+w, x) == True{} : Bool}:
  %Equal.sym(Nat, Nat.div(x, 256n), 0n, zero_of(Nat.div(x, 256n), dle(x, 0n, h))) : {N.fits(w, _) == True{} : Bool}
  zfits(w)

def fits_go(+w: Nat, +a: Nat, +x: Nat, +hx: {Nat.is_le(x, F.spec_common__pow2(a)) == True{} : Bool},
    +ha: {Nat.is_lt(a, Nat.double(Nat.double(Nat.double(w)))) == True{} : Bool}) -> {N.fits(w, x) == True{} : Bool}:
  match w:
    case 0n: Empty.absurd({N.fits(0n, x) == True{} : Bool}, F.nat__lt_zero_absurd(a, ha))
    case 1n+ +v:
      match a:
        case 0n: small(v, x, F.nat__le_trans(x, 1n, 255n, hx, {==}))
        case 1n: small(v, x, F.nat__le_trans(x, 2n, 255n, hx, {==}))
        case 2n: small(v, x, F.nat__le_trans(x, 4n, 255n, hx, {==}))
        case 3n: small(v, x, F.nat__le_trans(x, 8n, 255n, hx, {==}))
        case 4n: small(v, x, F.nat__le_trans(x, 16n, 255n, hx, {==}))
        case 5n: small(v, x, F.nat__le_trans(x, 32n, 255n, hx, {==}))
        case 6n: small(v, x, F.nat__le_trans(x, 64n, 255n, hx, {==}))
        case 7n: small(v, x, F.nat__le_trans(x, 128n, 255n, hx, {==}))
        case 8n+ +b: fits_go(v, b, Nat.div(x, 256n), step(x, b, hx), ha)

# The four-byte size bound for every x <= 2^a, a < 32.
law fits4:
  for +a: Nat
  for +x: Nat
  for +hx: {Nat.is_le(x, F.spec_common__pow2(a)) == True{} : Bool}
  for +ha: {Nat.is_lt(a, 32n) == True{} : Bool}
  {N.fits(4n, x) == True{} : Bool}
def fits4(a, x, hx, ha): fits_go(4n, a, x, hx, ha)

# ---- strict: x < 2^(8 w) fits w bytes (x < 2^32: every U32 value, any buffer length) ----------

def div_lt_go(+x: Nat, +y: Nat, +h: {Nat.is_lt(x, Nat.mul(y, 256n)) == True{} : Bool}, +b: Bool,
    +eb: {Nat.is_lt(Nat.div(x, 256n), y) == b : Bool}) -> {Nat.is_lt(Nat.div(x, 256n), y) == True{} : Bool}:
  match b:
    case True{}: eb
    case False{}:
      +q = Nat.div(x, 256n)
      +le1 = F.nat__not_lt_le(q, y, eb)
      +mm = mul_mono(y, q, 256n, le1)
      +le2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(q, 256n), z) == True{} : Bool}, Nat.add(Nat.mod(x, 256n), Nat.mul(q, 256n)), x, recompose(x),
        Order.left_below_sum(Nat.mod(x, 256n), Nat.mul(q, 256n)))
      +bad = F.nat__lt_le_trans(x, Nat.mul(y, 256n), x, h, F.nat__le_trans(Nat.mul(y, 256n), Nat.mul(q, 256n), x, mm, le2))
      Empty.absurd({Nat.is_lt(Nat.div(x, 256n), y) == True{} : Bool},
        F.logic__true_false(Equal.trans(Bool, True{}, Nat.is_lt(x, x), False{}, Equal.sym(Bool, Nat.is_lt(x, x), True{}, bad), F.nat__lt_irrefl(x))))

# x < 256 y gives x / 256 < y.
def div_lt(+x: Nat, +y: Nat, +h: {Nat.is_lt(x, Nat.mul(y, 256n)) == True{} : Bool}) -> {Nat.is_lt(Nat.div(x, 256n), y) == True{} : Bool}:
  div_lt_go(x, y, h, Nat.is_lt(Nat.div(x, 256n), y), {==})

def lt1z(+x: Nat, +h: {Nat.is_lt(x, 1n) == True{} : Bool}) -> {x == 0n : Nat}:
  match x:
    case 0n: {==}
    case 1n+ +p: Empty.absurd({1n+p == 0n : Nat}, F.nat__lt_zero_absurd(p, h))

def D3(+w: Nat) -> Nat: Nat.double(Nat.double(Nat.double(w)))

law fits_lt:
  for +w: Nat
  for +x: Nat
  for +h: {Nat.is_lt(x, F.spec_common__pow2(D3(w))) == True{} : Bool}
  {N.fits(w, x) == True{} : Bool}
def fits_lt(w, x, h):
  match w:
    case 0n:
      %Equal.sym(Nat, x, 0n, lt1z(x, h)) : {N.fits(0n, _) == True{} : Bool}
      {==}
    case 1n+ +v:
      +y = F.spec_common__pow2(D3(v))
      +h1 = F.logic__subst(Nat, z => {Nat.is_lt(x, z) == True{} : Bool}, D8(y), Nat.mul(y, 256n), Equal.sym(Nat, Nat.mul(y, 256n), D8(y), m256(y)), h)
      fits_lt(v, Nat.div(x, 256n), div_lt(x, y, h1))

# The four-byte size bound for every x < 2^32 (every U32 value).
def fits4lt(+x: Nat, +h: {Nat.is_lt(x, F.spec_common__pow2(32n)) == True{} : Bool}) -> {N.fits(4n, x) == True{} : Bool}:
  fits_lt(4n, x, h)
