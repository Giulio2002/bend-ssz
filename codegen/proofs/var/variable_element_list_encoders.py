#!/usr/bin/env python3
"""The encoders of the lists of variable-size elements at any byte position of an output tree:
the list of transactions (List[ByteList[2^30], 2^20], codegen/proofs/var/variable_element_list_windows.py's list, writer side),
and (GLISTS, glist_text) the generic progressive lists and vectors of such elements, parametric in
the element's encoder window (see GLISTS).

    python3 codegen/proofs/var/variable_element_list_encoders.py [--check]

proofs/obj/encx_l1048576_bl1073741824.bend (BIG: the 2^30 element limit is compared
as the window modules do). The list object is Seq{am(t), N} for a Data mirror tree t of
its boxed elements (the mirrors of proofs/obj/root_types.bend, copied here by name from
that generated file so this module does not import it: WMr, MB, th/fz, am, amswap,
amset, amswap_back, xat); every element i < N is MSome{WMr{T_i, N_i}} with T_i a perfect
tree of depth < 28 holding its N_i bytes and zero past them (EOK). The runtime's validity
loop va is evaluated by induction on its counter (va_go).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys
from codegen.core import generated_file_writer as writer  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('variable_element_list_encoders', globals())

def _unlit(text):
    """a module's text as before any light split (codegen/proofs/support/light_definition_modules.py: unlight), for parsing"""
    from codegen.proofs.support import light_definition_modules as light_definition_modules
    t = light_definition_modules.unlight(text)
    return t.rstrip('\n') + '\n\n'

OUT = ROOT / 'proofs/obj/encx_l1048576_bl1073741824.bend'
RT = ROOT / 'proofs/obj/root_types.bend'
P = 'l1048576_bl1073741824'
E = 'bl1073741824'
LIM = '1073741824'
LIML = '1048576'

COPY = ['WMr', 'th_w', 'fz_w', 'fzth_w', 'MB', f'th_{E}_bx', f'fz_{E}_bx', f'fzth_{E}_bx', f'am_{P}', f'amsize_{P}',
        f'amswap_go_{P}', f'amswap_{P}', f'amset_{P}', f'amswap_back_{P}', f'xat_{P}', f'nth_{P}']


def blocks(text):
    """{name: text} of the top-level def / law / type blocks."""
    out, cur, name = {}, [], None
    for l in text.split('\n'):
        m = re.match(r'(?:def|law|type) (\w+)', l)
        if m or (l and not l[0].isspace() and not l.startswith('#')):
            if name:
                out.setdefault(name, []).extend(cur)
            name, cur = (m.group(1) if m else None), [l]
        else:
            cur.append(l)
    if name:
        out.setdefault(name, []).extend(cur)
    return {k: '\n'.join(v).rstrip('\n') for k, v in out.items()}


HEAD = ['import Base', 'import ../compact/found.bend as F', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../compact/arith.bend as A',
        'import ../compact/reads.bend as RD', 'import ../../proofs/nat_order.bend as Order', 'import ./amap.bend as AM',
        'import ./mtree_defs.bend as MD', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
        'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD', 'import ./vbytes.bend as VY', 'import ./vlist.bend as VL',
        'import ./venc.bend as VE', 'import ./vbenc.bend as VBE', 'import ./spec_fixed.bend as FX',
        'import ./vbrt.bend as VBR', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
        'import ./vvle.bend as VE2', 'import ./vvl.bend as VVL', 'import ./vrej.bend as VR', 'import ../../src/primitives.bend as I', 'import ./vdig.bend as VG',
        'import ./dk.bend as DK', 'import ./vfix.bend as VF', 'import ./vvlu.bend as VVU', 'import ./vbspec.bend as VZ', 'import ../../spec/nat_bytes.bend as N', 'import ./vuwd.bend as WD', 'import ./vbsize.bend as VBZ', 'import ./vfits.bend as VFT', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/layout.bend as Layout', 'import ../../spec/fulu_schemas.bend as Spec', 'import ../../spec/primitives.bend as SP', 'import ../../proofs/nat_bytes.bend as Digits']

TEMPLATE = ROOT / 'codegen/templates/vvle_list.bend.in'


# ==== generic / progressive / Vector lists of variable-size elements, parametric in the element's encoder window ====
# The template above with its element part (the list of transactions' byte-list elements) replaced by
# an element module EM in the encoder-window interface of codegen/proofs/var/progressive_small_list_codec_laws.py's ENCX (mirror type
# EM.<mirror>, TH, OK, ENC, VAL, SZ, PUTX(m, dd, D, q, r), PADB, putx, putx_bytes, pfx, szx, sizex,
# encx_spec) that also exports validx(m, hok): {T.<E>_valid(TH(m)) == (TH(m), True{})} and
# domx(m, hok): {SP.bytes_domain(ENC(m)) == True{}}. The boxed elements' mirrors are MB<EM.mirror>;
# the array lemmas (am, amswap, ...) are copied from the source file's list of the same element kind
# (root_gtypes2.bend), renamed. Modes: 'list' (List[E, LIML]), 'prog' (ProgressiveList[E]), 'vec'
# (Vector[E, n]). Each module ends with the list itself in the same interface (MW{t, N}), so a list
# can be the element of another (pl_pl_VarTestStruct).

# (list prefix, element runtime prefix, mode, count (limit / vector length / None), element encx module,
#  element schema, source file, source list prefix, source element prefix)
GLISTS = [
    ('pl_VarTestStruct', 'VarTestStruct', 'prog', None, 'encx_VarTestStruct_iface.bend', 'Spec.VarTestStruct()',
     'root_gtypes2.bend', 'pl_VarTestStruct', 'VarTestStruct'),
    ('pl_ProgressiveVarTestStruct', 'ProgressiveVarTestStruct', 'prog', None, 'encx_ProgressiveVarTestStruct_iface.bend', 'Spec.ProgressiveVarTestStruct()',
     'root_gtypes2.bend', 'pl_ProgressiveVarTestStruct', 'ProgressiveVarTestStruct'),
    ('v2_VarTestStruct', 'VarTestStruct', 'vec', 2, 'encx_VarTestStruct_iface.bend', 'Spec.VarTestStruct()',
     'root_gtypes2.bend', 'pl_VarTestStruct', 'VarTestStruct'),
    ('pl_pl_VarTestStruct', 'pl_VarTestStruct', 'prog', None, 'encx_pl_VarTestStruct.bend', 'S.ProgressiveList{Spec.VarTestStruct()}',
     'root_gtypes2.bend', 'pl_pl_VarTestStruct', 'pl_VarTestStruct'),
    # Fulu (types/fulu_obj.bend): BeaconBlockBody's lists of containers, mirrors from root_types.bend
    ('l1_AttesterSlashing', 'AttesterSlashing', 'list', 1, 'encx_AttesterSlashing_iface.bend', 'Spec.Schema47()',
     'root_types.bend', 'l1_AttesterSlashing', 'AttesterSlashing', 'Spec.Schema98()', True),
    ('l8_Attestation', 'Attestation', 'list', 8, 'encx_Attestation_iface.bend', 'Spec.Schema40()',
     'root_types.bend', 'l8_Attestation', 'Attestation', 'Spec.Schema99()', True),
]

GHEAD = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
         for x in HEAD]


def gfile(p):
    return ROOT / f'proofs/obj/encx_{p}.bend'


def section(txt, start, end):
    i = txt.index(start)
    j = txt.index(end, i)
    return i, j


def repl(txt, start, end, new):
    i, j = section(txt, start, end)
    return txt[:i] + new + txt[j:]


GELEM = r"""# An element's facts: the element's encoder window's OK.
def EOK(+m: MB<@EW>) -> Bool:
  match m:
    case MNone{}: False{}
    case MSome{+w}: EM.OK(w)

"""

GNEYE = TEMPLATES.text('GNEYE')

GBXSIZE = r"""# One element's boxed size, when its facts hold.
def bxsize(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {T.@E_bx_size(th_@E_bx(m)) == (th_@E_bx(m), NE(m)) : O.Boxed<@EO> & U32}:
  match m:
    case MNone{}: Empty.absurd({T.@E_bx_size(th_@E_bx(MNone{})) == (th_@E_bx(MNone{}), NE(MNone{})) : O.Boxed<@EO> & U32}, F.logic__false_true(h))
    case MSome{+w}:
      %Equal.sym(@EO & U32, T.@E_size(EM.TH(w)), (EM.TH(w), EM.SZ(w)), EM.sizex(w, h)) :
        {T.@E_bx_size_back(_) == (O.BSome{EM.TH(w), O.BNone{}}, EM.SZ(w)) : O.Boxed<@EO> & U32}
      {==}

"""

GBXVALID = r"""def bxvalid(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {T.@E_bx_valid(th_@E_bx(m)) == (th_@E_bx(m), True{}) : O.Boxed<@EO> & Bool}:
  match m:
    case MNone{}: Empty.absurd({T.@E_bx_valid(th_@E_bx(MNone{})) == (th_@E_bx(MNone{}), True{}) : O.Boxed<@EO> & Bool}, F.logic__false_true(h))
    case MSome{+w}:
      %Equal.sym(@EO & Bool, T.@E_valid(EM.TH(w)), (EM.TH(w), True{}), EM.validx(w, h)) :
        {T.@E_bx_va_back(_) == (O.BSome{EM.TH(w), O.BNone{}}, True{}) : O.Boxed<@EO> & Bool}
      {==}

"""

GPUT = TEMPLATES.text('GPUT')

GLENYE = r"""def len_ye(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {VE2.LEN(YE(m)) == U32.to_nat(NE(m)) : Nat}:
  match m:
    case MNone{}: Empty.absurd({VE2.LEN(YE(MNone{})) == U32.to_nat(NE(MNone{})) : Nat}, F.logic__false_true(h))
    case MSome{+w}: Equal.sym(Nat, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), EM.szx(w, h))

"""

GPWEPF = r"""def pwe_perfect(+m: MB<@EW>, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool})
    -> {F.array__perfect(U32, dd, PWE(m, dd, D, q, r)) == True{} : Bool}:
  match m:
    case MNone{}: pf
    case MSome{+w}: EM.pfx(w, dd, D, q, r, pf)

"""

GDOM = TEMPLATES.text('GDOM')

GVALIDGO = r"""def valid_go(+k: Nat, +W: List<&2, MB<@EW>>, +i: Nat, +hok: {EOKS(k, W, i) == True{} : Bool}) -> {Layout.bytes_valid(VVL.VP(YS(k, W, i))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      +x = xat_@P(W, i)
      VVL.vp_valid(YE(x), YS(q, W, 1n+i), dom_ye(x, and_l(EOK(x), EOKS(q, W, 1n+i), hok)), valid_go(q, W, 1n+i, and_r(EOK(x), EOKS(q, W, 1n+i), hok)))

"""

GBCATDOM = r"""def bcat_dom(+k: Nat, +W: List<&2, MB<@EW>>, +i: Nat, +hok: {EOKS(k, W, i) == True{} : Bool}) -> {SP.bytes_domain(VR.bcat(YS(k, W, i))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      +x = xat_@P(W, i)
      app_dom(YE(x), VR.bcat(YS(q, W, 1n+i)), dom_ye(x, and_l(EOK(x), EOKS(q, W, 1n+i), hok)), bcat_dom(q, W, 1n+i, and_r(EOK(x), EOKS(q, W, 1n+i), hok)))

# The list's bytes are bytes.
def domx(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKL(t, N) == True{} : Bool}) -> {SP.bytes_domain(ENCL(t, N)) == True{} : Bool}:
  app_dom(VVL.OFFS(YSN(t, N), A.quad(U32.to_nat(N))), VR.bcat(YSN(t, N)), offs_dom(YSN(t, N), A.quad(U32.to_nat(N))), bcat_dom(U32.to_nat(N), SL(t), 0n, okl_e(t, N, h)))
"""

GIFACE = TEMPLATES.text('GIFACE')


def glist_text(p, E, mode, cnt, emod, esch, src, sp, se, lsch=None, fulu=False):
    tmpl = TEMPLATE.read_text()
    t = tmpl
    t = repl(t, "# An element's storage facts", "# Elements i .. i + k - 1 of W.", GELEM)
    t = repl(t, "# An element's byte count and bytes.", "# The bytes of elements i .. i + k - 1.", GNEYE)
    t = repl(t, "# ---- one element's facts", "# ---- the mirror array", '')
    t = repl(t, "# One element's boxed size", "law sz_go:", GBXSIZE)
    t = repl(t, "def bxvalid(", "law va_go:", GBXVALID)
    t = repl(t, "def TE(", "# ---- arithmetic", GPUT)
    t = repl(t, "def len_ye(", "# padd of two small words", GLENYE)
    t = repl(t, "def pwe_perfect(", "def q30(", GPWEPF)
    t = repl(t, "def dom_ye(", "def parts_go(", GDOM)
    t = repl(t, "def valid_go(", "# encx_spec:", GVALIDGO)
    t = repl(t, "def bcat_dom(", "\n# The list's bytes are bytes.\ndef domx(", '')
    i = t.index("# The list's bytes are bytes.\ndef domx(")
    t = t[:i] + GBCATDOM
    t = t.replace('S.Items{S.BytesValue{YE(xat_@P(W, i))}, XI(q, W, 1n+i)}', 'S.Items{EV(xat_@P(W, i)), XI(q, W, 1n+i)}')
    t = t.replace('Codec.parts(S.BytesValue{YE(x)}, Spec.Schema60())', 'Codec.parts(EV(x), @ESCH)')
    t = t.replace('Spec.Schema60()', '@ESCH')
    t = t.replace('valid_go(n, W, 0n)', 'valid_go(n, W, 0n, okl_e(t, N, h))')
    # the interface-level lemmas keep their names free for the interface
    for a, b in [('def putx(', 'def putl('), ('def putxW(', 'def putlW('), ('def szx(', 'def szl('), ('def szxS(', 'def szlS('), ('def sizex(', 'def sizel('), ('def encx_spec(', 'def specl(')]:
        assert t.count(a) == 1, a
        t = t.replace(a, b)
    # the count check
    if mode == 'list':
        LIMC, VCAP = f'U32.is_le(N, {cnt})', f'Bool.or(False{{}}, U32.is_le(N, {cnt}))'
        LSCH = f'S.ListOf{{{esch}, {cnt}n}}'
    elif mode == 'prog':
        LIMC, VCAP, LSCH = 'True{}', 'True{}', f'S.ProgressiveList{{{esch}}}'
    else:
        LIMC, VCAP, LSCH = f'U32.is_eq(N, {cnt})', f'U32.is_eq(N, {cnt})', f'S.Vector{{{esch}, {cnt}n}}'
    LSCH = lsch or LSCH
    t = t.replace('U32.is_le(N, @LIML)', LIMC)
    vi, vj = section(t, 'def valid_l(', '# The list\'s bytes: the offsets')
    V = t[vi:vj]
    if mode == 'list':
        V = V.replace('Bool.or(False{}, ' + LIMC + ')', VCAP)
    elif mode == 'prog':
        V = V.replace(f'T.@P_va_cap(Bool.or(False{{}}, {LIMC}), N, _)', f'T.@P_va_cap({VCAP}, N, _)')
        a = V.index('  %Equal.sym(Bool, True{}, True{}, okl_lim(t, N, h))')
        b = V.index('  %Equal.sym(Bool, U32.is_le(N, F.u32__pow2u(d))')
        V = V[:a] + V[b:]
    else:
        V = V.replace(f'T.@P_va_cap(Bool.or(False{{}}, {LIMC}), N, _)', f'T.@P_va_cap({VCAP}, N, _)')
        V = V.replace(f'{{T.@P_va_go(Bool.and(Bool.or(False{{}}, _), U32.is_le(N, F.u32__pow2u(d))), N, AR(t))', '{T.@P_va_go(Bool.and(_, U32.is_le(N, F.u32__pow2u(d))), N, AR(t))')
    t = t[:vi] + V + t[vj:]
    si, sj = section(t, 'def specl(', 'def app_dom(')
    Sx = t[si:sj].replace('Spec.Schema73()', LSCH)
    if mode == 'prog':
        a = Sx.index('  +hcount = ')
        b = Sx.index('  +fit = ')
        Sx = Sx[:a] + Sx[b:]
        a = Sx.index('  %Equal.sym(Bool, Nat.is_le(Codec.count(')
        b = Sx.index('  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(XI(n, W, 0n)')
        Sx = Sx[:a] + Sx[b:]
        Sx = Sx.replace('Codec.require(True{}, ', '').replace('None{})) == Some{[S.Variable{ENCL(t, N)}]}', 'None{}) == Some{[S.Variable{ENCL(t, N)}]}')
    elif mode == 'vec':
        a = Sx.index('  +hcount = ')
        b = Sx.index('  +fit = ')
        Sx = Sx[:a] + f'''  +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, {cnt}, F.u32alg__eq_of(N, {cnt}, okl_lim(t, N, h)))
  +hcount = F.logic__subst(Nat, z => {{Nat.is_eq(z, {cnt}n) == True{{}} : Bool}}, {cnt}n, Codec.count(XI(n, W, 0n)), Equal.sym(Nat, Codec.count(XI(n, W, 0n)), {cnt}n, Equal.trans(Nat, Codec.count(XI(n, W, 0n)), n, {cnt}n, count_go(n, W, 0n), eN)), {{==}})
''' + Sx[b:]
        a = Sx.index('  %Equal.sym(Bool, Nat.is_le(Codec.count(')
        b = Sx.index('  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(XI(n, W, 0n)')
        Sx = Sx[:a] + f'''  %Equal.sym(Bool, Nat.is_eq(Codec.count(XI(n, W, 0n)), {cnt}n), True{{}}, hcount) :
    {{Codec.require(Bool.and(Nat.is_lt(0n, {cnt}n), _), Codec.aggregate(Codec.parts(XI(n, W, 0n), S.Repeat{{@ESCH}}), None{{}})) == Some{{[S.Variable{{ENCL(t, N)}}]}} : Maybe<&2, +List<S.Part>>}}
''' + Sx[b:]
    t = t[:si] + Sx + t[sj:]
    t = t.replace('MB<WMr>', 'MB<@EW>').replace('O.Boxed<O.Words>', 'O.Boxed<@EO>')
    assert 'WMr' not in t and 'O.Words' not in t, [l for l in t.split('\n') if 'WMr' in l or 'O.Words' in l][:3]
    # the element module and the copied array lemmas
    es = _unlit((ROOT / 'proofs/obj' / emod).read_text())
    EW = 'EM.' + re.search(r'^type (\w+) is Data:', es, re.M).group(1)
    EO = 'O.Words' if E.startswith('bl') else (f'T.{E}_Seq' if E.startswith('pl_') or E.startswith('l') else f'T.{E}')
    bl = blocks(_unlit((ROOT / 'proofs/obj' / src).read_text()))
    names = ['MB', f'th_{se}_bx', f'am_{sp}', f'amsize_{sp}', f'amswap_go_{sp}', f'amswap_{sp}', f'amset_{sp}', f'amswap_back_{sp}', f'xat_{sp}', f'nth_{sp}']
    miss = [c for c in names if c not in bl]
    assert not miss, miss
    SEO = 'O.Words' if se.startswith('bl') else (f'T.{se}_Seq' if se.startswith('pl_') else f'T.{se}')
    cp = []
    for c in names:
        b = bl[c]
        b = re.sub(rf'\bM_{se}\b', '@EW', b).replace(f'th_{se}(', 'EM.TH(').replace(f'th_{se}_bx', f'th_{E}_bx')
        b = re.sub(rf'_{sp}\b', f'_{p}', b).replace(SEO, EO)
        cp.append(b)
    body = '\n'.join(cp) + '\n' + t + GIFACE
    body = body.replace('domx(+t:', 'domxl(+t:')
    body = (body.replace('@ESCH', esch).replace('@LSCH', LSCH).replace('@EW', EW).replace('@EO', EO).replace('@P', p).replace('@E', E)
            .replace('@LIML', str(cnt)).replace('@LIM', str(cnt)))
    assert '@' not in body.replace('&2', ''), [l for l in body.split('\n') if '@' in l.replace('&2', '')][:3]
    L = (HEAD if fulu else GHEAD) + [f'import ./{emod} as EM', '', '# GENERATED by variable_element_list_encoders (codegen). Do not edit.',
                 f'# {p}: a {"progressive list" if mode == "prog" else ("vector" if mode == "vec" else "list")} of {E} (boxed), writer side, in the encoder-window interface;',
                 f'# its elements through their encoder window {emod} (see the generator).', '',
                 f'# ---- mirrors of the boxed elements (copied from proofs/obj/{src}, renamed) ----']
    return '\n'.join(L) + '\n' + body


def main():
    out = {}
    bl = blocks(_unlit(RT.read_text()))
    missing = [c for c in COPY if c not in bl]
    assert not missing, missing
    L = HEAD + ['', '# GENERATED by variable_element_list_encoders (codegen). Do not edit.',
                '# The list of transactions, writer side (see the generator\'s docstring).', '',
                '# ---- mirrors of the boxed elements (copied from proofs/obj/root_types.bend) ----']
    L += [bl[c] for c in COPY]
    txt = '\n'.join(L) + '\n' + TEMPLATE.read_text().replace('@P', P).replace('@E', E).replace('@LIML', LIML).replace('@LIM', LIM)
    out[OUT] = txt
    for gl in GLISTS:
        if (ROOT / 'proofs/obj' / gl[4]).exists():
            out[gfile(gl[0])] = glist_text(*gl)
    from codegen.impl import runtime_file_split as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    from codegen.proofs.support import deep_window_decode_passes as deep  # the dd < 31 twins (name+W; the old names wrap them at dd < 29); the list writer's own W: vvle_list.bend.in
    out = deep.dify_out(out, strict='--loose' not in sys.argv, skip={'q30', 'qk'}, post=deep.chain_posts(deep.hl32_pass(needed_only=True, derive={'hlx': 'hlx32'}), deep.hs31_pass(derive={'hlx': 'hlx31'}), lambda q, t, res: (__import__('codegen.proofs.support.encode_size_limit_twins', fromlist=['_']).list_btwins(t), [])))
    if '--check' in sys.argv:
        return writer.check(out, 'stale generated list encoder modules: ', 'generated list encoder modules are current')
    for p, t in out.items():
        p.write_text(t)
    print(', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
