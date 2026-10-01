#!/usr/bin/env python3
"""Spec-connected codec laws of variable-size names with SEVERAL variable fields.

    python3 codegen/proofs/var/var_multi.py [--check]

Covered: DataColumnSidecar (a uint64, three lists of byte vectors held as packed
words -- Cell = 512 words, KZGCommitment / KZGProof = 12 words, 4096 elements at
most -- a boxed SignedBeaconBlockHeader and a Vector[Bytes32, 4]).

Writes proofs/obj/vmul.bend (from codegen/templates/vmul.bend.in: the spec side of a list of
byte vectors of E words, for every E, k and word list), proofs/obj/var_fix_types_m.bend
(the reader/writer lemmas of the fixed field types, codegen/proofs/var/var_laws.py's rd/put
lemmas) and proofs/obj/var_codec_<X>{,_unique,_rej,_enc}.bend with the law set of
codegen/proofs/var/var_laws.py (ok_eval, decode_accept, decode_spec, decode_unique,
decode_reject, decode_none, encode_eval, encode_spec).

The buffer laws quantify over every buffer B.Buf{thaw(t), n} on a perfect word
tree of depth d < 23 (16 MiB; the list storage the decoder allocates then has
depth at most 23, whose zero arrays stock Bend compares case by case), n <= 4 2^d.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys
from codegen.core import writer  # noqa: E402

from codegen.impl import generate as G  # noqa: E402
from codegen.core import schema  # noqa: E402
from codegen.proofs.var import var_laws as VLW  # noqa: E402

from codegen.core.paths import ROOT  # noqa: E402
X = 'DataColumnSidecar'

DEC_HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
            'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
            'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
            'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
            'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/nat_bytes.bend as N',
            'import ../../spec/fulu_schemas.bend as Spec', 'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS',
            'import ./vbuf.bend as VB', 'import ./vu32.bend as VU', 'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD',
            'import ./vfix.bend as VF', 'import ./vlist.bend as VL', 'import ./vmul.bend as VM', 'import ./vmv.bend as VV']


def readers_deep(text):
    """The fixed field readers (rd_*) at any depth d < 31 (they took d < 29): the offset sums of a field's words
    by VF.off_add32 (a word's index below 2^d, k + i < 2^d, hence 4 (k + i) < 2^32 for d < 31)."""
    from codegen.proofs.support import deep
    out = []
    for blk in re.split(r'\n(?=def |law )', text):
        if blk.startswith('def rd_'):
            i = 0
            while True:
                j = blk.find('VF.off_add(', i)
                if j < 0:
                    break
                args, e = deep._args(blk, j + len('VF.off_add('))
                assert len(args) == 9 and args[4] == '2n+d' and args[7] == 'hd' and args[8].startswith('VF.in_q('), args
                iq, _ = deep._args(args[8], len('VF.in_q('))
                inner = iq[3]
                if inner.startswith('VF.lt_le1('):
                    a4, _ = deep._args(inner, len('VF.lt_le1('))
                    x = a4[3]
                else:
                    assert inner.startswith('VF.in_le(0n, '), inner
                    a6, _ = deep._args(inner, len('VF.in_le('))
                    x = f'VF.in_lt({a6[1]}, {a6[2]}, {a6[3]}, {a6[4]}, {{==}}, {a6[6]})'
                    assert a6[5] == '{==}' and a6[0] == '0n', a6
                new = 'VF.off_add32(' + ', '.join(args[:4] + ['d', 'e', '{==}', 'hd', x]) + ')'
                blk = blk[:j] + new + blk[e:]
                i = j + len(new)
            blk = blk.replace('+hd: {Nat.is_lt(d, 29n) == True{} : Bool}', '+hd: {Nat.is_lt(d, 31n) == True{} : Bool}')
            blk = blk.replace('VB.lt32(d, F.nat__lt_trans(d, 29n, 31n, hd, {==}))', 'VB.lt32(d, hd)')
            assert 'd, 29n' not in blk and ', 2n+d,' not in blk, blk[:300]
        out.append(blk)
    return '\n'.join(out)


def fix_types(g, names):
    fts = []
    for f, ft in names[X].fields:
        if ft.fixed() and ft.kind == 'container':
            for d in VLW.FT(g, ft).deps():
                if d.p not in [x.p for x in fts]:
                    fts.append(d)
    u = VLW.FT(g, names[X].fields[0][1])
    if u.p not in [x.p for x in fts]:
        fts.insert(0, u)
    return writer.rebrand(readers_deep(VLW.fix_module(fts)), 'var_laws', 'var_multi', 'var_laws fix_module')


ZK = 23


def zeros_text():
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../compact/found.bend as FD', '',
         '# GENERATED by var_multi (codegen). Do not edit.',
         f'# The runtime zero array of depth k <= {ZK} is Array.new(U32, k, 0), case by case. The cases are a',
         '# chain on Nat.is_eq(k, j), not a match on k: a literal case leaves its own form of j in the goal, and',
         f'# comparing it to the literal would build and compare the closed trees of up to 2^{ZK} leaves.', '',
         '# a <= b and b != a give a + 1 <= b.',
         'def lesucc(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}, +n: {Nat.is_eq(b, a) == False{} : Bool}) -> {Nat.is_le(1n+a, b) == True{} : Bool}:',
         '  match a b:',
         '    case 0n 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, FD.logic__false_true(Equal.sym(Bool, True{}, False{}, n)))',
         '    case 0n 1n+q: FD.nat__zero_le(q)',
         '    case 1n+p 0n: Empty.absurd({Nat.is_le(2n+p, 0n) == True{} : Bool}, FD.logic__false_true(h))',
         '    case 1n+p 1n+q: lesucc(p, q, h, n)', '']
    Z = '{B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}'
    P = '+du: U32, +k: Nat, +e: {U32.to_nat(du) == k : Nat}, +hk: {Nat.is_le(k, %dn) == True{} : Bool}' % ZK
    L += [f'def zat{ZK + 1}({P}, +hge: {{Nat.is_le({ZK + 1}n, k) == True{{}} : Bool}}) -> {Z}:',
          f'  Empty.absurd({Z}, FD.logic__false_true(FD.nat__le_trans({ZK + 1}n, k, {ZK}n, hge, hk)))', '']
    for j in range(ZK, -1, -1):
        L += [f'def zat{j}({P}, +hge: {{Nat.is_le({j}n, k) == True{{}} : Bool}}, +b: Bool, +eb: {{Nat.is_eq(k, {j}n) == b : Bool}}) -> {Z}:',
              '  match b:',
              '    case True{}:',
              f'      +ek = FD.nat__eq_from_is_eq(k, {j}n, eb)',
              f'      %Equal.sym(Nat, k, {j}n, ek) : {{B.zeros(du) == Array.new(U32, _, 0) : Array<U32>}}',
              f'      %Equal.sym(U32, du, {j}, FD.u32__injective(du, {j}, Equal.trans(Nat, U32.to_nat(du), k, {j}n, e, ek))) :',
              f'        {{B.zeros(_) == Array.new(U32, {j}n, 0) : Array<U32>}}',
              '      {==}',
              (f'    case False{{}}: zat{j + 1}(du, k, e, hk, lesucc({j}n, k, hge, eb))' if j == ZK else
               f'    case False{{}}: zat{j + 1}(du, k, e, hk, lesucc({j}n, k, hge, eb), Nat.is_eq(k, {j + 1}n), {{==}})'), '']
    L += [f'def zat({P})', f'    -> {Z}:', '  zat0(du, k, e, hk, FD.nat__zero_le(k), Nat.is_eq(k, 0n), {==})']
    return '\n'.join(L) + '\n'


def dec_text(g, names):
    L = list(DEC_HEAD) + ['import ./vvlz.bend as VZG', '', '# GENERATED by var_multi (codegen). Do not edit.',
                          f'# {X}: the validator, the decoder, and the spec relation of the decoded value',
                          '# (see the module docstring of codegen/proofs/var/var_multi.py).', '']
    facts, reader = acc_text(g, names)
    L.append(DEC_BODY)
    L.append(facts)
    L.append(TPL('var_multi_facts.bend.in'))
    L.append(spec_text(g, names))
    return '\n'.join(L) + '\n'


def TPL(name):
    return (ROOT / 'codegen/templates' / name).read_text()


def prefixed(text, main):
    """Qualify the calls of the main module's definitions by DC."""
    names = set(re.findall(r'^(?:def|law) (\w+)', main, re.M))
    return re.sub(r'(?<![\w.])(\w+)\(', lambda m: ('DC.' if m.group(1) in names else '') + m.group(0), text)


def acc_file(g, names):
    main = dec_text(g, names)
    facts, reader = acc_text(g, names)
    L = list(DEC_HEAD) + ['import ./vzeros.bend as VZ', 'import ./var_fix_types_m.bend as VT', f'import ./var_codec_{X}.bend as DC', '',
                          '# GENERATED by var_multi (codegen). Do not edit.',
                          f'# {X}: the reader, and acceptance: every buffer the validator accepts decodes to OBJ(t, n).', '']
    L.append(prefixed(reader, main))
    return '\n'.join(L) + '\n'


DEC_BODY = r'''def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{FD.array__thaw(U32, t), n}

def rd32(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(BF(t, n), q) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, t), q), (FD.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, q, i, eq, hd, hi, pf)) :
    {B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  {==}

# ---- the validator ----------------------------------------------------------------------------

# the three list offsets
def O0(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 2n)
def O1(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 3n)
def O2(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 4n)

# a list of whole elements of b bytes, at most lim of them
def WH(+L: U32, +b: U32, +lim: U32) -> Bool: Bool.and(U32.is_eq(L, (U32.div(L, b) * b : U32)), U32.is_le(U32.div(L, b), lim))

def L0(+t: FD.array__Tree<U32>) -> U32: U32.sub(O1(t), O0(t))
def L1(+t: FD.array__Tree<U32>) -> U32: U32.sub(O2(t), O1(t))
def L2(+t: FD.array__Tree<U32>, +n: U32) -> U32: U32.sub(n, O2(t))

def CA(+n: U32) -> Bool: U32.is_le(356, n)
def CB(+t: FD.array__Tree<U32>) -> Bool: U32.is_eq(O0(t), 356)
def CC(+t: FD.array__Tree<U32>, +n: U32) -> Bool: Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n))
def CD(+t: FD.array__Tree<U32>, +n: U32) -> Bool: Bool.and(U32.is_le(O1(t), O2(t)), U32.is_le(O2(t), n))
def CE(+t: FD.array__Tree<U32>) -> Bool: WH(L0(t), 2048, 4096)
def CF(+t: FD.array__Tree<U32>) -> Bool: WH(L1(t), 48, 4096)
def CG(+t: FD.array__Tree<U32>, +n: U32) -> Bool: WH(L2(t, n), 48, 4096)

# the checks, in the validator's order
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool:
  Bool.and(CA(n), Bool.and(CB(t), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))))

def okG(+t: FD.array__Tree<U32>, +n: U32, +g: Bool)
    -> {T.DataColumnSidecar_c5(g, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), g) : B.Buf & Bool}:
  match g:
    case True{}: {==}
    case False{}: {==}

def okF(+t: FD.array__Tree<U32>, +n: U32, +f: Bool)
    -> {T.DataColumnSidecar_c4(f, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), Bool.and(f, CG(t, n))) : B.Buf & Bool}:
  match f:
    case True{}: okG(t, n, CG(t, n))
    case False{}: {==}

def okE(+t: FD.array__Tree<U32>, +n: U32, +e: Bool)
    -> {T.DataColumnSidecar_c3(e, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), Bool.and(e, Bool.and(CF(t), CG(t, n)))) : B.Buf & Bool}:
  match e:
    case True{}: okF(t, n, CF(t))
    case False{}: {==}

def okD(+t: FD.array__Tree<U32>, +n: U32, +c: Bool)
    -> {T.DataColumnSidecar_c2(c, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), Bool.and(c, Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))) : B.Buf & Bool}:
  match c:
    case True{}: okE(t, n, CE(t))
    case False{}: {==}

def okC(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +c: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnSidecar_c1(c, BF(t, n), 0, n, O0(t), O1(t)) == (BF(t, n), Bool.and(c, Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))) : B.Buf & Bool}:
  match c:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 4), (BF(t, n), O2(t)), rd32(d, t, n, 4, 4n, {==}, hd, hpo, pf)) :
        {T.DataColumnSidecar_v2(0, n, O0(t), O1(t), _) == (BF(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))) : B.Buf & Bool}
      okD(t, n, CD(t, n))
    case False{}: {==}

def okB(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +b: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnSidecar_c0(b, BF(t, n), 0, n, O0(t)) == (BF(t, n), Bool.and(b, Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))))) : B.Buf & Bool}:
  match b:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 3), (BF(t, n), O1(t)), rd32(d, t, n, 3, 3n, {==}, hd, FD.nat__lt_trans(3n, 4n, VB.pw(d), {==}, hpo), pf)) :
        {T.DataColumnSidecar_v1(0, n, O0(t), _) == (BF(t, n), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))) : B.Buf & Bool}
      okC(d, t, n, CC(t, n), hd, hpo, pf)
    case False{}: {==}

def okA(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +a: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnSidecar_ok_len(a, BF(t, n), 0, n) == (BF(t, n), Bool.and(a, Bool.and(CB(t), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))))) : B.Buf & Bool}:
  match a:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 2), (BF(t, n), O0(t)), rd32(d, t, n, 2, 2n, {==}, hd, FD.nat__lt_trans(2n, 4n, VB.pw(d), {==}, hpo), pf)) :
        {T.DataColumnSidecar_v0(0, n, _) == (BF(t, n), Bool.and(CB(t), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))))) : B.Buf & Bool}
      okB(d, t, n, CB(t), hd, hpo, pf)
    case False{}: {==}

# The validator returns the buffer and CHK(t, n).
law ok_eval:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +hd: {Nat.is_lt(d, 32n) == True{} : Bool}
  for +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  {T.DataColumnSidecar_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}
def ok_eval(d, t, n, hd, hpo, pf): okA(d, t, n, CA(n), hd, hpo, pf)
'''


def acc_text(g, names):
    t = names[X]
    hdr = VLW.FT(g, t.fields[4][1])
    HW = [f'VB.slot(t, {5 + k}n)' for k in range(hdr.W)]
    HOBJ = hdr.obj(HW)
    Lw = lambda i: f'O.Words{{FD.array__thaw(U32, VB.mone(VC.NW({LN[i]}), {QI[i]}, 0n, VL.DZ({LN[i]}), VC.ZT(VL.DZ({LN[i]})), t)), {LN[i]}}}'
    LN = ['L0(t)', 'L1(t)', 'L2(t, n)']
    QI = ['89n', 'Q1(t)', 'Q2(t)']
    OBJ = (f'T.{X}{{O.U64{{VB.slot(t, 0n), VB.slot(t, 1n)}}, {Lw(0)}, {Lw(1)}, {Lw(2)}, O.BSome{{{HOBJ}, O.BNone{{}}}}, '
           f'O.Words{{FD.array__thaw(U32, VB.mone(32n, 57n, 0n, 6n, VC.ZT(6n), t)), 128}}}}')
    RT = f'B.Buf & T.{X}'
    HY = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},\n'
          '    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}')
    HYA = 'd, t, n, pf, hd, hn'
    FACTS = ('+hb: {CB(t) == True{} : Bool}, +hc: {CC(t, n) == True{} : Bool}, +hdd: {CD(t, n) == True{} : Bool},\n'
             '    +he: {CE(t) == True{} : Bool}, +hf: {CF(t) == True{} : Bool}, +hg: {CG(t, n) == True{} : Bool}')
    FA = 'hb, hc, hdd, he, hf, hg'
    W = []
    w = W.append
    w(f"""
# ---- acceptance ---------------------------------------------------------------------------------

def v2048() -> Word(31n): FD.spec_numeric__from_nat(31n, 2048n)
def v48() -> Word(31n): FD.spec_numeric__from_nat(31n, 48n)

# the element counts, the lists' word counts, the lists' first words
def C0(+t: FD.array__Tree<U32>) -> Nat: U32.to_nat(U32.div(L0(t), 2048))
def C1(+t: FD.array__Tree<U32>) -> Nat: U32.to_nat(U32.div(L1(t), 48))
def C2(+t: FD.array__Tree<U32>, +n: U32) -> Nat: U32.to_nat(U32.div(L2(t, n), 48))
def M0(+t: FD.array__Tree<U32>) -> Nat: VM.mulE(512n, C0(t))
def M1(+t: FD.array__Tree<U32>) -> Nat: VM.mulE(12n, C1(t))
def M2(+t: FD.array__Tree<U32>, +n: U32) -> Nat: VM.mulE(12n, C2(t, n))
def Q1(+t: FD.array__Tree<U32>) -> Nat: Nat.add(89n, M0(t))
def Q2(+t: FD.array__Tree<U32>) -> Nat: Nat.add(Q1(t), M1(t))
def QN(+t: FD.array__Tree<U32>, +n: U32) -> Nat: Nat.add(Q2(t), M2(t, n))

def eL0(+t: FD.array__Tree<U32>, +h: {{CE(t) == True{{}} : Bool}}) -> {{U32.to_nat(L0(t)) == A.quad(M0(t)) : Nat}}:
  Equal.trans(Nat, U32.to_nat(L0(t)), Nat.mul(C0(t), U32.to_nat(2048)), A.quad(M0(t)),
    Pair.fst({{U32.to_nat(L0(t)) == Nat.mul(C0(t), U32.to_nat(2048)) : Nat}}, {{Nat.is_le(C0(t), U32.to_nat(4096)) == True{{}} : Bool}}, VU.whole_t(L0(t), 2048, 4096, v2048(), {{==}}, {{==}}, {{==}}, h)),
    VM.mulq(C0(t), 512n))

def eL1(+t: FD.array__Tree<U32>, +h: {{CF(t) == True{{}} : Bool}}) -> {{U32.to_nat(L1(t)) == A.quad(M1(t)) : Nat}}:
  Equal.trans(Nat, U32.to_nat(L1(t)), Nat.mul(C1(t), U32.to_nat(48)), A.quad(M1(t)),
    Pair.fst({{U32.to_nat(L1(t)) == Nat.mul(C1(t), U32.to_nat(48)) : Nat}}, {{Nat.is_le(C1(t), U32.to_nat(4096)) == True{{}} : Bool}}, VU.whole_t(L1(t), 48, 4096, v48(), {{==}}, {{==}}, {{==}}, h)),
    VM.mulq(C1(t), 12n))

def eL2(+t: FD.array__Tree<U32>, +n: U32, +h: {{CG(t, n) == True{{}} : Bool}}) -> {{U32.to_nat(L2(t, n)) == A.quad(M2(t, n)) : Nat}}:
  Equal.trans(Nat, U32.to_nat(L2(t, n)), Nat.mul(C2(t, n), U32.to_nat(48)), A.quad(M2(t, n)),
    Pair.fst({{U32.to_nat(L2(t, n)) == Nat.mul(C2(t, n), U32.to_nat(48)) : Nat}}, {{Nat.is_le(C2(t, n), U32.to_nat(4096)) == True{{}} : Bool}}, VU.whole_t(L2(t, n), 48, 4096, v48(), {{==}}, {{==}}, {{==}}, h)),
    VM.mulq(C2(t, n), 12n))

def eO1(+t: FD.array__Tree<U32>, +n: U32, +hb: {{CB(t) == True{{}} : Bool}}, +hc: {{CC(t, n) == True{{}} : Bool}}, +he: {{CE(t) == True{{}} : Bool}})
    -> {{U32.to_nat(O1(t)) == A.quad(Q1(t)) : Nat}}:
  +s = VM.sub_eq(O1(t), O0(t), FD.logic__and_left(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), hc))
  %s : {{_ == A.quad(Q1(t)) : Nat}}
  %Equal.sym(U32, O0(t), 356, FD.u32alg__eq_of(O0(t), 356, hb)) : {{Nat.add(U32.to_nat(_), U32.to_nat(L0(t))) == A.quad(Q1(t)) : Nat}}
  %Equal.sym(Nat, U32.to_nat(L0(t)), A.quad(M0(t)), eL0(t, he)) : {{Nat.add(U32.to_nat(356), _) == A.quad(Q1(t)) : Nat}}
  Equal.sym(Nat, A.quad(Q1(t)), Nat.add(A.quad(89n), A.quad(M0(t))), VM.quad_add(89n, M0(t)))

def eO2(+t: FD.array__Tree<U32>, +n: U32, +hb: {{CB(t) == True{{}} : Bool}}, +hc: {{CC(t, n) == True{{}} : Bool}}, +hdd: {{CD(t, n) == True{{}} : Bool}},
    +he: {{CE(t) == True{{}} : Bool}}, +hf: {{CF(t) == True{{}} : Bool}})
    -> {{U32.to_nat(O2(t)) == A.quad(Q2(t)) : Nat}}:
  +s = VM.sub_eq(O2(t), O1(t), FD.logic__and_left(U32.is_le(O1(t), O2(t)), U32.is_le(O2(t), n), hdd))
  %s : {{_ == A.quad(Q2(t)) : Nat}}
  %Equal.sym(Nat, U32.to_nat(O1(t)), A.quad(Q1(t)), eO1(t, n, hb, hc, he)) : {{Nat.add(_, U32.to_nat(L1(t))) == A.quad(Q2(t)) : Nat}}
  %Equal.sym(Nat, U32.to_nat(L1(t)), A.quad(M1(t)), eL1(t, hf)) : {{Nat.add(A.quad(Q1(t)), _) == A.quad(Q2(t)) : Nat}}
  Equal.sym(Nat, A.quad(Q2(t)), Nat.add(A.quad(Q1(t)), A.quad(M1(t))), VM.quad_add(Q1(t), M1(t)))

def eN(+t: FD.array__Tree<U32>, +n: U32, {FACTS})
    -> {{U32.to_nat(n) == A.quad(QN(t, n)) : Nat}}:
  +s = VM.sub_eq(n, O2(t), FD.logic__and_right(U32.is_le(O1(t), O2(t)), U32.is_le(O2(t), n), hdd))
  %s : {{_ == A.quad(QN(t, n)) : Nat}}
  %Equal.sym(Nat, U32.to_nat(O2(t)), A.quad(Q2(t)), eO2(t, n, hb, hc, hdd, he, hf)) : {{Nat.add(_, U32.to_nat(L2(t, n))) == A.quad(QN(t, n)) : Nat}}
  %Equal.sym(Nat, U32.to_nat(L2(t, n)), A.quad(M2(t, n)), eL2(t, n, hg)) : {{Nat.add(A.quad(Q2(t)), _) == A.quad(QN(t, n)) : Nat}}
  Equal.sym(Nat, A.quad(QN(t, n)), Nat.add(A.quad(Q2(t)), A.quad(M2(t, n))), VM.quad_add(Q2(t), M2(t, n)))

# QN <= 2^d: the header and the three lists lie in the buffer
def hQN({HY}, {FACTS})
    -> {{Nat.is_le(QN(t, n), VB.pw(d)) == True{{}} : Bool}}:
  VC.quad_inv(QN(t, n), VB.pw(d), FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(n), A.quad(QN(t, n)), eN(t, n, {FA}), hn))

# ---- the lists' storage from the buffer's size: n <= NMAX gives 31 + L <= UMAX for every list ----

def hnN(+n: U32, +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}}) -> {{Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le(n, VB.NMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())), VB.le_u32n(n, VB.NMAX()), hN)

# a list of quad(m) bytes, m <= Q, lies within the n = quad(Q) bytes of the buffer
def hLn(+n: U32, +L: U32, +m: Nat, +Q: Nat, +em: {{U32.to_nat(L) == A.quad(m) : Nat}}, +eN: {{U32.to_nat(n) == A.quad(Q) : Nat}}, +hm: {{Nat.is_le(m, Q) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(0n, U32.to_nat(L)), U32.to_nat(n)) == True{{}} : Bool}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(0n, z), U32.to_nat(n)) == True{{}} : Bool}}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em),
    FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(0n, A.quad(m)), z) == True{{}} : Bool}}, A.quad(Q), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), A.quad(Q), eN),
      FD.nat__double_le(Nat.double(m), Nat.double(Q), FD.nat__double_le(m, Q, hm))))

def hy0(+t: FD.array__Tree<U32>, +n: U32, {FACTS}, +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}})
    -> {{Nat.is_le(VC.YL(L0(t)), U32.to_nat(VB.UMAX())) == True{{}} : Bool}}:
  VC.hyW(0n, L0(t), FD.nat__le_trans(Nat.add(0n, U32.to_nat(L0(t))), U32.to_nat(n), U32.to_nat(VB.NMAX()),
    hLn(n, L0(t), M0(t), QN(t, n), eL0(t, he), eN(t, n, {FA}),
      FD.nat__le_trans(M0(t), Q1(t), QN(t, n), Order.left_below_sum(89n, M0(t)), FD.nat__le_trans(Q1(t), Q2(t), QN(t, n), Order.below_sum(Q1(t), M1(t)), Order.below_sum(Q2(t), M2(t, n))))),
    hnN(n, hN)))

def hy1(+t: FD.array__Tree<U32>, +n: U32, {FACTS}, +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}})
    -> {{Nat.is_le(VC.YL(L1(t)), U32.to_nat(VB.UMAX())) == True{{}} : Bool}}:
  VC.hyW(0n, L1(t), FD.nat__le_trans(Nat.add(0n, U32.to_nat(L1(t))), U32.to_nat(n), U32.to_nat(VB.NMAX()),
    hLn(n, L1(t), M1(t), QN(t, n), eL1(t, hf), eN(t, n, {FA}),
      FD.nat__le_trans(M1(t), Q2(t), QN(t, n), Order.left_below_sum(Q1(t), M1(t)), Order.below_sum(Q2(t), M2(t, n)))),
    hnN(n, hN)))

def hy2(+t: FD.array__Tree<U32>, +n: U32, {FACTS}, +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}})
    -> {{Nat.is_le(VC.YL(L2(t, n)), U32.to_nat(VB.UMAX())) == True{{}} : Bool}}:
  VC.hyW(0n, L2(t, n), FD.nat__le_trans(Nat.add(0n, U32.to_nat(L2(t, n))), U32.to_nat(n), U32.to_nat(VB.NMAX()),
    hLn(n, L2(t, n), M2(t, n), QN(t, n), eL2(t, n, hg), eN(t, n, {FA}),
      Order.left_below_sum(Q2(t), M2(t, n))),
    hnN(n, hN)))

# the zero array of the list storage, at any depth
def ezd(+L: U32) -> {{B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, VL.DZ(L), 0) : Array<U32>}}:
  FD.logic__subst(Nat, z => {{B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, z, 0) : Array<U32>}}, U32.to_nat(B.words_depth_u(VC.WZ(L))), VL.DZ(L),
    VD.wdu(VC.WZ(L)), VZG.zg(B.words_depth_u(VC.WZ(L))))

# the list's words, from word q on, lie in the buffer
def hsgD(+d: Nat, +L: U32, +m: Nat, +q: Nat, +em: {{U32.to_nat(L) == A.quad(m) : Nat}}, +h: {{Nat.is_le(Nat.add(q, m), VB.pw(d)) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(VC.NW(L), q), VB.pw(d)) == True{{}} : Bool}}:
  %Equal.sym(Nat, VC.NW(L), m, VL.nwmA(L, m, em)) : {{Nat.is_le(Nat.add(_, q), VB.pw(d)) == True{{}} : Bool}}
  %FD.nat__add_comm(q, m) : {{Nat.is_le(_, VB.pw(d)) == True{{}} : Bool}}
  h
""")
    nf = len(W)
    # ---- the reader ----
    LWg = lambda i, dz: f'O.Words{{FD.array__thaw(U32, VB.mone(VC.NW({LN[i]}), {QI[i]}, 0n, {dz}, VC.ZT({dz}), t)), {LN[i]}}}'
    UO = 'O.U64{VB.slot(t, 0n), VB.slot(t, 1n)}'
    PV = 'O.Words{FD.array__thaw(U32, VB.mone(32n, 57n, 0n, 6n, VC.ZT(6n), t)), 128}'
    OBJg = f'T.{X}{{{UO}, {LWg(0, "dz0")}, {LWg(1, "dz1")}, {LWg(2, "dz2")}, O.BSome{{{HOBJ}, O.BNone{{}}}}, {PV}}}'
    R = f'(BF(t, n), {OBJg})'
    OO = 'O0(t), O1(t), O2(t)'
    RP = lambda k, args: f'{{T.{X}_rd{k}(0, n, {args}) == {R} : {RT}}}'
    w(f"""
def rd_ok(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, 31n) == True{{}} : Bool}},
    +dz0: Nat, +dz1: Nat, +dz2: Nat,
    +hdz0: {{Nat.is_lt(dz0, 31n) == True{{}} : Bool}}, +hdz1: {{Nat.is_lt(dz1, 31n) == True{{}} : Bool}}, +hdz2: {{Nat.is_lt(dz2, 31n) == True{{}} : Bool}},
    +ez0: {{B.zeros(B.words_depth_u(VC.WZ(L0(t)))) == Array.new(U32, dz0, 0) : Array<U32>}},
    +ez1: {{B.zeros(B.words_depth_u(VC.WZ(L1(t)))) == Array.new(U32, dz1, 0) : Array<U32>}},
    +ez2: {{B.zeros(B.words_depth_u(VC.WZ(L2(t, n)))) == Array.new(U32, dz2, 0) : Array<U32>}},
    +eo0: {{O0(t) == 356 : U32}}, +e1: {{U32.to_nat(O1(t)) == A.quad(Q1(t)) : Nat}}, +e2: {{U32.to_nat(O2(t)) == A.quad(Q2(t)) : Nat}},
    +l3a: {{U32.and(L0(t), 3) == 0 : U32}}, +l3b: {{U32.and(L1(t), 3) == 0 : U32}}, +l3c: {{U32.and(L2(t, n), 3) == 0 : U32}},
    +hs0: {{Nat.is_le(Nat.add(VC.NW(L0(t)), 89n), VB.pw(d)) == True{{}} : Bool}},
    +hs1: {{Nat.is_le(Nat.add(VC.NW(L1(t)), Q1(t)), VB.pw(d)) == True{{}} : Bool}},
    +hs2: {{Nat.is_le(Nat.add(VC.NW(L2(t, n)), Q2(t)), VB.pw(d)) == True{{}} : Bool}},
    +hr0: {{Nat.is_le(Nat.add(VC.NW(L0(t)), 0n), VB.pw(dz0)) == True{{}} : Bool}},
    +hr1: {{Nat.is_le(Nat.add(VC.NW(L1(t)), 0n), VB.pw(dz1)) == True{{}} : Bool}},
    +hr2: {{Nat.is_le(Nat.add(VC.NW(L2(t, n)), 0n), VB.pw(dz2)) == True{{}} : Bool}},
    +h89: {{Nat.is_le(89n, VB.pw(d)) == True{{}} : Bool}})
    -> {{T.{X}_read(BF(t, n), 0, n) == {R} : {RT}}}:
  +hd29 = hd
  +hd31 = hd
  +hd32 = VB.lt32(d, hd31)
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 2), (BF(t, n), O0(t)), rd32(d, t, n, 2, 2n, {{==}}, hd32, FD.nat__lt_le_trans(2n, 89n, VB.pw(d), {{==}}, h89), pf)) :
    {RP(0, "_")}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 3), (BF(t, n), O1(t)), rd32(d, t, n, 3, 3n, {{==}}, hd32, FD.nat__lt_le_trans(3n, 89n, VB.pw(d), {{==}}, h89), pf)) :
    {RP(1, "O0(t), _")}
  %Equal.sym(B.Buf & U32, B.word(BF(t, n), 4), (BF(t, n), O2(t)), rd32(d, t, n, 4, 4n, {{==}}, hd32, FD.nat__lt_le_trans(4n, 89n, VB.pw(d), {{==}}, h89), pf)) :
    {RP(2, "O0(t), O1(t), _")}
  %Equal.sym(B.Buf & O.U64, T.u64_read(BF(t, n), U32.add(0, 0), 8), (BF(t, n), {UO}),
      VT.rd_u64(d, t, n, U32.add(0, 0), 0n, {{==}}, hd29, pf, FD.nat__le_trans(2n, 89n, VB.pw(d), {{==}}, h89))) :
    {RP(3, OO + ", _")}
  %Equal.sym(U32, O0(t), 356, eo0) :
    {RP(4, OO + ", " + UO + ", T.l4096_b2048_read(BF(t, n), U32.add(0, _), L0(t))")}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), U32.add(0, 356), L0(t)), (BF(t, n), {LWg(0, "dz0")}),
      VC.copy_in_ok(d, t, n, U32.add(0, 356), 89n, L0(t), dz0, pf, hd31, hdz0, ez0, {{==}}, {{==}}, l3a, hs0, hr0)) :
    {RP(4, OO + ", " + UO + ", _")}
  %Equal.sym(U32, U32.add(0, O1(t)), O1(t), FD.u32alg__zero_add(O1(t))) :
    {RP(5, OO + ", " + UO + ", " + LWg(0, "dz0") + ", T.l4096_b48_read(BF(t, n), _, L1(t))")}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), O1(t), L1(t)), (BF(t, n), {LWg(1, "dz1")}),
      VC.copy_in_ok(d, t, n, O1(t), Q1(t), L1(t), dz1, pf, hd31, hdz1, ez1, VL.and3_q(O1(t), Q1(t), e1), VM.shr_q(O1(t), Q1(t), e1), l3b, hs1, hr1)) :
    {RP(5, OO + ", " + UO + ", " + LWg(0, "dz0") + ", _")}
  %Equal.sym(U32, U32.add(0, O2(t)), O2(t), FD.u32alg__zero_add(O2(t))) :
    {RP(6, OO + ", " + UO + ", " + LWg(0, "dz0") + ", " + LWg(1, "dz1") + ", T.l4096_b48_read(BF(t, n), _, L2(t, n))")}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), O2(t), L2(t, n)), (BF(t, n), {LWg(2, "dz2")}),
      VC.copy_in_ok(d, t, n, O2(t), Q2(t), L2(t, n), dz2, pf, hd31, hdz2, ez2, VL.and3_q(O2(t), Q2(t), e2), VM.shr_q(O2(t), Q2(t), e2), l3c, hs2, hr2)) :
    {RP(6, OO + ", " + UO + ", " + LWg(0, "dz0") + ", " + LWg(1, "dz1") + ", _")}
  %Equal.sym(B.Buf & T.SignedBeaconBlockHeader, T.SignedBeaconBlockHeader_read(BF(t, n), U32.add(0, 20), 208), (BF(t, n), {HOBJ}),
      VT.rd_SignedBeaconBlockHeader(d, t, n, U32.add(0, 20), 5n, {{==}}, hd29, pf, FD.nat__le_trans(57n, 89n, VB.pw(d), {{==}}, h89))) :
    {RP(7, OO + ", " + UO + ", " + LWg(0, "dz0") + ", " + LWg(1, "dz1") + ", " + LWg(2, "dz2") + ", T.SignedBeaconBlockHeader_bx_rd(_)")}
  %Equal.sym(Array<U32>, Array.new(U32, 6n, 0), FD.array__thaw(U32, VC.ZT(6n)), FD.array__new(U32, 6n, 0)) :
    {RP(8, OO + ", " + UO + ", " + LWg(0, "dz0") + ", " + LWg(1, "dz1") + ", " + LWg(2, "dz2") + ", O.BSome{" + HOBJ + ", O.BNone{}}, O.copy_into(BF(t, n), U32.add(0, 228), 128, _)")}
  %Equal.sym(B.Buf & O.Words, O.copy_into(BF(t, n), U32.add(0, 228), 128, FD.array__thaw(U32, VC.ZT(6n))), (BF(t, n), {PV}),
      VC.ci_case(d, t, n, U32.add(0, 228), 57n, 128, 6n, pf, hd31, {{==}}, {{==}}, {{==}}, {{==}}, h89, {{==}}, U32.is_eq(128, 0), {{==}})) :
    {RP(8, OO + ", " + UO + ", " + LWg(0, "dz0") + ", " + LWg(1, "dz1") + ", " + LWg(2, "dz2") + ", O.BSome{" + HOBJ + ", O.BNone{}}, _")}
  {{==}}
""")
    w(TPL('var_multi_acc.bend.in').replace('@OBJ', OBJ).replace('@X', X))
    return '\n'.join(W[:nf]), '\n'.join(W[nf:])


def spec_text(g, names):
    """The spec side: the value of the buffer, its encoding (vmv.enc3), and decode_spec."""
    t = names[X]
    word = lambda k: f'VB.slot(t, {k}n)'

    def node(ft, k0):
        nd = VLW.SL.walk(g, ft, iter(range(100000)))
        mp = {int(w_[1:]): word(k0 + j) for j, w_ in enumerate(nd.words)}
        return {'val': VLW.subst_words(nd.val, mp), 'sch': nd.sch, 'proof': VLW.subst_words(nd.proof, mp),
                'words': [mp[int(w_[1:])] for w_ in nd.words]}
    IDX, HDR, PV = node(t.fields[0][1], 0), node(t.fields[4][1], 5), node(t.fields[5][1], 57)
    assert len(IDX['words']) == 2 and len(HDR['words']) == 52 and len(PV['words']) == 32
    wl = lambda ws: '[' + ', '.join(ws) + ']'
    AW = wl(IDX['words'])
    POST = '[' + wl(HDR['words']) + ', ' + wl(PV['words']) + ']'
    LN = ['L0(t)', 'L1(t)', 'L2(t, n)']
    CN = ['C0(t)', 'C1(t)', 'C2(t, n)']
    WLN = ['WL0(t)', 'WL1(t)', 'WL2(t, n)']
    YN = ['Y0(t)', 'Y1(t)', 'Y2(t, n)']
    EB = [(512, 2048), (12, 48), (12, 48)]
    vals = [IDX['val']] + [f'S.Sequence{{VM.bvit({CN[i]}, {EB[i][0]}n, {WLN[i]})}}' for i in range(3)] + [HDR['val'], PV['val']]
    schs = [IDX['sch']] + [f'S.ListOf{{S.ByteVector{{{EB[i][1]}n}}, U32.to_nat(4096)}}' for i in range(3)] + [HDR['sch'], PV['sch']]
    parts = ([f'S.Fixed{{F.limbs({AW})}}'] + [f'S.Variable{{F.limbs({YN[i]})}}' for i in range(3)]
             + [f'S.Fixed{{F.limbs({wl(HDR["words"])})}}', f'S.Fixed{{F.limbs({wl(PV["words"])})}}'])
    fixed = {0: IDX, 4: HDR, 5: PV}

    def items(i):
        return 'S.EmptyItems{}' if i == 6 else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == 6 else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == 6:
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if i in fixed:
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs({wl(fixed[i]["words"])}), '
                    f'{rest}, {fixed[i]["proof"]}, {cat(i + 1)})')
        j = i - 1
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs({YN[j]}), {rest}, '
                f'VM.list_bv({CN[j]}, {EB[j][0]}n, {EB[j][1]}n, {WLN[j]}, U32.to_nat(4096), {{==}}, {{==}}, {{==}}, hk{j}, hl{j}, ft{j}), {cat(i + 1)})')
    HK = ', '.join(
        f'Pair.snd({{U32.to_nat({LN[j]}) == Nat.mul({CN[j]}, U32.to_nat({EB[j][1]})) : Nat}}, {{Nat.is_le({CN[j]}, U32.to_nat(4096)) == True{{}} : Bool}}, '
        f'VU.whole_t({LN[j]}, {EB[j][1]}, 4096, v{EB[j][1]}(), {{==}}, {{==}}, {{==}}, {["he", "hf", "hg"][j]}))' for j in range(3))
    acc = TPL('var_multi_acc.bend.in')
    fl = acc.splitlines()
    a = next(k for k, l in enumerate(fl) if l.startswith('  +hqn = '))
    b = next(k for k, l in enumerate(fl) if l.startswith('  +z2 = '))
    FACTS = '\n'.join(fl[a:b + 1])
    txt = TPL('var_multi_spec.bend.in')
    for k, v in [('@ITEMS', items(0)), ('@CHAIN', chain(0)), ('@PL', '[' + ', '.join(parts) + ']'), ('@CAT', cat(0)),
                 ('@AW', AW), ('@POST', POST), ('@HK', HK), ('@FACTS', FACTS), ('@X', X)]:
        txt = txt.replace(k, v)
    return txt


def unique_text():
    return f'''import Base
import ../../types/schema.bend as S
import ../../spec/decoding_relation.bend as Decoding
import ../../spec/fulu_schemas.bend as Spec
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./var_codec_{X}.bend as DC
import ../../proofs/decode_unique.bend as DCO

# GENERATED by var_multi (codegen). Do not edit.
# Every spec value of an accepted buffer's bytes is the buffer's value DC.VAL.
law decode_unique:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {{F.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 31n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}}
  for +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.{X}(), DC.VW(t, n), v)
  {{v == DC.VAL(t, n) : S.Value}}
def decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec):
  DCO.valid_unique(Spec.{X}(), DC.VW(t, n), v, DC.VAL(t, n), {{==}}, spec,
    DC.decode_spec(d, t, n, pf, hd, hn, hN, hchk))
'''


REJ_HEAD = ['import ../compact/bits.bend as BT', 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
            'import ./dk.bend as DK', 'import ./vrej.bend as VR', 'import ./vnest.bend as VN', 'import ./vdig.bend as VG', 'import ./vmr.bend as VMR',
            f'import ./var_codec_{X}.bend as DC']


def rej_file():
    """Rejection: the spec's image has the shape the validator checks (inversion down to
    vmr's layout of three variable parts), so a refused buffer is outside it; and the
    decoder returns None."""
    SCH = ['Spec.Schema3()', 'Spec.Schema114()', 'Spec.Schema103()', 'Spec.Schema103()', 'Spec.Schema30()', 'Spec.Schema90()']
    FIX = {0: ('x0', 'l0', 8), 4: ('xh', 'lh', 208), 5: ('xp', 'lp', 128)}
    VAR = {1: ('y0', 'f0', 2048), 2: ('y1', 'f1', 48), 3: ('y2', 'f2', 48)}
    VWt = 'DC.VW(t, n)'
    CTXT = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},\n'
            '    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool}')
    CTX = 'd, t, n, pf, hd, hn, hchk'

    def ch(i):
        return 'S.End{}' if i == 6 else f'S.Chain{{{SCH[i]}, {ch(i + 1)}}}'

    def part(j):
        return f'S.Fixed{{{FIX[j][0]}}}' if j in FIX else f'S.Variable{{{VAR[j][0]}}}'

    def cc(i, tail):
        out = tail
        for j in reversed(range(i)):
            out = f'Codec.concatenate(Some{{[{part(j)}]}}, {out})'
        return out

    def E(i, tail):
        return f'{{Codec.bytes(Codec.aggregate({cc(i, tail)}, None{{}})) == Some{{{VWt}}} : Maybe<&2, +List<U32>>}}'

    def acc_t(i):
        L = []
        for j in range(i):
            if j in FIX:
                x, l, w_ = FIX[j]
                L.append(f'+{x}: +List<U32>, +{l}: {{List.length(&2, U32, {x}) == {w_}n : Nat}}')
            else:
                y, f, b = VAR[j]
                L.append(f'+{y}: +List<U32>, {f}: VMR.LF({y}, {b}n, U32.to_nat(4096))')
        return ''.join(', ' + a for a in L)

    def acc_a(i):
        L = []
        for j in range(i):
            L += [FIX[j][0], FIX[j][1]] if j in FIX else [VAR[j][0], VAR[j][1]]
        return ''.join(', ' + a for a in L)
    NONE = f'FD.logic__none_some(+List<U32>, {VWt}, e)'
    CONS = ['S.BooleanValue{+b0}', 'S.UnsignedValue{+u0}', 'S.BytesValue{+xs0}', 'S.BitsValue{+bs0}', 'S.Sequence{+it0}',
            'S.Items{+hd0, +tl0}', 'S.EmptyItems{}', 'S.Selected{+sel0, +sv0}', 'S.NullValue{}']
    W = []
    w = W.append
    w(TPL('var_multi_rej.bend.in'))
    PS = f'[{part(0)}, {part(1)}, {part(2)}, {part(3)}, {part(4)}, {part(5)}]'
    w(f"""
def fin({CTXT}{acc_t(6)}, +b5: Bool,
    +e: {{Codec.bytes(Codec.one(SP.optional(b5, VMR.OUTR(x0, y0, y1, y2, [xh, xp])), None{{}})) == Some{{{VWt}}} : Maybe<&2, +List<U32>>}}) -> Empty:
  match b5:
    case False{{}}: {NONE}
    case True{{}}: contra({CTX}{acc_a(6)}, FD.logic__some_inj(+List<U32>, VMR.OUTR(x0, y0, y1, y2, [xh, xp]), {VWt}, e))
""")
    for i in reversed(range(7)):
        # st_i: the items from field i on
        cases = []
        for c in CONS:
            if i < 6 and c.startswith('S.Items'):
                cases.append(f'    case S.Items{{+h, +r}}: fm{i}({CTX}{acc_a(i)}, h, Codec.parts(h, {SCH[i]}), DS.facts(h, {SCH[i]}, {{==}}), {{==}}, r, e)')
            elif i == 6 and c == 'S.EmptyItems{}':
                cases.append(f'    case S.EmptyItems{{}}: fin({CTX}{acc_a(6)}, Bool.and(Layout.bytes_valid({PS}), N.fits(4n, Nat.add(Layout.fixed_size({PS}), '
                             f'List.length(&2, U32, Layout.payloads({PS}))))), e)')
            else:
                cases.append(f'    case {c}: {NONE}')
        ST = (f"""
def st{i}({CTXT}{acc_t(i)}, +items: S.Value,
    +e: {E(i, f'Codec.parts(items, {ch(i)})')}) -> Empty:
  match items:
""" + '\n'.join(cases) + '\n')

        if i == 6:
            w(ST)
            continue
        WID = 'None{}' if i in VAR else f'Some{{{FIX[i][2]}n}}'
        if i in FIX:
            cf = f'st{i + 1}({CTX}{acc_a(i)}, xs, Equal.sym(Nat, {FIX[i][2]}n, List.length(&2, U32, xs), FD.logic__some_inj(Nat, {FIX[i][2]}n, List.length(&2, U32, xs), hf)), r, e)'
            cv = f'FD.logic__none_some(Nat, {FIX[i][2]}n, Equal.sym(Maybe<&2, Nat>, Some{{{FIX[i][2]}n}}, None{{}}, hf))'
        else:
            cf = 'FD.logic__none_some(Nat, List.length(&2, U32, xs), hf)'
            cv = (f'st{i + 1}({CTX}{acc_a(i)}, xs, VMR.linv(h, xs, {VAR[i][2] - 1}n, U32.to_nat(4096), '
                  f'Equal.cong(Maybe<&2, +List<S.Part>>, Maybe<&2, +List<U32>>, z => Codec.bytes(z), Codec.parts(h, {SCH[i]}), Some{{[S.Variable{{xs}}]}}, em)), r, e)')
        w(f"""
def fp{i}({CTXT}{acc_t(i)}, +h: S.Value, +ps: +List<S.Part>, hf: DF.single({WID}, ps),
    +em: {{Codec.parts(h, {SCH[i]}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}}, +r: S.Value,
    +e: {E(i, f'Codec.concatenate(Some{{ps}}, Codec.parts(r, {ch(i + 1)}))')}) -> Empty:
  match ps:
    case Nil{{}}: hf
    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: {cf}
    case Con{{S.Variable{{+xs}}, Nil{{}}}}: {cv}
    case Con{{S.Fixed{{+xs}}, Con{{+a, +b}}}}: hf
    case Con{{S.Variable{{+xs}}, Con{{+a, +b}}}}: hf

def fm{i}({CTXT}{acc_t(i)}, +h: S.Value, +mm: Maybe<&2, +List<S.Part>>, hf: DF.single_result({WID}, mm),
    +em: {{Codec.parts(h, {SCH[i]}) == mm : Maybe<&2, +List<S.Part>>}}, +r: S.Value,
    +e: {E(i, f'Codec.concatenate(mm, Codec.parts(r, {ch(i + 1)}))')}) -> Empty:
  match mm:
    case None{{}}: {NONE}
    case Some{{+ps}}: fp{i}({CTX}{acc_a(i)}, h, ps, hf, em, r, e)
""")
        w(ST)
    vcases = '\n'.join(f'    case S.Sequence{{+items}}: st0({CTX}, items, e)' if c.startswith('S.Sequence') else f'    case {c}: {NONE}' for c in CONS)
    w(f"""
def inv_v({CTXT}, +v: S.Value,
    +e: {{Codec.encoding_for_legal_type(Spec.{X}(), v) == Some{{{VWt}}} : Maybe<&2, +List<U32>>}}) -> Empty:
  match v:
{vcases}

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 31n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}}
  for +hchk: {{DC.CHK(t, n) == False{{}} : Bool}}
  Decoding.outside_image(Spec.{X}(), {VWt})
def decode_reject(d, t, n, pf, hd, hn, hN, hchk):
  v => e => inv_v({CTX}, v, e)

def none_go({CTXT}, +a: Bool, +ea: {{U32.is_le(356, n) == a : Bool}})
    -> {{T.{X}_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{{}}) : B.Buf & Maybe<&1, T.{X}>}}:
  match a:
    case False{{}}:
      %Equal.sym(Bool, U32.is_le(356, n), False{{}}, ea) :
        {{T.{X}_built(n, T.{X}_ok_len(_, DC.BF(t, n), 0, n)) == (DC.BF(t, n), None{{}}) : B.Buf & Maybe<&1, T.{X}>}}
      {{==}}
    case True{{}}:
      +hF2 = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le(356, n), Nat.is_le(356n, U32.to_nat(n)), VU.le_u32(356, n), ea)
      +h89 = VC.quad_inv(89n, VB.pw(d), FD.nat__le_trans(356n, U32.to_nat(n), A.quad(VB.pw(d)), hF2, hn))
      %Equal.sym(B.Buf & Bool, T.{X}_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), DC.CHK(t, n)),
          DC.ok_eval(d, t, n, VB.lt32(d, hd), FD.nat__lt_le_trans(4n, 89n, VB.pw(d), {{==}}, h89), pf)) :
        {{T.{X}_built(n, _) == (DC.BF(t, n), None{{}}) : B.Buf & Maybe<&1, T.{X}>}}
      %Equal.sym(Bool, DC.CHK(t, n), False{{}}, hchk) :
        {{T.{X}_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{{}}) : B.Buf & Maybe<&1, T.{X}>}}
      {{==}}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}
  for +hd: {{Nat.is_lt(d, 31n) == True{{}} : Bool}}
  for +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  for +hN: {{U32.is_le(n, VB.NMAX()) == True{{}} : Bool}}
  for +hchk: {{DC.CHK(t, n) == False{{}} : Bool}}
  {{T.{X}_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{{}}) : B.Buf & Maybe<&1, T.{X}>}}
def decode_none(d, t, n, pf, hd, hn, hN, hchk):
  none_go({CTX}, U32.is_le(356, n), {{==}})
""")
    L = list(DEC_HEAD) + REJ_HEAD + ['', '# GENERATED by var_multi (codegen). Do not edit.',
                                      f'# Rejection of {X} is exactly the complement of the spec image: every byte string the',
                                      '# spec relates to a value is [8 bytes | three lists of byte vectors | 208 + 128 bytes] behind',
                                      '# the three offsets, and then every check of the validator passes (contra).', '']
    return '\n'.join(L) + '\n' + '\n'.join(W)


ENC_HEAD = ['import ./vadd.bend as VA', 'import ./venc.bend as VE', 'import ./venc2.bend as V2', 'import ./vme.bend as VME', 'import ./vzeros.bend as VZ',
            'import ./var_fix_types_m.bend as VT', 'import ./vfits.bend as VFT', 'import ./xmul.bend as XM', 'import ../../spec/schema.bend as SC', 'import ./vseq.bend as VSQ', f'import ./var_codec_{X}.bend as DC']


def enc_file(g, names):
    from codegen.proofs.var import var_multi_enc as ME
    t = names[X]
    hdr = VLW.FT(g, t.fields[4][1])
    W, LAY, P = ME.text(hdr, None, None, None, DEC_HEAD, None)
    W += ME.put_text(P, LAY)

    def node(ft, words):
        nd = VLW.SL.walk(g, ft, iter(range(100000)))
        mp = {int(w_[1:]): words[j] for j, w_ in enumerate(nd.words)}
        return {'val': VLW.subst_words(nd.val, mp), 'sch': nd.sch, 'proof': VLW.subst_words(nd.proof, mp),
                'words': [mp[int(w_[1:])] for w_ in nd.words]}
    W += ME.spec_text(P, node(t.fields[0][1], ME.IW), node(t.fields[4][1], ME.HW), node(t.fields[5][1], ME.PW))
    L = list(DEC_HEAD) + ENC_HEAD + ['', '# GENERATED by var_multi (codegen: var_multi_enc). Do not edit.',
                                     '# ' + ME.__doc__.strip().splitlines()[0], '']
    from codegen.proofs.var import var_multi_u32 as MU
    return MU.fill('\n'.join(L) + '\n' + '\n'.join(W) + '\n')


def outputs():
    VLW.SL.EXACT = True   # spec_laws' exact spec-parts proofs (F.items_fixed / container_fixed): no parts run to compare forms
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    out = {ROOT / 'proofs/obj/vmul.bend': (ROOT / 'codegen/templates/vmul.bend.in').read_text(),
           ROOT / 'proofs/obj/vmv.bend': (ROOT / 'codegen/templates/vmv.bend.in').read_text(),
           ROOT / 'proofs/obj/vmr.bend': (ROOT / 'codegen/templates/vmr.bend.in').read_text(),
           ROOT / 'proofs/obj/vme.bend': (ROOT / 'codegen/templates/vme.bend.in').read_text(),
           ROOT / 'proofs/obj/var_fix_types_m.bend': __import__('codegen.proofs.support.deep', fromlist=['_']).dify_fix(fix_types(g, names)),
           ROOT / 'proofs/obj/vzeros.bend': zeros_text(),
           ROOT / f'proofs/obj/var_codec_{X}.bend': dec_text(g, names),
           ROOT / f'proofs/obj/var_codec_{X}_acc.bend': acc_file(g, names),
           ROOT / f'proofs/obj/var_codec_{X}_unique.bend': unique_text(),
           ROOT / f'proofs/obj/var_codec_{X}_rej.bend': rej_file(),
           ROOT / f'proofs/obj/var_codec_{X}_enc.bend': enc_file(g, names)}
    return out


def main():
    out = outputs()
    from codegen.impl import runtime_refs as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale: ', 'multi-variable laws are current')
    for p, t in out.items():
        p.write_text(t)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
