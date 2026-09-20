import Base
import ../src/packed.bend as P
import ./walk.bend as W
import ./lists.bend as L
import ./packing.bend as Pack
import ./word_facts.bend as F
import ../src/primitives.bend as IP
import ../types/primitive.bend as Primitive

# Packed byte storage denotes exactly one byte list.
#
# `P.slice_bytes` is that denotation. Every lemma here relates an operation on
# packed storage (sub-slicing, advancing, reading a byte) to the corresponding
# operation on the denoted byte list, so the decoder proofs can reason purely
# about byte lists while the runtime moves chunk records.

# ---------------------------------------------------------------------------
# Byte-list algebra used by the slice lemmas.
# ---------------------------------------------------------------------------
# Nat.min is a pick on a comparison; these reduce it structurally.
law min_zero:
  for +b: Nat
  {Nat.min(0n, b) == 0n : Nat}
def min_zero(b):
  match b:
    case 0n: {==}
    case 1n+q: {==}

law min_right_zero:
  for +a: Nat
  {Nat.min(a, 0n) == 0n : Nat}
def min_right_zero(a):
  match a:
    case 0n: {==}
    case 1n+p: {==}

law min_pick:
  for +lt: Bool
  for +a: Nat
  for +b: Nat
  {Bool.pick(Nat, lt, 1n+a, 1n+b) == 1n+Bool.pick(Nat, lt, a, b) : Nat}
def min_pick(lt, a, b):
  match lt:
    case True{}: {==}
    case False{}: {==}

law min_succ:
  for +a: Nat
  for +b: Nat
  {Nat.min(1n+a, 1n+b) == 1n+Nat.min(a, b) : Nat}
def min_succ(a, b):
  min_pick(Nat.is_lt(a, b), a, b)

law take_zero:
  for +xs: +List<U32>
  {List.take(&2, U32, xs, 0n) == [] : +List<U32>}
def take_zero(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: {==}

law sub_zero:
  for +a: Nat
  {Nat.sub(a, 0n) == a : Nat}
def sub_zero(a):
  match a:
    case 0n: {==}
    case 1n+p: {==}

law drop_zero:
  for +xs: +List<U32>
  {List.drop(&2, U32, xs, 0n) == xs : +List<U32>}
def drop_zero(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: {==}

law take_take:
  for +xs: +List<U32>
  for +a: Nat
  for +b: Nat
  {List.take(&2, U32, List.take(&2, U32, xs, b), a) == List.take(&2, U32, xs, Nat.min(a, b)) : +List<U32>}
def take_take(xs, a, b):
  match xs a b:
    case Nil{} _ _: {==}
    case Con{h, t} 0n 0n: {==}
    case Con{h, t} 0n 1n+q: {==}
    case Con{h, t} 1n+p 0n:
      %Equal.sym(Nat, Nat.min(1n+p, 0n), 0n, min_right_zero(1n+p)) : {List.take(&2, U32, List.take(&2, U32, h <> t, 0n), 1n+p) == List.take(&2, U32, h <> t, _) : +List<U32>}
      {==}
    case Con{h, t} 1n+p 1n+q:
      %Equal.sym(Nat, Nat.min(1n+p, 1n+q), 1n+Nat.min(p, q), min_succ(p, q)) : {List.take(&2, U32, List.take(&2, U32, h <> t, 1n+q), 1n+p) == List.take(&2, U32, h <> t, _) : +List<U32>}
      Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.take(&2, U32, List.take(&2, U32, t, q), p), List.take(&2, U32, t, Nat.min(p, q)), take_take(t, p, q))

law drop_take:
  for +xs: +List<U32>
  for +n: Nat
  for +m: Nat
  {List.drop(&2, U32, List.take(&2, U32, xs, m), n) == List.take(&2, U32, List.drop(&2, U32, xs, n), Nat.sub(m, n)) : +List<U32>}
def drop_take(xs, n, m):
  match xs n m:
    case Nil{} _ _: {==}
    case Con{h, t} 0n 0n: {==}
    case Con{h, t} 0n 1n+q: {==}
    case Con{h, t} 1n+p 0n: Equal.sym(+List<U32>, List.take(&2, U32, List.drop(&2, U32, h <> t, 1n+p), 0n), [], take_zero(List.drop(&2, U32, h <> t, 1n+p)))
    case Con{h, t} 1n+p 1n+q: drop_take(t, p, q)

law take_length:
  for +xs: +List<U32>
  for +n: Nat
  for +fits: {Nat.is_le(n, List.length(&2, U32, xs)) == True{} : Bool}
  {List.length(&2, U32, List.take(&2, U32, xs, n)) == n : Nat}
def take_length(xs, n, fits):
  match xs n:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: Empty.absurd({List.length(&2, U32, List.take(&2, U32, [], 1n+p)) == 1n+p : Nat}, F.false_true(fits))
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: Equal.cong(Nat, Nat, n2 => 1n+n2, List.length(&2, U32, List.take(&2, U32, t, p)), p, take_length(t, p, fits))

# ---------------------------------------------------------------------------
# A chunk denotes exactly 32 bytes.
law chunk_bytes_split:
  for +c: P.Chunk
  for +tail: +List<U32>
  {P.chunk_bytes(c, tail) == List.append(&2, U32, P.chunk_bytes(c, []), tail) : +List<U32>}
def chunk_bytes_split(c, tail):
  match c:
    case P.Chunk{w0, w1, w2, w3, w4, w5, w6, w7}: {==}

law chunk_bytes_length:
  for +c: P.Chunk
  {List.length(&2, U32, P.chunk_bytes(c, [])) == 32n : Nat}
def chunk_bytes_length(c):
  match c:
    case P.Chunk{w0, w1, w2, w3, w4, w5, w6, w7}: {==}

law chunks_bytes_cons:
  for +c: P.Chunk
  for +cs: +List<P.Chunk>
  {P.chunks_bytes(c <> cs) == List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(cs)) : +List<U32>}
def chunks_bytes_cons(c, cs):
  chunk_bytes_split(c, P.chunks_bytes(cs))

law drop_append_offset:
  for +p: +List<U32>
  for +r: +List<U32>
  for +at: Nat
  {List.drop(&2, U32, List.append(&2, U32, p, r), Nat.add(List.length(&2, U32, p), at)) == List.drop(&2, U32, r, at) : +List<U32>}
def drop_append_offset(p, r, at):
  match p:
    case Nil{}: {==}
    case Con{h, t}: drop_append_offset(t, r, at)

# Dropping one chunk from the stream drops exactly 32 bytes.
law drop_chunk:
  for +c: P.Chunk
  for +cs: +List<P.Chunk>
  for +at: Nat
  {List.drop(&2, U32, P.chunks_bytes(c <> cs), Nat.add(32n, at)) == List.drop(&2, U32, P.chunks_bytes(cs), at) : +List<U32>}
def drop_chunk(c, cs, at):
  %Equal.sym(+List<U32>, P.chunks_bytes(c <> cs), List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(cs)), chunks_bytes_cons(c, cs)) : {List.drop(&2, U32, _, Nat.add(32n, at)) == List.drop(&2, U32, P.chunks_bytes(cs), at) : +List<U32>}
  %chunk_bytes_length(c) : {List.drop(&2, U32, List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(cs)), Nat.add(_, at)) == List.drop(&2, U32, P.chunks_bytes(cs), at) : +List<U32>}
  drop_append_offset(P.chunk_bytes(c, []), P.chunks_bytes(cs), at)


# ---------------------------------------------------------------------------
# Normalising a slice (dropping whole chunks off the front) does not change
# the bytes it denotes.
law normalize_view:
  for +cs: +List<P.Chunk>
  for +at: Nat
  for +n: Nat
  {P.slice_bytes(P.normalize(cs, at, n)) == P.slice_bytes(P.Slice{cs, at, n}) : +List<U32>}
def normalize_view(cs, at, n):
  match cs:
    case Nil{}: {==}
    case Con{c, t}:
      match at:
        case 0n: {==}
        case 1n: {==}
        case 2n: {==}
        case 3n: {==}
        case 4n: {==}
        case 5n: {==}
        case 6n: {==}
        case 7n: {==}
        case 8n: {==}
        case 9n: {==}
        case 10n: {==}
        case 11n: {==}
        case 12n: {==}
        case 13n: {==}
        case 14n: {==}
        case 15n: {==}
        case 16n: {==}
        case 17n: {==}
        case 18n: {==}
        case 19n: {==}
        case 20n: {==}
        case 21n: {==}
        case 22n: {==}
        case 23n: {==}
        case 24n: {==}
        case 25n: {==}
        case 26n: {==}
        case 27n: {==}
        case 28n: {==}
        case 29n: {==}
        case 30n: {==}
        case 31n: {==}
        case 32n+rest:
          %Equal.sym(+List<U32>, List.drop(&2, U32, P.chunks_bytes(c <> t), Nat.add(32n, rest)), List.drop(&2, U32, P.chunks_bytes(t), rest), drop_chunk(c, t, rest)) : {P.slice_bytes(P.normalize(t, rest, n)) == List.take(&2, U32, _, n) : +List<U32>}
          normalize_view(t, rest, n)

# Advancing a slice drops that many bytes from its denotation.
law adv_view:
  for +s: P.Slice
  for +k: Nat
  {P.slice_bytes(P.adv(s, k)) == List.drop(&2, U32, P.slice_bytes(s), k) : +List<U32>}
def adv_view(s, k):
  match s:
    case P.Slice{cs, at, len}:
      Equal.trans(+List<U32>, P.slice_bytes(P.normalize(cs, Nat.add(at, k), Nat.sub(len, k))), P.slice_bytes(P.Slice{cs, Nat.add(at, k), Nat.sub(len, k)}), List.drop(&2, U32, P.slice_bytes(P.Slice{cs, at, len}), k),
        normalize_view(cs, Nat.add(at, k), Nat.sub(len, k)),
        Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), Nat.add(at, k)), Nat.sub(len, k)), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), k), Nat.sub(len, k)), List.drop(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), k),
          Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(len, k)), List.drop(&2, U32, P.chunks_bytes(cs), Nat.add(at, k)), List.drop(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), k), Equal.sym(+List<U32>, List.drop(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), k), List.drop(&2, U32, P.chunks_bytes(cs), Nat.add(at, k)), W.drop_drop(P.chunks_bytes(cs), at, k))),
          Equal.sym(+List<U32>, List.drop(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), k), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), k), Nat.sub(len, k)), drop_take(List.drop(&2, U32, P.chunks_bytes(cs), at), k, len))))

# Sub-slicing takes that many bytes of the denotation.
law sub_view:
  for +s: P.Slice
  for +k: Nat
  {P.slice_bytes(P.sub(s, k)) == List.take(&2, U32, P.slice_bytes(s), k) : +List<U32>}
def sub_view(s, k):
  match s:
    case P.Slice{cs, at, len}:
      Equal.sym(+List<U32>, List.take(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), k), List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), Nat.min(k, len)), take_take(List.drop(&2, U32, P.chunks_bytes(cs), at), k, len))

# ---------------------------------------------------------------------------
# Reading a byte of a slice is indexing its denotation.
law at_append_offset:
  for +p: +List<U32>
  for +r: +List<U32>
  for +k: Nat
  {IP.at(List.append(&2, U32, p, r), Nat.add(List.length(&2, U32, p), k)) == IP.at(r, k) : U32}
def at_append_offset(p, r, k):
  match p:
    case Nil{}: {==}
    case Con{h, t}: at_append_offset(t, r, k)

law lt_zero_false:
  for +r: Nat
  {Nat.is_lt(r, 0n) == False{} : Bool}
def lt_zero_false(r):
  match r:
    case 0n: {==}
    case 1n+p: {==}

law chunk_byte_at:
  for +c: P.Chunk
  for +j: Nat
  for +small: {Nat.is_lt(j, 32n) == True{} : Bool}
  {P.chunk_byte(c, j) == IP.at(P.chunk_bytes(c, []), j) : U32}
def chunk_byte_at(c, j, small):
  match c:
    case P.Chunk{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      match j:
        case 0n: {==}
        case 1n: {==}
        case 2n: {==}
        case 3n: {==}
        case 4n: {==}
        case 5n: {==}
        case 6n: {==}
        case 7n: {==}
        case 8n: {==}
        case 9n: {==}
        case 10n: {==}
        case 11n: {==}
        case 12n: {==}
        case 13n: {==}
        case 14n: {==}
        case 15n: {==}
        case 16n: {==}
        case 17n: {==}
        case 18n: {==}
        case 19n: {==}
        case 20n: {==}
        case 21n: {==}
        case 22n: {==}
        case 23n: {==}
        case 24n: {==}
        case 25n: {==}
        case 26n: {==}
        case 27n: {==}
        case 28n: {==}
        case 29n: {==}
        case 30n: {==}
        case 31n: {==}
        case 32n+rest: Empty.absurd({P.chunk_byte(c, 32n+rest) == IP.at(P.chunk_bytes(c, []), 32n+rest) : U32}, F.false_true(Equal.trans(Bool, False{}, Nat.is_lt(rest, 0n), True{}, Equal.sym(Bool, Nat.is_lt(rest, 0n), False{}, lt_zero_false(rest)), small)))


law at_drop:
  for +xs: +List<U32>
  for +a: Nat
  for +i: Nat
  {IP.at(List.drop(&2, U32, xs, a), i) == IP.at(xs, Nat.add(a, i)) : U32}
def at_drop(xs, a, i):
  match xs a:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: at_drop(t, p, i)

law at_take_low:
  for +xs: +List<U32>
  for +n: Nat
  for +i: Nat
  for +small: {Nat.is_lt(i, n) == True{} : Bool}
  {IP.at(List.take(&2, U32, xs, n), i) == IP.at(xs, i) : U32}
def at_take_low(xs, n, i, small):
  match xs n i:
    case Nil{} _ _: {==}
    case Con{h, t} 0n _: Empty.absurd({IP.at(List.take(&2, U32, h <> t, 0n), i) == IP.at(h <> t, i) : U32}, F.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, lt_zero_false(i)), small)))
    case Con{h, t} 1n+p 0n: {==}
    case Con{h, t} 1n+p 1n+q: at_take_low(t, p, q, small)

law at_take_high:
  for +xs: +List<U32>
  for +n: Nat
  for +i: Nat
  for +big: {Nat.is_lt(i, n) == False{} : Bool}
  {IP.at(List.take(&2, U32, xs, n), i) == 0 : U32}
def at_take_high(xs, n, i, big):
  match xs n i:
    case Nil{} _ _: {==}
    case Con{h, t} 0n _: {==}
    case Con{h, t} 1n+p 0n: Empty.absurd({IP.at(List.take(&2, U32, h <> t, 1n+p), 0n) == 0 : U32}, F.false_true(Equal.sym(Bool, True{}, False{}, big)))
    case Con{h, t} 1n+p 1n+q: at_take_high(t, p, q, big)

law at_append_low:
  for +p: +List<U32>
  for +r: +List<U32>
  for +j: Nat
  for +small: {Nat.is_lt(j, List.length(&2, U32, p)) == True{} : Bool}
  {IP.at(List.append(&2, U32, p, r), j) == IP.at(p, j) : U32}
def at_append_low(p, r, j, small):
  match p j:
    case Nil{} _: Empty.absurd({IP.at(r, j) == IP.at([], j) : U32}, F.false_true(Equal.trans(Bool, False{}, Nat.is_lt(j, 0n), True{}, Equal.sym(Bool, Nat.is_lt(j, 0n), False{}, lt_zero_false(j)), small)))
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+q: at_append_low(t, r, q, small)

# One chunk's byte, read through the chunk stream.
law chunk_head:
  for +c: P.Chunk
  for +t: +List<P.Chunk>
  for +j: Nat
  for +small: {Nat.is_lt(j, 32n) == True{} : Bool}
  {P.chunk_byte(c, j) == IP.at(P.chunks_bytes(c <> t), j) : U32}
def chunk_head(c, t, j, small):
  Equal.trans(U32, P.chunk_byte(c, j), IP.at(P.chunk_bytes(c, []), j), IP.at(P.chunks_bytes(c <> t), j),
    chunk_byte_at(c, j, small),
    Equal.sym(U32, IP.at(P.chunks_bytes(c <> t), j), IP.at(P.chunk_bytes(c, []), j),
      Equal.trans(U32, IP.at(P.chunks_bytes(c <> t), j), IP.at(List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(t)), j), IP.at(P.chunk_bytes(c, []), j),
        Equal.cong(+List<U32>, U32, ys => IP.at(ys, j), P.chunks_bytes(c <> t), List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(t)), chunks_bytes_cons(c, t)),
        at_append_low(P.chunk_bytes(c, []), P.chunks_bytes(t), j,
          %Equal.sym(Nat, List.length(&2, U32, P.chunk_bytes(c, [])), 32n, chunk_bytes_length(c)) : {Nat.is_lt(j, _) == True{} : Bool}
          small))))

# Reading through a normalised cursor is indexing the chunk stream.
law positioned_at:
  for +cs: +List<P.Chunk>
  for +j: Nat
  for +n: Nat
  {P.positioned(P.normalize(cs, j, n)) == IP.at(P.chunks_bytes(cs), j) : U32}
def positioned_at(cs, j, n):
  match cs:
    case Nil{}: {==}
    case Con{c, t}:
      match j:
        case 0n: chunk_head(c, t, 0n, {==})
        case 1n: chunk_head(c, t, 1n, {==})
        case 2n: chunk_head(c, t, 2n, {==})
        case 3n: chunk_head(c, t, 3n, {==})
        case 4n: chunk_head(c, t, 4n, {==})
        case 5n: chunk_head(c, t, 5n, {==})
        case 6n: chunk_head(c, t, 6n, {==})
        case 7n: chunk_head(c, t, 7n, {==})
        case 8n: chunk_head(c, t, 8n, {==})
        case 9n: chunk_head(c, t, 9n, {==})
        case 10n: chunk_head(c, t, 10n, {==})
        case 11n: chunk_head(c, t, 11n, {==})
        case 12n: chunk_head(c, t, 12n, {==})
        case 13n: chunk_head(c, t, 13n, {==})
        case 14n: chunk_head(c, t, 14n, {==})
        case 15n: chunk_head(c, t, 15n, {==})
        case 16n: chunk_head(c, t, 16n, {==})
        case 17n: chunk_head(c, t, 17n, {==})
        case 18n: chunk_head(c, t, 18n, {==})
        case 19n: chunk_head(c, t, 19n, {==})
        case 20n: chunk_head(c, t, 20n, {==})
        case 21n: chunk_head(c, t, 21n, {==})
        case 22n: chunk_head(c, t, 22n, {==})
        case 23n: chunk_head(c, t, 23n, {==})
        case 24n: chunk_head(c, t, 24n, {==})
        case 25n: chunk_head(c, t, 25n, {==})
        case 26n: chunk_head(c, t, 26n, {==})
        case 27n: chunk_head(c, t, 27n, {==})
        case 28n: chunk_head(c, t, 28n, {==})
        case 29n: chunk_head(c, t, 29n, {==})
        case 30n: chunk_head(c, t, 30n, {==})
        case 31n: chunk_head(c, t, 31n, {==})
        case 32n+rest:
          %Equal.sym(+List<U32>, P.chunks_bytes(c <> t), List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(t)), chunks_bytes_cons(c, t)) : {P.positioned(P.normalize(t, rest, n)) == IP.at(_, Nat.add(32n, rest)) : U32}
          %chunk_bytes_length(c) : {P.positioned(P.normalize(t, rest, n)) == IP.at(List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(t)), Nat.add(_, rest)) : U32}
          Equal.trans(U32, P.positioned(P.normalize(t, rest, n)), IP.at(P.chunks_bytes(t), rest), IP.at(List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(t)), Nat.add(List.length(&2, U32, P.chunk_bytes(c, [])), rest)),
            positioned_at(t, rest, n),
            Equal.sym(U32, IP.at(List.append(&2, U32, P.chunk_bytes(c, []), P.chunks_bytes(t)), Nat.add(List.length(&2, U32, P.chunk_bytes(c, [])), rest)), IP.at(P.chunks_bytes(t), rest), at_append_offset(P.chunk_bytes(c, []), P.chunks_bytes(t), rest)))

law byte_at_case:
  for +in_range: Bool
  for +cs: +List<P.Chunk>
  for +at: Nat
  for +len: Nat
  for +i: Nat
  for +same: {Nat.is_lt(i, len) == in_range : Bool}
  {P.slice_byte(in_range, cs, Nat.add(at, i), len) == IP.at(List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), i) : U32}
def byte_at_case(in_range, cs, at, len, i, same):
  match in_range:
    case True{}:
      Equal.trans(U32, P.positioned(P.normalize(cs, Nat.add(at, i), len)), IP.at(P.chunks_bytes(cs), Nat.add(at, i)), IP.at(List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), i),
        positioned_at(cs, Nat.add(at, i), len),
        Equal.sym(U32, IP.at(List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), i), IP.at(P.chunks_bytes(cs), Nat.add(at, i)),
          Equal.trans(U32, IP.at(List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), i), IP.at(List.drop(&2, U32, P.chunks_bytes(cs), at), i), IP.at(P.chunks_bytes(cs), Nat.add(at, i)),
            at_take_low(List.drop(&2, U32, P.chunks_bytes(cs), at), len, i, same),
            at_drop(P.chunks_bytes(cs), at, i))))
    case False{}: Equal.sym(U32, IP.at(List.take(&2, U32, List.drop(&2, U32, P.chunks_bytes(cs), at), len), i), 0, at_take_high(List.drop(&2, U32, P.chunks_bytes(cs), at), len, i, same))

# A slice byte is the byte of its denotation at that index.
law byte_at_view:
  for +s: P.Slice
  for +i: Nat
  {P.byte_at(s, i) == IP.at(P.slice_bytes(s), i) : U32}
def byte_at_view(s, i):
  match s:
    case P.Slice{cs, at, len}: byte_at_case(Nat.is_lt(i, len), cs, at, len, i, {==})


# ---------------------------------------------------------------------------
# Well formed slices: the declared size is the length of the denotation. Every
# slice the decoder builds is well formed, and the decoder proofs carry this.
def wf(s: P.Slice) -> Type:
  {List.length(&2, U32, P.slice_bytes(s)) == P.slice_size(s) : Nat}

law length_drop:
  for +xs: +List<U32>
  for +k: Nat
  {List.length(&2, U32, List.drop(&2, U32, xs, k)) == Nat.sub(List.length(&2, U32, xs), k) : Nat}
def length_drop(xs, k):
  match xs k:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: length_drop(t, p)

law normalize_size:
  for +cs: +List<P.Chunk>
  for +at: Nat
  for +n: Nat
  {P.slice_size(P.normalize(cs, at, n)) == n : Nat}
def normalize_size(cs, at, n):
  match cs:
    case Nil{}: {==}
    case Con{c, t}:
      match at:
        case 0n: {==}
        case 1n: {==}
        case 2n: {==}
        case 3n: {==}
        case 4n: {==}
        case 5n: {==}
        case 6n: {==}
        case 7n: {==}
        case 8n: {==}
        case 9n: {==}
        case 10n: {==}
        case 11n: {==}
        case 12n: {==}
        case 13n: {==}
        case 14n: {==}
        case 15n: {==}
        case 16n: {==}
        case 17n: {==}
        case 18n: {==}
        case 19n: {==}
        case 20n: {==}
        case 21n: {==}
        case 22n: {==}
        case 23n: {==}
        case 24n: {==}
        case 25n: {==}
        case 26n: {==}
        case 27n: {==}
        case 28n: {==}
        case 29n: {==}
        case 30n: {==}
        case 31n: {==}
        case 32n+rest: normalize_size(t, rest, n)

law wf_adv:
  for +s: P.Slice
  for +k: Nat
  for good: wf(s)
  wf(P.adv(s, k))
def wf_adv(s, k, good):
  match s:
    case P.Slice{cs, at, len}:
      %Equal.sym(Nat, P.slice_size(P.normalize(cs, Nat.add(at, k), Nat.sub(len, k))), Nat.sub(len, k), normalize_size(cs, Nat.add(at, k), Nat.sub(len, k))) : {List.length(&2, U32, P.slice_bytes(P.adv(P.Slice{cs, at, len}, k))) == _ : Nat}
      %Equal.sym(+List<U32>, P.slice_bytes(P.adv(P.Slice{cs, at, len}, k)), List.drop(&2, U32, P.slice_bytes(P.Slice{cs, at, len}), k), adv_view(P.Slice{cs, at, len}, k)) : {List.length(&2, U32, _) == Nat.sub(len, k) : Nat}
      Equal.trans(Nat, List.length(&2, U32, List.drop(&2, U32, P.slice_bytes(P.Slice{cs, at, len}), k)), Nat.sub(List.length(&2, U32, P.slice_bytes(P.Slice{cs, at, len})), k), Nat.sub(len, k),
        length_drop(P.slice_bytes(P.Slice{cs, at, len}), k),
        Equal.cong(Nat, Nat, m => Nat.sub(m, k), List.length(&2, U32, P.slice_bytes(P.Slice{cs, at, len})), len, good))

law min_le:
  for +k: Nat
  for +len: Nat
  for +fits: {Nat.is_le(k, len) == True{} : Bool}
  {Nat.min(k, len) == k : Nat}
def min_le(k, len, fits):
  match k len:
    case 0n _: min_zero(len)
    case 1n+p 0n: Empty.absurd({Nat.min(1n+p, 0n) == 1n+p : Nat}, F.false_true(fits))
    case 1n+p 1n+q:
      Equal.trans(Nat, Nat.min(1n+p, 1n+q), 1n+Nat.min(p, q), 1n+p, min_succ(p, q), Equal.cong(Nat, Nat, m => 1n+m, Nat.min(p, q), p, min_le(p, q, fits)))

law wf_sub:
  for +s: P.Slice
  for +k: Nat
  for good: wf(s)
  for +fits: {Nat.is_le(k, P.slice_size(s)) == True{} : Bool}
  wf(P.sub(s, k))
def wf_sub(s, k, good, fits):
  match s:
    case P.Slice{cs, at, len}:
      %Equal.sym(+List<U32>, P.slice_bytes(P.sub(P.Slice{cs, at, len}, k)), List.take(&2, U32, P.slice_bytes(P.Slice{cs, at, len}), k), sub_view(P.Slice{cs, at, len}, k)) : {List.length(&2, U32, _) == P.slice_size(P.sub(P.Slice{cs, at, len}, k)) : Nat}
      Equal.trans(Nat, List.length(&2, U32, List.take(&2, U32, P.slice_bytes(P.Slice{cs, at, len}), k)), k, P.slice_size(P.sub(P.Slice{cs, at, len}, k)),
        take_length(P.slice_bytes(P.Slice{cs, at, len}), k,
          %Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(P.Slice{cs, at, len})), len, good) : {Nat.is_le(k, _) == True{} : Bool}
          fits),
        Equal.sym(Nat, P.slice_size(P.sub(P.Slice{cs, at, len}, k)), k, min_le(k, len, fits)))


# ---------------------------------------------------------------------------
# Materialising a slice yields exactly its denotation.
law rev_append_twice:
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +acc: +List<U32>
  {P.rev_append(P.rev_append(xs, ys), acc) == P.rev_append(ys, List.append(&2, U32, xs, acc)) : +List<U32>}
def rev_append_twice(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: rev_append_twice(t, h <> ys, acc)

law to_list_go_view:
  for +xs: +List<U32>
  for +n: Nat
  for +s: P.Slice
  for +acc: +List<U32>
  for +same: {P.slice_bytes(s) == xs : +List<U32>}
  for +sized: {List.length(&2, U32, xs) == n : Nat}
  {P.to_list_go(n, s, acc) == P.rev_append(xs, acc) : +List<U32>}
def to_list_go_view(xs, n, s, acc, same, sized):
  match xs n:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: Empty.absurd({P.to_list_go(1n+p, s, acc) == acc : +List<U32>}, F.false_true(Equal.sym(Bool, Nat.is_eq(0n, 0n), Nat.is_eq(1n+p, 0n), Equal.cong(Nat, Bool, m => Nat.is_eq(m, 0n), 0n, 1n+p, sized))))
    case Con{h, t} 0n: Empty.absurd({acc == P.rev_append(h <> t, acc) : +List<U32>}, F.false_true(Equal.cong(Nat, Bool, m => Nat.is_eq(m, 0n), 1n+List.length(&2, U32, t), 0n, sized)))
    case Con{h, t} 1n+p:
      %Equal.sym(U32, P.byte_at(s, 0n), h, Equal.trans(U32, P.byte_at(s, 0n), IP.at(P.slice_bytes(s), 0n), h, byte_at_view(s, 0n), Equal.cong(+List<U32>, U32, ys => IP.at(ys, 0n), P.slice_bytes(s), h <> t, same))) : {P.to_list_go(p, P.adv(s, 1n), _ <> acc) == P.rev_append(t, h <> acc) : +List<U32>}
      to_list_go_view(t, p, P.adv(s, 1n), h <> acc,
        Equal.trans(+List<U32>, P.slice_bytes(P.adv(s, 1n)), List.drop(&2, U32, P.slice_bytes(s), 1n), t, adv_view(s, 1n), Equal.trans(+List<U32>, List.drop(&2, U32, P.slice_bytes(s), 1n), List.drop(&2, U32, t, 0n), t, Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, 1n), P.slice_bytes(s), h <> t, same), drop_zero(t))),
        Equal.trans(Nat, List.length(&2, U32, t), Nat.sub(List.length(&2, U32, t), 0n), p,
          Equal.sym(Nat, Nat.sub(List.length(&2, U32, t), 0n), List.length(&2, U32, t), sub_zero(List.length(&2, U32, t))),
          Equal.trans(Nat, Nat.sub(List.length(&2, U32, t), 0n), Nat.sub(p, 0n), p, Equal.cong(Nat, Nat, m => Nat.sub(m, 1n), 1n+List.length(&2, U32, t), 1n+p, sized), sub_zero(p))))

law to_list_view:
  for +s: P.Slice
  for good: wf(s)
  {P.to_list(s) == P.slice_bytes(s) : +List<U32>}
def to_list_view(s, good):
  %Equal.sym(+List<U32>, P.to_list_go(P.slice_size(s), s, []), P.rev_append(P.slice_bytes(s), []), to_list_go_view(P.slice_bytes(s), P.slice_size(s), s, [], {==}, good)) : {P.rev_append(_, []) == P.slice_bytes(s) : +List<U32>}
  Equal.trans(+List<U32>, P.rev_append(P.rev_append(P.slice_bytes(s), []), []), List.append(&2, U32, P.slice_bytes(s), []), P.slice_bytes(s),
    rev_append_twice(P.slice_bytes(s), [], []),
    L.append_empty(U32, P.slice_bytes(s)))

# ---------------------------------------------------------------------------
# Little-endian reads agree with the implementation's own limb reader on the
# denoted bytes, which the existing integer lemmas already relate to the spec.
law u32_at_view:
  for +s: P.Slice
  for +i: Nat
  {P.u32_at(s, i) == IP.read_limb(P.slice_bytes(s), i) : U32}
def u32_at_view(s, i):
  %Equal.sym(U32, P.byte_at(s, i), IP.at(P.slice_bytes(s), i), byte_at_view(s, i)) : {P.limb(_, P.byte_at(s, 1n+i), P.byte_at(s, 2n+i), P.byte_at(s, 3n+i)) == IP.read_limb(P.slice_bytes(s), i) : U32}
  %Equal.sym(U32, P.byte_at(s, 1n+i), IP.at(P.slice_bytes(s), 1n+i), byte_at_view(s, 1n+i)) : {P.limb(IP.at(P.slice_bytes(s), i), _, P.byte_at(s, 2n+i), P.byte_at(s, 3n+i)) == IP.read_limb(P.slice_bytes(s), i) : U32}
  %Equal.sym(U32, P.byte_at(s, 2n+i), IP.at(P.slice_bytes(s), 2n+i), byte_at_view(s, 2n+i)) : {P.limb(IP.at(P.slice_bytes(s), i), IP.at(P.slice_bytes(s), 1n+i), _, P.byte_at(s, 3n+i)) == IP.read_limb(P.slice_bytes(s), i) : U32}
  %Equal.sym(U32, P.byte_at(s, 3n+i), IP.at(P.slice_bytes(s), 3n+i), byte_at_view(s, 3n+i)) : {P.limb(IP.at(P.slice_bytes(s), i), IP.at(P.slice_bytes(s), 1n+i), IP.at(P.slice_bytes(s), 2n+i), _) == IP.read_limb(P.slice_bytes(s), i) : U32}
  {==}

law offset_at_view:
  for +s: P.Slice
  {P.offset_at(s) == U32.to_nat(IP.read_limb(P.slice_bytes(s), 0n)) : Nat}
def offset_at_view(s):
  Equal.cong(U32, Nat, w => U32.to_nat(w), P.u32_at(s, 0n), IP.read_limb(P.slice_bytes(s), 0n), u32_at_view(s, 0n))

law uint_word_view:
  for +s: P.Slice
  for +i: Nat
  for +width: Nat
  {P.uint_word_guard(s, i, width) == IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), i) : U32}
def uint_word_view(s, i, width):
  %sub_view(s, width) : {P.u32_at(P.sub(s, width), i) == IP.read_limb(_, i) : U32}
  u32_at_view(P.sub(s, width), i)

law uint_cong:
  for +a0: U32
  for +a1: U32
  for +a2: U32
  for +a3: U32
  for +a4: U32
  for +a5: U32
  for +a6: U32
  for +a7: U32
  for +b0: U32
  for +b1: U32
  for +b2: U32
  for +b3: U32
  for +b4: U32
  for +b5: U32
  for +b6: U32
  for +b7: U32
  for +e0: {a0 == b0 : U32}
  for +e1: {a1 == b1 : U32}
  for +e2: {a2 == b2 : U32}
  for +e3: {a3 == b3 : U32}
  for +e4: {a4 == b4 : U32}
  for +e5: {a5 == b5 : U32}
  for +e6: {a6 == b6 : U32}
  for +e7: {a7 == b7 : U32}
  {Primitive.UInt{a0, a1, a2, a3, a4, a5, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
def uint_cong(a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7, e0, e1, e2, e3, e4, e5, e6, e7):
  %Equal.sym(U32, a0, b0, e0) : {Primitive.UInt{_, a1, a2, a3, a4, a5, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a1, b1, e1) : {Primitive.UInt{b0, _, a2, a3, a4, a5, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a2, b2, e2) : {Primitive.UInt{b0, b1, _, a3, a4, a5, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a3, b3, e3) : {Primitive.UInt{b0, b1, b2, _, a4, a5, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a4, b4, e4) : {Primitive.UInt{b0, b1, b2, b3, _, a5, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a5, b5, e5) : {Primitive.UInt{b0, b1, b2, b3, b4, _, a6, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a6, b6, e6) : {Primitive.UInt{b0, b1, b2, b3, b4, b5, _, a7} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  %Equal.sym(U32, a7, b7, e7) : {Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, _} == Primitive.UInt{b0, b1, b2, b3, b4, b5, b6, b7} : Primitive.UInt}
  {==}

law uint_of_view:
  for +s: P.Slice
  for +width: Nat
  {P.uint_of(s, width) == IP.decoded(List.take(&2, U32, P.slice_bytes(s), width)) : Primitive.UInt}
def uint_of_view(s, width):
  uint_cong(P.uint_word_guard(s, 0n, width), P.uint_word_guard(s, 4n, width), P.uint_word_guard(s, 8n, width), P.uint_word_guard(s, 12n, width), P.uint_word_guard(s, 16n, width), P.uint_word_guard(s, 20n, width), P.uint_word_guard(s, 24n, width), P.uint_word_guard(s, 28n, width), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 0n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 4n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 8n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 12n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 16n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 20n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 24n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), width), 28n), uint_word_view(s, 0n, width), uint_word_view(s, 4n, width), uint_word_view(s, 8n, width), uint_word_view(s, 12n, width), uint_word_view(s, 16n, width), uint_word_view(s, 20n, width), uint_word_view(s, 24n, width), uint_word_view(s, 28n, width))

law take_length_all:
  for +xs: +List<U32>
  {List.take(&2, U32, xs, List.length(&2, U32, xs)) == xs : +List<U32>}
def take_length_all(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.take(&2, U32, t, List.length(&2, U32, t)), t, take_length_all(t))
