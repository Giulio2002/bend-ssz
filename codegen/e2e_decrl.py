#!/usr/bin/env python3
"""Generates e2e/e2e_drl_<L>.bend, one per record-list window reader proofs/obj/var_winx_<L>.bend (a list of
fixed-size containers): the decoded list is the storage premise (the encode records' sda: a perfect record tree of
depth below k holding its N records) and the root laws' rep_<L> (that, and N within the schema's limit).

The reader builds the list as LOBJ(len == 0, ...): an empty sequence, or the tree RT of NN(len) records written
into a default tree of depth B.words_depth(NN(len)) (NN = len / record size). Every conversion is shallow: the
depth bound comes from VD.wd_min / wd_cover and the closed fact limit <= 2^KB.

Usage: python3 codegen/e2e_decrl.py [--check]"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OBJ = ROOT / 'proofs' / 'obj'
E2E = ROOT / 'e2e'


def lists():
    out = []
    for f in sorted(OBJ.glob('var_winx_l*.bend')):
        s = f.read_text()
        if not re.search(r'^def RT\(k: Nat, \+j: Nat, \+dd: Nat, D: ', s, re.M) or not re.search(r'^def hcw\(\+len: U32', s, re.M):
            continue   # the boxed-record readers (Array.set, e.g. l16_ProposerSlashing) and l1099511627776_Validator: not yet
        if 'Progressive' in f.stem:
            continue   # the progressive test lists: their rep is not the tree form
        out.append(f)
    return out


def params(f):
    s = f.read_text()
    stem = f.stem[len('var_winx_'):]
    mrt = re.search(r'^def RT\(k: Nat, \+j: Nat, \+dd: Nat, D: FD\.array__Tree<([\w.]+)>', s, re.M)
    T = mrt.group(1)
    m0 = re.search(r'^    case 0n: FD\.array__upd\([\w.]+, dd, D, j, (RX\(t, VRL\.pos\(j, (\d+)n, x\)\))\)$', s, re.M)
    RX, esz = m0.group(1), int(m0.group(2))
    mlo = re.search(r'^def LOBJ\(e: Bool, \+t: FD\.array__Tree<U32>, \+x: Nat, \+len: U32\) -> ([\w.]+):\n'
                    r'  match e:\n    case True\{\}: ([\w.]+)\{([\w.]+)\(0n\), 0\}\n'
                    r'    case False\{\}: [\w.]+\{FD\.array__thaw\([\w.]+, RT\(U32\.to_nat\(U32\.sub\(NN\(len\), 1\)\), 0n, B\.words_depth\(NN\(len\)\), '
                    r'FD\.array__trep\([\w.]+, B\.words_depth\(NN\(len\)\), ([\w.]+\(\))\), t, x\)\), NN\(len\)\}$', s, re.M)
    SEQT, SEQ, FILL, DEF = mlo.group(1), mlo.group(2), mlo.group(3), mlo.group(4)
    lim = int(re.search(r'^def CHKw\(.*\n  Bool\.and\(U32\.is_eq\(len, \(U32\.div\(len, \d+\) \* \d+ : U32\)\), U32\.is_le\(U32\.div\(len, \d+\), (\d+)\)\)', s, re.M).group(1))
    aliases = {a: p for p, a in re.findall(r'^import (\S+) as (\w+)$', s, re.M)}
    need = {T.split('.')[0], SEQT.split('.')[0], DEF.split('.')[0], FILL.split('.')[0]}
    imps = [f'import {aliases[a].replace("../../", "../")} as {a}' for a in sorted(need)]
    kb = 0
    while 2 ** kb < lim:
        kb += 1
    rtl = None
    for m in sorted(OBJ.glob('root_*_light.bend')):
        if re.search(rf'^def xlen_o_{stem}\(', m.read_text(), re.M) and re.search(rf'^def rep_{stem}\(', m.read_text(), re.M):
            rtl = m.name
            break
    return dict(rtl=rtl, stem=stem, T=T, RX=RX, esz=esz, SEQT=SEQT, SEQ=SEQ, FILL=FILL, DEF=DEF, lim=lim, kb=max(kb, 1), imps=imps)


def text(f):
    p = params(f)
    stem, T, SEQT, SEQ, DEF, lim, kb = p['stem'], p['T'], p['SEQT'], p['SEQ'], p['DEF'], p['lim'], p['kb']
    RX = 'W.' + p['RX'].replace('VRL.pos', 'VRL.pos')
    NN = 'W.NN(len)'
    DW = f'B.words_depth({NN})'
    SDA = lambda w, k: (f'DK.Ex(FD.array__Tree<{T}>, tt => DK.Ex(Nat, dw => DK.Ex(U32, N =>\n'
                        f'    DK.P2({{{w} == {SEQ}{{FD.array__thaw({T}, tt), N}} : {SEQT}}},\n'
                        f'    DK.P2({{FD.array__perfect({T}, dw, tt) == True{{}} : Bool}},\n'
                        f'    DK.P2({{Nat.is_lt(dw, {k}) == True{{}} : Bool}},\n'
                        f'          {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}))))))')
    RXj = RX.replace('RX(t, VRL.pos(j,', 'RX(t, VRL.pos(j,')
    imports = ['import Base', 'import ../src/obj.bend as O', 'import ../src/buffer.bend as B', 'import ../types/schema.bend as S',
               'import ../proofs/compact/found.bend as FD', 'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/vdepth.bend as VD',
               'import ../proofs/obj/vrl.bend as VRL', 'import ../proofs/obj/schema_shapes.bend as SH', f'import ../proofs/obj/{p["rtl"]} as RTL',
               f'import ../proofs/obj/{f.name} as W'] + p['imps']
    if lim <= 2 ** 14:
        HL = (f'def hL() -> {{Nat.is_le(U32.to_nat({lim}), O.pow2n({kb}n)) == True{{}} : Bool}}:\n  {{==}}\n')
    else:   # an exact power of two: a U32 equation and u32__pow2u_value, no big number evaluated
        assert lim == 2 ** kb, lim
        HL = (f'def hL() -> {{Nat.is_le(U32.to_nat({lim}), O.pow2n({kb}n)) == True{{}} : Bool}}:\n'
              f'  +e1 = Equal.trans(Nat, U32.to_nat({lim}), FD.spec_common__pow2({kb}n), O.pow2n({kb}n),\n'
              f'    FD.logic__subst(U32, z => {{U32.to_nat(z) == FD.spec_common__pow2({kb}n) : Nat}}, FD.u32__pow2u({kb}n), {lim}, {{==}}, FD.u32__pow2u_value({kb}n, {{==}})), VD.s_pow2_eq({kb}n))\n'
              f'  FD.logic__subst(Nat, z => {{Nat.is_le(z, O.pow2n({kb}n)) == True{{}} : Bool}}, O.pow2n({kb}n), U32.to_nat({lim}), Equal.sym(Nat, U32.to_nat({lim}), O.pow2n({kb}n), e1), FD.nat__le_refl(O.pow2n({kb}n)))\n')
    t = '\n'.join(imports) + f'''

# GENERATED by codegen/e2e_decrl.py. Do not edit.
# The decoded {stem} (proofs/obj/{f.name}: {p['esz']}-byte records, at most {lim}) is the encode records'
# storage premise (sda: a perfect record tree of depth below k) and the root laws' rep_{stem}.

def SDA(w: {SEQT}, +k: Nat) -> Data:
  {SDA('w', 'k')}

# the records the reader writes keep the tree perfect
law rtp:
  for +k: Nat
  for +j: Nat
  for +dd: Nat
  for +D: FD.array__Tree<{T}>
  for +t: FD.array__Tree<U32>
  for +x: Nat
  for +pf: {{FD.array__perfect({T}, dd, D) == True{{}} : Bool}}
  {{FD.array__perfect({T}, dd, W.RT(k, j, dd, D, t, x)) == True{{}} : Bool}}
def rtp(k, j, dd, D, t, x, pf):
  match k:
    case 0n: FD.array__upd_perfect({T}, dd, D, j, {RXj}, pf)
    case 1n+ +q: rtp(q, 1n+j, dd, FD.array__upd({T}, dd, D, j, {RXj}), t, x, FD.array__upd_perfect({T}, dd, D, j, {RXj}, pf))

# at most {lim} = {lim} <= 2^{kb} records
{HL}
def lg(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +k: Nat, +hk: {{Nat.is_lt({kb}n, k) == True{{}} : Bool}},
    +hc: {{Nat.is_le(W.CC(len), U32.to_nat({lim})) == True{{}} : Bool}}) -> SDA(W.LOBJ(c, t, x, len), k):
  match c:
    case True{{}}:
      (FD.array__trep({T}, 0n, {DEF}), (0n, (0, (Equal.cong(Array<{T}>, {SEQT}, z => {SEQ}{{z, 0}}, Array.new({T}, 0n, {DEF}), FD.array__thaw({T}, FD.array__trep({T}, 0n, {DEF})), FD.array__new({T}, 0n, {DEF})),
        (FD.array__trep_perfect({T}, 0n, {DEF}), (FD.nat__le_lt_trans(0n, {kb}n, k, {{==}}, hk), {{==}}))))))
    case False{{}}:
      +h2 = FD.nat__le_trans(W.CC(len), U32.to_nat({lim}), O.pow2n({kb}n), hc, hL())
      (W.RT(U32.to_nat(U32.sub({NN}, 1)), 0n, {DW}, FD.array__trep({T}, {DW}, {DEF}), t, x), ({DW}, ({NN}, ({{==}},
        (rtp(U32.to_nat(U32.sub({NN}, 1)), 0n, {DW}, FD.array__trep({T}, {DW}, {DEF}), t, x, FD.array__trep_perfect({T}, {DW}, {DEF})),
        (FD.nat__le_lt_trans({DW}, {kb}n, k, VD.wd_min({NN}, {kb}n, h2), hk),
          FD.logic__subst(Nat, z => {{Nat.is_le(W.CC(len), z) == True{{}} : Bool}}, O.pow2n({DW}), FD.spec_common__pow2({DW}), Equal.sym(Nat, FD.spec_common__pow2({DW}), O.pow2n({DW}), VD.s_pow2_eq({DW})),
            VD.wd_cover({NN}, {kb}n, {{==}}, h2))))))))

def lm(+c: Bool, +len: U32, +t: FD.array__Tree<U32>, +x: Nat, +hc: {{Nat.is_le(W.CC(len), U32.to_nat({lim})) == True{{}} : Bool}})
    -> {{Nat.is_le(U32.to_nat(RTL.xlen_o_{stem}(W.LOBJ(c, t, x, len))), U32.to_nat({lim})) == True{{}} : Bool}}:
  match c:
    case True{{}}: FD.nat__zero_le(U32.to_nat({lim}))
    case False{{}}: hc

# the decoded list, as the encode records' storage premise (depth below k > {kb})
def sdl(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +k: Nat, +hk: {{Nat.is_lt({kb}n, k) == True{{}} : Bool}},
    +hchk: {{W.CHKw(t, x, off, len) == True{{}} : Bool}}) -> SDA(W.OBJw(d, t, x, off, len), k):
  lg(U32.is_eq(len, 0), len, t, x, k, hk, W.hcw(len, hchk))

# ... and as the root laws' rep_{stem} (its schema's limit {lim})
def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +s: S.Schema, +es: {{SH.ListOf_limit(s) == U32.to_nat({lim}) : Nat}},
    +hchk: {{W.CHKw(t, x, off, len) == True{{}} : Bool}}) -> RTL.rep_{stem}(W.OBJw(d, t, x, off, len), s):
  (sdl(d, t, x, off, len, 32n, {{==}}, hchk),
    FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(RTL.xlen_o_{stem}(W.OBJw(d, t, x, off, len))), z) == True{{}} : Bool}}, U32.to_nat({lim}), SH.ListOf_limit(s),
      Equal.sym(Nat, SH.ListOf_limit(s), U32.to_nat({lim}), es), lm(U32.is_eq(len, 0), len, t, x, W.hcw(len, hchk))))
'''
    return t


def main():
    outs = {E2E / f'e2e_drl_{f.stem[len("var_winx_"):]}.bend': text(f) for f in lists()}
    if '--check' in sys.argv:
        bad = [p.name for p, t in outs.items() if not p.exists() or p.read_text() != t]
        if bad:
            print('stale: ' + ', '.join(bad))
            sys.exit(1)
        print(f'e2e_decrl: up to date ({len(outs)} files)')
        return
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print(f'e2e_decrl: wrote {len(outs)} files')


if __name__ == '__main__':
    main()
