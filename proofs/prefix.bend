import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S

# Refinement of the overflow-checking prefix operation for ALL lengths/inputs.
# This lemma does not assume that runtime limb extraction is arithmetic digits.
law zeros_correct:
  for xs: +List<U32>
  {I.all_zero(xs) == S.zero_suffix(xs) : Bool}
def zeros_correct(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %zeros_correct(t) : {Bool.and(U32.is_eq(h, 0), I.all_zero(t)) == Bool.and(U32.is_eq(h, 0), _) : Bool}
      {==}

law accept_correct:
  for ok: Bool
  for xs: +List<U32>
  {I.accept_bytes(ok, xs) == S.optional(ok, xs) : Maybe<&2, +List<U32>>}
def accept_correct(ok, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law prepend_optional:
  for ok: Bool
  for h: U32
  for xs: +List<U32>
  {I.prepend(h, S.optional(ok, xs)) == S.optional(ok, h <> xs) : Maybe<&2, +List<U32>>}
def prepend_optional(ok, h, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law narrow_correct:
  for +n: Nat
  for +xs: +List<U32>
  {I.narrow(n, xs) == S.optional(S.fits(n, xs), S.prefix(n, xs)) : Maybe<&2, +List<U32>>}
def narrow_correct(n, xs):
  match n:
    case 0n:
      %zeros_correct(xs) : {I.accept_bytes(I.all_zero(xs), []) == S.optional(_, []) : Maybe<&2, +List<U32>>}
      accept_correct(I.all_zero(xs), [])
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}:
          %Equal.sym(Maybe<&2, +List<U32>>, I.narrow(p, t), S.optional(S.fits(p, t), S.prefix(p, t)), narrow_correct(p, t)) :
            {I.prepend(h, _) == S.optional(S.fits(p, t), h <> S.prefix(p, t)) : Maybe<&2, +List<U32>>}
          prepend_optional(S.fits(p, t), h, S.prefix(p, t))

law optional_accepted:
  for ok: Bool
  for xs: +List<U32>
  {I.is_some(S.optional(ok, xs)) == ok : Bool}
def optional_accepted(ok, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law narrow_domain_correct:
  for +n: Nat
  for +xs: +List<U32>
  {I.is_some(I.narrow(n, xs)) == S.fits(n, xs) : Bool}
def narrow_domain_correct(n, xs):
  %Equal.sym(Maybe<&2, +List<U32>>, I.narrow(n, xs), S.optional(S.fits(n, xs), S.prefix(n, xs)), narrow_correct(n, xs)) :
    {I.is_some(_) == S.fits(n, xs) : Bool}
  optional_accepted(S.fits(n, xs), S.prefix(n, xs))
