#!/usr/bin/env python3
"""Byte-offset windows of LISTS OF VARIABLE-SIZE ELEMENTS, for any element type with a
byte-offset window module (the interface of proofs/obj/vua_win.bend: CHKw, ok_evalw,
OBJw, readw, VALw, specw, invw), with a symbolic element count.

    python3 codegen/var_vlist.py [--check] [--no-big]

Writes
  proofs/obj/vvlb_<p>.bend   the window module of a bare ByteList[N] (an element type):
                             the reader is vua_ct.copy_in_at, the value the window's bytes;
  proofs/obj/vvl_<p>.bend    the window module of the list type p = l<M>_<e>.

The list's runtime (codegen/generate.py) checks and reads the offsets table with loops
over a Nat counter: ev (the validator: element j is the window [o_j, o_{j+1}) with
o_n = len) and rv (the reader: Array.set of each element into the storage array).
The module mirrors both loops over the buffer's words (EV, RV: the reads replaced by
UR.RWN words, the elements' checks and objects by the element module's CHKw, OBJw)
and proves each loop equal to its mirror by induction on the counter; the spec side
(VALw, specw, invw) goes through the layout of n variable parts (proofs/obj/vvl.bend).
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import var_laws as VL  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]

# (element runtime prefix, byte-list limit, spec schema of the element)
BYTELISTS = [('bl1073741824', 1073741824, 'Transaction'), ('bl32', 32, 'Schema70')]
# lists of variable-size elements: (list runtime prefix, limit, element runtime prefix, element window module,
# list schema, element schema)
# The one-part fact of an element value h (proofs/decode_facts.bend single_result), per element module.
SGL = {'bl1073741824': 'VVL.bsingle(U32.to_nat(1073741824), h)'}
VLISTS = [('l1048576_bl1073741824', 1048576, 'bl1073741824', 'big_vvlb_bl1073741824', 'Schema73', 'Schema60')]

WHX = ('+eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
       '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}')
PF = '+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}'
P4 = 'A.quad(VB.pw(d))'

HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
        'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD', 'import ./vbspec.bend as VZ', 'import ./vlist.bend as VLS',
        'import ./vbsize.bend as VBZ', 'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_win.bend as UW',
        'import ./vua_ct.bend as UCT']


def src():
    return (ROOT / 'types/fulu_obj.bend').read_text()


def bl_fname(p):
    return ROOT / f'proofs/obj/big_vvlb_{p}.bend'


def zeros_at(K):
    L = [f'def zeros_at(+du: U32, +k: Nat, +e: {{U32.to_nat(du) == k : Nat}}, +hk: {{Nat.is_le(k, {K}n) == True{{}} : Bool}})',
         '    -> {B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}:',
         '  match k:']
    for j in range(K + 1):
        L.append(f'    case {j}n:')
        L.append(f'      %Equal.sym(U32, du, {j}, FD.u32__injective(du, {j}, e)) : {{B.zeros(_) == Array.new(U32, {j}n, 0) : Array<U32>}}')
        L.append('      {==}')
    L.append(f'    case {K + 1}n+p: Empty.absurd({{B.zeros(du) == Array.new(U32, {K + 1}n+p, 0) : Array<U32>}}, FD.logic__false_true(hk))')
    return '\n'.join(L)


def bl_text(p, N, sch):
    want = [f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, U32.is_le(len, {N}))',
            f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)']
    for w in want:
        assert w in src(), w
    BF = 'UA.BF(t, n)'
    WX = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    absurd = f'Empty.absurd({{CHKw(t, x, off, len) == True{{}} : Bool}}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WX}}}], e))'
    cases = []
    for c, args in VL.VALUE_CTORS:
        pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
        if c == 'BytesValue':
            cases.append(f'    case S.BytesValue{{+xs}}: bv(d, t, x, off, len, pf, hw, xs, ByteList.domain(U32.to_nat({N}), xs), {{==}}, e)')
        else:
            cases.append(f'    case {pat}: {absurd}')
    CASES = '\n'.join(cases)
    return '\n'.join(HEAD + ['import ../../spec/byte_list.bend as ByteList', 'import ./big_vvlz.bend as VZG', '',
                             '# GENERATED by codegen/var_vlist.py. Do not edit.',
                             f'# ByteList[{N}] at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend',
                             '# (an element type of the lists of codegen/var_vlist.py). The buffer bounds its length',
                             '# (d < 28), the storage is vua_ct.copy_in_at\'s CT, the value is the window\'s bytes.', '']) + f'''
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: U32.is_le(len, {N})

def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF})
    -> {{T.{p}_ok({BF}, off, len) == ({BF}, CHKw(t, x, off, len)) : B.Buf & Bool}}:
  {{==}}

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Words:
  O.Words{{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}}


def hlen(+d: Nat, +x: Nat, +len: U32, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}})
    -> {{Nat.is_le(U32.to_nat(len), {P4}) == True{{}} : Bool}}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P4}, Order.left_below_sum(x, U32.to_nat(len)), hw)

# The reader on the window (it has no checks to rely on).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF},
    +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}})
    -> {{T.{p}_read({BF}, off, len) == ({BF}, OBJw(d, t, x, off, len)) : B.Buf & O.Words}}:
  +hL = hlen(d, x, len, hw)
  +hz = VLS.hdz29(d, len, hd, hL)
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {{==}}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {{==}}),
    FD.logic__subst(Nat, z => {{B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),
      VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len)))),
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.BytesValue{{{WX}}}

def lenw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {PF}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}})
    -> {{List.length(&2, U32, {WX}) == U32.to_nat(len) : Nat}}:
  UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)

# When the window's check holds, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF},
    +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{sch}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  +hl = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le(len, {N}), Nat.is_le(U32.to_nat(len), U32.to_nat({N})), VU.le_u32(len, {N}), hchk)
  VZ.bl_parts(U32.to_nat({N}), {WX}, UW.domWX(t, x, U32.to_nat(len)),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat({N})) == True{{}} : Bool}}, U32.to_nat(len), List.length(&2, U32, {WX}), Equal.sym(Nat, List.length(&2, U32, {WX}), U32.to_nat(len), lenw(d, t, x, len, pf, hw)), hl),
    FD.logic__subst(Nat, z => {{N.fits(4n, z) == True{{}} : Bool}}, U32.to_nat(len), List.length(&2, U32, {WX}), Equal.sym(Nat, List.length(&2, U32, {WX}), U32.to_nat(len), lenw(d, t, x, len, pf, hw)),
      VBZ.fitq(d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))))

def varpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{{S.Variable{{ys}}, Nil{{}}}}: ys
    case _: []

def var_inj(+a: +List<U32>, +b: +List<U32>, +e: {{Some{{[S.Variable{{a}}]}} == Some{{[S.Variable{{b}}]}} : {MP}}}) -> {{a == b : +List<U32>}}:
  Equal.cong(+List<S.Part>, +List<U32>, z => varpay(z), [S.Variable{{a}}], [S.Variable{{b}}], FD.logic__some_inj(+List<S.Part>, [S.Variable{{a}}], [S.Variable{{b}}], e))

def bv(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, {PF}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}},
    +xs: +List<U32>, +b: Bool, +eb: {{ByteList.domain(U32.to_nat({N}), xs) == b : Bool}},
    +e: {{Codec.one(SP.optional(b, xs), None{{}}) == Some{{[S.Variable{{{WX}}}]}} : {MP}}})
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  match b:
    case False{{}}: {absurd}
    case True{{}}:
      +ex = var_inj(xs, {WX}, e)
      +hx = FD.logic__and_right(SP.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), U32.to_nat({N})),
        FD.logic__and_left(Bool.and(SP.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), U32.to_nat({N}))), N.fits(4n, List.length(&2, U32, xs)), eb))
      +hl = FD.logic__subst(+List<U32>, z => {{Nat.is_le(List.length(&2, U32, z), U32.to_nat({N})) == True{{}} : Bool}}, xs, {WX}, ex, hx)
      +hn = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat({N})) == True{{}} : Bool}}, List.length(&2, U32, {WX}), U32.to_nat(len), lenw(d, t, x, len, pf, hw), hl)
      FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(len), U32.to_nat({N})), U32.is_le(len, {N}), Equal.sym(Bool, U32.is_le(len, {N}), Nat.is_le(U32.to_nat(len), U32.to_nat({N})), VU.le_u32(len, {N})), hn)

# Every value whose spec parts are the window's bytes passes the check.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF},
    +v: S.Value, +e: {{Codec.parts(v, Spec.{sch}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}})
    -> {{CHKw(t, x, off, len) == True{{}} : Bool}}:
  match v:
{CASES}
'''


# ByteList windows of the generic forms (types/generic_obj.bend, their schema S.ByteList{N}): (runtime prefix, limit)
GBYTELISTS = [('bl256', 256)]


def gbl_fname(p):
    return ROOT / f'proofs/obj/big_vvlb_{p}.bend'


def gbl_text(p, N):
    """bl_text over the generic runtime, the schema term S.ByteList{N} in place of a Spec name."""
    gsrc = (ROOT / 'types/generic_obj.bend').read_text()
    for w in [f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, U32.is_le(len, {N}))',
              f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)']:
        assert w in gsrc, w
    global src
    fsrc = src
    src = lambda: gsrc
    try:
        txt = bl_text(p, N, '@GSCH')
    finally:
        src = fsrc
    txt = txt.replace('Spec.@GSCH()', f'S.ByteList{{{N}n}}')
    txt = txt.replace('import ../../types/fulu_obj.bend as T', 'import ../../types/generic_obj.bend as T').replace('import ../../spec/fulu_schemas.bend as Spec', 'import ./generic_specs.bend as Spec')
    assert '@GSCH' not in txt
    return txt


def zg_text():
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../compact/found.bend as FD', '',
         '# GENERATED by codegen/var_vlist.py. Do not edit.',
         '# The runtime zero array B.zeros(du) is Array.new(U32, U32.to_nat(du), 0) for EVERY du, symbolically:',
         '# the literal-depth cases are closed by rewriting the depth before the arrays are compared (checkq',
         '# --big compares the identical trees node by node; stock Bend would evaluate them, 2^d leaves).', '']
    for j in reversed(range(27)):
        nxt = f'zg_c{j + 1}(U32.is_eq(d, {j + 1}), d, {{==}})' if j < 26 else '{==}'
        L += [f'def zg_c{j}(+b: Bool, +d: U32, +eb: {{U32.is_eq(d, {j}) == b : Bool}}) -> {{B.zeros_c{j}(b, d) == Array.new(U32, U32.to_nat(d), 0) : Array<U32>}}:',
              '  match b:', '    case True{}:',
              f'      %Equal.sym(U32, d, {j}, FD.u32alg__eq_of(d, {j}, eb)) : {{B.zeros_c{j}(True{{}}, _) == Array.new(U32, U32.to_nat(_), 0) : Array<U32>}}',
              f'      FD.logic__subst(Nat, z => {{Array.new(U32, {j}n, 0) == Array.new(U32, z, 0) : Array<U32>}}, {j}n, U32.to_nat({j}), {{==}}, {{==}})',
              f'    case False{{}}: {nxt}', '']
    L += ['law zg:', '  for +d: U32', '  {B.zeros(d) == Array.new(U32, U32.to_nat(d), 0) : Array<U32>}', 'def zg(d):', '  zg_c0(U32.is_eq(d, 0), d, {==})']
    return '\n'.join(L) + '\n'


# ---- a list of variable-size elements -------------------------------------------------------------

def T_(s, mp):
    for a in sorted(mp, key=len, reverse=True):
        s = s.replace(a, mp[a])
    return s


def vl_fname(p):
    return ROOT / f'proofs/obj/big_vvl_{p}.bend'


VL_VALID = r'''
# ---- the mirror of the validator ------------------------------------------------------------------
# W0: the first offset; NN: the element count; WJ(t, x, i): the offset of element i + 1 (at byte
# 4 (i + 1)); NX: the end of the next element (len for the last one); EV: the runtime's ev loop.

def W0(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, x)
def NN(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.shrn(W0(t, x), 2n)
def CI(+i: U32) -> U32: U32.mul(4, U32.add(i, 1))
def WJ(+t: FD.array__Tree<U32>, +x: Nat, +i: U32) -> U32: UR.RWN(t, Nat.add(U32.to_nat(CI(i)), x))

def NX(last: Bool, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +i: U32) -> U32:
  match last:
    case True{}: len
    case False{}: WJ(t, x, i)

def GD(+acc: Bool, +a: U32, +b: U32, +len: U32) -> Bool: Bool.and(acc, Bool.and(U32.is_le(a, b), U32.is_le(b, len)))

def EW(g: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +a: U32, +b: U32) -> Bool:
  match g:
    case True{}: YW.CHKw(t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a))
    case False{}: False{}

def EE(+acc: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +a: U32, +b: U32) -> Bool:
  Bool.and(acc, EW(GD(acc, a, b, len), t, x, off, a, b))

def EV(k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ok: Bool, +a: U32) -> Bool:
  match k:
    case 0n: ok
    case 1n+q: EV(q, U32.add(i, 1), m, t, x, off, len, EE(ok, t, x, off, len, a, NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))), NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))

def HC(+f: U32, +len: U32) -> Bool: Bool.and(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)))
def B1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> U32: NX(U32.is_eq(1, NN(t, x)), t, x, len, 0)

def CF(ok: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  match ok:
    case True{}: EV(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, off, len, EE(True{}, t, x, off, len, W0(t, x), B1(t, x, len)), B1(t, x, len))
    case False{}: False{}

def CZ(e: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  match e:
    case True{}: True{}
    case False{}: CF(HC(W0(t, x), len), t, x, off, len)

def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: CZ(U32.is_eq(len, 0), t, x, off, len)

# ---- facts ---------------------------------------------------------------------------------------

def hlen(+d: Nat, +x: Nat, +len: U32, @HW) -> {Nat.is_le(U32.to_nat(len), @P4) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), @P4, Order.left_below_sum(x, U32.to_nat(len)), hw)

def ule(+a: U32, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

# c + x <= 4 2^d for c <= len, and the byte offset off + c at c + x.
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, U32.to_nat(len)) == True{} : Bool}, @HW)
    -> {Nat.is_le(Nat.add(c, x), @P4) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), @P4, Order.add_right(c, U32.to_nat(len), x, hc),
    FD.logic__subst(Nat, z => {Nat.is_le(z, @P4) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

def eoc(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == True{} : Bool}, @WHX)
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw))

# The window (a + x, b - a) of an element, a <= b <= len.
def hwab(+d: Nat, +x: Nat, +len: U32, +a: U32, +b: U32, +hab: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(b), U32.to_nat(len)) == True{} : Bool}, @HW)
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(a), x), U32.to_nat(U32.sub(b, a))), @P4) == True{} : Bool}:
  +e = FD.u32__sub_nat(b, a, hab)
  %Equal.sym(Nat, U32.to_nat(U32.sub(b, a)), Nat.sub(U32.to_nat(b), U32.to_nat(a)), e) : {Nat.is_le(Nat.add(Nat.add(U32.to_nat(a), x), _), @P4) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(a), x), Nat.sub(U32.to_nat(b), U32.to_nat(a))), Nat.add(x, Nat.add(U32.to_nat(a), Nat.sub(U32.to_nat(b), U32.to_nat(a)))),
      Equal.trans(Nat, Nat.add(Nat.add(U32.to_nat(a), x), Nat.sub(U32.to_nat(b), U32.to_nat(a))), Nat.add(U32.to_nat(a), Nat.add(x, Nat.sub(U32.to_nat(b), U32.to_nat(a)))),
        Nat.add(x, Nat.add(U32.to_nat(a), Nat.sub(U32.to_nat(b), U32.to_nat(a)))),
        FD.nat__add_assoc(U32.to_nat(a), x, Nat.sub(U32.to_nat(b), U32.to_nat(a))), FD.lru_nat_algebra__add_swap(U32.to_nat(a), x, Nat.sub(U32.to_nat(b), U32.to_nat(a))))) :
    {Nat.is_le(_, @P4) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(a), Nat.sub(U32.to_nat(b), U32.to_nat(a))), U32.to_nat(b), FD.nat__sub_add(U32.to_nat(b), U32.to_nat(a), hab)) :
    {Nat.is_le(Nat.add(x, _), @P4) == True{} : Bool}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(b)), Nat.add(x, U32.to_nat(len)), @P4, Order.add_left(x, U32.to_nat(b), U32.to_nat(len), hb), hw)

# ---- the element check ---------------------------------------------------------------------------

def ew_ev(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +ok: Bool, +a: U32, +b: U32, +g: Bool, +eg: {GD(ok, a, b, len) == g : Bool})
    -> {T.@P_ew(g, @BF, off, a, b) == (@BF, EW(g, t, x, off, a, b)) : B.Buf & Bool}:
  match g:
    case False{}: {==}
    case True{}:
      +h2 = FD.logic__and_right(ok, Bool.and(U32.is_le(a, b), U32.is_le(b, len)), eg)
      +hab = ule(a, b, FD.logic__and_left(U32.is_le(a, b), U32.is_le(b, len), h2))
      +hb = ule(b, len, FD.logic__and_right(U32.is_le(a, b), U32.is_le(b, len), h2))
      YW.ok_evalw(d, t, n, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a), eoc(d, x, off, len, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), hab, hb), eo, hd, hw),
        hd, hwab(d, x, len, a, b, hab, hb, hw), pf)

def ee_ev(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +ok: Bool, +a: U32, +b: U32)
    -> {T.@P_ee(ok, off, len, a, (@BF, b)) == (@BF, (EE(ok, t, x, off, len, a, b), b)) : B.Buf & (Bool & U32)}:
  %Equal.sym(B.Buf & Bool, T.@P_ew(GD(ok, a, b, len), @BF, off, a, b), (@BF, EW(GD(ok, a, b, len), t, x, off, a, b)),
      ew_ev(d, t, n, x, off, len, eo, hd, hw, pf, ok, a, b, GD(ok, a, b, len), {==})) :
    {T.@P_eb(b, O.and_pair(ok, _)) == (@BF, (EE(ok, t, x, off, len, a, b), b)) : B.Buf & (Bool & U32)}
  {==}

# ---- the reads of the offsets table ---------------------------------------------------------------

def dm(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(A.quad(a), A.quad(b)) == True{} : Bool}:
  Order.double_monotone(Nat.double(a), Nat.double(b), Order.double_monotone(a, b, h))

# The offset of element j + 1, read when j + 2 <= m, 4 m <= len.
def nx_f(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +j: U32,
    +hj: {Nat.is_le(Nat.add(A.quad(1n+U32.to_nat(j)), 4n), U32.to_nat(len)) == True{} : Bool})
    -> {T.@P_next(False{}, @BF, off, len, j) == (@BF, WJ(t, x, j)) : B.Buf & U32}:
  +hc1 = FD.nat__le_trans(A.quad(1n+U32.to_nat(j)), Nat.add(A.quad(1n+U32.to_nat(j)), 4n), U32.to_nat(len), FD.nat__le_add_right(A.quad(1n+U32.to_nat(j)), 4n), hj)
  +ej1 = VVU.addk(j, 1, len, FD.nat__le_trans(1n+U32.to_nat(j), A.quad(1n+U32.to_nat(j)), U32.to_nat(len), A.quad_ge(1n+U32.to_nat(j)), hc1))
  +ec = Equal.trans(Nat, U32.to_nat(CI(j)), A.quad(U32.to_nat(U32.add(j, 1))), A.quad(1n+U32.to_nat(j)),
    VVU.mul4(U32.add(j, 1), len, FD.logic__subst(Nat, z => {Nat.is_le(A.quad(z), U32.to_nat(len)) == True{} : Bool}, 1n+U32.to_nat(j), U32.to_nat(U32.add(j, 1)), Equal.sym(Nat, U32.to_nat(U32.add(j, 1)), 1n+U32.to_nat(j), ej1), hc1)),
    Equal.cong(Nat, Nat, z => A.quad(z), U32.to_nat(U32.add(j, 1)), 1n+U32.to_nat(j), ej1))
  +hcl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, A.quad(1n+U32.to_nat(j)), U32.to_nat(CI(j)), Equal.sym(Nat, U32.to_nat(CI(j)), A.quad(1n+U32.to_nat(j)), ec), hc1)
  +h4 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 4n), U32.to_nat(len)) == True{} : Bool}, A.quad(1n+U32.to_nat(j)), U32.to_nat(CI(j)), Equal.sym(Nat, U32.to_nat(CI(j)), A.quad(1n+U32.to_nat(j)), ec), hj)
  UR.rwx(d, t, n, U32.add(off, CI(j)), Nat.add(U32.to_nat(CI(j)), x), eoc(d, x, off, len, CI(j), hcl, eo, hd, hw), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    FD.logic__subst(Nat, z => {Nat.is_le(z, @P4) == True{} : Bool}, Nat.add(x, Nat.add(U32.to_nat(CI(j)), 4n)), Nat.add(Nat.add(U32.to_nat(CI(j)), x), 4n),
      Equal.trans(Nat, Nat.add(x, Nat.add(U32.to_nat(CI(j)), 4n)), Nat.add(U32.to_nat(CI(j)), Nat.add(x, 4n)), Nat.add(Nat.add(U32.to_nat(CI(j)), x), 4n),
        FD.lru_nat_algebra__add_swap(x, U32.to_nat(CI(j)), 4n), Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(CI(j)), x), 4n), Nat.add(U32.to_nat(CI(j)), Nat.add(x, 4n)), FD.nat__add_assoc(U32.to_nat(CI(j)), x, 4n))),
      FD.nat__le_trans(Nat.add(x, Nat.add(U32.to_nat(CI(j)), 4n)), Nat.add(x, U32.to_nat(len)), @P4, Order.add_left(x, Nat.add(U32.to_nat(CI(j)), 4n), U32.to_nat(len), h4), hw)))

# The step's read: element i + 2 is the last one, or its offset is in the table.
def nx_s(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +i: U32, +m: U32,
    +him: {Nat.is_le(2n+U32.to_nat(i), U32.to_nat(m)) == True{} : Bool}, +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +l: Bool, +el: {U32.is_eq(U32.add(i, 2), m) == l : Bool})
    -> {T.@P_next(l, @BF, off, len, U32.add(i, 1)) == (@BF, NX(l, t, x, len, U32.add(i, 1))) : B.Buf & U32}:
  match l:
    case True{}: {==}
    case False{}:
      +e2 = VVU.addk(i, 2, m, him)
      +ne = FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(m)) == False{} : Bool}, U32.to_nat(U32.add(i, 2)), 2n+U32.to_nat(i), e2, VVU.eqf(U32.add(i, 2), m, el))
      +h3 = FD.nat__lt_succ_le_succ(2n+U32.to_nat(i), U32.to_nat(m), FD.nat__lt_or_eq(2n+U32.to_nat(i), U32.to_nat(m), him, ne))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him))
      nx_f(d, t, n, x, off, len, eo, hd, hw, pf, U32.add(i, 1),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(1n+z), 4n), U32.to_nat(len)) == True{} : Bool}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)),
          Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
          FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, Nat.add(4n, A.quad(2n+U32.to_nat(i))), Nat.add(A.quad(2n+U32.to_nat(i)), 4n),
            FD.nat__add_comm(4n, A.quad(2n+U32.to_nat(i))),
            FD.nat__le_trans(A.quad(3n+U32.to_nat(i)), A.quad(U32.to_nat(m)), U32.to_nat(len), dm(3n+U32.to_nat(i), U32.to_nat(m), h3), hq))))

def nx_0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +h1: {Nat.is_le(1n, U32.to_nat(m)) == True{} : Bool}, +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +l: Bool, +el: {U32.is_eq(1, m) == l : Bool})
    -> {T.@P_next(l, @BF, off, len, 0) == (@BF, NX(l, t, x, len, 0)) : B.Buf & U32}:
  match l:
    case True{}: {==}
    case False{}:
      +h2 = FD.nat__lt_succ_le_succ(1n, U32.to_nat(m), FD.nat__lt_or_eq(1n, U32.to_nat(m), h1, VVU.eqf(1, m, el)))
      nx_f(d, t, n, x, off, len, eo, hd, hw, pf, 0, FD.nat__le_trans(8n, A.quad(U32.to_nat(m)), U32.to_nat(len), dm(2n, U32.to_nat(m), h2), hq))

# ---- the loop --------------------------------------------------------------------------------------

# ev over the offsets table: element i + 1 onwards, with i + 1 + k = m elements in all.
def ev_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +k: Nat, +i: U32, +ok: Bool, +a: U32, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat})
    -> {T.@P_ev(k, i, m, off, len, (@BF, (ok, a))) == (@BF, EV(k, i, m, t, x, off, len, ok, a)) : B.Buf & Bool}:
  match k:
    case 0n: {==}
    case 1n+q:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n+q), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n+q), FD.nat__add_comm(2n+q, U32.to_nat(i)),
          A.le_skip(q, U32.to_nat(i))))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him))
      +inv2 = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 1n+q), Nat.add(1n+U32.to_nat(i), 1n+q), U32.to_nat(m),
        Equal.cong(Nat, Nat, z => Nat.add(z, 1n+q), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
        Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 1n+q), Nat.add(U32.to_nat(i), 2n+q), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 2n+q), 1n+Nat.add(U32.to_nat(i), 1n+q), FD.nat__add_succ(U32.to_nat(i), 1n+q)), inv))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      %Equal.sym(B.Buf & U32, T.@P_next(U32.is_eq(U32.add(i, 2), m), @BF, off, len, U32.add(i, 1)), (@BF, nb),
          nx_s(d, t, n, x, off, len, eo, hd, hw, pf, i, m, him, hq, U32.is_eq(U32.add(i, 2), m), {==})) :
        {T.@P_ev(q, U32.add(i, 1), m, off, len, T.@P_ee(ok, off, len, a, _)) == (@BF, EV(1n+q, i, m, t, x, off, len, ok, a)) : B.Buf & Bool}
      %Equal.sym(B.Buf & (Bool & U32), T.@P_ee(ok, off, len, a, (@BF, nb)), (@BF, (EE(ok, t, x, off, len, a, nb), nb)), ee_ev(d, t, n, x, off, len, eo, hd, hw, pf, ok, a, nb)) :
        {T.@P_ev(q, U32.add(i, 1), m, off, len, _) == (@BF, EV(1n+q, i, m, t, x, off, len, ok, a)) : B.Buf & Bool}
      ev_go(d, t, n, x, off, len, eo, hd, hw, pf, m, hq, q, U32.add(i, 1), EE(ok, t, x, off, len, a, nb), nb, inv2)

# ---- the validator --------------------------------------------------------------------------------

def quad_pos(+y: Nat, +h: {Nat.is_le(4n, A.quad(y)) == True{} : Bool}) -> {Nat.is_le(1n, y) == True{} : Bool}:
  match y:
    case 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, FD.logic__false_true(h))
    case 1n+p: FD.nat__zero_le(p)

def nz(+y: Nat, +h: {Nat.is_eq(y, 0n) == False{} : Bool}) -> {Nat.is_le(1n, y) == True{} : Bool}:
  match y:
    case 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, FD.logic__true_false(h))
    case 1n+p: FD.nat__zero_le(p)

def hcs_b(+f: U32, +len: U32, +hl: {Nat.is_lt(U32.to_nat(len), 4n) == True{} : Bool}, +b: Bool, +eb: {HC(f, len) == b : Bool}) -> {b == False{} : Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +hA = FD.logic__and_left(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), eb)
      +hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), eb)
      +hfl = ule(f, len, FD.logic__and_right(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
      +h4 = ule(4, f, FD.logic__and_left(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))
      Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(FD.nat__le_lt_trans(U32.to_nat(4), U32.to_nat(len), 4n, FD.nat__le_trans(U32.to_nat(4), U32.to_nat(f), U32.to_nat(len), h4, hfl), hl)))

def hcs(+f: U32, +len: U32, +hl: {Nat.is_lt(U32.to_nat(len), 4n) == True{} : Bool}) -> {HC(f, len) == False{} : Bool}:
  hcs_b(f, len, hl, HC(f, len), {==})

def okf(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +c: Bool, +ec: {HC(W0(t, x), len) == c : Bool})
    -> {T.@P_first(c, @BF, off, len, W0(t, x)) == (@BF, CF(c, t, x, off, len)) : B.Buf & Bool}:
  match c:
    case False{}: {==}
    case True{}:
      +f = W0(t, x)
      +hA = FD.logic__and_left(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), ec)
      +hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), ec)
      +e3 = VVU.eqt(U32.and(f, 3), 0, FD.logic__and_left(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
      +hfl = ule(f, len, FD.logic__and_right(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
      +h4 = ule(4, f, FD.logic__and_left(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))
      +ew = Equal.trans(Nat, U32.to_nat(f), Nat.add(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(U32.and(f, 3))), A.quad(U32.to_nat(NN(t, x))), VC.split4(f),
        Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(U32.and(f, 3))), Nat.add(A.quad(U32.to_nat(NN(t, x))), 0n), A.quad(U32.to_nat(NN(t, x))),
          Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(NN(t, x))), z), U32.to_nat(U32.and(f, 3)), 0n, e3), FD.nat__add_zero(A.quad(U32.to_nat(NN(t, x))))))
      +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew, hfl)
      +h1 = quad_pos(U32.to_nat(NN(t, x)), FD.logic__subst(Nat, z => {Nat.is_le(4n, z) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew, h4))
      +es = FD.u32__sub_nat(NN(t, x), 1, h1)
      +inv = Equal.trans(Nat, Nat.add(U32.to_nat(0), 1n+U32.to_nat(U32.sub(NN(t, x), 1))), 1n+Nat.sub(U32.to_nat(NN(t, x)), 1n), U32.to_nat(NN(t, x)),
        Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(U32.sub(NN(t, x), 1)), Nat.sub(U32.to_nat(NN(t, x)), 1n), es),
        FD.nat__sub_add(U32.to_nat(NN(t, x)), 1n, h1))
      %Equal.sym(B.Buf & U32, T.@P_next(U32.is_eq(1, NN(t, x)), @BF, off, len, 0), (@BF, B1(t, x, len)),
          nx_0(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), h1, hq, U32.is_eq(1, NN(t, x)), {==})) :
        {T.@P_ev(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), off, len, T.@P_ee(True{}, off, len, W0(t, x), _)) == (@BF, CF(True{}, t, x, off, len)) : B.Buf & Bool}
      %Equal.sym(B.Buf & (Bool & U32), T.@P_ee(True{}, off, len, W0(t, x), (@BF, B1(t, x, len))), (@BF, (EE(True{}, t, x, off, len, W0(t, x), B1(t, x, len)), B1(t, x, len))),
          ee_ev(d, t, n, x, off, len, eo, hd, hw, pf, True{}, W0(t, x), B1(t, x, len))) :
        {T.@P_ev(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), off, len, _) == (@BF, CF(True{}, t, x, off, len)) : B.Buf & Bool}
      ev_go(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), hq, U32.to_nat(U32.sub(NN(t, x), 1)), 0, EE(True{}, t, x, off, len, W0(t, x), B1(t, x, len)), B1(t, x, len), inv)

def okh(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +h1: {Nat.is_le(1n, U32.to_nat(len)) == True{} : Bool},
    +s: Bool, +es: {U32.is_lt(len, 4) == s : Bool})
    -> {T.@P_head(len, off, B.read32(@BF, off)) == (@BF, CF(HC(W0(t, x), len), t, x, off, len)) : B.Buf & Bool}:
  match s:
    case True{}:
      +hl = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(len, 4), Nat.is_lt(U32.to_nat(len), U32.to_nat(4)), FD.u32__is_lt_nat(len, 4), es)
      +hx = FD.logic__subst(Nat, z => {Nat.is_lt(z, @P4) == True{} : Bool}, x, U32.to_nat(off), Equal.sym(Nat, U32.to_nat(off), x, eo),
        FD.nat__lt_le_trans(x, Nat.add(x, U32.to_nat(len)), @P4, FD.logic__subst(Nat, z => {Nat.is_lt(x, z) == True{} : Bool}, Nat.add(U32.to_nat(len), x), Nat.add(x, U32.to_nat(len)), FD.nat__add_comm(U32.to_nat(len), x),
          FD.nat__lt_le_trans(x, Nat.add(1n, x), Nat.add(U32.to_nat(len), x), FD.nat__lt_succ(x), Order.add_right(1n, U32.to_nat(len), x, h1))), hw))
      %Equal.sym(B.Buf & U32, B.read32(@BF, off), (@BF, VVR.RN(d, t, off)), VVR.rd_near(d, t, n, off, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hx)) :
        {T.@P_head(len, off, _) == (@BF, CF(HC(W0(t, x), len), t, x, off, len)) : B.Buf & Bool}
      %Equal.sym(Bool, HC(VVR.RN(d, t, off), len), False{}, hcs(VVR.RN(d, t, off), len, hl)) :
        {T.@P_first(_, @BF, off, len, VVR.RN(d, t, off)) == (@BF, CF(HC(W0(t, x), len), t, x, off, len)) : B.Buf & Bool}
      %Equal.sym(Bool, HC(W0(t, x), len), False{}, hcs(W0(t, x), len, hl)) :
        {T.@P_first(False{}, @BF, off, len, VVR.RN(d, t, off)) == (@BF, CF(_, t, x, off, len)) : B.Buf & Bool}
      {==}
    case False{}:
      +h4 = FD.nat__not_lt_le(U32.to_nat(len), U32.to_nat(4), FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(len, 4), Nat.is_lt(U32.to_nat(len), U32.to_nat(4)), FD.u32__is_lt_nat(len, 4), es))
      %Equal.sym(B.Buf & U32, B.read32(@BF, off), (@BF, W0(t, x)), UR.rwx(d, t, n, off, x, eo, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
          FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, U32.to_nat(len)), @P4, Order.add_left(x, 4n, U32.to_nat(len), h4), hw))) :
        {T.@P_head(len, off, _) == (@BF, CF(HC(W0(t, x), len), t, x, off, len)) : B.Buf & Bool}
      okf(d, t, n, x, off, len, eo, hd, hw, pf, HC(W0(t, x), len), {==})

def okz(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +e: Bool, +ee: {U32.is_eq(len, 0) == e : Bool})
    -> {T.@P_ok_nz(e, @BF, off, len) == (@BF, CZ(e, t, x, off, len)) : B.Buf & Bool}:
  match e:
    case True{}: {==}
    case False{}: okh(d, t, n, x, off, len, eo, hd, hw, pf, nz(U32.to_nat(len), VVU.eqf(len, 0, ee)), U32.is_lt(len, 4), {==})

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF)
    -> {T.@P_ok(@BF, off, len) == (@BF, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okz(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_eq(len, 0), {==})
'''


VL_READ = r'''
# ---- the mirror of the reader -----------------------------------------------------------------------

def OBJE(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32) -> @ET:
  T.@E_bx_wrap(YW.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)))

def RV(k: Nat, +i: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, arr: Array<@ET>, v: @ET) -> Array<@ET>:
  match k:
    case 0n: Array.set(@ET, arr, i, v)
    case 1n+q: RV(q, U32.add(i, 1), m, d, t, x, off, len, Array.set(@ET, arr, i, v), OBJE(d, t, x, off, WJ(t, x, i), NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))))

def RZ(e: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@P_Seq:
  match e:
    case True{}: T.@P_Seq{T.@P_fill(0n), 0}
    case False{}: T.@P_Seq{RV(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), d, t, x, off, len, T.@P_fill(T.@P_cap(NN(t, x))), OBJE(d, t, x, off, W0(t, x), B1(t, x, len))), NN(t, x)}

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@P_Seq: RZ(U32.is_eq(len, 0), d, t, x, off, len)

# ---- what CHKw says about each element -------------------------------------------------------------

def ev_ok(k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +ok: Bool, +a: U32,
    +h: {EV(k, i, m, t, x, off, len, ok, a) == True{} : Bool}) -> {ok == True{} : Bool}:
  match k:
    case 0n: h
    case 1n+q:
      match ok:
        case True{}: {==}
        case False{}: ev_ok(q, U32.add(i, 1), m, t, x, off, len, False{}, NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)), h)

def ew_g(+g: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +a: U32, +b: U32, +h: {EW(g, t, x, off, a, b) == True{} : Bool}) -> {g == True{} : Bool}:
  match g:
    case True{}: {==}
    case False{}: h

def cf_ok(+c: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +h: {CF(c, t, x, off, len) == True{} : Bool}) -> {c == True{} : Bool}:
  match c:
    case True{}: {==}
    case False{}: h

# An element whose check passed: its window and the element module's check.
def el_ab(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +a: U32, +b: U32, +h: {EE(True{}, t, x, off, len, a, b) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  +g = ew_g(GD(True{}, a, b, len), t, x, off, a, b, h)
  ule(a, b, FD.logic__and_left(U32.is_le(a, b), U32.is_le(b, len), g))

def el_b(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +a: U32, +b: U32, +h: {EE(True{}, t, x, off, len, a, b) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(b), U32.to_nat(len)) == True{} : Bool}:
  +g = ew_g(GD(True{}, a, b, len), t, x, off, a, b, h)
  ule(b, len, FD.logic__and_right(U32.is_le(a, b), U32.is_le(b, len), g))

def el_c(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +a: U32, +b: U32, +h: {EE(True{}, t, x, off, len, a, b) == True{} : Bool})
    -> {YW.CHKw(t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {EW(z, t, x, off, a, b) == True{} : Bool}, GD(True{}, a, b, len), True{}, ew_g(GD(True{}, a, b, len), t, x, off, a, b, h), h)

# ---- the reads of the reader ---------------------------------------------------------------------------

def el_ev(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +a: U32, +b: U32,
    +h: {EE(True{}, t, x, off, len, a, b) == True{} : Bool})
    -> {T.@P_elem(off, (@BF, (a, b))) == (@BF, OBJE(d, t, x, off, a, b)) : B.Buf & @ET}:
  +hab = el_ab(t, x, off, len, a, b, h)
  +hb = el_b(t, x, off, len, a, b, h)
  %Equal.sym(B.Buf & @EO, T.@E_read(@BF, U32.add(off, a), U32.sub(b, a)), (@BF, YW.OBJw(d, t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a))),
      YW.readw(d, t, n, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a), eoc(d, x, off, len, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), hab, hb), eo, hd, hw),
        hd, hwab(d, x, len, a, b, hab, hb, hw), pf, el_c(t, x, off, len, a, b, h))) :
    {T.@E_bx_rd(_) == (@BF, OBJE(d, t, x, off, a, b)) : B.Buf & @ET}
  {==}

def wd(+x: U32) -> Word(32n):
  match x:
    case U32{+w}: w

def add11(+i: U32) -> {U32.add(U32.add(i, 1), 1) == U32.add(i, 2) : U32}:
  match i:
    case U32{+w}: Equal.cong(Word(32n), U32, v => U32{v}, Word.add(32n, Word.add(32n, w, wd(1)), wd(1)), Word.add(32n, w, Word.add(32n, wd(1), wd(1))),
      FD.u32alg__w_assoc(32n, w, wd(1), wd(1)))

# The next element's window, from the offset just read: to the next offset, or to len.
def ws_ev(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +i: U32, +m: U32,
    +him: {Nat.is_le(2n+U32.to_nat(i), U32.to_nat(m)) == True{} : Bool}, +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool}, +s: U32,
    +l: Bool, +el: {U32.is_eq(U32.add(i, 2), m) == l : Bool})
    -> {T.@P_win_last(l, off, len, U32.add(i, 1), s, @BF) == (@BF, (s, NX(l, t, x, len, U32.add(i, 1)))) : B.Buf & (U32 & U32)}:
  match l:
    case True{}: {==}
    case False{}:
      %Equal.sym(B.Buf & U32, T.@P_next(False{}, @BF, off, len, U32.add(i, 1)), (@BF, WJ(t, x, U32.add(i, 1))), nx_s(d, t, n, x, off, len, eo, hd, hw, pf, i, m, him, hq, False{}, el)) :
        {T.@P_win_end(s, _) == (@BF, (s, WJ(t, x, U32.add(i, 1)))) : B.Buf & (U32 & U32)}
      {==}

def win_ev(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +i: U32, +m: U32,
    +him: {Nat.is_le(2n+U32.to_nat(i), U32.to_nat(m)) == True{} : Bool}, +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool}, +s: U32)
    -> {T.@P_win_start(off, len, U32.add(i, 1), m, (@BF, s)) == (@BF, (s, NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))) : B.Buf & (U32 & U32)}:
  %Equal.sym(U32, U32.add(U32.add(i, 1), 1), U32.add(i, 2), add11(i)) : {T.@P_win_last(U32.is_eq(_, m), off, len, U32.add(i, 1), s, @BF) == (@BF, (s, NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))) : B.Buf & (U32 & U32)}
  ws_ev(d, t, n, x, off, len, eo, hd, hw, pf, i, m, him, hq, s, U32.is_eq(U32.add(i, 2), m), {==})

# ---- the loop -----------------------------------------------------------------------------------------

def eqfr(+a: U32, +b: U32, +h: {Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) == False{} : Bool}) -> {U32.is_eq(a, b) == False{} : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), FD.u32__u32_cmp(a, b)) : {Cmp.is_eq(_) == False{} : Bool}
  h

# rv with element i + 1 onwards still to read: i + 1 + k = m, and those elements' checks.
def rv_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +k: Nat, +i: U32, arr: Array<@ET>, v: @ET, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +hE: {EV(k, i, m, t, x, off, len, True{}, WJ(t, x, i)) == True{} : Bool})
    -> {T.@P_rv(k, i, off, len, m, arr, (@BF, v)) == (@BF, RV(k, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}:
  match k:
    case 0n: {==}
    case 1n:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n), FD.nat__add_comm(2n, U32.to_nat(i)),
          FD.nat__le_refl(2n+U32.to_nat(i))))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = ev_ok(0n, U32.add(i, 1), m, t, x, off, len, EE(True{}, t, x, off, len, WJ(t, x, i), nb), nb, hE)
      %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, CI(i))), (@BF, WJ(t, x, i)),
          nx_f(d, t, n, x, off, len, eo, hd, hw, pf, i, FD.nat__le_trans(Nat.add(A.quad(1n+U32.to_nat(i)), 4n), A.quad(U32.to_nat(m)), U32.to_nat(len),
            FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(U32.to_nat(m))) == True{} : Bool}, Nat.add(4n, A.quad(1n+U32.to_nat(i))), Nat.add(A.quad(1n+U32.to_nat(i)), 4n),
              FD.nat__add_comm(4n, A.quad(1n+U32.to_nat(i))), dm(2n+U32.to_nat(i), U32.to_nat(m), him)), hq))) :
        {T.@P_rv(0n, U32.add(i, 1), off, len, m, Array.set(@ET, arr, i, v), T.@P_elem(off, T.@P_win_start(off, len, U32.add(i, 1), m, _))) == (@BF, RV(1n, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}
      %Equal.sym(B.Buf & (U32 & U32), T.@P_win_start(off, len, U32.add(i, 1), m, (@BF, WJ(t, x, i))), (@BF, (WJ(t, x, i), nb)),
          win_ev(d, t, n, x, off, len, eo, hd, hw, pf, i, m, him, hq, WJ(t, x, i))) :
        {T.@P_rv(0n, U32.add(i, 1), off, len, m, Array.set(@ET, arr, i, v), T.@P_elem(off, _)) == (@BF, RV(1n, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}
      %Equal.sym(B.Buf & @ET, T.@P_elem(off, (@BF, (WJ(t, x, i), nb))), (@BF, OBJE(d, t, x, off, WJ(t, x, i), nb)), el_ev(d, t, n, x, off, len, eo, hd, hw, pf, WJ(t, x, i), nb, hc)) :
        {T.@P_rv(0n, U32.add(i, 1), off, len, m, Array.set(@ET, arr, i, v), _) == (@BF, RV(1n, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}
      {==}
    case 2n+q:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q), FD.nat__add_comm(3n+q, U32.to_nat(i)),
          A.le_skip(1n+q, U32.to_nat(i))))
      +hi3 = FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q), FD.nat__add_comm(3n+q, U32.to_nat(i)),
          A.le_skip(q, U32.to_nat(i))))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him))
      +e2 = VVU.addk(i, 2, m, him)
      +inv2 = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 2n+q), Nat.add(1n+U32.to_nat(i), 2n+q), U32.to_nat(m),
        Equal.cong(Nat, Nat, z => Nat.add(z, 2n+q), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
        Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 2n+q), Nat.add(U32.to_nat(i), 3n+q), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 3n+q), 1n+Nat.add(U32.to_nat(i), 2n+q), FD.nat__add_succ(U32.to_nat(i), 2n+q)), inv))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = ev_ok(1n+q, U32.add(i, 1), m, t, x, off, len, EE(True{}, t, x, off, len, WJ(t, x, i), nb), nb, hE)
      +hE1 = FD.logic__subst(Bool, z => {EV(1n+q, U32.add(i, 1), m, t, x, off, len, z, nb) == True{} : Bool}, EE(True{}, t, x, off, len, WJ(t, x, i), nb), True{}, hc, hE)
      +hne = eqfr(U32.add(i, 2), m, FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(m)) == False{} : Bool}, 2n+U32.to_nat(i), U32.to_nat(U32.add(i, 2)), Equal.sym(Nat, U32.to_nat(U32.add(i, 2)), 2n+U32.to_nat(i), e2),
        FD.nat__is_eq_lt(2n+U32.to_nat(i), U32.to_nat(m), FD.nat__succ_le_lt(2n+U32.to_nat(i), U32.to_nat(m), hi3))))
      +hE2 = FD.logic__subst(Bool, z => {EV(1n+q, U32.add(i, 1), m, t, x, off, len, True{}, NX(z, t, x, len, U32.add(i, 1))) == True{} : Bool}, U32.is_eq(U32.add(i, 2), m), False{}, hne, hE1)
      %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, CI(i))), (@BF, WJ(t, x, i)),
          nx_f(d, t, n, x, off, len, eo, hd, hw, pf, i, FD.nat__le_trans(Nat.add(A.quad(1n+U32.to_nat(i)), 4n), A.quad(U32.to_nat(m)), U32.to_nat(len),
            FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(U32.to_nat(m))) == True{} : Bool}, Nat.add(4n, A.quad(1n+U32.to_nat(i))), Nat.add(A.quad(1n+U32.to_nat(i)), 4n),
              FD.nat__add_comm(4n, A.quad(1n+U32.to_nat(i))), dm(2n+U32.to_nat(i), U32.to_nat(m), him)), hq))) :
        {T.@P_rv(1n+q, U32.add(i, 1), off, len, m, Array.set(@ET, arr, i, v), T.@P_elem(off, T.@P_win_start(off, len, U32.add(i, 1), m, _))) == (@BF, RV(2n+q, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}
      %Equal.sym(B.Buf & (U32 & U32), T.@P_win_start(off, len, U32.add(i, 1), m, (@BF, WJ(t, x, i))), (@BF, (WJ(t, x, i), nb)),
          win_ev(d, t, n, x, off, len, eo, hd, hw, pf, i, m, him, hq, WJ(t, x, i))) :
        {T.@P_rv(1n+q, U32.add(i, 1), off, len, m, Array.set(@ET, arr, i, v), T.@P_elem(off, _)) == (@BF, RV(2n+q, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}
      %Equal.sym(B.Buf & @ET, T.@P_elem(off, (@BF, (WJ(t, x, i), nb))), (@BF, OBJE(d, t, x, off, WJ(t, x, i), nb)), el_ev(d, t, n, x, off, len, eo, hd, hw, pf, WJ(t, x, i), nb, hc)) :
        {T.@P_rv(1n+q, U32.add(i, 1), off, len, m, Array.set(@ET, arr, i, v), _) == (@BF, RV(2n+q, i, m, d, t, x, off, len, arr, v)) : B.Buf & Array<@ET>}
      rv_go(d, t, n, x, off, len, eo, hd, hw, pf, m, hq, 1n+q, U32.add(i, 1), Array.set(@ET, arr, i, v), OBJE(d, t, x, off, WJ(t, x, i), nb), inv2, hE2)

# ---- the reader ---------------------------------------------------------------------------------------

def ws0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +h1: {Nat.is_le(1n, U32.to_nat(m)) == True{} : Bool}, +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool}, +s: U32,
    +l: Bool, +el: {U32.is_eq(1, m) == l : Bool})
    -> {T.@P_win_last(l, off, len, 0, s, @BF) == (@BF, (s, NX(l, t, x, len, 0))) : B.Buf & (U32 & U32)}:
  match l:
    case True{}: {==}
    case False{}:
      %Equal.sym(B.Buf & U32, T.@P_next(False{}, @BF, off, len, 0), (@BF, WJ(t, x, 0)), nx_0(d, t, n, x, off, len, eo, hd, hw, pf, m, h1, hq, False{}, el)) :
        {T.@P_win_end(s, _) == (@BF, (s, WJ(t, x, 0))) : B.Buf & (U32 & U32)}
      {==}

def he0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +l: Bool, +el: {U32.is_eq(1, NN(t, x)) == l : Bool},
    +h: {EV(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, off, len, True{}, NX(l, t, x, len, 0)) == True{} : Bool})
    -> {EV(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, off, len, True{}, WJ(t, x, 0)) == True{} : Bool}:
  match l:
    case False{}: h
    case True{}:
      +e1 = VVU.eqt(1, NN(t, x), el)
      +ek = Equal.trans(Nat, U32.to_nat(U32.sub(NN(t, x), 1)), Nat.sub(U32.to_nat(NN(t, x)), 1n), 0n,
        FD.u32__sub_nat(NN(t, x), 1, FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n, U32.to_nat(NN(t, x)), e1, {==})),
        Equal.cong(Nat, Nat, z => Nat.sub(z, 1n), U32.to_nat(NN(t, x)), 1n, Equal.sym(Nat, 1n, U32.to_nat(NN(t, x)), e1)))
      FD.logic__subst(Nat, z => {EV(z, 0, NN(t, x), t, x, off, len, True{}, WJ(t, x, 0)) == True{} : Bool}, 0n, U32.to_nat(U32.sub(NN(t, x), 1)), Equal.sym(Nat, U32.to_nat(U32.sub(NN(t, x), 1)), 0n, ek), {==})

def rdf(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +hc0: {CF(HC(W0(t, x), len), t, x, off, len) == True{} : Bool})
    -> {T.@P_rv_count(off, len, B.read32(@BF, off)) == (@BF, RZ(False{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}:
  +f = W0(t, x)
  +ec = cf_ok(HC(f, len), t, x, off, len, hc0)
  +hEV = FD.logic__subst(Bool, z => {CF(z, t, x, off, len) == True{} : Bool}, HC(f, len), True{}, ec, hc0)
  +hA = FD.logic__and_left(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), ec)
  +hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), ec)
  +e3 = VVU.eqt(U32.and(f, 3), 0, FD.logic__and_left(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
  +hfl = ule(f, len, FD.logic__and_right(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
  +h4 = ule(4, f, FD.logic__and_left(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))
  +ew = Equal.trans(Nat, U32.to_nat(f), Nat.add(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(U32.and(f, 3))), A.quad(U32.to_nat(NN(t, x))), VC.split4(f),
    Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(U32.and(f, 3))), Nat.add(A.quad(U32.to_nat(NN(t, x))), 0n), A.quad(U32.to_nat(NN(t, x))),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(NN(t, x))), z), U32.to_nat(U32.and(f, 3)), 0n, e3), FD.nat__add_zero(A.quad(U32.to_nat(NN(t, x))))))
  +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew, hfl)
  +h1 = quad_pos(U32.to_nat(NN(t, x)), FD.logic__subst(Nat, z => {Nat.is_le(4n, z) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew, h4))
  +es = FD.u32__sub_nat(NN(t, x), 1, h1)
  +inv = Equal.trans(Nat, Nat.add(U32.to_nat(0), 1n+U32.to_nat(U32.sub(NN(t, x), 1))), 1n+Nat.sub(U32.to_nat(NN(t, x)), 1n), U32.to_nat(NN(t, x)),
    Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(U32.sub(NN(t, x), 1)), Nat.sub(U32.to_nat(NN(t, x)), 1n), es),
    FD.nat__sub_add(U32.to_nat(NN(t, x)), 1n, h1))
  +h4l = FD.nat__le_trans(U32.to_nat(4), U32.to_nat(f), U32.to_nat(len), h4, hfl)
  +k0 = U32.to_nat(U32.sub(NN(t, x), 1))
  +hc1 = ev_ok(k0, 0, NN(t, x), t, x, off, len, EE(True{}, t, x, off, len, f, B1(t, x, len)), B1(t, x, len), hEV)
  +hE1 = FD.logic__subst(Bool, z => {EV(k0, 0, NN(t, x), t, x, off, len, z, B1(t, x, len)) == True{} : Bool}, EE(True{}, t, x, off, len, f, B1(t, x, len)), True{}, hc1, hEV)
  +hE0 = he0(t, x, off, len, U32.is_eq(1, NN(t, x)), {==}, hE1)
  +rd0 = UR.rwx(d, t, n, off, x, eo, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, U32.to_nat(len)), @P4, Order.add_left(x, 4n, U32.to_nat(len), h4l), hw))
  %Equal.sym(B.Buf & U32, B.read32(@BF, off), (@BF, f), rd0) : {T.@P_rv_count(off, len, _) == (@BF, RZ(False{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}
  %Equal.sym(B.Buf & U32, B.read32(@BF, off), (@BF, f), rd0) :
    {T.@P_rv_fin(NN(t, x), T.@P_rv(k0, 0, off, len, NN(t, x), T.@P_fill(T.@P_cap(NN(t, x))), T.@P_elem(off, T.@P_win_start(off, len, 0, NN(t, x), _)))) == (@BF, RZ(False{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}
  %Equal.sym(B.Buf & (U32 & U32), T.@P_win_last(U32.is_eq(1, NN(t, x)), off, len, 0, f, @BF), (@BF, (f, B1(t, x, len))),
      ws0(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), h1, hq, f, U32.is_eq(1, NN(t, x)), {==})) :
    {T.@P_rv_fin(NN(t, x), T.@P_rv(k0, 0, off, len, NN(t, x), T.@P_fill(T.@P_cap(NN(t, x))), T.@P_elem(off, _))) == (@BF, RZ(False{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}
  %Equal.sym(B.Buf & @ET, T.@P_elem(off, (@BF, (f, B1(t, x, len)))), (@BF, OBJE(d, t, x, off, f, B1(t, x, len))), el_ev(d, t, n, x, off, len, eo, hd, hw, pf, f, B1(t, x, len), hc1)) :
    {T.@P_rv_fin(NN(t, x), T.@P_rv(k0, 0, off, len, NN(t, x), T.@P_fill(T.@P_cap(NN(t, x))), _)) == (@BF, RZ(False{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}
  %Equal.sym(B.Buf & Array<@ET>, T.@P_rv(k0, 0, off, len, NN(t, x), T.@P_fill(T.@P_cap(NN(t, x))), (@BF, OBJE(d, t, x, off, f, B1(t, x, len)))),
      (@BF, RV(k0, 0, NN(t, x), d, t, x, off, len, T.@P_fill(T.@P_cap(NN(t, x))), OBJE(d, t, x, off, f, B1(t, x, len)))),
      rv_go(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), hq, k0, 0, T.@P_fill(T.@P_cap(NN(t, x))), OBJE(d, t, x, off, f, B1(t, x, len)), inv, hE0)) :
    {T.@P_rv_fin(NN(t, x), _) == (@BF, RZ(False{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}
  {==}

def rdz(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +e: Bool, +ee: {U32.is_eq(len, 0) == e : Bool},
    +hc: {CZ(e, t, x, off, len) == True{} : Bool})
    -> {T.@P_read_nz(e, @BF, off, len) == (@BF, RZ(e, d, t, x, off, len)) : B.Buf & T.@P_Seq}:
  match e:
    case True{}: {==}
    case False{}: rdf(d, t, n, x, off, len, eo, hd, hw, pf, hc)

# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {T.@P_read(@BF, off, len) == (@BF, OBJw(d, t, x, off, len)) : B.Buf & T.@P_Seq}:
  rdz(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_eq(len, 0), {==}, hchk)
'''


VL_SPEC = r'''
# ---- the spec side ------------------------------------------------------------------------------------
# Element (s, e): its window's bytes SW and the element module's value VE; VI and YS the items and the
# byte lists of elements i + 1 .. i + k.

def SW(+t: FD.array__Tree<U32>, +x: Nat, +s: U32, +e: U32) -> +List<U32>: UW.WX(t, Nat.add(U32.to_nat(s), x), U32.to_nat(U32.sub(e, s)))
def VE(+t: FD.array__Tree<U32>, +x: Nat, +s: U32, +e: U32) -> S.Value: YW.VALw(t, Nat.add(U32.to_nat(s), x), U32.sub(e, s))

def VI(k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{VE(t, x, WJ(t, x, i), NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))), VI(q, U32.add(i, 1), m, t, x, len)}

def YS(k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<+List<U32>>:
  match k:
    case 0n: []
    case 1n+q: Con{SW(t, x, WJ(t, x, i), NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))), YS(q, U32.add(i, 1), m, t, x, len)}

def VZE(e: Bool, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:
  match e:
    case True{}: S.Sequence{S.EmptyItems{}}
    case False{}: S.Sequence{S.Items{VE(t, x, W0(t, x), B1(t, x, len)), VI(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, len)}}

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: VZE(U32.is_eq(len, 0), t, x, len)

def el_parts(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +s: U32, +e: U32,
    +h: {EE(True{}, t, x, off, len, s, e) == True{} : Bool})
    -> {Codec.parts(VE(t, x, s, e), Spec.@ESCH()) == Some{[S.Variable{SW(t, x, s, e)}]} : Maybe<&2, +List<S.Part>>}:
  +hab = el_ab(t, x, off, len, s, e, h)
  +hb = el_b(t, x, off, len, s, e, h)
  YW.specw(d, t, n, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s), eoc(d, x, off, len, s, FD.nat__le_trans(U32.to_nat(s), U32.to_nat(e), U32.to_nat(len), hab, hb), eo, hd, hw),
    hd, hwab(d, x, len, s, e, hab, hb, hw), pf, el_c(t, x, off, len, s, e, h))

# The parts of elements i + 1 .. i + k: one variable part each, their windows' bytes.
def parts_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +k: Nat, +i: U32, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +hE: {EV(k, i, m, t, x, off, len, True{}, WJ(t, x, i)) == True{} : Bool})
    -> {Codec.parts(VI(k, i, m, t, x, len), S.Repeat{Spec.@ESCH()}) == Some{VVL.VP(YS(k, i, m, t, x, len))} : Maybe<&2, +List<S.Part>>}:
  match k:
    case 0n: {==}
    case 1n:
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = ev_ok(0n, U32.add(i, 1), m, t, x, off, len, EE(True{}, t, x, off, len, WJ(t, x, i), nb), nb, hE)
      VS.cat_var(Codec.parts(VE(t, x, WJ(t, x, i), nb), Spec.@ESCH()), SW(t, x, WJ(t, x, i), nb), Codec.parts(S.EmptyItems{}, S.Repeat{Spec.@ESCH()}), [],
        el_parts(d, t, n, x, off, len, eo, hd, hw, pf, WJ(t, x, i), nb, hc), {==})
    case 2n+q:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q), FD.nat__add_comm(3n+q, U32.to_nat(i)),
          A.le_skip(1n+q, U32.to_nat(i))))
      +hi3 = FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q), FD.nat__add_comm(3n+q, U32.to_nat(i)),
          A.le_skip(q, U32.to_nat(i))))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him))
      +e2 = VVU.addk(i, 2, m, him)
      +inv2 = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 2n+q), Nat.add(1n+U32.to_nat(i), 2n+q), U32.to_nat(m),
        Equal.cong(Nat, Nat, z => Nat.add(z, 2n+q), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
        Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 2n+q), Nat.add(U32.to_nat(i), 3n+q), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 3n+q), 1n+Nat.add(U32.to_nat(i), 2n+q), FD.nat__add_succ(U32.to_nat(i), 2n+q)), inv))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = ev_ok(1n+q, U32.add(i, 1), m, t, x, off, len, EE(True{}, t, x, off, len, WJ(t, x, i), nb), nb, hE)
      +hE1 = FD.logic__subst(Bool, z => {EV(1n+q, U32.add(i, 1), m, t, x, off, len, z, nb) == True{} : Bool}, EE(True{}, t, x, off, len, WJ(t, x, i), nb), True{}, hc, hE)
      +hne = eqfr(U32.add(i, 2), m, FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(m)) == False{} : Bool}, 2n+U32.to_nat(i), U32.to_nat(U32.add(i, 2)), Equal.sym(Nat, U32.to_nat(U32.add(i, 2)), 2n+U32.to_nat(i), e2),
        FD.nat__is_eq_lt(2n+U32.to_nat(i), U32.to_nat(m), FD.nat__succ_le_lt(2n+U32.to_nat(i), U32.to_nat(m), hi3))))
      +hE2 = FD.logic__subst(Bool, z => {EV(1n+q, U32.add(i, 1), m, t, x, off, len, True{}, NX(z, t, x, len, U32.add(i, 1))) == True{} : Bool}, U32.is_eq(U32.add(i, 2), m), False{}, hne, hE1)
      VS.cat_var(Codec.parts(VE(t, x, WJ(t, x, i), nb), Spec.@ESCH()), SW(t, x, WJ(t, x, i), nb), Codec.parts(VI(1n+q, U32.add(i, 1), m, t, x, len), S.Repeat{Spec.@ESCH()}),
        VVL.VP(YS(1n+q, U32.add(i, 1), m, t, x, len)),
        el_parts(d, t, n, x, off, len, eo, hd, hw, pf, WJ(t, x, i), nb, hc), parts_go(d, t, n, x, off, len, eo, hd, hw, pf, m, hq, 1n+q, U32.add(i, 1), inv2, hE2))
'''


VL_BYTES = r'''
# ---- the windows' bytes ---------------------------------------------------------------------------------

def eqtr(+a: U32, +b: U32, +h: {U32.to_nat(a) == U32.to_nat(b) : Nat}) -> {U32.is_eq(a, b) == True{} : Bool}:
  %Equal.sym(U32, a, b, FD.u32__injective(a, b, h)) : {U32.is_eq(_, b) == True{} : Bool}
  %Equal.sym(Cmp, U32.cmp(b, b), Nat.cmp(U32.to_nat(b), U32.to_nat(b)), FD.u32__u32_cmp(b, b)) : {Cmp.is_eq(_) == True{} : Bool}
  FD.nat__is_eq_refl(U32.to_nat(b))

def ci_val(+j: U32, +len: U32, +hj: {Nat.is_le(A.quad(1n+U32.to_nat(j)), U32.to_nat(len)) == True{} : Bool}) -> {U32.to_nat(CI(j)) == A.quad(1n+U32.to_nat(j)) : Nat}:
  +ej1 = VVU.addk(j, 1, len, FD.nat__le_trans(1n+U32.to_nat(j), A.quad(1n+U32.to_nat(j)), U32.to_nat(len), A.quad_ge(1n+U32.to_nat(j)), hj))
  Equal.trans(Nat, U32.to_nat(CI(j)), A.quad(U32.to_nat(U32.add(j, 1))), A.quad(1n+U32.to_nat(j)),
    VVU.mul4(U32.add(j, 1), len, FD.logic__subst(Nat, z => {Nat.is_le(A.quad(z), U32.to_nat(len)) == True{} : Bool}, 1n+U32.to_nat(j), U32.to_nat(U32.add(j, 1)), Equal.sym(Nat, U32.to_nat(U32.add(j, 1)), 1n+U32.to_nat(j), ej1), hj)),
    Equal.cong(Nat, Nat, z => A.quad(z), U32.to_nat(U32.add(j, 1)), 1n+U32.to_nat(j), ej1))

# (e - s) + (l - e) = l - s for s <= e <= l.
def ar3(+s: Nat, +e: Nat, +l: Nat, +hse: {Nat.is_le(s, e) == True{} : Bool}, +hel: {Nat.is_le(e, l) == True{} : Bool})
    -> {Nat.add(Nat.sub(e, s), Nat.sub(l, e)) == Nat.sub(l, s) : Nat}:
  +h1 = Equal.trans(Nat, Nat.add(s, Nat.add(Nat.sub(e, s), Nat.sub(l, e))), Nat.add(Nat.add(s, Nat.sub(e, s)), Nat.sub(l, e)), l,
    Equal.sym(Nat, Nat.add(Nat.add(s, Nat.sub(e, s)), Nat.sub(l, e)), Nat.add(s, Nat.add(Nat.sub(e, s), Nat.sub(l, e))), FD.nat__add_assoc(s, Nat.sub(e, s), Nat.sub(l, e))),
    Equal.trans(Nat, Nat.add(Nat.add(s, Nat.sub(e, s)), Nat.sub(l, e)), Nat.add(e, Nat.sub(l, e)), l,
      Equal.cong(Nat, Nat, z => Nat.add(z, Nat.sub(l, e)), Nat.add(s, Nat.sub(e, s)), e, FD.nat__sub_add(e, s, hse)), FD.nat__sub_add(l, e, hel)))
  +h2 = Equal.trans(Nat, Nat.add(s, Nat.add(Nat.sub(e, s), Nat.sub(l, e))), l, Nat.add(s, Nat.sub(l, s)), h1,
    Equal.sym(Nat, Nat.add(s, Nat.sub(l, s)), l, FD.nat__sub_add(l, s, FD.nat__le_trans(s, e, l, hse, hel))))
  FD.u32alg__add_cancel_r(Nat.add(Nat.sub(e, s), Nat.sub(l, e)), Nat.sub(l, s), s,
    Equal.trans(Nat, Nat.add(Nat.add(Nat.sub(e, s), Nat.sub(l, e)), s), Nat.add(s, Nat.add(Nat.sub(e, s), Nat.sub(l, e))), Nat.add(Nat.sub(l, s), s),
      FD.nat__add_comm(Nat.add(Nat.sub(e, s), Nat.sub(l, e)), s), Equal.trans(Nat, Nat.add(s, Nat.add(Nat.sub(e, s), Nat.sub(l, e))), Nat.add(s, Nat.sub(l, s)), Nat.add(Nat.sub(l, s), s), h2, FD.nat__add_comm(s, Nat.sub(l, s)))))

# Two consecutive windows (s, e), (e, l) are the window (s, l).
def win2(+t: FD.array__Tree<U32>, +x: Nat, +s: U32, +e: U32, +l: U32,
    +hse: {Nat.is_le(U32.to_nat(s), U32.to_nat(e)) == True{} : Bool}, +hel: {Nat.is_le(U32.to_nat(e), U32.to_nat(l)) == True{} : Bool})
    -> {List.append(&2, U32, SW(t, x, s, e), SW(t, x, e, l)) == SW(t, x, s, l) : +List<U32>}:
  +a = U32.to_nat(U32.sub(e, s))
  +b = U32.to_nat(U32.sub(l, e))
  +ea = FD.u32__sub_nat(e, s, hse)
  +eb = FD.u32__sub_nat(l, e, hel)
  +el = Equal.trans(Nat, Nat.add(a, b), Nat.add(Nat.sub(U32.to_nat(e), U32.to_nat(s)), Nat.sub(U32.to_nat(l), U32.to_nat(e))), U32.to_nat(U32.sub(l, s)),
    Equal.trans(Nat, Nat.add(a, b), Nat.add(Nat.sub(U32.to_nat(e), U32.to_nat(s)), b), Nat.add(Nat.sub(U32.to_nat(e), U32.to_nat(s)), Nat.sub(U32.to_nat(l), U32.to_nat(e))),
      Equal.cong(Nat, Nat, z => Nat.add(z, b), a, Nat.sub(U32.to_nat(e), U32.to_nat(s)), ea), Equal.cong(Nat, Nat, z => Nat.add(Nat.sub(U32.to_nat(e), U32.to_nat(s)), z), b, Nat.sub(U32.to_nat(l), U32.to_nat(e)), eb)),
    Equal.trans(Nat, Nat.add(Nat.sub(U32.to_nat(e), U32.to_nat(s)), Nat.sub(U32.to_nat(l), U32.to_nat(e))), Nat.sub(U32.to_nat(l), U32.to_nat(s)), U32.to_nat(U32.sub(l, s)),
      ar3(U32.to_nat(s), U32.to_nat(e), U32.to_nat(l), hse, hel), Equal.sym(Nat, U32.to_nat(U32.sub(l, s)), Nat.sub(U32.to_nat(l), U32.to_nat(s)), FD.u32__sub_nat(l, s, FD.nat__le_trans(U32.to_nat(s), U32.to_nat(e), U32.to_nat(l), hse, hel)))))
  +ep = Equal.trans(Nat, Nat.add(a, Nat.add(U32.to_nat(s), x)), Nat.add(Nat.add(a, U32.to_nat(s)), x), Nat.add(U32.to_nat(e), x),
    Equal.sym(Nat, Nat.add(Nat.add(a, U32.to_nat(s)), x), Nat.add(a, Nat.add(U32.to_nat(s), x)), FD.nat__add_assoc(a, U32.to_nat(s), x)),
    Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add(a, U32.to_nat(s)), U32.to_nat(e),
      Equal.trans(Nat, Nat.add(a, U32.to_nat(s)), Nat.add(U32.to_nat(s), a), U32.to_nat(e), FD.nat__add_comm(a, U32.to_nat(s)),
        Equal.trans(Nat, Nat.add(U32.to_nat(s), a), Nat.add(U32.to_nat(s), Nat.sub(U32.to_nat(e), U32.to_nat(s))), U32.to_nat(e),
          Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(s), z), a, Nat.sub(U32.to_nat(e), U32.to_nat(s)), ea), FD.nat__sub_add(U32.to_nat(e), U32.to_nat(s), hse)))))
  %el : {List.append(&2, U32, SW(t, x, s, e), SW(t, x, e, l)) == UW.WX(t, Nat.add(U32.to_nat(s), x), _) : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, Nat.add(U32.to_nat(s), x), Nat.add(a, b)), List.append(&2, U32, UW.WX(t, Nat.add(U32.to_nat(s), x), a), UW.WX(t, Nat.add(a, Nat.add(U32.to_nat(s), x)), b)),
      VX2.splitWX(t, Nat.add(U32.to_nat(s), x), a, b)) :
    {List.append(&2, U32, SW(t, x, s, e), SW(t, x, e, l)) == _ : +List<U32>}
  %Equal.sym(Nat, Nat.add(a, Nat.add(U32.to_nat(s), x)), Nat.add(U32.to_nat(e), x), ep) :
    {List.append(&2, U32, SW(t, x, s, e), SW(t, x, e, l)) == List.append(&2, U32, UW.WX(t, Nat.add(U32.to_nat(s), x), a), UW.WX(t, _, b)) : +List<U32>}
  {==}

def valid_go(+k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {Layout.bytes_valid(VVL.VP(YS(k, i, m, t, x, len))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+q:
      VVL.vp_valid(SW(t, x, WJ(t, x, i), NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))), YS(q, U32.add(i, 1), m, t, x, len),
        UW.domWX(t, Nat.add(U32.to_nat(WJ(t, x, i)), x), U32.to_nat(U32.sub(NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)), WJ(t, x, i)))), valid_go(q, U32.add(i, 1), m, t, x, len))

def cnt_go(+k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {VVL.CNT(YS(k, i, m, t, x, len)) == k : Nat}:
  match k:
    case 0n: {==}
    case 1n+q: Equal.cong(Nat, Nat, z => 1n+z, VVL.CNT(YS(q, U32.add(i, 1), m, t, x, len)), q, cnt_go(q, U32.add(i, 1), m, t, x, len))

def count_go(+k: Nat, +i: U32, +m: U32, +t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {Codec.count(VI(k, i, m, t, x, len)) == k : Nat}:
  match k:
    case 0n: {==}
    case 1n+q: Equal.cong(Nat, Nat, z => 1n+z, Codec.count(VI(q, U32.add(i, 1), m, t, x, len)), q, count_go(q, U32.add(i, 1), m, t, x, len))

# The payloads of elements i + 1 .. i + 1 + q: the window from element i + 1's start to len.
def pay_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +q: Nat, +i: U32, +inv: {Nat.add(U32.to_nat(i), 1n+(1n+q)) == U32.to_nat(m) : Nat},
    +hE: {EV(1n+q, i, m, t, x, off, len, True{}, WJ(t, x, i)) == True{} : Bool})
    -> {VR.bcat(YS(1n+q, i, m, t, x, len)) == SW(t, x, WJ(t, x, i), len) : +List<U32>}:
  match q:
    case 0n:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n), FD.nat__add_comm(2n, U32.to_nat(i)),
          FD.nat__le_refl(2n+U32.to_nat(i))))
      +e2 = VVU.addk(i, 2, m, him)
      +hl = eqtr(U32.add(i, 2), m, Equal.trans(Nat, U32.to_nat(U32.add(i, 2)), Nat.add(U32.to_nat(i), 2n), U32.to_nat(m), Equal.trans(Nat, U32.to_nat(U32.add(i, 2)), 2n+U32.to_nat(i), Nat.add(U32.to_nat(i), 2n), e2, FD.nat__add_comm(2n, U32.to_nat(i))), inv))
      %Equal.sym(Bool, U32.is_eq(U32.add(i, 2), m), True{}, hl) :
        {List.append(&2, U32, SW(t, x, WJ(t, x, i), NX(_, t, x, len, U32.add(i, 1))), []) == SW(t, x, WJ(t, x, i), len) : +List<U32>}
      VS.app_nil(SW(t, x, WJ(t, x, i), len))
    case 1n+q2:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q2), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q2, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q2), FD.nat__add_comm(3n+q2, U32.to_nat(i)),
          A.le_skip(1n+q2, U32.to_nat(i))))
      +hi3 = FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q2), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q2, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q2), FD.nat__add_comm(3n+q2, U32.to_nat(i)),
          A.le_skip(q2, U32.to_nat(i))))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him))
      +e2 = VVU.addk(i, 2, m, him)
      +inv2 = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 2n+q2), Nat.add(1n+U32.to_nat(i), 2n+q2), U32.to_nat(m),
        Equal.cong(Nat, Nat, z => Nat.add(z, 2n+q2), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
        Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 2n+q2), Nat.add(U32.to_nat(i), 3n+q2), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 3n+q2), 1n+Nat.add(U32.to_nat(i), 2n+q2), FD.nat__add_succ(U32.to_nat(i), 2n+q2)), inv))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = ev_ok(1n+q2, U32.add(i, 1), m, t, x, off, len, EE(True{}, t, x, off, len, WJ(t, x, i), nb), nb, hE)
      +hE1 = FD.logic__subst(Bool, z => {EV(1n+q2, U32.add(i, 1), m, t, x, off, len, z, nb) == True{} : Bool}, EE(True{}, t, x, off, len, WJ(t, x, i), nb), True{}, hc, hE)
      +hne = eqfr(U32.add(i, 2), m, FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(m)) == False{} : Bool}, 2n+U32.to_nat(i), U32.to_nat(U32.add(i, 2)), Equal.sym(Nat, U32.to_nat(U32.add(i, 2)), 2n+U32.to_nat(i), e2),
        FD.nat__is_eq_lt(2n+U32.to_nat(i), U32.to_nat(m), FD.nat__succ_le_lt(2n+U32.to_nat(i), U32.to_nat(m), hi3))))
      +hE2 = FD.logic__subst(Bool, z => {EV(1n+q2, U32.add(i, 1), m, t, x, off, len, True{}, NX(z, t, x, len, U32.add(i, 1))) == True{} : Bool}, U32.is_eq(U32.add(i, 2), m), False{}, hne, hE1)
      +hc2 = FD.logic__subst(Bool, z => {EE(True{}, t, x, off, len, WJ(t, x, i), NX(z, t, x, len, U32.add(i, 1))) == True{} : Bool}, U32.is_eq(U32.add(i, 2), m), False{}, hne, hc)
      +E = WJ(t, x, U32.add(i, 1))
      %Equal.sym(Bool, U32.is_eq(U32.add(i, 2), m), False{}, hne) :
        {List.append(&2, U32, SW(t, x, WJ(t, x, i), NX(_, t, x, len, U32.add(i, 1))), VR.bcat(YS(1n+q2, U32.add(i, 1), m, t, x, len))) == SW(t, x, WJ(t, x, i), len) : +List<U32>}
      %Equal.sym(+List<U32>, VR.bcat(YS(1n+q2, U32.add(i, 1), m, t, x, len)), SW(t, x, E, len), pay_go(d, t, n, x, off, len, eo, hd, hw, pf, m, hq, q2, U32.add(i, 1), inv2, hE2)) :
        {List.append(&2, U32, SW(t, x, WJ(t, x, i), E), _) == SW(t, x, WJ(t, x, i), len) : +List<U32>}
      win2(t, x, WJ(t, x, i), E, len, el_ab(t, x, off, len, WJ(t, x, i), E, hc2), FD.nat__le_trans(U32.to_nat(E), U32.to_nat(len), U32.to_nat(len), el_b(t, x, off, len, WJ(t, x, i), E, hc2), FD.nat__le_refl(U32.to_nat(len))))
# The offsets of elements i + 1 .. i + k: the table's words from element i + 1's.
def offs_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32,
    +hq: {Nat.is_le(A.quad(U32.to_nat(m)), U32.to_nat(len)) == True{} : Bool},
    +k: Nat, +i: U32, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +hE: {EV(k, i, m, t, x, off, len, True{}, WJ(t, x, i)) == True{} : Bool})
    -> {VVL.OFFS(YS(k, i, m, t, x, len), U32.to_nat(WJ(t, x, i))) == F.limbs(UR.RWS(k, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}:
  match k:
    case 0n: {==}
    case 1n:
      %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(WJ(t, x, i))), I.limb(WJ(t, x, i)), VG.digits_limb(WJ(t, x, i))) :
        {List.append(&2, U32, _, []) == F.limbs(UR.RWS(1n, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}
      {==}
    case 2n+q2:
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q2), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q2, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q2), FD.nat__add_comm(3n+q2, U32.to_nat(i)),
          A.le_skip(1n+q2, U32.to_nat(i))))
      +hi3 = FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 3n+q2), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(3n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(3n+q2, U32.to_nat(i)), Nat.add(U32.to_nat(i), 3n+q2), FD.nat__add_comm(3n+q2, U32.to_nat(i)),
          A.le_skip(q2, U32.to_nat(i))))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him))
      +e2 = VVU.addk(i, 2, m, him)
      +inv2 = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 2n+q2), Nat.add(1n+U32.to_nat(i), 2n+q2), U32.to_nat(m),
        Equal.cong(Nat, Nat, z => Nat.add(z, 2n+q2), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
        Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 2n+q2), Nat.add(U32.to_nat(i), 3n+q2), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 3n+q2), 1n+Nat.add(U32.to_nat(i), 2n+q2), FD.nat__add_succ(U32.to_nat(i), 2n+q2)), inv))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = ev_ok(1n+q2, U32.add(i, 1), m, t, x, off, len, EE(True{}, t, x, off, len, WJ(t, x, i), nb), nb, hE)
      +hE1 = FD.logic__subst(Bool, z => {EV(1n+q2, U32.add(i, 1), m, t, x, off, len, z, nb) == True{} : Bool}, EE(True{}, t, x, off, len, WJ(t, x, i), nb), True{}, hc, hE)
      +hne = eqfr(U32.add(i, 2), m, FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(m)) == False{} : Bool}, 2n+U32.to_nat(i), U32.to_nat(U32.add(i, 2)), Equal.sym(Nat, U32.to_nat(U32.add(i, 2)), 2n+U32.to_nat(i), e2),
        FD.nat__is_eq_lt(2n+U32.to_nat(i), U32.to_nat(m), FD.nat__succ_le_lt(2n+U32.to_nat(i), U32.to_nat(m), hi3))))
      +hE2 = FD.logic__subst(Bool, z => {EV(1n+q2, U32.add(i, 1), m, t, x, off, len, True{}, NX(z, t, x, len, U32.add(i, 1))) == True{} : Bool}, U32.is_eq(U32.add(i, 2), m), False{}, hne, hE1)
      +hc2 = FD.logic__subst(Bool, z => {EE(True{}, t, x, off, len, WJ(t, x, i), NX(z, t, x, len, U32.add(i, 1))) == True{} : Bool}, U32.is_eq(U32.add(i, 2), m), False{}, hne, hc)
      +E = WJ(t, x, U32.add(i, 1))
      +S = WJ(t, x, i)
      +E = WJ(t, x, U32.add(i, 1))
      +hab = el_ab(t, x, off, len, S, E, hc2)
      +hb = el_b(t, x, off, len, S, E, hc2)
      +eqoff = Equal.trans(Nat, Nat.add(U32.to_nat(S), List.length(&2, U32, SW(t, x, S, E))), Nat.add(U32.to_nat(S), U32.to_nat(U32.sub(E, S))), U32.to_nat(E),
        Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(S), z), List.length(&2, U32, SW(t, x, S, E)), U32.to_nat(U32.sub(E, S)), UW.lenWX(d, t, Nat.add(U32.to_nat(S), x), U32.to_nat(U32.sub(E, S)), pf, hwab(d, x, len, S, E, hab, hb, hw))),
        Equal.trans(Nat, Nat.add(U32.to_nat(S), U32.to_nat(U32.sub(E, S))), Nat.add(U32.to_nat(S), Nat.sub(U32.to_nat(E), U32.to_nat(S))), U32.to_nat(E),
          Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(S), z), U32.to_nat(U32.sub(E, S)), Nat.sub(U32.to_nat(E), U32.to_nat(S)), FD.u32__sub_nat(E, S, hab)), FD.nat__sub_add(U32.to_nat(E), U32.to_nat(S), hab)))
      +ci_i = ci_val(i, len, FD.nat__le_trans(A.quad(1n+U32.to_nat(i)), A.quad(U32.to_nat(m)), U32.to_nat(len), dm(1n+U32.to_nat(i), U32.to_nat(m), FD.nat__le_trans(1n+U32.to_nat(i), 2n+U32.to_nat(i), U32.to_nat(m), A.le_skip(1n, 1n+U32.to_nat(i)), him)), hq))
      +ci_j = Equal.trans(Nat, U32.to_nat(CI(U32.add(i, 1))), A.quad(1n+U32.to_nat(U32.add(i, 1))), A.quad(2n+U32.to_nat(i)),
        ci_val(U32.add(i, 1), len, FD.logic__subst(Nat, z => {Nat.is_le(A.quad(1n+z), U32.to_nat(len)) == True{} : Bool}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1),
          FD.nat__le_trans(A.quad(2n+U32.to_nat(i)), A.quad(U32.to_nat(m)), U32.to_nat(len), dm(2n+U32.to_nat(i), U32.to_nat(m), him), hq))),
        Equal.cong(Nat, Nat, z => A.quad(1n+z), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1))
      +eqpos = Equal.trans(Nat, 4n+Nat.add(U32.to_nat(CI(i)), x), 4n+Nat.add(A.quad(1n+U32.to_nat(i)), x), Nat.add(U32.to_nat(CI(U32.add(i, 1))), x),
        Equal.cong(Nat, Nat, z => 4n+Nat.add(z, x), U32.to_nat(CI(i)), A.quad(1n+U32.to_nat(i)), ci_i),
        Equal.sym(Nat, Nat.add(U32.to_nat(CI(U32.add(i, 1))), x), 4n+Nat.add(A.quad(1n+U32.to_nat(i)), x), Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(CI(U32.add(i, 1))), A.quad(2n+U32.to_nat(i)), ci_j)))
      %Equal.sym(Bool, U32.is_eq(U32.add(i, 2), m), False{}, hne) :
        {VVL.OFFS(Con{SW(t, x, S, NX(_, t, x, len, U32.add(i, 1))), YS(1n+q2, U32.add(i, 1), m, t, x, len)}, U32.to_nat(S)) == F.limbs(UR.RWS(2n+q2, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}
      %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(S)), I.limb(S), VG.digits_limb(S)) :
        {List.append(&2, U32, _, VVL.OFFS(YS(1n+q2, U32.add(i, 1), m, t, x, len), Nat.add(U32.to_nat(S), List.length(&2, U32, SW(t, x, S, E))))) == F.limbs(UR.RWS(2n+q2, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}
      %Equal.sym(Nat, Nat.add(U32.to_nat(S), List.length(&2, U32, SW(t, x, S, E))), U32.to_nat(E), eqoff) :
        {List.append(&2, U32, I.limb(S), VVL.OFFS(YS(1n+q2, U32.add(i, 1), m, t, x, len), _)) == F.limbs(UR.RWS(2n+q2, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}
      %Equal.sym(+List<U32>, VVL.OFFS(YS(1n+q2, U32.add(i, 1), m, t, x, len), U32.to_nat(E)), F.limbs(UR.RWS(1n+q2, t, Nat.add(U32.to_nat(CI(U32.add(i, 1))), x))),
          offs_go(d, t, n, x, off, len, eo, hd, hw, pf, m, hq, 1n+q2, U32.add(i, 1), inv2, hE2)) :
        {List.append(&2, U32, I.limb(S), _) == F.limbs(UR.RWS(2n+q2, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}
      %eqpos : {List.append(&2, U32, I.limb(S), F.limbs(UR.RWS(1n+q2, t, _))) == F.limbs(UR.RWS(2n+q2, t, Nat.add(U32.to_nat(CI(i)), x))) : +List<U32>}
      {==}
'''


VL_ASM = r'''
# ---- the window's bytes, element 0 included ----------------------------------------------------------

def ne12(+q: Nat, +e: {1n == 2n+q : Nat}) -> Empty:
  FD.logic__true_false(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 1n), 1n, 2n+q, e))

def be_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +hq: {Nat.is_le(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(len)) == True{} : Bool},
    +ew: {U32.to_nat(W0(t, x)) == A.quad(U32.to_nat(NN(t, x))) : Nat},
    +k: Nat, +inv: {Nat.add(U32.to_nat(0), 1n+k) == U32.to_nat(NN(t, x)) : Nat},
    +hE: {EV(k, 0, NN(t, x), t, x, off, len, True{}, WJ(t, x, 0)) == True{} : Bool},
    +l: Bool, +el: {U32.is_eq(1, NN(t, x)) == l : Bool},
    +hc1: {EE(True{}, t, x, off, len, W0(t, x), NX(l, t, x, len, 0)) == True{} : Bool})
    -> {List.append(&2, U32, VVL.OFFS(Con{SW(t, x, W0(t, x), NX(l, t, x, len, 0)), YS(k, 0, NN(t, x), t, x, len)}, U32.to_nat(W0(t, x))),
          VR.bcat(Con{SW(t, x, W0(t, x), NX(l, t, x, len, 0)), YS(k, 0, NN(t, x), t, x, len)})) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}:
  match k l:
    case 0n False{}: Empty.absurd({List.append(&2, U32, VVL.OFFS(Con{SW(t, x, W0(t, x), NX(False{}, t, x, len, 0)), YS(0n, 0, NN(t, x), t, x, len)}, U32.to_nat(W0(t, x))), VR.bcat(Con{SW(t, x, W0(t, x), NX(False{}, t, x, len, 0)), YS(0n, 0, NN(t, x), t, x, len)})) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}, FD.logic__true_false(Equal.trans(Bool, True{}, U32.is_eq(1, NN(t, x)), False{}, Equal.sym(Bool, U32.is_eq(1, NN(t, x)), True{}, eqtr(1, NN(t, x), inv)), el)))
    case 1n+q True{}: Empty.absurd({List.append(&2, U32, VVL.OFFS(Con{SW(t, x, W0(t, x), NX(True{}, t, x, len, 0)), YS(1n+q, 0, NN(t, x), t, x, len)}, U32.to_nat(W0(t, x))), VR.bcat(Con{SW(t, x, W0(t, x), NX(True{}, t, x, len, 0)), YS(1n+q, 0, NN(t, x), t, x, len)})) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}, ne12(q, Equal.trans(Nat, 1n, U32.to_nat(NN(t, x)), 2n+q, VVU.eqt(1, NN(t, x), el), Equal.sym(Nat, 2n+q, U32.to_nat(NN(t, x)), inv))))
    case 0n True{}:
      +f = W0(t, x)
      +hW = FD.nat__le_trans(U32.to_nat(f), U32.to_nat(len), U32.to_nat(len), el_ab(t, x, off, len, f, len, hc1), el_b(t, x, off, len, f, len, hc1))
      +L = U32.to_nat(U32.sub(len, f))
      +eL = Equal.trans(Nat, Nat.add(U32.to_nat(f), L), Nat.add(U32.to_nat(f), Nat.sub(U32.to_nat(len), U32.to_nat(f))), U32.to_nat(len),
        Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(f), z), L, Nat.sub(U32.to_nat(len), U32.to_nat(f)), FD.u32__sub_nat(len, f, hW)), FD.nat__sub_add(U32.to_nat(len), U32.to_nat(f), hW))
      +eW = Equal.trans(Nat, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), A.quad(1n), ew, Equal.cong(Nat, Nat, z => A.quad(z), U32.to_nat(NN(t, x)), 1n, Equal.sym(Nat, 1n, U32.to_nat(NN(t, x)), inv)))
      %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(f)), I.limb(f), VG.digits_limb(f)) :
        {List.append(&2, U32, List.append(&2, U32, _, []), List.append(&2, U32, SW(t, x, f, len), [])) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, SW(t, x, f, len), []), SW(t, x, f, len), VS.app_nil(SW(t, x, f, len))) :
        {List.append(&2, U32, List.append(&2, U32, I.limb(f), []), _) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %eL : {List.append(&2, U32, List.append(&2, U32, I.limb(f), []), SW(t, x, f, len)) == UW.WX(t, x, _) : +List<U32>}
      %Equal.sym(Nat, U32.to_nat(f), A.quad(1n), eW) :
        {List.append(&2, U32, List.append(&2, U32, I.limb(f), []), UW.WX(t, Nat.add(_, x), L)) == UW.WX(t, x, Nat.add(_, L)) : +List<U32>}
      Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(1n), L)), List.append(&2, U32, F.limbs(UR.RWS(1n, t, x)), UW.WX(t, Nat.add(A.quad(1n), x), L)),
        UW.headWX(d, t, x, 1n, L, pf, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), @P4) == True{} : Bool}, U32.to_nat(len), Nat.add(A.quad(1n), L),
          Equal.sym(Nat, Nat.add(A.quad(1n), L), U32.to_nat(len), FD.logic__subst(Nat, z => {Nat.add(z, L) == U32.to_nat(len) : Nat}, U32.to_nat(f), A.quad(1n), eW, eL)), hw)))
    case 1n+q False{}:
      +f = W0(t, x)
      +hW = FD.nat__le_trans(U32.to_nat(f), U32.to_nat(WJ(t, x, 0)), U32.to_nat(len), el_ab(t, x, off, len, f, WJ(t, x, 0), hc1), el_b(t, x, off, len, f, WJ(t, x, 0), hc1))
      +L = U32.to_nat(U32.sub(len, f))
      +eL = Equal.trans(Nat, Nat.add(U32.to_nat(f), L), Nat.add(U32.to_nat(f), Nat.sub(U32.to_nat(len), U32.to_nat(f))), U32.to_nat(len),
        Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(f), z), L, Nat.sub(U32.to_nat(len), U32.to_nat(f)), FD.u32__sub_nat(len, f, hW)), FD.nat__sub_add(U32.to_nat(len), U32.to_nat(f), hW))
      +S1 = WJ(t, x, 0)
      +eW = Equal.trans(Nat, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), A.quad(2n+q), ew, Equal.cong(Nat, Nat, z => A.quad(z), U32.to_nat(NN(t, x)), 2n+q, Equal.sym(Nat, 2n+q, U32.to_nat(NN(t, x)), inv)))
      +hab = el_ab(t, x, off, len, f, S1, hc1)
      +hb = el_b(t, x, off, len, f, S1, hc1)
      +eqoff = Equal.trans(Nat, Nat.add(U32.to_nat(f), List.length(&2, U32, SW(t, x, f, S1))), Nat.add(U32.to_nat(f), U32.to_nat(U32.sub(S1, f))), U32.to_nat(S1),
        Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(f), z), List.length(&2, U32, SW(t, x, f, S1)), U32.to_nat(U32.sub(S1, f)), UW.lenWX(d, t, Nat.add(U32.to_nat(f), x), U32.to_nat(U32.sub(S1, f)), pf, hwab(d, x, len, f, S1, hab, hb, hw))),
        Equal.trans(Nat, Nat.add(U32.to_nat(f), U32.to_nat(U32.sub(S1, f))), Nat.add(U32.to_nat(f), Nat.sub(U32.to_nat(S1), U32.to_nat(f))), U32.to_nat(S1),
          Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(f), z), U32.to_nat(U32.sub(S1, f)), Nat.sub(U32.to_nat(S1), U32.to_nat(f)), FD.u32__sub_nat(S1, f, hab)), FD.nat__sub_add(U32.to_nat(S1), U32.to_nat(f), hab)))
      %Equal.sym(Nat, Nat.add(U32.to_nat(f), List.length(&2, U32, SW(t, x, f, S1))), U32.to_nat(S1), eqoff) :
        {List.append(&2, U32, List.append(&2, U32, N.digits(4n, U32.to_nat(f)), VVL.OFFS(YS(1n+q, 0, NN(t, x), t, x, len), _)), List.append(&2, U32, SW(t, x, f, S1), VR.bcat(YS(1n+q, 0, NN(t, x), t, x, len)))) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %Equal.sym(+List<U32>, VVL.OFFS(YS(1n+q, 0, NN(t, x), t, x, len), U32.to_nat(S1)), F.limbs(UR.RWS(1n+q, t, Nat.add(U32.to_nat(CI(0)), x))),
          offs_go(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), hq, 1n+q, 0, inv, hE)) :
        {List.append(&2, U32, List.append(&2, U32, N.digits(4n, U32.to_nat(f)), _), List.append(&2, U32, SW(t, x, f, S1), VR.bcat(YS(1n+q, 0, NN(t, x), t, x, len)))) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(f)), I.limb(f), VG.digits_limb(f)) :
        {List.append(&2, U32, List.append(&2, U32, _, F.limbs(UR.RWS(1n+q, t, 4n+x))), List.append(&2, U32, SW(t, x, f, S1), VR.bcat(YS(1n+q, 0, NN(t, x), t, x, len)))) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %Equal.sym(+List<U32>, VR.bcat(YS(1n+q, 0, NN(t, x), t, x, len)), SW(t, x, S1, len), pay_go(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), hq, q, 0, inv, hE)) :
        {List.append(&2, U32, List.append(&2, U32, I.limb(f), F.limbs(UR.RWS(1n+q, t, 4n+x))), List.append(&2, U32, SW(t, x, f, S1), _)) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, SW(t, x, f, S1), SW(t, x, S1, len)), SW(t, x, f, len), win2(t, x, f, S1, len, hab, FD.nat__le_trans(U32.to_nat(S1), U32.to_nat(len), U32.to_nat(len), hb, FD.nat__le_refl(U32.to_nat(len))))) :
        {List.append(&2, U32, List.append(&2, U32, I.limb(f), F.limbs(UR.RWS(1n+q, t, 4n+x))), _) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}
      %eL : {List.append(&2, U32, List.append(&2, U32, I.limb(f), F.limbs(UR.RWS(1n+q, t, 4n+x))), SW(t, x, f, len)) == UW.WX(t, x, _) : +List<U32>}
      %Equal.sym(Nat, U32.to_nat(f), A.quad(2n+q), eW) :
        {List.append(&2, U32, List.append(&2, U32, I.limb(f), F.limbs(UR.RWS(1n+q, t, 4n+x))), UW.WX(t, Nat.add(_, x), L)) == UW.WX(t, x, Nat.add(_, L)) : +List<U32>}
      Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(2n+q), L)), List.append(&2, U32, F.limbs(UR.RWS(2n+q, t, x)), UW.WX(t, Nat.add(A.quad(2n+q), x), L)),
        UW.headWX(d, t, x, 2n+q, L, pf, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), @P4) == True{} : Bool}, U32.to_nat(len), Nat.add(A.quad(2n+q), L),
          Equal.sym(Nat, Nat.add(A.quad(2n+q), L), U32.to_nat(len), FD.logic__subst(Nat, z => {Nat.add(z, L) == U32.to_nat(len) : Nat}, U32.to_nat(f), A.quad(2n+q), eW, eL)), hw)))
# ---- the spec parts ------------------------------------------------------------------------------------

def spf(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +hc0: {CF(HC(W0(t, x), len), t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VZE(False{}, t, x, len), Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +f = W0(t, x)
  +ec = cf_ok(HC(f, len), t, x, off, len, hc0)
  +hEV = FD.logic__subst(Bool, z => {CF(z, t, x, off, len) == True{} : Bool}, HC(f, len), True{}, ec, hc0)
  +hA = FD.logic__and_left(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), ec)
  +hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)), ec)
  +e3 = VVU.eqt(U32.and(f, 3), 0, FD.logic__and_left(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
  +hfl = ule(f, len, FD.logic__and_right(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
  +h4 = ule(4, f, FD.logic__and_left(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))
  +ew = Equal.trans(Nat, U32.to_nat(f), Nat.add(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(U32.and(f, 3))), A.quad(U32.to_nat(NN(t, x))), VC.split4(f),
    Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(NN(t, x))), U32.to_nat(U32.and(f, 3))), Nat.add(A.quad(U32.to_nat(NN(t, x))), 0n), A.quad(U32.to_nat(NN(t, x))),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(NN(t, x))), z), U32.to_nat(U32.and(f, 3)), 0n, e3), FD.nat__add_zero(A.quad(U32.to_nat(NN(t, x))))))
  +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew, hfl)
  +h1 = quad_pos(U32.to_nat(NN(t, x)), FD.logic__subst(Nat, z => {Nat.is_le(4n, z) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew, h4))
  +es = FD.u32__sub_nat(NN(t, x), 1, h1)
  +inv = Equal.trans(Nat, Nat.add(U32.to_nat(0), 1n+U32.to_nat(U32.sub(NN(t, x), 1))), 1n+Nat.sub(U32.to_nat(NN(t, x)), 1n), U32.to_nat(NN(t, x)),
    Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(U32.sub(NN(t, x), 1)), Nat.sub(U32.to_nat(NN(t, x)), 1n), es),
    FD.nat__sub_add(U32.to_nat(NN(t, x)), 1n, h1))
  +h4l = FD.nat__le_trans(U32.to_nat(4), U32.to_nat(f), U32.to_nat(len), h4, hfl)
  +k0 = U32.to_nat(U32.sub(NN(t, x), 1))
  +hc1 = ev_ok(k0, 0, NN(t, x), t, x, off, len, EE(True{}, t, x, off, len, f, B1(t, x, len)), B1(t, x, len), hEV)
  +hE1 = FD.logic__subst(Bool, z => {EV(k0, 0, NN(t, x), t, x, off, len, z, B1(t, x, len)) == True{} : Bool}, EE(True{}, t, x, off, len, f, B1(t, x, len)), True{}, hc1, hEV)
  +hE0 = he0(t, x, off, len, U32.is_eq(1, NN(t, x)), {==}, hE1)
  +hlim = ule(U32.shrn(f, 2n), @LIM, FD.logic__and_right(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))
  +be = be_go(d, t, n, x, off, len, eo, hd, hw, pf, hq, ew, k0, inv, hE0, U32.is_eq(1, NN(t, x)), {==}, hc1)
  +ecn = Equal.trans(Nat, VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}), 1n+k0, U32.to_nat(NN(t, x)), Equal.cong(Nat, Nat, z => 1n+z, VVL.CNT(YS(k0, 0, NN(t, x), t, x, len)), k0, cnt_go(k0, 0, NN(t, x), t, x, len)), inv)
  +ecnt = Equal.trans(Nat, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), A.quad(U32.to_nat(NN(t, x))), U32.to_nat(f), Equal.cong(Nat, Nat, z => A.quad(z), VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}), U32.to_nat(NN(t, x)), ecn), Equal.sym(Nat, U32.to_nat(f), A.quad(U32.to_nat(NN(t, x))), ew))
  +be2 = FD.logic__subst(Nat, z => {List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, z), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}, U32.to_nat(f), A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), Equal.sym(Nat, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), U32.to_nat(f), ecnt), be)
  +hv = VVL.vp_valid(SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len), UW.domWX(t, Nat.add(U32.to_nat(f), x), U32.to_nat(U32.sub(B1(t, x, len), f))), valid_go(k0, 0, NN(t, x), t, x, len))
  +eqlen = Equal.trans(Nat, Nat.add(A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), Nat.add(List.length(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})))), List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), U32.to_nat(len),
    Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), List.length(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})))), Equal.sym(Nat, List.length(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})))), A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), VVL.len_offs(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))))),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})))), List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), List.length(&2, U32, List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), U32.to_nat(len),
      Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), Nat.add(List.length(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})))), List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VS.len_app(VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))),
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), UW.WX(t, x, U32.to_nat(len)), be2),
        UW.lenWX(d, t, x, U32.to_nat(len), pf, hw))))
  +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(len), Nat.add(A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), Equal.sym(Nat, Nat.add(A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), List.length(&2, U32, VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), U32.to_nat(len), eqlen),
    VBZ.fitq(d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))
  +cat = VS.cat_var(Codec.parts(VE(t, x, f, B1(t, x, len)), Spec.@ESCH()), SW(t, x, f, B1(t, x, len)), Codec.parts(VI(k0, 0, NN(t, x), t, x, len), S.Repeat{Spec.@ESCH()}), VVL.VP(YS(k0, 0, NN(t, x), t, x, len)),
    el_parts(d, t, n, x, off, len, eo, hd, hw, pf, f, B1(t, x, len), hc1), parts_go(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), hq, k0, 0, inv, hE0))
  +hcount = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}, U32.to_nat(NN(t, x)), 1n+Codec.count(VI(k0, 0, NN(t, x), t, x, len)),
    Equal.sym(Nat, 1n+Codec.count(VI(k0, 0, NN(t, x), t, x, len)), U32.to_nat(NN(t, x)), Equal.trans(Nat, 1n+Codec.count(VI(k0, 0, NN(t, x), t, x, len)), 1n+k0, U32.to_nat(NN(t, x)), Equal.cong(Nat, Nat, z => 1n+z, Codec.count(VI(k0, 0, NN(t, x), t, x, len)), k0, count_go(k0, 0, NN(t, x), t, x, len)), inv)), hlim)
  %Equal.sym(Bool, Nat.is_le(Codec.count(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}), U32.to_nat(@LIM)), True{}, hcount) :
    {Codec.require(_, Codec.aggregate(Codec.parts(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}, S.Repeat{Spec.@ESCH()}), None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}, S.Repeat{Spec.@ESCH()}), Some{VVL.VP(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})}, cat) :
    {Codec.require(True{}, Codec.aggregate(_, None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(VVL.VP(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), Some{List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))}, VVL.vp_enc(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, hv, fit)) :
    {Codec.require(True{}, Codec.one(_, None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, VVL.OFFS(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}, A.quad(VVL.CNT(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)}))), VR.bcat(Con{SW(t, x, f, B1(t, x, len)), YS(k0, 0, NN(t, x), t, x, len)})), UW.WX(t, x, U32.to_nat(len)), be2) :
    {Codec.require(True{}, Codec.one(Some{_}, None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  {==}

def spz(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +e: Bool, +ee: {U32.is_eq(len, 0) == e : Bool},
    +hc: {CZ(e, t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VZE(e, t, x, len), Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  match e:
    case True{}:
      %Equal.sym(Nat, U32.to_nat(len), 0n, VVU.eqt(len, 0, ee)) : {Codec.parts(S.Sequence{S.EmptyItems{}}, Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, _)}]} : Maybe<&2, +List<S.Part>>}
      {==}
    case False{}: spf(d, t, n, x, off, len, eo, hd, hw, pf, hc)

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  spz(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_eq(len, 0), {==}, hchk)
'''


VL_INV = r'''
# ---- the inversion: a value whose spec parts are the window's bytes passes the check -------------------

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def q4(+k: Nat) -> {Nat.is_le(4n, A.quad(1n+k)) == True{} : Bool}: dm(1n, 1n+k, FD.nat__zero_le(k))

def neq0(+len: U32, +h: {Nat.is_le(1n, U32.to_nat(len)) == True{} : Bool}, +b: Bool, +eb: {U32.is_eq(len, 0) == b : Bool}) -> {b == False{} : Bool}:
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, U32.to_nat(len), 0n,
      Equal.cong(U32, Nat, z => U32.to_nat(z), len, 0, FD.u32alg__eq_of(len, 0, eb)), h)))

# The word at byte p of the window, when the bytes from p are the four digits of Q.
def wval(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @PF, @HW, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +p: Nat, +Q: Nat, +R: +List<U32>,
    +hp: {Nat.is_le(Nat.add(p, 4n), U32.to_nat(len)) == True{} : Bool},
    +eb: {VS.bdr(p, @WW) == List.append(&2, U32, N.digits(4n, Q), R) : +List<U32>},
    +hQ: {Nat.is_le(Q, @P4) == True{} : Bool})
    -> {U32.to_nat(UR.RWN(t, Nat.add(p, x))) == Q : Nat}:
  +w = UR.RWN(t, Nat.add(p, x))
  +b1 = UR.rwn_bytes(d, t, Nat.add(p, x), pf, UR.roomw(x, U32.to_nat(len), p, @P4, hw, hp))
  +b2 = UW.subWX(t, x, p, 4n, U32.to_nat(len), hp)
  +b3 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), VS.bdr(p, @WW), List.append(&2, U32, N.digits(4n, Q), R), eb)
  +bl = Equal.trans(+List<U32>, I.limb(w), F.limbs([w]), N.digits(4n, Q), Equal.sym(+List<U32>, F.limbs([w]), I.limb(w), VS.app_nil(I.limb(w))),
    Equal.trans(+List<U32>, F.limbs([w]), UW.WX(t, Nat.add(p, x), 4n), N.digits(4n, Q), b1,
      Equal.trans(+List<U32>, UW.WX(t, Nat.add(p, x), 4n), VS.bt(4n, VS.bdr(p, @WW)), N.digits(4n, Q), Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(p, @WW)), UW.WX(t, Nat.add(p, x), 4n), b2), b3)))
  VG.digits_word(w, Q, VFT.fits4(2n+d, Q, hQ, FD.nat__lt_trans(d, 28n, 30n, hd, {==})), bl)

# The header check, for a first offset 4 c <= len with c <= @LIM.
def hct(+f: U32, +len: U32, +e3: {U32.and(f, 3) == 0 : U32}, +hfl: {Nat.is_le(U32.to_nat(f), U32.to_nat(len)) == True{} : Bool},
    +h4: {Nat.is_le(4n, U32.to_nat(f)) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(U32.shrn(f, 2n)), U32.to_nat(@LIM)) == True{} : Bool})
    -> {HC(f, len) == True{} : Bool}:
  %Equal.sym(U32, U32.and(f, 3), 0, e3) : {Bool.and(Bool.and(U32.is_eq(_, 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(f, len), True{}, u32le(f, len, hfl)) : {Bool.and(Bool.and(U32.is_eq(0, 0), _), Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(4, f), True{}, u32le(4, f, h4)) : {Bool.and(Bool.and(U32.is_eq(0, 0), True{}), Bool.and(_, U32.is_le(U32.shrn(f, 2n), @LIM))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(U32.shrn(f, 2n), @LIM), True{}, u32le(U32.shrn(f, 2n), @LIM, hN)) : {Bool.and(Bool.and(U32.is_eq(0, 0), True{}), Bool.and(True{}, _)) == True{} : Bool}
  {==}

# The element [a, b) whose bytes r0 start at P (the window's bytes from P are r0, then R) passes
# its check, when its value h has the one variable part r0.
def elx(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +a: U32, +b: U32, +P: Nat, +r0: +List<U32>, +R: +List<U32>, +h: S.Value,
    +ha: {U32.to_nat(a) == P : Nat}, +hb: {U32.to_nat(b) == Nat.add(P, List.length(&2, U32, r0)) : Nat},
    +hP: {VS.bdr(P, @WW) == List.append(&2, U32, r0, R) : +List<U32>},
    +hr: {Nat.is_le(Nat.add(P, List.length(&2, U32, r0)), U32.to_nat(len)) == True{} : Bool},
    +eh: {Codec.parts(h, Spec.@ESCH()) == Some{[S.Variable{r0}]} : @MP})
    -> {EE(True{}, t, x, off, len, a, b) == True{} : Bool}:
  +L0 = List.length(&2, U32, r0)
  +hab = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(b)) == True{} : Bool}, P, U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), P, ha),
    FD.logic__subst(Nat, z => {Nat.is_le(P, z) == True{} : Bool}, Nat.add(P, L0), U32.to_nat(b), Equal.sym(Nat, U32.to_nat(b), Nat.add(P, L0), hb), Order.below_sum(P, L0)))
  +hbl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, Nat.add(P, L0), U32.to_nat(b), Equal.sym(Nat, U32.to_nat(b), Nat.add(P, L0), hb), hr)
  +el = Equal.trans(Nat, U32.to_nat(U32.sub(b, a)), Nat.sub(U32.to_nat(b), U32.to_nat(a)), L0, FD.u32__sub_nat(b, a, hab),
    Equal.trans(Nat, Nat.sub(U32.to_nat(b), U32.to_nat(a)), Nat.sub(Nat.add(P, L0), P), L0,
      Equal.trans(Nat, Nat.sub(U32.to_nat(b), U32.to_nat(a)), Nat.sub(Nat.add(P, L0), U32.to_nat(a)), Nat.sub(Nat.add(P, L0), P),
        Equal.cong(Nat, Nat, z => Nat.sub(z, U32.to_nat(a)), U32.to_nat(b), Nat.add(P, L0), hb),
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.add(P, L0), z), U32.to_nat(a), P, ha)),
      FD.nat__add_sub_cancel(P, L0)))
  +ew = Equal.trans(+List<U32>, UW.WX(t, Nat.add(P, x), L0), VS.bt(L0, VS.bdr(P, @WW)), r0,
    Equal.sym(+List<U32>, VS.bt(L0, VS.bdr(P, @WW)), UW.WX(t, Nat.add(P, x), L0), UW.subWX(t, x, P, L0, U32.to_nat(len), hr)),
    Equal.trans(+List<U32>, VS.bt(L0, VS.bdr(P, @WW)), VS.bt(L0, List.append(&2, U32, r0, R)), r0,
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(L0, z), VS.bdr(P, @WW), List.append(&2, U32, r0, R), hP),
      Equal.trans(+List<U32>, VS.bt(L0, List.append(&2, U32, r0, R)), VS.bt(L0, r0), r0, VN.bt_app(L0, r0, R, FD.nat__le_refl(L0)), UW.bt_self(r0))))
  +ew2 = Equal.trans(+List<U32>, UW.WX(t, Nat.add(U32.to_nat(a), x), U32.to_nat(U32.sub(b, a))), UW.WX(t, Nat.add(P, x), L0), r0,
    Equal.trans(+List<U32>, UW.WX(t, Nat.add(U32.to_nat(a), x), U32.to_nat(U32.sub(b, a))), UW.WX(t, Nat.add(P, x), U32.to_nat(U32.sub(b, a))), UW.WX(t, Nat.add(P, x), L0),
      Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(z, x), U32.to_nat(U32.sub(b, a))), U32.to_nat(a), P, ha),
      Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(P, x), z), U32.to_nat(U32.sub(b, a)), L0, el)), ew)
  +hk = YW.invw(d, t, n, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a), eoc(d, x, off, len, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), hab, hbl), eo, hd, hw), hd,
    hwab(d, x, len, a, b, hab, hbl, hw), pf, h,
    FD.logic__subst(+List<U32>, z => {Codec.parts(h, Spec.@ESCH()) == Some{[S.Variable{z}]} : @MP}, r0, UW.WX(t, Nat.add(U32.to_nat(a), x), U32.to_nat(U32.sub(b, a))),
      Equal.sym(+List<U32>, UW.WX(t, Nat.add(U32.to_nat(a), x), U32.to_nat(U32.sub(b, a))), r0, ew2), eh))
  %Equal.sym(Bool, U32.is_le(a, b), True{}, u32le(a, b, hab)) : {Bool.and(True{}, EW(Bool.and(True{}, Bool.and(_, U32.is_le(b, len))), t, x, off, a, b)) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(b, len), True{}, u32le(b, len, hbl)) : {Bool.and(True{}, EW(Bool.and(True{}, Bool.and(True{}, _)), t, x, off, a, b)) == True{} : Bool}
  hk

# The end of element j: len for the last one (no elements rs2 after it), else the table's word at
# 4 (j + 1), P2 (the table from there holds the offsets of rs2 from P2).
def nxv(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @PF, @HW, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +l: Bool, +j: U32, +J: U32, +m: U32, +P2: Nat, +Z: +List<U32>, +rs2: +List<+List<U32>>,
    +el: {U32.is_eq(J, m) == l : Bool}, +ej: {Nat.add(U32.to_nat(J), VVL.CNT(rs2)) == U32.to_nat(m) : Nat},
    +hT: {VS.bdr(A.quad(1n+U32.to_nat(j)), @WW) == List.append(&2, U32, VVL.OFFS(rs2, P2), Z) : +List<U32>},
    +hH: {Nat.add(P2, List.length(&2, U32, VR.bcat(rs2))) == U32.to_nat(len) : Nat})
    -> {U32.to_nat(NX(l, t, x, len, j)) == P2 : Nat}:
  match l rs2:
    case True{} Nil{}:
      Equal.sym(Nat, P2, U32.to_nat(len), Equal.trans(Nat, P2, Nat.add(P2, 0n), U32.to_nat(len), Equal.sym(Nat, Nat.add(P2, 0n), P2, FD.nat__add_zero(P2)), hH))
    case True{} Con{+r1, +q}:
      +eJ = Equal.cong(U32, Nat, z => U32.to_nat(z), J, m, FD.u32alg__eq_of(J, m, el))
      Empty.absurd({U32.to_nat(NX(True{}, t, x, len, j)) == P2 : Nat}, VVL.nself(U32.to_nat(J), VVL.CNT(q),
        Equal.trans(Nat, Nat.add(U32.to_nat(J), 1n+VVL.CNT(q)), U32.to_nat(m), U32.to_nat(J), ej, Equal.sym(Nat, U32.to_nat(J), U32.to_nat(m), eJ))))
    case False{} Nil{}:
      +eJ = Equal.trans(Nat, U32.to_nat(J), Nat.add(U32.to_nat(J), 0n), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(J), 0n), U32.to_nat(J), FD.nat__add_zero(U32.to_nat(J))), ej)
      Empty.absurd({U32.to_nat(NX(False{}, t, x, len, j)) == P2 : Nat}, FD.logic__true_false(Equal.trans(Bool, True{}, U32.is_eq(J, m), False{}, Equal.sym(Bool, U32.is_eq(J, m), True{}, eqtr(J, m, eJ)), el)))
    case False{} Con{+r1, +q}:
      +q1 = A.quad(1n+U32.to_nat(j))
      +hL = FD.logic__subst(+List<U32>, z => {Nat.is_le(4n, List.length(&2, U32, z)) == True{} : Bool}, List.append(&2, U32, VVL.OFFS(Con{r1, q}, P2), Z), VS.bdr(q1, @WW),
        Equal.sym(+List<U32>, VS.bdr(q1, @WW), List.append(&2, U32, VVL.OFFS(Con{r1, q}, P2), Z), hT),
        FD.nat__zero_le(List.length(&2, U32, List.append(&2, U32, VVL.OFFS(q, Nat.add(P2, List.length(&2, U32, r1))), Z))))
      +room = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q1, 4n), z) == True{} : Bool}, List.length(&2, U32, @WW), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw), VVL.bdr_room(q1, @WW, hL))
      +hj = FD.nat__le_trans(q1, Nat.add(q1, 4n), U32.to_nat(len), FD.nat__le_add_right(q1, 4n), room)
      +ec = ci_val(j, len, hj)
      +hp = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 4n), U32.to_nat(len)) == True{} : Bool}, q1, U32.to_nat(CI(j)), Equal.sym(Nat, U32.to_nat(CI(j)), q1, ec), room)
      +eb = FD.logic__subst(Nat, z => {VS.bdr(z, @WW) == List.append(&2, U32, N.digits(4n, P2), List.append(&2, U32, VVL.OFFS(q, Nat.add(P2, List.length(&2, U32, r1))), Z)) : +List<U32>},
        q1, U32.to_nat(CI(j)), Equal.sym(Nat, U32.to_nat(CI(j)), q1, ec), hT)
      +hQ = FD.nat__le_trans(P2, U32.to_nat(len), @P4, FD.logic__subst(Nat, z => {Nat.is_le(P2, z) == True{} : Bool}, Nat.add(P2, List.length(&2, U32, VR.bcat(Con{r1, q}))), U32.to_nat(len), hH,
        Order.below_sum(P2, List.length(&2, U32, VR.bcat(Con{r1, q})))), hlen(d, x, len, hw))
      wval(d, t, x, len, pf, hw, hd, U32.to_nat(CI(j)), P2, List.append(&2, U32, VVL.OFFS(q, Nat.add(P2, List.length(&2, U32, r1))), Z), hp, eb, hQ)

# The ev loop from element i + 1 (start a, at P), over the elements' bytes rs and values its.
def evl(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +m: U32, +Z: +List<U32>,
    +k: Nat, +its: S.Value, +rs: +List<+List<U32>>, +i: U32, +a: U32, +P: Nat,
    +ek: {VVL.CNT(rs) == k : Nat},
    +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat},
    +ha: {U32.to_nat(a) == P : Nat},
    +hP: {VS.bdr(P, @WW) == VR.bcat(rs) : +List<U32>},
    +hH: {Nat.add(P, List.length(&2, U32, VR.bcat(rs))) == U32.to_nat(len) : Nat},
    +hT: {VS.bdr(A.quad(1n+U32.to_nat(i)), @WW) == List.append(&2, U32, VVL.OFFS(rs, P), Z) : +List<U32>},
    al: VVL.ALL(Spec.@ESCH(), its, rs))
    -> {EV(k, i, m, t, x, off, len, True{}, a) == True{} : Bool}:
  match k its rs:
    case 0n _ _: {==}
    case 1n+ +q S.Items{+h, +r} Con{+r0, +rs2}:
      (+eh, al2) = al
      +L0 = List.length(&2, U32, r0)
      +P2 = Nat.add(P, L0)
      +Bn = List.length(&2, U32, VR.bcat(rs2))
      +ek2 = FD.nat__succ_inj(VVL.CNT(rs2), q, ek)
      +ti = U32.to_nat(i)
      +him = FD.logic__subst(Nat, z => {Nat.is_le(2n+ti, z) == True{} : Bool}, Nat.add(ti, 2n+q), U32.to_nat(m), inv,
        FD.logic__subst(Nat, z => {Nat.is_le(2n+ti, z) == True{} : Bool}, Nat.add(2n+q, ti), Nat.add(ti, 2n+q), FD.nat__add_comm(2n+q, ti), A.le_skip(q, ti)))
      +e1 = VVU.addk(i, 1, m, FD.nat__le_trans(1n+ti, 2n+ti, U32.to_nat(m), A.le_skip(1n, 1n+ti), him))
      +e2 = VVU.addk(i, 2, m, him)
      +inv2 = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 1n+q), Nat.add(1n+ti, 1n+q), U32.to_nat(m),
        Equal.cong(Nat, Nat, z => Nat.add(z, 1n+q), U32.to_nat(U32.add(i, 1)), 1n+ti, e1),
        Equal.trans(Nat, Nat.add(1n+ti, 1n+q), Nat.add(ti, 2n+q), U32.to_nat(m), Equal.sym(Nat, Nat.add(ti, 2n+q), 1n+Nat.add(ti, 1n+q), FD.nat__add_succ(ti, 1n+q)), inv))
      +hH2 = Equal.trans(Nat, Nat.add(P2, Bn), Nat.add(P, Nat.add(L0, Bn)), U32.to_nat(len), FD.nat__add_assoc(P, L0, Bn),
        Equal.trans(Nat, Nat.add(P, Nat.add(L0, Bn)), Nat.add(P, List.length(&2, U32, VR.bcat(Con{r0, rs2}))), U32.to_nat(len),
          Equal.cong(Nat, Nat, z => Nat.add(P, z), Nat.add(L0, Bn), List.length(&2, U32, VR.bcat(Con{r0, rs2})),
            Equal.sym(Nat, List.length(&2, U32, VR.bcat(Con{r0, rs2})), Nat.add(L0, Bn), VS.len_app(r0, VR.bcat(rs2)))), hH))
      +hr = FD.logic__subst(Nat, z => {Nat.is_le(P2, z) == True{} : Bool}, Nat.add(P2, Bn), U32.to_nat(len), hH2, Order.below_sum(P2, Bn))
      +q1 = A.quad(1n+ti)
      +eqq = Equal.trans(Nat, A.quad(1n+U32.to_nat(U32.add(i, 1))), A.quad(2n+ti), Nat.add(q1, 4n),
        Equal.cong(Nat, Nat, z => A.quad(1n+z), U32.to_nat(U32.add(i, 1)), 1n+ti, e1), FD.nat__add_comm(4n, q1))
      +hT2 = Equal.trans(+List<U32>, VS.bdr(A.quad(1n+U32.to_nat(U32.add(i, 1))), @WW), VS.bdr(Nat.add(q1, 4n), @WW), List.append(&2, U32, VVL.OFFS(rs2, P2), Z),
        Equal.cong(Nat, +List<U32>, z => VS.bdr(z, @WW), A.quad(1n+U32.to_nat(U32.add(i, 1))), Nat.add(q1, 4n), eqq),
        Equal.trans(+List<U32>, VS.bdr(Nat.add(q1, 4n), @WW), VS.bdr(4n, VS.bdr(q1, @WW)), List.append(&2, U32, VVL.OFFS(rs2, P2), Z), VN.bdr_add(q1, 4n, @WW),
          Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(4n, z), VS.bdr(q1, @WW), List.append(&2, U32, VVL.OFFS(Con{r0, rs2}, P), Z), hT)))
      +hP2 = Equal.trans(+List<U32>, VS.bdr(P2, @WW), VS.bdr(L0, VS.bdr(P, @WW)), VR.bcat(rs2), VN.bdr_add(P, L0, @WW),
        Equal.trans(+List<U32>, VS.bdr(L0, VS.bdr(P, @WW)), VS.bdr(L0, List.append(&2, U32, r0, VR.bcat(rs2))), VR.bcat(rs2),
          Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(L0, z), VS.bdr(P, @WW), VR.bcat(Con{r0, rs2}), hP), VS.bdr_app(r0, VR.bcat(rs2))))
      +nb = NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +ej = Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 2)), VVL.CNT(rs2)), Nat.add(2n+ti, q), U32.to_nat(m),
        Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 2)), VVL.CNT(rs2)), Nat.add(2n+ti, VVL.CNT(rs2)), Nat.add(2n+ti, q),
          Equal.cong(Nat, Nat, z => Nat.add(z, VVL.CNT(rs2)), U32.to_nat(U32.add(i, 2)), 2n+ti, e2), Equal.cong(Nat, Nat, z => Nat.add(2n+ti, z), VVL.CNT(rs2), q, ek2)),
        Equal.trans(Nat, Nat.add(2n+ti, q), Nat.add(ti, 2n+q), U32.to_nat(m),
          Equal.sym(Nat, Nat.add(ti, 2n+q), 2n+Nat.add(ti, q), Equal.trans(Nat, Nat.add(ti, 2n+q), 1n+Nat.add(ti, 1n+q), 2n+Nat.add(ti, q), FD.nat__add_succ(ti, 1n+q),
            Equal.cong(Nat, Nat, z => 1n+z, Nat.add(ti, 1n+q), 1n+Nat.add(ti, q), FD.nat__add_succ(ti, q)))), inv))
      +hb = nxv(d, t, x, len, pf, hw, hd, U32.is_eq(U32.add(i, 2), m), U32.add(i, 1), U32.add(i, 2), m, P2, Z, rs2, {==}, ej, hT2, hH2)
      +hee = elx(d, t, n, x, off, len, eo, hd, hw, pf, a, nb, P, r0, VR.bcat(rs2), h, ha, hb, hP, hr, eh)
      %Equal.sym(Bool, EE(True{}, t, x, off, len, a, nb), True{}, hee) : {EV(q, U32.add(i, 1), m, t, x, off, len, _, nb) == True{} : Bool}
      evl(d, t, n, x, off, len, eo, hd, hw, pf, m, Z, q, r, rs2, U32.add(i, 1), nb, P2, ek2, inv2, hb, hP2, hH2, hT2, al2)
@EVL_ROWS

def inv0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +hW: {@WW == List.append(&2, U32, VVL.OFFS([], A.quad(0n)), VR.bcat([])) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, @WW), 0n, Equal.sym(Nat, List.length(&2, U32, @WW), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), @WW, [], hW))
  %Equal.sym(Bool, U32.is_eq(len, 0), True{}, FD.u32alg__eq_true(len, 0, FD.u32__injective(len, 0, el))) : {CZ(_, t, x, off, len) == True{} : Bool}
  {==}

# At least one element: y0 (value h0), then rs (values r).
def inv1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +h0: S.Value, +r: S.Value, +y0: +List<U32>, +rs: +List<+List<U32>>,
    +eh: {Codec.parts(h0, Spec.@ESCH()) == Some{[S.Variable{y0}]} : @MP}, al: VVL.ALL(Spec.@ESCH(), r, rs),
    +hW: {@WW == List.append(&2, U32, VVL.OFFS(Con{y0, rs}, A.quad(1n+VVL.CNT(rs))), VR.bcat(Con{y0, rs})) : +List<U32>},
    +hc: {Nat.is_le(1n+VVL.CNT(rs), U32.to_nat(@LIM)) == True{} : Bool})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +Q = A.quad(1n+VVL.CNT(rs))
  +Z = VR.bcat(Con{y0, rs})
  +OQ = VVL.OFFS(Con{y0, rs}, Q)
  +L0 = List.length(&2, U32, y0)
  +Bn = List.length(&2, U32, VR.bcat(rs))
  +O1 = VVL.OFFS(rs, Nat.add(Q, L0))
  +tl = U32.to_nat(len)
  +hlen1 = Equal.trans(Nat, Nat.add(Q, List.length(&2, U32, Z)), Nat.add(List.length(&2, U32, OQ), List.length(&2, U32, Z)), tl,
    Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, Z)), Q, List.length(&2, U32, OQ), Equal.sym(Nat, List.length(&2, U32, OQ), Q, VVL.len_offs(Con{y0, rs}, Q))),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, OQ), List.length(&2, U32, Z)), List.length(&2, U32, List.append(&2, U32, OQ, Z)), tl,
      Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, OQ, Z)), Nat.add(List.length(&2, U32, OQ), List.length(&2, U32, Z)), VS.len_app(OQ, Z)),
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, OQ, Z)), List.length(&2, U32, @WW), tl,
        Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), List.append(&2, U32, OQ, Z), @WW, Equal.sym(+List<U32>, @WW, List.append(&2, U32, OQ, Z), hW)),
        UW.lenWX(d, t, x, tl, pf, hw))))
  +hQl = FD.logic__subst(Nat, z => {Nat.is_le(Q, z) == True{} : Bool}, Nat.add(Q, List.length(&2, U32, Z)), tl, hlen1, Order.below_sum(Q, List.length(&2, U32, Z)))
  +h4Q = q4(VVL.CNT(rs))
  +h4l = FD.nat__le_trans(4n, Q, tl, h4Q, hQl)
  +hQ = FD.nat__le_trans(Q, tl, @P4, hQl, hlen(d, x, len, hw))
  +eW0 = wval(d, t, x, len, pf, hw, hd, 0n, Q, List.append(&2, U32, O1, Z), h4l, hW, hQ)
  +f = W0(t, x)
  +tN = U32.to_nat(NN(t, x))
  +e3 = VLS.and3_q(f, 1n+VVL.CNT(rs), eW0)
  +eqN = Equal.trans(Nat, A.quad(tN), Nat.add(A.quad(tN), 0n), Q, Equal.sym(Nat, Nat.add(A.quad(tN), 0n), A.quad(tN), FD.nat__add_zero(A.quad(tN))),
    Equal.trans(Nat, Nat.add(A.quad(tN), 0n), Nat.add(A.quad(tN), U32.to_nat(U32.and(f, 3))), Q,
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(tN), z), 0n, U32.to_nat(U32.and(f, 3)), Equal.cong(U32, Nat, z => U32.to_nat(z), 0, U32.and(f, 3), Equal.sym(U32, U32.and(f, 3), 0, e3))),
      Equal.trans(Nat, Nat.add(A.quad(tN), U32.to_nat(U32.and(f, 3))), U32.to_nat(f), Q, Equal.sym(Nat, U32.to_nat(f), Nat.add(A.quad(tN), U32.to_nat(U32.and(f, 3))), VC.split4(f)), eW0)))
  +hNN = FD.nat__double_inj(tN, 1n+VVL.CNT(rs), FD.nat__double_inj(Nat.double(tN), Nat.double(1n+VVL.CNT(rs)), eqN))
  +hNl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}, 1n+VVL.CNT(rs), tN, Equal.sym(Nat, tN, 1n+VVL.CNT(rs), hNN), hc)
  +hfl = FD.logic__subst(Nat, z => {Nat.is_le(z, tl) == True{} : Bool}, Q, U32.to_nat(f), Equal.sym(Nat, U32.to_nat(f), Q, eW0), hQl)
  +h4W = FD.logic__subst(Nat, z => {Nat.is_le(4n, z) == True{} : Bool}, Q, U32.to_nat(f), Equal.sym(Nat, U32.to_nat(f), Q, eW0), h4Q)
  +hhc = hct(f, len, e3, hfl, h4W, hNl)
  +hT1 = Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(4n, z), @WW, List.append(&2, U32, OQ, Z), hW)
  +hH1 = Equal.trans(Nat, Nat.add(Nat.add(Q, L0), Bn), Nat.add(Q, Nat.add(L0, Bn)), tl, FD.nat__add_assoc(Q, L0, Bn),
    Equal.trans(Nat, Nat.add(Q, Nat.add(L0, Bn)), Nat.add(Q, List.length(&2, U32, Z)), tl,
      Equal.cong(Nat, Nat, z => Nat.add(Q, z), Nat.add(L0, Bn), List.length(&2, U32, Z), Equal.sym(Nat, List.length(&2, U32, Z), Nat.add(L0, Bn), VS.len_app(y0, VR.bcat(rs)))), hlen1))
  +ej1 = Equal.sym(Nat, tN, 1n+VVL.CNT(rs), hNN)
  +hb1 = nxv(d, t, x, len, pf, hw, hd, U32.is_eq(1, NN(t, x)), 0, 1, NN(t, x), Nat.add(Q, L0), Z, rs, {==}, ej1, hT1, hH1)
  +hP0 = Equal.trans(+List<U32>, VS.bdr(Q, @WW), VS.bdr(Q, List.append(&2, U32, OQ, Z)), Z,
    Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(Q, z), @WW, List.append(&2, U32, OQ, Z), hW),
    FD.logic__subst(Nat, z => {VS.bdr(z, List.append(&2, U32, OQ, Z)) == Z : +List<U32>}, List.length(&2, U32, OQ), Q, VVL.len_offs(Con{y0, rs}, Q), VS.bdr_app(OQ, Z)))
  +hr0 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Q, L0), z) == True{} : Bool}, Nat.add(Nat.add(Q, L0), Bn), tl, hH1, Order.below_sum(Nat.add(Q, L0), Bn))
  +hee = elx(d, t, n, x, off, len, eo, hd, hw, pf, f, B1(t, x, len), Q, y0, VR.bcat(rs), h0, eW0, hb1, hP0, hr0, eh)
  +hP1 = Equal.trans(+List<U32>, VS.bdr(Nat.add(Q, L0), @WW), VS.bdr(L0, VS.bdr(Q, @WW)), VR.bcat(rs), VN.bdr_add(Q, L0, @WW),
    Equal.trans(+List<U32>, VS.bdr(L0, VS.bdr(Q, @WW)), VS.bdr(L0, List.append(&2, U32, y0, VR.bcat(rs))), VR.bcat(rs),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(L0, z), VS.bdr(Q, @WW), Z, hP0), VS.bdr_app(y0, VR.bcat(rs))))
  +h1N = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+VVL.CNT(rs), tN, Equal.sym(Nat, tN, 1n+VVL.CNT(rs), hNN), FD.nat__zero_le(VVL.CNT(rs)))
  +esub = FD.u32__sub_nat(NN(t, x), 1, h1N)
  +k0 = U32.to_nat(U32.sub(NN(t, x), 1))
  +ek0 = Equal.sym(Nat, k0, VVL.CNT(rs), Equal.trans(Nat, k0, Nat.sub(tN, 1n), VVL.CNT(rs), esub,
    Equal.trans(Nat, Nat.sub(tN, 1n), Nat.sub(1n+VVL.CNT(rs), 1n), VVL.CNT(rs), Equal.cong(Nat, Nat, z => Nat.sub(z, 1n), tN, 1n+VVL.CNT(rs), hNN), FD.nat__add_sub_cancel(1n, VVL.CNT(rs)))))
  +iv0 = Equal.trans(Nat, 1n+k0, 1n+VVL.CNT(rs), tN, Equal.cong(Nat, Nat, z => 1n+z, k0, VVL.CNT(rs), Equal.sym(Nat, VVL.CNT(rs), k0, ek0)), Equal.sym(Nat, tN, 1n+VVL.CNT(rs), hNN))
  +hl1 = FD.nat__le_trans(1n, 4n, tl, {==}, h4l)
  %Equal.sym(Bool, U32.is_eq(len, 0), False{}, neq0(len, hl1, U32.is_eq(len, 0), {==})) : {CZ(_, t, x, off, len) == True{} : Bool}
  %Equal.sym(Bool, HC(f, len), True{}, hhc) : {CF(_, t, x, off, len) == True{} : Bool}
  %Equal.sym(Bool, EE(True{}, t, x, off, len, f, B1(t, x, len)), True{}, hee) : {EV(k0, 0, NN(t, x), t, x, off, len, _, B1(t, x, len)) == True{} : Bool}
  evl(d, t, n, x, off, len, eo, hd, hw, pf, NN(t, x), Z, k0, r, rs, 0, B1(t, x, len), Nat.add(Q, L0), ek0, iv0, hb1, hP1, hH1, hT1, al)

def invm(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +items: S.Value, +ys: +List<+List<U32>>,
    +hW: {@WW == List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)) : +List<U32>},
    +hc: {Nat.is_le(VVL.CNT(ys), U32.to_nat(@LIM)) == True{} : Bool}, al: VVL.ALL(Spec.@ESCH(), items, ys))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match items ys:
    case S.EmptyItems{} Nil{}: inv0(d, t, n, x, off, len, eo, hd, hw, pf, hW)
    case S.Items{+h0, +r} Con{+y0, +rs}:
      (+eh, al2) = al
      inv1(d, t, n, x, off, len, eo, hd, hw, pf, h0, r, y0, rs, eh, al2, hW, hc)
@INVM_ROWS

def invl(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +items: S.Value, +ys: +List<+List<U32>>,
    lst: VVL.LST(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ys))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+hW, +hc, al) = lst
  invm(d, t, n, x, off, len, eo, hd, hw, pf, items, ys, hW, hc, al)

# The parts of items under Repeat{element}: one variable part per item.
def rep_v(+items: S.Value, +ps: +List<S.Part>, +e: {Codec.parts(items, S.Repeat{Spec.@ESCH()}) == Some{ps} : @MP}) -> VVL.REP(Spec.@ESCH(), items, ps):
  match items:
    case S.EmptyItems{}:
      +eps = FD.logic__some_inj(+List<S.Part>, [], ps, e)
      %Equal.sym(+List<S.Part>, ps, [], Equal.sym(+List<S.Part>, [], ps, eps)) : VVL.REP(Spec.@ESCH(), S.EmptyItems{}, _)
      ({==}, {==}, Unit{})
    case S.Items{+h, +t}: VVL.rep_h(Spec.@ESCH(), h, t, ps, Codec.parts(h, Spec.@ESCH()), @SGL, {==}, e, pt => et => rep_v(t, pt, et))
@REPV_ROWS

def rqn(+W: +List<U32>, +b: Bool, +e: {Codec.require(b, None{}) == Some{[S.Variable{W}]} : @MP}) -> Empty:
  match b:
    case True{}: FD.logic__none_some(+List<S.Part>, [S.Variable{W}], e)
    case False{}: FD.logic__none_some(+List<S.Part>, [S.Variable{W}], e)

def iv_m(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +items: S.Value, +m: @MP,
    +em: {Codec.parts(items, S.Repeat{Spec.@ESCH()}) == m : @MP},
    +e: {Codec.require(Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, rqn(@WW, Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), e))
    case Some{+ps}:
      invl(d, t, n, x, off, len, eo, hd, hw, pf, items, VVL.YP(ps), VVL.inv_enc(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ps, rep_v(items, ps, em), e))

# Every value whose spec parts are the window's bytes passes the check.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +v: S.Value, +e: {Codec.parts(v, Spec.@SCH()) == Some{[S.Variable{@WW}]} : @MP})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match v:
    case S.Sequence{+items}: iv_m(d, t, n, x, off, len, eo, hd, hw, pf, items, Codec.parts(items, S.Repeat{Spec.@ESCH()}), {==}, e)
@INVW_ROWS
'''

VALS = [('S.BooleanValue{+b0}', 'S.BooleanValue{b0}'), ('S.UnsignedValue{+u0}', 'S.UnsignedValue{u0}'), ('S.BytesValue{+xs0}', 'S.BytesValue{xs0}'),
        ('S.BitsValue{+bs0}', 'S.BitsValue{bs0}'), ('S.Sequence{+it0}', 'S.Sequence{it0}'), ('S.Items{+hd0, +tl0}', 'S.Items{hd0, tl0}'),
        ('S.EmptyItems{}', 'S.EmptyItems{}'), ('S.Selected{+sel0, +sv0}', 'S.Selected{sel0, sv0}'), ('S.NullValue{}', 'S.NullValue{}')]
GK = '{CHKw(t, x, off, len) == True{} : Bool}'


def inv_rows():
    '''The absurd rows of the inversion's matches.'''
    G = '{EV(1n+q, i, m, t, x, off, len, True{}, a) == True{} : Bool}'
    nil = f'Empty.absurd({G}, FD.logic__true_false(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 0n, 1n+q, ek)))'
    ev = [f'    case 1n+ +q S.Items{{+h, +r}} Nil{{}}: {nil}']
    im, rv, iw = [], [], []
    for pat, val in VALS:
        if not pat.startswith('S.Items'):
            ev.append(f'    case 1n+ +q {pat} Nil{{}}: {nil}')
            ev.append(f'    case 1n+ +q {pat} Con{{+r0, +rs2}}: Empty.absurd({G}, al)')
        for yp in ('Nil{}', 'Con{+y0, +rs}'):
            if (pat, yp) not in (('S.EmptyItems{}', 'Nil{}'), ('S.Items{+hd0, +tl0}', 'Con{+y0, +rs}')):
                im.append(f'    case {pat} {yp}: Empty.absurd({GK}, al)')
        if pat not in ('S.EmptyItems{}', 'S.Items{+hd0, +tl0}'):
            rv.append(f'    case {pat}: Empty.absurd(VVL.REP(Spec.@ESCH(), {val}, ps), FD.logic__none_some(+List<S.Part>, ps, e))')
        if not pat.startswith('S.Sequence'):
            iw.append(f'    case {pat}: Empty.absurd({GK}, FD.logic__none_some(+List<S.Part>, [S.Variable{{@WW}}], e))')
    return {'@EVL_ROWS': '\n'.join(ev), '@INVM_ROWS': '\n'.join(im), '@REPV_ROWS': '\n'.join(rv), '@INVW_ROWS': '\n'.join(iw)}


def vl_text(P, LIM, E, ymod, sch, esch):
    mp = {'@ESCH': esch, '@SCH': sch, '@P': P, '@E': E, '@ET': 'O.Boxed<O.Words>', '@EO': 'O.Words', '@LIM': str(LIM), '@BF': 'UA.BF(t, n)', '@P4': P4, '@WHX': WHX, '@PF': PF,
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@MP': 'Maybe<&2, +List<S.Part>>', '@WW': 'UW.WX(t, x, U32.to_nat(len))', '@SGL': SGL[E]}
    inv = VL_INV
    for a, b in inv_rows().items():
        inv = inv.replace(a, b)
    L = HEAD + ['import ./vvl.bend as VVL', 'import ./vvlr.bend as VVR', 'import ./big_vvlu.bend as VVU', 'import ./vbx2.bend as VX2', 'import ./vrej.bend as VR', 'import ./vdig.bend as VG', 'import ./vnest.bend as VN', 'import ./vfits.bend as VFT', 'import ../../src/primitives.bend as I', f'import ./{ymod}.bend as YW', '',
                '# GENERATED by codegen/var_vlist.py. Do not edit.',
                f'# {P} (a list of at most {LIM} variable-size {E}) at a window at ANY byte offset: the',
                '# interface of proofs/obj/vua_win.bend, with a symbolic element count (see codegen/var_vlist.py).', '']
    return '\n'.join(L) + T_(VL_VALID + VL_READ + VL_SPEC + VL_BYTES + VL_ASM + inv, mp)


# ---- progressive lists (ProgressiveList[C], no count bound) of generic element types ------------------

# (list runtime prefix, element runtime prefix, element object type, element window module, element schema term,
#  the element schema's parts argument: its fields chain (a container) or S.Repeat{..} (a progressive list))
PVLISTS = [
    ('pl_Gc465214E502', 'Gc465214E502', 'T.Gc465214E502', 'var_winx_Gc465214E502', 'Spec.Gc465214E502()',
     'S.Chain{S.Unsigned{P.U16{}}, S.Chain{S.ListOf{S.Unsigned{P.U16{}}, 1024n}, S.Chain{S.Unsigned{P.U8{}}, S.End{}}}}'),
    ('pl_pl_Gc465214E502', 'pl_Gc465214E502', 'T.pl_Gc465214E502_Seq', 'big_vvl_pl_Gc465214E502', 'S.ProgressiveList{Spec.Gc465214E502()}',
     'S.Repeat{Spec.Gc465214E502()}'),
    ('pl_Gp66304057C3', 'Gp66304057C3', 'T.Gp66304057C3', 'big_var_winx_Gp66304057C3', 'Spec.Gp66304057C3()',
     'S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.ListOf{S.Unsigned{P.U16{}}, 123n}, S.Chain{S.ProgressiveBits{}, S.End{}}}}'),
]

PROG_DEFS = r'''
# ---- a progressive list's encoding (no count bound) -------------------------------------------------

# What the list's encoding W says: the offsets table of its elements' bytes ys, then ys.
def LSTP(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>) -> Type:
  {W == List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)) : +List<U32>} & VVL.ALL(s, items, ys)

def inv_b2p(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>, al: VVL.ALL(s, items, ys), +b2: Bool,
    +e: {Codec.one(SP.optional(b2, List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys))), None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LSTP(s, items, W, ys):
  match b2:
    case False{}: Empty.absurd(LSTP(s, items, W, ys), FD.logic__none_some(+List<S.Part>, [S.Variable{W}], e))
    case True{}:
      (Equal.sym(+List<U32>, List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)), W, VVL.vinj(List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)), W, e)), al)

# A list value whose parts under Repeat{s} are ps, and whose layout is the one variable part W.
def inv_encp(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ps: +List<S.Part>, r: VVL.REP(s, items, ps),
    +e: {Codec.aggregate(Some{ps}, None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LSTP(s, items, W, VVL.YP(ps)):
  (+ep, +ec, al) = r
  +ys = VVL.YP(ps)
  +e1 = FD.logic__subst(+List<S.Part>, z => {Codec.one(Layout.encoding(z), None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, ps, VVL.VP(ys), ep, e)
  +G = SP.optional(Bool.and(Layout.bytes_valid(VVL.VP(ys)), N.fits(4n, Nat.add(A.quad(VVL.CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)))
  inv_b2p(s, items, W, ys, al, Bool.and(Layout.bytes_valid(VVL.VP(ys)), N.fits(4n, Nat.add(A.quad(VVL.CNT(ys)), List.length(&2, U32, VR.bcat(ys))))),
    FD.logic__subst(Maybe<&2, +List<U32>>, z => {Codec.one(z, None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, Layout.encoding(VVL.VP(ys)), G, VVL.vp_encb(ys), e1))

# An element value's spec parts are at most one variable part.
def esingle(+h: S.Value) -> DF.single_result(None{}, Codec.parts(h, @ESCHT)):
  match h:
    case S.Sequence{+items}: UW.vs_agg(Codec.parts(items, @EFIELDS))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BytesValue{+xs0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}
'''


def prog(text):
    """The bounded list's module text, without the count bound (a progressive list)."""
    def cut_line(t, start):
        a = t.index(start)
        b = t.index('\n', a) + 1
        return t[:a] + t[b:]

    def rep1(t, a, b):
        assert t.count(a) >= 1, a[:80]
        return t.replace(a, b)
    t = text
    # the header check hct: no count bound
    t = rep1(t, ', +hN: {Nat.is_le(U32.to_nat(U32.shrn(f, 2n)), U32.to_nat(@LIM)) == True{} : Bool})\n    -> {HC(f, len) == True{} : Bool}:',
             ')\n    -> {HC(f, len) == True{} : Bool}:')
    t = cut_line(t, '  %Equal.sym(Bool, U32.is_le(U32.shrn(f, 2n), @LIM), True{}, u32le(U32.shrn(f, 2n), @LIM, hN))')
    t = rep1(t, '# The header check, for a first offset 4 c <= len with c <= @LIM.', '# The header check, for a first offset 4 c <= len.')
    # the spec parts: no count bound, no require
    t = cut_line(t, '  +hlim = ule(U32.shrn(f, 2n), @LIM,')
    a = t.index('  +hcount = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}')
    b = t.index('  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}, S.Repeat{Spec.@ESCH()}), Some{VVL.VP(', a)
    t = t[:a] + t[b:]
    for x in ['Codec.aggregate(_, None{})', 'Codec.one(_, None{})', 'Codec.one(Some{_}, None{})']:
        t = rep1(t, f'Codec.require(True{{}}, {x})', x)
    # the inversion: no count bound
    t = rep1(t, ',\n    +hc: {Nat.is_le(1n+VVL.CNT(rs), U32.to_nat(@LIM)) == True{} : Bool})\n    -> {CHKw(t, x, off, len) == True{} : Bool}:', ')\n    -> {CHKw(t, x, off, len) == True{} : Bool}:')
    t = cut_line(t, '  +hNl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}')
    t = rep1(t, 'hct(f, len, e3, hfl, h4W, hNl)', 'hct(f, len, e3, hfl, h4W)')
    t = rep1(t, '\n    +hc: {Nat.is_le(VVL.CNT(ys), U32.to_nat(@LIM)) == True{} : Bool}, al:', '\n    al:')
    t = rep1(t, 'inv1(d, t, n, x, off, len, eo, hd, hw, pf, h0, r, y0, rs, eh, al2, hW, hc)', 'inv1(d, t, n, x, off, len, eo, hd, hw, pf, h0, r, y0, rs, eh, al2, hW)')
    t = rep1(t, '    lst: VVL.LST(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ys))', '    lst: LSTP(Spec.@ESCH(), items, @WW, ys))')
    t = rep1(t, '  (+hW, +hc, al) = lst\n  invm(d, t, n, x, off, len, eo, hd, hw, pf, items, ys, hW, hc, al)', '  (+hW, al) = lst\n  invm(d, t, n, x, off, len, eo, hd, hw, pf, items, ys, hW, al)')
    t = rep1(t, '    +e: {Codec.require(Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})',
             '    +e: {Codec.aggregate(m, None{}) == Some{[S.Variable{@WW}]} : @MP})')
    t = rep1(t, 'rqn(@WW, Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), e)', 'FD.logic__none_some(+List<S.Part>, [S.Variable{@WW}], e)')
    t = rep1(t, 'VVL.inv_enc(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ps, rep_v(items, ps, em), e)', 'inv_encp(Spec.@ESCH(), items, @WW, ps, rep_v(items, ps, em), e)')
    t = rep1(t, '\ndef invl(', PROG_DEFS + '\ndef invl(')
    # the validator's header: the count bound is True{}
    t = t.replace('U32.is_le(U32.shrn(f, 2n), @LIM)', 'True{}')
    t = t.replace('Spec.@SCH()', 'S.ProgressiveList{Spec.@ESCH()}').replace('Spec.@ESCH()', '@ESCHT')
    assert '@LIM' not in t, [l for l in t.split('\n') if '@LIM' in l][:3]
    return t


def vlp_text(P, E, EO, ymod, escht, efields):
    mp = {'@ESCHT': escht, '@EFIELDS': efields, '@P': P, '@E': E, '@ET': f'O.Boxed<{EO}>', '@EO': EO, '@BF': 'UA.BF(t, n)', '@P4': P4, '@WHX': WHX, '@PF': PF,
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@MP': 'Maybe<&2, +List<S.Part>>', '@WW': 'UW.WX(t, x, U32.to_nat(len))', '@SGL': 'esingle(h)'}
    inv = VL_INV
    for a, b in inv_rows().items():
        inv = inv.replace(a, b)
    head = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
            for x in HEAD]
    L = head + ['import ../../types/primitive.bend as P', 'import ../../proofs/decode_facts.bend as DF', 'import ./vvl.bend as VVL', 'import ./vvlr.bend as VVR',
                'import ./big_vvlu.bend as VVU', 'import ./vbx2.bend as VX2', 'import ./vrej.bend as VR', 'import ./vdig.bend as VG', 'import ./vnest.bend as VN',
                'import ./vfits.bend as VFT', 'import ../../src/primitives.bend as I', f'import ./{ymod}.bend as YW', '',
                '# GENERATED by codegen/var_vlist.py. Do not edit.',
                f'# {P} (a progressive list of variable-size {E}) at a window at ANY byte offset: the',
                '# interface of proofs/obj/vua_win.bend, with a symbolic element count (see codegen/var_vlist.py).', '']
    return '\n'.join(L) + T_(prog(VL_VALID + VL_READ + VL_SPEC + VL_BYTES + VL_ASM + inv), mp)


# ---- vectors (Vector[C, N]) of variable-size generic element types ------------------------------------
# The runtime is the list's (the offsets table, the elements' windows) with a fixed count: an empty window is
# refused and the header check is `first == 4 N` (instead of 4 <= first, first / 4 <= LIM); the spec requires
# the count to be N (codec.bend: Vector). The module is the bounded list's with those three changes.

# (vector runtime prefix, count, element runtime prefix, element object type, element window module, element
#  schema term, the element schema's parts argument (its fields chain))
VVECS = [
    ('v2_Gc465214E502', 2, 'Gc465214E502', 'T.Gc465214E502', 'var_winx_Gc465214E502', 'Spec.Gc465214E502()',
     'S.Chain{S.Unsigned{P.U16{}}, S.Chain{S.ListOf{S.Unsigned{P.U16{}}, 1024n}, S.Chain{S.Unsigned{P.U8{}}, S.End{}}}}'),
]

VEC_DEFS = r'''
# ---- a vector's encoding (count N) --------------------------------------------------------------------

# The header check's count part, from first == 4 N.
def hvv(+f: U32, +h: {U32.is_eq(f, @FN) == True{} : Bool}) -> {Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM)) == True{} : Bool}:
  FD.logic__subst(U32, z => {Bool.and(U32.is_le(4, z), U32.is_le(U32.shrn(z, 2n), @LIM)) == True{} : Bool}, @FN, f, Equal.sym(U32, f, @FN, FD.u32alg__eq_of(f, @FN, h)), {==})
def hnn(+f: U32, +h: {U32.is_eq(f, @FN) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(U32.shrn(f, 2n)), @Nn) == True{} : Bool}:
  FD.logic__subst(U32, z => {Nat.is_eq(U32.to_nat(U32.shrn(z, 2n)), @Nn) == True{} : Bool}, @FN, f, Equal.sym(U32, f, @FN, FD.u32alg__eq_of(f, @FN, h)), {==})

# What the vector's encoding W says: the offsets table of its N elements' bytes ys, then ys.
def LSTV(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>) -> Type:
  {W == List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)) : +List<U32>} & ({Nat.is_eq(VVL.CNT(ys), @Nn) == True{} : Bool} & VVL.ALL(s, items, ys))

def inv_b2v(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>, al: VVL.ALL(s, items, ys),
    +hl: {Nat.is_eq(VVL.CNT(ys), @Nn) == True{} : Bool}, +b2: Bool,
    +e: {Codec.one(SP.optional(b2, List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys))), None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LSTV(s, items, W, ys):
  match b2:
    case False{}: Empty.absurd(LSTV(s, items, W, ys), FD.logic__none_some(+List<S.Part>, [S.Variable{W}], e))
    case True{}:
      (Equal.sym(+List<U32>, List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)), W, VVL.vinj(List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)), W, e)), hl, al)

def inv_b1v(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>, al: VVL.ALL(s, items, ys),
    +b1: Bool, +eb1: {Nat.is_eq(VVL.CNT(ys), @Nn) == b1 : Bool},
    +e: {Codec.require(b1, Codec.one(Layout.encoding(VVL.VP(ys)), None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LSTV(s, items, W, ys):
  match b1:
    case False{}: Empty.absurd(LSTV(s, items, W, ys), FD.logic__none_some(+List<S.Part>, [S.Variable{W}], e))
    case True{}:
      +G = SP.optional(Bool.and(Layout.bytes_valid(VVL.VP(ys)), N.fits(4n, Nat.add(A.quad(VVL.CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, VVL.OFFS(ys, A.quad(VVL.CNT(ys))), VR.bcat(ys)))
      inv_b2v(s, items, W, ys, al, eb1, Bool.and(Layout.bytes_valid(VVL.VP(ys)), N.fits(4n, Nat.add(A.quad(VVL.CNT(ys)), List.length(&2, U32, VR.bcat(ys))))),
        FD.logic__subst(Maybe<&2, +List<U32>>, z => {Codec.one(z, None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, Layout.encoding(VVL.VP(ys)), G, VVL.vp_encb(ys), e))

# A vector value whose parts under Repeat{s} are ps, and whose layout is the one variable part W.
def inv_encv(+s: S.Schema, +items: S.Value, +W: +List<U32>, +ps: +List<S.Part>, r: VVL.REP(s, items, ps),
    +e: {Codec.require(Nat.is_eq(Codec.count(items), @Nn), Codec.aggregate(Some{ps}, None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LSTV(s, items, W, VVL.YP(ps)):
  (+ep, +ec, al) = r
  +e1 = FD.logic__subst(+List<S.Part>, z => {Codec.require(Nat.is_eq(Codec.count(items), @Nn), Codec.one(Layout.encoding(z), None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, ps, VVL.VP(VVL.YP(ps)), ep, e)
  +e2 = FD.logic__subst(Nat, z => {Codec.require(Nat.is_eq(z, @Nn), Codec.one(Layout.encoding(VVL.VP(VVL.YP(ps))), None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, Codec.count(items), VVL.CNT(VVL.YP(ps)), ec, e1)
  inv_b1v(s, items, W, VVL.YP(ps), al, Nat.is_eq(VVL.CNT(VVL.YP(ps)), @Nn), {==}, e2)

# An element value's spec parts are at most one variable part.
def esingle(+h: S.Value) -> DF.single_result(None{}, Codec.parts(h, @ESCHT)):
  match h:
    case S.Sequence{+items}: UW.vs_agg(Codec.parts(items, @EFIELDS))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BytesValue{+xs0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}
'''

HCT_VEC = r'''# The header check, for a first offset 4 c <= len with c = N.
def hct(+f: U32, +len: U32, +e3: {U32.and(f, 3) == 0 : U32}, +hfl: {Nat.is_le(U32.to_nat(f), U32.to_nat(len)) == True{} : Bool},
    +h4: {Nat.is_le(4n, U32.to_nat(f)) == True{} : Bool}, +hN: {Nat.is_eq(U32.to_nat(U32.shrn(f, 2n)), @Nn) == True{} : Bool})
    -> {HC(f, len) == True{} : Bool}:
  +eq = FD.nat__eq_from_is_eq(U32.to_nat(U32.shrn(f, 2n)), @Nn, hN)
  +ef = Equal.trans(Nat, U32.to_nat(f), Nat.add(A.quad(U32.to_nat(U32.shrn(f, 2n))), U32.to_nat(U32.and(f, 3))), U32.to_nat(@FN), VC.split4(f),
    FD.logic__subst(U32, z => {Nat.add(A.quad(U32.to_nat(U32.shrn(f, 2n))), U32.to_nat(z)) == U32.to_nat(@FN) : Nat}, 0, U32.and(f, 3), Equal.sym(U32, U32.and(f, 3), 0, e3),
      FD.logic__subst(Nat, z => {Nat.add(A.quad(z), U32.to_nat(0)) == U32.to_nat(@FN) : Nat}, @Nn, U32.to_nat(U32.shrn(f, 2n)), Equal.sym(Nat, U32.to_nat(U32.shrn(f, 2n)), @Nn, eq), {==})))
  +efn = FD.u32__injective(f, @FN, ef)
  %Equal.sym(U32, U32.and(f, 3), 0, e3) : {Bool.and(Bool.and(U32.is_eq(_, 0), U32.is_le(f, len)), U32.is_eq(f, @FN)) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(f, len), True{}, u32le(f, len, hfl)) : {Bool.and(Bool.and(U32.is_eq(0, 0), _), U32.is_eq(f, @FN)) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(f, @FN), True{}, FD.u32alg__eq_true(f, @FN, efn)) : {Bool.and(Bool.and(U32.is_eq(0, 0), True{}), _) == True{} : Bool}
  {==}
'''


def vec(text, esch):
    """The bounded list's module text as a vector's (count @N: see VVECS)."""
    def rep1(t, a, b, cnt=None):
        assert t.count(a) >= 1 and (cnt is None or t.count(a) == cnt), (a[:90], t.count(a))
        return t.replace(a, b)
    t = text
    OLDB = 'Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM))'
    # the header check: first == 4 N (hB now says so; hvv gives the count part back)
    for h in ('ec', 'eb'):
        t = t.replace(f'+hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), {OLDB}, {h})',
                      f'+hB = hvv(f, FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), U32.is_eq(f, @FN), {h}))\n      +hBe = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), U32.is_eq(f, @FN), {h})')
    a = t.index('# The header check, for a first offset 4 c <= len with c <= @LIM.')
    b = t.index('\ndef ', t.index('def hct(', a) + 1)
    t = t[:a] + HCT_VEC + t[b:]
    t = t.replace(OLDB, 'U32.is_eq(f, @FN)')
    # the empty window is refused
    t = rep1(t, 'def CZ(e: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:\n  match e:\n    case True{}: True{}',
             'def CZ(e: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:\n  match e:\n    case True{}: False{}')
    # the reader: no empty case in the runtime
    t = rep1(t, '    -> {T.@P_read_nz(e, @BF, off, len) == (@BF, RZ(e, d, t, x, off, len)) : B.Buf & T.@P_Seq}:\n  match e:\n    case True{}: {==}',
             '    -> {T.@P_read(@BF, off, len) == (@BF, RZ(e, d, t, x, off, len)) : B.Buf & T.@P_Seq}:\n  match e:\n'
             '    case True{}: Empty.absurd({T.@P_read(@BF, off, len) == (@BF, RZ(True{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}, FD.logic__false_true(hc))')
    # the spec: count N (Vector's require), no empty case
    t = rep1(t, "  %Equal.sym(Nat, U32.to_nat(len), 0n, VVU.eqt(len, 0, ee)) : {Codec.parts(S.Sequence{S.EmptyItems{}}, Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, _)}]} : Maybe<&2, +List<S.Part>>}\n      {==}",
             "  Empty.absurd({Codec.parts(VZE(True{}, t, x, len), Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}, FD.logic__false_true(hc))")
    t = rep1(t, '  +hlim = ule(U32.shrn(f, 2n), @LIM, FD.logic__and_right(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))',
             '  +hlim = hnn(f, hBe)')
    t = rep1(t, '  +hcount = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}', '  +hcount = FD.logic__subst(Nat, z => {Nat.is_eq(z, @Nn) == True{} : Bool}')
    t = rep1(t, "  %Equal.sym(Bool, Nat.is_le(Codec.count(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}), U32.to_nat(@LIM)), True{}, hcount) :\n    {Codec.require(_, ",
             "  %Equal.sym(Bool, Nat.is_eq(Codec.count(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}), @Nn), True{}, hcount) :\n    {Codec.require(_, ")
    # the inversion: count N
    t = rep1(t, '    +hc: {Nat.is_le(1n+VVL.CNT(rs), U32.to_nat(@LIM)) == True{} : Bool})', '    +hc: {Nat.is_eq(1n+VVL.CNT(rs), @Nn) == True{} : Bool})')
    t = rep1(t, '  +hNl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}', '  +hNl = FD.logic__subst(Nat, z => {Nat.is_eq(z, @Nn) == True{} : Bool}')
    t = rep1(t, '    +hc: {Nat.is_le(VVL.CNT(ys), U32.to_nat(@LIM)) == True{} : Bool}, al:', '    +hc: {Nat.is_eq(VVL.CNT(ys), @Nn) == True{} : Bool}, al:')
    t = rep1(t, '    case S.EmptyItems{} Nil{}: inv0(d, t, n, x, off, len, eo, hd, hw, pf, hW)', '    case S.EmptyItems{} Nil{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__false_true(hc))')
    t = rep1(t, '    lst: VVL.LST(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ys))', '    lst: LSTV(Spec.@ESCH(), items, @WW, ys))')
    t = rep1(t, '    +e: {Codec.require(Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})',
             '    +e: {Codec.require(Nat.is_eq(Codec.count(items), @Nn), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})')
    t = rep1(t, 'rqn(@WW, Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), e)', 'rqn(@WW, Nat.is_eq(Codec.count(items), @Nn), e)')
    t = rep1(t, 'VVL.inv_enc(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ps, rep_v(items, ps, em), e)', 'inv_encv(Spec.@ESCH(), items, @WW, ps, rep_v(items, ps, em), e)')
    a0 = t.index('\ndef inv0(')
    t = t[:a0] + t[t.index('\n\n', a0 + 1):]
    hdefs = VEC_DEFS[:VEC_DEFS.index('# What the vector')]
    t = rep1(t, '\ndef invl(', VEC_DEFS[VEC_DEFS.index('# What the vector'):] + '\ndef invl(')
    t = hdefs + t
    t = t.replace('Spec.@SCH()', f'S.Vector{{@ESCHT, @Nn}}').replace('Spec.@ESCH()', '@ESCHT')
    return t


def vvec_text(P, NV, E, EO, ymod, escht, efields):
    mp = {'@ESCHT': escht, '@EFIELDS': efields, '@P': P, '@E': E, '@ET': f'O.Boxed<{EO}>', '@EO': EO, '@BF': 'UA.BF(t, n)', '@P4': P4, '@WHX': WHX, '@PF': PF,
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@MP': 'Maybe<&2, +List<S.Part>>', '@WW': 'UW.WX(t, x, U32.to_nat(len))', '@SGL': 'esingle(h)',
          '@FN': str(4 * NV), '@Nn': f'{NV}n', '@LIM': str(NV)}
    inv = VL_INV
    for a, b in inv_rows().items():
        inv = inv.replace(a, b)
    head = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
            for x in HEAD]
    L = head + ['import ../../types/primitive.bend as P', 'import ../../proofs/decode_facts.bend as DF', 'import ./vvl.bend as VVL', 'import ./vvlr.bend as VVR',
                'import ./big_vvlu.bend as VVU', 'import ./vbx2.bend as VX2', 'import ./vrej.bend as VR', 'import ./vdig.bend as VG', 'import ./vnest.bend as VN',
                'import ./vfits.bend as VFT', 'import ../../src/primitives.bend as I', f'import ./{ymod}.bend as YW', '',
                '# GENERATED by codegen/var_vlist.py. Do not edit.',
                f'# {P} (a vector of {NV} variable-size {E}) at a window at ANY byte offset: the',
                '# interface of proofs/obj/vua_win.bend (see codegen/var_vlist.py).', '']
    return '\n'.join(L) + T_(vec(VL_VALID + VL_READ + VL_SPEC + VL_BYTES + VL_ASM + inv, escht), mp)


def main():
    out = {}
    nb = '--no-big' in sys.argv
    if not nb:
        out[ROOT / 'proofs/obj/big_vvlz.bend'] = zg_text()
        for p, N, sch in BYTELISTS:
            out[bl_fname(p)] = bl_text(p, N, sch)
        for p, N in GBYTELISTS:
            out[gbl_fname(p)] = gbl_text(p, N)
        for P, LIM, E, ymod, sch, esch in VLISTS:
            out[vl_fname(P)] = vl_text(P, LIM, E, ymod, sch, esch)
        for P, E, EO, ymod, escht, efields in PVLISTS:
            out[vl_fname(P)] = vlp_text(P, E, EO, ymod, escht, efields)
        for P, NV, E, EO, ymod, escht, efields in VVECS:
            out[vl_fname(P)] = vvec_text(P, NV, E, EO, ymod, escht, efields)
    # only files this generator wrote (another generator may name a file *vvl*_*)
    def foreign(q):
        m = re.search(r'# GENERATED by (codegen/[\w/]+\.py)', q.read_text()[:8000])
        return m is not None and m.group(1) != 'codegen/var_vlist.py'
    mine = [q for q in sorted((ROOT / 'proofs/obj').glob('*vvl*_*.bend')) if not foreign(q)]
    orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out and not (nb and q.name.startswith('big_'))]
    if '--check' in sys.argv:
        stale = [str(q.relative_to(ROOT)) for q, text in out.items() if not q.exists() or q.read_text() != text]
        if stale or orphans:
            print('stale generated variable-element list windows: ' + ', '.join(stale + orphans))
            sys.exit(1)
        print('generated variable-element list windows are current')
        return
    for q, text in out.items():
        q.write_text(text)
    for q in orphans:
        (ROOT / q).unlink()
    print(', '.join(str(q.relative_to(ROOT)) for q in out))


if __name__ == '__main__':
    main()
