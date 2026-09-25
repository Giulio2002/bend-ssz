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
