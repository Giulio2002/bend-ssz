#!/usr/bin/env python3
"""The symbolic decoder-acceptance witness of FuluBeaconState (docs/BS_WITNESS_DESIGN.md, stages 2 to 4), in modules that each check
in under two minutes and 12 GB (every one measured; docs/BS_WITNESS_DESIGN.md section 6):

  e2e/e2e_symdec_sk_lib_generated.bend         the list lemmas: zero words, `limbs`/`wlp` round trip, the sparse writes `ups(kv, l)` over a zero
                                               list with `ups_nth` (the word k is the last write, evaluated on U32 literals), `neq`, `lt_nat`
  e2e/FuluBeaconState_e2e_symdec_sk_generated.bend    the skeleton input: the byte list `limbs(ups(kv, ZW(M)))` of the offsets-only input
                                               (every list empty, the payload header with 3 bytes of extra data), its length (hn), byte domain
                                               (hd), its tree's words, and every word the window check reads, as facts about the list
  (later stages: the check over any list satisfying those facts; the assembly)

The input is the byte list of a *word list*: `sl0 = ups(kv, ZW(M))`, M = n0 / 4 zero words with the 15 words that hold the 12 offsets and
the header's own offset written. No gap lengths are ever added up (they would be equations between unary numbers of 600,000 successors,
which overflow the checker): `ups_nth` is proved once for every sparse list by induction, and an instance is a lookup that compares
U32 literals.

    python3 codegen/proofs/witnesses/beacon_state_symbolic_witness.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.proofs.witnesses import symbolic_decoder_witnesses as SD  # noqa: E402

E2E = ROOT / 'e2e'
OBJ = ROOT / 'proofs/obj'
NAME = 'FuluBeaconState'
LIB2 = E2E / 'e2e_symdec_sk_lib_generated.bend'
SK = E2E / f'{NAME}_e2e_symdec_sk_generated.bend'

# the skeleton: every list empty; the payload header (latest_execution_payload_header) is its 584-byte fixed part (its extra_data offset = 584)
# and 3 bytes of extra data, so the input length is a multiple of 4
HEADER_FIXED = 584
EXTRA = 3
HEADER_OFFSET_IN = 256 + 180      # var_bytesx_ExecutionPayloadHeader.SPOw reads the offset word at 256 + 180 in its window
BITS_POS = 2687256                # FX_bv4.CHK reads the justification bits' byte here (must be zero above the low 4 bits)

LIB2_IMPORTS = """import Base
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/spec_fixed.bend as F
import ../proofs/obj/load_words.bend as LW
import ../proofs/obj/vbuf.bend as VB
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ./e2e_load.bend as L
import ./e2e_zero_run_generated.bend as ZR
"""

LIB2_BODY = r'''# ---- the zero-run word list and the sparse writes over it --------------------------------------------------------------------

def len_zw(+m: Nat) -> {FD.spec_common__length(U32, ZR.ZW(m)) == m : Nat}:
  match m:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, FD.spec_common__length(U32, ZR.ZW(p)), p, len_zw(p))

def len_eq(+xs: List<&2, U32>) -> {List.length(&2, U32, xs) == FD.spec_common__length(U32, xs) : Nat}:
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, t), FD.spec_common__length(U32, t), len_eq(t))

def nthc_zw(+m: Nat, +q: Nat) -> {FD.flat__nthc(ZR.ZW(m), q) == 0 : U32}:
  match m q:
    case 0n _: {==}
    case 1n+ +p 0n: {==}
    case 1n+ +p 1n+ +j: nthc_zw(p, j)

def len_limbs(+sl: List<&2, U32>) -> {List.length(&2, U32, F.limbs(sl)) == A.quad(List.length(&2, U32, sl)) : Nat}:
  match sl:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(Nat, Nat, z => 4n+z, List.length(&2, U32, F.limbs(t)), A.quad(List.length(&2, U32, t)), len_limbs(t))

def wlp_limbs(+sl: List<&2, U32>) -> {L.wlp(F.limbs(sl)) == sl : List<&2, U32>}:
  match sl:
    case Nil{}: {==}
    case Con{+h, +t}:
      Equal.trans(List<&2, U32>, L.wlp(F.limbs(Con{h, t})), Con{h, L.wlp(F.limbs(t))}, Con{h, t},
        Equal.cong(U32, List<&2, U32>, z => Con{z, L.wlp(F.limbs(t))}, B.word_of(B.byte_sel(0, h), B.byte_sel(1, h), B.byte_sel(2, h), B.byte_sel(3, h)), h, LW.word_of_bytes(h)),
        Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{h, z}, L.wlp(F.limbs(t)), t, wlp_limbs(t)))

# a sparse list of word writes (index, value); a later write wins
type KV is Type:
  KVNil{}
  KVCons{+k: U32, +v: U32, r: KV}

def ups(kv: KV, l: List<&2, U32>) -> List<&2, U32>:
  match kv:
    case KVNil{}: l
    case KVCons{+k, +v, r}: ups(r, FD.spec_common__update(U32, l, U32.to_nat(k), v))

def lookup(kv: KV, +k: U32, +d: U32) -> U32:
  match kv:
    case KVNil{}: d
    case KVCons{+k2, +v, r}: lookup(r, k, O.pick(U32.is_eq(k2, k), v, d))

def neq_c(+a: U32, +b: U32, +h: {U32.is_eq(a, b) == False{} : Bool}, +c: Bool, +ec: {Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) == c : Bool}) -> {Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) == False{} : Bool}:
  match c:
    case False{}: ec
    case True{}:
      Empty.absurd({Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) == False{} : Bool}, FD.logic__false_true(Equal.trans(Bool, False{}, U32.is_eq(a, b), True{}, Equal.sym(Bool, U32.is_eq(a, b), False{}, h), FD.u32alg__eq_true(a, b, FD.u32__injective(a, b, FD.nat__eq_from_is_eq(U32.to_nat(a), U32.to_nat(b), Equal.trans(Bool, Nat.is_eq(U32.to_nat(a), U32.to_nat(b)), c, True{}, ec, {==})))))))

# two U32 indices that differ as U32 differ as Nat, with no unary number formed
def neq(+a: U32, +b: U32, +h: {U32.is_eq(a, b) == False{} : Bool}) -> {Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) == False{} : Bool}:
  neq_c(a, b, h, Nat.is_eq(U32.to_nat(a), U32.to_nat(b)), {==})

def ups_step(+k2: U32, +v: U32, +l: List<&2, U32>, +k: U32, +d: U32, +hd: {FD.flat__nthc(l, U32.to_nat(k)) == d : U32},
    +hl: {Nat.is_lt(U32.to_nat(k), FD.spec_common__length(U32, l)) == True{} : Bool}, +c: Bool, +ec: {U32.is_eq(k2, k) == c : Bool})
    -> {FD.flat__nthc(FD.spec_common__update(U32, l, U32.to_nat(k2), v), U32.to_nat(k)) == O.pick(c, v, d) : U32}:
  match c:
    case True{}:
      +e = FD.u32alg__eq_of(k2, k, ec)
      FD.logic__subst(U32, z => {FD.flat__nthc(FD.spec_common__update(U32, l, U32.to_nat(k2), v), U32.to_nat(z)) == v : U32}, k2, k, e,
        FD.flat__nthc_same(l, U32.to_nat(k2), v, FD.logic__subst(U32, z => {Nat.is_lt(U32.to_nat(z), FD.spec_common__length(U32, l)) == True{} : Bool}, k, k2, Equal.sym(U32, k2, k, e), hl)))
    case False{}:
      Equal.trans(U32, FD.flat__nthc(FD.spec_common__update(U32, l, U32.to_nat(k2), v), U32.to_nat(k)), FD.flat__nthc(l, U32.to_nat(k)), d,
        FD.flat__nthc_other(l, U32.to_nat(k2), U32.to_nat(k), v, neq(k2, k, ec)), hd)

# the word k of a sparse list is the last write to k, or the base word: the reads of the skeleton are this, evaluated on U32 literals
def ups_nth(kv: KV, +l: List<&2, U32>, +k: U32, +d: U32, +hd: {FD.flat__nthc(l, U32.to_nat(k)) == d : U32},
    +hl: {Nat.is_lt(U32.to_nat(k), FD.spec_common__length(U32, l)) == True{} : Bool})
    -> {FD.flat__nthc(ups(kv, l), U32.to_nat(k)) == lookup(kv, k, d) : U32}:
  match kv:
    case KVNil{}: hd
    case KVCons{+k2, +v, r}:
      ups_nth(r, FD.spec_common__update(U32, l, U32.to_nat(k2), v), k, O.pick(U32.is_eq(k2, k), v, d),
        ups_step(k2, v, l, k, d, hd, hl, U32.is_eq(k2, k), {==}),
        FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(k), z) == True{} : Bool}, FD.spec_common__length(U32, l), FD.spec_common__length(U32, FD.spec_common__update(U32, l, U32.to_nat(k2), v)),
          Equal.sym(Nat, FD.spec_common__length(U32, FD.spec_common__update(U32, l, U32.to_nat(k2), v)), FD.spec_common__length(U32, l), FD.list__length_update(U32, l, U32.to_nat(k2), v)), hl))

# U32 order as Nat order
def lt_nat(+a: U32, +b: U32, +h: {U32.is_lt(a, b) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(U32.to_nat(a), U32.to_nat(b)), U32.is_lt(a, b), True{}, Equal.sym(Bool, U32.is_lt(a, b), Nat.is_lt(U32.to_nat(a), U32.to_nat(b)), VB.lt_u32n(a, b)), h)

# a U32 below 2^d (d < 32) is a Nat below the power of two, without forming either unary number
def lt_pw(+a: U32, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +h: {U32.is_lt(a, FD.u32__pow2u(d)) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat(a), FD.spec_common__pow2(d)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(a), z) == True{} : Bool}, U32.to_nat(FD.u32__pow2u(d)), FD.spec_common__pow2(d), FD.u32__pow2u_value(d, hd), lt_nat(a, FD.u32__pow2u(d), h))

# the same stated with VB.pw (the composed theorems' h31 is `Nat.is_lt(to_nat(n), VB.pw(31n))`): generic in d, so that VB.pw(d) unfolds
# to the power of two with d a variable; a closed `VB.pw(31n)` against `spec_common__pow2(31n)` would be evaluated (2^31 successors)
def lt_pwv(+a: U32, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +h: {U32.is_lt(a, FD.u32__pow2u(d)) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat(a), VB.pw(d)) == True{} : Bool}:
  lt_pw(a, d, hd, h)

# a U32 index a below b below 2^d: 1 + a is below 2^d
def lt_pw_s(+a: U32, +b: U32, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hab: {U32.is_lt(a, b) == True{} : Bool}, +hb: {U32.is_lt(b, FD.u32__pow2u(d)) == True{} : Bool})
    -> {Nat.is_lt(1n+U32.to_nat(a), FD.spec_common__pow2(d)) == True{} : Bool}:
  FD.nat__le_lt_trans(1n+U32.to_nat(a), U32.to_nat(b), FD.spec_common__pow2(d), FD.nat__lt_succ_le_succ(U32.to_nat(a), U32.to_nat(b), lt_nat(a, b, hab)), lt_pw(b, d, hd, hb))

# the word k of a sparse list over m zero words (k < m, as U32): the last write, else 0
def zw_get(+m: U32, kv: KV, +k: U32, +hk: {U32.is_lt(k, m) == True{} : Bool})
    -> {FD.flat__nthc(ups(kv, ZR.ZW(U32.to_nat(m))), U32.to_nat(k)) == lookup(kv, k, 0) : U32}:
  ups_nth(kv, ZR.ZW(U32.to_nat(m)), k, 0, nthc_zw(U32.to_nat(m), U32.to_nat(k)),
    FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(k), z) == True{} : Bool}, U32.to_nat(m), FD.spec_common__length(U32, ZR.ZW(U32.to_nat(m))), Equal.sym(Nat, FD.spec_common__length(U32, ZR.ZW(U32.to_nat(m))), U32.to_nat(m), len_zw(U32.to_nat(m))), lt_nat(k, m, hk)))

def len_ups(kv: KV, +l: List<&2, U32>) -> {FD.spec_common__length(U32, ups(kv, l)) == FD.spec_common__length(U32, l) : Nat}:
  match kv:
    case KVNil{}: {==}
    case KVCons{+k, +v, r}:
      Equal.trans(Nat, FD.spec_common__length(U32, ups(r, FD.spec_common__update(U32, l, U32.to_nat(k), v))), FD.spec_common__length(U32, FD.spec_common__update(U32, l, U32.to_nat(k), v)), FD.spec_common__length(U32, l),
        len_ups(r, FD.spec_common__update(U32, l, U32.to_nat(k), v)), FD.list__length_update(U32, l, U32.to_nat(k), v))

# a successor of a U32 index (below 2^32 - 1) as a Nat successor
def succ_nat(+a: U32, +h: {Nat.is_lt(1n+U32.to_nat(a), FD.spec_common__pow2(32n)) == True{} : Bool}) -> {U32.to_nat(U32.add(a, 1)) == 1n+U32.to_nat(a) : Nat}:
  VB.add_lt32(a, 1, U32.to_nat(a), {==}, h)
'''


def skeleton(defs):
    """(n0, {word index: word}, [(label, c, R, lo, hi)]) of the offsets-only input"""
    ks = sorted(int(n[1:]) for n in defs if re.fullmatch(r'O\d+', n))
    pos = {k: SD.offset_pos(defs, k)[1] for k in ks}
    F = 2737225
    n0 = F + HEADER_FIXED + EXTRA
    assert n0 % 4 == 0
    # the field order: O0..O7 end at the payload header (O7's window is the header), later offsets point past it
    val = {k: (F if k <= 7 else n0) for k in ks}
    byte = {}
    for k in ks:
        for i in range(4):
            byte[pos[k] + i] = (val[k] >> (8 * i)) & 255
    for i in range(4):
        byte[F + HEADER_OFFSET_IN + i] = (HEADER_FIXED >> (8 * i)) & 255
    words = {}
    for p, b in byte.items():
        words[p // 4] = words.get(p // 4, 0) | (b << (8 * (p % 4)))
    reads = []
    for k in ks:
        c = pos[k]
        reads.append((f'o{k}', str(c), c % 4, words.get(c // 4, 0), words.get(c // 4 + 1, 0), c))
    c = F + HEADER_OFFSET_IN
    reads.append(('spo', f'U32.add({F}, {HEADER_OFFSET_IN})', c % 4, words.get(c // 4, 0), words.get(c // 4 + 1, 0), c))
    reads.append(('bits', str(BITS_POS), BITS_POS % 4, words.get(BITS_POS // 4, 0), words.get(BITS_POS // 4 + 1, 0), BITS_POS))
    return n0, words, reads, val


def kv_text(words):
    t = 'K.KVNil{}'
    for wi in sorted(words, reverse=True):
        t = f'K.KVCons{{{wi}, {words[wi]}, {t}}}'
    return t


def sk_module():
    wmod = OBJ / 'var_winx_BeaconState.bend'
    defs = SD.parse_defs(wmod.read_text())
    n0, words, reads, val = skeleton(defs)
    KV = kv_text(words)
    M = f'U32.shrn({n0}, 2n)'
    SL = f'K.ups({KV}, ZR.ZW(U32.to_nat({M})))'
    L = ['import Base', 'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/spec_fixed.bend as F',
         'import ../proofs/obj/vbuf.bend as VB', 'import ../spec/primitives.bend as SP', 'import ../src/buffer.bend as B',
         'import ./e2e_zero_run_generated.bend as ZR', 'import ./e2e_load.bend as L', 'import ./e2e_symdec_lib_generated.bend as SL', 'import ./e2e_symdec_sk_lib_generated.bend as K', '',
         writer.header('beacon_state_symbolic_witness'),
         f'# {NAME}: the offsets-only input. Its words: {len(words)} written over {n0 // 4} zero words; the offsets are {val}.', '']
    for label, c, R, lo, hi, cc in reads:
        k = f'U32.shrn({c}, 2n)'
        Q = f'U32.to_nat({k})'
        L.append(f'def skf_{label}_lo() -> {{FD.flat__nthc({SL}, {Q}) == {lo} : U32}}:')
        L.append(f'  Equal.trans(U32, FD.flat__nthc({SL}, {Q}), K.lookup({KV}, {k}, 0), {lo}, K.zw_get({M}, {KV}, {k}, {{==}}), {{==}})')
        L.append('')
        if R:
            k1 = f'U32.add({k}, 1)'
            L.append(f'def skf_{label}_hi() -> {{FD.flat__nthc({SL}, 1n+{Q}) == {hi} : U32}}:')
            L.append(f'  Equal.trans(U32, FD.flat__nthc({SL}, 1n+{Q}), FD.flat__nthc({SL}, U32.to_nat({k1})), {hi},')
            L.append(f'    Equal.cong(Nat, U32, z => FD.flat__nthc({SL}, z), 1n+{Q}, U32.to_nat({k1}), Equal.sym(Nat, U32.to_nat({k1}), 1n+{Q}, K.succ_nat({k}, {{==}}))),')
            L.append(f'    Equal.trans(U32, FD.flat__nthc({SL}, U32.to_nat({k1})), K.lookup({KV}, {k1}, 0), {hi}, K.zw_get({M}, {KV}, {k1}, {{==}}), {{==}}))')
            L.append('')
    # hn, hd, the tree's words
    L.append(f'# the input: the bytes of the word list; its length is the unary number of n0 = {n0} without ever forming it')
    L.append(f'def sk_len() -> {{List.length(&2, U32, F.limbs({SL})) == U32.to_nat({n0}) : Nat}}:')
    L.append(f'  Equal.trans(Nat, List.length(&2, U32, F.limbs({SL})), A.quad(List.length(&2, U32, {SL})), U32.to_nat({n0}), K.len_limbs({SL}),')
    L.append(f'    Equal.trans(Nat, A.quad(List.length(&2, U32, {SL})), A.quad(U32.to_nat({M})), U32.to_nat({n0}),')
    L.append(f'      Equal.cong(Nat, Nat, z => A.quad(z), List.length(&2, U32, {SL}), U32.to_nat({M}),')
    L.append(f'        Equal.trans(Nat, List.length(&2, U32, {SL}), FD.spec_common__length(U32, {SL}), U32.to_nat({M}), K.len_eq({SL}),')
    L.append(f'          Equal.trans(Nat, FD.spec_common__length(U32, {SL}), FD.spec_common__length(U32, ZR.ZW(U32.to_nat({M}))), U32.to_nat({M}), K.len_ups({KV}, ZR.ZW(U32.to_nat({M}))), K.len_zw(U32.to_nat({M}))))),')
    L.append(f'      Equal.sym(Nat, U32.to_nat({n0}), A.quad(U32.to_nat({M})), SL.pos_lit({n0}, {{==}}))))')
    L.append('')
    L.append(f'def sk_dom() -> {{SP.bytes_domain(F.limbs({SL})) == True{{}} : Bool}}: F.domain_limbs({SL})')
    L.append('')
    L.append(f'def sk_wlp() -> {{K.wlp(F.limbs({SL})) == {SL} : List<&2, U32>}}: K.wlp_limbs({SL})')
    return '\n'.join(L).replace('K.wlp(', 'L.wlp(') + '\n', n0, words, reads


# ---- the check over any list satisfying the skeleton's facts -------------------------------------------------------------------

CHK = E2E / f'{NAME}_e2e_symdec_chk_generated.bend'
HOLES = {'IT13': 'hb', 'IT21': 'h7'}
DEPTH = 20


def qualify(body, defs):
    """EW-qualified names of the module's own defs in a body"""
    names = set(defs)
    return re.sub(r'(?<![\w.])([A-Za-z_]\w*)\(', lambda m: f'EW.{m.group(1)}(' if m.group(1) in names else m.group(0), body)


def chk_module(with_children=True):
    wmod = OBJ / 'var_winx_BeaconState.bend'
    defs = SD.parse_defs(wmod.read_text())
    n0, words, reads, val = skeleton(defs)
    lines, offs, extra_a = SD.shadow(defs, HOLES)
    ks = [int(n[1:]) for n in offs]
    mine = ['import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vua_rd.bend as UR',
            'import ../proofs/obj/vua.bend as UA', 'import ../proofs/obj/arr_copy.bend as AC', 'import ../proofs/obj/var_winx_BeaconState.bend as EW',
            'import ./e2e_symdec_lib_generated.bend as SL']
    L = SD.win_imports(wmod.read_text(), mine)
    L += ['', writer.header('beacon_state_symbolic_witness'), f'# {NAME}: the window check over the offset words (CHKwS), the offsets read from any word list that holds the skeleton\'s words, '
          'and the checks of the two children that read the tree (the justification bits, the payload header) as parameters', '']
    L += lines
    L.append('')
    hb_expr = qualify(defs['IT13'][2], defs)
    h7_expr = qualify(defs['IT21'][2], defs)
    reads_a = ', '.join(f'EW.O{k}(t, x)' for k in ks)
    L.append('def chk_shadow(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32)')
    L.append(f'    -> {{EW.CHKw(t, x, off, len) == CHKwS(t, x, off, len, {reads_a}, {hb_expr}, {h7_expr}) : Bool}}:')
    L.append('  {==}')
    L.append('')
    D = DEPTH
    rd = {}
    for label, c, R, lo, hi, cc in reads:
        if not label.startswith('o'):
            continue
        k = int(label[1:])
        Q = f'U32.to_nat(U32.shrn({c}, 2n))'
        if R == 0:
            L.append(f'def rd{k}(+d: Nat, +sl: List<&2, U32>, +x: Nat, +hx: {{x == 0n : Nat}}, +hr: {{U32.and({c}, 3) == 0 : U32}}, +h: {{Nat.is_lt({Q}, FD.spec_common__pow2(d)) == True{{}} : Bool}})')
            L.append(f'    -> {{EW.O{k}(AC.segt(d, 0n, sl), x) == FD.flat__nthc(sl, {Q}) : U32}}:')
            L.append(f'  SL.rd_off(d, sl, x, {c}, hx, hr, h)')
            L.append('')
            L.append(f'def e{k}(+sl: List<&2, U32>, +flo: {{FD.flat__nthc(sl, {Q}) == {lo} : U32}}, +h: {{Nat.is_lt({Q}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}})')
            L.append(f'    -> {{EW.O{k}(AC.segt({D}n, 0n, sl), 0n) == {val[k]} : U32}}:')
            L.append(f'  Equal.trans(U32, EW.O{k}(AC.segt({D}n, 0n, sl), 0n), FD.flat__nthc(sl, {Q}), {val[k]}, rd{k}({D}n, sl, 0n, {{==}}, {{==}}, h), flo)')
        else:
            Rn = f'{R}n'
            w0 = f'FD.flat__nthc(sl, {Q})'
            w1 = f'FD.flat__nthc(sl, 1n+{Q})'
            L.append(f'def rd{k}(+d: Nat, +sl: List<&2, U32>, +x: Nat, +hx: {{x == 0n : Nat}}, +hr: {{U32.to_nat(U32.and({c}, 3)) == {Rn} : Nat}}, +hl: {{Nat.is_lt({Rn}, 4n) == True{{}} : Bool}}, +h: {{Nat.is_lt(1n+{Q}, FD.spec_common__pow2(d)) == True{{}} : Bool}})')
            L.append(f'    -> {{EW.O{k}(AC.segt(d, 0n, sl), x) == UA.jn({Rn}, FD.flat__nthc(sl, {Q}), FD.flat__nthc(sl, 1n+{Q})) : U32}}:')
            L.append(f'  SL.rd_off_u(d, sl, x, {c}, {Rn}, hx, hr, hl, h)')
            L.append('')
            L.append(f'def e{k}(+sl: List<&2, U32>, +flo: {{{w0} == {lo} : U32}}, +fhi: {{{w1} == {hi} : U32}}, +h: {{Nat.is_lt(1n+{Q}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}})')
            L.append(f'    -> {{EW.O{k}(AC.segt({D}n, 0n, sl), 0n) == {val[k]} : U32}}:')
            L.append(f'  Equal.trans(U32, EW.O{k}(AC.segt({D}n, 0n, sl), 0n), UA.jn({Rn}, {w0}, {w1}), {val[k]}, rd{k}({D}n, sl, 0n, {{==}}, {{==}}, {{==}}, h),')
            L.append(f'    Equal.trans(U32, UA.jn({Rn}, {w0}, {w1}), UA.jn({Rn}, {lo}, {w1}), {val[k]},')
            L.append(f'      Equal.cong(U32, U32, z => UA.jn({Rn}, z, {w1}), {w0}, {lo}, flo),')
            L.append(f'      Equal.trans(U32, UA.jn({Rn}, {lo}, {w1}), UA.jn({Rn}, {lo}, {hi}), {val[k]}, Equal.cong(U32, U32, z => UA.jn({Rn}, {lo}, z), {w1}, {hi}, fhi), {{==}})))')
        L.append('')
    # chk_from_bs: the check holds of the tree of any list with the skeleton's words, given the two children's results
    t = f'AC.segt({D}n, 0n, sl)'
    params = []
    args = {}
    for label, c, R, lo, hi, cc in reads:
        if not label.startswith('o'):
            continue
        k = int(label[1:])
        Q = f'U32.to_nat(U32.shrn({c}, 2n))'
        params.append(f'+flo{k}: {{FD.flat__nthc(sl, {Q}) == {lo} : U32}}')
        a = [f'flo{k}']
        if R:
            params.append(f'+fhi{k}: {{FD.flat__nthc(sl, 1n+{Q}) == {hi} : U32}}')
            a.append(f'fhi{k}')
            params.append(f'+hh{k}: {{Nat.is_lt(1n+{Q}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}}')
        else:
            params.append(f'+hh{k}: {{Nat.is_lt({Q}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}}')
        a.append(f'hh{k}')
        args[k] = f'e{k}(sl, {", ".join(a)})'
    def subst(body, **kw):
        for var, rep in kw.items():
            body = re.sub(rf'(?<![\w.]){var}(?![\w(])', rep, body)
        return body
    hbT = subst(hb_expr, t=t, x='0n', off='0')
    h7T = subst(h7_expr, t=t, x='0n', off='0')
    L.append(f'def chk_from_bs(+sl: List<&2, U32>, {", ".join(params)}, +hbt: {{{hbT} == True{{}} : Bool}}, +h7t: {{{h7T} == True{{}} : Bool}})')
    L.append(f'    -> {{EW.CHKw({t}, 0n, 0, {n0}) == True{{}} : Bool}}:')

    def S(a):
        return f'CHKwS({t}, 0n, 0, {n0}, {", ".join(a)})'
    cur = [f'EW.O{k}({t}, 0n)' for k in ks] + [hbT, h7T]
    target = [str(val[k]) for k in ks] + ['True{}', 'True{}']
    proofs = [args[k] for k in ks] + ['hbt', 'h7t']
    types = ['U32'] * len(ks) + ['Bool', 'Bool']
    rest = '{==}'
    steps = []
    c2 = list(cur)
    for i in range(len(cur)):
        nxt = c2[:i] + [target[i]] + c2[i + 1:]
        pre = (', '.join(c2[:i]) + ', ') if i else ''
        post = (', ' + ', '.join(c2[i + 1:])) if i + 1 < len(c2) else ''
        steps.append((list(c2), nxt, f'Equal.cong({types[i]}, Bool, z => CHKwS({t}, 0n, 0, {n0}, {pre}z{post}), {cur[i]}, {target[i]}, {proofs[i]})'))
        c2 = nxt
    for fr, to, pr in reversed(steps):
        rest = f'Equal.trans(Bool, {S(fr)}, {S(to)}, True{{}}, {pr}, {rest})'
    L.append(f'  Equal.trans(Bool, EW.CHKw({t}, 0n, 0, {n0}), {S(cur)}, True{{}}, chk_shadow({t}, 0n, 0, {n0}), {rest})')
    return '\n'.join(L) + '\n'


# ---- the two children that read the tree: the justification bits and the payload header ------------------------------------------

HDR = E2E / f'{NAME}_e2e_symdec_hdr_generated.bend'


def hdr_module():
    wmod = OBJ / 'var_winx_BeaconState.bend'
    defs = SD.parse_defs(wmod.read_text())
    n0, words, reads, val = skeleton(defs)
    hx_text = (OBJ / 'var_bytesx_ExecutionPayloadHeader.bend').read_text()
    assert 'def SPOw(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, 256n+180n+x)' in hx_text
    assert 'chk3(U32.is_le(584, len), U32.is_eq(SPOw(t, x), 584), BLW(U32.sub(len, SPOw(t, x))))' in hx_text
    F = val[7]
    D = DEPTH
    mine = ['import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vua_rd.bend as UR',
            'import ../proofs/obj/vua.bend as UA', 'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vbrt.bend as VR',
            'import ../proofs/obj/arr_copy.bend as AC', 'import ../proofs/obj/var_winx_BeaconState.bend as EW', 'import ./e2e_symdec_lib_generated.bend as SL']
    L = SD.win_imports(wmod.read_text(), mine)
    L += ['', writer.header('beacon_state_symbolic_witness'), f'# {NAME}: the check of the justification bits and of the payload header window over the tree of any word list that holds the skeleton\'s words', '']
    t = f'AC.segt({D}n, 0n, sl)'
    lab = {r[0]: r for r in reads}
    # ---- the bits
    _, cb, Rb, lob, hib, _ = lab['bits']
    Qb = f'U32.to_nat(U32.shrn({cb}, 2n))'
    L.append('def add0(+y: Nat) -> {Nat.add(0n, y) == y : Nat}: {==}')
    L.append('')
    L.append(f'def bits_gen(+d: Nat, +sl: List<&2, U32>, +x: Nat, +hx: {{x == U32.to_nat({cb}) : Nat}}, +fb: {{FD.flat__nthc(sl, {Qb}) == {lob} : U32}}, +h: {{Nat.is_lt({Qb}, FD.spec_common__pow2(d)) == True{{}} : Bool}})')
    L.append('    -> {FX_bv4.CHK(AC.segt(d, 0n, sl), x) == True{} : Bool}:')
    tt = 'AC.segt(d, 0n, sl)'
    vx = f'VR.VX({tt}, {cb})'
    byt = f'B.byte_sel(U32.and({cb}, 3), VB.slot({tt}, VR.QX({cb})))'
    L.append(f'  Equal.trans(Bool, FX_bv4.CHK({tt}, x), FX_bv4.CHKv({vx}), True{{}}, Equal.cong(U32, Bool, z => FX_bv4.CHKv(z), FX_bv4.BX({tt}, x), {vx}, Equal.sym(U32, {vx}, FX_bv4.BX({tt}, x), FX_bv4.vx_bx({tt}, {cb}, x, Equal.sym(Nat, x, U32.to_nat({cb}), hx)))),')
    L.append(f'    Equal.trans(Bool, FX_bv4.CHKv({vx}), FX_bv4.CHKv(B.byte_sel(U32.and({cb}, 3), FD.flat__nthc(sl, {Qb}))), True{{}},')
    L.append(f'      Equal.cong(U32, Bool, z => FX_bv4.CHKv(B.byte_sel(U32.and({cb}, 3), z)), VB.slot({tt}, VR.QX({cb})), FD.flat__nthc(sl, {Qb}), SL.slot_seg(d, sl, VR.QX({cb}), h)),')
    L.append(f'      Equal.trans(Bool, FX_bv4.CHKv(B.byte_sel(U32.and({cb}, 3), FD.flat__nthc(sl, {Qb}))), FX_bv4.CHKv(B.byte_sel(U32.and({cb}, 3), {lob})), True{{}},')
    L.append(f'        Equal.cong(U32, Bool, z => FX_bv4.CHKv(B.byte_sel(U32.and({cb}, 3), z)), FD.flat__nthc(sl, {Qb}), {lob}, fb), {{==}})))')
    L.append('')
    L.append(f'def bits_true(+sl: List<&2, U32>, +fb: {{FD.flat__nthc(sl, {Qb}) == {lob} : U32}}, +h: {{Nat.is_lt({Qb}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}})')
    L.append(f'    -> {{FX_bv4.CHK({t}, Nat.add(0n, U32.to_nat({cb}))) == True{{}} : Bool}}:')
    L.append(f'  bits_gen({D}n, sl, Nat.add(0n, U32.to_nat({cb})), add0(U32.to_nat({cb})), fb, h)')
    L.append('')
    # ---- the payload header
    _, cs, Rs, los, his, _ = lab['spo']
    Qs = f'U32.to_nat(U32.shrn({cs}, 2n))'
    L.append(f'def CHKhS(+len: U32, +p: U32) -> Bool: CH7.chk3(U32.is_le(584, len), U32.is_eq(p, 584), CH7.BLW(U32.sub(len, p)))')
    L.append('')
    L.append('def spo_unf(+t: FD.array__Tree<U32>, +y: Nat) -> {CH7.SPOw(t, y) == UR.RWN(t, 436n+y) : U32}: {==}')
    L.append('')
    L.append(f'def pos_rel(+a: U32, +cc: U32, +y: Nat, +hy: {{y == U32.to_nat(a) : Nat}}, +hk: {{U32.to_nat(cc) == 436n : Nat}}, +h: {{Nat.is_lt(Nat.add(436n, U32.to_nat(a)), FD.spec_common__pow2(32n)) == True{{}} : Bool}})')
    L.append('    -> {436n+y == U32.to_nat(U32.add(a, cc)) : Nat}:')
    L.append('  Equal.trans(Nat, 436n+y, Nat.add(U32.to_nat(cc), U32.to_nat(a)), U32.to_nat(U32.add(a, cc)),')
    L.append('    Equal.trans(Nat, 436n+y, Nat.add(436n, U32.to_nat(a)), Nat.add(U32.to_nat(cc), U32.to_nat(a)), Equal.cong(Nat, Nat, z => 436n+z, y, U32.to_nat(a), hy),')
    L.append('      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(a)), 436n, U32.to_nat(cc), Equal.sym(Nat, U32.to_nat(cc), 436n, hk))),')
    L.append('    Equal.sym(Nat, U32.to_nat(U32.add(a, cc)), Nat.add(U32.to_nat(cc), U32.to_nat(a)), VB.add_lt32k(a, cc, 436n, U32.to_nat(a), {==}, hk, h)))')
    L.append('')
    c = f'U32.add({F}, {HEADER_OFFSET_IN})'
    Q = f'U32.to_nat(U32.shrn({c}, 2n))'
    w0 = f'FD.flat__nthc(sl, {Q})'
    w1 = f'FD.flat__nthc(sl, 1n+{Q})'
    jn = f'UA.jn(1n, {w0}, {w1})'
    rt = f'UR.RWN({t}, 436n+y)'
    L.append(f'def spo_gen(+sl: List<&2, U32>, +y: Nat, +hy: {{y == U32.to_nat({F}) : Nat}}, +flo: {{{w0} == {los} : U32}}, +fhi: {{{w1} == {his} : U32}},')
    L.append(f'    +h: {{Nat.is_lt(1n+{Q}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}}, +hadd: {{Nat.is_lt(Nat.add(436n, U32.to_nat({F})), FD.spec_common__pow2(32n)) == True{{}} : Bool}})')
    L.append(f'    -> {{CH7.SPOw({t}, y) == {HEADER_FIXED} : U32}}:')
    L.append(f'  Equal.trans(U32, CH7.SPOw({t}, y), {rt}, {HEADER_FIXED}, spo_unf({t}, y),')
    L.append(f'    Equal.trans(U32, {rt}, UR.RWN({t}, U32.to_nat({c})), {HEADER_FIXED},')
    L.append(f'      Equal.cong(Nat, U32, z => UR.RWN({t}, z), 436n+y, U32.to_nat({c}), pos_rel({F}, {HEADER_OFFSET_IN}, y, hy, {{==}}, hadd)),')
    L.append(f'      Equal.trans(U32, UR.RWN({t}, U32.to_nat({c})), {jn}, {HEADER_FIXED},')
    L.append(f'        Equal.trans(U32, UR.RWN({t}, U32.to_nat({c})), UR.RWN({t}, Nat.add(0n, U32.to_nat({c}))), {jn},')
    L.append(f'          Equal.cong(Nat, U32, z => UR.RWN({t}, z), U32.to_nat({c}), Nat.add(0n, U32.to_nat({c})), Equal.sym(Nat, Nat.add(0n, U32.to_nat({c})), U32.to_nat({c}), add0(U32.to_nat({c})))),')
    L.append(f'          SL.rd_off_u({D}n, sl, 0n, {c}, 1n, {{==}}, {{==}}, {{==}}, h)),')
    L.append(f'        Equal.trans(U32, {jn}, UA.jn(1n, {los}, {w1}), {HEADER_FIXED}, Equal.cong(U32, U32, z => UA.jn(1n, z, {w1}), {w0}, {los}, flo),')
    L.append(f'          Equal.trans(U32, UA.jn(1n, {los}, {w1}), UA.jn(1n, {los}, {his}), {HEADER_FIXED}, Equal.cong(U32, U32, z => UA.jn(1n, {los}, z), {w1}, {his}, fhi), {{==}})))))')
    L.append('')
    # h7_unf generic in x, then the chain
    G = lambda o7, o8: f'CHKhS(U32.sub({o8}, {o7}), CH7.SPOw({t}, Nat.add(U32.to_nat({o7}), 0n)))'
    L.append(f'def h7_unf(+t: FD.array__Tree<U32>, +x: Nat, +off: U32)')
    L.append('    -> {CH7.CHKw(t, EW.XJ7(t, x), EW.FJ7(off, t, x), EW.LJ7(t, x)) == CHKhS(U32.sub(EW.O8(t, x), EW.O7(t, x)), CH7.SPOw(t, Nat.add(U32.to_nat(EW.O7(t, x)), x))) : Bool}: {==}')
    L.append('')
    o7 = f'EW.O7({t}, 0n)'
    o8 = f'EW.O8({t}, 0n)'
    V8 = val[8]
    h7e = f'CH7.CHKw({t}, EW.XJ7({t}, 0n), EW.FJ7(0, {t}, 0n), EW.LJ7({t}, 0n))'
    L.append(f'def h7_true(+sl: List<&2, U32>, +e7: {{{o7} == {F} : U32}}, +e8: {{{o8} == {V8} : U32}}, +flo: {{{w0} == {los} : U32}}, +fhi: {{{w1} == {his} : U32}},')
    L.append(f'    +h: {{Nat.is_lt(1n+{Q}, FD.spec_common__pow2({D}n)) == True{{}} : Bool}}, +hadd: {{Nat.is_lt(Nat.add(436n, U32.to_nat({F})), FD.spec_common__pow2(32n)) == True{{}} : Bool}})')
    L.append(f'    -> {{{h7e} == True{{}} : Bool}}:')
    L.append(f'  Equal.trans(Bool, {h7e}, {G(o7, o8)}, True{{}}, h7_unf({t}, 0n, 0),')
    L.append(f'    Equal.trans(Bool, {G(o7, o8)}, CHKhS(U32.sub({o8}, {F}), CH7.SPOw({t}, Nat.add(U32.to_nat({F}), 0n))), True{{}},')
    L.append(f'      Equal.cong(U32, Bool, z => CHKhS(U32.sub({o8}, z), CH7.SPOw({t}, Nat.add(U32.to_nat(z), 0n))), {o7}, {F}, e7),')
    L.append(f'      Equal.trans(Bool, CHKhS(U32.sub({o8}, {F}), CH7.SPOw({t}, Nat.add(U32.to_nat({F}), 0n))), CHKhS(U32.sub({V8}, {F}), CH7.SPOw({t}, Nat.add(U32.to_nat({F}), 0n))), True{{}},')
    L.append(f'        Equal.cong(U32, Bool, z => CHKhS(U32.sub(z, {F}), CH7.SPOw({t}, Nat.add(U32.to_nat({F}), 0n))), {o8}, {V8}, e8),')
    L.append(f'        Equal.trans(Bool, CHKhS(U32.sub({V8}, {F}), CH7.SPOw({t}, Nat.add(U32.to_nat({F}), 0n))), CHKhS(U32.sub({V8}, {F}), {HEADER_FIXED}), True{{}},')
    L.append(f'          Equal.cong(U32, Bool, z => CHKhS(U32.sub({V8}, {F}), z), CH7.SPOw({t}, Nat.add(U32.to_nat({F}), 0n)), {HEADER_FIXED}, spo_gen(sl, Nat.add(U32.to_nat({F}), 0n), FD.nat__add_zero(U32.to_nat({F})), flo, fhi, h, hadd)), {{==}}))))')
    return '\n'.join(L) + '\n'


# ---- the assembly: the premises of the composed theorems at the skeleton -------------------------------------------------------

ASM = E2E / f'{NAME}_e2e_symdec_asm_generated.bend'


def asm_module():
    wmod = OBJ / 'var_winx_BeaconState.bend'
    defs = SD.parse_defs(wmod.read_text())
    n0, words, reads, val = skeleton(defs)
    KV = kv_text(words)
    M = f'U32.shrn({n0}, 2n)'
    SLt = f'K.ups({KV}, ZR.ZW(U32.to_nat({M})))'
    D = DEPTH
    lab = {r[0]: r for r in reads}
    L = ['import Base', 'import ../proofs/compact/found.bend as FD', 'import ../proofs/obj/spec_fixed.bend as F', 'import ../proofs/obj/arr_copy.bend as AC',
         'import ../proofs/obj/vbuf.bend as VB', f'import ../proofs/obj/var_codec_{NAME[4:]}.bend as DC', 'import ../proofs/obj/var_winx_BeaconState.bend as EW',
         'import ../spec/primitives.bend as SP', 'import ../src/buffer.bend as B', 'import ./e2e_load.bend as L', 'import ./e2e_cap.bend as C',
         'import ./e2e_zero_run_generated.bend as ZR', 'import ./e2e_symdec_sk_lib_generated.bend as K',
         f'import ./{NAME}_e2e_symdec_sk_generated.bend as SK', f'import ./{NAME}_e2e_symdec_chk_generated.bend as CK', f'import ./{NAME}_e2e_symdec_hdr_generated.bend as HD',
         f'import ../types/{NAME}_def_generated.bend as {NAME}_d', f'import ../types/{NAME}_decode_ssz_generated.bend as {NAME}_r',
         '', writer.header('beacon_state_symbolic_witness'),
         f'# {NAME}: the premises of the composed theorems at the offsets-only input (docs/BS_WITNESS_DESIGN.md): hn, hd, hS, h31, hchk, and the decoder\'s acceptance, '
         'the decoded object being the term DC.OBJ(...) (never evaluated). Not importing the decode module e2e/FuluBeaconState_e2e_dec_generated.bend (its '
         'END_TO_END model and bridges): the three bridge lemmas it uses are restated here over the loader and capacity modules.', '']
    bs = f'F.limbs({SLt})'
    t = f'AC.segt({D}n, 0n, {SLt})'
    TT = lambda b, n: f'AC.segt(B.capacity({n}), 0n, L.wlp({b}))'
    DEC = lambda b, n: f'Pair.snd(B.Buf, Maybe<&1, {NAME}_d.{NAME[4:]}>, {NAME}_r.{NAME[4:]}_decode(B.fill_at(B.alloc({n}), 0, {b}), {n}))'
    L.append('def ld2(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {U32.is_le(n, VB.NMAX()) == True{} : Bool})')
    L.append(f'    -> {{B.fill_at(B.alloc(n), 0, bs) == DC.BF({TT("bs", "n")}, n) : B.Buf}}:')
    L.append('  L.bf(bs, n, B.capacity(n), hd, {==}, C.capM_32(n, hS), C.capM_w(bs, n, hn, hS))')
    L.append('')
    L.append('def acc2(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {SP.bytes_domain(bs) == True{} : Bool}, +hS: {U32.is_le(n, VB.NMAX()) == True{} : Bool},')
    L.append(f'    +hchk: {{DC.CHK({TT("bs", "n")}, n) == True{{}} : Bool}})')
    L.append(f'    -> {{{DEC("bs", "n")} == Some{{DC.OBJ(B.capacity(n), {TT("bs", "n")}, n)}} : Maybe<&1, {NAME}_d.{NAME[4:]}>}}:')
    L.append(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc(n), 0, bs), DC.BF({TT("bs", "n")}, n), ld2(bs, n, hn, hd, hS)) : {{Pair.snd(B.Buf, Maybe<&1, {NAME}_d.{NAME[4:]}>, {NAME}_r.{NAME[4:]}_decode(_, n)) == Some{{DC.OBJ(B.capacity(n), {TT("bs", "n")}, n)}} : Maybe<&1, {NAME}_d.{NAME[4:]}>}}')
    L.append(f'  Equal.cong(B.Buf & Maybe<&1, {NAME}_d.{NAME[4:]}>, Maybe<&1, {NAME}_d.{NAME[4:]}>, q => Pair.snd(B.Buf, Maybe<&1, {NAME}_d.{NAME[4:]}>, q), {NAME}_r.{NAME[4:]}_decode(DC.BF({TT("bs", "n")}, n), n), (DC.BF({TT("bs", "n")}, n), Some{{DC.OBJ(B.capacity(n), {TT("bs", "n")}, n)}}),')
    L.append(f'    DC.decode_accept(B.capacity(n), {TT("bs", "n")}, n, L.seg_pf(B.capacity(n), L.wlp(bs)), FD.nat__le_lt_trans(B.capacity(n), 30n, 31n, C.capM_le(n, hS), {{==}}), C.capM_q(n, hS), hS, hchk))')
    L.append('')
    L.append('def chk_tt(+bs: +List<U32>, +n: U32, +sl: List<&2, U32>, +hw: {L.wlp(bs) == sl : List<&2, U32>}, +hc: {B.capacity(n) == ' + f'{D}n' + ' : Nat},')
    L.append(f'    +hk: {{EW.CHKw(AC.segt({D}n, 0n, sl), 0n, 0, n) == True{{}} : Bool}})')
    L.append(f'    -> {{DC.CHK({TT("bs", "n")}, n) == True{{}} : Bool}}:')
    L.append(f'  Equal.trans(Bool, DC.CHK({TT("bs", "n")}, n), EW.CHKw(AC.segt({D}n, 0n, sl), 0n, 0, n), True{{}},')
    L.append(f'    Equal.trans(Bool, DC.CHK({TT("bs", "n")}, n), DC.CHK(AC.segt({D}n, 0n, L.wlp(bs)), n), EW.CHKw(AC.segt({D}n, 0n, sl), 0n, 0, n),')
    L.append(f'      Equal.cong(Nat, Bool, z => DC.CHK(AC.segt(z, 0n, L.wlp(bs)), n), B.capacity(n), {D}n, hc),')
    L.append(f'      Equal.cong(List<&2, U32>, Bool, z => DC.CHK(AC.segt({D}n, 0n, z), n), L.wlp(bs), sl, hw)), hk)')
    L.append('')
    args = []
    for label, c, R, lo, hi, cc in reads:
        if not label.startswith('o'):
            continue
        args.append(f'SK.skf_{label}_lo()')
        k0 = f'U32.shrn({c}, 2n)'
        if R:
            args.append(f'SK.skf_{label}_hi()')
            args.append(f'K.lt_pw_s({k0}, {(1 << D) - 1}, {D}n, {{==}}, {{==}}, {{==}})')
        else:
            args.append(f'K.lt_pw({k0}, {D}n, {{==}}, {{==}})')
    _, cb, Rb, lob, hib, _ = lab['bits']
    Fv = val[7]
    ltw = lambda k: f'K.lt_pw_s(U32.shrn({lab[k][1]}, 2n), {(1 << D) - 1}, {D}n, {{==}}, {{==}}, {{==}})'
    e7 = f'CK.e7({SLt}, SK.skf_o7_lo(), SK.skf_o7_hi(), {ltw("o7")})'
    e8 = f'CK.e8({SLt}, SK.skf_o8_lo(), SK.skf_o8_hi(), {ltw("o8")})'
    hbt = f'HD.bits_true({SLt}, SK.skf_bits_lo(), K.lt_pw(U32.shrn({cb}, 2n), {D}n, {{==}}, {{==}}))'
    h7t = f'HD.h7_true({SLt}, {e7}, {e8}, SK.skf_spo_lo(), SK.skf_spo_hi(), K.lt_pw_s(U32.shrn(U32.add({Fv}, {HEADER_OFFSET_IN}), 2n), {(1 << D) - 1}, {D}n, {{==}}, {{==}}, {{==}}), {{==}})'
    chk = f'CK.chk_from_bs({SLt}, {", ".join(args)}, {hbt}, {h7t})'
    L.append(f'def hchk() -> {{DC.CHK({TT(bs, n0)}, {n0}) == True{{}} : Bool}}:')
    L.append(f'  chk_tt({bs}, {n0}, {SLt}, SK.sk_wlp(), {{==}}, {chk})')
    L.append('')
    L.append(f'def hS() -> {{U32.is_le({n0}, VB.NMAX()) == True{{}} : Bool}}: {{==}}')
    L.append('')
    L.append(f'def h31() -> {{Nat.is_lt(U32.to_nat({n0}), VB.pw(31n)) == True{{}} : Bool}}: K.lt_pwv({n0}, 31n, {{==}}, {{==}})')
    L.append('')
    obj = f'DC.OBJ(B.capacity({n0}), {TT(bs, n0)}, {n0})'
    L.append('# the decoder accepts the skeleton; the decoded object is the term below, never evaluated')
    L.append(f'def accepts() -> {{{DEC(bs, n0)} == Some{{{obj}}} : Maybe<&1, {NAME}_d.{NAME[4:]}>}}:')
    L.append(f'  acc2({bs}, {n0}, SK.sk_len(), SK.sk_dom(), hS(), hchk())')
    return '\n'.join(L) + '\n'


def outputs():
    out = {LIB2: LIB2_IMPORTS + '\n' + writer.header('beacon_state_symbolic_witness') + '\n# the list lemmas of the symbolic BeaconState decode witness (docs/BS_WITNESS_DESIGN.md)\n\n' + LIB2_BODY}
    sk, n0, words, reads = sk_module()
    out[SK] = sk
    out[CHK] = chk_module()
    out[HDR] = hdr_module()
    out[ASM] = asm_module()
    return out


def main():
    out = outputs()
    if '--check' in sys.argv:
        return writer.check(out, 'stale beacon_state_symbolic_witness: ', 'beacon_state_symbolic_witness is current')
    writer.write(out)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
