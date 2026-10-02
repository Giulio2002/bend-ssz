#!/usr/bin/env python3
"""Byte-offset window modules (the interface of proofs/obj/vua_win.bend) of LISTS OF
FIXED-SIZE RECORDS, e.g. ExecutionRequests' deposits.

    python3 codegen/proofs/var/record_list_offset_windows.py [--check]

Writes proofs/obj/vrl.bend (from codegen/templates/vrl.bend.in: Array.set on a perfect tree of
any element type, positions of consecutive records) and, for each list type below,
proofs/obj/var_winx_<p>.bend exporting CHKw, ok_evalw, OBJw, readw, VALw, specw, invw
and linvr (what the spec encoding of any value of the list says about its bytes).

The reader reads record j at byte position x + R j (vua_fix.rdx_<record>): its words
are the four-byte joins UR.RWN(t, x + R j + 4 k). The object's record array is the tree
RT of those records; the value's items are the records' values over the same words,
whose parts are the window's bytes (UW.headWX, UR.rws_bytes).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.proofs.var.check_or_write_outputs import finish  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import typed_object_runtime as G  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.proofs.var import single_list_container_codec_laws as VLW  # noqa: E402
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('record_list_offset_windows', globals())

LISTS = [('ExecutionRequests', 'deposits'), ('ExecutionRequests', 'withdrawals'), ('ExecutionRequests', 'consolidations'),
         ('BeaconBlockBody', 'voluntary_exits'), ('BeaconBlockBody', 'bls_to_execution_changes'), ('ExecutionPayload', 'withdrawals'),
         ('BeaconState', 'eth1_data_votes'), ('BeaconState', 'historical_summaries'), ('BeaconState', 'pending_deposits'),
         ('BeaconState', 'pending_partial_withdrawals'), ('BeaconState', 'pending_consolidations')]

# A closed limit above this is evaluated only by checkq --big (stock Bend's stack holds unary
# numbers of a few thousand): such modules are big_ files.
BIG_LIM = 8192


def sym_depth(text, RS, KL):
    """rd_go's bound on the record storage depth from the window (count <= len <= 2^(d+2)),
    not from the closed limit (whose unary value exhausts the checker's memory)."""
    T = 'True{} : Bool'
    hcp = f'      +hcp = VD.wd_cover(NN(len), {KL}n, {{==}}, FD.nat__le_trans(c, U32.to_nat('
    a = text.index(hcp)
    text = text[:a] + (TPL.render('sym_depth', RS=RS, T=T)) + text[text.index('\n', a) + 1:]
    hdd = '      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), '
    a = text.index(hdd)
    text = text[:a] + '      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), 2n+d, 32n, VD.wd_min(NN(len), 2n+d, hcN), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))\n' + text[text.index('\n', a) + 1:]
    assert f'O.pow2n({KL}n)' not in text
    return text


def deep_rlist(text, RS, big):
    """A record list's window at any depth d < 31: the records' offsets below 2^32 (hw32, carried by the
    read loop as hb32), the storage depth from the window's records (at most 2^d of them: records of at
    least four bytes), the deep interface with the old one as wrappers (codegen/proofs/support/deep_window_decode_passes.py)."""
    from codegen.proofs.var import nested_type_window_laws as VWN
    T = 'True{} : Bool'
    P32 = 'FD.spec_common__pow2(32n)'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    reps = [
        # the read loop carries the record end below 2^32
        (f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == {T}}},\n",
         f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == {T}}}, +hb32: {{Nat.is_lt({POS('Nat.add(1n+k, j)')}, {P32}) == {T}}},\n"),
        (f"      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)\n",
         TPL.render('deep_rlist', P32=P32, POS=POS, RS=RS, T=T)),
        (f"      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)", f"      +ex = VRL.posU32(off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hx32)"),
        (f"VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2, hdd, hk2,", f"VRL.succU32(i, j, {RS - 1}n, x, ej, hx32), hd, pf, hb2, hb232, hdd, hk2,"),
        ("eo, {==}, hd, pf, hb, hdd, hk,", "eo, {==}, hd, pf, hb, hb32, hdd, hk,"),
        ("      +hcl = hcw(len, hchk)\n",
         TPL.render('deep_rlist_2', P32=P32, POS=POS, RS=RS, T=T)),
        ("FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf, hx)", "hd, pf, hx)"),
        ("FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf, hb0)", "hd, pf, hb0)"),
        (f"  +hf = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw)\n",
         f"  +hf = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw)\n"
         f"  +hf32 = FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(x, z), {P32}) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw32)\n"),
        (f"VFT.fits4(2n+d, Nat.mul(c, {RS}n), FD.nat__le_trans(Nat.mul(c, {RS}n), Nat.add(x, Nat.mul(c, {RS}n)), A.quad(VB.pw(d)), Order.left_below_sum(x, Nat.mul(c, {RS}n)), hf), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))",
         f"VFT.fits4lt(Nat.mul(c, {RS}n), FD.nat__le_lt_trans(Nat.mul(c, {RS}n), Nat.add(x, Nat.mul(c, {RS}n)), {P32}, Order.left_below_sum(x, Nat.mul(c, {RS}n)), hf32))"),
    ]
    for a, b in reps:
        assert text.count(a) == 1, (text.count(a), a[:90])
        text = text.replace(a, b)
    text = text.replace('VTX.rdx_', 'VTX.rdxd_')
    if big:
        a = text.index('      +hcN = ')
        b = text.index('      +hcP = ')
        text = text[:a] + (
            TPL.render('deep_rlist_3', RS=RS, T=T)) + text[b:]
        a = text.index('      +hdd = ')
        text = text[:a] + '      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), d, 32n, VD.wd_min(NN(len), d, hcN), FD.nat__lt_trans(d, 31n, 32n, hd, {==}))\n' + text[text.index('\n', a) + 1:]
    assert 'nat__lt_trans(d, 28n' not in text, [l for l in text.split('\n') if 'nat__lt_trans(d, 28n' in l][:2]
    return VWN.deep_x(text)


def deep_box(text, RS, R):
    """deep_rlist for the boxed-record lists (codegen/proofs/var/boxed_record_list_windows.py's reader: no record tree)."""
    from codegen.proofs.var import nested_type_window_laws as VWN
    T = 'True{} : Bool'
    P32 = 'FD.spec_common__pow2(32n)'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    HB = f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == {T}}}"
    reps = [
        (HB + ')', HB + f", +hb32: {{Nat.is_lt({POS('Nat.add(1n+k, j)')}, {P32}) == {T}}})"),
        (f"      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)\n",
         TPL.render('deep_box', P32=P32, POS=POS, RS=RS, T=T)),
        (f"      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)", f"      +ex = VRL.posU32(off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hx32)"),
        (f"VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2)", f"VRL.succU32(i, j, {RS - 1}n, x, ej, hx32), hd, pf, hb2, hb232)"),
        ("eo, {==}, hd, pf, hb)) :", "eo, {==}, hd, pf, hb, hb32)) :"),
        ("      +hb0 = ",
         TPL.render('deep_box_2', P32=P32, POS=POS, RS=RS, T=T)),
        (f"  +hf = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw)\n",
         f"  +hf = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw)\n"
         f"  +hf32 = FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(x, z), {P32}) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw32)\n"),
        (f"VFT.fits4(2n+d, Nat.mul(c, {RS}n), FD.nat__le_trans(Nat.mul(c, {RS}n), Nat.add(x, Nat.mul(c, {RS}n)), A.quad(VB.pw(d)), Order.left_below_sum(x, Nat.mul(c, {RS}n)), hf), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))",
         f"VFT.fits4lt(Nat.mul(c, {RS}n), FD.nat__le_lt_trans(Nat.mul(c, {RS}n), Nat.add(x, Nat.mul(c, {RS}n)), {P32}, Order.left_below_sum(x, Nat.mul(c, {RS}n)), hf32))"),
    ]
    for a, b in reps:
        assert text.count(a) == 1, (text.count(a), a[:90])
        text = text.replace(a, b)
    text = text.replace(f'VXB.rdbx_{R}(', f'VXB.rdbxd_{R}(').replace('FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf, hx)', 'hd, pf, hx)').replace('FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf, hb0)', 'hd, pf, hb0)')
    assert 'nat__lt_trans(d, 28n' not in text, [l for l in text.split('\n') if 'nat__lt_trans(d, 28n' in l][:2]
    return VWN.deep_x(text)


def deep_er(text):
    """ExecutionRequests' window at any depth d < 31 (the children's deep interface, offsets below 2^32)."""
    from codegen.proofs.var import nested_type_window_laws as VWN
    CA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    P32 = 'FD.spec_common__pow2(32n)'
    T = 'True{} : Bool'
    reps = [
        ('UR.offx(d, off, c, x, eo, FD.nat__lt_trans(d, 28n, 30n, hd, {==}),', 'UR.offx31(d, off, c, x, eo, hd,'),
        (f"""  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(2n+d, 30n, 31n, hd, {{==}}),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == {T}}}, Nat.add(x, U32.to_nat(c)), Nat.add(U32.to_nat(c), x), FD.nat__add_comm(x, U32.to_nat(c)), xle({CA}, c, hc)))""",
         f"""  VB.add_lt32(off, c, x, eo,
    FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == {T}}}, Nat.add(x, U32.to_nat(c)), Nat.add(U32.to_nat(c), x), FD.nat__add_comm(x, U32.to_nat(c)),
      FD.nat__le_lt_trans(Nat.add(x, U32.to_nat(c)), Nat.add(x, U32.to_nat(len)), {P32}, Order.add_left(x, U32.to_nat(c), U32.to_nat(len), hc), hw32)))"""),
        ("VFT.fits4(2n+d, U32.to_nat(len), FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))",
         "VFT.fits4lt(U32.to_nat(len), VB.u32_lt(len))"),
    ]
    for a, b in reps:
        assert text.count(a) == 1, (text.count(a), a[:80])
        text = text.replace(a, b)
    # the offset words' digits: every value within a U32 length is below 2^32
    a = text.index('VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),')
    b = text.index('hv),', a) + len('hv),')
    text = text[:a] + 'VFT.fits4lt(v, VB.le_n_lt32(v, len, hv)),' + text[b:]
    # the children's windows end below 2^32
    add = []
    for k in range(3):
        a = text.index(f'\ndef hw{k}(')
        b = text.index('\n  VRC.winb(', a)
        hdr = text[a + 1:b].replace(f'def hw{k}(', f'def hw{k}_32(')
        hdr = hdr.replace('A.quad(VB.pw(d))) == True{} : Bool}:', f'{P32}) == True{{}} : Bool}}:').replace('-> {Nat.is_le(Nat.add(X', '-> {Nat.is_lt(Nat.add(X')
        body = text[b + 1:text.index('\n', b + 1)]
        assert body.startswith('  VRC.winb(') and body.endswith(')'), body
        wa = [x_.strip() for x_ in _split(body[len('  VRC.winb('):-1])]
        o, e, lk, xl = wa[0], wa[1], wa[4], wa[5]
        assert wa[2] == 'x' and xl.startswith('xle(') and xl.endswith(')'), wa
        xa = [x_.strip() for x_ in _split(xl[len('xle('):-1])]
        assert xa[-2] == e, (xa, e)
        he = xa[-1]
        E = f'Nat.add(x, U32.to_nat({e}))'
        add.append(hdr + f'\n  FD.nat__le_lt_trans(Nat.add(X{k}(t, x), U32.to_nat({["L0(t, x)", "L1(t, x)", "L2(t, x, len)"][k]})), {E}, {P32},\n'
                   f'    VRC.winb({o}, {e}, x, {E}, {lk}, FD.nat__le_refl({E})),\n'
                   f'    FD.nat__le_lt_trans({E}, Nat.add(x, U32.to_nat(len)), {P32}, Order.add_left(x, U32.to_nat({e}), U32.to_nat(len), {he}), hw32))\n')
    a = text.index('\ndef eo0(')
    text = text[:a + 1] + '\n'.join(add) + text[a + 1:]
    for k in range(3):
        for nm in ('readw', 'specw'):
            pat = f'C{k}.{nm}('
            i = text.index(pat)
            j = VWN_close(text, i + len(pat))
            args = _split(text[i + len(pat):j])
            h = args[8].strip()
            h32 = f'hw{k}_32({CA}, hchk)'
            args.insert(9, ' ' + h32)
            text = text[:i] + f'C{k}.{nm}D(' + ','.join(args) + text[j:]
    return VWN.deep_x(text)


def VWN_close(s, i):
    from codegen.proofs.support import deep_window_decode_passes as deep
    return deep._close(s, i)


def _split(s):
    from codegen.proofs.support import deep_window_decode_passes as deep
    return deep._split_args(s)


def deep_er_top(text):
    """The whole-buffer laws at any depth d < 31: the window at 0 ends at n < 2^32."""
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)').replace(', hd, hn, pf', ', hd, hn, VB.u32_lt(n), pf')
    for nm in ('ok_evalw', 'readw', 'specw', 'invw'):
        text = text.replace(f'EW.{nm}(', f'EW.{nm}D(')
    return text


def winx_name(p, LIM):
    return f'{"" if LIM > BIG_LIM else ""}var_winx_{p}.bend'

# lists of boxed records (codegen/proofs/var/boxed_record_list_windows.py)
BOXLISTS = [('BeaconBlockBody', 'proposer_slashings'), ('BeaconBlockBody', 'deposits')]
# packed lists of byte vectors (codegen/proofs/var/byte_vector_list_windows.py)
BVLISTS = [('BeaconBlockBody', 'blob_kzg_commitments'), ('BeaconState', 'historical_roots')]

HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
        'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
        'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD', 'import ./vfits.bend as VFT', 'import ./vmr.bend as VMR',
        'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_win.bend as UW', 'import ./vua_fix.bend as VTX',
        'import ./vrl.bend as VRL']


def log2c(n):
    k = 0
    while (1 << k) < n:
        k += 1
    return k


def info(g, names, parent, field):
    ft = dict(names[parent].fields)[field]
    s = g.shape(ft)
    rt = ft.elem
    RS = rt.fixed_size()
    assert RS % 4 == 0
    return dict(p=s.p, R=rt.name, rt=rt, RS=RS, W=RS // 4, LIM=ft.size, KL=log2c(ft.size))


def rec_node(g, rt):
    """The record's object and walk node over the words UR.RWN(t, y + 4 k)."""
    word = lambda k: 'UR.RWN(t, y)' if k == 0 else f'UR.RWN(t, {4 * k}n+y)'
    ftp = VLW.FT(g, rt)
    obj = ftp.obj([word(k) for k in range(ftp.W)])
    nd = VLW.SL.walk(g, rt, iter(range(100000)))
    mp = {int(w_[1:]): word(j) for j, w_ in enumerate(nd.words)}
    return obj, VLW.subst_words(nd.val, mp), nd.sch, VLW.subst_words(nd.proof, mp), ftp.p


def list_text(g, names, parent, field, rec=None):
    I = info(g, names, parent, field)
    p, R, RS, W, LIM, KL = I['p'], I['R'], I['RS'], I['W'], I['LIM'], I['KL']
    obj, val, sch, proof, rp = rec or rec_node(g, I['rt'])
    TR = 'FD.array__Tree<U32>'
    TRR = f'FD.array__Tree<T.{R}>'
    TRUE = 'True{} : Bool'
    LSCH = f'S.ListOf{{{sch}, U32.to_nat({LIM})}}'
    CW = (f'+d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {{U32.to_nat(off) == x : Nat}},\n'
          f'    +hd: {{Nat.is_lt(d, 28n) == {TRUE}}}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == {TRUE}}},\n'
          f'    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}')
    CA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    HC = f'+hchk: {{CHKw(t, x, off, len) == {TRUE}}}'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    RD = f'B.Buf & Array<T.{R}>'
    L = list(HEAD) + ['', f'# GENERATED by record_list_offset_windows (codegen). Do not edit.',
                      f'# The byte-offset window module of {p} (List[{R}, {LIM}], records of {RS} bytes): see the',
                      '# module docstring of codegen/proofs/var/record_list_offset_windows.py and the interface in proofs/obj/vua_win.bend.', '']
    w = L.append
    RWL = '[' + ', '.join('UR.RWN(t, y)' if j == 0 else f'UR.RWN(t, {4 * j}n+y)' for j in range(W)) + ']'
    w(TPL.render('list_text', CA=CA, CW=CW, HC=HC, KL=KL, LIM=LIM, LSCH=LSCH, POS=POS, R=R, RD=RD, RS=RS, RWL=RWL, TR=TR, TRR=TRR, TRUE=TRUE, W=W, obj=obj, p=p, proof=proof, rp=rp, sch=sch, val=val))
    w(inv_text(sch, RS, LIM, LSCH, CW, CA))
    out = '\n'.join(L) + '\n'
    return out.replace('\n  +RHS = Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]}\n', '\n').replace(' == RHS :', ' == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} :')



def inv_text(sch, RS, LIM, LSCH, CW, CA):
    """The inversion: every value whose parts are the window's bytes passes CHKw (whole records of RS bytes)."""
    TRUE = 'True{} : Bool'
    return TPL.render('inv_text', CA=CA, CW=CW, LIM=LIM, LSCH=LSCH, RS=RS, TRUE=TRUE, sch=sch)


def outputs():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    out = {ROOT / 'proofs/obj/vrl.bend': (ROOT / 'codegen/templates/vrl.bend.in').read_text(),
           ROOT / 'proofs/obj/vrc.bend': (ROOT / 'codegen/templates/vrc.bend.in').read_text()}
    for parent, field in LISTS:
        I = info(g, names, parent, field)
        VLW.SL.HOIST = True   # nested fixed records' proofs as lemmas over their words (spec_connected_codec_laws.HOIST)
        VLW.SL.hoist_take()
        txt = list_text(g, names, parent, field)
        VLW.SL.HOIST = False
        txt = txt.replace('\ndef RX(', '\n' + VLW.SL.hoist_take() + 'def RX(', 1)
        if I['LIM'] > BIG_LIM:
            txt = sym_depth(txt, I['RS'], I['KL'])
        txt = deep_rlist(txt, I['RS'], I['LIM'] > BIG_LIM)
        out[ROOT / f'proofs/obj/{winx_name(I["p"], I["LIM"])}'] = txt
    from codegen.proofs.var import boxed_record_list_windows as BX
    out[ROOT / 'proofs/obj/vua_fixb.bend'] = BX.fixb_module(g, [dict(names[pa].fields)[f].elem for pa, f in BOXLISTS])
    for parent, field in BOXLISTS:
        I = info(g, names, parent, field)
        VLW.SL.HOIST = True
        VLW.SL.hoist_take()
        rec, needs_d = BX.list_rec(g, I['rt'])
        VLW.SL.HOIST = False
        hz = VLW.SL.hoist_take()
        txt = list_text(g, names, parent, field, rec).replace('\ndef RX(', '\n' + hz + 'def RX(', 1)
        out[ROOT / f'proofs/obj/var_winx_{I["p"]}.bend'] = deep_box(BX.post_box(txt, I['p'], I['R'], I['RS'], needs_d), I['RS'], I['R'])
    from codegen.proofs.var import byte_vector_list_windows as BV
    from codegen.proofs.var import nested_type_window_laws as VWN
    for parent, field in BVLISTS:
        ft = dict(names[parent].fields)[field]
        B, N, p = ft.elem.fixed_size(), ft.size, g.shape(ft).p
        out[ROOT / f'proofs/obj/{winx_name(p, N)}'] = BV.bvx_text(HEAD, VWN.zeros_at_text, inv_text, p, B, N, f'S.ByteVector{{{B}n}}',
                                                                  f'S.ListOf{{S.ByteVector{{{B}n}}, U32.to_nat({N})}}', N > BIG_LIM, deep=True)
    from codegen.proofs.var import execution_requests_window as ER
    LS = []
    for field in ('deposits', 'withdrawals', 'consolidations'):
        I = info(g, names, 'ExecutionRequests', field)
        sch = rec_node(g, I['rt'])[2]
        LS.append(dict(p=I['p'], RS=I['RS'], LIM=I['LIM'], LSCH=f'S.ListOf{{{sch}, U32.to_nat({I["LIM"]})}}'))
    L, _ = ER.er_text(HEAD, LS)
    out[ROOT / 'proofs/obj/var_winx_ExecutionRequests.bend'] = deep_er('\n'.join(L) + '\n')
    out[ROOT / 'proofs/obj/var_codec_ExecutionRequests.bend'] = deep_er_top(ER.top_text(HEAD))
    from codegen.proofs.var import execution_requests_encoder_laws as EN
    fts, recs = [], []
    for field in ('deposits', 'withdrawals', 'consolidations'):
        rt = dict(names['ExecutionRequests'].fields)[field].elem
        for dep in VLW.FT(g, rt).deps():
            if dep.p not in [f_.p for f_ in fts]:
                fts.append(dep)
    from codegen.proofs.support import deep_window_decode_passes as deep
    out[ROOT / 'proofs/obj/var_fix_put_er.bend'] = deep.dify_fix(EN.fixput_text(VLW, fts))
    LT = list(HEAD) + ['import ./vfix.bend as VF', 'import ./venc2.bend as V2', 'import ./var_fix_put_er.bend as VT2', '',
                       '# GENERATED by record_list_offset_windows (codegen: execution_requests_encoder_laws). Do not edit.',
                       '# ExecutionRequests\' records and lists, writer side: see codegen/proofs/var/execution_requests_encoder_laws.py.', '']
    for field in ('deposits', 'withdrawals', 'consolidations'):
        I = info(g, names, 'ExecutionRequests', field)
        nd = VLW.SL.walk(g, I['rt'], iter(range(100000)))
        txt, ft = EN.rec_text(VLW, g, I['rt'], (nd.val, nd.sch, nd.proof))
        LT.append(txt)
        LT.append(ER.inline(EN.list_text(I['p'], I['R'], I['RS'], I['W'], I['LIM'], I['KL'])))
        LT.append(EN.spec_list_text(I['p'], I['R'], I['RS'], I['W'], I['LIM'], nd.sch))
        LT.append(EN.lw_text(I['p'], I['R'], I['W']))
    out[ROOT / 'proofs/obj/var_rlenc_ExecutionRequests.bend'] = '\n'.join(LT) + '\n'
    LSE = []
    for field in ('deposits', 'withdrawals', 'consolidations'):
        I = info(g, names, 'ExecutionRequests', field)
        nd = VLW.SL.walk(g, I['rt'], iter(range(100000)))
        LSE.append(dict(p=I['p'], R=I['R'], RS=I['RS'], W=I['W'], LIM=I['LIM'], sch=nd.sch))
    BL, BP = EN.big_text(HEAD + ['import ./vlist.bend as VL', 'import ./venc2.bend as V2', 'import ../../spec/decoding_relation.bend as Decoding'], LSE)
    BL += EN.spec_big_text(BP, LSE)
    out[ROOT / 'proofs/obj/var_codec_ExecutionRequests_enc.bend'] = '\n'.join(ER.inline(b) for b in BL) + '\n'
    return out


def main():
    # accepts '--check' (check_or_write_outputs.finish reads it)
    VLW.SL.EXACT = True   # the exact spec-parts proofs (codegen/proofs/laws/spec_connected_codec_laws.py), before any walk
    def posww_hw(out):
        # VRL.posWW takes hW: 1 <= W (the record's word count, a literal) before hb
        return {p: re.sub(r'(VRL\.posWW\(dd, pos, Q, i, j, \d+, \d+n, \{==\}, ep, ei, hdd), ', r'\1, {==}, ', t) for p, t in out.items()}
    return finish(outputs(), 'stale: ', 'record-list windows are current', dify=dict(handled={'posWW'}), final=posww_hw)


if __name__ == '__main__':
    main()
