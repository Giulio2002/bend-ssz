#!/usr/bin/env python3
"""The decoder laws of the bare PROGRESSIVE bit list (generic form ProgressiveBits,
runtime pbits: O.ok_bitlist(buf, off, len, 0, True{}) / O.bits_in), against
spec/codec.bend's ProgressiveBits (list_encoding at the bits' own length).

    python3 codegen/proofs/var/progressive_bit_list_codec_laws.py [--check]

The BitList[N] development of codegen/proofs/var/bit_list_codec_laws.py with the limit removed: the validator's
bound check is off (big = True), so CHK is: non-empty, a non-zero last byte; the spec's
domain is |bits| <= |bits|; the decoder's storage depth is bounded from the buffer
(vlist.hdz29) and its zero array is vvlz.zg (any depth). Writes
proofs/obj/var_pbits_<X>{,_unique,_rej}.bend: ok_eval, decode_accept, decode_none,
decode_spec, decode_unique, decode_reject, for every buffer on a perfect word tree of depth
d < 28 with n <= 4 2^d.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.proofs.var.check_or_write_outputs import finish  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.proofs.var import bit_list_codec_laws as VB  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('progressive_bit_list_codec_laws', globals())


def names():
    out = []
    specs = (ROOT / 'proofs/obj/generic_specs.bend').read_text()
    src = RR.mono_text('generic')
    for m in re.finditer(r'^def (\w+)\(\) -> S\.Schema: S\.ProgressiveBits\{\}$', specs, re.M):
        X = m.group(1)
        d = re.search(rf'^def {X}_decode_in\(buf: B\.Buf, \+size: U32\)[^\n]*\n  \w+\(size, (\w+)_ok\(buf, 0, size\)\)', src, re.M)
        p = d.group(1)
        assert f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: O.ok_bitlist(buf, off, len, 0, True{{}})' in src
        out.append((X, p))
    return out


# the progressive bit list validator's representation bound (src/obj.bend bitlist_pick, big; proofs/obj/vpb29.bend)
LT29 = 'U32.is_lt(U32.sub({L}, 1), 536870912)'


def cut(text, start, end):
    a = text.index(start)
    b = text.index(end, a)
    return text[:a] + text[b:]


def dec_text(X, p):
    body = VB.GBODY + VB.GBODY2
    body = body.replace('O.bsel(False{}, True{}, ', 'O.bsel(True{}, True{}, ')
    body = body.replace(', @N, False{})', ', @N, True{})').replace('(n, @N, False{}, _)', '(n, @N, True{}, _)')
    body = body.replace('# The Bool of the validator\'s checks: non-empty, a non-zero last byte, at most @N bits.',
                        '# The Bool of the validator\'s checks: non-empty, a non-zero last byte (no bound).')
    # no bit limit: drop cC, hB, hdzK (and the storage bounds from the limit); the check's own
    # representation bound (len - 1 < 2^29, cL) bounds the storage instead, at any tree depth
    body = cut(body, 'def cC(', 'def c1(')
    body = body.replace('def c1(', TPL.text('dec_text'), 1)
    body = cut(body, '# n <= @BMAX: the checks bound the length.', 'def NBu(')
    # the reader: the storage depth from the check's bound, the zero array symbolically
    body = body.replace(''',
    +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool})
    -> {T.@p_read(BF(t, n), 0, n) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}:''', ''',
    +h29: {@LT29 == True{} : Bool})
    -> {T.@p_read(BF(t, n), 0, n) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}:''')
    body = body.replace('''  +hz = hdzK(d, n, hd, hn, hb)
  +ez = zeros_at(B.words_depth_u(VC.WZ(n)), VL.DZ(n), VD.wdu(VC.WZ(n)), hz)''', '''  +hz = VP.hdzP(n, M1(n), e1, h29)
  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(n))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(n))), VL.DZ(n),
    VD.wdu(VC.WZ(n)), VZG.zg(B.words_depth_u(VC.WZ(n))))''')
    body = body.replace('FD.nat__le_lt_trans(VL.DZ(n), @Kn, 31n, hz, {==})', 'FD.nat__le_lt_trans(VL.DZ(n), 29n, 31n, hz, {==})')
    body = body.replace('VR.nwleB(d, n, @KBn, {==}, hyB(n, hb), hn), hrgB(n, hb)', 'VR.nwleB(d, n, 30n, {==}, VP.hyP(n, M1(n), e1, h29), hn), VP.hrgP(n, M1(n), e1, h29)')
    body = body.replace('rd_go(d, t, n, pf, hd, hn, e1, hB(t, n, e1, cC(t, n, h1, cB(t, n, h1))))', 'rd_go(d, t, n, pf, hd, hn, e1, cL(t, n, h1, cB(t, n, h1)))')
    # the spec: the domain |bits| <= |bits|
    body = body.replace(''',
    +nz: {U32.is_eq(V(t, n), 0) == False{} : Bool}, +bd: {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> Decoding.decodes(GS.@X(), VW(t, n), VAL(t, n)):''', ''',
    +nz: {U32.is_eq(V(t, n), 0) == False{} : Bool})
    -> Decoding.decodes(GS.@X(), VW(t, n), VAL(t, n)):''')
    body = cut(body, '  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, n)))), U32.to_nat(@N))', '  %Equal.sym(Nat, U32.to_nat(n), 1n+m, e1) :\n    {Codec.encoding_for_legal_type')
    body = body.replace('''  %Equal.sym(Bool, Nat.is_le(List.length(&2, Bool, VBL.bl(W1)), @Nn), True{}, bdx) :''',
                        '''  %Equal.sym(Bool, Nat.is_le(List.length(&2, Bool, VBL.bl(W1)), List.length(&2, Bool, VBL.bl(W1))), True{}, FD.nat__le_refl(List.length(&2, Bool, VBL.bl(W1)))) :''')
    body = body.replace('  spec_go(d, t, n, pf, hd, hn, VR.e1n(n, VR.pos1(n, cA(U32.is_lt(0, n), t, n, hchk))), nz, cC(t, n, h1, nz))',
                        '  spec_go(d, t, n, pf, hd, hn, VR.e1n(n, VR.pos1(n, cA(U32.is_lt(0, n), t, n, hchk))), nz)')
    body = body.replace('bselF(U32.is_eq(V(t, n), 0), O.bsel(True{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))), h)',
                        'bselF(U32.is_eq(V(t, n), 0), O.bsel(True{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))), h)')
    for k, v in [('@LT29', LT29.format(L='n')), ('@Nn', '0n'), ('@N', '0'), ('@X_', f'{X}_'), ('@X(', f'{X}('), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    # the validator's representation bound (O.bitlist_pick with big: the bit count is a U32)
    body = body.replace('O.bsel(True{}, True{}, ', f'O.bsel(True{{}}, {LT29.format(L="n")}, ')
    assert '@' not in body and 'hdzK' not in body and 'hB(' not in body, [l for l in body.split('\n') if '@' in l or 'hB(' in l][:3]
    L = VB.GHEAD + ['import ./vvlz.bend as VZG', 'import ./vpb29.bend as VP', '', '# GENERATED by progressive_bit_list_codec_laws (codegen). Do not edit.',
                    f'# {X}: ProgressiveBits (runtime {p}): the validator, the decoder and the spec relation',
                    '# (see the module docstring of codegen/proofs/var/progressive_bit_list_codec_laws.py).', '']
    return '\n'.join(L) + body


def rej_text(X):
    body = VB.GREJ
    body = body.replace(''',
    +nz: {U32.is_eq(DC.V(t, n), 0) == False{} : Bool}, +bd: {Nat.is_le(DC.BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> {DC.CHK(t, n) == True{} : Bool}:''', ''',
    +nz: {U32.is_eq(DC.V(t, n), 0) == False{} : Bool})
    -> {DC.CHK(t, n) == True{} : Bool}:''')
    body = body.replace('''  %Equal.sym(Bool, U32.is_eq(DC.V(t, n), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(DC.BD(t, n), U32.to_nat(@N)))) == True{} : Bool}
  bd''', '''  %Equal.sym(Bool, U32.is_eq(DC.V(t, n), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(True{}, True{}, Nat.is_le(DC.BD(t, n), U32.to_nat(@N)))) == True{} : Bool}
  {==}''')
    body = body.replace('+bits: +List<Bool>, +hb: {Nat.is_le(List.length(&2, Bool, bits), @Nn) == True{} : Bool}, +pk:',
                        '+bits: +List<Bool>, +pk:')
    body = cut(body, '  # the bit count is 8 m + the high bit, within @N', '  FD.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n)')
    body = body.replace('chk_true(t, n, m, e1, nz, bd)', 'chk_true(t, n, m, e1, nz)')
    body = body.replace('+bits: +List<Bool>, +b: Bool, +eb: {Nat.is_le(List.length(&2, Bool, bits), @Nn) == b : Bool},',
                        '+bits: +List<Bool>, +b: Bool, +eb: {Nat.is_le(List.length(&2, Bool, bits), List.length(&2, Bool, bits)) == b : Bool},')
    body = body.replace('rej_t(d, t, n, pf, hd, hn, hchk, bits, eb, FD.logic__some_inj', 'rej_t(d, t, n, pf, hd, hn, hchk, bits, FD.logic__some_inj')
    body = body.replace('rej_b(d, t, n, pf, hd, hn, hchk, bits, Nat.is_le(List.length(&2, Bool, bits), @Nn), {==}, e)',
                        'rej_b(d, t, n, pf, hd, hn, hchk, bits, Nat.is_le(List.length(&2, Bool, bits), List.length(&2, Bool, bits)), {==}, e)')
    for k, v in [('@Nn', '0n'), ('@N', '0'), ('@X(', f'{X}(')]:
        body = body.replace(k, v)
    # the validator's representation bound: every spec encoding of at most VP.PMAX() bytes is within it
    # (VP.lt29P); longer ones are refused by the object API, so decode_reject takes n <= VP.PMAX()
    body = body.replace('O.bsel(True{}, True{}, ', f'O.bsel(True{{}}, {LT29.format(L="n")}, ')
    old = '''def chk_true(+t: FD.array__Tree<U32>, +n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat},
'''
    assert body.count(old) == 1
    body = body.replace(old, old + '''    +hP: {U32.is_le(n, VP.PMAX()) == True{} : Bool},
''')
    old = '''{O.bsel(_, False{}, O.bsel(True{}, ''' + LT29.format(L='n') + ''', Nat.is_le(DC.BD(t, n), U32.to_nat(0)))) == True{} : Bool}
  {==}'''
    assert body.count(old) == 1, body[body.index('def chk_true'):][:1500]
    body = body.replace(old, old[:-len('{==}')] + 'VP.lt29P(n, m, e1, hP)')
    assert body.count('chk_true(t, n, m, e1, nz)') == 1
    body = body.replace('chk_true(t, n, m, e1, nz)', 'chk_true(t, n, m, e1, hP, nz)')
    HN = '+hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool}'
    assert body.count(HN) == 3
    body = body.replace(HN, HN.replace(', +hchk', ', +hP: {U32.is_le(n, VP.PMAX()) == True{} : Bool}, +hchk'))
    LW = '  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}\n  for +hchk'
    assert body.count(LW) == 1
    body = body.replace(LW, LW.replace('\n  for +hchk', '\n  for +hP: {U32.is_le(n, VP.PMAX()) == True{} : Bool}\n  for +hchk'))
    assert body.count('pf, hd, hn, hchk') == 4, body.count('pf, hd, hn, hchk')
    body = body.replace('pf, hd, hn, hchk', 'pf, hd, hn, hP, hchk')
    assert '@' not in body
    L = VB.GHEAD + [f'import ./var_pbits_{X}.bend as DC', 'import ./vpb29.bend as VP', '', '# GENERATED by progressive_bit_list_codec_laws (codegen). Do not edit.',
                    f'# {X}: every byte string the spec relates to a value passes the validator.', '']
    return '\n'.join(L) + body


def enc_text(X, p):
    """encode_eval / encode_spec: bit_list_encoder_laws's sized encoder with the bound N (and the bit
    widths kb, KY, KO it needs) as law parameters under their arithmetic hypotheses."""
    from codegen.proofs.var import bit_list_encoder_laws as VE
    src = RR.mono_text('generic')
    assert f'def {X}_encode(o: O.Bits) -> O.Bits & B.Buf: {X}_enc_sized({p}_size(o))' in src
    assert f'  {X}_enc_put(n, {p}_putn(O.out_new(n), 0, o))' in src
    OBJ = 'O.Bits{F.array__thaw(U32, T), K}'
    L = VE.NHEAD + ['import ./bitlist_rep.bend as BOb', 'import ./vvlz.bend as VZG', '', '# GENERATED by progressive_bit_list_codec_laws (codegen). Do not edit.',
                    f'# {X}: ProgressiveBits (runtime {p}), the encoder: {X}_encode of an object O.Bits{{thaw(T), K}}',
                    '# (a well-formed bit object, K <= N for any bound N with the bit widths kb, KO of',
                    '# its arithmetic hypotheses) returns the object and the buffer of an explicit tree, whose',
                    '# K / 8 + 1 bytes are the spec/codec.bend encoding of the object\'s value BO.bview.', '']
    w = L.append
    DO = 'CO.DOK(K)'
    for line in TPL.render('enc_text_lines', DO=DO, OBJ=OBJ).split('\n'):
        w(line)
    # any bit count K + 8 <= 2^kb, kb <= 32 (K <= 2^32 - 8): the copy's size comes from K itself (vbitenc.y30)
    P = ['+dw: Nat', '+T: F.array__Tree<U32>', '+K: U32', '+N: Nat', '+kb: Nat', '+KO: Nat',
         '+pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}', '+hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}',
         f'+wf: BO.wfb({OBJ})', '+hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}',
         '+hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}', '+hKO: {Nat.is_lt(KO, 31n) == True{} : Bool}',
         '+hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool}',
         '+hNO: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO)) == True{} : Bool}',
         '+hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool}']
    A = ['dw', 'T', 'K', 'N', 'kb', 'KO', 'pfT', 'hdw', 'wf', 'hN', 'hkb', 'hKO', 'hNk', 'hNO', 'hcap']
    PS, AS = ', '.join(P), ', '.join(A)
    for line in TPL.render('enc_text_lines_2', DO=DO, PS=PS).split('\n'):
        w(line)
    RE = f'({OBJ}, B.Buf{{F.array__thaw(U32, OUT(T, K)), CO.NK(K)}})'
    ZT = f'F.array__thaw(U32, VC.ZT({DO}))'
    EV = f'CO.cr1({DO}, T, K, cr({AS}))'
    PN = 'Array<U32> & (O.Bits & U32)'
    CAP = 'U32.is_le(U32.add(U32.shrn(K, 5n), 1), F.u32__pow2u(dw))'
    ZB = 'B.zeros(B.words_depth_u(VC.nwu(CO.NK(K))))'
    w('# The encoder returns the object and the buffer of the tree OUT, K / 8 + 1 bytes.')
    w('law encode_eval:')
    for q in P:
        w(f'  for {q}')
    for line in TPL.render('enc_text_lines_3', AS=AS, CAP=CAP, DO=DO, EV=EV, OBJ=OBJ, PN=PN, RE=RE, X=X, ZB=ZB, ZT=ZT, p=p).split('\n'):
        w(line)
    for q in P:
        w(f'  for {q}')
    for line in TPL.render('enc_text_lines_4', AS=AS, X=X).split('\n'):
        w(line)
    MOT = 'Codec.bytes(Codec.one(Bits.encoding(@D, List.append(&2, Bool, CO.BITS(T, K), [True{}])), None{}))'
    w('  %Equal.sym(Bool, Nat.is_le(List.length(&2, Bool, CO.BITS(T, K)), List.length(&2, Bool, CO.BITS(T, K))), True{}, F.nat__le_refl(List.length(&2, Bool, CO.BITS(T, K)))) :')
    w('    {' + MOT.replace('@D', '_') + ' == Some{BY(T, K)} : Maybe<&2, +List<U32>>}')
    for line in TPL.render('enc_text_lines_5', DO=DO).split('\n'):
        w(line)
    return '\n'.join(L) + '\n'


def outputs():
    out = {}
    for X, p in names():
        out[ROOT / f'proofs/obj/var_pbits_{X}.bend'] = dec_text(X, p)
        out[ROOT / f'proofs/obj/var_pbits_{X}_unique.bend'] = writer.rebrand(VB.gbits_unique(X).replace(f'./var_bits_{X}.bend', f'./var_pbits_{X}.bend'), 'bit_list_codec_laws', 'progressive_bit_list_codec_laws')
        out[ROOT / f'proofs/obj/var_pbits_{X}_rej.bend'] = rej_text(X)
        out[ROOT / f'proofs/obj/var_pbits_{X}_enc.bend'] = enc_text(X, p)
    return out


def main():
    # accepts '--check' (check_or_write_outputs.finish reads it)
    return finish(outputs(), 'stale: ', 'progressive bit-list laws are current')


if __name__ == '__main__':
    main()
