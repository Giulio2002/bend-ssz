"""Emit proofs/obj/prog_list.bend: root laws of the progressive lists of basic
elements (ProgressiveList[uint8/16/32/64/128/256], ProgressiveList[boolean])
held as packed bytes (O.Words).

The runtime root is O.mix_count(hl, shift, O.words_root_prog(...)): the
progressive chunk tree of the packed bytes (proofs/obj/prog_root.bend: the
runtime tree is `pr`, whose bytes are spec/progressive.bend `tree`) with the
element count mixed in. The elements and their bytes are the packed laws'
(ulist_obj, packed_obj, packed_bytes); this file adds their counts, the state
law over the byte storage (empty or not: list_obj wfl) and the specification
law per element kind.

    python3 codegen/proofs/laws/prog_laws.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.core.paths import ROOT  # noqa: E402
from codegen.core.shared_laws import light_pair  # noqa: E402
from codegen.proofs.support import light_split as LS  # noqa: E402
OUT = ROOT / 'proofs/obj/prog_list.bend'
M = 'Maybe<&2, +List<U32>>'
SL = 'F.array__slots(U32, t)'
BYTES = f'WS.btake(U32.to_nat(N), FX.limbs({SL}))'

# kind: (element schema, width name, shift, word-packed element count?)
KINDS = {
    '8': dict(E='S.Unsigned{P.U64{}}', W='P.U64{}', sh=3, isw='UL.is_U64', shape='UL.is_U64_shape'),
    '4': dict(E='S.Unsigned{P.U32Width{}}', W='P.U32Width{}', sh=2, isw='PK.is_U32Width', shape='PK.is_U32Width_shape'),
    '16': dict(E='S.Unsigned{P.U128{}}', W='P.U128{}', sh=4, isw='PK.is_U128', shape='PK.is_U128_shape'),
    '32': dict(E='S.Unsigned{P.U256{}}', W='P.U256{}', sh=5, isw='PK.is_U256', shape='PK.is_U256_shape'),
    '1': dict(E='S.Unsigned{P.U8{}}', W='P.U8{}', sh=0, isw='PB.is_U8', shape='PB.is_U8_shape'),
    '2': dict(E='S.Unsigned{P.U16{}}', W='P.U16{}', sh=1, isw='PB.is_U16', shape='PB.is_U16_shape'),
    'b': dict(E='S.Boolean{}', W=None, sh=0, isw=None, shape=None),
}
NAMES = {'8': 'uint64', '4': 'uint32', '16': 'uint128', '32': 'uint256', '1': 'uint8', '2': 'uint16', 'b': 'boolean'}


def cons(xs, tail):
    e = tail
    for x in reversed(xs):
        e = f'Con{{{x}, {e}}}'
    return e


def count_law(K, w):
    """Codec.count of the element view."""
    if K in ('4', '16', '32'):
        W = int(K)
        m = W // 4
        A = [f'a{i}' for i in range(m)]
        goal = lambda k, L: f'{{Codec.count(PK.it{W}({k}, {L})) == {k} : Nat}}'
        w(f'law pc{W}:')
        w('  for +k: Nat')
        w('  for +W: List<&2, U32>')
        w(f'  for +hl: {{Nat.is_le(PK.m{W}(k), F.spec_common__length(U32, W)) == True{{}} : Bool}}')
        w(f'  {goal("k", "W")}')
        w(f'def pc{W}(k, W, hl):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +c:')
        ind, src = '      ', 'W'
        for i in range(m):
            w(f'{ind}match {src}:')
            w(f'{ind}  case Nil{{}}: Empty.absurd({goal("1n+c", cons(A[:i], "Nil{}"))}, MD.false_true(hl))')
            nxt = 'rest' if i == m - 1 else f't{i}'
            w(f'{ind}  case Con{{+a{i}, +{nxt}}}:')
            src, ind = nxt, ind + '    '
        w(f'{ind}%Equal.sym(Nat, Codec.count(PK.it{W}(c, rest)), c, pc{W}(c, rest, hl)) : {{1n+_ == 1n+c : Nat}}')
        w(f'{ind}{{==}}')
        w('')
        return
    if K in ('1', 'b'):
        it, scope, bound = ('PB.it1', 'SP.byte_scope', '256') if K == '1' else ('PB.itb', 'PB.bscope', '2')
        goal = lambda k, xs: f'{{Codec.count({it}({k}, {xs})) == {k} : Nat}}'
        w(f'law pc{K}:')
        w('  for +k: Nat')
        w('  for +xs: +List<U32>')
        w(f'  for +hs: {{{scope}(k, xs) == True{{}} : Bool}}')
        w(f'  {goal("k", "xs")}')
        w(f'def pc{K}(k, xs, hs):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +c:')
        w('      match xs:')
        w(f'        case Nil{{}}: Empty.absurd({goal("1n+c", "Nil{}")}, MD.false_true(hs))')
        w('        case Con{+h, +t}:')
        w(f'          %Equal.sym(Nat, Codec.count({it}(c, t)), c, pc{K}(c, t, V.and_right(U32.is_lt(h, {bound}), {scope}(c, t), hs))) : {{1n+_ == 1n+c : Nat}}')
        w('          {==}')
        w('')
        return
    if K == '2':
        goal = lambda k, xs: f'{{Codec.count(PB.it2({k}, {xs})) == {k} : Nat}}'
        w('law pc2:')
        w('  for +k: Nat')
        w('  for +xs: +List<U32>')
        w('  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}')
        w(f'  {goal("k", "xs")}')
        w('def pc2(k, xs, hs):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +c:')
        w('      match xs:')
        w(f'        case Nil{{}}: Empty.absurd({goal("1n+c", "Nil{}")}, MD.false_true(hs))')
        w('        case Con{+x0, +t}:')
        w('          match t:')
        w(f'            case Nil{{}}: Empty.absurd({goal("1n+c", "Con{x0, Nil{}}")}, MD.false_true(V.and_right(U32.is_lt(x0, 256), False{{}}, hs)))')
        w('            case Con{+x1, +rest}:')
        w('              +k1 = V.and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)')
        w('              %Equal.sym(Nat, Codec.count(PB.it2(c, rest)), c, pc2(c, rest, V.and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))) : {1n+_ == 1n+c : Nat}')
        w('              {==}')
        w('')


def kind_law(K, w):
    k = KINDS[K]
    E, sh = k['E'], k['sh']
    cN = f'U32.to_nat(U32.shrn(N, {sh}n))'
    SCH = f'S.ProgressiveList{{{E}}}'
    # the element view, its bytes, its count, per kind
    if K == '8':
        view, cnt = 'UL.uview', 'UL.ucnt'
        items = f'UL.uitems({cN}, {SL})'
        eW = 'O.e8'
        eqn = 'UL.eq_n(o, t, N, eo, eN)'
        zero = 'UL.e8_zero'
        enc = 'UL.ul_enc(N, q, r, dw, t, eNN, enq, h32, pf, room)'
        cnt_pf = f'UL.ucount({cN}, {SL}, UL.words_fit({cN}, q, r, dw, t, ec, h32, pf, room))'
    elif K in ('4', '16', '32'):
        W = int(K)
        view, cnt = f'PK.vview{W}', f'PK.cnt{W}'
        items = f'PK.it{W}({cN}, {SL})'
        eW = f'PK.e{W}'
        eqn = f'PK.eq_n{W}(o, t, N, eo, eN)'
        zero = f'e{W}_zero'
        enc = f'PK.v{W}_enc(N, q, r, dw, t, eNN, enq, h32, pf, room)'
        cnt_pf = f'pc{W}({cN}, {SL}, PK.words_fit{W}({cN}, q, r, dw, t, ec, h32, pf, room))'
    elif K == '2':
        view, cnt = 'PB.vview2', 'PB.cnt2'
        items = f'PB.it2({cN}, {BYTES})'
        eW = 'Nat.double'
        eqn = 'PB.eq_n2(o, t, N, eo, eN)'
        zero = 'dbl_zero'
        enc = 'PB.v2_enc(N, q, r, dw, t, eNN, enq, h32, pf, room)'
        cnt_pf = f'pc2({cN}, {BYTES}, PB.v2_scope(N, q, r, dw, t, eNN, enq, h32, pf, room))'
    else:
        it = 'PB.it1' if K == '1' else 'PB.itb'
        view = 'PB.vview1' if K == '1' else 'PB.vviewb'
        cnt = None
        items = f'{it}(U32.to_nat(N), {BYTES})'
        eW = None
        cN = 'U32.to_nat(N)'
        sc = 'PB.vscope(N, q, r, dw, t, enq, h32, pf, room)' if K == '1' else 'PB.bsc(o, t, N, eo, hb)'
        enc = f'{"PB.pb1" if K == "1" else "PB.pbb"}(U32.to_nat(N), {BYTES}, {sc})'
        cnt_pf = f'pc{K}(U32.to_nat(N), {BYTES}, {sc})'
    w(f'# ---- ProgressiveList[{NAMES[K]}] ' + '-' * 40)
    w('')
    # representation invariant and schema fact
    facts = []
    if eW:
        facts.append(f'{{U32.to_nat(WO.len(o)) == {eW}({cnt}(o)) : Nat}}')
    if K == 'b':
        facts.append('{PB.bscope(U32.to_nat(WO.len(o)), WO.wview(o)) == True{} : Bool}')
    rep = 'LO.wfl(o)'
    for f_ in reversed(facts):
        rep = f'DK.P2({rep}, {f_})' if f_ is facts[0] and len(facts) == 1 else rep
    if len(facts) == 1:
        rep = f'DK.P2(LO.wfl(o), {facts[0]})'
    elif len(facts) == 2:
        rep = f'DK.P2(LO.wfl(o), DK.P2({facts[0]}, {facts[1]}))'
    w(f'# The object represents a value of the progressive list schema s: byte storage')
    w(f'# of whole elements (any count; a progressive list has no limit).')
    w(f'def rep_pl{K}(o: O.Words, +s: S.Schema) -> Data:')
    w(f'  {rep}')
    w('')
    w(f'def rep_wf{K}(-o: O.Words, +s: S.Schema, +rep: rep_pl{K}(o, s)) -> LO.wfl(o):')
    if facts:
        w('  (+wf, +r) = rep')
        w('  wf')
    else:
        w('  rep')
    w('')
    if K == 'b':
        okx = 'SH.is_Boolean(SH.ProgressiveList_element(s))'
    else:
        okx = f'Bool.and(SH.is_Unsigned(SH.ProgressiveList_element(s)), {k["isw"]}(SH.Unsigned_width(SH.ProgressiveList_element(s))))'
    w(f'def ok_pl{K}(+s: S.Schema) -> Bool: Bool.and(SH.is_ProgressiveList(s), {okx})')
    w('')
    # the specification law over the destructured storage
    V_ = SCH
    dig = f'pdig(hl, _, {sh}n)'
    args = ['+hl: Nat', '+ehl: {hl == 64n : Nat}', '-o: O.Words', '+wf: LO.wfl(o)']
    if eW:
        args.append(f'+eN: {{U32.to_nat(WO.len(o)) == {eW}({cnt}(o)) : Nat}}')
    if K == 'b':
        args.append('+hb: {PB.bscope(U32.to_nat(WO.len(o)), WO.wview(o)) == True{} : Bool}')
    w(f'def pl{K}_body({", ".join(args)})')
    w(f'    -> RR.roots({view}(o), {V_}, [D.bytes(pdig(hl, o, {sh}n))]):')
    w('  match wf:')
    w('    case Inl{w}:')
    w('      (+t, w1) = w')
    w('      (+dw, w2) = w1')
    w('      (+N, w3) = w2')
    w('      (+eo, w4) = w3')
    w('      (+pf, w5) = w4')
    w('      (+hd, +en0) = w5')
    if eW:
        w(f'      +eNN = {eqn}')
        w(f'      +c0 = {zero}({cN}, Equal.trans(Nat, 0n, U32.to_nat(N), {eW}({cN}), Equal.sym(Nat, U32.to_nat(N), 0n, en0), eNN))')
    else:
        w('      +c0 = Equal.sym(Nat, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, en0))')
    w('      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :')
    w(f'        RR.roots({view}(_), {V_}, [D.bytes({dig})])')
    it0 = items.replace(SL, 'F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t)))')
    w(f'      %Equal.sym(Nat, {cN}, 0n, c0) :')
    w(f'        RR.roots(S.Sequence{{{it0.replace(cN, "_", 1)}}}, {V_}, [D.bytes(pdig(hl, O.Words{{F.array__thaw(U32, t), N}}, {sh}n))])')
    w('      %Equal.sym(Nat, U32.to_nat(N), 0n, en0) :')
    w(f'        RR.roots(S.Sequence{{S.EmptyItems{{}}}}, {V_}, [D.bytes(O.mix_len(hl, PR.pr(1n+Nat.div(Nat.add(_, 31n), 32n), Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, 0n, 0n, Nat.div(Nat.add(_, 31n), 32n), MR.clist(Nat.div(Nat.add(_, 31n), 32n), F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))), 0n)), U32.shrn(N, {sh}n)))])')
    w(f'      ([], (([], ({{==}}, {{==}})), (D.bytes(PR.pr(1n, False{{}}, hl, 0n, 0n, 0n, MR.clist(0n, F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))), 0n))), (pl_empty(hl, t), plen0(hl, ehl, N, {sh}n, PR.pr(1n, False{{}}, hl, 0n, 0n, 0n, MR.clist(0n, F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))), 0n)), {"c0" if sh else "c0"})))))')
    w('    case Inr{w}:')
    for i, (a, b) in enumerate([('t', 'w1'), ('dw', 'w2'), ('N', 'w3'), ('q', 'w4'), ('r', 'w5'), ('eo', 'w6'), ('pf', 'w7'), ('hd', 'w8'), ('enq', 'w9'), ('h1', 'w10'), ('h32', 'w11')]):
        w(f'      (+{a}, {b}) = {"w" if i == 0 else "w" + str(i)}')
    w('      (+room, +slack) = w11')
    if eW:
        w(f'      +eNN = {eqn}')
        w(f'      +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), {eW}({cN}), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)')
    w('      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :')
    w(f'        RR.roots({view}(_), {V_}, [D.bytes({dig})])')
    itF = items.replace(SL, 'F.array__slots(U32, _)')
    w('      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
    w(f'        RR.roots(S.Sequence{{{itF}}}, {V_}, [D.bytes(O.mix_len(hl, PR.pr(1n+O.chunks_of(N), Nat.is_lt(0n, O.chunks_of(N)), hl, 0n, 0n, O.chunks_of(N), MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n)), U32.shrn(N, {sh}n)))])')
    w('      %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :')
    w(f'        RR.roots(S.Sequence{{{items}}}, {V_}, [D.bytes(O.mix_len(hl, PR.pr(1n+_, Nat.is_lt(0n, _), hl, 0n, 0n, _, MR.clist(_, {SL}, 0n)), U32.shrn(N, {sh}n)))])')
    Lc = f'MR.clist(1n+q, {SL}, 0n)'
    R = f'PR.pr(2n+q, True{{}}, hl, 0n, 0n, 1n+q, {Lc})'
    w(f'      (MD.bytes_list({Lc}),')
    w(f'        (({BYTES}, ({enc}, UL.ul_pack(N, q, r, dw, t, enq, h1, h32, pf, room, slack))),')
    w(f'         (D.bytes({R}), (pl_merk(hl, ehl, q, dw, t, hd, room),')
    w(f'           plen(hl, ehl, N, {sh}n, {R}, Codec.count({items}), {cnt_pf})))))')
    w('')
    # the law over the schema variable
    w(f'# A progressive list of {NAMES[K]}: its digest is a specification root of its elements.')
    w(f'def pl{K}_rs(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -o: O.Words, +s: S.Schema, +rep: rep_pl{K}(o, s), +ok: {{ok_pl{K}(s) == True{{}} : Bool}})')
    w(f'    -> RR.roots({view}(o), s, [D.bytes(pdig(hl, o, {sh}n))]):')
    if len(facts) == 2:
        w('  (+wf, +r1) = rep')
        w('  (+eN, +hb) = r1')
        call = f'pl{K}_body(hl, ehl, o, wf, eN, hb)'
    elif len(facts) == 1:
        if K == 'b':
            w('  (+wf, +hb) = rep')
            call = f'pl{K}_body(hl, ehl, o, wf, hb)'
        else:
            w('  (+wf, +eN) = rep')
            call = f'pl{K}_body(hl, ehl, o, wf, eN)'
    else:
        w('  +wf = rep')
        call = f'pl{K}_body(hl, ehl, o, wf)'
    w(f'  +c0 = DK.and_l(SH.is_ProgressiveList(s), {okx}, ok)')
    w(f'  +k1 = DK.and_r(SH.is_ProgressiveList(s), {okx}, ok)')
    w('  %Equal.sym(S.Schema, s, S.ProgressiveList{SH.ProgressiveList_element(s)}, SH.ProgressiveList_shape(s, c0)) :')
    w(f'    RR.roots({view}(o), _, [D.bytes(pdig(hl, o, {sh}n))])')
    if K == 'b':
        w('  %Equal.sym(S.Schema, SH.ProgressiveList_element(s), S.Boolean{}, SH.Boolean_shape(SH.ProgressiveList_element(s), k1)) :')
        w(f'    RR.roots({view}(o), S.ProgressiveList{{_}}, [D.bytes(pdig(hl, o, {sh}n))])')
    else:
        w(f'  +c1 = DK.and_l(SH.is_Unsigned(SH.ProgressiveList_element(s)), {k["isw"]}(SH.Unsigned_width(SH.ProgressiveList_element(s))), k1)')
        w(f'  +c2 = DK.and_r(SH.is_Unsigned(SH.ProgressiveList_element(s)), {k["isw"]}(SH.Unsigned_width(SH.ProgressiveList_element(s))), k1)')
        w('  %Equal.sym(S.Schema, SH.ProgressiveList_element(s), S.Unsigned{SH.Unsigned_width(SH.ProgressiveList_element(s))}, SH.Unsigned_shape(SH.ProgressiveList_element(s), c1)) :')
        w(f'    RR.roots({view}(o), S.ProgressiveList{{_}}, [D.bytes(pdig(hl, o, {sh}n))])')
        w(f'  %Equal.sym(P.Width, SH.Unsigned_width(SH.ProgressiveList_element(s)), {k["W"]}, {k["shape"]}(SH.Unsigned_width(SH.ProgressiveList_element(s)), c2)) :')
        w(f'    RR.roots({view}(o), S.ProgressiveList{{S.Unsigned{{_}}}}, [D.bytes(pdig(hl, o, {sh}n))])')
    w(f'  {call}')
    w('')


HEAD = '''import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/codec.bend as Codec
import ../../spec/packing.bend as Pack
import ../../spec/progressive.bend as PS
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../proofs/primitive_invariants.bend as V
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_obj.bend as WO
import ./list_root.bend as LR
import ./list_obj.bend as LO
import ./ulist_obj.bend as UL
import ./packed_obj.bend as PK
import ./packed_bytes.bend as PB
import ./prog_root.bend as PR
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# GENERATED by prog_laws (codegen). Do not edit.
# Progressive lists of basic elements held as packed bytes: the runtime root
# is the progressive chunk tree of the bytes (prog_root pr) with the element
# count mixed in; the specification's is spec/root_relation.bend `sequence`
# with a progressive tree (spec/progressive.bend) and the count.

law pow2_eq:
  for +d: Nat
  {F.spec_common__pow2(d) == O.pow2n(d) : Nat}
def pow2_eq(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, F.spec_common__pow2(p), O.pow2n(p), pow2_eq(p)) : {Nat.double(_) == Nat.double(O.pow2n(p)) : Nat}
      {==}

law dz:
  for +c: Nat
  for +e: {0n == Nat.double(c) : Nat}
  {0n == c : Nat}
def dz(c, e):
  match c:
    case 0n: {==}
    case 1n+ +p: Empty.absurd({0n == 1n+p : Nat}, MD.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Nat, Bool, x => Nat.is_eq(x, 0n), 0n, Nat.double(1n+p), e))))

def dbl_zero(+c: Nat, +e: {0n == Nat.double(c) : Nat}) -> {c == 0n : Nat}: Equal.sym(Nat, 0n, c, dz(c, e))
def e4_zero(+c: Nat, +e: {0n == PK.e4(c) : Nat}) -> {c == 0n : Nat}:
  Equal.sym(Nat, 0n, c, dz(c, dz(Nat.double(c), e)))
def e16_zero(+c: Nat, +e: {0n == PK.e16(c) : Nat}) -> {c == 0n : Nat}:
  Equal.sym(Nat, 0n, c, dz(c, dz(Nat.double(c), dz(Nat.double(Nat.double(c)), dz(Nat.double(Nat.double(Nat.double(c))), e)))))
def e32_zero(+c: Nat, +e: {0n == PK.e32(c) : Nat}) -> {c == 0n : Nat}:
  Equal.sym(Nat, 0n, c, dz(c, dz(Nat.double(c), dz(Nat.double(Nat.double(c)), dz(Nat.double(Nat.double(Nat.double(c))), dz(Nat.double(Nat.double(Nat.double(Nat.double(c)))), e))))))

# The runtime root of byte storage as a progressive tree, with the count mixed in.
def pdig(+hl: Nat, o: O.Words, +sh: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: O.mix_len(hl, PR.pr(1n+O.chunks_of(n), Nat.is_lt(0n, O.chunks_of(n)), hl, 0n, 0n, O.chunks_of(n), MR.clist(O.chunks_of(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)), U32.shrn(n, sh))

def prog_st(+hl: Nat, -h: B.Buf, +t: F.array__Tree<U32>, +N: U32, +seg: U32, +sh: Nat, +dw: Nat,
    +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +hn: {Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {O.mix_count(hl, sh, O.words_root_prog(hl, h, O.Words{F.array__thaw(U32, t), N}, seg)) == (h, (O.Words{F.array__thaw(U32, t), N}, pdig(hl, O.Words{F.array__thaw(U32, t), N}, sh))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.ptree(1n+O.chunks_of(N), Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, 0n, 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero()))),
      (h, (F.array__thaw(U32, t), PR.pr(1n+O.chunks_of(N), Nat.is_lt(0n, O.chunks_of(N)), hl, 0n, 0n, O.chunks_of(N), MR.clist(O.chunks_of(N), F.array__slots(U32, t), 0n)))),
      PR.pt_run(1n+O.chunks_of(N), Nat.is_lt(0n, O.chunks_of(N)), hl, 0n, 0n, O.chunks_of(N), dw, t, h, D.zero(), {==}, hd, pf, hn)) :
    {O.mix_count(hl, sh, O.mt_words(N, _)) == (h, (O.Words{F.array__thaw(U32, t), N}, pdig(hl, O.Words{F.array__thaw(U32, t), N}, sh))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, PR.pr(1n+O.chunks_of(N), Nat.is_lt(0n, O.chunks_of(N)), hl, 0n, 0n, O.chunks_of(N), MR.clist(O.chunks_of(N), F.array__slots(U32, t), 0n)), U32.shrn(N, sh)))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, PR.pr(1n+O.chunks_of(N), Nat.is_lt(0n, O.chunks_of(N)), hl, 0n, 0n, O.chunks_of(N), MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n)), U32.shrn(N, sh)))) : B.Buf & (O.Words & D.Digest)}
  {==}

def hn0(+N: U32, +dw: Nat, +en0: {U32.to_nat(N) == 0n : Nat}) -> {Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(N), 0n, en0) : {Nat.is_le(O.e8(Nat.div(Nat.add(_, 31n), 32n)), F.spec_common__pow2(dw)) == True{} : Bool}
  Order.zero_le(F.spec_common__pow2(dw))

def hn1(+N: U32, +q: Nat, +r: Nat, +dw: Nat,
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(O.e8(O.chunks_of(N)), F.spec_common__pow2(dw)) == True{} : Bool}:
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) : {Nat.is_le(O.e8(_), F.spec_common__pow2(dw)) == True{} : Bool}
  room

# The progressive root over the storage: the state law, empty or not.
def pl_st(+hl: Nat, -h: B.Buf, -o: O.Words, +seg: U32, +sh: Nat, +wf: LO.wfl(o))
    -> {O.mix_count(hl, sh, O.words_root_prog(hl, h, o, seg)) == (h, (o, pdig(hl, o, sh))) : B.Buf & (O.Words & D.Digest)}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, sh, O.words_root_prog(hl, h, _, seg)) == (h, (_, pdig(hl, _, sh))) : B.Buf & (O.Words & D.Digest)}
      prog_st(hl, h, t, N, seg, sh, dw, hd, pf, hn0(N, dw, en0))
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, +slack) = w11
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, sh, O.words_root_prog(hl, h, _, seg)) == (h, (_, pdig(hl, _, sh))) : B.Buf & (O.Words & D.Digest)}
      prog_st(hl, h, t, N, seg, sh, dw, hd, pf, hn1(N, q, r, dw, enq, h1, h32, room))

# The chunks of nonempty storage merkleize progressively to the bytes of pr.
def pl_merk(+hl: Nat, +ehl: {hl == 64n : Nat}, +q: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {PS.merkleize(MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))) == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}:
  +hm = Order.transitive(PR.q4(1n+q), O.e8(1n+q), O.pow2n(dw), F.nat__double_self_le(PR.q4(1n+q)),
    PR.rw_le_r(O.e8(1n+q), F.spec_common__pow2(dw), O.pow2n(dw), pow2_eq(dw), room))
  %Equal.sym(Bool, Pack.chunks_domain(MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), True{}, RS.chunks_domain_bytes(MR.clist(1n+q, F.array__slots(U32, t), 0n))) :
    {PS.gate(_, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))) == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, List.length(&2, +List<U32>, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), RS.length_bytes(MR.clist(1n+q, F.array__slots(U32, t), 0n))) :
    {Some{PS.tree(_, 0n, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)))} == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)) :
    {Some{PS.tree(_, 0n, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)))} == Some{D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, D.bytes(PR.pr(2n+q, True{}, hl, 0n, 0n, 1n+q, MR.clist(1n+q, F.array__slots(U32, t), 0n))), PS.tree(1n+q, 0n, MD.bytes_list(MD.ddrop(0n, MR.clist(1n+q, F.array__slots(U32, t), 0n)))),
      PR.pr_spec(2n+q, 1n+q, True{}, hl, ehl, 0n, 0n, 1n+q, dw, MR.clist(1n+q, F.array__slots(U32, t), 0n), MR.clist_len(1n+q, F.array__slots(U32, t), 0n), {==},
        Order.step_right(1n+q, 1n+q, Order.reflexive(1n+q)), Order.reflexive(1n+q), {==}, hm, F.nat__lt_trans(dw, 32n, 64n, hd, {==}))) :
    {Some{PS.tree(1n+q, 0n, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)))} == Some{_} : Maybe<&2, +List<U32>>}
  {==}

# The count mixed in: the element count (the byte length shifted right).
def plen(+hl: Nat, +ehl: {hl == 64n : Nat}, +N: U32, +sh: Nat, +R: D.Digest, +c: Nat, +ec: {c == U32.to_nat(U32.shrn(N, sh)) : Nat})
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, c)) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, sh)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, c, U32.to_nat(U32.shrn(N, sh)), ec) : {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, sh)))} : Maybe<&2, +List<U32>>}
  LR.mix_bytes(hl, ehl, R, U32.shrn(N, sh))

# The progressive root of no chunks, once (every empty-list case uses it; it
# evaluates one spec hash, which the seven list bodies each re-ran).
def pl_empty(+hl: Nat, +t: F.array__Tree<U32>)
    -> {PS.merkleize([]) == Some{D.bytes(PR.pr(1n, False{}, hl, 0n, 0n, 0n, MR.clist(0n, F.array__slots(U32, F.array__freeze(U32, F.array__thaw(U32, t))), 0n)))} : Maybe<&2, +List<U32>>}:
  {==}

def plen0(+hl: Nat, +ehl: {hl == 64n : Nat}, +N: U32, +sh: Nat, +R: D.Digest, +c0: {U32.to_nat(U32.shrn(N, sh)) == 0n : Nat})
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, 0n)) == Some{D.bytes(O.mix_len(hl, R, U32.shrn(N, sh)))} : Maybe<&2, +List<U32>>}:
  plen(hl, ehl, N, sh, R, 0n, Equal.sym(Nat, U32.to_nat(U32.shrn(N, sh)), 0n, c0))
'''


def emit():
    L = [HEAD]
    w = L.append
    for K in ('4', '16', '32', '1', 'b', '2'):
        count_law(K, w)
    for K in ('8', '4', '16', '32', '1', '2', 'b'):
        kind_law(K, w)
    return '\n'.join(L) + '\n'


def main():
    return light_pair(OUT, emit(), 'prog_laws', 'progressive list laws are current', '--check' in sys.argv, LS)


if __name__ == '__main__':
    sys.exit(main())
