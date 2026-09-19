import Base
import ./word_facts.bend as W

# Proof-only structural views of little-endian bit words.
def join(+n: Nat, +m: Nat, low: Word(n), high: Word(m)) -> Word(Nat.add(n, m)):
  match n:
    case 0n: high
    case 1n+p:
      match low:
        case WCon{b, t}: WCon{b, join(p, m, t, high)}

def take(k: Nat, n: Nat, w: Word(n)) -> Word(k):
  match k:
    case 0n: WNil{}
    case 1n+p:
      match n:
        case 0n: Word.zero(1n+p)
        case 1n+q:
          match w:
            case WCon{b, t}: WCon{b, take(p, q, t)}

def cut(n: Nat, w: Word(1n+n)) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p:
      match w:
        case WCon{b, t}: WCon{b, cut(p, t)}

def last(n: Nat, w: Word(n)) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p:
      match p:
        case 0n:
          match w:
            case WCon{b, t}: b
        case 1n+q:
          match w:
            case WCon{b, t}: last(1n+q, t)

def roll(n: Nat, b: Bool, w: Word(n)) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p: WCon{b, cut(p, w)}

def quotient(+k: Nat, +n: Nat, w: Word(n)) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p:
      match w:
        case WCon{b, +t}: WCon{last(k, take(k, p, t)), quotient(k, p, t)}

law cut_zero:
  for +n: Nat
  {cut(n, Word.zero(1n+n)) == Word.zero(n) : Word(n)}
def cut_zero(n):
  match n:
    case 0n: {==}
    case 1n+p:
      %cut_zero(p) : {WCon{False{}, cut(p, Word.zero(1n+p))} == WCon{False{}, _} : Word(1n+p)}
      {==}

law cut_take:
  for +k: Nat
  for +n: Nat
  for +w: Word(n)
  {cut(k, take(1n+k, n, w)) == take(k, n, w) : Word(k)}
def cut_take(k, n, w):
  match k:
    case 0n: {==}
    case 1n+p:
      match n:
        case 0n: cut_zero(1n+p)
        case 1n+q:
          match w:
            case WCon{b, t}:
              %cut_take(p, q, t) : {WCon{b, cut(p, take(1n+p, q, t))} == WCon{b, _} : Word(1n+p)}
              {==}

law take_roll:
  for +k: Nat
  for +n: Nat
  for b: Bool
  for +w: Word(n)
  {roll(k, b, take(k, n, w)) == take(k, 1n+n, WCon{b, w}) : Word(k)}
def take_roll(k, n, b, w):
  match k:
    case 0n: {==}
    case 1n+p:
      %cut_take(p, n, w) : {WCon{b, cut(p, take(1n+p, n, w))} == WCon{b, _} : Word(1n+p)}
      {==}

# Subtracting a number with n low zero bits preserves the low n bits and carry.
law subtract_prefix:
  for +n: Nat
  for +m: Nat
  for +low: Word(n)
  for +a: Word(m)
  for +b: Word(m)
  {Word.sub(Nat.add(n, m), join(n, m, low, a), join(n, m, Word.zero(n), b)) == join(n, m, low, Word.sub(m, a, b)) : Word(Nat.add(n, m))}
def subtract_prefix(n, m, low, a, b):
  match n:
    case 0n: {==}
    case 1n+p:
      match low:
        case WCon{False{}, t}:
          %subtract_prefix(p, m, t, a, b) : {WCon{False{}, Word.sub(Nat.add(p, m), join(p, m, t, a), join(p, m, Word.zero(p), b))} == WCon{False{}, _} : Word(Nat.add(1n+p, m))}
          {==}
        case WCon{True{}, t}:
          %subtract_prefix(p, m, t, a, b) : {WCon{True{}, Word.sub(Nat.add(p, m), join(p, m, t, a), join(p, m, Word.zero(p), b))} == WCon{True{}, _} : Word(Nat.add(1n+p, m))}
          {==}

law cmp_zero_step:
  for c: Cmp
  for b: Bool
  for e: {Cmp.is_ge(c) == True{} : Bool}
  {Cmp.is_ge(Word.cmp.fin(b, False{}, c)) == True{} : Bool}
def cmp_zero_step(c, b, e):
  match c:
    case LT{}: e
    case GT{}: {==}
    case EQ{}:
      match b:
        case False{}: {==}
        case True{}: {==}

law compare_zero:
  for +n: Nat
  for +w: Word(n)
  {Cmp.is_ge(Word.cmp(n, w, Word.zero(n))) == True{} : Bool}
def compare_zero(n, w):
  match n:
    case 0n: {==}
    case 1n+p:
      match w:
        case WCon{b, t}: cmp_zero_step(Word.cmp(p, t, Word.zero(p)), b, compare_zero(p, t))

def ones(n: Nat) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p: WCon{True{}, ones(p)}

law mask_take:
  for +n: Nat
  for +m: Nat
  for +w: Word(Nat.add(n, m))
  {Word.and(Nat.add(n, m), w, join(n, m, ones(n), Word.zero(m))) == join(n, m, take(n, Nat.add(n, m), w), Word.zero(m)) : Word(Nat.add(n, m))}
def mask_take(n, m, w):
  match n:
    case 0n: W.and_zero(m, w)
    case 1n+p:
      match w:
        case WCon{False{}, t}:
          %mask_take(p, m, t) :
            {WCon{False{}, Word.and(Nat.add(p, m), t, join(p, m, ones(p), Word.zero(m)))} == WCon{False{}, _} : Word(Nat.add(1n+p, m))}
          {==}
        case WCon{True{}, t}:
          %mask_take(p, m, t) :
            {WCon{True{}, Word.and(Nat.add(p, m), t, join(p, m, ones(p), Word.zero(m)))} == WCon{True{}, _} : Word(Nat.add(1n+p, m))}
          {==}

law add_zero_left:
  for +n: Nat
  for +w: Word(n)
  {Word.add(n, Word.zero(n), w) == w : Word(n)}
def add_zero_left(n, w):
  match n:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{False{}, t}:
          %add_zero_left(p, t) : {WCon{False{}, Word.add(p, Word.zero(p), t)} == WCon{False{}, _} : Word(1n+p)}
          {==}
        case WCon{True{}, t}:
          %add_zero_left(p, t) : {WCon{True{}, Word.add(p, Word.zero(p), t)} == WCon{True{}, _} : Word(1n+p)}
          {==}

law add_prefix:
  for +n: Nat
  for +m: Nat
  for +low: Word(n)
  for +a: Word(m)
  for +b: Word(m)
  {Word.add(Nat.add(n, m), join(n, m, low, a), join(n, m, Word.zero(n), b)) == join(n, m, low, Word.add(m, a, b)) : Word(Nat.add(n, m))}
def add_prefix(n, m, low, a, b):
  match n:
    case 0n: {==}
    case 1n+p:
      match low:
        case WCon{False{}, t}:
          %add_prefix(p, m, t, a, b) : {WCon{False{}, Word.add(Nat.add(p, m), join(p, m, t, a), join(p, m, Word.zero(p), b))} == WCon{False{}, _} : Word(Nat.add(1n+p, m))}
          {==}
        case WCon{True{}, t}:
          %add_prefix(p, m, t, a, b) : {WCon{True{}, Word.add(Nat.add(p, m), join(p, m, t, a), join(p, m, Word.zero(p), b))} == WCon{True{}, _} : Word(Nat.add(1n+p, m))}
          {==}

law join_add:
  for +n: Nat
  for +m: Nat
  for +a: Word(n)
  for +b: Word(m)
  {Word.add(Nat.add(n, m), join(n, m, a, Word.zero(m)), join(n, m, Word.zero(n), b)) == join(n, m, a, b) : Word(Nat.add(n, m))}
def join_add(n, m, a, b):
  %add_zero_left(m, b) :
    {Word.add(Nat.add(n, m), join(n, m, a, Word.zero(m)), join(n, m, Word.zero(n), b)) == join(n, m, a, _) : Word(Nat.add(n, m))}
  add_prefix(n, m, a, Word.zero(m), b)

law or_zero_left:
  for +n: Nat
  for +w: Word(n)
  {Word.or(n, Word.zero(n), w) == w : Word(n)}
def or_zero_left(n, w):
  match n:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{b, t}:
          %or_zero_left(p, t) : {WCon{b, Word.or(p, Word.zero(p), t)} == WCon{b, _} : Word(1n+p)}
          {==}

law join_or:
  for +n: Nat
  for +m: Nat
  for +a: Word(n)
  for +b: Word(m)
  {Word.or(Nat.add(n, m), join(n, m, a, Word.zero(m)), join(n, m, Word.zero(n), b)) == join(n, m, a, b) : Word(Nat.add(n, m))}
def join_or(n, m, a, b):
  match n:
    case 0n: or_zero_left(m, b)
    case 1n+p:
      match a:
        case WCon{False{}, t}:
          %join_or(p, m, t, b) : {WCon{False{}, Word.or(Nat.add(p, m), join(p, m, t, Word.zero(m)), join(p, m, Word.zero(p), b))} == WCon{False{}, _} : Word(Nat.add(1n+p, m))}
          {==}
        case WCon{True{}, t}:
          %join_or(p, m, t, b) : {WCon{True{}, Word.or(Nat.add(p, m), join(p, m, t, Word.zero(m)), join(p, m, Word.zero(p), b))} == WCon{True{}, _} : Word(Nat.add(1n+p, m))}
          {==}

law lt_tail:
  for c: Cmp
  for b: Bool
  for e: {Cmp.is_lt(Word.cmp.fin(b, False{}, c)) == True{} : Bool}
  {Cmp.is_lt(c) == True{} : Bool}
def lt_tail(c, b, e):
  match c:
    case LT{}: {==}
    case GT{}: e
    case EQ{}:
      match b:
        case False{}: e
        case True{}: e

law below_one_tail:
  for c: Cmp
  for b: Bool
  for ge: {Cmp.is_ge(c) == True{} : Bool}
  for lt: {Cmp.is_lt(Word.cmp.fin(b, True{}, c)) == True{} : Bool}
  {Cmp.is_eq(c) == True{} : Bool}
def below_one_tail(c, b, ge, lt):
  match c:
    case LT{}: Empty.absurd({False{} == True{} : Bool}, W.false_true(ge))
    case GT{}: lt
    case EQ{}: {==}

law below_one_head:
  for c: Cmp
  for b: Bool
  for ge: {Cmp.is_ge(c) == True{} : Bool}
  for lt: {Cmp.is_lt(Word.cmp.fin(b, True{}, c)) == True{} : Bool}
  {b == False{} : Bool}
def below_one_head(c, b, ge, lt):
  match c:
    case LT{}: Empty.absurd({b == False{} : Bool}, W.false_true(ge))
    case GT{}: Empty.absurd({b == False{} : Bool}, W.false_true(lt))
    case EQ{}:
      match b:
        case False{}: {==}
        case True{}: Empty.absurd({True{} == False{} : Bool}, W.false_true(lt))

law below_one:
  for +n: Nat
  for +w: Word(1n+n)
  for +e: {Cmp.is_lt(Word.cmp(1n+n, w, WCon{True{}, Word.zero(n)})) == True{} : Bool}
  {w == Word.zero(1n+n) : Word(1n+n)}
def below_one(n, w, e):
  match w:
    case WCon{b, t}:
      %below_one_head(Word.cmp(n, t, Word.zero(n)), b, compare_zero(n, t), e) :
        {WCon{b, t} == WCon{_, Word.zero(n)} : Word(1n+n)}
      %W.word_compare_sound(n, t, Word.zero(n), below_one_tail(Word.cmp(n, t, Word.zero(n)), b, compare_zero(n, t), e)) :
        {WCon{b, t} == WCon{b, _} : Word(1n+n)}
      {==}

law lt_prefix:
  for +n: Nat
  for +m: Nat
  for +low: Word(n)
  for +high: Word(m)
  for +limit: Word(m)
  for e: {Cmp.is_lt(Word.cmp(Nat.add(n, m), join(n, m, low, high), join(n, m, Word.zero(n), limit))) == True{} : Bool}
  {Cmp.is_lt(Word.cmp(m, high, limit)) == True{} : Bool}
def lt_prefix(n, m, low, high, limit, e):
  match n:
    case 0n: e
    case 1n+p:
      match low:
        case WCon{b, t}:
          lt_prefix(p, m, t, high, limit,
            lt_tail(Word.cmp(Nat.add(p, m), join(p, m, t, high), join(p, m, Word.zero(p), limit)), b, e))
