import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vdepth.bend as VD
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ../compact/buf.bend as BF
import ../compact/reads.bend as RD

# Byte lists at lengths that are not whole words (codegen/var_bytes.py).
# The input copy O.copy_in keeps only the n & 3 low bytes of its last word
# (O.mask_last); here, symbolically in the length: what the copy returns on
# the array model (copy_in_any), and that the masked storage has the same first
# n bytes as the copied words (mk_bytes).

# ---- bits ------------------------------------------------------------------------------------

def band_assoc(+x: Bool, +y: Bool, +z: Bool) -> {Bool.and(Bool.and(x, y), z) == Bool.and(x, Bool.and(y, z)) : Bool}:
  match x:
    case False{}: {==}
    case True{}: {==}

law wand_assoc:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  for +c: Word(n)
  {Word.and(n, Word.and(n, a, b), c) == Word.and(n, a, Word.and(n, b, c)) : Word(n)}
def wand_assoc(n, a, b, c):
  match n a b c:
    case 0n WNil{} WNil{} WNil{}: {==}
    case 1n+ +p WCon{+x, +s} WCon{+y, +r} WCon{+z, +q}:
      %Equal.sym(Bool, Bool.and(Bool.and(x, y), z), Bool.and(x, Bool.and(y, z)), band_assoc(x, y, z)) : {WCon{_, Word.and(p, Word.and(p, s, r), q)} == WCon{Bool.and(x, Bool.and(y, z)), Word.and(p, s, Word.and(p, r, q))} : Word(1n+p)}
      %Equal.sym(Word(p), Word.and(p, Word.and(p, s, r), q), Word.and(p, s, Word.and(p, r, q)), wand_assoc(p, s, r, q)) : {WCon{Bool.and(x, Bool.and(y, z)), _} == WCon{Bool.and(x, Bool.and(y, z)), Word.and(p, s, Word.and(p, r, q))} : Word(1n+p)}
      {==}

law and_assoc:
  for +a: U32
  for +b: U32
  for +c: U32
  {U32.and(U32.and(a, b), c) == U32.and(a, U32.and(b, c)) : U32}
def and_assoc(a, b, c):
  match a b c:
    case U32{+x} U32{+y} U32{+z}:
      %Equal.sym(Word(32n), Word.and(32n, Word.and(32n, x, y), z), Word.and(32n, x, Word.and(32n, y, z)), wand_assoc(32n, x, y, z)) : {U32{_} == U32{Word.and(32n, x, Word.and(32n, y, z))} : U32}
      {==}

law pad_and:
  for +p: Nat
  for +a: Word(p)
  for +b: Word(p)
  {Word.shr.pad(p, Word.and(p, a, b)) == Word.and(1n+p, Word.shr.pad(p, a), Word.shr.pad(p, b)) : Word(1n+p)}
def pad_and(p, a, b):
  match p a b:
    case 0n WNil{} WNil{}: {==}
    case 1n+ +q WCon{+x, +s} WCon{+y, +r}:
      %Equal.sym(Word(1n+q), Word.shr.pad(q, Word.and(q, s, r)), Word.and(1n+q, Word.shr.pad(q, s), Word.shr.pad(q, r)), pad_and(q, s, r)) : {WCon{Bool.and(x, y), _} == WCon{Bool.and(x, y), Word.and(1n+q, Word.shr.pad(q, s), Word.shr.pad(q, r))} : Word(2n+q)}
      {==}

law shr_and:
  for +a: U32
  for +b: U32
  {U32.shr(U32.and(a, b)) == U32.and(U32.shr(a), U32.shr(b)) : U32}
def shr_and(a, b):
  match a b:
    case U32{WCon{+x, +s}} U32{WCon{+y, +r}}:
      %Equal.sym(Word(32n), Word.shr.pad(31n, Word.and(31n, s, r)), Word.and(32n, Word.shr.pad(31n, s), Word.shr.pad(31n, r)), pad_and(31n, s, r)) : {U32{_} == U32{Word.and(32n, Word.shr.pad(31n, s), Word.shr.pad(31n, r))} : U32}
      {==}

law shrn_and:
  for +k: Nat
  for +a: U32
  for +b: U32
  {U32.shrn(U32.and(a, b), k) == U32.and(U32.shrn(a, k), U32.shrn(b, k)) : U32}
def shrn_and(k, a, b):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(U32, U32.shrn(U32.and(a, b), p), U32.and(U32.shrn(a, p), U32.shrn(b, p)), shrn_and(p, a, b)) : {U32.shr(_) == U32.and(U32.shr(U32.shrn(a, p)), U32.shr(U32.shrn(b, p))) : U32}
      shr_and(U32.shrn(a, p), U32.shrn(b, p))

# Byte j of (x & M) is byte j of x when the mask keeps byte j: (M >> 8j) & 255 = 255.
def sel_mask(+x: U32, +M: U32, +k: Nat, +h: {U32.and(U32.shrn(M, k), 255) == 255 : U32})
    -> {U32.and(U32.shrn(U32.and(x, M), k), 255) == U32.and(U32.shrn(x, k), 255) : U32}:
  %Equal.sym(U32, U32.shrn(U32.and(x, M), k), U32.and(U32.shrn(x, k), U32.shrn(M, k)), shrn_and(k, x, M)) : {U32.and(_, 255) == U32.and(U32.shrn(x, k), 255) : U32}
  %Equal.sym(U32, U32.and(U32.and(U32.shrn(x, k), U32.shrn(M, k)), 255), U32.and(U32.shrn(x, k), U32.and(U32.shrn(M, k), 255)), and_assoc(U32.shrn(x, k), U32.shrn(M, k), 255)) : {_ == U32.and(U32.shrn(x, k), 255) : U32}
  %Equal.sym(U32, U32.and(U32.shrn(M, k), 255), 255, h) : {U32.and(U32.shrn(x, k), _) == U32.and(U32.shrn(x, k), 255) : U32}
  {==}

# The first r bytes of a word are kept by O.keep(r, _), r = 1, 2, 3.
def keep1(+x: U32) -> {VS.bt(1n, I.limb(O.keep(1, x))) == VS.bt(1n, I.limb(x)) : +List<U32>}:
  %Equal.sym(U32, U32.and(U32.shrn(U32.and(x, 255), 0n), 255), U32.and(U32.shrn(x, 0n), 255), sel_mask(x, 255, 0n, {==})) : {[_] == [U32.and(x, 255)] : +List<U32>}
  {==}

def keep2(+x: U32) -> {VS.bt(2n, I.limb(O.keep(2, x))) == VS.bt(2n, I.limb(x)) : +List<U32>}:
  %Equal.sym(U32, U32.and(U32.shrn(U32.and(x, 65535), 0n), 255), U32.and(U32.shrn(x, 0n), 255), sel_mask(x, 65535, 0n, {==})) : {[_, U32.and(U32.shrn(U32.and(x, 65535), 8n), 255)] == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)] : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(U32.and(x, 65535), 8n), 255), U32.and(U32.shrn(x, 8n), 255), sel_mask(x, 65535, 8n, {==})) : {[U32.and(x, 255), _] == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)] : +List<U32>}
  {==}

def keep3(+x: U32) -> {VS.bt(3n, I.limb(O.keep(3, x))) == VS.bt(3n, I.limb(x)) : +List<U32>}:
  %Equal.sym(U32, U32.and(U32.shrn(U32.and(x, 16777215), 0n), 255), U32.and(U32.shrn(x, 0n), 255), sel_mask(x, 16777215, 0n, {==})) : {[_, U32.and(U32.shrn(U32.and(x, 16777215), 8n), 255), U32.and(U32.shrn(U32.and(x, 16777215), 16n), 255)] == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), U32.and(U32.shrn(x, 16n), 255)] : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(U32.and(x, 16777215), 8n), 255), U32.and(U32.shrn(x, 8n), 255), sel_mask(x, 16777215, 8n, {==})) : {[U32.and(x, 255), _, U32.and(U32.shrn(U32.and(x, 16777215), 16n), 255)] == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), U32.and(U32.shrn(x, 16n), 255)] : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(U32.and(x, 16777215), 16n), 255), U32.and(U32.shrn(x, 16n), 255), sel_mask(x, 16777215, 16n, {==})) : {[U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), _] == [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), U32.and(U32.shrn(x, 16n), 255)] : +List<U32>}
  {==}

# The first r bytes of O.keep(L & 3, x) are those of x, r = L & 3.
def keep_bits(+b0: Bool, +b1: Bool, +x: U32)
    -> {VS.bt(U32.to_nat(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}), I.limb(O.keep(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}, x))) == VS.bt(U32.to_nat(U32{WCon{b0, WCon{b1, Word.zero(30n)}}}), I.limb(x)) : +List<U32>}:
  match b0 b1:
    case False{} False{}: {==}
    case True{} False{}: keep1(x)
    case False{} True{}: keep2(x)
    case True{} True{}: keep3(x)

law keep_rm:
  for +L: U32
  for +x: U32
  {VS.bt(U32.to_nat(U32.and(L, 3)), I.limb(O.keep(U32.and(L, 3), x))) == VS.bt(U32.to_nat(U32.and(L, 3)), I.limb(x)) : +List<U32>}
def keep_rm(L, x):
  match L:
    case U32{WCon{+b0, WCon{+b1, +r}}}:
      %BF.low_sel(b0, b1, r) : {VS.bt(U32.to_nat(_), I.limb(O.keep(_, x))) == VS.bt(U32.to_nat(_), I.limb(x)) : +List<U32>}
      keep_bits(b0, b1, x)

# ---- byte prefixes of word lists -----------------------------------------------------------

def bt_head(+r: Nat, +v: U32, +w: U32, +X: +List<U32>, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +h: {VS.bt(r, I.limb(v)) == VS.bt(r, I.limb(w)) : +List<U32>})
    -> {VS.bt(r, List.append(&2, U32, I.limb(v), X)) == VS.bt(r, List.append(&2, U32, I.limb(w), X)) : +List<U32>}:
  match r:
    case 0n: {==}
    case 1n: h
    case 2n: h
    case 3n: h
    case 4n+ +q: Empty.absurd({VS.bt(4n+q, List.append(&2, U32, I.limb(v), X)) == VS.bt(4n+q, List.append(&2, U32, I.limb(w), X)) : +List<U32>}, F.nat__lt_zero_absurd(q, hr))

# Replacing word k by a word with the same first r bytes (r < 4) keeps the first 4k + r bytes.
law bt_upd:
  for +k: Nat
  for +r: Nat
  for +W: List<&2, U32>
  for +v: U32
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +h: {VS.bt(r, I.limb(v)) == VS.bt(r, I.limb(F.flat__nthc(W, k))) : +List<U32>}
  for +hk: {Nat.is_lt(k, VB.len(W)) == True{} : Bool}
  {VS.bt(Nat.add(A.quad(k), r), FX.limbs(F.spec_common__update(U32, W, k, v))) == VS.bt(Nat.add(A.quad(k), r), FX.limbs(W)) : +List<U32>}
def bt_upd(k, r, W, v, hr, h, hk):
  match k W:
    case 0n Nil{}: Empty.absurd({VS.bt(Nat.add(A.quad(0n), r), FX.limbs(F.spec_common__update(U32, Nil{}, 0n, v))) == VS.bt(Nat.add(A.quad(0n), r), FX.limbs(Nil{})) : +List<U32>}, F.logic__false_true(hk))
    case 1n+ +p Nil{}: Empty.absurd({VS.bt(Nat.add(A.quad(1n+p), r), FX.limbs(F.spec_common__update(U32, Nil{}, 1n+p, v))) == VS.bt(Nat.add(A.quad(1n+p), r), FX.limbs(Nil{})) : +List<U32>}, F.logic__false_true(hk))
    case 0n Con{+w, +t}: bt_head(r, v, w, FX.limbs(t), hr, h)
    case 1n+ +p Con{+w, +t}:
      %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(p), r), FX.limbs(F.spec_common__update(U32, t, p, v))), VS.bt(Nat.add(A.quad(p), r), FX.limbs(t)), bt_upd(p, r, t, v, hr, h, hk)) :
        {List.append(&2, U32, I.limb(w), _) == List.append(&2, U32, I.limb(w), VS.bt(Nat.add(A.quad(p), r), FX.limbs(t))) : +List<U32>}
      {==}

# The first 4 H + m bytes of the limbs of W: the limbs of its first H words, then m bytes of the rest.
law bt_split:
  for +H: Nat
  for +m: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(H, VB.len(W)) == True{} : Bool}
  {VS.bt(Nat.add(A.quad(H), m), FX.limbs(W)) == List.append(&2, U32, FX.limbs(VS.wtake(H, W)), VS.bt(m, FX.limbs(VB.wdr(H, W)))) : +List<U32>}
def bt_split(H, m, W, h):
  match H W:
    case 0n +W0: {==}
    case 1n+ +p Nil{}: Empty.absurd({VS.bt(Nat.add(A.quad(1n+p), m), FX.limbs(Nil{})) == List.append(&2, U32, FX.limbs(VS.wtake(1n+p, Nil{})), VS.bt(m, FX.limbs(VB.wdr(1n+p, Nil{})))) : +List<U32>}, F.logic__false_true(h))
    case 1n+ +p Con{+w, +t}:
      %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(p), m), FX.limbs(t)), List.append(&2, U32, FX.limbs(VS.wtake(p, t)), VS.bt(m, FX.limbs(VB.wdr(p, t)))), bt_split(p, m, t, h)) :
        {List.append(&2, U32, I.limb(w), _) == List.append(&2, U32, List.append(&2, U32, I.limb(w), FX.limbs(VS.wtake(p, t))), VS.bt(m, FX.limbs(VB.wdr(p, t)))) : +List<U32>}
      {==}

law bt_take:
  for +K: Nat
  for +m: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(m, A.quad(K)) == True{} : Bool}
  {VS.bt(m, FX.limbs(VS.wtake(K, W))) == VS.bt(m, FX.limbs(W)) : +List<U32>}
def bt_take(K, m, W, h):
  match K m W:
    case 0n 0n +W0: {==}
    case 0n 1n+ +q +W0: Empty.absurd({VS.bt(1n+q, FX.limbs(VS.wtake(0n, W0))) == VS.bt(1n+q, FX.limbs(W0)) : +List<U32>}, F.logic__false_true(h))
    case 1n+ +p +m0 Nil{}: {==}
    case 1n+ +p 0n Con{+w, +t}: {==}
    case 1n+ +p 1n Con{+w, +t}: {==}
    case 1n+ +p 2n Con{+w, +t}: {==}
    case 1n+ +p 3n Con{+w, +t}: {==}
    case 1n+ +p 4n+ +q Con{+w, +t}:
      %Equal.sym(+List<U32>, VS.bt(q, FX.limbs(VS.wtake(p, t))), VS.bt(q, FX.limbs(t)), bt_take(p, q, t, h)) :
        {List.append(&2, U32, I.limb(w), _) == List.append(&2, U32, I.limb(w), VS.bt(q, FX.limbs(t))) : +List<U32>}
      {==}

# ---- the masked word's index ----------------------------------------------------------------

law succ_le_lt:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(1n+a, b) == True{} : Bool}
  {Nat.is_lt(a, b) == True{} : Bool}
def succ_le_lt(a, b, h):
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 0n: Empty.absurd({Nat.is_lt(1n+p, 0n) == True{} : Bool}, F.logic__false_true(h))
    case 0n 1n+ +q: {==}
    case 1n+ +p 1n+ +q: succ_le_lt(p, q, h)

def rng2_r(+r: Nat, +h0: {Nat.is_eq(r, 0n) == False{} : Bool}, +h3: {Nat.is_le(r, 3n) == True{} : Bool})
    -> {VD.s_rng(2n, 3n+Nat.add(A.quad(0n), r)) == 1n : Nat}:
  match r:
    case 0n: Empty.absurd({VD.s_rng(2n, 3n+Nat.add(A.quad(0n), 0n)) == 1n : Nat}, F.logic__false_true(Equal.sym(Bool, True{}, False{}, h0)))
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +s: Empty.absurd({VD.s_rng(2n, 3n+Nat.add(A.quad(0n), 4n+s)) == 1n : Nat}, F.logic__false_true(h3))

# (3 + 4 q + r) / 4 = q + 1 for r = 1, 2, 3.
law rng2_q:
  for +q: Nat
  for +r: Nat
  for +h0: {Nat.is_eq(r, 0n) == False{} : Bool}
  for +h3: {Nat.is_le(r, 3n) == True{} : Bool}
  {VD.s_rng(2n, 3n+Nat.add(A.quad(q), r)) == 1n+q : Nat}
def rng2_q(q, r, h0, h3):
  match q:
    case 0n: rng2_r(r, h0, h3)
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_rng(2n, 3n+Nat.add(A.quad(p), r)), 1n+p, rng2_q(p, r, h0, h3)) : {1n+_ == 2n+p : Nat}
      {==}

def RM(+L: U32) -> U32: U32.and(L, 3)
def QL(+L: U32) -> Nat: U32.to_nat(U32.shrn(L, 2n))
# The index of the masked word (O.mask_last's).
def KW(+L: U32) -> Nat: U32.to_nat(U32.sub(VC.nwu(L), 1))

def rm_ne(+L: U32, +hb: {U32.is_eq(RM(L), 0) == False{} : Bool}) -> {Nat.is_eq(U32.to_nat(RM(L)), 0n) == False{} : Bool}:
  %VD.eq0(RM(L)) : {_ == False{} : Bool}
  hb

# A length with a partial last word: NW = q + 1 words, q = L >> 2.
def nw_qU(+L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hb: {U32.is_eq(RM(L), 0) == False{} : Bool})
    -> {VC.NW(L) == 1n+QL(L) : Nat}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, 3n+U32.to_nat(L)), VC.eNWu(L, hy)) : {_ == 1n+QL(L) : Nat}
  %Equal.sym(Nat, U32.to_nat(L), Nat.add(A.quad(QL(L)), U32.to_nat(RM(L))), VC.split4(L)) : {VD.s_rng(2n, 3n+_) == 1n+QL(L) : Nat}
  rng2_q(QL(L), U32.to_nat(RM(L)), rm_ne(L, hb), RD.and_le(L, 3))

def nw_q(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +hb: {U32.is_eq(RM(L), 0) == False{} : Bool})
    -> {VC.NW(L) == 1n+QL(L) : Nat}:
  nw_qU(L, VC.hyU(L, k, hk, hy), hb)

def FD_le1(+x: Nat, +q: Nat, +e: {x == 1n+q : Nat}) -> {Nat.is_le(1n, x) == True{} : Bool}:
  %Equal.sym(Nat, x, 1n+q, e) : {Nat.is_le(1n, _) == True{} : Bool}
  Order.zero_le(q)

def kw_qU(+L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hb: {U32.is_eq(RM(L), 0) == False{} : Bool})
    -> {KW(L) == QL(L) : Nat}:
  +e = nw_qU(L, hy, hb)
  +h1 = FD_le1(VC.NW(L), QL(L), e)
  %Equal.sym(Nat, KW(L), Nat.sub(VC.NW(L), 1n), F.u32__sub_nat(VC.nwu(L), 1, h1)) : {_ == QL(L) : Nat}
  %Equal.sym(Nat, VC.NW(L), 1n+QL(L), e) : {Nat.sub(_, 1n) == QL(L) : Nat}
  F.nat__sub_zero(QL(L))

def kw_q(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +hb: {U32.is_eq(RM(L), 0) == False{} : Bool})
    -> {KW(L) == QL(L) : Nat}:
  kw_qU(L, VC.hyU(L, k, hk, hy), hb)

def kw_ltU(+L: U32, +dz: Nat, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hb: {U32.is_eq(RM(L), 0) == False{} : Bool}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool})
    -> {Nat.is_lt(KW(L), VB.pw(dz)) == True{} : Bool}:
  %Equal.sym(Nat, KW(L), QL(L), kw_qU(L, hy, hb)) : {Nat.is_lt(_, VB.pw(dz)) == True{} : Bool}
  succ_le_lt(QL(L), VB.pw(dz), F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, VC.NW(L), 1n+QL(L), nw_qU(L, hy, hb), hr))

def kw_lt(+L: U32, +dz: Nat, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +hb: {U32.is_eq(RM(L), 0) == False{} : Bool}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool})
    -> {Nat.is_lt(KW(L), VB.pw(dz)) == True{} : Bool}:
  kw_ltU(L, dz, VC.hyU(L, k, hk, hy), hb, hr)

# ---- the masked storage -----------------------------------------------------------------------

def mk(b: Bool, +L: U32, +dz: Nat, +M: F.array__Tree<U32>) -> F.array__Tree<U32>:
  match b:
    case True{}: M
    case False{}: F.array__upd(U32, dz, M, KW(L), O.keep(RM(L), VB.slot(M, KW(L))))

# The storage O.mask_last(L, _) leaves of the words M.
def MK(+L: U32, +dz: Nat, +M: F.array__Tree<U32>) -> F.array__Tree<U32>: mk(U32.is_eq(RM(L), 0), L, dz, M)

def mask_goU(+b: Bool, +L: U32, +dz: Nat, +M: F.array__Tree<U32>, +eb: {U32.is_eq(RM(L), 0) == b : Bool}, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hdz: {Nat.is_lt(dz, 32n) == True{} : Bool}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool},
    +pf: {F.array__perfect(U32, dz, M) == True{} : Bool})
    -> {O.ml_go(b, RM(L), U32.sub(VC.nwu(L), 1), F.array__thaw(U32, M)) == F.array__thaw(U32, mk(b, L, dz, M)) : Array<U32>}:
  match b:
    case True{}: {==}
    case False{}:
      +hkw = kw_ltU(L, dz, hy, eb, hr)
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, M), U32.sub(VC.nwu(L), 1)), (F.array__thaw(U32, M), VB.slot(M, KW(L))),
          VB.get_n(dz, M, U32.sub(VC.nwu(L), 1), KW(L), {==}, hdz, hkw, pf)) :
        {O.ml_set(RM(L), U32.sub(VC.nwu(L), 1), _) == F.array__thaw(U32, mk(False{}, L, dz, M)) : Array<U32>}
      VB.set_n(dz, M, U32.sub(VC.nwu(L), 1), KW(L), O.keep(RM(L), VB.slot(M, KW(L))), {==}, hdz, hkw, pf)

def mask_go(+b: Bool, +L: U32, +dz: Nat, +M: F.array__Tree<U32>, +k: Nat, +eb: {U32.is_eq(RM(L), 0) == b : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +hdz: {Nat.is_lt(dz, 32n) == True{} : Bool}, +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool},
    +pf: {F.array__perfect(U32, dz, M) == True{} : Bool})
    -> {O.ml_go(b, RM(L), U32.sub(VC.nwu(L), 1), F.array__thaw(U32, M)) == F.array__thaw(U32, mk(b, L, dz, M)) : Array<U32>}:
  mask_goU(b, L, dz, M, eb, VC.hyU(L, k, hk, hy), hdz, hr, pf)

law mask_okU:
  for +L: U32
  for +dz: Nat
  for +M: F.array__Tree<U32>
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 32n) == True{} : Bool}
  for +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dz, M) == True{} : Bool}
  {O.mask_last(L, F.array__thaw(U32, M)) == F.array__thaw(U32, MK(L, dz, M)) : Array<U32>}
def mask_okU(L, dz, M, hy, hdz, hr, pf):
  mask_goU(U32.is_eq(RM(L), 0), L, dz, M, {==}, hy, hdz, hr, pf)

law mask_ok:
  for +L: U32
  for +dz: Nat
  for +M: F.array__Tree<U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 32n) == True{} : Bool}
  for +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dz, M) == True{} : Bool}
  {O.mask_last(L, F.array__thaw(U32, M)) == F.array__thaw(U32, MK(L, dz, M)) : Array<U32>}
def mask_ok(L, dz, M, k, hk, hy, hdz, hr, pf):
  mask_okU(L, dz, M, VC.hyU(L, k, hk, hy), hdz, hr, pf)

def mkp_go(+b: Bool, +L: U32, +dz: Nat, +M: F.array__Tree<U32>, +pf: {F.array__perfect(U32, dz, M) == True{} : Bool})
    -> {F.array__perfect(U32, dz, mk(b, L, dz, M)) == True{} : Bool}:
  match b:
    case True{}: pf
    case False{}: F.array__upd_perfect(U32, dz, M, KW(L), O.keep(RM(L), VB.slot(M, KW(L))), pf)

law mk_perfect:
  for +L: U32
  for +dz: Nat
  for +M: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, dz, M) == True{} : Bool}
  {F.array__perfect(U32, dz, MK(L, dz, M)) == True{} : Bool}
def mk_perfect(L, dz, M, pf):
  mkp_go(U32.is_eq(RM(L), 0), L, dz, M, pf)

def mkb_goU(+b: Bool, +L: U32, +dz: Nat, +M: F.array__Tree<U32>, +eb: {U32.is_eq(RM(L), 0) == b : Bool}, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool}, +pf: {F.array__perfect(U32, dz, M) == True{} : Bool})
    -> {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, mk(b, L, dz, M)))) == VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, M))) : +List<U32>}:
  match b:
    case True{}: {==}
    case False{}:
      +hkw = kw_ltU(L, dz, hy, eb, hr)
      +v = O.keep(RM(L), VB.slot(M, KW(L)))
      +e1 = Equal.trans(Nat, U32.to_nat(L), Nat.add(A.quad(QL(L)), U32.to_nat(RM(L))), Nat.add(A.quad(KW(L)), U32.to_nat(RM(L))), VC.split4(L),
        Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), U32.to_nat(RM(L))), QL(L), KW(L), Equal.sym(Nat, KW(L), QL(L), kw_qU(L, hy, eb))))
      +hkl = F.logic__subst(Nat, z => {Nat.is_lt(KW(L), z) == True{} : Bool}, VB.pw(dz), VB.len(F.array__slots(U32, M)), Equal.sym(Nat, VB.len(F.array__slots(U32, M)), VB.pw(dz), F.array__slots_length(U32, dz, M, pf)), hkw)
      %Equal.sym(List<&2, U32>, F.array__slots(U32, F.array__upd(U32, dz, M, KW(L), v)), F.spec_common__update(U32, F.array__slots(U32, M), KW(L), v), F.array__upd_slots(U32, dz, M, KW(L), v, hkw, pf)) :
        {VS.bt(U32.to_nat(L), FX.limbs(_)) == VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, M))) : +List<U32>}
      %Equal.sym(Nat, U32.to_nat(L), Nat.add(A.quad(KW(L)), U32.to_nat(RM(L))), e1) : {VS.bt(_, FX.limbs(F.spec_common__update(U32, F.array__slots(U32, M), KW(L), v))) == VS.bt(_, FX.limbs(F.array__slots(U32, M))) : +List<U32>}
      bt_upd(KW(L), U32.to_nat(RM(L)), F.array__slots(U32, M), v, F.nat__le_lt_trans(U32.to_nat(RM(L)), 3n, 4n, RD.and_le(L, 3), {==}),
        keep_rm(L, VB.slot(M, KW(L))), hkl)

def mkb_go(+b: Bool, +L: U32, +dz: Nat, +M: F.array__Tree<U32>, +k: Nat, +eb: {U32.is_eq(RM(L), 0) == b : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool}, +pf: {F.array__perfect(U32, dz, M) == True{} : Bool})
    -> {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, mk(b, L, dz, M)))) == VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, M))) : +List<U32>}:
  mkb_goU(b, L, dz, M, eb, VC.hyU(L, k, hk, hy), hr, pf)

# The masked storage has the words' first L bytes.
law mk_bytesU:
  for +L: U32
  for +dz: Nat
  for +M: F.array__Tree<U32>
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dz, M) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, MK(L, dz, M)))) == VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, M))) : +List<U32>}
def mk_bytesU(L, dz, M, hy, hr, pf):
  mkb_goU(U32.is_eq(RM(L), 0), L, dz, M, {==}, hy, hr, pf)

law mk_bytes:
  for +L: U32
  for +dz: Nat
  for +M: F.array__Tree<U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  for +hr: {Nat.is_le(VC.NW(L), VB.pw(dz)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dz, M) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, MK(L, dz, M)))) == VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, M))) : +List<U32>}
def mk_bytes(L, dz, M, k, hk, hy, hr, pf):
  mk_bytesU(L, dz, M, VC.hyU(L, k, hk, hy), hr, pf)

# ---- the copy ---------------------------------------------------------------------------------

def ci_anyU(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +L: U32, +dz: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +h3: {U32.and(off, 3) == 0 : U32}, +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(L, 0) == z : Bool})
    -> {O.ci_fin(n, L, O.ci_go(z, U32.and(off, 3), U32.shrn(off, 2n), VC.nwu(L), F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)))
        == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}:
  match z:
    case True{}:
      +eL = F.u32alg__eq_of(L, 0, ez)
      %Equal.sym(U32, L, 0, eL) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{O.mask_last(_, F.array__thaw(U32, VC.ZT(dz))), _}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(_, dz, VB.mone(VC.NW(_), i, 0n, dz, VC.ZT(dz), t))), _}) : B.Buf & O.Words}
      {==}
    case False{}:
      +Mo = VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t)
      %Equal.sym(U32, U32.and(off, 3), 0, h3) :
        {O.ci_fin(n, L, O.ci_pick(_, U32.shrn(off, 2n), VC.nwu(L), F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)))
          == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, Mo)), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.acopy(VC.nwu(L), U32.shrn(off, 2n), 0, F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)),
          (F.array__thaw(U32, Mo), F.array__thaw(U32, t)),
          VB.acopy_ok(VC.nwu(L), U32.shrn(off, 2n), 0, i, 0n, dz, d, VC.ZT(dz), t, ei, {==}, hdz, hd, hs, hr, F.array__trep_perfect(U32, dz, 0), pf)) :
        {O.ci_fin(n, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, Mo)), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32>, O.mask_last(L, F.array__thaw(U32, Mo)), F.array__thaw(U32, MK(L, dz, Mo)),
          mask_okU(L, dz, Mo, hy, VB.lt32(dz, hdz),
            F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, Nat.add(VC.NW(L), 0n), VC.NW(L), F.nat__add_zero(VC.NW(L)), hr),
            VB.mone_perfect(VC.NW(L), i, 0n, dz, VC.ZT(dz), t, F.array__trep_perfect(U32, dz, 0)))) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{_, L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, Mo)), L}) : B.Buf & O.Words}
      {==}

def ci_any(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +L: U32, +dz: Nat, +k: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +h3: {U32.and(off, 3) == 0 : U32}, +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(L, 0) == z : Bool})
    -> {O.ci_fin(n, L, O.ci_go(z, U32.and(off, 3), U32.shrn(off, 2n), VC.nwu(L), F.array__thaw(U32, VC.ZT(dz)), F.array__thaw(U32, t)))
        == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}:
  ci_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hs, hr, VC.hyU(L, k, hk, hy), z, ez)

# copy_in of any byte length at a word-aligned offset: the words are copied and
# the last one keeps only its L & 3 low bytes (MK).
law copy_in_anyU:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +i: Nat
  for +L: U32
  for +dz: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  {O.copy_in(B.Buf{F.array__thaw(U32, t), n}, off, L) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
def copy_in_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, ez, h3, ei, hs, hr, hy):
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.WZ(L))), Array.new(U32, dz, 0), ez) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
  %Equal.sym(Array<U32>, Array.new(U32, dz, 0), F.array__thaw(U32, VC.ZT(dz)), F.array__new(U32, dz, 0)) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
  ci_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hs, hr, hy, U32.is_eq(L, 0), {==})

law copy_in_any:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +i: Nat
  for +L: U32
  for +dz: Nat
  for +k: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  {O.copy_in(B.Buf{F.array__thaw(U32, t), n}, off, L) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
def copy_in_any(d, t, n, off, i, L, dz, k, pf, hd, hdz, ez, h3, ei, hs, hr, hk, hy):
  copy_in_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, ez, h3, ei, hs, hr, VC.hyU(L, k, hk, hy))

# The same copy into a given zero array (a fixed-size field's Array.new at a literal depth).
law copy_into_anyU:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +i: Nat
  for +L: U32
  for +dz: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, Array.new(U32, dz, 0)) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
def copy_into_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hs, hr, hy):
  %Equal.sym(Array<U32>, Array.new(U32, dz, 0), F.array__thaw(U32, VC.ZT(dz)), F.array__new(U32, dz, 0)) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
  ci_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hs, hr, hy, U32.is_eq(L, 0), {==})

# ---- room -------------------------------------------------------------------------------------

law copy_into_any:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +i: Nat
  for +L: U32
  for +dz: Nat
  for +k: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, Array.new(U32, dz, 0)) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, MK(L, dz, VB.mone(VC.NW(L), i, 0n, dz, VC.ZT(dz), t))), L}) : B.Buf & O.Words}
def copy_into_any(d, t, n, off, i, L, dz, k, pf, hd, hdz, h3, ei, hs, hr, hk, hy):
  copy_into_anyU(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hs, hr, VC.hyU(L, k, hk, hy))

# 4 ((y >> 2)) <= y
def rng2_quad_le(+y: Nat) -> {Nat.is_le(A.quad(VD.s_rng(2n, y)), y) == True{} : Bool}:
  F.nat__le_trans(A.quad(VD.s_rng(2n, y)), Nat.double(VD.s_h2(y)), y,
    Order.double_monotone(Nat.double(VD.s_h2(VD.s_h2(y))), VD.s_h2(y), VC.h2_down(VD.s_h2(y))),
    VC.h2_down(y))

law quad_le3:
  for +x: Nat
  for +P: Nat
  for +h: {Nat.is_le(A.quad(x), 3n+A.quad(P)) == True{} : Bool}
  {Nat.is_le(x, P) == True{} : Bool}
def quad_le3(x, P, h):
  match x P:
    case 0n +P0: Order.zero_le(P0)
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: quad_le3(p, q, h)

# The words of L bytes at word a of a buffer whose 4 a + L bytes fit in 4 P bytes lie in its P words.
law nw_roomU:
  for +a: Nat
  for +L: U32
  for +P: Nat
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(A.quad(a), U32.to_nat(L)), A.quad(P)) == True{} : Bool}
  {Nat.is_le(Nat.add(VC.NW(L), a), P) == True{} : Bool}
def nw_roomU(a, L, P, hy, h):
  +m = VD.s_rng(2n, 3n+U32.to_nat(L))
  +h1 = rng2_quad_le(3n+U32.to_nat(L))
  +h2 = F.nat__le_trans(Nat.add(A.quad(m), A.quad(a)), Nat.add(3n+U32.to_nat(L), A.quad(a)), 3n+A.quad(P),
    Order.add_right(A.quad(m), 3n+U32.to_nat(L), A.quad(a), h1),
    F.logic__subst(Nat, z => {Nat.is_le(3n+z, 3n+A.quad(P)) == True{} : Bool}, Nat.add(A.quad(a), U32.to_nat(L)), Nat.add(U32.to_nat(L), A.quad(a)),
      F.nat__add_comm(A.quad(a), U32.to_nat(L)), h))
  %Equal.sym(Nat, VC.NW(L), m, VC.eNWu(L, hy)) : {Nat.is_le(Nat.add(_, a), P) == True{} : Bool}
  quad_le3(Nat.add(m, a), P, F.logic__subst(Nat, z => {Nat.is_le(z, 3n+A.quad(P)) == True{} : Bool}, Nat.add(A.quad(m), A.quad(a)), A.quad(Nat.add(m, a)), VF.quad_add(m, a), h2))

law nw_room:
  for +a: Nat
  for +L: U32
  for +P: Nat
  for +k: Nat
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(A.quad(a), U32.to_nat(L)), A.quad(P)) == True{} : Bool}
  {Nat.is_le(Nat.add(VC.NW(L), a), P) == True{} : Bool}
def nw_room(a, L, P, k, hk, hy, h):
  nw_roomU(a, L, P, VC.hyU(L, k, hk, hy), h)
