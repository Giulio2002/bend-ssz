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


HEAD_EXTRA = ['import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', 'import ./vua.bend as UA', 'import ../compact/reads.bend as RD',
              'import ./vrl.bend as VRL', 'import ./vmr.bend as VMR', 'import ./big_vu40.bend as V40',
              'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF']


def module_text():
    RX, rec = record_text()
    L = W.HEADX + HEAD_EXTRA + ['', '# GENERATED by codegen/var_winv.py. Do not edit.',
                                '# List[Validator, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + '\n' + rec + '\n' + list_check_text() + reader_text()


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
