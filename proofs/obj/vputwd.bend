import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as UWD
import ./vuw_bits_generated.bend as UWB
import ./vbenc.bend as VBE
import ./vcopy.bend as VC
import ./vbrt.bend as VR
import ./vuwb.bend as VWB
import ./vbytes.bend as VY
import ./vdepth.bend as VD
import ../compact/reads.bend as RD
import ./vuw1_generated.bend as UB1
import ./vuw2_generated.bend as UB2
import ./vuw3_generated.bend as UB3
import ./vuwp1_generated.bend as UP1
import ./vuwp2_generated.bend as UP2
import ./vuwp3_generated.bend as UP3
import ./vbenc.bend as VBE2

# O.put_words written data-only (hand-written): only the n bytes it writes are zero beforehand, the
# bytes around them (in its first and last words) may already hold data. The runtime ORs its partial
# words, so the tree's bytes are the data spliced in; the models are OR chains, and their bytes follow
# from the zero tree's (vuw's lemmas) by the slotwise OR (ZOR): an OR chain on D is D OR the chain on
# zeros.

# ---- OR facts on bits and words ----
def bor_as(+a: Bool, +b: Bool, +c: Bool) -> {Bool.or(Bool.or(a, b), c) == Bool.or(a, Bool.or(b, c)) : Bool}:
  match a b c:
    case False{} False{} False{}: {==}
    case False{} False{} True{}: {==}
    case False{} True{} False{}: {==}
    case False{} True{} True{}: {==}
    case True{} False{} False{}: {==}
    case True{} False{} True{}: {==}
    case True{} True{} False{}: {==}
    case True{} True{} True{}: {==}
def band_or(+a: Bool, +b: Bool, +c: Bool) -> {Bool.and(Bool.or(a, b), c) == Bool.or(Bool.and(a, c), Bool.and(b, c)) : Bool}:
  match a b c:
    case False{} False{} False{}: {==}
    case False{} False{} True{}: {==}
    case False{} True{} False{}: {==}
    case False{} True{} True{}: {==}
    case True{} False{} False{}: {==}
    case True{} False{} True{}: {==}
    case True{} True{} False{}: {==}
    case True{} True{} True{}: {==}

law wor_as:
  for +n: Nat
  for +x: Word(n)
  for +y: Word(n)
  for +z: Word(n)
  {Word.or(n, Word.or(n, x, y), z) == Word.or(n, x, Word.or(n, y, z)) : Word(n)}
def wor_as(n, x, y, z):
  match n:
    case 0n: {==}
    case 1n+ +p:
      match x y z:
        case WCon{+a, +xt} WCon{+b, +yt} WCon{+c, +zt}:
          Equal.trans(Word(1n+p), WCon{Bool.or(Bool.or(a, b), c), Word.or(p, Word.or(p, xt, yt), zt)}, WCon{Bool.or(a, Bool.or(b, c)), Word.or(p, Word.or(p, xt, yt), zt)},
            WCon{Bool.or(a, Bool.or(b, c)), Word.or(p, xt, Word.or(p, yt, zt))},
            Equal.cong(Bool, Word(1n+p), h => WCon{h, Word.or(p, Word.or(p, xt, yt), zt)}, Bool.or(Bool.or(a, b), c), Bool.or(a, Bool.or(b, c)), bor_as(a, b, c)),
            Equal.cong(Word(p), Word(1n+p), t => WCon{Bool.or(a, Bool.or(b, c)), t}, Word.or(p, Word.or(p, xt, yt), zt), Word.or(p, xt, Word.or(p, yt, zt)), wor_as(p, xt, yt, zt)))

law wand_or:
  for +n: Nat
  for +x: Word(n)
  for +y: Word(n)
  for +z: Word(n)
  {Word.and(n, Word.or(n, x, y), z) == Word.or(n, Word.and(n, x, z), Word.and(n, y, z)) : Word(n)}
def wand_or(n, x, y, z):
  match n:
    case 0n: {==}
    case 1n+ +p:
      match x y z:
        case WCon{+a, +xt} WCon{+b, +yt} WCon{+c, +zt}:
          Equal.trans(Word(1n+p), WCon{Bool.and(Bool.or(a, b), c), Word.and(p, Word.or(p, xt, yt), zt)}, WCon{Bool.or(Bool.and(a, c), Bool.and(b, c)), Word.and(p, Word.or(p, xt, yt), zt)},
            WCon{Bool.or(Bool.and(a, c), Bool.and(b, c)), Word.or(p, Word.and(p, xt, zt), Word.and(p, yt, zt))},
            Equal.cong(Bool, Word(1n+p), h => WCon{h, Word.and(p, Word.or(p, xt, yt), zt)}, Bool.and(Bool.or(a, b), c), Bool.or(Bool.and(a, c), Bool.and(b, c)), band_or(a, b, c)),
            Equal.cong(Word(p), Word(1n+p), t => WCon{Bool.or(Bool.and(a, c), Bool.and(b, c)), t}, Word.and(p, Word.or(p, xt, yt), zt), Word.or(p, Word.and(p, xt, zt), Word.and(p, yt, zt)), wand_or(p, xt, yt, zt)))

law pad_or:
  for +p: Nat
  for +x: Word(p)
  for +y: Word(p)
  {Word.shr.pad(p, Word.or(p, x, y)) == Word.or(1n+p, Word.shr.pad(p, x), Word.shr.pad(p, y)) : Word(1n+p)}
def pad_or(p, x, y):
  match p:
    case 0n: {==}
    case 1n+ +q:
      match x y:
        case WCon{+a, +xt} WCon{+b, +yt}:
          Equal.cong(Word(1n+q), Word(2n+q), t => WCon{Bool.or(a, b), t}, Word.shr.pad(q, Word.or(q, xt, yt)), Word.or(1n+q, Word.shr.pad(q, xt), Word.shr.pad(q, yt)), pad_or(q, xt, yt))

def or_as(+a: U32, +b: U32, +c: U32) -> {U32.or(U32.or(a, b), c) == U32.or(a, U32.or(b, c)) : U32}:
  match a b c:
    case U32{+x} U32{+y} U32{+z}: Equal.cong(Word(32n), U32, w => U32{w}, Word.or(32n, Word.or(32n, x, y), z), Word.or(32n, x, Word.or(32n, y, z)), wor_as(32n, x, y, z))
def and_or(+a: U32, +b: U32, +m: U32) -> {U32.and(U32.or(a, b), m) == U32.or(U32.and(a, m), U32.and(b, m)) : U32}:
  match a b m:
    case U32{+x} U32{+y} U32{+z}: Equal.cong(Word(32n), U32, w => U32{w}, Word.and(32n, Word.or(32n, x, y), z), Word.or(32n, Word.and(32n, x, z), Word.and(32n, y, z)), wand_or(32n, x, y, z))
def shr_or(+a: U32, +b: U32) -> {U32.shr(U32.or(a, b)) == U32.or(U32.shr(a), U32.shr(b)) : U32}:
  match a b:
    case U32{WCon{+a0, +x}} U32{WCon{+b0, +y}}: Equal.cong(Word(32n), U32, w => U32{w}, Word.shr.pad(31n, Word.or(31n, x, y)), Word.or(32n, Word.shr.pad(31n, x), Word.shr.pad(31n, y)), pad_or(31n, x, y))
law shrn_or:
  for +a: U32
  for +b: U32
  for +k: Nat
  {U32.shrn(U32.or(a, b), k) == U32.or(U32.shrn(a, k), U32.shrn(b, k)) : U32}
def shrn_or(a, b, k):
  match k:
    case 0n: {==}
    case 1n+ +p:
      Equal.trans(U32, U32.shr(U32.shrn(U32.or(a, b), p)), U32.shr(U32.or(U32.shrn(a, p), U32.shrn(b, p))), U32.or(U32.shr(U32.shrn(a, p)), U32.shr(U32.shrn(b, p))),
        Equal.cong(U32, U32, z => U32.shr(z), U32.shrn(U32.or(a, b), p), U32.or(U32.shrn(a, p), U32.shrn(b, p)), shrn_or(a, b, p)),
        shr_or(U32.shrn(a, p), U32.shrn(b, p)))

# ---- the slotwise OR of two lists ----
def ZOR(xs: +List<U32>, ys: +List<U32>) -> +List<U32>:
  match xs ys:
    case Con{a, at} Con{b, bt}: Con{U32.or(a, b), ZOR(at, bt)}
    case _ _: []

# a byte of a word's OR is the OR of the bytes
def bor(+a: U32, +b: U32, +k: Nat) -> {U32.and(U32.shrn(U32.or(a, b), k), 255) == U32.or(U32.and(U32.shrn(a, k), 255), U32.and(U32.shrn(b, k), 255)) : U32}:
  Equal.trans(U32, U32.and(U32.shrn(U32.or(a, b), k), 255), U32.and(U32.or(U32.shrn(a, k), U32.shrn(b, k)), 255), U32.or(U32.and(U32.shrn(a, k), 255), U32.and(U32.shrn(b, k), 255)),
    Equal.cong(U32, U32, z => U32.and(z, 255), U32.shrn(U32.or(a, b), k), U32.or(U32.shrn(a, k), U32.shrn(b, k)), shrn_or(a, b, k)),
    and_or(U32.shrn(a, k), U32.shrn(b, k), 255))
def limb_or(+a: U32, +b: U32) -> {I.limb(U32.or(a, b)) == ZOR(I.limb(a), I.limb(b)) : +List<U32>}:
  %Equal.sym(U32, U32.and(U32.shrn(U32.or(a, b), 0n), 255), U32.or(U32.and(U32.shrn(a, 0n), 255), U32.and(U32.shrn(b, 0n), 255)), bor(a, b, 0n)) :
    {[_, U32.and(U32.shrn(U32.or(a, b), 8n), 255), U32.and(U32.shrn(U32.or(a, b), 16n), 255), U32.shrn(U32.or(a, b), 24n)] == ZOR(I.limb(a), I.limb(b)) : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(U32.or(a, b), 8n), 255), U32.or(U32.and(U32.shrn(a, 8n), 255), U32.and(U32.shrn(b, 8n), 255)), bor(a, b, 8n)) :
    {[U32.or(U32.and(a, 255), U32.and(b, 255)), _, U32.and(U32.shrn(U32.or(a, b), 16n), 255), U32.shrn(U32.or(a, b), 24n)] == ZOR(I.limb(a), I.limb(b)) : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(U32.or(a, b), 16n), 255), U32.or(U32.and(U32.shrn(a, 16n), 255), U32.and(U32.shrn(b, 16n), 255)), bor(a, b, 16n)) :
    {[U32.or(U32.and(a, 255), U32.and(b, 255)), U32.or(U32.and(U32.shrn(a, 8n), 255), U32.and(U32.shrn(b, 8n), 255)), _, U32.shrn(U32.or(a, b), 24n)] == ZOR(I.limb(a), I.limb(b)) : +List<U32>}
  %Equal.sym(U32, U32.shrn(U32.or(a, b), 24n), U32.or(U32.shrn(a, 24n), U32.shrn(b, 24n)), shrn_or(a, b, 24n)) :
    {[U32.or(U32.and(a, 255), U32.and(b, 255)), U32.or(U32.and(U32.shrn(a, 8n), 255), U32.and(U32.shrn(b, 8n), 255)), U32.or(U32.and(U32.shrn(a, 16n), 255), U32.and(U32.shrn(b, 16n), 255)), _] == ZOR(I.limb(a), I.limb(b)) : +List<U32>}
  {==}

law limbs_zor:
  for +A: +List<U32>
  for +B: +List<U32>
  {FX.limbs(ZOR(A, B)) == ZOR(FX.limbs(A), FX.limbs(B)) : +List<U32>}
def limbs_zor(A, B):
  match A B:
    case Nil{} _: {==}
    case Con{+a, +at} Nil{}: {==}
    case Con{+a, +at} Con{+b, +bt}:
      Equal.trans(+List<U32>, List.append(&2, U32, I.limb(U32.or(a, b)), FX.limbs(ZOR(at, bt))), List.append(&2, U32, ZOR(I.limb(a), I.limb(b)), FX.limbs(ZOR(at, bt))),
        List.append(&2, U32, ZOR(I.limb(a), I.limb(b)), ZOR(FX.limbs(at), FX.limbs(bt))),
        Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, z, FX.limbs(ZOR(at, bt))), I.limb(U32.or(a, b)), ZOR(I.limb(a), I.limb(b)), limb_or(a, b)),
        Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, ZOR(I.limb(a), I.limb(b)), z), FX.limbs(ZOR(at, bt)), ZOR(FX.limbs(at), FX.limbs(bt)), limbs_zor(at, bt)))

# ---- an OR into slot j, and the OR chains of vuw (SWc) on lists ----
def ORL(+xs: +List<U32>, +j: Nat, +v: U32) -> +List<U32>: FD.spec_common__update(U32, xs, j, U32.or(FD.flat__nthc(xs, j), v))
def ORSLb(b: Bool, +xs: +List<U32>, +j: Nat, +c: U32) -> +List<U32>:
  match b:
    case True{}: xs
    case False{}: ORL(xs, j, c)

law zor_orl:
  for +A: +List<U32>
  for +B: +List<U32>
  for +j: Nat
  for +v: U32
  {ORL(ZOR(A, B), j, v) == ZOR(A, ORL(B, j, v)) : +List<U32>}
def zor_orl(A, B, j, v):
  match A B j:
    case Nil{} _ _: {==}
    case Con{+a, +at} Nil{} _: {==}
    case Con{+a, +at} Con{+b, +bt} 0n:
      Equal.cong(U32, +List<U32>, z => Con{z, ZOR(at, bt)}, U32.or(U32.or(a, b), v), U32.or(a, U32.or(b, v)), or_as(a, b, v))
    case Con{+a, +at} Con{+b, +bt} 1n+ +p:
      Equal.cong(+List<U32>, +List<U32>, z => Con{U32.or(a, b), z}, ORL(ZOR(at, bt), p, v), ZOR(at, ORL(bt, p, v)), zor_orl(at, bt, p, v))

def zor_orslb(+b: Bool, +A: +List<U32>, +B: +List<U32>, +j: Nat, +c: U32) -> {ORSLb(b, ZOR(A, B), j, c) == ZOR(A, ORSLb(b, B, j, c)) : +List<U32>}:
  match b:
    case True{}: {==}
    case False{}: zor_orl(A, B, j, c)

def SWCL(+S: U32, ws: +List<U32>, +L: +List<U32>, +i: Nat, +c: U32) -> +List<U32>:
  match ws:
    case Nil{}: ORSLb(U32.is_eq(c, 0), L, i, c)
    case Con{+w, t}: SWCL(S, t, ORL(L, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S))

law swcl_zor:
  for +S: U32
  for +ws: +List<U32>
  for +A: +List<U32>
  for +B: +List<U32>
  for +i: Nat
  for +c: U32
  {SWCL(S, ws, ZOR(A, B), i, c) == ZOR(A, SWCL(S, ws, B, i, c)) : +List<U32>}
def swcl_zor(S, ws, A, B, i, c):
  match ws:
    case Nil{}: zor_orslb(U32.is_eq(c, 0), A, B, i, c)
    case Con{+w, +t}:
      +v = U32.or(O.shl_bytes(w, S), c)
      Equal.trans(+List<U32>, SWCL(S, t, ORL(ZOR(A, B), i, v), 1n+i, O.shr_over(w, S)), SWCL(S, t, ZOR(A, ORL(B, i, v)), 1n+i, O.shr_over(w, S)),
        ZOR(A, SWCL(S, t, ORL(B, i, v), 1n+i, O.shr_over(w, S))),
        Equal.cong(+List<U32>, +List<U32>, z => SWCL(S, t, z, 1n+i, O.shr_over(w, S)), ORL(ZOR(A, B), i, v), ZOR(A, ORL(B, i, v)), zor_orl(A, B, i, v)),
        swcl_zor(S, t, A, ORL(B, i, v), 1n+i, O.shr_over(w, S)))

# the trees' slots: an ORW is the list OR, the SWc chain the list chain
def slw_orw(+dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +v: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool})
    -> {UW.SLW(UW.ORW(dd, D, i, v)) == ORL(UW.SLW(D), i, v) : +List<U32>}:
  FD.array__upd_slots(U32, dd, D, i, U32.or(VB.slot(D, i), v), hi, pf)
def slw_orsb(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +c: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool})
    -> {UW.SLW(UW.ORSb(b, dd, D, i, c)) == ORSLb(b, UW.SLW(D), i, c) : +List<U32>}:
  match b:
    case True{}: {==}
    case False{}: slw_orw(dd, D, i, c, pf, hi)

law slw_swc:
  for +S: U32
  for +ws: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_lt(Nat.add(i, List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool}
  {UW.SLW(UW.SWc(S, ws, dd, D, i, c)) == SWCL(S, ws, UW.SLW(D), i, c) : +List<U32>}
def slw_swc(S, ws, dd, D, i, c, pf, hl):
  match ws:
    case Nil{}:
      slw_orsb(U32.is_eq(c, 0), dd, D, i, c, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(i, 0n), i, FD.nat__add_zero(i), hl))
    case Con{+w, +t}:
      +v = U32.or(O.shl_bytes(w, S), c)
      +hi = FD.nat__le_lt_trans(i, Nat.add(i, 1n+List.length(&2, U32, t)), VB.pw(dd), FD.nat__le_add_right(i, 1n+List.length(&2, U32, t)), hl)
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(i, 1n+List.length(&2, U32, t)), 1n+Nat.add(i, List.length(&2, U32, t)),
        FD.nat__add_succ(i, List.length(&2, U32, t)), hl)
      Equal.trans(+List<U32>, UW.SLW(UW.SWc(S, t, dd, UW.ORW(dd, D, i, v), 1n+i, O.shr_over(w, S))), SWCL(S, t, UW.SLW(UW.ORW(dd, D, i, v)), 1n+i, O.shr_over(w, S)),
        SWCL(S, t, ORL(UW.SLW(D), i, v), 1n+i, O.shr_over(w, S)),
        slw_swc(S, t, dd, UW.ORW(dd, D, i, v), 1n+i, O.shr_over(w, S), UW.orw_perfect(dd, D, i, v, pf), hl1),
        Equal.cong(+List<U32>, +List<U32>, z => SWCL(S, t, z, 1n+i, O.shr_over(w, S)), UW.SLW(UW.ORW(dd, D, i, v)), ORL(UW.SLW(D), i, v), slw_orw(dd, D, i, v, pf, hi)))

# ---- an OR with zeros ----
law zor_rep:
  for +A: +List<U32>
  for +n: Nat
  for +h: {FD.spec_common__length(U32, A) == n : Nat}
  {ZOR(A, FD.spec_common__replicate(U32, n, 0)) == A : +List<U32>}
def zor_rep(A, n, h):
  match A n:
    case Nil{} _: {==}
    case Con{+a, +t} 0n: Empty.absurd({ZOR(Con{a, t}, []) == Con{a, t} : +List<U32>}, FD.logic__false_true(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 1n+FD.spec_common__length(U32, t), 0n, h)))
    case Con{+a, +t} 1n+ +p:
      Equal.trans(+List<U32>, Con{U32.or(a, 0), ZOR(t, FD.spec_common__replicate(U32, p, 0))}, Con{a, ZOR(t, FD.spec_common__replicate(U32, p, 0))}, Con{a, t},
        Equal.cong(U32, +List<U32>, z => Con{z, ZOR(t, FD.spec_common__replicate(U32, p, 0))}, U32.or(a, 0), a, UWB.or0r(a)),
        Equal.cong(+List<U32>, +List<U32>, z => Con{a, z}, ZOR(t, FD.spec_common__replicate(U32, p, 0)), t, zor_rep(t, p, FD.nat__succ_inj(FD.spec_common__length(U32, t), p, h))))

# A tree's slots OR the zero tree's are its slots.
def zor_zt(+dd: Nat, +D: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}) -> {ZOR(UW.SLW(D), UW.SLW(VC.ZT(dd))) == UW.SLW(D) : +List<U32>}:
  Equal.trans(+List<U32>, ZOR(UW.SLW(D), UW.SLW(VC.ZT(dd))), ZOR(UW.SLW(D), FD.spec_common__replicate(U32, FD.spec_common__pow2(dd), 0)), UW.SLW(D),
    Equal.cong(+List<U32>, +List<U32>, z => ZOR(UW.SLW(D), z), UW.SLW(VC.ZT(dd)), FD.spec_common__replicate(U32, FD.spec_common__pow2(dd), 0), FD.array__trep_slots(U32, dd, 0)),
    zor_rep(UW.SLW(D), FD.spec_common__pow2(dd), FD.array__slots_length(U32, dd, D, pf)))

def ISN(xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, t}: False{}
def HDL(xs: +List<U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: h
def TLL(xs: +List<U32>) -> +List<U32>:
  match xs:
    case Nil{}: []
    case Con{h, t}: t

# OR onto a list whose first |S1| items are zero: S1, then the OR of the rest.
law zor_pre:
  for +Bl: +List<U32>
  for +S1: +List<U32>
  for +R: +List<U32>
  for +hz: {VS.bt(List.length(&2, U32, S1), Bl) == UW.ZB(List.length(&2, U32, S1)) : +List<U32>}
  {ZOR(Bl, List.append(&2, U32, S1, R)) == List.append(&2, U32, S1, ZOR(VS.bdr(List.length(&2, U32, S1), Bl), R)) : +List<U32>}
def zor_pre(Bl, S1, R, hz):
  match Bl S1:
    case _ Nil{}: {==}
    case Nil{} Con{+s, +st}:
      Empty.absurd({ZOR([], List.append(&2, U32, Con{s, st}, R)) == List.append(&2, U32, Con{s, st}, ZOR(VS.bdr(1n+List.length(&2, U32, st), []), R)) : +List<U32>},
        FD.logic__true_false(Equal.cong(+List<U32>, Bool, z => ISN(z), [], UW.ZB(1n+List.length(&2, U32, st)), hz)))
    case Con{+b, +bt} Con{+s, +st}:
      +eb = Equal.cong(+List<U32>, U32, z => HDL(z), Con{b, VS.bt(List.length(&2, U32, st), bt)}, UW.ZB(1n+List.length(&2, U32, st)), hz)
      +et = Equal.cong(+List<U32>, +List<U32>, z => TLL(z), Con{b, VS.bt(List.length(&2, U32, st), bt)}, UW.ZB(1n+List.length(&2, U32, st)), hz)
      +es = Equal.trans(U32, U32.or(b, s), U32.or(0, s), s, Equal.cong(U32, U32, z => U32.or(z, s), b, 0, eb), VBE.zero_or(s))
      Equal.trans(+List<U32>, Con{U32.or(b, s), ZOR(bt, List.append(&2, U32, st, R))}, Con{s, ZOR(bt, List.append(&2, U32, st, R))},
        Con{s, List.append(&2, U32, st, ZOR(VS.bdr(List.length(&2, U32, st), bt), R))},
        Equal.cong(U32, +List<U32>, z => Con{z, ZOR(bt, List.append(&2, U32, st, R))}, U32.or(b, s), s, es),
        Equal.cong(+List<U32>, +List<U32>, z => Con{s, z}, ZOR(bt, List.append(&2, U32, st, R)), List.append(&2, U32, st, ZOR(VS.bdr(List.length(&2, U32, st), bt), R)), zor_pre(bt, st, R, et)))

law zor_zb:
  for +C: +List<U32>
  for +K: Nat
  for +h: {List.length(&2, U32, C) == K : Nat}
  {ZOR(C, UW.ZB(K)) == C : +List<U32>}
def zor_zb(C, K, h):
  match C K:
    case Nil{} _: {==}
    case Con{+a, +t} 0n: Empty.absurd({ZOR(Con{a, t}, []) == Con{a, t} : +List<U32>}, FD.logic__false_true(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 1n+List.length(&2, U32, t), 0n, h)))
    case Con{+a, +t} 1n+ +p:
      Equal.trans(+List<U32>, Con{U32.or(a, 0), ZOR(t, UW.ZB(p))}, Con{a, ZOR(t, UW.ZB(p))}, Con{a, t},
        Equal.cong(U32, +List<U32>, z => Con{z, ZOR(t, UW.ZB(p))}, U32.or(a, 0), a, UWB.or0r(a)),
        Equal.cong(+List<U32>, +List<U32>, z => Con{a, z}, ZOR(t, UW.ZB(p)), t, zor_zb(t, p, FD.nat__succ_inj(List.length(&2, U32, t), p, h))))

law bdr_zb:
  for +a: Nat
  for +n: Nat
  {VS.bdr(a, UW.ZB(n)) == UW.ZB(Nat.sub(n, a)) : +List<U32>}
def bdr_zb(a, n):
  match a n:
    case 0n 0n: {==}
    case 0n 1n+ +q: {==}
    case 1n+ +p 0n: {==}
    case 1n+ +p 1n+ +q: bdr_zb(p, q)

law len_bdr:
  for +m: Nat
  for +xs: +List<U32>
  {List.length(&2, U32, VS.bdr(m, xs)) == Nat.sub(List.length(&2, U32, xs), m) : Nat}
def len_bdr(m, xs):
  match m xs:
    case 0n Nil{}: {==}
    case 0n Con{+h, +t}: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: len_bdr(p, t)

# N - m == k + (N - (m + k)) when m + k <= N
law ar1:
  for +N: Nat
  for +m: Nat
  for +k: Nat
  for +h: {Nat.is_le(Nat.add(m, k), N) == True{} : Bool}
  {Nat.sub(N, m) == Nat.add(k, Nat.sub(N, Nat.add(m, k))) : Nat}
def ar1(N, m, k, h):
  match N m:
    case 0n 0n: Equal.sym(Nat, Nat.add(k, Nat.sub(0n, k)), 0n, FD.nat__sub_add(0n, k, h))
    case 1n+ +q 0n: Equal.sym(Nat, Nat.add(k, Nat.sub(1n+q, k)), 1n+q, FD.nat__sub_add(1n+q, k, h))
    case 0n 1n+ +p: Empty.absurd({Nat.sub(0n, 1n+p) == Nat.add(k, Nat.sub(0n, Nat.add(1n+p, k))) : Nat}, FD.logic__false_true(h))
    case 1n+ +q 1n+ +p: ar1(q, p, k, h)

# OR-ing the zero list with data S1 (then zeros) at X onto B, whose |S1| bytes at X are zero, splices S1 in.
law spl_zor:
  for +Bl: +List<U32>
  for +X: Nat
  for +S1: +List<U32>
  for +k: Nat
  for +hX: {Nat.is_le(Nat.add(Nat.add(X, List.length(&2, U32, S1)), k), List.length(&2, U32, Bl)) == True{} : Bool}
  for +hz: {VS.bt(List.length(&2, U32, S1), VS.bdr(X, Bl)) == UW.ZB(List.length(&2, U32, S1)) : +List<U32>}
  {ZOR(Bl, UW.SPL(UW.ZB(List.length(&2, U32, Bl)), X, List.append(&2, U32, S1, UW.ZB(k)))) == UW.SPL(Bl, X, S1) : +List<U32>}
def spl_zor(Bl, X, S1, k, hX, hz):
  match Bl X:
    case _ 0n:
      +m = List.length(&2, U32, S1)
      +N = List.length(&2, U32, Bl)
      +Y = List.append(&2, U32, S1, UW.ZB(k))
      +eY = Equal.trans(Nat, List.length(&2, U32, Y), Nat.add(m, List.length(&2, U32, UW.ZB(k))), Nat.add(m, k), VS.len_app(S1, UW.ZB(k)),
        Equal.cong(Nat, Nat, z => Nat.add(m, z), List.length(&2, U32, UW.ZB(k)), k, UW.len_zb(k)))
      +Rz = VS.bdr(List.length(&2, U32, Y), UW.ZB(N))
      +eR = Equal.trans(+List<U32>, Rz, UW.ZB(Nat.sub(N, List.length(&2, U32, Y))), UW.ZB(Nat.sub(N, Nat.add(m, k))), bdr_zb(List.length(&2, U32, Y), N),
        Equal.cong(Nat, +List<U32>, z => UW.ZB(Nat.sub(N, z)), List.length(&2, U32, Y), Nat.add(m, k), eY))
      +e1 = VS.app_assoc(S1, UW.ZB(k), Rz)
      +e2 = zor_pre(Bl, S1, List.append(&2, U32, UW.ZB(k), Rz), hz)
      +e3 = Equal.trans(+List<U32>, List.append(&2, U32, UW.ZB(k), Rz), List.append(&2, U32, UW.ZB(k), UW.ZB(Nat.sub(N, Nat.add(m, k)))), UW.ZB(Nat.add(k, Nat.sub(N, Nat.add(m, k)))),
        Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, UW.ZB(k), z), Rz, UW.ZB(Nat.sub(N, Nat.add(m, k))), eR), UWD.zb_app(k, Nat.sub(N, Nat.add(m, k))))
      +hl = Equal.trans(Nat, List.length(&2, U32, VS.bdr(m, Bl)), Nat.sub(N, m), Nat.add(k, Nat.sub(N, Nat.add(m, k))), len_bdr(m, Bl), ar1(N, m, k, hX))
      +e4 = Equal.trans(+List<U32>, ZOR(VS.bdr(m, Bl), List.append(&2, U32, UW.ZB(k), Rz)), ZOR(VS.bdr(m, Bl), UW.ZB(Nat.add(k, Nat.sub(N, Nat.add(m, k))))), VS.bdr(m, Bl),
        Equal.cong(+List<U32>, +List<U32>, z => ZOR(VS.bdr(m, Bl), z), List.append(&2, U32, UW.ZB(k), Rz), UW.ZB(Nat.add(k, Nat.sub(N, Nat.add(m, k)))), e3),
        zor_zb(VS.bdr(m, Bl), Nat.add(k, Nat.sub(N, Nat.add(m, k))), hl))
      Equal.trans(+List<U32>, ZOR(Bl, List.append(&2, U32, Y, Rz)), ZOR(Bl, List.append(&2, U32, S1, List.append(&2, U32, UW.ZB(k), Rz))), List.append(&2, U32, S1, VS.bdr(m, Bl)),
        Equal.cong(+List<U32>, +List<U32>, z => ZOR(Bl, z), List.append(&2, U32, Y, Rz), List.append(&2, U32, S1, List.append(&2, U32, UW.ZB(k), Rz)), e1),
        Equal.trans(+List<U32>, ZOR(Bl, List.append(&2, U32, S1, List.append(&2, U32, UW.ZB(k), Rz))), List.append(&2, U32, S1, ZOR(VS.bdr(m, Bl), List.append(&2, U32, UW.ZB(k), Rz))), List.append(&2, U32, S1, VS.bdr(m, Bl)),
          e2, Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, S1, z), ZOR(VS.bdr(m, Bl), List.append(&2, U32, UW.ZB(k), Rz)), VS.bdr(m, Bl), e4)))
    case Nil{} 1n+ +p:
      Empty.absurd({ZOR([], UW.SPL(UW.ZB(0n), 1n+p, List.append(&2, U32, S1, UW.ZB(k)))) == UW.SPL([], 1n+p, S1) : +List<U32>}, FD.logic__false_true(hX))
    case Con{+b, +bt} 1n+ +p:
      Equal.trans(+List<U32>, Con{U32.or(b, 0), ZOR(bt, UW.SPL(UW.ZB(List.length(&2, U32, bt)), p, List.append(&2, U32, S1, UW.ZB(k))))},
        Con{b, ZOR(bt, UW.SPL(UW.ZB(List.length(&2, U32, bt)), p, List.append(&2, U32, S1, UW.ZB(k))))}, Con{b, UW.SPL(bt, p, S1)},
        Equal.cong(U32, +List<U32>, z => Con{z, ZOR(bt, UW.SPL(UW.ZB(List.length(&2, U32, bt)), p, List.append(&2, U32, S1, UW.ZB(k))))}, U32.or(b, 0), b, UWB.or0r(b)),
        Equal.cong(+List<U32>, +List<U32>, z => Con{b, z}, ZOR(bt, UW.SPL(UW.ZB(List.length(&2, U32, bt)), p, List.append(&2, U32, S1, UW.ZB(k)))), UW.SPL(bt, p, S1), spl_zor(bt, p, S1, k, hX, hz)))

# ---- windows of zeros ----
# m zero bytes at off inside a window of n zero bytes (off may pass n when m is 0)
law zwin:
  for +off: Nat
  for +m: Nat
  for +n: Nat
  for +xs: +List<U32>
  for +hz: {VS.bt(n, xs) == UW.ZB(n) : +List<U32>}
  for +h: {Nat.is_le(m, Nat.sub(n, off)) == True{} : Bool}
  {VS.bt(m, VS.bdr(off, xs)) == UW.ZB(m) : +List<U32>}
def zwin(off, m, n, xs, hz, h):
  match off m n xs:
    case 0n 0n _ _: {==}
    case 0n 1n+ +p 0n _: Empty.absurd({VS.bt(1n+p, VS.bdr(0n, xs)) == UW.ZB(1n+p) : +List<U32>}, FD.logic__false_true(h))
    case 0n 1n+ +p 1n+ +q _:
      Equal.trans(+List<U32>, VS.bt(1n+p, xs), VS.bt(1n+p, VS.bt(1n+q, xs)), UW.ZB(1n+p), Equal.sym(+List<U32>, VS.bt(1n+p, VS.bt(1n+q, xs)), VS.bt(1n+p, xs), UW.bt_le_m(1n+p, 1n+q, xs, h)),
        Equal.trans(+List<U32>, VS.bt(1n+p, VS.bt(1n+q, xs)), VS.bt(1n+p, UW.ZB(1n+q)), UW.ZB(1n+p),
          Equal.cong(+List<U32>, +List<U32>, z => VS.bt(1n+p, z), VS.bt(1n+q, xs), UW.ZB(1n+q), hz), UW.zb_win(0n, 1n+p, 1n+q, h)))
    case 1n+ +o 0n _ _: {==}
    case 1n+ +o 1n+ +p 0n _: Empty.absurd({VS.bt(1n+p, VS.bdr(1n+o, xs)) == UW.ZB(1n+p) : +List<U32>}, FD.logic__false_true(h))
    case 1n+ +o 1n+ +p 1n+ +q Nil{}: Empty.absurd({VS.bt(1n+p, VS.bdr(1n+o, [])) == UW.ZB(1n+p) : +List<U32>}, FD.logic__true_false(Equal.cong(+List<U32>, Bool, z => ISN(z), [], UW.ZB(1n+q), hz)))
    case 1n+ +o 1n+ +p 1n+ +q Con{+x, +t}:
      zwin(o, 1n+p, q, t, Equal.cong(+List<U32>, +List<U32>, z => TLL(z), Con{x, VS.bt(q, t)}, UW.ZB(1n+q), hz), h)

# m zero bytes at X of the zero tree
def zt_win(+dd: Nat, +X: Nat, +m: Nat, +h: {Nat.is_le(Nat.add(X, m), A.quad(VB.pw(dd))) == True{} : Bool}) -> {VS.bt(m, VS.bdr(X, UA.BYT(VC.ZT(dd)))) == UW.ZB(m) : +List<U32>}:
  %Equal.sym(+List<U32>, UA.BYT(VC.ZT(dd)), UW.ZB(A.quad(VB.pw(dd))), VWB.zt_bytes(dd)) : {VS.bt(m, VS.bdr(X, _)) == UW.ZB(m) : +List<U32>}
  UW.zb_win(X, m, A.quad(VB.pw(dd)), h)

# ---- the OR models' bytes: the tree's OR the zero tree's ----
def bytes_swc(+S: U32, +ws: +List<U32>, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(i, List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool})
    -> {UA.BYT(UW.SWc(S, ws, dd, D, i, 0)) == ZOR(UA.BYT(D), UA.BYT(UW.SWc(S, ws, dd, VC.ZT(dd), i, 0))) : +List<U32>}:
  +Z = VC.ZT(dd)
  +pfZ = FD.array__trep_perfect(U32, dd, 0)
  +e1 = slw_swc(S, ws, dd, D, i, 0, pf, hl)
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => SWCL(S, ws, z, i, 0), UW.SLW(D), ZOR(UW.SLW(D), UW.SLW(Z)), Equal.sym(+List<U32>, ZOR(UW.SLW(D), UW.SLW(Z)), UW.SLW(D), zor_zt(dd, D, pf)))
  +e3 = swcl_zor(S, ws, UW.SLW(D), UW.SLW(Z), i, 0)
  +e4 = Equal.cong(+List<U32>, +List<U32>, z => ZOR(UW.SLW(D), z), SWCL(S, ws, UW.SLW(Z), i, 0), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0)),
    Equal.sym(+List<U32>, UW.SLW(UW.SWc(S, ws, dd, Z, i, 0)), SWCL(S, ws, UW.SLW(Z), i, 0), slw_swc(S, ws, dd, Z, i, 0, pfZ, hl)))
  +es = Equal.trans(+List<U32>, UW.SLW(UW.SWc(S, ws, dd, D, i, 0)), SWCL(S, ws, UW.SLW(D), i, 0), ZOR(UW.SLW(D), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0))), e1,
    Equal.trans(+List<U32>, SWCL(S, ws, UW.SLW(D), i, 0), SWCL(S, ws, ZOR(UW.SLW(D), UW.SLW(Z)), i, 0), ZOR(UW.SLW(D), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0))), e2,
      Equal.trans(+List<U32>, SWCL(S, ws, ZOR(UW.SLW(D), UW.SLW(Z)), i, 0), ZOR(UW.SLW(D), SWCL(S, ws, UW.SLW(Z), i, 0)), ZOR(UW.SLW(D), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0))), e3, e4)))
  Equal.trans(+List<U32>, FX.limbs(UW.SLW(UW.SWc(S, ws, dd, D, i, 0))), FX.limbs(ZOR(UW.SLW(D), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0)))), ZOR(UA.BYT(D), UA.BYT(UW.SWc(S, ws, dd, Z, i, 0))),
    Equal.cong(+List<U32>, +List<U32>, z => FX.limbs(z), UW.SLW(UW.SWc(S, ws, dd, D, i, 0)), ZOR(UW.SLW(D), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0))), es),
    limbs_zor(UW.SLW(D), UW.SLW(UW.SWc(S, ws, dd, Z, i, 0))))

def bytes_orw(+dd: Nat, +D: FD.array__Tree<U32>, +j: Nat, +v: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {UA.BYT(UW.ORW(dd, D, j, v)) == ZOR(UA.BYT(D), UA.BYT(UW.ORW(dd, VC.ZT(dd), j, v))) : +List<U32>}:
  +Z = VC.ZT(dd)
  +pfZ = FD.array__trep_perfect(U32, dd, 0)
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => ORL(z, j, v), UW.SLW(D), ZOR(UW.SLW(D), UW.SLW(Z)), Equal.sym(+List<U32>, ZOR(UW.SLW(D), UW.SLW(Z)), UW.SLW(D), zor_zt(dd, D, pf)))
  +e4 = Equal.cong(+List<U32>, +List<U32>, z => ZOR(UW.SLW(D), z), ORL(UW.SLW(Z), j, v), UW.SLW(UW.ORW(dd, Z, j, v)), Equal.sym(+List<U32>, UW.SLW(UW.ORW(dd, Z, j, v)), ORL(UW.SLW(Z), j, v), slw_orw(dd, Z, j, v, pfZ, hj)))
  +es = Equal.trans(+List<U32>, UW.SLW(UW.ORW(dd, D, j, v)), ORL(UW.SLW(D), j, v), ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, Z, j, v))), slw_orw(dd, D, j, v, pf, hj),
    Equal.trans(+List<U32>, ORL(UW.SLW(D), j, v), ORL(ZOR(UW.SLW(D), UW.SLW(Z)), j, v), ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, Z, j, v))), e2,
      Equal.trans(+List<U32>, ORL(ZOR(UW.SLW(D), UW.SLW(Z)), j, v), ZOR(UW.SLW(D), ORL(UW.SLW(Z), j, v)), ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, Z, j, v))), zor_orl(UW.SLW(D), UW.SLW(Z), j, v), e4)))
  Equal.trans(+List<U32>, FX.limbs(UW.SLW(UW.ORW(dd, D, j, v))), FX.limbs(ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, Z, j, v)))), ZOR(UA.BYT(D), UA.BYT(UW.ORW(dd, Z, j, v))),
    Equal.cong(+List<U32>, +List<U32>, z => FX.limbs(z), UW.SLW(UW.ORW(dd, D, j, v)), ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, Z, j, v))), es),
    limbs_zor(UW.SLW(D), UW.SLW(UW.ORW(dd, Z, j, v))))

# OR onto the tree's bytes the zero tree's bytes with S1 then k zeros at X: S1 spliced in, when the |S1| bytes were zero.
def spl_or(+dd: Nat, +D: FD.array__Tree<U32>, +X: Nat, +S1: +List<U32>, +k: Nat, +Y: +List<U32>, +eY: {Y == List.append(&2, U32, S1, UW.ZB(k)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hX: {Nat.is_le(Nat.add(Nat.add(X, List.length(&2, U32, S1)), k), A.quad(VB.pw(dd))) == True{} : Bool},
    +hz: {VS.bt(List.length(&2, U32, S1), VS.bdr(X, UA.BYT(D))) == UW.ZB(List.length(&2, U32, S1)) : +List<U32>})
    -> {ZOR(UA.BYT(D), UW.SPL(UA.BYT(VC.ZT(dd)), X, Y)) == UW.SPL(UA.BYT(D), X, S1) : +List<U32>}:
  +eL = VR.lenS(dd, D, pf)
  +eZ = Equal.trans(+List<U32>, UA.BYT(VC.ZT(dd)), UW.ZB(A.quad(VB.pw(dd))), UW.ZB(List.length(&2, U32, UA.BYT(D))), VWB.zt_bytes(dd),
    Equal.cong(Nat, +List<U32>, z => UW.ZB(z), A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), eL)))
  %Equal.sym(+List<U32>, UA.BYT(VC.ZT(dd)), UW.ZB(List.length(&2, U32, UA.BYT(D))), eZ) : {ZOR(UA.BYT(D), UW.SPL(_, X, Y)) == UW.SPL(UA.BYT(D), X, S1) : +List<U32>}
  %Equal.sym(+List<U32>, Y, List.append(&2, U32, S1, UW.ZB(k)), eY) : {ZOR(UA.BYT(D), UW.SPL(UW.ZB(List.length(&2, U32, UA.BYT(D))), X, _)) == UW.SPL(UA.BYT(D), X, S1) : +List<U32>}
  spl_zor(UA.BYT(D), X, S1, k, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(X, List.length(&2, U32, S1)), k), z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), eL), hX), hz)

# ---- sizes ----
law quad_add:
  for +a: Nat
  for +b: Nat
  {A.quad(Nat.add(a, b)) == Nat.add(A.quad(a), A.quad(b)) : Nat}
def quad_add(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 4n+z, A.quad(Nat.add(p, b)), Nat.add(A.quad(p), A.quad(b)), quad_add(p, b))

# X0 = 4 q + s, s < 4, and L words after q ending before P: X0 + 4 L <= 4 P
def win_end(+q: Nat, +s: Nat, +L: Nat, +P: Nat, +hs: {Nat.is_lt(s, 4n) == True{} : Bool}, +h: {Nat.is_lt(Nat.add(q, L), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(A.quad(q), s), A.quad(L)), A.quad(P)) == True{} : Bool}:
  +x = A.quad(Nat.add(q, L))
  +e1 = Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), s), A.quad(L)), Nat.add(A.quad(q), Nat.add(s, A.quad(L))), Nat.add(s, x),
    FD.nat__add_assoc(A.quad(q), s, A.quad(L)),
    Equal.trans(Nat, Nat.add(A.quad(q), Nat.add(s, A.quad(L))), Nat.add(s, Nat.add(A.quad(q), A.quad(L))), Nat.add(s, x),
      FD.lru_nat_algebra__add_swap(A.quad(q), s, A.quad(L)),
      Equal.cong(Nat, Nat, z => Nat.add(s, z), Nat.add(A.quad(q), A.quad(L)), x, Equal.sym(Nat, x, Nat.add(A.quad(q), A.quad(L)), quad_add(q, L)))))
  +h1 = FD.nat__le_trans(Nat.add(s, x), Nat.add(4n, x), A.quad(P), Order.add_right(s, 4n, x, FD.nat__lt_le(s, 4n, hs)), UW.quad_le(1n+Nat.add(q, L), P, FD.nat__lt_succ_le_succ(Nat.add(q, L), P, h)))
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(P)) == True{} : Bool}, Nat.add(s, x), Nat.add(Nat.add(A.quad(q), s), A.quad(L)), Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), s), A.quad(L)), Nat.add(s, x), e1), h1)

def rr_le(+R: Nat, +h: {Nat.is_le(R, 3n) == True{} : Bool}) -> {Nat.is_le(R, A.quad(VD.s_rng(2n, 3n+R))) == True{} : Bool}:
  match R:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +t: Empty.absurd({Nat.is_le(4n+t, A.quad(VD.s_rng(2n, 7n+t))) == True{} : Bool}, FD.logic__false_true(h))

# n <= 4 NW(n)
def n_le_qnwU(+n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool}:
  +Q = VY.QL(n)
  +S2 = VD.s_rng(2n, 3n+UWD.RR(n))
  +e1 = UWD.n_qr(n, UWD.RR(n), {==})
  +e2 = Equal.trans(Nat, A.quad(VC.NW(n)), A.quad(Nat.add(Q, S2)), Nat.add(A.quad(Q), A.quad(S2)), Equal.cong(Nat, Nat, z => A.quad(z), VC.NW(n), Nat.add(Q, S2), UWD.nw_qrU(n, hy)), quad_add(Q, S2))
  +h1 = Order.add_left(A.quad(Q), UWD.RR(n), A.quad(S2), rr_le(UWD.RR(n), RD.and_le(n, 3)))
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VC.NW(n))) == True{} : Bool}, Nat.add(A.quad(Q), UWD.RR(n)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(A.quad(Q), UWD.RR(n)), e1),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(Q), UWD.RR(n)), z) == True{} : Bool}, Nat.add(A.quad(Q), A.quad(S2)), A.quad(VC.NW(n)), Equal.sym(Nat, A.quad(VC.NW(n)), Nat.add(A.quad(Q), A.quad(S2)), e2), h1))

def n_le_qnw(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool}:
  n_le_qnwU(n, VC.hyU(n, k, hk, hy))

# the data bytes: n of them
def len_dU(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool})
    -> {List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) == U32.to_nat(n) : Nat}:
  VS.bt_len(U32.to_nat(n), FX.limbs(UW.SLW(T)), FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(n), z) == True{} : Bool}, A.quad(VB.pw(dw)), List.length(&2, U32, FX.limbs(UW.SLW(T))),
    Equal.sym(Nat, List.length(&2, U32, FX.limbs(UW.SLW(T))), A.quad(VB.pw(dw)), VR.lenS(dw, T, pfT)),
    FD.nat__le_trans(U32.to_nat(n), A.quad(VC.NW(n)), A.quad(VB.pw(dw)), n_le_qnwU(n, hy), UW.quad_le(VC.NW(n), VB.pw(dw), hsrc))))

def len_d(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hk: {Nat.is_lt(k, 31n) == True{} : Bool},
    +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool})
    -> {List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) == U32.to_nat(n) : Nat}:
  len_dU(n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc)

def len_w(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool})
    -> {List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))) == VC.NW(n) : Nat}:
  UW.len_take(VC.NW(n), UW.SLW(T), FD.logic__subst(Nat, z => {Nat.is_le(VC.NW(n), z) == True{} : Bool}, VB.pw(dw), VB.len(UW.SLW(T)), Equal.sym(Nat, VB.len(UW.SLW(T)), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc))

# the data then the zeros to the last word's end: the n bytes and 4 NW - n
def hxdU(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +X: Nat, +N: Nat,
    +h: {Nat.is_le(Nat.add(X, A.quad(VC.NW(n))), N) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(X, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), N) == True{} : Bool}:
  +e1 = Equal.cong(Nat, Nat, z => Nat.add(Nat.add(X, z), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), U32.to_nat(n), len_dU(n, dw, T, pfT, hy, hsrc))
  +e2 = Equal.trans(Nat, Nat.add(Nat.add(X, U32.to_nat(n)), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), Nat.add(X, Nat.add(U32.to_nat(n), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))), Nat.add(X, A.quad(VC.NW(n))),
    FD.nat__add_assoc(X, U32.to_nat(n), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))),
    Equal.cong(Nat, Nat, z => Nat.add(X, z), Nat.add(U32.to_nat(n), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), A.quad(VC.NW(n)), FD.nat__sub_add(A.quad(VC.NW(n)), U32.to_nat(n), n_le_qnwU(n, hy))))
  FD.logic__subst(Nat, z => {Nat.is_le(z, N) == True{} : Bool}, Nat.add(X, A.quad(VC.NW(n))), Nat.add(Nat.add(X, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))),
    Equal.sym(Nat, Nat.add(Nat.add(X, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), Nat.add(X, A.quad(VC.NW(n))), Equal.trans(Nat, Nat.add(Nat.add(X, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), Nat.add(Nat.add(X, U32.to_nat(n)), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), Nat.add(X, A.quad(VC.NW(n))), e1, e2)), h)

def hxd(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hk: {Nat.is_lt(k, 31n) == True{} : Bool},
    +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +X: Nat, +N: Nat,
    +h: {Nat.is_le(Nat.add(X, A.quad(VC.NW(n))), N) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(X, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))), N) == True{} : Bool}:
  hxdU(n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc, X, N, h)

# O.put_words at byte 1 of word q, data-only: its bytes (SWc: the tree's OR the zero tree's).
def bw1U(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {UA.BYT(UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  +Z = VC.ZT(dd)
  +eLW = len_w(n, dw, T, pfT, hsrc)
  +hr = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eLW), hl)
  +hwe = win_end(q, 1n, VC.NW(n), VB.pw(dd), {==}, hl)
  +hzZ = zt_win(dd, Nat.add(A.quad(q), 1n), A.quad(List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T)))), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(A.quad(q), 1n), A.quad(z)), A.quad(VB.pw(dd))) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eLW), hwe))
  +e1 = bytes_swc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, pf, hr)
  +e2 = UB1.swcb(VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, FD.array__trep_perfect(U32, dd, 0), hr, hzZ)
  +hz2 = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), Equal.sym(Nat, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), U32.to_nat(n), len_dU(n, dw, T, pfT, hy, hsrc)), hz)
  +e3 = spl_or(dd, D, Nat.add(A.quad(q), 1n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))), UWD.key_anyU(n, dw, T, pfT, hy, hsrc, htz), pf,
    hxdU(n, dw, T, pfT, hy, hsrc, Nat.add(A.quad(q), 1n), A.quad(VB.pw(dd)), hwe), hz2)
  Equal.trans(+List<U32>, UA.BYT(UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), ZOR(UA.BYT(D), UA.BYT(UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), e1,
    Equal.trans(+List<U32>, ZOR(UA.BYT(D), UA.BYT(UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0))), ZOR(UA.BYT(D), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 1n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))),
      Equal.cong(+List<U32>, +List<U32>, z => ZOR(UA.BYT(D), z), UA.BYT(UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0)), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 1n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))), e2), e3))

def bw1(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {UA.BYT(UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  bw1U(dd, D, q, dw, T, n, pf, pfT, VC.hyU(n, k, hk, hy), hsrc, hl, htz, hz)

# O.put_words at byte 2 of word q, data-only: its bytes (SWc: the tree's OR the zero tree's).
def bw2U(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {UA.BYT(UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  +Z = VC.ZT(dd)
  +eLW = len_w(n, dw, T, pfT, hsrc)
  +hr = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eLW), hl)
  +hwe = win_end(q, 2n, VC.NW(n), VB.pw(dd), {==}, hl)
  +hzZ = zt_win(dd, Nat.add(A.quad(q), 2n), A.quad(List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T)))), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(A.quad(q), 2n), A.quad(z)), A.quad(VB.pw(dd))) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eLW), hwe))
  +e1 = bytes_swc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, pf, hr)
  +e2 = UB2.swcb(VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, FD.array__trep_perfect(U32, dd, 0), hr, hzZ)
  +hz2 = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), Equal.sym(Nat, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), U32.to_nat(n), len_dU(n, dw, T, pfT, hy, hsrc)), hz)
  +e3 = spl_or(dd, D, Nat.add(A.quad(q), 2n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))), UWD.key_anyU(n, dw, T, pfT, hy, hsrc, htz), pf,
    hxdU(n, dw, T, pfT, hy, hsrc, Nat.add(A.quad(q), 2n), A.quad(VB.pw(dd)), hwe), hz2)
  Equal.trans(+List<U32>, UA.BYT(UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), ZOR(UA.BYT(D), UA.BYT(UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), e1,
    Equal.trans(+List<U32>, ZOR(UA.BYT(D), UA.BYT(UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0))), ZOR(UA.BYT(D), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 2n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))),
      Equal.cong(+List<U32>, +List<U32>, z => ZOR(UA.BYT(D), z), UA.BYT(UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0)), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 2n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))), e2), e3))

def bw2(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {UA.BYT(UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  bw2U(dd, D, q, dw, T, n, pf, pfT, VC.hyU(n, k, hk, hy), hsrc, hl, htz, hz)

# O.put_words at byte 3 of word q, data-only: its bytes (SWc: the tree's OR the zero tree's).
def bw3U(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {UA.BYT(UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  +Z = VC.ZT(dd)
  +eLW = len_w(n, dw, T, pfT, hsrc)
  +hr = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eLW), hl)
  +hwe = win_end(q, 3n, VC.NW(n), VB.pw(dd), {==}, hl)
  +hzZ = zt_win(dd, Nat.add(A.quad(q), 3n), A.quad(List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T)))), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(A.quad(q), 3n), A.quad(z)), A.quad(VB.pw(dd))) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eLW), hwe))
  +e1 = bytes_swc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, pf, hr)
  +e2 = UB3.swcb(VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, FD.array__trep_perfect(U32, dd, 0), hr, hzZ)
  +hz2 = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), Equal.sym(Nat, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), U32.to_nat(n), len_dU(n, dw, T, pfT, hy, hsrc)), hz)
  +e3 = spl_or(dd, D, Nat.add(A.quad(q), 3n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))), UWD.key_anyU(n, dw, T, pfT, hy, hsrc, htz), pf,
    hxdU(n, dw, T, pfT, hy, hsrc, Nat.add(A.quad(q), 3n), A.quad(VB.pw(dd)), hwe), hz2)
  Equal.trans(+List<U32>, UA.BYT(UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), ZOR(UA.BYT(D), UA.BYT(UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), e1,
    Equal.trans(+List<U32>, ZOR(UA.BYT(D), UA.BYT(UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0))), ZOR(UA.BYT(D), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 3n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))),
      Equal.cong(+List<U32>, +List<U32>, z => ZOR(UA.BYT(D), z), UA.BYT(UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, Z, q, 0)), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 3n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))), e2), e3))

def bw3(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {UA.BYT(UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  bw3U(dd, D, q, dw, T, n, pf, pfT, VC.hyU(n, k, hk, hy), hsrc, hl, htz, hz)

# ---- the aligned copy (VB.mone) on lists: a run of stores into zero slots is the OR run ----
def MONEL(m: Nat, +i: Nat, +j: Nat, +A: +List<U32>, +S: FD.array__Tree<U32>) -> +List<U32>:
  match m:
    case 0n: A
    case 1n+p: MONEL(p, 1n+i, 1n+j, FD.spec_common__update(U32, A, j, VB.slot(S, i)), S)

law slw_mone:
  for +m: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +S: FD.array__Tree<U32>
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(m, j), VB.pw(dd)) == True{} : Bool}
  {UW.SLW(VB.mone(m, i, j, dd, D, S)) == MONEL(m, i, j, UW.SLW(D), S) : +List<U32>}
def slw_mone(m, i, j, dd, D, S, pf, hj):
  match m:
    case 0n: {==}
    case 1n+ +p:
      +v = VB.slot(S, i)
      +hj1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hi = FD.nat__le_lt_trans(j, Nat.add(p, j), VB.pw(dd), Order.left_below_sum(p, j), FD.nat__succ_le_lt(Nat.add(p, j), VB.pw(dd), hj))
      Equal.trans(+List<U32>, UW.SLW(VB.mone(p, 1n+i, 1n+j, dd, FD.array__upd(U32, dd, D, j, v), S)), MONEL(p, 1n+i, 1n+j, UW.SLW(FD.array__upd(U32, dd, D, j, v)), S),
        MONEL(p, 1n+i, 1n+j, FD.spec_common__update(U32, UW.SLW(D), j, v), S),
        slw_mone(p, 1n+i, 1n+j, dd, FD.array__upd(U32, dd, D, j, v), S, FD.array__upd_perfect(U32, dd, D, j, v, pf), hj1),
        Equal.cong(+List<U32>, +List<U32>, z => MONEL(p, 1n+i, 1n+j, z, S), UW.SLW(FD.array__upd(U32, dd, D, j, v)), FD.spec_common__update(U32, UW.SLW(D), j, v), FD.array__upd_slots(U32, dd, D, j, v, hi, pf)))

law zor_upd:
  for +A: +List<U32>
  for +B: +List<U32>
  for +j: Nat
  for +v: U32
  for +h: {FD.flat__nthc(A, j) == 0 : U32}
  {FD.spec_common__update(U32, ZOR(A, B), j, v) == ZOR(A, FD.spec_common__update(U32, B, j, v)) : +List<U32>}
def zor_upd(A, B, j, v, h):
  match A B j:
    case Nil{} _ _: {==}
    case Con{+a, +at} Nil{} _: {==}
    case Con{+a, +at} Con{+b, +bt} 0n:
      Equal.sym(+List<U32>, Con{U32.or(a, v), ZOR(at, bt)}, Con{v, ZOR(at, bt)},
        Equal.cong(U32, +List<U32>, z => Con{z, ZOR(at, bt)}, U32.or(a, v), v, Equal.trans(U32, U32.or(a, v), U32.or(0, v), v, Equal.cong(U32, U32, z => U32.or(z, v), a, 0, h), VBE.zero_or(v))))
    case Con{+a, +at} Con{+b, +bt} 1n+ +p:
      Equal.cong(+List<U32>, +List<U32>, z => Con{U32.or(a, b), z}, FD.spec_common__update(U32, ZOR(at, bt), p, v), ZOR(at, FD.spec_common__update(U32, bt, p, v)), zor_upd(at, bt, p, v, h))

# the m words at j of D are zero (its bytes there): the copy of them onto D OR B is D OR the copy onto B
law monel_zor:
  for +m: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +B: +List<U32>
  for +S: FD.array__Tree<U32>
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hz: {VS.bt(A.quad(m), VS.bdr(A.quad(j), UA.BYT(D))) == UW.ZB(A.quad(m)) : +List<U32>}
  for +hl: {Nat.is_le(Nat.add(m, j), VB.pw(dd)) == True{} : Bool}
  {MONEL(m, i, j, ZOR(UW.SLW(D), B), S) == ZOR(UW.SLW(D), MONEL(m, i, j, B, S)) : +List<U32>}
def monel_zor(m, i, j, dd, D, B, S, pf, hz, hl):
  match m:
    case 0n: {==}
    case 1n+ +p:
      +v = VB.slot(S, i)
      +BD = UA.BYT(D)
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hl)
      +hi = FD.nat__le_lt_trans(Nat.add(0n, j), Nat.add(p, j), VB.pw(dd), Order.left_below_sum(p, j), FD.nat__succ_le_lt(Nat.add(p, j), VB.pw(dd), hl))
      +hz0 = FD.logic__subst(Nat, z => {VS.bt(A.quad(1n+p), VS.bdr(z, BD)) == UW.ZB(A.quad(1n+p)) : +List<U32>}, A.quad(j), Nat.add(A.quad(j), 0n), Equal.sym(Nat, Nat.add(A.quad(j), 0n), A.quad(j), FD.nat__add_zero(A.quad(j))), hz)
      +h0 = UW.zslot_g(dd, D, j, 0n, A.quad(1n+p), 0n, 0n, pf, hz0, {==}, Order.add_left(4n, 0n, A.quad(p), FD.nat__zero_le(A.quad(p))), hi)
      +eW = Equal.trans(+List<U32>, VS.bdr(A.quad(1n+j), BD), VS.bdr(Nat.add(A.quad(j), 4n), BD), VS.bdr(4n, VS.bdr(A.quad(j), BD)),
        Equal.cong(Nat, +List<U32>, z => VS.bdr(z, BD), A.quad(1n+j), Nat.add(A.quad(j), 4n), FD.nat__add_comm(4n, A.quad(j))), UW.bdr_add(A.quad(j), 4n, BD))
      +z1 = Equal.trans(+List<U32>, VS.bt(A.quad(p), VS.bdr(4n, VS.bdr(A.quad(j), BD))), VS.bt(A.quad(p), VS.bdr(4n, VS.bt(A.quad(1n+p), VS.bdr(A.quad(j), BD)))), UW.ZB(A.quad(p)),
        UW.bt_bdr_bt(A.quad(p), 4n, A.quad(1n+p), VS.bdr(A.quad(j), BD), FD.nat__le_refl(A.quad(1n+p))),
        FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(p), VS.bdr(4n, z)) == UW.ZB(A.quad(p)) : +List<U32>}, UW.ZB(A.quad(1n+p)), VS.bt(A.quad(1n+p), VS.bdr(A.quad(j), BD)),
          Equal.sym(+List<U32>, VS.bt(A.quad(1n+p), VS.bdr(A.quad(j), BD)), UW.ZB(A.quad(1n+p)), hz), UW.zb_win(4n, A.quad(p), A.quad(1n+p), FD.nat__le_refl(A.quad(1n+p)))))
      +hz1 = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(p), z) == UW.ZB(A.quad(p)) : +List<U32>}, VS.bdr(4n, VS.bdr(A.quad(j), BD)), VS.bdr(A.quad(1n+j), BD), Equal.sym(+List<U32>, VS.bdr(A.quad(1n+j), BD), VS.bdr(4n, VS.bdr(A.quad(j), BD)), eW), z1)
      Equal.trans(+List<U32>, MONEL(p, 1n+i, 1n+j, FD.spec_common__update(U32, ZOR(UW.SLW(D), B), j, v), S), MONEL(p, 1n+i, 1n+j, ZOR(UW.SLW(D), FD.spec_common__update(U32, B, j, v)), S),
        ZOR(UW.SLW(D), MONEL(p, 1n+i, 1n+j, FD.spec_common__update(U32, B, j, v), S)),
        Equal.cong(+List<U32>, +List<U32>, z => MONEL(p, 1n+i, 1n+j, z, S), FD.spec_common__update(U32, ZOR(UW.SLW(D), B), j, v), ZOR(UW.SLW(D), FD.spec_common__update(U32, B, j, v)), zor_upd(UW.SLW(D), B, j, v, h0)),
        monel_zor(p, 1n+i, 1n+j, dd, D, FD.spec_common__update(U32, B, j, v), S, pf, hz1, hl1))

law nthc_rep:
  for +n: Nat
  for +j: Nat
  {FD.flat__nthc(FD.spec_common__replicate(U32, n, 0), j) == 0 : U32}
def nthc_rep(n, j):
  match n j:
    case 0n _: {==}
    case 1n+ +p 0n: {==}
    case 1n+ +p 1n+ +q: nthc_rep(p, q)
def slot_zt(+dd: Nat, +j: Nat) -> {VB.slot(VC.ZT(dd), j) == 0 : U32}:
  %Equal.sym(List<&2, U32>, UW.SLW(VC.ZT(dd)), FD.spec_common__replicate(U32, FD.spec_common__pow2(dd), 0), FD.array__trep_slots(U32, dd, 0)) : {FD.flat__nthc(_, j) == 0 : U32}
  nthc_rep(FD.spec_common__pow2(dd), j)

# ---- O.put_words at a word boundary, data-only ----
def PW0b(b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32) -> FD.array__Tree<U32>:
  match b:
    case True{}: VB.mone(VC.NW(n), 0n, q, dd, D, T)
    case False{}: UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, D, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))

# a tree whose slots are D's OR the zero tree's aligned copy has the data bytes spliced in
def fin0U(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +M: FD.array__Tree<U32>, +eS: {UW.SLW(M) == ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))) : +List<U32>})
    -> {UA.BYT(M) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  +Z = VC.ZT(dd)
  +hj = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, VC.NW(n)), Nat.add(VC.NW(n), q), FD.nat__add_comm(q, VC.NW(n)), FD.nat__lt_le(Nat.add(q, VC.NW(n)), VB.pw(dd), hl))
  +eZb = UW.mone_bytes(VC.NW(n), 0n, q, dd, Z, dw, T, FD.array__trep_perfect(U32, dd, 0), pfT, hj, hsrc)
  +eZ = FD.logic__subst(Nat, z => {UA.BYT(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T)) == UW.SPL(UA.BYT(Z), z, FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))) : +List<U32>}, A.quad(q), Nat.add(A.quad(q), 0n), Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))), eZb)
  +hwe = win_end(q, 0n, VC.NW(n), VB.pw(dd), {==}, hl)
  +hz2 = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), Equal.sym(Nat, List.length(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), U32.to_nat(n), len_dU(n, dw, T, pfT, hy, hsrc)), hz)
  +e3 = spl_or(dd, D, Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))), UWD.key_anyU(n, dw, T, pfT, hy, hsrc, htz), pf,
    hxdU(n, dw, T, pfT, hy, hsrc, Nat.add(A.quad(q), 0n), A.quad(VB.pw(dd)), hwe), hz2)
  +eB = Equal.trans(+List<U32>, FX.limbs(UW.SLW(M)), FX.limbs(ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T)))), ZOR(UA.BYT(D), UA.BYT(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))),
    Equal.cong(+List<U32>, +List<U32>, z => FX.limbs(z), UW.SLW(M), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))), eS), limbs_zor(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))))
  Equal.trans(+List<U32>, UA.BYT(M), ZOR(UA.BYT(D), UA.BYT(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))), eB,
    Equal.trans(+List<U32>, ZOR(UA.BYT(D), UA.BYT(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))), ZOR(UA.BYT(D), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 0n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))),
      Equal.cong(+List<U32>, +List<U32>, z => ZOR(UA.BYT(D), z), UA.BYT(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T)), UW.SPL(UA.BYT(Z), Nat.add(A.quad(q), 0n), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))), eZ), e3))

def fin0(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +M: FD.array__Tree<U32>, +eS: {UW.SLW(M) == ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))) : +List<U32>})
    -> {UA.BYT(M) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  fin0U(dd, D, q, dw, T, n, pf, pfT, VC.hyU(n, k, hk, hy), hsrc, hl, htz, hz, M, eS)

def bw0U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {UA.BYT(PW0b(b, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  match b:
    case True{}:
    +Z = VC.ZT(dd)
    +pfZ = FD.array__trep_perfect(U32, dd, 0)
    +hz0 = FD.logic__subst(Nat, z => {VS.bt(U32.to_nat(n), VS.bdr(z, UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), hz)
    +eQ = UWD.n_qr(n, UWD.RR(n), {==})
    +hzQ = UWD.zpre(A.quad(VY.QL(n)), UWD.RR(n), VS.bdr(A.quad(q), UA.BYT(D)),
      FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(A.quad(q), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), Nat.add(A.quad(VY.QL(n)), UWD.RR(n)), eQ, hz0))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), VY.RM(n), 0, FD.u32alg__eq_of(VY.RM(n), 0, eb))
      +eNW = Equal.trans(Nat, VC.NW(n), Nat.add(VY.QL(n), VD.s_rng(2n, 3n+UWD.RR(n))), VY.QL(n), UWD.nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(VY.QL(n), VD.s_rng(2n, 3n+UWD.RR(n))), Nat.add(VY.QL(n), 0n), VY.QL(n), Equal.cong(Nat, Nat, z => Nat.add(VY.QL(n), VD.s_rng(2n, 3n+z)), UWD.RR(n), 0n, eR), FD.nat__add_zero(VY.QL(n))))
      +eN = Equal.trans(Nat, U32.to_nat(n), Nat.add(A.quad(VY.QL(n)), UWD.RR(n)), A.quad(VY.QL(n)), eQ,
        Equal.trans(Nat, Nat.add(A.quad(VY.QL(n)), UWD.RR(n)), Nat.add(A.quad(VY.QL(n)), 0n), A.quad(VY.QL(n)), Equal.cong(Nat, Nat, z => Nat.add(A.quad(VY.QL(n)), z), UWD.RR(n), 0n, eR), FD.nat__add_zero(A.quad(VY.QL(n)))))
      +hzW = FD.logic__subst(Nat, z => {VS.bt(A.quad(z), VS.bdr(A.quad(q), UA.BYT(D))) == UW.ZB(A.quad(z)) : +List<U32>}, VY.QL(n), VC.NW(n), Equal.sym(Nat, VC.NW(n), VY.QL(n), eNW),
        FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(A.quad(q), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), A.quad(VY.QL(n)), eN, hz0))
      +hj = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, VC.NW(n)), Nat.add(VC.NW(n), q), FD.nat__add_comm(q, VC.NW(n)), FD.nat__lt_le(Nat.add(q, VC.NW(n)), VB.pw(dd), hl))
      +eS = Equal.trans(+List<U32>, UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, D, T)), MONEL(VC.NW(n), 0n, q, UW.SLW(D), T), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))),
        slw_mone(VC.NW(n), 0n, q, dd, D, T, pf, hj),
        Equal.trans(+List<U32>, MONEL(VC.NW(n), 0n, q, UW.SLW(D), T), MONEL(VC.NW(n), 0n, q, ZOR(UW.SLW(D), UW.SLW(Z)), T), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))),
          Equal.cong(+List<U32>, +List<U32>, z => MONEL(VC.NW(n), 0n, q, z, T), UW.SLW(D), ZOR(UW.SLW(D), UW.SLW(Z)), Equal.sym(+List<U32>, ZOR(UW.SLW(D), UW.SLW(Z)), UW.SLW(D), zor_zt(dd, D, pf))),
          Equal.trans(+List<U32>, MONEL(VC.NW(n), 0n, q, ZOR(UW.SLW(D), UW.SLW(Z)), T), ZOR(UW.SLW(D), MONEL(VC.NW(n), 0n, q, UW.SLW(Z), T)), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))),
            monel_zor(VC.NW(n), 0n, q, dd, D, UW.SLW(Z), T, pf, hzW, hj),
            Equal.cong(+List<U32>, +List<U32>, z => ZOR(UW.SLW(D), z), MONEL(VC.NW(n), 0n, q, UW.SLW(Z), T), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T)),
              Equal.sym(+List<U32>, UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T)), MONEL(VC.NW(n), 0n, q, UW.SLW(Z), T), slw_mone(VC.NW(n), 0n, q, dd, Z, T, pfZ, hj))))))
      fin0U(dd, D, q, dw, T, n, pf, pfT, hy, hsrc, hl, htz, hz, VB.mone(VC.NW(n), 0n, q, dd, D, T), eS)
    case False{}:
    +Z = VC.ZT(dd)
    +pfZ = FD.array__trep_perfect(U32, dd, 0)
    +hz0 = FD.logic__subst(Nat, z => {VS.bt(U32.to_nat(n), VS.bdr(z, UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), hz)
    +eQ = UWD.n_qr(n, UWD.RR(n), {==})
    +hzQ = UWD.zpre(A.quad(VY.QL(n)), UWD.RR(n), VS.bdr(A.quad(q), UA.BYT(D)),
      FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(A.quad(q), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, U32.to_nat(n), Nat.add(A.quad(VY.QL(n)), UWD.RR(n)), eQ, hz0))
      +eNW = VY.nw_qU(n, hy, eb)
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), 1n+VY.QL(n), eNW, hl)
      +hq1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 1n+VY.QL(n)), 1n+Nat.add(VY.QL(n), q),
        Equal.trans(Nat, Nat.add(q, 1n+VY.QL(n)), 1n+Nat.add(q, VY.QL(n)), 1n+Nat.add(VY.QL(n), q), FD.nat__add_succ(q, VY.QL(n)), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(q, VY.QL(n)), Nat.add(VY.QL(n), q), FD.nat__add_comm(q, VY.QL(n)))), hl1)
      +hjQ = FD.nat__lt_le(Nat.add(VY.QL(n), q), VB.pw(dd), FD.nat__lt_trans(Nat.add(VY.QL(n), q), 1n+Nat.add(VY.QL(n), q), VB.pw(dd), FD.nat__lt_succ(Nat.add(VY.QL(n), q)), hq1))
      +hi = FD.nat__lt_trans(Nat.add(VY.QL(n), q), 1n+Nat.add(VY.QL(n), q), VB.pw(dd), FD.nat__lt_succ(Nat.add(VY.QL(n), q)), hq1)
      +hi2 = hi
      +pf1 = VB.mone_perfect(VY.QL(n), 0n, q, dd, D, T, pf)
      +pf1z = VB.mone_perfect(VY.QL(n), 0n, q, dd, Z, T, pfZ)
      +e1 = Equal.trans(+List<U32>, UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, D, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))), ORL(UW.SLW(VB.mone(VY.QL(n), 0n, q, dd, D, T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(D), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))),
        slw_orw(dd, VB.mone(VY.QL(n), 0n, q, dd, D, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)), pf1, hi2),
        Equal.cong(+List<U32>, +List<U32>, z => ORL(z, Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), UW.SLW(VB.mone(VY.QL(n), 0n, q, dd, D, T)), MONEL(VY.QL(n), 0n, q, UW.SLW(D), T), slw_mone(VY.QL(n), 0n, q, dd, D, T, pf, hjQ)))
      +e2 = Equal.trans(+List<U32>, ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(D), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ORL(MONEL(VY.QL(n), 0n, q, ZOR(UW.SLW(D), UW.SLW(Z)), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ORL(ZOR(UW.SLW(D), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))),
        Equal.cong(+List<U32>, +List<U32>, z => ORL(MONEL(VY.QL(n), 0n, q, z, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), UW.SLW(D), ZOR(UW.SLW(D), UW.SLW(Z)), Equal.sym(+List<U32>, ZOR(UW.SLW(D), UW.SLW(Z)), UW.SLW(D), zor_zt(dd, D, pf))),
        Equal.cong(+List<U32>, +List<U32>, z => ORL(z, Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), MONEL(VY.QL(n), 0n, q, ZOR(UW.SLW(D), UW.SLW(Z)), T), ZOR(UW.SLW(D), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T)), monel_zor(VY.QL(n), 0n, q, dd, D, UW.SLW(Z), T, pf, hzQ, hjQ)))
      +e3 = Equal.trans(+List<U32>, ORL(ZOR(UW.SLW(D), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ZOR(UW.SLW(D), ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))), ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))))),
        zor_orl(UW.SLW(D), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))),
        Equal.cong(+List<U32>, +List<U32>, z => ZOR(UW.SLW(D), z), ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))),
          Equal.trans(+List<U32>, ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ORL(UW.SLW(VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))),
            Equal.cong(+List<U32>, +List<U32>, z => ORL(z, Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T), UW.SLW(VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T)), Equal.sym(+List<U32>, UW.SLW(VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T)), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T), slw_mone(VY.QL(n), 0n, q, dd, Z, T, pfZ, hjQ))),
            Equal.sym(+List<U32>, UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))), ORL(UW.SLW(VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), slw_orw(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)), pf1z, hi2)))))
      # the zero tree: the OR into its untouched slot is the store, the aligned copy of all NW words
      +hs0 = Equal.trans(U32, VB.slot(VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q)), VB.slot(Z, Nat.add(VY.QL(n), q)), 0, VBE.slot_mone_hi(VY.QL(n), 0n, q, dd, Z, T, Nat.add(VY.QL(n), q), pfZ, hjQ, FD.nat__le_refl(Nat.add(VY.QL(n), q))), slot_zt(dd, Nat.add(VY.QL(n), q)))
      +em = Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), FD.array__upd(U32, dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), VB.mone(Nat.add(VY.QL(n), 1n), 0n, q, dd, Z, T),
        UW.orw_zero(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)), hs0),
        Equal.trans(FD.array__Tree<U32>, FD.array__upd(U32, dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), FD.array__upd(U32, dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, Nat.add(VY.QL(n), 0n))), VB.mone(Nat.add(VY.QL(n), 1n), 0n, q, dd, Z, T),
          Equal.cong(Nat, FD.array__Tree<U32>, z => FD.array__upd(U32, dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, z)), VY.QL(n), Nat.add(VY.QL(n), 0n), Equal.sym(Nat, Nat.add(VY.QL(n), 0n), VY.QL(n), FD.nat__add_zero(VY.QL(n)))),
          VB.mone_add(VY.QL(n), 1n, 0n, q, dd, Z, T)))
      +e1Q = Equal.trans(Nat, Nat.add(VY.QL(n), 1n), 1n+Nat.add(VY.QL(n), 0n), 1n+VY.QL(n), FD.nat__add_succ(VY.QL(n), 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(VY.QL(n), 0n), VY.QL(n), FD.nat__add_zero(VY.QL(n))))
      +em2 = Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), VB.mone(Nat.add(VY.QL(n), 1n), 0n, q, dd, Z, T), VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T), em,
        Equal.cong(Nat, FD.array__Tree<U32>, z => VB.mone(z, 0n, q, dd, Z, T), Nat.add(VY.QL(n), 1n), VC.NW(n), Equal.trans(Nat, Nat.add(VY.QL(n), 1n), 1n+VY.QL(n), VC.NW(n), e1Q, Equal.sym(Nat, VC.NW(n), 1n+VY.QL(n), eNW))))
      +e4 = Equal.cong(FD.array__Tree<U32>, +List<U32>, z => ZOR(UW.SLW(D), UW.SLW(z)), UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T), em2)
      +eS = Equal.trans(+List<U32>, UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, D, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)))), ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(D), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))), e1,
        Equal.trans(+List<U32>, ORL(MONEL(VY.QL(n), 0n, q, UW.SLW(D), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ORL(ZOR(UW.SLW(D), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))), e2,
          Equal.trans(+List<U32>, ORL(ZOR(UW.SLW(D), MONEL(VY.QL(n), 0n, q, UW.SLW(Z), T)), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), ZOR(UW.SLW(D), UW.SLW(UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, VC.ZT(dd), T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))))), ZOR(UW.SLW(D), UW.SLW(VB.mone(VC.NW(n), 0n, q, dd, VC.ZT(dd), T))), e3, e4)))
      fin0U(dd, D, q, dw, T, n, pf, pfT, hy, hsrc, hl, htz, hz, UW.ORW(dd, VB.mone(VY.QL(n), 0n, q, dd, D, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n))), eS)

def bw0(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(q, VC.NW(n)), VB.pw(dd)) == True{} : Bool}, +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {UA.BYT(PW0b(b, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  bw0U(b, dd, D, q, dw, T, n, pf, pfT, VC.hyU(n, k, hk, hy), hsrc, hl, htz, hz, eb)

# the interior words of a write at byte 1: 4 M <= n - 3
def mb1bU(+b1: Bool, +b2: Bool, +n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +eb1: {U32.is_lt(U32.add(n, 1), 4) == b1 : Bool}, +eb2: {U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)) == b2 : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pick(b1, 0, O.pick(b2, U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))))), Nat.sub(U32.to_nat(n), 3n)) == True{} : Bool}:
  match b1 b2:
    case True{} _: FD.nat__zero_le(Nat.sub(U32.to_nat(n), 3n))
    case False{} True{}:
    +ha = VB.add_nwk(n, 1, 1n, U32.to_nat(n), {==}, {==}, FD.nat__le_trans(Nat.add(1n, U32.to_nat(n)), VC.YL(n), U32.to_nat(VB.UMAX()), Order.add_right(1n, 31n, U32.to_nat(n), {==}), hy))
    +h4 = FD.nat__not_lt_le(U32.to_nat(U32.add(n, 1)), 4n, FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(U32.add(n, 1), 4), Nat.is_lt(U32.to_nat(U32.add(n, 1)), 4n), VR.lt_u32(U32.add(n, 1), 4), eb1))
    +es = FD.u32__sub_nat(U32.add(n, 1), 4, h4)
    +e4 = Equal.trans(Nat, U32.to_nat(U32.sub(U32.add(n, 1), 4)), Nat.sub(U32.to_nat(U32.add(n, 1)), 4n), Nat.sub(U32.to_nat(n), 3n), es,
      Equal.cong(Nat, Nat, z => Nat.sub(z, 4n), U32.to_nat(U32.add(n, 1)), Nat.add(1n, U32.to_nat(n)), ha))
    +hsh = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), z) == True{} : Bool}, U32.to_nat(U32.sub(U32.add(n, 1), 4)), Nat.sub(U32.to_nat(n), 3n), e4,
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), z) == True{} : Bool}, Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 1), 4), 3))), U32.to_nat(U32.sub(U32.add(n, 1), 4)),
        Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(n, 1), 4)), Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 1), 4), 3))), VC.split4(U32.sub(U32.add(n, 1), 4))),
        FD.nat__le_add_right(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 1), 4), 3)))))
      +hlt = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)), Nat.is_lt(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), VR.lt_u32(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)), eb2)
      FD.nat__le_trans(A.quad(U32.to_nat(U32.sub(VC.nwu(n), 1))), A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), Nat.sub(U32.to_nat(n), 3n),
        UW.quad_le(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)), FD.nat__lt_le(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)), hlt)), hsh)
    case False{} False{}:
    +ha = VB.add_nwk(n, 1, 1n, U32.to_nat(n), {==}, {==}, FD.nat__le_trans(Nat.add(1n, U32.to_nat(n)), VC.YL(n), U32.to_nat(VB.UMAX()), Order.add_right(1n, 31n, U32.to_nat(n), {==}), hy))
    +h4 = FD.nat__not_lt_le(U32.to_nat(U32.add(n, 1)), 4n, FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(U32.add(n, 1), 4), Nat.is_lt(U32.to_nat(U32.add(n, 1)), 4n), VR.lt_u32(U32.add(n, 1), 4), eb1))
    +es = FD.u32__sub_nat(U32.add(n, 1), 4, h4)
    +e4 = Equal.trans(Nat, U32.to_nat(U32.sub(U32.add(n, 1), 4)), Nat.sub(U32.to_nat(U32.add(n, 1)), 4n), Nat.sub(U32.to_nat(n), 3n), es,
      Equal.cong(Nat, Nat, z => Nat.sub(z, 4n), U32.to_nat(U32.add(n, 1)), Nat.add(1n, U32.to_nat(n)), ha))
    +hsh = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), z) == True{} : Bool}, U32.to_nat(U32.sub(U32.add(n, 1), 4)), Nat.sub(U32.to_nat(n), 3n), e4,
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), z) == True{} : Bool}, Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 1), 4), 3))), U32.to_nat(U32.sub(U32.add(n, 1), 4)),
        Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(n, 1), 4)), Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 1), 4), 3))), VC.split4(U32.sub(U32.add(n, 1), 4))),
        FD.nat__le_add_right(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 1), 4), 3)))))
      hsh

def mb1b(+b1: Bool, +b2: Bool, +n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +eb1: {U32.is_lt(U32.add(n, 1), 4) == b1 : Bool}, +eb2: {U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)) == b2 : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pick(b1, 0, O.pick(b2, U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n))))), Nat.sub(U32.to_nat(n), 3n)) == True{} : Bool}:
  mb1bU(b1, b2, n, VC.hyU(n, k, hk, hy), eb1, eb2)

def mb1U(+n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pw_mid(n, 1, VC.nwu(n)))), Nat.sub(U32.to_nat(n), 3n)) == True{} : Bool}:
  mb1bU(U32.is_lt(U32.add(n, 1), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)), n, hy, {==}, {==})

def mb1(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pw_mid(n, 1, VC.nwu(n)))), Nat.sub(U32.to_nat(n), 3n)) == True{} : Bool}:
  mb1U(n, VC.hyU(n, k, hk, hy))

# vuwp1.putwu with zeros only in the n bytes (its interior words lie in them: mb1)
def putwud1U(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 1n) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(i), 1n), UA.BYT(U))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  +SL = UW.SLW(TS)
  +NWU = VC.nwu(n)
  +NW = VC.NW(n)
  +Q = U32.shrn(pos, 2n)
  +MID = O.pw_mid(n, 1, VC.nwu(n))
  +M = U32.to_nat(O.pw_mid(n, 1, VC.nwu(n)))
  +K = U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 1, VC.nwu(n)))
  +KN = U32.to_nat(U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 1, VC.nwu(n))))
  +C1 = O.shr_over(VB.slot(TS, 0n), 1)
  +e3 = UW.ua_3(pos, i, 1n, 1, {==}, e, {==})
  +eq = UW.ua_q(pos, i, 1n, e, {==})
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
  +W1 = U32.to_nat(U32.sub(VC.nwu(n), 1))
  +eW1 = FD.u32__sub_nat(VC.nwu(n), 1, hNW1)
  +hM = UW.mid_le_g(U32.is_lt(U32.add(n, 1), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n)), U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 1), 4), 2n), {==})
  +eKN = FD.u32__sub_nat(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 1, VC.nwu(n)), hM)
  +eMK = Equal.trans(Nat, Nat.add(M, KN), Nat.add(M, Nat.sub(W1, M)), W1, Equal.cong(Nat, Nat, z => Nat.add(M, z), KN, Nat.sub(W1, M), eKN), FD.nat__sub_add(W1, M, hM))
  +eNW = Equal.trans(Nat, 1n+Nat.add(M, KN), 1n+W1, NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(M, KN), W1, eMK),
    Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)))
  +h1M = FD.logic__subst(Nat, z => {Nat.is_le(1n+M, z) == True{} : Bool}, 1n+W1, NW, Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)), hM)
  +hms = FD.nat__lt_le_trans(M, NW, VB.pw(ds), FD.nat__succ_le_lt(M, NW, h1M), hnw)
  +hmd = FD.nat__le_trans(Nat.add(M, 1n+i), Nat.add(NW, i), VB.pw(dd),
    FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(NW, i)) == True{} : Bool}, Nat.add(1n+M, i), Nat.add(M, 1n+i), Equal.sym(Nat, Nat.add(M, 1n+i), 1n+Nat.add(M, i), FD.nat__add_succ(M, i)), Order.add_right(1n+M, NW, i, h1M)),
    FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +eKM = Equal.trans(Nat, Nat.add(KN, 1n+M), 1n+Nat.add(KN, M), NW, FD.nat__add_succ(KN, M),
    Equal.trans(Nat, 1n+Nat.add(KN, M), 1n+Nat.add(M, KN), NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(KN, M), Nat.add(M, KN), FD.nat__add_comm(KN, M)), eNW))
  +hjs = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(ds)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), hnw)
  +hji = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +ej = VB.add_at(O.pw_mid(n, 1, VC.nwu(n)), 1, M, 1n+ds, {==}, VB.lt32s(ds, hds), VB.le_pw_lt(1n+M, ds, FD.nat__le_trans(1n+M, NW, VB.pw(ds), h1M, hnw)))
  +h0s = FD.nat__lt_le_trans(0n, NW, VB.pw(ds), FD.nat__lt_le_trans(0n, 1n, NW, {==}, hNW1), hnw)
  +hi0 = FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl)
  +D1 = UW.SWo(1, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0)
  +pf1 = UW.swo_perfect(1, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0, pf)
  +D2 = UW.SWo(1, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)
  +C2 = UW.CRY(1, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), C1)
  +pf2 = UW.swo_perfect(1, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1, pf1)
  +D3 = UW.SWo(1, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2)
  +C3 = UW.CRY(1, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), C2)
  +pf3 = UW.swo_perfect(1, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2, pf2)
  +X0 = Nat.add(A.quad(i), 1n)
  +B = UA.BYT(U)
  +hb = mb1U(n, hy)
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, 3n), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, 3n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), 1n, 3n)))
  +zU = Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(3n, VS.bdr(X0, B))), UW.ZB(A.quad(M)),
    Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(Nat.add(X0, 3n), B)), VS.bt(A.quad(M), VS.bdr(3n, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt(A.quad(M), VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, 3n), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(A.quad(M), z), VS.bdr(Nat.add(X0, 3n), B), VS.bdr(3n, VS.bdr(X0, B)), UW.bdr_add(X0, 3n, B))),
    zwin(3n, A.quad(M), U32.to_nat(n), VS.bdr(X0, B), hz, hb))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), U32.or(O.shl_bytes(VB.slot(TS, 0n), 1), 0)), pf, hi0)
  +eA1 = Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n, z), UW.SLW(TS), Con{VB.slot(TS, 0n), VB.wdr(1n, UW.SLW(TS))},
    UW.wdr_con(UW.SLW(TS), 0n, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s)))
  +eD1 = Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(1, z, dd, U, i, 0), VS.wtake(1n, UW.SLW(TS)), [VB.slot(TS, 0n)], eA1)
  +hz1a = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(M), z) == UW.ZB(A.quad(M)) : +List<U32>}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(1, [VB.slot(TS, 0n)], dd, U, i, 0))),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(1, [VB.slot(TS, 0n)], dd, U, i, 0))), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hz1 = FD.logic__subst(FD.array__Tree<U32>, z => {VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), UA.BYT(z))) == UW.ZB(A.quad(M)) : +List<U32>}, UW.SWo(1, [VB.slot(TS, 0n)], dd, U, i, 0), D1,
    Equal.sym(FD.array__Tree<U32>, D1, UW.SWo(1, [VB.slot(TS, 0n)], dd, U, i, 0), eD1), hz1a)
  +eC1 = UW.cry_take(1, 0n, 0n, UW.SLW(TS), 0, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s))
  +pw1 = UP1.pwor(0n, 0, 0n, Q, i, 0, dd, ds, U, TS, {==}, eq, hd, hds, h0s, FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl), pf, pfS)
  +pm = UP1.pmid_b(U32.is_eq(MID, 0), M, MID, Q, i, dd, ds, D1, TS, {==}, {==}, eq, hd, hds, hms, hmd, hz1, pf1, pfS)
  +pt = UP1.ptail_b(U32.is_eq(K, 0), KN, K, U32.add(MID, 1), 1n+M, Q, i, C2, dd, ds, D2, TS, {==}, {==}, ej, eq, hd, hds, hjs, hji, pf2, pfS)
  +pc = UP1.pcarry_b(U32.is_eq(C3, 0), dd, D3, TS, U32.add(Q, NWU), Nat.add(NW, i), C3, VB.add_at(Q, NWU, i, dd, eq, hd32, hl), hd, hl, pf3)
  +fin = FD.logic__subst(Nat, z => {UW.ORS(dd, D3, Nat.add(z, i), C3) == UW.SWc(1, VS.wtake(z, UW.SLW(TS)), dd, U, i, 0) : FD.array__Tree<U32>}, 1n+Nat.add(M, KN), NW, eNW,
    UW.asm(1, dd, U, i, UW.SLW(TS), M, KN, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(UW.SLW(TS))) == True{} : Bool}, NW, 1n+Nat.add(M, KN), Equal.sym(Nat, 1n+Nat.add(M, KN), NW, eNW),
      FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hnw))))
  %Equal.sym(Bool, U32.is_eq(n, 0), False{}, hn) : {O.put_fin(n, O.pw_empty(_, U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), 1, e3) : {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), 1, e3) : {O.put_fin(n, O.pw_un(_, n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), 0), (FD.array__thaw(U32, TS), VB.slot(TS, 0n)), VB.get_n(ds, TS, 0, 0n, {==}, hds32, h0s, pfS)) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or1_at(U32.add(MID, 1), K, Q, O.pw_mid1(MID, Q, O.pw_or1(0n, 0, Q, 0, FD.array__thaw(U32, U), _))))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_or1(0n, 0, Q, 0, FD.array__thaw(U32, U), (FD.array__thaw(U32, TS), VB.slot(TS, 0n))), (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), UW.CRY(1, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0))), pw1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or1_at(U32.add(MID, 1), K, Q, O.pw_mid1(MID, Q, _)))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, UW.CRY(1, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0), C1, eC1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or1_at(U32.add(MID, 1), K, Q, O.pw_mid1(MID, Q, (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), _)))))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_mid1_run(U32.is_eq(MID, 0), MID, Q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), C1), (FD.array__thaw(U32, D2), (FD.array__thaw(U32, TS), C2)), pm) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or1_at(U32.add(MID, 1), K, Q, _))) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_or1_run(U32.is_eq(K, 0), U32.add(MID, 1), K, Q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), C2), (FD.array__thaw(U32, D3), (FD.array__thaw(U32, TS), C3)), pt) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), _)) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & Array<U32>, O.pw_carry_skip(U32.is_eq(C3, 0), U32.add(Q, NWU), FD.array__thaw(U32, D3), FD.array__thaw(U32, TS), C3), (FD.array__thaw(U32, UW.ORSb(U32.is_eq(C3, 0), dd, D3, Nat.add(NW, i), C3)), FD.array__thaw(U32, TS)), pc) :
    {O.put_fin(n, _) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  Equal.cong(FD.array__Tree<U32>, Array<U32> & O.Words, z => (FD.array__thaw(U32, z), O.Words{FD.array__thaw(U32, TS), n}), UW.ORS(dd, D3, Nat.add(NW, i), C3), UW.SWc(1, VS.wtake(NW, UW.SLW(TS)), dd, U, i, 0), fin)

def putwud1(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 1n) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool},
    +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(i), 1n), UA.BYT(U))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  putwud1U(dd, U, pos, i, ds, TS, n, e, hn, hd, hds, hNW1, hnw, hl, VC.hyU(n, k, hk, hy), hz, pf, pfS)

# the interior words of a write at byte 2: 4 M <= n - 2
def mb2bU(+b1: Bool, +b2: Bool, +n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +eb1: {U32.is_lt(U32.add(n, 2), 4) == b1 : Bool}, +eb2: {U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)) == b2 : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pick(b1, 0, O.pick(b2, U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))))), Nat.sub(U32.to_nat(n), 2n)) == True{} : Bool}:
  match b1 b2:
    case True{} _: FD.nat__zero_le(Nat.sub(U32.to_nat(n), 2n))
    case False{} True{}:
    +ha = VB.add_nwk(n, 2, 2n, U32.to_nat(n), {==}, {==}, FD.nat__le_trans(Nat.add(2n, U32.to_nat(n)), VC.YL(n), U32.to_nat(VB.UMAX()), Order.add_right(2n, 31n, U32.to_nat(n), {==}), hy))
    +h4 = FD.nat__not_lt_le(U32.to_nat(U32.add(n, 2)), 4n, FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(U32.add(n, 2), 4), Nat.is_lt(U32.to_nat(U32.add(n, 2)), 4n), VR.lt_u32(U32.add(n, 2), 4), eb1))
    +es = FD.u32__sub_nat(U32.add(n, 2), 4, h4)
    +e4 = Equal.trans(Nat, U32.to_nat(U32.sub(U32.add(n, 2), 4)), Nat.sub(U32.to_nat(U32.add(n, 2)), 4n), Nat.sub(U32.to_nat(n), 2n), es,
      Equal.cong(Nat, Nat, z => Nat.sub(z, 4n), U32.to_nat(U32.add(n, 2)), Nat.add(2n, U32.to_nat(n)), ha))
    +hsh = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), z) == True{} : Bool}, U32.to_nat(U32.sub(U32.add(n, 2), 4)), Nat.sub(U32.to_nat(n), 2n), e4,
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), z) == True{} : Bool}, Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 2), 4), 3))), U32.to_nat(U32.sub(U32.add(n, 2), 4)),
        Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(n, 2), 4)), Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 2), 4), 3))), VC.split4(U32.sub(U32.add(n, 2), 4))),
        FD.nat__le_add_right(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 2), 4), 3)))))
      +hlt = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)), Nat.is_lt(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), VR.lt_u32(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)), eb2)
      FD.nat__le_trans(A.quad(U32.to_nat(U32.sub(VC.nwu(n), 1))), A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), Nat.sub(U32.to_nat(n), 2n),
        UW.quad_le(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)), FD.nat__lt_le(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)), hlt)), hsh)
    case False{} False{}:
    +ha = VB.add_nwk(n, 2, 2n, U32.to_nat(n), {==}, {==}, FD.nat__le_trans(Nat.add(2n, U32.to_nat(n)), VC.YL(n), U32.to_nat(VB.UMAX()), Order.add_right(2n, 31n, U32.to_nat(n), {==}), hy))
    +h4 = FD.nat__not_lt_le(U32.to_nat(U32.add(n, 2)), 4n, FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(U32.add(n, 2), 4), Nat.is_lt(U32.to_nat(U32.add(n, 2)), 4n), VR.lt_u32(U32.add(n, 2), 4), eb1))
    +es = FD.u32__sub_nat(U32.add(n, 2), 4, h4)
    +e4 = Equal.trans(Nat, U32.to_nat(U32.sub(U32.add(n, 2), 4)), Nat.sub(U32.to_nat(U32.add(n, 2)), 4n), Nat.sub(U32.to_nat(n), 2n), es,
      Equal.cong(Nat, Nat, z => Nat.sub(z, 4n), U32.to_nat(U32.add(n, 2)), Nat.add(2n, U32.to_nat(n)), ha))
    +hsh = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), z) == True{} : Bool}, U32.to_nat(U32.sub(U32.add(n, 2), 4)), Nat.sub(U32.to_nat(n), 2n), e4,
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), z) == True{} : Bool}, Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 2), 4), 3))), U32.to_nat(U32.sub(U32.add(n, 2), 4)),
        Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(n, 2), 4)), Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 2), 4), 3))), VC.split4(U32.sub(U32.add(n, 2), 4))),
        FD.nat__le_add_right(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 2), 4), 3)))))
      hsh

def mb2b(+b1: Bool, +b2: Bool, +n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +eb1: {U32.is_lt(U32.add(n, 2), 4) == b1 : Bool}, +eb2: {U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)) == b2 : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pick(b1, 0, O.pick(b2, U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n))))), Nat.sub(U32.to_nat(n), 2n)) == True{} : Bool}:
  mb2bU(b1, b2, n, VC.hyU(n, k, hk, hy), eb1, eb2)

def mb2U(+n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pw_mid(n, 2, VC.nwu(n)))), Nat.sub(U32.to_nat(n), 2n)) == True{} : Bool}:
  mb2bU(U32.is_lt(U32.add(n, 2), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)), n, hy, {==}, {==})

def mb2(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pw_mid(n, 2, VC.nwu(n)))), Nat.sub(U32.to_nat(n), 2n)) == True{} : Bool}:
  mb2U(n, VC.hyU(n, k, hk, hy))

# vuwp2.putwu with zeros only in the n bytes (its interior words lie in them: mb2)
def putwud2U(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 2n) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(i), 2n), UA.BYT(U))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  +SL = UW.SLW(TS)
  +NWU = VC.nwu(n)
  +NW = VC.NW(n)
  +Q = U32.shrn(pos, 2n)
  +MID = O.pw_mid(n, 2, VC.nwu(n))
  +M = U32.to_nat(O.pw_mid(n, 2, VC.nwu(n)))
  +K = U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 2, VC.nwu(n)))
  +KN = U32.to_nat(U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 2, VC.nwu(n))))
  +C1 = O.shr_over(VB.slot(TS, 0n), 2)
  +e3 = UW.ua_3(pos, i, 2n, 2, {==}, e, {==})
  +eq = UW.ua_q(pos, i, 2n, e, {==})
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
  +W1 = U32.to_nat(U32.sub(VC.nwu(n), 1))
  +eW1 = FD.u32__sub_nat(VC.nwu(n), 1, hNW1)
  +hM = UW.mid_le_g(U32.is_lt(U32.add(n, 2), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n)), U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 2), 4), 2n), {==})
  +eKN = FD.u32__sub_nat(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 2, VC.nwu(n)), hM)
  +eMK = Equal.trans(Nat, Nat.add(M, KN), Nat.add(M, Nat.sub(W1, M)), W1, Equal.cong(Nat, Nat, z => Nat.add(M, z), KN, Nat.sub(W1, M), eKN), FD.nat__sub_add(W1, M, hM))
  +eNW = Equal.trans(Nat, 1n+Nat.add(M, KN), 1n+W1, NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(M, KN), W1, eMK),
    Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)))
  +h1M = FD.logic__subst(Nat, z => {Nat.is_le(1n+M, z) == True{} : Bool}, 1n+W1, NW, Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)), hM)
  +hms = FD.nat__lt_le_trans(M, NW, VB.pw(ds), FD.nat__succ_le_lt(M, NW, h1M), hnw)
  +hmd = FD.nat__le_trans(Nat.add(M, 1n+i), Nat.add(NW, i), VB.pw(dd),
    FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(NW, i)) == True{} : Bool}, Nat.add(1n+M, i), Nat.add(M, 1n+i), Equal.sym(Nat, Nat.add(M, 1n+i), 1n+Nat.add(M, i), FD.nat__add_succ(M, i)), Order.add_right(1n+M, NW, i, h1M)),
    FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +eKM = Equal.trans(Nat, Nat.add(KN, 1n+M), 1n+Nat.add(KN, M), NW, FD.nat__add_succ(KN, M),
    Equal.trans(Nat, 1n+Nat.add(KN, M), 1n+Nat.add(M, KN), NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(KN, M), Nat.add(M, KN), FD.nat__add_comm(KN, M)), eNW))
  +hjs = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(ds)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), hnw)
  +hji = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +ej = VB.add_at(O.pw_mid(n, 2, VC.nwu(n)), 1, M, 1n+ds, {==}, VB.lt32s(ds, hds), VB.le_pw_lt(1n+M, ds, FD.nat__le_trans(1n+M, NW, VB.pw(ds), h1M, hnw)))
  +h0s = FD.nat__lt_le_trans(0n, NW, VB.pw(ds), FD.nat__lt_le_trans(0n, 1n, NW, {==}, hNW1), hnw)
  +hi0 = FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl)
  +D1 = UW.SWo(2, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0)
  +pf1 = UW.swo_perfect(2, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0, pf)
  +D2 = UW.SWo(2, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)
  +C2 = UW.CRY(2, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), C1)
  +pf2 = UW.swo_perfect(2, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1, pf1)
  +D3 = UW.SWo(2, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2)
  +C3 = UW.CRY(2, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), C2)
  +pf3 = UW.swo_perfect(2, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2, pf2)
  +X0 = Nat.add(A.quad(i), 2n)
  +B = UA.BYT(U)
  +hb = mb2U(n, hy)
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, 2n), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, 2n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), 2n, 2n)))
  +zU = Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(2n, VS.bdr(X0, B))), UW.ZB(A.quad(M)),
    Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(Nat.add(X0, 2n), B)), VS.bt(A.quad(M), VS.bdr(2n, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt(A.quad(M), VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, 2n), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(A.quad(M), z), VS.bdr(Nat.add(X0, 2n), B), VS.bdr(2n, VS.bdr(X0, B)), UW.bdr_add(X0, 2n, B))),
    zwin(2n, A.quad(M), U32.to_nat(n), VS.bdr(X0, B), hz, hb))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), U32.or(O.shl_bytes(VB.slot(TS, 0n), 2), 0)), pf, hi0)
  +eA1 = Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n, z), UW.SLW(TS), Con{VB.slot(TS, 0n), VB.wdr(1n, UW.SLW(TS))},
    UW.wdr_con(UW.SLW(TS), 0n, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s)))
  +eD1 = Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(2, z, dd, U, i, 0), VS.wtake(1n, UW.SLW(TS)), [VB.slot(TS, 0n)], eA1)
  +hz1a = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(M), z) == UW.ZB(A.quad(M)) : +List<U32>}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(2, [VB.slot(TS, 0n)], dd, U, i, 0))),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(2, [VB.slot(TS, 0n)], dd, U, i, 0))), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hz1 = FD.logic__subst(FD.array__Tree<U32>, z => {VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), UA.BYT(z))) == UW.ZB(A.quad(M)) : +List<U32>}, UW.SWo(2, [VB.slot(TS, 0n)], dd, U, i, 0), D1,
    Equal.sym(FD.array__Tree<U32>, D1, UW.SWo(2, [VB.slot(TS, 0n)], dd, U, i, 0), eD1), hz1a)
  +eC1 = UW.cry_take(2, 0n, 0n, UW.SLW(TS), 0, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s))
  +pw1 = UP2.pwor(0n, 0, 0n, Q, i, 0, dd, ds, U, TS, {==}, eq, hd, hds, h0s, FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl), pf, pfS)
  +pm = UP2.pmid_b(U32.is_eq(MID, 0), M, MID, Q, i, dd, ds, D1, TS, {==}, {==}, eq, hd, hds, hms, hmd, hz1, pf1, pfS)
  +pt = UP2.ptail_b(U32.is_eq(K, 0), KN, K, U32.add(MID, 1), 1n+M, Q, i, C2, dd, ds, D2, TS, {==}, {==}, ej, eq, hd, hds, hjs, hji, pf2, pfS)
  +pc = UP2.pcarry_b(U32.is_eq(C3, 0), dd, D3, TS, U32.add(Q, NWU), Nat.add(NW, i), C3, VB.add_at(Q, NWU, i, dd, eq, hd32, hl), hd, hl, pf3)
  +fin = FD.logic__subst(Nat, z => {UW.ORS(dd, D3, Nat.add(z, i), C3) == UW.SWc(2, VS.wtake(z, UW.SLW(TS)), dd, U, i, 0) : FD.array__Tree<U32>}, 1n+Nat.add(M, KN), NW, eNW,
    UW.asm(2, dd, U, i, UW.SLW(TS), M, KN, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(UW.SLW(TS))) == True{} : Bool}, NW, 1n+Nat.add(M, KN), Equal.sym(Nat, 1n+Nat.add(M, KN), NW, eNW),
      FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hnw))))
  %Equal.sym(Bool, U32.is_eq(n, 0), False{}, hn) : {O.put_fin(n, O.pw_empty(_, U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), 2, e3) : {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), 2, e3) : {O.put_fin(n, O.pw_un(_, n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), 0), (FD.array__thaw(U32, TS), VB.slot(TS, 0n)), VB.get_n(ds, TS, 0, 0n, {==}, hds32, h0s, pfS)) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or2_at(U32.add(MID, 1), K, Q, O.pw_mid2(MID, Q, O.pw_or2(0n, 0, Q, 0, FD.array__thaw(U32, U), _))))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_or2(0n, 0, Q, 0, FD.array__thaw(U32, U), (FD.array__thaw(U32, TS), VB.slot(TS, 0n))), (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), UW.CRY(2, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0))), pw1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or2_at(U32.add(MID, 1), K, Q, O.pw_mid2(MID, Q, _)))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, UW.CRY(2, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0), C1, eC1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or2_at(U32.add(MID, 1), K, Q, O.pw_mid2(MID, Q, (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), _)))))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_mid2_run(U32.is_eq(MID, 0), MID, Q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), C1), (FD.array__thaw(U32, D2), (FD.array__thaw(U32, TS), C2)), pm) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or2_at(U32.add(MID, 1), K, Q, _))) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_or2_run(U32.is_eq(K, 0), U32.add(MID, 1), K, Q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), C2), (FD.array__thaw(U32, D3), (FD.array__thaw(U32, TS), C3)), pt) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), _)) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & Array<U32>, O.pw_carry_skip(U32.is_eq(C3, 0), U32.add(Q, NWU), FD.array__thaw(U32, D3), FD.array__thaw(U32, TS), C3), (FD.array__thaw(U32, UW.ORSb(U32.is_eq(C3, 0), dd, D3, Nat.add(NW, i), C3)), FD.array__thaw(U32, TS)), pc) :
    {O.put_fin(n, _) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  Equal.cong(FD.array__Tree<U32>, Array<U32> & O.Words, z => (FD.array__thaw(U32, z), O.Words{FD.array__thaw(U32, TS), n}), UW.ORS(dd, D3, Nat.add(NW, i), C3), UW.SWc(2, VS.wtake(NW, UW.SLW(TS)), dd, U, i, 0), fin)

def putwud2(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 2n) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool},
    +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(i), 2n), UA.BYT(U))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  putwud2U(dd, U, pos, i, ds, TS, n, e, hn, hd, hds, hNW1, hnw, hl, VC.hyU(n, k, hk, hy), hz, pf, pfS)

# the interior words of a write at byte 3: 4 M <= n - 1
def mb3bU(+b1: Bool, +b2: Bool, +n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +eb1: {U32.is_lt(U32.add(n, 3), 4) == b1 : Bool}, +eb2: {U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)) == b2 : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pick(b1, 0, O.pick(b2, U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))))), Nat.sub(U32.to_nat(n), 1n)) == True{} : Bool}:
  match b1 b2:
    case True{} _: FD.nat__zero_le(Nat.sub(U32.to_nat(n), 1n))
    case False{} True{}:
    +ha = VB.add_nwk(n, 3, 3n, U32.to_nat(n), {==}, {==}, FD.nat__le_trans(Nat.add(3n, U32.to_nat(n)), VC.YL(n), U32.to_nat(VB.UMAX()), Order.add_right(3n, 31n, U32.to_nat(n), {==}), hy))
    +h4 = FD.nat__not_lt_le(U32.to_nat(U32.add(n, 3)), 4n, FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(U32.add(n, 3), 4), Nat.is_lt(U32.to_nat(U32.add(n, 3)), 4n), VR.lt_u32(U32.add(n, 3), 4), eb1))
    +es = FD.u32__sub_nat(U32.add(n, 3), 4, h4)
    +e4 = Equal.trans(Nat, U32.to_nat(U32.sub(U32.add(n, 3), 4)), Nat.sub(U32.to_nat(U32.add(n, 3)), 4n), Nat.sub(U32.to_nat(n), 1n), es,
      Equal.cong(Nat, Nat, z => Nat.sub(z, 4n), U32.to_nat(U32.add(n, 3)), Nat.add(3n, U32.to_nat(n)), ha))
    +hsh = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), z) == True{} : Bool}, U32.to_nat(U32.sub(U32.add(n, 3), 4)), Nat.sub(U32.to_nat(n), 1n), e4,
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), z) == True{} : Bool}, Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 3), 4), 3))), U32.to_nat(U32.sub(U32.add(n, 3), 4)),
        Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(n, 3), 4)), Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 3), 4), 3))), VC.split4(U32.sub(U32.add(n, 3), 4))),
        FD.nat__le_add_right(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 3), 4), 3)))))
      +hlt = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)), Nat.is_lt(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), VR.lt_u32(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)), eb2)
      FD.nat__le_trans(A.quad(U32.to_nat(U32.sub(VC.nwu(n), 1))), A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), Nat.sub(U32.to_nat(n), 1n),
        UW.quad_le(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)), FD.nat__lt_le(U32.to_nat(U32.sub(VC.nwu(n), 1)), U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)), hlt)), hsh)
    case False{} False{}:
    +ha = VB.add_nwk(n, 3, 3n, U32.to_nat(n), {==}, {==}, FD.nat__le_trans(Nat.add(3n, U32.to_nat(n)), VC.YL(n), U32.to_nat(VB.UMAX()), Order.add_right(3n, 31n, U32.to_nat(n), {==}), hy))
    +h4 = FD.nat__not_lt_le(U32.to_nat(U32.add(n, 3)), 4n, FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(U32.add(n, 3), 4), Nat.is_lt(U32.to_nat(U32.add(n, 3)), 4n), VR.lt_u32(U32.add(n, 3), 4), eb1))
    +es = FD.u32__sub_nat(U32.add(n, 3), 4, h4)
    +e4 = Equal.trans(Nat, U32.to_nat(U32.sub(U32.add(n, 3), 4)), Nat.sub(U32.to_nat(U32.add(n, 3)), 4n), Nat.sub(U32.to_nat(n), 1n), es,
      Equal.cong(Nat, Nat, z => Nat.sub(z, 4n), U32.to_nat(U32.add(n, 3)), Nat.add(3n, U32.to_nat(n)), ha))
    +hsh = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), z) == True{} : Bool}, U32.to_nat(U32.sub(U32.add(n, 3), 4)), Nat.sub(U32.to_nat(n), 1n), e4,
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), z) == True{} : Bool}, Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 3), 4), 3))), U32.to_nat(U32.sub(U32.add(n, 3), 4)),
        Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(n, 3), 4)), Nat.add(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 3), 4), 3))), VC.split4(U32.sub(U32.add(n, 3), 4))),
        FD.nat__le_add_right(A.quad(U32.to_nat(U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))), U32.to_nat(U32.and(U32.sub(U32.add(n, 3), 4), 3)))))
      hsh

def mb3b(+b1: Bool, +b2: Bool, +n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +eb1: {U32.is_lt(U32.add(n, 3), 4) == b1 : Bool}, +eb2: {U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)) == b2 : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pick(b1, 0, O.pick(b2, U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n))))), Nat.sub(U32.to_nat(n), 1n)) == True{} : Bool}:
  mb3bU(b1, b2, n, VC.hyU(n, k, hk, hy), eb1, eb2)

def mb3U(+n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pw_mid(n, 3, VC.nwu(n)))), Nat.sub(U32.to_nat(n), 1n)) == True{} : Bool}:
  mb3bU(U32.is_lt(U32.add(n, 3), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)), n, hy, {==}, {==})

def mb3(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(A.quad(U32.to_nat(O.pw_mid(n, 3, VC.nwu(n)))), Nat.sub(U32.to_nat(n), 1n)) == True{} : Bool}:
  mb3U(n, VC.hyU(n, k, hk, hy))

# vuwp3.putwu with zeros only in the n bytes (its interior words lie in them: mb3)
def putwud3U(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 3n) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(i), 3n), UA.BYT(U))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  +SL = UW.SLW(TS)
  +NWU = VC.nwu(n)
  +NW = VC.NW(n)
  +Q = U32.shrn(pos, 2n)
  +MID = O.pw_mid(n, 3, VC.nwu(n))
  +M = U32.to_nat(O.pw_mid(n, 3, VC.nwu(n)))
  +K = U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 3, VC.nwu(n)))
  +KN = U32.to_nat(U32.sub(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 3, VC.nwu(n))))
  +C1 = O.shr_over(VB.slot(TS, 0n), 3)
  +e3 = UW.ua_3(pos, i, 3n, 3, {==}, e, {==})
  +eq = UW.ua_q(pos, i, 3n, e, {==})
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hds32 = FD.nat__lt_trans(ds, 31n, 32n, hds, {==})
  +W1 = U32.to_nat(U32.sub(VC.nwu(n), 1))
  +eW1 = FD.u32__sub_nat(VC.nwu(n), 1, hNW1)
  +hM = UW.mid_le_g(U32.is_lt(U32.add(n, 3), 4), U32.is_lt(U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n)), U32.sub(VC.nwu(n), 1), U32.shrn(U32.sub(U32.add(n, 3), 4), 2n), {==})
  +eKN = FD.u32__sub_nat(U32.sub(VC.nwu(n), 1), O.pw_mid(n, 3, VC.nwu(n)), hM)
  +eMK = Equal.trans(Nat, Nat.add(M, KN), Nat.add(M, Nat.sub(W1, M)), W1, Equal.cong(Nat, Nat, z => Nat.add(M, z), KN, Nat.sub(W1, M), eKN), FD.nat__sub_add(W1, M, hM))
  +eNW = Equal.trans(Nat, 1n+Nat.add(M, KN), 1n+W1, NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(M, KN), W1, eMK),
    Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)))
  +h1M = FD.logic__subst(Nat, z => {Nat.is_le(1n+M, z) == True{} : Bool}, 1n+W1, NW, Equal.trans(Nat, 1n+W1, 1n+Nat.sub(NW, 1n), NW, Equal.cong(Nat, Nat, z => 1n+z, W1, Nat.sub(NW, 1n), eW1), FD.nat__sub_add(NW, 1n, hNW1)), hM)
  +hms = FD.nat__lt_le_trans(M, NW, VB.pw(ds), FD.nat__succ_le_lt(M, NW, h1M), hnw)
  +hmd = FD.nat__le_trans(Nat.add(M, 1n+i), Nat.add(NW, i), VB.pw(dd),
    FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(NW, i)) == True{} : Bool}, Nat.add(1n+M, i), Nat.add(M, 1n+i), Equal.sym(Nat, Nat.add(M, 1n+i), 1n+Nat.add(M, i), FD.nat__add_succ(M, i)), Order.add_right(1n+M, NW, i, h1M)),
    FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +eKM = Equal.trans(Nat, Nat.add(KN, 1n+M), 1n+Nat.add(KN, M), NW, FD.nat__add_succ(KN, M),
    Equal.trans(Nat, 1n+Nat.add(KN, M), 1n+Nat.add(M, KN), NW, Equal.cong(Nat, Nat, z => 1n+z, Nat.add(KN, M), Nat.add(M, KN), FD.nat__add_comm(KN, M)), eNW))
  +hjs = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(ds)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), hnw)
  +hji = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, NW, Nat.add(KN, 1n+M), Equal.sym(Nat, Nat.add(KN, 1n+M), NW, eKM), FD.nat__lt_le(Nat.add(NW, i), VB.pw(dd), hl))
  +ej = VB.add_at(O.pw_mid(n, 3, VC.nwu(n)), 1, M, 1n+ds, {==}, VB.lt32s(ds, hds), VB.le_pw_lt(1n+M, ds, FD.nat__le_trans(1n+M, NW, VB.pw(ds), h1M, hnw)))
  +h0s = FD.nat__lt_le_trans(0n, NW, VB.pw(ds), FD.nat__lt_le_trans(0n, 1n, NW, {==}, hNW1), hnw)
  +hi0 = FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl)
  +D1 = UW.SWo(3, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0)
  +pf1 = UW.swo_perfect(3, VS.wtake(1n, UW.SLW(TS)), dd, U, i, 0, pf)
  +D2 = UW.SWo(3, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1)
  +C2 = UW.CRY(3, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), C1)
  +pf2 = UW.swo_perfect(3, VS.wtake(M, VB.wdr(1n, UW.SLW(TS))), dd, D1, 1n+i, C1, pf1)
  +D3 = UW.SWo(3, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2)
  +C3 = UW.CRY(3, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), C2)
  +pf3 = UW.swo_perfect(3, VS.wtake(KN, VB.wdr(1n+M, UW.SLW(TS))), dd, D2, Nat.add(1n+M, i), C2, pf2)
  +X0 = Nat.add(A.quad(i), 3n)
  +B = UA.BYT(U)
  +hb = mb3U(n, hy)
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, 1n), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, 1n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), 3n, 1n)))
  +zU = Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(1n, VS.bdr(X0, B))), UW.ZB(A.quad(M)),
    Equal.trans(+List<U32>, VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), B)), VS.bt(A.quad(M), VS.bdr(Nat.add(X0, 1n), B)), VS.bt(A.quad(M), VS.bdr(1n, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt(A.quad(M), VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, 1n), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(A.quad(M), z), VS.bdr(Nat.add(X0, 1n), B), VS.bdr(1n, VS.bdr(X0, B)), UW.bdr_add(X0, 1n, B))),
    zwin(1n, A.quad(M), U32.to_nat(n), VS.bdr(X0, B), hz, hb))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), U32.or(O.shl_bytes(VB.slot(TS, 0n), 3), 0)), pf, hi0)
  +eA1 = Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n, z), UW.SLW(TS), Con{VB.slot(TS, 0n), VB.wdr(1n, UW.SLW(TS))},
    UW.wdr_con(UW.SLW(TS), 0n, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s)))
  +eD1 = Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(3, z, dd, U, i, 0), VS.wtake(1n, UW.SLW(TS)), [VB.slot(TS, 0n)], eA1)
  +hz1a = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(M), z) == UW.ZB(A.quad(M)) : +List<U32>}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(3, [VB.slot(TS, 0n)], dd, U, i, 0))),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(UW.SWo(3, [VB.slot(TS, 0n)], dd, U, i, 0))), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hz1 = FD.logic__subst(FD.array__Tree<U32>, z => {VS.bt(A.quad(M), VS.bdr(4n+A.quad(i), UA.BYT(z))) == UW.ZB(A.quad(M)) : +List<U32>}, UW.SWo(3, [VB.slot(TS, 0n)], dd, U, i, 0), D1,
    Equal.sym(FD.array__Tree<U32>, D1, UW.SWo(3, [VB.slot(TS, 0n)], dd, U, i, 0), eD1), hz1a)
  +eC1 = UW.cry_take(3, 0n, 0n, UW.SLW(TS), 0, FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), h0s))
  +pw1 = UP3.pwor(0n, 0, 0n, Q, i, 0, dd, ds, U, TS, {==}, eq, hd, hds, h0s, FD.nat__le_lt_trans(i, Nat.add(NW, i), VB.pw(dd), Order.left_below_sum(NW, i), hl), pf, pfS)
  +pm = UP3.pmid_b(U32.is_eq(MID, 0), M, MID, Q, i, dd, ds, D1, TS, {==}, {==}, eq, hd, hds, hms, hmd, hz1, pf1, pfS)
  +pt = UP3.ptail_b(U32.is_eq(K, 0), KN, K, U32.add(MID, 1), 1n+M, Q, i, C2, dd, ds, D2, TS, {==}, {==}, ej, eq, hd, hds, hjs, hji, pf2, pfS)
  +pc = UP3.pcarry_b(U32.is_eq(C3, 0), dd, D3, TS, U32.add(Q, NWU), Nat.add(NW, i), C3, VB.add_at(Q, NWU, i, dd, eq, hd32, hl), hd, hl, pf3)
  +fin = FD.logic__subst(Nat, z => {UW.ORS(dd, D3, Nat.add(z, i), C3) == UW.SWc(3, VS.wtake(z, UW.SLW(TS)), dd, U, i, 0) : FD.array__Tree<U32>}, 1n+Nat.add(M, KN), NW, eNW,
    UW.asm(3, dd, U, i, UW.SLW(TS), M, KN, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(UW.SLW(TS))) == True{} : Bool}, NW, 1n+Nat.add(M, KN), Equal.sym(Nat, 1n+Nat.add(M, KN), NW, eNW),
      FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(ds), VB.len(UW.SLW(TS)), Equal.sym(Nat, VB.len(UW.SLW(TS)), VB.pw(ds), FD.array__slots_length(U32, ds, TS, pfS)), hnw))))
  %Equal.sym(Bool, U32.is_eq(n, 0), False{}, hn) : {O.put_fin(n, O.pw_empty(_, U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), 3, e3) : {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), U32.and(pos, 3), n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, U32.and(pos, 3), 3, e3) : {O.put_fin(n, O.pw_un(_, n, NWU, Q, FD.array__thaw(U32, U), FD.array__thaw(U32, TS))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TS), 0), (FD.array__thaw(U32, TS), VB.slot(TS, 0n)), VB.get_n(ds, TS, 0, 0n, {==}, hds32, h0s, pfS)) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or3_at(U32.add(MID, 1), K, Q, O.pw_mid3(MID, Q, O.pw_or3(0n, 0, Q, 0, FD.array__thaw(U32, U), _))))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_or3(0n, 0, Q, 0, FD.array__thaw(U32, U), (FD.array__thaw(U32, TS), VB.slot(TS, 0n))), (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), UW.CRY(3, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0))), pw1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or3_at(U32.add(MID, 1), K, Q, O.pw_mid3(MID, Q, _)))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(U32, UW.CRY(3, VS.wtake(1n, VB.wdr(0n, UW.SLW(TS))), 0), C1, eC1) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or3_at(U32.add(MID, 1), K, Q, O.pw_mid3(MID, Q, (FD.array__thaw(U32, D1), (FD.array__thaw(U32, TS), _)))))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_mid3_run(U32.is_eq(MID, 0), MID, Q, FD.array__thaw(U32, D1), FD.array__thaw(U32, TS), C1), (FD.array__thaw(U32, D2), (FD.array__thaw(U32, TS), C2)), pm) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), O.pw_or3_at(U32.add(MID, 1), K, Q, _))) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & (Array<U32> & U32), O.pw_or3_run(U32.is_eq(K, 0), U32.add(MID, 1), K, Q, FD.array__thaw(U32, D2), FD.array__thaw(U32, TS), C2), (FD.array__thaw(U32, D3), (FD.array__thaw(U32, TS), C3)), pt) :
    {O.put_fin(n, O.pw_carry(U32.add(Q, NWU), _)) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  %Equal.sym(Array<U32> & Array<U32>, O.pw_carry_skip(U32.is_eq(C3, 0), U32.add(Q, NWU), FD.array__thaw(U32, D3), FD.array__thaw(U32, TS), C3), (FD.array__thaw(U32, UW.ORSb(U32.is_eq(C3, 0), dd, D3, Nat.add(NW, i), C3)), FD.array__thaw(U32, TS)), pc) :
    {O.put_fin(n, _) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}
  Equal.cong(FD.array__Tree<U32>, Array<U32> & O.Words, z => (FD.array__thaw(U32, z), O.Words{FD.array__thaw(U32, TS), n}), UW.ORS(dd, D3, Nat.add(NW, i), C3), UW.SWc(3, VS.wtake(NW, UW.SLW(TS)), dd, U, i, 0), fin)

def putwud3(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +ds: Nat, +TS: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 3n) : Nat}, +hn: {U32.is_eq(n, 0) == False{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hNW1: {Nat.is_le(1n, VC.NW(n)) == True{} : Bool}, +hnw: {Nat.is_le(VC.NW(n), VB.pw(ds)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), i), VB.pw(dd)) == True{} : Bool},
    +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(i), 3n), UA.BYT(U))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, TS) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, U), pos, O.Words{FD.array__thaw(U32, TS), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(TS)), dd, U, i, 0)), O.Words{FD.array__thaw(U32, TS), n}) : Array<U32> & O.Words}:
  putwud3U(dd, U, pos, i, ds, TS, n, e, hn, hd, hds, hNW1, hnw, hl, VC.hyU(n, k, hk, hy), hz, pf, pfS)

# the aligned write with its partial last word OR-ed (vbenc.pw_part, the model ORW-ing the last word)
def pw_partdU(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hb: {U32.is_eq(VY.RM(n), 0) == False{} : Bool})
    -> {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(False{}, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, UW.ORW(dd, VB.mone(VY.QL(n), 0n, P, dd, D, T), Nat.add(VY.QL(n), P), VB.slot(T, VY.QL(n)))), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  +Q = VY.QL(n)
  +ekw = VY.kw_qU(n, hy, hb)
  +enw = VY.nw_qU(n, hy, hb)
  +hQ1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(VC.NW(n), 0n), 1n+Nat.add(Q, 0n), Equal.cong(Nat, Nat, z => Nat.add(z, 0n), VC.NW(n), 1n+Q, enw), hsrc)
  +hQ2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), P), 1n+Nat.add(Q, P), Equal.cong(Nat, Nat, z => Nat.add(z, P), VC.NW(n), 1n+Q, enw), hdst)
  +M1 = VB.mone(Q, 0n, P, dd, D, T)
  +pf1 = VB.mone_perfect(Q, 0n, P, dd, D, T, pfD)
  +ecp = Equal.trans(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), VY.KW(n), Q, {==}, ekw)
  +hi0 = VY.succ_le_lt(Nat.add(Q, 0n), VB.pw(dw), hQ1)
  +hiP = VY.succ_le_lt(Nat.add(Q, P), VB.pw(dd), hQ2)
  +eL = VBE.e_lastU(p, P, n, dd, eP, hy, hb, hdd, hdst)
  %Equal.sym(Array<U32> & Array<U32>, O.acopy(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)),
      (FD.array__thaw(U32, VB.mone(U32.to_nat(U32.sub(VC.nwu(n), 1)), 0n, P, dd, D, T)), FD.array__thaw(U32, T)),
      VB.acopy_ok(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw,
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 0n), VB.pw(dw)) == True{} : Bool}, Q, U32.to_nat(U32.sub(VC.nwu(n), 1)), Equal.sym(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), Q, ecp), FD.nat__lt_le(Nat.add(Q, 0n), VB.pw(dw), hi0)),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, P), VB.pw(dd)) == True{} : Bool}, Q, U32.to_nat(U32.sub(VC.nwu(n), 1)), Equal.sym(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), Q, ecp), FD.nat__lt_le(Nat.add(Q, P), VB.pw(dd), hiP)),
        pfD, pfT)) :
    {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), _) == (FD.array__thaw(U32, UW.ORW(dd, VB.mone(Q, 0n, P, dd, D, T), Nat.add(Q, P), VB.slot(T, Q))), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), Q, ecp) :
    {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), (FD.array__thaw(U32, VB.mone(_, 0n, P, dd, D, T)), FD.array__thaw(U32, T))) == (FD.array__thaw(U32, UW.ORW(dd, VB.mone(Q, 0n, P, dd, D, T), Nat.add(Q, P), VB.slot(T, Q))), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, T), U32.sub(VC.nwu(n), 1)), (FD.array__thaw(U32, T), VB.slot(T, Q)),
      VB.get_n(dw, T, U32.sub(VC.nwu(n), 1), Q, ecp, VB.lt32(dw, hdw), FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dw)) == True{} : Bool}, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q), hi0), pfT)) :
    {O.pw_al_or_w(VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, M1), _) == (FD.array__thaw(U32, UW.ORW(dd, VB.mone(Q, 0n, P, dd, D, T), Nat.add(Q, P), VB.slot(T, Q))), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  Equal.cong(Array<U32>, Array<U32> & Array<U32>, z => (z, FD.array__thaw(U32, T)), O.or_word(FD.array__thaw(U32, M1), U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), VB.slot(T, Q)),
    FD.array__thaw(U32, UW.ORW(dd, M1, Nat.add(Q, P), VB.slot(T, Q))), UW.orw_rt(dd, M1, U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), Nat.add(Q, P), VB.slot(T, Q), eL, VB.lt32(dd, hdd), hiP, pf1))

def pw_partd(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hb: {U32.is_eq(VY.RM(n), 0) == False{} : Bool})
    -> {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(False{}, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, UW.ORW(dd, VB.mone(VY.QL(n), 0n, P, dd, D, T), Nat.add(VY.QL(n), P), VB.slot(T, VY.QL(n)))), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  pw_partdU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hb)


# the aligned copy at a word boundary, its partial last word OR-ed (vuwd.pwa2 without the zero word)
def pwa2dU(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.pw_al_tail(b, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(b, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, PW0b(b, dd, D, P, T, n)), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  match b:
    case True{}: VB.acopy_ok(VC.nwu(n), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw, hsrc, hdst, pfD, pfT)
    case False{}: pw_partdU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, hy, hsrc, hdst, eb)

def pwa2d(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.pw_al_tail(b, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(b, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, PW0b(b, dd, D, P, T, n)), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  pwa2dU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, b, eb)

def pwn2dU(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool})
    -> {O.put_fin(n, O.pw_empty(z, U32.and(p, 3), n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, PW0b(U32.is_eq(VY.RM(n), 0), dd, D, P, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match z:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, ez)) :
        {(FD.array__thaw(U32, D), O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PW0b(U32.is_eq(VY.RM(_), 0), dd, D, P, T, _)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}
    case False{}:
      %Equal.sym(U32, U32.and(p, 3), 0, hp3) :
        {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), _, n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
          == (FD.array__thaw(U32, PW0b(U32.is_eq(VY.RM(n), 0), dd, D, P, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.pw_aligned(n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)),
          (FD.array__thaw(U32, PW0b(U32.is_eq(VY.RM(n), 0), dd, D, P, T, n)), FD.array__thaw(U32, T)),
          pwa2dU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, hy, hsrc, hdst, U32.is_eq(VY.RM(n), 0), {==})) :
        {O.put_fin(n, _) == (FD.array__thaw(U32, PW0b(U32.is_eq(VY.RM(n), 0), dd, D, P, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}

# ==== O.put_words at any byte position X = 4 q + r, data-only ====================================

def pwn2d(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool})
    -> {O.put_fin(n, O.pw_empty(z, U32.and(p, 3), n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, PW0b(U32.is_eq(VY.RM(n), 0), dd, D, P, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  pwn2dU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, z, ez)

# The model: at a word boundary the aligned copy (its partial last word OR-ed), else vuw's SWc.
def PWD(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32) -> FD.array__Tree<U32>:
  match r:
    case 0n: PW0b(U32.is_eq(VY.RM(n), 0), dd, D, q, T, n)
    case 1n: UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 2n: UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 3n: UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 4n+t: D

def pw0b_perfect(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PW0b(b, dd, D, q, T, n)) == True{} : Bool}:
  match b:
    case True{}: VB.mone_perfect(VC.NW(n), 0n, q, dd, D, T, pf)
    case False{}: UW.orw_perfect(dd, VB.mone(VY.QL(n), 0n, q, dd, D, T), Nat.add(VY.QL(n), q), VB.slot(T, VY.QL(n)), VB.mone_perfect(VY.QL(n), 0n, q, dd, D, T, pf))
def pwd_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PWD(r, dd, D, q, T, n)) == True{} : Bool}:
  match r:
    case 0n: pw0b_perfect(U32.is_eq(VY.RM(n), 0), dd, D, q, T, n, pf)
    case 1n: UWD.pwm_perfect(1n, dd, D, q, T, n, pf)
    case 2n: UWD.pwm_perfect(2n, dd, D, q, T, n, pf)
    case 3n: UWD.pwm_perfect(3n, dd, D, q, T, n, pf)
    case 4n+ +t: pf

def putwd_u1UW(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      putwud1U(dd, D, X, q, dw, T, n, e, eb, hd, hdw, UW.nw_posU(n, hy, eb), hsrc, hl, hy, hz, pf, pfT)

def putwd_u1U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u1UW(b, dd, D, X, q, dw, T, n, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hy, hsrc, hl, pf, pfT, hz, eb)

def putwd_u1W(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u1UW(b, dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, eb)

def putwd_u1(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u1W(b, dd, D, X, q, dw, T, n, k, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hk, hy, hsrc, hl, pf, pfT, hz, eb)

def putwd_u2UW(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      putwud2U(dd, D, X, q, dw, T, n, e, eb, hd, hdw, UW.nw_posU(n, hy, eb), hsrc, hl, hy, hz, pf, pfT)

def putwd_u2U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u2UW(b, dd, D, X, q, dw, T, n, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hy, hsrc, hl, pf, pfT, hz, eb)

def putwd_u2W(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u2UW(b, dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, eb)

def putwd_u2(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u2W(b, dd, D, X, q, dw, T, n, k, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hk, hy, hsrc, hl, pf, pfT, hz, eb)

def putwd_u3UW(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      putwud3U(dd, D, X, q, dw, T, n, e, eb, hd, hdw, UW.nw_posU(n, hy, eb), hsrc, hl, hy, hz, pf, pfT)

def putwd_u3U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u3UW(b, dd, D, X, q, dw, T, n, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hy, hsrc, hl, pf, pfT, hz, eb)

def putwd_u3W(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u3UW(b, dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, eb)

def putwd_u3(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_u3W(b, dd, D, X, q, dw, T, n, k, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hk, hy, hsrc, hl, pf, pfT, hz, eb)

# O.put_words at X = 4 q + r is the model, when only its n bytes were zero (room for the carry word).
def putwd_anyUW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWD(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match r:
    case 0n:
      pwn2dU(dd, dw, D, T, X, q, n, pf, pfT, hd, hdw, UW.ua_3(X, q, 0n, 0, {==}, e, {==}), UW.ua_q(X, q, 0n, e, {==}), hy,
        FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), Nat.add(VC.NW(n), 0n), Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))), hsrc),
        FD.nat__lt_le(Nat.add(VC.NW(n), q), VB.pw(dd), hl), U32.is_eq(n, 0), {==})
    case 1n: putwd_u1UW(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, hl, pf, pfT, hz, {==})
    case 2n: putwd_u2UW(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, hl, pf, pfT, hz, {==})
    case 3n: putwd_u3UW(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, hl, pf, pfT, hz, {==})
    case 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWD(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))

def putwd_anyU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWD(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_anyUW(dd, D, X, q, r, dw, T, n, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hy, hsrc, hl, pf, pfT, hz)

def putwd_anyW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWD(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_anyUW(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz)

def putwd_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWD(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putwd_anyW(dd, D, X, q, r, dw, T, n, k, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hk, hy, hsrc, hl, pf, pfT, hz)

# Its bytes: the n data bytes spliced in (the bytes after them in its last words kept).
def putwd_any_bytesUW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool})
    -> {UA.BYT(PWD(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  match r:
    case 0n: bw0U(U32.is_eq(VY.RM(n), 0), dd, D, q, dw, T, n, pf, pfT, hy, hsrc, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl), htz, hz, {==})
    case 1n: bw1U(dd, D, q, dw, T, n, pf, pfT, hy, hsrc, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl), htz, hz)
    case 2n: bw2U(dd, D, q, dw, T, n, pf, pfT, hy, hsrc, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl), htz, hz)
    case 3n: bw3U(dd, D, q, dw, T, n, pf, pfT, hy, hsrc, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl), htz, hz)
    case 4n+ +t: Empty.absurd({UA.BYT(PWD(4n+t, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))

def putwd_any_bytesU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool})
    -> {UA.BYT(PWD(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  putwd_any_bytesUW(dd, D, X, q, r, dw, T, n, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hy, hsrc, hl, pf, pfT, hz, htz)

def putwd_any_bytesW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool})
    -> {UA.BYT(PWD(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  putwd_any_bytesUW(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, htz)

def putwd_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(U32.to_nat(n), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(n)) : +List<U32>},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool})
    -> {UA.BYT(PWD(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))) : +List<U32>}:
  putwd_any_bytesW(dd, D, X, q, r, dw, T, n, k, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, hk, hy, hsrc, hl, pf, pfT, hz, htz)
