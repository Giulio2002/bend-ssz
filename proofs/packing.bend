import Base
import ./primitive_invariants.bend as V
import ./primitives.bend as Basic
import ../src/packing.bend as I
import ../spec/packing.bend as S
import ../src/primitives.bend as R
import ../spec/primitives.bend as P
import ./bytes.bend as B
import ./basic_root.bend as Root

law reverse_go_append:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  for +zs: +List<A>
  {List.reverse.go(&2, A, xs, List.append(&2, A, ys, zs)) == List.append(&2, A, List.reverse.go(&2, A, xs, ys), zs) : +List<A>}
def reverse_go_append(A, xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: reverse_go_append(A, t, h <> ys, zs)

law reverse_cons:
  for -A: Data
  for +h: A
  for +t: +List<A>
  {List.reverse(&2, A, h <> t) == List.append(&2, A, List.reverse(&2, A, t), [h]) : +List<A>}
def reverse_cons(A, h, t): reverse_go_append(A, t, [], [h])

law finish_correct:
  for +room: Nat
  for +buffer: +List<U32>
  for +chunks: +List<+List<U32>>
  {I.finish(room, buffer, chunks) == S.finish(room, buffer, List.reverse(&2, +List<U32>, chunks)) : +List<+List<U32>>}
def finish_correct(room, buffer, chunks):
  match buffer:
    case Nil{}: {==}
    case Con{h, t}:
      %Root.empty_padding(1n+room) :
        {I.finish(room, h <> t, chunks) == List.append(&2, +List<U32>, List.reverse(&2, +List<U32>, chunks), [List.append(&2, U32, h <> t, _)]) : +List<+List<U32>>}
      reverse_cons(+List<U32>, List.append(&2, U32, h <> t, R.pad(1n+room, [])), chunks)

law scan_correct:
  for +xs: +List<U32>
  for +room: Nat
  for +buffer: +List<U32>
  for +chunks: +List<+List<U32>>
  {I.scan(xs, room, buffer, chunks) == S.scan(xs, room, buffer, List.reverse(&2, +List<U32>, chunks)) : +List<+List<U32>>}
def scan_correct(xs, room, buffer, chunks):
  match xs:
    case Nil{}: finish_correct(room, buffer, chunks)
    case Con{h, t}:
      match room:
        case 0n:
          %reverse_cons(+List<U32>, List.append(&2, U32, buffer, [h]), chunks) :
            {I.scan(t, 31n, [], List.append(&2, U32, buffer, [h]) <> chunks) == S.scan(t, 31n, [], _) : +List<+List<U32>>}
          scan_correct(t, 31n, [], List.append(&2, U32, buffer, [h]) <> chunks)
        case 1n+p: scan_correct(t, p, List.append(&2, U32, buffer, [h]), chunks)

law valid_go_correct:
  for +xs: +List<U32>
  for +ok: Bool
  {I.valid_go(xs, ok) == Bool.and(ok, P.bytes_domain(xs)) : Bool}
def valid_go_correct(xs, ok):
  match xs:
    case Nil{}: Equal.sym(Bool, Bool.and(ok, True{}), ok, B.and_identity(ok))
    case Con{h, t}:
      %B.and_associative(ok, U32.is_lt(h, 256), P.bytes_domain(t)) :
        {I.valid_go(t, Bool.and(ok, U32.is_lt(h, 256))) == _ : Bool}
      valid_go_correct(t, Bool.and(ok, U32.is_lt(h, 256)))

law checked_correct:
  for ok: Bool
  for +xs: +List<U32>
  {I.checked(ok, xs) == S.checked(ok, xs) : Maybe<&2, +List<+List<U32>>>}
def checked_correct(ok, xs):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(+List<+List<U32>>, Maybe<&2, +List<+List<U32>>>, cs => Some{cs}, I.scan(xs, 31n, [], []), S.scan(xs, 31n, [], []), scan_correct(xs, 31n, [], []))

law pack_correct:
  for +xs: +List<U32>
  {I.pack(xs) == S.pack(xs) : Maybe<&2, +List<+List<U32>>>}
def pack_correct(xs):
  %valid_go_correct(xs, True{}) : {I.pack(xs) == S.checked(_, xs) : Maybe<&2, +List<+List<U32>>>}
  checked_correct(I.valid_go(xs, True{}), xs)

def accepted(result: Maybe<&2, +List<+List<U32>>>) -> Bool:
  match result:
    case None{}: False{}
    case Some{chunks}: True{}

law checked_acceptance:
  for +ok: Bool
  for xs: +List<U32>
  {accepted(I.checked(ok, xs)) == ok : Bool}
def checked_acceptance(ok, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law pack_rejection:
  for +xs: +List<U32>
  {accepted(I.pack(xs)) == P.bytes_domain(xs) : Bool}
def pack_rejection(xs):
  %valid_go_correct(xs, True{}) : {accepted(I.pack(xs)) == _ : Bool}
  checked_acceptance(I.valid_go(xs, True{}), xs)

law add_zero:
  for +n: Nat
  {Nat.add(n, 0n) == n : Nat}
def add_zero(n):
  match n:
    case 0n: {==}
    case 1n+p:
      %add_zero(p) : {1n+Nat.add(p, 0n) == 1n+_ : Nat}
      {==}

law add_succ:
  for +n: Nat
  for +m: Nat
  {Nat.add(n, 1n+m) == 1n+Nat.add(n, m) : Nat}
def add_succ(n, m):
  match n:
    case 0n: {==}
    case 1n+p:
      %add_succ(p, m) : {1n+Nat.add(p, 1n+m) == 1n+_ : Nat}
      {==}

law snoc_room:
  for +xs: +List<U32>
  for +h: U32
  for +room: Nat
  {Nat.add(List.length(&2, U32, List.append(&2, U32, xs, [h])), room) == Nat.add(List.length(&2, U32, xs), 1n+room) : Nat}
def snoc_room(xs, h, room):
  match xs:
    case Nil{}: {==}
    case Con{a, t}:
      %snoc_room(t, h, room) : {1n+Nat.add(List.length(&2, U32, List.append(&2, U32, t, [h])), room) == 1n+_ : Nat}
      {==}

law scope_from_size:
  for +xs: +List<U32>
  for +n: Nat
  for size: {List.length(&2, U32, xs) == n : Nat}
  for bytes: {P.bytes_domain(xs) == True{} : Bool}
  {P.byte_scope(n, xs) == True{} : Bool}
def scope_from_size(xs, n, size, bytes):
  %size : {P.byte_scope(_, xs) == True{} : Bool}
  %Equal.sym(Bool, P.byte_scope(List.length(&2, U32, xs), xs), P.bytes_domain(xs), V.scope_of_domain(xs)) : {_ == True{} : Bool}
  bytes

law padded_buffer:
  for +room: Nat
  for +buffer: +List<U32>
  for size: {Nat.add(List.length(&2, U32, buffer), room) == 31n : Nat}
  {List.append(&2, U32, buffer, P.zero_bytes(1n+room)) == R.pad(32n, buffer) : +List<U32>}
def padded_buffer(room, buffer, size):
  %size : {List.append(&2, U32, buffer, P.zero_bytes(1n+room)) == R.pad(1n+_, buffer) : +List<U32>}
  %add_succ(List.length(&2, U32, buffer), room) : {List.append(&2, U32, buffer, P.zero_bytes(1n+room)) == R.pad(_, buffer) : +List<U32>}
  Equal.sym(+List<U32>, R.pad(Nat.add(List.length(&2, U32, buffer), 1n+room), buffer), List.append(&2, U32, buffer, P.zero_bytes(1n+room)), Root.padding_content(buffer, 1n+room))

law full_buffer_size:
  for +buffer: +List<U32>
  for +h: U32
  for size: {Nat.add(List.length(&2, U32, buffer), 0n) == 31n : Nat}
  {List.length(&2, U32, List.append(&2, U32, buffer, [h])) == 32n : Nat}
def full_buffer_size(buffer, h, size):
  %size : {List.length(&2, U32, List.append(&2, U32, buffer, [h])) == 1n+_ : Nat}
  %add_succ(List.length(&2, U32, buffer), 0n) : {List.length(&2, U32, List.append(&2, U32, buffer, [h])) == _ : Nat}
  %snoc_room(buffer, h, 0n) : {List.length(&2, U32, List.append(&2, U32, buffer, [h])) == _ : Nat}
  Equal.sym(Nat, Nat.add(List.length(&2, U32, List.append(&2, U32, buffer, [h])), 0n), List.length(&2, U32, List.append(&2, U32, buffer, [h])), add_zero(List.length(&2, U32, List.append(&2, U32, buffer, [h]))))

law snoc_bytes:
  for +buffer: +List<U32>
  for +h: U32
  for eb: {P.bytes_domain(buffer) == True{} : Bool}
  for eh: {U32.is_lt(h, 256) == True{} : Bool}
  {P.bytes_domain(List.append(&2, U32, buffer, [h])) == True{} : Bool}
def snoc_bytes(buffer, h, eb, eh):
  V.append_domain(buffer, [h], eb, V.and_true(U32.is_lt(h, 256), True{}, eh, {==}))

law reverse_go_domain:
  for +xs: +List<+List<U32>>
  for +acc: +List<+List<U32>>
  for +ex: {S.chunks_domain(xs) == True{} : Bool}
  for ea: {S.chunks_domain(acc) == True{} : Bool}
  {S.chunks_domain(List.reverse.go(&2, +List<U32>, xs, acc)) == True{} : Bool}
def reverse_go_domain(xs, acc, ex, ea):
  match xs:
    case Nil{}: ea
    case Con{h, t}:
      reverse_go_domain(t, h <> acc,
        V.and_right(P.byte_scope(32n, h), S.chunks_domain(t), ex),
        V.and_true(P.byte_scope(32n, h), S.chunks_domain(acc), V.and_left(P.byte_scope(32n, h), S.chunks_domain(t), ex), ea))

law finish_domain:
  for +room: Nat
  for +buffer: +List<U32>
  for +chunks: +List<+List<U32>>
  for size: {Nat.add(List.length(&2, U32, buffer), room) == 31n : Nat}
  for eb: {P.bytes_domain(buffer) == True{} : Bool}
  for ec: {S.chunks_domain(chunks) == True{} : Bool}
  {S.chunks_domain(I.finish(room, buffer, chunks)) == True{} : Bool}
def finish_domain(room, buffer, chunks, size, eb, ec):
  match buffer:
    case Nil{}: reverse_go_domain(chunks, [], ec, {==})
    case Con{h, t}:
      %Equal.sym(+List<U32>, R.pad(1n+room, []), P.zero_bytes(1n+room), Root.empty_padding(1n+room)) :
        {S.chunks_domain(List.reverse(&2, +List<U32>, List.append(&2, U32, h <> t, _) <> chunks)) == True{} : Bool}
      %Equal.sym(+List<U32>, List.append(&2, U32, h <> t, P.zero_bytes(1n+room)), R.pad(32n, h <> t), padded_buffer(room, h <> t, size)) :
        {S.chunks_domain(List.reverse(&2, +List<U32>, _ <> chunks)) == True{} : Bool}
      reverse_go_domain(R.pad(32n, h <> t) <> chunks, [],
        V.and_true(P.byte_scope(32n, R.pad(32n, h <> t)), S.chunks_domain(chunks),
          scope_from_size(R.pad(32n, h <> t), 32n, Basic.padded_length(32n, h <> t), Root.pad_preserves_domain(32n, h <> t, eb)), ec), {==})

law next_room:
  for +buffer: +List<U32>
  for +h: U32
  for +room: Nat
  for size: {Nat.add(List.length(&2, U32, buffer), 1n+room) == 31n : Nat}
  {Nat.add(List.length(&2, U32, List.append(&2, U32, buffer, [h])), room) == 31n : Nat}
def next_room(buffer, h, room, size):
  Equal.trans(Nat, Nat.add(List.length(&2, U32, List.append(&2, U32, buffer, [h])), room), Nat.add(List.length(&2, U32, buffer), 1n+room), 31n, snoc_room(buffer, h, room), size)

law scan_domain:
  for +xs: +List<U32>
  for +room: Nat
  for +buffer: +List<U32>
  for +chunks: +List<+List<U32>>
  for +ex: {P.bytes_domain(xs) == True{} : Bool}
  for size: {Nat.add(List.length(&2, U32, buffer), room) == 31n : Nat}
  for eb: {P.bytes_domain(buffer) == True{} : Bool}
  for ec: {S.chunks_domain(chunks) == True{} : Bool}
  {S.chunks_domain(I.scan(xs, room, buffer, chunks)) == True{} : Bool}
def scan_domain(xs, room, buffer, chunks, ex, size, eb, ec):
  match xs:
    case Nil{}: finish_domain(room, buffer, chunks, size, eb, ec)
    case Con{h, t}:
      match room:
        case 0n:
          scan_domain(t, 31n, [], List.append(&2, U32, buffer, [h]) <> chunks,
            V.and_right(U32.is_lt(h, 256), P.bytes_domain(t), ex), {==}, {==},
            V.and_true(P.byte_scope(32n, List.append(&2, U32, buffer, [h])), S.chunks_domain(chunks),
              scope_from_size(List.append(&2, U32, buffer, [h]), 32n, full_buffer_size(buffer, h, size),
                snoc_bytes(buffer, h, eb, V.and_left(U32.is_lt(h, 256), P.bytes_domain(t), ex))), ec))
        case 1n+p:
          scan_domain(t, p, List.append(&2, U32, buffer, [h]), chunks,
            V.and_right(U32.is_lt(h, 256), P.bytes_domain(t), ex), next_room(buffer, h, p, size),
            snoc_bytes(buffer, h, eb, V.and_left(U32.is_lt(h, 256), P.bytes_domain(t), ex)), ec)

def result_domain(result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case None{}: Unit
    case Some{chunks}: {S.chunks_domain(chunks) == True{} : Bool}

law checked_domain:
  for +ok: Bool
  for +xs: +List<U32>
  for e: {ok == P.bytes_domain(xs) : Bool}
  result_domain(I.checked(ok, xs))
def checked_domain(ok, xs, e):
  match ok:
    case False{}: Unit{}
    case True{}:
      scan_domain(xs, 31n, [], [], Equal.sym(Bool, True{}, P.bytes_domain(xs), e), {==}, {==}, {==})

law pack_domain:
  for +xs: +List<U32>
  result_domain(I.pack(xs))
def pack_domain(xs): checked_domain(I.valid_go(xs, True{}), xs, valid_go_correct(xs, True{}))
