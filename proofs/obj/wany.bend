import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as SF
import ./words_spec.bend as WS
import ./words_obj_light.bend as WO
import ./packed_obj_light_generated.bend as PK
import ./arr_copy_generated.bend as AC
import ./arr_vec_generated.bend as AV
import ./arr_emit_generated.bend as AE
import ./vspec.bend as VS

# Encoding word storage of ANY depth. The root laws' representation facts (rep_*)
# allow a storage tree deeper than the encoder's output; the writer only reads the
# first NW words, so its output is the copy (arr_copy cpt) of those words into the
# zero output tree, whose first NW slots are the storage's first NW slots. The
# lemmas here are depth-generic; proofs/obj/spec_gany_*.bend instantiate them.

def bool_disc(b: Bool) -> Type:
  match b:
    case True{}: Unit
    case False{}: Empty

def false_true(e: {False{} == True{} : Bool}) -> Empty:
  %Equal.sym(Bool, False{}, True{}, e) : bool_disc(_)
  Unit{}

# ---- Nat bounds -------------------------------------------------------------------------

law dle:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(Nat.double(a), Nat.double(b)) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def dle(a, b, h):
  match a b:
    case 0n _: Order.zero_le(b)
    case 1n+p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, false_true(h))
    case 1n+ +p 1n+ +q: dle(p, q, h)

# 4 NW = 32 q + r with r <= 32: NW <= 8 (q + 1), the words the storage's capacity fact covers.
def nw_le(+NW: Nat, +q: Nat, +r: Nat, +e: {A.quad(NW) == Nat.add(WS.e32(q), r) : Nat}, +h32: {Nat.is_le(r, 32n) == True{} : Bool})
    -> {Nat.is_le(NW, O.e8(1n+q)) == True{} : Bool}:
  +h1 = F.nat__le_add_left(r, 32n, WS.e32(q), h32)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(WS.e32(q), 32n)) == True{} : Bool}, Nat.add(WS.e32(q), r), A.quad(NW), Equal.sym(Nat, A.quad(NW), Nat.add(WS.e32(q), r), e), h1)
  +h3 = F.logic__subst(Nat, z => {Nat.is_le(A.quad(NW), z) == True{} : Bool}, Nat.add(WS.e32(q), 32n), Nat.add(32n, WS.e32(q)), F.nat__add_comm(WS.e32(q), 32n), h2)
  dle(NW, O.e8(1n+q), dle(Nat.double(NW), Nat.double(O.e8(1n+q)), h3))

# a < a + (1 + p)
def lt_a(+a: Nat, +p: Nat) -> {Nat.is_lt(a, Nat.add(a, 1n+p)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(a, 1n+p), 1n+Nat.add(a, p), F.nat__add_succ(a, p)) : {Nat.is_lt(a, _) == True{} : Bool}
  F.nat__le_lt_succ(a, Nat.add(a, p), F.nat__le_add_right(a, p))

# a + (1 + p) <= P as (1 + a) + p <= P
def le_s(+a: Nat, +p: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(a, 1n+p), P) == True{} : Bool}) -> {Nat.is_le(Nat.add(1n+a, p), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(a, 1n+p), 1n+Nat.add(a, p), F.nat__add_succ(a, p), h)

# A Bool fact at its stated type (to name a closed {==} in a let).
def le_true(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(a, b) == True{} : Bool}: h

# ---- lists ------------------------------------------------------------------------------

law take_upd:
  for +xs: List<&2, U32>
  for +k: Nat
  for +v: U32
  for +h: {Nat.is_lt(k, F.spec_common__length(U32, xs)) == True{} : Bool}
  {F.spec_common__take(U32, F.spec_common__update(U32, xs, k, v), 1n+k) == F.spec_common__snoc(U32, F.spec_common__take(U32, xs, k), v) : List<&2, U32>}
def take_upd(xs, k, v, h):
  match xs k:
    case Nil{} _: Empty.absurd({F.spec_common__take(U32, F.spec_common__update(U32, Nil{}, k, v), 1n+k) == F.spec_common__snoc(U32, F.spec_common__take(U32, Nil{}, k), v) : List<&2, U32>}, F.nat__lt_zero_absurd(k, h))
    case Con{+x, +t} 0n: F.list__cons_cong(U32, v, F.spec_common__take(U32, t, 0n), Nil{}, F.list__sc_take_zero(U32, t))
    case Con{+x, +t} 1n+ +p:
      F.list__cons_cong(U32, x, F.spec_common__take(U32, F.spec_common__update(U32, t, p, v), 1n+p), F.spec_common__snoc(U32, F.spec_common__take(U32, t, p), v), take_upd(t, p, v, h))

law take_snoc:
  for +xs: List<&2, U32>
  for +q: Nat
  for +h: {Nat.is_lt(q, F.spec_common__length(U32, xs)) == True{} : Bool}
  {F.spec_common__take(U32, xs, 1n+q) == F.spec_common__snoc(U32, F.spec_common__take(U32, xs, q), F.flat__nthc(xs, q)) : List<&2, U32>}
def take_snoc(xs, q, h):
  match xs q:
    case Nil{} _: Empty.absurd({F.spec_common__take(U32, Nil{}, 1n+q) == F.spec_common__snoc(U32, F.spec_common__take(U32, Nil{}, q), F.flat__nthc(Nil{}, q)) : List<&2, U32>}, F.nat__lt_zero_absurd(q, h))
    case Con{+x, +t} 0n: F.list__cons_cong(U32, x, F.spec_common__take(U32, t, 0n), Nil{}, F.list__sc_take_zero(U32, t))
    case Con{+x, +t} 1n+ +r:
      F.list__cons_cong(U32, x, F.spec_common__take(U32, t, 1n+r), F.spec_common__snoc(U32, F.spec_common__take(U32, t, r), F.flat__nthc(t, r)), take_snoc(t, r, h))

law len_take:
  for +xs: List<&2, U32>
  for +k: Nat
  for +h: {Nat.is_le(k, F.spec_common__length(U32, xs)) == True{} : Bool}
  {F.spec_common__length(U32, F.spec_common__take(U32, xs, k)) == k : Nat}
def len_take(xs, k, h):
  match xs k:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: Empty.absurd({F.spec_common__length(U32, F.spec_common__take(U32, Nil{}, 1n+p)) == 1n+p : Nat}, false_true(h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      %Equal.sym(Nat, F.spec_common__length(U32, F.spec_common__take(U32, t, p)), p, len_take(t, p, h)) : {1n+_ == 1n+p : Nat}
      {==}

# The words i, i + 1, ... of xs, one by one.
def nl(k: Nat, +xs: List<&2, U32>, +i: Nat) -> List<&2, U32>:
  match k:
    case 0n: []
    case 1n+p: F.flat__nthc(xs, i) <> nl(p, xs, 1n+i)

law nl_shift:
  for +k: Nat
  for +x: U32
  for +t: List<&2, U32>
  for +i: Nat
  {nl(k, Con{x, t}, 1n+i) == nl(k, t, i) : List<&2, U32>}
def nl_shift(k, x, t, i):
  match k:
    case 0n: {==}
    case 1n+ +p: F.list__cons_cong(U32, F.flat__nthc(t, i), nl(p, Con{x, t}, 2n+i), nl(p, t, 1n+i), nl_shift(p, x, t, 1n+i))

law take_nl:
  for +xs: List<&2, U32>
  for +k: Nat
  for +h: {Nat.is_le(k, F.spec_common__length(U32, xs)) == True{} : Bool}
  {F.spec_common__take(U32, xs, k) == nl(k, xs, 0n) : List<&2, U32>}
def take_nl(xs, k, h):
  match xs k:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: Empty.absurd({F.spec_common__take(U32, Nil{}, 1n+p) == nl(1n+p, Nil{}, 0n) : List<&2, U32>}, false_true(h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      %Equal.sym(List<&2, U32>, nl(p, Con{x, t}, 1n), nl(p, t, 0n), nl_shift(p, x, t, 0n)) : {Con{x, F.spec_common__take(U32, t, p)} == Con{x, _} : List<&2, U32>}
      F.list__cons_cong(U32, x, F.spec_common__take(U32, t, p), nl(p, t, 0n), take_nl(t, p, h))

# The first 4m bytes of the limbs of words are the limbs of the first m words.
law btake_limbs:
  for +m: Nat
  for +W: List<&2, U32>
  {WS.btake(A.quad(m), SF.limbs(W)) == SF.limbs(F.spec_common__take(U32, W, m)) : +List<U32>}
def btake_limbs(m, W):
  match m W:
    case 0n Nil{}: {==}
    case 0n Con{+h, +t}: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}:
      %Equal.sym(+List<U32>, WS.btake(A.quad(p), SF.limbs(t)), SF.limbs(F.spec_common__take(U32, t, p)), btake_limbs(p, t)) :
        {U32.and(h, 255) <> U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> _ ==
         U32.and(h, 255) <> U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> SF.limbs(F.spec_common__take(U32, t, p)) : +List<U32>}
      {==}

law bt_limbs:
  for +m: Nat
  for +W: List<&2, U32>
  {VS.bt(A.quad(m), SF.limbs(W)) == SF.limbs(F.spec_common__take(U32, W, m)) : +List<U32>}
def bt_limbs(m, W):
  match m W:
    case 0n Nil{}: {==}
    case 0n Con{+h, +t}: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}:
      %Equal.sym(+List<U32>, VS.bt(A.quad(p), SF.limbs(t)), SF.limbs(F.spec_common__take(U32, t, p)), bt_limbs(p, t)) :
        {U32.and(h, 255) <> U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> _ ==
         U32.and(h, 255) <> U32.and(U32.shrn(h, 8n), 255) <> U32.and(U32.shrn(h, 16n), 255) <> U32.shrn(h, 24n) <> SF.limbs(F.spec_common__take(U32, t, p)) : +List<U32>}
      {==}

# The byte view of word storage of 4k bytes: the limbs of its first k words.
def wview_take(+t: F.array__Tree<U32>, +N: U32, +k: Nat, +e: {U32.to_nat(N) == A.quad(k) : Nat})
    -> {WO.wview(O.Words{F.array__thaw(U32, t), N}) == SF.limbs(F.spec_common__take(U32, F.array__slots(U32, t), k)) : +List<U32>}:
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {WS.btake(U32.to_nat(N), SF.limbs(F.array__slots(U32, _))) == SF.limbs(F.spec_common__take(U32, F.array__slots(U32, t), k)) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(N), A.quad(k), e) :
    {WS.btake(_, SF.limbs(F.array__slots(U32, t))) == SF.limbs(F.spec_common__take(U32, F.array__slots(U32, t), k)) : +List<U32>}
  btake_limbs(k, F.array__slots(U32, t))

# ---- the encoder's output ------------------------------------------------------------------

def out_buf(+n: U32, a: Array<U32>) -> {O.out_done(n, a) == B.Buf{a, n} : B.Buf}: {==}

# listed drops the buffer (the list is the bytes emitted).
def listed_pair(b: B.Buf, +xs: +List<U32>) -> {SF.listed((b, xs)) == xs : +List<U32>}: {==}

# B.emit of the first N words (N a variable, so a copy tree over it never unfolds).
law emit_n:
  for +d: Nat
  for +T: F.array__Tree<U32>
  for +n: U32
  for +k: U32
  for +N: Nat
  for +hk: {Nat.is_eq(U32.to_nat(k), N) == True{} : Bool}
  for +h0: {Nat.is_lt(0n, N) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hK: {Nat.is_le(N, F.spec_common__pow2(d)) == True{} : Bool}
  for +hn: {Nat.is_le(A.quad(N), U32.to_nat(n)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, T) == True{} : Bool}
  {B.emit(B.Buf{F.array__thaw(U32, T), n}, 0, k) == (B.Buf{F.array__thaw(U32, T), n}, SF.limbs(F.spec_common__take(U32, F.array__slots(U32, T), N))) : B.Buf & +List<U32>}
def emit_n(d, T, n, k, N, hk, h0, hd, hK, hn, pf):
  match N:
    case 0n: Empty.absurd({B.emit(B.Buf{F.array__thaw(U32, T), n}, 0, k) == (B.Buf{F.array__thaw(U32, T), n}, SF.limbs(F.spec_common__take(U32, F.array__slots(U32, T), 0n))) : B.Buf & +List<U32>}, false_true(h0))
    case 1n+ +K: AE.emit_take(d, T, n, k, K, hk, hd, F.nat__succ_le_lt(K, F.spec_common__pow2(d), hK), hn, pf)

# ---- the copy of the first k words ------------------------------------------------------

law cpt_pre:
  for +dd: Nat
  for +k: Nat
  for +a: Nat
  for +D: F.array__Tree<U32>
  for +sl: List<&2, U32>
  for +pd: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hk: {Nat.is_le(Nat.add(a, k), F.spec_common__pow2(dd)) == True{} : Bool}
  for +hs: {Nat.is_le(Nat.add(a, k), F.spec_common__length(U32, sl)) == True{} : Bool}
  for +h0: {F.spec_common__take(U32, F.array__slots(U32, D), a) == F.spec_common__take(U32, sl, a) : List<&2, U32>}
  {F.spec_common__take(U32, F.array__slots(U32, AC.cpt(dd, k, a, a, D, sl)), Nat.add(a, k)) == F.spec_common__take(U32, sl, Nat.add(a, k)) : List<&2, U32>}
def cpt_pre(dd, k, a, D, sl, pd, hk, hs, h0):
  match k:
    case 0n:
      %Equal.sym(Nat, Nat.add(a, 0n), a, F.nat__add_zero(a)) :
        {F.spec_common__take(U32, F.array__slots(U32, D), _) == F.spec_common__take(U32, sl, _) : List<&2, U32>}
      h0
    case 1n+ +p:
      +v = F.flat__nthc(sl, a)
      +W = F.array__slots(U32, D)
      +ha = F.nat__lt_le_trans(a, Nat.add(a, 1n+p), F.spec_common__pow2(dd), lt_a(a, p), hk)
      +hsa = F.nat__lt_le_trans(a, Nat.add(a, 1n+p), F.spec_common__length(U32, sl), lt_a(a, p), hs)
      +hW = F.logic__subst(Nat, z => {Nat.is_lt(a, z) == True{} : Bool}, F.spec_common__pow2(dd), F.spec_common__length(U32, W), Equal.sym(Nat, F.spec_common__length(U32, W), F.spec_common__pow2(dd), F.array__slots_length(U32, dd, D, pd)), ha)
      +e1 = F.array__upd_slots(U32, dd, D, a, v, ha, pd)
      +h1 = Equal.trans(List<&2, U32>, F.spec_common__take(U32, F.array__slots(U32, F.array__upd(U32, dd, D, a, v)), 1n+a), F.spec_common__snoc(U32, F.spec_common__take(U32, W, a), v), F.spec_common__take(U32, sl, 1n+a),
        Equal.trans(List<&2, U32>, F.spec_common__take(U32, F.array__slots(U32, F.array__upd(U32, dd, D, a, v)), 1n+a), F.spec_common__take(U32, F.spec_common__update(U32, W, a, v), 1n+a), F.spec_common__snoc(U32, F.spec_common__take(U32, W, a), v),
          Equal.cong(List<&2, U32>, List<&2, U32>, z => F.spec_common__take(U32, z, 1n+a), F.array__slots(U32, F.array__upd(U32, dd, D, a, v)), F.spec_common__update(U32, W, a, v), e1),
          take_upd(W, a, v, hW)),
        Equal.trans(List<&2, U32>, F.spec_common__snoc(U32, F.spec_common__take(U32, W, a), v), F.spec_common__snoc(U32, F.spec_common__take(U32, sl, a), v), F.spec_common__take(U32, sl, 1n+a),
          Equal.cong(List<&2, U32>, List<&2, U32>, z => F.spec_common__snoc(U32, z, v), F.spec_common__take(U32, W, a), F.spec_common__take(U32, sl, a), h0),
          Equal.sym(List<&2, U32>, F.spec_common__take(U32, sl, 1n+a), F.spec_common__snoc(U32, F.spec_common__take(U32, sl, a), v), take_snoc(sl, a, hsa))))
      %Equal.sym(Nat, Nat.add(a, 1n+p), 1n+Nat.add(a, p), F.nat__add_succ(a, p)) :
        {F.spec_common__take(U32, F.array__slots(U32, AC.cpt(dd, p, 1n+a, 1n+a, F.array__upd(U32, dd, D, a, v), sl)), _) == F.spec_common__take(U32, sl, _) : List<&2, U32>}
      cpt_pre(dd, p, 1n+a, F.array__upd(U32, dd, D, a, v), sl, F.array__upd_perfect(U32, dd, D, a, v, pd),
        le_s(a, p, F.spec_common__pow2(dd), hk), le_s(a, p, F.spec_common__length(U32, sl), hs), h1)

# The first k slots of the copy of k words of sl into D are the first k words of sl.
def cpt_take(+dd: Nat, +k: Nat, +D: F.array__Tree<U32>, +sl: List<&2, U32>, +pd: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hk: {Nat.is_le(k, F.spec_common__pow2(dd)) == True{} : Bool}, +hs: {Nat.is_le(k, F.spec_common__length(U32, sl)) == True{} : Bool})
    -> {F.spec_common__take(U32, F.array__slots(U32, AC.cpt(dd, k, 0n, 0n, D, sl)), k) == F.spec_common__take(U32, sl, k) : List<&2, U32>}:
  cpt_pre(dd, k, 0n, D, sl, pd, hk, hs, Equal.trans(List<&2, U32>, F.spec_common__take(U32, F.array__slots(U32, D), 0n), Nil{}, F.spec_common__take(U32, sl, 0n),
    F.list__sc_take_zero(U32, F.array__slots(U32, D)), Equal.sym(List<&2, U32>, F.spec_common__take(U32, sl, 0n), Nil{}, F.list__sc_take_zero(U32, sl))))

# ac_tail of k words from S (depth ds) into D (depth dd): the copy cpt.
law actl:
  for +k: Nat
  for +a: U32
  for +b: U32
  for +Ai: Nat
  for +Bi: Nat
  for +ds: Nat
  for +dd: Nat
  for +S: F.array__Tree<U32>
  for +D: F.array__Tree<U32>
  for +ea: {U32.to_nat(a) == Ai : Nat}
  for +eb: {U32.to_nat(b) == Bi : Nat}
  for +hs: {Nat.is_lt(ds, 32n) == True{} : Bool}
  for +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}
  for +hA: {Nat.is_le(Nat.add(Ai, k), F.spec_common__pow2(ds)) == True{} : Bool}
  for +hB: {Nat.is_le(Nat.add(Bi, k), F.spec_common__pow2(dd)) == True{} : Bool}
  for +ps: {F.array__perfect(U32, ds, S) == True{} : Bool}
  for +pd: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {O.ac_tail(k, a, b, (F.array__thaw(U32, D), F.array__thaw(U32, S))) == (F.array__thaw(U32, AC.cpt(dd, k, Ai, Bi, D, F.array__slots(U32, S))), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
def actl(k, a, b, Ai, Bi, ds, dd, S, D, ea, eb, hs, hdd, hA, hB, ps, pd):
  match k:
    case 0n: {==}
    case 1n+ +p:
      +sl = F.array__slots(U32, S)
      +v = F.flat__nthc(sl, Ai)
      +PS = F.spec_common__pow2(ds)
      +PD = F.spec_common__pow2(dd)
      +ltA = F.nat__lt_le_trans(Ai, Nat.add(Ai, 1n+p), PS, lt_a(Ai, p), hA)
      +ltB = F.nat__lt_le_trans(Bi, Nat.add(Bi, 1n+p), PD, lt_a(Bi, p), hB)
      +ea1 = AC.ix(a, 1, Ai, ds, ea, hs, F.nat__lt_succ_le_succ(Ai, PS, ltA))
      +eb1 = AC.ix(b, 1, Bi, dd, eb, hdd, F.nat__lt_succ_le_succ(Bi, PD, ltB))
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), a), (F.array__thaw(U32, S), v), AC.getv(ds, S, a, Ai, ea, hs, ltA, ps)) :
        {O.ac_tail(p, (a + 1 : U32), (b + 1 : U32), O.ac_w(b, F.array__thaw(U32, D), _)) == (F.array__thaw(U32, AC.cpt(dd, 1n+p, Ai, Bi, D, sl)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
      %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), b, v), F.array__thaw(U32, F.array__upd(U32, dd, D, Bi, v)), AC.setv(dd, D, b, Bi, v, eb, hdd, ltB, pd)) :
        {O.ac_tail(p, (a + 1 : U32), (b + 1 : U32), (_, F.array__thaw(U32, S))) == (F.array__thaw(U32, AC.cpt(dd, 1n+p, Ai, Bi, D, sl)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
      actl(p, (a + 1 : U32), (b + 1 : U32), 1n+Ai, 1n+Bi, ds, dd, S, F.array__upd(U32, dd, D, Bi, v), ea1, eb1, hs, hdd,
        le_s(Ai, p, PS, hA), le_s(Bi, p, PD, hB), ps, F.array__upd_perfect(U32, dd, D, Bi, v, pd))

# it4 (the view of a packed vector of 4-byte integers) is chu1 (arr_vec) of the first 1k words.
law it4c:
  for +k: Nat
  for +W: List<&2, U32>
  {PK.it4(k, W) == AV.chu1(F.spec_common__take(U32, W, AV.m1(k))) : S.Value}
def it4c(k, W):
  match k:
    case 0n:
      match W:
        case Nil{}: {==}
        case Con{+a, +r}: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a0, +r0}:
          %Equal.sym(S.Value, PK.it4(c, r0), AV.chu1(F.spec_common__take(U32, r0, AV.m1(c))), it4c(c, r0)) :
            {S.Items{S.UnsignedValue{P.UInt{a0, 0, 0, 0, 0, 0, 0, 0}}, _} == AV.chu1(Con{a0, F.spec_common__take(U32, r0, AV.m1(c))}) : S.Value}
          {==}

# it8 (the view of a packed vector of 8-byte integers) is chu2 (arr_vec) of the first 2k words.
law it8c:
  for +k: Nat
  for +W: List<&2, U32>
  {PK.it8(k, W) == AV.chu2(F.spec_common__take(U32, W, AV.m2(k))) : S.Value}
def it8c(k, W):
  match k:
    case 0n:
      match W:
        case Nil{}: {==}
        case Con{+a, +r}: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a0, +r0}:
          match r0:
            case Nil{}: {==}
            case Con{+a1, +r1}:
              %Equal.sym(S.Value, PK.it8(c, r1), AV.chu2(F.spec_common__take(U32, r1, AV.m2(c))), it8c(c, r1)) :
                {S.Items{S.UnsignedValue{P.UInt{a0, a1, 0, 0, 0, 0, 0, 0}}, _} == AV.chu2(Con{a0, Con{a1, F.spec_common__take(U32, r1, AV.m2(c))}}) : S.Value}
              {==}

# it16 (the view of a packed vector of 16-byte integers) is chu4 (arr_vec) of the first 4k words.
law it16c:
  for +k: Nat
  for +W: List<&2, U32>
  {PK.it16(k, W) == AV.chu4(F.spec_common__take(U32, W, AV.m4(k))) : S.Value}
def it16c(k, W):
  match k:
    case 0n:
      match W:
        case Nil{}: {==}
        case Con{+a, +r}: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a0, +r0}:
          match r0:
            case Nil{}: {==}
            case Con{+a1, +r1}:
              match r1:
                case Nil{}: {==}
                case Con{+a2, +r2}:
                  match r2:
                    case Nil{}: {==}
                    case Con{+a3, +r3}:
                      %Equal.sym(S.Value, PK.it16(c, r3), AV.chu4(F.spec_common__take(U32, r3, AV.m4(c))), it16c(c, r3)) :
                        {S.Items{S.UnsignedValue{P.UInt{a0, a1, a2, a3, 0, 0, 0, 0}}, _} == AV.chu4(Con{a0, Con{a1, Con{a2, Con{a3, F.spec_common__take(U32, r3, AV.m4(c))}}}}) : S.Value}
                      {==}

# it32 (the view of a packed vector of 32-byte integers) is chu8 (arr_vec) of the first 8k words.
law it32c:
  for +k: Nat
  for +W: List<&2, U32>
  {PK.it32(k, W) == AV.chu8(F.spec_common__take(U32, W, AV.m8(k))) : S.Value}
def it32c(k, W):
  match k:
    case 0n:
      match W:
        case Nil{}: {==}
        case Con{+a, +r}: {==}
    case 1n+ +c:
      match W:
        case Nil{}: {==}
        case Con{+a0, +r0}:
          match r0:
            case Nil{}: {==}
            case Con{+a1, +r1}:
              match r1:
                case Nil{}: {==}
                case Con{+a2, +r2}:
                  match r2:
                    case Nil{}: {==}
                    case Con{+a3, +r3}:
                      match r3:
                        case Nil{}: {==}
                        case Con{+a4, +r4}:
                          match r4:
                            case Nil{}: {==}
                            case Con{+a5, +r5}:
                              match r5:
                                case Nil{}: {==}
                                case Con{+a6, +r6}:
                                  match r6:
                                    case Nil{}: {==}
                                    case Con{+a7, +r7}:
                                      %Equal.sym(S.Value, PK.it32(c, r7), AV.chu8(F.spec_common__take(U32, r7, AV.m8(c))), it32c(c, r7)) :
                                        {S.Items{S.UnsignedValue{P.UInt{a0, a1, a2, a3, a4, a5, a6, a7}}, _} == AV.chu8(Con{a0, Con{a1, Con{a2, Con{a3, Con{a4, Con{a5, Con{a6, Con{a7, F.spec_common__take(U32, r7, AV.m8(c))}}}}}}}}) : S.Value}
                                      {==}

