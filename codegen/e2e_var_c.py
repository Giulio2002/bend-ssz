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
import ../proofs/obj/gleaf.bend as GL
import ../proofs/u32_order.bend as UO
import ../proofs/power_division.bend as PD
import ../proofs/word_split.bend as WSp
import ../proofs/obj/vu32.bend as VU

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
''' + gwin_more()





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


# ---- (i): the names whose encode laws go through an encx record (codegen/var_cont_top: CI.MW, OK, TH, VAL) ----
# enc_m: for every record m with OK(m), the encoder's bytes of TH(m) are END_TO_END's serialize of VAL(m);
# the name's own part (MWP[X]) builds m from rep with o == TH(m), v_X(TH(m)) == VAL(m) and OK(m).
MWP = {}


def venc_mw(R, X):
    dcm = _dc_module(R)
    api = (ROOT / 'proofs/api' / f'{R}_encode_ssz_proof_generated.bend').read_text()
    ci = re.search(r'^import \.\./obj/(\S+) as \w+_CI$', api, re.M).group(1)
    en = re.search(r'^import \.\./obj/(\S+) as \w+_PRV$', api, re.M).group(1)
    esrc = (ROOT / 'proofs/obj' / en).read_text()
    dep = re.search(r'^def OUTE\(\+m: CI\.MW\) -> FD\.array__Tree<U32>: CI\.PUTX\(m, (.*), VC\.ZT\(', esrc, re.M).group(1)
    room = 'EN.roomf(m, hok)' if re.search(r'^def roomf\(', esrc, re.M) else 'EN.room(m, hok, 28n, {==})'
    tmod = re.search(r'-> \{(\w+)\.' + X + r'_encode\(', esrc).group(1)
    tpath = re.search(r'^import \.\./\.\./types/(\S+) as ' + tmod + '$', esrc, re.M).group(1)
    dmod = re.search(r'-> \{\w+\.' + X + r'_encode\(CI\.TH\(m\)\) == \(CI\.TH\(m\), B\.Buf\{.*?\}\) : (\w+)\.' + X + r' & B\.Buf\}', esrc).group(1)
    dpath = re.search(r'^import \.\./\.\./types/(\S+) as ' + dmod + '$', esrc, re.M).group(1)
    D = f'{dmod}.{X}'
    ENC = f'{tmod}.{X}_encode'
    SER = lambda v: f'API.serialize(Spec.{X}(), {v})'  # noqa: E731
    OB = 'B.Buf{FD.array__thaw(U32, EN.OUTE(m)), EN.SZSM(m)}'
    BT = 'VSP.bt(U32.to_nat(EN.SZSM(m)), SF.limbs(FD.array__slots(U32, EN.OUTE(m))))'
    GOAL = lambda o, v: f'{{Some{{E.obytes(Pair.snd({D}, B.Buf, {ENC}({o})))}} == {SER(v)} : Maybe<&2, +List<U32>>}}'  # noqa: E731
    mw = MWP[X](R, X, D)
    pdefs, pbody, pimps = mw[:3]
    sig = mw[3] if len(mw) > 3 else f'+rep: RT.rep_{X}(o)'
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/obj/generic_specs.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../spec/codec.bend as Encoding',
            'import ../proofs/obj/spec_fixed.bend as SF', 'import ../proofs/obj/vspec.bend as VSP', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/vcopy.bend as VC', 'import ../proofs/obj/vuwd.bend as WD', 'import ../proofs/obj/vcont.bend as VCN',
            'import ../proofs/obj/vlist.bend as VL', 'import ../proofs/obj/dk.bend as DK',
            f'import ../proofs/obj/{ci} as CI', f'import ../proofs/obj/{en} as EN', f'import ../types/{tpath} as {tmod}', f'import ../types/{dpath} as {dmod}',
            'import ./e2e_support.bend as E', 'import ./e2e_emit.bend as EM'] + pimps
    return '\n'.join(dict.fromkeys(imps)) + f'''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (variable size): the object API's encoder's bytes are END_TO_END's serialize of the object's view,
# for every object the root law represents (rep), through its encode laws' record (CI.MW).

# the encoder's buffer: its bytes (the tree is perfect at its depth, the size within it)
def obM(+m: CI.MW, +hok: {{CI.OK(m) == True{{}} : Bool}}) -> {{E.obytes({OB}) == {BT} : +List<U32>}}:
  +g = {room}
  +hd = CI.PA(EN.HD(m), DK.P2(EN.HL(m), EN.HZ(m)), g)
  +hl = CI.PA(EN.HL(m), EN.HZ(m), CI.PB(EN.HD(m), DK.P2(EN.HL(m), EN.HZ(m)), g))
  +L = List.length(&2, U32, CI.ENC(m))
  +M = Nat.add(L, WD.PADB(0n, L))
  +hm = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw({dep}))) == True{{}} : Bool}}, A.quad(WD.NWN(L)), M, Equal.sym(Nat, M, A.quad(WD.NWN(L)), VCN.padb_id(0n, L)),
    VCN.VME4(WD.NWN(L), VB.pw({dep}), hl))
  +hL = FD.nat__le_trans(L, M, A.quad(VB.pw({dep})), FD.nat__le_add_right(L, WD.PADB(0n, L)), hm)
  +hn = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw({dep}))) == True{{}} : Bool}}, L, U32.to_nat(CI.SZ(m)), Equal.sym(Nat, U32.to_nat(CI.SZ(m)), L, CI.szx(m, hok)), hL)
  EM.ob({dep}, EN.OUTE(m), CI.SZ(m), CI.pfx(m, {dep}, VC.ZT({dep}), 0n, 0n, FD.array__trep_perfect(U32, {dep}, 0)), hd, hn)

# (i) on a record
def enc_m(+m: CI.MW, +hok: {{CI.OK(m) == True{{}} : Bool}}) -> {GOAL('CI.TH(m)', 'CI.VAL(m)')}:
  %Equal.sym({D} & B.Buf, {ENC}(CI.TH(m)), (CI.TH(m), {OB}), EN.encode_eval(m, hok)) :
    {{Some{{E.obytes(Pair.snd({D}, B.Buf, _))}} == {SER('CI.VAL(m)')} : Maybe<&2, +List<U32>>}}
  %Equal.sym(+List<U32>, E.obytes({OB}), {BT}, obM(m, hok)) : {{Some{{_}} == {SER('CI.VAL(m)')} : Maybe<&2, +List<U32>>}}
  Equal.sym(Maybe<&2, +List<U32>>, {SER('CI.VAL(m)')}, Some{{{BT}}},
    Equal.trans(Maybe<&2, +List<U32>>, {SER('CI.VAL(m)')}, Encoding.encoding_for_legal_type(Spec.{X}(), CI.VAL(m)), Some{{{BT}}},
      E.serialize_legal(Spec.{X}(), CI.VAL(m), VS.public_sound(Spec.{X}(), {{==}})), EN.encode_spec(m, hok)))

# an object, as a record: o == TH(m), its view VAL(m), OK(m)
def via(-o: {D}, +m: CI.MW, +eo: {{o == CI.TH(m) : {D}}}, +ev: {{RT.v_{X}(CI.TH(m)) == CI.VAL(m) : S.Value}}, +hok: {{CI.OK(m) == True{{}} : Bool}})
    -> {GOAL('o', f'RT.v_{X}(o)')}:
  %Equal.sym({D}, o, CI.TH(m), eo) : {GOAL('_', f'RT.v_{X}(_)')}
  %Equal.sym(S.Value, RT.v_{X}(CI.TH(m)), CI.VAL(m), ev) : {{Some{{E.obytes(Pair.snd({D}, B.Buf, {ENC}(CI.TH(m))))}} == {SER('_')} : Maybe<&2, +List<U32>>}}
  enc_m(m, hok)

{pdefs}
# (i): for every object the root law represents
def {R}_e2e_encode(-o: {D}, {sig}) -> {GOAL('o', f'RT.v_{X}(o)')}:
{pbody}
'''


def mwp_union_a(R, X, D):
    """CompatibleUnionA: rep is the arm's value v = GpF350A3C486{x} with x < 256; m = MW0{x}."""
    C = 'ProgressiveSingleFieldContainerTestStruct_d.GpF350A3C486'
    O1 = f'{D}_c0{{{C}{{x}}}}'
    defs = f'''def u1(-o: {D}, +x: U32, +eo: {{o == {O1} : {D}}}, +hv: {{U32.is_lt(x, 256) == True{{}} : Bool}})
    -> {{Some{{E.obytes(Pair.snd({D}, B.Buf, CompatibleUnionA_e.{X}_encode(o)))}} == API.serialize(Spec.{X}(), RT.v_{X}(o)) : Maybe<&2, +List<U32>>}}:
  +hok = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(x), U32.to_nat(255)), U32.is_le(x, 255),
    Equal.sym(Bool, U32.is_le(x, 255), Nat.is_le(U32.to_nat(x), U32.to_nat(255)), VU.le_u32(x, 255)), LB.small(x, hv))
  +ev = Equal.cong(U32, S.Value, z => S.Selected{{1, S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{z, 0, 0, 0, 0, 0, 0, 0}}}}, S.EmptyItems{{}}}}}}}}, x, U32.and(x, 255),
    Equal.sym(U32, U32.and(x, 255), x, VBB.ea(x, hv)))
  via(o, CI.MW0{{x}}, eo, ev, hok)

def u0(-o: {D}, +v: {C}, +eo: {{o == {D}_c0{{v}} : {D}}}, +rp: RN.rp_GpF350A3C486(v))
    -> {{Some{{E.obytes(Pair.snd({D}, B.Buf, CompatibleUnionA_e.{X}_encode(o)))}} == API.serialize(Spec.{X}(), RT.v_{X}(o)) : Maybe<&2, +List<U32>>}}:
  match v:
    case {C}{{+x}}: u1(o, x, eo, rp)
'''
    body = '''  (+v, +q) = rep
  (+eo, +rp) = q
  u0(o, v, eo, rp)'''
    imps = ['import ../proofs/obj/root_gtypes2.bend as RT', 'import ../proofs/obj/root_gnames.bend as RN', 'import ../proofs/obj/vu32.bend as VU',
            'import ../proofs/obj/len_bridge.bend as LB', 'import ../proofs/obj/vbitb.bend as VBB',
            'import ../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as ProgressiveSingleFieldContainerTestStruct_d']
    return defs, body, imps


MWP['GuA2212AE21F'] = mwp_union_a
VENC_SHAPES['GuA2212AE21F'] = venc_mw


def mwp_vartest(R, X, D):
    """VarTestStruct: its record from rep and the list's storage premise (e2e_encr.vtb)."""
    K = encr_k('l1024')
    defs = f"""# the record's facts: the object is TH(m), its view VAL(m), m valid
def vt1(-o: {D}, +c: ER.VTR(o)) -> {{Some{{E.obytes(Pair.snd({D}, B.Buf, {R}_e.{X}_encode(o)))}} == API.serialize(Spec.{X}(), RT.v_{X}(o)) : Maybe<&2, +List<U32>>}}:
  (+m, +c1) = c
  (+eo, +c2) = c1
  (+ev, +c3) = c2
  (+hok, +hl) = c3
  via(o, m, eo, ev, hok)
"""
    body = '  vt1(o, ER.vtb(o, rep, hs))'
    imps = ['import ../proofs/obj/root_gtypes.bend as RT', 'import ./e2e_blist.bend as BL', 'import ./e2e_encr.bend as ER']
    sig = f'+rep: RT.rep_{X}(o, Spec.{X}()), +hs: BL.sdk(RT.pj_{X}_1(o), {K}n)'
    return defs, body, imps, sig


MWP['Gc465214E502'] = mwp_vartest


# ---- (iv) for a container whose rep projects several fields (ComplexTestStruct): each projected field is
# copied to a runtime value from its rep's witness (cpw: byte storage, cpv: a nested VarTestStruct, cpa: a
# vector's array), the object is rewritten to the literal built from them, and the root law applies there.
CPX = {
    'Gc56D855869F': {
        'mods': ['ComplexTestStruct_d:ComplexTestStruct_def_generated', 'VarTestStruct_d:VarTestStruct_def_generated',
                 'vec_FixedTestStruct_4_d:vec_FixedTestStruct_4_def_generated', 'vec_VarTestStruct_2_d:vec_VarTestStruct_2_def_generated',
                 'FixedTestStruct_d:FixedTestStruct_def_generated'],
        'hmod': 'ComplexTestStruct_h:ComplexTestStruct_hashtreeroot_generated',
        # (kind, field type) in field order; rep: x0, x2, eo, then per field its part in order
        'fields': [('u', 'U32'), ('l', 'O.Words'), ('u', 'U32'), ('l', 'O.Words'), ('c', 'VarTestStruct_d.Gc465214E502'),
                   ('a', 'vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq'), ('a', 'vec_VarTestStruct_2_d.v2_Gc465214E502_Seq')],
    },
}
CPA = {  # a vector's rep: its storage t (element type), the object is Seq{ARR(t), N}
    'vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq': ('rep_v4_GcDC3E457711', 'FixedTestStruct_d.GcDC3E457711', 'FD.array__thaw(FixedTestStruct_d.GcDC3E457711, {t})'),
    'vec_VarTestStruct_2_d.v2_Gc465214E502_Seq': ('rep_v2_Gc465214E502', 'RT.MB<RT.M_Gc465214E502>', 'RT.am_v2_Gc465214E502({t})'),
}
CPV = 'VarTestStruct_d.Gc465214E502'


def _cp_shape(kd, T, k):
    """A projected field's runtime copy: its Data witnesses (name, type) and the literal they build."""
    W = lambda t, n: f'O.Words{{FD.array__thaw(U32, {t}), {n}}}'  # noqa: E731
    if kd == 'u':
        return [(f'x{k}', 'U32')], f'x{k}'
    if kd == 'l':
        return [(f't{k}', 'FD.array__Tree<U32>'), (f'N{k}', 'U32')], W(f't{k}', f'N{k}')
    if kd == 'c':
        return ([(f'a{k}', 'U32'), (f'b{k}', 'U32'), (f't{k}', 'FD.array__Tree<U32>'), (f'N{k}', 'U32')],
                f'{CPV}{{a{k}, {W(f"t{k}", f"N{k}")}, b{k}}}')
    rp, el, arr = CPA[T]
    return [(f't{k}', f'FD.array__Tree<{el}>'), (f'N{k}', 'U32')], f'{T}{{{arr.format(t=f"t{k}")}, N{k}}}'


def _ex(vs, eq):
    """DK.Ex over the witnesses vs, ending in the equation eq."""
    out = eq
    for v, T in reversed(vs):
        out = f'DK.Ex({T}, {v} => {out})'
    return out


def _tup(vs, pf):
    out = pf
    for v, _ in reversed(vs):
        out = f'({v}, {out})'
    return out


def vroot_complex(R, X):
    c = CPX[X]
    hm, hp = c['hmod'].split(':')
    D = f'{R}_d.{X}'
    fs = c['fields']
    n = len(fs)
    PJ = lambda k: f'RT.pj_{X}_{k}(o)'  # noqa: E731
    SK = lambda k: 'SH.Chain_head(' + 'SH.Chain_tail(' * k + f'SH.Container_fields(Spec.{X}())' + ')' * k + ')'  # noqa: E731
    shp = [_cp_shape(kd, T, k) for k, (kd, T) in enumerate(fs)]
    OL = f'{D}{{{", ".join(lit for _, lit in shp)}}}'
    allv = [v for vs, _ in shp for v in vs]
    runt = ', '.join(f'+{v}: {T}' for v, T in allv)
    wargs = ', '.join(v for v, _ in allv)
    BY = lambda o: f'D.bytes(Pair.snd({D}, D.Digest, Pair.snd(B.Buf, {D} & D.Digest, {hm}.{X}_hash_tree_root(h, {o}))))'  # noqa: E731
    G = lambda o: f'{{Some{{{BY(o)}}} == API.hash_tree_root(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    wsig = [('t', 'FD.array__Tree<U32>'), ('N', 'U32')]
    WL = 'O.Words{FD.array__thaw(U32, t), N}'
    L = []
    L.append(f"""# byte storage (list_obj.wfl): its tree and length
def cpw(-w: O.Words, +wf: LO.wfl(w)) -> {_ex(wsig, f'{{w == {WL} : O.Words}}')}:
  match wf:
    case Inl{{s}}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+ew, s4) = s3
      (t, (N, ew))
    case Inr{{s}}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+q, s4) = s3
      (+r, s5) = s4
      (+ew, s6) = s5
      (t, (N, ew))
""")
    if any(kd == 'c' for kd, _ in fs):
        V = CPV
        P1 = 'RT.pj_Gc465214E502_1(v)'
        vsig = [('x0', 'U32'), ('x2', 'U32'), ('t', 'FD.array__Tree<U32>'), ('N', 'U32')]
        VL = f'{V}{{x0, {WL}, x2}}'
        L.append(f"""# a VarTestStruct (rep_Gc465214E502): its words and its list's tree and length
def cpv2(-v: {V}, +x0: U32, +x2: U32, +ev: {{v == {V}{{x0, {P1}, x2}} : {V}}}, +c: {_ex(wsig, f'{{{P1} == {WL} : O.Words}}')}) -> {_ex(vsig, f'{{v == {VL} : {V}}}')}:
  (+t, +c1) = c
  (+N, +ew) = c1
  (x0, (x2, (t, (N, Equal.trans({V}, v, {V}{{x0, {P1}, x2}}, {VL}, ev, Equal.cong(O.Words, {V}, z => {V}{{x0, z, x2}}, {P1}, {WL}, ew))))))

def cpv(-v: {V}, +s: S.Schema, +rep: RT.rep_Gc465214E502(v, s)) -> {_ex(vsig, f'{{v == {VL} : {V}}}')}:
  (+x0, +r0) = rep
  (+x2, +r1) = r0
  (+ev, +q1) = r1
  (+h0, +q2) = q1
  (+c1, +h2) = q2
  (+wf, +z1) = c1
  cpv2(v, x0, x2, ev, cpw({P1}, wf))
""")
    for k, (kd, T) in enumerate(fs):
        if kd == 'a':
            rp, el, arr = CPA[T]
            asig = [('t', f'FD.array__Tree<{el}>'), ('N', 'U32')]
            AL = f'{T}{{{arr.format(t="t")}, N}}'
            L.append(f"""# field {k}, a vector: its tree and length
def cpa{k}(-v: {T}, +s: S.Schema, +rep: RT.{rp}(v, s)) -> {_ex(asig, f'{{v == {AL} : {T}}}')}:
  (+ex, +hl) = rep
  (+t, +e1) = ex
  (+dw, +e2) = e1
  (+N, +e3) = e2
  (+eq, +e4) = e3
  (t, (N, eq))
""")
    L.append(f"""# the literal object
def rt1(h: B.Buf, {runt}, +rep: RT.rep_{X}({OL}, Spec.{X}())) -> {G(OL)}:
  E.root_legal(Spec.{X}(), RT.v_{X}({OL}), VS.public_sound(Spec.{X}(), {{==}}), {BY(OL)},
    GV.{X}_root_valid({OL}, Spec.{X}(), {{==}}, rep), RT.{X}_root_correct(h, {OL}, Spec.{X}(), {{==}}, rep))

# the object as the literal
def rt2(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {runt}, +eo: {{o == {OL} : {D}}}) -> {G('o')}:
  %Equal.sym({D}, o, {OL}, eo) : {G('_')}
  rt1(h, {wargs}, FD.logic__subst({D}, z => RT.rep_{X}(z, Spec.{X}()), o, {OL}, eo, rep))
""")
    cur = [f'x{k}' if kd == 'u' else PJ(k) for k, (kd, _) in enumerate(fs)]
    E0 = f'{D}{{{", ".join(cur)}}}'
    cps = [(k, T) for k, (kd, T) in enumerate(fs) if kd != 'u']
    us = [k for k, (kd, _) in enumerate(fs) if kd == 'u']
    eqn = 'eo'
    for k, T in cps:
        nxt = list(cur)
        nxt[k] = shp[k][1]
        mot = list(cur)
        mot[k] = 'z'
        step = f'Equal.cong({T}, {D}, z => {D}{{{", ".join(mot)}}}, {PJ(k)}, {shp[k][1]}, e{k})'
        eqn = f'Equal.trans({D}, o, {D}{{{", ".join(cur)}}}, {D}{{{", ".join(nxt)}}},\n    {eqn},\n    {step})'
        cur = nxt
    cparams = ', '.join(f'+c{k}: {_ex(shp[k][0], f"{{{PJ(k)} == {shp[k][1]} : {T}}}")}' for k, T in cps)
    unp = []
    for k, _ in cps:
        vs = shp[k][0]
        src = f'c{k}'
        for i, (v, _) in enumerate(vs):
            nx = f'e{k}' if i == len(vs) - 1 else f'c{k}_{i}'
            unp.append(f'  (+{v}, +{nx}) = {src}')
            src = nx
    uparams = ', '.join(f'+x{k}: U32' for k in us)
    L.append(f"""# the copies, and the object's equation to the literal
def g1(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {uparams}, +eo: {{o == {E0} : {D}}}, {cparams}) -> {G('o')}:
{chr(10).join(unp)}
  rt2(h, o, rep, {wargs}, {eqn})
""")
    lines = [f'  (+x{us[0]}, +r0) = rep', f'  (+x{us[1]}, +r1) = r0', '  (+eo, +q0) = r1']
    pn = {i: (f'q{i}' if i == n - 1 else f'p{i}') for i in range(n)}
    for i in range(n):
        if i < n - 1:
            lines.append(f'  (+p{i}, +q{i + 1}) = q{i}')
        if fs[i][0] == 'l':
            lines.append(f'  (+wf{i}, +z{i}) = {pn[i]}')
    args = []
    for k, T in cps:
        kd = fs[k][0]
        if kd == 'l':
            args.append(f'cpw({PJ(k)}, wf{k})')
        elif kd == 'c':
            args.append(f'cpv({PJ(k)}, {SK(k)}, {pn[k]})')
        else:
            args.append(f'cpa{k}({PJ(k)}, {SK(k)}, {pn[k]})')
    lines.append(f'  g1(h, o, rep, {", ".join("x" + str(k) for k in us)}, eo,\n    ' + ',\n    '.join(args) + ')')
    body = '\n'.join(lines)
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S',
            'import ../proofs/obj/generic_specs.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/list_obj.bend as LO',
            'import ../proofs/obj/schema_shapes.bend as SH',
            'import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/gvalid_gtypes.bend as GV', 'import ./e2e_support.bend as E']
    imps += [f'import ../types/{pth}.bend as {al}' for al, pth in (m.split(':') for m in c['mods'])] + [f'import ../types/{hp}.bend as {hm}']
    return '\n'.join(imps) + f"""

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (variable size): the object API's root is END_TO_END's hash_tree_root, for every object the root law
# represents (rep_{X}: its storage fields' words in perfect trees of depth below 32, its nested objects' reps).
# The object is rebuilt from rep's witnesses (trees and lengths, which the root law's runtime arguments need).

""" + '\n'.join(L) + f"""
# (iv)
def {R}_e2e_root(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}())) -> {G('o')}:
{body}
"""


VROOT_SHAPES['Gc56D855869F'] = vroot_complex
VENC_SHAPES['Gc465214E502'] = venc_mw

def gwin_more():
    """keep2 == x below 2^16 (k2id), the spec's uint16 of a word's bytes is the word (eq16), below 2^16 is at
    most 65535 (small16), an even length has a zero low bit (ev)."""
    A16 = [f'a{i}' for i in range(16)]

    def W(bits, tail):
        return 'U32{' + ''.join(f'WCon{{{b}, ' for b in bits) + tail + '}' * len(bits) + '}'
    Z16 = 'Word.zero(16n)'
    WL = W(A16, Z16)
    WT = W([f'Bool.and({a}, True{{}})' for a in A16], 'Word.and(16n, Word.zero(16n), Word.zero(16n))')
    P16 = ', '.join(f'+{a}: Bool' for a in A16)
    steps = []
    for i in range(16):
        cur = A16[:i] + ['_'] + [f'Bool.and({a}, True{{}})' for a in A16[i + 1:]]
        steps.append(f'  %Equal.sym(Bool, Bool.and(a{i}, True{{}}), a{i}, at(a{i})) : {{{W(cur, Z16)} == {WL} : U32}}')
    B = [f'b{i}' for i in range(1, 32)]
    PB31 = ', '.join(f'+{b}: Bool' for b in B)
    WE = W(['False{}'] + B, 'WNil{}')
    WEa = W(['False{}'] + [f'Bool.and({b}, False{{}})' for b in B], 'WNil{}')
    WZ = W(['False{}'] * 32, 'WNil{}')
    esteps = []
    for i, bb in enumerate(B):
        cur = ['False{}'] * (i + 1) + ['_'] + [f'Bool.and({c}, False{{}})' for c in B[i + 1:]]
        esteps.append(f'  %Equal.sym(Bool, Bool.and({bb}, False{{}}), False{{}}, af({bb})) : {{{W(cur, "WNil{}")} == {WZ} : U32}}')
    patw = ''.join(f'WCon{{+{b}, ' for b in B) + 'WNil{}' + '}' * 31
    return f"""
# ---- words below 2^16, even lengths ----

def at(+b: Bool) -> {{Bool.and(b, True{{}}) == b : Bool}}:
  match b:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def kz1({P16}) -> {{O.keep(2, {WL}) == {WT} : U32}}: {{==}}

def kz2({P16}) -> {{{WT} == {WL} : U32}}:
""" + '\n'.join(steps) + f"""
  {{==}}

def k2w(+w: Word(32n)) -> {{O.keep(2, U32{{WSp.join(16n, 16n, WSp.take(16n, 32n, w), Word.zero(16n))}}) == U32{{WSp.join(16n, 16n, WSp.take(16n, 32n, w), Word.zero(16n))}} : U32}}:
  match w:
    case {''.join(f'WCon{{+{a}, ' for a in A16)}+hi{'}' * 16}:
      Equal.trans(U32, O.keep(2, {WL}), {WT}, {WL}, kz1({', '.join(A16)}), kz2({', '.join(A16)}))

# a word below 2^16 is its low two bytes
def k2id(+x: U32, +h: {{U32.is_lt(x, 65536) == True{{}} : Bool}}) -> {{O.keep(2, x) == x : U32}}:
  %Equal.sym(U32, x, U32{{WSp.join(16n, 16n, WSp.take(16n, 32n, PD.bits(x)), Word.zero(16n))}}, GL.half_shape(x, h)) : {{O.keep(2, _) == _ : U32}}
  k2w(PD.bits(x))

# the spec's uint16 of a word's two low bytes is the word, below 2^16
def eq16(+x: U32, +h: {{U32.is_lt(x, 65536) == True{{}} : Bool}}) -> {{PB.v16of(U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)) == x : U32}}:
  Equal.trans(U32, PB.v16of(U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)), O.keep(2, x), x, Equal.sym(U32, O.keep(2, x), PB.v16of(U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)), kv16(x)), k2id(x, h))

# a < b is a <= b - 1 (b a variable: no closed power is evaluated)
def ltp(+a: Nat, +b: Nat, +h: {{Nat.is_lt(a, b) == True{{}} : Bool}}) -> {{Nat.is_le(a, Nat.sub(b, U32.to_nat(1))) == True{{}} : Bool}}:
  match b:
    case 0n: Empty.absurd({{Nat.is_le(a, Nat.sub(0n, U32.to_nat(1))) == True{{}} : Bool}}, FD.nat__lt_zero_absurd(a, h))
    case 1n+ +q:
      %Equal.sym(Nat, Nat.sub(q, 0n), q, FD.nat__sub_zero(q)) : {{Nat.is_le(a, _) == True{{}} : Bool}}
      FD.nat__lt_succ_le(a, q, h)

# below 2^16: a valid uint16 (U32.is_le(x, 65535)), through the powers as U32.pow2u(16) and spec_common__pow2(16)
def u16v(+x: U32, +h: {{U32.is_lt(x, 65536) == True{{}} : Bool}}) -> {{U32.is_le(x, 65535) == True{{}} : Bool}}:
  +P = FD.spec_common__pow2(16n)
  +hl = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_lt(x, 65536), Nat.is_lt(U32.to_nat(x), U32.to_nat(65536)), FD.u32__is_lt_nat(x, 65536), h)
  +e6 = Equal.trans(Nat, U32.to_nat(65536), U32.to_nat(FD.u32__pow2u(16n)), P, Equal.cong(U32, Nat, z => U32.to_nat(z), 65536, FD.u32__pow2u(16n), {{==}}), FD.u32__pow2u_value(16n, {{==}}))
  +hP = FD.logic__subst(Nat, z => {{Nat.is_lt(U32.to_nat(x), z) == True{{}} : Bool}}, U32.to_nat(65536), P, e6, hl)
  +e5 = Equal.trans(Nat, U32.to_nat(65535), U32.to_nat(U32.sub(FD.u32__pow2u(16n), 1)), Nat.sub(P, U32.to_nat(1)),
    Equal.cong(U32, Nat, z => U32.to_nat(z), 65535, U32.sub(FD.u32__pow2u(16n), 1), {{==}}),
    Equal.trans(Nat, U32.to_nat(U32.sub(FD.u32__pow2u(16n), 1)), Nat.sub(U32.to_nat(FD.u32__pow2u(16n)), U32.to_nat(1)), Nat.sub(P, U32.to_nat(1)),
      FD.u32__sub_nat(FD.u32__pow2u(16n), 1, FD.u32__one_le_pow2u(16n, {{==}})),
      Equal.cong(Nat, Nat, z => Nat.sub(z, U32.to_nat(1)), U32.to_nat(FD.u32__pow2u(16n)), P, FD.u32__pow2u_value(16n, {{==}}))))
  %Equal.sym(Bool, U32.is_le(x, 65535), Nat.is_le(U32.to_nat(x), U32.to_nat(65535)), VU.le_u32(x, 65535)) : {{_ == True{{}} : Bool}}
  %Equal.sym(Nat, U32.to_nat(65535), Nat.sub(P, U32.to_nat(1)), e5) : {{Nat.is_le(U32.to_nat(x), _) == True{{}} : Bool}}
  ltp(U32.to_nat(x), P, hP)

def ev1({PB31}) -> {{U32.and({WE}, 1) == {WEa} : U32}}: {{==}}

def ev2({PB31}) -> {{{WEa} == {WZ} : U32}}:
""" + '\n'.join(esteps) + f"""
  {{==}}

def evw(+w: Word(31n)) -> {{U32.is_eq(U32.and(U32{{WCon{{False{{}}, w}}}}, 1), 0) == True{{}} : Bool}}:
  match w:
    case {patw}:
      %Equal.sym(U32, U32.and({WE}, 1), {WZ}, Equal.trans(U32, U32.and({WE}, 1), {WEa}, {WZ}, ev1({', '.join(B)}), ev2({', '.join(B)}))) : {{U32.is_eq(_, 0) == True{{}} : Bool}}
      {{==}}

def evb(+b0: Bool, +w: Word(31n), +c: Nat, +e: {{Word.to_nat(32n, WCon{{b0, w}}) == Nat.double(c) : Nat}}) -> {{U32.is_eq(U32.and(U32{{WCon{{b0, w}}}}, 1), 0) == True{{}} : Bool}}:
  match b0:
    case True{{}}: Empty.absurd({{U32.is_eq(U32.and(U32{{WCon{{True{{}}, w}}}}, 1), 0) == True{{}} : Bool}}, FD.nat__even_odd(c, Word.to_nat(31n, w), Equal.sym(Nat, 1n+Nat.double(Word.to_nat(31n, w)), Nat.double(c), e)))
    case False{{}}: evw(w)

# an even byte count has a zero low bit
def ev(+x: U32, +c: Nat, +e: {{U32.to_nat(x) == Nat.double(c) : Nat}}) -> {{U32.is_eq(U32.and(x, 1), 0) == True{{}} : Bool}}:
  match x:
    case U32{{WCon{{+b0, +w}}}}: evb(b0, w, c, e)
"""


SUPPORT_OUT['e2e_gwin.bend'] = gwin_text()


# ---- e2e_gvt: VarTestStruct at any byte window (vtw) and Vector[VarTestStruct, 2] at a window (vv2w) ----
def gvt_text():
    P_ = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
          '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    WA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    X0, X6 = 'Nat.add(x, U32.to_nat(0))', 'Nat.add(x, U32.to_nat(6))'
    CH = 'CH0.OBJw(d, t, YW.XJ0(t, x), YW.FJ0(off, t, x), YW.LJ0(t, x, len))'
    CV = 'CH0.VALw(t, YW.XJ0(t, x), YW.LJ0(t, x, len))'
    U16 = f'S.UnsignedValue{{P.UInt{{O.keep(2, UR.RWN(t, {X0})), 0, 0, 0, 0, 0, 0, 0}}}}'
    V16 = f'FX16.VAL(t, {X0})'
    U8 = f'FX8.VAL(t, {X6})'
    VT = 'VarTestStruct_d.Gc465214E502'
    SEQ = 'vec_VarTestStruct_2_d.v2_Gc465214E502_Seq'
    WJ0 = 'V2.WJ(t, x, 0)'
    OB = lambda a, b: f'YW.OBJw(d, t, Nat.add(U32.to_nat({a}), x), U32.add(off, {a}), U32.sub({b}, {a}))'  # noqa: E731
    TF = lambda o: f'RT.th_Gc465214E502(RT.fz_Gc465214E502({o}))'  # noqa: E731
    VA, VB_ = f'RT.v_Gc465214E502({TF(OB("8", WJ0))})', f'RT.v_Gc465214E502({TF(OB(WJ0, "len"))})'
    RV8 = f'{SEQ}{{V2.RV(1n, 0, 2, d, t, x, off, len, vec_VarTestStruct_2_d.v2_Gc465214E502_fill(vec_VarTestStruct_2_d.v2_Gc465214E502_cap(2)), V2.OBJE(d, t, x, off, 8, {WJ0})), 2}}'
    EE1 = f'V2.EE(True{{}}, t, x, off, len, 8, {WJ0})'
    EW2 = lambda z: f'V2.EW(V2.GD({z}, {WJ0}, len, len), t, x, off, {WJ0}, len)'  # noqa: E731
    BW = lambda w: f'V2.NX(U32.is_eq(1, U32.shrn({w}, 2n)), t, x, len, 0)'  # noqa: E731
    NW = lambda w: f'U32.shrn({w}, 2n)'  # noqa: E731
    KW = lambda w: f'U32.to_nat(U32.sub({NW(w)}, 1))'  # noqa: E731
    PW = lambda w: (f'{{RT.xv_v2_Gc465214E502({SEQ}{{V2.RV({KW(w)}, 0, {NW(w)}, d, t, x, off, len, vec_VarTestStruct_2_d.v2_Gc465214E502_fill(vec_VarTestStruct_2_d.v2_Gc465214E502_cap({NW(w)})), '
                    f'V2.OBJE(d, t, x, off, {w}, {BW(w)})), {NW(w)}}}) == S.Sequence{{S.Items{{V2.VE(t, x, {w}, {BW(w)}), V2.VI({KW(w)}, 0, {NW(w)}, t, x, len)}}}} : S.Value}}')  # noqa: E731
    EVW = lambda w: f'V2.EV({KW(w)}, 0, {NW(w)}, t, x, off, len, V2.EE(True{{}}, t, x, off, len, {w}, {BW(w)}), {BW(w)})'  # noqa: E731
    W0 = 'V2.W0(t, x)'
    return f"""import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/primitive.bend as P
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vua_win.bend as UW
import ../proofs/obj/vua_rd.bend as UR
import ../proofs/obj/vua_ct.bend as UCT
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/words_obj.bend as WO
import ../proofs/obj/packed_bytes.bend as PBF
import ../proofs/obj/pb_min.bend as PBM
import ../proofs/obj/root_gtypes.bend as RT
import ../proofs/obj/vfx_u16.bend as FX16
import ../proofs/obj/vfx_u8.bend as FX8
import ../proofs/obj/var_winx_Gc465214E502.bend as YW
import ../proofs/obj/var_winx_l1024_u16.bend as CH0
import ../proofs/obj/big_vvl_v2_Gc465214E502.bend as V2
import ../types/VarTestStruct_def_generated.bend as VarTestStruct_d
import ../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d
import ./e2e_blist.bend as BL
import ./e2e_plist.bend as PL
import ./e2e_gwin.bend as GW

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# The root view of a VarTestStruct read at any byte window is its codec value (vtw), and so is a
# Vector[VarTestStruct, 2]'s (vv2w: its check fixes the first offset at 8, so two elements).

# a word read at x + 0 of a window of at least K >= 4 bytes is within the tree
def hx4(+d: Nat, +x: Nat, +len: U32, +K: U32, +hK: {{Nat.is_le(4n, U32.to_nat(K)) == True{{}} : Bool}}, +hk: {{Nat.is_le(U32.to_nat(K), U32.to_nat(len)) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}) -> {{Nat.is_le(Nat.add(Nat.add(x, U32.to_nat(0)), 4n), A.quad(VB.pw(d))) == True{{}} : Bool}}:
  %Equal.sym(Nat, Nat.add(x, 0n), x, FD.nat__add_zero(x)) : {{Nat.is_le(Nat.add(_, 4n), A.quad(VB.pw(d))) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, 4n, U32.to_nat(len), FD.nat__le_trans(4n, U32.to_nat(K), U32.to_nat(len), hK, hk)), hw)
{gwin_u16list_text()}
# ---- VarTestStruct at a byte window ----
def vtw({P_}, +h: {{YW.CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{RT.v_Gc465214E502(YW.OBJw(d, t, x, off, len)) == YW.VALw(t, x, len) : S.Value}}:
  +h4 = hx4(d, x, len, 7, {{==}}, YW.hFc(t, x, off, len, h), hw)
  +e16 = GW.v16w(d, t, {X0}, pf, h4)
  +el = lv(d, t, YW.XJ0(t, x), YW.FJ0(off, t, x), YW.LJ0(t, x, len), YW.eoJ0({WA}, h), hd, YW.hwJ0({WA}, h), pf, YW.itD0(t, x, off, len, h))
  Equal.trans(S.Value, S.Sequence{{S.Items{{{U16}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, S.Sequence{{S.Items{{{V16}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, YW.VALw(t, x, len),
    Equal.cong(U32, S.Value, z => S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{z, 0, 0, 0, 0, 0, 0, 0}}}}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, O.keep(2, UR.RWN(t, {X0})), PBM.v16of(FX8.BX(t, {X0}), FX8.BX(t, 1n+{X0})), e16),
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{{V16}, S.Items{{z, S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, PBF.vview2({CH}), {CV}, el))

# ---- Vector[VarTestStruct, 2] at a byte window ----
# an element's frozen-and-thawed object is the object
def thfz(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {{{TF('YW.OBJw(d, t, x, off, len)')} == YW.OBJw(d, t, x, off, len) : {VT}}}:
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YW.FJ0(off, t, x), YW.LJ0(t, x, len), VLS.DZ(YW.LJ0(t, x, len))))), UCT.CT(d, t, YW.FJ0(off, t, x), YW.LJ0(t, x, len), VLS.DZ(YW.LJ0(t, x, len))),
      FD.array__freeze_thaw(U32, UCT.CT(d, t, YW.FJ0(off, t, x), YW.LJ0(t, x, len), VLS.DZ(YW.LJ0(t, x, len))))) :
    {{{VT}{{FX16.OBJ(d, t, {X0}), O.Words{{FD.array__thaw(U32, _), YW.LJ0(t, x, len)}}, FX8.OBJ(d, t, {X6})}} == YW.OBJw(d, t, x, off, len) : {VT}}}
  {{==}}

# element (a, b) whose check passed: its view is its codec value
def elv({P_}, +a: U32, +b: U32, +h: {{V2.EE(True{{}}, t, x, off, len, a, b) == True{{}} : Bool}})
    -> {{RT.v_Gc465214E502({TF(OB('a', 'b'))}) == V2.VE(t, x, a, b) : S.Value}}:
  +hab = V2.el_ab(t, x, off, len, a, b, h)
  +hb = V2.el_b(t, x, off, len, a, b, h)
  %Equal.sym({VT}, {TF(OB('a', 'b'))}, {OB('a', 'b')}, thfz(d, t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a))) : {{RT.v_Gc465214E502(_) == V2.VE(t, x, a, b) : S.Value}}
  vtw(d, t, n, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a), V2.eoc(d, x, off, len, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), hab, hb), eo, hd, hw),
    hd, V2.hwab(d, x, len, a, b, hab, hb, hw), pf, V2.el_c(t, x, off, len, a, b, h))

# the two elements' views, as the vector's
def v2e(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {{RT.xv_v2_Gc465214E502({RV8}) == S.Sequence{{S.Items{{{VA}, S.Items{{{VB_}, S.EmptyItems{{}}}}}}}} : S.Value}}:
  {{==}}

# first offset 8: elements (8, WJ0) and (WJ0, len)
def v2d({P_}, +h8: {{V2.EE({EE1}, t, x, off, len, {WJ0}, len) == True{{}} : Bool}}) -> {PW('8')}:
  +ha = FD.logic__and_left({EE1}, {EW2(EE1)}, h8)
  +hb = FD.logic__subst(Bool, z => {{{EW2('z')} == True{{}} : Bool}}, {EE1}, True{{}}, ha, FD.logic__and_right({EE1}, {EW2(EE1)}, h8))
  +ea = elv({WA}, 8, {WJ0}, ha)
  +eb = elv({WA}, {WJ0}, len, hb)
  Equal.trans(S.Value, RT.xv_v2_Gc465214E502({RV8}), S.Sequence{{S.Items{{{VA}, S.Items{{{VB_}, S.EmptyItems{{}}}}}}}}, S.Sequence{{S.Items{{V2.VE(t, x, 8, {WJ0}), S.Items{{V2.VE(t, x, {WJ0}, len), S.EmptyItems{{}}}}}}}},
    v2e(d, t, x, off, len),
    Equal.trans(S.Value, S.Sequence{{S.Items{{{VA}, S.Items{{{VB_}, S.EmptyItems{{}}}}}}}}, S.Sequence{{S.Items{{V2.VE(t, x, 8, {WJ0}), S.Items{{{VB_}, S.EmptyItems{{}}}}}}}}, S.Sequence{{S.Items{{V2.VE(t, x, 8, {WJ0}), S.Items{{V2.VE(t, x, {WJ0}, len), S.EmptyItems{{}}}}}}}},
      Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{z, S.Items{{{VB_}, S.EmptyItems{{}}}}}}}}, {VA}, V2.VE(t, x, 8, {WJ0}), ea),
      Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{V2.VE(t, x, 8, {WJ0}), S.Items{{z, S.EmptyItems{{}}}}}}}}, {VB_}, V2.VE(t, x, {WJ0}, len), eb)))

# a nonempty window: the check's first offset is 8
def v2b({P_}, +h: {{V2.CF(V2.HC({W0}, len), t, x, off, len) == True{{}} : Bool}})
    -> {{RT.xv_v2_Gc465214E502(V2.RZ(False{{}}, d, t, x, off, len)) == V2.VZE(False{{}}, t, x, len) : S.Value}}:
  +hc = V2.cf_ok(V2.HC({W0}, len), t, x, off, len, h)
  +h1 = FD.logic__subst(Bool, z => {{V2.CF(z, t, x, off, len) == True{{}} : Bool}}, V2.HC({W0}, len), True{{}}, hc, h)
  +e8 = FD.u32alg__eq_of({W0}, 8, FD.logic__and_right(Bool.and(U32.is_eq(U32.and({W0}, 3), 0), U32.is_le({W0}, len)), U32.is_eq({W0}, 8), hc))
  +h8 = FD.logic__subst(U32, w => {{{EVW('w')} == True{{}} : Bool}}, {W0}, 8, e8, h1)
  %Equal.sym(U32, {W0}, 8, e8) : {PW('_')}
  v2d({WA}, h8)

def v2z({P_}, +e: Bool, +h: {{V2.CZ(e, t, x, off, len) == True{{}} : Bool}})
    -> {{RT.xv_v2_Gc465214E502(V2.RZ(e, d, t, x, off, len)) == V2.VZE(e, t, x, len) : S.Value}}:
  match e:
    case True{{}}: Empty.absurd({{RT.xv_v2_Gc465214E502(V2.RZ(True{{}}, d, t, x, off, len)) == V2.VZE(True{{}}, t, x, len) : S.Value}}, FD.logic__false_true(h))
    case False{{}}: v2b({WA}, h)

def vv2w({P_}, +h: {{V2.CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{RT.xv_v2_Gc465214E502(V2.OBJw(d, t, x, off, len)) == V2.VALw(t, x, len) : S.Value}}:
  v2z({WA}, U32.is_eq(len, 0), h)
"""


SUPPORT_OUT['e2e_gvt.bend'] = gvt_text()


# ---- ComplexTestStruct (ii)/(iii): each of the seven parts' view is its codec value, rewritten in place ----
def complex_view(R, X):
    x = '0n'
    WA = 'd, t, n, 0n, 0, n, {==}, hd, hn, pf, h'
    X0, X6, X15 = 'Nat.add(0n, U32.to_nat(0))', 'Nat.add(0n, U32.to_nat(6))', 'Nat.add(0n, U32.to_nat(15))'
    J = lambda k, ln=False: (f'W.XJ{k}(t, {x})', f'W.FJ{k}(0, t, {x})', f'W.LJ{k}(t, {x}' + (', n)' if ln else ')'))  # noqa: E731
    x0_, f0, l0 = J(0)
    x1, f1, l1 = J(1)
    x2, f2, l2 = J(2)
    x3, f3, l3 = J(3, True)
    parts = {
        'A': (f'O.keep(2, UR.RWN(t, {X0}))', f'PBM.v16of(FX8.BX(t, {X0}), FX8.BX(t, 1n+{X0}))', 'e16'),
        'B': (f'PBF.vview2(CH0.OBJw(d, t, {x0_}, {f0}, {l0}))', f'CH0.VALw(t, {x0_}, {l0})', 'el'),
        'D': (f'WO.wview(O.Words{{FD.array__thaw(U32, BL.CW(d, t, {f1}, {l1})), {l1}}})', f'UW.WX(t, {x1}, U32.to_nat({l1}))', 'eb'),
        'E': (f'RT.v_Gc465214E502(CH2.OBJw(d, t, {x2}, {f2}, {l2}))', f'CH2.VALw(t, {x2}, {l2})', 'ev'),
        'F': (f'RT.xv_v4_GcDC3E457711(FXV4.OBJ(d, t, {X15}))', f'FXV4.VAL(t, {X15})', 'e4'),
        'G': (f'RT.xv_v2_Gc465214E502(CH3.OBJw(d, t, {x3}, {f3}, {l3}))', f'CH3.VALw(t, {x3}, {l3})', 'ew'),
    }
    order = ['A', 'B', 'D', 'E', 'F', 'G']

    def seq(v):
        return (f'S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{{v["A"]}, 0, 0, 0, 0, 0, 0, 0}}}}, S.Items{{{v["B"]}, S.Items{{FX8.VAL(t, {X6}), '
                f'S.Items{{S.BytesValue{{{v["D"]}}}, S.Items{{{v["E"]}, S.Items{{{v["F"]}, S.Items{{{v["G"]}, S.EmptyItems{{}}}}}}}}}}}}}}}}}}')
    steps = []
    for i, k in enumerate(order):
        v = {q: (parts[q][0] if j < i else ('_' if j == i else parts[q][1])) for j, q in enumerate(order)}
        steps.append(f'  %{parts[k][2]} : {{RT.v_{X}(DC.OBJ(d, t, n)) == {seq(v)} : S.Value}}')
    head = f"""# ---- the view of a decoded object is the codec law's value ----
{gwin_u16list_text()}
# the vector of four FixedTestStructs: its view is its codec value
def fv4(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat) -> {{RT.xv_v4_GcDC3E457711(FXV4.OBJ(d, t, x)) == FXV4.VAL(t, x) : S.Value}}:
  {{==}}

def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}}:
  +h = hchk
  +h4 = GV2.hx4(d, 0n, n, 71, {{==}}, W.hFc(t, 0n, 0, n, h), hn)
  +e16 = GW.v16w(d, t, {X0}, pf, h4)
  +el = lv(d, t, {x0_}, {f0}, {l0}, W.eoJ0({WA}), hd, W.hwJ0({WA}), pf, W.itD0(t, 0n, 0, n, h))
  +eb = BL.bview(d, t, {f1}, {l1}, {x1}, W.eoJ1({WA}), hd, W.hwJ1({WA}), pf)
  +ev = GV2.vtw(d, t, n, {x2}, {f2}, {l2}, W.eoJ2({WA}), hd, W.hwJ2({WA}), pf, W.itD2(t, 0n, 0, n, h))
  +e4 = fv4(d, t, {X15})
  +ew = GV2.vv2w(d, t, n, {x3}, {f3}, {l3}, W.eoJ3({WA}), hd, W.hwJ3({WA}), pf, W.itD3(t, 0n, 0, n, h))
"""
    text = head + '\n'.join(steps) + '\n  {==}\n\n'
    src = _dc_module(R).read_text()
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = (ROOT / 'proofs/obj' / wm).read_text()
    ch = dict((a, m) for m, a in re.findall(r'^import \./(\S+) as (CH\d+)$', wsrc, re.M))
    return {'view': f'RT.v_{X}',
            'imports': ['import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/packed_bytes.bend as PBF',
                        'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/vua_win.bend as UW', 'import ../proofs/obj/vua_rd.bend as UR',
                        'import ../proofs/obj/vbuf.bend as VB', 'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_gwin.bend as GW',
                        'import ./e2e_gvt.bend as GV2', f'import ../proofs/obj/{wm} as W', f'import ../proofs/obj/{ch["CH0"]} as CH0',
                        f'import ../proofs/obj/{ch["CH2"]} as CH2', f'import ../proofs/obj/{ch["CH3"]} as CH3',
                        'import ../proofs/obj/vfx_u16.bend as FX16', 'import ../proofs/obj/vfx_u8.bend as FX8',
                        'import ../proofs/obj/vfx_v4_GcDC3E457711.bend as FXV4'],
            'text': text}


VDEC_VIEWS['Gc56D855869F'] = complex_view('ComplexTestStruct', 'Gc56D855869F')


# ==== e2e_encr: encode records from the root law's representation (for (i) of containers) ====
# Every storage field of a root-law object is O.Words{thaw(tt), n} for its tree tt and length n; its encode
# record is X.MW{LDEP(tt), tt, n} (LDEP: the tree's left depth, its depth when perfect). The storage premise
# each encode law needs (depth below its bound K, read from the law's OKT) is BL.sdk(words, K).

def _andproof(expr, leaf):
    """A proof of {expr == True} for a Bool.and tree, from proofs of its leaves (leaf: text -> proof)."""
    e = expr.strip()
    if e.startswith('Bool.and('):
        a, b = [x.strip() for x in _split(e[len('Bool.and('):-1])]
        return f'FD.logic__and_intro({a}, {b}, {_andproof(a, leaf)},\n    {_andproof(b, leaf)})'
    return leaf[e]


def _okt(src, name='OKT'):
    """The body of def OKT(..) -> Bool: body (one line or indented continuation)."""
    m = re.search(rf'^def {name}\((.*?)\) -> Bool:\s*\n?(.*?)(?=\n(?:def |law |#|type |\n))', src, re.M | re.S)
    return ' '.join(m.group(2).split())


def _obj(p):
    return (ROOT / 'proofs/obj' / p).read_text()


ENCR_LISTS = {  # tag: (encode record module, window module, kind)
    'l1024': ('big_encx_l1024_u16.bend', 'var_winx_l1024_u16.bend', 'u16'),
    'l128': ('big_encx_l128_u16.bend', 'var_winx_l128_u16.bend', 'u16'),
    'b256': ('big_encx_bl256.bend', 'big_vvlb_bl256.bend', 'bytes'),
}


def encr_k(tag):
    """The depth bound K of a storage field's encode record (its OKT's `dw < K`)."""
    return int(re.search(r'Nat\.is_lt\(dw, (\d+)n\)', _okt(_obj(ENCR_LISTS[tag][0]))).group(1))


def encr_text():
    TR = 'FD.array__Tree<U32>'
    WL = lambda t, n: f'O.Words{{FD.array__thaw(U32, {t}), {n}}}'  # noqa: E731
    L = []
    L.append(f'''# ---- trees and words ----
def LDEP(-A: Data, t: FD.array__Tree<A>) -> Nat:
  match t:
    case FD.TLeaf{{x}}: 0n
    case FD.TNode{{l, r}}: 1n+LDEP(A, l)

# a perfect tree's left depth is its depth
def pdep(-A: Data, +d: Nat, +t: FD.array__Tree<A>, +pf: {{FD.array__perfect(A, d, t) == True{{}} : Bool}}) -> {{LDEP(A, t) == d : Nat}}:
  match d t:
    case 0n FD.TLeaf{{x}}: {{==}}
    case 0n FD.TNode{{l, r}}: Empty.absurd({{LDEP(A, FD.TNode{{l, r}}) == 0n : Nat}}, FD.logic__false_true(pf))
    case 1n+p FD.TLeaf{{x}}: Empty.absurd({{LDEP(A, FD.TLeaf{{x}}) == 1n+p : Nat}}, FD.logic__false_true(pf))
    case 1n+ +p FD.TNode{{+l, +r}}: Equal.cong(Nat, Nat, z => 1n+z, LDEP(A, l), p, pdep(A, p, l, FD.array__pf_left(A, p, l, r, pf)))

def wT(w: O.Words) -> {TR}:
  match w:
    case O.Words{{ws, +n}}: FD.array__freeze(U32, ws)
def wN(w: O.Words) -> U32:
  match w:
    case O.Words{{ws, +n}}: n

# equal words: equal trees and lengths
def weT(+a: {TR}, +n: U32, +b: {TR}, +m: U32, +e: {{{WL('a', 'n')} == {WL('b', 'm')} : O.Words}}) -> {{a == b : {TR}}}:
  +e1 = Equal.cong(O.Words, {TR}, z => wT(z), {WL('a', 'n')}, {WL('b', 'm')}, e)
  Equal.trans({TR}, a, FD.array__freeze(U32, FD.array__thaw(U32, a)), b, Equal.sym({TR}, FD.array__freeze(U32, FD.array__thaw(U32, a)), a, FD.array__freeze_thaw(U32, a)),
    Equal.trans({TR}, FD.array__freeze(U32, FD.array__thaw(U32, a)), FD.array__freeze(U32, FD.array__thaw(U32, b)), b, e1, FD.array__freeze_thaw(U32, b)))
def weN(+a: {TR}, +n: U32, +b: {TR}, +m: U32, +e: {{{WL('a', 'n')} == {WL('b', 'm')} : O.Words}}) -> {{n == m : U32}}:
  Equal.cong(O.Words, U32, z => wN(z), {WL('a', 'n')}, {WL('b', 'm')}, e)

# byte storage (list_obj.wfl): its tree and length
def cpw(-w: O.Words, +wf: LO.wfl(w)) -> DK.Ex({TR}, t => DK.Ex(U32, n => {{w == {WL('t', 'n')} : O.Words}})):
  match wf:
    case Inl{{s}}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+ew, s4) = s3
      (t, (N, ew))
    case Inr{{s}}:
      (+t, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+q, s4) = s3
      (+r, s5) = s4
      (+ew, s6) = s5
      (t, (N, ew))

# ---- the storage facts an encode record takes, at depth bound K ----
def SFT(+tt: {TR}, +n: U32, +K: Nat) -> Data:
  DK.P2({{FD.array__perfect(U32, LDEP(U32, tt), tt) == True{{}} : Bool}},
  DK.P2({{Nat.is_lt(LDEP(U32, tt), K) == True{{}} : Bool}},
  DK.P2({{Nat.is_le(U32.to_nat(n), A.quad(VB.pw(LDEP(U32, tt)))) == True{{}} : Bool}},
        {{O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))) == True{{}} : Bool}})))

def sfx(+tt: {TR}, +n: U32, +K: Nat, +T: {TR}, +dw: Nat, +N: U32, +ew: {{{WL('tt', 'n')} == {WL('T', 'N')} : O.Words}},
    +pf: {{FD.array__perfect(U32, dw, T) == True{{}} : Bool}}, +hdw: {{Nat.is_lt(dw, K) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), A.quad(VB.pw(dw))) == True{{}} : Bool}}, +htz: {{O.tail_zero(U32.and(N, 3), VB.slot(T, VY.QL(N))) == True{{}} : Bool}}) -> SFT(tt, n, K):
  +et = weT(tt, n, T, N, ew)
  +en = weN(tt, n, T, N, ew)
  +ed = pdep(U32, dw, T, pf)
  %Equal.sym({TR}, tt, T, et) : SFT(_, n, K)
  %Equal.sym(U32, n, N, en) : SFT(T, _, K)
  %Equal.sym(Nat, LDEP(U32, T), dw, ed) : DK.P2({{FD.array__perfect(U32, _, T) == True{{}} : Bool}}, DK.P2({{Nat.is_lt(_, K) == True{{}} : Bool}},
    DK.P2({{Nat.is_le(U32.to_nat(N), A.quad(VB.pw(_))) == True{{}} : Bool}}, {{O.tail_zero(U32.and(N, 3), VB.slot(T, VY.QL(N))) == True{{}} : Bool}})))
  (pf, (hdw, (hN, htz)))

# the premise (BL.sdk: byte storage at depth below K) as those facts
def sfk(+tt: {TR}, +n: U32, +K: Nat, +hs: BL.sdk({WL('tt', 'n')}, K)) -> SFT(tt, n, K):
  match hs:
    case Inl{{s}}:
      (+T, s1) = s
      (+dw, s2) = s1
      (+N, s3) = s2
      (+ew, s4) = s3
      (+pf, s5) = s4
      (+hdw, +en0) = s5
      +hN = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(dw))) == True{{}} : Bool}}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, en0), Order.zero_le(A.quad(VB.pw(dw))))
      +htz = FD.logic__subst(U32, z => {{O.tail_zero(U32.and(z, 3), VB.slot(T, VY.QL(z))) == True{{}} : Bool}}, 0, N, Equal.sym(U32, N, 0, FD.u32__injective(N, 0, en0)), {{==}})
      sfx(tt, n, K, T, dw, N, ew, pf, hdw, hN, htz)
    case Inr{{s}}:
      (+T, s1) = s
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
      +hq = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(O.e8(1n+q))) == True{{}} : Bool}}, Nat.add(r, WS.e32(q)), U32.to_nat(N),
        Equal.sym(Nat, U32.to_nat(N), Nat.add(r, WS.e32(q)), Equal.trans(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), Nat.add(r, WS.e32(q)), eN, FD.nat__add_comm(WS.e32(q), r))),
        Order.add_right(r, 32n, WS.e32(q), hr32))
      +hN = FD.nat__le_trans(U32.to_nat(N), A.quad(O.e8(1n+q)), A.quad(VB.pw(dw)), hq, C.q4(O.e8(1n+q), FD.spec_common__pow2(dw), hcap))
      sfx(tt, n, K, T, dw, N, ew, pf, hdw, hN, TZ.tz(T, N, q, r, eN, hr0, hr32, bz))

# a + b <= A + B
def addle(+a: Nat, +b: Nat, +A: Nat, +B: Nat, +ha: {{Nat.is_le(a, A) == True{{}} : Bool}}, +hb: {{Nat.is_le(b, B) == True{{}} : Bool}}) -> {{Nat.is_le(Nat.add(a, b), Nat.add(A, B)) == True{{}} : Bool}}:
  FD.nat__le_trans(Nat.add(a, b), Nat.add(A, b), Nat.add(A, B), Order.add_right(a, A, b, ha), FD.nat__le_add_left(b, B, A, hb))
''')
    imps = []
    for tag, (xm, wm, kind) in ENCR_LISTS.items():
        X, W = f'X{tag}', f'W{tag}'
        imps += [f'import ../proofs/obj/{xm} as {X}', f'import ../proofs/obj/{wm} as {W}']
        okt = _okt(_obj(xm))
        K = encr_k(tag)
        R = f'{X}.MW{{LDEP(U32, tt), tt, n}}'
        leaf = {f'FD.array__perfect(U32, dw, T)': 'pf', f'Nat.is_lt(dw, {K}n)': 'hdw', 'Nat.is_le(U32.to_nat(N), A.quad(VB.pw(dw)))': 'hN',
                'O.tail_zero(U32.and(N, 3), VB.slot(T, VYS.QL(N)))': 'htz'}
        sub = lambda s: re.sub(r'\bVYS\.', 'VY.', re.sub(r'\bN\b', 'n', re.sub(r'\bT\b', 'tt', re.sub(r'\bdw\b', 'LDEP(U32, tt)', s))))  # noqa: E731
        if kind == 'u16':
            M2 = int(re.search(r'Nat\.is_le\(U32\.to_nat\(N\), U32\.to_nat\((\d+)\)\)', okt).group(1))
            LIM = int(re.search(r'hk: \{Nat\.is_le\(c, (\d+)n\)', _obj(wm)).group(1))
            assert M2 == 2 * LIM, (tag, M2, LIM)
            leaf.update({f'Nat.is_le(U32.to_nat(N), U32.to_nat({M2}))': 'h2', 'U32.is_eq(U32.and(N, 1), 0)': 'GW.ev(n, c, ec)', 'W.CHKw(T, 0n, 0, N)': f'{W}.chk2(tt, 0n, 0, n, c, ec, hk)'})
            leaf = {sub(k): v for k, v in leaf.items()}
            proof = _andproof(sub(okt).replace('W.CHKw', f'{W}.CHKw'), {k.replace('W.CHKw', f'{W}.CHKw'): v for k, v in leaf.items()})
            CP = f'+c: Nat, +ec: {{U32.to_nat(n) == Nat.double(c) : Nat}}, +hk: {{Nat.is_le(c, {LIM}n) == True{{}} : Bool}}'
            L.append(f'''# ---- {tag}: a List[uint16, {LIM}] field ----
def h2_{tag}(+n: U32, {CP}) -> {{Nat.is_le(U32.to_nat(n), {M2}n) == True{{}} : Bool}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(z, {M2}n) == True{{}} : Bool}}, Nat.double(c), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.double(c), ec), FD.nat__double_le(c, {LIM}n, hk))

def ok_{tag}(+tt: {TR}, +n: U32, +sf: SFT(tt, n, {K}n), {CP}) -> {{{X}.OK({R}) == True{{}} : Bool}}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  +h2 = h2_{tag}(n, c, ec, hk)
  {proof}

def lv_{tag}(+tt: {TR}, +n: U32, {CP}) -> {{PBF.vview2({WL('tt', 'n')}) == {W}.VALw(tt, 0n, n) : S.Value}}:
  +eq = PL.c2(n, {W}.CQ(n), {W}.eLc(tt, 0n, 0, n, {W}.chk2(tt, 0n, 0, n, c, ec, hk)))
  +e0 = Equal.cong(Nat, S.Value, z => S.Sequence{{PBF.it2(z, WO.wview({WL('tt', 'n')}))}}, U32.to_nat(U32.shrn(n, 1n)), {W}.CQ(n), eq)
  +e1 = Equal.cong(+List<U32>, S.Value, z => S.Sequence{{PBF.it2({W}.CQ(n), z)}}, WO.wview({WL('tt', 'n')}), BL.WX0(tt, n), BL.wv0(tt, n))
  +e2 = Equal.cong(S.Value, S.Value, z => S.Sequence{{z}}, PBF.it2({W}.CQ(n), BL.WX0(tt, n)), PBM.it2({W}.CQ(n), BL.WX0(tt, n)), PL.it2eq({W}.CQ(n), BL.WX0(tt, n)))
  Equal.trans(S.Value, PBF.vview2({WL('tt', 'n')}), S.Sequence{{PBF.it2({W}.CQ(n), WO.wview({WL('tt', 'n')}))}}, {W}.VALw(tt, 0n, n), e0,
    Equal.trans(S.Value, S.Sequence{{PBF.it2({W}.CQ(n), WO.wview({WL('tt', 'n')}))}}, S.Sequence{{PBF.it2({W}.CQ(n), BL.WX0(tt, n))}}, {W}.VALw(tt, 0n, n), e1, e2))

def ln_{tag}(+tt: {TR}, +n: U32, +hok: {{{X}.OK({R}) == True{{}} : Bool}}, {CP}) -> {{Nat.is_le(LY.LN({X}.ENC({R})), {M2}n) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {X}.ENC({R})), U32.to_nat(n), {X}.eL(LDEP(U32, tt), tt, n, hok)) : {{Nat.is_le(_, {M2}n) == True{{}} : Bool}}
  h2_{tag}(n, c, ec, hk)

# the field's record from its words (rep_l2) and the premise
def LR_{tag}(w: O.Words) -> Data:
  DK.Ex({X}.MW, m => DK.P2({{w == {X}.TH(m) : O.Words}}, DK.P2({{PBF.vview2({X}.TH(m)) == {X}.VAL(m) : S.Value}}, DK.P2({{{X}.OK(m) == True{{}} : Bool}}, {{Nat.is_le(LY.LN({X}.ENC(m)), {M2}n) == True{{}} : Bool}}))))

def lb2_{tag}(-w: O.Words, +cw: DK.Ex({TR}, t => DK.Ex(U32, n => {{w == {WL('t', 'n')} : O.Words}})), +hx: {{U32.to_nat(WO.len(w)) == Nat.double(PBF.cnt2(w)) : Nat}},
    +hl: {{Nat.is_le(PBF.cnt2(w), {LIM}n) == True{{}} : Bool}}, +hs: BL.sdk(w, {K}n)) -> LR_{tag}(w):
  (+tt, +c1) = cw
  (+n, +ew) = c1
  +hx2 = FD.logic__subst(O.Words, z => {{U32.to_nat(WO.len(z)) == Nat.double(PBF.cnt2(z)) : Nat}}, w, {WL('tt', 'n')}, ew, hx)
  +hl2 = FD.logic__subst(O.Words, z => {{Nat.is_le(PBF.cnt2(z), {LIM}n) == True{{}} : Bool}}, w, {WL('tt', 'n')}, ew, hl)
  +hs2 = FD.logic__subst(O.Words, z => BL.sdk(z, {K}n), w, {WL('tt', 'n')}, ew, hs)
  +hok = ok_{tag}(tt, n, sfk(tt, n, {K}n, hs2), PBF.cnt2({WL('tt', 'n')}), hx2, hl2)
  ({R}, (ew, (lv_{tag}(tt, n, PBF.cnt2({WL('tt', 'n')}), hx2, hl2), (hok, ln_{tag}(tt, n, hok, PBF.cnt2({WL('tt', 'n')}), hx2, hl2)))))

def lb_{tag}(-w: O.Words, +rep: BLI.rep_l2(w, S.ListOf{{S.Unsigned{{P.U16{{}}}}, {LIM}n}}), +hs: BL.sdk(w, {K}n)) -> LR_{tag}(w):
  (+wf, +z) = rep
  (+hx, +hl) = z
  lb2_{tag}(w, cpw(w, wf), hx, hl, hs)
''')
        else:
            LIM = int(re.search(r'U32\.is_le\(N, (\d+)\)', okt).group(1))
            leaf.update({f'U32.is_le(N, {LIM})': 'hle'})
            leaf = {sub(k): v for k, v in leaf.items()}
            proof = _andproof(sub(okt), leaf)
            L.append(f'''# ---- {tag}: a ByteList[{LIM}] field ----
def ok_{tag}(+tt: {TR}, +n: U32, +sf: SFT(tt, n, {K}n), +hl: {{Nat.is_le(U32.to_nat(n), {LIM}n) == True{{}} : Bool}}) -> {{{X}.OK({R}) == True{{}} : Bool}}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  +hle = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(n), U32.to_nat({LIM})), U32.is_le(n, {LIM}),
    Equal.sym(Bool, U32.is_le(n, {LIM}), Nat.is_le(U32.to_nat(n), U32.to_nat({LIM})), VU.le_u32(n, {LIM})), hl)
  {proof}

def ln_{tag}(+tt: {TR}, +n: U32, +hok: {{{X}.OK({R}) == True{{}} : Bool}}, +hl: {{Nat.is_le(U32.to_nat(n), {LIM}n) == True{{}} : Bool}}) -> {{Nat.is_le(LY.LN({X}.ENC({R})), {LIM}n) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {X}.ENC({R})), U32.to_nat(n), {X}.eL(LDEP(U32, tt), tt, n, hok)) : {{Nat.is_le(_, {LIM}n) == True{{}} : Bool}}
  hl

def LR_{tag}(w: O.Words) -> Data:
  DK.Ex({X}.MW, m => DK.P2({{w == {X}.TH(m) : O.Words}}, DK.P2({{S.BytesValue{{WO.wview({X}.TH(m))}} == {X}.VAL(m) : S.Value}}, DK.P2({{{X}.OK(m) == True{{}} : Bool}}, {{Nat.is_le(LY.LN({X}.ENC(m)), {LIM}n) == True{{}} : Bool}}))))

def lb2_{tag}(-w: O.Words, +cw: DK.Ex({TR}, t => DK.Ex(U32, n => {{w == {WL('t', 'n')} : O.Words}})), +hl: {{Nat.is_le(U32.to_nat(WO.len(w)), {LIM}n) == True{{}} : Bool}},
    +hs: BL.sdk(w, {K}n)) -> LR_{tag}(w):
  (+tt, +c1) = cw
  (+n, +ew) = c1
  +hl2 = FD.logic__subst(O.Words, z => {{Nat.is_le(U32.to_nat(WO.len(z)), {LIM}n) == True{{}} : Bool}}, w, {WL('tt', 'n')}, ew, hl)
  +hs2 = FD.logic__subst(O.Words, z => BL.sdk(z, {K}n), w, {WL('tt', 'n')}, ew, hs)
  +hok = ok_{tag}(tt, n, sfk(tt, n, {K}n, hs2), hl2)
  ({R}, (ew, (Equal.cong(+List<U32>, S.Value, z => S.BytesValue{{z}}, WO.wview({WL('tt', 'n')}), BL.WX0(tt, n), BL.wv0(tt, n)), (hok, ln_{tag}(tt, n, hok, hl2)))))

def lb_{tag}(-w: O.Words, +rep: LO.rep_bl(w, S.ByteList{{{LIM}n}}), +hs: BL.sdk(w, {K}n)) -> LR_{tag}(w):
  (+wf, +hl) = rep
  lb2_{tag}(w, cpw(w, wf), hl, hs)
''')
    # ---- VarTestStruct (Gc465214E502): its record from its fields ----
    em = _obj('big_encx_Gc465214E502_iface.bend')
    FIX = int(re.search(r'^def ENDC\(.*?\) -> Nat: Nat\.add\((\d+)n,', em, re.M).group(1))
    KB = int(re.search(r'A\.quad\(VB\.pw\((\d+)n\)\)\)\)\)$', re.search(r'^def OKT\(.*$', em, re.M).group(0)).group(1))
    M2 = int(re.search(r'Nat\.is_le\(U32\.to_nat\(N\), U32\.to_nat\((\d+)\)\)', _okt(_obj(ENCR_LISTS['l1024'][0]))).group(1))
    LIM = M2 // 2
    EB = FIX + M2
    VT = 'VarTestStruct_d.Gc465214E502'
    MB = 'Xl1024.MW{LDEP(U32, tt), tt, n}'
    RM = f'EM.MW{{a0, {MB}, a2}}'
    V16 = 'PBM.v16of(U32.and(a0, 255), U32.and(U32.shrn(a0, 8n), 255))'
    VW = f'PBF.vview2({WL("tt", "n")})'
    VL = 'Wl1024.VALw(tt, 0n, n)'
    VIEW = lambda a, b, c: f'S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{{a}, 0, 0, 0, 0, 0, 0, 0}}}}, S.Items{{{b}, S.Items{{S.UnsignedValue{{P.UInt{{{c}, 0, 0, 0, 0, 0, 0, 0}}}}, S.EmptyItems{{}}}}}}}}}}'  # noqa: E731
    MOT = lambda a, b, c: f'{{{VIEW("a0", VW, "a2")} == {VIEW(a, b, c)} : S.Value}}'  # noqa: E731
    BND = f'Nat.is_le(Nat.add({FIX}n, LY.LN(Xl1024.ENC(mB))), A.quad(VB.pw({KB}n)))'
    PW = 1
    while 4 * 2 ** PW < EB:
        PW += 1
    FP = '+h0: {U32.is_lt(a0, 65536) == True{} : Bool}, +h2: {U32.is_lt(a2, 256) == True{} : Bool}'
    CP = '+c: Nat, +ec: {U32.to_nat(n) == Nat.double(c) : Nat}, +hk: {Nat.is_le(c, @LIM@n) == True{} : Bool}'.replace('@LIM@', str(LIM))
    L.append(f'''# ---- VarTestStruct: the record EM.MW{{a0, Xl1024.MW{{LDEP(tt), tt, n}}, a2}} ----
def okp_vt(+a0: U32, +a2: U32, +mB: Xl1024.MW, +hB: {{Xl1024.OK(mB) == True{{}} : Bool}}, {FP}, +hb: {{{BND} == True{{}} : Bool}}) -> {{EM.OK(EM.MW{{a0, mB, a2}}) == True{{}} : Bool}}:
  +h8 = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(a2), U32.to_nat(255)), U32.is_le(a2, 255),
    Equal.sym(Bool, U32.is_le(a2, 255), Nat.is_le(U32.to_nat(a2), U32.to_nat(255)), VU.le_u32(a2, 255)), LB.small(a2, h2))
  FD.logic__and_intro(Xl1024.OK(mB), Bool.and(Bool.and(uint16_e.u16_valid(a0), uint8_e.u8_valid(a2)), {BND}), hB,
    FD.logic__and_intro(Bool.and(uint16_e.u16_valid(a0), uint8_e.u8_valid(a2)), {BND},
      FD.logic__and_intro(uint16_e.u16_valid(a0), uint8_e.u8_valid(a2), GW.u16v(a0, h0), h8), hb))

def val_vt(+a0: U32, +a2: U32, +tt: {TR}, +n: U32, {FP}, +eb: {{{VW} == {VL} : S.Value}}) -> {{RT.v_Gc465214E502(EM.TH({RM})) == EM.VAL({RM}) : S.Value}}:
  %Equal.sym(U32, {V16}, a0, GW.eq16(a0, h0)) : {MOT('_', VL, 'U32.and(a2, 255)')}
  %Equal.sym(U32, U32.and(a2, 255), a2, VBB.ea(a2, h2)) : {MOT('a0', VL, '_')}
  %eb : {MOT('a0', '_', 'a2')}
  {{==}}

def VTF(+a0: U32, +a2: U32, +tt: {TR}, +n: U32) -> Data:
  DK.P2({{RT.v_Gc465214E502(EM.TH({RM})) == EM.VAL({RM}) : S.Value}}, DK.P2({{EM.OK({RM}) == True{{}} : Bool}}, {{Nat.is_le(LY.LN(EM.ENC({RM})), {EB}n) == True{{}} : Bool}}))

# the record's facts from its fields' facts and the list's premise
def vtf(+a0: U32, +a2: U32, +tt: {TR}, +n: U32, {FP}, {CP}, +hs: BL.sdk({WL('tt', 'n')}, {encr_k('l1024')}n)) -> VTF(a0, a2, tt, n):
  +hl = ok_l1024(tt, n, sfk(tt, n, {encr_k('l1024')}n, hs), c, ec, hk)
  +hL = ln_l1024(tt, n, hl, c, ec, hk)
  +hb = FD.nat__le_trans(Nat.add({FIX}n, LY.LN(Xl1024.ENC({MB}))), {EB}n, A.quad(VB.pw({KB}n)), FD.nat__le_add_left(LY.LN(Xl1024.ENC({MB})), {M2}n, {FIX}n, hL),
    FD.nat__le_trans({EB}n, A.quad(VB.pw({PW}n)), A.quad(VB.pw({KB}n)), {{==}}, C.q4(VB.pw({PW}n), VB.pw({KB}n), VBG.pw_mono({PW}n, {KB}n, {{==}}))))
  +hok = okp_vt(a0, a2, {MB}, hl, h0, h2, hb)
  +ln = FD.logic__subst(Nat, z => {{Nat.is_le(z, {EB}n) == True{{}} : Bool}}, Nat.add({FIX}n, LY.LN(Xl1024.ENC({MB}))), List.length(&2, U32, EK.ENCC(a0, {MB}, a2)),
    Equal.sym(Nat, List.length(&2, U32, EK.ENCC(a0, {MB}, a2)), Nat.add({FIX}n, LY.LN(Xl1024.ENC({MB}))), EM.lenE(a0, {MB}, a2, hok)), FD.nat__le_add_left(LY.LN(Xl1024.ENC({MB})), {M2}n, {FIX}n, hL))
  (val_vt(a0, a2, tt, n, h0, h2, lv_l1024(tt, n, c, ec, hk)), (hok, ln))

def VTR(v: {VT}) -> Data:
  DK.Ex(EM.MW, m => DK.P2({{v == EM.TH(m) : {VT}}}, DK.P2({{RT.v_Gc465214E502(EM.TH(m)) == EM.VAL(m) : S.Value}}, DK.P2({{EM.OK(m) == True{{}} : Bool}}, {{Nat.is_le(LY.LN(EM.ENC(m)), {EB}n) == True{{}} : Bool}}))))

def vtb3(-v: {VT}, +x0: U32, +x2: U32, +tt: {TR}, +n: U32, +eo: {{v == {VT}{{x0, {WL('tt', 'n')}, x2}} : {VT}}}, +f: VTF(x0, x2, tt, n)) -> VTR(v):
  (+fv, +f1) = f
  (+fo, +fl) = f1
  (EM.MW{{x0, Xl1024.MW{{LDEP(U32, tt), tt, n}}, x2}}, (eo, (fv, (fo, fl))))

def vtb2(-v: {VT}, +x0: U32, +x2: U32, +ev: {{v == {VT}{{x0, RT.pj_Gc465214E502_1(v), x2}} : {VT}}}, +h0: {{U32.is_lt(x0, 65536) == True{{}} : Bool}}, +h2: {{U32.is_lt(x2, 256) == True{{}} : Bool}},
    +hx: {{U32.to_nat(WO.len(RT.pj_Gc465214E502_1(v))) == Nat.double(PBF.cnt2(RT.pj_Gc465214E502_1(v))) : Nat}}, +hl: {{Nat.is_le(PBF.cnt2(RT.pj_Gc465214E502_1(v)), {LIM}n) == True{{}} : Bool}},
    +hs: BL.sdk(RT.pj_Gc465214E502_1(v), {encr_k('l1024')}n), +cw: DK.Ex({TR}, t => DK.Ex(U32, n => {{RT.pj_Gc465214E502_1(v) == {WL('t', 'n')} : O.Words}}))) -> VTR(v):
  (+tt, +c1) = cw
  (+n, +ew) = c1
  +hx2 = FD.logic__subst(O.Words, z => {{U32.to_nat(WO.len(z)) == Nat.double(PBF.cnt2(z)) : Nat}}, RT.pj_Gc465214E502_1(v), {WL('tt', 'n')}, ew, hx)
  +hl2 = FD.logic__subst(O.Words, z => {{Nat.is_le(PBF.cnt2(z), {LIM}n) == True{{}} : Bool}}, RT.pj_Gc465214E502_1(v), {WL('tt', 'n')}, ew, hl)
  +hs2 = FD.logic__subst(O.Words, z => BL.sdk(z, {encr_k('l1024')}n), RT.pj_Gc465214E502_1(v), {WL('tt', 'n')}, ew, hs)
  +eo = Equal.trans({VT}, v, {VT}{{x0, RT.pj_Gc465214E502_1(v), x2}}, {VT}{{x0, {WL('tt', 'n')}, x2}}, ev,
    Equal.cong(O.Words, {VT}, z => {VT}{{x0, z, x2}}, RT.pj_Gc465214E502_1(v), {WL('tt', 'n')}, ew))
  vtb3(v, x0, x2, tt, n, eo, vtf(x0, x2, tt, n, h0, h2, PBF.cnt2({WL('tt', 'n')}), hx2, hl2, hs2))

# a VarTestStruct the root law represents, with its list's premise: its record
def vtb(-v: {VT}, +rep: RT.rep_Gc465214E502(v, Spec.Gc465214E502()), +hs: BL.sdk(RT.pj_Gc465214E502_1(v), {encr_k('l1024')}n)) -> VTR(v):
  (+x0, +r0) = rep
  (+x2, +r1) = r0
  (+ev, +q1) = r1
  (+h0, +q2) = q1
  (+c1, +h2) = q2
  (+wf, +z1) = c1
  (+hx, +hl) = z1
  vtb2(v, x0, x2, ev, h0, h2, hx, hl, hs, cpw(RT.pj_Gc465214E502_1(v), wf))
''')
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vbig.bend as VBG', 'import ../proofs/obj/vbytes.bend as VY',
            'import ../proofs/obj/vua_lay.bend as LY', 'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/words_spec.bend as WS',
            'import ../proofs/obj/packed_bytes.bend as PBF', 'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/vu32.bend as VU',
            'import ../proofs/obj/len_bridge.bend as LB', 'import ../proofs/obj/vbitb.bend as VBB', 'import ../proofs/obj/dk.bend as DK',
            'import ../proofs/obj/list_obj.bend as LO', 'import ../proofs/obj/blist_obj.bend as BLI', 'import ../proofs/obj/generic_specs.bend as Spec',
            'import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/big_encx_Gc465214E502_iface.bend as EM', 'import ../proofs/obj/big_encx_Gc465214E502.bend as EK',
            'import ../types/uint16_encode_ssz_generated.bend as uint16_e', 'import ../types/uint8_encode_ssz_generated.bend as uint8_e',
            'import ../types/VarTestStruct_def_generated.bend as VarTestStruct_d'] + imps + [
            'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_tz.bend as TZ', 'import ./e2e_cap.bend as C', 'import ./e2e_gwin.bend as GW']
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# Encode records from the root law's representation: a storage field O.Words{thaw(tt), n} is the record
# X.MW{LDEP(tt), tt, n}, valid when its storage premise (BL.sdk at the record's depth bound) holds; a
# VarTestStruct's record from its fields (vtf) or its root-law rep (vtb).

''' + '\n'.join(L)


SUPPORT_OUT['e2e_encr.bend'] = encr_text()


# ==== e2e_encv: encode records of vectors from the root law's representation ====
# A vector of variable-size elements (v2_Gc465214E502): the root law's mirror tree t of boxed element mirrors
# maps (EMAP, elementwise em1) to the encode law's tree of element records; am_eq, map_pf, tdm_map, slots_map,
# xat_map carry the object, depth and slots across, and eoks_go / xi_go / bl_go (by induction on the count)
# its elements' validity, values and byte lengths. A vector of fixed-size records (v4_GcDC3E457711) is its own
# record MW{dw, t, N}.

def vt_eb():
    em = _obj('big_encx_Gc465214E502_iface.bend')
    FIX = int(re.search(r'^def ENDC\(.*?\) -> Nat: Nat\.add\((\d+)n,', em, re.M).group(1))
    M2 = int(re.search(r'Nat\.is_le\(U32\.to_nat\(N\), U32\.to_nat\((\d+)\)\)', _okt(_obj(ENCR_LISTS['l1024'][0]))).group(1))
    return FIX + M2


def _pw_above(x):
    p = 1
    while 4 * 2 ** p < x:
        p += 1
    return p


def encv_text():
    RMB = 'RT.MB<RT.M_Gc465214E502>'
    EMB = 'EN2.MB<EM.MW>'
    TRR = f'FD.array__Tree<{RMB}>'
    LR = f'List<&2, {RMB}>'
    LE = f'List<&2, {EMB}>'
    VT = 'VarTestStruct_d.Gc465214E502'
    ARR = f'Array<O.Boxed<{VT}>>'
    SEQ = 'vec_VarTestStruct_2_d.v2_Gc465214E502_Seq'
    SE = 'Spec.Gc465214E502()'
    en2 = _obj('big_encx_v2_Gc465214E502.bend')
    OKL = _okt(en2, 'OKL')
    Kt = int(re.search(r'Nat\.is_lt\(TDM\(t\), (\d+)n\)', OKL).group(1))
    NV = int(re.search(r'U32\.is_eq\(N, (\d+)\)', OKL).group(1))
    KQ = int(re.search(r'A\.quad\(VB\.pw\((\d+)n\)\)', _okt(en2)).group(1))
    SV2 = f'S.Vector{{{SE}, {NV}n}}'
    K = encr_k('l1024')
    EB = vt_eb()
    LB = 4 * NV + NV * EB
    P = _pw_above(LB)
    WL = lambda t, n: f'O.Words{{FD.array__thaw(U32, {t}), {n}}}'  # noqa: E731
    k = 'U32.to_nat(N)'
    SL = lambda t: f'FD.array__slots({RMB}, {t})'  # noqa: E731
    SLE = lambda t: f'FD.array__slots({EMB}, {t})'  # noqa: E731

    def okl_txt(D, S_):
        s = OKL.replace('TDM(t)', '@D@').replace('SL(t)', '@S@')
        s = re.sub(r'\bt\b', 'EMAP(t)', s).replace('F.', 'FD.').replace('MB<EM.MW>', EMB).replace('EOKS(', 'EN2.EOKS(')
        return s.replace('@D@', D).replace('@S@', S_)
    ES_T = lambda W, i: f'BL.sdk(RT.pj_Gc465214E502_1(RT.pjb_Gc465214E502_bx(RT.th_Gc465214E502_bx(RT.xat_v2_Gc465214E502({W}, {i})))), K)'  # noqa: E731
    HS = lambda x: f'BL.sdk(RT.pj_Gc465214E502_1(RT.pjb_Gc465214E502_bx(RT.th_Gc465214E502_bx({x}))), {K}n)'  # noqa: E731
    RB = lambda x: f'RT.rep_Gc465214E502_bx(RT.th_Gc465214E502_bx({x}), {SE})'  # noqa: E731
    RM = 'EM.MW{a0, Xl1024.MW{ER.LDEP(U32, tt), tt, n}, a2}'
    MS = f'RT.MSome{{RT.M_Gc465214E502{{a0, RT.WMr{{tt, n}}, a2}}}}'
    L = []
    L.append(f'''# ---- the element map: a VarTestStruct's mirror M{{a0, WMr{{t, n}}, a2}} to its record ----
def wrec(w: RT.WMr) -> Xl1024.MW:
  match w:
    case RT.WMr{{+t, +n}}: Xl1024.MW{{ER.LDEP(U32, t), t, n}}
def em0(m: RT.M_Gc465214E502) -> EM.MW:
  match m:
    case RT.M_Gc465214E502{{+a0, +a1, +a2}}: EM.MW{{a0, wrec(a1), a2}}
def em1(x: {RMB}) -> {EMB}:
  match x:
    case RT.MNone{{}}: EN2.MNone{{}}
    case RT.MSome{{+v}}: EN2.MSome{{em0(v)}}

def thw(+a0: U32, +w: RT.WMr, +a2: U32) -> {{EM.TH(EM.MW{{a0, wrec(w), a2}}) == RT.th_Gc465214E502(RT.M_Gc465214E502{{a0, w, a2}}) : {VT}}}:
  match w:
    case RT.WMr{{+t, +n}}: {{==}}
def thm(+m: RT.M_Gc465214E502) -> {{EM.TH(em0(m)) == RT.th_Gc465214E502(m) : {VT}}}:
  match m:
    case RT.M_Gc465214E502{{+a0, +a1, +a2}}: thw(a0, a1, a2)
def thb(+x: {RMB}) -> {{EN2.th_Gc465214E502_bx(em1(x)) == RT.th_Gc465214E502_bx(x) : O.Boxed<{VT}>}}:
  match x:
    case RT.MNone{{}}: {{==}}
    case RT.MSome{{+v}}: Equal.cong({VT}, O.Boxed<{VT}>, z => O.BSome{{z, O.BNone{{}}}}, EM.TH(em0(v)), RT.th_Gc465214E502(v), thm(v))

# ---- an element's facts: its record is valid, its value the root view, its bytes at most {EB} ----
def EF(+x: {RMB}) -> Data:
  DK.P2({{EN2.EOK(em1(x)) == True{{}} : Bool}}, DK.P2({{EN2.EV(em1(x)) == RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(x)) : S.Value}}, {{Nat.is_le(LY.LN(EN2.YE(em1(x))), {EB}n) == True{{}} : Bool}}))

def vf0(v: {VT}) -> U32:
  match v:
    case {VT}{{+x0, x1, +x2}}: x0
def vf2(v: {VT}) -> U32:
  match v:
    case {VT}{{+x0, x1, +x2}}: x2
def isS(o: O.Boxed<{VT}>) -> Bool:
  match o:
    case O.BSome{{v, rest}}: True{{}}
    case O.BNone{{}}: False{{}}

def vtt2(+a0: U32, +tt: FD.array__Tree<U32>, +n: U32, +a2: U32, +f: ER.VTF(a0, a2, tt, n)) -> EF({MS}):
  (+fv, +f1) = f
  (+fo, +fl) = f1
  (fo, (Equal.sym(S.Value, RT.v_Gc465214E502(EM.TH({RM})), EM.VAL({RM}), fv), fl))

def vtt(+a0: U32, +tt: FD.array__Tree<U32>, +n: U32, +a2: U32, +rb: {RB(MS)}, +hs: BL.sdk({WL('tt', 'n')}, {K}n)) -> EF({MS}):
  (+eb, +rv) = rb
  (+x0, +r0) = rv
  (+x2, +r1) = r0
  (+ev, +q1) = r1
  (+h0, +q2) = q1
  (+c1, +h2) = q2
  (+wf, +z1) = c1
  (+hx, +hl) = z1
  +e0 = Equal.cong({VT}, U32, z => vf0(z), {VT}{{a0, {WL('tt', 'n')}, a2}}, {VT}{{x0, {WL('tt', 'n')}, x2}}, ev)
  +e2 = Equal.cong({VT}, U32, z => vf2(z), {VT}{{a0, {WL('tt', 'n')}, a2}}, {VT}{{x0, {WL('tt', 'n')}, x2}}, ev)
  +h0a = FD.logic__subst(U32, z => {{U32.is_lt(z, 65536) == True{{}} : Bool}}, x0, a0, Equal.sym(U32, a0, x0, e0), h0)
  +h2a = FD.logic__subst(U32, z => {{U32.is_lt(z, 256) == True{{}} : Bool}}, x2, a2, Equal.sym(U32, a2, x2, e2), h2)
  vtt2(a0, tt, n, a2, ER.vtf(a0, a2, tt, n, h0a, h2a, PBF.cnt2({WL('tt', 'n')}), hx, hl, hs))

def vtw(+a0: U32, +w: RT.WMr, +a2: U32, +rb: {RB('RT.MSome{RT.M_Gc465214E502{a0, w, a2}}')}, +hs: {HS('RT.MSome{RT.M_Gc465214E502{a0, w, a2}}')})
    -> EF(RT.MSome{{RT.M_Gc465214E502{{a0, w, a2}}}}):
  match w:
    case RT.WMr{{+tt, +n}}: vtt(a0, tt, n, a2, rb, hs)
def vtm(+m: RT.M_Gc465214E502, +rb: {RB('RT.MSome{m}')}, +hs: {HS('RT.MSome{m}')}) -> EF(RT.MSome{{m}}):
  match m:
    case RT.M_Gc465214E502{{+a0, +a1, +a2}}: vtw(a0, a1, a2, rb, hs)
def nb(+rb: {RB('RT.MNone{}')}) -> Empty:
  (+eb, +rv) = rb
  FD.logic__false_true(Equal.cong(O.Boxed<{VT}>, Bool, z => isS(z), O.BNone{{}}, O.BSome{{RT.pjb_Gc465214E502_bx(O.BNone{{}}), O.BNone{{}}}}, eb))
def vte(+x: {RMB}, +rb: {RB('x')}, +hs: {HS('x')}) -> EF(x):
  match x:
    case RT.MNone{{}}: Empty.absurd(EF(RT.MNone{{}}), nb(rb))
    case RT.MSome{{+m}}: vtm(m, rb, hs)

# ---- the tree map ----
def EMAP(t: {TRR}) -> FD.array__Tree<{EMB}>:
  match t:
    case FD.TLeaf{{+x}}: FD.TLeaf{{em1(x)}}
    case FD.TNode{{l, r}}: FD.TNode{{EMAP(l), EMAP(r)}}
def LMAP(W: {LR}) -> {LE}:
  match W:
    case Nil{{}}: Nil{{}}
    case Con{{+x, t}}: Con{{em1(x), LMAP(t)}}

def am_eq(+t: {TRR}) -> {{EN2.am_v2_Gc465214E502(EMAP(t)) == RT.am_v2_Gc465214E502(t) : {ARR}}}:
  match t:
    case FD.TLeaf{{+x}}: Equal.cong(O.Boxed<{VT}>, {ARR}, z => ALeaf{{z}}, EN2.th_Gc465214E502_bx(em1(x)), RT.th_Gc465214E502_bx(x), thb(x))
    case FD.TNode{{+l, +r}}:
      %Equal.sym({ARR}, EN2.am_v2_Gc465214E502(EMAP(l)), RT.am_v2_Gc465214E502(l), am_eq(l)) : {{ANode{{_, EN2.am_v2_Gc465214E502(EMAP(r))}} == ANode{{RT.am_v2_Gc465214E502(l), RT.am_v2_Gc465214E502(r)}} : {ARR}}}
      %Equal.sym({ARR}, EN2.am_v2_Gc465214E502(EMAP(r)), RT.am_v2_Gc465214E502(r), am_eq(r)) : {{ANode{{RT.am_v2_Gc465214E502(l), _}} == ANode{{RT.am_v2_Gc465214E502(l), RT.am_v2_Gc465214E502(r)}} : {ARR}}}
      {{==}}

def map_pf(+d: Nat, +t: {TRR}, +pf: {{FD.array__perfect({RMB}, d, t) == True{{}} : Bool}}) -> {{FD.array__perfect({EMB}, d, EMAP(t)) == True{{}} : Bool}}:
  match d t:
    case 0n FD.TLeaf{{x}}: {{==}}
    case 0n FD.TNode{{l, r}}: Empty.absurd({{FD.array__perfect({EMB}, 0n, EMAP(FD.TNode{{l, r}})) == True{{}} : Bool}}, FD.logic__false_true(pf))
    case 1n+p FD.TLeaf{{x}}: Empty.absurd({{FD.array__perfect({EMB}, 1n+p, EMAP(FD.TLeaf{{x}})) == True{{}} : Bool}}, FD.logic__false_true(pf))
    case 1n+ +p FD.TNode{{+l, +r}}: FD.logic__and_intro(FD.array__perfect({EMB}, p, EMAP(l)), FD.array__perfect({EMB}, p, EMAP(r)),
      map_pf(p, l, FD.array__pf_left({RMB}, p, l, r, pf)), map_pf(p, r, FD.array__pf_right({RMB}, p, l, r, pf)))

def tdm_map(+t: {TRR}) -> {{EN2.TDM(EMAP(t)) == ER.LDEP({RMB}, t) : Nat}}:
  match t:
    case FD.TLeaf{{x}}: {{==}}
    case FD.TNode{{+l, +r}}: Equal.cong(Nat, Nat, z => 1n+z, EN2.TDM(EMAP(l)), ER.LDEP({RMB}, l), tdm_map(l))

def lmap_app(+a: {LR}, +b: {LR}) -> {{LMAP(FD.spec_common__append({RMB}, a, b)) == FD.spec_common__append({EMB}, LMAP(a), LMAP(b)) : {LE}}}:
  match a:
    case Nil{{}}: {{==}}
    case Con{{+x, +t}}: Equal.cong({LE}, {LE}, z => Con{{em1(x), z}}, LMAP(FD.spec_common__append({RMB}, t, b)), FD.spec_common__append({EMB}, LMAP(t), LMAP(b)), lmap_app(t, b))

def slots_map(+t: {TRR}) -> {{{SLE('EMAP(t)')} == LMAP({SL('t')}) : {LE}}}:
  match t:
    case FD.TLeaf{{+x}}: {{==}}
    case FD.TNode{{+l, +r}}:
      %Equal.sym({LE}, {SLE('EMAP(l)')}, LMAP({SL('l')}), slots_map(l)) : {{FD.spec_common__append({EMB}, _, {SLE('EMAP(r)')}) == LMAP(FD.spec_common__append({RMB}, {SL('l')}, {SL('r')})) : {LE}}}
      %Equal.sym({LE}, {SLE('EMAP(r)')}, LMAP({SL('r')}), slots_map(r)) : {{FD.spec_common__append({EMB}, LMAP({SL('l')}), _) == LMAP(FD.spec_common__append({RMB}, {SL('l')}, {SL('r')})) : {LE}}}
      Equal.sym({LE}, LMAP(FD.spec_common__append({RMB}, {SL('l')}, {SL('r')})), FD.spec_common__append({EMB}, LMAP({SL('l')}), LMAP({SL('r')})), lmap_app({SL('l')}, {SL('r')}))

def xat_map(+W: {LR}, +i: Nat) -> {{EN2.xat_v2_Gc465214E502(LMAP(W), i) == em1(RT.xat_v2_Gc465214E502(W, i)) : {EMB}}}:
  match W i:
    case Nil{{}} _: {{==}}
    case Con{{+x, +t}} 0n: {{==}}
    case Con{{+x, +t}} 1n+ +j: xat_map(t, j)

# ---- the elements' premise: each element's list storage at depth below K ----
def ES(k: Nat, +W: {LR}, +i: Nat, +K: Nat) -> Data:
  match k:
    case 0n: {{True{{}} == True{{}} : Bool}}
    case 1n+q: DK.P2({ES_T('W', 'i')}, ES(q, W, 1n+i, K))

# the vector's premise: its mirror tree below Kt, its elements' lists below K
def sv2(v: {SEQ}, +Kt: Nat, +K: Nat) -> Data:
  match v:
    case {SEQ}{{arr, +n}}: DK.P2({{Nat.is_lt(ER.LDEP({RMB}, RT.tfz_v2_Gc465214E502(arr)), Kt) == True{{}} : Bool}}, ES(U32.to_nat(n), {SL('RT.tfz_v2_Gc465214E502(arr)')}, 0n, K))

# ---- by induction on the count: validity, values, byte lengths ----
def eoks_go(+k: Nat, +W: {LR}, +i: Nat, +er: RT.ereps_v2_Gc465214E502(k, W, i, {SE}), +es: ES(k, W, i, {K}n)) -> {{EN2.EOKS(k, LMAP(W), i) == True{{}} : Bool}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      (+rb, +er2) = er
      (+hs, +es2) = es
      +fo = eok1(RT.xat_v2_Gc465214E502(W, i), vte(RT.xat_v2_Gc465214E502(W, i), rb, hs))
      +fo2 = FD.logic__subst({EMB}, z => {{EN2.EOK(z) == True{{}} : Bool}}, em1(RT.xat_v2_Gc465214E502(W, i)), EN2.xat_v2_Gc465214E502(LMAP(W), i),
        Equal.sym({EMB}, EN2.xat_v2_Gc465214E502(LMAP(W), i), em1(RT.xat_v2_Gc465214E502(W, i)), xat_map(W, i)), fo)
      FD.logic__and_intro(EN2.EOK(EN2.xat_v2_Gc465214E502(LMAP(W), i)), EN2.EOKS(q, LMAP(W), 1n+i), fo2, eoks_go(q, W, 1n+i, er2, es2))

def BB(k: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+q: Nat.add({EB}n, BB(q))

def xi_go(+k: Nat, +W: {LR}, +i: Nat, +er: RT.ereps_v2_Gc465214E502(k, W, i, {SE}), +es: ES(k, W, i, {K}n)) -> {{EN2.XI(k, LMAP(W), i) == RT.xi_v2_Gc465214E502(k, W, i) : S.Value}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      (+rb, +er2) = er
      (+hs, +es2) = es
      +fv = ev1(RT.xat_v2_Gc465214E502(W, i), vte(RT.xat_v2_Gc465214E502(W, i), rb, hs))
      %Equal.sym({EMB}, EN2.xat_v2_Gc465214E502(LMAP(W), i), em1(RT.xat_v2_Gc465214E502(W, i)), xat_map(W, i)) :
        {{S.Items{{EN2.EV(_), EN2.XI(q, LMAP(W), 1n+i)}} == S.Items{{RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(RT.xat_v2_Gc465214E502(W, i))), RT.xi_v2_Gc465214E502(q, W, 1n+i)}} : S.Value}}
      %Equal.sym(S.Value, EN2.EV(em1(RT.xat_v2_Gc465214E502(W, i))), RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(RT.xat_v2_Gc465214E502(W, i))), fv) :
        {{S.Items{{_, EN2.XI(q, LMAP(W), 1n+i)}} == S.Items{{RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(RT.xat_v2_Gc465214E502(W, i))), RT.xi_v2_Gc465214E502(q, W, 1n+i)}} : S.Value}}
      %Equal.sym(S.Value, EN2.XI(q, LMAP(W), 1n+i), RT.xi_v2_Gc465214E502(q, W, 1n+i), xi_go(q, W, 1n+i, er2, es2)) :
        {{S.Items{{RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(RT.xat_v2_Gc465214E502(W, i))), _}} == S.Items{{RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(RT.xat_v2_Gc465214E502(W, i))), RT.xi_v2_Gc465214E502(q, W, 1n+i)}} : S.Value}}
      {{==}}

def bl_go(+k: Nat, +W: {LR}, +i: Nat, +er: RT.ereps_v2_Gc465214E502(k, W, i, {SE}), +es: ES(k, W, i, {K}n)) -> {{Nat.is_le(EN2.BL(k, LMAP(W), i), BB(k)) == True{{}} : Bool}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      (+rb, +er2) = er
      (+hs, +es2) = es
      +fl = ln1(RT.xat_v2_Gc465214E502(W, i), vte(RT.xat_v2_Gc465214E502(W, i), rb, hs))
      +fl2 = FD.logic__subst({EMB}, z => {{Nat.is_le(LY.LN(EN2.YE(z)), {EB}n) == True{{}} : Bool}}, em1(RT.xat_v2_Gc465214E502(W, i)), EN2.xat_v2_Gc465214E502(LMAP(W), i),
        Equal.sym({EMB}, EN2.xat_v2_Gc465214E502(LMAP(W), i), em1(RT.xat_v2_Gc465214E502(W, i)), xat_map(W, i)), fl)
      +Y = EN2.YE(EN2.xat_v2_Gc465214E502(LMAP(W), i))
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y, VR.bcat(EN2.YS(q, LMAP(W), 1n+i)))), Nat.add(List.length(&2, U32, Y), List.length(&2, U32, VR.bcat(EN2.YS(q, LMAP(W), 1n+i)))),
          VSP.len_app(Y, VR.bcat(EN2.YS(q, LMAP(W), 1n+i)))) : {{Nat.is_le(_, BB(1n+q)) == True{{}} : Bool}}
      ER.addle(List.length(&2, U32, Y), EN2.BL(q, LMAP(W), 1n+i), {EB}n, BB(q), fl2, bl_go(q, W, 1n+i, er2, es2))

def ieq_{NV}(+N: U32, +eN: {{U32.to_nat(N) == {NV}n : Nat}}) -> {{U32.is_eq(N, {NV}) == True{{}} : Bool}}:
  %Equal.sym(Cmp, U32.cmp(N, {NV}), Nat.cmp(U32.to_nat(N), U32.to_nat({NV})), FD.u32__u32_cmp(N, {NV})) : {{Cmp.is_eq(_) == True{{}} : Bool}}
  %Equal.sym(Nat, U32.to_nat(N), {NV}n, eN) : {{Cmp.is_eq(Nat.cmp(_, U32.to_nat({NV}))) == True{{}} : Bool}}
  {{==}}

# ---- the vector's record EN2.MW{{EMAP(t), N}} ----
def hll(+t: {TRR}, +N: U32, +eN: {{U32.to_nat(N) == {NV}n : Nat}}, +er: RT.ereps_v2_Gc465214E502({k}, {SL('t')}, 0n, {SE}), +es: ES({k}, {SL('t')}, 0n, {K}n))
    -> {{Nat.is_le(EN2.LL(EMAP(t), N), {LB}n) == True{{}} : Bool}}:
  +hb = bl_go({k}, {SL('t')}, 0n, er, es)
  +h1 = FD.nat__le_add_left(EN2.BL({k}, LMAP({SL('t')}), 0n), BB({k}), A.quad({k}), hb)
  +h2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(A.quad(z), BB(z)), {LB}n) == True{{}} : Bool}}, {NV}n, {k}, Equal.sym(Nat, {k}, {NV}n, eN), {{==}})
  %Equal.sym({LE}, {SLE('EMAP(t)')}, LMAP({SL('t')}), slots_map(t)) : {{Nat.is_le(Nat.add(A.quad({k}), EN2.BL({k}, _, 0n)), {LB}n) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add(A.quad({k}), EN2.BL({k}, LMAP({SL('t')}), 0n)), Nat.add(A.quad({k}), BB({k})), {LB}n, h1, h2)

def llq(+x: Nat, +h: {{Nat.is_le(x, {LB}n) == True{{}} : Bool}}) -> {{Nat.is_le(x, A.quad(VB.pw({KQ}n))) == True{{}} : Bool}}:
  FD.nat__le_trans(x, {LB}n, A.quad(VB.pw({KQ}n)), h, FD.nat__le_trans({LB}n, A.quad(VB.pw({P}n)), A.quad(VB.pw({KQ}n)), {{==}}, C.q4(VB.pw({P}n), VB.pw({KQ}n), VBG.pw_mono({P}n, {KQ}n, {{==}}))))

def v2okl(+t: {TRR}, +dw: Nat, +N: U32, +etd: {{EN2.TDM(EMAP(t)) == dw : Nat}}, +pf: {{FD.array__perfect({RMB}, dw, t) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +hdw: {{Nat.is_lt(dw, {Kt}n) == True{{}} : Bool}}, +eN: {{U32.to_nat(N) == {NV}n : Nat}},
    +er: RT.ereps_v2_Gc465214E502({k}, {SL('t')}, 0n, {SE}), +es: ES({k}, {SL('t')}, 0n, {K}n)) -> {{EN2.OKL(EMAP(t), N) == True{{}} : Bool}}:
  %Equal.sym(Nat, EN2.TDM(EMAP(t)), dw, etd) : {{{okl_txt('_', 'EN2.SL(EMAP(t))')} == True{{}} : Bool}}
  %Equal.sym({LE}, {SLE('EMAP(t)')}, LMAP({SL('t')}), slots_map(t)) : {{{okl_txt('dw', '_')} == True{{}} : Bool}}
  @OKLPROOF@

def v2val(+t: {TRR}, +N: U32, +er: RT.ereps_v2_Gc465214E502({k}, {SL('t')}, 0n, {SE}), +es: ES({k}, {SL('t')}, 0n, {K}n))
    -> {{RT.xv_v2_Gc465214E502(EN2.TH(EN2.MW{{EMAP(t), N}})) == EN2.VAL(EN2.MW{{EMAP(t), N}}) : S.Value}}:
  %Equal.sym({ARR}, EN2.am_v2_Gc465214E502(EMAP(t)), RT.am_v2_Gc465214E502(t), am_eq(t)) :
    {{S.Sequence{{RT.xi_v2_Gc465214E502({k}, {SL('RT.tfz_v2_Gc465214E502(_)')}, 0n)}} == EN2.VALL(EMAP(t), N) : S.Value}}
  %Equal.sym({TRR}, RT.tfz_v2_Gc465214E502(RT.am_v2_Gc465214E502(t)), t, RT.tfzam_v2_Gc465214E502(t)) :
    {{S.Sequence{{RT.xi_v2_Gc465214E502({k}, {SL('_')}, 0n)}} == EN2.VALL(EMAP(t), N) : S.Value}}
  %Equal.sym({LE}, {SLE('EMAP(t)')}, LMAP({SL('t')}), slots_map(t)) :
    {{S.Sequence{{RT.xi_v2_Gc465214E502({k}, {SL('t')}, 0n)}} == S.Sequence{{EN2.XI({k}, _, 0n)}} : S.Value}}
  Equal.sym(S.Value, S.Sequence{{EN2.XI({k}, LMAP({SL('t')}), 0n)}}, S.Sequence{{RT.xi_v2_Gc465214E502({k}, {SL('t')}, 0n)}},
    Equal.cong(S.Value, S.Value, z => S.Sequence{{z}}, EN2.XI({k}, LMAP({SL('t')}), 0n), RT.xi_v2_Gc465214E502({k}, {SL('t')}, 0n), xi_go({k}, {SL('t')}, 0n, er, es)))

def V2R(v: {SEQ}) -> Data:
  DK.Ex(EN2.MW, m => DK.P2({{v == EN2.TH(m) : {SEQ}}}, DK.P2({{RT.xv_v2_Gc465214E502(EN2.TH(m)) == EN2.VAL(m) : S.Value}},
    DK.P2({{EN2.OK(m) == True{{}} : Bool}}, {{Nat.is_le(LY.LN(EN2.ENC(m)), {LB}n) == True{{}} : Bool}}))))

def v2d(-v: {SEQ}, +t: {TRR}, +dw: Nat, +N: U32, +eq: {{v == {SEQ}{{RT.am_v2_Gc465214E502(t), N}} : {SEQ}}}, +pf: {{FD.array__perfect({RMB}, dw, t) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +er: RT.ereps_v2_Gc465214E502({k}, {SL('t')}, 0n, {SE}),
    +eN: {{U32.to_nat(N) == {NV}n : Nat}}, +hdw: {{Nat.is_lt(dw, {Kt}n) == True{{}} : Bool}}, +es: ES({k}, {SL('t')}, 0n, {K}n)) -> V2R(v):
  +etd = Equal.trans(Nat, EN2.TDM(EMAP(t)), ER.LDEP({RMB}, t), dw, tdm_map(t), ER.pdep({RMB}, dw, t, pf))
  +hl = hll(t, N, eN, er, es)
  +hok = FD.logic__and_intro(EN2.OKL(EMAP(t), N), Nat.is_le(EN2.LL(EMAP(t), N), A.quad(VB.pw({KQ}n))), v2okl(t, dw, N, etd, pf, hN, hdw, eN, er, es), llq(EN2.LL(EMAP(t), N), hl))
  +eo = Equal.trans({SEQ}, v, {SEQ}{{RT.am_v2_Gc465214E502(t), N}}, {SEQ}{{EN2.am_v2_Gc465214E502(EMAP(t)), N}}, eq,
    Equal.cong({ARR}, {SEQ}, z => {SEQ}{{z, N}}, RT.am_v2_Gc465214E502(t), EN2.am_v2_Gc465214E502(EMAP(t)), Equal.sym({ARR}, EN2.am_v2_Gc465214E502(EMAP(t)), RT.am_v2_Gc465214E502(t), am_eq(t))))
  +ln = FD.logic__subst(Nat, z => {{Nat.is_le(z, {LB}n) == True{{}} : Bool}}, EN2.LL(EMAP(t), N), VE2.LEN(EN2.ENCL(EMAP(t), N)),
    Equal.sym(Nat, VE2.LEN(EN2.ENCL(EMAP(t), N)), EN2.LL(EMAP(t), N), EN2.len_encl(EMAP(t), N)), hl)
  (EN2.MW{{EMAP(t), N}}, (eo, (v2val(t, N, er, es), (hok, ln))))

def v2c2(-v: {SEQ}, +t: {TRR}, +dw: Nat, +N: U32, +eq: {{v == {SEQ}{{RT.am_v2_Gc465214E502(t), N}} : {SEQ}}}, +pf: {{FD.array__perfect({RMB}, dw, t) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +er: RT.ereps_v2_Gc465214E502({k}, {SL('t')}, 0n, {SE}), +eN: {{U32.to_nat(N) == {NV}n : Nat}},
    +hs2: DK.P2({{Nat.is_lt(ER.LDEP({RMB}, RT.tfz_v2_Gc465214E502(RT.am_v2_Gc465214E502(t))), {Kt}n) == True{{}} : Bool}}, ES({k}, {SL('RT.tfz_v2_Gc465214E502(RT.am_v2_Gc465214E502(t))')}, 0n, {K}n))) -> V2R(v):
  (+hk0, +es0) = hs2
  +hk = FD.logic__subst({TRR}, z => {{Nat.is_lt(ER.LDEP({RMB}, z), {Kt}n) == True{{}} : Bool}}, RT.tfz_v2_Gc465214E502(RT.am_v2_Gc465214E502(t)), t, RT.tfzam_v2_Gc465214E502(t), hk0)
  +es = FD.logic__subst({TRR}, z => ES({k}, {SL('z')}, 0n, {K}n), RT.tfz_v2_Gc465214E502(RT.am_v2_Gc465214E502(t)), t, RT.tfzam_v2_Gc465214E502(t), es0)
  +hdw = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {Kt}n) == True{{}} : Bool}}, ER.LDEP({RMB}, t), dw, ER.pdep({RMB}, dw, t, pf), hk)
  v2d(v, t, dw, N, eq, pf, hN, er, eN, hdw, es)

def v2c(-v: {SEQ}, +t: {TRR}, +dw: Nat, +N: U32, +eq: {{v == {SEQ}{{RT.am_v2_Gc465214E502(t), N}} : {SEQ}}}, +pf: {{FD.array__perfect({RMB}, dw, t) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +er: RT.ereps_v2_Gc465214E502({k}, {SL('t')}, 0n, {SE}),
    +hlen: {{Nat.is_eq(U32.to_nat(RT.xlen_o_v2_Gc465214E502(v)), {NV}n) == True{{}} : Bool}}, +hs: sv2(v, {Kt}n, {K}n)) -> V2R(v):
  +hs2 = FD.logic__subst({SEQ}, z => sv2(z, {Kt}n, {K}n), v, {SEQ}{{RT.am_v2_Gc465214E502(t), N}}, eq, hs)
  +hl2 = FD.logic__subst({SEQ}, z => {{Nat.is_eq(U32.to_nat(RT.xlen_o_v2_Gc465214E502(z)), {NV}n) == True{{}} : Bool}}, v, {SEQ}{{RT.am_v2_Gc465214E502(t), N}}, eq, hlen)
  v2c2(v, t, dw, N, eq, pf, hN, er, FD.nat__eq_from_is_eq(U32.to_nat(N), {NV}n, hl2), hs2)

# a Vector[VarTestStruct, {NV}] the root law represents, with its premise (sv2): its record
def v2b(-v: {SEQ}, +rep: RT.rep_v2_Gc465214E502(v, {SV2}), +hs: sv2(v, {Kt}n, {K}n)) -> V2R(v):
  (+ex, +hlen) = rep
  (+t, +e1) = ex
  (+dw, +e2) = e1
  (+N, +e3) = e2
  (+eq, +e4) = e3
  (+pf, +e5) = e4
  (+hd32, +e6) = e5
  (+hN, +er) = e6
  v2c(v, t, dw, N, eq, pf, hN, er, hlen, hs)
''')
    leaf = {'Nat.is_lt(dw, %dn)' % Kt: 'hdw', f'FD.array__perfect({EMB}, dw, EMAP(t))': 'map_pf(dw, t, pf)', 'Nat.is_le(U32.to_nat(N), VB.pw(dw))': 'hN',
            f'U32.is_eq(N, {NV})': f'ieq_{NV}(N, eN)', f'EN2.EOKS(U32.to_nat(N), LMAP({SL("t")}), 0n)': f'eoks_go({k}, {SL("t")}, 0n, er, es)'}
    text = L[0].replace('@OKLPROOF@', _andproof(okl_txt('dw', f'LMAP({SL("t")})'), leaf))
    # the element facts' projections (callee-first: before their uses)
    pro = f'''def eok1(+x: {RMB}, +f: EF(x)) -> {{EN2.EOK(em1(x)) == True{{}} : Bool}}:
  (+fo, +f1) = f
  fo
def ev1(+x: {RMB}, +f: EF(x)) -> {{EN2.EV(em1(x)) == RT.v_Gc465214E502_bx(RT.th_Gc465214E502_bx(x)) : S.Value}}:
  (+fo, +f1) = f
  (+fv, +fl) = f1
  fv
def ln1(+x: {RMB}, +f: EF(x)) -> {{Nat.is_le(LY.LN(EN2.YE(em1(x))), {EB}n) == True{{}} : Bool}}:
  (+fo, +f1) = f
  (+fv, +fl) = f1
  fl

'''
    text = text.replace('# ---- the tree map ----\n', pro + '# ---- the tree map ----\n')
    # ---- v4_GcDC3E457711 ----
    rv = _obj('big_encx_v4_GcDC3E457711.bend')
    OKT4 = _okt(rv)
    K4 = int(re.search(r'Nat\.is_lt\(da, (\d+)n\)', OKT4).group(1))
    NV4 = int(re.search(r'U32\.is_eq\(N, (\d+)\)', OKT4).group(1))
    FTS = 'FixedTestStruct_d.GcDC3E457711'
    TR4 = f'FD.array__Tree<{FTS}>'
    SEQ4 = 'vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq'
    SV4 = f'S.Vector{{Spec.GcDC3E457711(), {NV4}n}}'
    S4 = lambda t: f'FD.array__slots({FTS}, {t})'  # noqa: E731
    okt4 = re.sub(r'\bda\b', 'dw', OKT4)
    okt4 = re.sub(r'\bA\b(?!\.)', 't', okt4).replace('VOK(', 'RV.VOK(')
    leaf4 = {f'Nat.is_lt(dw, {K4}n)': 'hda', f'FD.array__perfect({FTS}, dw, t)': 'pf', 'Nat.is_le(U32.to_nat(N), VB.pw(dw))': 'hN',
             f'U32.is_eq(N, {NV4})': f'ieq_{NV4}(N, eN)',
             'RV.VOK(U32.to_nat(N), t, 0n)': f'vok_go({k}, t, 0n, er)'}
    ieq4 = '' if NV4 == NV else f'''def ieq_{NV4}(+N: U32, +eN: {{U32.to_nat(N) == {NV4}n : Nat}}) -> {{U32.is_eq(N, {NV4}) == True{{}} : Bool}}:
  %Equal.sym(Cmp, U32.cmp(N, {NV4}), Nat.cmp(U32.to_nat(N), U32.to_nat({NV4})), FD.u32__u32_cmp(N, {NV4})) : {{Cmp.is_eq(_) == True{{}} : Bool}}
  %Equal.sym(Nat, U32.to_nat(N), {NV4}n, eN) : {{Cmp.is_eq(Nat.cmp(_, U32.to_nat({NV4}))) == True{{}} : Bool}}
  {{==}}
'''
    text += f'''
# ---- Vector[FixedTestStruct, {NV4}]: its record RV.MW{{dw, t, N}} ----
{ieq4}
# the vector's premise: its record tree below K (the encode law's depth bound)
def sv4(v: {SEQ4}, +K: Nat) -> Data:
  match v:
    case {SEQ4}{{arr, +n}}: {{Nat.is_lt(ER.LDEP({FTS}, FD.array__freeze({FTS}, arr)), K) == True{{}} : Bool}}

def el_xat(+W: List<&2, {FTS}>, +j: Nat) -> {{VRL.mget({FTS}, FD.spec_common__nth({FTS}, W, j), {FTS}_default()) == RT.xat_v4_GcDC3E457711(W, j) : {FTS}}}:
  match W j:
    case Nil{{}} _: {{==}}
    case Con{{+x, +tl}} 0n: {{==}}
    case Con{{+x, +tl}} 1n+ +p: el_xat(tl, p)

def fv(+e: {FTS}, +rp: RN.rp_GcDC3E457711(e)) -> {{FixedTestStruct_e.GcDC3E457711_valid(e) == True{{}} : Bool}}:
  match e:
    case {FTS}{{+a, +b, +c}}:
      FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(a), U32.to_nat(255)), U32.is_le(a, 255),
        Equal.sym(Bool, U32.is_le(a, 255), Nat.is_le(U32.to_nat(a), U32.to_nat(255)), VU.le_u32(a, 255)), LB.small(a, rp))

def fvv2(+a: U32, +b: O.U64, +c: U32, +rp: {{U32.is_lt(a, 256) == True{{}} : Bool}}) -> {{RV.RV_GcDC3E457711({FTS}{{a, b, c}}) == RN.v_GcDC3E457711({FTS}{{a, b, c}}) : S.Value}}:
  match b:
    case O.U64{{+lo, +hi}}:
      %Equal.sym(U32, U32.and(a, 255), a, VBB.ea(a, rp)) : {{S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{_, 0, 0, 0, 0, 0, 0, 0}}}}, S.Items{{S.UnsignedValue{{P.UInt{{lo, hi, 0, 0, 0, 0, 0, 0}}}}, S.Items{{S.UnsignedValue{{P.UInt{{c, 0, 0, 0, 0, 0, 0, 0}}}}, S.EmptyItems{{}}}}}}}}}} == RN.v_GcDC3E457711({FTS}{{a, O.U64{{lo, hi}}, c}}) : S.Value}}
      {{==}}
def fvv(+e: {FTS}, +rp: RN.rp_GcDC3E457711(e)) -> {{RV.RV_GcDC3E457711(e) == RN.v_GcDC3E457711(e) : S.Value}}:
  match e:
    case {FTS}{{+a, +b, +c}}: fvv2(a, b, c, rp)

def vok_go(+k: Nat, +t: {TR4}, +j: Nat, +er: RT.ereps_v4_GcDC3E457711(k, {S4('t')}, j)) -> {{RV.VOK(k, t, j) == True{{}} : Bool}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      (+rp, +er2) = er
      +hv = FD.logic__subst({FTS}, z => {{FixedTestStruct_e.GcDC3E457711_valid(z) == True{{}} : Bool}}, RT.xat_v4_GcDC3E457711({S4('t')}, j), RV.EL(t, j),
        Equal.sym({FTS}, RV.EL(t, j), RT.xat_v4_GcDC3E457711({S4('t')}, j), el_xat({S4('t')}, j)), fv(RT.xat_v4_GcDC3E457711({S4('t')}, j), rp))
      FD.logic__and_intro(FixedTestStruct_e.GcDC3E457711_valid(RV.EL(t, j)), RV.VOK(q, t, 1n+j), hv, vok_go(q, t, 1n+j, er2))

def its_go(+k: Nat, +t: {TR4}, +j: Nat, +er: RT.ereps_v4_GcDC3E457711(k, {S4('t')}, j)) -> {{RV.ITS(k, t, j) == RT.xi_v4_GcDC3E457711(k, {S4('t')}, j) : S.Value}}:
  match k:
    case 0n: {{==}}
    case 1n+ +q:
      (+rp, +er2) = er
      +X = RT.xat_v4_GcDC3E457711({S4('t')}, j)
      %Equal.sym({FTS}, RV.EL(t, j), X, el_xat({S4('t')}, j)) : {{S.Items{{RV.RV_GcDC3E457711(_), RV.ITS(q, t, 1n+j)}} == S.Items{{RN.v_GcDC3E457711(X), RT.xi_v4_GcDC3E457711(q, {S4('t')}, 1n+j)}} : S.Value}}
      %Equal.sym(S.Value, RV.RV_GcDC3E457711(X), RN.v_GcDC3E457711(X), fvv(X, rp)) : {{S.Items{{_, RV.ITS(q, t, 1n+j)}} == S.Items{{RN.v_GcDC3E457711(X), RT.xi_v4_GcDC3E457711(q, {S4('t')}, 1n+j)}} : S.Value}}
      %Equal.sym(S.Value, RV.ITS(q, t, 1n+j), RT.xi_v4_GcDC3E457711(q, {S4('t')}, 1n+j), its_go(q, t, 1n+j, er2)) : {{S.Items{{RN.v_GcDC3E457711(X), _}} == S.Items{{RN.v_GcDC3E457711(X), RT.xi_v4_GcDC3E457711(q, {S4('t')}, 1n+j)}} : S.Value}}
      {{==}}

def v4val(+dw: Nat, +t: {TR4}, +N: U32, +er: RT.ereps_v4_GcDC3E457711({k}, {S4('t')}, 0n)) -> {{RT.xv_v4_GcDC3E457711(RV.TH(RV.MW{{dw, t, N}})) == RV.VAL(RV.MW{{dw, t, N}}) : S.Value}}:
  %Equal.sym({TR4}, FD.array__freeze({FTS}, FD.array__thaw({FTS}, t)), t, FD.array__freeze_thaw({FTS}, t)) :
    {{S.Sequence{{RT.xi_v4_GcDC3E457711({k}, {S4('_')}, 0n)}} == S.Sequence{{RV.ITS({k}, t, 0n)}} : S.Value}}
  Equal.sym(S.Value, S.Sequence{{RV.ITS({k}, t, 0n)}}, S.Sequence{{RT.xi_v4_GcDC3E457711({k}, {S4('t')}, 0n)}},
    Equal.cong(S.Value, S.Value, z => S.Sequence{{z}}, RV.ITS({k}, t, 0n), RT.xi_v4_GcDC3E457711({k}, {S4('t')}, 0n), its_go({k}, t, 0n, er)))

def V4R(v: {SEQ4}) -> Data:
  DK.Ex(RV.MW, m => DK.P2({{v == RV.TH(m) : {SEQ4}}}, DK.P2({{RT.xv_v4_GcDC3E457711(RV.TH(m)) == RV.VAL(m) : S.Value}}, {{RV.OK(m) == True{{}} : Bool}})))

def v4c2(-v: {SEQ4}, +t: {TR4}, +dw: Nat, +N: U32, +eq: {{v == {SEQ4}{{FD.array__thaw({FTS}, t), N}} : {SEQ4}}}, +pf: {{FD.array__perfect({FTS}, dw, t) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +er: RT.ereps_v4_GcDC3E457711({k}, {S4('t')}, 0n), +eN: {{U32.to_nat(N) == {NV4}n : Nat}},
    +hk0: {{Nat.is_lt(ER.LDEP({FTS}, FD.array__freeze({FTS}, FD.array__thaw({FTS}, t))), {K4}n) == True{{}} : Bool}}) -> V4R(v):
  +ea = Equal.trans(Nat, ER.LDEP({FTS}, FD.array__freeze({FTS}, FD.array__thaw({FTS}, t))), ER.LDEP({FTS}, t), dw,
    Equal.cong({TR4}, Nat, z => ER.LDEP({FTS}, z), FD.array__freeze({FTS}, FD.array__thaw({FTS}, t)), t, FD.array__freeze_thaw({FTS}, t)), ER.pdep({FTS}, dw, t, pf))
  +hda = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {K4}n) == True{{}} : Bool}}, ER.LDEP({FTS}, FD.array__freeze({FTS}, FD.array__thaw({FTS}, t))), dw, ea, hk0)
  +hok = {_andproof(okt4, leaf4)}
  (RV.MW{{dw, t, N}}, (eq, (v4val(dw, t, N, er), hok)))

def v4c(-v: {SEQ4}, +t: {TR4}, +dw: Nat, +N: U32, +eq: {{v == {SEQ4}{{FD.array__thaw({FTS}, t), N}} : {SEQ4}}}, +pf: {{FD.array__perfect({FTS}, dw, t) == True{{}} : Bool}},
    +hN: {{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}}, +er: RT.ereps_v4_GcDC3E457711({k}, {S4('t')}, 0n),
    +hlen: {{Nat.is_eq(U32.to_nat(RT.xlen_o_v4_GcDC3E457711(v)), {NV4}n) == True{{}} : Bool}}, +hs: sv4(v, {K4}n)) -> V4R(v):
  +hs2 = FD.logic__subst({SEQ4}, z => sv4(z, {K4}n), v, {SEQ4}{{FD.array__thaw({FTS}, t), N}}, eq, hs)
  +hl2 = FD.logic__subst({SEQ4}, z => {{Nat.is_eq(U32.to_nat(RT.xlen_o_v4_GcDC3E457711(z)), {NV4}n) == True{{}} : Bool}}, v, {SEQ4}{{FD.array__thaw({FTS}, t), N}}, eq, hlen)
  v4c2(v, t, dw, N, eq, pf, hN, er, FD.nat__eq_from_is_eq(U32.to_nat(N), {NV4}n, hl2), hs2)

# a Vector[FixedTestStruct, {NV4}] the root law represents, with its premise (sv4): its record
def v4b(-v: {SEQ4}, +rep: RT.rep_v4_GcDC3E457711(v, {SV4}), +hs: sv4(v, {K4}n)) -> V4R(v):
  (+ex, +hlen) = rep
  (+t, +e1) = ex
  (+dw, +e2) = e1
  (+N, +e3) = e2
  (+eq, +e4) = e3
  (+pf, +e5) = e4
  (+hd32, +e6) = e5
  (+hN, +er) = e6
  v4c(v, t, dw, N, eq, pf, hN, er, hlen, hs)
'''
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/vbig.bend as VBG', 'import ../proofs/obj/vua_lay.bend as LY', 'import ../proofs/obj/vspec.bend as VSP',
            'import ../proofs/obj/vvle.bend as VE2', 'import ../proofs/obj/vrej.bend as VR', 'import ../proofs/obj/vrl.bend as VRL',
            'import ../proofs/obj/packed_bytes.bend as PBF', 'import ../proofs/obj/vu32.bend as VU', 'import ../proofs/obj/len_bridge.bend as LB',
            'import ../proofs/obj/vbitb.bend as VBB', 'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/generic_specs.bend as Spec',
            'import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/root_gnames.bend as RN',
            'import ../proofs/obj/big_encx_Gc465214E502_iface.bend as EM', 'import ../proofs/obj/big_encx_l1024_u16.bend as Xl1024',
            'import ../proofs/obj/big_encx_v2_Gc465214E502.bend as EN2', 'import ../proofs/obj/big_encx_v4_GcDC3E457711.bend as RV',
            'import ../types/VarTestStruct_def_generated.bend as VarTestStruct_d', 'import ../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d',
            'import ../types/FixedTestStruct_def_generated.bend as FixedTestStruct_d', 'import ../types/FixedTestStruct_encode_ssz_generated.bend as FixedTestStruct_e',
            'import ../types/vec_FixedTestStruct_4_def_generated.bend as vec_FixedTestStruct_4_d',
            'import ./e2e_blist.bend as BL', 'import ./e2e_cap.bend as C', 'import ./e2e_encr.bend as ER']
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# Encode records of vectors from the root law's representation (see codegen/e2e_var_c.py: encv_text).

''' + text


SUPPORT_OUT['e2e_encv.bend'] = encv_text()


# ---- ComplexTestStruct (i): its record from its fields' records (e2e_encr, e2e_encv) ----
def mwp_complex(R, X, D):
    ci = _obj('big_encx_Gc56D855869F_iface.bend')
    okt = _okt(ci)
    m = re.search(r'^def OKT\((.*?)\) -> Bool', ci, re.M).group(1)
    names = re.findall(r'\+(\w+): ', m)
    ren = {'f_A': 'x0', 'm_f_B': 'mB', 'f_C': 'x2', 'm_f_D': 'mD', 'm_f_E': 'mE', 'm_f_F': 'mF', 'm_f_G': 'mG'}
    assert names == list(ren), names
    for a, b in ren.items():
        okt = re.sub(rf'\b{a}\b', b, okt)
    aliases = ['EX_l128_u16', 'EX_bl256', 'EX_Gc465214E502', 'RV_v4_GcDC3E457711', 'EX_v2_Gc465214E502', 'uint16_e', 'uint8_e', 'LY']
    imps = []
    for al in aliases:
        p = re.search(rf'^import (\S+) as {al}$', ci, re.M).group(1)
        p = p.replace('../../types/', '../types/') if p.startswith('../../types/') else '../proofs/obj/' + p[2:]
        imps.append(f'import {p} as {al}')
    # the storage premises: each at its encode law's depth bound
    KB, KD, KE = encr_k('l128'), encr_k('b256'), encr_k('l1024')
    en2 = _obj('big_encx_v2_Gc465214E502.bend')
    Kt = int(re.search(r'Nat\.is_lt\(TDM\(t\), (\d+)n\)', _okt(en2, 'OKL')).group(1))
    rv = _okt(_obj('big_encx_v4_GcDC3E457711.bend'))
    K4 = int(re.search(r'Nat\.is_lt\(da, (\d+)n\)', rv).group(1))
    PJ = lambda k: f'RT.pj_{X}_{k}(o)'  # noqa: E731
    sig = (f'+rep: RT.rep_{X}(o, Spec.{X}()), +hsB: BL.sdk({PJ(1)}, {KB}n), +hsD: BL.sdk({PJ(3)}, {KD}n), '
           f'+hsE: BL.sdk(RT.pj_Gc465214E502_1({PJ(4)}), {KE}n), +hsF: EV.sv4({PJ(5)}, {K4}n), +hsG: EV.sv2({PJ(6)}, {Kt}n, {KE}n)')
    # the fields' byte bounds and the total
    M2B = 2 * int(re.search(r'hk: \{Nat\.is_le\(c, (\d+)n\)', _obj(ENCR_LISTS['l128'][1])).group(1))
    LD = int(re.search(r'U32\.is_le\(N, (\d+)\)', _okt(_obj(ENCR_LISTS['b256'][0]))).group(1))
    EB = vt_eb()
    NV = int(re.search(r'U32\.is_eq\(N, (\d+)\)', _okt(en2, 'OKL')).group(1))
    LB = 4 * NV + NV * EB
    lens = {'LY.LN(EX_l128_u16.ENC(mB))': (M2B, 'lB'), 'LY.LN(EX_bl256.ENC(mD))': (LD, 'lD'),
            'LY.LN(EX_Gc465214E502.ENC(mE))': (EB, 'lE'), 'LY.LN(EX_v2_Gc465214E502.ENC(mG))': (LB, 'lG')}
    bm = re.search(r'Nat\.is_le\((Nat\.add\(.*\)), A\.quad\(VB\.pw\((\d+)n\)\)\)', okt)
    SUM, KQ = bm.group(1), int(bm.group(2))
    # the sum's leaves in order, so its bound is closed
    SUM = SUM[:[i for i in range(len(SUM)) if SUM[:i + 1].count('(') == SUM[:i + 1].count(')') and SUM[:i + 1].count('(') > 0][0] + 1]

    def bound(e):
        e = e.strip()
        if e.startswith('Nat.add('):
            a, b = [x.strip() for x in _split(e[len('Nat.add('):-1])]
            va, pa, sa = bound(a)
            vb, pb, sb = bound(b)
            return va + vb, f'ER.addle({a}, {b}, {sa}, {sb}, {pa}, {pb})', f'Nat.add({sa}, {sb})'
        if re.fullmatch(r'\d+n', e):
            return int(e[:-1]), f'Order.reflexive({e})', e
        v, p = lens[e]
        return v, p, f'{v}n'
    TV, BP, TS = bound(SUM)
    P = _pw_above(TV)
    BLEAF = f'Nat.is_le({SUM}, A.quad(VB.pw({KQ}n)))'
    BPROOF = (f'FD.nat__le_trans({SUM}, {TS}, A.quad(VB.pw({KQ}n)), {BP},\n    FD.nat__le_trans({TS}, A.quad(VB.pw({P}n)), A.quad(VB.pw({KQ}n)), {{==}}, '
              f'C.q4(VB.pw({P}n), VB.pw({KQ}n), VBG.pw_mono({P}n, {KQ}n, {{==}}))))')
    leaf = {'EX_l128_u16.OK(mB)': 'oB', 'EX_bl256.OK(mD)': 'oD', 'EX_Gc465214E502.OK(mE)': 'oE', 'RV_v4_GcDC3E457711.OK(mF)': 'oF',
            'EX_v2_Gc465214E502.OK(mG)': 'oG', 'uint16_e.u16_valid(x0)': 'GW.u16v(x0, h0)', 'uint8_e.u8_valid(x2)': 'h8', BLEAF: 'hb'}
    HOK = _andproof(okt, leaf)
    MW = 'CI.MW{x0, mB, x2, mD, mE, mF, mG}'
    # o == CI.TH(m): each projected field replaced by its record's object
    TH = {1: ('O.Words', 'EX_l128_u16.TH(mB)', 'eB'), 3: ('O.Words', 'EX_bl256.TH(mD)', 'eD'), 4: ('VarTestStruct_d.Gc465214E502', 'EX_Gc465214E502.TH(mE)', 'eE'),
          5: ('vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq', 'RV_v4_GcDC3E457711.TH(mF)', 'eF'), 6: ('vec_VarTestStruct_2_d.v2_Gc465214E502_Seq', 'EX_v2_Gc465214E502.TH(mG)', 'eG')}
    cur = ['x0', PJ(1), 'x2', PJ(3), PJ(4), PJ(5), PJ(6)]
    eqn = 'eo'
    for k_, (T, th, e) in TH.items():
        nxt = list(cur)
        nxt[k_] = th
        mot = list(cur)
        mot[k_] = 'z'
        eqn = (f'Equal.trans({D}, o, {D}{{{", ".join(cur)}}}, {D}{{{", ".join(nxt)}}},\n    {eqn},\n    '
               f'Equal.cong({T}, {D}, z => {D}{{{", ".join(mot)}}}, {PJ(k_)}, {th}, {e}))')
        cur = nxt
    # the view: VALC's items from the object's view's, position by position
    UI = lambda v: f'S.UnsignedValue{{P.UInt{{{v}, 0, 0, 0, 0, 0, 0, 0}}}}'  # noqa: E731
    lhs = [UI('x0'), 'PBF.vview2(EX_l128_u16.TH(mB))', UI('x2'), 'S.BytesValue{WO.wview(EX_bl256.TH(mD))}', 'RT.v_Gc465214E502(EX_Gc465214E502.TH(mE))',
           'RT.xv_v4_GcDC3E457711(RV_v4_GcDC3E457711.TH(mF))', 'RT.xv_v2_Gc465214E502(EX_v2_Gc465214E502.TH(mG))']
    rfull = [UI('PBM.v16of(U32.and(x0, 255), U32.and(U32.shrn(x0, 8n), 255))'), 'EX_l128_u16.VAL(mB)', UI('U32.and(x2, 255)'), 'EX_bl256.VAL(mD)',
             'EX_Gc465214E502.VAL(mE)', 'RV_v4_GcDC3E457711.VAL(mF)', 'EX_v2_Gc465214E502.VAL(mG)']
    rhs = [UI('_'), '_', UI('_'), '_', '_', '_', '_']
    eqs = ['Equal.sym(U32, PBM.v16of(U32.and(x0, 255), U32.and(U32.shrn(x0, 8n), 255)), x0, GW.eq16(x0, h0))', 'vB',
           'Equal.sym(U32, U32.and(x2, 255), x2, VBB.ea(x2, h2))', 'vD', 'vE', 'vF', 'vG']

    def seq(it):
        out = 'S.EmptyItems{}'
        for x in reversed(it):
            out = f'S.Items{{{x}, {out}}}'
        return f'S.Sequence{{{out}}}'
    steps = []
    for p in range(7):
        it = [lhs[q] if q < p else (rhs[q] if q == p else rfull[q]) for q in range(7)]
        steps.append(f'  %{eqs[p]} : {{RT.v_{X}(CI.TH({MW})) == {seq(it)} : S.Value}}')
    rl = lambda f, n: f'  (+m{f}, +{f}1) = c{f}\n  (+e{f}, +{f}2) = {f}1\n' + (f'  (+v{f}, +{f}3) = {f}2\n  (+o{f}, +l{f}) = {f}3\n' if n == 4 else f'  (+v{f}, +o{f}) = {f}2\n')  # noqa: E731
    defs = f'''# the object's record from its fields' records
def c1(-o: {D}, +x0: U32, +x2: U32, +eo: {{o == {D}{{x0, {PJ(1)}, x2, {PJ(3)}, {PJ(4)}, {PJ(5)}, {PJ(6)}}} : {D}}},
    +h0: {{U32.is_lt(x0, 65536) == True{{}} : Bool}}, +h2: {{U32.is_lt(x2, 256) == True{{}} : Bool}},
    +cB: ER.LR_l128({PJ(1)}), +cD: ER.LR_b256({PJ(3)}), +cE: ER.VTR({PJ(4)}), +cF: EV.V4R({PJ(5)}), +cG: EV.V2R({PJ(6)}))
    -> {{Some{{E.obytes(Pair.snd({D}, B.Buf, {R}_e.{X}_encode(o)))}} == API.serialize(Spec.{X}(), RT.v_{X}(o)) : Maybe<&2, +List<U32>>}}:
{rl('B', 4)}{rl('D', 4)}{rl('E', 4)}{rl('F', 3)}{rl('G', 4)}  +h8 = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(x2), U32.to_nat(255)), U32.is_le(x2, 255),
    Equal.sym(Bool, U32.is_le(x2, 255), Nat.is_le(U32.to_nat(x2), U32.to_nat(255)), VU.le_u32(x2, 255)), LB.small(x2, h2))
  +hb = {BPROOF}
  +hok = {HOK}
  via(o, {MW}, {eqn}, vw(x0, x2, mB, mD, mE, mF, mG, h0, h2, vB, vD, vE, vF, vG), hok)
'''
    vw = f'''# the object's view is the record's
def vw(+x0: U32, +x2: U32, +mB: EX_l128_u16.MW, +mD: EX_bl256.MW, +mE: EX_Gc465214E502.MW, +mF: RV_v4_GcDC3E457711.MW, +mG: EX_v2_Gc465214E502.MW,
    +h0: {{U32.is_lt(x0, 65536) == True{{}} : Bool}}, +h2: {{U32.is_lt(x2, 256) == True{{}} : Bool}},
    +vB: {{PBF.vview2(EX_l128_u16.TH(mB)) == EX_l128_u16.VAL(mB) : S.Value}}, +vD: {{S.BytesValue{{WO.wview(EX_bl256.TH(mD))}} == EX_bl256.VAL(mD) : S.Value}},
    +vE: {{RT.v_Gc465214E502(EX_Gc465214E502.TH(mE)) == EX_Gc465214E502.VAL(mE) : S.Value}}, +vF: {{RT.xv_v4_GcDC3E457711(RV_v4_GcDC3E457711.TH(mF)) == RV_v4_GcDC3E457711.VAL(mF) : S.Value}},
    +vG: {{RT.xv_v2_Gc465214E502(EX_v2_Gc465214E502.TH(mG)) == EX_v2_Gc465214E502.VAL(mG) : S.Value}}) -> {{RT.v_{X}(CI.TH({MW})) == CI.VAL({MW}) : S.Value}}:
''' + '\n'.join(steps) + '\n  {==}\n\n'
    body = f'''  (+x0, +r0) = rep
  (+x2, +r1) = r0
  (+eo, +q0) = r1
  (+h0, +q1) = q0
  (+p1, +q2) = q1
  (+h2, +q3) = q2
  (+p3, +q4) = q3
  (+p4, +q5) = q4
  (+p5, +p6) = q5
  c1(o, x0, x2, eo, h0, h2, ER.lb_l128({PJ(1)}, p1, hsB), ER.lb_b256({PJ(3)}, p3, hsD), ER.vtb({PJ(4)}, p4, hsE), EV.v4b({PJ(5)}, p5, hsF), EV.v2b({PJ(6)}, p6, hsG))'''
    pimps = ['import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/vu32.bend as VU', 'import ../proofs/obj/len_bridge.bend as LB',
             'import ../proofs/obj/vbitb.bend as VBB', 'import ../proofs/obj/vbig.bend as VBG', 'import ../proofs/obj/pb_min.bend as PBM',
             'import ../proofs/obj/packed_bytes.bend as PBF', 'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/nat_order.bend as Order',
             'import ../types/VarTestStruct_def_generated.bend as VarTestStruct_d', 'import ../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d',
             'import ../types/vec_FixedTestStruct_4_def_generated.bend as vec_FixedTestStruct_4_d',
             'import ./e2e_blist.bend as BL', 'import ./e2e_cap.bend as C', 'import ./e2e_gwin.bend as GW', 'import ./e2e_encr.bend as ER', 'import ./e2e_encv.bend as EV'] + imps
    return vw + defs, body, pimps, sig


MWP['Gc56D855869F'] = mwp_complex
VENC_SHAPES['Gc56D855869F'] = venc_mw
def cx_premise():
    KB, KD, KE = encr_k('l128'), encr_k('b256'), encr_k('l1024')
    en2 = _obj('big_encx_v2_Gc465214E502.bend')
    Kt = int(re.search(r'Nat\.is_lt\(TDM\(t\), (\d+)n\)', _okt(en2, 'OKL')).group(1))
    rv = _okt(_obj('big_encx_v4_GcDC3E457711.bend'))
    K4 = int(re.search(r'Nat\.is_lt\(da, (\d+)n\)', rv).group(1))
    return ('rep: RT.rep_Gc56D855869F(o, Spec.Gc56D855869F()) and the storage premises, each at its field\'s encode law\'s bound (read from the law; '
            'dropped when the encode laws take the root law\'s dw < 32): '
            f'hsB: BL.sdk(pj_1(o), {KB}n) (f_B\'s words below depth {KB}), hsD: BL.sdk(pj_3(o), {KD}n) (f_D\'s bytes below depth {KD}), '
            f'hsE: BL.sdk(pj_Gc465214E502_1(pj_4(o)), {KE}n) (f_E\'s list below depth {KE}), '
            f'hsF: EV.sv4(pj_5(o), {K4}n) (f_F\'s record tree below depth {K4}), '
            f'hsG: EV.sv2(pj_6(o), {Kt}n, {KE}n) (f_G\'s mirror tree below depth {Kt}, each element\'s list below depth {KE})')


VENC_PREMISE['Gc56D855869F'] = cx_premise()


VENC_PREMISE['Gc465214E502'] = ('rep: RT.rep_Gc465214E502(o, Spec.Gc465214E502()) and hs: BL.sdk(RT.pj_Gc465214E502_1(o), %dn) (the list field\'s storage '
                                'below its encode law\'s depth bound %d, read from the law; the root law gives dw < 32; dropped when the encode laws take dw < 32)'
                                % (encr_k('l1024'), encr_k('l1024')))
VENC_PREMISE['GuA2212AE21F'] = 'rep: RT.rep_GuA2212AE21F(o) (the root law\'s representation invariant; no storage premise)'
