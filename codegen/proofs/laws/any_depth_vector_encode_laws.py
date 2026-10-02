"""Encode laws of word-storage vectors at ANY storage depth (called by spec_connected_codec_laws.py).

The root laws' representation facts (packed_obj rep_v<K>, words_obj wf1; root_words'
t, dw, hd, pf, cap) allow a storage tree deeper than the one the decoder builds. The
per-name encode laws of spec_gcodec_*/spec_garr_*/spec_codec_* are stated for the
literal canonical tree. This module states, per name, under the root law's own
hypotheses only:

  <N>_encode_any : {SF.emitted(O.Words, T.<N>_encode(o), NW) == (o, WO.wview(o))}
  <N>_decodes_any: Decoding.decodes(s, WO.wview(o), PK.vview<K>(o))

for the generic uint vectors (spec_gcodec, spec_garr), and for the four Bytes32
branch names of root_words (binders t, dw, hd, pf, cap; o = O.Words{thaw t, NB}):

  <N>_encode_any : {SF.emitted(O.Words, T.<N>_encode(o), NW) == (o, VS.bt(NBn, SF.limbs(slots t)))}
  <N>_decodes_any: Decoding.decodes(Spec.<N>(), VS.bt(NBn, SF.limbs(slots t)), S.Sequence{WR.items(k, slots t, 0n)})

Proof: the writer reads only words 0 .. NW - 1 (Array.get at any depth, arr_copy
getv), so its output is the copy AC.cpt of those words into the zero output tree
(unrolled writers: one small lemma per word; whole-word acopy writers: arr_copy blk
plus wany.actl for the tail); B.emit of that tree is the limbs of its first NW
slots (arr_emit.emit_take), which are the storage's first NW slots (wany.cpt_take).
The value side is list-generic (wany.it<K>c, arr_vec vpartsu<n>).
"""
import re

from codegen.impl import typed_object_runtime as G  # noqa: F401  kept: the import may register hooks at import time
from codegen.proofs.laws import generic_form_root_laws as RG
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text

ELEM = {4: ('P.U32Width{}', 1, 2), 8: ('P.U64{}', 2, 3), 16: ('P.U128{}', 4, 4), 32: ('P.U256{}', 8, 5)}
BRANCHES = {'FinalityBranch': 7, 'CurrentSyncCommitteeBranch': 6, 'NextSyncCommitteeBranch': 6, 'ExecutionBranch': 4}
PER_FILE = 8

GHEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/generic_obj.bend as T', 'import ../../types/schema.bend as S',
         'import ../../types/primitive.bend as P', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ./generic_specs.bend as Spec', 'import ../compact/found.bend as F', 'import ../compact/arith.bend as A',
         'import ./spec_fixed.bend as SF', 'import ./schema_shapes.bend as SH', 'import ./words_spec.bend as WS',
         'import ./words_obj.bend as WO', 'import ./packed_obj.bend as PK', 'import ./arr_copy.bend as AC',
         'import ./arr_emit.bend as AE', 'import ./arr_vec.bend as AV', 'import ./arr_spec.bend as AS',
         'import ./wany.bend as WA']

WHEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
         'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../compact/found.bend as F', 'import ./spec_fixed.bend as SF', 'import ./words_root.bend as WR',
         'import ./vspec.bend as VS', 'import ./arr_copy.bend as AC', 'import ./arr_emit.bend as AE',
         'import ./wany.bend as WA']


class Skip(Exception):
    pass


def writer(src, name):
    """(kind, prefix, out depth, NB) of the name's encoder: 'unrolled' (pa0 .. pa{NW-1})
    or 'put' (O.put_words)."""
    m = re.search(r'^def ' + name + r'_encode\(o: O\.Words\) -> O\.Words & B\.Buf: ' + name + r'_enc_out\((\w+)_put\(O\.out_at\((\d+)n\), 0, o\)\)$', src, re.M)
    if not m:
        raise Skip(f'{name}: encoder shape')
    pre, c = m.group(1), int(m.group(2))
    m2 = re.search(r'^def ' + name + r'_enc_out\(pair: Array<U32> & O\.Words\) -> O\.Words & B\.Buf:\n  \(out, o\) = pair\n  \(o, O\.out_done\((\d+), out\)\)$', src, re.M)
    if not m2:
        raise Skip(f'{name}: enc_out shape')
    nb = int(m2.group(1))
    put = re.search(r'^def ' + pre + r'_put\(out: Array<U32>, \+pos: U32, o: O\.Words\) -> Array<U32> & O\.Words:(.*)$', src, re.M)
    if put.group(1).strip() == 'O.put_words(out, pos, o)':
        return 'put', pre, c, nb
    if f'{pre}_pw(' not in src or f'def {pre}_pa0(' not in src:
        raise Skip(f'{name}: writer {pre}')
    return 'unrolled', pre, c, nb


def chain(w, name, pre, c, nw, T='T'):
    """<name>_pc<j>: the unrolled writer's steps j .. nw - 1 copy words j .. nw - 1."""
    for j in range(nw - 1, -1, -1):
        rhs = f'(F.array__thaw(U32, AC.cpt({c}n, {nw - j}n, {j}n, {j}n, D, F.array__slots(U32, t))), F.array__thaw(U32, t))'
        w(f'def {name}_pc{j}(+D: F.array__Tree<U32>, +t: F.array__Tree<U32>, +ds: Nat, +hs: {{Nat.is_lt(ds, 32n) == True{{}} : Bool}}, +ps: {{F.array__perfect(U32, ds, t) == True{{}} : Bool}},')
        w(f'    +hn: {{Nat.is_le({nw}n, F.spec_common__pow2(ds)) == True{{}} : Bool}}, +pD: {{F.array__perfect(U32, {c}n, D) == True{{}} : Bool}})')
        w(f'    -> {{{T}.{pre}_pa{j}(U32.shrn(0, 2n), F.array__thaw(U32, D), Array.get(U32, F.array__thaw(U32, t), {j})) == {rhs} : Array<U32> & Array<U32>}}:')
        w(f'  +v = F.flat__nthc(F.array__slots(U32, t), {j}n)')
        w(f'  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), {j}), (F.array__thaw(U32, t), v), AC.getv(ds, t, {j}, {j}n, {{==}}, hs, F.nat__lt_le_trans({j}n, {nw}n, F.spec_common__pow2(ds), {{==}}, hn), ps)) :')
        w(f'    {{{T}.{pre}_pa{j}(U32.shrn(0, 2n), F.array__thaw(U32, D), _) == {rhs} : Array<U32> & Array<U32>}}')
        setv = (f'AC.setv({c}n, D, (U32.shrn(0, 2n) + {j} : U32), {j}n, v, {{==}}, {{==}}, {{==}}, pD)')
        seteq = f'Array.set(U32, F.array__thaw(U32, D), (U32.shrn(0, 2n) + {j} : U32), v), F.array__thaw(U32, F.array__upd(U32, {c}n, D, {j}n, v))'
        if j == nw - 1:
            w(f'  %Equal.sym(Array<U32>, {seteq}, {setv}) :')
            w(f'    {{(_, F.array__thaw(U32, t)) == {rhs} : Array<U32> & Array<U32>}}')
            w('  {==}')
        else:
            w(f'  %Equal.sym(Array<U32>, {seteq}, {setv}) :')
            w(f'    {{{T}.{pre}_pa{j + 1}(U32.shrn(0, 2n), _, Array.get(U32, F.array__thaw(U32, t), {j + 1})) == {rhs} : Array<U32> & Array<U32>}}')
            w(f'  {name}_pc{j + 1}(F.array__upd(U32, {c}n, D, {j}n, v), t, ds, hs, ps, hn, F.array__upd_perfect(U32, {c}n, D, {j}n, v, pD))')


def counts(nw):
    """(m, k7, NWT, NWE): the block words m = 8 (nw >> 3), the tail k7, the copy count as a
    term over the variable M (eM: M == m, so a copy tree over it never unfolds), and the
    same term at M = m."""
    m, k7 = 8 * (nw >> 3), nw & 7
    NWT = 'M' if k7 == 0 else f'Nat.add(M, {k7}n)'
    NWE = f'{m}n' if k7 == 0 else f'Nat.add({m}n, {k7}n)'
    return m, k7, NWT, NWE


def eqc(a, b):
    """A closed Nat equation, through Nat.is_eq (a {==} on the equation itself can overflow)."""
    return f'F.nat__eq_from_is_eq({a}, {b}, {{==}})'


def subm(m, P, proof):
    """From P(m) (closed) to P(M), by eM: M == m."""
    return f'F.logic__subst(Nat, z => {P}, {m}n, M, Equal.sym(Nat, M, {m}n, eM), {proof})'


def acopy(w, name, c, nb, nw):
    """<name>_acopy: the whole-word copy of nw words (blocks of 8, then the tail) into any
    perfect D of depth c; the counts are over the variable M."""
    kb = nw >> 3
    m, k7, NWT, NWE = counts(nw)
    SL = 'F.array__slots(U32, t)'
    CP = f'AC.cpt({c}n, {NWT}, 0n, 0n, D, {SL})'
    CM = f'AC.cpt({c}n, M, 0n, 0n, D, {SL})'
    NWU = f'U32.shrn(({nb} + 3 : U32), 2n)'
    RHS = f'(F.array__thaw(U32, {CP}), F.array__thaw(U32, t))'
    w(f'def {name}_acopy(+D: F.array__Tree<U32>, +pD: {{F.array__perfect(U32, {c}n, D) == True{{}} : Bool}}, +t: F.array__Tree<U32>, +ds: Nat, +hs: {{Nat.is_lt(ds, 32n) == True{{}} : Bool}}, +ps: {{F.array__perfect(U32, ds, t) == True{{}} : Bool}},')
    w(f'    +hn: {{Nat.is_le({nw}n, F.spec_common__pow2(ds)) == True{{}} : Bool}}, +M: Nat, +eM: {{M == {m}n : Nat}})')
    w(f'    -> {{O.acopy({NWU}, 0, U32.shrn(0, 2n), F.array__thaw(U32, D), F.array__thaw(U32, t)) == {RHS} : Array<U32> & Array<U32>}}:')
    tail = f'O.ac_tail(U32.to_nat(({NWU} .&. 7 : U32)), (0 + {NWU} - ({NWU} .&. 7 : U32) : U32), (U32.shrn(0, 2n) + {NWU} - ({NWU} .&. 7 : U32) : U32), '
    hm = subm(m, f'{{Nat.is_eq(AC.oct({kb}n), z) == True{{}} : Bool}}', '{==}')
    hA = subm(m, '{Nat.is_le(Nat.add(z, 0n), F.spec_common__pow2(ds)) == True{} : Bool}', f'F.nat__le_trans(Nat.add({m}n, 0n), {nw}n, F.spec_common__pow2(ds), {{==}}, hn)')
    hB = subm(m, f'{{Nat.is_le(Nat.add(z, 0n), F.spec_common__pow2({c}n)) == True{{}} : Bool}}', '{==}')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.ac_blk({kb}n, 0, U32.shrn(0, 2n), (F.array__thaw(U32, D), F.array__thaw(U32, t))), (F.array__thaw(U32, {CM}), F.array__thaw(U32, t)),')
    w(f'      AC.blk({kb}n, M, 0, U32.shrn(0, 2n), 0n, 0n, ds, {c}n, t, D, {hm}, {{==}}, {{==}}, hs, {{==}}, {hA}, {hB}, ps, pD)) :')
    w(f'    {{{tail}_) == {RHS} : Array<U32> & Array<U32>}}')
    if k7 == 0:
        w('  {==}')
        return
    w(f'  %Equal.sym(F.array__Tree<U32>, AC.cpt({c}n, Nat.add(M, {k7}n), 0n, 0n, D, {SL}), AC.cpt({c}n, {k7}n, Nat.add(M, 0n), Nat.add(M, 0n), {CM}, {SL}), AC.split({c}n, M, {k7}n, 0n, 0n, D, {SL})) :')
    w(f'    {{{tail}(F.array__thaw(U32, {CM}), F.array__thaw(U32, t))) == (F.array__thaw(U32, _), F.array__thaw(U32, t)) : Array<U32> & Array<U32>}}')
    A0 = f'(0 + {NWU} - ({NWU} .&. 7 : U32) : U32)'
    B0 = f'(U32.shrn(0, 2n) + {NWU} - ({NWU} .&. 7 : U32) : U32)'
    ea = subm(m, f'{{U32.to_nat({A0}) == Nat.add(z, 0n) : Nat}}', eqc(f'U32.to_nat({A0})', f'Nat.add({m}n, 0n)'))
    eb = subm(m, f'{{U32.to_nat({B0}) == Nat.add(z, 0n) : Nat}}', eqc(f'U32.to_nat({B0})', f'Nat.add({m}n, 0n)'))
    hA2 = subm(m, f'{{Nat.is_le(Nat.add(Nat.add(z, 0n), {k7}n), F.spec_common__pow2(ds)) == True{{}} : Bool}}', f'F.nat__le_trans(Nat.add(Nat.add({m}n, 0n), {k7}n), {nw}n, F.spec_common__pow2(ds), {{==}}, hn)')
    hB2 = subm(m, f'{{Nat.is_le(Nat.add(Nat.add(z, 0n), {k7}n), F.spec_common__pow2({c}n)) == True{{}} : Bool}}', '{==}')
    w(f'  WA.actl({k7}n, {A0}, {B0}, Nat.add(M, 0n), Nat.add(M, 0n), ds, {c}n, t, {CM}, {ea}, {eb}, hs, {{==}},')
    w(f'    {hA2}, {hB2}, ps, AC.cpt_perfect({c}n, M, 0n, 0n, D, {SL}, pD))')


def emit_lemma(w, name, T, kind, pre, c, nb, nw):
    """<name>_emit: for any perfect D of depth c (the zero output), the writer's emitted
    bytes are the limbs of the storage's first nw words. D is a variable, and a whole-word
    writer's count is over the variable M, so the copy tree AC.cpt never unfolds."""
    SL = 'F.array__slots(U32, t)'
    OW = f'O.Words{{F.array__thaw(U32, t), {nb}}}'
    if kind == 'unrolled':
        NWT = f'{nw}n'
        L0 = f'{T}.{name}_enc_out({T}.{pre}_pal({nb}, {T}.{pre}_pa0(U32.shrn(0, 2n), F.array__thaw(U32, D), Array.get(U32, F.array__thaw(U32, t), 0))))'
        extra = ''
        sub = lambda P, pr: pr
    else:
        m, k7, NWT, NWE = counts(nw)
        L0 = f'{T}.{name}_enc_out(O.put_words(F.array__thaw(U32, D), 0, {OW}))'
        extra = f', +M: Nat, +eM: {{M == {m}n : Nat}}'
        sub = lambda P, pr: subm(m, P, pr)
    at = lambda z: NWT if kind == 'unrolled' else NWT.replace('M', z)
    CP = f'AC.cpt({c}n, {NWT}, 0n, 0n, D, {SL})'
    R = f'({OW}, SF.limbs(F.spec_common__take(U32, {SL}, {NWT})))'
    w(f'def {name}_emit(+D: F.array__Tree<U32>, +pD: {{F.array__perfect(U32, {c}n, D) == True{{}} : Bool}}, +t: F.array__Tree<U32>, +dw: Nat, +hd: {{Nat.is_lt(dw, 32n) == True{{}} : Bool}},')
    w(f'    +pf: {{F.array__perfect(U32, dw, t) == True{{}} : Bool}}, +hn: {{Nat.is_le({nw}n, F.spec_common__pow2(dw)) == True{{}} : Bool}}{extra})')
    w(f'    -> {{SF.emitted(O.Words, {L0}, {nw}) == {R} : O.Words & +List<U32>}}:')
    if kind == 'unrolled':
        w(f'  %Equal.sym(Array<U32> & Array<U32>, {T}.{pre}_pa0(U32.shrn(0, 2n), F.array__thaw(U32, D), Array.get(U32, F.array__thaw(U32, t), 0)), (F.array__thaw(U32, {CP}), F.array__thaw(U32, t)),')
        w(f'      {name}_pc0(D, t, dw, hd, pf, hn, pD)) :')
        w(f'    {{SF.emitted(O.Words, {T}.{name}_enc_out({T}.{pre}_pal({nb}, _)), {nw}) == {R} : O.Words & +List<U32>}}')
    else:
        w(f'  %Equal.sym(Array<U32> & O.Words, O.put_words(F.array__thaw(U32, D), 0, {OW}), O.put_fin({nb}, (F.array__thaw(U32, {CP}), F.array__thaw(U32, t))),')
        w(f'      AC.put_al(F.array__thaw(U32, D), F.array__thaw(U32, t), 0, {nb}, (F.array__thaw(U32, {CP}), F.array__thaw(U32, t)), {{==}}, {{==}}, {{==}}, {name}_acopy(D, pD, t, dw, hd, pf, hn, M, eM))) :')
        w(f'    {{SF.emitted(O.Words, {T}.{name}_enc_out(_), {nw}) == {R} : O.Words & +List<U32>}}')
    BF = f'B.Buf{{F.array__thaw(U32, {CP}), {nb}}}'
    TK = f'F.spec_common__take(U32, F.array__slots(U32, {CP}), {NWT})'
    w(f'  %Equal.sym(B.Buf, O.out_done({nb}, F.array__thaw(U32, {CP})), {BF}, WA.out_buf({nb}, F.array__thaw(U32, {CP}))) :')
    w(f'    {{({OW}, SF.listed(B.emit(_, 0, {nw}))) == {R} : O.Words & +List<U32>}}')
    hk = sub(f'{{Nat.is_eq(U32.to_nat({nw}), {at("z")}) == True{{}} : Bool}}', '{==}')
    h0 = sub(f'{{Nat.is_lt(0n, {at("z")}) == True{{}} : Bool}}', '{==}')
    hK = sub(f'{{Nat.is_le({at("z")}, F.spec_common__pow2({c}n)) == True{{}} : Bool}}', f'WA.le_true({at(str(counts(nw)[0]) + "n") if kind != "unrolled" else NWT}, F.spec_common__pow2({c}n), {{==}})')
    hq = sub(f'{{Nat.is_le(A.quad({at("z")}), U32.to_nat({nb})) == True{{}} : Bool}}', '{==}')
    w(f'  +hK = {hK}')
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit({BF}, 0, {nw}), ({BF}, SF.limbs({TK})),')
    w(f'      WA.emit_n({c}n, {CP}, {nb}, {nw}, {NWT}, {hk}, {h0}, {{==}}, hK, {hq}, AC.cpt_perfect({c}n, {NWT}, 0n, 0n, D, {SL}, pD))) :')
    w(f'    {{({OW}, SF.listed(_)) == {R} : O.Words & +List<U32>}}')
    w(f'  %Equal.sym(+List<U32>, SF.listed(({BF}, SF.limbs({TK}))), SF.limbs({TK}), WA.listed_pair({BF}, SF.limbs({TK}))) :')
    w(f'    {{({OW}, _) == {R} : O.Words & +List<U32>}}')
    w(f'  +hlen = F.logic__subst(Nat, z => {{Nat.is_le({nw}n, z) == True{{}} : Bool}}, F.spec_common__pow2(dw), F.spec_common__length(U32, {SL}), Equal.sym(Nat, F.spec_common__length(U32, {SL}), F.spec_common__pow2(dw), F.array__slots_length(U32, dw, t, pf)), hn)')
    if kind == 'unrolled':
        hs = 'hlen'
    else:
        hs = sub(f'{{Nat.is_le({at("z")}, F.spec_common__length(U32, {SL})) == True{{}} : Bool}}', f'F.nat__le_trans({NWE}, {nw}n, F.spec_common__length(U32, {SL}), {{==}}, hlen)')
    w(f'  %Equal.sym(List<&2, U32>, {TK}, F.spec_common__take(U32, {SL}, {NWT}), WA.cpt_take({c}n, {NWT}, D, {SL}, pD, hK, {hs})) :')
    w(f'    {{({OW}, SF.limbs(_)) == {R} : O.Words & +List<U32>}}')
    w('  {==}')


def emit_top(w, name, T, kind, pre, c, nb, nw):
    """The encoder's zero output (Array.new) as the thawed zero tree, then <name>_emit."""
    TR = f'F.array__trep(U32, {c}n, 0)'
    SL = 'F.array__slots(U32, t)'
    OW = f'O.Words{{F.array__thaw(U32, t), {nb}}}'
    NWE = f'{nw}n' if kind == 'unrolled' else counts(nw)[3]
    R = f'({OW}, SF.limbs(F.spec_common__take(U32, {SL}, {NWE})))'
    if kind == 'unrolled':
        L0 = f'{T}.{name}_enc_out({T}.{pre}_pal({nb}, {T}.{pre}_pa0(U32.shrn(0, 2n), _, Array.get(U32, F.array__thaw(U32, t), 0))))'
        more = ''
    else:
        L0 = f'{T}.{name}_enc_out(O.put_words(_, 0, {OW}))'
        more = f', {counts(nw)[0]}n, {{==}}'
    w(f'  %Equal.sym(Array<U32>, Array.new(U32, {c}n, 0), F.array__thaw(U32, {TR}), F.array__new(U32, {c}n, 0)) :')
    w(f'    {{SF.emitted(O.Words, {L0}, {nw}) == {R} : O.Words & +List<U32>}}')
    w(f'  {name}_emit({TR}, F.array__trep_perfect(U32, {c}n, 0), t, dw, hd, pf, hn{more})')


def rep_facts(w, name, K, L, nb, nw):
    """Destructure PK.rep_v<K>(o, s) and derive N == NB, NW <= 2^dw."""
    _p, _n, sh = ELEM[K]
    for line in ['(+wf, +r1) = rep', '(+t, w1) = wf', '(+dw, w2) = w1', '(+N, w3) = w2', '(+q, w4) = w3', '(+r, w5) = w4',
                 '(+eo, w6) = w5', '(+pf, w7) = w6', '(+hd, w8) = w7', '(+en, w9) = w8', '(+h0, w10) = w9', '(+h32, w11) = w10',
                 '(+cap, +zt) = w11', '(+eN, +hv) = r1']:
        w('  ' + line)
    SHN = f'U32.to_nat(U32.shrn(N, {sh}n))'
    w(f'  +eC = F.nat__eq_from_is_eq({SHN}, {L}n, F.logic__subst(S.Schema, z => {{Nat.is_eq({SHN}, SH.Vector_length(z)) == True{{}} : Bool}}, s, Spec.{name}(), es, PK.eqn_n{K}(o, t, N, SH.Vector_length(s), eo, hv)))')
    w(f'  +eNB = Equal.trans(Nat, U32.to_nat(N), PK.e{K}({SHN}), A.quad({nw}n), PK.eq_n{K}(o, t, N, eo, eN),')
    w(f'    Equal.trans(Nat, PK.e{K}({SHN}), PK.e{K}({L}n), A.quad({nw}n), Equal.cong(Nat, Nat, x => PK.e{K}(x), {SHN}, {L}n, eC), F.nat__eq_from_is_eq(PK.e{K}({L}n), A.quad({nw}n), {{==}})))')
    w(f'  +eNN = F.u32__injective(N, {nb}, Equal.trans(Nat, U32.to_nat(N), A.quad({nw}n), U32.to_nat({nb}), eNB, F.nat__eq_from_is_eq(A.quad({nw}n), U32.to_nat({nb}), {{==}})))')
    w(f'  +hn = F.nat__le_trans({nw}n, O.e8(1n+q), F.spec_common__pow2(dw), WA.nw_le({nw}n, q, r, Equal.trans(Nat, A.quad({nw}n), U32.to_nat(N), Nat.add(WS.e32(q), r), Equal.sym(Nat, U32.to_nat(N), A.quad({nw}n), eNB), en), h32), cap)')


def gname(w, name, K, L, src):
    kind, pre, c, nb = writer(src, name)
    nw = nb // 4
    assert nb == K * L and nb % 4 == 0, name
    Pt, n, sh = ELEM[K]
    w(f'# ---- {name}: a vector of {L} uint{8 * K} ({nb} bytes, {nw} words; writer {kind} {pre}, output depth {c}) ----')
    if kind == 'unrolled':
        chain(w, name, pre, c, nw)
    else:
        acopy(w, name, c, nb, nw)
    emit_lemma(w, name, 'T', kind, pre, c, nb, nw)
    OW = f'O.Words{{F.array__thaw(U32, t), {nb}}}'
    OWN = 'O.Words{F.array__thaw(U32, t), N}'
    SL = 'F.array__slots(U32, t)'
    # E1
    w(f'def {name}_encode_any(-o: O.Words, +s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}, +rep: PK.rep_v{K}(o, s))')
    w(f'    -> {{SF.emitted(O.Words, T.{name}_encode(o), {nw}) == (o, WO.wview(o)) : O.Words & +List<U32>}}:')
    rep_facts(w, name, K, L, nb, nw)
    w(f'  %Equal.sym(O.Words, o, {OWN}, eo) : {{SF.emitted(O.Words, T.{name}_encode(_), {nw}) == (_, WO.wview(_)) : O.Words & +List<U32>}}')
    w(f'  %Equal.sym(U32, N, {nb}, eNN) :')
    w(f'    {{SF.emitted(O.Words, T.{name}_encode(O.Words{{F.array__thaw(U32, t), _}}), {nw}) == (O.Words{{F.array__thaw(U32, t), _}}, WO.wview(O.Words{{F.array__thaw(U32, t), _}})) : O.Words & +List<U32>}}')
    NWE = f'{nw}n' if kind == 'unrolled' else counts(nw)[3]
    w(f'  %Equal.sym(+List<U32>, WO.wview({OW}), SF.limbs(F.spec_common__take(U32, {SL}, {NWE})), WA.wview_take(t, {nb}, {NWE}, {eqc(f"U32.to_nat({nb})", f"A.quad({NWE})")})) :')
    w(f'    {{SF.emitted(O.Words, T.{name}_encode({OW}), {nw}) == ({OW}, _) : O.Words & +List<U32>}}')
    emit_top(w, name, 'T', kind, pre, c, nb, nw)
    # E2
    w(f'def {name}_decodes_any(-o: O.Words, +s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}, +rep: PK.rep_v{K}(o, s))')
    w(f'    -> Decoding.decodes(s, WO.wview(o), PK.vview{K}(o)):')
    rep_facts(w, name, K, L, nb, nw)
    TK = f'F.spec_common__take(U32, {SL}, {nw}n)'
    w(f'  %Equal.sym(O.Words, o, {OWN}, eo) : Decoding.decodes(s, WO.wview(_), PK.vview{K}(_))')
    w(f'  %Equal.sym(U32, N, {nb}, eNN) : Decoding.decodes(s, WO.wview(O.Words{{F.array__thaw(U32, t), _}}), PK.vview{K}(O.Words{{F.array__thaw(U32, t), _}}))')
    w(f'  %Equal.sym(+List<U32>, WO.wview({OW}), SF.limbs({TK}), WA.wview_take(t, {nb}, {nw}n, F.nat__eq_from_is_eq(U32.to_nat({nb}), A.quad({nw}n), {{==}}))) : Decoding.decodes(s, _, PK.vview{K}({OW}))')
    w(f'  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
    w(f'    Decoding.decodes(s, SF.limbs({TK}), S.Sequence{{PK.it{K}(U32.to_nat(U32.shrn({nb}, {sh}n)), F.array__slots(U32, _))}})')
    w(f'  %Equal.sym(S.Value, PK.it{K}({L}n, {SL}), AV.chu{n}(F.spec_common__take(U32, {SL}, AV.m{n}({L}n))), WA.it{K}c({L}n, {SL})) :')
    w(f'    Decoding.decodes(s, SF.limbs({TK}), S.Sequence{{_}})')
    # the element-byte count m<n>(L) as the literal word count, by evaluating Nat.is_eq: a conversion under
    # take/chu<n> would walk the {nw} words
    w(f'  %F.nat__eq_from_is_eq({nw}n, AV.m{n}({L}n), {{==}}) : Decoding.decodes(s, SF.limbs({TK}), S.Sequence{{AV.chu{n}(F.spec_common__take(U32, {SL}, _))}})')
    w(f'  +hlen = F.logic__subst(Nat, z => {{Nat.is_le({nw}n, z) == True{{}} : Bool}}, F.spec_common__pow2(dw), F.spec_common__length(U32, {SL}), Equal.sym(Nat, F.spec_common__length(U32, {SL}), F.spec_common__pow2(dw), F.array__slots_length(U32, dw, t, pf)), hn)')
    w(f'  +hl = WA.len_take({SL}, {nw}n, hlen)')
    sub = lambda P: f'F.logic__subst(S.Schema, z => {P}, Spec.{name}(), s, Equal.sym(S.Schema, s, Spec.{name}(), es), {{==}})'
    w(f'  SF.encoding_of_parts(s, S.Sequence{{AV.chu{n}({TK})}}, SF.limbs({TK}),')
    w(f'    AV.vpartsu{n}(s, {TK}, {L}n, {nw}n, {nb}n, {sub("{SH.is_Vector(z) == True{} : Bool}")},')
    w(f'      {sub("{SH.Vector_element(z) == S.Unsigned{" + Pt + "} : S.Schema}")},')
    w(f'      {sub("{Nat.is_eq(SH.Vector_length(z), " + str(L) + "n) == True{} : Bool}")}, {{==}}, hl, {{==}}, AS.wlen_len({TK}, {nw}n, {nb}n, hl, {{==}}), {{==}}))')
    w('')
    return kind


def branch(w, name, k, src):
    kind, pre, c, nb = writer(src, name)
    nw = nb // 4
    assert nw == 8 * k and kind == 'unrolled', name
    w(f'# ---- {name}: a vector of {k} Bytes32 ({nb} bytes, {nw} words; writer {pre}, output depth {c}) ----')
    chain(w, name, pre, c, nw)
    emit_lemma(w, name, 'T', kind, pre, c, nb, nw)
    OW = f'O.Words{{F.array__thaw(U32, t), {nb}}}'
    SL = 'F.array__slots(U32, t)'
    BT = f'VS.bt({nb}n, SF.limbs({SL}))'
    binders = (f'+t: F.array__Tree<U32>, +dw: Nat, +hd: {{Nat.is_lt(dw, 32n) == True{{}} : Bool}}, +pf: {{F.array__perfect(U32, dw, t) == True{{}} : Bool}}, '
               f'+cap: {{Nat.is_le(O.e8({k}n), F.spec_common__pow2(dw)) == True{{}} : Bool}}')
    w(f'def {name}_encode_any({binders})')
    w(f'    -> {{SF.emitted(O.Words, T.{name}_encode({OW}), {nw}) == ({OW}, {BT}) : O.Words & +List<U32>}}:')
    w(f'  +hn = F.nat__le_trans({nw}n, O.e8({k}n), F.spec_common__pow2(dw), {{==}}, cap)')
    w(f'  %Equal.sym(+List<U32>, {BT}, SF.limbs(F.spec_common__take(U32, {SL}, {nw}n)), WA.bt_limbs({nw}n, {SL})) :')
    w(f'    {{SF.emitted(O.Words, T.{name}_encode({OW}), {nw}) == ({OW}, _) : O.Words & +List<U32>}}')
    emit_top(w, name, 'T', kind, pre, c, nb, nw)
    w(f'def {name}_decodes_any({binders})')
    w(f'    -> Decoding.decodes(Spec.{name}(), {BT}, S.Sequence{{WR.items({k}n, {SL}, 0n)}}):')
    w(f'  +hn = F.nat__le_trans({nw}n, O.e8({k}n), F.spec_common__pow2(dw), {{==}}, cap)')
    w(f'  +hlen = F.logic__subst(Nat, z => {{Nat.is_le({nw}n, z) == True{{}} : Bool}}, F.spec_common__pow2(dw), F.spec_common__length(U32, {SL}), Equal.sym(Nat, F.spec_common__length(U32, {SL}), F.spec_common__pow2(dw), F.array__slots_length(U32, dw, t, pf)), hn)')
    w(f'  %Equal.sym(+List<U32>, {BT}, SF.limbs(F.spec_common__take(U32, {SL}, {nw}n)), WA.bt_limbs({nw}n, {SL})) :')
    w(f'    Decoding.decodes(Spec.{name}(), _, S.Sequence{{WR.items({k}n, {SL}, 0n)}})')
    w(f'  %Equal.sym(List<&2, U32>, F.spec_common__take(U32, {SL}, {nw}n), WA.nl({nw}n, {SL}, 0n), WA.take_nl({SL}, {nw}n, hlen)) :')
    w(f'    Decoding.decodes(Spec.{name}(), SF.limbs(_), S.Sequence{{WR.items({k}n, {SL}, 0n)}})')
    w(f'  C.{name}_spec_encode(' + ', '.join(f'F.flat__nthc({SL}, {i}n)' for i in range(nw)) + ')')
    w('')


def outputs(ROOT, gen=None):
    """The spec_gany_<k> and spec_wany_<k> files; gen (path -> text) is the spec_connected_codec_laws run's
    output, read in place of the files on disk (so --check sees one consistent run)."""
    gen = gen or {}
    # the run's own files when it has any of the pattern (the files on disk may be a former layout);
    # in_order: in the run's order (the per-name codec files: the names' order)
    files = lambda pat, in_order=False: ([q for q in gen if q.match(pat)] if in_order else sorted(q for q in gen if q.match(pat))) \
        or sorted((ROOT / 'proofs/obj').glob(pat))
    text = lambda q: gen[q] if q in gen else q.read_text()
    gnames = RG.generic_names()
    gsrc = RR.mono_text('generic')
    covered = []
    for f in files('spec_gcodec_*.bend', True):
        covered += re.findall(r'^# ---- (\w+) \(\d+ bytes\) ----$', text(f), re.M)
    covered += [p.stem[len('spec_garr_'):] for p in files('spec_garr_vec_*.bend')]
    picked = []
    for n in covered:
        t = gnames.get(n)
        if t is None or t.kind != 'vector' or t.elem.kind != 'uint' or t.elem.size not in ELEM:
            continue
        picked.append((n, t.elem.size, t.size))
    out = {}
    head = GHEAD + ['', '# GENERATED by spec_connected_codec_laws (codegen: any_depth_vector_encode_laws). Do not edit.',
                    '# Encode laws of word-storage uint vectors at ANY storage depth, under the root',
                    "# laws' own hypotheses (PK.rep_v<K>(o, s), s == Spec.<N>()); see codegen/proofs/laws/any_depth_vector_encode_laws.py.", '']
    for i in range(0, len(picked), PER_FILE):
        L = list(head)
        for n, K, Ln in picked[i:i + PER_FILE]:
            gname(L.append, n, K, Ln, gsrc)
        out[ROOT / f'proofs/obj/spec_gany_{i // PER_FILE}.bend'] = '\n'.join(L) + '\n'
    fsrc = RR.mono_text('fulu')
    groups = {}
    for n, k in BRANCHES.items():
        mod = [f.stem for f in files('spec_codec_*.bend') if f'def {n}_spec_encode(' in text(f)]
        if len(mod) != 1:
            raise Skip(f'{n}: its spec_encode law is in {mod}')
        groups.setdefault(mod[0], []).append((n, k))
    for mod, ns in sorted(groups.items()):
        L = WHEAD + [f'import ./{mod}.bend as C', '', '# GENERATED by spec_connected_codec_laws (codegen: any_depth_vector_encode_laws). Do not edit.',
                     '# Encode laws of the Bytes32 branch vectors (root_words) at ANY storage depth, under',
                     "# the root laws' own binders (t, dw, hd, pf, cap); see codegen/proofs/laws/any_depth_vector_encode_laws.py.", '']
        for n, k in ns:
            branch(L.append, n, k, fsrc)
        out[ROOT / f'proofs/obj/spec_wany_{mod.split("_")[-1]}.bend'] = '\n'.join(L) + '\n'
    return out, [n for n, _, _ in picked]
