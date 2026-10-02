"""Emit proofs/obj/packed_obj.bend: root laws of vectors of word-aligned
unsigned integers (uint32, uint64, uint128, uint256) held as packed words
(O.Words), for any vector schema the object represents.

Per element byte width W (m = W/4 words per element, count shift log2 W):

  it{W}(k, W)       the first k elements of a word list (m words each)
  pb{W}             their basic serialization is the first W*k bytes of the words
  rep_v{W}(o, s)    the storage is nonempty byte storage (words_obj wf1) of exactly
                    W * count bytes, count == the vector length
  ok_v{W}(s, d)     the schema is a vector of uint(8W) whose chunk limit has
                    minimal depth d (one closed Bool)
  v{W}_rs           the digest (words_obj wdig, the runtime's by bv_st) is a
                    specification root of the elements

The byte packing and the tree are the list proof's (ulist_obj ul_pack,
root_support at_depth_tree); a vector mixes no length in.

    python3 codegen/proofs/laws/packed_vector_root_laws.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.law_module_helpers import sync_pairs  # noqa: E402
OUT = ROOT / 'proofs/obj/packed_obj.bend'
OUT2 = ROOT / 'proofs/obj/packed_bytes.bend'
WID = {4: 'P.U32Width{}', 8: 'P.U64{}', 16: 'P.U128{}', 32: 'P.U256{}'}
ALLW = ['P.U8{}', 'P.U16{}', 'P.U32Width{}', 'P.U64{}', 'P.U128{}', 'P.U256{}']
SHIFT = {4: 2, 8: 3, 16: 4, 32: 5}
M = 'Maybe<&2, +List<U32>>'


def uint(W, xs):
    m = W // 4
    return 'P.UInt{' + ', '.join(xs + ['0'] * (8 - m)) + '}'


def cons(xs, tail):
    e = tail
    for x in reversed(xs):
        e = f'Con{{{x}, {e}}}'
    return e


def app(parts):
    e = parts[-1]
    for p in reversed(parts[:-1]):
        e = f'List.append(&2, U32, {p}, {e})'
    return e


def emit_width(W, w):
    m = W // 4
    sh = SHIFT[W]
    U = f'S.Unsigned{{{WID[W]}}}'
    A = [f'a{i}' for i in range(m)]
    w(f'# ---- uint{8 * W}: {m} word{"s" if m > 1 else ""} per element ' + '-' * 40)
    w('')
    mw = {1: 'x', 2: 'Nat.double(x)', 4: 'Nat.double(Nat.double(x))', 8: 'O.e8(x)'}[m]
    w(f'def m{W}(+x: Nat) -> Nat: {mw}')
    w(f'def e{W}(+x: Nat) -> Nat: Nat.double(Nat.double(m{W}(x)))')
    w('')
    # the elements
    w(f'def it{W}(k: Nat, W: List<&2, U32>) -> S.Value:')
    w('  match k:')
    w('    case 0n: S.EmptyItems{}')
    w('    case 1n+c:')
    ind = '      '
    src = 'W'
    for i in range(m):
        w(f'{ind}match {src}:')
        w(f'{ind}  case Nil{{}}: S.EmptyItems{{}}')
        nxt = 'rest' if i == m - 1 else f't{i}'
        if i == m - 1:
            w(f'{ind}  case Con{{+a{i}, rest}}: S.Items{{S.UnsignedValue{{{uint(W, A)}}}, it{W}(c, rest)}}')
        else:
            w(f'{ind}  case Con{{+a{i}, {nxt}}}:')
        src = nxt
        ind += '    '
    w('')
    # their bytes
    goal = lambda k, L: f'{{RR.basic_bytes(it{W}({k}, {L}), {U}) == Some{{WS.btake(e{W}({k}), FX.limbs({L}))}} : {M}}}'
    w(f'law pb{W}:')
    w('  for +k: Nat')
    w('  for +W: List<&2, U32>')
    w(f'  for +hl: {{Nat.is_le(m{W}(k), F.spec_common__length(U32, W)) == True{{}} : Bool}}')
    w(f'  {goal("k", "W")}')
    w(f'def pb{W}(k, W, hl):')
    w('  match k:')
    w('    case 0n: {==}')
    w('    case 1n+ +c:')
    ind = '      '
    src = 'W'
    for i in range(m):
        w(f'{ind}match {src}:')
        w(f'{ind}  case Nil{{}}: Empty.absurd({goal("1n+c", cons(A[:i], "Nil{}"))}, MD.false_true(hl))')
        nxt = 'rest' if i == m - 1 else f't{i}'
        w(f'{ind}  case Con{{+a{i}, +{nxt}}}:')
        src = nxt
        ind += '    '
    full = cons(A, 'rest')
    rhs = f'Some{{WS.btake(e{W}(1n+c), FX.limbs({full}))}}'
    rec = f'Some{{WS.btake(e{W}(c), FX.limbs(rest))}}'
    lds = [f'SP.limb_digits({a})' for a in A]
    w(f'{ind}%Equal.sym({M}, RR.basic_bytes(it{W}(c, rest), {U}), {rec}, pb{W}(c, rest, hl)) :')
    w(f'{ind}  {{RR.join(Some{{{app(lds)}}}, _) == {rhs} : {M}}}')
    for i in range(m):
        parts = [f'I.limb({a})' for a in A[:i]] + ['_'] + lds[i + 1:]
        w(f'{ind}%IE.limb_correct({A[i]}) :')
        w(f'{ind}  {{RR.join(Some{{{app(parts)}}}, {rec}) == {rhs} : {M}}}')
    w(f'{ind}{{==}}')
    w('')
    # arithmetic
    w(f'law e{W}_mul:')
    w('  for +L: Nat')
    w(f'  {{e{W}(L) == Nat.mul(L, {W}n) : Nat}}')
    w(f'def e{W}_mul(L):')
    w('  match L:')
    w('    case 0n: {==}')
    w('    case 1n+ +p:')
    w(f'      %Equal.sym(Nat, e{W}(p), Nat.mul(p, {W}n), e{W}_mul(p)) : {{{W}n+_ == Nat.add({W}n, Nat.mul(p, {W}n)) : Nat}}')
    w('      {==}')
    w('')
    w(f'law e{W}_mono:')
    w('  for +a: Nat')
    w('  for +b: Nat')
    w('  for +e: {Nat.is_le(a, b) == True{} : Bool}')
    w(f'  {{Nat.is_le(e{W}(a), e{W}(b)) == True{{}} : Bool}}')
    w(f'def e{W}_mono(a, b, e):')
    w('  match a b:')
    w(f'    case 0n _: Order.zero_le(e{W}(b))')
    w(f'    case 1n+p 0n: Empty.absurd({{Nat.is_le(e{W}(1n+p), e{W}(0n)) == True{{}} : Bool}}, MD.false_true(e))')
    w(f'    case 1n+ +p 1n+ +q: e{W}_mono(p, q, e)')
    w('')
    nm = {4: 'U32Width', 8: 'U64', 16: 'U128', 32: 'U256'}[W]
    w(f'def is_{nm}(w: P.Width) -> Bool:')
    w('  match w:')
    w(f'    case P.{nm}{{}}: True{{}}')
    w('    case _: False{}')
    w('')
    w(f'law is_{nm}_shape:')
    w('  for +w: P.Width')
    w(f'  for +e: {{is_{nm}(w) == True{{}} : Bool}}')
    w(f'  {{w == P.{nm}{{}} : P.Width}}')
    w(f'def is_{nm}_shape(w, e):')
    w('  match w:')
    for x in ALLW:
        if x == WID[W]:
            w(f'    case {x}: {{==}}')
        else:
            w(f'    case {x}: Empty.absurd({{{x} == P.{nm}{{}} : P.Width}}, MD.false_true(e))')
    w('')
    # the object
    w(f'def cnt{W}(o: O.Words) -> Nat: U32.to_nat(U32.shrn(WO.len(o), {sh}n))')
    w('')
    w(f'def vview{W}(o: O.Words) -> S.Value:')
    w('  match o:')
    w(f'    case O.Words{{ws, +n}}: S.Sequence{{it{W}(U32.to_nat(U32.shrn(n, {sh}n)), F.array__slots(U32, F.array__freeze(U32, ws)))}}')
    w('')
    w(f'# The object represents a value of the vector schema s: nonempty byte storage')
    w(f'# of whole elements ({W} bytes each), as many as the vector length.')
    w(f'def rep_v{W}(o: O.Words, +s: S.Schema) -> Data:')
    w(f'  DK.P2(WO.wf1(o), DK.P2({{U32.to_nat(WO.len(o)) == e{W}(cnt{W}(o)) : Nat}}, {{Nat.is_eq(cnt{W}(o), SH.Vector_length(s)) == True{{}} : Bool}}))')
    w('')
    lim = f'Nat.div(Nat.add(Nat.mul(SH.Vector_length(s), {W}n), 31n), 32n)'
    c3 = f'Lim.minimal({lim}, depth)'
    c2 = f'Bool.and(is_{nm}(SH.Unsigned_width(SH.Vector_element(s))), {c3})'
    c1 = f'Bool.and(SH.is_Unsigned(SH.Vector_element(s)), {c2})'
    w(f'# The schema is a vector of uint{8 * W} whose chunk limit has minimal depth `depth`.')
    w(f'def ok_v{W}(+s: S.Schema, +depth: Nat) -> Bool:')
    w(f'  Bool.and(SH.is_Vector(s), {c1})')
    w('')
    w(f'def rep_wf{W}(-o: O.Words, +s: S.Schema, +rep: rep_v{W}(o, s)) -> WO.wf1(o):')
    w('  (+wf, +r) = rep')
    w('  wf')
    w('')
    # the specification root
    w(f'def eq_n{W}(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +eo: {{o == O.Words{{F.array__thaw(U32, t), N}} : O.Words}},')
    w(f'    +eN: {{U32.to_nat(WO.len(o)) == e{W}(cnt{W}(o)) : Nat}}) -> {{U32.to_nat(N) == e{W}(U32.to_nat(U32.shrn(N, {sh}n))) : Nat}}:')
    w(f'  %Equal.cong(O.Words, U32, WO.len, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{U32.to_nat(_) == e{W}(U32.to_nat(U32.shrn(_, {sh}n))) : Nat}}')
    w('  eN')
    w('')
    w(f'def eqn_n{W}(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {{o == O.Words{{F.array__thaw(U32, t), N}} : O.Words}},')
    w(f'    +hv: {{Nat.is_eq(cnt{W}(o), L) == True{{}} : Bool}}) -> {{Nat.is_eq(U32.to_nat(U32.shrn(N, {sh}n)), L) == True{{}} : Bool}}:')
    w(f'  %Equal.cong(O.Words, U32, WO.len, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{Nat.is_eq(U32.to_nat(U32.shrn(_, {sh}n)), L) == True{{}} : Bool}}')
    w('  hv')
    w('')
    w(f'def le_n{W}(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {{o == O.Words{{F.array__thaw(U32, t), N}} : O.Words}},')
    w(f'    +hv: {{Nat.is_eq(cnt{W}(o), L) == True{{}} : Bool}}) -> {{Nat.is_le(U32.to_nat(U32.shrn(N, {sh}n)), L) == True{{}} : Bool}}:')
    w(f'  eq_le(U32.to_nat(U32.shrn(N, {sh}n)), L, eqn_n{W}(o, t, N, L, eo, hv))')
    w('')
    w(f'# m{W}(c) words fit the array: {W}c = 32q + r <= 32(q + 1) bytes, so m{W}(c) <= 8(q + 1) words.')
    w(f'def words_fit{W}(+c: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,')
    w(f'    +ec: {{Nat.add(WS.e32(q), r) == e{W}(c) : Nat}},')
    w('    +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w('    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},')
    w('    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})')
    w(f'    -> {{Nat.is_le(m{W}(c), F.spec_common__length(U32, F.array__slots(U32, t))) == True{{}} : Bool}}:')
    w('  +a1 = Order.add_left(WS.e32(q), r, 32n, h32)')
    w(f'  +a2 = UL.rw_le_l(Nat.add(WS.e32(q), r), e{W}(c), Nat.add(WS.e32(q), 32n), ec, a1)')
    w(f'  +a3 = UL.rw_le_r(e{W}(c), Nat.add(WS.e32(q), 32n), WS.e32(1n+q), UL.add32(q), a2)')
    w(f'  +a4 = UL.dbl_cancel(m{W}(c), O.e8(1n+q), UL.dbl_cancel(Nat.double(m{W}(c)), Nat.double(O.e8(1n+q)), a3))')
    w(f'  Order.transitive(m{W}(c), O.e8(1n+q), F.spec_common__length(U32, F.array__slots(U32, t)), a4, UL.cap_q(q, dw, t, pf, room))')
    w('')
    cN = f'U32.to_nat(U32.shrn(N, {sh}n))'
    w(f'def v{W}_enc(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,')
    w(f'    +eNN: {{U32.to_nat(N) == e{W}({cN}) : Nat}},')
    w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
    w('    +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w('    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},')
    w('    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})')
    w(f'    -> {{RR.basic_bytes(it{W}({cN}, F.array__slots(U32, t)), {U}) == Some{{WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))}} : {M}}}:')
    w(f'  +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), e{W}({cN}), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)')
    w(f'  %Equal.sym(Nat, U32.to_nat(N), e{W}({cN}), eNN) :')
    w(f'    {{RR.basic_bytes(it{W}({cN}, F.array__slots(U32, t)), {U}) == Some{{WS.btake(_, FX.limbs(F.array__slots(U32, t)))}} : {M}}}')
    w(f'  pb{W}({cN}, F.array__slots(U32, t), words_fit{W}({cN}, q, r, dw, t, ec, h32, pf, room))')
    w('')
    lim_n = f'Nat.div(Nat.add(Nat.mul(L, {W}n), 31n), 32n)'
    w(f'def v{W}_lim(+N: U32, +q: Nat, +r: Nat, +L: Nat, +t: F.array__Tree<U32>,')
    w(f'    +eNN: {{U32.to_nat(N) == e{W}({cN}) : Nat}},')
    w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
    w('    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w(f'    +hvN: {{Nat.is_le({cN}, L) == True{{}} : Bool}})')
    w(f'    -> {{Nat.is_le(MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), {lim_n}) == True{{}} : Bool}}:')
    w(f'  +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), e{W}({cN}), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)')
    w(f'  +hm = UL.rw_le_r(e{W}({cN}), e{W}(L), Nat.mul(L, {W}n), e{W}_mul(L), e{W}_mono({cN}, L, hvN))')
    w(f'  +hn = UL.rw_le_l(e{W}({cN}), Nat.add(WS.e32(q), r), Nat.mul(L, {W}n), Equal.sym(Nat, Nat.add(WS.e32(q), r), e{W}({cN}), ec), hm)')
    w(f'  LR.bl_hlen(q, t, Nat.mul(L, {W}n), NF.chunk_le(q, r, Nat.mul(L, {W}n), h1, h32, hn))')
    w('')
    V = f'S.Vector{{{U}, L}}'
    dig = 'WO.wdig(hl, _, depth)'
    w(f'def v{W}_body(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -o: O.Words, +L: Nat, +depth: Nat,')
    w('    +wf: WO.wf1(o),')
    w(f'    +eN: {{U32.to_nat(WO.len(o)) == e{W}(cnt{W}(o)) : Nat}},')
    w(f'    +hv: {{Nat.is_eq(cnt{W}(o), L) == True{{}} : Bool}},')
    w(f'    +hmin: {{Lim.minimal({lim_n}, depth) == True{{}} : Bool}},')
    w('    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})')
    w(f'    -> RR.roots(vview{W}(o), {V}, [D.bytes(WO.wdig(hl, o, depth))]):')
    w('  (+t, w1) = wf')
    w('  (+dw, w2) = w1')
    w('  (+N, w3) = w2')
    w('  (+q, w4) = w3')
    w('  (+r, w5) = w4')
    w('  (+eo, w6) = w5')
    w('  (+pf, w7) = w6')
    w('  (+hd, w8) = w7')
    w('  (+enq, w9) = w8')
    w('  (+h1, w10) = w9')
    w('  (+h32, w11) = w10')
    w('  (+room, +slack) = w11')
    w(f'  +eNN = eq_n{W}(o, t, N, eo, eN)')
    w(f'  +hvN = le_n{W}(o, t, N, L, eo, hv)')
    w('  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :')
    w(f'    RR.roots(vview{W}(_), {V}, [D.bytes({dig})])')
    w('  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
    w(f'    RR.roots(S.Sequence{{it{W}({cN}, F.array__slots(U32, _))}}, {V}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n))])')
    w('  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :')
    w(f'    RR.roots(S.Sequence{{it{W}({cN}, F.array__slots(U32, t))}}, {V}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n))])')
    w('  (MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)),')
    w(f'    ((WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t))), (v{W}_enc(N, q, r, dw, t, eNN, enq, h32, pf, room), UL.ul_pack(N, q, r, dw, t, enq, h1, h32, pf, room, slack))),')
    w('     (D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n)),')
    w(f'      ((depth, (hmin, RS.at_depth_tree({lim_n}, depth, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), hdep, v{W}_lim(N, q, r, L, t, eNN, enq, h1, h32, hvN), ehl))),')
    w('       {==}))))')
    w('')
    w(f'# A vector of uint{8 * W}: its digest is a specification root of its elements.')
    w(f'def v{W}_rs(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -o: O.Words, +s: S.Schema, +depth: Nat,')
    w(f'    +rep: rep_v{W}(o, s),')
    w(f'    +ok: {{ok_v{W}(s, depth) == True{{}} : Bool}},')
    w('    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})')
    w(f'    -> RR.roots(vview{W}(o), s, [D.bytes(WO.wdig(hl, o, depth))]):')
    w('  (+wf, +r1) = rep')
    w('  (+eN, +hq) = r1')
    w(f'  +c0 = DK.and_l(SH.is_Vector(s), {c1}, ok)')
    w(f'  +k1 = DK.and_r(SH.is_Vector(s), {c1}, ok)')
    w(f'  +c1 = DK.and_l(SH.is_Unsigned(SH.Vector_element(s)), {c2}, k1)')
    w(f'  +k2 = DK.and_r(SH.is_Unsigned(SH.Vector_element(s)), {c2}, k1)')
    w(f'  +c2 = DK.and_l(is_{nm}(SH.Unsigned_width(SH.Vector_element(s))), {c3}, k2)')
    w(f'  +c3 = DK.and_r(is_{nm}(SH.Unsigned_width(SH.Vector_element(s))), {c3}, k2)')
    w('  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, c0)) :')
    w(f'    RR.roots(vview{W}(o), _, [D.bytes(WO.wdig(hl, o, depth))])')
    w('  %Equal.sym(S.Schema, SH.Vector_element(s), S.Unsigned{SH.Unsigned_width(SH.Vector_element(s))}, SH.Unsigned_shape(SH.Vector_element(s), c1)) :')
    w(f'    RR.roots(vview{W}(o), S.Vector{{_, SH.Vector_length(s)}}, [D.bytes(WO.wdig(hl, o, depth))])')
    w(f'  %Equal.sym(P.Width, SH.Unsigned_width(SH.Vector_element(s)), {WID[W]}, is_{nm}_shape(SH.Unsigned_width(SH.Vector_element(s)), c2)) :')
    w(f'    RR.roots(vview{W}(o), S.Vector{{S.Unsigned{{_}}, SH.Vector_length(s)}}, [D.bytes(WO.wdig(hl, o, depth))])')
    w(f'  v{W}_body(hl, ehl, o, SH.Vector_length(s), depth, wf, eN, hq, c3, hdep)')
    w('')


HEAD = '''import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../../proofs/integer_encoding.bend as IE
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_obj.bend as WO
import ./list_root.bend as LR
import ./ulist_obj.bend as UL
import ./nat_facts.bend as NF
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# GENERATED by packed_vector_root_laws (codegen). Do not edit.
# Vectors of uint32/64/128/256 held as packed words (O.Words): the runtime root
# is the byte storage's tree (words_obj bv_st); the specification's is the
# basic-sequence root of the elements (spec/root_relation.bend `sequence`, no
# length mixed in).

law eq_le:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_eq(a, b) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def eq_le(a, b, e):
  %WS.nat_eq(a, b, e) : {Nat.is_le(a, _) == True{} : Bool}
  WS.le_refl(a)
'''


def emit():
    L = [HEAD]
    for W in (4, 8, 16, 32):
        emit_width(W, L.append)
    return '\n'.join(L)


HEAD2 = """import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../../proofs/integer_encoding.bend as IE
import ../../proofs/integer_decoding.bend as ID
import ../../proofs/power_division.bend as PD
import ../../proofs/word_split.bend as WSp
import ../../proofs/primitive_invariants.bend as V
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_obj.bend as WO
import ./list_root.bend as LR
import ./ulist_obj.bend as UL
import ./packed_obj.bend as PK
import ./nat_facts.bend as NF
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# GENERATED by packed_vector_root_laws (codegen). Do not edit.
# Vectors of uint8 and of boolean held as packed bytes (O.Words, one byte per
# element): the runtime root is the byte storage's tree (words_obj bv_st); the
# specification's is the basic-sequence root of the elements. A uint8 element
# is its byte (every storage byte is below 256: words_spec chunk_scope); a
# boolean element is `byte == 1`, and the representation invariant of boolean
# storage says every byte is 0 or 1 (`bscope`), which is what the generated
# validator checks (O.bools_ok).
"""


def bits8(prefix, low_first):
    return prefix


def emit_bytes(w):
    M = 'Maybe<&2, +List<U32>>'
    A = [f'a{i}' for i in range(8)]
    low = 'WNil{}'
    for a in reversed(A):
        low = f'WCon{{{a}, {low}}}'
    X = f'PD.embed8({low})'
    ZERO = 'SP.limb_digits(0)'
    R = ZERO
    for _ in range(6):
        R = f'List.append(&2, U32, {ZERO}, {R})'
    w('law andt:')
    w('  for +a: Bool')
    w('  {Bool.and(a, True{}) == a : Bool}')
    w('def andt(a):')
    w('  match a:')
    w('    case True{}: {==}')
    w('    case False{}: {==}')
    w('')
    w('law andf:')
    w('  for +a: Bool')
    w('  {Bool.and(a, False{}) == False{} : Bool}')
    w('def andf(a):')
    w('  match a:')
    w('    case True{}: {==}')
    w('    case False{}: {==}')
    w('')
    w('law mul1:')
    w('  for +L: Nat')
    w('  {L == Nat.mul(L, 1n) : Nat}')
    w('def mul1(L):')
    w('  match L:')
    w('    case 0n: {==}')
    w('    case 1n+ +p:')
    w('      %mul1(p) : {1n+p == 1n+_ : Nat}')
    w('      {==}')
    w('')
    # one uint8 element
    w('# A byte below 256 is its own uint8 encoding.')
    w('law bone8:')
    w('  for +w8: Word(8n)')
    w(f'  {{RR.basic_one(S.UnsignedValue{{P.UInt{{PD.embed8(w8), 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U8{{}}}}) == Some{{[PD.embed8(w8)]}} : {M}}}')
    w('def bone8(w8):')
    w('  match w8:')
    w(f'    case {low.replace("WCon{a", "WCon{+a")}:')
    w(f'      %IE.limb_correct({X}) :')
    w(f'        {{SP.optional(SP.fits(1n, List.append(&2, U32, _, {R})), SP.prefix(1n, List.append(&2, U32, _, {R}))) == Some{{[{X}]}} : {M}}}')
    for i in range(8):
        bits = A[:i] + ['_'] + [f'Bool.and({a}, True{{}})' for a in A[i + 1:]]
        e = 'Word.zero(24n)'
        for b in reversed(bits):
            e = f'WCon{{{b}, {e}}}'
        w(f'      %Equal.sym(Bool, Bool.and(a{i}, True{{}}), a{i}, andt(a{i})) :')
        w(f'        {{Some{{[U32{{{e}}}]}} == Some{{[{X}]}} : {M}}}')
    w('      {==}')
    w('')
    w('law bone:')
    w('  for +x: U32')
    w('  for +e: {U32.is_lt(x, 256) == True{} : Bool}')
    w(f'  {{RR.basic_one(S.UnsignedValue{{P.UInt{{x, 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U8{{}}}}) == Some{{[x]}} : {M}}}')
    w('def bone(x, e):')
    w('  %Equal.sym(U32, x, PD.embed8(WSp.take(8n, 32n, PD.bits(x))), ID.byte_shape(x, e)) :')
    w(f'    {{RR.basic_one(S.UnsignedValue{{P.UInt{{_, 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U8{{}}}}) == Some{{[_]}} : {M}}}')
    w('  bone8(WSp.take(8n, 32n, PD.bits(x)))')
    w('')
    # one boolean element
    w('# A byte below 2 is the encoding of the boolean `byte == 1`.')
    w('def bbool1(+a0: Bool) -> {RR.basic_one(S.BooleanValue{U32.is_eq(U32{WCon{a0, Word.zero(31n)}}, 1)}, S.Boolean{}) == Some{[U32{WCon{a0, Word.zero(31n)}}]} : ' + M + '}:')
    w('  match a0:')
    w('    case True{}: {==}')
    w('    case False{}: {==}')
    w('')
    w('law bbool:')
    w('  for +x: U32')
    w('  for +e: {U32.is_lt(x, 2) == True{} : Bool}')
    w(f'  {{RR.basic_one(S.BooleanValue{{U32.is_eq(x, 1)}}, S.Boolean{{}}) == Some{{[x]}} : {M}}}')
    w('def bbool(x, e):')
    w('  match x:')
    w('    case U32{WCon{+a0, +hi}}:')
    w('      %Equal.sym(Word(31n), hi, Word.zero(31n), WSp.below_one(30n, hi, WSp.lt_prefix(1n, 31n, WCon{a0, WNil{}}, hi, WCon{True{}, Word.zero(30n)}, e))) :')
    w(f'        {{RR.basic_one(S.BooleanValue{{U32.is_eq(U32{{WCon{{a0, _}}}}, 1)}}, S.Boolean{{}}) == Some{{[U32{{WCon{{a0, _}}}}]}} : {M}}}')
    w('      bbool1(a0)')
    w('')
    for kind in ('u8', 'bool'):
        emit_bytes_kind(kind, w)


def emit_bytes_kind(kind, w):
    M = 'Maybe<&2, +List<U32>>'
    K = 'b' if kind == 'bool' else '1'
    E = 'S.Boolean{}' if kind == 'bool' else 'S.Unsigned{P.U8{}}'
    val = 'S.BooleanValue{U32.is_eq(x, 1)}' if kind == 'bool' else 'S.UnsignedValue{P.UInt{x, 0, 0, 0, 0, 0, 0, 0}}'
    bound = '2' if kind == 'bool' else '256'
    scope = 'bscope' if kind == 'bool' else 'SP.byte_scope'
    one = 'bbool' if kind == 'bool' else 'bone'
    w(f'# ---- {"boolean" if kind == "bool" else "uint8"}: one byte per element ' + '-' * 40)
    w('')
    if kind == 'bool':
        w('# Exactly n bytes, each 0 or 1.')
        w('def bscope(n: Nat, xs: +List<U32>) -> Bool:')
        w('  match n:')
        w('    case 0n:')
        w('      match xs:')
        w('        case Nil{}: True{}')
        w('        case Con{h, t}: False{}')
        w('    case 1n+p:')
        w('      match xs:')
        w('        case Nil{}: False{}')
        w('        case Con{h, t}: Bool.and(U32.is_lt(h, 2), bscope(p, t))')
        w('')
    w(f'def it{K}(k: Nat, xs: +List<U32>) -> S.Value:')
    w('  match k:')
    w('    case 0n: S.EmptyItems{}')
    w('    case 1n+c:')
    w('      match xs:')
    w('        case Nil{}: S.EmptyItems{}')
    w(f'        case Con{{+x, t}}: S.Items{{{val}, it{K}(c, t)}}')
    w('')
    goal = lambda k, xs: f'{{RR.basic_bytes(it{K}({k}, {xs}), {E}) == Some{{{xs}}} : {M}}}'
    w(f'law pb{K}:')
    w('  for +k: Nat')
    w('  for +xs: +List<U32>')
    w(f'  for +hs: {{{scope}(k, xs) == True{{}} : Bool}}')
    w(f'  {goal("k", "xs")}')
    w(f'def pb{K}(k, xs, hs):')
    w('  match k:')
    w('    case 0n:')
    w('      match xs:')
    w('        case Nil{}: {==}')
    w(f'        case Con{{+h, +t}}: Empty.absurd({goal("0n", "Con{h, t}")}, MD.false_true(hs))')
    w('    case 1n+ +c:')
    w('      match xs:')
    w(f'        case Nil{{}}: Empty.absurd({goal("1n+c", "Nil{}")}, MD.false_true(hs))')
    w('        case Con{+h, +t}:')
    w(f'          +hh = V.and_left(U32.is_lt(h, {bound}), {scope}(c, t), hs)')
    w(f'          +ht = V.and_right(U32.is_lt(h, {bound}), {scope}(c, t), hs)')
    hval = val.replace('(x, 1)', '(h, 1)').replace('UInt{x,', 'UInt{h,')
    w(f'          %Equal.sym({M}, RR.basic_one({hval}, {E}), Some{{[h]}}, {one}(h, hh)) :')
    w(f'            {{RR.join(_, RR.basic_bytes(it{K}(c, t), {E})) == Some{{Con{{h, t}}}} : {M}}}')
    w(f'          %Equal.sym({M}, RR.basic_bytes(it{K}(c, t), {E}), Some{{t}}, pb{K}(c, t, ht)) :')
    w(f'            {{RR.join(Some{{[h]}}, _) == Some{{Con{{h, t}}}} : {M}}}')
    w('          {==}')
    w('')
    view = f'it{K}(U32.to_nat(n), WS.btake(U32.to_nat(n), FX.limbs(F.array__slots(U32, F.array__freeze(U32, ws)))))'
    w(f'def vview{K}(o: O.Words) -> S.Value:')
    w('  match o:')
    w(f'    case O.Words{{ws, +n}}: S.Sequence{{{view}}}')
    w('')
    extra = ', DK.P2({Nat.is_eq(U32.to_nat(WO.len(o)), SH.Vector_length(s)) == True{} : Bool}, {bscope(U32.to_nat(WO.len(o)), WO.wview(o)) == True{} : Bool})' if kind == 'bool' \
        else ', {Nat.is_eq(U32.to_nat(WO.len(o)), SH.Vector_length(s)) == True{} : Bool}'
    w(f'# The object represents a value of the vector schema s: nonempty byte storage')
    w(f'# of as many bytes as the vector length' + (', each 0 or 1.' if kind == 'bool' else '.'))
    w(f'def rep_v{K}(o: O.Words, +s: S.Schema) -> Data:')
    w(f'  DK.P2(WO.wf1(o){extra})')
    w('')
    w(f'def rep_wf{K}(-o: O.Words, +s: S.Schema, +rep: rep_v{K}(o, s)) -> WO.wf1(o):')
    w('  (+wf, +r) = rep')
    w('  wf')
    w('')
    lim = 'Nat.div(Nat.add(Nat.mul(SH.Vector_length(s), 1n), 31n), 32n)'
    c3 = f'Lim.minimal({lim}, depth)'
    if kind == 'bool':
        c1 = f'Bool.and(SH.is_Boolean(SH.Vector_element(s)), {c3})'
    else:
        c2 = f'Bool.and(UL_is_U8(SH.Unsigned_width(SH.Vector_element(s))), {c3})'.replace('UL_is_U8', 'is_U8')
        c1 = f'Bool.and(SH.is_Unsigned(SH.Vector_element(s)), {c2})'
        w('def is_U8(w: P.Width) -> Bool:')
        w('  match w:')
        w('    case P.U8{}: True{}')
        w('    case _: False{}')
        w('')
        w('law is_U8_shape:')
        w('  for +w: P.Width')
        w('  for +e: {is_U8(w) == True{} : Bool}')
        w('  {w == P.U8{} : P.Width}')
        w('def is_U8_shape(w, e):')
        w('  match w:')
        for x in ['P.U8{}', 'P.U16{}', 'P.U32Width{}', 'P.U64{}', 'P.U128{}', 'P.U256{}']:
            w(f'    case {x}: ' + ('{==}' if x == 'P.U8{}' else f'Empty.absurd({{{x} == P.U8{{}} : P.Width}}, MD.false_true(e))'))
        w('')
    w(f'def ok_v{K}(+s: S.Schema, +depth: Nat) -> Bool:')
    w(f'  Bool.and(SH.is_Vector(s), {c1})')
    w('')
    lim_n = 'Nat.div(Nat.add(Nat.mul(L, 1n), 31n), 32n)'
    slots = 'F.array__slots(U32, t)'
    bytes_ = f'WS.btake(U32.to_nat(N), FX.limbs({slots}))'
    if kind == 'u8':
        w('# The storage bytes are bytes (the chunk scope of the storage).')
        w('def vscope(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,')
        w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
        w('    +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
        w('    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},')
        w('    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})')
        w(f'    -> {{SP.byte_scope(U32.to_nat(N), {bytes_}) == True{{}} : Bool}}:')
        w('  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq) :')
        w(f'    {{SP.byte_scope(_, WS.btake(_, FX.limbs({slots}))) == True{{}} : Bool}}')
        w(f'  WS.chunk_scope(q, r, {slots}, 0n, h32, WR.cap_at(q, dw, t, pf, room))')
        w('')
    else:
        w('# The boolean fact about the object, about its destructured storage.')
        w('def bsc(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},')
        w('    +hb: {bscope(U32.to_nat(WO.len(o)), WO.wview(o)) == True{} : Bool})')
        w(f'    -> {{bscope(U32.to_nat(N), {bytes_}) == True{{}} : Bool}}:')
        w('  %F.array__freeze_thaw(U32, t) :')
        w('    {bscope(U32.to_nat(N), WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, _)))) == True{} : Bool}')
        w('  %Equal.cong(O.Words, Bool, x => bscope(U32.to_nat(WO.len(x)), WO.wview(x)), o, O.Words{F.array__thaw(U32, t), N}, eo) : {_ == True{} : Bool}')
        w('  hb')
        w('')
    w(f'def v{K}_lim(+N: U32, +q: Nat, +r: Nat, +L: Nat, +t: F.array__Tree<U32>,')
    w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
    w('    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w('    +hvN: {Nat.is_le(U32.to_nat(N), L) == True{} : Bool})')
    w(f'    -> {{Nat.is_le(MD.dlen(MR.clist(1n+q, {slots}, 0n)), {lim_n}) == True{{}} : Bool}}:')
    w('  +hm = UL.rw_le_r(U32.to_nat(N), L, Nat.mul(L, 1n), mul1(L), hvN)')
    w('  +hn = UL.rw_le_l(U32.to_nat(N), Nat.add(WS.e32(q), r), Nat.mul(L, 1n), enq, hm)')
    w('  LR.bl_hlen(q, t, Nat.mul(L, 1n), NF.chunk_le(q, r, Nat.mul(L, 1n), h1, h32, hn))')
    w('')
    V_ = f'S.Vector{{{E}, L}}'
    extra_arg = '    +hb: {bscope(U32.to_nat(WO.len(o)), WO.wview(o)) == True{} : Bool},\n' if kind == 'bool' else ''
    w(f'def v{K}_body(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -o: O.Words, +L: Nat, +depth: Nat,')
    w('    +wf: WO.wf1(o),')
    w('    +hv: {Nat.is_eq(U32.to_nat(WO.len(o)), L) == True{} : Bool},')
    if extra_arg:
        w(extra_arg.rstrip('\n'))
    w(f'    +hmin: {{Lim.minimal({lim_n}, depth) == True{{}} : Bool}},')
    w('    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})')
    w(f'    -> RR.roots(vview{K}(o), {V_}, [D.bytes(WO.wdig(hl, o, depth))]):')
    for i, (a, b) in enumerate([('t', 'w1'), ('dw', 'w2'), ('N', 'w3'), ('q', 'w4'), ('r', 'w5'), ('eo', 'w6'), ('pf', 'w7'), ('hd', 'w8'), ('enq', 'w9'), ('h1', 'w10'), ('h32', 'w11')]):
        w(f'  (+{a}, {b}) = {"wf" if i == 0 else "w" + str(i)}')
    w('  (+room, +slack) = w11')
    w('  +hvN = PK.eq_le(U32.to_nat(N), L, WO.eq_len(o, t, N, L, eo, hv))')
    sc = ('bsc(o, t, N, eo, hb)' if kind == 'bool' else 'vscope(N, q, r, dw, t, enq, h32, pf, room)')
    w(f'  +sc = {sc}')
    w('  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :')
    w(f'    RR.roots(vview{K}(_), {V_}, [D.bytes(WO.wdig(hl, _, depth))])')
    w('  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
    w(f'    RR.roots(S.Sequence{{it{K}(U32.to_nat(N), WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, _))))}}, {V_}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n))])')
    w('  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :')
    w(f'    RR.roots(S.Sequence{{it{K}(U32.to_nat(N), {bytes_})}}, {V_}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, {slots}, 0n), 0n))])')
    w(f'  (MD.bytes_list(MR.clist(1n+q, {slots}, 0n)),')
    w(f'    (({bytes_}, (pb{K}(U32.to_nat(N), {bytes_}, sc), UL.ul_pack(N, q, r, dw, t, enq, h1, h32, pf, room, slack))),')
    w(f'     (D.bytes(MD.rtree(depth, True{{}}, hl, MR.clist(1n+q, {slots}, 0n), 0n)),')
    w(f'      ((depth, (hmin, RS.at_depth_tree({lim_n}, depth, hl, MR.clist(1n+q, {slots}, 0n), hdep, v{K}_lim(N, q, r, L, t, enq, h1, h32, hvN), ehl))),')
    w('       {==}))))')
    w('')
    w(f'def v{K}_rs(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -o: O.Words, +s: S.Schema, +depth: Nat,')
    w(f'    +rep: rep_v{K}(o, s),')
    w(f'    +ok: {{ok_v{K}(s, depth) == True{{}} : Bool}},')
    w('    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})')
    w(f'    -> RR.roots(vview{K}(o), s, [D.bytes(WO.wdig(hl, o, depth))]):')
    if kind == 'bool':
        w('  (+wf, +r1) = rep')
        w('  (+hq, +hb) = r1')
    else:
        w('  (+wf, +hq) = rep')
    w(f'  +c0 = DK.and_l(SH.is_Vector(s), {c1}, ok)')
    w(f'  +k1 = DK.and_r(SH.is_Vector(s), {c1}, ok)')
    if kind == 'bool':
        w(f'  +c1 = DK.and_l(SH.is_Boolean(SH.Vector_element(s)), {c3}, k1)')
        w(f'  +c3 = DK.and_r(SH.is_Boolean(SH.Vector_element(s)), {c3}, k1)')
    else:
        w(f'  +c1 = DK.and_l(SH.is_Unsigned(SH.Vector_element(s)), {c2}, k1)')
        w(f'  +k2 = DK.and_r(SH.is_Unsigned(SH.Vector_element(s)), {c2}, k1)')
        w(f'  +c2 = DK.and_l(is_U8(SH.Unsigned_width(SH.Vector_element(s))), {c3}, k2)')
        w(f'  +c3 = DK.and_r(is_U8(SH.Unsigned_width(SH.Vector_element(s))), {c3}, k2)')
    w('  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, c0)) :')
    w(f'    RR.roots(vview{K}(o), _, [D.bytes(WO.wdig(hl, o, depth))])')
    if kind == 'bool':
        w('  %Equal.sym(S.Schema, SH.Vector_element(s), S.Boolean{}, SH.Boolean_shape(SH.Vector_element(s), c1)) :')
        w(f'    RR.roots(vview{K}(o), S.Vector{{_, SH.Vector_length(s)}}, [D.bytes(WO.wdig(hl, o, depth))])')
        w(f'  v{K}_body(hl, ehl, o, SH.Vector_length(s), depth, wf, hq, hb, c3, hdep)')
    else:
        w('  %Equal.sym(S.Schema, SH.Vector_element(s), S.Unsigned{SH.Unsigned_width(SH.Vector_element(s))}, SH.Unsigned_shape(SH.Vector_element(s), c1)) :')
        w(f'    RR.roots(vview{K}(o), S.Vector{{_, SH.Vector_length(s)}}, [D.bytes(WO.wdig(hl, o, depth))])')
        w('  %Equal.sym(P.Width, SH.Unsigned_width(SH.Vector_element(s)), P.U8{}, is_U8_shape(SH.Unsigned_width(SH.Vector_element(s)), c2)) :')
        w(f'    RR.roots(vview{K}(o), S.Vector{{S.Unsigned{{_}}, SH.Vector_length(s)}}, [D.bytes(WO.wdig(hl, o, depth))])')
        w(f'  v{K}_body(hl, ehl, o, SH.Vector_length(s), depth, wf, hq, c3, hdep)')
    w('')


def emit_u16(w):
    """uint16 vectors: element j is bytes 2j, 2j + 1, as the word of their 16 bits."""
    M = 'Maybe<&2, +List<U32>>'
    A = [f'a{i}' for i in range(8)]
    Bv = [f'b{i}' for i in range(8)]
    def word(bits, tail):
        e = tail
        for b in reversed(bits):
            e = f'WCon{{{b}, {e}}}'
        return e
    lowA, lowB = word(A, 'WNil{}'), word(Bv, 'WNil{}')
    V = lambda t0, t1: f'U32{{WSp.join(8n, 24n, {t0}, WSp.join(8n, 16n, {t1}, Word.zero(16n)))}}'
    ZERO = 'SP.limb_digits(0)'
    R = ZERO
    for _ in range(6):
        R = f'List.append(&2, U32, {ZERO}, {R})'
    w('# ---- uint16: two bytes per element ' + '-' * 40)
    w('')
    w('def v16of(+x0: U32, +x1: U32) -> U32: ' + V('WSp.take(8n, 32n, PD.bits(x0))', 'WSp.take(8n, 32n, PD.bits(x1))'))
    w('')
    X = V(lowA, lowB)
    E0, E1 = f'PD.embed8({lowA})', f'PD.embed8({lowB})'
    w('law two8:')
    w('  for +t0: Word(8n)')
    w('  for +t1: Word(8n)')
    w(f'  {{RR.basic_one(S.UnsignedValue{{P.UInt{{v16of(PD.embed8(t0), PD.embed8(t1)), 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U16{{}}}}) == Some{{[PD.embed8(t0), PD.embed8(t1)]}} : {M}}}')
    w('def two8(t0, t1):')
    w('  match t0 t1:')
    w(f'    case {lowA.replace("WCon{a", "WCon{+a")} {lowB.replace("WCon{b", "WCon{+b")}:')
    w(f'      %IE.limb_correct({X}) :')
    w(f'        {{SP.optional(SP.fits(2n, List.append(&2, U32, _, {R})), SP.prefix(2n, List.append(&2, U32, _, {R}))) == Some{{[{E0}, {E1}]}} : {M}}}')
    # d0 = low byte: bits a (masked by 1) then bits b (masked by 0); d1 = bits b (masked by 1)
    st0 = [f'Bool.and({a}, True{{}})' for a in A]
    st0b = [f'Bool.and({b}, False{{}})' for b in Bv]
    st1 = [f'Bool.and({b}, True{{}})' for b in Bv]
    def show(x0, x0b, x1):
        d0 = word(x0 + x0b, 'Word.zero(16n)')
        d1 = word(x1, 'Word.zero(24n)')
        return f'{{Some{{[U32{{{d0}}}, U32{{{d1}}}]}} == Some{{[{E0}, {E1}]}} : {M}}}'
    for i in range(8):
        cur = st0[:i] + ['_'] + st0[i + 1:]
        w(f'      %Equal.sym(Bool, Bool.and({A[i]}, True{{}}), {A[i]}, andt({A[i]})) :')
        w(f'        {show(cur, st0b, st1)}')
        st0[i] = A[i]
    for i in range(8):
        cur = st0b[:i] + ['_'] + st0b[i + 1:]
        w(f'      %Equal.sym(Bool, Bool.and({Bv[i]}, False{{}}), False{{}}, andf({Bv[i]})) :')
        w(f'        {show(st0, cur, st1)}')
        st0b[i] = 'False{}'
    for i in range(8):
        cur = st1[:i] + ['_'] + st1[i + 1:]
        w(f'      %Equal.sym(Bool, Bool.and({Bv[i]}, True{{}}), {Bv[i]}, andt({Bv[i]})) :')
        w(f'        {show(st0, st0b, cur)}')
        st1[i] = Bv[i]
    w('      {==}')
    w('')
    w('law two:')
    w('  for +x0: U32')
    w('  for +x1: U32')
    w('  for +e0: {U32.is_lt(x0, 256) == True{} : Bool}')
    w('  for +e1: {U32.is_lt(x1, 256) == True{} : Bool}')
    w(f'  {{RR.basic_one(S.UnsignedValue{{P.UInt{{v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U16{{}}}}) == Some{{[x0, x1]}} : {M}}}')
    w('def two(x0, x1, e0, e1):')
    w('  %Equal.sym(U32, x0, PD.embed8(WSp.take(8n, 32n, PD.bits(x0))), ID.byte_shape(x0, e0)) :')
    w(f'    {{RR.basic_one(S.UnsignedValue{{P.UInt{{v16of(_, x1), 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U16{{}}}}) == Some{{[_, x1]}} : {M}}}')
    w('  %Equal.sym(U32, x1, PD.embed8(WSp.take(8n, 32n, PD.bits(x1))), ID.byte_shape(x1, e1)) :')
    w(f'    {{RR.basic_one(S.UnsignedValue{{P.UInt{{v16of(PD.embed8(WSp.take(8n, 32n, PD.bits(x0))), _), 0, 0, 0, 0, 0, 0, 0}}}}, S.Unsigned{{P.U16{{}}}}) == Some{{[PD.embed8(WSp.take(8n, 32n, PD.bits(x0))), _]}} : {M}}}')
    w('  two8(WSp.take(8n, 32n, PD.bits(x0)), WSp.take(8n, 32n, PD.bits(x1)))')
    w('')
    w('def it2(k: Nat, xs: +List<U32>) -> S.Value:')
    w('  match k:')
    w('    case 0n: S.EmptyItems{}')
    w('    case 1n+c:')
    w('      match xs:')
    w('        case Nil{}: S.EmptyItems{}')
    w('        case Con{+x0, t}:')
    w('          match t:')
    w('            case Nil{}: S.EmptyItems{}')
    w('            case Con{+x1, rest}: S.Items{S.UnsignedValue{P.UInt{v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, it2(c, rest)}')
    w('')
    E = 'S.Unsigned{P.U16{}}'
    goal = lambda k, xs: f'{{RR.basic_bytes(it2({k}, {xs}), {E}) == Some{{{xs}}} : {M}}}'
    w('law pb2:')
    w('  for +k: Nat')
    w('  for +xs: +List<U32>')
    w('  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}')
    w(f'  {goal("k", "xs")}')
    w('def pb2(k, xs, hs):')
    w('  match k:')
    w('    case 0n:')
    w('      match xs:')
    w('        case Nil{}: {==}')
    w(f'        case Con{{+h, +t}}: Empty.absurd({goal("0n", "Con{h, t}")}, MD.false_true(hs))')
    w('    case 1n+ +c:')
    w('      match xs:')
    w(f'        case Nil{{}}: Empty.absurd({goal("1n+c", "Nil{}")}, MD.false_true(hs))')
    w('        case Con{+x0, +t}:')
    w('          match t:')
    w(f'            case Nil{{}}: Empty.absurd({goal("1n+c", "Con{x0, Nil{}}")}, MD.false_true(V.and_right(U32.is_lt(x0, 256), False{{}}, hs)))')
    w('            case Con{+x1, +rest}:')
    w('              +e0 = V.and_left(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)')
    w('              +k1 = V.and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)')
    w('              +e1 = V.and_left(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1)')
    w('              +hr = V.and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1)')
    w(f'              %Equal.sym({M}, RR.basic_one(S.UnsignedValue{{P.UInt{{v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}}}, {E}), Some{{[x0, x1]}}, two(x0, x1, e0, e1)) :')
    w(f'                {{RR.join(_, RR.basic_bytes(it2(c, rest), {E})) == Some{{Con{{x0, Con{{x1, rest}}}}}} : {M}}}')
    w(f'              %Equal.sym({M}, RR.basic_bytes(it2(c, rest), {E}), Some{{rest}}, pb2(c, rest, hr)) :')
    w(f'                {{RR.join(Some{{[x0, x1]}}, _) == Some{{Con{{x0, Con{{x1, rest}}}}}} : {M}}}')
    w('              {==}')
    w('')
    slots = 'F.array__slots(U32, t)'
    bytes_ = f'WS.btake(U32.to_nat(N), FX.limbs({slots}))'
    cN = 'U32.to_nat(U32.shrn(N, 1n))'
    w('def cnt2(o: O.Words) -> Nat: U32.to_nat(U32.shrn(WO.len(o), 1n))')
    w('')
    w('def vview2(o: O.Words) -> S.Value:')
    w('  match o:')
    w('    case O.Words{ws, +n}: S.Sequence{it2(U32.to_nat(U32.shrn(n, 1n)), WS.btake(U32.to_nat(n), FX.limbs(F.array__slots(U32, F.array__freeze(U32, ws)))))}')
    w('')
    w('# The object represents a value of the vector schema s: nonempty byte storage')
    w('# of whole elements (two bytes each), as many as the vector length.')
    w('def rep_v2(o: O.Words, +s: S.Schema) -> Data:')
    w('  DK.P2(WO.wf1(o), DK.P2({U32.to_nat(WO.len(o)) == Nat.double(cnt2(o)) : Nat}, {Nat.is_eq(cnt2(o), SH.Vector_length(s)) == True{} : Bool}))')
    w('')
    w('def rep_wf2(-o: O.Words, +s: S.Schema, +rep: rep_v2(o, s)) -> WO.wf1(o):')
    w('  (+wf, +r) = rep')
    w('  wf')
    w('')
    w('def is_U16(w: P.Width) -> Bool:')
    w('  match w:')
    w('    case P.U16{}: True{}')
    w('    case _: False{}')
    w('')
    w('law is_U16_shape:')
    w('  for +w: P.Width')
    w('  for +e: {is_U16(w) == True{} : Bool}')
    w('  {w == P.U16{} : P.Width}')
    w('def is_U16_shape(w, e):')
    w('  match w:')
    for x in ['P.U8{}', 'P.U16{}', 'P.U32Width{}', 'P.U64{}', 'P.U128{}', 'P.U256{}']:
        w(f'    case {x}: ' + ('{==}' if x == 'P.U16{}' else f'Empty.absurd({{{x} == P.U16{{}} : P.Width}}, MD.false_true(e))'))
    w('')
    lim = 'Nat.div(Nat.add(Nat.mul(SH.Vector_length(s), 2n), 31n), 32n)'
    c3 = f'Lim.minimal({lim}, depth)'
    c2 = f'Bool.and(is_U16(SH.Unsigned_width(SH.Vector_element(s))), {c3})'
    c1 = f'Bool.and(SH.is_Unsigned(SH.Vector_element(s)), {c2})'
    w('def ok_v2(+s: S.Schema, +depth: Nat) -> Bool:')
    w(f'  Bool.and(SH.is_Vector(s), {c1})')
    w('')
    w('law dbl_mul:')
    w('  for +L: Nat')
    w('  {Nat.double(L) == Nat.mul(L, 2n) : Nat}')
    w('def dbl_mul(L):')
    w('  match L:')
    w('    case 0n: {==}')
    w('    case 1n+ +p:')
    w('      %Equal.sym(Nat, Nat.double(p), Nat.mul(p, 2n), dbl_mul(p)) : {2n+_ == Nat.add(2n, Nat.mul(p, 2n)) : Nat}')
    w('      {==}')
    w('')
    w('def eq_n2(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},')
    w(f'    +eN: {{U32.to_nat(WO.len(o)) == Nat.double(cnt2(o)) : Nat}}) -> {{U32.to_nat(N) == Nat.double({cN}) : Nat}}:')
    w('  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {U32.to_nat(_) == Nat.double(U32.to_nat(U32.shrn(_, 1n))) : Nat}')
    w('  eN')
    w('')
    w('def eqn_n2(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},')
    w(f'    +hv: {{Nat.is_eq(cnt2(o), L) == True{{}} : Bool}}) -> {{Nat.is_eq({cN}, L) == True{{}} : Bool}}:')
    w('  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(U32.to_nat(U32.shrn(_, 1n)), L) == True{} : Bool}')
    w('  hv')
    w('')
    w('def v2_scope(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,')
    w(f'    +eNN: {{U32.to_nat(N) == Nat.double({cN}) : Nat}},')
    w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
    w('    +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w('    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},')
    w('    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})')
    w(f'    -> {{SP.byte_scope(Nat.double({cN}), {bytes_}) == True{{}} : Bool}}:')
    w(f'  %eNN : {{SP.byte_scope(_, {bytes_}) == True{{}} : Bool}}')
    w('  vscope(N, q, r, dw, t, enq, h32, pf, room)')
    w('')
    w('def v2_enc(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,')
    w(f'    +eNN: {{U32.to_nat(N) == Nat.double({cN}) : Nat}},')
    w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
    w('    +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w('    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},')
    w('    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})')
    w(f'    -> {{RR.basic_bytes(it2({cN}, {bytes_}), {E}) == Some{{{bytes_}}} : {M}}}:')
    w(f'  pb2({cN}, {bytes_}, v2_scope(N, q, r, dw, t, eNN, enq, h32, pf, room))')
    w('')
    lim_n = 'Nat.div(Nat.add(Nat.mul(L, 2n), 31n), 32n)'
    w('def v2_lim(+N: U32, +q: Nat, +r: Nat, +L: Nat, +t: F.array__Tree<U32>,')
    w(f'    +eNN: {{U32.to_nat(N) == Nat.double({cN}) : Nat}},')
    w('    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},')
    w('    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},')
    w(f'    +hvN: {{Nat.is_le({cN}, L) == True{{}} : Bool}})')
    w(f'    -> {{Nat.is_le(MD.dlen(MR.clist(1n+q, {slots}, 0n)), {lim_n}) == True{{}} : Bool}}:')
    w(f'  +hd = Order.double_monotone({cN}, L, hvN)')
    w(f'  +hm = UL.rw_le_r(Nat.double({cN}), Nat.double(L), Nat.mul(L, 2n), dbl_mul(L), hd)')
    w(f'  +hN = UL.rw_le_l(Nat.double({cN}), U32.to_nat(N), Nat.mul(L, 2n), Equal.sym(Nat, U32.to_nat(N), Nat.double({cN}), eNN), hm)')
    w('  +hn = UL.rw_le_l(U32.to_nat(N), Nat.add(WS.e32(q), r), Nat.mul(L, 2n), enq, hN)')
    w('  LR.bl_hlen(q, t, Nat.mul(L, 2n), NF.chunk_le(q, r, Nat.mul(L, 2n), h1, h32, hn))')
    w('')
    V_ = f'S.Vector{{{E}, L}}'
    w('def v2_body(+hl: Nat, +ehl: {hl == 64n : Nat}, -o: O.Words, +L: Nat, +depth: Nat,')
    w('    +wf: WO.wf1(o),')
    w('    +eN: {U32.to_nat(WO.len(o)) == Nat.double(cnt2(o)) : Nat},')
    w('    +hv: {Nat.is_eq(cnt2(o), L) == True{} : Bool},')
    w(f'    +hmin: {{Lim.minimal({lim_n}, depth) == True{{}} : Bool}},')
    w('    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})')
    w(f'    -> RR.roots(vview2(o), {V_}, [D.bytes(WO.wdig(hl, o, depth))]):')
    for i, (a, b) in enumerate([('t', 'w1'), ('dw', 'w2'), ('N', 'w3'), ('q', 'w4'), ('r', 'w5'), ('eo', 'w6'), ('pf', 'w7'), ('hd', 'w8'), ('enq', 'w9'), ('h1', 'w10'), ('h32', 'w11')]):
        w(f'  (+{a}, {b}) = {"wf" if i == 0 else "w" + str(i)}')
    w('  (+room, +slack) = w11')
    w('  +eNN = eq_n2(o, t, N, eo, eN)')
    w(f'  +hvN = PK.eq_le({cN}, L, eqn_n2(o, t, N, L, eo, hv))')
    w('  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :')
    w(f'    RR.roots(vview2(_), {V_}, [D.bytes(WO.wdig(hl, _, depth))])')
    w('  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
    w(f'    RR.roots(S.Sequence{{it2({cN}, WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, _))))}}, {V_}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n))])')
    w('  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :')
    w(f'    RR.roots(S.Sequence{{it2({cN}, {bytes_})}}, {V_}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, {slots}, 0n), 0n))])')
    w(f'  (MD.bytes_list(MR.clist(1n+q, {slots}, 0n)),')
    w(f'    (({bytes_}, (v2_enc(N, q, r, dw, t, eNN, enq, h32, pf, room), UL.ul_pack(N, q, r, dw, t, enq, h1, h32, pf, room, slack))),')
    w(f'     (D.bytes(MD.rtree(depth, True{{}}, hl, MR.clist(1n+q, {slots}, 0n), 0n)),')
    w(f'      ((depth, (hmin, RS.at_depth_tree({lim_n}, depth, hl, MR.clist(1n+q, {slots}, 0n), hdep, v2_lim(N, q, r, L, t, eNN, enq, h1, h32, hvN), ehl))),')
    w('       {==}))))')
    w('')
    w('def v2_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -o: O.Words, +s: S.Schema, +depth: Nat,')
    w('    +rep: rep_v2(o, s),')
    w('    +ok: {ok_v2(s, depth) == True{} : Bool},')
    w('    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})')
    w('    -> RR.roots(vview2(o), s, [D.bytes(WO.wdig(hl, o, depth))]):')
    w('  (+wf, +r1) = rep')
    w('  (+eN, +hq) = r1')
    w(f'  +c0 = DK.and_l(SH.is_Vector(s), {c1}, ok)')
    w(f'  +k1 = DK.and_r(SH.is_Vector(s), {c1}, ok)')
    w(f'  +c1 = DK.and_l(SH.is_Unsigned(SH.Vector_element(s)), {c2}, k1)')
    w(f'  +k2 = DK.and_r(SH.is_Unsigned(SH.Vector_element(s)), {c2}, k1)')
    w(f'  +c2 = DK.and_l(is_U16(SH.Unsigned_width(SH.Vector_element(s))), {c3}, k2)')
    w(f'  +c3 = DK.and_r(is_U16(SH.Unsigned_width(SH.Vector_element(s))), {c3}, k2)')
    w('  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, c0)) :')
    w('    RR.roots(vview2(o), _, [D.bytes(WO.wdig(hl, o, depth))])')
    w('  %Equal.sym(S.Schema, SH.Vector_element(s), S.Unsigned{SH.Unsigned_width(SH.Vector_element(s))}, SH.Unsigned_shape(SH.Vector_element(s), c1)) :')
    w('    RR.roots(vview2(o), S.Vector{_, SH.Vector_length(s)}, [D.bytes(WO.wdig(hl, o, depth))])')
    w('  %Equal.sym(P.Width, SH.Unsigned_width(SH.Vector_element(s)), P.U16{}, is_U16_shape(SH.Unsigned_width(SH.Vector_element(s)), c2)) :')
    w('    RR.roots(vview2(o), S.Vector{S.Unsigned{_}, SH.Vector_length(s)}, [D.bytes(WO.wdig(hl, o, depth))])')
    w('  v2_body(hl, ehl, o, SH.Vector_length(s), depth, wf, eN, hq, c3, hdep)')
    w('')


def emit2():
    L = [HEAD2]
    emit_bytes(L.append)
    emit_u16(L.append)
    return '\n'.join(L) + '\n'


def main():
    # the views and representation invariants go to light companions: e2e files stating against them do
    # not import the root laws (codegen/proofs/support/light_definition_modules.py)
    from codegen.proofs.support import light_definition_modules as LS
    t1, l1 = LS.split(emit(), lambda n: re.match(r'(vview|rep_v|it|cnt|e)(4|8|16|32)$', n) is not None,
                      './packed_obj_light.bend', 'packed_vector_root_laws (codegen)')
    t2, l2 = LS.split(emit2(), lambda n: re.match(r'(vview(1|2|b)|rep_v(1|2|b)|it(1|2|b)|cnt2|bscope|v16of)$', n) is not None,
                      './packed_bytes_light.bend', 'packed_vector_root_laws (codegen)')
    outs = [(p, LS.light(t)) for p, t in [(OUT, t1), (OUT.with_name('packed_obj_light.bend'), l1),
                                          (OUT2, t2), (OUT2.with_name('packed_bytes_light.bend'), l2)]]
    return sync_pairs(outs, 'packed_vector_root_laws', 'packed laws are current', '--check' in sys.argv)


if __name__ == '__main__':
    sys.exit(main())
