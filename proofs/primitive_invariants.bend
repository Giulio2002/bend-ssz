import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T
import ./word_facts.bend as W

law and_true:
  for a: Bool
  for b: Bool
  for ea: {a == True{} : Bool}
  for eb: {b == True{} : Bool}
  {Bool.and(a, b) == True{} : Bool}
def and_true(a, b, ea, eb):
  match a:
    case False{}: Empty.absurd({False{} == True{} : Bool}, W.false_true(ea))
    case True{}: eb

law and_left:
  for a: Bool
  for b: Bool
  for e: {Bool.and(a, b) == True{} : Bool}
  {a == True{} : Bool}
def and_left(a, b, e):
  match a:
    case False{}: e
    case True{}: {==}

law and_right:
  for a: Bool
  for b: Bool
  for e: {Bool.and(a, b) == True{} : Bool}
  {b == True{} : Bool}
def and_right(a, b, e):
  match a:
    case False{}: Empty.absurd({b == True{} : Bool}, W.false_true(e))
    case True{}: e

law append_domain:
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +ex: {S.bytes_domain(xs) == True{} : Bool}
  for ey: {S.bytes_domain(ys) == True{} : Bool}
  {S.bytes_domain(List.append(&2, U32, xs, ys)) == True{} : Bool}
def append_domain(xs, ys, ex, ey):
  match xs:
    case Nil{}: ey
    case Con{h, t}:
      and_true(U32.is_lt(h, 256), S.bytes_domain(List.append(&2, U32, t, ys)),
        and_left(U32.is_lt(h, 256), S.bytes_domain(t), ex),
        append_domain(t, ys, and_right(U32.is_lt(h, 256), S.bytes_domain(t), ex), ey))

law limb_domain:
  for +x: U32
  {S.bytes_domain(I.limb(x)) == True{} : Bool}
def limb_domain(x):
  and_true(U32.is_lt(U32.and(x, 255), 256),
    S.bytes_domain([U32.and(U32.shrn(x, 8n), 255), U32.and(U32.shrn(x, 16n), 255), U32.shrn(x, 24n)]),
    W.masked_byte_bound(x),
    and_true(U32.is_lt(U32.and(U32.shrn(x, 8n), 255), 256),
      S.bytes_domain([U32.and(U32.shrn(x, 16n), 255), U32.shrn(x, 24n)]),
      W.masked_byte_bound(U32.shrn(x, 8n)),
      and_true(U32.is_lt(U32.and(U32.shrn(x, 16n), 255), 256),
        S.bytes_domain([U32.shrn(x, 24n)]), W.masked_byte_bound(U32.shrn(x, 16n)),
        and_true(U32.is_lt(U32.shrn(x, 24n), 256), True{}, W.shifted_byte_bound(x), {==}))))

# Successful-result predicates do not assert acceptance of invalid input.
def sized(n: Nat, r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{xs}: {List.length(&2, U32, xs) == n : Nat}

def byte_result(r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{xs}: {S.bytes_domain(xs) == True{} : Bool}

law accept_sized:
  for ok: Bool
  sized(0n, I.accept_bytes(ok, []))
def accept_sized(ok):
  match ok:
    case False{}: Unit{}
    case True{}: {==}

law prepend_sized:
  for n: Nat
  for h: U32
  for r: Maybe<&2, +List<U32>>
  for e: sized(n, r)
  sized(1n+n, I.prepend(h, r))
def prepend_sized(n, h, r, e):
  match r:
    case None{}: Unit{}
    case Some{xs}:
      %e : {1n+List.length(&2, U32, xs) == 1n+_ : Nat}
      {==}

law narrow_sized:
  for +n: Nat
  for +xs: +List<U32>
  sized(n, I.narrow(n, xs))
def narrow_sized(n, xs):
  match n:
    case 0n: accept_sized(I.all_zero(xs))
    case 1n+p:
      match xs:
        case Nil{}: Unit{}
        case Con{h, t}: prepend_sized(p, h, I.narrow(p, t), narrow_sized(p, t))

law accept_empty_domain:
  for ok: Bool
  byte_result(I.accept_bytes(ok, []))
def accept_empty_domain(ok):
  match ok:
    case False{}: Unit{}
    case True{}: {==}

law prepend_domain:
  for +h: U32
  for r: Maybe<&2, +List<U32>>
  for eh: {U32.is_lt(h, 256) == True{} : Bool}
  for er: byte_result(r)
  byte_result(I.prepend(h, r))
def prepend_domain(h, r, eh, er):
  match r:
    case None{}: Unit{}
    case Some{xs}: and_true(U32.is_lt(h, 256), S.bytes_domain(xs), eh, er)

law narrow_domain:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {S.bytes_domain(xs) == True{} : Bool}
  byte_result(I.narrow(n, xs))
def narrow_domain(n, xs, e):
  match n:
    case 0n: accept_empty_domain(I.all_zero(xs))
    case 1n+p:
      match xs:
        case Nil{}: Unit{}
        case Con{h, t}:
          prepend_domain(h, I.narrow(p, t),
            and_left(U32.is_lt(h, 256), S.bytes_domain(t), e),
            narrow_domain(p, t, and_right(U32.is_lt(h, 256), S.bytes_domain(t), e)))

law uint_bytes_domain:
  for +v: T.UInt
  {S.bytes_domain(I.uint_bytes(v)) == True{} : Bool}
def uint_bytes_domain(v):
  match v:
    case T.UInt{a, b, c, d, e, f, g, h}:
      append_domain(I.limb(a), List.append(&2, U32, I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, I.limb(g), I.limb(h))))))), limb_domain(a), append_domain(I.limb(b), List.append(&2, U32, I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, I.limb(g), I.limb(h)))))), limb_domain(b), append_domain(I.limb(c), List.append(&2, U32, I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, I.limb(g), I.limb(h))))), limb_domain(c), append_domain(I.limb(d), List.append(&2, U32, I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, I.limb(g), I.limb(h)))), limb_domain(d), append_domain(I.limb(e), List.append(&2, U32, I.limb(f), List.append(&2, U32, I.limb(g), I.limb(h))), limb_domain(e), append_domain(I.limb(f), List.append(&2, U32, I.limb(g), I.limb(h)), limb_domain(f), append_domain(I.limb(g), I.limb(h), limb_domain(g), limb_domain(h))))))))

law uint_serialized_length:
  for +w: T.Width
  for +v: T.UInt
  sized(I.width(w), I.uint_serialize(w, v))
def uint_serialized_length(w, v):
  narrow_sized(I.width(w), I.uint_bytes(v))

law uint_serialized_bytes:
  for +w: T.Width
  for +v: T.UInt
  byte_result(I.uint_serialize(w, v))
def uint_serialized_bytes(w, v):
  narrow_domain(I.width(w), I.uint_bytes(v), uint_bytes_domain(v))

law scope_of_domain:
  for +xs: +List<U32>
  {S.byte_scope(List.length(&2, U32, xs), xs) == S.bytes_domain(xs) : Bool}
def scope_of_domain(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %scope_of_domain(t) :
        {Bool.and(U32.is_lt(h, 256), S.byte_scope(List.length(&2, U32, t), t)) == Bool.and(U32.is_lt(h, 256), _) : Bool}
      {==}

def scoped(n: Nat, r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{xs}: {S.byte_scope(n, xs) == True{} : Bool}

law size_and_domain_scope:
  for n: Nat
  for +r: Maybe<&2, +List<U32>>
  for es: sized(n, r)
  for ed: byte_result(r)
  scoped(n, r)
def size_and_domain_scope(n, r, es, ed):
  match r:
    case None{}: Unit{}
    case Some{xs}:
      %es : {S.byte_scope(_, xs) == True{} : Bool}
      Equal.trans(Bool, S.byte_scope(List.length(&2, U32, xs), xs), S.bytes_domain(xs), True{}, scope_of_domain(xs), ed)

law uint_serialized_scope:
  for +w: T.Width
  for +v: T.UInt
  scoped(I.width(w), I.uint_serialize(w, v))
def uint_serialized_scope(w, v):
  size_and_domain_scope(I.width(w), I.uint_serialize(w, v), uint_serialized_length(w, v), uint_serialized_bytes(w, v))
