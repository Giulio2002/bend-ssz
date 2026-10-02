#!/usr/bin/env python3
"""proofs/obj/encset_<list>.bend: the encode of a list after one element is written, stated per element (the boxed lists).

The encode bridge of a list of boxed containers (proofs/obj/encx_<list>.bend) says: for a mirror tree t holding N elements that satisfies
OKL(t, N) (a perfect tree of depth TDM(t) below 31, N within the depth and the limit, and EOKS(N, slots t, 0): every element satisfies
EOK), the spec encode of its value VALL(t, N) is the runtime's bytes ENCL(t, N) (encx_specB, under a bound B on the byte count).

A set of element i writes the thawed mirror m into the tree: t' = array__upd(MB, TDM t, t, i, m). This file proves, per element and without
any closed comparison, that the written object satisfies the same premises and that its value is the old one with item i replaced:

    <c>_xat_same / <c>_xat_other        the element after an update: the new one at i, the old one elsewhere
    <c>_xi_same / <c>_xi_set            the items of the encode value over the updated slots: items_set of the old ones with the new element's item
    <c>_eoks_other / <c>_eoks_set       EOKS after the update: the new element's EOK at i, the old elements' elsewhere (one induction on the count)
    <c>_tdm                             the depth of a perfect tree of depth d is d
    <c>_okl_set                         OKL(t, N) and EOK(m), i < N: OKL(t', N)
    <c>_vall_set                        VALL(t', N) == field_set(VALL(t, N), i, item(m))
    <c>_written                         the written object: its array is the old array with the box of m at i (the mirror's amset)
    <c>_api_encode_set                  the composed statement: the spec encode of the set value is the bytes ENCL(t', N) of the written object (encx_specB on t')

    python3 codegen/proofs/collections/encset.py            # write
    python3 codegen/proofs/collections/encset.py --check    # nonzero exit if the output is stale
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core.paths import ROOT  # noqa: E402
from codegen.proofs.collections import viewseq as VQS  # noqa: E402

OBJ = ROOT / 'proofs/obj'
LISTS = ('l1_AttesterSlashing', 'l1048576_bl1073741824', 'l16_Deposit', 'l16_ProposerSlashing', 'l8_Attestation')

HELP = '''def and_l(+a: Bool, +b: Bool, +e: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case True{}: {==}
    case False{}: Empty.absurd({False{} == True{} : Bool}, F.logic__false_true(e))

def and_r(+a: Bool, +b: Bool, +e: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case True{}: e
    case False{}: Empty.absurd({b == True{} : Bool}, F.logic__false_true(e))

def and_i(+a: Bool, +b: Bool, +ha: {a == True{} : Bool}, +hb: {b == True{} : Bool}) -> {Bool.and(a, b) == True{} : Bool}:
  match a:
    case True{}: hb
    case False{}: Empty.absurd({Bool.and(False{}, b) == True{} : Bool}, F.logic__false_true(ha))

'''


def split_top(s):
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in '([{<':
            depth += 1
        elif ch in ')]}>':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    out.append(cur)
    return out


def facts(c):
    """the names and types of the encode module of list c, read from proofs/obj/encx_<c>.bend"""
    txt = (OBJ / ('encx_%s.bend' % c)).read_text()
    defs = set(re.findall(r'^def (\w+)\(', txt, re.M)) | set(re.findall(r'^type (\w+)', txt, re.M)) | set(re.findall(r'^type (\w+)<', txt, re.M))
    imps = {a: p for p, a in re.findall(r'^import (\S+) as (\w+)', txt, re.M)}
    mx = re.search(r'^def xat_%s\(W: List<&2, (.+?)>, \+i: Nat\) -> (.+?):$' % re.escape(c), txt, re.M)
    EL0 = mx.group(2)
    EL = re.sub(r'\b(MB|M_\w+|WMr)\b', lambda k: 'E.' + k.group(1), EL0)
    sfx = lambda n: n + '_' + c if re.search(r'^def %s_%s\(' % (n, re.escape(c)), txt, re.M) else n
    OKL, THL, VALL, ENCL, LL = (sfx(n) for n in ('OKL', 'THL', 'VALL', 'ENCL', 'LL'))
    XI = 'XI' if re.search(r'^def XI\(k: Nat', txt, re.M) else 'ITE'
    mi = re.search(r'^def %s\(\w+: Nat, \+W: .*?\n  match \w+:\n    case 0n: S.EmptyItems\{\}\n    case 1n\+q: S.Items\{(.+), %s\(q, W, 1n\+i\)\}' % (XI, XI), txt, re.M)
    item = mi.group(1)
    assert 'xat_%s(W, i)' % c in item, (c, item)
    item = item.replace('xat_%s(W, i)' % c, '@M@')
    for n in defs:
        item = re.sub(r'(?<![\w.])%s(?=\()' % re.escape(n), 'E.' + n, item)
    item = item.replace('@M@', 'm')
    sp = [n for n in ('encx_spec_%sB' % c, 'encx_specB', 'speclB') if re.search(r'^def %s\(' % n, txt, re.M)][0]
    ms = re.search(r'^def %s\(.*?\n.*?\n    -> \{Codec.parts\(%s\(t, N\), (Spec\.\w+\(\))\) ==' % (sp, VALL), txt, re.M)
    mseq = re.search(r'^def %s\(.*?\) -> (\S+_Seq):' % THL, txt, re.M)
    mam = re.search(r'^def am_%s\(t: .*?\) -> Array<(.+)>:' % re.escape(c), txt, re.M)
    mth = re.search(r'^def amset_%s\(.*?Array\.set\((.+?), am_%s\(t\), i, (\w+)\(v\)\)' % (re.escape(c), re.escape(c)), txt, re.M)
    mlim = re.search(r'^def okl_lim\(.*?\{(U32\.is_le\(N, \d+\)) == True', txt, re.M)
    return dict(c=c, EL=EL, EL0=EL0, OKL=OKL, THL=THL, VALL=VALL, ENCL=ENCL, LL=LL, XI=XI, item=item, spec=sp, schema=ms.group(1), seq=mseq.group(1),
                bx=mam.group(1), th=mth.group(2), imps=imps, lim=mlim.group(1), txt=txt)


def text(c):
    f = facts(c)
    EL = f['EL']
    E = lambda n: 'E.' + n
    XAT = lambda W, i: 'E.xat_%s(%s, %s)' % (c, W, i)
    UPDW = lambda W, J='J', e='e': 'F.spec_common__update(%s, %s, %s, %s)' % (EL, W, J, e)
    XI = lambda k, W, i: 'E.%s(%s, %s, %s)' % (f['XI'], k, W, i)
    V = 'vv_' + c
    body = []
    body.append('def %s(m: %s) -> S.Value: %s\n' % (V, EL, f['item']))
    body.append(VQS.XAT_LEMMAS % dict(c=c, E=EL, xs=XAT(UPDW('W'), 'J'), xn=XAT(UPDW('Nil{}'), 'J'), xu=XAT(UPDW('W'), 'i'), xw=XAT('W', 'i'),
                                      xu0=XAT(UPDW('Con{x, t}', '0n', 'e'), '0n'), xw0=XAT('Con{x, t}', '0n')))
    body.append(VQS.XI_LEMMAS % dict(c=c, E=EL, V=V, a=XI('k', UPDW('W'), 'i0'), b=XI('k', 'W', 'i0'), xu=XAT(UPDW('W'), 'i0'), xw=XAT('W', 'i0'), xz=XAT(UPDW('W'), 'z'),
                                     tu=XI('q', UPDW('W'), '1n+i0'), tw=XI('q', 'W', '1n+i0')))
    body.append(EOKS_LEMMAS % dict(c=c, EL=EL, XATU=XAT(UPDW('W'), 'i0'), XATW=XAT('W', 'i0'), XATJ=XAT(UPDW('W'), 'J')))
    body.append(OKL_LEMMAS % dict(c=c, EL=EL, OKL=E(f['OKL']), VALL=E(f['VALL']), THL=E(f['THL']), ENCL=E(f['ENCL']), LL=E(f['LL']), XI=f['XI'], V=V, lim=f['lim'], schema=f['schema'],
                                  spec=E(f['spec']), seq=f['seq'], bx=f['bx'], th=E(f['th'])))
    text_ = '\n'.join(body)
    # the modules the types and names use
    fixed = {'S': '../../types/schema.bend', 'F': '../compact/found.bend', 'VS': './value_set.bend', 'WR': './words_rw.bend', 'WW': './words_win.bend', 'Order': '../nat_order.bend',
             'VB': './vbuf.bend', 'Codec': '../../spec/codec.bend', 'O': '../../src/obj.bend', 'E': './encx_%s.bend' % c}
    imps = dict(fixed)
    for a, p in f['imps'].items():
        if a not in imps and re.search(r'(?<![\w.])%s\.' % re.escape(a), text_):
            imps[a] = p
    head = ['import Base'] + ['import %s as %s' % (p, a) for a, p in imps.items()]
    head += ['', '# GENERATED by encset (codegen). Do not edit.',
             '# The encode of the list %s after one element is written, stated per element: see codegen/proofs/collections/encset.py.' % c, '', VQS.HELPER, HELP]
    return '\n'.join(head) + text_ + '\n'


EOKS_LEMMAS = '''# ---- EOKS after an update: the new element's EOK at the written index, the old ones elsewhere ----
def %(c)s_eoks_other(+k: Nat, +W: List<&2, %(EL)s>, +i0: Nat, +J: Nat, +e: %(EL)s, +h: {E.EOKS(k, W, i0) == True{} : Bool}, +hlt: {Nat.is_lt(J, i0) == True{} : Bool})
    -> {E.EOKS(k, F.spec_common__update(%(EL)s, W, J, e), i0) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      +a = and_l(E.EOK(%(XATW)s), E.EOKS(q, W, 1n+i0), h)
      +b = and_r(E.EOK(%(XATW)s), E.EOKS(q, W, 1n+i0), h)
      +a2 = F.logic__subst(%(EL)s, z => {E.EOK(z) == True{} : Bool}, %(XATW)s, %(XATU)s, Equal.sym(%(EL)s, %(XATU)s, %(XATW)s, %(c)s_xat_other(W, J, i0, e, F.nat__is_eq_lt(J, i0, hlt))), a)
      +b2 = %(c)s_eoks_other(q, W, 1n+i0, J, e, b, F.nat__lt_trans(J, i0, 1n+i0, hlt, F.nat__lt_succ(i0)))
      and_i(E.EOK(%(XATU)s), E.EOKS(q, F.spec_common__update(%(EL)s, W, J, e), 1n+i0), a2, b2)

def %(c)s_eoks_set(+k: Nat, +r: Nat, +W: List<&2, %(EL)s>, +i0: Nat, +J: Nat, +e: %(EL)s, +h: {E.EOKS(k, W, i0) == True{} : Bool}, +em: {E.EOK(e) == True{} : Bool},
    +hJ: {J == Nat.add(i0, r) : Nat}, +hl: {Nat.is_lt(J, F.spec_common__length(%(EL)s, W)) == True{} : Bool})
    -> {E.EOKS(k, F.spec_common__update(%(EL)s, W, J, e), i0) == True{} : Bool}:
  match k r:
    case 0n _: {==}
    case 1n+ +q 0n:
      +b = and_r(E.EOK(%(XATW)s), E.EOKS(q, W, 1n+i0), h)
      +ji = Equal.trans(Nat, J, Nat.add(i0, 0n), i0, hJ, F.nat__add_zero(i0))
      +a2 = F.logic__subst(%(EL)s, z => {E.EOK(z) == True{} : Bool}, e, %(XATU)s, Equal.trans(%(EL)s, e, %(XATJ)s, %(XATU)s, Equal.sym(%(EL)s, %(XATJ)s, e, %(c)s_xat_same(W, J, e, hl)), Equal.cong(Nat, %(EL)s, z => E.xat_%(c)s(F.spec_common__update(%(EL)s, W, J, e), z), J, i0, ji)), em)
      +b2 = %(c)s_eoks_other(q, W, 1n+i0, J, e, b, F.logic__subst(Nat, z => {Nat.is_lt(z, 1n+i0) == True{} : Bool}, i0, J, Equal.sym(Nat, J, i0, ji), F.nat__lt_succ(i0)))
      and_i(E.EOK(%(XATU)s), E.EOKS(q, F.spec_common__update(%(EL)s, W, J, e), 1n+i0), a2, b2)
    case 1n+ +q 1n+ +r1:
      +a = and_l(E.EOK(%(XATW)s), E.EOKS(q, W, 1n+i0), h)
      +b = and_r(E.EOK(%(XATW)s), E.EOKS(q, W, 1n+i0), h)
      +hlt = F.logic__subst(Nat, z => {Nat.is_lt(i0, z) == True{} : Bool}, 1n+Nat.add(i0, r1), J, Equal.sym(Nat, J, 1n+Nat.add(i0, r1), Equal.trans(Nat, J, Nat.add(i0, 1n+r1), 1n+Nat.add(i0, r1), hJ, F.nat__add_succ(i0, r1))), F.nat__succ_le_lt(i0, 1n+Nat.add(i0, r1), Order.below_sum(i0, r1)))
      +a2 = F.logic__subst(%(EL)s, z => {E.EOK(z) == True{} : Bool}, %(XATW)s, %(XATU)s, Equal.sym(%(EL)s, %(XATU)s, %(XATW)s, %(c)s_xat_other(W, J, i0, e, WR.neq_sym(i0, J, F.nat__is_eq_lt(i0, J, hlt)))), a)
      +b2 = %(c)s_eoks_set(q, r1, W, 1n+i0, J, e, b, em, F.logic__subst(Nat, z => {J == z : Nat}, Nat.add(i0, 1n+r1), Nat.add(1n+i0, r1), WW.add_shift_plain(i0, r1), hJ), hl)
      and_i(E.EOK(%(XATU)s), E.EOKS(q, F.spec_common__update(%(EL)s, W, J, e), 1n+i0), a2, b2)
'''

OKL_LEMMAS = '''# ---- the premises of the encode bridge for the written tree ----
def %(c)s_tdm(+d: Nat, +t: F.array__Tree<%(EL)s>, +pf: {F.array__perfect(%(EL)s, d, t) == True{} : Bool}) -> {E.TDM(t) == d : Nat}:
  match d t:
    case 0n F.TLeaf{x}: {==}
    case 0n F.TNode{l, r}: Empty.absurd({E.TDM(F.TNode{l, r}) == 0n : Nat}, F.logic__false_true(pf))
    case 1n+ +p F.TLeaf{x}: Empty.absurd({E.TDM(F.TLeaf{x}) == 1n+p : Nat}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{l, r}: Equal.cong(Nat, Nat, z => 1n+z, E.TDM(l), p, %(c)s_tdm(p, l, and_l(F.array__perfect(%(EL)s, p, l), F.array__perfect(%(EL)s, p, r), pf)))

# the written tree is the old one with the new element in the slot of the index
def %(c)s_okl_set(+t: F.array__Tree<%(EL)s>, +N: U32, +i: U32, +m: %(EL)s, +h: {%(OKL)s(t, N) == True{} : Bool},
    +hs: {Nat.is_lt(U32.to_nat(i), U32.to_nat(N)) == True{} : Bool}, +em: {E.EOK(m) == True{} : Bool})
    -> {%(OKL)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N) == True{} : Bool}:
  +d = E.TDM(t)
  +pf = E.okl_pf(t, N, h)
  +T2 = F.array__upd(%(EL)s, d, t, U32.to_nat(i), m)
  +pf2 = F.array__upd_perfect(%(EL)s, d, t, U32.to_nat(i), m, pf)
  +td = %(c)s_tdm(d, T2, pf2)
  +hj = F.nat__lt_le_trans(U32.to_nat(i), U32.to_nat(N), F.spec_common__pow2(d), hs, E.okl_n(t, N, h))
  +hil = F.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, F.spec_common__pow2(d), F.spec_common__length(%(EL)s, F.array__slots(%(EL)s, t)), Equal.sym(Nat, F.spec_common__length(%(EL)s, F.array__slots(%(EL)s, t)), F.spec_common__pow2(d), F.array__slots_length(%(EL)s, d, t, pf)), hj)
  +hsl = F.array__upd_slots(%(EL)s, d, t, U32.to_nat(i), m, hj, pf)
  +he2 = %(c)s_eoks_set(U32.to_nat(N), U32.to_nat(i), F.array__slots(%(EL)s, t), 0n, U32.to_nat(i), m, E.okl_e(t, N, h), em, {==}, hil)
  +he3 = F.logic__subst(List<&2, %(EL)s>, z => {E.EOKS(U32.to_nat(N), z, 0n) == True{} : Bool}, F.spec_common__update(%(EL)s, F.array__slots(%(EL)s, t), U32.to_nat(i), m), F.array__slots(%(EL)s, T2), Equal.sym(List<&2, %(EL)s>, F.array__slots(%(EL)s, T2), F.spec_common__update(%(EL)s, F.array__slots(%(EL)s, t), U32.to_nat(i), m), hsl), he2)
  +c1 = F.logic__subst(Nat, z => {Nat.is_lt(z, 31n) == True{} : Bool}, d, E.TDM(T2), Equal.sym(Nat, E.TDM(T2), d, td), E.okl_d(t, N, h))
  +c2 = F.logic__subst(Nat, z => {F.array__perfect(%(EL)s, z, T2) == True{} : Bool}, d, E.TDM(T2), Equal.sym(Nat, E.TDM(T2), d, td), pf2)
  +c3 = F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(N), VB.pw(z)) == True{} : Bool}, d, E.TDM(T2), Equal.sym(Nat, E.TDM(T2), d, td), E.okl_n(t, N, h))
  and_i(Nat.is_lt(E.TDM(T2), 31n), Bool.and(F.array__perfect(%(EL)s, E.TDM(T2), T2), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(E.TDM(T2))), Bool.and(%(lim)s, E.EOKS(U32.to_nat(N), F.array__slots(%(EL)s, T2), 0n)))), c1,
    and_i(F.array__perfect(%(EL)s, E.TDM(T2), T2), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(E.TDM(T2))), Bool.and(%(lim)s, E.EOKS(U32.to_nat(N), F.array__slots(%(EL)s, T2), 0n))), c2,
      and_i(Nat.is_le(U32.to_nat(N), VB.pw(E.TDM(T2))), Bool.and(%(lim)s, E.EOKS(U32.to_nat(N), F.array__slots(%(EL)s, T2), 0n)), c3,
        and_i(%(lim)s, E.EOKS(U32.to_nat(N), F.array__slots(%(EL)s, T2), 0n), E.okl_lim(t, N, h), he3))))

# ---- the value of the written list: the old value with item i replaced ----
def %(c)s_vall_set(+t: F.array__Tree<%(EL)s>, +N: U32, +i: U32, +m: %(EL)s, +h: {%(OKL)s(t, N) == True{} : Bool}, +hs: {Nat.is_lt(U32.to_nat(i), U32.to_nat(N)) == True{} : Bool})
    -> {%(VALL)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N) == VS.field_set(%(VALL)s(t, N), U32.to_nat(i), %(V)s(m)) : S.Value}:
  +d = E.TDM(t)
  +pf = E.okl_pf(t, N, h)
  +T2 = F.array__upd(%(EL)s, d, t, U32.to_nat(i), m)
  +hj = F.nat__lt_le_trans(U32.to_nat(i), U32.to_nat(N), F.spec_common__pow2(d), hs, E.okl_n(t, N, h))
  +hil = F.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, F.spec_common__pow2(d), F.spec_common__length(%(EL)s, F.array__slots(%(EL)s, t)), Equal.sym(Nat, F.spec_common__length(%(EL)s, F.array__slots(%(EL)s, t)), F.spec_common__pow2(d), F.array__slots_length(%(EL)s, d, t, pf)), hj)
  +hsl = F.array__upd_slots(%(EL)s, d, t, U32.to_nat(i), m, hj, pf)
  %%Equal.sym(List<&2, %(EL)s>, F.array__slots(%(EL)s, T2), F.spec_common__update(%(EL)s, F.array__slots(%(EL)s, t), U32.to_nat(i), m), hsl) :
    {S.Sequence{E.%(XI)s(U32.to_nat(N), _, 0n)} == VS.field_set(%(VALL)s(t, N), U32.to_nat(i), %(V)s(m)) : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, E.%(XI)s(U32.to_nat(N), F.spec_common__update(%(EL)s, F.array__slots(%(EL)s, t), U32.to_nat(i), m), 0n),
    VS.items_set(E.%(XI)s(U32.to_nat(N), F.array__slots(%(EL)s, t), 0n), U32.to_nat(i), %(V)s(m)),
    %(c)s_xi_set(U32.to_nat(N), U32.to_nat(i), F.array__slots(%(EL)s, t), 0n, U32.to_nat(i), m, {==}, hil))

# ---- the written object: its array is the old array with the box of the new element at the index ----
def %(c)s_written(+t: F.array__Tree<%(EL)s>, +N: U32, +i: U32, +m: %(EL)s, +h: {%(OKL)s(t, N) == True{} : Bool}, +hs: {Nat.is_lt(U32.to_nat(i), U32.to_nat(N)) == True{} : Bool})
    -> {%(THL)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N) == %(seq)s{Array.set(%(bx)s, E.AR(t), i, %(th)s(m)), N} : %(seq)s}:
  +d = E.TDM(t)
  +pf = E.okl_pf(t, N, h)
  +hj = F.nat__lt_le_trans(U32.to_nat(i), U32.to_nat(N), F.spec_common__pow2(d), hs, E.okl_n(t, N, h))
  +hil = F.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, F.spec_common__pow2(d), F.spec_common__length(%(EL)s, F.array__slots(%(EL)s, t)), Equal.sym(Nat, F.spec_common__length(%(EL)s, F.array__slots(%(EL)s, t)), F.spec_common__pow2(d), F.array__slots_length(%(EL)s, d, t, pf)), hj)
  +x = E.xat_%(c)s(F.array__slots(%(EL)s, t), U32.to_nat(i))
  +hx = E.nth_%(c)s(F.array__slots(%(EL)s, t), U32.to_nat(i), hil)
  Equal.cong(Array<%(bx)s>, %(seq)s, z => %(seq)s{z, N}, E.am_%(c)s(F.array__upd(%(EL)s, d, t, U32.to_nat(i), m)), Array.set(%(bx)s, E.AR(t), i, %(th)s(m)),
    Equal.sym(Array<%(bx)s>, Array.set(%(bx)s, E.AR(t), i, %(th)s(m)), E.am_%(c)s(F.array__upd(%(EL)s, d, t, U32.to_nat(i), m)), E.amset_%(c)s(d, t, i, m, x, F.nat__lt_trans(d, 31n, 32n, E.okl_d(t, N, h), {==}), hj, hx, pf)))

# ---- the composed statement: the spec encode of the set value is the bytes of the written object ----
def %(c)s_api_encode_set(+t: F.array__Tree<%(EL)s>, +N: U32, +i: U32, +m: %(EL)s, +h: {%(OKL)s(t, N) == True{} : Bool},
    +hs: {Nat.is_lt(U32.to_nat(i), U32.to_nat(N)) == True{} : Bool}, +em: {E.EOK(m) == True{} : Bool},
    +B: Nat, +hB: {Nat.is_lt(B, VB.pw(31n)) == True{} : Bool}, +hL: {Nat.is_le(%(LL)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N), B) == True{} : Bool})
    -> {Codec.parts(VS.field_set(%(VALL)s(t, N), U32.to_nat(i), %(V)s(m)), %(schema)s) == Some{[S.Variable{%(ENCL)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N)}]} : Maybe<&2, +List<S.Part>>}:
  %%%(c)s_vall_set(t, N, i, m, h, hs) :
    {Codec.parts(_, %(schema)s) == Some{[S.Variable{%(ENCL)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N)}]} : Maybe<&2, +List<S.Part>>}
  %(spec)s(F.array__upd(%(EL)s, E.TDM(t), t, U32.to_nat(i), m), N, %(c)s_okl_set(t, N, i, m, h, hs, em), B, hB, hL)
'''


def out_path(c):
    return OBJ / ('encset_%s.bend' % c)


def main():
    stale = False
    for c in LISTS:
        t = text(c)
        o = out_path(c)
        if '--check' in sys.argv:
            if not o.exists() or o.read_text() != t:
                print('stale: %s' % o.name)
                stale = True
            continue
        if not o.exists() or o.read_text() != t:
            o.write_text(t)
        print('encset: proofs/obj/%s' % o.name)
    if '--check' in sys.argv:
        if stale:
            sys.exit(1)
        print('encset: up to date')


if __name__ == '__main__':
    main()
