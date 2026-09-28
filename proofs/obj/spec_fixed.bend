import Base
import ../../src/primitives.bend as I
import ../../src/buffer.bend as B
import ../../spec/primitives.bend as SP
import ../../spec/bytes.bend as Bytes
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/schema.bend as SS
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../proofs/primitive_invariants.bend as V
import ../../proofs/word_facts.bend as W
import ../../proofs/integer_encoding.bend as IE

# Spec-side facts about fixed-size encodings built from whole 32-bit words.
#
# The generated object API stores every whole-word leaf as U32 words and emits
# word w as its four little-endian bytes `I.limb(w)`. The laws here say what
# the INDEPENDENT specification (spec/codec.bend, spec/layout.bend) makes of
# such byte strings: a byte vector of words is in the byte domain, an unsigned
# integer of words encodes to the limbs of its words, and a container or vector
# of fixed parts encodes to their concatenation. proofs/obj/spec_codec_*.bend
# combine them, name by name, with the generated encoders and decoders.

def limbs(ws: +List<U32>) -> +List<U32>:
  match ws:
    case Nil{}: []
    case Con{h, t}: List.append(&2, U32, I.limb(h), limbs(t))

def wlen(ws: +List<U32>) -> Nat:
  match ws:
    case Nil{}: 0n
    case Con{h, t}: 1n+1n+1n+1n+wlen(t)

law scope_limbs:
  for +ws: +List<U32>
  {SP.byte_scope(wlen(ws), limbs(ws)) == True{} : Bool}
def scope_limbs(ws):
  match ws:
    case Nil{}: {==}
    case Con{h, t}:
      V.and_true(U32.is_lt(U32.and(h, 255), 256),
        SP.byte_scope(1n+1n+1n+wlen(t), U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> limbs(t)),
        W.masked_byte_bound(h),
        V.and_true(U32.is_lt(U32.and(U32.shrn(h, 8n), 255), 256),
          SP.byte_scope(1n+1n+wlen(t), U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> limbs(t)),
          W.masked_byte_bound(U32.shrn(h, 8n)),
          V.and_true(U32.is_lt(U32.and(U32.shrn(h, 16n), 255), 256),
            SP.byte_scope(1n+wlen(t), U32.shrn(h, 24n) <> limbs(t)),
            W.masked_byte_bound(U32.shrn(h, 16n)),
            V.and_true(U32.is_lt(U32.shrn(h, 24n), 256), SP.byte_scope(wlen(t), limbs(t)),
              W.shifted_byte_bound(h), scope_limbs(t)))))

law domain_limbs:
  for +ws: +List<U32>
  {SP.bytes_domain(limbs(ws)) == True{} : Bool}
def domain_limbs(ws):
  match ws:
    case Nil{}: {==}
    case Con{h, t}: V.append_domain(I.limb(h), limbs(t), V.limb_domain(h), domain_limbs(t))

# ---- leaves ----------------------------------------------------------------

# A byte vector whose bytes are the limbs of a nonempty word list.
law bytes_part:
  for +h: U32
  for +t: +List<U32>
  for fit: {Bytes.size_fits(wlen(h <> t)) == True{} : Bool}
  {Codec.parts(S.BytesValue{limbs(h <> t)}, S.ByteVector{wlen(h <> t)}) == Some{[S.Fixed{limbs(h <> t)}]} : Maybe<&2, +List<S.Part>>}
def bytes_part(h, t, fit):
  %Equal.sym(Bool, SP.byte_scope(wlen(h <> t), limbs(h <> t)), True{}, scope_limbs(h <> t)) :
    {Codec.one(SP.optional(Bool.and(_, Bytes.size_fits(wlen(h <> t))), limbs(h <> t)), Some{wlen(h <> t)}) == Some{[S.Fixed{limbs(h <> t)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Bytes.size_fits(wlen(h <> t)), True{}, fit) :
    {Codec.one(SP.optional(Bool.and(True{}, _), limbs(h <> t)), Some{wlen(h <> t)}) == Some{[S.Fixed{limbs(h <> t)}]} : Maybe<&2, +List<S.Part>>}
  {==}

# The same with the vector length as the enclosing schema states it.
law bytes_part_n:
  for +h: U32
  for +t: +List<U32>
  for +n: Nat
  for en: {n == wlen(h <> t) : Nat}
  for fit: {Bytes.size_fits(wlen(h <> t)) == True{} : Bool}
  {Codec.parts(S.BytesValue{limbs(h <> t)}, S.ByteVector{n}) == Some{[S.Fixed{limbs(h <> t)}]} : Maybe<&2, +List<S.Part>>}
def bytes_part_n(h, t, n, en, fit):
  %Equal.sym(Nat, n, wlen(h <> t), en) :
    {Codec.parts(S.BytesValue{limbs(h <> t)}, S.ByteVector{_}) == Some{[S.Fixed{limbs(h <> t)}]} : Maybe<&2, +List<S.Part>>}
  bytes_part(h, t, fit)

# ---- unsigned integers: the zero high limbs --------------------------------
# The generic forms uintN_g take the high limbs as variables with the fact that their bytes are zero
# (zeroK, via limb0), so the conversions stay stuck on variables instead of evaluating
# I.limb(0)'s U32 ops on literal words; ap spells List.append without the &2 argument (Bend's
# syntactic shortcut stops at a quantity), so zeroK matches its use syntactically.
def ap(xs: +List<U32>, ys: +List<U32>) -> +List<U32>: List.append(&2, U32, xs, ys)

law limb0:
  {I.limb(0) == [0, 0, 0, 0] : +List<U32>}
def limb0(): {==}

law zero7:
  {I.all_zero(ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), I.limb(0)))))))) == True{} : Bool}
def zero7():
  %Equal.sym(+List<U32>, I.limb(0), [0, 0, 0, 0], limb0()) : {I.all_zero(ap(_, ap(_, ap(_, ap(_, ap(_, ap(_, _))))))) == True{} : Bool}
  {==}

law uint32_g:
  for +x0: U32
  for +z1: U32
  for +z2: U32
  for +z3: U32
  for +z4: U32
  for +z5: U32
  for +z6: U32
  for +z7: U32
  for +hz: {I.all_zero(ap(I.limb(z1), ap(I.limb(z2), ap(I.limb(z3), ap(I.limb(z4), ap(I.limb(z5), ap(I.limb(z6), I.limb(z7)))))))) == True{} : Bool}
  {Codec.parts(S.UnsignedValue{P.UInt{x0, z1, z2, z3, z4, z5, z6, z7}}, S.Unsigned{P.U32Width{}}) == Some{[S.Fixed{limbs([x0])}]} : Maybe<&2, +List<S.Part>>}
def uint32_g(x0, z1, z2, z3, z4, z5, z6, z7, hz):
  %IE.uint_serialize_correct(P.U32Width{}, P.UInt{x0, z1, z2, z3, z4, z5, z6, z7}) :
    {Codec.one(_, Some{SP.byte_width(P.U32Width{})}) == Some{[S.Fixed{limbs([x0])}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, I.all_zero(ap(I.limb(z1), ap(I.limb(z2), ap(I.limb(z3), ap(I.limb(z4), ap(I.limb(z5), ap(I.limb(z6), I.limb(z7)))))))), True{}, hz) :
    {Codec.one(I.prepend(U32.and(x0, 255), I.prepend(U32.and(U32.shrn(x0, 8n), 255), I.prepend(U32.and(U32.shrn(x0, 16n), 255), I.prepend(U32.shrn(x0, 24n), I.accept_bytes(_, []))))), Some{SP.byte_width(P.U32Width{})}) == Some{[S.Fixed{limbs([x0])}]} : Maybe<&2, +List<S.Part>>}
  {==}

law zero6:
  {I.all_zero(ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), I.limb(0))))))) == True{} : Bool}
def zero6():
  %Equal.sym(+List<U32>, I.limb(0), [0, 0, 0, 0], limb0()) : {I.all_zero(ap(_, ap(_, ap(_, ap(_, ap(_, _)))))) == True{} : Bool}
  {==}

law uint64_g:
  for +x0: U32
  for +x1: U32
  for +z2: U32
  for +z3: U32
  for +z4: U32
  for +z5: U32
  for +z6: U32
  for +z7: U32
  for +hz: {I.all_zero(ap(I.limb(z2), ap(I.limb(z3), ap(I.limb(z4), ap(I.limb(z5), ap(I.limb(z6), I.limb(z7))))))) == True{} : Bool}
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, z2, z3, z4, z5, z6, z7}}, S.Unsigned{P.U64{}}) == Some{[S.Fixed{limbs([x0, x1])}]} : Maybe<&2, +List<S.Part>>}
def uint64_g(x0, x1, z2, z3, z4, z5, z6, z7, hz):
  %IE.uint_serialize_correct(P.U64{}, P.UInt{x0, x1, z2, z3, z4, z5, z6, z7}) :
    {Codec.one(_, Some{SP.byte_width(P.U64{})}) == Some{[S.Fixed{limbs([x0, x1])}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, I.all_zero(ap(I.limb(z2), ap(I.limb(z3), ap(I.limb(z4), ap(I.limb(z5), ap(I.limb(z6), I.limb(z7))))))), True{}, hz) :
    {Codec.one(I.prepend(U32.and(x0, 255), I.prepend(U32.and(U32.shrn(x0, 8n), 255), I.prepend(U32.and(U32.shrn(x0, 16n), 255), I.prepend(U32.shrn(x0, 24n), I.prepend(U32.and(x1, 255), I.prepend(U32.and(U32.shrn(x1, 8n), 255), I.prepend(U32.and(U32.shrn(x1, 16n), 255), I.prepend(U32.shrn(x1, 24n), I.accept_bytes(_, []))))))))), Some{SP.byte_width(P.U64{})}) == Some{[S.Fixed{limbs([x0, x1])}]} : Maybe<&2, +List<S.Part>>}
  {==}

law zero4:
  {I.all_zero(ap(I.limb(0), ap(I.limb(0), ap(I.limb(0), I.limb(0))))) == True{} : Bool}
def zero4():
  %Equal.sym(+List<U32>, I.limb(0), [0, 0, 0, 0], limb0()) : {I.all_zero(ap(_, ap(_, ap(_, _)))) == True{} : Bool}
  {==}

law uint128_g:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +z4: U32
  for +z5: U32
  for +z6: U32
  for +z7: U32
  for +hz: {I.all_zero(ap(I.limb(z4), ap(I.limb(z5), ap(I.limb(z6), I.limb(z7))))) == True{} : Bool}
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, x2, x3, z4, z5, z6, z7}}, S.Unsigned{P.U128{}}) == Some{[S.Fixed{limbs([x0, x1, x2, x3])}]} : Maybe<&2, +List<S.Part>>}
def uint128_g(x0, x1, x2, x3, z4, z5, z6, z7, hz):
  %IE.uint_serialize_correct(P.U128{}, P.UInt{x0, x1, x2, x3, z4, z5, z6, z7}) :
    {Codec.one(_, Some{SP.byte_width(P.U128{})}) == Some{[S.Fixed{limbs([x0, x1, x2, x3])}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, I.all_zero(ap(I.limb(z4), ap(I.limb(z5), ap(I.limb(z6), I.limb(z7))))), True{}, hz) :
    {Codec.one(I.prepend(U32.and(x0, 255), I.prepend(U32.and(U32.shrn(x0, 8n), 255), I.prepend(U32.and(U32.shrn(x0, 16n), 255), I.prepend(U32.shrn(x0, 24n), I.prepend(U32.and(x1, 255), I.prepend(U32.and(U32.shrn(x1, 8n), 255), I.prepend(U32.and(U32.shrn(x1, 16n), 255), I.prepend(U32.shrn(x1, 24n), I.prepend(U32.and(x2, 255), I.prepend(U32.and(U32.shrn(x2, 8n), 255), I.prepend(U32.and(U32.shrn(x2, 16n), 255), I.prepend(U32.shrn(x2, 24n), I.prepend(U32.and(x3, 255), I.prepend(U32.and(U32.shrn(x3, 8n), 255), I.prepend(U32.and(U32.shrn(x3, 16n), 255), I.prepend(U32.shrn(x3, 24n), I.accept_bytes(_, []))))))))))))))))), Some{SP.byte_width(P.U128{})}) == Some{[S.Fixed{limbs([x0, x1, x2, x3])}]} : Maybe<&2, +List<S.Part>>}
  {==}

law uint32_part:
  for +x0: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U32Width{}}) == Some{[S.Fixed{limbs([x0])}]} : Maybe<&2, +List<S.Part>>}
def uint32_part(x0):
  uint32_g(x0, 0, 0, 0, 0, 0, 0, 0, zero7())

law uint64_part:
  for +x0: U32
  for +x1: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U64{}}) == Some{[S.Fixed{limbs([x0, x1])}]} : Maybe<&2, +List<S.Part>>}
def uint64_part(x0, x1):
  uint64_g(x0, x1, 0, 0, 0, 0, 0, 0, zero6())

law uint128_part:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, x2, x3, 0, 0, 0, 0}}, S.Unsigned{P.U128{}}) == Some{[S.Fixed{limbs([x0, x1, x2, x3])}]} : Maybe<&2, +List<S.Part>>}
def uint128_part(x0, x1, x2, x3):
  uint128_g(x0, x1, x2, x3, 0, 0, 0, 0, zero4())

law uint256_part:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, x2, x3, x4, x5, x6, x7}}, S.Unsigned{P.U256{}}) == Some{[S.Fixed{limbs([x0, x1, x2, x3, x4, x5, x6, x7])}]} : Maybe<&2, +List<S.Part>>}
def uint256_part(x0, x1, x2, x3, x4, x5, x6, x7):
  %IE.uint_serialize_correct(P.U256{}, P.UInt{x0, x1, x2, x3, x4, x5, x6, x7}) :
    {Codec.one(_, Some{SP.byte_width(P.U256{})}) == Some{[S.Fixed{limbs([x0, x1, x2, x3, x4, x5, x6, x7])}]} : Maybe<&2, +List<S.Part>>}
  {==}

# ---- composition -------------------------------------------------------------

# One fixed part in front of the parts of the rest.
law cat_fixed:
  for a: Maybe<&2, +List<S.Part>>
  for +xs: +List<U32>
  for b: Maybe<&2, +List<S.Part>>
  for +rest: +List<S.Part>
  for ea: {a == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}
  for eb: {b == Some{rest} : Maybe<&2, +List<S.Part>>}
  {Codec.concatenate(a, b) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}
def cat_fixed(a, xs, b, rest, ea, eb):
  %Equal.sym(Maybe<&2, +List<S.Part>>, a, Some{[S.Fixed{xs}]}, ea) :
    {Codec.concatenate(_, b) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, b, Some{rest}, eb) :
    {Codec.concatenate(Some{[S.Fixed{xs}]}, _) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}
  {==}

def fparts(wss: +List<+List<U32>>) -> +List<S.Part>:
  match wss:
    case Nil{}: []
    case Con{ws, t}: S.Fixed{limbs(ws)} <> fparts(t)

def flat(wss: +List<+List<U32>>) -> +List<U32>:
  match wss:
    case Nil{}: []
    case Con{ws, t}: List.append(&2, U32, limbs(ws), flat(t))

law valid_fparts:
  for +wss: +List<+List<U32>>
  {Layout.bytes_valid(fparts(wss)) == True{} : Bool}
def valid_fparts(wss):
  match wss:
    case Nil{}: {==}
    case Con{ws, t}: V.and_true(SP.bytes_domain(limbs(ws)), Layout.bytes_valid(fparts(t)), domain_limbs(ws), valid_fparts(t))

# The aggregate of fixed parts of words, at a width the concrete sites compute.
# `total` is the offset formula's size check, a closed computation there.
law aggregate_fixed:
  for a: Maybe<&2, +List<S.Part>>
  for +wss: +List<+List<U32>>
  for +n: Nat
  for ea: {a == Some{fparts(wss)} : Maybe<&2, +List<S.Part>>}
  for total: {Codec.one(Layout.encoding(fparts(wss)), Some{n}) == Codec.one(SP.optional(Bool.and(Layout.bytes_valid(fparts(wss)), True{}), flat(wss)), Some{n}) : Maybe<&2, +List<S.Part>>}
  {Codec.aggregate(a, Some{n}) == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
def aggregate_fixed(a, wss, n, ea, total):
  %Equal.sym(Maybe<&2, +List<S.Part>>, a, Some{fparts(wss)}, ea) :
    {Codec.aggregate(_, Some{n}) == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.one(Layout.encoding(fparts(wss)), Some{n}), Codec.one(SP.optional(Bool.and(Layout.bytes_valid(fparts(wss)), True{}), flat(wss)), Some{n}), total) :
    {_ == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Layout.bytes_valid(fparts(wss)), True{}, valid_fparts(wss)) :
    {Codec.one(SP.optional(Bool.and(_, True{}), flat(wss)), Some{n}) == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
  {==}

# ---- composition in the exact form of the parts terms ------------------------
# The generated spec_parts proofs chain these so that every hypothesis already
# has the syntactic form the enclosing Codec.parts term unfolds to; the checker
# then never evaluates the spec encoders of the leaves to compare two forms.

def wcat(wss: +List<+List<U32>>) -> +List<U32>:
  match wss:
    case Nil{}: []
    case Con{ws, t}: List.append(&2, U32, ws, wcat(t))

law limbs_append:
  for +a: +List<U32>
  for +b: +List<U32>
  {limbs(List.append(&2, U32, a, b)) == List.append(&2, U32, limbs(a), limbs(b)) : +List<U32>}
def limbs_append(a, b):
  match a:
    case Nil{}: {==}
    case Con{h, t}:
      Equal.cong(+List<U32>, +List<U32>, r => List.append(&2, U32, I.limb(h), r),
        limbs(List.append(&2, U32, t, b)), List.append(&2, U32, limbs(t), limbs(b)), limbs_append(t, b))

law limbs_flat:
  for +wss: +List<+List<U32>>
  {limbs(wcat(wss)) == flat(wss) : +List<U32>}
def limbs_flat(wss):
  match wss:
    case Nil{}: {==}
    case Con{ws, t}:
      %Equal.sym(+List<U32>, limbs(List.append(&2, U32, ws, wcat(t))), List.append(&2, U32, limbs(ws), limbs(wcat(t))), limbs_append(ws, wcat(t))) :
        {_ == List.append(&2, U32, limbs(ws), flat(t)) : +List<U32>}
      Equal.cong(+List<U32>, +List<U32>, r => List.append(&2, U32, limbs(ws), r), limbs(wcat(t)), flat(t), limbs_flat(t))

# A field in front of the remaining fields.
law items_fixed:
  for +h: S.Value
  for +t: S.Value
  for +s: S.Schema
  for +rest: S.Schema
  for +xs: +List<U32>
  for +ps: +List<S.Part>
  for ea: {Codec.parts(h, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}
  for eb: {Codec.parts(t, rest) == Some{ps} : Maybe<&2, +List<S.Part>>}
  {Codec.parts(S.Items{h, t}, S.Chain{s, rest}) == Some{S.Fixed{xs} <> ps} : Maybe<&2, +List<S.Part>>}
def items_fixed(h, t, s, rest, xs, ps, ea, eb):
  cat_fixed(Codec.parts(h, s), xs, Codec.parts(t, rest), ps, ea, eb)

# An element in front of the remaining elements of a vector.
law items_rep:
  for +h: S.Value
  for +t: S.Value
  for +s: S.Schema
  for +xs: +List<U32>
  for +ps: +List<S.Part>
  for ea: {Codec.parts(h, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}
  for eb: {Codec.parts(t, S.Repeat{s}) == Some{ps} : Maybe<&2, +List<S.Part>>}
  {Codec.parts(S.Items{h, t}, S.Repeat{s}) == Some{S.Fixed{xs} <> ps} : Maybe<&2, +List<S.Part>>}
def items_rep(h, t, s, xs, ps, ea, eb):
  cat_fixed(Codec.parts(h, s), xs, Codec.parts(t, S.Repeat{s}), ps, ea, eb)

# A container of fixed fields whose words, in order, are ws.
law container_fixed:
  for +names: +List<String>
  for +fields: S.Schema
  for +items: S.Value
  for +wss: +List<+List<U32>>
  for +n: Nat
  for +ws: +List<U32>
  for ea: {Codec.parts(items, fields) == Some{fparts(wss)} : Maybe<&2, +List<S.Part>>}
  for en: {SS.fixed_size(fields) == Some{n} : Maybe<&2, Nat>}
  for total: {Codec.one(Layout.encoding(fparts(wss)), Some{n}) == Codec.one(SP.optional(Bool.and(Layout.bytes_valid(fparts(wss)), True{}), flat(wss)), Some{n}) : Maybe<&2, +List<S.Part>>}
  for ew: {ws == wcat(wss) : +List<U32>}
  {Codec.parts(S.Sequence{items}, S.Container{names, fields}) == Some{[S.Fixed{limbs(ws)}]} : Maybe<&2, +List<S.Part>>}
def container_fixed(names, fields, items, wss, n, ws, ea, en, total, ew):
  %Equal.sym(+List<U32>, ws, wcat(wss), ew) :
    {Codec.parts(S.Sequence{items}, S.Container{names, fields}) == Some{[S.Fixed{limbs(_)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, limbs(wcat(wss)), flat(wss), limbs_flat(wss)) :
    {Codec.parts(S.Sequence{items}, S.Container{names, fields}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(fields), Some{n}, en) :
    {Codec.aggregate(Codec.parts(items, fields), _) == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
  aggregate_fixed(Codec.parts(items, fields), wss, n, ea, total)

# A vector of k fixed elements whose words, in order, are ws.
law vector_fixed:
  for +s: S.Schema
  for +k: Nat
  for +items: S.Value
  for +wss: +List<+List<U32>>
  for +n: Nat
  for +ws: +List<U32>
  for ea: {Codec.parts(items, S.Repeat{s}) == Some{fparts(wss)} : Maybe<&2, +List<S.Part>>}
  for ek: {Bool.and(Nat.is_lt(0n, k), Nat.is_eq(Codec.count(items), k)) == True{} : Bool}
  for en: {SS.times(k, SS.fixed_size(s)) == Some{n} : Maybe<&2, Nat>}
  for total: {Codec.one(Layout.encoding(fparts(wss)), Some{n}) == Codec.one(SP.optional(Bool.and(Layout.bytes_valid(fparts(wss)), True{}), flat(wss)), Some{n}) : Maybe<&2, +List<S.Part>>}
  for ew: {ws == wcat(wss) : +List<U32>}
  {Codec.parts(S.Sequence{items}, S.Vector{s, k}) == Some{[S.Fixed{limbs(ws)}]} : Maybe<&2, +List<S.Part>>}
def vector_fixed(s, k, items, wss, n, ws, ea, ek, en, total, ew):
  %Equal.sym(+List<U32>, ws, wcat(wss), ew) :
    {Codec.parts(S.Sequence{items}, S.Vector{s, k}) == Some{[S.Fixed{limbs(_)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, limbs(wcat(wss)), flat(wss), limbs_flat(wss)) :
    {Codec.parts(S.Sequence{items}, S.Vector{s, k}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Bool.and(Nat.is_lt(0n, k), Nat.is_eq(Codec.count(items), k)), True{}, ek) :
    {Codec.require(_, Codec.aggregate(Codec.parts(items, S.Repeat{s}), SS.times(k, SS.fixed_size(s)))) == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, Nat>, SS.times(k, SS.fixed_size(s)), Some{n}, en) :
    {Codec.aggregate(Codec.parts(items, S.Repeat{s}), _) == Some{[S.Fixed{flat(wss)}]} : Maybe<&2, +List<S.Part>>}
  aggregate_fixed(Codec.parts(items, S.Repeat{s}), wss, n, ea, total)

# The top-level encoding from the parts of a fixed value.
law encoding_of_parts:
  for +schema: S.Schema
  for +value: S.Value
  for +xs: +List<U32>
  for e: {Codec.parts(value, schema) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}
  {Codec.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def encoding_of_parts(schema, value, xs, e):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(value, schema), Some{[S.Fixed{xs}]}, e) :
    {Codec.bytes(_) == Some{xs} : Maybe<&2, +List<U32>>}
  {==}

# The same for one variable part (a variable-size value): stated over variables, so a
# caller's schema and value are never compared with the spec encoder by evaluation.
law encoding_of_var:
  for +schema: S.Schema
  for +value: S.Value
  for +xs: +List<U32>
  for e: {Codec.parts(value, schema) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  {Codec.encoding_for_legal_type(schema, value) == Some{xs} : Maybe<&2, +List<U32>>}
def encoding_of_var(schema, value, xs, e):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(value, schema), Some{[S.Variable{xs}]}, e) :
    {Codec.bytes(_) == Some{xs} : Maybe<&2, +List<U32>>}
  {==}

# The spec encoding is the bytes of the parts, over variables (an instance at a large value
# is then a substitution: the checker compares no encoder runs).
law efl_bytes:
  for +schema: S.Schema
  for +value: S.Value
  {Codec.bytes(Codec.parts(value, schema)) == Codec.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}
def efl_bytes(schema, value):
  {==}

# ---- the bytes of an encoder whose object is not duplicable ------------------

# An encoder of a `Type`-kind object (one holding boxed children) hands the
# object back with the fresh buffer; these views list the emitted bytes and
# consume the buffer (B.drop reads every word, so nothing is left unforced).
def keep(+x: U32, xs: +List<U32>) -> +List<U32>: xs

def listed(pair: B.Buf & +List<U32>) -> +List<U32>:
  (b, xs) = pair
  keep(B.drop(b), xs)

def emitted(-A: Type, p: A & B.Buf, +nw: U32) -> A & +List<U32>:
  (o, b) = p
  (o, listed(B.emit(b, 0, nw)))
