#!/usr/bin/env python3
"""Structural validity of the root views (spec/value_domain.bend root_valid).

END_TO_END's root semantics (root_for_legal_type) asks for
Domain.root_valid(VAL(o), Spec.X()) == True for the view VAL(o) = v_X(o) that
each root law uses. codegen/proofs/laws/root_laws.py emit_valid proves it for the Fulu
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

Outputs (named gvalid_* so codegen/proofs/bridges/e2e_bridge.py's valid_*.bend index does not pick
them up before it handles the generic object API, types/generic_obj.bend):
  proofs/obj/gvalid_gnames.bend the generic phase-A shapes and names (root_gnames.bend)

Library (hand-written): proofs/obj/valid_lib.bend (the uint domains of the one-word
leaves from their representation facts).

    python3 codegen/proofs/laws/valid_laws.py [--check]
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import sys
from codegen.proofs.support.light_split import unlight as _unlight   # parse modules as before their light split (codegen/proofs/support/light_split.py)
from pathlib import Path

from codegen.impl import generate as G  # noqa: E402
from codegen.proofs.laws import root_laws as RA  # noqa: E402
from codegen.proofs.laws import root_laws_generic as RG  # noqa: E402

ROOT = Path(__file__).resolve().parents[3]
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
            arg = f'{xs[i]}, {rpn[i]}' if vneeds_rp(fs) else xs[i]  # noqa
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
          '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
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
        law_src = _unlight((OBJ / 'root_gnames.bend').read_text())
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
             '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
             '# The one-word leaf views (leaf_small.bend, gleaf.bend: the view is the value itself)',
             '# are structurally valid under their root laws\' facts (e: the value is below 2^8 / 2^16).', '']


def emit_leaves():
    Z7 = ', '.join(['0'] * 7)
    V = f'S.UnsignedValue{{P.UInt{{o, {Z7}}}}}'
    L = list(LEAF_HEAD)
    w = L.append
    for n, sp, dom, e in (('uint8', 'Spec', 'u8dom', '256'), ('ParticipationFlags', 'Spec', 'u8dom', '256'), ('uint32', 'Spec', 'u32dom', None),
                          ('uint16', 'GSpec', 'u16dom', '65536')):    # the other basic types are the fork's own
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
        k = t.size - 32 * (s.nw - 1)
        # the root law's binders (its fact e about the last word is not needed)
        e = f'{{GB.{n}_last(o) == U32{{WSp.join({k}n, {32 - k}n, WSp.take({k}n, 32n, PD.bits(GB.{n}_last(o))), Word.zero({32 - k}n))}} : U32}}'
        L.append(f'def {n}_root_valid(+o: {R}, +e: {e}) -> {{VD.root_valid(S.BitsValue{{GB.{n}_bits(o)}}, Spec.{n}()) == True{{}} : Bool}}:')
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
                'import ./bitlist_pack.bend as BLP', 'import ../../proofs/power_division.bend as PD',
                'import ../../proofs/word_split.bend as WSp', f'import ./{mod} as GB', '',
                '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
                f'# The partial-word bit vector views of {mod} are structurally valid: the view is',
                '# the first n bits of the words, and the words hold at least n bits.', '']
        outs[OBJ / ('gvalid_' + mod)] = '\n'.join(head + body) + '\n'
    return outs


WORDS_HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/schema.bend as S',
              'import ../../spec/value_domain.bend as VD', 'import ../../spec/primitives.bend as SP',
              'import ../../spec/fulu_schemas.bend as Spec', 'import ../compact/found.bend as F',
              'import ./spec_fixed.bend as FX', 'import ./words_spec.bend as WS', 'import ./words_root.bend as WR', '',
              '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
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
    src = _unlight((OBJ / 'root_words.bend').read_text())
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
    (codegen/proofs/laws/root_laws_b.py Gen, after run(): meta, okinfo, done)."""

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
            rr = f', {r}' if vneeds_rp(fs) else ''
            return f'VO.vtrans({RN_view(g, fs, k, x, RT)}, {sx}, {g.E(fs)}, {eqp}, {VN}.rv_{fs.p}({x}{rr}))'
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
        if k in ('l1', 'l2', 'lh'):
            return f'VP.vl{k[1]}({x}, {sx}, {g.dd(fs, k)}, {r}, {okp})'
        if k.startswith('vk'):
            return f'VP.vv{k[2:]}({x}, {sx}, {g.dd(fs, k)}, {r}, {okp})'
        if k == 'pk':
            return f'VP.vpl{g.pk(fs)[0]}({x}, {sx}, {r}, {okp})'
        if k == 'pb':
            self.extra('pb')
            return f'vpbits({x}, {sx}, {r}, {okp})'
        if k == 'bvb':
            self.extra('bvb')
            return f'vbvb({x}, {sx}, {fs.t.size}n, {g.depth(fs, k)}n, {r}, {okp})'
        if k in ('tl', 'ptl'):
            self.tlist(fs, 'plist' if k == 'ptl' else None)
            return f'vr_{fs.p}({x}, {sx}, {r}, dv, edv, {okp}, {eqp})'
        if k == 'xl':
            self.xlist(fs)
            big = g.depth(fs, k) >= RBmod().BIGD
            return f'vr_{fs.p}({x}, {sx}, {r}' + (', dv, edv' if big else '') + f', {okp}, {eqp})'
        if k == 'bvr':
            self.bvr(fs)
            return f'VO.vtrans({RN_view(g, fs, k, x, RT)}, {sx}, {g.E(fs)}, {eqp}, vbvr_{fs.p}({x}))'
        if k == 'px':
            self.xlist(fs, 'plist')
            return f'vr_{fs.p}({x}, {sx}, {r}, {okp}, {eqp})'
        raise RA.Skip(f'{fs.p}: no validity for field kind {k} yet')

    def xlist(self, fs, mode=None):
        """A list / vector / progressive list of Data-kind containers (root_laws_b
        xlist_laws, plist_x_laws)."""
        if fs.p in self.done:
            return
        mode = mode or ('vector' if fs.t.kind == 'vector' else 'list')
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
        acc = {'list': 'ListOf', 'vector': 'Vector', 'plist': 'ProgressiveList'}[mode]
        EL = f'SH.{acc}_element(s)'
        okarg = dva if mode != 'plist' else ''
        w(f'def vr_{p}(-o: {Seq}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s){dvp if mode != "plist" else ""}, +ok: {{{RT}.ok_{p}(s{okarg}) == True{{}} : Bool}}, +eq: {{{EL} == {EX} : S.Schema}})')
        w(f'    -> {{VD.root_valid({RT}.xv_{p}(o), s) == True{{}} : Bool}}:')
        if mode == 'plist':
            w('  (+t, w1) = rep')
        else:
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
        Ts = f'F.array__thaw({RX}, t)'
        W = f'F.array__slots({RX}, t)'
        nN = 'U32.to_nat(N)'
        XI = f'{RT}.xi_{p}({nN}, {W}, 0n)'
        VAL = f'vxval_{p}({nN}, {W}, 0n' + (', er)' if erp else ')')
        if mode == 'list':
            Lm = 'SH.ListOf_limit(s)'
            w(f'  +k0 = DK.and_l(SH.is_ListOf(s), Lim.minimal({Lm}, {DD}), ok)')
            w(f'  +hvN = {RT}.xhv_{p}(o, t, N, {Lm}, eo, hv)')
            SC = f'S.ListOf{{{EL}, {Lm}}}'
            SE = f'S.ListOf{{{EX}, {Lm}}}'
            shape = f'SH.ListOf_shape(s, k0)'
        elif mode == 'vector':
            if D_ == 0 or big:
                raise RA.Skip(f'{p}: vector of containers at depth {D_} not yet')
            Lm = 'SH.Vector_length(s)'
            w(f'  +k0 = DK.and_l(SH.is_Vector(s), Lim.minimal({Lm}, {DD}), ok)')
            w(f'  +km = DK.and_r(SH.is_Vector(s), Lim.minimal({Lm}, {DD}), ok)')
            w(f'  +eN = F.nat__eq_from_is_eq({nN}, {Lm}, {RT}.xhv_{p}(o, t, N, {Lm}, eo, hv))')
            w(f'  +kp = VO.lt0_rw({nN}, {Lm}, eN, VO.min_pos({Lm}, {D_ - 1}n, km))')
            SC = f'S.Vector{{{EL}, {Lm}}}'
            SE = f'S.Vector{{{EX}, {Lm}}}'
            shape = f'SH.Vector_shape(s, k0)'
        else:
            SC = f'S.ProgressiveList{{{EL}}}'
            SE = f'S.ProgressiveList{{{EX}}}'
            shape = 'SH.ProgressiveList_shape(s, ok)'
        w(f'  %Equal.sym(S.Schema, s, {SC}, {shape}) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(o), _) == True{{}} : Bool}}')
        w(f'  %Equal.sym(S.Schema, {EL}, {EX}, eq) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(o), {SC.replace(EL, "_")}) == True{{}} : Bool}}')
        if mode == 'vector':
            w(f'  %eN : {{VD.root_valid({RT}.xv_{p}(o), S.Vector{{{EX}, _}}) == True{{}} : Bool}}')
            SE = f'S.Vector{{{EX}, {nN}}}'
        w(f'  %Equal.sym({Seq}, o, {Seq}{{{Ts}, N}}, eo) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(_), {SE}) == True{{}} : Bool}}')
        w(f'  %Equal.sym(F.array__Tree<{RX}>, F.array__freeze({RX}, {Ts}), t, F.array__freeze_thaw({RX}, t)) :')
        w(f'    {{VD.root_valid(S.Sequence{{{RT}.xi_{p}({nN}, F.array__slots({RX}, _), 0n)}}, {SE}) == True{{}} : Bool}}')
        if mode == 'list':
            w(f'  %Equal.sym(Bool, VD.root_valid({XI}, S.Repeat{{{EX}}}), True{{}}, {VAL}) :')
            w(f'    {{Bool.and(Nat.is_le(VD.items_length({XI}), {Lm}), _) == True{{}} : Bool}}')
            w(f'  %Equal.sym(Nat, VD.items_length({XI}), {nN}, vxlen_{p}({nN}, {W}, 0n)) :')
            w(f'    {{Bool.and(Nat.is_le(_, {Lm}), True{{}}) == True{{}} : Bool}}')
            w(f'  %Equal.sym(Bool, Nat.is_le({nN}, {Lm}), True{{}}, hvN) : {{Bool.and(_, True{{}}) == True{{}} : Bool}}')
            w('  {==}')
        elif mode == 'vector':
            w(f'  VO.vfin({nN}, {XI}, {EX}, kp, vxlen_{p}({nN}, {W}, 0n), {VAL})')
        else:
            w(f'  {VAL}')
        w('')
        self.out.extend(L)

    EXTRA = {
        'pb': ['# A progressive bit list is any list of bits.',
               'def vpbits(-o: O.Bits, +s: S.Schema, +rep: PBO.rep_pbits(o, s), +ok: {PBO.ok_pbits(s) == True{} : Bool})',
               '    -> {VD.root_valid(S.BitsValue{BO.bview(o)}, s) == True{} : Bool}:',
               '  %Equal.sym(S.Schema, s, S.ProgressiveBits{}, SH.ProgressiveBits_shape(s, ok)) : {VD.root_valid(S.BitsValue{BO.bview(o)}, _) == True{} : Bool}',
               '  {==}', ''],
        'bvb': ['# A bit vector held as byte storage (wbits_obj rep_bvb / ok_bvb).',
                'def vbvb_len(+t: F.array__Tree<U32>, +N: U32, +n: Nat, +fc: WBV.fct2(t, N, n))',
                '    -> {List.length(&2, Bool, BLP.btk(n, BLP.bitsof(F.array__slots(U32, t)))) == n : Nat}:',
                '  (+hbc, +f1) = fc', '  (+hz, +f2) = f1', '  (+hln, +hcl) = f2', '  hln',
                'def vbvb_go(+t: F.array__Tree<U32>, +N: U32, +n: Nat, +fc: WBV.fct2(t, N, n), +kpos: {Nat.is_lt(0n, n) == True{} : Bool})',
                '    -> {VD.root_valid(S.BitsValue{BLP.btk(n, BLP.bitsof(F.array__slots(U32, t)))}, S.BitVector{n}) == True{} : Bool}:',
                '  %Equal.sym(Nat, List.length(&2, Bool, BLP.btk(n, BLP.bitsof(F.array__slots(U32, t)))), n, vbvb_len(t, N, n, fc)) :',
                '    {Bool.and(Nat.is_lt(0n, n), Nat.is_eq(_, n)) == True{} : Bool}',
                '  %Equal.sym(Bool, Nat.is_eq(n, n), True{}, F.nat__is_eq_refl(n)) : {Bool.and(Nat.is_lt(0n, n), _) == True{} : Bool}',
                '  %Equal.sym(Bool, Nat.is_lt(0n, n), True{}, kpos) : {Bool.and(_, True{}) == True{} : Bool}',
                '  {==}',
                'def vbvb(-o: O.Words, +s: S.Schema, +n: Nat, +depth: Nat, +rep: WBV.rep_bvb(o, n), +ok: {WBV.ok_bvb(s, n, depth) == True{} : Bool})',
                '    -> {VD.root_valid(S.BitsValue{WBV.wbits(o, n)}, s) == True{} : Bool}:',
                '  (+wf, +fc) = rep', '  (+t, w1) = wf', '  (+dw, w2) = w1', '  (+N, w3) = w2', '  (+q, w4) = w3', '  (+r, w5) = w4',
                '  (+eo, w6) = w5', '  (+pf, w7) = w6', '  (+hd, w8) = w7', '  (+enq, w9) = w8', '  (+h1, w10) = w9', '  (+h32, w11) = w10',
                '  (+room, +slack) = w11',
                '  +ks = DK.and_l(SH.is_BitVector(s), Bool.and(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Mix.canonical_depth(n, depth))), ok)',
                '  +k1 = DK.and_r(SH.is_BitVector(s), Bool.and(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Mix.canonical_depth(n, depth))), ok)',
                '  +keq = DK.and_l(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Mix.canonical_depth(n, depth)), k1)',
                '  +k2 = DK.and_r(Nat.is_eq(SH.BitVector_length(s), n), Bool.and(Nat.is_lt(0n, n), Mix.canonical_depth(n, depth)), k1)',
                '  +kpos = DK.and_l(Nat.is_lt(0n, n), Mix.canonical_depth(n, depth), k2)',
                '  +fc2 = WBV.fct_ft(t, N, n, WBV.fct_at(o, t, N, n, eo, fc))',
                '  %Equal.sym(S.Schema, s, S.BitVector{SH.BitVector_length(s)}, SH.BitVector_shape(s, ks)) : {VD.root_valid(S.BitsValue{WBV.wbits(o, n)}, _) == True{} : Bool}',
                '  %Equal.sym(Nat, SH.BitVector_length(s), n, F.nat__eq_from_is_eq(SH.BitVector_length(s), n, keq)) : {VD.root_valid(S.BitsValue{WBV.wbits(o, n)}, S.BitVector{_}) == True{} : Bool}',
                '  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) : {VD.root_valid(S.BitsValue{WBV.wbits(_, n)}, S.BitVector{n}) == True{} : Bool}',
                '  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :',
                '    {VD.root_valid(S.BitsValue{BLP.btk(n, BLP.bitsof(F.array__slots(U32, _)))}, S.BitVector{n}) == True{} : Bool}',
                '  vbvb_go(t, N, n, fc2, kpos)', ''],
    }

    def bvr(self, fs):
        """A one-word partial bit vector record field (root_laws_b bvr_laws): its view is the
        first n bits of the word, and the word holds 32 >= n bits."""
        if fs.p in self.done:
            return
        self.done.add(fs.p)
        RT, p, n = self.RT, fs.p, fs.t.size
        R = RA.qual(fs.rep)
        BITS = f'BLP.btk({n}n, BLP.bitsof([w0]))'
        self.out.extend([
            f'def vbvr_h_{p}(+w0: U32) -> {{Nat.is_le({n}n, List.length(&2, Bool, BLP.bitsof([w0]))) == True{{}} : Bool}}:',
            f'  %Equal.sym(Nat, List.length(&2, Bool, BLP.bitsof([w0])), {RT}.bl32([w0]), {RT}.len_bitsof([w0])) :',
            f'    {{Nat.is_le({n}n, _) == True{{}} : Bool}}',
            '  {==}',
            f'def vbvr_{p}(+o: {R}) -> {{VD.root_valid({RT}.v_{p}(o), S.BitVector{{{n}n}}) == True{{}} : Bool}}:',
            '  match o:',
            f'    case {RA.pattern(R, ["w0"])}:',
            f'      %Equal.sym(Nat, List.length(&2, Bool, {BITS}), {n}n, {RT}.btk_len({n}n, BLP.bitsof([w0]), vbvr_h_{p}(w0))) :',
            f'        {{Bool.and(Nat.is_lt(0n, {n}n), Nat.is_eq(_, {n}n)) == True{{}} : Bool}}',
            '      {==}',
            ''])

    def extra(self, k):
        if ('X:' + k) in self.done:
            return
        self.done.add('X:' + k)
        self.out.extend(self.EXTRA[k])

    def box_words(self, fs):
        if fs.p in self.done:
            return
        self.done.add(fs.p)
        RT = self.RT
        p = fs.p
        BR = 'O.Boxed<O.Words>'
        L = [f'def vr_{p}(-o: {BR}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{{RT}.ok_{p}(s, dv) == True{{}} : Bool}}, +eq: {RT}.eqs_{p}(s))',
             f'    -> {{VD.root_valid({RT}.v_{p}(o), s) == True{{}} : Bool}}:',
             '  (+eo, +ri) = rep',
             f'  %Equal.sym({BR}, o, O.BSome{{{RT}.pjb_{p}(o), O.BNone{{}}}}, eo) : {{VD.root_valid({RT}.v_{p}(_), s) == True{{}} : Bool}}',
             f'  VO.vbl({RT}.pjb_{p}(o), s, {self.okdepth(fs)}, ri, ok)', '']
        self.out.extend(L)

    def okdepth(self, fs):
        """The depth term of a box of byte list's ok (literal, or the DV entry)."""
        g = self.gen
        inner = fs.inner
        d = G.log2ceil(max(1, (inner.t.size + 31) // 32))
        return f'OS.dv_{d}(dv)' if d >= RBmod().BIGD else f'{d}n'

    def tlist(self, fs, mode=None):
        """A list / vector / progressive list of boxed Type-kind elements (root_laws_b tlist_laws,
        ptlist_laws, through mirrors)."""
        if fs.p in self.done:
            return
        mode = mode or {'list': 'list', 'vector': 'vector', 'plist': 'plist'}[fs.t.kind]
        g, RT = self.gen, self.RT
        p = fs.p
        BE = fs.elem
        E = BE.inner
        if E.kind == 'container' or (E.kind == 'seq' and E.t.kind == 'plist' and not E.pelem.data):
            self.box(BE, 'boxT')
            MI = f'{RT}.M_{E.p}'
        elif E.kind == 'bytelist':
            self.box_words(BE)
            MI = f'{RT}.WMr'
        else:
            raise RA.Skip(f'{p}: list of {BE.p} (element kind {E.kind})')
        self.done.add(p)
        MX = f'{RT}.MB<{MI}>'
        Seq = f'T.{p}_Seq'
        th = f'{RT}.th_{BE.p}'
        xa = lambda W, i: f'{RT}.xat_{p}({W}, {i})'
        L = []
        w = L.append
        w(f'# ---- {p}: list of {BE.p} ----')
        w(f'law vtlen_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w(f'  {{VD.items_length({RT}.xi_{p}(k, W, i)) == k : Nat}}')
        w(f'def vtlen_{p}(k, W, i):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w(f'      %Equal.sym(Nat, VD.items_length({RT}.xi_{p}(q, W, 1n+i)), q, vtlen_{p}(q, W, 1n+i)) : {{1n+_ == 1n+q : Nat}}')
        w('      {==}')
        w(f'law vtval_{p}:')
        w('  for +k: Nat')
        w(f'  for +W: List<&2, {MX}>')
        w('  for +i: Nat')
        w('  for +sE: S.Schema')
        w(f'  for +er: {RT}.ereps_{p}(k, W, i, sE)')
        w('  for +dv: OS.DV')
        w('  for +edv: {dv == OS.DV0() : OS.DV}')
        w(f'  for +ok: {{{RT}.ok_{BE.p}(sE, dv) == True{{}} : Bool}}')
        w(f'  for +eq: {RT}.eqs_{BE.p}(sE)')
        w(f'  {{VD.root_valid({RT}.xi_{p}(k, W, i), S.Repeat{{sE}}) == True{{}} : Bool}}')
        w(f'def vtval_{p}(k, W, i, sE, er, dv, edv, ok, eq):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +q:')
        w('      (+r0, +rs) = er')
        x0 = f'{th}({xa("W", "i")})'
        w(f'      %Equal.sym(Bool, VD.root_valid({RT}.v_{BE.p}({x0}), sE), True{{}}, vr_{BE.p}({x0}, sE, r0, dv, edv, ok, eq)) :')
        w(f'        {{Bool.and(_, VD.root_valid({RT}.xi_{p}(q, W, 1n+i), S.Repeat{{sE}})) == True{{}} : Bool}}')
        w(f'      vtval_{p}(q, W, 1n+i, sE, rs, dv, edv, ok, eq)')
        acc = {'list': 'ListOf', 'vector': 'Vector', 'plist': 'ProgressiveList'}[mode]
        sE = f'SH.{acc}_element(s)'
        D_ = g.depth(fs, 'tl') if mode != 'plist' else 0
        if mode == 'vector' and (D_ == 0 or D_ >= RBmod().BIGD):
            raise RA.Skip(f'{p}: vector of Type-kind elements at depth {D_} not yet')
        DD = f'OS.dv_{D_}(dv)' if D_ >= RBmod().BIGD else f'{D_}n'
        Ts = f'{RT}.am_{p}(t)'
        W = f'F.array__slots({MX}, t)'
        nN = 'U32.to_nat(N)'
        XI = f'{RT}.xi_{p}({nN}, {W}, 0n)'
        w(f'def vr_{p}(-o: {Seq}, +s: S.Schema, +rep: {RT}.rep_{p}(o, s), +dv: OS.DV, +edv: {{dv == OS.DV0() : OS.DV}}, +ok: {{{RT}.ok_{p}(s, dv) == True{{}} : Bool}}, +eq: {RT}.eqs_{p}(s))')
        w(f'    -> {{VD.root_valid({RT}.xv_{p}(o), s) == True{{}} : Bool}}:')
        if mode != 'plist':
            w('  (+wf, +hv) = rep')
            w('  (+t, w1) = wf')
        else:
            w('  (+t, w1) = rep')
        w('  (+dw, w2) = w1')
        w('  (+N, w3) = w2')
        w('  (+eo, w4) = w3')
        w('  (+pf, w5) = w4')
        w('  (+hd, w6) = w5')
        w('  (+hn, +er) = w6')
        VT = f'vtval_{p}({nN}, {W}, 0n, {sE}, er, dv, edv, kel, eq)'
        if mode == 'plist':
            w(f'  +k0 = DK.and_l(SH.is_ProgressiveList(s), {RT}.ok_{BE.p}({sE}, dv), ok)')
            w(f'  +kel = DK.and_r(SH.is_ProgressiveList(s), {RT}.ok_{BE.p}({sE}, dv), ok)')
            SC = f'S.ProgressiveList{{{sE}}}'
            shape = 'SH.ProgressiveList_shape(s, k0)'
        else:
            Lm = f'SH.{acc}_{"limit" if mode == "list" else "length"}(s)'
            rest = f'Bool.and(Lim.minimal({Lm}, {DD}), {RT}.ok_{BE.p}({sE}, dv))'
            w(f'  +k0 = DK.and_l(SH.is_{acc}(s), {rest}, ok)')
            w(f'  +k1 = DK.and_r(SH.is_{acc}(s), {rest}, ok)')
            w(f'  +kel = DK.and_r(Lim.minimal({Lm}, {DD}), {RT}.ok_{BE.p}({sE}, dv), k1)')
            SC = f'S.{acc}{{{sE}, {Lm}}}'
            shape = f'SH.{acc}_shape(s, k0)'
            if mode == 'list':
                w(f'  +hvN = {RT}.xhv_{p}(o, t, N, {Lm}, eo, hv)')
            else:
                w(f'  +km = DK.and_l(Lim.minimal({Lm}, {DD}), {RT}.ok_{BE.p}({sE}, dv), k1)')
                w(f'  +eN = F.nat__eq_from_is_eq({nN}, {Lm}, {RT}.xhv_{p}(o, t, N, {Lm}, eo, hv))')
                w(f'  +kp = VO.lt0_rw({nN}, {Lm}, eN, VO.min_pos({Lm}, {D_ - 1}n, km))')
        w(f'  %Equal.sym(S.Schema, s, {SC}, {shape}) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(o), _) == True{{}} : Bool}}')
        if mode == 'vector':
            w(f'  %eN : {{VD.root_valid({RT}.xv_{p}(o), S.Vector{{{sE}, _}}) == True{{}} : Bool}}')
            SC = f'S.Vector{{{sE}, {nN}}}'
        w(f'  %Equal.sym({Seq}, o, {Seq}{{{Ts}, N}}, eo) :')
        w(f'    {{VD.root_valid({RT}.xv_{p}(_), {SC}) == True{{}} : Bool}}')
        w(f'  %Equal.sym(F.array__Tree<{MX}>, {RT}.tfz_{p}({Ts}), t, {RT}.tfzam_{p}(t)) :')
        w(f'    {{VD.root_valid(S.Sequence{{{RT}.xi_{p}({nN}, F.array__slots({MX}, _), 0n)}}, {SC}) == True{{}} : Bool}}')
        if mode == 'list':
            w(f'  %Equal.sym(Bool, VD.root_valid({XI}, S.Repeat{{{sE}}}), True{{}}, {VT}) :')
            w(f'    {{Bool.and(Nat.is_le(VD.items_length({XI}), {Lm}), _) == True{{}} : Bool}}')
            w(f'  %Equal.sym(Nat, VD.items_length({XI}), {nN}, vtlen_{p}({nN}, {W}, 0n)) :')
            w(f'    {{Bool.and(Nat.is_le(_, {Lm}), True{{}}) == True{{}} : Bool}}')
            w(f'  %Equal.sym(Bool, Nat.is_le({nN}, {Lm}), True{{}}, hvN) : {{Bool.and(_, True{{}}) == True{{}} : Bool}}')
            w('  {==}')
        elif mode == 'vector':
            w(f'  VO.vfin({nN}, {XI}, {sE}, kp, vtlen_{p}({nN}, {W}, 0n), {VT})')
        else:
            w(f'  {VT}')
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
            if inner.kind == 'seq':
                self.tlist(inner, 'plist')
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
        wide = n > G.GROUP
        groups = [list(range(j, min(n, j + G.GROUP))) for j in range(0, n, G.GROUP)] if wide else None
        xs = [f'x{i}' for i in range(n)]
        isdata = [k in ('data', 'datar', 'bvr') for k in kinds]
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
        if prog:
            PN, PF, PA = 'SH.ProgressiveContainer_names(s)', 'SH.ProgressiveContainer_fields(s)', 'SH.ProgressiveContainer_active(s)'
            w(f'  %Equal.sym(S.Schema, s, S.ProgressiveContainer{{{PN}, {PF}, {PA}}}, SH.ProgressiveContainer_shape(s, {kname[0]})) :')
            w(f'    {{VD.root_valid({V0}, _) == True{{}} : Bool}}')
            w(f'  %Equal.sym(S.Schema, {PF}, {chain}, {RT}.fsh_{p}(s, dv, ok)) :')
            w(f'    {{VD.root_valid({V0}, S.ProgressiveContainer{{{PN}, _, {PA}}}) == True{{}} : Bool}}')
        else:
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
    from codegen.proofs.laws import root_laws_b as RB
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
    from codegen.proofs.laws import root_laws_b as RB
    return list(RB.HEAD) + ['import ../../spec/value_domain.bend as VD', 'import ./valid_names.bend as VN', 'import ./valid_obj.bend as VO',
                            'import ./valid_obj2.bend as VO2', 'import ./root_types.bend as RT', '',
                            '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
                            '# The Type-kind root views of root_types.bend are structurally valid under the',
                            "# root laws' own hypotheses (rep_<p>(o, s), s == Spec.<Name>()).", '']


def emit_types(only=None):
    from codegen.proofs.laws import root_laws_b as RB
    gen = RB.Gen()
    gen.run()
    vb = VB(gen, 'RT', 'VN', False)
    laws = []
    src = _unlight((OBJ / 'root_types.bend').read_text())
    status = {}
    big = {}
    state = {}
    for n, t in gen.names.items():
        if only and n not in only:
            continue
        s = gen.g.shape(t)
        bigf = OBJ / f'root_{n}.bend'
        if n in RBmod().LARGE_NAMES or (bigf.exists() and f'law {n}_root_correct:' in _unlight(bigf.read_text())):
            if gen.state_text is not None and f'def rep_{s.p}(' in gen.state_text:
                vs = VB(gen, 'XX', 'VN', False)
                try:
                    vs.shape(s)
                except RA.Skip as e:
                    status[n] = str(e)
                    continue
                stn = RBmod().defnames(gen.state_text)
                import re as _re
                body = _re.sub(r'\bXX\.(\w+)', lambda m_: ('ST.' if m_.group(1) in stn else 'RT.') + m_.group(1), '\n'.join(vs.out))
                state[n] = (s, body)
                status[n] = 'valid (big)'
                continue
            if s.kind == 'container' and not s.data:
                saved = (list(vb.out), set(vb.done))
                try:
                    vb.shape(s)
                except RA.Skip as e:
                    vb.out, vb.done = saved
                    status[n] = str(e)
                    continue
                big[n] = s
                status[n] = 'valid (big)'
            elif s.kind == 'bytelist':
                big[n] = s
                status[n] = 'valid (big)'
            continue
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
    import re as _re
    for m in _re.finditer(r'^def (\w+)_ok\(\+s: S\.Schema, \+es: \{s == Spec\.\w+\(\) : S\.Schema\}\) -> \{WO\.ok_bv\(s, (\d+n)\) == True\{\} : Bool\}:', src, _re.M):
        n, d = m.groups()
        if only and n not in only:
            continue
        laws.append(f'def {n}_root_valid(-o: O.Words, +s: S.Schema, +es: {{s == Spec.{n}() : S.Schema}}, +rep: WO.rep_bv(o, s))')
        laws.append('    -> {VD.root_valid(S.BytesValue{WO.wview(o)}, s) == True{} : Bool}:')
        laws.append(f'  VO.vbv(o, s, {d}, rep, RT.{n}_ok(s, es))')
        laws.append('')
        status[n] = 'valid'
    bigtext = {}
    for n, s in big.items():
        R = RA.qual(s.rep)
        head = [x for x in types_head() if x.startswith('import ')] + [f'import ./root_{n}.bend as BR', 'import ./gvalid_types.bend as GVT', '',
                '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
                f'# BIG: {n}\'s root view is structurally valid under its root law\'s hypotheses; the',
                '# closed schema facts come from its big root law file (root_<Name>.bend).', '']
        if s.kind == 'bytelist':
            body = [f'def {n}_root_valid(-o: O.Words, +s: S.Schema, +es: {{s == Spec.{n}() : S.Schema}}, +rep: LO.rep_bl(o, s))',
                    '    -> {VD.root_valid(S.BytesValue{WO.wview(o)}, s) == True{} : Bool}:',
                    f'  VO.vbl(o, s, OS.dv_25(OS.DV0()), rep, BR.{n}_ok(s, es, OS.DV0(), {{==}}))']
        else:
            body = [f'def {n}_root_valid(-o: {R}, +s: S.Schema, +es: {{s == Spec.{n}() : S.Schema}}, +rep: RT.rep_{s.p}(o, s))',
                    f'    -> {{VD.root_valid(RT.v_{s.p}(o), s) == True{{}} : Bool}}:',
                    f'  GVT.vr_{s.p}(o, s, rep, OS.DV0(), {{==}}, BR.{n}_ok(s, es, OS.DV0(), {{==}}), BR.{n}_eqs(s, es))']
        bigtext[OBJ / f'gvalid_{n}.bend'] = '\n'.join(head + body) + '\n'
    for n, (s, body) in state.items():
        R = RA.qual(s.rep)
        head = [x for x in types_head() if x.startswith('import ') and not x.endswith(' as VN')] + [
                'import ./valid_names.bend as VN',
                'import ./gvalid_packed.bend as VP', 'import ./bitlist_pack.bend as BLP', 'import ./blist_obj.bend as BLI', 'import ./packed_bytes.bend as PB',
                'import ./root_state.bend as ST', f'import ./root_{n}.bend as BR', '',
                '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
                f'# BIG: {n}\'s root view (root_state.bend) is structurally valid under its root law\'s',
                '# hypotheses; the closed schema facts come from root_<Name>.bend.', '']
        law = [f'def {n}_root_valid(-o: {R}, +s: S.Schema, +es: {{s == Spec.{n}() : S.Schema}}, +rep: ST.rep_{s.p}(o, s))',
               f'    -> {{VD.root_valid(ST.v_{s.p}(o), s) == True{{}} : Bool}}:',
               f'  vr_{s.p}(o, s, rep, OS.DV0(), {{==}}, BR.{n}_ok(s, es, OS.DV0(), {{==}}), BR.{n}_eqs(s, es))']
        bigtext[OBJ / f'gvalid_{n}.bend'] = '\n'.join(head + [body] + law) + '\n'
    return '\n'.join(types_head() + vb.out + laws) + '\n', status, bigtext


def union_valid(gen, vb, name, s):
    """A compatible union's root view is valid: by cases on the option its rep_ names, the
    option's own validity at the option's (closed) schema, as the root law's rep_ states it."""
    p = s.p
    R = RA.qual(s.rep)
    opts = [o for _, o in s.options]
    n = len(opts)
    byp = {gen.g.shape(t).p: nm for nm, t in gen.names.items()}
    GOAL = f'{{VD.root_valid(RT.v_{p}(o), Spec.{name}()) == True{{}} : Bool}}'
    L = []
    w = L.append
    w(f'# ---- {name}: compatible union ----')
    for i, o in enumerate(opts):
        OSi = RG.spec_of(o.t)
        w(f'def vu_{p}_{i}(-o: {R}, +a: RT.pc_{p}_{i}(o)) -> {GOAL}:')
        if o.data:
            if RA.needs_rep(o):
                w('  (+v, a1) = a')
                w('  (+eo, +rp) = a1')
                call = f'GV.rv_{o.p}(v' + (', rp)' if vneeds_rp(o) else ')')
            else:
                w('  (+v, +eo) = a')
                call = f'GV.rv_{o.p}(v)'
            w(f'  %Equal.sym({R}, o, {R}_c{i}{{v}}, eo) : {{VD.root_valid(RT.v_{p}(_), Spec.{name}()) == True{{}} : Bool}}')
            w(f'  {call}')
        else:
            if o.p not in byp:
                raise RA.Skip(f'{name}: option {o.p} is not a named form')
            vb.shape(o)
            N = byp[o.p]
            v = f'RT.pju_{p}_{i}(o)'
            w('  (+eo, +ri) = a')
            w(f'  %Equal.sym({R}, o, {R}_c{i}{{{v}}}, eo) : {{VD.root_valid(RT.v_{p}(_), Spec.{name}()) == True{{}} : Bool}}')
            w(f'  vr_{o.p}({v}, {OSi}, ri, OS.DV0(), {{==}}, RT.{N}_ok({OSi}, {{==}}, OS.DV0(), {{==}}), RT.{N}_eqs({OSi}, {{==}}))')
    for k in range(n - 2, -1, -1):
        w(f'def vul_{p}_{k}(-o: {R}, +r: RT.por_{p}_{k}(o)) -> {GOAL}:')
        w('  match r:')
        w(f'    case Inl{{+a}}: vu_{p}_{k}(o, a)')
        nxt = f'vu_{p}_{n - 1}(o, b)' if k == n - 2 else f'vul_{p}_{k + 1}(o, b)'
        w(f'    case Inr{{+b}}: {nxt}')
    top = f'vu_{p}_0(o, rep)' if n == 1 else f'vul_{p}_0(o, rep)'
    w(f'def {name}_root_valid(-o: {R}, +rep: RT.rep_{p}(o)) -> {GOAL}: {top}')
    w('')
    return L


def emit_gtypes():
    """The generic Type-kind containers of root_gtypes.bend / root_gtypes2.bend: <Name>_root_valid
    under each root law's own binders (o, s, es, rep), through the VB class over the generator run
    that produced those files (root_laws_generic.emit_phase_b)."""
    import re
    names = RG.generic_names()
    RA.PARTIAL_OK = RG.container_partial_bits(names)
    RA.PARTIAL_HOOK = RG.partial_bits_shape
    RG.emit_phase_b(names)
    gb, gb2 = RG.LAST_GENS
    RA.PARTIAL_OK = RG.container_partial_bits(names)
    RA.PARTIAL_HOOK = RG.partial_bits_shape
    outs, status = {}, {}
    for gen, fn, out in ((gb, 'root_gtypes', 'gvalid_gtypes'), (gb2, 'root_gtypes2', 'gvalid_gtypes2')):
        src = _unlight((OBJ / f'{fn}.bend').read_text())
        head = [x for x in src.split('\n') if x.startswith('import ')]
        vb = VB(gen, 'RT', 'GV', True)
        laws = []
        RA.EXTRA_LEAVES = True
        try:
            for n, t in gen.names.items():
                if not re.search(r'^law ' + n + r'_root_correct:\n  for -h: B.Buf\n  for -o: .*\n  for \+s: S.Schema\n  for \+es:', src, re.M):
                    continue
                sh = gen.g.shape(t)
                if sh.kind not in ('container', 'pcontainer') or sh.data:
                    continue
                saved = (list(vb.out), set(vb.done))
                try:
                    vb.shape(sh)
                except RA.Skip as e:
                    vb.out, vb.done = saved
                    status[n] = str(e)
                    continue
                R = RA.qual(sh.rep)
                laws.append(f'def {n}_root_valid(-o: {R}, +s: S.Schema, +es: {{s == Spec.{n}() : S.Schema}}, +rep: RT.rep_{sh.p}(o, s))')
                laws.append(f'    -> {{VD.root_valid(RT.v_{sh.p}(o), s) == True{{}} : Bool}}:')
                laws.append(f'  vr_{sh.p}(o, s, rep, OS.DV0(), {{==}}, RT.{n}_ok(s, es, OS.DV0(), {{==}}), RT.{n}_eqs(s, es))')
                laws.append('')
                status[n] = 'valid'
            if fn == 'root_gtypes2':
                for n, t in gen.names.items():
                    sh = gen.g.shape(t)
                    if sh.kind != 'cunion' or f'law {n}_root_correct:' not in src:
                        continue
                    try:
                        laws.extend(union_valid(gen, vb, n, sh))
                        status[n] = 'valid'
                    except RA.Skip as e:
                        status[n] = str(e)
        finally:
            RA.EXTRA_LEAVES = False
        body = '\n'.join(vb.out + laws)
        extra = ['import ../../spec/value_domain.bend as VD', 'import ./gvalid_gnames.bend as GV', 'import ./valid_obj.bend as VO',
                 'import ./valid_obj2.bend as VO2']
        if 'VP.' in body:
            extra.append('import ./gvalid_packed.bend as VP')
        if 'BLP.' in body and 'import ./bitlist_pack.bend as BLP' not in head:
            extra.append('import ./bitlist_pack.bend as BLP')
        extra.append(f'import ./{fn}.bend as RT')
        text = '\n'.join(head + extra + ['', '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
                          f'# The generic Type-kind root views of {fn}.bend are structurally valid under the',
                          "# root laws' own hypotheses (rep_<p>(o, s), s == Spec.<Name>()).", '', body]) + '\n'
        outs[OBJ / f'{out}.bend'] = text
    return outs, status


# ---- packed basic elements (packed_obj PK, packed_bytes PB, prog_list PG, blist_obj BLI) ----

PACK_HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
             'import ../../spec/value_domain.bend as VD', 'import ../../spec/primitives.bend as SP', 'import ../../spec/root_relation.bend as RR',
             'import ../../spec/codec.bend as Codec', 'import ../../spec/limits.bend as Lim', 'import ../compact/found.bend as F',
             'import ./dk.bend as DK', 'import ./schema_shapes.bend as SH', 'import ./spec_fixed.bend as FX', 'import ./words_spec.bend as WS',
             'import ./words_obj.bend as WO', 'import ./list_obj.bend as LO', 'import ./ulist_obj.bend as UL',
             'import ./packed_obj.bend as PK', 'import ./packed_bytes.bend as PB', 'import ./valid_lib.bend as VL', 'import ./valid_obj.bend as VO',
             'import ./mtree_defs.bend as MD', 'import ./words_root.bend as WR', 'import ./prog_list.bend as PG', 'import ./blist_obj.bend as BLI', '',
             '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
             '# Structural validity of packed basic elements: every element of a packed vector / list',
             '# view is in its type\'s domain, and the views hold their element counts.', '']

WPK = {'4': (1, 'P.U32Width{}', lambda a: f'VL.u32dom({a[0]})'), '8': (2, 'P.U64{}', lambda a: f'VL.u64dom({a[0]}, {a[1]})'),
       '16': (4, 'P.U128{}', lambda a: 'VL.u128dom(' + ', '.join(a) + ')'), '32': (8, 'P.U256{}', lambda a: 'VL.u256dom(' + ', '.join(a) + ')')}


def emit_packed_lib():
    L = list(PACK_HEAD)
    w = L.append
    ctors = [('S.BooleanValue{+b}', 'S.BooleanValue{b}'), ('S.UnsignedValue{+v}', 'S.UnsignedValue{v}'), ('S.BytesValue{+x}', 'S.BytesValue{x}'),
             ('S.BitsValue{+x}', 'S.BitsValue{x}'), ('S.Sequence{+x}', 'S.Sequence{x}'), ('S.EmptyItems{}', 'S.EmptyItems{}'),
             ('S.Selected{+a, +x}', 'S.Selected{a, x}'), ('S.NullValue{}', 'S.NullValue{}')]
    w('# The two item counts of the specification agree.')
    w('law cnt_len:')
    w('  for +items: S.Value')
    w('  {VD.items_length(items) == Codec.count(items) : Nat}')
    w('def cnt_len(items):')
    w('  match items:')
    w('    case S.Items{+h, +t}:')
    w('      %Equal.sym(Nat, VD.items_length(t), Codec.count(t), cnt_len(t)) : {1n+_ == 1n+Codec.count(t) : Nat}')
    w('      {==}')
    for pat, _ in ctors:
        w(f'    case {pat}: {{==}}')
    w('')
    # word kinds
    for K, (m, W, dom) in WPK.items():
        A = [f'a{i}' for i in range(m)]
        V = 'P.UInt{' + ', '.join(A + ['0'] * (8 - m)) + '}'
        R = f'S.Repeat{{S.Unsigned{{{W}}}}}'
        for nm, stmt in (('vit', f'{{VD.root_valid(PK.it{K}(k, W), {R}) == True{{}} : Bool}}'),
                         ('lit', f'{{Nat.is_le(VD.items_length(PK.it{K}(k, W)), k) == True{{}} : Bool}}')):
            w(f'law {nm}{K}:')
            w('  for +k: Nat')
            w('  for +W: List<&2, U32>')
            w(f'  {stmt}')
            w(f'def {nm}{K}(k, W):')
            w('  match k:')
            w('    case 0n: {==}')
            w('    case 1n+ +c:')
            ind = '      '
            src = 'W'
            for i, a in enumerate(A):
                w(f'{ind}match {src}:')
                w(f'{ind}  case Nil{{}}: ' + ('{==}' if nm == 'vit' else 'VO.zero_le(1n+c)'))
                nxt = 'rest' if i == m - 1 else f't{i}'
                w(f'{ind}  case Con{{+{a}, +{nxt}}}:')
                ind += '    '
                src = nxt
            if nm == 'vit':
                w(f'{ind}%Equal.sym(Bool, SP.uint_domain({W}, {V}), True{{}}, {dom(A)}) :')
                w(f'{ind}  {{Bool.and(_, VD.root_valid(PK.it{K}(c, rest), {R})) == True{{}} : Bool}}')
                w(f'{ind}vit{K}(c, rest)')
            else:
                w(f'{ind}lit{K}(c, rest)')
        w('')
    # byte kinds
    for K, W, hyp in (('1', 'S.Unsigned{P.U8{}}', True), ('b', 'S.Boolean{}', False), ('2', 'S.Unsigned{P.U16{}}', True)):
        R = f'S.Repeat{{{W}}}'
        m = 2 if K == '2' else 1
        for nm, stmt in (('vit', f'{{VD.root_valid(PB.it{K}(k, xs), {R}) == True{{}} : Bool}}'),
                         ('lit', f'{{Nat.is_le(VD.items_length(PB.it{K}(k, xs)), k) == True{{}} : Bool}}')):
            hy = hyp and nm == 'vit'
            w(f'law {nm}{K}:')
            w('  for +k: Nat')
            w('  for +xs: +List<U32>')
            if hy:
                w('  for +hd: {SP.bytes_domain(xs) == True{} : Bool}')
            w(f'  {stmt}')
            w(f'def {nm}{K}(k, xs' + (', hd' if hy else '') + '):')
            w('  match k:')
            w('    case 0n: {==}')
            w('    case 1n+ +c:')
            w('      match xs:')
            w('        case Nil{}: ' + ('{==}' if nm == 'vit' else 'VO.zero_le(1n+c)'))
            if m == 1:
                w('        case Con{+x0, +rest}:')
                ind = '          '
            else:
                w('        case Con{+x0, +t0}:')
                w('          match t0:')
                w('            case Nil{}: ' + ('{==}' if nm == 'vit' else 'VO.zero_le(1n+c)'))
                w('            case Con{+x1, +rest}:')
                ind = '              '
            if nm == 'lit':
                w(f'{ind}lit{K}(c, rest)')
                continue
            if K == 'b':
                w(f'{ind}vitb(c, rest)')
                continue
            if K == '1':
                w(f'{ind}+e0 = WS.and_left(U32.is_lt(x0, 256), SP.bytes_domain(rest), hd)')
                w(f'{ind}+hr = WS.and_right(U32.is_lt(x0, 256), SP.bytes_domain(rest), hd)')
                w(f'{ind}%Equal.sym(Bool, SP.uint_domain(P.U8{{}}, P.UInt{{x0, 0, 0, 0, 0, 0, 0, 0}}), True{{}}, VL.u8dom(x0, e0)) :')
                w(f'{ind}  {{Bool.and(_, VD.root_valid(PB.it1(c, rest), {R})) == True{{}} : Bool}}')
                w(f'{ind}vit1(c, rest, hr)')
            else:
                w(f'{ind}+e0 = WS.and_left(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.bytes_domain(rest)), hd)')
                w(f'{ind}+k1 = WS.and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.bytes_domain(rest)), hd)')
                w(f'{ind}+e1 = WS.and_left(U32.is_lt(x1, 256), SP.bytes_domain(rest), k1)')
                w(f'{ind}+hr = WS.and_right(U32.is_lt(x1, 256), SP.bytes_domain(rest), k1)')
                V = 'P.UInt{PB.v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}'
                w(f'{ind}%Equal.sym(Bool, SP.uint_domain(P.U16{{}}, {V}), True{{}}, VL.od_true(SP.uint_domain(P.U16{{}}, {V}), SP.prefix(2n, SP.full_digits({V})), [x0, x1], PB.two(x0, x1, e0, e1))) :')
                w(f'{ind}  {{Bool.and(_, VD.root_valid(PB.it2(c, rest), {R})) == True{{}} : Bool}}')
                w(f'{ind}vit2(c, rest, hr)')
        w('')
    emit_packed_vec(w)
    emit_packed_lists(w)
    emit_blists(w)
    return '\n'.join(L) + '\n'


def split_and(e):
    """The conjuncts of a right-nested Bool.and(...) text."""
    out = []
    e = e.strip()
    while e.startswith('Bool.and('):
        inner = e[len('Bool.and('):-1]
        depth, i = 0, 0
        for i, ch in enumerate(inner):
            if ch in '({[':
                depth += 1
            elif ch in ')}]':
                depth -= 1
            elif ch == ',' and depth == 0:
                break
        out.append(inner[:i].strip())
        e = inner[i + 1:].strip()
    out.append(e)
    return out


def ok_def(mod_file, name, alias):
    """The conjuncts of `def <name>(...) -> Bool: <expr>` of a module, qualified."""
    import re
    src = _unlight((OBJ / mod_file).read_text())
    m = re.search(r'^def ' + name + r'\(.*?\) -> Bool:\s*(.*?)(?:\n(?=\S|\n)|\n?\Z)', src, re.M | re.S)
    expr = ' '.join(m.group(1).split())
    loc = set(re.findall(r'^def (\w+)\(', src, re.M))
    expr = re.sub(r'(?<![\w.])(\w+)\(', lambda mm: (f'{alias}.{mm.group(1)}(' if mm.group(1) in loc else mm.group(0)), expr)
    return split_and(expr)


def and_lets(w, conj, root, ind='  '):
    """k0.. names of the conjuncts of fact `root`."""
    names = []
    prev = root
    for j in range(len(conj)):
        if j == len(conj) - 1:
            names.append(prev)
            break
        rest = fold_and(conj[j + 1:])
        w(f'{ind}+k{j} = DK.and_l({conj[j]}, {rest}, {prev})')
        w(f'{ind}+r{j + 1} = DK.and_r({conj[j]}, {rest}, {prev})')
        names.append(f'k{j}')
        prev = f'r{j + 1}'
    return names


VKIND = {  # K: (module alias, module file, width, element count shift, e-function, it-alias)
    '1': ('PB', 'packed_bytes.bend', 'P.U8{}', None, None), 'b': ('PB', 'packed_bytes.bend', None, None, None),
    '2': ('PB', 'packed_bytes.bend', 'P.U16{}', '1n', 'Nat.double'),
    '4': ('PK', 'packed_obj.bend', 'P.U32Width{}', '2n', 'PK.e4'), '8': ('PK', 'packed_obj.bend', 'P.U64{}', '3n', 'PK.e8'),
    '16': ('PK', 'packed_obj.bend', 'P.U128{}', '4n', 'PK.e16'), '32': ('PK', 'packed_obj.bend', 'P.U256{}', '5n', 'PK.e32')}
WSHAPE = {'1': 'PB.is_U8_shape', '2': 'PB.is_U16_shape', '4': 'PK.is_U32Width_shape', '8': 'PK.is_U64_shape',
          '16': 'PK.is_U128_shape', '32': 'PK.is_U256_shape'}


def emit_packed_vec(w):
    """Exact counts, positivity, and the vector lemmas vv<K>."""
    w('def lt0_rw(+a: Nat, +b: Nat, +e: {a == b : Nat}, +h: {Nat.is_lt(0n, b) == True{} : Bool}) -> {Nat.is_lt(0n, a) == True{} : Bool}:')
    w('  %Equal.sym(Nat, a, b, e) : {Nat.is_lt(0n, _) == True{} : Bool}')
    w('  h')
    w('def scope_rw(+a: Nat, +b: Nat, +xs: +List<U32>, +e: {a == b : Nat}, +h: {SP.byte_scope(a, xs) == True{} : Bool}) -> {SP.byte_scope(b, xs) == True{} : Bool}:')
    w('  %e : {SP.byte_scope(_, xs) == True{} : Bool}')
    w('  h')
    w('# A vector view of k items of length k, positive, every item valid, is valid.')
    w('def vfin(+k: Nat, +items: S.Value, +E: S.Schema, +kp: {Nat.is_lt(0n, k) == True{} : Bool},')
    w('    +le: {VD.items_length(items) == k : Nat}, +rv: {VD.root_valid(items, S.Repeat{E}) == True{} : Bool})')
    w('    -> {VD.root_valid(S.Sequence{items}, S.Vector{E, k}) == True{} : Bool}:')
    w('  %Equal.sym(Bool, VD.root_valid(items, S.Repeat{E}), True{}, rv) :')
    w('    {Bool.and(Bool.and(Nat.is_lt(0n, k), Nat.is_eq(VD.items_length(items), k)), _) == True{} : Bool}')
    w('  %Equal.sym(Nat, VD.items_length(items), k, le) : {Bool.and(Bool.and(Nat.is_lt(0n, k), Nat.is_eq(_, k)), True{}) == True{} : Bool}')
    w('  %Equal.sym(Bool, Nat.is_eq(k, k), True{}, F.nat__is_eq_refl(k)) : {Bool.and(Bool.and(Nat.is_lt(0n, k), _), True{}) == True{} : Bool}')
    w('  %Equal.sym(Bool, Nat.is_lt(0n, k), True{}, kp) : {Bool.and(Bool.and(_, True{}), True{}) == True{} : Bool}')
    w('  {==}')
    w('')
    # positivity from a positive multiple
    for K in ('2', '4', '8', '16', '32'):
        ef = VKIND[K][4]
        w(f'def pos{K}(+k: Nat, +h: {{Nat.is_lt(0n, {ef}(k)) == True{{}} : Bool}}) -> {{Nat.is_lt(0n, k) == True{{}} : Bool}}:')
        w('  match k:')
        w(f'    case 0n: Empty.absurd({{Nat.is_lt(0n, 0n) == True{{}} : Bool}}, MD.false_true(h))')
        w('    case 1n+ +p: {==}')
    w('')
    # exact counts
    for K in ('4', '8', '16', '32'):
        m = WPK[K][0]
        w(f'law leq{K}:')
        w('  for +k: Nat')
        w('  for +W: List<&2, U32>')
        w(f'  for +hl: {{Nat.is_le(PK.m{K}(k), F.spec_common__length(U32, W)) == True{{}} : Bool}}')
        w(f'  {{VD.items_length(PK.it{K}(k, W)) == k : Nat}}')
        w(f'def leq{K}(k, W, hl):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +c:')
        ind, src = '      ', 'W'
        consumed = []
        for i in range(m):
            nxt = 'rest' if i == m - 1 else f't{i}'
            lst = 'Nil{}'
            for a in reversed(consumed):
                lst = f'Con{{{a}, {lst}}}'
            w(f'{ind}match {src}:')
            w(f'{ind}  case Nil{{}}: Empty.absurd({{VD.items_length(PK.it{K}(1n+c, {lst})) == 1n+c : Nat}}, MD.false_true(hl))')
            w(f'{ind}  case Con{{+a{i}, +{nxt}}}:')
            consumed.append(f'a{i}')
            ind += '    '
            src = nxt
        w(f'{ind}%Equal.sym(Nat, VD.items_length(PK.it{K}(c, rest)), c, leq{K}(c, rest, hl)) : {{1n+_ == 1n+c : Nat}}')
        w(f'{ind}{{==}}')
    for K, sc in (('1', 'k'), ('b', 'k'), ('2', 'Nat.double(k)')):
        w(f'law leq{K}:')
        w('  for +k: Nat')
        w('  for +xs: +List<U32>')
        w(f'  for +hs: {{SP.byte_scope({sc}, xs) == True{{}} : Bool}}')
        w(f'  {{VD.items_length(PB.it{K}(k, xs)) == k : Nat}}')
        w(f'def leq{K}(k, xs, hs):')
        w('  match k:')
        w('    case 0n: {==}')
        w('    case 1n+ +c:')
        w('      match xs:')
        w(f'        case Nil{{}}: Empty.absurd({{VD.items_length(PB.it{K}(1n+c, Nil{{}})) == 1n+c : Nat}}, MD.false_true(hs))')
        if K != '2':
            w('        case Con{+x0, +rest}:')
            w(f'          %Equal.sym(Nat, VD.items_length(PB.it{K}(c, rest)), c, leq{K}(c, rest, WS.and_right(U32.is_lt(x0, 256), SP.byte_scope(c, rest), hs))) : {{1n+_ == 1n+c : Nat}}')
            w('          {==}')
        else:
            w('        case Con{+x0, +t0}:')
            w('          match t0:')
            w(f'            case Nil{{}}: Empty.absurd({{VD.items_length(PB.it2(1n+c, Con{{x0, Nil{{}}}})) == 1n+c : Nat}}, MD.false_true(WS.and_right(U32.is_lt(x0, 256), False{{}}, hs)))')
            w('            case Con{+x1, +rest}:')
            w('              +k1 = WS.and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)')
            w('              %Equal.sym(Nat, VD.items_length(PB.it2(c, rest)), c, leq2(c, rest, WS.and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))) : {1n+_ == 1n+c : Nat}')
            w('              {==}')
    w('')
    # the vectors
    for K, (MOD, mfile, W, sh, ef) in VKIND.items():
        conj = ok_def(mfile, f'ok_v{K}', MOD)
        w(f'# A packed vector of {"booleans" if K == "b" else W} ({MOD} rep_v{K} / ok_v{K}).')
        w(f'def vv{K}(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: {MOD}.rep_v{K}(o, s), +ok: {{{MOD}.ok_v{K}(s, depth) == True{{}} : Bool}})')
        w(f'    -> {{VD.root_valid({MOD}.vview{K}(o), s) == True{{}} : Bool}}:')
        if K == '1':
            w('  (+wf, +hv) = rep')
        else:
            w('  (+wf, +r0) = rep')
        for i, v in enumerate(['t', 'dw', 'N', 'q', 'r', 'eo', 'pf', 'hd', 'enq', 'h1', 'h32']):
            w(f'  (+{v}, w{i + 1}) = ' + ('wf' if i == 0 else f'w{i}'))
        w('  (+room, +slack) = w11')
        if K == 'b':
            w('  (+hv, +hb) = r0')
        elif K != '1':
            w('  (+eN, +hv) = r0')
        kn = and_lets(w, conj, 'ok')
        n = 'SH.Vector_length(s)'
        E = 'SH.Vector_element(s)'
        xsb = 'WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))'
        Wd = 'F.array__slots(U32, t)'
        pos_add = 'WR.pos_add(WS.e32(q), r, h1)'
        if K in ('1', 'b'):
            kv = 'U32.to_nat(N)'
            items_arg = xsb
            w(f'  +hvN = VO.eq_at(o, t, N, {n}, eo, hv)')
            w(f'  +sc = PB.vscope(N, q, r, dw, t, enq, h32, pf, room)')
            w(f'  +kp = lt0_rw(U32.to_nat(N), Nat.add(WS.e32(q), r), enq, {pos_add})')
            w(f'  +le = leq{K}({kv}, {xsb}, sc)')
            rv = f'vit1({kv}, {xsb}, VO.sc_dom({kv}, {xsb}, sc))' if K == '1' else f'vitb({kv}, {xsb})'
        elif K == '2':
            kv = 'U32.to_nat(U32.shrn(N, 1n))'
            items_arg = xsb
            w(f'  +hvN = PB.eqn_n2(o, t, N, {n}, eo, hv)')
            w('  +eNN = PB.eq_n2(o, t, N, eo, eN)')
            w(f'  +sc = PB.vscope(N, q, r, dw, t, enq, h32, pf, room)')
            w(f'  +sc2 = scope_rw(U32.to_nat(N), Nat.double({kv}), {xsb}, eNN, sc)')
            w(f'  +kp = pos2({kv}, lt0_rw(Nat.double({kv}), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), Nat.double({kv}), eNN), lt0_rw(U32.to_nat(N), Nat.add(WS.e32(q), r), enq, {pos_add})))')
            w(f'  +le = leq2({kv}, {xsb}, sc2)')
            rv = f'vit2({kv}, {xsb}, VO.sc_dom(U32.to_nat(N), {xsb}, sc))'
        else:
            kv = f'U32.to_nat(U32.shrn(N, {sh}))'
            items_arg = Wd
            w(f'  +hvN = PK.eqn_n{K}(o, t, N, {n}, eo, hv)')
            w(f'  +eNN = PK.eq_n{K}(o, t, N, eo, eN)')
            w(f'  +ec = Equal.trans(Nat, Nat.add(WS.e32(q), r), U32.to_nat(N), {ef}({kv}), Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq), eNN)')
            w(f'  +kp = pos{K}({kv}, lt0_rw({ef}({kv}), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), {ef}({kv}), eNN), lt0_rw(U32.to_nat(N), Nat.add(WS.e32(q), r), enq, {pos_add})))')
            w(f'  +le = leq{K}({kv}, {Wd}, PK.words_fit{K}({kv}, q, r, dw, t, ec, h32, pf, room))')
            rv = f'vit{K}({kv}, {Wd})'
        w(f'  +eL = WS.nat_eq({kv}, {n}, hvN)')
        Elem = 'S.Boolean{}' if K == 'b' else f'S.Unsigned{{{W}}}'
        w(f'  %Equal.sym(S.Schema, s, S.Vector{{{E}, {n}}}, SH.Vector_shape(s, {kn[0]})) :')
        w(f'    {{VD.root_valid({MOD}.vview{K}(o), _) == True{{}} : Bool}}')
        if K == 'b':
            w(f'  %Equal.sym(S.Schema, {E}, S.Boolean{{}}, SH.Boolean_shape({E}, {kn[1]})) :')
            w(f'    {{VD.root_valid({MOD}.vview{K}(o), S.Vector{{_, {n}}}) == True{{}} : Bool}}')
        else:
            w(f'  %Equal.sym(S.Schema, {E}, S.Unsigned{{SH.Unsigned_width({E})}}, SH.Unsigned_shape({E}, {kn[1]})) :')
            w(f'    {{VD.root_valid({MOD}.vview{K}(o), S.Vector{{_, {n}}}) == True{{}} : Bool}}')
            w(f'  %Equal.sym(P.Width, SH.Unsigned_width({E}), {W}, {WSHAPE[K]}(SH.Unsigned_width({E}), {kn[2]})) :')
            w(f'    {{VD.root_valid({MOD}.vview{K}(o), S.Vector{{S.Unsigned{{_}}, {n}}}) == True{{}} : Bool}}')
        w(f'  %eL : {{VD.root_valid({MOD}.vview{K}(o), S.Vector{{{Elem}, _}}) == True{{}} : Bool}}')
        w(f'  %Equal.sym(O.Words, o, O.Words{{F.array__thaw(U32, t), N}}, eo) :')
        w(f'    {{VD.root_valid({MOD}.vview{K}(_), S.Vector{{{Elem}, {kv}}}) == True{{}} : Bool}}')
        froz = items_arg.replace('F.array__slots(U32, t)', 'F.array__slots(U32, _)')
        w(f'  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
        w(f'    {{VD.root_valid(S.Sequence{{{MOD}.it{K}({kv}, {froz})}}, S.Vector{{{Elem}, {kv}}}) == True{{}} : Bool}}')
        w(f'  vfin({kv}, {MOD}.it{K}({kv}, {items_arg}), {Elem}, kp, le, {rv})')
        w('')


PLK = {  # plist K: (view module, width, count, items args builder)
    '1': ('PB', 'P.U8{}', 'U32.to_nat(N)'), 'b': ('PB', None, 'U32.to_nat(N)'), '2': ('PB', 'P.U16{}', 'U32.to_nat(U32.shrn(N, 1n))'),
    '4': ('PK', 'P.U32Width{}', 'U32.to_nat(U32.shrn(N, 2n))'), '16': ('PK', 'P.U128{}', 'U32.to_nat(U32.shrn(N, 4n))'),
    '32': ('PK', 'P.U256{}', 'U32.to_nat(U32.shrn(N, 5n))'), '8': ('UL', 'P.U64{}', 'U32.to_nat(U32.shrn(N, 3n))')}


def emit_packed_lists(w):
    """Progressive lists (prog_list PG) and bounded lists of uint8/uint16/Bytes32 (blist_obj BLI)."""
    WF0 = ['t', 'dw', 'N', 'eo', 'pf']
    WF1 = ['t', 'dw', 'N', 'q', 'r', 'eo', 'pf', 'hd', 'enq', 'h1', 'h32']

    def dest(names, root, last):
        for i, v in enumerate(names):
            w(f'      (+{v}, w{i + 1}) = ' + (root if i == 0 else f'w{i}'))
        w(f'      {last} = w{len(names)}')

    def items(K, xsN):
        MOD = PLK[K][0]
        if K == '8':
            return f'UL.uitems({PLK[K][2]}, {xsN})'
        return f'{MOD}.it{K}({PLK[K][2]}, {xsN})'

    def valid_call(K, xs, hd):
        if K == '8':
            return f'VO.uvalid({PLK[K][2]}, {xs})'
        if K in ('1', '2'):
            return f'vit{K}({PLK[K][2]}, {xs}, {hd})'
        return f'vit{K}({PLK[K][2]}, {xs})'

    def view(K):
        return {'8': 'UL.uview', 'b': 'PB.vviewb'}.get(K, f'{PLK[K][0]}.vview{K}')

    def elem(K):
        return 'S.Boolean{}' if K == 'b' else f'S.Unsigned{{{PLK[K][1]}}}'
    xsb = 'WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))'
    xsbz = 'WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, _)))'
    Wd = 'F.array__slots(U32, t)'
    # the items of any storage (empty or not) are valid
    for K in PLK:
        byt = K in ('1', 'b', '2')
        R = f'S.Repeat{{{elem(K)}}}'
        w(f'def wv{K}(-o: O.Words, +wf: LO.wfl(o)) -> {{VD.root_valid({view(K)}(o), S.ProgressiveList{{{elem(K)}}}) == True{{}} : Bool}}:')
        w('  match wf:')
        w('    case Inl{w0}:')
        dest(WF0, 'w0', '(+hd, +en0)')
        w(f'      %Equal.sym(O.Words, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{VD.root_valid({view(K)}(_), S.ProgressiveList{{{elem(K)}}}) == True{{}} : Bool}}')
        w(f'      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
        w(f'        {{VD.root_valid({items(K, xsbz if byt else "F.array__slots(U32, _)")}, {R}) == True{{}} : Bool}}')
        if byt:
            w(f'      %Equal.sym(Nat, U32.to_nat(N), 0n, en0) :')
            w(f'        {{VD.root_valid({items(K, "WS.btake(_, FX.limbs(F.array__slots(U32, t)))")}, {R}) == True{{}} : Bool}}')
            w(f'      {valid_call(K, "WS.btake(0n, FX.limbs(F.array__slots(U32, t)))", "{==}")}')
        else:
            w(f'      {valid_call(K, Wd, None)}')
        w('    case Inr{w0}:')
        dest(WF1, 'w0', '(+room, +slack)')
        w(f'      %Equal.sym(O.Words, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{VD.root_valid({view(K)}(_), S.ProgressiveList{{{elem(K)}}}) == True{{}} : Bool}}')
        w(f'      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
        w(f'        {{VD.root_valid({items(K, xsbz if byt else "F.array__slots(U32, _)")}, {R}) == True{{}} : Bool}}')
        if byt:
            w(f'      {valid_call(K, xsb, f"VO.sc_dom(U32.to_nat(N), {xsb}, PB.vscope(N, q, r, dw, t, enq, h32, pf, room))")}')
        else:
            w(f'      {valid_call(K, Wd, None)}')
        w('')
        # the progressive list lemma
        conj = ok_def('prog_list.bend', f'ok_pl{K}', 'PG')
        E = 'SH.ProgressiveList_element(s)'
        w(f'def vpl{K}(-o: O.Words, +s: S.Schema, +rep: PG.rep_pl{K}(o, s), +ok: {{PG.ok_pl{K}(s) == True{{}} : Bool}})')
        w(f'    -> {{VD.root_valid({view(K)}(o), s) == True{{}} : Bool}}:')
        if K == '1':
            w('  +wf = rep')
        else:
            w('  (+wf, +r0) = rep')
        kn = and_lets(w, conj, 'ok')
        w(f'  %Equal.sym(S.Schema, s, S.ProgressiveList{{{E}}}, SH.ProgressiveList_shape(s, {kn[0]})) :')
        w(f'    {{VD.root_valid({view(K)}(o), _) == True{{}} : Bool}}')
        if K == 'b':
            w(f'  %Equal.sym(S.Schema, {E}, S.Boolean{{}}, SH.Boolean_shape({E}, {kn[1]})) :')
            w(f'    {{VD.root_valid({view(K)}(o), S.ProgressiveList{{_}}) == True{{}} : Bool}}')
        else:
            shape = WSHAPE[K] if K != '8' else 'UL.is_U64_shape'
            w(f'  %Equal.sym(S.Schema, {E}, S.Unsigned{{SH.Unsigned_width({E})}}, SH.Unsigned_shape({E}, {kn[1]})) :')
            w(f'    {{VD.root_valid({view(K)}(o), S.ProgressiveList{{_}}) == True{{}} : Bool}}')
            w(f'  %Equal.sym(P.Width, SH.Unsigned_width({E}), {PLK[K][1]}, {shape}(SH.Unsigned_width({E}), {kn[2]})) :')
            w(f'    {{VD.root_valid({view(K)}(o), S.ProgressiveList{{S.Unsigned{{_}}}}) == True{{}} : Bool}}')
        w(f'  wv{K}(o, wf)')
        w('')


def emit_blists(w):
    """Bounded lists held as packed bytes (blist_obj BLI): uint8, uint16, Bytes32."""
    WF0 = ['t', 'dw', 'N', 'eo', 'pf']
    WF1 = ['t', 'dw', 'N', 'q', 'r', 'eo', 'pf', 'hd', 'enq', 'h1', 'h32']
    xsb = 'WS.btake(U32.to_nat(N), FX.limbs(F.array__slots(U32, t)))'
    for K, view, cnt, elem, sh in (('1', 'PB.vview1', None, 'S.Unsigned{P.U8{}}', None), ('2', 'PB.vview2', 'PB.cnt2', 'S.Unsigned{P.U16{}}', '1n'),
                                   ('h', 'BLI.hview', 'BLI.cnth', 'S.ByteVector{32n}', '5n')):
        k = 'U32.to_nat(N)' if K == '1' else f'U32.to_nat(U32.shrn(N, {sh}))'
        R = f'S.Repeat{{{elem}}}'
        its = {'1': f'PB.it1({k}, {xsb})', '2': f'PB.it2({k}, {xsb})', 'h': f'WR.items({k}, F.array__slots(U32, t), 0n)'}[K]
        itsz = its.replace('F.array__slots(U32, t)', 'F.array__slots(U32, _)')
        if cnt:
            w(f'def hl{K}(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +L: Nat, +eo: {{o == O.Words{{F.array__thaw(U32, t), N}} : O.Words}},')
            w(f'    +hv: {{Nat.is_le({cnt}(o), L) == True{{}} : Bool}}) -> {{Nat.is_le({k}, L) == True{{}} : Bool}}:')
            w(f'  %Equal.cong(O.Words, U32, WO.len, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{Nat.is_le(U32.to_nat(U32.shrn(_, {sh})), L) == True{{}} : Bool}}')
            w('  hv')
            hvt = f'{{Nat.is_le({cnt}(o), L) == True{{}} : Bool}}'
            hvN = f'hl{K}(o, t, N, L, eo, hv)'
        else:
            hvt = '{Nat.is_le(U32.to_nat(WO.len(o)), L) == True{} : Bool}'
            hvN = 'LO.le_len(o, t, N, L, eo, hv)'
        w(f'def wl{K}(-o: O.Words, +L: Nat, +wf: LO.wfl(o), +hv: {hvt}) -> {{VD.root_valid({view}(o), S.ListOf{{{elem}, L}}) == True{{}} : Bool}}:')
        w('  match wf:')
        w('    case Inl{w0}:')
        for i, v in enumerate(WF0):
            w(f'      (+{v}, w{i + 1}) = ' + ('w0' if i == 0 else f'w{i}'))
        w('      (+hd, +en0) = w5')
        w(f'      %Equal.sym(O.Words, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{VD.root_valid({view}(_), S.ListOf{{{elem}, L}}) == True{{}} : Bool}}')
        w(f'      %Equal.sym(U32, N, 0, F.u32__injective(N, 0, en0)) : {{VD.root_valid({view}(O.Words{{F.array__thaw(U32, t), _}}), S.ListOf{{{elem}, L}}) == True{{}} : Bool}}')
        w('      %Equal.sym(Bool, Nat.is_le(0n, L), True{}, VO.zero_le(L)) : {Bool.and(_, True{}) == True{} : Bool}')
        w('      {==}')
        w('    case Inr{w0}:')
        for i, v in enumerate(WF1):
            w(f'      (+{v}, w{i + 1}) = ' + ('w0' if i == 0 else f'w{i}'))
        w('      (+room, +slack) = w11')
        w(f'      +hvN = {hvN}')
        w(f'      %Equal.sym(O.Words, o, O.Words{{F.array__thaw(U32, t), N}}, eo) : {{VD.root_valid({view}(_), S.ListOf{{{elem}, L}}) == True{{}} : Bool}}')
        w(f'      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :')
        w(f'        {{VD.root_valid(S.Sequence{{{itsz}}}, S.ListOf{{{elem}, L}}) == True{{}} : Bool}}')
        if K == 'h':
            rv = f'VO.items_valid({k}, F.array__slots(U32, t), 0n)'
            le = f'Equal.sym(Nat, {k}, VD.items_length({its}), VO.items_len({k}, F.array__slots(U32, t), 0n))'
            w(f'      %Equal.sym(Bool, VD.root_valid({its}, {R}), True{{}}, {rv}) :')
            w(f'        {{Bool.and(Nat.is_le(VD.items_length({its}), L), _) == True{{}} : Bool}}')
            w(f'      %Equal.sym(Nat, VD.items_length({its}), {k}, VO.items_len({k}, F.array__slots(U32, t), 0n)) :')
            w(f'        {{Bool.and(Nat.is_le(_, L), True{{}}) == True{{}} : Bool}}')
            w(f'      %Equal.sym(Bool, Nat.is_le({k}, L), True{{}}, hvN) : {{Bool.and(_, True{{}}) == True{{}} : Bool}}')
            w('      {==}')
        else:
            hd = f'VO.sc_dom(U32.to_nat(N), {xsb}, PB.vscope(N, q, r, dw, t, enq, h32, pf, room))'
            w(f'      %Equal.sym(Bool, VD.root_valid({its}, {R}), True{{}}, vit{K}({k}, {xsb}, {hd})) :')
            w(f'        {{Bool.and(Nat.is_le(VD.items_length({its}), L), _) == True{{}} : Bool}}')
            w(f'      %Equal.sym(Bool, Nat.is_le(VD.items_length({its}), L), True{{}}, F.nat__le_trans(VD.items_length({its}), {k}, L, lit{K}({k}, {xsb}), hvN)) :')
            w(f'        {{Bool.and(_, True{{}}) == True{{}} : Bool}}')
            w('      {==}')
        # the list lemma
        conj = ok_def('blist_obj.bend', f'ok_l{K}', 'BLI')
        E = 'SH.ListOf_element(s)'
        Lm = 'SH.ListOf_limit(s)'
        w(f'def vl{K}(-o: O.Words, +s: S.Schema, +depth: Nat, +rep: BLI.rep_l{K}(o, s), +ok: {{BLI.ok_l{K}(s, depth) == True{{}} : Bool}})')
        w(f'    -> {{VD.root_valid({view}(o), s) == True{{}} : Bool}}:')
        w('  (+wf, +r0) = rep')
        if K != '1':
            w('  (+eN, +hv) = r0')
        kn = and_lets(w, conj, 'ok')
        w(f'  %Equal.sym(S.Schema, s, S.ListOf{{{E}, {Lm}}}, SH.ListOf_shape(s, {kn[0]})) :')
        w(f'    {{VD.root_valid({view}(o), _) == True{{}} : Bool}}')
        if K == 'h':
            w(f'  %Equal.sym(S.Schema, {E}, S.ByteVector{{SH.ByteVector_length({E})}}, SH.ByteVector_shape({E}, {kn[1]})) :')
            w(f'    {{VD.root_valid({view}(o), S.ListOf{{_, {Lm}}}) == True{{}} : Bool}}')
            w(f'  %Equal.sym(Nat, SH.ByteVector_length({E}), 32n, WS.nat_eq(SH.ByteVector_length({E}), 32n, {kn[2]})) :')
            w(f'    {{VD.root_valid({view}(o), S.ListOf{{S.ByteVector{{_}}, {Lm}}}) == True{{}} : Bool}}')
        else:
            W = 'P.U8{}' if K == '1' else 'P.U16{}'
            w(f'  %Equal.sym(S.Schema, {E}, S.Unsigned{{SH.Unsigned_width({E})}}, SH.Unsigned_shape({E}, {kn[1]})) :')
            w(f'    {{VD.root_valid({view}(o), S.ListOf{{_, {Lm}}}) == True{{}} : Bool}}')
            w(f'  %Equal.sym(P.Width, SH.Unsigned_width({E}), {W}, {WSHAPE[K]}(SH.Unsigned_width({E}), {kn[2]})) :')
            w(f'    {{VD.root_valid({view}(o), S.ListOf{{S.Unsigned{{_}}, {Lm}}}) == True{{}} : Bool}}')
        w(f'  wl{K}(o, {Lm}, wf, ' + ('r0' if K == '1' else 'hv') + ')')
        w('')


REPLEMMA = [(r'PB\.rep_v(1|2|b)\(o, s\)', lambda m, d: f'VP.vv{m.group(1)}(o, s, {d}, rep, ok)'),
            (r'PK\.rep_v(4|8|16|32)\(o, s\)', lambda m, d: f'VP.vv{m.group(1)}(o, s, {d}, rep, ok)'),
            (r'PG\.rep_pl(1|2|b|4|8|16|32)\(o, s\)', lambda m, d: f'VP.vpl{m.group(1)}(o, s, rep, ok)'),
            (r'BO\.rep_bits\(o, s\)', lambda m, d: f'VO.vbits(o, s, {d}, rep, ok)'),
            (r'PBO\.rep_pbits\(o, s\)', lambda m, d: 'vpbits(o, s, rep, ok)')]


def emit_gnames_packed():
    """The generic names whose root law is over packed storage (root_gtypes*.bend: packed vectors,
    progressive lists, bit lists, progressive bit lists), each with its root law's hypotheses."""
    import re
    L = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/schema.bend as S',
         'import ../../spec/value_domain.bend as VD', 'import ./generic_specs.bend as Spec', 'import ./schema_shapes.bend as SH',
         'import ./packed_obj.bend as PK', 'import ./packed_bytes.bend as PB', 'import ./prog_list.bend as PG', 'import ./ulist_obj.bend as UL',
         'import ./bitlist_obj.bend as BO', 'import ./pbits_obj.bend as PBO', 'import ./valid_obj.bend as VO', 'import ./gvalid_packed.bend as VP', '',
         '# GENERATED by codegen/proofs/laws/valid_laws.py. Do not edit.',
         '# The generic packed-storage root views (packed vectors, progressive lists, bit lists,',
         '# progressive bit lists; root_gtypes*.bend) are structurally valid under the root laws\' hypotheses.', '',
         '# A progressive bit list is any list of bits.',
         'def vpbits(-o: O.Bits, +s: S.Schema, +rep: PBO.rep_pbits(o, s), +ok: {PBO.ok_pbits(s) == True{} : Bool})',
         '    -> {VD.root_valid(S.BitsValue{BO.bview(o)}, s) == True{} : Bool}:',
         '  %Equal.sym(S.Schema, s, S.ProgressiveBits{}, SH.ProgressiveBits_shape(s, ok)) : {VD.root_valid(S.BitsValue{BO.bview(o)}, _) == True{} : Bool}',
         '  {==}', '']
    status = {}
    for f in ('root_gtypes.bend', 'root_gtypes2.bend'):
        src = _unlight((OBJ / f).read_text())
        for m in re.finditer(r'^law (\w+)_root_correct:\n((?:  for .*\n)+)  (RR\.roots\((.*?), s, \[.*)$', src, re.M):
            n, binders, view = m.group(1), m.group(2), m.group(4)
            bs = [b.strip()[len('for '):] for b in binders.strip('\n').split('\n')]
            rep = [b for b in bs if b.startswith('+rep:')]
            if not rep:
                continue
            rept = rep[0][len('+rep: '):]
            call = None
            okm = re.search(r'^def ' + n + r'_ok\((.*?)\) -> \{(.*?) == True\{\} : Bool\}:\n  (.*)\n  \{==\}$', src, re.M)
            if not okm:
                continue
            okexpr = okm.group(2)
            dm = re.search(r', (\d+n)\)$', okexpr)
            d = dm.group(1) if dm else None
            for pat, mk in REPLEMMA:
                mm = re.fullmatch(pat, rept)
                if mm:
                    call = mk(mm, d)
                    break
            if call is None:
                continue
            L.append(f'def {n}_vok({okm.group(1)}) -> {{{okexpr} == True{{}} : Bool}}:')
            L.append(f'  {okm.group(3)}')
            L.append('  {==}')
            L.append(f'def {n}_root_valid(' + ', '.join(b for b in bs if not b.startswith('-h')) + f') -> {{VD.root_valid({view}, s) == True{{}} : Bool}}:')
            L.append(f'  ' + call.replace('ok)', f'{n}_vok(s, es))'))
            L.append('')
            status[n] = 'valid'
    return '\n'.join(L) + '\n', status


def main():
    global TYPES
    TYPES = emit_types()
    outs = [(OBJ / 'gvalid_gnames.bend', emit_gnames()), (OBJ / 'gvalid_leaves.bend', emit_leaves()), (OBJ / 'gvalid_words.bend', emit_words()), (OBJ / 'gvalid_types.bend', TYPES[0]), (OBJ / 'gvalid_packed.bend', emit_packed_lib()), (OBJ / 'gvalid_gpacked.bend', emit_gnames_packed()[0])] + ([] if False else sorted(TYPES[2].items())) + sorted(emit_gbits().items()) + sorted(emit_gtypes()[0].items())
    from codegen.impl import runtime_refs as RR  # the runtime split: the modules import the per-name files they use
    outs = RR.rewire_out(outs)
    if '--check' in sys.argv:
        for path, text in outs:
            if not path.exists() or path.read_text() != text:
                sys.exit(f'{path.relative_to(ROOT)} is stale; run codegen/proofs/laws/valid_laws.py')
        print('validity laws are current')
        return
    for path, text in outs:
        if not path.exists() or path.read_text() != text:
            path.write_text(text)


if __name__ == '__main__':
    main()
