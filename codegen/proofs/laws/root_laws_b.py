#!/usr/bin/env python3
"""Phase B root laws: containers held by pointer (Type kind) and their fields
(byte storage, byte lists, vectors of Bytes32, boxes, nested containers),
against spec/root_relation.bend `roots`.

    python3 codegen/proofs/laws/root_laws_b.py [--check] [--status]

Output: proofs/obj/root_types.bend.

Per shape p (a Type-kind container, a field group of a wide container, or a
box) this emits
  v_p(o)            the specification value of the object (its view)
  d_p(hl, o)        the digest of the object, a function of its fields
  rep_p(o, s)       the object represents a value of the schema s (the
                    fields' representation invariants, relative to s's parts)
  ok_p(s)           the schema's shape and depth facts, one closed Bool
  eqs_p(s)          the schemas of its Data-kind parts (small, compared)
  st_p              the runtime root returns (h, (o, d_p(hl, o)))
  rs_p              RR.roots(v_p(o), s, [bytes(d_p(hl, o))])
and per name N a law
  N_root_correct(h, o, s, es: s == Spec.N(), rep: rep_p(o, s)) :
    RR.roots(v_p(o), s, [bytes(snd(snd(T.N_hash_tree_root(h, o))))]).

Why the schema is a variable and its facts are one Bool: see
proofs/obj/words_obj.bend (the checker compares separately built copies of a
large closed number by unfolding both into unary digits).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys
from pathlib import Path

from codegen.impl import generate as G  # noqa: E402
from codegen.proofs.laws import root_laws as RA  # noqa: E402
from codegen.core import schema  # noqa: E402

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'proofs/obj/root_types.bend'
# Names whose closed schema fact takes the checker long to evaluate (the
# Transaction limit 2^30 bytes: `Lim.minimal(div(2^30 + 31, 32), 25)` is 2^30
# unary steps of Nat.div): kept in their own module, so root_types stays quick.
LARGE_NAMES = ('Transaction', 'ExecutionPayload', 'BeaconBlockBody', 'BeaconBlock', 'SignedBeaconBlock')

HEAD = ['import Base', 'import ../compact/found.bend as F', 'import ../../src/buffer.bend as B', 'import ../../src/digest.bend as D',
        'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T',
        'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P', 'import ./cform.bend as CF', 'import ./amap.bend as AM',
        'import ../../spec/root_relation.bend as RR', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ./schema_shapes.bend as SH', 'import ./dk.bend as DK', 'import ./mtree_defs.bend as MD',
        'import ./root_support.bend as RS', 'import ./words_obj.bend as WO', 'import ./list_obj.bend as LO',
        'import ./pv_obj.bend as PV', 'import ./bitlist_obj.bend as BO', 'import ./cells.bend as CE', 'import ./obj_support.bend as OS', 'import ./root_names.bend as RN',
        'import ./ulist_obj.bend as UL', 'import ./lim_ul.bend as LUL', 'import ./lim_leaf.bend as LLF', 'import ./packed_obj.bend as PK', 'import ./elems48.bend as E48', 'import ./xlist_support.bend as XS',
        'import ./mtree_run.bend as MR', 'import ./list_root.bend as LR', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/limits.bend as Lim', 'import ../../spec/bit_root.bend as Mix', 'import ../../spec/nat_bytes.bend as Len', 'import ../../spec/byte_list.bend as BL']


BIGHEAD = HEAD + ['import ./root_types.bend as RT', 'import ./lim_bl.bend as LBL']
# BIG proofs (proofs/obj/root_<Name>.bend, proofs/obj/lim_sym.bend,
# proofs/obj/lim_bl.bend): their closed schema facts hold a 2^30-byte limit,
# proved symbolically and instantiated in the exact form of the goal. They
# check only with a checker that compares two calls of one def rigidly before
# unfolding them (the pinned rigid-subterms build, aa99b746); stock Bend 2.0.34
# evaluates the limit in unary.
# Byte-list shapes whose closed fact is proved symbolically: shape -> (depth,
# lemma `(+s, +es: {s == Spec.<Name>()}) -> {LO.ok_bl(s, OS.dv_<depth>(OS.DV0())) == True}`).
LIMIT_LEMMAS_BL = {'bl1073741824': (25, 'LBL.tx_ok_at')}
# Field shapes of BeaconState whose closed schema fact (a limit of 2^24, 2^27 or
# 2^40) is proved symbolically: shape -> lemma
# `(+s, +es: {s == Spec.<Schema>()}) -> {<the field's ok conjunct at s, OS.DV0()> == True{}}`
# (proofs/obj/lim_st.bend).
LIMIT_LEMMAS = {'l16777216_b32': 'LST.hr_ok_at', 'l1099511627776_Validator': 'LST.val_ok_at',
            'l1099511627776_u64': 'LST.bal_ok_at', 'l1099511627776_u8': 'LST.part_ok_at',
            'l16777216_HistoricalSummary': 'LST.hs_ok_at', 'l134217728_PendingDeposit': 'LST.pd_ok_at',
            'l134217728_PendingPartialWithdrawal': 'LST.ppw_ok_at',
            # IndexedAttestation's attesting_indices (2^17), for root_types' names too (proofs/obj/lim_ul.bend)
            'l131072_u64': 'LUL.ia_ok_at',
            # Attestation's aggregation_bits and Blob (2^17), for the names holding them (proofs/obj/lim_leaf.bend):
            # evaluated, each cost about 0.3 s, repeated in every name above them
            'bits131072': 'LLF.bits_ok_at', 'b131072': 'LLF.bv_ok_at'}
# Names whose laws are generated after all others, into their own files: their
# new shapes into proofs/obj/root_state.bend (importing root_types as RT, so
# root_types does not grow), their name law into a root_<Name>.bend.
SPLIT_NAMES = ('BeaconState',)
STATE_OUT = ROOT / 'proofs/obj/root_state.bend'
STATE_HEAD = ['import ./root_types.bend as RT', 'import ./blist_obj.bend as BLI', 'import ./packed_bytes.bend as PB',
              'import ./bitlist_pack.bend as BLP', 'import ./bits_leaf.bend as BLF', 'import ./root_leaf.bend as RL',
              'import ../../spec/bit_packing.bend as Bp', 'import ../../spec/packing.bend as Pack', 'import ../../spec/primitives.bend as SP',
              'import ../../proofs/power_division.bend as PD', 'import ../../proofs/word_split.bend as WSp',
              'import ./spec_fixed.bend as FX', 'import ./words_spec.bend as WS']


WD_WORDS = r'''
# ---- digest witnesses of byte storage fields (values from the invariant) ----
def wdc_wdig(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(WO.wdig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(WO.wdig(hl, _, d))
  (WO.wdig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wdc_ldig(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(LO.ldig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(LO.ldig(hl, _, d))
  (LO.ldig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wdc_udig(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(UL.udig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(UL.udig(hl, _, d))
  (UL.udig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wd_bv(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: WO.rep_bv(o, s)) -> OS.DW(WO.wdig(hl, o, d)):
  (+w, +z) = r
  wdc_wdig(hl, o, d, CF.cf1(o, w))
def wd_pv(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: PV.rep_pv(o, s)) -> OS.DW(WO.wdig(hl, o, d)):
  (+w, +z) = r
  wdc_wdig(hl, o, d, CF.cfv(o, w))
def wd_bl(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: LO.rep_bl(o, s)) -> OS.DW(LO.ldig(hl, o, d)):
  (+w, +z) = r
  wdc_ldig(hl, o, d, CF.cfl(o, w))
def wd_ul(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: UL.rep_ul(o, s)) -> OS.DW(UL.udig(hl, o, d)):
  (+w, +z) = r
  wdc_udig(hl, o, d, CF.cfl(o, w))
def wd_ev(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: E48.rep_ev(o, s)) -> OS.DW(E48.edig(hl, o, d)):
  (+w, +z) = r
  (+t, +a) = w
  (+dw, +b) = a
  (+N, +c) = b
  (+ce, +y) = c
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(E48.edig(hl, _, d))
  (E48.edig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wd_el(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: E48.rep_el(o, s)) -> OS.DW(E48.ldig(hl, o, d)):
  (+w, +z) = r
  (+t, +a) = w
  (+dw, +b) = a
  (+N, +c) = b
  (+ce, +y) = c
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(E48.ldig(hl, _, d))
  (E48.ldig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})

def wd_cl(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: CE.rep_el(o, s)) -> OS.DW(CE.ldig(hl, o, d)):
  (+w, +z) = r
  (+t, +a) = w
  (+dw, +b) = a
  (+N, +c) = b
  (+ce, +y) = c
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(CE.ldig(hl, _, d))
  (CE.ldig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})

# ---- Data mirrors of Type-kind objects (for lists of Type-kind elements) ----
# A list's array holds Type-kind boxes; its laws describe the array as the
# image AM.am(th, t) of a Data mirror tree t. `th` builds the object from its
# mirror, `fz` reads the mirror back, and fz(th(m)) == m.
type WMr is Data:
  WMr{t: F.array__Tree<U32>, n: U32}
def th_w(m: WMr) -> O.Words:
  match m:
    case WMr{+t, +n}: O.Words{F.array__thaw(U32, t), n}
def fz_w(x: O.Words) -> WMr:
  match x:
    case O.Words{ws, +n}: WMr{F.array__freeze(U32, ws), n}
def fzth_w(+m: WMr) -> {fz_w(th_w(m)) == m : WMr}:
  match m:
    case WMr{+t, +n}:
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) : {WMr{_, n} == WMr{t, n} : WMr}
      {==}
type BMr is Data:
  BMr{t: F.array__Tree<U32>, k: U32}
def th_b(m: BMr) -> O.Bits:
  match m:
    case BMr{+t, +k}: O.Bits{F.array__thaw(U32, t), k}
def fz_b(x: O.Bits) -> BMr:
  match x:
    case O.Bits{ws, +k}: BMr{F.array__freeze(U32, ws), k}
def fzth_b(+m: BMr) -> {fz_b(th_b(m)) == m : BMr}:
  match m:
    case BMr{+t, +k}:
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) : {BMr{_, k} == BMr{t, k} : BMr}
      {==}
type MB<-X: Data> is Data:
  MNone{}
  MSome{v: X}

# A container or byte list schema is composite: no basic size.
def bs_cont(+E: S.Schema, +k: {SH.is_Container(E) == True{} : Bool}) -> {RR.basic_size(E) == None{} : Maybe<&2, Nat>}:
  %Equal.sym(S.Schema, E, S.Container{SH.Container_names(E), SH.Container_fields(E)}, SH.Container_shape(E, k)) : {RR.basic_size(_) == None{} : Maybe<&2, Nat>}
  {==}
def bs_blist(+E: S.Schema, +k: {SH.is_ByteList(E) == True{} : Bool}) -> {RR.basic_size(E) == None{} : Maybe<&2, Nat>}:
  %Equal.sym(S.Schema, E, S.ByteList{SH.ByteList_limit(E)}, SH.ByteList_shape(E, k)) : {RR.basic_size(_) == None{} : Maybe<&2, Nat>}
  {==}
'''


# Names whose shape laws are generated and checked but whose name instance is
# not: the closed schema fact compares Nats of 2^15 (attesting_indices limit
# 131072 -> chunk limit 32768, `Lim.minimal(32768, 15)`). A closed definition
# evaluates it (1 s), but after the `s -> Spec.Name()` rewrite the checker's
# evaluation of `Nat.is_le` at 2^15 fails and printing the error overflows the
# stack.
NAME_SKIP = {}


# depths from which schema facts hold the depth as a variable (OS.DV)
BIGD = 14


class Skip(Exception):
    pass


# Binder names the generated proofs use; a module-level name equal to one of
# them could not be qualified by `qualify` without capturing the binder.
BINDERS = {'o', 's', 'h', 'hl', 'ehl', 'seg', 'rep', 'ok', 'ev', 'eq', 'dv', 'edv', 't', 'dw', 'N', 'eo', 'pf', 'hd', 'hn',
           'er', 'wf', 'hv', 'junk', 'e', 'b', 'd', 'v', 'n', 'W', 'i', 'k', 'sE', 'm', 'y', 'x', 'q', 'r', 'w', 'c', 'es', 'rest'}


def defnames(text):
    """The names a generated module defines: defs, laws, types and constructors."""
    names = set()
    intype = False
    for line in text.split('\n'):
        m = re.match(r'(def|law|type)\s+(\w+)', line)
        if m:
            names.add(m.group(2))
            intype = m.group(1) == 'type'
            continue
        if intype:
            m = re.match(r'  (\w+)\{', line)
            if m:
                names.add(m.group(1))
                continue
            intype = False
    clash = names & BINDERS
    assert not clash, clash
    return names


def qualify(text, names, prefix):
    """Qualify every reference to one of `names` in text with `prefix`."""
    if not names:
        return text
    pat = re.compile(r'(?<![\w.])(' + '|'.join(sorted(map(re.escape, names), key=len, reverse=True)) + r')(?![\w])')
    return pat.sub(lambda m: prefix + m.group(1), text)


def fold_and(cs):
    if not cs:
        return 'True{}'
    t = cs[-1]
    for c in reversed(cs[:-1]):
        t = f'Bool.and({c}, {t})'
    return t


def fold_p2(ts):
    if not ts:
        return 'Unit'
    t = ts[-1]
    for c in reversed(ts[:-1]):
        t = f'DK.P2({c}, {t})'
    return t


def tails(f, j):
    for _ in range(j):
        f = f'SH.Chain_tail({f})'
    return f


def sch(s, i, cf='SH.Container_fields'):
    return f'SH.Chain_head({tails(f"{cf}({s})", i)})'


class Gen:
    def __init__(self):
        self.names = schema.load(ROOT / 'codegen/fulu.yaml')
        self.g = G.Gen()
        for n, t in self.names.items():
            self.g.shape(t)
        self.done = {}        # shape p -> True (emitted) / Skip message
        self.okinfo = {}      # shape p -> how ok_p is built (see okproof)
        self.out = []
        self.phaseA = set()
        for s in self.g.order:
            if s.kind == 'box':
                continue
            try:
                RA.covered(s)
                RA.spec_schema(s)
                self.phaseA.add(s.p)
            except RA.Skip:
                pass

    # ---- field kinds ------------------------------------------------------
    def fk(self, fs):
        """The kind of a field shape, or Skip."""
        k = self.fk0(fs)
        return k

    def dd(self, fs, k):
        """The depth term of a field in schema facts: a literal, or for depth
        >= BIGD the variable record's entry (see OS.DV)."""
        d = self.depth(fs, k)
        return f'OS.dv_{d}(dv)' if d >= BIGD else f'{d}n'

    bvr_ok = False

    def bvr_laws(self, fs):
        """v/d/rp/st/rs of a one-word Data record bit vector of k < 32 bits
        (the generic gbits laws' argument at depth 0): the representation fact is
        that the word is its low k bits followed by zeros."""
        p = fs.p
        if p in self.done:
            return
        self.done[p] = True
        L = []
        w = L.append
        if 'BITS:helpers' not in self.done:
            self.done['BITS:helpers'] = True
            w('# ---- bit lengths of words (as codegen/proofs/laws/root_laws_generic.py BITS_HEAD) ----')
            w('def bl32(ws: +List<U32>) -> Nat:')
            w('  match ws:')
            w('    case Nil{}: 0n')
            w('    case Con{+x, r}: Nat.add(32n, bl32(r))')
            w('law len_bitsof:')
            w('  for +ws: +List<U32>')
            w('  {List.length(&2, Bool, BLP.bitsof(ws)) == bl32(ws) : Nat}')
            w('def len_bitsof(ws):')
            w('  match ws:')
            w('    case Nil{}: {==}')
            w('    case Con{+x, +r}:')
            w('      %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, BLF.wbits(x), BLP.bitsof(r))), Nat.add(32n, List.length(&2, Bool, BLP.bitsof(r))), BLF.len_app_w(x, BLP.bitsof(r))) :')
            w('        {_ == Nat.add(32n, bl32(r)) : Nat}')
            w('      %Equal.sym(Nat, List.length(&2, Bool, BLP.bitsof(r)), bl32(r), len_bitsof(r)) : {Nat.add(32n, _) == Nat.add(32n, bl32(r)) : Nat}')
            w('      {==}')
            w('law btk_len:')
            w('  for +n: Nat')
            w('  for +xs: +List<Bool>')
            w('  for +h: {Nat.is_le(n, List.length(&2, Bool, xs)) == True{} : Bool}')
            w('  {List.length(&2, Bool, BLP.btk(n, xs)) == n : Nat}')
            w('def btk_len(n, xs, h):')
            w('  match n:')
            w('    case 0n: {==}')
            w('    case 1n+ +p:')
            w('      match xs:')
            w('        case Nil{}: Empty.absurd({List.length(&2, Bool, BLP.btk(1n+p, Nil{})) == 1n+p : Nat}, MD.false_true(h))')
            w('        case Con{+b, +t}:')
            w('          %Equal.sym(Nat, List.length(&2, Bool, BLP.btk(p, t)), p, btk_len(p, t, h)) : {1n+_ == 1n+p : Nat}')
            w('          {==}')
            w('')
        nb = fs.t.size
        k = nb
        R = RA.qual(fs.rep)
        A = [f'a{i}' for i in range(k)]
        low = 'WNil{}'
        for a in reversed(A):
            low = f'WCon{{{a}, {low}}}'
        lowp = low.replace('WCon{a', 'WCon{+a')
        X = f'U32{{WSp.join({k}n, {32 - k}n, {low}, Word.zero({32 - k}n))}}'
        XT = f'U32{{WSp.join({k}n, {32 - k}n, t, Word.zero({32 - k}n))}}'
        M = 'Maybe<&2, +List<U32>>'

        def dg(x):
            return f'D.D{{B.swap32({x}), 0, 0, 0, 0, 0, 0, 0}}'
        Lc = f'[{dg(X)}]'
        BITS = f'BLP.btk({nb}n, BLP.bitsof([{X}]))'
        BYTES = f'WS.btake(Bp.byte_count({nb}n), FX.limbs([{X}]))'
        DIG = f'MD.rtree(0n, True{{}}, hl, {Lc}, 0n)'
        aargs = ', '.join(f'+{a}: Bool' for a in A)
        acall = ', '.join(A)
        w(f'# ---- {p}: Bitvector[{nb}] in one word (a Data field) ----')
        w(f'def {p}_lh({aargs}) -> {{Nat.is_le({nb}n, List.length(&2, Bool, BLP.bitsof([{X}]))) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(Nat, List.length(&2, Bool, BLP.bitsof([{X}])), bl32([{X}]), len_bitsof([{X}])) :')
        w(f'    {{Nat.is_le({nb}n, _) == True{{}} : Bool}}')
        w('  {==}')
        w(f'def {p}_len({aargs}) -> {{List.length(&2, Bool, {BITS}) == {nb}n : Nat}}:')
        w(f'  btk_len({nb}n, BLP.bitsof([{X}]), {p}_lh({acall}))')
        w(f'def {p}_ch({aargs}) -> {{Pack.scan({BYTES}, 31n, [], []) == MD.bytes_list({Lc}) : +List<+List<U32>>}}:')
        w(f'  %Equal.sym(+List<U32>, D.bytes({dg(X)}), List.append(&2, U32, FX.limbs([{X}]), SP.zero_bytes(28n)), RL.bytes_1({X})) :')
        w(f'    {{Pack.scan({BYTES}, 31n, [], []) == [_] : +List<+List<U32>>}}')
        w('  {==}')
        w(f'def {p}_g(+hl: Nat, +ehl: {{hl == 64n : Nat}}, {aargs}) -> {{Mix.bitvector_at_depth({nb}n, 0n, {BITS}) == Some{{D.bytes({DIG})}} : {M}}}:')
        w(f'  %Equal.sym(Nat, List.length(&2, Bool, {BITS}), {nb}n, {p}_len({acall})) :')
        w(f'    {{Mix.vector_gate(Bool.and(Nat.is_lt(0n, {nb}n), Nat.is_eq(_, {nb}n)), {nb}n, 0n, {BITS}) == Some{{D.bytes({DIG})}} : {M}}}')
        w(f'  %Equal.sym(+List<U32>, Bp.pack({BITS}), {BYTES}, BLP.bpack([{X}], {nb}n, {{==}})) :')
        w(f'    {{Lim.at_depth(Mix.chunk_limit({nb}n), 0n, Pack.scan(_, 31n, [], [])) == Some{{D.bytes({DIG})}} : {M}}}')
        w(f'  %Equal.sym(+List<+List<U32>>, Pack.scan({BYTES}, 31n, [], []), MD.bytes_list({Lc}), {p}_ch({acall})) :')
        w(f'    {{Lim.at_depth(Mix.chunk_limit({nb}n), 0n, _) == Some{{D.bytes({DIG})}} : {M}}}')
        w(f'  %Equal.sym({M}, Lim.at_depth(Mix.chunk_limit({nb}n), 0n, MD.bytes_list({Lc})), Some{{D.bytes(MD.rtree(0n, Nat.is_lt(0n, MD.dlen({Lc})), hl, {Lc}, 0n))}}, RS.at_depth_tree(Mix.chunk_limit({nb}n), 0n, hl, {Lc}, {{==}}, {{==}}, ehl)) :')
        w(f'    {{_ == Some{{D.bytes({DIG})}} : {M}}}')
        w('  {==}')
        w(f'def v_{p}(o: {R}) -> S.Value:')
        w('  match o:')
        w(f'    case {R}{{+w0}}: S.BitsValue{{BLP.btk({nb}n, BLP.bitsof([w0]))}}')
        w(f'def d_{p}(+hl: Nat, o: {R}) -> D.Digest:')
        w('  match o:')
        w(f'    case {R}{{+w0}}: {dg("w0")}')
        w(f'def last_{p}(o: {R}) -> U32:')
        w('  match o:')
        w(f'    case {R}{{+w0}}: w0')
        w(f'# the representation fact: the bits past {nb} are zero')
        w(f'def rp_{p}(o: {R}) -> Data: {{last_{p}(o) == U32{{WSp.join({k}n, {32 - k}n, WSp.take({k}n, 32n, PD.bits(last_{p}(o))), Word.zero({32 - k}n))}} : U32}}')
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, +o: {R}, +seg: U32) -> {{T.{p}_root(hl, h, o, seg) == (h, d_{p}(hl, o)) : B.Buf & D.Digest}}:')
        w('  match o:')
        w(f'    case {R}{{+w0}}: {{==}}')
        w(f'def rsh_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, +t: Word({k}n)) -> RR.roots(S.BitsValue{{BLP.btk({nb}n, BLP.bitsof([{XT}]))}}, S.BitVector{{{nb}n}}, [D.bytes({dg(XT)})]):')
        w('  match t:')
        w(f'    case {lowp}: (0n, ({{==}}, {p}_g(hl, ehl, {acall})))')
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, +o: {R}, +rp: rp_{p}(o)) -> RR.roots(v_{p}(o), S.BitVector{{{nb}n}}, [D.bytes(d_{p}(hl, o))]):')
        w('  match o:')
        w(f'    case {R}{{+w0}}:')
        w(f'      %Equal.sym(U32, w0, U32{{WSp.join({k}n, {32 - k}n, WSp.take({k}n, 32n, PD.bits(w0)), Word.zero({32 - k}n))}}, rp) :')
        w(f'        RR.roots(S.BitsValue{{BLP.btk({nb}n, BLP.bitsof([_]))}}, S.BitVector{{{nb}n}}, [D.bytes({dg("_")})])')
        w(f'      rsh_{p}(hl, ehl, WSp.take({k}n, 32n, PD.bits(w0)))')
        w('')
        self.out.extend(L)

    DIGF = {'bits': 'BO.bdig', 'bv': 'WO.wdig', 'pv': 'WO.wdig', 'bl': 'LO.ldig', 'ul': 'UL.udig', 'ev': 'E48.edig', 'el': 'E48.ldig'}

    # Packed lists of uint8 / uint16 / Bytes32 (proofs/obj/blist_obj.bend) and
    # packed vectors of basic elements (packed_obj PK, packed_bytes PB): kind ->
    # (count shift, view, rep, ok, rep -> wf, spec law).
    PLIST = {'l1': ('0n', 'PB.vview1', 'BLI.rep_l1', 'BLI.ok_l1', 'BLI.rep_wf1', 'BLI.l1_rs'),
             'l2': ('1n', 'PB.vview2', 'BLI.rep_l2', 'BLI.ok_l2', 'BLI.rep_wf2', 'BLI.l2_rs'),
             'lh': ('5n', 'BLI.hview', 'BLI.rep_lh', 'BLI.ok_lh', 'BLI.rep_wfh', 'BLI.lh_rs')}

    @staticmethod
    def vk(k):
        """(module, K) of a packed vector kind 'vk<K>'."""
        K = k[2:]
        return ('PB' if K in ('1', '2', 'b') else 'PK'), K

    def digf(self, k, x, d):
        """The digest of a leaf field kind at depth term d."""
        if k in self.PLIST:
            return f'BLI.bdig(hl, {x}, {d}, {self.PLIST[k][0]})'
        if k.startswith('vk'):
            return f'WO.wdig(hl, {x}, {d})'
        return f'{self.DIGF[k]}(hl, {x}, {d})'

    def isleaf(self, k):
        return k in self.DIGF or k in self.PLIST or k.startswith('vk')

    def wdk(self, k):
        """Emit (once) the digest witness wd_<k> of a packed list / vector kind."""
        key = 'WD:' + k
        if key in self.done:
            return
        self.done[key] = True
        L = []
        w = L.append
        if 'WD:bdig' not in self.done:
            self.done['WD:bdig'] = True
            w('def wdc_bdig(+hl: Nat, -o: O.Words, +d: Nat, +sh: Nat, +c: CF.CF(o)) -> OS.DW(BLI.bdig(hl, o, d, sh)):')
            w('  (+t, +c1) = c')
            w('  (+N, +ce) = c1')
            w('  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(BLI.bdig(hl, _, d, sh))')
            w('  (BLI.bdig(hl, O.Words{F.array__thaw(U32, t), N}, d, sh), {==})')
        if k in self.PLIST:
            sh, _v, R, _o, WF, _r = self.PLIST[k]
            w(f'def wd_{k}(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: {R}(o, s)) -> OS.DW(BLI.bdig(hl, o, d, {sh})):')
            w(f'  wdc_bdig(hl, o, d, {sh}, CF.cfl(o, {WF}(o, s, r)))')
        else:
            Mo, K = self.vk(k)
            w(f'def wd_{k}(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: {Mo}.rep_v{K}(o, s)) -> OS.DW(WO.wdig(hl, o, d)):')
            w(f'  wdc_wdig(hl, o, d, CF.cf1(o, {Mo}.rep_wf{K}(o, s, r)))')
        w('')
        self.out.extend(L)

    def fk0(self, fs):
        if fs.kind == 'box':
            inner = fs.inner
            if inner.data:
                if inner.p not in self.phaseA:
                    raise Skip(f'boxed {inner.p}: not a phase A shape')
                return 'boxD'
            self.shape(inner)
            return 'boxT'
        if fs.data and fs.kind == 'rec' and fs.t.kind == 'bits' and fs.t.size % 32 and fs.p not in self.phaseA:
            # a bit vector in part of a word: its law is generated here (bvr_laws)
            if not self.bvr_ok:
                raise Skip(f'{fs.p}: partial-word bit vector field (its laws need the bit-packing imports of root_state)')
            if fs.nw != 1:
                raise Skip(f'{fs.p}: partial-word bit vector field of {fs.nw} words')
            self.bvr_laws(fs)
            return 'bvr'
        if fs.data:
            if fs.p not in self.phaseA:
                raise Skip(f'{fs.p}: not a phase A shape')
            # a Data field whose phase A law needs a representation fact (uint8/16)
            return 'datar' if RA.needs_rep(fs) else 'data'
        if fs.kind == 'fixwords' and fs.t.kind == 'bytes':
            return 'bv'
        if fs.kind == 'fixwords' and fs.t.kind == 'bits' and getattr(self, 'v2', False):
            return 'bvb'
        if fs.kind == 'bytelist':
            return 'bl'
        if fs.kind == 'bitlist':
            if fs.t is not None and fs.t.kind == 'pbits':
                # a progressive bit list: its root is bits_root_prog, not a fixed-depth tree
                if getattr(self, 'v2', False):
                    return 'pb'
                raise Skip(f'{fs.p}: progressive bit list field (no law yet)')
            return 'bits'
        if fs.kind == 'packed' and fs.t.kind == 'vector' and fs.t.elem.kind == 'bytes' and fs.t.elem.size == 32:
            return 'pv'
        if fs.kind == 'packed' and fs.t.kind == 'list' and fs.t.elem.kind == 'uint' and fs.t.elem.size == 8:
            return 'ul'
        if fs.kind == 'packed' and fs.t.kind == 'list' and fs.t.elem.kind == 'uint' and fs.t.elem.size in (1, 2):
            return f'l{fs.t.elem.size}'
        if fs.kind == 'packed' and fs.t.kind == 'list' and fs.t.elem.kind == 'bytes' and fs.t.elem.size == 32:
            return 'lh'
        if fs.kind == 'packed' and fs.t.kind == 'vector' and (fs.t.elem.kind == 'bool' or (fs.t.elem.kind == 'uint' and fs.t.elem.size in (1, 2, 4, 8, 16, 32))):
            return 'vk' + ('b' if fs.t.elem.kind == 'bool' else str(fs.t.elem.size))
        if getattr(self, 'v2', False) and fs.kind == 'packed' and fs.t.kind == 'plist' and (fs.t.elem.kind == 'bool' or (fs.t.elem.kind == 'uint' and fs.t.elem.size in (1, 2, 4, 8, 16, 32))):
            return 'pk'
        if getattr(self, 'v2', False) and fs.kind == 'seq' and fs.t.kind == 'plist' and not fs.pelem.data:
            self.ptlist_laws(fs)
            return 'ptl'
        if getattr(self, 'v2', False) and fs.kind == 'seq' and fs.t.kind == 'plist' and fs.pelem.data:
            if fs.pelem.p not in self.phaseA:
                raise Skip(f'{fs.p}: element {fs.pelem.p} not a phase A shape')
            self.plist_x_laws(fs)
            return 'px'
        if fs.kind == 'seq' and fs.t.kind in ('list', 'vector') and not fs.pelem.data:
            self.tlist_laws(fs)
            return 'tl'
        if fs.kind == 'seq' and fs.t.kind in ('list', 'vector') and fs.pelem.data:
            if fs.pelem.p not in self.phaseA:
                raise Skip(f'{fs.p}: element {fs.pelem.p} not a phase A shape')
            self.xlist_laws(fs)
            return 'xl'
        if fs.kind == 'packed_elems' and fs.t.elem.kind == 'bytes' and fs.t.elem.size == 2048 and fs.t.kind == 'list':
            self.clist_st(fs)
            return 'cl'
        if fs.kind == 'packed_elems' and fs.t.elem.kind == 'bytes' and fs.t.elem.size == 48:
            if fs.t.kind == 'vector':
                return 'ev'
            self.elist_st(fs)
            return 'el'
        if fs.kind == 'container':
            self.shape(fs)
            return 'T'
        raise Skip(f'{fs.p}: field kind {fs.kind}/{fs.t.kind if fs.t else ""} not covered yet')

    @staticmethod
    def pk(fs):
        """(key, shift, view) of a packed progressive list field (prog_list)."""
        K = 'b' if fs.t.elem.kind == 'bool' else str(fs.t.elem.size)
        sh = {'b': 0, '1': 0, '2': 1, '4': 2, '8': 3, '16': 4, '32': 5}[K]
        VIEW = {'8': 'UL.uview(o)', '4': 'PK.vview4(o)', '16': 'PK.vview16(o)', '32': 'PK.vview32(o)',
                '1': 'PB.vview1(o)', '2': 'PB.vview2(o)', 'b': 'PB.vviewb(o)'}[K]
        return K, sh, VIEW

    def depth(self, fs, k):
        if k == 'bv':
            return G.log2ceil(G.chunks_of(fs.t.size))
        if k == 'bvb':
            return G.log2ceil(G.chunks_of((fs.t.size + 7) // 8))
        if k == 'bl':
            return G.log2ceil(max(1, (fs.t.size + 31) // 32))
        if k == 'bits':
            return G.log2ceil(max(1, (fs.t.size + 255) // 256))
        if k == 'pv':
            return G.log2ceil(fs.t.size)
        if k == 'ul':
            return G.log2ceil(max(1, (8 * fs.t.size + 31) // 32))
        if k in ('l1', 'l2'):
            return G.log2ceil(max(1, (int(k[1]) * fs.t.size + 31) // 32))
        if k == 'lh':
            return G.log2ceil(max(1, fs.t.size))
        if k.startswith('vk'):
            W = 1 if fs.t.elem.kind == 'bool' else fs.t.elem.size
            return G.log2ceil(G.chunks_of(W * fs.t.size))
        if k in ('ev', 'el', 'xl', 'tl', 'cl'):
            return G.log2ceil(fs.t.size)
        return None

    def E(self, fs):
        return RA.spec_schema(fs.inner if fs.kind == 'box' else fs)

    @staticmethod
    def pre(k):
        """Where the laws of a Data field's shape are: phase A (RN) or here."""
        return '' if k == 'bvr' else 'RN.'

    def view(self, fs, k, x):
        if k in ('data', 'datar', 'bvr'):
            return f'{self.pre(k)}v_{fs.p}({x})'
        if k in ('bv', 'bl'):
            return f'S.BytesValue{{WO.wview({x})}}'
        if k == 'bvb':
            return f'S.BitsValue{{WBV.wbits({x}, {fs.t.size}n)}}'
        if k == 'pv':
            return f'PV.pview({x})'
        if k in ('bits', 'pb'):
            return f'S.BitsValue{{BO.bview({x})}}'
        if k == 'ul':
            return f'UL.uview({x})'
        if k in self.PLIST:
            return f'{self.PLIST[k][1]}({x})'
        if k.startswith('vk'):
            Mo, K = self.vk(k)
            return f'{Mo}.vview{K}({x})'
        if k in ('ev', 'el'):
            return f'E48.eview({x})'
        if k == 'cl':
            return f'CE.eview({x})'
        if k in ('xl', 'tl', 'px', 'ptl'):
            return f'xv_{fs.p}({x})'
        if k == 'pk':
            return self.pk(fs)[2].replace('(o)', f'({x})')
        return f'v_{fs.p}({x})'

    def dig(self, fs, k, x):
        if k in ('data', 'datar', 'bvr'):
            return f'{self.pre(k)}d_{fs.p}(hl, {x})'
        if k == 'pb':
            return f'PBO.pbdig(hl, {x})'
        d = self.depth(fs, k)
        if k in ('bv', 'pv', 'bvb'):
            return f'WO.wdig(hl, {x}, {d}n)'
        if k == 'bl':
            return f'LO.ldig(hl, {x}, {d}n)'
        if k == 'bits':
            return f'BO.bdig(hl, {x}, {d}n)'
        if k == 'ul':
            return f'UL.udig(hl, {x}, {d}n)'
        if k in self.PLIST or k.startswith('vk'):
            return self.digf(k, x, f'{d}n')
        if k == 'ev':
            return f'E48.edig(hl, {x}, {d}n)'
        if k == 'el':
            return f'E48.ldig(hl, {x}, {d}n)'
        if k == 'cl':
            return f'CE.ldig(hl, {x}, {d}n)'
        if k in ('xl', 'tl', 'px', 'ptl'):
            return f'xd_{fs.p}(hl, {x})'
        if k == 'pk':
            return f'PG.pdig(hl, {x}, {self.pk(fs)[1]}n)'
        return f'd_{fs.p}(hl, {x})'

    def rep(self, fs, k, x, sx):
        if k == 'data':
            return None
        if k in ('datar', 'bvr'):
            return f'{self.pre(k)}rp_{fs.p}({x})'

        if k == 'bv':
            return f'WO.rep_bv({x}, {sx})'
        if k == 'bl':
            return f'LO.rep_bl({x}, {sx})'
        if k == 'bits':
            return f'BO.rep_bits({x}, {sx})'
        if k == 'pb':
            return f'PBO.rep_pbits({x}, {sx})'
        if k == 'bvb':
            return f'WBV.rep_bvb({x}, {fs.t.size}n)'
        if k == 'pv':
            return f'PV.rep_pv({x}, {sx})'
        if k == 'ul':
            return f'UL.rep_ul({x}, {sx})'
        if k in self.PLIST:
            return f'{self.PLIST[k][2]}({x}, {sx})'
        if k.startswith('vk'):
            Mo, K = self.vk(k)
            return f'{Mo}.rep_v{K}({x}, {sx})'
        if k == 'ev':
            return f'E48.rep_ev({x}, {sx})'
        if k == 'el':
            return f'E48.rep_el({x}, {sx})'
        if k == 'cl':
            return f'CE.rep_el({x}, {sx})'
        if k in ('xl', 'px'):
            return f'rep_{fs.p}({x}, {sx})'
        if k == 'pk':
            return f'PG.rep_pl{self.pk(fs)[0]}({x}, {sx})'
        return f'rep_{fs.p}({x}, {sx})'

    def ok(self, fs, k, sx):
        d = self.depth(fs, k)
        if k in ('data', 'datar', 'bvr', 'boxD'):
            return None
        if k == 'bv':
            return f'WO.ok_bv({sx}, {self.dd(fs, k)})'
        if k == 'bl':
            return f'LO.ok_bl({sx}, {self.dd(fs, k)})'
        if k == 'bits':
            return f'BO.ok_bits({sx}, {self.dd(fs, k)})'
        if k == 'pb':
            return f'PBO.ok_pbits({sx})'
        if k == 'bvb':
            return f'WBV.ok_bvb({sx}, {fs.t.size}n, {d}n)'
        if k == 'pv':
            return f'PV.ok_pv({sx}, {self.dd(fs, k)})'
        if k == 'ul':
            return f'UL.ok_ul({sx}, {self.dd(fs, k)})'
        if k in self.PLIST:
            return f'{self.PLIST[k][3]}({sx}, {self.dd(fs, k)})'
        if k.startswith('vk'):
            Mo, K = self.vk(k)
            return f'{Mo}.ok_v{K}({sx}, {self.dd(fs, k)})'
        if k == 'ev':
            return f'E48.ok_ev({sx}, {self.dd(fs, k)})'
        if k == 'el':
            return f'E48.ok_el({sx}, {self.dd(fs, k)})'
        if k == 'cl':
            return f'CE.ok_el({sx}, {self.dd(fs, k)})'
        if k == 'xl':
            return f'ok_{fs.p}({sx}, dv)' if d >= BIGD else f'ok_{fs.p}({sx})'
        if k == 'px':
            return f'ok_{fs.p}({sx})'
        if k == 'pk':
            return f'PG.ok_pl{self.pk(fs)[0]}({sx})'
        return f'ok_{fs.p}({sx}, dv)'  # T, boxT, tl

    def eqs_type(self, fs, k, sx):
        if k in ('data', 'datar', 'bvr', 'boxD'):
            return f'{{{sx} == {self.E(fs)} : S.Schema}}'
        if k in ('boxT', 'T'):
            inner = fs.inner if k == 'boxT' else fs
            return f'eqs_{inner.p}({sx})'
        if k == 'xl':
            return f'{{{self.vsub(fs, "SH.ListOf_element")}({sx}) == {RA.spec_schema(fs.pelem)} : S.Schema}}'
        if k == 'px':
            return f'{{SH.ProgressiveList_element({sx}) == {RA.spec_schema(fs.pelem)} : S.Schema}}'
        if k in ('tl', 'ptl'):
            return f'eqs_{fs.p}({sx})'
        return None

    def st(self, fs, k, x, sx, r):
        """(lhs, rhs, type, proof) of the field's state equation."""
        R = RA.qual(fs.rep)
        lhs = f'T.{fs.p}_root(hl, h, {x}, seg)'
        dg = self.dig(fs, k, x)
        if k in ('data', 'datar', 'bvr'):
            return lhs, f'(h, {dg})', 'B.Buf & D.Digest', f'{self.pre(k)}st_{fs.p}(hl, h, {x}, seg)'
        ty = f'B.Buf & ({R} & D.Digest)'
        rhs = f'(h, ({x}, {dg}))'
        d = self.depth(fs, k)
        if k == 'bv':
            pf = f'WO.bv_st(hl, h, {x}, {d}, seg, {d}n, WO.rep_wf({x}, {sx}, {r}), {{==}})'
        elif k == 'bl':
            pf = f'LO.bl_st(hl, h, {x}, {d}, seg, {d}n, LO.rep_wf({x}, {sx}, {r}), {{==}})'
        elif k == 'bits':
            pf = f'BO.bst(hl, h, {x}, {d}, seg, {d}n, BO.rep_wf({x}, {sx}, {r}), {{==}})'
        elif k == 'pb':
            pf = f'PBO.pbst(hl, h, {x}, seg, {r})'
        elif k == 'pk':
            pf = f'PG.pl_st(hl, h, {x}, seg, {self.pk(fs)[1]}n, PG.rep_wf{self.pk(fs)[0]}({x}, {sx}, {r}))'
        elif k == 'bvb':
            pf = f'WBV.bvb_st(hl, h, {x}, {d}, seg, {d}n, {fs.t.size}n, {r}, {{==}})'
        elif k == 'pv':
            pf = f'PV.pv_st(hl, h, {x}, {d}, seg, {d}n, PV.rep_wf({x}, {sx}, {r}), {{==}})'
        elif k == 'ul':
            pf = f'UL.ul_st(hl, h, {x}, {d}, seg, {d}n, UL.rep_wf({x}, {sx}, {r}), {{==}})'
        elif k in self.PLIST:
            pf = f'BLI.bl_st(hl, h, {x}, {d}, seg, {d}n, {self.PLIST[k][0]}, {self.PLIST[k][4]}({x}, {sx}, {r}), {{==}})'
        elif k.startswith('vk'):
            Mo, K = self.vk(k)
            pf = f'WO.bv_st(hl, h, {x}, {d}, seg, {d}n, {Mo}.rep_wf{K}({x}, {sx}, {r}), {{==}})'
        elif k == 'ev':
            pf = f'E48.ev_st(hl, h, {x}, {d}, seg, {d}n, E48.rep_wfv({x}, {sx}, {r}), {{==}})'
        elif k in ('el', 'xl', 'tl', 'cl'):
            pf = f'st_{fs.p}(hl, h, {x}, seg, {sx}, {r})'
        else:
            pf = f'st_{fs.p}(hl, h, {x}, seg, {sx}, {r})'
        return lhs, rhs, ty, pf

    def rs(self, fs, k, x, sx, r, okp, eqp):
        vw, dg = self.view(fs, k, x), self.dig(fs, k, x)
        if k == 'data':
            return f'OS.transport({vw}, {sx}, {self.E(fs)}, [D.bytes({dg})], {eqp}, RN.rs_{fs.p}(hl, ehl, {x}))'
        if k in ('datar', 'bvr'):
            return f'OS.transport({vw}, {sx}, {self.E(fs)}, [D.bytes({dg})], {eqp}, {self.pre(k)}rs_{fs.p}(hl, ehl, {x}, {r}))'

        d = self.depth(fs, k)
        if self.isleaf(k) and d >= BIGD:
            # the spec law at the variable depth, moved to the literal-depth digest
            D = f'OS.dv_{d}(dv)'
            du = f'OS.dvu(OS.dv_{d}, dv, edv, {d}, {{==}})'
            dl = f'OS.dvl(OS.dv_{d}, dv, edv, {{==}})'
            if k in self.PLIST:
                law = f'{self.PLIST[k][5]}(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})'
            elif k.startswith('vk'):
                Mo, K = self.vk(k)
                law = f'{Mo}.v{K}_rs(hl, ehl, {x}, {sx}, {D}, {r}, {okp}, {dl})'
            else:
                law = None
            law = law or {'bv': f'WO.bv_rs(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})',
                   'bl': f'LO.bl_rs(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})',
                   'pv': f'PV.pv_rs(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})',
                   'ul': f'UL.ul_rs(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})',
                   'ev': f'E48.ev_rs(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})',
                   'el': f'E48.el_rs(hl, ehl, h, {x}, {sx}, {D}, {r}, {okp}, {dl})',
                   'bits': f'BO.brs(hl, ehl, h, {x}, {sx}, {D}, {d}, 0, {r}, {okp}, {du}, {dl})'}[k]
            e = f'Equal.cong(Nat, D.Digest, y => {self.digf(k, x, "y")}, {D}, {d}n, OS.dveq(OS.dv_{d}, dv, edv))'
            return f'OS.dtrans({vw}, {sx}, {self.digf(k, x, f"{d}n")}, {self.digf(k, x, D)}, {e}, {law})'
        if k == 'bv':
            return f'WO.bv_rs(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k == 'bl':
            return f'LO.bl_rs(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k == 'bits':
            return f'BO.brs(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k == 'pb':
            return f'PBO.pbrs(hl, ehl, h, {x}, {sx}, {r}, {okp})'
        if k == 'bvb':
            return f'WBV.bvb_rs(hl, ehl, h, {x}, {sx}, {fs.t.size}n, {d}n, {r}, {okp}, {{==}})'
        if k == 'pv':
            return f'PV.pv_rs(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k == 'ul':
            return f'UL.ul_rs(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k in self.PLIST:
            return f'{self.PLIST[k][5]}(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k.startswith('vk'):
            Mo, K = self.vk(k)
            return f'{Mo}.v{K}_rs(hl, ehl, {x}, {sx}, {d}n, {r}, {okp}, {{==}})'
        if k == 'ev':
            return f'E48.ev_rs(hl, ehl, h, {x}, {sx}, {d}n, {d}, 0, {r}, {okp}, {{==}}, {{==}})'
        if k == 'el':
            return f'E48.el_rs(hl, ehl, h, {x}, {sx}, {d}n, {r}, {okp}, {{==}})'
        if k == 'cl':
            return f'CE.el_rs(hl, ehl, h, {x}, {sx}, {d}n, {r}, {okp}, {{==}})'
        if k == 'px':
            return f'rs_{fs.p}(hl, ehl, h, {x}, {sx}, {r}, {okp}, {eqp})'
        if k == 'pk':
            return f'PG.pl{self.pk(fs)[0]}_rs(hl, ehl, {x}, {sx}, {r}, {okp})'
        if k == 'xl':
            if d >= BIGD:
                return f'rs_{fs.p}(hl, ehl, h, {x}, {sx}, {r}, dv, edv, {okp}, {eqp})'
            return f'rs_{fs.p}(hl, ehl, h, {x}, {sx}, {r}, {okp}, {eqp})'
        if k == 'boxD':
            return f'rs_{fs.p}(hl, ehl, h, {x}, {sx}, {r}, {eqp})'
        return f'rs_{fs.p}(hl, ehl, h, {x}, {sx}, {r}, dv, edv, {okp}, {eqp})'

    def witness(self, fs, k, x, sx, r, i, w, ind='  '):
        """Emit a let giving a value digest of the Type-kind field x (erased) from
        its representation invariant r; return (witness, proof of dig(x) == it)."""
        d = self.depth(fs, k)
        if k == 'bits':
            call = f'BO.bwd(hl, {x}, {sx}, {self.dd(fs, k) if d < BIGD else str(d) + "n"}, {r})'
        elif k == 'pb':
            call = f'PBO.pbwd(hl, {x}, {sx}, {r})'
        elif k == 'pk':
            call = f'PLO.pdwd(hl, {x}, {self.pk(fs)[1]}n, PG.rep_wf{self.pk(fs)[0]}({x}, {sx}, {r}))'
        elif k == 'bvb':
            call = f'WBV.bvb_wd(hl, {x}, {fs.t.size}n, {d}n, {r})'
        elif k in ('bv', 'bl', 'pv', 'ul', 'ev', 'el', 'cl'):
            call = f'wd_{k}(hl, {x}, {sx}, {d}n, {r})'
        elif k in self.PLIST or k.startswith('vk'):
            self.wdk(k)
            call = f'wd_{k}(hl, {x}, {sx}, {d}n, {r})'
        else:
            call = f'wd_{fs.p}(hl, {x}, {sx}, {r})'
        d0 = self.dig(fs, k, x)
        w(f'{ind}+dd{i} = OS.dwv({d0}, {call})')
        w(f'{ind}+de{i} = OS.dwe({d0}, {call})')
        return f'dd{i}', f'de{i}'

    def elist_st(self, fs):
        """The state law of a list of Bytes48 (its generated mix of the count)."""
        if fs.p in self.done:
            return
        p = fs.p
        d = self.depth(fs, 'el')
        W = 'O.Words{F.array__thaw(U32, t), N}'
        L = []
        w = L.append
        w(f'# ---- {p}: list of Bytes48 ----')
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: O.Words, +seg: U32, +s: S.Schema, +rep: E48.rep_el(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, E48.ldig(hl, o, {d}n))) : B.Buf & (O.Words & D.Digest)}}:')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        w('  (+hd, +room) = w5')
        w(f'  %Equal.sym(O.Words, o, {W}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, E48.ldig(hl, _, {d}n))) : B.Buf & (O.Words & D.Digest)}}')
        w(f'  %Equal.sym(B.Buf & (O.Words & D.Digest), O.elems_root(hl, h, {W}, 12, 1, {d}, seg), (h, ({W}, E48.edig(hl, {W}, {d}n))),')
        w(f'      E48.ev_st(hl, h, {W}, {d}, seg, {d}n, (t, (dw, (N, ({{==}}, (pf, (hd, room)))))), {{==}})) :')
        w(f'    {{T.{p}_mix(hl, _) == (h, ({W}, E48.ldig(hl, {W}, {d}n))) : B.Buf & (O.Words & D.Digest)}}')
        w('  {==}')
        w('')
        self.done[p] = True
        self.out.extend(L)

    def clist_st(self, fs):
        """The state law of a list of cells (2048 bytes) (its generated mix of the count)."""
        if fs.p in self.done:
            return
        p = fs.p
        d = self.depth(fs, 'cl')
        W = 'O.Words{F.array__thaw(U32, t), N}'
        L = []
        w = L.append
        w(f'# ---- {p}: list of cells (2048 bytes) ----')
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: O.Words, +seg: U32, +s: S.Schema, +rep: CE.rep_el(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, CE.ldig(hl, o, {d}n))) : B.Buf & (O.Words & D.Digest)}}:')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        w('  (+hd, +room) = w5')
        w(f'  %Equal.sym(O.Words, o, {W}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, CE.ldig(hl, _, {d}n))) : B.Buf & (O.Words & D.Digest)}}')
        w(f'  %Equal.sym(B.Buf & (O.Words & D.Digest), O.elems_root(hl, h, {W}, 512, 6, {d}, seg), (h, ({W}, CE.edig(hl, {W}, {d}n))),')
        w(f'      CE.ev_st(hl, h, {W}, {d}, seg, {d}n, (t, (dw, (N, ({{==}}, (pf, (hd, room)))))), {{==}})) :')
        w(f'    {{T.{p}_mix(hl, _) == (h, ({W}, CE.ldig(hl, {W}, {d}n))) : B.Buf & (O.Words & D.Digest)}}')
        w('  {==}')
        w('')
        self.done[p] = True
        self.out.extend(L)

    @staticmethod
    def vsub(fs, c):
        """A list schema accessor, as the vector's when fs is a vector."""
        if fs.t.kind != 'vector':
            return c
        for a, b in (('SH.is_ListOf', 'SH.is_Vector'), ('SH.ListOf_limit', 'SH.Vector_length'), ('SH.ListOf_element', 'SH.Vector_element'),
                     ('SH.ListOf_shape', 'SH.Vector_shape'), ('S.ListOf{', 'S.Vector{')):
            c = c.replace(a, b)
        return c

    def vecify(self, fs, L):
        """The laws of a vector of containers from its list laws: the runtime
        mixes no length in, the schema is a vector whose length is the count, and
        the specification's sequence has no length (codegen: the same tree)."""
        if fs.t.kind != 'vector':
            return L
        p = fs.p
        out = []
        if 'VEC:helpers' not in self.done:
            self.done['VEC:helpers'] = True
            out += ['# ---- vectors of containers: the sequence relation without a length ----',
                    'def vec_none(-items: S.Value, -E: S.Schema, -L: Nat, -outs: +List<+List<U32>>, +e: {RR.basic_size(E) == None{} : Maybe<&2, Nat>},',
                    '    p: RR.sequence(None{}, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), L, False{}, None{}, outs))',
                    '    -> RR.roots(S.Sequence{items}, S.Vector{E, L}, outs):',
                    '  %Equal.sym(Maybe<&2, Nat>, RR.basic_size(E), None{}, e) : RR.sequence(_, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), L, False{}, None{}, outs)',
                    '  p',
                    'law veq_le:', '  for +a: Nat', '  for +b: Nat', '  for +e: {Nat.is_eq(a, b) == True{} : Bool}',
                    '  {Nat.is_le(a, b) == True{} : Bool}',
                    'def veq_le(a, b, e):',
                    '  match a b:',
                    '    case 0n 0n: {==}',
                    '    case 0n 1n+q: Empty.absurd({Nat.is_le(0n, 1n+q) == True{} : Bool}, MD.false_true(e))',
                    '    case 1n+p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, MD.false_true(e))',
                    '    case 1n+ +p 1n+ +q: veq_le(p, q, e)', '']
        # the length-mixing lemma xlm_<p> has no use for a vector: drop it
        keep, skip = [], False
        for line in L:
            if line.startswith(f'def xlm_{p}('):
                skip = True
            elif skip and (line.startswith('def ') or line.startswith('law ')):
                skip = False
            if not skip:
                keep.append(line)
        text = '\n'.join(keep)
        # drop the length mixing: O.mix_len(hl, X, N) -> X (N the count)
        for cnt in ('N', 'n'):
            key = 'O.mix_len(hl, '
            i = 0
            while True:
                i = text.find(key, i)
                if i < 0:
                    break
                j, depth = i + len(key), 1
                k = j
                while depth:
                    ch = text[k]
                    depth += ch == '('
                    depth -= ch == ')'
                    k += 1
                inner = text[j:k - 1]
                if inner.endswith(', ' + cnt):
                    text = text[:i] + inner[:-len(', ' + cnt)] + text[k:]
                else:
                    i = k
        text = self.vsub(fs, text)
        text = text.replace(f'{{Nat.is_le(U32.to_nat(xlen_o_{p}(o)), SH.Vector_length(s)) == True{{}} : Bool}}',
                            f'{{Nat.is_eq(U32.to_nat(xlen_o_{p}(o)), SH.Vector_length(s)) == True{{}} : Bool}}')
        text = text.replace(f'+hv: {{Nat.is_le(U32.to_nat(xlen_o_{p}(o)), Lm) == True{{}} : Bool}}) -> {{Nat.is_le(U32.to_nat(N), Lm) == True{{}} : Bool}}',
                            f'+hv: {{Nat.is_eq(U32.to_nat(xlen_o_{p}(o)), Lm) == True{{}} : Bool}}) -> {{Nat.is_eq(U32.to_nat(N), Lm) == True{{}} : Bool}}')
        text = text.replace(f'{{Nat.is_le(U32.to_nat(_), Lm) == True{{}} : Bool}}\n  hv', f'{{Nat.is_eq(U32.to_nat(_), Lm) == True{{}} : Bool}}\n  hv')
        text = text.replace(f'+hvN = xhv_{p}(o, t, N, SH.Vector_length(s), eo, hv)',
                            f'+hvN = veq_le(U32.to_nat(N), SH.Vector_length(s), xhv_{p}(o, t, N, SH.Vector_length(s), eo, hv))')
        text = text.replace('OS.list_none(', 'vec_none(')
        # the length-mixing lemma is not used: the length part of the relation is [root] == [root]
        key = f'xlm_{p}(hl, ehl, N,'
        while key in text:
            i = text.index(key)
            k, depth = i + len(f'xlm_{p}('), 1
            while depth:
                depth += text[k] == '('
                depth -= text[k] == ')'
                k += 1
            text = text[:i] + '{==}' + text[k:]
        assert f'xlm_{p}(hl, ehl, N,' not in text, p
        out += text.split('\n')
        return out

    def xcommon(self, p, X, RX, EX, w):
        """The element, digest-list, view and tree laws shared by the lists of
        Data-kind elements (bounded `xl`, progressive `px`)."""
        w(f'def xat_{p}(W: List<&2, {RX}>, +i: Nat) -> {RX}:')
        w('  match W:')
        w(f'    case Nil{{}}: T.{X.p}_default()')
        w('    case Con{+x, t}:')
        w('      match i:')
        w('        case 0n: x')
        w(f'        case 1n+j: xat_{p}(t, j)')
        w(f'law nth_{p}:')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        w(f'  for +hi: {{Nat.is_lt(i, F.spec_common__length({RX}, W)) == True{{}} : Bool}}')
        w(f'  {{F.spec_common__nth({RX}, W, i) == Some{{xat_{p}(W, i)}} : Maybe<&2, {RX}>}}')
        w(f'def nth_{p}(W, i, hi):')
        w('  match W:')
        w(f'    case Nil{{}}: Empty.absurd({{F.spec_common__nth({RX}, Nil{{}}, i) == Some{{xat_{p}(Nil{{}}, i)}} : Maybe<&2, {RX}>}}, MD.false_true(Equal.trans(Bool, False{{}}, Nat.is_lt(i, 0n), True{{}}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{{}}, F.nat__not_lt_zero(i)), hi)))')
        w('    case Con{+x, +t}:')
        w('      match i:')
        w('        case 0n: {==}')
        w(f'        case 1n+ +j: nth_{p}(t, j, hi)')
        w(f'def xl_{p}(k: Nat, +W: List<&2, {RX}>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:')
        w('  match k:')
        w('    case 0n: []')
        w(f'    case 1n+q: RN.d_{X.p}(hl, xat_{p}(W, i)) <> xl_{p}(q, W, 1n+i, hl)')
        w(f'law xlen_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        w('  for +hl: Nat')
        w(f'  {{MD.dlen(xl_{p}(k, W, i, hl)) == k : Nat}}')
        w(f'def xlen_{p}(k, W, i, hl):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w(f'      %xlen_{p}(q, W, 1n+i, hl) : {{1n+MD.dlen(xl_{p}(q, W, 1n+i, hl)) == 1n+_ : Nat}}')
        w('      {==}')
        w(f'law xat_at_{p}:')
        w('  for +s: Nat')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        w('  for +hl: Nat')
        w('  for +e: {Nat.is_lt(s, k) == True{} : Bool}')
        w(f'  {{MD.dhead(MD.ddrop(s, xl_{p}(k, W, i, hl))) == RN.d_{X.p}(hl, xat_{p}(W, Nat.add(s, i))) : D.Digest}}')
        w(f'def xat_at_{p}(s, k, W, i, hl, e):')
        w('  match s:')
        w('    case 0n:')
        w('      match k:')
        w(f'        case 0n: Empty.absurd({{MD.dhead(MD.ddrop(0n, xl_{p}(0n, W, i, hl))) == RN.d_{X.p}(hl, xat_{p}(W, Nat.add(0n, i))) : D.Digest}}, MD.false_true(e))')
        w('        case 1n+q: {==}')
        w('    case 1n+ +p1:')
        w('      match k:')
        w(f'        case 0n: Empty.absurd({{MD.dhead(MD.ddrop(1n+p1, xl_{p}(0n, W, i, hl))) == RN.d_{X.p}(hl, xat_{p}(W, Nat.add(1n+p1, i))) : D.Digest}}, MD.false_true(e))')
        w('        case 1n+ +q:')
        w(f'          %MR.add_succ(p1, i) : {{MD.dhead(MD.ddrop(p1, xl_{p}(q, W, 1n+i, hl))) == RN.d_{X.p}(hl, xat_{p}(W, _)) : D.Digest}}')
        w(f'          xat_at_{p}(p1, q, W, 1n+i, hl, e)')
        w(f'def xi_{p}(k: Nat, +W: List<&2, {RX}>, +i: Nat) -> S.Value:')
        w('  match k:')
        w('    case 0n: S.EmptyItems{}')
        w(f'    case 1n+q: S.Items{{RN.v_{X.p}(xat_{p}(W, i)), xi_{p}(q, W, 1n+i)}}')
        # elements whose phase A law needs a representation fact (uint8/16 fields)
        erp = RA.needs_rep(X)
        ER = ', er' if erp else ''
        if erp:
            w(f'def ereps_{p}(k: Nat, +W: List<&2, {RX}>, +i: Nat) -> Data:')
            w('  match k:')
            w('    case 0n: {True{} == True{} : Bool}')
            w(f'    case 1n+q: DK.P2(RN.rp_{X.p}(xat_{p}(W, i)), ereps_{p}(q, W, 1n+i))')
        w(f'law xroots_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        w('  for +hl: Nat')
        w('  for +ehl: {hl == 64n : Nat}')
        if erp:
            w(f'  for +er: ereps_{p}(k, W, i)')
        w(f'  RR.roots(xi_{p}(k, W, i), S.Repeat{{{EX}}}, MD.bytes_list(xl_{p}(k, W, i, hl)))')
        w(f'def xroots_{p}(k, W, i, hl, ehl{ER}):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        if erp:
            w('      (+r0, +rs) = er')
        R0 = ', r0' if erp else ''
        RS_ = ', rs' if erp else ''
        w(f'      ([D.bytes(RN.d_{X.p}(hl, xat_{p}(W, i)))], (MD.bytes_list(xl_{p}(q, W, 1n+i, hl)), (RN.rs_{X.p}(hl, ehl, xat_{p}(W, i){R0}), (xroots_{p}(q, W, 1n+i, hl, ehl{RS_}), {{==}}))))')
        w(f'law xcount_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        w(f'  {{Codec.count(xi_{p}(k, W, i)) == k : Nat}}')
        w(f'def xcount_{p}(k, W, i):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w(f'      %Equal.sym(Nat, Codec.count(xi_{p}(q, W, 1n+i)), q, xcount_{p}(q, W, 1n+i)) : {{1n+_ == 1n+q : Nat}}')
        w('      {==}')
        w(f'law xph1_{p}:')
        w('  for +d: Nat')
        w('  for +b: Bool')
        w('  for +hl: Nat')
        w('  for +seg: U32')
        w('  for +v: Nat')
        w('  for +s: Nat')
        w('  for +n: Nat')
        w('  for -h: B.Buf')
        w(f'  for -ws: Array<{RX}>')
        w('  for +dl: D.Digest')
        w(f'  {{T.{p}_mt(d, 1n, b, hl, seg, v, s, n, (h, (ws, dl))) == T.{p}_mj(hl, dl, T.{p}_mt(d, 0n, b, hl, seg, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<{RX}> & D.Digest)}}')
        w(f'def xph1_{p}(d, b, hl, seg, v, s, n, h, ws, dl):')
        w('  match d:')
        w('    case 0n: {==}')
        w('    case 1n+q: {==}')
        # the element read
        w(f'def xget_{p}(+dw: Nat, +t: F.array__Tree<{RX}>, +s: Nat, +hd: {{Nat.is_lt(dw, 32n) == True{{}} : Bool}},')
        w(f'    +pf: {{F.array__perfect({RX}, dw, t) == True{{}} : Bool}}, +hs: {{Nat.is_lt(s, F.spec_common__pow2(dw)) == True{{}} : Bool}})')
        w(f'    -> {{Array.get({RX}, F.array__thaw({RX}, t), U32.from_nat(s)) == (F.array__thaw({RX}, t), xat_{p}(F.array__slots({RX}, t), s)) : Array<{RX}> & {RX}}}:')
        w(f'  +e1 = F.u32__to_nat_from_nat(s, dw, F.nat__lt_le(dw, 32n, hd), hs)')
        w(f'  +hlen = XS.lt_len({RX}, dw, t, s, pf, hs)')
        w(f'  F.array__get({RX}, dw, t, U32.from_nat(s), xat_{p}(F.array__slots({RX}, t), s), hd, MR.hi_at(dw, s, hd, hs),')
        w(f'    XS.at_nth({RX}, F.array__slots({RX}, t), s, U32.to_nat(U32.from_nat(s)), xat_{p}(F.array__slots({RX}, t), s), e1, nth_{p}(F.array__slots({RX}, t), s, hlen)), pf)')
        # the tree
        Ts = f'F.array__thaw({RX}, t)'
        XL = f'xl_{p}(n, F.array__slots({RX}, t), 0n, hl)'
        TY = f'B.Buf & (Array<{RX}> & D.Digest)'
        w(f'law xmt_{p}:')
        for a, ty in (('d', 'Nat'), ('b', 'Bool'), ('hl', 'Nat'), ('seg', 'U32'), ('dw', 'Nat')):
            w(f'  for +{a}: {ty}')
        w(f'  for +t: F.array__Tree<{RX}>')
        w('  for +s: Nat')
        w('  for +n: Nat')
        w('  for -h: B.Buf')
        w('  for +junk: D.Digest')
        w('  for +e: {Nat.is_lt(s, n) == b : Bool}')
        w('  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}')
        w(f'  for +pf: {{F.array__perfect({RX}, dw, t) == True{{}} : Bool}}')
        w('  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}')
        w(f'  {{T.{p}_mt(d, 0n, b, hl, seg, O.pow2n(d), s, n, (h, ({Ts}, junk))) == (h, ({Ts}, MD.rtree(d, b, hl, {XL}, s))) : {TY}}}')
        w(f'def xmt_{p}(d, b, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn):')
        w('  match d:')
        w('    case 0n:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        xs = f'xat_{p}(F.array__slots({RX}, t), s)'
        w(f'          %Equal.sym(Array<{RX}> & {RX}, Array.get({RX}, {Ts}, U32.from_nat(s)), ({Ts}, {xs}), xget_{p}(dw, t, s, hd, pf, F.nat__lt_le_trans(s, n, F.spec_common__pow2(dw), e, hn))) :')
        w(f'            {{T.{p}_rl(hl, seg, h, _) == (h, ({Ts}, MD.rtree(0n, True{{}}, hl, {XL}, s))) : {TY}}}')
        w(f'          %Equal.sym(B.Buf & D.Digest, T.{X.p}_root(hl, h, {xs}, (seg + 64 : U32)), (h, RN.d_{X.p}(hl, {xs})), RN.st_{X.p}(hl, h, {xs}, (seg + 64 : U32))) :')
        w(f'            {{T.{p}_rl_d({Ts}, _) == (h, ({Ts}, MD.rtree(0n, True{{}}, hl, {XL}, s))) : {TY}}}')
        w(f'          %Equal.sym(D.Digest, MD.dhead(MD.ddrop(s, {XL})), RN.d_{X.p}(hl, xat_{p}(F.array__slots({RX}, t), Nat.add(s, 0n))), xat_at_{p}(s, n, F.array__slots({RX}, t), 0n, hl, e)) :')
        w(f'            {{(h, ({Ts}, RN.d_{X.p}(hl, {xs}))) == (h, ({Ts}, _)) : {TY}}}')
        w(f'          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :')
        w(f'            {{(h, ({Ts}, RN.d_{X.p}(hl, {xs}))) == (h, ({Ts}, RN.d_{X.p}(hl, xat_{p}(F.array__slots({RX}, t), _)))) : {TY}}}')
        w('          {==}')
        w('    case 1n+ +q:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        Pq = 'O.pow2n(q)'
        half = f'Nat.div(Nat.double({Pq}), 2n)'
        node = lambda r: f'D.node(hl, MD.rtree(q, True{{}}, hl, {XL}, s), MD.rtree(q, Nat.is_lt(Nat.add(s, {Pq}), {r}), hl, {XL}, Nat.add(s, {Pq})))'
        w(f'          %Equal.sym(Nat, MD.dlen({XL}), n, xlen_{p}(n, F.array__slots({RX}, t), 0n, hl)) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, {half}), n), hl, seg, {half}, Nat.add(s, {half}), n, T.{p}_mt(q, 0n, True{{}}, hl, seg, {half}, s, n, (h, ({Ts}, junk)))) == (h, ({Ts}, {node("_")})) : {TY}}}')
        w(f'          %Equal.sym(Nat, {half}, {Pq}, MR.div_double({Pq})) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, _), n), hl, seg, _, Nat.add(s, _), n, T.{p}_mt(q, 0n, True{{}}, hl, seg, _, s, n, (h, ({Ts}, junk)))) == (h, ({Ts}, {node("n")})) : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(q, 0n, True{{}}, hl, seg, {Pq}, s, n, (h, ({Ts}, junk))), (h, ({Ts}, MD.rtree(q, True{{}}, hl, {XL}, s))), xmt_{p}(q, True{{}}, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn)) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, _) == (h, ({Ts}, {node("n")})) : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, (h, ({Ts}, MD.rtree(q, True{{}}, hl, {XL}, s)))),')
        w(f'              T.{p}_mj(hl, MD.rtree(q, True{{}}, hl, {XL}, s), T.{p}_mt(q, 0n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, (h, ({Ts}, D.zero())))),')
        w(f'              xph1_{p}(q, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, h, {Ts}, MD.rtree(q, True{{}}, hl, {XL}, s))) :')
        w(f'            {{_ == (h, ({Ts}, {node("n")})) : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(q, 0n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, (h, ({Ts}, D.zero()))), (h, ({Ts}, MD.rtree(q, Nat.is_lt(Nat.add(s, {Pq}), n), hl, {XL}, Nat.add(s, {Pq})))),')
        w(f'              xmt_{p}(q, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, dw, t, Nat.add(s, {Pq}), n, h, D.zero(), {{==}}, hd, pf, hn)) :')
        w(f'            {{T.{p}_mj(hl, MD.rtree(q, True{{}}, hl, {XL}, s), _) == (h, ({Ts}, {node("n")})) : {TY}}}')
        w('          {==}')
        return Ts, XL, TY, erp, ER

    def xlist_laws(self, fs):
        """Laws of a list of Data-kind containers (its generated tree `_mt`)."""
        if fs.p in self.done:
            return
        p = fs.p
        X = fs.pelem
        RX = RA.qual(X.rep)
        EX = RA.spec_schema(X)
        D_ = self.depth(fs, 'xl')
        Seq = f'T.{p}_Seq'
        L = []
        w = L.append
        W = f'F.array__slots({RX}, t)'
        w(f'# ---- {p}: list of {X.p} (Data elements) ----')
        Ts, XL, TY, erp, ER = self.xcommon(p, X, RX, EX, w)
        w(f'def xmt0_{p}(+d: Nat, +b: Bool, +hl: Nat, +seg: U32, +dw: Nat, +t: F.array__Tree<{RX}>, +n: Nat, -h: B.Buf, +junk: D.Digest,')
        w('    +e: {Nat.is_lt(0n, n) == b : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},')
        w(f'    +pf: {{F.array__perfect({RX}, dw, t) == True{{}} : Bool}}, +hn: {{Nat.is_le(n, F.spec_common__pow2(dw)) == True{{}} : Bool}})')
        w(f'    -> {{T.{p}_mt0(d, b, hl, seg, n, (h, ({Ts}, junk))) == (h, ({Ts}, MD.rtree(d, b, hl, {XL}, 0n))) : {TY}}}:')
        w('  match d:')
        w(f'    case 0n: xmt_{p}(0n, b, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn)')
        w('    case 1n+ +q:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        w(f'          %MR.div_double(O.pow2n(q)) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(0n, _), n), hl, seg, _, Nat.add(0n, _), n, T.{p}_mt(q, 0n, True{{}}, hl, seg, _, 0n, n, (h, ({Ts}, junk)))) == (h, ({Ts}, MD.rtree(1n+q, True{{}}, hl, {XL}, 0n))) : {TY}}}')
        w(f'          xmt_{p}(1n+q, True{{}}, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn)')
        # the object
        w(f'def xlen_o_{p}(o: {Seq}) -> U32:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: n')
        w(f'def xv_{p}(o: {Seq}) -> S.Value:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: S.Sequence{{xi_{p}(U32.to_nat(n), F.array__slots({RX}, F.array__freeze({RX}, arr)), 0n)}}')
        w(f'def xd_{p}(+hl: Nat, o: {Seq}) -> D.Digest:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(n)), hl, xl_{p}(U32.to_nat(n), F.array__slots({RX}, F.array__freeze({RX}, arr)), 0n, hl), 0n), n)')
        w(f'def rep_{p}(o: {Seq}, +s: S.Schema) -> Data:')
        w(f'  DK.P2(DK.Ex(F.array__Tree<{RX}>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>')
        w(f'    DK.P2({{o == {Seq}{{F.array__thaw({RX}, t), N}} : {Seq}}},')
        w(f'    DK.P2({{F.array__perfect({RX}, dw, t) == True{{}} : Bool}},')
        w('    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},')
        if erp:
            w('    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},')
            w(f'          ereps_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n)))))))),')
        else:
            w('          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),')
        w(f'    {{Nat.is_le(U32.to_nat(xlen_o_{p}(o)), SH.ListOf_limit(s)) == True{{}} : Bool}})')
        big = D_ >= BIGD
        DD = f'OS.dv_{D_}(dv)' if big else f'{D_}n'
        if big:
            # the depth as the variable record's entry (see OS.DV)
            w(f'def ok_{p}(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_ListOf(s), Lim.minimal(SH.ListOf_limit(s), {DD}))')
            self.okinfo[p] = ('and', [self.vsub(fs, c) for c in ['SH.is_ListOf(s)', f'Lim.minimal(SH.ListOf_limit(s), {DD})']], {}, {1: (p, 's')} if p in LIMIT_LEMMAS else {})
        else:
            w(f'def ok_{p}(+s: S.Schema) -> Bool: Bool.and(SH.is_ListOf(s), Lim.minimal(SH.ListOf_limit(s), {D_}n))')
        Wo = f'{Seq}{{F.array__thaw({RX}, t), N}}'
        XLo = f'xl_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n, hl)'
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {Seq}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, xd_{p}(hl, o))) : B.Buf & ({Seq} & D.Digest)}}:')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        if erp:
            w('  (+hd, w6) = w5')
            w('  (+hn, +er) = w6')
        else:
            w('  (+hd, +hn) = w5')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, xd_{p}(hl, _))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym({TY}, T.{p}_mt0({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, U32.to_nat(N), (h, ({Ts}, D.zero()))), (h, ({Ts}, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, {XLo}, 0n))),')
        w(f'      xmt0_{p}({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, dw, t, U32.to_nat(N), h, D.zero(), {{==}}, hd, pf, hn)) :')
        w(f'    {{T.{p}_rt_fin(hl, N, _) == (h, ({Wo}, xd_{p}(hl, {Wo}))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym(F.array__Tree<{RX}>, F.array__freeze({RX}, {Ts}), t, F.array__freeze_thaw({RX}, t)) :')
        w(f'    {{(h, ({Wo}, O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, {XLo}, 0n), N))) == (h, ({Wo}, O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_{p}(U32.to_nat(N), F.array__slots({RX}, _), 0n, hl), 0n), N))) : B.Buf & ({Seq} & D.Digest)}}')
        w('  {==}')
        # the spec law
        w(f'def xlm_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, +N: U32, +R: D.Digest, +Wl: List<&2, {RX}>)')
        w(f'    -> {{Mix.mix_length_bytes(Some{{D.bytes(R)}}, Len.encoding(32n, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)))) == Some{{D.bytes(O.mix_len(hl, R, N))}} : Maybe<&2, +List<U32>>}}:')
        w(f'  %Equal.sym(Nat, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)), U32.to_nat(N), xcount_{p}(U32.to_nat(N), Wl, 0n)) :')
        w('    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, N))} : Maybe<&2, +List<U32>>}')
        w('  LR.mix_bytes(hl, ehl, R, N)')
        w(f'def xhl_{p}(+N: U32, +Lm: Nat, +Wl: List<&2, {RX}>, +hl: Nat, +hv: {{Nat.is_le(U32.to_nat(N), Lm) == True{{}} : Bool}})')
        w(f'    -> {{Nat.is_le(MD.dlen(xl_{p}(U32.to_nat(N), Wl, 0n, hl)), Lm) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(Nat, MD.dlen(xl_{p}(U32.to_nat(N), Wl, 0n, hl)), U32.to_nat(N), xlen_{p}(U32.to_nat(N), Wl, 0n, hl)) : {{Nat.is_le(_, Lm) == True{{}} : Bool}}')
        w('  hv')
        w(f'def xhv_{p}(-o: {Seq}, +t: F.array__Tree<{RX}>, +N: U32, +Lm: Nat, +eo: {{o == {Wo} : {Seq}}},')
        w(f'    +hv: {{Nat.is_le(U32.to_nat(xlen_o_{p}(o)), Lm) == True{{}} : Bool}}) -> {{Nat.is_le(U32.to_nat(N), Lm) == True{{}} : Bool}}:')
        w(f'  %Equal.cong({Seq}, U32, xlen_o_{p}, o, {Wo}, eo) : {{Nat.is_le(U32.to_nat(_), Lm) == True{{}} : Bool}}')
        w('  hv')
        w(f'def wd_{p}(+hl: Nat, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(xd_{p}(hl, o)):')
        w('  (+wf, +hv) = rep')
        w('  (+t, +w1) = wf')
        w('  (+dw, +w2) = w1')
        w('  (+N, +w3) = w2')
        w('  (+eo, +w4) = w3')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) : OS.DW(xd_{p}(hl, _))')
        w(f'  (xd_{p}(hl, {Wo}), {{==}})')
        Lm = 'SH.ListOf_limit(s)'
        dvp = ', +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}' if big else ''
        dva = ', dv' if big else ''
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s){dvp}, +ok: {{ok_{p}(s{dva}) == True{{}} : Bool}}, +eq: {{SH.ListOf_element(s) == {EX} : S.Schema}})')
        w(f'    -> RR.roots(xv_{p}(o), s, [D.bytes(xd_{p}(hl, o))]):')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        if erp:
            w('  (+hd, w6) = w5')
            w('  (+hn, +er) = w6')
        else:
            w('  (+hd, +hn) = w5')
        w(f'  +k0 = DK.and_l(SH.is_ListOf(s), Lim.minimal({Lm}, {DD}), ok)')
        w(f'  +k1 = DK.and_r(SH.is_ListOf(s), Lim.minimal({Lm}, {DD}), ok)')
        w(f'  +hvN = xhv_{p}(o, t, N, {Lm}, eo, hv)')
        w(f'  %Equal.sym(S.Schema, s, S.ListOf{{SH.ListOf_element(s), {Lm}}}, SH.ListOf_shape(s, k0)) :')
        w(f'    RR.roots(xv_{p}(o), _, [D.bytes(xd_{p}(hl, o))])')
        w(f'  %Equal.sym(S.Schema, SH.ListOf_element(s), {EX}, eq) :')
        w(f'    RR.roots(xv_{p}(o), S.ListOf{{_, {Lm}}}, [D.bytes(xd_{p}(hl, o))])')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    RR.roots(xv_{p}(_), S.ListOf{{{EX}, {Lm}}}, [D.bytes(xd_{p}(hl, _))])')
        w(f'  %Equal.sym(F.array__Tree<{RX}>, F.array__freeze({RX}, {Ts}), t, F.array__freeze_thaw({RX}, t)) :')
        w(f'    RR.roots(S.Sequence{{xi_{p}(U32.to_nat(N), F.array__slots({RX}, _), 0n)}}, S.ListOf{{{EX}, {Lm}}}, [D.bytes(O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_{p}(U32.to_nat(N), F.array__slots({RX}, _), 0n, hl), 0n), N))])')
        w(f'  %xlen_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n, hl) :')
        w(f'    RR.roots(S.Sequence{{xi_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n)}}, S.ListOf{{{EX}, {Lm}}}, [D.bytes(O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, _), hl, {XLo}, 0n), N))])')
        if big:
            # the spec law at the variable depth, moved to the literal-depth digest
            Dv = DD
            R2v = f'MD.rtree({Dv}, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n)'
            R2l = f'MD.rtree({D_}n, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n)'
            e = f'Equal.cong(Nat, D.Digest, y => O.mix_len(hl, MD.rtree(y, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n), N), {Dv}, {D_}n, OS.dveq(OS.dv_{D_}, dv, edv))'
            XI = f'xi_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n)'
            w(f'  OS.dtrans(S.Sequence{{{XI}}}, S.ListOf{{{EX}, {Lm}}}, O.mix_len(hl, {R2l}, N), O.mix_len(hl, {R2v}, N), {e},')
            w(f'  (MD.bytes_list({XLo}), (xroots_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n, hl, ehl{ER}),')
            w(f'    (D.bytes({R2v}), (({Dv}, (k1, RS.at_depth_tree({Lm}, {Dv}, hl, {XLo}, OS.dvl(OS.dv_{D_}, dv, edv, {{==}}), xhl_{p}(N, {Lm}, F.array__slots({RX}, t), hl, hvN), ehl))),')
            w(f'     xlm_{p}(hl, ehl, N, {R2v}, F.array__slots({RX}, t)))))))')
        else:
            R2 = f'MD.rtree({D_}n, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n)'
            w(f'  (MD.bytes_list({XLo}), (xroots_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n, hl, ehl{ER}),')
            w(f'    (D.bytes({R2}), (({D_}n, (k1, RS.at_depth_tree({Lm}, {D_}n, hl, {XLo}, {{==}}, xhl_{p}(N, {Lm}, F.array__slots({RX}, t), hl, hvN), ehl))),')
            w(f'     xlm_{p}(hl, ehl, N, {R2}, F.array__slots({RX}, t))))))')
        w('')
        self.done[p] = True
        self.out.extend(self.vecify(fs, L))

    def plist_x_laws(self, fs):
        """Laws of a progressive list of Data-kind elements (its generated
        progressive tree `_ptr` over the fixed-depth `_mt` subtrees)."""
        if fs.p in self.done:
            return
        p = fs.p
        X = fs.pelem
        RX = RA.qual(X.rep)
        EX = RA.spec_schema(X)
        Seq = f'T.{p}_Seq'
        L = []
        w = L.append
        w(f'# ---- {p}: progressive list of {X.p} (Data elements) ----')
        Ts, XL, TY, rep, _ER = self.xcommon(p, X, RX, EX, w)
        P_ = 'O.pow2n(dep)'
        B2 = f'Nat.is_lt(Nat.add(s, {P_}), n)'
        w(f'law xpt_{p}:')
        for a, ty in (('g', 'Nat'), ('b', 'Bool'), ('hl', 'Nat'), ('seg', 'U32'), ('dep', 'Nat'), ('s', 'Nat'), ('n', 'Nat'), ('dw', 'Nat')):
            w(f'  for +{a}: {ty}')
        w(f'  for +t: F.array__Tree<{RX}>')
        w('  for -h: B.Buf')
        w('  for +junk: D.Digest')
        w('  for +e: {Nat.is_lt(s, n) == b : Bool}')
        w('  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}')
        w(f'  for +pf: {{F.array__perfect({RX}, dw, t) == True{{}} : Bool}}')
        w('  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}')
        w(f'  {{T.{p}_ptr(g, b, hl, seg, dep, s, n, (h, ({Ts}, junk))) == (h, ({Ts}, PR.pr(g, b, hl, dep, s, n, {XL}))) : {TY}}}')
        w(f'def xpt_{p}(g, b, hl, seg, dep, s, n, dw, t, h, junk, e, hd, pf, hn):')
        w('  match g:')
        w('    case 0n: {==}')
        w('    case 1n+ +k:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        PRK = f'PR.pr(k, {B2}, hl, Nat.add(dep, 2n), Nat.add(s, {P_}), n, {XL})'
        RHS = f'(h, ({Ts}, PR.pr(1n+k, True{{}}, hl, dep, s, n, {XL})))'
        w(f'          %Equal.sym({TY}, T.{p}_ptr(k, {B2}, hl, seg, Nat.add(dep, 2n), Nat.add(s, {P_}), n, (h, ({Ts}, junk))), (h, ({Ts}, {PRK})),')
        w(f'              xpt_{p}(k, {B2}, hl, seg, Nat.add(dep, 2n), Nat.add(s, {P_}), n, dw, t, h, junk, {{==}}, hd, pf, hn)) :')
        w(f'            {{T.{p}_prr(hl, seg, dep, s, n, _) == {RHS} : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(dep, 0n, True{{}}, hl, seg, {P_}, s, n, (h, ({Ts}, D.zero()))), (h, ({Ts}, MD.rtree(dep, True{{}}, hl, {XL}, s))),')
        w(f'              xmt_{p}(dep, True{{}}, hl, seg, dw, t, s, n, h, D.zero(), e, hd, pf, hn)) :')
        w(f'            {{T.{p}_mj(hl, {PRK}, _) == {RHS} : {TY}}}')
        w('          {==}')
        # the object
        w(f'def xlen_o_{p}(o: {Seq}) -> U32:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: n')
        w(f'def xv_{p}(o: {Seq}) -> S.Value:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: S.Sequence{{xi_{p}(U32.to_nat(n), F.array__slots({RX}, F.array__freeze({RX}, arr)), 0n)}}')
        nn = 'U32.to_nat(n)'
        w(f'def xd_{p}(+hl: Nat, o: {Seq}) -> D.Digest:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: O.mix_len(hl, PR.pr(1n+{nn}, Nat.is_lt(0n, {nn}), hl, 0n, 0n, {nn}, xl_{p}({nn}, F.array__slots({RX}, F.array__freeze({RX}, arr)), 0n, hl)), n)')
        inner = '{Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool}'
        if rep:
            inner = f'DK.P2({inner}, ereps_{p}(U32.to_nat(N), F.array__slots({RX}, t), 0n))'
        w(f'def rep_{p}(o: {Seq}, +s: S.Schema) -> Data:')
        w(f'  DK.Ex(F.array__Tree<{RX}>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>')
        w(f'    DK.P2({{o == {Seq}{{F.array__thaw({RX}, t), N}} : {Seq}}},')
        w(f'    DK.P2({{F.array__perfect({RX}, dw, t) == True{{}} : Bool}},')
        w('    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},')
        w(f'          {inner}))))))')
        w(f'def ok_{p}(+s: S.Schema) -> Bool: SH.is_ProgressiveList(s)')
        Wo = f'{Seq}{{F.array__thaw({RX}, t), N}}'
        nN = 'U32.to_nat(N)'
        XLo = f'xl_{p}({nN}, F.array__slots({RX}, t), 0n, hl)'
        PRo = f'PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, {XLo})'

        def dest(ind='  '):
            w(f'{ind}(+t, w1) = rep')
            w(f'{ind}(+dw, w2) = w1')
            w(f'{ind}(+N, w3) = w2')
            w(f'{ind}(+eo, w4) = w3')
            w(f'{ind}(+pf, w5) = w4')
            if rep:
                w(f'{ind}(+hd, w6) = w5')
                w(f'{ind}(+hn, +hr) = w6')
            else:
                w(f'{ind}(+hd, +hn) = w5')
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {Seq}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, xd_{p}(hl, o))) : B.Buf & ({Seq} & D.Digest)}}:')
        dest()
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, xd_{p}(hl, _))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym({TY}, T.{p}_ptr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, seg, 0n, 0n, {nN}, (h, ({Ts}, D.zero()))), (h, ({Ts}, {PRo})),')
        w(f'      xpt_{p}(1n+{nN}, Nat.is_lt(0n, {nN}), hl, seg, 0n, 0n, {nN}, dw, t, h, D.zero(), {{==}}, hd, pf, hn)) :')
        w(f'    {{T.{p}_rt_fin(hl, N, _) == (h, ({Wo}, xd_{p}(hl, {Wo}))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym(F.array__Tree<{RX}>, F.array__freeze({RX}, {Ts}), t, F.array__freeze_thaw({RX}, t)) :')
        w(f'    {{(h, ({Wo}, O.mix_len(hl, {PRo}, N))) == (h, ({Wo}, O.mix_len(hl, PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, xl_{p}({nN}, F.array__slots({RX}, _), 0n, hl)), N))) : B.Buf & ({Seq} & D.Digest)}}')
        w('  {==}')
        w(f'def xlm_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, +N: U32, +R: D.Digest, +Wl: List<&2, {RX}>)')
        w(f'    -> {{Mix.mix_length_bytes(Some{{D.bytes(R)}}, Len.encoding(32n, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)))) == Some{{D.bytes(O.mix_len(hl, R, N))}} : Maybe<&2, +List<U32>>}}:')
        w(f'  %Equal.sym(Nat, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)), U32.to_nat(N), xcount_{p}(U32.to_nat(N), Wl, 0n)) :')
        w('    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, N))} : Maybe<&2, +List<U32>>}')
        w('  LR.mix_bytes(hl, ehl, R, N)')
        w(f'def wd_{p}(+hl: Nat, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(xd_{p}(hl, o)):')
        w('  (+t, +w1) = rep')
        w('  (+dw, +w2) = w1')
        w('  (+N, +w3) = w2')
        w('  (+eo, +w4) = w3')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) : OS.DW(xd_{p}(hl, _))')
        w(f'  (xd_{p}(hl, {Wo}), {{==}})')
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s), +ok: {{ok_{p}(s) == True{{}} : Bool}}, +eq: {{SH.ProgressiveList_element(s) == {EX} : S.Schema}})')
        w(f'    -> RR.roots(xv_{p}(o), s, [D.bytes(xd_{p}(hl, o))]):')
        dest()
        w(f'  %Equal.sym(S.Schema, s, S.ProgressiveList{{SH.ProgressiveList_element(s)}}, SH.ProgressiveList_shape(s, ok)) :')
        w(f'    RR.roots(xv_{p}(o), _, [D.bytes(xd_{p}(hl, o))])')
        w(f'  %Equal.sym(S.Schema, SH.ProgressiveList_element(s), {EX}, eq) :')
        w(f'    RR.roots(xv_{p}(o), S.ProgressiveList{{_}}, [D.bytes(xd_{p}(hl, o))])')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    RR.roots(xv_{p}(_), S.ProgressiveList{{{EX}}}, [D.bytes(xd_{p}(hl, _))])')
        w(f'  %Equal.sym(F.array__Tree<{RX}>, F.array__freeze({RX}, {Ts}), t, F.array__freeze_thaw({RX}, t)) :')
        w(f'    RR.roots(S.Sequence{{xi_{p}({nN}, F.array__slots({RX}, _), 0n)}}, S.ProgressiveList{{{EX}}}, [D.bytes(O.mix_len(hl, PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, xl_{p}({nN}, F.array__slots({RX}, _), 0n, hl)), N))])')
        xr = f'xroots_{p}({nN}, F.array__slots({RX}, t), 0n, hl, ehl' + (', hr)' if rep else ')')
        w(f'  (MD.bytes_list({XLo}), ({xr},')
        w(f'    (D.bytes({PRo}), (PCN.pmerk(hl, ehl, {nN}, {XLo}, dw, xlen_{p}({nN}, F.array__slots({RX}, t), 0n, hl), hd, hn),')
        w(f'     xlm_{p}(hl, ehl, N, {PRo}, F.array__slots({RX}, t))))))')
        w('')
        self.done[p] = True
        self.out.extend(L)

    # ---- lists of Type-kind elements ---------------------------------------------
    def tcommon(self, p, BE, th, MX, BR, AMt, w):
        """The mirror-array, element, digest-list, view and tree laws shared by
        the lists of Type-kind elements (bounded `tl`, progressive `ptl`)."""
        # the Base Array laws over the mirror image (codegen/templates/amap_template.bend.in)
        tpl = (ROOT / 'codegen/templates/amap_template.bend.in').read_text()
        tpl = tpl.replace('@P', p).replace('@TH', th)
        tpl = re.sub(r'\bA\b', MX, tpl)
        tpl = re.sub(r'\bB\b', BR, tpl)
        for line in tpl.rstrip('\n').split('\n'):
            w(line)
        w(f'def xat_{p}(W: List<&2, {MX}>, +i: Nat) -> {MX}:')
        w('  match W:')
        w('    case Nil{}: MNone{}')
        w('    case Con{+x, t}:')
        w('      match i:')
        w('        case 0n: x')
        w(f'        case 1n+j: xat_{p}(t, j)')
        w(f'law nth_{p}:')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w(f'  for +hi: {{Nat.is_lt(i, F.spec_common__length({MX}, W)) == True{{}} : Bool}}')
        w(f'  {{F.spec_common__nth({MX}, W, i) == Some{{xat_{p}(W, i)}} : Maybe<&2, {MX}>}}')
        w(f'def nth_{p}(W, i, hi):')
        w('  match W:')
        w(f'    case Nil{{}}: Empty.absurd({{F.spec_common__nth({MX}, Nil{{}}, i) == Some{{xat_{p}(Nil{{}}, i)}} : Maybe<&2, {MX}>}}, MD.false_true(Equal.trans(Bool, False{{}}, Nat.is_lt(i, 0n), True{{}}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{{}}, F.nat__not_lt_zero(i)), hi)))')
        w('    case Con{+x, +t}:')
        w('      match i:')
        w('        case 0n: {==}')
        w(f'        case 1n+ +j: nth_{p}(t, j, hi)')
        dE = lambda x: f'd_{BE.p}(hl, {th}({x}))'
        w(f'def xl_{p}(k: Nat, +W: List<&2, {MX}>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:')
        w('  match k:')
        w('    case 0n: []')
        w(f'    case 1n+q: {dE(f"xat_{p}(W, i)")} <> xl_{p}(q, W, 1n+i, hl)')
        w(f'law xlen_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w('  for +hl: Nat')
        w(f'  {{MD.dlen(xl_{p}(k, W, i, hl)) == k : Nat}}')
        w(f'def xlen_{p}(k, W, i, hl):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w(f'      %xlen_{p}(q, W, 1n+i, hl) : {{1n+MD.dlen(xl_{p}(q, W, 1n+i, hl)) == 1n+_ : Nat}}')
        w('      {==}')
        w(f'law xat_at_{p}:')
        w('  for +s: Nat')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w('  for +hl: Nat')
        w('  for +e: {Nat.is_lt(s, k) == True{} : Bool}')
        w(f'  {{MD.dhead(MD.ddrop(s, xl_{p}(k, W, i, hl))) == {dE(f"xat_{p}(W, Nat.add(s, i))")} : D.Digest}}')
        w(f'def xat_at_{p}(s, k, W, i, hl, e):')
        w('  match s:')
        w('    case 0n:')
        w('      match k:')
        w(f'        case 0n: Empty.absurd({{MD.dhead(MD.ddrop(0n, xl_{p}(0n, W, i, hl))) == {dE(f"xat_{p}(W, Nat.add(0n, i))")} : D.Digest}}, MD.false_true(e))')
        w('        case 1n+q: {==}')
        w('    case 1n+ +p1:')
        w('      match k:')
        w(f'        case 0n: Empty.absurd({{MD.dhead(MD.ddrop(1n+p1, xl_{p}(0n, W, i, hl))) == {dE(f"xat_{p}(W, Nat.add(1n+p1, i))")} : D.Digest}}, MD.false_true(e))')
        w('        case 1n+ +q:')
        w(f'          %MR.add_succ(p1, i) : {{MD.dhead(MD.ddrop(p1, xl_{p}(q, W, 1n+i, hl))) == {dE(f"xat_{p}(W, _)")} : D.Digest}}')
        w(f'          xat_at_{p}(p1, q, W, 1n+i, hl, e)')
        # element invariants
        w(f'def ereps_{p}(k: Nat, +W: List<&2, {MX}>, +i: Nat, +sE: S.Schema) -> Data:')
        w('  match k:')
        w('    case 0n: {True{} == True{} : Bool}')
        w(f'    case 1n+q: DK.P2(rep_{BE.p}({th}(xat_{p}(W, i)), sE), ereps_{p}(q, W, 1n+i, sE))')
        w(f'def erep_at_{p}(+s: Nat, +k: Nat, +W: List<&2, {MX}>, +i: Nat, +sE: S.Schema, +er: ereps_{p}(k, W, i, sE), +e: {{Nat.is_lt(s, k) == True{{}} : Bool}})')
        w(f'    -> rep_{BE.p}({th}(xat_{p}(W, Nat.add(s, i))), sE):')
        w('  match s:')
        w('    case 0n:')
        w('      match k:')
        w(f'        case 0n: Empty.absurd(rep_{BE.p}({th}(xat_{p}(W, Nat.add(0n, i))), sE), MD.false_true(e))')
        w('        case 1n+q:')
        w('          (+r0, +rs) = er')
        w('          r0')
        w('    case 1n+ +p1:')
        w('      match k:')
        w(f'        case 0n: Empty.absurd(rep_{BE.p}({th}(xat_{p}(W, Nat.add(1n+p1, i))), sE), MD.false_true(e))')
        w('        case 1n+ +q:')
        w('          (+r0, +rs) = er')
        w(f'          %MR.add_succ(p1, i) : rep_{BE.p}({th}(xat_{p}(W, _)), sE)')
        w(f'          erep_at_{p}(p1, q, W, 1n+i, sE, rs, e)')
        # values
        w(f'def xi_{p}(k: Nat, +W: List<&2, {MX}>, +i: Nat) -> S.Value:')
        w('  match k:')
        w('    case 0n: S.EmptyItems{}')
        w(f'    case 1n+q: S.Items{{v_{BE.p}({th}(xat_{p}(W, i))), xi_{p}(q, W, 1n+i)}}')
        w(f'law xroots_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w('  for +hl: Nat')
        w('  for +ehl: {hl == 64n : Nat}')
        w('  for -h: B.Buf')
        w('  for +sE: S.Schema')
        w(f'  for +er: ereps_{p}(k, W, i, sE)')
        w('  for +dv: OS.DV')
        w('  for +edv: {dv == OS.DV0() : OS.DV}')
        w(f'  for +ok: {{ok_{BE.p}(sE, dv) == True{{}} : Bool}}')
        w(f'  for +eq: eqs_{BE.p}(sE)')
        w(f'  RR.roots(xi_{p}(k, W, i), S.Repeat{{sE}}, MD.bytes_list(xl_{p}(k, W, i, hl)))')
        w(f'def xroots_{p}(k, W, i, hl, ehl, h, sE, er, dv, edv, ok, eq):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w('      (+r0, +rs) = er')
        x0 = f'xat_{p}(W, i)'
        w(f'      ([D.bytes({dE(x0)})], (MD.bytes_list(xl_{p}(q, W, 1n+i, hl)), (rs_{BE.p}(hl, ehl, h, {th}({x0}), sE, r0, dv, edv, ok, eq), (xroots_{p}(q, W, 1n+i, hl, ehl, h, sE, rs, dv, edv, ok, eq), {{==}}))))')
        w(f'law xcount_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w(f'  {{Codec.count(xi_{p}(k, W, i)) == k : Nat}}')
        w(f'def xcount_{p}(k, W, i):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w(f'      %Equal.sym(Nat, Codec.count(xi_{p}(q, W, 1n+i)), q, xcount_{p}(q, W, 1n+i)) : {{1n+_ == 1n+q : Nat}}')
        w('      {==}')
        TY = f'B.Buf & (Array<{BR}> & D.Digest)'
        w(f'law xph1_{p}:')
        w('  for +d: Nat')
        w('  for +b: Bool')
        w('  for +hl: Nat')
        w('  for +seg: U32')
        w('  for +v: Nat')
        w('  for +s: Nat')
        w('  for +n: Nat')
        w('  for -h: B.Buf')
        w(f'  for -ws: Array<{BR}>')
        w('  for +dl: D.Digest')
        w(f'  {{T.{p}_mt(d, 1n, b, hl, seg, v, s, n, (h, (ws, dl))) == T.{p}_mj(hl, dl, T.{p}_mt(d, 0n, b, hl, seg, v, s, n, (h, (ws, D.zero())))) : {TY}}}')
        w(f'def xph1_{p}(d, b, hl, seg, v, s, n, h, ws, dl):')
        w('  match d:')
        w('    case 0n: {==}')
        w('    case 1n+q: {==}')
        Ts = AMt('t')
        XL = f'xl_{p}(n, F.array__slots({MX}, t), 0n, hl)'
        W_ = f'F.array__slots({MX}, t)'
        w(f'law xmt_{p}:')
        for a, ty in (('d', 'Nat'), ('b', 'Bool'), ('hl', 'Nat'), ('seg', 'U32'), ('dw', 'Nat')):
            w(f'  for +{a}: {ty}')
        w(f'  for +t: F.array__Tree<{MX}>')
        w('  for +s: Nat')
        w('  for +n: Nat')
        w('  for -h: B.Buf')
        w('  for +junk: D.Digest')
        w('  for +e: {Nat.is_lt(s, n) == b : Bool}')
        w('  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}')
        w(f'  for +pf: {{F.array__perfect({MX}, dw, t) == True{{}} : Bool}}')
        w('  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}')
        w('  for +sE: S.Schema')
        w(f'  for +er: ereps_{p}(n, {W_}, 0n, sE)')
        w(f'  {{T.{p}_mt(d, 0n, b, hl, seg, O.pow2n(d), s, n, (h, ({Ts}, junk))) == (h, ({Ts}, MD.rtree(d, b, hl, {XL}, s))) : {TY}}}')
        w(f'def xmt_{p}(d, b, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn, sE, er):')
        w('  match d:')
        w('    case 0n:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        xs = f'xat_{p}({W_}, s)'
        w(f'          +hs = F.nat__lt_le_trans(s, n, F.spec_common__pow2(dw), e, hn)')
        w(f'          +e1 = F.u32__to_nat_from_nat(s, dw, F.nat__lt_le(dw, 32n, hd), hs)')
        w(f'          +hx = XS.at_nth({MX}, {W_}, s, U32.to_nat(U32.from_nat(s)), {xs}, e1, nth_{p}({W_}, s, XS.lt_len({MX}, dw, t, s, pf, hs)))')
        w(f'          +rx = F.logic__subst(Nat, j => rep_{BE.p}({th}(xat_{p}({W_}, j)), sE), Nat.add(s, 0n), s, MR.add_zero(s), erep_at_{p}(s, n, {W_}, 0n, sE, er, e))')
        Tu = AMt(f'F.array__upd({MX}, dw, t, U32.to_nat(U32.from_nat(s)), MNone{{}})')
        w(f'          %Equal.sym(Array<{BR}> & {BR}, Array.swap({BR}, {Ts}, U32.from_nat(s), O.BNone{{}}), ({Tu}, {th}({xs})),')
        w(f'              amswap_{p}(dw, t, U32.from_nat(s), MNone{{}}, {xs}, hd, MR.hi_at(dw, s, hd, hs), hx, pf)) :')
        w(f'            {{T.{p}_rl(hl, U32.from_nat(s), seg, h, _) == (h, ({Ts}, MD.rtree(0n, True{{}}, hl, {XL}, s))) : {TY}}}')
        w(f'          %Equal.sym(B.Buf & ({BR} & D.Digest), T.{BE.p}_root(hl, h, {th}({xs}), (seg + 64 : U32)), (h, ({th}({xs}), {dE(xs)})), st_{BE.p}(hl, h, {th}({xs}), (seg + 64 : U32), sE, rx)) :')
        w(f'            {{T.{p}_rl_n(U32.from_nat(s), {Tu}, _) == (h, ({Ts}, MD.rtree(0n, True{{}}, hl, {XL}, s))) : {TY}}}')
        w(f'          %Equal.sym(Array<{BR}>, Array.set({BR}, {Tu}, U32.from_nat(s), {th}({xs})), {Ts}, amswap_back_{p}(dw, t, U32.from_nat(s), MNone{{}}, {xs}, hd, MR.hi_at(dw, s, hd, hs), hx, pf)) :')
        w(f'            {{(h, (_, {dE(xs)})) == (h, ({Ts}, MD.rtree(0n, True{{}}, hl, {XL}, s))) : {TY}}}')
        w(f'          %Equal.sym(D.Digest, MD.dhead(MD.ddrop(s, {XL})), {dE(f"xat_{p}({W_}, Nat.add(s, 0n))")}, xat_at_{p}(s, n, {W_}, 0n, hl, e)) :')
        w(f'            {{(h, ({Ts}, {dE(xs)})) == (h, ({Ts}, _)) : {TY}}}')
        w(f'          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :')
        w(f'            {{(h, ({Ts}, {dE(xs)})) == (h, ({Ts}, {dE(f"xat_{p}({W_}, _)")})) : {TY}}}')
        w('          {==}')
        w('    case 1n+ +q:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        Pq = 'O.pow2n(q)'
        half = f'Nat.div(Nat.double({Pq}), 2n)'
        node = lambda r: f'D.node(hl, MD.rtree(q, True{{}}, hl, {XL}, s), MD.rtree(q, Nat.is_lt(Nat.add(s, {Pq}), {r}), hl, {XL}, Nat.add(s, {Pq})))'
        w(f'          %Equal.sym(Nat, MD.dlen({XL}), n, xlen_{p}(n, {W_}, 0n, hl)) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, {half}), n), hl, seg, {half}, Nat.add(s, {half}), n, T.{p}_mt(q, 0n, True{{}}, hl, seg, {half}, s, n, (h, ({Ts}, junk)))) == (h, ({Ts}, {node("_")})) : {TY}}}')
        w(f'          %Equal.sym(Nat, {half}, {Pq}, MR.div_double({Pq})) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, _), n), hl, seg, _, Nat.add(s, _), n, T.{p}_mt(q, 0n, True{{}}, hl, seg, _, s, n, (h, ({Ts}, junk)))) == (h, ({Ts}, {node("n")})) : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(q, 0n, True{{}}, hl, seg, {Pq}, s, n, (h, ({Ts}, junk))), (h, ({Ts}, MD.rtree(q, True{{}}, hl, {XL}, s))), xmt_{p}(q, True{{}}, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn, sE, er)) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, _) == (h, ({Ts}, {node("n")})) : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, (h, ({Ts}, MD.rtree(q, True{{}}, hl, {XL}, s)))),')
        w(f'              T.{p}_mj(hl, MD.rtree(q, True{{}}, hl, {XL}, s), T.{p}_mt(q, 0n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, (h, ({Ts}, D.zero())))),')
        w(f'              xph1_{p}(q, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, h, {Ts}, MD.rtree(q, True{{}}, hl, {XL}, s))) :')
        w(f'            {{_ == (h, ({Ts}, {node("n")})) : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(q, 0n, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, {Pq}, Nat.add(s, {Pq}), n, (h, ({Ts}, D.zero()))), (h, ({Ts}, MD.rtree(q, Nat.is_lt(Nat.add(s, {Pq}), n), hl, {XL}, Nat.add(s, {Pq})))),')
        w(f'              xmt_{p}(q, Nat.is_lt(Nat.add(s, {Pq}), n), hl, seg, dw, t, Nat.add(s, {Pq}), n, h, D.zero(), {{==}}, hd, pf, hn, sE, er)) :')
        w(f'            {{T.{p}_mj(hl, MD.rtree(q, True{{}}, hl, {XL}, s), _) == (h, ({Ts}, {node("n")})) : {TY}}}')
        w('          {==}')
        return Ts, XL, TY, W_, dE

    def tfz(self, p, BE, th, MX, BR, AMt, Ts, w):
        """The freeze of a list's array into its mirror tree (tfz, tfzam)."""
        # the object, read through its mirror
        w(f'def tfz_{p}(a: Array<{BR}>) -> F.array__Tree<{MX}>:')
        w('  match a:')
        w(f'    case ALeaf{{x}}: F.TLeaf{{fz_{BE.p}(x)}}')
        w(f'    case ANode{{l, r}}: F.TNode{{tfz_{p}(l), tfz_{p}(r)}}')
        w(f'law tfzam_{p}:')
        w(f'  for +t: F.array__Tree<{MX}>')
        w(f'  {{tfz_{p}({Ts}) == t : F.array__Tree<{MX}>}}')
        w(f'def tfzam_{p}(t):')
        w('  match t:')
        w('    case F.TLeaf{+x}:')
        w(f'      %Equal.sym({MX}, fz_{BE.p}({th}(x)), x, fzth_{BE.p}(x)) : {{F.TLeaf{{_}} == F.TLeaf{{x}} : F.array__Tree<{MX}>}}')
        w('      {==}')
        w('    case F.TNode{+l, +r}:')
        w(f'      %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({AMt("l")}), l, tfzam_{p}(l)) : {{F.TNode{{_, tfz_{p}({AMt("r")})}} == F.TNode{{l, r}} : F.array__Tree<{MX}>}}')
        w(f'      %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({AMt("r")}), r, tfzam_{p}(r)) : {{F.TNode{{l, _}} == F.TNode{{l, r}} : F.array__Tree<{MX}>}}')
        w('      {==}')

    def tlist_laws(self, fs):
        """Laws of a list whose elements are boxes of Type-kind containers: the
        array is the image AM.am(th, t) of a Data mirror tree t (see WMr/MB)."""
        if fs.p in self.done:
            return
        p = fs.p
        BE = fs.elem                      # the element box shape
        if BE.kind != 'box' or BE.inner.data:
            raise Skip(f'{p}: list of {BE.p} (element kind not covered)')
        E = BE.inner
        if E.kind == 'container':
            self.shape(E)
            self.box(BE, 'boxT')
            self.mirror(E)
            self.mirror_box(BE)
            MI = f'M_{E.p}'
        elif E.kind == 'bytelist':
            self.box_words(BE)
            MI = 'WMr'
        else:
            raise Skip(f'{p}: list of {BE.p} (element kind {E.kind} not covered)')
        RE = RA.qual(E.rep)
        BR = f'O.Boxed<{RE}>'
        MX = f'MB<{MI}>'
        D_ = self.depth(fs, 'tl')
        big = D_ >= BIGD
        DD = f'OS.dv_{D_}(dv)' if big else f'{D_}n'
        Seq = f'T.{p}_Seq'
        th = f'th_{BE.p}'
        AMt = lambda t: f'am_{p}({t})'
        L = []
        w = L.append
        w(f'# ---- {p}: list of {BE.p} (Type-kind elements, through mirrors) ----')
        Ts, XL, TY, W_, dE = self.tcommon(p, BE, th, MX, BR, AMt, w)
        w(f'def xmt0_{p}(+d: Nat, +b: Bool, +hl: Nat, +seg: U32, +dw: Nat, +t: F.array__Tree<{MX}>, +n: Nat, -h: B.Buf, +junk: D.Digest,')
        w('    +e: {Nat.is_lt(0n, n) == b : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},')
        w(f'    +pf: {{F.array__perfect({MX}, dw, t) == True{{}} : Bool}}, +hn: {{Nat.is_le(n, F.spec_common__pow2(dw)) == True{{}} : Bool}},')
        w(f'    +sE: S.Schema, +er: ereps_{p}(n, {W_}, 0n, sE))')
        w(f'    -> {{T.{p}_mt0(d, b, hl, seg, n, (h, ({Ts}, junk))) == (h, ({Ts}, MD.rtree(d, b, hl, {XL}, 0n))) : {TY}}}:')
        w('  match d:')
        w(f'    case 0n: xmt_{p}(0n, b, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn, sE, er)')
        w('    case 1n+ +q:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        w(f'          %MR.div_double(O.pow2n(q)) :')
        w(f'            {{T.{p}_mt(q, 1n, Nat.is_lt(Nat.add(0n, _), n), hl, seg, _, Nat.add(0n, _), n, T.{p}_mt(q, 0n, True{{}}, hl, seg, _, 0n, n, (h, ({Ts}, junk)))) == (h, ({Ts}, MD.rtree(1n+q, True{{}}, hl, {XL}, 0n))) : {TY}}}')
        w(f'          xmt_{p}(1n+q, True{{}}, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn, sE, er)')
        self.tfz(p, BE, th, MX, BR, AMt, Ts, w)
        w(f'def xlen_o_{p}(o: {Seq}) -> U32:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: n')
        w(f'def xv_{p}(o: {Seq}) -> S.Value:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: S.Sequence{{xi_{p}(U32.to_nat(n), F.array__slots({MX}, tfz_{p}(arr)), 0n)}}')
        w(f'def xd_{p}(+hl: Nat, o: {Seq}) -> D.Digest:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(n)), hl, xl_{p}(U32.to_nat(n), F.array__slots({MX}, tfz_{p}(arr)), 0n, hl), 0n), n)')
        Wo = f'{Seq}{{{Ts}, N}}'
        w(f'def rep_{p}(o: {Seq}, +s: S.Schema) -> Data:')
        w(f'  DK.P2(DK.Ex(F.array__Tree<{MX}>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>')
        w(f'    DK.P2({{o == {Wo} : {Seq}}},')
        w(f'    DK.P2({{F.array__perfect({MX}, dw, t) == True{{}} : Bool}},')
        w('    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},')
        w('    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},')
        w(f'          ereps_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n, SH.ListOf_element(s))))))))),')
        w(f'    {{Nat.is_le(U32.to_nat(xlen_o_{p}(o)), SH.ListOf_limit(s)) == True{{}} : Bool}})')
        w(f'def ok_{p}(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_ListOf(s), Bool.and(Lim.minimal(SH.ListOf_limit(s), {DD}), ok_{BE.p}(SH.ListOf_element(s), dv)))')
        self.okinfo[p] = ('and', [self.vsub(fs, c) for c in ['SH.is_ListOf(s)', f'Lim.minimal(SH.ListOf_limit(s), {DD})', f'ok_{BE.p}(SH.ListOf_element(s), dv)']],
                          {2: (BE.p, self.vsub(fs, 'SH.ListOf_element(s)'))})
        w(f'def eqs_{p}(+s: S.Schema) -> Data: eqs_{BE.p}(SH.ListOf_element(s))')
        XLo = f'xl_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n, hl)'
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {Seq}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, xd_{p}(hl, o))) : B.Buf & ({Seq} & D.Digest)}}:')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        w('  (+hd, w6) = w5')
        w('  (+hn, +er) = w6')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, xd_{p}(hl, _))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym({TY}, T.{p}_mt0({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, U32.to_nat(N), (h, ({Ts}, D.zero()))), (h, ({Ts}, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, {XLo}, 0n))),')
        w(f'      xmt0_{p}({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, dw, t, U32.to_nat(N), h, D.zero(), {{==}}, hd, pf, hn, SH.ListOf_element(s), er)) :')
        w(f'    {{T.{p}_rt_fin(hl, N, _) == (h, ({Wo}, xd_{p}(hl, {Wo}))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({Ts}), t, tfzam_{p}(t)) :')
        w(f'    {{(h, ({Wo}, O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, {XLo}, 0n), N))) == (h, ({Wo}, O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_{p}(U32.to_nat(N), F.array__slots({MX}, _), 0n, hl), 0n), N))) : B.Buf & ({Seq} & D.Digest)}}')
        w('  {==}')
        # the spec law
        w(f'def xlm_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, +N: U32, +R: D.Digest, +Wl: List<&2, {MX}>)')
        w(f'    -> {{Mix.mix_length_bytes(Some{{D.bytes(R)}}, Len.encoding(32n, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)))) == Some{{D.bytes(O.mix_len(hl, R, N))}} : Maybe<&2, +List<U32>>}}:')
        w(f'  %Equal.sym(Nat, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)), U32.to_nat(N), xcount_{p}(U32.to_nat(N), Wl, 0n)) :')
        w('    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, N))} : Maybe<&2, +List<U32>>}')
        w('  LR.mix_bytes(hl, ehl, R, N)')
        w(f'def xhl_{p}(+N: U32, +Lm: Nat, +Wl: List<&2, {MX}>, +hl: Nat, +hv: {{Nat.is_le(U32.to_nat(N), Lm) == True{{}} : Bool}})')
        w(f'    -> {{Nat.is_le(MD.dlen(xl_{p}(U32.to_nat(N), Wl, 0n, hl)), Lm) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(Nat, MD.dlen(xl_{p}(U32.to_nat(N), Wl, 0n, hl)), U32.to_nat(N), xlen_{p}(U32.to_nat(N), Wl, 0n, hl)) : {{Nat.is_le(_, Lm) == True{{}} : Bool}}')
        w('  hv')
        w(f'def xhv_{p}(-o: {Seq}, +t: F.array__Tree<{MX}>, +N: U32, +Lm: Nat, +eo: {{o == {Wo} : {Seq}}},')
        w(f'    +hv: {{Nat.is_le(U32.to_nat(xlen_o_{p}(o)), Lm) == True{{}} : Bool}}) -> {{Nat.is_le(U32.to_nat(N), Lm) == True{{}} : Bool}}:')
        w(f'  %Equal.cong({Seq}, U32, xlen_o_{p}, o, {Wo}, eo) : {{Nat.is_le(U32.to_nat(_), Lm) == True{{}} : Bool}}')
        w('  hv')
        w(f'def wd_{p}(+hl: Nat, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(xd_{p}(hl, o)):')
        w('  (+wf, +hv) = rep')
        w('  (+t, +w1) = wf')
        w('  (+dw, +w2) = w1')
        w('  (+N, +w3) = w2')
        w('  (+eo, +w4) = w3')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) : OS.DW(xd_{p}(hl, _))')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({Ts}), t, tfzam_{p}(t)) : OS.DW(O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_{p}(U32.to_nat(N), F.array__slots({MX}, _), 0n, hl), 0n), N))')
        w(f'  (O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, {XLo}, 0n), N), {{==}})')
        Lm = 'SH.ListOf_limit(s)'
        sE = 'SH.ListOf_element(s)'
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}, +eq: eqs_{p}(s))')
        w(f'    -> RR.roots(xv_{p}(o), s, [D.bytes(xd_{p}(hl, o))]):')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        w('  (+hd, w6) = w5')
        w('  (+hn, +er) = w6')
        rest = f'Bool.and(Lim.minimal({Lm}, {DD}), ok_{BE.p}({sE}, dv))'
        w(f'  +k0 = DK.and_l(SH.is_ListOf(s), {rest}, ok)')
        w(f'  +k1 = DK.and_r(SH.is_ListOf(s), {rest}, ok)')
        w(f'  +kmin = DK.and_l(Lim.minimal({Lm}, {DD}), ok_{BE.p}({sE}, dv), k1)')
        w(f'  +kel = DK.and_r(Lim.minimal({Lm}, {DD}), ok_{BE.p}({sE}, dv), k1)')
        w(f'  +hvN = xhv_{p}(o, t, N, {Lm}, eo, hv)')
        okc = f'okc_{E.p}({sE}, dv, kel)' if E.kind == 'container' else f'okc_{BE.p}({sE}, dv, kel)'
        bsl = 'bs_cont' if E.kind == 'container' else 'bs_blist'
        w(f'  +ebs = {bsl}({sE}, {okc})')
        w(f'  %Equal.sym(S.Schema, s, S.ListOf{{{sE}, {Lm}}}, SH.ListOf_shape(s, k0)) :')
        w(f'    RR.roots(xv_{p}(o), _, [D.bytes(xd_{p}(hl, o))])')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    RR.roots(xv_{p}(_), S.ListOf{{{sE}, {Lm}}}, [D.bytes(xd_{p}(hl, _))])')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({Ts}), t, tfzam_{p}(t)) :')
        w(f'    RR.roots(S.Sequence{{xi_{p}(U32.to_nat(N), F.array__slots({MX}, _), 0n)}}, S.ListOf{{{sE}, {Lm}}}, [D.bytes(O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_{p}(U32.to_nat(N), F.array__slots({MX}, _), 0n, hl), 0n), N))])')
        w(f'  %xlen_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n, hl) :')
        w(f'    RR.roots(S.Sequence{{xi_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n)}}, S.ListOf{{{sE}, {Lm}}}, [D.bytes(O.mix_len(hl, MD.rtree({D_}n, Nat.is_lt(0n, _), hl, {XLo}, 0n), N))])')
        if big:
            # the spec law at the variable depth, moved to the literal-depth digest
            Dv = f'OS.dv_{D_}(dv)'
            R2v = f'MD.rtree({Dv}, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n)'
            R2l = f'MD.rtree({D_}n, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n)'
            e = f'Equal.cong(Nat, D.Digest, y => O.mix_len(hl, MD.rtree(y, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n), N), {Dv}, {D_}n, OS.dveq(OS.dv_{D_}, dv, edv))'
            w(f'  OS.dtrans(S.Sequence{{xi_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n)}}, S.ListOf{{{sE}, {Lm}}}, O.mix_len(hl, {R2l}, N), O.mix_len(hl, {R2v}, N), {e},')
            XI = f'xi_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n)'
            w(f'    OS.list_none({XI}, {sE}, {Lm}, [D.bytes(O.mix_len(hl, {R2v}, N))], ebs,')
            w(f'    (MD.bytes_list({XLo}), (xroots_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n, hl, ehl, h, {sE}, er, dv, edv, kel, eq),')
            w(f'      (D.bytes({R2v}), (({Dv}, (kmin, RS.at_depth_tree({Lm}, {Dv}, hl, {XLo}, OS.dvl(OS.dv_{D_}, dv, edv, {{==}}), xhl_{p}(N, {Lm}, F.array__slots({MX}, t), hl, hvN), ehl))),')
            w(f'       xlm_{p}(hl, ehl, N, {R2v}, F.array__slots({MX}, t))))))))')
            w('')
            self.done[p] = True
            self.out.extend(self.vecify(fs, L))
            return
        R2 = f'MD.rtree({D_}n, Nat.is_lt(0n, MD.dlen({XLo})), hl, {XLo}, 0n)'
        XI = f'xi_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n)'
        w(f'  OS.list_none({XI}, {sE}, {Lm}, [D.bytes(O.mix_len(hl, {R2}, N))], ebs,')
        w(f'  (MD.bytes_list({XLo}), (xroots_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n, hl, ehl, h, {sE}, er, dv, edv, kel, eq),')
        w(f'    (D.bytes({R2}), (({D_}n, (kmin, RS.at_depth_tree({Lm}, {D_}n, hl, {XLo}, {{==}}, xhl_{p}(N, {Lm}, F.array__slots({MX}, t), hl, hvN), ehl))),')
        w(f'     xlm_{p}(hl, ehl, N, {R2}, F.array__slots({MX}, t)))))))')
        w('')
        self.done[p] = True
        self.out.extend(self.vecify(fs, L))

    def ptlist_laws(self, fs):
        """Laws of a progressive list of boxed Type-kind elements (containers, or
        progressive lists of them): the bounded list's mirror and tree laws
        (tcommon), with the progressive tree `_ptr` (xpt) instead of `_mt0`."""
        if fs.p in self.done:
            return
        p = fs.p
        BE = fs.elem
        if BE.kind != 'box' or BE.inner.data:
            raise Skip(f'{p}: progressive list of {BE.p} (element kind not covered)')
        E = BE.inner
        if E.kind == 'container':
            self.shape(E)
            self.box(BE, 'boxT')
            self.mirror(E)
            self.mirror_box(BE)
            bsE = 'PLO.bs_pcont' if E.t.kind == 'pcontainer' else 'bs_cont'
            okcE = lambda sE, k: f'{bsE}({sE}, okc_{E.p}({sE}, dv, {k}))'
        elif E.kind == 'seq' and E.t.kind == 'plist' and not E.pelem.data:
            self.ptlist_laws(E)
            self.box(BE, 'boxT')
            self.mirror_seq(E)
            self.mirror_box(BE)
            okcE = lambda sE, k: f'PLO.bs_plist({sE}, okc_{E.p}({sE}, dv, {k}))'
        else:
            raise Skip(f'{p}: progressive list of {BE.p} (element kind {E.kind} not covered)')
        RE = RA.qual(E.rep)
        BR = f'O.Boxed<{RE}>'
        MX = f'MB<M_{E.p}>'
        Seq = f'T.{p}_Seq'
        th = f'th_{BE.p}'
        AMt = lambda t: f'am_{p}({t})'
        L = []
        w = L.append
        w(f'# ---- {p}: progressive list of {BE.p} (Type-kind elements, through mirrors) ----')
        Ts, XL, TY, W_, dE = self.tcommon(p, BE, th, MX, BR, AMt, w)
        P_ = 'O.pow2n(dep)'
        B2 = f'Nat.is_lt(Nat.add(s, {P_}), n)'
        w(f'law xpt_{p}:')
        for a, ty in (('g', 'Nat'), ('b', 'Bool'), ('hl', 'Nat'), ('seg', 'U32'), ('dep', 'Nat'), ('s', 'Nat'), ('n', 'Nat'), ('dw', 'Nat')):
            w(f'  for +{a}: {ty}')
        w(f'  for +t: F.array__Tree<{MX}>')
        w('  for -h: B.Buf')
        w('  for +junk: D.Digest')
        w('  for +e: {Nat.is_lt(s, n) == b : Bool}')
        w('  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}')
        w(f'  for +pf: {{F.array__perfect({MX}, dw, t) == True{{}} : Bool}}')
        w('  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}')
        w('  for +sE: S.Schema')
        w(f'  for +er: ereps_{p}(n, {W_}, 0n, sE)')
        w(f'  {{T.{p}_ptr(g, b, hl, seg, dep, s, n, (h, ({Ts}, junk))) == (h, ({Ts}, PR.pr(g, b, hl, dep, s, n, {XL}))) : {TY}}}')
        w(f'def xpt_{p}(g, b, hl, seg, dep, s, n, dw, t, h, junk, e, hd, pf, hn, sE, er):')
        w('  match g:')
        w('    case 0n: {==}')
        w('    case 1n+ +k:')
        w('      match b:')
        w('        case False{}: {==}')
        w('        case True{}:')
        PRK = f'PR.pr(k, {B2}, hl, Nat.add(dep, 2n), Nat.add(s, {P_}), n, {XL})'
        RHS = f'(h, ({Ts}, PR.pr(1n+k, True{{}}, hl, dep, s, n, {XL})))'
        w(f'          %Equal.sym({TY}, T.{p}_ptr(k, {B2}, hl, seg, Nat.add(dep, 2n), Nat.add(s, {P_}), n, (h, ({Ts}, junk))), (h, ({Ts}, {PRK})),')
        w(f'              xpt_{p}(k, {B2}, hl, seg, Nat.add(dep, 2n), Nat.add(s, {P_}), n, dw, t, h, junk, {{==}}, hd, pf, hn, sE, er)) :')
        w(f'            {{T.{p}_prr(hl, seg, dep, s, n, _) == {RHS} : {TY}}}')
        w(f'          %Equal.sym({TY}, T.{p}_mt(dep, 0n, True{{}}, hl, seg, {P_}, s, n, (h, ({Ts}, D.zero()))), (h, ({Ts}, MD.rtree(dep, True{{}}, hl, {XL}, s))),')
        w(f'              xmt_{p}(dep, True{{}}, hl, seg, dw, t, s, n, h, D.zero(), e, hd, pf, hn, sE, er)) :')
        w(f'            {{T.{p}_mj(hl, {PRK}, _) == {RHS} : {TY}}}')
        w('          {==}')
        self.tfz(p, BE, th, MX, BR, AMt, Ts, w)
        nn = 'U32.to_nat(n)'
        w(f'def xlen_o_{p}(o: {Seq}) -> U32:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: n')
        w(f'def xv_{p}(o: {Seq}) -> S.Value:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: S.Sequence{{xi_{p}({nn}, F.array__slots({MX}, tfz_{p}(arr)), 0n)}}')
        w(f'def xd_{p}(+hl: Nat, o: {Seq}) -> D.Digest:')
        w('  match o:')
        w(f'    case {Seq}{{arr, +n}}: O.mix_len(hl, PR.pr(1n+{nn}, Nat.is_lt(0n, {nn}), hl, 0n, 0n, {nn}, xl_{p}({nn}, F.array__slots({MX}, tfz_{p}(arr)), 0n, hl)), n)')
        # as a shape (the element of an outer list): the container API names
        w(f'def v_{p}(o: {Seq}) -> S.Value: xv_{p}(o)')
        w(f'def d_{p}(+hl: Nat, o: {Seq}) -> D.Digest: xd_{p}(hl, o)')
        Wo = f'{Seq}{{{Ts}, N}}'
        sE = 'SH.ProgressiveList_element(s)'
        w(f'def rep_{p}(o: {Seq}, +s: S.Schema) -> Data:')
        w(f'  DK.Ex(F.array__Tree<{MX}>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>')
        w(f'    DK.P2({{o == {Wo} : {Seq}}},')
        w(f'    DK.P2({{F.array__perfect({MX}, dw, t) == True{{}} : Bool}},')
        w('    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},')
        w('    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},')
        w(f'          ereps_{p}(U32.to_nat(N), F.array__slots({MX}, t), 0n, {sE}))))))))')
        w(f'def ok_{p}(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_ProgressiveList(s), ok_{BE.p}({sE}, dv))')
        w(f'def okc_{p}(+s: S.Schema, +dv: OS.DV, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}) -> {{SH.is_ProgressiveList(s) == True{{}} : Bool}}: DK.and_l(SH.is_ProgressiveList(s), ok_{BE.p}({sE}, dv), ok)')
        self.okinfo[p] = ('and', ['SH.is_ProgressiveList(s)', f'ok_{BE.p}({sE}, dv)'], {1: (BE.p, sE)})
        w(f'def eqs_{p}(+s: S.Schema) -> Data: eqs_{BE.p}({sE})')
        self.plists[p] = BE.inner.p
        nN = 'U32.to_nat(N)'
        XLo = f'xl_{p}({nN}, F.array__slots({MX}, t), 0n, hl)'
        PRo = f'PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, {XLo})'

        def dest():
            w('  (+t, w1) = rep')
            w('  (+dw, w2) = w1')
            w('  (+N, w3) = w2')
            w('  (+eo, w4) = w3')
            w('  (+pf, w5) = w4')
            w('  (+hd, w6) = w5')
            w('  (+hn, +er) = w6')
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {Seq}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, xd_{p}(hl, o))) : B.Buf & ({Seq} & D.Digest)}}:')
        dest()
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, xd_{p}(hl, _))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym({TY}, T.{p}_ptr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, seg, 0n, 0n, {nN}, (h, ({Ts}, D.zero()))), (h, ({Ts}, {PRo})),')
        w(f'      xpt_{p}(1n+{nN}, Nat.is_lt(0n, {nN}), hl, seg, 0n, 0n, {nN}, dw, t, h, D.zero(), {{==}}, hd, pf, hn, {sE}, er)) :')
        w(f'    {{T.{p}_rt_fin(hl, N, _) == (h, ({Wo}, xd_{p}(hl, {Wo}))) : B.Buf & ({Seq} & D.Digest)}}')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({Ts}), t, tfzam_{p}(t)) :')
        w(f'    {{(h, ({Wo}, O.mix_len(hl, {PRo}, N))) == (h, ({Wo}, O.mix_len(hl, PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, xl_{p}({nN}, F.array__slots({MX}, _), 0n, hl)), N))) : B.Buf & ({Seq} & D.Digest)}}')
        w('  {==}')
        w(f'def xlm_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, +N: U32, +R: D.Digest, +Wl: List<&2, {MX}>)')
        w(f'    -> {{Mix.mix_length_bytes(Some{{D.bytes(R)}}, Len.encoding(32n, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)))) == Some{{D.bytes(O.mix_len(hl, R, N))}} : Maybe<&2, +List<U32>>}}:')
        w(f'  %Equal.sym(Nat, Codec.count(xi_{p}(U32.to_nat(N), Wl, 0n)), U32.to_nat(N), xcount_{p}(U32.to_nat(N), Wl, 0n)) :')
        w('    {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, R, N))} : Maybe<&2, +List<U32>>}')
        w('  LR.mix_bytes(hl, ehl, R, N)')
        w(f'def wd_{p}(+hl: Nat, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(xd_{p}(hl, o)):')
        w('  (+t, +w1) = rep')
        w('  (+dw, +w2) = w1')
        w('  (+N, +w3) = w2')
        w('  (+eo, +w4) = w3')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) : OS.DW(xd_{p}(hl, _))')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({Ts}), t, tfzam_{p}(t)) : OS.DW(O.mix_len(hl, PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, xl_{p}({nN}, F.array__slots({MX}, _), 0n, hl)), N))')
        w(f'  (O.mix_len(hl, {PRo}, N), {{==}})')
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {Seq}, +s: S.Schema, +rep: rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}, +eq: eqs_{p}(s))')
        w(f'    -> RR.roots(xv_{p}(o), s, [D.bytes(xd_{p}(hl, o))]):')
        dest()
        w(f'  +k0 = DK.and_l(SH.is_ProgressiveList(s), ok_{BE.p}({sE}, dv), ok)')
        w(f'  +kel = DK.and_r(SH.is_ProgressiveList(s), ok_{BE.p}({sE}, dv), ok)')
        w(f'  +ebs = {okcE(sE, "kel")}')
        w(f'  %Equal.sym(S.Schema, s, S.ProgressiveList{{{sE}}}, SH.ProgressiveList_shape(s, k0)) :')
        w(f'    RR.roots(xv_{p}(o), _, [D.bytes(xd_{p}(hl, o))])')
        w(f'  %Equal.sym({Seq}, o, {Wo}, eo) :')
        w(f'    RR.roots(xv_{p}(_), S.ProgressiveList{{{sE}}}, [D.bytes(xd_{p}(hl, _))])')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, tfz_{p}({Ts}), t, tfzam_{p}(t)) :')
        w(f'    RR.roots(S.Sequence{{xi_{p}({nN}, F.array__slots({MX}, _), 0n)}}, S.ProgressiveList{{{sE}}}, [D.bytes(O.mix_len(hl, PR.pr(1n+{nN}, Nat.is_lt(0n, {nN}), hl, 0n, 0n, {nN}, xl_{p}({nN}, F.array__slots({MX}, _), 0n, hl)), N))])')
        XI = f'xi_{p}({nN}, F.array__slots({MX}, t), 0n)'
        w(f'  PLO.plist_none({XI}, {sE}, [D.bytes(O.mix_len(hl, {PRo}, N))], ebs,')
        w(f'  (MD.bytes_list({XLo}), (xroots_{p}({nN}, F.array__slots({MX}, t), 0n, hl, ehl, h, {sE}, er, dv, edv, kel, eq),')
        w(f'    (D.bytes({PRo}), (PCN.pmerk(hl, ehl, {nN}, {XLo}, dw, xlen_{p}({nN}, F.array__slots({MX}, t), 0n, hl), hd, hn),')
        w(f'     xlm_{p}(hl, ehl, N, {PRo}, F.array__slots({MX}, t)))))))')
        w('')
        self.done[p] = True
        self.out.extend(L)

    def mirror_seq(self, s):
        """The Data mirror of a progressive list of boxed Type-kind elements: its
        mirror tree and count (th through the list's am, fz through its tfz)."""
        key = 'M:' + s.p
        if key in self.done:
            return
        self.done[key] = True
        p = s.p
        R = RA.qual(s.rep)
        MX = f'MB<M_{s.elem.inner.p}>'
        L = []
        w = L.append
        w(f'# ---- Data mirror of {p} ----')
        w(f'type M_{p} is Data:')
        w(f'  M_{p}{{t: F.array__Tree<{MX}>, n: U32}}')
        w(f'def th_{p}(m: M_{p}) -> {R}:')
        w('  match m:')
        w(f'    case M_{p}{{+t, +n}}: {R}{{am_{p}(t), n}}')
        w(f'def fz_{p}(x: {R}) -> M_{p}:')
        w('  match x:')
        w(f'    case {R}{{arr, +n}}: M_{p}{{tfz_{p}(arr), n}}')
        w(f'def fzth_{p}(+m: M_{p}) -> {{fz_{p}(th_{p}(m)) == m : M_{p}}}:')
        w('  match m:')
        w(f'    case M_{p}{{+t, +n}}:')
        w(f'      %Equal.sym(F.array__Tree<{MX}>, tfz_{p}(am_{p}(t)), t, tfzam_{p}(t)) : {{M_{p}{{_, n}} == M_{p}{{t, n}} : M_{p}}}')
        w('      {==}')
        w('')
        self.out.extend(L)

    def box_words(self, fs):
        """A box of byte storage (a list element): box laws and its Data mirror."""
        if fs.p in self.done:
            return
        self.done[fs.p] = True
        inner = fs.inner
        k = {'bytelist': 'bl'}[inner.kind]
        d = self.depth(inner, k)
        D = f'OS.dv_{d}(dv)' if d >= BIGD else f'{d}n'
        p = fs.p
        BR = 'O.Boxed<O.Words>'
        B1 = f'O.BSome{{pjb_{p}(o), O.BNone{{}}}}'
        L = []
        w = L.append
        w(f'# ---- box of {inner.p} (byte storage) ----')
        w(f'def pjb_{p}(o: {BR}) -> O.Words:')
        w('  match o:')
        w('    case O.BSome{v, rest}: v')
        w(f'    case O.BNone{{}}: T.{inner.p}_default()')
        w(f'def v_{p}(o: {BR}) -> S.Value:')
        w('  match o:')
        w('    case O.BSome{v, rest}: S.BytesValue{WO.wview(v)}')
        w('    case O.BNone{}: S.NullValue{}')
        w(f'def d_{p}(+hl: Nat, o: {BR}) -> D.Digest:')
        w('  match o:')
        w(f'    case O.BSome{{v, rest}}: LO.ldig(hl, v, {d}n)')
        w('    case O.BNone{}: D.zero()')
        w(f'def rep_{p}(o: {BR}, +s: S.Schema) -> Data:')
        w(f'  DK.P2({{o == {B1} : {BR}}}, LO.rep_bl(pjb_{p}(o), s))')
        w(f'def ok_{p}(+s: S.Schema, +dv: OS.DV) -> Bool: LO.ok_bl(s, {D})')
        self.okinfo[p] = ('bl', d)
        w(f'def eqs_{p}(+s: S.Schema) -> Data: {{True{{}} == True{{}} : Bool}}')
        w(f'def okc_{p}(+s: S.Schema, +dv: OS.DV, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}) -> {{SH.is_ByteList(s) == True{{}} : Bool}}: DK.and_l(SH.is_ByteList(s), Lim.minimal(BL.chunk_limit(SH.ByteList_limit(s)), {D}), ok)')
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {BR}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, d_{p}(hl, o))) : B.Buf & ({BR} & D.Digest)}}:')
        w('  (+eo, +ri) = rep')
        w(f'  %Equal.sym({BR}, o, {B1}, eo) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, d_{p}(hl, _))) : B.Buf & ({BR} & D.Digest)}}')
        w(f'  %Equal.sym(B.Buf & (O.Words & D.Digest), T.{inner.p}_root(hl, h, pjb_{p}(o), seg), (h, (pjb_{p}(o), LO.ldig(hl, pjb_{p}(o), {d}n))), LO.bl_st(hl, h, pjb_{p}(o), {d}, seg, {d}n, LO.rep_wf(pjb_{p}(o), s, ri), {{==}})) :')
        w(f'    {{T.{p}_rt(_) == (h, ({B1}, d_{p}(hl, {B1}))) : B.Buf & ({BR} & D.Digest)}}')
        w('  {==}')
        vw = f'S.BytesValue{{WO.wview(pjb_{p}(o))}}'
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {BR}, +s: S.Schema, +rep: rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}, +eq: eqs_{p}(s))')
        w(f'    -> RR.roots(v_{p}(o), s, [D.bytes(d_{p}(hl, o))]):')
        w('  (+eo, +ri) = rep')
        w(f'  %Equal.sym({BR}, o, {B1}, eo) : RR.roots(v_{p}(_), s, [D.bytes(d_{p}(hl, _))])')
        x = f'pjb_{p}(o)'
        if d >= BIGD:
            law = f'LO.bl_rs(hl, ehl, h, {x}, s, {D}, {d}, 0, ri, ok, OS.dvu(OS.dv_{d}, dv, edv, {d}, {{==}}), OS.dvl(OS.dv_{d}, dv, edv, {{==}}))'
            e = f'Equal.cong(Nat, D.Digest, y => LO.ldig(hl, {x}, y), {D}, {d}n, OS.dveq(OS.dv_{d}, dv, edv))'
            w(f'  OS.dtrans({vw}, s, LO.ldig(hl, {x}, {d}n), LO.ldig(hl, {x}, {D}), {e}, {law})')
        else:
            w(f'  LO.bl_rs(hl, ehl, h, {x}, s, {d}n, {d}, 0, ri, ok, {{==}}, {{==}})')
        w(f'def wd_{p}(+hl: Nat, -o: {BR}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(d_{p}(hl, o)):')
        w('  (+eo, +ri) = rep')
        w(f'  %Equal.sym({BR}, o, {B1}, eo) : OS.DW(d_{p}(hl, _))')
        w(f'  wd_bl(hl, {x}, s, {d}n, ri)')
        # the Data mirror of a list element
        w(f'def th_{p}(m: MB<WMr>) -> {BR}:')
        w('  match m:')
        w('    case MSome{+v}: O.BSome{th_w(v), O.BNone{}}')
        w('    case MNone{}: O.BNone{}')
        w(f'def fz_{p}(x: {BR}) -> MB<WMr>:')
        w('  match x:')
        w('    case O.BSome{v, rest}: MSome{fz_w(v)}')
        w('    case O.BNone{}: MNone{}')
        w(f'def fzth_{p}(+m: MB<WMr>) -> {{fz_{p}(th_{p}(m)) == m : MB<WMr>}}:')
        w('  match m:')
        w('    case MSome{+v}:')
        w('      %Equal.sym(WMr, fz_w(th_w(v)), v, fzth_w(v)) : {MSome{_} == MSome{v} : MB<WMr>}')
        w('      {==}')
        w('    case MNone{}: {==}')
        w('')
        self.out.extend(L)

    # ---- Data mirrors of Type-kind shapes --------------------------------------
    def mfield(self, fs, k):
        """(mirror type, thaw(a), freeze(x), proof of freeze(thaw(a)) == a or None)."""
        R = RA.qual(fs.rep)
        if k in ('data', 'datar', 'bvr'):
            return R, lambda a: a, lambda x: x, None
        if k == 'boxD':
            RI = RA.qual(fs.inner.rep)
            self.mirror_box(fs)
            return (RI, lambda a: f'O.BSome{{{a}, O.BNone{{}}}}',
                    lambda x: f'mfz_{fs.p}({x})', None)
        if k in ('bv', 'bl', 'pv', 'ul', 'ev', 'el') or k in self.PLIST or k.startswith('vk'):
            return 'WMr', lambda a: f'th_w({a})', lambda x: f'fz_w({x})', lambda a: f'fzth_w({a})'
        if k in ('bits', 'pb'):
            return 'BMr', lambda a: f'th_b({a})', lambda x: f'fz_b({x})', lambda a: f'fzth_b({a})'
        if k in ('pk', 'bvb'):
            return 'WMr', lambda a: f'th_w({a})', lambda x: f'fz_w({x})', lambda a: f'fzth_w({a})'
        if k == 'T':
            self.mirror(fs)
            return f'M_{fs.p}', lambda a: f'th_{fs.p}({a})', lambda x: f'fz_{fs.p}({x})', lambda a: f'fzth_{fs.p}({a})'
        if k == 'boxT':
            self.mirror(fs.inner)
            self.mirror_box(fs)
            q = fs.inner.p
            return (f'M_{q}', lambda a: f'O.BSome{{th_{q}({a}), O.BNone{{}}}}',
                    lambda x: f'mfz_{fs.p}({x})', lambda a: f'fzth_{q}({a})')
        raise Skip(f'{fs.p}: no Data mirror for field kind {k}')

    def mirror(self, s):
        """type M_p, th_p, fz_p and fzth_p for a Type-kind container shape (once)."""
        key = 'M:' + s.p
        if key in self.done:
            return
        self.done[key] = True
        p = s.p
        R = RA.qual(s.rep)
        F = s.fields
        n = len(F)
        if n > G.GROUP:
            raise Skip(f'{p}: no Data mirror for a wide container yet')
        kinds = [self.fk(fs) for _, fs in F]
        ms = [self.mfield(fs, k) for (_, fs), k in zip(F, kinds)]
        L = []
        w = L.append
        w(f'# ---- Data mirror of {p} ----')
        w(f'type M_{p} is Data:')
        w(f'  M_{p}{{' + ', '.join(f'a{i}: {ms[i][0]}' for i in range(n)) + '}')
        w(f'def th_{p}(m: M_{p}) -> {R}:')
        w('  match m:')
        w(f'    case M_{p}{{' + ', '.join(f'+a{i}' for i in range(n)) + f'}}: {R}{{' + ', '.join(ms[i][1](f'a{i}') for i in range(n)) + '}')
        isdata = [k in ('data', 'datar', 'bvr') for k in kinds]
        w(f'def fz_{p}(x: {R}) -> M_{p}:')
        w('  match x:')
        w(f'    case {R}{{' + ', '.join(('+' if isdata[i] else '') + f'x{i}' for i in range(n)) + f'}}: M_{p}{{' + ', '.join(ms[i][2](f'x{i}') for i in range(n)) + '}')
        w(f'def fzth_{p}(+m: M_{p}) -> {{fz_{p}(th_{p}(m)) == m : M_{p}}}:')
        w('  match m:')
        w(f'    case M_{p}{{' + ', '.join(f'+a{i}' for i in range(n)) + '}:')
        cur = [ms[i][2](ms[i][1](f'a{i}')) for i in range(n)]
        orig = [f'a{i}' for i in range(n)]
        for i in range(n):
            if ms[i][3] is None:
                cur[i] = orig[i]
                continue
            hole = cur[:i] + ['_'] + cur[i + 1:]
            w(f'      %Equal.sym({ms[i][0]}, {ms[i][2](ms[i][1](f"a{i}"))}, a{i}, {ms[i][3](f"a{i}")}) :')
            w(f'        {{M_{p}{{{", ".join(hole)}}} == M_{p}{{{", ".join(orig)}}} : M_{p}}}')
            cur[i] = orig[i]
        w('      {==}')
        w('')
        self.out.extend(L)

    def mirror_box(self, fs):
        """The freeze of a box field (the inverse of O.BSome{th(a), O.BNone})."""
        key = 'MB:' + fs.p
        if key in self.done:
            return
        self.done[key] = True
        L = []
        w = L.append
        inner = fs.inner
        R = RA.qual(inner.rep)
        if inner.data:
            w(f'def mfz_{fs.p}(x: O.Boxed<{R}>) -> {R}:')
            w('  match x:')
            w('    case O.BSome{+v, rest}: v')
            w(f'    case O.BNone{{}}: T.{inner.p}_default()')
        else:
            q = inner.p
            w(f'def mfz_{fs.p}(x: O.Boxed<{R}>) -> M_{q}:')
            w('  match x:')
            w(f'    case O.BSome{{v, rest}}: fz_{q}(v)')
            w(f'    case O.BNone{{}}: fz_{q}(T.{q}_default())')
            # list elements: the Data box mirror MB
            w(f'def th_{fs.p}(m: MB<M_{q}>) -> O.Boxed<{R}>:')
            w('  match m:')
            w(f'    case MSome{{+v}}: O.BSome{{th_{q}(v), O.BNone{{}}}}')
            w('    case MNone{}: O.BNone{}')
            w(f'def fz_{fs.p}(x: O.Boxed<{R}>) -> MB<M_{q}>:')
            w('  match x:')
            w(f'    case O.BSome{{v, rest}}: MSome{{fz_{q}(v)}}')
            w('    case O.BNone{}: MNone{}')
            w(f'def fzth_{fs.p}(+m: MB<M_{q}>) -> {{fz_{fs.p}(th_{fs.p}(m)) == m : MB<M_{q}>}}:')
            w('  match m:')
            w('    case MSome{+v}:')
            w(f'      %Equal.sym(M_{q}, fz_{q}(th_{q}(v)), v, fzth_{q}(v)) : {{MSome{{_}} == MSome{{v}} : MB<M_{q}>}}')
            w('      {==}')
            w('    case MNone{}: {==}')
        w('')
        self.out.extend(L)

    # ---- shapes -------------------------------------------------------------
    def shape(self, s):
        if s.p in self.done:
            if self.done[s.p] is not True:
                raise Skip(self.done[s.p])
            return
        try:
            if s.kind == 'container' and not s.data:
                lines = self.container(s)
            else:
                raise Skip(f'{s.p}: kind {s.kind}')
        except Skip as e:
            self.done[s.p] = str(e)
            raise
        self.done[s.p] = True
        self.out.extend(lines)

    def box(self, fs, k):
        """Emit the box shape fs (once)."""
        if fs.p in self.done:
            return
        inner = fs.inner
        R = RA.qual(inner.rep)
        BR = f'O.Boxed<{R}>'
        p = fs.p
        L = []
        w = L.append
        w(f'# ---- box of {inner.p} ----')
        if k == 'boxD':
            w(f'def v_{p}(o: {BR}) -> S.Value:')
            w('  match o:')
            w(f'    case O.BSome{{+v, rest}}: RN.v_{inner.p}(v)')
            w('    case O.BNone{}: S.NullValue{}')
            w(f'def d_{p}(+hl: Nat, o: {BR}) -> D.Digest:')
            w('  match o:')
            w(f'    case O.BSome{{+v, rest}}: RN.d_{inner.p}(hl, v)')
            w('    case O.BNone{}: D.zero()')
            w(f'def rep_{p}(o: {BR}, +s: S.Schema) -> Data:')
            w(f'  DK.Ex({R}, v => {{o == O.BSome{{v, O.BNone{{}}}} : {BR}}})')
            w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {BR}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
            w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, d_{p}(hl, o))) : B.Buf & ({BR} & D.Digest)}}:')
            w('  (+v, +eo) = rep')
            w(f'  %Equal.sym({BR}, o, O.BSome{{v, O.BNone{{}}}}, eo) :')
            w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, d_{p}(hl, _))) : B.Buf & ({BR} & D.Digest)}}')
            rhs = f'(h, (O.BSome{{v, O.BNone{{}}}}, d_{p}(hl, O.BSome{{v, O.BNone{{}}}})))'
            w(f'  %Equal.sym(B.Buf & D.Digest, T.{inner.p}_root(hl, h, v, seg), (h, RN.d_{inner.p}(hl, v)), RN.st_{inner.p}(hl, h, v, seg)) :')
            w(f'    {{T.{p}_rt(v, _) == {rhs} : B.Buf & ({BR} & D.Digest)}}')
            w('  {==}')
            E = self.E(fs)
            w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {BR}, +s: S.Schema, +rep: rep_{p}(o, s), +eq: {{s == {E} : S.Schema}})')
            w(f'    -> RR.roots(v_{p}(o), s, [D.bytes(d_{p}(hl, o))]):')
            w('  (+v, +eo) = rep')
            w(f'  %Equal.sym({BR}, o, O.BSome{{v, O.BNone{{}}}}, eo) : RR.roots(v_{p}(_), s, [D.bytes(d_{p}(hl, _))])')
            w(f'  OS.transport(RN.v_{inner.p}(v), s, {E}, [D.bytes(RN.d_{inner.p}(hl, v))], eq, RN.rs_{inner.p}(hl, ehl, v))')
            w(f'def wd_{p}(+hl: Nat, -o: {BR}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(d_{p}(hl, o)):')
            w('  (+v, +eo) = rep')
            w(f'  %Equal.sym({BR}, o, O.BSome{{v, O.BNone{{}}}}, eo) : OS.DW(d_{p}(hl, _))')
            w(f'  (RN.d_{inner.p}(hl, v), {{==}})')
        else:
            w(f'def pjb_{p}(o: {BR}) -> {R}:')
            w('  match o:')
            w('    case O.BSome{v, rest}: v')
            w(f'    case O.BNone{{}}: T.{inner.p}_default()')
            w(f'def v_{p}(o: {BR}) -> S.Value:')
            w('  match o:')
            w(f'    case O.BSome{{v, rest}}: v_{inner.p}(v)')
            w('    case O.BNone{}: S.NullValue{}')
            w(f'def d_{p}(+hl: Nat, o: {BR}) -> D.Digest:')
            w('  match o:')
            w(f'    case O.BSome{{v, rest}}: d_{inner.p}(hl, v)')
            w('    case O.BNone{}: D.zero()')
            w(f'def rep_{p}(o: {BR}, +s: S.Schema) -> Data:')
            w(f'  DK.P2({{o == O.BSome{{pjb_{p}(o), O.BNone{{}}}} : {BR}}}, rep_{inner.p}(pjb_{p}(o), s))')
            w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {BR}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
            w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, d_{p}(hl, o))) : B.Buf & ({BR} & D.Digest)}}:')
            w('  (+eo, +ri) = rep')
            v = f'pjb_{p}(o)'
            B1 = f'O.BSome{{{v}, O.BNone{{}}}}'
            w(f'  %Equal.sym({BR}, o, {B1}, eo) :')
            w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, d_{p}(hl, _))) : B.Buf & ({BR} & D.Digest)}}')
            rhs = f'(h, ({B1}, d_{p}(hl, {B1})))'
            w(f'  %Equal.sym(B.Buf & ({R} & D.Digest), T.{inner.p}_root(hl, h, {v}, seg), (h, ({v}, d_{inner.p}(hl, {v}))), st_{inner.p}(hl, h, {v}, seg, s, ri)) :')
            w(f'    {{T.{p}_rt(_) == {rhs} : B.Buf & ({BR} & D.Digest)}}')
            w('  {==}')
            w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {BR}, +s: S.Schema, +rep: rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{ok_{inner.p}(s, dv) == True{{}} : Bool}}, +eq: eqs_{inner.p}(s))')
            w(f'    -> RR.roots(v_{p}(o), s, [D.bytes(d_{p}(hl, o))]):')
            w('  (+eo, +ri) = rep')
            w(f'  %Equal.sym({BR}, o, {B1}, eo) : RR.roots(v_{p}(_), s, [D.bytes(d_{p}(hl, _))])')
            w(f'  rs_{inner.p}(hl, ehl, h, {v}, s, ri, dv, edv, ok, eq)')
            w(f'def wd_{p}(+hl: Nat, -o: {BR}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(d_{p}(hl, o)):')
            w('  (+eo, +ri) = rep')
            w(f'  %Equal.sym({BR}, o, {B1}, eo) : OS.DW(d_{p}(hl, _))')
            w(f'  wd_{inner.p}(hl, {v}, s, ri)')
            # the box's ok / eqs are the inner's
            w(f'def ok_{p}(+s: S.Schema, +dv: OS.DV) -> Bool: ok_{inner.p}(s, dv)')
            self.okinfo[p] = ('alias', inner.p)
            w(f'def eqs_{p}(+s: S.Schema) -> Data: eqs_{inner.p}(s)')
        w('')
        self.done[fs.p] = True
        self.out.extend(L)

    def container(self, s):
        p = s.p
        R = RA.qual(s.rep)
        F = s.fields
        n = len(F)
        kinds = []
        for f, fs in F:
            k = self.fk(fs)
            if k in ('boxD', 'boxT'):
                self.box(fs, k)
            kinds.append(k)
        wide = n > G.GROUP
        groups = [list(range(j, min(n, j + G.GROUP))) for j in range(0, n, G.GROUP)] if wide else None
        xs = [f'x{i}' for i in range(n)]
        isdata = [k in ('data', 'datar', 'bvr') for k in kinds]
        L = []
        w = L.append
        w(f'# ---- {p} (Type-kind container, {n} fields{", in groups" if wide else ""}) ----')

        # pattern of the object from field binders
        def gname(j):
            return f'T.{p}_g{j}'

        def obj(args):
            if not wide:
                return f'{R}{{' + ', '.join(args) + '}'
            return f'{R}{{' + ', '.join(f'{gname(j)}{{' + ', '.join(args[i] for i in grp) + '}' for j, grp in enumerate(groups)) + '}'

        def match_lines(binders, body, ind='  '):
            """match o on the object's structure, then `body`."""
            if not wide:
                w(f'{ind}match o:')
                w(f'{ind}  case {R}{{' + ', '.join(binders) + f'}}: {body}')
                return
            gb = []
            for j, grp in enumerate(groups):
                gdata = all(isdata[i] for i in grp)
                gb.append(('+' if gdata else '') + f'g{j}')
            w(f'{ind}match o:')
            w(f'{ind}  case {R}{{' + ', '.join(gb) + '}:')
            cur = ind + '    '
            for j, grp in enumerate(groups):
                w(f'{cur}match g{j}:')
                w(f'{cur}  case {gname(j)}{{' + ', '.join(binders[i] for i in grp) + '}:')
                cur += '    '
            w(f'{cur}{body}')

        binders = [('+' if isdata[i] else '') + xs[i] for i in range(n)]
        # projections of the Type-kind fields
        for i in range(n):
            if isdata[i]:
                continue
            w(f'def pj_{p}_{i}(o: {R}) -> {RA.qual(F[i][1].rep)}:')
            match_lines(binders, xs[i])
        args = [xs[i] if isdata[i] else f'pj_{p}_{i}(o)' for i in range(n)]
        # a progressive container (generic forms): the progressive schema's
        # accessors, its active list, and the progressive root tree (pcont.bend)
        prog = s.t is not None and s.t.kind == 'pcontainer'
        if prog:
            from codegen.proofs.laws import pcont_laws as PCL
            if wide:
                raise Skip(f'{p}: wide progressive container')
            PK_ = PCL.key(s.t.active)
            ACT = PCL.act_term(s.t.active)
        cf = 'SH.ProgressiveContainer_fields' if prog else 'SH.Container_fields'
        cpred = 'SH.is_ProgressiveContainer' if prog else 'SH.is_Container'

        def digexpr(ds):
            if prog:
                return f'O.mix_len(hl, {PCL.expr(PCL.tree(s.t.active), ds)}, {PCL.mask(s.t.active)})'
            return f'MD.rtree({depth}n, True{{}}, hl, [' + ', '.join(ds) + '], 0n)'
        sx = [sch('s', i, cf) for i in range(n)]
        # view and digest
        items = 'S.EmptyItems{}'
        for i in range(n - 1, -1, -1):
            items = f'S.Items{{{self.view(F[i][1], kinds[i], xs[i])}, {items}}}'
        w(f'def v_{p}(o: {R}) -> S.Value:')
        match_lines(binders, f'S.Sequence{{{items}}}')
        depth = G.log2ceil(n)
        w(f'def d_{p}(+hl: Nat, o: {R}) -> D.Digest:')
        match_lines(binders, digexpr([self.dig(F[i][1], kinds[i], xs[i]) for i in range(n)]))
        # rep
        reps = [self.rep(F[i][1], kinds[i], args[i], sx[i]) for i in range(n)]
        inner = fold_p2([f'{{o == {obj(args)} : {R}}}'] + [r for r in reps if r])
        rt = inner
        for i in range(n - 1, -1, -1):
            if isdata[i]:
                rt = f'DK.Ex({RA.qual(F[i][1].rep)}, {xs[i]} => {rt})'
        w(f'def rep_{p}(o: {R}, +s: S.Schema) -> Data:')
        w(f'  {rt}')
        # ok
        f0 = f'{cf}(s)'
        conj = [f'{cpred}(s)'] + [f'SH.is_Chain({tails(f0, j)})' for j in range(n)] + [f'SH.is_End({tails(f0, n)})']
        oks = [self.ok(F[i][1], kinds[i], sx[i]) for i in range(n)]
        ok_at = {}
        subs = {}
        leafsym = {}
        for i in range(n):
            if oks[i]:
                ok_at[i] = len(conj)
                if oks[i].startswith('ok_'):
                    subs[len(conj)] = (F[i][1].p, sx[i])
                elif F[i][1].p in LIMIT_LEMMAS:
                    leafsym[len(conj)] = (F[i][1].p, sx[i])
                conj.append(oks[i])
        if prog:
            kact = len(conj)
            conj.append(f'PCN.beq(SH.ProgressiveContainer_active(s), {ACT})')
        self.okinfo[p] = ('and', list(conj), subs, leafsym) if leafsym else ('and', list(conj), subs)
        w(f'def ok_{p}(+s: S.Schema, +dv: OS.DV) -> Bool: {fold_and(conj)}')
        w(f'def okc_{p}(+s: S.Schema, +dv: OS.DV, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}) -> {{{cpred}(s) == True{{}} : Bool}}: DK.and_l({conj[0]}, {fold_and(conj[1:])}, ok)')
        # eqs
        eqt = [(i, self.eqs_type(F[i][1], kinds[i], sx[i])) for i in range(n)]
        eqt = [(i, t) for i, t in eqt if t]
        w(f'def eqs_{p}(+s: S.Schema) -> Data: {fold_p2([t for _, t in eqt])}')
        self.meta[p] = dict(sx=sx, kinds=kinds, F=F, eqt=[i for i, _ in eqt], cf=cf)

        def conj_lets(ind='  '):
            """let-bind every ok conjunct: +k{j}."""
            m = len(conj) - 1
            prev = 'ok'
            for j in range(m + 1):
                rest = fold_and(conj[j + 1:])
                if j < m:
                    w(f'{ind}+k{j} = DK.and_l({conj[j]}, {rest}, {prev})')
                    w(f'{ind}+r{j + 1} = DK.and_r({conj[j]}, {rest}, {prev})')
                    prev = f'r{j + 1}'
            self.klast = (m, prev)
            return lambda j: prev if j == m else f'k{j}'

        def rep_lets(ind='  '):
            """destructure rep: Data fields, eo, the reps of Type fields."""
            cur = 'rep'
            c = 0
            for i in range(n):
                if isdata[i]:
                    w(f'{ind}(+{xs[i]}, +q{c}) = {cur}')
                    cur = f'q{c}'
                    c += 1
            rs_ = [i for i in range(n) if reps[i]]
            if not rs_:
                self.eo_name = cur
                return {}
            self.eo_name = 'eo'
            names_ = {}
            w(f'{ind}(+eo, +q{c}) = {cur}')
            cur = f'q{c}'
            c += 1
            for j, i in enumerate(rs_):
                if j == len(rs_) - 1:
                    names_[i] = cur
                else:
                    w(f'{ind}(+rp{i}, +q{c}) = {cur}')
                    cur = f'q{c}'
                    c += 1
                    names_[i] = f'rp{i}'
            return names_

        def eqs_lets(ind='  '):
            names_ = {}
            idx = [i for i, _ in eqt]
            cur = 'ev'
            for j, i in enumerate(idx):
                if j == len(idx) - 1:
                    names_[i] = cur
                else:
                    w(f'{ind}(+qe{i}, +qv{j}) = {cur}')
                    cur = f'qv{j}'
                    names_[i] = f'qe{i}'
            return names_

        # the fields' chain shape
        chain = 'S.End{}'
        for i in range(n - 1, -1, -1):
            chain = f'S.Chain{{{sx[i]}, {chain}}}'
        w(f'def fsh_{p}(+s: S.Schema, +dv: OS.DV, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}) -> {{{f0} == {chain} : S.Schema}}:')
        kn = conj_lets()
        for j in range(n + 1):
            t = tails(f0, j)
            ctx = '_'
            for i in range(j - 1, -1, -1):
                ctx = f'S.Chain{{{sx[i]}, {ctx}}}'
            if j < n:
                w(f'  %Equal.sym(S.Schema, {t}, S.Chain{{SH.Chain_head({t}), SH.Chain_tail({t})}}, SH.Chain_shape({t}, {kn(j + 1)})) :')
            else:
                w(f'  %Equal.sym(S.Schema, {t}, S.End{{}}, SH.End_shape({t}, {kn(j + 1)})) :')
            w(f'    {{{ctx} == {chain} : S.Schema}}')
        w('  {==}')

        # the state law
        TY = f'B.Buf & ({R} & D.Digest)'
        w(f'def st_{p}(+hl: Nat, -h: B.Buf, -o: {R}, +seg: U32, +s: S.Schema, +rep: rep_{p}(o, s))')
        w(f'    -> {{T.{p}_root(hl, h, o, seg) == (h, (o, d_{p}(hl, o))) : {TY}}}:')
        rpn = rep_lets()
        O_ = obj(args)
        w(f'  %Equal.sym({R}, o, {O_}, {self.eo_name}) :')
        w(f'    {{T.{p}_root(hl, h, _, seg) == (h, (_, d_{p}(hl, _))) : {TY}}}')
        RHS = f'(h, ({O_}, d_{p}(hl, {O_})))'
        if not wide:
            self.chain_rewrites(w, f'T.{p}', list(range(n)), F, kinds, args, isdata, sx, rpn, RHS, TY)
        else:
            # the outer chain over the groups, each group's root by its own law
            gargs = [f'{gname(j)}{{' + ', '.join(args[i] for i in grp) + '}' for j, grp in enumerate(groups)]
            gdata = [all(isdata[i] for i in grp) for grp in groups]
            gdig = [f'MD.rtree(3n, True{{}}, hl, [' + ', '.join(self.dig(F[i][1], kinds[i], args[i]) for i in grp) + '], 0n)' for grp in groups]
            ng = len(groups)
            gd = G.log2ceil(n) - 3
            counts = [ng]
            for lv in range(gd):
                counts.append((counts[-1] + 1) // 2)
            zl = [lv for lv in range(gd) if counts[lv] % 2 == 1]
            steps = [('g', j) for j in range(ng)] + [('z', 3 + lv) for lv in zl]
            done = []
            for k2, st in enumerate(steps):
                if st[0] == 'z':
                    done.append(f'D.zconst({st[1]}n)')
                    continue
                j = st[1]
                held = [gargs[jj] for jj in range(ng) if not (jj == j and not gdata[jj])]
                ctx = f'T.{p}_rt{k2}(' + ', '.join(['hl', 'seg'] + held + done + ['_']) + ')'
                grp = groups[j]
                gparams = []
                for i in grp:
                    gparams.append(args[i])
                for i in grp:
                    if reps[i]:
                        gparams += [sx[i], rpn[i]]
                lhs = f'T.{p}_g{j}_root(hl, h, {gargs[j]}, seg)'
                if gdata[j]:
                    rhs, ty = f'(h, {gdig[j]})', 'B.Buf & D.Digest'
                else:
                    rhs, ty = f'(h, ({gargs[j]}, {gdig[j]}))', f'B.Buf & ({gname(j)} & D.Digest)'
                w(f'  %Equal.sym({ty}, {lhs}, {rhs}, stg_{p}_{j}(hl, h, ' + ', '.join(gparams) + ', seg)) :')
                w(f'    {{{ctx} == {RHS} : {TY}}}')
                done.append(gdig[j])
        w('  {==}')
        # group state laws come first in the file: emit them before this block
        pre = []
        if wide:
            for j, grp in enumerate(groups):
                pre.extend(self.group_law(p, j, grp, F, kinds, isdata, reps))

        digs0 = [self.dig(F[i][1], kinds[i], args[i]) for i in range(n)]

        def witnesses(rpn):
            """digest witnesses of the Type-kind fields: (list of digests with
            witnesses, [(i, witness, proof)])."""
            ws_ = []
            for i in range(n):
                if isdata[i]:
                    continue
                dd, de = self.witness(F[i][1], kinds[i], args[i], sx[i], rpn[i], i, w)
                ws_.append((i, dd, de))
            digw = list(digs0)
            for i, dd, _ in ws_:
                digw[i] = dd
            return digw, ws_

        def dig_rewrites(digw, ws_, ctx):
            """rewrite the fields' digests to their witnesses inside ctx(L)."""
            cur = list(digs0)
            for i, dd, de in ws_:
                hole = list(cur)
                hole[i] = '_'
                w(f'  %Equal.sym(D.Digest, {digs0[i]}, {dd}, {de}) :')
                w(f'    {ctx(digexpr(hole))}')
                cur[i] = dd

        # the digest as a value (from the invariant)
        w(f'def wd_{p}(+hl: Nat, -o: {R}, +s: S.Schema, +rep: rep_{p}(o, s)) -> OS.DW(d_{p}(hl, o)):')
        rpn = rep_lets()
        digw, ws_ = witnesses(rpn)
        w(f'  %Equal.sym({R}, o, {O_}, {self.eo_name}) : OS.DW(d_{p}(hl, _))')
        dig_rewrites(digw, ws_, lambda t: f'OS.DW({t})')
        w(f'  ({digexpr(digw)}, {{==}})')

        # the spec law
        w(f'def rs_{p}(+hl: Nat, +ehl: {{hl == 64n : Nat}}, -h: B.Buf, -o: {R}, +s: S.Schema, +rep: rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{ok_{p}(s, dv) == True{{}} : Bool}}, +ev: eqs_{p}(s))')
        w(f'    -> RR.roots(v_{p}(o), s, [D.bytes(d_{p}(hl, o))]):')
        rpn = rep_lets()
        eqn = eqs_lets()
        digw, ws_ = witnesses(rpn)
        kn = conj_lets()
        w(f'  %Equal.sym({R}, o, {O_}, {self.eo_name}) : RR.roots(v_{p}(_), s, [D.bytes(d_{p}(hl, _))])')
        if prog:
            PN, PF, PA = 'SH.ProgressiveContainer_names(s)', 'SH.ProgressiveContainer_fields(s)', 'SH.ProgressiveContainer_active(s)'
            w(f'  %Equal.sym(S.Schema, s, S.ProgressiveContainer{{{PN}, {PF}, {PA}}}, SH.ProgressiveContainer_shape(s, {kn(0)})) :')
            w(f'    RR.roots(v_{p}({O_}), _, [D.bytes(d_{p}(hl, {O_}))])')
            w(f'  %Equal.sym(S.Schema, {PF}, {chain}, fsh_{p}(s, dv, ok)) :')
            w(f'    RR.roots(v_{p}({O_}), S.ProgressiveContainer{{{PN}, _, {PA}}}, [D.bytes(d_{p}(hl, {O_}))])')
            w(f'  %Equal.sym(+List<Bool>, {PA}, {ACT}, PCN.beq_eq({PA}, {ACT}, {kn(kact)})) :')
            w(f'    RR.roots(v_{p}({O_}), S.ProgressiveContainer{{{PN}, {chain}, _}}, [D.bytes(d_{p}(hl, {O_}))])')
            dig_rewrites(digw, ws_, lambda t: f'RR.roots(v_{p}({O_}), S.ProgressiveContainer{{{PN}, {chain}, {ACT}}}, [D.bytes({t})])')
        else:
            w(f'  %Equal.sym(S.Schema, s, S.Container{{SH.Container_names(s), SH.Container_fields(s)}}, SH.Container_shape(s, {kn(0)})) :')
            w(f'    RR.roots(v_{p}({O_}), _, [D.bytes(d_{p}(hl, {O_}))])')
            w(f'  %Equal.sym(S.Schema, SH.Container_fields(s), {chain}, fsh_{p}(s, dv, ok)) :')
            w(f'    RR.roots(v_{p}({O_}), S.Container{{SH.Container_names(s), _}}, [D.bytes(d_{p}(hl, {O_}))])')
            dig_rewrites(digw, ws_, lambda t: f'RR.roots(v_{p}({O_}), S.Container{{SH.Container_names(s), {chain}}}, [D.bytes({t})])')
        wmap = {i: (dd, de) for i, dd, de in ws_}
        digs = digw
        Lda = '[' + ', '.join(digs) + ']'

        def items_proof(i):
            if i == n:
                return '{==}'
            rest = '[' + ', '.join(digs[i + 1:]) + ']'
            fs, k = F[i][1], kinds[i]
            okp = kn(ok_at[i]) if i in ok_at else None
            eqp = eqn.get(i)
            rsx = self.rs(fs, k, args[i], sx[i], rpn.get(i), okp, eqp)
            if i in wmap:
                rsx = f'OS.dtrans({self.view(fs, k, args[i])}, {sx[i]}, {wmap[i][0]}, {digs0[i]}, {wmap[i][1]}, {rsx})'
            return f'([D.bytes({digs[i]})], (MD.bytes_list({rest}), ({rsx}, ({items_proof(i + 1)}, {{==}}))))'
        w(f'  (MD.bytes_list({Lda}), ({items_proof(0)},')
        if prog:
            w(f'    PCN.{PK_}_ar(hl, ehl, {", ".join(digs)})))')
        else:
            w(f'    RS.aggregate_digests({n}n, {depth}n, hl, {Lda}, {{==}}, {{==}}, {{==}}, ehl)))')
        w('')
        return pre + L

    def chain_rewrites(self, w, Tp, idx, F, kinds, args, isdata, sx, rpn, RHS, TY):
        """rt-chain rewrites of a plain field set (container or group)."""
        n = len(idx)
        # zero levels, as generate.emit_fieldset_root
        depth = 3 if Tp.endswith('__group') else G.log2ceil(n)
        width = 1 << depth
        level_nodes = [n]
        for lv in range(depth):
            level_nodes.append((level_nodes[-1] + 1) // 2)
        zlevels = sorted(set(lv for lv in range(1, depth) if level_nodes[lv] % 2 == 1 or level_nodes[lv] < (width >> lv) and level_nodes[lv] % 2 == 1))
        steps = [('f', j) for j in range(n)] + [('z', lv) for lv in zlevels]
        done = []
        for k2, st in enumerate(steps):
            if st[0] == 'z':
                done.append(f'D.zconst({st[1]}n)')
                continue
            j = st[1]
            i = idx[j]
            fs, k = F[i][1], kinds[i]
            held = [args[idx[jj]] for jj in range(n) if not (jj == j and not isdata[idx[jj]])]
            ctx = f'{Tp.replace("__group", "")}_rt{k2}(' + ', '.join(['hl', 'seg'] + held + done + ['_']) + ')'
            lhs, rhs, ty, pf = self.st(fs, k, args[i], sx[i], rpn.get(i))
            w(f'  %Equal.sym({ty}, {lhs}, {rhs}, {pf}) :')
            w(f'    {{{ctx} == {RHS} : {TY}}}')
            done.append(self.dig(fs, k, args[i]))

    def group_law(self, p, j, grp, F, kinds, isdata, reps):
        L = []
        w = L.append
        GR = f'T.{p}_g{j}'
        gdata = all(isdata[i] for i in grp)
        xs = [f'x{i}' for i in grp]
        params = []
        for i in grp:
            params.append(('+' if isdata[i] else '-') + f'x{i}: {RA.qual(F[i][1].rep)}')
        for i in grp:
            if reps[i]:
                sx = f's{i}'
                params += [f'+{sx}: S.Schema', f'+r{i}: {self.rep(F[i][1], kinds[i], f"x{i}", sx)}']
        dig = 'MD.rtree(3n, True{}, hl, [' + ', '.join(self.dig(F[i][1], kinds[i], f'x{i}') for i in grp) + '], 0n)'
        O_ = f'{GR}{{' + ', '.join(xs) + '}'
        if gdata:
            TY = 'B.Buf & D.Digest'
            RHS = f'(h, {dig})'
        else:
            TY = f'B.Buf & ({GR} & D.Digest)'
            RHS = f'(h, ({O_}, {dig}))'
        w(f'def stg_{p}_{j}(+hl: Nat, -h: B.Buf, ' + ', '.join(params) + f', +seg: U32)')
        w(f'    -> {{T.{p}_g{j}_root(hl, h, {O_}, seg) == {RHS} : {TY}}}:')
        sub_F = [F[i] for i in grp]
        sub_k = [kinds[i] for i in grp]
        sub_args = xs
        sub_d = [isdata[i] for i in grp]
        sub_sx = [f's{i}' for i in grp]
        rpn = {jj: f'r{i}' for jj, i in enumerate(grp) if reps[i]}
        self.chain_rewrites(w, f'T.{p}_g{j}__group', list(range(len(grp))), sub_F, sub_k, sub_args, sub_d, sub_sx, rpn, RHS, TY)
        w('  {==}')
        w('')
        return L

    # ---- name laws ------------------------------------------------------------
    def eqs_proof(self, name, p, path):
        """A proof of eqs_p(path(s)) from es: s == Spec.name(); `path` maps a
        schema expression to the expression of p's schema inside it."""
        if p in getattr(self, 'plists', {}):
            return self.eqs_proof(name, self.plists[p], lambda y: f'SH.ProgressiveList_element({path(y)})')
        m = self.meta[p]
        comps = []
        for i in m['eqt']:
            fs, k = m['F'][i][1], m['kinds'][i]
            sub = (lambda y, i=i: sch(path(y), i, m.get('cf', 'SH.Container_fields')))
            if k in ('data', 'datar', 'bvr', 'boxD'):
                comps.append(f'OS.eq_at(y => {sub("y")}, s, Spec.{name}(), {self.E(fs)}, es, {{==}})')
            elif k == 'ptl':
                comps.append(self.eqs_proof(name, fs.p, sub))
            elif k == 'px':
                comps.append(f'OS.eq_at(y => SH.ProgressiveList_element({sub("y")}), s, Spec.{name}(), {RA.spec_schema(fs.pelem)}, es, {{==}})')
            elif k == 'xl':
                comps.append(f'OS.eq_at(y => {self.vsub(fs, "SH.ListOf_element")}({sub("y")}), s, Spec.{name}(), {RA.spec_schema(fs.pelem)}, es, {{==}})')
            elif k == 'tl' and fs.elem.inner.kind != 'container':
                comps.append('{==}')
            elif k == 'tl':
                comps.append(self.eqs_proof(name, fs.elem.inner.p, lambda y, sub=sub, fs=fs: f'{self.vsub(fs, "SH.ListOf_element")}({sub(y)})'))
            else:
                inner = fs.inner if k == 'boxT' else fs
                comps.append(self.eqs_proof(name, inner.p, sub))
        if not comps:
            return 'Unit{}'
        t = comps[-1]
        for c in reversed(comps[:-1]):
            t = f'({c}, {t})'
        return t

    def has_symbolic(self, p):
        info = self.okinfo.get(p)
        if info is None:
            return False
        if info[0] == 'bl':
            b = LIMIT_LEMMAS_BL.get(p.removesuffix('_bx'))
            return b is not None and b[0] == info[1]
        if info[0] == 'alias':
            return self.has_symbolic(info[1])
        if len(info) > 3 and info[3]:
            return True
        return any(self.has_symbolic(sp) for sp, _ in info[2].values())

    def ok_intros(self, p, Q, L, seen):
        """Emit okI_<p>: ok_<p>(s, dv) from one fact per conjunct, proved with s
        and dv as variables (nothing closed is evaluated), for every shape on
        the way to a symbolic byte-list fact."""
        if p in seen or not self.has_symbolic(p):
            return
        seen.add(p)
        info = self.okinfo[p]
        w = L.append
        if info[0] == 'bl':
            d = info[1]
            w(f'def okI_{p}(+s: S.Schema, +dv: OS.DV, +h: {{LO.ok_bl(s, OS.dv_{d}(dv)) == True{{}} : Bool}}) -> {{{Q}ok_{p}(s, dv) == True{{}} : Bool}}: h')
            return
        if info[0] == 'alias':
            self.ok_intros(info[1], Q, L, seen)
            w(f'def okI_{p}(+s: S.Schema, +dv: OS.DV, +h: {{{Q}ok_{info[1]}(s, dv) == True{{}} : Bool}}) -> {{{Q}ok_{p}(s, dv) == True{{}} : Bool}}: h')
            return
        conj, subs = info[1], info[2]
        for sp, _ in subs.values():
            self.ok_intros(sp, Q, L, seen)
        cs = [self.qual(c, Q) for c in conj]
        hs = ', '.join(f'+h{j}: {{{c} == True{{}} : Bool}}' for j, c in enumerate(cs))
        t = f'h{len(cs) - 1}'
        for j in range(len(cs) - 2, -1, -1):
            t = f'LUL.and_t({cs[j]}, {fold_and(cs[j + 1:])}, h{j}, {t})'
        w(f'def okI_{p}(+s: S.Schema, +dv: OS.DV, {hs}) -> {{{Q}ok_{p}(s, dv) == True{{}} : Bool}}:')
        w(f'  {t}')

    @staticmethod
    def qual(c, Q):
        return re.sub(r'(?<![\w.])ok_', Q + 'ok_', c)

    def okproof(self, p, S, Q):
        """A proof of {ok_p(S, OS.DV0()) == True{}} for a closed schema S: okI_p at
        (S, DV0()), whose type is the goal's text; each conjunct without a
        symbolic byte-list fact is a closed fact ({==}, evaluated)."""
        if not self.has_symbolic(p):
            return '{==}'
        info = self.okinfo[p]
        if info[0] == 'bl':
            lemma = LIMIT_LEMMAS_BL[p.removesuffix('_bx')][1]
            return f'okI_{p}({S}, OS.DV0(), {lemma}({S}, {{==}}))'
        if info[0] == 'alias':
            return f'okI_{p}({S}, OS.DV0(), {self.okproof(info[1], S, Q)})'
        conj, subs = info[1], info[2]
        leafsym = info[3] if len(info) > 3 else {}

        def close(c):
            return re.sub(r'(?<![\w.])s(?![\w])', lambda _: S, c)
        pf = []
        for j in range(len(conj)):
            if j in subs and self.has_symbolic(subs[j][0]):
                pf.append(self.okproof(subs[j][0], close(subs[j][1]), Q))
            elif j in leafsym:
                # a closed limit fact proved symbolically (proofs/obj/lim_st.bend)
                pf.append(f'{LIMIT_LEMMAS[leafsym[j][0]]}({close(leafsym[j][1])}, {{==}})')
            else:
                pf.append('{==}')
        return f'okI_{p}({S}, OS.DV0(), ' + ', '.join(pf) + ')'

    okI_seen = set()

    def name_law(self, name, s, q='', sym=False):
        p = s.p
        Q = q
        R = RA.qual(s.rep)
        L = []
        w = L.append
        w(f'# {name}: for every object representing a value of Spec.{name}(), the runtime')
        w('# root is a specification root of that value.')
        # the closed schema fact is the last argument of ok_at: evaluated once
        # ({==}), or, for a BIG name, built from okI lemmas (okproof)
        closed = '{==}'
        if self.has_symbolic(p):
            # root_types' own names share one set of okI lemmas; a big file has its own
            self.ok_intros(p, Q, L, self.okI_seen if not (Q or sym) else set())
            closed = self.okproof(p, f'Spec.{name}()', Q)
        w(f'def {name}_ok(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}, +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}) -> {{{Q}ok_{p}(s, dv) == True{{}} : Bool}}:')
        w(f'  OS.ok_at(y => d => {Q}ok_{p}(y, d), s, Spec.{name}(), dv, es, edv, {closed})')
        eqp = self.eqs_proof(name, p, lambda y: y)
        w(f'def {name}_eqs(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}) -> {Q}eqs_{p}(s): {eqp}')
        concl = f'RR.roots({Q}v_{p}(o), s, [D.bytes(Pair.snd({R}, D.Digest, Pair.snd(B.Buf, {R} & D.Digest, T.{name}_hash_tree_root(h, o))))])'
        w(f'def {name}_rc(-h: B.Buf, -o: {R}, +s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}, +rep: {Q}rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}})')
        w(f'    -> {concl}:')
        w(f'  %Equal.sym(B.Buf & ({R} & D.Digest), T.{p}_root(64n, h, o, 0), (h, (o, {Q}d_{p}(64n, o))), {Q}st_{p}(64n, h, o, 0, s, rep)) :')
        w(f'    RR.roots({Q}v_{p}(o), s, [D.bytes(Pair.snd({R}, D.Digest, Pair.snd(B.Buf, {R} & D.Digest, _)))])')
        w(f'  {Q}rs_{p}(64n, {{==}}, h, o, s, rep, dv, edv, {name}_ok(s, es, dv, edv), {name}_eqs(s, es))')
        w(f'law {name}_root_correct:')
        w('  for -h: B.Buf')
        w(f'  for -o: {R}')
        w('  for +s: S.Schema')
        w(f'  for +es: {{s == Spec.{name}() : S.Schema}}')
        w(f'  for +rep: {Q}rep_{p}(o, s)')
        w(f'  {concl}')
        w(f'def {name}_root_correct(h, o, s, es, rep): {name}_rc(h, o, s, es, rep, OS.DV0(), {{==}})')
        w('')
        return L

    def words_law(self, name, s):
        k = {'fixwords': 'bv', 'bytelist': 'bl', 'bitlist': 'bits'}.get(s.kind)
        if k is None or (k == 'bv' and s.t.kind != 'bytes'):
            raise Skip(f'{name}: kind {s.kind}')
        d = self.depth(s, k)
        M = {'bv': 'WO', 'bl': 'LO', 'bits': 'BO'}[k]
        OT = 'O.Bits' if k == 'bits' else 'O.Words'
        VIEW = 'S.BitsValue{BO.bview(o)}' if k == 'bits' else 'S.BytesValue{WO.wview(o)}'
        REP = 'BO.rep_bits' if k == 'bits' else f'{M}.rep_{k}'
        OK = 'BO.ok_bits' if k == 'bits' else f'{M}.ok_{k}'
        RS_ = 'BO.brs' if k == 'bits' else f'{M}.{k}_rs'
        run = {'bv': f'O.words_root(64n, h, o, {d}, 0)', 'bl': f'O.mix_count(64n, 0n, O.words_root(64n, h, o, {d}, 0))',
               'bits': f'O.bits_root(64n, h, o, {d}, 0)'}[k]
        dig = self.dig(s, k, 'o').replace('hl', '64n')
        st = {'bv': f'WO.bv_st(64n, h, o, {d}, 0, {d}n, WO.rep_wf(o, s, rep), {{==}})',
              'bl': f'LO.bl_st(64n, h, o, {d}, 0, {d}n, LO.rep_wf(o, s, rep), {{==}})',
              'bits': f'BO.bst(64n, h, o, {d}, 0, {d}n, BO.rep_wf(o, s, rep), {{==}})'}[k]
        if d >= BIGD:
            if k == 'bits':
                raise Skip(f'{name}: bit list of depth {d} >= {BIGD}')
            return self.words_law_big(name, s, k, d, M, run, dig, st)
        L = []
        w = L.append
        what = 'bits' if k == 'bits' else 'bytes'
        w(f'# {name}: for every {"bit list" if k == "bits" else "byte storage"} object representing a value of Spec.{name}(),')
        w(f'# the runtime root is a specification root of its {what}.')
        w(f'def {name}_ok(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}) -> {{{OK}(s, {d}n) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(S.Schema, s, Spec.{name}(), es) : {{{OK}(_, {d}n) == True{{}} : Bool}}')
        w(f'  {LIMIT_LEMMAS[s.p]}(Spec.{name}(), {{==}})' if s.p in LIMIT_LEMMAS else '  {==}')
        w(f'law {name}_root_correct:')
        w('  for -h: B.Buf')
        w(f'  for -o: {OT}')
        w('  for +s: S.Schema')
        w(f'  for +es: {{s == Spec.{name}() : S.Schema}}')
        w(f'  for +rep: {REP}(o, s)')
        w(f'  RR.roots({VIEW}, s, [D.bytes(Pair.snd({OT}, D.Digest, Pair.snd(B.Buf, {OT} & D.Digest, T.{name}_hash_tree_root(h, o))))])')
        w(f'def {name}_root_correct(h, o, s, es, rep):')
        w(f'  %Equal.sym(B.Buf & ({OT} & D.Digest), {run}, (h, (o, {dig})), {st}) :')
        w(f'    RR.roots({VIEW}, s, [D.bytes(Pair.snd({OT}, D.Digest, Pair.snd(B.Buf, {OT} & D.Digest, _)))])')
        w(f'  {RS_}(64n, {{==}}, h, o, s, {d}n, {d}, 0, rep, {name}_ok(s, es), {{==}}, {{==}})')
        w('')
        return L

    def plist_law(self, name, s):
        """A progressive list of basic elements held as packed bytes (prog_list)."""
        K = 'b' if s.t.elem.kind == 'bool' else str(s.t.elem.size)
        sh = {'b': 0, '1': 0, '2': 1, '4': 2, '8': 3, '16': 4, '32': 5}[K]
        VIEW = {'8': 'UL.uview(o)', '4': 'PK.vview4(o)', '16': 'PK.vview16(o)', '32': 'PK.vview32(o)',
                '1': 'PB.vview1(o)', '2': 'PB.vview2(o)', 'b': 'PB.vviewb(o)'}[K]
        L = []
        w = L.append
        w(f'# {name}: for every packed byte object representing a value of Spec.{name}(),')
        w('# the runtime root is a specification root of its elements.')
        w(f'def {name}_ok(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}) -> {{PG.ok_pl{K}(s) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(S.Schema, s, Spec.{name}(), es) : {{PG.ok_pl{K}(_) == True{{}} : Bool}}')
        w('  {==}')
        w(f'law {name}_root_correct:')
        w('  for -h: B.Buf')
        w('  for -o: O.Words')
        w('  for +s: S.Schema')
        w(f'  for +es: {{s == Spec.{name}() : S.Schema}}')
        w(f'  for +rep: PG.rep_pl{K}(o, s)')
        w(f'  RR.roots({VIEW}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, T.{name}_hash_tree_root(h, o))))])')
        w(f'def {name}_root_correct(h, o, s, es, rep):')
        w(f'  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, {sh}n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, {sh}n))), PG.pl_st(64n, h, o, 0, {sh}n, PG.rep_wf{K}(o, s, rep))) :')
        w(f'    RR.roots({VIEW}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])')
        w(f'  PG.pl{K}_rs(64n, {{==}}, o, s, rep, {name}_ok(s, es))')
        w('')
        return L

    def pbits_law(self, name, s):
        """A progressive bit list (pbits_obj.bend)."""
        L = []
        w = L.append
        TY = 'B.Buf & (O.Bits & D.Digest)'
        w(f'# {name}: for every represented progressive bit list, the runtime root is a')
        w('# specification root of its bits.')
        w(f'def {name}_ok(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}) -> {{PBO.ok_pbits(s) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(S.Schema, s, Spec.{name}(), es) : {{PBO.ok_pbits(_) == True{{}} : Bool}}')
        w('  {==}')
        w(f'law {name}_root_correct:')
        w('  for -h: B.Buf')
        w('  for -o: O.Bits')
        w('  for +s: S.Schema')
        w(f'  for +es: {{s == Spec.{name}() : S.Schema}}')
        w('  for +rep: PBO.rep_pbits(o, s)')
        w(f'  RR.roots(S.BitsValue{{BO.bview(o)}}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, T.{name}_hash_tree_root(h, o))))])')
        w(f'def {name}_root_correct(h, o, s, es, rep):')
        w(f'  %Equal.sym({TY}, O.bits_root_prog(64n, h, o, 0), (h, (o, PBO.pbdig(64n, o))), PBO.pbst(64n, h, o, 0, rep)) :')
        w('    RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])')
        w(f'  PBO.pbrs(64n, {{==}}, h, o, s, rep, {name}_ok(s, es))')
        w('')
        return L

    def packed_law(self, name, s):
        """A vector of uint32/64/128/256 held as packed words (packed_obj)."""
        W = 1 if s.t.elem.kind == 'bool' else s.t.elem.size
        d = G.log2ceil(G.chunks_of(W * s.t.size))
        # uint8 and boolean vectors: one byte per element (packed_bytes.bend)
        Mo, K = ('PB', 'b') if s.t.elem.kind == 'bool' else (('PB', str(W)) if W in (1, 2) else ('PK', W))
        VIEW = f'{Mo}.vview{K}(o)'
        L = []
        w = L.append
        w(f'# {name}: for every packed word object representing a value of Spec.{name}(),')
        w('# the runtime root is a specification root of its elements.')
        w(f'def {name}_ok(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}) -> {{{Mo}.ok_v{K}(s, {d}n) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(S.Schema, s, Spec.{name}(), es) : {{{Mo}.ok_v{K}(_, {d}n) == True{{}} : Bool}}')
        w('  {==}')
        w(f'law {name}_root_correct:')
        w('  for -h: B.Buf')
        w('  for -o: O.Words')
        w('  for +s: S.Schema')
        w(f'  for +es: {{s == Spec.{name}() : S.Schema}}')
        w(f'  for +rep: {Mo}.rep_v{K}(o, s)')
        w(f'  RR.roots({VIEW}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, T.{name}_hash_tree_root(h, o))))])')
        w(f'def {name}_root_correct(h, o, s, es, rep):')
        w(f'  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, {d}, 0), (h, (o, WO.wdig(64n, o, {d}n))), WO.bv_st(64n, h, o, {d}, 0, {d}n, {Mo}.rep_wf{K}(o, s, rep), {{==}})) :')
        w(f'    RR.roots({VIEW}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])')
        w(f'  {Mo}.v{K}_rs(64n, {{==}}, o, s, {d}n, rep, {name}_ok(s, es), {{==}})')
        w('')
        return L

    def words_law_big(self, name, s, k, d, M, run, dig, st):
        """words_law for depth >= BIGD: the schema fact at the variable depth."""
        f = self.DIGF[k]
        D = f'OS.dv_{d}(dv)'
        L = []
        w = L.append
        w(f'# {name}: for every byte storage object representing a value of Spec.{name}(),')
        closed = '{==}'
        if s.p in LIMIT_LEMMAS_BL:
            sd, lemma = LIMIT_LEMMAS_BL[s.p]
            if (M, k, d) != ('LO', 'bl', sd):
                raise Skip(f'{name}: symbolic limit table does not match (M={M}, k={k}, d={d})')
            closed = f'{lemma}(Spec.{name}(), {{==}})'
            w('# the runtime root is a specification root of its bytes. The closed limit fact')
            w(f'# is proved symbolically ({lemma}, proofs/obj/lim_bl.bend).')
        else:
            w('# the runtime root is a specification root of its bytes. The closed limit fact')
            w('# is evaluated once, at DV0() (a large closed number, so this takes long).')
        w(f'def {name}_ok(+s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}, +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}) -> {{{M}.ok_{k}(s, {D}) == True{{}} : Bool}}:')
        w(f'  OS.ok_at(y => e => {M}.ok_{k}(y, OS.dv_{d}(e)), s, Spec.{name}(), dv, es, edv, {closed})')
        concl = f'RR.roots(S.BytesValue{{WO.wview(o)}}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, T.{name}_hash_tree_root(h, o))))])'
        w(f'def {name}_rc(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {{s == Spec.{name}() : S.Schema}}, +rep: {M}.rep_{k}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}})')
        w(f'    -> {concl}:')
        w(f'  %Equal.sym(B.Buf & (O.Words & D.Digest), {run}, (h, (o, {dig})), {st}) :')
        w('    RR.roots(S.BytesValue{WO.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])')
        law = f'{M}.{k}_rs(64n, {{==}}, h, o, s, {D}, {d}, 0, rep, {name}_ok(s, es, dv, edv), OS.dvu(OS.dv_{d}, dv, edv, {d}, {{==}}), OS.dvl(OS.dv_{d}, dv, edv, {{==}}))'
        e = f'Equal.cong(Nat, D.Digest, y => {f}(64n, o, y), {D}, {d}n, OS.dveq(OS.dv_{d}, dv, edv))'
        w(f'  OS.dtrans(S.BytesValue{{WO.wview(o)}}, s, {f}(64n, o, {d}n), {f}(64n, o, {D}), {e}, {law})')
        w(f'law {name}_root_correct:')
        w('  for -h: B.Buf')
        w('  for -o: O.Words')
        w('  for +s: S.Schema')
        w(f'  for +es: {{s == Spec.{name}() : S.Schema}}')
        w(f'  for +rep: {M}.rep_{k}(o, s)')
        w(f'  {concl}')
        w(f'def {name}_root_correct(h, o, s, es, rep): {name}_rc(h, o, s, es, rep, OS.DV0(), {{==}})')
        w('')
        return L

    def run(self):
        self.meta = {}
        status = {}
        laws = []
        big = {}
        deferred = []
        for n, t in self.names.items():
            if n in SPLIT_NAMES:
                deferred.append(n)
                continue
            s = self.g.shape(t)
            if s.kind == 'packed' and t.kind == 'plist' and (t.elem.kind == 'bool' or (t.elem.kind == 'uint' and t.elem.size in (1, 2, 4, 8, 16, 32))):
                laws.extend(self.plist_law(n, s))
                status[n] = 'proved (phase B, progressive list)'
                continue
            if s.kind == 'packed' and t.kind == 'vector' and (t.elem.kind == 'bool' or (t.elem.kind == 'uint' and t.elem.size in (1, 2, 4, 8, 16, 32))):
                laws.extend(self.packed_law(n, s))
                status[n] = 'proved (phase B, packed vector)'
                continue
            if getattr(self, 'v2', False) and t.kind == 'pbits':
                laws.extend(self.pbits_law(n, s))
                status[n] = 'proved (phase B, progressive bit list)'
                continue
            if n in ('Blob', 'Transaction') or s.kind in ('bitlist', 'fixwords', 'bytelist'):
                try:
                    (big.setdefault(n, []) if n in LARGE_NAMES else laws).extend(self.words_law(n, s))
                    status[n] = 'proved (phase B, byte storage)'
                except Skip as e:
                    status[n] = f'phase B: {e}'
                continue
            if s.kind != 'container' or s.data:
                continue
            try:
                self.shape(s)
                if n in NAME_SKIP:
                    status[n] = f'phase B: {NAME_SKIP[n]}'
                    continue
                if n in LARGE_NAMES:
                    big.setdefault(n, []).extend(self.name_law(n, s, 'RT.'))
                else:
                    laws.extend(self.name_law(n, s))
                status[n] = 'proved (phase B)'
            except Skip as e:
                status[n] = f'phase B: {e}'
        base_out = list(self.out)
        state_laws = {}
        self.bvr_ok = True
        for n in deferred:
            s = self.g.shape(self.names[n])
            try:
                self.shape(s)
                state_laws[n] = self.name_law(n, s, '', sym=True)
                status[n] = 'proved (phase B, big)'
            except Skip as e:
                status[n] = f'phase B: {e}'
        state_body = self.out[len(base_out):]
        self.out = base_out
        text = '\n'.join(HEAD + ['', '# GENERATED by codegen/proofs/laws/root_laws_b.py. Do not edit.',
                                 '# Root laws of the Type-kind containers (see the generator).', ''] + WD_WORDS.strip('\n').split('\n') + [''] + self.out + laws) + '\n'
        self.state_text = None
        if deferred:
            rt = defnames(text)
            body = qualify('\n'.join(state_body), rt, 'RT.')
            self.state_text = '\n'.join(HEAD + STATE_HEAD + ['', '# GENERATED by codegen/proofs/laws/root_laws_b.py. Do not edit.',
                                                             '# Root laws of the shapes only BeaconState uses (see SPLIT_NAMES in the generator);',
                                                             '# the shapes it shares with other names are root_types\'s (RT).', '', body]) + '\n'
            st = defnames(self.state_text)
            for n, ls in state_laws.items():
                big[n] = ['import ./root_state.bend as ST', 'import ./blist_obj.bend as BLI', 'import ./lim_st.bend as LST', '',
                          '# GENERATED by codegen/proofs/laws/root_laws_b.py. Do not edit.',
                          '# BIG: checks only with the rigid-subterms checker (see LIMIT_LEMMAS in the generator).', '',
                          qualify(qualify('\n'.join(ls), st, 'ST.'), rt, 'RT.')]
        # One file per name (proofs/obj/root_<Name>.bend): each closed schema
        # fact is evaluated in its own checker process, so the unary evaluations
        # of the 2^30-byte Transaction limit do not accumulate in one process.
        bigtext = {ROOT / f'proofs/obj/root_{n}.bend':
                   ('\n'.join(BIGHEAD + ls) if n in state_laws else
                    '\n'.join(BIGHEAD + ['', '# GENERATED by codegen/proofs/laws/root_laws_b.py. Do not edit.',
                                         '# BIG: checks only with the rigid-subterms checker (see LIMIT_LEMMAS_BL in the generator).', ''] + ls)) + '\n'
                   for n, ls in big.items()}
        return text, bigtext, status


def main():
    gen = Gen()
    text, bigtext, status = gen.run()
    if '--status' in sys.argv:
        for n, st in status.items():
            print(f'{n}: {st}')
        return 0
    if False:
        bigtext = {}
    extra = [(STATE_OUT, gen.state_text)] if gen.state_text is not None else []
    from codegen.proofs.laws import root_laws_generic as RLG  # the object views, mirrors and invariants: light companions (codegen/proofs/support/light_split.py)
    both = RLG.light_outs([(OUT, text)] + extra, 'codegen/proofs/laws/root_laws_b.py')
    text, extra = both[0][1], both[1:]
    from codegen.impl import runtime_refs as RR  # the runtime split: the modules import the per-name files they use
    text = RR.rewire(text)
    extra = RR.rewire_out(extra)
    bigtext = RR.rewire_out(bigtext)
    if '--check' in sys.argv:
        for path, t in [(OUT, text)] + extra + sorted(bigtext.items()):
            if not path.exists() or path.read_text() != t:
                print(f'{path} is stale; run codegen/proofs/laws/root_laws_b.py')
                return 1
        return 0
    if not OUT.exists() or OUT.read_text() != text:
        OUT.write_text(text)
    for path, t in extra + list(bigtext.items()):
        if not path.exists() or path.read_text() != t:
            path.write_text(t)
    return 0


if __name__ == '__main__':
    sys.exit(main())
