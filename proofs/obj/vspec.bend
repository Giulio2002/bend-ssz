import Base
import ../../src/primitives.bend as I
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../proofs/primitive_invariants.bend as V
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./nat_facts.bend as NF
import ./spec_fixed.bend as FX
import ../compact/arith.bend as A

# Variable-size codec laws, specification side (spec/codec.bend,
# spec/layout.bend): what the independent offset layout makes of parts whose
# bytes are the limbs of word lists. Everything is stated over word LISTS and
# symbolic counts; no closed large number is ever evaluated.

# ---- small list facts -----------------------------------------------------------

law app_nil:
  for +xs: +List<U32>
  {List.append(&2, U32, xs, []) == xs : +List<U32>}
def app_nil(xs):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(+List<U32>, List.append(&2, U32, t, []), t, app_nil(t)) : {h <> _ == h <> t : +List<U32>}
      {==}

law app_assoc:
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +zs: +List<U32>
  {List.append(&2, U32, List.append(&2, U32, xs, ys), zs) == List.append(&2, U32, xs, List.append(&2, U32, ys, zs)) : +List<U32>}
def app_assoc(xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, t, ys), zs), List.append(&2, U32, t, List.append(&2, U32, ys, zs)), app_assoc(t, ys, zs)) :
        {h <> _ == h <> List.append(&2, U32, t, List.append(&2, U32, ys, zs)) : +List<U32>}
      {==}

law len_app:
  for +xs: +List<U32>
  for +ys: +List<U32>
  {List.length(&2, U32, List.append(&2, U32, xs, ys)) == Nat.add(List.length(&2, U32, xs), List.length(&2, U32, ys)) : Nat}
def len_app(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, t, ys)), Nat.add(List.length(&2, U32, t), List.length(&2, U32, ys)), len_app(t, ys)) :
        {1n+_ == 1n+Nat.add(List.length(&2, U32, t), List.length(&2, U32, ys)) : Nat}
      {==}

law len_limbs:
  for +ws: +List<U32>
  {List.length(&2, U32, FX.limbs(ws)) == FX.wlen(ws) : Nat}
def len_limbs(ws):
  match ws:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, FX.limbs(t)), FX.wlen(t), len_limbs(t)) : {4n+_ == 4n+FX.wlen(t) : Nat}
      {==}

# ---- the fits test is monotone ------------------------------------------------------

law fits_mono:
  for +k: Nat
  for +x: Nat
  for +y: Nat
  for +le: {Nat.is_le(x, y) == True{} : Bool}
  for +fy: {N.fits(k, y) == True{} : Bool}
  {N.fits(k, x) == True{} : Bool}
def fits_mono(k, x, y, le, fy):
  match k:
    case 0n:
      +le0 = F.logic__subst(Nat, z => {Nat.is_le(x, z) == True{} : Bool}, y, 0n, F.nat__eq_from_is_eq(y, 0n, fy), le)
      %Equal.sym(Nat, x, 0n, F.nat__le_antisym(x, 0n, le0, F.nat__zero_le(x))) : {Nat.is_eq(_, 0n) == True{} : Bool}
      {==}
    case 1n+ +p:
      fits_mono(p, Nat.div(x, 256n), Nat.div(y, 256n), NF.quotient_monotone(x, y, 255n, 0n, 0n, le), fy)

# ---- fixed parts of words ------------------------------------------------------------

law fixed_size_fparts:
  for +wss: +List<+List<U32>>
  {Layout.fixed_size(FX.fparts(wss)) == List.length(&2, U32, FX.flat(wss)) : Nat}
def fixed_size_fparts(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t))), Nat.add(List.length(&2, U32, FX.limbs(ws)), List.length(&2, U32, FX.flat(t))), len_app(FX.limbs(ws), FX.flat(t))) :
        {Nat.add(List.length(&2, U32, FX.limbs(ws)), Layout.fixed_size(FX.fparts(t))) == _ : Nat}
      %Equal.sym(Nat, Layout.fixed_size(FX.fparts(t)), List.length(&2, U32, FX.flat(t)), fixed_size_fparts(t)) :
        {Nat.add(List.length(&2, U32, FX.limbs(ws)), _) == Nat.add(List.length(&2, U32, FX.limbs(ws)), List.length(&2, U32, FX.flat(t))) : Nat}
      {==}

law fixed_parts_fparts:
  for +wss: +List<+List<U32>>
  for +off: Nat
  {Layout.fixed_parts(FX.fparts(wss), off) == FX.flat(wss) : +List<U32>}
def fixed_parts_fparts(wss, off):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(+List<U32>, Layout.fixed_parts(FX.fparts(t), off), FX.flat(t), fixed_parts_fparts(t, off)) :
        {List.append(&2, U32, FX.limbs(ws), _) == List.append(&2, U32, FX.limbs(ws), FX.flat(t)) : +List<U32>}
      {==}

law payloads_fparts:
  for +wss: +List<+List<U32>>
  {Layout.payloads(FX.fparts(wss)) == [] : +List<U32>}
def payloads_fparts(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}: payloads_fparts(t)

# The layout of fixed parts of words is their concatenation, when it fits.
law encoding_fparts:
  for +wss: +List<+List<U32>>
  for +fit: {N.fits(4n, List.length(&2, U32, FX.flat(wss))) == True{} : Bool}
  {Layout.encoding(FX.fparts(wss)) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
def encoding_fparts(wss, fit):
  %Equal.sym(Nat, Layout.fixed_size(FX.fparts(wss)), List.length(&2, U32, FX.flat(wss)), fixed_size_fparts(wss)) :
    {SP.optional(Bool.and(Layout.bytes_valid(FX.fparts(wss)), N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(FX.fparts(wss)))))),
       List.append(&2, U32, Layout.fixed_parts(FX.fparts(wss), _), Layout.payloads(FX.fparts(wss)))) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(FX.fparts(wss)), [], payloads_fparts(wss)) :
    {SP.optional(Bool.and(Layout.bytes_valid(FX.fparts(wss)), N.fits(4n, Nat.add(List.length(&2, U32, FX.flat(wss)), List.length(&2, U32, _)))),
       List.append(&2, U32, Layout.fixed_parts(FX.fparts(wss), List.length(&2, U32, FX.flat(wss))), _)) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(FX.fparts(wss), List.length(&2, U32, FX.flat(wss))), FX.flat(wss), fixed_parts_fparts(wss, List.length(&2, U32, FX.flat(wss)))) :
    {SP.optional(Bool.and(Layout.bytes_valid(FX.fparts(wss)), N.fits(4n, Nat.add(List.length(&2, U32, FX.flat(wss)), 0n))),
       List.append(&2, U32, _, [])) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, FX.flat(wss), []), FX.flat(wss), app_nil(FX.flat(wss))) :
    {SP.optional(Bool.and(Layout.bytes_valid(FX.fparts(wss)), N.fits(4n, Nat.add(List.length(&2, U32, FX.flat(wss)), 0n))), _) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, Nat.add(List.length(&2, U32, FX.flat(wss)), 0n), List.length(&2, U32, FX.flat(wss)), F.nat__add_zero(List.length(&2, U32, FX.flat(wss)))) :
    {SP.optional(Bool.and(Layout.bytes_valid(FX.fparts(wss)), N.fits(4n, _)), FX.flat(wss)) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, List.length(&2, U32, FX.flat(wss))), True{}, fit) :
    {SP.optional(Bool.and(Layout.bytes_valid(FX.fparts(wss)), _), FX.flat(wss)) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid(FX.fparts(wss)), True{}, FX.valid_fparts(wss)) :
    {SP.optional(Bool.and(_, True{}), FX.flat(wss)) == Some{FX.flat(wss)} : Maybe<&2, +List<U32>>}
  {==}

# ---- lists of uint64 held as words ------------------------------------------------------

# k uint64 elements from a word list: element j is words 2j, 2j + 1 (low, high).
# (The same definition as proofs/obj/ulist_obj.bend `uitems`.)
def uitems(k: Nat, W: List<&2, U32>) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+c:
      match W:
        case Nil{}: S.EmptyItems{}
        case Con{+a, t}:
          match t:
            case Nil{}: S.EmptyItems{}
            case Con{+b, rest}: S.Items{S.UnsignedValue{P.UInt{a, b, 0, 0, 0, 0, 0, 0}}, uitems(c, rest)}

# Their words, two per element.
def upairs(k: Nat, W: List<&2, U32>) -> +List<+List<U32>>:
  match k:
    case 0n: []
    case 1n+c:
      match W:
        case Nil{}: []
        case Con{+a, t}:
          match t:
            case Nil{}: []
            case Con{+b, rest}: [a, b] <> upairs(c, rest)

law u64_parts:
  for +k: Nat
  for +W: List<&2, U32>
  {Codec.parts(uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}) == Some{FX.fparts(upairs(k, W))} : Maybe<&2, +List<S.Part>>}
def u64_parts(k, W):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a, +t}:
          match t:
            case Nil{}: {==}
            case Con{+b, +rest}:
              FX.cat_fixed(Codec.parts(S.UnsignedValue{P.UInt{a, b, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U64{}}), FX.limbs([a, b]),
                Codec.parts(uitems(c, rest), S.Repeat{S.Unsigned{P.U64{}}}), FX.fparts(upairs(c, rest)),
                FX.uint64_part(a, b), u64_parts(c, rest))

law count_uitems:
  for +k: Nat
  for +W: List<&2, U32>
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {Codec.count(uitems(k, W)) == k : Nat}
def count_uitems(k, W, hl):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: Empty.absurd({Codec.count(uitems(1n+c, Nil{})) == 1n+c : Nat}, F.logic__false_true(hl))
        case Con{+a, +t}:
          match t:
            case Nil{}: Empty.absurd({Codec.count(uitems(1n+c, [a])) == 1n+c : Nat}, F.logic__false_true(hl))
            case Con{+b, +rest}:
              %Equal.sym(Nat, Codec.count(uitems(c, rest)), c, count_uitems(c, rest, hl)) : {1n+_ == 1n+c : Nat}
              {==}

# The words of k elements are the first 2k words.
def wtake(n: Nat, W: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: []
    case 1n+p:
      match W:
        case Nil{}: []
        case Con{h, t}: h <> wtake(p, t)

# The number of whole elements available (k when the list is long enough).
def upairs_n(k: Nat, W: List<&2, U32>) -> Nat:
  match k:
    case 0n: 0n
    case 1n+c:
      match W:
        case Nil{}: 0n
        case Con{+a, t}:
          match t:
            case Nil{}: 0n
            case Con{+b, rest}: 1n+upairs_n(c, rest)

law flat_upairs:
  for +k: Nat
  for +W: List<&2, U32>
  {FX.flat(upairs(k, W)) == FX.limbs(wtake(Nat.double(upairs_n(k, W)), W)) : +List<U32>}
def flat_upairs(k, W):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a, +t}:
          match t:
            case Nil{}: {==}
            case Con{+b, +rest}:
              %Equal.sym(+List<U32>, FX.flat(upairs(c, rest)), FX.limbs(wtake(Nat.double(upairs_n(c, rest)), rest)), flat_upairs(c, rest)) :
                {List.append(&2, U32, List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])), _) ==
                 List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), FX.limbs(wtake(Nat.double(upairs_n(c, rest)), rest)))) : +List<U32>}
              %Equal.sym(+List<U32>, List.append(&2, U32, I.limb(b), []), I.limb(b), app_nil(I.limb(b))) :
                {List.append(&2, U32, List.append(&2, U32, I.limb(a), _), FX.limbs(wtake(Nat.double(upairs_n(c, rest)), rest))) ==
                 List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), FX.limbs(wtake(Nat.double(upairs_n(c, rest)), rest)))) : +List<U32>}
              app_assoc(I.limb(a), I.limb(b), FX.limbs(wtake(Nat.double(upairs_n(c, rest)), rest)))


law upairs_n_eq:
  for +k: Nat
  for +W: List<&2, U32>
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {upairs_n(k, W) == k : Nat}
def upairs_n_eq(k, W, hl):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: Empty.absurd({upairs_n(1n+c, Nil{}) == 1n+c : Nat}, F.logic__false_true(hl))
        case Con{+a, +t}:
          match t:
            case Nil{}: Empty.absurd({upairs_n(1n+c, [a]) == 1n+c : Nat}, F.logic__false_true(hl))
            case Con{+b, +rest}:
              %Equal.sym(Nat, upairs_n(c, rest), c, upairs_n_eq(c, rest, hl)) : {1n+_ == 1n+c : Nat}
              {==}

# 8k, by structural recursion.
def x8(k: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+c: 8n+x8(c)

law len_flat_upairs:
  for +k: Nat
  for +W: List<&2, U32>
  {List.length(&2, U32, FX.flat(upairs(k, W))) == x8(upairs_n(k, W)) : Nat}
def len_flat_upairs(k, W):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a, +t}:
          match t:
            case Nil{}: {==}
            case Con{+b, +rest}:
              %len_flat_upairs(c, rest) :
                {List.length(&2, U32, List.append(&2, U32, FX.limbs([a, b]), FX.flat(upairs(c, rest)))) == 8n+_ : Nat}
              {==}

law upairs_n_le:
  for +k: Nat
  for +W: List<&2, U32>
  {Nat.is_le(upairs_n(k, W), k) == True{} : Bool}
def upairs_n_le(k, W):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a, +t}:
          match t:
            case Nil{}: {==}
            case Con{+b, +rest}: upairs_n_le(c, rest)

law x8_mono:
  for +a: Nat
  for +b: Nat
  for +le: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(x8(a), x8(b)) == True{} : Bool}
def x8_mono(a, b, le):
  match a b:
    case 0n _: F.nat__zero_le(x8(b))
    case 1n+p 0n: Empty.absurd({Nat.is_le(x8(1n+p), 0n) == True{} : Bool}, F.logic__false_true(le))
    case 1n+ +p 1n+ +q: x8_mono(p, q, le)

# A list of uint64 of at most `lim` elements (whose 8 lim bytes fit the offset
# width) is one variable part: the limbs of its words.
law list_u64_parts:
  for +k: Nat
  for +W: List<&2, U32>
  for +lim: Nat
  for +hk: {Nat.is_le(k, lim) == True{} : Bool}
  for +hfit: {N.fits(4n, x8(lim)) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {Codec.parts(S.Sequence{uitems(k, W)}, S.ListOf{S.Unsigned{P.U64{}}, lim}) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
def list_u64_parts(k, W, lim, hk, hfit, hl):
  +fit = fits_mono(4n, List.length(&2, U32, FX.flat(upairs(k, W))), x8(lim),
    F.logic__subst(Nat, z => {Nat.is_le(z, x8(lim)) == True{} : Bool}, x8(upairs_n(k, W)), List.length(&2, U32, FX.flat(upairs(k, W))),
      Equal.sym(Nat, List.length(&2, U32, FX.flat(upairs(k, W))), x8(upairs_n(k, W)), len_flat_upairs(k, W)),
      x8_mono(upairs_n(k, W), lim, F.nat__le_trans(upairs_n(k, W), k, lim, upairs_n_le(k, W), hk))),
    hfit)
  %Equal.sym(Nat, Codec.count(uitems(k, W)), k, count_uitems(k, W, hl)) :
    {Codec.require(Nat.is_le(_, lim), Codec.aggregate(Codec.parts(uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}), None{})) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Nat.is_le(k, lim), True{}, hk) :
    {Codec.require(_, Codec.aggregate(Codec.parts(uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}), None{})) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(uitems(k, W), S.Repeat{S.Unsigned{P.U64{}}}), Some{FX.fparts(upairs(k, W))}, u64_parts(k, W)) :
    {Codec.require(True{}, Codec.aggregate(_, None{})) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(FX.fparts(upairs(k, W))), Some{FX.flat(upairs(k, W))}, encoding_fparts(upairs(k, W), fit)) :
    {Codec.one(_, None{}) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, FX.flat(upairs(k, W)), FX.limbs(wtake(Nat.double(upairs_n(k, W)), W)), flat_upairs(k, W)) :
    {Codec.one(Some{_}, None{}) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Nat, upairs_n(k, W), k, upairs_n_eq(k, W, hl)) :
    {Codec.one(Some{FX.limbs(wtake(Nat.double(_), W))}, None{}) == Some{[S.Variable{FX.limbs(wtake(Nat.double(k), W))}]} : Maybe<&2, +List<S.Part>>}
  {==}

law wlen_wtake2:
  for +k: Nat
  for +W: List<&2, U32>
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {FX.wlen(wtake(Nat.double(k), W)) == x8(k) : Nat}
def wlen_wtake2(k, W, hl):
  match k:
    case 0n: {==}
    case 1n+ +c:
      match W:
        case Nil{}: Empty.absurd({FX.wlen(wtake(Nat.double(1n+c), Nil{})) == x8(1n+c) : Nat}, F.logic__false_true(hl))
        case Con{+a, +t}:
          match t:
            case Nil{}: Empty.absurd({FX.wlen(wtake(Nat.double(1n+c), [a])) == x8(1n+c) : Nat}, F.logic__false_true(hl))
            case Con{+b, +rest}:
              %wlen_wtake2(c, rest, hl) : {8n+FX.wlen(wtake(Nat.double(c), rest)) == 8n+_ : Nat}
              {==}

law len_limbs_wtake2:
  for +k: Nat
  for +W: List<&2, U32>
  for +hl: {Nat.is_le(Nat.double(k), F.spec_common__length(U32, W)) == True{} : Bool}
  {List.length(&2, U32, FX.limbs(wtake(Nat.double(k), W))) == x8(k) : Nat}
def len_limbs_wtake2(k, W, hl):
  %wlen_wtake2(k, W, hl) : {List.length(&2, U32, FX.limbs(wtake(Nat.double(k), W))) == _ : Nat}
  len_limbs(wtake(Nat.double(k), W))

# The first n bytes (as proofs/obj/words_spec.bend `btake`).
def bt(n: Nat, xs: +List<U32>) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{h, t}: h <> bt(p, t)

# The first 4m bytes of the limbs of words are the limbs of the first m words.
law bt_limbs:
  for +m: Nat
  for +W: List<&2, U32>
  {bt(Nat.double(Nat.double(m)), FX.limbs(W)) == FX.limbs(wtake(m, W)) : +List<U32>}
def bt_limbs(m, W):
  match m W:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}:
      %Equal.sym(+List<U32>, bt(Nat.double(Nat.double(p)), FX.limbs(t)), FX.limbs(wtake(p, t)), bt_limbs(p, t)) :
        {U32.and(h, 255) <> U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> _ ==
         U32.and(h, 255) <> U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> FX.limbs(wtake(p, t)) : +List<U32>}
      {==}

# ---- byte windows ------------------------------------------------------------------------

def bdr(n: Nat, xs: +List<U32>) -> +List<U32>:
  match n:
    case 0n: xs
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{h, t}: bdr(p, t)

law bdr_app:
  for +xs: +List<U32>
  for +R: +List<U32>
  {bdr(List.length(&2, U32, xs), List.append(&2, U32, xs, R)) == R : +List<U32>}
def bdr_app(xs, R):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}: bdr_app(t, R)

law wlen_quad:
  for +ws: +List<U32>
  {FX.wlen(ws) == A.quad(List.length(&2, U32, ws)) : Nat}
def wlen_quad(ws):
  match ws:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, FX.wlen(t), A.quad(List.length(&2, U32, t)), wlen_quad(t)) : {4n+_ == 4n+A.quad(List.length(&2, U32, t)) : Nat}
      {==}

law bt_len:
  for +m: Nat
  for +xs: +List<U32>
  for +h: {Nat.is_le(m, List.length(&2, U32, xs)) == True{} : Bool}
  {List.length(&2, U32, bt(m, xs)) == m : Nat}
def bt_len(m, xs, h):
  match m xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({List.length(&2, U32, bt(1n+p, Nil{})) == 1n+p : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}:
      %bt_len(p, t, h) : {1n+List.length(&2, U32, bt(p, t)) == 1n+_ : Nat}
      {==}

law bdr_bt:
  for +k: Nat
  for +m: Nat
  for +xs: +List<U32>
  {bdr(k, bt(Nat.add(k, m), xs)) == bt(m, bdr(k, xs)) : +List<U32>}
def bdr_bt(k, m, xs):
  match k m xs:
    case 0n +m2 +x2: {==}
    case 1n+ +p 0n Nil{}: {==}
    case 1n+ +p 1n+ +q Nil{}: {==}
    case 1n+ +p +m2 Con{+x, +t}: bdr_bt(p, m2, t)

law bt_bt:
  for +a: Nat
  for +b: Nat
  for +xs: +List<U32>
  {bt(a, bt(Nat.add(a, b), xs)) == bt(a, xs) : +List<U32>}
def bt_bt(a, b, xs):
  match a xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}:
      %bt_bt(p, b, t) : {x <> bt(p, bt(Nat.add(p, b), t)) == x <> _ : +List<U32>}
      {==}

# (as vbuf.bend `wdr`; here so that the byte lemmas need no array import)
def wdr0(n: Nat, W: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: W
    case 1n+p:
      match W:
        case Nil{}: []
        case Con{h, t}: wdr0(p, t)

law bdr_limbs:
  for +k: Nat
  for +W: List<&2, U32>
  {bdr(A.quad(k), FX.limbs(W)) == FX.limbs(wdr0(k, W)) : +List<U32>}
def bdr_limbs(k, W):
  match k W:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: bdr_limbs(p, t)

# ---- inverting the encoding of a list of uint64 --------------------------------------------

def allfix(ps: +List<S.Part>) -> Bool:
  match ps:
    case Nil{}: True{}
    case Con{S.Fixed{xs}, t}: allfix(t)
    case Con{S.Variable{xs}, t}: False{}

def REPF(+its: S.Value, +ps: +List<S.Part>) -> Type:
  {allfix(ps) == True{} : Bool} & {Layout.fixed_size(ps) == x8(Codec.count(its)) : Nat}

def U64S() -> S.Schema: S.Unsigned{P.U64{}}

def rep_len(+P8: +List<U32>, +pb: +List<S.Part>, +t: S.Value, +l8: {List.length(&2, U32, P8) == 8n : Nat},
    +hs: {Layout.fixed_size(pb) == x8(Codec.count(t)) : Nat})
    -> {Nat.add(List.length(&2, U32, P8), Layout.fixed_size(pb)) == 8n+x8(Codec.count(t)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, P8), 8n, l8) : {Nat.add(_, Layout.fixed_size(pb)) == 8n+x8(Codec.count(t)) : Nat}
  %Equal.sym(Nat, Layout.fixed_size(pb), x8(Codec.count(t)), hs) : {8n+_ == 8n+x8(Codec.count(t)) : Nat}
  {==}

def rep_t2(+P8: +List<U32>, +el: S.Value, +t: S.Value, +pb: +List<S.Part>, +l8: {List.length(&2, U32, P8) == 8n : Nat}, r: REPF(t, pb))
    -> REPF(S.Items{el, t}, S.Fixed{P8} <> pb):
  (+ha, +hs) = r
  (ha, rep_len(P8, pb, t, l8, hs))

def rep_t(+P8: +List<U32>, +el: S.Value, +t: S.Value, +ps: +List<S.Part>, +mB: Maybe<&2, +List<S.Part>>,
    +eB: {Codec.parts(t, S.Repeat{U64S()}) == mB : Maybe<&2, +List<S.Part>>},
    +l8: {List.length(&2, U32, P8) == 8n : Nat},
    +e: {Codec.concatenate(Some{[S.Fixed{P8}]}, mB) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pb: +List<S.Part> -> {Codec.parts(t, S.Repeat{U64S()}) == Some{pb} : Maybe<&2, +List<S.Part>>} -> REPF(t, pb))
    -> REPF(S.Items{el, t}, ps):
  match mB:
    case None{}: Empty.absurd(REPF(S.Items{el, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case Some{+pb}:
      +eps = F.logic__some_inj(+List<S.Part>, S.Fixed{P8} <> pb, ps, e)
      %Equal.sym(+List<S.Part>, ps, S.Fixed{P8} <> pb, Equal.sym(+List<S.Part>, S.Fixed{P8} <> pb, ps, eps)) : REPF(S.Items{el, t}, _)
      rep_t2(P8, el, t, pb, l8, ih(pb, eB))


def rep_u(+a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32, +t: S.Value, +ps: +List<S.Part>, +b: Bool,
    +e: {Codec.concatenate(Codec.one(SP.optional(b, SP.prefix(8n, SP.full_digits(P.UInt{a0, a1, a2, a3, a4, a5, a6, a7}))), Some{8n}), Codec.parts(t, S.Repeat{U64S()})) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pb: +List<S.Part> -> {Codec.parts(t, S.Repeat{U64S()}) == Some{pb} : Maybe<&2, +List<S.Part>>} -> REPF(t, pb))
    -> REPF(S.Items{S.UnsignedValue{P.UInt{a0, a1, a2, a3, a4, a5, a6, a7}}, t}, ps):
  match b:
    case False{}: Empty.absurd(REPF(S.Items{S.UnsignedValue{P.UInt{a0, a1, a2, a3, a4, a5, a6, a7}}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case True{}: rep_t(SP.prefix(8n, SP.full_digits(P.UInt{a0, a1, a2, a3, a4, a5, a6, a7})), S.UnsignedValue{P.UInt{a0, a1, a2, a3, a4, a5, a6, a7}}, t, ps, Codec.parts(t, S.Repeat{U64S()}), {==}, {==}, e, ih)

law rep_facts:
  for +its: S.Value
  for +ps: +List<S.Part>
  for +e: {Codec.parts(its, S.Repeat{U64S()}) == Some{ps} : Maybe<&2, +List<S.Part>>}
  REPF(its, ps)
def rep_facts(its, ps, e):
  match its:
    case S.EmptyItems{}:
      +eps = F.logic__some_inj(+List<S.Part>, [], ps, e)
      %Equal.sym(+List<S.Part>, ps, [], Equal.sym(+List<S.Part>, [], ps, eps)) : REPF(S.EmptyItems{}, _)
      ({==}, {==})
    case S.Items{S.UnsignedValue{P.UInt{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}}, +t}:
      rep_u(a0, a1, a2, a3, a4, a5, a6, a7, t, ps, SP.uint_domain(P.U64{}, P.UInt{a0, a1, a2, a3, a4, a5, a6, a7}), e, pb => eb => rep_facts(t, pb, eb))
    case S.BooleanValue{+b}: Empty.absurd(REPF(S.BooleanValue{b}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.UnsignedValue{+u}: Empty.absurd(REPF(S.UnsignedValue{u}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.BytesValue{+xs}: Empty.absurd(REPF(S.BytesValue{xs}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.BitsValue{+bs}: Empty.absurd(REPF(S.BitsValue{bs}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Sequence{+it}: Empty.absurd(REPF(S.Sequence{it}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.BooleanValue{+b}, +t}: Empty.absurd(REPF(S.Items{S.BooleanValue{b}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.BytesValue{+xs}, +t}: Empty.absurd(REPF(S.Items{S.BytesValue{xs}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.BitsValue{+bs}, +t}: Empty.absurd(REPF(S.Items{S.BitsValue{bs}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.Sequence{+it}, +t}: Empty.absurd(REPF(S.Items{S.Sequence{it}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.Items{+hd, +tl}, +t}: Empty.absurd(REPF(S.Items{S.Items{hd, tl}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.EmptyItems{}, +t}: Empty.absurd(REPF(S.Items{S.EmptyItems{}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.Selected{+sel, +sv}, +t}: Empty.absurd(REPF(S.Items{S.Selected{sel, sv}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.NullValue{}, +t}: Empty.absurd(REPF(S.Items{S.NullValue{}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Selected{+sel, +sv}: Empty.absurd(REPF(S.Selected{sel, sv}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case S.NullValue{}: Empty.absurd(REPF(S.NullValue{}, ps), F.logic__none_some(+List<S.Part>, ps, e))

law allfix_pay:
  for +ps: +List<S.Part>
  for +h: {allfix(ps) == True{} : Bool}
  {Layout.payloads(ps) == [] : +List<U32>}
def allfix_pay(ps, h):
  match ps:
    case Nil{}: {==}
    case Con{S.Fixed{+xs}, +t}: allfix_pay(t, h)
    case Con{S.Variable{+xs}, +t}: Empty.absurd({Layout.payloads(S.Variable{xs} <> t) == [] : +List<U32>}, F.logic__false_true(h))

law allfix_fp:
  for +ps: +List<S.Part>
  for +o: Nat
  for +h: {allfix(ps) == True{} : Bool}
  {List.length(&2, U32, Layout.fixed_parts(ps, o)) == Layout.fixed_size(ps) : Nat}
def allfix_fp(ps, o, h):
  match ps:
    case Nil{}: {==}
    case Con{S.Fixed{+xs}, +t}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(t, o))), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, Layout.fixed_parts(t, o))), len_app(xs, Layout.fixed_parts(t, o))) : {_ == Nat.add(List.length(&2, U32, xs), Layout.fixed_size(t)) : Nat}
      %Equal.sym(Nat, List.length(&2, U32, Layout.fixed_parts(t, o)), Layout.fixed_size(t), allfix_fp(t, o, h)) :
        {Nat.add(List.length(&2, U32, xs), _) == Nat.add(List.length(&2, U32, xs), Layout.fixed_size(t)) : Nat}
      {==}
    case Con{S.Variable{+xs}, +t}: Empty.absurd({List.length(&2, U32, Layout.fixed_parts(S.Variable{xs} <> t, o)) == Layout.fixed_size(S.Variable{xs} <> t) : Nat}, F.logic__false_true(h))

def enc_len_go(+ps: +List<S.Part>, +ys: +List<U32>, +h: {allfix(ps) == True{} : Bool}, +b: Bool,
    +e: {SP.optional(b, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps))) == Some{ys} : Maybe<&2, +List<U32>>})
    -> {List.length(&2, U32, ys) == Layout.fixed_size(ps) : Nat}:
  match b:
    case False{}: Empty.absurd({List.length(&2, U32, ys) == Layout.fixed_size(ps) : Nat}, F.logic__none_some(+List<U32>, ys, e))
    case True{}:
      +eys = F.logic__some_inj(+List<U32>, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps)), ys, e)
      %eys : {List.length(&2, U32, _) == Layout.fixed_size(ps) : Nat}
      %Equal.sym(+List<U32>, Layout.payloads(ps), [], allfix_pay(ps, h)) : {List.length(&2, U32, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), _)) == Layout.fixed_size(ps) : Nat}
      %Equal.sym(+List<U32>, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), []), Layout.fixed_parts(ps, Layout.fixed_size(ps)), app_nil(Layout.fixed_parts(ps, Layout.fixed_size(ps)))) :
        {List.length(&2, U32, _) == Layout.fixed_size(ps) : Nat}
      allfix_fp(ps, Layout.fixed_size(ps), h)

# The layout of all-fixed parts has their total size.
def enc_len(+ps: +List<S.Part>, +ys: +List<U32>, +h: {allfix(ps) == True{} : Bool},
    +e: {Layout.encoding(ps) == Some{ys} : Maybe<&2, +List<U32>>})
    -> {List.length(&2, U32, ys) == Layout.fixed_size(ps) : Nat}:
  enc_len_go(ps, ys, h, Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(Layout.fixed_size(ps), List.length(&2, U32, Layout.payloads(ps))))), e)

# ---- a container of fixed fields of words around ONE variable field ---------------------------

def fpv(+pre: +List<+List<U32>>, +Y: +List<U32>, +post: +List<+List<U32>>) -> +List<S.Part>:
  List.append(&2, S.Part, FX.fparts(pre), Con{S.Variable{Y}, FX.fparts(post)})

law fpv_size:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.fixed_size(fpv(pre, Y, post)) == Nat.add(List.length(&2, U32, FX.flat(pre)), 4n+List.length(&2, U32, FX.flat(post))) : Nat}
def fpv_size(pre, Y, post):
  match pre:
    case Nil{}:
      %Equal.sym(Nat, Layout.fixed_size(FX.fparts(post)), List.length(&2, U32, FX.flat(post)), fixed_size_fparts(post)) : {4n+_ == 4n+List.length(&2, U32, FX.flat(post)) : Nat}
      {==}
    case Con{+ws, +t}:
      %Equal.sym(Nat, Layout.fixed_size(fpv(t, Y, post)), Nat.add(List.length(&2, U32, FX.flat(t)), 4n+List.length(&2, U32, FX.flat(post))), fpv_size(t, Y, post)) :
        {Nat.add(List.length(&2, U32, FX.limbs(ws)), _) == Nat.add(List.length(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t))), 4n+List.length(&2, U32, FX.flat(post))) : Nat}
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t))), Nat.add(List.length(&2, U32, FX.limbs(ws)), List.length(&2, U32, FX.flat(t))), len_app(FX.limbs(ws), FX.flat(t))) :
        {Nat.add(List.length(&2, U32, FX.limbs(ws)), Nat.add(List.length(&2, U32, FX.flat(t)), 4n+List.length(&2, U32, FX.flat(post)))) == Nat.add(_, 4n+List.length(&2, U32, FX.flat(post))) : Nat}
      Equal.sym(Nat, Nat.add(Nat.add(List.length(&2, U32, FX.limbs(ws)), List.length(&2, U32, FX.flat(t))), 4n+List.length(&2, U32, FX.flat(post))),
        Nat.add(List.length(&2, U32, FX.limbs(ws)), Nat.add(List.length(&2, U32, FX.flat(t)), 4n+List.length(&2, U32, FX.flat(post)))),
        F.nat__add_assoc(List.length(&2, U32, FX.limbs(ws)), List.length(&2, U32, FX.flat(t)), 4n+List.length(&2, U32, FX.flat(post))))

law fpv_pay:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.payloads(fpv(pre, Y, post)) == List.append(&2, U32, Y, []) : +List<U32>}
def fpv_pay(pre, Y, post):
  match pre:
    case Nil{}:
      %Equal.sym(+List<U32>, Layout.payloads(FX.fparts(post)), [], payloads_fparts(post)) : {List.append(&2, U32, Y, _) == List.append(&2, U32, Y, []) : +List<U32>}
      {==}
    case Con{+ws, +t}: fpv_pay(t, Y, post)

law fpv_fp:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  for +off: Nat
  {Layout.fixed_parts(fpv(pre, Y, post), off) == List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, off), FX.flat(post))) : +List<U32>}
def fpv_fp(pre, Y, post, off):
  match pre:
    case Nil{}:
      %Equal.sym(+List<U32>, Layout.fixed_parts(FX.fparts(post), Nat.add(off, List.length(&2, U32, Y))), FX.flat(post), fixed_parts_fparts(post, Nat.add(off, List.length(&2, U32, Y)))) : {List.append(&2, U32, N.digits(4n, off), _) == List.append(&2, U32, N.digits(4n, off), FX.flat(post)) : +List<U32>}
      {==}
    case Con{+ws, +t}:
      %Equal.sym(+List<U32>, Layout.fixed_parts(fpv(t, Y, post), off), List.append(&2, U32, FX.flat(t), List.append(&2, U32, N.digits(4n, off), FX.flat(post))), fpv_fp(t, Y, post, off)) : {List.append(&2, U32, FX.limbs(ws), _) == List.append(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t)), List.append(&2, U32, N.digits(4n, off), FX.flat(post))) : +List<U32>}
      Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t)), List.append(&2, U32, N.digits(4n, off), FX.flat(post))),
        List.append(&2, U32, FX.limbs(ws), List.append(&2, U32, FX.flat(t), List.append(&2, U32, N.digits(4n, off), FX.flat(post)))),
        app_assoc(FX.limbs(ws), FX.flat(t), List.append(&2, U32, N.digits(4n, off), FX.flat(post))))

law fpv_valid:
  for +pre: +List<+List<U32>>
  for +Ys: List<&2, U32>
  for +post: +List<+List<U32>>
  {Layout.bytes_valid(fpv(pre, FX.limbs(Ys), post)) == True{} : Bool}
def fpv_valid(pre, Ys, post):
  match pre:
    case Nil{}: V.and_true(SP.bytes_domain(FX.limbs(Ys)), Layout.bytes_valid(FX.fparts(post)), FX.domain_limbs(Ys), FX.valid_fparts(post))
    case Con{+ws, +t}: V.and_true(SP.bytes_domain(FX.limbs(ws)), Layout.bytes_valid(fpv(t, FX.limbs(Ys), post)), FX.domain_limbs(ws), fpv_valid(t, Ys, post))

def enc_go(+pre: +List<+List<U32>>, +Ys: List<&2, U32>, +post: +List<+List<U32>>, +b: Bool,
    +eb: {N.fits(4n, Nat.add(Layout.fixed_size(fpv(pre, FX.limbs(Ys), post)), List.length(&2, U32, Layout.payloads(fpv(pre, FX.limbs(Ys), post))))) == b : Bool},
    +fit: {b == True{} : Bool})
    -> {Layout.encoding(fpv(pre, FX.limbs(Ys), post)) == Some{List.append(&2, U32, Layout.fixed_parts(fpv(pre, FX.limbs(Ys), post), Layout.fixed_size(fpv(pre, FX.limbs(Ys), post))), Layout.payloads(fpv(pre, FX.limbs(Ys), post)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, Layout.bytes_valid(fpv(pre, FX.limbs(Ys), post)), True{}, fpv_valid(pre, Ys, post)) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(Layout.fixed_size(fpv(pre, FX.limbs(Ys), post)), List.length(&2, U32, Layout.payloads(fpv(pre, FX.limbs(Ys), post)))))), List.append(&2, U32, Layout.fixed_parts(fpv(pre, FX.limbs(Ys), post), Layout.fixed_size(fpv(pre, FX.limbs(Ys), post))), Layout.payloads(fpv(pre, FX.limbs(Ys), post)))) == Some{List.append(&2, U32, Layout.fixed_parts(fpv(pre, FX.limbs(Ys), post), Layout.fixed_size(fpv(pre, FX.limbs(Ys), post))), Layout.payloads(fpv(pre, FX.limbs(Ys), post)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(Layout.fixed_size(fpv(pre, FX.limbs(Ys), post)), List.length(&2, U32, Layout.payloads(fpv(pre, FX.limbs(Ys), post))))), True{}, Equal.trans(Bool, N.fits(4n, Nat.add(Layout.fixed_size(fpv(pre, FX.limbs(Ys), post)), List.length(&2, U32, Layout.payloads(fpv(pre, FX.limbs(Ys), post))))), b, True{}, eb, fit)) :
    {SP.optional(Bool.and(True{}, _), List.append(&2, U32, Layout.fixed_parts(fpv(pre, FX.limbs(Ys), post), Layout.fixed_size(fpv(pre, FX.limbs(Ys), post))), Layout.payloads(fpv(pre, FX.limbs(Ys), post)))) == Some{List.append(&2, U32, Layout.fixed_parts(fpv(pre, FX.limbs(Ys), post), Layout.fixed_size(fpv(pre, FX.limbs(Ys), post))), Layout.payloads(fpv(pre, FX.limbs(Ys), post)))} : Maybe<&2, +List<U32>>}
  {==}
