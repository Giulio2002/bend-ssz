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
def _rep(X):
    """The rep_X of root_types: the fixed fields' witnesses [(x, type)], the constructor's argument
    texts (the list field as pj_X_i(o)) and the list field's index."""
    src = (ROOT / 'proofs/obj/root_types.bend').read_text()
    body = re.search(rf'^def rep_{X}\(o: \w+\.{X}, \+s: S\.Schema\) -> Data:\n  (.*)$', src, re.M).group(1)
    wit = re.findall(r'DK\.Ex\((\w+)\.(\w+), (x\d+) =>', body)
    cons = re.search(r'\{o == \w+\.' + X + r'\{(.*?)\} : \w+\.' + X + r'\}', body).group(1)
    args = [a.strip() for a in cons.split(', ')]
    li = [i for i, a in enumerate(args) if a.startswith(f'pj_{X}_')]
    assert len(li) == 1 and len(args) == len(wit) + 1, (X, args, wit)
    return [(x, f'T.{ty}') for _m, ty, x in wit], args, li[0]


def vroot_ulist(R, X):
    wit, args, i = _rep(X)
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
    un += [f'  (+eo, +q1) = {cur}', '  (+wf, +q2) = q1']

    def case(fields):
        return '\n'.join(f'      ({f}, w{k + 1}) = {"w" if k == 0 else "w" + str(k)}' for k, f in enumerate(fields))
    rb = (f'      rt2(h, o, rep, {XA}, t, N, Equal.trans({D}, o, {obj(PJ)}, {O1}, eo,\n'
          f'        Equal.cong(O.Words, {D}, z => {obj("z")}, {PJ}, {WORDS}, ew)))')
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/fulu_obj.bend as T', 'import ../types/schema.bend as S',
            'import ../spec/fulu_schemas.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            'import ../proofs/obj/root_types.bend as RT', 'import ../proofs/obj/gvalid_types.bend as GV', 'import ./e2e_support.bend as E']
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
    wit, args, li = _rep(X)
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
