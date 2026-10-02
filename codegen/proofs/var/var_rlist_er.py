from codegen.core.shared_var_b import Templates  # noqa: E402
TPL = Templates('var_rlist_er', globals())
"""ExecutionRequests for codegen/proofs/var/var_rlist.py: its byte-offset window module
(proofs/obj/var_winx_ExecutionRequests.bend, the interface of vua_win.bend) over the three
record-list window modules, and its whole-buffer decoder laws (the window at x = 0,
proofs/obj/var_codec_ExecutionRequests.bend)."""

X = 'ExecutionRequests'
TRUE = 'True{} : Bool'
TR = 'FD.array__Tree<U32>'


def _er_buffer_def():
    """the buffer constructor of the window's tree"""
    return f'''def BF(t: {TR}, +n: U32) -> B.Buf: UA.BF(t, n)

'''


def _er_offsets():
    """the offsets, the lists' lengths, byte positions and runtime offsets"""
    return TPL.render('_er_offsets')


def _er_validator(TXO, O):
    """the validator: its checks, the conjunction chain and the runtime's validity evaluated"""
    return TPL.render('_er_validator', O=O, TXO=TXO)


def _er_header_words(CW, P, O, CA):
    """the header words read at off, off + 4, off + 8"""
    return TPL.render('_er_header_words', CA=CA, CW=CW, O=O, P=P)


def _er_check_facts(TXO, CA, O, CW, P, Xk, Lk, Fk):
    """what the checks give: each check and the order of the offsets"""
    return f'''# ---- what the checks give -----------------------------------------------------------------------

def hA({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CA(len) == {TRUE}}}: FD.logic__and_left(CA(len), K1(t, x, off, len), h)
def k1({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{K1(t, x, off, len) == {TRUE}}}: FD.logic__and_right(CA(len), K1(t, x, off, len), h)
def k2({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{K2(t, x, off, len) == {TRUE}}}: FD.logic__and_right(CB(t, x), K2(t, x, off, len), k1(t, x, off, len, h))
def k3({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{K3(t, x, off, len) == {TRUE}}}: FD.logic__and_right(CC(t, x, len), K3(t, x, off, len), k2(t, x, off, len, h))
def k4({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{K4(t, x, off, len) == {TRUE}}}: FD.logic__and_right(CD(t, x, len), K4(t, x, off, len), k3(t, x, off, len, h))
def k5({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{K5(t, x, off, len) == {TRUE}}}: FD.logic__and_right(CE(t, x, off, len), K5(t, x, off, len), k4(t, x, off, len, h))
def hB({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CB(t, x) == {TRUE}}}: FD.logic__and_left(CB(t, x), K2(t, x, off, len), k1(t, x, off, len, h))
def hC({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CC(t, x, len) == {TRUE}}}: FD.logic__and_left(CC(t, x, len), K3(t, x, off, len), k2(t, x, off, len, h))
def hD({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CD(t, x, len) == {TRUE}}}: FD.logic__and_left(CD(t, x, len), K4(t, x, off, len), k3(t, x, off, len, h))
def hE({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CE(t, x, off, len) == {TRUE}}}: FD.logic__and_left(CE(t, x, off, len), K5(t, x, off, len), k4(t, x, off, len, h))
def hF({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CF(t, x, off, len) == {TRUE}}}: FD.logic__and_left(CF(t, x, off, len), CG(t, x, off, len), k5(t, x, off, len, h))
def hG({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{CG(t, x, off, len) == {TRUE}}}: FD.logic__and_right(CF(t, x, off, len), CG(t, x, off, len), k5(t, x, off, len, h))

def natle(+a: U32, +b: U32, +h: {{U32.is_le(a, b) == {TRUE}}}) -> {{Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == {TRUE}}}:
  FD.logic__subst(Bool, z => {{z == {TRUE}}}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def l01({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{U32.is_le({O[0]}, {O[1]}) == {TRUE}}}: FD.logic__and_left(U32.is_le({O[0]}, {O[1]}), U32.is_le({O[1]}, len), hC(t, x, off, len, h))
def l1n({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{U32.is_le({O[1]}, len) == {TRUE}}}: FD.logic__and_right(U32.is_le({O[0]}, {O[1]}), U32.is_le({O[1]}, len), hC(t, x, off, len, h))
def l12({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{U32.is_le({O[1]}, {O[2]}) == {TRUE}}}: FD.logic__and_left(U32.is_le({O[1]}, {O[2]}), U32.is_le({O[2]}, len), hD(t, x, off, len, h))
def l2n({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{U32.is_le({O[2]}, len) == {TRUE}}}: FD.logic__and_right(U32.is_le({O[1]}, {O[2]}), U32.is_le({O[2]}, len), hD(t, x, off, len, h))
def l0n({TXO}, +h: {{CHKw(t, x, off, len) == {TRUE}}}) -> {{Nat.is_le(U32.to_nat({O[0]}), U32.to_nat(len)) == {TRUE}}}:
  FD.nat__le_trans(U32.to_nat({O[0]}), U32.to_nat({O[1]}), U32.to_nat(len), natle({O[0]}, {O[1]}, l01(t, x, off, len, h)), natle({O[1]}, len, l1n(t, x, off, len, h)))

# the lists' windows lie in the window
def xle({CW}, +c: U32, +hc: {{Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == {TRUE}}}) -> {{Nat.is_le(Nat.add(x, U32.to_nat(c)), {P}) == {TRUE}}}:
  FD.nat__le_trans(Nat.add(x, U32.to_nat(c)), Nat.add(x, U32.to_nat(len)), {P}, Order.add_left(x, U32.to_nat(c), U32.to_nat(len), hc), hw)
def eoc({CW}, +c: U32, +hc: {{Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == {TRUE}}})
    -> {{U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(2n+d, 30n, 31n, hd, {{==}}),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, {P}) == {TRUE}}}, Nat.add(x, U32.to_nat(c)), Nat.add(U32.to_nat(c), x), FD.nat__add_comm(x, U32.to_nat(c)), xle({CA}, c, hc)))
def hw0({CW}, {'+hchk: {CHKw(t, x, off, len) == True{} : Bool}'}) -> {{Nat.is_le(Nat.add({Xk[0]}, U32.to_nat({Lk[0]})), {P}) == {TRUE}}}:
  VRC.winb({O[0]}, {O[1]}, x, {P}, l01(t, x, off, len, hchk), xle({CA}, {O[1]}, natle({O[1]}, len, l1n(t, x, off, len, hchk))))
def hw1({CW}, {'+hchk: {CHKw(t, x, off, len) == True{} : Bool}'}) -> {{Nat.is_le(Nat.add({Xk[1]}, U32.to_nat({Lk[1]})), {P}) == {TRUE}}}:
  VRC.winb({O[1]}, {O[2]}, x, {P}, l12(t, x, off, len, hchk), xle({CA}, {O[2]}, natle({O[2]}, len, l2n(t, x, off, len, hchk))))
def hw2({CW}, {'+hchk: {CHKw(t, x, off, len) == True{} : Bool}'}) -> {{Nat.is_le(Nat.add({Xk[2]}, U32.to_nat({Lk[2]})), {P}) == {TRUE}}}:
  VRC.winb({O[2]}, len, x, {P}, l2n(t, x, off, len, hchk), xle({CA}, len, Order.reflexive(U32.to_nat(len))))
def eo0({CW}, {'+hchk: {CHKw(t, x, off, len) == True{} : Bool}'}) -> {{U32.to_nat({Fk[0]}) == {Xk[0]} : Nat}}: eoc({CA}, {O[0]}, l0n(t, x, off, len, hchk))
def eo1({CW}, {'+hchk: {CHKw(t, x, off, len) == True{} : Bool}'}) -> {{U32.to_nat({Fk[1]}) == {Xk[1]} : Nat}}: eoc({CA}, {O[1]}, natle({O[1]}, len, l1n(t, x, off, len, hchk)))
def eo2({CW}, {'+hchk: {CHKw(t, x, off, len) == True{} : Bool}'}) -> {{U32.to_nat({Fk[2]}) == {Xk[2]} : Nat}}: eoc({CA}, {O[2]}, natle({O[2]}, len, l2n(t, x, off, len, hchk)))

'''


def _er_reader(TXO, Xk, Fk, Lk, CW, CA, O, LS, RD):
    """the reader: the object read from the tree"""
    return TPL.render('_er_reader', CA=CA, CW=CW, Fk=Fk, LS=LS, Lk=Lk, O=O, RD=RD, TXO=TXO, Xk=Xk)


def _er_spec_side(Xk, Lk, TXO, O, CW, Yk, P, RHSV, LS, CA, Fk):
    """the spec side: the value, the offsets' values, the window's bytes and the window statement"""
    return TPL.render('_er_spec_side', CA=CA, CW=CW, Fk=Fk, LS=LS, Lk=Lk, O=O, P=P, RHSV=RHSV, TXO=TXO, Xk=Xk, Yk=Yk)


def er_text(HEAD, LS):
    """LS: for the three lists (deposits, withdrawals, consolidations) the dicts
    (p, RS, LIM, LSCH) of var_rlist."""
    L = list(HEAD) + ['import ./vdig.bend as VG', f'import ./vrc.bend as VRC', f'import ./vmul.bend as VM', f'import ./var_winx_{LS[0]["p"]}.bend as C0',
                      f'import ./var_winx_{LS[1]["p"]}.bend as C1', f'import ./var_winx_{LS[2]["p"]}.bend as C2', '',
                      '# GENERATED by var_rlist (codegen: var_rlist_er). Do not edit.',
                      f'# The byte-offset window module of {X} (the interface of proofs/obj/vua_win.bend): three',
                      '# offsets, then its three lists of records, read by the window modules C0, C1, C2.', '']
    w = L.append
    CW = (f'+d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {{U32.to_nat(off) == x : Nat}},\n'
          f'    +hd: {{Nat.is_lt(d, 28n) == {TRUE}}}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == {TRUE}}},\n'
          f'    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}')
    CA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    TXO = '+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32'
    P = 'A.quad(VB.pw(d))'
    O = ['O0(t, x)', 'O1(t, x)', 'O2(t, x)']
    Lk = ['L0(t, x)', 'L1(t, x)', 'L2(t, x, len)']
    Xk = ['X0(t, x)', 'X1(t, x)', 'X2(t, x)']
    Fk = ['F0(off, t, x)', 'F1(off, t, x)', 'F2(off, t, x)']
    Yk = [f'UW.WX(t, {Xk[i]}, U32.to_nat({Lk[i]}))' for i in range(3)]
    RD = [f'T.{LS[i]["p"]}_read' for i in range(3)]
    OKF = [f'T.{LS[i]["p"]}_ok' for i in range(3)]
    RHSV = 'Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]}'
    w(
        _er_buffer_def() +
        _er_offsets() +
        _er_validator(TXO, O) +
        _er_header_words(CW, P, O, CA) +
        _er_check_facts(TXO, CA, O, CW, P, Xk, Lk, Fk) +
        _er_reader(TXO, Xk, Fk, Lk, CW, CA, O, LS, RD) +
        _er_spec_side(Xk, Lk, TXO, O, CW, Yk, P, RHSV, LS, CA, Fk))
    # ---- the inversion ----
    SCH = ['Spec.Schema63()', 'Spec.Schema64()', 'Spec.Schema65()']
    ACCT = lambda i: ''.join(f', +y{j}: +List<U32>, f{j}: VMR.LF(y{j}, {LS[j]["RS"]}n, U32.to_nat({LS[j]["LIM"]}))' for j in range(i))
    ACCA = lambda i: ''.join(f', y{j}, f{j}' for j in range(i))

    def ch(i):
        return 'S.End{}' if i == 3 else f'S.Chain{{{SCH[i]}, {ch(i + 1)}}}'

    def cc(i, tail):
        out = tail
        for j in reversed(range(i)):
            out = f'Codec.concatenate(Some{{[S.Variable{{y{j}}}]}}, {out})'
        return out
    E = lambda i, tail: f'{{Codec.aggregate({cc(i, tail)}, None{{}}) == {RHSV} : Maybe<&2, +List<S.Part>>}}'
    GOAL = f'{{CHKw(t, x, off, len) == {TRUE}}}'
    ABS = lambda ev: f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{UW.WX(t, x, U32.to_nat(len))}}], {ev}))'
    CONS = ['S.BooleanValue{+b0}', 'S.UnsignedValue{+u0}', 'S.BytesValue{+xs0}', 'S.BitsValue{+bs0}', 'S.Sequence{+it0}',
            'S.Items{+hd0, +tl0}', 'S.EmptyItems{}', 'S.Selected{+sel0, +sv0}', 'S.NullValue{}']
    YY = 'y0, y1, y2'
    s = ['List.length(&2, U32, y0)', 'List.length(&2, U32, y1)', 'List.length(&2, U32, y2)']
    V1 = f'Nat.add(12n, {s[0]})'
    V2 = f'Nat.add(Nat.add(12n, {s[0]}), {s[1]})'
    SUM = f'Nat.add(12n, Nat.add({s[0]}, Nat.add({s[1]}, {s[2]})))'
    w(TPL.render('er_text', CA=CA, CW=CW, P=P))
    R = f'Nat.add({s[1]}, {s[2]})'
    R = f'Nat.add({s[0]}, Nat.add({s[1]}, {s[2]}))'
    ACC3 = ACCT(3)
    RS = [LS[j]["RS"] for j in range(3)]
    LIM = [LS[j]["LIM"] for j in range(3)]
    w(TPL.render('er_text_contra', ABS=ABS, ACC3=ACC3, ACCA=ACCA, CA=CA, CW=CW, GOAL=GOAL, LIM=LIM, Lk=Lk, O=O, R=R, RHSV=RHSV, RS=RS, SUM=SUM, V1=V1, V2=V2, YY=YY, s=s))
    PS = 'VRC.PV3(y0, y1, y2)'
    for i in reversed(range(4)):
        cases = []
        for c in CONS:
            if i < 3 and c.startswith('S.Items'):
                cases.append(f'    case S.Items{{+h, +r}}: fm{i}({CA}{ACCA(i)}, h, Codec.parts(h, {SCH[i]}), DS.facts(h, {SCH[i]}, {{==}}), {{==}}, r, e)')
            elif i == 3 and c == 'S.EmptyItems{}':
                cases.append(f'    case S.EmptyItems{{}}: fin({CA}{ACCA(3)}, Bool.and(Layout.bytes_valid({PS}), N.fits(4n, Nat.add(Layout.fixed_size({PS}), List.length(&2, U32, Layout.payloads({PS}))))), e)')
            else:
                cases.append(f'    case {c}: {ABS("e")}')
        ST = f"""
def st{i}({CW}{ACCT(i)}, +items: S.Value,
    +e: {E(i, f'Codec.parts(items, {ch(i)})')}) -> {GOAL}:
  match items:
""" + '\n'.join(cases) + '\n'
        if i == 3:
            w(ST)
            continue
        w(f"""
def fp{i}({CW}{ACCT(i)}, +h: S.Value, +ps: +List<S.Part>, hf: DF.single(None{{}}, ps),
    +em: {{Codec.parts(h, {SCH[i]}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}}, +r: S.Value,
    +e: {E(i, f'Codec.concatenate(Some{{ps}}, Codec.parts(r, {ch(i + 1)}))')}) -> {GOAL}:
  match ps:
    case Nil{{}}: Empty.absurd({GOAL}, hf)
    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))
    case Con{{S.Variable{{+ys}}, Nil{{}}}}:
      st{i + 1}({CA}{ACCA(i)}, ys, C{i}.linvr(h, ys, Equal.cong(Maybe<&2, +List<S.Part>>, Maybe<&2, +List<U32>>, z => Codec.bytes(z), Codec.parts(h, {SCH[i]}), Some{{[S.Variable{{ys}}]}}, em)), r, e)
    case Con{{S.Fixed{{+xs}}, Con{{+a, +b}}}}: Empty.absurd({GOAL}, hf)
    case Con{{S.Variable{{+xs}}, Con{{+a, +b}}}}: Empty.absurd({GOAL}, hf)

def fm{i}({CW}{ACCT(i)}, +h: S.Value, +mm: Maybe<&2, +List<S.Part>>, hf: DF.single_result(None{{}}, mm),
    +em: {{Codec.parts(h, {SCH[i]}) == mm : Maybe<&2, +List<S.Part>>}}, +r: S.Value,
    +e: {E(i, f'Codec.concatenate(mm, Codec.parts(r, {ch(i + 1)}))')}) -> {GOAL}:
  match mm:
    case None{{}}: {ABS("e")}
    case Some{{+ps}}: fp{i}({CA}{ACCA(i)}, h, ps, hf, em, r, e)
""")
        w(ST)
    vc = '\n'.join(f'    case S.Sequence{{+items}}: st0({CA}, items, e)' if c.startswith('S.Sequence') else f'    case {c}: {ABS("e")}' for c in CONS)
    w(TPL.render('er_text_invw', CW=CW, GOAL=GOAL, RHSV=RHSV, vc=vc))
    return [inline(b) for b in L], dict(CW=CW, CA=CA, TXO=TXO, P=P, O=O, Lk=Lk, Xk=Xk, Fk=Fk, Yk=Yk, RHSV=RHSV, SCH=SCH, ACCT=ACCT, ACCA=ACCA, ch=ch, cc=cc, E=E,
                   GOAL=GOAL, ABS=ABS, CONS=CONS, s=s, V1=V1, V2=V2, SUM=SUM)


def inline(block):
    """Replace `+RHS = X` / `+RHS3 = X` lets (lets of pairs need annotations) by X."""
    import re
    out, rhs = [], {}
    for line in block.split('\n'):
        if line.startswith('def '):
            rhs = {}
        m = re.match(r'  \+(RHS3?) = (.*)$', line)
        if m:
            rhs[m.group(1)] = m.group(2)
            continue
        for k, v in rhs.items():
            line = re.sub(r'(?<![\w.])' + k + r'(?![\w])', lambda _m: v, line)
        out.append(line)
    return '\n'.join(out)


def top_text(HEAD):
    """The whole-buffer decoder laws of ExecutionRequests: the window at x = 0, off = 0, len = n."""
    L = list(HEAD) + ['import ../../spec/decoding_relation.bend as Decoding',
                      'import ../../proofs/decode_unique.bend as DCO', 'import ./var_winx_ExecutionRequests.bend as EW', '',
                      '# GENERATED by var_rlist (codegen: var_rlist_er). Do not edit.',
                      f'# {X}: the decoder laws over a whole buffer, from its byte-offset window module at x = 0.', '']
    H = (f'+d: Nat, +t: {TR}, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},\n'
         f'    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == {TRUE}}}')
    LH = ('  for +d: Nat\n  for +t: FD.array__Tree<U32>\n  for +n: U32\n  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}\n'
          '  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}\n  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}\n')
    RT = f'B.Buf & Maybe<&1, T.{X}>'
    WA = 'd, t, n, 0n, 0, n, {==}, hd, hn, pf'
    L.append(TPL.render('top_text', H=H, LH=LH, RT=RT, WA=WA))
    return '\n'.join(L) + '\n'
