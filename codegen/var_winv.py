#!/usr/bin/env python3
"""Byte-offset window of List[Validator, 2^40] (BeaconState.validators): the
interface of proofs/obj/vua_win.bend.

    python3 codegen/var_winv.py [--check] [--no-big]

A Validator record is 121 bytes (not whole words), so record j of the window
sits at byte x + 121 j at any phase: its words are the four-byte joins
UR.RWN(t, y + c), its boolean the byte LB(t, y + 88) of the spec's bytes. The
runtime validates each record's boolean (its byte is at most 1) in a loop; the
reader fills the record array in a loop. Both loops are proved by induction on
the records left; every depth bound comes from the buffer (x + len <= 4 2^d),
never from the 2^40 limit (big_vu40 compares that one symbolically).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import var_win as W  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT = 'big_var_winx_l1099511627776_Validator.bend'
P = 'l1099511627776_Validator'
RS = 121
TRUE = 'True{} : Bool'
PW = 'A.quad(VB.pw(d))'
BUF = 'UA.BF(t, n)'
CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
      '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
      '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
# a record at y: its hypotheses
RY = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +y: Nat, +e: {U32.to_nat(off) == y : Nat},\n'
      '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},\n'
      f'    +hb: {{Nat.is_le(Nat.add(y, {RS}n), A.quad(VB.pw(d))) == True{{}} : Bool}}')
RYA = 'd, t, n, off, y, e, hd, pf, hb'

# the fields: (runtime reader prefix, byte position, size, words)
FIELDS = [('b48', 0, 48), ('b32', 48, 32), ('u64', 80, 8), ('bool', 88, 1), ('u64', 89, 8), ('u64', 97, 8), ('u64', 105, 8), ('u64', 113, 8)]


def ypos(c):
    return 'y' if c == 0 else f'{c}n+y'


def words(c, s):
    return [f'UR.RWN(t, {ypos(c + 4 * k)})' for k in range(s // 4)]


def fobj(p, c, s):
    ws = words(c, s)
    if p == 'b48':
        return 'T.Bytes48{' + ', '.join(ws) + '}'
    if p == 'b32':
        return 'T.Bytes32{' + ', '.join(ws) + '}'
    if p == 'u64':
        return 'O.U64{' + ', '.join(ws) + '}'
    return f'U32.is_eq(LB(t, {ypos(c)}), 1)'


def record_text():
    objs = [fobj(p, c, s) for p, c, s in FIELDS]
    RX = 'T.Validator{' + ', '.join(objs) + '}'
    w = []
    w.append(f'''
# ---- one record at byte y ------------------------------------------------------------------------

# The spec's byte at k.
def LB(+t: FD.array__Tree<U32>, +k: Nat) -> U32: VBL.nthb(UA.BYT(t), k)

# The runtime's byte at X is the spec's byte at to_nat X.
def vx_lb(+t: FD.array__Tree<U32>, +X: U32) -> {{VR.VX(t, X) == LB(t, U32.to_nat(X)) : U32}}:
  +hr = FD.nat__le_lt_trans(VR.RX(X), 3n, 4n, RD.and_le(X, 3), {{==}})
  %Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(VR.QX(X)), VR.RX(X)), VC.split4(X)) : {{VR.VX(t, X) == LB(t, _) : U32}}
  %Equal.sym(U32, VBL.nthb(UA.BYT(t), Nat.add(A.quad(VR.QX(X)), VR.RX(X))), VR.bsN(VR.RX(X), VB.slot(t, VR.QX(X))), VR.nth_limbs(VR.SL(t), VR.QX(X), VR.RX(X), hr)) :
    {{VR.VX(t, X) == _ : U32}}
  VR.bs_eq(U32.and(X, 3), VB.slot(t, VR.QX(X)), VR.RX(X), {{==}}, hr)

# The byte at X (X < 4 2^d).
def bat(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +X: U32, +k: Nat, +eX: {{U32.to_nat(X) == k : Nat}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},
    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +h: {{Nat.is_lt(k, {PW}) == {TRUE}}})
    -> {{B.byte_at({BUF}, X) == ({BUF}, LB(t, k)) : B.Buf & U32}}:
  +q = VR.QX(X)
  +hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {PW}) == {TRUE}}}, k, Nat.add(A.quad(q), VR.RX(X)),
    Equal.trans(Nat, k, U32.to_nat(X), Nat.add(A.quad(q), VR.RX(X)), Equal.sym(Nat, U32.to_nat(X), k, eX), VC.split4(X)), h)
  +hq = A.quad_lt(q, VB.pw(d), FD.nat__le_lt_trans(A.quad(q), Nat.add(A.quad(q), VR.RX(X)), {PW}, FD.nat__le_add_right(A.quad(q), VR.RX(X)), hk))
  %eX : {{B.byte_at({BUF}, X) == ({BUF}, LB(t, _)) : B.Buf & U32}}
  %vx_lb(t, X) : {{B.byte_at({BUF}, X) == ({BUF}, _) : B.Buf & U32}}
  VR.byte_at_ok(d, t, n, X, FD.nat__lt_trans(d, 28n, 32n, hd, {{==}}), hq, pf)
''')
    # the reader of one record
    RHS = f'({BUF}, RX(t, y)) : B.Buf & T.Validator'
    w.append(f'def RX(+t: FD.array__Tree<U32>, +y: Nat) -> T.Validator: {RX}')
    w.append('')
    w.append(f"""# off + c at c + y, inside the record.
def eoy({RY}, +c: U32, +k: Nat, +ec: {{U32.to_nat(c) == k : Nat}}, +s: Nat, +hc: {{Nat.is_le(Nat.add(k, 1n+s), {RS}n) == {TRUE}}})
    -> {{U32.to_nat(U32.add(off, c)) == Nat.add(k, y) : Nat}}:
  %ec : {{U32.to_nat(U32.add(off, c)) == Nat.add(_, y) : Nat}}
  UR.offx(d, off, c, y, e, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, y), {PW}) == {TRUE}}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec),
    FD.nat__lt_le_trans(Nat.add(k, y), Nat.add(Nat.add(k, y), 1n+s), {PW}, VTX.ltp(Nat.add(k, y), s), UR.roomf(y, {RS}n, k, 1n+s, {PW}, hb, hc))))
""")
    w.append(f'# The runtime reads the record at off (at byte y).')
    w.append(f'def rdxV({RY}) -> {{T.Validator_read({BUF}, off, {RS}) == {RHS}}}:')
    done = []
    for i, (p, c, sz) in enumerate(FIELDS):
        eo = f'eoy({RYA}, {c}, {c}n, {{==}}, {sz - 1}n, {{==}})'
        hole = f'T.Validator_rd{i}(off, {RS}, {", ".join(done + ["_"])})' if i else 'T.Validator_rd0(off, 121, _)'
        if p == 'bool':
            hole = f'T.Validator_rd{i}(off, {RS}, {", ".join(done)}, O.bool_of(_))'
            w.append(f'  %Equal.sym(B.Buf & U32, B.byte_at({BUF}, U32.add(off, {c})), ({BUF}, LB(t, {ypos(c)})), bat(d, t, n, U32.add(off, {c}), Nat.add({c}n, y), {eo}, hd, pf,')
            w.append(f'      FD.nat__lt_le_trans(Nat.add({c}n, y), Nat.add(Nat.add({c}n, y), 1n), {PW}, VTX.ltp(Nat.add({c}n, y), 0n), UR.roomf(y, {RS}n, {c}n, 1n, {PW}, hb, {{==}})))) :')
        else:
            ty = {'b48': 'T.Bytes48', 'b32': 'T.Bytes32', 'u64': 'O.U64'}[p]
            w.append(f'  %Equal.sym(B.Buf & {ty}, T.{p}_read({BUF}, U32.add(off, {c}), {sz}), ({BUF}, {fobj(p, c, sz)}),')
            w.append(f'      VTX.rdx_{p}(d, t, n, U32.add(off, {c}), Nat.add({c}n, y), {eo}, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), pf, UR.roomf(y, {RS}n, {c}n, {sz}n, {PW}, hb, {{==}}))) :')
        w.append(f'    {{{hole} == {RHS}}}')
        done.append(fobj(p, c, sz))
    w.append('  {==}')
    w.append('')
    w.append(f"""# The record's check: its boolean byte is at most 1.
def VCK(+t: FD.array__Tree<U32>, +y: Nat) -> Bool: U32.is_le(LB(t, 88n+y), 1)

def c0id(+b: Bool, +off: U32, buf: B.Buf) -> {{T.Validator_c0(b, buf, off) == (buf, b) : B.Buf & Bool}}:
  match b:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def okV({RY}) -> {{T.Validator_ok_at({BUF}, off) == ({BUF}, VCK(t, y)) : B.Buf & Bool}}:
  %Equal.sym(B.Buf & U32, B.byte_at({BUF}, U32.add(off, 88)), ({BUF}, LB(t, 88n+y)), bat(d, t, n, U32.add(off, 88), Nat.add(88n, y), eoy({RYA}, 88, 88n, {{==}}, 0n, {{==}}), hd, pf,
      FD.nat__lt_le_trans(Nat.add(88n, y), Nat.add(Nat.add(88n, y), 1n), {PW}, VTX.ltp(Nat.add(88n, y), 0n), UR.roomf(y, {RS}n, 88n, 1n, {PW}, hb, {{==}})))) :
    {{T.Validator_v0(off, O.bool_ok_pick(_)) == ({BUF}, VCK(t, y)) : B.Buf & Bool}}
  c0id(VCK(t, y), off, {BUF})
""")
    return RX, '\n'.join(w)


def POS(j):
    return f'VRL.pos({j}, {RS}n, x)'


def list_check_text():
    TR = 'FD.array__Tree<U32>'
    HB = lambda k, j: f'+hb: {{Nat.is_le({POS(f"Nat.add(1n+{k}, {j})")}, {PW}) == {TRUE}}}'
    return f"""
# ---- the list's checks ---------------------------------------------------------------------------

def vR() -> Word(31n): FD.spec_numeric__from_nat(31n, {RS}n)
def NN(+len: U32) -> U32: U32.div(len, {RS})
def CC(+len: U32) -> Nat: U32.to_nat(NN(len))
def KK(+len: U32) -> Nat: U32.to_nat(U32.sub(NN(len), 1))

# The records j, j + 1, .. j + k pass, after acc (left to right, as the runtime's loop).
def CKA(k: Nat, +j: Nat, +acc: Bool, +t: {TR}, +x: Nat) -> Bool:
  match k:
    case 0n: Bool.and(acc, VCK(t, {POS("j")}))
    case 1n+q: CKA(q, 1n+j, Bool.and(acc, VCK(t, {POS("j")})), t, x)

def ZCK(e: Bool, +t: {TR}, +x: Nat, +len: U32) -> Bool:
  match e:
    case True{{}}: True{{}}
    case False{{}}: CKA(KK(len), 0n, True{{}}, t, x)

def LCK(a: Bool, +t: {TR}, +x: Nat, +len: U32) -> Bool:
  match a:
    case False{{}}: False{{}}
    case True{{}}: ZCK(U32.is_eq(NN(len), 0), t, x, len)

# Whole records, and each record's boolean byte is at most 1.
def CHKw(+t: {TR}, +x: Nat, +off: U32, +len: U32) -> Bool: LCK(Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}}), t, x, len)

# The check loop from record j (index i) on.
def ckl(k: Nat, +d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +i: U32, +j: Nat, +acc: Bool,
    +eo: {{U32.to_nat(off) == x : Nat}}, +ej: {{U32.to_nat(i) == j : Nat}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},
    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, {HB("k", "j")})
    -> {{T.{P}_ck(k, i, off, acc, ({BUF}, VCK(t, {POS("j")}))) == ({BUF}, CKA(k, j, acc, t, x)) : B.Buf & Bool}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      +hb2 = FD.logic__subst(Nat, z => {{Nat.is_le({POS("1n+z")}, {PW}) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      +hx = VRL.nextfit(j, q, {RS}n, x, {PW}, hb)
      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)
      %Equal.sym(B.Buf & Bool, T.Validator_ok_at({BUF}, U32.add(off, U32.mul(U32.add(i, 1), {RS}))), ({BUF}, VCK(t, {POS("1n+j")})),
          okV(d, t, n, U32.add(off, U32.mul(U32.add(i, 1), {RS})), {POS("1n+j")}, ex, hd, pf, hx)) :
        {{T.{P}_ck(q, U32.add(i, 1), off, Bool.and(acc, VCK(t, {POS("j")})), _) == ({BUF}, CKA(1n+q, j, acc, t, x)) : B.Buf & Bool}}
      ckl(q, d, t, n, x, off, U32.add(i, 1), 1n+j, Bool.and(acc, VCK(t, {POS("j")})), eo, VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2)

# A whole window: its length is the records' (from the is_eq half of the check).
def ecw(+len: U32, +h: {{U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)) == {TRUE}}}) -> {{U32.to_nat(len) == Nat.mul(CC(len), {RS}n) : Nat}}:
  V40.whole_e(len, {RS}, vR(), {{==}}, {{==}}, {{==}}, h)

# A non-empty count is at least 1.
def cpos(+m: U32, +eb: {{U32.is_eq(m, 0) == False{{}} : Bool}}, +c: Nat, +ec: {{U32.to_nat(m) == c : Nat}}) -> {{Nat.is_le(1n, c) == {TRUE}}}:
  match c:
    case 0n: Empty.absurd({{Nat.is_le(1n, 0n) == {TRUE}}}, FD.logic__true_false(Equal.trans(Bool, True{{}}, U32.is_eq(m, 0), False{{}},
      Equal.sym(Bool, U32.is_eq(m, 0), True{{}}, FD.u32alg__eq_true(m, 0, FD.u32__injective(m, 0, ec))), eb)))
    case 1n+ +p: FD.nat__zero_le(p)

# The records fit: record c - 1 ends at x + len.
def hbw({CW}, +h: {{U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)) == {TRUE}}}, +eb: {{U32.is_eq(NN(len), 0) == False{{}} : Bool}})
    -> {{Nat.is_le({POS("Nat.add(1n+KK(len), 0n)")}, {PW}) == {TRUE}}}:
  +c = CC(len)
  +k = KK(len)
  +h1 = cpos(NN(len), eb, c, {{==}})
  +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(NN(len), 1, h1)), FD.nat__sub_add(c, 1n, h1))
  +hL = FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw)
  +hLc = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, x), {PW}) == {TRUE}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ecw(len, h), hL)
  FD.logic__subst(Nat, z => {{Nat.is_le({POS("z")}, {PW}) == {TRUE}}}, c, Nat.add(1n+k, 0n),
    Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), hLc)

def okz({CW}, +h: {{U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)) == {TRUE}}}, +e: Bool, +ee: {{U32.is_eq(NN(len), 0) == e : Bool}})
    -> {{T.{P}_ok_nz(e, {BUF}, off, NN(len)) == ({BUF}, ZCK(e, t, x, len)) : B.Buf & Bool}}:
  match e:
    case True{{}}: {{==}}
    case False{{}}:
      +hb = hbw({CWA}, h, ee)
      +hb0 = FD.nat__le_trans(Nat.add(x, {RS}n), {POS("Nat.add(1n+KK(len), 0n)")}, {PW},
        FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, {RS}n), z) == {TRUE}}}, Nat.add({RS}n, Nat.add(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x)), {POS("Nat.add(1n+KK(len), 0n)")},
          Equal.sym(Nat, {POS("Nat.add(1n+KK(len), 0n)")}, Nat.add({RS}n, Nat.add(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x)), FD.nat__add_assoc({RS}n, Nat.mul(Nat.add(KK(len), 0n), {RS}n), x)),
          FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, {RS}n), z) == {TRUE}}}, Nat.add(Nat.add(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x), {RS}n), Nat.add({RS}n, Nat.add(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x)),
            FD.nat__add_comm(Nat.add(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x), {RS}n),
            Order.add_right(x, Nat.add(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x), {RS}n, Order.left_below_sum(Nat.mul(Nat.add(KK(len), 0n), {RS}n), x)))), hb)
      %Equal.sym(B.Buf & Bool, T.Validator_ok_at({BUF}, off), ({BUF}, VCK(t, x)), okV(d, t, n, off, x, eo, hd, pf, hb0)) :
        {{T.{P}_ck(KK(len), 0, off, True{{}}, _) == ({BUF}, CKA(KK(len), 0n, True{{}}, t, x)) : B.Buf & Bool}}
      ckl(KK(len), d, t, n, x, off, 0, 0n, True{{}}, eo, {{==}}, hd, pf, hb)

def okl({CW}, +a: Bool, +ea: {{Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}}) == a : Bool}})
    -> {{T.{P}_ok_len(a, {BUF}, off, len) == ({BUF}, LCK(a, t, x, len)) : B.Buf & Bool}}:
  match a:
    case False{{}}: {{==}}
    case True{{}}: okz({CWA}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}}, ea), U32.is_eq(NN(len), 0), {{==}})

# The validator on the window returns the buffer and CHKw.
def ok_evalw({CW}) -> {{T.{P}_ok({BUF}, off, len) == ({BUF}, CHKw(t, x, off, len)) : B.Buf & Bool}}:
  okl({CWA}, Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}}), {{==}})
"""


def reader_text():
    TR = 'FD.array__Tree<U32>'
    TRR = 'FD.array__Tree<T.Validator>'
    RD = 'B.Buf & Array<T.Validator>'
    HC = f'+hchk: {{CHKw(t, x, off, len) == {TRUE}}}'
    return f"""
# ---- what the checks give ------------------------------------------------------------------------

def lck_a(+a: Bool, +t: {TR}, +x: Nat, +len: U32, +h: {{LCK(a, t, x, len) == {TRUE}}}) -> {{a == {TRUE}}}:
  match a:
    case False{{}}: h
    case True{{}}: {{==}}

def lck_z(+a: Bool, +t: {TR}, +x: Nat, +len: U32, +h: {{LCK(a, t, x, len) == {TRUE}}}) -> {{ZCK(U32.is_eq(NN(len), 0), t, x, len) == {TRUE}}}:
  match a:
    case False{{}}: Empty.absurd({{ZCK(U32.is_eq(NN(len), 0), t, x, len) == {TRUE}}}, FD.logic__false_true(h))
    case True{{}}: h

def hwh(+t: {TR}, +x: Nat, +off: U32, +len: U32, {HC}) -> {{U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)) == {TRUE}}}:
  FD.logic__and_left(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}},
    lck_a(Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}}), t, x, len, hchk))

# The count, bounded by the buffer: c <= 2^29.
def hcK({CW}, {HC}) -> {{Nat.is_le(CC(len), O.pow2n(29n)) == {TRUE}}}:
  +hl = FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {PW}, Order.left_below_sum(x, U32.to_nat(len)), hw)
  +hc = FD.nat__le_trans(CC(len), Nat.mul(CC(len), {RS}n), U32.to_nat(len), VRL.le_mul(CC(len), {RS - 1}n),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(len)) == {TRUE}}}, U32.to_nat(len), Nat.mul(CC(len), {RS}n), ecw(len, hwh(t, x, off, len, hchk)), FD.nat__le_refl(U32.to_nat(len))))
  +h2 = FD.logic__subst(Nat, z => {{Nat.is_le(CC(len), z) == {TRUE}}}, VB.pw(2n+d), O.pow2n(2n+d), VD.s_pow2_eq(2n+d), FD.nat__le_trans(CC(len), U32.to_nat(len), {PW}, hc, hl))
  FD.nat__le_trans(CC(len), O.pow2n(2n+d), O.pow2n(29n), h2, VD.s_pow2_mono(2n+d, 29n, FD.nat__lt_succ_le_succ(d, 28n, hd)))

# ---- the reader ---------------------------------------------------------------------------------

# the records j, j + 1, ..., j + k written into a record tree D
def RT(k: Nat, +j: Nat, +dd: Nat, D: {TRR}, +t: {TR}, +x: Nat) -> {TRR}:
  match k:
    case 0n: FD.array__upd(T.Validator, dd, D, j, RX(t, {POS("j")}))
    case 1n+q: RT(q, 1n+j, dd, FD.array__upd(T.Validator, dd, D, j, RX(t, {POS("j")})), t, x)

def LOBJ(e: Bool, +t: {TR}, +x: Nat, +len: U32) -> T.{P}_Seq:
  match e:
    case True{{}}: T.{P}_Seq{{T.{P}_fill(0n), 0}}
    case False{{}}: T.{P}_Seq{{FD.array__thaw(T.Validator, RT(U32.to_nat(U32.sub(NN(len), 1)), 0n, B.words_depth(NN(len)), FD.array__trep(T.Validator, B.words_depth(NN(len)), T.Validator_default()), t, x)), NN(len)}}
def OBJw(+d: Nat, +t: {TR}, +x: Nat, +off: U32, +len: U32) -> T.{P}_Seq: LOBJ(U32.is_eq(len, 0), t, x, len)

# The read loop from record j (index i) on.
def lp(k: Nat, +d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +i: U32, +j: Nat, +dd: Nat, +D: {TRR},
    +eo: {{U32.to_nat(off) == x : Nat}}, +ej: {{U32.to_nat(i) == j : Nat}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},
    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +hb: {{Nat.is_le({POS("Nat.add(1n+k, j)")}, {PW}) == {TRUE}}},
    +hdd: {{Nat.is_lt(dd, 32n) == {TRUE}}}, +hk: {{Nat.is_lt(Nat.add(k, j), VB.pw(dd)) == {TRUE}}},
    +pfD: {{FD.array__perfect(T.Validator, dd, D) == {TRUE}}})
    -> {{T.{P}_rd(k, i, off, FD.array__thaw(T.Validator, D), ({BUF}, RX(t, {POS("j")}))) == ({BUF}, FD.array__thaw(T.Validator, RT(k, j, dd, D, t, x))) : {RD}}}:
  match k:
    case 0n:
      %Equal.sym(Array<T.Validator>, Array.set(T.Validator, FD.array__thaw(T.Validator, D), i, RX(t, {POS("j")})), FD.array__thaw(T.Validator, FD.array__upd(T.Validator, dd, D, j, RX(t, {POS("j")}))),
          VRL.set_g(T.Validator, dd, D, i, j, RX(t, {POS("j")}), T.Validator_default(), ej, hdd, hk, pfD)) :
        {{({BUF}, _) == ({BUF}, FD.array__thaw(T.Validator, RT(0n, j, dd, D, t, x))) : {RD}}}
      {{==}}
    case 1n+ +q:
      +v = RX(t, {POS("j")})
      +D1 = FD.array__upd(T.Validator, dd, D, j, v)
      +hkj = FD.nat__le_lt_trans(j, Nat.add(q, j), VB.pw(dd), Order.left_below_sum(q, j), FD.nat__lt_trans(Nat.add(q, j), 1n+Nat.add(q, j), VB.pw(dd), FD.nat__lt_succ(Nat.add(q, j)), hk))
      +hk2 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(dd)) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hk)
      +hb2 = FD.logic__subst(Nat, z => {{Nat.is_le({POS("1n+z")}, {PW}) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      +hx = VRL.nextfit(j, q, {RS}n, x, {PW}, hb)
      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)
      %Equal.sym(Array<T.Validator>, Array.set(T.Validator, FD.array__thaw(T.Validator, D), i, v), FD.array__thaw(T.Validator, D1), VRL.set_g(T.Validator, dd, D, i, j, v, T.Validator_default(), ej, hdd, hkj, pfD)) :
        {{T.{P}_rd(q, U32.add(i, 1), off, _, T.Validator_read({BUF}, U32.add(off, U32.mul(U32.add(i, 1), {RS})), {RS})) == ({BUF}, FD.array__thaw(T.Validator, RT(1n+q, j, dd, D, t, x))) : {RD}}}
      %Equal.sym(B.Buf & T.Validator, T.Validator_read({BUF}, U32.add(off, U32.mul(U32.add(i, 1), {RS})), {RS}), ({BUF}, RX(t, {POS("1n+j")})),
          rdxV(d, t, n, U32.add(off, U32.mul(U32.add(i, 1), {RS})), {POS("1n+j")}, ex, hd, pf, hx)) :
        {{T.{P}_rd(q, U32.add(i, 1), off, FD.array__thaw(T.Validator, D1), _) == ({BUF}, FD.array__thaw(T.Validator, RT(1n+q, j, dd, D, t, x))) : {RD}}}
      lp(q, d, t, n, x, off, U32.add(i, 1), 1n+j, dd, D1, eo, VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2, hdd, hk2, FD.array__upd_perfect(T.Validator, dd, D, j, v, pfD))

# A non-empty window holds c >= 1 records.
def cposL(+len: U32, +c: Nat, +ec: {{U32.to_nat(len) == Nat.mul(c, {RS}n) : Nat}}, +eb: {{U32.is_eq(len, 0) == False{{}} : Bool}})
    -> {{Nat.is_le(1n, c) == {TRUE}}}:
  match c:
    case 0n: Empty.absurd({{Nat.is_le(1n, 0n) == {TRUE}}}, FD.logic__true_false(Equal.trans(Bool, True{{}}, U32.is_eq(len, 0), False{{}},
      Equal.sym(Bool, U32.is_eq(len, 0), True{{}}, FD.u32alg__eq_true(len, 0, FD.u32__injective(len, 0, ec))), eb)))
    case 1n+ +p: FD.nat__zero_le(p)

def rd_go({CW}, {HC}, +b: Bool, +eb: {{U32.is_eq(len, 0) == b : Bool}})
    -> {{T.{P}_rd_start(b, off, NN(len), {BUF}) == ({BUF}, LOBJ(b, t, x, len)) : B.Buf & T.{P}_Seq}}:
  match b:
    case True{{}}: {{==}}
    case False{{}}:
      +c = CC(len)
      +ec = ecw(len, hwh(t, x, off, len, hchk))
      +h1 = cposL(len, c, ec, eb)
      +k = U32.to_nat(U32.sub(NN(len), 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(NN(len), 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hL = FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw)
      +hLc = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, x), {PW}) == {TRUE}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hL)
      +hb = FD.logic__subst(Nat, z => {{Nat.is_le({POS("z")}, {PW}) == {TRUE}}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), hLc)
      +hck = hcK({CWA}, hchk)
      +hcp = VD.wd_cover(NN(len), 29n, {{==}}, hck)
      +hcP = FD.logic__subst(Nat, z => {{Nat.is_le(c, z) == {TRUE}}}, O.pow2n(B.words_depth(NN(len))), VB.pw(B.words_depth(NN(len))), Equal.sym(Nat, VB.pw(B.words_depth(NN(len))), O.pow2n(B.words_depth(NN(len))), VD.s_pow2_eq(B.words_depth(NN(len)))), hcp)
      +hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(B.words_depth(NN(len)))) == {TRUE}}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(B.words_depth(NN(len))), FD.logic__subst(Nat, z => {{Nat.is_lt(k, z) == {TRUE}}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hcP))
      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), 29n, 32n, VD.wd_min(NN(len), 29n, hck), {{==}})
      +hb0 = FD.nat__le_trans(Nat.add(x, {RS}n), Nat.add(x, U32.to_nat(len)), {PW},
        Order.add_left(x, {RS}n, U32.to_nat(len), FD.logic__subst(Nat, z => {{Nat.is_le({RS}n, z) == {TRUE}}}, Nat.mul(c, {RS}n), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.mul(c, {RS}n), ec),
          FD.logic__subst(Nat, z => {{Nat.is_le({RS}n, Nat.mul(z, {RS}n)) == {TRUE}}}, 1n+k, c, e1, Order.below_sum({RS}n, Nat.mul(k, {RS}n))))), hw)
      +cap = B.words_depth(NN(len))
      %Equal.sym(B.Buf & T.Validator, T.Validator_read({BUF}, off, {RS}), ({BUF}, RX(t, x)), rdxV(d, t, n, off, x, eo, hd, pf, hb0)) :
        {{T.{P}_rd_fin(NN(len), T.{P}_rd(k, 0, off, T.{P}_fill(T.{P}_cap(NN(len))), _)) == ({BUF}, LOBJ(False{{}}, t, x, len)) : B.Buf & T.{P}_Seq}}
      %Equal.sym(Array<T.Validator>, Array.new(T.Validator, cap, T.Validator_default()), FD.array__thaw(T.Validator, FD.array__trep(T.Validator, cap, T.Validator_default())), FD.array__new(T.Validator, cap, T.Validator_default())) :
        {{T.{P}_rd_fin(NN(len), T.{P}_rd(k, 0, off, _, ({BUF}, RX(t, x)))) == ({BUF}, LOBJ(False{{}}, t, x, len)) : B.Buf & T.{P}_Seq}}
      %Equal.sym({RD}, T.{P}_rd(k, 0, off, FD.array__thaw(T.Validator, FD.array__trep(T.Validator, cap, T.Validator_default())), ({BUF}, RX(t, x))),
          ({BUF}, FD.array__thaw(T.Validator, RT(k, 0n, cap, FD.array__trep(T.Validator, cap, T.Validator_default()), t, x))),
          lp(k, d, t, n, x, off, 0, 0n, cap, FD.array__trep(T.Validator, cap, T.Validator_default()), eo, {{==}}, hd, pf, hb, hdd, hk, FD.array__trep_perfect(T.Validator, cap, T.Validator_default()))) :
        {{T.{P}_rd_fin(NN(len), _) == ({BUF}, LOBJ(False{{}}, t, x, len)) : B.Buf & T.{P}_Seq}}
      {{==}}

# The reader on the window, when the checks hold.
def readw({CW}, {HC})
    -> {{T.{P}_read({BUF}, off, len) == ({BUF}, OBJw(d, t, x, off, len)) : B.Buf & T.{P}_Seq}}:
  rd_go({CWA}, hchk, U32.is_eq(len, 0), {{==}})
"""


SCHS = ['Spec.Schema8()', 'Spec.Schema7()', 'Spec.Schema3()', 'Spec.Schema0()', 'Spec.Schema3()', 'Spec.Schema3()', 'Spec.Schema3()', 'Spec.Schema3()']
LSCH = 'Spec.Schema78()'
LIMN = 'Nat.mul(U32.to_nat(1073741824), 1024n)'


def spec_text():
    TR = 'FD.array__Tree<U32>'
    MP = 'Maybe<&2, +List<S.Part>>'
    vals, parts, cats = [], [], []
    for p_, c, sz in FIELDS:
        ws = words(c, sz)
        if p_ in ('b48', 'b32'):
            vals.append(f'S.BytesValue{{F.limbs([{", ".join(ws)}])}}')
            parts.append(f'S.Fixed{{F.limbs([{", ".join(ws)}])}}')
            cats.append(f'F.bytes_part({ws[0]}, [{", ".join(ws[1:])}], {{==}})')
        elif p_ == 'u64':
            vals.append(f'S.UnsignedValue{{P.UInt{{{ws[0]}, {ws[1]}, 0, 0, 0, 0, 0, 0}}}}')
            parts.append(f'S.Fixed{{F.limbs([{ws[0]}, {ws[1]}])}}')
            cats.append(f'F.uint64_part({ws[0]}, {ws[1]})')
        else:
            vals.append(f'S.BooleanValue{{U32.is_eq(LB(t, {ypos(c)}), 1)}}')
            parts.append(f'S.Fixed{{[LB(t, {ypos(c)})]}}')
            cats.append(f'Equal.cong(+List<U32>, {MP}, z => Some{{[S.Fixed{{z}}]}}, SP.boolean_encoding(U32.is_eq(LB(t, {ypos(c)}), 1)), [LB(t, {ypos(c)})], b01(LB(t, {ypos(c)}), hc))')
    n = len(FIELDS)

    def itm(i):
        return 'S.EmptyItems{}' if i == n else f'S.Items{{{vals[i]}, {itm(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == n else f'S.Chain{{{SCHS[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == n:
            return '{==}'
        xs = parts[i][len('S.Fixed{'):-1]
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        return f'F.cat_fixed(Codec.parts({vals[i]}, {SCHS[i]}), {xs}, Codec.parts({itm(i + 1)}, {chain(i + 1)}), {rest}, {cats[i]},\n    {cat(i + 1)})'
    RPS = '[' + ', '.join(parts) + ']'
    FPR = '[]'
    for pt in reversed(parts):
        FPR = f'List.append(&2, U32, {pt[len("S.Fixed{"):-1]}, {FPR})'
    TGTF = f'Some{{[S.Fixed{{UW.WX(t, y, {RS}n)}}]}}'
    doms = []
    for p_, c, sz in FIELDS:
        if p_ == 'bool':
            doms.append((f'SP.bytes_domain([LB(t, {ypos(c)})])', f'FD.logic__and_intro(U32.is_lt(LB(t, {ypos(c)}), 256), True{{}}, b256(LB(t, {ypos(c)}), hc), {{==}})'))
        else:
            ws = words(c, sz)
            doms.append((f'SP.bytes_domain(F.limbs([{", ".join(ws)}]))', f'F.domain_limbs([{", ".join(ws)}])'))
    hv = '{==}'
    for i in range(n - 1, -1, -1):
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        hv = f'FD.logic__and_intro({doms[i][0]}, Layout.bytes_valid({rest}), {doms[i][1]},\n      {hv})'
    RY2 = ('+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},\n'
           f'    +hb: {{Nat.is_le(Nat.add(y, {RS}n), {PW}) == {TRUE}}}')
    return f"""
# ---- the spec side -------------------------------------------------------------------------------

# A boolean byte (at most 1) is the encoding of `byte == 1`.
def b01g(+v: U32, +k: Nat, +ek: {{U32.to_nat(v) == k : Nat}}, +h: {{U32.is_le(v, 1) == {TRUE}}}) -> {{SP.boolean_encoding(U32.is_eq(v, 1)) == [v] : +List<U32>}}:
  match k:
    case 0n:
      %Equal.sym(U32, v, 0, FD.u32__injective(v, 0, ek)) : {{SP.boolean_encoding(U32.is_eq(_, 1)) == [_] : +List<U32>}}
      {{==}}
    case 1n:
      %Equal.sym(U32, v, 1, FD.u32__injective(v, 1, ek)) : {{SP.boolean_encoding(U32.is_eq(_, 1)) == [_] : +List<U32>}}
      {{==}}
    case 2n+ +p:
      Empty.absurd({{SP.boolean_encoding(U32.is_eq(v, 1)) == [v] : +List<U32>}},
        FD.logic__false_true(FD.logic__subst(Nat, z => {{Nat.is_le(z, 1n) == {TRUE}}}, U32.to_nat(v), 2n+p, ek, FD.logic__subst(Bool, z => {{z == {TRUE}}}, U32.is_le(v, 1), Nat.is_le(U32.to_nat(v), U32.to_nat(1)), VU.le_u32(v, 1), h))))

def b01(+v: U32, +h: {{U32.is_le(v, 1) == {TRUE}}}) -> {{SP.boolean_encoding(U32.is_eq(v, 1)) == [v] : +List<U32>}}: b01g(v, U32.to_nat(v), {{==}}, h)

def b256(+v: U32, +h: {{U32.is_le(v, 1) == {TRUE}}}) -> {{U32.is_lt(v, 256) == {TRUE}}}:
  FD.logic__subst(Bool, z => {{z == {TRUE}}}, Nat.is_lt(U32.to_nat(v), U32.to_nat(256)), U32.is_lt(v, 256), Equal.sym(Bool, U32.is_lt(v, 256), Nat.is_lt(U32.to_nat(v), U32.to_nat(256)), VR.lt_u32(v, 256)),
    FD.nat__le_lt_trans(U32.to_nat(v), 1n, 256n, FD.logic__subst(Bool, z => {{z == {TRUE}}}, U32.is_le(v, 1), Nat.is_le(U32.to_nat(v), U32.to_nat(1)), VU.le_u32(v, 1), h), {{==}}))

# A one-byte list is its first byte.
def one1(+xs: +List<U32>, +e: {{List.length(&2, U32, xs) == 1n : Nat}}) -> {{xs == [VBL.nthb(xs, 0n)] : +List<U32>}}:
  match xs:
    case Nil{{}}: Empty.absurd({{[] == [VBL.nthb([], 0n)] : +List<U32>}}, FD.logic__true_false(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 0n, 1n, e)))
    case Con{{+a, +r}}:
      match r:
        case Nil{{}}: {{==}}
        case Con{{+b, +q}}: Empty.absurd({{a <> b <> q == [a] : +List<U32>}}, FD.logic__false_true(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 1n), 2n+List.length(&2, U32, q), 1n, e)))

# The spec's one byte at k.
def wx1(+d: Nat, +t: FD.array__Tree<U32>, +k: Nat, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +h: {{Nat.is_le(Nat.add(1n, k), {PW}) == {TRUE}}})
    -> {{UW.WX(t, k, 1n) == [LB(t, k)] : +List<U32>}}:
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(1n, k), Nat.add(k, 1n), Equal.sym(Nat, Nat.add(k, 1n), Nat.add(1n, k), A.add_right(k, 1n)), h)
  +e1 = one1(UW.WX(t, k, 1n), UW.lenWX(d, t, k, 1n, pf, hl))
  +e2 = Equal.trans(U32, VBL.nthb(UW.WX(t, k, 1n), 0n), VBL.nthb(VS.bdr(k, UA.BYT(t)), 0n), VBL.nthb(UA.BYT(t), Nat.add(k, 0n)),
    VR.nth_bt(1n, VS.bdr(k, UA.BYT(t)), 0n, {{==}}), VR.nth_bdr(k, UA.BYT(t), 0n))
  %FD.nat__add_zero(k) : {{UW.WX(t, k, 1n) == [VBL.nthb(UA.BYT(t), _)] : +List<U32>}}
  Equal.trans(+List<U32>, UW.WX(t, k, 1n), [VBL.nthb(UW.WX(t, k, 1n), 0n)], [VBL.nthb(UA.BYT(t), Nat.add(k, 0n))], e1,
    Equal.cong(U32, +List<U32>, z => [z], VBL.nthb(UW.WX(t, k, 1n), 0n), VBL.nthb(UA.BYT(t), Nat.add(k, 0n)), e2))

def RVAL(+t: {TR}, +y: Nat) -> S.Value: S.Sequence{{{itm(0)}}}

# The record's bytes are the window's {RS} bytes at y.
def winR({RY2})
    -> {{List.append(&2, U32, {FPR}, []) == UW.WX(t, y, {RS}n) : +List<U32>}}:
  +hc = FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(y, {RS}n), Nat.add({RS}n, y), A.add_right(y, {RS}n), hb)
  +a = Nat.add(A.quad(22n), y)
  +b = Nat.add(1n, a)
  %Equal.sym(+List<U32>, UW.WX(t, y, Nat.add(A.quad(22n), 33n)), List.append(&2, U32, F.limbs(UR.RWS(22n, t, y)), UW.WX(t, a, 33n)), UW.headWX(d, t, y, 22n, 33n, pf, hb)) :
    {{List.append(&2, U32, {FPR}, []) == _ : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, a, Nat.add(1n, 32n)), List.append(&2, U32, UW.WX(t, a, 1n), UW.WX(t, b, 32n)), UW.splitWX(t, a, 1n, 32n)) :
    {{List.append(&2, U32, {FPR}, []) == List.append(&2, U32, F.limbs(UR.RWS(22n, t, y)), _) : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, a, 1n), [LB(t, a)], wx1(d, t, a, pf, FD.nat__le_trans(Nat.add(1n, a), Nat.add({RS}n, y), {PW}, Order.left_below_sum(32n, y), hc))) :
    {{List.append(&2, U32, {FPR}, []) == List.append(&2, U32, F.limbs(UR.RWS(22n, t, y)), List.append(&2, U32, _, UW.WX(t, b, 32n))) : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, b, Nat.add(A.quad(8n), 0n)), List.append(&2, U32, F.limbs(UR.RWS(8n, t, b)), UW.WX(t, Nat.add(A.quad(8n), b), 0n)),
      UW.headWX(d, t, b, 8n, 0n, pf, FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(32n, b), Nat.add(b, 32n), Equal.sym(Nat, Nat.add(b, 32n), Nat.add(32n, b), A.add_right(b, 32n)), hc))) :
    {{List.append(&2, U32, {FPR}, []) == List.append(&2, U32, F.limbs(UR.RWS(22n, t, y)), List.append(&2, U32, [LB(t, a)], _)) : +List<U32>}}
  {{==}}

# A valid record's spec parts: one fixed part, the window's {RS} bytes at y.
def rprt({RY2}, +hc: {{VCK(t, y) == {TRUE}}})
    -> {{Codec.parts(RVAL(t, y), Spec.Schema58()) == {TGTF} : {MP}}}:
  %Equal.sym({MP}, Codec.parts({itm(0)}, {chain(0)}), Some{{{RPS}}},
      {cat(0)}) :
    {{Codec.aggregate(_, Some{{{RS}n}}) == {TGTF} : {MP}}}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding({RPS}), Some{{List.append(&2, U32, {FPR}, [])}},
      VMV.enc_gen({RPS}, {RS}n, {FPR}, [], {{==}}, {{==}}, {{==}},
      {hv}, {{==}})) :
    {{Codec.one(_, Some{{{RS}n}}) == {TGTF} : {MP}}}
  %Equal.sym(+List<U32>, List.append(&2, U32, {FPR}, []), UW.WX(t, y, {RS}n), winR(d, t, y, pf, hb)) : {{Codec.one(Some{{_}}, Some{{{RS}n}}) == {TGTF} : {MP}}}
  {{==}}
"""


def list_spec_text():
    TR = 'FD.array__Tree<U32>'
    MP = 'Maybe<&2, +List<S.Part>>'
    HC = f'+hchk: {{CHKw(t, x, off, len) == {TRUE}}}'
    HBJ = lambda c, j: f'+hb: {{Nat.is_le({POS(f"Nat.add({c}, {j})")}, {PW}) == {TRUE}}}'
    DTX = f'+d: Nat, +t: {TR}, +x: Nat, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}'
    V = lambda j: f'VCK(t, {POS(j)})'
    return f"""
# ---- the list's spec side -------------------------------------------------------------------------

# The records j .. j + c - 1 are valid.
def ALLV(c: Nat, +j: Nat, +t: {TR}, +x: Nat) -> Bool:
  match c:
    case 0n: True{{}}
    case 1n+q: Bool.and({V("j")}, ALLV(q, 1n+j, t, x))

def cka_acc(k: Nat, +j: Nat, +acc: Bool, +t: {TR}, +x: Nat, +h: {{CKA(k, j, acc, t, x) == {TRUE}}}) -> {{acc == {TRUE}}}:
  match k:
    case 0n: FD.logic__and_left(acc, {V("j")}, h)
    case 1n+ +q: FD.logic__and_left(acc, {V("j")}, cka_acc(q, 1n+j, Bool.and(acc, {V("j")}), t, x, h))

def cka_all(k: Nat, +j: Nat, +acc: Bool, +t: {TR}, +x: Nat, +h: {{CKA(k, j, acc, t, x) == {TRUE}}}) -> {{ALLV(1n+k, j, t, x) == {TRUE}}}:
  match k:
    case 0n: FD.logic__and_intro({V("j")}, True{{}}, FD.logic__and_right(acc, {V("j")}, h), {{==}})
    case 1n+ +q:
      FD.logic__and_intro({V("j")}, ALLV(1n+q, 1n+j, t, x), FD.logic__and_right(acc, {V("j")}, cka_acc(q, 1n+j, Bool.and(acc, {V("j")}), t, x, h)),
        cka_all(q, 1n+j, Bool.and(acc, {V("j")}), t, x, h))

def zck_all(+t: {TR}, +x: Nat, +len: U32, +e: Bool, +ee: {{U32.is_eq(NN(len), 0) == e : Bool}}, +h: {{ZCK(e, t, x, len) == {TRUE}}})
    -> {{ALLV(CC(len), 0n, t, x) == {TRUE}}}:
  match e:
    case True{{}}:
      %Equal.cong(U32, Nat, z => U32.to_nat(z), 0, NN(len), Equal.sym(U32, NN(len), 0, FD.u32alg__eq_of(NN(len), 0, ee))) : {{ALLV(_, 0n, t, x) == {TRUE}}}
      {{==}}
    case False{{}}:
      +c = CC(len)
      +h1 = cpos(NN(len), ee, c, {{==}})
      +e1 = Equal.trans(Nat, 1n+KK(len), 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, KK(len), Nat.sub(c, 1n), FD.u32__sub_nat(NN(len), 1, h1)), FD.nat__sub_add(c, 1n, h1))
      FD.logic__subst(Nat, z => {{ALLV(z, 0n, t, x) == {TRUE}}}, 1n+KK(len), c, e1, cka_all(KK(len), 0n, True{{}}, t, x, h))

def allv(+t: {TR}, +x: Nat, +off: U32, +len: U32, {HC}) -> {{ALLV(CC(len), 0n, t, x) == {TRUE}}}:
  zck_all(t, x, len, U32.is_eq(NN(len), 0), {{==}}, lck_z(Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), True{{}}), t, x, len, hchk))

def RITEMS(c: Nat, +j: Nat, +t: {TR}, +x: Nat) -> S.Value:
  match c:
    case 0n: S.EmptyItems{{}}
    case 1n+q: S.Items{{RVAL(t, {POS("j")}), RITEMS(q, 1n+j, t, x)}}

def RPARTS(c: Nat, +j: Nat, +t: {TR}, +x: Nat) -> +List<S.Part>:
  match c:
    case 0n: []
    case 1n+q: S.Fixed{{UW.WX(t, {POS("j")}, {RS}n)}} <> RPARTS(q, 1n+j, t, x)

def FLAT(c: Nat, +j: Nat, +t: {TR}, +x: Nat) -> +List<U32>:
  match c:
    case 0n: []
    case 1n+q: List.append(&2, U32, UW.WX(t, {POS("j")}, {RS}n), FLAT(q, 1n+j, t, x))

law cnt_items:
  for +c: Nat
  for +j: Nat
  for +t: {TR}
  for +x: Nat
  {{Codec.count(RITEMS(c, j, t, x)) == c : Nat}}
def cnt_items(c, j, t, x):
  match c:
    case 0n: {{==}}
    case 1n+ +q: FD.nat__succ_cong(Codec.count(RITEMS(q, 1n+j, t, x)), q, cnt_items(q, 1n+j, t, x))

# Record j fits when records j .. j + q do.
def fitc(+j: Nat, +q: Nat, +x: Nat, +P: Nat, +h: {{Nat.is_le({POS("Nat.add(1n+q, j)")}, P) == {TRUE}}}) -> {{Nat.is_le(Nat.add({POS("j")}, {RS}n), P) == {TRUE}}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(z, P) == {TRUE}}}, Nat.add({RS}n, {POS("j")}), Nat.add({POS("j")}, {RS}n), Equal.sym(Nat, Nat.add({POS("j")}, {RS}n), Nat.add({RS}n, {POS("j")}), A.add_right({POS("j")}, {RS}n)),
    VRL.fit0(j, {RS}n, x, P, FD.nat__le_trans({POS("1n+j")}, {POS("Nat.add(1n+q, j)")}, P,
      Order.add_right(Nat.mul(1n+j, {RS}n), Nat.mul(Nat.add(1n+q, j), {RS}n), x, VRL.mul_mono(1n+j, Nat.add(1n+q, j), {RS}n, Order.left_below_sum(q, j))), h)))

def hbs(+j: Nat, +q: Nat, +x: Nat, +P: Nat, +h: {{Nat.is_le({POS("Nat.add(1n+q, j)")}, P) == {TRUE}}}) -> {{Nat.is_le({POS("Nat.add(q, 1n+j)")}, P) == {TRUE}}}:
  FD.logic__subst(Nat, z => {{Nat.is_le({POS("z")}, P) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), h)

law prt_items:
  for c: Nat
  for +j: Nat
  for +d: Nat
  for +t: {TR}
  for +x: Nat
  for +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}
  for +hb: {{Nat.is_le({POS("Nat.add(c, j)")}, {PW}) == {TRUE}}}
  for +hv: {{ALLV(c, j, t, x) == {TRUE}}}
  {{Codec.parts(RITEMS(c, j, t, x), S.Repeat{{Spec.Schema58()}}) == Some{{RPARTS(c, j, t, x)}} : {MP}}}
def prt_items(c, j, d, t, x, pf, hb, hv):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      F.cat_fixed(Codec.parts(RVAL(t, {POS("j")}), Spec.Schema58()), UW.WX(t, {POS("j")}, {RS}n), Codec.parts(RITEMS(q, 1n+j, t, x), S.Repeat{{Spec.Schema58()}}), RPARTS(q, 1n+j, t, x),
        rprt(d, t, {POS("j")}, pf, fitc(j, q, x, {PW}, hb), FD.logic__and_left({V("j")}, ALLV(q, 1n+j, t, x), hv)),
        prt_items(q, 1n+j, d, t, x, pf, hbs(j, q, x, {PW}, hb), FD.logic__and_right({V("j")}, ALLV(q, 1n+j, t, x), hv)))

law rp_size:
  for c: Nat
  for +j: Nat
  for +d: Nat
  for +t: {TR}
  for +x: Nat
  for +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}
  for +hb: {{Nat.is_le({POS("Nat.add(c, j)")}, {PW}) == {TRUE}}}
  {{Layout.fixed_size(RPARTS(c, j, t, x)) == Nat.mul(c, {RS}n) : Nat}}
def rp_size(c, j, d, t, x, pf, hb):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      %Equal.sym(Nat, List.length(&2, U32, UW.WX(t, {POS("j")}, {RS}n)), {RS}n, UW.lenWX(d, t, {POS("j")}, {RS}n, pf, fitc(j, q, x, {PW}, hb))) :
        {{Nat.add(_, Layout.fixed_size(RPARTS(q, 1n+j, t, x))) == Nat.mul(1n+q, {RS}n) : Nat}}
      Equal.cong(Nat, Nat, z => Nat.add({RS}n, z), Layout.fixed_size(RPARTS(q, 1n+j, t, x)), Nat.mul(q, {RS}n), rp_size(q, 1n+j, d, t, x, pf, hbs(j, q, x, {PW}, hb)))

law rp_fp:
  for c: Nat
  for +j: Nat
  for +t: {TR}
  for +x: Nat
  for +o: Nat
  {{Layout.fixed_parts(RPARTS(c, j, t, x), o) == FLAT(c, j, t, x) : +List<U32>}}
def rp_fp(c, j, t, x, o):
  match c:
    case 0n: {{==}}
    case 1n+ +q: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, UW.WX(t, {POS("j")}, {RS}n), z), Layout.fixed_parts(RPARTS(q, 1n+j, t, x), o), FLAT(q, 1n+j, t, x), rp_fp(q, 1n+j, t, x, o))

law rp_pay:
  for c: Nat
  for +j: Nat
  for +t: {TR}
  for +x: Nat
  {{Layout.payloads(RPARTS(c, j, t, x)) == [] : +List<U32>}}
def rp_pay(c, j, t, x):
  match c:
    case 0n: {{==}}
    case 1n+ +q: rp_pay(q, 1n+j, t, x)

law rp_valid:
  for c: Nat
  for +j: Nat
  for +t: {TR}
  for +x: Nat
  {{Layout.bytes_valid(RPARTS(c, j, t, x)) == {TRUE}}}
def rp_valid(c, j, t, x):
  match c:
    case 0n: {{==}}
    case 1n+ +q: FD.logic__and_intro(SP.bytes_domain(UW.WX(t, {POS("j")}, {RS}n)), Layout.bytes_valid(RPARTS(q, 1n+j, t, x)), UW.domWX(t, {POS("j")}, {RS}n), rp_valid(q, 1n+j, t, x))

law flat_wx:
  for c: Nat
  for +j: Nat
  for +t: {TR}
  for +x: Nat
  {{FLAT(c, j, t, x) == UW.WX(t, {POS("j")}, Nat.mul(c, {RS}n)) : +List<U32>}}
def flat_wx(c, j, t, x):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      +M = Nat.mul(q, {RS}n)
      %Equal.sym(+List<U32>, UW.WX(t, {POS("j")}, Nat.add({RS}n, M)), List.append(&2, U32, UW.WX(t, {POS("j")}, {RS}n), UW.WX(t, Nat.add({RS}n, {POS("j")}), M)), UW.splitWX(t, {POS("j")}, {RS}n, M)) :
        {{FLAT(1n+q, j, t, x) == _ : +List<U32>}}
      %FD.nat__add_assoc({RS}n, Nat.mul(j, {RS}n), x) : {{FLAT(1n+q, j, t, x) == List.append(&2, U32, UW.WX(t, {POS("j")}, {RS}n), UW.WX(t, _, M)) : +List<U32>}}
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, UW.WX(t, {POS("j")}, {RS}n), z), FLAT(q, 1n+j, t, x), UW.WX(t, {POS("1n+j")}, M), flat_wx(q, 1n+j, t, x))

def VALw(+t: {TR}, +x: Nat, +len: U32) -> S.Value: S.Sequence{{RITEMS(CC(len), 0n, t, x)}}

# The spec parts of the value: one variable part, the window's bytes.
def specw({CW}, {HC})
    -> {{Codec.parts(VALw(t, x, len), {LSCH}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}:
  +c = CC(len)
  +ec = ecw(len, hwh(t, x, off, len, hchk))
  +M = Nat.mul(c, {RS}n)
  +hL = FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw)
  +hLc = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, x), {PW}) == {TRUE}}}, U32.to_nat(len), M, ec, hL)
  +hb = FD.logic__subst(Nat, z => {{Nat.is_le({POS("z")}, {PW}) == {TRUE}}}, c, Nat.add(c, 0n), Equal.sym(Nat, Nat.add(c, 0n), c, FD.nat__add_zero(c)), hLc)
  +fit = FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, U32.to_nat(len), Nat.add(M, 0n), Equal.trans(Nat, U32.to_nat(len), M, Nat.add(M, 0n), ec, Equal.sym(Nat, Nat.add(M, 0n), M, FD.nat__add_zero(M))),
    VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})))
  %Equal.sym(Nat, Codec.count(RITEMS(c, 0n, t, x)), c, cnt_items(c, 0n, t, x)) :
    {{Codec.require(Nat.is_le(_, {LIMN}), Codec.aggregate(Codec.parts(RITEMS(c, 0n, t, x), S.Repeat{{Spec.Schema58()}}), None{{}})) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  %Equal.sym(Bool, Nat.is_le(c, {LIMN}), True{{}}, V40.u32le40(NN(len))) :
    {{Codec.require(_, Codec.aggregate(Codec.parts(RITEMS(c, 0n, t, x), S.Repeat{{Spec.Schema58()}}), None{{}})) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  %Equal.sym({MP}, Codec.parts(RITEMS(c, 0n, t, x), S.Repeat{{Spec.Schema58()}}), Some{{RPARTS(c, 0n, t, x)}}, prt_items(c, 0n, d, t, x, pf, hb, allv(t, x, off, len, hchk))) :
    {{Codec.require(True{{}}, Codec.aggregate(_, None{{}})) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(RPARTS(c, 0n, t, x)), Some{{List.append(&2, U32, FLAT(c, 0n, t, x), [])}},
      VMV.enc_gen(RPARTS(c, 0n, t, x), M, FLAT(c, 0n, t, x), [], rp_size(c, 0n, d, t, x, pf, hb), rp_fp(c, 0n, t, x, M), rp_pay(c, 0n, t, x), rp_valid(c, 0n, t, x), fit)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  %Equal.sym(+List<U32>, List.append(&2, U32, FLAT(c, 0n, t, x), []), FLAT(c, 0n, t, x), VS.app_nil(FLAT(c, 0n, t, x))) :
    {{Codec.one(Some{{_}}, None{{}}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  %Equal.sym(+List<U32>, FLAT(c, 0n, t, x), UW.WX(t, {POS("0n")}, M), flat_wx(c, 0n, t, x)) :
    {{Codec.one(Some{{_}}, None{{}}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  %ec : {{Codec.one(Some{{UW.WX(t, x, _)}}, None{{}}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : {MP}}}
  {{==}}
"""


HEAD_EXTRA = ['import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', 'import ./vua.bend as UA', 'import ../compact/reads.bend as RD',
              'import ./vrl.bend as VRL', 'import ./vmv.bend as VMV', 'import ./vmr.bend as VMR', 'import ./big_vu40.bend as V40',
              'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF']


def module_text():
    RX, rec = record_text()
    L = W.HEADX + HEAD_EXTRA + ['', '# GENERATED by codegen/var_winv.py. Do not edit.',
                                '# List[Validator, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + W.COMMONX + '\n' + rec + '\n' + list_check_text() + reader_text() + spec_text() + list_spec_text()


def main():
    out = {ROOT / 'proofs/obj' / OUT: module_text()}
    if '--no-big' in sys.argv:
        out = {}
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('validator list window is current')
        return
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
