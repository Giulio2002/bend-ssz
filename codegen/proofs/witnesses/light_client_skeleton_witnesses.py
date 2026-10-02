#!/usr/bin/env python3
"""Decode-acceptance witnesses of the light-client names over the offsets-only skeleton: e2e/<Name>_e2e_decode_witness_generated.bend.

The decode witnesses of decoder_acceptance_witnesses.py take the real input, the encoding of the default object, and evaluate the encoder, the byte
domain and the window check over it: minutes (the 25 KB bootstrap) to tens of minutes. Here the input is the same bytes written as what
they are, zero runs and a few non-zero words (the offsets of the default encoding: every list empty, every fixed part zero), as the list

    bs0 = ZB(4 a_0) ++ B(v_0) ++ ZB(4 a_1) ++ B(v_1) ++ ... ++ ZB(4 a_k) ++ []         (ZB: a run of zero bytes, B(v): the 4 bytes of a word)

and nothing is ever evaluated over it. The input's facts are proved by one lemma per segment, from the end (all symbolic in the tail):

  * hn  `length(bs0) == to_nat(n0)`: zr_len for a run, the four conses of a word, and A.add_le for the U32 sum n0 = g_0 + (4 + (g_1 + ...));
  * hd  `bytes_domain(bs0) == True`: zr_dom for a run, a computation on the literal bytes of a word;
  * the loader's words  `wlp(bs0) == ZW(a_0) ++ [v_0] ++ ZW(a_1) ++ ...`: zr_wlp, and a computation on a word (the packed bytes);
  * hchk `CHK(TT(bs0, n0), n0) == True`: the tree TT(bs0, n0) = segt(capacity(n0), 0n, wlp(bs0)) is rewritten over the words and the
    window check is evaluated on that (a tree of the word list: a few thousand words, read at the few offset words);
  * dec: DB.d_acc(..., hchk), the decoded object kept as the term DC.OBJ(...), never evaluated; then the composed decode;encode and
    decode;root theorems at (bs0, n0, DC.OBJ(...)).

The unary Nat of the byte count is never formed (the lengths are U32 sums, `to_nat` of a run is related to its word count by SL.pos_lit),
and no thunk names the input (the checker unfolds a thunk by evaluating it): every statement spells bs0 out. The default encoding is
computed here from codegen/fulu.yaml (SSZ: fixed parts, offsets of the variable fields, the variable parts), and the checker is what
shows it is accepted.

    python3 codegen/proofs/witnesses/light_client_skeleton_witnesses.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

import yaml

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.proofs.witnesses import bridge_premise_witnesses as W  # noqa: E402
from codegen.proofs.witnesses import decoder_acceptance_witnesses as DW  # noqa: E402

E2E = ROOT / 'e2e'
LIB = E2E / 'e2e_skel_lib_generated.bend'

# the names witnessed over the skeleton (decoder_acceptance_witnesses.py leaves them alone)
NAMES = DW.SKEL


# ---- the default object's SSZ encoding, from the schema -----------------------------------------------------------------------

class Schema:
    def __init__(self):
        y = yaml.safe_load((ROOT / 'codegen/fulu.yaml').read_text())
        self.consts = dict(y['constants'])
        self.types = y['types']
        self.prefix = y.get('prefix', '')

    def n(self, expr):
        s = str(expr)

        def floorlog2(x):
            return int(x).bit_length() - 1
        return eval(s.replace('//', '//'), {'__builtins__': {}}, {**self.consts, 'floorlog2': floorlog2})

    def parse(self, t):
        t = str(t).strip()
        m = re.fullmatch(r'(Vector|List)\[(.+), (.+)\]', t)
        if m:
            return (m.group(1).lower(), self.parse(m.group(2)), self.n(m.group(3)))
        m = re.fullmatch(r'(ByteVector|ByteList|Bitvector|Bitlist)\[(.+)\]', t)
        if m:
            return (m.group(1).lower(), None, self.n(m.group(2)))
        if t == 'boolean':
            return ('basic', None, 1)
        m = re.fullmatch(r'uint(\d+)', t)
        if m:
            return ('basic', None, int(m.group(1)) // 8)
        m = re.fullmatch(r'Bytes(\d+)', t)
        if m and t not in self.types:
            return ('basic', None, int(m.group(1)))
        body = self.types.get(t)
        if isinstance(body, str):
            if body == t:
                m = re.fullmatch(r'Bytes(\d+)', t)
                return ('basic', None, int(m.group(1)))
            return self.parse(body)
        if isinstance(body, list):
            return ('container', [(next(iter(f)), self.parse(next(iter(f.values())))) for f in body], None)
        raise SystemExit(f'light_client_skeleton_witnesses: unknown type {t}')

    def fixed(self, ty):
        k = ty[0]
        if k == 'basic':
            return ty[2]
        if k == 'vector':
            f = self.fixed(ty[1])
            return None if f is None else f * ty[2]
        if k == 'bytevector':
            return ty[2]
        if k == 'bitvector':
            return (ty[2] + 7) // 8
        if k == 'container':
            sizes = [self.fixed(f) for _, f in ty[1]]
            return None if None in sizes else sum(sizes)
        return None

    def encode(self, ty):
        """the encoding of the default value (every list empty, every number zero)"""
        f = self.fixed(ty)
        if f is not None:
            return bytearray(f)
        if ty[0] in ('list', 'bytelist'):
            return bytearray()
        if ty[0] == 'bitlist':
            return bytearray([1])
        if ty[0] != 'container':
            raise SystemExit(f'light_client_skeleton_witnesses: no default encoding for {ty[0]}')
        fixed_part, var_parts = bytearray(), []
        fixed_len = sum(self.fixed(ft) if self.fixed(ft) is not None else 4 for _, ft in ty[1])
        slots = []
        for _, ft in ty[1]:
            fs = self.fixed(ft)
            if fs is None:
                slots.append(len(fixed_part))
                fixed_part += bytearray(4)
                var_parts.append(self.encode(ft))
            else:
                fixed_part += bytearray(fs)
        off = fixed_len
        for s, v in zip(slots, var_parts):
            fixed_part[s:s + 4] = off.to_bytes(4, 'little')
            off += len(v)
        return fixed_part + b''.join(var_parts)

    def default_encoding(self, name):
        short = name[len(self.prefix):] if name.startswith(self.prefix) else name
        return bytes(self.encode(self.parse(short)))


def segments(enc):
    """[('z', bytes), ('w', value, [b0..b3]), ..., ('z', bytes)]: the input as zero runs and its non-zero words; every run is a multiple of 4"""
    assert len(enc) % 4 == 0, 'the skeleton must be whole words'
    words = [int.from_bytes(enc[i:i + 4], 'little') for i in range(0, len(enc), 4)]
    out, run = [], 0
    for w in words:
        if w == 0:
            run += 1
        else:
            out.append(('z', 4 * run))
            out.append(('w', w, list(w.to_bytes(4, 'little'))))
            run = 0
    out.append(('z', 4 * run))
    return out



# ---- the lemma library: only what the skeleton needs, from zero_run_lemmas.py and symbolic_decoder_witnesses.py (their own files import the u64 list
# windows and the read lemmas, 20 s of modules the witness does not use) -------------------------------------------------------

LIB_IMPORTS = """import Base
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/vuw.bend as UW
import ../proofs/obj/vcopy.bend as VC
import ../spec/primitives.bend as SP
import ../src/buffer.bend as B
import ./e2e_load.bend as L
"""

# one step of the chain (a zero run or a four-byte word in front of a tail R), each over variables: the tail is a parameter, so nothing is
# compared or evaluated through the concrete bytes behind it
STEP_LEMMAS = r"""
def and_t(+x: Bool, +y: Bool, +hx: {x == True{} : Bool}) -> {Bool.and(x, y) == y : Bool}:
  match x:
    case True{}: {==}
    case False{}: Empty.absurd({Bool.and(x, y) == y : Bool}, FD.logic__false_true(hx))

def dom1(+a: U32, +t: +List<U32>, +h: {U32.is_lt(a, 256) == True{} : Bool}) -> {SP.bytes_domain(Con{a, t}) == SP.bytes_domain(t) : Bool}:
  and_t(U32.is_lt(a, 256), SP.bytes_domain(t), h)

def dom_ws(+b0: U32, +b1: U32, +b2: U32, +b3: U32, +R: +List<U32>, +h0: {U32.is_lt(b0, 256) == True{} : Bool}, +h1: {U32.is_lt(b1, 256) == True{} : Bool},
    +h2: {U32.is_lt(b2, 256) == True{} : Bool}, +h3: {U32.is_lt(b3, 256) == True{} : Bool}, +h: {SP.bytes_domain(R) == True{} : Bool})
    -> {SP.bytes_domain(Con{b0, Con{b1, Con{b2, Con{b3, R}}}}) == True{} : Bool}:
  Equal.trans(Bool, SP.bytes_domain(Con{b0, Con{b1, Con{b2, Con{b3, R}}}}), SP.bytes_domain(Con{b1, Con{b2, Con{b3, R}}}), True{}, dom1(b0, Con{b1, Con{b2, Con{b3, R}}}, h0),
    Equal.trans(Bool, SP.bytes_domain(Con{b1, Con{b2, Con{b3, R}}}), SP.bytes_domain(Con{b2, Con{b3, R}}), True{}, dom1(b1, Con{b2, Con{b3, R}}, h1),
      Equal.trans(Bool, SP.bytes_domain(Con{b2, Con{b3, R}}), SP.bytes_domain(Con{b3, R}), True{}, dom1(b2, Con{b3, R}, h2),
        Equal.trans(Bool, SP.bytes_domain(Con{b3, R}), SP.bytes_domain(R), True{}, dom1(b3, R, h3), h))))

def dom_zs(+m: Nat, +R: +List<U32>, +h: {SP.bytes_domain(R) == True{} : Bool}) -> {SP.bytes_domain(List.append(&2, U32, UW.ZB(m), R)) == True{} : Bool}:
  Equal.trans(Bool, SP.bytes_domain(List.append(&2, U32, UW.ZB(m), R)), SP.bytes_domain(R), True{}, zr_dom(m, R), h)

def wlp_ws(+b0: U32, +b1: U32, +b2: U32, +b3: U32, +R: +List<U32>, +W: List<&2, U32>, +h: {L.wlp(R) == W : List<&2, U32>})
    -> {L.wlp(Con{b0, Con{b1, Con{b2, Con{b3, R}}}}) == Con{B.word_of(b0, b1, b2, b3), W} : List<&2, U32>}:
  Equal.trans(List<&2, U32>, L.wlp(Con{b0, Con{b1, Con{b2, Con{b3, R}}}}), Con{B.word_of(b0, b1, b2, b3), L.wlp(R)}, Con{B.word_of(b0, b1, b2, b3), W}, {==},
    Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{B.word_of(b0, b1, b2, b3), z}, L.wlp(R), W, h))

def wlp_zs(+Q: Nat, +R: +List<U32>, +W: List<&2, U32>, +h: {L.wlp(R) == W : List<&2, U32>})
    -> {L.wlp(List.append(&2, U32, UW.ZB(A.quad(Q)), R)) == List.append(&2, U32, ZW(Q), W) : List<&2, U32>}:
  Equal.trans(List<&2, U32>, L.wlp(List.append(&2, U32, UW.ZB(A.quad(Q)), R)), List.append(&2, U32, ZW(Q), L.wlp(R)), List.append(&2, U32, ZW(Q), W), zr_wlp(Q, R),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => List.append(&2, U32, ZW(Q), z), L.wlp(R), W, h))

def len_ws(+b0: U32, +b1: U32, +b2: U32, +b3: U32, +Nn: U32, +R: +List<U32>, +hl: {List.length(&2, U32, R) == U32.to_nat(Nn) : Nat},
    +ha: {Nat.is_le(Nat.add(U32.to_nat(4), U32.to_nat(Nn)), U32.to_nat((4 + Nn : U32))) == True{} : Bool})
    -> {List.length(&2, U32, Con{b0, Con{b1, Con{b2, Con{b3, R}}}}) == U32.to_nat((4 + Nn : U32)) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, Con{b0, Con{b1, Con{b2, Con{b3, R}}}}), Nat.add(4n, U32.to_nat(Nn)), U32.to_nat((4 + Nn : U32)),
    Equal.cong(Nat, Nat, z => Nat.add(4n, z), List.length(&2, U32, R), U32.to_nat(Nn), hl),
    Equal.sym(Nat, U32.to_nat((4 + Nn : U32)), Nat.add(U32.to_nat(4), U32.to_nat(Nn)), A.add_le(4, Nn, (4 + Nn : U32), ha)))

def len_zs(+g: U32, +Nn: U32, +R: +List<U32>, +hl: {List.length(&2, U32, R) == U32.to_nat(Nn) : Nat},
    +hq: {U32.to_nat(g) == A.quad(U32.to_nat(U32.shrn(g, 2n))) : Nat},
    +ha: {Nat.is_le(Nat.add(U32.to_nat(g), U32.to_nat(Nn)), U32.to_nat((g + Nn : U32))) == True{} : Bool})
    -> {List.length(&2, U32, List.append(&2, U32, UW.ZB(A.quad(U32.to_nat(U32.shrn(g, 2n)))), R)) == U32.to_nat((g + Nn : U32)) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, UW.ZB(A.quad(U32.to_nat(U32.shrn(g, 2n)))), R)), Nat.add(A.quad(U32.to_nat(U32.shrn(g, 2n))), List.length(&2, U32, R)), U32.to_nat((g + Nn : U32)),
    zr_len(A.quad(U32.to_nat(U32.shrn(g, 2n))), R),
    Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(U32.shrn(g, 2n))), List.length(&2, U32, R)), Nat.add(A.quad(U32.to_nat(U32.shrn(g, 2n))), U32.to_nat(Nn)), U32.to_nat((g + Nn : U32)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(U32.shrn(g, 2n))), z), List.length(&2, U32, R), U32.to_nat(Nn), hl),
      Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(U32.shrn(g, 2n))), U32.to_nat(Nn)), Nat.add(U32.to_nat(g), U32.to_nat(Nn)), U32.to_nat((g + Nn : U32)),
        Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(Nn)), A.quad(U32.to_nat(U32.shrn(g, 2n))), U32.to_nat(g), Equal.sym(Nat, U32.to_nat(g), A.quad(U32.to_nat(U32.shrn(g, 2n))), hq)),
        Equal.sym(Nat, U32.to_nat((g + Nn : U32)), Nat.add(U32.to_nat(g), U32.to_nat(Nn)), A.add_le(g, Nn, (g + Nn : U32), ha)))))
"""


def lib_text():
    zr = (E2E / 'e2e_zero_run_generated.bend').read_text()
    from codegen.proofs.witnesses import symbolic_decoder_witnesses as SD

    def grab(text, name):
        m = re.search(rf'^def {name}\(.*?(?=^\S|\Z)', text, re.S | re.M)
        return m.group(0).rstrip()
    zr_defs = [grab(zr, n) for n in ('ZW', 'zr_dom', 'zr_len', 'zr_wlp')]
    pos = grab(SD.LIB_BODY, 'pos_lit')
    return LIB_IMPORTS + '\n' + writer.header('light_client_skeleton_witnesses') + '\n# the zero-run and position lemmas of the skeleton witnesses (copies of zero_run_lemmas.py / symbolic_decoder_witnesses.py)\n\n' + '\n\n'.join(zr_defs + [pos]) + '\n' + STEP_LEMMAS

# ---- the module ---------------------------------------------------------------------------------------------------------------

def module(name):
    enc = Schema().default_encoding(name)
    segs = segments(enc)
    n0 = len(enc)
    cp = E2E / f'{name}_e2e_comp_generated.bend'
    W.Mod.cache.clear()
    cm = W.Mod.get(cp)
    de, dr = f'{name}_e2e_decode_encode', f'{name}_e2e_decode_root'
    _, ceonc, _ = cm.signature(de)
    pe = dict(DW.split_param(p) for p in cm.fullp)
    _, croncl, _ = cm.signature(dr)
    pr = dict(DW.split_param(p) for p in cm.fullp)
    mdec = re.search(r'^\{Pair\.snd\(B\.Buf, Maybe<&1, ([\w.]+)>, (.*?)\) == Some\{o\} : Maybe<&1, [\w.]+>\}$', pe['dec'], re.S)
    menc = re.search(r'\w+\.obytes\(Pair\.snd\([\w.]+, B\.Buf, ([\w.]+\.\w+)\(o\)\)\) == bs', ceonc)
    objr, decr, encr = mdec.group(1), mdec.group(2), menc.group(1)
    DBp, DCp = E2E / f'{name}_e2e_dec_generated.bend', cm.imports['DC']
    dm = W.Mod.get(DBp)
    _, dconcl, _ = dm.signature('d_acc')
    OBJ_TXT = re.search(r'== Some\{(.*)\} : Maybe<&1, [\w.]+>\}$', dconcl, re.S).group(1)
    HK_TXT = dict(DW.split_param(q) for q in dm.fullp)['hchk']

    W.PREFER.clear()
    for pth, al in ((ROOT / 'src/buffer.bend', 'B'), (ROOT / 'src/obj.bend', 'O'), (E2E / 'e2e_support.bend', 'E'),
                    (ROOT / 'proofs/compact/found.bend', 'FD'), (ROOT / 'proofs/compact/arith.bend', 'A'),
                    (ROOT / 'proofs/obj/arr_copy.bend', 'AC'), (ROOT / 'proofs/obj/vuw.bend', 'UW'),
                    (E2E / 'e2e_load.bend', 'L'), (LIB, 'ZR')):
        W.PREFER[pth.resolve()] = al
    c = W.Ctx()
    BA, FD, A, AC, UW, L, ZR, E = (c.alias(p) for p in (ROOT / 'src/buffer.bend', ROOT / 'proofs/compact/found.bend', ROOT / 'proofs/compact/arith.bend',
                                                       ROOT / 'proofs/obj/arr_copy.bend', ROOT / 'proofs/obj/vuw.bend', E2E / 'e2e_load.bend', LIB,
                                                       E2E / 'e2e_support.bend'))
    SL = ZR
    CPa, DBa, DCa, SPa = c.alias(cp), c.alias(DBp), c.alias(DCp), c.alias(cm.imports['SP'])
    lift = lambda t: c.lift(cm, t)
    OBJT, ENC = lift(objr), lift(encr)

    def lst(x, rest):
        return f'List.append(&2, U32, {x}, {rest})'
    k = len(segs)

    def Q(g):                      # the word count of a run of g bytes, as the term to_nat(shrn(g, 2n))
        return f'U32.to_nat(U32.shrn({g}, 2n))'

    def zb(g):
        return f'{UW}.ZB({A}.quad({Q(g)}))'

    def piece(b, rest):
        return f'Con{{{b[0]}, Con{{{b[1]}, Con{{{b[2]}, Con{{{b[3]}, {rest}}}}}}}}}'

    def BS(j):
        if j == k:
            return '[]'
        s = segs[j]
        return lst(zb(s[1]), BS(j + 1)) if s[0] == 'z' else piece(s[2], BS(j + 1))

    def N(j):
        if j == k:
            return '0'
        s = segs[j]
        return f'({s[1] if s[0] == "z" else 4} + {N(j + 1)} : U32)'

    def WD(j):
        if j == k:
            return 'Nil{}'
        s = segs[j]
        return lst(f'{ZR}.ZW({Q(s[1])})', WD(j + 1)) if s[0] == 'z' else f'Con{{{BA}.word_of({", ".join(map(str, s[2]))}), {WD(j + 1)}}}'

    ln = lambda e: f'List.length(&2, U32, {e})'
    defs = []
    for j in reversed(range(k)):
        s = segs[j]
        R, Nn, Wn = BS(j + 1), N(j + 1), WD(j + 1)
        cur = BS(j)
        nj = N(j)
        if s[0] == 'z':
            g = s[1]
            p_len = f'{ZR}.len_zs({g}, {Nn}, {R}, len{j + 1}(), {ZR}.pos_lit({g}, {{==}}), {{==}})'
            p_dom = f'{ZR}.dom_zs({A}.quad({Q(g)}), {R}, dom{j + 1}())'
            p_wlp = f'{ZR}.wlp_zs({Q(g)}, {R}, {Wn}, wlp{j + 1}())'
        else:
            bb = ', '.join(map(str, s[2]))
            p_len = f'{ZR}.len_ws({bb}, {Nn}, {R}, len{j + 1}(), {{==}})'
            p_dom = f'{ZR}.dom_ws({bb}, {R}, {{==}}, {{==}}, {{==}}, {{==}}, dom{j + 1}())'
            p_wlp = f'{ZR}.wlp_ws({bb}, {R}, {Wn}, wlp{j + 1}())'
        defs.append(f'def len{j}() -> {{{ln(cur)} == U32.to_nat({nj}) : Nat}}:\n  {p_len}')
        defs.append(f'def dom{j}() -> {{{SPa}.bytes_domain({cur}) == True{{}} : Bool}}:\n  {p_dom}')
        defs.append(f'def wlp{j}() -> {{{L}.wlp({cur}) == {WD(j)} : List<&2, U32>}}:\n  {p_wlp}')
    base = [f'def len{k}() -> {{{ln("[]")} == U32.to_nat(0) : Nat}}:\n  {{==}}',
            f'def dom{k}() -> {{{SPa}.bytes_domain([]) == True{{}} : Bool}}:\n  {{==}}',
            f'def wlp{k}() -> {{{L}.wlp([]) == Nil{{}} : List<&2, U32>}}:\n  {{==}}']
    # base case first, then from the end to the start
    ordered = base
    by_j = {}
    for d in defs:
        by_j.setdefault(int(re.match(r'def (?:len|dom|wlp)(\d+)', d).group(1)), []).append(d)
    for j in reversed(range(k)):
        ordered += by_j[j]
    bs0, n0e, wd0 = BS(0), N(0), WD(0)
    sub = {'bs': bs0, 'n': n0e}
    cap = f'{BA}.capacity({n0e})'

    def sub_bn(t, mod):
        t = c.lift(mod, t)
        return re.sub(r'(?<![\w.])(bs|n)(?![\w.])', lambda m: sub[m.group(1)], t)
    o = sub_bn(OBJ_TXT, dm)
    dec0 = f'Pair.snd({BA}.Buf, Maybe<&1, {OBJT}>, ' + sub_bn(decr, cm) + ')'
    hs_t = re.sub(r'^\{|\}$', '', sub_bn(pe['hS'], cm))
    hk_t = re.sub(r'^\{|\}$', '', sub_bn(HK_TXT, dm))
    tt = f'{DBa}.TT({bs0}, {n0e})'
    acc_name = f'{name}_e2e_decode_witness_acc()'
    known = {'bs': bs0, 'n': n0e, 'o': o, 'hn': 'len0()', 'hd': 'dom0()', 'hS': 'hS()', 'h31': 'h31()', 'hchk': 'hchk()', 'h': f'{BA}.alloc(0)', 'dec': acc_name}

    def args_of(names):
        miss = [x for x in names if x not in known]
        if miss:
            raise SystemExit(f'light_client_skeleton_witnesses: {name}: no argument for {miss}')
        return ', '.join(known[x] for x in names)
    d_acc_args = args_of([x for x in dict(DW.split_param(q) for q in dm.fullp) if x != 'bs' or True])
    def bound_proof(t):
        """a size bound as the bridge from one U32 compare (n < 2^p), not an evaluation of the Nat power (48 s for 2^29 on a 2 KB input)"""
        m = re.fullmatch(r'Nat\.is_le\(U32\.to_nat\((.*)\), A\.quad\(FD\.spec_common__pow2\((\d+)n\)\)\) == True\{\} : Bool', t, re.S)
        if m and m.group(1) == n0e and int(m.group(2)) + 2 < 32:
            return f'FD.nat__lt_le(U32.to_nat({n0e}), A.quad(FD.spec_common__pow2({m.group(2)}n)), FD.array__lt_bridge({n0e}, {int(m.group(2)) + 2}n, {{==}}, True{{}}, {{==}}))'
        m = re.fullmatch(r'Nat\.is_lt\(U32\.to_nat\((.*)\), \w+\.pw\((\d+)n\)\) == True\{\} : Bool', t, re.S)
        if m and m.group(1) == n0e and int(m.group(2)) < 32:
            return f'FD.array__lt_bridge({n0e}, {m.group(2)}n, {{==}}, True{{}}, {{==}})'
        return '{==}'
    h31_t = re.sub(r'^[{]|[}]$', '', sub_bn(pe['h31'], cm)) if 'h31' in pe else None
    final = [
        f'def hS() -> {{{hs_t}}}:\n  {bound_proof(hs_t)}',
        *([f'def h31() -> {{{h31_t}}}:\n  {bound_proof(h31_t)}'] if h31_t else []),
        f'def hchk() -> {{{hk_t}}}:\n'
        f'  Equal.trans(Bool, {DCa}.CHK({tt}, {n0e}), {DCa}.CHK({AC}.segt({cap}, 0n, {wd0}), {n0e}), True{{}},\n'
        f'    Equal.cong(List<&2, U32>, Bool, z => {DCa}.CHK({AC}.segt({cap}, 0n, z), {n0e}), {L}.wlp({bs0}), {wd0}, wlp0()), {{==}})',
        f'def {name}_e2e_decode_witness_acc() -> {{{dec0} == Some{{{o}}} : Maybe<&1, {OBJT}>}}:\n  {DBa}.d_acc({d_acc_args})',
        f'def {name}_e2e_decode_witness() -> {{{CPa}.isS({dec0}) == True{{}} : Bool}}:\n'
        f'  %Equal.sym(Maybe<&1, {OBJT}>, {dec0}, Some{{{o}}}, {name}_e2e_decode_witness_acc()) : {{{CPa}.isS(_) == True{{}} : Bool}}\n  {{==}}',
    ]
    sub3 = {'bs': bs0, 'n': n0e, 'o': o}
    for tag, law, concl, plist in (('encode', de, ceonc, pe), ('root', dr, croncl, pr)):
        c2 = re.sub(r'(?<![\w.])(bs|n|o)(?![\w.])', lambda m: sub3[m.group(1)], c.lift(cm, concl))
        c2 = re.sub(r'(?<![\w.])h(?=[),])', f'{BA}.alloc(0)', c2)
        final.append(f'def {name}_e2e_decode_witness_{tag}() -> {c2}:\n  {CPa}.{law}({args_of(list(plist))})')
    body = '\n\n'.join(ordered + final)
    head = (W.imports_text(c) + '\n\n' + writer.header('light_client_skeleton_witnesses') + '\n'
            f'# {name}: the decoder accepts the offsets-only skeleton of the default encoding ({n0} bytes: zero runs and {sum(1 for s in segs if s[0] == "w")} non-zero words),\n'
            '# and the composed theorems apply at that input (codegen/proofs/witnesses/light_client_skeleton_witnesses.py)\n\n')
    return head + body + '\n'


def outputs():
    out = {E2E / f'{name}_e2e_decode_witness_generated.bend': module(name) for name in NAMES}
    out[LIB] = lib_text()
    return out


def main():
    out = outputs()
    if '--check' in sys.argv:
        return writer.check(out, 'stale light_client_skeleton_witnesses: ', 'light_client_skeleton_witnesses is current')
    writer.write(out)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
