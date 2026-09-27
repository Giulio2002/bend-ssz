"""The third variable-size worker's share (the root worker: u-lists and unions) of the e2e bridges (codegen/e2e_bridge.py imports it).

codegen/e2e_bridge.py owns the templates, the shared support modules (e2e_load, e2e_cap, e2e_emit,
e2e_ulist) and the manifest; this module only adds per-name entries and any new shared module:

  VDEC_VIEWS[X]   = {'view': 'RT.v_X', 'imports': [...], 'text': ...}   (ii)/(iii): the view lemma vv
  VROOT_SHAPES[X] = f(R, X) -> text                                     (iv): the rebuild from rep
  VENC_SHAPES[X]  = f(R, X) -> text                                     (i)
  SUPPORT_OUT     = {'e2e_<name>.bend': text}                           new shared modules
  VENC_PREMISE[X] = '...'                                               (i)'s premise text in the manifest

X is the generated name (api_map.json), R the readable one (names.py). A name counts as bridged in the
manifest's variable_size section once it has all three; see e2e_bridge's DataColumnsByRootIdentifier
entries for the pattern. Texts may import ../types/fulu_obj.bend as T: e2e_bridge rewires them.

The decode template reads from the name's decode facade: the decoder (T.<fn>), the object type
(Maybe<&1, ..>; override with VDEC_VIEWS[X]['otype']), the schema (Spec or GS), and whether OBJ / VAL
take the depth (OBJ(d, t, n)); it calls the view lemma with decode_accept's own hypotheses:
  vv(+d, +t, +n, +pf: perfect(d, t), +hd: d < bound, +hn: to_nat(n) <= quad(pow2(d)), +hchk: CHK(t, n) == True)
    -> {view(OBJ(..)) == VAL(..)}
"""

VDEC_VIEWS = {}
VROOT_SHAPES = {}
VENC_SHAPES = {}
SUPPORT_OUT = {}
VENC_PREMISE = {}

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _dc_module(R):
    """The codec law module (the decode facade's DC) of the readable name R."""
    s = (ROOT / 'proofs/api' / f'{R}_decode_ssz_proof_generated.bend').read_text()
    imp = dict((a, p) for p, a in re.findall(r'^import \.\./obj/(\S+) as (\w+)$', s, re.M))
    m = re.search(r'\+hchk: \{(\w+)\.CHK\(t, n\)', s)
    return ROOT / 'proofs/obj' / imp[m.group(1)]


# ---- (ii)/(iii): names with one u64 list field and fixed fields read from slots ----
# The codec law's value XV(t, k, W) has the list's value S.Sequence{VS.uitems(k, W)} at the list
# field; the object's view has UL.uview(O.Words{thaw(MM), LL}) there and evaluates to XV's fixed
# field values. vv rewrites the list field alone (e2e_ulist.uvw), the rest converts.
def ulist_view(R, X):
    src = _dc_module(R).read_text()
    xv = re.search(r'^def XV\(\+t: FD\.array__Tree<U32>, \+k: Nat, \+W: List<&2, U32>\) -> S\.Value: (.*)$', src, re.M).group(1)
    fs = re.search(r'^def CHK\(\+t: FD\.array__Tree<U32>, \+n: U32\) -> Bool: chk3\(U32\.is_le\((\d+), n\)', src, re.M).group(1)
    hole = 'S.Sequence{VS.uitems(k, W)}'
    assert xv.count(hole) == 1, X
    ctx = xv.replace(hole, 'z').replace('VS.', 'VSP.')
    words = 'O.Words{FD.array__thaw(U32, DC.MM(t, n)), DC.LL(n)}'
    text = f'''# ---- the view of a decoded object is the codec law's value ----

def cnt(+n: U32, +hc: {{DC.whole(DC.LL(n)) == True{{}} : Bool}}) -> {{U32.to_nat(U32.shrn(DC.LL(n), 3n)) == DC.CQ(n) : Nat}}:
  Equal.trans(Nat, U32.to_nat(U32.shrn(DC.LL(n), 3n)), VD.s_rng(3n, U32.to_nat(DC.LL(n))), DC.CQ(n), VD.shrk(3n, DC.LL(n)),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(DC.LL(n))), VD.s_rng(3n, VSP.x8(DC.CQ(n))), DC.CQ(n),
      Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(DC.LL(n)), VSP.x8(DC.CQ(n)), DC.eLc(n, hc)), U.r8(DC.CQ(n))))

def wh(+t: FD.array__Tree<U32>, +n: U32, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{DC.whole(DC.LL(n)) == True{{}} : Bool}}:
  +a = U32.is_le({fs}, n)
  +b = U32.is_eq(DC.SPO(t), {fs})
  +c = DC.whole(U32.sub(n, DC.SPO(t)))
  +epo = FD.u32alg__eq_of(DC.SPO(t), {fs}, DC.chk_b(a, b, c, hchk))
  FD.logic__subst(U32, z => {{DC.whole(U32.sub(n, z)) == True{{}} : Bool}}, DC.SPO(t), {fs}, epo, DC.chk_c(a, b, c, hchk))

def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(t, n)) == DC.VAL(t, n) : S.Value}}:
  Equal.cong(S.Value, S.Value, z => {ctx}, UL.uview({words}),
    S.Sequence{{VSP.uitems(DC.CQ(n), FD.array__slots(U32, DC.MM(t, n)))}}, U.uvw(DC.MM(t, n), DC.LL(n), DC.CQ(n), cnt(n, wh(t, n, hchk))))

'''
    return {'view': f'RT.v_{X}',
            'imports': ['import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vspec.bend as VSP', 'import ../proofs/obj/vbuf.bend as VB',
                        'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/root_types.bend as RT', 'import ./e2e_ulist.bend as U'],
            'text': text}


VDEC_VIEWS['IndexedAttestation'] = ulist_view('FuluIndexedAttestation', 'IndexedAttestation')


# ---- (iv): names with one u64 list field, from the root law's representation invariant ----
def _rep(X, rt='root_types'):
    """The rep_X of proofs/obj/<rt>.bend: the fixed fields' witnesses [(x, type)], the constructor's argument
    texts (the list field as pj_X_i(o)), the list field's index, and after the object's equation, the number
    of conjuncts and the list's conjunct's index."""
    src = (ROOT / f'proofs/obj/{rt}.bend').read_text()
    body = re.search(rf'^def rep_{X}\(o: \w+\.{X}, \+s: S\.Schema\) -> Data:\n  (.*)$', src, re.M).group(1)
    wit = re.findall(r'DK\.Ex\((?:(\w+)\.)?(\w+), (x\d+) =>', body)
    cons = re.search(r'\{o == \w+\.' + X + r'\{(.*?)\} : \w+\.' + X + r'\}', body)
    args = [a.strip() for a in cons.group(1).split(', ')]
    li = [i for i, a in enumerate(args) if a.startswith(f'pj_{X}_')]
    assert len(li) == 1 and len(args) == len(wit) + 1, (X, args, wit)
    rest = body[cons.end():].lstrip(', ')
    conj = []
    while rest.startswith('DK.P2('):
        inner = rest[len('DK.P2('):]
        dep, k = 0, 0
        while not (inner[k] == ',' and dep == 0):
            dep += {'(': 1, ')': -1, '{': 1, '}': -1}.get(inner[k], 0)
            k += 1
        conj.append(inner[:k])
        rest = inner[k + 2:]
    conj.append(rest.rstrip(')'))
    lc = [j for j, c in enumerate(conj) if c.startswith(('UL.rep_ul(', 'BLI.rep_l2('))]
    assert len(lc) == 1, conj
    return [(x, f'T.{ty}' if m else ty) for m, ty, x in wit], args, li[0], len(conj), lc[0]


def vroot_ulist(R, X, rt='root_types', gv='gvalid_types', spec='../spec/fulu_schemas.bend', tobj='fulu_obj'):
    wit, args, i, nconj, lc = _rep(X, rt)
    D = f'T.{X}'
    WORDS = 'O.Words{FD.array__thaw(U32, t), N}'
    PJ = f'RT.pj_{X}_{i}(o)'

    def obj(field):
        return f'{D}{{' + ', '.join(field if k == i else a for k, a in enumerate(args)) + '}'
    O1 = obj(WORDS)
    RX = lambda o: f'D.bytes(Pair.snd({D}, D.Digest, Pair.snd(B.Buf, {D} & D.Digest, T.{X}_hash_tree_root(h, {o}))))'  # noqa: E731
    G = lambda o: f'{{Some{{{RX(o)}}} == API.hash_tree_root(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    XS = ', '.join(f'+{x}: {ty}' for x, ty in wit)
    XA = ', '.join(x for x, _ in wit)
    # rep = Ex x.. (P2 eo (P2 wf ..)): unpack the witnesses in order
    un, cur = [], 'rep'
    for k, (x, _) in enumerate(wit):
        un.append(f'  (+{x}, +r{k}) = {cur}')
        cur = f'r{k}'
    un.append(f'  (+eo, +q1) = {cur}')
    cq = 'q1'
    if nconj > 1:
        for j_ in range(nconj - 1):
            un.append(f'  (+c{j_}, +q{j_ + 2}) = {cq}')
            cq = f'q{j_ + 2}'
        lcv = f'c{lc}' if lc < nconj - 1 else cq
    else:
        lcv = 'q1'
    un.append(f'  (+wf, +{"q2" if nconj == 1 else "z9"}) = {lcv}')

    def case(fields):
        return '\n'.join(f'      ({f}, w{k + 1}) = {"w" if k == 0 else "w" + str(k)}' for k, f in enumerate(fields))
    rb = (f'      rt2(h, o, rep, {XA}, t, N, Equal.trans({D}, o, {obj(PJ)}, {O1}, eo,\n'
          f'        Equal.cong(O.Words, {D}, z => {obj("z")}, {PJ}, {WORDS}, ew)))')
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', f'import ../types/{tobj}.bend as T', 'import ../types/schema.bend as S',
            f'import {spec} as Spec', 'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            f'import ../proofs/obj/{rt}.bend as RT', f'import ../proofs/obj/{gv}.bend as GV', 'import ./e2e_support.bend as E']
    return '\n'.join(imps) + f"""

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (variable size): the object API's root is END_TO_END's hash_tree_root, for every object the
# root law represents (rep_{X}: its list field's words in a perfect tree of depth below 32).

def rt1(h: B.Buf, {XS}, +t: FD.array__Tree<U32>, +N: U32, +rep: RT.rep_{X}({O1}, Spec.{X}())) -> {G(O1)}:
  E.root_legal(Spec.{X}(), RT.v_{X}({O1}), VS.public_sound(Spec.{X}(), {{==}}), {RX(O1)},
    GV.{X}_root_valid({O1}, Spec.{X}(), {{==}}, rep), RT.{X}_root_correct(h, {O1}, Spec.{X}(), {{==}}, rep))

# the object as rep's witnesses name it
def rt2(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {XS}, +t: FD.array__Tree<U32>, +N: U32,
    +eo: {{o == {O1} : {D}}}) -> {G('o')}:
  %Equal.sym({D}, o, {O1}, eo) : {G('_')}
  rt1(h, {XA}, t, N, FD.logic__subst({D}, z => RT.rep_{X}(z, Spec.{X}()), o, {O1}, eo, rep))

# (iv)
def {R}_e2e_root(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}())) -> {G('o')}:
""" + '\n'.join(un) + f"""
  match wf:
    case Inl{{w}}:
{case(['+t', '+dw', '+N', '+ew'])}
{rb}
    case Inr{{w}}:
{case(['+t', '+dw', '+N', '+q', '+r', '+ew'])}
{rb}
"""


VROOT_SHAPES['IndexedAttestation'] = vroot_ulist
VROOT_SHAPES['Gc465214E502'] = lambda R, X: vroot_ulist(R, X, 'root_gtypes', 'gvalid_gtypes', '../proofs/obj/generic_specs.bend', 'generic_obj')


# ---- (i): names with one u64 list field, through the encode laws (var_enc) and the output path ----
def _spec_at(X, path):
    """The schema term at SH-path `path` (e.g. SH.Chain_head(SH.Container_fields(s))) of spec/fulu_schemas.bend's
    X(), with its own sub-schemas left as Spec.<name>() calls: the form a {==} meets without evaluating."""
    src = (ROOT / 'spec/fulu_schemas.bend').read_text()
    defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.*)$', src, re.M))

    def resolve(t):
        m = re.fullmatch(r'(\w+)\(\)', t.strip())
        return resolve(defs[m.group(1)]) if m else t.strip()
    ops = re.findall(r'SH\.(\w+)\(', path)[::-1]
    t = resolve(f'{X}()')
    for op in ops:
        n = _parse(t)
        if op == 'Container_fields':
            assert n[0] == 'T.Container', t
            t = resolve(_render(n[1][1]))
        elif op == 'Chain_head':
            assert n[0] == 'T.Chain', t
            t = resolve(_render(n[1][0]))
        elif op == 'Chain_tail':
            assert n[0] == 'T.Chain', t
            t = resolve(_render(n[1][1]))
        else:
            raise SystemExit(op)
    t = re.sub(r'\b(Schema\d+|\w+)\(\)', lambda m: f'Spec.{m.group(1)}()', t)
    return t.replace('T.', 'S.')


def _parse(t):
    """A constructor term 'M.C{a, b, ..}' as (ctor, [children]); a leaf name as (name, None)."""
    t = t.strip()
    if '{' not in t:
        return (t, None)
    head, body = t[:t.index('{')], t[t.index('{') + 1:-1]
    if not body.strip():
        return (head, [])
    parts, dep, cur = [], 0, ''
    for ch in body:
        if ch in '{([':
            dep += 1
        elif ch in '})]':
            dep -= 1
        if ch == ',' and dep == 0:
            parts.append(cur)
            cur = ''
        else:
            cur += ch
    parts.append(cur)
    return (head, [_parse(p) for p in parts])


def _render(n):
    h, ch = n
    return h if ch is None else h + '{' + ', '.join(_render(c) for c in ch) + '}'


def venc_ulist(R, X):
    import lim_pow as LPW
    dcm = _dc_module(R)
    enc = (dcm.parent / (dcm.stem + '_enc.bend')).read_text()
    ev = re.search(r'^def encode_eval\((.*?)\)\n    -> \{(\w+)\.' + X + r'_encode\((.*?)\) == \(.*?B\.Buf\{FD\.array__thaw\(U32, (TD\d+)\(', enc, re.M | re.S)
    WS = re.findall(r'\+(w\d+): U32', ev.group(1))
    WA = ', '.join(WS)
    EMOD = ev.group(2)
    OBJT = ev.group(3).replace('FD.array__thaw(U32, T)', 'FD.array__thaw(U32, t)')
    TD = ev.group(4)
    PFD = 'pfD' + TD[2:]
    FS = int(re.search(r'^def SFS\(\+N: U32\) -> U32: U32\.add\((\d+), N\)', enc, re.M).group(1))
    LIMN = re.search(r'\+hc: \{Nat\.is_le\(c, (.*?)\) == True\{\} : Bool\}', ev.group(1)).group(1)
    xe = re.search(r'^def XE\(.*?\+k: Nat, \+W: List<&2, U32>\) -> S\.Value: (.*)$', enc, re.M).group(1)
    hole = 'S.Sequence{VS.uitems(k, W)}'
    assert xe.count(hole) == 1
    XCTX = xe.replace(hole, 'z').replace('F.limbs(', 'SF.limbs(').replace('VS.', 'VSP.')
    timps = [f'import ../types/{p} as {a}' for p, a in re.findall(r'^import \.\./\.\./types/(\S+_generated\.bend) as (\w+)$', enc, re.M)]
    D = re.match(r'(\w+_d\.' + X + r')\{', OBJT).group(1)
    ENC = f'{EMOD}.{X}_encode'
    wit, args, li, _nc, _lc = _rep(X)
    PJ = f'RT.pj_{X}_{li}(o)'
    WORDS = 'O.Words{FD.array__thaw(U32, t), N}'
    tree = _parse(OBJT)
    assert _render(tree[1][li]) == WORDS, OBJT
    # the bounds: x8(LIM) = 2^q, FS + x8(LIM) <= 2^r; e2e_cap's forms quad(2^(q-2)), quad(2^(r-2))
    LP = LPW.LimPow(LIMN, alias='VBG')
    if LP.big:
        X8 = LP.x8()
        q = X8.s
        r = LP.bound(LP.add(FS, X8))
        P1 = LP.le_pow2n(LP.add(FS, X8), r).replace('VS.', 'VSP.')
        P3 = LP.le_spow2(X8, q).replace('VS.', 'VSP.')
    else:
        LIM = int(LIMN.rstrip('n'))
        q = (8 * LIM - 1).bit_length()
        assert 8 * LIM == 1 << q
        r = (FS + 8 * LIM - 1).bit_length()
        P1 = P3 = None
    K, Q = r - 2, q - 2
    assert K < 29 and Q < 29
    GOAL = lambda o: f'{{Some{{E.obytes(Pair.snd({D}, B.Buf, {ENC}({o})))}} == API.serialize(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    O1 = OBJT
    O1pj = OBJT.replace(WORDS, PJ)
    EN = lambda s: s  # noqa: E731
    TDc = f'EN.{TD}({WA}, N, t)'
    SFS = 'EN.SFS(N)'
    hK = f'{{Nat.is_le(U32.to_nat({SFS}), A.quad(FD.spec_common__pow2({K}n))) == True{{}} : Bool}}'
    L = []
    w = L.append
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../spec/fulu_schemas.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../spec/codec.bend as Encoding', 'import ../proofs/obj/spec_fixed.bend as SF', 'import ../proofs/obj/vspec.bend as VSP',
            'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vcopy.bend as VC', 'import ../proofs/obj/ulist_obj.bend as UL',
            'import ../proofs/obj/root_types.bend as RT', f'import ../proofs/obj/{dcm.stem}_enc.bend as EN'] + timps + [
            'import ./e2e_support.bend as E', 'import ./e2e_cap.bend as C', 'import ./e2e_emit.bend as EM', 'import ./e2e_ulist.bend as U',
            'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/words_spec.bend as WS', 'import ../proofs/obj/schema_shapes.bend as SH',
            'import ../proofs/obj/dk.bend as DK', 'import ../spec/primitives.bend as SP'] + (['import ../proofs/obj/vbig.bend as VBG'] if LP.big else [])
    w('\n'.join(imps))
    w(f'''
# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (variable size): the object API's encoder's bytes are END_TO_END's serialize of the object's view,
# for every object the root law represents (rep) whose list storage is at depth below 31 (hs).

def vx({', '.join('+' + x + ': U32' for x in WS)}, +t: FD.array__Tree<U32>, +N: U32, +c: Nat, +ecq: {{U32.to_nat(U32.shrn(N, 3n)) == c : Nat}}) -> {{RT.v_{X}({O1}) == EN.XE({WA}, c, FD.array__slots(U32, t)) : S.Value}}:
  Equal.cong(S.Value, S.Value, z => {XCTX}, UL.uview({WORDS}),
    S.Sequence{{VSP.uitems(c, FD.array__slots(U32, t))}}, U.uvw(t, N, c, ecq))
''')
    if LP.big:
        w(f'''# the bounds, without evaluating the limit: {FS} + 8 * limit <= 2^{r} = 4 * 2^{K}, 8 * limit = 2^{q} = 4 * 2^{Q}
def p2() -> {{Nat.is_le(O.pow2n({r}n), A.quad(FD.spec_common__pow2({K}n))) == True{{}} : Bool}}:
  %Equal.sym(Nat, A.quad(FD.spec_common__pow2({K}n)), FD.spec_common__pow2({r}n), VBG.quadpw({K}n, {r}n, {{==}})) : {{Nat.is_le(O.pow2n({r}n), _) == True{{}} : Bool}}
  %VD.s_pow2_eq({r}n) : {{Nat.is_le(_, FD.spec_common__pow2({r}n)) == True{{}} : Bool}}
  FD.nat__le_refl(FD.spec_common__pow2({r}n))

def p3() -> {{Nat.is_le(VSP.x8({LIMN}), A.quad(FD.spec_common__pow2({Q}n))) == True{{}} : Bool}}:
  %Equal.sym(Nat, A.quad(FD.spec_common__pow2({Q}n)), FD.spec_common__pow2({q}n), VBG.quadpw({Q}n, {q}n, {{==}})) : {{Nat.is_le(VSP.x8({LIMN}), _) == True{{}} : Bool}}
  {P3}
''')
        C1, C2 = P1, 'p2()'
    else:
        C1, C2 = '{==}', '{==}'
    w(f'''# the encoder's buffer: its bytes, and within e2e_cap's bounds ({FS} + N <= 2^{r})
def hK(+N: U32, +c: Nat, +ec: {{U32.to_nat(N) == VSP.x8(c) : Nat}}, +hc: {{Nat.is_le(c, {LIMN}) == True{{}} : Bool}}) -> {hK}:
  +hN = FD.logic__subst(Nat, z => {{Nat.is_le(z, VSP.x8({LIMN})) == True{{}} : Bool}}, VSP.x8(c), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), VSP.x8(c), ec), VSP.x8_mono(c, {LIMN}, hc))
  +hs = FD.nat__le_trans(Nat.add({FS}n, U32.to_nat(N)), Nat.add({FS}n, VSP.x8({LIMN})), O.pow2n({r}n), Order.add_left({FS}n, U32.to_nat(N), VSP.x8({LIMN}), hN), {C1})
  +es = VD.s_add_nat({FS}, N, {r}n, {{==}}, hs)
  %Equal.sym(Nat, U32.to_nat(U32.add({FS}, N)), Nat.add({FS}n, U32.to_nat(N)), es) : {{Nat.is_le(_, A.quad(FD.spec_common__pow2({K}n))) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add({FS}n, U32.to_nat(N)), O.pow2n({r}n), A.quad(FD.spec_common__pow2({K}n)), hs, {C2})

def eby({', '.join('+' + x + ': U32' for x in WS)}, +t: FD.array__Tree<U32>, +N: U32, +h: {hK})
    -> {{E.obytes(B.Buf{{FD.array__thaw(U32, {TDc}), {SFS}}}) == VSP.bt(U32.to_nat({SFS}), SF.limbs(FD.array__slots(U32, {TDc}))) : +List<U32>}}:
  EM.ob(EN.DO(N), {TDc}, {SFS}, EN.{PFD}({WA}, N, t),
    FD.nat__le_lt_trans(B.capacity({SFS}), {K}n, 29n, C.cap_le({SFS}, {K}n, {{==}}, h), {{==}}), C.cap_q({SFS}, {K}n, {{==}}, h))
''')
    SER = lambda v: f'API.serialize(Spec.{X}(), {v})'  # noqa: E731
    XEV = f'EN.XE({WA}, c, FD.array__slots(U32, t))'
    BT = f'VSP.bt(U32.to_nat({SFS}), SF.limbs(FD.array__slots(U32, {TDc})))'
    w(f'''# (i) on an object with its list stored in a perfect tree t of depth dw < 31 holding N = 8c bytes
def a1({', '.join('+' + x + ': U32' for x in WS)}, +dw: Nat, +t: FD.array__Tree<U32>, +N: U32, +c: Nat, +pf: {{FD.array__perfect(U32, dw, t) == True{{}} : Bool}}, +hdw: {{Nat.is_lt(dw, 31n) == True{{}} : Bool}},
    +ec: {{U32.to_nat(N) == VSP.x8(c) : Nat}}, +hc: {{Nat.is_le(c, {LIMN}) == True{{}} : Bool}}, +hroom: {{Nat.is_le(Nat.add(VC.NW(N), 0n), FD.spec_common__pow2(dw)) == True{{}} : Bool}},
    +ecq: {{U32.to_nat(U32.shrn(N, 3n)) == c : Nat}}) -> {GOAL(O1)}:
  %Equal.sym({D} & B.Buf, {ENC}({O1}), ({O1}, B.Buf{{FD.array__thaw(U32, {TDc}), {SFS}}}), EN.encode_eval({WA}, dw, t, N, c, pf, hdw, ec, hc, hroom)) :
    {{Some{{E.obytes(Pair.snd({D}, B.Buf, _))}} == {SER(f'RT.v_{X}({O1})')} : Maybe<&2, +List<U32>>}}
  %Equal.sym(+List<U32>, E.obytes(B.Buf{{FD.array__thaw(U32, {TDc}), {SFS}}}), {BT}, eby({WA}, t, N, hK(N, c, ec, hc))) :
    {{Some{{_}} == {SER(f'RT.v_{X}({O1})')} : Maybe<&2, +List<U32>>}}
  %Equal.sym(S.Value, RT.v_{X}({O1}), {XEV}, vx({WA}, t, N, c, ecq)) :
    {{Some{{{BT}}} == {SER('_')} : Maybe<&2, +List<U32>>}}
  Equal.sym(Maybe<&2, +List<U32>>, {SER(XEV)}, Some{{{BT}}},
    Equal.trans(Maybe<&2, +List<U32>>, {SER(XEV)}, Encoding.encoding_for_legal_type(Spec.{X}(), {XEV}), Some{{{BT}}},
      E.serialize_legal(Spec.{X}(), {XEV}, VS.public_sound(Spec.{X}(), {{==}})),
      EN.encode_spec({WA}, dw, t, N, c, pf, hdw, ec, hc, hroom)))
''')
    # the list field's premises, as the root law's invariant states them
    rl = (ROOT / 'proofs/obj/root_types.bend').read_text().split(f'def rep_{X}(')[1].split('\n')[1]
    j0 = rl.index(f'UL.rep_ul(pj_{X}_{li}(o), ') + len(f'UL.rep_ul(pj_{X}_{li}(o), ')
    j, dep = j0, 0
    while not (rl[j] == ')' and dep == 0):
        dep += {'(': 1, ')': -1}.get(rl[j], 0)
        j += 1
    LIMS = rl[j0:j]
    LIMS = LIMS.replace('(s)', f'(Spec.{X}())')
    ELEN = f'+elen: {{U32.to_nat(WO.len({PJ})) == O.e8(UL.ucnt({PJ})) : Nat}}'
    HLIM = f'+hlim: {{Nat.is_le(UL.ucnt({PJ}), SH.ListOf_limit({LIMS})) == True{{}} : Bool}}'
    HS = f'+hs: U.sd({PJ})'
    HCW, HCE = '', ''
    if LP.big:
        # the limit as the spec states it, moved to the laws' form by rewriting (no evaluation of the limit)
        LSCH = _spec_at(X, LIMS)
        ln = _parse(LSCH)
        assert ln[0] == 'S.ListOf' and _render(ln[1][1]) == LIMN, (LSCH, LIMN)
        ELT = _render(ln[1][0])
        HCW, HCE = 'hcl(c, ', ')'
        w(f'''# the list's limit, read through the spec's schema without evaluating it
def lim_of(+e: S.Schema, +n: Nat) -> {{SH.ListOf_limit(S.ListOf{{e, n}}) == n : Nat}}: {{==}}

def eH() -> {{{LIMS} == {LSCH} : S.Schema}}: {{==}}

def hcl(+c: Nat, +h: {{Nat.is_le(c, SH.ListOf_limit({LIMS})) == True{{}} : Bool}}) -> {{Nat.is_le(c, {LIMN}) == True{{}} : Bool}}:
  %lim_of({ELT}, {LIMN}) : {{Nat.is_le(c, _) == True{{}} : Bool}}
  %eH() : {{Nat.is_le(c, SH.ListOf_limit(_)) == True{{}} : Bool}}
  h
''')
    # hN8: N <= 4 * 2^Q (e2e_cap's nw)
    hN8 = (f'FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(FD.spec_common__pow2({Q}n))) == True{{}} : Bool}}, VSP.x8(c), U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), VSP.x8(c), ec), '
           + (f'FD.nat__le_trans(VSP.x8(c), VSP.x8({LIMN}), A.quad(FD.spec_common__pow2({Q}n)), VSP.x8_mono(c, {LIMN}, hc), p3()))' if LP.big else f'VSP.x8_mono(c, {LIMN}, hc))'))
    common = f'''      +c = U32.to_nat(U32.shrn(N, 3n))
      +el = FD.logic__subst(O.Words, z => {{U32.to_nat(WO.len(z)) == O.e8(UL.ucnt(z)) : Nat}}, {PJ}, {WORDS}, ew, elen)
      +ec = Equal.trans(Nat, U32.to_nat(N), O.e8(c), VSP.x8(c), el, Equal.sym(Nat, VSP.x8(c), O.e8(c), U.x8e(c)))
      +hc = {HCW}FD.logic__subst(O.Words, z => {{Nat.is_le(UL.ucnt(z), SH.ListOf_limit({LIMS})) == True{{}} : Bool}}, {PJ}, {WORDS}, ew, hlim){HCE}
      +hN8 = {hN8}
      +enw = Equal.trans(Nat, Nat.add(VC.NW(N), 0n), VC.NW(N), C.nwn(U32.to_nat(N)), FD.nat__add_zero(VC.NW(N)), C.nw(N, {Q}n, {{==}}, hN8))'''
    eo_step = (f'      %Equal.sym({D}, o, {O1}, Equal.trans({D}, o, {O1pj}, {O1}, eo, Equal.cong(O.Words, {D}, z => {OBJT.replace(WORDS, "z")}, {PJ}, {WORDS}, ew))) : {GOAL("_")}\n'
               f'      a1({WA}, dw, t, N, c, pf, hdw, ec, hc, hroom, {{==}})')
    # the destructuring chain: from rep's witnesses down to the words, one match per def
    nodes = {}   # id -> (ctor, [child ids]) ; leaves: (name, None)

    def reg(n):
        i_ = len(nodes)
        nodes[i_] = None
        nodes[i_] = (n[0], None if n[1] is None else [reg(c) for c in n[1]])
        return i_
    top = [reg(c) for c in tree[1]]
    xi = iter(x for x, _ in wit)
    vname = {t_: next(xi) for k_, t_ in enumerate(top) if k_ != li}
    fresh = iter(f'y{j_}' for j_ in range(10000))
    opened = set()

    def rend(i_):
        h_, ch_ = nodes[i_]
        if ch_ is None:
            return h_
        if i_ not in opened:
            return vname[i_]
        return h_ + '{' + ', '.join(rend(c) for c in ch_) + '}'

    def objtext():
        return f'{D}{{' + ', '.join(PJ if k_ == li else rend(t_) for k_, t_ in enumerate(top)) + '}'

    def front():
        out = []

        def go(i_):
            h_, ch_ = nodes[i_]
            if ch_ is None:
                out.append((h_, 'U32'))
            elif i_ not in opened:
                out.append((vname[i_], h_))
            else:
                for c in ch_:
                    go(c)
        for k_, t_ in enumerate(top):
            if k_ != li:
                go(t_)
        return out

    def sig(fr):
        return ', '.join(f'+{n_}: {ty_}' for n_, ty_ in fr)

    def argl(fr):
        return ', '.join(n_ for n_, _ in fr)
    order = []

    def todo(i_):
        h_, ch_ = nodes[i_]
        if ch_ is not None:
            order.append(i_)
            for c in ch_:
                todo(c)
    for k_, t_ in enumerate(top):
        if k_ != li:
            todo(t_)
    names = [f'e{j_ + 1}' for j_ in range(len(order))] + ['ew0']
    chain = []
    w = chain.append
    for j_, i_ in enumerate(order):
        fr, ot = front(), objtext()
        h_, ch_ = nodes[i_]
        for c in ch_:
            if nodes[c][1] is not None:
                vname[c] = next(fresh)
        pat = ', '.join('+' + (nodes[c][0] if nodes[c][1] is None else vname[c]) for c in ch_)
        var = vname[i_]
        opened.add(i_)
        nfr = front()
        w(f'def {names[j_]}(-o: {D}, {sig(fr)}, +eo: {{o == {ot} : {D}}},\n    {ELEN}, {HLIM}, {HS}) -> {GOAL("o")}:')
        w(f'  match {var}:')
        w(f'    case {h_}{{{pat}}}: {names[j_ + 1]}(o, {argl(nfr)}, eo, elen, hlim, hs)')
        w('')
    w = L.append
    w(f'''def ew0(-o: {D}, {', '.join('+' + x + ': U32' for x in WS)}, +eo: {{o == {O1pj} : {D}}},
    {ELEN}, {HLIM}, {HS}) -> {GOAL("o")}:
  match hs:
    case Inl{{s}}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+ew, s4) = s3
      (+pf, s5) = s4
      (+hdw, +en0) = s5
{common}
      +hroom = FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dw)) == True{{}} : Bool}}, 0n, Nat.add(VC.NW(N), 0n),
        Equal.sym(Nat, Nat.add(VC.NW(N), 0n), 0n, Equal.trans(Nat, Nat.add(VC.NW(N), 0n), C.nwn(U32.to_nat(N)), 0n, enw, Equal.cong(Nat, Nat, z => C.nwn(z), U32.to_nat(N), 0n, en0))),
        Order.zero_le(FD.spec_common__pow2(dw)))
{eo_step}
    case Inr{{s}}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+q, s4) = s3
      (+r, s5) = s4
      (+ew, s6) = s5
      (+pf, s7) = s6
      (+hdw, s8) = s7
      (+eN, s9) = s8
      (+hr0, s10) = s9
      (+hr32, s11) = s10
      (+hcap, +bz) = s11
{common}
      +hq = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(O.e8(1n+q))) == True{{}} : Bool}}, Nat.add(r, WS.e32(q)), U32.to_nat(N),
        Equal.sym(Nat, U32.to_nat(N), Nat.add(r, WS.e32(q)), Equal.trans(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), Nat.add(r, WS.e32(q)), eN, FD.nat__add_comm(WS.e32(q), r))),
        Order.add_right(r, 32n, WS.e32(q), hr32))
      +hroom = FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dw)) == True{{}} : Bool}}, C.nwn(U32.to_nat(N)), Nat.add(VC.NW(N), 0n),
        Equal.sym(Nat, Nat.add(VC.NW(N), 0n), C.nwn(U32.to_nat(N)), enw),
        FD.nat__le_trans(C.nwn(U32.to_nat(N)), O.e8(1n+q), FD.spec_common__pow2(dw), C.nle(U32.to_nat(N), O.e8(1n+q), hq), hcap))
{eo_step}
''')
    # the chain callee-first (a def may only call the ones above it)
    blocks, cur_b = [], []
    for ln in chain:
        if ln.startswith('def ') and cur_b:
            blocks.append(cur_b)
            cur_b = []
        cur_b.append(ln)
    blocks.append(cur_b)
    for b_ in reversed(blocks):
        L.extend(b_)
    un, cur = [], 'rep'
    for k, (x, _) in enumerate(wit):
        un.append(f'  (+{x}, +r{k}) = {cur}')
        cur = f'r{k}'
    first = names[0]
    w(f'''# (i): for every object the root law represents, its list field stored at depth below 31 (hs)
def {R}_e2e_encode(-o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {HS}) -> {GOAL("o")}:
''' + '\n'.join(un) + f'''
  (+eo, +q1) = {cur}
  (+wf, +q2) = q1
  (+elen, +hlim) = q2
  {first}(o, {', '.join(x for x, _ in wit)}, eo, elen, hlim, hs)
''')
    return '\n'.join(L)


VENC_SHAPES['IndexedAttestation'] = venc_ulist


# ---- (ii)/(iii): a container of two boxed u64-list children at windows (AttesterSlashing) ----
def nest2_view(R, X, child):
    """The view lemma of X{BSome{child at window 2}, BSome{child at window J}} (codegen/var_nest's
    layout): the child's view at a window (vvw, as ulist_view at word offset i), twice."""
    src = _dc_module(R).read_text()
    cm = re.search(r'^import \./(\S+) as DC$', src, re.M).group(1)
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = (ROOT / 'proofs/obj' / wm).read_text()
    xv = re.search(r'^def XVw\(\+t: FD\.array__Tree<U32>, \+i: Nat, \+k: Nat, \+W: List<&2, U32>\) -> S\.Value: (.*)$', wsrc, re.M).group(1)
    fs = re.search(r'DC\.chk3\(U32\.is_le\((\d+), len\)', wsrc).group(1)
    hole = 'S.Sequence{VS.uitems(k, W)}'
    assert xv.count(hole) == 1
    ctx = xv.replace(hole, 'z').replace('VS.', 'VSP.')
    chk = re.search(r'^def CHK\(\+t: FD\.array__Tree<U32>, \+n: U32\) -> Bool:\n  chk5\((.*)\)$', src, re.M).group(1)
    ca = [a.strip() for a in _split(chk)]
    assert len(ca) == 5
    ca = [re.sub(r'\b(O0|O1|L1|L2|J)\(', r'DC.\1(', a) for a in ca]
    CV = lambda c_: f'RT.v_{child}(W.OBJw(t, {c_}))'  # noqa: E731
    VW_ = lambda c_: f'W.VALw(t, {c_})'  # noqa: E731
    w1, w2 = '2n, DC.L1(t)', 'DC.J(t), DC.L2(t, n)'
    text = f'''# ---- the view of a decoded object is the codec law's value ----

def cntw(+len: U32, +hc: {{IA.whole(IA.LL(len)) == True{{}} : Bool}}) -> {{U32.to_nat(U32.shrn(IA.LL(len), 3n)) == IA.CQ(len) : Nat}}:
  Equal.trans(Nat, U32.to_nat(U32.shrn(IA.LL(len), 3n)), VD.s_rng(3n, U32.to_nat(IA.LL(len))), IA.CQ(len), VD.shrk(3n, IA.LL(len)),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(IA.LL(len))), VD.s_rng(3n, VSP.x8(IA.CQ(len))), IA.CQ(len),
      Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(IA.LL(len)), VSP.x8(IA.CQ(len)), IA.eLc(len, hc)), U.r8(IA.CQ(len))))

def whw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, +h: {{W.CHKw(t, i, len) == True{{}} : Bool}}) -> {{IA.whole(IA.LL(len)) == True{{}} : Bool}}:
  +a = U32.is_le({fs}, len)
  +b = U32.is_eq(W.SPOw(t, i), {fs})
  +c = IA.whole(U32.sub(len, W.SPOw(t, i)))
  +epo = FD.u32alg__eq_of(W.SPOw(t, i), {fs}, IA.chk_b(a, b, c, h))
  FD.logic__subst(U32, z => {{IA.whole(U32.sub(len, z)) == True{{}} : Bool}}, W.SPOw(t, i), {fs}, epo, IA.chk_c(a, b, c, h))

# the child's view at the window of word i, length len
def vvw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, +h: {{W.CHKw(t, i, len) == True{{}} : Bool}}) -> {{{CV('i, len')} == {VW_('i, len')} : S.Value}}:
  Equal.cong(S.Value, S.Value, z => {ctx}, UL.uview(O.Words{{FD.array__thaw(U32, W.MMw(t, i, len)), IA.LL(len)}}),
    S.Sequence{{VSP.uitems(IA.CQ(len), FD.array__slots(U32, W.MMw(t, i, len)))}}, U.uvw(W.MMw(t, i, len), IA.LL(len), IA.CQ(len), cntw(len, whw(t, i, len, h))))

def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(t, n)) == DC.VAL(t, n) : S.Value}}:
  +a = {ca[0]}
  +b = {ca[1]}
  +c = {ca[2]}
  +d4 = {ca[3]}
  +e = {ca[4]}
  Equal.trans(S.Value, S.Sequence{{S.Items{{{CV(w1)}, S.Items{{{CV(w2)}, S.EmptyItems{{}}}}}}}}, S.Sequence{{S.Items{{{VW_(w1)}, S.Items{{{CV(w2)}, S.EmptyItems{{}}}}}}}}, DC.VAL(t, n),
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{z, S.Items{{{CV(w2)}, S.EmptyItems{{}}}}}}}}, {CV(w1)}, {VW_(w1)}, vvw(t, {w1}, DC.c5d(a, b, c, d4, e, hchk))),
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{{VW_(w1)}, S.Items{{z, S.EmptyItems{{}}}}}}}}, {CV(w2)}, {VW_(w2)}, vvw(t, {w2}, DC.c5e(a, b, c, d4, e, hchk))))

'''
    return {'view': f'RT.v_{X}',
            'imports': ['import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vspec.bend as VSP', 'import ../proofs/obj/vbuf.bend as VB',
                        'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/root_types.bend as RT', 'import ./e2e_ulist.bend as U',
                        f'import ../proofs/obj/{cm} as IA', f'import ../proofs/obj/{wm} as W'],
            'text': text}


def _split(t):
    parts, dep, cur = [], 0, ''
    for ch in t:
        if ch in '{([':
            dep += 1
        elif ch in '})]':
            dep -= 1
        if ch == ',' and dep == 0:
            parts.append(cur)
            cur = ''
        else:
            cur += ch
    parts.append(cur)
    return parts


VDEC_VIEWS['AttesterSlashing'] = nest2_view('FuluAttesterSlashing', 'AttesterSlashing', 'IndexedAttestation')


# ---- (iv): a container of two boxed u64-list children (AttesterSlashing) ----
def vroot_nest2(R, X, child):
    cw, cargs, cli, _nc, _lc = _rep(child)
    D, C, BX = f'T.{X}', f'T.{child}', f'O.Boxed<T.{child}>'

    def cobj(k, lw):
        ws = iter(f'{x}_{k}' for x, _ in cw)
        return f'{C}{{' + ', '.join(lw if j == cli else next(ws) for j in range(len(cargs))) + '}'
    WK = lambda k: f'O.Words{{FD.array__thaw(U32, t{k}), N{k}}}'  # noqa: E731
    C1, C2 = cobj(1, WK(1)), cobj(2, WK(2))
    B1, B2 = f'O.BSome{{{C1}, O.BNone{{}}}}', f'O.BSome{{{C2}, O.BNone{{}}}}'
    O1 = f'{D}{{{B1}, {B2}}}'
    PJ = lambda k: f'RT.pj_{X}_{k - 1}(o)'  # noqa: E731
    PB = lambda k: f'RT.pjb_{child}_bx({PJ(k)})'  # noqa: E731
    PL = lambda k: f'RT.pj_{child}_{cli}({PB(k)})'  # noqa: E731
    CP = lambda k: cobj(k, PL(k))  # noqa: E731
    RX = lambda o: f'D.bytes(Pair.snd({D}, D.Digest, Pair.snd(B.Buf, {D} & D.Digest, T.{X}_hash_tree_root(h, {o}))))'  # noqa: E731
    G = lambda o: f'{{Some{{{RX(o)}}} == API.hash_tree_root(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    WS_ = ', '.join(f'+{x}_{k}: {ty}' for k in (1, 2) for x, ty in cw)
    WA_ = ', '.join(f'{x}_{k}' for k in (1, 2) for x, _ in cw)
    TN = '+t1: FD.array__Tree<U32>, +N1: U32, +t2: FD.array__Tree<U32>, +N2: U32'
    TA = 't1, N1, t2, N2'
    # the hypotheses the chain carries
    E0 = f'+e0: {{o == {D}{{{PJ(1)}, {PJ(2)}}} : {D}}}'
    EB = lambda k: f'+eb{k}: {{{PJ(k)} == O.BSome{{{PB(k)}, O.BNone{{}}}} : {BX}}}'  # noqa: E731
    EC = lambda k: f'+ec{k}: {{{PB(k)} == {CP(k)} : {C}}}'  # noqa: E731
    WF = lambda k: f'+wf{k}: LO.wfl({PL(k)})'  # noqa: E731
    EW = lambda k: f'+ew{k}: {{{PL(k)} == {WK(k)} : O.Words}}'  # noqa: E731

    def ceq(k):
        """{pj_k(o) == BSome{C_k, BNone}} from eb_k, ec_k, ew_k."""
        Ck = C1 if k == 1 else C2
        inner = (f'Equal.trans({C}, {PB(k)}, {CP(k)}, {Ck}, ec{k}, Equal.cong(O.Words, {C}, z => {cobj(k, "z")}, {PL(k)}, {WK(k)}, ew{k}))')
        return (f'Equal.trans({BX}, {PJ(k)}, O.BSome{{{PB(k)}, O.BNone{{}}}}, O.BSome{{{Ck}, O.BNone{{}}}}, eb{k}, '
                f'Equal.cong({C}, {BX}, z => O.BSome{{z, O.BNone{{}}}}, {PB(k)}, {Ck}, {inner}))')
    EO = (f'Equal.trans({D}, o, {D}{{{PJ(1)}, {PJ(2)}}}, {O1}, e0, Equal.trans({D}, {D}{{{PJ(1)}, {PJ(2)}}}, {D}{{{B1}, {PJ(2)}}}, {O1}, '
          f'Equal.cong({BX}, {D}, z => {D}{{z, {PJ(2)}}}, {PJ(1)}, {B1}, {ceq(1)}), Equal.cong({BX}, {D}, z => {D}{{{B1}, z}}, {PJ(2)}, {B2}, {ceq(2)})))')

    def unpack(k, wn):
        l1 = ['+t', '+dw', '+N', '+ew'] if wn == 'Inl' else ['+t', '+dw', '+N', '+q', '+r', '+ew']
        l1 = [f'{a}{k}' if a in ('+t', '+N', '+ew') else f'{a}{k}' for a in l1]
        return '\n'.join(f'      ({f}, w{j + 1}) = {"w" if j == 0 else "w" + str(j)}' for j, f in enumerate(l1))
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/fulu_obj.bend as T', 'import ../types/schema.bend as S',
            'import ../spec/fulu_schemas.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            'import ../proofs/obj/root_types.bend as RT', 'import ../proofs/obj/gvalid_types.bend as GV', 'import ../proofs/obj/list_obj.bend as LO',
            'import ./e2e_support.bend as E']
    s2cases = []
    for wn in ('Inl', 'Inr'):
        s2cases.append(f'''    case {wn}{{w}}:
{unpack(2, wn)}
      rt2(h, o, rep, {WA_}, {TA}, {EO})''')
    s1cases = []
    for wn in ('Inl', 'Inr'):
        s1cases.append(f'''    case {wn}{{w}}:
{unpack(1, wn)}
      s2(h, o, rep, {WA_}, t1, N1, e0, eb1, eb2, ec1, ec2, ew1, wf2)''')
    return '\n'.join(imps) + f"""

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (variable size): the object API's root is END_TO_END's hash_tree_root, for every object the
# root law represents (rep_{X}: each child's list field's words in a perfect tree of depth below 32).

def rt1(h: B.Buf, {WS_}, {TN}, +rep: RT.rep_{X}({O1}, Spec.{X}())) -> {G(O1)}:
  E.root_legal(Spec.{X}(), RT.v_{X}({O1}), VS.public_sound(Spec.{X}(), {{==}}), {RX(O1)},
    GV.{X}_root_valid({O1}, Spec.{X}(), {{==}}, rep), RT.{X}_root_correct(h, {O1}, Spec.{X}(), {{==}}, rep))

# the object as rep's witnesses name it
def rt2(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {WS_}, {TN},
    +eo: {{o == {O1} : {D}}}) -> {G('o')}:
  %Equal.sym({D}, o, {O1}, eo) : {G('_')}
  rt1(h, {WA_}, {TA}, FD.logic__subst({D}, z => RT.rep_{X}(z, Spec.{X}()), o, {O1}, eo, rep))

# the second child's storage
def s2(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {WS_}, +t1: FD.array__Tree<U32>, +N1: U32,
    {E0}, {EB(1)}, {EB(2)}, {EC(1)}, {EC(2)}, {EW(1)}, {WF(2)}) -> {G('o')}:
  match wf2:
{chr(10).join(s2cases)}

# the first child's storage
def s1(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {WS_},
    {E0}, {EB(1)}, {EB(2)}, {EC(1)}, {EC(2)}, {WF(1)}, {WF(2)}) -> {G('o')}:
  match wf1:
{chr(10).join(s1cases)}

# (iv)
def {R}_e2e_root(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}())) -> {G('o')}:
  (+e0, +q) = rep
  (+rb1, +rb2) = q
""" + '\n'.join(
        '\n'.join([f'  (+eb{k}, +ri{k}) = rb{k}', f'  (+{cw[0][0]}_{k}, +a0_{k}) = ri{k}'] + [f'  (+{x}_{k}, +a{j}_{k}) = a{j - 1}_{k}' for j, (x, _) in enumerate(cw) if j > 0]
                  + [f'  (+ec{k}, +b1_{k}) = a{len(cw) - 1}_{k}', f'  (+wf{k}, +b2_{k}) = b1_{k}']) for k in (1, 2)) + f"""
  s1(h, o, rep, {WA_}, e0, eb1, eb2, ec1, ec2, wf1, wf2)
"""


VROOT_SHAPES['AttesterSlashing'] = lambda R, X: vroot_nest2(R, X, 'IndexedAttestation')


# ---- (i): a container of two boxed u64-list children (AttesterSlashing), through codegen/var_nest_enc's laws ----
def venc_nest2(R, X, child):
    import lim_pow as LPW
    dcm = _dc_module(R)
    enc = (dcm.parent / (dcm.stem + '_enc.bend')).read_text()
    cenc_name = re.search(r'^import \./(\S+) as E$', enc, re.M).group(1)
    cencw_name = re.search(r'^import \./(\S+) as IW$', enc, re.M).group(1)
    cenc = (ROOT / 'proofs/obj' / cenc_name).read_text()
    ev = re.search(r'^def encode_eval\((.*?)\)\n    -> \{(\w+)\.' + X + r'_encode\((.*?)\) == \(.*?B\.Buf\{FD\.array__thaw\(U32, (AW\d+)\(', enc, re.M | re.S)
    params = ev.group(1)
    WS1 = re.findall(r'\+(\w+\d+): U32', params.split('+dw1:')[0])
    WS2 = re.findall(r'\+(\w+\d+): U32', params.split('+dw1:')[1].split('+dw2:')[0])
    WS2 = [w_ for w_ in WS2 if w_ not in ('N1',)]
    WA1, WA2 = ', '.join(WS1), ', '.join(WS2)
    EMOD, AW = ev.group(2), ev.group(4)
    OBJT = ev.group(3).replace('FD.array__thaw(U32, T1)', 'FD.array__thaw(U32, t1)').replace('FD.array__thaw(U32, T2)', 'FD.array__thaw(U32, t2)')
    LIMN = re.search(r'\+hc1: \{Nat\.is_le\(c1, (.*?)\) == True\{\} : Bool\}', params).group(1)
    FS = int(re.search(r'^def SFS\(\+N: U32\) -> U32: U32\.add\((\d+), N\)', cenc, re.M).group(1))
    H = int(re.search(r'VB\.mone\(VC\.NW\(N\), 0n, (\d+)n, DO\(N\)', cenc).group(1))
    IWl = re.search(r'^def AW2\(.*\) -> FD\.array__Tree<U32>: IW\.(IW\d+)\(', enc, re.M).group(1)
    xe = re.search(r'^def XE\(.*?\+k: Nat, \+W: List<&2, U32>\) -> S\.Value: (.*)$', cenc, re.M).group(1)
    hole = 'S.Sequence{VS.uitems(k, W)}'
    cws = re.findall(r'\+(w\d+): U32', re.search(r'^def XE\((.*?)\+k: Nat', cenc, re.M).group(1))
    XCTX = xe.replace(hole, 'z').replace('F.limbs(', 'SF.limbs(').replace('VS.', 'VSP.')

    def xctx(ws):
        m = dict(zip(cws, ws))
        return re.sub(r'\bw\d+\b', lambda mm: m[mm.group(0)], XCTX)
    timps = [f'import ../types/{p} as {a}' for p, a in re.findall(r'^import \.\./\.\./types/(\S+_generated\.bend) as (\w+)$', enc, re.M)]
    D = re.match(r'(\w+_d\.' + X + r')\{', OBJT).group(1)
    CD = re.search(r'O\.BSome\{(\w+_d\.' + child + r')\{', OBJT).group(1)
    ENC = f'{EMOD}.{X}_encode'
    cw, cargs, cli, _nc, _lc = _rep(child)
    WORDS = lambda k: f'O.Words{{FD.array__thaw(U32, t{k}), N{k}}}'  # noqa: E731
    PJ = lambda k: f'RT.pj_{X}_{k - 1}(o)'  # noqa: E731
    PB = lambda k: f'RT.pjb_{child}_bx({PJ(k)})'  # noqa: E731
    PL = lambda k: f'RT.pj_{child}_{cli}({PB(k)})'  # noqa: E731
    # the children's schema paths (rep_X), and the list's inside the child (rep_child)
    rl = (ROOT / 'proofs/obj/root_types.bend').read_text().split(f'def rep_{X}(')[1].split('\n')[1]
    csch = []
    for k in (1, 2):
        j0 = rl.index(f'rep_{child}_bx(pj_{X}_{k - 1}(o), ') + len(f'rep_{child}_bx(pj_{X}_{k - 1}(o), ')
        j, dep = j0, 0
        while not (rl[j] == ')' and dep == 0):
            dep += {'(': 1, ')': -1}.get(rl[j], 0)
            j += 1
        csch.append(rl[j0:j])
    rlc = (ROOT / 'proofs/obj/root_types.bend').read_text().split(f'def rep_{child}(')[1].split('\n')[1]
    j0 = rlc.index(f'UL.rep_ul(pj_{child}_{cli}(o), ') + len(f'UL.rep_ul(pj_{child}_{cli}(o), ')
    j, dep = j0, 0
    while not (rlc[j] == ')' and dep == 0):
        dep += {'(': 1, ')': -1}.get(rlc[j], 0)
        j += 1
    lin = rlc[j0:j]
    LIMS = [lin.replace('(s)', f'({csch[k].replace("(s)", f"(Spec.{X}())")})') for k in (0, 1)]
    LP = LPW.LimPow(LIMN, alias='VBG')
    assert LP.big
    X8 = LP.x8()
    XL = LP.add(FS, X8)
    X2 = LP.sum(LP.add(8, XL), XL)
    q, r = X8.s, LP.bound(X2)
    K, Q = r - 2, q - 2
    assert K < 29 and Q < 29
    CLOSED = X2.text.replace('VS.', 'VSP.')
    P2 = LP.le_spow2(X2, r).replace('VS.', 'VSP.')
    P3 = LP.le_spow2(X8, q).replace('VS.', 'VSP.')
    GOAL = lambda o: f'{{Some{{E.obytes(Pair.snd({D}, B.Buf, {ENC}({o})))}} == API.serialize(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    TWa = f'{WA1}, N1, t1, {WA2}, N2, t2'
    AWc = f'EN.{AW}({TWa})'
    C2 = 'EN.C2(N1, N2)'
    hK = f'{{Nat.is_le(U32.to_nat({C2}), A.quad(FD.spec_common__pow2({K}n))) == True{{}} : Bool}}'
    NC = lambda k: f'+N{k}: U32, +c{k}: Nat, +ec{k}: {{U32.to_nat(N{k}) == VSP.x8(c{k}) : Nat}}, +hc{k}: {{Nat.is_le(c{k}, {LIMN}) == True{{}} : Bool}}'  # noqa: E731
    L = []
    w = L.append
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../spec/fulu_schemas.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../spec/codec.bend as Encoding', 'import ../proofs/obj/spec_fixed.bend as SF', 'import ../proofs/obj/vspec.bend as VSP',
            'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vcopy.bend as VC', 'import ../proofs/obj/ulist_obj.bend as UL',
            'import ../proofs/obj/root_types.bend as RT', 'import ../proofs/obj/list_obj.bend as LO', f'import ../proofs/obj/{dcm.stem}_enc.bend as EN',
            f'import ../proofs/obj/{cenc_name} as CE', f'import ../proofs/obj/{cencw_name} as IW'] + timps + [
            'import ./e2e_support.bend as E', 'import ./e2e_cap.bend as C', 'import ./e2e_emit.bend as EM', 'import ./e2e_ulist.bend as U',
            'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/words_spec.bend as WS', 'import ../proofs/obj/schema_shapes.bend as SH',
            'import ../proofs/obj/dk.bend as DK', 'import ../spec/primitives.bend as SP', 'import ../proofs/obj/vbig.bend as VBG']
    w('\n'.join(imps))
    SIG1 = ', '.join('+' + x + ': U32' for x in WS1)
    SIG2 = ', '.join('+' + x + ': U32' for x in WS2)
    VALT = f'EN.VAL({WA1}, {WA2}, c1, c2, FD.array__slots(U32, t1), FD.array__slots(U32, t2))'
    CV1 = f'RT.v_{child}({re.search(r"O.BSome{(.*?), O.BNone{}}, O.BSome", OBJT).group(1)})'
    CV2 = f'RT.v_{child}({re.search(r"O.BNone{}}, O.BSome{(.*), O.BNone{}}}$", OBJT).group(1)})'
    XE1 = f'CE.XE({WA1}, c1, FD.array__slots(U32, t1))'
    XE2 = f'CE.XE({WA2}, c2, FD.array__slots(U32, t2))'
    w(f'''
# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (variable size): the object API's encoder's bytes are END_TO_END's serialize of the object's view,
# for every object the root law represents (rep) whose children's list storage is at depth below 31 (hs1, hs2).

def vx1({SIG1}, +t1: FD.array__Tree<U32>, +N1: U32, +c1: Nat, +ecq1: {{U32.to_nat(U32.shrn(N1, 3n)) == c1 : Nat}}) -> {{{CV1} == {XE1} : S.Value}}:
  Equal.cong(S.Value, S.Value, z => {xctx(WS1)}, UL.uview({WORDS(1)}), S.Sequence{{VSP.uitems(c1, FD.array__slots(U32, t1))}}, U.uvw(t1, N1, c1, ecq1))

def vx2({SIG2}, +t2: FD.array__Tree<U32>, +N2: U32, +c2: Nat, +ecq2: {{U32.to_nat(U32.shrn(N2, 3n)) == c2 : Nat}}) -> {{{CV2} == {XE2} : S.Value}}:
  Equal.cong(S.Value, S.Value, z => {xctx(WS2)}, UL.uview({WORDS(2)}), S.Sequence{{VSP.uitems(c2, FD.array__slots(U32, t2))}}, U.uvw(t2, N2, c2, ecq2))

def vx({SIG1}, {SIG2}, +t1: FD.array__Tree<U32>, +N1: U32, +c1: Nat, +t2: FD.array__Tree<U32>, +N2: U32, +c2: Nat,
    +ecq1: {{U32.to_nat(U32.shrn(N1, 3n)) == c1 : Nat}}, +ecq2: {{U32.to_nat(U32.shrn(N2, 3n)) == c2 : Nat}}) -> {{RT.v_{X}({OBJT}) == {VALT} : S.Value}}:
  Equal.trans(S.Value, S.Sequence{{S.Items{{{CV1}, S.Items{{{CV2}, S.EmptyItems{{}}}}}}}}, S.Sequence{{S.Items{{{XE1}, S.Items{{{CV2}, S.EmptyItems{{}}}}}}}}, {VALT},
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{z, S.Items{{{CV2}, S.EmptyItems{{}}}}}}}}, {CV1}, {XE1}, vx1({WA1}, t1, N1, c1, ecq1)),
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{{XE1}, S.Items{{z, S.EmptyItems{{}}}}}}}}, {CV2}, {XE2}, vx2({WA2}, t2, N2, c2, ecq2)))

# the bounds, without evaluating the limit
def p2() -> {{Nat.is_le({CLOSED}, A.quad(FD.spec_common__pow2({K}n))) == True{{}} : Bool}}:
  %Equal.sym(Nat, A.quad(FD.spec_common__pow2({K}n)), FD.spec_common__pow2({r}n), VBG.quadpw({K}n, {r}n, {{==}})) : {{Nat.is_le({CLOSED}, _) == True{{}} : Bool}}
  {P2}

def p3() -> {{Nat.is_le(VSP.x8({LIMN}), A.quad(FD.spec_common__pow2({Q}n))) == True{{}} : Bool}}:
  %Equal.sym(Nat, A.quad(FD.spec_common__pow2({Q}n)), FD.spec_common__pow2({q}n), VBG.quadpw({Q}n, {q}n, {{==}})) : {{Nat.is_le(VSP.x8({LIMN}), _) == True{{}} : Bool}}
  {P3}

def hK({NC(1)}, {NC(2)}) -> {hK}:
  FD.nat__le_trans(U32.to_nat({C2}), {CLOSED}, A.quad(FD.spec_common__pow2({K}n)), EN.leC2(N1, c1, ec1, hc1, N2, c2, ec2, hc2), p2())

# the output tree is perfect at its depth
def pfAW({SIG1}, +N1: U32, +t1: FD.array__Tree<U32>, {SIG2}, +N2: U32, +t2: FD.array__Tree<U32>) -> {{FD.array__perfect(U32, EN.DOA(N1, N2), {AWc}) == True{{}} : Bool}}:
  IW.pfW{IWl[2:]}({WA2}, EN.DOA(N1, N2), EN.A2({TWa}), Nat.add(2n, Nat.add({H}n, VC.NW(N1))), N2, t2, EN.pfA2({TWa}))

def eby({SIG1}, +N1: U32, +t1: FD.array__Tree<U32>, {SIG2}, +N2: U32, +t2: FD.array__Tree<U32>, +h: {hK})
    -> {{E.obytes(B.Buf{{FD.array__thaw(U32, {AWc}), {C2}}}) == VSP.bt(U32.to_nat({C2}), SF.limbs(FD.array__slots(U32, {AWc}))) : +List<U32>}}:
  EM.ob(EN.DOA(N1, N2), {AWc}, {C2}, pfAW({TWa}),
    FD.nat__le_lt_trans(B.capacity({C2}), {K}n, 29n, C.cap_le({C2}, {K}n, {{==}}, h), {{==}}), C.cap_q({C2}, {K}n, {{==}}, h))
''')
    SER = lambda v: f'API.serialize(Spec.{X}(), {v})'  # noqa: E731
    BT = f'VSP.bt(U32.to_nat({C2}), SF.limbs(FD.array__slots(U32, {AWc})))'
    EVARGS = f'{WA1}, dw1, t1, N1, c1, pf1, hdw1, ec1, hc1, hroom1, {WA2}, dw2, t2, N2, c2, pf2, hdw2, ec2, hc2, hroom2'
    CH = lambda k: f'+dw{k}: Nat, +t{k}: FD.array__Tree<U32>, +N{k}: U32, +c{k}: Nat, +pf{k}: {{FD.array__perfect(U32, dw{k}, t{k}) == True{{}} : Bool}}, +hdw{k}: {{Nat.is_lt(dw{k}, 31n) == True{{}} : Bool}},\n    +ec{k}: {{U32.to_nat(N{k}) == VSP.x8(c{k}) : Nat}}, +hc{k}: {{Nat.is_le(c{k}, {LIMN}) == True{{}} : Bool}}, +hroom{k}: {{Nat.is_le(Nat.add(VC.NW(N{k}), 0n), FD.spec_common__pow2(dw{k})) == True{{}} : Bool}}'  # noqa: E731
    w(f'''# (i) on an object whose children's lists are stored in perfect trees t_k of depth dw_k < 31 holding N_k = 8 c_k bytes
def enc1({SIG1}, {CH(1)},
    {SIG2}, {CH(2)},
    +ecq1: {{U32.to_nat(U32.shrn(N1, 3n)) == c1 : Nat}}, +ecq2: {{U32.to_nat(U32.shrn(N2, 3n)) == c2 : Nat}}) -> {GOAL(OBJT)}:
  %Equal.sym({D} & B.Buf, {ENC}({OBJT}), ({OBJT}, B.Buf{{FD.array__thaw(U32, {AWc}), {C2}}}), EN.encode_eval({EVARGS})) :
    {{Some{{E.obytes(Pair.snd({D}, B.Buf, _))}} == {SER(f'RT.v_{X}({OBJT})')} : Maybe<&2, +List<U32>>}}
  %Equal.sym(+List<U32>, E.obytes(B.Buf{{FD.array__thaw(U32, {AWc}), {C2}}}), {BT}, eby({TWa}, hK(N1, c1, ec1, hc1, N2, c2, ec2, hc2))) :
    {{Some{{_}} == {SER(f'RT.v_{X}({OBJT})')} : Maybe<&2, +List<U32>>}}
  %Equal.sym(S.Value, RT.v_{X}({OBJT}), {VALT}, vx({WA1}, {WA2}, t1, N1, c1, t2, N2, c2, ecq1, ecq2)) :
    {{Some{{{BT}}} == {SER('_')} : Maybe<&2, +List<U32>>}}
  Equal.sym(Maybe<&2, +List<U32>>, {SER(VALT)}, Some{{{BT}}},
    Equal.trans(Maybe<&2, +List<U32>>, {SER(VALT)}, Encoding.encoding_for_legal_type(Spec.{X}(), {VALT}), Some{{{BT}}},
      E.serialize_legal(Spec.{X}(), {VALT}, VS.public_sound(Spec.{X}(), {{==}})),
      EN.encode_spec({EVARGS})))
''')
    # the lists' limits through the spec's schema terms
    ELT = []
    for k in (1, 2):
        LSCH = _spec_at(X, LIMS[k - 1])
        ln = _parse(LSCH)
        assert ln[0] == 'S.ListOf' and _render(ln[1][1]) == LIMN, (LSCH, LIMN)
        ELT.append(_render(ln[1][0]))
        w(f'''def eH{k}() -> {{{LIMS[k - 1]} == {LSCH} : S.Schema}}: {{==}}
''')
    w(f'''def lim_of(+e: S.Schema, +n: Nat) -> {{SH.ListOf_limit(S.ListOf{{e, n}}) == n : Nat}}: {{==}}
''')
    for k in (1, 2):
        w(f'''def hcl{k}(+c: Nat, +h: {{Nat.is_le(c, SH.ListOf_limit({LIMS[k - 1]})) == True{{}} : Bool}}) -> {{Nat.is_le(c, {LIMN}) == True{{}} : Bool}}:
  %lim_of({ELT[k - 1]}, {LIMN}) : {{Nat.is_le(c, _) == True{{}} : Bool}}
  %eH{k}() : {{Nat.is_le(c, SH.ListOf_limit(_)) == True{{}} : Bool}}
  h
''')
    # per child: from its storage witnesses to (dw, t, N, c, pf, hdw, ec, hc, hroom, ecq)
    ELEN = lambda k: f'+elen{k}: {{U32.to_nat(WO.len({PL(k)})) == O.e8(UL.ucnt({PL(k)})) : Nat}}'  # noqa: E731
    HLIM = lambda k: f'+hlim{k}: {{Nat.is_le(UL.ucnt({PL(k)}), SH.ListOf_limit({LIMS[k - 1]})) == True{{}} : Bool}}'  # noqa: E731
    HS = lambda k: f'+hs{k}: U.sd({PL(k)})'  # noqa: E731

    def common(k):
        return f'''      +c{k} = U32.to_nat(U32.shrn(N{k}, 3n))
      +el{k} = FD.logic__subst(O.Words, z => {{U32.to_nat(WO.len(z)) == O.e8(UL.ucnt(z)) : Nat}}, {PL(k)}, {WORDS(k)}, ew{k}, elen{k})
      +ec{k} = Equal.trans(Nat, U32.to_nat(N{k}), O.e8(c{k}), VSP.x8(c{k}), el{k}, Equal.sym(Nat, VSP.x8(c{k}), O.e8(c{k}), U.x8e(c{k})))
      +hc{k} = hcl{k}(c{k}, FD.logic__subst(O.Words, z => {{Nat.is_le(UL.ucnt(z), SH.ListOf_limit({LIMS[k - 1]})) == True{{}} : Bool}}, {PL(k)}, {WORDS(k)}, ew{k}, hlim{k}))
      +hN{k} = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(FD.spec_common__pow2({Q}n))) == True{{}} : Bool}}, VSP.x8(c{k}), U32.to_nat(N{k}), Equal.sym(Nat, U32.to_nat(N{k}), VSP.x8(c{k}), ec{k}), FD.nat__le_trans(VSP.x8(c{k}), VSP.x8({LIMN}), A.quad(FD.spec_common__pow2({Q}n)), VSP.x8_mono(c{k}, {LIMN}, hc{k}), p3()))
      +enw{k} = Equal.trans(Nat, Nat.add(VC.NW(N{k}), 0n), VC.NW(N{k}), C.nwn(U32.to_nat(N{k})), FD.nat__add_zero(VC.NW(N{k})), C.nw(N{k}, {Q}n, {{==}}, hN{k}))'''

    def inl(k):
        return f'''      (+t{k}, s1) = s
      (+dw{k}, s2) = s1
      (+N{k}, s3) = s2
      (+ew{k}, s4) = s3
      (+pf{k}, s5) = s4
      (+hdw{k}, +en0) = s5
{common(k)}
      +hroom{k} = FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dw{k})) == True{{}} : Bool}}, 0n, Nat.add(VC.NW(N{k}), 0n),
        Equal.sym(Nat, Nat.add(VC.NW(N{k}), 0n), 0n, Equal.trans(Nat, Nat.add(VC.NW(N{k}), 0n), C.nwn(U32.to_nat(N{k})), 0n, enw{k}, Equal.cong(Nat, Nat, z => C.nwn(z), U32.to_nat(N{k}), 0n, en0))),
        Order.zero_le(FD.spec_common__pow2(dw{k})))'''

    def inr(k):
        return f'''      (+t{k}, s1) = s
      (+dw{k}, s2) = s1
      (+N{k}, s3) = s2
      (+q, s4) = s3
      (+r, s5) = s4
      (+ew{k}, s6) = s5
      (+pf{k}, s7) = s6
      (+hdw{k}, s8) = s7
      (+eN, s9) = s8
      (+hr0, s10) = s9
      (+hr32, s11) = s10
      (+hcap, +bz) = s11
{common(k)}
      +hq = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(O.e8(1n+q))) == True{{}} : Bool}}, Nat.add(r, WS.e32(q)), U32.to_nat(N{k}),
        Equal.sym(Nat, U32.to_nat(N{k}), Nat.add(r, WS.e32(q)), Equal.trans(Nat, U32.to_nat(N{k}), Nat.add(WS.e32(q), r), Nat.add(r, WS.e32(q)), eN, FD.nat__add_comm(WS.e32(q), r))),
        Order.add_right(r, 32n, WS.e32(q), hr32))
      +hroom{k} = FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dw{k})) == True{{}} : Bool}}, C.nwn(U32.to_nat(N{k})), Nat.add(VC.NW(N{k}), 0n),
        Equal.sym(Nat, Nat.add(VC.NW(N{k}), 0n), C.nwn(U32.to_nat(N{k})), enw{k}),
        FD.nat__le_trans(C.nwn(U32.to_nat(N{k})), O.e8(1n+q), FD.spec_common__pow2(dw{k}), C.nle(U32.to_nat(N{k}), O.e8(1n+q), hq), hcap))'''
    # the object over the fixed-field witnesses (x_k) and the list fields as the rep names them (PL) / as stored (WORDS)
    def cobjw(k, lst):
        xs = iter(f'{x}_{k}' for x, _ in cw)
        return f'{CD}{{' + ', '.join(lst if j_ == cli else next(xs) for j_ in range(len(cargs))) + '}'

    def objx(l1, l2):
        return f'{D}{{O.BSome{{{cobjw(1, l1)}, O.BNone{{}}}}, O.BSome{{{cobjw(2, l2)}, O.BNone{{}}}}}}'
    _wt = _parse(OBJT)
    XS = ', '.join(f'+{x}_{k}: {_wt[1][k - 1][1][0][1][j_][0]}' for k in (1, 2) for j_, (x, _) in
                   ((j2, w2) for j2, w2 in zip([j3 for j3 in range(len(cargs)) if j3 != cli], cw)))
    XA = ', '.join(f'{x}_{k}' for k in (1, 2) for x, _ in cw)
    CHP = lambda k: (f'+dw{k}: Nat, +t{k}: FD.array__Tree<U32>, +N{k}: U32, +c{k}: Nat, +pf{k}: {{FD.array__perfect(U32, dw{k}, t{k}) == True{{}} : Bool}}, +hdw{k}: {{Nat.is_lt(dw{k}, 31n) == True{{}} : Bool}}, '
                     f'+ec{k}: {{U32.to_nat(N{k}) == VSP.x8(c{k}) : Nat}}, +hc{k}: {{Nat.is_le(c{k}, {LIMN}) == True{{}} : Bool}}, +hroom{k}: {{Nat.is_le(Nat.add(VC.NW(N{k}), 0n), FD.spec_common__pow2(dw{k})) == True{{}} : Bool}}, +ecq{k}: {{U32.to_nat(U32.shrn(N{k}, 3n)) == c{k} : Nat}}')  # noqa: E731
    CHA = lambda k: f'dw{k}, t{k}, N{k}, c{k}, pf{k}, hdw{k}, ec{k}, hc{k}, hroom{k}, ecq{k}'  # noqa: E731
    # the destructuring chain over the witnesses, from objx(WORDS(1), WORDS(2)) down to the words; then (i)
    tree = _parse(objx(WORDS(1), WORDS(2)))
    nodes = {}

    def reg(n):
        i_ = len(nodes)
        nodes[i_] = None
        nodes[i_] = (n[0], None if n[1] is None else [reg(c) for c in n[1]])
        return i_
    root_ = reg(tree)
    vname, opened, wits = {}, {root_}, []
    wt = _parse(OBJT)
    for k, bs in enumerate(nodes[root_][1]):
        opened.add(bs)
        cnode = nodes[bs][1][0]
        opened.add(cnode)
        xs = iter(f'{x}_{k + 1}' for x, _ in cw)
        for j_, a_ in enumerate(nodes[cnode][1]):
            if j_ == cli:
                opened.add(a_)
                opened.update(nodes[a_][1] or [])
            else:
                vname[a_] = next(xs)
                wits.append((a_, wt[1][k][1][0][1][j_]))

    def reg_at(n):
        i_ = max(nodes) + 1
        nodes[i_] = None
        nodes[i_] = (n[0], None if n[1] is None else [reg_at(c) for c in n[1]])
        return i_
    for a_, sub in wits:
        nodes[a_] = (sub[0], [reg_at(c) for c in sub[1]])
    fresh = iter(f'y{j_}' for j_ in range(10000))

    def rend(i_):
        h_, ch_ = nodes[i_]
        if ch_ is None:
            return h_
        if ch_ == []:
            return h_ + '{}'
        if i_ not in opened:
            return vname[i_]
        return h_ + '{' + ', '.join(rend(c) for c in ch_) + '}'

    def front():
        out = []

        def go(i_):
            h_, ch_ = nodes[i_]
            if ch_ is None:
                if re.fullmatch(r'[a-z]\d+', h_):
                    out.append((h_, 'U32'))
            elif ch_ == []:
                pass
            elif i_ not in opened:
                out.append((vname[i_], h_))
            else:
                for c in ch_:
                    go(c)
        go(root_)
        return out
    order = []

    def todo(i_):
        h_, ch_ = nodes[i_]
        if ch_:
            order.append(i_)
            for c in ch_:
                todo(c)
    for a_, _ in wits:
        todo(a_)
    names = [f'e{j_ + 1}' for j_ in range(len(order))] + ['fin']
    PASS = f'{CHA(1)}, {CHA(2)}'
    PSIG = f'{CHP(1)},\n    {CHP(2)}'
    chain = []
    for j_, i_ in enumerate(order):
        fr, ot = front(), rend(root_)
        h_, ch_ = nodes[i_]
        for c in ch_:
            if nodes[c][1]:
                vname[c] = next(fresh)
        pat = ', '.join('+' + (nodes[c][0] if nodes[c][1] is None else vname[c]) for c in ch_)
        var = vname[i_]
        opened.add(i_)
        nfr = front()
        chain.append([f'def {names[j_]}(-o: {D}, ' + ', '.join(f'+{n_}: {ty_}' for n_, ty_ in fr) + f', {PSIG}, +eo: {{o == {ot} : {D}}}) -> {GOAL("o")}:',
                      f'  match {var}:',
                      f'    case {h_}{{{pat}}}: {names[j_ + 1]}(o, ' + ', '.join(n_ for n_, _ in nfr) + f', {PASS}, eo)', ''])
    assert rend(root_) == OBJT, (rend(root_), OBJT)
    w(f"""def fin(-o: {D}, {SIG1}, {SIG2}, {PSIG}, +eo: {{o == {OBJT} : {D}}}) -> {GOAL("o")}:
  %Equal.sym({D}, o, {OBJT}, eo) : {GOAL("_")}
  enc1({WA1}, dw1, t1, N1, c1, pf1, hdw1, ec1, hc1, hroom1, {WA2}, dw2, t2, N2, c2, pf2, hdw2, ec2, hc2, hroom2, ecq1, ecq2)
""")
    for b_ in reversed(chain):
        L.extend(b_)
    # the children's storage: (hs1, hs2) -> the encode laws' premises
    O2 = objx(WORDS(1), PL(2))
    O3 = objx(WORDS(1), WORDS(2))
    eo2 = (f'      e1(o, {XA}, {CHA(1)}, dw2, t2, N2, c2, pf2, hdw2, ec2, hc2, hroom2, {{==}}, '
           f'Equal.trans({D}, o, {O2}, {O3}, eo, Equal.cong(O.Words, {D}, z => {objx(WORDS(1), "z")}, {PL(2)}, {WORDS(2)}, ew2)))')
    w(f"""def st2(-o: {D}, {XS}, {CHP(1)}, +eo: {{o == {O2} : {D}}},
    {ELEN(2)}, {HLIM(2)}, {HS(2)}) -> {GOAL("o")}:
  match hs2:
    case Inl{{s}}:
{inl(2)}
{eo2}
    case Inr{{s}}:
{inr(2)}
{eo2}
""")
    O1_ = objx(PL(1), PL(2))
    eo1 = (f'      st2(o, {XA}, dw1, t1, N1, c1, pf1, hdw1, ec1, hc1, hroom1, {{==}}, '
           f'Equal.trans({D}, o, {O1_}, {O2}, eo, Equal.cong(O.Words, {D}, z => {objx("z", PL(2))}, {PL(1)}, {WORDS(1)}, ew1)), elen2, hlim2, hs2)')
    w(f"""def st1(-o: {D}, {XS}, +eo: {{o == {O1_} : {D}}},
    {ELEN(1)}, {HLIM(1)}, {HS(1)}, {ELEN(2)}, {HLIM(2)}, {HS(2)}) -> {GOAL("o")}:
  match hs1:
    case Inl{{s}}:
{inl(1)}
{eo1}
    case Inr{{s}}:
{inr(1)}
{eo1}
""")
    BX = f'O.Boxed<{CD}>'

    def ceq(k):
        ck = cobjw(k, PL(k))
        return (f'Equal.trans({BX}, {PJ(k)}, O.BSome{{{PB(k)}, O.BNone{{}}}}, O.BSome{{{ck}, O.BNone{{}}}}, eb{k}, '
                f'Equal.cong({CD}, {BX}, z => O.BSome{{z, O.BNone{{}}}}, {PB(k)}, {ck}, ec{k}))')
    B1 = f'O.BSome{{{cobjw(1, PL(1))}, O.BNone{{}}}}'
    B2 = f'O.BSome{{{cobjw(2, PL(2))}, O.BNone{{}}}}'
    EO = (f'Equal.trans({D}, o, {D}{{{PJ(1)}, {PJ(2)}}}, {O1_}, e0, Equal.trans({D}, {D}{{{PJ(1)}, {PJ(2)}}}, {D}{{{B1}, {PJ(2)}}}, {O1_}, '
          f'Equal.cong({BX}, {D}, z => {D}{{z, {PJ(2)}}}, {PJ(1)}, {B1}, {ceq(1)}), Equal.cong({BX}, {D}, z => {D}{{{B1}, z}}, {PJ(2)}, {B2}, {ceq(2)})))')
    un = ['  (+e0, +q) = rep', '  (+rb1, +rb2) = q']
    for k in (1, 2):
        un.append(f'  (+eb{k}, +ri{k}) = rb{k}')
        cur = f'ri{k}'
        for j_, (x, _) in enumerate(cw):
            un.append(f'  (+{x}_{k}, +a{j_}_{k}) = {cur}')
            cur = f'a{j_}_{k}'
        un += [f'  (+ec{k}, +b1_{k}) = {cur}', f'  (+wf{k}, +b2_{k}) = b1_{k}', f'  (+elen{k}, +hlim{k}) = b2_{k}']
    w(f'''# (i): for every object the root law represents, its children's list fields stored at depth below 31 (hs1, hs2)
def {R}_e2e_encode(-o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {HS(1)}, {HS(2)}) -> {GOAL("o")}:
''' + '\n'.join(un) + f'''
  st1(o, {XA}, {EO}, elen1, hlim1, hs1, elen2, hlim2, hs2)
''')
    return '\n'.join(L)


VENC_SHAPES['AttesterSlashing'] = lambda R, X: venc_nest2(R, X, 'IndexedAttestation')
VENC_PREMISE['AttesterSlashing'] = ('rep: RT.rep_AttesterSlashing(o, Spec.AttesterSlashing()) and hs1, hs2: U.sd(each child\'s list field) '
                                    '(its storage at depth below 31: the encode laws take dw < 31, the root law dw < 32)')


# ---- e2e/e2e_gwin.bend: the generic containers' fields at byte windows (shared) ----
def gwin_text():
    L_ = [f'l{i}' for i in range(32)]

    def W(bits):
        return 'U32{' + ''.join(f'WCon{{{b}, ' for b in bits) + 'WNil{}' + '}' * len(bits) + '}'
    WW = W(L_)
    low = [f'Bool.and({l}, True{{}})' for l in L_[:16]]
    WA = W(low + [f'Bool.and({l}, False{{}})' for l in L_[16:]])
    WZ = W(low + ['False{}'] * 16)
    P = ', '.join(f'+{l}: Bool' for l in L_)
    A = ', '.join(L_)
    RHS = lambda y: f'PB.v16of(U32.and({y}, 255), U32.and(U32.shrn({y}, 8n), 255))'  # noqa: E731
    steps = []
    for i in range(16, 32):
        cur = low + ['False{}'] * (i - 16) + ['_'] + [f'Bool.and({l}, False{{}})' for l in L_[i + 1:]]
        steps.append(f'  %Equal.sym(Bool, Bool.and(l{i}, False{{}}), False{{}}, af(l{i})) : {{{W(cur)} == {WZ} : U32}}')
    pat = 'U32{' + ''.join(f'WCon{{+{l}, ' for l in L_) + 'WNil{}' + '}' * 32 + '}'
    return f'''import Base
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/vspec.bend as VS
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/spec_fixed.bend as F
import ../proofs/obj/vua.bend as UA
import ../proofs/obj/vua_rd.bend as UR
import ../proofs/obj/vbitl.bend as VBL
import ../proofs/obj/pb_min.bend as PB
import ../proofs/obj/vfx_u8.bend as FX8

# GENERATED by codegen/e2e_bridge.py (codegen/e2e_var_c.py). Do not edit.
# The generic containers' fields at byte windows, shared by the e2e bridges:
#   v16w  a uint16 read at byte x (vfx_u16.OBJ = O.keep(2, UR.RWN(t, x))) is the spec's value of its two bytes
#         (vfx_u16.VAL = PB.v16of(BX(t, x), BX(t, 1+x))); kv16, its bit identity on any word.

def af(+b: Bool) -> {{Bool.and(b, False{{}}) == False{{}} : Bool}}:
  match b:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def k1({P}) -> {{O.keep(2, {WW}) == {WA} : U32}}: {{==}}

def k2({P}) -> {{{WA} == {WZ} : U32}}:
''' + '\n'.join(steps) + f'''
  {{==}}

def k3({P}) -> {{{WZ} == {RHS(WW)} : U32}}: {{==}}

def k16({P}) -> {{O.keep(2, {WW}) == {RHS(WW)} : U32}}:
  Equal.trans(U32, O.keep(2, {WW}), {WA}, {RHS(WW)}, k1({A}), Equal.trans(U32, {WA}, {WZ}, {RHS(WW)}, k2({A}), k3({A})))

# the low two bytes of a word are its first two limbs, as the spec's uint16 of them
def kv16(+y: U32) -> {{O.keep(2, y) == {RHS('y')} : U32}}:
  match y:
    case {pat}: k16({A})

def h0(+l: +List<U32>) -> U32:
  match l:
    case Nil{{}}: 0
    case Con{{+a, r}}: a

def h1(+l: +List<U32>) -> U32:
  match l:
    case Nil{{}}: 0
    case Con{{a, +r}}: h0(r)

# the window's bytes x, x + 1 (x + 4 within the buffer)
def b2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}},
    +h: {{Nat.is_le(Nat.add(x, 4n), A.quad(VB.pw(d))) == True{{}} : Bool}})
    -> {{[U32.and(UR.RWN(t, x), 255), U32.and(U32.shrn(UR.RWN(t, x), 8n), 255)] == [FX8.BX(t, x), FX8.BX(t, 1n+x)] : +List<U32>}}:
  +e2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add(x, 4n)) == True{{}} : Bool}}, Nat.add(x, 2n), Nat.add(2n, x), FD.nat__add_comm(x, 2n), FD.nat__le_add_left(2n, 4n, x, {{==}}))
  +hl = FD.nat__lt_le_trans(1n+x, Nat.add(x, 4n), A.quad(VB.pw(d)), FD.nat__succ_le_lt(1n+x, Nat.add(x, 4n), e2), h)
  +hB = FD.logic__subst(Nat, z => {{Nat.is_lt(1n+x, z) == True{{}} : Bool}}, A.quad(VB.pw(d)), List.length(&2, U32, UA.BYT(t)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), A.quad(VB.pw(d)), FX8.lenB(d, t, pf)), hl)
  Equal.trans(+List<U32>, VS.bt(2n, F.limbs([UR.RWN(t, x)])), VS.bt(2n, VS.bdr(x, UA.BYT(t))), [VBL.nthb(UA.BYT(t), x), VBL.nthb(UA.BYT(t), 1n+x)],
    Equal.trans(+List<U32>, VS.bt(2n, F.limbs([UR.RWN(t, x)])), VS.bt(2n, VS.bt(4n, VS.bdr(x, UA.BYT(t)))), VS.bt(2n, VS.bdr(x, UA.BYT(t))),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(2n, z), F.limbs([UR.RWN(t, x)]), VS.bt(4n, VS.bdr(x, UA.BYT(t))), UR.rwn_bytes(d, t, x, pf, h)),
      VS.bt_bt(2n, 2n, VS.bdr(x, UA.BYT(t)))),
    FX8.bt2(UA.BYT(t), x, hB))

# a uint16 read at byte x is the spec's uint16 of its two bytes
def v16w(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}},
    +h: {{Nat.is_le(Nat.add(x, 4n), A.quad(VB.pw(d))) == True{{}} : Bool}})
    -> {{O.keep(2, UR.RWN(t, x)) == PB.v16of(FX8.BX(t, x), FX8.BX(t, 1n+x)) : U32}}:
  +R = UR.RWN(t, x)
  +eb = b2(d, t, x, pf, h)
  +e0 = Equal.cong(+List<U32>, U32, l => h0(l), [U32.and(R, 255), U32.and(U32.shrn(R, 8n), 255)], [FX8.BX(t, x), FX8.BX(t, 1n+x)], eb)
  +e1 = Equal.cong(+List<U32>, U32, l => h1(l), [U32.and(R, 255), U32.and(U32.shrn(R, 8n), 255)], [FX8.BX(t, x), FX8.BX(t, 1n+x)], eb)
  Equal.trans(U32, O.keep(2, R), {RHS('R')}, PB.v16of(FX8.BX(t, x), FX8.BX(t, 1n+x)), kv16(R),
    Equal.trans(U32, {RHS('R')}, PB.v16of(FX8.BX(t, x), U32.and(U32.shrn(R, 8n), 255)), PB.v16of(FX8.BX(t, x), FX8.BX(t, 1n+x)),
      Equal.cong(U32, U32, z => PB.v16of(z, U32.and(U32.shrn(R, 8n), 255)), U32.and(R, 255), FX8.BX(t, x), e0),
      Equal.cong(U32, U32, z => PB.v16of(FX8.BX(t, x), z), U32.and(U32.shrn(R, 8n), 255), FX8.BX(t, 1n+x), e1)))
'''


SUPPORT_OUT['e2e_gwin.bend'] = gwin_text()


# ---- (ii)/(iii): VarTestStruct: {uint16, List[uint16, 1024], uint8} at byte windows ----
def gwin_u16list_text():
    """lv: the root view of a List[uint16, N] child read at a byte window is its codec value."""
    return '''
# a list of uint16 read at the byte window (x, off, len): its root view is its codec value
def lv(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hc: {CH0.CHKw(t, x, off, len) == True{} : Bool}) -> {PBF.vview2(CH0.OBJw(d, t, x, off, len)) == CH0.VALw(t, x, len) : S.Value}:
  +ec = PL.c2(len, CH0.CQ(len), CH0.eLc(t, x, off, len, hc))
  +eb = BL.bview(d, t, off, len, x, eo, hd, hw, pf)
  %Equal.sym(Nat, U32.to_nat(U32.shrn(len, 1n)), CH0.CQ(len), ec) : {S.Sequence{PBF.it2(_, WO.wview(O.Words{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}))} == CH0.VALw(t, x, len) : S.Value}
  %Equal.sym(+List<U32>, WO.wview(O.Words{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}), UW.WX(t, x, U32.to_nat(len)), eb) : {S.Sequence{PBF.it2(CH0.CQ(len), _)} == CH0.VALw(t, x, len) : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, PBF.it2(CH0.CQ(len), UW.WX(t, x, U32.to_nat(len))), PBM.it2(CH0.CQ(len), UW.WX(t, x, U32.to_nat(len))), PL.it2eq(CH0.CQ(len), UW.WX(t, x, U32.to_nat(len))))
'''


def vartest_view(R, X):
    src = _dc_module(R).read_text()
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = (ROOT / 'proofs/obj' / wm).read_text()
    ch = re.search(r'^import \./(\S+) as CH0$', wsrc, re.M).group(1)
    x0, x6 = 'Nat.add(0n, U32.to_nat(0))', 'Nat.add(0n, U32.to_nat(6))'
    CH = f'CH0.OBJw(d, t, W.XJ0(t, 0n), W.FJ0(0, t, 0n), W.LJ0(t, 0n, n))'
    CV = 'CH0.VALw(t, W.XJ0(t, 0n), W.LJ0(t, 0n, n))'
    U16 = f'S.UnsignedValue{{P.UInt{{O.keep(2, UR.RWN(t, {x0})), 0, 0, 0, 0, 0, 0, 0}}}}'
    V16 = f'FX16.VAL(t, {x0})'
    U8 = f'FX8.VAL(t, {x6})'
    WA = 'd, t, n, 0n, 0, n, {==}, hd, hn, pf, h'
    text = f'''# ---- the view of a decoded object is the codec law's value ----
{gwin_u16list_text()}
def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}}:
  +h = hchk
  +h4 = FD.nat__le_trans(Nat.add({x0}, 4n), U32.to_nat(n), A.quad(VB.pw(d)), FD.nat__le_trans(Nat.add({x0}, 4n), U32.to_nat(7), U32.to_nat(n), {{==}}, W.hFc(t, 0n, 0, n, h)), hn)
  +e16 = GW.v16w(d, t, {x0}, pf, h4)
  +el = lv(d, t, W.XJ0(t, 0n), W.FJ0(0, t, 0n), W.LJ0(t, 0n, n), W.eoJ0({WA}), hd, W.hwJ0({WA}), pf, W.itD0(t, 0n, 0, n, h))
  Equal.trans(S.Value, S.Sequence{{S.Items{{{U16}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, S.Sequence{{S.Items{{{V16}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, DC.VAL(t, n),
    Equal.cong(U32, S.Value, z => S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{z, 0, 0, 0, 0, 0, 0, 0}}}}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, O.keep(2, UR.RWN(t, {x0})), PBM.v16of(FX8.BX(t, {x0}), FX8.BX(t, 1n+{x0})), e16),
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{{V16}, S.Items{{z, S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, PBF.vview2({CH}), {CV}, el))

'''
    return {'view': f'RT.v_{X}',
            'imports': ['import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/packed_bytes.bend as PBF',
                        'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/vua_win.bend as UW', 'import ../proofs/obj/vua_rd.bend as UR',
                        'import ../proofs/obj/vbuf.bend as VB', 'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_gwin.bend as GW',
                        f'import ../proofs/obj/{wm} as W', f'import ../proofs/obj/{ch} as CH0',
                        'import ../proofs/obj/vfx_u16.bend as FX16', 'import ../proofs/obj/vfx_u8.bend as FX8'],
            'text': text}


VDEC_VIEWS['Gc465214E502'] = vartest_view('VarTestStruct', 'Gc465214E502')


# ---- (ii)/(iii): CompatibleUnions (codegen/var_winu's layout: a selector byte, then the arm's window) ----
# CHILD_VIEWS[arm window module] = f(obj, val, a) -> proof text of {view(obj) == val} at the arm's window
# (a = its window args x, off, len, and the helpers' context); None: they convert.
UNION_CHILD = {'var_winx_GpF350A3C486.bend': None}


def union_view(R, X):
    src = _dc_module(R).read_text()
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = (ROOT / 'proofs/obj' / wm).read_text()
    alias_mod = dict((a, m) for m, a in re.findall(r'^import \./(\S+) as (CH\d+)$', wsrc, re.M))
    ks = sorted(int(k) for k in re.findall(r'^def K(\d+)\(c: Bool', wsrc, re.M))
    sels = {}
    for k in ks:
        sels[k] = None
    s0 = re.search(r'^def CHKw\(.*?K0\(U32\.is_eq\(BX\(t, x\), (\d+)\)', wsrc, re.M).group(1)
    sels[0] = s0
    for k in ks[:-1]:
        sels[k + 1] = re.search(rf'^def K{k}\(c: Bool.*?\n.*?\n.*?\n    case False{{}}: K{k + 1}\(U32\.is_eq\(s, (\d+)\)', wsrc, re.M | re.S).group(1)
    arm = {}
    for k in ks:
        arm[k] = re.search(rf'^def K{k}\(c: Bool.*?\n.*?\n    case True{{}}: (CH\d+)\.CHKw', wsrc, re.M | re.S).group(1)
    rt = 'root_gtypes2'
    vsrc = (ROOT / f'proofs/obj/{rt}.bend').read_text()
    vbody = re.search(rf'^def v_{X}\(o: .*?\n  match o:\n((?:    case .*\n)+)', vsrc, re.M).group(1)
    ctor = dict((int(c), (sel, vw)) for c, sel, vw in re.findall(rf'case \w+\.{X}_c(\d+){{v}}: S\.Selected{{(\d+), ([\w.]+)\(v\)}}', vbody))
    WIN = 'XJ(t, x), FJ(off), LJ(len)'
    L = []
    last = ks[-1]
    for k in reversed(ks):
        ch = arm[k]
        # the object's constructor for arm k (OB_k's True case)
        oc = re.search(rf'^def OB{k}\(c: Bool.*?\n.*?\n    case True{{}}: (\w+\.{X}_c(\d+))\{{', wsrc, re.M | re.S)
        cidx = int(oc.group(2))
        sel, vw = ctor[cidx]
        assert sel == sels[k], (X, k, sel, sels[k])
        vw = vw if '.' in vw else f'RT.{vw}'
        obj = f'W.{ch}.OBJw(d, t, W.{WIN.replace("XJ(", "XJ(").replace("FJ(", "FJ(").replace("LJ(", "LJ(")})'
        obj = f'{ch}.OBJw(d, t, W.XJ(t, x), W.FJ(off), W.LJ(len))'
        val = f'{ch}.VALw(t, W.XJ(t, x), W.LJ(len))'
        cv = UNION_CHILD[alias_mod[ch]]
        cvp = '{==}' if cv is None else cv(obj, val)
        GOAL = f'{{RT.v_{X}(W.OB{k}(c, W.BX(t, x), d, t, x, off, len)) == S.Selected{{W.BX(t, x), W.VV{k}(c, W.BX(t, x), t, x, len)}} : S.Value}}'
        nxt = (f'      u{k + 1}(d, t, x, off, len, U32.is_eq(W.BX(t, x), {sels[k + 1]}), {{==}}, hk)' if k != last else
               f'      Empty.absurd({GOAL.replace("(c, ", "(False{}, ")}, FD.logic__false_true(hk))')
        L.append(f'''def u{k}(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +c: Bool, +ec: {{U32.is_eq(W.BX(t, x), {sel}) == c : Bool}},
    +hk: {{W.K{k}(c, W.BX(t, x), t, x, off, len) == True{{}} : Bool}}) -> {GOAL}:
  match c:
    case True{{}}:
      %Equal.sym(U32, W.BX(t, x), {sel}, FD.u32alg__eq_of(W.BX(t, x), {sel}, ec)) : {{RT.v_{X}(W.OB{k}(True{{}}, W.BX(t, x), d, t, x, off, len)) == S.Selected{{_, W.VV{k}(True{{}}, W.BX(t, x), t, x, len)}} : S.Value}}
      Equal.cong(S.Value, S.Value, z => S.Selected{{{sel}, z}}, {vw}({obj}), {val}, {cvp})
    case False{{}}:
{nxt}
''')
    text = f'''# ---- the view of a decoded object is the codec law's value: the selected arm's view at its window ----

{chr(10).join(L)}
def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}}:
  u0(d, t, 0n, 0, n, U32.is_eq(W.BX(t, 0n), {sels[0]}), {{==}}, FD.logic__and_right(U32.is_le(1, n), W.K0(U32.is_eq(W.BX(t, 0n), {sels[0]}), W.BX(t, 0n), t, 0n, 0, n), hchk))

'''
    chs = sorted(set(arm.values()))
    return {'view': f'RT.v_{X}',
            'imports': [f'import ../proofs/obj/{rt}.bend as RT', 'import ../proofs/obj/root_gnames.bend as RN', f'import ../proofs/obj/{wm} as W']
            + [f'import ../proofs/obj/{alias_mod[c]} as {c}' for c in chs],
            'text': text}


VDEC_VIEWS['GuA2212AE21F'] = union_view('CompatibleUnionA', 'GuA2212AE21F')


# ---- (iv): CompatibleUnions, from rep (DK.Or2 over the arms' pc_X_k: the arm's value v and o == X_ck{v}) ----
def vroot_union(R, X, rt='root_gtypes2', gv='gvalid_gtypes2'):
    vsrc = (ROOT / f'proofs/obj/{rt}.bend').read_text()
    rep = re.search(rf'^def rep_{X}\(o: \w+\.{X}\) -> Data: (.*)$', vsrc, re.M).group(1)
    arms = [int(k) for k in re.findall(rf'pc_{X}_(\d+)\(o\)', rep)]
    D = f'T.{X}'
    ty = {}
    for k in arms:
        m = re.search(rf'^def pc_{X}_{k}\(o: .*?\) -> Data: DK\.Ex\((\w+)\.(\w+), v =>', vsrc, re.M)
        ty[k] = f'T.{m.group(2)}'
    CO = lambda k: f'{D}_c{k}{{v}}'  # noqa: E731
    RX = lambda o: f'D.bytes(Pair.snd({D}, D.Digest, Pair.snd(B.Buf, {D} & D.Digest, T.{X}_hash_tree_root(h, {o}))))'  # noqa: E731
    G = lambda o: f'{{Some{{{RX(o)}}} == API.hash_tree_root(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    L = []
    for k in arms:
        L.append(f'''def rt1_{k}(h: B.Buf, +v: {ty[k]}, +rep: RT.rep_{X}({CO(k)})) -> {G(CO(k))}:
  E.root_legal(Spec.{X}(), RT.v_{X}({CO(k)}), VS.public_sound(Spec.{X}(), {{==}}), {RX(CO(k))},
    GV.{X}_root_valid({CO(k)}, rep), RT.{X}_root_correct(h, {CO(k)}, rep))

def rt2_{k}(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o), +v: {ty[k]}, +eo: {{o == {CO(k)} : {D}}}) -> {G('o')}:
  %Equal.sym({D}, o, {CO(k)}, eo) : {G('_')}
  rt1_{k}(h, v, FD.logic__subst({D}, z => RT.rep_{X}(z), o, {CO(k)}, eo, rep))
''')
    # the Or2 tree over the arms: Or2(a0, Or2(a1, ..)) or a single pc
    def arm_case(k, var, ind):
        return (f'{ind}(+v, +q) = {var}\n{ind}(+eo, +rp) = q\n{ind}rt2_{k}(h, o, rep, v, eo)')
    assert len(arms) == 1, (X, 'multi-arm unions: rep is por_X_0 (an Or over the arms), not written yet')
    body = arm_case(arms[0], 'rep', '  ')
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/generic_obj.bend as T', 'import ../types/schema.bend as S',
            'import ../proofs/obj/generic_specs.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            f'import ../proofs/obj/{rt}.bend as RT', f'import ../proofs/obj/{gv}.bend as GV', 'import ../proofs/obj/dk.bend as DK', 'import ./e2e_support.bend as E']
    return '\n'.join(imps) + f"""

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (a CompatibleUnion): the object API's root is END_TO_END's hash_tree_root, for every object the
# root law represents (rep_{X}: the selected arm's value, represented).

""" + '\n'.join(L) + f"""
# (iv)
def {R}_e2e_root(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o)) -> {G('o')}:
{body}
"""


VROOT_SHAPES['GuA2212AE21F'] = vroot_union
