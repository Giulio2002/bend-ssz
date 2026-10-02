"""The spec view of the list of 2048-byte cells after a cell is written: proofs/obj/view_cells.bend.

The cells are 512 words each (CL.cbytes(W, j): the bytes of the words 512 j .. 512 j + 511). One written cell
(the words X of a value, length 512) replaces the words at word 512 J of perfect storage; the view of the storage is then
the view before with item J replaced (VS.field_set). The proof is packed_list_set_view.py's induction over the items (items_same,
items_set, view_set: the same text, through packed_list_set_view.items_region), with element lemmas for cells: a cell's bytes are the
limbs of its window of words (WL.btake_limbs), and the window of the written tree is X at the place written and the old
window before and after it (words_list.bend). An element read needs its block inside the storage (the bytes of a window
that runs past the end are cut), so the induction carries a count bound C and hk: i0 + k <= C, with C blocks inside the
storage (hC).

    python3 codegen/proofs/collections/cell_list_set_view.py            # write
    python3 codegen/proofs/collections/cell_list_set_view.py --check    # nonzero exit if the output is stale
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys

from codegen.proofs.collections import packed_list_set_view as VL

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.law_module_helpers import run_single  # noqa: E402
OUT = ROOT / 'proofs/obj/view_cells.bend'

BASE = lambda i: 'O.e8(Nat.mul(%s, 64n))' % i
EL = lambda W, i: 'S.BytesValue{CL.cbytes(%s, %s)}' % (W, i)
ITEMS = lambda k, W, i: 'CL.citems(%s, %s, %s)' % (k, W, i)
XS, XA = 'X', 'X, hx'
XP = '+X: List<&2, U32>, +hx: {F.spec_common__length(U32, X) == 512n : Nat}'
MKX = 'S.BytesValue{FX.limbs(X)}'
KN = '512n'

ARITH = '''def e8_add(+a: Nat, +b: Nat) -> {O.e8(Nat.add(a, b)) == Nat.add(O.e8(a), O.e8(b)) : Nat}:
  match a:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, O.e8(Nat.add(p, b)), Nat.add(O.e8(p), O.e8(b)), e8_add(p, b)) : {8n+_ == 8n+Nat.add(O.e8(p), O.e8(b)) : Nat}
      {==}

def blk(+i: Nat) -> {Nat.add(O.e8(Nat.mul(i, 64n)), 512n) == O.e8(Nat.mul(1n+i, 64n)) : Nat}:
  Equal.trans(Nat, Nat.add(O.e8(Nat.mul(i, 64n)), 512n), Nat.add(512n, O.e8(Nat.mul(i, 64n))), O.e8(Nat.mul(1n+i, 64n)),
    F.nat__add_comm(O.e8(Nat.mul(i, 64n)), 512n),
    Equal.sym(Nat, O.e8(Nat.add(64n, Nat.mul(i, 64n))), Nat.add(O.e8(64n), O.e8(Nat.mul(i, 64n))), e8_add(64n, Nat.mul(i, 64n))))

def mul64_mono(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(Nat.mul(a, 64n), Nat.mul(b, 64n)) == True{} : Bool}:
  match a b:
    case 0n _: F.nat__zero_le(Nat.mul(b, 64n))
    case 1n+p 0n: Empty.absurd({Nat.is_le(Nat.mul(1n+p, 64n), Nat.mul(0n, 64n)) == True{} : Bool}, F.logic__false_true(h))
    case 1n+p 1n+q: F.nat__le_add_left(Nat.mul(p, 64n), Nat.mul(q, 64n), 64n, mul64_mono(p, q, h))

def mono(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(O.e8(Nat.mul(a, 64n)), O.e8(Nat.mul(b, 64n))) == True{} : Bool}:
  F.nat__double_le(Nat.double(Nat.double(Nat.mul(a, 64n))), Nat.double(Nat.double(Nat.mul(b, 64n))),
    F.nat__double_le(Nat.double(Nat.mul(a, 64n)), Nat.double(Nat.mul(b, 64n)), F.nat__double_le(Nat.mul(a, 64n), Nat.mul(b, 64n), mul64_mono(a, b, h))))
'''


def text():
    Q = BASE('J')
    TK = 'WW.tk(X, d, t, %s, 0n)' % Q
    W2 = 'F.array__slots(U32, %s)' % TK
    W1 = 'F.array__slots(U32, t)'
    P = 'F.spec_common__pow2(d)'
    XP_ = XP
    HB = '+hb: {Nat.is_le(Nat.add(%s, %s), %s) == True{} : Bool}' % (Q, KN, P)
    PF0 = '+pf: {F.array__perfect(U32, d, t) == True{} : Bool}'
    PF = PF0 + ', +C: Nat, +hC: {Nat.is_le(%s, %s) == True{} : Bool}, +hk: {Nat.is_le(Nat.add(i0, k), C) == True{} : Bool}' % (BASE('C'), P)
    PFV = PF0 + ', +hcap: {Nat.is_le(%s, %s) == True{} : Bool}' % (BASE('c'), P)
    HKS = 'F.logic__subst(Nat, z => {Nat.is_le(z, C) == True{} : Bool}, Nat.add(i0, 1n+q), Nat.add(1n+i0, q), F.nat__add_succ(i0, q), hk)'
    ROOM = 'idx_room(i0, C, %s, lt_k(i0, q, C, hk), hC)' % P
    SUBS = {'@RA@': 'hb, pf, C, hC, ' + HKS, '@EA@': 'hb, pf, ' + ROOM, '@PA@': 'pf, c, hcap, F.nat__le_refl(c)',
            '@PFV@': PFV, '@XP@': XP_, '@HB@': HB, '@PF@': PF, '@W2@': W2, '@W1@': W1, '@XA@': XA, '@XS@': XS, '@MKX@': MKX, '@K@': KN}

    def sub(t):
        for k, v in SUBS.items():
            t = t.replace(k, v)
        return t
    out = []
    w = out.append
    w('\n'.join(['import Base', 'import ../../src/obj.bend as O', 'import ../../types/schema.bend as S', 'import ../compact/found.bend as F',
                 'import ./mtree_run.bend as MR', 'import ./value_set.bend as VS', 'import ./words_rw.bend as WR', 'import ./words_win.bend as WW',
                 'import ./words_list.bend as WL', 'import ./words_spec.bend as WS', 'import ./spec_fixed.bend as FX', 'import ./cells_light.bend as CL', 'import ./words_obj_light.bend as WO']))
    w('')
    w('# GENERATED by cell_list_set_view (codegen). Do not edit.')
    w('# The view of the list of 2048-byte cells after one cell (512 words at word %s) is written into perfect storage: the view before with that item replaced.' % Q)
    w('# See codegen/proofs/collections/cell_list_set_view.py.')
    w('')
    w(ARITH)
    VL.gaps(w, BASE, KN)
    w('''# a block below the bound C is inside storage that holds C blocks, the count bound of the induction
def lt_k(+i0: Nat, +q: Nat, +C: Nat, +hk: {Nat.is_le(Nat.add(i0, 1n+q), C) == True{} : Bool}) -> {Nat.is_lt(i0, C) == True{} : Bool}:
  F.nat__lt_le_trans(i0, Nat.add(i0, 1n+q), C, lt_add_succ(i0, q), hk)

# the tree written is perfect, so its slots are as many as the storage's
def tk_len(+d: Nat, +t: F.array__Tree<U32>, +X: List<&2, U32>, +q: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {F.spec_common__length(U32, F.array__slots(U32, WW.tk(X, d, t, q, 0n))) == F.spec_common__pow2(d) : Nat}:
  F.array__slots_length(U32, d, WW.tk(X, d, t, q, 0n), WW.tk_perfect(X, d, t, q, 0n, pf))

# the bytes of a cell are the limbs of its window of words
def cbytes_win(+W: List<&2, U32>, +j: Nat, +h: {Nat.is_le(Nat.add(%s, 512n), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {CL.cbytes(W, j) == FX.limbs(WL.wlist(512n, W, %s)) : +List<U32>}:
  WL.btake_limbs(512n, W, %s, h)

# a block inside the storage is inside its slots
def room_in(+W: List<&2, U32>, +P: Nat, +e: {F.spec_common__length(U32, W) == P : Nat}, +j: Nat, +h: {Nat.is_le(Nat.add(%s, 512n), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(%s, 512n), F.spec_common__length(U32, W)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(%s, 512n), z) == True{} : Bool}, P, F.spec_common__length(U32, W), Equal.sym(Nat, F.spec_common__length(U32, W), P, e), h)
''' % (BASE('j'), BASE('j'), BASE('j'), BASE('j'), BASE('j'), BASE('j')))
    w(sub('''# the room for the words written, with their length
def hbx(+d: Nat, @XP@, +Q: Nat, +hb: {Nat.is_le(Nat.add(Q, 512n), %s) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Q, F.spec_common__length(U32, X)), %s) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(Q, z), %s) == True{} : Bool}, 512n, F.spec_common__length(U32, X), Equal.sym(Nat, F.spec_common__length(U32, X), 512n, hx), hb)

def hb0(+d: Nat, @XP@, +Q: Nat, +hb: {Nat.is_le(Nat.add(Q, 512n), %s) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(Q, 0n), F.spec_common__length(U32, X)), %s) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, F.spec_common__length(U32, X)), %s) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, F.nat__add_zero(Q)), hbx(d, X, hx, Q, hb))

# the gap after block J, in words, for the words written
def aft(+X: List<&2, U32>, +hx: {F.spec_common__length(U32, X) == 512n : Nat}, +i: Nat, +J: Nat, +hs: {Nat.is_lt(i, J) == False{} : Bool}, +ne: {Nat.is_eq(i, J) == False{} : Bool})
    -> {Nat.is_le(Nat.add(%s, F.spec_common__length(U32, X)), %s) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(%s, z), %s) == True{} : Bool}, 512n, F.spec_common__length(U32, X), Equal.sym(Nat, F.spec_common__length(U32, X), 512n, hx),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(%s, 512n), z) == True{} : Bool}, Nat.add(%s, 0n), %s, F.nat__add_zero(%s),
      gap_after(i, J, 0n, F.nat__lt_or_eq(J, i, F.nat__not_lt_le(i, J, hs), WR.neq_sym(i, J, ne)))))

# the words written are the window of the written tree at their place
def hit_words(+d: Nat, +t: F.array__Tree<U32>, @XP@, +J: Nat, @HB@, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {WL.wlist(512n, %s, %s) == X : List<&2, U32>}:
  F.logic__subst(Nat, z => {WL.wlist(z, %s, %s) == X : List<&2, U32>}, F.spec_common__length(U32, X), 512n, hx,
    F.logic__subst(Nat, z => {WL.wlist(F.spec_common__length(U32, X), %s, z) == X : List<&2, U32>}, Nat.add(%s, 0n), %s, F.nat__add_zero(%s),
      WL.wlist_hit(X, d, t, %s, 0n, hb0(d, X, hx, %s, hb), pf)))
''' % (P, P, P, P, P, P,
       Q, BASE('i'), Q, BASE('i'), Q, BASE('i'), BASE('i'), BASE('i'),
       W2, Q, W2, Q, W2, Q, Q, Q, Q, Q)))
    return out, sub, Q, W1, W2, P


def cells_file():
    out, sub, Q, W1, W2, P = text()
    w = out.append
    w('''# the bytes of a written value: the limbs of its 512 words
def val_view(+dv: Nat, +tv: F.array__Tree<U32>, +hv: {Nat.is_le(512n, F.spec_common__pow2(dv)) == True{} : Bool}, +pfv: {F.array__perfect(U32, dv, tv) == True{} : Bool})
    -> {WO.wview(O.Words{F.array__thaw(U32, tv), 2048}) == FX.limbs(WL.alist(512n, F.array__slots(U32, tv), 0n)) : +List<U32>}:
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, tv)), tv, F.array__freeze_thaw(U32, tv)) :
    {WS.btake(U32.to_nat(2048), FX.limbs(F.array__slots(U32, _))) == FX.limbs(WL.alist(512n, F.array__slots(U32, tv), 0n)) : +List<U32>}
  Equal.trans(+List<U32>, WS.btake(U32.to_nat(2048), FX.limbs(F.array__slots(U32, tv))), FX.limbs(WL.wlist(512n, F.array__slots(U32, tv), 0n)), FX.limbs(WL.alist(512n, F.array__slots(U32, tv), 0n)),
    WL.btake_limbs(512n, F.array__slots(U32, tv), 0n, F.logic__subst(Nat, z => {Nat.is_le(512n, z) == True{} : Bool}, F.spec_common__pow2(dv), F.spec_common__length(U32, F.array__slots(U32, tv)), Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, tv)), F.spec_common__pow2(dv), F.array__slots_length(U32, dv, tv, pfv)), hv)),
    Equal.cong(List<&2, U32>, +List<U32>, z => FX.limbs(z), WL.wlist(512n, F.array__slots(U32, tv), 0n), WL.alist(512n, F.array__slots(U32, tv), 0n), WL.wlist_alist(512n, F.array__slots(U32, tv), 0n)))
''')
    w(sub('''# ---- one element ----
def el_hit(+d: Nat, +t: F.array__Tree<U32>, @XP@, +J: Nat, @HB@, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {%s == @MKX@ : S.Value}:
  Equal.cong(+List<U32>, S.Value, z => S.BytesValue{z}, CL.cbytes(@W2@, J), FX.limbs(X),
    Equal.trans(+List<U32>, CL.cbytes(@W2@, J), FX.limbs(WL.wlist(512n, @W2@, %s)), FX.limbs(X),
      cbytes_win(@W2@, J, room_in(@W2@, %s, tk_len(d, t, X, %s, pf), J, hb)),
      Equal.cong(List<&2, U32>, +List<U32>, z => FX.limbs(z), WL.wlist(512n, @W2@, %s), X, hit_words(d, t, X, hx, J, hb, pf))))
''' % (EL(W2, 'J'), Q, P, Q, Q)))
    # the window of the written tree equals the old one for a block i away from J
    w(sub('''# a block whose window is the same before and after the write has the same cell
def win_eq(+d: Nat, +t: F.array__Tree<U32>, @XP@, +J: Nat, +i: Nat, +hw: {WL.wlist(512n, @W2@, %s) == WL.wlist(512n, @W1@, %s) : List<&2, U32>},
    +hroom: {Nat.is_le(Nat.add(%s, 512n), %s) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {%s == %s : S.Value}:
  Equal.cong(+List<U32>, S.Value, z => S.BytesValue{z}, CL.cbytes(@W2@, i), CL.cbytes(@W1@, i),
    Equal.trans(+List<U32>, CL.cbytes(@W2@, i), FX.limbs(WL.wlist(512n, @W2@, %s)), CL.cbytes(@W1@, i),
      cbytes_win(@W2@, i, room_in(@W2@, %s, tk_len(d, t, X, %s, pf), i, hroom)),
      Equal.trans(+List<U32>, FX.limbs(WL.wlist(512n, @W2@, %s)), FX.limbs(WL.wlist(512n, @W1@, %s)), CL.cbytes(@W1@, i),
        Equal.cong(List<&2, U32>, +List<U32>, z => FX.limbs(z), WL.wlist(512n, @W2@, %s), WL.wlist(512n, @W1@, %s), hw),
        Equal.sym(+List<U32>, CL.cbytes(@W1@, i), FX.limbs(WL.wlist(512n, @W1@, %s)), cbytes_win(@W1@, i, room_in(@W1@, %s, F.array__slots_length(U32, d, t, pf), i, hroom))))))
''' % (BASE('i'), BASE('i'), BASE('i'), P, EL(W2, 'i'), EL(W1, 'i'),
       BASE('i'), P, Q, BASE('i'), BASE('i'), BASE('i'), BASE('i'), BASE('i'), P)))
    w(sub('''def el_same_go(+s: Bool, +d: Nat, +t: F.array__Tree<U32>, @XP@, +i: Nat, +J: Nat, +hs: {Nat.is_lt(i, J) == s : Bool},
    +ne: {Nat.is_eq(i, J) == False{} : Bool}, @HB@, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hroom: {Nat.is_le(Nat.add(%s, 512n), %s) == True{} : Bool})
    -> {%s == %s : S.Value}:
  match s:
    case True{}:
      win_eq(d, t, @XA@, J, i, WL.wlist_before(512n, X, d, t, %s, %s, gap_before(i, J, hs), hbx(d, X, hx, %s, hb), pf), hroom, pf)
    case False{}:
      win_eq(d, t, @XA@, J, i, WL.wlist_after(512n, X, d, t, %s, %s, aft(X, hx, i, J, hs, ne), hbx(d, X, hx, %s, hb), pf), hroom, pf)

def el_same(+d: Nat, +t: F.array__Tree<U32>, @XP@, +i: Nat, +J: Nat, +ne: {Nat.is_eq(i, J) == False{} : Bool}, @HB@, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hroom: {Nat.is_le(Nat.add(%s, 512n), %s) == True{} : Bool})
    -> {%s == %s : S.Value}:
  el_same_go(Nat.is_lt(i, J), d, t, @XA@, i, J, {==}, ne, hb, pf, hroom)
''' % (BASE('i'), P, EL(W2, 'i'), EL(W1, 'i'),
       Q, BASE('i'), Q,
       Q, BASE('i'), Q,
       BASE('i'), P, EL(W2, 'i'), EL(W1, 'i'))))
    VL.items_region(w, sub, BASE, ITEMS, EL, XS, XA, MKX, Q, W1, W2)
    return '\n'.join(out)


def main():
    run_single('viewcells', OUT, cells_file(), '--check' in sys.argv)


if __name__ == '__main__':
    main()
