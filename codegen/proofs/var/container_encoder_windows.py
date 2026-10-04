#!/usr/bin/env python3
"""Encoder windows of variable-size CONTAINERS at any byte position X = 4 q + r.

    python3 codegen/proofs/var/container_encoder_windows.py [--check]

For each container C of CONTS, proofs/obj/encx_<C>.bend (generated):

  the object OBJ, built from its fields' objects (Data leaves) and its children's mirrors
  (the encoder windows' own: encx_bl32's MW, the transactions list's (t, N), a record
  list's (A, N), a fixed byte vector's tree);
  M<k>                    the output tree after the k-th write of the runtime's put chain
                          (codegen/impl/typed_object_runtime.py's emit_fieldset / emit_wide order: per group,
                          its checked writers `putk` and variable fields `putv` (offset word,
                          then the child), then its Data fields, innermost first);
  rt_<g>, rt_C            the runtime's chain, from each write's fact (cong steps);
  putx                    DK.P2( T.C_putn(thaw D, X, OBJ) == (thaw PUTC, (OBJ, SZC)),
                                 DK.P2( BYT(PUTC) == SPL(BYT D, 4 q + r, AP(ENCC, ZB(PADB(r, L)))),
                                        PUTC perfect ) )
                          when the L + PADB(r, L) bytes at X are zero, the L bytes fit the tree,
                          and the children's objects are valid.

The bytes follow the container's region as a list of pieces (proofs/obj/vcont.bend): its fixed
fields and offsets in byte order, its variable fields, the trailing zeros; each write turns one
zero piece into its bytes (reg_put / reg_putc), and each writer's zero window comes from the
pieces not yet written (reg_zero). Positions: vrecx.fpos/froom for the fixed part, vcont.vpos /
croom / padfit / cnext for the variable part (the running cursor).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import pathlib
from codegen.proofs.support import deep_window_decode_passes as _deep  # noqa: E402
import sys
from pathlib import Path

from codegen.core.repository_paths import ROOT  # noqa: E402

from codegen.impl import typed_object_runtime as G  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('container_encoder_windows', globals())

CONTS = ['ExecutionPayload', 'ExecutionPayloadHeader', 'ExecutionRequests', 'Attestation', 'IndexedAttestation', 'AttesterSlashing',
         'LightClientHeader', 'BeaconBlockBody', 'LightClientFinalityUpdate', 'LightClientUpdate', 'BeaconBlock', 'SignedBeaconBlock', 'BeaconState']
TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'
GROUP = G.GROUP


def out_file(C):
    return ROOT / f'proofs/obj/encx_{C}.bend'


# ---- leaves -----------------------------------------------------------------------------------------

class Leaf:
    """A Data leaf written at any X by its dispatch lemma (vuwd, vuwv_<p>)."""

    def __init__(self, p, ctor, W, mod, model, rt, by, pf, rt_hz, rec=None, sub=0, pad=False, bits=0, tail=False):
        self.p, self.ctor, self.W, self.mod = p, ctor, W, mod
        self.tail = tail  # W words and then one byte (Bitvector[257]: vbv257, data-only; its check T.<p>_valid a hypothesis)
        self.bits = bits  # a one-byte bit vector (Bitvector[1/2/8]): a byte leaf on its word (vbitb), valid below 2^bits
        self.pad = pad    # a one-byte leaf in the zero-padded form (vuwv_bv4): its bytes and the zeros to its word's end
        self.sub = sub    # a sub-word leaf (uint8 / uint16: its byte count), a piece at any byte (vpiece)
        self.model, self.rt, self.by, self.pf, self.rt_hz = model, rt, by, pf, rt_hz
        self.rec = rec    # a fixed record of codegen/proofs/var/fixed_record_encoder_windows.py's RECS: its field tree (single_list_container_codec_laws.FT)


# The modules this generator writes, as this run computes them (read before the disk copy, so one
# run reaches its fixed point: an interface's maxx / sizex reads its children's interfaces).
GEN = {}


def obj_text(path):
    """A proofs/obj module's text: this run's, else the disk's (None when neither)."""
    path = Path(path)
    if path in GEN:
        return GEN[path]
    return path.read_text() if path.exists() else None


# the fixed records written by codegen/proofs/var/fixed_record_encoder_windows.py (proofs/obj/encx_recs.bend), by name: their field trees
_RECFT = None


def rec_ft(n):
    global _RECFT
    if _RECFT is None:
        from codegen.proofs.var import fixed_record_encoder_windows as VRE
        g, names = VRE.layout()
        _RECFT = {m: ft for m, ft in VRE.order(g, names, VRE.RECS)}
    return _RECFT.get(n)


# the packed byte vectors of fixed size written like the fixwords (codegen/proofs/var/word_vector_writer_laws.py's FWORDS: vuwv_<p>)
FIXW_PACKED = ('v4_b32', 'v6_b32', 'v7_b32', 'v8192_b32', 'v65536_b32', 'v8192_u64', 'v64_u64')


def is_fixw(fs):
    return fs.fixed and (fs.kind == 'fixwords' or (fs.kind == 'packed' and fs.p in FIXW_PACKED))


# ---- FixW: the fixed non-Data fields written by a checked writer T.<p>_putk returning size 0 ----------------
# (the fixwords / packed word vectors, SyncCommittee, a boxed fixed record); the rt_* put step and putx_text's
# fixw branch read these fields.

class FixW:
    def __init__(self, f, fs):
        self.packed = False
        self.f, self.fs, self.p = f, fs, fs.p
        self.text = ''
        if fs.kind == 'container' and fs.p == 'SyncCommittee':
            self._sync_committee(f, fs)
        elif fs.kind == 'fixwords' and fs.p == 'bv1281':
            self._bitvector1281(f, fs)
        elif fs.p in rvec_names():
            self._record_vector(f, fs)
        elif fs.kind == 'box' and rec_ft(fs.p[:-3]) is not None:
            self._boxed_record(f, fs)
        else:
            self._word_vector(f, fs)
        self.rtype = f'Array<U32> & ({self.vt} & U32)'

    def _sync_committee(self, f, fs):
        ws = [f'{f}_a{j}' for j in range(12)]
        A_ = ', '.join(ws)
        a = 'V_SyncCommittee'
        self.mod = f'import ./vuwv_SyncCommittee.bend as {a}'
        self.params = [f'+dB_{f}: Nat', f'+TB_{f}: {TR}'] + [f'+{w}: U32' for w in ws]
        self.oargs = [f'dB_{f}', f'TB_{f}'] + ws
        self.hyps = [f'+pfB_{f}: {{FD.array__perfect(U32, dB_{f}, TB_{f}) == {TRUE}}}', f'+hdB_{f}: {{Nat.is_lt(dB_{f}, 31n) == {TRUE}}}',
                     f'+hrB_{f}: {{Nat.is_le(6144n, VB.pw(dB_{f})) == {TRUE}}}']
        self.hargs = [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}']
        self.obj = f'T.SyncCommittee{{O.Words{{FD.array__thaw(U32, TB_{f}), 24576}}, T.Bytes48{{{A_}}}}}'
        self.vt = 'T.SyncCommittee'
        self.model = lambda r, D, q: f'{a}.PX_SyncCommittee({r}, dd, {D}, {q}, TB_{f}, {A_})'
        self.pf = lambda r, D, q, pf: f'{a}.SyncCommitteex_perfect({r}, dd, {D}, {q}, TB_{f}, {A_}, {pf})'
        args = lambda D, X, q, r, e, hr, hl, pf, hz: f'dd, {D}, {X}, {q}, {r}, dB_{f}, TB_{f}, {A_}, {e}, {hr}, hd, {hl}, {pf}, pfB_{f}, hdB_{f}, hrB_{f}, {hz}'  # noqa: E731
        self.rt = lambda *x: f'{a}.SyncCommittee_any({args(*x)})'
        self.by = lambda *x: f'{a}.SyncCommittee_any_bytes({args(*x)})'
        self.Y = f'List.append(&2, U32, VS.bt(U32.to_nat(24576), FX.limbs(UW.SLW(TB_{f}))), FX.limbs([{A_}]))'
        self.hY = f'{a}.SyncCommittee_len(dB_{f}, TB_{f}, {A_}, pfB_{f}, hrB_{f})'

    def _bitvector1281(self, f, fs):
        # Bitvector[1281] (161 bytes held as O.Words), data-only (vbv1281d over vputwd): only its bytes zero,
        # room for one more word after them (room_extra)
        a = 'V_bv1281'
        self.mod = 'import ./vbv1281d.bend as V_bv1281'
        self.params = [f'+dB_{f}: Nat', f'+TB_{f}: {TR}']
        self.oargs = [f'dB_{f}', f'TB_{f}']
        self.hyps = [f'+pfB_{f}: {{FD.array__perfect(U32, dB_{f}, TB_{f}) == {TRUE}}}', f'+hdB_{f}: {{Nat.is_lt(dB_{f}, 28n) == {TRUE}}}',
                     f'+hrB_{f}: {{Nat.is_le(161n, A.quad(VB.pw(dB_{f}))) == {TRUE}}}', f'+htz_{f}: {{{a}.HTZ(TB_{f}) == {TRUE}}}',
                     f'+hbz_{f}: {{{a}.HBZ(dB_{f}, TB_{f}) == {TRUE}}}']
        self.hargs = [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}', f'htz_{f}', f'hbz_{f}']
        self.obj = f'O.Words{{FD.array__thaw(U32, TB_{f}), 161}}'
        self.vt = 'O.Words'
        self.model = lambda r, D, q: f'{a}.PXD({r}, dd, {D}, {q}, TB_{f})'
        self.pf = lambda r, D, q, pf: f'{a}.pxd_perfect({r}, dd, {D}, {q}, TB_{f}, {pf})'
        self.rt = lambda D, X, q, r, e, hr, hl, pf, hz: (f'{a}.bv1281d_any(dd, {D}, {X}, {q}, {r}, dB_{f}, TB_{f}, {e}, {hr}, hd, {hl}, {pf}, pfB_{f}, hdB_{f}, hrB_{f}, '
                                                         f'htz_{f}, hbz_{f}, {hz})')
        self.by = lambda D, X, q, r, e, hr, hl, pf, hz: (f'{a}.bv1281d_any_bytes(dd, {D}, {X}, {q}, {r}, dB_{f}, TB_{f}, {e}, {hr}, hd, {hl}, {pf}, pfB_{f}, hdB_{f}, hrB_{f}, '
                                                         f'htz_{f}, {hz})')
        self.Y = f'VS.bt(161n, FX.limbs(UW.SLW(TB_{f})))'
        self.hY = f'{a}.lenY(dB_{f}, TB_{f}, pfB_{f}, hrB_{f})'
        self.alias = a
        self.room_extra = 4

    def _record_vector(self, f, fs):
        # a vector of records (fixed_record_encoder_windows.RVECS): encx_<p>'s FixW-form laws fwrt / fwby / lenv / pfx / validx
        a = f'RV_{fs.p}'
        m = f'm_{f}'
        self.mod = f'import ./encx_{fs.p}.bend as {a}'
        self.params = [f'+{m}: {a}.MW']
        self.oargs = [m]
        self.hyps = [f'+hok_{f}: {{{a}.OK({m}) == {TRUE}}}']
        self.hargs = [f'hok_{f}']
        self.obj = f'{a}.TH({m})'
        self.vt = f'T.{fs.rep}'
        self.model = lambda r, D, q: f'{a}.PUTX({m}, dd, {D}, {q}, {r})'
        self.pf = lambda r, D, q, pf: f'{a}.pfx({m}, dd, {D}, {q}, {r}, {pf})'
        args = lambda D, X, q, r, e, hr, hl, pf, hz: f'{m}, dd, {D}, {X}, {q}, {r}, {e}, {hr}, hd, {hl}, {pf}, {hz}, hok_{f}'  # noqa: E731
        self.rt = lambda *x: f'{a}.fwrt({args(*x)})'
        self.by = lambda *x: f'{a}.fwby({args(*x)})'
        self.Y = f'{a}.ENC({m})'
        self.hY = f'{a}.lenv({m}, hok_{f})'
        self.alias = a

    def _boxed_record(self, f, fs):
        R = fs.p[:-3]
        ft = rec_ft(R)
        ws = [f'{f}_w{j}' for j in range(ft.W)]
        W = ', '.join(ws)
        v = ft.obj(ws)
        self.mod = 'import ./encx_recs.bend as ER'
        self.params = [f'+{w}: U32' for w in ws]
        self.oargs = ws
        self.hyps, self.hargs = [], []
        self.obj = f'O.BSome{{{v}, O.BNone{{}}}}'
        self.vt = f'O.Boxed<T.{R}>'
        self.model = lambda r, D, q: f'ER.PX_{R}({W}, dd, {D}, {q}, {r})'
        self.pf = lambda r, D, q, pf: f'ER.pf_{R}({W}, dd, {D}, {q}, {r}, {pf})'
        args = lambda D, X, q, r, e, hr, hl, pf, hz: f'{W}, dd, {D}, {X}, {q}, {r}, {e}, {hr}, hd, {hl}, {pf}, {hz}'  # noqa: E731
        self.rt = lambda *x: f'bxrt_{f}({args(*x)})'
        self.by = lambda *x: f'PB(ER.RT_{R}({W}, dd, {x[0]}, {x[1]}, {x[2]}, {x[3]}), ER.BY_{R}({W}, dd, {x[0]}, {x[2]}, {x[3]}), ER.putx_{R}({args(*x)}))'
        self.Y = f'FX.limbs([{W}])'
        self.hY = '{==}'
        X0 = 'Nat.add(A.quad(q), r)'
        TY = f'Array<U32> & ({self.vt} & U32)'
        self.text = f'''
# ---- {f}: the boxed {R}, its runtime writer T.{fs.p}_putk (encx_recs.putx_{R}; its check is True) ----
def bxrt_{f}({", ".join(self.params)}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {4 * ft.W}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({4 * ft.W}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({4 * ft.W}n) : +List<U32>}})
    -> {{T.{fs.p}_putk(FD.array__thaw(U32, D), X, {self.obj}) == (FD.array__thaw(U32, ER.PX_{R}({W}, dd, D, q, r)), ({self.obj}, 0)) : {TY}}}:
  +g = ER.putx_{R}({W}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
  +rt = PA(ER.RT_{R}({W}, dd, D, X, q, r), ER.BY_{R}({W}, dd, D, q, r), g)
  Equal.cong(Array<U32>, {TY}, z => (z, ({self.obj}, 0)), T.{R}_put(FD.array__thaw(U32, D), X, {v}), FD.array__thaw(U32, ER.PX_{R}({W}, dd, D, q, r)), rt)
'''

    def _word_vector(self, f, fs):
        nW = fs.fsize // 4
        a = f'V_{fs.p}'
        # the word vector's module: vuwv_<p>, or the generic containers' data-only vuwg_<p> (bv1280)
        m_ = 'vuwv' if (ROOT / f'proofs/obj/vuwv_{fs.p}.bend').exists() or not (ROOT / f'proofs/obj/vuwg_{fs.p}.bend').exists() else 'vuwg'
        self.mod = f'import ./{m_}_{fs.p}.bend as {a}'
        self.params = [f'+dB_{f}: Nat', f'+TB_{f}: {TR}']
        self.oargs = [f'dB_{f}', f'TB_{f}']
        # a packed vector module (vuwv_v8192_b32, ..: its statements name the sizes U32.to_nat(S) / VC.NW(S),
        # never a closed Nat literal; see word_vector_writer_laws.pwords_text)
        src_ = (ROOT / f'proofs/obj/{m_}_{fs.p}.bend')
        self.packed = src_.exists() and f'+hrB: {{Nat.is_le(VC.NW({fs.fsize}), VB.pw(dB))' in src_.read_text()
        self.S = fs.fsize
        NWt = f'VC.NW({fs.fsize})' if self.packed else f'{nW}n'
        self.hyps = [f'+pfB_{f}: {{FD.array__perfect(U32, dB_{f}, TB_{f}) == {TRUE}}}', f'+hdB_{f}: {{Nat.is_lt(dB_{f}, 31n) == {TRUE}}}',
                     f'+hrB_{f}: {{Nat.is_le({NWt}, VB.pw(dB_{f})) == {TRUE}}}']
        self.hargs = [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}']
        self.obj = f'O.Words{{FD.array__thaw(U32, TB_{f}), {fs.fsize}}}'
        self.vt = 'O.Words'
        self.model = lambda r, D, q: f'{a}.PX_{fs.p}({r}, dd, {D}, {q}, TB_{f})'
        self.pf = lambda r, D, q, pf: f'{a}.{fs.p}x_perfect({r}, dd, {D}, {q}, TB_{f}, {pf})'
        args = lambda D, X, q, r, e, hr, hl, pf, hz: f'dd, {D}, {X}, {q}, {r}, dB_{f}, TB_{f}, {e}, {hr}, hd, {hl}, {pf}, pfB_{f}, hdB_{f}, hrB_{f}, {hz}'  # noqa: E731
        self.rt = lambda *x: f'{a}.{fs.p}_any({args(*x)})'
        self.by = lambda *x: f'{a}.{fs.p}_any_bytes({args(*x)})'
        self.Y = f'FX.limbs(VS.wtake({NWt}, UW.SLW(TB_{f})))'
        h64 = (f'FD.logic__subst(Nat, zz => {{Nat.is_le({NWt}, zz) == {TRUE}}}, VB.pw(dB_{f}), List.length(&2, U32, UW.SLW(TB_{f})), '
               f'Equal.sym(Nat, List.length(&2, U32, UW.SLW(TB_{f})), VB.pw(dB_{f}), Equal.trans(Nat, List.length(&2, U32, UW.SLW(TB_{f})), '
               f'FD.spec_common__length(U32, UW.SLW(TB_{f})), VB.pw(dB_{f}), VMR.len_eq(UW.SLW(TB_{f})), FD.array__slots_length(U32, dB_{f}, TB_{f}, pfB_{f}))), hrB_{f})')
        self.hY = f'VCN.len_wt({NWt}, UW.SLW(TB_{f}), {h64})'
        if self.packed:
            # {LN(Y) == U32.to_nat(S)} (putx_text carries it to the region's size)
            self.hY = (f'Equal.trans(Nat, VCN.LN({self.Y}), A.quad({NWt}), U32.to_nat({fs.fsize}), {self.hY}, '
                       f'Equal.sym(Nat, U32.to_nat({fs.fsize}), A.quad({NWt}), {a}.{fs.p}_eK()))')

    # the field's storage check: valid(hargs) proves {T.<p>_valid(obj) == (obj, True)} from the field's hypotheses,
    # passed in the order of self.hargs (an entry without hypotheses ignores them)
    def valid(self, hargs=None):
        hargs = list(self.hargs if hargs is None else hargs)
        fs, f = self.fs, self.f
        if fs.kind == 'box':
            return '{==}'
        if fs.p in rvec_names():
            return f'{self.alias}.validx(m_{f}, {hargs[0]})'
        if fs.kind == 'fixwords' and fs.p == 'bv1281':
            return f'V_bv1281.valid_ok(dB_{f}, TB_{f}, {", ".join(hargs)})'
        if fs.kind == 'container' and fs.p == 'SyncCommittee':
            return f'V_SyncCommittee.SyncCommittee_valid_ok(dB_{f}, TB_{f}, {", ".join(self.oargs[2:])}, {", ".join(hargs)})'
        return f'V_{fs.p}.{fs.p}_valid_ok(dB_{f}, TB_{f}, {", ".join(hargs)})'


def rvec_names():
    """The record vectors of codegen/proofs/var/fixed_record_encoder_windows.py (RVECS), fixed fields in the FixW form."""
    from codegen.proofs.var import fixed_record_encoder_windows as VRE
    return [p for p, _, _ in VRE.RVECS]


def is_fixw_ext(fs):
    """is_fixw, and the fixed non-Data fields with a FixW entry: SyncCommittee, a boxed record of fixed_record_encoder_windows,
    a record vector of fixed_record_encoder_windows.RVECS."""
    return is_fixw(fs) or (fs.fixed and not fs.data and ((fs.kind == 'container' and fs.p == 'SyncCommittee')
                                                        or (fs.kind == 'box' and fs.p.endswith('_bx') and rec_ft(fs.p[:-3]) is not None)
                                                        or (fs.kind == 'seq' and fs.p in rvec_names())))



BIGPIECE = 4096   # a fixed piece this large: its region offsets are proved (ln_cat), never evaluated

# U32 mode (a fixed part of U32FIX bytes or more, BeaconState's 2.7M): the writer states no closed big Nat. A
# fixed field's position is U32.to_nat(c) (its word position QX/RX of X + c), the fixed size F is U32.to_nat(F),
# the region's lengths are summed into positions by vpos32 (U32 sums, their carries: closed U32 terms), bounds
# by vadd.lea; the big piece sizes stay variables SZ<v>, uSZ<v> relating them to U32.to_nat(v).
U32FIX = 1 << 20
U32M = False
U32PK = set()       # the big sizes of packed vectors (their eSZ<v> is stated at U32.to_nat(v))
ELNS = {}           # slot -> the sizes summed by elnS<slot>


def form_of(v):
    """A big size's term at its literal: U32.to_nat(v) for F and the packed vectors' sizes in U32 mode."""
    return f'U32.to_nat({v})' if (U32M and int(v) in U32PK) else f'{v}n'


def nat_u(szn):
    """A proof of {<szn> == U32.to_nat(v)} for the Nat literal szn = 'vn' (a big one by its size variable)."""
    v = int(szn[:-1])
    if v >= BIGPIECE:
        return f'uSZ{v}({szn}, eSZ{v})'
    return '{==}' if v < 1024 else f'FD.nat__eq_from_is_eq({szn}, U32.to_nat({v}), {{==}})'


def u_nat(v, szt):
    """A proof of {U32.to_nat(v) == szt}, szt the field's size term (U32.to_nat(v) or the literal vn)."""
    if szt == f'U32.to_nat({v})':
        return '{==}'
    return '{==}' if v < 1024 else f'FD.nat__eq_from_is_eq(U32.to_nat({v}), {szt}, {{==}})'


def ln_u_core(pc):
    """ln_u of a piece of the interface's cores (a big piece at its size variable SZ<v>, eSZ<v> in scope; K.uSZ<v>
    states it at U32.to_nat(v))."""
    m = re.fullmatch(r'VCN\.PC\(SZ(\d+), (.*)\)', pc)
    if m:
        v = m.group(1)
        return int(v), f'P32.lnpc(SZ{v}, {m.group(2)}, {v}, K.uSZ{v}(SZ{v}, eSZ{v}))'
    v, p = ln_u(pc)
    return v, p.replace('uSZ', 'K.uSZ')


def ln_u(pc):
    """(v, proof of {VCN.LN(pc) == U32.to_nat(v)}) of a region piece."""
    m = re.fullmatch(r'UW\.ZB\((\d+)n\)', pc)
    if m:
        return int(m.group(1)), f'P32.lnzb({m.group(1)}n, {m.group(1)}, {nat_u(m.group(1) + "n")})'
    m = re.fullmatch(r'VCN\.PC\((\d+)n, (.*)\)', pc)
    if m:
        return int(m.group(1)), f'P32.lnpc({m.group(1)}n, {m.group(2)}, {m.group(1)}, {nat_u(m.group(1) + "n")})'
    if pc.startswith('I.limb('):
        return 4, '{==}'
    raise ValueError(f'ln_u: piece {pc[:60]}')


def eln_u(pcs):
    """(c, proof of {VCN.LN(VCN.CAT([pcs])) == U32.to_nat(c)}) by elnS<len(pcs)> (written by eln_defs)."""
    szs, prs = zip(*[ln_u(x) for x in pcs]) if pcs else ((), ())
    i = len(pcs)
    if i in ELNS:
        assert ELNS[i] == tuple(szs), (i, ELNS[i], szs)
    ELNS[i] = tuple(szs)
    return sum(szs), f'elnS{i}(' + ', '.join(list(pcs) + list(prs)) + ')'


def eln_defs():
    """elnS<i>: the length of i pieces of the fixed sizes ELNS[i], at the U32 sum (vpos32.lnc, U32 constants)."""
    out = []
    for i, szs in sorted(ELNS.items()):
        ps = [f'p{j}' for j in range(i)]
        suf = [0] * (i + 1)
        for j in reversed(range(i)):
            suf[j] = suf[j + 1] + szs[j]
        prf = 'P32.lnnil()'
        for j in reversed(range(i)):
            prf = f'P32.lnc({ps[j]}, [{", ".join(ps[j + 1:])}], {szs[j]}, {suf[j + 1]}, {suf[j]}, e{j}, {prf}, {{==}}, {{==}})'
        sig = ', '.join([f'+{x}: +List<U32>' for x in ps] + [f'+e{j}: {{VCN.LN({ps[j]}) == U32.to_nat({szs[j]}) : Nat}}' for j in range(i)])
        out.append(f'def elnS{i}({sig})\n    -> {{VCN.LN(VCN.CAT([{", ".join(ps)}])) == U32.to_nat({suf[0]}) : Nat}}:\n  {prf}\n')
    return '\n'.join(out)


def sum_u(szs):
    """A proof of {VCN.SUM([szs]) == U32.to_nat(total)} for Nat literals szs (vpos32.sumc)."""
    vals = [int(x[:-1]) for x in szs]
    suf = [0] * (len(vals) + 1)
    for j in reversed(range(len(vals))):
        suf[j] = suf[j + 1] + vals[j]
    prf = 'P32.sumnil()'
    for j in reversed(range(len(vals))):
        prf = f'P32.sumc({szs[j]}, [{", ".join(szs[j + 1:])}], {vals[j]}, {suf[j + 1]}, {suf[j]}, {nat_u(szs[j])}, {prf}, {{==}}, {{==}})'
    return prf


def piece_len(pc):
    """(length term, proof of {List.length(pc) == length}, size) of a region piece string."""
    m = re.fullmatch(r'VCN\.PC\((\d+)n, (.*)\)', pc)
    if m:
        return f'{m.group(1)}n', f'LNPC({m.group(1)}n, {m.group(2)})', int(m.group(1))
    m = re.fullmatch(r'UW\.ZB\((\d+)n\)', pc)
    if m:
        return f'{m.group(1)}n', f'UW.len_zb({m.group(1)}n)', int(m.group(1))
    if pc.startswith('I.limb('):
        return '4n', '{==}', 4
    m = re.fullmatch(r'VCN\.PC\((SZ(\d+)), (.*)\)', pc)
    if m:
        # a big piece at its size variable (bigify's cores)
        return m.group(1), f'LNPC({m.group(1)}, {m.group(3)})', int(m.group(2))
    return None, None, 0


def big_pieces(pcs):
    return any(piece_len(x)[2] >= BIGPIECE for x in pcs)


def big_fixed(pieces):
    """A container with a fixed piece of BIGPIECE bytes or more: its fixed size F is written last in every sum,
    Nat.add(SUM(..), F) (vcont's F0-last lemmas), so no comparison unfolds it."""
    return big_pieces([f'UW.ZB({sz})' for _, _, sz in pieces if sz.endswith('n') and sz[:-1].isdigit()])


def fadd(bigf, F, S):
    """F + S, F last when bigf."""
    return f'Nat.add({S}, {F})' if bigf else f'Nat.add({F}, {S})'


def ln_cat(pcs, target):
    """A proof of {VCN.LN(VCN.CAT([pcs])) == target} (target a closed Nat): each piece's length by its lemma
    (LNPC / UW.len_zb), stated on List.length (VCN.LN only at the end: a mismatch between the two forms would
    unfold the long pieces), their sum by Nat.is_eq."""
    LL = lambda x: f'List.length(&2, U32, {x})'  # noqa: E731

    def go(i):
        if i == len(pcs):
            return '0n', '{==}'
        rest = '[' + ', '.join(pcs[i + 1:]) + ']'
        lt, lp, _ = piece_len(pcs[i])
        st, sp = go(i + 1)
        L0 = LL(f'VCN.CAT([{", ".join(pcs[i:])}])')
        LR = LL(f'VCN.CAT({rest})')
        tot = f'Nat.add({lt}, {st})'
        prf = (f'Equal.trans(Nat, {L0}, Nat.add({LL(pcs[i])}, {LR}), {tot}, LNCC({pcs[i]}, {rest}), '
               f'Equal.trans(Nat, Nat.add({LL(pcs[i])}, {LR}), Nat.add({lt}, {LR}), {tot}, '
               f'Equal.cong(Nat, Nat, zz => Nat.add(zz, {LR}), {LL(pcs[i])}, {lt}, {lp}), '
               f'Equal.cong(Nat, Nat, zz => Nat.add({lt}, zz), {LR}, {st}, {sp})))')
        return tot, prf
    tot, prf = go(0)
    X = f'VCN.CAT([{", ".join(pcs)}])'
    return f'LNW({X}, {target}, Equal.trans(Nat, {LL(X)}, {tot}, {target}, {prf}, FD.nat__eq_from_is_eq({tot}, {target}, {{==}})))'


def qr_at(c, X='X'):
    """A fixed field's word position (q', r') at byte c of the container at X = 4 q + r: (c / 4 + q, r) when
    c is word-aligned, else (QX, RX) of U32.add(X, c) (vcont; placed through vpiece.ppos / proom)."""
    if c % 4 == 0 and not U32M:
        return f'Nat.add({c // 4}n, q)', 'r'
    return f'VCN.QX(U32.add({X}, {c}))', f'VCN.RX(U32.add({X}, {c}))'


# the one-byte bit vectors written as byte leaves (vbitb): their bit counts
BITB = {'bv1': 1, 'bv2': 2, 'bv8': 8}


def bits_obj(lf, f):
    """The object of a bit-vector byte leaf held as its word f."""
    return f'T.Bitvector{lf.bits}{{{f}}}'

def fixw_spec_field(g, names, fw, f, fs, sch):
    """The spec side of a FixW field for iface_text: its value, part, bytes (the writer's piece) and parts proof
    (proofs/obj/vfixw_spec.bend: the word vectors, SyncCommittee; a boxed record: its record's walk)."""
    from codegen.proofs.laws import spec_connected_codec_laws as SLW
    by = f'VCN.PC({fs.fsize}n, {fw.Y})'
    d = dict(kind='fix', f=f, sch=sch, part=f'S.Fixed{{{by}}}', bytes=by, psch=sch)
    if fs.kind == 'packed' and fs.p in FIXW_PACKED:
        k = int(fs.p.split('_')[0][1:])
        S_, W = fs.fsize, fs.fsize // 4
        if fw.packed and U32M:
            # the literal-free sizes (vfixw_u32 over the vuwv module's eK / eS)
            E = S_.bit_length() - 1
            a_, nm = ('WU.wv8u', 'FWS.VV8') if fs.p.endswith('_b32') else ('WU.wvu2u', 'FWS.VU2')
            by = f'VCN.PC({form_of(S_)}, {fw.Y})'
            prf = (f'{a_}({sch}, dB_{f}, TB_{f}, {k}n, {S_}, {E}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, V_{fs.p}.{fs.p}_eK(), V_{fs.p}.{fs.p}_eS(), '
                   f'{{==}}, OKA_pfB_{f}, OKA_hrB_{f})')
            if form_of(S_) != f'U32.to_nat({S_})':
                prf = (f'FD.logic__subst(Nat, zz => {{Codec.parts({nm}(VC.NW({S_}), TB_{f}), {sch}) == Some{{[S.Fixed{{VCN.PC(zz, {fw.Y})}}]}} : Maybe<&2, +List<S.Part>>}}, '
                       f'U32.to_nat({S_}), {S_}n, {{==}}, {prf})')
            d.update(part=f'S.Fixed{{{by}}}', bytes=by, val=f'{nm}(VC.NW({S_}), TB_{f})', prf=prf)
        elif fs.p.endswith('_b32'):
            d.update(val=f'FWS.VV8({W}n, TB_{f})',
                     prf=f'FWS.wv8({sch}, dB_{f}, TB_{f}, {k}n, {W}n, {S_}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, OKA_pfB_{f}, OKA_hrB_{f})')
        else:
            d.update(val=f'FWS.VU2({W}n, TB_{f})',
                     prf=f'FWS.wvu2({sch}, dB_{f}, TB_{f}, {k}n, {W}n, {S_}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, OKA_pfB_{f}, OKA_hrB_{f})')
    elif fs.kind == 'container' and fs.p == 'SyncCommittee':
        A_ = ', '.join(fw.oargs[2:])
        d.update(val=f'FWS.SCV(TB_{f}, {A_})',
                 prf=f'FWS.scp({sch}, {{==}}, dB_{f}, TB_{f}, {A_}, OKA_pfB_{f}, OKA_hrB_{f}, V_SyncCommittee.SyncCommittee_len(dB_{f}, TB_{f}, {A_}, OKA_pfB_{f}, OKA_hrB_{f}))')
    elif fs.kind == 'box':
        R = fs.p[:-3]
        nd = _xwalk(SLW, g, names[R])
        ren = {x: w for x, w in zip(nd.words, fw.oargs)}
        sub = lambda t: re.sub(r'\bx(\d+)\b', lambda mm: ren[mm.group(0)], t)  # noqa: E731
        fx = lambda t: re.sub(r'(?<![\w.])F\.', 'FX.', t)  # noqa: E731
        val = fx(sub(nd.val))
        d.update(val=val, psch=fx(nd.sch),
                 prf=f'CS.pcfix({val}, {fx(nd.sch)}, {fw.Y}, {fs.fsize}n, {{==}}, {fx(sub(nd.proof))})')
    else:
        raise SystemExit(f'no spec row for the FixW field {f}: {fs.kind}/{fs.p}')
    return d


def leaf_of(fs):
    if fs.kind in ('u8', 'u16'):
        m = 1 if fs.kind == 'u8' else 2
        return Leaf(fs.p, 'U32', 0, 'import ./vpiece.bend as VPC', f'VPC.P{8 * m}', f'VPC.u{8 * m}piece', None, f'VPC.p{8 * m}_perfect', False, sub=m)
    if fs.p in BITB:
        n = BITB[fs.p]
        return Leaf(fs.p, 'U32', 0, 'import ./vpiece.bend as VPC', 'VPC.P8', 'VPC.u8piece', None, 'VPC.p8_perfect', False, sub=1, bits=n)
    if fs.kind == 'u64':
        return Leaf('u64', 'O.U64', 2, None, 'WD.W64X', 'WD.w64_any', 'WD.w64_any_bytes', 'WD.w64x_perfect', False)
    if fs.p == 'b20':
        return Leaf('b20', 'T.Bytes20', 5, None, 'WD.B20X', 'WD.b20_any', 'WD.b20_any_bytes', 'WD.b20x_perfect', True)
    if fs.p in ('b32', 'u256', 'b48', 'b96', 'bv512', 'bv64'):
        a = f'V_{fs.p}'
        return Leaf(fs.p, f'T.{fs.rep}', fs.fsize // 4, f'import ./vuwv_{fs.p}.bend as {a}', f'{a}.PX_{fs.p}', f'{a}.{fs.p}_any',
                    f'{a}.{fs.p}_any_bytes', f'{a}.{fs.p}x_perfect', True)
    if fs.p == 'bv256':
        return Leaf('bv256', 'T.Bitvector256', 8, 'import ./vuwg_bv256.bend as V_bv256', 'V_bv256.PX_bv256', 'V_bv256.bv256_any',
                    'V_bv256.bv256_any_bytes', 'V_bv256.bv256x_perfect', True)
    if fs.p == 'bv257':
        return Leaf('bv257', 'T.Bitvector257', 8, 'import ./vbv257.bend as V_bv257', 'V_bv257.PXD', 'V_bv257.bv257d_any',
                    'V_bv257.bv257d_any_bytes', 'V_bv257.pxd_perfect', True, tail=True)
    if fs.p == 'bv4':
        PADCTOR['bv4'] = Leaf('bv4', 'T.Bitvector4', 1, 'import ./vuwv_bv4.bend as V_bv4', 'V_bv4.PX_bv4', 'V_bv4.bv4_any', 'V_bv4.bv4_any_bytes',
                              'V_bv4.bv4x_perfect', True, pad=True)
        return PADCTOR['bv4']
    if fs.kind == 'container' and rec_ft(fs.p) is not None:
        return Leaf(fs.p, f'T.{fs.p}', fs.fsize // 4, 'import ./encx_recs.bend as ER', f'ER.PX_{fs.p}', f'ER.putx_{fs.p}', None,
                    f'ER.pf_{fs.p}', True, rec=rec_ft(fs.p))
    raise SystemExit(f'no leaf writer for {fs.kind}/{fs.p}')


def rec_leaf_text(lf):
    """A fixed record's writer on the object: nested matches exposing its words, then encx_recs' lemmas."""
    from codegen.proofs.var import execution_requests_encoder_laws as EN
    p = lf.p
    words = []
    ls, ind = EN.nest(lf.rec, 'o', words, 2)
    body = '\n'.join(ls)
    pad = ' ' * ind
    WA = ', '.join(words)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * lf.W
    return TEMPLATES.render('rec_leaf_text', p=p, lf=lf, body=body, pad=pad, WA=WA, X0=X0, B=B)


def pad_leaf_text(lf):
    """Bitvector[4] (justification_bits): one byte, written in vuwv_bv4's zero-padded form (its byte and the
    zeros to its word's end, which the next field's still-zero bytes supply), valid when its word is below 256."""
    p = lf.p
    X0 = 'Nat.add(A.quad(q), r)'
    PD = 'WD.PADB(r, 1n)'
    return TEMPLATES.render('pad_leaf_text', p=p, lf=lf, X0=X0, PD=PD)


PADCTOR = {}   # p -> its Leaf, for the zero-padded leaves (filled by leaf_of)


def pad_spec_text(lf):
    """The zero-padded bv4 leaf's spec value and parts, for the interface module (the decoder's vfx_bv4)."""
    p, TRUE_ = lf.p, TRUE
    return TEMPLATES.render('pad_spec_text', p=p, lf=lf, TRUE_=TRUE_)


def leaf_bytes(lf, f):
    """A leaf's bytes, as a term of its object f."""
    return f'V_{lf.p}.BYW({f})' if lf.tail else f'FX.limbs(RW_{lf.p}({f}))'


def tail_leaf_text(lf):
    """W words and then one byte (Bitvector[257]): written data-only (vbv257), its check a hypothesis."""
    p, W = lf.p, lf.W
    ws = [f'w{i}' for i in range(W + 1)]
    pat = f'{lf.ctor}{{' + ', '.join('+' + w for w in ws) + '}'
    WA = ', '.join(ws)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * W + 1
    return TEMPLATES.render('tail_leaf_text', p=p, B=B, lf=lf, pat=pat, WA=WA, X0=X0, W=W)


def leaf_text(lf):
    if lf.pad:
        return pad_leaf_text(lf)
    if lf.tail:
        return tail_leaf_text(lf)
    if lf.rec is not None:
        return rec_leaf_text(lf)
    p, W = lf.p, lf.W
    ws = [f'w{i}' for i in range(W)]
    pat = f'{lf.ctor}{{' + ', '.join('+' + w for w in ws) + '}'
    WA = ', '.join(ws)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * W
    hz = ', hz' if lf.rt_hz else ''
    return TEMPLATES.render('leaf_text', p=p, lf=lf, pat=pat, WA=WA, X0=X0, B=B, hz=hz)


# ---- children (variable fields) -----------------------------------------------------------------------

class Child:
    """A variable field's encoder window, adapted: its mirror parameters and facts, object, bytes,
    byte count, writer model and laws, returned size."""

    def __init__(self, f, fs):
        self.f, self.fs, self.p = f, fs, fs.p
        if fs.kind == 'bytelist' and fs.p == 'bl32':
            self._mirror_window(f, 'EB', 'import ./encx_bl32.bend as EB', 'MW', f'EB.TH(m_{f})', 'O.Words')
        elif fs.kind == 'seq' and fs.p == 'l1048576_bl1073741824':
            t, N = f't_{f}', f'N_{f}'
            self.mod = 'import ./encx_l1048576_bl1073741824.bend as ET'
            self.params = [f'+{t}: FD.array__Tree<ET.MB<ET.WMr>>', f'+{N}: U32']
            self.hyps = [f'+h_{f}: {{ET.OKL({t}, {N}) == {TRUE}}}']
            self.oargs = [t, N]
            self.hargs = [f'h_{f}']
            self.obj = f'ET.THL({t}, {N})'
            self.vt = f'T.{fs.p}_Seq'
            self.enc = f'ET.ENCL({t}, {N})'
            self.len = f'ET.LL({t}, {N})'
            self.sz = f'ET.SZW({t}, {N})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'ET.PUTL({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            self.hY = f'ET.len_encl({t}, {N})'
        elif fs.kind == 'seq' and fs.p.startswith('l') and '_' in fs.p and fs.p not in STD_CHILDREN():
            A_, N = f'A_{f}', f'N_{f}'
            p = fs.p
            R = p.split('_', 1)[1]
            self.mod = f'import ./encx_{p}.bend as EW_{p}'
            a = f'EW_{p}'
            # a list of boxed records (fixed_record_encoder_windows's BLISTS_BOX) is held as a mirror tree of MB<M_R>
            boxed = f'def OKL_{p}(+t: FD.array__Tree<MB<M_{R}>>' in (ROOT / f'proofs/obj/encx_{p}.bend').read_text()
            self.params = [f'+{A_}: FD.array__Tree<{a}.MB<{a}.M_{R}>>' if boxed else f'+{A_}: FD.array__Tree<T.{R}>', f'+{N}: U32']
            self.hyps = [f'+h_{f}: {{{a}.OKL_{p}({A_}, {N}) == {TRUE}}}']
            self.oargs = [A_, N]
            self.hargs = [f'h_{f}']
            self.obj = f'{a}.THL_{p}({A_}, {N})'
            self.vt = f'T.{p}_Seq'
            self.enc = f'{a}.ENCL_{p}({A_}, {N})'
            self.len = f'{a}.LL_{p}({A_}, {N})'
            rs = re.search(r'O\.mulc\(n, (\d+)\)', fn_body(f'{p}_ptn_fin')).group(1)
            self.sz = f'O.mulc({N}, {rs})'
            self.pad = False
            self.model = lambda dd, D, X, q, r: f'{a}.PUTL_{p}({A_}, {N}, {dd}, {D}, {q}, {r})'
            self.hY = f'{a}.len_encl_{p}({A_}, {N})'
            self.alias = a
            # the Validator list (fixed_record_encoder_windows.vlist_text): records at any byte phase, its model and laws take X
            self.xform = p == 'l1099511627776_Validator'
            if self.xform:
                self.model = lambda dd, D, X, q, r: f'{a}.PUTL_{p}({A_}, {N}, {dd}, {D}, {X})'
        elif fs.p in STD_CHILDREN():
            # a child in progressive_small_list_codec_laws's encoder-window interface (codegen/proofs/var/encoder_window_children.py)
            c = STD_CHILDREN()[fs.p]
            a = f'EX_{fs.p}'
            self._mirror_window(f, a, f'import ./{c["file"]} as {a}', c['mirror'], f'{a}.TH(m_{f})', c['obj'])
            self.alias = a
            self.std = True
        elif fs.kind in ('container', 'box') and not fs.fixed and _has_iface(fs.p[:-3] if fs.kind == 'box' else fs.rep):
            # a variable-size container child (or one in a box) through its interface module encx_<C>_iface (codegen/proofs/var/container_encoder_windows.py)
            X = fs.p[:-3] if fs.kind == 'box' else fs.rep
            a = f'EC_{X}'
            boxed = fs.kind == 'box'
            self._mirror_window(f, a, f'import ./encx_{X}_iface.bend as {a}', 'MW',
                                f'O.BSome{{{a}.TH(m_{f}), O.BNone{{}}}}' if boxed else f'{a}.TH(m_{f})',
                                f'O.Boxed<T.{X}>' if boxed else f'T.{X}')
            self.alias = a
            self.std = True
            self.box = X if fs.kind == 'box' else None
            # a wide container's interface states no sizex / validx: its size module encx_<X>_size does (sizez, validx)
            fi = ROOT / 'proofs/obj' / f'encx_{X}_iface.bend'
            self.szalias = None
            ft_ = obj_text(fi)
            if ft_ is not None and '\nlaw sizex:' not in ft_:
                self.szalias = f'ES_{X}'
                self.mod += f'\nimport ./encx_{X}_size.bend as ES_{X}'
        else:
            raise FileNotFoundError(2, 'no child window', f'child {fs.kind}/{fs.p}')

    def _mirror_window(self, f, a, mod, mirror_t, obj, vt):
        """A child held as one mirror m_<f> of its encoder-window module `a` (bl32, the standard children, the container
        interfaces): the module's OK, TH, ENC, SZ and PUTX over that mirror."""
        m = f'm_{f}'
        self.mod = mod
        self.params = [f'+{m}: {a}.{mirror_t}']
        self.hyps = [f'+hok_{f}: {{{a}.OK({m}) == {TRUE}}}']
        self.oargs = [m]
        self.hargs = [f'hok_{f}']
        self.obj, self.vt = obj, vt
        self.enc = f'{a}.ENC({m})'
        self.len = f'List.length(&2, U32, {a}.ENC({m}))'
        self.sz = f'{a}.SZ({m})'
        self.pad = True
        self.model = lambda dd, D, X, q, r: f'{a}.PUTX({m}, {dd}, {D}, {q}, {r})'
        self.hY = '{==}'

    def putx(self, dd, D, X, q, r, e, hr, hd, hl, pf, hz):
        """(runtime fact, bytes fact, perfect fact) terms."""
        f, p = self.f, self.p
        if p == 'bl32':
            m = f'm_{f}'
            a = f'{m}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {pf}, {hl}, {hz}, hok_{f}'
            return f'EB.putx({a})', f'EB.putx_bytes({a})', f'EB.pfx({m}, {dd}, {D}, {q}, {r}, {pf})', None
        if getattr(self, 'std', False):
            m, al = f'm_{f}', self.alias
            a = f'{m}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {pf}, {hl}, {hz}, hok_{f}'
            rt = f'{al}.putx({a})'
            if getattr(self, 'box', None):
                B = self.box
                rt = (f'Equal.cong(Array<U32> & (T.{B} & U32), Array<U32> & (O.Boxed<T.{B}> & U32), z => T.{B}_bx_pk_back(z), '
                      f'T.{B}_putk(FD.array__thaw(U32, {D}), {X}, {al}.TH({m})), (FD.array__thaw(U32, {al}.PUTX({m}, {dd}, {D}, {q}, {r})), ({al}.TH({m}), {al}.SZ({m}))), {rt})')
            return rt, f'{al}.putx_bytes({a})', f'{al}.pfx({m}, {dd}, {D}, {q}, {r}, {pf})', None
        t, N = self.oargs
        if p == 'l1048576_bl1073741824':
            g = f'ET.putx({t}, {N}, h_{f}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {hl}, {pf}, {hz})'
            b = f'U32.is_eq({N}, 0)'
            RT = f'ET.RTL({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            BY = f'ET.BYLb({b}, {t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            PF = f'ET.PFLb({b}, {t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            return g, (RT, BY, PF), None, 'P3'
        a = self.alias
        g = f'{a}.putx_{p}({t}, {N}, h_{f}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {hl}, {pf}, {hz})'
        RT = f'{a}.RTL_{p}({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
        BY = f'{a}.BYL_{p}({t}, {N}, {dd}, {D}, {q}, {r})'
        PF = f'{a}.PFL_{p}({t}, {N}, {dd}, {D}, {q}, {r})'
        if getattr(self, 'xform', False):
            BY = f'{a}.BYL_{p}({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            PF = f'{a}.PFL_{p}({t}, {N}, {dd}, {D}, {X})'
        return g, (RT, BY, PF), None, 'P3'

    def szx(self, qc, rc, dd, hd, hlc):
        f, p = self.f, self.p
        if p == 'bl32':
            return f'EB.szx(m_{f}, hok_{f})'
        if getattr(self, 'std', False):
            return f'{self.alias}.szx(m_{f}, hok_{f})'
        t, N = self.oargs
        if p == 'l1048576_bl1073741824':
            hb = (f'FD.nat__le_trans(ET.LL({t}, {N}), A.quad(VB.pw({dd})), VB.pw(30n), VCN.pc_end({qc}, {rc}, ET.LL({t}, {N}), {dd}, ET.LL({t}, {N}), '
                  f'FD.nat__le_refl(ET.LL({t}, {N})), {hlc}), FD.nat__pow2_mono(2n+{dd}, 30n, FD.nat__lt_succ_le({dd}, 28n, {hd})))')
            return f'ET.szx({t}, {N}, h_{f}, 30n, {{==}}, {hb})'
        a = self.alias
        return f'{a}.szx_{p}({t}, {N}, {qc}, {rc}, {dd}, {hd}, {hlc})'


# ---- the runtime's source ---------------------------------------------------------------------------

SRC = None
SRC_FILE = 'types/fulu_obj.bend'
_STD = None


def STD_CHILDREN():
    """The children in the encoder-window interface (codegen/proofs/var/encoder_window_children.py), by runtime prefix;
    bl32 keeps its own branch."""
    global _STD
    if _STD is None:
        from codegen.proofs.var import encoder_window_children as EC
        _STD = {}
        for p in EC.PREFIXES:
            if p == 'bl32':
                continue
            # this run's interface module first (GEN), else the disk's
            fi = EC.OBJ / f'encx_{p}_iface.bend'
            if fi in GEN:
                _STD[p] = EC.read_child(p, GEN[fi], fi.name)
            elif p in EC.CHILDREN:
                _STD[p] = EC.CHILDREN[p]
    return _STD


def src():
    global SRC
    if SRC is None:
        SRC = RR.mono_text('generic' if 'generic' in SRC_FILE else 'fulu')
    return SRC


def has_valid_f(p):
    """the runtime's `_valid` of p is the fields' `_valid_f` and the size pass (typed_object_runtime.valid_needs_size, R4-05)"""
    return re.search(rf'^def {re.escape(p)}_valid_f\(', src(), re.M) is not None


def fn_body(name):
    m = re.search(rf'^def {re.escape(name)}\(.*?(?=^def |\Z)', src(), re.M | re.S)
    if not m:
        raise SystemExit(f'no runtime def {name}')
    return m.group(0)


def fn_params(name):
    """The parameter names of a runtime def, in order."""
    m = re.search(rf'^def {re.escape(name)}\((.*?)\) ->', src(), re.M)
    if not m:
        raise SystemExit(f'no runtime def {name}')
    ps = []
    d = 0
    cur = ''
    for ch in m.group(1):
        if ch in '<({':
            d += 1
        elif ch in '>)}':
            d -= 1
        if ch == ',' and d == 0:
            ps.append(cur)
            cur = ''
        else:
            cur += ch
    ps.append(cur)
    return [x.split(':')[0].strip().lstrip('+~-') for x in ps]


# ---- the container --------------------------------------------------------------------------------------

class Cont:
    def __init__(self, g, names, C):
        self.C = C
        self.t = names[C]
        self.s = g.shape(self.t)
        self.p = self.s.p
        F = self.s.fields
        self.F = F
        self.hoff, self.fixed = G.container_layout(F)
        self.wide = len(F) > GROUP
        self.leaves = {}
        self.children = {}
        self.fixw = {}
        for i, (f, fs) in enumerate(F):
            if fs.fixed and fs.data:
                lf = leaf_of(fs)
                self.leaves.setdefault(lf.p, lf)
            elif is_fixw_ext(fs):
                self.fixw[f] = FixW(f, fs)
            elif not fs.fixed:
                self.children[f] = Child(f, fs)
            else:
                raise SystemExit(f'field {f}: {fs.kind} not supported')


def _pz_argument(body):
    """The argument V of the first `O.pz(V)` of a runtime put step (the check of its Data leaves, folded into the returned
    size), with its calls qualified as T.<call>; None when the step has no such check."""
    j = body.find('O.pz(')
    if j < 0:
        return None
    start, depth, end = j + len('O.pz('), 0, j + len('O.pz(')
    for end in range(start, len(body)):
        if body[end] == '(':
            depth += 1
        elif body[end] == ')':
            if depth == 0:
                break
            depth -= 1
    return re.sub(r'(?<![\w.])([a-z_]\w*)\(', r'T.\1(', body[start:end])


def _object_params(K, F):
    """The writer's parameters and hypotheses and the object each field contributes: (OP, OA, HP, HA, OBJF), the parameter
    declarations and argument names, the hypothesis declarations and argument names, and the field -> object term table."""
    OP, OA, HP, HA = [], [], [], []
    OBJF = {}
    for i, (f, fs) in enumerate(F):
        if fs.fixed and fs.data:
            OP.append(f'+{f}: {leaf_of(fs).ctor}')
            OA.append(f)
            OBJF[f] = f
            if leaf_of(fs).bits:
                OBJF[f] = bits_obj(leaf_of(fs), f)
                HP.append(f'+hv_{f}: {{U32.is_lt({f}, {2 ** leaf_of(fs).bits}) == {TRUE}}}')
                HA.append(f'hv_{f}')
            if leaf_of(fs).pad:
                HP.append(f'+hv_{f}: {{OK_{leaf_of(fs).p}({f}) == {TRUE}}}')
                HA.append(f'hv_{f}')
            if leaf_of(fs).tail:
                HP.append(f'+hv_{f}: {{T.{leaf_of(fs).p}_valid({f}) == {TRUE}}}')
                HA.append(f'hv_{f}')
        elif f in K.fixw:
            fw = K.fixw[f]
            OP += fw.params
            OA += fw.oargs
            HP += fw.hyps
            HA += fw.hargs
            OBJF[f] = fw.obj
        else:
            ch = K.children[f]
            OP += ch.params
            OA += ch.oargs
            HP += ch.hyps
            HA += ch.hargs
            OBJF[f] = ch.obj

    return OP, OA, HP, HA, OBJF


def generate_cont(g, names, C):
    global U32M
    K = Cont(g, names, C)
    F, hoff, FIX, p = K.F, K.hoff, K.fixed, K.p
    U32M = FIX >= U32FIX
    U32PK.clear()
    ELNS.clear()
    if U32M:
        U32PK.update(fw.S for fw in K.fixw.values() if fw.packed and fw.S >= BIGPIECE)
        U32PK.add(FIX)
    names_ = [f for f, _ in F]
    fsd = dict(F)
    OP, OA, HP, HA, OBJF = _object_params(K, F)
    # the runtime's check of the sub-word leaves, folded into the returned size (c .|. O.pz(V)): V is a hypothesis
    K.pz = None
    if not K.wide and any(fs.fixed and fs.data for _, fs in F):
        npw = sum(1 for _, fs in F if not fs.data)    # the put steps: the variable fields and the checked fixed writers
        if npw:
            K.pz = _pz_argument(fn_body(f'{p}_pw{npw - 1}'))
        if K.pz is not None:
            for f_, fs_ in F:
                if fs_.fixed and fs_.data and leaf_of(fs_).bits:
                    K.pz = re.sub(rf'(?<![\w.{{]){f_}\b', bits_obj(leaf_of(fs_), f_), K.pz)
            HP.append(f'+hpz: {{{K.pz} == {TRUE}}}')
            HA.append('hpz')
    # a wide container's groups' own checks of their Data fields, folded into the group's size (c .|. O.pz(V))
    K.gpz = {}
    if K.wide:
        for gk_ in range(0, (len(F) + GROUP - 1) // GROUP):
            idx_ = list(range(gk_ * GROUP, min(gk_ * GROUP + GROUP, len(F))))
            nps_ = sum(1 for i_ in idx_ if not F[i_][1].data)
            if not nps_ or not any(F[i_][1].fixed and F[i_][1].data for i_ in idx_):
                continue
            term = _pz_argument(fn_body(f'{p}_g{gk_}_pw{nps_ - 1}'))
            if term is None:
                continue
            K.gpz[gk_] = term
            HP.append(f'+hpz_g{gk_}: {{{term} == {TRUE}}}')
            HA.append(f'hpz_g{gk_}')
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    if K.wide:
        groups = [(k // GROUP, list(range(k, min(k + GROUP, len(F))))) for k in range(0, len(F), GROUP)]
    else:
        groups = [(None, list(range(len(F))))]

    def gname(gk):
        return p if gk is None else f'{p}_g{gk}'

    def grec(gk, idx):
        return f'T.{gname(gk)}{{' + ', '.join(OBJF[names_[i]] for i in idx) + '}'
    if K.wide:
        OBJ = f'T.{C}{{' + ', '.join(grec(gk, idx) for gk, idx in groups) + '}'
    else:
        OBJ = grec(None, groups[0][1])
    X0 = 'Nat.add(A.quad(q), r)'
    MA = f'{OAS}, dd, D, X, q, r'
    MP = f'{OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat'
    # ---- the pieces ----
    pieces = []   # (kind, field, size term)
    fidx = {}
    for i, (f, fs) in enumerate(F):
        fidx[f] = len(pieces)
        pieces.append(('fix' if fs.fixed else 'off', f, f'{fs.fsize}n' if fs.fixed else '4n'))
    var = [f for f, fs in F if not fs.fixed]
    vidx = {}
    for f in var:
        vidx[f] = len(pieces)
        pieces.append(('var', f, K.children[f].len))
    PT = f'WD.PADB(r, LLC({MA}))'
    pieces.append(('pad', None, PT))
    ks_all = [K.children[f].len for f in var]
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    FS = '[' + ', '.join(sz for k, f, sz in pieces if k in ('fix', 'off')) + ']'
    # ---- the runtime's writes, in order ----
    events = []    # dict(kind, field, ...)
    cur_terms = {}

    def group_events(gk, idx, cur0):
        varg = [i for i in idx if not F[i][1].fixed]
        ling = [i for i in idx if not F[i][1].data]
        psteps = [('putv', i) for i in varg] + [('put', i) for i in ling if i not in varg]
        cur = cur0
        for kind_, i in psteps:
            f = names_[i]
            if kind_ == 'putv':
                events.append(dict(kind='off', field=f, cur=cur, hoff=hoff[i]))
                events.append(dict(kind='var', field=f, cur=cur))
                cur_terms[f] = cur
                cur = f'O.padd({cur}, {K.children[f].sz})'
            else:
                events.append(dict(kind='fixw', field=f, hoff=hoff[i]))
                if not K.wide:
                    cur = f'({cur} .|. 0 : U32)'    # the checked writer's flag (0), as the rt_* put step carries it
        if K.pz is not None and psteps:
            cur = f'({cur} .|. O.pz({K.pz}) : U32)'
        for i in idx:
            if F[i][1].fixed and F[i][1].data:
                events.append(dict(kind='leaf', field=names_[i], hoff=hoff[i]))
        return psteps, cur
    GI = []
    cur = f'{FIX}'
    for gk, idx in groups:
        st, cur2 = group_events(gk, idx, cur)
        GI.append((gk, idx, st, cur))
        cur = cur2
    SZC = cur
    # the models
    L = []
    w = L.append
    for lf in K.leaves.values():
        if not lf.sub:
            w(leaf_text(lf))
    for fw in K.fixw.values():
        if fw.text:
            w(fw.text)
    LLCB = fadd(big_fixed(pieces), f'U32.to_nat({FIX})' if U32M else f'{FIX}n', f'VCN.SUM({KS(ks_all)})')
    w(TEMPLATES.render('generate_cont', C=C, OPS=OPS, OBJ=OBJ, LLCB=LLCB, SZC=SZC))
    if K.pz is not None:
        core = SZC[1:SZC.index(f' .|. O.pz(')]
        w(f'''# the returned size, the leaves valid
def szpz({OPS}, +hpz: {{{K.pz} == {TRUE}}}) -> {{SZC({OAS}) == {core} : U32}}:
  Equal.trans(U32, U32.or({core}, O.pz({K.pz})), U32.or({core}, 0), {core}, Equal.cong(Bool, U32, zb => U32.or({core}, O.pz(zb)), {K.pz}, True{{}}, hpz), UWB.or0r({core}))
''')
    # models M0..Mn
    w(f'def M0({MP}) -> {TR}: D')
    for k, ev in enumerate(events):
        prev = f'M{k}({MA})'
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf' and leaf_of(fs).sub:
            mdl = f'{leaf_of(fs).model}(dd, {prev}, X, {ev["hoff"]}, {f})'
        elif ev['kind'] == 'off' and (ev['hoff'] % 4 or U32M):
            Xc = f'U32.add(X, {ev["hoff"]})'
            mdl = f'WD.W32X(VCN.RX({Xc}), dd, {prev}, VCN.QX({Xc}), {ev["cur"]})'
        elif ev['kind'] == 'leaf':
            lf = leaf_of(fs)
            qk_, rk_ = qr_at(ev['hoff'])
            mdl = f'PXo_{lf.p}({f}, dd, {prev}, {qk_}, {rk_})'
        elif ev['kind'] == 'fixw':
            qk_, rk_ = qr_at(ev['hoff'])
            mdl = K.fixw[f].model(rk_, prev, qk_)
        elif ev['kind'] == 'off':
            kw = ev['hoff'] // 4
            mdl = f'WD.W32X(r, dd, {prev}, Nat.add({kw}n, q), {ev["cur"]})'
        else:
            Xc = f'U32.add(X, {ev["cur"]})'
            mdl = K.children[f].model('dd', prev, Xc, f'VCN.QX({Xc})', f'VCN.RX({Xc})')
        w(f'def M{k + 1}({MP}) -> {TR}: {mdl}')
    NE = len(events)
    w(f'def PUTC({MP}) -> {TR}: M{NE}({MA})')
    return K, L, events, GI, OBJ, OBJF, OP, OA, HP, HA, pieces, fidx, vidx, var, ks_all, PT, FS, groups, SZC


def module_text(g, names, C):
    K, L, events, GI, OBJ, OBJF, OP, OA, HP, HA, pieces, fidx, vidx, var, ks_all, PT, FS, groups, SZC = generate_cont(g, names, C)
    F, hoff, FIX, p = K.F, K.hoff, K.fixed, K.p
    names_ = [f for f, _ in F]
    fsd = dict(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    MA = f'{OAS}, dd, D, X, q, r'
    MP = f'{OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat'
    X0 = 'Nat.add(A.quad(q), r)'
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    w = L.append
    Mk = lambda k: f'M{k}({MA})'
    TH = lambda k: f'FD.array__thaw(U32, {Mk(k)})'
    # ---- the putv facts, per variable field ----
    for f in var:
        ch = K.children[f]
        V = ch.obj
        RT = f'Array<U32> & ({ch.vt} & U32)'
        w(TEMPLATES.render('module_text', f=f, ch=ch, V=V, RT=RT))
    # ---- the runtime chain: facts per write ----
    def fact(k, ev):
        """(inner lhs, rhs) of write k (runtime term on tree M_k)."""
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf':
            return f'T.{leaf_of(fs).p}_put({TH(k)}, U32.add(X, {ev["hoff"]}), {OBJF[f]})', TH(k + 1), 'Array<U32>'
        if ev['kind'] == 'fixw':
            o = OBJF[f]
            return f'T.{fs.p}_putk({TH(k)}, U32.add(X, {ev["hoff"]}), {o})', f'({TH(k + 1)}, ({o}, 0))', K.fixw[f].rtype
        if ev['kind'] == 'off':
            return f'O.w32({TH(k)}, U32.add(X, {ev["hoff"]}), {ev["cur"]})', TH(k + 1), 'Array<U32>'
        ch = K.children[f]
        return f'T.{ch.p}_putk({TH(k)}, U32.add(X, {ev["cur"]}), {ch.obj})', f'({TH(k + 1)}, ({ch.obj}, {ch.sz}))', f'Array<U32> & ({ch.vt} & U32)'
    FACTP = []
    for k, ev in enumerate(events):
        lhs, rhs, ty = fact(k, ev)
        FACTP.append(f'+f{k}: {{{lhs} == {rhs} : {ty}}}')
    FPS = ',\n    '.join(FACTP)
    FAS = ', '.join(f'f{k}' for k in range(len(events)))
    # chain builder
    def chain(ty, steps, start, end):
        """steps: [(ctx lambda body with z, inner lhs, inner rhs, inner type, proof, term after)]"""
        if not steps:
            return '{==}'
        terms = [start] + [s[5] for s in steps]
        def go(j):
            ctx, lhs, rhs, ity, prf, after = steps[j]
            e = f'Equal.cong({ity}, {ty}, z => {ctx}, {lhs}, {rhs}, {prf})'
            if j == len(steps) - 1:
                return e
            return f'Equal.trans({ty}, {terms[j]}, {terms[j + 1]}, {end}, {e}, {go(j + 1)})'
        return go(0)
    # per group: runtime lemma
    evk = {}  # event index by (kind, field)
    for k, ev in enumerate(events):
        evk[(ev['kind'], ev['field'])] = k
    GRT = []
    k0 = 0
    for gk, idx, psteps, cur0 in GI:
        gp = p if gk is None else f'{p}_g{gk}'
        gobj = f'T.{gp}{{' + ', '.join(OBJF[names_[i]] for i in idx) + '}'
        data_only = not psteps
        nev = sum(1 for ev in events if ev['field'] in [names_[i] for i in idx])
        kA, kB = k0, k0 + nev
        k0 = kB
        steps = []
        if data_only:
            RTg = 'Array<U32>'
            start = f'T.{gp}_put({TH(kA)}, X, {cur0}, {gobj})' if K.wide else None
        else:
            RTg = f'Array<U32> & (T.{gp} & U32)'
            start = f'T.{gp}_put({TH(kA)}, X, {cur0}, {gobj})' if K.wide else f'T.{gp}_putn({TH(kA)}, X, {gobj})'
        # the chain steps
        held = lambda i_ex, reps: [reps.get(names_[i], OBJF[names_[i]]) for i in idx if i != i_ex]
        cur = cur0
        reps = {}
        kk = kA
        for s, (kind_, i) in enumerate(psteps):
            f = names_[i]
            pw = f'T.{gp}_pw{s}'
            pnames = fn_params(f'{gp}_pw{s}')
            if kind_ == 'putv':
                ch = K.children[f]
                args = ['X'] + held(i, reps)
                ctx = f'{pw}({", ".join(args)}, z)'
                lhs = f'T.{ch.p}_putv({TH(kk)}, X, {hoff[i]}, {cur}, {ch.obj})'
                ncur = f'O.padd({cur}, {ch.sz})'
                rhs = f'({TH(kk + 2)}, ({ch.obj}, {ncur}))'
                ity = f'Array<U32> & ({ch.vt} & U32)'
                prf = f'putv_{f}({", ".join(ch.oargs)}, {Mk(kk)}, {Mk(kk + 1)}, {Mk(kk + 2)}, X, {hoff[i]}, {cur}, f{kk}, f{kk + 1})'
                steps.append((ctx, lhs, rhs, ity, prf, f'{pw}({", ".join(args)}, {rhs})'))
                cur = ncur
                kk += 2
            else:
                fs = fsd[f]
                args = ['X', cur] + held(i, reps)
                ctx = f'{pw}({", ".join(args)}, z)'
                o = OBJF[f]
                lhs = f'T.{fs.p}_putk({TH(kk)}, U32.add(X, {hoff[i]}), {o})'
                rhs = f'({TH(kk + 1)}, ({o}, 0))'
                steps.append((ctx, lhs, rhs, K.fixw[f].rtype, f'f{kk}', f'{pw}({", ".join(args)}, {rhs})'))
                cur = f'({cur} .|. 0 : U32)'
                kk += 1
        if K.pz is not None and psteps:
            cur = f'({cur} .|. O.pz({K.pz}) : U32)'
        if K.wide and psteps and gk in K.gpz:
            cur = f'({cur} .|. O.pz({K.gpz[gk]}) : U32)'
        # the Data fields, innermost first
        dat = [i for i in idx if F[i][1].fixed and F[i][1].data]

        def fw(expr, j0):
            for i in dat[j0:]:
                expr = f'T.{leaf_of(fsd[names_[i]]).p}_put({expr}, U32.add(X, {hoff[i]}), {OBJF[names_[i]]})'
            return expr
        for j, i in enumerate(dat):
            f = names_[i]
            lhs, rhs, ity = fact(kk, events[kk])
            inner = fw('z', j + 1)
            if data_only:
                ctx = inner
                after = fw(rhs, j + 1)
            else:
                ctx = f'({inner}, ({gobj}, {cur}))'
                after = f'({fw(rhs, j + 1)}, ({gobj}, {cur}))'
            steps.append((ctx, lhs, rhs, ity, f'f{kk}', after))
            kk += 1
        assert kk == kB, (gk, kk, kB)
        end = TH(kB) if data_only else f'({TH(kB)}, ({gobj}, {cur}))'
        if start is None:
            start = f'T.{gp}_put({TH(kA)}, X, {gobj})'
        GRT.append((gk, gp, kA, kB, RTg, start, end, cur, gobj, data_only))
        w(TEMPLATES.render('module_text_2', gp=gp, gk=gk, p=p, MP=MP, FPS=FPS, start=start, end=end, RTg=RTg, chain=chain, steps=steps))
    # the whole container (wide): putn through the groups
    RTC = f'Array<U32> & (T.{C} & U32)'
    START = f'T.{p}_putn({TH(0)}, X, {OBJ})'
    ENDC = f'({TH(len(events))}, ({OBJ}, {SZC}))'
    if K.wide:
        lin = [x for x in GRT if not x[9]]
        steps = []
        gmap = {x[0]: x for x in GRT}
        allg = [x[0] for x in GRT]
        # putn: the Data groups before the first linear group, then pw0(...)
        first = lin[0]
        assert all(not gmap[gk][9] or gk > first[0] for gk in allg), 'Data groups before the first linear group'
        for j, x in enumerate(lin):
            gk, gp, kA, kB, RTg, start, end, cur, gobj, _ = x
            heldg = [gmap[g2][8] for g2 in allg if g2 != gk]
            if j == 0:
                ctx = f'T.{p}_pw0(X, {", ".join(heldg)}, z)'
            else:
                ctx = f'T.{p}_pw{j}(X, {", ".join(heldg)}, z)'
            nm = 'G' + gp[len(p):]
            prf = f'rt_{nm}({MA}, {FAS})'
            after = f'{ctx.replace("z)", end + ")")}'
            steps.append((ctx, start, end, RTg, prf, after))
            # a group ending in FixW writes returns (c .|. 0): back to c (vuw_bits.or0r; a literal c evaluates)
            clean = cur
            if gk in K.gpz and clean.endswith(f' .|. O.pz({K.gpz[gk]}) : U32)'):
                # its Data fields' check (c .|. O.pz(V)), V true: back to c
                inner_ = clean[1:-len(f' .|. O.pz({K.gpz[gk]}) : U32)')]
                ctx3 = ctx.replace('z)', f'({TH(kB)}, ({gobj}, z)))')
                V_ = K.gpz[gk]
                prf_ = (f'Equal.trans(U32, U32.or({inner_}, O.pz({V_})), U32.or({inner_}, 0), {inner_}, '
                        f'Equal.cong(Bool, U32, zb => U32.or({inner_}, O.pz(zb)), {V_}, True{{}}, hpz_g{gk}), UWB.or0r({inner_}))')
                steps.append((ctx3, clean, inner_, 'U32', prf_, ctx.replace('z)', f'({TH(kB)}, ({gobj}, {inner_})))')))
                clean = inner_
                K.or0 = True
            while re.fullmatch(r'\((.*) \.\|\. 0 : U32\)', clean) and not re.fullmatch(r'\((\d+) \.\|\. 0 : U32\)', clean):
                inner_ = re.fullmatch(r'\((.*) \.\|\. 0 : U32\)', clean).group(1)
                ctx3 = ctx.replace('z)', f'({TH(kB)}, ({gobj}, z)))')
                steps.append((ctx3, clean, inner_, 'U32', f'UWB.or0r({inner_})', ctx.replace('z)', f'({TH(kB)}, ({gobj}, {inner_})))')))
                clean = inner_
                K.or0 = True
            cur = clean
            # Data groups after this one (before the next linear one)
            nxt = lin[j + 1][0] if j + 1 < len(lin) else None
            for g2 in allg:
                y = gmap[g2]
                if y[9] and g2 > gk and (nxt is None or g2 < nxt):
                    ctx2 = f'(z, ({OBJ}, {cur}))'
                    nm2 = 'G' + y[1][len(p):]
                    steps.append((ctx2, y[5], y[6], 'Array<U32>', f'rt_{nm2}({MA}, {FAS})', f'({y[6]}, ({OBJ}, {cur}))'))
        chain_rt = chain(RTC, steps, START, ENDC)
    else:
        chain_rt = f'rt_C({MA}, {FAS})'
    GPZP = ''.join(f',\n    +hpz_g{gk_}: {{{V_} == {TRUE}}}' for gk_, V_ in sorted(K.gpz.items()))
    w(TEMPLATES.render('module_text_3', C=C, MP=MP, FPS=FPS, GPZP=GPZP, START=START, ENDC=ENDC, RTC=RTC, chain_rt=chain_rt))
    return L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC


def K_fixed_count(pieces):
    return sum(1 for k, _, _ in pieces if k in ('fix', 'off'))


def _putx_subword_event(fidx, hle, FIX, X0, LLv, Mk, st, a, u32m, BSF, facts, f, k, ev, fs, kind, UBk, UBn):
    """a sub-word leaf or a byte-offset word: zero its bytes, write them, and the registers of the piece"""
    assert not (u32m and kind == 'leaf'), 'U32 mode: a sub-word leaf'
    i = fidx[f]
    c = ev['hoff']
    size = 4 if kind == 'off' else leaf_of(fs).sub
    pre = '[' + ', '.join(st[:i]) + ']'
    post = '[' + ', '.join(st[i + 1:]) + ']'
    Xc = f'U32.add(X, {c})'
    rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
    hk = f'FD.nat__le_trans(Nat.add({c}n, {size}n), {FIX}n, {LLv}, {{==}}, {BSF})'
    cn_ = f'{c}n'
    if u32m:
        hk, cn_ = hle(c, size, f'{size}n'), f'U32.to_nat({c})'
    a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
    if kind == 'leaf':
        lf = leaf_of(fs)
        m = lf.sub
        a(f'+g{k} = {lf.rt}(dd, {Mk(k)}, X, {c}, {c}n, q, r, {LLv}, {f}, e, {{==}}, hd, {hk}, hl, pf{k}, z{k})')
        Y = f'[U32.and({f}, 255)]' if m == 1 else f'[U32.and({f}, 255), U32.and(U32.shrn({f}, 8n), 255)]'
        pput = 'u8' if lf.bits else fs.p
        RT_ = f'{{T.{pput}_put(FD.array__thaw(U32, {Mk(k)}), {Xc}, {f}) == FD.array__thaw(U32, {lf.model}(dd, {Mk(k)}, X, {c}, {f})) : Array<U32>}}'
        BY_ = f'{{UA.BYT({lf.model}(dd, {Mk(k)}, X, {c}, {f})) == UW.SPL(UA.BYT({Mk(k)}), Nat.add({X0}, {c}n), {Y}) : +List<U32>}}'
        if lf.bits:
            # the bit vector's put is the byte write (vbitb.put<n>, its word below 2^n)
            a(f'+rt{k} = Equal.trans(Array<U32>, T.{fs.p}_put(FD.array__thaw(U32, {Mk(k)}), {Xc}, {bits_obj(lf, f)}), T.u8_put(FD.array__thaw(U32, {Mk(k)}), {Xc}, {f}), '
              f'FD.array__thaw(U32, {lf.model}(dd, {Mk(k)}, X, {c}, {f})), VBB.put{lf.bits}(FD.array__thaw(U32, {Mk(k)}), {Xc}, {f}, hv_{f}), PA({RT_}, {BY_}, g{k}))')
        else:
            a(f'+rt{k} = PA({RT_}, {BY_}, g{k})')
        a(f'+by{k} = PB({RT_}, {BY_}, g{k})')
        a(f'+pf{k + 1} = {lf.pf}(dd, {Mk(k)}, X, {c}, {f}, pf{k})')
    else:
        cur = ev['cur']
        QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
        pos = f'Nat.add(A.quad({QX}), {RX})'
        a(f'+ep{k} = VPC.ppos(X, {c}, {cn_}, q, r, {LLv}, 4n, dd, e, {{==}}, hd, {hk}, hl)')
        a(f'+hl{k} = VPC.proom(X, {c}, {cn_}, q, r, {LLv}, 4n, dd, e, {{==}}, hd, {hk}, hl)')
        if u32m:
            # the offset's place: the pieces before it sum to c (vpos32), then vpiece.ppos
            c_, eln_ = eln_u(st[:i])
            assert c_ == c, (f, c_, c)
            a(f'+eln{k} = {eln_}')
            a(f'+rp{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, {cn_}), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), {cn_}, eln{k}), ep{k})')
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt(4n, VS.bdr(zz, {UBk})) == UW.ZB(4n) : +List<U32>}}, {rel}, {pos}, rp{k}, z{k})')
        else:
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt(4n, VS.bdr(zz, {UBk})) == UW.ZB(4n) : +List<U32>}}, Nat.add({X0}, {c}n), {pos}, ep{k}, z{k})')
        a(f'+rt{k} = WD.w32_any(dd, {Mk(k)}, {Xc}, {QX}, {RX}, {cur}, VC.split4({Xc}), VCN.rx_lt({Xc}), hd, hl{k}, pf{k})')
        a(f'+bw{k} = WD.w32_any_bytes(dd, {Mk(k)}, {Xc}, {QX}, {RX}, {cur}, VC.split4({Xc}), VCN.rx_lt({Xc}), hd, hl{k}, pf{k}, hz{k})')
        Y = f'I.limb({cur})'
        if u32m:
            a(f'+by{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, rp{k}), bw{k})')
        else:
            a(f'+by{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, Nat.add({X0}, {c}n), Equal.sym(Nat, Nat.add({X0}, {c}n), {pos}, ep{k}), bw{k})')
        a(f'+pf{k + 1} = WD.w32x_perfect({RX}, dd, {Mk(k)}, {QX}, {cur}, pf{k})')
    a(f'+I{k + 1} = VCN.reg_put0(UA.BYT(D), {X0}, {pre}, {size}n, {post}, {Y}, {UBk}, {UBn}, hX, I{k}, {{==}}, by{k})')
    st[i] = Y
    facts.append(f'rt{k}')


def _putx_fixed_positions(FIX, X0, LLv, st, a, big_region, u32m, BSF, hle, f, k, UBk, i, c, size, pre, post, Xc, rel, pos, kw, qk, rk, rsize, bigp, pk, hzn):
    """a fixed field's position proofs: its word, the room past it and the zeros before it (U32, byte-offset and word-aligned cases)"""
    if u32m:
        # U32 mode: every fixed field at its byte position U32.to_nat(c) (QX/RX of X + c), the pieces
        # before it summed to c (vpos32), its end within F (vadd.lea); a packed vector's size U32.to_nat(S)
        SZT = f'U32.to_nat({size})' if pk else f'{size}n'
        RSZT = f'U32.to_nat({rsize})' if pk else f'{rsize}n'
        pos = f'Nat.add(A.quad({qk}), {rk})'
        cn_ = f'U32.to_nat({c})'
        a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
        a(f'+pp{k} = VPC.ppos(X, {c}, {cn_}, q, r, {LLv}, {SZT}, dd, e, {{==}}, hd, {hle(c, size, SZT)}, hl)')
        c_, eln_ = eln_u(st[:i])
        assert c_ == c, (f, c_, c)
        a(f'+eln{k} = {eln_}')
        a(f'+rp{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, {cn_}), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), {cn_}, eln{k}), pp{k})')
        a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({size}n, VS.bdr(zz, {UBk})) == UW.ZB({size}n) : +List<U32>}}, {rel}, {pos}, rp{k}, z{k})')
        if pk:
            a(f'+hzU{k} = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({pos}, {UBk})) == UW.ZB(zz) : +List<U32>}}, {size}n, {SZT}, {nat_u(f"{size}n")}, hz{k})')
            hzn = f'hzU{k}'
        a(f'+ep{k} = VC.split4({Xc})')
        a(f'+hl{k} = VPC.proom(X, {c}, {cn_}, q, r, {LLv}, {RSZT}, dd, e, {{==}}, hd, {hle(c, rsize, RSZT)}, hl)')
        hrk, eqpos = f'VCN.rx_lt({Xc})', f'rp{k}'
    elif c % 4:
        # a field at a byte offset: its word position (QX, RX) of X + c (vpiece.ppos / proom)
        pos = f'Nat.add(A.quad({qk}), {rk})'
        hk_ = f'FD.nat__le_trans(Nat.add({c}n, {size}n), {FIX}n, {LLv}, {{==}}, {BSF})'
        hkr_ = f'FD.nat__le_trans(Nat.add({c}n, {rsize}n), {FIX}n, {LLv}, {{==}}, {BSF})'
        a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
        a(f'+pp{k} = VPC.ppos(X, {c}, {c}n, q, r, {LLv}, {size}n, dd, e, {{==}}, hd, {hk_}, hl)')
        if bigp:
            a(f'+eln{k} = {ln_cat(st[:i], f"{c}n")}')
            a(f'+rp{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, {c}n), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), {c}n, eln{k}), pp{k})')
        a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({size}n, VS.bdr(zz, {UBk})) == UW.ZB({size}n) : +List<U32>}}, {rel}, {pos}, {"rp" if bigp else "pp"}{k}, z{k})')
        a(f'+ep{k} = VC.split4({Xc})')
        a(f'+hl{k} = VPC.proom(X, {c}, {c}n, q, r, {LLv}, {rsize}n, dd, e, {{==}}, hd, {hkr_}, hl)')
        hrk, eqpos = f'VCN.rx_lt({Xc})', f'{"rp" if bigp else "pp"}{k}'
    else:
        a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
        if bigp:
            a(f'+eln{k} = {ln_cat(st[:i], f"A.quad({kw}n)")}')
            a(f'+rp{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, A.quad({kw}n)), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), A.quad({kw}n), eln{k}), VRX.fpx(q, r, {kw}n))')
        a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({size}n, VS.bdr(zz, {UBk})) == UW.ZB({size}n) : +List<U32>}}, {rel}, {pos}, {f"rp{k}" if bigp else f"VRX.fpx(q, r, {kw}n)"}, z{k})')
        hkq = f'FD.nat__le_trans(A.quad({kw}n), {FIX}n, {LLv}, {{==}}, {BSF})' if big_region else '{==}'
        ecq = f'FD.nat__eq_from_is_eq(U32.to_nat({c}), A.quad({kw}n), {{==}})' if big_region else '{==}'
        a(f'+ep{k} = VRX.fpos(X, q, r, {kw}n, {c}, {LLv}, dd, e, {ecq}, hd, {hkq}, hl)')
        a(f'+hl{k} = VRX.froom(q, r, dd, {kw}n, {rsize}n, {LLv}, FD.nat__le_trans(Nat.add(A.quad({kw}n), {rsize}n), {FIX}n, {LLv}, {{==}}, {BSF}), hl)')
        hrk, eqpos = 'hr', (f'rp{k}' if bigp else f'VRX.fpx(q, r, {kw}n)')
    return pos, hzn, hrk, eqpos


def _putx_padded_leaf(X0, Mk, st, a, facts, f, k, fs, UBk, UBn, i, pre, post, Xc, rel, pos, qk, rk, hrk, eqpos):
    """the zero-padded one-byte leaf: its byte and the zeros to its word's end"""
    # the zero-padded one-byte leaf: its byte and the zeros to its word's end, from the next piece's zeros
    lf = leaf_of(fs)
    PDk = f'WD.PADB({rk}, 1n)'
    nx = st[i + 1]
    assert nx.startswith('UW.ZB(') and nx.endswith('n)'), nx
    rest = '[' + ', '.join(st[i + 2:]) + ']'
    a(f'+hp{k} = VCN.zb_pre({nx[6:-1]}, {rest}, {PDk}, FD.nat__le_trans({PDk}, 3n, {nx[6:-1]}, VCN.padb3({rk}, 1n), {{==}}))')
    a(f'+zp{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, 1n, {post}, {PDk}, {UBk}, hX, I{k}, hp{k})')
    a(f'+hzp{k} = FD.logic__subst(Nat, zz => {{VS.bt(Nat.add(1n, {PDk}), VS.bdr(zz, {UBk})) == UW.ZB(Nat.add(1n, {PDk})) : +List<U32>}}, {rel}, {pos}, {eqpos}, zp{k})')
    a(f'+g{k} = putxo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, {rk}, ep{k}, {hrk}, hd, hl{k}, pf{k}, hv_{f}, hzp{k})')
    a(f'+rt{k} = PA(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, {rk}), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, {rk}), g{k})')
    a(f'+by{k} = PB(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, {rk}), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, {rk}), g{k})')
    Y = f'VS.bt(1n, FX.limbs(RW_{lf.p}({f})))'
    a(f'+pf{k + 1} = pfo_{lf.p}({f}, dd, {Mk(k)}, {qk}, {rk}, pf{k})')
    a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, List.append(&2, U32, {Y}, UW.ZB({PDk}))) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, {eqpos}), by{k})')
    a(f'+I{k + 1} = VCN.reg_putc(UA.BYT(D), {X0}, {pre}, 1n, {post}, {Y}, {PDk}, {UBk}, {UBn}, hX, I{k}, lenb_{lf.p}({f}), hp{k}, hop{k})')
    st[i] = f'VCN.PC(1n, {Y})'
    facts.append(f'rt{k}')


def _putx_fixed_piece(K, Mk, a, u32m, f, k, ev, fs, kind, size, Xc, qk, rk, pk, hzn, hrk):
    """the fixed field's writer: the leaf, the checked fixed writer or the word, with its bytes and perfect-tree facts"""
    if kind == 'leaf':
        lf = leaf_of(fs)
        hv_ = f', hv_{f}' if lf.tail else ''
        a(f'+g{k} = putxo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, {rk}, ep{k}, {hrk}, hd, hl{k}, pf{k}{hv_}, hz{k})')
        a(f'+rt{k} = PA(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, {rk}), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, {rk}), g{k})')
        a(f'+by{k} = PB(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, {rk}), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, {rk}), g{k})')
        Y = leaf_bytes(lf, f)
        hY = f'lenb_{lf.p}({f})'
        a(f'+pf{k + 1} = pfo_{lf.p}({f}, dd, {Mk(k)}, {qk}, {rk}, pf{k})')
        piece = f'VCN.PC({size}n, {Y})'
        reg = 'reg_putc0'
    elif kind == 'fixw':
        fw = K.fixw[f]
        xs = (Mk(k), Xc, qk, rk, f'ep{k}', hrk, f'hl{k}', f'pf{k}', hzn)
        a(f'+rt{k} = {fw.rt(*xs)}')
        a(f'+by{k} = {fw.by(*xs)}')
        Y = fw.Y
        hY = fw.hY
        if u32m and pk:
            hY = f'Equal.trans(Nat, VCN.LN({Y}), U32.to_nat({size}), {size}n, {hY}, Equal.sym(Nat, {size}n, U32.to_nat({size}), {nat_u(f"{size}n")}))'
        a(f'+pf{k + 1} = {fw.pf(rk, Mk(k), qk, f"pf{k}")}')
        piece = f'VCN.PC({size}n, {Y})'
        reg = 'reg_putc0'
    else:
        cur = ev['cur']
        a(f'+rt{k} = WD.w32_any(dd, {Mk(k)}, {Xc}, {qk}, r, {cur}, ep{k}, hr, hd, hl{k}, pf{k})')
        a(f'+by{k} = WD.w32_any_bytes(dd, {Mk(k)}, {Xc}, {qk}, r, {cur}, ep{k}, hr, hd, hl{k}, pf{k}, hz{k})')
        Y = f'I.limb({cur})'
        hY = '{==}'
        a(f'+pf{k + 1} = WD.w32x_perfect(r, dd, {Mk(k)}, {qk}, {cur}, pf{k})')
        piece = Y
        reg = 'reg_put0'
    return Y, hY, piece, reg


def _putx_var_event(K, vidx, var, ks_all, FIX, X0, LLv, Mk, KS, st, a, PTr, big_region, u32m, FIXT, UF, eUF, FA, RV, LE, facts, curs, enc_of, szx_of, ec_of, vj, f, nfix, k, ev, UBk, UBn):
    """a variable-length child: its room, position, put and the registers of its piece"""
    ch = K.children[f]
    j = vj[f]
    i = vidx[f]
    cur = ev['cur']
    ks_j = ks_all[:j]
    rest = ks_all[j + 1:]
    Lj = ch.len
    aj = FA(f'VCN.SUM({KS(ks_j)})')
    Xc = f'U32.add(X, {cur})'
    QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
    if j == 0 and u32m:
        assert cur == f'{FIX}' and aj == f'Nat.add(VCN.SUM([]), {FIXT})', (cur, aj)
        a(f'+ec{k} = Equal.trans(Nat, {UF}, {FIXT}, {aj}, {eUF}, Equal.sym(Nat, {aj}, {FIXT}, P32.snil({FIXT})))')
    elif j == 0:
        a(f'+ec{k} = VCN.EQN(U32.to_nat({cur}), {aj}, {{==}})')
    else:
        fp = var[j - 1]
        pa = f'Nat.add({FA(f"VCN.SUM({KS(ks_all[:j - 1])})")}, {ks_all[j - 1]})'
        a(f'+ec{k} = VCN.cnext{RV}({curs[fp]}, {K.children[fp].sz}, {FIXT}, {KS(ks_all[:j - 1])}, {ks_all[j - 1]}, dd, hd, {ec_of[fp]}, {szx_of[fp]}, '
          f'VCN.pc_end(q, r, {LLv}, dd, {pa}, VCN.pc_room{RV}({FIXT}, {KS(ks_all[:j - 1])}, {ks_all[j - 1]}, {KS(ks_all[j:])}{LE}), hl))')
    ec_of[f] = f'ec{k}'
    curs[f] = cur
    a(f'+hk{k} = VCN.pc_room{RV}({FIXT}, {KS(ks_j)}, {Lj}, {KS(rest)}{LE})')
    a(f'+ha{k} = FD.nat__le_trans({aj}, Nat.add({aj}, {Lj}), {LLv}, Order.below_sum({aj}, {Lj}), hk{k})')
    a(f'+ep{k} = VCN.vpos(X, {cur}, {aj}, q, r, {LLv}, dd, e, ec{k}, hd, ha{k}, hl)')
    a(f'+hlc{k} = VCN.croom({Xc}, q, r, {aj}, {Lj}, {LLv}, dd, ep{k}, hk{k}, hl)')
    fw = st[:nfix]
    ps = '[' + ', '.join(enc_of[x] for x in var[:j]) + ']'
    pre = f'VCN.LAP([{", ".join(fw)}], VCN.PCL({KS(ks_j)}, {ps}))'
    post = '[' + ', '.join(st[i + 1:]) + ']'
    rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
    pos = f'Nat.add(A.quad({QX}), {RX})'
    epv = f'VCN.eposv{RV}([{", ".join(fw)}], {ps}, {KS(ks_j)})'
    if u32m or big_pieces(fw):
        if u32m:
            c_, efw_ = eln_u(fw)
            assert c_ == FIX, (c_, FIX)
            a(f'+efw{k} = Equal.trans(Nat, VCN.LN(VCN.CAT([{", ".join(fw)}])), {UF}, {FIXT}, {efw_}, {eUF})')
        else:
            a(f'+efw{k} = {ln_cat(fw, f"{FIX}n")}')
        LF_ = f'VCN.LN(VCN.CAT([{", ".join(fw)}]))'
        SJ_ = f'VCN.SUM({KS(ks_j)})'
        epv = (f'Equal.trans(Nat, VCN.LN(VCN.CAT({pre})), {fadd(big_region, LF_, SJ_)}, {aj}, {epv}, '
               f'Equal.cong(Nat, Nat, zz => {fadd(big_region, "zz", SJ_)}, {LF_}, {FIXT}, efw{k}))')
    a(f'+epc{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, {aj}), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), {aj}, '
      f'{epv}), '
      f'Equal.trans(Nat, Nat.add({X0}, {aj}), U32.to_nat({Xc}), {pos}, Equal.sym(Nat, U32.to_nat({Xc}), Nat.add({X0}, {aj}), ep{k}), VC.split4({Xc})))')
    if ch.pad:
        pc = f'WD.PADB({RX}, {Lj})'
        MSr = f'VCN.APPN({KS(rest)}, [{PTr}])'
        a(f'+hp{k} = VCN.zbs_pre({MSr}, {pc}, VCN.padfit({Xc}, q, r, {aj}, {Lj}, {LLv}, VCN.SUM({MSr}), ep{k}, hk{k}, '
          f'VCN.pc_after{RV}({FIXT}, {KS(ks_j)}, {Lj}, {KS(rest)}, {PTr}{LE})))')
        a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {pc}, {UBk}, hX, I{k}, hp{k})')
        win = f'Nat.add({Lj}, {pc})'
        a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({win}, VS.bdr(zz, {UBk})) == UW.ZB({win}) : +List<U32>}}, {rel}, {pos}, epc{k}, z{k})')
    else:
        a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
        a(f'+z{k}b = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({rel}, {UBk})) == UW.ZB(zz) : +List<U32>}}, Nat.add({Lj}, 0n), {Lj}, FD.nat__add_zero({Lj}), z{k})')
        a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({Lj}, VS.bdr(zz, {UBk})) == UW.ZB({Lj}) : +List<U32>}}, {rel}, {pos}, epc{k}, z{k}b)')
    g, parts, pfx, kind_ = ch.putx('dd', Mk(k), Xc, QX, RX, f'VC.split4({Xc})', f'VCN.rx_lt({Xc})', 'hd', f'hlc{k}', f'pf{k}', f'hz{k}')
    if kind_ is None:
        a(f'+rt{k} = {g}')
        a(f'+by{k} = {parts}')
        a(f'+pf{k + 1} = {pfx}')
    else:
        RT, BYt, PF = parts
        a(f'+g{k} = {g}')
        a(f'+rt{k} = PA({RT}, DK.P2({BYt}, {PF}), g{k})')
        a(f'+g{k}b = PB({RT}, DK.P2({BYt}, {PF}), g{k})')
        a(f'+by{k} = PA({BYt}, {PF}, g{k}b)')
        a(f'+pf{k + 1} = PB({BYt}, {PF}, g{k}b)')
    Y = f'VCN.AP({ch.enc}, UW.ZB(WD.PADB({RX}, {Lj})))' if ch.pad else ch.enc
    a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, epc{k}), by{k})')
    if ch.pad:
        a(f'+I{k + 1} = VCN.reg_putc(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {ch.enc}, WD.PADB({RX}, {Lj}), {UBk}, {UBn}, hX, I{k}, {ch.hY}, hp{k}, hop{k})')
    else:
        a(f'+I{k + 1} = VCN.reg_putc0(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {ch.enc}, {UBk}, {UBn}, hX, I{k}, {ch.hY}, hop{k})')
    a(f'+sz{k} = {ch.szx(QX, RX, "dd", "hd", f"hlc{k}")}')
    szx_of[f] = f'sz{k}'
    enc_of[f] = ch.enc
    st[i] = f'VCN.PC({Lj}, {ch.enc})'
    facts.append(f'rt{k}')


def putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC):
    hle = None  # bound only on some paths below; the helpers take them
    F, FIX = K.F, K.fixed
    fsd = dict(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS = ', '.join(HP)
    MA = f'{OAS}, dd, D, X, q, r'
    X0 = 'Nat.add(A.quad(q), r)'
    LLv = f'LLC({MA})'
    Mk = lambda k: f'M{k}({MA})'
    BY = lambda k: f'UA.BYT({Mk(k)})'
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    st = [f'UW.ZB({sz})' for _, _, sz in pieces]
    L = []
    w = L.append
    ls = []
    a = ls.append
    PTr = f'WD.PADB(r, {LLv})'
    MS = f'VCN.APPN({FS}, VCN.APPN({KS(ks_all)}, [{PTr}]))'
    a(f'+hX = VRX.xstart(q, r, {LLv}, dd, D, pf, hl)')
    esr = f'VCN.sum_region({FS}, {KS(ks_all)}, {PTr})'
    big_region = big_fixed(pieces)
    u32m = U32M
    # F: the literal here, a variable SZ<F> in putx_core (U32 mode: eSZ<F> states it at U32.to_nat(F))
    FIXT = f'{FIX}n'
    eLF = 'eLF'
    UF = f'U32.to_nat({FIX})'
    eUF = f'Equal.sym(Nat, {FIXT}, {UF}, eSZ{FIX})'     # {U32.to_nat(F) == F}
    if u32m:
        assert big_region
        SK = f'VCN.SUM({KS(ks_all)})'
        szs_ = split_args(FS[1:-1])
        esr = (f'Equal.trans(Nat, VCN.SUM({MS}), Nat.add(Nat.add({SK}, {FIXT}), {PTr}), Nat.add({LLv}, {PTr}), '
               f'VCN.sum_region_r({FS}, {KS(ks_all)}, {PTr}, {FIXT}, Equal.trans(Nat, VCN.SUM({FS}), {UF}, {FIXT}, {sum_u(szs_)}, {eUF})), '
               f'Equal.cong(Nat, Nat, zz => Nat.add(zz, {PTr}), Nat.add({SK}, {FIXT}), {LLv}, eLF))')
    elif big_region:
        # a large fixed region: F last (vcont's F0-last lemmas); the fixed pieces' sum by Nat.is_eq
        SK = f'VCN.SUM({KS(ks_all)})'
        esr = (f'Equal.trans(Nat, VCN.SUM({MS}), Nat.add(Nat.add({SK}, {FIX}n), {PTr}), Nat.add({LLv}, {PTr}), '
               f'VCN.sum_region_r({FS}, {KS(ks_all)}, {PTr}, {FIX}n, FD.nat__eq_from_is_eq(VCN.SUM({FS}), {FIX}n, {{==}})), '
               f'Equal.cong(Nat, Nat, zz => Nat.add(zz, {PTr}), Nat.add({SK}, {FIX}n), {LLv}, eLF))')
    BS = (lambda a_, b_: f'Order.left_below_sum({b_}, {a_})') if big_region else (lambda a_, b_: f'Order.below_sum({a_}, {b_})')
    FA = lambda S: fadd(big_region, FIXT, S)  # noqa: E731
    RV = '_r' if big_region else ''
    # eLF: {SUM(ks) + F == LLC} (a parameter of putx_core, which holds F as a variable)
    LE = f', {LLv}, {KS(ks_all)}, {{==}}, {eLF}' if big_region else ''
    BSF = BS(FIXT, f'VCN.SUM({KS(ks_all)})')
    a(f'+hz0 = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({X0}, UA.BYT(D))) == UW.ZB(zz) : +List<U32>}}, Nat.add({LLv}, {PTr}), VCN.SUM({MS}), '
      f'Equal.sym(Nat, VCN.SUM({MS}), Nat.add({LLv}, {PTr}), {esr}), hz)')
    if big_pieces(st):
        # the region's pieces as a list of pieces (the list's spine only; no piece is unfolded)
        a(f'+I0r = VCN.reg_init(UA.BYT(D), {X0}, {MS}, hz0)')
        a(f'+I0 = FD.logic__subst(+List<+List<U32>>, zz => {{UA.BYT(D) == UW.SPL(UA.BYT(D), {X0}, VCN.CAT(zz)) : +List<U32>}}, VCN.ZBS({MS}), '
          f'VCN.LAP([], Con{{{st[0]}, [{", ".join(st[1:])}]}}), {{==}}, I0r)')
    else:
        a(f'+I0 = VCN.reg_init(UA.BYT(D), {X0}, {MS}, hz0)')
    a('+pf0 = pf')
    if u32m:
        # a fixed piece's end within F (vadd.lea on U32 constants, carried to F), F within LLC (hF, by eLF: LLC
        # states F at U32.to_nat(F), putx_core's F is a variable)
        SK = f'VCN.SUM({KS(ks_all)})'
        a(f'+hF = FD.logic__subst(Nat, zz => {{Nat.is_le({FIXT}, zz) == {TRUE}}}, Nat.add({SK}, {FIXT}), {LLv}, eLF, Order.left_below_sum({SK}, {FIXT}))')
        hle = lambda c_, v_, szt: (f'FD.nat__le_trans(Nat.add(U32.to_nat({c_}), {szt}), {FIXT}, {LLv}, '  # noqa: E731
                                   f'FD.logic__subst(Nat, zz => {{Nat.is_le(Nat.add(U32.to_nat({c_}), {szt}), zz) == {TRUE}}}, {UF}, {FIXT}, {eUF}, '
                                   f'AD.lea({c_}, {v_}, {FIX}, {szt}, {u_nat(v_, szt)}, {{==}}, {{==}})), hF)')
    facts = []
    curs = {}
    enc_of = {}
    szx_of = {}
    ec_of = {}
    vj = {f: j for j, f in enumerate(var)}
    nfix = K_fixed_count(pieces)
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        kind = ev['kind']
        UBk, UBn = BY(k), BY(k + 1)
        if (kind == 'leaf' and leaf_of(fs).sub) or (kind == 'off' and (ev['hoff'] % 4 or u32m)):
            _putx_subword_event(fidx, hle, FIX, X0, LLv, Mk, st, a, u32m, BSF, facts, f, k, ev, fs, kind, UBk, UBn)
            continue
        if kind in ('leaf', 'fixw', 'off'):
            i = fidx[f]
            c = ev['hoff']
            kw = c // 4
            size = 4 if kind == 'off' else fs.fsize
            pre = '[' + ', '.join(st[:i]) + ']'
            post = '[' + ', '.join(st[i + 1:]) + ']'
            pos = f'Nat.add(A.quad(Nat.add({kw}n, q)), r)'
            rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
            Xc = f'U32.add(X, {c})'
            qk, rk = qr_at(c)
            # the room a checked fixed writer asks for past its bytes (FixW.room_extra, e.g. vbv1281d's carry word)
            rsize = size + (getattr(K.fixw.get(f), 'room_extra', 0) if kind == 'fixw' else 0)
            bigp = big_pieces(st[:i])
            fwp = K.fixw.get(f) if kind == 'fixw' else None
            pk = fwp is not None and fwp.packed
            hzn = f'hz{k}'
            pos, hzn, hrk, eqpos = _putx_fixed_positions(FIX, X0, LLv, st, a, big_region, u32m, BSF, hle, f, k, UBk, i, c, size, pre, post, Xc, rel, pos, kw, qk, rk, rsize, bigp, pk, hzn)
            if kind == 'leaf' and leaf_of(fs).pad:
                _putx_padded_leaf(X0, Mk, st, a, facts, f, k, fs, UBk, UBn, i, pre, post, Xc, rel, pos, qk, rk, hrk, eqpos)
                continue
            Y, hY, piece, reg = _putx_fixed_piece(K, Mk, a, u32m, f, k, ev, fs, kind, size, Xc, qk, rk, pk, hzn, hrk)
            a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, {eqpos}), by{k})')
            a(f'+I{k + 1} = VCN.{reg}(UA.BYT(D), {X0}, {pre}, {size}n, {post}, {Y}, {UBk}, {UBn}, hX, I{k}, {hY}, hop{k})')
            st[i] = piece
            facts.append(f'rt{k}')
            continue
        # a variable field
        _putx_var_event(K, vidx, var, ks_all, FIX, X0, LLv, Mk, KS, st, a, PTr, big_region, u32m, FIXT, UF, eUF, FA, RV, LE, facts, curs, enc_of, szx_of, ec_of, vj, f, nfix, k, ev, UBk, UBn)
    n = len(events)
    EP = '[' + ', '.join(st[:-1]) + ']'
    ENCC = f'VCN.CAT({EP})'
    a(f'+ef = Equal.trans(+List<U32>, VCN.CAT(VCN.LAP({EP}, [UW.ZB({PTr})])), VCN.AP({ENCC}, VCN.CAT([UW.ZB({PTr})])), VCN.AP({ENCC}, UW.ZB({PTr})), '
      f'VCN.cat_lap({EP}, [UW.ZB({PTr})]), Equal.cong(+List<U32>, +List<U32>, zz => VCN.AP({ENCC}, zz), VCN.AP(UW.ZB({PTr}), []), UW.ZB({PTr}), VS.app_nil(UW.ZB({PTr}))))')
    a(f'+byf = FD.logic__subst(+List<U32>, zz => {{{BY(n)} == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VCN.CAT(VCN.LAP({EP}, [UW.ZB({PTr})])), VCN.AP({ENCC}, UW.ZB({PTr})), ef, I{n})')
    fl = var[-1]
    ksl = ks_all[:-1]
    pa = f'Nat.add({FA(f"VCN.SUM({KS(ksl)})")}, {ks_all[-1]})'
    a(f'+szf = VCN.cnext{RV}({curs[fl]}, {K.children[fl].sz}, {FIXT}, {KS(ksl)}, {ks_all[-1]}, dd, hd, {ec_of[fl]}, {szx_of[fl]}, '
      f'VCN.pc_end(q, r, {LLv}, dd, {pa}, VCN.pc_room{RV}({FIXT}, {KS(ksl)}, {ks_all[-1]}, []{LE}), hl))')
    if big_region:
        SA_ = f'Nat.add(VCN.SUM(VCN.APPN({KS(ksl)}, [{ks_all[-1]}])), {FIXT})'
        SKF_ = f'Nat.add(VCN.SUM({KS(ks_all)}), {FIXT})'
        a(f'+szf = Equal.trans(Nat, U32.to_nat(O.padd({curs[fl]}, {K.children[fl].sz})), {SA_}, {LLv}, szf, Equal.trans(Nat, {SA_}, {SKF_}, {LLv}, {{==}}, {eLF}))')
    # the checked fixed writers' flags (0) OR-ed into the size (narrow containers): peel them with or0r
    t_, layers = (SZC if K.pz is None else SZC[1:SZC.index(' .|. O.pz(')]), []
    while t_.startswith('(') and t_.endswith(' .|. 0 : U32)'):
        layers.append((t_[1:-len(' .|. 0 : U32)')], t_))
        t_ = layers[-1][0]
    for inner, outer in reversed(layers):
        a(f'+szf = FD.logic__subst(U32, zz => {{U32.to_nat(zz) == LLC({MA}) : Nat}}, {inner}, {outer}, Equal.sym(U32, U32.or({inner}, 0), {inner}, UWB.or0r({inner})), szf)')
    if K.pz is not None:
        a(f'+szf = FD.logic__subst(U32, zz => {{U32.to_nat(zz) == LLC({MA}) : Nat}}, {SZC[1:SZC.index(" .|. O.pz(")]}, SZC({OAS}), Equal.sym(U32, SZC({OAS}), {SZC[1:SZC.index(" .|. O.pz(")]}, szpz({OAS}, hpz)), szf)')
    body = '\n  '.join(ls)
    w(f'''
def ENCC({OPS}) -> +List<U32>: {ENCC}
def RTC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{K.p}_putn(FD.array__thaw(U32, D), X, OBJC({OAS})) == (FD.array__thaw(U32, PUTC({MA})), (OBJC({OAS}), SZC({OAS}))) : Array<U32> & (T.{K.C} & U32)}}
def BYC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTC({MA})) == UW.SPL(UA.BYT(D), {X0}, VCN.AP(ENCC({OAS}), UW.ZB(WD.PADB(r, LLC({MA}))))) : +List<U32>}}
def PFC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {{FD.array__perfect(U32, dd, PUTC({MA})) == {TRUE}}}
def SZXC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {{U32.to_nat(SZC({OAS})) == LLC({MA}) : Nat}}

# The four facts as one (built from variables, so no fact's proof term enters another's type).
def mk4({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +a: RTC({MA}), +b: BYC({MA}), +c: PFC({MA}), +d: SZXC({MA}))
    -> DK.P2(RTC({MA}), DK.P2(BYC({MA}), DK.P2(PFC({MA}), SZXC({MA})))):
  (a, (b, (c, d)))

# putx: the runtime's writer of {K.C} at X = 4 q + r is the model PUTC, whose bytes splice the
# container's bytes (and the zeros to the end of the last word) into D's, whose tree is perfect,
# and whose returned size is the byte count.
def putx({OPS}, {HPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LLC({MA})))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt(Nat.add(LLC({MA}), WD.PADB(r, LLC({MA}))), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(Nat.add(LLC({MA}), WD.PADB(r, LLC({MA})))) : +List<U32>}})
    -> DK.P2(RTC({MA}), DK.P2(BYC({MA}), DK.P2(PFC({MA}), SZXC({MA})))):
  {body}
  mk4({MA}, rt_all({MA}, {", ".join(facts + [f"hpz_g{gk_}" for gk_ in sorted(K.gpz)])}), byf, pf{n}, szf)
''')
    if u32m:
        L.insert(0, "\n# the lengths of the first pieces of the fixed part, as U32 sums (vpos32)\n" + eln_defs())
    return L


# ==== the container in the encoder-window interface, with its spec side (a separate module) ============
# proofs/obj/encx_<C>_iface.bend imports the container's writer module (as K) and states the
# container in codegen/proofs/var/progressive_small_list_codec_laws.py's ENCX interface: the mirror MW of the writer's parameters, OK
# (the writer's hypotheses as Bools, and the bytes within 2^30), TH, ENC, VAL, SZ, PUTX (at
# XQ(q, r) = U32.from_nat(4 q + r)), PADB, and the laws putx, putx_bytes, szx, encx_spec, domx, and
# pfx / sizex where the children allow. The value is the sequence of the field values (a fixed
# field's value read back from its words: spec_connected_codec_laws.walk; a byte vector held in a words tree:
# vconts.bvw; a child's VAL); its parts are the fields' parts (F.cat_fixed / VS.cat_var), their
# layout the offsets the writer writes (vua_lay.hdr_fp over the running offsets vconts.pstep),
# its encoding the writer's bytes ENCC (the pieces' cells, vcont.pc_id).

def spec_schema(C, generic):
    """(names text, [field schema texts]) of container C, as its spec states it (qualified by Spec.)."""
    fn = ROOT / ('proofs/obj/generic_specs.bend' if generic else 'spec/fulu_schemas.bend')
    src_ = fn.read_text()
    name = C
    while True:
        m = re.search(rf'^def {name}\(\) -> [ST]\.Schema: (.*)$', src_, re.M)
        body = m.group(1).strip()
        mm = re.fullmatch(r'(\w+)\(\)', body)
        if not mm:
            break
        name = mm.group(1)
    body = re.sub(r'\bT\.', 'S.', body)
    m = re.fullmatch(r'S\.(Container|ProgressiveContainer)\{(.*)\}', body)
    from codegen.proofs.var import block_body_offset_windows as WB
    top = WB.split_top(m.group(2))
    names_txt, ch = top[0].strip(), top[1].strip()
    kids = []
    while ch != 'S.End{}':
        a, b = WB.split_top(ch[len('S.Chain{'):-1])
        kids.append(a.strip())
        ch = b.strip()
    q = lambda s: re.sub(r'(?<![\w.])([A-Za-z]\w*)\(\)', r'Spec.\1()', s)
    return names_txt, [q(k) for k in kids], m.group(1)


def split_list(txt):
    from codegen.proofs.var import block_body_offset_windows as WB
    assert txt.startswith('[') and txt.endswith(']')
    return [x.strip() for x in WB.split_top(txt[1:-1])]


def szpeel(core, prf, end):
    """The size's proof {to_nat(core) == end} from the innermost one prf, peeling the checked fixed writers'
    flags (0) OR-ed onto it, (x .|. 0 : U32) layers, with vuw_bits.or0r."""
    t_, layers = core, []
    while t_.startswith('(') and t_.endswith(' .|. 0 : U32)'):
        layers.append((t_[1:-len(' .|. 0 : U32)')], t_))
        t_ = layers[-1][0]
    for inner, outer in reversed(layers):
        prf = (f'FD.logic__subst(U32, zz => {{U32.to_nat(zz) == {end} : Nat}}, {inner}, {outer}, '
               f'Equal.sym(U32, U32.or({inner}, 0), {inner}, UWB.or0r({inner})), {prf})')
    return prf


def child_max(ch):
    """The byte bound MX a child's module states (law maxx), or None."""
    if ch.p != 'bl32' and not getattr(ch, 'std', False) and not getattr(ch, 'alias', '').startswith('EC_'):
        return None
    m = re.match(r'import \./(\S+) as ', ch.mod or '')
    t = obj_text(ROOT / 'proofs/obj' / m.group(1)) if m else None
    if t is None:
        return None
    mm = re.search(r'^law maxx:\n.*\n.*\n  \{Nat\.is_le\(List\.length\(&2, U32, ENC\(m\)\), (\d+)n\) == True\{\} : Bool\}', t, re.M)
    return int(mm.group(1)) if mm else None


def _xwalk(SLW, g, t):
    # the walk in its exact forms (F.items_fixed / F.container_fixed, the layout total by VS.agg_total):
    # the older F.aggregate_fixed / F.cat_fixed steps made the checker evaluate the spec encoders
    # over the record's words (lvp_BeaconBlockHeader: 26M steps)
    old = SLW.EXACT, SLW.TOTAL
    SLW.EXACT, SLW.TOTAL = True, True
    try:
        return SLW.walk(g, t, iter(range(1000000)))
    finally:
        SLW.EXACT, SLW.TOTAL = old


def _iface_load(C, generic):
    """the object names, the writer's module and its put text, the encoding pieces and the field tables"""
    global SRC, SRC_FILE
    if generic:
        from codegen.core import generic_form_schemas as GN
        names = {n: t for n, t, err in GN.inventory_all() if err is None}
        if SRC_FILE != 'types/generic_obj.bend':
            SRC, SRC_FILE = None, 'types/generic_obj.bend'
    else:
        names = schema.load(ROOT / 'codegen/fulu.yaml')
        if SRC_FILE != 'types/fulu_obj.bend':
            SRC, SRC_FILE = None, 'types/fulu_obj.bend'
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC = module_text(g, names, C)
    RECF[C] = (OP, OA)
    LP = putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC)
    txt = '\n'.join(LP)
    ENCCB = re.search(r'^def ENCC\(.*?\) -> \+List<U32>: VCN\.CAT\((\[.*\])\)$', txt, re.M).group(1)
    EP = [re.sub(r'(?<![\w.])(RW_\w+)\(', r'K.\1(', x) for x in split_list(ENCCB)]
    # (U32 mode: the packed vectors' pieces at their U32.to_nat sizes, as the writer's ENCC states them)
    EP = [re.sub(r'^VCN\.PC\((\d+)n, ', lambda mm: f'VCN.PC({form_of(int(mm.group(1)))}, ', x) for x in EP]
    nv = len(var)
    fw, vw = EP[:len(EP) - nv], EP[len(EP) - nv:]
    F, FIX = K.F, K.fixed
    fsd = dict(F)
    tfs = dict(K.t.fields)
    return names, g, K, events, OBJF, OP, OA, HP, HA, SZC, EP, fw, vw, F, FIX, fsd, tfs


def _iface_spec_and_hyps(C, generic, OP, OA, HP, HA, F):
    """the container's spec schema and the writer's hypotheses as Bools"""
    names_txt, kids, kind = spec_schema(C, generic)
    assert len(kids) == len(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    TRUE_ = TRUE
    # the writer's hypotheses as Bools
    conj = []
    for h in HP:
        m = re.fullmatch(r'\+(\w+): \{(.*) == True\{\} : Bool\}', h)
        conj.append((m.group(1), re.sub(r'(?<![\w.])OK_(\w+)\(', r'K.OK_\1(', m.group(2))))
    # ---- the fields: value, schema, part, parts proof, bytes proof ----
    return names_txt, kids, kind, OPS, OAS, TRUE_, conj


def _iface_fields(SLW, names, g, K, events, F, tfs, kids):
    """the fields: value, schema, part, parts proof and bytes proof of each, with the lemmas of their leaves"""
    fields = []    # dict(kind, f, val, sch, part, prf, dom)
    lvs = {}
    L2 = []
    w = L2.append
    curs = {ev['field']: ev['cur'] for ev in events if ev['kind'] == 'var'}
    for i, (f, fs) in enumerate(F):
        sch = kids[i]
        if fs.fixed and fs.data and leaf_of(fs).tail:
            # Bitvector[257]: its value and parts (vbv257s), its bytes vbv257.BYW
            B_ = f'VCN.PC({4 * leaf_of(fs).W + 1}n, V_{fs.p}.BYW({f}))'
            prf_ = (f'FD.logic__subst(+List<U32>, zz => {{Codec.parts(V2S.V257({f}), {sch}) == Some{{[S.Fixed{{zz}}]}} : Maybe<&2, +List<S.Part>>}}, V_{fs.p}.BYW({f}), {B_}, '
                    f'Equal.sym(+List<U32>, {B_}, V_{fs.p}.BYW({f}), VCN.pc_id({4 * leaf_of(fs).W + 1}n, V_{fs.p}.BYW({f}), K.lenb_{fs.p}({f}))), V2S.prt257({f}, OKA_hv_{f}))')
            fields.append(dict(kind='fix', f=f, val=f'V2S.V257({f})', sch=sch, part=f'S.Fixed{{{B_}}}', bytes=B_, prf=prf_, psch=sch))
        elif fs.fixed and fs.data and leaf_of(fs).bits:
            n_ = leaf_of(fs).bits
            Y = f'[U32.and({f}, 255)]'
            fields.append(dict(kind='fix', f=f, val=f'VBB.V{n_}({f})', sch=sch, part=f'S.Fixed{{{Y}}}', bytes=Y,
                               prf=f'VBB.prt{n_}({f}, OKA_hv_{f})', psch=f'S.BitVector{{{n_}n}}'))
        elif fs.fixed and fs.data and leaf_of(fs).pad:
            lf_ = leaf_of(fs)
            Y = f'VS.bt(1n, FX.limbs(K.RW_{lf_.p}({f})))'
            # (its bytes as the writer's piece: VCN.PC(1n, Y))
            B_ = f'VCN.PC(1n, {Y})'
            prf_ = (f'FD.logic__subst(+List<U32>, zz => {{Codec.parts(VBo_{lf_.p}({f}), {sch}) == Some{{[S.Fixed{{zz}}]}} : Maybe<&2, +List<S.Part>>}}, {Y}, {B_}, '
                    f'Equal.sym(+List<U32>, {B_}, {Y}, VCN.pc_id(1n, {Y}, K.lenb_{lf_.p}({f}))), prto_{lf_.p}({f}, OKA_hv_{f}))')
            fields.append(dict(kind='fix', f=f, val=f'VBo_{lf_.p}({f})', sch=sch, part=f'S.Fixed{{{B_}}}', bytes=B_,
                               prf=prf_, psch='S.BitVector{4n}'))
        elif fs.fixed and fs.data and leaf_of(fs).sub:
            m_ = leaf_of(fs).sub
            Y = f'[U32.and({f}, 255)]' if m_ == 1 else f'[U32.and({f}, 255), U32.and(U32.shrn({f}, 8n), 255)]'
            fields.append(dict(kind='fix', f=f, val=f'VRB.UV{8 * m_}({f})', sch=sch, part=f'S.Fixed{{{Y}}}', bytes=Y,
                               prf=f'VRB.prt{8 * m_}({f})', psch=f'S.Unsigned{{P.U{8 * m_}{{}}}}'))
        elif fs.fixed and fs.data:
            _iface_fixed_words_field(SLW, g, tfs, fields, lvs, w, f, fs, sch)
        elif fs.fixed and not fs.data and fs.p in rvec_names():
            # a record vector (fixed_record_encoder_windows.RVECS): its value, bytes and parts from its module (vspec)
            a_ = K.fixw[f].alias
            E_, B_ = f'{a_}.ENC(m_{f})', f'VCN.PC({fs.fsize}n, {a_}.ENC(m_{f}))'
            prf_ = (f'FD.logic__subst(+List<U32>, zz => {{Codec.parts({a_}.VAL(m_{f}), {sch}) == Some{{[S.Fixed{{zz}}]}} : Maybe<&2, +List<S.Part>>}}, {E_}, {B_}, '
                    f'Equal.sym(+List<U32>, {B_}, {E_}, VCN.pc_id({fs.fsize}n, {E_}, {a_}.lenv(m_{f}, OKA_hok_{f}))), {a_}.vspec(m_{f}, OKA_hok_{f}))')
            fields.append(dict(kind='fix', f=f, val=f'{a_}.VAL(m_{f})', sch=sch, part=f'S.Fixed{{{B_}}}', bytes=B_, prf=prf_, psch=sch))
        elif f in K.fixw and fs.kind == 'fixwords' and fs.p in ('bv1280', 'bv1281'):
            # the word-held bit vectors of the generic containers (vbv128s)
            fw8 = K.fixw[f]
            nB = fs.fsize
            B_ = f'VCN.PC({nB}n, {fw8.Y})'
            if fs.p == 'bv1281':
                val = f'V2S8.V1281(TB_{f})'
                hY_ = f'V_bv1281.lenY(dB_{f}, TB_{f}, OKA_pfB_{f}, OKA_hrB_{f})'
                prt_ = f'V2S8.prt1281(dB_{f}, TB_{f}, OKA_pfB_{f}, OKA_hdB_{f}, OKA_hrB_{f}, OKA_hbz_{f})'
            else:
                val = f'V2S8.V1280(TB_{f})'
                hY_ = re.sub(r'(?<![\w_])(pfB|hrB)_' + f, lambda mm: 'OKA_' + mm.group(0), fw8.hY)
                prt_ = f'V2S8.prt1280(dB_{f}, TB_{f}, OKA_pfB_{f}, OKA_hrB_{f})'
            fields.append(dict(kind='fix', f=f, val=val, sch=sch, part=f'S.Fixed{{{B_}}}', bytes=B_, psch=sch,
                               prf=f'CS.pcfix({val}, {sch}, {fw8.Y}, {nB}n, {hY_}, {prt_})'))
        elif fs.fixed and fs.kind == 'fixwords':
            nW = fs.fsize // 4
            by = f'VCN.PC(A.quad({nW}n), CS.WT({nW}n, TB_{f}))'
            fields.append(dict(kind='fix', f=f, val=f'S.BytesValue{{CS.WT({nW}n, TB_{f})}}', sch=sch, part=f'S.Fixed{{{by}}}', bytes=by,
                               prf=f'CS.bvw({nW}n, dB_{f}, TB_{f}, OKA_pfB_{f}, OKA_hrB_{f}, {{==}}, {{==}})', psch=f'S.ByteVector{{A.quad({nW}n)}}'))
        elif f in K.fixw:
            fields.append(fixw_spec_field(g, names, K.fixw[f], f, fs, sch))
        else:
            ch = K.children[f]
            d = dict(kind='var', f=f, sch=sch, enc=ch.enc, sz=ch.sz, cur=curs[f])
            if ch.p == 'bl32' or getattr(ch, 'std', False):
                a = 'EB' if ch.p == 'bl32' else ch.alias
                m_ = f'm_{f}'
                d.update(val=f'{a}.VAL({m_})', prf=f'{a}.encx_spec({m_}, OKA_hok_{f})', szx=f'{a}.szx({m_}, OKA_hok_{f})', pfx=f'{a}.pfx({m_}, dd, @D, @Q, @R, @PF)')
            elif ch.p == 'l1048576_bl1073741824':
                t_, N_ = ch.oargs
                d.update(val=f'ET.VALL({t_}, {N_})', prf=f'ET.encx_spec({t_}, {N_}, OKA_h_{f}, k, CS.hk30(k, ek), @HLL)',
                         szx=f'Equal.trans(Nat, U32.to_nat(ET.SZW({t_}, {N_})), ET.LL({t_}, {N_}), LY.LN(ET.ENCL({t_}, {N_})), ET.szx({t_}, {N_}, OKA_h_{f}, 2n+k, CS.ek2(k, ek), @HLL), Equal.sym(Nat, LY.LN(ET.ENCL({t_}, {N_})), ET.LL({t_}, {N_}), ET.len_encl({t_}, {N_})))',
                         pfx=None, LL=f'ET.LL({t_}, {N_})', hY=f'ET.len_encl({t_}, {N_})')
            else:
                A_, N_ = ch.oargs
                a, p = ch.alias, ch.p
                d.update(val=f'{a}.VALL_{p}({A_}, {N_})', prf=f'{a}.encx_spec_{p}({A_}, {N_}, OKA_h_{f}, k, CS.hk30(k, ek), @HLL)',
                         szx=f'Equal.trans(Nat, U32.to_nat({ch.sz}), {a}.LL_{p}({A_}, {N_}), LY.LN({ch.enc}), {a}.szx_{p}({A_}, {N_}, 0n, 0n, k, CS.hk29(k, ek), VRX.nwn_le({a}.LL_{p}({A_}, {N_}), VB.pw(k), @HLL)), Equal.sym(Nat, LY.LN({ch.enc}), {a}.LL_{p}({A_}, {N_}), {a}.len_encl_{p}({A_}, {N_})))',
                         pfx=f'{a}.pfLb_{p}(U32.is_eq({N_}, 0), {A_}, {N_}, dd, @D, @Q, @R, @PF)', LL=f'{a}.LL_{p}({A_}, {N_})', hY=f'{a}.len_encl_{p}({A_}, {N_})')
                if getattr(ch, 'xform', False):
                    d['pfx'] = f'{a}.pfLb_{p}(U32.is_eq({N_}, 0), {A_}, {N_}, dd, @D, @X, @PF)'
            d['part'] = f'S.Variable{{{ch.enc}}}'
            d['bytes'] = ch.enc
            fields.append(d)
    return fields, L2, w


def _iface_fixed_words_field(SLW, g, tfs, fields, lvs, w, f, fs, sch):
    """a fixed field of words: its value, parts and bytes, with the leaf's value lemmas written once"""
    lf = leaf_of(fs)
    if lf.p not in lvs:
        nd = _xwalk(SLW, g, tfs[f])
        ren = {x: f'w{j}' for j, x in enumerate(nd.words)}
        sub = lambda s: re.sub(r'\bx(\d+)\b', lambda mm: ren[mm.group(0)], s)
        fx = lambda s: re.sub(r'(?<![\w.])F\.', 'FX.', s)
        ws = [f'w{j}' for j in range(lf.W)]
        pat = f'{lf.ctor}{{' + ', '.join('+' + x for x in ws) + '}'
        B = 4 * lf.W
        if lf.rec is not None:
            # a fixed record: nested matches expose its words (execution_requests_encoder_laws.nest), named as walk names them
            from codegen.proofs.var import execution_requests_encoder_laws as EN
            words = []
            ls, ind = EN.nest(lf.rec, 'o', words, 2)
            assert words == nd.words, (words[:4], nd.words[:4])
            bodyn = '\n'.join(ls)
            padn = ' ' * ind
            w(f'''
# ---- {lf.p}: its value, read back from its words, and its parts (a fixed record) ----
def LV_{lf.p}(o: {lf.ctor}) -> S.Value:
{bodyn}
{padn}{fx(nd.val)}
# its value by its body (LV_{lf.p} of the rebuilt record against the walk's value under Codec.parts evaluated the parts)
def lvq_{lf.p}({", ".join(f"+{x}: U32" for x in nd.words)}) -> {{{fx(nd.val)} == LV_{lf.p}({fx(nd.obj)}) : S.Value}}: {{==}}
def lvp_{lf.p}(+o: {lf.ctor}) -> {{Codec.parts(LV_{lf.p}(o), {fx(nd.sch)}) == Some{{[S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}(o)))}}]}} : Maybe<&2, +List<S.Part>>}}:
{bodyn}
{padn}%lvq_{lf.p}({", ".join(nd.words)}) : {{Codec.parts(_, {fx(nd.sch)}) == Some{{[S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}({fx(nd.obj)})))}}]}} : Maybe<&2, +List<S.Part>>}}
{padn}CS.pcfix({fx(nd.val)}, {fx(nd.sch)}, FX.limbs([{", ".join(nd.words)}]), {B}n, {{==}}, {fx(nd.proof)})
''')
        else:
            w(f'''
# ---- {lf.p}: its value, read back from its words, and its parts ----
def LV_{lf.p}(o: {lf.ctor}) -> S.Value:
  match o:
    case {pat}: {fx(sub(nd.val))}
# its value by its body (LV_{lf.p} against the walk's value under Codec.parts would evaluate the parts)
def lvq_{lf.p}({", ".join(f"+{x}: U32" for x in ws)}) -> {{{fx(sub(nd.val))} == LV_{lf.p}({lf.ctor}{{{", ".join(ws)}}}) : S.Value}}: {{==}}
def lvp_{lf.p}(+o: {lf.ctor}) -> {{Codec.parts(LV_{lf.p}(o), {fx(nd.sch)}) == Some{{[S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}(o)))}}]}} : Maybe<&2, +List<S.Part>>}}:
  match o:
    case {pat}:
      %lvq_{lf.p}({", ".join(ws)}) : {{Codec.parts(_, {fx(nd.sch)}) == Some{{[S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}({lf.ctor}{{{", ".join(ws)}}})))}}]}} : Maybe<&2, +List<S.Part>>}}
      CS.pcfix({fx(sub(nd.val))}, {fx(nd.sch)}, FX.limbs([{", ".join(ws)}]), {B}n, {{==}}, {fx(sub(nd.proof))})
''')
        lvs[lf.p] = (fx(nd.sch), B)
        assert fx(nd.sch) == sch or True
    lsch, B = lvs[lf.p]
    part = f'S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}({f})))}}'
    fields.append(dict(kind='fix', f=f, val=f'LV_{lf.p}({f})', sch=sch, part=part, bytes=f'VCN.PC({B}n, FX.limbs(K.RW_{lf.p}({f})))',
                       prf=f'lvp_{lf.p}({f})', psch=lsch))


def _iface_chain(C, FIX, names_txt, kids, kind, OPS, OAS, TRUE_, conj, fields):
    """the container's value chain, its offsets and the conjuncts of its facts"""
    n = len(fields)
    PS = '[' + ', '.join(x['part'] for x in fields) + ']'
    VV = [x for x in fields if x['kind'] == 'var']
    OS = '[' + ', '.join(x['cur'] for x in VV) + ']'
    # the running offsets o_j and the bound's chain
    os_ = [f'{FIX}n']
    for x in VV:
        os_.append(f'Nat.add({os_[-1]}, LY.LN({x["enc"]}))')
    END = os_[-1]
    SCH = f'Spec.{C}()'

    def items(i):
        return 'S.EmptyItems{}' if i == n else f'S.Items{{{fields[i]["val"]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == n else f'S.Chain{{{kids[i]}, {chain(i + 1)}}}'

    # the OK conjuncts: the writer's hypotheses, then the bound
    # (U32 mode: the bound on ENDC by name, so okbk and the bound's users compare it syntactically)
    CJ = [c for _, c in conj] + [f'Nat.is_le({f"ENDC({OAS})" if U32M else END}, A.quad(VB.pw(28n)))']
    CN = [nm for nm, _ in conj] + ['bnd']

    def conjt(i):
        return CJ[i] if i == len(CJ) - 1 else f'Bool.and({CJ[i]}, {conjt(i + 1)})'
    acc = []
    for i in range(len(CJ) - 1):
        src_ = 'h' if i == 0 else f'okr{i}({OAS}, h)'
        acc.append(f'def okr{i + 1}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{conjt(i + 1)} == {TRUE_}}}: and_r({CJ[i]}, {conjt(i + 1)}, {src_})')
    for i in range(len(CJ)):
        src_ = 'h' if i == 0 else f'okr{i}({OAS}, h)'
        if i == len(CJ) - 1:
            acc.append(f'def ok_{CN[i]}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{CJ[i]} == {TRUE_}}}: {src_}')
        else:
            acc.append(f'def ok_{CN[i]}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{CJ[i]} == {TRUE_}}}: and_l({CJ[i]}, {conjt(i + 1)}, {src_})')
    OKA = lambda s: re.sub(r'OKA_(\w+)', lambda mm: f'ok_{mm.group(1)}({OAS}, h)', s)
    HA2 = ', '.join(f'ok_{nm}({OAS}, h)' for nm, _ in conj)
    ENCCt = f'K.ENCC({OAS})'
    return n, PS, VV, OS, os_, END, SCH, items, chain, conjt, acc, OKA, HA2, ENCCt


def _iface_size_laws(C, generic, n, K, SZC, fw, vw, FIX, OPS, OAS, TRUE_, fields, w, PS, VV, OS, os_, END, items, chain, conjt, acc, OKA):
    """the size laws: the encoding's length, the offsets' bounds and the bytes of each variable part"""
    w(f'''
# ---- {C}: its value, parts, layout, and bytes ----

{f"def ENDC({OPS}) -> Nat: {END}{chr(10)}" if U32M else ""}def OKT({OPS}) -> Bool: {conjt(0)}
{chr(10).join(acc)}

def VALC({OPS}) -> S.Value: S.Sequence{{{items(0)}}}
def PSC({OPS}) -> +List<S.Part>: {PS}
def OSC({OPS}) -> +List<U32>: {OS}
{"" if U32M else f"def ENDC({OPS}) -> Nat: {END}{chr(10)}"}
# the bound with its exponent symbolic (k = 28)
def okbk({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{Nat.is_le(ENDC({OAS}), A.quad(VB.pw(k))) == {TRUE_}}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(ENDC({OAS}), A.quad(VB.pw(z))) == {TRUE_}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), ok_bnd({OAS}, h))
''')
    # the bounds o_{j+1} <= 4 2^k, j = n_v .. 1
    Q = 'A.quad(VB.pw(k))'
    hb = {len(VV): f'okbk({OAS}, h, k, ek)'}
    for j in range(len(VV) - 1, 0, -1):
        hb[j] = f'CS.lel({os_[j]}, LY.LN({VV[j]["enc"]}), {Q}, {hb[j + 1]})'
    HLL = {j: f'CS.ler({os_[j]}, LY.LN({VV[j]["enc"]}), {Q}, {hb[j + 1]})' for j in range(len(VV))}
    # LL-form bound for ET / EW children: LL <= 4 2^k
    for j, x in enumerate(VV):
        if 'LL' in x:
            HLL[j] = f'FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE_}}}, LY.LN({x["enc"]}), {x["LL"]}, {x["hY"]}, {HLL[j]})'
    for j, x in enumerate(VV):
        for key in ('prf', 'szx'):
            x[key] = x[key].replace('@HLL', HLL[j])
    # the offsets: to_nat(cur_j) == o_j
    # (a big container's first offset is a large literal: its equation by Nat.is_eq, not by unfolding it)
    eo = [f'FD.nat__eq_from_is_eq(U32.to_nat({FIX}), {FIX}n, {{==}})' if big_sizes(C, generic) else '{==}']
    for j, x in enumerate(VV):
        eo.append(f'CS.pstep({x["cur"]}, {x["sz"]}, {os_[j]}, LY.LN({x["enc"]}), k, CS.hk29(k, ek), {eo[j]}, {x["szx"]}, {hb[j + 1]})')
    OKO = '(' + ', ('.join(eo[j] for j in range(len(VV))) + ', Unit{}' + ')' * len(VV) if VV else 'Unit{}'
    # the parts of the items
    def cat(i):
        if i == n:
            return '{==}'
        x = fields[i]
        rest = '[' + ', '.join(y['part'] for y in fields[i + 1:]) + ']'
        fn_ = 'FX.cat_fixed' if x['kind'] == 'fix' else 'VS.cat_var'
        return (f'{fn_}(Codec.parts({x["val"]}, {x["sch"]}), {x["bytes"]}, Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest},\n    {OKA(x["prf"])}, {cat(i + 1)})')
    # bytes_valid(PS): each part's bytes are bytes
    def bv(i):
        if i == n:
            return '{==}'
        x = fields[i]
        rest = '[' + ', '.join(y['part'] for y in fields[i + 1:]) + ']'
        dm = 'CS.domf' if x['kind'] == 'fix' else 'CS.domv'
        sch_ = x.get('psch', x['sch']) if x['kind'] == 'fix' else x['sch']
        return (f'FD.logic__and_intro(SP.bytes_domain({x["bytes"]}), Layout.bytes_valid({rest}), {dm}({x["val"]}, {sch_}, {x["bytes"]}, {{==}}, {OKA(x["prf"])}),\n    {bv(i + 1)})')
    # the variable pieces' cells are their bytes
    rw = []
    for j, x in enumerate(VV):
        k0 = len(fw) + j
        cells = [(f'_' if jj == j else (y['enc'] if jj < j else vw[jj])) for jj, y in enumerate(VV)]
        hY = x.get('hY', '{==}')
        ch = K.children[x['f']]
        rw.append(f'  %Equal.sym(+List<U32>, {vw[j]}, {x["enc"]}, VCN.pc_id({ch.len}, {x["enc"]}, {hY})) :\n    {{VCN.AP(VCN.CAT([{", ".join(fw)}]), VCN.CAT([{", ".join(cells)}])) == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}')
    if getattr(K, 'pz', None) is not None:
        SZCORE = SZC[1:SZC.index(' .|. O.pz(')]
        ESZ = f'K.szpz({OAS}, ok_hpz({OAS}, h))'
    else:
        SZCORE, ESZ = SZC, f'eSZ({OAS}, Unit{{}})'
        # the checked fixed writers' flags (.|. 0) peeled with UWB.or0r
        while SZCORE.startswith('(') and SZCORE.endswith(' .|. 0 : U32)'):
            inner = SZCORE[1:-len(' .|. 0 : U32)')]
            ESZ = f'Equal.trans(U32, K.SZC({OAS}), {SZCORE}, {inner}, {ESZ}, UWB.or0r({inner}))'
            SZCORE = inner
    if U32M:
        # the packed vectors' parts, each its own lemma (their literal side conditions evaluated at the top)
        for x in fields:
            if x['kind'] == 'fix' and 'WU.' in x['prf']:
                w(f'def fps_{x["f"]}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}})\n'
                  f'    -> {{Codec.parts({x["val"]}, {x["sch"]}) == Some{{[S.Fixed{{{x["bytes"]}}}]}} : Maybe<&2, +List<S.Part>>}}:\n  {OKA(x["prf"])}\n')
                x['prf'] = f'fps_{x["f"]}({OAS}, h)'
    return eo, OKO, cat, bv, rw, SZCORE, ESZ


def _iface_writer_laws(K, SZC, EP, fw, vw, FIX, OPS, OAS, TRUE_, w, VV, SCH, items, chain, ENCCt, eo, OKO, cat, bv, rw, SZCORE, ESZ):
    """the writer's laws over the concatenated parts"""
    w(f'''
def partsC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}})
    -> {{Codec.parts({items(0)}, {chain(0)}) == Some{{PSC({OAS})}} : Maybe<&2, +List<S.Part>>}}:
  {cat(0)}

def validC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{Layout.bytes_valid(PSC({OAS})) == {TRUE_}}}:
  {bv(0)}

# the offsets the writer writes are the layout's
def okoC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> LY.OKO(PSC({OAS}), {FIX}n, OSC({OAS})):
  {OKO}

# the returned size is the bytes' end
def eSZ({OPS}, +u: Unit) -> {{K.SZC({OAS}) == {SZC} : U32}}: {{==}}
def szC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{U32.to_nat(K.SZC({OAS})) == ENDC({OAS}) : Nat}}:
  FD.logic__subst(U32, z => {{U32.to_nat(z) == ENDC({OAS}) : Nat}}, {SZCORE}, K.SZC({OAS}), Equal.sym(U32, K.SZC({OAS}), {SZCORE}, {ESZ}),
    {szpeel(SZCORE, eo[-1], f'ENDC({OAS})')})

# the writer's bytes: the fixed region (the layout's header), then the payloads
def eENC({OPS}, +u: Unit) -> {{{ENCCt} == VCN.CAT([{", ".join(EP)}]) : +List<U32>}}: {{==}}
def eLLC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> {{K.LLC({OAS}, dd, D, X, q, r) == Nat.add({FIX}n, VCN.SUM([{", ".join(K.children[x["f"]].len for x in VV)}])) : Nat}}: {{==}}
def cellsC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{ENCCt} == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}:
  %Equal.sym(+List<U32>, {ENCCt}, VCN.CAT([{", ".join(EP)}]), eENC({OAS}, Unit{{}})) :
    {{_ == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}
  %Equal.sym(+List<U32>, VCN.CAT([{", ".join(EP)}]), VCN.AP(VCN.CAT([{", ".join(fw)}]), VCN.CAT([{", ".join(vw)}])), VCN.cat_lap([{", ".join(fw)}], [{", ".join(vw)}])) :
    {{_ == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}
''' + '\n'.join(rw) + '\n  {==}\n' + TEMPLATES.render('_iface_writer_laws', OPS=OPS, OAS=OAS, TRUE_=TRUE_, ENCCt=ENCCt, FIX=FIX, SCH=SCH, items=items, chain=chain, VV=VV, K=K, EP=EP, fw=fw))


def _iface_mw_text(C, K, OP, OA, OPS, OAS, TRUE_, HA2, ENCCt):
    """the interface's record type and the first group of its laws"""
    MWF = ', '.join(x.lstrip('+') for x in OP)
    MP = 'MW{' + ', '.join('+' + a for a in OA) + '}'
    MA = f'{OAS}, dd, D, XQ(q, r), q, r'
    ifc = TEMPLATES.render('_iface_mw_text', C=C, MWF=MWF, MP=MP, OAS=OAS, ENCCt=ENCCt, MA=MA, OPS=OPS, K=K, TRUE_=TRUE_, HA2=HA2)
    return MP, ifc


def _iface_hyps_text(C, K, OAS, SCH, ENCCt, MP, ifc):
    """the hypotheses of the interface and the rest of its laws"""
    HYPS = '''  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
'''.replace('@TR', TR)
    ifc += TEMPLATES.render('_iface_hyps_text', HYPS=HYPS, K=K, C=C, MP=MP, OAS=OAS, ENCCt=ENCCt, SCH=SCH)
    return ifc


def _iface_child_max(K, FIX, OPS, OAS, TRUE_, VV, ENCCt, MP, ifc):
    """the children's maxima and the bound derived from them"""
    mxs = [child_max(K.children[x['f']]) for x in VV]
    if VV and all(v is not None for v in mxs):
        steps, cur, B_ = [], f'{FIX}n', FIX
        prf = '{==}'
        for x, mx in zip(VV, mxs):
            ch = K.children[x['f']]
            ln = f'LY.LN({x["enc"]})'
            nxt = f'Nat.add({cur}, {ln})'
            prf = (f'FD.nat__le_trans({nxt}, Nat.add({B_}n, {ln}), {B_ + mx}n, Order.add_right({cur}, {B_}n, {ln}, {prf}), '
                   f'Order.add_left({B_}n, {ln}, {mx}n, {"EB" if ch.p == "bl32" else ch.alias}.maxx(m_{x["f"]}, ok_hok_{x["f"]}({OAS}, h))))')
            cur, B_ = nxt, B_ + mx
        ifc += TEMPLATES.render('_iface_child_max', OPS=OPS, OAS=OAS, TRUE_=TRUE_, B_=B_, prf=prf, MP=MP, ENCCt=ENCCt)
    return ifc


def _iface_events_pf(K, events, fsd, OAS, fields):
    """the events' perfect-tree proofs"""
    MAk = f'{OAS}, dd, D, XQ(q, r), q, r'
    Mk = lambda k: f'K.M{k}({MAk})'
    pfs, okpf = 'pf', True
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf' and leaf_of(fs).sub:
            pfs = f'{leaf_of(fs).pf}(dd, {Mk(k)}, XQ(q, r), {ev["hoff"]}, {f}, {pfs})'
        elif ev['kind'] == 'off' and (ev['hoff'] % 4 or U32M):
            Xc_ = f'U32.add(XQ(q, r), {ev["hoff"]})'
            pfs = f'WD.w32x_perfect(VCN.RX({Xc_}), dd, {Mk(k)}, VCN.QX({Xc_}), {ev["cur"]}, {pfs})'
        elif ev['kind'] == 'leaf':
            qk_, rk_ = qr_at(ev['hoff'], 'XQ(q, r)')
            pfs = f'K.pfo_{leaf_of(fs).p}({f}, dd, {Mk(k)}, {qk_}, {rk_}, {pfs})'
        elif ev['kind'] == 'fixw':
            qk_, rk_ = qr_at(ev['hoff'], 'XQ(q, r)')
            pfs = K.fixw[f].pf(rk_, Mk(k), qk_, pfs)
        elif ev['kind'] == 'off':
            pfs = f'WD.w32x_perfect(r, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), {ev["cur"]}, {pfs})'
        else:
            x = [y for y in fields if y['f'] == f][0]
            if not x.get('pfx'):
                okpf = False
                break
            Xc = f'U32.add(XQ(q, r), {ev["cur"]})'
            pfs = x['pfx'].replace('@D', Mk(k)).replace('@Q', f'VCN.QX({Xc})').replace('@R', f'VCN.RX({Xc})').replace('@X', Xc).replace('@PF', pfs)


def _iface_rt_chain(rq, cs, K, OBJF, F, OAS, VV):
    """the round-trip chain of the interface"""
    szx_ok = not K.wide
    RTS = ''
    if szx_ok:
        def rq(t):
            return re.sub(r'(?<![\w.])(?!(?:True|False|Some|None|Con|Nil)\b)([A-Za-z_]\w*)(?=[({])', r'T.\1', t)
        cs = {}
        for x in VV:
            ch = K.children[x['f']]
            if ch.p == 'bl32' or getattr(ch, 'std', False):
                a = 'EB' if ch.p == 'bl32' else ch.alias
                sa = getattr(ch, 'szalias', None)
                szp = f'{sa}.sizez(m_{x["f"]}, @HOK)' if sa else f'{a}.sizex(m_{x["f"]}, @HOK)'
                vap = f'{sa or a}.validx(m_{x["f"]}, @HOK)'
                if getattr(ch, 'box', None):
                    # a boxed child: T.<B>_bx_size / _bx_valid unwrap the box and rebox through _bx_size_back / _bx_va_back
                    B, th = ch.box, f'{a}.TH(m_{x["f"]})'
                    szp = f'Equal.cong(T.{B} & U32, O.Boxed<T.{B}> & U32, z => T.{B}_bx_size_back(z), T.{B}_size({th}), ({th}, {ch.sz}), {szp})'
                    vap = f'Equal.cong(T.{B} & Bool, O.Boxed<T.{B}> & Bool, z => T.{B}_bx_va_back(z), T.{B}_valid({th}), ({th}, True{{}}), {vap})'
                cs.setdefault(ch.p, []).append((szp, ch.vt, ch.obj, ch.sz, f'ok_hok_{x["f"]}', vap))
            elif ch.p == 'l1048576_bl1073741824':
                szx_ok = False
            else:
                A_, N_ = ch.oargs
                cs.setdefault(ch.p, []).append((f'{ch.alias}.sizex_{ch.p}({A_}, {N_}, @HOK)', ch.vt, ch.obj, ch.sz, f'ok_h_{x["f"]}', f'{ch.alias}.valid_{ch.p}({A_}, {N_}, @HOK)'))
        # the record vectors (fixed_record_encoder_windows.RVECS): their storage check, FixW.valid on the OK accessors
        for f_, fw_ in K.fixw.items():
            if fw_.p in rvec_names():
                vt_ = fw_.valid([f'ok_{hn}({OAS}, h)' for hn in fw_.hargs])
                cs.setdefault(fw_.p, []).append((None, fw_.vt, fw_.obj, None, None, vt_))
    def chain_rt(entry, result_t, final_rhs, pair_second):
        """The runtime's pass `entry` (size / valid) over the children, each child's call rewritten by its law."""
        # a `_valid` that also tests the size pass (R4-05) proves its fields' part `_valid_f` here (validx adds the size)
        body_ = fn_body(f'{K.p}_{entry}_f' if entry == 'valid' and has_valid_f(K.p) else f'{K.p}_{entry}')
        mm = re.search(r'case (\w+)\{([^}]*)\}: (.*)$', body_, re.M)
        pv = [v.strip().lstrip('+') for v in mm.group(2).split(',')]
        sub = dict(zip(pv, [OBJF[f] for f, _ in F]))

        def subst(t, d):
            return re.sub(r'(?<![\w.])([A-Za-z_]\w*)\b(?![({])', lambda z: d.get(z.group(1), z.group(1)), t)
        cur = rq(subst(mm.group(3).strip(), sub))
        steps = []
        if entry == 'valid' and getattr(K, 'pz', None) is not None and K.pz in cur:
            steps.append(f'  %Equal.sym(Bool, {K.pz}, True{{}}, ok_hpz({OAS}, h)) :\n    {{{cur.replace(K.pz, "_", 1)} == {final_rhs} : {result_t}}}')
            cur = cur.replace(K.pz, 'True{}', 1)
        while True:
            m2 = re.fullmatch(r'T\.(\w+_(?:sz|va)\d+)\((.*)\)', cur)
            if not m2:
                break
            fname, args = m2.group(1), [a.strip() for a in __import__('codegen.proofs.var.block_body_offset_windows', fromlist=['_']).split_top(m2.group(2))]
            last = args[-1]
            m3 = re.fullmatch(rf'T\.(\w+?)_{entry}(?:_f)?\((.*)\)', last)   # (a wrapped list child: its fields' validity `_valid_f`, R4-05)
            if not m3 or m3.group(1) not in cs:
                return None
            cp, V = m3.group(1), m3.group(2)
            # children of one type are told apart by their object term
            cands = [c for c in cs[cp] if c[2] == V] if len(cs[cp]) > 1 else cs[cp]
            if len(cands) != 1:
                return None
            vt, SZj, hokn = cands[0][1], cands[0][3], cands[0][4]
            prf = cands[0][0] if entry == 'size' else cands[0][5]
            if entry == 'valid' and re.fullmatch(rf'T\.\w+?_valid_f\(.*\)', last):
                prf = prf.replace('.validx(', '.validx_f(')   # (a wrapped list child: its fields' validity law, R4-05)
            second = SZj if entry == 'size' else 'True{}'
            ctx = f'T.{fname}(' + ', '.join(args[:-1] + ['_']) + ')'
            steps.append(f'  %Equal.sym({vt} & {pair_second}, {last}, ({V}, {second}), {prf.replace("@HOK", f"{hokn}({OAS}, h)")}) :\n    {{{ctx} == {final_rhs} : {result_t}}}')
            fb = fn_body(fname)
            params = fn_params(fname)
            d = dict(zip(params, args[:-1] + [None]))
            m4 = re.search(r'\((\+?\w+), \+?(\w+)\) = pair\n\s*(.*)$', fb, re.S)
            d[m4.group(1).lstrip('+')] = V
            d[m4.group(2)] = second
            nxt = m4.group(3).strip().split('\n')[0].strip()
            cur = rq(subst(nxt, {k_: v_ for k_, v_ in d.items() if v_ is not None}))
        return '\n'.join(steps) + '\n  {==}'
    return rq, cs, szx_ok, RTS, chain_rt


def _iface_rtv(C, K, OBJF, SZC, F, OAS, szx_ok, RTS, rq, cs, chain_rt):
    """the round-trip value statement"""
    RTV = None
    if szx_ok:
        RTV = chain_rt('valid', f'T.{C} & Bool', f'(K.OBJC({OAS}), True{{}})', 'Bool')
    if szx_ok:
        body_ = fn_body(f'{K.p}_size')
        mm = re.search(r'case (\w+)\{([^}]*)\}: (.*)$', body_, re.M)
        pv = [v.strip().lstrip('+') for v in mm.group(2).split(',')]
        sub = dict(zip(pv, [OBJF[f] for f, _ in F]))

        def subst(t, d):
            return re.sub(r'(?<![\w.])([A-Za-z_]\w*)\b(?![({])', lambda z: d.get(z.group(1), z.group(1)), t)
        cur = rq(subst(mm.group(3).strip(), sub))
        steps = []
        SZR0 = None
        if getattr(K, 'pz', None) is not None:
            core_ = SZC[1:SZC.index(' .|. O.pz(')]
            steps.append(f'  %Equal.sym(U32, K.SZC({OAS}), {core_}, K.szpz({OAS}, ok_hpz({OAS}, h))) :\n    {{T.{K.p}_size(K.OBJC({OAS})) == (K.OBJC({OAS}), _) : T.{C} & U32}}')
        elif SZC.endswith(' .|. 0 : U32)'):
            # the checked fixed writers' flags (.|. 0): the size pass returns the core
            core_, prf_ = SZC, f'eSZ({OAS}, Unit{{}})'
            while core_.startswith('(') and core_.endswith(' .|. 0 : U32)'):
                inner = core_[1:-len(' .|. 0 : U32)')]
                prf_ = f'Equal.trans(U32, K.SZC({OAS}), {core_}, {inner}, {prf_}, UWB.or0r({inner}))'
                core_ = inner
            steps.append(f'  %Equal.sym(U32, K.SZC({OAS}), {core_}, {prf_}) :\n    {{T.{K.p}_size(K.OBJC({OAS})) == (K.OBJC({OAS}), _) : T.{C} & U32}}')
            SZR0 = core_
        # the pz case: its core's checked fixed writers' flags (0), peeled with or0r
        t_, peeled = SZC, False
        if getattr(K, 'pz', None) is not None:
            t_ = SZC[1:SZC.index(' .|. O.pz(')]
            while t_.startswith('(') and t_.endswith(' .|. 0 : U32)'):
                in_ = t_[1:-len(' .|. 0 : U32)')]
                steps.append(f'  %Equal.sym(U32, U32.or({in_}, 0), {in_}, UWB.or0r({in_})) :\n    {{T.{K.p}_size(K.OBJC({OAS})) == (K.OBJC({OAS}), _) : T.{C} & U32}}')
                t_, peeled = in_, True
        while True:
            m2 = re.fullmatch(r'T\.(\w+_sz\d+)\((.*)\)', cur)
            if not m2:
                break
            fname, args = m2.group(1), [a.strip() for a in __import__('codegen.proofs.var.block_body_offset_windows', fromlist=['_']).split_top(m2.group(2))]
            last = args[-1]
            m3 = re.fullmatch(r'T\.(\w+)_size\((.*)\)', last)
            cp, V = m3.group(1), m3.group(2)
            if cp not in cs:
                szx_ok = False
                break
            cands = [c for c in cs[cp] if c[2] == V] if len(cs[cp]) > 1 else cs[cp]
            if len(cands) != 1:
                szx_ok = False
                break
            sz_prf, vt, _, SZj, hokn, _v = cands[0]
            ctx = f'T.{fname}(' + ', '.join(args[:-1] + ['_']) + ')'
            SZR = t_ if peeled else (SZC[1:SZC.index(' .|. O.pz(')] if getattr(K, 'pz', None) is not None else (SZR0 or f'K.SZC({OAS})'))
            steps.append(f'  %Equal.sym({vt} & U32, {last}, ({V}, {SZj}), {sz_prf.replace("@HOK", f"{hokn}({OAS}, h)")}) :\n    {{{ctx} == (K.OBJC({OAS}), {SZR}) : T.{C} & U32}}')
            fb = fn_body(fname)
            params = fn_params(fname)
            d = dict(zip(params, args[:-1] + [None]))
            m4 = re.search(r'\((\+?\w+), \+?(\w+)\) = pair\n\s*(.*)$', fb, re.S)
            d[m4.group(1).lstrip('+')] = V
            d[m4.group(2)] = SZj
            nxt = m4.group(3).strip().split('\n')[0].strip()
            cur = rq(subst(nxt, {k_: v_ for k_, v_ in d.items() if v_ is not None}))
        if szx_ok:
            RTS = '\n'.join(steps) + '\n  {==}'
    return szx_ok, RTS, RTV


def iface_text(C, generic=False):
    global SRC, SRC_FILE
    rq = cs = None  # bound only on some paths below; the helpers take them
    from codegen.proofs.laws import spec_connected_codec_laws as SLW
    names, g, K, events, OBJF, OP, OA, HP, HA, SZC, EP, fw, vw, F, FIX, fsd, tfs = _iface_load(C, generic)
    names_txt, kids, kind, OPS, OAS, TRUE_, conj = _iface_spec_and_hyps(C, generic, OP, OA, HP, HA, F)
    fields, L2, w = _iface_fields(SLW, names, g, K, events, F, tfs, kids)
    n, PS, VV, OS, os_, END, SCH, items, chain, conjt, acc, OKA, HA2, ENCCt = _iface_chain(C, FIX, names_txt, kids, kind, OPS, OAS, TRUE_, conj, fields)
    eo, OKO, cat, bv, rw, SZCORE, ESZ = _iface_size_laws(C, generic, n, K, SZC, fw, vw, FIX, OPS, OAS, TRUE_, fields, w, PS, VV, OS, os_, END, items, chain, conjt, acc, OKA)
    _iface_writer_laws(K, SZC, EP, fw, vw, FIX, OPS, OAS, TRUE_, w, VV, SCH, items, chain, ENCCt, eo, OKO, cat, bv, rw, SZCORE, ESZ)
    # ---- the interface ----
    MP, ifc = _iface_mw_text(C, K, OP, OA, OPS, OAS, TRUE_, HA2, ENCCt)
    ifc = _iface_hyps_text(C, K, OAS, SCH, ENCCt, MP, ifc)
    # ---- maxx: the bytes' bound, FIX plus the children's (when every child states one) ----
    ifc = _iface_child_max(K, FIX, OPS, OAS, TRUE_, VV, ENCCt, MP, ifc)
    # ---- pfx: the writer's tree is perfect, write by write (when every child's is) ----
    _iface_events_pf(K, events, fsd, OAS, fields)
    # ---- sizex: the runtime's size pass, child by child (narrow containers whose children state it) ----
    rq, cs, szx_ok, RTS, chain_rt = _iface_rt_chain(rq, cs, K, OBJF, F, OAS, VV)
    szx_ok, RTS, RTV = _iface_rtv(C, K, OBJF, SZC, F, OAS, szx_ok, RTS, rq, cs, chain_rt)
    body = '\n'.join(L2)
    body = OKA(body)
    okpf = True
    pfs = f'K.pfC({OAS}, dd, D, XQ(q, r), q, r, pf)'
    if okpf:
        ifc += TEMPLATES.render('iface_text', MP=MP, pfs=pfs)
    if szx_ok:
        ifc += TEMPLATES.render('iface_text_2', OPS=OPS, OAS=OAS, TRUE_=TRUE_, K=K, C=C, RTS=RTS, MP=MP).replace('@H', 'h')
    if RTV is not None:
        ifc += TEMPLATES.render('iface_text_3f' if has_valid_f(K.p) else 'iface_text_3', OPS=OPS, OAS=OAS, TRUE_=TRUE_, K=K, C=C, RTV=RTV, MP=MP)
    return body + ifc


IHEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
         'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/layout.bend as Layout', 'import ../../spec/primitives.bend as SP', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
         'import ./vuwd.bend as WD', 'import ./vcopy.bend as VC', 'import ./vrecx.bend as VRX', 'import ./vcont.bend as VCN', 'import ./vua_lay.bend as LY',
         'import ./vconts.bend as CS', 'import ./spec_bits.bend as FB', 'import ./dk.bend as DK']


def iface_file(C):
    return ROOT / f'proofs/obj/encx_{C}_iface.bend'


def iface_full(C, generic=False):
    body = iface_text(C, generic)
    main = (out_file(C) if not generic else gfile_c(C)).name
    heads = full_text(C, generic).split('\n')
    mods = [l for l in heads if l.startswith('import ./') and (' as E' in l or ' as V_' in l or ' as RV_' in l or l.endswith(' as VPC'))]
    hd = IHEAD
    if generic:
        hd = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec') for x in hd]
    if 'VRB.' in body:
        mods.append('import ./vrecb.bend as VRB')
    pads = sorted(set(re.findall(r'\bVBo_(\w+)\(', body)))
    if pads:   # the zero-padded bv4 leaf's spec value and parts (pad_spec_text), before the body
        body = ''.join(pad_spec_text(PADCTOR[p_]) for p_ in pads) + body
        mods.append('import ./vfx_bv4.bend as VFB4')
    if 'VBB.' in body:
        mods.append('import ./vbitb.bend as VBB')
    if 'V2S.' in body:
        mods.append('import ./vbv257s.bend as V2S')
    if 'V2S8.' in body:
        mods.append('import ./vbv128s.bend as V2S8')
    if 'VMR.' in body and 'import ./vmr.bend as VMR' not in mods + hd:
        mods.append('import ./vmr.bend as VMR')
    if 'FWS.' in body:
        mods.append('import ./vfixw_spec.bend as FWS')
    if 'WU.' in body:
        mods.append('import ./vfixw_u32.bend as WU')
    if U32M:
        mods.append('import ./vpos32.bend as P32')
    if 'UWB.' in body and 'import ./vuw_bits.bend as UWB' not in mods + hd:
        mods.append('import ./vuw_bits.bend as UWB')
    head = hd + mods + [f'import ./{main} as K', '', '# GENERATED by container_encoder_windows (codegen). Do not edit.',
                        f'# {C} in the encoder-window interface, with its spec side (see the generator: iface_text).', '',
                        'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                        'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b',
                        'def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}: FD.logic__and_left(a, b, h)',
                        'def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}: FD.logic__and_right(a, b, h)']
    text = bigify(C, generic, '\n'.join(head) + '\n' + body)
    if RECORD and big_sizes(C, generic):
        text = rm_iface(text, *RECF[C])
    return text


HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
        'import ./vuwd.bend as WD', 'import ./vcopy.bend as VC', 'import ./vrecx.bend as VRX', 'import ./vcont.bend as VCN', 'import ./vmr.bend as VMR', 'import ./dk.bend as DK']


# The generic containers (types/generic_obj.bend, proofs/obj/generic_specs.bend) written by this generator:
# every child in the encoder-window interface, every fixed piece word-aligned (so far).
GCONTS = ['ProgressiveSingleListContainerTestStruct', 'VarTestStruct', 'ProgressiveVarTestStruct', 'ProgressiveComplexTestStruct', 'ProgressiveTestStruct', 'BitsStruct', 'ComplexTestStruct', 'ProgressiveBitsStruct']
# the containers written in the encoder-window interface with their spec side (iface_text): (name, generic)
def _has_iface(X):
    # a container child has an encoder window when its iface is generated here (ICONTS) or already on disk
    return X in dict(ICONTS) or (ROOT / 'proofs/obj' / f'encx_{X}_iface.bend').exists()


ICONTS = [('ProgressiveSingleListContainerTestStruct', True), ('ExecutionPayload', False), ('ExecutionPayloadHeader', False), ('VarTestStruct', True), ('ProgressiveVarTestStruct', True),
          ('ProgressiveComplexTestStruct', True), ('ProgressiveTestStruct', True), ('ExecutionRequests', False), ('Attestation', False),
          ('IndexedAttestation', False), ('AttesterSlashing', False), ('BitsStruct', True),
          ('LightClientHeader', False), ('BeaconBlockBody', False), ('BeaconBlock', False), ('SignedBeaconBlock', False), ('ComplexTestStruct', True),
          ('LightClientFinalityUpdate', False), ('LightClientUpdate', False), ('ProgressiveBitsStruct', True), ('BeaconState', False)]


def gfile_c(C):
    return ROOT / f'proofs/obj/encx_{C}.bend'


RECF = {}           # container -> (OP, OA), for recordize


def rm_iface(text, OP, OA):
    """The interface over the writer's record K.KW (recordize): the mirror MW wraps the record (MW{wR: K.KW}), so a
    match on MW keeps ENC(m), VAL(m) .. stuck for a variable m (the laws' types hold List.length(&2, ..) /
    Maybe<&2, ..>, which the checker compares by evaluation), while inside a case the record is a variable: the
    writer's terms over it stay small (F_<f>(wR)) and compare syntactically; its lemmas take the record too."""
    OAS = ', '.join(OA)
    PAT = ', '.join('+' + x for x in OA)
    fre = re.compile(r'(?<![\w.+"])(' + '|'.join(sorted(OA, key=len, reverse=True)) + r')(?![\w"])')
    idx = [mm.start() for mm in re.finditer(r'^(def|law|type) ', text, re.M)] + [len(text)]
    parts = [text[:idx[0]]]
    for j in range(len(idx) - 1):
        b = text[idx[j]:idx[j + 1]]
        if b.startswith('type MW is Data:'):
            b = f'type MW is Data:\n  MW{{{RV}: K.KW}}\n\n'
        elif f'MW{{{PAT}}}' in b:
            b = b.replace(f'MW{{{PAT}}}', f'MW{{+{RV}}}').replace(f'K.KW{{{OAS}}}', RV).replace(OAS, RV)
            b = fre.sub(lambda mm: f'K.F_{mm.group(1)}({RV})', b)
        parts.append(b)
    return recordize(''.join(parts), OP, OA, qual='K.')


RECORD = True       # a big container's fields threaded as one record KW (recordize)
RV = 'wR'           # the record's variable


def rec_decl(OP, qual=''):
    """The record KW of the container's fields and its projections F_<f> (qual: the writer's alias from outside)."""
    fs = [(p.split(':')[0].strip().lstrip('+'), p.split(':', 1)[1].strip()) for p in OP]
    pat = ', '.join(f'+{f}' for f, _ in fs)
    out = ['# ---- the container\'s fields as one record (its lemmas take it whole: a field is F_<f>(w)) ----',
           'type KW is Data:', '  KW{' + ', '.join(f'{f}: {t}' for f, t in fs) + '}', '']
    for f, t in fs:
        out.append(f'def F_{f}({RV}: KW) -> {t}:\n  match {RV}:\n    case KW{{{pat}}}: {f}')
    return '\n'.join(out) + '\n'


def recordize(text, OP, OA, qual=''):
    """In each def over the fields (their parameter list OPS): OPS -> +wR: KW, their argument lists (OAS) -> wR,
    every other field -> F_<f>(wR). Everything is then generic in one record variable (no field list is repeated
    in a statement); a def binding some fields itself keeps them."""
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    fre = re.compile(r'(?<![\w.+"])(' + '|'.join(sorted(OA, key=len, reverse=True)) + r')(?![\w"])')
    idx = [m.start() for m in re.finditer(r'^(def|law|type) ', text, re.M)] + [len(text)]
    parts = [text[:idx[0]]]
    for j in range(len(idx) - 1):
        b = text[idx[j]:idx[j + 1]]
        if OPS in b:
            b = b.replace(OPS, f'+{RV}: {qual}KW').replace(OAS, RV)
            b = fre.sub(lambda mm: f'{qual}F_{mm.group(1)}({RV})', b)
        parts.append(b)
    text = ''.join(parts)
    if not qual:
        i = text.index('\ndef ')
        text = text[:i] + '\n' + rec_decl(OP) + text[i:]
    return text


def full_text(C, generic=False):
    global SRC, SRC_FILE
    if generic:
        from codegen.core import generic_form_schemas as GN
        names = {n: t for n, t, err in GN.inventory_all() if err is None}
        g = G.Gen()
        if SRC_FILE != 'types/generic_obj.bend':
            SRC, SRC_FILE = None, 'types/generic_obj.bend'
    else:
        g, names = G.Gen(), schema.load(ROOT / 'codegen/fulu.yaml')
        if SRC_FILE != 'types/fulu_obj.bend':
            SRC, SRC_FILE = None, 'types/fulu_obj.bend'
    for n, t in names.items():
        g.shape(t)
    L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC = module_text(g, names, C)
    RECF[C] = (OP, OA)
    L += putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC)
    mods = []
    for lf in K.leaves.values():
        if lf.mod and lf.mod not in mods:
            mods.append(lf.mod)
    for f, fw in K.fixw.items():
        if fw.mod not in mods:
            mods.append(fw.mod)
    for ch in K.children.values():
        if ch.mod not in mods:
            mods.append(ch.mod)
    if any(ev['kind'] in ('off', 'leaf', 'fixw') and ev['hoff'] % 4 for ev in events) and 'import ./vpiece.bend as VPC' not in mods:
        mods.append('import ./vpiece.bend as VPC')
    if getattr(K, 'pz', None) is not None or ' .|. 0 : U32)' in SZC or getattr(K, 'or0', False):
        mods.append('import ./vuw_bits.bend as UWB')
    if any(lf.bits or lf.tail for lf in K.leaves.values()):
        mods.append('import ./vbitb.bend as VBB')
    if any(lf.pad for lf in K.leaves.values()):   # the zero-padded bv4 leaf: its validity and spec (vbitb, vfx_bv4)
        mods.append('import ./vbitb.bend as VBB')
    hd = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T') for x in HEAD] if generic else HEAD
    head = hd + mods + ['', '# GENERATED by container_encoder_windows (codegen). Do not edit.',
                          f'# {C} in the encoder-window interface: written at any byte position X = 4 q + r (see the generator).', '',
                          'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                          'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b']
    OPS_, OAS_ = ', '.join(OP), ', '.join(OA)
    MA_ = f'{OAS_}, dd, D, X, q, r'
    L.append(TEMPLATES.render('full_text', K=K, OPS_=OPS_, MA_=MA_, OAS_=OAS_, C=C))
    L.append(pfc_text(K, events, OP, OA, C))
    text = bigify(C, generic, '\n'.join(head) + '\n' + '\n'.join(L) + '\n')
    if RECORD and big_sizes(C, generic):
        text = recordize(text, OP, OA)
    return text



def split_args(t):
    out, dep, cur = [], 0, ''
    for ch in t:
        if ch in '([{':
            dep += 1
        elif ch in ')]}':
            dep -= 1
        if ch == ',' and dep == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    out.append(cur.strip())
    return out


def eqn_is_eq(text):
    """VCN.EQN(a, b, {==}) -> VCN.EQN(a, b, FD.nat__eq_from_is_eq(a, b, {==}))."""
    out, i = [], 0
    while True:
        j = text.find('VCN.EQN(', i)
        if j < 0:
            out.append(text[i:])
            return ''.join(out)
        k, dep = j + len('VCN.EQN('), 1
        while dep:
            dep += {'(': 1, ')': -1}.get(text[k], 0)
            k += 1
        args = split_args(text[j + len('VCN.EQN('):k - 1])
        if len(args) == 3 and args[2] == '{==}':
            out.append(text[i:j] + f'VCN.EQN({args[0]}, {args[1]}, FD.nat__eq_from_is_eq({args[0]}, {args[1]}, {{==}}))')
        else:
            out.append(text[i:k])
        i = k


_BS_CACHE = {}


def big_sizes(C, generic=False):
    """The fixed fields' sizes of BIGPIECE bytes or more."""
    if generic:
        return []
    if '_bs' not in _BS_CACHE:
        names = schema.load(ROOT / 'codegen/fulu.yaml')
        g = G.Gen()
        for n, t in names.items():
            g.shape(t)
        _BS_CACHE['_bs'] = (names, g)
    names, g = _BS_CACHE['_bs']
    return sorted({fs.fsize for _, fs in g.shape(names[C]).fields if fs.fixed and (fs.fsize or 0) >= BIGPIECE})



def brace_at(t, i):
    """end index (exclusive) of the {..} group starting at t[i] == '{'."""
    k, dep = i + 1, 1
    while dep:
        dep += {'{': 1, '}': -1}.get(t[k], 0)
        k += 1
    return k


def putx_hyps(text):
    """putx/putx_bytes state hl/hz (and putx_bytes its goal) over ENC(m), PADB(r, m) and List.length/append; go and
    BYX over K.ENCC(..) with VCN.LN/AP.  At the literal sizes a conversion between the two forms under a length or a
    byte walk evaluates the bytes, so each is bridged by logic__subst steps whose motives hit the given type
    syntactically: ENC(MW{..}) == K.ENCC(..) as a bare list (cheap), and the generic lnl/apl/padq."""
    a = text.index('\ndef go(')
    G = {}
    for h in ('hl', 'hz'):
        i = text.index('+' + h + ': {', a) + len(h) + 3
        G[h] = text[i:brace_at(text, i)]
    j = G['hl'].index('VCN.LN(K.ENCC(')
    k, dep = j + 7, 1
    while dep:
        dep += {'(': 1, ')': -1}.get(G['hl'][k], 0)
        k += 1
    LNK = G['hl'][j:k]
    KE = LNK[7:-1]
    A = KE[len('K.ENCC('):-1]
    M = 'MW{' + A + '}'
    sub = lambda T, mot, x, y, e, p: f'FD.logic__subst({T}, {mot}, {x}, {y}, {e}, {p})'
    Gl, Gz = G['hl'], G['hz']
    PZ = f'WD.PADB(r, {LNK})'
    LLm, LNm = 'List.length(&2, U32, ENC(m))', 'VCN.LN(ENC(m))'
    # putxE/putx_bytesE take ENC(m) abstracted as EE (with eE: ENC(m) == EE), so the hypotheses refined by the
    # match mention no m; only bare lists are compared across the refinement
    eK = f'Equal.trans(+List<U32>, EE, ENC({M}), {KE}, Equal.sym(+List<U32>, ENC({M}), EE, eE), {{==}})'
    h2 = sub('+List<U32>', 'zq => ' + Gl.replace(LNK, 'VCN.LN(zq)'), 'EE', KE, eK, 'hl')
    z2 = sub('+List<U32>', 'zq => ' + Gz.replace(LNK, 'VCN.LN(zq)'), 'EE', KE, eK, 'hz')
    assert text.count(', pf, hl, hz))') == 2
    text = text.replace(', pf, hl, hz))', f', pf, {h2}, {z2}))')
    i = text.index('\ndef BYX(')
    i = text.index('\n  {', i) + 3
    B = text[i:brace_at(text, i)]
    LHS = B[1:B.index(' == UW.SPL(')]
    RB = f'UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VCN.AP({KE}, UW.ZB(WD.PADB(r, {LNK}))))'
    assert B == '{' + LHS + ' == ' + RB + ' : +List<U32>}', B[-300:]
    RBm = RB.replace(KE, 'ENC(m)')
    RGm = 'UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m))))'
    j = text.index('\ndef putx_bytes(')
    c = find_call(text, 'PB', j)
    R = text[c[0]:c[1]]
    text = text[:c[0]] + sub('+List<U32>', 'zq => ' + B.replace(KE, 'zq'), KE, 'EE', f'Equal.sym(+List<U32>, EE, {KE}, {eK})', R) + text[c[1]:]
    for nm in ('putx', 'putx_bytes'):
        lw = text.index(f'\nlaw {nm}:\n') + 1
        le = text.index('\ndef ', lw) + 1
        fors = [l[len('  for '):] for l in text[lw:le].split('\n') if l.startswith('  for ')]
        goal = [l for l in text[lw:le].split('\n') if l.startswith('  {')][0].strip()
        if nm == 'putx_bytes':
            goal = '{UA.BYT(PUTX(m, dd, D, q, r)) == ' + RBm.replace('ENC(m)', 'EE') + ' : +List<U32>}'
        ps = [p for p in fors if p.split(':')[0] not in ('+hl', '+hz', '+hok')]
        hok = [p for p in fors if p.startswith('+hok:')][0]
        ps += ['+EE: +List<U32>', '+eE: {ENC(m) == EE : +List<U32>}', '+hl: ' + Gl.replace(LNK, 'VCN.LN(EE)'),
               '+hz: ' + Gz.replace(LNK, 'VCN.LN(EE)'), hok]
        hdr = f'def {nm}(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):\n'
        k = text.index(hdr, le)
        ke = text.find('\n\n', k)
        body = text[k + len(hdr):ke]
        call = f'{nm}E(m, dd, D, X, q, r, e, hr, hd, pf, ENC(m), {{==}}, hlm(q, r, dd, m, hl), hzm(q, r, D, m, hz), hok)'
        if nm == 'putx_bytes':
            call = f'bym(UA.BYT(PUTX(m, dd, D, q, r)), D, q, r, m, {call})'
        text = (text[:lw] + f'def {nm}E(' + ', '.join(ps) + f') -> {goal}:\n' + body + '\n\n'
                + text[lw:k] + hdr + '  ' + call + text[ke:])
    # the other laws over ENC(m): the same abstraction, the body's K.ENCC result carried to EE
    for lw in [x for x in re.findall(r'\nlaw (\w+):\n', text) if x not in ('putx', 'putx_bytes')]:
        li = text.index(f'\nlaw {lw}:\n') + 1
        le = text.index('\ndef ', li) + 1
        blk = text[li:le].split('\n')
        goal = [l for l in blk if l.startswith('  {')][0].strip()
        if 'ENC(m)' not in goal:
            continue
        fors = [l[len('  for '):] for l in blk if l.startswith('  for ')]
        SE = goal.replace('List.length(&2, U32, ENC(m))', 'VCN.LN(ENC(m))').replace('ENC(m)', 'EE')
        k = text.index(f'def {lw}(', le)
        hdr = text[k:text.index('\n', k) + 1]
        ke = text.find('\n\n', k)
        body = text[k + len(hdr):ke]
        ci = body.index('}: ', body.index('case MW{')) + 3
        ce = body.find('\n', ci)
        ce = len(body) if ce < 0 else ce
        mot = 'zq => ' + re.sub(r'(?<![\w.])m(?![\w])', M, SE.replace('EE', 'zq'))
        body = body[:ci] + sub('+List<U32>', mot, KE, 'EE', f'Equal.sym(+List<U32>, EE, {KE}, {eK})', body[ci:ce]) + body[ce:]
        names_ = [p.split(':')[0].strip('+ ') for p in fors]
        call = f'{lw}E(' + ', '.join(names_ + ['ENC(m)', '{==}']) + ')'
        text = (text[:li] + f'def {lw}E(' + ', '.join(fors + ['+EE: +List<U32>', '+eE: {ENC(m) == EE : +List<U32>}'])
                + f') -> {SE}:\n' + body + '\n\n' + text[li:k] + hdr + '  ' + call + text[ke:])
    i = text.index('\ndef RTX(')
    return (text[:i] + '\n# the putx laws' + "'" + ' hypotheses and goal between ENC(m) (List.length/append, PADB) and VCN.LN/AP, generic in m\n'
            + f'def hlm(+q: Nat, +r: Nat, +dd: Nat, m: MW, +hl: {Gl.replace(LNK, LLm)}) -> {Gl.replace(LNK, LNm)}: hl\n'
            + f'def hlm32(+q: Nat, +r: Nat, +dd: Nat, m: MW, +hl32: {_deep.hl32_decl("FD")(Gl.replace(LNK, LLm))}) -> {_deep.hl32_decl("FD")(Gl.replace(LNK, LNm))}: hl32\n'
            + f'def hlm31(+q: Nat, +r: Nat, +dd: Nat, m: MW, +hs31: {_deep.hs31_decl(Gl.replace(LNK, LLm))}) -> {_deep.hs31_decl(Gl.replace(LNK, LNm))}: hs31\n'
            + f'def hzm(+q: Nat, +r: Nat, +D: FD.array__Tree<U32>, m: MW, +hz: {Gz.replace(PZ, "PADB(r, m)").replace(LNK, LLm)}) -> {Gz.replace(LNK, LNm)}: hz\n'
            + f'def bym(+L: +List<U32>, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat, m: MW, +R: {{L == {RBm} : +List<U32>}}) -> {{L == {RGm} : +List<U32>}}: R\n'
            + text[i:])


def find_call(text, name, start=0):
    """(start, end, args) of the next call name(...) in text."""
    j = text.find(name + '(', start)
    if j < 0:
        return None
    k, dep = j + len(name) + 1, 1
    while dep:
        dep += {'(': 1, ')': -1}.get(text[k], 0)
        k += 1
    return j, k, split_args(text[j + len(name) + 1:k - 1])


def lit_sub(t, v, rep):
    return re.sub(rf'(?<![\w.]){v}n\b', rep, t)


def lit_sub_nw(t, v, rep):
    """lit_sub, a word count (VS.wtake's) equal to a big byte size staying a literal (BeaconState: the 65536
    words of block_roots, the 65536 bytes of slashings)."""
    keep = []
    while True:
        c = find_call(t, 'VCN.len_wt')
        if c is None:
            break
        keep.append(t[c[0]:c[1]])
        t = t[:c[0]] + f'@LW{len(keep) - 1}@' + t[c[1]:]
    t = re.sub(r'VS\.wtake\((\d+)n, ', r'VS.wtake(@WT\1@, ', t)
    t = lit_sub(t, v, rep)
    t = re.sub(r'VS\.wtake\(@WT(\d+)@, ', r'VS.wtake(\1n, ', t)
    for k in reversed(range(len(keep))):
        t = t.replace(f'@LW{k}@', keep[k])
    return t


def sz_is_eq(text, bigs):
    """FD.nat__eq_from_is_eq(a, b, {==}) with a big size variable SZ<v> in a or b: the size variables replaced by
    their literals (logic__subst on eSZ<v>), then decided by Nat.is_eq."""
    out, i = [], 0
    while True:
        c = find_call(text, 'FD.nat__eq_from_is_eq', i)
        if c is None:
            out.append(text[i:])
            return ''.join(out)
        j, k, args = c
        vs = [v for v in bigs if f'SZ{v}' in args[0] or f'SZ{v}' in args[1]]
        if len(args) == 3 and vs:
            def go(a_, b_, vs_):
                if not vs_:
                    return f'FD.nat__eq_from_is_eq({a_}, {b_}, {{==}})'
                v = vs_[0]
                az, bz = a_.replace(f'SZ{v}', 'zz'), b_.replace(f'SZ{v}', 'zz')
                inner = go(a_.replace(f'SZ{v}', f'{v}n'), b_.replace(f'SZ{v}', f'{v}n'), vs_[1:])
                return f'FD.logic__subst(Nat, zz => {{{az} == {bz} : Nat}}, {v}n, SZ{v}, Equal.sym(Nat, SZ{v}, {v}n, eSZ{v}), {inner})'
            out.append(text[i:j] + go(args[0], args[1], vs))
        else:
            out.append(text[i:k])
        i = k


def sz_le(text, bigs):
    """FD.nat__le_trans(a, b, c, {==}, h) with a size variable SZ<v> in a or b: its {==} (Nat.is_le(a, b)) decided at
    the literals and carried to the variables by logic__subst on eSZ<v>."""
    out, i = [], 0
    while True:
        c = find_call(text, 'FD.nat__le_trans', i)
        if c is None:
            out.append(text[i:])
            return ''.join(out)
        j, k, args = c
        vs = [v for v in bigs if f'SZ{v}' in args[0] or f'SZ{v}' in args[1]]
        if len(args) == 5 and args[3] == '{==}' and vs:
            def go(a_, b_, vs_):
                if not vs_:
                    return '{==}'
                v = vs_[0]
                az, bz = a_.replace(f'SZ{v}', 'zz'), b_.replace(f'SZ{v}', 'zz')
                inner = go(a_.replace(f'SZ{v}', f'{v}n'), b_.replace(f'SZ{v}', f'{v}n'), vs_[1:])
                return f'FD.logic__subst(Nat, zz => {{Nat.is_le({az}, {bz}) == True{{}} : Bool}}, {v}n, SZ{v}, Equal.sym(Nat, SZ{v}, {v}n, eSZ{v}), {inner})'
            args[3] = go(args[0], args[1], vs)
            out.append(text[i:j] + 'FD.nat__le_trans(' + ', '.join(args) + ')')
        else:
            out.append(text[i:k])
        i = k


def putx_core(text, bigs):
    """putx over symbolic big sizes: putx_core takes SZ<v> (with eSZ<v>: SZ<v> == v) for each big fixed piece size v
    and states the region's pieces with them (a length of the region is then never unfolded); the FixW writers'
    lemmas, stated at the literal, are bridged with eSZ<v>; putx is putx_core at the literals."""
    i = text.index('\ndef putx(') + 1
    j = text.index('\n\n', i)
    block = text[i:j]
    a = block.index('\n    -> ')
    b = block.index(':\n', a)
    params = block[len('def putx('):a - 1]
    ret = block[a + len('\n    -> '):b]
    body = block[b + 2:]
    stm = re.split(r'\n(?=  \S)', body)
    # the fixed size F (LLC = SUM(ks) + F) is a variable too, with eLF: SUM(ks) + F == LLC
    LLv = re.search(r'LLC\([^()]*\)', block).group(0)
    mL = re.search(r'\ndef LLC\(.*\) -> Nat: Nat\.add\((VCN\.SUM\(.*\)), (?:U32\.to_nat\((\d+)\)|(\d+)n)\)\n', text)
    SK, FIX = mL.group(1), int(mL.group(2) or mL.group(3))
    bigs = sorted(set(bigs) | {FIX})
    # U32 mode: F and the packed vectors' sizes stated at U32.to_nat(v) (F's LLC is), the others at the literal
    FORM = form_of
    SZP = ', '.join(f'+SZ{v}: Nat, +eSZ{v}: {{SZ{v} == {FORM(v)} : Nat}}' for v in bigs) + f', +eLF: {{Nat.add({SK}, SZ{FIX}) == {LLv} : Nat}}'
    out = []
    ren = {}
    putc_lemmas = []
    for st_ in stm:
        m = re.match(r'  \+(\w+) = ', st_)
        nm = m.group(1) if m else None
        if nm and (re.fullmatch(r'(hl|pp)\d+', nm) or (re.fullmatch(r'ep\d+', nm) and 'VRX.fpos(' in st_)):
            # a fixed field's position and room: stated on LLC with the literal sizes (no region piece); in U32
            # mode F (bounding its end) is the variable
            out.append(lit_sub_nw(st_, FIX, f'SZ{FIX}') if U32M else st_)
            continue
        t = st_
        # a word count equal to a big byte size (BeaconState: 65536 words of block_roots, 65536 bytes of
        # slashings) stays a literal
        for v in bigs:
            t = lit_sub_nw(t, v, f'SZ{v}')
        for old, new_ in ren.items():
            t = re.sub(rf'\b{old}\b', new_, t)
        if nm and re.fullmatch(r'z\d+', nm) and t.startswith(f'  +{nm} = VCN.reg_zero('):
            args = find_call(t, 'VCN.reg_zero')[2]
            if re.fullmatch(r'SZ\d+', args[3]) and args[5] == '0n':
                # m + 0 is m only by unfolding m: VS.bt's count restated by nat__add_zero
                rel = f'Nat.add({args[1]}, VCN.LN(VCN.CAT({args[2]})))'
                out.append(t)
                out.append(f'  +{nm}b = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({rel}, {args[6]})) == UW.ZB(zz) : +List<U32>}}, Nat.add({args[3]}, 0n), {args[3]}, '
                           f'FD.nat__add_zero({args[3]}), {nm})')
                ren[nm] = nm + 'b'
                continue
        if nm and re.fullmatch(r'hz\d+', nm) and 'VS.bt(SZ' in t and not (U32M and int(re.search(r'VS\.bt\(SZ(\d+),', t).group(1)) in U32PK):
            c = find_call(t, 'FD.logic__subst')
            args = c[2]
            v = re.search(r'VS\.bt\(SZ(\d+),', args[1]).group(1)
            ub = re.search(r'VS\.bdr\(zz, (.*)\)\) == UW\.ZB', args[1]).group(1)
            out.append(t)
            out.append(f'  +{nm}L = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({args[3]}, {ub})) == UW.ZB(zz) : +List<U32>}}, SZ{v}, {v}n, eSZ{v}, {nm})')
            ren[nm] = nm + 'L'
            continue
        if nm and nm.startswith('I') and ('VCN.reg_putc0(' in t or 'VCN.reg_putc(' in t):
            fn = 'VCN.reg_putc0' if 'VCN.reg_putc0(' in t else 'VCN.reg_putc'
            c = find_call(t, fn)
            args = c[2]
            mv = re.fullmatch(r'SZ(\d+)', args[3])
            if mv and not (U32M and int(mv.group(1)) in U32PK):
                v = mv.group(1)
                hi = 10
                HY, Y = args[hi], args[5]
                if HY.startswith('VCN.len_wt('):
                    W = split_args(HY[len('VCN.len_wt('):-1])[0]
                    HY = f'Equal.trans(Nat, VCN.LN({Y}), A.quad({W}), {v}n, {HY}, FD.nat__eq_from_is_eq(A.quad({W}), {v}n, {{==}}))'
                args[hi] = f'Equal.trans(Nat, VCN.LN({Y}), {v}n, SZ{v}, {HY}, Equal.sym(Nat, SZ{v}, {v}n, eSZ{v}))'
                t = t[:c[0]] + f'{fn}(' + ', '.join(args) + ')' + t[c[1]:]
        if nm == 'byf':
            c = find_call(t, 'FD.logic__subst')
            args = c[2]
            B = args[3]
            mot = args[1]
            vs = [v for v in bigs if f'SZ{v}' in B]
            out.append(t)
            # the writer's tree and bytes by their names while the big sizes are variables (the region's
            # CAT is then stuck on them): putcq (M<n> -> PUTC), encq (CAT -> ENCCs at SZ<v>); then the
            # sizes to their literals, ENCCs(.., v n) being ENCC by one definitional step
            mcall = find_call(mot, 'UA.BYT')[2][0]
            margs = mcall[mcall.index('('):]
            ap = find_call(B, 'VCN.AP')[2]
            oas = ', '.join(split_args(margs[1:-1])[:-5])
            spl = mot[mot.index('UW.SPL('):mot.rindex(' : +List<U32>}')]
            szs = ', '.join(f'SZ{v}' for v in vs)
            out.append(f'  +byfP = FD.logic__subst(FD.array__Tree<U32>, zt => {{UA.BYT(zt) == {spl.replace(", zz)", ", " + B + ")", 1)} : +List<U32>}}, '
                       f'{mcall}, PUTC{margs}, putcq{margs}, byf)')
            out.append(f'  +byfE = FD.logic__subst(+List<U32>, ze => {{UA.BYT(PUTC{margs}) == {spl.replace(", zz)", ", VCN.AP(ze, " + ap[1] + "))", 1)} : +List<U32>}}, '
                       f'{ap[0]}, ENCCs({oas}, {szs}), encq({oas}, {szs}), byfP)')
            prev = 'byfE'
            cur = f'ENCCs({oas}, {szs})'
            for v in vs:
                bz = cur.replace(f'SZ{v}', 'zz2')
                out.append(f'  +{prev}L = FD.logic__subst(Nat, zz2 => {{UA.BYT(PUTC{margs}) == {spl.replace(", zz)", ", VCN.AP(" + bz + ", " + ap[1] + "))", 1)} : +List<U32>}}, '
                           f'SZ{v}, {FORM(v)}, eSZ{v}, {prev})')
                cur = cur.replace(f'SZ{v}', FORM(v))
                prev = prev + 'L'
            # ENCCs at the literals to ENCC by name, in the motive: BYC states it as ENCC(..), and a
            # conversion that meets ENCCs(.., literals) against it would unfold the SPL around them first
            out.append(f'  +{prev}C = FD.logic__subst(+List<U32>, ze => {{UA.BYT(PUTC{margs}) == {spl.replace(", zz)", ", VCN.AP(ze, " + ap[1] + "))", 1)} : +List<U32>}}, '
                       f'{cur}, ENCC({oas}), {{==}}, {prev})')
            prev = prev + 'C'
            ren['byf'] = prev
            putc_lemmas.append((mcall, margs, ap[0], oas, vs))
            continue
        out.append(t)
    core_body = sz_le(sz_is_eq('\n'.join(out), bigs), bigs)
    names = [x.split(':')[0].strip().lstrip('+') for x in split_args(params)]
    core = f'def putx_core({params}, {SZP})\n    -> {ret}:\n{core_body}'
    wrap = f'def putx({params})\n    -> {ret}:\n  putx_core({", ".join(names)}, ' + ', '.join(f'{FORM(v)}, {{==}}' for v in bigs) + ', {==})'
    lem = ''
    for mcall, margs, cat, oas, vs in putc_lemmas:
        pp = re.search(r'\ndef PUTC\((.*?)\) -> ', text).group(1)
        pe = re.search(r'\ndef ENCC\((.*?)\) -> ', text).group(1)
        szp = ', '.join(f'+SZ{v}: Nat' for v in vs)
        szs = ', '.join(f'SZ{v}' for v in vs)
        lem += (TEMPLATES.render('putx_core', pp=pp, mcall=mcall, margs=margs, pe=pe, szp=szp, cat=cat, oas=oas, szs=szs))
        # ENCC over the big sizes (ENCCs), ENCC being it at the literals
        m_ = re.search(r'\ndef ENCC\((.*?)\) -> \+List<U32>: (.*)\n', text)
        body_ = m_.group(2)
        for v in vs:
            body_ = lit_sub_nw(body_, v, f'SZ{v}')
        text = (text[:m_.start()] + f'\ndef ENCCs({pe}, {szp}) -> +List<U32>: {body_}\n'
                + f'def ENCC({pe}) -> +List<U32>: ENCCs({oas}, ' + ', '.join(FORM(v) for v in vs) + ')\n' + text[m_.end():])
        i = text.index('\ndef putx(') + 1
        j = text.index('\n\n', i)
    if U32M:
        # a big size variable at its U32 (a packed vector's eSZ states it so; the others' by Nat.is_eq, once)
        for v in bigs:
            prf = 'e' if FORM(v) != f'{v}n' else f'Equal.trans(Nat, z, {v}n, U32.to_nat({v}), e, FD.nat__eq_from_is_eq({v}n, U32.to_nat({v}), {{==}}))'
            lem += f'def uSZ{v}(+z: Nat, +e: {{z == {FORM(v)} : Nat}}) -> {{z == U32.to_nat({v}) : Nat}}: {prf}\n'
        lem += '\n'
        for imp in ('import ./vpos32.bend as P32', 'import ./vadd.bend as AD', 'import ./vpiece.bend as VPC'):
            if imp not in text:
                text = text.replace('\nimport ./dk.bend as DK\n', f'\nimport ./dk.bend as DK\n{imp}\n', 1)
        i = text.index('\ndef putx(') + 1
        j = text.index('\n\n', i)
    return (text[:i] + lem + '# putx over symbolic sizes of its big fixed pieces (see putx_core in codegen/proofs/var/container_encoder_windows.py)\n'
            + core + '\n\n' + wrap + text[j:])


GCV = TEMPLATES.text('GCV')


def typed_parts(text, bigs):
    """partsC over the big fixed sizes: PSC is PSCs (its parts over SZ<v>) at the literals; partsC_core states
    Some{PSCs(.., SZ<v>)} and steps with gcv_ / gcf_ (GCV), a field proof stated at a literal size carried to
    SZ<v> by one logic__subst (its motive at the literal is its type); partsC is the core at the literals.
    Comparing the parts list with PSC then never evaluates a big piece (VCN.PC at a literal count)."""
    MB = 'Maybe<&2, +List<S.Part>>'
    m = re.search(r'\ndef PSC\((.*?)\) -> \+List<S.Part>: (.*)\n', text)
    pp, pbody = m.group(1), m.group(2)
    pn = [x.split(':')[0].strip().lstrip('+') for x in split_args(pp)]
    vs = [v for v in bigs if re.search(re.escape(f'VCN.PC({form_of(v)}, '), pbody)]
    if not vs:
        return text
    szp = ', '.join(f'+SZ{v}: Nat' for v in vs)
    sza = ', '.join(f'SZ{v}' for v in vs)
    lit = ', '.join(form_of(v) for v in vs)
    sub = lambda t: reduce_sz(t, vs)  # noqa: E731
    text = (text[:m.start()] + f'\ndef PSCs({pp}, {szp}) -> +List<S.Part>: {sub(pbody)}\n'
            + f'def PSC({pp}) -> +List<S.Part>: PSCs({", ".join(pn)}, {lit})\n' + text[m.end():])

    def rw(t):
        cands = [(t.find(n + '('), n) for n in ('VS.cat_var', 'FX.cat_fixed')]
        cands = [(j, n) for j, n in cands if j >= 0]
        if not cands:
            return t
        j, n = min(cands)
        c = find_call(t, n, j)
        args = [rw(x) for x in c[2]]
        v, s_ = find_call(args[0], 'Codec.parts')[2]
        vs_, rs = find_call(args[2], 'Codec.parts')[2]
        g = 'gcv_' if n == 'VS.cat_var' else 'gcf_'
        y, ea = args[1], args[4]
        ys = sub(y)
        if ys != y:
            # the field's proof at the literal size, carried to SZ<v>
            for vv in vs:
                if f'SZ{vv}' in ys:
                    yz = ys.replace(f'SZ{vv}', 'zz').replace('SZ', 'SZ')
                    ylit = ys
                    for w_ in vs:
                        if w_ != vv:
                            ylit = ylit.replace(f'SZ{w_}', f'SZ{w_}')
                    tp = 'Variable' if g == 'gcv_' else 'Fixed'
                    ea = (f'FD.logic__subst(Nat, zz => {{Codec.parts({v}, {s_}) == Some{{[S.{tp}{{{yz.replace(f"SZ{vv}", "zz")}}}]}} : {MB}}}, '
                          f'{form_of(vv)}, SZ{vv}, Equal.sym(Nat, SZ{vv}, {form_of(vv)}, eSZ{vv}), {ea})')
        return t[:j] + f'{g}({v}, {vs_}, {s_}, {rs}, {ys}, {sub(args[3])}, {ea}, {args[5]})' + rw(t[c[1]:])
    a = text.index('\ndef partsC(') + 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    h_end = blk.index(':\n  ')
    hdr, body = blk[:h_end], blk[h_end + 2:].strip()
    ps_ = hdr[len('def partsC('):hdr.rindex(')\n    -> ')]
    ret = hdr[hdr.rindex('    -> ') + 7:]
    names = [x.split(':')[0].strip().lstrip('+') for x in split_args(ps_)]
    retc = ret.replace(f'Some{{PSC({", ".join(pn)})}}', f'Some{{PSCs({", ".join(pn)}, {sza})}}')
    assert retc != ret, ret[-200:]
    ezp = ', '.join(f'+SZ{v}: Nat, +eSZ{v}: {{SZ{v} == {form_of(v)} : Nat}}' for v in vs)
    core = f'def partsC_core({ps_}, {ezp})\n    -> {retc}:\n  {rw(body)}\n'
    wrap = (f'def partsC({ps_})\n    -> {ret}:\n  partsC_core({", ".join(names)}, '
            + ', '.join(f'{form_of(v)}, {{==}}' for v in vs) + ')\n')
    return text[:a] + GCV.lstrip('\n') + '\n' + core + '\n' + wrap + text[b:]


SCB_BODY = re.compile(r'List\.append\(&2, U32, VS\.bt\(U32\.to_nat\(24576\), FX\.limbs\(UW\.SLW\((\w+)\)\)\), FX\.limbs\(\[([\w, ]+)\]\)\)')


def scb_named(text):
    """A SyncCommittee's bytes as FWS.SCB(TB, a0..a11), the form vfixw_spec's scp states them in (its body
    inside a big piece, compared with SCB(..), would evaluate the piece)."""
    return SCB_BODY.sub(lambda m: f'FWS.SCB({m.group(1)}, {m.group(2)})', text)


def iface_eqs(text, bigs):
    """The interface's closed equations of a big container: eLLC by commutativity (LLC is F-last), eENC at the
    big sizes as variables (eENCs; the CAT is stuck on them), instantiated at the literals."""
    m = re.search(r'\ndef eLLC\((.*?)\) -> \{(K\.LLC\(.*?\)) == Nat\.add\((\d+n), (VCN\.SUM\(.*\))\) : Nat\}: \{==\}\n', text)
    if m:
        text = (text[:m.start()] + f'\ndef eLLC({m.group(1)}) -> {{{m.group(2)} == Nat.add({m.group(3)}, {m.group(4)}) : Nat}}:\n'
                f'  FD.nat__add_comm({m.group(4)}, {m.group(3)})\n' + text[m.end():])
    m = re.search(r'\ndef eENC\((.*?), \+u: Unit\) -> \{K\.ENCC\((.*?)\) == (VCN\.CAT\(.*\)) : \+List<U32>\}: \{==\}\n', text)
    if m:
        vs = [v for v in bigs if f'VCN.PC({form_of(v)}, ' in m.group(3)]
        if vs:
            szp = ', '.join(f'+SZ{v}: Nat' for v in vs)
            sza = ', '.join(f'SZ{v}' for v in vs)
            text = (text[:m.start()] + f'\ndef eENCs({m.group(1)}, {szp}) -> {{K.ENCCs({m.group(2)}, {sza}) == {reduce_sz(m.group(3), vs)} : +List<U32>}}: {{==}}\n'
                    + text[m.end():])
    return text


def coreize(text, bigs):
    """The interface's lemmas over the big fixed pieces at variable sizes: each def whose statement or proof
    mentions PSC, K.ENCC, a big piece at its literal size or another such def becomes D_core (+SZ<v>, +eSZ<v>),
    with PSC -> PSCs(.., SZ<v>), K.ENCC -> K.ENCCs(.., SZ<v>), VCN.PC(<v>n, -> VCN.PC(SZ<v>,, and calls to
    the cores; D is D_core at the literals when its statement names the pieces only (no big literal in it),
    and is dropped otherwise (it was only used inside other cores). A comparison at a variable size stops
    at the stuck piece; at the literal it would evaluate it."""
    m = re.search(r'\ndef PSCs\((.*?)\) -> ', text)
    if m is None:
        return text
    vs = [v for v in bigs if f'+SZ{v}: Nat' in m.group(1)]
    szp = ', '.join(f'+SZ{v}: Nat, +eSZ{v}: {{SZ{v} == {form_of(v)} : Nat}}' for v in vs)
    sza = ', '.join(f'SZ{v}, eSZ{v}' for v in vs)
    szs = ', '.join(f'SZ{v}' for v in vs)
    lit = ', '.join(f'{form_of(v)}, {{==}}' for v in vs)
    idx = [mm.start() for mm in re.finditer(r'^def ', text, re.M)] + [len(text)]
    blocks = [(text[idx[i]:idx[i + 1]]) for i in range(len(idx) - 1)]
    head = text[:idx[0]]
    name = lambda b: b[4:b.index('(')]  # noqa: E731
    skip = {'PSCs', 'PSC', 'partsC_core', 'partsC', 'eENCs', 'gcv_', 'gcf_'}
    cored = {'partsC', 'eENC'}
    todo = []
    lemmas = {'eENC', 'cellsC', 'encE', 'specC', 'lenC', 'lenE', 'maxC'}
    # lemmas that check at the literals, called from a core: transported to SZ<v> (their statements name PSC /
    # K.ENCC only; the motive at the literal is the statement with them unfolded one step)
    lits_ = {}
    for b in blocks:
        n = name(b)
        if n in ('validC', 'okoC'):
            c0 = find_call(b, f'def {n}')
            rest0 = b[c0[1]:]
            st0 = rest0[rest0.index('-> ') + 3:rest0.index(':\n')] if ':\n' in rest0 else None
            lits_[n] = ([x.split(':')[0].strip().lstrip('+') for x in split_args(b[len(f'def {n}('):c0[1] - 1])], st0)
    for b in blocks:
        n = name(b)
        if n in skip or n not in lemmas:
            continue
        if (re.search(r'(?<![\w.])PSC\(|K\.ENCC\(', b) or any(f'VCN.PC({form_of(v)}, ' in b for v in vs)
                or any(re.search(rf'(?<![\w.]){c}\(', b) for c in cored)):
            cored.add(n)
            todo.append(n)
    out = []
    need_encq2 = []
    for b in blocks:
        n = name(b)
        if n not in todo:
            out.append(b)
            continue
        c0 = find_call(b, f'def {n}')
        params = b[len(f'def {n}('):c0[1] - 1]
        rest = b[c0[1]:]
        pn = [x.split(':')[0].strip().lstrip('+') for x in split_args(params)]
        def sub(t):
            t = re.sub(r'(?<![\w.])PSC\(', 'PSCq(', t)
            t = t.replace('K.ENCC(', 'K.ENCCq(')
            t = reduce_sz(t, vs)
            for c in cored:
                t = re.sub(rf'(?<![\w.]){c}\(', f'{c}_coreq(', t)
            # close the marked calls with the size arguments
            for mk, extra in (('PSCq(', szs), ('K.ENCCq(', szs)):
                j = 0
                while True:
                    j = t.find(mk, j)
                    if j < 0:
                        break
                    c_ = find_call(t, mk[:-1], j)
                    args_ = [a_ for a_ in c_[2]]
                    base = 'PSCs(' if mk == 'PSCq(' else 'K.ENCCs('
                    rep = base + ', '.join(args_ + [extra]) + ')'
                    t = t[:j] + rep + t[c_[1]:]
                    j += len(rep)
            for ln_, (lpn, lst) in lits_.items():
                j = 0
                while lst is not None:
                    c_ = find_call(t, ln_, j)
                    if c_ is None:
                        break
                    j0 = c_[0]
                    if j0 > 0 and (t[j0 - 1].isalnum() or t[j0 - 1] in '._'):
                        j = c_[1]
                        continue
                    stz = lst
                    for pn_, a_ in zip(lpn, c_[2]):
                        stz = re.sub(rf'(?<![\w.]){pn_}(?!\w)', a_, stz)
                    mot = sub_names(stz, 'zz')
                    v0 = vs[0]
                    rep = (f'FD.logic__subst(Nat, zz => {mot}, {v0}n, SZ{v0}, Equal.sym(Nat, SZ{v0}, {v0}n, eSZ{v0}), {t[j0:c_[1]]})')
                    t = t[:j0] + rep + t[c_[1]:]
                    j = j0 + len(rep)
            j = 0
            while True:
                mm_ = re.search(r'(\w+)_coreq\(', t[j:])
                if not mm_:
                    break
                j0 = j + mm_.start()
                cn = mm_.group(1)
                c_ = find_call(t, f'{cn}_coreq', j0)
                args_ = c_[2]
                if cn == 'eENC':
                    rep = 'eENCs(' + ', '.join(args_[:-1] + [szs]) + ')'
                else:
                    rep = f'{cn}_core(' + ', '.join(args_ + [sza]) + ')'
                t = t[:j0] + rep + t[c_[1]:]
                j = j0 + len(rep)
            return t
        core = f'def {n}_core({params}, {szp}){sub(rest)}'
        stmt = rest[:rest.index(':\n')] if ':\n' in rest else rest[:rest.index(': ')]
        out.append(core if core.endswith('\n') else core + '\n')
        if not any(f'VCN.PC({form_of(v)}, ' in stmt for v in vs) and n not in ('eENC',):
            call = f'{n}_core({", ".join(pn)}, {lit})'
            ce = find_call(stmt, 'K.ENCC')
            if 'List.length(&2, U32, K.ENCC(' in stmt and ce is not None:
                # K.ENCC under List.length: a conversion would count its bytes; rewrite with encq2 instead
                oas = ', '.join(ce[2])
                litn = ', '.join(form_of(v) for v in vs)
                mot = stmt[stmt.index('-> ') + 3:].replace(f'K.ENCC({oas})', 'zq')
                call = f'FD.logic__subst(+List<U32>, zq => {mot}, K.ENCCs({oas}, {litn}), K.ENCC({oas}), encq2({oas}), {call})'
                need_encq2.append(True)
            out.append(f'def {n}({params}){stmt}:\n  {call}\n\n')
    text = head + ''.join(out)
    if need_encq2:
        m_ = re.search(r'\ndef VALC\((.*?)\) -> ', text)
        pp_ = m_.group(1)
        pn_ = ', '.join(x.split(':')[0].strip().lstrip('+') for x in split_args(pp_))
        litn = ', '.join(form_of(v) for v in vs)
        a_ = text.index('\ndef eENCs(') + 1
        text = (text[:a_] + f'def encq2({pp_}) -> {{K.ENCCs({pn_}, {litn}) == K.ENCC({pn_}) : +List<U32>}}:\n  {{==}}\n' + text[a_:])
    return text


def sub_names(t, z):
    '''PSC(..) -> PSCs(.., z), K.ENCC(..) -> K.ENCCs(.., z) (one big size).'''
    for mk, base in (('PSC', 'PSCs'), ('K.ENCC', 'K.ENCCs')):
        j = 0
        while True:
            c_ = find_call(t, mk, j)
            if c_ is None:
                break
            j0 = c_[0]
            if j0 > 0 and (t[j0 - 1].isalnum() or t[j0 - 1] in '_') or (mk == 'PSC' and j0 > 0 and t[j0 - 1] == '.'):
                j = c_[1]
                continue
            rep = f'{base}(' + ', '.join(c_[2] + [z]) + ')'
            t = t[:j0] + rep + t[c_[1]:]
            j = j0 + len(rep)
    return t


def len_f_last(text, bigs):
    """lenC_core with the fixed size F last (LLC's form): SL = SUM(ks) + F, the fixed prefix's length by
    ln_cat (its pieces' lengths, summed by Nat.is_eq at the literals), vcont's eposv_r; eLLC (F first, whose
    statement alone expands F) goes."""
    a = text.find('\ndef lenC_core(')
    if a < 0:
        return text
    a += 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    msl = re.search(r'  \+SL = Nat\.add\((\d+)n, (VCN\.SUM\(.*\))\)\n', blk)
    FIX, SK = msl.group(1), msl.group(2)
    FT = form_of(FIX)
    blk = blk[:msl.start()] + f'  +SL = Nat.add({SK}, {FT})\n' + blk[msl.end():]
    c = find_call(blk, 'VCN.eposv')
    fw, ps, ks = c[2]
    pcs = split_args(fw[1:-1])
    if U32M:
        # the fixed prefix at U32.to_nat(F): the writer's elnS (U32 sums), its pieces' lengths at their sizes
        facts = [ln_u_core(x) for x in pcs]
        assert sum(v for v, _ in facts) == int(FIX)
        efw = f'K.elnS{len(pcs)}(' + ', '.join(pcs + [p for _, p in facts]) + ')'
    else:
        efw = sz_le(sz_is_eq(ln_cat(pcs, f'{FIX}n'), bigs), bigs)
    LF = f'VCN.LN(VCN.CAT({fw}))'
    SKs = f'VCN.SUM({ks})'
    rep = (f'Equal.trans(Nat, VCN.LN(VCN.CAT(VCN.LAP({fw}, VCN.PCL({ks}, {ps})))), Nat.add({SKs}, {LF}), Nat.add({SKs}, {FT}), '
           f'VCN.eposv_r({fw}, {ps}, {ks}), Equal.cong(Nat, Nat, zz => Nat.add({SKs}, zz), {LF}, {FT}, {efw}))')
    blk = blk[:c[0]] + rep + blk[c[1]:]
    # the last line: e1 is the statement (K.LLC unfolds to SL)
    lines = blk.rstrip('\n').split('\n')
    assert lines[-1].startswith('  Equal.trans(Nat, List.length(') and 'eLLC(' in lines[-1], lines[-1][:80]
    lines[-1] = '  e1'
    blk = '\n'.join(lines) + '\n'
    text = text[:a] + blk + text[b:]
    m = re.search(r'\ndef eLLC\(.*?\n(  .*\n)*', text)
    if m and text.count('eLLC(') == 1:
        text = text[:m.start()] + '\n' + text[m.end():]
    return text


def enc_fixed_size(text, bigs):
    """encE_core's {Layout.fixed_size(PSCs(.., SZ<v>)) == F}: the sum written as fixed_size unfolds it (4n per
    variable part, kn per small fixed part, VCN.LN(VCN.PC(SZ<v>, xs)) per big one; {==} against the unfolding,
    stuck at the same place), decided at the literals by Nat.is_eq and carried back by eSZ<v> and len_pc."""
    a = text.find('\ndef encE_core(')
    if a < 0:
        return text
    a += 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    c = find_call(blk, 'LY.enc_genL')
    args = c[2]
    if args[4] != '{==}':
        return text
    ps, FS = args[0], args[1]
    m = re.search(r'\ndef PSCs\((.*?)\) -> \+List<S\.Part>: \[(.*)\]\n', text)
    items = split_args(m.group(2))
    slots, bigp = [], []
    for it in items:
        if it.startswith('S.Variable{'):
            slots.append('4n')
            continue
        pc = find_call(it, 'VCN.PC')
        if pc is None:
            # a short piece (the bv4 bits: VS.bt(kn, ..))
            slots.append(re.match(r'S\.Fixed\{VS\.bt\((\d+n), ', it).group(1))
            continue
        k_, xs_ = pc[2]
        if re.fullmatch(r'SZ\d+', k_):
            slots.append(f'VCN.LN(VCN.PC({k_}, {xs_}))')
            bigp.append((k_, xs_))
        else:
            slots.append(k_)
    def summ(sl):
        t = '0n'
        for x in reversed(sl):
            t = f'Nat.add({x}, {t})'
        return t
    S0 = summ(slots)
    # at the literals, then back to SZ<v>, then to the pieces' lengths
    lits = [re.sub(r'VCN\.LN\(VCN\.PC\(SZ(\d+), .*\)\)$', lambda mm: f'{mm.group(1)}n', x) if x.startswith('VCN.LN(') else x for x in slots]
    prf = f'FD.nat__eq_from_is_eq({summ(lits)}, {FS}, {{==}})'
    cur = list(lits)
    for i, x in enumerate(slots):
        if x.startswith('VCN.LN('):
            k_, xs_ = find_call(x[len('VCN.LN('):-1], 'VCN.PC')[2]
            v = k_[2:]
            mot = summ(cur[:i] + ['zz'] + cur[i + 1:])
            prf = f'FD.logic__subst(Nat, zz => {{{mot} == {FS} : Nat}}, {form_of(v)}, {k_}, Equal.sym(Nat, {k_}, {form_of(v)}, eSZ{v}), {prf})'
            cur[i] = k_
            mot = summ(cur[:i] + ['zz'] + cur[i + 1:])
            prf = (f'FD.logic__subst(Nat, zz => {{{mot} == {FS} : Nat}}, {k_}, {x}, '
                   f'Equal.sym(Nat, {x}, {k_}, VCN.len_pc({k_}, {xs_})), {prf})')
            cur[i] = x
    hs = f'Equal.trans(Nat, Layout.fixed_size({ps}), {S0}, {FS}, {{==}}, {prf})'
    args[4] = hs
    blk = blk[:c[0]] + 'LY.enc_genL(' + ', '.join(args) + ')' + blk[c[1]:]
    return text[:a] + blk + text[b:]


def enc_fit(text):
    """encE_core's fit: CS.fitc's end equation by lenS (the payloads' length summed as ENDC nests it, over a
    variable F: at the literal F an unfolding of Nat.add(F, ..) expands F), and the fact in enc_genL's LY.LN
    form by fitLN (List.length vs LY.LN, over a variable F)."""
    a = text.find('\ndef encE_core(')
    if a < 0:
        return text
    a += 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    m = re.search(r'  \+fit = (CS\.fitc\(.*\))\n', blk)
    c = find_call(m.group(1), 'CS.fitc')
    FS, PAY, E, k, ek, eE, hb = c[2]
    lay = find_call(eE, 'LY.lay_end')[2]
    ps = lay[0]
    me = re.search(r'\ndef ENDC\((.*?)\) -> Nat: (.*)\n', text)
    endc = me.group(2)
    encs = re.findall(r'LY\.LN\(([^()]*\([^()]*\))\)', endc)
    n = len(encs)
    aa = [f'a{i}' for i in range(n)]
    def apl(xs):
        return '[]' if not xs else f'VCN.AP({xs[0]}, {apl(xs[1:])})'
    def nest(xs):
        t = 'F'
        for x in xs:
            t = f'Nat.add({t}, LY.LN({x}))'
        return t
    L = lambda x: f'List.length(&2, U32, {x})'  # noqa: E731
    # step: F + |a ++ r| == (F + LN a) + |r|
    lem = ('def lenS1(+F: Nat, +a: +List<U32>, +r: +List<U32>) -> {Nat.add(F, List.length(&2, U32, VCN.AP(a, r))) == Nat.add(Nat.add(F, LY.LN(a)), List.length(&2, U32, r)) : Nat}:\n'
           '  Equal.trans(Nat, Nat.add(F, List.length(&2, U32, VCN.AP(a, r))), Nat.add(F, Nat.add(List.length(&2, U32, a), List.length(&2, U32, r))), Nat.add(Nat.add(F, LY.LN(a)), List.length(&2, U32, r)),\n'
           '    Equal.cong(Nat, Nat, z => Nat.add(F, z), List.length(&2, U32, VCN.AP(a, r)), Nat.add(List.length(&2, U32, a), List.length(&2, U32, r)), VS.len_app(a, r)),\n'
           '    Equal.sym(Nat, Nat.add(Nat.add(F, LY.LN(a)), List.length(&2, U32, r)), Nat.add(F, Nat.add(List.length(&2, U32, a), List.length(&2, U32, r))), FD.nat__add_assoc(F, List.length(&2, U32, a), List.length(&2, U32, r))))\n')
    # the chain over the n payloads
    ps_ = ', '.join(f'+{x}: +List<U32>' for x in aa)
    steps = []
    cur = f'Nat.add(F, {L(apl(aa))})'
    proof = None
    for i in range(n):
        nxt = f'Nat.add({nest(aa[:i + 1])}, {L(apl(aa[i + 1:]))})'
        e = f'lenS1({nest(aa[:i])}, {aa[i]}, {apl(aa[i + 1:])})'
        steps.append((cur, nxt, e))
        cur = nxt
    fin = nest(aa)
    steps.append((cur, fin, f'FD.nat__add_zero({fin})'))
    def chain(i):
        c0, n0, e0 = steps[i]
        if i == len(steps) - 1:
            return e0
        return f'Equal.trans(Nat, {c0}, {n0}, {fin}, {e0}, {chain(i + 1)})'
    lem += f'def lenS({"+F: Nat, " + ps_}) -> {{Nat.add(F, {L(apl(aa))}) == {fin} : Nat}}:\n  {chain(0)}\n'
    lem += ('def lenP(+F: Nat, +ps: +List<S.Part>, +P: +List<U32>, +hp: {Layout.payloads(ps) == P : +List<U32>}, +E: Nat,\n'
            '    +e: {Nat.add(F, List.length(&2, U32, P)) == E : Nat}) -> {Nat.add(F, List.length(&2, U32, Layout.payloads(ps))) == E : Nat}:\n'
            '  FD.logic__subst(+List<U32>, z => {Nat.add(F, List.length(&2, U32, z)) == E : Nat}, P, Layout.payloads(ps), Equal.sym(+List<U32>, Layout.payloads(ps), P, hp), e)\n')
    lem += ('def fitLN(+F: Nat, +P: +List<U32>, +h: {N.fits(4n, Nat.add(F, List.length(&2, U32, P))) == True{} : Bool}) -> {N.fits(4n, Nat.add(F, LY.LN(P))) == True{} : Bool}:\n'
            '  h\n\n')
    P_ = apl(encs)
    eE2 = f'lenP({FS}, {ps}, {P_}, {{==}}, {E}, lenS({FS}, {", ".join(encs)}))'
    fit = f'CS.fitc({FS}, {PAY}, {E}, {k}, {ek}, {eE2}, {hb})'
    blk = blk[:m.start()] + f'  +fit = fitLN({FS}, {PAY}, {fit})\n' + blk[m.end():]
    text = text[:a] + lem + blk + text[b:]
    if 'import ../../spec/nat_bytes.bend as N\n' not in text:
        text = text.replace('\nimport ./dk.bend as DK\n', '\nimport ./dk.bend as DK\nimport ../../spec/nat_bytes.bend as N\n', 1)
    return text


def enc_symbolic_F(text):
    """encE_core over the fixed size F as a variable SZF (with eSZF): ENDC is ENDCs(.., F) at the literal; the
    fit, the header facts and the fixed size's equation at SZF (a sum Nat.add(F, ..) at the literal F unfolds F
    whenever ENDC meets its body); okoC / okbk / the fixed-size equation carried from the literal by eSZF."""
    m = re.search(r'\ndef ENDC\((.*?)\) -> Nat: ((?:Nat\.add\()+)(\d+)n, (.*)\n', text)
    if m is None:
        return text
    FIX = m.group(3)
    pp = m.group(1)
    pn = [x.split(':')[0].strip().lstrip('+') for x in split_args(pp)]
    body = f'{m.group(2)}F, {m.group(4)}'
    text = (text[:m.start()] + f'\ndef ENDCs({pp}, +F: Nat) -> Nat: {body}\n'
            + f'def ENDC({pp}) -> Nat: ENDCs({", ".join(pn)}, {form_of(FIX)})\n' + text[m.end():])
    a = text.index('\ndef encE_core(') + 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    hd_end = blk.index(')\n    -> ')
    blk = blk[:hd_end] + f', +SZF: Nat, +eSZF: {{SZF == {form_of(FIX)} : Nat}}' + blk[hd_end:]
    tr = lambda mot, t: f'FD.logic__subst(Nat, zf => {mot}, {form_of(FIX)}, SZF, Equal.sym(Nat, SZF, {form_of(FIX)}, eSZF), {t})'  # noqa: E731
    # hf
    c = find_call(blk, 'LY.hdr_fp')
    ps, _, osc, oko = c[2]
    blk = blk[:c[0]] + f'LY.hdr_fp({ps}, SZF, {osc}, {tr(f"LY.OKO({ps}, zf, {osc})", oko)})' + blk[c[1]:]
    # fit
    mfit = re.search(r'  \+fit = (.*)\n', blk)
    ft = mfit.group(1)
    for nm in ('fitLN', 'CS.fitc', 'lenP', 'lenS'):
        ft = ft.replace(f'{nm}({FIX}n, ', f'{nm}(SZF, ')
    j = 0
    while True:
        c2 = find_call(ft, 'ENDC', j)
        if c2 is None:
            break
        if c2[0] > 0 and (ft[c2[0] - 1].isalnum() or ft[c2[0] - 1] in '._'):
            j = c2[1]
            continue
        rep = 'ENDCs(' + ', '.join(c2[2] + ['SZF']) + ')'
        ft = ft[:c2[0]] + rep + ft[c2[1]:]
        j = c2[0] + len(rep)
    c3 = find_call(ft, 'okbk')
    ek_ = c3[2]
    endcs = f'ENDCs({", ".join(pn)}, zf)'
    ft = ft[:c3[0]] + tr(f'{{Nat.is_le({endcs}, A.quad(VB.pw({ek_[-2]}))) == True{{}} : Bool}}', ft[c3[0]:c3[1]]) + ft[c3[1]:]
    blk = blk[:mfit.start()] + f'  +fit = {ft}\n' + blk[mfit.end():]
    # e1: enc_genL at SZF, its fixed-size equation carried
    c4 = find_call(blk, 'LY.enc_genL')
    ar = c4[2]
    ar[1] = 'SZF'
    ar[4] = tr(f'{{Layout.fixed_size({ar[0]}) == zf : Nat}}', ar[4])
    blk = blk[:c4[0]] + 'LY.enc_genL(' + ', '.join(ar) + ')' + blk[c4[1]:]
    text = text[:a] + blk + text[b:]
    # the wrapper at the literal
    a = text.index('\ndef encE(') + 1
    b = text.index('\ndef ', a)
    w_ = text[a:b]
    c5 = find_call(w_, 'encE_core')
    w_ = w_[:c5[0]] + 'encE_core(' + ', '.join(c5[2] + [f'{form_of(FIX)}', '{==}']) + ')' + w_[c5[1]:]
    return text[:a] + w_ + text[b:]


def len_symbolic_F(text):
    """lenE_core over the fixed size F as a variable (SZF, as encE_core): ENDCs at SZF in its statement; the
    fixed prefix's length by lay_len and encE_core's fixed-size equation (at SZF); the end by lay_end at SZF
    (END and ENDCs meet stuck on SZF); okoC carried from the literal F; the wrapper at the literal."""
    m = re.search(r'\ndef ENDC\(.*?\) -> Nat: ENDCs\(.*, (?:U32\.to_nat\()?(\d+)n?\)\)?\n', text)
    if m is None or '\ndef lenE_core(' not in text:
        return text
    FIX = m.group(1)
    ae = text.index('\ndef encE_core(') + 1
    be = text.index('\ndef ', ae)
    HS = find_call(text[ae:be], 'LY.enc_genL')[2][4]
    a = text.index('\ndef lenE_core(') + 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    hd = blk.index(') -> {')
    stmt_end = blk.index(':\n', hd)
    head_, stmt, body = blk[:hd], blk[hd:stmt_end], blk[stmt_end:]
    head_ += f', +SZF: Nat, +eSZF: {{SZF == {form_of(FIX)} : Nat}}'
    j = 0
    while True:
        c = find_call(stmt, 'ENDC', j)
        if c is None:
            break
        rep = 'ENDCs(' + ', '.join(c[2] + ['SZF']) + ')'
        stmt = stmt[:c[0]] + rep + stmt[c[1]:]
        j = c[0] + len(rep)
    # okoC at the literal F, carried to SZF (inside the size transport)
    c = find_call(body, 'okoC')
    oko = body[c[0]:c[1]]
    body = body.replace(oko, '@OKO@', 1)
    body = re.sub(rf'(?<![\w.]){FIX}n\b', 'SZF', body)
    ci = find_call(body, 'FD.logic__subst', body.rfind('FD.logic__subst(Nat, zz => LY.OKO(', 0, body.index('@OKO@')))
    mot = ci[2][1][len('zz => '):]
    ps_ = find_call(mot, 'LY.OKO')[2]
    okT = (f'FD.logic__subst(Nat, zf => LY.OKO({ps_[0].replace("zz", "24624n")}, zf, {ps_[2]}), {FIX}n, SZF, '
           f'Equal.sym(Nat, SZF, {FIX}n, eSZF), {oko})')
    body = body.replace('@OKO@', okT, 1)
    # lay_len: fixed_size(ps) == SZF by encE_core's equation
    c = find_call(body, 'LY.lay_len')
    ps0, o0 = c[2]
    body = body[:c[0]] + (f'Equal.trans(Nat, List.length(&2, U32, Layout.fixed_parts({ps0}, {o0})), Layout.fixed_size({ps0}), SZF, '
                          f'LY.lay_len({ps0}, {o0}), {HS})') + body[c[1]:]
    j = 0
    while True:
        c = find_call(body, 'ENDC', j)
        if c is None:
            break
        if c[0] > 0 and (body[c[0] - 1].isalnum() or body[c[0] - 1] in '._'):
            j = c[1]
            continue
        rep = 'ENDCs(' + ', '.join(c[2] + ['SZF']) + ')'
        body = body[:c[0]] + rep + body[c[1]:]
        j = c[0] + len(rep)
    # the end: lenP / lenS at SZF (as encE_core's fit), not lay_end (END against ENDCs)
    c = find_call(body, 'LY.lay_end')
    if c is not None:
        ps1, _ = c[2]
        me = re.search(r'\ndef ENDCs\((.*?)\) -> Nat: (.*)\n', text)
        encs = re.findall(r'LY\.LN\(([^()]*\([^()]*\))\)', me.group(2))
        P_ = '[]'
        for x in reversed(encs):
            P_ = f'VCN.AP({x}, {P_})'
        E_ = find_call(stmt, 'ENDCs')
        E_ = stmt[E_[0]:E_[1]]
        body = body[:c[0]] + f'lenP(SZF, {ps1}, {P_}, {{==}}, {E_}, lenS(SZF, {", ".join(encs)}))' + body[c[1]:]
    text = text[:a] + head_ + stmt + body + text[b:]
    a = text.index('\ndef lenE(') + 1
    b = text.index('\ndef ', a)
    w_ = text[a:b]
    c = find_call(w_, 'lenE_core')
    w_ = w_[:c[0]] + 'lenE_core(' + ', '.join(c[2] + [f'{form_of(FIX)}', '{==}']) + ')' + w_[c[1]:]
    return text[:a] + w_ + text[b:]


def spec_one_step(text):
    """specC_core: the container's parts one step down by rewrites (vwcU: VALC is its Sequence; lctU: parts at
    the container, over an opaque value) instead of a conversion against aggregate(..), which would evaluate
    the fields' parts; encE_core's calls get the fixed size's arguments (SZF at the literal)."""
    m = re.search(r'\ndef ENDC\(.*?\) -> Nat: ENDCs\(.*, (?:U32\.to_nat\()?(\d+)n?\)\)?\n', text)
    FIX = m.group(1) if m else None
    a = text.find('\ndef specC_core(')
    if a < 0:
        return text
    a += 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    if FIX:
        c = find_call(blk, 'encE_core')
        if c is not None and '+SZF' in text[text.index('\ndef encE_core('):text.index('\n', text.index('\ndef encE_core(') + 1)]:
            blk = blk[:c[0]] + 'encE_core(' + ', '.join(c[2] + [f'{form_of(FIX)}', '{==}']) + ')' + blk[c[1]:]
    ms = re.search(r'\n    -> \{Codec\.parts\((VALC\(.*?\)), (Spec\.\w+\(\))\) == (Some\{.*\}) : Maybe<&2, \+List<S\.Part>>\}:\n', blk)
    VALC, SP_, RHS = ms.group(1), ms.group(2), ms.group(3)
    c = find_call(blk, '%Equal.sym')
    items, chain = find_call(c[2][2], 'Codec.parts')[2]
    MB = 'Maybe<&2, +List<S.Part>>'
    ins = (f'  %vwcU({VALC[len("VALC("):-1]}) : {{Codec.parts(_, {SP_}) == {RHS} : {MB}}}\n'
           f'  %lctU({items}) : {{_ == {RHS} : {MB}}}\n')
    blk = blk[:c[0] - 2] + ins + blk[c[0] - 2:]
    pp = re.search(r'\ndef VALC\((.*?)\) -> ', text).group(1)
    defs = (TEMPLATES.render('spec_one_step', pp=pp, items=items, VALC=VALC, chain=chain, SP_=SP_, MB=MB))
    return text[:a] + defs + blk + text[b:]


def reduce_sz(t, vs):
    """VCN.PC(<v>n, ..) -> VCN.PC(SZ<v>, ..) for the big sizes vs."""
    for v in vs:
        t = t.replace(f'VCN.PC({form_of(v)}, ', f'VCN.PC(SZ{v}, ')
    return t



CHUNK_MAX = 200     # putx_core statements above which its let chain is cut into chunk defs
CHUNK_LEN = 90      # statements per chunk (a let chain's depth is the checker's recursion depth)



def u32_iface(text, FIX):
    """U32 mode's interface (BeaconState): no closed F. ENDC is spelled ENDCs(.., U32.to_nat(F)) everywhere (its
    name against its body would evaluate the F-first sum); every lemma summing from F (a literal F left in it, or
    the bound okbk) is a core over F as a variable SZF (eSZF: SZF == U32.to_nat(F)), okbk carried to SZF once (bS),
    and is called at SZF inside cores, at U32.to_nat(F) elsewhere."""
    UF = f'U32.to_nat({FIX})'
    Fn = re.compile(rf'(?<![\w.]){FIX}n\b')
    out, i = [], 0
    while True:
        m = re.compile(r'(?<![\w.])ENDC\(').search(text, i)
        if m is None:
            out.append(text[i:])
            break
        if text[max(0, m.start() - 4):m.start()] == 'def ':
            out.append(text[i:m.end()])
            i = m.end()
            continue
        c = find_call(text, 'ENDC', m.start())
        out.append(text[i:m.start()] + 'ENDCs(' + ', '.join(c[2] + [UF]) + ')')
        i = c[1]
    text = ''.join(out)

    def blocks(t):
        idx = [mm.start() for mm in re.finditer(r'^(def|law) ', t, re.M)] + [len(t)]
        return t[:idx[0]], [t[idx[j]:idx[j + 1]] for j in range(len(idx) - 1)]
    head, bl = blocks(text)
    name = lambda b_: b_[4:b_.index('(')] if b_.startswith('def ') else None  # noqa: E731
    skip = {'okbk', 'ENDC', 'ENDCs', 'OKT'}
    todo = [name(b_) for b_ in bl if name(b_) and name(b_) not in skip and not name(b_).startswith('ok')
            and Fn.search(b_)]
    todo += [n_ for n_ in ('okoC', 'szC') if n_ not in todo]
    newcores = {}
    for n_ in todo:
        k_ = [j for j, b_ in enumerate(bl) if name(b_) == n_][0]
        blk = bl[k_]
        hd = blk[:blk.index(':\n')]
        body = blk[len(hd) + 2:]
        sep = ')\n    -> ' if ')\n    -> ' in hd else ') -> '
        params = hd[len(f'def {n_}('):hd.rindex(sep)]
        stmt = hd[hd.rindex(sep) + len(sep):]
        names = [x.split(':')[0].strip().lstrip('+') for x in split_args(params)]
        has = '+SZF: Nat' in params
        OAS = ', '.join(names[:names.index('h')]) if 'h' in names else None
        body = body.replace(f'FD.nat__eq_from_is_eq({UF}, {FIX}n, {{==}})', f'Equal.sym(Nat, SZF, {UF}, eSZF)')
        body = Fn.sub('SZF', body)
        if OAS is not None:
            body = body.replace(f'ENDCs({OAS}, {UF})', f'ENDCs({OAS}, SZF)')
        if 'okbk(' in body:
            bnd = (f'FD.logic__subst(Nat, zf => {{Nat.is_le(ENDCs({OAS}, zf), A.quad(VB.pw(k))) == True{{}} : Bool}}, {UF}, SZF, '
                   f'Equal.sym(Nat, SZF, {UF}, eSZF), okbk({OAS}, h, k, ek))')
            body = body.replace(f'okbk({OAS}, h, k, ek)', 'bS')
            body = f'  +bS = {bnd}\n' + body
        st_c = Fn.sub('SZF', stmt)
        if has:
            bl[k_] = f'def {n_}({params}){sep[1:]}{st_c}:\n{body}'
            continue
        if n_.endswith('_core'):
            bl[k_] = f'def {n_}({params}, +SZF: Nat, +eSZF: {{SZF == {UF} : Nat}}){sep[1:]}{st_c}:\n{body}'
            newcores[n_] = n_
            continue
        st_c = st_c.replace(UF, 'SZF') if n_ in ('okoC', 'szC') else st_c
        core = f'def {n_}_core({params}, +SZF: Nat, +eSZF: {{SZF == {UF} : Nat}}){sep[1:]}{st_c}:\n{body.rstrip()}\n'
        wrap = f'def {n_}({params}){sep[1:]}{st_c.replace("SZF", UF)}:\n  {n_}_core({", ".join(names)}, {UF}, {{==}})\n\n'
        bl[k_] = core + '\n' + wrap
    # calls of the new cores: at SZF inside a def that has it, at U32.to_nat(F) elsewhere
    for n_ in newcores:
        for j, b_ in enumerate(bl):
            if name(b_) == n_:
                continue
            ins = '+SZF: Nat' in b_[:b_.index(':\n')] if ':\n' in b_ else False
            out, i = [], 0
            while True:
                c = find_call(b_, n_, i)
                if c is None or (c[0] > 0 and (b_[c[0] - 1].isalnum() or b_[c[0] - 1] in '_.')):
                    if c is None:
                        out.append(b_[i:])
                        break
                    out.append(b_[i:c[1]])
                    i = c[1]
                    continue
                out.append(b_[i:c[0]] + f'{n_}(' + ', '.join(c[2] + (['SZF', 'eSZF'] if ins else [UF, '{==}'])) + ')')
                i = c[1]
            bl[j] = ''.join(out)
    text = head + ''.join(bl)
    return u32_encE(text, FIX)


def u32_encE(text, FIX):
    """U32 mode's encE_core: the header facts by okoC_core at SZF, the parts' byte validity by validC_core over the
    big sizes' variables (each field's parts proof carried to SZ<v>), the fixed size's equation SUM == SZF by
    vpos32.addc (U32 sums; a literal F is never evaluated), the bound bS as is."""
    UF = f'U32.to_nat({FIX})'
    m = re.search(r'\ndef PSCs\((.*?)\) -> \+List<S\.Part>: \[(.*)\]\n', text)
    pp = m.group(1)
    vs = [int(x) for x in re.findall(r'\+SZ(\d+): Nat', pp)]
    items = split_args(m.group(2))
    SZA = ', '.join(f'SZ{v}' for v in vs)
    SZE = ', '.join(f'SZ{v}, eSZ{v}' for v in vs)
    PSP = ', '.join(f'+SZ{v}: Nat, +eSZ{v}: {{SZ{v} == {form_of(v)} : Nat}}' for v in vs)
    # validC_core over the sizes' variables
    a = text.index('\ndef validC_core(') + 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    hd = blk[:blk.index(':\n')]
    names = [x.split(':')[0].strip().lstrip('+') for x in split_args(hd[len('def validC_core('):hd.rindex(') -> ')])]
    OAS = ', '.join(names[:names.index('h')])
    body = blk[len(hd) + 2:]
    hd = hd.replace(', +SZF: Nat,', f', {PSP}, +SZF: Nat,').replace(f'PSC({OAS})', f'PSCs({OAS}, {SZA})')
    for v in vs:
        body = body.replace(f'VCN.PC({form_of(v)}, ', f'VCN.PC(SZ{v}, ')
    out, i = [], 0
    while True:
        c = find_call(body, 'CS.domf', i)
        if c is None:
            out.append(body[i:])
            break
        val, sch, byt, e0, prf = c[2]
        mv = re.match(r'VCN\.PC\(SZ(\d+), (.*)\)$', byt)
        if mv:
            v = int(mv.group(1))
            prf = (f'FD.logic__subst(Nat, zz => {{Codec.parts({val}, {sch}) == Some{{[S.Fixed{{VCN.PC(zz, {mv.group(2)})}}]}} : Maybe<&2, +List<S.Part>>}}, '
                   f'{form_of(v)}, SZ{v}, Equal.sym(Nat, SZ{v}, {form_of(v)}, eSZ{v}), {prf})')
        out.append(body[i:c[0]] + 'CS.domf(' + ', '.join([val, sch, byt, e0, prf]) + ')')
        i = c[1]
    body = ''.join(out)
    text = text[:a] + hd + ':\n' + body + text[b:]
    # (its wrapper at the literals is not used)
    mw = re.search(r'\ndef validC\(.*?\n  validC_core\(.*\n\n', text)
    if mw:
        text = text[:mw.start() + 1] + text[mw.end():]
    # encE_core
    a = text.index('\ndef encE_core(') + 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    c = find_call(blk, 'LY.hdr_fp')
    ps, _, osc, _ = c[2]
    blk = blk[:c[0]] + f'LY.hdr_fp({ps}, SZF, {osc}, okoC_core({OAS}, h, k, ek, SZF, eSZF))' + blk[c[1]:]
    bnd2 = (f'FD.logic__subst(Nat, zf => {{Nat.is_le(ENDCs({OAS}, zf), A.quad(VB.pw(k))) == True{{}} : Bool}}, {UF}, SZF, '
            f'Equal.sym(Nat, SZF, {UF}, eSZF), bS)')
    blk = blk.replace(bnd2, 'bS')
    c = find_call(blk, 'LY.enc_genL')
    ar = c[2]
    # the fixed size, part by part at U32 sums (vpos32.fsc), over the parts list (a transport: the list's spine only)
    el = []
    for it in items:
        if it.startswith('S.Variable{'):
            el.append((it, 4, '{==}'))
            continue
        mv = re.match(r'S\.Fixed\{VCN\.PC\(SZ(\d+), (.*)\)\}$', it)
        if mv:
            v = int(mv.group(1))
            el.append((it, v, f'P32.slotf(VCN.PC(SZ{v}, {mv.group(2)}), SZ{v}, {v}, LNPC(SZ{v}, {mv.group(2)}), K.uSZ{v}(SZ{v}, eSZ{v}))'))
            continue
        mk = re.match(r'S\.Fixed\{VCN\.PC\((\d+)n, (.*)\)\}$', it)
        if mk:
            # (its length by LNPC: unfolding PC at a comparison with the literal recurses per byte)
            el.append((it, int(mk.group(1)), f'P32.slotf(VCN.PC({mk.group(1)}n, {mk.group(2)}), {mk.group(1)}n, {mk.group(1)}, LNPC({mk.group(1)}n, {mk.group(2)}), {{==}})'))
            continue
        raise ValueError(f'u32_encE: part {it[:80]}')
    tot = [0] * (len(el) + 1)
    for j in reversed(range(len(el))):
        tot[j] = tot[j + 1] + el[j][1]
    assert tot[0] == FIX, (tot[0], FIX)
    # the chain over part variables (fsS: its lists are names), applied to the parts and their slots
    n_ = len(el)
    ps_ = [f'p{j}' for j in range(n_)]
    cp = 'P32.fsnil()'
    for j in reversed(range(n_)):
        cp = f'P32.fsc({ps_[j]}, [{", ".join(ps_[j + 1:])}], {el[j][1]}, {tot[j + 1]}, {tot[j]}, e{j}, {cp}, {{==}}, {{==}})'
    sig = ', '.join([f'+{x}: S.Part' for x in ps_] + [f'+e{j}: {{Layout.slot({ps_[j]}) == U32.to_nat({el[j][1]}) : Nat}}' for j in range(n_)])
    fsdef = TEMPLATES.render('u32_encE', n_=n_, sig=sig, ps_=ps_, tot=tot, cp=cp)
    prf = f'fsS{n_}(' + ', '.join([x[0] for x in el] + [x[2] for x in el]) + ')'
    LST = '[' + ', '.join(items) + ']'
    PSS = f'PSCs({OAS}, {SZA})'
    OPSp = pp[:pp.index(', +SZ')]
    fsdef += (TEMPLATES.render('u32_encE_2', OPSp=OPSp, PSP=PSP, UF=UF, PSS=PSS, LST=LST, prf=prf))
    FSZ = f'fszC({OAS}, {SZE}, SZF, eSZF)'
    ar[1] = 'SZF'
    ar[4] = FSZ
    ar[7] = f'validC_core({OAS}, h, k, ek, {SZE}, SZF, eSZF)'
    blk = blk[:c[0]] + 'LY.enc_genL(' + ', '.join(ar) + ')' + blk[c[1]:]
    text = text[:a] + fsdef + blk + text[b:]
    # lenE_core: the header facts by okoC_core, the fixed size by fszC
    a = text.index('\ndef lenE_core(') + 1
    b = text.index('\ndef ', a)
    blk = text[a:b]
    c = find_call(blk, 'LY.hdr_fp')
    ps, _, osc, _ = c[2]
    blk = blk[:c[0]] + f'LY.hdr_fp({ps}, SZF, {osc}, okoC_core({OAS}, h, 28n, {{==}}, SZF, eSZF))' + blk[c[1]:]
    c = find_call(blk, 'LY.lay_len')
    j0 = blk.index(', ', c[1]) + 2
    c2 = find_call(blk, 'FD.logic__subst', j0)
    assert c2[0] == j0, blk[j0:j0 + 80]
    blk = blk[:c2[0]] + FSZ + blk[c2[1]:]
    return text[:a] + blk + text[b:]


def chunk_putx(text):
    """A wide container's putx_core (BeaconState: 660 statements) cut into chunk defs of about CHUNK_LEN
    statements at I<k> boundaries: a chunk takes putx_core's parameters and the facts it reads from earlier
    chunks, typed as their producers (the region invariant I<k>) or consumers (rt_all's facts, cnext's ec/es)
    state them, and returns the facts later statements read as a DK.P2 chain (CT<c>_<i>)."""
    i = text.index('\ndef putx_core(') + 1
    j = text.index('\n\n', i)
    block = text[i:j]
    a = block.index('\n    -> ')
    b = block.index(':\n', a)
    params = block[len('def putx_core('):a - 1]
    body = block[b + 2:]
    stm = re.split(r'\n(?=  \S)', body)
    if len(stm) <= CHUNK_MAX:
        return text
    pnames = [x.split(':')[0].strip().lstrip('+') for x in split_args(params)]
    ALL = ', '.join(pnames)
    nm = [(re.match(r'  \+(\w+) = ', t) or [None, None])[1] for t in stm]
    tail0 = nm.index('ef')
    ib = [k for k, n in enumerate(nm) if n and re.fullmatch(r'I\d+', n) and k < tail0]
    pro = ib[0] + 1                      # the prologue (hX .. I0, pf0) stays in putx_core
    while nm[pro] and nm[pro].startswith('pf'):
        pro += 1
    cuts, last = [], pro
    for k in ib[1:]:
        nx = nm[k + 1] if k + 1 < len(nm) else None
        if nx and (nx.startswith('sz') or nx.startswith('hlc')):
            continue
        if k + 1 - last >= CHUNK_LEN or k == ib[-1]:
            cuts.append((last, k + 1))
            last = k + 1
    if last < tail0:
        cuts.append((last, tail0))
    defd = {n: k for k, n in enumerate(nm) if n}
    words = [set(re.findall(r'\b\w+\b', t)) for t in stm]
    mcall = re.search(r'\bM0(\(.*?, dd, D, X, q, r\))', body).group(1)
    ra = re.search(r'\ndef rt_all\((.*?)\)\n    -> ', text, re.S).group(1)
    ra_types = {x.split(':')[0].strip().lstrip('+'): x.split(':', 1)[1].strip() for x in split_args(ra)}
    fin = find_call(stm[-1], 'rt_all')[2]
    fact_ty = {n: ra_types[p] for n, p in zip(fin, [x.split(':')[0].strip().lstrip('+') for x in split_args(ra)]) if n != p}

    def consumer(n, after):
        for k in range(after, len(stm)):
            if n in words[k]:
                c = find_call(stm[k], 'VCN.cnext_r') or find_call(stm[k], 'VCN.cnext')
                if c and n in c[2]:
                    return c[2]
        return None

    def ty(n, after):
        k = defd[n]
        t = stm[k]
        if n == 'hX':
            return '{Nat.is_le(Nat.add(A.quad(q), r), List.length(&2, U32, UA.BYT(D))) == True{} : Bool}'
        if n in fact_ty:
            return fact_ty[n]
        if re.fullmatch(r'I\d+', n):
            for fn, ub in (('VCN.reg_putc0', 7), ('VCN.reg_put0', 7), ('VCN.reg_putc', 8)):
                c = find_call(t, fn)
                if c and t.startswith(f'  +{n} = {fn}('):
                    g = c[2]
                    Y = g[5] if fn == 'VCN.reg_put0' else f'VCN.PC({g[3]}, {g[5]})'
                    return f'{{{g[ub]} == UW.SPL({g[0]}, {g[1]}, VCN.CAT(VCN.LAP({g[2]}, Con{{{Y}, {g[4]}}}))) : +List<U32>}}'
        if t.startswith(f'  +{n} = FD.logic__subst('):
            g = find_call(t, 'FD.logic__subst')[2]
            v_, bd = g[1].split(' => ', 1)
            return re.sub(rf'\b{v_}\b', lambda _: g[3], bd)
        if re.fullmatch(r'pf\d+', n):
            return f'{{FD.array__perfect(U32, dd, M{n[2:]}{mcall}) == True{{}} : Bool}}'
        if re.fullmatch(r'(ec|sz)\d+', n):
            g = consumer(n, after)
            if g is not None:
                if g[7] == n:
                    return (f'{{U32.to_nat({g[0]}) == Nat.add(VCN.SUM({g[3]}), {g[2]}) : Nat}}')
                if g[8] == n:
                    return f'{{U32.to_nat({g[1]}) == {g[4]} : Nat}}'
        raise ValueError(f'chunk_putx: no type for {n}')

    out_top = stm[:pro]
    defs = []
    for c, (s0, s1) in enumerate(cuts):
        ins = sorted({n for k in range(s0, s1) for n in words[k] if n in defd and defd[n] < s0}, key=lambda n: defd[n])
        outs = [n for n in nm[s0:s1] if n and any(n in words[k] for k in range(s1, len(stm)))]
        # cnext's ec is typed by the cnext form (cnext_r in the big-region containers)
        tys_in = [(n, ty(n, s0)) for n in ins]
        tys_out = [(n, ty(n, s1)) for n in outs]
        for n_, t_ in tys_out:
            fact_ty.setdefault(n_, t_) if n_.startswith('rt') else None
        ct = []
        for i_, (n_, t_) in enumerate(tys_out):
            nxt = f'CT{c}_{i_ + 1}({ALL})' if i_ + 1 < len(tys_out) else None
            ct.append(f'def CT{c}_{i_}({params}) -> Data: ' + (f'DK.P2({t_}, {nxt})' if nxt else t_))
        tup = outs[-1]
        for n_ in reversed(outs[:-1]):
            tup = f'({n_}, {tup})'
        sig = ', '.join([params] + [f'+{n_}: {t_}' for n_, t_ in tys_in])
        defs.append('\n'.join(ct) + TEMPLATES.render('chunk_putx', c=c, sig=sig, ALL=ALL) + '\n'.join(stm[s0:s1]) + f'\n  {tup}\n')
        out_top.append(f'  +K{c}_0 = putx_ch{c}({", ".join(pnames + ins)})')
        for i_, (n_, t_) in enumerate(tys_out):
            if i_ + 1 < len(tys_out):
                B_ = f'CT{c}_{i_ + 1}({ALL})'
                out_top.append(f'  +{n_} = PA({t_}, {B_}, K{c}_{i_})')
                out_top.append(f'  +K{c}_{i_ + 1} = PB({t_}, {B_}, K{c}_{i_})')
            else:
                out_top.append(f'  +{n_} = K{c}_{i_}')
    out_top += stm[tail0:]
    nb = block[:b + 2] + '\n'.join(out_top)
    return text[:i] + '\n'.join(defs) + '\n' + nb + text[j:]


def bigify(C, generic, text):
    """In a container with fixed pieces of BIGPIECE bytes or more: putx's body over their sizes as variables
    (putx_core), closed Nat equations by Nat.is_eq, and the length lemmas the region proofs use; other containers'
    text is unchanged."""
    bigs = big_sizes(C, generic)
    if not bigs:
        return text
    text = eqn_is_eq(scb_named(text))
    if 'FWS.SCB(' in text and 'import ./vfixw_spec.bend as FWS' not in text:
        text = text.replace('\nimport ./dk.bend as DK\n', '\nimport ./dk.bend as DK\nimport ./vfixw_spec.bend as FWS\n', 1)
    if '\ndef putx(+' in text and 'def putx_core(' not in text:
        text = putx_core(text, bigs)
        text = chunk_putx(text)
    if '\ndef partsC(' in text:
        text = typed_parts(text, bigs)
        text = iface_eqs(text, bigs)
        text = coreize(text, bigs)
        text = len_f_last(text, bigs)
        text = enc_fixed_size(text, bigs)
        text = enc_fit(text)
        text = enc_symbolic_F(text)
        text = spec_one_step(text)
        text = len_symbolic_F(text)
        # a statement with List.length(&2, U32, K.ENCC(..)) (the literal-size bytes) is evaluated when checked:
        # the byte counts through VCN.LN (one definitional step from List.length)
        text = (text.replace('List.length(&2, U32, K.ENCC(', 'VCN.LN(K.ENCC(').replace('List.length(&2, U32, K.ENCCs(', 'VCN.LN(K.ENCCs(')
                .replace('zq => {List.length(&2, U32, zq)', 'zq => {VCN.LN(zq)'))
        text = putx_hyps(text)
        if U32M:
            text = u32_iface(text, max(U32PK))
    i = text.index('\ndef ')
    return (text[:i] + '\n\n# length lemmas of the region proofs\n'
            + 'def LNCC(+p: +List<U32>, +t: +List<+List<U32>>) -> {List.length(&2, U32, VCN.CAT(Con{p, t})) == Nat.add(List.length(&2, U32, p), List.length(&2, U32, VCN.CAT(t))) : Nat}: VCN.len_app(p, VCN.CAT(t))\n'
            + 'def LNPC(+k: Nat, +xs: +List<U32>) -> {List.length(&2, U32, VCN.PC(k, xs)) == k : Nat}: VCN.len_pc(k, xs)\n'
            + 'def LNW(+x: +List<U32>, +n: Nat, +e: {List.length(&2, U32, x) == n : Nat}) -> {VCN.LN(x) == n : Nat}: e\n'
            + text[i:])

def pfc_text(K, events, OP, OA, C):
    """pfC: the writer's tree is perfect, with no hypothesis (the writes' perfect lemmas in order)."""
    OPS_, OAS_ = ', '.join(OP), ', '.join(OA)
    MA_ = f'{OAS_}, dd, D, X, q, r'
    fsd = dict(K.F)
    Mk = lambda k: f'M{k}({MA_})'
    pfs = 'pf'
    pre = ''
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf' and leaf_of(fs).sub:
            pfs = f'{leaf_of(fs).pf}(dd, {Mk(k)}, X, {ev["hoff"]}, {f}, {pfs})'
        elif ev['kind'] == 'off' and (ev['hoff'] % 4 or U32M):
            Xc_ = f'U32.add(X, {ev["hoff"]})'
            pfs = f'WD.w32x_perfect(VCN.RX({Xc_}), dd, {Mk(k)}, VCN.QX({Xc_}), {ev["cur"]}, {pfs})'
        elif ev['kind'] == 'leaf':
            qk_, rk_ = qr_at(ev['hoff'])
            pfs = f'pfo_{leaf_of(fs).p}({f}, dd, {Mk(k)}, {qk_}, {rk_}, {pfs})'
        elif ev['kind'] == 'fixw':
            qk_, rk_ = qr_at(ev['hoff'])
            pfs = K.fixw[f].pf(rk_, Mk(k), qk_, pfs)
        elif ev['kind'] == 'off':
            pfs = f'WD.w32x_perfect(r, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), {ev["cur"]}, {pfs})'
        else:
            ch = K.children[f]
            Xc = f'U32.add(X, {ev["cur"]})'
            QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
            if ch.p == 'bl32' or getattr(ch, 'std', False):
                a = 'EB' if ch.p == 'bl32' else ch.alias
                pfs = f'{a}.pfx(m_{f}, dd, {Mk(k)}, {QX}, {RX}, {pfs})'
            elif ch.p == 'l1048576_bl1073741824':
                t_, N_ = ch.oargs
                pfs = f'etpflb(U32.is_eq({N_}, 0), {t_}, {N_}, dd, {Mk(k)}, {Xc}, {QX}, {RX}, {pfs})'
                P = ch.p
                pre = TEMPLATES.render('pfc_text', P=P)
            else:
                A_, N_ = ch.oargs
                if getattr(ch, 'xform', False):
                    # a list of records in the X form (its perfect lemma at X, not q, r)
                    pfs = f'{ch.alias}.pfLb_{ch.p}(U32.is_eq({N_}, 0), {A_}, {N_}, dd, {Mk(k)}, {Xc}, {pfs})'
                else:
                    pfs = f'{ch.alias}.pfLb_{ch.p}(U32.is_eq({N_}, 0), {A_}, {N_}, dd, {Mk(k)}, {QX}, {RX}, {pfs})'
    return pre + f'''
# pfC: the writer's tree is perfect (no hypothesis).
def pfC({OPS_}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}}) -> PFC({MA_}):
  {pfs}'''


# ==== unions in the encoder-window interface (UCONTS) ===========================================
# A generic union U: the runtime writes the selector byte s with O.w8 at X, then the arm's put at X + 1
# (proofs/obj/vunion.bend: sel_rt / sel_by / arm_e / aroom / arm_hz / ubytes / tag_v / tag_f). Its arms:
# a container through its interface encx_<A>_iface (EA_<A>), or a Data record of one uint8 (vrecb's
# W8P at the byte after the selector). encx_<U>_iface.bend states the interface's laws on its mirror MW.

UCONTS = ['CompatibleUnionA', 'CompatibleUnionBC', 'CompatibleUnionABCA']

UHEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/generic_obj.bend as T',
         'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/layout.bend as Layout', 'import ../../spec/primitives.bend as SP', 'import ./generic_specs.bend as Spec',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
         'import ./vuwd.bend as WD', 'import ./vcopy.bend as VC', 'import ./vrecx.bend as VRX', 'import ./vcont.bend as VCN', 'import ./vua_lay.bend as LY',
         'import ./vconts.bend as CS', 'import ./dk.bend as DK', 'import ./vunion.bend as VU', 'import ./vrecb.bend as VRB', 'import ./sub_pack.bend as SP2']


def ufile(U):
    return ROOT / f'proofs/obj/encx_{U}_iface.bend'


def union_arms(U):
    src = RR.mono_text('generic')
    m = re.search(rf'^type {U} is Type:\n((?:  .*\n)+)', src, re.M)
    arms = []
    for ln in m.group(1).rstrip('\n').split('\n'):
        mm = re.fullmatch(rf'  {U}_c(\d+)\{{v: (\w+)\}}', ln)
        j, A = int(mm.group(1)), mm.group(2)
        pt = re.search(rf'^def {U}_pt{j}\(.*\n  (.*)$', src, re.M).group(1)
        s = int(re.search(r'O\.w8\(out, pos, (\d+)\)', pt).group(1))
        if _has_iface(A):
            pk = re.search(rf'^def {A}_putk\(out: Array<U32>, \+pos: U32, o: {A}\) -> .*: (.*)$', src, re.M).group(1)
            assert pk == f'{A}_putn(out, pos, o)', (A, pk)
            arms.append(dict(j=j, A=A, s=s, kind='if'))
        else:
            assert re.search(rf'^type {A} is Data:\n  {A}\{{f_A: U32\}}\n', src, re.M), A
            assert re.search(rf'^    case {A}\{{\+f_A\}}: u8_valid\(f_A\)$', src, re.M)
            sz = re.search(rf'^    case {U}_c{j}\{{\+v\}}: \({U}_c{j}\{{v\}}, (\d+)\)$', src, re.M).group(1)
            assert sz == '2', (U, j, sz)
            arms.append(dict(j=j, A=A, s=s, kind='u8'))
    return arms


def _union_prelude(U):
    """the union's arms, the module header lines and the shared helper lemmas (PA, PB, and_l, and_r)"""
    arms = union_arms(U)
    TRU = 'True{} : Bool'
    TY = f'Array<U32> & (T.{U} & U32)'
    X0 = 'Nat.add(A.quad(q), r)'
    L = []
    w = L.append
    mods = []
    for a in arms:
        if a['kind'] == 'if' and f'import ./encx_{a["A"]}_iface.bend as EA_{a["A"]}' not in mods:
            mods.append(f'import ./encx_{a["A"]}_iface.bend as EA_{a["A"]}')
    w('')
    w('# GENERATED by container_encoder_windows (codegen). Do not edit.')
    w(f'# {U} in the encoder-window interface: its selector byte, then its arm at X + 1 (see the generator: union_text).')
    w('')
    w('def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:\n  (+a, +b) = p\n  a')
    w('def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:\n  (+a, +b) = p\n  b')
    w('def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}: FD.logic__and_left(a, b, h)')
    w('def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}: FD.logic__and_right(a, b, h)')
    if any(a['kind'] == 'u8' for a in arms):
        w('''
# ---- the one-byte record arm: its value and parts (one fixed byte) ----
def RV8(+x: U32) -> S.Value: S.Sequence{S.Items{VRB.UV8(x), S.EmptyItems{}}}
def rprf(+x: U32) -> {Codec.parts(RV8(x), Spec.ProgressiveSingleFieldContainerTestStruct()) == Some{[S.Fixed{[U32.and(x, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Items{VRB.UV8(x), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U8{}}, S.End{}}), Some{[S.Fixed{[U32.and(x, 255)]}]},
    FX.cat_fixed(Codec.parts(VRB.UV8(x), S.Unsigned{P.U8{}}), [U32.and(x, 255)], Codec.parts(S.EmptyItems{}, S.End{}), [], VRB.prt8(x), {==})) :
    {Codec.aggregate(_, Some{1n}) == Some{[S.Fixed{[U32.and(x, 255)]}]} : Maybe<&2, +List<S.Part>>}
  SP2.agg([S.Fixed{[U32.and(x, 255)]}], 1n, 1n, {==}, SP2.bd_app([U32.and(x, 255)], [], VRB.dom8(x), {==}), {==}, {==})''')
    return arms, TRU, TY, X0, L, w, mods


def _union_arm_names(U, a, j, A, S_, Sb, DS):
    """an arm's names: its record type, thaw, encoding, value, size and writer (the selector arm or the selector byte arm)"""
    if a['kind'] == 'if':
        ea = f'EA_{A}'
        xt = f'{ea}.MW'
        TH = f'T.{U}_c{j}{{{ea}.TH(x)}}'
        E = f'List.length(&2, U32, {ea}.ENC(x))'
        OK = f'Bool.and({ea}.OK(x), Nat.is_le(1n+{E}, A.quad(VB.pw(28n))))'
        ENC = f'Con{{{Sb}, {ea}.ENC(x)}}'
        VAL = f'S.Selected{{{S_}, {ea}.VAL(x)}}'
        SZ = f'O.padd({ea}.SZ(x), 1)'
        PUTX = f'{ea}.PUTX(x, dd, {DS}, VU.AQ(q, r), VU.AR(r))'
    else:
        xt = 'U32'
        TH = f'T.{U}_c{j}{{T.{A}{{x}}}}'
        E = '1n'
        OK = 'U32.is_le(x, 255)'
        ENC = f'Con{{{Sb}, [U32.and(x, 255)]}}'
        VAL = f'S.Selected{{{S_}, RV8(x)}}'
        SZ = '2'
        PUTX = f'VRB.W8P(dd, {DS}, Nat.add(0n, 1n+VU.X0(q, r)), x)'
    return xt, TH, E, OK, ENC, VAL, SZ, PUTX


def _union_arm_go_lemma(U, TRU, TY, L, w, a, j, A, S_, DS, xt, E, HYP, END):
    """an arm's go lemma and its statement inserted before the law"""
    if a['kind'] == 'if':
        ea = f'EA_{A}'
        B = f'Nat.is_le(1n+{E}, A.quad(VB.pw(28n)))'
        w(TEMPLATES.render('_union_arm_go_lemma', j=j, HYP=HYP, E=E, ea=ea, B=B, S_=S_, DS=DS))
        # the runtime chain, before go
        L.insert(len(L) - 1, TEMPLATES.render('_union_arm_go_lemma_2', j=j, xt=xt, ea=ea, TRU=TRU, S_=S_, DS=DS, A=A, U=U, END=END, TY=TY))
    else:
        P_ = 'Nat.add(0n, 1n+VU.X0(q, r))'
        Xn = 'Nat.add(A.quad(VU.AQ(q, r)), VU.AR(r))'
        Y0 = 'U32.add(U32.add(X, 1), 0)'
        PB_ = 'WD.PADB(VU.AR(r), 1n)'
        b8 = '[U32.and(x, 255)]'
        w(TEMPLATES.render('_union_arm_go_lemma_3', j=j, HYP=HYP, S_=S_, Xn=Xn, TRU=TRU, DS=DS, Y0=Y0, P_=P_, PB_=PB_, b8=b8))
        L.insert(len(L) - 1, TEMPLATES.render('_union_arm_go_lemma_4', j=j, TRU=TRU, S_=S_, DS=DS, Y0=Y0, U=U, END=END, TY=TY, A=A))


def _union_arm_prefix_lemma(U, TRU, w, a, j, A, S_, DS, xt, E):
    """an arm's prefix lemma"""
    if a['kind'] == 'if':
        ea = f'EA_{A}'
        B = f'Nat.is_le(1n+{E}, A.quad(VB.pw(28n)))'
        w(TEMPLATES.render('_union_arm_prefix_lemma', j=j, xt=xt, TRU=TRU, ea=ea, DS=DS, S_=S_, E=E, B=B, U=U, A=A))
    else:
        w(TEMPLATES.render('_union_arm_prefix_lemma_2', j=j, TRU=TRU, DS=DS, S_=S_, U=U, A=A))


def _union_ctor_text(U, arms, w, D):
    """the arms' constructors and the type text"""
    ctors = '\n'.join(f'  MW{a["j"]}{{x: {D[a["j"]]["xt"]}}}' for a in arms)

    def mt(ret, fn, extra='', args=''):
        cases = '\n'.join(f'    case MW{a["j"]}{{+x}}: {fn}{a["j"]}(x{args})' for a in arms)
        return f'  match m:\n{cases}'
    w(TEMPLATES.render('_union_ctor_text', ctors=ctors, U=U, mt=mt))


def union_text(U):
    arms, TRU, TY, X0, L, w, mods = _union_prelude(U)
    # per-arm definitions
    D = {}
    for a in arms:
        j, A, s = a['j'], a['A'], a['s']
        S_ = str(s)
        Sb = f'U32.and({s}, 255)'
        DS = f'VU.DS(dd, D, q, r, {S_})'
        xt, TH, E, OK, ENC, VAL, SZ, PUTX = _union_arm_names(U, a, j, A, S_, Sb, DS)
        D[j] = dict(xt=xt)
        w(TEMPLATES.render('union_text', j=j, A=A, s=s, xt=xt, U=U, TH=TH, OK=OK, ENC=ENC, VAL=VAL, SZ=SZ, PUTX=PUTX, TY=TY, X0=X0))
        HYP = (TEMPLATES.render('union_text_2', xt=xt, X0=X0, TRU=TRU, j=j))
        END = f'(FD.array__thaw(U32, PUTX{j}(x, dd, D, q, r)), (TH{j}(x), SZ{j}(x)))'
        _union_arm_go_lemma(U, TRU, TY, L, w, a, j, A, S_, DS, xt, E, HYP, END)
        # the arm's other facts
        _union_arm_prefix_lemma(U, TRU, w, a, j, A, S_, DS, xt, E)
    # the mirror and the interface
    _union_ctor_text(U, arms, w, D)
    LH = ['for +m: MW', 'for +dd: Nat', 'for +D: FD.array__Tree<U32>', 'for +X: U32', 'for +q: Nat', 'for +r: Nat',
          'for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}', 'for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}',
          'for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}', 'for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}',
          'for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}',
          'for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}',
          'for +hok: {OK(m) == True{} : Bool}']
    LHs = '\n  '.join(LH)
    cs = lambda body: '\n'.join(f'    case MW{a["j"]}{{+x}}: ' + body(a['j']) for a in arms)  # noqa: E731
    GA = 'x, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok'
    w(f'''law putx:
  {LHs}
  {{T.{U}_putk(FD.array__thaw(U32, D), X, TH(m)) == (FD.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : {TY}}}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
{cs(lambda j: f"PA(RT{j}(x, dd, D, X, q, r), BY{j}(x, dd, D, q, r), go{j}({GA}))")}

law putx_bytes:
  {LHs}
  {{UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
{cs(lambda j: f"PB(RT{j}(x, dd, D, X, q, r), BY{j}(x, dd, D, q, r), go{j}({GA}))")}

law szx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}}
def szx(m, hok):
  match m:
{cs(lambda j: f"szk{j}(x, hok, 28n, {{==}})")}

law bndx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  for +k: Nat
  for +ek: {{k == 28n : Nat}}
  {{Nat.is_le(List.length(&2, U32, ENC(m)), A.quad(VB.pw(k))) == True{{}} : Bool}}
def bndx(m, hok, k, ek):
  match m:
{cs(lambda j: f"bnd{j}(x, hok, k, ek)")}

law encx_spec:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{Codec.parts(VAL(m), Spec.{U}()) == Some{{[S.Variable{{ENC(m)}}]}} : Maybe<&2, +List<S.Part>>}}
def encx_spec(m, hok):
  match m:
{cs(lambda j: f"spec{j}(x, hok)")}

law domx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{SP.bytes_domain(ENC(m)) == True{{}} : Bool}}
def domx(m, hok): CS.domv(VAL(m), Spec.{U}(), ENC(m), {{==}}, encx_spec(m, hok))

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +q: Nat
  for +r: Nat
  for +pf: {{FD.array__perfect(U32, dd, D) == True{{}} : Bool}}
  {{FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{{}} : Bool}}
def pfx(m, dd, D, q, r, pf):
  match m:
{cs(lambda j: f"pfx{j}(x, dd, D, q, r, pf)")}

law sizex:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{T.{U}_size(TH(m)) == (TH(m), SZ(m)) : T.{U} & U32}}
def sizex(m, hok):
  match m:
{cs(lambda j: f"size{j}(x, hok)")}

law validx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{T.{U}_valid(TH(m)) == (TH(m), True{{}}) : T.{U} & Bool}}
def validx(m, hok):
  match m:
{cs(lambda j: f"valid{j}(x, hok)")}
''')
    if all(a['kind'] == 'u8' for a in arms):
        w(f'''law maxx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{Nat.is_le(List.length(&2, U32, ENC(m)), 2n) == True{{}} : Bool}}
def maxx(m, hok):
  match m:
{cs(lambda j: "{==}")}
''')
    return '\n'.join(UHEAD + mods) + '\n' + '\n'.join(L)


# ---- the dd < 31 twins (deep.dify_out's post pass) ------------------------------------------------------------
# hl32 (the region's end below 2^32) and hs31 (the region's length below 2^31: the padd cursors' poison bit)
# beside hl in the twins that need them; the fields' strict starts; the cursors' bounds from hs31.
def cont_strict(q, t, res):
    from codegen.proofs.support import deep_window_decode_passes as deep
    P32 = 'FD.spec_common__pow2(32n)'
    # a fixed field starts inside the region: 4 k < L (the literal check, strict)
    t = deep.edit_calls(t, 'VRX.fposW', lambda a, blk: a[:10] + ([a[10].replace('FD.nat__le_trans(', 'FD.nat__lt_le_trans(', 1)] if a[10].startswith('FD.nat__le_trans(') else [a[10]]) + a[11:])
    # a piece of m >= 1 bytes (a literal m)
    for n in ('VPC.pposW', 'VPC.proomW'):
        t = deep.edit_calls(t, n, lambda a, blk: a[:12] + ['{==}'] + a[12:])
    t, bad1 = deep.hl32_pass(needed_only=True, derive={'croom': 'croom32', 'proomW': 'proom32', 'aroom': 'aroom32', 'hlm': 'hlm32'})(q, t, res)
    t, bad2 = deep.hs31_pass(seeds={'VCN.cnextW', 'VCN.cnext_rW'}, derive={'aroom': 'aroom31', 'hlm': 'hlm31'})(q, t, res)
    # the cursors below 2^31 (O.padd): VCN.pc_end31 by hs31
    def pc(a, blk):
        la = a[-1]
        if not la.startswith('VCN.pc_end('):
            return None
        b, _ = deep._args(la, len('VCN.pc_end('))
        if b[-1] != 'hl':
            return None
        return a[:-1] + ['VCN.pc_end31(' + ', '.join(b[:-1] + ['hs31']) + ')']
    for n in ('VCN.cnextW', 'VCN.cnext_rW'):
        t = deep.edit_calls(t, n, pc)
    # a transactions-like list's size: below 2^31 by its region (VCN.croom31)
    def sz(a, blk):
        if len(a) != 6 or a[3] != '30n':
            return None
        if not a[5].startswith('FD.nat__le_trans('):
            return None
        lt, _ = deep._args(a[5], len('FD.nat__le_trans('))
        if not lt[3].startswith('VCN.pc_end('):
            return None
        pe, _ = deep._args(lt[3], len('VCN.pc_end('))
        hlc = pe[-1]
        lm = None
        for lm in re.finditer(r'^\s*\+' + re.escape(hlc) + r' = ', blk, re.M):
            pass
        if not lm:
            return None
        ex, _ = deep._args(blk, lm.end() + len('VCN.croom('))
        if not blk[lm.end():].startswith('VCN.croom('):
            return None
        return a[:3] + ['VCN.croom31(' + ', '.join(ex[:-1] + ['hs31']) + ')']
    for al in sorted(set(re.findall(r'(?<![\w.])(\w+)\.szx\(', t))):
        t = deep.edit_calls(t, al + '.szx', sz, rename=al + '.szxS')
    # OKW: the container encodings below 2^31 bytes (codegen/proofs/support/encode_size_limit_twins.py): the ifaces' twins, the writers' children on OKW
    from codegen.proofs.support import encode_size_limit_twins as okw
    child = set()
    for mi in re.finditer(r'^import \./(\w+)\.bend as (\w+)$', t, re.M):
        if mi.group(1) in _OKT_MODS:
            child.add(mi.group(2) + '.')
    bad3 = []
    if q.stem in OKW_SKIP:
        # (its OKW twins in the companion module only: the base module keeps its size, and its importers' check time)
        dch = q.stem in okw.LIST_D_STEMS
        if 'def OKT(' in t:
            tf, bad3 = okw.okw_iface(t, child, olaws=okw.OLAWS_C, keep=True, dchild=dch)
            _COMP[q] = (t, tf)
        elif 'def PUTC(' in t:
            _COMP[q] = (t, okw.okw_writer(t, child, dchild=dch))
    elif 'def OKT(' in t:
        dch = q.stem in okw.LIST_D_STEMS   # (its list children in D form)
        tf, _ = okw.okw_iface(t, child, olaws=okw.OLAWS_C, keep=True, dchild=dch)
        t, bad3 = okw.okw_iface(t, child, dchild=dch)
        _COMP[q] = (t, tf)   # (the size and validity passes on OKW: the companion <iface>_o, main)
    elif 'def PUTC(' in t:   # (a container writer; the unions keep their arms on OK)
        t = okw.okw_writer(t, child, dchild=q.stem in okw.LIST_D_STEMS)
    return t, bad1 + bad2 + bad3


_OKT_MODS = set()
_COMP = {}
OKW_SKIP = {'encx_BeaconState_iface', 'encx_BeaconState'}   # (their OKW twins live in the companions only)


SKIPPED = []


def build_all():
    """{path: text} of every module. A module that reads a file a sibling generator has not written yet
    (from-scratch regeneration: variable_element_list_encoders's list encoders need this generator's interfaces, and the
    containers using them need the lists) is skipped and named in SKIPPED: write mode leaves it to the
    next pass, --check reports it stale."""
    nxt = {}
    jobs = [(out_file(C), lambda C=C: full_text(C)) for C in CONTS]
    jobs += [(gfile_c(C), lambda C=C: full_text(C, generic=True)) for C in GCONTS]
    jobs += [(iface_file(C), lambda C=C, gen=gen: iface_full(C, gen)) for C, gen in ICONTS]
    jobs += [(ufile(U), lambda U=U: union_text(U)) for U in UCONTS]
    for f, mk in jobs:
        try:
            nxt[f] = mk()
        except FileNotFoundError as e:
            SKIPPED.append(f'{pathlib.Path(f).name} (needs {str(e.filename).rsplit('/', 1)[-1] if '/' in str(e.filename) and not str(e.filename).startswith('child ') else e.filename})')
    return nxt


def main():
    out = {}
    out = build_all()
    # to the fixed point, in this run: a module's text may read its children's (GEN)
    global _STD
    for _ in range(8):
        GEN.clear()
        GEN.update(out)
        _STD = None
        SKIPPED.clear()
        nxt = build_all()
        if nxt == out:
            break
        out = nxt
    else:
        raise SystemExit('container_encoder_windows: no fixed point in 8 rounds')
    out = RR.rewire_out(out)
    global _OKT_MODS
    _OKT_MODS = {pathlib.Path(q).stem for q, t in out.items() if 'def OKT(' in t}
    out = _deep.dify_out(out, handled={'fposW'}, post=cont_strict)  # the dd < 31 twins
    # the ifaces' companions (codegen/proofs/support/encode_size_limit_twins.py okw_companion): the O laws only their callers check
    from codegen.proofs.support import encode_size_limit_twins as okw
    comp = {}
    for q, (tb, tf) in _COMP.items():
        if q in out:
            c = okw.okw_companion(out[q], tf, q.stem, 'the size and validity passes on OKW (encodings below 2^31 bytes) of ' + q.stem, 'container_encoder_windows')
            if c:
                comp[q.with_name(q.stem + '_o.bend')] = c
    names = {q.stem[:-2]: okw._names(c) for q, c in comp.items()}
    names.update({f'encx_{C}_size': {x + 'O' for x in okw.SLAWS} for C in ('ExecutionPayload', 'ExecutionPayloadHeader', 'BeaconBlockBody', 'ProgressiveBitsStruct')})
    out.update({q: okw.okw_relink(c, names) for q, c in comp.items()})
    from codegen.core import retired_module_list as retired  # modules nothing imports: not written (codegen/core/retired_module_list.py)
    out = retired.drop(out)
    if '--check' in sys.argv:
        stale = [str(q.relative_to(ROOT)) for q, t in out.items() if not q.exists() or q.read_text() != t]
        if stale or SKIPPED:
            print('stale generated container encoder windows: ' + ', '.join(stale + ['skipped: ' + s for s in SKIPPED]))
            sys.exit(1)
        print('generated container encoder windows are current')
        return
    for q, t in out.items():
        q.write_text(t)
    print(', '.join(str(q.relative_to(ROOT)) for q in out))


if __name__ == '__main__':
    main()
