#!/usr/bin/env python3
"""Byte-offset window modules (the interface of proofs/obj/vua_win.bend) of LISTS OF
FIXED-SIZE RECORDS, e.g. ExecutionRequests' deposits.

    python3 codegen/var_rlist.py [--check]

Writes proofs/obj/vrl.bend (from codegen/vrl.bend.in: Array.set on a perfect tree of
any element type, positions of consecutive records) and, for each list type below,
proofs/obj/var_winx_<p>.bend exporting CHKw, ok_evalw, OBJw, readw, VALw, specw, invw
and linvr (what the spec encoding of any value of the list says about its bytes).

The reader reads record j at byte position x + R j (vua_fix.rdx_<record>): its words
are the four-byte joins UR.RWN(t, x + R j + 4 k). The object's record array is the tree
RT of those records; the value's items are the records' values over the same words,
whose parts are the window's bytes (UW.headWX, UR.rws_bytes).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
import generate as G  # noqa: E402
import schema  # noqa: E402
import var_laws as VLW  # noqa: E402

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
    text = text[:a] + (f'      +hcN = FD.logic__subst(Nat, z => {{Nat.is_le(c, z) == {T}}}, VB.pw(2n+d), O.pow2n(2n+d), VD.s_pow2_eq(2n+d),\n'
                       f'        FD.nat__le_trans(c, Nat.mul(c, {RS}n), VB.pw(2n+d), VRL.le_mul(c, {RS - 1}n),\n'
                       f'          FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(2n+d)) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec,\n'
                       f'            FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw))))\n'
                       f'      +hcp = VD.wd_cover(NN(len), 2n+d, FD.nat__lt_le(d, 30n, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}})), hcN)\n') + text[text.index('\n', a) + 1:]
    hdd = '      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), '
    a = text.index(hdd)
    text = text[:a] + '      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), 2n+d, 32n, VD.wd_min(NN(len), 2n+d, hcN), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))\n' + text[text.index('\n', a) + 1:]
    assert f'O.pow2n({KL}n)' not in text
    return text


def deep_rlist(text, RS, big):
    """A record list's window at any depth d < 31: the records' offsets below 2^32 (hw32, carried by the
    read loop as hb32), the storage depth from the window's records (at most 2^d of them: records of at
    least four bytes), the deep interface with the old one as wrappers (codegen/deep.py)."""
    import var_win as VWN
    T = 'True{} : Bool'
    P32 = 'FD.spec_common__pow2(32n)'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    reps = [
        # the read loop carries the record end below 2^32
        (f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == {T}}},\n",
         f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == {T}}}, +hb32: {{Nat.is_lt({POS('Nat.add(1n+k, j)')}, {P32}) == {T}}},\n"),
        (f"      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)\n",
         f"      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)\n"
         f"      +hx32 = FD.nat__le_lt_trans(Nat.add({POS('1n+j')}, {RS}n), {POS('Nat.add(2n+q, j)')}, {P32},\n"
         f"        VRL.nextfit(j, q, {RS}n, x, {POS('Nat.add(2n+q, j)')}, FD.nat__le_refl({POS('Nat.add(2n+q, j)')})), hb32)\n"
         f"      +hb232 = FD.logic__subst(Nat, z => {{Nat.is_lt(VRL.pos(1n+z, {RS}n, x), {P32}) == {T}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb32)\n"),
        (f"      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)", f"      +ex = VRL.posU32(off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hx32)"),
        (f"VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2, hdd, hk2,", f"VRL.succU32(i, j, {RS - 1}n, x, ej, hx32), hd, pf, hb2, hb232, hdd, hk2,"),
        ("eo, {==}, hd, pf, hb, hdd, hk,", "eo, {==}, hd, pf, hb, hb32, hdd, hk,"),
        ("      +hcl = hcw(len, hchk)\n",
         f"      +hL32 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == {T}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32)\n"
         f"      +hLc32 = FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, x), {P32}) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hL32)\n"
         f"      +hb32 = FD.logic__subst(Nat, z => {{Nat.is_lt({POS('z')}, {P32}) == {T}}}, c, Nat.add(1n+k, 0n),\n"
         f"        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), hLc32)\n"
         "      +hcl = hcw(len, hchk)\n"),
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
            f'      +hcN = FD.logic__subst(Nat, z => {{Nat.is_le(c, z) == {T}}}, VB.pw(d), O.pow2n(d), VD.s_pow2_eq(d),\n'
            f'        VC.quad_inv(c, VB.pw(d), FD.nat__le_trans(A.quad(c), Nat.mul(c, {RS}n), A.quad(VB.pw(d)), VRL.quad_le_mul(c, {RS - 4}n),\n'
            f'          FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec,\n'
            f'            FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw)))))\n'
            f'      +hcp = VD.wd_cover(NN(len), d, FD.nat__lt_le(d, 32n, FD.nat__lt_trans(d, 31n, 32n, hd, {{==}})), hcN)\n') + text[b:]
        a = text.index('      +hdd = ')
        text = text[:a] + '      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), d, 32n, VD.wd_min(NN(len), d, hcN), FD.nat__lt_trans(d, 31n, 32n, hd, {==}))\n' + text[text.index('\n', a) + 1:]
    assert 'nat__lt_trans(d, 28n' not in text, [l for l in text.split('\n') if 'nat__lt_trans(d, 28n' in l][:2]
    return VWN.deep_x(text)


def deep_box(text, RS, R):
    """deep_rlist for the boxed-record lists (codegen/var_rlist_box.py's reader: no record tree)."""
    import var_win as VWN
    T = 'True{} : Bool'
    P32 = 'FD.spec_common__pow2(32n)'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    HB = f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == {T}}}"
    reps = [
        (HB + ')', HB + f", +hb32: {{Nat.is_lt({POS('Nat.add(1n+k, j)')}, {P32}) == {T}}})"),
        (f"      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)\n",
         f"      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)\n"
         f"      +hx32 = FD.nat__le_lt_trans(Nat.add({POS('1n+j')}, {RS}n), {POS('Nat.add(2n+q, j)')}, {P32},\n"
         f"        VRL.nextfit(j, q, {RS}n, x, {POS('Nat.add(2n+q, j)')}, FD.nat__le_refl({POS('Nat.add(2n+q, j)')})), hb32)\n"
         f"      +hb232 = FD.logic__subst(Nat, z => {{Nat.is_lt(VRL.pos(1n+z, {RS}n, x), {P32}) == {T}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb32)\n"),
        (f"      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)", f"      +ex = VRL.posU32(off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hx32)"),
        (f"VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2)", f"VRL.succU32(i, j, {RS - 1}n, x, ej, hx32), hd, pf, hb2, hb232)"),
        ("eo, {==}, hd, pf, hb)) :", "eo, {==}, hd, pf, hb, hb32)) :"),
        ("      +hb0 = ",
         f"      +hL32 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == {T}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32)\n"
         f"      +hLc32 = FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, x), {P32}) == {T}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hL32)\n"
         f"      +hb32 = FD.logic__subst(Nat, z => {{Nat.is_lt({POS('z')}, {P32}) == {T}}}, c, Nat.add(1n+k, 0n),\n"
         f"        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), hLc32)\n"
         "      +hb0 = "),
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
    import re as _re
    import var_win as VWN
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
    import deep
    return deep._close(s, i)


def _split(s):
    import deep
    return deep._split_args(s)


def deep_er_top(text):
    """The whole-buffer laws at any depth d < 31: the window at 0 ends at n < 2^32."""
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)').replace(', hd, hn, pf', ', hd, hn, VB.u32_lt(n), pf')
    for nm in ('ok_evalw', 'readw', 'specw', 'invw'):
        text = text.replace(f'EW.{nm}(', f'EW.{nm}D(')
    return text


def winx_name(p, LIM):
    return f'{"" if LIM > BIG_LIM else ""}var_winx_{p}.bend'

# lists of boxed records (codegen/var_rlist_box.py)
BOXLISTS = [('BeaconBlockBody', 'proposer_slashings'), ('BeaconBlockBody', 'deposits')]
# packed lists of byte vectors (codegen/var_rlist_bv.py)
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
    L = list(HEAD) + ['', f'# GENERATED by codegen/var_rlist.py. Do not edit.',
                      f'# The byte-offset window module of {p} (List[{R}, {LIM}], records of {RS} bytes): see the',
                      '# module docstring of codegen/var_rlist.py and the interface in proofs/obj/vua_win.bend.', '']
    w = L.append
    RWL = '[' + ', '.join('UR.RWN(t, y)' if j == 0 else f'UR.RWN(t, {4 * j}n+y)' for j in range(W)) + ']'
    w(f'''def BF(t: {TR}, +n: U32) -> B.Buf: UA.BF(t, n)

# ---- the records ---------------------------------------------------------------------------------

# the record whose words are the four-byte joins at y, y + 4, ...
def RX(+t: {TR}, +y: Nat) -> T.{R}: {obj}

# its spec value, and that value's parts: the limbs of those words
def RVAL(+t: {TR}, +y: Nat) -> S.Value: {val}
# (RVAL unfolded by a rewrite: comparing parts(RVAL(t, y), s) with parts(<its body>, s) evaluates the parts)
def RVQ(+t: {TR}, +y: Nat) -> {{{val} == RVAL(t, y) : S.Value}}:
  {{==}}
# (RWS unfolded by a rewrite too: F.limbs of RWS against F.limbs of the written-out words would expand both
# into bytes and compare them one level per byte)
def RWSQ(+t: {TR}, +y: Nat) -> {{{RWL} == UR.RWS({W}n, t, y) : List<&2, U32>}}:
  {{==}}
def RPRF(+t: {TR}, +y: Nat) -> {{Codec.parts(RVAL(t, y), {sch}) == Some{{[S.Fixed{{F.limbs(UR.RWS({W}n, t, y))}}]}} : Maybe<&2, +List<S.Part>>}}:
  %RVQ(t, y) : {{Codec.parts(_, {sch}) == Some{{[S.Fixed{{F.limbs(UR.RWS({W}n, t, y))}}]}} : Maybe<&2, +List<S.Part>>}}
  %RWSQ(t, y) : {{Codec.parts({val}, {sch}) == Some{{[S.Fixed{{F.limbs(_)}}]}} : Maybe<&2, +List<S.Part>>}}
  {proof}

# the records j, j + 1, ..., j + k written into a record tree D
def RT(k: Nat, +j: Nat, +dd: Nat, D: {TRR}, +t: {TR}, +x: Nat) -> {TRR}:
  match k:
    case 0n: FD.array__upd(T.{R}, dd, D, j, RX(t, {POS("j")}))
    case 1n+q: RT(q, 1n+j, dd, FD.array__upd(T.{R}, dd, D, j, RX(t, {POS("j")})), t, x)

# ---- the validator ------------------------------------------------------------------------------

def CHKw(+t: {TR}, +x: Nat, +off: U32, +len: U32) -> Bool:
  Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), U32.is_le(U32.div(len, {RS}), {LIM}))

def ok_evalw({CW}) -> {{T.{p}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}}:
  {{==}}

def vR() -> Word(31n): FD.spec_numeric__from_nat(31n, {RS}n)

# The window is c whole records, c <= {LIM}.
def NN(+len: U32) -> U32: U32.div(len, {RS})
def CC(+len: U32) -> Nat: U32.to_nat(NN(len))
def ecw(+len: U32, +h: {{Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), U32.is_le(U32.div(len, {RS}), {LIM})) == {TRUE}}})
    -> {{U32.to_nat(len) == Nat.mul(CC(len), {RS}n) : Nat}}:
  Pair.fst({{U32.to_nat(len) == Nat.mul(CC(len), U32.to_nat({RS})) : Nat}}, {{Nat.is_le(CC(len), U32.to_nat({LIM})) == {TRUE}}}, VU.whole_t(len, {RS}, {LIM}, vR(), {{==}}, {{==}}, {{==}}, h))
def hcw(+len: U32, +h: {{Bool.and(U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32)), U32.is_le(U32.div(len, {RS}), {LIM})) == {TRUE}}})
    -> {{Nat.is_le(CC(len), U32.to_nat({LIM})) == {TRUE}}}:
  Pair.snd({{U32.to_nat(len) == Nat.mul(CC(len), U32.to_nat({RS})) : Nat}}, {{Nat.is_le(CC(len), U32.to_nat({LIM})) == {TRUE}}}, VU.whole_t(len, {RS}, {LIM}, vR(), {{==}}, {{==}}, {{==}}, h))

# ---- the reader ---------------------------------------------------------------------------------

def LOBJ(e: Bool, +t: {TR}, +x: Nat, +len: U32) -> T.{p}_Seq:
  match e:
    case True{{}}: T.{p}_Seq{{T.{p}_fill(0n), 0}}
    case False{{}}: T.{p}_Seq{{FD.array__thaw(T.{R}, RT(U32.to_nat(U32.sub(NN(len), 1)), 0n, B.words_depth(NN(len)), FD.array__trep(T.{R}, B.words_depth(NN(len)), T.{R}_default()), t, x)), NN(len)}}
def OBJw(+d: Nat, +t: {TR}, +x: Nat, +off: U32, +len: U32) -> T.{p}_Seq: LOBJ(U32.is_eq(len, 0), t, x, len)

# The read loop from record j (index i) on.
def lp(k: Nat, +d: Nat, +t: {TR}, +n: U32, +x: Nat, +off: U32, +i: U32, +j: Nat, +dd: Nat, +D: {TRR},
    +eo: {{U32.to_nat(off) == x : Nat}}, +ej: {{U32.to_nat(i) == j : Nat}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},
    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +hb: {{Nat.is_le({POS("Nat.add(1n+k, j)")}, A.quad(VB.pw(d))) == {TRUE}}},
    +hdd: {{Nat.is_lt(dd, 32n) == {TRUE}}}, +hk: {{Nat.is_lt(Nat.add(k, j), VB.pw(dd)) == {TRUE}}},
    +pfD: {{FD.array__perfect(T.{R}, dd, D) == {TRUE}}})
    -> {{T.{p}_rd(k, i, off, FD.array__thaw(T.{R}, D), (BF(t, n), RX(t, {POS("j")}))) == (BF(t, n), FD.array__thaw(T.{R}, RT(k, j, dd, D, t, x))) : {RD}}}:
  match k:
    case 0n:
      %Equal.sym(Array<T.{R}>, Array.set(T.{R}, FD.array__thaw(T.{R}, D), i, RX(t, {POS("j")})), FD.array__thaw(T.{R}, FD.array__upd(T.{R}, dd, D, j, RX(t, {POS("j")}))),
          VRL.set_g(T.{R}, dd, D, i, j, RX(t, {POS("j")}), T.{R}_default(), ej, hdd, hk, pfD)) :
        {{(BF(t, n), _) == (BF(t, n), FD.array__thaw(T.{R}, RT(0n, j, dd, D, t, x))) : {RD}}}
      {{==}}
    case 1n+ +q:
      +v = RX(t, {POS("j")})
      +D1 = FD.array__upd(T.{R}, dd, D, j, v)
      +hkj = FD.nat__le_lt_trans(j, Nat.add(q, j), VB.pw(dd), Order.left_below_sum(q, j), FD.nat__lt_trans(Nat.add(q, j), 1n+Nat.add(q, j), VB.pw(dd), FD.nat__lt_succ(Nat.add(q, j)), hk))
      +hk2 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(dd)) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hk)
      +hb2 = FD.logic__subst(Nat, z => {{Nat.is_le(VRL.pos(1n+z, {RS}n, x), A.quad(VB.pw(d))) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      +hx = VRL.nextfit(j, q, {RS}n, x, A.quad(VB.pw(d)), hb)
      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)
      %Equal.sym(Array<T.{R}>, Array.set(T.{R}, FD.array__thaw(T.{R}, D), i, v), FD.array__thaw(T.{R}, D1), VRL.set_g(T.{R}, dd, D, i, j, v, T.{R}_default(), ej, hdd, hkj, pfD)) :
        {{T.{p}_rd(q, U32.add(i, 1), off, _, T.{R}_read(BF(t, n), U32.add(off, U32.mul(U32.add(i, 1), {RS})), {RS})) == (BF(t, n), FD.array__thaw(T.{R}, RT(1n+q, j, dd, D, t, x))) : {RD}}}
      %Equal.sym(B.Buf & T.{R}, T.{R}_read(BF(t, n), U32.add(off, U32.mul(U32.add(i, 1), {RS})), {RS}), (BF(t, n), RX(t, {POS("1n+j")})),
          VTX.rdx_{rp}(d, t, n, U32.add(off, U32.mul(U32.add(i, 1), {RS})), {POS("1n+j")}, ex, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), pf, hx)) :
        {{T.{p}_rd(q, U32.add(i, 1), off, FD.array__thaw(T.{R}, D1), _) == (BF(t, n), FD.array__thaw(T.{R}, RT(1n+q, j, dd, D, t, x))) : {RD}}}
      lp(q, d, t, n, x, off, U32.add(i, 1), 1n+j, dd, D1, eo, VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2, hdd, hk2, FD.array__upd_perfect(T.{R}, dd, D, j, v, pfD))

# A non-empty window holds c >= 1 records.
def cpos(+len: U32, +c: Nat, +ec: {{U32.to_nat(len) == Nat.mul(c, {RS}n) : Nat}}, +eb: {{U32.is_eq(len, 0) == False{{}} : Bool}})
    -> {{Nat.is_le(1n, c) == {TRUE}}}:
  match c:
    case 0n: Empty.absurd({{Nat.is_le(1n, 0n) == {TRUE}}}, FD.logic__true_false(Equal.trans(Bool, True{{}}, U32.is_eq(len, 0), False{{}},
      Equal.sym(Bool, U32.is_eq(len, 0), True{{}}, FD.u32alg__eq_true(len, 0, FD.u32__injective(len, 0, ec))), eb)))
    case 1n+ +p: FD.nat__zero_le(p)

def rd_go({CW}, {HC}, +b: Bool, +eb: {{U32.is_eq(len, 0) == b : Bool}})
    -> {{T.{p}_rd_start(b, off, NN(len), BF(t, n)) == (BF(t, n), LOBJ(b, t, x, len)) : B.Buf & T.{p}_Seq}}:
  match b:
    case True{{}}: {{==}}
    case False{{}}:
      +c = CC(len)
      +ec = ecw(len, hchk)
      +h1 = cpos(len, c, ec, eb)
      +k = U32.to_nat(U32.sub(NN(len), 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(NN(len), 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +P = A.quad(VB.pw(d))
      +hL = FD.logic__subst(Nat, z => {{Nat.is_le(z, P) == {TRUE}}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw)
      +hLc = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, x), P) == {TRUE}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hL)
      +hb = FD.logic__subst(Nat, z => {{Nat.is_le({POS("z")}, P) == {TRUE}}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), hLc)
      +hcl = hcw(len, hchk)
      +hcp = VD.wd_cover(NN(len), {KL}n, {{==}}, FD.nat__le_trans(c, U32.to_nat({LIM}), O.pow2n({KL}n), hcl, {{==}}))
      +hcP = FD.logic__subst(Nat, z => {{Nat.is_le(c, z) == {TRUE}}}, O.pow2n(B.words_depth(NN(len))), VB.pw(B.words_depth(NN(len))), Equal.sym(Nat, VB.pw(B.words_depth(NN(len))), O.pow2n(B.words_depth(NN(len))), VD.s_pow2_eq(B.words_depth(NN(len)))), hcp)
      +hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(B.words_depth(NN(len)))) == {TRUE}}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(B.words_depth(NN(len))), FD.logic__subst(Nat, z => {{Nat.is_lt(k, z) == {TRUE}}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hcP))
      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), {KL}n, 32n, VD.wd_min(NN(len), {KL}n, FD.nat__le_trans(c, U32.to_nat({LIM}), O.pow2n({KL}n), hcl, {{==}})), {{==}})
      +hb0 = FD.nat__le_trans(Nat.add(x, {RS}n), Nat.add(x, U32.to_nat(len)), P,
        Order.add_left(x, {RS}n, U32.to_nat(len), FD.logic__subst(Nat, z => {{Nat.is_le({RS}n, z) == {TRUE}}}, Nat.mul(c, {RS}n), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.mul(c, {RS}n), ec),
          FD.logic__subst(Nat, z => {{Nat.is_le({RS}n, Nat.mul(z, {RS}n)) == {TRUE}}}, 1n+k, c, e1, Order.below_sum({RS}n, Nat.mul(k, {RS}n))))), hw)
      +cap = B.words_depth(NN(len))
      %Equal.sym(B.Buf & T.{R}, T.{R}_read(BF(t, n), off, {RS}), (BF(t, n), RX(t, x)), VTX.rdx_{rp}(d, t, n, off, x, eo, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), pf, hb0)) :
        {{T.{p}_rd_fin(NN(len), T.{p}_rd(k, 0, off, T.{p}_fill(T.{p}_cap(NN(len))), _)) == (BF(t, n), LOBJ(False{{}}, t, x, len)) : B.Buf & T.{p}_Seq}}
      %Equal.sym(Array<T.{R}>, Array.new(T.{R}, cap, T.{R}_default()), FD.array__thaw(T.{R}, FD.array__trep(T.{R}, cap, T.{R}_default())), FD.array__new(T.{R}, cap, T.{R}_default())) :
        {{T.{p}_rd_fin(NN(len), T.{p}_rd(k, 0, off, _, (BF(t, n), RX(t, x)))) == (BF(t, n), LOBJ(False{{}}, t, x, len)) : B.Buf & T.{p}_Seq}}
      %Equal.sym({RD}, T.{p}_rd(k, 0, off, FD.array__thaw(T.{R}, FD.array__trep(T.{R}, cap, T.{R}_default())), (BF(t, n), RX(t, x))),
          (BF(t, n), FD.array__thaw(T.{R}, RT(k, 0n, cap, FD.array__trep(T.{R}, cap, T.{R}_default()), t, x))),
          lp(k, d, t, n, x, off, 0, 0n, cap, FD.array__trep(T.{R}, cap, T.{R}_default()), eo, {{==}}, hd, pf, hb, hdd, hk, FD.array__trep_perfect(T.{R}, cap, T.{R}_default()))) :
        {{T.{p}_rd_fin(NN(len), _) == (BF(t, n), LOBJ(False{{}}, t, x, len)) : B.Buf & T.{p}_Seq}}
      {{==}}

def readw({CW}, {HC})
    -> {{T.{p}_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.{p}_Seq}}:
  rd_go({CA}, hchk, U32.is_eq(len, 0), {{==}})

# ---- the spec side ------------------------------------------------------------------------------

def RITEMS(c: Nat, +t: {TR}, +y: Nat) -> S.Value:
  match c:
    case 0n: S.EmptyItems{{}}
    case 1n+q: S.Items{{RVAL(t, y), RITEMS(q, t, Nat.add({RS}n, y))}}

def RIT1(+q: Nat, +t: {TR}, +y: Nat) -> {{S.Items{{RVAL(t, y), RITEMS(q, t, Nat.add({RS}n, y))}} == RITEMS(1n+q, t, y) : S.Value}}:
  {{==}}

def CHUNKS(c: Nat, +t: {TR}, +y: Nat) -> +List<+List<U32>>:
  match c:
    case 0n: []
    case 1n+q: Con{{UR.RWS({W}n, t, y), CHUNKS(q, t, Nat.add({RS}n, y))}}

law cnt_items:
  for +c: Nat
  for +t: {TR}
  for +y: Nat
  {{Codec.count(RITEMS(c, t, y)) == c : Nat}}
def cnt_items(c, t, y):
  match c:
    case 0n: {{==}}
    case 1n+ +q: FD.nat__succ_cong(Codec.count(RITEMS(q, t, Nat.add({RS}n, y))), q, cnt_items(q, t, Nat.add({RS}n, y)))

law prt_items:
  for +c: Nat
  for +t: {TR}
  for +y: Nat
  {{Codec.parts(RITEMS(c, t, y), S.Repeat{{{sch}}}) == Some{{F.fparts(CHUNKS(c, t, y))}} : Maybe<&2, +List<S.Part>>}}
def prt_items(c, t, y):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      %RIT1(q, t, y) : {{Codec.parts(_, S.Repeat{{{sch}}}) == Some{{F.fparts(CHUNKS(1n+q, t, y))}} : Maybe<&2, +List<S.Part>>}}
      F.items_rep(RVAL(t, y), RITEMS(q, t, Nat.add({RS}n, y)), {sch}, F.limbs(UR.RWS({W}n, t, y)),
        F.fparts(CHUNKS(q, t, Nat.add({RS}n, y))), RPRF(t, y), prt_items(q, t, Nat.add({RS}n, y)))

law flat_chunks:
  for +c: Nat
  for +d: Nat
  for +t: {TR}
  for +y: Nat
  for +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}
  for +h: {{Nat.is_le(Nat.add(y, Nat.mul(c, {RS}n)), A.quad(VB.pw(d))) == {TRUE}}}
  {{F.flat(CHUNKS(c, t, y)) == UW.WX(t, y, Nat.mul(c, {RS}n)) : +List<U32>}}
def flat_chunks(c, d, t, y, pf, h):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      +M = Nat.mul(q, {RS}n)
      +e = Equal.trans(Nat, Nat.add(Nat.add({RS}n, y), M), Nat.add({RS}n, Nat.add(y, M)), Nat.add(y, Nat.add({RS}n, M)),
        FD.nat__add_assoc({RS}n, y, M), FD.lru_nat_algebra__add_swap({RS}n, y, M))
      +h2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(d))) == {TRUE}}}, Nat.add(y, Nat.add({RS}n, M)), Nat.add(Nat.add({RS}n, y), M), Equal.sym(Nat, Nat.add(Nat.add({RS}n, y), M), Nat.add(y, Nat.add({RS}n, M)), e), h)
      %Equal.sym(+List<U32>, F.flat(CHUNKS(q, t, Nat.add({RS}n, y))), UW.WX(t, Nat.add({RS}n, y), M), flat_chunks(q, d, t, Nat.add({RS}n, y), pf, h2)) :
        {{List.append(&2, U32, F.limbs(UR.RWS({W}n, t, y)), _) == UW.WX(t, y, Nat.mul(1n+q, {RS}n)) : +List<U32>}}
      Equal.sym(+List<U32>, UW.WX(t, y, Nat.add(A.quad({W}n), M)), List.append(&2, U32, F.limbs(UR.RWS({W}n, t, y)), UW.WX(t, Nat.add(A.quad({W}n), y), M)), UW.headWX(d, t, y, {W}n, M, pf, h))

def VALw(+t: {TR}, +x: Nat, +len: U32) -> S.Value: S.Sequence{{RITEMS(CC(len), t, x)}}

def specw({CW}, {HC})
    -> {{Codec.parts(VALw(t, x, len), {LSCH}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : Maybe<&2, +List<S.Part>>}}:
  +c = CC(len)
  +ec = ecw(len, hchk)
  +RHS = Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}}
  +hf = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == {TRUE}}}, U32.to_nat(len), Nat.mul(c, {RS}n), ec, hw)
  +fl = flat_chunks(c, d, t, x, pf, hf)
  +fit = FD.logic__subst(+List<U32>, z => {{N.fits(4n, List.length(&2, U32, z)) == {TRUE}}}, UW.WX(t, x, Nat.mul(c, {RS}n)), F.flat(CHUNKS(c, t, x)), Equal.sym(+List<U32>, F.flat(CHUNKS(c, t, x)), UW.WX(t, x, Nat.mul(c, {RS}n)), fl),
    FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, Nat.mul(c, {RS}n), List.length(&2, U32, UW.WX(t, x, Nat.mul(c, {RS}n))), Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, Nat.mul(c, {RS}n))), Nat.mul(c, {RS}n), UW.lenWX(d, t, x, Nat.mul(c, {RS}n), pf, hf)),
      VFT.fits4(2n+d, Nat.mul(c, {RS}n), FD.nat__le_trans(Nat.mul(c, {RS}n), Nat.add(x, Nat.mul(c, {RS}n)), A.quad(VB.pw(d)), Order.left_below_sum(x, Nat.mul(c, {RS}n)), hf), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))))
  %Equal.sym(Nat, Codec.count(RITEMS(c, t, x)), c, cnt_items(c, t, x)) :
    {{Codec.require(Nat.is_le(_, U32.to_nat({LIM})), Codec.aggregate(Codec.parts(RITEMS(c, t, x), S.Repeat{{{sch}}}), None{{}})) == RHS : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(Bool, Nat.is_le(c, U32.to_nat({LIM})), True{{}}, hcw(len, hchk)) :
    {{Codec.require(_, Codec.aggregate(Codec.parts(RITEMS(c, t, x), S.Repeat{{{sch}}}), None{{}})) == RHS : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(RITEMS(c, t, x), S.Repeat{{{sch}}}), Some{{F.fparts(CHUNKS(c, t, x))}}, prt_items(c, t, x)) :
    {{Codec.require(True{{}}, Codec.aggregate(_, None{{}})) == RHS : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(F.fparts(CHUNKS(c, t, x))), Some{{F.flat(CHUNKS(c, t, x))}}, VS.encoding_fparts(CHUNKS(c, t, x), fit)) :
    {{Codec.one(_, None{{}}) == RHS : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(+List<U32>, F.flat(CHUNKS(c, t, x)), UW.WX(t, x, Nat.mul(c, {RS}n)), fl) :
    {{Codec.one(Some{{_}}, None{{}}) == RHS : Maybe<&2, +List<S.Part>>}}
  %ec : {{Codec.one(Some{{UW.WX(t, x, _)}}, None{{}}) == RHS : Maybe<&2, +List<S.Part>>}}
  {{==}}
''')
    w(inv_text(sch, RS, LIM, LSCH, CW, CA))
    out = '\n'.join(L) + '\n'
    return out.replace('\n  +RHS = Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]}\n', '\n').replace(' == RHS :', ' == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} :')



def inv_text(sch, RS, LIM, LSCH, CW, CA):
    """The inversion: every value whose parts are the window's bytes passes CHKw (whole records of RS bytes)."""
    TRUE = 'True{} : Bool'
    return f'''# ---- the inversion ------------------------------------------------------------------------------

def rp_t(+xs: +List<U32>, +el: S.Value, +tl: S.Value, +ps: +List<S.Part>, +mB: Maybe<&2, +List<S.Part>>,
    +eB: {{Codec.parts(tl, S.Repeat{{{sch}}}) == mB : Maybe<&2, +List<S.Part>>}},
    +lx: {{List.length(&2, U32, xs) == {RS}n : Nat}},
    +e: {{Codec.concatenate(Some{{[S.Fixed{{xs}}]}}, mB) == Some{{ps}} : Maybe<&2, +List<S.Part>>}},
    ih: @+pb: +List<S.Part> -> {{Codec.parts(tl, S.Repeat{{{sch}}}) == Some{{pb}} : Maybe<&2, +List<S.Part>>}} -> VMR.REPB(tl, pb, {RS}n))
    -> VMR.REPB(S.Items{{el, tl}}, ps, {RS}n):
  match mB:
    case None{{}}: Empty.absurd(VMR.REPB(S.Items{{el, tl}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case Some{{+pb}}:
      +eps = FD.logic__some_inj(+List<S.Part>, S.Fixed{{xs}} <> pb, ps, e)
      %Equal.sym(+List<S.Part>, ps, S.Fixed{{xs}} <> pb, Equal.sym(+List<S.Part>, S.Fixed{{xs}} <> pb, ps, eps)) : VMR.REPB(S.Items{{el, tl}}, _, {RS}n)
      VMR.rpb_t2(xs, el, tl, pb, {RS}n, lx, ih(pb, eB))

def rp_p(+el: S.Value, +tl: S.Value, +ps: +List<S.Part>, +ph: +List<S.Part>, hf: DF.single(Some{{{RS}n}}, ph),
    +e: {{Codec.concatenate(Some{{ph}}, Codec.parts(tl, S.Repeat{{{sch}}})) == Some{{ps}} : Maybe<&2, +List<S.Part>>}},
    ih: @+pb: +List<S.Part> -> {{Codec.parts(tl, S.Repeat{{{sch}}}) == Some{{pb}} : Maybe<&2, +List<S.Part>>}} -> VMR.REPB(tl, pb, {RS}n))
    -> VMR.REPB(S.Items{{el, tl}}, ps, {RS}n):
  match ph:
    case Nil{{}}: Empty.absurd(VMR.REPB(S.Items{{el, tl}}, ps, {RS}n), hf)
    case Con{{S.Fixed{{+xs}}, Nil{{}}}}:
      rp_t(xs, el, tl, ps, Codec.parts(tl, S.Repeat{{{sch}}}), {{==}}, Equal.sym(Nat, {RS}n, List.length(&2, U32, xs), FD.logic__some_inj(Nat, {RS}n, List.length(&2, U32, xs), hf)), e, ih)
    case Con{{S.Variable{{+xs}}, Nil{{}}}}: Empty.absurd(VMR.REPB(S.Items{{el, tl}}, ps, {RS}n), FD.logic__none_some(Nat, {RS}n, Equal.sym(Maybe<&2, Nat>, Some{{{RS}n}}, None{{}}, hf)))
    case Con{{S.Fixed{{+xs}}, Con{{+a, +b}}}}: Empty.absurd(VMR.REPB(S.Items{{el, tl}}, ps, {RS}n), hf)
    case Con{{S.Variable{{+xs}}, Con{{+a, +b}}}}: Empty.absurd(VMR.REPB(S.Items{{el, tl}}, ps, {RS}n), hf)

def rp_m(+el: S.Value, +tl: S.Value, +ps: +List<S.Part>, +mh: Maybe<&2, +List<S.Part>>, hf: DF.single_result(Some{{{RS}n}}, mh),
    +e: {{Codec.concatenate(mh, Codec.parts(tl, S.Repeat{{{sch}}})) == Some{{ps}} : Maybe<&2, +List<S.Part>>}},
    ih: @+pb: +List<S.Part> -> {{Codec.parts(tl, S.Repeat{{{sch}}}) == Some{{pb}} : Maybe<&2, +List<S.Part>>}} -> VMR.REPB(tl, pb, {RS}n))
    -> VMR.REPB(S.Items{{el, tl}}, ps, {RS}n):
  match mh:
    case None{{}}: Empty.absurd(VMR.REPB(S.Items{{el, tl}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case Some{{+ph}}: rp_p(el, tl, ps, ph, hf, e, ih)

# The parts of records are fixed parts of {RS} bytes each.
law rep_r:
  for +its: S.Value
  for +ps: +List<S.Part>
  for +e: {{Codec.parts(its, S.Repeat{{{sch}}}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}}
  VMR.REPB(its, ps, {RS}n)
def rep_r(its, ps, e):
  match its:
    case S.EmptyItems{{}}:
      +eps = FD.logic__some_inj(+List<S.Part>, [], ps, e)
      %Equal.sym(+List<S.Part>, ps, [], Equal.sym(+List<S.Part>, [], ps, eps)) : VMR.REPB(S.EmptyItems{{}}, _, {RS}n)
      ({{==}}, {{==}})
    case S.Items{{+h, +tl}}: rp_m(h, tl, ps, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), e, pb => eb => rep_r(tl, pb, eb))
    case S.BooleanValue{{+b}}: Empty.absurd(VMR.REPB(S.BooleanValue{{b}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case S.UnsignedValue{{+u}}: Empty.absurd(VMR.REPB(S.UnsignedValue{{u}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case S.BytesValue{{+xs}}: Empty.absurd(VMR.REPB(S.BytesValue{{xs}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case S.BitsValue{{+bs}}: Empty.absurd(VMR.REPB(S.BitsValue{{bs}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case S.Sequence{{+it}}: Empty.absurd(VMR.REPB(S.Sequence{{it}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case S.Selected{{+sel, +sv}}: Empty.absurd(VMR.REPB(S.Selected{{sel, sv}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))
    case S.NullValue{{}}: Empty.absurd(VMR.REPB(S.NullValue{{}}, ps, {RS}n), FD.logic__none_some(+List<S.Part>, ps, e))

def lm4(+its: S.Value, +ys: +List<U32>, +hk: {{Nat.is_le(Codec.count(its), U32.to_nat({LIM})) == {TRUE}}}, +ps: +List<S.Part>,
    +em3: {{Codec.parts(its, S.Repeat{{{sch}}}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}}, +m4: Maybe<&2, +List<U32>>,
    +em4: {{Layout.encoding(ps) == m4 : Maybe<&2, +List<U32>>}}, +e: {{Codec.bytes(Codec.one(m4, None{{}})) == Some{{ys}} : Maybe<&2, +List<U32>>}})
    -> VMR.LF(ys, {RS}n, U32.to_nat({LIM})):
  match m4:
    case None{{}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case Some{{+zs}}:
      +ez = FD.logic__some_inj(+List<U32>, zs, ys, e)
      +lz = Equal.trans(Nat, List.length(&2, U32, zs), Layout.fixed_size(ps), Nat.mul(Codec.count(its), {RS}n),
        VS.enc_len(ps, zs, Pair.fst({{VS.allfix(ps) == {TRUE}}}, {{Layout.fixed_size(ps) == Nat.mul(Codec.count(its), {RS}n) : Nat}}, rep_r(its, ps, em3)), em4),
        Pair.snd({{VS.allfix(ps) == {TRUE}}}, {{Layout.fixed_size(ps) == Nat.mul(Codec.count(its), {RS}n) : Nat}}, rep_r(its, ps, em3)))
      (Codec.count(its), (FD.logic__subst(+List<U32>, z => {{List.length(&2, U32, z) == Nat.mul(Codec.count(its), {RS}n) : Nat}}, zs, ys, ez, lz), hk))

def lm3(+its: S.Value, +ys: +List<U32>, +hk: {{Nat.is_le(Codec.count(its), U32.to_nat({LIM})) == {TRUE}}}, +m3: Maybe<&2, +List<S.Part>>,
    +em3: {{Codec.parts(its, S.Repeat{{{sch}}}) == m3 : Maybe<&2, +List<S.Part>>}}, +e: {{Codec.bytes(Codec.aggregate(m3, None{{}})) == Some{{ys}} : Maybe<&2, +List<U32>>}})
    -> VMR.LF(ys, {RS}n, U32.to_nat({LIM})):
  match m3:
    case None{{}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case Some{{+ps}}: lm4(its, ys, hk, ps, em3, Layout.encoding(ps), {{==}}, e)

def lb(+its: S.Value, +ys: +List<U32>, +b: Bool, +eb: {{Nat.is_le(Codec.count(its), U32.to_nat({LIM})) == b : Bool}},
    +e: {{Codec.bytes(Codec.require(b, Codec.aggregate(Codec.parts(its, S.Repeat{{{sch}}}), None{{}}))) == Some{{ys}} : Maybe<&2, +List<U32>>}})
    -> VMR.LF(ys, {RS}n, U32.to_nat({LIM})):
  match b:
    case False{{}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case True{{}}: lm3(its, ys, eb, Codec.parts(its, S.Repeat{{{sch}}}), {{==}}, e)

# The spec bytes ys of any value of the list are whole records, at most {LIM}.
law linvr:
  for +h: S.Value
  for +ys: +List<U32>
  for +e: {{Codec.bytes(Codec.parts(h, {LSCH})) == Some{{ys}} : Maybe<&2, +List<U32>>}}
  VMR.LF(ys, {RS}n, U32.to_nat({LIM}))
def linvr(h, ys, e):
  match h:
    case S.Sequence{{+its}}: lb(its, ys, Nat.is_le(Codec.count(its), U32.to_nat({LIM})), {{==}}, e)
    case S.BooleanValue{{+b0}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.UnsignedValue{{+u0}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.BytesValue{{+xs0}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.BitsValue{{+bs0}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.Items{{+hd0, +tl0}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.EmptyItems{{}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.Selected{{+sel0, +sv0}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))
    case S.NullValue{{}}: Empty.absurd(VMR.LF(ys, {RS}n, U32.to_nat({LIM})), FD.logic__none_some(+List<U32>, ys, e))

def chk_i({CW}, f: VMR.LF(UW.WX(t, x, U32.to_nat(len)), {RS}n, U32.to_nat({LIM}))) -> {{CHKw(t, x, off, len) == {TRUE}}}:
  (+k, +pr) = f
  (+hl, +hk) = pr
  VU.whole_i(len, {RS}, {LIM}, vR(), {{==}}, {{==}}, {{==}}, k,
    Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), Nat.mul(k, {RS}n),
      Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)), hl), hk)

# Every value whose parts are the window's bytes passes the check.
def invw({CW}, +v: S.Value,
    +e: {{Codec.parts(v, {LSCH}) == Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}} : Maybe<&2, +List<S.Part>>}})
    -> {{CHKw(t, x, off, len) == {TRUE}}}:
  chk_i({CA}, linvr(v, UW.WX(t, x, U32.to_nat(len)),
    Equal.cong(Maybe<&2, +List<S.Part>>, Maybe<&2, +List<U32>>, z => Codec.bytes(z), Codec.parts(v, {LSCH}), Some{{[S.Variable{{UW.WX(t, x, U32.to_nat(len))}}]}}, e)))
'''


def outputs():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    out = {ROOT / 'proofs/obj/vrl.bend': (ROOT / 'codegen/vrl.bend.in').read_text(),
           ROOT / 'proofs/obj/vrc.bend': (ROOT / 'codegen/vrc.bend.in').read_text()}
    for parent, field in LISTS:
        I = info(g, names, parent, field)
        VLW.SL.HOIST = True   # nested fixed records' proofs as lemmas over their words (spec_laws.HOIST)
        VLW.SL.hoist_take()
        txt = list_text(g, names, parent, field)
        VLW.SL.HOIST = False
        txt = txt.replace('\ndef RX(', '\n' + VLW.SL.hoist_take() + 'def RX(', 1)
        if I['LIM'] > BIG_LIM:
            txt = sym_depth(txt, I['RS'], I['KL'])
        txt = deep_rlist(txt, I['RS'], I['LIM'] > BIG_LIM)
        out[ROOT / f'proofs/obj/{winx_name(I["p"], I["LIM"])}'] = txt
    import var_rlist_box as BX
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
    import var_rlist_bv as BV
    import var_win as VWN
    for parent, field in BVLISTS:
        ft = dict(names[parent].fields)[field]
        B, N, p = ft.elem.fixed_size(), ft.size, g.shape(ft).p
        out[ROOT / f'proofs/obj/{winx_name(p, N)}'] = BV.bvx_text(HEAD, VWN.zeros_at_text, inv_text, p, B, N, f'S.ByteVector{{{B}n}}',
                                                                  f'S.ListOf{{S.ByteVector{{{B}n}}, U32.to_nat({N})}}', N > BIG_LIM, deep=True)
    import var_rlist_er as ER
    LS = []
    for field in ('deposits', 'withdrawals', 'consolidations'):
        I = info(g, names, 'ExecutionRequests', field)
        sch = rec_node(g, I['rt'])[2]
        LS.append(dict(p=I['p'], RS=I['RS'], LIM=I['LIM'], LSCH=f'S.ListOf{{{sch}, U32.to_nat({I["LIM"]})}}'))
    L, _ = ER.er_text(HEAD, LS)
    out[ROOT / 'proofs/obj/var_winx_ExecutionRequests.bend'] = deep_er('\n'.join(L) + '\n')
    out[ROOT / 'proofs/obj/var_codec_ExecutionRequests.bend'] = deep_er_top(ER.top_text(HEAD))
    import var_rlist_enc as EN
    fts, recs = [], []
    for field in ('deposits', 'withdrawals', 'consolidations'):
        rt = dict(names['ExecutionRequests'].fields)[field].elem
        for dep in VLW.FT(g, rt).deps():
            if dep.p not in [f_.p for f_ in fts]:
                fts.append(dep)
    import deep
    out[ROOT / 'proofs/obj/var_fix_put_er.bend'] = deep.dify_fix(EN.fixput_text(VLW, fts))
    LT = list(HEAD) + ['import ./vfix.bend as VF', 'import ./venc2.bend as V2', 'import ./var_fix_put_er.bend as VT2', '',
                       '# GENERATED by codegen/var_rlist.py (codegen/var_rlist_enc.py). Do not edit.',
                       '# ExecutionRequests\' records and lists, writer side: see codegen/var_rlist_enc.py.', '']
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
    VLW.SL.EXACT = True   # the exact spec-parts proofs (codegen/spec_laws.py), before any walk
    out = outputs()
    if False:
        out = {p: t for p, t in out.items() if not p.name.startswith('')}
    import runtime_refs as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    import deep  # the dd < 31 twins (name+W; the old names wrap them at dd < 29)
    out = deep.dify_out(out, handled={'posWW'})
    # VRL.posWW takes hW: 1 <= W (the record's word count, a literal) before hb
    out = {p: re.sub(r'(VRL\.posWW\(dd, pos, Q, i, j, \d+, \d+n, \{==\}, ep, ei, hdd), ', r'\1, {==}, ', t) for p, t in out.items()}
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('record-list windows are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
