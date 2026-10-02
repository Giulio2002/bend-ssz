#!/usr/bin/env python3
"""Byte-offset windows of LISTS OF VARIABLE-SIZE ELEMENTS, for any element type with a
byte-offset window module (the interface of proofs/obj/vua_win.bend: CHKw, ok_evalw,
OBJw, readw, VALw, specw, invw), with a symbolic element count.

    python3 codegen/proofs/var/variable_element_list_windows.py [--check]

Writes
  proofs/obj/vvlb_<p>.bend   the window module of a bare ByteList[N] (an element type):
                             the reader is vua_ct.copy_in_at, the value the window's bytes;
  proofs/obj/vvl_<p>.bend    the window module of the list type p = l<M>_<e>.

The list's runtime (codegen/impl/typed_object_runtime.py) checks and reads the offsets table with loops
over a Nat counter: ev (the validator: element j is the window [o_j, o_{j+1}) with
o_n = len) and rv (the reader: Array.set of each element into the storage array).
The module mirrors both loops over the buffer's words (EV, RV: the reads replaced by
UR.RWN words, the elements' checks and objects by the element module's CHKw, OBJw)
and proves each loop equal to its mirror by induction on the counter; the spec side
(VALw, specw, invw) goes through the layout of n variable parts (proofs/obj/vvl.bend).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys
from codegen.core import generated_file_writer as writer  # noqa: E402

from codegen.proofs.var import single_list_container_codec_laws as VL  # noqa: E402
from codegen.proofs.support import zeros_without_case_split as ZD  # noqa: E402,F401  (named by the templates)
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('variable_element_list_windows', globals())

# (element runtime prefix, byte-list limit, spec schema of the element)
BYTELISTS = [('bl1073741824', 1073741824, 'Transaction'), ('bl32', 32, 'Schema70')]
# lists of variable-size elements: (list runtime prefix, limit, element runtime prefix, element window module,
# list schema, element schema)
# The one-part fact of an element value h (proofs/decode_facts.bend single_result), per element module.
SGL = {'bl1073741824': 'VVL.bsingle(U32.to_nat(1073741824), h)'}
VLISTS = [('l1048576_bl1073741824', 1048576, 'bl1073741824', 'vvlb_bl1073741824', 'Schema73', 'Schema60')]
# lists of variable-size containers (fulu): as VLISTS, with the element's object type and its one-part fact
VLISTS_C = [('l8_Attestation', 8, 'Attestation', 'var_winx_Attestation', 'Schema99', 'Schema40', 'T.Attestation',
             'UW.vsingle(h, ["aggregation_bits", "data", "signature", "committee_bits"], S.Chain{Spec.Schema38(), S.Chain{Spec.Schema36(), S.Chain{Spec.Schema9(), S.Chain{Spec.Schema39(), S.End{}}}}}, {==})'),
            ('l1_AttesterSlashing', 1, 'AttesterSlashing', 'var_winx_AttesterSlashing', 'Schema98', 'Schema47', 'T.AttesterSlashing',
             'UW.vsingle(h, ["attestation_1", "attestation_2"], S.Chain{Spec.Schema46(), S.Chain{Spec.Schema46(), S.End{}}}, {==})')]
# the element name the child window's specw is stated at (the list schema names its element by number)
YSCH = {'l8_Attestation': 'Attestation', 'l1_AttesterSlashing': 'AttesterSlashing'}

WHX = ('+eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
       '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}')
PF = '+pf: {FD.array__perfect(U32, d, t) == True{} : Bool}'
P4 = 'A.quad(VB.pw(d))'

HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
        'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD', 'import ./vbspec.bend as VZ', 'import ./vlist.bend as VLS',
        'import ./vbsize.bend as VBZ', 'import ./vua.bend as UA', 'import ./vua_rd.bend as UR', 'import ./vua_win.bend as UW',
        'import ./vua_ct.bend as UCT']


def src():
    return RR.mono_text('fulu')


def bl_fname(p):
    return ROOT / f'proofs/obj/vvlb_{p}.bend'


def bl_text(p, N, sch):
    want = [f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, U32.is_le(len, {N}))',
            f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)']
    for w in want:
        assert w in src(), w
    BF = 'UA.BF(t, n)'
    WX = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    absurd = f'Empty.absurd({{CHKw(t, x, off, len) == True{{}} : Bool}}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WX}}}], e))'
    cases = []
    for c, args in VL.VALUE_CTORS:
        pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
        if c == 'BytesValue':
            cases.append(f'    case S.BytesValue{{+xs}}: bv(d, t, x, off, len, pf, hw, xs, ByteList.domain(U32.to_nat({N}), xs), {{==}}, e)')
        else:
            cases.append(f'    case {pat}: {absurd}')
    CASES = '\n'.join(cases)
    return '\n'.join(HEAD + ['import ../../spec/byte_list.bend as ByteList', 'import ./vvlz.bend as VZG', '',
                             '# GENERATED by variable_element_list_windows (codegen). Do not edit.',
                             f'# ByteList[{N}] at a window at ANY byte offset: the interface of proofs/obj/vua_win.bend',
                             '# (an element type of the lists of codegen/proofs/var/variable_element_list_windows.py), at any depth d < 31 (bl_deep): the',
                             '# limit (or NMAX) bounds its length, the storage is vua_ct\'s CT, the value is the window\'s bytes.', '']) + TEMPLATES.render('bl_text', N=N, p=p, BF=BF, WX=WX, sch=sch, MP=MP, absurd=absurd, CASES=CASES)


# ByteList windows of the generic forms (types/generic_obj.bend, their schema S.ByteList{N}): (runtime prefix, limit)
GBYTELISTS = [('bl256', 256)]


def _ceil_log2(v):
    return (v - 1).bit_length()


BL_RD_OLD = """  +hL = hlen(d, x, len, hw)
  +hz = VLS.hdz29(d, len, hd, hL)
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {==}),
    FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),
      VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len)))),
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))"""
BL_EZ = """FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),
      VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))"""
BL_FIT_OLD = 'VBZ.fitq(d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))'
LT32 = 'FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(x, U32.to_nat(len)), {H})'


def bounded_text(N):
    """(KB, K, text): a window of at most N bytes (hb: len <= N) has 31 + len <= 2^KB and a copy of depth <= K:
    hyB, hWZ, hdzK, hrgB and zeros_at (bit_list_codec_laws' pattern), for UCT.copy_in_at at KB with UW.hsxB."""
    YMAX = 31 + N
    KB = _ceil_log2(YMAX)
    K = _ceil_log2(((YMAX) >> 2) + 8)
    assert KB < 31 and K < 31
    return KB, K, TEMPLATES.render('bounded_text', KB=KB, N=N, K=K, YMAX=YMAX)


def bounded_copy(KB, K, ez='zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)'):
    """the copy_in_at call of a bounded window (hb: len <= N in scope, hz = hdzK(len, hb))"""
    return (f"""  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), {KB}n, pf, hd, FD.nat__le_lt_trans(VLS.DZ(len), {K}n, 31n, hz, {{==}}),
    {ez},
    UW.hsxB(d, off, x, len, eo, {KB}n, {{==}}, hyB(len, hb), hw), hrgB(len, hb), {{==}}, hyB(len, hb))""")


def bl_deep(text, N):
    """A ByteList[N] window at any depth d < 31. N bounded (31 + N < 2^30): the storage's bounds come from the
    limit (hB, hyB, hWZ, hdzK, hrgB: bit_list_codec_laws' pattern), the window's end below 2^32 is hw32 (nested_type_window_laws.deep_x).
    N = 2^30: the window ends by NMAX (hwN), the copy is vua_ct's U chain (nested_type_window_laws.deep_xN's pattern)."""
    from codegen.proofs.var import nested_type_window_laws as VW
    for a in (BL_RD_OLD, BL_FIT_OLD):
        assert a in text, a[:60]
    # hlen keeps its signature (other modules call it): its window hypothesis is not threaded
    hl_old = '''def hlen(+d: Nat, +x: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw)'''
    assert hl_old in text, 'hlen'
    text = text.replace(hl_old, hl_old.replace('+hw:', '+hl:').replace(', hw)', ', hl)'))
    text = text.replace("import ./vua_ct.bend as UCT\n", "import ./vua_ct.bend as UCT\nimport ./vfits.bend as VFT\n", 1)
    if 31 + N >= 1 << 30:
        text = text.replace(BL_RD_OLD, """  +hy = VC.hyW(x, len, hwN)
  +hz = VC.dz30(len, hy)
  UCT.copy_in_atU(d, t, n, off, len, VLS.DZ(len), pf, hd, FD.nat__le_lt_trans(VLS.DZ(len), 30n, 31n, hz, {==}),
    """ + BL_EZ + """,
    UW.hsxBU(d, off, x, len, eo, hy, hw), VC.hrgU(len, hy), hy)""")
        text = text.replace(BL_FIT_OLD, 'VFT.fits4lt(U32.to_nat(len), ' + LT32.replace('{H}', 'VB.le_n_lt32(Nat.add(x, U32.to_nat(len)), VB.NMAX(), hwN)') + ')')
        return VW.deep_N(text)
    KB, K, bounds = bounded_text(N)
    helpers = TEMPLATES.render('bl_deep', N=N) + bounds
    text = text.replace(BL_RD_OLD, "  +hb = hB(t, x, off, len, hchk)\n  +hz = hdzK(len, hb)\n" + bounded_copy(KB, K))
    text = text.replace(BL_FIT_OLD, 'VFT.fits4lt(U32.to_nat(len), ' + LT32.replace('{H}', 'hw32') + ')')
    a = text.index('\n# The reader on the window')
    text = text[:a] + '\n' + helpers + text[a:]
    return VW.deep_x(text)


def gbl_fname(p):
    return ROOT / f'proofs/obj/vvlb_{p}.bend'


def gbl_text(p, N):
    """bl_text over the generic runtime, the schema term S.ByteList{N} in place of a Spec name."""
    gsrc = RR.mono_text('generic')
    for w in [f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, U32.is_le(len, {N}))',
              f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)']:
        assert w in gsrc, w
    global src
    fsrc = src
    src = lambda: gsrc
    try:
        txt = bl_text(p, N, '@GSCH')
    finally:
        src = fsrc
    txt = txt.replace('Spec.@GSCH()', f'S.ByteList{{{N}n}}')
    txt = txt.replace('import ../../types/fulu_obj.bend as T', 'import ../../types/generic_obj.bend as T').replace('import ../../spec/fulu_schemas.bend as Spec', 'import ./generic_specs.bend as Spec')
    assert '@GSCH' not in txt
    return txt


def zg_text():
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../compact/found.bend as FD', '',
         '# GENERATED by variable_element_list_windows (codegen). Do not edit.',
         '# The runtime zero array B.zeros(du) is Array.new(U32, U32.to_nat(du), 0) for EVERY du, symbolically:',
         '# the literal-depth cases are closed by rewriting the depth before the arrays are compared (checkq',
         '# --big compares the identical trees node by node; stock Bend would evaluate them, 2^d leaves).', '']
    for j in reversed(range(27)):
        nxt = f'zg_c{j + 1}(U32.is_eq(d, {j + 1}), d, {{==}})' if j < 26 else '{==}'
        L += [f'def zg_c{j}(+b: Bool, +d: U32, +eb: {{U32.is_eq(d, {j}) == b : Bool}}) -> {{B.zeros_c{j}(b, d) == Array.new(U32, U32.to_nat(d), 0) : Array<U32>}}:',
              '  match b:', '    case True{}:',
              f'      %Equal.sym(U32, d, {j}, FD.u32alg__eq_of(d, {j}, eb)) : {{B.zeros_c{j}(True{{}}, _) == Array.new(U32, U32.to_nat(_), 0) : Array<U32>}}',
              f'      FD.logic__subst(Nat, z => {{Array.new(U32, {j}n, 0) == Array.new(U32, z, 0) : Array<U32>}}, {j}n, U32.to_nat({j}), {{==}}, {{==}})',
              f'    case False{{}}: {nxt}', '']
    L += ['law zg:', '  for +d: U32', '  {B.zeros(d) == Array.new(U32, U32.to_nat(d), 0) : Array<U32>}', 'def zg(d):', '  zg_c0(U32.is_eq(d, 0), d, {==})']
    return '\n'.join(L) + '\n'


# ---- a list of variable-size elements -------------------------------------------------------------

def T_(s, mp):
    for a in sorted(mp, key=len, reverse=True):
        s = s.replace(a, mp[a])
    return s


def vl_fname(p):
    return ROOT / f'proofs/obj/vvl_{p}.bend'


VL_VALID = TEMPLATES.text('VL_VALID')


VL_READ = TEMPLATES.text('VL_READ')


VL_SPEC = TEMPLATES.text('VL_SPEC')


VL_BYTES = TEMPLATES.text('VL_BYTES')


VL_ASM = TEMPLATES.text('VL_ASM')


VL_INV = TEMPLATES.text('VL_INV')

VALS = [('S.BooleanValue{+b0}', 'S.BooleanValue{b0}'), ('S.UnsignedValue{+u0}', 'S.UnsignedValue{u0}'), ('S.BytesValue{+xs0}', 'S.BytesValue{xs0}'),
        ('S.BitsValue{+bs0}', 'S.BitsValue{bs0}'), ('S.Sequence{+it0}', 'S.Sequence{it0}'), ('S.Items{+hd0, +tl0}', 'S.Items{hd0, tl0}'),
        ('S.EmptyItems{}', 'S.EmptyItems{}'), ('S.Selected{+sel0, +sv0}', 'S.Selected{sel0, sv0}'), ('S.NullValue{}', 'S.NullValue{}')]
GK = '{CHKw(t, x, off, len) == True{} : Bool}'


def inv_rows():
    '''The absurd rows of the inversion's matches.'''
    G = '{EV(1n+q, i, m, t, x, off, len, True{}, a) == True{} : Bool}'
    nil = f'Empty.absurd({G}, FD.logic__true_false(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 0n, 1n+q, ek)))'
    ev = [f'    case 1n+ +q S.Items{{+h, +r}} Nil{{}}: {nil}']
    im, rv, iw = [], [], []
    for pat, val in VALS:
        if not pat.startswith('S.Items'):
            ev.append(f'    case 1n+ +q {pat} Nil{{}}: {nil}')
            ev.append(f'    case 1n+ +q {pat} Con{{+r0, +rs2}}: Empty.absurd({G}, al)')
        for yp in ('Nil{}', 'Con{+y0, +rs}'):
            if (pat, yp) not in (('S.EmptyItems{}', 'Nil{}'), ('S.Items{+hd0, +tl0}', 'Con{+y0, +rs}')):
                im.append(f'    case {pat} {yp}: Empty.absurd({GK}, al)')
        if pat not in ('S.EmptyItems{}', 'S.Items{+hd0, +tl0}'):
            rv.append(f'    case {pat}: Empty.absurd(VVL.REP(Spec.@ESCH(), {val}, ps), FD.logic__none_some(+List<S.Part>, ps, e))')
        if not pat.startswith('S.Sequence'):
            iw.append(f'    case {pat}: Empty.absurd({GK}, FD.logic__none_some(+List<S.Part>, [S.Variable{{@WW}}], e))')
    return {'@EVL_ROWS': '\n'.join(ev), '@INVM_ROWS': '\n'.join(im), '@REPV_ROWS': '\n'.join(rv), '@INVW_ROWS': '\n'.join(iw)}


def vl_text(P, LIM, E, ymod, sch, esch, EO='O.Words', sgl=None):
    mp = {'@ESCH': esch, '@SCH': sch, '@P': P, '@E': E, '@ET': f'O.Boxed<{EO}>', '@EO': EO, '@LIM': str(LIM), '@BF': 'UA.BF(t, n)', '@P4': P4, '@WHX': WHX, '@PF': PF,
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@MP': 'Maybe<&2, +List<S.Part>>', '@WW': 'UW.WX(t, x, U32.to_nat(len))', '@SGL': sgl or SGL[E]}
    inv = VL_INV
    for a, b in inv_rows().items():
        inv = inv.replace(a, b)
    L = HEAD + ['import ./vvl.bend as VVL', 'import ./vvlr.bend as VVR', 'import ./vvlu.bend as VVU', 'import ./vbx2.bend as VX2', 'import ./vrej.bend as VR', 'import ./vdig.bend as VG', 'import ./vnest.bend as VN', 'import ./vfits.bend as VFT', 'import ../../src/primitives.bend as I', f'import ./{ymod}.bend as YW', '',
                '# GENERATED by variable_element_list_windows (codegen). Do not edit.',
                f'# {P} (a list of at most {LIM} variable-size {E}) at a window at ANY byte offset: the',
                '# interface of proofs/obj/vua_win.bend, with a symbolic element count (see codegen/proofs/var/variable_element_list_windows.py).', '']
    # the count bound as the schema states it (@LIMF: a literal, or U32.to_nat of one), from hlim's U32 form by a closed step
    limf = list_bound(sch)
    if limf == f'U32.to_nat({LIM})':
        hl = 'hlim'
    else:
        assert limf == f'{LIM}n', (sch, limf)
        hl = 'FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(NN(t, x)), z) == True{} : Bool}, U32.to_nat(@LIM), @LIMF, limn(), hlim)'
    mp['@LIMF'] = limf
    # the list's parts one step down, first at the window's items (vz1), then over them as an opaque value (lpl):
    # a conversion would unfold them and compare the count against the (possibly huge) bound
    WWS = 'Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>'
    lpl = (f'  %vz1(t, x, len) : {{Codec.parts(_, Spec.@SCH()) == {WWS}}}\n'
           f'  %lpl(S.Items{{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}}) : {{_ == {WWS}}}\n')
    lpldef = ('def vz1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {S.Sequence{S.Items{VE(t, x, W0(t, x), B1(t, x, len)), '
              'VI(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, len)}} == VZE(False{}, t, x, len) : S.Value}:\n  {==}\n\n'
              'def lpl(+it: S.Value) -> {Codec.require(Nat.is_le(Codec.count(it), @LIMF), Codec.aggregate(Codec.parts(it, S.Repeat{Spec.@ESCH()}), None{})) '
              '== Codec.parts(S.Sequence{it}, Spec.@SCH()) : Maybe<&2, +List<S.Part>>}:\n  {==}\n\n')
    text = '\n'.join(L) + T_((VL_VALID + VL_READ + VL_SPEC + VL_BYTES + VL_ASM + inv).replace('@HLIMN', hl).replace('@LPLDEF', lpldef).replace('@LPL', lpl), mp)
    # (a big literal's {==} would expand it: nat__eq_from_is_eq compares the two numbers once)
    if hl != 'hlim':
        text = text.replace('def vz1(', f'def limn() -> {{U32.to_nat({LIM}) == {LIM}n : Nat}}: FD.nat__eq_from_is_eq(U32.to_nat({LIM}), {LIM}n, {{==}})\n\n' + 'def vz1(', 1)
    if P in YSCH:
        text = ysch_bridge(text, esch, YSCH[P])
    return text


def _def_block(text, name):
    a = text.index(f'\ndef {name}(') + 1
    b = text.find('\ndef ', a + 1)
    c = text.find('\n# ', a + 1)
    b = min(x for x in (b, c, len(text)) if x != -1)
    return a, b


def _keep_sig(text, name):
    """An externally usable helper keeps its signature: its window hypothesis is named hl (thread() skips it)."""
    a, b = _def_block(text, name)
    blk = re.sub(r'(?<![\w.])hw(?![\w])', 'hl', text[a:b])
    return text[:a] + blk + text[b:]


def vl_deep(text, mode, keep=()):
    """A list window of variable-size elements at any depth d < 31. mode 'hw32': its end below 2^32 (hw32, the
    elements' windows by their D interface with hwab32); mode 'hwN': its end by NMAX (hwN, for elements whose
    windows take hwN). Offsets: VB.add_lt32 in place of add_le_at's 2^(2 + d) bound; fits: every U32 fits 4 bytes."""
    from codegen.proofs.support import deep_window_decode_passes as deep
    from codegen.proofs.var import nested_type_window_laws as VW
    H, HT = ('hw32', '{Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool}') if mode == 'hw32' else \
        ('hwN', '{Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}')
    text = _keep_sig(text, 'hcx')
    text = _keep_sig(text, 'hwab')
    for nm in keep:   # helpers other modules call with the old window bound
        text = _keep_sig(text, nm)
    reps = [('  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw))',
             f'  VB.add_lt32(off, c, x, eo, hcx32(x, len, U32.to_nat(c), hc, {H}))'),
            ('+hQ: {Nat.is_le(Q, A.quad(VB.pw(d))) == True{} : Bool})', '+hQ: {Nat.is_le(Q, U32.to_nat(len)) == True{} : Bool})'),
            ("VFT.fits4(2n+d, Q, hQ, FD.nat__lt_trans(d, 28n, 30n, hd, {==}))", 'VFT.fits4lt(Q, VB.le_n_lt32(Q, len, hQ))'),
            ('VBZ.fitq(d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))', 'VFT.fits4lt(U32.to_nat(len), VB.u32_lt(len))'),
            ('  +hQ = FD.nat__le_trans(Q, tl, A.quad(VB.pw(d)), hQl, hlen(d, x, len, hw))\n', ''),
            (', h4l, hW, hQ)', ', h4l, hW, hQl)')]
    for a_, b_ in reps:
        assert a_ in text, a_[:70]
        text = text.replace(a_, b_)
    # nxv: hQ is P2 <= len (drop the step to the tree's bound)
    m = re.search(r'      \+hQ = FD\.nat__le_trans\(P2, U32\.to_nat\(len\), A\.quad\(VB\.pw\(d\)\), (.*), hlen\(d, x, len, hw\)\)\n', text, re.S)
    assert m, 'nxv hQ'
    text = text[:m.start()] + f'      +hQ = {m.group(1)}\n' + text[m.end():]
    # the elements' windows: hwab bounds them by x + len, then hw32 / hwN
    ab = TEMPLATES.render('vl_deep')
    if mode == 'hw32':
        ab += TEMPLATES.render('vl_deep_2', HT=HT)
    else:
        ab += TEMPLATES.render('vl_deep_3', HT=HT)
    a, b = _def_block(text, 'eoc')
    text = text[:a] + ab.lstrip('\n') + '\n' + text[a:]
    # the elements' windows through their D interface
    out, i = [], 0
    pat = re.compile(r'YW\.(ok_evalw|readw|specw|invw)\(')
    while True:
        m = pat.search(text, i)
        if not m:
            out.append(text[i:])
            break
        a = m.end()
        b = deep._close(text, a)
        args = deep._split_args(text[a:b])
        k = [j for j, x in enumerate(args) if x.strip().startswith('hwab(')]
        assert len(k) == 1, text[a:a + 200]
        tw = args[k[0]].replace('hwab(d, x, len, ', 'hwab32(x, len, ', 1)
        assert tw.rstrip().endswith(', hw)'), tw
        tw = tw.rstrip()[:-len(', hw)')] + f', {H})'
        args.insert(k[0] + 1, ' ' + tw.strip())
        out.append(text[i:m.start()] + f'YW.{m.group(1)}D(' + ','.join(args) + ')')
        i = b + 1
    text = ''.join(out)
    # eoc is called from outside (e2e_vtx, e2e_vbx_ExecutionPayload): it keeps its old form as a wrapper too
    names = VW.XIFACE + ['eoc']
    if mode == 'hw32':
        return VW.deep_x(text, names)
    return VW.deep_N(text.replace('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd'), names)


def list_bound(sch):
    '''The count bound of the list schema Spec.<sch>() as fulu_schemas.bend writes it.'''
    m = re.search(r'^def ' + sch + r'\(\) -> T\.Schema: T\.ListOf\{\w+\(\), (.+)\}$', (ROOT / 'spec/fulu_schemas.bend').read_text(), re.M)
    return m.group(1)


def ysch_bridge(text, esch, ysch):
    '''el_parts states the element's parts at Spec.<esch>() (the list schema's own term); the child's specw
    is stated at Spec.<ysch>(). One {==} rewrite between the two names, so no conversion unfolds the parts.'''
    E, Y = f'Spec.{esch}()', f'Spec.{ysch}()'
    MB = 'Maybe<&2, +List<S.Part>>'
    a = text.index('  %ve1(t, x, s, e) : ')
    b = text.index('  YW.specw(', a)
    blk = text[a:b]
    assert blk.count(E) == 2, blk
    blk = (f'  %yeq() : {{Codec.parts(VE(t, x, s, e), _) == Some{{[S.Variable{{SW(t, x, s, e)}}]}} : {MB}}}\n'
           + blk.replace(E, Y))
    text = text[:a] + blk + text[b:]
    d = text.index('def el_parts(')
    return text[:d] + f'def yeq() -> {{{Y} == {E} : S.Schema}}:\n  {{==}}\n\n' + text[d:]


# ---- progressive lists (ProgressiveList[C], no count bound) of generic element types ------------------

# (list runtime prefix, element runtime prefix, element object type, element window module, element schema term,
#  the element schema's parts argument: its fields chain (a container) or S.Repeat{..} (a progressive list))
PVLISTS = [
    ('pl_VarTestStruct', 'VarTestStruct', 'T.VarTestStruct', 'var_winx_VarTestStruct', 'Spec.VarTestStruct()',
     'S.Chain{S.Unsigned{P.U16{}}, S.Chain{S.ListOf{S.Unsigned{P.U16{}}, 1024n}, S.Chain{S.Unsigned{P.U8{}}, S.End{}}}}'),
    ('pl_pl_VarTestStruct', 'pl_VarTestStruct', 'T.pl_VarTestStruct_Seq', 'vvl_pl_VarTestStruct', 'S.ProgressiveList{Spec.VarTestStruct()}',
     'S.Repeat{Spec.VarTestStruct()}'),
    ('pl_ProgressiveVarTestStruct', 'ProgressiveVarTestStruct', 'T.ProgressiveVarTestStruct', 'var_winx_ProgressiveVarTestStruct', 'Spec.ProgressiveVarTestStruct()',
     'S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.ListOf{S.Unsigned{P.U16{}}, 123n}, S.Chain{S.ProgressiveBits{}, S.End{}}}}'),
]

PROG_DEFS = TEMPLATES.text('PROG_DEFS')


def prog(text):
    """The bounded list's module text, without the count bound (a progressive list)."""
    def cut_line(t, start):
        a = t.index(start)
        b = t.index('\n', a) + 1
        return t[:a] + t[b:]

    def rep1(t, a, b):
        assert t.count(a) >= 1, a[:80]
        return t.replace(a, b)
    t = text
    # the header check hct: no count bound
    t = rep1(t, ', +hN: {Nat.is_le(U32.to_nat(U32.shrn(f, 2n)), U32.to_nat(@LIM)) == True{} : Bool})\n    -> {HC(f, len) == True{} : Bool}:',
             ')\n    -> {HC(f, len) == True{} : Bool}:')
    t = cut_line(t, '  %Equal.sym(Bool, U32.is_le(U32.shrn(f, 2n), @LIM), True{}, u32le(U32.shrn(f, 2n), @LIM, hN))')
    t = rep1(t, '# The header check, for a first offset 4 c <= len with c <= @LIM.', '# The header check, for a first offset 4 c <= len.')
    # the spec parts: no count bound, no require
    t = cut_line(t, '  +hlim = ule(U32.shrn(f, 2n), @LIM,')
    a = t.index('  +hcount = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMF) == True{} : Bool}')
    b = t.index('  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}, S.Repeat{Spec.@ESCH()}), Some{VVL.VP(', a)
    t = t[:a] + t[b:]
    for x in ['Codec.aggregate(_, None{})', 'Codec.one(_, None{})', 'Codec.one(Some{_}, None{})']:
        t = rep1(t, f'Codec.require(True{{}}, {x})', x)
    # the inversion: no count bound
    t = rep1(t, ',\n    +hc: {Nat.is_le(1n+VVL.CNT(rs), U32.to_nat(@LIM)) == True{} : Bool})\n    -> {CHKw(t, x, off, len) == True{} : Bool}:', ')\n    -> {CHKw(t, x, off, len) == True{} : Bool}:')
    t = cut_line(t, '  +hNl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}')
    t = rep1(t, 'hct(f, len, e3, hfl, h4W, hNl)', 'hct(f, len, e3, hfl, h4W)')
    t = rep1(t, '\n    +hc: {Nat.is_le(VVL.CNT(ys), U32.to_nat(@LIM)) == True{} : Bool}, al:', '\n    al:')
    t = rep1(t, 'inv1(d, t, n, x, off, len, eo, hd, hw, pf, h0, r, y0, rs, eh, al2, hW, hc)', 'inv1(d, t, n, x, off, len, eo, hd, hw, pf, h0, r, y0, rs, eh, al2, hW)')
    t = rep1(t, '    lst: VVL.LST(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ys))', '    lst: LSTP(Spec.@ESCH(), items, @WW, ys))')
    t = rep1(t, '  (+hW, +hc, al) = lst\n  invm(d, t, n, x, off, len, eo, hd, hw, pf, items, ys, hW, hc, al)', '  (+hW, al) = lst\n  invm(d, t, n, x, off, len, eo, hd, hw, pf, items, ys, hW, al)')
    t = rep1(t, '    +e: {Codec.require(Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})',
             '    +e: {Codec.aggregate(m, None{}) == Some{[S.Variable{@WW}]} : @MP})')
    t = rep1(t, 'rqn(@WW, Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), e)', 'FD.logic__none_some(+List<S.Part>, [S.Variable{@WW}], e)')
    t = rep1(t, 'VVL.inv_enc(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ps, rep_v(items, ps, em), e)', 'inv_encp(Spec.@ESCH(), items, @WW, ps, rep_v(items, ps, em), e)')
    t = rep1(t, '\ndef invl(', PROG_DEFS + '\ndef invl(')
    t = rep1(t, '@LPLDEF', '')
    # the validator's header: the count bound is True{}
    t = t.replace('U32.is_le(U32.shrn(f, 2n), @LIM)', 'True{}')
    t = t.replace('Spec.@SCH()', 'S.ProgressiveList{Spec.@ESCH()}').replace('Spec.@ESCH()', '@ESCHT')
    assert '@LIM' not in t, [l for l in t.split('\n') if '@LIM' in l][:3]
    return t


def vlp_text(P, E, EO, ymod, escht, efields):
    mp = {'@ESCHT': escht, '@EFIELDS': efields, '@P': P, '@E': E, '@ET': f'O.Boxed<{EO}>', '@EO': EO, '@BF': 'UA.BF(t, n)', '@P4': P4, '@WHX': WHX, '@PF': PF,
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@MP': 'Maybe<&2, +List<S.Part>>', '@WW': 'UW.WX(t, x, U32.to_nat(len))', '@SGL': 'esingle(h)'}
    inv = VL_INV
    for a, b in inv_rows().items():
        inv = inv.replace(a, b)
    head = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
            for x in HEAD]
    L = head + ['import ../../types/primitive.bend as P', 'import ../../proofs/decode_facts.bend as DF', 'import ./vvl.bend as VVL', 'import ./vvlr.bend as VVR',
                'import ./vvlu.bend as VVU', 'import ./vbx2.bend as VX2', 'import ./vrej.bend as VR', 'import ./vdig.bend as VG', 'import ./vnest.bend as VN',
                'import ./vfits.bend as VFT', 'import ../../src/primitives.bend as I', f'import ./{ymod}.bend as YW', '',
                '# GENERATED by variable_element_list_windows (codegen). Do not edit.',
                f'# {P} (a progressive list of variable-size {E}) at a window at ANY byte offset: the',
                '# interface of proofs/obj/vua_win.bend, with a symbolic element count (see codegen/proofs/var/variable_element_list_windows.py).', '']
    return '\n'.join(L) + T_(prog(VL_VALID + VL_READ + VL_SPEC + VL_BYTES + VL_ASM + inv), mp)


# ---- vectors (Vector[C, N]) of variable-size generic element types ------------------------------------
# The runtime is the list's (the offsets table, the elements' windows) with a fixed count: an empty window is
# refused and the header check is `first == 4 N` (instead of 4 <= first, first / 4 <= LIM); the spec requires
# the count to be N (codec.bend: Vector). The module is the bounded list's with those three changes.

# (vector runtime prefix, count, element runtime prefix, element object type, element window module, element
#  schema term, the element schema's parts argument (its fields chain))
PV_SHALLOW = {'pl_ProgressiveVarTestStruct'}



def pall_deep(text):
    """A progressive list whose elements hold progressive bit lists (their invwD take the representation
    premises hP_j): the list's inversion takes one premise PALL(t, x, len), the conjunction over its elements
    [a, b) of PE: "a <= b <= len implies the element's premises" (its own premises at the element's window,
    guarded, Nat comparisons: nothing wraps). PV folds PE along the check loop EV's elements. The old
    interface (d < 28) proves PALL element by element (pall_old: every window of at most 2^29 bytes)."""
    from codegen.proofs.support import deep_window_decode_passes as deep
    T = 'True{} : Bool'
    ym = re.search(r'^import \./(\S+) as YW$', text, re.M).group(1)
    ysrc = (ROOT / 'proofs/obj' / ym).read_text()
    yds = deep._defs(ysrc)
    prems = [p_ for p_ in yds['invwD'][3] if re.match(r'\+hP\d+:', p_)]
    assert prems, 'no element premise'
    TX, TL = 'Nat.add(U32.to_nat(a), x)', 'U32.sub(b, a)'

    def at_el(ty):
        ty = ty[ty.index('{') + 1:ty.rindex(' == True{} : Bool}')]
        ty = re.sub(r'(?<![\w.])(O\d+|W0|WJ|XJ\d+|FJ\d+|LJ\d+)\(', r'YW.\1(', ty)
        ty = re.sub(r'(?<![\w.])x(?![\w])', 'XX', ty)
        ty = re.sub(r'(?<![\w.])len(?![\w])', 'LL', ty)
        return ty.replace('XX', TX).replace('LL', TL)
    inner = [at_el(p_.split(':', 1)[1].strip()) for p_ in prems]
    INNER = inner[-1]
    for c in reversed(inner[:-1]):
        INNER = f'Bool.and({c}, {INNER})'
    TR = 'FD.array__Tree<U32>'
    NB = 'NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))'
    defs = TEMPLATES.render('pall_deep', TR=TR, INNER=INNER, NB=NB, T=T)
    # each element premise: Bool.or(Nat.is_lt(len_e, E), le(E - O, PMAX)) from the element's window of at most PMAX bytes (YW.hPw)
    pws = []
    for c in inner:
        m_ = re.fullmatch(r'Bool\.or\(Nat\.is_lt\(U32\.to_nat\(' + re.escape(TL) + r'\), U32\.to_nat\((.*?)\)\), Nat\.is_le\(Nat\.sub\(U32\.to_nat\(\1\), U32\.to_nat\((.*)\)\), U32\.to_nat\(VP\.PMAX\(\)\)\)\)', c)
        assert m_, c
        pws.append(f'YW.hPw({TL}, {m_.group(2)}, {m_.group(1)}, hle, Nat.is_lt(U32.to_nat({TL}), U32.to_nat({m_.group(1)})), {{==}})')
    pw = pws[-1]
    for c, q in zip(reversed(inner[:-1]), reversed(pws[:-1])):
        pw = f'FD.logic__and_intro({c}, {pw.split(",")[0]} , {q}, {pw})'
    assert len(pws) == 1, 'several element premises: and_intro form not written'
    defs = defs.replace('@PWS@', pw)
    a0 = text.index('\ndef elx(')
    text = text[:a0] + '\n' + defs + text[a0:]
    # elx: the element's premises from PE (a <= b <= len there)
    m = re.search(r'YW\.invwD\(', text)
    b0 = deep._close(text, m.end())
    text = text[:b0] + ', peIn(t, x, len, a, b, hab, hbl, hPE)' + text[b0:]
    reps = {'elx': f'+hPE: {{PE(t, x, len, a, b) == {T}}}', 'evl': f'+hPV: {{PV(k, i, m, t, x, len, a) == {T}}}'}
    for nm in ('inv1', 'invm', 'invl', 'iv_m', 'invwD'):
        reps[nm] = f'+hPA: {{PALL(t, x, len) == {T}}}'
    for nm, prm in reps.items():
        a0 = text.index(f'\ndef {nm}(') + len(f'\ndef {nm}(')
        b0 = deep._close(text, a0)
        text = text[:b0] + ', ' + prm + text[b0:]
    # calls
    def addarg(text, nm, argf):
        pat = re.compile(rf'(?<![\w.])(?<!def ){nm}\(')
        out, i = [], 0
        while True:
            mm = pat.search(text, i)
            if not mm:
                out.append(text[i:])
                return ''.join(out)
            p0 = mm.end()
            b = deep._close(text, p0)
            args = deep._split_args(text[p0:b])
            out.append(text[i:b] + ', ' + argf(args))
            i = b
    # evl's step: PE of this element, PV of the rest; inv1: PALL's halves
    def elx_arg(args):
        if 'nb' in [x_.strip() for x_ in args]:      # evl's step
            return (f'FD.logic__and_left(PE(t, x, len, a, {NB}), PV(q, U32.add(i, 1), m, t, x, len, {NB}), hPV)')
        return (f'FD.logic__and_left(PE(t, x, len, W0(t, x), B1(t, x, len)), PV(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, len, B1(t, x, len)), hPA)')
    text = addarg(text, 'elx', elx_arg)

    def evl_arg(args):
        if 'nb' in [x_.strip() for x_ in args]:
            return f'FD.logic__and_right(PE(t, x, len, a, {NB}), PV(q, U32.add(i, 1), m, t, x, len, {NB}), hPV)'
        return (f'FD.logic__and_right(PE(t, x, len, W0(t, x), B1(t, x, len)), PV(U32.to_nat(U32.sub(NN(t, x), 1)), 0, NN(t, x), t, x, len, B1(t, x, len)), hPA)')
    text = addarg(text, 'evl', evl_arg)
    for nm in ('inv1', 'invm', 'invl', 'iv_m'):
        text = addarg(text, nm, lambda args: 'hPA')
    # the old invw: PALL from d < 28 (len <= 4 2^d <= PMAX)
    a0 = text.index('\ndef invw(')
    b0 = text.find('\n\n', a0)
    b0 = len(text) if b0 < 0 else b0
    w = text[a0:b0]
    m = re.search(r'invwD\(', w)
    b1 = deep._close(w, m.end())
    w = w[:b1] + ', pall_old(t, x, len, PBP.hPof(d, len, hd, hlen(d, x, len, hw)))' + w[b1:]
    text = text[:a0] + w + text[b0:]
    for imp in ('import ./vpb29.bend as VP', 'import ./var_winp_pbits.bend as PBP'):
        if imp not in text:
            text = text.replace('\nimport ./vbuf.bend as VB\n', f'\nimport ./vbuf.bend as VB\n{imp}\n', 1)
    return text

VVECS = [
    ('v2_VarTestStruct', 2, 'VarTestStruct', 'T.VarTestStruct', 'var_winx_VarTestStruct', 'Spec.VarTestStruct()',
     'S.Chain{S.Unsigned{P.U16{}}, S.Chain{S.ListOf{S.Unsigned{P.U16{}}, 1024n}, S.Chain{S.Unsigned{P.U8{}}, S.End{}}}}'),
]

VEC_DEFS = TEMPLATES.text('VEC_DEFS')

HCT_VEC = TEMPLATES.text('HCT_VEC')


def vec(text, esch):
    """The bounded list's module text as a vector's (count @N: see VVECS)."""
    def rep1(t, a, b, cnt=None):
        assert t.count(a) >= 1 and (cnt is None or t.count(a) == cnt), (a[:90], t.count(a))
        return t.replace(a, b)
    t = text
    OLDB = 'Bool.and(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM))'
    # the header check: first == 4 N (hB now says so; hvv gives the count part back)
    for h in ('ec', 'eb'):
        t = t.replace(f'+hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), {OLDB}, {h})',
                      f'+hB = hvv(f, FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), U32.is_eq(f, @FN), {h}))\n      +hBe = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), U32.is_eq(f, @FN), {h})')
    a = t.index('# The header check, for a first offset 4 c <= len with c <= @LIM.')
    b = t.index('\ndef ', t.index('def hct(', a) + 1)
    t = t[:a] + HCT_VEC + t[b:]
    t = t.replace(OLDB, 'U32.is_eq(f, @FN)')
    # the empty window is refused
    t = rep1(t, 'def CZ(e: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:\n  match e:\n    case True{}: True{}',
             'def CZ(e: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:\n  match e:\n    case True{}: False{}')
    # the reader: no empty case in the runtime
    t = rep1(t, '    -> {T.@P_read_nz(e, @BF, off, len) == (@BF, RZ(e, d, t, x, off, len)) : B.Buf & T.@P_Seq}:\n  match e:\n    case True{}: {==}',
             '    -> {T.@P_read(@BF, off, len) == (@BF, RZ(e, d, t, x, off, len)) : B.Buf & T.@P_Seq}:\n  match e:\n'
             '    case True{}: Empty.absurd({T.@P_read(@BF, off, len) == (@BF, RZ(True{}, d, t, x, off, len)) : B.Buf & T.@P_Seq}, FD.logic__false_true(hc))')
    # the spec: count N (Vector's require), no empty case
    t = rep1(t, "  %Equal.sym(Nat, U32.to_nat(len), 0n, VVU.eqt(len, 0, ee)) : {Codec.parts(S.Sequence{S.EmptyItems{}}, Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, _)}]} : Maybe<&2, +List<S.Part>>}\n      {==}",
             "  Empty.absurd({Codec.parts(VZE(True{}, t, x, len), Spec.@SCH()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}, FD.logic__false_true(hc))")
    t = rep1(t, '  +hlim = ule(U32.shrn(f, 2n), @LIM, FD.logic__and_right(U32.is_le(4, f), U32.is_le(U32.shrn(f, 2n), @LIM), hB))',
             '  +hlim = hnn(f, hBe)')
    t = rep1(t, '  +hcount = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMF) == True{} : Bool}', '  +hcount = FD.logic__subst(Nat, z => {Nat.is_eq(z, @Nn) == True{} : Bool}')
    t = rep1(t, 'inv)), @HLIMN)', 'inv)), hlim)')
    t = rep1(t, '@LPLDEF', '')
    t = rep1(t, '@LPL', '')
    t = rep1(t, "  %Equal.sym(Bool, Nat.is_le(Codec.count(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}), @LIMF), True{}, hcount) :\n    {Codec.require(_, ",
             "  %Equal.sym(Bool, Nat.is_eq(Codec.count(S.Items{VE(t, x, f, B1(t, x, len)), VI(k0, 0, NN(t, x), t, x, len)}), @Nn), True{}, hcount) :\n    {Codec.require(_, ")
    # the inversion: count N
    t = rep1(t, '    +hc: {Nat.is_le(1n+VVL.CNT(rs), U32.to_nat(@LIM)) == True{} : Bool})', '    +hc: {Nat.is_eq(1n+VVL.CNT(rs), @Nn) == True{} : Bool})')
    t = rep1(t, '  +hNl = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(@LIM)) == True{} : Bool}', '  +hNl = FD.logic__subst(Nat, z => {Nat.is_eq(z, @Nn) == True{} : Bool}')
    t = rep1(t, '    +hc: {Nat.is_le(VVL.CNT(ys), U32.to_nat(@LIM)) == True{} : Bool}, al:', '    +hc: {Nat.is_eq(VVL.CNT(ys), @Nn) == True{} : Bool}, al:')
    t = rep1(t, '    case S.EmptyItems{} Nil{}: inv0(d, t, n, x, off, len, eo, hd, hw, pf, hW)', '    case S.EmptyItems{} Nil{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__false_true(hc))')
    t = rep1(t, '    lst: VVL.LST(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ys))', '    lst: LSTV(Spec.@ESCH(), items, @WW, ys))')
    t = rep1(t, '    +e: {Codec.require(Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})',
             '    +e: {Codec.require(Nat.is_eq(Codec.count(items), @Nn), Codec.aggregate(m, None{})) == Some{[S.Variable{@WW}]} : @MP})')
    t = rep1(t, 'rqn(@WW, Nat.is_le(Codec.count(items), U32.to_nat(@LIM)), e)', 'rqn(@WW, Nat.is_eq(Codec.count(items), @Nn), e)')
    t = rep1(t, 'VVL.inv_enc(Spec.@ESCH(), U32.to_nat(@LIM), items, @WW, ps, rep_v(items, ps, em), e)', 'inv_encv(Spec.@ESCH(), items, @WW, ps, rep_v(items, ps, em), e)')
    a0 = t.index('\ndef inv0(')
    t = t[:a0] + t[t.index('\n\n', a0 + 1):]
    hdefs = VEC_DEFS[:VEC_DEFS.index('# What the vector')]
    t = rep1(t, '\ndef invl(', VEC_DEFS[VEC_DEFS.index('# What the vector'):] + '\ndef invl(')
    t = hdefs + t
    t = t.replace('Spec.@SCH()', f'S.Vector{{@ESCHT, @Nn}}').replace('Spec.@ESCH()', '@ESCHT')
    return t


def vvec_text(P, NV, E, EO, ymod, escht, efields):
    mp = {'@ESCHT': escht, '@EFIELDS': efields, '@P': P, '@E': E, '@ET': f'O.Boxed<{EO}>', '@EO': EO, '@BF': 'UA.BF(t, n)', '@P4': P4, '@WHX': WHX, '@PF': PF,
          '@HW': f'+hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), {P4}) == True{{}} : Bool}}',
          '@MP': 'Maybe<&2, +List<S.Part>>', '@WW': 'UW.WX(t, x, U32.to_nat(len))', '@SGL': 'esingle(h)',
          '@FN': str(4 * NV), '@Nn': f'{NV}n', '@LIM': str(NV)}
    inv = VL_INV
    for a, b in inv_rows().items():
        inv = inv.replace(a, b)
    head = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
            for x in HEAD]
    L = head + ['import ../../types/primitive.bend as P', 'import ../../proofs/decode_facts.bend as DF', 'import ./vvl.bend as VVL', 'import ./vvlr.bend as VVR',
                'import ./vvlu.bend as VVU', 'import ./vbx2.bend as VX2', 'import ./vrej.bend as VR', 'import ./vdig.bend as VG', 'import ./vnest.bend as VN',
                'import ./vfits.bend as VFT', 'import ../../src/primitives.bend as I', f'import ./{ymod}.bend as YW', '',
                '# GENERATED by variable_element_list_windows (codegen). Do not edit.',
                f'# {P} (a vector of {NV} variable-size {E}) at a window at ANY byte offset: the',
                '# interface of proofs/obj/vua_win.bend (see codegen/proofs/var/variable_element_list_windows.py).', '']
    return '\n'.join(L) + T_(vec(VL_VALID + VL_READ + VL_SPEC + VL_BYTES + VL_ASM + inv, escht), mp)


def main():
    out = {}
    out[ROOT / 'proofs/obj/vvlz.bend'] = zg_text()
    for p, N, sch in BYTELISTS:
        out[bl_fname(p)] = bl_deep(bl_text(p, N, sch), N)
    for p, N in GBYTELISTS:
        out[gbl_fname(p)] = bl_deep(gbl_text(p, N), N)
    for P, LIM, E, ymod, sch, esch in VLISTS:
        out[vl_fname(P)] = vl_deep(vl_text(P, LIM, E, ymod, sch, esch), 'hwN')
    for P, LIM, E, ymod, sch, esch, EO, sgl in VLISTS_C:
        out[vl_fname(P)] = vl_deep(vl_text(P, LIM, E, ymod, sch, esch, EO, sgl), 'hw32')
    for P, E, EO, ymod, escht, efields in PVLISTS:
        t_ = vlp_text(P, E, EO, ymod, escht, efields)
        # (the elements holding pbits need its representation premise per element: not yet deep)
        out[vl_fname(P)] = pall_deep(vl_deep(t_, 'hwN', keep=('hlen',))) if P in PV_SHALLOW else vl_deep(t_, 'hw32', keep=('hlen',))
    for P, NV, E, EO, ymod, escht, efields in VVECS:
        out[vl_fname(P)] = vl_deep(vvec_text(P, NV, E, EO, ymod, escht, efields), 'hw32', keep=('hlen',))
    # only files this generator wrote (another generator may name a file *vvl*_*)
    def foreign(q):
        return writer.is_foreign(q, 'variable_element_list_windows')
    mine = [q for q in sorted((ROOT / 'proofs/obj').glob('*vvl*_*.bend')) if not foreign(q)]
    orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out]
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale generated variable-element list windows: ', 'generated variable-element list windows are current', orphans=orphans)
    for q, text in out.items():
        q.write_text(text)
    for q in orphans:
        (ROOT / q).unlink()
    print(', '.join(str(q.relative_to(ROOT)) for q in out))


if __name__ == '__main__':
    main()
