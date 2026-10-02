#!/usr/bin/env python3
"""Symbolic decoder-acceptance witnesses (docs/BS_WITNESS_DESIGN.md, stage 1): e2e/e2e_symdec_lib_generated.bend and
e2e/<Name>_e2e_symdec_generated.bend.

The decode witnesses of decode_witness.py evaluate the decoder's window check over the real input. Here the check is restated over
the offset words and never evaluated over a tree:

* lib: `rd_seg(d, sl, q)`: the word the window modules read at byte position 4 q of the tree of the word list `sl` is `nthc(sl, q)`
  (for any list and depth, by induction: `slots_segt` and the padded list `ns`), `pos_lit(c)`: a 4-aligned U32 literal as the Nat 4 q
  without ever forming the unary number (the checker overflows comparing 524464 successors; `QX(c) = to_nat(shrn(c, 2n))` stays a term),
  `nthc_zr`: reading past a zero run.
* per name: the window module's check (`proofs/obj/var_winx_<Name>.bend`, `CHKw`) is copied with every offset read `O<k>(t, x)` replaced
  by a U32 parameter `o<k>` (`CHKwS`); `chk_shadow` states `CHKw(t, x, off, len) == CHKwS(t, x, off, len, O0(t, x), ...)` (by
  computation, for any tree) and `chk_from` the check of `n0` bytes holds as soon as the offset words are the skeleton's values, by
  congruence one offset at a time; the children's windows are then of length 0 and reduce without reading the tree.
  The input `bs0` is the skeleton: the bytes of a short list of words (every list empty); the reads, `hn`, `hd`, `hS` are
  small here; the decoder's acceptance is `DB.d_acc(..., chk_from)` and the object `DC.OBJ(...)`, never evaluated.

    python3 codegen/proofs/witnesses/sym_decode.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

E2E = ROOT / 'e2e'
OBJ = ROOT / 'proofs/obj'
LIB = E2E / 'e2e_symdec_lib_generated.bend'

# the names with a symbolic witness (stage 1): name -> the skeleton's words (the input is their 4-byte little-endian bytes)
SKELETONS = {
    'FuluExecutionRequests': [12, 12, 12],
}

LIB_IMPORTS = """import Base
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/arr_copy.bend as AC
import ../proofs/obj/arr_enc.bend as AN
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vua.bend as UA
import ../proofs/obj/vua_rd.bend as UR
import ../proofs/obj/vcopy.bend as VC
import ./e2e_zero_run_generated.bend as ZR
"""

LIB_BODY = r"""
# the words a .. a + n - 1 of a list read at i < n: word a + i
def nthc_ns(+n: Nat, +a: Nat, +sl: List<&2, U32>, +i: Nat, +h: {Nat.is_lt(i, n) == True{} : Bool})
    -> {FD.flat__nthc(AN.ns(n, a, sl), i) == FD.flat__nthc(sl, Nat.add(a, i)) : U32}:
  match n i:
    case 0n _: Empty.absurd({FD.flat__nthc(AN.ns(0n, a, sl), i) == FD.flat__nthc(sl, Nat.add(a, i)) : U32}, FD.nat__lt_zero_absurd(i, h))
    case 1n+ +m 0n: Equal.cong(Nat, U32, z => FD.flat__nthc(sl, z), a, Nat.add(a, 0n), Equal.sym(Nat, Nat.add(a, 0n), a, FD.nat__add_zero(a)))
    case 1n+ +m 1n+ +j:
      Equal.trans(U32, FD.flat__nthc(AN.ns(1n+m, a, sl), 1n+j), FD.flat__nthc(sl, Nat.add(1n+a, j)), FD.flat__nthc(sl, Nat.add(a, 1n+j)),
        nthc_ns(m, 1n+a, sl, j, h),
        Equal.cong(Nat, U32, z => FD.flat__nthc(sl, z), Nat.add(1n+a, j), Nat.add(a, 1n+j), Equal.sym(Nat, Nat.add(a, 1n+j), 1n+Nat.add(a, j), FD.nat__add_succ(a, j))))

# slot i of the tree the loader builds from a word list is word i of the list
def slot_seg(+d: Nat, +sl: List<&2, U32>, +i: Nat, +h: {Nat.is_lt(i, FD.spec_common__pow2(d)) == True{} : Bool})
    -> {VB.slot(AC.segt(d, 0n, sl), i) == FD.flat__nthc(sl, i) : U32}:
  Equal.trans(U32, VB.slot(AC.segt(d, 0n, sl), i), FD.flat__nthc(AN.ns(FD.spec_common__pow2(d), 0n, sl), i), FD.flat__nthc(sl, i),
    Equal.cong(List<&2, U32>, U32, z => FD.flat__nthc(z, i), FD.array__slots(U32, AC.segt(d, 0n, sl)), AN.ns(FD.spec_common__pow2(d), 0n, sl), AN.slots_segt(d, 0n, sl)),
    nthc_ns(FD.spec_common__pow2(d), 0n, sl, i, h))

def d4q(+q: Nat) -> {UR.d4(A.quad(q)) == q : Nat}:
  match q:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, UR.d4(A.quad(p)), p, d4q(p))

def m4q(+q: Nat) -> {UR.m4(A.quad(q)) == 0n : Nat}:
  match q:
    case 0n: {==}
    case 1n+ +p: m4q(p)

# the four-byte read at the aligned position 4 q is word q
def rd_seg(+d: Nat, +sl: List<&2, U32>, +q: Nat, +h: {Nat.is_lt(q, FD.spec_common__pow2(d)) == True{} : Bool})
    -> {UR.RWN(AC.segt(d, 0n, sl), A.quad(q)) == FD.flat__nthc(sl, q) : U32}:
  Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), A.quad(q)), UA.jn(0n, VB.slot(AC.segt(d, 0n, sl), q), VB.slot(AC.segt(d, 0n, sl), 1n+q)), FD.flat__nthc(sl, q),
    Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), A.quad(q)), UA.jn(0n, VB.slot(AC.segt(d, 0n, sl), UR.d4(A.quad(q))), VB.slot(AC.segt(d, 0n, sl), 1n+UR.d4(A.quad(q)))), UA.jn(0n, VB.slot(AC.segt(d, 0n, sl), q), VB.slot(AC.segt(d, 0n, sl), 1n+q)),
      Equal.cong(Nat, U32, z => UA.jn(z, VB.slot(AC.segt(d, 0n, sl), UR.d4(A.quad(q))), VB.slot(AC.segt(d, 0n, sl), 1n+UR.d4(A.quad(q)))), UR.m4(A.quad(q)), 0n, m4q(q)),
      Equal.cong(Nat, U32, z => UA.jn(0n, VB.slot(AC.segt(d, 0n, sl), z), VB.slot(AC.segt(d, 0n, sl), 1n+z)), UR.d4(A.quad(q)), q, d4q(q))),
    slot_seg(d, sl, q, h))

# any U32 position c as 4 q + r with r = to_nat(c .&. 3) a small literal
def pos_split(+c: U32, +r: Nat, +hr: {U32.to_nat(U32.and(c, 3)) == r : Nat})
    -> {U32.to_nat(c) == Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), r) : Nat}:
  Equal.trans(Nat, U32.to_nat(c), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), U32.to_nat(U32.and(c, 3))), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), r), VC.split4(c),
    Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), z), U32.to_nat(U32.and(c, 3)), r, hr))

# the four-byte read at the unaligned position 4 q + r (r < 4) joins words q and q + 1
def rd_seg_u(+d: Nat, +sl: List<&2, U32>, +q: Nat, +r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +h: {Nat.is_lt(1n+q, FD.spec_common__pow2(d)) == True{} : Bool})
    -> {UR.RWN(AC.segt(d, 0n, sl), Nat.add(A.quad(q), r)) == UA.jn(r, FD.flat__nthc(sl, q), FD.flat__nthc(sl, 1n+q)) : U32}:
  Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), Nat.add(A.quad(q), r)), UA.jn(r, VB.slot(AC.segt(d, 0n, sl), q), VB.slot(AC.segt(d, 0n, sl), 1n+q)), UA.jn(r, FD.flat__nthc(sl, q), FD.flat__nthc(sl, 1n+q)),
    Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), Nat.add(A.quad(q), r)), UA.jn(r, VB.slot(AC.segt(d, 0n, sl), UR.d4(Nat.add(A.quad(q), r))), VB.slot(AC.segt(d, 0n, sl), 1n+UR.d4(Nat.add(A.quad(q), r)))), UA.jn(r, VB.slot(AC.segt(d, 0n, sl), q), VB.slot(AC.segt(d, 0n, sl), 1n+q)),
      Equal.cong(Nat, U32, z => UA.jn(z, VB.slot(AC.segt(d, 0n, sl), UR.d4(Nat.add(A.quad(q), r))), VB.slot(AC.segt(d, 0n, sl), 1n+UR.d4(Nat.add(A.quad(q), r)))), UR.m4(Nat.add(A.quad(q), r)), r, UR.m4_eq(q, r, hr)),
      Equal.cong(Nat, U32, z => UA.jn(r, VB.slot(AC.segt(d, 0n, sl), z), VB.slot(AC.segt(d, 0n, sl), 1n+z)), UR.d4(Nat.add(A.quad(q), r)), q, UR.d4_eq(q, r, hr))),
    Equal.trans(U32, UA.jn(r, VB.slot(AC.segt(d, 0n, sl), q), VB.slot(AC.segt(d, 0n, sl), 1n+q)), UA.jn(r, FD.flat__nthc(sl, q), VB.slot(AC.segt(d, 0n, sl), 1n+q)), UA.jn(r, FD.flat__nthc(sl, q), FD.flat__nthc(sl, 1n+q)),
      Equal.cong(U32, U32, z => UA.jn(r, z, VB.slot(AC.segt(d, 0n, sl), 1n+q)), VB.slot(AC.segt(d, 0n, sl), q), FD.flat__nthc(sl, q), slot_seg(d, sl, q, FD.nat__lt_trans(q, 1n+q, FD.spec_common__pow2(d), FD.nat__lt_succ(q), h))),
      Equal.cong(U32, U32, z => UA.jn(r, FD.flat__nthc(sl, q), z), VB.slot(AC.segt(d, 0n, sl), 1n+q), FD.flat__nthc(sl, 1n+q), slot_seg(d, sl, 1n+q, h))))

# reading past a run of zero words: word j + m of (m zeros ++ S) is word j of S (the small operand first: `Nat.add` recurses on its first
# argument, and m is up to 700,000)
def nthc_zr(+m: Nat, +S: List<&2, U32>, +j: Nat) -> {FD.flat__nthc(List.append(&2, U32, ZR.ZW(m), S), Nat.add(j, m)) == FD.flat__nthc(S, j) : U32}:
  match m:
    case 0n: Equal.cong(Nat, U32, z => FD.flat__nthc(S, z), Nat.add(j, 0n), j, FD.nat__add_zero(j))
    case 1n+ +p:
      Equal.trans(U32, FD.flat__nthc(List.append(&2, U32, ZR.ZW(1n+p), S), Nat.add(j, 1n+p)), FD.flat__nthc(List.append(&2, U32, ZR.ZW(1n+p), S), 1n+Nat.add(j, p)), FD.flat__nthc(S, j),
        Equal.cong(Nat, U32, z => FD.flat__nthc(List.append(&2, U32, ZR.ZW(1n+p), S), z), Nat.add(j, 1n+p), 1n+Nat.add(j, p), FD.nat__add_succ(j, p)),
        nthc_zr(p, S, j))

# a 4-aligned U32 as the Nat 4 q, with q = to_nat(shrn(c, 2n)) kept as a term (never expanded: 524464 successors overflow the checker)
def pos_lit(+c: U32, +hr: {U32.and(c, 3) == 0 : U32})
    -> {U32.to_nat(c) == A.quad(U32.to_nat(U32.shrn(c, 2n))) : Nat}:
  Equal.trans(Nat, U32.to_nat(c), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), U32.to_nat(U32.and(c, 3))), A.quad(U32.to_nat(U32.shrn(c, 2n))), VC.split4(c),
    Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), U32.to_nat(U32.and(c, 3))), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), 0n), A.quad(U32.to_nat(U32.shrn(c, 2n))),
      Equal.cong(U32, Nat, z => Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), U32.to_nat(z)), U32.and(c, 3), 0, hr), FD.nat__add_zero(A.quad(U32.to_nat(U32.shrn(c, 2n))))))

# the window modules' offset read at a 4-aligned literal position c, over a tree of a word list, all in terms of variables (no closed term
# whose conversion would expand the unary number of c: a `{==}` between `O_k(t, 0n)` and `RWN(t, to_nat(c))` costs 150 s at c = 2.7 M)
def rd_off(+d: Nat, +sl: List<&2, U32>, +x: Nat, +c: U32, +hx: {x == 0n : Nat}, +hr: {U32.and(c, 3) == 0 : U32},
    +h: {Nat.is_lt(U32.to_nat(U32.shrn(c, 2n)), FD.spec_common__pow2(d)) == True{} : Bool})
    -> {UR.RWN(AC.segt(d, 0n, sl), Nat.add(x, U32.to_nat(c))) == FD.flat__nthc(sl, U32.to_nat(U32.shrn(c, 2n))) : U32}:
  Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), Nat.add(x, U32.to_nat(c))), UR.RWN(AC.segt(d, 0n, sl), A.quad(U32.to_nat(U32.shrn(c, 2n)))), FD.flat__nthc(sl, U32.to_nat(U32.shrn(c, 2n))),
    Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), Nat.add(x, U32.to_nat(c))), UR.RWN(AC.segt(d, 0n, sl), Nat.add(0n, U32.to_nat(c))), UR.RWN(AC.segt(d, 0n, sl), A.quad(U32.to_nat(U32.shrn(c, 2n)))),
      Equal.cong(Nat, U32, z => UR.RWN(AC.segt(d, 0n, sl), Nat.add(z, U32.to_nat(c))), x, 0n, hx),
      Equal.cong(Nat, U32, z => UR.RWN(AC.segt(d, 0n, sl), z), Nat.add(0n, U32.to_nat(c)), A.quad(U32.to_nat(U32.shrn(c, 2n))), pos_lit(c, hr))),
    rd_seg(d, sl, U32.to_nat(U32.shrn(c, 2n)), h))

def rd_off_u(+d: Nat, +sl: List<&2, U32>, +x: Nat, +c: U32, +r: Nat, +hx: {x == 0n : Nat}, +hr: {U32.to_nat(U32.and(c, 3)) == r : Nat},
    +hl: {Nat.is_lt(r, 4n) == True{} : Bool}, +h: {Nat.is_lt(1n+U32.to_nat(U32.shrn(c, 2n)), FD.spec_common__pow2(d)) == True{} : Bool})
    -> {UR.RWN(AC.segt(d, 0n, sl), Nat.add(x, U32.to_nat(c))) == UA.jn(r, FD.flat__nthc(sl, U32.to_nat(U32.shrn(c, 2n))), FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(c, 2n)))) : U32}:
  Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), Nat.add(x, U32.to_nat(c))), UR.RWN(AC.segt(d, 0n, sl), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), r)), UA.jn(r, FD.flat__nthc(sl, U32.to_nat(U32.shrn(c, 2n))), FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(c, 2n)))),
    Equal.trans(U32, UR.RWN(AC.segt(d, 0n, sl), Nat.add(x, U32.to_nat(c))), UR.RWN(AC.segt(d, 0n, sl), Nat.add(0n, U32.to_nat(c))), UR.RWN(AC.segt(d, 0n, sl), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), r)),
      Equal.cong(Nat, U32, z => UR.RWN(AC.segt(d, 0n, sl), Nat.add(z, U32.to_nat(c))), x, 0n, hx),
      Equal.cong(Nat, U32, z => UR.RWN(AC.segt(d, 0n, sl), z), Nat.add(0n, U32.to_nat(c)), Nat.add(A.quad(U32.to_nat(U32.shrn(c, 2n))), r), pos_split(c, r, hr))),
    rd_seg_u(d, sl, U32.to_nat(U32.shrn(c, 2n)), r, hl, h))

# the words at m and m + 1 of (m zeros ++ S), with the small operand first stated once, for a closed m
def nthc_zr0(+m: Nat, +S: List<&2, U32>) -> {FD.flat__nthc(List.append(&2, U32, ZR.ZW(m), S), m) == FD.flat__nthc(S, 0n) : U32}:
  nthc_zr(m, S, 0n)

def nthc_zr1(+m: Nat, +S: List<&2, U32>) -> {FD.flat__nthc(List.append(&2, U32, ZR.ZW(m), S), 1n+m) == FD.flat__nthc(S, 1n) : U32}:
  nthc_zr(m, S, 1n)
"""


# ---- the window module's check, copied over the offset words ----------------------------------------------------------------

DEF = re.compile(r'^def (\w+)\(([^\n]*)\) -> ([^\n]*?): (.*)$')


def parse_defs(text):
    """{name: (params, ret, body)} of the single-line top-level defs of a window module, in order"""
    out = {}
    for line in text.split('\n'):
        m = DEF.match(line)
        if m and not line.rstrip().endswith(':'):
            out[m.group(1)] = (m.group(2), m.group(3), m.group(4))
    return out


def balanced(s, i):
    """index just past the parenthesis group opening at s[i]"""
    d = 0
    for j in range(i, len(s)):
        if s[j] == '(':
            d += 1
        elif s[j] == ')':
            d -= 1
            if d == 0:
                return j + 1
    raise SystemExit('unbalanced')


def shadow(defs):
    """(order, shadow text lines, offsets) of CHKw's closure copied over the offset words"""
    names = set(defs)
    ident = re.compile(r'(?<![\w.])([A-Za-z_]\w*)\(')

    def calls(body):
        return {m.group(1) for m in ident.finditer(body) if m.group(1) in names}
    clo, todo = [], ['CHKw']
    while todo:
        n = todo.pop()
        if n in clo:
            continue
        clo.append(n)
        todo += sorted(calls(defs[n][2]))
    offs = sorted((n for n in clo if re.fullmatch(r'O\d+', n)), key=lambda n: int(n[1:]))
    dep = set(offs)
    ch = True
    while ch:
        ch = False
        for n in clo:
            if n not in dep and calls(defs[n][2]) & dep:
                dep.add(n)
                ch = True
    ks = [n[1:] for n in offs]
    extra_p = ', '.join(f'+o{k}: U32' for k in ks)
    extra_a = ', '.join(f'o{k}' for k in ks)

    def rewrite(body):
        out, i = '', 0
        while i < len(body):
            m = ident.match(body, i)
            if m and m.group(1) in dep:
                nm, j = m.group(1), balanced(body, m.end() - 1)
                if re.fullmatch(r'O\d+', nm):
                    out += 'o' + nm[1:]
                else:
                    out += nm + 'S' + rewrite(body[m.end() - 1:j - 1]) + ', ' + extra_a + ')'
                i = j
            else:
                out += body[i]
                i += 1
        return out
    lines = []
    for n in reversed(clo):
        if n not in dep:       # a def that reads no offset is copied as it is
            p, r, b = defs[n]
            lines.append(f'def {n}({p}) -> {r}: {b}')
    for n in reversed(clo):
        if n in dep and n not in offs:
            p, r, b = defs[n]
            lines.append(f'def {n}S({p}, {extra_p}) -> {r}: {rewrite(b)}')
    return lines, offs, extra_a


def offset_pos(defs, k):
    """(byte position as ('lit', c) for Nat.add(x, U32.to_nat(c)) or ('quad', q) for q*4 as k n+x), of the read O<k>"""
    b = defs[f'O{k}'][2]
    m = re.fullmatch(r'UR\.RWN\(t, Nat\.add\(x, U32\.to_nat\((\d+)\)\)\)', b)
    if m:
        return ('lit', int(m.group(1)))
    m = re.fullmatch(r'UR\.RWN\(t, (?:(\d+)n\+)?x\)', b)
    if m:
        return ('quad', int(m.group(1) or 0))
    raise SystemExit(f'sym_decode: the read {b} is not a form this generator knows')


def word_bytes(ws):
    out = []
    for w in ws:
        out += [(w >> (8 * i)) & 255 for i in range(4)]
    return out


def win_imports(text, mine):
    """the window module's imports (its relative paths rebased to e2e/) and `mine` (import lines whose alias it does not already have)"""
    out, aliases = [], set()
    for line in text.split('\n'):
        m = re.match(r'import (\S+\.bend) as (\w+)$', line)
        if not m:
            continue
        path, al = m.groups()
        if path.startswith('./'):
            path = '../proofs/obj/' + path[2:]
        elif path.startswith('../../'):
            path = '../' + path[6:]
        elif path.startswith('../'):
            path = '../proofs/' + path[3:]
        out.append(f'import {path} as {al}')
        aliases.add(al)
    for line in mine:
        m = re.match(r'import (\S+\.bend) as (\w+)$', line)
        if m is None or m.group(2) not in aliases:
            out.append(line)
    return ['import Base'] + [l for l in out if l != 'import Base']


def name_file(name):
    return E2E / f'{name}_e2e_symdec_generated.bend'


def module(name, words):
    short = name[4:] if name.startswith('Fulu') else name
    wmod = OBJ / f'var_winx_{short}.bend'
    defs = parse_defs(wmod.read_text())
    lines, offs, extra_a = shadow(defs)
    ks = [int(n[1:]) for n in offs]
    bs = word_bytes(words)
    n0 = len(bs)
    assert n0 % 4 == 0
    vals = {}
    pos = {}
    for k in ks:
        kind, c = offset_pos(defs, k)
        q = c // 4 if kind == 'lit' else c // 4  # 'quad': c is already the multiple of 4 as k n+x: 4 per n+
        if kind == 'quad':
            q = c // 4
            c = c  # bytes
        assert c % 4 == 0
        pos[k] = (kind, c, c // 4)
        vals[k] = words[c // 4]
    P = f'{name}'
    mine = ['import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vua_rd.bend as UR',
            f'import ../proofs/obj/var_winx_{short}.bend as EW', f'import ../proofs/obj/var_codec_{short}.bend as DC', 'import ../src/buffer.bend as B',
            'import ../spec/primitives.bend as SP', 'import ./e2e_load.bend as L', 'import ./e2e_support.bend as E', 'import ./e2e_symdec_lib_generated.bend as SL',
            f'import ./{name}_e2e_dec_generated.bend as DB', f'import ./{name}_e2e_comp_generated.bend as COMP',
            f'import ../types/{name}_def_generated.bend as {name}_d', f'import ../types/{name}_encode_ssz_generated.bend as {name}_e',
            f'import ../types/{name}_decode_ssz_generated.bend as {name}_r']
    L = win_imports(wmod.read_text(), mine)
    L += ['', writer.header('sym_decode'),
          f'# {name}: the decode-acceptance witness over the skeleton input, its window check restated over the offset words (docs/BS_WITNESS_DESIGN.md)', '']
    L += lines
    L.append('')
    # chk_shadow
    reads = ', '.join(f'EW.O{k}(t, x)' for k in ks)
    L.append(f'def chk_shadow(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32)')
    L.append(f'    -> {{EW.CHKw(t, x, off, len) == CHKwS(t, x, off, len, {reads}) : Bool}}:')
    L.append('  {==}')
    L.append('')
    # chk_from: len n0, x = 0n, off = 0; the offsets replaced one at a time
    eparams = ', '.join(f'+e{k}: {{EW.O{k}(t, 0n) == {vals[k]} : U32}}' for k in ks)
    L.append(f'def chk_from(+t: FD.array__Tree<U32>, {eparams})')
    L.append(f'    -> {{EW.CHKw(t, 0n, 0, {n0}) == True{{}} : Bool}}:')

    def S(args):
        return f'CHKwS(t, 0n, 0, {n0}, {", ".join(args)})'
    cur = [f'EW.O{k}(t, 0n)' for k in ks]
    target = [str(vals[k]) for k in ks]
    chain = []   # (from args, to args, cong proof)
    for idx, k in enumerate(ks):
        nxt = cur[:idx] + [target[idx]] + cur[idx + 1:]
        pre = ', '.join(cur[:idx])
        post = ', '.join(cur[idx + 1:])
        pre_c = (pre + ', ') if pre else ''
        post_c = (', ' + post) if post else ''
        proof = f'Equal.cong(U32, Bool, z => CHKwS(t, 0n, 0, {n0}, {pre_c}z{post_c}), EW.O{k}(t, 0n), {vals[k]}, e{k})'
        chain.append((list(cur), nxt, proof))
        cur = nxt
    # fold the chain into nested Equal.trans, ending with the computation
    final = f'{S(target)}'
    expr = '{==}'
    # build from the end: trans(A, B, True, step, rest)
    steps = chain
    expr_rest = '{==}'      # CHKwS(target) == True by computation
    for fr, to, proof in reversed(steps):
        expr_rest = f'Equal.trans(Bool, {S(fr)}, {S(to)}, True{{}}, {proof}, {expr_rest})'
    L.append(f'  Equal.trans(Bool, EW.CHKw(t, 0n, 0, {n0}), {S([f"EW.O{k}(t, 0n)" for k in ks])}, True{{}}, chk_shadow(t, 0n, 0, {n0}), {expr_rest})')
    L.append('')
    # the skeleton input and the hypotheses
    L.append(f'def bs0() -> +List<U32>: [{", ".join(str(b) for b in bs)}]')
    L.append('')
    tt = f'DB.TT(bs0(), {n0})'
    cap = f'B.capacity({n0})'
    sl = f'L.wlp(bs0())'
    for k in ks:
        kind, c, q = pos[k]
        if kind == 'quad':
            qexpr = f'{q}n'
            rd = f'SL.rd_seg({cap}, {sl}, {qexpr}, {{==}})'
            L.append(f'def e{k}() -> {{EW.O{k}({tt}, 0n) == {vals[k]} : U32}}:')
            L.append(f'  Equal.trans(U32, EW.O{k}({tt}, 0n), FD.flat__nthc({sl}, {qexpr}), {vals[k]}, {rd}, {{==}})')
        else:
            Q = f'U32.to_nat(U32.shrn({c}, 2n))'
            L.append(f'def e{k}() -> {{EW.O{k}({tt}, 0n) == {vals[k]} : U32}}:')
            L.append(f'  Equal.trans(U32, EW.O{k}({tt}, 0n), FD.flat__nthc({sl}, {Q}), {vals[k]},')
            L.append(f'    Equal.trans(U32, EW.O{k}({tt}, 0n), UR.RWN({tt}, A.quad({Q})), FD.flat__nthc({sl}, {Q}),')
            L.append(f'      Equal.cong(Nat, U32, z => UR.RWN({tt}, z), U32.to_nat({c}), A.quad({Q}), SL.pos_lit({c}, {{==}})), SL.rd_seg({cap}, {sl}, {Q}, {{==}})), {{==}})')
        L.append('')
    args = ', '.join(f'e{k}()' for k in ks)
    L.append(f'def hchk() -> {{DC.CHK({tt}, {n0}) == True{{}} : Bool}}: chk_from({tt}, {args})')
    L.append('')
    obj = f'DC.OBJ({cap}, {tt}, {n0})'
    dec = f'Pair.snd(B.Buf, Maybe<&1, {name}_d.{short}>, {name}_r.{short}_decode(B.fill_at(B.alloc({n0}), 0, bs0()), {n0}))'
    L.append(f'# the decoder accepts the skeleton, and the decoded object is `{obj}`: a term, never evaluated')
    L.append(f'def accepts() -> {{{dec} == Some{{{obj}}} : Maybe<&1, {name}_d.{short}>}}:')
    L.append(f'  DB.d_acc(bs0(), {n0}, {{==}}, {{==}}, {{==}}, hchk())')
    L.append('')
    L.append(f'def decode_encode() -> {{E.obytes(Pair.snd({name}_d.{short}, B.Buf, {name}_e.{short}_encode({obj}))) == bs0() : +List<U32>}}:')
    L.append(f'  COMP.{name}_e2e_decode_encode(bs0(), {n0}, {obj}, {{==}}, {{==}}, {{==}}, accepts())')
    return '\n'.join(L) + '\n'


# the names whose window module is probed at scale: the copied check and one read per offset over a run-structured word list
# `ZW(QX(c_k)) ++ [v]` of depth DEPTH (no unary number of the position is ever formed). The reads of all offsets in ONE list need the
# positions' differences as Nat terms (stage 2).
PROBES = {'FuluBeaconState': 20}


def probe_module(name, depth):
    short = name[4:] if name.startswith('Fulu') else name
    wmod = OBJ / f'var_winx_{short}.bend'
    defs = parse_defs(wmod.read_text())
    lines, offs, extra_a = shadow(defs)
    ks = [int(n[1:]) for n in offs]
    mine = ['import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vua_rd.bend as UR', 'import ../proofs/obj/vua.bend as UA',
            'import ../proofs/obj/arr_copy.bend as AC', f'import ../proofs/obj/var_winx_{short}.bend as EW', 'import ./e2e_zero_run_generated.bend as ZR',
            'import ./e2e_symdec_lib_generated.bend as SL']
    L = win_imports(wmod.read_text(), mine)
    L += ['', writer.header('sym_decode'),
          f'# {name}: the window check copied over the offset words, and every offset read at its byte position over a run-structured list of depth {depth}', '']
    L += lines
    L.append('')
    reads = ', '.join(f'EW.O{k}(t, x)' for k in ks)
    L.append('def chk_shadow(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32)')
    L.append(f'    -> {{EW.CHKw(t, x, off, len) == CHKwS(t, x, off, len, {reads}) : Bool}}:')
    L.append('  {==}')
    L.append('')
    for k in ks:
        kind, c = offset_pos(defs, k)
        assert kind == 'lit'
        R = c % 4
        c4 = c - R
        Q = f'U32.to_nat(U32.shrn({c}, 2n))'
        win = [0] * 8
        for i, b in enumerate(word_bytes([PROBE_VALUE])):
            win[R + i] = b
        lo = sum(win[i] << (8 * i) for i in range(4))
        hi = sum(win[4 + i] << (8 * i) for i in range(4))
        words = f'[{lo}, {hi}]' if R else f'[{lo}]'
        sl = f'List.append(&2, U32, ZR.ZW({Q}), {words})'
        t = f'AC.segt({depth}n, 0n, {sl})'
        if R == 0:
            L.append(f'def rd{k}(+d: Nat, +sl: List<&2, U32>, +x: Nat, +hx: {{x == 0n : Nat}}, +hr: {{U32.and({c}, 3) == 0 : U32}}, +h: {{Nat.is_lt({Q}, FD.spec_common__pow2(d)) == True{{}} : Bool}})')
            L.append(f'    -> {{EW.O{k}(AC.segt(d, 0n, sl), x) == FD.flat__nthc(sl, {Q}) : U32}}:')
            L.append(f'  SL.rd_off(d, sl, x, {c}, hx, hr, h)')
            L.append('')
            L.append(f'def read{k}() -> {{EW.O{k}({t}, 0n) == {PROBE_VALUE} : U32}}:')
            L.append(f'  Equal.trans(U32, EW.O{k}({t}, 0n), FD.flat__nthc({sl}, {Q}), {PROBE_VALUE}, rd{k}({depth}n, {sl}, 0n, {{==}}, {{==}}, {{==}}),')
            L.append(f'    Equal.trans(U32, FD.flat__nthc({sl}, {Q}), FD.flat__nthc({words}, 0n), {PROBE_VALUE}, SL.nthc_zr0({Q}, {words}), {{==}}))')
        else:
            Rn = f'{R}n'
            w0 = f'FD.flat__nthc({sl}, {Q})'
            w1 = f'FD.flat__nthc({sl}, 1n+{Q})'
            jn = f'UA.jn({Rn}, {w0}, {w1})'
            L.append(f'def rd{k}(+d: Nat, +sl: List<&2, U32>, +x: Nat, +hx: {{x == 0n : Nat}}, +hr: {{U32.to_nat(U32.and({c}, 3)) == {Rn} : Nat}}, +hl: {{Nat.is_lt({Rn}, 4n) == True{{}} : Bool}}, +h: {{Nat.is_lt(1n+{Q}, FD.spec_common__pow2(d)) == True{{}} : Bool}})')
            L.append(f'    -> {{EW.O{k}(AC.segt(d, 0n, sl), x) == UA.jn({Rn}, FD.flat__nthc(sl, {Q}), FD.flat__nthc(sl, 1n+{Q})) : U32}}:')
            L.append(f'  SL.rd_off_u(d, sl, x, {c}, {Rn}, hx, hr, hl, h)')
            L.append('')
            L.append(f'def read{k}() -> {{EW.O{k}({t}, 0n) == {PROBE_VALUE} : U32}}:')
            L.append(f'  Equal.trans(U32, EW.O{k}({t}, 0n), {jn}, {PROBE_VALUE}, rd{k}({depth}n, {sl}, 0n, {{==}}, {{==}}, {{==}}, {{==}}),')
            L.append(f'    Equal.trans(U32, {jn}, UA.jn({Rn}, {lo}, {w1}), {PROBE_VALUE},')
            L.append(f'      Equal.cong(U32, U32, z => UA.jn({Rn}, z, {w1}), {w0}, {lo}, Equal.trans(U32, {w0}, FD.flat__nthc({words}, 0n), {lo}, SL.nthc_zr0({Q}, {words}), {{==}})),')
            L.append(f'      Equal.trans(U32, UA.jn({Rn}, {lo}, {w1}), UA.jn({Rn}, {lo}, {hi}), {PROBE_VALUE},')
            L.append(f'        Equal.cong(U32, U32, z => UA.jn({Rn}, {lo}, z), {w1}, {hi}, Equal.trans(U32, {w1}, FD.flat__nthc({words}, 1n), {hi}, SL.nthc_zr1({Q}, {words}), {{==}})), {{==}})))')
        L.append('')
    return '\n'.join(L) + '\n'


PROBE_VALUE = 2737225


def outputs():
    out = {LIB: LIB_IMPORTS + '\n' + writer.header('sym_decode') + '\n# the read lemmas of the symbolic decode witnesses (docs/BS_WITNESS_DESIGN.md)\n' + LIB_BODY}
    for name, words in SKELETONS.items():
        out[name_file(name)] = module(name, words)
    for name, depth in PROBES.items():
        out[name_file(name)] = probe_module(name, depth)
    return out


def main():
    out = outputs()
    if '--check' in sys.argv:
        return writer.check(out, 'stale sym_decode: ', 'sym_decode is current')
    writer.write(out)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
