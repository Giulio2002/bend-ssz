#!/usr/bin/env python3
"""Encoder windows of FIXED-SIZE CONTAINERS at any byte position X = 4 q + r.

    python3 codegen/proofs/var/var_rec_enc.py [--check]

proofs/obj/encx_recs.bend (generated): for each fixed container R of RECS (and the fixed
containers nested in them, first), with its words w0 .. w{W-1}:

  PX_R(ws, dd, D, q, r)   the output tree after the runtime's T.R_put at X: the leaf writers'
                          models (vuwd: W64X for uint64, <P>X for the word-vector leaves) and
                          the nested containers' PX, field by field in the runtime's order;
  pf_R                    it is perfect;
  putx_R                  DK.P2( T.R_put(thaw D, X, obj(ws)) == thaw PX_R(..),
                                 BYT(PX_R(..)) == SPL(BYT D, 4 q + r, limbs(ws)) )
                          when the value's 4 W bytes at X are zero and its words fit the tree.

The bytes follow the region invariant of proofs/obj/vuw.bend (inv_init, inv_zero, inv_step):
the region is the value's 4 W bytes, starting as zeros, each field's write splices its limbs at
its offset; the regions' shapes are closed, so each zero window and the final bytes close by
evaluation. The leaves write their data bytes only (vuwd's data-only form), so a record's bytes
are exactly its words' limbs. Positions and room: proofs/obj/vrecx.bend.

proofs/obj/encx_<p>.bend (generated, big) for the lists of SUBLISTS, whose records have uint8 /
uint16 fields: the list in var_plist_sub's encoder-window interface, its records written byte by
byte at any byte position (hand-written helpers: proofs/obj/vrecb.bend; see sub_text).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.proofs.var.var_finish import finish  # noqa: E402

from codegen.core.paths import ROOT  # noqa: E402

def _unlit(text):
    """a module's text as before any light split (codegen/proofs/support/light_split.py: unlight), for parsing"""
    from codegen.proofs.support import light_split
    t = light_split.unlight(text)
    return t.rstrip('\n') + '\n\n'


from codegen.proofs.var import var_laws as VL  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports
from codegen.core.shared_var_b import Templates  # noqa: E402
TPL = Templates('var_rec_enc', globals())

OUT = ROOT / 'proofs/obj/encx_recs.bend'
RECS = ['Withdrawal', 'SyncAggregate', 'BeaconBlockHeader', 'Fork', 'Checkpoint', 'Eth1Data', 'HistoricalSummary', 'PendingDeposit',
        'PendingPartialWithdrawal', 'PendingConsolidation',
        # BeaconBlockBody's and ExecutionRequests' records
        'AttestationData', 'DepositRequest', 'WithdrawalRequest', 'ConsolidationRequest', 'SignedVoluntaryExit', 'SignedBLSToExecutionChange',
        'SignedBeaconBlockHeader', 'DepositData']
# the word-vector leaves written by their own modules (codegen/proofs/var/var_uwv.py's vuwv_<p>)
VLEAVES = ('b32', 'u256', 'b48', 'b96', 'bv512', 'bv64', 'b4')
TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'

HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS',
        'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW', 'import ./vuwd.bend as WD', 'import ./vrecx.bend as VRX',
        'import ./dk.bend as DK']


def leaf(k):
    """(model, runtime lemma, bytes lemma, perfect lemma, runtime lemma takes hz) of a leaf field type."""
    if k.kind == 'u64':
        return 'WD.W64X', 'WD.w64_any', 'WD.w64_any_bytes', 'WD.w64x_perfect', False
    P = k.p
    if P in VLEAVES:
        return f'V_{P}.PX_{P}', f'V_{P}.{P}_any', f'V_{P}.{P}_any_bytes', f'V_{P}.{P}x_perfect', True
    return f'WD.{P.upper()}X', f'WD.{P}_any', f'WD.{P}_any_bytes', f'WD.{P}x_perfect', True


def layout():
    from codegen.core import schema
    from codegen.impl import generate as G
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    return g, names


def order(g, names, recs):
    """The records and their nested fixed containers, children first."""
    out = []

    def visit(n, ft):
        for c, k in ft.kids:
            if k.kind == 'container':
                visit(k.s.rep, k)
        if n not in [o[0] for o in out]:
            out.append((n, ft))
    for n in recs:
        visit(n, VL.FT(g, names[n]))
    return out


def rec_text(n, ft):
    W = ft.W
    ws = [f'w{i}' for i in range(W)]
    WSIG = ', '.join(f'+{w}: U32' for w in ws)
    WA = ', '.join(ws)
    Ln = f'{4 * W}n'
    X0 = 'Nat.add(A.quad(q), r)'
    OBJ = ft.obj(ws)
    fields = []
    for c, k in ft.kids:
        kw = ws[c // 4:c // 4 + k.W]
        fields.append((c, k, kw))

    def model(i, inner):
        c, k, kw = fields[i]
        pos = f'Nat.add({c // 4}n, q)'
        if k.kind == 'container':
            return f'PX_{k.s.rep}({", ".join(kw)}, dd, {inner}, {pos}, r)'
        M = leaf(k)[0]
        return f'{M}(r, dd, {inner}, {pos}, {", ".join(kw)})'

    def tree(i):
        t = 'D'
        for j in range(i):
            t = model(j, t)
        return t
    L = []
    w = L.append
    w(f'# ---- {n}: {len(fields)} fields, {4 * W} bytes ----')
    w(f'def PX_{n}({WSIG}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}: {tree(len(fields))}')
    pfs = 'pf'
    for i, (c, k, kw) in enumerate(fields):
        pos = f'Nat.add({c // 4}n, q)'
        if k.kind == 'container':
            pfs = f'pf_{k.s.rep}({", ".join(kw)}, dd, {tree(i)}, {pos}, r, {pfs})'
        else:
            pfs = f'{leaf(k)[3]}(r, dd, {tree(i)}, {pos}, {", ".join(kw)}, {pfs})'
    for line in TPL.render('rec_text_lines', WA=WA, WSIG=WSIG, n=n, pfs=pfs).split('\n'):
        w(line)
    RT = f'{{T.{n}_put(FD.array__thaw(U32, D), X, {OBJ}) == FD.array__thaw(U32, PX_{n}({WA}, dd, D, q, r)) : Array<U32>}}'
    BY = f'{{UA.BYT(PX_{n}({WA}, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, FX.limbs([{WA}])) : +List<U32>}}'
    w(TPL.render('rec_text', BY=BY, Ln=Ln, RT=RT, W=W, WA=WA, WSIG=WSIG, X0=X0, n=n))
    E = f'UW.ZB({Ln})'
    pf_cur = 'pf'
    rts = []
    for i, (c, k, kw) in enumerate(fields):
        m = 4 * k.W
        pos = f'Nat.add({c // 4}n, q)'
        Di = tree(i)
        Dn = tree(i + 1)
        Xi = f'U32.add(X, {c})'
        for line in TPL.render('rec_text_lines_2', Di=Di, E=E, Ln=Ln, X0=X0, c=c, i=i, m=m, pos=pos).split('\n'):
            w(line)
        if k.kind == 'container':
            w(f'  +g{i} = putx_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r, ep{i}, hr, hd, hl{i}, {pf_cur}, hz{i})')
            rt = f'DK.P2(RT_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r), BY_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r))'
            w(f'  +rt{i} = PA(RT_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r), BY_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r), g{i})')
            w(f'  +by{i} = PB(RT_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r), BY_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r), g{i})')
            pf_next = f'pf_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r, {pf_cur})'
        else:
            M, RTL, BYL, PFL, needz = leaf(k)
            if needz:
                w(f'  +rt{i} = {RTL}(dd, {Di}, {Xi}, {pos}, r, {", ".join(kw)}, ep{i}, hr, hd, hl{i}, {pf_cur}, hz{i})')
            else:
                w(f'  +rt{i} = {RTL}(dd, {Di}, {Xi}, {pos}, r, {", ".join(kw)}, ep{i}, hr, hd, hl{i}, {pf_cur})')
            w(f'  +by{i} = {BYL}(dd, {Di}, {Xi}, {pos}, r, {", ".join(kw)}, ep{i}, hr, hd, hl{i}, {pf_cur}, hz{i})')
            pf_next = f'{PFL}(r, dd, {Di}, {pos}, {", ".join(kw)}, {pf_cur})'
        Y = f'FX.limbs([{", ".join(kw)}])'
        w(f'  +hop{i} = FD.logic__subst(Nat, zz => {{UA.BYT({Dn}) == UW.SPL(UA.BYT({Di}), zz, {Y}) : +List<U32>}}, Nat.add(A.quad({pos}), r), Nat.add({X0}, {c}n), Equal.sym(Nat, Nat.add({X0}, {c}n), Nat.add(A.quad({pos}), r), VRX.fpx(q, r, {c // 4}n)), by{i})')
        rr = 4 * W - c - m
        w(f'  +I{i + 1} = UW.inv_step(UA.BYT(D), {X0}, {Ln}, {E}, {c}n, {Y}, {rr}n, UA.BYT({Di}), UA.BYT({Dn}), hX, I{i}, hop{i}, {{==}}, {{==}})')
        E = f'UW.SPL({E}, {c}n, {Y})'
        rts.append((i, c, k, kw, Di, Dn))
        pf_cur = pf_next
    # the runtime chain
    def put_expr(i, inner):
        c, k, kw = fields[i]
        Xi = f'U32.add(X, {c})'
        return f'T.{k.p}_put({inner}, {Xi}, {k.obj(kw)})'

    def outer(i, hole):
        t = hole
        for j in range(i + 1, len(fields)):
            t = put_expr(j, t)
        return t
    w(f'  +byf = FD.logic__subst(+List<U32>, zz => {{UA.BYT(PX_{n}({WA}, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VS.bt({Ln}, {E}), FX.limbs([{WA}]), {{==}}, I{len(fields)})')
    w(f'  (rt_{n}({WA}, dd, D, X, q, r, {", ".join(f"rt{i}" for i in range(len(fields)))}), byf)')
    w('')
    # the runtime lemma (by rewriting the nested puts, innermost first); it precedes putx
    mark = len(L)
    RTP = []
    for i, c, k, kw, Di, Dn in rts:
        lhs = put_expr(i, f'FD.array__thaw(U32, {Di})')
        RTP.append(f'+rt{i}: {{{lhs} == FD.array__thaw(U32, {Dn}) : Array<U32>}}')
    w(f'def rt_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,\n    ' + ',\n    '.join(RTP) + f')\n    -> {RT}:')
    for i, c, k, kw, Di, Dn in rts:
        lhs = put_expr(i, f'FD.array__thaw(U32, {Di})')
        w(f'  %Equal.sym(Array<U32>, {lhs}, FD.array__thaw(U32, {Dn}), rt{i}) :')
        w(f'    {{{outer(i, "_")} == FD.array__thaw(U32, PX_{n}({WA}, dd, D, q, r)) : Array<U32>}}')
    w('  {==}')
    w('')
    text = '\n'.join(L[:mark])
    cut = text.index(f'\n# T.{n}_put at X')
    return text[:cut] + '\n\n' + '\n'.join(L[mark:]) + text[cut:] + '\n'


def module_text():
    g, names = layout()
    used = []
    for n, ft in order(g, names, RECS):
        for c, k in ft.kids:
            if k.kind != 'container' and k.kind != 'u64' and k.p in VLEAVES and k.p not in used:
                used.append(k.p)
    L = HEAD + [f'import ./vuwv_{P}.bend as V_{P}' for P in used] + ['', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                '# Encoder windows of fixed-size containers at any byte position (see the generator).', '',
                'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b', '']
    for n, ft in order(g, names, RECS):
        L.append(rec_text(n, ft))
    return '\n'.join(L) + '\n'


# ---- lists of fixed records ----------------------------------------------------------------------

LISTS = [('ExecutionPayload', 'withdrawals'), ('BeaconState', 'eth1_data_votes'), ('BeaconState', 'historical_summaries'),
         ('BeaconState', 'pending_deposits'), ('BeaconState', 'pending_partial_withdrawals'), ('BeaconState', 'pending_consolidations'),
         ('ExecutionRequests', 'deposits'), ('ExecutionRequests', 'withdrawals'), ('ExecutionRequests', 'consolidations'),
         ('BeaconBlockBody', 'voluntary_exits'), ('BeaconBlockBody', 'bls_to_execution_changes')]


def lfile(p):
    return ROOT / f'proofs/obj/encx_{p}.bend'


def obj_text(VLW, EN, g, rt, walk):
    """The record's words, value, parts (var_rlist_enc.rec_text, without its aligned writer) and its
    object-level window over encx_recs: PXo, pfo, putxo, lenb."""
    txt, ft = EN.rec_text(VLW, g, rt, walk)
    txt = txt[:txt.index('\ndef putR_')] + '\n'
    R, W = rt.name, ft.W
    words = []
    ls, ind = EN.nest(ft, 'o', words, 2)
    body = '\n'.join(ls)
    pad = ' ' * ind
    WA = ', '.join(words)
    RS = 4 * W
    X0 = 'Nat.add(A.quad(q), r)'
    return txt + TPL.render('obj_text', R=R, RS=RS, WA=WA, X0=X0, body=body, pad=pad)


def loop_text(p, R, RS, W, LIM):
    TRR = f'FD.array__Tree<T.{R}>'
    Wn = f'{W}n'
    QJ = f'Nat.add(Nat.mul(j, {Wn}), q)'
    RTP = f'Array<U32> & Array<T.{R}>'
    X0 = 'Nat.add(A.quad(q), r)'
    TH = f'FD.array__thaw(T.{R}, A)'
    return TPL.render('loop_text', LIM=LIM, QJ=QJ, R=R, RS=RS, RTP=RTP, TH=TH, TRR=TRR, Wn=Wn, X0=X0, p=p)


def spec_x_text(p, R, W, LIM, sch):
    Wn = f'{W}n'
    TRR = f'FD.array__Tree<T.{R}>'
    LSCH = f'S.ListOf{{{sch}, U32.to_nat({LIM})}}'
    RWA = f'RWA_{p}(U32.to_nat(N), A, 0n)'
    return TPL.render('spec_x_text', LIM=LIM, LSCH=LSCH, RWA=RWA, TRR=TRR, Wn=Wn, p=p)


# ---- byte lists (O.Words with a bound) -----------------------------------------------------------
# The encoder window of a ByteList[LIM] field, on var_plist_sub's O.Words template (putw_any) with the
# list's validity check O.words_ok(o, 0, LIM, False, 1), over its decoder window (var_vlist's vvlb_<p>).
BLISTS = [('bl32', 'Schema70', 32)]


def bl_file(p):
    return ROOT / f'proofs/obj/encx_{p}.bend'


def bl_text(p, X, LIM):
    from codegen.proofs.var import var_plist_sub as VPS
    from codegen.proofs.var import var_win as VW
    valid = TPL.render('valid', LIM=LIM, p=p)
    body = VPS.ENCX.replace('@PRE', '').replace('@VALID', valid).replace('@EXTRA', f'U32.is_le(N, {LIM})').replace('@OKDOC', f', at most {LIM} bytes')
    body = body.replace('@CHK', 'ok_ex(dw, T, N, hok)').replace('@X(', f'{X}(').replace('@p_', f'{p}_')
    # the bytes' bound (a container's maxx)
    body += TPL.render('bl_text', LIM=LIM)
    L = VW.HEADX + ['import ./venc.bend as VE', 'import ./vbenc.bend as VBE', 'import ./vbytes.bend as VYS', 'import ./vua.bend as UA',
                    'import ./vuw.bend as UWW', 'import ./vuwd.bend as VWD', 'import ../compact/reads.bend as RD',
                    f'import ./vvlb_{p}.bend as W', '', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                    f'# ByteList[{LIM}] (T.{p}_*) in the encoder-window interface: the list written at any byte position',
                    '# X = 4 q + r of a perfect tree D of depth dd < 29 (vuwd.putw_any / putw_any_bytes; var_plist_sub.ENCX).', '']
    return '\n'.join(L) + body



# ---- BeaconState's packed lists in encx form (var_plist_sub.ENCX over codec-var's windows var_winx_<p>) ----

def _wvalid(p, unit, hu):
    return TPL.render('_wvalid', hu=hu, p=p, unit=unit)


def _flist_kinds():
    u64x = 'Bool.and(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N))'
    b32c1 = 'Nat.is_le(U32.to_nat(N), U32.to_nat(536870912))'
    b32c2 = 'U32.is_eq(U32.and(N, 31), 0)'
    b32x = f'Bool.and({b32c1}, Bool.and({b32c2}, W.CHKw(T, 0n, 0, N)))'
    p64, p8, p32 = 'l1099511627776_u64', 'l1099511627776_u8', 'l16777216_b32'
    return {
        p64: dict(X='Spec.Schema79()', EXTRA=u64x, OKDOC=', a multiple of 8',
                  CHK='FD.logic__and_right(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N), ok_ex(dw, T, N, hok))',
                  VALID=_wvalid(p64, 8, 'FD.logic__and_left(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N), ok_ex(dw, T, N, h))')),
        p8: dict(X='Spec.Schema82()', EXTRA='W.CHKw(T, 0n, 0, N)', OKDOC='', CHK='ok_ex(dw, T, N, hok)', VALID=_wvalid(p8, 1, '{==}')),
        p32: dict(X='S.ListOf{S.ByteVector{32n}, U32.to_nat(16777216)}', EXTRA=b32x, OKDOC=', at most 536870912 bytes, a multiple of 32',
                  CHK=f'FD.logic__and_right({b32c2}, W.CHKw(T, 0n, 0, N), FD.logic__and_right({b32c1}, Bool.and({b32c2}, W.CHKw(T, 0n, 0, N)), ok_ex(dw, T, N, hok)))',
                  VALID=TPL.render('_flist_kinds', b32c1=b32c1, b32c2=b32c2, p32=p32)),
        # BeaconBlockBody's blob_kzg_commitments: at most 4096 commitments of 48 bytes (codec-var's var_winx_l4096_b48)
        'l4096_b48': dict(X='S.ListOf{S.ByteVector{48n}, U32.to_nat(4096)}', WIN='var_winx_l4096_b48',
                          EXTRA=f'Bool.and(U32.is_le(N, 196608), Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)))',
                          OKDOC=', at most 196608 bytes, a multiple of 48',
                          CHK='FD.logic__and_right(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N), FD.logic__and_right(U32.is_le(N, 196608), '
                              'Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)), ok_ex(dw, T, N, hok)))',
                          VALID=TPL.text('_flist_kinds_valid')),
        # IndexedAttestation's attesting_indices: at most 131072 uint64 (codec-var's var_winx_l131072_u64)
        'l131072_u64': dict(X='Spec.Schema45()',
                            EXTRA=f'Bool.and(U32.is_le(N, 1048576), Bool.and(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N)))',
                            OKDOC=', at most 1048576 bytes, a multiple of 8',
                            CHK='FD.logic__and_right(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N), FD.logic__and_right(U32.is_le(N, 1048576), '
                                'Bool.and(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N)), ok_ex(dw, T, N, hok)))',
                            VALID=TPL.text('_flist_kinds_2')),
    }


FLISTS = ['l1099511627776_u64', 'l1099511627776_u8', 'l16777216_b32', 'l4096_b48', 'l131072_u64']


def flist_text(p):
    from codegen.proofs.var import var_plist_sub as VPS
    from codegen.proofs.var import var_win as VW
    kd = _flist_kinds()[p]
    body = VPS.ENCX.replace('@PRE', '').replace('@VALID', kd['VALID']).replace('@EXTRA', kd['EXTRA']).replace('@OKDOC', kd['OKDOC']).replace('@CHK', kd['CHK'])
    body = body.replace('Spec.@X()', kd['X']).replace('@p_', f'{p}_')
    assert '@' not in body.replace('&2', ''), [ln for ln in body.split('\n') if '@' in ln.replace('&2', '')][:3]
    L = VW.HEADX + ['import ./venc.bend as VE', 'import ./vbenc.bend as VBE', 'import ./vbytes.bend as VYS', 'import ./vua.bend as UA',
                    'import ./vuw.bend as UWW', 'import ./vuwd.bend as VWD', 'import ../compact/reads.bend as RD',
                    f'import ./{kd.get("WIN", "var_winx_" + p)}.bend as W', '', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                    f'# {p} (T.{p}_*) in the encoder-window interface: the list written at any byte position',
                    '# X = 4 q + r of a perfect tree D of depth dd < 29 (vuwd.putw_any / putw_any_bytes; var_plist_sub.ENCX).', '']
    return '\n'.join(L) + body


# ---- fixed records with fields at any byte offset (Validator: 121 bytes, a one-byte bool) --------------
# Each field is written by the runtime at Xc = X + c, placed at the word position 4 QX(Xc) + RX(Xc)
# (vpiece.ppos / proom, vcont.vpos / croom, vcopy.split4), its bytes spliced at X0 + c of the record's
# region (vuw.inv_init / inv_zero / inv_step).

URECS = ['Validator']


def urec_file(n):
    return ROOT / f'proofs/obj/encx_{n}.bend'


def _uleaf(fs, f, k):
    """(words, object term, model(r, dd, D, q), rt(D, X, q, r, e, hr, hd, hl, pf), by(.., hz), perfect(r, dd, D, q, pf), bytes, runtime prefix, m)."""
    if fs.kind == 'u64':
        ws = [f'{f}_lo', f'{f}_hi']
        W = ', '.join(ws)
        return dict(ws=ws, obj=f'O.U64{{{W}}}', model=lambda r, dd, D, q: f'WD.W64X({r}, {dd}, {D}, {q}, {W})',
                    rt=lambda D, X, q, r: f'WD.w64_any(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf)',
                    by=lambda D, X, q, r: f'WD.w64_any_bytes(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf, @hz)',
                    pf=lambda r, D, q, p: f'WD.w64x_perfect({r}, dd, {D}, {q}, {W}, {p})', Y=f'FX.limbs([{W}])', put='u64', m=8)
    if fs.kind == 'bool':
        return dict(ws=[f], obj=f, model=lambda r, dd, D, q: f'PBo({f}, {r}, {dd}, {D}, {q})',
                    rt=lambda D, X, q, r: f'bool_any(dd, {D}, {X}, {q}, {r}, {f}, @e, @hr, hd, @hl, @pf)',
                    by=lambda D, X, q, r: f'bool_any_bytes(dd, {D}, {X}, {q}, {r}, {f}, @e, @hr, hd, @hl, @pf, @hz)',
                    pf=lambda r, D, q, p: f'boolx_perfect({f}, {r}, dd, {D}, {q}, {p})', Y=f'[BB({f})]', put='bool', m=1)
    p = fs.p
    N = fs.fsize // 4
    ws = [f'{f}_{j}' for j in range(N)]
    W = ', '.join(ws)
    a = f'V_{p}'
    return dict(ws=ws, obj=f'T.{fs.rep}{{{W}}}', model=lambda r, dd, D, q: f'{a}.PX_{p}({r}, {dd}, {D}, {q}, {W})',
                rt=lambda D, X, q, r: f'{a}.{p}_any(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf, @hz)',
                by=lambda D, X, q, r: f'{a}.{p}_any_bytes(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf, @hz)',
                pf=lambda r, D, q, p_: f'{a}.{p}x_perfect({r}, dd, {D}, {q}, {W}, {p_})', Y=f'FX.limbs([{W}])', put=p, m=fs.fsize, mod=f'import ./vuwv_{p}.bend as {a}')


UREC_PRE = TPL.text('UREC_PRE')


def urec_text(n):
    from codegen.impl import generate as G
    g, names = layout()
    s = g.shape(names[n])
    F = s.fields
    hoff, L = G.container_layout(F)
    Ln = f'{L}n'
    lv = [_uleaf(fs, f, k) for k, (f, fs) in enumerate(F)]
    ws = [w for x in lv for w in x['ws']]
    WSIG = ', '.join(f'+{w}: Bool' if (fs.kind == 'bool') else f'+{w}: U32' for x, (f, fs) in zip(lv, F) for w in x['ws'])
    WA = ', '.join(ws)
    OBJ = f'T.{n}{{' + ', '.join(x['obj'] for x in lv) + '}'
    X0 = 'Nat.add(A.quad(q), r)'
    QC = lambda c: f'VCN.QX(U32.add(X, {c}))'  # noqa: E731
    RC = lambda c: f'VCN.RX(U32.add(X, {c}))'  # noqa: E731

    def tree(i):
        t = 'D'
        for j in range(i):
            t = lv[j]['model'](RC(hoff[j]), 'dd', t, QC(hoff[j]))
        return t
    BYTES = 'List.append(&2, U32, ' + ', List.append(&2, U32, '.join(x['Y'] for x in lv[:-1]) + ', ' + lv[-1]['Y'] + ')' * (len(lv) - 1)
    out = [UREC_PRE]
    w = out.append
    w(f'# ---- {n}: {len(F)} fields, {L} bytes ----')
    w(f'def PX_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32) -> {TR}: {tree(len(F))}')
    pfs = 'pf'
    for i in range(len(F)):
        pfs = lv[i]['pf'](RC(hoff[i]), tree(i), QC(hoff[i]), pfs)
    for line in TPL.render('urec_text_lines', BYTES=BYTES, WA=WA, WSIG=WSIG, n=n, pfs=pfs).split('\n'):
        w(line)
    RT = f'{{T.{n}_put(FD.array__thaw(U32, D), X, {OBJ}) == FD.array__thaw(U32, PX_{n}({WA}, dd, D, X)) : Array<U32>}}'
    BY = f'{{UA.BYT(PX_{n}({WA}, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, BY_{n}({WA})) : +List<U32>}}'
    w(TPL.render('urec_text', BY=BY, Ln=Ln, RT=RT, WA=WA, WSIG=WSIG, n=n))

    def put_expr(i, inner):
        return f'T.{lv[i]["put"]}_put({inner}, U32.add(X, {hoff[i]}), {lv[i]["obj"]})'
    rts = []
    body = [TPL.render('urec_text_putx_', L=L, Ln=Ln, WA=WA, WSIG=WSIG, X0=X0, n=n)]
    b = body.append
    E = f'UW.ZB({Ln})'
    pf_cur = 'pf'
    for i, (f, fs) in enumerate(F):
        c, m, x = hoff[i], lv[i]['m'], lv[i]
        Di, Dn = tree(i), tree(i + 1)
        Xc = f'U32.add(X, {c})'
        pos = f'Nat.add(A.quad({QC(c)}), {RC(c)})'
        for line in TPL.render('urec_text_lines_2', Di=Di, E=E, Ln=Ln, X0=X0, c=c, i=i, m=m, pos=pos).split('\n'):
            b(line)
        sub = lambda t: t.replace('@e', f'VC.split4({Xc})').replace('@hr', f'VCN.rx_lt({Xc})').replace('@hl', f'hl{i}').replace('@pf', pf_cur).replace('@hz', f'hz{i}')  # noqa: E731
        b(f'  +rt{i} = {sub(x["rt"](Di, Xc, QC(c), RC(c)))}')
        b(f'  +by{i} = {sub(x["by"](Di, Xc, QC(c), RC(c)))}')
        Y = x['Y']
        b(f'  +hop{i} = FD.logic__subst(Nat, zz => {{UA.BYT({Dn}) == UW.SPL(UA.BYT({Di}), zz, {Y}) : +List<U32>}}, {pos}, Nat.add({X0}, {c}n), Equal.sym(Nat, Nat.add({X0}, {c}n), {pos}, pp{i}), by{i})')
        rr = L - c - m
        b(f'  +I{i + 1} = UW.inv_step(UA.BYT(D), {X0}, {Ln}, {E}, {c}n, {Y}, {rr}n, UA.BYT({Di}), UA.BYT({Dn}), hX, I{i}, hop{i}, {{==}}, {{==}})')
        E = f'UW.SPL({E}, {c}n, {Y})'
        rts.append((i, Di, Dn))
        pf_cur = x['pf'](RC(c), Di, QC(c), pf_cur)
    b(f'  +byf = FD.logic__subst(+List<U32>, zz => {{UA.BYT(PX_{n}({WA}, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VS.bt({Ln}, {E}), BY_{n}({WA}), {{==}}, I{len(F)})')
    b(f'  (rt_{n}({WA}, dd, D, X, {", ".join(f"rt{i}" for i in range(len(F)))}), byf)')

    def outer(i, hole):
        t = hole
        for j in range(i + 1, len(F)):
            t = put_expr(j, t)
        return t
    RTP = [f'+rt{i}: {{{put_expr(i, f"FD.array__thaw(U32, {Di})")} == FD.array__thaw(U32, {Dn}) : Array<U32>}}' for i, Di, Dn in rts]
    w(f'def rt_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32,\n    ' + ',\n    '.join(RTP) + f')\n    -> {RT}:')
    for i, Di, Dn in rts:
        w(f'  %Equal.sym(Array<U32>, {put_expr(i, f"FD.array__thaw(U32, {Di})")}, FD.array__thaw(U32, {Dn}), rt{i}) :')
        w(f'    {{{outer(i, "_")} == FD.array__thaw(U32, PX_{n}({WA}, dd, D, X)) : Array<U32>}}')
    w('  {==}')
    w('')
    out += body
    mods = []
    for x in lv:
        if x.get('mod') and x['mod'] not in mods:
            mods.append(x['mod'])
    Lh = HEAD + ['import ./vcont.bend as VCN', 'import ./vcopy.bend as VC', 'import ./vpiece.bend as VP', 'import ./vuwl_u8.bend as W8'] + mods + [
        '', '# GENERATED by var_rec_enc (codegen). Do not edit.',
        f'# {n} ({L} bytes, fields at any byte offset) written at any byte position X = 4 q + r (see the generator).', '',
        'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
        'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b']
    return '\n'.join(Lh) + '\n' + '\n'.join(out) + '\n'

# ---- the Validator list (List[Validator, 2^40]): records of 121 bytes at byte stride 121 ------------------
# Record j is written at Xj = X + 121 j (U32.add(X, U32.mul(i, 121))) by encx_Validator.putx_Validator at
# (QX(Xj), RX(Xj)); its bytes are spliced at X0 + 121 j (vcont.vpos / croom, vrecx.znext / spl_catx).
# The list's value: its records' values (spec_rec_Validator), one variable part (Spec.Schema78).

VLIST = 'l1099511627776_Validator'


def _vlist_shared_lemmas():
    """the pair projections and the Bool conjunction lemmas shared by the module"""
    return TPL.render('_vlist_shared_lemmas')


def _vlist_record_laws(R, NEST, PAD, BYV, VAL, WSG, S, SPB, bv, rbeq_cases, WA, DOM, X0, es, xs):
    """the record's bytes, value and parts, and its writer at any X"""
    return TPL.render('_vlist_record_laws', BYV=BYV, DOM=DOM, NEST=NEST, PAD=PAD, R=R, S=S, SPB=SPB, VAL=VAL, WA=WA, WSG=WSG, X0=X0, bv=bv, es=es, rbeq_cases=rbeq_cases, xs=xs)


def _vlist_positions(X0, S, XJ, RS):
    """positions at the byte stride of a record: the products, the position and the room of record j"""
    return TPL.render('_vlist_positions', RS=RS, S=S, X0=X0, XJ=XJ)


def _vlist_record_values(p, TRR, R, TH, S):
    """the list's records, their bytes and values, and the root laws of the list"""
    return TPL.render('_vlist_record_values', R=R, S=S, TH=TH, TRR=TRR, p=p)


def _vlist_write_loop(p, R, RS, TRR, XJ, TH, RTP, X0, S):
    """the write loop at X = 4q + r: the perfect tree, a record's write and the loop over the records"""
    return TPL.render('_vlist_write_loop', R=R, RS=RS, RTP=RTP, S=S, TH=TH, TRR=TRR, X0=X0, XJ=XJ, p=p)


def _vlist_encoder_window(p, TRR, TH, R, S, ENC, X0, LLv, RTP, RS):
    """the list's encoder window: its object, bytes, the writer's model, validity and the runtime writer"""
    return TPL.render('_vlist_encoder_window', ENC=ENC, LLv=LLv, R=R, RS=RS, RTP=RTP, S=S, TH=TH, TRR=TRR, X0=X0, p=p)


def _vlist_sizes(p, TRR, R, RS, TH, LLv, S, X0):
    """the sizes: the runtime's size pass and the size the writer returns"""
    return TPL.render('_vlist_sizes', LLv=LLv, R=R, RS=RS, S=S, TH=TH, TRR=TRR, X0=X0, p=p)


def _vlist_spec_side(p, TRR, LLv, S):
    """the spec side: the list's value and the encx_spec statement"""
    return TPL.render('_vlist_spec_side', LLv=LLv, S=S, TRR=TRR, p=p)


def vlist_text():
    from codegen.impl import generate as G  # noqa: F401  kept: the import may register hooks at import time
    p, R, RS = VLIST, 'Validator', 121
    g, names = layout()
    F_ = g.shape(names[R]).fields
    ups = []          # (field, words) in putx_Validator's order
    for f, fs in F_:
        if fs.kind == 'u64':
            ups.append((f, fs, [f'{f}_lo', f'{f}_hi']))
        elif fs.kind == 'bool':
            ups.append((f, fs, [f]))
        else:
            ups.append((f, fs, [f'{f}_{j}' for j in range(fs.fsize // 4)]))
    WA = ', '.join(w for _, _, ws in ups for w in ws)
    lines = ['  match o:', '    case T.Validator{' + ', '.join(f'+o{k}' if fs.kind != 'bool' else f'+{f}' for k, (f, fs, _) in enumerate(ups)) + '}:']
    ind = 6
    for k, (f, fs, ws) in enumerate(ups):
        if fs.kind == 'bool':
            continue
        ctor = 'O.U64' if fs.kind == 'u64' else f'T.{fs.rep}'
        lines.append(' ' * ind + f'match o{k}:')
        lines.append(' ' * (ind + 2) + f'case {ctor}{{' + ', '.join('+' + w for w in ws) + '}:')
        ind += 4
    NEST = '\n'.join(lines)
    PAD = ' ' * ind
    xs = [w for f, fs, ws in ups[:3] for w in ws]
    bv = ups[3][2][0]
    es = [w for f, fs, ws in ups[4:] for w in ws]
    u = lambda a, b: f'S.UnsignedValue{{P.UInt{{{a}, {b}, 0, 0, 0, 0, 0, 0}}}}'  # noqa: E731
    items = [f'S.BytesValue{{F.limbs([{", ".join(ups[0][2])}])}}', f'S.BytesValue{{F.limbs([{", ".join(ups[1][2])}])}}', u(*ups[2][2]), f'S.BooleanValue{{{bv}}}'] + \
        [u(*ups[k][2]) for k in range(4, 8)]
    VAL = 'S.Sequence{' + ''.join(f'S.Items{{{it}, ' for it in items) + 'S.EmptyItems{}' + '}' * len(items) + '}'
    SPB = f'List.append(&2, U32, F.limbs([{", ".join(xs)}]), List.append(&2, U32, SP.boolean_encoding({bv}), F.limbs([{", ".join(es)}])))'
    BYV = f'EV.BY_{R}({WA})'
    TRR = f'FD.array__Tree<T.{R}>'
    TH = f'FD.array__thaw(T.{R}, A)'
    RTP = f'Array<U32> & Array<T.{R}>'
    X0 = 'Nat.add(A.quad(q), r)'
    S = f'{RS}n'
    XJ = f'U32.add(X, U32.mul(i, {RS}))'
    LLv = f'LL_{p}(A, N)'
    ENC = f'(CHV_{p}(U32.to_nat(N), A, 0n))'
    WSG = ', '.join(f'+{w}: Bool' if fs.kind == 'bool' else f'+{w}: U32' for f, fs, ws in ups for w in ws)
    ys = [f'F.limbs([{", ".join(ws)}])' if fs.kind != 'bool' else f'[EV.BB({ws[0]})]' for f, fs, ws in ups]
    dms = [f'F.domain_limbs([{", ".join(ws)}])' if fs.kind != 'bool' else f'domBB({ws[0]})' for f, fs, ws in ups]

    def dom(k):
        if k == len(ys) - 1:
            return dms[k]
        rest = ys[k + 1] if k + 1 == len(ys) - 1 else 'List.append(&2, U32, ' + ', List.append(&2, U32, '.join(ys[k + 1:-1]) + ', ' + ys[-1] + ')' * (len(ys) - k - 2)
        return f'PI.append_domain({ys[k]}, {rest}, {dms[k]}, {dom(k + 1)})'
    DOM = dom(0)
    rbeq_cases = '\n'.join(f'    case {c}{{}}: {{{{==}}}}'.replace('{{==}}', '{==}') for c in ('True', 'False'))
    return (
        _vlist_shared_lemmas() +
        _vlist_record_laws(R, NEST, PAD, BYV, VAL, WSG, S, SPB, bv, rbeq_cases, WA, DOM, X0, es, xs) +
        _vlist_positions(X0, S, XJ, RS) +
        _vlist_record_values(p, TRR, R, TH, S) +
        _vlist_write_loop(p, R, RS, TRR, XJ, TH, RTP, X0, S) +
        _vlist_encoder_window(p, TRR, TH, R, S, ENC, X0, LLv, RTP, RS) +
        _vlist_sizes(p, TRR, R, RS, TH, LLv, S, X0) +
        _vlist_spec_side(p, TRR, LLv, S))


def vlist_module():
    L = LHEAD + ['import ./vcont.bend as VCN', 'import ./vcopy.bend as VC', 'import ./vu40.bend as V40', 'import ./encx_Validator.bend as EV',
                 'import ./spec_rec_Validator.bend as SRV', 'import ./vmv.bend as VMV', 'import ../../proofs/primitive_invariants.bend as PI', '', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                 f'# The encoder window of {VLIST} (records of 121 bytes at any byte phase) at any byte position (see the generator).', '']
    return '\n'.join(L) + vlist_text()

LHEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
         'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
         'import ./vmr.bend as VMR', 'import ./vfix.bend as VF', 'import ./vua.bend as UA', 'import ./vuw.bend as UW', 'import ./vuwd.bend as WD',
         'import ./vrl.bend as VRL', 'import ./vbsize.bend as VBZ', 'import ./vrecx.bend as VRX', 'import ./encx_recs.bend as ERC', 'import ./dk.bend as DK']

COMMON = TPL.text('COMMON')


def list_module(g, names, parent, field):
    from codegen.proofs.var import var_rlist as VRG
    from codegen.proofs.var import var_rlist_enc as EN
    I = VRG.info(g, names, parent, field)
    p, R, RS, W, LIM = I['p'], I['R'], I['RS'], I['W'], I['LIM']
    nd = VL.SL.walk(g, I['rt'], iter(range(100000)))
    sp = EN.spec_list_text(p, R, RS, W, LIM, nd.sch)
    sp = sp[:sp.index('\n# the run of record j lies')] + '\n'
    L = LHEAD + ['', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                 f'# The encoder window of {p} (a list of fixed records) at any byte position (see the generator).', '', COMMON]
    L.append(obj_text(VL, EN, g, I["rt"], (nd.val, nd.sch, nd.proof, nd.obj)))
    L.append(f"def EL_{p}(+A: FD.array__Tree<T.{R}>, +j: Nat) -> T.{R}: VRL.mget(T.{R}, FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), j), T.{R}_default())")
    L.append(sp)
    lt = loop_text(p, R, RS, W, LIM)
    lt = lt.replace(f"def EL_{p}(+A: FD.array__Tree<T.{R}>, +j: Nat) -> T.{R}: VRL.mget(T.{R}, FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), j), T.{R}_default())\n", '')
    L.append(lt)
    L.append(spec_x_text(p, R, W, LIM, nd.sch))
    return p, '\n'.join(L) + '\n'


# ---- lists of records with sub-word fields (uint8 / uint16), byte-granular -----------------------
# The generic lists l10_ProgressiveSingleFieldContainerTestStruct (List[{uint8}, 10]) and pl_SmallTestStruct (ProgressiveList[{uint16,
# uint16}]) in the encoder-window interface of var_plist_sub.ENCX (mirror MW{da, A, N}: the record tree A
# of depth da holding the list's N records). A record's fields are written by the sub-word leaves at a
# byte position P (vrecb.W8P / W16P over vuwl_u8.W8X / vuwl_u16.W16X at 4 QP(P) + RP(P)); its bytes are
# its fields' bytes (byte lists: [x & 255], [x & 255, (x >> 8) & 255]), its value is read back from them
# (vrecb.UV8 / UV16), so its parts are its bytes with no validity assumption. Record j of the list is at
# byte P0 + RS j (vrl.pos; vrecb.posb, rroomb, pnext), its bytes splice into the zero window there
# (vrecx.zhead, znext, spl_catx), and the list's validity check is modeled by VOK (the records'
# T.R_valid), proved by the loop vax.

SUBLISTS = [('pl_SmallTestStruct', 'SmallTestStruct', None), ('l10_ProgressiveSingleFieldContainerTestStruct', 'ProgressiveSingleFieldContainerTestStruct', 10)]


def sub_file(p):
    return ROOT / f'proofs/obj/encx_{p}.bend'


def sub_fields(R):
    """The record's fields [(name, byte offset, 'u8' | 'u16')] from the runtime type and var_rlist_sub.RECS."""
    import re
    from codegen.proofs.var import var_rlist_sub as VRS
    src = RR.mono_text('generic')
    m = re.search(rf'^type {R} is Data:\n  {R}\{{([^}}]*)\}}', src, re.M)
    names = [f.split(':')[0].strip() for f in m.group(1).split(',')]
    RS, sch, fl = VRS.RECS[R] if R in VRS.RECS else SUBRECS[R]
    assert len(names) == len(fl)
    return RS, sch, [(nm, c, SUBK[sz]) for nm, (c, sz, *_rest) in zip(names, fl)]


# records of the vectors (RVECS) not in var_rlist_sub.RECS: (size, schema, fields [(byte offset, size)])
SUBRECS = {
    'FixedTestStruct': (13, 'S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}',
                     [(0, 1), (1, 8), (9, 4)]),
}
# vectors of such records (runtime prefix, record, length): a fixed field of a container, written by its putk
# (checked, its size flag 0), in the FixW form of codegen/proofs/var/var_cont_enc.py (fwrt / fwby / lenv / validx / vspec)
RVECS = [('v4_FixedTestStruct', 'FixedTestStruct', 4)]


# field size -> kind; a field's pattern, arguments (its words), object and bytes
SUBK = {1: 'u8', 2: 'u16', 4: 'u32', 8: 'u64'}


def VS_(nm, k):
    return [f'{nm}_lo', f'{nm}_hi'] if k == 'u64' else [nm]


def AR_(nm, k):
    return ', '.join(VS_(nm, k))


def PT_(nm, k):
    return f'O.U64{{+{nm}_lo, +{nm}_hi}}' if k == 'u64' else f'+{nm}'


def OB_(nm, k):
    return f'O.U64{{{nm}_lo, {nm}_hi}}' if k == 'u64' else nm


def SUBY(nm, k):
    def l4(x):
        return [f'U32.and({x}, 255)', f'U32.and(U32.shrn({x}, 8n), 255)', f'U32.and(U32.shrn({x}, 16n), 255)', f'U32.shrn({x}, 24n)']
    if k == 'u8':
        return [f'U32.and({nm}, 255)']
    if k == 'u16':
        return [f'U32.and({nm}, 255)', f'U32.and(U32.shrn({nm}, 8n), 255)']
    if k == 'u32':
        return l4(nm)
    return l4(f'{nm}_lo') + l4(f'{nm}_hi')


SUBHEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/generic_obj.bend as T', 'import ../../types/schema.bend as S',
           'import ../../types/primitive.bend as P', 'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A',
           'import ../../proofs/nat_order.bend as Order', 'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout',
           'import ../../spec/codec.bend as Codec', 'import ../../spec/nat_bytes.bend as N', 'import ./spec_fixed.bend as F',
           'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU', 'import ./vua.bend as UA',
           'import ./vuw.bend as UW', 'import ./vuwd.bend as WD', 'import ./vrl.bend as VRL', 'import ./vrecx.bend as VRX',
           'import ./vrecb.bend as VRB', 'import ./vfits.bend as VFT', 'import ./vmv.bend as VMV', 'import ./sub_pack.bend as SP2',
           'import ./dk.bend as DK']


def sub_rec_text(R, RS, sch, fields):
    """The record R at a byte position P: its bytes RB, model PR, perfect, the runtime's T.R_put, value, parts."""
    TR = 'FD.array__Tree<U32>'
    pat = f'T.{R}{{' + ', '.join(PT_(nm, k) for nm, c, k in fields) + '}'

    def by(nm, k):
        return SUBY(nm, k)
    ys = [by(nm, k) for nm, c, k in fields]
    RB = '[' + ', '.join(sum(ys, [])) + ']'
    ms = [len(y) for y in ys]
    W = {'u8': 'VRB.W8P', 'u16': 'VRB.W16P', 'u32': 'VRB.W32P', 'u64': 'VRB.W64P'}
    PFW = {'u8': 'VRB.w8p_perfect', 'u16': 'VRB.w16p_perfect', 'u32': 'VRB.w32p_perfect', 'u64': 'VRB.w64p_perfect'}
    RTW = {'u8': 'VRB.w8p_rt', 'u16': 'VRB.w16p_rt', 'u32': 'VRB.w32p_rt', 'u64': 'VRB.w64p_rt'}
    BYW = {'u8': 'VRB.w8p_bytes', 'u16': 'VRB.w16p_bytes', 'u32': 'VRB.w32p_bytes', 'u64': 'VRB.w64p_bytes'}
    PUT = {'u8': 'T.u8_put', 'u16': 'T.u16_put', 'u32': 'T.u32_put', 'u64': 'T.u64_put'}

    def pos(c):
        return f'Nat.add({c}n, P)'

    def tree(i):
        t = 'D'
        for nm, c, k in fields[:i]:
            t = f'{W[k]}(dd, {t}, {pos(c)}, {AR_(nm, k)})'
        return t
    n = len(fields)
    pfs = 'pf'
    for i, (nm, c, k) in enumerate(fields):
        pfs = f'{PFW[k]}(dd, {tree(i)}, {pos(c)}, {AR_(nm, k)}, {pfs})'
    uv = {'u8': lambda x: f'VRB.UV8({x})', 'u16': lambda x: f'VRB.UV16({x})',
          'u32': lambda x: f'S.UnsignedValue{{P.UInt{{{x}, 0, 0, 0, 0, 0, 0, 0}}}}',
          'u64': lambda x: f'S.UnsignedValue{{P.UInt{{{x}_lo, {x}_hi, 0, 0, 0, 0, 0, 0}}}}'}
    items = 'S.EmptyItems{}'
    for nm, c, k in reversed(fields):
        items = f'S.Items{{{uv[k](nm)}, {items}}}'
    L = []
    w = L.append
    w(TPL.render('sub_rec_text', R=R, RB=RB, RS=RS, TR=TR, n=n, pat=pat, pfs=pfs, tree=tree))
    pf_cur = 'pf'
    acc = []  # the bytes written so far
    for i, (nm, c, k) in enumerate(fields):
        m = ms[i]
        Di, Dn = tree(i), tree(i + 1)
        Pi = pos(c)
        Xi = f'U32.add(X, {c})'
        w(f'      +ep{i} = VRB.fposb(dd, X, {c}, P, {RS}n, e, hd, hb, {{==}})')
        w(f'      +hb{i} = VRB.froomb(P, {c}n, {m}n, {RS}n, A.quad(VB.pw(dd)), hb, {{==}})')
        rest = RS - c - m
        if i == 0:
            zsrc = 'hz'
        else:
            A0 = '[' + ', '.join(acc) + ']'
            w(f'      +z{i}a = VRX.znext(B, P, {A0}, {Pi}, {c}n, {RS - c}n, UA.BYT({Di}), hX, {{==}}, VRB.pcx(P, {c}n), E{i}, hz)')
            zsrc = f'z{i}a'
        if rest > 0:
            Lz = f'UA.BYT({Di})' if i else 'B'
            w(f'      +hz{i} = VRX.zhead({m}n, {rest}n, VS.bdr({Pi}, {Lz}), {zsrc})')
        else:
            w(f'      +hz{i} = {zsrc}')
        w(f'      +rt{i} = {RTW[k]}(dd, {Di}, {Xi}, {Pi}, {AR_(nm, k)}, ep{i}, hd, hb{i}, {pf_cur})')
        w(f'      +by{i} = {BYW[k]}(dd, {Di}, {Xi}, {Pi}, {AR_(nm, k)}, ep{i}, hd, hb{i}, {pf_cur}, hz{i})')
        Y = '[' + ', '.join(ys[i]) + ']'
        if i == 0:
            w(f'      +E1 = by0')
        else:
            A0 = '[' + ', '.join(acc) + ']'
            w(f'      +E{i + 1} = Equal.trans(+List<U32>, UA.BYT({Dn}), UW.SPL(UA.BYT({Di}), {Pi}, {Y}), UW.SPL(B, P, VRX.AP({A0}, {Y})), by{i},')
            w(f'        VRX.spl_catx(B, P, {A0}, {Y}, {Pi}, UA.BYT({Di}), hX, VRB.pcx(P, {c}n), E{i}))')
        acc += ys[i]
        pf_cur = f'{PFW[k]}(dd, {Di}, {Pi}, {AR_(nm, k)}, {pf_cur})'

    # the runtime: rewrite the innermost put first
    def rt_goal_after(i):
        """the runtime expression with the first i puts already replaced by the model tree D_i."""
        t = f'FD.array__thaw(U32, {tree(i)})'
        for nm, c, k in fields[i:]:
            t = f'{PUT[k]}({t}, U32.add(X, {c}), {OB_(nm, k)})'
        return t
    w(f'      +rtf = rtc_{R}(dd, D, X, P, {", ".join(AR_(nm, k) for nm, c, k in fields)}, {", ".join(f"rt{i}" for i in range(n))})')
    w(f'      (rtf, E{n})')
    # the runtime chain lemma
    RTP = []
    for i, (nm, c, k) in enumerate(fields):
        RTP.append(f'+rt{i}: {{{PUT[k]}(FD.array__thaw(U32, {tree(i)}), U32.add(X, {c}), {OB_(nm, k)}) == FD.array__thaw(U32, {tree(i + 1)}) : Array<U32>}}')
    sig = ', '.join(f'+{v}: U32' for nm, c, k in fields for v in VS_(nm, k))
    C = [f'def rtc_{R}(+dd: Nat, +D: {TR}, +X: U32, +P: Nat, {sig},\n    ' + ',\n    '.join(RTP) +
         f')\n    -> {{{rt_goal_after(0)} == FD.array__thaw(U32, {tree(n)}) : Array<U32>}}:']
    for i, (nm, c, k) in enumerate(fields[:-1]):
        lhs = f'{PUT[k]}(FD.array__thaw(U32, {tree(i)}), U32.add(X, {c}), {OB_(nm, k)})'
        hole = '_'
        for nm2, c2, k2 in fields[i + 1:]:
            hole = f'{PUT[k2]}({hole}, U32.add(X, {c2}), {OB_(nm2, k2)})'
        C.append(f'  %Equal.sym(Array<U32>, {lhs}, FD.array__thaw(U32, {tree(i + 1)}), rt{i}) :')
        C.append(f'    {{{hole} == FD.array__thaw(U32, {tree(n)}) : Array<U32>}}')
    C.append(f'  rt{n - 1}')
    text = '\n'.join(L)
    cut = text.index(f'\n# T.{R}_put at X (byte P)')
    text = text[:cut].rstrip('\n') + '\n\n' + '\n'.join(C) + '\n' + text[cut:]
    # the value and its parts
    chain = sch[sch.index('S.Chain'):]
    chain = chain[:len(chain) - (len(chain) - chain.rfind('S.End{}') - len('S.End{}'))]
    chain += '}' * (len(fields) - 1)
    fsch = {'u8': 'S.Unsigned{P.U8{}}', 'u16': 'S.Unsigned{P.U16{}}', 'u32': 'S.Unsigned{P.U32Width{}}', 'u64': 'S.Unsigned{P.U64{}}'}
    prt = {'u8': lambda x: f'VRB.prt8({x})', 'u16': lambda x: f'VRB.prt16({x})', 'u32': lambda x: f'F.uint32_part({x})',
           'u64': lambda x: f'F.uint64_part({x}_lo, {x}_hi)'}
    dom = {'u8': lambda x: f'VRB.dom8({x})', 'u16': lambda x: f'VRB.dom16({x})', 'u32': lambda x: f'F.domain_limbs([{x}])',
           'u64': lambda x: f'F.domain_limbs([{x}_lo, {x}_hi])'}

    def chain_from(i):
        t = 'S.End{}'
        for nm, c, k in reversed(fields[i:]):
            t = f'S.Chain{{{fsch[k]}, {t}}}'
        return t

    def items_from(i):
        t = 'S.EmptyItems{}'
        for nm, c, k in reversed(fields[i:]):
            t = f'S.Items{{{uv[k](nm)}, {t}}}'
        return t

    def cat(i):
        if i == n:
            return '{==}'
        nm, c, k = fields[i]
        Y = '[' + ', '.join(ys[i]) + ']'
        restp = '[' + ', '.join(f'S.Fixed{{[{", ".join(ys[j])}]}}' for j in range(i + 1, n)) + ']'
        return (f'F.cat_fixed(Codec.parts({uv[k](nm)}, {fsch[k]}), {Y}, Codec.parts({items_from(i + 1)}, {chain_from(i + 1)}), {restp},\n'
                f'        {prt[k](nm)}, {cat(i + 1)})')
    PL = '[' + ', '.join(f'S.Fixed{{[{", ".join(ys[j])}]}}' for j in range(n)) + ']'

    def domc(i):
        nm, c, k = fields[i]
        Y = '[' + ', '.join(ys[i]) + ']'
        if i == n - 1:
            return f'SP2.bd_app({Y}, [], {dom[k](nm)}, {{==}})'
        tail = '[' + ', '.join(sum(ys[i + 1:], [])) + ']'
        return f'SP2.bd_app({Y}, {tail}, {dom[k](nm)}, {domc(i + 1)})'
    text += TPL.render('sub_rec_text_RV_', PL=PL, R=R, RB=RB, RS=RS, cat=cat, chain_from=chain_from, domc=domc, items=items, pat=pat, sch=sch)
    return text


def ok_chain(name, args, sig, cs):
    """Accessors of a conjunction Bool.and(c0, Bool.and(c1, ... c{n-1})): {name}_i(args, h) -> {c_i == True}."""
    def conj(i):
        return cs[i] if i == len(cs) - 1 else f'Bool.and({cs[i]}, {conj(i + 1)})'
    L = []
    for i in range(len(cs) - 1):
        src = 'h' if i == 0 else f'{name}_r{i}({args}, h)'
        L.append(f'def {name}_r{i + 1}({sig}, +h: {{{conj(0)} == {TRUE}}}) -> {{{conj(i + 1)} == {TRUE}}}:')
        L.append(f'  and_r({cs[i]}, {conj(i + 1)}, {src})')
    for i in range(len(cs)):
        src = 'h' if i == 0 else f'{name}_r{i}({args}, h)'
        if i == len(cs) - 1:
            L.append(f'def {name}_{i}({sig}, +h: {{{conj(0)} == {TRUE}}}) -> {{{cs[i]} == {TRUE}}}: {src}')
        else:
            L.append(f'def {name}_{i}({sig}, +h: {{{conj(0)} == {TRUE}}}) -> {{{cs[i]} == {TRUE}}}:')
            L.append(f'  and_l({cs[i]}, {conj(i + 1)}, {src})')
    return conj(0), '\n'.join(L)


SUBLIST = TPL.text('SUBLIST')


def sub_text(p, R, LIM):
    RS, sch, fields = sub_fields(R)
    TRR = f'FD.array__Tree<T.{R}>'
    TH = f'FD.array__thaw(T.{R}, A)'
    cs = ['Nat.is_lt(da, 28n)', f'FD.array__perfect(T.{R}, da, A)', 'Nat.is_le(U32.to_nat(N), VB.pw(da))',
          f'Nat.is_le(Nat.mul(U32.to_nat(N), {RS}n), A.quad(VB.pw(da)))']
    if LIM:
        cs.append(f'U32.is_le(N, {LIM})')
    cs.append('VOK(U32.to_nat(N), A, 0n)')
    sig = f'+da: Nat, +A: {TRR}, +N: U32'
    conj, acc = ok_chain('ok', 'da, A, N', sig, cs)
    okdefs = f'def OKT({sig}) -> Bool:\n  {conj}\n{acc}'
    if LIM:
        LSCH = f'S.ListOf{{{sch}, {LIM}n}}'
        okarg = f'Bool.or(False{{}}, U32.is_le(N, {LIM}))'
        okarg1 = 'Bool.or(False{}, True{})'
        limrw = (f'  %Equal.sym(Bool, U32.is_le(N, {LIM}), True{{}}, ok_4(da, A, N, h)) :\n'
                 f'    {{T.@p_va_go(Bool.and(Bool.or(False{{}}, _), U32.is_le(N, FD.u32__pow2u(da))), N, @TH) == (T.@p_Seq{{@TH, N}}, True{{}}) : T.@p_Seq & Bool}}\n')
        specrw = (TPL.render('specrw', LIM=LIM))
        agg = 'Codec.require(True{}, @)'
        okdoc = f', at most {LIM} records'
        vi = 5
    else:
        LSCH = f'S.ProgressiveList{{{sch}}}'
        okarg, okarg1, limrw, specrw, agg, okdoc, vi = 'True{}', 'True{}', '', '', '@', '', 4
    body = SUBLIST
    body = body.replace('@SPECRW', specrw).replace('@LIMRW', limrw).replace('@OKDEFS', okdefs)
    AGG_open, AGG_close = agg.split('@')
    body = body.replace('@AGG(Codec.aggregate(_, None{}))', AGG_open + 'Codec.aggregate(_, None{})' + AGG_close)
    body = (body.replace('@OKARG1', okarg1).replace('@OKARG', okarg).replace('@OKDOC', okdoc).replace('@VI', str(vi))
            .replace('@LSCH', LSCH).replace('@SCH', sch).replace('@TRR', TRR).replace('@TR', 'FD.array__Tree<U32>').replace('@TH', TH)
            .replace('@RTP', f'Array<U32> & Array<T.{R}>').replace('@RSn', f'{RS}n').replace('@RS', str(RS)).replace('@p', p).replace('@R', R))
    L = SUBHEAD + ['', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                   f'# {p} (a list of {R} records, {RS} bytes each) in the encoder-window interface, written at any byte',
                   '# position X = 4 q + r of a perfect tree D of depth dd < 29 (see the generator).', '', COMMON]
    return '\n'.join(L) + sub_rec_text(R, RS, sch, fields) + body




VEC_TAIL = TPL.text('VEC_TAIL')


def vec_text(p, R, NV):
    """A vector of NV records R (RVECS): the list machinery of SUBLIST up to its writer's loop, then the
    vector's checked writer (its size flag 0) and its laws in the FixW form (VEC_TAIL)."""
    RS, sch, fields = sub_fields(R)
    TRR = f'FD.array__Tree<T.{R}>'
    TH = f'FD.array__thaw(T.{R}, A)'
    cs = ['Nat.is_lt(da, 28n)', f'FD.array__perfect(T.{R}, da, A)', 'Nat.is_le(U32.to_nat(N), VB.pw(da))',
          f'U32.is_eq(N, {NV})', 'VOK(U32.to_nat(N), A, 0n)']
    sig = f'+da: Nat, +A: {TRR}, +N: U32'
    conj, acc = ok_chain('ok', 'da, A, N', sig, cs)
    okdefs = f'def OKT({sig}) -> Bool:\n  {conj}\n{acc}'
    limrw = (f'  %Equal.sym(Bool, U32.is_eq(N, {NV}), True{{}}, ok_3(da, A, N, h)) :\n'
             f'    {{T.@p_va_go(Bool.and(_, U32.is_le(N, FD.u32__pow2u(da))), N, @TH) == (T.@p_Seq{{@TH, N}}, True{{}}) : T.@p_Seq & Bool}}\n')
    body = SUBLIST[:SUBLIST.index('\ndef RTX(')] + '\n' + VEC_TAIL
    body = body.replace('@LIMRW', limrw).replace('@OKDEFS', okdefs)
    body = (body.replace('@OKARG1', 'True{}').replace('@OKARG', f'U32.is_eq(N, {NV})').replace('@OKDOC', f', exactly {NV} records').replace('@VI', '4')
            .replace('@NVn', f'{NV}n').replace('@NV', str(NV)).replace('@NBn', f'{NV * RS}n').replace('@NB', str(NV * RS))
            .replace('@SCH', sch).replace('@TRR', TRR).replace('@TR', 'FD.array__Tree<U32>').replace('@TH', TH)
            .replace('@RTP', f'Array<U32> & Array<T.{R}>').replace('@RSn', f'{RS}n').replace('@RS', str(RS)).replace('@p', p).replace('@R', R))
    body = body.replace(f'with room for the N records, whose {RS} N bytes fit\n# 4 2^da, exactly', 'with room for the N records,\n# exactly')
    L = SUBHEAD + ['import ../../spec/schema.bend as SS', '', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                   f'# {p} (a vector of {NV} {R} records, {RS} bytes each) as a fixed field: written at any byte',
                   '# position X = 4 q + r of a perfect tree D of depth dd < 29 (see the generator: vec_text).', '', COMMON]
    return '\n'.join(L) + sub_rec_text(R, RS, sch, fields) + body


# ---- lists of boxed fixed-size elements (a swap loop over O.Boxed) --------------------------------
# proofs/obj/encx_<p>.bend: the element's writer on its root_types mirror M_<E> (its fields boxed Data
# records, written through encx_recs' putx_<R> in the object form of obj_text), then the list of
# codegen/templates/vrlb_list.bend.in: element i at X + RS i through T.<p>_pt's swap loop (vcont / vrecx for the
# positions and the bytes).
BLISTS_BOX = [('BeaconBlockBody', 'proposer_slashings'), ('BeaconBlockBody', 'deposits')]


def _brec_fields(g, names, E):
    """[(field, record type, byte offset)] of an element whose fields are boxed Data records."""
    t = names[E]
    s = g.shape(t)
    out, c = [], 0
    for (f, ft), (_, fs) in zip(t.fields, s.fields):
        if fs.kind != 'box':
            raise SystemExit(f'{E}.{f}: {fs.kind} is not a boxed record')
        out.append((f, ft, c))
        c += ft.fixed_size()
    return out, c



def _spec_def(name):
    """The body of `def <name>() -> T.Schema: ...` in spec/fulu_schemas.bend."""
    txt = (ROOT / 'spec/fulu_schemas.bend').read_text()
    m = re.search(rf'^def {name}\(\) -> T\.Schema: (.*)$', txt, re.M)
    return m.group(1).strip()


def _espec(E):
    """(element schema, [field schemas]) of the container E, in this module's names (Spec., S.)."""
    sn = re.fullmatch(r'(Schema\d+)\(\)', _spec_def(E)).group(1)
    body = _spec_def(sn)
    fx = lambda t: re.sub(r'(?<![\w.])(Schema\d+)\(\)', r'Spec.\1()', t).replace('T.', 'S.')
    ch = body[body.index('], ') + 3:-1]
    from codegen.proofs.var import var_winb
    fl = []
    while ch.startswith('T.Chain{'):
        a, b = var_winb.split_top(ch[len('T.Chain{'):-1])
        fl.append(fx(a.strip()))
        ch = b.strip()
    return f'Spec.{sn}()', fl


_ETOT = TPL.text('_ETOT')


def _em_text(M, E, RS):
    """The element on its box (MB): model, bytes, perfect, length, and its boxed write; its value and parts."""
    X0 = 'Nat.add(A.quad(q), r)'
    ty = f'Array<U32> & T.{E}'
    ES = _espec(E)[0]
    return TPL.render('_em_text', E=E, ES=ES, M=M, RS=RS, X0=X0, ty=ty)

def belem_text(VLW, EN, g, names, E):
    fields, RS = _brec_fields(g, names, E)
    M = f'M_{E}'
    X0 = 'Nat.add(A.quad(q), r)'
    n = len(fields)
    av = [f'a{k}' for k in range(n)]
    pat = f'{M}{{' + ', '.join('+' + x for x in av) + '}'
    L = []
    w = L.append
    done = set()
    for f, rt, c in fields:
        if rt.name not in done:
            done.add(rt.name)
            nd = VLW.SL.walk(g, rt, iter(range(100000)))
            w(obj_text(VLW, EN, g, rt, (nd.val, nd.sch, nd.proof, nd.obj)))
    R = [rt.name for _, rt, _ in fields]
    C = [c for _, _, c in fields]
    S = [rt.fixed_size() for _, rt, _ in fields]
    Y = [f'F.limbs(RWD_{R[k]}(a{k}))' for k in range(n)]
    qk = [f'Nat.add({C[k] // 4}n, q)' for k in range(n)]

    def model(k):
        D = 'D' if k == 0 else model(k - 1)
        return f'PXo_{R[k]}(a{k}, dd, {D}, {qk[k]}, r)' if k >= 0 else 'D'

    def cat(k):
        return Y[k] if k == n - 1 else f'VRX.AP({Y[k]}, {cat(k + 1)})'

    def lenp(k):
        """LN(cat(k)) == sum of S[k:]"""
        tot = sum(S[k:])
        if k == n - 1:
            return f'lenb_{R[k]}(a{k})'
        rest = sum(S[k + 1:])
        return (TPL.render('lenp', R=R, S=S, Y=Y, cat=cat, k=k, lenp=lenp, rest=rest, tot=tot))

    def pfs(k):
        if k < 0:
            return 'pf'
        D = 'D' if k == 0 else model(k - 1)
        return f'pfo_{R[k]}(a{k}, dd, {D}, {qk[k]}, r, {pfs(k - 1)})'
    w(TPL.render('belem_text', E=E, M=M, RS=RS, X0=X0, cat=cat, lenp=lenp, model=model, n=n, pat=pat, pfs=pfs))
    # putxE
    ls = []
    a = ls.append
    Dk = lambda k: 'D' if k == 0 else model(k - 1)
    Xk = lambda k: f'Nat.add(A.quad({qk[k]}), r)'
    for k in range(n):
        rem = RS - C[k] - S[k]
        Zk = 'hz' if k == 0 else f'Z{k}'
        for line in TPL.render('belem_text_lines', C=C, Dk=Dk, RS=RS, S=S, Xk=Xk, Zk=Zk, k=k, rem=rem).split('\n'):
            a(line)
        pfk = 'pf' if k == 0 else f'pf{k}'
        for line in TPL.render('belem_text_lines_2', C=C, Dk=Dk, R=R, S=S, k=k, pfk=pfk, qk=qk).split('\n'):
            a(line)
        if k < n - 1:
            a(f'+eX{k} = UW.pos_eq({S[k] // 4}n, {qk[k]}, r)')
            a(f'+Z{k + 1} = VRX.znext(UA.BYT({Dk(k)}), {Xk(k)}, {Y[k]}, {Xk(k + 1)}, {S[k]}n, {rem}n, UA.BYT({model(k)}), hX{k}, lenb_{R[k]}(a{k}), eX{k}, by{k}, {Zk})')
    # bytes, from the last field back
    a(f'+S{n - 1} = by{n - 1}')
    for k in range(n - 2, -1, -1):
        a(f'+eXn{k} = Equal.trans(Nat, {Xk(k + 1)}, Nat.add({Xk(k)}, {S[k]}n), Nat.add({Xk(k)}, VRX.LN({Y[k]})), eX{k}, '
          f'Equal.cong(Nat, Nat, z => Nat.add({Xk(k)}, z), {S[k]}n, VRX.LN({Y[k]}), Equal.sym(Nat, VRX.LN({Y[k]}), {S[k]}n, lenb_{R[k]}(a{k}))))')
        a(f'+S{k} = Equal.trans(+List<U32>, UA.BYT({model(n - 1)}), UW.SPL(UA.BYT({model(k)}), {Xk(k + 1)}, {cat(k + 1)}), UW.SPL(UA.BYT({Dk(k)}), {Xk(k)}, {cat(k)}), S{k + 1}, '
          f'VRX.spl_catx(UA.BYT({Dk(k)}), {Xk(k)}, {Y[k]}, {cat(k + 1)}, {Xk(k + 1)}, UA.BYT({model(k)}), hX{k}, eXn{k}, by{k}))')
    # the runtime chain
    objs = [f'O.BSome{{a{k}, O.BNone{{}}}}' for k in range(n)]
    ty = f'Array<U32> & T.{E}'
    cur = ['0']
    for k in range(n):
        cur.append(f'({cur[k]} .|. O.pz(T.{R[k]}_valid(a{k})) : U32)')
    steps = []
    for k in range(n):
        held = [objs[i] for i in range(n) if i != k]
        ctx = f'T.{E}_put_drop(T.{E}_pw{k}(X, {cur[k]}, {", ".join(held)}, (z, ({objs[k]}, O.pz(T.{R[k]}_valid(a{k}))))))'
        lhs = f'T.{R[k]}_put(FD.array__thaw(U32, {Dk(k)}), U32.add(X, {C[k]}), a{k})'
        rhs = f'FD.array__thaw(U32, {model(k)})'
        steps.append((ctx, lhs, rhs))
    start = f'T.{E}_put(FD.array__thaw(U32, D), X, th_{E}({M}{{{", ".join(av)}}}))'
    end = f'(FD.array__thaw(U32, {model(n - 1)}), th_{E}({M}{{{", ".join(av)}}}))'

    def chain(j, first):
        ctx, lhs, rhs = steps[j]
        e = f'Equal.cong(Array<U32>, {ty}, z => {ctx}, {lhs}, {rhs}, rt{j})'
        if j == n - 1:
            return e
        after = ctx.replace('(z, (', f'({rhs}, (', 1)
        nxt_lhs = steps[j + 1][0].replace('(z, (', f'({steps[j + 1][1]}, (', 1)
        return f'Equal.trans({ty}, {first}, {after}, {end}, {e}, {chain(j + 1, nxt_lhs)})'
    body = '\n      '.join(ls)
    w(TPL.render('belem_text_putxE', M=M, RS=RS, X0=X0, av=av, body=body, chain=chain, pat=pat, start=start))
    # its value and parts: a container of fixed records (spec_fixed's aggregate_fixed over their words)
    ES, FS = _espec(E)
    assert len(FS) == n, (E, FS)
    V = [f'RVW_{R[k]}(a{k})' for k in range(n)]
    WS = [f'RWD_{R[k]}(a{k})' for k in range(n)]
    wss = '[' + ', '.join(WS) + ']'

    def items(k):
        return 'S.EmptyItems{}' if k == n else f'S.Items{{{V[k]}, {items(k + 1)}}}'

    def chn(k):
        return 'S.End{}' if k == n else f'S.Chain{{{FS[k]}, {chn(k + 1)}}}'

    def rest(k):
        return '[' + ', '.join(f'S.Fixed{{{Y[j]}}}' for j in range(k, n)) + ']'

    def cf(k):
        if k == n:
            return '{==}'
        return (f'F.cat_fixed(Codec.parts({V[k]}, {FS[k]}), {Y[k]}, Codec.parts({items(k + 1)}, {chn(k + 1)}), {rest(k + 1)}, '
                f'rparts_{R[k]}(a{k}), {cf(k + 1)})')
    # F.flat(wss) == cat(0): the last piece's trailing []
    last = f'List.append(&2, U32, {Y[n - 1]}, [])'
    ctx = 'z'
    for k in range(n - 2, -1, -1):
        ctx = f'List.append(&2, U32, {Y[k]}, {ctx})'
    ef = f'Equal.cong(+List<U32>, +List<U32>, z => {ctx}, {last}, {Y[n - 1]}, VS.app_nil({Y[n - 1]}))' if n > 1 else f'VS.app_nil({Y[0]})'
    c0 = cat(0)
    w(_ETOT)
    w(TPL.render('belem_text_EV', E=E, ES=ES, M=M, RS=RS, c0=c0, cf=cf, chn=chn, ef=ef, items=items, lenp=lenp, pat=pat, wss=wss))
    w(_em_text(M, E, RS))
    return '\n'.join(L), RS



def belem_deposit_text(VLW, EN, g, names):
    """Deposit on its mirror M_Deposit{WMr{t, n}, DepositData}: the 33-word proof by vuwd.putw_any
    (its validity O.words_ok(1056, 1056, 32)), then the boxed DepositData through encx_recs; the bytes
    over vcont's pieces [1056 | 184] (the proof's trailing zeros fall on the DepositData piece)."""
    E, M = 'Deposit', 'M_Deposit'
    rt = names['DepositData']
    nd = VLW.SL.walk(g, rt, iter(range(100000)))
    L = [obj_text(VLW, EN, g, rt, (nd.val, nd.sch, nd.proof, nd.obj))]
    X0 = 'Nat.add(A.quad(q), r)'
    WOB = 'O.Words{FD.array__thaw(U32, t), 1056}'
    Y1 = 'VS.bt(1056n, F.limbs(UW.SLW(t)))'
    Y2 = 'F.limbs(RWD_DepositData(a1))'
    OBJ = f'T.Deposit{{{WOB}, O.BSome{{a1, O.BNone{{}}}}}}'
    D1 = 'WD.PWM(r, dd, D, q, t, 1056)'
    D2 = f'PXo_DepositData(a1, dd, {D1}, Nat.add(264n, q), r)'
    PT = 'WD.PADB(r, 1056n)'
    OKW = ('Bool.and(Nat.is_lt(TDW(t), 28n), Bool.and(FD.array__perfect(U32, TDW(t), t), Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056))))')
    L.append(TPL.render('belem_deposit_text', D1=D1, D2=D2, E=E, M=M, OBJ=OBJ, OKW=OKW, PT=PT, WOB=WOB, X0=X0, Y1=Y1, Y2=Y2))
    ES, FS = _espec(E)
    WSP = 'VS.wtake(264n, UW.SLW(t))'
    wss = f'[{WSP}, RWD_DepositData(a1)]'
    ITEMS = f'S.Items{{S.Sequence{{AV.ch8({WSP})}}, S.Items{{RVW_DepositData(a1), S.EmptyItems{{}}}}}}'
    CH = f'S.Chain{{{FS[0]}, S.Chain{{{FS[1]}, S.End{{}}}}}}'
    YEv = f'VCN.CAT([VCN.PC(1056n, {Y1}), VCN.PC(184n, {Y2})])'
    L.append(_ETOT)
    L.append(TPL.render('belem_deposit_text_EV', CH=CH, ES=ES, FS=FS, ITEMS=ITEMS, M=M, WSP=WSP, Y1=Y1, Y2=Y2, YEv=YEv, wss=wss))
    L.append(_em_text(M, E, 1240))
    return '\n'.join(L), 1240


def blist_box_text(g, names, parent, field):
    from codegen.proofs.var import var_rlist as VRG  # noqa: F401  kept: the import may register hooks at import time
    from codegen.proofs.var import var_rlist_enc as EN
    from codegen.proofs.var import var_vlist_enc as VV
    ft = dict(names[parent].fields)[field]
    s = g.shape(ft)
    p = s.p
    E = ft.elem.name
    LIM = ft.size
    etext, RS = belem_deposit_text(VL, EN, g, names) if E == 'Deposit' else belem_text(VL, EN, g, names, E)
    bl = VV.blocks(_unlit((ROOT / 'proofs/obj/root_types.bend').read_text()))
    COPYB = (['WMr', 'th_w'] if E == 'Deposit' else []) + ['MB', f'M_{E}', f'th_{E}', f'th_{E}_bx', f'am_{p}', f'amsize_{p}', f'amswap_go_{p}', f'amswap_{p}', f'amset_{p}', f'amswap_back_{p}',
             f'xat_{p}', f'nth_{p}']
    cp = [re.sub(r'\bF\.', 'FD.', bl[c]) for c in COPYB]
    tmpl = (ROOT / 'codegen/templates/vrlb_list.bend.in').read_text()
    ES = _espec(E)[0]
    LS = re.search(rf'^def (Schema\d+)\(\) -> T\.Schema: T\.ListOf\{{{re.escape(ES[5:])}, {LIM}n\}}$', (ROOT / 'spec/fulu_schemas.bend').read_text(), re.M).group(1)
    body = (tmpl.replace('@P', p).replace('@ESCH', ES).replace('@LSCH', f'Spec.{LS}()').replace('@E', E).replace('@M', f'M_{E}').replace('@RSn', f'{RS}n').replace('@RS', str(RS))
            .replace('@Wn', f'{RS // 4}n').replace('@LIMn', f'{LIM}n').replace('@LIM', str(LIM)))
    assert '@' not in body.replace('&2', ''), [ln for ln in body.split('\n') if '@' in ln.replace('&2', '')][:3]
    # the list's interface under the record lists' names (<name>_<p>, var_cont_enc's list child)
    for nm in ['THL', 'OKL', 'ENCL', 'LL', 'PUTLb', 'PUTL', 'RTL', 'BYL', 'PFL', 'putx', 'sizex', 'szx', 'pfLb', 'VALL', 'encx_spec', 'len_encl']:
        body = re.sub(rf'(?<![\w.]){nm}\(', f'{nm}_{p}(', body)
    body = re.sub(r'(?<![\w.])valid_l\(', f'valid_{p}(', body)
    L = LHEAD + ['import ./vcont.bend as VCN', 'import ./amap.bend as AM', 'import ./mtree_defs.bend as MD', 'import ./vbenc.bend as VBE', 'import ./vlist.bend as VL', 'import ./vcopy.bend as VC',
                 'import ./vconts.bend as CS', 'import ./arr_vec.bend as AV', '', '# GENERATED by var_rec_enc (codegen). Do not edit.',
                 f'# {p}: a list of boxed {E} (fixed size, {RS} bytes) in the encoder-window interface (see the generator).', '', COMMON,
                 '# ---- mirrors of the boxed elements (copied from proofs/obj/root_types.bend) ----'] + cp
    return p, '\n'.join(L) + '\n' + etext + '\n' + body


# ---- the dd < 31 twins' strict bounds (deep.dify_out's post pass) ----------------------------------------------
BMULW = TPL.text('BMULW')


def rec_strict(q, t, res):
    from codegen.proofs.support import deep
    P32 = 'FD.spec_common__pow2(32n)'

    def L_of(blk):
        ty = deep.param_type(blk, deep.twin_name(blk), 'hl32')
        return deep.hl32_parts(ty) if ty else None
    # records of W >= 1 words (a literal W): rposW's hW
    t = deep.edit_calls(t, 'VRX.rposW', lambda a, blk: a[:14] + ['{==}'] + a[14:])
    # records of R >= 1 bytes, pieces of m >= 1 bytes (literals): posbW's hR, pposW / proomW's hm
    t = deep.edit_calls(t, 'VRB.posbW', lambda a, blk: a[:11] + ['{==}'] + a[11:])
    for n in ('VP.pposW', 'VP.proomW', 'VPC.pposW', 'VPC.proomW'):
        t = deep.edit_calls(t, n, lambda a, blk: a[:12] + ['{==}'] + a[12:])
    if 'def sroom(' in t:   # sroom32: sroom's region below 2^32 (VCN.croom32)
        a0 = t.index('def sroom(')
        b0 = t.index('\n\n', a0) + 2
        blk = t[a0:b0]
        hl_ty = deep.param_type(blk, 'sroom', 'hl')
        ret = re.search(r'-> (\{.*\}):\n', blk).group(1)
        s32 = blk.replace('def sroom(', 'def sroom32(', 1).replace('+hl: ' + hl_ty, '+hl32: ' + deep.hl32_decl('FD')(hl_ty), 1)
        s32 = s32.replace('-> ' + ret, '-> ' + deep.hl32_decl('FD')(ret), 1).replace('VCN.croom(', 'VCN.croom32(').replace(', ep, h2, hl)', ', ep, h2, hl32)')
        t = t[:b0] + s32 + t[b0:]
    # hl32 (the region's last byte a U32 position) beside every hl
    t, bad = deep.hl32_pass(derive={'proomW': 'proom32', 'sroom': 'sroom32'})(q, t, res)
    # the list's byte count N RS: below 2^32 by hl32
    # (a subst by {==} to mulqW's own form 4 (j W): no closed 2^32 is ever compared up to evaluation)
    def mq(a, blk):
        q_, r_, L_ = L_of(blk)
        return a[1:7] + [f'FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == True{{}} : Bool}}, {L_}, A.quad(Nat.mul({a[2]}, {a[4]})), {{==}}, VRX.yl32({q_}, {r_}, {L_}, hl32))']
    t = deep.edit_calls(t, 'VRX.mulqW', mq)
    if 'def bmulW(' in t:
        a0 = t.index('def bmulW(')
        b0 = t.index('\ndef ', a0) + 1
        t = t[:a0] + BMULW + t[b0:]
        t = deep.restore_old(t, 'bmul')

        def bm(a, blk):
            q_, r_, L_ = L_of(blk)
            hm = a[8]
            if hm == 'hm':   # spos: j S <= LT (h1)
                lt = f'FD.nat__le_lt_trans({a[2]} if False else Nat.mul({a[2]}, {a[4]}), {L_}, {P32}, h1, VRX.yl32({q_}, {r_}, {L_}, hl32))'
                lt = f'FD.nat__le_lt_trans(Nat.mul({a[2]}, {a[4]}), {L_}, {P32}, h1, VRX.yl32({q_}, {r_}, {L_}, hl32))'
            else:            # szx: N S is the region's whole length
                lt = f'FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == True{{}} : Bool}}, {L_}, Nat.mul({a[2]}, {a[4]}), {{==}}, VRX.yl32({q_}, {r_}, {L_}, hl32))'
            return a[1:7] + [lt]
        t = deep.edit_calls(t, 'bmulW', bm)
    # the OKW containers' B twins of the lists' spec and size (codegen/proofs/support/okw.py)
    from codegen.proofs.support import okw
    t = okw.list_btwins(t)
    return t, bad


def main():
    # accepts '--check' (var_finish.finish reads it)
    VL.SL.EXACT = True   # spec_laws' exact spec-parts proofs (F.items_fixed / container_fixed): no parts run to compare forms
    VL.SL.TOTAL = True   # their layout by vspec.agg_total, not {==}
    out = {OUT: module_text()}
    g, names = layout()
    for parent, field in LISTS:
        p, t = list_module(g, names, parent, field)
        out[lfile(p)] = t
    for parent, field in BLISTS_BOX:
        p, t = blist_box_text(g, names, parent, field)
        out[lfile(p)] = t
    for p, X, LIM in BLISTS:
        out[bl_file(p)] = bl_text(p, X, LIM)
    for p, R, LIM in SUBLISTS:
        out[sub_file(p)] = sub_text(p, R, LIM)
    for p, R, NV in RVECS:
        out[sub_file(p)] = vec_text(p, R, NV)
    for p in FLISTS:
        out[bl_file(p)] = flist_text(p)
    for n in URECS:
        out[urec_file(n)] = urec_text(n)
    out[lfile(VLIST)] = vlist_module()
    return finish(out, 'stale generated record encoder windows: ', 'generated record encoder windows are current',
                  dify=dict(handled={'rposW', 'mulqW', 'posbW', 'pposW', 'proomW', 'fposW', 'vposW'}, post=rec_strict))


if __name__ == '__main__':
    main()
