#!/usr/bin/env python3
"""The decoder laws of the bare PROGRESSIVE bit list (generic form ProgressiveBits,
runtime pbits: O.ok_bitlist(buf, off, len, 0, True{}) / O.bits_in), against
spec/codec.bend's ProgressiveBits (list_encoding at the bits' own length).

    python3 codegen/var_pbits.py [--check] [--no-big]

The BitList[N] development of codegen/var_bits.py with the limit removed: the validator's
bound check is off (big = True), so CHK is: non-empty, a non-zero last byte; the spec's
domain is |bits| <= |bits|; the decoder's storage depth is bounded from the buffer
(vlist.hdz29) and its zero array is big_vvlz.zg (any depth). Writes
proofs/obj/var_pbits_<X>{,_unique,_rej}.bend: ok_eval, decode_accept, decode_none,
decode_spec, decode_unique, decode_reject, for every buffer on a perfect word tree of depth
d < 28 with n <= 4 2^d.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
import var_bits as VB  # noqa: E402
import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports


def names():
    out = []
    specs = (ROOT / 'proofs/obj/generic_specs.bend').read_text()
    src = RR.mono_text('generic')
    for m in re.finditer(r'^def (G\w+)\(\) -> S\.Schema: S\.ProgressiveBits\{\}$', specs, re.M):
        X = m.group(1)
        d = re.search(rf'^def {X}_decode\(buf: B\.Buf, \+size: U32\)[^\n]*\n  \w+\(size, (\w+)_ok\(buf, 0, size\)\)', src, re.M)
        p = d.group(1)
        assert f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: O.ok_bitlist(buf, off, len, 0, True{{}})' in src
        out.append((X, p))
    return out


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
    # no length bound: drop cC, hB, hdzK
    body = cut(body, 'def cC(', 'def c1(')
    body = cut(body, '# n <= @BMAX: the checks bound the length.', 'def NBu(')
    # the reader: the storage depth from the buffer, the zero array symbolically
    body = body.replace(''',
    +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool})
    -> {T.@p_read(BF(t, n), 0, n) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}:''', ''')
    -> {T.@p_read(BF(t, n), 0, n) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}:''')
    body = body.replace('''  +hz = hdzK(d, n, hd, hn, hb)
  +ez = zeros_at(B.words_depth_u(VC.WZ(n)), VL.DZ(n), VD.wdu(VC.WZ(n)), hz)''', '''  +hz = VL.hdz29(d, n, hd, hn)
  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(n))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(n))), VL.DZ(n),
    VD.wdu(VC.WZ(n)), VZG.zg(B.words_depth_u(VC.WZ(n))))''')
    body = body.replace('FD.nat__le_lt_trans(VL.DZ(n), @Kn, 31n, hz, {==})', 'FD.nat__le_lt_trans(VL.DZ(n), 29n, 31n, hz, {==})')
    body = body.replace('rd_go(d, t, n, pf, hd, hn, e1, hB(t, n, e1, cC(t, n, h1, cB(t, n, h1))))', 'rd_go(d, t, n, pf, hd, hn, e1)')
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
    for k, v in [('@Nn', '0n'), ('@N', '0'), ('@X_', f'{X}_'), ('@X(', f'{X}('), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    assert '@' not in body and 'hdzK' not in body and 'hB(' not in body, [l for l in body.split('\n') if '@' in l or 'hB(' in l][:3]
    L = VB.GHEAD + ['import ./big_vvlz.bend as VZG', '', '# GENERATED by codegen/var_pbits.py. Do not edit.',
                    f'# {X}: ProgressiveBits (runtime {p}): the validator, the decoder and the spec relation',
                    '# (see the module docstring of codegen/var_pbits.py).', '']
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
    assert '@' not in body
    L = VB.GHEAD + [f'import ./var_pbits_{X}.bend as DC', '', '# GENERATED by codegen/var_pbits.py. Do not edit.',
                    f'# {X}: every byte string the spec relates to a value passes the validator.', '']
    return '\n'.join(L) + body


def enc_text(X, p):
    """encode_eval / encode_spec: var_bits_enc's sized encoder with the bound N (and the bit
    widths kb, KY, KO it needs) as law parameters under their arithmetic hypotheses."""
    import var_bits_enc as VE
    src = RR.mono_text('generic')
    assert f'def {X}_encode(o: O.Bits) -> O.Bits & B.Buf: {X}_enc_sized({p}_size(o))' in src
    assert f'  {X}_enc_put(n, {p}_putn(O.out_new(n), 0, o))' in src
    OBJ = 'O.Bits{F.array__thaw(U32, T), K}'
    L = VE.NHEAD + ['import ./bitlist_rep.bend as BOb', 'import ./big_vvlz.bend as VZG', '', '# GENERATED by codegen/var_pbits.py. Do not edit.',
                    f'# {X}: ProgressiveBits (runtime {p}), the encoder: {X}_encode of an object O.Bits{{thaw(T), K}}',
                    '# (a well-formed bit object, K <= N for any bound N with the bit widths kb, KY, KO of',
                    '# its arithmetic hypotheses) returns the object and the buffer of an explicit tree, whose',
                    '# K / 8 + 1 bytes are the spec/codec.bend encoding of the object\'s value BO.bview.', '']
    w = L.append
    DO = 'CO.DOK(K)'
    w(f'def OUT(+T: F.array__Tree<U32>, +K: U32) -> F.array__Tree<U32>: DL.OZ({DO}, T, K)')
    w(f'def VAL(+T: F.array__Tree<U32>, +K: U32) -> S.Value: S.BitsValue{{BO.bview({OBJ})}}')
    w('def BY(+T: F.array__Tree<U32>, +K: U32) -> +List<U32>: VS.bt(U32.to_nat(CO.NK(K)), FX.limbs(F.array__slots(U32, OUT(T, K))))')
    w('')
    P = ['+dw: Nat', '+T: F.array__Tree<U32>', '+K: U32', '+N: Nat', '+kb: Nat', '+KY: Nat', '+KO: Nat',
         '+pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}', '+hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}',
         f'+wf: BO.wfb({OBJ})', '+hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}',
         '+hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}', '+hKY: {Nat.is_lt(KY, 31n) == True{} : Bool}', '+hKO: {Nat.is_lt(KO, 31n) == True{} : Bool}',
         '+hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool}',
         '+hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool}',
         '+hNO: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO)) == True{} : Bool}',
         '+hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool}']
    A = ['dw', 'T', 'K', 'N', 'kb', 'KY', 'KO', 'pfT', 'hdw', 'wf', 'hN', 'hkb', 'hKY', 'hKO', 'hNk', 'hNY', 'hNO', 'hcap']
    PS, AS = ', '.join(P), ', '.join(A)
    w(f'def cr({PS}) -> CO.CR({DO}, T, K):')
    w('  +hz = VR.rep_hz(dw, T, K, kb, N, pfT, hkb, hN, hNk, CO.qs_sized(dw, K, kb, N, hkb, hN, hNk, hcap), wf)')
    w('  CO.enc_sized(dw, T, K, kb, KY, KO, N, pfT, hdw, hkb, hKY, hKO, hN, hNk, hNY, hNO, hcap, hz)')
    w('')
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
    w(f'  {{T.{X}_encode({OBJ}) == {RE} : O.Bits & B.Buf}}')
    w(f'def encode_eval({AS}):')
    w(f'  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, T)), (F.array__thaw(U32, T), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, T, pfT)) :')
    w(f'    {{T.{X}_enc_sized(O.bsz_pick(K, _)) == {RE} : O.Bits & B.Buf}}')
    w(f'  %Equal.sym(Bool, {CAP}, True{{}}, CO.capT(K, dw, hdw, hcap)) :')
    w(f'    {{T.{X}_enc_sized(({OBJ}, O.pick(_, U32.add(U32.shrn(K, 3n), 1), 2147483648))) == {RE} : O.Bits & B.Buf}}')
    w(f'  %Equal.sym(Array<U32>, {ZB}, {ZT},')
    w(f'      Equal.trans(Array<U32>, {ZB}, Array.new(U32, {DO}, 0), {ZT},')
    w(f'        F.logic__subst(Nat, z => {{{ZB} == Array.new(U32, z, 0) : Array<U32>}}, U32.to_nat(B.words_depth_u(VC.nwu(CO.NK(K)))), {DO},')
    w(f'          VD.wdu(VC.nwu(CO.NK(K))), VZG.zg(B.words_depth_u(VC.nwu(CO.NK(K))))),')
    w(f'        F.array__new(U32, {DO}, 0))) :')
    w(f'    {{T.{X}_enc_put(CO.NK(K), T.{p}_putn(_, 0, {OBJ})) == {RE} : O.Bits & B.Buf}}')
    w(f'  %Equal.sym({PN}, O.put_bits_n({ZT}, 0, {OBJ}), (F.array__thaw(U32, OUT(T, K)), ({OBJ}, CO.NK(K))), {EV}) :')
    w(f'    {{T.{X}_enc_put(CO.NK(K), _) == {RE} : O.Bits & B.Buf}}')
    w('  {==}')
    w('')
    w("# Those bytes are the spec/codec.bend encoding of the object's value.")
    w('law encode_spec:')
    for q in P:
        w(f'  for {q}')
    w(f'  Decoding.decodes(GS.{X}(), BY(T, K), VAL(T, K))')
    w(f'def encode_spec({AS}):')
    w(f'  +c = cr({AS})')
    w('  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, T)), T, F.array__freeze_thaw(U32, T)) :')
    w(f'    Decoding.decodes(GS.{X}(), BY(T, K), S.BitsValue{{BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, _)))}})')
    MOT = 'Codec.bytes(Codec.one(Bits.encoding(@D, List.append(&2, Bool, CO.BITS(T, K), [True{}])), None{}))'
    w('  %Equal.sym(Bool, Nat.is_le(List.length(&2, Bool, CO.BITS(T, K)), List.length(&2, Bool, CO.BITS(T, K))), True{}, F.nat__le_refl(List.length(&2, Bool, CO.BITS(T, K)))) :')
    w('    {' + MOT.replace('@D', '_') + ' == Some{BY(T, K)} : Maybe<&2, +List<U32>>}')
    w(f'  %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{{}}])), BY(T, K), CO.cr2({DO}, T, K, c)) :')
    w('    {Codec.bytes(Codec.one(Some{_}, None{})) == Some{BY(T, K)} : Maybe<&2, +List<U32>>}')
    w('  {==}')
    return '\n'.join(L) + '\n'


def outputs():
    out = {}
    for X, p in names():
        out[ROOT / f'proofs/obj/var_pbits_{X}.bend'] = dec_text(X, p)
        out[ROOT / f'proofs/obj/var_pbits_{X}_unique.bend'] = VB.gbits_unique(X).replace(f'./var_bits_{X}.bend', f'./var_pbits_{X}.bend').replace('codegen/var_bits.py', 'codegen/var_pbits.py')
        out[ROOT / f'proofs/obj/var_pbits_{X}_rej.bend'] = rej_text(X)
        out[ROOT / f'proofs/obj/var_pbits_{X}_enc.bend'] = enc_text(X, p)
    return out


def main():
    out = outputs()
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('progressive bit-list laws are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
