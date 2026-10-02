#!/usr/bin/env python3
"""Window laws for nesting: a type read at a symbolic word-aligned window
(byte offset off = 4 i, length len) of a buffer.

    python3 codegen/proofs/var/var_win.py [--check]

Every window module proofs/obj/<big_>var_win_<X>.bend exports the same
interface, so that a container whose variable field is X is proved from it:

    CHKw(t, i, off, len)   the Bool of X's validator on the window;
    ok_evalw               T.<X>_ok(BF(t, n), off, len) == (BF(t, n), CHKw(..));
    OBJw(t, i, off, len)   the object the reader builds when CHKw holds;
    readw                  T.<X>_read(BF(t, n), off, len) == (BF(t, n), OBJw(..));
    VALw(t, i, len)        its spec value;
    specw                  CHKw holds: the spec parts of VALw are one variable
                           part, the window's bytes VR.WB(t, i, len);
    invw                   every value whose spec parts are that variable part
                           passes the checks: CHKw(t, i, off, len) = True;

for every perfect word tree t of depth d < 28 with 4 i + len <= 4 2^d. Kinds:
bit lists (var_win_bits<N>), and containers of fixed word-aligned fields
around one variable field that is a bit list or such a container (boxed or
not). For the containers the generator also writes the top-level codec laws
(the window at offset 0 of the whole buffer): proofs/obj/<big_>var_win_<X>_top.bend
(ok_eval, decode_accept, decode_none, decode_spec, decode_reject) and _unique.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.core import writer  # noqa: E402
from codegen.proofs.var.var_finish import finish  # noqa: E402

from codegen.impl import generate as G  # noqa: E402
from codegen.core import schema  # noqa: E402
from codegen.proofs.var import var_laws as VL  # noqa: E402
from codegen.proofs.support import zeros_dispatch as ZD  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports
from codegen.core.shared_var_b import Templates  # noqa: E402
TPL = Templates('var_win', globals())

ROOT = VL.ROOT
# Containers, in dependency order (children first).
WIN = ['Attestation', 'AggregateAndProof', 'SignedAggregateAndProof']
# Containers with a byte-offset window module (proofs/obj/vua_win.bend's interface).
WINX = ['PendingAttestation', 'Attestation', 'DataColumnsByRootIdentifier', 'IndexedAttestation']


def ceil_log2(x):
    return max(0, (x - 1).bit_length())


# ---- the deep laws (any tree depth d < 31): the word-aligned windows carry hw32, the window's end below 2^32
HWI = '{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}'
HW32I = '{Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool}'


def deep_i(text):
    from codegen.proofs.support import deep
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)').replace('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd')
    return deep.thread(text, HWI, HW32I)


HEAD = list(VL.DEC_HEAD) + ['import ./spec_bits.bend as FB', 'import ./vfits.bend as VFT', 'import ./vlist.bend as VLS',
                            'import ./vbitl.bend as VBL', 'import ./vbyte.bend as VY', 'import ./vbrt.bend as VR',
                            'import ./vbitc.bend as VBC', 'import ./vrej.bend as VRJ', 'import ./vnest.bend as VN', 'import ./dk.bend as DK',
                            'import ../../spec/bitfields.bend as Bits', 'import ../../spec/bit_packing.bend as Bp']

COMMON = TPL.text('COMMON')

BITS = TPL.text('BITS')


# the word-aligned bit-list window as it was (d < 28): the byte-offset windows are derived from it
# (bitsx_text) until they carry the deep bounds too
BITS0 = TPL.text('BITS0')


def zeros_at_text(KK):
    return ZD.zeros_at_text(KK)


VALUE_CTORS = [('BooleanValue', ['b0']), ('UnsignedValue', ['u0']), ('BytesValue', ['xs0']), ('BitsValue', ['bs0']),
               ('Sequence', ['it0']), ('Items', ['hd0', 'tl0']), ('EmptyItems', []), ('Selected', ['sel0', 'sv0']), ('NullValue', [])]


def absurd_cases(keep, goal, e='e', target='[S.Variable{VR.WB(t, i, U32.to_nat(len))}]'):
    out = []
    for c, args in VALUE_CTORS:
        if c == keep:
            continue
        pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
        out.append(f'    case {pat}: Empty.absurd({goal}, FD.logic__none_some(+List<S.Part>, {target}, {e}))')
    return '\n'.join(out)


class Bits:
    """A bit list BitList[N] (runtime prefix p), and the schema term of its spec."""

    def __init__(self, N, p, sch, limn):
        self.N, self.p, self.sch, self.limn = N, p, sch, limn
        self.C = N // 8
        self.BMAX = self.C + 1
        self.YMAX = 31 + self.BMAX
        self.K = ceil_log2((self.YMAX >> 2) + 8)
        self.name = f'bits{N}'


def big_bits(b):
    return b.N >= 1 << 16


def bits_fname(b):
    return ROOT / f'proofs/obj/{"" if big_bits(b) else ""}var_win_{b.name}.bend'


def bits_text(b):
    body = BITS.replace('@ZEROS', '\n' + zeros_at_text(b.K))
    body = body.replace('@ABSURDV', absurd_cases('BitsValue', '{CHKw(t, i, off, len) == True{} : Bool}'))
    for k, v in [('@BMAXn', f'{b.BMAX}n'), ('@YMAXn', f'{b.YMAX}n'), ('@Cn', f'{b.C}n'), ('@Kn', f'{b.K}n'), ('@KBn', f'{ceil_log2(b.YMAX)}n'), ('@LIMN', b.limn),
                 ('@SCH', b.sch), ('@N', str(b.N)), ('@p_', f'{b.p}_')]:
        body = body.replace(k, v)
    L = HEAD + ['', '# GENERATED by var_win (codegen). Do not edit.',
                f'# BitList[{b.N}] at a word-aligned window: the window interface of codegen/proofs/var/var_win.py.', '']
    return deep_i('\n'.join(L) + COMMON + body)


def spec_defs():
    src = (ROOT / 'spec/fulu_schemas.bend').read_text()
    return dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.*)$', src, re.M))


# ---- containers: fixed fields around one variable field (a bit list or a window container) -------

class WName:
    def __init__(self, g, n, t, src, kids):
        self.n, self.t = n, t
        self.fields = []
        pos = 0
        var = None
        for (fname, ft), k in zip(t.fields, kids):
            if ft.fixed():
                f = VL.FT(g, ft)
                self.fields.append({'kind': 'fix', 'name': fname, 'ft': f, 'c': pos, 'k': pos // 4, 't': ft, 'sk': k})
                pos += f.size
            else:
                assert var is None
                var = {'kind': 'var', 'name': fname, 'c': pos, 'k': pos // 4, 't': ft, 'sk': k}
                self.fields.append(var)
                pos += 4
        self.var = var
        self.FS, self.H, self.po = pos, pos // 4, var['k']
        # the runtime's reader and validator of the variable field
        m = re.search(rf'def {n}_c0\(ok: Bool, buf: B\.Buf, \+off: U32, \+len: U32, \+o0: U32\) -> B\.Buf & Bool:\n  match ok:\n    case True\{{\}}: {n}_v1\(off, len, o0, (\w+)_ok\(buf', src)
        self.okf = m.group(1)
        m = re.search(r'(\w+)_read\(buf, \(off \+ o_' + var['name'] + r' : U32\)', src)
        self.rdf = m.group(1)
        self.boxed = self.rdf.endswith('_bx')


def cont_text(g, x, ch, chmod, CSCH, chrep, bits):
    """Window module of container x whose variable field is read by the child
    window module chmod (alias CH); CSCH is the child's spec schema term."""
    n, FS, H, po = x.n, x.FS, x.H, x.po
    Tn = f'T.{n}'
    CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},\n'
          '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
          '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    CWA = 'd, t, n, i, off, len, eo, hd, hw, pf'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    kids = [f['sk'] for f in x.fields]
    L = HEAD + ['import ./vwin.bend as VWN', f'import ./{chmod} as CH', 'import ../../proofs/decode_shape.bend as DS',
                'import ../../proofs/decode_facts.bend as DF', '', '# GENERATED by var_win (codegen). Do not edit.',
                f'# {n} at a word-aligned window: the window interface of codegen/proofs/var/var_win.py.', '']
    w = L.append
    w(COMMON)
    CHK_child = 'CH.CHKw(t, JW(i), OWc(off), LLw(len))'
    w(TPL.render('cont_text', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, H=H, HA=HA, Tn=Tn, po=po, x=x))
    # ---- the reader ----
    CHOBJ = f'CH.OBJw(t, JW(i), OWc(off), LLw(len))'
    objs = []
    for f in x.fields:
        if f['kind'] == 'fix':
            objs.append(f['ft'].obj([f'VB.slot(t, Nat.add({f["k"] + j}n, i))' for j in range(f['ft'].W)]))
        else:
            objs.append(f'O.BSome{{{CHOBJ}, O.BNone{{}}}}' if x.boxed else CHOBJ)
    OBJ = f'{Tn}{{' + ', '.join(objs) + '}'
    RHS = '(BF(t, n), OBJw(t, i, off, len))'
    TY = f'B.Buf & {Tn}'
    for text_line in TPL.render('cont_text_lines', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, HA=HA, OBJ=OBJ, RHS=RHS, TY=TY, Tn=Tn, po=po).split('\n'):
        w(text_line)

    def read_term(f, o):
        if f['kind'] == 'fix':
            ft = f['ft']
            return f'T.{ft.p}_read(BF(t, n), U32.add(off, {f["c"]}), {ft.size})'
        return f'T.{x.rdf}_read(BF(t, n), U32.add(off, {o}), U32.sub(len, {o}))'
    w(f'  %Equal.sym(U32, SPOw(t, i), {FS}, epo) :')
    w(f'    {{{Tn}_rd1(off, len, _, {read_term(x.fields[0], "_")}) == {RHS} : {TY}}}')
    for j, f in enumerate(x.fields):
        args = ', '.join(['off', 'len', f'{FS}'] + objs[:j])
        if f['kind'] == 'fix':
            ft = f['ft']
            k = f['k']
            hb = f'FD.nat__le_trans(Nat.add({ft.W}n, Nat.add({k}n, i)), Nat.add({H}n, i), VB.pw(d), Order.left_below_sum({H - ft.W - k}n, Nat.add({ft.W}n, Nat.add({k}n, i))), hH)'
            for text_line in TPL.render('cont_text_lines_2', CWA=CWA, FS=FS, RHS=RHS, TY=TY, Tn=Tn, args=args, f=f, ft=ft, hb=hb, j=j, k=k, objs=objs, read_term=read_term).split('\n'):
                w(text_line)
        else:
            base = x.rdf[:-3] if x.boxed else x.rdf
            cur = f'T.{base}_read(BF(t, n), OWc(off), LLw(len))'
            w(f'  %Equal.sym(B.Buf & {chrep}, {cur}, (BF(t, n), {CHOBJ}),')
            w(f'      CH.readw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc)) :')
            hole = f'T.{x.rdf}_rd(_)' if x.boxed else '_'
            w(f'    {{{Tn}_rd{j + 1}({args}, {hole}) == {RHS} : {TY}}}')
    w('  {==}')
    w(TPL.render('cont_text_readw', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, RHS=RHS, TY=TY, Tn=Tn))
    # ---- the spec side ----
    nodes = VL.field_nodes(g, x, lambda k: f'VB.slot(t, Nat.add({k}n, i))')
    vi = [f['kind'] for f in x.fields].index('var')
    Y = 'VR.WB(t, JW(i), U32.to_nat(LLw(len)))'
    vals, schs, parts = [], [], []
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append('CH.VALw(t, JW(i), LLw(len))')
            schs.append(CSCH)
            parts.append(f'S.Variable{{{Y}}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if x.fields[i]['kind'] == 'fix':
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, {Y}, {rest}, '
                f'CH.specw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(FS)]
    HDR = '[' + ', '.join(hdr) + ']'
    HDRh = '[' + ', '.join(h if k != po else '_' for k, h in enumerate(hdr)) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {Y})'
    WBL = 'VR.WB(t, i, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    s = 'FD.array__slots(U32, t)'
    w(TPL.render('cont_text_VALw', CHK_child=CHK_child, CW=CW, CWA=CWA, ENCR=ENCR, FS=FS, H=H, HA=HA, HDR=HDR, HDRh=HDRh, M=M, MP=MP, POST=POST, PRE=PRE, WBL=WBL, Y=Y, cat=cat, chain=chain, items=items, n=n, parts=parts, s=s))
    w(inv_text(x, CW, CWA, CHK_child, CSCH, kids, Y, WBL))
    return deep_i('\n'.join(L) + '\n')


def inv_text(x, CW, CWA, CHK_child, CSCH, kids, Y, WBL):
    n, FS, H, po = x.n, x.FS, x.H, x.po
    P = 4 * po
    m = len(x.fields)
    vi = [f['kind'] for f in x.fields].index('var')
    L = []
    w = L.append
    MP = 'Maybe<&2, +List<S.Part>>'
    GOAL = '{CHKw(t, i, off, len) == True{} : Bool}'

    def absurd():
        return f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))'

    def match_value(var, keep, body):
        out = [f'  match {var}:']
        for c, args in VALUE_CTORS:
            if c == keep[0]:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in keep[1]) + f'}}: {body}')
            else:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in args) + f'}}: {absurd()}')
        return out

    def prefix(i):
        decl, args, parts = [], [], []
        for j, f in enumerate(x.fields[:i]):
            if f['kind'] == 'fix':
                decl += [f'+xs{j}: +List<U32>', f'+lx{j}: {{List.length(&2, U32, xs{j}) == {f["ft"].size}n : Nat}}']
                args += [f'xs{j}', f'lx{j}']
                parts.append(f'S.Fixed{{xs{j}}}')
            else:
                decl += ['+hv: S.Value', '+ys: +List<U32>', f'+eh: {{Codec.parts(hv, {CSCH}) == Some{{[S.Variable{{ys}}]}} : {MP}}}']
                args += ['hv', 'ys', 'eh']
                parts.append('S.Variable{ys}')
        return decl, args, parts

    def CC(parts, X):
        for pp in reversed(parts):
            X = f'Codec.concatenate(Some{{[{pp}]}}, {X})'
        return X

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{Spec.{kids[i]}(), {chain(i + 1)}}}'

    def E(parts, X):
        return f'{{Codec.aggregate({CC(parts, X)}, None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}'

    def sig(name, decl, extra):
        return f'def {name}({CW}, ' + ', '.join(decl + extra) + f') -> {GOAL}:'

    pre = list(range(vi))
    post = list(range(vi + 1, m))
    PRE = '[' + ', '.join(f'xs{j}' for j in pre) + ']'
    POST = '[' + ', '.join(f'xs{j}' for j in post) + ']'
    decl_m, args_m, parts_m = prefix(m)
    Pz = sum(x.fields[j]['ft'].size for j in pre)
    Qz = sum(x.fields[j]['ft'].size for j in post)
    ALL = ', '.join(args_m)
    OUT = f'VRJ.OUT({PRE}, ys, {POST})'

    def lens_eq(name, idx, total):
        w(f'def {name}(' + ', '.join(decl_m) + f') -> {{VRJ.lens([' + ', '.join(f'xs{j}' for j in idx) + f']) == {total}n : Nat}}:')
        cur = [f'List.length(&2, U32, xs{j})' for j in idx]
        for a, j in enumerate(idx):
            def term(c):
                tt = '0n'
                for q in reversed(c):
                    tt = f'Nat.add({q}, {tt})'
                return tt
            mot = cur[:a] + ['_'] + cur[a + 1:]
            w(f'  %Equal.sym(Nat, List.length(&2, U32, xs{j}), {x.fields[j]["ft"].size}n, lx{j}) : {{{term(mot)} == {total}n : Nat}}')
            cur[a] = f'{x.fields[j]["ft"].size}n'
        w('  {==}')
        w('')
    w('# ---- every value whose spec parts are the window\'s bytes passes the checks ------------------')
    w('')
    lens_eq('eP', pre, Pz)
    lens_eq('eQ', post, Qz)
    w(f'def fz_eq(' + ', '.join(decl_m) + f') -> {{VRJ.FZ({PRE}, {POST}) == {FS}n : Nat}}:')
    for text_line in TPL.render('inv_text_lines', ALL=ALL, FS=FS, POST=POST, PRE=PRE, Pz=Pz, Qz=Qz).split('\n'):
        w(text_line)
    w(f'def f_off(' + ', '.join(decl_m) + f') -> {{VS.bt(4n, VS.bdr({P}n, {OUT})) == N.digits(4n, {FS}n) : +List<U32>}}:')
    for text_line in TPL.render('inv_text_lines_2', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE, Qz=Qz).split('\n'):
        w(text_line)
    w(f'def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FS}n, List.length(&2, U32, ys)) : Nat}}:')
    for text_line in TPL.render('inv_text_lines_3', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE).split('\n'):
        w(text_line)
    w(f'def f_tail(' + ', '.join(decl_m) + f') -> {{VS.bdr({FS}n, {OUT}) == ys : +List<U32>}}:')
    for text_line in TPL.render('inv_text_lines_4', ALL=ALL, OUT=OUT, POST=POST, PRE=PRE).split('\n'):
        w(text_line)
    RF = FS - P - 4
    w(TPL.render('inv_text', ALL=ALL, CHK_child=CHK_child, CSCH=CSCH, CW=CW, CWA=CWA, FS=FS, GOAL=GOAL, H=H, MP=MP, OUT=OUT, P=P, RF=RF, WBL=WBL, decl_m=decl_m, po=po))
    PLIST = '[' + ', '.join(parts_m) + ']'
    b5 = f'Bool.and(Layout.bytes_valid({PLIST}), N.fits(4n, Nat.add(Layout.fixed_size({PLIST}), List.length(&2, U32, Layout.payloads({PLIST})))))'
    w(sig('fin', decl_m, ['+b5: Bool', f'+e: {{Codec.one(SP.optional(b5, {OUT}), None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}']))
    for text_line in TPL.render('inv_text_lines_5', ALL=ALL, CWA=CWA, OUT=OUT, WBL=WBL, absurd=absurd).split('\n'):
        w(text_line)
    w(sig(f'st{m}', decl_m, ['+items: S.Value', '+e: ' + E(parts_m, 'Codec.parts(items, S.End{})')]))
    L.extend(match_value('items', ('EmptyItems', []), f'fin({CWA}, {ALL}, {b5}, e)'))
    w('')
    for i in reversed(range(m)):
        f = x.fields[i]
        decl, args, parts = prefix(i)
        A = ', '.join(args + [''])
        sch = f'Spec.{kids[i]}()'
        nxt = f'Codec.parts(r, {chain(i + 1)})'
        if f['kind'] == 'fix':
            z = f['ft'].size
            w(sig(f'fp{i}', decl, ['+ps: +List<S.Part>', f'hf: DF.single(Some{{{z}n}}, ps)', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            for text_line in TPL.render('inv_text_lines_6', A=A, CWA=CWA, GOAL=GOAL, i=i, z=z).split('\n'):
                w(text_line)
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            for text_line in TPL.render('inv_text_lines_7', A=A, CWA=CWA, absurd=absurd, i=i).split('\n'):
                w(text_line)
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+r: S.Value', '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({CWA}, {A}Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), r, e)')
            w('')
        else:
            w(sig(f'vp{i}', decl, ['+h: S.Value', '+ps: +List<S.Part>', 'hf: DF.single(None{}, ps)',
                                   f'+em: {{Codec.parts(h, {CSCH}) == Some{{ps}} : {MP}}}', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            for text_line in TPL.render('inv_text_lines_8', A=A, CWA=CWA, GOAL=GOAL, i=i).split('\n'):
                w(text_line)
            w(sig(f'vm{i}', decl, ['+h: S.Value', '+mm: Maybe<&2, +List<S.Part>>', 'hf: DF.single_result(None{}, mm)',
                                   f'+em: {{Codec.parts(h, {CSCH}) == mm : {MP}}}', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            for text_line in TPL.render('inv_text_lines_9', A=A, CWA=CWA, absurd=absurd, i=i).split('\n'):
                w(text_line)
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+r: S.Value', '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  vm{i}({CWA}, {A}h, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), {{==}}, r, e)')
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 'r']), f'fd{i}({CWA}, {A}h, r, e)'))
        w('')
    w(f'# Every value whose spec parts are the window\'s bytes passes the checks.')
    w(f'def invw({CW}, +v: S.Value, +e: {{Codec.parts(v, Spec.{n}()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    L.extend(match_value('v', ('Sequence', ['items']), f'st0({CWA}, items, e)'))
    return '\n'.join(L).replace('{HA_}', f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}')


TOP = TPL.text('TOP')


def top_text(x, wmod, kids, deep=False):
    """deep: the window module carries the deep bounds (d < 31, hw32); other generators' windows are d < 28."""
    chain = 'S.End{}'
    for k in reversed(kids):
        chain = f'S.Chain{{Spec.{k}(), {chain}}}'
    ab = []
    for c, args in VALUE_CTORS:
        if c == 'Sequence':
            continue
        pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
        ab.append(f'    case {pat}: FD.logic__none_some(+List<U32>, VW(t, n), e)')
    body = TOP.replace('@ABSURD', '\n'.join(ab) + '\n').replace('@CHAIN', chain).replace('@Tn', f'T.{x.n}').replace('@N(', f'{x.n}(')
    L = HEAD + [f'import ./{wmod} as W', '', '# GENERATED by var_win (codegen). Do not edit.',
                f'# {x.n}: the codec laws of the whole buffer, from its window laws ({wmod}).', '']
    if not deep:
        return '\n'.join(L) + body.replace('Nat.is_lt(d, 31n)', 'Nat.is_lt(d, 28n)').replace(', hd, hn, VB.u32_lt(n), pf', ', hd, hn, pf')
    return deep_i('\n'.join(L) + body)


def unique_text(x, top):
    return writer.rebrand(VL.unique_text(None, x.n, top, 31), 'var_laws', 'var_win')


# ---- byte-offset windows (the interface of proofs/obj/vua_win.bend) ---------------------------

HEADX = HEAD + ['import ./vua_win.bend as UW', 'import ./vua_ct.bend as UCT']

COMMONX = TPL.text('COMMONX')


def to_bytes_window(s):
    """The word-aligned window text (index i, off = 4 i) at a byte position x."""
    for a, b in [
            ('+i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}', '+x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}'),
            ('Nat.add(A.quad(i), ', 'Nat.add(x, '),
            ('VR.eXN(d, off, i, ', 'UW.eXN(d, off, x, '),
            ('FD.nat__lt_add_left(M1(len), 1n+M1(len), A.quad(i), ', 'FD.nat__lt_add_left(M1(len), 1n+M1(len), x, '),
            ('VR.WB(t, i, ', 'UW.WX(t, x, '), ('VR.lastWB(d, t, i, ', 'UW.lastWX(d, t, x, '), ('VR.domWB(t, i, ', 'UW.domWX(t, x, '),
            ('VR.lenWB(d, t, i, ', 'UW.lenWX(d, t, x, '),
            ('+t: FD.array__Tree<U32>, +i: Nat, +off: U32', '+t: FD.array__Tree<U32>, +x: Nat, +off: U32'),
            ('(t, i, off, len', '(t, x, off, len'), ('(d, t, n, i, off, len', '(d, t, n, x, off, len'), ('(d, t, i, off, len', '(d, t, x, off, len'),
            ('(d, i, off, len', '(d, x, off, len'), ('hlen(d, i, len, hw)', 'hlen(d, x, len, hw)'),
            ('+t: FD.array__Tree<U32>, +i: Nat, +len: U32', '+t: FD.array__Tree<U32>, +x: Nat, +len: U32'), ('VALw(t, i, len)', 'VALw(t, x, len)')]:
        s = s.replace(a, b)
    return s


HWX = '{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}'
HW32X = '{Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool}'
XIFACE = ['ok_evalw', 'readw', 'specw', 'invw']


def deep_x(text, names=XIFACE):
    """The byte-offset window text at any depth d < 31 (hw32: the window's end below 2^32), plus the
    interface as it was (d < 28, no hw32) under the old names for the callers not yet deep."""
    from codegen.proofs.support import deep
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)').replace('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd')
    text = deep.thread(text, HWX, HW32X)
    return deep.compat(text, names, HWX, HW32X, 'Nat.add(x, U32.to_nat(len))')


def bitsx_deep_body(b):
    body = to_bytes_window(BITS).replace('VR.eXNw(off, i, ', 'UW.eXNw(off, x, ')
    obj_old = """def OBJw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}"""
    obj_new = """def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), NB(t, off, len)), NB(t, off, len)}"""
    assert obj_old in body, 'OBJw'
    body = body.replace(obj_old, obj_new)
    body = body.replace('OBJw(t, x, off, len)', 'OBJw(d, t, x, off, len)')
    ci_old = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwHB(d, len, i, @KBn, {==}, hyB(len, hb), hw), hrgB(len, hb))) :"""
    ci_new = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}),
      UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), @KBn, pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,
        UW.hsxB(d, off, x, len, eo, @KBn, {==}, hyB(len, hb), hw), hrgB(len, hb), {==}, hyB(len, hb))) :"""
    assert ci_old in body, 'copy_in'
    return body.replace(ci_old, ci_new)


def bitsx_text(b, deep=False):
    if deep:
        return deep_x(_bitsx_text(b, bitsx_deep_body(b)))
    return _bitsx_text(b, None)


def _bitsx_text(b, dbody):
    if dbody is not None:
        body = dbody
    else:
        body = _bitsx_old_body()
    body = body.replace('@ZEROS', '\n' + zeros_at_text(b.K))
    body = body.replace('@ABSURDV', absurd_cases('BitsValue', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    for k, v in [('@BMAXn', f'{b.BMAX}n'), ('@YMAXn', f'{b.YMAX}n'), ('@Cn', f'{b.C}n'), ('@KBn', f'{ceil_log2(b.YMAX)}n'), ('@Kn', f'{b.K}n'), ('@LIMN', b.limn),
                 ('@SCH', b.sch), ('@N', str(b.N)), ('@p_', f'{b.p}_')]:
        body = body.replace(k, v)
    assert 'A.quad(i)' not in body and 'VR.WB(' not in body, 'leftover word index'
    L = HEADX + ['', '# GENERATED by var_win (codegen). Do not edit.',
                 f'# BitList[{b.N}] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + COMMONX + body


def _bitsx_old_body():
    body = to_bytes_window(BITS0)
    obj_old = """def OBJw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}"""
    obj_new = """def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), NB(t, off, len)), NB(t, off, len)}"""
    assert obj_old in body, 'OBJw'
    body = body.replace(obj_old, obj_new)
    body = body.replace('OBJw(t, x, off, len)', 'OBJw(d, t, x, off, len)')
    ci_old = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwH(d, len, i, hd, hw), VLS.hrg(d, len, hd, hL))) :"""
    ci_new = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}),
      UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,
        UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))) :"""
    assert ci_old in body, 'copy_in'
    return body.replace(ci_old, ci_new)


def bitsx_fname(b):
    return ROOT / f'proofs/obj/{"" if big_bits(b) else ""}var_winx_{b.name}.bend'


def posx(c):
    return 'x' if c == 0 else f'{c}n+x'


def _cx_reader(x, chrep, FS, P, Tn, CW, CWA, HA, w, CHK_child):
    """the reader: the object read from the window, and rd_go with the child reads"""
    CHOBJ = 'CH.OBJw(d, t, JW(x), OWc(off), LLw(len))'
    objs = []
    for f in x.fields:
        if f['kind'] == 'fix':
            objs.append(f['ft'].obj([f'UR.RWN(t, {posx(f["c"] + 4 * j)})' for j in range(f['ft'].W)]))
        else:
            objs.append(f'O.BSome{{{CHOBJ}, O.BNone{{}}}}' if x.boxed else CHOBJ)
    OBJ = f'{Tn}{{' + ', '.join(objs) + '}'
    RHS = '(BF(t, n), OBJw(d, t, x, off, len))'
    TY = f'B.Buf & {Tn}'
    for text_line in TPL.render('_cx_reader_lines', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, HA=HA, OBJ=OBJ, P=P, RHS=RHS, TY=TY, Tn=Tn).split('\n'):
        w(text_line)

    def read_term(f, o):
        if f['kind'] == 'fix':
            ft = f['ft']
            return f'T.{ft.p}_read(BF(t, n), U32.add(off, {f["c"]}), {ft.size})'
        return f'T.{x.rdf}_read(BF(t, n), U32.add(off, {o}), U32.sub(len, {o}))'
    w(f'  %Equal.sym(U32, SPOw(t, x), {FS}, epo) :')
    w(f'    {{{Tn}_rd1(off, len, _, {read_term(x.fields[0], "_")}) == {RHS} : {TY}}}')
    for j, f in enumerate(x.fields):
        args = ', '.join(['off', 'len', f'{FS}'] + objs[:j])
        if f['kind'] == 'fix':
            ft = f['ft']
            c = f['c']
            for text_line in TPL.render('_cx_reader_lines_2', CWA=CWA, FS=FS, RHS=RHS, TY=TY, Tn=Tn, args=args, c=c, f=f, ft=ft, j=j, objs=objs, read_term=read_term).split('\n'):
                w(text_line)
        else:
            base = x.rdf[:-3] if x.boxed else x.rdf
            cur = f'T.{base}_read(BF(t, n), OWc(off), LLw(len))'
            w(f'  %Equal.sym(B.Buf & {chrep}, {cur}, (BF(t, n), {CHOBJ}),')
            w(f'      CH.readwD(d, t, n, JW(x), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc)) :')
            hole = f'T.{x.rdf}_rd(_)' if x.boxed else '_'
            w(f'    {{{Tn}_rd{j + 1}({args}, {hole}) == {RHS} : {TY}}}')
    w('  {==}')
    w(TPL.render('_cx_reader', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, RHS=RHS, TY=TY, Tn=Tn))


def _cx_spec_value(g, x, CSCH, FS, po, CWA):
    """the spec side: the value, schema and parts of each field and the fixed-field definitions"""
    nodes = VL.field_nodes(g, x, lambda k: f'UR.RWN(t, {posx(4 * k)})')
    vi = [f['kind'] for f in x.fields].index('var')
    Y = 'UW.WX(t, JW(x), U32.to_nat(LLw(len)))'
    vals, schs, parts = [], [], []
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append('CH.VALw(t, JW(x), LLw(len))')
            schs.append(CSCH)
            parts.append(f'S.Variable{{{Y}}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    # definitions per step: the fixed fields' values as small refs (FVc<i>), their parts facts as lemmas (fxc<i>)
    svals = [f'FVc{i}(t, x)' if f['kind'] == 'fix' else v for i, (f, v) in enumerate(zip(x.fields, vals))]

    def sitems(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{svals[i]}, {sitems(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if x.fields[i]['kind'] == 'fix':
            return (f'gcf_({svals[i]}, {sitems(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, fxc{i}(t, x), {cat(i + 1)})')
        return (f'gcv_({svals[i]}, {sitems(i + 1)}, {schs[i]}, {chain(i + 1)}, {Y}, {rest}, '
                f'CH.specwD(d, t, n, JW(x), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(FS)]
    HDR = '[' + ', '.join(hdr) + ']'
    HDRh = '[' + ', '.join(h if k != po else '_' for k, h in enumerate(hdr)) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {Y})'
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    LLn = 'U32.to_nat(LLw(len))'
    TXL = '+t: FD.array__Tree<U32>, +x: Nat, +len: U32'
    FXR = lambda i: f'Some{{[S.Fixed{{F.limbs([{", ".join(nodes[i]["words"])}])}}]}} : {MP}'
    fxdefs = ''.join(TPL.render('_cx_spec_value', FXR=FXR, i=i, nodes=nodes, schs=schs, vals=vals) for i, f in enumerate(x.fields) if f['kind'] == 'fix')
    LH = 'LHc(t, x, len)'
    SMALL = (TPL.render('SMALL', ENCR=ENCR, HDR=HDR, POST=POST, PRE=PRE, TXL=TXL, Y=Y, sitems=sitems))
    return Y, items, chain, cat, PRE, POST, HDR, HDRh, WBL, MP, M, LLn, fxdefs, LH, SMALL


def _cx_inv(x, CSCH, FS, H, po, P, CW, CWA, kids, w, CHK_child, Y, WBL):
    """the invariant lemma, its window facts re-stated over the offset tree"""
    inv = inv_text(x, CW, CWA, CHK_child, CSCH, kids, Y, WBL).replace('CH.invw(', 'CH.invwD(')
    RF = FS - P - 4
    for a, b in [('CHKw(t, i, off, len)', 'CHKw(t, x, off, len)'),
                 ('VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)', 'UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)'),
                 (f'+W2 = VR.WB(t, i, Nat.add({FS}n, lY))', f'+W2 = UW.WX(t, x, Nat.add({FS}n, lY))'),
                 ('z => VR.WB(t, i, z)', 'z => UW.WX(t, x, z)'),
                 ('Nat.add(A.quad(i), z)', 'Nat.add(x, z)'),
                 (f'VWN.byteW(d, t, i, {po}n, Nat.add({RF}n, lY), pf, hw2)', f'UW.byteWX(d, t, x, {P}n, Nat.add({RF}n, lY), pf, hw2)'),
                 ('SPOw(t, i)', 'SPOw(t, x)'),
                 (f'VWN.tailW(t, i, {H}n, lY)', f'UW.tailWX(t, x, {FS}n, lY)'),
                 ('VR.WB(t, JW(i), ', 'UW.WX(t, JW(x), '), ('JW(i)', 'JW(x)'),
                 ('def chk_t(+t: FD.array__Tree<U32>, +i: Nat,', 'def chk_t(+t: FD.array__Tree<U32>, +x: Nat,'), ('chk_t(t, i, ', 'chk_t(t, x, ')]:
        assert a in inv or a in ('Nat.add(A.quad(i), z)',), a
        inv = inv.replace(a, b)
    w(inv)


def contx_text(g, x, chmod, CSCH, chrep):
    """Byte-offset window module of container x (the interface of
    proofs/obj/vua_win.bend) whose variable field is read by the child byte
    window module chmod (alias CH)."""
    n, FS, H, po = x.n, x.FS, x.H, x.po
    P = 4 * po
    Tn = f'T.{n}'
    CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
          '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
          '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    PW = 'A.quad(VB.pw(d))'
    kids = [f['sk'] for f in x.fields]
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', f'import ./{chmod} as CH', 'import ../../proofs/decode_shape.bend as DS',
                 'import ../../proofs/decode_facts.bend as DF', '', '# GENERATED by var_win (codegen). Do not edit.',
                 f'# {n} at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    w = L.append
    w(COMMONX)
    CHK_child = 'CH.CHKw(t, JW(x), OWc(off), LLw(len))'
    w(TPL.render('contx_text', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, HA=HA, P=P, PW=PW, Tn=Tn, x=x))
    # ---- the reader ----
    _cx_reader(x, chrep, FS, P, Tn, CW, CWA, HA, w, CHK_child)
    # ---- the spec side ----
    Y, items, chain, cat, PRE, POST, HDR, HDRh, WBL, MP, M, LLn, fxdefs, LH, SMALL = _cx_spec_value(g, x, CSCH, FS, po, CWA)
    w(TPL.render('contx_text_VALw', CW=CW, CWA=CWA, FS=FS, H=H, HA=HA, HDR=HDR, HDRh=HDRh, LLn=LLn, POST=POST, PRE=PRE, PW=PW, WBL=WBL, Y=Y, items=items)
    + fxdefs + SMALL + TPL.render('contx_text_vwc', CHK_child=CHK_child, CW=CW, CWA=CWA, FS=FS, HA=HA, LH=LH, LLn=LLn, M=M, MP=MP, POST=POST, PRE=PRE, WBL=WBL, Y=Y, cat=cat, chain=chain, n=n))
    _cx_inv(x, CSCH, FS, H, po, P, CW, CWA, kids, w, CHK_child, Y, WBL)
    text = '\n'.join(L) + '\n'
    for bad in ['A.quad(i)', 'VR.WB(', '(t, i,', 'JW(i)']:
        assert bad not in text, bad
    return deep_x(text)


# A List[uint64, N] at a window at any byte offset (the runtime prefix @p_, limit @N).
LISTX = TPL.text('LISTX')


LISTX_DEEP_BOUNDS = TPL.text('LISTX_DEEP_BOUNDS')


def listx_deep_text(N, p, sch, el, limn):
    """List[uint64, N] at a window at any byte offset, any depth d < 31: the storage's bounds come from the
    limit N (31 + 8 N <= 2^KB), never from the buffer's depth."""
    YMAX = 31 + 8 * N
    KB = ceil_log2(YMAX)
    K = ceil_log2((YMAX >> 2) + 8)
    # N = 2^pw: the closed bounds by proofs/obj/xbound.bend in powers of two (8 N = 2^(pw + 3)), never as
    # unary numbers (hyL, hWZ, specwD's fits counted a million steps each: 5 s per module); the storage
    # bound is then 2^(pw + 3) (one more than the least K, which only bounds the zero storage's depth)
    pw = N.bit_length() - 1
    xb = N == 1 << pw and pw >= 2 and pw + 3 < 31
    if xb:
        assert KB == pw + 4
        K = pw + 3
    assert KB < 31 and K < 31
    body = LISTX.replace('@ZEROS', '')
    body = _cut_def(body, 'hWZ')
    a = body.index('\ndef OBJw(')
    body = body[:a] + LISTX_DEEP_BOUNDS + body[a:]
    if xb:
        E5 = ', '.join(['{==}'] * 5)
        for a_, b_ in [('VB.pw(@KBn), hyN(t, x, off, len, hc), {==})',
                        f'VB.pw(@KBn), hyN(t, x, off, len, hc), XB.yle(@N, {pw}n, {pw + 2}n, @KBn, {E5}))'),
                       ('hyN(t, x, off, len, hc))),\n      {==}))',
                        f'hyN(t, x, off, len, hc))),\n      XB.wzb(@N, {pw}n, {pw + 2}n, @KBn, @Kn, {E5}, {{==}})))'),
                       ('  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), {==},',
                        f'  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), XB.fitb(@N, {pw}n, {pw + 2}n, {{==}}, {{==}}, {{==}}, {{==}}),')]:
            assert a_ in body, a_[:60]
            body = body.replace(a_, b_)
    for a_, b_ in [('  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))', '  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(t, x, off, len, hchk))'),
                   ('  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)',
                    '  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),\n'
                    '    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))'),
                   ('  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,\n'
                    '    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))',
                    '  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), @KBn, pf, hd, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,\n'
                    '    UW.hsxB(d, off, x, len, eo, @KBn, {==}, hyL(t, x, off, len, hchk), hw), hrgL(t, x, off, len, hchk), {==}, hyL(t, x, off, len, hchk))'),
                   ('  +hL = hlen(d, x, len, hw)\n', '')]:
        assert a_ in body, a_[:60]
        body = body.replace(a_, b_)
    body = body.replace('@ABSURDV', absurd_cases('Sequence', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    for k, v in [('@KBn', f'{KB}n'), ('@Kn', f'{K}n'), ('@LIMN', limn), ('@SCH', sch), ('@EL', el), ('@N', str(N)), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vvlz.bend as VZG'] + (['import ./xbound.bend as XB'] if xb else []) + ['', '# GENERATED by var_win (codegen). Do not edit.',
                 f'# List[uint64, {N}] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return deep_x('\n'.join(L) + COMMONX + body)



def _cut_def(text, name):
    """text without the def `name` (up to the next blank line)."""
    a = text.index(f'\ndef {name}(')
    b = text.index('\n\n', a + 1)
    return text[:a] + text[b:]


HWNX = '{Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}'


def deep_xN(text, names=XIFACE):
    """The unbounded byte-offset windows (the 2^40 lists) at any depth d < 31: the window ends by NMAX
    (hwN), so 31 + len <= UMAX and the copy is VC's U chain; no power of two on the depth bounds the
    storage. The old interface (d < 28) stays under the old names (hwN from VB.hwNof)."""
    from codegen.proofs.support import deep  # noqa: F401  kept: the import may register hooks at import time
    reps = [
        ('  +hz = VLS.hdz29(d, len, hd, hL)', '  +hy = VC.hyW(x, len, hwN)\n  +hz = VC.dz30(len, hy)'),
        ('  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {==}), ez,\n'
         '    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))',
         '  UCT.copy_in_atU(d, t, n, off, len, VLS.DZ(len), pf, hd, FD.nat__le_lt_trans(VLS.DZ(len), 30n, 31n, hz, {==}), ez,\n'
         '    UW.hsxBU(d, off, x, len, eo, hy, hw), VC.hrgU(len, hy), hy)'),
        ('VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))',
         'VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(x, U32.to_nat(len)),\n'
         '        VB.le_n_lt32(Nat.add(x, U32.to_nat(len)), VB.NMAX(), hwN)))'),
        ('  +hL = hlen(d, x, len, hw)\n', ''),
    ]
    for a, b in reps:
        assert a in text, a[:70]
        text = text.replace(a, b)
    return deep_N(text, names)


def deep_N(text, names=XIFACE):
    """d < 31 and hwN (the window ends by NMAX) threaded, the old interface as wrappers (hwN from VB.hwNof)."""
    from codegen.proofs.support import deep
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)')
    assert 'VLS.KK(' not in text and 'VLS.hrg(' not in text and 'UW.hsx(' not in text and '28n' not in text.replace('28n+x', ''), 'deep_N leftover'
    text = deep.thread(text, HWX, HWNX, hw32='hwN')
    return deep.compat(text, names, HWX, HWNX, 'Nat.add(x, U32.to_nat(len))', hw32='hwN',
                       hw32_term='VB.hwNof(d, Nat.add(x, U32.to_nat(len)), hd, hw)')


def listx40_text(p, sch, el, limn, deep=False):
    """List[uint64, 2^40] at a window at any byte offset: the runtime checks only
    whole elements (a U32 length cannot exceed the limit), so the count's bound
    is the length's (vu40: symbolic capacities, never evaluated)."""
    K = 29
    body = LISTX.replace('@ZEROS', '')
    body = body.replace('@ABSURDV', absurd_cases('Sequence', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    body = _cut_def(body, 'hWZ')
    body = _cut_def(body, 'eLc')
    body = _cut_def(body, 'hcL')
    body = _cut_def(body, 'ivf')
    reps = [
        ('# Whole elements, at most @N.\ndef CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), @N))',
         TPL.text('listx40_text')),
        ('  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))', '  +hz = VLS.hdz29(d, len, hd, hL)'),
        ('  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)',
         '  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),\n'
         '    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))'),
        ('  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), {==},',
         '  V40.list_u64_partsk(k, W, @LIMN, hcL(t, x, off, len, hchk),\n'
         '    FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(len), VS.x8(k), eLc(t, x, off, len, hchk),\n'
         '      VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))),'),
        ('U32.to_nat(@N)', '@LIMN'),
    ]
    for a, b in reps:
        assert a in body, a[:60]
        body = body.replace(a, b)
    ivf = TPL.text('ivf')
    a = body.index('\ndef ivm4(')
    body = body[:a] + ivf + body[a:]
    for k, v in [('@Kn', f'{K}n'), ('@LIMN', limn), ('@SCH', sch), ('@EL', el), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    assert '@' not in body.replace('&2', ''), [l for l in body.splitlines() if '@' in l.replace('&2', '')][:3]
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vu40.bend as V40', 'import ./vvlz.bend as VZG', '', '# GENERATED by var_win (codegen). Do not edit.',
                 f'# List[uint64, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    text = '\n'.join(L) + COMMONX + body
    return deep_xN(text) if deep else text



LISTU8X40 = TPL.text('LISTU8X40')


def listu8x40_text(p, sch, limn, deep=False):
    """List[uint8, 2^40] at a window at any byte offset (BeaconState's participation lists)."""
    body = LISTU8X40
    for k, v in [('@LIMN', limn), ('@SCH', sch), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vu40.bend as V40', 'import ./vvlz.bend as VZG', 'import ./vu8.bend as U8',
                 'import ./pb_min.bend as PB', '', '# GENERATED by var_win (codegen). Do not edit.',
                 f'# List[uint8, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    text = '\n'.join(L) + COMMONX + body
    return deep_xN(text) if deep else text


# A container of two variable-size fields of one child type (AttesterSlashing):
# offsets at bytes 0 and 4, windows [O0, O1) and [O1, len).
ASX = TPL.text('ASX')


def asx_stages(sch):
    """The inversion stages of ASX's invw (two variable parts of schema sch)."""
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    GOAL = '{CHKw(t, x, off, len) == True{} : Bool}'
    L = []
    w = L.append

    def absurd():
        return f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))'

    def match_value(var, keep, body):
        out = [f'  match {var}:']
        for c, args in VALUE_CTORS:
            if c == keep[0]:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in keep[1]) + f'}}: {body}')
            else:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in args) + f'}}: {absurd()}')
        return out

    def CC(parts, X):
        for pp in reversed(parts):
            X = f'Codec.concatenate(Some{{[{pp}]}}, {X})'
        return X

    def E(parts, X):
        return f'{{Codec.aggregate({CC(parts, X)}, None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}'
    chains = [f'S.Chain{{{sch}, S.Chain{{{sch}, S.End{{}}}}}}', f'S.Chain{{{sch}, S.End{{}}}}', 'S.End{}']
    PL2 = '[S.Variable{y0}, S.Variable{y1}]'
    b5 = f'Bool.and(Layout.bytes_valid({PL2}), N.fits(4n, Nat.add(Layout.fixed_size({PL2}), List.length(&2, U32, Layout.payloads({PL2})))))'
    D0 = '+h0: S.Value, +y0: +List<U32>, +eh0: {Codec.parts(h0, ' + sch + ') == Some{[S.Variable{y0}]} : ' + MP + '}'
    D1 = '+h1: S.Value, +y1: +List<U32>, +eh1: {Codec.parts(h1, ' + sch + ') == Some{[S.Variable{y1}]} : ' + MP + '}'
    w(f'def fin(@CW, {D0}, {D1}, +b5: Bool, +e: {{Codec.one(SP.optional(b5, OUT2(y0, y1)), None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w(f'    case True{{}}: contra(@CWA, h0, y0, eh0, h1, y1, eh1, var_inj(OUT2(y0, y1), {WBL}, e))')
    w('')
    w(f'def st2(@CW, {D0}, {D1}, +items: S.Value, +e: {E(["S.Variable{y0}", "S.Variable{y1}"], "Codec.parts(items, S.End{})")}) -> {GOAL}:')
    L.extend(match_value('items', ('EmptyItems', []), f'fin(@CWA, h0, y0, eh0, h1, y1, eh1, {b5}, e)'))
    w('')
    for i in (1, 0):
        prev = ['S.Variable{y0}'] if i == 1 else []
        pdecl = f'{D0}, ' if i == 1 else ''
        pargs = 'h0, y0, eh0, ' if i == 1 else ''
        nxt = f'Codec.parts(r, {chains[i + 1]})'
        w(f'def vp{i}(@CW, {pdecl}+h: S.Value, +ps: +List<S.Part>, hf: DF.single(None{{}}, ps), +em: {{Codec.parts(h, {sch}) == Some{{ps}} : {MP}}}, +r: S.Value,')
        w(f'    +e: {E(prev, f"Codec.concatenate(Some{{ps}}, {nxt})")}) -> {GOAL}:')
        w('  match ps:')
        w(f'    case Nil{{}}: Empty.absurd({GOAL}, hf)')
        w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
        w(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{i + 1}(@CWA, {pargs}h, ys, em, r, e)')
        w(f'    case Con{{S.Fixed{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)')
        w(f'    case Con{{S.Variable{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)')
        w('')
        w(f'def vm{i}(@CW, {pdecl}+h: S.Value, +mm: {MP}, hf: DF.single_result(None{{}}, mm), +em: {{Codec.parts(h, {sch}) == mm : {MP}}}, +r: S.Value,')
        w(f'    +e: {E(prev, f"Codec.concatenate(mm, {nxt})")}) -> {GOAL}:')
        w('  match mm:')
        w(f'    case None{{}}: {absurd()}')
        w(f'    case Some{{+ps}}: vp{i}(@CWA, {pargs}h, ps, hf, em, r, e)')
        w('')
        w(f'def fd{i}(@CW, {pdecl}+h: S.Value, +r: S.Value, +e: {E(prev, f"Codec.concatenate(Codec.parts(h, {sch}), {nxt})")}) -> {GOAL}:')
        w(f'  vm{i}(@CWA, {pargs}h, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), {{==}}, r, e)')
        w('')
        w(f'def st{i}(@CW, {pdecl}+items: S.Value, +e: {E(prev, f"Codec.parts(items, {chains[i]})")}) -> {GOAL}:')
        L.extend(match_value('items', ('Items', ['h', 'r']), f'fd{i}(@CWA, {pargs}h, r, e)'))
        w('')
    w("# Every value whose spec parts are the window's bytes passes the checks.")
    w(f'def invw(@CW, +v: S.Value, +e: {{Codec.parts(v, Spec.@AS()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    L.extend(match_value('v', ('Sequence', ['items']), 'st0(@CWA, items, e)'))
    return '\n'.join(L)


def asx_deep(text):
    """asx_text at any depth d < 31: offsets below 2^32 from hw32, the children's deep interface."""
    from codegen.proofs.support import deep
    P32 = 'FD.spec_common__pow2(32n)'
    reps = [
        ("""  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), A.quad(VB.pw(d)), Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))""",
         f"""  +hl = FD.nat__le_lt_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), {P32}, Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == True{{}} : Bool}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32))
  VB.add_lt32(off, o, x, eo, hl)"""),
        ('VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))',
         f'VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P32}, Order.left_below_sum(x, U32.to_nat(len)), hw32))'),
        ('VFT.fits4(2n+d, Nat.add(8n, List.length(&2, U32, y0)), FD.nat__le_trans(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), A.quad(VB.pw(d)), le8y0, hlen(d, x, len, hw)), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))',
         f'VFT.fits4lt(Nat.add(8n, List.length(&2, U32, y0)), FD.nat__le_lt_trans(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), {P32}, le8y0,\n'
         f'      FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P32}, Order.left_below_sum(x, U32.to_nat(len)), hw32)))'),
    ]
    for a, b in reps:
        assert a in text, a[:70]
        text = text.replace(a, b)
    # hwj / hw8 with the window's end below 2^32
    a = text.index('\ndef hwj(')
    b = text.index('\n\n', a + 1)
    hwj = text[a:b]
    hwj32 = (hwj.replace('def hwj(', 'def hwj32(').replace('# ', '# ')
             .replace('Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), A.quad(VB.pw(d)))', f'Nat.is_lt(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), {P32})')
             .replace('{Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), A.quad(VB.pw(d))) == True{} : Bool}', f'{{Nat.is_lt(Nat.add(Nat.add(U32.to_nat(o), x), _), {P32}) == True{{}} : Bool}}')
             .replace('{Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}', f'{{Nat.is_lt(_, {P32}) == True{{}} : Bool}}')
             .replace('FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)',
                      f'FD.nat__le_lt_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), {P32}, Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw32)'))
    assert 'A.quad(VB.pw(d))' not in hwj32[hwj32.index('    -> '):], hwj32
    text = text[:b] + '\n' + hwj32 + text[b:]
    a = text.index('\ndef hw8(')
    b = text.index('\n\n', a + 1)
    hw8 = text[a:b]
    hw832 = (hw8.replace('def hw8(', 'def hw8_32(').replace('Nat.is_le(Nat.add(8n+x, U32.to_nat(A0(t, x))), A.quad(VB.pw(d)))', f'Nat.is_lt(Nat.add(8n+x, U32.to_nat(A0(t, x))), {P32})')
             .replace('hwj(', 'hwj32('))
    text = text[:b] + '\n' + hw832 + text[b:]
    # the children's deep interface
    pat = re.compile(r'CH\.(ok_evalw|readw|specw|invw)\(')
    out, i = [], 0
    while True:
        m = pat.search(text, i)
        if not m:
            out.append(text[i:])
            break
        a = m.end()
        b = deep._close(text, a)
        args = deep._split_args(text[a:b])
        h = args[8].strip()
        assert h.startswith(('hwj(', 'hw8(')), h
        h32 = h.replace('hwj(', 'hwj32(', 1) if h.startswith('hwj(') else h.replace('hw8(', 'hw8_32(', 1)
        args.insert(9, ' ' + h32)
        out.append(text[i:m.start()] + f'CH.{m.group(1)}D(' + ','.join(args) + ')')
        i = b + 1
    return deep_x(''.join(out))


def asx_text(n, c, chmod, sch):
    CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
          '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
          '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    body = ASX.replace('@STAGES', asx_stages(sch)).replace('@SC', f'Spec.{c}()').replace('@CWA', CWA).replace('@CW', CW).replace('@AS', n).replace('@C_', f'{c}_').replace('T.@C', f'T.{c}').replace('@S', sch)
    L = HEADX + ['import ../../src/primitives.bend as I', 'import ./vua_rd.bend as UR', f'import ./{chmod} as CH', 'import ./vdig.bend as VG',
                 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF', '',
                 '# GENERATED by var_win (codegen). Do not edit.',
                 f'# {n} at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + COMMONX + body


def main():
    # accepts '--check' (var_finish.finish reads it)
    VL.SL.EXACT = True   # the exact spec-parts proofs (codegen/proofs/laws/spec_laws.py), before any walk
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    out = {}
    defs = spec_defs()
    # the bit lists of the containers
    for n in WIN:
        kids, _ = VL.spec_schemas(n)
        for (fname_, ft), k in zip(names[n].fields, kids):
            if ft.kind == 'bitlist':
                m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[k])
                b = Bits(ft.size, g.shape(ft).p, f'Spec.{k}()', m.group(1))
                out[bits_fname(b)] = bits_text(b)
    src = RR.mono_text('fulu')
    mods = {}
    for n in WIN:
        kids, _ = VL.spec_schemas(n)
        x = WName(g, n, names[n], src, kids)
        vf = x.var
        ft = vf['t']
        if ft.kind == 'bitlist':
            m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[vf['sk']])
            b = Bits(ft.size, g.shape(ft).p, f'Spec.{vf["sk"]}()', m.group(1))
            chf, chrep, big = bits_fname(b), 'O.Bits', big_bits(b)
        else:
            chf, chrep, big = mods[ft.name]
        big = big or False
        wf = ROOT / f'proofs/obj/var_win_{n}.bend'
        mods[n] = (wf, f'T.{n}', big)
        out[wf] = cont_text(g, x, None, chf.name, f'Spec.{vf["sk"]}()', chrep, None)
        if n not in VL.BITC:
            tf = ROOT / f'proofs/obj/var_win_{n}_top.bend'
            out[tf] = top_text(x, wf.name, kids, True)
            out[ROOT / f'proofs/obj/var_win_{n}_unique.bend'] = unique_text(x, tf.name)
    # byte-offset windows
    for n in WINX:
        kids, _ = VL.spec_schemas(n)
        x = WName(g, n, names[n], src, kids)
        vf = x.var
        ft = vf['t']
        if ft.kind == 'bitlist':
            m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[vf['sk']])
            b = Bits(ft.size, g.shape(ft).p, f'Spec.{vf["sk"]}()', m.group(1))
            big = big_bits(b)
            chf, chtext, chrep = bitsx_fname(b), (lambda b=b: bitsx_text(b, deep=True)), 'O.Bits'
        else:
            assert ft.kind == 'list' and ft.elem.kind == 'uint' and ft.elem.size == 8
            m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[vf['sk']])
            big = ft.size >= 1 << 16
            p = g.shape(ft).p
            chf = ROOT / f'proofs/obj/{"" if big else ""}var_winx_{p}.bend'
            chtext = (lambda ft=ft, p=p, m=m, vf=vf: listx_deep_text(ft.size, p, f'Spec.{vf["sk"]}()', f'Spec.{m.group(1)}()', m.group(2)))
            chrep = 'O.Words'
        out[chf] = chtext()
        out[ROOT / f'proofs/obj/{"" if big else ""}var_winx_{n}.bend'] = contx_text(g, x, chf.name, f'Spec.{vf["sk"]}()', chrep)
    # List[uint64, 2^40] (BeaconState's balances, inactivity_scores)
    bkids, _ = VL.spec_schemas('BeaconState')
    bi = [f for f, _ in names['BeaconState'].fields].index('balances')
    bst, bsk = names['BeaconState'].fields[bi][1], bkids[bi]
    m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[bsk])
    out[ROOT / f'proofs/obj/var_winx_{g.shape(bst).p}.bend'] = listx40_text(g.shape(bst).p, f'Spec.{bsk}()', f'Spec.{m.group(1)}()', m.group(2), deep=True)
    bi = [f for f, _ in names['BeaconState'].fields].index('previous_epoch_participation')
    bst, bsk = names['BeaconState'].fields[bi][1], bkids[bi]
    m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[bsk])
    out[ROOT / f'proofs/obj/var_winx_{g.shape(bst).p}.bend'] = listu8x40_text(g.shape(bst).p, f'Spec.{bsk}()', m.group(2), deep=True)
    # two variable fields of one child (AttesterSlashing)
    kids, _ = VL.spec_schemas('AttesterSlashing')
    out[ROOT / 'proofs/obj/var_winx_AttesterSlashing.bend'] = asx_deep(asx_text('AttesterSlashing', 'IndexedAttestation', 'var_winx_IndexedAttestation.bend', f'Spec.{kids[0]}()'))
    # only files this generator wrote (var_rlist.py writes var_winx_* modules too)
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_win*.bend') if q.name.startswith(('var_win_', 'var_winx_'))
            and '# GENERATED by var_win (codegen)' in q.read_text()[:400]]
    orphans = sorted(str(q.relative_to(ROOT)) for q in mine if q not in out)
    return finish(out, 'stale generated window laws: ', 'generated window laws are current', orphans, retire=True)


if __name__ == '__main__':
    main()
