import Base
import ../../src/obj.bend as O
import ../../spec/primitives.bend as SP
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ./spec_fixed.bend as FX
import ./words_spec.bend as WS
import ./words_obj_light.bend as WO
import ./mtree_run.bend as MR
import ./words_zero.bend as WZ
import ./vbuf.bend as VB
import ./vbytes.bend as VY
import ./vdepth.bend as VD
import ../../e2e/e2e_tz_generated.bend as TZ

# The storage of a represented byte list is clean (O.wcn, docs/CRASH_HUNT.md R2-02 (b)): the words of its last chunk that hold only bytes
# past the length are zero, and so is the partial word's tail. The root laws start from the plain root, which the runtime takes for such
# storage; these lemmas show that the check passes for every object `rep` represents (the invariant of words_obj.bend: a perfect tree of
# depth dw with room for the whole chunks, length 32 q + r, the bytes past it in the last chunk zero).

# The eight words of chunk q, as the specification's chunk reads them (WS.cb).
def cbl(+S: List<&2, U32>, +q: Nat) -> List<&2, U32>:
  [MR.wd(S, Nat.add(O.e8(q), 0n)), MR.wd(S, Nat.add(O.e8(q), 1n)), MR.wd(S, Nat.add(O.e8(q), 2n)), MR.wd(S, Nat.add(O.e8(q), 3n)),
   MR.wd(S, Nat.add(O.e8(q), 4n)), MR.wd(S, Nat.add(O.e8(q), 5n)), MR.wd(S, Nat.add(O.e8(q), 6n)), MR.wd(S, Nat.add(O.e8(q), 7n))]

# word k of chunk q is zero when it holds only bytes from byte r on
def zc(+S: List<&2, U32>, +q: Nat, +r: Nat, +m: Nat, +k: Nat, +hbd: {WS.bdrop(r, WS.cb(S, q)) == SP.zero_bytes(m) : +List<U32>},
    +hk: {Nat.is_le(r, A.quad(k)) == True{} : Bool}) -> {MR.wd(cbl(S, q), k) == 0 : U32}:
  WZ.zw(cbl(S, q), r, m, k, hbd, hk)

# one condition of the check: a word below byte r is not looked at, any other is zero
def hzj(+S: List<&2, U32>, +q: Nat, +r: Nat, +m: Nat, +jn: Nat, +cn: Nat, +ec: {cn == A.quad(jn) : Nat}, +x: U32,
    +ex: {x == MR.wd(cbl(S, q), jn) : U32}, +hbd: {WS.bdrop(r, WS.cb(S, q)) == SP.zero_bytes(m) : +List<U32>},
    +b: Bool, +eb: {Nat.is_lt(cn, r) == b : Bool}) -> {Bool.or(Nat.is_lt(cn, r), U32.is_eq(x, 0)) == True{} : Bool}:
  match b:
    case True{}:
      %Equal.sym(Bool, Nat.is_lt(cn, r), True{}, eb) : {Bool.or(_, U32.is_eq(x, 0)) == True{} : Bool}
      {==}
    case False{}:
      +hk = F.logic__subst(Nat, z => {Nat.is_le(r, z) == True{} : Bool}, cn, A.quad(jn), ec, F.nat__not_lt_le(cn, r, eb))
      +w0 = zc(S, q, r, m, jn, hbd, hk)
      %Equal.sym(Bool, Nat.is_lt(cn, r), False{}, eb) : {Bool.or(_, U32.is_eq(x, 0)) == True{} : Bool}
      %Equal.sym(U32, x, 0, Equal.trans(U32, x, MR.wd(cbl(S, q), jn), 0, ex, w0)) : {Bool.or(False{}, U32.is_eq(_, 0)) == True{} : Bool}
      {==}

# the check of one word of the last chunk
def lcs(+q: Nat, +jn: Nat, +cn: Nat, +rN: Nat, +dw: Nat, +t: F.array__Tree<U32>, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hk: {Nat.is_lt(Nat.add(O.e8(q), jn), F.spec_common__pow2(dw)) == True{} : Bool},
    +hz: {Bool.or(Nat.is_lt(cn, rN), U32.is_eq(MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), jn)), 0)) == True{} : Bool})
    -> {O.lc_step(rN, cn, True{}, O.lc_read(q, jn, F.array__thaw(U32, t))) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.from_nat(Nat.add(O.e8(q), jn))), (F.array__thaw(U32, t), MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), jn))),
      MR.get_at(dw, t, Nat.add(O.e8(q), jn), hd, pf, hk)) :
    {O.lc_step(rN, cn, True{}, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Bool, Bool.or(Nat.is_lt(cn, rN), U32.is_eq(MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), jn)), 0)), True{}, hz) :
    {(F.array__thaw(U32, t), Bool.and(True{}, _)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  {==}

# the eight words of the last chunk
def lcchain(+q: Nat, +r: Nat, +m: Nat, +dw: Nat, +t: F.array__Tree<U32>, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +hb: {Nat.is_lt(Nat.add(O.e8(q), 7n), F.spec_common__pow2(dw)) == True{} : Bool},
    +hbd: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), q)) == SP.zero_bytes(m) : +List<U32>})
    -> {O.lc_s0(q, r, (F.array__thaw(U32, t), True{})) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}:
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 0n, True{}, O.lc_read(q, 0n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 0n, 0n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 0n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 0n, 0n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 0n)), {==}, hbd, Nat.is_lt(0n, r), {==}))) :
    {O.lc_s1(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 4n, True{}, O.lc_read(q, 1n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 1n, 4n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 1n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 1n, 4n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 1n)), {==}, hbd, Nat.is_lt(4n, r), {==}))) :
    {O.lc_s2(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 8n, True{}, O.lc_read(q, 2n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 2n, 8n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 2n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 2n, 8n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 2n)), {==}, hbd, Nat.is_lt(8n, r), {==}))) :
    {O.lc_s3(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 12n, True{}, O.lc_read(q, 3n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 3n, 12n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 3n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 3n, 12n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 3n)), {==}, hbd, Nat.is_lt(12n, r), {==}))) :
    {O.lc_s4(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 16n, True{}, O.lc_read(q, 4n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 4n, 16n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 4n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 4n, 16n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 4n)), {==}, hbd, Nat.is_lt(16n, r), {==}))) :
    {O.lc_s5(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 20n, True{}, O.lc_read(q, 5n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 5n, 20n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 5n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 5n, 20n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 5n)), {==}, hbd, Nat.is_lt(20n, r), {==}))) :
    {O.lc_s6(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.lc_step(r, 24n, True{}, O.lc_read(q, 6n, F.array__thaw(U32, t))), (F.array__thaw(U32, t), True{}),
      lcs(q, 6n, 24n, r, dw, t, hd, pf, MR.lt_step(O.e8(q), 6n, F.spec_common__pow2(dw), {==}, hb),
        hzj(F.array__slots(U32, t), q, r, m, 6n, 24n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 6n)), {==}, hbd, Nat.is_lt(24n, r), {==}))) :
    {O.lc_s7(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  lcs(q, 7n, 28n, r, dw, t, hd, pf, hb,
    hzj(F.array__slots(U32, t), q, r, m, 7n, 28n, {==}, MR.wd(F.array__slots(U32, t), Nat.add(O.e8(q), 7n)), {==}, hbd, Nat.is_lt(28n, r), {==}))

# a read at any index (proofs/obj/arr_copy.bend: get_any)
def get_any(+d: Nat, +t: F.array__Tree<U32>, +q: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), q) == (F.array__thaw(U32, t), RD.wd(t, d, q)) : Array<U32> & U32}:
  +m = RD.masked(q, d)
  +hm = RD.mask_lt(q, d, hd)
  +x = F.flat__nthc(F.array__slots(U32, t), U32.to_nat(m))
  +hx = F.flat__nthc_nth(F.array__slots(U32, t), U32.to_nat(m), F.array__len_lt(U32, d, t, U32.to_nat(m), pf, hm))
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf)) : {Array.get.at(U32, q, _) == (F.array__thaw(U32, t), RD.wd(t, d, q)) : Array<U32> & U32}
  F.array__get_go(U32, d, t, m, x, hd, hm, hx, U32.is_lt(m, U32.shr(F.u32__pow2u(d))), {==}, pf)

# the partial word (R2-02 (b)): past the storage it is not looked at, within it its tail is zero (TZ.tz)
def ptz(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>, +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +zb: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +b: Bool, +eb: {U32.is_le(F.u32__pow2u(dw), U32.shrn(N, 2n)) == b : Bool})
    -> {O.wcn_tz(N, F.u32__pow2u(dw), Array.get(U32, F.array__thaw(U32, t), U32.shrn(N, 2n))) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}:
  match b:
    case True{}:
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.shrn(N, 2n)), (F.array__thaw(U32, t), RD.wd(t, dw, U32.shrn(N, 2n))), get_any(dw, t, U32.shrn(N, 2n), hd, pf)) :
        {O.wcn_tz(N, F.u32__pow2u(dw), _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
      %Equal.sym(Bool, U32.is_le(F.u32__pow2u(dw), U32.shrn(N, 2n)), True{}, eb) :
        {(F.array__thaw(U32, t), Bool.or(_, O.tail_zero(U32.and(N, 3), RD.wd(t, dw, U32.shrn(N, 2n))))) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
      {==}
    case False{}:
      +hlt = F.nat__not_le_lt(U32.to_nat(F.u32__pow2u(dw)), U32.to_nat(U32.shrn(N, 2n)),
        Equal.trans(Bool, Nat.is_le(U32.to_nat(F.u32__pow2u(dw)), U32.to_nat(U32.shrn(N, 2n))), U32.is_le(F.u32__pow2u(dw), U32.shrn(N, 2n)), False{},
          Equal.sym(Bool, U32.is_le(F.u32__pow2u(dw), U32.shrn(N, 2n)), Nat.is_le(U32.to_nat(F.u32__pow2u(dw)), U32.to_nat(U32.shrn(N, 2n))), VD.s_le_nat(F.u32__pow2u(dw), U32.shrn(N, 2n))), eb))
      +hi = F.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(U32.shrn(N, 2n)), z) == True{} : Bool}, U32.to_nat(F.u32__pow2u(dw)), F.spec_common__pow2(dw), F.u32__pow2u_value(dw, hd), hlt)
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.shrn(N, 2n)), (F.array__thaw(U32, t), VB.slot(t, VY.QL(N))),
          VB.get_n(dw, t, U32.shrn(N, 2n), VY.QL(N), {==}, hd, hi, pf)) :
        {O.wcn_tz(N, F.u32__pow2u(dw), _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
      %Equal.sym(Bool, U32.is_le(F.u32__pow2u(dw), U32.shrn(N, 2n)), False{}, eb) :
        {(F.array__thaw(U32, t), Bool.or(_, O.tail_zero(U32.and(N, 3), VB.slot(t, VY.QL(N))))) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
      %Equal.sym(Bool, O.tail_zero(U32.and(N, 3), VB.slot(t, VY.QL(N))), True{}, TZ.tz(t, N, q, r, enq, h1, h32, zb)) :
        {(F.array__thaw(U32, t), Bool.or(False{}, _)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
      {==}

# an object without chunks is clean whatever its storage
def canon0(+N: U32, +c: U32, -ws: Array<U32>, +e0: {O.chunks_of(N) == 0n : Nat}) -> {O.wcn_k(O.chunks_of(N), N, c, ws) == (ws, True{}) : Array<U32> & Bool}:
  %Equal.sym(Nat, O.chunks_of(N), 0n, e0) : {O.wcn_k(_, N, c, ws) == (ws, True{}) : Array<U32> & Bool}
  {==}

# the storage of a represented non-empty byte list is clean
def canon1(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>, +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool}, +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +zb: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>})
    -> {O.wcn_k(O.chunks_of(N), N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}:
  +zbq = F.logic__subst(Nat, z => {WS.bdrop(r, WS.cb(F.array__slots(U32, t), z)) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>}, Nat.add(q, 0n), q, F.nat__add_zero(q), zb)
  +hb = F.nat__lt_le_trans(Nat.add(O.e8(q), 7n), O.e8(1n+q), F.spec_common__pow2(dw), MR.e8_bound(q, 1n+q, F.nat__lt_succ(q)), room)
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) : {O.wcn_k(_, N, F.u32__pow2u(dw), F.array__thaw(U32, t)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Nat, Nat.sub(U32.to_nat(N), O.e32(q)), r, Equal.trans(Nat, Nat.sub(U32.to_nat(N), O.e32(q)), Nat.sub(Nat.add(O.e32(q), r), O.e32(q)), r,
      Equal.cong(Nat, Nat, z => Nat.sub(z, O.e32(q)), U32.to_nat(N), Nat.add(O.e32(q), r), enq), F.nat__add_sub_cancel(O.e32(q), r))) :
    {O.wcn_t(N, F.u32__pow2u(dw), q, _, F.array__thaw(U32, t)) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  %Equal.sym(Array<U32> & Bool, O.wcn_tz(N, F.u32__pow2u(dw), Array.get(U32, F.array__thaw(U32, t), U32.shrn(N, 2n))), (F.array__thaw(U32, t), True{}),
      ptz(N, q, r, dw, t, enq, h1, h32, hd, pf, zb, U32.is_le(F.u32__pow2u(dw), U32.shrn(N, 2n)), {==})) :
    {O.wcn_c(q, r, _) == (F.array__thaw(U32, t), True{}) : Array<U32> & Bool}
  lcchain(q, r, Nat.sub(32n, r), dw, t, hd, pf, hb, zbq)
