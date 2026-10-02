#!/usr/bin/env python3
"""The encoder laws of the variable-size names of codegen/proofs/var/single_list_container_codec_laws.py.

For a name X of the family (fixed word-aligned fields around one list of
uint64) this writes, into single_list_container_codec_laws.fname(x, '_enc'),

    encode_eval    for every object whose fixed fields hold the words w_k and
                   whose list is O.Words{thaw(T), N} (T a perfect tree of depth
                   dw < 31 with room for its words, N = 8c, c <= limit),
                   T.X_encode returns the object and the buffer
                   B.Buf{thaw(OUT3), FS + N}, OUT3 an explicit output tree;
    encode_spec    the bytes of that buffer are the spec/codec.bend encoding
                   of the object's value XE(w.., c, slots(T)).

The output tree is the offset word at po, the list's words copied after the
header (VB.mone) and the fixed fields' words written by runs of word writes
(VF.updv); its slots are read back window by window (proofs/obj/venc2.bend).
"""
import re

from codegen.proofs.var import single_list_container_codec_laws as VL
from codegen.proofs.support import large_limit_size_facts as LPW
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('single_list_container_encoder_laws', globals())


def _em_limits(g, x):
    """the list's sizes, the bounds on its powers of two and the limit arithmetic"""
    n, FS, H, po, LIM, lp = x.n, x.FS, x.H, x.po, x.LIM, x.lp
    KO, KK = x.KO, max(x.K, x.KO)
    Tn = f'T.{n}'
    src = RR.mono_text('fulu')
    m = re.search(rf'def {lp}_valid\(o: O\.Words\) -> O\.Words & Bool: O\.words_ok\(o, 0, (\d+), False\{{\}}, 8\)', src)
    if not m or int(m.group(1)) != 8 * LIM:
        raise VL.Skip('list storage check differs')
    LIMB = int(m.group(1))
    PB = (8 * LIM).bit_length()
    P2 = (31 + FS + 8 * LIM).bit_length()
    assert PB <= 31 and P2 < 31 and KO < 29

    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, LIMN, YS = VL.spec_parts(g, x, lambda k: f'w{k}')
    # The closed facts about the limit: `{==}` for a small limit, symbolic (codegen/proofs/support/large_limit_size_facts.py) for 2^p.
    LP = LPW.LimPow(LIMN)
    q = (8 * LIM).bit_length() - 1
    if LP.big:
        X8 = LP.x8()
        assert PB == q + 1 and P2 == q + 1
        BS = 1 << (q + 1)
        K_PB = LP.lt(X8, PB)
        K_ES = LP.le_u32(LP.add(FS, X8), q + 1)
        K_YN = LP.le(LP.add(31, X8), P2)
        K_YS = LP.le(LP.add(31, LP.add(FS, X8)), P2)
        MKO = f'Nat.add({H}n, Nat.double({LIMN}))'
        K_KO = LP.le_pow2n(LP.add(H, LP.dbl()), KO)
        K_LB = LP.le_u32(X8, q)
        K_FIT = LP.fits(LP.add(FS, X8), q + 1)
    else:
        BS = FS + LIMB
        K_PB = K_ES = K_YN = K_YS = K_KO = K_LB = K_FIT = '{==}'
        MKO = f'{H}n+Nat.double({LIMN})'
    return n, FS, H, po, lp, KO, KK, Tn, LIMB, PB, P2, ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, LIMN, YS, LP, BS, K_PB, K_ES, K_YN, K_YS, MKO, K_KO, K_LB, K_FIT


def _em_names(x, n, FS, H, po, Tn, hdr, LIMN, LP):
    """the module header and the name bundles: parameters, objects, trees and the type definitions"""
    ks = [k for k in range(H) if k != po]
    WS = ', '.join(f'+w{k}: U32' for k in ks)
    WA = ', '.join(f'w{k}' for k in ks)
    fixed = [f for f in x.fields if f['kind'] == 'fix']

    def V(f):
        return '[' + ', '.join(f'w{f["k"] + j}' for j in range(f['ft'].W)) + ']'

    def fobj(f):
        return f['ft'].obj([f'w{f["k"] + j}' for j in range(f['ft'].W)])
    objs = [fobj(f) if f['kind'] == 'fix' else 'O.Words{FD.array__thaw(U32, T), N}' for f in x.fields]
    OBJ = f'{Tn}{{' + ', '.join(objs) + '}'
    FIXOBJS = ', '.join(fobj(f) for f in fixed)
    WORDS = 'O.Words{FD.array__thaw(U32, T), N}'
    NC = '+N: U32, +c: Nat, +ec: {U32.to_nat(N) == VS.x8(c) : Nat}, +hc: {Nat.is_le(c, ' + LIMN + ') == True{} : Bool}'
    NCa = 'N, c, ec, hc'
    ALLP = (f'{WS}, +dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +c: Nat,\n'
            '    +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},\n'
            '    +ec: {U32.to_nat(N) == VS.x8(c) : Nat}, +hc: {Nat.is_le(c, ' + LIMN + ') == True{} : Bool},\n'
            '    +hroom: {Nat.is_le(Nat.add(VC.NW(N), 0n), VB.pw(dw)) == True{} : Bool}')
    ALLa = f'{WA}, dw, T, N, c, pfT, hdw, ec, hc, hroom'
    TD = lambda j: f'TD{j}({WA}, N, T)'  # noqa: E731
    OUT3 = TD(len(fixed))
    S3 = f'FD.array__slots(U32, {OUT3})'
    ST = 'FD.array__slots(U32, T)'
    HDR = ' <> '.join(hdr)
    HDRL = '[' + ', '.join(hdr) + ']'
    NW = 'VC.NW(N)'
    toN = 'U32.to_nat(N)'
    M = 'Maybe<&2, +List<U32>>'
    MP = 'Maybe<&2, +List<S.Part>>'
    L = list(VL.DEC_HEAD) + ['import ./venc.bend as VE', 'import ./venc2.bend as V2', f'import ./{VL.fname(x).name} as DC'] + LP.imports() + VL.SPEC_IMPORTS + ['',
                             '# GENERATED by single_list_container_encoder_laws (codegen). Do not edit.',
                             f'# The encoder of {n}: for every object whose list storage is a perfect tree T',
                             f'# holding N = 8c bytes (c <= limit) with room for them, the encoder returns the',
                             f'# object and B.Buf{{thaw(OUT3), {FS} + N}} (encode_eval), and the bytes of that',
                             '# buffer are the spec/codec.bend encoding of the object\'s value (encode_spec).', '']
    w = L.append
    TREES = [f'def SFS(+N: U32) -> U32: U32.add({FS}, N)',
             'def DO(+N: U32) -> Nat: B.words_depth(VC.nwu(SFS(N)))',
             f'def OUT1(+N: U32) -> FD.array__Tree<U32>: FD.array__upd(U32, DO(N), VC.ZT(DO(N)), {po}n, {FS})',
             f'def OUT2(+N: U32, +T: FD.array__Tree<U32>) -> FD.array__Tree<U32>: VB.mone(VC.NW(N), 0n, {H}n, DO(N), OUT1(N), T)',
             f'def TD0({WS}, +N: U32, +T: FD.array__Tree<U32>) -> FD.array__Tree<U32>: OUT2(N, T)']
    for j, f in enumerate(fixed):
        TREES.append(f'def TD{j + 1}({WS}, +N: U32, +T: FD.array__Tree<U32>) -> FD.array__Tree<U32>: VF.updv({V(f)}, DO(N), {TD(j)}, {f["k"]}n)')
    w('\n'.join(TREES))
    return WS, WA, fixed, V, fobj, OBJ, FIXOBJS, WORDS, NC, NCa, ALLP, ALLa, TD, OUT3, S3, ST, HDR, HDRL, NW, toN, M, MP, L, w


def _em_object_laws(FS, H, po, KO, Tn, PB, P2, LIMN, BS, K_PB, K_ES, K_YN, K_YS, MKO, K_KO, WS, WA, fixed, V, OBJ, FIXOBJS, NC, NCa, ALLP, TD, toN, w):
    """the offsets, the output trees and the laws of their words"""
    w(TEMPLATES.render('_em_object_laws', NC=NC, toN=toN, LIMN=LIMN, FS=FS, PB=PB, NCa=NCa, K_PB=K_PB, BS=BS, K_ES=K_ES, P2=P2, K_YN=K_YN, K_YS=K_YS, H=H, KO=KO, MKO=MKO, K_KO=K_KO, po=po, WS=WS, TD=TD))
    for j, f in enumerate(fixed):
        w(f'def pfD{j + 1}({WS}, +N: U32, +T: FD.array__Tree<U32>) -> {{FD.array__perfect(U32, DO(N), {TD(j + 1)}) == True{{}} : Bool}}:')
        w(f'  VF.updv_perfect({V(f)}, DO(N), {TD(j)}, {f["k"]}n, pfD{j}({WA}, N, T))')

    def hb(f):
        return f'hbk(Nat.add({f["ft"].W}n, {f["k"]}n), {NCa}, {{==}})'

    # ---- size and put ----
    RS = f'({OBJ}, SFS(N))'
    w(TEMPLATES.render('_em_object_laws_2', ALLP=ALLP, Tn=Tn, OBJ=OBJ, RS=RS, FIXOBJS=FIXOBJS, FS=FS, NCa=NCa))
    return hb, RS


def _em_put_eval(FS, H, po, lp, Tn, LIMB, LIMN, K_LB, WA, fixed, fobj, OBJ, FIXOBJS, WORDS, NCa, ALLP, TD, OUT3, toN, w, hb):
    """put_eval: the runtime's put against the model"""
    RP = f'(FD.array__thaw(U32, {OUT3}), ({OBJ}, SFS(N)))'
    TP = f'Array<U32> & ({Tn} & U32)'

    def puts(j, inner):
        """The runtime's nested puts of fixed fields j.. around `inner`."""
        t = inner
        for f in fixed[j:]:
            t = f'T.{f["ft"].p}_put({t}, U32.add(0, {f["c"]}), {fobj(f)})'
        return t
    w(f'def put_eval({ALLP})')
    w(f'    -> {{{Tn}_putn(FD.array__thaw(U32, VC.ZT(DO(N))), 0, {OBJ}) == {RP} : {TP}}}:')
    w(f'  +hd31 = hDO31({NCa})')
    w(f'  +hd32 = VB.lt32(DO(N), hd31)')
    w(f'  +hd29 = hDO29({NCa})')
    w(f'  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, VC.ZT(DO(N))), {po}, {FS}), FD.array__thaw(U32, OUT1(N)),')
    w(f'      VB.set_n(DO(N), VC.ZT(DO(N)), {po}, {po}n, {FS}, {{==}}, hd32, ltH({po}n, {NCa}, {{==}}), pf0(N))) :')
    w(f'    {{{Tn}_pw0(0, {FIXOBJS}, T.{lp}_pvb({FS}, T.{lp}_pk(_, U32.add(0, {FS}), T.{lp}_valid({WORDS})))) == {RP} : {TP}}}')
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({WORDS}, 0, {LIMB}, False{{}}, 8), ({WORDS}, True{{}}),')
    w(f'      VE.words_ok_u64(dw, T, N, {LIMB}, c, pfT, hdw, ec, FD.nat__le_trans({toN}, VS.x8({LIMN}), U32.to_nat({LIMB}), leN({NCa}), {K_LB}), hroom)) :')
    w(f'    {{{Tn}_pw0(0, {FIXOBJS}, T.{lp}_pvb({FS}, T.{lp}_pk(FD.array__thaw(U32, OUT1(N)), U32.add(0, {FS}), _))) == {RP} : {TP}}}')
    w(f'  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, OUT1(N)), U32.add(0, {FS}), {WORDS}), (FD.array__thaw(U32, OUT2(N, T)), {WORDS}),')
    w(f'      VE.put_words_ok(DO(N), dw, OUT1(N), T, U32.add(0, {FS}), {H}n, N, pf1(N), pfT, hd31, hdw, {{==}}, {{==}}, VC.and3_x8(N, c, ec), hroom, hdst({NCa}))) :')
    w(f'    {{{Tn}_pw0(0, {FIXOBJS}, T.{lp}_pvb({FS}, O.pwn(_))) == {RP} : {TP}}}')
    w(f'  %Equal.sym(U32, O.padd({FS}, N), SFS(N), padd({NCa})) :')
    w(f'    {{({puts(0, "FD.array__thaw(U32, OUT2(N, T))")}, ({OBJ}, _)) == {RP} : {TP}}}')
    for j, f in enumerate(fixed):
        ft = f['ft']
        cur = f'T.{ft.p}_put(FD.array__thaw(U32, {TD(j)}), U32.add(0, {f["c"]}), {fobj(f)})'
        ws = ', '.join(f'w{f["k"] + i}' for i in range(ft.W))
        w(f'  %Equal.sym(Array<U32>, {cur}, FD.array__thaw(U32, {TD(j + 1)}),')
        w(f'      VT.put_{ft.p}(DO(N), {TD(j)}, U32.add(0, {f["c"]}), {f["k"]}n, {{==}}, hd29, pfD{j}({WA}, N, T), {hb(f)}, {ws})) :')
        w(f'    {{({puts(j + 1, "_")}, ({OBJ}, SFS(N))) == {RP} : {TP}}}')
    w('  {==}')
    return RP, TP


def _em_encode_eval(FS, KO, KK, Tn, WS, WA, OBJ, NC, NCa, ALLP, ALLa, OUT3, w, RS, RP, TP):
    """encode_eval: the encoder returns the object and the output tree's buffer"""
    RE = f'({OBJ}, B.Buf{{FD.array__thaw(U32, {OUT3}), SFS(N)}})'
    TE = f'{Tn} & B.Buf'
    w(TEMPLATES.render('_em_encode_eval', FS=FS, ALLP=ALLP, Tn=Tn, OBJ=OBJ, RE=RE, TE=TE, RS=RS, ALLa=ALLa, KO=KO, KK=KK, NCa=NCa, TP=TP, RP=RP))
    # ---- the output's words, window by window ----
    SP = f'{WS}, {NC}, +T: FD.array__Tree<U32>'
    SPa = f'{WA}, {NCa}, T'
    LT = 'List<&2, U32>'
    return SP, SPa, LT


def _em_windows(x, FS, H, po, WA, fixed, V, NCa, TD, S3, ST, HDRL, NW, w, hb, SP, SPa, LT):
    """the windows of the output's words: header, payload and their equalities"""
    def win(m, p, j):
        return f'VF.WIN({m}, {p}, FD.array__slots(U32, {TD(j)}))'

    def peel_chain(m, p, lo_hi, stop, last_term, last_proof):
        """Equal.trans chain WIN(m, p, TD_M) = ... = WIN(m, p, TD_stop) = rest."""
        steps = []
        for g in range(len(fixed) - 1, stop - 1, -1):
            fg = fixed[g]
            kind = lo_hi(fg)
            if kind == 'lo':
                h = f'Nat.is_le(Nat.add(VF.slen({V(fg)}), {fg["k"]}n), {p}) == True{{}} : Bool'
            else:
                h = f'Nat.is_le(Nat.add({m}, {p}), {fg["k"]}n) == True{{}} : Bool'
            pr = f'V2.peel_{kind}({V(fg)}, DO(N), {TD(g)}, {fg["k"]}n, {m}, {p}, pfD{g}({WA}, N, T), {hb(fg)}, {{==}})'
            steps.append((win(m, p, g + 1), win(m, p, g), pr))
        # fold
        out = last_proof
        for a, b, pr in reversed(steps):
            out = f'Equal.trans({LT}, {a}, {b}, {last_term}, {pr},\n    {out})'
        return out

    def rel(fg, k0, W0):
        return 'lo' if fg['k'] + fg['ft'].W <= k0 else 'hi'
    for i, f in enumerate(x.fields):
        if f['kind'] == 'fix':
            j = fixed.index(f)
            k0, W0 = f['k'], f['ft'].W
            last = f'V2.own({V(f)}, DO(N), {TD(j)}, {k0}n, pfD{j}({WA}, N, T), {hb(f)})'
            body = peel_chain(f'{W0}n', f'{k0}n', lambda fg: rel(fg, k0, W0), j + 1, V(f), last)
            w(f'def seg{i}({SP}) -> {{{win(f"{W0}n", f"{k0}n", len(fixed))} == {V(f)} : {LT}}}:')
            w('  ' + body)
            w('')
        else:
            LM = f'VB.lm({NW}, 0n, {H}n, FD.array__slots(U32, OUT1(N)), {ST})'
            tail = (TEMPLATES.render('_em_windows', LT=LT, po=po, LM=LM, FS=FS, NW=NW, H=H, NCa=NCa, ST=ST))
            body = peel_chain('1n', f'{po}n', lambda fg: rel(fg, po, 1), 0, f'[{FS}]', tail)
            w(f'def seg{i}({SP}) -> {{{win("1n", f"{po}n", len(fixed))} == [{FS}] : {LT}}}:')
            w('  ' + body)
            w('')
    # payload window
    LM = f'VB.lm({NW}, 0n, {H}n, FD.array__slots(U32, OUT1(N)), {ST})'
    tail = (TEMPLATES.render('_em_windows_2', LT=LT, NW=NW, H=H, LM=LM, ST=ST, NCa=NCa))
    body = peel_chain(NW, f'{H}n', lambda fg: 'lo', 0, f'VS.wtake({NW}, {ST})', tail)
    w(f'def pay_eq({SP}, +dw: Nat, +pfT: {{FD.array__perfect(U32, dw, T) == True{{}} : Bool}}, +hroom: {{Nat.is_le(Nat.add(VC.NW(N), 0n), VB.pw(dw)) == True{{}} : Bool}})')
    w(f'    -> {{{win(NW, f"{H}n", len(fixed))} == VS.wtake({NW}, {ST}) : {LT}}}:')
    w('  ' + body)
    w('')
    # header window
    w(f'def hdr_eq({SP}) -> {{{win(f"{H}n", "0n", len(fixed))} == {HDRL} : {LT}}}:')
    segs = []
    for i, f in enumerate(x.fields):
        segs.append((i, f['ft'].W if f['kind'] == 'fix' else 1, f['k'], V(f) if f['kind'] == 'fix' else f'[{FS}]'))
    R, s = H, 0
    pre = lambda t: t  # noqa: E731
    for idx, (i, Wd, k, Vs) in enumerate(segs):
        assert k == s
        if idx < len(segs) - 1:
            w(f'  %Equal.sym({LT}, {win(f"Nat.add({Wd}n, {R - Wd}n)", f"{s}n", len(fixed))}, VF.app({win(f"{Wd}n", f"{s}n", len(fixed))}, {win(f"{R - Wd}n", f"Nat.add({s}n, {Wd}n)", len(fixed))}),')
            w(f'      VF.win_split({Wd}n, {R - Wd}n, {s}n, {S3})) :')
            w(f'    {{{pre("_")} == {HDRL} : {LT}}}')
            w(f'  %Equal.sym({LT}, {win(f"{Wd}n", f"{s}n", len(fixed))}, {Vs}, seg{i}({SPa})) :')
            p0 = pre
            rest = win(f'{R - Wd}n', f'{s + Wd}n', len(fixed))
            w(f'    {{{p0(f"VF.app(_, {rest})")} == {HDRL} : {LT}}}')
            pre = (lambda p0, Vs: (lambda t: p0(f'VF.app({Vs}, {t})')))(p0, Vs)
            R, s = R - Wd, s + Wd
        else:
            assert R == Wd
            w(f'  %Equal.sym({LT}, {win(f"{Wd}n", f"{s}n", len(fixed))}, {Vs}, seg{i}({SPa})) :')
            w(f'    {{{pre("_")} == {HDRL} : {LT}}}')
    w('  {==}')
    w('')


def _em_spec_side(n, FS, H, ITEMS, CHAIN, PL, CAT, PRE, POST, LIMN, YS, K_FIT, WS, WA, NC, NCa, ALLP, ALLa, S3, ST, HDR, HDRL, NW, toN, M, MP, L, w, SPa, LT):
    """the spec side: the value and bytes of the object and encode_spec"""
    RHSk = f'Some{{F.limbs({HDR} <> {YS})}}'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), F.limbs({YS}))'
    RHS = f'F.limbs({HDR} <> VS.wtake(Nat.double(c), {ST}))'
    BT = f'VS.bt(U32.to_nat(SFS(N)), F.limbs({S3}))'
    Kx = f'Nat.add({H}n, {NW})'
    w(TEMPLATES.render('_em_spec_side', WS=WS, ITEMS=ITEMS, LIMN=LIMN, n=n, WA=WA, RHSk=RHSk, M=M, YS=YS, PRE=PRE, POST=POST, FS=FS, K_FIT=K_FIT, MP=MP, CHAIN=CHAIN, PL=PL, CAT=CAT, ENCR=ENCR, NC=NC, Kx=Kx, NW=NW, NCa=NCa, H=H, toN=toN, ALLP=ALLP, BT=BT, RHS=RHS, S3=S3, LT=LT, HDRL=HDRL, SPa=SPa, ST=ST, ALLa=ALLa))
    return '\n'.join(L) + '\n'


def enc_module_text(g, x):
    n, FS, H, po, lp, KO, KK, Tn, LIMB, PB, P2, ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, LIMN, YS, LP, BS, K_PB, K_ES, K_YN, K_YS, MKO, K_KO, K_LB, K_FIT = _em_limits(g, x)
    WS, WA, fixed, V, fobj, OBJ, FIXOBJS, WORDS, NC, NCa, ALLP, ALLa, TD, OUT3, S3, ST, HDR, HDRL, NW, toN, M, MP, L, w = _em_names(x, n, FS, H, po, Tn, hdr, LIMN, LP)
    hb, RS = _em_object_laws(FS, H, po, KO, Tn, PB, P2, LIMN, BS, K_PB, K_ES, K_YN, K_YS, MKO, K_KO, WS, WA, fixed, V, OBJ, FIXOBJS, NC, NCa, ALLP, TD, toN, w)
    RP, TP = _em_put_eval(FS, H, po, lp, Tn, LIMB, LIMN, K_LB, WA, fixed, fobj, OBJ, FIXOBJS, WORDS, NCa, ALLP, TD, OUT3, toN, w, hb)
    SP, SPa, LT = _em_encode_eval(FS, KO, KK, Tn, WS, WA, OBJ, NC, NCa, ALLP, ALLa, OUT3, w, RS, RP, TP)

    _em_windows(x, FS, H, po, WA, fixed, V, NCa, TD, S3, ST, HDRL, NW, w, hb, SP, SPa, LT)
    # ---- spec ----
    return _em_spec_side(n, FS, H, ITEMS, CHAIN, PL, CAT, PRE, POST, LIMN, YS, K_FIT, WS, WA, NC, NCa, ALLP, ALLa, S3, ST, HDR, HDRL, NW, toN, M, MP, L, w, SPa, LT)
