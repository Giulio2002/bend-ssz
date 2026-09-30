import Base
import ../proofs/word_split.bend as WSp

# What the generated validity predicates (types/<X>_encode_ssz_generated.bend, X_valid) say, in the
# forms the e2e bridges take as premises (e2e/<Name>_e2e_generated.bend). Used by
# e2e/<Name>_e2e_ser_generated.bend (codegen/serialize_e2e.py).

# x <= 2^n - 1 gives x < 2^n (the uint8 / uint16 domains: u8_valid is is_le(o, 255), rp_u8 is is_lt(o, 256)), on the
# words: the checker never turns the constants into unary numbers
def le_tail(+c: Cmp, +b: Bool, +e: {Cmp.is_le(Word.cmp.fin(b, True{}, c)) == True{} : Bool}) -> {Cmp.is_le(c) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: e

def lt_fin(+c: Cmp, +b: Bool, +h: {Cmp.is_lt(c) == True{} : Bool}) -> {Cmp.is_lt(Word.cmp.fin(b, False{}, c)) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}:
      match b:
        case False{}: h
        case True{}: h
    case GT{}: h

def le_lt0(+c: Cmp, +b: Bool, +e: {Cmp.is_le(Word.cmp.fin(b, False{}, c)) == True{} : Bool}) -> {Cmp.is_lt(Word.cmp.fin(b, True{}, c)) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}:
      match b:
        case False{}: {==}
        case True{}: e
    case GT{}: e

def le_lt(+n: Nat, +m: Nat, +w: Word(Nat.add(n, 1n+m)),
    +e: {Cmp.is_le(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, WSp.ones(n), Word.zero(1n+m)))) == True{} : Bool})
    -> {Cmp.is_lt(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, Word.zero(n), WCon{True{}, Word.zero(m)}))) == True{} : Bool}:
  match n:
    case 0n:
      match w:
        case WCon{b, t}: le_lt0(Word.cmp(m, t, Word.zero(m)), b, e)
    case 1n+p:
      match w:
        case WCon{b, t}:
          lt_fin(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, Word.zero(p), WCon{True{}, Word.zero(m)})), b,
            le_lt(p, m, t, le_tail(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, WSp.ones(p), Word.zero(1n+m))), b, e)))

# a little-endian word below 2^n (as the word 0..0 1 0..0, n zeros first) has its high m + 1 bits zero, so it is the join
# of its n low bits with zeros: the shape the bit-vector bridges take as premise
def shz(+n: Nat, +m: Nat, +w: Word(Nat.add(n, 1n+m)),
    +e: {Cmp.is_lt(Word.cmp(Nat.add(n, 1n+m), w, WSp.join(n, 1n+m, Word.zero(n), WCon{True{}, Word.zero(m)}))) == True{} : Bool})
    -> {w == WSp.join(n, 1n+m, WSp.take(n, Nat.add(n, 1n+m), w), Word.zero(1n+m)) : Word(Nat.add(n, 1n+m))}:
  match n:
    case 0n: WSp.below_one(m, w, e)
    case 1n+p:
      match w:
        case WCon{b, t}:
          Equal.cong(Word(Nat.add(p, 1n+m)), Word(Nat.add(1n+p, 1n+m)), z => WCon{b, z}, t,
            WSp.join(p, 1n+m, WSp.take(p, Nat.add(p, 1n+m), t), Word.zero(1n+m)),
            shz(p, m, t, WSp.lt_tail(Word.cmp(Nat.add(p, 1n+m), t, WSp.join(p, 1n+m, Word.zero(p), WCon{True{}, Word.zero(m)})), b, e)))
