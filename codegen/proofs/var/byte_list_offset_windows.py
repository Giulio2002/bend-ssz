#!/usr/bin/env python3
"""Byte-list names at a window at ANY byte offset: the byte-offset window
interface of proofs/obj/vua_win.bend for the names of codegen/proofs/var/byte_list_codec_laws.py.

    python3 codegen/proofs/var/byte_list_offset_windows.py [--check]

For a name X of byte_list_codec_laws.py (fixed fields around one byte list), the module
proofs/obj/var_bytesx_X.bend exports, for a window [off, off + len) of
UA.BF(t, n) with off at byte position x (eo: to_nat off == x, hd: d < 28,
hw: x + len <= 4 2^d, pf: t perfect of depth d):

  CHKw(t, x, off, len), ok_evalw   the validator returns CHKw;
  OBJw(d, t, x, off, len), readw   when CHKw holds the reader returns OBJw: its
                                   fixed fields' words are the four-byte joins
                                   UR.RWN(t, x + c) (vua_fix / vbx_fix rdx_*),
                                   its byte vectors and byte list the copies
                                   UCT.CT (vbx.copy_into_at, vua_ct.copy_in_at);
  VALw(t, x, len), specw           the spec parts of VALw are the window's
                                   bytes UW.WX(t, x, len), one variable part;
  invw                             every value with those parts passes CHKw.

VALw's fixed fields are built from the words RWN(t, x + c) and its byte list
is the window's tail WX(t, 4 H + x, len - FS); specw splits the window with
UW.headWX. invw runs the spec inversion of byte_list_codec_laws.py's rejection module
(written here without its whole-buffer part, as var_bytesx_X_inv.bend) and
reads the offset word back with UW.byteWX.

proofs/obj/vbx_fix.bend holds the rdx_* readers vua_fix.bend lacks;
proofs/obj/vbx.bend (hand-written) holds copy_into_at.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.proofs.var.check_or_write_outputs import finish  # noqa: E402

from codegen.impl import typed_object_runtime as G  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.proofs.var import single_list_container_codec_laws as VL  # noqa: E402
from codegen.proofs.var import unaligned_read_laws as VUA  # noqa: E402
from codegen.proofs.var import byte_list_codec_laws as VBY  # noqa: E402
from codegen.proofs.laws import spec_connected_codec_laws as SL  # noqa: E402
from codegen.proofs.var import nested_byte_list_codec_laws as VBN  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('byte_list_offset_windows', globals())
NAMES = ['ExecutionPayloadHeader']
# names nesting a covered name (codegen/proofs/var/nested_byte_list_codec_laws.py), in dependency order
NEST = ['LightClientHeader']


def spec_names(n):
    """The field-name list of spec/fulu_schemas.bend's container Spec.n(), as Bend text."""
    src = (VBY.ROOT / 'spec/fulu_schemas.bend').read_text()
    m = re.search(rf'^def {n}\(\) -> T\.Schema: (\w+)\(\)$', src, re.M)
    name = m.group(1) if m else n
    m2 = re.search(rf'^def {name}\(\) -> T\.Schema: T\.Container\{{(\[[^\]]*\])', src, re.M)
    assert m2, n
    return m2.group(1)


def seq_step(n, v, items, chain, rhs, MP):
    """The rewrite of Codec.parts(v, Spec.n()) to Codec.aggregate(Codec.parts(items, chain), SC.fixed_size(chain))
    by VSQ.seq_parts (proofs/obj/vseq.bend): no conversion evaluates the whole container (checker_findings item 2)."""
    return (f'  %Equal.sym({MP}, Codec.parts({v}, Spec.{n}()), Codec.aggregate(Codec.parts({items}, {chain}), SC.fixed_size({chain})),\n'
            f'      VSQ.seq_parts({v}, Spec.{n}(), {items}, {spec_names(n)}, {chain}, {{==}}, {{==}})) :\n'
            f'    {{_ == {rhs} : {MP}}}\n')

def posx(c):
    """c + x as a chain of successors (a literal above 256 would parse as Nat.add)."""
    if c == 0:
        return 'x'
    s, r = '', c
    while r > 256:
        s += '256n+'
        r -= 256
    return f'{s}{r}n+x'


def rwn(c):
    return f'UR.RWN(t, {posx(c)})'


def vtx_types():
    src = (ROOT / 'proofs/obj/vua_fix.bend').read_text()
    return {ln.split('(')[0][len('def rdx_'):] for ln in src.splitlines() if ln.startswith('def rdx_')}


class XName(VBY.Name):
    def slot(self, k):
        return rwn(4 * k)

    def obj(self, f):
        if f['kind'] == 'fix':
            return f['ft'].obj(self.words(f))
        if f['kind'] == 'words':
            return f'O.Words{{FD.array__thaw(U32, UCT.CT(d, t, U32.add(off, {f["c"]}), {f["size"]}, {f["dz"]}n)), {f["size"]}}}'
        return f'O.Words{{FD.array__thaw(U32, UCT.CT(d, t, U32.add(off, {self.FS}), LL(len), DZ(len))), LL(len)}}'


def fname(x, part=''):
    return ROOT / f'proofs/obj/var_bytesx_{x.n}{part}.bend'


# ---- the readers vua_fix.bend lacks -----------------------------------------------------------

def fix_module(fts):
    have = vtx_types()
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T',
         'import ../compact/found.bend as F', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', '',
         '# GENERATED by byte_list_offset_windows (codegen). Do not edit.',
         '# T.<p>_read at an offset off at ANY byte position x, for the fixed field types of',
         '# codegen/proofs/var/byte_list_offset_windows.py that proofs/obj/vua_fix.bend lacks (as codegen/proofs/var/unaligned_read_laws.py rdx_lemma).', '']
    for ft in fts:
        if ft.p in have:
            continue
        for ln in VUA.rdx_lemma(ft):
            ln = ln.replace('ltp(', 'VTX.ltp(')
            for kp in have:
                ln = ln.replace(f'rdx_{kp}(', f'VTX.rdx_{kp}(')
            L.append(ln)
        L.append('')
    # the same at any tree depth d < 31 (rdxd_: the offsets below 2^32)
    for ft in fts:
        if ft.p in have:
            continue
        for ln in VUA.rdx_lemma(ft, deep=True):
            ln = ln.replace('ltp(', 'VTX.ltp(')
            for kp in have:
                ln = ln.replace(f'rdxd_{kp}(', f'VTX.rdxd_{kp}(')
            L.append(ln)
        L.append('')
    return '\n'.join(L) + '\n'


def rdx_ref(ft):
    return f'VTX.rdx_{ft.p}' if ft.p in vtx_types() else f'XF.rdx_{ft.p}'


# ---- the spec inversion, without the whole-buffer part ----------------------------------------

def inv_text(x):
    L = [ln for ln in VBY.rej_text(x, pure=True) if not (ln.startswith('import ./') and (' as W' in ln or ' as DC' in ln))]
    L = [writer.rebrand(ln, 'byte_list_codec_laws', 'byte_list_offset_windows') for ln in L]
    q = VL.REJ
    q = q[q.index('def q0('):q.index('def ec_sub(')]
    fsb = [x.FS & 255, (x.FS >> 8) & 255, (x.FS >> 16) & 255, (x.FS >> 24) & 255]
    for a, b in [('@FSL', '[' + ', '.join(map(str, fsb)) + ']'), ('@FS', str(x.FS)),
                 ('@B0', str(fsb[0])), ('@B1', str(fsb[1])), ('@B2', str(fsb[2])), ('@B3', str(fsb[3]))]:
        q = q.replace(a, b)
    L.append(q.rstrip() + '\n')
    for line in TPL.render('inv_text_lines', x=x).split('\n'):
        L.append(line)
    return '\n'.join(L) + '\n'


# ---- the window module --------------------------------------------------------------------------

HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec', 'import ./spec_fixed.bend as F',
        'import ../../spec/schema.bend as SC', 'import ./vseq.bend as VSQ', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU', 'import ./vcopy.bend as VC',
        'import ./vdepth.bend as VD', 'import ./vbytes.bend as VY', 'import ./vbspec.bend as VZ', 'import ./vbrt.bend as VRT',
        'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_win.bend as UW', 'import ./vua_ct.bend as UCT',
        'import ./vua_fix.bend as VTX', 'import ./vbx_fix.bend as XF', 'import ./vbx.bend as VBX']

WHX = ('+eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
       '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}')
PF = '+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}'
P4 = 'A.quad(VB.pw(d))'


def between(s, a, b):
    i = s.index(a)
    return s[i:s.index(b, i)]


def win_text(x):
    n, FS, H, po, cvar, LIM, KY, KZ = x.n, x.FS, x.H, x.po, x.cvar, x.LIM, x.KY, x.KZ
    Tn = f'T.{n}'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    HX = '+hx: {BLW(LL(len)) == True{} : Bool}'
    MP = 'Maybe<&2, +List<S.Part>>'
    BF = 'UA.BF(t, n)'
    al = VBY.win_text(x)
    L = list(HEAD) + [f'import ./{fname(x, "_inv").name} as XI', '', '# GENERATED by byte_list_offset_windows (codegen). Do not edit.',
                      f'# {n} at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend',
                      '# (see the module docstring of codegen/proofs/var/byte_list_offset_windows.py).', '']
    w = L.append
    w(between(al, 'def chk3(', '# The byte list\'s check'))
    w(TPL.render('win_text', FS=FS, LIM=LIM, cvar=cvar))
    w(between(al, 'def c1_id(', 'def winb('))
    w(TPL.render('win_text_hcx', BF=BF, FS=FS, HA=HA, Tn=Tn, cvar=cvar))
    w(between(al, 'def hLx(', '# The byte list\'s words lie in the buffer'))
    w(between(al, '# The storage of the byte list: depth', '# The byte list\'s storage: the masked copy'))
    w(TPL.render('win_text_hsv', BF=BF, FS=FS, HA=HA, cvar=cvar))
    # ---- the reader ----
    leaves, OBJ = VBY.read_plan(x)
    OBJ = OBJ.replace('VF.BF(t, n)', BF)
    RHS = f'({BF}, OBJw(d, t, x, off, len))'
    TY = f'B.Buf & {Tn}'
    for line in TPL.render('win_text_lines', BF=BF, FS=FS, HA=HA, HX=HX, OBJ=OBJ, RHS=RHS, TY=TY, Tn=Tn).split('\n'):
        w(line)

    def ecf(c):
        return f'eoc(d, x, off, len, {c}, {{==}}, eo, hd, hw, ha)'
    for ctx, call, val, kind, f in leaves:
        ctx = ctx.replace('VF.BF(t, n)', BF)
        call = call.replace('VF.BF(t, n)', BF)
        pat = ctx.replace('@', '_')
        if kind == 'off':
            w(f'  %Equal.sym(B.Buf & U32, {call}, ({BF}, {val}), rdo(d, t, n, x, off, len, eo, hd, hw, pf, ha, epo)) :')
        elif kind == 'fix':
            ft = f['ft']
            c = f['c']
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {call}, ({BF}, {val}),')
            w(f'      {rdx_ref(ft)}(d, t, n, U32.add(off, {c}), {posx(c)}, {ecf(c)}, hd30, pf, roomc(d, x, len, {c}n, {ft.size}n, {{==}}, hw, ha))) :')
        elif kind == 'words':
            c, z = f['c'], f['size']
            kw = VBY.kfit(31 + z)
            hs = (f'UW.hsx(d, U32.add(off, {c}), Nat.add(U32.to_nat({c}), x), {z}, {ecf(c)}, hd, '
                  f'roomc(d, x, len, U32.to_nat({c}), U32.to_nat({z}), {{==}}, hw, ha))')
            w(f'  %Equal.sym(B.Buf & O.Words, {call}, ({BF}, {val}),')
            w(f'      VBX.copy_into_at(d, t, n, U32.add(off, {c}), {z}, {f["dz"]}n, {kw}n, pf, hd31, {{==}}, {hs}, {{==}}, {{==}}, {{==}})) :')
        else:
            for line in TPL.render('win_text_lines_2', BF=BF, FS=FS, KY=KY, call=call, val=val).split('\n'):
                w(line)
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(TPL.render('win_text_readw', BF=BF, FS=FS, RHS=RHS, TY=TY, Tn=Tn))
    L.extend(spec_part(x))
    L.extend(inv_part(x))
    return '\n'.join(L) + '\n'


def spec_part(x):
    n, FS, H, po, LIM = x.n, x.FS, x.H, x.po, x.LIM
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    HX = '+hx: {BLW(LL(len)) == True{} : Bool}'
    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, CDEFS = VBY.spec_items(x, 'Y', named=('XC', '+t: FD.array__Tree<U32>, +x: Nat, +Y: +List<U32>', 't, x, Y', '+t: FD.array__Tree<U32>, +x: Nat, +Y: +List<U32>', 't, x, Y',
        '+t: FD.array__Tree<U32>, +x: Nat, +Y: +List<U32>, +hdom: {SP.bytes_domain(Y) == True{} : Bool}, +hlen: {Nat.is_le(List.length(&2, U32, Y), ' + f'{x.LIM}' + 'n) == True{} : Bool}', 't, x, Y, hdom, hlen'))
    CDEF = '\n'.join(CDEFS)
    HDR = '[' + ', '.join(hdr) + ']'
    hdrh = '[' + ', '.join(h if j != po else '_' for j, h in enumerate(hdr)) + ']'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    ENC = f'List.append(&2, U32, F.limbs({HDR}), Y)'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), Y)'
    YX = f'UW.WX(t, Nat.add(A.quad({H}n), x), U32.to_nat(LL(len)))'
    WX = 'UW.WX(t, x, U32.to_nat(len))'
    L4 = 'U32.to_nat(LL(len))'
    return [f'''
# ---- the spec side ------------------------------------------------------------------------------

# The value of the window's fixed words and byte list Y, through its named field suffixes.
{CDEF}
def XVw(+t: FD.array__Tree<U32>, +x: Nat, +Y: +List<U32>) -> S.Value: S.Sequence{{{ITEMS}}}

# Its spec parts: one variable part, the header's bytes (the offset is {FS}) and Y.
def encpw(+t: FD.array__Tree<U32>, +x: Nat, +Y: +List<U32>, +hdom: {{SP.bytes_domain(Y) == True{{}} : Bool}},
    +hlen: {{Nat.is_le(List.length(&2, U32, Y), {LIM}n) == True{{}} : Bool}})
    -> {{Codec.parts(XVw(t, x, Y), Spec.{n}()) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}:
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, Y)), Nat.add({FS}n, {LIM}n),
    Order.add_left({FS}n, List.length(&2, U32, Y), {LIM}n, hlen), {{==}})
{seq_step(n, 'XVw(t, x, Y)', ITEMS, CHAIN, f'Some{{[S.Variable{{{ENC}}}]}}', MP)}  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PL}}},
      {CAT}) :
    {{Codec.aggregate(_, SC.fixed_size({CHAIN})) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, Y, {POST})), Some{{{ENCR}}}, VZ.enc_fpvb({PRE}, Y, {POST}, hdom, fit)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  {{==}}

# The byte list's value: the window's bytes after the header.
def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: XVw(t, x, {YX})
# VALw's body, as a rewrite (a spec-parts goal over VALw compared with one over its body ran the spec encoder)
def VALq(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {{XVw(t, x, {YX}) == VALw(t, x, len) : S.Value}}: {{==}}

# The window is the header's words and the byte list's bytes.
def hwH(+d: Nat, +x: Nat, +len: U32, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{Nat.is_le(Nat.add(x, Nat.add(A.quad({H}n), {L4})), A.quad(VB.pw(d))) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)) : {{Nat.is_le(Nat.add(x, _), A.quad(VB.pw(d))) == True{{}} : Bool}}
  hw

def hwY(+d: Nat, +x: Nat, +len: U32, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA})
    -> {{Nat.is_le(Nat.add(Nat.add(A.quad({H}n), x), {L4}), A.quad(VB.pw(d))) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad({H}n), x), {L4}), Nat.add(x, Nat.add(A.quad({H}n), {L4})), Equal.trans(Nat, Nat.add(Nat.add(A.quad({H}n), x), {L4}), Nat.add(A.quad({H}n), Nat.add(x, {L4})), Nat.add(x, Nat.add(A.quad({H}n), {L4})),
    FD.nat__add_assoc(A.quad({H}n), x, {L4}), FD.lru_nat_algebra__add_swap(A.quad({H}n), x, {L4}))) : {{Nat.is_le(_, A.quad(VB.pw(d))) == True{{}} : Bool}}
  hwH(d, x, len, hw, ha)

def len_y(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {PF}, +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, {HX})
    -> {{Nat.is_le(List.length(&2, U32, {YX}), {LIM}n) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {YX}), {L4}, UW.lenWX(d, t, Nat.add(A.quad({H}n), x), {L4}, pf, hwY(d, x, len, hw, ha))) : {{Nat.is_le(_, {LIM}n) == True{{}} : Bool}}
  hLx(len, hx)

def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {PF},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}})
    -> {{List.append(&2, U32, F.limbs({HDR}), {YX}) == {WX} : +List<U32>}}:
  %enFS(len, ha) : {{List.append(&2, U32, F.limbs({HDR}), {YX}) == UW.WX(t, x, _) : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad({H}n), {L4})), List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), {YX}),
      UW.headWX(d, t, x, {H}n, {L4}, pf, hwH(d, x, len, hw, ha))) :
    {{List.append(&2, U32, F.limbs({HDR}), {YX}) == _ : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({hdrh}), {YX}) == List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), {YX}) : +List<U32>}}
  {{==}}

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +len: U32, {PF},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}}, {HX})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  %VALq(t, x, len) :
    {{Codec.parts(_, Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}
  %bytesw(d, t, x, len, pf, hw, ha, epo) :
    {{Codec.parts(XVw(t, x, {YX}), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  encpw(t, x, {YX}, UW.domWX(t, Nat.add(A.quad({H}n), x), {L4}), len_y(d, t, x, len, pf, hw, ha, hx))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF},
    +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, x), {FS})
  +c = BLW(U32.sub(len, SPOw(t, x)))
  +epo = FD.u32alg__eq_of(SPOw(t, x), {FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, x, len, pf, hw, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {{BLW(U32.sub(len, z)) == True{{}} : Bool}}, SPOw(t, x), {FS}, epo, chk_c(a, b, c, hchk)))
''']


def inv_part(x):
    n, FS, H, po, cvar, LIM = x.n, x.FS, x.H, x.po, x.cvar, x.LIM
    R = FS - cvar - 4
    fsb = [FS & 255, (FS >> 8) & 255, (FS >> 16) & 255, (FS >> 24) & 255]
    FSL = '[' + ', '.join(map(str, fsb)) + ']'
    WX = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    return [TPL.render('inv_part', FS=FS, FSL=FSL, LIM=LIM, MP=MP, R=R, WX=WX, cvar=cvar, n=n)]


# ---- names nesting a covered name ---------------------------------------------------------------

class XNName(VBN.NName):
    def slot(self, k):
        return rwn(4 * k)

    @property
    def JX(self):
        return posx(self.FS)

    def yobj(self):
        return f'YW.OBJw(d, t, {self.JX}, U32.add(off, {self.FS}), LL(len))'

    def obj(self, f):
        if f['kind'] == 'fix':
            o = f['ft'].obj(self.words(f))
            return f'O.BSome{{{o}, O.BNone{{}}}}' if f['box'] else o
        if f['kind'] == 'words':
            return XName.obj(self, f)
        if f['kind'] == 'var':
            o = self.yobj()
            return f'O.BSome{{{o}, O.BNone{{}}}}' if f['box'] else o
        raise VBY.Skip('field kind ' + f['kind'])


def win_deep(text, FS):
    """The window at any depth d < 31 (hw32: the window's end below 2^32, nested_type_window_laws.deep_x): header offsets by
    VB.add_lt32, the fields by rdxd_, the copies by UW.hsxB (their lengths bound the storage), the old
    interface as wrappers."""
    from codegen.proofs.support import deep_window_decode_passes as deep
    from codegen.proofs.var import nested_type_window_laws as VW
    P32 = 'FD.spec_common__pow2(32n)'
    T = 'True{} : Bool'
    EOC = f'  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}), hcx(d, x, len, U32.to_nat(c), hc, hw, ha))'
    HSV = ('  UW.hsx(d, U32.add(off, {FS}), Nat.add(U32.to_nat({FS}), x), LL(len), eoc(d, x, off, len, {FS}, {{==}}, eo, hd, hw, ha), hd, hwv(d, x, len, hw, ha))'
           .format(FS=FS))
    reps = [
        (EOC, '  VB.add_lt32(off, c, x, eo, hcx32(x, len, U32.to_nat(c), hc, hw32, ha))'),
        (HSV, HSV.replace('UW.hsx(', 'UW.hsxB(').replace(', hd, hwv(', ', 6n, {==}, hyL(len, hx), hwv(')),
        ('hsv(d, x, off, len, eo, hd, hw, ha)', 'hsv(d, x, off, len, eo, hd, hw, ha, hx)'),
        ('  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {==})\n', ''),
        ('  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})\n', ''),
        ('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd'),
    ]
    for a, b in reps:
        assert a in text, a[:80]
        text = text.replace(a, b)
    # hsv takes the byte list's check (its length bounds the storage)
    a = text.index('\ndef hsv(')
    b = text.index(')\n    -> ', a)
    text = text[:b] + ', +hx: {BLW(LL(len)) == True{} : Bool}' + text[b:]
    text = re.sub(r'(VTX|XF)\.rdx_(\w+)\(', r'\1.rdxd_\2(', text)
    text = text.replace(', hd30, pf, ', ', hd, pf, ').replace('pf, hd31, ', 'pf, hd, ')
    # the byte vectors' copies: their lengths bound the storage (31 + L <= 2^k)
    while True:
        m = re.search(r'UW\.hsx\(d, (U32\.add\(off, \d+\)), (Nat\.add\(U32\.to_nat\(\d+\), x\)), (\d+), ', text)
        if not m:
            break
        L_ = int(m.group(3))
        k = (31 + L_ - 1).bit_length()
        p0 = text.index('(', m.start()) + 1
        b = deep._close(text, p0)
        args = deep._split_args(text[p0:b])
        assert args[5].strip() == 'hd', args[5]
        args = args[:5] + [f' {k}n', ' {==}', ' {==}'] + args[6:]
        text = text[:m.start()] + 'UW.hsxB(' + ','.join(args) + ')' + text[b + 1:]
    # c + x below 2^32 for a header byte c
    a = text.index('\ndef eoc(')
    hcx32 = (TPL.render('hcx32', FS=FS, P32=P32, T=T))
    text = text[:a + 1] + hcx32 + text[a + 1:]
    left = [l for l in text.split('\n') if re.search(r'lt_trans\(d, 28n|UW\.hsx\(|\.rdx_\w+\(|add_le_at\(|VFT\.fits4\(|VMR\.fitsn\(', l)]
    assert not left, left[:3]
    # helpers other modules call keep their signatures (roomc, hwv: hw renamed hl, so not threaded; eoc: a wrapper)
    from codegen.proofs.var import variable_element_list_windows as VVL
    for nm in ('roomc', 'hwv'):
        text = VVL._keep_sig(text, nm)
    return VW.deep_x(text, VW.XIFACE + ['eoc'])


def xn_inv_text(x):
    drop = (' as W', ' as DC', ' as YW', ' as YR')
    L = [ln for ln in VBN.rej_text(x, pure=True) if not (ln.startswith('import ./') and ln.endswith(drop))]
    L = [writer.rebrand(ln, 'nested_byte_list_codec_laws', 'byte_list_offset_windows') for ln in L]
    q = VL.REJ
    q = q[q.index('def q0('):q.index('def ec_sub(')]
    fsb = [x.FS & 255, (x.FS >> 8) & 255, (x.FS >> 16) & 255, (x.FS >> 24) & 255]
    for a, b in [('@FSL', '[' + ', '.join(map(str, fsb)) + ']'), ('@FS', str(x.FS)),
                 ('@B0', str(fsb[0])), ('@B1', str(fsb[1])), ('@B2', str(fsb[2])), ('@B3', str(fsb[3]))]:
        q = q.replace(a, b)
    L.append(q.rstrip() + '\n')
    for line in TPL.render('xn_inv_text_lines', x=x).split('\n'):
        L.append(line)
    return '\n'.join(L) + '\n'


def xn_win_deep(text, FS):
    """The nested window (a fixed header and one variable child) at any depth d < 31 (hw32: the window's end
    below 2^32): header offsets by VB.add_lt32, the fields by rdxd_, the copies by UW.hsxB, the fit of the
    length by every U32 fitting four bytes, the child through its D interface (hwY32). The old interface stays
    under the old names as wrappers (with eoc / ecY); hwY, roomc, hcx keep their signatures."""
    from codegen.proofs.support import deep_window_decode_passes as deep
    from codegen.proofs.var import nested_type_window_laws as VW
    from codegen.proofs.var import variable_element_list_windows as VVL
    P32 = 'FD.spec_common__pow2(32n)'
    T = 'True{} : Bool'
    EOC = f'  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}), hcx(d, x, len, U32.to_nat(c), hc, hw, ha))'
    reps = [
        (EOC, '  VB.add_lt32(off, c, x, eo, hcx32(x, len, U32.to_nat(c), hc, hw32, ha))'),
        ('  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {==})\n', ''),
        ('  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})\n', ''),
        ('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd'),
    ]
    for a, b in reps:
        assert a in text, a[:80]
        text = text.replace(a, b)
    text = re.sub(r'(VTX|XF)\.rdx_(\w+)\(', r'\1.rdxd_\2(', text)
    text = text.replace(', hd30, pf, ', ', hd, pf, ').replace('pf, hd31, ', 'pf, hd, ')
    while True:
        m = re.search(r'UW\.hsx\(d, (U32\.add\(off, \d+\)), (Nat\.add\(U32\.to_nat\(\d+\), x\)), (\d+), ', text)
        if not m:
            break
        L_ = int(m.group(3))
        k = (31 + L_ - 1).bit_length()
        p0 = text.index('(', m.start()) + 1
        b = deep._close(text, p0)
        args = deep._split_args(text[p0:b])
        assert args[5].strip() == 'hd', args[5]
        args = args[:5] + [f' {k}n', ' {==}', ' {==}'] + args[6:]
        text = text[:m.start()] + 'UW.hsxB(' + ','.join(args) + ')' + text[b + 1:]
    # the fit of the header's size plus the child's bytes: below 2^32
    a = text.index('  VBZ.fit_b(')
    e = text.index('FD.nat__lt_trans(d, 28n, 30n, hd, {==}))', a) + len('FD.nat__lt_trans(d, 28n, 30n, hd, {==}))')
    blk = text[a:e]
    mm = re.search(r'VBZ\.fit_b\(d, (\d+)n, LL\(len\), len, (.*?), hlY\(d, t, x, len, pf, hw, ha\), enFS\(len, ha\),', blk, re.S)
    assert mm, blk[:200]
    FSn, YXt = mm.group(1), mm.group(2)
    L4 = 'U32.to_nat(LL(len))'
    new = (f'  FD.nat__le_lt_trans(Nat.add({FSn}n, List.length(&2, U32, {YXt})), U32.to_nat(len), {P32},\n'
           f'    FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({FSn}n, List.length(&2, U32, {YXt})), z) == True{{}} : Bool}}, Nat.add({FSn}n, {L4}), U32.to_nat(len), enFS(len, ha),\n'
           f'      Order.add_left({FSn}n, List.length(&2, U32, {YXt}), {L4}, hlY(d, t, x, len, pf, hw, ha))), VB.u32_lt(len))')
    text = text[:a] + f'  VFT.fits4lt(Nat.add({FSn}n, List.length(&2, U32, {YXt})),\n  ' + new.lstrip() + ')' + text[e:]
    # c + x below 2^32 for a header byte c
    a = text.index('\ndef eoc(')
    hcx32 = (TPL.render('hcx32_hcx32', FS=FS, P32=P32, T=T))
    text = text[:a + 1] + hcx32 + text[a + 1:]
    # the child's window below 2^32
    a = text.index('\ndef ecY(')
    hwy32 = (TPL.render('hwy32', FS=FS, P32=P32, T=T))
    text = text[:a + 1] + hwy32 + text[a + 1:]
    # the child's D interface (its hw32 after its hw)
    pat = re.compile(r'(?<![\w.])YW\.(ok_evalw|readw|specw|invw)\(')
    out, i = [], 0
    while True:
        m = pat.search(text, i)
        if not m:
            out.append(text[i:])
            break
        a = m.end()
        b = deep._close(text, a)
        args = deep._split_args(text[a:b])
        assert args[8].strip().startswith('hwY('), args[8]
        args.insert(9, ' hwY32(x, len, hw32, ha)')
        out.append(text[i:m.start()] + f'YW.{m.group(1)}D(' + ','.join(args) + ')')
        i = b + 1
    text = ''.join(out)
    for nm in ('roomc', 'hcx', 'hwY'):
        text = VVL._keep_sig(text, nm)
    if 'as VFT' not in text:
        text = text.replace('import ./vbuf.bend as VB\n', 'import ./vbuf.bend as VB\nimport ./vfits.bend as VFT\n', 1)
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)')
    left = [l for l in text.split('\n') if re.search(r'is_lt\(d, 28n\)|lt_trans\(d, 28n|UW\.hsx\(|\.rdx_\w+\(|add_le_at\(|VBZ\.fit_b\(', l)]
    assert not left, left[:3]
    text = deep.thread(text, VW.HWX, VW.HW32X)
    return deep.compat(text, VW.XIFACE + ['eoc', 'ecY'], VW.HWX, VW.HW32X, 'Nat.add(x, U32.to_nat(len))')


def _xw_setup(x):
    """the container's facts, the window module's imports and the child's window definitions"""
    n, FS, H, po, cvar, Y, JX = x.n, x.FS, x.H, x.po, x.cvar, x.Y, x.JX
    Tn = f'T.{n}'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    HW = f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    BF = 'UA.BF(t, n)'
    yok = f'T.{Y}_bx_ok' if x.var['box'] else f'T.{Y}_ok'
    YCHK = f'YW.CHKw(t, {JX}, U32.add(off, {FS}), LL(len))'
    al = VBN.win_text(x)
    L = list(HEAD) + ['import ./vbsize.bend as VBZ', 'import ./dk.bend as DK', f'import ./{fname(type("X", (), {"n": Y})).name} as YW', f'import ./{fname(x, "_inv").name} as XI', '',
                      '# GENERATED by byte_list_offset_windows (codegen). Do not edit.',
                      f'# {n} at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend, on',
                      f'# {Y}\'s at the window (off + {FS}, len - {FS}) (see codegen/proofs/var/byte_list_offset_windows.py).', '']
    w = L.append
    w(between(al, 'def chk3(', 'def LL('))
    w(TPL.render('_xw_setup', FS=FS, Y=Y, YCHK=YCHK, cvar=cvar))
    w(between(al, 'def c1_id(', 'def winb('))
    return n, FS, H, po, cvar, Y, JX, Tn, HA, HW, MP, M, BF, yok, YCHK, L, w


def _xw_reader(x, FS, cvar, Y, JX, Tn, HA, HW, BF, yok, YCHK, w):
    """the window's checks and sizes (hcx), the object read from the window and rdw_go"""
    w(TPL.render('_xw_reader', BF=BF, FS=FS, HA=HA, HW=HW, JX=JX, Tn=Tn, Y=Y, YCHK=YCHK, cvar=cvar, yok=yok))
    leaves, OBJ = VBN.read_plan(x)
    OBJ = OBJ.replace('VF.BF(t, n)', BF)
    RHS = f'({BF}, OBJw(d, t, x, off, len))'
    TY = f'B.Buf & {Tn}'
    for line in TPL.render('_xw_reader_lines', BF=BF, FS=FS, HA=HA, OBJ=OBJ, RHS=RHS, TY=TY, Tn=Tn, YCHK=YCHK).split('\n'):
        w(line)

    def ecf(c):
        return f'eoc(d, x, off, len, {c}, {{==}}, eo, hd, hw, ha)'
    for ctx, call, val, kind, f in leaves:
        ctx = ctx.replace('VF.BF(t, n)', BF)
        call = call.replace('VF.BF(t, n)', BF)
        pat = ctx.replace('@', '_')
        if kind == 'off':
            w(f'  %Equal.sym(B.Buf & U32, {call}, ({BF}, {val}), rdo(d, t, n, x, off, len, eo, hd, hw, pf, ha, epo)) :')
        elif kind == 'fix':
            ft = f['ft']
            c = f['c']
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {call}, ({BF}, {val}),')
            w(f'      {rdx_ref(ft)}(d, t, n, U32.add(off, {c}), {posx(c)}, {ecf(c)}, hd30, pf, roomc(d, x, len, {c}n, {ft.size}n, {{==}}, hw, ha))) :')
        elif kind == 'words':
            c, z = f['c'], f['size']
            kw = VBY.kfit(31 + z)
            hs = (f'UW.hsx(d, U32.add(off, {c}), Nat.add(U32.to_nat({c}), x), {z}, {ecf(c)}, hd, '
                  f'roomc(d, x, len, U32.to_nat({c}), U32.to_nat({z}), {{==}}, hw, ha))')
            w(f'  %Equal.sym(B.Buf & O.Words, {call}, ({BF}, {val}),')
            w(f'      VBX.copy_into_at(d, t, n, U32.add(off, {c}), {z}, {f["dz"]}n, {kw}n, pf, hd31, {{==}}, {hs}, {{==}}, {{==}}, {{==}})) :')
        elif kind == 'var':
            w(f'  %Equal.sym(B.Buf & T.{Y}, {call}, ({BF}, {x.yobj()}),')
            w(f'      YW.readw(d, t, n, {JX}, U32.add(off, {FS}), LL(len), ecY(d, x, off, len, eo, hd, hw, ha), hd, hwY(d, x, len, hw, ha), pf, hY)) :')
        else:
            raise VBY.Skip('leaf kind ' + kind)
        w(f'    {{{pat} == {RHS} : {TY}}}')
    w('  {==}')
    w(TPL.render('_xw_reader_readw', BF=BF, FS=FS, RHS=RHS, TY=TY, Tn=Tn, YCHK=YCHK))


def _xw_spec_value(x, n, FS, H, po, Y, JX, HA, HW, MP, M, YCHK, w):
    """the spec side: the items, header and value of the container read from the window"""
    ITEMS, CHAIN, PL, CAT, PRE, POST, hdr, CDEFS = VBN.spec_items(x, 'V', 'Yb', 'hv', named=('XC', '+t: FD.array__Tree<U32>, +x: Nat, +V: S.Value', 't, x, V', '+t: FD.array__Tree<U32>, +x: Nat, +Yb: +List<U32>', 't, x, Yb',
        '+t: FD.array__Tree<U32>, +x: Nat, +V: S.Value, +Yb: +List<U32>, +hv: {Codec.parts(V, Spec.' + x.Y + '()) == Some{[S.Variable{Yb}]} : Maybe<&2, +List<S.Part>>}', 't, x, V, Yb, hv'))
    CDEF = '\n'.join(CDEFS)
    HDR = '[' + ', '.join(hdr) + ']'
    hdrh = '[' + ', '.join(h if j != po else '_' for j, h in enumerate(hdr)) + ']'
    ENC = f'List.append(&2, U32, F.limbs({HDR}), Yb)'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), Yb)'
    L4 = 'U32.to_nat(LL(len))'
    YX = f'UW.WX(t, {JX}, {L4})'
    WX = 'UW.WX(t, x, U32.to_nat(len))'
    VY_ = f'YW.VALw(t, {JX}, LL(len))'
    w(f'''
# ---- the spec side ------------------------------------------------------------------------------

# The value of the window's fixed words and the child's value V, through its named field suffixes.
{CDEF}
def XVw(+t: FD.array__Tree<U32>, +x: Nat, +V: S.Value) -> S.Value: S.Sequence{{{ITEMS}}}

# Its spec parts: one variable part, the header's bytes (the offset is {FS}) and the child's bytes Yb.
def encpw(+t: FD.array__Tree<U32>, +x: Nat, +V: S.Value, +Yb: +List<U32>,
    +hv: {{Codec.parts(V, Spec.{Y}()) == Some{{[S.Variable{{Yb}}]}} : {MP}}}, +hdom: {{SP.bytes_domain(Yb) == True{{}} : Bool}},
    +fit: {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, Yb))) == True{{}} : Bool}})
    -> {{Codec.parts(XVw(t, x, V), Spec.{n}()) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}:
{seq_step(n, 'XVw(t, x, V)', ITEMS, CHAIN, f'Some{{[S.Variable{{{ENC}}}]}}', MP)}  %Equal.sym({MP}, Codec.parts({ITEMS}, {CHAIN}), Some{{{PL}}},
      {CAT}) :
    {{Codec.aggregate(_, SC.fixed_size({CHAIN})) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, Yb, {POST})), Some{{{ENCR}}}, VZ.enc_fpvb({PRE}, Yb, {POST}, hdom, fit)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{{ENC}}}]}} : {MP}}}
  {{==}}

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: XVw(t, x, {VY_})
# VALw's body, as a rewrite (a spec-parts goal over VALw compared with one over its body ran the spec encoder)
def VALq(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {{XVw(t, x, {VY_}) == VALw(t, x, len) : S.Value}}: {{==}}

def hwH(+d: Nat, +x: Nat, +len: U32, {HW}, {HA})
    -> {{Nat.is_le(Nat.add(x, Nat.add(A.quad({H}n), {L4})), {P4}) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add({FS}n, {L4}), U32.to_nat(len), enFS(len, ha)) : {{Nat.is_le(Nat.add(x, _), {P4}) == True{{}} : Bool}}
  hw

# The header's bytes and the child's window's bytes are the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {PF}, {HW}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}})
    -> {{List.append(&2, U32, F.limbs({HDR}), {YX}) == {WX} : +List<U32>}}:
  %enFS(len, ha) : {{List.append(&2, U32, F.limbs({HDR}), {YX}) == UW.WX(t, x, _) : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad({H}n), {L4})), List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), UW.WX(t, Nat.add(A.quad({H}n), x), {L4})),
      UW.headWX(d, t, x, {H}n, {L4}, pf, hwH(d, x, len, hw, ha))) :
    {{List.append(&2, U32, F.limbs({HDR}), {YX}) == _ : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({hdrh}), {YX}) == List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), UW.WX(t, Nat.add(A.quad({H}n), x), {L4})) : +List<U32>}}
  {{==}}

def hlY(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {PF}, {HW}, {HA})
    -> {{Nat.is_le(List.length(&2, U32, {YX}), {L4}) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {YX}), {L4}, UW.lenWX(d, t, {JX}, {L4}, pf, hwY(d, x, len, hw, ha))) : {{Nat.is_le(_, {L4}) == True{{}} : Bool}}
  FD.nat__le_refl({L4})

def fitw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, {PF}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}}, {HW}, {HA})
    -> {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {YX}))) == True{{}} : Bool}}:
  VBZ.fit_b(d, {FS}n, LL(len), len, {YX}, hlY(d, t, x, len, pf, hw, ha), enFS(len, ha),
    FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P4}, Order.left_below_sum(x, U32.to_nat(len)), hw),
    FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}},
    +hY: {{{YCHK} == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  %VALq(t, x, len) :
    {{Codec.parts(_, Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}
  %bytesw(d, t, x, len, pf, hw, ha, epo) :
    {{Codec.parts(XVw(t, x, {VY_}), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  encpw(t, x, {VY_}, {YX}, YW.specw(d, t, n, {JX}, U32.add(off, {FS}), LL(len), ecY(d, x, off, len, eo, hd, hw, ha), hd, hwY(d, x, len, hw, ha), pf, hY),
    UW.domWX(t, {JX}, {L4}), fitw(d, t, x, len, pf, hd, hw, ha))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, {WHX}, {PF},
    +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WX}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, x), {FS})
  +c = {YCHK}
  +epo = FD.u32alg__eq_of(SPOw(t, x), {FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, x, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))
''')
    return L4, YX, WX


def _xw_invariant(n, FS, cvar, Y, JX, HW, MP, YCHK, w, L4, YX, WX):
    """the invariant: every value whose parts are the window's bytes passes the checks"""
    fsb = [FS & 255, (FS >> 8) & 255, (FS >> 16) & 255, (FS >> 24) & 255]
    FSL = '[' + ', '.join(map(str, fsb)) + ']'
    R = FS - cvar - 4
    w(TPL.render('_xw_invariant', FS=FS, FSL=FSL, HW=HW, JX=JX, L4=L4, MP=MP, R=R, WX=WX, Y=Y, YCHK=YCHK, YX=YX, cvar=cvar, n=n))


def xn_win_text(x):
    n, FS, H, po, cvar, Y, JX, Tn, HA, HW, MP, M, BF, yok, YCHK, L, w = _xw_setup(x)
    _xw_reader(x, FS, cvar, Y, JX, Tn, HA, HW, BF, yok, YCHK, w)
    # ---- the spec side ----
    L4, YX, WX = _xw_spec_value(x, n, FS, H, po, Y, JX, HA, HW, MP, M, YCHK, w)
    # ---- the inversion ----
    _xw_invariant(n, FS, cvar, Y, JX, HW, MP, YCHK, w, L4, YX, WX)
    return '\n'.join(L) + '\n'


def main():
    # accepts '--check' (check_or_write_outputs.finish reads it)
    SL.EXACT = True   # spec_connected_codec_laws' exact spec-parts proofs (F.items_fixed, container_fixed, ...)
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for nm, t in names.items():
        g.shape(t)
    xs = [XName(g, nm, names[nm]) for nm in NAMES]
    ns = [XNName(g, nm, names[nm]) for nm in NEST]
    from codegen.proofs.var import two_variable_field_offset_windows as VX2
    x2s = [VX2.X2Name(g, nm, names[nm]) for nm in VX2.X2]
    fts = []
    for x in xs + ns + x2s:
        for f in x.fields:
            if f['kind'] == 'fix':
                for dft in f['ft'].deps():
                    if dft.p not in [q.p for q in fts]:
                        fts.append(dft)
    out = {ROOT / 'proofs/obj/vbx_fix.bend': fix_module(fts)}
    for x in xs:
        out[fname(x, '_inv')] = inv_text(x)
        out[fname(x)] = win_deep(win_text(x), x.FS)
    for x in ns:
        out[fname(x, '_inv')] = xn_inv_text(x)
        out[fname(x)] = xn_win_deep(xn_win_text(x), x.FS)
    for x in x2s:
        out[fname(x, '_inv')] = VX2.inv_text(x)
        out[fname(x)] = VX2.win_text(x)
        out[fname(x, '_dec')] = VX2.dec_text(x)
    mine = sorted((ROOT / 'proofs/obj').glob('var_bytesx_*.bend'))
    orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out]
    return finish(out, 'stale generated byte-offset byte-list laws: ', 'generated byte-offset byte-list laws are current', orphans)


if __name__ == '__main__':
    main()
