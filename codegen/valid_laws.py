#!/usr/bin/env python3
"""Structural validity of the root views (spec/value_domain.bend root_valid).

END_TO_END's root semantics (root_for_legal_type) asks for
Domain.root_valid(VAL(o), Spec.X()) == True for the view VAL(o) = v_X(o) that
each root law uses. codegen/root_laws.py emit_valid proves it for the Fulu
phase-A shapes (proofs/obj/valid_names.bend). This generator proves it for the
other root views, one lemma per shape, under the root law's own hypotheses,

  rv_<p>(+o[, +rp: RN.rp_<p>(o)]) : {VD.root_valid(RN.v_<p>(o), <schema>) == True{} : Bool}

and per name, at its specification schema,

  <Name>_root_valid(+o[, +rp]) : {VD.root_valid(RN.v_<p>(o), Spec.<Name>()) == True{} : Bool}

(the hypotheses are the root law's: its `for +rp: ...` binders, same names/types).

Type-kind containers (phase B, root_types.bend): per shape
  vr_<p>(-o, +s, +rep: RT.rep_<p>(o, s), +dv, +edv, +ok: {RT.ok_<p>(s, dv) == True}, +ev: RT.eqs_<p>(s))
    : {VD.root_valid(RT.v_<p>(o), s) == True{} : Bool}
and per name <Name>_root_valid(-o, +s, +es: {s == Spec.<Name>()}, +rep: RT.rep_<p>(o, s)).
Libraries (hand-written): valid_obj.bend (byte/bit/uint64/Bytes32 storage fields), valid_obj2.bend
(Bytes48 and cell elements).

Outputs (named gvalid_* so codegen/e2e_bridge.py's valid_*.bend index does not pick
them up before it handles the generic object API, types/generic_obj.bend):
  proofs/obj/gvalid_gnames.bend the generic phase-A shapes and names (root_gnames.bend)

Library (hand-written): proofs/obj/valid_lib.bend (the uint domains of the one-word
leaves from their representation facts).

    python3 codegen/valid_laws.py [--check]
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import root_laws as RA  # noqa: E402
import root_laws_generic as RG  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OBJ = ROOT / 'proofs/obj'


def vneeds_rp(s):
    """The shape's validity needs a representation fact (uint8/16 fields)."""
    if s.kind in ('u8', 'u16'):
        return True
    if s.kind == 'container':
        return any(vneeds_rp(fs) for _, fs in s.fields)
    return False


def rp_names(s, xs, root='rp'):
    """Destructure lines for the rp chain of a container (as root_laws rs_), and
    the fact names per field index (only of fields whose rp_ is part of it)."""
    reps = [i for i, (_, fs) in enumerate(s.fields) if RA.needs_rep(fs)]
    lines, names, cur = [], {}, root
    for j, i in enumerate(reps):
        if j == len(reps) - 1:
            names[i] = cur
        else:
            lines.append(f'(+r{i}, +k{i}) = {cur}')
            names[i] = f'r{i}'
            cur = f'k{i}'
    return lines, names


def valid_shape(s, w, RN):
    p, k, t = s.p, s.kind, s.t
    R = RA.qual(s.rep)
    E = RA.spec_schema(s)
    rp = vneeds_rp(s)
    head = f'def rv_{p}(+o: {R}' + (f', +rp: {RN}.rp_{p}(o)' if rp else '') + f') -> {{VD.root_valid({RN}.v_{p}(o), {E}) == True{{}} : Bool}}:'
    Z7 = ', '.join(['0'] * 7)
    if k == 'bool':
        w(head + ' {==}')
    elif k == 'u8':
        w(head + ' VL.u8dom(o, rp)')
    elif k == 'u16':
        w(head + ' VL.u16dom(o, rp)')
    elif k == 'u32':
        w(head + ' VL.u32dom(o)')
    elif k == 'u64':
        w(head)
        w('  match o:')
        w('    case O.U64{+lo, +hi}: {==}')
    elif k == 'uwide':
        ws = [f'w{i}' for i in range(s.nw)]
        w(head)
        w('  match o:')
        w(f'    case {RA.pattern(R, ws)}: {{==}}')
    elif k == 'rec' and t.kind == 'bytes':
        w(head + f' {RN}.domain_{p}(o)')
    elif k == 'rec' and t.kind == 'bits' and RA.partial_bits(s):
        nb, nw = t.size, s.nw
        ws = [f'w{i}' for i in range(nw)]
        WL = '[' + ', '.join(ws) + ']'
        wargs = ', '.join(f'+{x}: U32' for x in ws)
        BITS = f'BLP.btk({nb}n, BLP.bitsof({WL}))'
        w(f'def vlh_{p}({wargs}) -> {{Nat.is_le({nb}n, List.length(&2, Bool, BLP.bitsof({WL}))) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(Nat, List.length(&2, Bool, BLP.bitsof({WL})), {RN}.pbl32({WL}), {RN}.plen_bitsof({WL})) :')
        w(f'    {{Nat.is_le({nb}n, _) == True{{}} : Bool}}')
        w('  {==}')
        w(head)
        w('  match o:')
        w(f'    case {RA.pattern(R, ws)}:')
        w(f'      %Equal.sym(Nat, List.length(&2, Bool, {BITS}), {nb}n, {RN}.pbtk_len({nb}n, BLP.bitsof({WL}), vlh_{p}({", ".join(ws)}))) :')
        w(f'        {{Bool.and(Nat.is_lt(0n, {nb}n), Nat.is_eq(_, {nb}n)) == True{{}} : Bool}}')
        w('      {==}')
    elif k == 'rec' and t.kind == 'bits':
        w(head)
        w(f'  %Equal.sym(Nat, List.length(&2, Bool, {RN}.bits_{p}(o)), {t.size}n, {RN}.blen_{p}(o)) :')
        w(f'    {{Bool.and(Nat.is_lt(0n, {t.size}n), Nat.is_eq(_, {t.size}n)) == True{{}} : Bool}}')
        w('  {==}')
    elif k == 'container':
        F_ = s.fields
        n = len(F_)
        xs = [f'x{i}' for i in range(n)]
        w(head)
        w('  match o:')
        w(f'    case {RA.pattern(R, xs)}:')
        rpn = {}
        if rp:
            lines, rpn = rp_names(s, xs)
            for ln in lines:
                w('      ' + ln)

        def rest(i):
            items = 'S.EmptyItems{}'
            chain = 'S.End{}'
            for j in range(n - 1, i - 1, -1):
                items = f'S.Items{{{RN}.v_{F_[j][1].p}({xs[j]}), {items}}}'
                chain = f'S.Chain{{{RA.spec_schema(F_[j][1])}, {chain}}}'
            return f'VD.root_valid({items}, {chain})'
        for i, (f, fs) in enumerate(F_):
            ctx = f'Bool.and(_, {rest(i + 1)})'
            for _ in range(i):
                ctx = f'Bool.and(True{{}}, {ctx})'
            Ei = RA.spec_schema(fs)
            arg = f'{xs[i]}, {rpn[i]}' if vneeds_rp(fs) else xs[i]
            w(f'      %Equal.sym(Bool, VD.root_valid({RN}.v_{fs.p}({xs[i]}), {Ei}), True{{}}, rv_{fs.p}({arg})) :')
            w(f'        {{{ctx} == True{{}} : Bool}}')
        w('      {==}')
    else:
        raise RA.Skip(f'{p}: kind {k}')
    w('')


HEAD_G = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/generic_obj.bend as T',
          'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
          'import ../../spec/value_domain.bend as VD', 'import ./generic_specs.bend as Spec',
          'import ./bitlist_pack.bend as BLP', 'import ./valid_lib.bend as VL', 'import ./root_gnames.bend as RN', '',
          '# GENERATED by codegen/valid_laws.py. Do not edit.',
          '# The generic phase-A root views are structurally valid (spec/value_domain.bend',
          '# root_valid), under the root laws\' own representation facts (rp_<p>).', '']


def emit_gnames():
    names = RG.generic_names()
    RA.PARTIAL_OK = RG.container_partial_bits(names)
    RA.PARTIAL_HOOK = RG.partial_bits_shape
    RA.EXTRA_LEAVES = True
    try:
        g = G.Gen()
        for n, t in names.items():
            g.shape(t)
        good = []
        for s in g.order:
            if s.kind == 'box':
                continue
            try:
                RA.covered(s)
                RA.spec_schema(s)
                good.append(s)
            except RA.Skip:
                pass
        L = list(HEAD_G)
        for s in good:
            valid_shape(s, L.append, 'RN')
        gp = {s.p for s in good}
        law_src = (OBJ / 'root_gnames.bend').read_text()
        for n, t in names.items():
            s = g.shape(t)
            if s.p not in gp or RA.partial_bits(s) or f'law {n}_root_correct:' not in law_src:
                continue
            rp = vneeds_rp(s)
            R = RA.qual(s.rep)
            L.append(f'def {n}_root_valid(+o: {R}' + (f', +rp: RN.rp_{s.p}(o)' if rp else '')
                     + f') -> {{VD.root_valid(RN.v_{s.p}(o), Spec.{n}()) == True{{}} : Bool}}: rv_{s.p}(o' + (', rp)' if rp else ')'))
        return '\n'.join(L) + '\n'
    finally:
        RA.EXTRA_LEAVES = False


LEAF_HEAD = ['import Base', 'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
             'import ../../types/primitive.bend as P', 'import ../../spec/value_domain.bend as VD',
             'import ../../spec/fulu_schemas.bend as Spec', 'import ./generic_specs.bend as GSpec',
             'import ./valid_lib.bend as VL', 'import ./leaf_small.bend as LS', '',
             '# GENERATED by codegen/valid_laws.py. Do not edit.',
             '# The one-word leaf views (leaf_small.bend, gleaf.bend: the view is the value itself)',
             '# are structurally valid under their root laws\' facts (e: the value is below 2^8 / 2^16).', '']


def emit_leaves():
    Z7 = ', '.join(['0'] * 7)
    V = f'S.UnsignedValue{{P.UInt{{o, {Z7}}}}}'
    L = list(LEAF_HEAD)
    w = L.append
    for n, sp, dom, e in (('uint8', 'Spec', 'u8dom', '256'), ('ParticipationFlags', 'Spec', 'u8dom', '256'), ('uint32', 'Spec', 'u32dom', None),
                          ('Gt967E8D815F', 'GSpec', 'u8dom', '256'), ('GtECF9BB18D8', 'GSpec', 'u16dom', '65536'), ('Gt7B8507E2C2', 'GSpec', 'u32dom', None)):
        hyp = f', +e: {{U32.is_lt(o, {e}) == True{{}} : Bool}}' if e else ''
        w(f'def {n}_root_valid(+o: U32{hyp}) -> {{VD.root_valid({V}, {sp}.{n}()) == True{{}} : Bool}}: VL.{dom}(o' + (', e)' if e else ')'))
    w('def Bytes1_root_valid(+o: T.Bytes1, +e: {U32.is_lt(LS.b1_byte(o), 256) == True{} : Bool}) -> {VD.root_valid(S.BytesValue{[LS.b1_byte(o)]}, Spec.Bytes1()) == True{} : Bool}:')
    w('  %Equal.sym(Bool, U32.is_lt(LS.b1_byte(o), 256), True{}, e) : {Bool.and(_, True{}) == True{} : Bool}')
    w('  {==}')
    return '\n'.join(L) + '\n'


def emit_gbits():
    names = RG.generic_names()
    g = G.Gen()
    files = {}
    for n, t in names.items():
        if not (t.kind == 'bits' and t.size % 32):
            continue
        s = g.shape(t)
        if s.kind != 'rec':
            continue
        depth = G.log2ceil(G.chunks_of(4 * s.nw))
        mod = 'gbits_small.bend' if depth == 0 else f'gbits_{n}.bend'
        L = files.setdefault(mod, [])
        R = RA.qual(s.rep)
        ws = [f'w{i}' for i in range(s.nw)]
        WL = '[' + ', '.join(ws) + ']'
        L.append(f'def vlh_{n}(' + ', '.join(f'+{x}: U32' for x in ws) + f') -> {{Nat.is_le({t.size}n, List.length(&2, Bool, BLP.bitsof({WL}))) == True{{}} : Bool}}:')
        L.append(f'  %Equal.sym(Nat, List.length(&2, Bool, BLP.bitsof({WL})), GB.bl32({WL}), GB.len_bitsof({WL})) :')
        L.append(f'    {{Nat.is_le({t.size}n, _) == True{{}} : Bool}}')
        L.append('  {==}')
        L.append(f'def {n}_root_valid(+o: {R}) -> {{VD.root_valid(S.BitsValue{{GB.{n}_bits(o)}}, Spec.{n}()) == True{{}} : Bool}}:')
        L.append('  match o:')
        L.append(f'    case {RA.pattern(R, ws)}:')
        BITS = f'BLP.btk({t.size}n, BLP.bitsof({WL}))'
        L.append(f'      %Equal.sym(Nat, List.length(&2, Bool, {BITS}), {t.size}n, GB.btk_len({t.size}n, BLP.bitsof({WL}), vlh_{n}({", ".join(ws)}))) :')
        L.append(f'        {{Bool.and(Nat.is_lt(0n, {t.size}n), Nat.is_eq(_, {t.size}n)) == True{{}} : Bool}}')
        L.append('      {==}')
        L.append('')
    outs = {}
    for mod, body in files.items():
        head = ['import Base', 'import ../../types/generic_obj.bend as T', 'import ../../types/schema.bend as S',
                'import ../../spec/value_domain.bend as VD', 'import ./generic_specs.bend as Spec',
                'import ./bitlist_pack.bend as BLP', f'import ./{mod} as GB', '',
                '# GENERATED by codegen/valid_laws.py. Do not edit.',
                f'# The partial-word bit vector views of {mod} are structurally valid: the view is',
                '# the first n bits of the words, and the words hold at least n bits.', '']
        outs[OBJ / ('gvalid_' + mod)] = '\n'.join(head + body) + '\n'
    return outs


WORDS_HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/schema.bend as S',
              'import ../../spec/value_domain.bend as VD', 'import ../../spec/primitives.bend as SP',
              'import ../../spec/fulu_schemas.bend as Spec', 'import ../compact/found.bend as F',
              'import ./spec_fixed.bend as FX', 'import ./words_spec.bend as WS', 'import ./words_root.bend as WR', '',
              '# GENERATED by codegen/valid_laws.py. Do not edit.',
              '# The byte-storage root views of root_words.bend (vectors of Bytes32: WR.items; byte',
              '# vectors: WR.view) are structurally valid, under the root laws\' own hypotheses.', '',
              '# Every item of a vector of Bytes32 is 32 bytes below 256.',
              'law items_valid:', '  for +k: Nat', '  for +W: List<&2, U32>', '  for +i: Nat',
              '  {VD.root_valid(WR.items(k, W, i), S.Repeat{S.ByteVector{32n}}) == True{} : Bool}',
              'def items_valid(k, W, i):', '  match k:', '    case 0n: {==}', '    case 1n+ +q:',
              '      %Equal.sym(Bool, SP.byte_scope(32n, WS.cb(W, i)), True{}, WS.scope_cb(W, i)) :',
              '        {Bool.and(_, VD.root_valid(WR.items(q, W, 1n+i), S.Repeat{S.ByteVector{32n}})) == True{} : Bool}',
              '      items_valid(q, W, 1n+i)', '',
              '# The first N = 32q + r bytes of the words are N bytes below 256.',
              'def bv_valid(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,',
              '    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},',
              '    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},',
              '    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},',
              '    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool})',
              '    -> {VD.root_valid(S.BytesValue{WR.view(t, N)}, S.ByteVector{U32.to_nat(N)}) == True{} : Bool}:',
              '  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :',
              '    {VD.bytevector_domain(_, WS.btake(_, FX.limbs(F.array__slots(U32, t)))) == True{} : Bool}',
              '  %Equal.sym(Bool, VD.bytevector_domain(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), SP.byte_scope(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))),',
              '      WR.dom_pos(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), WR.pos_add(WS.e32(q), r, h1))) :',
              '    {_ == True{} : Bool}',
              '  WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR.cap_at(q, dw, t, pf, cap))', '']


def emit_words():
    import re
    src = (OBJ / 'root_words.bend').read_text()
    L = list(WORDS_HEAD)
    w = L.append
    for m in re.finditer(r'^law (\w+)_root_correct:\n((?:  for .*\n)+)  (RR\.roots\(.*)\ndef \w+\((.*)\):\n  (.*)$', src, re.M):
        n, binders, stmt, _args, body = m.groups()
        bs = [b.strip()[len('for '):] for b in binders.strip('\n').split('\n')]
        bs = [b for b in bs if not b.startswith('-h')]
        view = re.match(r'RR\.roots\((S\.\w+\{.*?\}), Spec\.', stmt).group(1)
        head = f'def {n}_root_valid(' + ', '.join(bs) + f') -> {{VD.root_valid({view}, Spec.{n}()) == True{{}} : Bool}}:'
        if view.startswith('S.Sequence{WR.items('):
            k = re.match(r'S\.Sequence\{WR\.items\((\d+)n, ', view).group(1)
            w(head)
            w(f'  %Equal.sym(Bool, VD.root_valid(WR.items({k}n, F.array__slots(U32, t), 0n), S.Repeat{{S.ByteVector{{32n}}}}), True{{}}, items_valid({k}n, F.array__slots(U32, t), 0n)) :')
            w(f'    {{Bool.and(Bool.and(Nat.is_lt(0n, {k}n), Nat.is_eq(VD.items_length(WR.items({k}n, F.array__slots(U32, t), 0n)), {k}n)), _) == True{{}} : Bool}}')
            w('  {==}')
        else:
            a = [x.strip() for x in re.match(r'WR\.bv_full\((.*)\)$', body).group(1).split(',')]
            N, q, r = a[4], a[6], a[7]
            w(head)
            w(f'  bv_valid({N}, {q}, {r}, dw, t, {{==}}, {{==}}, {{==}}, pf, cap)')
        w('')
    return '\n'.join(L) + '\n'


# ---- phase B: Type-kind containers (root_types.bend / root_gtypes*.bend) --------

class VB:
    """The validity lemmas of the Type-kind shapes of a phase-B generator run
    (codegen/root_laws_b.py Gen, after run(): meta, okinfo, done)."""

    VOBJ = {'bits': 'VO.vbits', 'bv': 'VO.vbv', 'bl': 'VO.vbl', 'pv': 'VO.vpv', 'ul': 'VO.vul'}

    def __init__(self, gen, RT, VN, generic):
        self.gen, self.RT, self.VN, self.generic = gen, RT, VN, generic
        self.done = set()
        self.out = []
        self.todo = {}

    def fvalid(self, fs, k, x, sx, r, okp, eqp):
        """A proof of {VD.root_valid(view, sx) == True} of field x (kind k)."""
        g, RT, VN = self.gen, self.RT, self.VN
        if k == 'data':
            return f'VO.vtrans({RN_view(g, fs, k, x, RT)}, {sx}, {g.E(fs)}, {eqp}, {VN}.rv_{fs.p}({x}))'
        if k == 'datar':
            return f'VO.vtrans({RN_view(g, fs, k, x, RT)}, {sx}, {g.E(fs)}, {eqp}, {VN}.rv_{fs.p}({x}, {r}))'
        if k in self.VOBJ:
            return f'{self.VOBJ[k]}({x}, {sx}, {g.dd(fs, k)}, {r}, {okp})'
        if k == 'boxD':
            self.box(fs, k)
            return f'vr_{fs.p}({x}, {sx}, {r}, {eqp})'
        if k in ('boxT', 'T'):
            if k == 'boxT':
                self.box(fs, k)
            else:
                self.shape(fs)
            return f'vr_{fs.p}({x}, {sx}, {r}, dv, edv, {okp}, {eqp})'
        if k == 'ev':
            d = g.depth(fs, k)
            if d == 0 or d >= RBmod().BIGD:
                raise RA.Skip(f'{fs.p}: vector of Bytes48 of depth {d}: no validity law yet')
            return f'VO2.vev({x}, {sx}, {d - 1}n, {r}, {okp})'
        if k in ('el', 'cl'):
            return f'VO2.v{k}({x}, {sx}, {g.dd(fs, k)}, {r}, {okp})'
        if k == 'xl':
            self.xlist(fs)
            big = g.depth(fs, k) >= RBmod().BIGD
            return f'vr_{fs.p}({x}, {sx}, {r}' + (', dv, edv' if big else '') + f', {okp}, {eqp})'
        raise RA.Skip(f'{fs.p}: no validity for field kind {k} yet')

    def xlist(self, fs):
        """A list of Data-kind containers (root_laws_b xlist_laws)."""
        if fs.p in self.done:
            return
        if fs.t.kind != 'list':
            raise RA.Skip(f'{fs.p}: vector of containers validity not yet')
        self.done.add(fs.p)
        g, RT, VN = self.gen, self.RT, self.VN
        p = fs.p
        X = fs.pelem
        RX = RA.qual(X.rep)
        EX = RA.spec_schema(X)
        erp = RA.needs_rep(X)
        D_ = g.depth(fs, 'xl')
        big = D_ >= RBmod().BIGD
        Seq = f'T.{p}_Seq'
        L = []
        w = L.append
        w(f'# ---- {p}: list of {X.p} ----')
        w(f'law vxlen_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        w(f'  {{VD.items_length({RT}.xi_{p}(k, W, i)) == k : Nat}}')
        w(f'def vxlen_{p}(k, W, i):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w(f'      %Equal.sym(Nat, VD.items_length({RT}.xi_{p}(q, W, 1n+i)), q, vxlen_{p}(q, W, 1n+i)) : {{1n+_ == 1n+q : Nat}}')
        w('      {==}')
        w(f'law vxval_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {RX}>')
        w('  for +i: Nat')
        if erp:
            w(f'  for +er: {RT}.ereps_{p}(k, W, i)')
        w(f'  {{VD.root_valid({RT}.xi_{p}(k, W, i), S.Repeat{{{EX}}}) == True{{}} : Bool}}')
        w(f'def vxval_{p}(k, W, i' + (', er' if erp else '') + '):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        if erp:
            w('      (+r0, +rs) = er')
        xa = f'{RT}.xat_{p}(W, i)'
        w(f'      %Equal.sym(Bool, VD.root_valid(RN.v_{X.p}({xa}), {EX}), True{{}}, {VN}.rv_{X.p}({xa}' + (', r0)' if erp else ')') + ') :')
        w(f'        {{Bool.and(_, VD.root_valid({RT}.xi_{p}(q, W, 1n+i), S.Repeat{{{EX}}})) == True{{}} : Bool}}')
        w(f'      vxval_{p}(q, W, 1n+i' + (', rs)' if erp else ')'))
        dvp = ', +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}' if big else ''
        dva = ', dv' if big else ''
        DD = f'OS.dv_{D_}(dv)' if big else f'{D_}n'
        w(f'def vr_{p}(-o: {Seq}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s){dvp}, +ok: {{{RT}.ok_{p}(s{dva}) == True{{}} : Bool}}, +eq: {{SH.ListOf_element(s) == {EX} : S.Schema}})')
        w(f'    -> {{VD.root_valid({RT}.xv_{p}(o), s) == True{{}} : Bool}}:')
        w('  (+wf, +hv) = rep')
        w('  (+t, w1) = wf')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        if erp:
            w('  (+hd, w6) = w5')
            w('  (+hn, +er) = w6')
        else:
            w('  (+hd, +hn) = w5')
        Lm = 'SH.ListOf_limit(s)'
        Ts = f'F.array__thaw({RX}, t)'
        W = f'F.array__slots({RX}, t)'
        nN = 'U32.to_nat(N)'
        XI = f'{RT}.xi_{p}({nN}, {W}, 0n)'
        w(f'  +k0 = DK.and_l(SH.is_ListOf(s), Lim.minimal({Lm}, {DD}), ok)')
        w(f'  +hvN = {RT}.xhv_{p}(o, t, N, {Lm}, eo, hv)')
        w(f'  %Equal.sym(S.Schema, s, S.ListOf{{SH.ListOf_element(s), {Lm}}}, SH.ListOf_shape(s, k0)) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(o), _) == True{{}} : Bool}}')
        w(f'  %Equal.sym(S.Schema, SH.ListOf_element(s), {EX}, eq) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(o), S.ListOf{{_, {Lm}}}) == True{{}} : Bool}}')
        w(f'  %Equal.sym({Seq}, o, {Seq}{{{Ts}, N}}, eo) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(_), S.ListOf{{{EX}, {Lm}}}) == True{{}} : Bool}}')
        w(f'  %Equal.sym(F.array__Tree<{RX}>, F.array__freeze({RX}, {Ts}), t, F.array__freeze_thaw({RX}, t)) :')
        w(f'    {{VD.root_valid(S.Sequence{{{RT}.xi_{p}({nN}, F.array__slots({RX}, _), 0n)}}, S.ListOf{{{EX}, {Lm}}}) == True{{}} : Bool}}')
        w(f'  %Equal.sym(Bool, VD.root_valid({XI}, S.Repeat{{{EX}}}), True{{}}, vxval_{p}({nN}, {W}, 0n' + (', er)' if erp else ')') + ') :')
        w(f'    {{Bool.and(Nat.is_le(VD.items_length({XI}), {Lm}), _) == True{{}} : Bool}}')
        w(f'  %Equal.sym(Nat, VD.items_length({XI}), {nN}, vxlen_{p}({nN}, {W}, 0n)) :')
        w(f'    {{Bool.and(Nat.is_le(_, {Lm}), True{{}}) == True{{}} : Bool}}')
        w(f'  %Equal.sym(Bool, Nat.is_le({nN}, {Lm}), True{{}}, hvN) : {{Bool.and(_, True{{}}) == True{{}} : Bool}}')
        w('  {==}')
        w('')
        self.out.extend(L)

    def box(self, fs, k):
        if fs.p in self.done:
            return
        self.done.add(fs.p)
        g, RT, VN = self.gen, self.RT, self.VN
        inner = fs.inner
        R = RA.qual(inner.rep)
        BR = f'O.Boxed<{R}>'
        p = fs.p
        L = []
        w = L.append
        if k == 'boxD':
            E = g.E(fs)
            w(f'def vr_{p}(-o: {BR}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s), +eq: {{s == {E} : S.Schema}}) -> {{VD.root_valid({RT}.v_{p}(o), s) == True{{}} : Bool}}:')
            w('  (+v, +eo) = rep')
            w(f'  %Equal.sym({BR}, o, O.BSome{{v, O.BNone{{}}}}, eo) : {{VD.root_valid({RT}.v_{p}(_), s) == True{{}} : Bool}}')
            w(f'  VO.vtrans(RN.v_{inner.p}(v), s, {E}, eq, {VN}.rv_{inner.p}(v))')
        else:
            self.shape(inner)
            v = f'{RT}.pjb_{p}(o)'
            B1 = f'O.BSome{{{v}, O.BNone{{}}}}'
            w(f'def vr_{p}(-o: {BR}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{{RT}.ok_{inner.p}(s, dv) == True{{}} : Bool}}, +eq: {RT}.eqs_{inner.p}(s))')
            w(f'    -> {{VD.root_valid({RT}.v_{p}(o), s) == True{{}} : Bool}}:')
            w('  (+eo, +ri) = rep')
            w(f'  %Equal.sym({BR}, o, {B1}, eo) : {{VD.root_valid({RT}.v_{p}(_), s) == True{{}} : Bool}}')
            w(f'  vr_{inner.p}({v}, s, ri, dv, edv, ok, eq)')
        w('')
        self.out.extend(L)

    def shape(self, s):
        if s.p in self.done:
            return
        self.done.add(s.p)
        g, RT = self.gen, self.RT
        p = s.p
        R = RA.qual(s.rep)
        m = g.meta[p]
        F, kinds, sx, cf = m['F'], m['kinds'], m['sx'], m.get('cf', 'SH.Container_fields')
        n = len(F)
        prog = s.t is not None and s.t.kind == 'pcontainer'
        if prog:
            raise RA.Skip(f'{p}: progressive container validity not yet')
        wide = n > G.GROUP
        groups = [list(range(j, min(n, j + G.GROUP))) for j in range(0, n, G.GROUP)] if wide else None
        xs = [f'x{i}' for i in range(n)]
        isdata = [k in ('data', 'datar') for k in kinds]
        args = [xs[i] if isdata[i] else f'{RT}.pj_{p}_{i}(o)' for i in range(n)]

        def obj(a):
            if not wide:
                return f'{R}{{' + ', '.join(a) + '}'
            return f'{R}{{' + ', '.join(f'T.{p}_g{j}{{' + ', '.join(a[i] for i in grp) + '}' for j, grp in enumerate(groups)) + '}'
        O_ = obj(args)
        reps = [g.rep(F[i][1], kinds[i], args[i], sx[i]) for i in range(n)]
        conj = [qual_rt(c, RT) for c in g.okinfo[p][1]]
        L = []
        w = L.append
        w(f'# ---- {p} ----')
        w(f'def vr_{p}(-o: {R}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{{RT}.ok_{p}(s, dv) == True{{}} : Bool}}, +ev: {RT}.eqs_{p}(s))')
        w(f'    -> {{VD.root_valid({RT}.v_{p}(o), s) == True{{}} : Bool}}:')
        # rep
        cur, c = 'rep', 0
        for i in range(n):
            if isdata[i]:
                w(f'  (+{xs[i]}, +q{c}) = {cur}')
                cur = f'q{c}'
                c += 1
        rs_ = [i for i in range(n) if reps[i]]
        rpn = {}
        if rs_:
            w(f'  (+eo, +q{c}) = {cur}')
            cur = f'q{c}'
            c += 1
            for j, i in enumerate(rs_):
                if j == len(rs_) - 1:
                    rpn[i] = cur
                else:
                    w(f'  (+rp{i}, +q{c}) = {cur}')
                    cur = f'q{c}'
                    c += 1
                    rpn[i] = f'rp{i}'
            eo = 'eo'
        else:
            eo = cur
        # eqs
        eqn = {}
        idx = m['eqt']
        cur = 'ev'
        for j, i in enumerate(idx):
            if j == len(idx) - 1:
                eqn[i] = cur
            else:
                w(f'  (+qe{i}, +qv{j}) = {cur}')
                cur = f'qv{j}'
                eqn[i] = f'qe{i}'
        # ok conjuncts
        mm = len(conj) - 1
        prev = 'ok'
        kname = {}
        for j in range(mm + 1):
            rest = fold_and(conj[j + 1:])
            if j < mm:
                w(f'  +k{j} = DK.and_l({conj[j]}, {rest}, {prev})')
                w(f'  +r{j + 1} = DK.and_r({conj[j]}, {rest}, {prev})')
                kname[j] = f'k{j}'
                prev = f'r{j + 1}'
        kname[mm] = prev
        okat = {}
        base = n + 2
        jj = base
        for i in range(n):
            if g.ok(F[i][1], kinds[i], sx[i]):
                okat[i] = kname[jj]
                jj += 1
        chain = 'S.End{}'
        for i in range(n - 1, -1, -1):
            chain = f'S.Chain{{{sx[i]}, {chain}}}'
        V0 = f'{RT}.v_{p}({O_})'
        w(f'  %Equal.sym({R}, o, {O_}, {eo}) : {{VD.root_valid({RT}.v_{p}(_), s) == True{{}} : Bool}}')
        w(f'  %Equal.sym(S.Schema, s, S.Container{{SH.Container_names(s), SH.Container_fields(s)}}, SH.Container_shape(s, {kname[0]})) :')
        w(f'    {{VD.root_valid({V0}, _) == True{{}} : Bool}}')
        w(f'  %Equal.sym(S.Schema, SH.Container_fields(s), {chain}, {RT}.fsh_{p}(s, dv, ok)) :')
        w(f'    {{VD.root_valid({V0}, S.Container{{SH.Container_names(s), _}}) == True{{}} : Bool}}')
        views = [g.view(F[i][1], kinds[i], args[i]) for i in range(n)]
        views = [qualify_view(v, RT) for v in views]

        def rest(i):
            items = 'S.EmptyItems{}'
            ch = 'S.End{}'
            for j in range(n - 1, i - 1, -1):
                items = f'S.Items{{{views[j]}, {items}}}'
                ch = f'S.Chain{{{sx[j]}, {ch}}}'
            return f'VD.root_valid({items}, {ch})'
        for i in range(n):
            ctx = f'Bool.and(_, {rest(i + 1)})'
            for _ in range(i):
                ctx = f'Bool.and(True{{}}, {ctx})'
            pf = self.fvalid(F[i][1], kinds[i], args[i], sx[i], rpn.get(i), okat.get(i), eqn.get(i))
            w(f'  %Equal.sym(Bool, VD.root_valid({views[i]}, {sx[i]}), True{{}}, {pf}) :')
            w(f'    {{{ctx} == True{{}} : Bool}}')
        w('  {==}')
        w('')
        self.out.extend(L)


def RBmod():
    import root_laws_b as RB
    return RB


def fold_and(cs):
    if not cs:
        return 'True{}'
    t = cs[-1]
    for c in reversed(cs[:-1]):
        t = f'Bool.and({c}, {t})'
    return t


def qual_rt(c, RT):
    import re
    return re.sub(r'(?<![\w.])(ok_|rep_|eqs_|okc_)', lambda m_: f'{RT}.{m_.group(1)}', c)


def qualify_view(v, RT):
    """A Gen.view term in this file's namespace (the root file's own defs under RT)."""
    import re
    return re.sub(r'(?<![\w.])(v_|xv_)', lambda m_: f'{RT}.{m_.group(1)}', v)


def RN_view(g, fs, k, x, RT):
    return qualify_view(g.view(fs, k, x), RT)


def types_head():
    import root_laws_b as RB
    return list(RB.HEAD) + ['import ../../spec/value_domain.bend as VD', 'import ./valid_names.bend as VN', 'import ./valid_obj.bend as VO',
                            'import ./valid_obj2.bend as VO2', 'import ./root_types.bend as RT', '',
                            '# GENERATED by codegen/valid_laws.py. Do not edit.',
                            '# The Type-kind root views of root_types.bend are structurally valid under the',
                            "# root laws' own hypotheses (rep_<p>(o, s), s == Spec.<Name>()).", '']


def emit_types(only=None):
    import root_laws_b as RB
    gen = RB.Gen()
    gen.run()
    vb = VB(gen, 'RT', 'VN', False)
    laws = []
    src = (OBJ / 'root_types.bend').read_text()
    status = {}
    for n, t in gen.names.items():
        if only and n not in only:
            continue
        s = gen.g.shape(t)
        if s.kind != 'container' or s.data or f'law {n}_root_correct:' not in src:
            continue
        saved = (list(vb.out), set(vb.done))
        try:
            vb.shape(s)
        except RA.Skip as e:
            vb.out, vb.done = saved
            status[n] = str(e)
            continue
        R = RA.qual(s.rep)
        laws.append(f'def {n}_root_valid(-o: {R}, +s: S.Schema, +es: {{s == Spec.{n}() : S.Schema}}, +rep: RT.rep_{s.p}(o, s))')
        laws.append(f'    -> {{VD.root_valid(RT.v_{s.p}(o), s) == True{{}} : Bool}}:')
        laws.append(f'  vr_{s.p}(o, s, rep, OS.DV0(), {{==}}, RT.{n}_ok(s, es, OS.DV0(), {{==}}), RT.{n}_eqs(s, es))')
        laws.append('')
        status[n] = 'valid'
    return '\n'.join(types_head() + vb.out + laws) + '\n', status


def main():
    outs = [(OBJ / 'gvalid_gnames.bend', emit_gnames()), (OBJ / 'gvalid_leaves.bend', emit_leaves()), (OBJ / 'gvalid_words.bend', emit_words()), (OBJ / 'gvalid_types.bend', emit_types()[0])] + sorted(emit_gbits().items())
    if '--check' in sys.argv:
        for path, text in outs:
            if not path.exists() or path.read_text() != text:
                sys.exit(f'{path.relative_to(ROOT)} is stale; run codegen/valid_laws.py')
        print('validity laws are current')
        return
    for path, text in outs:
        if not path.exists() or path.read_text() != text:
            path.write_text(text)


if __name__ == '__main__':
    main()
