import Base
import ../../spec/tree.bend as TR
import ../../spec/limits.bend as Lim
import ../../spec/byte_list.bend as BL
import ../../spec/fulu_schemas.bend as Spec
import ../../types/schema.bend as S

# Symbolic facts about power-of-two limits.
#
# The checker compares Nats in unary, so a closed fact such as
# Lim.minimal(BL.chunk_limit(2^30), 25) costs about 2^30 steps when it is
# evaluated. Here the same facts are proved for a symbolic depth d, by
# induction, and the closed limits are reached through equations between
# words (32 steps) and through conversions that match f(x) against f(x)
# without evaluating it. The last two need tools/bend-fast (stock Bend 2.0.25
# evaluates both sides of every conversion first; see tools/bend-fast/README.md).

# The word of n zero bits, and the word of n bits with only bit k set
# (bits are least significant first, as in Base's Word.to_nat).
def zw(n: Nat) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p: WCon{False{}, zw(p)}

def pw(k: Nat, n: Nat) -> Word(n):
  match k n:
    case 0n 0n: WNil{}
    case 0n 1n+p: WCon{True{}, zw(p)}
    case 1n+q 0n: WNil{}
    case 1n+q 1n+p: WCon{False{}, pw(q, p)}

law zw_nat:
  for +n: Nat
  {Word.to_nat(n, zw(n)) == 0n : Nat}
def zw_nat(n):
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, x => Nat.double(x), Word.to_nat(p, zw(p)), 0n, zw_nat(p))

# A word with only bit k set denotes 2^k (TR.capacity(k)).
law pw_nat:
  for +k: Nat
  for +m: Nat
  {Word.to_nat(Nat.add(k, 1n+m), pw(k, Nat.add(k, 1n+m))) == TR.capacity(k) : Nat}
def pw_nat(k, m):
  match k:
    case 0n: Equal.cong(Nat, Nat, x => 1n+Nat.double(x), Word.to_nat(m, zw(m)), 0n, zw_nat(m))
    case 1n+q: Equal.cong(Nat, Nat, x => Nat.double(x), Word.to_nat(Nat.add(q, 1n+m), pw(q, Nat.add(q, 1n+m))), TR.capacity(q), pw_nat(q, m))

law u32_word:
  for +w: Word(32n)
  {U32.to_nat(U32{w}) == Word.to_nat(32n, w) : Nat}
def u32_word(w): {==}

# The 2^30 literal of the Fulu schemas.
def pow30() -> {U32.to_nat(1073741824) == TR.capacity(30n) : Nat}:
  Equal.trans(Nat, U32.to_nat(1073741824), Word.to_nat(32n, pw(30n, 32n)), TR.capacity(30n),
    Equal.trans(Nat, U32.to_nat(1073741824), U32.to_nat(U32{pw(30n, 32n)}), Word.to_nat(32n, pw(30n, 32n)),
      Equal.cong(U32, Nat, x => U32.to_nat(x), 1073741824, U32{pw(30n, 32n)}, {==}),
      u32_word(pw(30n, 32n))),
    pw_nat(30n, 1n))

law add_s:
  for +n: Nat
  for +m: Nat
  {Nat.add(n, 1n+m) == 1n+Nat.add(n, m) : Nat}
def add_s(n, m):
  match n:
    case 0n: {==}
    case 1n+q: Equal.cong(Nat, Nat, x => 1n+x, Nat.add(q, 1n+m), 1n+Nat.add(q, m), add_s(q, m))

law add_z:
  for +n: Nat
  {Nat.add(n, 0n) == n : Nat}
def add_z(n):
  match n:
    case 0n: {==}
    case 1n+q: Equal.cong(Nat, Nat, x => 1n+x, Nat.add(q, 0n), q, add_z(q))

# 32 * c, as TR.capacity(5 + d) unfolds to it.
def d5(c: Nat) -> Nat: Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(c)))))

# Division by 32 of 32c + 31, one block of 32 steps at a time.
law go32:
  for +c: Nat
  for +acc: Nat
  {Nat.divmod.go(Nat.add(d5(c), 31n), 31n, acc, 0n) == (Nat.add(c, acc), 31n) : Nat & Nat}
def go32(c, acc):
  match c:
    case 0n: {==}
    case 1n+p:
      %add_s(p, acc) : {Nat.divmod.go(Nat.add(d5(1n+p), 31n), 31n, acc, 0n) == (_, 31n) : Nat & Nat}
      go32(p, 1n+acc)

# A byte list of 2^(5+d) bytes has 2^d chunks.
law cl:
  for +d: Nat
  {BL.chunk_limit(TR.capacity(Nat.add(5n, d))) == TR.capacity(d) : Nat}
def cl(d):
  %add_z(TR.capacity(d)) : {BL.chunk_limit(TR.capacity(Nat.add(5n, d))) == _ : Nat}
  Equal.cong(Nat & Nat, Nat, x => Pair.fst(Nat, Nat, x), Nat.divmod.go(Nat.add(d5(TR.capacity(d)), 31n), 31n, 0n, 0n), (Nat.add(TR.capacity(d), 0n), 31n), go32(TR.capacity(d), 0n))

law cmp_dbl:
  for +a: Nat
  for +b: Nat
  {Nat.cmp(Nat.double(a), Nat.double(b)) == Nat.cmp(a, b) : Cmp}
def cmp_dbl(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: cmp_dbl(p, q)

law le_refl:
  for +x: Nat
  {Nat.is_le(x, x) == True{} : Bool}
def le_refl(x):
  match x:
    case 0n: {==}
    case 1n+y: le_refl(y)

law lt_cd:
  for +p: Nat
  {Nat.is_lt(TR.capacity(p), Nat.double(TR.capacity(p))) == True{} : Bool}
def lt_cd(p):
  match p:
    case 0n: {==}
    case 1n+q:
      %Equal.sym(Cmp, Nat.cmp(Nat.double(TR.capacity(q)), Nat.double(Nat.double(TR.capacity(q)))), Nat.cmp(TR.capacity(q), Nat.double(TR.capacity(q))), cmp_dbl(TR.capacity(q), Nat.double(TR.capacity(q)))) : {Cmp.is_lt(_) == True{} : Bool}
      lt_cd(q)

# 2^d is the minimal capacity for depth d.
law min_cap:
  for +d: Nat
  {Lim.minimal(TR.capacity(d), d) == True{} : Bool}
def min_cap(d):
  match d:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Bool, Nat.is_le(TR.capacity(1n+p), TR.capacity(1n+p)), True{}, le_refl(TR.capacity(1n+p))) : {Bool.and(_, Lim.lower(TR.capacity(1n+p), 1n+p)) == True{} : Bool}
      lt_cd(p)

# The chunk limit of a byte list of 2^(5+d) bytes is minimal at depth d.
law mcl:
  for +d: Nat
  {Lim.minimal(BL.chunk_limit(TR.capacity(Nat.add(5n, d))), d) == True{} : Bool}
def mcl(d):
  %Equal.sym(Nat, BL.chunk_limit(TR.capacity(Nat.add(5n, d))), TR.capacity(d), cl(d)) : {Lim.minimal(_, d) == True{} : Bool}
  min_cap(d)

# Transaction = ByteList[2^30] (spec/fulu_schemas.bend Schema60).
def tx_schema() -> {S.ByteList{U32.to_nat(1073741824)} == Spec.Transaction() : S.Schema}: {==}
