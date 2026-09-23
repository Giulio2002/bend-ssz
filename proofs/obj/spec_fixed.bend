import Base
import ../../src/primitives.bend as I
import ../../src/buffer.bend as B
import ../../spec/primitives.bend as SP
import ../../spec/bytes.bend as Bytes
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
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

law uint32_part:
  for +x0: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U32Width{}}) == Some{[S.Fixed{limbs([x0])}]} : Maybe<&2, +List<S.Part>>}
def uint32_part(x0):
  %IE.uint_serialize_correct(P.U32Width{}, P.UInt{x0, 0, 0, 0, 0, 0, 0, 0}) :
    {Codec.one(_, Some{SP.byte_width(P.U32Width{})}) == Some{[S.Fixed{limbs([x0])}]} : Maybe<&2, +List<S.Part>>}
  {==}

law uint64_part:
  for +x0: U32
  for +x1: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U64{}}) == Some{[S.Fixed{limbs([x0, x1])}]} : Maybe<&2, +List<S.Part>>}
def uint64_part(x0, x1):
  %IE.uint_serialize_correct(P.U64{}, P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}) :
    {Codec.one(_, Some{SP.byte_width(P.U64{})}) == Some{[S.Fixed{limbs([x0, x1])}]} : Maybe<&2, +List<S.Part>>}
  {==}

law uint128_part:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  {Codec.parts(S.UnsignedValue{P.UInt{x0, x1, x2, x3, 0, 0, 0, 0}}, S.Unsigned{P.U128{}}) == Some{[S.Fixed{limbs([x0, x1, x2, x3])}]} : Maybe<&2, +List<S.Part>>}
def uint128_part(x0, x1, x2, x3):
  %IE.uint_serialize_correct(P.U128{}, P.UInt{x0, x1, x2, x3, 0, 0, 0, 0}) :
    {Codec.one(_, Some{SP.byte_width(P.U128{})}) == Some{[S.Fixed{limbs([x0, x1, x2, x3])}]} : Maybe<&2, +List<S.Part>>}
  {==}

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
