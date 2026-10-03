"""The encoder laws of DataColumnSidecar (encode_eval, encode_spec), for codegen/proofs/var/multi_variable_field_codec_laws.py.

The object is index words i0 i1, the three lists' storage trees T0 T1 T2 holding
N0 N1 N2 bytes (c0 elements of 2048 bytes, c1 and c2 of 48; ec_i, hc_i), the
header's 52 words h0..h51 and the inclusion proof's storage tree TP (32 words).
The encoder allocates a zero tree of depth DO and writes, in its order:
  D1  word 2 := 356          D2  column's words at 89      D3  word 3 := S1
  D4  kzg_commitments at Q1  D5  word 4 := S2              D6  kzg_proofs at Q2
  D7  the header at word 5   D8  the proof at word 57      D9  the index at word 0
encode_eval: the encoder returns the object and B.Buf{thaw(D9), S3}.
encode_spec: those S3 bytes are the spec encoding of the object's value.
The sizes are up to 8.8 MB, so the closed bounds (cQ, cS, cD, cH0, cH1) make this a
big_* file (checked with --big).
"""
from codegen.core.bend_source_text_helpers import wl  # noqa: E402
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('data_column_sidecar_encoder_laws', globals())

X = 'DataColumnSidecar'
IW = ['i0', 'i1']
HW = [f'h{k}' for k in range(52)]
PW = [f'VB.slot(TP, {k}n)' for k in range(32)]
TR = 'FD.array__Tree<U32>'
X_ = X


def VBX_names(n):
    from codegen.proofs.var import byte_list_offset_windows as VBX  # the container's field-name list (spec/fulu_schemas.bend)
    return VBX.spec_names(n)


def text(hdr, pvnode, hnode, inode, DEC_HEAD, SCH):
    """hdr: single_list_container_codec_laws.FT of the header; the walk nodes (val, sch, proof, words) of the
    proof vector (words VB.slot(TP, k)), the header (words h..) and the index (i0 i1)."""
    W = []
    w = W.append
    TRUE = 'True{} : Bool'
    # ---- parameter lists ----
    NP = ('+N0: U32, +N1: U32, +N2: U32, +c0: Nat, +c1: Nat, +c2: Nat,\n'
          '    +ec0: {U32.to_nat(N0) == A.quad(M0(c0)) : Nat}, +ec1: {U32.to_nat(N1) == A.quad(M1(c1)) : Nat}, +ec2: {U32.to_nat(N2) == A.quad(M2(c2)) : Nat},\n'
          f'    +hc0: {{Nat.is_le(c0, U32.to_nat(4096)) == {TRUE}}}, +hc1: {{Nat.is_le(c1, U32.to_nat(4096)) == {TRUE}}}, +hc2: {{Nat.is_le(c2, U32.to_nat(4096)) == {TRUE}}}')
    NA = 'N0, N1, N2, c0, c1, c2, ec0, ec1, ec2, hc0, hc1, hc2'
    DP = (f'+N0: U32, +N1: U32, +N2: U32, +c0: Nat, +c1: Nat, +T0: {TR}, +T1: {TR}, +T2: {TR}, +TP: {TR}, +i0: U32, +i1: U32, '
          + ', '.join(f'+{h}: U32' for h in HW))
    DA = 'N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, ' + ', '.join(HW)
    HP = (TPL.render('HP', TRUE=TRUE))
    HA = 'c2, dw0, dw1, dw2, dp, pf0, pf1, pf2, pfP, hdw0, hdw1, hdw2, hdp, ec0, ec1, ec2, hc0, hc1, hc2, hr0, hr1, hr2, hrP'
    ALLP = DP + ',\n    ' + HP
    ALLA = DA + ', ' + HA
    DOe = 'DO(N0, N1, N2)'
    HR = hdr.obj(HW)
    OE = (f'T.{X}{{O.U64{{i0, i1}}, O.Words{{FD.array__thaw(U32, T0), N0}}, O.Words{{FD.array__thaw(U32, T1), N1}}, O.Words{{FD.array__thaw(U32, T2), N2}}, '
          f'O.BSome{{{HR}, O.BNone{{}}}}, O.Words{{FD.array__thaw(U32, TP), 128}}}}')
    w(TPL.render('text', DOe=DOe, NA=NA, NP=NP, TRUE=TRUE))
    # ---- the output trees ----
    LAY = [('D1', 'v', '[356]', '2n', None), ('D2', 'm', 'VC.NW(N0)', '89n', 'T0'), ('D3', 'v', '[S1(N0)]', '3n', None),
           ('D4', 'm', 'VC.NW(N1)', 'Q1(c0)', 'T1'), ('D5', 'v', '[S2(N0, N1)]', '4n', None), ('D6', 'm', 'VC.NW(N2)', 'Q2(c0, c1)', 'T2'),
           ('D7', 'v', wl(HW), '5n', None), ('D8', 'v', wl(PW), '57n', None), ('D9', 'v', '[i0, i1]', '0n', None)]
    w('\n# ---- the output trees ------------------------------------------------------------------------\n')
    w(f'def ZD({DP}) -> {TR}: VC.ZT({DOe})')
    w(f'def pfZD({DP}) -> {{FD.array__perfect(U32, {DOe}, ZD({DA})) == {TRUE}}}: FD.array__trep_perfect(U32, {DOe}, 0)')
    prev = 'ZD'
    for n, k, V, j, src in LAY:
        if k == 'v':
            w(f'def {n}({DP}) -> {TR}: VF.updv({V}, {DOe}, {prev}({DA}), {j})')
            w(f'def pf{n}({DP}) -> {{FD.array__perfect(U32, {DOe}, {n}({DA})) == {TRUE}}}: VF.updv_perfect({V}, {DOe}, {prev}({DA}), {j}, pf{prev}({DA}))')
        else:
            w(f'def {n}({DP}) -> {TR}: VB.mone({V}, 0n, {j}, {DOe}, {prev}({DA}), {src})')
            w(f'def pf{n}({DP}) -> {{FD.array__perfect(U32, {DOe}, {n}({DA})) == {TRUE}}}: VB.mone_perfect({V}, 0n, {j}, {DOe}, {prev}({DA}), {src}, pf{prev}({DA}))')
        prev = n
    return W, LAY, dict(NP=NP, NA=NA, DP=DP, DA=DA, HP=HP, HA=HA, ALLP=ALLP, ALLA=ALLA, OE=OE, HR=HR, DOe=DOe)


def put_text(P, LAY):
    """The encoder's evaluation: size_eval, the writes, put_eval, encode_eval."""
    NP, NA, DP, DA, ALLP, ALLA, OE, HR, DOe = (P[k] for k in ('NP', 'NA', 'DP', 'DA', 'ALLP', 'ALLA', 'OE', 'HR', 'DOe'))
    TRUE = 'True{} : Bool'
    W = []
    w = W.append
    TH = lambda n: f'FD.array__thaw(U32, {n}({DA}))'
    W0 = 'O.Words{FD.array__thaw(U32, T0), N0}'
    W1 = 'O.Words{FD.array__thaw(U32, T1), N1}'
    W2 = 'O.Words{FD.array__thaw(U32, T2), N2}'
    WP = 'O.Words{FD.array__thaw(U32, TP), 128}'
    HB = f'O.BSome{{{HR}, O.BNone{{}}}}'
    U = 'O.U64{i0, i1}'
    S1, S2, S3 = 'S1(N0)', 'S2(N0, N1)', 'S3(N0, N1, N2)'
    # ---- the proof vector's word copy ----
    w('\n# ---- the inclusion proof: 32 words from TP to word 57 -------------------------------------------\n')
    for k in reversed(range(32)):
        rest = '[' + ', '.join(f'VB.slot(TP, {j}n)' for j in range(k, 32)) + ']'
        RHS = f'(FD.array__thaw(U32, VF.updv({rest}, dd, X, {57 + k}n)), FD.array__thaw(U32, TP))'
        ST = f'Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, X), {57 + k}, VB.slot(TP, {k}n)), FD.array__thaw(U32, FD.array__upd(U32, dd, X, {57 + k}n, VB.slot(TP, {k}n))), VB.set_n(dd, X, {57 + k}, {57 + k}n, VB.slot(TP, {k}n), {{==}}, hd32, FD.nat__lt_le_trans({57 + k}n, 89n, VB.pw(dd), {{==}}, h89), pfX))'
        head = (f'def pa{k}(+dd: Nat, +X: {TR}, +TP: {TR}, +dp: Nat, +pfX: {{FD.array__perfect(U32, dd, X) == {TRUE}}}, +hd32: {{Nat.is_lt(dd, 32n) == {TRUE}}},\n'
                f'    +h89: {{Nat.is_le(89n, VB.pw(dd)) == {TRUE}}}, +pfP: {{FD.array__perfect(U32, dp, TP) == {TRUE}}}, +hdp32: {{Nat.is_lt(dp, 32n) == {TRUE}}}, +hrP: {{Nat.is_le(32n, VB.pw(dp)) == {TRUE}}})\n'
                f'    -> {{T.v4_b32_pa{k}(57, FD.array__thaw(U32, X), (FD.array__thaw(U32, TP), VB.slot(TP, {k}n))) == {RHS} : Array<U32> & Array<U32>}}:')
        if k == 31:
            w(head + f'\n  %{ST} :\n    {{(_, FD.array__thaw(U32, TP)) == {RHS} : Array<U32> & Array<U32>}}\n  {{==}}\n')
        else:
            X1 = f'FD.array__upd(U32, dd, X, {57 + k}n, VB.slot(TP, {k}n))'
            w(head + TPL.render('put_text', RHS=RHS, ST=ST, X1=X1, k=k))
    NH = f'{NA}'
    w(TPL.render('put_text_pvP', ALLP=ALLP, DA=DA, DOe=DOe, NH=NH, TH=TH, WP=WP))
    # ---- the lists' writes ----
    LST = [dict(k=0, T='T0', N='N0', c='c0', W=W0, pre='ZD', mid='D1', out='D2', hoff=8, cur='356', curN=None, word=2, hi=8388608, E=512, B=2048,
                Mx='MX0()', cH='cH0()', P='89n', eP='{==}', hp3='{==}', pd='pd1', nxt=S1, pf='pf0', hdw='hdw0', hr='hr0', hdst='hdst0', putv='l4096_b2048_putv', v='DC.v2048()'),
           dict(k=1, T='T1', N='N1', c='c1', W=W1, pre='D2', mid='D3', out='D4', hoff=12, cur=S1, curN='Q1(c0)', word=3, hi=196608, E=12, B=48,
                Mx='MX1()', cH='cH1()', P='Q1(c0)', eP=f'VM.shr_q({S1}, Q1(c0), eS1({NH}))', hp3=f'VL.and3_q({S1}, Q1(c0), eS1({NH}))', pd='pd2', nxt=S2,
                pf='pf1', hdw='hdw1', hr='hr1', hdst='hdst1', putv='l4096_b48_putv', v='DC.v48()'),
           dict(k=2, T='T2', N='N2', c='c2', W=W2, pre='D4', mid='D5', out='D6', hoff=16, cur=S2, curN='Q2(c0, c1)', word=4, hi=196608, E=12, B=48,
                Mx='MX1()', cH='cH1()', P='Q2(c0, c1)', eP=f'VM.shr_q({S2}, Q2(c0, c1), eS2({NH}))', hp3=f'VL.and3_q({S2}, Q2(c0, c1), eS2({NH}))', pd='pd3', nxt=S3,
                pf='pf2', hdw='hdw2', hr='hr2', hdst='hdst2', putv='l4096_b48_putv', v='DC.v48()')]
    for L in LST:
        k, N, c = L['k'], L['N'], L['c']
        M = f'M{k}({c})'
        pfx = L['putv'].replace('_putv', '')
        RHS = f'({TH(L["out"])}, ({L["W"]}, {L["nxt"]}))'
        cur = L['cur']
        zero = '' if k == 0 else f'''
  %Equal.sym(U32, U32.add(0, {cur}), {cur}, FD.u32alg__zero_add({cur})) :
    {{T.{pfx}_pvb({cur}, T.{pfx}_putk({TH(L["mid"])}, _, {L["W"]})) == RHS : Array<U32> & (O.Words & U32)}}'''
        w(TPL.render('put_text_hhi', ALLP=ALLP, DA=DA, DOe=DOe, L=L, M=M, N=N, NH=NH, NP=NP, RHS=RHS, TH=TH, TRUE=TRUE, c=c, cur=cur, k=k, pfx=pfx, zero=zero))
    # ---- the whole write ----
    RT = f'Array<U32> & (T.{X} & U32)'
    RHS = f'({TH("D9")}, ({OE}, {S3}))'
    OR1 = f'U32.or({S3}, 0)'
    w(f'''
def put_eval({ALLP})
    -> {{T.{X}_putn({TH("ZD")}, 0, {OE}) == {RHS} : {RT}}}:
  +RHS = {RHS}
  %Equal.sym({RT.replace(f"T.{X} & U32", "O.Words & U32")}, T.l4096_b2048_putv({TH("ZD")}, 0, 8, 356, {W0}), ({TH("D2")}, ({W0}, {S1})), pv0({ALLA})) :
    {{T.{X}_pw0(0, {U}, {W1}, {W2}, {HB}, {WP}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32> & (O.Words & U32), T.l4096_b48_putv({TH("D2")}, 0, 12, {S1}, {W1}), ({TH("D4")}, ({W1}, {S2})), pv1({ALLA})) :
    {{T.{X}_pw1(0, {U}, {W0}, {W2}, {HB}, {WP}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32> & (O.Words & U32), T.l4096_b48_putv({TH("D4")}, 0, 16, {S2}, {W2}), ({TH("D6")}, ({W2}, {S3})), pv2({ALLA})) :
    {{T.{X}_pw2(0, {U}, {W0}, {W1}, {HB}, {WP}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32>, T.SignedBeaconBlockHeader_put({TH("D6")}, 20, {HR}), {TH("D7")},
      VT.put_SignedBeaconBlockHeader({DOe}, D6({DA}), 20, 5n, {{==}}, hDO29({NH}), pfD6({DA}), lkP({NH}, 57n, {{==}}), {", ".join(f"h{j}" for j in range(52))})) :
    {{T.{X}_pw3(0, {S3}, {U}, {W0}, {W1}, {W2}, {WP}, (_, ({HB}, 0))) == RHS : {RT}}}
  %Equal.sym(Array<U32> & (O.Words & U32), T.v4_b32_putk({TH("D7")}, 228, {WP}), ({TH("D8")}, ({WP}, 0)), pvP({ALLA})) :
    {{T.{X}_pw4(0, {OR1}, {U}, {W0}, {W1}, {W2}, {HB}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32>, T.u64_put({TH("D8")}, 0, {U}), {TH("D9")}, VT.put_u64({DOe}, D8({DA}), 0, 0n, {{==}}, hDO29({NH}), pfD8({DA}), lkP({NH}, 2n, {{==}}), i0, i1)) :
    {{(_, ({OE}, U32.or({OR1}, 0))) == RHS : {RT}}}
  %Equal.sym(U32, U32.or({OR1}, U32{{Word.zero(32n)}}), {OR1}, VE.or_zero_u({OR1})) :
    {{({TH("D9")}, ({OE}, _)) == RHS : {RT}}}
  %Equal.sym(U32, U32.or({S3}, U32{{Word.zero(32n)}}), {S3}, VE.or_zero_u({S3})) :
    {{({TH("D9")}, ({OE}, _)) == RHS : {RT}}}
  {{==}}

def size_eval({ALLP})
    -> {{T.{X}_size({OE}) == ({OE}, {S3}) : T.{X} & U32}}:
  +RHS = ({OE}, {S3})
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T0)), (FD.array__thaw(U32, T0), FD.u32__pow2u(dw0)), FD.array__size_thaw(U32, dw0, T0, pf0)) :
    {{T.{X}_sz0({U}, {W1}, {W2}, {HB}, {WP}, 356, O.wsz_pick(N0, _)) == RHS : T.{X} & U32}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N0), FD.u32__pow2u(dw0)), True{{}}, VE.le_room(N0, dw0, hdw0, hr0)) :
    {{T.{X}_sz0({U}, {W1}, {W2}, {HB}, {WP}, 356, ({W0}, O.pick(_, N0, 4294967295))) == RHS : T.{X} & U32}}
  %Equal.sym(U32, O.padd(356, N0), {S1}, pd1({NH})) :
    {{T.{X}_sz1({U}, {W2}, {HB}, {WP}, {W0}, _, T.l4096_b48_size({W1})) == RHS : T.{X} & U32}}
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T1)), (FD.array__thaw(U32, T1), FD.u32__pow2u(dw1)), FD.array__size_thaw(U32, dw1, T1, pf1)) :
    {{T.{X}_sz1({U}, {W2}, {HB}, {WP}, {W0}, {S1}, O.wsz_pick(N1, _)) == RHS : T.{X} & U32}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N1), FD.u32__pow2u(dw1)), True{{}}, VE.le_room(N1, dw1, hdw1, hr1)) :
    {{T.{X}_sz1({U}, {W2}, {HB}, {WP}, {W0}, {S1}, ({W1}, O.pick(_, N1, 4294967295))) == RHS : T.{X} & U32}}
  %Equal.sym(U32, O.padd({S1}, N1), {S2}, pd2({NH})) :
    {{T.{X}_sz2({U}, {HB}, {WP}, {W0}, {W1}, _, T.l4096_b48_size({W2})) == RHS : T.{X} & U32}}
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T2)), (FD.array__thaw(U32, T2), FD.u32__pow2u(dw2)), FD.array__size_thaw(U32, dw2, T2, pf2)) :
    {{T.{X}_sz2({U}, {HB}, {WP}, {W0}, {W1}, {S2}, O.wsz_pick(N2, _)) == RHS : T.{X} & U32}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N2), FD.u32__pow2u(dw2)), True{{}}, VE.le_room(N2, dw2, hdw2, hr2)) :
    {{T.{X}_sz2({U}, {HB}, {WP}, {W0}, {W1}, {S2}, ({W2}, O.pick(_, N2, 4294967295))) == RHS : T.{X} & U32}}
  %Equal.sym(U32, O.padd({S2}, N2), {S3}, pd3({NH})) :
    {{({OE}, _) == RHS : T.{X} & U32}}
  {{==}}

# The encoder returns the object and the buffer of D9, S3 bytes.
def encode_eval({ALLP})
    -> {{T.{X}_encode({OE}) == ({OE}, B.Buf{{{TH("D9")}, {S3}}}) : T.{X} & B.Buf}}:
  +RHS = ({OE}, B.Buf{{{TH("D9")}, {S3}}})
  %Equal.sym(T.{X} & U32, T.{X}_size({OE}), ({OE}, {S3}), size_eval({ALLA})) :
    {{T.{X}_enc_sized(_) == RHS : T.{X} & B.Buf}}
  %Equal.sym(Bool, O.is_poisoned({S3}), False{{}}, npS3({NH})) :
    {{T.{X}_enc_go(_, {S3}, {OE}) == RHS : T.{X} & B.Buf}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu({S3}))), Array.new(U32, {DOe}, 0), VZ.zat(B.words_depth_u(VC.nwu({S3})), {DOe}, VD.wdu(VC.nwu({S3})), hDO({NH}))) :
    {{T.{X}_enc_put({S3}, T.{X}_putn(_, 0, {OE})) == RHS : T.{X} & B.Buf}}
  %Equal.sym(Array<U32>, Array.new(U32, {DOe}, 0), FD.array__thaw(U32, VC.ZT({DOe})), FD.array__new(U32, {DOe}, 0)) :
    {{T.{X}_enc_put({S3}, T.{X}_putn(_, 0, {OE})) == RHS : T.{X} & B.Buf}}
  %Equal.sym({RT}, T.{X}_putn({TH("ZD")}, 0, {OE}), ({TH("D9")}, ({OE}, {S3})), put_eval({ALLA})) :
    {{T.{X}_enc_put({S3}, _) == RHS : T.{X} & B.Buf}}
  {{==}}
''')
    return [inline_rhs(b) for b in W]


def inline_rhs(block):
    """Replace a `+RHS = X` let (lets of pairs need annotations) by X."""
    out, rhs = [], None
    for line in block.split('\n'):
        if line.startswith('  +RHS = '):
            rhs = line[len('  +RHS = '):]
            continue
        if line.startswith('def '):
            rhs = None
        if rhs is not None:
            line = line.replace(' == RHS :', f' == {rhs} :')
        out.append(line)
    return '\n'.join(out)


def spec_text(P, IDX, HDR, PV):
    """encode_spec: the output's bytes are the spec encoding of the object's value."""
    NP, NA, DP, DA, ALLP, ALLA, OE, DOe = (P[k] for k in ('NP', 'NA', 'DP', 'DA', 'ALLP', 'ALLA', 'OE', 'DOe'))
    TRUE = 'True{} : Bool'
    NH = NA
    W = []
    w = W.append
    SD = f'FD.array__slots(U32, D9({DA}))'
    SL = lambda n: f'FD.array__slots(U32, {n}({DA}))'
    S1, S2, S3 = 'S1(N0)', 'S2(N0, N1)', 'S3(N0, N1, N2)'
    CN = ['c0', 'c1', 'c2']
    TN = ['T0', 'T1', 'T2']
    MN = ['M0(c0)', 'M1(c1)', 'M2(c2)']
    QN_ = ['89n', 'Q1(c0)', 'Q2(c0, c1)']
    ZN = [f'VS.wtake({MN[i]}, FD.array__slots(U32, {TN[i]}))' for i in range(3)]
    EB = [(512, 2048), (12, 48), (12, 48)]
    AW = wl(IDX['words'])
    POST = '[' + wl(HDR['words']) + ', ' + wl(PV['words']) + ']'
    vals = [IDX['val']] + [f'S.Sequence{{VM.bvit({CN[i]}, {EB[i][0]}n, FD.array__slots(U32, {TN[i]}))}}' for i in range(3)] + [HDR['val'], PV['val']]
    schs = [IDX['sch']] + [f'S.ListOf{{S.ByteVector{{{EB[i][1]}n}}, U32.to_nat(4096)}}' for i in range(3)] + [HDR['sch'], PV['sch']]
    parts = ([f'S.Fixed{{F.limbs({AW})}}'] + [f'S.Variable{{F.limbs({ZN[i]})}}' for i in range(3)]
             + [f'S.Fixed{{F.limbs({wl(HDR["words"])})}}', f'S.Fixed{{F.limbs({wl(PV["words"])})}}'])
    fixed = {0: IDX, 4: HDR, 5: PV}

    def items(i):
        return 'S.EmptyItems{}' if i == 6 else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == 6 else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == 6:
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if i in fixed:
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs({wl(fixed[i]["words"])}), '
                    f'{rest}, {fixed[i]["proof"]}, {cat(i + 1)})')
        j = i - 1
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs({ZN[j]}), {rest}, '
                f'VM.list_bv({CN[j]}, {EB[j][0]}n, {EB[j][1]}n, FD.array__slots(U32, {TN[j]}), U32.to_nat(4096), {{==}}, {{==}}, {{==}}, hc{j}, hl{j}({ALLA}), ft{j}({ALLA})), {cat(i + 1)})')
    ENC = (f'List.append(&2, U32, List.append(&2, U32, F.limbs({AW}), List.append(&2, U32, F.limbs([356, {S1}, {S2}]), F.flat({POST}))), '
           f'List.append(&2, U32, F.limbs({ZN[0]}), List.append(&2, U32, F.limbs({ZN[1]}), F.limbs({ZN[2]}))))')
    XE = f'S.Sequence{{{items(0)}}}'
    w(TPL.render('spec_text', ALLP=ALLP, ENC=ENC, XE=XE))
    for j in range(3):
        w(TPL.render('spec_text_hl', ALLP=ALLP, MN=MN, NH=NH, TN=TN, TRUE=TRUE, j=j))
    w(TPL.render('spec_text_encE', ALLA=ALLA, ALLP=ALLP, NH=NH, S1=S1, ZN=ZN))
    W.pop()   # (lets of rewrites are not allowed: the offsets' equations are separate lemmas)
    w(TPL.render('spec_text_ce1', ALLA=ALLA, ALLP=ALLP, AW=AW, NH=NH, POST=POST, S1=S1, S2=S2, TRUE=TRUE, ZN=ZN, cat=cat, chain=chain, items=items, parts=parts))
    # ---- the output's windows ----
    LAYS = [('D9', 'v', '[i0, i1]', '0n', None, 2), ('D8', 'v', wl(PW), '57n', None, 32), ('D7', 'v', wl(HW), '5n', None, 52),
            ('D6', 'm', 'VC.NW(N2)', 'Q2(c0, c1)', 'T2', 'hdst2'), ('D5', 'v', '[S2(N0, N1)]', '4n', None, 1),
            ('D4', 'm', 'VC.NW(N1)', 'Q1(c0)', 'T1', 'hdst1'), ('D3', 'v', '[S1(N0)]', '3n', None, 1),
            ('D2', 'm', 'VC.NW(N0)', '89n', 'T0', 'hdst0'), ('D1', 'v', '[356]', '2n', None, 1)]
    PREV = {'D9': 'D8', 'D8': 'D7', 'D7': 'D6', 'D6': 'D5', 'D5': 'D4', 'D4': 'D3', 'D3': 'D2', 'D2': 'D1', 'D1': 'ZD'}
    DW = {'T0': 'dw0', 'T1': 'dw1', 'T2': 'dw2'}
    PFT = {'T0': 'pf0', 'T1': 'pf1', 'T2': 'pf2'}
    HR = {'T0': 'hr0', 'T1': 'hr1', 'T2': 'hr2'}

    def chain_proof(m, p, owner, conds, rhs):
        """WIN(m, p, slots D9) == rhs: peel the layers above `owner`, then own it.
        conds[layer] = the proof of the peel condition at that layer."""
        steps = []
        for (n, k, V, j, src, extra) in LAYS:
            prev = PREV[n]
            if n == owner:
                if k == 'v':
                    steps.append((n, f'V2.own({V}, {DOe}, {prev}({DA}), {j}, pf{prev}({DA}), lkP({NH}, Nat.add(FD.spec_common__length(U32, {V}), {j}), {{==}}))', rhs))
                else:
                    steps.append((n, f'VME.mown({V}, {j}, {DOe}, {prev}({DA}), {DW[src]}, {src}, pf{prev}({DA}), {PFT[src]}, {extra}({NH}), {HR[src]})', rhs))
                break
            c, side = conds[n]
            if k == 'v':
                lem = 'V2.peel_lo' if side == 'lo' else 'V2.peel_hi'
                steps.append((n, f'{lem}({V}, {DOe}, {prev}({DA}), {j}, {m}, {p}, pf{prev}({DA}), lkP({NH}, Nat.add(FD.spec_common__length(U32, {V}), {j}), {{==}}), {c})',
                              f'VF.WIN({m}, {p}, {SL(prev)})'))
            else:
                lem = 'VME.mpeel_lo' if side == 'lo' else 'VME.mpeel_hi'
                steps.append((n, f'{lem}({V}, {j}, {DOe}, {prev}({DA}), {src}, {m}, {p}, pf{prev}({DA}), {extra}({NH}), {c})',
                              f'VF.WIN({m}, {p}, {SL(prev)})'))
        # fold into Equal.trans
        cur = f'VF.WIN({m}, {p}, {SD})'
        out = None
        for n, prf, nxt in reversed(steps):
            pass
        expr = steps[-1][1]
        right = steps[-1][2]
        for idx in range(len(steps) - 2, -1, -1):
            n, prf, nxt = steps[idx]
            left = f'VF.WIN({m}, {p}, {SL(n)})'
            expr = f'Equal.trans(List<&2, U32>, {left}, {nxt}, {right}, {prf}, {expr})'
        return expr

    def hc(k, j):
        return '{==}'
    # header segments
    SEG = [('s0', '2n', '0n', 'D9', '[i0, i1]', {}),
           ('s2', '1n', '2n', 'D1', '[356]', {'D9': ('{==}', 'lo'), 'D8': ('{==}', 'hi'), 'D7': ('{==}', 'hi'), 'D6': (f'lkQ2(c0, c1, 3n, {{==}})', 'hi'),
                                             'D5': ('{==}', 'hi'), 'D4': (f'lkQ1(c0, 3n, {{==}})', 'hi'), 'D3': ('{==}', 'hi'), 'D2': ('{==}', 'hi')}),
           ('s3', '1n', '3n', 'D3', f'[{S1}]', {'D9': ('{==}', 'lo'), 'D8': ('{==}', 'hi'), 'D7': ('{==}', 'hi'), 'D6': (f'lkQ2(c0, c1, 4n, {{==}})', 'hi'),
                                                'D5': ('{==}', 'hi'), 'D4': (f'lkQ1(c0, 4n, {{==}})', 'hi')}),
           ('s4', '1n', '4n', 'D5', f'[{S2}]', {'D9': ('{==}', 'lo'), 'D8': ('{==}', 'hi'), 'D7': ('{==}', 'hi'), 'D6': (f'lkQ2(c0, c1, 5n, {{==}})', 'hi')}),
           ('s5', '52n', '5n', 'D7', wl(HW), {'D9': ('{==}', 'lo'), 'D8': ('{==}', 'hi')}),
           ('s57', '32n', '57n', 'D8', wl(PW), {'D9': ('{==}', 'lo')})]
    for name, m, p, owner, rhs, conds in SEG:
        w(f'def {name}({ALLP}) -> {{VF.WIN({m}, {p}, {SD}) == {rhs} : List<&2, U32>}}:\n  {chain_proof(m, p, owner, conds, rhs)}\n')
    # the header window: split 89 = 2 + 1 + 1 + 1 + 52 + 32
    HW89 = wl(['i0', 'i1', '356', S1, S2] + HW + PW)
    w(TPL.render('spec_text_hdrW', ALLA=ALLA, ALLP=ALLP, HW89=HW89, S1=S1, S2=S2, SD=SD))
    # the lists' windows
    LC = [{'D9': ('lo', 0), 'D8': ('lo', 0), 'D7': ('lo', 0), 'D6': (f'lW0Q2({NH})', 'hi'), 'D5': ('lo', 0), 'D4': (f'lW0({NH})', 'hi'), 'D3': ('lo', 0)},
          {'D9': ('lo', 1), 'D8': ('lo', 1), 'D7': ('lo', 1), 'D6': (f'lW1({NH})', 'hi'), 'D5': ('lo', 1)},
          {'D9': ('lo', 2), 'D8': ('lo', 2), 'D7': ('lo', 2)}]
    LAYD = {n: (k, V, j) for (n, k, V, j, src, extra) in LAYS}
    for i in range(3):
        conds = {}
        for n, v in LC[i].items():
            if v[0] == 'lo':
                k, V, j = LAYD[n]
                kk = f'Nat.add(FD.spec_common__length(U32, {V}), {j})'
                c = '{==}' if i == 0 else (f'lkQ1(c0, {kk}, {{==}})' if i == 1 else f'lkQ2(c0, c1, {kk}, {{==}})')
                conds[n] = (c, 'lo')
            else:
                conds[n] = v
        NWi = f'VC.NW(N{i})'
        owner = ['D2', 'D4', 'D6'][i]
        w(f'''def lWn{i}({ALLP}) -> {{VF.WIN({NWi}, {QN_[i]}, {SD}) == VS.wtake({NWi}, FD.array__slots(U32, {TN[i]})) : List<&2, U32>}}:
  {chain_proof(NWi, QN_[i], owner, conds, f"VS.wtake({NWi}, FD.array__slots(U32, {TN[i]}))")}
def lW{i}w({ALLP}) -> {{VF.WIN({MN[i]}, {QN_[i]}, {SD}) == {ZN[i]} : List<&2, U32>}}:
  %eNW{i}({NH}) : {{VF.WIN(_, {QN_[i]}, {SD}) == VS.wtake(_, FD.array__slots(U32, {TN[i]})) : List<&2, U32>}}
  lWn{i}({ALLA})
''')
    # out_eq, as lim3
    X0 = f'VS.wtake(M0(c0), VB.wdr(89n, {SD}))'
    X1 = f'VS.wtake(M1(c1), VB.wdr(Q1(c0), {SD}))'
    X2 = f'VS.wtake(M2(c2), VB.wdr(Q2(c0, c1), {SD}))'
    Ew = f'ENC({ALLA})'
    LH = f'F.limbs({HW89})'
    w(TPL.render('spec_text_out_eq', ALLA=ALLA, ALLP=ALLP, Ew=Ew, HW89=HW89, LH=LH, NH=NH, S3=S3, SD=SD, X0=X0, X1=X1, X2=X2, ZN=ZN))
    return W
