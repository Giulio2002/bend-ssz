#!/usr/bin/env python3
"""Byte-offset window of List[Validator, 2^40] (BeaconState.validators): the
interface of proofs/obj/vua_win.bend.

    python3 codegen/proofs/var/validator_list_window.py [--check]

A Validator record is 121 bytes (not whole words), so record j of the window
sits at byte x + 121 j at any phase: its words are the four-byte joins
UR.RWN(t, y + c), its boolean the byte LB(t, y + 88) of the spec's bytes. The
runtime validates each record's boolean (its byte is at most 1) in a loop; the
reader fills the record array in a loop. Both loops are proved by induction on
the records left; every depth bound comes from the buffer (x + len <= 4 2^d),
never from the 2^40 limit (vu40 compares that one symbolically).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys
from codegen.core import generated_file_writer as writer  # noqa: E402

from codegen.proofs.var import nested_type_window_laws as W  # noqa: E402
from codegen.proofs.var import byte_list_codec_laws as VBY  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader import Templates  # noqa: E402
TEMPLATES = Templates('validator_list_window', globals())
OUT = 'var_winx_l1099511627776_Validator.bend'
P = 'l1099511627776_Validator'
RS = 121
TRUE = 'True{} : Bool'
PW = 'A.quad(VB.pw(d))'
BUF = 'UA.BF(t, n)'
CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
      '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
      '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
# a record at y: its hypotheses
RY = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +y: Nat, +e: {U32.to_nat(off) == y : Nat},\n'
      '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},\n'
      f'    +hb: {{Nat.is_le(Nat.add(y, {RS}n), A.quad(VB.pw(d))) == True{{}} : Bool}}')
RYA = 'd, t, n, off, y, e, hd, pf, hb'

# the fields: (runtime reader prefix, byte position, size, words)
FIELDS = [('b48', 0, 48), ('b32', 48, 32), ('u64', 80, 8), ('bool', 88, 1), ('u64', 89, 8), ('u64', 97, 8), ('u64', 105, 8), ('u64', 113, 8)]


def ypos(c):
    return 'y' if c == 0 else f'{c}n+y'


def words(c, s):
    return [f'UR.RWN(t, {ypos(c + 4 * k)})' for k in range(s // 4)]


def fobj(p, c, s):
    ws = words(c, s)
    if p == 'b48':
        return 'T.Bytes48{' + ', '.join(ws) + '}'
    if p == 'b32':
        return 'T.Bytes32{' + ', '.join(ws) + '}'
    if p == 'u64':
        return 'O.U64{' + ', '.join(ws) + '}'
    return f'U32.is_eq(LB(t, {ypos(c)}), 1)'


def record_text():
    objs = [fobj(p, c, s) for p, c, s in FIELDS]
    RX = 'T.Validator{' + ', '.join(objs) + '}'
    w = []
    w.append(TEMPLATES.render('record_text'))
    # the reader of one record
    RHS = f'({BUF}, RX(t, y)) : B.Buf & T.Validator'
    w.append(f'def RX(+t: FD.array__Tree<U32>, +y: Nat) -> T.Validator: {RX}')
    w.append('')
    w.append(TEMPLATES.render('record_text_2'))
    w.append(f'# The runtime reads the record at off (at byte y).')
    w.append(f'def rdxV({RY}) -> {{T.Validator_read({BUF}, off, {RS}) == {RHS}}}:')
    done = []
    for i, (p, c, sz) in enumerate(FIELDS):
        eo = f'eoy({RYA}, {c}, {c}n, {{==}}, {sz - 1}n, {{==}})'
        hole = f'T.Validator_rd{i}(off, {RS}, {", ".join(done + ["_"])})' if i else 'T.Validator_rd0(off, 121, _)'
        if p == 'bool':
            hole = f'T.Validator_rd{i}(off, {RS}, {", ".join(done)}, O.bool_of(_))'
            w.append(f'  %Equal.sym(B.Buf & U32, B.byte_at({BUF}, U32.add(off, {c})), ({BUF}, LB(t, {ypos(c)})), bat(d, t, n, U32.add(off, {c}), Nat.add({c}n, y), {eo}, hd, pf,')
            w.append(f'      FD.nat__lt_le_trans(Nat.add({c}n, y), Nat.add(Nat.add({c}n, y), 1n), {PW}, VTX.ltp(Nat.add({c}n, y), 0n), UR.roomf(y, {RS}n, {c}n, 1n, {PW}, hb, {{==}})))) :')
        else:
            ty = {'b48': 'T.Bytes48', 'b32': 'T.Bytes32', 'u64': 'O.U64'}[p]
            w.append(f'  %Equal.sym(B.Buf & {ty}, T.{p}_read({BUF}, U32.add(off, {c}), {sz}), ({BUF}, {fobj(p, c, sz)}),')
            w.append(f'      VTX.rdx_{p}(d, t, n, U32.add(off, {c}), Nat.add({c}n, y), {eo}, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), pf, UR.roomf(y, {RS}n, {c}n, {sz}n, {PW}, hb, {{==}}))) :')
        w.append(f'    {{{hole} == {RHS}}}')
        done.append(fobj(p, c, sz))
    w.append('  {==}')
    w.append('')
    w.append(TEMPLATES.render('record_text_3'))
    return RX, '\n'.join(w)


def POS(j):
    return f'VRL.pos({j}, {RS}n, x)'


def list_check_text():
    TR = 'FD.array__Tree<U32>'
    HB = lambda k, j: f'+hb: {{Nat.is_le({POS(f"Nat.add(1n+{k}, {j})")}, {PW}) == {TRUE}}}'
    return TEMPLATES.render('list_check_text', TR=TR, HB=HB)


def reader_text():
    TR = 'FD.array__Tree<U32>'
    TRR = 'FD.array__Tree<T.Validator>'
    RD = 'B.Buf & Array<T.Validator>'
    HC = f'+hchk: {{CHKw(t, x, off, len) == {TRUE}}}'
    return TEMPLATES.render('reader_text', TR=TR, HC=HC, TRR=TRR, RD=RD)


SCHS = ['Spec.Schema8()', 'Spec.Schema7()', 'Spec.Schema3()', 'Spec.Schema0()', 'Spec.Schema3()', 'Spec.Schema3()', 'Spec.Schema3()', 'Spec.Schema3()']
LSCH = 'Spec.Schema78()'
LIMN = 'Nat.mul(U32.to_nat(1073741824), 1024n)'


def spec_text():
    TR = 'FD.array__Tree<U32>'
    MP = 'Maybe<&2, +List<S.Part>>'
    vals, parts, cats, lsch = [], [], [], []
    for p_, c, sz in FIELDS:
        ws = words(c, sz)
        if p_ in ('b48', 'b32'):
            vals.append(f'S.BytesValue{{F.limbs([{", ".join(ws)}])}}')
            parts.append(f'S.Fixed{{F.limbs([{", ".join(ws)}])}}')
            cats.append(f'F.bytes_part_n({ws[0]}, [{", ".join(ws[1:])}], {sz}n, {{==}}, {{==}})')
            lsch.append(f'S.ByteVector{{{sz}n}}')
        elif p_ == 'u64':
            vals.append(f'S.UnsignedValue{{P.UInt{{{ws[0]}, {ws[1]}, 0, 0, 0, 0, 0, 0}}}}')
            parts.append(f'S.Fixed{{F.limbs([{ws[0]}, {ws[1]}])}}')
            cats.append(f'F.uint64_part({ws[0]}, {ws[1]})')
            lsch.append('S.Unsigned{P.U64{}}')
        else:
            vals.append(f'S.BooleanValue{{U32.is_eq(LB(t, {ypos(c)}), 1)}}')
            parts.append(f'S.Fixed{{[LB(t, {ypos(c)})]}}')
            lsch.append('S.Boolean{}')
            cats.append(f'Equal.cong(+List<U32>, {MP}, z => Some{{[S.Fixed{{z}}]}}, SP.boolean_encoding(U32.is_eq(LB(t, {ypos(c)}), 1)), [LB(t, {ypos(c)})], b01(LB(t, {ypos(c)}), hc))')
    n = len(FIELDS)

    # named field suffixes (byte_list_codec_laws.chain_defs): the chain's levels carry small calls
    NV = ('RC', f'+t: {TR}, +y: Nat', 't, y', f'+t: {TR}, +y: Nat', 't, y')
    CDEF = '\n'.join(VBY.chain_defs(*NV, vals, SCHS, parts))

    def itm(i):
        return f'RCV{i}(t, y)'

    def chain(i):
        return f'RCS{i}()'

    # one def per field (callee first): ctl<i> proves the parts of the fields from i on. Each
    # unfolds its named suffixes by one-step {==} rewrites and closes with VS.chain_fixed at the
    # field's literal schema, so no level re-evaluates the parts of the fields after it (the
    # nested F.cat_fixed chain did: its levels' types met only after whnf, which runs
    # Codec.parts to the end), and a uint's field part meets its lemma's schema syntactically.
    CTL = [f'def ctl{n}(+t: {TR}, +y: Nat, +hc: {{VCK(t, y) == {TRUE}}}) -> {{Codec.parts(RCV{n}(t, y), RCS{n}()) == Some{{RCP{n}(t, y)}} : {MP}}}: {{==}}']
    for i in range(n - 1, -1, -1):
        xs = parts[i][len('S.Fixed{'):-1]
        IT = f'S.Items{{{vals[i]}, RCV{i + 1}(t, y)}}'
        CH = f'S.Chain{{{lsch[i]}, RCS{i + 1}()}}'
        PP = f'Con{{{parts[i]}, RCP{i + 1}(t, y)}}'
        CTL += [f'def ctl{i}(+t: {TR}, +y: Nat, +hc: {{VCK(t, y) == {TRUE}}}) -> {{Codec.parts(RCV{i}(t, y), RCS{i}()) == Some{{RCP{i}(t, y)}} : {MP}}}:',
                f'  %Equal.sym(S.Value, RCV{i}(t, y), {IT}, {{==}}) : {{Codec.parts(_, RCS{i}()) == Some{{RCP{i}(t, y)}} : {MP}}}',
                f'  %Equal.sym(S.Schema, RCS{i}(), {CH}, {{==}}) : {{Codec.parts({IT}, _) == Some{{RCP{i}(t, y)}} : {MP}}}',
                f'  %Equal.sym(+List<S.Part>, RCP{i}(t, y), {PP}, {{==}}) : {{Codec.parts({IT}, {CH}) == Some{{_}} : {MP}}}',
                f'  VS.chain_fixed({vals[i]}, RCV{i + 1}(t, y), {lsch[i]}, RCS{i + 1}(), {xs}, RCP{i + 1}(t, y), {cats[i]}, ctl{i + 1}(t, y, hc))']
    CTLS = '\n'.join(CTL)

    def cat(i):
        return 'ctl0(t, y, hc)'
    RPS = '[' + ', '.join(parts) + ']'
    FPR = '[]'
    for pt in reversed(parts):
        FPR = f'List.append(&2, U32, {pt[len("S.Fixed{"):-1]}, {FPR})'
    TGTF = f'Some{{[S.Fixed{{UW.WX(t, y, {RS}n)}}]}}'
    doms = []
    for p_, c, sz in FIELDS:
        if p_ == 'bool':
            doms.append((f'SP.bytes_domain([LB(t, {ypos(c)})])', f'FD.logic__and_intro(U32.is_lt(LB(t, {ypos(c)}), 256), True{{}}, b256(LB(t, {ypos(c)}), hc), {{==}})'))
        else:
            ws = words(c, sz)
            doms.append((f'SP.bytes_domain(F.limbs([{", ".join(ws)}]))', f'F.domain_limbs([{", ".join(ws)}])'))
    hv = '{==}'
    for i in range(n - 1, -1, -1):
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        hv = f'FD.logic__and_intro({doms[i][0]}, Layout.bytes_valid({rest}), {doms[i][1]},\n      {hv})'
    RY2 = ('+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},\n'
           f'    +hb: {{Nat.is_le(Nat.add(y, {RS}n), {PW}) == {TRUE}}}')
    return TEMPLATES.render('spec_text', CDEF=CDEF, TR=TR, itm=itm, RY2=RY2, FPR=FPR, CTLS=CTLS, TGTF=TGTF, MP=MP, chain=chain, cat=cat, RPS=RPS, hv=hv)


def list_spec_text():
    TR = 'FD.array__Tree<U32>'
    MP = 'Maybe<&2, +List<S.Part>>'
    HC = f'+hchk: {{CHKw(t, x, off, len) == {TRUE}}}'
    V = lambda j: f'VCK(t, {POS(j)})'
    return TEMPLATES.render('list_spec_text', TR=TR, V=V, HC=HC, MP=MP)


VALUES = ['BooleanValue{+b0}', 'UnsignedValue{+u0}', 'BytesValue{+xs0}', 'BitsValue{+bs0}', 'Sequence{+it0}', 'Items{+hd0, +tl0}', 'EmptyItems{}',
          'Selected{+sel0, +sv0}', 'NullValue{}']


def rinv_text():
    MP = 'Maybe<&2, +List<S.Part>>'
    TG = 'Some{[S.Fixed{xs}]}'
    GR = f'{{U32.is_le(VBL.nthb(xs, 88n), 1) == {TRUE}}}'
    ABS = f'Empty.absurd({GR}, FD.logic__none_some(+List<S.Part>, [S.Fixed{{xs}}], e))'
    n = len(SCHS)

    def chain(i):
        return 'S.End{}' if i == n else f'S.Chain{{{SCHS[i]}, {chain(i + 1)}}}'
    parts = ['S.Fixed{a0}', 'S.Fixed{a1}', 'S.Fixed{a2}', 'S.Fixed{SP.boolean_encoding(b)}']

    def pre(i, inner):
        out = inner
        for pt in reversed(parts[:i]):
            out = f'Codec.concatenate(Some{{[{pt}]}}, {out})'
        return out
    sizes = [48, 32, 8]
    decl = ['', '+a0: +List<U32>, +l0: {Some{48n} == Some{List.length(&2, U32, a0)} : Maybe<&2, Nat>}, ',
            '+a0: +List<U32>, +l0: {Some{48n} == Some{List.length(&2, U32, a0)} : Maybe<&2, Nat>}, +a1: +List<U32>, +l1: {Some{32n} == Some{List.length(&2, U32, a1)} : Maybe<&2, Nat>}, ',
            '+a0: +List<U32>, +l0: {Some{48n} == Some{List.length(&2, U32, a0)} : Maybe<&2, Nat>}, +a1: +List<U32>, +l1: {Some{32n} == Some{List.length(&2, U32, a1)} : Maybe<&2, Nat>}, +a2: +List<U32>, +l2: {Some{8n} == Some{List.length(&2, U32, a2)} : Maybe<&2, Nat>}, ']
    args = ['', 'a0, l0, ', 'a0, l0, a1, l1, ', 'a0, l0, a1, l1, a2, l2, ']
    w = []
    w.append(TEMPLATES.render('rinv_text', MP=MP))
    R3 = 'List.append(&2, U32, SP.boolean_encoding(b), Layout.fixed_parts(rps, o))'
    R2 = f'List.append(&2, U32, a2, {R3})'
    R1 = f'List.append(&2, U32, a1, {R2})'
    X = lambda a, r: f'List.append(&2, U32, List.append(&2, U32, {a}, {r}), P)'
    w.append(TEMPLATES.render('rinv_text_2', decl=decl, X=X, R1=R1, R2=R2, R3=R3))
    PSX = 'S.Fixed{a0} <> S.Fixed{a1} <> S.Fixed{a2} <> S.Fixed{SP.boolean_encoding(b)} <> rps'
    BY = f'List.append(&2, U32, Layout.fixed_parts({PSX}, Layout.fixed_size({PSX})), Layout.payloads({PSX}))'
    w.append(TEMPLATES.render('rinv_text_3', decl=decl, BY=BY, TG=TG, MP=MP, GR=GR, ABS=ABS, args=args, PSX=PSX, pre=pre))
    # the boolean field
    body = [f'def rb3({decl[3]}+h: S.Value, +r: S.Value, +xs: +List<U32>,',
            f'    +e: {{Codec.aggregate({pre(3, f"Codec.concatenate(Codec.parts(h, {SCHS[3]}), Codec.parts(r, {chain(4)}))")}, Some{{{RS}n}}) == {TG} : {MP}}}) -> {GR}:',
            '  match h:']
    for v in VALUES:
        nm = v.split('{')[0]
        if nm == 'BooleanValue':
            body.append(f'    case S.BooleanValue{{+b}}: rq4({args[3]}b, Codec.parts(r, {chain(4)}), xs, e)')
        else:
            body.append(f'    case S.{v}: {ABS}')
    w.append('\n'.join(body) + '\n')
    for i in range(3, -1, -1):
        e_ty = f'{{Codec.aggregate({pre(i, f"Codec.parts(items, {chain(i)})")}, Some{{{RS}n}}) == {TG} : {MP}}}'
        body = [f'def rs{i}({decl[i]}+items: S.Value, +xs: +List<U32>, +e: {e_ty}) -> {GR}:', '  match items:']
        for v in VALUES:
            nm = v.split('{')[0]
            if nm == 'Items':
                if i == 3:
                    body.append(f'    case S.Items{{+h, +r}}: rb3({args[3]}h, r, xs, e)')
                else:
                    body.append(f'    case S.Items{{+h, +r}}: rm{i}({args[i]}h, Codec.parts(h, {SCHS[i]}), DS.facts(h, {SCHS[i]}, {{==}}), {{==}}, r, xs, e)')
            else:
                body.append(f'    case S.{v}: {ABS}')
        if i < 3:
            sz = sizes[i]
            nxt = f'rs{i + 1}({args[i]}a, hf, r, xs, e)'
            e_fp = f'{{Codec.aggregate({pre(i, f"Codec.concatenate(Some{{ps}}, Codec.parts(r, {chain(i + 1)}))")}, Some{{{RS}n}}) == {TG} : {MP}}}'
            e_fm = f'{{Codec.aggregate({pre(i, f"Codec.concatenate(mm, Codec.parts(r, {chain(i + 1)}))")}, Some{{{RS}n}}) == {TG} : {MP}}}'
            w.append(TEMPLATES.render('rinv_text_4', i=i, decl=decl, sz=sz, e_fp=e_fp, GR=GR, nxt=nxt, MP=MP, e_fm=e_fm, ABS=ABS, args=args))
        w.append('\n'.join(body) + '\n')
    body = [f'# A record\'s bytes hold a boolean byte (at most 1) at 88.',
            f'def rv(+h: S.Value, +xs: +List<U32>, +e: {{Codec.parts(h, Spec.Schema58()) == {TG} : {MP}}}) -> {GR}:', '  match h:']
    for v in VALUES:
        nm = v.split('{')[0]
        if nm == 'Sequence':
            body.append('    case S.Sequence{+items}: rs0(items, xs, e)')
        else:
            body.append(f'    case S.{v}: {ABS}')
    w.append('\n'.join(body) + '\n')
    return '\n'.join(w)


def linv_text():
    TR = 'FD.array__Tree<U32>'
    MP = 'Maybe<&2, +List<S.Part>>'
    REP = 'S.Repeat{Spec.Schema58()}'
    BYo = lambda ps: f'List.append(&2, U32, Layout.fixed_parts({ps}, o), Layout.payloads({ps}))'
    V = lambda j: f'VCK(t, {POS(j)})'
    LEN = lambda xs: f'List.length(&2, U32, {xs})'
    DT = f'+d: Nat, +t: {TR}, +x: Nat, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}'
    GL = lambda its, ps: f'{{List.length(&2, U32, {BYo(ps)}) == Nat.mul(Codec.count({its}), {RS}n) : Nat}}'
    IHL = f'ih: @+pt: +List<S.Part> -> {{Codec.parts(r, {REP}) == Some{{pt}} : {MP}}} -> {GL("r", "pt")}'
    GV = lambda its: f'{{ALLV(Codec.count({its}), j, t, x) == {TRUE}}}'
    IHV = (f'ih: @+pt: +List<S.Part> -> {{Codec.parts(r, {REP}) == Some{{pt}} : {MP}}} -> @+L2: Nat -> {{{BYo("pt")} == UW.WX(t, {POS("1n+j")}, L2) : +List<U32>}}'
           f' -> {{Nat.is_le(Nat.add({POS("1n+j")}, L2), {PW}) == {TRUE}}} -> {{ALLV(Codec.count(r), 1n+j, t, x) == {TRUE}}}')
    ABSL = f'Empty.absurd({GL("S.Items{h, r}", "ps")}, FD.logic__none_some(+List<S.Part>, ps, e))'
    ABSV = f'Empty.absurd({GV("S.Items{h, r}")}, FD.logic__none_some(+List<S.Part>, ps, e))'
    w = []
    w.append(f"""
# ---- the inversion: the list ---------------------------------------------------------------------

def cancel_l(+a: +List<U32>, +b: +List<U32>, +c: +List<U32>, +q: +List<U32>, +E: {{List.append(&2, U32, a, b) == List.append(&2, U32, c, q) : +List<U32>}},
    +hl: {{{LEN("a")} == {LEN("c")} : Nat}}) -> {{a == c : +List<U32>}}:
  +e1 = Equal.trans(+List<U32>, a, VS.bt({LEN("a")}, a), VS.bt({LEN("a")}, List.append(&2, U32, a, b)), Equal.sym(+List<U32>, VS.bt({LEN("a")}, a), a, UW.bt_self(a)),
    Equal.sym(+List<U32>, VS.bt({LEN("a")}, List.append(&2, U32, a, b)), VS.bt({LEN("a")}, a), VN.bt_app({LEN("a")}, a, b, FD.nat__le_refl({LEN("a")}))))
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt({LEN("a")}, z), List.append(&2, U32, a, b), List.append(&2, U32, c, q), E)
  +e3 = FD.logic__subst(Nat, z => {{VS.bt({LEN("a")}, List.append(&2, U32, c, q)) == VS.bt(z, List.append(&2, U32, c, q)) : +List<U32>}}, {LEN("a")}, {LEN("c")}, hl, {{==}})
  +e4 = Equal.trans(+List<U32>, VS.bt({LEN("c")}, List.append(&2, U32, c, q)), VS.bt({LEN("c")}, c), c, VN.bt_app({LEN("c")}, c, q, FD.nat__le_refl({LEN("c")})), UW.bt_self(c))
  Equal.trans(+List<U32>, a, VS.bt({LEN("a")}, List.append(&2, U32, a, b)), c, e1,
    Equal.trans(+List<U32>, VS.bt({LEN("a")}, List.append(&2, U32, a, b)), VS.bt({LEN("a")}, List.append(&2, U32, c, q)), c, e2,
      Equal.trans(+List<U32>, VS.bt({LEN("a")}, List.append(&2, U32, c, q)), VS.bt({LEN("c")}, List.append(&2, U32, c, q)), c, e3, e4)))

def cancel_r(+a: +List<U32>, +b: +List<U32>, +c: +List<U32>, +q: +List<U32>, +E: {{List.append(&2, U32, a, b) == List.append(&2, U32, c, q) : +List<U32>}},
    +hl: {{{LEN("a")} == {LEN("c")} : Nat}}) -> {{b == q : +List<U32>}}:
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => VS.bdr({LEN("a")}, z), List.append(&2, U32, a, b), List.append(&2, U32, c, q), E)
  +e3 = FD.logic__subst(Nat, z => {{VS.bdr({LEN("a")}, List.append(&2, U32, c, q)) == VS.bdr(z, List.append(&2, U32, c, q)) : +List<U32>}}, {LEN("a")}, {LEN("c")}, hl, {{==}})
  Equal.trans(+List<U32>, b, VS.bdr({LEN("a")}, List.append(&2, U32, a, b)), q, Equal.sym(+List<U32>, VS.bdr({LEN("a")}, List.append(&2, U32, a, b)), b, VS.bdr_app(a, b)),
    Equal.trans(+List<U32>, VS.bdr({LEN("a")}, List.append(&2, U32, a, b)), VS.bdr({LEN("a")}, List.append(&2, U32, c, q)), q, e2,
      Equal.trans(+List<U32>, VS.bdr({LEN("a")}, List.append(&2, U32, c, q)), VS.bdr({LEN("c")}, List.append(&2, U32, c, q)), q, e3, VS.bdr_app(c, q))))

# ---- lengths: every record is {RS} bytes -----------------------------------------------------------

def ll_t(+h: S.Value, +xs: +List<U32>, +r: S.Value, +ps: +List<S.Part>, +o: Nat, +lx: {{{LEN("xs")} == {RS}n : Nat}}, +mr: {MP}, +emr: {{Codec.parts(r, {REP}) == mr : {MP}}},
    +e: {{Codec.concatenate(Some{{[S.Fixed{{xs}}]}}, mr) == Some{{ps}} : {MP}}}, {IHL}) -> {GL("S.Items{h, r}", "ps")}:
  match mr:
    case None{{}}: Empty.absurd({GL("S.Items{h, r}", "ps")}, FD.logic__none_some(+List<S.Part>, ps, e))
    case Some{{+pt}}:
      %FD.logic__some_inj(+List<S.Part>, S.Fixed{{xs}} <> pt, ps, e) : {GL("S.Items{h, r}", "_")}
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(pt, o)), Layout.payloads(pt)), List.append(&2, U32, xs, {BYo("pt")}), VS.app_assoc(xs, Layout.fixed_parts(pt, o), Layout.payloads(pt))) :
        {{List.length(&2, U32, _) == Nat.mul(1n+Codec.count(r), {RS}n) : Nat}}
      %Equal.sym(Nat, {LEN(f"List.append(&2, U32, xs, {BYo('pt')})")}, Nat.add({LEN("xs")}, {LEN(BYo("pt"))}), VS.len_app(xs, {BYo("pt")})) : {{_ == Nat.mul(1n+Codec.count(r), {RS}n) : Nat}}
      %Equal.sym(Nat, {LEN("xs")}, {RS}n, lx) : {{Nat.add(_, {LEN(BYo("pt"))}) == Nat.mul(1n+Codec.count(r), {RS}n) : Nat}}
      Equal.cong(Nat, Nat, z => Nat.add({RS}n, z), {LEN(BYo("pt"))}, Nat.mul(Codec.count(r), {RS}n), ih(pt, emr))
""")
    # the item's part: one fixed part of RS bytes
    def mstages(pref, extra_decl, extra_args, goal, absurd_goal, tail):
        return TEMPLATES.render('mstages', pref=pref, extra_decl=extra_decl, MP=MP, REP=REP, tail=tail, goal=goal, absurd_goal=absurd_goal, extra_args=extra_args)
    lx = f'Equal.sym(Nat, {RS}n, {LEN("xs")}, LY.mnat({RS}n, {LEN("xs")}, hf))'
    w.append(mstages('ll', '+o: Nat, ', 'o, ', GL('S.Items{h, r}', 'ps'), ABSL,
                     (IHL, f'll_t(h, xs, r, ps, o, {lx}, Codec.parts(r, {REP}), {{==}}, e, ih)')))
    body = [f'law lenl:', '  for +its: S.Value', '  for +ps: +List<S.Part>', '  for +o: Nat', f'  for +e: {{Codec.parts(its, {REP}) == Some{{ps}} : {MP}}}',
            f'  {GL("its", "ps")}', 'def lenl(its, ps, o, e):', '  match its:',
            f'    case S.EmptyItems{{}}:',
            f'      %FD.logic__some_inj(+List<S.Part>, [], ps, e) : {GL("S.EmptyItems{}", "_")}',
            '      {==}',
            f'    case S.Items{{+h, +r}}: ll_m(h, r, ps, o, Codec.parts(h, Spec.Schema58()), DS.facts(h, Spec.Schema58(), {{==}}), {{==}}, e, pt => ept => lenl(r, pt, o, ept))']
    for v in VALUES:
        nm = v.split('{')[0]
        if nm in ('EmptyItems', 'Items'):
            continue
        body.append(f'    case S.{v}: Empty.absurd({GL("S." + v.replace("+", ""), "ps")}, FD.logic__none_some(+List<S.Part>, ps, e))')
    w.append('\n'.join(body) + '\n')
    # ---- the records' boolean bytes
    WJ = lambda L: f'UW.WX(t, {POS("j")}, {L})'
    w.append(f"""# ---- the records' boolean bytes, read back from the window ----------------------------------------

def iv_t(+h: S.Value, +xs: +List<U32>, +r: S.Value, +ps: +List<S.Part>, +o: Nat, +j: Nat, {DT}, +lx: {{{LEN("xs")} == {RS}n : Nat}},
    +hbyte: {{U32.is_le(VBL.nthb(xs, 88n), 1) == {TRUE}}}, +mr: {MP}, +emr: {{Codec.parts(r, {REP}) == mr : {MP}}},
    +e: {{Codec.concatenate(Some{{[S.Fixed{{xs}}]}}, mr) == Some{{ps}} : {MP}}}, +L: Nat, +E: {{{BYo("ps")} == {WJ("L")} : +List<U32>}},
    +hb: {{Nat.is_le(Nat.add({POS("j")}, L), {PW}) == {TRUE}}}, {IHV}) -> {GV("S.Items{h, r}")}:
  match mr:
    case None{{}}: {ABSV}
    case Some{{+pt}}:
      +B2 = {BYo("pt")}
      +L2 = {LEN("B2")}
      +E1 = FD.logic__subst(+List<S.Part>, z => {{{BYo("z")} == {WJ("L")} : +List<U32>}}, ps, S.Fixed{{xs}} <> pt,
        Equal.sym(+List<S.Part>, S.Fixed{{xs}} <> pt, ps, FD.logic__some_inj(+List<S.Part>, S.Fixed{{xs}} <> pt, ps, e)), E)
      +E2 = Equal.trans(+List<U32>, List.append(&2, U32, xs, B2), List.append(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(pt, o)), Layout.payloads(pt)), {WJ("L")},
        Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(pt, o)), Layout.payloads(pt)), List.append(&2, U32, xs, B2), VS.app_assoc(xs, Layout.fixed_parts(pt, o), Layout.payloads(pt))), E1)
      +eL = Equal.trans(Nat, L, {LEN(WJ("L"))}, Nat.add({RS}n, L2), Equal.sym(Nat, {LEN(WJ("L"))}, L, UW.lenWX(d, t, {POS("j")}, L, pf, hb)),
        Equal.trans(Nat, {LEN(WJ("L"))}, {LEN("List.append(&2, U32, xs, B2)")}, Nat.add({RS}n, L2),
          Equal.cong(+List<U32>, Nat, z => {LEN("z")}, {WJ("L")}, List.append(&2, U32, xs, B2), Equal.sym(+List<U32>, List.append(&2, U32, xs, B2), {WJ("L")}, E2)),
          Equal.trans(Nat, {LEN("List.append(&2, U32, xs, B2)")}, Nat.add({LEN("xs")}, L2), Nat.add({RS}n, L2), VS.len_app(xs, B2), Equal.cong(Nat, Nat, z => Nat.add(z, L2), {LEN("xs")}, {RS}n, lx))))
      +hb1 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({POS("j")}, z), {PW}) == {TRUE}}}, L, Nat.add({RS}n, L2), eL, hb)
      +E3 = FD.logic__subst(Nat, z => {{List.append(&2, U32, xs, B2) == {WJ("z")} : +List<U32>}}, L, Nat.add({RS}n, L2), eL, E2)
      +E4 = Equal.trans(+List<U32>, List.append(&2, U32, xs, B2), {WJ(f"Nat.add({RS}n, L2)")}, List.append(&2, U32, {WJ(f"{RS}n")}, UW.WX(t, Nat.add({RS}n, {POS("j")}), L2)), E3,
        UW.splitWX(t, {POS("j")}, {RS}n, L2))
      +hr = FD.nat__le_trans(Nat.add({POS("j")}, {RS}n), Nat.add({POS("j")}, Nat.add({RS}n, L2)), {PW}, Order.add_left({POS("j")}, {RS}n, Nat.add({RS}n, L2), FD.nat__le_add_right({RS}n, L2)), hb1)
      +lw = UW.lenWX(d, t, {POS("j")}, {RS}n, pf, hr)
      +eqx = cancel_l(xs, B2, {WJ(f"{RS}n")}, UW.WX(t, Nat.add({RS}n, {POS("j")}), L2), E4, Equal.trans(Nat, {LEN("xs")}, {RS}n, {LEN(WJ(f"{RS}n"))}, lx, Equal.sym(Nat, {LEN(WJ(f"{RS}n"))}, {RS}n, lw)))
      +eB = cancel_r(xs, B2, {WJ(f"{RS}n")}, UW.WX(t, Nat.add({RS}n, {POS("j")}), L2), E4, Equal.trans(Nat, {LEN("xs")}, {RS}n, {LEN(WJ(f"{RS}n"))}, lx, Equal.sym(Nat, {LEN(WJ(f"{RS}n"))}, {RS}n, lw)))
      +eP = FD.nat__add_assoc({RS}n, Nat.mul(j, {RS}n), x)
      +E5 = FD.logic__subst(Nat, z => {{B2 == UW.WX(t, z, L2) : +List<U32>}}, Nat.add({RS}n, {POS("j")}), {POS("1n+j")}, Equal.sym(Nat, {POS("1n+j")}, Nat.add({RS}n, {POS("j")}), eP), eB)
      +hb3 = FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == {TRUE}}}, Nat.add({POS("j")}, Nat.add({RS}n, L2)), Nat.add(Nat.add({RS}n, {POS("j")}), L2),
        Equal.trans(Nat, Nat.add({POS("j")}, Nat.add({RS}n, L2)), Nat.add({RS}n, Nat.add({POS("j")}, L2)), Nat.add(Nat.add({RS}n, {POS("j")}), L2),
          FD.lru_nat_algebra__add_swap({POS("j")}, {RS}n, L2), Equal.sym(Nat, Nat.add(Nat.add({RS}n, {POS("j")}), L2), Nat.add({RS}n, Nat.add({POS("j")}, L2)), FD.nat__add_assoc({RS}n, {POS("j")}, L2))), hb1)
      +hb2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, L2), {PW}) == {TRUE}}}, Nat.add({RS}n, {POS("j")}), {POS("1n+j")}, Equal.sym(Nat, {POS("1n+j")}, Nat.add({RS}n, {POS("j")}), eP), hb3)
      +nb = Equal.trans(U32, VBL.nthb({WJ(f"{RS}n")}, 88n), VBL.nthb(VS.bdr({POS("j")}, UA.BYT(t)), 88n), LB(t, Nat.add({POS("j")}, 88n)),
        VR.nth_bt({RS}n, VS.bdr({POS("j")}, UA.BYT(t)), 88n, {{==}}), VR.nth_bdr({POS("j")}, UA.BYT(t), 88n))
      +hbx = FD.logic__subst(+List<U32>, z => {{U32.is_le(VBL.nthb(z, 88n), 1) == {TRUE}}}, xs, {WJ(f"{RS}n")}, eqx, hbyte)
      +hby = FD.logic__subst(U32, z => {{U32.is_le(z, 1) == {TRUE}}}, VBL.nthb({WJ(f"{RS}n")}, 88n), LB(t, Nat.add({POS("j")}, 88n)), nb, hbx)
      +hvj = FD.logic__subst(Nat, z => {{U32.is_le(LB(t, z), 1) == {TRUE}}}, Nat.add({POS("j")}, 88n), Nat.add(88n, {POS("j")}), A.add_right({POS("j")}, 88n), hby)
      FD.logic__and_intro({V("j")}, ALLV(Codec.count(r), 1n+j, t, x), hvj, ih(pt, emr, L2, E5, hb2))
""")
    lx = f'Equal.sym(Nat, {RS}n, {LEN("xs")}, LY.mnat({RS}n, {LEN("xs")}, hf))'
    EXD = f'+o: Nat, +j: Nat, {DT}, +L: Nat, +E: {{{BYo("ps")} == {WJ("L")} : +List<U32>}}, +hb: {{Nat.is_le(Nat.add({POS("j")}, L), {PW}) == {TRUE}}}, '
    EXA = 'o, j, d, t, x, pf, L, E, hb, '
    w.append(mstages('iv', EXD, EXA, GV('S.Items{h, r}'), ABSV,
                     (IHV, f'iv_t(h, xs, r, ps, o, j, d, t, x, pf, {lx}, rv(h, xs, em), Codec.parts(r, {REP}), {{==}}, e, L, E, hb, ih)')))
    body = ['law invl:', '  for +its: S.Value', '  for +ps: +List<S.Part>', '  for +o: Nat', '  for +j: Nat', '  for +d: Nat', f'  for +t: {TR}', '  for +x: Nat',
            f'  for +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}', f'  for +e: {{Codec.parts(its, {REP}) == Some{{ps}} : {MP}}}', '  for +L: Nat',
            f'  for +E: {{{BYo("ps")} == {WJ("L")} : +List<U32>}}', f'  for +hb: {{Nat.is_le(Nat.add({POS("j")}, L), {PW}) == {TRUE}}}',
            f'  {GV("its")}', 'def invl(its, ps, o, j, d, t, x, pf, e, L, E, hb):', '  match its:',
            '    case S.EmptyItems{}: {==}',
            f'    case S.Items{{+h, +r}}: iv_m(h, r, ps, o, j, d, t, x, pf, L, E, hb, Codec.parts(h, Spec.Schema58()), DS.facts(h, Spec.Schema58(), {{==}}), {{==}}, e,',
            '      pt => ept => L2 => E2 => hb2 => invl(r, pt, o, 1n+j, d, t, x, pf, ept, L2, E2, hb2))']
    for v in VALUES:
        nm = v.split('{')[0]
        if nm in ('EmptyItems', 'Items'):
            continue
        body.append(f'    case S.{v}: Empty.absurd({GV("S." + v.replace("+", ""))}, FD.logic__none_some(+List<S.Part>, ps, e))')
    w.append('\n'.join(body) + '\n')
    return '\n'.join(w)


def top_inv_text():
    TR = 'FD.array__Tree<U32>'
    MP = 'Maybe<&2, +List<S.Part>>'
    REP = 'S.Repeat{Spec.Schema58()}'
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    TGT = f'Some{{[S.Variable{{{WBL}}}]}}'
    GOAL = f'{{CHKw(t, x, off, len) == {TRUE}}}'
    ABS = f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))'
    V = lambda j: f'VCK(t, {POS(j)})'
    BY = 'List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps))'
    EQ = f'U32.is_eq(len, (U32.div(len, {RS}) * {RS} : U32))'
    w = [TEMPLATES.render('top_inv_text', TR=TR, V=V, BY=BY, REP=REP, MP=MP, TGT=TGT, GOAL=GOAL, ABS=ABS, WBL=WBL, EQ=EQ)]
    body = ['# Every value whose spec parts are the window\'s bytes passes the checks.',
            f'def invw({CW}, +v: S.Value, +e: {{Codec.parts(v, {LSCH}) == {TGT} : {MP}}}) -> {GOAL}:', '  match v:']
    for v in VALUES:
        nm = v.split('{')[0]
        if nm == 'Sequence':
            body.append(f'    case S.Sequence{{+its}}: ib({CWA}, its, Nat.is_le(Codec.count(its), {LIMN}), e)')
        else:
            body.append(f'    case S.{v}: {ABS}')
    w.append('\n'.join(body) + '\n')
    return '\n'.join(w)


HEAD_EXTRA = ['import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', 'import ./vua.bend as UA', 'import ../compact/reads.bend as RD',
              'import ./vrl.bend as VRL', 'import ./vmv.bend as VMV', 'import ./vua_lay.bend as LY', 'import ./vmr.bend as VMR', 'import ./vu40.bend as V40',
              'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF']


def module_text():
    RX, rec = record_text()
    L = W.HEADX + HEAD_EXTRA + ['', '# GENERATED by validator_list_window (codegen). Do not edit.',
                                '# List[Validator, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return v_deep('\n'.join(L) + W.COMMONX + '\n' + rec + '\n' + list_check_text() + reader_text() + spec_text() + list_spec_text() + rinv_text() + linv_text() + top_inv_text())


def _cut(text, name):
    a = text.index(f'\ndef {name}(') + 1
    b = text.index('\n\n', a)
    return text[:a] + text[b + 2:]


def v_deep(text):
    """The Validator list's window at any depth d < 31 (record_list_offset_windows.deep_rlist's pattern, hw32): the check and read
    loops carry the records' end below 2^32 (hb32: VRL.posU32 / succU32), the record reads by vua_fix rdxd_ and
    UR.offx31, the record storage depth from the window's records (records of 121 >= 4 bytes: at most 2^d),
    the old interface as wrappers."""
    T = 'True{} : Bool'
    P32 = 'FD.spec_common__pow2(32n)'
    PW = 'A.quad(VB.pw(d))'
    POS = lambda j: f'VRL.pos({j}, {RS}n, x)'
    HB = f"+hb: {{Nat.is_le({POS('Nat.add(1n+k, j)')}, {PW}) == {T}}}"
    HB32 = f"+hb32: {{Nat.is_lt({POS('Nat.add(1n+k, j)')}, {P32}) == {T}}}"
    HX = f"      +hx = VRL.nextfit(j, q, {RS}n, x, {PW}, hb)\n"
    HX32 = (HX + f"      +hx32 = FD.nat__le_lt_trans(Nat.add({POS('1n+j')}, {RS}n), {POS('Nat.add(2n+q, j)')}, {P32},\n"
            f"        VRL.nextfit(j, q, {RS}n, x, {POS('Nat.add(2n+q, j)')}, FD.nat__le_refl({POS('Nat.add(2n+q, j)')})), hb32)\n"
            f"      +hb232 = FD.logic__subst(Nat, z => {{Nat.is_lt(VRL.pos(1n+z, {RS}n, x), {P32}) == {T}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb32)\n")
    reps = [
        (HB + ',\n', HB + ', ' + HB32 + ',\n', 1),
        (HB + ')\n', HB + ', ' + HB32 + ')\n', 1),
        (HX, HX32, 2),
        (f"      +ex = VRL.posU(d, off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hd, hx)", f"      +ex = VRL.posU32(off, x, i, j, {RS}, {RS - 1}n, {{==}}, eo, ej, hx32)", 2),
        (f"VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2)", f"VRL.succU32(i, j, {RS - 1}n, x, ej, hx32), hd, pf, hb2, hb232)", 1),
        (f"VRL.succU(d, i, j, {RS - 1}n, x, ej, hd, hx), hd, pf, hb2, hdd, hk2,", f"VRL.succU32(i, j, {RS - 1}n, x, ej, hx32), hd, pf, hb2, hb232, hdd, hk2,", 1),
        ("eo, {==}, hd, pf, hb, hdd, hk,", "eo, {==}, hd, pf, hb, hb32, hdd, hk,", 1),
        ("eo, {==}, hd, pf, hb)", "eo, {==}, hd, pf, hb, hb32)", 1),
        ("      +hb = hbw(d, t, n, x, off, len, eo, hd, hw, pf, h, ee)\n",
         "      +hb = hbw(d, t, n, x, off, len, eo, hd, hw, pf, h, ee)\n      +hb32 = hbw32(d, t, n, x, off, len, eo, hd, hw, pf, h, ee)\n", 1),
        ("FD.nat__lt_trans(d, 28n, 32n, hd, {==})", "FD.nat__lt_trans(d, 31n, 32n, hd, {==})", 1),
        ("UR.offx(d, off, c, y, e, FD.nat__lt_trans(d, 28n, 30n, hd, {==}),", "UR.offx31(d, off, c, y, e, hd,", 1),
        ("VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))", "VFT.fits4lt(U32.to_nat(len), VB.u32_lt(len))", 1),
        ("      +hck = hcK(d, t, n, x, off, len, eo, hd, hw, pf, hchk)\n      +hcp = VD.wd_cover(NN(len), 29n, {==}, hck)\n",
         TEMPLATES.render('v_deep', P32=P32, T=T, POS=POS), 1),
        ("      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), 29n, 32n, VD.wd_min(NN(len), 29n, hck), {==})\n",
         "      +hdd = FD.nat__le_lt_trans(B.words_depth(NN(len)), d, 32n, VD.wd_min(NN(len), d, hcN), FD.nat__lt_trans(d, 31n, 32n, hd, {==}))\n", 1),
    ]
    for a, b, n in reps:
        assert text.count(a) == n, (text.count(a), n, a[:100])
        text = text.replace(a, b)
    text = re.sub(r'VTX\.rdx_(\w+)\(', r'VTX.rdxd_\1(', text).replace('FD.nat__lt_trans(d, 28n, 30n, hd, {==}), pf,', 'hd, pf,')
    text = _cut(text, 'hcK')
    # hbw32: the last record's end below 2^32
    a = text.index('\ndef hbw(') + 1
    b = text.index('\n\n', a)
    h = text[a:b]
    from codegen.proofs.support import deep_window_decode_passes as deep
    pe = deep._close(h, h.index('(') + 1)
    body = h[pe:]
    for x_, y_ in [(f"Nat.is_le(VRL.pos(Nat.add(1n+KK(len), 0n), {RS}n, x), {PW})", f"Nat.is_lt(VRL.pos(Nat.add(1n+KK(len), 0n), {RS}n, x), {P32})"),
                   (f"{{Nat.is_le(z, {PW}) == {T}}}", f"{{Nat.is_lt(z, {P32}) == {T}}}"),
                   (f"{{Nat.is_le(Nat.add(z, x), {PW}) == {T}}}", f"{{Nat.is_lt(Nat.add(z, x), {P32}) == {T}}}"),
                   (f"{{Nat.is_le(VRL.pos(z, {RS}n, x), {PW}) == {T}}}", f"{{Nat.is_lt(VRL.pos(z, {RS}n, x), {P32}) == {T}}}"),
                   ('FD.nat__add_comm(x, U32.to_nat(len)), hw)', 'FD.nat__add_comm(x, U32.to_nat(len)), hw32)')]:
        assert x_ in body, x_[:80]
        body = body.replace(x_, y_)
    assert PW not in body, body
    text = text[:b] + '\n\n' + h[:pe].replace('def hbw(', 'def hbw32(') + body + text[b:]
    left = [l for l in text.split('\n') if re.search(r'lt_trans\(d, 28n|\.rdx_\w+\(|VFT\.fits4\(|posU\(|succU\(|UR\.offx\(|29n', l)]
    assert not left, left[:3]
    return W.deep_x(text)


def main():
    out = {ROOT / 'proofs/obj' / OUT: module_text()}
    from codegen.impl import runtime_file_split as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale: ', 'validator list window is current')
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
